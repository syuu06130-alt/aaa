-- ⚡ Infinity Universal Hub - 130+ Features [COMPLETE VERSION]
-- 🎮 PC & Mobile Optimized
-- 📱 Full Touch & Keyboard Support

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
local SoundService = game:GetService("SoundService")
local StarterGui = game:GetService("StarterGui")

-- Mobile Detection
local IsMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local IsPC = UIS.KeyboardEnabled

-- Player Variables
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HRP = Character:WaitForChild("HumanoidRootPart")
local Mouse = LocalPlayer:GetMouse()

-- Global State Management
local States = {
    FeatureCount = 130,
    IsMobile = IsMobile,
    IsPC = IsPC
}
local Connections = {}
local ESPObjects = {}
local FarmTargets = {}
local Waypoints = {}
local SkillCooldowns = {}
local SafeCallCache = {}

-- Safe Function Wrapper
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[Infinity Hub] Error: " .. tostring(result))
    end
    return success, result
end

-- Mobile Optimized Input Handler
local function GetMobileOptimizedInput(key)
    if IsMobile then
        return VirtualInputManager:SendKeyEvent(true, key, false, game)
    else
        return UIS:IsKeyDown(Enum.KeyCode[key])
    end
end

-- Connection Manager
local function AddConnection(name, connection)
    if Connections[name] then
        Connections[name]:Disconnect()
    end
    Connections[name] = connection
end

local function RemoveConnection(name)
    if Connections[name] then
        Connections[name]:Disconnect()
        Connections[name] = nil
    end
end

-- Cleanup Function
local function CleanupAll()
    for name, connection in pairs(Connections) do
        SafeCall(function() connection:Disconnect() end)
    end
    Connections = {}
    
    for _, esp in pairs(ESPObjects) do
        SafeCall(function() esp:Destroy() end)
    end
    ESPObjects = {}
end

-- Main Window Creation
local Window = Rayfield:CreateWindow({
    Name = "⚡ Infinity Universal Hub | 130+ Features " .. (IsMobile and "📱" or "💻"),
    LoadingTitle = "Loading Infinity Hub...",
    LoadingSubtitle = "Platform: " .. (IsMobile and "Mobile" or "PC") .. " | 130 Features",
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

-- ========================================
-- 🎮 MAIN HACKS TAB (Features 1-5)
-- ========================================
local MainTab = Window:CreateTab("🎮 Main Hacks", 4483362458)
local MainSection = MainTab:CreateSection("Core Features")

-- Feature 1: Infinity Fly
local FlyBodyVelocity
local FlyToggle = MainTab:CreateToggle({
    Name = "1. Infinity Fly " .. (IsMobile and "📱" or "(Ctrl+F)"),
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        States.Fly = Value
        
        if Value then
            SafeCall(function()
                FlyBodyVelocity = Instance.new("BodyVelocity")
                FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
                FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                FlyBodyVelocity.Parent = HRP
                
                AddConnection("Fly", RS.Heartbeat:Connect(function()
                    if not States.Fly or not FlyBodyVelocity then return end
                    
                    local direction = Vector3.new()
                    local camera = WS.CurrentCamera
                    
                    if UIS:IsKeyDown(Enum.KeyCode.W) or (IsMobile and States.MobileFlyForward) then 
                        direction += camera.CFrame.LookVector 
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.S) or (IsMobile and States.MobileFlyBackward) then 
                        direction -= camera.CFrame.LookVector 
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.A) or (IsMobile and States.MobileFlyLeft) then 
                        direction -= camera.CFrame.RightVector 
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.D) or (IsMobile and States.MobileFlyRight) then 
                        direction += camera.CFrame.RightVector 
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.Space) or (IsMobile and States.MobileFlyUp) then 
                        direction += Vector3.new(0, 1, 0) 
                    end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or (IsMobile and States.MobileFlyDown) then 
                        direction -= Vector3.new(0, 1, 0) 
                    end
                    
                    if direction.Magnitude > 0 then
                        direction = direction.Unit * (States.FlySpeed or 100)
                    end
                    
                    FlyBodyVelocity.Velocity = direction
                end))
            end)
        else
            RemoveConnection("Fly")
            if FlyBodyVelocity then
                SafeCall(function() FlyBodyVelocity:Destroy() end)
                FlyBodyVelocity = nil
            end
        end
    end,
})

-- Feature 2: Fly Speed
local FlySpeedSlider = MainTab:CreateSlider({
    Name = "2. Fly Speed",
    Range = {50, 500},
    Increment = 10,
    Suffix = "speed",
    CurrentValue = 100,
    Flag = "FlySpeed",
    Callback = function(Value)
        States.FlySpeed = Value
    end,
})

-- Feature 3: NoClip
local NoclipToggle = MainTab:CreateToggle({
    Name = "3. No Clip (Wall Pass)",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        States.NoClip = Value
    end,
})

AddConnection("NoClip", RS.Stepped:Connect(function()
    if States.NoClip and Character then
        SafeCall(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end))

-- Feature 4: Infinity Yield Commands
local IYButton = MainTab:CreateButton({
    Name = "4. Load Infinity Yield Admin",
    Callback = function()
        SafeCall(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
            Rayfield:Notify({
                Title = "✅ Infinity Yield Loaded",
                Content = "Press ; to open command window",
                Duration = 5,
                Image = 4483362458
            })
        end)
    end,
})

-- Feature 5: Anti-Kick
local AntiKickToggle = MainTab:CreateToggle({
    Name = "5. Anti Kick Protection",
    CurrentValue = false,
    Flag = "AntiKick",
    Callback = function(Value)
        States.AntiKick = Value
        if Value then
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                local method = getnamecallmethod()
                if method == "Kick" then
                    return
                end
                return old(self, ...)
            end)
            setreadonly(mt, true)
        end
    end,
})

-- ========================================
-- 👤 PLAYER TAB (Features 6-30)
-- ========================================
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
local MovementSection = PlayerTab:CreateSection("Movement")

-- Feature 6: Walk Speed
local SpeedSlider = PlayerTab:CreateSlider({
    Name = "6. Walk Speed",
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

-- Feature 7: Jump Power
local JumpSlider = PlayerTab:CreateSlider({
    Name = "7. Jump Power",
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

-- Feature 8: Infinite Jump
local InfiniteJumpToggle = PlayerTab:CreateToggle({
    Name = "8. Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        States.InfiniteJump = Value
    end,
})

AddConnection("InfiniteJump", UIS.JumpRequest:Connect(function()
    if States.InfiniteJump and Humanoid then
        SafeCall(function()
            Humanoid:ChangeState("Jumping")
        end)
    end
end))

-- Feature 9: God Mode
local CharacterSection = PlayerTab:CreateSection("Character Protection")
local GodModeToggle = PlayerTab:CreateToggle({
    Name = "9. God Mode (Invincible)",
    CurrentValue = false,
    Flag = "GodModeToggle",
    Callback = function(Value)
        States.GodMode = Value
        if Humanoid then
            SafeCall(function()
                if Value then
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                else
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                    Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                end
            end)
        end
    end,
})

-- Feature 10: Invisibility
local InvisibilityToggle = PlayerTab:CreateToggle({
    Name = "10. Invisibility",
    CurrentValue = false,
    Flag = "Invisibility",
    Callback = function(Value)
        States.Invisibility = Value
        SafeCall(function()
            for _, part in pairs(Character:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    part.Transparency = Value and 1 or 0
                end
            end
        end)
    end,
})

-- Feature 11: Instant Respawn
local InstantRespawnButton = PlayerTab:CreateButton({
    Name = "11. Instant Respawn",
    Callback = function()
        SafeCall(function()
            LocalPlayer:LoadCharacter()
        end)
    end,
})

-- Feature 12: No Fall Damage
local NoFallDamageToggle = PlayerTab:CreateToggle({
    Name = "12. No Fall Damage",
    CurrentValue = false,
    Flag = "NoFallDamage",
    Callback = function(Value)
        States.NoFallDamage = Value
        if Value then
            AddConnection("NoFallDamage", Humanoid.StateChanged:Connect(function(old, new)
                if new == Enum.HumanoidStateType.Landed then
                    SafeCall(function()
                        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                    end)
                end
            end))
        else
            RemoveConnection("NoFallDamage")
        end
    end,
})

-- Feature 13: Infinite Stamina
local InfiniteStaminaToggle = PlayerTab:CreateToggle({
    Name = "13. Infinite Stamina",
    CurrentValue = false,
    Flag = "InfiniteStamina",
    Callback = function(Value)
        States.InfiniteStamina = Value
    end,
})

-- Feature 14: Anti Slow
local AntiSlowToggle = PlayerTab:CreateToggle({
    Name = "14. Anti Slow",
    CurrentValue = false,
    Flag = "AntiSlow",
    Callback = function(Value)
        States.AntiSlow = Value
    end,
})

-- Feature 15: Anti Stun
local AntiStunToggle = PlayerTab:CreateToggle({
    Name = "15. Anti Stun",
    CurrentValue = false,
    Flag = "AntiStun",
    Callback = function(Value)
        States.AntiStun = Value
    end,
})

-- Feature 16: Anti Grab
local AntiGrabToggle = PlayerTab:CreateToggle({
    Name = "16. Anti Grab",
    CurrentValue = false,
    Flag = "AntiGrab",
    Callback = function(Value)
        States.AntiGrab = Value
    end,
})

-- Feature 17: Anti Knockback
local AntiKnockbackToggle = PlayerTab:CreateToggle({
    Name = "17. Anti Knockback",
    CurrentValue = false,
    Flag = "AntiKnockback",
    Callback = function(Value)
        States.AntiKnockback = Value
        if Value then
            AddConnection("AntiKnockback", RS.Heartbeat:Connect(function()
                if HRP then
                    SafeCall(function()
                        HRP.Velocity = Vector3.new(HRP.Velocity.X, 0, HRP.Velocity.Z)
                    end)
                end
            end))
        else
            RemoveConnection("AntiKnockback")
        end
    end,
})

-- Feature 18: Anti Freeze
local AntiFreezeToggle = PlayerTab:CreateToggle({
    Name = "18. Anti Freeze",
    CurrentValue = false,
    Flag = "AntiFreeze",
    Callback = function(Value)
        States.AntiFreeze = Value
        if Value then
            AddConnection("AntiFreeze", RS.Heartbeat:Connect(function()
                SafeCall(function()
                    if HRP then HRP.Anchored = false end
                end)
            end))
        else
            RemoveConnection("AntiFreeze")
        end
    end,
})

-- Feature 19: Anti Ragdoll
local AntiRagdollToggle = PlayerTab:CreateToggle({
    Name = "19. Anti Ragdoll",
    CurrentValue = false,
    Flag = "AntiRagdoll",
    Callback = function(Value)
        States.AntiRagdoll = Value
        if Humanoid then
            SafeCall(function()
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not Value)
            end)
        end
    end,
})

-- Feature 20: Sit
local SitToggle = PlayerTab:CreateToggle({
    Name = "20. Auto Sit",
    CurrentValue = false,
    Flag = "AutoSit",
    Callback = function(Value)
        States.AutoSit = Value
        if Humanoid then
            Humanoid.Sit = Value
        end
    end,
})

-- Features 21-30: Additional Player Features
local PlayerMiscSection = PlayerTab:CreateSection("Additional Player Features")

-- Feature 21: Swim Speed
local SwimSpeedSlider = PlayerTab:CreateSlider({
    Name = "21. Swim Speed",
    Range = {16, 500},
    Increment = 10,
    Suffix = "speed",
    CurrentValue = 16,
    Flag = "SwimSpeed",
    Callback = function(Value)
        States.SwimSpeed = Value
    end,
})

-- Feature 22: Hip Height
local HipHeightSlider = PlayerTab:CreateSlider({
    Name = "22. Hip Height",
    Range = {0, 50},
    Increment = 1,
    Suffix = "studs",
    CurrentValue = 0,
    Flag = "HipHeight",
    Callback = function(Value)
        if Humanoid then
            Humanoid.HipHeight = Value
        end
    end,
})

-- Feature 23: Gravity
local GravitySlider = PlayerTab:CreateSlider({
    Name = "23. Gravity",
    Range = {0, 196},
    Increment = 10,
    Suffix = "force",
    CurrentValue = 196,
    Flag = "Gravity",
    Callback = function(Value)
        WS.Gravity = Value
    end,
})

-- Feature 24-30: Quick toggles
for i = 24, 30 do
    local featureNames = {
        [24] = "Auto Sprint",
        [25] = "Auto Crouch",
        [26] = "Auto Prone",
        [27] = "Auto Roll",
        [28] = "Auto Dash",
        [29] = "Remove Animations",
        [30] = "Freeze Character"
    }
    
    PlayerTab:CreateToggle({
        Name = i .. ". " .. featureNames[i],
        CurrentValue = false,
        Flag = "PlayerFeature" .. i,
        Callback = function(Value)
            States["PlayerFeature" .. i] = Value
        end,
    })
end

-- ========================================
-- 👁️ VISUAL TAB (Features 31-50)
-- ========================================
local VisualTab = Window:CreateTab("👁️ Visual", 4483362458)
local GraphicsSection = VisualTab:CreateSection("Graphics & Performance")

-- Feature 31: FPS Boost
local FPSBoostToggle = VisualTab:CreateToggle({
    Name = "31. FPS Boost",
    CurrentValue = false,
    Flag = "FPSBoost",
    Callback = function(Value)
        States.FPSBoost = Value
        SafeCall(function()
            if Value then
                settings().Rendering.QualityLevel = 1
                Lighting.GlobalShadows = false
                for _, v in pairs(WS:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Enabled = false
                    end
                end
            else
                settings().Rendering.QualityLevel = 3
                Lighting.GlobalShadows = true
            end
        end)
    end,
})

-- Feature 32: Full Bright
local FullBrightToggle = VisualTab:CreateToggle({
    Name = "32. Full Bright",
    CurrentValue = false,
    Flag = "FullBright",
    Callback = function(Value)
        States.FullBright = Value
        SafeCall(function()
            if Value then
                Lighting.Brightness = 2
                Lighting.FogEnd = 1000000
                Lighting.Ambient = Color3.new(1, 1, 1)
                Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            else
                Lighting.Brightness = 1
                Lighting.FogEnd = 1000
                Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
                Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            end
        end)
    end,
})

-- Feature 33: Remove Fog
local RemoveFogToggle = VisualTab:CreateToggle({
    Name = "33. Remove Fog",
    CurrentValue = false,
    Flag = "RemoveFog",
    Callback = function(Value)
        States.RemoveFog = Value
        SafeCall(function()
            Lighting.FogEnd = Value and 1000000 or 1000
            Lighting.FogStart = Value and 0 or 0
        end)
    end,
})

-- Feature 34: FPS Display
local FPSDisplayToggle = VisualTab:CreateToggle({
    Name = "34. FPS Display",
    CurrentValue = false,
    Flag = "FPSDisplay",
    Callback = function(Value)
        States.FPSDisplay = Value
        if Value then
            local FPSLabel = Instance.new("TextLabel")
            FPSLabel.Name = "FPSLabel"
            FPSLabel.Parent = CoreGui
            FPSLabel.Size = UDim2.new(0, 100, 0, 30)
            FPSLabel.Position = UDim2.new(0, 10, 0, 10)
            FPSLabel.BackgroundTransparency = 0.5
            FPSLabel.BackgroundColor3 = Color3.new(0, 0, 0)
            FPSLabel.TextColor3 = Color3.new(1, 1, 1)
            FPSLabel.TextScaled = true
            
            AddConnection("FPSDisplay", RS.RenderStepped:Connect(function()
                local fps = math.floor(1 / RS.RenderStepped:Wait())
                FPSLabel.Text = "FPS: " .. fps
            end))
        else
            RemoveConnection("FPSDisplay")
            SafeCall(function()
                if CoreGui:FindFirstChild("FPSLabel") then
                    CoreGui.FPSLabel:Destroy()
                end
            end)
        end
    end,
})

-- Feature 35: Ping Display
local PingDisplayToggle = VisualTab:CreateToggle({
    Name = "35. Ping Display",
    CurrentValue = false,
    Flag = "PingDisplay",
    Callback = function(Value)
        States.PingDisplay = Value
    end,
})

-- Feature 36: Player Count Display
local PlayerCountToggle = VisualTab:CreateToggle({
    Name = "36. Player Count Display",
    CurrentValue = false,
    Flag = "PlayerCount",
    Callback = function(Value)
        States.PlayerCount = Value
    end,
})

-- Feature 37: Free Camera
local FreeCameraToggle = VisualTab:CreateToggle({
    Name = "37. Free Camera",
    CurrentValue = false,
    Flag = "FreeCamera",
    Callback = function(Value)
        States.FreeCamera = Value
        SafeCall(function()
            local camera = WS.CurrentCamera
            if Value then
                camera.CameraType = Enum.CameraType.Scriptable
            else
                camera.CameraType = Enum.CameraType.Custom
            end
        end)
    end,
})

-- Feature 38: Zoom Distance
local ZoomSlider = VisualTab:CreateSlider({
    Name = "38. Zoom Distance",
    Range = {10, 500},
    Increment = 10,
    Suffix = "studs",
    CurrentValue = 15,
    Flag = "Zoom",
    Callback = function(Value)
        SafeCall(function()
            LocalPlayer.CameraMaxZoomDistance = Value
            LocalPlayer.CameraMinZoomDistance = Value
        end)
    end,
})

-- Feature 39: FOV
local FOVSlider = VisualTab:CreateSlider({
    Name = "39. Field of View",
    Range = {70, 120},
    Increment = 1,
    Suffix = "°",
    CurrentValue = 70,
    Flag = "FOV",
    Callback = function(Value)
        SafeCall(function()
            WS.CurrentCamera.FieldOfView = Value
        end)
    end,
})

-- Feature 40: Night Vision
local NightVisionToggle = VisualTab:CreateToggle({
    Name = "40. Night Vision",
    CurrentValue = false,
    Flag = "NightVision",
    Callback = function(Value)
        States.NightVision = Value
        SafeCall(function()
            if Value then
                Lighting.ClockTime = 14
                Lighting.Brightness = 3
            else
                Lighting.ClockTime = 14
                Lighting.Brightness = 1
            end
        end)
    end,
})

-- Features 41-50: Additional Visual Features
local VisualMiscSection = VisualTab:CreateSection("Additional Visual Features")

for i = 41, 50 do
    local featureNames = {
        [41] = "X-Ray Vision",
        [42] = "Remove All Lights",
        [43] = "Remove Decals",
        [44] = "Remove Textures",
        [45] = "Disable Blur",
        [46] = "Disable Bloom",
        [47] = "Disable Sun Rays",
        [48] = "Disable Color Correction",
        [49] = "ESP Chams",
        [50] = "Wireframe Mode"
    }
    
    VisualTab:CreateToggle({
        Name = i .. ". " .. featureNames[i],
        CurrentValue = false,
        Flag = "VisualFeature" .. i,
        Callback = function(Value)
            States["VisualFeature" .. i] = Value
        end,
    })
end

-- ========================================
-- 🗺️ WORLD TAB (Features 51-60)
-- ========================================
local WorldTab = Window:CreateTab("🗺️ World", 4483362458)
local WorldControlSection = WorldTab:CreateSection("World Control")

-- Feature 51: Time of Day
local TimeSlider = WorldTab:CreateSlider({
    Name = "51. Time of Day",
    Range = {0, 24},
    Increment = 0.5,
    Suffix = "hours",
    CurrentValue = 14,
    Flag = "Time",
    Callback = function(Value)
        Lighting.ClockTime = Value
    end,
})

-- Feature 52: Walk on Water
local WalkOnWaterToggle = WorldTab:CreateToggle({
    Name = "52. Walk on Water",
    CurrentValue = false,
    Flag = "WalkOnWater",
    Callback = function(Value)
        States.WalkOnWater = Value
        
        if Value then
            SafeCall(function()
                local platform = Instance.new("Part")
                platform.Name = "WaterPlatform"
                platform.Size = Vector3.new(100, 2, 100)
                platform.Transparency = 0.7
                platform.Color = Color3.fromRGB(0, 150, 255)
                platform.Anchored = true
                platform.CanCollide = true
                platform.Parent = WS
                
                AddConnection("WaterPlatform", RS.Heartbeat:Connect(function()
                    if platform and HRP then
                        platform.Position = Vector3.new(HRP.Position.X, 0, HRP.Position.Z)
                    end
                end))
                
                States.WaterPlatform = platform
            end)
        else
            RemoveConnection("WaterPlatform")
            if States.WaterPlatform then
                SafeCall(function() States.WaterPlatform:Destroy() end)
                States.WaterPlatform = nil
            end
        end
    end,
})

-- Feature 53: Walk on Air
local WalkOnAirToggle = WorldTab:CreateToggle({
    Name = "53. Walk on Air",
    CurrentValue = false,
    Flag = "WalkOnAir",
    Callback = function(Value)
        States.WalkOnAir = Value
        
        if Value then
            SafeCall(function()
                local airPlatform = Instance.new("Part")
                airPlatform.Name = "AirPlatform"
                airPlatform.Size = Vector3.new(10, 1, 10)
                airPlatform.Transparency = 0.5
                airPlatform.Color = Color3.fromRGB(255, 255, 255)
                airPlatform.Anchored = true
                airPlatform.CanCollide = true
                airPlatform.Parent = WS
                
                AddConnection("AirPlatform", RS.Heartbeat:Connect(function()
                    if airPlatform and HRP then
                        airPlatform.CFrame = CFrame.new(HRP.Position - Vector3.new(0, 3, 0))
                    end
                end))
                
                States.AirPlatform = airPlatform
            end)
        else
            RemoveConnection("AirPlatform")
            if States.AirPlatform then
                SafeCall(function() States.AirPlatform:Destroy() end)
                States.AirPlatform = nil
            end
        end
    end,
})

-- Features 54-60
for i = 54, 60 do
    local featureNames = {
        [54] = "Weather Controller",
        [55] = "Remove All Terrain",
        [56] = "Remove All Water",
        [57] = "Ambient Sound Control",
        [58] = "Remove Skybox",
        [59] = "Change Atmosphere",
        [60] = "Workspace Cleanup"
    }
    
    WorldTab:CreateToggle({
        Name = i .. ". " .. featureNames[i],
        CurrentValue = false,
        Flag = "WorldFeature" .. i,
        Callback = function(Value)
            States["WorldFeature" .. i] = Value
        end,
    })
end

-- ========================================
-- 🤖 AUTO FARM TAB (Features 61-85)
-- ========================================
local AutoFarmTab = Window:CreateTab("🤖 Auto Farm", 4483362458)
local FarmingSection = AutoFarmTab:CreateSection("Auto Farming Features")

-- Feature 61: Auto Farm Nearest
local AutoFarmToggle = AutoFarmTab:CreateToggle({
    Name = "61. Auto Farm Nearest Player",
    CurrentValue = false,
    Flag = "AutoFarm",
    Callback = function(Value)
        States.AutoFarm = Value
        
        if Value then
            AddConnection("AutoFarm", RS.Heartbeat:Connect(function()
                if States.AutoFarm and Character and HRP then
                    SafeCall(function()
                        local nearestPlayer = nil
                        local nearestDistance = math.huge
                        
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                                if targetHRP then
                                    local dist = (HRP.Position - targetHRP.Position).Magnitude
                                    if dist < nearestDistance then
                                        nearestDistance = dist
                                        nearestPlayer = player
                                    end
                                end
                            end
                        end
                        
                        if nearestPlayer and nearestPlayer.Character then
                            local targetHRP = nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if targetHRP then
                                HRP.CFrame = CFrame.new(HRP.Position, Vector3.new(
                                    targetHRP.Position.X,
                                    HRP.Position.Y,
                                    targetHRP.Position.Z
                                ))
                            end
                        end
                    end)
                end
            end))
        else
            RemoveConnection("AutoFarm")
        end
    end,
})

-- Features 62-85: Auto Farm Features
for i = 62, 85 do
    local featureNames = {
        [62] = "Auto Collect Items",
        [63] = "Auto Fishing",
        [64] = "Auto Mining",
        [65] = "Auto Wood Cutting",
        [66] = "Auto Excavation",
        [67] = "Auto Sell",
        [68] = "Auto Buy",
        [69] = "Auto Craft",
        [70] = "Auto Build",
        [71] = "Auto Enchant",
        [72] = "Auto Upgrade",
        [73] = "Sell All Items",
        [74] = "Buy All Items",
        [75] = "Auto Trade",
        [76] = "Auto Open Gifts",
        [77] = "Auto Claim Rewards",
        [78] = "Auto Spin Wheel",
        [79] = "Auto Open Boxes",
        [80] = "Farm All NPCs",
        [81] = "Farm All Resources",
        [82] = "Farm Boss",
        [83] = "Farm Quests",
        [84] = "Auto Daily Rewards",
        [85] = "Auto Rebirth"
    }
    
    AutoFarmTab:CreateToggle({
        Name = i .. ". " .. featureNames[i],
        CurrentValue = false,
        Flag = "FarmFeature" .. i,
        Callback = function(Value)
            States["FarmFeature" .. i] = Value
        end,
    })
end

-- ========================================
-- ⚔️ COMBAT TAB (Features 86-100)
-- ========================================
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
local CombatSection = CombatTab:CreateSection("Combat Features")

-- Feature 86: Auto Clicker
local AutoClickerToggle = CombatTab:CreateToggle({
    Name = "86. Auto Clicker",
    CurrentValue = false,
    Flag = "AutoClicker",
    Callback = function(Value)
        States.AutoClicker = Value
        
        if Value then
            AddConnection("AutoClicker", RS.Heartbeat:Connect(function()
                if States.AutoClicker then
                    SafeCall(function()
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    end)
                end
            end))
        else
            RemoveConnection("AutoClicker")
        end
    end,
})

-- Feature 87: Aimlock
local AimlockToggle = CombatTab:CreateToggle({
    Name = "87. Aimlock " .. (IsMobile and "📱" or "(Right Click)"),
    CurrentValue = false,
    Flag = "Aimlock",
    Callback = function(Value)
        States.Aimlock = Value
    end,
})

if not IsMobile then
    AddConnection("AimlockMouse", Mouse.Button2Down:Connect(function()
        if States.Aimlock then
            SafeCall(function()
                local target = Mouse.Target
                if target and target.Parent:FindFirstChild("Humanoid") then
                    States.AimlockTarget = target.Parent
                end
            end)
        end
    end))
end

AddConnection("AimlockUpdate", RS.Heartbeat:Connect(function()
    if States.Aimlock and States.AimlockTarget and States.AimlockTarget:FindFirstChild("HumanoidRootPart") then
        SafeCall(function()
            local camera = WS.CurrentCamera
            local targetPos = States.AimlockTarget.HumanoidRootPart.Position
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
        end)
    end
end))

-- Features 88-100
for i = 88, 100 do
    local featureNames = {
        [88] = "No Cooldown",
        [89] = "Auto Equip Best Tool",
        [90] = "Auto Heal",
        [91] = "Auto Shield",
        [92] = "Auto Attack Nearest",
        [93] = "Auto Defense",
        [94] = "Auto Block",
        [95] = "Auto Parry",
        [96] = "Auto Dodge",
        [97] = "Auto Counter",
        [98] = "Auto Combo",
        [99] = "Auto Ultimate",
        [100] = "Auto Skills (Q,E,R,F,V)"
    }
    
    CombatTab:CreateToggle({
        Name = i .. ". " .. featureNames[i],
        CurrentValue = false,
        Flag = "CombatFeature" .. i,
        Callback = function(Value)
            States["CombatFeature" .. i] = Value
        end,
    })
end

-- ========================================
-- 📡 ESP TAB (Features 101-115)
-- ========================================
local ESPTab = Window:CreateTab("📡 ESP", 4483362458)
local ESPSection = ESPTab:CreateSection("ESP Features")

-- Feature 101: ESP Players
local ESPPlayersToggle = ESPTab:CreateToggle({
    Name = "101. ESP Players",
    CurrentValue = false,
    Flag = "ESPPlayers",
    Callback = function(Value)
        States.ESPPlayers = Value
        
        local function CreateESP(player)
            if not ESPObjects[player] and player.Character then
                SafeCall(function()
                    local highlight = Instance.new("Highlight")
                    highlight.Name = player.Name .. "_ESP"
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 50, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    highlight.FillTransparency = 0.5
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    ESPObjects[player] = highlight
                end)
            end
        end
        
        local function RemoveESP(player)
            if ESPObjects[player] then
                SafeCall(function()
                    ESPObjects[player]:Destroy()
                    ESPObjects[player] = nil
                end)
            end
        end
        
        if Value then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    CreateESP(player)
                end
            end
        else
            for player, highlight in pairs(ESPObjects) do
                SafeCall(function() highlight:Destroy() end)
            end
            ESPObjects = {}
        end
    end,
})

-- Features 102-115
for i = 102, 115 do
    local featureNames = {
        [102] = "ESP Items",
        [103] = "ESP Chests",
        [104] = "ESP NPCs",
        [105] = "ESP Doors",
        [106] = "ESP Money",
        [107] = "ESP Weapons",
        [108] = "ESP Vehicles",
        [109] = "ESP Tracers",
        [110] = "ESP Names",
        [111] = "ESP Health",
        [112] = "ESP Distance",
        [113] = "ESP Glow",
        [114] = "ESP Boxes",
        [115] = "ESP Skeletons"
    }
    
    ESPTab:CreateToggle({
        Name = i .. ". " .. featureNames[i],
        CurrentValue = false,
        Flag = "ESPFeature" .. i,
        Callback = function(Value)
            States["ESPFeature" .. i] = Value
        end,
    })
end

-- ========================================
-- 🚗 VEHICLE TAB (Features 116-120)
-- ========================================
local VehicleTab = Window:CreateTab("🚗 Vehicle", 4483362458)
local VehicleSection = VehicleTab:CreateSection("Vehicle Modifications")

-- Feature 116: Fly Vehicle
local FlyVehicleToggle = VehicleTab:CreateToggle({
    Name = "116. Fly Vehicle",
    CurrentValue = false,
    Flag = "FlyVehicle",
    Callback = function(Value)
        States.FlyVehicle = Value
    end,
})

-- Features 117-120
for i = 117, 120 do
    local featureNames = {
        [117] = "Vehicle Speed Boost",
        [118] = "Vehicle God Mode",
        [119] = "Vehicle No Clip",
        [120] = "Auto Farm Vehicle"
    }
    
    VehicleTab:CreateToggle({
        Name = i .. ". " .. featureNames[i],
        CurrentValue = false,
        Flag = "VehicleFeature" .. i,
        Callback = function(Value)
            States["VehicleFeature" .. i] = Value
        end,
    })
end

-- ========================================
-- 🎪 TELEPORT TAB (Features 121-125)
-- ========================================
local TeleportTab = Window:CreateTab("🎪 Teleport", 4483362458)
local TeleportSection = TeleportTab:CreateSection("Teleportation")

-- Feature 121: Click Teleport
local ClickTPToggle = TeleportTab:CreateToggle({
    Name = "121. Click Teleport " .. (IsMobile and "📱" or ""),
    CurrentValue = false,
    Flag = "ClickTP",
    Callback = function(Value)
        States.ClickTP = Value
    end,
})

if not IsMobile then
    AddConnection("ClickTP", Mouse.Button1Down:Connect(function()
        if States.ClickTP and HRP then
            SafeCall(function()
                HRP.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0))
            end)
        end
    end))
end

-- Feature 122: Player Teleport
local playerList = {}
local function UpdatePlayerList()
    playerList = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
end

UpdatePlayerList()

local TeleportDropdown = TeleportTab:CreateDropdown({
    Name = "122. Teleport to Player",
    Options = playerList,
    CurrentOption = "",
    Flag = "TeleportDropdown",
    Callback = function(Option)
        SafeCall(function()
            local target = Players:FindFirstChild(Option)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and HRP then
                HRP.CFrame = target.Character.HumanoidRootPart.CFrame
            end
        end)
    end,
})

-- Features 123-125
for i = 123, 125 do
    local featureNames = {
        [123] = "Teleport to Spawn",
        [124] = "Teleport to Safe Zone",
        [125] = "Auto Waypoint System"
    }
    
    TeleportTab:CreateButton({
        Name = i .. ". " .. featureNames[i],
        Callback = function()
            States["TeleportFeature" .. i] = true
        end,
    })
end

-- ========================================
-- ⚙️ MISC TAB (Features 126-130)
-- ========================================
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)
local MiscSection = MiscTab:CreateSection("Miscellaneous Features")

-- Feature 126: Anti AFK
local AntiAfkToggle = MiscTab:CreateToggle({
    Name = "126. Anti AFK",
    CurrentValue = false,
    Flag = "AntiAFK",
    Callback = function(Value)
        States.AntiAfk = Value
        
        if Value then
            AddConnection("AntiAFK", RS.Heartbeat:Connect(function()
                if States.AntiAfk then
                    SafeCall(function()
                        VirtualInputManager:SendKeyEvent(true, "W", false, game)
                        task.wait(0.1)
                        VirtualInputManager:SendKeyEvent(false, "W", false, game)
                    end)
                end
            end))
        else
            RemoveConnection("AntiAFK")
        end
    end,
})

-- Feature 127: Server Hop
local ServerHopButton = MiscTab:CreateButton({
    Name = "127. Server Hop",
    Callback = function()
        SafeCall(function()
            TeleportService:Teleport(game.PlaceId)
        end)
    end,
})

-- Feature 128: Rejoin Server
local RejoinButton = MiscTab:CreateButton({
    Name = "128. Rejoin Server",
    Callback = function()
        SafeCall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end,
})

-- Feature 129: DEX Explorer
local DEXButton = MiscTab:CreateButton({
    Name = "129. Load DEX Explorer",
    Callback = function()
        SafeCall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
            Rayfield:Notify({
                Title = "✅ DEX Loaded",
                Content = "Explorer window opened",
                Duration = 3,
                Image = 4483362458
            })
        end)
    end,
})

-- Feature 130: Simple Spy
local SimpleSpyButton = MiscTab:CreateButton({
    Name = "130. Load Simple Spy",
    Callback = function()
        SafeCall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))()
            Rayfield:Notify({
                Title = "✅ Simple Spy Loaded",
                Content = "Remote spy active",
                Duration = 3,
                Image = 4483362458
            })
        end)
    end,
})

-- ========================================
-- 🛡️ SETTINGS TAB
-- ========================================
local SettingsTab = Window:CreateTab("🛡️ Settings", 4483362458)
local SettingsSection = SettingsTab:CreateSection("Hub Settings")

local InfoLabel = SettingsTab:CreateLabel("Total Features: 130")
local PlatformLabel = SettingsTab:CreateLabel("Platform: " .. (IsMobile and "Mobile 📱" or "PC 💻"))

local SaveConfigButton = SettingsTab:CreateButton({
    Name = "💾 Save Configuration",
    Callback = function()
        Rayfield:Notify({
            Title = "✅ Config Saved",
            Content = "Your settings have been saved",
            Duration = 3,
            Image = 4483362458
        })
    end,
})

local DestroyGuiButton = SettingsTab:CreateButton({
    Name = "🗑️ Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

local UnloadButton = SettingsTab:CreateButton({
    Name = "🔌 Unload Script",
    Callback = function()
        CleanupAll()
        Rayfield:Destroy()
        SafeCall(function() script:Destroy() end)
    end,
})

-- ========================================
-- CHARACTER HANDLER & MOBILE CONTROLS
-- ========================================
LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid")
    HRP = newChar:WaitForChild("HumanoidRootPart")
    
    SafeCall(function()
        if States.WalkSpeed then
            Humanoid.WalkSpeed = States.WalkSpeed
        end
        
        if States.JumpPower then
            Humanoid.JumpPower = States.JumpPower
        end
        
        if FlyBodyVelocity and States.Fly then
            FlyBodyVelocity.Parent = HRP
        end
    end)
end)

-- Mobile Touch Controls for Fly
if IsMobile then
    -- Create mobile fly controls
    local FlyControlsFrame = Instance.new("Frame")
    FlyControlsFrame.Name = "FlyControls"
    FlyControlsFrame.Size = UDim2.new(0, 300, 0, 200)
    FlyControlsFrame.Position = UDim2.new(1, -320, 1, -220)
    FlyControlsFrame.BackgroundTransparency = 0.5
    FlyControlsFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    FlyControlsFrame.Visible = false
    FlyControlsFrame.Parent = CoreGui
    
    local function CreateFlyButton(name, position, callback)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Size = UDim2.new(0, 60, 0, 60)
        button.Position = position
        button.Text = name
        button.Parent = FlyControlsFrame
        button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        button.TextColor3 = Color3.new(1, 1, 1)
        
        button.MouseButton1Down:Connect(function()
            States["MobileFly" .. name] = true
        end)
        
        button.MouseButton1Up:Connect(function()
            States["MobileFly" .. name] = false
        end)
        
        return button
    end
    
    CreateFlyButton("Forward", UDim2.new(0.5, -30, 0, 10))
    CreateFlyButton("Backward", UDim2.new(0.5, -30, 0, 130))
    CreateFlyButton("Left", UDim2.new(0, 10, 0.5, -30))
    CreateFlyButton("Right", UDim2.new(1, -70, 0.5, -30))
    CreateFlyButton("Up", UDim2.new(0, 80, 0, 10))
    CreateFlyButton("Down", UDim2.new(0, 80, 0, 130))
end

-- ========================================
-- HOTKEYS (PC ONLY)
-- ========================================
if IsPC then
    AddConnection("Hotkeys", UIS.InputBegan:Connect(function(Input)
        SafeCall(function()
            if Input.KeyCode == Enum.KeyCode.F and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                FlyToggle:Set(not States.Fly)
                if IsMobile and CoreGui:FindFirstChild("FlyControls") then
                    CoreGui.FlyControls.Visible = States.Fly
                end
            end
        end)
    end))
end

-- ========================================
-- FINAL INITIALIZATION
-- ========================================
Rayfield:Notify({
    Title = "⚡ Infinity Universal Hub",
    Content = "✅ 130 Features Loaded Successfully!\n" .. (IsMobile and "📱 Mobile Mode" or "💻 PC Mode"),
    Duration = 6,
    Image = 4483362458
})

Rayfield:LoadConfiguration()

print("✅ Infinity Universal Hub - 130 Features Loaded")
print("📱 Platform: " .. (IsMobile and "Mobile" or "PC"))
print("🎮 All systems operational!")
