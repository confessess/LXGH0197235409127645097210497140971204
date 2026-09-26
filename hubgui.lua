local ArsenalURL = "https://raw.githubusercontent.com/confessess/AR097125409721047210947/main/main.lua"
local BloxStrikeURL = "https://raw.githubusercontent.com/confessess/BS097510971057105710957/main/main.lua"
local MM2URL = "https://raw.githubusercontent.com/confessess/MM097059417091750917/main/main.lua"
local FTAPURL = "https://raw.githubusercontent.com/confessess/FTAP097509175091765091750/main/main.lua"

local function safeLoad(url, name)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not ok then
        warn("[LightHub] Failed to load " .. name .. " script: " .. tostring(result))
        return false
    end

    return true
end

if game.PlaceId == 286090429 then
    safeLoad(ArsenalURL, "Arsenal")
    return
end

if game.PlaceId == 114234929420007 then
    safeLoad(BloxStrikeURL, "Blox Strike")
    return
end

if game.PlaceId == 142823291 then
    safeLoad(MM2URL, "MM2")
    return
end

if game.PlaceId == 6961824067 then
    safeLoad(FTAPURL, "FTAP")
    return
end
