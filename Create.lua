-- ==================================================
-- SWILL ULTIMATE TELEPORTER (RAYFIELD UI) [ОБЪЕДИНЁННАЯ ВЕРСИЯ]
-- ==================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
repeat task.wait() until game.Players.LocalPlayer and game.Players.LocalPlayer.Character
task.wait(1)

local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

-- ==================================================
-- ПЕРЕМЕННЫЕ
-- ==================================================
local selectedPlayer = nil
local currentSpeed = 16
local infiniteJumpEnabled = false
local noFallEnabled = false
local espEnabled = false
local xrayEnabled = false
local tracersEnabled = false
local noclipEnabled = false
local godModeEnabled = false
local invisibleEnabled = false
local aimbotEnabled = false
local savedPosition = nil
local logs = {}
local logConnection = nil

-- Переменные для ESP
local espObjects = {} -- Хранит все созданные объекты для ESP (боксы, билборды, трейсеры)
local noclipParts = {}
local originalTransparency = {}

-- ==================================================
-- БАЗОВЫЕ ФУНКЦИИ
-- ==================================================
local function addLog(msg)
    local time = os.date("%H:%M:%S")
    table.insert(logs, 1, "[" .. time .. "] " .. msg)
    if #logs > 100 then table.remove(logs) end
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

-- ==================================================
-- ESP СИСТЕМА (БОКСЫ, ИМЕНА, ЗДОРОВЬЕ + ТРЕЙСЕРЫ)
-- ==================================================
local function clearESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
end

local function updateESP()
    if not espEnabled then
        clearESP()
        return
    end

    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local hum = plr.Character:FindFirstChild("Humanoid")
            
            -- 1. Box ESP (оранжевая рамка)
            if not espObjects["box_" .. plr.UserId] then
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ESPBox"
                box.Adornee = root
                box.Size = Vector3.new(4, 5, 1)
                box.Color3 = Color3.fromRGB(255, 165, 0)
                box.Transparency = 0.5
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Parent = root
                espObjects["box_" .. plr.UserId] = box
            end

            -- 2. BillboardGui (Имя + HP)
            if not espObjects["bill_" .. plr.UserId] then
                local bill = Instance.new("BillboardGui")
                bill.Name = "ESPBill"
                bill.Adornee = root
                bill.Size = UDim2.new(0, 120, 0, 40)
                bill.StudsOffset = Vector3.new(0, 2.5, 0)
                bill.AlwaysOnTop = true
                bill.Parent = root

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Name = "NameLabel"
                nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = plr.Name
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.Parent = bill

                local hpLabel = Instance.new("TextLabel")
                hpLabel.Name = "HPLabel"
                hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
                hpLabel.Position = UDim2.new(0, 0, 0.5, 0)
                hpLabel.BackgroundTransparency = 1
                hpLabel.Text = "HP: 100%"
                hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                hpLabel.TextScaled = true
                hpLabel.Font = Enum.Font.GothamBold
                hpLabel.Parent = bill
                
                espObjects["bill_" .. plr.UserId] = bill
                espObjects["hpLabel_" .. plr.UserId] = hpLabel
            end

            -- Обновление HP
            if hum and espObjects["hpLabel_" .. plr.UserId] then
                local hpPercent = (hum.Health / hum.MaxHealth) * 100
                espObjects["hpLabel_" .. plr.UserId].Text = string.format("HP: %.1f%%", hpPercent)
                local color = hpPercent > 50 and Color3.fromRGB(0, 255, 0) or (hpPercent > 20 and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(255, 0, 0))
                espObjects["hpLabel_" .. plr.UserId].TextColor3 = color
            end

            -- 3. X-Ray (Включение/выключение видимости через стены)
            if xrayEnabled then
                local charParts = plr.Character:GetChildren()
                for _, part in ipairs(charParts) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = 0.6
                    end
                end
            elseif espObjects["xray_" .. plr.UserId] then
                 for _, part in ipairs(plr.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.LocalTransparencyModifier = 0
                    end
                end
            end

            -- 4. Tracers (Линия от центра экрана к игроку)
            if tracersEnabled then
                if not espObjects["tracer_" .. plr.UserId] then
                    local tracer = Instance.new("LineHandleAdornment")
                    tracer.Name = "Tracer"
                    tracer.Adornee = root
                    tracer.AlwaysOnTop = true
                    tracer.ZIndex = 10
                    tracer.Thickness = 2
                    tracer.Color3 = Color3.fromRGB(255, 255, 255)
                    tracer.Parent = root
                    espObjects["tracer_" .. plr.UserId] = tracer
                end
                
                if espObjects["tracer_" .. plr.UserId] and Camera then
                    local vector, onScreen = Camera:WorldToScreenPoint(root.Position)
                    if onScreen then
                        espObjects["tracer_" .. plr.UserId].From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        espObjects["tracer_" .. plr.UserId].To = Vector2.new(vector.X, vector.Y)
                        espObjects["tracer_" .. plr.UserId].Visible = true
                    else
                        espObjects["tracer_" .. plr.UserId].Visible = false
                    end
                end
            elseif espObjects["tracer_" .. plr.UserId] then
                espObjects["tracer_" .. plr.UserId].Visible = false
            end
            
        else
            -- Удаляем ESP, если игрок вышел или умер
            if espObjects["box_" .. plr.UserId] then espObjects["box_" .. plr.UserId]:Destroy() end
            if espObjects["bill_" .. plr.UserId] then espObjects["bill_" .. plr.UserId]:Destroy() end
            if espObjects["tracer_" .. plr.UserId] then espObjects["tracer_" .. plr.UserId]:Destroy() end
            espObjects["box_" .. plr.UserId] = nil
            espObjects["bill_" .. plr.UserId] = nil
            espObjects["hpLabel_" .. plr.UserId] = nil
            espObjects["tracer_" .. plr.UserId] = nil
        end
    end
end

-- ==================================================
-- X-RAY (ГЛОБАЛЬНЫЙ)
-- ==================================================
local function setGlobalXRay(value)
    if value then
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and part.Transparency < 0.9 then
                part.LocalTransparencyModifier = 0.7
            end
        end
    else
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
    end
end

-- ==================================================
-- ОСТАЛЬНЫЕ ФУНКЦИИ (NOCLIP, GOD MODE, HEAL ETC.)
-- ==================================================
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
    addLog(godModeEnabled and "God Mode включён" or "God Mode выключен")
end

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
    else
        for part, oldTrans in pairs(originalTransparency) do
            if part and part.Parent then
                part.Transparency = oldTrans
            end
        end
        originalTransparency = {}
    end
end

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

-- Аимбот (оставляем простой, из твоего скрипта)
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
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Character.HumanoidRootPart.Position)
    end
end

local function fullShutdown()
    espEnabled = false
    updateESP()
    noclipEnabled = false
    updateNoclip()
    godModeEnabled = false
    setupGodMode()
    invisibleEnabled = false
    setInvisibility(false)
    infiniteJumpEnabled = false
    noFallEnabled = false
    aimbotEnabled = false
    setSpeed(16)
    setGlobalXRay(false)
    Rayfield:Destroy()
    addLog("Скрипт полностью остановлен")
end

-- ==================================================
-- GUI RAYFIELD
-- ==================================================
local Window = Rayfield:CreateWindow({
    Name = "SWILL ULTIMATE HUB",
    LoadingTitle = "Загрузка...",
    LoadingSubtitle = "by SWILL",
    ConfigurationSaving = {Enabled = true, FolderName = "SWILL_ULTIMATE", FileName = "Settings"},
    KeySystem = false
})

-- --- Вкладка Телепорт ---
local TeleportTab = Window:CreateTab("Телепорт")
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

local function refreshDropdown()
    if playerDropdown then playerDropdown:Refresh(getPlayerNames(), true) end
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
    end
})

TeleportTab:CreateButton({Name = "Обновить список", Callback = refreshDropdown})
TeleportTab:CreateButton({
    Name = "ТЕЛЕПОРТ К ВЫБРАННОМУ",
    Callback = function()
        if not selectedPlayer then return Rayfield:Notify({Title = "Ошибка", Content = "Выбери игрока", Duration = 2}) end
        if not selectedPlayer.Character or not selectedPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot and targetRoot then
            myRoot.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0))
        end
    end
})

-- Метка
local savedPos = nil
TeleportTab:CreateSection("Метка")
TeleportTab:CreateButton({Name = "Поставить метку", Callback = function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then savedPos = char.HumanoidRootPart.Position end
end})
TeleportTab:CreateButton({Name = "Телепорт к метке", Callback = function()
    if savedPos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(savedPos)
    else
        Rayfield:Notify({Title = "Ошибка", Content = "Нет метки", Duration = 2})
    end
end})

-- --- Вкладка Визуал (ESP) ---
local VisualTab = Window:CreateTab("Визуал")
VisualTab:CreateToggle({Name = "🔘 Включить ESP (Боксы + Имена + HP)", CurrentValue = false, Flag = "ESP", Callback = function(v)
    espEnabled = v
    if not v then clearESP() end
end})
VisualTab:CreateToggle({Name = "🔘 X-Ray (Стены насквозь)", CurrentValue = false, Flag = "XRay", Callback = function(v)
    xrayEnabled = v
    setGlobalXRay(v)
end})
VisualTab:CreateToggle({Name = "🔘 Tracers (Линии к игрокам)", CurrentValue = false, Flag = "Tracers", Callback = function(v)
    tracersEnabled = v
    if not v then
        for _, obj in pairs(espObjects) do
            if obj:IsA("LineHandleAdornment") then obj:Destroy() end
        end
    end
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

-- --- Вкладка Движение ---
local MoveTab = Window:CreateTab("Движение")
MoveTab:CreateSlider({Name = "Скорость", Range = {16, 300}, Increment = 1, CurrentValue = 16, Flag = "Speed", Callback = setSpeed})
MoveTab:CreateToggle({Name = "Бесконечный прыжок", CurrentValue = false, Flag = "Jump", Callback = function(v) infiniteJumpEnabled = v end})
MoveTab:CreateToggle({Name = "Noclip", CurrentValue = false, Flag = "Noclip", Callback = function(v)
    noclipEnabled = v
    setupNoclip()
end})
MoveTab:CreateToggle({Name = "Антипадение", CurrentValue = false, Flag = "NoFall", Callback = function(v)
    noFallEnabled = v
    if v then setupNoFall() end
end})
MoveTab:CreateToggle({Name = "Невидимость", CurrentValue = false, Flag = "Invis", Callback = function(v)
    invisibleEnabled = v
    setInvisibility(v)
end})

-- --- Вкладка Бой ---
local CombatTab = Window:CreateTab("Бой")
CombatTab:CreateToggle({Name = "Аимбот на ближайшего", CurrentValue = false, Flag = "Aimbot", Callback = function(v)
    aimbotEnabled = v
end})

-- --- Вкладка Хил ---
local HealTab = Window:CreateTab("Хил")
HealTab:CreateToggle({Name = "God Mode", CurrentValue = false, Flag = "God", Callback = function(v)
    godModeEnabled = v
    setupGodMode()
end})
HealTab:CreateButton({Name = "Вылечить 100 HP", Callback = function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Health = math.min(player.Character.Humanoid.Health + 100, player.Character.Humanoid.MaxHealth)
    end
end})
HealTab:CreateButton({Name = "Полное исцеление", Callback = function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Health = player.Character.Humanoid.MaxHealth
    end
end})

-- --- Вкладка Логи ---
local LogTab = Window:CreateTab("Логи")
LogTab:CreateButton({Name = "Очистить логи", Callback = function()
    logs = {}
    addLog("Логи очищены")
end})
local logDisplay = LogTab:CreateLabel("Логи будут здесь")
task.spawn(function()
    while true do
        task.wait(1)
        local text = ""
        for i = 1, math.min(10, #logs) do
            text = text .. logs[i] .. "\n"
        end
        logDisplay:Set(text)
    end
end)

-- Глобальные обновления
player.CharacterAdded:Connect(function()
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

setSpeed(16)
refreshDropdown()
addLog("Скрипт загружен")
print("SWILL ULTIMATE HUB loaded. Press F2 to open menu")
