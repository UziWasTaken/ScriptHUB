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
    Visuals = Window:AddTab('Visuals'),
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
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

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

-- Add this section before UI Settings
local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP Settings')

ESPGroup:AddToggle('ESPEnabled', {
    Text = 'Enable ESP',
    Default = false,
    Tooltip = 'Toggles ESP features',
})

ESPGroup:AddToggle('BoxESP', {
    Text = 'Boxes',
    Default = true,
    Tooltip = 'Shows boxes around players',
})

ESPGroup:AddToggle('TracerESP', {
    Text = 'Tracers',
    Default = false,
    Tooltip = 'Shows lines to players',
})

ESPGroup:AddToggle('NameESP', {
    Text = 'Names',
    Default = true,
    Tooltip = 'Shows player names',
})

ESPGroup:AddToggle('DistanceESP', {
    Text = 'Distance',
    Default = true,
    Tooltip = 'Shows distance to players',
})

ESPGroup:AddToggle('TeamCheck', {
    Text = 'Team Check',
    Default = true,
    Tooltip = 'Only show ESP for enemies',
})

ESPGroup:AddSlider('ESPMaxDistance', {
    Text = 'Max Distance',
    Default = 1000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Suffix = ' studs',
})

-- ESP Implementation
if not Drawing then
    warn("Your executor does not support the Drawing library!")
    return
end

local ESPObjects = {}

local function CreateESPObject()
    local DrawingObject = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Tracer = Drawing.new("Line")
    }
    
    -- Box settings
    DrawingObject.Box.Thickness = 1
    DrawingObject.Box.Filled = false
    DrawingObject.Box.Color = Color3.fromRGB(255, 255, 255)
    DrawingObject.Box.Transparency = 1
    
    -- Name settings
    DrawingObject.Name.Size = 14
    DrawingObject.Name.Center = true
    DrawingObject.Name.Outline = true
    DrawingObject.Name.Color = Color3.fromRGB(255, 255, 255)
    
    -- Distance settings
    DrawingObject.Distance.Size = 12
    DrawingObject.Distance.Center = true
    DrawingObject.Distance.Outline = true
    DrawingObject.Distance.Color = Color3.fromRGB(255, 255, 255)
    
    -- Tracer settings
    DrawingObject.Tracer.Thickness = 1
    DrawingObject.Tracer.Color = Color3.fromRGB(255, 255, 255)
    
    return DrawingObject
end

local function RemoveESP(object)
    if object then
        for _, drawing in pairs(object) do
            if drawing then
                drawing:Remove()
            end
        end
    end
end

local function UpdateESP()
    for player, esp in pairs(ESPObjects) do
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            RemoveESP(esp)
            ESPObjects[player] = nil
            continue
        end
        
        local humanoidRootPart = player.Character.HumanoidRootPart
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local head = player.Character:FindFirstChild("Head")
        
        if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then
            continue
        end
        
        local vector, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)
        local distance = (Camera.CFrame.Position - humanoidRootPart.Position).Magnitude
        
        if not onScreen or distance > Options.ESPMaxDistance.Value then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Tracer.Visible = false
            continue
        end
        
        if Toggles.TeamCheck.Value and player.Team == LocalPlayer.Team then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Tracer.Visible = false
            continue
        end
        
        if not Toggles.ESPEnabled.Value then
            esp.Box.Visible = false
            esp.Name.Visible = false
            esp.Distance.Visible = false
            esp.Tracer.Visible = false
            continue
        end
        
        -- Update Box ESP
        if Toggles.BoxESP.Value then
            local size = (Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(2, 3, 0)).X - Camera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(-2, -3, 0)).X) / 2
            esp.Box.Size = Vector2.new(size, size * 2)
            esp.Box.Position = Vector2.new(vector.X - size / 2, vector.Y - size)
            esp.Box.Visible = true
        else
            esp.Box.Visible = false
        end
        
        -- Update Name ESP
        if Toggles.NameESP.Value then
            esp.Name.Text = player.Name
            esp.Name.Position = Vector2.new(vector.X, vector.Y - esp.Box.Size.Y - 15)
            esp.Name.Visible = true
        else
            esp.Name.Visible = false
        end
        
        -- Update Distance ESP
        if Toggles.DistanceESP.Value then
            esp.Distance.Text = math.floor(distance) .. " studs"
            esp.Distance.Position = Vector2.new(vector.X, vector.Y + esp.Box.Size.Y)
            esp.Distance.Visible = true
        else
            esp.Distance.Visible = false
        end
        
        -- Update Tracer ESP
        if Toggles.TracerESP.Value then
            esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            esp.Tracer.To = Vector2.new(vector.X, vector.Y)
            esp.Tracer.Visible = true
        else
            esp.Tracer.Visible = false
        end
    end
end

-- Player handling
local function PlayerAdded(player)
    if player ~= LocalPlayer then
        ESPObjects[player] = CreateESPObject()
    end
end

local function PlayerRemoving(player)
    if ESPObjects[player] then
        RemoveESP(ESPObjects[player])
        ESPObjects[player] = nil
    end
end

-- Initialize ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        PlayerAdded(player)
    end
end

-- Connect events
Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)
RunService.RenderStepped:Connect(UpdateESP)

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
