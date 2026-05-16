import telebot
import random
import string
import json
import os
import sys
import time
import shutil
import base64
import zlib
import hashlib
import threading
from datetime import datetime

TOKEN = "8883643360:AAHBPZWx-A5QOqipNvWbkDkZtbRvWCfCqzQ"
bot = telebot.TeleBot(TOKEN)

# ========== ВЕРСИЯ ==========
BOT_VERSION = "3.0.0"
MAIN_FILE   = os.path.abspath(__file__)

# ========== БЛОКИРОВКА (потокобезопасность дуэлей) ==========
battles_lock = threading.Lock()

# ========== АДМИНЫ ==========
ADMINS     = [7561678959, 7133785280]
SUPERADMIN = 7561678959

# ========== ФАЙЛЫ ==========
PROFILES_FILE    = "profiles.json"
CARDS_FILE       = "cards.json"
BLOCKED_FILE     = "blocked.json"
LEAGUES_FILE     = "leagues.json"
BATTLES_LOG_FILE = "battles_log.json"
SETTINGS_FILE    = "settings.json"
BACKUPS_DIR      = "backups"
VERSION_FILE     = "version.json"
ERROR_LOG_FILE   = "error_log.json"
BOT_BACKUP_FILE  = "bot_backup.py"

os.makedirs(BACKUPS_DIR, exist_ok=True)

# ========== НАСТРОЙКИ ==========
DEFAULT_SETTINGS = {
    "duel_cards":      6,        # 3–8
    "duel_rounds":     5,        # 3 / 5 / 8
    "bot_difficulty":  "medium", # weak / medium / strong
    "bot_timeout":     60,       # секунд до авто-отмены хода бота
    "player_timeout":  120,      # секунд до авто-отмены хода игрока
}

def load_settings():
    if os.path.exists(SETTINGS_FILE):
        with open(SETTINGS_FILE, "r", encoding="utf-8") as f:
            s = json.load(f)
        for k, v in DEFAULT_SETTINGS.items():
            s.setdefault(k, v)
        return s
    return DEFAULT_SETTINGS.copy()

def save_settings(s):
    with open(SETTINGS_FILE, "w", encoding="utf-8") as f:
        json.dump(s, f, indent=2, ensure_ascii=False)

SETTINGS = load_settings()

# ========== ЛОГ ОШИБОК ==========
error_log      = []
error_log_lock = threading.Lock()

def log_error(source: str, error: str, extra: str = ""):
    entry = {
        "time":   datetime.now().strftime("%d.%m.%Y %H:%M:%S"),
        "source": source,
        "error":  str(error)[:300],
        "extra":  str(extra)[:200],
    }
    with error_log_lock:
        error_log.append(entry)
        if len(error_log) > 300:
            error_log.pop(0)
    try:
        with open(ERROR_LOG_FILE, "w", encoding="utf-8") as f:
            json.dump(error_log, f, indent=2, ensure_ascii=False)
    except: pass

# ========== ВЕРСИОНИРОВАНИЕ ==========
def load_version_info():
    if os.path.exists(VERSION_FILE):
        with open(VERSION_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {"current": BOT_VERSION, "history": []}

def save_version_info(data):
    with open(VERSION_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

# ========== СИСТЕМА ОБНОВЛЕНИЙ ==========
def verify_patch(patch_b64: str):
    try:
        raw        = base64.b64decode(patch_b64)
        checksum   = raw[:64].decode("utf-8")
        compressed = raw[64:]
        if hashlib.sha256(compressed).hexdigest() != checksum:
            return False, "❌ Контрольная сумма не совпадает"
        code = zlib.decompress(compressed).decode("utf-8")
        import ast; ast.parse(code)
        return True, code
    except SyntaxError as e:
        return False, f"❌ Синтаксическая ошибка: {e}"
    except Exception as e:
        return False, f"❌ Ошибка: {e}"

def apply_update(code: str, new_version: str, applied_by: int):
    ts          = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = os.path.join(BACKUPS_DIR, f"bot_v{BOT_VERSION}_{ts}.py.bak")
    shutil.copy2(MAIN_FILE, backup_path)
    vi = load_version_info()
    vi["history"].append({"version": vi["current"], "backup": backup_path,
                          "replaced_at": datetime.now().strftime("%d.%m.%Y %H:%M"),
                          "replaced_by": applied_by})
    vi["current"] = new_version; save_version_info(vi)
    with open(MAIN_FILE, "w", encoding="utf-8") as f: f.write(code)
    for aid in ADMINS:
        try: bot.send_message(aid, f"🔄 *Обновление!* v`{new_version}`\nБэкап: `{os.path.basename(backup_path)}`\n♻️ Перезапуск...", parse_mode="Markdown")
        except: pass
    time.sleep(3); os.execv(sys.executable, [sys.executable, MAIN_FILE])

def rollback_to(backup_filename: str, applied_by: int):
    backup_path = os.path.join(BACKUPS_DIR, backup_filename)
    if not os.path.exists(backup_path): return False, "❌ Файл не найден"
    with open(backup_path, "r", encoding="utf-8") as f: code = f.read()
    import ast
    try: ast.parse(code)
    except SyntaxError as e: return False, f"❌ Копия повреждена: {e}"
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    pre = os.path.join(BACKUPS_DIR, f"pre_rollback_{ts}.py.bak")
    shutil.copy2(MAIN_FILE, pre)
    with open(MAIN_FILE, "w", encoding="utf-8") as f: f.write(code)
    vi = load_version_info()
    vi["history"].append({"version": vi["current"], "backup": pre, "replaced_at": datetime.now().strftime("%d.%m.%Y %H:%M"),
                          "replaced_by": applied_by, "note": f"rollback to {backup_filename}"})
    vi["current"] = "rollback"; save_version_info(vi)
    for aid in ADMINS:
        try: bot.send_message(aid, f"⏪ *Откат!* `{backup_filename}`\n♻️ Перезапуск...", parse_mode="Markdown")
        except: pass
    time.sleep(3); os.execv(sys.executable, [sys.executable, MAIN_FILE])
    return True, ""

@bot.message_handler(commands=['sys_update'])
def sys_update_cmd(message):
    if message.chat.id not in ADMINS: return
    parts = message.text.split(maxsplit=2)
    if len(parts) < 3: bot.send_message(message.chat.id, "❌ /sys_update <версия> <patch>"); return
    new_version = parts[1]; patch_b64 = parts[2].strip()
    bot.send_message(message.chat.id, "🔍 Проверка...")
    ok, result = verify_patch(patch_b64)
    if not ok: bot.send_message(message.chat.id, result); return
    bot.send_message(message.chat.id, f"✅ Патч OK! v`{new_version}` Применяю...", parse_mode="Markdown")
    threading.Thread(target=apply_update, args=(result, new_version, message.chat.id), daemon=True).start()

@bot.message_handler(commands=['sys_rollback'])
def sys_rollback_cmd(message):
    if message.chat.id not in ADMINS: return
    parts = message.text.split(maxsplit=1)
    if len(parts) < 2:
        files = sorted(os.listdir(BACKUPS_DIR)) if os.path.exists(BACKUPS_DIR) else []
        bak   = [f for f in files if f.endswith(".py.bak")]
        if not bak: bot.send_message(message.chat.id, "📭 Нет копий."); return
        text = "💾 *Резервные копии:*\n\n" + "".join(f"`{f}`\n" for f in reversed(bak[-10:]))
        text += "\n`/sys_rollback имя.py.bak`"
        bot.send_message(message.chat.id, text, parse_mode="Markdown"); return
    filename = parts[1].strip()
    bot.send_message(message.chat.id, f"⏪ Откатываюсь к `{filename}`...", parse_mode="Markdown")
    ok, err = rollback_to(filename, message.chat.id)
    if not ok: bot.send_message(message.chat.id, err)

@bot.message_handler(commands=['sys_version'])
def sys_version_cmd(message):
    if message.chat.id not in ADMINS: return
    vi = load_version_info()
    text = f"🤖 *Версия:* `{vi['current']}`\n\n"
    hist = vi.get("history", [])
    if hist:
        text += "📜 *История (последние 5):*\n"
        for h in reversed(hist[-5:]):
            note = f" _{h.get('note','')}_" if h.get("note") else ""
            text += f"• `{h['version']}` — {h['replaced_at']}{note}\n"
    bot.send_message(message.chat.id, text, parse_mode="Markdown")

# ========== БЭКАП САМОГО БОТА ==========
@bot.message_handler(commands=['bot_backup'])
def bot_backup_cmd(message):
    """Сохранить текущий исходник бота как файл."""
    if message.chat.id not in ADMINS: return
    ts   = datetime.now().strftime("%Y%m%d_%H%M%S")
    name = f"bot_snapshot_{ts}.py.bak"
    dst  = os.path.join(BACKUPS_DIR, name)
    try:
        shutil.copy2(MAIN_FILE, dst)
        bot.send_message(message.chat.id, f"✅ *Снапшот сохранён:*\n`{name}`", parse_mode="Markdown")
        bot_log(f"💾 {message.chat.id} сохранил снапшот {name}")
    except Exception as e:
        bot.send_message(message.chat.id, f"❌ Ошибка: {e}")
        log_error("bot_backup", str(e))

@bot.message_handler(commands=['bot_backups'])
def bot_backups_cmd(message):
    """Список всех бэкапов бота."""
    if message.chat.id not in ADMINS: return
    files = sorted(os.listdir(BACKUPS_DIR)) if os.path.exists(BACKUPS_DIR) else []
    baks  = [f for f in files if f.endswith(".py.bak")]
    if not baks: bot.send_message(message.chat.id, "📭 Нет бэкапов."); return
    total_size = sum(os.path.getsize(os.path.join(BACKUPS_DIR, f)) for f in baks)
    text  = f"💾 *БЭКАПЫ БОТА* ({len(baks)} файлов, {total_size//1024} КБ)\n\n"
    for f in reversed(baks[-15:]):
        sz = os.path.getsize(os.path.join(BACKUPS_DIR, f)) // 1024
        text += f"`{f}` — {sz} КБ\n"
    text += f"\n/sys\\_rollback имя — восстановить"
    bot.send_message(message.chat.id, text, parse_mode="Markdown")

# ========== ЛИГИ ==========
LEAGUES = [
    {"name": "Бронзовая",   "emoji": "🥉", "min_cups": 0,    "max_cups": 299},
    {"name": "Серебряная",  "emoji": "🥈", "min_cups": 300,  "max_cups": 699},
    {"name": "Золотая",     "emoji": "🥇", "min_cups": 700,  "max_cups": 1199},
    {"name": "Алмазная",    "emoji": "💎", "min_cups": 1200, "max_cups": 1999},
    {"name": "Мифическая",  "emoji": "🌀", "min_cups": 2000, "max_cups": 2999},
    {"name": "Легендарная", "emoji": "🌟", "min_cups": 3000, "max_cups": 4499},
    {"name": "Мастерская",  "emoji": "👑", "min_cups": 4500, "max_cups": 5999},
    {"name": "Про",         "emoji": "🔱", "min_cups": 6000, "max_cups": 999999},
]
LEAGUE_CUPS_REWARD = {"win": 30, "loss": -15, "draw": 5}

def get_league(cups):
    for lg in LEAGUES:
        if lg["min_cups"] <= cups <= lg["max_cups"]: return lg
    return LEAGUES[0]

# ========== ЗАГРУЗКА/СОХРАНЕНИЕ ==========
def load_profiles():
    if os.path.exists(PROFILES_FILE):
        with open(PROFILES_FILE, "r", encoding="utf-8") as f: return json.load(f)
    return {}

def save_profiles(p):
    with open(PROFILES_FILE, "w", encoding="utf-8") as f: json.dump(p, f, indent=2, ensure_ascii=False)

def load_cards():
    if os.path.exists(CARDS_FILE):
        with open(CARDS_FILE, "r", encoding="utf-8") as f: return json.load(f)
    return {}

def save_cards(cards):
    with open(CARDS_FILE, "w", encoding="utf-8") as f: json.dump(cards, f, indent=2, ensure_ascii=False)

def load_blocked():
    if os.path.exists(BLOCKED_FILE):
        with open(BLOCKED_FILE, "r", encoding="utf-8") as f: return json.load(f)
    return []

def save_blocked(b):
    with open(BLOCKED_FILE, "w", encoding="utf-8") as f: json.dump(b, f, indent=2, ensure_ascii=False)

def load_league_photos():
    if os.path.exists(LEAGUES_FILE):
        with open(LEAGUES_FILE, "r", encoding="utf-8") as f: return json.load(f)
    return {}

def save_league_photos(data):
    with open(LEAGUES_FILE, "w", encoding="utf-8") as f: json.dump(data, f, indent=2, ensure_ascii=False)

def load_battles_log():
    if os.path.exists(BATTLES_LOG_FILE):
        with open(BATTLES_LOG_FILE, "r", encoding="utf-8") as f: return json.load(f)
    return []

def save_battles_log(lg):
    with open(BATTLES_LOG_FILE, "w", encoding="utf-8") as f: json.dump(lg, f, indent=2, ensure_ascii=False)

# ========== КАРТЫ ==========
DEFAULT_CARDS = {
    "card_001": {"name": "Рокси",     "element": "вода",   "rating": 80,  "media": None, "media_type": None},
    "card_002": {"name": "Куруми",    "element": "песок",  "rating": 80,  "media": None, "media_type": None},
    "card_003": {"name": "Канеки",    "element": "лёд",    "rating": 80,  "media": None, "media_type": None},
    "card_004": {"name": "Миса",      "element": "земля",  "rating": 80,  "media": None, "media_type": None},
    "card_005": {"name": "Ренгоку",   "element": "огонь",  "rating": 80,  "media": None, "media_type": None},
    "card_006": {"name": "Хината",    "element": "ветер",  "rating": 80,  "media": None, "media_type": None},
    "card_007": {"name": "Сакура",    "element": "дерево", "rating": 80,  "media": None, "media_type": None},
    "card_008": {"name": "Эш",        "element": "молния", "rating": 80,  "media": None, "media_type": None},
    "card_009": {"name": "Эрза",      "element": "металл", "rating": 80,  "media": None, "media_type": None},
    "card_010": {"name": "Гатс",      "element": "металл", "rating": 84,  "media": None, "media_type": None},
    "card_011": {"name": "Рукия",     "element": "лёд",    "rating": 84,  "media": None, "media_type": None},
    "card_012": {"name": "Бер",       "element": "дерево", "rating": 84,  "media": None, "media_type": None},
    "card_013": {"name": "Боруто",    "element": "молния", "rating": 84,  "media": None, "media_type": None},
    "card_014": {"name": "Симон",     "element": "песок",  "rating": 85,  "media": None, "media_type": None},
    "card_015": {"name": "Шигео",     "element": "ветер",  "rating": 85,  "media": None, "media_type": None},
    "card_016": {"name": "Хао",       "element": "огонь",  "rating": 85,  "media": None, "media_type": None},
    "card_017": {"name": "Сон",       "element": "вода",   "rating": 85,  "media": None, "media_type": None},
    "card_018": {"name": "Махорага",  "element": "дерево", "rating": 90,  "media": None, "media_type": None},
    "card_019": {"name": "Адам",      "element": "дерево", "rating": 90,  "media": None, "media_type": None},
    "card_020": {"name": "Наруто",    "element": "ветер",  "rating": 90,  "media": None, "media_type": None},
    "card_021": {"name": "Сид",       "element": "ветер",  "rating": 90,  "media": None, "media_type": None},
    "card_022": {"name": "Айзен",     "element": "песок",  "rating": 90,  "media": None, "media_type": None},
    "card_023": {"name": "Соломон",   "element": "песок",  "rating": 90,  "media": None, "media_type": None},
    "card_024": {"name": "Эсдес",     "element": "лёд",    "rating": 90,  "media": None, "media_type": None},
    "card_025": {"name": "Аинз",      "element": "молния", "rating": 90,  "media": None, "media_type": None},
    "card_026": {"name": "Мэш",       "element": "металл", "rating": 90,  "media": None, "media_type": None},
    "card_027": {"name": "Рудеус",    "element": "вода",   "rating": 90,  "media": None, "media_type": None},
    "card_028": {"name": "Кирито",    "element": "вода",   "rating": 90,  "media": None, "media_type": None},
    "card_029": {"name": "Макима",    "element": "огонь",  "rating": 90,  "media": None, "media_type": None},
    "card_030": {"name": "Ёричии",    "element": "огонь",  "rating": 90,  "media": None, "media_type": None},
    "card_031": {"name": "Мадара",    "element": "огонь",  "rating": 90,  "media": None, "media_type": None},
    "card_032": {"name": "Субару",    "element": "молния", "rating": 90,  "media": None, "media_type": None},
    "card_033": {"name": "Саске",     "element": "молния", "rating": 100, "media": None, "media_type": None},
    "card_034": {"name": "Лелуш",     "element": "песок",  "rating": 100, "media": None, "media_type": None},
    "card_035": {"name": "Артурия",   "element": "молния", "rating": 100, "media": None, "media_type": None},
    "card_036": {"name": "Шинра",     "element": "огонь",  "rating": 100, "media": None, "media_type": None},
    "card_037": {"name": "Тач",       "element": "металл", "rating": 100, "media": None, "media_type": None},
    "card_038": {"name": "Акнология", "element": "ветер",  "rating": 100, "media": None, "media_type": None},
    "card_039": {"name": "Дио",       "element": "молния", "rating": 100, "media": None, "media_type": None},
    "card_040": {"name": "Люциус",    "element": "песок",  "rating": 100, "media": None, "media_type": None},
    "card_041": {"name": "Яхве",      "element": "дерево", "rating": 100, "media": None, "media_type": None},
    "card_042": {"name": "Луффи",     "element": "ветер",  "rating": 100, "media": None, "media_type": None},
    "card_043": {"name": "Сукуна",    "element": "огонь",  "rating": 100, "media": None, "media_type": None},
    "card_044": {"name": "Римуру",    "element": "вода",   "rating": 100, "media": None, "media_type": None},
    "card_045": {"name": "Сайтама",   "element": "огонь",  "rating": 100, "media": None, "media_type": None},
    "card_046": {"name": "Ичиго",     "element": "ветер",  "rating": 101, "media": None, "media_type": None},
    "card_047": {"name": "Кагуя",     "element": "дерево", "rating": 101, "media": None, "media_type": None},
    "card_048": {"name": "Гильгамеш", "element": "песок",  "rating": 101, "media": None, "media_type": None},
    "card_049": {"name": "Нацу",      "element": "огонь",  "rating": 101, "media": None, "media_type": None},
    "card_050": {"name": "Джинву",    "element": "вода",   "rating": 101, "media": None, "media_type": None},
}

CARDS_DB = load_cards()
if not CARDS_DB:
    CARDS_DB = DEFAULT_CARDS
    save_cards(CARDS_DB)

FEARS = {
    "вода":   ["дерево","ветер"],
    "металл": ["вода","земля"],
    "огонь":  ["вода","песок"],
    "молния": ["песок","земля"],
    "песок":  ["ветер","лёд"],
    "ветер":  ["огонь","металл","молния"],
    "дерево": ["огонь"],
    "лёд":    ["молния"],
    "земля":  ["ветер"],
}

# ========== СОСТОЯНИЕ ==========
user_decks                = {}
duels                     = {}
battles                   = {}
admin_upload              = {}
profiles                  = load_profiles()
blocked_users             = load_blocked()
league_photos             = load_league_photos()
battles_log               = load_battles_log()
matchmaking_queue         = {}
duel_menu_state           = {}
collection_state          = {}
add_card_state            = {}
league_photo_upload_state = {}
# Watchdog: время последнего действия в дуэли
battle_last_action        = {}   # code -> float (timestamp)

CANCEL_BUTTONS = [
    "📚 Моя колода","⚔️ Дуэль","🃏 Собрать колоду","🤖 Авто-колода",
    "🔍 Все карты","👤 Профиль","🏆 Топ игроков",
    "1️⃣ Дуэль с игроком","2️⃣ Дуэль с ботом","🔍 Найти дуэль","➕ Создать дуэль",
    "🏅 Моя лига","🔙 Назад",
]

def is_blocked(uid): return uid in blocked_users and uid not in ADMINS

def bot_log(msg):
    for aid in ADMINS:
        try: bot.send_message(aid, f"📋 {msg}")
        except: pass

# ========== ПРОФИЛЬ ==========
def ensure_profile(uid):
    uid_str = str(uid)
    if uid_str not in profiles:
        profiles[uid_str] = {"wins": 0, "losses": 0, "draws": 0, "cups": 0}
        save_profiles(profiles)
    p = profiles[uid_str]
    for k in ("wins","losses","draws","cups"):
        p.setdefault(k, 0)
    return p

def add_cups(uid, delta):
    p = ensure_profile(uid)
    p["cups"] = max(0, p["cups"] + delta)
    save_profiles(profiles)

def get_profile_text(user_id, name=None):
    p     = ensure_profile(user_id)
    cups  = p.get("cups", 0); lg = get_league(cups)
    total = p["wins"] + p["losses"] + p["draws"]
    wr    = (p["wins"] / total * 100) if total > 0 else 0
    return (
        f"👤 *{name or str(user_id)}*\nID: `{user_id}`\n"
        f"{lg['emoji']} Лига: **{lg['name']}**\n🏆 Кубков: {cups}\n\n"
        f"✅ Побед: {p['wins']}\n❌ Поражений: {p['losses']}\n🤝 Ничьих: {p['draws']}\n"
        f"📊 Всего: {total}\n📈 Винрейт: {wr:.1f}%"
    )

def update_stats(winner_id, loser_id):
    ensure_profile(winner_id); ensure_profile(loser_id)
    profiles[str(winner_id)]["wins"]  += 1
    profiles[str(loser_id)]["losses"] += 1
    profiles[str(winner_id)]["cups"]   = max(0, profiles[str(winner_id)]["cups"] + LEAGUE_CUPS_REWARD["win"])
    profiles[str(loser_id)]["cups"]    = max(0, profiles[str(loser_id)]["cups"]  + LEAGUE_CUPS_REWARD["loss"])
    save_profiles(profiles)

def update_stats_draw(p1, p2):
    ensure_profile(p1); ensure_profile(p2)
    for uid in (p1, p2):
        profiles[str(uid)]["draws"] += 1
        profiles[str(uid)]["cups"]   = max(0, profiles[str(uid)]["cups"] + LEAGUE_CUPS_REWARD["draw"])
    save_profiles(profiles)

def reload_user(uid):
    for code in list(duels.keys()):
        if duels[code].get("p1") == uid or duels[code].get("p2") == uid: del duels[code]
    for code in list(battles.keys()):
        if battles[code].get("p1") == uid or battles[code].get("p2") == uid: del battles[code]
    for d in [user_decks, matchmaking_queue, collection_state, add_card_state]:
        if uid in d: del d[uid]
    try: send_main_menu(uid)
    except: pass
    bot_log(f"🔄 Перезагружен {uid}")

# ========== МЕНЮ ==========
def send_main_menu(chat_id):
    kb = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
    kb.row("📚 Моя колода", "⚔️ Дуэль")
    kb.row("🃏 Собрать колоду", "🤖 Авто-колода")
    kb.row("🔍 Все карты", "👤 Профиль", "🏆 Топ игроков")
    vi = load_version_info()
    bot.send_message(chat_id, f"🏆 Главное меню  |  v{vi['current']}", reply_markup=kb)

def send_duel_menu(chat_id):
    kb = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
    kb.row("1️⃣ Дуэль с игроком", "2️⃣ Дуэль с ботом")
    kb.row("🏅 Моя лига")
    kb.row("🔙 Назад")
    bot.send_message(chat_id,
        "⚔️ *Выбери режим дуэли:*\n\n1️⃣ — Найти/создать дуэль с игроком\n2️⃣ — Сразиться с ботом\n🏅 — Моя лига и прогресс",
        parse_mode="Markdown", reply_markup=kb)
    duel_menu_state[chat_id] = "duel_main"

def send_pvp_menu(chat_id):
    kb = telebot.types.ReplyKeyboardMarkup(resize_keyboard=True)
    kb.row("🔍 Найти дуэль", "➕ Создать дуэль")
    kb.row("🔙 Назад")
    bot.send_message(chat_id,
        "⚔️ *Дуэль с игроком:*\n\n🔍 Авто-поиск соперника\n➕ Получить код/ссылку для друга",
        parse_mode="Markdown", reply_markup=kb)
    duel_menu_state[chat_id] = "duel_pvp"

def send_league_info(uid):
    p    = ensure_profile(uid); cups = p.get("cups", 0)
    lg   = get_league(cups); lg_index = LEAGUES.index(lg)
    span = lg["max_cups"] - lg["min_cups"] + 1; progress = cups - lg["min_cups"]
    filled = min(10, int(progress / span * 10))
    bar  = "🟩" * filled + "⬜" * (10 - filled)
    text = f"🏅 *МОЯ ЛИГА*\n\n{lg['emoji']} *{lg['name']} Лига*\n🏆 Кубков: *{cups}*\nПрогресс: {bar}\n({progress}/{span})\n\n"
    if lg_index + 1 < len(LEAGUES):
        nl   = LEAGUES[lg_index + 1]
        text += f"⬆️ *Следующая:* {nl['emoji']} {nl['name']} Лига\nНужно ещё: *{nl['min_cups'] - cups}* 🏆\n\n"
    else:
        text += "🔱 *Ты в высшей лиге!*\n\n"
    text += "📋 *Все лиги:*\n"
    for l in LEAGUES:
        text += f"{'👉 ' if l['name'] == lg['name'] else '    '}{l['emoji']} {l['name']}: {l['min_cups']}–{l['max_cups']} 🏆\n"
    photo = league_photos.get(lg["name"])
    if photo:
        try: bot.send_photo(uid, photo, caption=text, parse_mode="Markdown"); return
        except: pass
    bot.send_message(uid, text, parse_mode="Markdown")

# ========== КАРТЫ ==========
def send_card_media(chat_id, card_id, caption):
    card = CARDS_DB.get(card_id)
    if not card or not card.get("media"): bot.send_message(chat_id, caption); return
    try:
        if card.get("media_type") == "video": bot.send_video(chat_id, card["media"], caption=caption)
        else: bot.send_photo(chat_id, card["media"], caption=caption)
    except: bot.send_message(chat_id, caption)

def get_deck_text(deck):
    n = SETTINGS.get("duel_cards", 6)
    lines = []
    for i, cid in enumerate(deck[:n], 1):
        c = CARDS_DB.get(cid)
        if c:
            lines.append(f"/{i} {c['name']} | {c['element']} | ⭐{c['rating']}")
    return "\n".join(lines)

def calculate_winner(cid1, cid2):
    c1, c2 = CARDS_DB[cid1], CARDS_DB[cid2]
    p1, p2 = c1["rating"], c2["rating"]
    if c2["element"] in FEARS.get(c1["element"], []): p1 -= 10
    if c1["element"] in FEARS.get(c2["element"], []): p2 -= 10
    return "p1" if p1 > p2 else ("p2" if p2 > p1 else "draw")

# ========== COLLECTION ==========
def get_collection_steps():
    n = SETTINGS.get("duel_cards", 6)
    if n <= 3:
        return [
            {"ratings": [100, 101], "count": 1, "label": "⭐100–101 (1 карта)"},
            {"ratings": [90],       "count": 1, "label": "⭐90 (1 карта)"},
            {"ratings": [80, 84, 85], "count": 1, "label": "⭐80–85 (1 карта)"},
        ]
    elif n <= 5:
        return [
            {"ratings": [100, 101], "count": 1, "label": "⭐100–101 (1 карта)"},
            {"ratings": [90],       "count": 2, "label": "⭐90 (2 карты)"},
            {"ratings": [84, 85],   "count": 1, "label": "⭐84–85 (1 карта)"},
            {"ratings": [80],       "count": 1, "label": "⭐80 (1 карта)"},
        ]
    elif n == 6:
        return [
            {"ratings": [100, 101], "count": 1, "label": "⭐100–101 (1 карта)"},
            {"ratings": [90],       "count": 2, "label": "⭐90 (2 карты)"},
            {"ratings": [84, 85],   "count": 1, "label": "⭐84–85 (1 карта)"},
            {"ratings": [80],       "count": 2, "label": "⭐80 (2 карты)"},
        ]
    else:
        return [
            {"ratings": [100, 101], "count": 2, "label": "⭐100–101 (2 карты)"},
            {"ratings": [90],       "count": 2, "label": "⭐90 (2 карты)"},
            {"ratings": [84, 85],   "count": 2, "label": "⭐84–85 (2 карты)"},
            {"ratings": [80],       "count": 2, "label": "⭐80 (2 карты)"},
        ]

def get_cards_for_step(steps, step_index):
    ratings = steps[step_index]["ratings"]
    return sorted([(cid, c) for cid, c in CARDS_DB.items() if c["rating"] in ratings], key=lambda x: x[0])

def build_step_text(steps, step_index, numbered, picks_left):
    step = steps[step_index]
    text = f"🃏 *ШАГ {step_index+1}/{len(steps)} — {step['label']}*\nНужно ещё: *{picks_left}*\n\n"
    for i, (cid, c) in enumerate(numbered, 1):
        text += f"`{i:02d}` — {c['name']} | {c['element']} | ⭐{c['rating']} {'🖼' if c['media'] else ''}\n"
    return text + "\nВведи номер:"

def start_collection(uid):
    steps    = get_collection_steps()
    numbered = get_cards_for_step(steps, 0)
    collection_state[uid] = {"deck": [], "step": 0, "picks_done": 0, "numbered": numbered, "steps": steps}
    bot.send_message(uid, build_step_text(steps, 0, numbered, steps[0]["count"]), parse_mode="Markdown")

def handle_collection_input(message):
    uid   = message.chat.id
    state = collection_state.get(uid)
    if not state: return False
    text = message.text.strip()
    if text in CANCEL_BUTTONS or text.startswith("/"): del collection_state[uid]; return False
    if not text.isdigit(): bot.send_message(uid, "❌ Введи число."); return True
    steps    = state["steps"]
    numbered = state["numbered"]
    choice   = int(text)
    if choice < 1 or choice > len(numbered): bot.send_message(uid, f"❌ От 1 до {len(numbered)}"); return True
    chosen_id = numbered[choice-1][0]
    if chosen_id in state["deck"]: bot.send_message(uid, "❌ Карта уже выбрана!"); return True
    state["deck"].append(chosen_id); state["picks_done"] += 1
    c = CARDS_DB[chosen_id]
    bot.send_message(uid, f"✅ *{c['name']}* | {c['element']} | ⭐{c['rating']}", parse_mode="Markdown")
    step_index = state["step"]; needed = steps[step_index]["count"]
    if state["picks_done"] < needed:
        bot.send_message(uid, build_step_text(steps, step_index, numbered, needed - state["picks_done"]), parse_mode="Markdown")
        collection_state[uid] = state
    else:
        nxt = step_index + 1
        if nxt >= len(steps):
            finished = state["deck"][:]; del collection_state[uid]; user_decks[uid] = finished
            bot.send_message(uid, f"🎉 *Колода собрана!*\n\n{get_deck_text(finished)}", parse_mode="Markdown")
            bot_log(f"👤 {uid} собрал колоду"); return False
        else:
            state["step"] = nxt; state["picks_done"] = 0
            nn = get_cards_for_step(steps, nxt); state["numbered"] = nn
            bot.send_message(uid, build_step_text(steps, nxt, nn, steps[nxt]["count"]), parse_mode="Markdown")
            collection_state[uid] = state
    return True

def build_bot_deck():
    steps = get_collection_steps()
    deck  = []
    for step in steps:
        pool = [cid for cid, c in CARDS_DB.items() if c["rating"] in step["ratings"] and cid not in deck]
        if len(pool) < step["count"]:
            pool = [cid for cid in CARDS_DB if cid not in deck]
        if pool:
            deck.extend(random.sample(pool, min(step["count"], len(pool))))
    return deck

# ========== СЛОЖНОСТЬ БОТА ==========
def bot_pick_card_by_difficulty(deck, player_card_id=None):
    diff = SETTINGS.get("bot_difficulty", "medium")
    if not deck: return None
    if diff == "weak":
        srt  = sorted(deck, key=lambda cid: CARDS_DB[cid]["rating"])
        pool = srt[:max(1, len(srt)//2)]
        return random.choice(pool)
    elif diff == "strong" and player_card_id and player_card_id in CARDS_DB:
        pc = CARDS_DB[player_card_id]
        best = None; best_score = -999
        for cid in deck:
            bc    = CARDS_DB[cid]
            score = bc["rating"]
            if pc["element"] in FEARS.get(bc["element"], []): score -= 10
            if bc["element"] in FEARS.get(pc["element"], []): score += 10
            if score > best_score: best_score = score; best = cid
        return best if best else random.choice(deck)
    else:
        return random.choice(deck)

# ========= WATCHDOG — антифриз дуэлей =========
def _touch(code):
    """Обновить timestamp последнего действия в дуэли."""
    battle_last_action[code] = time.time()

def watchdog_loop():
    while True:
        try:
            now = time.time()
            for code in list(battles.keys()):
                b = battles.get(code)
                if not b: continue

                is_bot_b      = b.get("is_bot", False)
                waiting_p1    = b.get("waiting_p1", False)
                waiting_p2    = b.get("waiting_p2", False)
                bot_timeout   = SETTINGS.get("bot_timeout", 60)
                player_timeout = SETTINGS.get("player_timeout", 120)

                last = battle_last_action.get(code)
                if last is None:
                    battle_last_action[code] = now; continue

                elapsed = now - last

                # ── Заморозка хода БОТА ──
                if is_bot_b and waiting_p2 and elapsed > bot_timeout:
                    log_error("watchdog.bot_freeze", f"Bot stuck in {code}", f"elapsed={elapsed:.0f}s phase={b.get('phase')}")
                    # Принудительно выбираем карту за бота
                    deck = b.get("p2_deck", [])
                    if deck:
                        card_id = bot_pick_card_by_difficulty(deck)
                        if card_id:
                            try:
                                deck.remove(card_id)
                                b["p2_card"]    = card_id
                                b["waiting_p2"] = False
                                battles[code]   = b
                                _touch(code)
                                uid = b["p1"]
                                wc  = CARDS_DB.get(card_id, {})
                                bot.send_message(uid, f"⏱ Бот думал слишком долго — ход сделан автоматически!\n🤖 Карта: {wc.get('name','?')}")
                                phase = b.get("phase")
                                if phase == "blind":
                                    if b.get("p1_card"): resolve_round(code)
                                elif phase == "winner_picks":
                                    b["phase"]      = "loser_picks"
                                    b["waiting_p1"] = True
                                    b["waiting_p2"] = False
                                    battles[code]   = b
                                    _touch(code)
                                    n = SETTINGS.get("duel_cards", 6)
                                    bot.send_message(uid,
                                        f"🤖 Бот выбрал: {wc.get('name','?')} | {wc.get('element','?')} | ⭐{wc.get('rating','?')}\n\n"
                                        f"Твой ход! /1–/{min(n, len(b['p1_deck']))}:\n\n{get_deck_text(b['p1_deck'])}")
                                elif phase == "loser_picks":
                                    resolve_round(code)
                            except Exception as e:
                                log_error("watchdog.bot_autoplay", str(e), code)
                    else:
                        # У бота нет карт — завершаем дуэль
                        try:
                            b["waiting_p2"] = False; battles[code] = b
                            end_battle(code)
                        except Exception as e:
                            log_error("watchdog.bot_nocard", str(e), code)
                            if code in battles: del battles[code]
                            if code in duels:   del duels[code]
                        if code in battle_last_action: del battle_last_action[code]

                # ── Заморозка хода ИГРОКА ──
                elif (waiting_p1 or (waiting_p2 and not is_bot_b)) and elapsed > player_timeout:
                    log_error("watchdog.player_freeze", f"Player stuck in {code}", f"elapsed={elapsed:.0f}s")
                    for pid_key in ["p1", "p2"]:
                        pid = b.get(pid_key)
                        if pid and pid != "BOT":
                            try: bot.send_message(pid,
                                f"⏰ Дуэль `{code}` отменена: превышено время ожидания хода ({int(elapsed)}с).\n"
                                f"Счёт был: {b.get('score1',0)}:{b.get('score2',0)}", parse_mode="Markdown")
                            except: pass
                    for aid in ADMINS:
                        try: bot.send_message(aid,
                            f"⏰ *Дуэль `{code}` завершена принудительно*\n"
                            f"Причина: игрок не ходил {int(elapsed)}с\n"
                            f"Счёт: {b.get('score1',0)}:{b.get('score2',0)}", parse_mode="Markdown")
                        except: pass
                    try:
                        end_battle(code)
                    except Exception as e:
                        log_error("watchdog.end_battle", str(e), code)
                        if code in battles: del battles[code]
                        if code in duels:   del duels[code]
                    if code in battle_last_action: del battle_last_action[code]

        except Exception as e:
            log_error("watchdog_loop", str(e))
        time.sleep(10)

threading.Thread(target=watchdog_loop, daemon=True).start()

# ========== КОМАНДЫ ==========
@bot.message_handler(commands=['start'])
def start_command(message):
    uid = message.chat.id
    if is_blocked(uid): bot.send_message(uid, "🚫 Вы заблокированы."); return
    parts = message.text.split()
    if len(parts) > 1 and parts[1].startswith("join_"):
        message.text = f"/join {parts[1].replace('join_','')}"
        join_command(message); return
    ensure_profile(uid); send_main_menu(uid)

@bot.message_handler(commands=['build_deck','collection'])
def build_deck_command(message):
    if is_blocked(message.chat.id): bot.send_message(message.chat.id, "🚫 Вы заблокированы."); return
    start_collection(message.chat.id)

@bot.message_handler(commands=['auto_build','Auto_build'])
def auto_build_command(message):
    uid = message.chat.id; deck = []
    steps = get_collection_steps()
    for step in steps:
        pool = [cid for cid, c in CARDS_DB.items() if c["rating"] in step["ratings"] and cid not in deck]
        if len(pool) < step["count"]: bot.send_message(uid, f"❌ Недостаточно карт ⭐{step['ratings']}!"); return
        deck.extend(random.sample(pool, step["count"]))
    user_decks[uid] = deck
    bot.send_message(uid, f"🤖 *Авто-колода собрана!*\n\n{get_deck_text(deck)}", parse_mode="Markdown")

@bot.message_handler(commands=['my_deck'])
def my_deck_command(message):
    deck = user_decks.get(message.chat.id)
    if not deck: bot.send_message(message.chat.id, "❌ Нет колоды. /build_deck"); return
    bot.send_message(message.chat.id, "📚 *МОЯ КОЛОДА*\n\n" + get_deck_text(deck), parse_mode="Markdown")

@bot.message_handler(commands=['profile'])
def profile_command(message):
    uid = message.chat.id; p = ensure_profile(uid); lg = get_league(p.get("cups", 0))
    text = get_profile_text(uid, message.from_user.first_name)
    lp = league_photos.get(lg["name"])
    if lp:
        try: bot.send_photo(uid, lp, caption=text, parse_mode="Markdown"); return
        except: pass
    bot.send_message(uid, text, parse_mode="Markdown")

@bot.message_handler(commands=['info'])
def info_command(message):
    parts = message.text.split()
    if len(parts) != 2: bot.send_message(message.chat.id, "❌ /info USER_ID"); return
    try:
        uid = int(parts[1]); name = None
        try: name = bot.get_chat(uid).first_name
        except: pass
        text = get_profile_text(uid, name); p = ensure_profile(uid); lg = get_league(p.get("cups", 0))
        lp = league_photos.get(lg["name"])
        if lp:
            try: bot.send_photo(message.chat.id, lp, caption=text, parse_mode="Markdown"); return
            except: pass
        bot.send_message(message.chat.id, text, parse_mode="Markdown")
    except: bot.send_message(message.chat.id, "❌ Неверный ID")

@bot.message_handler(commands=['top'])
def top_command(message):
    if not profiles: bot.send_message(message.chat.id, "📊 Нет статистики"); return
    srt  = sorted(profiles.items(), key=lambda x: x[1].get("cups",0), reverse=True)[:10]
    text = "🏆 *ТОП-10 ПО КУБКАМ*\n\n"
    for i, (uid, data) in enumerate(srt, 1):
        name = uid
        try: name = bot.get_chat(int(uid)).first_name
        except: pass
        cups = data.get("cups",0); lg = get_league(cups)
        text += f"{i}. {lg['emoji']} {name} — {cups} 🏆\n"
    bot.send_message(message.chat.id, text, parse_mode="Markdown")

@bot.message_handler(commands=['all_cards'])
def all_cards_command(message):
    text = "📋 *ВСЕ КАРТЫ*\n\n"
    for cid, c in CARDS_DB.items():
        text += f"`{cid}` - {c['name']} | {c['element']} | ⭐{c['rating']} | {'✅' if c['media'] else '❌'}\n"
    bot.send_message(message.chat.id, text, parse_mode="Markdown")

@bot.message_handler(commands=['look'])
def look_cmd(message):
    if not battles_log: bot.send_message(message.chat.id, "📭 Архив боёв пуст."); return
    last = list(reversed(battles_log[-5:]))
    text = "🗂 *ПОСЛЕДНИЕ БОИ*\n\n"
    for i, e in enumerate(last, 1):
        bm   = " 🤖" if e.get("is_bot") else ""
        text += f"*{i}.* {e['p1_name']} ⚔️ {e['p2_name']}{bm}\n📅 {e['date']}\n🏆 {e['score_p1']}:{e['score_p2']}\n🎯 {e['result']}\n🔑 `{e['code']}`\n\n"
    bot.send_message(message.chat.id, text, parse_mode="Markdown")

# ========== ДУЭЛЬ ==========
@bot.message_handler(commands=['duel'])
def duel_command(message):
    if is_blocked(message.chat.id): bot.send_message(message.chat.id, "🚫 Вы заблокированы."); return
    if message.chat.id not in user_decks: bot.send_message(message.chat.id, "❌ Сначала /build_deck"); return
    send_duel_menu(message.chat.id)

def create_duel(uid):
    for b in battles.values():
        if b.get("p1") == uid or b.get("p2") == uid: bot.send_message(uid, "❌ Уже в дуэли"); return
    if uid in matchmaking_queue: del matchmaking_queue[uid]
    code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    duels[code] = {"p1": uid, "p1_deck": user_decks[uid].copy(), "status": "waiting"}
    try: me = bot.get_me(); link = f"https://t.me/{me.username}?start=join_{code}"
    except: link = f"/join {code}"
    bot.send_message(uid, f"⚔️ *Дуэль создана!*\nКод: `{code}`\n\nСсылка:\n{link}\n\nИли: /join {code}", parse_mode="Markdown")
    bot_log(f"⚔️ {uid} создал дуэль {code}")

def search_duel(uid):
    for b in battles.values():
        if b.get("p1") == uid or b.get("p2") == uid: bot.send_message(uid, "❌ Уже в дуэли"); return
    if uid in matchmaking_queue: bot.send_message(uid, "⏳ Уже в очереди. /cancel_search для отмены."); return
    for wuid in list(matchmaking_queue.keys()):
        if wuid == uid: continue
        if wuid not in user_decks: del matchmaking_queue[wuid]; continue
        p1 = wuid; p2 = uid; del matchmaking_queue[p1]
        code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
        battles[code] = _make_pvp_battle(code, p1, p2)
        duels[code]   = {"p1": p1, "p2": p2, "status": "active"}
        bot.send_message(p1, "⚔️ Соперник найден! Бой начинается!")
        bot.send_message(p2, "⚔️ Соперник найден! Бой начинается!")
        bot_log(f"🔍 Матч: {p1} vs {p2}, {code}"); play_round(code); return
    matchmaking_queue[uid] = user_decks[uid].copy()
    bot.send_message(uid, "🔍 Ищем соперника...\n\n/cancel_search — отменить поиск.")

def _make_pvp_battle(code, p1, p2):
    return {
        "code": code, "p1": p1, "p2": p2,
        "p1_deck": user_decks[p1].copy(), "p2_deck": user_decks[p2].copy(),
        "round": 1, "score1": 0, "score2": 0,
        "p1_card": None, "p2_card": None,
        "last_winner": None, "phase": "blind",
        "waiting_p1": False, "waiting_p2": False, "is_bot": False,
    }

@bot.message_handler(commands=['cancel_search'])
def cancel_search(message):
    uid = message.chat.id
    if uid in matchmaking_queue: del matchmaking_queue[uid]; bot.send_message(uid, "❌ Поиск отменён.")
    else: bot.send_message(uid, "Ты не в очереди.")

@bot.message_handler(commands=['join'])
def join_command(message):
    if is_blocked(message.chat.id): bot.send_message(message.chat.id, "🚫 Вы заблокированы."); return
    parts = message.text.split()
    if len(parts) != 2: bot.send_message(message.chat.id, "❌ /join КОД"); return
    code = parts[1].replace("join_",""); duel = duels.get(code)
    if not duel or duel["status"] != "waiting": bot.send_message(message.chat.id, "❌ Код недействителен"); return
    if message.chat.id not in user_decks: bot.send_message(message.chat.id, "❌ Сначала /build_deck"); return
    for b in battles.values():
        if b.get("p1") == message.chat.id or b.get("p2") == message.chat.id:
            bot.send_message(message.chat.id, "❌ Уже в дуэли"); return
    duel.update({"p2": message.chat.id, "p2_deck": user_decks[message.chat.id].copy(), "status": "active"})
    battles[code] = _make_pvp_battle(code, duel["p1"], duel["p2"])
    bot.send_message(duel["p1"], "⚔️ Соперник найден! Начинаем!")
    bot.send_message(duel["p2"], f"⚔️ Вступили в дуэль {code}")
    bot_log(f"⚔️ {code}: {duel['p1']} vs {duel['p2']}"); play_round(code)

def start_bot_battle(uid):
    if uid not in user_decks: bot.send_message(uid, "❌ Сначала /build_deck"); return
    for b in battles.values():
        if b.get("p1") == uid or b.get("p2") == uid: bot.send_message(uid, "❌ Уже в дуэли"); return
    code  = "BOT_" + ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))
    diff  = SETTINGS.get("bot_difficulty", "medium")
    rounds = SETTINGS.get("duel_rounds", 5)
    cards  = SETTINGS.get("duel_cards", 6)
    diff_labels = {"weak": "🟢 Слабый", "medium": "🟡 Средний", "strong": "🔴 Сильный"}
    battles[code] = {
        "code": code, "p1": uid, "p2": "BOT",
        "p1_deck": user_decks[uid].copy(), "p2_deck": build_bot_deck(),
        "round": 1, "score1": 0, "score2": 0,
        "p1_card": None, "p2_card": None,
        "last_winner": None, "phase": "blind",
        "waiting_p1": False, "waiting_p2": False, "is_bot": True,
        "total_rounds": rounds,
    }
    _touch(code)
    p = ensure_profile(uid); lg = get_league(p.get("cups",0))
    bot.send_message(uid,
        f"🤖 *Дуэль с ботом!*\n{lg['emoji']} Лига: *{lg['name']}*\n"
        f"🎯 Сложность: {diff_labels.get(diff, diff)}\n"
        f"🃏 Карт: {cards}  |  🔢 Раундов: {rounds}",
        parse_mode="Markdown")
    bot_log(f"🤖 {uid} vs бот [{diff}], {rounds}р, {code}")
    play_round(code)

# ─────────────────────────────────────────────────────────────
#  БОТ ВЫБИРАЕТ КАРТУ — переработано, без состояния-снапшота
# ─────────────────────────────────────────────────────────────
def schedule_bot_move(code, expected_phase, player_card_id=None):
    """
    Запускает таймер хода бота. Проверяет актуальное состояние
    из battles[code] каждый раз — не из снапшота.
    """
    delay = {"weak": 1.8, "medium": 1.2, "strong": 0.6}.get(
        SETTINGS.get("bot_difficulty", "medium"), 1.2)

    def _do():
        time.sleep(delay)
        # === Читаем АКТУАЛЬНОЕ состояние ===
        b = battles.get(code)
        if not b or not b.get("is_bot"):
            return  # дуэль уже завершена
        if not b.get("waiting_p2"):
            return  # бот уже не ждёт хода (например, watchdog уже сыграл)
        if b.get("phase") != expected_phase:
            return  # фаза изменилась — не наш ход

        deck = b.get("p2_deck", [])
        if not deck:
            # У бота нет карт — завершаем дуэль
            try: end_battle(code)
            except Exception as e: log_error("bot_move.no_cards", str(e), code)
            return

        card_id = bot_pick_card_by_difficulty(deck, player_card_id)
        if not card_id:
            return

        # === Применяем ход бота ===
        try:
            deck.remove(card_id)
        except ValueError:
            log_error("bot_move.remove", f"card {card_id} not in deck", code)
            return

        b["p2_card"]    = card_id
        b["waiting_p2"] = False
        battles[code]   = b
        _touch(code)

        phase = b.get("phase")
        uid   = b["p1"]
        wc    = CARDS_DB.get(card_id, {})
        n     = SETTINGS.get("duel_cards", 6)

        try:
            if phase == "blind":
                if b.get("p1_card"):
                    resolve_round(code)
                # else: ждём карту игрока — watchdog подстрахует

            elif phase == "winner_picks":
                # Бот — победитель прошлого раунда, выбрал карту первым
                # Теперь показываем её игроку (проигравшему) и просим его ход
                b["phase"]      = "loser_picks"
                b["waiting_p1"] = True
                b["waiting_p2"] = False
                battles[code]   = b
                _touch(code)
                bot.send_message(uid,
                    f"🤖 Бот выбрал: *{wc.get('name','?')}* | {wc.get('element','?')} | ⭐{wc.get('rating','?')}\n\n"
                    f"Твой ход! /1–/{min(n, len(b['p1_deck']))}:\n\n{get_deck_text(b['p1_deck'])}",
                    parse_mode="Markdown")

            elif phase == "loser_picks":
                # Бот — проигравший, ходит вторым — сразу разрешаем раунд
                resolve_round(code)

        except Exception as e:
            log_error("bot_move.dispatch", str(e), code)

    threading.Thread(target=_do, daemon=True).start()

# ========== БОЙ ==========
def play_round(code):
    b = battles.get(code)
    if not b:
        log_error("play_round", "battle not found", code); return

    total_rounds = b.get("total_rounds", SETTINGS.get("duel_rounds", 5))
    r    = b["round"]
    n    = SETTINGS.get("duel_cards", 6)

    # Завершаем если исчерпаны раунды или карты
    if r > total_rounds or not b["p1_deck"] or (b.get("is_bot") and not b["p2_deck"]):
        end_battle(code); return

    # Сбрасываем карты раунда
    b["p1_card"]    = None
    b["p2_card"]    = None
    b["waiting_p1"] = False
    b["waiting_p2"] = False
    is_bot = b.get("is_bot", False)

    if b["last_winner"] is None:
        # ── Вслепую ──
        b["phase"]      = "blind"
        b["waiting_p1"] = True
        b["waiting_p2"] = True
        battles[code]   = b
        _touch(code)

        deck_n = min(n, len(b["p1_deck"]))
        bot.send_message(b["p1"],
            f"🔮 РАУНД {r}/{total_rounds} | Вслепую!\nВыбери /1–/{deck_n}:\n\n{get_deck_text(b['p1_deck'])}")
        if is_bot:
            schedule_bot_move(code, "blind")
        else:
            deck_n2 = min(n, len(b["p2_deck"]))
            bot.send_message(b["p2"],
                f"🔮 РАУНД {r}/{total_rounds} | Вслепую!\nВыбери /1–/{deck_n2}:\n\n{get_deck_text(b['p2_deck'])}")

    else:
        # ── Победитель ходит первым ──
        winner = b["last_winner"]
        loser  = "p2" if winner == "p1" else "p1"
        b["phase"]          = "winner_picks"
        b[f"waiting_{winner}"] = True
        b[f"waiting_{loser}"]  = False
        battles[code] = b
        _touch(code)

        if winner == "p1":
            # Человек — победитель
            dn = min(n, len(b["p1_deck"]))
            bot.send_message(b["p1"],
                f"⚔️ РАУНД {r}/{total_rounds} | Ты ходишь первым!\nВыбери /1–/{dn}:\n\n{get_deck_text(b['p1_deck'])}")
            if not is_bot:
                bot.send_message(b["p2"], f"⏳ РАУНД {r}/{total_rounds} | Соперник выбирает...")
        else:
            # Бот — победитель, ходит первым
            if is_bot:
                schedule_bot_move(code, "winner_picks")
            else:
                dn = min(n, len(b["p2_deck"]))
                bot.send_message(b["p2"],
                    f"⚔️ РАУНД {r}/{total_rounds} | Твой ход первым!\nВыбери /1–/{dn}:\n\n{get_deck_text(b['p2_deck'])}")
                bot.send_message(b["p1"], f"⏳ РАУНД {r}/{total_rounds} | Соперник выбирает...")

def after_winner_pick(code, winner, card_id):
    """Человек-победитель сыграл карту — теперь проигравший ходит."""
    b = battles.get(code)
    if not b: return
    loser   = "p2" if winner == "p1" else "p1"
    is_bot  = b.get("is_bot", False)
    wc      = CARDS_DB.get(card_id, {})
    n       = SETTINGS.get("duel_cards", 6)

    b["phase"]          = "loser_picks"
    b[f"waiting_{winner}"] = False
    b[f"waiting_{loser}"]  = True
    battles[code] = b
    _touch(code)

    if loser == "p1":
        # Проигравший — человек
        send_card_media(b["p1"], card_id,
            f"👁 Противник выбрал: {wc.get('name','?')} | {wc.get('element','?')} | ⭐{wc.get('rating','?')}\n"
            f"Твой ход /1–/{min(n, len(b['p1_deck']))}:")
        bot.send_message(b["p1"], get_deck_text(b["p1_deck"]))
    elif not is_bot:
        # PvP — показываем карту победителя проигравшему
        send_card_media(b["p2"], card_id,
            f"👁 Противник выбрал: {wc.get('name','?')} | {wc.get('element','?')} | ⭐{wc.get('rating','?')}\n"
            f"Твой ход /1–/{min(n, len(b['p2_deck']))}:")
        bot.send_message(b["p2"], get_deck_text(b["p2_deck"]))

    if is_bot and loser == "p2":
        schedule_bot_move(code, "loser_picks", card_id)

@bot.message_handler(commands=['1','2','3','4','5','6','7','8'])
def select_card(message):
    idx = int(message.text[1:]) - 1
    uid = message.chat.id

    # Найти дуэль игрока
    battle = None; code = None
    for c, b in battles.items():
        if (b["p1"] == uid and b.get("waiting_p1")) or \
           (b.get("p2") == uid and b.get("waiting_p2") and not b.get("is_bot")):
            battle = b; code = c; break

    if not battle:
        bot.send_message(uid, "❌ Сейчас не твой ход")
        return

    player = "p1" if battle["p1"] == uid else "p2"
    deck   = battle[f"{player}_deck"]
    n      = SETTINGS.get("duel_cards", 6)
    max_idx = min(n, len(deck))

    if idx < 0 or idx >= max_idx:
        bot.send_message(uid, f"❌ От 1 до {max_idx}")
        return

    card_id = deck.pop(idx)
    battle[f"{player}_card"]    = card_id
    battle[f"waiting_{player}"] = False
    battles[code] = battle
    _touch(code)

    send_card_media(uid, card_id, f"🎴 Ты выбрал: {CARDS_DB[card_id]['name']}")

    phase = battle.get("phase")
    if phase == "blind":
        if battle["p1_card"] and battle["p2_card"]:
            resolve_round(code)
        elif battle.get("is_bot") and not battle.get("p2_card"):
            schedule_bot_move(code, "blind")
        else:
            bot.send_message(uid, "⏳ Ждём соперника…")
    elif phase == "winner_picks":
        after_winner_pick(code, player, card_id)
    elif phase == "loser_picks":
        resolve_round(code)

def resolve_round(code):
    b = battles.get(code)
    if not b: return
    # Защита от двойного вызова
    if not b.get("p1_card") or not b.get("p2_card"):
        log_error("resolve_round", "missing cards", f"{code} p1={b.get('p1_card')} p2={b.get('p2_card')}")
        return

    r           = b["round"]
    is_bot      = b.get("is_bot", False)
    total_rounds = b.get("total_rounds", SETTINGS.get("duel_rounds", 5))
    res = calculate_winner(b["p1_card"], b["p2_card"])

    # Показываем карты
    for pid, mc, oc in [(b["p1"], b["p1_card"], b["p2_card"])] + ([] if is_bot else [(b["p2"], b["p2_card"], b["p1_card"])]):
        send_card_media(pid, mc, f"🎴 Твоя: {CARDS_DB[mc]['name']}")
        send_card_media(pid, oc, f"🎴 Соперник: {CARDS_DB[oc]['name']}")

    if is_bot:
        uid = b["p1"]
        if res == "p1":
            bot.send_message(uid, f"✅ РАУНД {r} — ПОБЕДА!"); b["score1"] += 1; b["last_winner"] = "p1"
        elif res == "p2":
            bot.send_message(uid, f"❌ РАУНД {r} — ПОРАЖЕНИЕ!"); b["score2"] += 1; b["last_winner"] = "p2"
        else:
            bot.send_message(uid, f"🤝 РАУНД {r} — НИЧЬЯ!"); b["last_winner"] = None
    else:
        if res == "p1":
            bot.send_message(b["p1"], f"✅ РАУНД {r} — ПОБЕДА!")
            bot.send_message(b["p2"], f"❌ РАУНД {r} — ПОРАЖЕНИЕ!")
            b["score1"] += 1; b["last_winner"] = "p1"
        elif res == "p2":
            bot.send_message(b["p1"], f"❌ РАУНД {r} — ПОРАЖЕНИЕ!")
            bot.send_message(b["p2"], f"✅ РАУНД {r} — ПОБЕДА!")
            b["score2"] += 1; b["last_winner"] = "p2"
        else:
            bot.send_message(b["p1"], f"🤝 РАУНД {r} — НИЧЬЯ!")
            bot.send_message(b["p2"], f"🤝 РАУНД {r} — НИЧЬЯ!")
            b["last_winner"] = None

    b["round"] += 1
    battles[code] = b
    _touch(code)

    if b["round"] <= total_rounds and b["p1_deck"] and (is_bot and b["p2_deck"] or not is_bot and b["p2_deck"]):
        play_round(code)
    else:
        end_battle(code)

def end_battle(code):
    b = battles.get(code)
    if not b: return
    # Помечаем как завершённую немедленно чтобы предотвратить двойной вызов
    battles.pop(code, None)
    if code in duels: del duels[code]
    if code in battle_last_action: del battle_last_action[code]

    is_bot = b.get("is_bot", False)
    uid    = b["p1"]

    def cups_line(pid, delta):
        p  = ensure_profile(pid)
        cups = p.get("cups", 0)
        lg = get_league(cups)
        return f"{'+'if delta>=0 else''}{delta} 🏆\nВсего: {cups} 🏆\n{lg['emoji']} **{lg['name']}**"

    s1, s2 = b["score1"], b["score2"]

    try:
        if s1 > s2:
            if is_bot:
                add_cups(uid, LEAGUE_CUPS_REWARD["win"]); profiles[str(uid)]["wins"] += 1; save_profiles(profiles)
                bot.send_message(uid, f"🏆 ПОБЕДА! {s1}:{s2}\n\n{cups_line(uid, LEAGUE_CUPS_REWARD['win'])}", parse_mode="Markdown")
            else:
                update_stats(b["p1"], b["p2"])
                bot.send_message(b["p1"], f"🏆 ПОБЕДА! {s1}:{s2}\n\n{cups_line(b['p1'], LEAGUE_CUPS_REWARD['win'])}", parse_mode="Markdown")
                bot.send_message(b["p2"], f"💔 ПОРАЖЕНИЕ! {s1}:{s2}\n\n{cups_line(b['p2'], LEAGUE_CUPS_REWARD['loss'])}", parse_mode="Markdown")
        elif s2 > s1:
            if is_bot:
                add_cups(uid, LEAGUE_CUPS_REWARD["loss"]); profiles[str(uid)]["losses"] += 1; save_profiles(profiles)
                bot.send_message(uid, f"💔 ПОРАЖЕНИЕ! {s1}:{s2}\n\n{cups_line(uid, LEAGUE_CUPS_REWARD['loss'])}", parse_mode="Markdown")
            else:
                update_stats(b["p2"], b["p1"])
                bot.send_message(b["p1"], f"💔 ПОРАЖЕНИЕ! {s1}:{s2}\n\n{cups_line(b['p1'], LEAGUE_CUPS_REWARD['loss'])}", parse_mode="Markdown")
                bot.send_message(b["p2"], f"🏆 ПОБЕДА! {s1}:{s2}\n\n{cups_line(b['p2'], LEAGUE_CUPS_REWARD['win'])}", parse_mode="Markdown")
        else:
            if is_bot:
                add_cups(uid, LEAGUE_CUPS_REWARD["draw"]); profiles[str(uid)]["draws"] += 1; save_profiles(profiles)
                bot.send_message(uid, f"🤝 НИЧЬЯ! {s1}:{s2}\n\n{cups_line(uid, LEAGUE_CUPS_REWARD['draw'])}", parse_mode="Markdown")
            else:
                update_stats_draw(b["p1"], b["p2"])
                bot.send_message(b["p1"], f"🤝 НИЧЬЯ! {s1}:{s2}\n\n{cups_line(b['p1'], LEAGUE_CUPS_REWARD['draw'])}", parse_mode="Markdown")
                bot.send_message(b["p2"], f"🤝 НИЧЬЯ! {s1}:{s2}\n\n{cups_line(b['p2'], LEAGUE_CUPS_REWARD['draw'])}", parse_mode="Markdown")
    except Exception as e:
        log_error("end_battle.notify", str(e), code)

    bot_log(f"🏁 {code} завершён {s1}:{s2}")
    p1_name = str(b["p1"]); p2_name = "🤖 БОТ" if is_bot else str(b["p2"])
    try: p1_name = bot.get_chat(b["p1"]).first_name or p1_name
    except: pass
    if not is_bot:
        try: p2_name = bot.get_chat(b["p2"]).first_name or p2_name
        except: pass
    result_str = f"{p1_name} победил" if s1 > s2 else (f"{p2_name} победил" if s2 > s1 else "Ничья")
    battles_log.append({
        "code": code, "date": datetime.now().strftime("%d.%m.%Y %H:%M"),
        "p1_id": b["p1"], "p1_name": p1_name,
        "p2_id": "BOT" if is_bot else b["p2"], "p2_name": p2_name,
        "score_p1": s1, "score_p2": s2, "result": result_str, "is_bot": is_bot,
    })
    if len(battles_log) > 500: battles_log.pop(0)
    save_battles_log(battles_log)

# ========== /cancel_duel — отменить свою дуэль ==========
@bot.message_handler(commands=['cancel_duel'])
def cancel_duel_cmd(message):
    uid = message.chat.id
    found = None; found_code = None
    for code, b in battles.items():
        if b.get("p1") == uid or (b.get("p2") == uid and b.get("p2") != "BOT"):
            found = b; found_code = code; break
    if not found:
        bot.send_message(uid, "❌ Ты не в дуэли.")
        return
    is_bot = found.get("is_bot", False)
    other  = found.get("p2") if found["p1"] == uid else found["p1"]
    battles.pop(found_code, None)
    if found_code in duels: del duels[found_code]
    if found_code in battle_last_action: del battle_last_action[found_code]
    bot.send_message(uid, "❌ Ты отменил дуэль.")
    if not is_bot and other and other != "BOT":
        try: bot.send_message(other, "❌ Противник отменил дуэль.")
        except: pass
    bot_log(f"🗑 {uid} отменил дуэль {found_code}")
    send_main_menu(uid)

# ========== /settings — ПАНЕЛЬ (только ADMINS) ==========
@bot.message_handler(commands=['settings'])
def settings_cmd(message):
    if message.chat.id not in ADMINS:
        bot.send_message(message.chat.id, "❌ Только для администраторов.")
        return
    send_settings_menu(message.chat.id)

def send_settings_menu(chat_id):
    diff_labels = {"weak": "🟢 Слабый", "medium": "🟡 Средний", "strong": "🔴 Сильный"}
    diff   = SETTINGS.get("bot_difficulty", "medium")
    cards  = SETTINGS.get("duel_cards", 6)
    rounds = SETTINGS.get("duel_rounds", 5)
    bt     = SETTINGS.get("bot_timeout", 60)
    pt     = SETTINGS.get("player_timeout", 120)

    active_pvp = [(c, b) for c, b in battles.items() if not b.get("is_bot")]
    active_bot = [(c, b) for c, b in battles.items() if b.get("is_bot")]

    text = (
        "⚙️ *НАСТРОЙКИ И МОНИТОР ДУЭЛЕЙ*\n"
        "━━━━━━━━━━━━━━━━━━━━━\n"
        f"🃏 Карт в колоде:  *{cards}*  (3–8)\n"
        f"🔢 Раундов:        *{rounds}*  (3 / 5 / 8)\n"
        f"🤖 Сложность бота: *{diff_labels.get(diff, diff)}*\n"
        f"⏱ Таймаут бота:   *{bt}с*\n"
        f"⏱ Таймаут игрока: *{pt}с*\n"
        "━━━━━━━━━━━━━━━━━━━━━\n"
        f"⚔️ PvP дуэлей:    *{len(active_pvp)}*\n"
        f"🤖 Бот-дуэлей:    *{len(active_bot)}*\n"
        f"🔍 В очереди:      *{len(matchmaking_queue)}*\n"
    )

    now = time.time()
    if active_pvp or active_bot:
        text += "\n📋 *АКТИВНЫЕ ДУЭЛИ:*\n"
        for code, b in (active_pvp + active_bot):
            is_bot_b    = b.get("is_bot", False)
            total_rounds = b.get("total_rounds", rounds)
            p1_name = str(b["p1"])
            try: p1_name = bot.get_chat(b["p1"]).first_name or p1_name
            except: pass
            p2_name = "🤖 БОТ" if is_bot_b else str(b["p2"])
            if not is_bot_b:
                try: p2_name = bot.get_chat(b["p2"]).first_name or p2_name
                except: pass

            waiting_on = []
            if b.get("waiting_p1"): waiting_on.append(p1_name)
            if b.get("waiting_p2") and not is_bot_b: waiting_on.append(p2_name)
            if b.get("waiting_p2") and is_bot_b: waiting_on.append("🤖 БОТ")

            last    = battle_last_action.get(code)
            elapsed = int(now - last) if last else 0
            warn    = " ⚠️ ЗАВИСАНИЕ" if (
                (is_bot_b and b.get("waiting_p2") and elapsed > bt * 0.8) or
                (not is_bot_b and elapsed > pt * 0.75)
            ) else ""

            text += (
                f"\n🔑 `{code}` | Р.{b['round']}/{total_rounds} | {b['score1']}:{b['score2']}"
                f" | фаза: *{b.get('phase','?')}*{warn}\n"
                f"   👥 {p1_name} vs {p2_name}\n"
                f"   ⏳ Ожидает: {', '.join(waiting_on) if waiting_on else '—'}\n"
                f"   ⏱ Без хода: {elapsed}с\n"
            )

    recent_errors = error_log[-5:] if error_log else []
    if recent_errors:
        text += "\n\n🚨 *ПОСЛЕДНИЕ ОШИБКИ:*\n"
        for e in reversed(recent_errors):
            text += f"⚠️ [{e['time']}] {e['source']}: {e['error'][:55]}\n"
    else:
        text += "\n\n✅ *Ошибок нет*\n"

    text += (
        "\n━━━━━━━━━━━━━━━━━━━━━\n"
        "🔧 */set\\_cards* 3–8 | */set\\_rounds* 3|5|8 | */set\\_diff* weak|medium|strong\n"
        "🗑 */kill\\_duel* КОД — принудительно отменить\n"
        "/duel\\_monitor — обновить | /error\\_log — лог\n"
        "/check — проверка бота | /bot\\_backup — сохранить снапшот\n"
    )

    kb = telebot.types.InlineKeyboardMarkup(row_width=3)
    # Карты
    kb.add(
        telebot.types.InlineKeyboardButton(f"{'✅ ' if cards==3 else ''}🃏 3", callback_data="sc_3"),
        telebot.types.InlineKeyboardButton(f"{'✅ ' if cards==4 else ''}🃏 4", callback_data="sc_4"),
        telebot.types.InlineKeyboardButton(f"{'✅ ' if cards==5 else ''}🃏 5", callback_data="sc_5"),
        telebot.types.InlineKeyboardButton(f"{'✅ ' if cards==6 else ''}🃏 6", callback_data="sc_6"),
        telebot.types.InlineKeyboardButton(f"{'✅ ' if cards==7 else ''}🃏 7", callback_data="sc_7"),
        telebot.types.InlineKeyboardButton(f"{'✅ ' if cards==8 else ''}🃏 8", callback_data="sc_8"),
    )
    # Раунды
    kb.add(
        telebot.types.InlineKeyboardButton(f"{'✅ ' if rounds==3 else ''}🔢 3р", callback_data="sr_3"),
        telebot.types.InlineKeyboardButton(f"{'✅ ' if rounds==5 else ''}🔢 5р", callback_data="sr_5"),
        telebot.types.InlineKeyboardButton(f"{'✅ ' if rounds==8 else ''}🔢 8р", callback_data="sr_8"),
    )
    # Сложность бота
    kb.add(
        telebot.types.InlineKeyboardButton(f"{'✅ ' if diff=='weak' else ''}🟢 Слабый",   callback_data="sd_weak"),
        telebot.types.InlineKeyboardButton(f"{'✅ ' if diff=='medium' else ''}🟡 Средний", callback_data="sd_medium"),
        telebot.types.InlineKeyboardButton(f"{'✅ ' if diff=='strong' else ''}🔴 Сильный", callback_data="sd_strong"),
    )
    kb.add(telebot.types.InlineKeyboardButton("🔄 Обновить монитор", callback_data="refresh_s"))

    bot.send_message(chat_id, text, parse_mode="Markdown", reply_markup=kb)

@bot.callback_query_handler(func=lambda call: call.data[:3] in ("sc_","sr_","sd_") or call.data == "refresh_s")
def settings_callback(call):
    if call.from_user.id not in ADMINS:
        bot.answer_callback_query(call.id, "❌ Нет прав"); return

    d = call.data
    if d.startswith("sc_"):
        n = int(d[3:]); SETTINGS["duel_cards"] = n; save_settings(SETTINGS)
        bot.answer_callback_query(call.id, f"✅ Карт в колоде: {n}")
        bot_log(f"⚙️ {call.from_user.id} → карт={n}")
    elif d.startswith("sr_"):
        r = int(d[3:]); SETTINGS["duel_rounds"] = r; save_settings(SETTINGS)
        bot.answer_callback_query(call.id, f"✅ Раундов: {r}")
        bot_log(f"⚙️ {call.from_user.id} → раундов={r}")
    elif d.startswith("sd_"):
        diff = d[3:]; SETTINGS["bot_difficulty"] = diff; save_settings(SETTINGS)
        labels = {"weak": "Слабый", "medium": "Средний", "strong": "Сильный"}
        bot.answer_callback_query(call.id, f"✅ Бот: {labels.get(diff,diff)}")
        bot_log(f"⚙️ {call.from_user.id} → сложность={diff}")
    else:
        bot.answer_callback_query(call.id, "🔄 Обновлено")

    try: bot.delete_message(call.message.chat.id, call.message.message_id)
    except: pass
    send_settings_menu(call.message.chat.id)

@bot.message_handler(commands=['set_cards'])
def set_cards_cmd(message):
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только для администраторов."); return
    parts = message.text.split()
    if len(parts) != 2 or not parts[1].isdigit(): bot.send_message(message.chat.id, "❌ /set_cards 3–8"); return
    n = int(parts[1])
    if n < 3 or n > 8: bot.send_message(message.chat.id, "❌ Диапазон: 3–8"); return
    SETTINGS["duel_cards"] = n; save_settings(SETTINGS)
    bot.send_message(message.chat.id, f"✅ Карт в колоде: *{n}*", parse_mode="Markdown")

@bot.message_handler(commands=['set_rounds'])
def set_rounds_cmd(message):
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только для администраторов."); return
    parts = message.text.split()
    if len(parts) != 2 or not parts[1].isdigit(): bot.send_message(message.chat.id, "❌ /set_rounds 3|5|8"); return
    r = int(parts[1])
    if r not in (3, 5, 8): bot.send_message(message.chat.id, "❌ Допустимо: 3, 5, 8"); return
    SETTINGS["duel_rounds"] = r; save_settings(SETTINGS)
    bot.send_message(message.chat.id, f"✅ Раундов в дуэли: *{r}*", parse_mode="Markdown")
    bot_log(f"⚙️ {message.chat.id} → раундов={r}")

@bot.message_handler(commands=['set_diff'])
def set_diff_cmd(message):
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только для администраторов."); return
    parts = message.text.split()
    if len(parts) != 2 or parts[1] not in ("weak","medium","strong"):
        bot.send_message(message.chat.id, "❌ /set_diff weak|medium|strong"); return
    SETTINGS["bot_difficulty"] = parts[1]; save_settings(SETTINGS)
    labels = {"weak": "🟢 Слабый", "medium": "🟡 Средний", "strong": "🔴 Сильный"}
    bot.send_message(message.chat.id, f"✅ Бот: *{labels[parts[1]]}*", parse_mode="Markdown")

@bot.message_handler(commands=['duel_monitor'])
def duel_monitor_cmd(message):
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только для администраторов."); return
    send_settings_menu(message.chat.id)

@bot.message_handler(commands=['kill_duel'])
def kill_duel_cmd(message):
    """Принудительно завершить дуэль по коду."""
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только для администраторов."); return
    parts = message.text.split()
    if len(parts) != 2: bot.send_message(message.chat.id, "❌ /kill_duel КОД"); return
    code = parts[1].strip()
    b    = battles.get(code)
    if not b: bot.send_message(message.chat.id, f"❌ Дуэль `{code}` не найдена.", parse_mode="Markdown"); return
    for pid_key in ["p1", "p2"]:
        pid = b.get(pid_key)
        if pid and pid != "BOT":
            try: bot.send_message(pid, f"🛑 Дуэль `{code}` принудительно остановлена администратором.", parse_mode="Markdown")
            except: pass
    battles.pop(code, None)
    if code in duels: del duels[code]
    if code in battle_last_action: del battle_last_action[code]
    bot.send_message(message.chat.id, f"✅ Дуэль `{code}` уничтожена.", parse_mode="Markdown")
    bot_log(f"🛑 {message.chat.id} убил дуэль {code}")

@bot.message_handler(commands=['error_log'])
def error_log_cmd(message):
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только для администраторов."); return
    if not error_log: bot.send_message(message.chat.id, "✅ Лог ошибок пуст."); return
    text = "🚨 *ЛОГ ОШИБОК (последние 20)*\n\n"
    for e in reversed(error_log[-20:]):
        text += f"⚠️ `{e['time']}`\n📍 {e['source']}\n💬 {e['error']}\n"
        if e.get("extra"): text += f"ℹ️ {e['extra']}\n"
        text += "\n"
    if len(text) > 4000: text = text[:3900] + "\n...(обрезано)"
    bot.send_message(message.chat.id, text, parse_mode="Markdown")

# ========== /check — АВТОНОМНАЯ ПРОВЕРКА + АВТОРЕМОНТ ==========
@bot.message_handler(commands=['check'])
def check_cmd(message):
    if message.chat.id not in ADMINS:
        bot.send_message(message.chat.id, "❌ Только для администраторов.")
        return
    threading.Thread(target=run_full_check, args=(message.chat.id,), daemon=True).start()

def run_full_check(chat_id):
    checks  = []
    total   = 0
    passed  = 0
    repaired = []

    def run_check(name, fn, repair_fn=None):
        nonlocal total, passed
        total += 1
        try:
            ok, detail = fn()
            if not ok and repair_fn:
                try:
                    repair_fn()
                    repaired.append(name)
                    ok2, detail2 = fn()
                    if ok2:
                        checks.append(f"🔧 {name}: ПОЧИНЕНО → {detail2}")
                        passed += 1; return True
                except Exception as re:
                    detail += f" | ❌ Ремонт не удался: {re}"
                    log_error(f"check/repair/{name}", str(re))
            status = "✅" if ok else "❌"
            if ok: passed += 1
            checks.append(f"{status} {name}: {detail}")
            return ok
        except Exception as e:
            checks.append(f"❌ {name}: ИСКЛЮЧЕНИЕ — {e}")
            log_error(f"check/{name}", str(e))
            return False

    # Прогресс-сообщение
    try:
        pmsg = bot.send_message(chat_id, "🔍 *Запуск проверки...*\n`░░░░░░░░░░` 0%", parse_mode="Markdown")
    except: pmsg = None

    def upd(pct, label=""):
        if not pmsg: return
        bar = "▓" * int(pct/10) + "░" * (10 - int(pct/10))
        try: bot.edit_message_text(f"🔍 *Проверка...*\n`{bar}` {pct}%\n_{label}_",
                                   chat_id, pmsg.message_id, parse_mode="Markdown")
        except: pass

    # ── 1. Файлы ──
    upd(8, "Файлы данных...")
    run_check("profiles.json",
              lambda: (os.path.exists(PROFILES_FILE), f"{len(profiles)} игроков"),
              lambda: save_profiles(profiles))
    run_check("cards.json",
              lambda: (os.path.exists(CARDS_FILE), f"{len(CARDS_DB)} карт"),
              lambda: save_cards(CARDS_DB))
    run_check("settings.json",
              lambda: (os.path.exists(SETTINGS_FILE), f"cards={SETTINGS.get('duel_cards',6)}, rounds={SETTINGS.get('duel_rounds',5)}, diff={SETTINGS.get('bot_difficulty','?')}"),
              lambda: save_settings(SETTINGS))
    run_check("error_log.json",
              lambda: (True, f"{len(error_log)} записей"))

    # ── 2. Карты ──
    upd(18, "База карт...")
    def _cards_integrity():
        broken = [cid for cid, c in CARDS_DB.items()
                  if not c.get("name") or not c.get("element") or not c.get("rating")]
        return (len(broken) == 0, f"{len(CARDS_DB)} карт, {len(broken)} повреждённых")
    def _fix_cards():
        for cid, c in list(CARDS_DB.items()):
            if not c.get("element"): CARDS_DB[cid]["element"] = "вода"
            if not c.get("rating"):  CARDS_DB[cid]["rating"]  = 80
        save_cards(CARDS_DB)
    run_check("Карты (целостность)", _cards_integrity, _fix_cards)

    def _elements():
        bad = [cid for cid, c in CARDS_DB.items() if c.get("element") not in FEARS]
        return (len(bad) == 0, f"{len(bad)} с неверным элементом")
    def _fix_elements():
        for cid, c in CARDS_DB.items():
            if c.get("element") not in FEARS: CARDS_DB[cid]["element"] = "вода"
        save_cards(CARDS_DB)
    run_check("Карты (элементы)", _elements, _fix_elements)

    # ── 3. Колоды ──
    upd(30, "Колоды игроков...")
    def _decks():
        bad = [uid for uid, deck in user_decks.items() if any(cid not in CARDS_DB for cid in deck)]
        return (len(bad) == 0, f"{len(user_decks)} колод, {len(bad)} с битыми картами")
    def _fix_decks():
        for uid in list(user_decks.keys()):
            user_decks[uid] = [cid for cid in user_decks[uid] if cid in CARDS_DB]
            if not user_decks[uid]: del user_decks[uid]
    run_check("Колоды игроков", _decks, _fix_decks)

    # ── 4. Активные дуэли ──
    upd(42, "Активные дуэли...")
    def _battles():
        issues = []
        for code, b in battles.items():
            if b.get("p1") is None: issues.append(f"{code}:нет p1")
            if not b.get("is_bot") and b.get("p2") is None: issues.append(f"{code}:нет p2")
        return (len(issues) == 0, f"{len(battles)} активных, {len(issues)} ошибок")
    def _fix_battles():
        for code in list(battles.keys()):
            b = battles[code]
            if b.get("p1") is None or (not b.get("is_bot") and b.get("p2") is None):
                battles.pop(code, None)
                if code in duels: del duels[code]
                if code in battle_last_action: del battle_last_action[code]
    run_check("Активные дуэли", _battles, _fix_battles)

    def _frozen():
        now = time.time(); frozen = []
        for code, b in battles.items():
            last = battle_last_action.get(code)
            if last:
                elapsed = now - last
                limit   = SETTINGS.get("bot_timeout",60) if b.get("is_bot") and b.get("waiting_p2") \
                          else SETTINGS.get("player_timeout",120)
                if elapsed > limit * 0.85:
                    frozen.append(f"{code}({int(elapsed)}с)")
        return (len(frozen) == 0, f"{len(frozen)} зависших: {', '.join(frozen) or 'нет'}")
    run_check("Зависшие дуэли", _frozen)

    # ── 5. Профили ──
    upd(55, "Профили...")
    def _profiles():
        bad = [uid for uid, p in profiles.items()
               if not isinstance(p.get("wins"), int) or not isinstance(p.get("cups"), int)]
        return (len(bad) == 0, f"{len(profiles)} профилей, {len(bad)} ошибок")
    def _fix_profiles():
        for uid, p in profiles.items():
            for k in ("wins","losses","draws","cups"):
                if not isinstance(p.get(k), int): p[k] = 0
        save_profiles(profiles)
    run_check("Профили", _profiles, _fix_profiles)

    def _neg_cups():
        neg = [uid for uid, p in profiles.items() if p.get("cups", 0) < 0]
        return (len(neg) == 0, f"{len(neg)} с отрицательными кубками")
    def _fix_neg():
        for uid, p in profiles.items():
            if p.get("cups", 0) < 0: p["cups"] = 0
        save_profiles(profiles)
    run_check("Кубки (отрицательные)", _neg_cups, _fix_neg)

    # ── 6. Блокировки ──
    upd(68, "Блокировки...")
    def _blocked():
        admin_bl = [uid for uid in blocked_users if uid in ADMINS]
        return (len(admin_bl) == 0, f"{len(blocked_users)} заблокированных, {len(admin_bl)} — admin!")
    def _fix_blocked():
        for uid in list(blocked_users):
            if uid in ADMINS: blocked_users.remove(uid)
        save_blocked(blocked_users)
    run_check("Заблокированные", _blocked, _fix_blocked)

    # ── 7. Очередь матчмейкинга ──
    upd(78, "Очередь поиска...")
    def _queue():
        dead = [uid for uid in matchmaking_queue if uid not in user_decks]
        return (len(dead) == 0, f"{len(matchmaking_queue)} в очереди, {len(dead)} без колоды")
    def _fix_queue():
        for uid in [u for u in matchmaking_queue if u not in user_decks]:
            del matchmaking_queue[uid]
    run_check("Очередь поиска", _queue, _fix_queue)

    # ── 8. Настройки ──
    upd(88, "Настройки...")
    def _settings():
        n    = SETTINGS.get("duel_cards", 6)
        r    = SETTINGS.get("duel_rounds", 5)
        diff = SETTINGS.get("bot_difficulty", "medium")
        ok   = (3 <= n <= 8) and (r in (3,5,8)) and diff in ("weak","medium","strong")
        return (ok, f"cards={n}, rounds={r}, diff={diff}")
    def _fix_settings():
        if not (3 <= SETTINGS.get("duel_cards",6) <= 8): SETTINGS["duel_cards"] = 6
        if SETTINGS.get("duel_rounds",5) not in (3,5,8): SETTINGS["duel_rounds"] = 5
        if SETTINGS.get("bot_difficulty","medium") not in ("weak","medium","strong"): SETTINGS["bot_difficulty"] = "medium"
        save_settings(SETTINGS)
    run_check("Настройки", _settings, _fix_settings)

    # ── 9. Версия ──
    upd(96, "Версия бота...")
    run_check("Версия", lambda: (bool(load_version_info().get("current")), f"v{load_version_info().get('current','?')}"))

    upd(100, "Готово!")
    pct  = int(passed / total * 100) if total > 0 else 0
    bar  = "▓" * int(pct/10) + "░" * (10 - int(pct/10))
    icon = "✅" if pct >= 90 else ("⚠️" if pct >= 60 else "❌")
    status = "Всё в порядке" if pct >= 90 else ("Есть проблемы" if pct >= 60 else "КРИТИЧНЫЕ ОШИБКИ")

    report = (
        f"🤖 *ОТЧЁТ ПРОВЕРКИ БОТА*\n"
        f"`{bar}` {pct}% ({passed}/{total})\n"
        f"{icon} *{status}*\n"
    )
    if repaired:
        report += f"🔧 Починено авто: {len(repaired)} — {', '.join(repaired)}\n"
    report += "━━━━━━━━━━━━━━━━━━━━━\n\n"
    report += "\n".join(checks)
    report += f"\n\n📅 {datetime.now().strftime('%d.%m.%Y %H:%M:%S')}"

    try: bot.delete_message(chat_id, pmsg.message_id)
    except: pass

    for i in range(0, len(report), 3800):
        bot.send_message(chat_id, report[i:i+3800], parse_mode="Markdown")

# ========== ЛИГИ АДМИН ==========
@bot.message_handler(commands=['lligsll'])
def lligsll_command(message):
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только для администраторов"); return
    text = "🏅 *ПАНЕЛЬ УПРАВЛЕНИЯ ЛИГАМИ*\n\n"
    for lg in LEAGUES:
        has = "✅" if league_photos.get(lg["name"]) else "❌"
        text += f"{lg['emoji']} **{lg['name']}** — {lg['min_cups']}–{lg['max_cups']} 🏆 — {has}\n"
    text += "\n📸 `/upload_league Золотая` → отправь фото\n🔱 `/givecups USER_ID ЧИСЛО`\n"
    bot.send_message(message.chat.id, text, parse_mode="Markdown")

@bot.message_handler(commands=['upload_league'])
def upload_league_cmd(message):
    if message.chat.id not in ADMINS: return
    parts = message.text.split(maxsplit=1)
    if len(parts) < 2: bot.send_message(message.chat.id, "❌ /upload_league НазваниеЛиги"); return
    ln = parts[1].strip()
    if ln not in [lg["name"] for lg in LEAGUES]:
        bot.send_message(message.chat.id, "❌ Лига не найдена. Названия: " + ", ".join(lg["name"] for lg in LEAGUES)); return
    league_photo_upload_state[message.chat.id] = ln
    bot.send_message(message.chat.id, f"📸 Отправь фото для лиги *{ln}*:", parse_mode="Markdown")

@bot.message_handler(commands=['givecups'])
def givecups_cmd(message):
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только для администраторов"); return
    parts = message.text.split()
    if len(parts) != 3 or not parts[1].isdigit(): bot.send_message(message.chat.id, "❌ /givecups USER_ID ЧИСЛО"); return
    try: uid = int(parts[1]); delta = int(parts[2])
    except: bot.send_message(message.chat.id, "❌ Неверные параметры"); return
    old = ensure_profile(uid).get("cups",0); add_cups(uid, delta); new = ensure_profile(uid).get("cups",0)
    lg  = get_league(new); sign = "+" if delta >= 0 else ""
    try: bot.send_message(uid, f"🏆 Кубки: {sign}{delta}\nВсего: {new} 🏆\n{lg['emoji']} **{lg['name']}**", parse_mode="Markdown")
    except: pass
    bot.send_message(message.chat.id, f"✅ {uid}: {old} → {new} ({sign}{delta})")
    bot_log(f"👑 {message.chat.id} кубки {uid}: {sign}{delta}")

@bot.message_handler(commands=['say'])
def say_cmd(message):
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только для администраторов"); return
    parts = message.text.split(maxsplit=1)
    if len(parts) < 2 or not parts[1].strip(): bot.send_message(message.chat.id, "❌ /say ТЕКСТ"); return
    text = parts[1].strip(); sent = 0; failed = 0
    for uid_str in profiles.keys():
        try: bot.send_message(int(uid_str), f"📢 *Сообщение от администратора:*\n\n{text}", parse_mode="Markdown"); sent += 1
        except: failed += 1
    bot.send_message(message.chat.id, f"✅ Отправлено: {sent} | Не доставлено: {failed}")
    bot_log(f"📢 Рассылка от {message.chat.id}")

@bot.message_handler(commands=['admins'])
def admins_cmd(message):
    if message.chat.id not in ADMINS: return
    text = "👑 *АДМИНИСТРАТОРЫ*\n\n"
    for aid in ADMINS:
        try:
            u = bot.get_chat(aid); name = u.first_name or str(aid)
            un = f" (@{u.username})" if u.username else ""
            text += f"• {name}{un}{' 🔱' if aid == SUPERADMIN else ''} — `{aid}`\n"
        except: text += f"• `{aid}`{' 🔱' if aid == SUPERADMIN else ''}\n"
    bot.send_message(message.chat.id, text, parse_mode="Markdown")

@bot.message_handler(commands=['players'])
def players_cmd(message):
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только для администраторов"); return
    if not profiles: bot.send_message(message.chat.id, "📭 Нет игроков."); return
    text = "👥 *СПИСОК ИГРОКОВ*\n\n"
    for uid_str in profiles.keys():
        name = uid_str
        try:
            c = bot.get_chat(int(uid_str)); name = c.first_name or uid_str
            if c.username: name += f" (@{c.username})"
        except: pass
        cups = profiles[uid_str].get("cups",0); lg = get_league(cups)
        text += f"• `{uid_str}` — {name}{'👑' if int(uid_str) in ADMINS else ''}{'🔒' if int(uid_str) in blocked_users else ''} | {lg['emoji']} {cups} 🏆\n"
    bot.send_message(message.chat.id, text, parse_mode="Markdown")

@bot.message_handler(commands=['block'])
def block_cmd(message):
    if message.chat.id not in ADMINS: return
    parts = message.text.split()
    if len(parts) != 2 or not parts[1].isdigit(): bot.send_message(message.chat.id, "❌ /block USER_ID"); return
    uid = int(parts[1])
    if uid in ADMINS: bot.send_message(message.chat.id, "❌ Нельзя заблокировать администратора!"); return
    if uid not in blocked_users: blocked_users.append(uid); save_blocked(blocked_users)
    try: bot.send_message(uid, "🚫 Вы заблокированы администратором.")
    except: pass
    bot.send_message(message.chat.id, f"✅ {uid} заблокирован."); bot_log(f"🔒 {message.chat.id} заблокировал {uid}")

@bot.message_handler(commands=['unblock'])
def unblock_cmd(message):
    if message.chat.id not in ADMINS: return
    parts = message.text.split()
    if len(parts) != 2 or not parts[1].isdigit(): bot.send_message(message.chat.id, "❌ /unblock USER_ID"); return
    uid = int(parts[1])
    if uid in blocked_users:
        blocked_users.remove(uid); save_blocked(blocked_users)
        try: bot.send_message(uid, "✅ Доступ восстановлен.")
        except: pass
        bot.send_message(message.chat.id, f"✅ {uid} разблокирован.")
        bot_log(f"🔓 {message.chat.id} разблокировал {uid}")
    else: bot.send_message(message.chat.id, f"❌ {uid} не заблокирован.")

@bot.message_handler(commands=['reload'])
def reload_command(message):
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только админ"); return
    parts = message.text.split()
    if len(parts) != 2: bot.send_message(message.chat.id, "❌ /reload USER_ID"); return
    try: uid = int(parts[1]); reload_user(uid); bot.send_message(message.chat.id, f"✅ {uid} перезагружен")
    except: bot.send_message(message.chat.id, "❌ Неверный ID")

@bot.message_handler(commands=['clean'])
def clean_cmd(message):
    if message.chat.id not in ADMINS: return
    parts = message.text.split()
    if len(parts) != 2: bot.send_message(message.chat.id, "❌ /clean USER_ID"); return
    try:
        uid = int(parts[1])
        for code in list(battles.keys()):
            if battles[code].get("p1") == uid or battles[code].get("p2") == uid:
                battles.pop(code, None)
                if code in duels: del duels[code]
                if code in battle_last_action: del battle_last_action[code]
                bot.send_message(message.chat.id, f"✅ {uid} очищен"); return
        bot.send_message(message.chat.id, f"❌ {uid} не в дуэли")
    except: bot.send_message(message.chat.id, "❌ Неверный ID")

@bot.message_handler(commands=['restart'])
def restart_cmd(message):
    if message.chat.id not in ADMINS: return
    bot.send_message(message.chat.id, "🔄 Перезапуск...")
    bot_log(f"👑 Перезапуск от {message.chat.id}")
    os._exit(0)

@bot.message_handler(commands=['op'])
def op_cmd(message):
    if message.chat.id != SUPERADMIN: bot.send_message(message.chat.id, "❌ Только главный администратор."); return
    parts = message.text.split()
    if len(parts) != 2 or not parts[1].isdigit(): bot.send_message(message.chat.id, "❌ /op USER_ID"); return
    uid = int(parts[1])
    if uid in ADMINS: bot.send_message(message.chat.id, f"ℹ️ {uid} уже администратор."); return
    ADMINS.append(uid)
    try: bot.send_message(uid, "👑 Вам выданы права администратора!"); send_main_menu(uid)
    except: pass
    bot.send_message(message.chat.id, f"✅ {uid} назначен."); bot_log(f"👑 Суперадмин выдал права {uid}")

@bot.message_handler(commands=['deop'])
def deop_cmd(message):
    if message.chat.id != SUPERADMIN: bot.send_message(message.chat.id, "❌ Только главный администратор."); return
    parts = message.text.split()
    if len(parts) != 2 or not parts[1].isdigit(): bot.send_message(message.chat.id, "❌ /deop USER_ID"); return
    uid = int(parts[1])
    if uid == SUPERADMIN: bot.send_message(message.chat.id, "❌ Нельзя снять права у главного!"); return
    if uid not in ADMINS: bot.send_message(message.chat.id, f"ℹ️ {uid} не администратор."); return
    ADMINS.remove(uid)
    try: bot.send_message(uid, "🚫 Права администратора сняты."); send_main_menu(uid)
    except: pass
    bot.send_message(message.chat.id, f"✅ Права сняты с {uid}."); bot_log(f"👑 Суперадмин снял права с {uid}")

VALID_ELEMENTS = ["вода","металл","огонь","молния","песок","ветер","дерево","лёд","земля"]
VALID_RATINGS  = [80, 84, 85, 90, 100, 101]

def get_next_card_id():
    if not CARDS_DB: return "card_001"
    existing = [int(k.replace("card_","")) for k in CARDS_DB if k.startswith("card_")]
    return f"card_{max(existing)+1:03d}"

@bot.message_handler(commands=['add_card'])
def add_card_cmd(message):
    if message.chat.id not in ADMINS: bot.send_message(message.chat.id, "❌ Только администраторы"); return
    add_card_state[message.chat.id] = {"step": "name"}
    bot.send_message(message.chat.id, "🃏 *ДОБАВЛЕНИЕ КАРТЫ*\n\nВведи имя персонажа:", parse_mode="Markdown")

def handle_add_card_input(message):
    uid   = message.chat.id
    state = add_card_state.get(uid)
    if not state: return False
    text = message.text.strip()
    if text.startswith("/") or text in CANCEL_BUTTONS: del add_card_state[uid]; return False
    step = state["step"]
    if step == "name":
        state["name"] = text; state["step"] = "element"
        bot.send_message(uid, f"✅ Имя: *{text}*\n\n🌀 Элемент:\n" + "\n".join(f"• `{e}`" for e in VALID_ELEMENTS), parse_mode="Markdown")
    elif step == "element":
        if text.lower() not in VALID_ELEMENTS: bot.send_message(uid, f"❌ Доступные: {', '.join(VALID_ELEMENTS)}"); return True
        state["element"] = text.lower(); state["step"] = "rating"
        bot.send_message(uid, f"✅ Элемент: *{text}*\n\n⭐ Рейтинг: `{', '.join(str(r) for r in VALID_RATINGS)}`", parse_mode="Markdown")
    elif step == "rating":
        if not text.isdigit() or int(text) not in VALID_RATINGS: bot.send_message(uid, f"❌ Рейтинги: {', '.join(str(r) for r in VALID_RATINGS)}"); return True
        state["rating"] = int(text); state["step"] = "confirm"; nid = get_next_card_id(); state["new_id"] = nid
        bot.send_message(uid, f"📋 *ПРЕДПРОСМОТР*\n\n🆔 `{nid}`\n👤 *{state['name']}*\n🌀 {state['element']}\n⭐ {state['rating']}\n\nВведи *сохранить* или *отмена*", parse_mode="Markdown")
    elif step == "confirm":
        if text.lower() == "сохранить":
            CARDS_DB[state["new_id"]] = {"name": state["name"], "element": state["element"], "rating": state["rating"], "media": None, "media_type": None}
            save_cards(CARDS_DB); del add_card_state[uid]
            bot.send_message(uid, f"✅ Карта *{state['name']}* сохранена!", parse_mode="Markdown")
            bot_log(f"👑 {uid} добавил {state['new_id']}: {state['name']}")
        elif text.lower() == "отмена": del add_card_state[uid]; bot.send_message(uid, "❌ Отменено.")
        else: bot.send_message(uid, "Введи *сохранить* или *отмена*", parse_mode="Markdown")
    add_card_state[uid] = state
    return True

@bot.message_handler(commands=['media_manager'])
def media_manager_cmd(message):
    if message.chat.id not in ADMINS: return
    text = "🖼️ *МЕДИА МЕНЕДЖЕР*\n\n"
    for cid, c in CARDS_DB.items():
        text += f"`{cid}` - {c['name']} — {'✅' if c['media'] else '❌'} [{c.get('media_type','-')}]\n"
    text += "\n📌 /upload — загрузить медиа"
    bot.send_message(message.chat.id, text, parse_mode="Markdown")

@bot.message_handler(commands=['upload'])
def upload_cmd(message):
    if message.chat.id not in ADMINS: return
    admin_upload[message.chat.id] = True
    bot.send_message(message.chat.id, "📸 Отправь ФОТО или ВИДЕО. Подпись = ID карты (card_001)")

@bot.message_handler(commands=['help'])
def help_cmd(message):
    uid = message.chat.id; vi = load_version_info()
    n   = SETTINGS.get("duel_cards", 6); r = SETTINGS.get("duel_rounds", 5)
    user_text = (
        f"📖 *СПИСОК КОМАНД*  |  v{vi['current']}\n\n"
        "👤 /start /profile /top\n"
        "🃏 /build\\_deck /auto\\_build /my\\_deck /all\\_cards\n"
        f"⚔️ /duel /join КОД /cancel\\_search /1–/{n}\n"
        f"🏳 /cancel\\_duel — отменить свою дуэль\n"
        f"🔢 Раундов: {r} | Победа: +30🏆 | Пораж: -15🏆 | Ничья: +5🏆\n"
        "ℹ️ /info USER\\_ID /look /help\n"
    )
    admin_text = (
        "\n\n👑 *АДМИН*\n"
        "/add\\_card /upload /media\\_manager\n"
        "/block /unblock /players /admins\n"
        "/reload /clean /restart\n"
        "/givecups USER\\_ID КУБКИ\n"
        "/lligsll /upload\\_league ЛИГА\n"
        "/say ТЕКСТ\n"
        "/sys\\_version /sys\\_rollback\n"
        "\n⚙️ *НАСТРОЙКИ И МОНИТОР*\n"
        "/settings — панель настроек + монитор\n"
        "/set\\_cards 3–8  |  /set\\_rounds 3|5|8\n"
        "/set\\_diff weak|medium|strong\n"
        "/duel\\_monitor — монитор активных дуэлей\n"
        "/kill\\_duel КОД — принудительно завершить\n"
        "/error\\_log — лог ошибок\n"
        "/check — 🔍 полная проверка + авторемонт\n"
        "/bot\\_backup — снапшот кода бота\n"
        "/bot\\_backups — список снапшотов\n"
    )
    superadmin_text = "\n🔱 *СУПЕРАДМИН*\n/op /deop USER\\_ID\n/sys\\_update — патч\n"
    bot.send_message(uid,
        user_text + (admin_text if uid in ADMINS else "") + (superadmin_text if uid == SUPERADMIN else ""),
        parse_mode="Markdown")

@bot.message_handler(content_types=['photo','video'])
def handle_media(message):
    uid = message.chat.id
    if uid in league_photo_upload_state:
        ln = league_photo_upload_state.pop(uid)
        if message.photo:
            league_photos[ln] = message.photo[-1].file_id; save_league_photos(league_photos)
            bot.send_message(uid, f"✅ Фото для *{ln}* сохранено!", parse_mode="Markdown")
            bot_log(f"👑 {uid} загрузил фото лиги {ln}")
        else: bot.send_message(uid, "❌ Нужно ФОТО (не видео).")
        return
    if admin_upload.get(uid):
        card_id = (message.caption or "").strip()
        if card_id in CARDS_DB:
            if message.video:   CARDS_DB[card_id].update({"media": message.video.file_id, "media_type": "video"})
            elif message.photo: CARDS_DB[card_id].update({"media": message.photo[-1].file_id, "media_type": "photo"})
            save_cards(CARDS_DB); bot.send_message(uid, f"✅ Медиа для {CARDS_DB[card_id]['name']} сохранено!")
            bot_log(f"👑 {uid} загрузил медиа {card_id}")
        else: bot.send_message(uid, f"❌ Карта {card_id} не найдена")
        del admin_upload[uid]

@bot.message_handler(func=lambda m: True)
def buttons(message):
    uid = message.chat.id
    if is_blocked(uid): bot.send_message(uid, "🚫 Вы заблокированы."); return
    if uid in add_card_state:
        if handle_add_card_input(message): return
    if handle_collection_input(message): return
    text = message.text

    if uid in duel_menu_state:
        state = duel_menu_state[uid]
        if text == "🔙 Назад":
            if state == "duel_pvp": send_duel_menu(uid)
            else: del duel_menu_state[uid]; send_main_menu(uid)
            return
        if state == "duel_main":
            if text == "1️⃣ Дуэль с игроком":
                if uid not in user_decks: bot.send_message(uid, "❌ Сначала /build_deck"); return
                send_pvp_menu(uid); return
            elif text == "2️⃣ Дуэль с ботом":
                del duel_menu_state[uid]; send_main_menu(uid); start_bot_battle(uid); return
            elif text == "🏅 Моя лига": send_league_info(uid); return
        elif state == "duel_pvp":
            if text == "🔍 Найти дуэль":
                if uid not in user_decks: bot.send_message(uid, "❌ Сначала /build_deck"); return
                del duel_menu_state[uid]; send_main_menu(uid); search_duel(uid); return
            elif text == "➕ Создать дуэль":
                if uid not in user_decks: bot.send_message(uid, "❌ Сначала /build_deck"); return
                del duel_menu_state[uid]; send_main_menu(uid); create_duel(uid); return

    if text == "📚 Моя колода":   my_deck_command(message)
    elif text == "⚔️ Дуэль":
        if uid not in user_decks: bot.send_message(uid, "❌ Сначала /build_deck"); return
        send_duel_menu(uid)
    elif text == "🃏 Собрать колоду": start_collection(uid)
    elif text == "🤖 Авто-колода":    auto_build_command(message)
    elif text == "🔍 Все карты":      all_cards_command(message)
    elif text == "👤 Профиль":        profile_command(message)
    elif text == "🏆 Топ игроков":    top_command(message)

# ========== ЗАПУСК ==========
vi = load_version_info()
print(f"✅ БОТ ЗАПУЩЕН  v{vi['current']}")
bot_log(f"🚀 Бот запущен v{vi['current']}")
bot.infinity_polling()
