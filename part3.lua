-- ==================================================
-- ЧАСТЬ 3 (part3.lua) - GUI И УПРАВЛЕНИЕ
-- ==================================================

-- ==================================================
-- ЧАТ ФУНКЦИИ
-- ==================================================
local function sendInternalChatMessage(msg)
    if msg == "" then return end
    local data = {
        sender = player.Name,
        message = msg,
        time = os.date("%H:%M:%S")
    }
    local chatRemote = replicatedStorage:FindFirstChild("SWILL_ChatEvent")
    if not chatRemote then
        chatRemote = Instance.new("RemoteEvent")
        chatRemote.Name = "SWILL_ChatEvent"
        chatRemote.Parent = replicatedStorage
    end
    chatRemote:FireServer(data)
    table.insert(chatMessages, 1, "[" .. data.time .. "] " .. data.sender .. ": " .. data.message)
    if #chatMessages > 50 then table.remove(chatMessages) end
    updateChatDisplay()
end

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
        Rayfield:Notify({Title = "Новое сообщение", Content = data.sender .. ": " .. data.message, Duration = 3})
    end)
end

local function updateChatDisplay()
    if not chatHistory then return end
    local text = ""
    for i = 1, math.min(15, #chatMessages) do
        text = text .. chatMessages[i] .. "\n"
    end
    chatHistory:Set(text)
end

local function createChatUI()
    if chatFrame then return end

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

-- ==================================================
-- АКТИВАЦИЯ ВСЕХ ФУНКЦИЙ
-- ==================================================
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
-- ИНИЦИАЛИЗАЦИЯ GUI
-- ==================================================
local function refreshDropdown()
    local names = getPlayerNames()
    if #names == 0 then names = {"НЕТ ИГРОКОВ"} end
    if playerDropdown then playerDropdown:Refresh(names, true) end
end

local function getPlayerNames()
    local names = {}
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player then table.insert(names, plr.Name) end
    end
    table.sort(names, function(a, b) return a:lower() < b:lower() end)
    return names
end

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
MoveTab:CreateSection("Полёт Fly V3")
MoveTab:CreateToggle({Name = "Включить полёт V3", CurrentValue = false, Flag = "Fly", Callback = function(value)
    flyEnabled = value
    if value then
        startFlyV3()
        addLog("Полёт V3 включён")
    else
        stopFlyV3()
        addLog("Полёт V3 выключен")
    end
end})
MoveTab:CreateSlider({Name = "Скорость полёта", Range = {20, 200}, Increment = 5, Suffix = "studs/s", CurrentValue = 50, Flag = "FlySpeed", Callback = function(value) flySpeed = value end})
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
MoveTab:CreateSection("Внешний вид")
MoveTab:CreateButton({Name = "Сбросить все аксессуары", Callback = clearAccessories})
MoveTab:CreateSection("Чат")
MoveTab:CreateButton({Name = "💬 ОТКРЫТЬ ЧАТ", Callback = function()
    createChatUI()
    toggleChat()
end})
MoveTab:CreateButton({Name = "Написать 'я гей' в глобальный чат", Callback = function()
    sendChatMessage("я гей")
    Rayfield:Notify({Title = "Чат", Content = "Сообщение отправлено", Duration = 1.5})
    addLog("Отправлено сообщение в глобальный чат: я гей")
end})
MoveTab:CreateSection("Управление")
MoveTab:CreateButton({Name = "🔥 KNOCKOUT (Включить всё)", Callback = activateAllFeatures})
MoveTab:CreateButton({Name = "ПОЛНОСТЬЮ ЗАКРЫТЬ СКРИПТ", Callback = fullShutdown})

-- Вкладка ХИЛ
local HealTab = Window:CreateTab("Хил")
HealTab:CreateSection("Регенерация")
HealTab:CreateButton({Name = "Вылечить 50 HP", Callback = function() healPlayer(50) end})
HealTab:CreateButton({Name = "Вылечить 100 HP", Callback = function() healPlayer(100) end})
HealTab:CreateButton({Name = "Полное исцеление", Callback = function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.Health = char.Humanoid.MaxHealth
        addLog("Полное исцеление")
    end
end})
HealTab:CreateSection("Бессмертие")
HealTab:CreateToggle({Name = "God Mode (бессмертие)", CurrentValue = false, Flag = "GodMode", Callback = function(value)
    godModeEnabled = value
    setupGodMode()
end})

-- Вкладка РАЗНОЕ
local MiscTab = Window:CreateTab("Разное")
MiscTab:CreateSection("Инструменты")
MiscTab:CreateButton({Name = "Телепорт в центр карты", Callback = function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
        addLog("Телепорт в центр карты")
    end
end})
MiscTab:CreateButton({Name = "Поднять в воздух (10 блоков)", Callback = function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position
        char.HumanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y + 10, pos.Z)
        addLog("Поднят в воздух")
    end
end})
MiscTab:CreateButton({Name = "Спавн частиц вокруг", Callback = function()
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        for i = 1, 20 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(0.5, 0.5, 0.5)
            part.Position = char.HumanoidRootPart.Position + Vector3.new(math.random(-5,5), math.random(-2,5), math.random(-5,5))
            part.Anchored = true
            part.CanCollide = false
            part.BrickColor = BrickColor.new("Bright red")
            part.Material = Enum.Material.Neon
            part.Parent = workspace
            task.wait(0.05)
            part:Destroy()
        end
        addLog("Частицы созданы")
    end
end})
MiscTab:CreateSection("Информация")
MiscTab:CreateLabel("SWILL ULTIMATE v3.0")
MiscTab:CreateLabel("F2 - открыть/закрыть меню")
MiscTab:CreateLabel("Совместимо с Delta Mobile")

-- Вкладка ЛОГИ
local LogTab = Window:CreateTab("Логи")
LogTab:CreateSection("Система логирования")
LogTab:CreateButton({Name = "Начать логирование", Callback = function()
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
end})
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
-- НАСТРОЙКА ЧАТА
-- ==================================================
setupChatListener()

-- ==================================================
-- ОБНОВЛЕНИЕ ПЕРСОНАЖА
-- ==================================================
player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    setSpeed(currentSpeed)
    if noclipEnabled then setupNoclip() end
    if godModeEnabled then setupGodMode() end
    if invisibleEnabled then setInvisibility(true) end
    if flyEnabled then
        flyEnabled = false
        stopFlyV3()
        task.wait(0.5)
        flyEnabled = true
        startFlyV3()
    end
end)

runService.RenderStepped:Connect(function()
    if noclipEnabled then updateNoclip() end
    if espEnabled then updateESP() end
end)

refreshDropdown()
setSpeed(16)
addLog("Скрипт загружен")
print("SWILL ULTIMATE loaded. Press F2 to open menu")
