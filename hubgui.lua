local ArsenalURL = "https://raw.githubusercontent.com/confessess/AR097125409721047210947/main/main.lua"
local BloxStrikeURL = "https://raw.githubusercontent.com/confessess/BS097510971057105710957/main/main.lua"
local MM2URL = "https://raw.githubusercontent.com/confessess/MM097059417091750917/main/main.lua"
local FTAPURL = "https://raw.githubusercontent.com/confessess/FTAP097509175091765091750/main/main.lua"
local PrisonLifeURL = "https://raw.githubusercontent.com/confessess/PL09714017540917509/refs/heads/main/main.lua"
local RivalsURL = "https://raw.githubusercontent.com/confessess/RVLS0917509175075097/refs/heads/main/main.lua"
local SpellingBeeURL = "https://raw.githubusercontent.com/confessess/SPPLNG01972501675/refs/heads/main/main.lua"

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

if game.PlaceId == 155615604 then
    safeLoad(PrisonLifeURL, "Prison Life")
    return
end

if game.PlaceId == 17590362521 then
    safeLoad(SpellingBeeURL, "Spelling Bee")
    return
end

local RivalsPlaceIds = {
    [17625359962] = true,
    [133215910299950] = true,
    [129604661913557] = true,
    [117398147513099] = true,
    [71874690745115] = true,
    [18126510175] = true,
}

if RivalsPlaceIds[game.PlaceId] then
    safeLoad(RivalsURL, "Rivals")
    return
end