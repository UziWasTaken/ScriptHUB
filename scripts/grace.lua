--[[
    Grace Script
    Version: 1.0
    Author: UziWasTaken
    Description: A script for the Grace game with various features and utilities
]]

-- Constants and Configuration
local CONFIG = {
    UI = {
        TITLE = 'Grace Script',
        REPO = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/',
        CONSOLE_COLOR = "@@LIGHT_CYAN@@"
    },
    ESP = {
        DEFAULT_DISTANCE = 50,
        MIN_DISTANCE = 10,
        MAX_DISTANCE = 100
    },
    TOUCH = {
        DEFAULT_RANGE = 10,
        MIN_RANGE = 5,
        MAX_RANGE = 20
    },
    KICK = {
        DEFAULT_RANGE = 5,
        MIN_RANGE = 1,
        MAX_RANGE = 10
    },
    MOVEMENT = {
        DEFAULT_SPRINT = 0,
        MAX_SPRINT = 30,
        DEFAULT_SLIDE = 0,
        MAX_SLIDE = 30
    }
}

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Initialize UI Library
local Library = loadstring(game:HttpGet(CONFIG.UI.REPO .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(CONFIG.UI.REPO .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(CONFIG.UI.REPO .. 'addons/SaveManager.lua'))()

-- State Management
local State = {
    connections = {},
    espObjects = {},
    movementAttributes = {
        sprintSpeed = 0,
        slideSpeed = 0
    }
}

-- Create Window and Tabs
local Window = Library:CreateWindow({
    Title = CONFIG.UI.TITLE,
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Console = Window:AddTab('Console'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Utility Functions
local function cleanupConnections()
    for name, connection in pairs(State.connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    State.connections = {}
end

local function cleanupESP()
    for _, esp in pairs(State.espObjects) do
        if esp and esp.Parent then
            esp:Destroy()
        end
    end
    State.espObjects = {}
end

-- ESP Functions
local function createESP(object, isHidbox)
    local esp = Instance.new("Folder")
    esp.Name = "ESP"
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = isHidbox and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = isHidbox and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 200, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = esp
    
    esp.Parent = object
    table.insert(State.espObjects, esp)
    
    return esp
end

local function updateESP()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local maxDistance = Options.ESPDistance.Value
    
    -- Update Door ESP
    if Toggles.ESPEnabled.Value then
        for _, door in pairs(workspace:GetDescendants()) do
            if door:IsA("Model") and door.Name:match("Door") then
                local distance = (door:GetPivot().Position - humanoidRootPart.Position).Magnitude
                if distance <= maxDistance then
                    if not door:FindFirstChild("ESP") then
                        createESP(door, false)
                    end
                else
                    local esp = door:FindFirstChild("ESP")
                    if esp then esp:Destroy() end
                end
            end
        end
    end
    
    -- Update Hidbox ESP
    if Toggles.HidboxESP.Value then
        for _, hidbox in pairs(workspace:GetDescendants()) do
            if hidbox:IsA("Model") and hidbox.Name:match("Hidbox") then
                local distance = (hidbox:GetPivot().Position - humanoidRootPart.Position).Magnitude
                if distance <= maxDistance then
                    if not hidbox:FindFirstChild("ESP") then
                        createESP(hidbox, true)
                    end
                else
                    local esp = hidbox:FindFirstChild("ESP")
                    if esp then esp:Destroy() end
                end
            end
        end
    end
end

-- Movement Functions
local function updateMovementAttributes()
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Update sprint speed
    if Toggles.AutoSprint.Value then
        humanoid.WalkSpeed = humanoid.WalkSpeed + State.movementAttributes.sprintSpeed
    end
    
    -- Update slide speed (implement your slide speed logic here)
end

-- Console Functions
local function createConsole()
    rconsolesettitle(CONFIG.UI.TITLE .. " Console")
    rconsolecreate()
    rconsoleprint(CONFIG.UI.CONSOLE_COLOR)
    rconsoleprint("Grace Script Console Initialized\n")
end

local function clearConsole()
    rconsoleclear()
    rconsoleprint(CONFIG.UI.CONSOLE_COLOR)
end

-- UI Setup
local function setupUI()
    -- Main features group
    local MainGroup = Tabs.Main:AddLeftGroupbox('Game Features')
    
    -- Add toggles for each feature
    MainGroup:AddToggle('ParticleBoost', {
        Text = 'Enhanced Particles',
        Default = false,
        Tooltip = 'Increases particle rate by 10x'
    })
    
    MainGroup:AddToggle('AutoLever', {
        Text = 'Auto Lever Teleport',
        Default = false,
        Tooltip = 'Automatically teleports levers to you'
    })
    
    MainGroup:AddToggle('EntityRemoval', {
        Text = 'Remove Entities',
        Default = false,
        Tooltip = 'Removes dangerous entities'
    })
    
    -- Add GUI removal toggles
    local guiTypes = {'Eye', 'Smile', 'Goat'}
    for _, guiType in ipairs(guiTypes) do
        MainGroup:AddToggle('Remove' .. guiType .. 'Gui', {
            Text = 'Remove ' .. guiType .. ' GUI',
            Default = false,
            Tooltip = 'Removes ' .. guiType:lower() .. ' GUI'
        })
    end
    
    -- Add other toggles
    MainGroup:AddToggle('Fullbright', {
        Text = 'Fullbright',
        Default = false,
        Tooltip = 'Removes all darkness from the game'
    })
    
    MainGroup:AddToggle('AutoSprint', {
        Text = 'Auto Sprint',
        Default = false,
        Tooltip = 'Automatically holds sprint key'
    })
    
    -- Add Auto Touch features
    MainGroup:AddToggle('AutoTouch', {
        Text = 'Auto Touch',
        Default = false,
        Tooltip = 'Automatically touches interactive objects'
    })
    
    MainGroup:AddSlider('TouchRange', {
        Text = 'Touch Range',
        Default = CONFIG.TOUCH.DEFAULT_RANGE,
        Min = CONFIG.TOUCH.MIN_RANGE,
        Max = CONFIG.TOUCH.MAX_RANGE,
        Rounding = 1,
        Tooltip = 'Range for auto-touch feature'
    })
    
    -- Add Auto Kick features
    MainGroup:AddToggle('AutoKickDoor', {
        Text = 'Auto Kick Doors',
        Default = false,
        Tooltip = 'Automatically kicks doors when near them'
    })
    
    MainGroup:AddSlider('KickRange', {
        Text = 'Kick Range',
        Default = CONFIG.KICK.DEFAULT_RANGE,
        Min = CONFIG.KICK.MIN_RANGE,
        Max = CONFIG.KICK.MAX_RANGE,
        Rounding = 1,
        Tooltip = 'Range for auto-kick feature'
    })
    
    -- Add Audio toggles
    MainGroup:AddToggle('MuteAudio', {
        Text = 'Mute Entity Sounds',
        Default = false,
        Tooltip = 'Mutes tinnitus and other entity sounds'
    })
    
    MainGroup:AddToggle('MuteMusic', {
        Text = 'Mute Music',
        Default = false,
        Tooltip = 'Mutes background music'
    })
    
    MainGroup:AddToggle('MuteDoors', {
        Text = 'Mute Door Sounds',
        Default = false,
        Tooltip = 'Mutes all door-related sounds'
    })
    
    -- Add ESP group
    local ESPGroup = Tabs.Main:AddRightGroupbox('ESP Settings')
    
    ESPGroup:AddToggle('ESPEnabled', {
        Text = 'Door ESP',
        Default = false,
        Tooltip = 'Shows ESP for doors'
    })
    
    ESPGroup:AddToggle('HidboxESP', {
        Text = 'Hidbox ESP',
        Default = false,
        Tooltip = 'Shows ESP for hiding spots'
    })
    
    ESPGroup:AddSlider('ESPDistance', {
        Text = 'ESP Distance',
        Default = CONFIG.ESP.DEFAULT_DISTANCE,
        Min = CONFIG.ESP.MIN_DISTANCE,
        Max = CONFIG.ESP.MAX_DISTANCE,
        Rounding = 0,
        Tooltip = 'Maximum distance to show ESP'
    })
    
    -- Add Movement group
    local MovementGroup = Tabs.Main:AddRightGroupbox('Movement Settings')
    
    MovementGroup:AddSlider('SprintModifier', {
        Text = 'Sprint Speed',
        Default = CONFIG.MOVEMENT.DEFAULT_SPRINT,
        Min = 0,
        Max = CONFIG.MOVEMENT.MAX_SPRINT,
        Rounding = 0,
        Tooltip = 'Modifies sprint speed'
    })
    
    MovementGroup:AddSlider('SlideBooster', {
        Text = 'Slide Speed',
        Default = CONFIG.MOVEMENT.DEFAULT_SLIDE,
        Min = 0,
        Max = CONFIG.MOVEMENT.MAX_SLIDE,
        Rounding = 0,
        Tooltip = 'Modifies slide speed'
    })
    
    -- Console features
    local ConsoleGroup = Tabs.Console:AddLeftGroupbox('Console Settings')
    
    ConsoleGroup:AddButton('Create Console', createConsole)
    ConsoleGroup:AddButton('Clear Console', clearConsole)
    ConsoleGroup:AddButton('Destroy Console', rconsoledestroy)
    
    ConsoleGroup:AddInput('ConsoleTitle', {
        Default = CONFIG.UI.TITLE .. ' Console',
        Numeric = false,
        Finished = false,
        Text = 'Console Title',
        Tooltip = 'Set the title of the console window',
        Placeholder = 'Enter console title...',
        Callback = function(Value)
            rconsolesettitle(Value)
        end
    })
    
    -- UI Settings
    local SettingsGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
    
    SettingsGroup:AddButton('Unload', function()
        cleanupConnections()
        cleanupESP()
        Library:Unload()
    end)
    
    SettingsGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
        Default = 'End',
        NoUI = true,
        Text = 'Menu keybind'
    })
    
    Library.ToggleKeybind = Options.MenuKeybind
end

-- Initialize Script
local function initialize()
    -- Set up UI
    Library:SetWatermarkVisibility(true)
    Library:SetWatermark(CONFIG.UI.TITLE .. ' - v1.0')
    setupUI()
    
    -- Set up theme manager
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
    ThemeManager:SetFolder('Grace')
    SaveManager:SetFolder('Grace/configs')
    SaveManager:BuildConfigSection(Tabs['UI Settings'])
    ThemeManager:ApplyToTab(Tabs['UI Settings'])
    
    -- Load config
    SaveManager:LoadAutoloadConfig()
    
    -- Set up ESP update loop
    State.connections.espUpdate = RunService.RenderStepped:Connect(updateESP)
    
    -- Set up character added handler
    State.connections.characterAdded = LocalPlayer.CharacterAdded:Connect(function(character)
        updateMovementAttributes()
    end)
end

initialize()
