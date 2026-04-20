-- SWILL LAUNCHER v2.0 [Rayfield UI]
-- Загрузчик с GUI и поэтапным логом

-- Сначала загружаем Rayfield
local RayfieldLoaded = false
local loadAttempts = 0

while not RayfieldLoaded and loadAttempts < 3 do
    local success, result = pcall(function()
        return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end)
    if success and type(result) == "table" then
        RayfieldLoaded = true
        Rayfield = result
    else
        loadAttempts = loadAttempts + 1
        task.wait(2)
    end
end

if not RayfieldLoaded then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Ошибка",
        Text = "Не удалось загрузить Rayfield. Проверь интернет.",
        Duration = 5
    })
    return
end

-- Создаём окно загрузчика
local Window = Rayfield:CreateWindow({
    Name = "SWILL LAUNCHER v2.0",
    LoadingTitle = "Инициализация...",
    LoadingSubtitle = "Подготовка к загрузке",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local MainTab = Window:CreateTab("Загрузчик", 4483362458)
local LogTab = Window:CreateTab("Логи", 4483362458)

-- Секция управления
MainTab:CreateSection("Управление загрузкой")

-- Создаём лог-область
local logDisplay = LogTab:CreateLabel("Логи будут здесь...")

local logs = {}
local function addLog(msg, color)
    local time = os.date("%H:%M:%S")
    table.insert(logs, 1, "[" .. time .. "] " .. msg)
    if #logs > 30 then table.remove(logs) end
    local text = "=== ПОСЛЕДНИЕ ЛОГИ ===\n"
    for i = 1, math.min(20, #logs) do
        text = text .. logs[i] .. "\n"
    end
    logDisplay:Set(text)
    print("[SWILL] " .. msg)
end

-- Список файлов для загрузки
local files = {
    {name = "part1.lua", url = "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/part1.lua", status = "pending"},
    {name = "part2.lua", url = "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/part2.lua", status = "pending"},
    {name = "part3.lua", url = "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/part3.lua", status = "pending"}
}

local progressBar = nil
local currentFileIndex = 1
local isLoading = false

-- Функция загрузки одного файла
local function loadFile(file)
    addLog("📥 Загрузка: " .. file.name)
    file.status = "loading"
    
    local success, content = pcall(function()
        return game:HttpGet(file.url)
    end)
    
    if success then
        addLog("✅ " .. file.name .. " загружен (" .. string.len(content) .. " байт)")
        file.status = "loaded"
        
        addLog("🔧 Выполнение: " .. file.name)
        local execSuccess, execError = pcall(function()
            loadstring(content)()
        end)
        
        if execSuccess then
            addLog("✅ " .. file.name .. " выполнен")
            file.status = "executed"
            return true
        else
            addLog("❌ Ошибка выполнения " .. file.name .. ": " .. tostring(execError))
            file.status = "error"
            return false
        end
    else
        addLog("❌ Ошибка загрузки " .. file.name .. ": " .. tostring(content))
        file.status = "error"
        return false
    end
end

-- Функция последовательной загрузки
local function startLoading()
    if isLoading then
        addLog("⚠️ Загрузка уже идёт")
        return
    end
    
    isLoading = true
    addLog("🚀 НАЧАЛО ЗАГРУЗКИ")
    addLog("📋 Список файлов: part1.lua, part2.lua, part3.lua")
    
    for i, file in ipairs(files) do
        currentFileIndex = i
        addLog(string.format("📦 Файл %d/%d", i, #files))
        
        local success = loadFile(file)
        if not success then
            addLog("⛔ ЗАГРУЗКА ПРЕРВАНА на файле: " .. file.name)
            addLog("💡 Проверь интернет и ссылки")
            isLoading = false
            return
        end
        task.wait(0.5)
    end
    
    addLog("🎉 ВСЕ ФАЙЛЫ УСПЕШНО ЗАГРУЖЕНЫ И ВЫПОЛНЕНЫ!")
    addLog("⚡ ГУИ должно появиться")
    isLoading = false
end

-- Кнопка запуска
MainTab:CreateButton({
    Name = "🚀 ЗАПУСТИТЬ ЗАГРУЗКУ",
    Callback = function()
        startLoading()
    end
})

-- Кнопка очистки логов
MainTab:CreateButton({
    Name = "🗑️ ОЧИСТИТЬ ЛОГИ",
    Callback = function()
        logs = {}
        logDisplay:Set("Логи очищены")
        addLog("Логи очищены")
    end
})

-- Информационная секция
MainTab:CreateSection("Информация")
MainTab:CreateLabel("SWILL LAUNCHER v2.0")
MainTab:CreateLabel("Загружает 3 части скрипта последовательно")
MainTab:CreateLabel("Автор: SWILL")
MainTab:CreateLabel("F2 - открыть/закрыть меню")

-- Добавляем начальный лог
addLog("⚡ Загрузчик готов")
addLog("📌 Нажми 'ЗАПУСТИТЬ ЗАГРУЗКУ'")
addLog("🔗 Источник: github.com/susces9-lab/Simengey")

print("SWILL LAUNCHER v2.0 loaded. Press F2 to open menu")
