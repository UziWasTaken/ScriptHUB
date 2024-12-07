local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Universal Script',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Main features group
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

-- Implement feature callbacks
Toggles.WalkSpeedEnabled:OnChanged(function()
    if Toggles.WalkSpeedEnabled.Value then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Options.WalkSpeedValue.Value
    else
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

Options.WalkSpeedValue:OnChanged(function()
    if Toggles.WalkSpeedEnabled.Value then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Options.WalkSpeedValue.Value
    end
end)

Toggles.JumpPowerEnabled:OnChanged(function()
    if Toggles.JumpPowerEnabled.Value then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Options.JumpPowerValue.Value
    else
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
    end
end)

Options.JumpPowerValue:OnChanged(function()
    if Toggles.JumpPowerEnabled.Value then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = Options.JumpPowerValue.Value
    end
end)

-- UI Settings
local SettingsGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
SettingsGroup:AddButton('Unload', function() Library:Unload() end)
SettingsGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

-- Theme and Save Manager Setup
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('UniversalScript')
SaveManager:SetFolder('UniversalScript/GameConfigs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()
