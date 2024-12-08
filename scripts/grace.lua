local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Grace Script',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Console = Window:AddTab('Console'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Main features group
local MainGroup = Tabs.Main:AddLeftGroupbox('Game Features')

-- Add toggles for each feature
MainGroup:AddToggle('ParticleBoost', {
    Text = 'Enhanced Particles',
    Default = false,
    Tooltip = 'Increases particle rate by 10x',
})

MainGroup:AddToggle('AutoLever', {
    Text = 'Auto Lever Teleport',
    Default = false,
    Tooltip = 'Automatically teleports levers to you',
})

MainGroup:AddToggle('EntityRemoval', {
    Text = 'Remove Entities',
    Default = false,
    Tooltip = 'Removes dangerous entities',
})

MainGroup:AddToggle('RemoveEyeGui', {
    Text = 'Remove Eye GUI',
    Default = false,
    Tooltip = 'Removes eye parasites GUI',
})

MainGroup:AddToggle('RemoveSmileGui', {
    Text = 'Remove Smile GUI',
    Default = false,
    Tooltip = 'Removes smile GUI',
})

MainGroup:AddToggle('RemoveGoatGui', {
    Text = 'Remove Goat GUI',
    Default = false,
    Tooltip = 'Removes goat GUI',
})

-- Add Fullbright toggle
MainGroup:AddToggle('Fullbright', {
    Text = 'Fullbright',
    Default = false,
    Tooltip = 'Removes all darkness from the game',
})

-- Console features group
local ConsoleGroup = Tabs.Console:AddLeftGroupbox('Console Settings')

ConsoleGroup:AddButton('Create Console', function()
    rconsolesettitle("Grace Script Console")
    rconsolecreate()
    rconsoleprint("@@LIGHT_CYAN@@")
    rconsoleprint("Grace Script Console Initialized\n")
end)

ConsoleGroup:AddButton('Clear Console', function()
    rconsoleclear()
    rconsoleprint("@@LIGHT_CYAN@@")
end)

ConsoleGroup:AddButton('Destroy Console', function()
    rconsoledestroy()
end)

ConsoleGroup:AddInput('ConsoleTitle', {
    Default = 'Grace Script Console',
    Numeric = false,
    Finished = false,
    Text = 'Console Title',
    Tooltip = 'Set the title of the console window',
    Placeholder = 'Enter console title...',
    Callback = function(value)
        rconsolesettitle(value)
    end
})

-- Implement feature callbacks
local connections = {}

Toggles.ParticleBoost:OnChanged(function()
    if Toggles.ParticleBoost.Value then
        connections.particle = workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ParticleEmitter") then
                descendant.Rate = descendant.Rate * 10
            end
        end)
    else
        if connections.particle then
            connections.particle:Disconnect()
        end
    end
end)

Toggles.AutoLever:OnChanged(function()
    if Toggles.AutoLever.Value then
        connections.lever = workspace.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "base" and descendant:IsA("BasePart") then
                local player = game.Players.LocalPlayer
                if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    descendant.Position = player.Character.HumanoidRootPart.Position
                    game.StarterGui:SetCore("SendNotification", {
                        Title = "levers moved",
                        Text = "door has been opened",
                        Duration = 3
                    })
                end
            end
        end)
    else
        if connections.lever then
            connections.lever:Disconnect()
        end
    end
end)

Toggles.EntityRemoval:OnChanged(function()
    if Toggles.EntityRemoval.Value then
        connections.entity = workspace.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "eye" or descendant.Name == "elkman" or 
               descendant.Name == "Rush" or descendant.Name == "Worm" or 
               descendant.Name == "eyePrime" then
                descendant:Destroy()
            end
        end)
    else
        if connections.entity then
            connections.entity:Disconnect()
        end
    end
end)

-- Implement Fullbright callback
Toggles.Fullbright:OnChanged(function()
    if Toggles.Fullbright.Value then
        -- Store original lighting properties
        connections.fullbrightProps = {
            Brightness = game:GetService("Lighting").Brightness,
            ClockTime = game:GetService("Lighting").ClockTime,
            FogEnd = game:GetService("Lighting").FogEnd,
            GlobalShadows = game:GetService("Lighting").GlobalShadows,
            Ambient = game:GetService("Lighting").Ambient
        }

        -- Apply Fullbright
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").Ambient = Color3.fromRGB(178, 178, 178)

        -- Remove all lighting effects
        connections.fullbright = game:GetService("Lighting").DescendantAdded:Connect(function(descendant)
            if descendant:IsA("BlurEffect") or 
               descendant:IsA("ColorCorrectionEffect") or 
               descendant:IsA("BloomEffect") or 
               descendant:IsA("SunRaysEffect") then
                descendant.Enabled = false
            end
        end)

        -- Disable existing effects
        for _, effect in pairs(game:GetService("Lighting"):GetDescendants()) do
            if effect:IsA("BlurEffect") or 
               effect:IsA("ColorCorrectionEffect") or 
               effect:IsA("BloomEffect") or 
               effect:IsA("SunRaysEffect") then
                effect.Enabled = false
            end
        end
    else
        -- Restore original lighting properties
        if connections.fullbrightProps then
            for property, value in pairs(connections.fullbrightProps) do
                game:GetService("Lighting")[property] = value
            end
        end

        -- Disconnect the effect remover
        if connections.fullbright then
            connections.fullbright:Disconnect()
        end

        -- Re-enable effects
        for _, effect in pairs(game:GetService("Lighting"):GetDescendants()) do
            if effect:IsA("BlurEffect") or 
               effect:IsA("ColorCorrectionEffect") or 
               effect:IsA("BloomEffect") or 
               effect:IsA("SunRaysEffect") then
                effect.Enabled = true
            end
        end
    end
end)

-- GUI Removal functions
local function setupGuiRemoval(toggleName, guiName)
    Toggles[toggleName]:OnChanged(function()
        if Toggles[toggleName].Value then
            connections[toggleName] = game:GetService("RunService").Heartbeat:Connect(function()
                local gui = game.Players.LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild(guiName)
                if gui then
                    gui:Destroy()
                end
            end)
        else
            if connections[toggleName] then
                connections[toggleName]:Disconnect()
            end
        end
    end)
end

setupGuiRemoval('RemoveEyeGui', 'eyegui')
setupGuiRemoval('RemoveSmileGui', 'smilegui')
setupGuiRemoval('RemoveGoatGui', 'GOATPORT')

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

ThemeManager:SetFolder('GraceScript')
SaveManager:SetFolder('GraceScript/GameConfigs')

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig() 
