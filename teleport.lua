-- SWILL ULTIMATE TELEPORTER [Rayfield UI]
-- Максимальная версия: ESP, Fly V3, Noclip, God Mode, Anti-Fall, Invisible, Chat, Clear Accessories, Внутриигровой чат
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
local flyEnabled = false
local flySpeed = 50
local noFallEnabled = false
local espEnabled = false
local noclipEnabled = false
local godModeEnabled = false
local invisibleEnabled = false
local savedPosition = nil
local logs = {}
local logConnection = nil
local noclipParts = {}
local originalTransparency = {}
local flyConnection = nil
local bodyVelocity = nil
local bodyGyro = nil

-- Переменные для чата
local chatMessages = {}
local chatInputOpen = false
local chatInputBox = nil
local chatFrame = nil
local chatHistory = nil

-- ESP переменные
local espBoxes = {}
local espNames = {}

-- ==================================================
-- ФУНКЦИИ
-- ==================================================
-- Отправка сообщения в внутриигровой чат
local function sendInternalChatMessage(msg)
    if msg == "" then return end
    local data = {
        sender = player.Name,
        message = msg,
        time = os.date("%H:%M:%S")
    }
    -- Отправляем всем на сервере через RemoteEvent
    local chatRemote = replicatedStorage:FindFirstChild("SWILL_ChatEvent")
    if not chatRemote then
        chatRemote = Instance.new("RemoteEvent")
        chatRemote.Name = "SWILL_ChatEvent"
        chatRemote.Parent = replicatedStorage
    end
    chatRemote:FireServer(data)
    -- Добавляем своё сообщение в локальный чат
    table.insert(chatMessages, 1, "[" .. data.time .. "] " .. data.sender .. ": " .. data.message)
    if #chatMessages > 50 then table.remove(chatMessages) end
    updateChatDisplay()
end

-- Получение сообщения от сервера
local function setupChatListener()
    local chatRemote = replicatedStorage:FindFirstChild("SWILL_ChatEvent")
    if not chatRemote then
        chatRemote = Instance.new("RemoteEvent")
        chatRemote.Name = "SWILL_ChatEvent"
        chatRemote.Parent = replicatedStorage
    end
    chatRemote.OnClientEvent:Connect(function(data)
        table.insert(chatMessages, 1, "[" .. data.time .. "] " .. data.sender .. ": " .. data.message)
        if #chatMessages > 50 then table.remove(chatMessages) end
        updateChatDisplay()
        -- Уведомление о новом сообщении
        Rayfield:Notify({Title = "Новое сообщение", Content = data.sender .. ": " .. data.message, Duration = 3})
    end)
end

-- Обновление отображения чата
local function updateChatDisplay()
    if not chatHistory then return end
    local text = ""
    for i = 1, math.min(15, #chatMessages) do
        text = text .. chatMessages[i] .. "\n"
    end
    chatHistory:Set(text)
end

-- Создание GUI чата
local function createChatUI()
    if chatFrame then return end
    
    -- Создаём отдельное окно чата
    chatFrame = Instance.new("Frame")
    chatFrame.Parent = player.PlayerGui
    chatFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    chatFrame.BackgroundTransparency = 0.1
    chatFrame.Size = UDim2.new(0, 300, 0, 400)
    chatFrame.Position = UDim2.new(0, 10, 0.5, -200)
    chatFrame.Active = true
    chatFrame.Draggable = true
    chatFrame.Visible = false
    
    local chatCorner = Instance.new("UICorner")
    chatCorner.CornerRadius = UDim.new(0, 12)
    chatCorner.Parent = chatFrame
    
    local chatTitle = Instance.new("TextLabel")
    chatTitle.Parent = chatFrame
    chatTitle.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
    chatTitle.Size = UDim2.new(1, 0, 0, 35)
    chatTitle.Text = "💬 SWILL CHAT"
    chatTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    chatTitle.Font = Enum.Font.GothamBold
    chatTitle.TextScaled = true
    
    local closeChatBtn = Instance.new("TextButton")
    closeChatBtn.Parent = chatFrame
    closeChatBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeChatBtn.Size = UDim2.new(0, 25, 0, 25)
    closeChatBtn.Position = UDim2.new(1, -30, 0, 5)
    closeChatBtn.Text = "X"
    closeChatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeChatBtn.Font = Enum.Font.GothamBold
    closeChatBtn.TextScaled = true
    closeChatBtn.MouseButton1Click:Connect(function()
        chatFrame.Visible = false
    end)
    
    -- Область сообщений
    chatHistory = Instance.new("TextLabel")
    chatHistory.Parent = chatFrame
    chatHistory.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    chatHistory.BackgroundTransparency = 0.5
    chatHistory.Size = UDim2.new(0.95, 0, 0.7, 0)
    chatHistory.Position = UDim2.new(0.025, 0, 0.12, 0)
    chatHistory.Text = ""
    chatHistory.TextColor3 = Color3.fromRGB(255, 255, 255)
    chatHistory.Font = Enum.Font.Gotham
    chatHistory.TextScaled = true
    chatHistory.TextXAlignment = Enum.TextXAlignment.Left
    chatHistory.TextYAlignment = Enum.TextYAlignment.Top
    chatHistory.TextWrapped = true
    
    -- Поле ввода
    local inputFrame = Instance.new("Frame")
    inputFrame.Parent = chatFrame
    inputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    inputFrame.Size = UDim2.new(0.95, 0, 0, 40)
    inputFrame.Position = UDim2.new(0.025, 0, 0.85, 0)
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputFrame
    
    chatInputBox = Instance.new("TextBox")
    chatInputBox.Parent = inputFrame
    chatInputBox.BackgroundTransparency = 1
    chatInputBox.Size = UDim2.new(1, -10, 1, 0)
    chatInputBox.Position = UDim2.new(0, 5, 0, 0)
    chatInputBox.PlaceholderText = "Введите сообщение..."
    chatInputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    chatInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    chatInputBox.Font = Enum.Font.Gotham
    chatInputBox.TextScaled = true
    
    chatInputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and chatInputBox.Text ~= "" then
            sendInternalChatMessage(chatInputBox.Text)
            chatInputBox.Text = ""
        end
    end)
end

local function toggleChat()
    createChatUI()
    chatFrame.Visible = not chatFrame.Visible
    if chatFrame.Visible then
        chatInputBox:CaptureFocus()
    end
end

-- Остальные функции (sendChatMessage, clearAccessories, setSpeed, и т.д.)
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

local function clearAccessories()
    local char = player.Character
    if not char then return end
    local accessories = char:GetChildren()
    local count = 0
    for _, child in pairs(accessories) do
        if child:IsA("Accessory") or child:IsA("Hat") or child:IsA("Shirt") or child:IsA("Pants") or child.Name == "BodyColors" then
            child:Destroy()
            count = count + 1
        end
    end
    addLog("Удалено аксессуаров: " .. count)
    Rayfield:Notify({Title = "Аксессуары", Content = "Удалено: " .. count, Duration = 2})
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

local function healPlayer(amount)
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    hum.Health = math.min(hum.Health + amount, hum.MaxHealth)
    addLog("Вылечено на " .. amount .. " HP")
end

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

local function activateAllFeatures()
    setSpeed(80)
    currentSpeed = 80
    infiniteJumpEnabled = true
    noFallEnabled = true
    setupNoFall()
    noclipEnabled = true
    setupNoclip()
    godModeEnabled = true
    setupGodMode()
    invisibleEnabled = true
    setInvisibility(true)
    espEnabled = true
    updateESP()
    flyEnabled = true
    startFlyV3()
    
    addLog("🔥 Knockout режим активирован! Все функции включены")
    Rayfield:Notify({Title = "KNOCKOUT", Content = "Все функции активированы!", Duration = 3})
end

local function fullShutdown()
    if flyEnabled then
        flyEnabled = false
        stopFlyV3()
    end
    if espEnabled then
        espEnabled = false
        updateESP()
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
    lo
