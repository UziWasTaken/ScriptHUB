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
    Aimbot = Window:AddTab('Aimbot'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Add this near the top of the script, after the Library initialization
getgenv().Flags = {
    IsAnimeFan = false,
    FireDirectly = false
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

MainGroup:AddToggle('IsAnimeFan', {
    Text = 'Toggle Feature',
    Default = false,
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

-- Add after the Main features group but before UI Settings
local AimbotGroup = Tabs.Aimbot:AddLeftGroupbox('Aimbot Settings')

AimbotGroup:AddToggle('AimbotEnabled', {
    Text = 'Enable Aimbot',
    Default = false,
    Tooltip = 'Toggles aimbot functionality',
})

AimbotGroup:AddToggle('AimbotTeamCheck', {
    Text = 'Team Check',
    Default = true,
    Tooltip = 'Prevents aiming at teammates',
})

AimbotGroup:AddToggle('AimbotVisibilityCheck', {
    Text = 'Visibility Check',
    Default = true,
    Tooltip = 'Only target visible players',
})

AimbotGroup:AddSlider('AimbotFOV', {
    Text = 'FOV',
    Default = 100,
    Min = 0,
    Max = 360,
    Rounding = 0,
    Tooltip = 'Field of View for target detection',
})

AimbotGroup:AddSlider('AimbotSmoothness', {
    Text = 'Smoothness',
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Tooltip = 'Higher = smoother aiming',
})

AimbotGroup:AddDropdown('AimbotTargetPart', {
    Values = {'Head', 'HumanoidRootPart', 'Torso'},
    Default = 1,
    Multi = false,
    Text = 'Target Part',
    Tooltip = 'Body part to aim at',
})

-- Aimbot implementation
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local function GetClosestPlayer()
    if not Toggles.AimbotEnabled.Value then return end
    
    local closestPlayer = nil
    local shortestDistance = Options.AimbotFOV.Value

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Team Check
            if Toggles.AimbotTeamCheck.Value and player.Team == LocalPlayer.Team then
                continue
            end

            local character = player.Character
            if not character or not character:FindFirstChild(Options.AimbotTargetPart.Value) then
                continue
            end

            local targetPart = character[Options.AimbotTargetPart.Value]
            local humanoid = character:FindFirstChild("Humanoid")
            
            if humanoid and humanoid.Health <= 0 then
                continue
            end

            -- Visibility Check
            if Toggles.AimbotVisibilityCheck.Value then
                local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
                local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, character})
                if hit then continue end
            end

            local screenPoint = Camera:WorldToScreenPoint(targetPart.Position)
            local vectorDistance = (Vector2.new(screenPoint.X, screenPoint.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude

            if vectorDistance < shortestDistance then
                closestPlayer = player
                shortestDistance = vectorDistance
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if Toggles.AimbotEnabled.Value then
        local target = GetClosestPlayer()
        if target and target.Character then
            local targetPart = target.Character[Options.AimbotTargetPart.Value]
            local targetPos = Camera:WorldToScreenPoint(targetPart.Position)
            local mousePos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            local aimPos = Vector2.new(targetPos.X, targetPos.Y)
            
            mousemoverel(
                (aimPos.X - mousePos.X) / Options.AimbotSmoothness.Value,
                (aimPos.Y - mousePos.Y) / Options.AimbotSmoothness.Value
            )
        end
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
