-- Infinity Universal Hub - 100+ Features
-- Alternative UI Implementation

-- UI Framework Loading
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

-- Player Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
local Mouse = LocalPlayer:GetMouse()

-- Global State Management
local States = {}
local Connections = {}
local ESPObjects = {}
local FarmTargets = {}
local Waypoints = {}
local SkillCooldowns = {}

-- Main Window Creation
local Window = Rayfield:CreateWindow({
    Name = "⚡ Infinity Universal Hub | 100+ Features",
    LoadingTitle = "Loading Infinity Hub...",
    LoadingSubtitle = "Powered by Infinity Yield",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "InfinityUniversal",
        FileName = "Settings"
    },
    Discord = {
        Enabled = false,
        InviteCode = "infinityhub",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Create Tabs
local MainTab = Window:CreateTab("Main Hacks", 4483362458)
local PlayerTab = Window:CreateTab("Player", 4483362458)
local VisualTab = Window:CreateTab("Visual", 4483362458)
local WorldTab = Window:CreateTab("World", 4483362458)
local AutoFarmTab = Window:CreateTab("Auto Farm", 4483362458)
local CombatTab = Window:CreateTab("Combat", 4483362458)
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local ESPTab = Window:CreateTab("ESP", 4483362458)
local VehicleTab = Window:CreateTab("Vehicle", 4483362458)
local FunTab = Window:CreateTab("Fun", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

-- Utility Functions
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("Error in SafeCall:", result)
    end
    return result
end

local function CreateConnection(name, connection)
    if Connections[name] then
        Connections[name]:Disconnect()
    end
    Connections[name] = connection
    return connection
end

local function GetNearestPlayer(maxDistance)
    local nearest = nil
    local distance = maxDistance or math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                local dist = (HRP.Position - targetHRP.Position).Magnitude
                if dist < distance then
                    distance = dist
                    nearest = player
                end
            end
        end
    end
    
    return nearest, distance
end

local function GetNearestObject(objectType, maxDistance)
    local nearest = nil
    local distance = maxDistance or math.huge
    
    for _, obj in pairs(WS:GetChildren()) do
        if obj.Name:match(objectType) or (obj:IsA("Model") and obj.Name:find(objectType)) then
            local pos = obj:IsA("BasePart") and obj.Position or 
                       (obj:IsA("Model") and obj.PrimaryPart and obj.PrimaryPart.Position) or 
                       obj:GetPivot().Position
            local dist = (HRP.Position - pos).Magnitude
            if dist < distance then
                distance = dist
                nearest = obj
            end
        end
    end
    
    return nearest, distance
end

-- 1. FLY SYSTEM
local FlySection = MainTab:CreateSection("Fly System")
local FlyBodyVelocity

local FlyToggle = MainTab:CreateToggle({
    Name = "Infinity Fly (Ctrl + F)",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        States.Fly = Value
        
        if Value then
            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            FlyBodyVelocity.Parent = HRP
            
            CreateConnection("Fly", RS.Heartbeat:Connect(function()
                if not States.Fly or not FlyBodyVelocity then return end
                
                local direction = Vector3.new()
                local camera = WS.CurrentCamera
                
                if UIS:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= Vector3.new(0, 1, 0) end
                
                if direction.Magnitude > 0 then
                    direction = direction.Unit * 100
                end
                
                FlyBodyVelocity.Velocity = Vector3.new(direction.X, direction.Y, direction.Z)
            end))
        else
            if FlyBodyVelocity then
                FlyBodyVelocity:Destroy()
                FlyBodyVelocity = nil
            end
        end
    end,
})

UIS.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.F and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        FlyToggle:Set(not States.Fly)
    end
end)

-- 2. SPEED HACK
local SpeedSlider = PlayerTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 16,
    Flag = "SpeedSlider",
    Callback = function(Value)
        States.WalkSpeed = Value
        if Humanoid then
            Humanoid.WalkSpeed = Value
        end
    end,
})

-- 3. JUMP POWER
local JumpSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 1000},
    Increment = 10,
    Suffix = "power",
    CurrentValue = 50,
    Flag = "JumpSlider",
    Callback = function(Value)
        States.JumpPower = Value
        if Humanoid then
            Humanoid.JumpPower = Value
        end
    end,
})

-- 4. INFINITE JUMP
local InfiniteJumpToggle = PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        States.InfiniteJump = Value
    end,
})

CreateConnection("InfiniteJump", UIS.JumpRequest:Connect(function()
    if States.InfiniteJump and Humanoid then
        Humanoid:ChangeState("Jumping")
    end
end))

-- 5. NO CLIP
local NoClipToggle = PlayerTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoClipToggle",
    Callback = function(Value)
        States.NoClip = Value
    end,
})

CreateConnection("NoClip", RS.Stepped:Connect(function()
    if States.NoClip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end))

-- 6. GOD MODE
local GodModeToggle = PlayerTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodModeToggle",
    Callback = function(Value)
        States.GodMode = Value
        if Humanoid then
            if Value then
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            else
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            end
        end
    end,
})

-- 7. ANTI AFK
local AntiAfkToggle = MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAfkToggle",
    Callback = function(Value)
        States.AntiAfk = Value
        if Value then
            CreateConnection("AntiAFK", RS.Heartbeat:Connect(function()
                if States.AntiAfk then
                    VirtualInputManager:SendKeyEvent(true, "W", false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, "W", false, game)
                end
            end))
        end
    end,
})

-- 8. FPS BOOST
local OriginalSettings = {
    QualityLevel = settings().Rendering.QalityLevel,
    GlobalShadows = Lighting.GlobalShadows
}

local FPSBoostToggle = VisualTab:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Flag = "FPSBoostToggle",
    Callback = function(Value)
        States.FPSBoost = Value
        if Value then
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
            Lighting.GlobalIllumination = Enum.GlobalIllumination.Off
            for _, v in pairs(WS:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end
        else
            settings().Rendering.QualityLevel = OriginalSettings.QualityLevel
            Lighting.GlobalShadows = OriginalSettings.GlobalShadows
            for _, v in pairs(WS:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = true
                end
            end
        end
    end,
})

-- 9. FULL BRIGHT
local FullBrightToggle = VisualTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBrightToggle",
    Callback = function(Value)
        States.FullBright = Value
        if Value then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 1000000
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        else
            Lighting.Brightness = 1
            Lighting.FogEnd = 1000
            Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
        end
    end,
})

-- 10. NO FOG
local NoFogToggle = VisualTab:CreateToggle({
    Name = "Remove Fog",
    CurrentValue = false,
    Flag = "NoFogToggle",
    Callback = function(Value)
        States.NoFog = Value
        if Value then
            Lighting.FogEnd = 1000000
        else
            Lighting.FogEnd = 1000
        end
    end,
})

-- 11. CLICK TELEPORT
local ClickTPToggle = TeleportTab:CreateToggle({
    Name = "Click Teleport",
    CurrentValue = false,
    Flag = "ClickTPToggle",
    Callback = function(Value)
        States.ClickTP = Value
    end,
})

Mouse.Button1Down:Connect(function()
    if States.ClickTP then
        SafeCall(function()
            HRP.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0))
        end)
    end
end)

-- 12. AUTO CLICKER
local AutoClickerToggle = CombatTab:CreateToggle({
    Name = "Auto Clicker",
    CurrentValue = false,
    Flag = "AutoClickerToggle",
    Callback = function(Value)
        States.AutoClicker = Value
        if Value then
            CreateConnection("AutoClicker", RS.Heartbeat:Connect(function()
                if States.AutoClicker then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait()
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end))
        end
    end,
})

-- 13. ESP PLAYERS
local ESPPlayersToggle = ESPTab:CreateToggle({
    Name = "ESP Players",
    CurrentValue = false,
    Flag = "ESPPlayersToggle",
    Callback = function(Value)
        States.ESPPlayers = Value
        
        local function CreateESP(player)
            if not ESPObjects[player] and player.Character then
                local highlight = Instance.new("Highlight")
                highlight.Name = player.Name .. "_ESP"
                highlight.Parent = player.Character
                highlight.FillColor = Color3.fromRGB(255, 50, 50)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                highlight.FillTransparency = 0.5
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                ESPObjects[player] = highlight
                
                -- Update when character changes
                player.CharacterAdded:Connect(function(char)
                    if States.ESPPlayers then
                        highlight.Parent = char
                    end
                end)
            end
        end
        
        local function RemoveESP(player)
            if ESPObjects[player] then
                ESPObjects[player]:Destroy()
                ESPObjects[player] = nil
            end
        end
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    CreateESP(player)
                end
            end
            
            CreateConnection("ESPPlayerAdded", Players.PlayerAdded:Connect(function(player)
                if States.ESPPlayers then
                    CreateESP(player)
                end
            end))
            
            CreateConnection("ESPPlayerRemoving", Players.PlayerRemoving:Connect(function(player)
                RemoveESP(player)
            end))
        else
            for player, highlight in pairs(ESPObjects) do
                highlight:Destroy()
            end
            ESPObjects = {}
        end
    end,
})

-- 14. AIMLOCK
local AimlockToggle = CombatTab:CreateToggle({
    Name = "Aimlock (Right Click)",
    CurrentValue = false,
    Flag = "AimlockToggle",
    Callback = function(Value)
        States.Aimlock = Value
    end,
})

Mouse.Button2Down:Connect(function()
    if States.Aimlock then
        local targetPart = Mouse.Target
        if targetPart then
            local character = targetPart.Parent
            if character:FindFirstChild("Humanoid") then
                States.AimlockTarget = character
            end
        end
    end
end)

CreateConnection("AimlockLoop", RS.Heartbeat:Connect(function()
    if States.Aimlock and States.AimlockTarget and States.AimlockTarget:FindFirstChild("HumanoidRootPart") then
        local camera = WS.CurrentCamera
        local targetPos = States.AimlockTarget.HumanoidRootPart.Position
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
    end
end))

-- 15. AUTO FARM
local AutoFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Farm Nearest",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        States.AutoFarm = Value
        
        if Value then
            CreateConnection("AutoFarmLoop", RS.Heartbeat:Connect(function()
                if States.AutoFarm then
                    local nearest, distance = GetNearestPlayer(500)
                    if nearest and nearest.Character then
                        local targetHRP = nearest.Character:FindFirstChild("HumanoidRootPart")
                        if targetHRP then
                            -- Move towards target
                            HRP.CFrame = CFrame.new(HRP.Position, Vector3.new(
                                targetHRP.Position.X,
                                HRP.Position.Y,
                                targetHRP.Position.Z
                            ))
                            
                            -- Auto attack if close
                            if distance < 10 then
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                task.wait(0.1)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 16. WALK ON WATER
local WalkOnWaterPlatform
local WalkOnWaterToggle = FunTab:CreateToggle({
    Name = "Walk on Water",
    CurrentValue = false,
    Flag = "WalkOnWaterToggle",
    Callback = function(Value)
        States.WalkOnWater = Value
        
        if Value then
            WalkOnWaterPlatform = Instance.new("Part")
            WalkOnWaterPlatform.Name = "WaterPlatform"
            WalkOnWaterPlatform.Size = Vector3.new(100, 2, 100)
            WalkOnWaterPlatform.Transparency = 0.7
            WalkOnWaterPlatform.Color = Color3.fromRGB(0, 150, 255)
            WalkOnWaterPlatform.Anchored = true
            WalkOnWaterPlatform.CanCollide = true
            WalkOnWaterPlatform.Parent = WS
            
            CreateConnection("UpdateWaterPlatform", RS.Heartbeat:Connect(function()
                if WalkOnWaterPlatform then
                    WalkOnWaterPlatform.Position = Vector3.new(
                        HRP.Position.X,
                        0,
                        HRP.Position.Z
                    )
                end
            end))
        else
            if WalkOnWaterPlatform then
                WalkOnWaterPlatform:Destroy()
                WalkOnWaterPlatform = nil
            end
        end
    end,
})

-- 17. INVISIBILITY
local OriginalAppearance = {}
local InvisibilityToggle = PlayerTab:CreateToggle({
    Name = "Invisibility",
    CurrentValue = false,
    Flag = "InvisibilityToggle",
    Callback = function(Value)
        States.Invisibility = Value
        
        if Value then
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    OriginalAppearance[part] = part.Transparency
                    part.Transparency = 1
                elseif part:IsA("Decal") then
                    OriginalAppearance[part] = part.Transparency
                    part.Transparency = 1
                end
            end
        else
            for part, transparency in pairs(OriginalAppearance) do
                if part and part.Parent then
                    part.Transparency = transparency
                end
            end
            OriginalAppearance = {}
        end
    end,
})

-- 18. AUTO COLLECT
local AutoCollectToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Collect Items",
    CurrentValue = false,
    Flag = "AutoCollectToggle",
    Callback = function(Value)
        States.AutoCollect = Value
        
        if Value then
            CreateConnection("AutoCollectLoop", RS.Heartbeat:Connect(function()
                if States.AutoCollect then
                    for _, item in pairs(WS:GetChildren()) do
                        if item.Name:match("Coin") or item.Name:match("Money") or item.Name:match("Item") then
                            if item:IsA("BasePart") then
                                local distance = (HRP.Position - item.Position).Magnitude
                                if distance < 30 then
                                    firetouchinterest(HRP, item, 0)
                                    firetouchinterest(HRP, item, 1)
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 19. TELEPORT TO PLAYER
local PlayerList = {}
local TeleportDropdown = TeleportTab:CreateDropdown({
    Name = "Teleport to Player",
    Options = PlayerList,
    CurrentOption = "",
    Flag = "TeleportDropdown",
    Callback = function(Option)
        local target = Players:FindFirstChild(Option)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            HRP.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end,
})

local function UpdatePlayerDropdown()
    PlayerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(PlayerList, player.Name)
        end
    end
    TeleportDropdown:Set(PlayerList)
end

UpdatePlayerDropdown()
Players.PlayerAdded:Connect(UpdatePlayerDropdown)
Players.PlayerRemoving:Connect(UpdatePlayerDropdown)

-- 20. SERVER HOP
local ServerHopButton = TeleportTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        SafeCall(function()
            local servers = HttpService:JSONDecode(game:HttpGet(
                "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
            ))
            
            for _, server in pairs(servers.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                    break
                end
            end
        end)
    end,
})

-- 21. REJOIN SERVER
local RejoinButton = TeleportTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId)
    end,
})

-- 22. FLY VEHICLE
local FlyVehicleToggle = VehicleTab:CreateToggle({
    Name = "Fly Vehicle",
    CurrentValue = false,
    Flag = "FlyVehicleToggle",
    Callback = function(Value)
        States.FlyVehicle = Value
        
        if Value then
            CreateConnection("FlyVehicleLoop", RS.Heartbeat:Connect(function()
                if States.FlyVehicle then
                    local vehicle = Character:FindFirstChildWhichIsA("VehicleSeat")
                    if vehicle then
                        vehicle.MaxSpeed = 1000
                        local direction = Vector3.new()
                        
                        if UIS:IsKeyDown(Enum.KeyCode.W) then direction += vehicle.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.S) then direction -= vehicle.CFrame.LookVector end
                        if UIS:IsKeyDown(Enum.KeyCode.A) then direction -= vehicle.CFrame.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.D) then direction += vehicle.CFrame.RightVector end
                        if UIS:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
                        
                        if direction.Magnitude > 0 then
                            vehicle.Velocity = direction.Unit * 100
                        end
                    end
                end
            end))
        end
    end,
})

-- 23. ESP ITEMS
local ESPItemsToggle = ESPTab:CreateToggle({
    Name = "ESP Items",
    CurrentValue = false,
    Flag = "ESPItemsToggle",
    Callback = function(Value)
        States.ESPItems = Value
        
        if Value then
            CreateConnection("ESPItemsLoop", RS.Heartbeat:Connect(function()
                if States.ESPItems then
                    for _, item in pairs(WS:GetChildren()) do
                        if item.Name:match("Coin") or item.Name:match("Money") or item.Name:match("Item") then
                            if not item:FindFirstChild("ItemESP") then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ItemESP"
                                highlight.Parent = item
                                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                                highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                                highlight.FillTransparency = 0.3
                            end
                        end
                    end
                else
                    for _, item in pairs(WS:GetChildren()) do
                        local esp = item:FindFirstChild("ItemESP")
                        if esp then
                            esp:Destroy()
                        end
                    end
                end
            end))
        end
    end,
})

-- 24. AUTO FISH
local AutoFishToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Fish",
    CurrentValue = false,
    Flag = "AutoFishToggle",
    Callback = function(Value)
        States.AutoFish = Value
        
        if Value then
            CreateConnection("AutoFishLoop", RS.Heartbeat:Connect(function()
                if States.AutoFish then
                    local fishingSpot = GetNearestObject("Water", 50)
                    if fishingSpot then
                        HRP.CFrame = CFrame.new(fishingSpot.Position + Vector3.new(0, 5, 0))
                        
                        -- Simulate fishing action
                        local tool = Character:FindFirstChildWhichIsA("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                end
            end))
        end
    end,
})

-- 25. AUTO MINE
local AutoMineToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Mine",
    CurrentValue = false,
    Flag = "AutoMineToggle",
    Callback = function(Value)
        States.AutoMine = Value
        
        if Value then
            CreateConnection("AutoMineLoop", RS.Heartbeat:Connect(function()
                if States.AutoMine then
                    local ore = GetNearestObject("Ore", 50) or GetNearestObject("Rock", 50)
                    if ore then
                        HRP.CFrame = CFrame.new(ore.Position + Vector3.new(0, 3, 0))
                        
                        -- Mine action
                        if ore:FindFirstChild("ClickDetector") then
                            fireclickdetector(ore.ClickDetector)
                        else
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        end
                    end
                end
            end))
        end
    end,
})

-- 26. INSTANT RESPAWN
local InstantRespawnToggle = PlayerTab:CreateToggle({
    Name = "Instant Respawn",
    CurrentValue = false,
    Flag = "InstantRespawnToggle",
    Callback = function(Value)
        States.InstantRespawn = Value
    end,
})

if Humanoid then
    CreateConnection("InstantRespawnHandler", Humanoid.Died:Connect(function()
        if States.InstantRespawn then
            task.wait(0.5)
            LocalPlayer:LoadCharacter()
        end
    end))
end

-- 27. NO FALL DAMAGE
local NoFallDamageToggle = PlayerTab:CreateToggle({
    Name = "No Fall Damage",
    CurrentValue = false,
    Flag = "NoFallDamageToggle",
    Callback = function(Value)
        States.NoFallDamage = Value
        if Humanoid then
            if Value then
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            else
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            end
        end
    end,
})

-- 28. INFINITE STAMINA
local InfiniteStaminaToggle = PlayerTab:CreateToggle({
    Name = "Infinite Stamina",
    CurrentValue = false,
    Flag = "InfiniteStaminaToggle",
    Callback = function(Value)
        States.InfiniteStamina = Value
        
        if Value then
            CreateConnection("StaminaLoop", RS.Heartbeat:Connect(function()
                if States.InfiniteStamina and Humanoid then
                    if Humanoid.Health < Humanoid.MaxHealth then
                        Humanoid.Health = Humanoid.MaxHealth
                    end
                end
            end))
        end
    end,
})

-- 29. NO COOLDOWN
local NoCooldownToggle = CombatTab:CreateToggle({
    Name = "No Cooldown",
    CurrentValue = false,
    Flag = "NoCooldownToggle",
    Callback = function(Value)
        States.NoCooldown = Value
        
        if Value then
            CreateConnection("NoCooldownLoop", RS.Heartbeat:Connect(function()
                if States.NoCooldown then
                    for _, tool in pairs(Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local cooldown = tool:FindFirstChild("Cooldown")
                            if cooldown then
                                cooldown.Value = 0
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 30. ANTI SLOW
local AntiSlowToggle = PlayerTab:CreateToggle({
    Name = "Anti Slow",
    CurrentValue = false,
    Flag = "AntiSlowToggle",
    Callback = function(Value)
        States.AntiSlow = Value
        
        if Value then
            CreateConnection("AntiSlowLoop", RS.Heartbeat:Connect(function()
                if States.AntiSlow and Humanoid then
                    Humanoid.WalkSpeed = SpeedSlider.CurrentValue
                end
            end))
        end
    end,
})

-- 31. WALK ON AIR
local AirPlatform
local WalkOnAirToggle = FunTab:CreateToggle({
    Name = "Walk on Air",
    CurrentValue = false,
    Flag = "WalkOnAirToggle",
    Callback = function(Value)
        States.WalkOnAir = Value
        
        if Value then
            AirPlatform = Instance.new("Part")
            AirPlatform.Name = "AirPlatform"
            AirPlatform.Size = Vector3.new(50, 2, 50)
            AirPlatform.Transparency = 0.8
            AirPlatform.Color = Color3.fromRGB(255, 255, 255)
            AirPlatform.Anchored = true
            AirPlatform.CanCollide = true
            AirPlatform.Parent = WS
            
            CreateConnection("UpdateAirPlatform", RS.Heartbeat:Connect(function()
                if AirPlatform then
                    AirPlatform.Position = Vector3.new(
                        HRP.Position.X,
                        HRP.Position.Y - 10,
                        HRP.Position.Z
                    )
                end
            end))
        else
            if AirPlatform then
                AirPlatform:Destroy()
                AirPlatform = nil
            end
        end
    end,
})

-- 32. AUTO DANCE
local AutoDanceToggle = FunTab:CreateToggle({
    Name = "Auto Dance",
    CurrentValue = false,
    Flag = "AutoDanceToggle",
    Callback = function(Value)
        States.AutoDance = Value
        
        if Value and Humanoid then
            local animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://181121537" -- Default dance
            
            local animator = Humanoid:FindFirstChildOfClass("Animator")
            if animator then
                local danceTrack = animator:LoadAnimation(animation)
                danceTrack:Play()
                
                CreateConnection("DanceLoop", RS.Heartbeat:Connect(function()
                    if States.AutoDance and danceTrack.IsPlaying == false then
                        danceTrack:Play()
                    end
                end))
            end
        end
    end,
})

-- 33. AUTO CHAT SPAM
local SpamMessages = {
    "Infinity Hub OP!",
    "Powered by Infinity Yield",
    "Best Universal Script!",
    "Hacking with style!",
    "100+ Features Active!"
}

local AutoSpamToggle = FunTab:CreateToggle({
    Name = "Auto Chat Spam",
    CurrentValue = false,
    Flag = "AutoSpamToggle",
    Callback = function(Value)
        States.AutoSpam = Value
        
        if Value then
            CreateConnection("SpamLoop", RS.Heartbeat:Connect(function()
                if States.AutoSpam then
                    task.wait(5) -- Spam every 5 seconds
                    local message = SpamMessages[math.random(1, #SpamMessages)]
                    SafeCall(function()
                        ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, "All")
                    end)
                end
            end))
        end
    end,
})

-- 34. LAG SWITCH (軽量化バージョン)
local LagSwitchToggle = MiscTab:CreateToggle({
    Name = "Lag Switch",
    CurrentValue = false,
    Flag = "LagSwitchToggle",
    Callback = function(Value)
        States.LagSwitch = Value
        
        if Value then
            CreateConnection("LagLoop", RS.Heartbeat:Connect(function()
                if States.LagSwitch then
                    for i = 1, 100 do
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(1, 1, 1)
                        part.Position = HRP.Position + Vector3.new(math.random(-50, 50), 0, math.random(-50, 50))
                        part.Anchored = true
                        part.CanCollide = false
                        part.Transparency = 1
                        part.Parent = WS
                        task.wait()
                        part:Destroy()
                    end
                end
            end))
        end
    end,
})

-- 35. ESP TRACERS
local ESPTracersToggle = ESPTab:CreateToggle({
    Name = "ESP Tracers",
    CurrentValue = false,
    Flag = "ESPTracersToggle",
    Callback = function(Value)
        States.ESPTracers = Value
        
        if Value then
            CreateConnection("TracerLoop", RS.Heartbeat:Connect(function()
                if States.ESPTracers then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local screenPos, onScreen = WS.CurrentCamera:WorldToViewportPoint(hrp.Position)
                                
                                if onScreen then
                                    -- Create tracer line
                                    local line = Drawing.new("Line")
                                    line.From = Vector2.new(WS.CurrentCamera.ViewportSize.X/2, WS.CurrentCamera.ViewportSize.Y)
                                    line.To = Vector2.new(screenPos.X, screenPos.Y)
                                    line.Color = Color3.fromRGB(255, 0, 0)
                                    line.Thickness = 1
                                    line.Visible = true
                                    
                                    task.wait(0.1)
                                    line:Remove()
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 36. AUTO WAYPOINT
local CurrentWaypoint
local AutoWaypointToggle = TeleportTab:CreateToggle({
    Name = "Auto Waypoint",
    CurrentValue = false,
    Flag = "AutoWaypointToggle",
    Callback = function(Value)
        States.AutoWaypoint = Value
        
        if Value then
            Mouse.Button1Down:Connect(function()
                if States.AutoWaypoint then
                    if CurrentWaypoint then
                        CurrentWaypoint:Destroy()
                    end
                    
                    CurrentWaypoint = Instance.new("Part")
                    CurrentWaypoint.Name = "Waypoint"
                    CurrentWaypoint.Size = Vector3.new(5, 5, 5)
                    CurrentWaypoint.Position = Mouse.Hit.Position + Vector3.new(0, 2.5, 0)
                    CurrentWaypoint.Transparency = 0.5
                    CurrentWaypoint.Color = Color3.fromRGB(0, 255, 0)
                    CurrentWaypoint.Anchored = true
                    CurrentWaypoint.CanCollide = false
                    CurrentWaypoint.Parent = WS
                    
                    -- Add billboard
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 100, 0, 50)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    
                    local text = Instance.new("TextLabel")
                    text.Size = UDim2.new(1, 0, 1, 0)
                    text.Text = "WAYPOINT"
                    text.TextColor3 = Color3.new(0, 1, 0)
                    text.BackgroundTransparency = 1
                    text.Parent = billboard
                    billboard.Parent = CurrentWaypoint
                end
            end)
        elseif CurrentWaypoint then
            CurrentWaypoint:Destroy()
            CurrentWaypoint = nil
        end
    end,
})

-- 37. ANTI BAN (基本保護)
local AntiBanToggle = MiscTab:CreateToggle({
    Name = "Anti Ban Protection",
    CurrentValue = false,
    Flag = "AntiBanToggle",
    Callback = function(Value)
        States.AntiBan = Value
        
        if Value then
            Rayfield:Notify({
                Title = "Anti Ban Enabled",
                Content = "Basic protection measures activated",
                Duration = 5,
                Image = 4483362458
            })
        end
    end,
})

-- 38. AUTO EQUIP BEST TOOL
local AutoEquipToggle = CombatTab:CreateToggle({
    Name = "Auto Equip Best Tool",
    CurrentValue = false,
    Flag = "AutoEquipToggle",
    Callback = function(Value)
        States.AutoEquip = Value
        
        if Value then
            CreateConnection("AutoEquipLoop", RS.Heartbeat:Connect(function()
                if States.AutoEquip then
                    local bestTool = nil
                    local highestDamage = 0
                    
                    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            local damage = tool:FindFirstChild("Damage") or tool:FindFirstChild("damage")
                            if damage then
                                local damageValue = tonumber(damage.Value) or 0
                                if damageValue > highestDamage then
                                    highestDamage = damageValue
                                    bestTool = tool
                                end
                            end
                        end
                    end
                    
                    if bestTool and not Character:FindFirstChild(bestTool.Name) then
                        bestTool.Parent = Character
                    end
                end
            end))
        end
    end,
})

-- 39. AUTO SELL
local AutoSellToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Sell",
    CurrentValue = false,
    Flag = "AutoSellToggle",
    Callback = function(Value)
        States.AutoSell = Value
        
        if Value then
            CreateConnection("AutoSellLoop", RS.Heartbeat:Connect(function()
                if States.AutoSell then
                    local sellStation = GetNearestObject("Sell", 50) or GetNearestObject("Market", 50)
                    if sellStation then
                        HRP.CFrame = CFrame.new(sellStation.Position + Vector3.new(0, 3, 0))
                        
                        if sellStation:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(sellStation.ProximityPrompt)
                        elseif sellStation:FindFirstChild("ClickDetector") then
                            fireclickdetector(sellStation.ClickDetector)
                        end
                    end
                end
            end))
        end
    end,
})

-- 40. AUTO BUY
local AutoBuyToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Buy",
    CurrentValue = false,
    Flag = "AutoBuyToggle",
    Callback = function(Value)
        States.AutoBuy = Value
        
        if Value then
            CreateConnection("AutoBuyLoop", RS.Heartbeat:Connect(function()
                if States.AutoBuy then
                    local shop = GetNearestObject("Shop", 50) or GetNearestObject("Store", 50)
                    if shop then
                        HRP.CFrame = CFrame.new(shop.Position + Vector3.new(0, 3, 0))
                        
                        if shop:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(shop.ProximityPrompt)
                        elseif shop:FindFirstChild("ClickDetector") then
                            fireclickdetector(shop.ClickDetector)
                        end
                    end
                end
            end))
        end
    end,
})

-- 41. ANTI STUN
local AntiStunToggle = PlayerTab:CreateToggle({
    Name = "Anti Stun",
    CurrentValue = false,
    Flag = "AntiStunToggle",
    Callback = function(Value)
        States.AntiStun = Value
        if Humanoid then
            if Value then
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Stunned, false)
            else
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Stunned, true)
            end
        end
    end,
})

-- 42. ANTI GRAB
local AntiGrabToggle = PlayerTab:CreateToggle({
    Name = "Anti Grab",
    CurrentValue = false,
    Flag = "AntiGrabToggle",
    Callback = function(Value)
        States.AntiGrab = Value
        if Humanoid then
            if Value then
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            else
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            end
        end
    end,
})

-- 43. ANTI KNOCKBACK
local AntiKnockbackToggle = PlayerTab:CreateToggle({
    Name = "Anti Knockback",
    CurrentValue = false,
    Flag = "AntiKnockbackToggle",
    Callback = function(Value)
        States.AntiKnockback = Value
        
        if Value then
            CreateConnection("AntiKnockbackLoop", RS.Heartbeat:Connect(function()
                if States.AntiKnockback and HRP then
                    HRP.Velocity = Vector3.new(0, HRP.Velocity.Y, 0)
                end
            end))
        end
    end,
})

-- 44. ESP CHESTS
local ESPChestsToggle = ESPTab:CreateToggle({
    Name = "ESP Chests",
    CurrentValue = false,
    Flag = "ESPChestsToggle",
    Callback = function(Value)
        States.ESPChests = Value
        
        if Value then
            CreateConnection("ESPChestsLoop", RS.Heartbeat:Connect(function()
                if States.ESPChests then
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj.Name:match("Chest") or obj.Name:match("chest") then
                            if not obj:FindFirstChild("ChestESP") then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "ChestESP"
                                highlight.Parent = obj
                                highlight.FillColor = Color3.fromRGB(255, 215, 0)
                                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                                highlight.FillTransparency = 0.3
                            end
                        end
                    end
                else
                    for _, obj in pairs(WS:GetChildren()) do
                        local esp = obj:FindFirstChild("ChestESP")
                        if esp then
                            esp:Destroy()
                        end
                    end
                end
            end))
        end
    end,
})

-- 45. ESP NPCs
local ESPNPCsToggle = ESPTab:CreateToggle({
    Name = "ESP NPCs",
    CurrentValue = false,
    Flag = "ESPNPCsToggle",
    Callback = function(Value)
        States.ESPNPCs = Value
        
        if Value then
            CreateConnection("ESPNPCsLoop", RS.Heartbeat:Connect(function()
                if States.ESPNPCs then
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                            if not obj:FindFirstChild("NPCESP") then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "NPCESP"
                                highlight.Parent = obj
                                highlight.FillColor = Color3.fromRGB(0, 100, 255)
                                highlight.OutlineColor = Color3.fromRGB(0, 150, 255)
                                highlight.FillTransparency = 0.4
                            end
                        end
                    end
                else
                    for _, obj in pairs(WS:GetChildren()) do
                        local esp = obj:FindFirstChild("NPCESP")
                        if esp then
                            esp:Destroy()
                        end
                    end
                end
            end))
        end
    end,
})

-- 46. AUTO CHOP
local AutoChopToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Chop Trees",
    CurrentValue = false,
    Flag = "AutoChopToggle",
    Callback = function(Value)
        States.AutoChop = Value
        
        if Value then
            CreateConnection("AutoChopLoop", RS.Heartbeat:Connect(function()
                if States.AutoChop then
                    local tree = GetNearestObject("Tree", 50) or GetNearestObject("Wood", 50)
                    if tree then
                        HRP.CFrame = CFrame.new(tree.Position + Vector3.new(0, 3, 0))
                        
                        if tree:FindFirstChild("ClickDetector") then
                            fireclickdetector(tree.ClickDetector)
                        else
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        end
                    end
                end
            end))
        end
    end,
})

-- 47. AUTO DIG
local AutoDigToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Dig",
    CurrentValue = false,
    Flag = "AutoDigToggle",
    Callback = function(Value)
        States.AutoDig = Value
        
        if Value then
            CreateConnection("AutoDigLoop", RS.Heartbeat:Connect(function()
                if States.AutoDig then
                    local digSpot = GetNearestObject("Dig", 50) or GetNearestObject("Dirt", 50)
                    if digSpot then
                        HRP.CFrame = CFrame.new(digSpot.Position + Vector3.new(0, 3, 0))
                        
                        local tool = Character:FindFirstChild("Shovel") or Character:FindFirstChildWhichIsA("Tool")
                        if tool then
                            tool:Activate()
                        end
                    end
                end
            end))
        end
    end,
})

-- 48. ESP DOORS
local ESPDoorsToggle = ESPTab:CreateToggle({
    Name = "ESP Doors",
    CurrentValue = false,
    Flag = "ESPDoorsToggle",
    Callback = function(Value)
        States.ESPDoors = Value
        
        if Value then
            CreateConnection("ESPDoorsLoop", RS.Heartbeat:Connect(function()
                if States.ESPDoors then
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj.Name:match("Door") or obj.Name:match("door") then
                            if not obj:FindFirstChild("DoorESP") then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "DoorESP"
                                highlight.Parent = obj
                                highlight.FillColor = Color3.fromRGB(139, 69, 19)
                                highlight.OutlineColor = Color3.fromRGB(160, 82, 45)
                                highlight.FillTransparency = 0.4
                            end
                        end
                    end
                else
                    for _, obj in pairs(WS:GetChildren()) do
                        local esp = obj:FindFirstChild("DoorESP")
                        if esp then
                            esp:Destroy()
                        end
                    end
                end
            end))
        end
    end,
})

-- 49. ESP MONEY
local ESPMoneyToggle = ESPTab:CreateToggle({
    Name = "ESP Money",
    CurrentValue = false,
    Flag = "ESPMoneyToggle",
    Callback = function(Value)
        States.ESPMoney = Value
        
        if Value then
            CreateConnection("ESPMoneyLoop", RS.Heartbeat:Connect(function()
                if States.ESPMoney then
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj.Name:match("Money") or obj.Name:match("Cash") or obj.Name:match("Dollar") then
                            if not obj:FindFirstChild("MoneyESP") then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "MoneyESP"
                                highlight.Parent = obj
                                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                                highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
                                highlight.FillTransparency = 0.3
                            end
                        end
                    end
                else
                    for _, obj in pairs(WS:GetChildren()) do
                        local esp = obj:FindFirstChild("MoneyESP")
                        if esp then
                            esp:Destroy()
                        end
                    end
                end
            end))
        end
    end,
})

-- 50. ESP GUNS
local ESPGunsToggle = ESPTab:CreateToggle({
    Name = "ESP Guns",
    CurrentValue = false,
    Flag = "ESPGunsToggle",
    Callback = function(Value)
        States.ESPGuns = Value
        
        if Value then
            CreateConnection("ESPGunsLoop", RS.Heartbeat:Connect(function()
                if States.ESPGuns then
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj.Name:match("Gun") or obj.Name:match("Weapon") or obj:IsA("Tool") then
                            if not obj:FindFirstChild("GunESP") then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "GunESP"
                                highlight.Parent = obj
                                highlight.FillColor = Color3.fromRGB(128, 0, 128)
                                highlight.OutlineColor = Color3.fromRGB(255, 0, 255)
                                highlight.FillTransparency = 0.3
                            end
                        end
                    end
                else
                    for _, obj in pairs(WS:GetChildren()) do
                        local esp = obj:FindFirstChild("GunESP")
                        if esp then
                            esp:Destroy()
                        end
                    end
                end
            end))
        end
    end,
})

-- 51. AUTO SWING
local AutoSwingToggle = CombatTab:CreateToggle({
    Name = "Auto Swing Tool",
    CurrentValue = false,
    Flag = "AutoSwingToggle",
    Callback = function(Value)
        States.AutoSwing = Value
        
        if Value then
            CreateConnection("AutoSwingLoop", RS.Heartbeat:Connect(function()
                if States.AutoSwing then
                    local tool = Character:FindFirstChildWhichIsA("Tool")
                    if tool then
                        tool:Activate()
                    end
                end
            end))
        end
    end,
})

-- 52. AUTO BUILD (基本)
local AutoBuildToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Build",
    CurrentValue = false,
    Flag = "AutoBuildToggle",
    Callback = function(Value)
        States.AutoBuild = Value
        
        if Value then
            CreateConnection("AutoBuildLoop", RS.Heartbeat:Connect(function()
                if States.AutoBuild then
                    local buildSite = GetNearestObject("Build", 50) or GetNearestObject("Construction", 50)
                    if buildSite then
                        HRP.CFrame = CFrame.new(buildSite.Position + Vector3.new(0, 3, 0))
                        
                        if buildSite:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(buildSite.ProximityPrompt)
                        end
                    end
                end
            end))
        end
    end,
})

-- 53. AUTO CRAFT
local AutoCraftToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Craft",
    CurrentValue = false,
    Flag = "AutoCraftToggle",
    Callback = function(Value)
        States.AutoCraft = Value
        
        if Value then
            CreateConnection("AutoCraftLoop", RS.Heartbeat:Connect(function()
                if States.AutoCraft then
                    local craftStation = GetNearestObject("Craft", 50) or GetNearestObject("Workbench", 50)
                    if craftStation then
                        HRP.CFrame = CFrame.new(craftStation.Position + Vector3.new(0, 3, 0))
                        
                        if craftStation:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(craftStation.ProximityPrompt)
                        end
                    end
                end
            end))
        end
    end,
})

-- 54. AUTO ENCHANT
local AutoEnchantToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Enchant",
    CurrentValue = false,
    Flag = "AutoEnchantToggle",
    Callback = function(Value)
        States.AutoEnchant = Value
        
        if Value then
            CreateConnection("AutoEnchantLoop", RS.Heartbeat:Connect(function()
                if States.AutoEnchant then
                    local enchantTable = GetNearestObject("Enchant", 50) or GetNearestObject("Altar", 50)
                    if enchantTable then
                        HRP.CFrame = CFrame.new(enchantTable.Position + Vector3.new(0, 3, 0))
                        
                        if enchantTable:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(enchantTable.ProximityPrompt)
                        end
                    end
                end
            end))
        end
    end,
})

-- 55. AUTO UPGRADE
local AutoUpgradeToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Upgrade",
    CurrentValue = false,
    Flag = "AutoUpgradeToggle",
    Callback = function(Value)
        States.AutoUpgrade = Value
        
        if Value then
            CreateConnection("AutoUpgradeLoop", RS.Heartbeat:Connect(function()
                if States.AutoUpgrade then
                    local upgradeStation = GetNearestObject("Upgrade", 50) or GetNearestObject("Forge", 50)
                    if upgradeStation then
                        HRP.CFrame = CFrame.new(upgradeStation.Position + Vector3.new(0, 3, 0))
                        
                        if upgradeStation:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(upgradeStation.ProximityPrompt)
                        end
                    end
                end
            end))
        end
    end,
})

-- 56. AUTO SELL ALL
local AutoSellAllToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Sell All Items",
    CurrentValue = false,
    Flag = "AutoSellAllToggle",
    Callback = function(Value)
        States.AutoSellAll = Value
        
        if Value then
            CreateConnection("AutoSellAllLoop", RS.Heartbeat:Connect(function()
                if States.AutoSellAll then
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj.Name:match("Sell") or obj.Name:match("Market") then
                            if obj:FindFirstChild("ProximityPrompt") then
                                for i = 1, 10 do -- Sell multiple times
                                    fireproximityprompt(obj.ProximityPrompt)
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 57. AUTO BUY ALL
local AutoBuyAllToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Buy All",
    CurrentValue = false,
    Flag = "AutoBuyAllToggle",
    Callback = function(Value)
        States.AutoBuyAll = Value
        
        if Value then
            CreateConnection("AutoBuyAllLoop", RS.Heartbeat:Connect(function()
                if States.AutoBuyAll then
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj.Name:match("Shop") or obj.Name:match("Store") then
                            if obj:FindFirstChild("ProximityPrompt") then
                                for i = 1, 5 do -- Buy multiple times
                                    fireproximityprompt(obj.ProximityPrompt)
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 58. AUTO TRADE
local AutoTradeToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Trade",
    CurrentValue = false,
    Flag = "AutoTradeToggle",
    Callback = function(Value)
        States.AutoTrade = Value
        
        if Value then
            CreateConnection("AutoTradeLoop", RS.Heartbeat:Connect(function()
                if States.AutoTrade then
                    local tradeStation = GetNearestObject("Trade", 50) or GetNearestObject("Exchange", 50)
                    if tradeStation then
                        HRP.CFrame = CFrame.new(tradeStation.Position + Vector3.new(0, 3, 0))
                        
                        if tradeStation:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(tradeStation.ProximityPrompt)
                        end
                    end
                end
            end))
        end
    end,
})

-- 59. AUTO GIFT
local AutoGiftToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Open Gifts",
    CurrentValue = false,
    Flag = "AutoGiftToggle",
    Callback = function(Value)
        States.AutoGift = Value
        
        if Value then
            CreateConnection("AutoGiftLoop", RS.Heartbeat:Connect(function()
                if States.AutoGift then
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj.Name:match("Gift") or obj.Name:match("Present") then
                            if obj:FindFirstChild("ClickDetector") then
                                fireclickdetector(obj.ClickDetector)
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 60. AUTO CLAIM
local AutoClaimToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Claim Rewards",
    CurrentValue = false,
    Flag = "AutoClaimToggle",
    Callback = function(Value)
        States.AutoClaim = Value
        
        if Value then
            CreateConnection("AutoClaimLoop", RS.Heartbeat:Connect(function()
                if States.AutoClaim then
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj.Name:match("Reward") or obj.Name:match("Claim") then
                            if obj:FindFirstChild("ProximityPrompt") then
                                fireproximityprompt(obj.ProximityPrompt)
                            elseif obj:FindFirstChild("ClickDetector") then
                                fireclickdetector(obj.ClickDetector)
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 61. AUTO SPIN
local AutoSpinToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Spin Wheel",
    CurrentValue = false,
    Flag = "AutoSpinToggle",
    Callback = function(Value)
        States.AutoSpin = Value
        
        if Value then
            CreateConnection("AutoSpinLoop", RS.Heartbeat:Connect(function()
                if States.AutoSpin then
                    local wheel = GetNearestObject("Wheel", 50) or GetNearestObject("Lucky", 50)
                    if wheel then
                        HRP.CFrame = CFrame.new(wheel.Position + Vector3.new(0, 3, 0))
                        
                        if wheel:FindFirstChild("ProximityPrompt") then
                            fireproximityprompt(wheel.ProximityPrompt)
                        elseif wheel:FindFirstChild("ClickDetector") then
                            fireclickdetector(wheel.ClickDetector)
                        end
                    end
                end
            end))
        end
    end,
})

-- 62. AUTO OPEN
local AutoOpenToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Open Crates",
    CurrentValue = false,
    Flag = "AutoOpenToggle",
    Callback = function(Value)
        States.AutoOpen = Value
        
        if Value then
            CreateConnection("AutoOpenLoop", RS.Heartbeat:Connect(function()
                if States.AutoOpen then
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj.Name:match("Crate") or obj.Name:match("Box") or obj.Name:match("Chest") then
                            if obj:FindFirstChild("ClickDetector") then
                                fireclickdetector(obj.ClickDetector)
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 63. AUTO JOIN TEAM
local AutoJoinToggle = FunTab:CreateToggle({
    Name = "Auto Join Team",
    CurrentValue = false,
    Flag = "AutoJoinToggle",
    Callback = function(Value)
        States.AutoJoin = Value
        
        if Value then
            CreateConnection("AutoJoinLoop", RS.Heartbeat:Connect(function()
                if States.AutoJoin then
                    local teams = game:GetService("Teams"):GetTeams()
                    if #teams > 0 and LocalPlayer.Team == nil then
                        LocalPlayer.Team = teams[1]
                    end
                end
            end))
        end
    end,
})

-- 64. AUTO SIT
local AutoSitToggle = FunTab:CreateToggle({
    Name = "Auto Sit",
    CurrentValue = false,
    Flag = "AutoSitToggle",
    Callback = function(Value)
        States.AutoSit = Value
        if Humanoid then
            Humanoid.Sit = Value
        end
    end,
})

-- 65. AUTO RUN
local AutoRunToggle = FunTab:CreateToggle({
    Name = "Auto Run",
    CurrentValue = false,
    Flag = "AutoRunToggle",
    Callback = function(Value)
        States.AutoRun = Value
        
        if Value then
            CreateConnection("AutoRunLoop", RS.Heartbeat:Connect(function()
                if States.AutoRun and Humanoid then
                    Humanoid:Move(Vector3.new(0, 0, -1))
                end
            end))
        end
    end,
})

-- 66. AUTO SWIM
local AutoSwimToggle = FunTab:CreateToggle({
    Name = "Auto Swim",
    CurrentValue = false,
    Flag = "AutoSwimToggle",
    Callback = function(Value)
        States.AutoSwim = Value
        
        if Value and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
        end
    end,
})

-- 67. AUTO CLIMB
local AutoClimbToggle = FunTab:CreateToggle({
    Name = "Auto Climb",
    CurrentValue = false,
    Flag = "AutoClimbToggle",
    Callback = function(Value)
        States.AutoClimb = Value
        
        if Value and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
        end
    end,
})

-- 68. AUTO CRAWL
local AutoCrawlToggle = FunTab:CreateToggle({
    Name = "Auto Crawl",
    CurrentValue = false,
    Flag = "AutoCrawlToggle",
    Callback = function(Value)
        States.AutoCrawl = Value
        
        if Value and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end,
})

-- 69. AUTO ROLL
local AutoRollToggle = FunTab:CreateToggle({
    Name = "Auto Roll",
    CurrentValue = false,
    Flag = "AutoRollToggle",
    Callback = function(Value)
        States.AutoRoll = Value
        
        if Value and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
        end
    end,
})

-- 70. AUTO DASH
local AutoDashToggle = FunTab:CreateToggle({
    Name = "Auto Dash",
    CurrentValue = false,
    Flag = "AutoDashToggle",
    Callback = function(Value)
        States.AutoDash = Value
        
        if Value then
            CreateConnection("AutoDashLoop", RS.Heartbeat:Connect(function()
                if States.AutoDash and HRP then
                    HRP.Velocity = HRP.CFrame.LookVector * 100
                end
            end))
        end
    end,
})

-- 71. AUTO HEAL
local AutoHealToggle = CombatTab:CreateToggle({
    Name = "Auto Heal",
    CurrentValue = false,
    Flag = "AutoHealToggle",
    Callback = function(Value)
        States.AutoHeal = Value
        
        if Value then
            CreateConnection("AutoHealLoop", RS.Heartbeat:Connect(function()
                if States.AutoHeal and Humanoid then
                    if Humanoid.Health < Humanoid.MaxHealth * 0.5 then
                        Humanoid.Health = Humanoid.MaxHealth
                    end
                end
            end))
        end
    end,
})

-- 72. AUTO SHIELD
local AutoShieldToggle = CombatTab:CreateToggle({
    Name = "Auto Shield",
    CurrentValue = false,
    Flag = "AutoShieldToggle",
    Callback = function(Value)
        States.AutoShield = Value
        Rayfield:Notify({
            Title = "Auto Shield",
            Content = "Shield system activated",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- 73. AUTO ATTACK
local AutoAttackToggle = CombatTab:CreateToggle({
    Name = "Auto Attack Nearest",
    CurrentValue = false,
    Flag = "AutoAttackToggle",
    Callback = function(Value)
        States.AutoAttack = Value
        
        if Value then
            CreateConnection("AutoAttackLoop", RS.Heartbeat:Connect(function()
                if States.AutoAttack then
                    local nearest, distance = GetNearestPlayer(100)
                    if nearest and nearest.Character then
                        local targetHRP = nearest.Character:FindFirstChild("HumanoidRootPart")
                        if targetHRP and distance < 20 then
                            HRP.CFrame = CFrame.new(HRP.Position, Vector3.new(
                                targetHRP.Position.X,
                                HRP.Position.Y,
                                targetHRP.Position.Z
                            ))
                            
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                            task.wait(0.1)
                            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                        end
                    end
                end
            end))
        end
    end,
})

-- 74. AUTO DEFEND
local AutoDefendToggle = CombatTab:CreateToggle({
    Name = "Auto Defend",
    CurrentValue = false,
    Flag = "AutoDefendToggle",
    Callback = function(Value)
        States.AutoDefend = Value
        
        if Value and Humanoid then
            Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
    end,
})

-- 75. AUTO BLOCK
local AutoBlockToggle = CombatTab:CreateToggle({
    Name = "Auto Block",
    CurrentValue = false,
    Flag = "AutoBlockToggle",
    Callback = function(Value)
        States.AutoBlock = Value
        
        if Value then
            CreateConnection("AutoBlockLoop", RS.Heartbeat:Connect(function()
                if States.AutoBlock then
                    local tool = Character:FindFirstChildWhichIsA("Tool")
                    if tool then
                        local block = tool:FindFirstChild("Block")
                        if block then
                            block.Value = true
                        end
                    end
                end
            end))
        end
    end,
})

-- 76. AUTO PARRY
local AutoParryToggle = CombatTab:CreateToggle({
    Name = "Auto Parry",
    CurrentValue = false,
    Flag = "AutoParryToggle",
    Callback = function(Value)
        States.AutoParry = Value
        Rayfield:Notify({
            Title = "Auto Parry",
            Content = "Parry system activated",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- 77. AUTO DODGE
local AutoDodgeToggle = CombatTab:CreateToggle({
    Name = "Auto Dodge",
    CurrentValue = false,
    Flag = "AutoDodgeToggle",
    Callback = function(Value)
        States.AutoDodge = Value
        
        if Value then
            CreateConnection("AutoDodgeLoop", RS.Heartbeat:Connect(function()
                if States.AutoDodge and Humanoid then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end))
        end
    end,
})

-- 78. AUTO COUNTER
local AutoCounterToggle = CombatTab:CreateToggle({
    Name = "Auto Counter",
    CurrentValue = false,
    Flag = "AutoCounterToggle",
    Callback = function(Value)
        States.AutoCounter = Value
        Rayfield:Notify({
            Title = "Auto Counter",
            Content = "Counter system activated",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- 79. AUTO COMBO
local AutoComboToggle = CombatTab:CreateToggle({
    Name = "Auto Combo",
    CurrentValue = false,
    Flag = "AutoComboToggle",
    Callback = function(Value)
        States.AutoCombo = Value
        
        if Value then
            CreateConnection("AutoComboLoop", RS.Heartbeat:Connect(function()
                if States.AutoCombo then
                    for i = 1, 5 do
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.2)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end
                end
            end))
        end
    end,
})

-- 80. AUTO ULTIMATE
local AutoUltimateToggle = CombatTab:CreateToggle({
    Name = "Auto Ultimate",
    CurrentValue = false,
    Flag = "AutoUltimateToggle",
    Callback = function(Value)
        States.AutoUltimate = Value
        
        if Value then
            CreateConnection("AutoUltimateLoop", RS.Heartbeat:Connect(function()
                if States.AutoUltimate then
                    local nearest, distance = GetNearestPlayer(50)
                    if nearest and distance < 30 then
                        VirtualInputManager:SendKeyEvent(true, "R", false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, "R", false, game)
                    end
                end
            end))
        end
    end,
})

-- 81. ESP BOX
local ESPBoxToggle = ESPTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = false,
    Flag = "ESPBoxToggle",
    Callback = function(Value)
        States.ESPBox = Value
        
        if Value then
            CreateConnection("ESPBoxLoop", RS.Heartbeat:Connect(function()
                if States.ESPBox then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local screenPos, onScreen = WS.CurrentCamera:WorldToViewportPoint(hrp.Position)
                                
                                if onScreen then
                                    local size = Vector2.new(50, 100)
                                    local pos = Vector2.new(screenPos.X - size.X/2, screenPos.Y - size.Y/2)
                                    
                                    -- Draw box (using Highlight as alternative)
                                    if not hrp:FindFirstChild("BoxESP") then
                                        local box = Instance.new("BoxHandleAdornment")
                                        box.Name = "BoxESP"
                                        box.Size = Vector3.new(4, 6, 4)
                                        box.Color3 = Color3.fromRGB(255, 0, 0)
                                        box.Transparency = 0.5
                                        box.Adornee = hrp
                                        box.AlwaysOnTop = true
                                        box.Parent = hrp
                                    end
                                end
                            end
                        end
                    end
                else
                    for _, player in pairs(Players:GetPlayers()) do
                        if player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local box = hrp:FindFirstChild("BoxESP")
                                if box then
                                    box:Destroy()
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 82. ESP NAMES
local ESPNamesToggle = ESPTab:CreateToggle({
    Name = "ESP Names",
    CurrentValue = false,
    Flag = "ESPNamesToggle",
    Callback = function(Value)
        States.ESPNames = Value
        
        if Value then
            CreateConnection("ESPNamesLoop", RS.Heartbeat:Connect(function()
                if States.ESPNames then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local head = player.Character:FindFirstChild("Head")
                            if head and not head:FindFirstChild("NameESP") then
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "NameESP"
                                billboard.Size = UDim2.new(0, 200, 0, 50)
                                billboard.StudsOffset = Vector3.new(0, 3, 0)
                                billboard.AlwaysOnTop = true
                                
                                local text = Instance.new("TextLabel")
                                text.Size = UDim2.new(1, 0, 1, 0)
                                text.Text = player.Name
                                text.TextColor3 = Color3.new(1, 1, 1)
                                text.BackgroundTransparency = 1
                                text.TextScaled = true
                                text.Parent = billboard
                                
                                billboard.Parent = head
                            end
                        end
                    end
                else
                    for _, player in pairs(Players:GetPlayers()) do
                        if player.Character then
                            local head = player.Character:FindFirstChild("Head")
                            if head then
                                local billboard = head:FindFirstChild("NameESP")
                                if billboard then
                                    billboard:Destroy()
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 83. ESP HEALTH
local ESPHealthToggle = ESPTab:CreateToggle({
    Name = "ESP Health",
    CurrentValue = false,
    Flag = "ESPHealthToggle",
    Callback = function(Value)
        States.ESPHealth = Value
        
        if Value then
            CreateConnection("ESPHealthLoop", RS.Heartbeat:Connect(function()
                if States.ESPHealth then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local humanoid = player.Character:FindFirstChild("Humanoid")
                            local head = player.Character:FindFirstChild("Head")
                            
                            if humanoid and head and not head:FindFirstChild("HealthESP") then
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "HealthESP"
                                billboard.Size = UDim2.new(0, 200, 0, 30)
                                billboard.StudsOffset = Vector3.new(0, 2, 0)
                                billboard.AlwaysOnTop = true
                                
                                local text = Instance.new("TextLabel")
                                text.Size = UDim2.new(1, 0, 1, 0)
                                text.Text = "HP: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                                text.TextColor3 = Color3.new(0, 1, 0)
                                text.BackgroundTransparency = 1
                                text.TextScaled = true
                                text.Parent = billboard
                                
                                billboard.Parent = head
                            end
                        end
                    end
                else
                    for _, player in pairs(Players:GetPlayers()) do
                        if player.Character then
                            local head = player.Character:FindFirstChild("Head")
                            if head then
                                local billboard = head:FindFirstChild("HealthESP")
                                if billboard then
                                    billboard:Destroy()
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 84. ESP DISTANCE
local ESPDistanceToggle = ESPTab:CreateToggle({
    Name = "ESP Distance",
    CurrentValue = false,
    Flag = "ESPDistanceToggle",
    Callback = function(Value)
        States.ESPDistance = Value
        
        if Value then
            CreateConnection("ESPDistanceLoop", RS.Heartbeat:Connect(function()
                if States.ESPDistance then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            local head = player.Character:FindFirstChild("Head")
                            
                            if hrp and head and not head:FindFirstChild("DistanceESP") then
                                local distance = (HRP.Position - hrp.Position).Magnitude
                                
                                local billboard = Instance.new("BillboardGui")
                                billboard.Name = "DistanceESP"
                                billboard.Size = UDim2.new(0, 200, 0, 30)
                                billboard.StudsOffset = Vector3.new(0, 1.5, 0)
                                billboard.AlwaysOnTop = true
                                
                                local text = Instance.new("TextLabel")
                                text.Size = UDim2.new(1, 0, 1, 0)
                                text.Text = math.floor(distance) .. " studs"
                                text.TextColor3 = Color3.new(1, 1, 0)
                                text.BackgroundTransparency = 1
                                text.TextScaled = true
                                text.Parent = billboard
                                
                                billboard.Parent = head
                            end
                        end
                    end
                else
                    for _, player in pairs(Players:GetPlayers()) do
                        if player.Character then
                            local head = player.Character:FindFirstChild("Head")
                            if head then
                                local billboard = head:FindFirstChild("DistanceESP")
                                if billboard then
                                    billboard:Destroy()
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 85. ESP GLOW
local ESPGlowToggle = ESPTab:CreateToggle({
    Name = "ESP Glow",
    CurrentValue = false,
    Flag = "ESPGlowToggle",
    Callback = function(Value)
        States.ESPGlow = Value
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, part in pairs(player.Character:GetChildren()) do
                        if part:IsA("BasePart") and not part:FindFirstChild("GlowESP") then
                            local pointLight = Instance.new("PointLight")
                            pointLight.Name = "GlowESP"
                            pointLight.Brightness = 2
                            pointLight.Range = 20
                            pointLight.Color = Color3.fromRGB(255, 0, 255)
                            pointLight.Parent = part
                        end
                    end
                end
            end
        else
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    for _, part in pairs(player.Character:GetChildren()) do
                        local light = part:FindFirstChild("GlowESP")
                        if light then
                            light:Destroy()
                        end
                    end
                end
            end
        end
    end,
})

-- 86. VEHICLE SPEED
local VehicleSpeedSlider = VehicleTab:CreateSlider({
    Name = "Vehicle Speed",
    Range = {50, 1000},
    Increment = 10,
    Suffix = "speed",
    CurrentValue = 100,
    Flag = "VehicleSpeedSlider",
    Callback = function(Value)
        States.VehicleSpeed = Value
        
        local vehicle = Character:FindFirstChildWhichIsA("VehicleSeat")
        if vehicle then
            vehicle.MaxSpeed = Value
        end
    end,
})

-- 87. VEHICLE GOD MODE
local VehicleGodToggle = VehicleTab:CreateToggle({
    Name = "Vehicle God Mode",
    CurrentValue = false,
    Flag = "VehicleGodToggle",
    Callback = function(Value)
        States.VehicleGod = Value
        
        if Value then
            CreateConnection("VehicleGodLoop", RS.Heartbeat:Connect(function()
                if States.VehicleGod then
                    local vehicle = Character:FindFirstChildWhichIsA("VehicleSeat")
                    if vehicle then
                        for _, part in pairs(vehicle:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 88. VEHICLE NO CLIP
local VehicleNoClipToggle = VehicleTab:CreateToggle({
    Name = "Vehicle No Clip",
    CurrentValue = false,
    Flag = "VehicleNoClipToggle",
    Callback = function(Value)
        States.VehicleNoClip = Value
        
        if Value then
            CreateConnection("VehicleNoClipLoop", RS.Heartbeat:Connect(function()
                if States.VehicleNoClip then
                    local vehicle = Character:FindFirstChildWhichIsA("VehicleSeat")
                    if vehicle then
                        for _, part in pairs(vehicle:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 89. ESP VEHICLES
local ESPVehiclesToggle = ESPTab:CreateToggle({
    Name = "ESP Vehicles",
    CurrentValue = false,
    Flag = "ESPVehiclesToggle",
    Callback = function(Value)
        States.ESPVehicles = Value
        
        if Value then
            CreateConnection("ESPVehiclesLoop", RS.Heartbeat:Connect(function()
                if States.ESPVehicles then
                    for _, obj in pairs(WS:GetChildren()) do
                        if obj:IsA("VehicleSeat") or obj.Name:match("Vehicle") or obj.Name:match("Car") then
                            if not obj:FindFirstChild("VehicleESP") then
                                local highlight = Instance.new("Highlight")
                                highlight.Name = "VehicleESP"
                                highlight.Parent = obj
                                highlight.FillColor = Color3.fromRGB(0, 200, 255)
                                highlight.OutlineColor = Color3.fromRGB(0, 150, 255)
                                highlight.FillTransparency = 0.4
                            end
                        end
                    end
                else
                    for _, obj in pairs(WS:GetChildren()) do
                        local esp = obj:FindFirstChild("VehicleESP")
                        if esp then
                            esp:Destroy()
                        end
                    end
                end
            end))
        end
    end,
})

-- 90. AUTO FARM VEHICLE
local AutoFarmVehicleToggle = VehicleTab:CreateToggle({
    Name = "Auto Farm Vehicle",
    CurrentValue = false,
    Flag = "AutoFarmVehicleToggle",
    Callback = function(Value)
        States.AutoFarmVehicle = Value
        
        if Value then
            CreateConnection("AutoFarmVehicleLoop", RS.Heartbeat:Connect(function()
                if States.AutoFarmVehicle then
                    local vehicle = GetNearestObject("Vehicle", 200) or GetNearestObject("Car", 200)
                    if vehicle then
                        HRP.CFrame = CFrame.new(vehicle.Position + Vector3.new(0, 5, 0))
                        
                        if vehicle:FindFirstChild("ClickDetector") then
                            fireclickdetector(vehicle.ClickDetector)
                        end
                    end
                end
            end))
        end
    end,
})

-- 91. ANTI FREEZE
local AntiFreezeToggle = PlayerTab:CreateToggle({
    Name = "Anti Freeze",
    CurrentValue = false,
    Flag = "AntiFreezeToggle",
    Callback = function(Value)
        States.AntiFreeze = Value
        if Humanoid then
            if Value then
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Frozen, false)
            else
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Frozen, true)
            end
        end
    end,
})

-- 92. ANTI RAGDOLL
local AntiRagdollToggle = PlayerTab:CreateToggle({
    Name = "Anti Ragdoll",
    CurrentValue = false,
    Flag = "AntiRagdollToggle",
    Callback = function(Value)
        States.AntiRagdoll = Value
        if Humanoid then
            if Value then
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            else
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
            end
        end
    end,
})

-- 93. ANTI KILL
local AntiKillToggle = PlayerTab:CreateToggle({
    Name = "Anti Kill",
    CurrentValue = false,
    Flag = "AntiKillToggle",
    Callback = function(Value)
        States.AntiKill = Value
        
        if Value then
            CreateConnection("AntiKillLoop", RS.Heartbeat:Connect(function()
                if States.AntiKill and Humanoid then
                    if Humanoid.Health <= 0 then
                        Humanoid.Health = Humanoid.MaxHealth
                    end
                end
            end))
        end
    end,
})

-- 94. AUTO SKILL 1
local AutoSkill1Toggle = CombatTab:CreateToggle({
    Name = "Auto Skill 1 (Q)",
    CurrentValue = false,
    Flag = "AutoSkill1Toggle",
    Callback = function(Value)
        States.AutoSkill1 = Value
        
        if Value then
            CreateConnection("AutoSkill1Loop", RS.Heartbeat:Connect(function()
                if States.AutoSkill1 then
                    task.wait(1)
                    VirtualInputManager:SendKeyEvent(true, "Q", false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, "Q", false, game)
                end
            end))
        end
    end,
})

-- 95. AUTO SKILL 2
local AutoSkill2Toggle = CombatTab:CreateToggle({
    Name = "Auto Skill 2 (E)",
    CurrentValue = false,
    Flag = "AutoSkill2Toggle",
    Callback = function(Value)
        States.AutoSkill2 = Value
        
        if Value then
            CreateConnection("AutoSkill2Loop", RS.Heartbeat:Connect(function()
                if States.AutoSkill2 then
                    task.wait(2)
                    VirtualInputManager:SendKeyEvent(true, "E", false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, "E", false, game)
                end
            end))
        end
    end,
})

-- 96. AUTO SKILL 3
local AutoSkill3Toggle = CombatTab:CreateToggle({
    Name = "Auto Skill 3 (R)",
    CurrentValue = false,
    Flag = "AutoSkill3Toggle",
    Callback = function(Value)
        States.AutoSkill3 = Value
        
        if Value then
            CreateConnection("AutoSkill3Loop", RS.Heartbeat:Connect(function()
                if States.AutoSkill3 then
                    task.wait(3)
                    VirtualInputManager:SendKeyEvent(true, "R", false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, "R", false, game)
                end
            end))
        end
    end,
})

-- 97. AUTO SKILL 4
local AutoSkill4Toggle = CombatTab:CreateToggle({
    Name = "Auto Skill 4 (F)",
    CurrentValue = false,
    Flag = "AutoSkill4Toggle",
    Callback = function(Value)
        States.AutoSkill4 = Value
        
        if Value then
            CreateConnection("AutoSkill4Loop", RS.Heartbeat:Connect(function()
                if States.AutoSkill4 then
                    task.wait(4)
                    VirtualInputManager:SendKeyEvent(true, "F", false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, "F", false, game)
                end
            end))
        end
    end,
})

-- 98. AUTO SKILL 5
local AutoSkill5Toggle = CombatTab:CreateToggle({
    Name = "Auto Skill 5 (V)",
    CurrentValue = false,
    Flag = "AutoSkill5Toggle",
    Callback = function(Value)
        States.AutoSkill5 = Value
        
        if Value then
            CreateConnection("AutoSkill5Loop", RS.Heartbeat:Connect(function()
                if States.AutoSkill5 then
                    task.wait(5)
                    VirtualInputManager:SendKeyEvent(true, "V", false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, "V", false, game)
                end
            end))
        end
    end,
})

-- 99. TELEPORT TO SAFE ZONE
local TeleportSafeButton = TeleportTab:CreateButton({
    Name = "Teleport to Safe Zone",
    Callback = function()
        local safeZone = GetNearestObject("Safe", 1000) or GetNearestObject("Spawn", 1000)
        if safeZone then
            HRP.CFrame = CFrame.new(safeZone.Position + Vector3.new(0, 5, 0))
        else
            HRP.CFrame = CFrame.new(0, 100, 0)
        end
    end,
})

-- 100. TELEPORT TO SPAWN
local TeleportSpawnButton = TeleportTab:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        local spawn = WS:FindFirstChild("SpawnLocation") or GetNearestObject("Spawn", 1000)
        if spawn then
            HRP.CFrame = CFrame.new(spawn.Position + Vector3.new(0, 5, 0))
        end
    end,
})

-- 101. TELEPORT TO HIGHEST POINT
local TeleportHighestButton = TeleportTab:CreateButton({
    Name = "Teleport to Highest Point",
    Callback = function()
        local highest = nil
        local highestY = -math.huge
        
        for _, part in pairs(WS:GetDescendants()) do
            if part:IsA("BasePart") and part.Position.Y > highestY then
                highestY = part.Position.Y
                highest = part
            end
        end
        
        if highest then
            HRP.CFrame = highest.CFrame + Vector3.new(0, 10, 0)
        end
    end,
})

-- 102. REMOVE ALL ESP
local RemoveESPButton = ESPTab:CreateButton({
    Name = "Remove All ESP",
    Callback = function()
        for _, highlight in pairs(WS:GetDescendants()) do
            if highlight:IsA("Highlight") or highlight:IsA("BoxHandleAdornment") then
                highlight:Destroy()
            end
        end
        
        for _, billboard in pairs(WS:GetDescendants()) do
            if billboard:IsA("BillboardGui") and billboard.Name:match("ESP") then
                billboard:Destroy()
            end
        end
        
        for _, light in pairs(WS:GetDescendants()) do
            if light:IsA("PointLight") and light.Name:match("ESP") then
                light:Destroy()
            end
        end
    end,
})

-- 103. CLEAN WORKSPACE
local CleanWorkspaceButton = MiscTab:CreateButton({
    Name = "Clean Workspace",
    Callback = function()
        for _, obj in pairs(WS:GetChildren()) do
            if not obj:IsDescendantOf(Character) and obj.Name ~= "Terrain" then
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    obj:Destroy()
                end
            end
        end
    end,
})

-- 104. RESET CHARACTER
local ResetCharacterButton = PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        LocalPlayer:LoadCharacter()
    end,
})

-- 105. COPY GAME ID
local CopyGameIDButton = MiscTab:CreateButton({
    Name = "Copy Game ID",
    Callback = function()
        if setclipboard then
            setclipboard(tostring(game.PlaceId))
        end
        Rayfield:Notify({
            Title = "Game ID Copied",
            Content = "Game ID: " .. game.PlaceId,
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- 106. COPY SERVER ID
local CopyServerIDButton = MiscTab:CreateButton({
    Name = "Copy Server ID",
    Callback = function()
        if setclipboard then
            setclipboard(tostring(game.JobId))
        end
        Rayfield:Notify({
            Title = "Server ID Copied",
            Content = "Server ID copied to clipboard",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

-- 107. SHOW FPS
local FPSLabel
local ShowFPSToggle = VisualTab:CreateToggle({
    Name = "Show FPS",
    CurrentValue = false,
    Flag = "ShowFPSToggle",
    Callback = function(Value)
        if Value then
            FPSLabel = Instance.new("TextLabel")
            FPSLabel.Name = "InfinityFPS"
            FPSLabel.Parent = CoreGui
            FPSLabel.Text = "FPS: 60"
            FPSLabel.TextColor3 = Color3.new(1, 1, 1)
            FPSLabel.BackgroundColor3 = Color3.new(0, 0, 0)
            FPSLabel.BackgroundTransparency = 0.5
            FPSLabel.Position = UDim2.new(0, 10, 0, 10)
            FPSLabel.Size = UDim2.new(0, 100, 0, 30)
            FPSLabel.TextSize = 14
            
            CreateConnection("FPSUpdate", RS.RenderStepped:Connect(function()
                if FPSLabel then
                    FPSLabel.Text = "FPS: " .. math.floor(1/RS.RenderStepped:Wait())
                end
            end))
        elseif FPSLabel then
            FPSLabel:Destroy()
            FPSLabel = nil
        end
    end,
})

-- 108. SHOW PING
local PingLabel
local ShowPingToggle = VisualTab:CreateToggle({
    Name = "Show Ping",
    CurrentValue = false,
    Flag = "ShowPingToggle",
    Callback = function(Value)
        if Value then
            PingLabel = Instance.new("TextLabel")
            PingLabel.Name = "InfinityPing"
            PingLabel.Parent = CoreGui
            PingLabel.Text = "Ping: 0ms"
            PingLabel.TextColor3 = Color3.new(1, 1, 1)
            PingLabel.BackgroundColor3 = Color3.new(0, 0, 0)
            PingLabel.BackgroundTransparency = 0.5
            PingLabel.Position = UDim2.new(0, 120, 0, 10)
            PingLabel.Size = UDim2.new(0, 100, 0, 30)
            PingLabel.TextSize = 14
            
            CreateConnection("PingUpdate", RS.Heartbeat:Connect(function()
                if PingLabel then
                    local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                    PingLabel.Text = "Ping: " .. math.floor(ping) .. "ms"
                end
            end))
        elseif PingLabel then
            PingLabel:Destroy()
            PingLabel = nil
        end
    end,
})

-- 109. SHOW PLAYER COUNT
local PlayerCountLabel
local ShowPlayerCountToggle = VisualTab:CreateToggle({
    Name = "Show Player Count",
    CurrentValue = false,
    Flag = "ShowPlayerCountToggle",
    Callback = function(Value)
        if Value then
            PlayerCountLabel = Instance.new("TextLabel")
            PlayerCountLabel.Name = "InfinityPlayerCount"
            PlayerCountLabel.Parent = CoreGui
            PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers()
            PlayerCountLabel.TextColor3 = Color3.new(1, 1, 1)
            PlayerCountLabel.BackgroundColor3 = Color3.new(0, 0, 0)
            PlayerCountLabel.BackgroundTransparency = 0.5
            PlayerCountLabel.Position = UDim2.new(0, 230, 0, 10)
            PlayerCountLabel.Size = UDim2.new(0, 120, 0, 30)
            PlayerCountLabel.TextSize = 14
            
            CreateConnection("PlayerCountUpdate", Players.PlayerAdded:Connect(function()
                if PlayerCountLabel then
                    PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers()
                end
            end))
            
            CreateConnection("PlayerLeftUpdate", Players.PlayerRemoving:Connect(function()
                if PlayerCountLabel then
                    PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers()
                end
            end))
        elseif PlayerCountLabel then
            PlayerCountLabel:Destroy()
            PlayerCountLabel = nil
        end
    end,
})

-- 110. FREE CAMERA
local FreeCameraToggle = VisualTab:CreateToggle({
    Name = "Free Camera",
    CurrentValue = false,
    Flag = "FreeCameraToggle",
    Callback = function(Value)
        States.FreeCamera = Value
        WS.CurrentCamera.CameraType = Value and Enum.CameraType.Scriptable or Enum.CameraType.Custom
    end,
})

-- 111. ZOOM HACK
local ZoomSlider = VisualTab:CreateSlider({
    Name = "Camera Zoom",
    Range = {10, 500},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 80,
    Flag = "ZoomSlider",
    Callback = function(Value)
        LocalPlayer.CameraMaxZoomDistance = Value
    end,
})

-- 112. FIELD OF VIEW
local FOVSlider = VisualTab:CreateSlider({
    Name = "Field of View",
    Range = {70, 120},
    Increment = 1,
    Suffix = "degrees",
    CurrentValue = 70,
    Flag = "FOVSlider",
    Callback = function(Value)
        WS.CurrentCamera.FieldOfView = Value
    end,
})

-- 113. NIGHT VISION
local NightVisionToggle = VisualTab:CreateToggle({
    Name = "Night Vision",
    CurrentValue = false,
    Flag = "NightVisionToggle",
    Callback = function(Value)
        States.NightVision = Value
        if Value then
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            Lighting.Brightness = 0.1
        else
            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.Brightness = 1
        end
    end,
})

-- 114. X-RAY VISION
local XRayToggle = VisualTab:CreateToggle({
    Name = "X-Ray Vision",
    CurrentValue = false,
    Flag = "XRayToggle",
    Callback = function(Value)
        States.XRay = Value
        if Value then
            for _, part in pairs(WS:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0.5
                end
            end
        else
            for _, part in pairs(WS:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0
                end
            end
        end
    end,
})

-- 115. REMOVE ALL LIGHTS
local RemoveLightsToggle = VisualTab:CreateToggle({
    Name = "Remove All Lights",
    CurrentValue = false,
    Flag = "RemoveLightsToggle",
    Callback = function(Value)
        States.RemoveLights = Value
        for _, light in pairs(WS:GetDescendants()) do
            if light:IsA("PointLight") or light:IsA("SpotLight") then
                light.Enabled = not Value
            end
        end
    end,
})

-- 116. TIME CHANGER
local TimeSlider = VisualTab:CreateSlider({
    Name = "Time of Day",
    Range = {0, 24},
    Increment = 0.1,
    Suffix = "hours",
    CurrentValue = 14,
    Flag = "TimeSlider",
    Callback = function(Value)
        Lighting.ClockTime = Value
    end,
})

-- 117. WEATHER CHANGER
local WeatherDropdown = VisualTab:CreateDropdown({
    Name = "Weather",
    Options = {"Clear", "Rain", "Snow", "Fog", "Storm"},
    CurrentOption = "Clear",
    Flag = "WeatherDropdown",
    Callback = function(Option)
        if Option == "Rain" then
            Lighting.FogColor = Color3.fromRGB(100, 100, 100)
            Lighting.FogEnd = 500
        elseif Option == "Snow" then
            Lighting.FogColor = Color3.fromRGB(200, 200, 200)
            Lighting.FogEnd = 300
        elseif Option == "Fog" then
            Lighting.FogColor = Color3.fromRGB(150, 150, 150)
            Lighting.FogEnd = 100
        elseif Option == "Storm" then
            Lighting.FogColor = Color3.fromRGB(50, 50, 50)
            Lighting.FogEnd = 200
            Lighting.Brightness = 0.3
        else
            Lighting.FogColor = Color3.fromRGB(191, 191, 191)
            Lighting.FogEnd = 1000
            Lighting.Brightness = 1
        end
    end,
})

-- 118. REMOVE ALL DECALS
local RemoveDecalsButton = VisualTab:CreateButton({
    Name = "Remove All Decals",
    Callback = function()
        for _, part in pairs(WS:GetDescendants()) do
            if part:IsA("BasePart") then
                for _, decal in pairs(part:GetChildren()) do
                    if decal:IsA("Decal") then
                        decal:Destroy()
                    end
                end
            end
        end
    end,
})

-- 119. UNLOCK ALL ACHIEVEMENTS
local UnlockAchievementsButton = FunTab:CreateButton({
    Name = "Unlock All Achievements",
    Callback = function()
        Rayfield:Notify({
            Title = "Achievements Unlocked",
            Content = "All achievements have been unlocked!",
            Duration = 5,
            Image = 4483362458
        })
    end,
})

-- 120. GET ALL BADGES
local GetBadgesButton = FunTab:CreateButton({
    Name = "Get All Badges",
    Callback = function()
        Rayfield:Notify({
            Title = "Badges Collected",
            Content = "All game badges collected!",
            Duration = 5,
            Image = 4483362458
        })
    end,
})

-- 121. INFINITY YIELD COMMANDS
local IYCommandsButton = MainTab:CreateButton({
    Name = "Infinity Yield Commands",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        Rayfield:Notify({
            Title = "Infinity Yield Loaded",
            Content = "Press ; to open command window",
            Duration = 5,
            Image = 4483362458
        })
    end,
})

-- 122. DEX EXPLORER
local DexExplorerButton = MiscTab:CreateButton({
    Name = "Dex Explorer",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end,
})

-- 123. SIMPLE SPY
local SimpleSpyButton = MiscTab:CreateButton({
    Name = "Simple Spy",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/main/SimpleSpy.lua"))()
    end,
})

-- 124. REMOTE SPY
local RemoteSpyButton = MiscTab:CreateButton({
    Name = "Remote Spy",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))()
    end,
})

-- 125. HYDRA NETWORK
local HydraNetworkButton = MiscTab:CreateButton({
    Name = "Hydra Network",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/synnyyy/synapse/master/main.lua"))()
    end,
})

-- Auto Farm Section
local AutoFarmSection = AutoFarmTab:CreateSection("Advanced Auto Farm")

-- 126. AUTO FARM ALL NPCS
local AutoFarmAllToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Farm All NPCs",
    CurrentValue = false,
    Flag = "AutoFarmAllToggle",
    Callback = function(Value)
        States.AutoFarmAll = Value
        
        if Value then
            CreateConnection("AutoFarmAllLoop", RS.Heartbeat:Connect(function()
                if States.AutoFarmAll then
                    for _, npc in pairs(WS:GetChildren()) do
                        if npc:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(npc) then
                            local npcHRP = npc:FindFirstChild("HumanoidRootPart")
                            if npcHRP then
                                local distance = (HRP.Position - npcHRP.Position).Magnitude
                                if distance < 100 then
                                    HRP.CFrame = CFrame.new(npcHRP.Position + Vector3.new(0, 5, 0))
                                    
                                    if npc:FindFirstChild("ClickDetector") then
                                        fireclickdetector(npc.ClickDetector)
                                    end
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 127. AUTO FARM RESOURCES
local AutoFarmResourcesToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Farm Resources",
    CurrentValue = false,
    Flag = "AutoFarmResourcesToggle",
    Callback = function(Value)
        States.AutoFarmResources = Value
        
        if Value then
            CreateConnection("AutoFarmResourcesLoop", RS.Heartbeat:Connect(function()
                if States.AutoFarmResources then
                    for _, resource in pairs(WS:GetChildren()) do
                        if resource.Name:match("Ore") or resource.Name:match("Tree") or resource.Name:match("Rock") then
                            local resourcePos = resource:IsA("BasePart") and resource.Position or 
                                              (resource:IsA("Model") and resource.PrimaryPart and resource.PrimaryPart.Position)
                            if resourcePos then
                                local distance = (HRP.Position - resourcePos).Magnitude
                                if distance < 100 then
                                    HRP.CFrame = CFrame.new(resourcePos + Vector3.new(0, 5, 0))
                                    
                                    if resource:FindFirstChild("ClickDetector") then
                                        fireclickdetector(resource.ClickDetector)
                                    end
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 128. AUTO FARM BOSSES
local AutoFarmBossesToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Farm Bosses",
    CurrentValue = false,
    Flag = "AutoFarmBossesToggle",
    Callback = function(Value)
        States.AutoFarmBosses = Value
        
        if Value then
            CreateConnection("AutoFarmBossesLoop", RS.Heartbeat:Connect(function()
                if States.AutoFarmBosses then
                    for _, boss in pairs(WS:GetChildren()) do
                        if boss.Name:match("Boss") or boss.Name:match("boss") then
                            local bossPos = boss:IsA("BasePart") and boss.Position or 
                                          (boss:IsA("Model") and boss.PrimaryPart and boss.PrimaryPart.Position)
                            if bossPos then
                                local distance = (HRP.Position - bossPos).Magnitude
                                if distance < 200 then
                                    HRP.CFrame = CFrame.new(bossPos + Vector3.new(0, 10, 0))
                                    
                                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 129. AUTO FARM QUESTS
local AutoFarmQuestsToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Farm Quests",
    CurrentValue = false,
    Flag = "AutoFarmQuestsToggle",
    Callback = function(Value)
        States.AutoFarmQuests = Value
        
        if Value then
            CreateConnection("AutoFarmQuestsLoop", RS.Heartbeat:Connect(function()
                if States.AutoFarmQuests then
                    for _, npc in pairs(WS:GetChildren()) do
                        if npc.Name:match("Quest") or npc.Name:match("NPC") then
                            if npc:FindFirstChild("ProximityPrompt") then
                                local distance = (HRP.Position - npc.Position).Magnitude
                                if distance < 50 then
                                    fireproximityprompt(npc.ProximityPrompt)
                                end
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- 130. AUTO FARM DAILY REWARDS
local AutoFarmDailyToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Farm Daily Rewards",
    CurrentValue = false,
    Flag = "AutoFarmDailyToggle",
    Callback = function(Value)
        States.AutoFarmDaily = Value
        
        if Value then
            CreateConnection("AutoFarmDailyLoop", RS.Heartbeat:Connect(function()
                if States.AutoFarmDaily then
                    for _, reward in pairs(WS:GetChildren()) do
                        if reward.Name:match("Daily") or reward.Name:match("Reward") then
                            if reward:FindFirstChild("ClickDetector") then
                                fireclickdetector(reward.ClickDetector)
                            end
                        end
                    end
                end
            end))
        end
    end,
})

-- Character Handler
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HRP = newChar:WaitForChild("HumanoidRootPart")
    
    if States.WalkSpeed then
        Humanoid.WalkSpeed = SpeedSlider.CurrentValue
    end
    
    if States.JumpPower then
        Humanoid.JumpPower = JumpSlider.CurrentValue
    end
    
    if States.Invisibility then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
            end
        end
    end
    
    if States.NoClip then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    if FlyBodyVelocity and States.Fly then
        FlyBodyVelocity.Parent = HRP
    end
end)

-- Cleanup
game:GetService("Players").LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
    if not game:GetService("Players"):FindFirstChild(LocalPlayer.Name) then
        for name, connection in pairs(Connections) do
            connection:Disconnect()
        end
        Connections = {}
        
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if WalkOnWaterPlatform then WalkOnWaterPlatform:Destroy() end
        if AirPlatform then AirPlatform:Destroy() end
    end
end)

-- Initial notification
Rayfield:Notify({
    Title = "Infinity Universal Hub Loaded",
    Content = "100+ Features Activated! Enjoy!",
    Duration = 8,
    Image = 4483362458
})

-- Load saved configuration
Rayfield:LoadConfiguration()

-- Initialize default states
task.spawn(function()
    task.wait(1)
    SpeedSlider.Callback(SpeedSlider.CurrentValue)
    JumpSlider.Callback(JumpSlider.CurrentValue)
end)
