-- SWILL OS DATA MANAGER
local DataManager = {}
_G.SWILL_OS.modules.dataManager = DataManager

local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer

-- Сохранение в Player (простой способ)
function DataManager.save(key, value)
    local container = player:FindFirstChild("SwillOS_Data")
    if not container then
        container = Instance.new("Folder")
        container.Name = "SwillOS_Data"
        container.Parent = player
    end
    
    local entry = container:FindFirstChild(key)
    if not entry then
        entry = Instance.new("StringValue")
        entry.Name = key
        entry.Parent = container
    end
    
    entry.Value = HttpService:JSONEncode(value)
    print("✅ Сохранено: " .. key)
end

-- Загрузка из Player
function DataManager.load(key, defaultValue)
    local container = player:FindFirstChild("SwillOS_Data")
    if container then
        local entry = container:FindFirstChild(key)
        if entry and entry.Value ~= "" then
            local success, data = pcall(function()
                return HttpService:JSONDecode(entry.Value)
            end)
            if success then
                return data
            end
        end
    end
    return defaultValue or {}
end

-- Сохранение установленных приложений
function DataManager.saveInstalledApps(apps)
    DataManager.save("InstalledApps", apps)
end

-- Загрузка установленных приложений
function DataManager.loadInstalledApps()
    return DataManager.load("InstalledApps", {})
end

print("✅ DataManager готов")
