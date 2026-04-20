-- SWILL ULTIMATE TELEPORTER [Rayfield UI] - МОДИФИЦИРОВАННАЯ ВЕРСИЯ
-- Удалено: полёт, хилы. Добавлена кнопка бессмертия (пишет "я гей" в чат), улучшенный ESP, авто-аим на ближайшего игрока

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
task.wait(1)

local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local replicatedStorage = game:GetService("ReplicatedStorage")

-- ==================================================
-- ПЕРЕМЕННЫЕ
-- ==================================================
local selectedPlayer = nil
local currentSpeed = 16
local infiniteJumpEnabled = false
local noFallEnabled = false
local espEnabled = false
local noclipEnabled = false
local godModeEnabled = false
local invisibleEnabled = false
local aimbotEnabled = false
local savedPosition = nil
local logs = {}
local logConnection = nil
local noclipParts = {}
local originalTransparency = {}
local espBoxes = {}
local espNames = {}

-- ==================================================
-- ФУНКЦИИ
-- ==================================================
-- Отправка сообщения в чат
local function sendChatMessage(msg)
    local chatRemote = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") or replicatedStorage:FindFirstChild("SayMessageRequest")
    if chatRemote then
        pcall(function() chatRemote:FireServer(msg, "All") end)
    end
    local sayMessage = replicatedStorage:FindFirstChild("SayMessageRequest")
    if sayMessage then
        pcall(function() sayMessage:FireServer(msg, "All") end)
    end
end

-- Кнопка бессмертия (пишет "я гей")
local function immortalityChat()
    sendChatMessage("я гей")
    addLog("Отправлено сообщение в чат: я гей")
    Rayfield:Notify({Title = "Бессмертие", Content = "Сообщение отправлено!", Duration = 2})
end

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

-- Невидимость
local function setInvisibility(value)
    local char = player.Character
    if not char then return end
    if value then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                originalTransparency[part] = part.Transparency
                part.Transparency = 1
            end
        end
        addLog("Невидимость включена")
    else
        for part, oldTrans in pairs(originalTransparency) do
            if part and part.Parent then
                part.Transparency = oldTrans
            end
        end
        originalTransparency = {}
        addLog("Невидимость выключена")
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

local function setupNoclip()
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") and not noclipParts[part] then
            noclipParts[part] = part.CanCollide
        end
    end
    updateNoclip()
end

-- God Mode (бессмертие)
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
        addLog("God Mode включён")
    else
        hum.MaxHealth = 100
        if hum.Health > 100 then hum.Health = 100 end
        hum.BreakJointsOnDeath = true
        addLog("God Mode выключен")
    end
end

-- Улучшенный ESP
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
                box.Color3 = plr.TeamColor == player.TeamColor and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                box.Transparency = 0.4
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Parent = root
                espBoxes[plr] = box
                
                local billboard = Instance.new("BillboardGui")
                billboard.Size = UDim2.new(0, 120, 0, 35)
                billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = root
                
                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.Text = plr.Name
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.TextScaled = true
                text.Font = Enum.Font.GothamBold
                text.Parent = billboard
                
                local hpBar = Instance.new("Frame")
                hpBar.Size = UDim2.new(1, 0, 0.2, 0)
                hpBar.Position = UDim2.new(0, 0, 1, 0)
                hpBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                hpBar.BorderSizePixel = 0
                hpBar.Parent = billboard
                
                espNames[plr] = {billboard = billboard, hpBar = hpBar, text = text}
            end
            
            if espNames[plr] and espNames[plr].hpBar then
                local hum = plr.Character:FindFirstChild("Humanoid")
                if hum then
                    local hpPercent = hum.Health / hum.MaxHealth
                    espNames[plr].hpBar.Size = UDim2.new(hpPercent, 0, 0.2, 0)
                    espNames[plr].hpBar.BackgroundColor3 = hpPercent > 0.5 and Color3.fromRGB(0, 255, 0) or (hpPercent > 0.2 and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(255, 0, 0))
                end
            end
        elseif espBoxes[plr] then
            espBoxes[plr]:Destroy()
            if espNames[plr] and espNames[plr].billboard then espNames[plr].billboard:Destroy() end
            espBoxes[plr] = nil
            espNames[plr] = nil
        end
    end
end

-- Авто-аим на ближайшего игрока
local function updateAimbot()
    if not aimbotEnabled then return end
    
    local closest = nil
    local shortestDistance = math.huge
    
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local distance = (player.Character.HumanoidRootPart.Position - root.Position).magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                closest = plr
            end
        end
    end
    
    if closest and closest.Character and closest.Character:FindFirstChild("HumanoidRootPart") then
        local cam = workspace.CurrentCamera
        local targetPos = closest.Character.HumanoidRootPart.Position
        cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
    end
end

-- X-Ray (скрытие стен)
local function setXRay(value)
    if value then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 0.9 then
                part.LocalTransparencyModifier = 0.7
            end
        end
        addLog("X-Ray включён")
    else
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
        addLog("X-Ray выключен")
    end
end

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

-- Полная остановка скрипта
local function fullShutdown()
    if espEnabled then
        for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
            if espBoxes[plr] then espBoxes[plr]:Destroy() end
            if espNames[plr] then espNames[plr]:Destroy() end
        end
    end
    if noclipEnabled then
        noclipEnabled = false
        updateNoclip()
    end
    if godModeEnabled then
        godModeEnabled = false
        setupGodMode()
    end
    if invisibleEnabled then
        invisibleEnabled = false
        setInvisibility(false)
    end
    if logConnection then
        logConnection:Disconnect()
        logConnection = nil
    end
    infiniteJumpEnabled = false
    noFallEnabled = false
    aimbotEnabled = false
    setSpeed(16)
    setXRay(false)
    Rayfield:Destroy()
    addLog("Скрипт полностью остановлен")
end

-- ==================================================
-- RAYFIELD GUI
-- ==================================================
local Window = Rayfield:CreateWindow({
    Name = "SWILL ULTIMATE",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by SWILL",
    ConfigurationSaving = {Enabled = true, FolderName = "SWILL_ULTIMATE", FileName = "Settings"},
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

TeleportTab:CreateButton({Name = "Обновить список", Callback = refreshDropdown})
TeleportTab:CreateButton({
    Name = "ТЕЛЕПОРТ К ВЫБРАННОМУ",
    Callback = function()
        if not selectedPlayer then return Rayfield:Notify({Title = "Ошибка", Content = "Выбери игрока!", Duration = 2}) end
        if not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then return Rayfield:Notify({Title = "Ошибка", Content = "Игрок недоступен!", Duration = 2}) end
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
TeleportTab:CreateButton({Name = "Поставить метку", Callback = function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        savedPosition = char.HumanoidRootPart.Position
        addLog("Метка сохранена")
    end
end})
TeleportTab:CreateButton({Name = "Телепорт к метке", Callback = function()
    if savedPosition then
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(savedPosition)
            addLog("Телепорт к метке")
        end
    else
        Rayfield:Notify({Title = "Ошибка", Content = "Нет сохранённой метки!", Duration = 2})
    end
end})

-- Вкладка ВИЗУАЛ
local VisualTab = Window:CreateTab("Визуал")
VisualTab:CreateSection("ESP")
VisualTab:CreateToggle({Name = "Включить улучшенный ESP", CurrentValue = false, Flag = "ESP", Callback = function(value)
    espEnabled = value
    updateESP()
    addLog(value and "ESP включён" or "ESP выключен")
end})
VisualTab:CreateToggle({Name = "X-Ray (скрыть стены)", CurrentValue = false, Flag = "XRay", Callback = setXRay})
VisualTab:CreateSection("Освещение")
VisualTab:CreateToggle({Name = "FullBright", CurrentValue = false, Flag = "FullBright", Callback = function(value)
    if value then
        lighting.Ambient = Color3.fromRGB(255, 255, 255)
        lighting.Brightness = 2
    else
        lighting.Ambient = Color3.fromRGB(127, 127, 127)
        lighting.Brightness = 1
    end
end})

-- Вкладка ДВИЖЕНИЕ
local MoveTab = Window:CreateTab("Движение")
MoveTab:CreateSection("Скорость")
MoveTab:CreateSlider({Name = "Скорость бега", Range = {16, 300}, Increment = 1, Suffix = "WalkSpeed", CurrentValue = 16, Flag = "SpeedSlider", Callback = setSpeed})
MoveTab:CreateButton({Name = "Сбросить скорость", Callback = function() setSpeed(16) end})
MoveTab:CreateToggle({Name = "Бесконечный прыжок", CurrentValue = false, Flag = "InfiniteJump", Callback = function(value) infiniteJumpEnabled = value end})
MoveTab:CreateToggle({Name = "Noclip (проход сквозь стены)", CurrentValue = false, Flag = "Noclip", Callback = function(value)
    noclipEnabled = value
    setupNoclip()
    addLog(value and "Noclip включён" or "Noclip выключен")
end})
MoveTab:CreateSection("Защита")
MoveTab:CreateToggle({Name = "Анти-падение", CurrentValue = false, Flag = "NoFall", Callback = function(value)
    noFallEnabled = value
    if value then setupNoFall() end
    addLog(value and "Анти-падение включено" or "Анти-падение выключено")
end})
MoveTab:CreateSection("Скрытность")
MoveTab:CreateToggle({Name = "Полная невидимость", CurrentValue = false, Flag = "Invisible", Callback = function(value)
    invisibleEnabled = value
    setInvisibility(value)
end})
MoveTab:CreateSection("Чат")
MoveTab:CreateButton({Name = "💬 БЕССМЕРТИЕ (написать 'я гей')", Callback = function()
    immortalityChat()
end})
MoveTab:CreateSection("Управление")
MoveTab:CreateButton({Name = "ПОЛНОСТЬЮ ЗАКРЫТЬ СКРИПТ", Callback = fullShutdown})

-- Вкладка БОЙ
local CombatTab = Window:CreateTab("Бой")
CombatTab:CreateSection("Аимбот")
CombatTab:CreateToggle({Name = "Авто-аим на ближайшего игрока", CurrentValue = false, Flag = "Aimbot", Callback = function(value)
    aimbotEnabled = value
    addLog(value and "Аимбот включён" or "Аимбот выключен")
end})

-- Вкладка ХИЛ (оставлена только God Mode, удалены кнопки хила)
local HealTab = Window:CreateTab("Хил")
HealTab:CreateSection("Бессмертие")
HealTab:CreateToggle({Name = "God Mode (бессмертие)", CurrentValue = false, Flag = "GodMode", Callback = function(value)
    godModeEnabled = value
    setupGodMode()
end})

-- Вкладка ЛОГИ
local LogTab = Window:CreateTab("Логи")
LogTab:CreateSection("Система логирования")
LogTab:CreateButton({Name = "Начать логирование", Callback = startLogging})
LogTab:CreateButton({Name = "Очистить логи", Callback = function()
    logs = {}
    addLog("Логи очищены")
end})
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
-- ОБНОВЛЕНИЕ ПЕРСОНАЖА
-- ==================================================
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    setSpeed(currentSpeed)
    if noclipEnabled then setupNoclip() end
    if godModeEnabled then setupGodMode() end
    if invisibleEnabled then setInvisibility(true) end
end)

runService.RenderStepped:Connect(function()
    if noclipEnabled then updateNoclip() end
    if espEnabled then updateESP() end
    if aimbotEnabled then updateAimbot() end
end)

refreshDropdown()
setSpeed(16)
addLog("Скрипт загружен")
print("SWILL ULTIMATE loaded. Press F2 to open menu")
