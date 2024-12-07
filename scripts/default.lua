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

-- FOV Circle Settings
AimbotGroup:AddToggle('ShowFOV', {
    Text = 'Show FOV Circle',
    Default = true,
    Tooltip = 'Shows or hides the FOV circle'
})

AimbotGroup:AddSlider('FOVSize', {
    Text = 'FOV Size',
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Compact = false,
})

AimbotGroup:AddToggle('FOVFilled', {
    Text = 'Filled FOV',
    Default = false,
    Tooltip = 'Makes the FOV circle filled or not'
})

-- Create FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = Options.FOVSize.Value
FOVCircle.Filled = Toggles.FOVFilled.Value
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Transparency = 0.5
FOVCircle.Visible = Toggles.ShowFOV.Value

-- Update Circle
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    if FOVCircle then
        FOVCircle.Position = game:GetService("UserInputService"):GetMouseLocation()
        FOVCircle.Radius = Options.FOVSize.Value
        FOVCircle.Filled = Toggles.FOVFilled.Value
        FOVCircle.Visible = Toggles.ShowFOV.Value
    end
end)

-- Handle callbacks for FOV settings
Toggles.ShowFOV:OnChanged(function()
    FOVCircle.Visible = Toggles.ShowFOV.Value
end)

Options.FOVSize:OnChanged(function()
    FOVCircle.Radius = Options.FOVSize.Value
end)

Toggles.FOVFilled:OnChanged(function()
    FOVCircle.Filled = Toggles.FOVFilled.Value
end)

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

-- Clean up FOV circle when script ends
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child.Name == "ScreenGui" then
        FOVCircle:Remove()
    end
end)
