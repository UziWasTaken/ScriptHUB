--[[
    Friday Night Bloxxin' Script
    Version: 1.0
    Author: UziWasTaken
    Description: Auto-player script for Friday Night Bloxxin'
]]

-- Constants and Configuration
local CONFIG = {
    URLS = {
        HOOKS = "https://raw.githubusercontent.com/stavratum/lua/main/fnb/hooks",
        CONNECTIONS = "https://raw.githubusercontent.com/stavratum/lua/main/Connections",
        UTIL = "https://raw.githubusercontent.com/stavratum/lua/main/fnb/util",
        UI_REPO = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
    },
    JUDGMENTS = {
        Marvelous = { chance = 100, offset = 0 },
        Sick = { chance = 0, offset = 0.032 },
        Good = { chance = 0, offset = 0.06 },
        Ok = { chance = 0, offset = 0.11 },
        Bad = { chance = 0, offset = 0.155 },
        Miss = { chance = 0, offset = 1 }
    }
}

-- Utility Functions
local function import(modulePath)
    return loadstring(game:HttpGet(("https://raw.githubusercontent.com/stavratum/lua/main/%s.lua"):format(modulePath)))()
end

-- Import Dependencies
local Hooks = import("fnb/hooks")
local Connections = import("Connections")
local Util = import("fnb/util")

-- Initialize UI Library
local Library = loadstring(game:HttpGet(CONFIG.URLS.UI_REPO .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(CONFIG.URLS.UI_REPO .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(CONFIG.URLS.UI_REPO .. 'addons/SaveManager.lua'))()

-- Create main window
local Window = Library:CreateWindow({
    Title = 'Friday Night Bloxxin\'',
    Center = true,
    AutoShow = true,
})

-- Create tabs
local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Create main groupboxes
local ConfigBox = Tabs.Main:AddLeftGroupbox('Configuration')
local ControlBox = Tabs.Main:AddRightGroupbox('Controls')
local UtilityBox = Tabs.Main:AddRightGroupbox('Utility')

-- Store our controls
local sliderObjects = {}
local lockedToggles = {}

-- Game Logic
local function onChildAdded(Object)
    if not Object or tostring(Object) ~= "FNFEngine" then return end
    
    local Engine = Object:WaitForChild("Engine")
    TEMP:Clear()
    
    -- Initialize Game State
    local GameState = {
        convert = nil,
        spawn = task.spawn,
        delay = task.delay,
        Begin = Enum.UserInputState.Begin,
        End = Enum.UserInputState.End,
        GimmickNotes = nil,
        Chart = {},
        IncomingNotes = {},
        Song = nil,
        SongData = nil,
        SongOffset = nil,
        PBSpeed = nil,
        Stage = Engine.Stage.Value,
        Side = Engine.PlayerSide.Value,
        TimePast = Engine.Config.TimePast
    }
    
    -- Wait for required game elements
    while not GameState.Stage.Config.Song.Value do
        GameState.TimePast.Changed:Wait()
    end
    
    while not require(Engine.Modules.Functions).notetypeconvert do
        GameState.TimePast.Changed:Wait()
    end
    
    local function Find(...)
        local tostring = tostring 
        local table_find = table.find
        
        for i,v in ipairs(GameState.Song:GetDescendants()) do
            if table_find({...}, tostring(v)) then
                return v
            end
        end
        
        for i,v in ipairs(GameState.Song.Parent:GetDescendants()) do
            if table_find({...}, tostring(v))  then
                return v
            end
        end
    end

    local gc = getgc(true)
    local rawget = rawget

    for i = 1, #gc do local v = gc[i]
        if type(v) == "table" and rawget(v, "song") then
            GameState.SongData = v
            break
        end
    end
    
    GameState.PBSpeed = Engine.Config.PlaybackSpeed.Value
    GameState.Song = GameState.Stage.Config.Song.Value
    GameState.SongOffset = Find("Offset")
    GameState.SongData = Engine.Events.GetLibraryChart:InvokeServer()
    GameState.convert = require(Engine.Modules.Functions).notetypeconvert
    
    local Offset = Client.Input.Offset.Value + GameState.SongOffset.Value
    local PoisonNotes = Find("MultipleGimmickNotes", "GimmickNotes", "MineNotes")
    
    for _, connection in ipairs(getconnections(Engine.Events.UserInput.OnClientEvent)) do 
        connection:Disable()
    end
    
    -- Parse Song Data
    for Index, Note in ipairs(Util.parse( GameState.SongData )) do
        local Note_1 = Note[1]
        local Key, _, HellNote = GameState.convert(Note_1[2], Note_1[4])
        Key = type(Key) == "string" and Key or "|"
        
        local function add()
            GameState.Chart[#GameState.Chart + 1] = {
                Length = Note[1][3],
                At = Note[1][1] / GameState.PBSpeed - Offset,
                Key = Key:split"_"[1]
            }
        end
        
        local function close()
            add = function() end
        end
        
        --
    
        local mustHit
        
        if (not Key or Key:find"|") then close() end
        if type(Note[2]) ~= "table" then close() else
            mustHit = Note[2].mustHitSection
        end
        
        local Arrow = PoisonNotes and PoisonNotes:FindFirstChild(Key:split"_"[2] or Key:split"_"[1])
        Arrow = Arrow and require(Arrow.ModuleScript)
        
        if (_) then mustHit = not mustHit end
        if (mustHit and "R" or "L") ~= GameState.Side then close() end
        if HellNote and (Arrow and Arrow.Type == "OnHit" or PoisonNotes and PoisonNotes.Value == "OnHit") then close() end
        
        add()
    end
    
    -- Process Incoming Notes
    for i,v in ipairs(GameState.Chart) do
        GameState.IncomingNotes[v.Key] = (GameState.IncomingNotes[v.Key] or {})
        if v.At > GameState.TimePast.Value * 1000 then 
            GameState.IncomingNotes[v.Key][#GameState.IncomingNotes[v.Key] + 1] = { v.At - 22.5, tonumber(v.Length) and (v.Length / 1000) or 0 }
        end
    end
    
    -- Initialize Input Function
    local inputFunction = get_signal_function(InputService.InputBegan, Engine.Client)
    
    -- Process Incoming Notes
    for Key, chart in pairs(GameState.IncomingNotes) do
        local input = Util.getKeycode(Key, #GameState.IncomingNotes)
        local index = 1
        
        local function Check()
            local Arrow = chart[index]
            
            if Arrow and (Arrow[1] <= GameState.TimePast.Value * 1000) then
                index = index + 1
                
                if (not Flags.IsAnimeFan) then return end
                local Offset = Roll()
                if (Offset == 1) then return end
                
                if (Flags.FireDirectly) then 
                    set_identity(2)   
                    
                    delay(Offset, inputFunction, { KeyCode = input, UserInputState = Begin })
                    delay(Arrow[2] + Offset, inputFunction, { KeyCode = input, UserInputState = End })
                else
                    set_identity(7)
                    
                    delay(Offset, VirtualInputManager.SendKeyEvent, VirtualInputManager, true, input, false, nil)
                    delay(Arrow[2] + Offset, VirtualInputManager.SendKeyEvent, VirtualInputManager, false, input, false, nil)
                end
                
                spawn(Check)
            end
        end
        
        TEMP:Insert(RunService.RenderStepped, Check)
    end
end

-- UI Setup
local function setupUI()
    -- Create percentage sliders
    local judgments = {"Marvelous", "Sick", "Good", "Ok", "Bad", "Miss"}
    
    for _, judgment in ipairs(judgments) do
        sliderObjects[judgment] = ConfigBox:AddSlider('Slider' .. judgment, {
            Text = '% ' .. judgment,
            Default = CONFIG.JUDGMENTS[judgment].chance,
            Min = 0,
            Max = 100,
            Rounding = 0,
            Compact = false,
            Callback = function(val) adjustSliders(judgment, val) end
        })
        
        lockedToggles[judgment] = ConfigBox:AddToggle('Lock' .. judgment, {
            Text = 'Lock ' .. judgment,
            Default = false,
            Callback = function(bool) Toggles['Lock' .. judgment].Value = bool end
        })
    end
    
    -- Add main controls
    ControlBox:AddToggle('AutoPlayer', {
        Text = 'Toggle Autoplayer',
        Default = false,
        
        Callback = function(bool)
            Flags.IsAnimeFan = bool
        end
    })

    ControlBox:AddToggle('DirectSignals', {
        Text = 'Fire Signals Directly',
        Default = false,
        
        Callback = function(bool)
            Flags.FireDirectly = bool
        end
    })

    -- Add utility buttons
    UtilityBox:AddButton({
        Text = 'Unload Script',
        Func = function()
            set_identity(7)
            Connections:Destroy()
            Library:Unload()
        end,
    })

    UtilityBox:AddButton({
        Text = 'Copy Discord Invite',
        Func = function()
            local code = game:HttpGet "https://stavratum.github.io/invite"
            local invite = "discord.gg" .. "/" .. code
            setclipboard(invite)
        end,
    })

    -- UI Settings tab setup
    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

    MenuGroup:AddButton({
        Text = 'Unload',
        Func = function() 
            Library:Unload() 
        end
    })

    MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { 
        Default = 'End', 
        NoUI = true, 
        Text = 'Menu keybind' 
    })

    Library.ToggleKeybind = Options.MenuKeybind

    -- Set up theme and save managers
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)

    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

    ThemeManager:SetFolder('FNB')
    SaveManager:SetFolder('FNB/configs')

    SaveManager:BuildConfigSection(Tabs['UI Settings'])
    ThemeManager:ApplyToTab(Tabs['UI Settings'])

    -- Initialize watermark
    Library:SetWatermarkVisibility(true)
    Library:SetWatermark('Friday Night Bloxxin\' - v1.0')

    -- Load autoload config
    SaveManager:LoadAutoloadConfig()
end

-- Initialize Script
MAIN:Insert(PlayerGui.ChildAdded, onChildAdded)
spawn(onChildAdded, PlayerGui:FindFirstChild"FNFEngine")
setupUI()
