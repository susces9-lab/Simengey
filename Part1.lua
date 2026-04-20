-- ==================================================
-- ЧАСТЬ 1 (part1.lua) - ИНИЦИАЛИЗАЦИЯ И ПЕРЕМЕННЫЕ
-- ==================================================

-- Загружаем Rayfield с проверкой
local Rayfield = nil
local attempts = 0
while Rayfield == nil and attempts < 3 do
    local success, result = pcall(function()
        return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    end)
    if success and type(result) == "table" then
        Rayfield = result
        print("✅ Rayfield загружен")
    else
        attempts = attempts + 1
        print("⚠️ Ошибка загрузки Rayfield, попытка " .. attempts .. "/3")
        task.wait(2)
    end
end

if not Rayfield then
    game.StarterGui:SetCore("SendNotification", {
        Title = "Ошибка",
        Text = "Не удалось загрузить Rayfield. Скрипт не будет работать.",
        Duration = 5
    })
    return
end

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
-- БАЗОВЫЕ ФУНКЦИИ
-- ==================================================
local function addLog(msg)
    local time = os.date("%H:%M:%S")
    table.insert(logs, 1, "[" .. time .. "] " .. msg)
    if #logs > 100 then table.remove(logs) end
end

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

local function setSpeed(value)
    currentSpeed = value
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = value
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

local function clearAccessories()
    local char = player.Character
    if not char then return end
    local count = 0
    for _, child in pairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") then
            child:Destroy()
            count = count + 1
        end
    end
    addLog("Удалено аксессуаров: " .. count)
    Rayfield:Notify({Title = "Аксессуары", Content = "Удалено: " .. count, Duration = 2})
end
