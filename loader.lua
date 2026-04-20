-- ==================================================
-- ЗАГРУЗЧИК (loader.lua)
-- Размести этот файл в корне репозитория
-- Ссылка для запуска: loadstring(game:HttpGet("https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/loader.lua"))()
-- ==================================================

local scriptUrls = {
    "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/part1.lua",
    "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/part2.lua",
    "https://raw.githubusercontent.com/susces9-lab/Simengey/refs/heads/main/part3.lua"
}

local function loadScript(url)
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        return result
    else
        warn("Ошибка загрузки: " .. url .. " - " .. tostring(result))
        return nil
    end
end

local function executeScripts()
    for _, url in ipairs(scriptUrls) do
        local scriptContent = loadScript(url)
        if scriptContent then
            loadstring(scriptContent)()
            task.wait(0.5)
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "Ошибка",
                Text = "Не удалось загрузить: " .. url,
                Duration = 5
            })
            return
        end
    end
    print("✅ Все части скрипта загружены!")
end

executeScripts()
