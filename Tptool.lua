-- Подключаем сервисы
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Функция для телепортации к выбранному игроку
local function TeleportToPlayer(TargetPlayer)
    if not TargetPlayer or not TargetPlayer.Character then
        return false
    end
    
    local TargetHRP = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local LocalChar = LocalPlayer.Character
    
    if TargetHRP and LocalChar then
        local LocalHRP = LocalChar:FindFirstChild("HumanoidRootPart")
        if LocalHRP then
            -- Телепортируем игрока к цели (с небольшим смещением 2 студии)
            LocalHRP.CFrame = TargetHRP.CFrame * CFrame.new(0, 0, 2)
            return true
        end
    end
    return false
end

-- Создаём GUI для выбора игрока
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TeleportGUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0.5, -125, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "Телепорт к игроку"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.Parent = Frame

-- Список игроков (ScrollingFrame)
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, -10, 1, -50)
PlayerList.Position = UDim2.new(0, 5, 0, 45)
PlayerList.BackgroundTransparency = 1
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.ScrollBarThickness = 5
PlayerList.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = PlayerList
UIListLayout.SortOrder = Enum.SortOrder.Name
UIListLayout.Padding = UDim.new(0, 5)

-- Кнопка для открытия/закрытия GUI
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(1, -60, 0, 10)
ToggleButton.Text = "TP"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 20
ToggleButton.Parent = ScreenGui

-- Показывать/скрывать GUI
local guiVisible = true
ToggleButton.MouseButton1Click:Connect(function()
    guiVisible = not guiVisible
    Frame.Visible = guiVisible
end)

-- Функция обновления списка игроков
local function UpdatePlayerList()
    -- Очищаем старые кнопки
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local players = Players:GetPlayers()
    local yOffset = 0
    
    for _, otherPlayer in pairs(players) do
        if otherPlayer ~= LocalPlayer then
            local PlayerButton = Instance.new("TextButton")
            PlayerButton.Size = UDim2.new(1, 0, 0, 35)
            PlayerButton.Text = otherPlayer.Name
            PlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            PlayerButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            PlayerBackward:Connect(function()
                TeleportToPlayer(otherPlayer)
                -- Опционально: скрыть GUI после телепорта
                -- Frame.Visible = false
                -- guiVisible = false
            end)
            PlayerButton.Parent = PlayerList
        end
    end
    
    -- Обновляем размер Canvas
    local childrenCount = #PlayerList:GetChildren()
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, childrenCount * 40)
end

-- Обновляем список при добавлении/удалении игроков
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- Первоначальное обновление
UpdatePlayerList()

print("Скрипт телепортации загружен! Нажми на кнопку TP для открытия списка.")
