local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- First create the window
local Window = Library:CreateWindow({
    Title = 'Universal Script',
    Center = true,
    AutoShow = true,
})

-- Create all tabs first
local Tabs = {
    Main = Window:AddTab('Main'),
    Aimbot = Window:AddTab('Aimbot'),
    Visuals = Window:AddTab('Visuals'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Initialize Flags table
local Flags = {}

-- Main Tab
local MainGroup = Tabs.Main:AddLeftGroupbox('Player Features')

MainGroup:AddToggle('WalkSpeedEnabled', {
    Text = 'WalkSpeed Enabled',
    Default = false,
    Tooltip = 'Enables WalkSpeed modification',
})

MainGroup:AddSlider('WalkSpeedValue', {
    Text = 'WalkSpeed',
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
})

MainGroup:AddToggle('JumpPowerEnabled', {
    Text = 'JumpPower Enabled',
    Default = false,
    Tooltip = 'Enables JumpPower modification',
})

MainGroup:AddSlider('JumpPowerValue', {
    Text = 'JumpPower',
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
})

-- Aimbot Tab
local AimbotGroup = Tabs.Aimbot:AddLeftGroupbox('Aimbot Settings')

AimbotGroup:AddToggle('AimbotEnabled', {
    Text = 'Enable Aimbot',
    Default = false,
    Tooltip = 'Toggles aimbot functionality',
})

-- Changed keybind to use UserInputType instead of KeyCode
AimbotGroup:AddToggle('AimbotActive', {
    Text = 'Aimbot Active',
    Default = false,
})

AimbotGroup:AddToggle('AimbotTeamCheck', {
    Text = 'Team Check',
    Default = true,
})

AimbotGroup:AddSlider('AimbotFOV', {
    Text = 'FOV',
    Default = 100,
    Min = 0,
    Max = 360,
    Rounding = 0,
})

AimbotGroup:AddSlider('AimbotSmoothness', {
    Text = 'Smoothness',
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
})

-- Visuals Tab
local VisualsGroup = Tabs.Visuals:AddLeftGroupbox('ESP Settings')

VisualsGroup:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
})

VisualsGroup:AddToggle('BoxESP', {
    Text = 'Boxes',
    Default = true,
})

VisualsGroup:AddToggle('TracerESP', {
    Text = 'Tracers',
    Default = false,
})

VisualsGroup:AddToggle('NameESP', {
    Text = 'Names',
    Default = true,
})

VisualsGroup:AddToggle('DistanceESP', {
    Text = 'Distance',
    Default = true,
})

-- UI Settings Tab
local SettingsGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

SettingsGroup:AddButton('Unload', function() 
    Library:Unload() 
end)

SettingsGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { 
    Default = 'End', 
    NoUI = true, 
    Text = 'Menu keybind' 
})

-- Initialize theme manager and save manager
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('UniversalScript')
SaveManager:SetFolder('UniversalScript/GameConfigs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- Set up the library toggle keybind
Library.ToggleKeybind = Options.MenuKeybind

-- Implement aimbot using UserInputService
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Toggles.AimbotActive.Value = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Toggles.AimbotActive.Value = false
    end
end)

-- Load autoload config
SaveManager:LoadAutoloadConfig()
