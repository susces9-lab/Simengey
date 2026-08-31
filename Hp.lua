-- ==============================================
-- ПРОСТЕНЬКИЙ ЧИТ-ГУИ ДЛЯ DELTA (ТЕЛЕФОН)
-- Восстанавливает 5 HP в секунду
-- ==============================================

local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local gui = player:WaitForChild("PlayerGui")

-- Удаляем старый GUI если есть
for _, v in pairs(gui:GetChildren()) do
    if v.Name == "HealGUI" then v:Destroy() end
end

-- ========== ГЛАВНОЕ ОКНО ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HealGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = gui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 120)
mainFrame.Position = UDim2.new(0.5, -100, 0.7, -60)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.Parent = screenGui
mainFrame.Active = true
mainFrame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
title.Text = "💚 ХИЛЕР 5 HP/сек"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = mainFrame

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.Parent = mainFrame
closeBtn.MouseButton1Click:Connect(function() 
    screenGui:Destroy() 
    healLoop = false
end)

-- Текст статуса
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 30)
statusLabel.Position = UDim2.new(0, 10, 0, 35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "❌ ОСТАНОВЛЕН"
statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextScaled = true
statusLabel.Parent = mainFrame

-- Кнопка вкл/выкл
local healBtn = Instance.new("TextButton")
healBtn.Size = UDim2.new(0.8, 0, 0, 35)
healBtn.Position = UDim2.new(0.1, 0, 0.75, 0)
healBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
healBtn.Text = "▶ ВКЛЮЧИТЬ"
healBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
healBtn.Font = Enum.Font.GothamBold
healBtn.TextScaled = true
healBtn.Parent = mainFrame

local healCorner = Instance.new("UICorner")
healCorner.CornerRadius = UDim.new(0, 8)
healCorner.Parent = healBtn

-- ========== ЛОГИКА ХИЛА (5 HP В СЕКУНДУ) ==========
local healLoop = false
local healThread = nil

local function stopHeal()
    healLoop = false
    if healThread then
        task.cancel(healThread)
        healThread = nil
    end
    statusLabel.Text = "❌ ОСТАНОВЛЕН"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    healBtn.Text = "▶ ВКЛЮЧИТЬ"
    healBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
end

local function startHeal()
    if healLoop then return end
    healLoop = true
    statusLabel.Text = "✅ РАБОТАЕТ... (5 HP/сек)"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    healBtn.Text = "⏹ ВЫКЛЮЧИТЬ"
    healBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

    healThread = task.spawn(function()
        while healLoop do
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                if hum.Health < hum.MaxHealth then
                    hum.Health = hum.Health + 5 -- ← ИЗМЕНЕНИЕ ЗДЕСЬ: 5 HP
                end
            end
            task.wait(1) -- 1 секунда
        end
    end)
end

-- Обработчик кнопки
healBtn.MouseButton1Click:Connect(function()
    if healLoop then
        stopHeal()
    else
        startHeal()
    end
end)

-- Остановка если персонаж умер
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    if healLoop then
        stopHeal()
    end
end)

-- Безопасный выход
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if healLoop then
        stopHeal()
    end
end)

print("💚 Хилер 5 HP/сек загружен! Нажми кнопку для запуска.")
