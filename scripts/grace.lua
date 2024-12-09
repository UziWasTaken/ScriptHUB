-- Booting the Library
print("Booting the Library")
print("Loading the Rayfield Library")

-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local Config = {
    Enabled = false,
    DoorRange = 10,
    AutoTouch = false,
    AutoTouchRange = 10,
    AutoKick = false,
    AutoInteract = false,
    AutoSprint = false,
    SlideBoost = {
        Enabled = false,
        Multiplier = 1.5
    },
    ESP = {
        Enabled = false,
        HidboxEnabled = false,
        MaxDistance = 100,
        Color = Color3.fromRGB(255, 0, 0),
        HidboxColor = Color3.fromRGB(0, 255, 0)
    },
    Fullbright = {
        Enabled = false,
        OldAmbient = nil,
        OldBrightness = nil,
        OldClockTime = nil,
        OldFogEnd = nil,
        OldGlobalShadows = nil
    },
    Notifications = false,
    WalkSpeedEnabled = false,
    WalkSpeed = 16 -- Default Roblox walk speed
}

-- Creating a Window in Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Door Aura | v1.0",
    LoadingTitle = "Door Aura Loading...",
    LoadingSubtitle = "by Your Name",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DoorAura",
        FileName = "Config"
    },
    KeySystem = false
})

-- Create Single Main Tab
local MainTab = Window:CreateTab("Main Features", 4483362458)

-- Door Controls Section
MainTab:CreateSection("Door Controls")

local DoorAuraToggle = MainTab:CreateToggle({
    Name = "Enable Door Aura",
    CurrentValue = Config.Enabled,
    Flag = "DoorAuraEnabled",
    Callback = function(Value)
        Config.Enabled = Value
    end,
})

local AutoTouchToggle = MainTab:CreateToggle({
    Name = "Auto Touch",
    CurrentValue = Config.AutoTouch,
    Flag = "AutoTouch",
    Callback = function(Value)
        Config.AutoTouch = Value
    end,
})

-- Add the slider right after Auto Touch toggle
local AutoTouchSlider = MainTab:CreateSlider({
    Name = "Auto Touch Range",
    Range = {5, 50},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = Config.AutoTouchRange,
    Flag = "AutoTouchRange",
    Callback = function(Value)
        Config.AutoTouchRange = Value
    end,
})

local AutoKickToggle = MainTab:CreateToggle({
    Name = "Auto Kick",
    CurrentValue = Config.AutoKick,
    Flag = "AutoKick",
    Callback = function(Value)
        Config.AutoKick = Value
    end,
})

local AutoInteractToggle = MainTab:CreateToggle({
    Name = "Auto Interact",
    CurrentValue = Config.AutoInteract,
    Flag = "AutoInteract",
    Callback = function(Value)
        Config.AutoInteract = Value
    end,
})

-- Movement Section
MainTab:CreateSection("Movement")

local SlideBoostToggle = MainTab:CreateToggle({
    Name = "Slide Boost",
    CurrentValue = Config.SlideBoost.Enabled,
    Flag = "SlideBoost",
    Callback = function(Value)
        Config.SlideBoost.Enabled = Value
    end,
})

local SlideBoostSlider = MainTab:CreateSlider({
    Name = "Slide Boost Multiplier",
    Range = {1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = Config.SlideBoost.Multiplier,
    Flag = "SlideBoostMultiplier",
    Callback = function(Value)
        Config.SlideBoost.Multiplier = Value
    end,
})

local SlideDistanceSlider = MainTab:CreateSlider({
    Name = "Slide Distance",
    Range = {100, 500},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = 100,
    Flag = "SlideDistance",
    Callback = function(Value)
        Config.SlideBoost.Distance = Value
    end,
})

-- Walkspeed Toggle
local WalkSpeedToggle = MainTab:CreateToggle({
    Name = "Enable Walkspeed",
    CurrentValue = Config.WalkSpeedEnabled,
    Flag = "WalkSpeedEnabled",
    Callback = function(Value)
        Config.WalkSpeedEnabled = Value
        if not Value then
            -- Reset to default walkspeed when disabled
            local character = Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16 -- Default walkspeed
                end
            end
        end
    end,
})

-- Walkspeed Slider
local WalkSpeedSlider = MainTab:CreateSlider({
    Name = "Walkspeed",
    Range = {16, 100}, -- Adjust the range as needed
    Increment = 1,
    Suffix = " studs/s",
    CurrentValue = Config.WalkSpeed,
    Flag = "WalkSpeed",
    Callback = function(Value)
        Config.WalkSpeed = Value
        if Config.WalkSpeedEnabled then
            local character = Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = Value
                end
            end
        end
    end,
})

-- Visual Settings Section
MainTab:CreateSection("Visual Settings")

local DoorESPToggle = MainTab:CreateToggle({
    Name = "Door ESP",
    CurrentValue = Config.ESP.Enabled,
    Flag = "DoorESP",
    Callback = function(Value)
        Config.ESP.Enabled = Value
    end,
})

local HidboxESPToggle = MainTab:CreateToggle({
    Name = "Hidbox ESP",
    CurrentValue = Config.ESP.HidboxEnabled,
    Flag = "HidboxESP",
    Callback = function(Value)
        Config.ESP.HidboxEnabled = Value
    end,
})

local ESPDistanceSlider = MainTab:CreateSlider({
    Name = "ESP Distance",
    Range = {10, 500},
    Increment = 10,
    Suffix = " studs",
    CurrentValue = Config.ESP.MaxDistance,
    Flag = "ESPDistance",
    Callback = function(Value)
        Config.ESP.MaxDistance = Value
    end,
})

local FullbrightToggle = MainTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = Config.Fullbright.Enabled,
    Flag = "Fullbright",
    Callback = function(Value)
        Config.Fullbright.Enabled = Value
        
        if Value then
            -- Store original lighting
            Config.Fullbright.OldAmbient = Lighting.Ambient
            Config.Fullbright.OldBrightness = Lighting.Brightness
            Config.Fullbright.OldClockTime = Lighting.ClockTime
            Config.Fullbright.OldFogEnd = Lighting.FogEnd
            Config.Fullbright.OldGlobalShadows = Lighting.GlobalShadows
            
            -- Apply fullbright
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            
            -- Disable effects
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("BlurEffect") or 
                   effect:IsA("ColorCorrectionEffect") or 
                   effect:IsA("BloomEffect") or 
                   effect:IsA("SunRaysEffect") or 
                   effect:IsA("DepthOfFieldEffect") then
                    effect.Enabled = false
                end
            end
        else
            -- Restore lighting
            Lighting.Ambient = Config.Fullbright.OldAmbient
            Lighting.Brightness = Config.Fullbright.OldBrightness
            Lighting.ClockTime = Config.Fullbright.OldClockTime
            Lighting.FogEnd = Config.Fullbright.OldFogEnd
            Lighting.GlobalShadows = Config.Fullbright.OldGlobalShadows
            
            -- Re-enable effects
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("BlurEffect") or 
                   effect:IsA("ColorCorrectionEffect") or 
                   effect:IsA("BloomEffect") or 
                   effect:IsA("SunRaysEffect") or 
                   effect:IsA("DepthOfFieldEffect") then
                    effect.Enabled = true
                end
            end
        end
    end,
})

-- Anti-Eye Toggle
local AntiEyeToggle = MainTab:CreateToggle({
    Name = "Anti Eye",
    CurrentValue = AntiEyeEnabled,
    Flag = "AntiEye",
    Callback = function(Value)
        AntiEyeEnabled = Value
    end,
})

-- Other Settings Section
MainTab:CreateSection("Other Settings")

local NotificationsToggle = MainTab:CreateToggle({
    Name = "Enable Notifications",
    CurrentValue = true,
    Flag = "EnableNotifications",
    Callback = function(Value)
        if Value then
            Rayfield:Notify({
                Title = "Feature Enabled",
                Content = "Notifications are now enabled.",
                Duration = 4,
                Image = 4483362458,
            })
        else
            Rayfield:Notify({
                Title = "Feature Disabled",
                Content = "Notifications are now disabled.",
                Duration = 4,
                Image = 4483362458,
            })
        end
    end,
})

-- Adding Door Controls
local Toggle1 = Window:CreateTab("Door Aura", 4483362458)

-- Create Sections
local Section1 = Toggle1:CreateSection("Door Controls")
local Section2 = Toggle1:CreateSection("Movement")
local Section3 = Toggle1:CreateSection("Visuals")
local Section4 = Toggle1:CreateSection("Notifications")

-- Adding Movement Controls
local Toggle10 = Toggle1:CreateToggle({
    Name = "Slide Boost",
    CurrentValue = Config.SlideBoost.Enabled,
    Flag = "SlideBoostToggle",
    Callback = function(Value)
        Config.SlideBoost.Enabled = Value
    end,
})

local Slider3 = Toggle1:CreateSlider({
    Name = "Slide Boost Multiplier",
    Range = {1, 5},
    Increment = 0.1,
    Suffix = "x",
    CurrentValue = Config.SlideBoost.Multiplier,
    Flag = "SlideBoostMultiplier",
    Callback = function(Value)
        Config.SlideBoost.Multiplier = Value
    end,
})

-- Adding Visual Controls
local Toggle6 = Toggle1:CreateToggle({
    Name = "Door ESP",
    CurrentValue = Config.ESP.Enabled,
    Flag = "DoorESPToggle",
    Callback = function(Value)
        Config.ESP.Enabled = Value
    end,
})

local Toggle7 = Toggle1:CreateToggle({
    Name = "Hidbox ESP",
    CurrentValue = Config.ESP.HidboxEnabled,
    Flag = "HidboxESPToggle",
    Callback = function(Value)
        Config.ESP.HidboxEnabled = Value
    end,
})

local Slider2 = Toggle1:CreateSlider({
    Name = "ESP Distance",
    Range = {10, 500},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = Config.ESP.MaxDistance,
    Flag = "ESPDistanceSlider",
    Callback = function(Value)
        Config.ESP.MaxDistance = Value
    end,
})

local Toggle8 = Toggle1:CreateToggle({
    Name = "Fullbright",
    CurrentValue = Config.Fullbright.Enabled,
    Flag = "FullbrightToggle",
    Callback = function(Value)
        Config.Fullbright.Enabled = Value
        
        if Value then
            -- Store original lighting
            Config.Fullbright.OldAmbient = Lighting.Ambient
            Config.Fullbright.OldBrightness = Lighting.Brightness
            Config.Fullbright.OldClockTime = Lighting.ClockTime
            Config.Fullbright.OldFogEnd = Lighting.FogEnd
            Config.Fullbright.OldGlobalShadows = Lighting.GlobalShadows
            
            -- Apply fullbright
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            
            -- Disable effects
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("BlurEffect") or 
                   effect:IsA("ColorCorrectionEffect") or 
                   effect:IsA("BloomEffect") or 
                   effect:IsA("SunRaysEffect") or 
                   effect:IsA("DepthOfFieldEffect") then
                    effect.Enabled = false
                end
            end
        else
            -- Restore lighting
            Lighting.Ambient = Config.Fullbright.OldAmbient
            Lighting.Brightness = Config.Fullbright.OldBrightness
            Lighting.ClockTime = Config.Fullbright.OldClockTime
            Lighting.FogEnd = Config.Fullbright.OldFogEnd
            Lighting.GlobalShadows = Config.Fullbright.OldGlobalShadows
            
            -- Re-enable effects
            for _, effect in pairs(Lighting:GetChildren()) do
                if effect:IsA("BlurEffect") or 
                   effect:IsA("ColorCorrectionEffect") or 
                   effect:IsA("BloomEffect") or 
                   effect:IsA("SunRaysEffect") or 
                   effect:IsA("DepthOfFieldEffect") then
                    effect.Enabled = true
                end
            end
        end
    end,
})

-- ESP Objects Storage
local espObjects = {}

-- ESP Functions
local function createESP(door, isHidbox)
    local esp = Instance.new("Folder")
    esp.Name = "ESP"
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = isHidbox and Config.ESP.HidboxColor or Config.ESP.Color
    highlight.OutlineColor = isHidbox and Config.ESP.HidboxColor or Config.ESP.Color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = door
    highlight.Parent = esp
    
    local distanceText = Instance.new("BillboardGui")
    distanceText.Name = "DistanceText"
    distanceText.Size = UDim2.new(0, 200, 0, 50)
    distanceText.AlwaysOnTop = true
    distanceText.Parent = esp
    
    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Font = Enum.Font.SourceSansBold
    text.TextSize = 14
    text.TextColor3 = isHidbox and Config.ESP.HidboxColor or Config.ESP.Color
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.Parent = distanceText
    
    return esp, text, distanceText
end

-- Clean up function for ESP
local function cleanupESP()
    for door, esp in pairs(espObjects) do
        if not door:IsDescendantOf(game) then
            esp:Destroy()
            espObjects[door] = nil
        end
    end
end

-- Anti-Eye Configuration
local AntiEyeEnabled = true

-- Main Loops
RunService.Heartbeat:Connect(function()
    -- Door Kicking
    if Config.Enabled then
        local character = Players.LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, room in pairs(workspace.Rooms:GetChildren()) do
            local door = room:FindFirstChild("Door")
            if door then
                local kickBox = door:FindFirstChild("kickBox")
                if kickBox and kickBox:FindFirstChild("TouchInterest") then
                    local distance = (kickBox.Position - hrp.Position).Magnitude
                    if distance <= Config.DoorRange then
                        firetouchinterest(hrp, kickBox, 0)
                        task.wait()
                        firetouchinterest(hrp, kickBox, 1)
                    end
                end
            end
        end
    end

    -- Auto Touch (Separate from Door Kicking)
    if Config.AutoTouch then
        local character = Players.LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, room in pairs(workspace.Rooms:GetChildren()) do
            for _, child in pairs(room:GetChildren()) do
                local base = child:FindFirstChild("base")
                if base and base:FindFirstChild("TouchInterest") then
                    local distance = (base.Position - hrp.Position).Magnitude
                    if distance <= Config.AutoTouchRange then
                        firetouchinterest(hrp, base, 0)
                        task.wait()
                        firetouchinterest(hrp, base, 1)
                    end
                end
                
                if child.Name == "base" and child:FindFirstChild("TouchInterest") then
                    local distance = (child.Position - hrp.Position).Magnitude
                    if distance <= Config.AutoTouchRange then
                        firetouchinterest(hrp, child, 0)
                        task.wait()
                        firetouchinterest(hrp, child, 1)
                    end
                end
            end
        end
    end

    -- Auto Interact
    if Config.AutoInteract then
        local character = Players.LocalPlayer.Character
        if not character then return end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        -- Check vault entrance in Room 21 with proper error handling
        pcall(function()
            local room21 = workspace.Rooms:FindFirstChild("21")
            if room21 then
                local safeRoom = room21:FindFirstChild("SafeRoom")
                if safeRoom then
                    local vaultEntrance = safeRoom:FindFirstChild("VaultEntrance")
                    if vaultEntrance then
                        local hinged = vaultEntrance:FindFirstChild("Hinged")
                        if hinged then
                            local cylinder = hinged:FindFirstChild("Cylinder")
                            if cylinder then
                                local prompt = cylinder:FindFirstChild("ProximityPrompt")
                                if prompt then
                                    local distance = (cylinder.Position - hrp.Position).Magnitude
                                    if distance <= Config.DoorRange then
                                        fireproximityprompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)

        for _, room in pairs(workspace.Rooms:GetChildren()) do
            local door = room:FindFirstChild("Door")
            if door then
                local promptBox = door:FindFirstChild("promptBox")
                if promptBox and promptBox:FindFirstChild("ProximityPrompt") then
                    local distance = (promptBox.Position - hrp.Position).Magnitude
                    if distance <= Config.DoorRange then
                        local virtualInputManager = game:GetService("VirtualInputManager")
                        virtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(0.1)
                        virtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end
                end
            end
        end
    end

    -- Ensure the character's walkspeed is set to the configured value if enabled
    if Config.WalkSpeedEnabled then
        local character = Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.WalkSpeed ~= Config.WalkSpeed then
                humanoid.WalkSpeed = Config.WalkSpeed
            end
        end
    end

    -- Anti-Eye Logic (Remove Nodes)
    if AntiEyeEnabled then
        for _, room in pairs(workspace.Rooms:GetChildren()) do
            local nodes = room:FindFirstChild("Nodes")
            if nodes then
                for _, node in pairs(nodes:GetChildren()) do
                    if node:IsA("Model") or node:IsA("Part") then
                        node:Destroy()
                    end
                end
            end
        end
    end
end)

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    if not (Config.ESP.Enabled or Config.ESP.HidboxEnabled) then return end
    
    local character = Players.LocalPlayer.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    cleanupESP()
    
    for _, room in pairs(workspace.Rooms:GetChildren()) do
        if Config.ESP.Enabled then
            local door = room:FindFirstChild("Door")
            if door and door:FindFirstChild("kickBox") then
                if not espObjects[door] or not espObjects[door]:IsDescendantOf(game) then
                    local esp, text, gui = createESP(door, false)
                    espObjects[door] = esp
                    esp.Parent = door
                    gui.Adornee = door
                end
                
                if espObjects[door] then
                    local esp = espObjects[door]
                    if esp:IsDescendantOf(game) then
                        local distance = (door.kickBox.Position - hrp.Position).Magnitude
                        local text = esp.DistanceText.TextLabel
                        text.Text = string.format("Door [%d studs]\nRoom %s", 
                            math.floor(distance),
                            room.Name)
                        
                        local visible = distance <= Config.ESP.MaxDistance
                        esp.DistanceText.Enabled = visible
                        esp.Highlight.Enabled = visible
                    end
                end
            end
        end
        
        if Config.ESP.HidboxEnabled then
            local hidbox = room:FindFirstChild("Hidbox")
            if hidbox then
                if not espObjects[hidbox] or not espObjects[hidbox]:IsDescendantOf(game) then
                    local esp, text, gui = createESP(hidbox, true)
                    espObjects[hidbox] = esp
                    esp.Parent = hidbox
                    gui.Adornee = hidbox
                end
                
                if espObjects[hidbox] then
                    local esp = espObjects[hidbox]
                    if esp:IsDescendantOf(game) then
                        local distance = (hidbox.Position - hrp.Position).Magnitude
                        local text = esp.DistanceText.TextLabel
                        text.Text = string.format("Hidbox [%d studs]\nRoom %s", 
                            math.floor(distance),
                            room.Name)
                        
                        local visible = distance <= Config.ESP.MaxDistance
                        esp.DistanceText.Enabled = visible
                        esp.Highlight.Enabled = visible
                    end
                end
            end
        end
    end
end)

-- Notifications
Rayfield:Notify({
    Title = "Door Aura Loaded!",
    Content = "Door Aura script loaded successfully.",
    Duration = 4,
    Image = 4483362458,
})
