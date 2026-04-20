-- ==================================================
-- ЧАСТЬ 2 (part2.lua) - ESP, ПОЛЁТ, ЗАЩИТА
-- ==================================================

-- ==================================================
-- ESP ФУНКЦИИ
-- ==================================================
local function updateESP()
    if not espEnabled then
        for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
            if plr.Character then
                if espBoxes[plr] then espBoxes[plr]:Destroy() end
                if espNames[plr] then espNames[plr]:Destroy() end
            end
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

-- ==================================================
-- ПОЛЁТ V3
-- ==================================================
local function startFlyV3()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    humanoid.PlatformStand = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 100000
    bodyGyro.Parent = root

    local moveDirection = Vector3.new(0, 0, 0)
    flyConnection = runService.RenderStepped:Connect(function()
        if not flyEnabled or not root or not bodyVelocity then
            if flyConnection then flyConnection:Disconnect() end
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
        if moveVector.Magnitude > 0 then
            bodyGyro.CFrame = CFrame.new(root.Position, root.Position + moveVector.Unit)
        end
    end)
end

local function stopFlyV3()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
    end
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if char and char:FindFirstChild("HumanoidRootPart") then
        local root = char.HumanoidRootPart
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
    end
end

-- ==================================================
-- ЗАЩИТА И НЕВИДИМОСТЬ
-- ==================================================
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
        addLog("God Mode включён")
    else
        hum.MaxHealth = 100
        if hum.Health > 100 then hum.Health = 100 end
        hum.BreakJointsOnDeath = true
        addLog("God Mode выключен")
    end
end

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
