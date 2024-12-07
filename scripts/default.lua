local function import(s)
    return loadstring(game:HttpGet( ("https://raw.githubusercontent.com/stavratum/lua/main/%s.lua"):format(s) ))()
end

import("fnb/hooks")
local Connections = import("Connections")
local Util = import("fnb/util")

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

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

local Chances = {
    Marvelous = 100,
    Sick = 0,
    Good = 0,
    Ok = 0,
    Bad = 0,
    Miss = 0
}
local Offsets = {
    Marvelous = 0,
    Sick = 0.032,
    Good = 0.06,
    Ok = 0.11,
    Bad = 0.155,
    Miss = 1
}

local VirtualInputManager = (getvirtualinputmanager or game.GetService)(game, "VirtualInputManager")
local InputService = game:GetService "UserInputService"
local HttpService = game:GetService "HttpService"
local RunService = game:GetService "RunService"
local Players = game:GetService "Players"

local Client = Players.LocalPlayer
local PlayerGui = Client.PlayerGui

local set_identity = (syn and syn.set_thread_identity or setidentity or setthreadcontext)
local random = (meth and meth or math).random

local get_signal_function, Roll do 
    get_signal_function = function(Signal, Target)
        local callback
        
        set_identity(2)
        for index, connection in ipairs( getconnections(Signal) ) do
            if getfenv(connection.Function).script == Target then
                callback = connection.Function
                break
            end 
        end
        set_identity(7)
        return callback;
    end
    
    Roll = function()
        local a, b = 0, 0
        for Judgement, v in pairs(Chances) do
            a += v
        end
        if (a < 1) then return Offsets.Marvelous end
        
        a = random(a)
        for Judgement, v in pairs(Chances) do 
            b += v
            
            if (b > a) then
                return Offsets[Judgement]
            end
        end
        
        return 0
    end
end

local MAIN = Connections:Open("MAIN")
local TEMP = Connections:Open("TEMP")

local function onChildAdded(Object)
    if (not Object) then return end
    if (tostring(Object) ~= "FNFEngine") then return end
    
    Object = Object:WaitForChild("Engine")
    TEMP:Clear()
    
    local convert
    local spawn = task.spawn
    local delay = task.delay
    
    local Begin = Enum.UserInputState.Begin
    local End = Enum.UserInputState.End
    
    local GimmickNotes
    local Chart = {}
    local IncomingNotes = {}
    
    local Song, SongData, SongOffset, PBSpeed
    local Stage = Object.Stage.Value
    local Side = Object.PlayerSide.Value
    
    local TimePast = Object.Config.TimePast
    
    while (not Stage.Config.Song.Value) do
        TimePast.Changed:Wait()
    end

    while not require(Object.Modules.Functions).notetypeconvert do
        TimePast.Changed:Wait()
    end
    
    local function Find(...)
        local tostring = tostring 
        local table_find = table.find
        
        for i,v in ipairs(Song:GetDescendants()) do
            if table_find({...}, tostring(v)) then
                return v
            end
        end
        
        for i,v in ipairs(Song.Parent:GetDescendants()) do
            if table_find({...}, tostring(v))  then
                return v
            end
        end
    end

    local gc = getgc(true)
    local rawget = rawget

    for i = 1, #gc do local v = gc[i]
        if type(v) == "table" and rawget(v, "song") then
            SongData = v
            break
        end
    end
    
    PBSpeed = Object.Config.PlaybackSpeed.Value
    Song = Stage.Config.Song.Value
    SongOffset = Find("Offset")
    SongData = Object.Events.GetLibraryChart:InvokeServer()
    convert = require(Object.Modules.Functions).notetypeconvert
    
    local Offset = Client.Input.Offset.Value + SongOffset.Value
    local PoisonNotes = Find("MultipleGimmickNotes", "GimmickNotes", "MineNotes")
    
    for _, connection in ipairs(getconnections(Object.Events.UserInput.OnClientEvent)) do 
        connection:Disable()
    end
    
    
    for Index, Note in ipairs(Util.parse( SongData )) do
        local Note_1 = Note[1]
        local Key, _, HellNote = convert(Note_1[2], Note_1[4])
        Key = type(Key) == "string" and Key or "|"
        
        local function add()
            Chart[#Chart + 1] = {
                Length = Note[1][3],
                At = Note[1][1] / PBSpeed - Offset,
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
        if (mustHit and "R" or "L") ~= Side then close() end
        if HellNote and (Arrow and Arrow.Type == "OnHit" or PoisonNotes and PoisonNotes.Value == "OnHit") then close() end
        
        add()
    end
    
    for i,v in ipairs(Chart) do
        IncomingNotes[v.Key] = (IncomingNotes[v.Key] or {})
        if v.At > TimePast.Value * 1000 then 
            IncomingNotes[v.Key][#IncomingNotes[v.Key] + 1] = { v.At - 22.5, tonumber(v.Length) and (v.Length / 1000) or 0 }
        end
    end
    
    local len = 0 
    for i,v in pairs(IncomingNotes) do len += 1 end
    
    local inputFunction = get_signal_function(InputService.InputBegan, Object.Client)
    
    for Key, chart in pairs(IncomingNotes) do
        local input = Util.getKeycode(Key, len)
        local index = 1
        
        local function Check()
            local Arrow = chart[index]
            
            if Arrow and (Arrow[1] <= TimePast.Value * 1000) then
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

MAIN:Insert(PlayerGui.ChildAdded, onChildAdded)
spawn(onChildAdded, PlayerGui:FindFirstChild"FNFEngine")

-- Define the adjustSliders function
local function adjustSliders(judgment, val)
    Chances[judgment] = val
    -- Add any additional logic needed for adjusting sliders
end

-- Create percentage sliders
for judgment, value in pairs(Chances) do
    sliderObjects[judgment] = ConfigBox:AddSlider('Slider' .. judgment, {
        Text = '% ' .. judgment,
        Default = value,
        Min = 0,
        Max = 100,
        Rounding = 0,
        Compact = false,
        
        Callback = function(val)
            adjustSliders(judgment, val)
        end
    })
    
    -- Add lock toggle for each judgment
    lockedToggles[judgment] = ConfigBox:AddToggle('Lock' .. judgment, {
        Text = 'Lock ' .. judgment,
        Default = false,
        
        Callback = function(bool)
            Toggles['Lock' .. judgment].Value = bool
        end
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

if Client.Input.Keybinds.R4.Value == ";" then
    game:GetService("ReplicatedStorage").Events.RemoteEvent:FireServer("Input", "Semicolon", "R4")
end
