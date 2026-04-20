-- SWILL TELEPORT TO PLAYER [Delta Mobile]
-- Показывает список игроков на сервере и телепортирует к выбранному
-- С функцией сворачивания в маленький кубик и сортировкой ников по алфавиту
wait(2)

local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local userInput = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")

-- Удаляем старый GUI если есть
for _, v in pairs(gui:GetChildren()) do
    if v.Name == "PlayerTeleporter" then v:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerTeleporter"
screenGui.Parent = gui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- ==================================================
-- СОСТОЯНИЯ
-- ==================================================
local isMinimized = false

-- ==================================================
-- МАЛЕНЬКИЙ КУБИК (свёрнутое состояние)
-- ==================================================
local miniCube = Instance.new("TextButton")
miniCube.Parent = screenGui
miniCube.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
miniCube.Size = UDim2.new(0, 50, 0, 50)
miniCube.Position = UDim2.new(0, 20, 0.5, -25)
miniCube.Text = "👥"
miniCube.TextColor3 = Color3.fromRGB(255, 255, 255)
miniCube.Font = Enum.Font.GothamBold
miniCube.TextScaled = true
miniCube.Visible = true
miniCube.Draggable = true

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 10)
miniCorner.Parent = miniCube

-- ==================================================
-- ГЛАВНОЕ ОКНО (развёрнутое состояние)
-- ==================================================
local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BackgroundTransparency = 0.1
frame.Size = UDim2.new(0, 250, 0, 350)
frame.Position = UDim2.new(0.5, -125, 0.5, -175)
frame.Visible = false
frame.Active = true
frame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "👥 ТЕЛЕПОРТ К ИГРОКУ"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- Кнопка СВЕРНУТЬ (в кубик)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = frame
minimizeBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -65, 0, 5)
minimizeBtn.Text = "➖"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextScaled = true
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = true
    frame.Visible = false
    miniCube.Visible = true
end)

-- Кнопка ЗАКРЫТЬ (полное закрытие)
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = frame
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextScaled = true
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Разворачивание из кубика
miniCube.MouseButton1Click:Connect(function()
    isMinimized = false
    miniCube.Visible = false
    frame.Visible = true
    updatePlayerList() -- обновляем список при открытии
end)

-- ==================================================
-- СПИСОК ИГРОКОВ
-- ==================================================
local playerList = Instance.new("ScrollingFrame")
playerList.Parent = frame
playerList.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
playerList.Size = UDim2.new(0.9, 0, 0.6, 0)
playerList.Position = UDim2.new(0.05, 0, 0.15, 0)
playerList.CanvasSize = UDim2.new(0, 0, 2, 0)
playerList.ScrollBarThickness = 8

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 10)
listCorner.Parent = playerList

-- Статус
local status = Instance.new("TextLabel")
status.Parent = frame
status.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
status.BackgroundTransparency = 0.5
status.Size = UDim2.new(0.9, 0, 0, 35)
status.Position = UDim2.new(0.05, 0, 0.8, 0)
status.Text = "🤴PLAYER"
status.TextColor3 = Color3.fromRGB(255, 255, 0)
status.Font = Enum.Font.GothamBold
status.TextScaled = true

-- Кнопка обновления
local refreshBtn = Instance.new("TextButton")
refreshBtn.Parent = frame
refreshBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
refreshBtn.Size = UDim2.new(0.44, 0, 0, 35)
refreshBtn.Position = UDim2.new(0.05, 0, 0.88, 0)
refreshBtn.Text = "⛄ ОБНОВИТЬ"
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextScaled = true

-- Кнопка телепорта
local tpBtn = Instance.new("TextButton")
tpBtn.Parent = frame
tpBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
tpBtn.Size = UDim2.new(0.44, 0, 0, 35)
tpBtn.Position = UDim2.new(0.51, 0, 0.88, 0)
tpBtn.Text = "⚡ ТЕЛЕПОРТ"
tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextScaled = true

-- Переменные
local selectedPlayer = nil
local playerButtons = {}

-- Обновление списка игроков (с сортировкой по алфавиту)
local function updatePlayerList()
    -- Очищаем старые кнопки
    for _, btn in pairs(playerButtons) do
        btn:Destroy()
    end
    playerButtons = {}
    
    local yPos = 5
    local playersList = game:GetService("Players"):GetPlayers()
    
    -- СОРТИРУЕМ ПО АЛФАВИТУ
    local sortedPlayers = {}
    for _, plr in pairs(playersList) do
        if plr ~= player then
            table.insert(sortedPlayers, plr)
        end
    end
    table.sort(sortedPlayers, function(a, b)
        return a.Name:lower() < b.Name:lower()
    end)
    
    for _, plr in ipairs(sortedPlayers) do
        local btn = Instance.new("TextButton")
        btn.Parent = playerList
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.Size = UDim2.new(0.98, 0, 0, 45)
        btn.Position = UDim2.new(0.01, 0, 0, yPos)
        btn.Text = ""
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn
        
        -- Имя игрока
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = btn
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(0.7, 0, 1, 0)
        nameLabel.Position = UDim2.new(0, 10, 0, 0)
        nameLabel.Text = plr.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextScaled = true
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        -- Уровень (если есть leaderstats)
        local levelLabel = Instance.new("TextLabel")
        levelLabel.Parent = btn
        levelLabel.BackgroundTransparency = 1
        levelLabel.Size = UDim2.new(0.3, -10, 1, 0)
        levelLabel.Position = UDim2.new(0.7, 0, 0, 0)
        levelLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        levelLabel.Font = Enum.Font.Gotham
        levelLabel.TextScaled = true
        levelLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local stats = plr:FindFirstChild("leaderstats")
        if stats then
            local level = stats:FindFirstChild("Level")
            if level then
                levelLabel.Text = "Lv." .. level.Value
            else
                levelLabel.Text = "Lv.? "
            end
        else
            levelLabel.Text = ""
        end
        
        -- Выбор игрока
        btn.MouseButton1Click:Connect(function()
            selectedPlayer = plr
            status.Text = "🎯 ВЫБРАН: " .. plr.Name
            status.TextColor3 = Color3.fromRGB(0, 255, 0)
            -- Подсветка выбранного
            for _, b in pairs(playerButtons) do
                b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            end
            btn.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
        end)
        
        table.insert(playerButtons, btn)
        yPos = yPos + 50
    end
    
    if #playerButtons == 0 then
        local noBtn = Instance.new("TextButton")
        noBtn.Parent = playerList
        noBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        noBtn.Size = UDim2.new(0.98, 0, 0, 45)
        noBtn.Position = UDim2.new(0.01, 0, 0, yPos)
        noBtn.Text = "❌ НЕТ ИГРОКОВ"
        noBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        noBtn.Font = Enum.Font.GothamBold
        noBtn.TextScaled = true
        table.insert(playerButtons, noBtn)
        yPos = yPos + 50
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, yPos + 10)
end

-- Телепортация
local function teleportToPlayer(target)
    if not target or not target.Character then
        status.Text = "❌ ИГРОК НЕДОСТУПЕН"
        status.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then
        status.Text = "❌ НЕТ ТОЧКИ ТЕЛЕПОРТА"
        status.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    local myChar = player.Character
    if not myChar then
        status.Text = "❌ НЕТ ПЕРСОНАЖА"
        status.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        status.Text = "❌ НЕТ ТОЧКИ ТЕЛЕПОРТА"
        status.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    status.Text = "⏳ ТЕЛЕПОРТАЦИЯ..."
    status.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    local targetPos = targetRoot.Position + Vector3.new(0, 3, 0)
    myRoot.CFrame = CFrame.new(targetPos)
    
    status.Text = "✅ ТЕЛЕПОРТ К " .. target.Name
    status.TextColor3 = Color3.fromRGB(0, 255, 0)
    
    wait(2)
    if selectedPlayer then
        status.Text = "🎯 ВЫБРАН: " .. selectedPlayer.Name
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        status.Text = "👆 ВЫБЕРИ ИГРОКА"
        status.TextColor3 = Color3.fromRGB(255, 255, 0)
    end
end

-- Обработчики кнопок
refreshBtn.MouseButton1Click:Connect(updatePlayerList)

tpBtn.MouseButton1Click:Connect(function()
    if selectedPlayer then
        teleportToPlayer(selectedPlayer)
    else
        status.Text = "❌ СНАЧАЛА ВЫБЕРИ ИГРОКА"
        status.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- Горячая клавиша F2 для открытия/закрытия
userInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F2 then
        if frame.Visible then
            isMinimized = true
            frame.Visible = false
            miniCube.Visible = true
        else
            isMinimized = false
            miniCube.Visible = false
            frame.Visible = true
            updatePlayerList()
        end
    end
end)

-- Первоначальное обновление
updatePlayerList()
frame.Visible = false
miniCube.Visible = true

print("✅ Player Teleporter загружен! Нажми F2 для открытия, кнопка ➖ сворачивает в кубик")
