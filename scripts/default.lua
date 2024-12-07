local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Initialize Theme and Save Manager FIRST
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')

-- Create window
local Window = Library:CreateWindow({
    Title = 'Universal Script',
    Center = true,
    AutoShow = true,
})

-- Create all tabs
local Tabs = {
    Main = Window:AddTab('Main'),
    Aimbot = Window:AddTab('Aimbot'),
    Visuals = Window:AddTab('Visuals'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

-- Main Tab
local MainGroup = Tabs.Main:AddLeftGroupbox('Player Features')
MainGroup:AddToggle('WalkSpeedEnabled', {
    Text = 'WalkSpeed Enabled',
    Default = false,
    Tooltip = 'Enables WalkSpeed modification'
})

MainGroup:AddSlider('WalkSpeed', {
    Text = 'WalkSpeed',
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Compact = false,
})

MainGroup:AddToggle('JumpPowerEnabled', {
    Text = 'JumpPower Enabled',
    Default = false,
    Tooltip = 'Enables JumpPower modification'
})

MainGroup:AddSlider('JumpPower', {
    Text = 'JumpPower',
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Compact = false,
})

-- Visuals Tab
local VisualsGroup = Tabs.Visuals:AddLeftGroupbox('Visual Features')

-- UI Settings Tab
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

-- Load autoload config
SaveManager:LoadAutoloadConfig()

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Transparency = 0.5
FOVCircle.Visible = true

game:GetService("RunService").RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = game:GetService("UserInputService"):GetMouseLocation()
    end
end)

game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "ScreenGui" then
        FOVCircle:Remove()
    end
end)
