-- SWILL CHAT ONLY - ВНУТРИИГРОВОЙ ЧАТ ДЛЯ DELTA MOBILE
-- Чат работает между всеми пользователями скрипта на сервере

-- Загрузчик RemoteEvent для чата
local replicatedStorage = game:GetService("ReplicatedStorage")
local chatRemote = replicatedStorage:FindFirstChild("SWILL_ChatEvent")
if not chatRemote then
    chatRemote = Instance.new("RemoteEvent")
    chatRemote.Name = "SWILL_ChatEvent"
    chatRemote.Parent = replicatedStorage
end

local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Удаляем старый GUI
for _, v in pairs(gui:GetChildren()) do
    if v.Name == "SwillChat" then v:Destroy() end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SwillChat"
screenGui.Parent = gui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- ==================================================
-- ОКНО ЧАТА
-- ==================================================
local chatFrame = Instance.new("Frame")
chatFrame.Parent = screenGui
chatFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
chatFrame.Size = UDim2.new(0, 320, 0, 450)
chatFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
chatFrame.Active = true
chatFrame.Draggable = true
chatFrame.BackgroundTransparency = 0.1

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = chatFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Parent = chatFrame
title.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "💬 SWILL CHAT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Parent = chatFrame
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

-- Область сообщений
local messagesFrame = Instance.new("ScrollingFrame")
messagesFrame.Parent = chatFrame
messagesFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
messagesFrame.Size = UDim2.new(0.95, 0, 0.65, 0)
messagesFrame.Position = UDim2.new(0.025, 0, 0.12, 0)
messagesFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
messagesFrame.ScrollBarThickness = 6

local messagesText = Instance.new("TextLabel")
messagesText.Parent = messagesFrame
messagesText.BackgroundTransparency = 1
messagesText.Size = UDim2.new(1, -20, 1, -20)
messagesText.Position = UDim2.new(0, 10, 0, 10)
messagesText.Text = "Чат пуст\n"
messagesText.TextColor3 = Color3.fromRGB(255, 255, 255)
messagesText.Font = Enum.Font.Gotham
messagesText.TextScaled = true
messagesText.TextXAlignment = Enum.TextXAlignment.Left
messagesText.TextYAlignment = Enum.TextYAlignment.Top
messagesText.TextWrapped = true

-- Поле ввода
local inputFrame = Instance.new("Frame")
inputFrame.Parent = chatFrame
inputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
inputFrame.Size = UDim2.new(0.95, 0, 0, 50)
inputFrame.Position = UDim2.new(0.025, 0, 0.8, 0)
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = inputFrame

local inputBox = Instance.new("TextBox")
inputBox.Parent = inputFrame
inputBox.BackgroundTransparency = 1
inputBox.Size = UDim2.new(0.7, -10, 1, 0)
inputBox.Position = UDim2.new(0, 10, 0, 0)
inputBox.PlaceholderText = "Введите сообщение..."
inputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.Font = Enum.Font.Gotham
inputBox.TextScaled = true

-- Кнопка отправки
local sendBtn = Instance.new("TextButton")
sendBtn.Parent = inputFrame
sendBtn.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
sendBtn.Size = UDim2.new(0.25, -10, 0.8, 0)
sendBtn.Position = UDim2.new(0.73, 0, 0.1, 0)
sendBtn.Text = "➤"
sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sendBtn.Font = Enum.Font.GothamBold
sendBtn.TextScaled = true
local sendCorner = Instance.new("UICorner")
sendCorner.CornerRadius = UDim.new(0, 6)
sendCorner.Parent = sendBtn

-- ==================================================
-- ЧАТ ЛОГИКА
-- ==================================================
local messages = {}

local function updateChat()
    local text = ""
    for i = 1, math.min(30, #messages) do
        text = text .. messages[i] .. "\n"
    end
    messagesText.Text = text
    messagesFrame.CanvasSize = UDim2.new(0, 0, 0, #messages * 25)
end

local function sendMessage(msg)
    if msg == "" then return end
    local data = {
        sender = player.Name,
        message = msg,
        time = os.date("%H:%M:%S")
    }
    chatRemote:FireServer(data)
    table.insert(messages, 1, "[" .. data.time .. "] " .. data.sender .. ": " .. data.message)
    if #messages > 50 then table.remove(messages) end
    updateChat()
end

-- Приём сообщений
chatRemote.OnClientEvent:Connect(function(data)
    table.insert(messages, 1, "[" .. data.time .. "] " .. data.sender .. ": " .. data.message)
    if #messages > 50 then table.remove(messages) end
    updateChat()
end)

-- Обработчики отправки
sendBtn.MouseButton1Click:Connect(function()
    if inputBox.Text ~= "" then
        sendMessage(inputBox.Text)
        inputBox.Text = ""
    end
end)

inputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed and inputBox.Text ~= "" then
        sendMessage(inputBox.Text)
        inputBox.Text = ""
    end
end)

-- ==================================================
-- ЗАПУСК
-- ==================================================
table.insert(messages, 1, "💬 Чат загружен. Напиши что-нибудь!")
updateChat()

print("SWILL CHAT loaded. Press F2 to open/close")

-- Горячая клавиша F2
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F2 then
        chatFrame.Visible = not chatFrame.Visible
    end
end)
