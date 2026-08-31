-- ==============================================
-- ПРОСТОЙ ПРИЦЕЛ-КРЕСТИК ДЛЯ DELTA (Android)
-- Белый, маленький, можно передвигать пальцем
-- ==============================================

local player = game:GetService("Players").LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Удаляем старый прицел если есть
for _, v in pairs(gui:GetChildren()) do
    if v.Name == "CrosshairGUI" then v:Destroy() end
end

-- ========== СОЗДАЁМ GUI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CrosshairGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = gui

-- ========== ОСНОВНАЯ РАМКА (перетаскиваемая) ==========
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 40, 0, 40) -- Размер зоны для касания
frame.Position = UDim2.new(0.5, -20, 0.5, -20) -- По центру
frame.BackgroundTransparency = 1 -- Полностью прозрачная
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true -- Вот эта волшебная строчка! Позволяет перетаскивать

-- ========== ГОРИЗОНТАЛЬНАЯ ПАЛОЧКА КРЕСТИКА ==========
local hLine = Instance.new("Frame")
hLine.Size = UDim2.new(0, 20, 0, 2) -- Длина 20 пикселей, толщина 2
hLine.Position = UDim2.new(0.5, -10, 0.5, -1) -- Центрируем
hLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Белый
hLine.BackgroundTransparency = 0
hLine.Parent = frame

-- ========== ВЕРТИКАЛЬНАЯ ПАЛОЧКА КРЕСТИКА ==========
local vLine = Instance.new("Frame")
vLine.Size = UDim2.new(0, 2, 0, 20) -- Толщина 2, длина 20
vLine.Position = UDim2.new(0.5, -1, 0.5, -10) -- Центрируем
vLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Белый
vLine.BackgroundTransparency = 0
vLine.Parent = frame

print("✅ Прицел-крестик создан! Перетащи его пальцем в любое место.")
