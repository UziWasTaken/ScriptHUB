local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

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

-- Aimbot Tab
local AimbotGroup = Tabs.Aimbot:AddLeftGroupbox('Aimbot')
AimbotGroup:AddToggle('AimbotEnabled', {
    Text = 'Enabled',
    Default = false,
    Tooltip = 'Enables the aimbot functionality'
})

-- Visuals Tab
local VisualsGroup = Tabs.Visuals:AddLeftGroupbox('Visual Features')
-- Add your visual features here

-- UI Settings Tab
local UISettingsTab = Tabs['UI Settings']
ThemeManager:ApplyToTab(UISettingsTab)
SaveManager:BuildConfigSection(UISettingsTab)

-- Set up the library toggle keybind
Library.ToggleKeybind = Options.MenuKeybind

-- Set up watermark
Library:SetWatermarkVisibility(true)
Library:SetWatermark('Universal Script')

-- Load autoload config
SaveManager:LoadAutoloadConfig()

-- Handle aimbot activation
local UIS = game:GetService("UserInputService")

UIS.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Toggles.AimbotEnabled then
            Toggles.AimbotEnabled.Value = true
        end
    end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Toggles.AimbotEnabled then
            Toggles.AimbotEnabled.Value = false
        end
    end
end)
