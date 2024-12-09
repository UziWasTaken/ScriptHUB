--[[
    Universal Script
    Version: 1.0
    Author: UziWasTaken
    Description: A universal script with common game features and utilities
]]

-- Constants and Configuration
local CONFIG = {
    UI = {
        TITLE = 'Universal Script',
        REPO = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/',
    },
    PLAYER = {
        DEFAULT_WALKSPEED = 16,
        DEFAULT_JUMPPOWER = 50,
        MIN_WALKSPEED = 16,
        MAX_WALKSPEED = 500,
        MIN_JUMPPOWER = 50,
        MAX_JUMPPOWER = 500
    },
    NOCLIP = {
        PLATFORM_SIZE = Vector3.new(5, 1, 5),
        PLATFORM_OFFSET = 3.5
    }
}

-- Services
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Initialize UI Library
local Library = loadstring(game:HttpGet(CONFIG.UI.REPO .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(CONFIG.UI.REPO .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(CONFIG.UI.REPO .. 'addons/SaveManager.lua'))()

-- State Management
local State = {
    Connections = {},
    AirWalkPart = nil
}

-- Create Window and Tabs
local Window = Library:CreateWindow({
    Title = CONFIG.UI.TITLE,
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
    Console = Window:AddTab('Console'),
}

-- Player Movement Functions
local function updateWalkSpeed(speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speed
    end
end

local function updateJumpPower(power)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = power
    end
end

local function setupNoClip(enabled)
    if State.Connections.NoClip then
        State.Connections.NoClip:Disconnect()
        State.Connections.NoClip = nil
    end

    -- Create air walk platform if needed
    if not State.AirWalkPart then
        State.AirWalkPart = Instance.new("Part")
        State.AirWalkPart.Size = CONFIG.NOCLIP.PLATFORM_SIZE
        State.AirWalkPart.Anchored = true
        State.AirWalkPart.Transparency = 1
        State.AirWalkPart.Name = "AirWalkPart"
        State.AirWalkPart.CanCollide = true
    end

    if enabled then
        State.Connections.NoClip = RunService.Stepped:Connect(function()
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
                    State.AirWalkPart.CFrame = CFrame.new(
                        root.Position.X, 
                        root.Position.Y - CONFIG.NOCLIP.PLATFORM_OFFSET, 
                        root.Position.Z
                    )
                    if not State.AirWalkPart.Parent then
                        State.AirWalkPart.Parent = workspace
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
        if State.AirWalkPart then
            State.AirWalkPart.Parent = nil
        end
    end
end

-- Console Functions
local function createConsole()
    rconsolesettitle("Universal Script Console")
    rconsolecreate()
    rconsoleprint("@@RED@@")
    rconsoleprint("Error logging console created.\n")
end

local function clearConsole()
    rconsoleclear()
    rconsoleprint("@@RED@@")
end

local function destroyConsole()
    rconsoledestroy()
end

-- UI Setup
local function setupUI()
    -- Main features group
    local MainGroup = Tabs.Main:AddLeftGroupbox('Player Features')

    MainGroup:AddToggle('WalkSpeedEnabled', {
        Text = 'WalkSpeed Enabled',
        Default = false,
        Tooltip = 'Enables WalkSpeed modification',
        Callback = function(Value)
            if Value then
                updateWalkSpeed(Options.WalkSpeedValue.Value)
            else
                updateWalkSpeed(CONFIG.PLAYER.DEFAULT_WALKSPEED)
            end
        end
    })

    MainGroup:AddSlider('WalkSpeedValue', {
        Text = 'WalkSpeed',
        Default = CONFIG.PLAYER.DEFAULT_WALKSPEED,
        Min = CONFIG.PLAYER.MIN_WALKSPEED,
        Max = CONFIG.PLAYER.MAX_WALKSPEED,
        Rounding = 0,
        Callback = function(Value)
            if Toggles.WalkSpeedEnabled.Value then
                updateWalkSpeed(Value)
            end
        end
    })

    MainGroup:AddToggle('JumpPowerEnabled', {
        Text = 'JumpPower Enabled',
        Default = false,
        Tooltip = 'Enables JumpPower modification',
        Callback = function(Value)
            if Value then
                updateJumpPower(Options.JumpPowerValue.Value)
            else
                updateJumpPower(CONFIG.PLAYER.DEFAULT_JUMPPOWER)
            end
        end
    })

    MainGroup:AddSlider('JumpPowerValue', {
        Text = 'JumpPower',
        Default = CONFIG.PLAYER.DEFAULT_JUMPPOWER,
        Min = CONFIG.PLAYER.MIN_JUMPPOWER,
        Max = CONFIG.PLAYER.MAX_JUMPPOWER,
        Rounding = 0,
        Callback = function(Value)
            if Toggles.JumpPowerEnabled.Value then
                updateJumpPower(Value)
            end
        end
    })

    MainGroup:AddToggle('NoClipEnabled', {
        Text = 'NoClip',
        Default = false,
        Tooltip = 'Enables NoClip with Air Walk',
        Callback = function(Value)
            setupNoClip(Value)
        end
    })

    -- Console features group
    local ConsoleGroup = Tabs.Console:AddLeftGroupbox('Console Settings')

    ConsoleGroup:AddButton('Create Console', createConsole)
    ConsoleGroup:AddButton('Clear Console', clearConsole)
    ConsoleGroup:AddButton('Destroy Console', destroyConsole)

    ConsoleGroup:AddInput('ConsoleTitle', {
        Default = CONFIG.UI.TITLE .. ' Console',
        Numeric = false,
        Finished = false,
        Text = 'Console Title',
        Tooltip = 'Set the title of the console window',
        Placeholder = 'Enter console title...',
        Callback = function(Value)
            rconsolesettitle(Value)
        end
    })

    -- Misc features group
    local MiscGroup = Tabs.Misc:AddLeftGroupbox('Utility')

    MiscGroup:AddButton('Rejoin Game', function()
        local source = game:HttpGet('https://raw.githubusercontent.com/UziWasTaken/ScriptHUB/main/loader.lua')
        queue_on_teleport(source)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)

    -- UI Settings
    local SettingsGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

    SettingsGroup:AddButton('Unload', function()
        Library:Unload()
    end)

    SettingsGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
        Default = 'End',
        NoUI = true,
        Text = 'Menu keybind'
    })

    Library.ToggleKeybind = Options.MenuKeybind

    -- Theme Manager Setup
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
    ThemeManager:SetFolder('UniversalScript')
    SaveManager:SetFolder('UniversalScript/configs')
    SaveManager:BuildConfigSection(Tabs['UI Settings'])
    ThemeManager:ApplyToTab(Tabs['UI Settings'])
end

-- Initialize
Library:SetWatermarkVisibility(true)
Library:SetWatermark(CONFIG.UI.TITLE .. ' - v1.0')
setupUI()
SaveManager:LoadAutoloadConfig()
