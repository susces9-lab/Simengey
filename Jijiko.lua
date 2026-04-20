-- SWILL SIMPLE LOADER
-- Простой загрузчик с GUI и логами

-- Создаём GUI
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "SWILL_Loader"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local frame = Instance.new("Frame")
frame.Parent = gui
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.Size = UDim2.new(0, 350, 0, 250)
frame.Position = UDim2.new(0.5, -175, 0.5, -125)
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "SWILL LOADER"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- Лог область
local logFrame = Instance.new("ScrollingFrame")
logFrame.Parent = frame
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
logText.Text = "⚡ Готов к загрузке\n"
logText.TextColor3 = Color3.fromRGB(255, 255, 255)
logText.Font = Enum.Font.Gotham
logText.TextScaled = true
logText.TextXAlignment = Enum.TextXAlignment.Left
logText.TextWrapped = true

local function addLog(msg)
    local current = logText.Text
    local time = os.date("%H:%M:%S")
    logText.Text = current .. "[" .. time .. "] " .. msg .. "\n"
    logFrame.CanvasSize = UDim2.new(0, 0, 0, #logText.Text:split("\n") * 20)
end

-- Кнопки
local loadBtn = Instance.new("TextButton")
loadBtn.Parent = frame
loadBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
loadBtn.Size = UDim2.new(0.44, 0, 0, 40)
loadBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
loadBtn.Text = "🚀 ЗАГРУЗИТЬ"
loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
loadBtn.Font = Enum.Font.GothamBold
loadBtn.TextScaled = true

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = frame
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Size = UDim2.new(0.44, 0, 0, 40)
closeBtn.Position = UDim2.new(0.51, 0, 0.78, 0)
closeBtn.Text = "✕ ЗАКРЫТЬ"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = frame
statusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.BackgroundTransparency = 0.5
statusLabel.Size = UDim2.new(0.95, 0, 0, 30)
statusLabel.Position = UDim2.new(0.025, 0, 0.88, 0)
statusLabel.Text = "✅ ОЖИДАНИЕ"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextScaled = true

-- Основной скрипт (твой teleport.lua)
local mainScriptUrl = "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/teleport.lua"

loadBtn.MouseButton1Click:Connect(function()
    addLog("🚀 Начинаю загрузку...")
    statusLabel.Text = "⏳ ЗАГРУЗКА..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    addLog("📥 Загрузка с: " .. mainScriptUrl)
    
    local success, content = pcall(function()
        return game:HttpGet(mainScriptUrl)
    end)
    
    if not success then
        addLog("❌ Ошибка загрузки: " .. tostring(content))
        statusLabel.Text = "❌ ОШИБКА"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    addLog("✅ Скрипт загружен (" .. string.len(content) .. " байт)")
    addLog("🔧 Выполнение...")
    
    local execSuccess, execError = pcall(function()
        loadstring(content)()
    end)
    
    if execSuccess then
        addLog("✅ СКРИПТ УСПЕШНО ЗАПУЩЕН!")
        statusLabel.Text = "✅ ГОТОВО"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        wait(2)
        gui:Destroy()
    else
        addLog("❌ Ошибка выполнения: " .. tostring(execError))
        statusLabel.Text = "❌ ОШИБКА"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

addLog("⚡ Загрузчик готов")
addLog("📌 Нажми 'ЗАГРУЗИТЬ'")

print("SWILL SIMPLE LOADER loaded")
