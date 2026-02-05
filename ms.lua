-- Infinity Universal Hub - 100+ Features
-- 修正版: 機能がタブに追加されていない問題を解決

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

-- 修正点: 各タブにセクションを作成して機能を追加
local MainTab = Window:CreateTab("Main Hacks", 4483362458)
-- 1. MainTabにセクションと機能を追加
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
            
            local flyConnection = RS.Heartbeat:Connect(function()
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
            end)
            
            Connections["Fly"] = flyConnection
        else
            if Connections["Fly"] then
                Connections["Fly"]:Disconnect()
                Connections["Fly"] = nil
            end
            if FlyBodyVelocity then
                FlyBodyVelocity:Destroy()
                FlyBodyVelocity = nil
            end
        end
    end,
})

-- ホットキー設定
UIS.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.F and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        FlyToggle:Set(not States.Fly)
    end
end)

-- MainTabに別の機能を追加
local NoclipToggle = MainTab:CreateToggle({
    Name = "No Clip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        States.NoClip = Value
    end,
})

RS.Stepped:Connect(function()
    if States.NoClip and Character then
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- MainTabにセクションを追加
local MiscSection = MainTab:CreateSection("Miscellaneous")

local IYCommandsButton = MainTab:CreateButton({
    Name = "Load Infinity Yield",
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

-- Player Tab - 完全に機能を追加
local PlayerTab = Window:CreateTab("Player", 4483362458)
local MovementSection = PlayerTab:CreateSection("Movement")

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

local InfiniteJumpToggle = PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJumpToggle",
    Callback = function(Value)
        States.InfiniteJump = Value
    end,
})

UIS.JumpRequest:Connect(function()
    if States.InfiniteJump and Humanoid then
        Humanoid:ChangeState("Jumping")
    end
end)

local CharacterSection = PlayerTab:CreateSection("Character")
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
            else
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            end
        end
    end,
})

local ResetCharacterButton = PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        LocalPlayer:LoadCharacter()
    end,
})

-- Visual Tab
local VisualTab = Window:CreateTab("Visual", 4483362458)
local ESPVisualSection = VisualTab:CreateSection("ESP")

local ESPPlayersToggle = VisualTab:CreateToggle({
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
        else
            for player, highlight in pairs(ESPObjects) do
                highlight:Destroy()
            end
            ESPObjects = {}
        end
    end,
})

local GraphicsSection = VisualTab:CreateSection("Graphics")
local FPSBoostToggle = VisualTab:CreateToggle({
    Name = "FPS Boost",
    CurrentValue = false,
    Flag = "FPSBoostToggle",
    Callback = function(Value)
        States.FPSBoost = Value
        if Value then
            settings().Rendering.QualityLevel = 1
            Lighting.GlobalShadows = false
        else
            settings().Rendering.QualityLevel = 3
            Lighting.GlobalShadows = true
        end
    end,
})

local FullBrightToggle = VisualTab:CreateToggle({
    Name = "Full Bright",
    CurrentValue = false,
    Flag = "FullBrightToggle",
    Callback = function(Value)
        States.FullBright = Value
        if Value then
            Lighting.Brightness = 2
            Lighting.FogEnd = 1000000
        else
            Lighting.Brightness = 1
            Lighting.FogEnd = 1000
        end
    end,
})

-- World Tab
local WorldTab = Window:CreateTab("World", 4483362458)
local WorldControlSection = WorldTab:CreateSection("World Control")

local TimeSlider = WorldTab:CreateSlider({
    Name = "Time of Day",
    Range = {0, 24},
    Increment = 0.5,
    Suffix = "hours",
    CurrentValue = 14,
    Flag = "TimeSlider",
    Callback = function(Value)
        Lighting.ClockTime = Value
    end,
})

local RemoveLightsToggle = WorldTab:CreateToggle({
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

-- Auto Farm Tab
local AutoFarmTab = Window:CreateTab("Auto Farm", 4483362458)
local FarmingSection = AutoFarmTab:CreateSection("Auto Farming")

local AutoFarmToggle = AutoFarmTab:CreateToggle({
    Name = "Auto Farm Nearest Player",
    CurrentValue = false,
    Flag = "AutoFarmToggle",
    Callback = function(Value)
        States.AutoFarm = Value
        
        if Value then
            local farmConnection = RS.Heartbeat:Connect(function()
                if States.AutoFarm and Character and HRP then
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
                            
                            if nearestDistance < 10 then
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                                task.wait(0.1)
                                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                            end
                        end
                    end
                end
            end)
            
            Connections["AutoFarm"] = farmConnection
        else
            if Connections["AutoFarm"] then
                Connections["AutoFarm"]:Disconnect()
                Connections["AutoFarm"] = nil
            end
        end
    end,
})

-- Combat Tab
local CombatTab = Window:CreateTab("Combat", 4483362458)
local CombatSection = CombatTab:CreateSection("Combat Features")

local AutoClickerToggle = CombatTab:CreateToggle({
    Name = "Auto Clicker",
    CurrentValue = false,
    Flag = "AutoClickerToggle",
    Callback = function(Value)
        States.AutoClicker = Value
        
        if Value then
            local clickConnection = RS.Heartbeat:Connect(function()
                if States.AutoClicker then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                    task.wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                end
            end)
            
            Connections["AutoClicker"] = clickConnection
        else
            if Connections["AutoClicker"] then
                Connections["AutoClicker"]:Disconnect()
                Connections["AutoClicker"] = nil
            end
        end
    end,
})

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
        local target = Mouse.Target
        if target and target.Parent:FindFirstChild("Humanoid") then
            States.AimlockTarget = target.Parent
        end
    end
end)

local aimlockConnection = RS.Heartbeat:Connect(function()
    if States.Aimlock and States.AimlockTarget and States.AimlockTarget:FindFirstChild("HumanoidRootPart") then
        local camera = WS.CurrentCamera
        local targetPos = States.AimlockTarget.HumanoidRootPart.Position
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
    end
end)

Connections["Aimlock"] = aimlockConnection

-- Teleport Tab
local TeleportTab = Window:CreateTab("Teleport", 4483362458)
local TeleportSection = TeleportTab:CreateSection("Teleportation")

local ClickTPToggle = TeleportTab:CreateToggle({
    Name = "Click Teleport",
    CurrentValue = false,
    Flag = "ClickTPToggle",
    Callback = function(Value)
        States.ClickTP = Value
    end,
})

Mouse.Button1Down:Connect(function()
    if States.ClickTP and HRP then
        HRP.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0))
    end
end)

local PlayerTeleportSection = TeleportTab:CreateSection("Player Teleport")
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
    Name = "Teleport to Player",
    Options = playerList,
    CurrentOption = "",
    Flag = "TeleportDropdown",
    Callback = function(Option)
        local target = Players:FindFirstChild(Option)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and HRP then
            HRP.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end,
})

-- ESP Tab
local ESPTab = Window:CreateTab("ESP", 4483362458)
local ESPSection = ESPTab:CreateSection("ESP Features")

local ESPItemsToggle = ESPTab:CreateToggle({
    Name = "ESP Items",
    CurrentValue = false,
    Flag = "ESPItemsToggle",
    Callback = function(Value)
        States.ESPItems = Value
        
        local function UpdateESPItems()
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
        end
        
        if Value then
            local espConnection = RS.Heartbeat:Connect(UpdateESPItems)
            Connections["ESPItems"] = espConnection
        else
            if Connections["ESPItems"] then
                Connections["ESPItems"]:Disconnect()
                Connections["ESPItems"] = nil
            end
            UpdateESPItems()
        end
    end,
})

-- Vehicle Tab
local VehicleTab = Window:CreateTab("Vehicle", 4483362458)
local VehicleSection = VehicleTab:CreateSection("Vehicle Mods")

local FlyVehicleToggle = VehicleTab:CreateToggle({
    Name = "Fly Vehicle",
    CurrentValue = false,
    Flag = "FlyVehicleToggle",
    Callback = function(Value)
        States.FlyVehicle = Value
        
        if Value then
            local vehicleConnection = RS.Heartbeat:Connect(function()
                if States.FlyVehicle and Character then
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
            end)
            
            Connections["FlyVehicle"] = vehicleConnection
        else
            if Connections["FlyVehicle"] then
                Connections["FlyVehicle"]:Disconnect()
                Connections["FlyVehicle"] = nil
            end
        end
    end,
})

-- Fun Tab
local FunTab = Window:CreateTab("Fun", 4483362458)
local FunSection = FunTab:CreateSection("Fun Features")

local WalkOnWaterToggle = FunTab:CreateToggle({
    Name = "Walk on Water",
    CurrentValue = false,
    Flag = "WalkOnWaterToggle",
    Callback = function(Value)
        States.WalkOnWater = Value
        
        if Value then
            local platform = Instance.new("Part")
            platform.Name = "WaterPlatform"
            platform.Size = Vector3.new(100, 2, 100)
            platform.Transparency = 0.7
            platform.Color = Color3.fromRGB(0, 150, 255)
            platform.Anchored = true
            platform.CanCollide = true
            platform.Parent = WS
            
            local platformConnection = RS.Heartbeat:Connect(function()
                if platform and HRP then
                    platform.Position = Vector3.new(
                        HRP.Position.X,
                        0,
                        HRP.Position.Z
                    )
                end
            end)
            
            Connections["WaterPlatform"] = platformConnection
            States.WaterPlatform = platform
        else
            if Connections["WaterPlatform"] then
                Connections["WaterPlatform"]:Disconnect()
                Connections["WaterPlatform"] = nil
            end
            if States.WaterPlatform then
                States.WaterPlatform:Destroy()
                States.WaterPlatform = nil
            end
        end
    end,
})

-- Misc Tab
local MiscTab = Window:CreateTab("Misc", 4483362458)
local MiscSection = MiscTab:CreateSection("Miscellaneous")

local AntiAfkToggle = MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAfkToggle",
    Callback = function(Value)
        States.AntiAfk = Value
        
        if Value then
            local afkConnection = RS.Heartbeat:Connect(function()
                if States.AntiAfk then
                    VirtualInputManager:SendKeyEvent(true, "W", false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, "W", false, game)
                end
            end)
            
            Connections["AntiAFK"] = afkConnection
        else
            if Connections["AntiAFK"] then
                Connections["AntiAFK"]:Disconnect()
                Connections["AntiAFK"] = nil
            end
        end
    end,
})

local ServerHopButton = MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        TeleportService:Teleport(game.PlaceId)
    end,
})

-- Settings Tab
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local SettingsSection = SettingsTab:CreateSection("Hub Settings")

local DestroyGuiButton = SettingsTab:CreateButton({
    Name = "Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

local UnloadButton = SettingsTab:CreateButton({
    Name = "Unload Script",
    Callback = function()
        for name, connection in pairs(Connections) do
            connection:Disconnect()
        end
        
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if States.WaterPlatform then States.WaterPlatform:Destroy() end
        
        Rayfield:Destroy()
        script:Destroy()
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
    
    if FlyBodyVelocity and States.Fly then
        FlyBodyVelocity.Parent = HRP
    end
end)

-- 初期通知
Rayfield:Notify({
    Title = "Infinity Universal Hub Loaded",
    Content = "All features are now available!",
    Duration = 5,
    Image = 4483362458
})

-- 設定をロード
Rayfield:LoadConfiguration()

print("Infinity Universal Hub successfully loaded with all features!")
