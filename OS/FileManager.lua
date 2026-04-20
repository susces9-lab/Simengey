-- SWILL OS FILE MANAGER
local FileManager = {}
_G.SWILL_OS.modules.fileManager = FileManager

local DataManager = _G.SWILL_OS.modules.dataManager
local loadedScripts = {}

function FileManager.loadScript(url, name)
    if loadedScripts[name] then
        print("📁 Уже загружен: " .. name)
        return true
    end
    
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        local func, err = loadstring(content)
        if func then
            func()
            loadedScripts[name] = true
            print("✅ Загружен: " .. name)
            return true
        end
    end
    return false
end

function FileManager.installApp(url, name)
    if FileManager.loadScript(url, name) then
        local apps = DataManager.loadInstalledApps()
        table.insert(apps, {name = name, url = url})
        DataManager.saveInstalledApps(apps)
        print("📦 Установлено: " .. name)
        return true
    end
    return false
end

function FileManager.loadSavedApps()
    local apps = DataManager.loadInstalledApps()
    for _, app in ipairs(apps) do
        FileManager.loadScript(app.url, app.name)
        task.wait(0.2)
    end
end

function FileManager.getInstalledApps()
    return DataManager.loadInstalledApps()
end

print("✅ FileManager готов")
