-- SWILL COORDINATE READER & TELEPORTER (Delta Mobile)
-- Считывает координаты игрока и позволяет телепортироваться к ним

wait(1)

local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Удаляем старый GUI
for _, v in pairs(gui:GetChildren()) do
    if v.Name == "CoordinateReader" then v:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoordinateReader"
screenGui.Parent = gui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- ==================================================
-- ОСНОВНОЕ ОКНО
-- ==================================================
local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Заголовок
local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "📍 КООРДИНАТЫ"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = frame
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- ==================================================
-- ТЕКУЩИЕ КООРДИНАТЫ
-- ==================================================
local currentFrame = Instance.new("Frame")
currentFrame.Parent = frame
currentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
currentFrame.Size = UDim2.new(0.9, 0, 0, 80)
currentFrame.Position = UDim2.new(0.05, 0, 0.12, 0)

local currentCorner = Instance.new("UICorner")
currentCorner.CornerRadius = UDim.new(0, 8)
currentCorner.Parent = currentFrame

local currentLabel = Instance.new("TextLabel")
currentLabel.Parent = currentFrame
currentLabel.BackgroundTransparency = 1
currentLabel.Size = UDim2.new(1, 0, 0.4, 0)
currentLabel.Position = UDim2.new(0, 0, 0, 5)
currentLabel.Text = "📍 ТЕКУЩИЕ"
currentLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
currentLabel.Font = Enum.Font.GothamBold
currentLabel.TextScaled = true

local coordText = Instance.new("TextLabel")
coordText.Parent = currentFrame
coordText.BackgroundTransparency = 1
coordText.Size = UDim2.new(1, 0, 0.5, 0)
coordText.Position = UDim2.new(0, 0, 0.4, 0)
coordText.Text = "X: 0 | Y: 0 | Z: 0"
coordText.TextColor3 = Color3.fromRGB(255, 255, 255)
coordText.Font = Enum.Font.GothamBold
coordText.TextScaled = true

-- Обновление координат
local function updateCurrentCoords()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        coordText.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", pos.X, pos.Y, pos.Z)
    else
        coordText.Text = "❌ НЕТ ПЕРСОНАЖА"
    end
end

-- Обновляем каждые 0.1 секунды
spawn(function()
    while true do
        updateCurrentCoords()
        wait(0.1)
    end
end)

-- ==================================================
-- СОХРАНЁННЫЕ КООРДИНАТЫ
-- ==================================================
local savedFrame = Instance.new("Frame")
savedFrame.Parent = frame
savedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
savedFrame.Size = UDim2.new(0.9, 0, 0, 120)
savedFrame.Position = UDim2.new(0.05, 0, 0.45, 0)

local savedCorner = Instance.new("UICorner")
savedCorner.CornerRadius = UDim.new(0, 8)
savedCorner.Parent = savedFrame

local savedLabel = Instance.new("TextLabel")
savedLabel.Parent = savedFrame
savedLabel.BackgroundTransparency = 1
savedLabel.Size = UDim2.new(1, 0, 0.25, 0)
savedLabel.Position = UDim2.new(0, 0, 0, 5)
savedLabel.Text = "💾 СОХРАНЁННЫЕ"
savedLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
savedLabel.Font = Enum.Font.GothamBold
savedLabel.TextScaled = true

local savedCoords = Instance.new("TextLabel")
savedCoords.Parent = savedFrame
savedCoords.BackgroundTransparency = 1
savedCoords.Size = UDim2.new(1, 0, 0.4, 0)
savedCoords.Position = UDim2.new(0, 0, 0.25, 0)
savedCoords.Text = "Нет сохранённых координат"
savedCoords.TextColor3 = Color3.fromRGB(200, 200, 200)
savedCoords.Font = Enum.Font.Gotham
savedCoords.TextScaled = true

local savedPos = nil

-- Кнопка сохранения
local saveBtn = Instance.new("TextButton")
saveBtn.Parent = savedFrame
saveBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
saveBtn.Size = UDim2.new(0.44, 0, 0, 30)
saveBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
saveBtn.Text = "💾 СОХРАНИТЬ"
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextScaled = true

-- Кнопка телепорта
local tpBtn = Instance.new("TextButton")
tpBtn.Parent = savedFrame
tpBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
tpBtn.Size = UDim2.new(0.44, 0, 0, 30)
tpBtn.Position = UDim2.new(0.51, 0, 0.7, 0)
tpBtn.Text = "🚀 ТЕЛЕПОРТ"
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextScaled = true

saveBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedPos = char.HumanoidRootPart.Position
        savedCoords.Text = string.format("📍 X: %.1f | Y: %.1f | Z: %.1f", savedPos.X, savedPos.Y, savedPos.Z)
        savedCoords.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        savedCoords.Text = "❌ НЕТ ПЕРСОНАЖА"
    end
end)

tpBtn.MouseButton1Click:Connect(function()
    if savedPos then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(savedPos)
        end
    else
        savedCoords.Text = "❌ НЕТ СОХРАНЁННЫХ КООРДИНАТ"
        task.wait(1)
        if savedPos then
            savedCoords.Text = string.format("📍 X: %.1f | Y: %.1f | Z: %.1f", savedPos.X, savedPos.Y, savedPos.Z)
        else
            savedCoords.Text = "Нет сохранённых координат"
        end
    end
end)

-- ==================================================
-- КООРДИНАТЫ ДРУГИХ ИГРОКОВ
-- ==================================================
local playersFrame = Instance.new("Frame")
playersFrame.Parent = frame
playersFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
playersFrame.Size = UDim2.new(0.9, 0, 0, 140)
playersFrame.Position = UDim2.new(0.05, 0, 0.7, 0)

local playersCorner = Instance.new("UICorner")
playersCorner.CornerRadius = UDim.new(0, 8)
playersCorner.Parent = playersFrame

local playersLabel = Instance.new("TextLabel")
playersLabel.Parent = playersFrame
playersLabel.BackgroundTransparency = 1
playersLabel.Size = UDim2.new(1, 0, 0.25, 0)
playersLabel.Position = UDim2.new(0, 0, 0, 5)
playersLabel.Text = "👥 КООРДИНАТЫ ИГРОКОВ"
playersLabel.TextColor3 = Color3.fromRGB(138, 43, 226)
playersLabel.Font = Enum.Font.GothamBold
playersLabel.TextScaled = true

local playersList = Instance.new("ScrollingFrame")
playersList.Parent = playersFrame
playersList.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
playersList.Size = UDim2.new(0.95, 0, 0.6, 0)
playersList.Position = UDim2.new(0.025, 0, 0.3, 0)
playersList.CanvasSize = UDim2.new(0, 0, 2, 0)
playersList.ScrollBarThickness = 5

local playersCorner2 = Instance.new("UICorner")
playersCorner2.CornerRadius = UDim.new(0, 6)
playersCorner2.Parent = playersList

local function updatePlayersList()
    for _, child in pairs(playersList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local yPos = 5
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton")
            btn.Parent = playersList
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            btn.Size = UDim2.new(0.98, 0, 0, 35)
            btn.Position = UDim2.new(0.01, 0, 0, yPos)
            btn.Text = ""
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 6)
            btnCorner.Parent = btn
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = btn
            nameLabel.BackgroundTransparency = 1
            nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.Text = plr.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextScaled = true
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local coordLabel = Instance.new("TextLabel")
            coordLabel.Parent = btn
            coordLabel.BackgroundTransparency = 1
            coordLabel.Size = UDim2.new(0.5, 0, 1, 0)
            coordLabel.Position = UDim2.new(0.5, 0, 0, 0)
            coordLabel.Text = "поиск..."
            coordLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            coordLabel.Font = Enum.Font.Gotham
            coordLabel.TextScaled = true
            coordLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            -- Обновляем координаты игрока
            spawn(function()
                while btn and btn.Parent do
                    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local pos = plr.Character.HumanoidRootPart.Position
                        coordLabel.Text = string.format("X:%.0f Y:%.0f Z:%.0f", pos.X, pos.Y, pos.Z)
                        coordLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
                    else
                        coordLabel.Text = "не в игре"
                        coordLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                    end
                    wait(0.5)
                end
            end)
            
            -- Телепорт к игроку
            btn.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local myChar = player.Character
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        myChar.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                    end
                end
            end)
            
            yPos = yPos + 42
        end
    end
    
    playersList.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
end

updatePlayersList()
game:GetService("Players").PlayerAdded:Connect(updatePlayersList)
game:GetService("Players").PlayerRemoving:Connect(updatePlayersList)

-- ==================================================
-- КНОПКА ОБНОВЛЕНИЯ СПИСКА ИГРОКОВ
-- ==================================================
local refreshBtn = Instance.new("TextButton")
refreshBtn.Parent = playersFrame
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
refreshBtn.Size = UDim2.new(0.44, 0, 0, 25)
refreshBtn.Position = UDim2.new(0.05, 0, 0.92, 0)
refreshBtn.Text = "🔄 ОБНОВИТЬ"
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextScaled = true

refreshBtn.MouseButton1Click:Connect(updatePlayersList)

print("✅ COORDINATE READER ЗАГРУЖЕН")
print("📍 Показывает координаты игроков в реальном времени")
print("👆 Нажми на игрока для телепортации")
