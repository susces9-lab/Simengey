-- SWILL OS KERNEL v1.0
print("🔷 SWILL OS Kernel v1.0")

local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

-- Очистка старого GUI
for _, v in pairs(gui:GetChildren()) do
    if v.Name == "SwillOS" then v:Destroy() end
end

-- Глобальные переменные
_G.SWILL_OS = {
    version = "1.0",
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
    "App_ESP.lua",
    "App_Aimbot.lua",
    "App_Speed.lua",
    "App_Fly.lua",
    "App_Noclip.lua"
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

print("🔷 SWILL OS загружена! Нажми F2")
