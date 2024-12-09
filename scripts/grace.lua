--[[
    Grace Script
    Version: 1.0
    Author: UziWasTaken
    Description: Enhanced gameplay script with UI controls and movement features
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

-- Constants
local CONFIG = {
    UI = {
        TITLE = "Grace Script",
        CONSOLE_COLOR = "@@LIGHT_CYAN@@",
        WATERMARK = "Grace Script | v1.0",
        KEYBIND = "RightControl"
    },
    MOVEMENT = {
        DEFAULT_WALKSPEED = 16,
        DEFAULT_JUMPPOWER = 50,
        MAX_WALKSPEED = 500,
        MAX_JUMPPOWER = 500,
        DEFAULT_SPRINT = 0,
        MAX_SPRINT = 30,
        DEFAULT_SLIDE = 0,
        MAX_SLIDE = 30
    },
    ESP = {
        DEFAULT_DISTANCE = 50,
        MIN_DISTANCE = 10,
        MAX_DISTANCE = 200,
        COLORS = {
            DOOR = Color3.fromRGB(255, 255, 0),
            HIDBOX = Color3.fromRGB(0, 255, 0)
        }
    }
}

-- Variables
local LocalPlayer = Players.LocalPlayer
local State = {
    connections = {},
    movement = {
        walkspeed = CONFIG.MOVEMENT.DEFAULT_WALKSPEED,
        jumppower = CONFIG.MOVEMENT.DEFAULT_JUMPPOWER,
        sprintSpeed = CONFIG.MOVEMENT.DEFAULT_SPRINT,
        slideSpeed = CONFIG.MOVEMENT.DEFAULT_SLIDE
    },
    espObjects = {},
    fullbright = false,
    originalLighting = {
        Ambient = Lighting.Ambient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd,
        GlobalShadows = Lighting.GlobalShadows,
        OutdoorAmbient = Lighting.OutdoorAmbient
    }
}

-- Library Setup
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/Library.lua"))()
local Window = Library:CreateWindow({
    Title = CONFIG.UI.TITLE,
    Center = true,
    AutoShow = true
})

-- UI Elements
local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Utility Functions
local function clearPrintHistory()
    for i = 1, 50 do
        print("\n")
    end
    print(CONFIG.UI.CONSOLE_COLOR)
end

-- ESP Functions
local function createESP(object, isHidbox)
    if not object:IsDescendantOf(workspace) then return end
    
    local esp = Instance.new("Highlight")
    esp.Name = "ESP"
    esp.FillColor = isHidbox and CONFIG.ESP.COLORS.HIDBOX or CONFIG.ESP.COLORS.DOOR
    esp.OutlineColor = isHidbox and CONFIG.ESP.COLORS.HIDBOX or CONFIG.ESP.COLORS.DOOR
    esp.FillTransparency = 0.5
    esp.OutlineTransparency = 0
    esp.Adornee = object
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
    
    -- Clean up old ESP
    for i = #State.espObjects, 1, -1 do
        local esp = State.espObjects[i]
        if esp and esp.Parent then
            esp:Destroy()
        end
        table.remove(State.espObjects, i)
    end
    
    -- Update Door ESP
    if Toggles.ESPEnabled.Value then
        for _, door in ipairs(workspace:GetDescendants()) do
            if door:IsA("Model") and door.Name:match("Door") then
                local distance = (door:GetPivot().Position - humanoidRootPart.Position).Magnitude
                if distance <= maxDistance then
                    createESP(door, false)
                end
            end
        end
    end
    
    -- Update Hidbox ESP
    if Toggles.HidboxESP.Value then
        for _, hidbox in ipairs(workspace:GetDescendants()) do
            if hidbox:IsA("Model") and hidbox.Name:match("Hidbox") then
                local distance = (hidbox:GetPivot().Position - humanoidRootPart.Position).Magnitude
                if distance <= maxDistance then
                    createESP(hidbox, true)
                end
            end
        end
    end
end

-- Movement Functions
local function updateMovementAttributes()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        local totalSpeed = State.movement.walkspeed
        
        if Toggles.AutoSprint and Toggles.AutoSprint.Value then
            totalSpeed = totalSpeed + State.movement.sprintSpeed
        end
        
        -- Use setpropertylevel to bypass anti-cheat
        if gethiddenproperty then
            sethiddenproperty(humanoid, "WalkSpeed", totalSpeed)
            sethiddenproperty(humanoid, "JumpPower", State.movement.jumppower)
        else
            -- Fallback to regular property setting
            humanoid.WalkSpeed = totalSpeed
            humanoid.JumpPower = State.movement.jumppower
        end
    end
end

-- Entity Management
local function removeEntities()
    if not Toggles.EntityRemoval.Value then return end
    
    for _, entity in ipairs(workspace:GetChildren()) do
        if entity:IsA("Model") and entity.Name:match("Entity") then
            entity:Destroy()
        end
    end
end

-- GUI Management
local function updateGUI()
    for _, guiType in ipairs({'Eye', 'Smile', 'Goat'}) do
        if Toggles['Remove' .. guiType .. 'Gui'] and Toggles['Remove' .. guiType .. 'Gui'].Value then
            for _, gui in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
                if gui.Name:match(guiType) then
                    gui.Enabled = false
                end
            end
        end
    end
end

-- Sound Management
local function updateSounds()
    for _, sound in ipairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            if Toggles.MuteAudio and Toggles.MuteAudio.Value and sound.Name:match("Entity") then
                sound.Volume = 0
            elseif Toggles.MuteMusic and Toggles.MuteMusic.Value and sound.Name:match("Music") then
                sound.Volume = 0
            elseif Toggles.MuteDoors and Toggles.MuteDoors.Value and sound.Name:match("Door") then
                sound.Volume = 0
            end
        end
    end
end

-- UI Setup Functions
local function setupMovementControls(group)
    group:AddSlider('WalkSpeed', {
        Text = 'Walk Speed',
        Default = CONFIG.MOVEMENT.DEFAULT_WALKSPEED,
        Min = 0,
        Max = CONFIG.MOVEMENT.MAX_WALKSPEED,
        Rounding = 1,
        Compact = false,
        Callback = function(value)
            State.movement.walkspeed = value
            updateMovementAttributes()
        end
    })

    group:AddSlider('JumpPower', {
        Text = 'Jump Power',
        Default = CONFIG.MOVEMENT.DEFAULT_JUMPPOWER,
        Min = 0,
        Max = CONFIG.MOVEMENT.MAX_JUMPPOWER,
        Rounding = 1,
        Compact = false,
        Callback = function(value)
            State.movement.jumppower = value
            updateMovementAttributes()
        end
    })

    group:AddSlider('SprintModifier', {
        Text = 'Sprint Speed',
        Default = CONFIG.MOVEMENT.DEFAULT_SPRINT,
        Min = 0,
        Max = CONFIG.MOVEMENT.MAX_SPRINT,
        Rounding = 0,
        Callback = function(value)
            State.movement.sprintSpeed = value
            updateMovementAttributes()
        end
    })

    group:AddToggle('AutoSprint', {
        Text = 'Auto Sprint',
        Default = false,
        Tooltip = 'Automatically holds sprint key',
        Callback = updateMovementAttributes
    })
end

local function setupGameFeatures(group)
    group:AddToggle('Fullbright', {
        Text = 'Fullbright',
        Default = false,
        Tooltip = 'Removes all darkness',
        Callback = function(value)
            State.fullbright = value
            if value then
                if sethiddenproperty then
                    sethiddenproperty(Lighting, "Brightness", 2)
                    sethiddenproperty(Lighting, "ClockTime", 14)
                    sethiddenproperty(Lighting, "FogEnd", 100000)
                    sethiddenproperty(Lighting, "GlobalShadows", false)
                else
                    Lighting.Brightness = 2
                    Lighting.ClockTime = 14
                    Lighting.FogEnd = 100000
                    Lighting.GlobalShadows = false
                end
            else
                if sethiddenproperty then
                    sethiddenproperty(Lighting, "Brightness", State.originalLighting.Brightness)
                    sethiddenproperty(Lighting, "ClockTime", State.originalLighting.ClockTime)
                    sethiddenproperty(Lighting, "FogEnd", State.originalLighting.FogEnd)
                    sethiddenproperty(Lighting, "GlobalShadows", State.originalLighting.GlobalShadows)
                else
                    Lighting.Brightness = State.originalLighting.Brightness
                    Lighting.ClockTime = State.originalLighting.ClockTime
                    Lighting.FogEnd = State.originalLighting.FogEnd
                    Lighting.GlobalShadows = State.originalLighting.GlobalShadows
                end
            end
        end
    })

    group:AddToggle('EntityRemoval', {
        Text = 'Remove Entities',
        Default = false,
        Tooltip = 'Removes dangerous entities'
    })

    -- GUI Removal Toggles
    local guiTypes = {'Eye', 'Smile', 'Goat'}
    for _, guiType in ipairs(guiTypes) do
        group:AddToggle('Remove' .. guiType .. 'Gui', {
            Text = 'Remove ' .. guiType .. ' GUI',
            Default = false,
            Tooltip = 'Removes ' .. guiType:lower() .. ' GUI'
        })
    end

    -- Audio Toggles
    group:AddToggle('MuteAudio', {
        Text = 'Mute Entity Sounds',
        Default = false,
        Tooltip = 'Mutes tinnitus and other entity sounds'
    })

    group:AddToggle('MuteMusic', {
        Text = 'Mute Music',
        Default = false,
        Tooltip = 'Mutes background music'
    })

    group:AddToggle('MuteDoors', {
        Text = 'Mute Door Sounds',
        Default = false,
        Tooltip = 'Mutes all door-related sounds'
    })
end

local function setupESPControls(group)
    group:AddToggle('ESPEnabled', {
        Text = 'Door ESP',
        Default = false,
        Tooltip = 'Shows ESP for doors'
    })

    group:AddToggle('HidboxESP', {
        Text = 'Hidbox ESP',
        Default = false,
        Tooltip = 'Shows ESP for hiding spots'
    })

    group:AddSlider('ESPDistance', {
        Text = 'ESP Distance',
        Default = CONFIG.ESP.DEFAULT_DISTANCE,
        Min = CONFIG.ESP.MIN_DISTANCE,
        Max = CONFIG.ESP.MAX_DISTANCE,
        Rounding = 0,
        Tooltip = 'Maximum distance to show ESP'
    })
end

local function setupUISettings()
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
    
    MenuGroup:AddButton('Unload', function() 
        -- Restore original lighting
        if State.fullbright then
            for prop, value in pairs(State.originalLighting) do
                if sethiddenproperty then
                    sethiddenproperty(Lighting, prop, value)
                else
                    Lighting[prop] = value
                end
            end
        end
        
        -- Clean up connections
        for _, connection in pairs(State.connections) do
            if typeof(connection) == "RBXScriptConnection" then
                connection:Disconnect()
            end
        end
        
        -- Clean up ESP
        for _, esp in pairs(State.espObjects) do
            if esp and esp.Parent then
                esp:Destroy()
            end
        end
        
        Library:Unload() 
    end)
    
    MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = CONFIG.UI.KEYBIND })
    
    Library.ToggleKeybind = Options.MenuKeybind
    
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
    
    ThemeManager:SetFolder('MyScriptHub')
    SaveManager:SetFolder('MyScriptHub/specific-game')
    
    SaveManager:BuildConfigSection(Tabs['UI Settings'])
    ThemeManager:ApplyToTab(Tabs['UI Settings'])
end

-- Initialization
local function initialize()
    -- Setup UI Groups
    local MovementGroup = Tabs.Main:AddLeftGroupbox('Movement')
    setupMovementControls(MovementGroup)
    
    local FeaturesGroup = Tabs.Main:AddRightGroupbox('Game Features')
    setupGameFeatures(FeaturesGroup)
    
    local ESPGroup = Tabs.Main:AddLeftGroupbox('ESP Settings')
    setupESPControls(ESPGroup)
    
    -- Setup UI Settings
    setupUISettings()
    
    -- Initialize movement
    updateMovementAttributes()
    
    -- Setup connections
    State.connections.characterAdded = LocalPlayer.CharacterAdded:Connect(updateMovementAttributes)
    State.connections.espUpdate = RunService.RenderStepped:Connect(updateESP)
    State.connections.entityRemoval = RunService.Heartbeat:Connect(removeEntities)
    State.connections.guiUpdate = RunService.Heartbeat:Connect(updateGUI)
    State.connections.soundUpdate = RunService.Heartbeat:Connect(updateSounds)
    
    -- Print initialization message
    print(CONFIG.UI.CONSOLE_COLOR)
    print("Grace Script Initialized\n")
end

-- Start the script
initialize()
