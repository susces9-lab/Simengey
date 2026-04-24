-- SWILL PERFECT CROSSHAIR - ДЛЯ DELTA MOBILE
-- ТОЧНЫЙ ПРИЦЕЛ ПО ЦЕНТРУ ЭКРАНА
wait(1)

local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Удаляем старый прицел
for _, v in pairs(gui:GetChildren()) do
    if v.Name == "SwillCrosshair" then v:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SwillCrosshair"
screenGui.Parent = gui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ==================================================
-- ОСНОВНОЙ ПРИЦЕЛ (КРУГ)
-- ==================================================
-- Внешний круг
local outerCircle = Instance.new("Frame")
outerCircle.Parent = screenGui
outerCircle.BackgroundTransparency = 1
outerCircle.Size = UDim2.new(0, 30, 0, 30)
outerCircle.Position = UDim2.new(0.5, -15, 0.5, -15)

local outerCircleImg = Instance.new("ImageLabel")
outerCircleImg.Parent = outerCircle
outerCircleImg.BackgroundTransparency = 1
outerCircleImg.Size = UDim2.new(1, 0, 1, 0)
outerCircleImg.Image = "rbxassetid://9247430365" -- Круглый прицел
outerCircleImg.ImageColor3 = Color3.fromRGB(255, 255, 255)
outerCircleImg.ImageTransparency = 0.3

-- ==================================================
-- ТОЧКА В ЦЕНТРЕ (КРАСНАЯ)
-- ==================================================
local dot = Instance.new("Frame")
dot.Parent = screenGui
dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
dot.Size = UDim2.new(0, 3, 0, 3)
dot.Position = UDim2.new(0.5, -1.5, 0.5, -1.5)
dot.BorderSizePixel = 0

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = dot

-- ==================================================
-- КРЕСТИК (ДОПОЛНИТЕЛЬНО)
-- ==================================================
local crosshair = Instance.new("Frame")
crosshair.Parent = screenGui
crosshair.BackgroundTransparency = 1
crosshair.Size = UDim2.new(0, 20, 0, 20)
crosshair.Position = UDim2.new(0.5, -10, 0.5, -10)

-- Верхняя линия
local lineTop = Instance.new("Frame")
lineTop.Parent = crosshair
lineTop.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
lineTop.Size = UDim2.new(0, 2, 0, 8)
lineTop.Position = UDim2.new(0.5, -1, 0, -8)

-- Нижняя линия
local lineBottom = Instance.new("Frame")
lineBottom.Parent = crosshair
lineBottom.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
lineBottom.Size = UDim2.new(0, 2, 0, 8)
lineBottom.Position = UDim2.new(0.5, -1, 1, 0)

-- Левая линия
local lineLeft = Instance.new("Frame")
lineLeft.Parent = crosshair
lineLeft.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
lineLeft.Size = UDim2.new(0, 8, 0, 2)
lineLeft.Position = UDim2.new(0, -8, 0.5, -1)

-- Правая линия
local lineRight = Instance.new("Frame")
lineRight.Parent = crosshair
lineRight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
lineRight.Size = UDim2.new(0, 8, 0, 2)
lineRight.Position = UDim2.new(1, 0, 0.5, -1)

-- ==================================================
-- КНОПКА ВКЛЮЧЕНИЯ/ВЫКЛЮЧЕНИЯ ПРИЦЕЛА
-- ==================================================
local toggleBtn = Instance.new("TextButton")
toggleBtn.Parent = screenGui
toggleBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
toggleBtn.Text = "➕"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextScaled = true
toggleBtn.Draggable = true

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = toggleBtn

-- ==================================================
-- МЕНЮ НАСТРОЕК
-- ==================================================
local settingsFrame = Instance.new("Frame")
settingsFrame.Parent = screenGui
settingsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
settingsFrame.Size = UDim2.new(0, 250, 0, 200)
settingsFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
settingsFrame.Visible = false
settingsFrame.Active = true
settingsFrame.Draggable = true

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 12)
settingsCorner.Parent = settingsFrame

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Parent = settingsFrame
settingsTitle.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
settingsTitle.Size = UDim2.new(1, 0, 0, 35)
settingsTitle.Text = "НАСТРОЙКИ ПРИЦЕЛА"
settingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextScaled = true

local closeSettings = Instance.new("TextButton")
closeSettings.Parent = settingsFrame
closeSettings.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeSettings.Size = UDim2.new(0, 25, 0, 25)
closeSettings.Position = UDim2.new(1, -30, 0, 5)
closeSettings.Text = "X"
closeSettings.TextColor3 = Color3.fromRGB(255, 255, 255)
closeSettings.Font = Enum.Font.GothamBold
closeSettings.TextScaled = true
closeSettings.MouseButton1Click:Connect(function()
    settingsFrame.Visible = false
end)

-- Ползунок для изменения размера прицела
local sizeLabel = Instance.new("TextLabel")
sizeLabel.Parent = settingsFrame
sizeLabel.BackgroundTransparency = 1
sizeLabel.Size = UDim2.new(0.9, 0, 0, 25)
sizeLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
sizeLabel.Text = "Размер прицела: 20"
sizeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
sizeLabel.Font = Enum.Font.GothamBold
sizeLabel.TextScaled = true

local sizeSlider = Instance.new("Frame")
sizeSlider.Parent = settingsFrame
sizeSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
sizeSlider.Size = UDim2.new(0.8, 0, 0, 10)
sizeSlider.Position = UDim2.new(0.1, 0, 0.4, 0)

local sizeFill = Instance.new("Frame")
sizeFill.Parent = sizeSlider
sizeFill.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
sizeFill.Size = UDim2.new(0.5, 0, 1, 0)

local sizeValue = 20

sizeSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        local pos = input.Position.X - sizeSlider.AbsolutePosition.X
        local percent = math.clamp(pos / sizeSlider.AbsoluteSize.X, 0, 1)
        sizeValue = math.floor(10 + percent * 40)
        sizeFill.Size = UDim2.new(percent, 0, 1, 0)
        sizeLabel.Text = "Размер прицела: " .. sizeValue
        crosshair.Size = UDim2.new(0, sizeValue, 0, sizeValue)
        outerCircle.Size = UDim2.new(0, sizeValue + 10, 0, sizeValue + 10)
    end
end)

-- Ползунок для изменения цвета
local colorLabel = Instance.new("TextLabel")
colorLabel.Parent = settingsFrame
colorLabel.BackgroundTransparency = 1
colorLabel.Size = UDim2.new(0.9, 0, 0, 25)
colorLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
colorLabel.Text = "Цвет: БЕЛЫЙ"
colorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
colorLabel.Font = Enum.Font.GothamBold
colorLabel.TextScaled = true

local colors = {"БЕЛЫЙ", "КРАСНЫЙ", "СИНИЙ", "ЗЕЛЁНЫЙ", "ЖЁЛТЫЙ", "ФИОЛЕТОВЫЙ"}
local colorIndex = 1
local colorValues = {
    Color3.fromRGB(255, 255, 255), -- белый
    Color3.fromRGB(255, 0, 0),     -- красный
    Color3.fromRGB(0, 100, 255),   -- синий
    Color3.fromRGB(0, 255, 0),     -- зелёный
    Color3.fromRGB(255, 255, 0),   -- жёлтый
    Color3.fromRGB(138, 43, 226),  -- фиолетовый
}

local colorBtn = Instance.new("TextButton")
colorBtn.Parent = settingsFrame
colorBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
colorBtn.Size = UDim2.new(0.8, 0, 0, 35)
colorBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
colorBtn.Text = "СМЕНИТЬ ЦВЕТ"
colorBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
colorBtn.Font = Enum.Font.GothamBold
colorBtn.TextScaled = true

colorBtn.MouseButton1Click:Connect(function()
    colorIndex = colorIndex % #colors + 1
    colorLabel.Text = "Цвет: " .. colors[colorIndex]
    local newColor = colorValues[colorIndex]
    
    lineTop.BackgroundColor3 = newColor
    lineBottom.BackgroundColor3 = newColor
    lineLeft.BackgroundColor3 = newColor
    lineRight.BackgroundColor3 = newColor
    outerCircleImg.ImageColor3 = newColor
    dot.BackgroundColor3 = colorIndex == 2 and Color3.fromRGB(255, 0, 0) or newColor
end)

-- Кнопка сброса
local resetBtn = Instance.new("TextButton")
resetBtn.Parent = settingsFrame
resetBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
resetBtn.Size = UDim2.new(0.8, 0, 0, 30)
resetBtn.Position = UDim2.new(0.1, 0, 0.85, 0)
resetBtn.Text = "СБРОСИТЬ НАСТРОЙКИ"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextScaled = true

resetBtn.MouseButton1Click:Connect(function()
    sizeValue = 20
    sizeFill.Size = UDim2.new(0.5, 0, 1, 0)
    sizeLabel.Text = "Размер прицела: 20"
    crosshair.Size = UDim2.new(0, 20, 0, 20)
    outerCircle.Size = UDim2.new(0, 30, 0, 30)
    
    colorIndex = 1
    colorLabel.Text = "Цвет: БЕЛЫЙ"
    local white = Color3.fromRGB(255, 255, 255)
    lineTop.BackgroundColor3 = white
    lineBottom.BackgroundColor3 = white
    lineLeft.BackgroundColor3 = white
    lineRight.BackgroundColor3 = white
    outerCircleImg.ImageColor3 = white
    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
end)

-- ==================================================
-- ОБРАБОТЧИК КНОПКИ
-- ==================================================
local crosshairEnabled = true

toggleBtn.MouseButton1Click:Connect(function()
    if settingsFrame.Visible then
        settingsFrame.Visible = false
        toggleBtn.Text = "➕"
    else
        settingsFrame.Visible = true
        toggleBtn.Text = "⚙️"
    end
end)

-- Долгое нажатие для включения/выключения прицела
local pressTime = 0
toggleBtn.MouseButton1Down:Connect(function()
    pressTime = tick()
end)

toggleBtn.MouseButton1Up:Connect(function()
    if tick() - pressTime > 0.5 then
        crosshairEnabled = not crosshairEnabled
        crosshair.Visible = crosshairEnabled
        outerCircle.Visible = crosshairEnabled
        dot.Visible = crosshairEnabled
        toggleBtn.Text = crosshairEnabled and "➕" or "🔴"
    end
end)

print("✅ SWILL PERFECT CROSSHAIR ЗАГРУЖЕН")
print("👆 Нажми на кнопку для настроек")
print("🔴 Зажми кнопку на 0.5 сек чтобы выключить прицел")
