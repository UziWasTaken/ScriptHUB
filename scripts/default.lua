local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local RunService = game:GetService("RunService")
local LocalPlayer = game.Players.LocalPlayer
local Connections = {}

local Window = Library:CreateWindow({
    Title = 'Universal Script',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
    Console = Window:AddTab('Console'),
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

MainGroup:AddToggle('NoClipEnabled', {
    Text = 'NoClip',
    Default = false,
    Tooltip = 'Enables NoClip with Air Walk',
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

Toggles.NoClipEnabled:OnChanged(function(bool)
    if Connections.NoClip then
        Connections.NoClip:Disconnect()
        Connections.NoClip = nil
    end

    -- Create air walk platform only once and store it
    if not Connections.AirWalkPart then
        Connections.AirWalkPart = Instance.new("Part")
        Connections.AirWalkPart.Size = Vector3.new(5, 1, 5)
        Connections.AirWalkPart.Anchored = true
        Connections.AirWalkPart.Transparency = 1
        Connections.AirWalkPart.Name = "AirWalkPart"
        Connections.AirWalkPart.CanCollide = true
    end

    if bool then
        Connections.NoClip = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                -- NoClip
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end

                -- Air Walk
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    Connections.AirWalkPart.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.5, root.Position.Z)
                    if not Connections.AirWalkPart.Parent then
                        Connections.AirWalkPart.Parent = workspace
                    end
                end
            end
        end)
    else
        -- Restore collision
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end

        -- Remove air walk platform
        if Connections.AirWalkPart then
            Connections.AirWalkPart.Parent = nil
        end
    end
end)

-- Console features group
local ConsoleGroup = Tabs.Console:AddLeftGroupbox('Console Settings')

ConsoleGroup:AddButton('Create Console', function()
    rconsolesettitle("Universal Script Console")
    rconsolecreate()
    rconsoleprint("@@RED@@")
    rconsoleprint("Error logging console created.\n")
end)

ConsoleGroup:AddButton('Clear Console', function()
    rconsoleclear()
    rconsoleprint("@@RED@@")
end)

ConsoleGroup:AddButton('Destroy Console', function()
    rconsoledestroy()
end)

ConsoleGroup:AddInput('ConsoleTitle', {
    Default = 'Universal Script Console',
    Numeric = false,
    Finished = false,
    Text = 'Console Title',
    Tooltip = 'Set the title of the console window',
    Placeholder = 'Enter console title...',
    Callback = function(value)
        rconsolesettitle(value)
    end
})

-- Add error logging function
local function LogError(message)
    rconsoleprint("@@RED@@")
    rconsoleprint("[ERROR] " .. tostring(message) .. "\n")
end

-- Example usage (you can add this where needed):
-- LogError("Something went wrong!")

-- Add Misc features group (add this before UI Settings section)
local MiscGroup = Tabs.Misc:AddLeftGroupbox('Utility')

MiscGroup:AddButton('Rejoin Game', function()
    local ts = game:GetService("TeleportService")
    local p = game:GetService("Players").LocalPlayer
    ts:Teleport(game.PlaceId, p)
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
