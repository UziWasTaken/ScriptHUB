--[[
    Universal Script Loader
    Version: 1.0
    Author: UziWasTaken
    Description: A universal script loader that detects and loads game-specific scripts
]]

-- Constants
local CONFIG = {
    TITLE = "Script Loader",
    VERSION = "1.0",
    AUTHOR = "UziWasTaken",
    LOADING_FRAMES = {"|", "/", "-", "\\"},
    SCRIPT_URLS = {
        GRACE = "https://raw.githubusercontent.com/UziWasTaken/ScriptHUB/refs/heads/main/scripts/grace.lua",
        FNB = "https://raw.githubusercontent.com/UziWasTaken/ScriptHUB/main/scripts/FNB.lua",
        DEFAULT = "https://raw.githubusercontent.com/UziWasTaken/ScriptHUB/main/scripts/default.lua"
    },
    COLORS = {
        CYAN = "@@LIGHT_CYAN@@",
        BLUE = "@@LIGHT_BLUE@@",
        MAGENTA = "@@LIGHT_MAGENTA@@",
        YELLOW = "@@YELLOW@@",
        GREEN = "@@LIGHT_GREEN@@",
        RED = "@@RED@@"
    }
}

-- Services
local MarketplaceService = game:GetService("MarketplaceService")

-- Initialize console
local function initializeConsole()
    rconsolesettitle(CONFIG.TITLE)
    rconsolecreate()
    rconsoleclear()
end

-- UI Functions
local function printLogo()
    rconsoleprint(CONFIG.COLORS.CYAN)
    rconsoleprint([[
    ╔═══════════════════════════════════════╗
    ║           SCRIPT LOADER v1.0          ║
    ║         Created by UziWasTaken        ║
    ╚═══════════════════════════════════════╝
    ]])
end

local function animateLoading(text)
    for i = 1, 15 do
        rconsoleprint(CONFIG.COLORS.BLUE)
        rconsoleprint("\r" .. text .. " " .. CONFIG.LOADING_FRAMES[i % 4 + 1])
        task.wait(0.1)
    end
    rconsoleprint("\n")
end

local function log(color, message)
    rconsoleprint(color)
    rconsoleprint(message .. "\n")
end

-- Game Detection
local function getGameInfo()
    local success, gameInfo = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    
    if not success then
        log(CONFIG.COLORS.RED, "➤ Error getting game info: " .. tostring(gameInfo))
        return nil
    end
    
    return gameInfo
end

local function detectGameScript()
    local gameInfo = getGameInfo()
    if not gameInfo then return CONFIG.SCRIPT_URLS.DEFAULT end
    
    -- Debug logging
    log(CONFIG.COLORS.YELLOW, "➤ Debug - Place ID: " .. tostring(game.PlaceId))
    log(CONFIG.COLORS.YELLOW, "➤ Debug - Game Name: " .. tostring(gameInfo.Name))
    log(CONFIG.COLORS.YELLOW, "➤ Debug - Creator: " .. tostring(gameInfo.Creator.Name))
    
    -- Game detection logic
    local gameName = gameInfo.Name
    if gameName:match("[Gg]race") then
        log(CONFIG.COLORS.GREEN, "➤ Debug - Matched Grace game pattern")
        return CONFIG.SCRIPT_URLS.GRACE
    elseif game.PlaceId == 7603193259 then
        return CONFIG.SCRIPT_URLS.FNB
    end
    
    log(CONFIG.COLORS.RED, "➤ Debug - No match found, using default script")
    return CONFIG.SCRIPT_URLS.DEFAULT
end

-- Script Loading
local function loadScript(scriptUrl)
    local success, result = pcall(function()
        local scriptContent = game:HttpGet(scriptUrl)
        return loadstring(scriptContent)()
    end)
    
    if success then
        log(CONFIG.COLORS.GREEN, "✓ Script loaded successfully!")
    else
        log(CONFIG.COLORS.RED, "✗ Error loading script: " .. tostring(result))
    end
    
    return success
end

-- Main Execution
local function main()
    -- Initialize
    initializeConsole()
    printLogo()
    rconsoleprint("\n")
    
    -- Show executor info
    local executor, version = identifyexecutor()
    log(CONFIG.COLORS.MAGENTA, "➤ Executor: " .. executor .. " (v" .. version .. ")")
    task.wait(0.5)
    
    -- Detect and load game script
    local gameInfo = getGameInfo()
    if gameInfo then
        log(CONFIG.COLORS.GREEN, "➤ Detected Game: " .. gameInfo.Name)
    end
    task.wait(0.5)
    
    local scriptUrl = detectGameScript()
    animateLoading("Fetching script URL")
    log(CONFIG.COLORS.GREEN, "➤ Script URL: " .. scriptUrl)
    task.wait(0.5)
    
    animateLoading("Loading script")
    loadScript(scriptUrl)
    
    task.wait(2)
end

-- Start the loader
main()
