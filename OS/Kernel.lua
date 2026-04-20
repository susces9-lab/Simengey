-- SWILL OS KERNEL v2.1 (ИСПРАВЛЕННАЯ)
print("🔷 SWILL OS Kernel v2.1")

local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Очистка старого GUI
for _, v in pairs(gui:GetChildren()) do
    if v.Name == "SwillOS" then v:Destroy() end
end

-- Глобальные переменные
_G.SWILL_OS = {
    version = "2.1",
    modules = {},
    apps = {},
    windows = {}
}

-- Функция загрузки модуля
local function loadModule(url, name)
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        local func, err = loadstring(content)
        if func then
            func()
            print("✅ Модуль загружен: " .. name)
            return true
        else
            warn("❌ Ошибка: " .. tostring(err))
        end
    else
        warn("❌ Не удалось загрузить: " .. name)
    end
    return false
end

-- Загрузка модулей по порядку
local modules = {
    {name = "DataManager", url = "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/OS/DataManager.lua"},
    {name = "ModuleLoader", url = "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/OS/ModuleLoader.lua"},
    {name = "WindowManager", url = "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/OS/WindowManager.lua"},
    {name = "FileManager", url = "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/OS/FileManager.lua"},
}

for _, m in ipairs(modules) do
    loadModule(m.url, m.name)
    task.wait(0.3)
end

-- Загрузка приложений
local appsFolder = "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/OS/Apps/"
local apps = {
    "App_Teleport.lua",
    "App_Installer.lua",
}

for _, app in ipairs(apps) do
    loadModule(appsFolder .. app, app)
    task.wait(0.2)
end

-- Загрузка сохранённых пользовательских приложений
local fileManager = _G.SWILL_OS.modules.fileManager
if fileManager and fileManager.loadSavedApps then
    fileManager.loadSavedApps()
end

-- ==================================================
-- СОЗДАНИЕ РАБОЧЕГО СТОЛА
-- ==================================================
local WindowManager = _G.SWILL_OS.modules.windowManager
if WindowManager then
    local desktop = WindowManager.createDesktop()
    
    -- Добавляем иконки на рабочий стол
    local yPos = 20
    
    -- Иконка телепорта
    local teleportBtn = Instance.new("TextButton")
    teleportBtn.Parent = desktop.bg
    teleportBtn.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
    teleportBtn.Size = UDim2.new(0, 80, 0, 80)
    teleportBtn.Position = UDim2.new(0, 20, 0, yPos)
    teleportBtn.Text = "Телепорт"
    teleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportBtn.Font = Enum.Font.GothamBold
    teleportBtn.TextScaled = true
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = teleportBtn
    
    teleportBtn.MouseButton1Click:Connect(function()
        local success, content = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/OS/Apps/App_Teleport.lua")
        end)
        if success then
            loadstring(content)()
        end
    end)
    
    yPos = yPos + 100
    
    -- Иконка установщика
    local installBtn = Instance.new("TextButton")
    installBtn.Parent = desktop.bg
    installBtn.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    installBtn.Size = UDim2.new(0, 80, 0, 80)
    installBtn.Position = UDim2.new(0, 20, 0, yPos)
    installBtn.Text = "Установщик"
    installBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    installBtn.Font = Enum.Font.GothamBold
    installBtn.TextScaled = true
    
    local btnCorner2 = Instance.new("UICorner")
    btnCorner2.CornerRadius = UDim.new(0, 10)
    btnCorner2.Parent = installBtn
    
    installBtn.MouseButton1Click:Connect(function()
        local success, content = pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/OS/Apps/App_Installer.lua")
        end)
        if success then
            loadstring(content)()
        end
    end)
    
    print("🔷 Рабочий стол создан! Иконок: 2")
else
    warn("❌ WindowManager не загружен!")
end

print("🔷 SWILL OS v2.1 загружена!")
print("🔷 Нажми F2 для скрытия/показа")

-- Горячая клавиша F2
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F2 then
        local screen = player.PlayerGui:FindFirstChild("SwillOS")
        if screen then
            screen.Enabled = not screen.Enabled
        end
    end
end)
