-- SWILL ULTIMATE HUB - ОБЫЧНОЕ GUI (БЕЗ RAYFIELD)
-- Все функции: телепорт, ESP, полёт, noclip, скорость, невидимость, god mode и т.д.

wait(1)
local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Удаляем старый GUI
for _, v in pairs(gui:GetChildren()) do
    if v.Name == "SwillHub" then v:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SwillHub"
screenGui.Parent = gui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- ==================================================
-- ОСНОВНОЕ ОКНО
-- ==================================================
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.BackgroundTransparency = 0.1

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "SWILL ULTIMATE HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = mainFrame
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
-- ВКЛАДКИ
-- ==================================================
local tabContainer = Instance.new("Frame")
tabContainer.Parent = mainFrame
tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
tabContainer.Size = UDim2.new(1, 0, 0, 30)
tabContainer.Position = UDim2.new(0, 0, 0, 35)

local tabs = {"Телепорт", "Визуал", "Движение", "Хил"}
local activeTab = 1
local tabButtons = {}
local contentFrames = {}

local function showTab(index)
    for i, frame in pairs(contentFrames) do
        frame.Visible = (i == index)
    end
    for i, btn in pairs(tabButtons) do
        btn.BackgroundColor3 = (i == index) and Color3.fromRGB(0, 191, 255) or Color3.fromRGB(40, 40, 50)
    end
end

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Parent = tabContainer
    btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0, 191, 255) or Color3.fromRGB(40, 40, 50)
    btn.Size = UDim2.new(0.25, -1, 1, 0)
    btn.Position = UDim2.new((i-1)*0.25, 1, 0, 0)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    btn.MouseButton1Click:Connect(function()
        activeTab = i
        showTab(i)
    end)
    tabButtons[i] = btn
    
    local content = Instance.new("ScrollingFrame")
    content.Parent = mainFrame
    content.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    content.Size = UDim2.new(1, -10, 1, -85)
    content.Position = UDim2.new(0, 5, 0, 70)
    content.CanvasSize = UDim2.new(0, 0, 2, 0)
    content.ScrollBarThickness = 6
    content.Visible = (i == 1)
    contentFrames[i] = content
end

-- ==================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ==================================================
local function createButton(parent, text, color, y, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.BackgroundColor3 = color
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createToggle(parent, text, color, y, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.Size = UDim2.new(0.9, 0, 0, 35)
    frame.Position = UDim2.new(0.05, 0, 0, y)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local toggle = Instance.new("TextButton")
    toggle.Parent = frame
    toggle.BackgroundColor3 = color
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -60, 0.5, -12.5)
    toggle.Text = "ВЫКЛ"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextScaled = true
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggle
    
    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.Text = state and "ВКЛ" or "ВЫКЛ"
        toggle.BackgroundColor3 = state and Color3.fromRGB(50, 205, 50) or color
        callback(state)
    end)
    return frame
end

local function createSlider(parent, text, min, max, default, y, callback)
    local frame = Instance.new("Frame")
    frame.Parent = parent
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.Size = UDim2.new(0.9, 0, 0, 60)
    frame.Position = UDim2.new(0.05, 0, 0, y)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -10, 0, 20)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = frame
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextScaled = true
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Parent = frame
    sliderFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    sliderFrame.Size = UDim2.new(0.9, 0, 0, 10)
    sliderFrame.Position = UDim2.new(0.05, 0, 0.7, 0)
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderFrame
    
    local fill = Instance.new("Frame")
    fill.Parent = sliderFrame
    fill.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local value = default
    local dragging = false
    
    local dragBtn = Instance.new("TextButton")
    dragBtn.Parent = sliderFrame
    dragBtn.BackgroundTransparency = 1
    dragBtn.Size = UDim2.new(1, 0, 1, 0)
    dragBtn.Text = ""
    
    dragBtn.MouseButton1Down:Connect(function() dragging = true end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            local mousePos = game:GetService("UserInputService"):GetMouseLocation()
            local sliderPos = sliderFrame.AbsolutePosition
            local sliderSize = sliderFrame.AbsoluteSize.X
            local percent = math.clamp((mousePos.X - sliderPos.X) / sliderSize, 0, 1)
            value = math.floor(min + (max - min) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            valueLabel.Text = tostring(value)
            callback(value)
        end
    end)
    
    return frame
end

-- ==================================================
-- ПЕРЕМЕННЫЕ
-- ==================================================
local selectedPlayer = nil
local currentSpeed = 16
local infiniteJumpEnabled = false
local flyEnabled = false
local flySpeed = 50
local noFallEnabled = false
local espEnabled = false
local noclipEnabled = false
local godModeEnabled = false
local invisibleEnabled = false
local savedPosition = nil
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local espBoxes = {}
local espNames = {}
local playerList = {}

-- ==================================================
-- ФУНКЦИИ
-- ==================================================
local function setSpeed(value)
    currentSpeed = value
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
end

local function healPlayer(amount)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = math.min(char.Humanoid.Health + amount, char.Humanoid.MaxHealth)
    end
end

-- ESP
local function updateESP()
    if not espEnabled then
        for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
            if espBoxes[plr] then espBoxes[plr]:Destroy() end
            if espNames[plr] then espNames[plr]:Destroy() end
        end
        espBoxes = {}
        espNames = {}
        return
    end
    
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            if not espBoxes[plr] then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(4, 5, 1)
                box.Color3 = Color3.fromRGB(255, 0, 0)
                box.Transparency = 0.4
                box.AlwaysOnTop = true
                box.Parent = root
                espBoxes[plr] = box
                
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 120, 0, 30)
                bill.StudsOffset = Vector3.new(0, 2.5, 0)
                bill.AlwaysOnTop = true
                bill.Parent = root
                
                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = plr.Name
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.TextScaled = true
                text.Font = Enum.Font.GothamBold
                text.Parent = bill
                espNames[plr] = bill
            end
        elseif espBoxes[plr] then
            espBoxes[plr]:Destroy()
            if espNames[plr] then espNames[plr]:Destroy() end
            espBoxes[plr] = nil
            espNames[plr] = nil
        end
    end
end

-- Полёт
local function startFly()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local hum = char:FindFirstChild("Humanoid")
    if hum then hum.PlatformStand = true end
    
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
    bodyVelocity.Parent = root
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
    bodyGyro.Parent = root
    
    local userInput = game:GetService("UserInputService")
    flyConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not flyEnabled or not root then return
        local move = Vector3.new(0, 0, 0)
        if userInput:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0, 0, -1) end
        if userInput:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0, 0, 1) end
        if userInput:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1, 0, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1, 0, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0, -1, 0) end
        if move.Magnitude > 0 then move = move.Unit end
        local cam = workspace.CurrentCamera
        local vel = (cam.CFrame.LookVector * move.Z + cam.CFrame.RightVector * move.X + Vector3.new(0, move.Y, 0)) * flySpeed
        bodyVelocity.Velocity = vel
    end)
end

local function stopFly()
    if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    local char = player.Character
    if char then
        if char:FindFirstChild("Humanoid") then char.Humanoid.PlatformStand = false end
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    end
end

-- Noclip
local function updateNoclip()
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
end

-- Антипадение
local function setupNoFall()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.StateChanged:Connect(function(state)
            if noFallEnabled and state == Enum.HumanoidStateType.FallingDown then
                task.wait(0.1)
                if player.Character then
                    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end
        end)
    end
end

-- Невидимость
local function setInvisibility(value)
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = value and 1 or 0
        end
    end
end

-- God Mode
local function setupGodMode()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    if godModeEnabled then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        hum.BreakJointsOnDeath = false
        hum:GetPropertyChangedSignal("Health"):Connect(function()
            if godModeEnabled then hum.Health = math.huge end
        end)
    else
        hum.MaxHealth = 100
        if hum.Health > 100 then hum.Health = 100 end
        hum.BreakJointsOnDeath = true
    end
end

-- ==================================================
-- ВКЛАДКА ТЕЛЕПОРТ
-- ==================================================
local tpContent = contentFrames[1]

local playerDropdown = nil
local dropdownFrame = nil

local function updatePlayerList()
    local names = {}
    playerList = {}
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
            table.insert(playerList, plr)
        end
    end
    table.sort(names)
    if #names == 0 then table.insert(names, "НЕТ ИГРОКОВ") end
    
    if dropdownFrame then dropdownFrame:Destroy() end
    
    dropdownFrame = Instance.new("Frame")
    dropdownFrame.Parent = tpContent
    dropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    dropdownFrame.Size = UDim2.new(0.9, 0, 0, 35)
    dropdownFrame.Position = UDim2.new(0.05, 0, 0, 10)
    local dropCorner = Instance.new("UICorner")
    dropCorner.CornerRadius = UDim.new(0, 6)
    dropCorner.Parent = dropdownFrame
    
    playerDropdown = Instance.new("TextButton")
    playerDropdown.Parent = dropdownFrame
    playerDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    playerDropdown.Size = UDim2.new(0.8, 0, 0.8, 0)
    playerDropdown.Position = UDim2.new(0.05, 0, 0.1, 0)
    playerDropdown.Text = names[1] or "ВЫБЕРИ ИГРОКА"
    playerDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    playerDropdown.Font = Enum.Font.Gotham
    playerDropdown.TextScaled = true
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = playerDropdown
    
    local arrow = Instance.new("TextLabel")
    arrow.Parent = dropdownFrame
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0.1, 0, 0.8, 0)
    arrow.Position = UDim2.new(0.87, 0, 0.1, 0)
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    arrow.Font = Enum.Font.GothamBold
    arrow.TextScaled = true
    
    local listFrame = nil
    local isOpen = false
    
    playerDropdown.MouseButton1Click:Connect(function()
        if isOpen then
            if listFrame then listFrame:Destroy() end
            isOpen = false
            return
        end
        if listFrame then listFrame:Destroy() end
        listFrame = Instance.new("ScrollingFrame")
        listFrame.Parent = dropdownFrame
        listFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        listFrame.Size = UDim2.new(0.9, 0, 0, 150)
        listFrame.Position = UDim2.new(0.05, 0, 1, 0)
        listFrame.CanvasSize = UDim2.new(0, 0, 0, #names * 35)
        listFrame.ScrollBarThickness = 6
        
        local y = 0
        for i, name in ipairs(names) do
            local opt = Instance.new("TextButton")
            opt.Parent = listFrame
            opt.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
            opt.Size = UDim2.new(1, 0, 0, 35)
            opt.Position = UDim2.new(0, 0, 0, y)
            opt.Text = name
            opt.TextColor3 = Color3.fromRGB(255, 255, 255)
            opt.Font = Enum.Font.Gotham
            opt.TextScaled = true
            opt.MouseButton1Click:Connect(function()
                playerDropdown.Text = name
                for _, plr in pairs(playerList) do
                    if plr.Name == name then selectedPlayer = plr break end
                end
                if listFrame then listFrame:Destroy() end
                isOpen = false
            end)
            y = y + 35
        end
        isOpen = true
    end)
end

updatePlayerList()
game:GetService("Players").PlayerAdded:Connect(updatePlayerList)
game:GetService("Players").PlayerRemoving:Connect(updatePlayerList)

createButton(tpContent, "ОБНОВИТЬ СПИСОК", Color3.fromRGB(0, 191, 255), 55, updatePlayerList)

createButton(tpContent, "ТЕЛЕПОРТ К ВЫБРАННОМУ", Color3.fromRGB(255, 50, 50), 100, function()
    if not selectedPlayer then return end
    if not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myChar = player.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and targetRoot then
        myRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0))
    end
end)

createButton(tpContent, "ПОСТАВИТЬ МЕТКУ", Color3.fromRGB(50, 205, 50), 150, function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedPosition = char.HumanoidRootPart.Position
    end
end)

createButton(tpContent, "ТЕЛЕПОРТ К МЕТКЕ", Color3.fromRGB(0, 191, 255), 200, function()
    if savedPosition then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(savedPosition)
        end
    end
end)

-- ==================================================
-- ВКЛАДКА ВИЗУАЛ
-- ==================================================
local visContent = contentFrames[2]

createToggle(visContent, "ESP", Color3.fromRGB(0, 191, 255), 10, function(v)
    espEnabled = v
    updateESP()
end)

createToggle(visContent, "FullBright", Color3.fromRGB(0, 191, 255), 60, function(v)
    local lighting = game:GetService("Lighting")
    if v then
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.Brightness = 2
    else
        lighting.Ambient = Color3.fromRGB(127, 127, 127)
        lighting.Brightness = 1
    end
end)

-- ==================================================
-- ВКЛАДКА ДВИЖЕНИЕ
-- ==================================================
local moveContent = contentFrames[3]

createSlider(moveContent, "Скорость бега", 16, 300, 16, 10, function(v)
    setSpeed(v)
end)

createToggle(moveContent, "Бесконечный прыжок", Color3.fromRGB(0, 191, 255), 85, function(v)
    infiniteJumpEnabled = v
end)

createToggle(moveContent, "Noclip (проход сквозь стены)", Color3.fromRGB(0, 191, 255), 135, function(v)
    noclipEnabled = v
    updateNoclip()
end)

createToggle(moveContent, "Антипадение", Color3.fromRGB(0, 191, 255), 185, function(v)
    noFallEnabled = v
    if v then setupNoFall() end
end)

createToggle(moveContent, "Невидимость", Color3.fromRGB(0, 191, 255), 235, function(v)
    invisibleEnabled = v
    setInvisibility(v)
end)

createToggle(moveContent, "Полёт V3", Color3.fromRGB(0, 191, 255), 285, function(v)
    flyEnabled = v
    if v then startFly() else stopFly() end
end)

createSlider(moveContent, "Скорость полёта", 20, 200, 50, 340, function(v)
    flySpeed = v
end)

-- Обработчик прыжка
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Обновление noclip
game:GetService("RunService").RenderStepped:Connect(function()
    if noclipEnabled then updateNoclip() end
    if espEnabled then updateESP() end
end)

-- Обновление персонажа
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    setSpeed(currentSpeed)
    if noclipEnabled then updateNoclip() end
    if godModeEnabled then setupGodMode() end
    if invisibleEnabled then setInvisibility(true) end
    if flyEnabled then
        flyEnabled = false
        stopFly()
        task.wait(0.5)
        flyEnabled = true
        startFly()
    end
end)

-- ==================================================
-- ВКЛАДКА ХИЛ
-- ==================================================
local healContent = contentFrames[4]

createButton(healContent, "ВЫЛЕЧИТЬ 50 HP", Color3.fromRGB(50, 205, 50), 10, function()
    healPlayer(50)
end)

createButton(healContent, "ВЫЛЕЧИТЬ 100 HP", Color3.fromRGB(50, 205, 50), 60, function()
    healPlayer(100)
end)

createButton(healContent, "ПОЛНОЕ ИСЦЕЛЕНИЕ", Color3.fromRGB(50, 205, 50), 110, function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = char.Humanoid.MaxHealth
    end
end)

createToggle(healContent, "GOD MODE (бессмертие)", Color3.fromRGB(255, 50, 50), 160, function(v)
    godModeEnabled = v
    setupGodMode()
end)

-- ==================================================
-- ЗАПУСК
-- ==================================================
setSpeed(16)
print("SWILL ULTIMATE HUB loaded. Press F2 to open/close")

-- Горячая клавиша F2
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F2 then
        mainFrame.Visible = not mainFrame.Visible
    end
end)
