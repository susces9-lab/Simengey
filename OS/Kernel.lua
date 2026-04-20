-- SWILL OS KERNEL v3.0 (УПРОЩЁННАЯ ВЕРСИЯ)
print("🔷 SWILL OS Kernel v3.0")

local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Очистка старого GUI
for _, v in pairs(gui:GetChildren()) do
    if v.Name == "SwillOS" then v:Destroy() end
end

-- ==================================================
-- ПРОСТОЙ МЕНЕДЖЕР ОКОН
-- ==================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SwillOS"
screenGui.Parent = gui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Главное окно
local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Size = UDim2.new(0, 400, 0, 350)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -175)
mainFrame.Active = true
mainFrame.Draggable = true

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "SWILL OS"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- Кнопка закрытия
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

-- Область для кнопок (рабочий стол)
local desktop = Instance.new("Frame")
desktop.Parent = mainFrame
desktop.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
desktop.Size = UDim2.new(1, 0, 1, -40)
desktop.Position = UDim2.new(0, 0, 0, 40)

-- ==================================================
-- ИКОНКИ
-- ==================================================
local yPos = 20

-- Функция создания иконки
local function addIcon(name, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = desktop
    btn.BackgroundColor3 = color
    btn.Size = UDim2.new(0, 80, 0, 80)
    btn.Position = UDim2.new(0, 20, 0, yPos)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextScaled = true
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(callback)
    
    yPos = yPos + 100
    return btn
end

-- Иконка телепорта
addIcon("Телепорт", Color3.fromRGB(0, 191, 255), function()
    -- Создаём окно телепорта
    local teleWin = Instance.new("Frame")
    teleWin.Parent = screenGui
    teleWin.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    teleWin.Size = UDim2.new(0, 300, 0, 400)
    teleWin.Position = UDim2.new(0.5, -150, 0.5, -200)
    teleWin.Active = true
    teleWin.Draggable = true
    
    local teleCorner = Instance.new("UICorner")
    teleCorner.CornerRadius = UDim.new(0, 12)
    teleCorner.Parent = teleWin
    
    local teleTitle = Instance.new("TextLabel")
    teleTitle.Parent = teleWin
    teleTitle.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
    teleTitle.Size = UDim2.new(1, 0, 0, 35)
    teleTitle.Text = "Телепорт"
    teleTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleTitle.Font = Enum.Font.GothamBold
    teleTitle.TextScaled = true
    
    local teleClose = Instance.new("TextButton")
    teleClose.Parent = teleWin
    teleClose.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    teleClose.Size = UDim2.new(0, 25, 0, 25)
    teleClose.Position = UDim2.new(1, -30, 0, 5)
    teleClose.Text = "X"
    teleClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleClose.Font = Enum.Font.GothamBold
    teleClose.TextScaled = true
    teleClose.MouseButton1Click:Connect(function()
        teleWin:Destroy()
    end)
    
    local list = Instance.new("ScrollingFrame")
    list.Parent = teleWin
    list.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    list.Size = UDim2.new(1, -20, 1, -50)
    list.Position = UDim2.new(0, 10, 0, 45)
    
    local function updateList()
        for _, child in pairs(list:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        
        local y = 5
        for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
            if plr ~= player then
                local btn = Instance.new("TextButton")
                btn.Parent = list
                btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                btn.Size = UDim2.new(0.95, 0, 0, 40)
                btn.Position = UDim2.new(0.025, 0, 0, y)
                btn.Text = plr.Name
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                btn.Font = Enum.Font.Gotham
                btn.TextScaled = true
                
                btn.MouseButton1Click:Connect(function()
                    local char = player.Character
                    local target = plr.Character
                    if char and target and target:FindFirstChild("HumanoidRootPart") then
                        char.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
                    end
                end)
                
                y = y + 50
            end
        end
        list.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    end
    
    updateList()
    
    local refresh = Instance.new("TextButton")
    refresh.Parent = teleWin
    refresh.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
    refresh.Size = UDim2.new(0.9, 0, 0, 35)
    refresh.Position = UDim2.new(0.05, 0, 1, -45)
    refresh.Text = "Обновить"
    refresh.TextColor3 = Color3.fromRGB(255, 255, 255)
    refresh.Font = Enum.Font.GothamBold
    refresh.TextScaled = true
    refresh.MouseButton1Click:Connect(updateList)
end)

-- Иконка установщика
addIcon("Установщик", Color3.fromRGB(50, 205, 50), function()
    -- Создаём окно установщика
    local instWin = Instance.new("Frame")
    instWin.Parent = screenGui
    instWin.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    instWin.Size = UDim2.new(0, 350, 0, 300)
    instWin.Position = UDim2.new(0.5, -175, 0.5, -150)
    instWin.Active = true
    instWin.Draggable = true
    
    local instCorner = Instance.new("UICorner")
    instCorner.CornerRadius = UDim.new(0, 12)
    instCorner.Parent = instWin
    
    local instTitle = Instance.new("TextLabel")
    instTitle.Parent = instWin
    instTitle.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    instTitle.Size = UDim2.new(1, 0, 0, 35)
    instTitle.Text = "Установщик скриптов"
    instTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    instTitle.Font = Enum.Font.GothamBold
    instTitle.TextScaled = true
    
    local instClose = Instance.new("TextButton")
    instClose.Parent = instWin
    instClose.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    instClose.Size = UDim2.new(0, 25, 0, 25)
    instClose.Position = UDim2.new(1, -30, 0, 5)
    instClose.Text = "X"
    instClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    instClose.Font = Enum.Font.GothamBold
    instClose.TextScaled = true
    instClose.MouseButton1Click:Connect(function()
        instWin:Destroy()
    end)
    
    local urlLabel = Instance.new("TextLabel")
    urlLabel.Parent = instWin
    urlLabel.BackgroundTransparency = 1
    urlLabel.Size = UDim2.new(0.9, 0, 0, 25)
    urlLabel.Position = UDim2.new(0.05, 0, 0.12, 0)
    urlLabel.Text = "Ссылка на скрипт:"
    urlLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    urlLabel.Font = Enum.Font.GothamBold
    urlLabel.TextScaled = true
    urlLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local urlInput = Instance.new("TextBox")
    urlInput.Parent = instWin
    urlInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    urlInput.Size = UDim2.new(0.9, 0, 0, 40)
    urlInput.Position = UDim2.new(0.05, 0, 0.25, 0)
    urlInput.PlaceholderText = "https://raw.githubusercontent.com/..."
    urlInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    urlInput.Font = Enum.Font.Gotham
    urlInput.TextScaled = true
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = instWin
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(0.9, 0, 0, 25)
    nameLabel.Position = UDim2.new(0.05, 0, 0.45, 0)
    nameLabel.Text = "Название:"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local nameInput = Instance.new("TextBox")
    nameInput.Parent = instWin
    nameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    nameInput.Size = UDim2.new(0.9, 0, 0, 40)
    nameInput.Position = UDim2.new(0.05, 0, 0.55, 0)
    nameInput.PlaceholderText = "Название приложения"
    nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameInput.Font = Enum.Font.Gotham
    nameInput.TextScaled = true
    
    local installBtn = Instance.new("TextButton")
    installBtn.Parent = instWin
    installBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    installBtn.Size = UDim2.new(0.8, 0, 0, 45)
    installBtn.Position = UDim2.new(0.1, 0, 0.72, 0)
    installBtn.Text = "УСТАНОВИТЬ"
    installBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    installBtn.Font = Enum.Font.GothamBold
    installBtn.TextScaled = true
    
    local status = Instance.new("TextLabel")
    status.Parent = instWin
    status.BackgroundTransparency = 1
    status.Size = UDim2.new(0.9, 0, 0, 30)
    status.Position = UDim2.new(0.05, 0, 0.88, 0)
    status.Text = "Готов"
    status.TextColor3 = Color3.fromRGB(255, 255, 0)
    status.Font = Enum.Font.Gotham
    status.TextScaled = true
    
    installBtn.MouseButton1Click:Connect(function()
        local url = urlInput.Text
        local name = nameInput.Text
        
        if url == "" then
            status.Text = "❌ Введи ссылку!"
            return
        end
        if name == "" then
            name = "Новый скрипт"
        end
        
        status.Text = "⏳ Загрузка..."
        
        local success, content = pcall(function()
            return game:HttpGet(url)
        end)
        
        if success then
            local execSuccess, err = pcall(function()
                loadstring(content)()
            end)
            if execSuccess then
                status.Text = "✅ Установлено: " .. name
                status.TextColor3 = Color3.fromRGB(0, 255, 0)
                urlInput.Text = ""
                nameInput.Text = ""
            else
                status.Text = "❌ Ошибка: " .. tostring(err)
                status.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        else
            status.Text = "❌ Ошибка загрузки!"
            status.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end)
end)

print("🔷 SWILL OS v3.0 загружена!")
print("🔷 Нажми F2 для скрытия/показа")

-- Горячая клавиша F2
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F2 then
        screenGui.Enabled = not screenGui.Enabled
    end
end)
