-- SWILL OS MODULE LOADER
local ModuleLoader = {}
_G.SWILL_OS.modules.moduleLoader = ModuleLoader

ModuleLoader.modules = {}

function ModuleLoader.register(name, module)
    ModuleLoader.modules[name] = module
    print("📦 Зарегистрирован: " .. name)
end

function ModuleLoader.get(name)
    return ModuleLoader.modules[name]
end

function ModuleLoader.loadFromUrl(url, name)
    local success, content = pcall(function()
        return game:HttpGet(url)
    end)
    
    if success then
        local func, err = loadstring(content)
        if func then
            func()
            print("✅ Загружен: " .. name)
            return true
        end
    end
    return false
end

print("✅ ModuleLoader готов")
