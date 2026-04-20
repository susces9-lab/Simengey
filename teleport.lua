-- SWILL TELEPORT TO PLAYER [Rayfield UI]
-- Показывает список игроков на сервере и телепортирует к выбранному
-- С сортировкой ников по алфавиту и регулировкой скорости бега

-- Подключаем библиотеку Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Ждём загрузки персонажа игрока
repeat wait() until game.Players.LocalPlayer.Character
wait(1)

local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- Переменные
local selectedPlayer = nil
local currentSpeed = 16

-- Функция установки скорости
local function setSpeed(value)
    currentSpeed = value
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end

-- Создаём окно Rayfield
local Window = Rayfield:CreateWindow({
    Name = "SWILL TELEPORTER",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by SWILL",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SWILL_HUB",
        FileName = "Teleporter_Settings"
    },
    KeySystem = false,
    KeySettings = {
        Title = "Введите ключ",
        Subtitle = "Ключ для доступа",
        Note = "Ключ можно найти в Discord",
        Key = {"SWILL2026"}
    }
})

-- Создаём вкладки
local MainTab = Window:CreateTab("Телепорт", 4483362458)
local SettingsTab = Window:CreateTab("Настройки", 4483362458)

-- ==================================================
-- ОСНОВНАЯ ВКЛАДКА (СПИСОК ИГРОКОВ)
-- ==================================================

-- Создаём секцию для списка игроков
local PlayersSection = MainTab:CreateSection("Список игроков")

-- Переменная для хранения Dropdown
local playerDropdown = nil

-- Функция обновления списка игроков
local function updatePlayerList()
    local playersList = game:GetService("Players"):GetPlayers()
    local playerNames = {}
    
    for _, plr in pairs(playersList) do
        if plr ~= player then
            table.insert(playerNames, plr.Name)
        end
    end
    
    -- Сортируем по алфавиту
    table.sort(playerNames, function(a, b)
        return a:lower() < b:lower()
    end)
    
    if #playerNames == 0 then
        table.insert(playerNames, "НЕТ ИГРОКОВ")
    end
    
    -- Если Dropdown уже существует, обновляем его опции
    if playerDropdown then
        playerDropdown:Refresh(playerNames, true)
    else
        -- Создаём Dropdown в первый раз
        playerDropdown = MainTab:CreateDropdown({
            Name = "Выбери игрока",
            Options = playerNames,
            CurrentOption = {"НЕТ ИГРОКОВ"},
            Flag = "PlayerSelect",
            Callback = function(option)
                if option ~= "НЕТ ИГРОКОВ" then
                    for _, plr in pairs(playersList) do
                        if plr.Name == option then
                            selectedPlayer = plr
                            break
                        end
                    end
                else
                    selectedPlayer = nil
                end
            end
        })
    end
end

-- Кнопка обновления списка
MainTab:CreateButton({
    Name = "Обновить список игроков",
    Callback = function()
        updatePlayerList()
        Rayfield:Notify({
            Title = "Обновлено",
            Content = "Список игроков обновлён",
            Duration = 1.5
        })
    end
})

-- Кнопка телепортации
MainTab:CreateButton({
    Name = "ТЕЛЕПОРТ К ВЫБРАННОМУ",
    Callback = function()
        if not selectedPlayer then
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Сначала выбери игрока!",
                Duration = 2
            })
            return
        end
        
        if not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Игрок недоступен!",
                Duration = 2
            })
            return
        end
        
        local myChar = player.Character
        if not myChar then
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Нет персонажа!",
                Duration = 2
            })
            return
        end
        
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if not myRoot or not targetRoot then
            Rayfield:Notify({
                Title = "Ошибка",
                Content = "Нет точки телепорта!",
                Duration = 2
            })
            return
        end
        
        local targetPos = targetRoot.Position + Vector3.new(0, 3, 0)
        myRoot.CFrame = CFrame.new(targetPos)
        
        Rayfield:Notify({
            Title = "Телепорт",
            Content = "Ты телепортировался к " .. selectedPlayer.Name,
            Duration = 2
        })
    end
})

-- ==================================================
-- ВКЛАДКА НАСТРОЙКИ
-- ==================================================

local SettingsSection = SettingsTab:CreateSection("Настройки персонажа")

-- Ползунок для изменения скорости
SettingsTab:CreateSlider({
    Name = "Скорость бега",
    Range = {16, 300},
    Increment = 1,
    Suffix = "WalkSpeed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(value)
        setSpeed(value)
        Rayfield:Notify({
            Title = "Скорость",
            Content = "Установлена: " .. value,
            Duration = 1
        })
    end
})

-- Кнопка сброса скорости
SettingsTab:CreateButton({
    Name = "Сбросить скорость (16)",
    Callback = function()
        setSpeed(16)
        Rayfield:Notify({
            Title = "Скорость сброшена",
            Content = "WalkSpeed = 16",
            Duration = 1.5
        })
    end
})

-- Секция "Об игре"
local InfoSection = SettingsTab:CreateSection("Информация")

SettingsTab:CreateLabel("SWILL TELEPORTER v1.0")
SettingsTab:CreateLabel("F2 - открыть/закрыть меню")
SettingsTab:CreateLabel("Совместимо с Delta Mobile")

-- ==================================================
-- ОБНОВЛЕНИЕ ПРИ ПОЯВЛЕНИИ НОВЫХ ИГРОКОВ
-- ==================================================
game:GetService("Players").PlayerAdded:Connect(function()
    updatePlayerList()
end)

game:GetService("Players").PlayerRemoving:Connect(function()
    updatePlayerList()
end)

-- ==================================================
-- ПЕРЕСОЗДАНИЕ ГУИ ПРИ РЕСПАВНЕ ПЕРСОНАЖА
-- ==================================================
player.CharacterAdded:Connect(function(char)
    wait(0.5)
    setSpeed(currentSpeed)
end)

-- ==================================================
-- ГОРЯЧАЯ КЛАВИША F2 ДЛЯ ОТКРЫТИЯ/ЗАКРЫТИЯ
-- ==================================================
userInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F2 then
        Rayfield:Toggle()
    end
end)

-- ==================================================
-- ПЕРВОНАЧАЛЬНАЯ ИНИЦИАЛИЗАЦИЯ
-- ==================================================
updatePlayerList()

-- Устанавливаем стандартную скорость
setSpeed(16)

print("SWILL Teleporter loaded. Press F2 to open Rayfield menu")
