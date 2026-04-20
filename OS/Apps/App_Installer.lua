-- SWILL OS APP INSTALLER
-- Позволяет добавлять новые скрипты прямо из игры

local WindowManager = _G.SWILL_OS.modules.windowManager
local FileManager = _G.SWILL_OS.modules.fileManager
local DataManager = _G.SWILL_OS.modules.dataManager

-- Создаём окно установщика
local win = WindowManager.createWindow("Установщик скриптов", 350, 400, 200, 150)

-- Поле для ввода URL
local urlLabel = Instance.new("TextLabel")
urlLabel.Parent = win
urlLabel.BackgroundTransparency = 1
urlLabel.Size = UDim2.new(0.9, 0, 0, 30)
urlLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
urlLabel.Text = "Вставь ссылку на скрипт:"
urlLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
urlLabel.Font = Enum.Font.GothamBold
urlLabel.TextScaled = true
urlLabel.TextXAlignment = Enum.TextXAlignment.Left

local urlInput = Instance.new("TextBox")
urlInput.Parent = win
urlInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
urlInput.Size = UDim2.new(0.9, 0, 0, 40)
urlInput.Position = UDim2.new(0.05, 0, 0.18, 0)
urlInput.PlaceholderText = "https://raw.githubusercontent.com/..."
urlInput.TextColor3 = Color3.fromRGB(255, 255, 255)
urlInput.Font = Enum.Font.Gotham
urlInput.TextScaled = true

local nameLabel = Instance.new("TextLabel")
nameLabel.Parent = win
nameLabel.BackgroundTransparency = 1
nameLabel.Size = UDim2.new(0.9, 0, 0, 30)
nameLabel.Position = UDim2.new(0.05, 0, 0.33, 0)
nameLabel.Text = "Название приложения:"
nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLabel.Font = Enum.Font.GothamBold
nameLabel.TextScaled = true
nameLabel.TextXAlignment = Enum.TextXAlignment.Left

local nameInput = Instance.new("TextBox")
nameInput.Parent = win
nameInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
nameInput.Size = UDim2.new(0.9, 0, 0, 40)
nameInput.Position = UDim2.new(0.05, 0, 0.46, 0)
nameInput.PlaceholderText = "Моё приложение"
nameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
nameInput.Font = Enum.Font.Gotham
nameInput.TextScaled = true

-- Кнопка установки
local installBtn = Instance.new("TextButton")
installBtn.Parent = win
installBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
installBtn.Size = UDim2.new(0.8, 0, 0, 45)
installBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
installBtn.Text = "📥 УСТАНОВИТЬ"
installBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
installBtn.Font = Enum.Font.GothamBold
installBtn.TextScaled = true

-- Статус
local status = Instance.new("TextLabel")
status.Parent = win
status.BackgroundTransparency = 1
status.Size = UDim2.new(0.9, 0, 0, 40)
status.Position = UDim2.new(0.05, 0, 0.78, 0)
status.Text = "Готов к установке"
status.TextColor3 = Color3.fromRGB(255, 255, 0)
status.Font = Enum.Font.Gotham
status.TextScaled = true
status.TextWrapped = true

-- Список установленных приложений
local listFrame = Instance.new("ScrollingFrame")
listFrame.Parent = win
listFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
listFrame.Size = UDim2.new(0.9, 0, 0, 120)
listFrame.Position = UDim2.new(0.05, 0, 0.9, 0)
listFrame.CanvasSize = UDim2.new(0, 0, 2, 0)
listFrame.Visible = false

-- Функция обновления списка
local function updateInstalledList()
    -- Очищаем
    for _, child in pairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local apps = DataManager.loadInstalledApps()
    local y = 5
    
    for _, app in ipairs(apps) do
        local btn = Instance.new("TextButton")
        btn.Parent = listFrame
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.Size = UDim2.new(0.98, 0, 0, 35)
        btn.Position = UDim2.new(0.01, 0, 0, y)
        btn.Text = "🗑️ " .. app.name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextScaled = true
        
        btn.MouseButton1Click:Connect(function()
            -- Удаляем приложение
            local newApps = {}
            for _, a in ipairs(apps) do
                if a.name ~= app.name then
                    table.insert(newApps, a)
                end
            end
            DataManager.saveInstalledApps(newApps)
            updateInstalledList()
            status.Text = "🗑️ Удалено: " .. app.name
            status.TextColor3 = Color3.fromRGB(255, 165, 0)
        end)
        
        y = y + 40
    end
    
    listFrame.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- Кнопка показа/скрытия списка
local showListBtn = Instance.new("TextButton")
showListBtn.Parent = win
showListBtn.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
showListBtn.Size = UDim2.new(0.8, 0, 0, 30)
showListBtn.Position = UDim2.new(0.1, 0, 0.85, 0)
showListBtn.Text = "📋 ПОКАЗАТЬ УСТАНОВЛЕННЫЕ"
showListBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
showListBtn.Font = Enum.Font.GothamBold
showListBtn.TextScaled = true

showListBtn.MouseButton1Click:Connect(function()
    listFrame.Visible = not listFrame.Visible
    if listFrame.Visible then
        updateInstalledList()
        showListBtn.Text = "✖️ СКРЫТЬ СПИСОК"
    else
        showListBtn.Text = "📋 ПОКАЗАТЬ УСТАНОВЛЕННЫЕ"
    end
end)

-- Установка скрипта
installBtn.MouseButton1Click:Connect(function()
    local url = urlInput.Text
    local name = nameInput.Text
    
    if url == "" then
        status.Text = "❌ Введи ссылку на скрипт!"
        status.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    if name == "" then
        name = "Новое приложение"
    end
    
    status.Text = "⏳ Загрузка..."
    status.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    -- Пробуем загрузить и установить
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if not success then
        status.Text = "❌ Ошибка загрузки! Проверь ссылку"
        status.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end
    
    -- Выполняем скрипт
    local execSuccess, err = pcall(function()
        loadstring(content)()
    end)
    
    if execSuccess then
        -- Сохраняем в список установленных
        local apps = DataManager.loadInstalledApps()
        table.insert(apps, {name = name, url = url})
        DataManager.saveInstalledApps(apps)
        
        status.Text = "✅ Установлено: " .. name
        status.TextColor3 = Color3.fromRGB(0, 255, 0)
        urlInput.Text = ""
        nameInput.Text = ""
        
        -- Добавляем иконку на рабочий стол
        local WindowManager = _G.SWILL_OS.modules.windowManager
        if WindowManager and WindowManager.addIconToDesktop then
            WindowManager.addIconToDesktop(name, Color3.fromRGB(100, 100, 255), function()
                loadstring(game:HttpGet(url))()
            end)
        end
    else
        status.Text = "❌ Ошибка выполнения: " .. tostring(err)
        status.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

print("✅ Установщик приложений загружен!")
