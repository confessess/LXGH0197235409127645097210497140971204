local ArsenalURL = "https://raw.githubusercontent.com/confessess/AR097125409721047210947/main/main.lua"

local function safeLoad(url)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not ok then
        warn("[LightHub] Failed to load Arsenal script: " .. tostring(result))
        return false
    end

    return true
end

if game.PlaceId == 286090429 then
    safeLoad(ArsenalURL)
    return
end

-- This file is intentionally stripped down to auto-load only the Arsenal repo.
-- If you want a GUI again later, you can re-add it separately.
