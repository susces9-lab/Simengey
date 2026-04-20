-- SWILL ULTIMATE TELEPORTER [Rayfield UI]
-- Телепорт к игрокам, ESP, полёт, метки, логи, анти-падение
-- Подключаем библиотеку Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
task.wait(1)

local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")

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
local savedPosition = nil
local logs = {}
local logConnection = nil

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

local function onJumpRequest()
    if infiniteJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end
userInput.JumpRequest:Connect(onJumpRequest)

-- Анти-падение
local function onHumanoidStateChanged(state)
    if noFallEnabled and state == Enum.HumanoidStateType.FallingDown then
        task.wait(0.1)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

local function setupNoFall()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.StateChanged:Connect(onHumanoidStateChanged)
    end
end

-- Полёт
local function startFly()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end
    
    humanoid.PlatformStand = true
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
    bodyVelocity.Parent = root
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
    bodyGyro.Parent = root
    
    local moveDirection = Vector3.new(0, 0, 0)
    local connection
    connection = runService.RenderStepped:Connect(function()
        if not flyEnabled or not root or not bodyVelocity then
            if connection then connection:Disconnect() end
            return
        end
        moveDirection = Vector3.new(0, 0, 0)
        if userInput:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
        if userInput:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
        if userInput:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Vector3.new(1, 0, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection + Vector3.new(0, -1, 0) end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end
        local camera = workspace.CurrentCamera
        local forward = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector
        local moveVector = (forward * moveDirection.Z + right * moveDirection.X + Vector3.new(0, moveDirection.Y, 0)) * flySpeed
        bodyVelocity.Velocity = moveVector
        bodyGyro.CFrame = CFrame.new(root.Position, root.Position + (forward * moveDirection.Z + right * moveDirection.X) + Vector3.new(0, moveDirection.Y, 0))
    end)
    
    _G.flyConnection = connection
end

local function stopFly()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
    if _G.flyConnection then
        _G.flyConnection:Disconnect()
        _G.flyConnection = nil
    end
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        local bv = root:FindFirstChild("BodyVelocity")
        local bg = root:FindFirstChild("BodyGyro")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end

-- ESP
local function createESP(plr)
    if not espEnabled then return end
    if plr == player then return end
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESPBox"
        box.Adornee = plr.Character.HumanoidRootPart
        box.Size = Vector3.new(4, 5, 1)
        box.Color3 = plr.TeamColor == player.TeamColor and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        box.Transparency = 0.5
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Parent = plr.Character
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPName"
        billboard.Adornee = plr.Character.HumanoidRootPart
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Parent = plr.Character
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = plr.Name
        text.TextColor3 = Color3.fromRGB(255, 255, 255)
        text.TextScaled = true
        text.Font = Enum.Font.GothamBold
        text.Parent = billboard
    end
end

local function removeESP(plr)
    if plr.Character then
        local box = plr.Character:FindFirstChild("ESPBox")
        local bill = plr.Character:FindFirstChild("ESPName")
        if box then box:Destroy() end
        if bill then bill:Destroy() end
    end
end

local function updateAllESP()
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        removeESP(plr)
        if espEnabled then createESP(plr) end
    end
end

game:GetService("Players").PlayerAdded:Connect(function(plr)
    if espEnabled then
        plr.CharacterAdded:Connect(function() createESP(plr) end)
        if plr.Character then createESP(plr) end
    end
end)

game:GetService("Players").PlayerRemoving:Connect(removeESP)

-- Логирование
local function addLog(msg)
    local time = os.date("%H:%M:%S")
    table.insert(logs, 1, "[" .. time .. "] " .. msg)
    if #logs > 100 then table.remove(logs) end
end

local function startLogging()
    if logConnection then return end
    addLog("Логирование запущено")
    logConnection = runService.RenderStepped:Connect(function()
        -- Логируем изменения здоровья
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            local hum = char.Humanoid
            if hum.Health ~= _G.lastHealth then
                addLog("Здоровье: " .. math.floor(hum.Health))
                _G.lastHealth = hum.Health
            end
        end
    end)
end

-- ==================================================
-- RAYFIELD GUI
-- ==================================================
local Window = Rayfield:CreateWindow({
    Name = "SWILL ULTIMATE",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by SWILL",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SWILL_ULTIMATE",
        FileName = "Settings"
    },
    KeySystem = false
})

-- Вкладка ТЕЛЕПОРТ
local TeleportTab = Window:CreateTab("Телепорт")

TeleportTab:CreateSection("Список игроков")
local playerDropdown = nil

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player then table.insert(names, plr.Name) end
    end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

local function refreshDropdown()
    local names = getPlayerNames()
    if #names == 0 then names = {"НЕТ ИГРОКОВ"} end
    if playerDropdown then playerDropdown:Refresh(names, true) end
end

playerDropdown = TeleportTab:CreateDropdown({
    Name = "Выбери игрока",
    Options = getPlayerNames(),
    CurrentOption = {"НЕТ ИГРОКОВ"},
    Flag = "PlayerSelect",
    Callback = function(option)
        if option == "НЕТ ИГРОКОВ" then selectedPlayer = nil return end
        for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
            if plr.Name == option then selectedPlayer = plr break end
        end
        if selectedPlayer then addLog("Выбран игрок: " .. selectedPlayer.Name) end
    end
})

TeleportTab:CreateButton({
    Name = "Обновить список",
    Callback = function() refreshDropdown() end
})

TeleportTab:CreateButton({
    Name = "ТЕЛЕПОРТ К ВЫБРАННОМУ",
    Callback = function()
        if not selectedPlayer then
            Rayfield:Notify({Title = "Ошибка", Content = "Выбери игрока!", Duration = 2})
            return
        end
        if not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Rayfield:Notify({Title = "Ошибка", Content = "Игрок недоступен!", Duration = 2})
            return
        end
        local myChar = player.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot or not targetRoot then return end
        myRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0))
        addLog("Телепорт к " .. selectedPlayer.Name)
    end
})

TeleportTab:CreateSection("Метка")
TeleportTab:CreateButton({
    Name = "Поставить метку",
    Callback = function()
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedPosition = char.HumanoidRootPart.Position
            addLog("Метка сохранена: X=" .. math.floor(savedPosition.X) .. " Y=" .. math.floor(savedPosition.Y) .. " Z=" .. math.floor(savedPosition.Z))
        end
    end
})

TeleportTab:CreateButton({
    Name = "Телепорт к метке",
    Callback = function()
        if savedPosition then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(savedPosition)
                addLog("Телепорт к метке")
            end
        else
            Rayfield:Notify({Title = "Ошибка", Content = "Нет сохранённой метки!", Duration = 2})
        end
    end
})

-- Вкладка ВИЗУАЛ
local VisualTab = Window:CreateTab("Визуал")

VisualTab:CreateSection("ESP")
VisualTab:CreateToggle({
    Name = "Включить ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(value)
        espEnabled = value
        if value then
            updateAllESP()
            for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                if plr.Character then createESP(plr) end
                plr.CharacterAdded:Connect(function() createESP(plr) end)
            end
            addLog("ESP включён")
        else
            for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                removeESP(plr)
            end
            addLog("ESP выключен")
        end
    end
})

VisualTab:CreateSection("Освещение")
VisualTab:CreateToggle({
    Name = "FullBright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(value)
        if value then
            lighting.Ambient = Color3.fromRGB(255, 255, 255)
            lighting.Brightness = 2
        else
            lighting.Ambient = Color3.fromRGB(127, 127, 127)
            lighting.Brightness = 1
        end
    end
})

-- Вкладка ДВИЖЕНИЕ
local MoveTab = Window:CreateTab("Движение")

MoveTab:CreateSection("Скорость")
MoveTab:CreateSlider({
    Name = "Скорость бега",
    Range = {16, 300},
    Increment = 1,
    Suffix = "WalkSpeed",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = setSpeed
})

MoveTab:CreateButton({
    Name = "Сбросить скорость",
    Callback = function() setSpeed(16) end
})

MoveTab:CreateToggle({
    Name = "Бесконечный прыжок",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(value) infiniteJumpEnabled = value end
})

MoveTab:CreateSection("Полёт")
MoveTab:CreateToggle({
    Name = "Включить полёт",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(value)
        flyEnabled = value
        if value then
            startFly()
            addLog("Полёт включён")
        else
            stopFly()
            addLog("Полёт выключен")
        end
    end
})

MoveTab:CreateSlider({
    Name = "Скорость полёта",
    Range = {20, 200},
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(value) flySpeed = value end
})

MoveTab:CreateSection("Защита")
MoveTab:CreateToggle({
    Name = "Анти-падение",
    CurrentValue = false,
    Flag = "NoFall",
    Callback = function(value)
        noFallEnabled = value
        if value then setupNoFall() end
        addLog(value and "Анти-падение включено" or "Анти-падение выключено")
    end
})

-- Вкладка ЛОГИ
local LogTab = Window:CreateTab("Логи")

LogTab:CreateSection("Система логирования")
LogTab:CreateButton({
    Name = "Начать логирование",
    Callback = function() startLogging() end
})

LogTab:CreateButton({
    Name = "Очистить логи",
    Callback = function()
        logs = {}
        addLog("Логи очищены")
    end
})

local logDisplay = LogTab:CreateLabel("Логи будут здесь")
task.spawn(function()
    while true do
        task.wait(1)
        local text = "Последние логи:\n"
        for i = 1, math.min(10, #logs) do
            text = text .. logs[i] .. "\n"
        end
        logDisplay:Set(text)
    end
end)

-- ==================================================
-- ИНИЦИАЛИЗАЦИЯ
-- ==================================================
refreshDropdown()
setSpeed(16)
addLog("Скрипт загружен")

print("SWILL ULTIMATE loaded. Press F2 to open menu")
