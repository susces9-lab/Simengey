-- SWILL ULTIMATE TELEPORTER [FIXED VERSION]
-- Всё в одном файле, без ошибок

-- Загружаем Rayfield с проверкой
local Rayfield = nil
local attempts = 0
while Rayfield == nil and attempts < 5 do
    local success, result = pcall(function()
        return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end)
    if success and type(result) == "table" then
        Rayfield = result
        print("✅ Rayfield загружен")
    else
        attempts = attempts + 1
        print("⚠️ Ошибка загрузки Rayfield, попытка " .. attempts .. "/5")
        task.wait(2)
    end
end

if not Rayfield then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Ошибка",
        Text = "Не удалось загрузить Rayfield. Проверь интернет.",
        Duration = 5
    })
    return
end

repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
task.wait(1)

local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local replicatedStorage = game:GetService("ReplicatedStorage")

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
local logs = {}
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil
local espBoxes = {}
local espNames = {}

-- ==================================================
-- ФУНКЦИИ
-- ==================================================
local function addLog(msg)
    local time = os.date("%H:%M:%S")
    table.insert(logs, 1, "[" .. time .. "] " .. msg)
    if #logs > 50 then table.remove(logs) end
    print("[LOG] " .. msg)
end

local function setSpeed(value)
    currentSpeed = value
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
    end
    addLog("Скорость: " .. value)
end

local function healPlayer(amount)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = math.min(char.Humanoid.Health + amount, char.Humanoid.MaxHealth)
        addLog("Вылечено на " .. amount .. " HP")
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
    
    flyConnection = runService.RenderStepped:Connect(function()
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

-- Защита
local function updateNoclip()
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = not noclipEnabled
        end
    end
end

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

local function setInvisibility(value)
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = value and 1 or 0
        end
    end
    addLog(value and "Невидимость вкл" or "Невидимость выкл")
end

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
    addLog(godModeEnabled and "God Mode вкл" or "God Mode выкл")
end

-- ==================================================
-- GUI
-- ==================================================
local Window = Rayfield:CreateWindow({
    Name = "SWILL ULTIMATE",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by SWILL",
    ConfigurationSaving = {Enabled = true, FolderName = "SWILL", FileName = "Settings"},
    KeySystem = false
})

local TeleportTab = Window:CreateTab("Телепорт")
local VisualTab = Window:CreateTab("Визуал")
local MoveTab = Window:CreateTab("Движение")
local HealTab = Window:CreateTab("Хил")

-- Телепорт
local playerDropdown = nil
local function getPlayerNames()
    local names = {}
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player then table.insert(names, plr.Name) end
    end
    table.sort(names)
    if #names == 0 then names = {"НЕТ ИГРОКОВ"} end
    return names
end

playerDropdown = TeleportTab:CreateDropdown({
    Name = "Выбери игрока",
    Options = getPlayerNames(),
    CurrentOption = {"НЕТ ИГРОКОВ"},
    Flag = "PlayerSelect",
    Callback = function(opt)
        if opt == "НЕТ ИГРОКОВ" then selectedPlayer = nil return end
        for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
            if plr.Name == opt then selectedPlayer = plr break end
        end
        addLog("Выбран: " .. (selectedPlayer and selectedPlayer.Name or "None"))
    end
})

TeleportTab:CreateButton({Name = "Обновить список", Callback = function()
    playerDropdown:Refresh(getPlayerNames(), true)
end})

TeleportTab:CreateButton({Name = "ТЕЛЕПОРТ", Callback = function()
    if not selectedPlayer then return Rayfield:Notify({Title = "Ошибка", Content = "Выбери игрока", Duration = 2}) end
    if not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    local myChar = player.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and targetRoot then
        myRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0))
        addLog("Телепорт к " .. selectedPlayer.Name)
    end
end})

-- Метка
local savedPos = nil
TeleportTab:CreateSection("Метка")
TeleportTab:CreateButton({Name = "Поставить метку", Callback = function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedPos = char.HumanoidRootPart.Position
        addLog("Метка сохранена")
    end
end})
TeleportTab:CreateButton({Name = "Телепорт к метке", Callback = function()
    if savedPos then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(savedPos)
            addLog("Телепорт к метке")
        end
    else
        Rayfield:Notify({Title = "Ошибка", Content = "Нет метки", Duration = 2})
    end
end})

-- Визуал
VisualTab:CreateToggle({Name = "ESP", CurrentValue = false, Flag = "ESP", Callback = function(v)
    espEnabled = v
    updateESP()
    addLog(v and "ESP вкл" or "ESP выкл")
end})
VisualTab:CreateToggle({Name = "FullBright", CurrentValue = false, Flag = "FB", Callback = function(v)
    if v then
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.Brightness = 2
    else
        lighting.Ambient = Color3.fromRGB(127, 127, 127)
        lighting.Brightness = 1
    end
end})

-- Движение
MoveTab:CreateSlider({Name = "Скорость", Range = {16, 300}, Increment = 1, CurrentValue = 16, Flag = "Speed", Callback = setSpeed})
MoveTab:CreateToggle({Name = "Бесконечный прыжок", CurrentValue = false, Flag = "Jump", Callback = function(v)
    infiniteJumpEnabled = v
    addLog(v and "Беск. прыжок вкл" or "Беск. прыжок выкл")
end})
MoveTab:CreateToggle({Name = "Noclip", CurrentValue = false, Flag = "Noclip", Callback = function(v)
    noclipEnabled = v
    updateNoclip()
    addLog(v and "Noclip вкл" or "Noclip выкл")
end})
MoveTab:CreateToggle({Name = "Антипадение", CurrentValue = false, Flag = "NoFall", Callback = function(v)
    noFallEnabled = v
    if v then setupNoFall() end
    addLog(v and "Антипадение вкл" or "Антипадение выкл")
end})
MoveTab:CreateToggle({Name = "Невидимость", CurrentValue = false, Flag = "Invis", Callback = function(v)
    invisibleEnabled = v
    setInvisibility(v)
end})
MoveTab:CreateToggle({Name = "Полёт", CurrentValue = false, Flag = "Fly", Callback = function(v)
    flyEnabled = v
    if v then startFly() else stopFly() end
    addLog(v and "Полёт вкл" or "Полёт выкл")
end})
MoveTab:CreateSlider({Name = "Скорость полёта", Range = {20, 200}, Increment = 5, CurrentValue = 50, Flag = "FlySpeed", Callback = function(v) flySpeed = v end})

-- Хил
HealTab:CreateButton({Name = "Вылечить 50 HP", Callback = function() healPlayer(50) end})
HealTab:CreateButton({Name = "Вылечить 100 HP", Callback = function() healPlayer(100) end})
HealTab:CreateButton({Name = "Полное исцеление", Callback = function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = char.Humanoid.MaxHealth
        addLog("Полное исцеление")
    end
end})
HealTab:CreateToggle({Name = "God Mode", CurrentValue = false, Flag = "God", Callback = function(v)
    godModeEnabled = v
    setupGodMode()
end})

-- Обработчик прыжка
userInput.JumpRequest:Connect(function()
    if infiniteJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
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

runService.RenderStepped:Connect(function()
    if noclipEnabled then updateNoclip() end
    if espEnabled then updateESP() end
end)

setSpeed(16)
addLog("✅ Скрипт загружен! Нажми F2")
print("SWILL ULTIMATE loaded. Press F2")
