-- SWILL DIAGNOSTIC LAUNCHER
-- Этот скрипт проверит окружение и попытается загрузить твой основной скрипт
wait(1)

local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Удаляем старый GUI диагностики
for _, v in pairs(gui:GetChildren()) do
    if v.Name == "SWILL_Diagnostic" then v:Destroy() end
end

-- Создаём диагностическое окно
local diagGui = Instance.new("ScreenGui")
diagGui.Name = "SWILL_Diagnostic"
diagGui.Parent = gui
diagGui.ResetOnSpawn = false
diagGui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame")
mainFrame.Parent = diagGui
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.Size = UDim2.new(0, 450, 0, 350)
mainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
mainFrame.Active = true
mainFrame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "SWILL DIAGNOSTIC LAUNCHER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- Лог-область
local logFrame = Instance.new("ScrollingFrame")
logFrame.Parent = mainFrame
logFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
logFrame.BackgroundTransparency = 0.5
logFrame.Size = UDim2.new(0.95, 0, 0.55, 0)
logFrame.Position = UDim2.new(0.025, 0, 0.18, 0)
logFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
logFrame.ScrollBarThickness = 8

local logText = Instance.new("TextLabel")
logText.Parent = logFrame
logText.BackgroundTransparency = 1
logText.Size = UDim2.new(1, -20, 1, -20)
logText.Position = UDim2.new(0, 10, 0, 10)
logText.Text = "🔍 Система диагностики запущена\n"
logText.TextColor3 = Color3.fromRGB(255, 255, 255)
logText.Font = Enum.Font.Gotham
logText.TextScaled = true
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextWrapped = true

local function addLog(msg, color)
    local current = logText.Text
    local time = os.date("%H:%M:%S")
    logText.Text = current .. "\n[" .. time .. "] " .. msg
    logFrame.CanvasSize = UDim2.new(0, 0, 0, #logText.Text:split("\n") * 20)
end

-- Кнопки
local startBtn = Instance.new("TextButton")
startBtn.Parent = mainFrame
startBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
startBtn.Size = UDim2.new(0.44, 0, 0, 40)
startBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
startBtn.Text = "🚀 ЗАПУСТИТЬ СКРИПТ"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.Font = Enum.Font.GothamBold
startBtn.TextScaled = true

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = mainFrame
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Size = UDim2.new(0.44, 0, 0, 40)
closeBtn.Position = UDim2.new(0.51, 0, 0.78, 0)
closeBtn.Text = "✕ ЗАКРЫТЬ"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.MouseButton1Click:Connect(function()
    diagGui:Destroy()
end)

-- Статус
local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = mainFrame
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.BackgroundTransparency = 0.5
statusLabel.Size = UDim2.new(0.95, 0, 0, 30)
statusLabel.Position = UDim2.new(0.025, 0, 0.88, 0)
statusLabel.Text = "✅ ОЖИДАНИЕ ЗАПУСКА"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true

-- ==================================================
-- ДИАГНОСТИКА
-- ==================================================
local function runDiagnostic()
    addLog("🔍 Начало диагностики...")
    
    -- 1. Проверка экзекутора
    addLog("📡 Проверка окружения...")
    local executors = {"Delta", "Arceus X", "Fluxus", "KRNL", "Synapse", "ScriptWare"}
    local detected = "Неизвестный"
    for _, ex in pairs(executors) do
        if game:GetService("CoreGui"):FindFirstChild(ex) or 
           game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild(ex) then
            detected = ex
            break
        end
    end
    addLog("🔧 Экзекутор: " .. detected)
    
    -- 2. Проверка интернета
    addLog("🌐 Проверка подключения...")
    local internetOk = false
    local success, err = pcall(function()
        return game:HttpGet("https://google.com", true)
    end)
    if success then
        internetOk = true
        addLog("✅ Интернет доступен")
    else
        addLog("❌ Проблема с интернетом: " .. tostring(err))
    end
    
    -- 3. Проверка Rayfield
    addLog("📦 Проверка библиотеки Rayfield...")
    local rayfieldLoaded = false
    local rayfieldError = nil
    
    success, err = pcall(function()
        return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end)
    
    if success and type(err) == "table" then
        rayfieldLoaded = true
        addLog("✅ Rayfield загружен успешно")
    else
        rayfieldLoaded = false
        rayfieldError = tostring(err)
        addLog("❌ Ошибка загрузки Rayfield: " .. rayfieldError)
    end
    
    -- 4. Проверка создания GUI
    addLog("🖥️ Проверка создания GUI...")
    local guiSuccess = false
    local guiError = nil
    
    success, err = pcall(function()
        local testGui = Instance.new("ScreenGui")
        testGui.Name = "SWILL_Test"
        testGui.Parent = player.PlayerGui
        local testFrame = Instance.new("Frame")
        testFrame.Parent = testGui
        testFrame.Size = UDim2.new(0, 100, 0, 100)
        testFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        task.wait(0.1)
        testGui:Destroy()
        return true
    end)
    
    if success then
        guiSuccess = true
        addLog("✅ GUI создаётся успешно")
    else
        guiError = tostring(err)
        addLog("❌ Ошибка создания GUI: " .. guiError)
    end
    
    -- 5. Финальный вердикт
    addLog("\n📊 РЕЗУЛЬТАТЫ ДИАГНОСТИКИ:")
    if rayfieldLoaded and guiSuccess and internetOk then
        addLog("✅ ВСЁ ГОТОВО К ЗАПУСКУ!")
        statusLabel.Text = "✅ ГОТОВ К ЗАПУСКУ"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        return true
    elseif not rayfieldLoaded then
        addLog("❌ ПРОБЛЕМА: Rayfield не загрузился")
        addLog("💡 РЕШЕНИЕ: Проверь интернет или используй VPN")
        statusLabel.Text = "❌ ОШИБКА: Rayfield"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return false
    elseif not guiSuccess then
        addLog("❌ ПРОБЛЕМА: GUI не создаётся")
        addLog("💡 РЕШЕНИЕ: Попробуй перезапустить экзекутор")
        statusLabel.Text = "❌ ОШИБКА: GUI"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return false
    elseif not internetOk then
        addLog("❌ ПРОБЛЕМА: Нет интернета")
        addLog("💡 РЕШЕНИЕ: Проверь подключение")
        statusLabel.Text = "❌ ОШИБКА: Интернет"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return false
    end
    return false
end

-- ==================================================
-- ЗАГРУЗКА ОСНОВНОГО СКРИПТА
-- ==================================================
local function loadMainScript()
    addLog("🚀 ЗАГРУЗКА ОСНОВНОГО СКРИПТА...")
    statusLabel.Text = "⏳ ЗАГРУЗКА..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    local mainScriptUrl = "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/teleport.lua"
    
    addLog("📥 Загрузка с: " .. mainScriptUrl)
    
    local success, scriptContent = pcall(function()
        return game:HttpGet(mainScriptUrl)
    end)
    
    if not success then
        addLog("❌ НЕ УДАЛОСЬ ЗАГРУЗИТЬ СКРИПТ: " .. tostring(scriptContent))
        statusLabel.Text = "❌ ОШИБКА ЗАГРУЗКИ"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    addLog("✅ Скрипт загружен (" .. string.len(scriptContent) .. " байт)")
    addLog("🔧 Выполнение основного скрипта...")
    
    local execSuccess, execError = pcall(function()
        loadstring(scriptContent)()
    end)
    
    if execSuccess then
        addLog("✅ ОСНОВНОЙ СКРИПТ ЗАГРУЖЕН УСПЕШНО!")
        statusLabel.Text = "✅ ЗАПУЩЕНО"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        wait(2)
        diagGui:Destroy()
    else
        addLog("❌ ОШИБКА ВЫПОЛНЕНИЯ: " .. tostring(execError))
        statusLabel.Text = "❌ ОШИБКА СКРИПТА"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- Обработчик кнопки
startBtn.MouseButton1Click:Connect(function()
    local ready = runDiagnostic()
    if ready then
        loadMainScript()
    else
        addLog("\n⚠️ НЕВОЗМОЖНО ЗАПУСТИТЬ ИЗ-ЗА ОШИБОК")
        statusLabel.Text = "❌ ЗАПУСК НЕВОЗМОЖЕН"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

addLog("⚡ Система готова. Нажми 'ЗАПУСТИТЬ СКРИПТ' для диагностики")
addLog("📌 URL скрипта: github.com/susces9-lab/Simengey")
