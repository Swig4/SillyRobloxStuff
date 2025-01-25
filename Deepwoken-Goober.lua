-- init
if not game:IsLoaded() then 
    game.Loaded:Wait()
end

if not syn or not protectgui then
    getgenv().protectgui = function() end
end

-- variables
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Workspace = game:GetService("Workspace")
local UIS = game:GetService'UserInputService'


local flyForce
local conn
local humanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
local originalGravity = workspace.Gravity
local FLY_SPEED = 50

-- functions
local function AllowRagdoll(Toggle)
    local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
    Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, Toggle)
    Humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

local function startFlying()
    if flyForce then return end
    if not Toggles.AntiRagdoll.Value then
        AllowRagdoll(false)
    end
    workspace.Gravity = 0

    flyForce = Instance.new("BodyVelocity")
    flyForce.Velocity = Vector3.new(0, 0, 0)
    flyForce.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyForce.Parent = humanoidRootPart

    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    conn = game:GetService("RunService").Heartbeat:Connect(function()
        local camera = workspace.CurrentCamera
        local lookVector = camera.CFrame.LookVector
        local rightVector = camera.CFrame.RightVector

        local moveDirection = Vector3.new(0, 0, 0)

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + lookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - lookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - rightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + rightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        if moveDirection.Magnitude > 0 then
            flyForce.Velocity = moveDirection.Unit * Options.FlightSlider.Value
        else
            flyForce.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end
local function stopFlying()
    if flyForce then
        flyForce:Destroy()
        flyForce = nil
    end
    if not Toggles.AntiRagdoll.Value then
        AllowRagdoll(true)
    end
    if conn then
        conn:Disconnect()
        conn = nil
    end

    workspace.Gravity = originalGravity

    for _, child in pairs(humanoidRootPart:GetChildren()) do
        if child:IsA("BodyGyro") then
            child:Destroy()
        end
    end

    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

local function teleportToCoordinates(x, y, z, duration)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = humanoidRootPart

    local startPosition = humanoidRootPart.Position
    local targetPosition = Vector3.new(x, y, z)
    local startTime = tick()
    while (humanoidRootPart.Position - targetPosition).Magnitude > 0.1 do
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / duration, 1)
        local newPosition = startPosition:Lerp(targetPosition, progress)
        humanoidRootPart.CFrame = CFrame.new(newPosition)
        wait(0.03)
    end
    bodyVelocity:Destroy()
end

local function SendNotification(message)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Goober Client",
        Text = message
    })
end

-- ui creating & handling
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
Library:SetWatermark("discord.gg/mushroom")
Library.OutlineColor = Color3.fromRGB(49, 169, 246)
Library.AccentColor = Color3.fromRGB(49, 169, 246)
local Window = Library:CreateWindow({Title = 'Goober Client | Made By swig5 | V1.0', Center = true, AutoShow = true, TabPadding = 8, MenuFadeTime = 0.2})

noclip = false
NoClipFirstEnabled = false

-- ON LOAD

SendNotification("Goober Client Has Successfully Loaded!")

game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
    Character:WaitForChild("HumanoidRootPart")
    ResetCollisions(Character)
end)

local function ResetCollisions(Character)
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

game:GetService('RunService').Stepped:connect(function()
    local Character = game.Players.LocalPlayer.Character
    if Character then
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if NoClipFirstEnabled then
            if noclip and HumanoidRootPart then
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            else
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end)

-- PLAYER
local PlayerTab = Window:AddTab("Player")
local MainBOX = PlayerTab:AddLeftTabbox("Main") do
    local Main = MainBOX:AddTab("Main")
    Main:AddToggle("Phase", {Text = "Phase"}):OnChanged(function(event)
        noclip = event
        if not NoClipFirstEnabled then
            NoClipFirstEnabled = true
        end
    end)
    Main:AddToggle("AntiRagdoll", {Text = "Anti Ragdoll"}):OnChanged(function(event)
        AllowRagdoll(event)
    end)
end


-- MOVEMENT
local MovementTab = Window:AddTab("Movement")
local SpeedBox = MovementTab:AddLeftTabbox("Speed") do
    local Main = SpeedBox:AddTab("Speed")

    Main:AddDropdown("SpeedMode", {AllowNull = false, Text = "Speed Mode", Default = "Walk", Values = {
        "Walk",
        "Force-Velo",
        "Force-Direction"
    }})
    
    Main:AddSlider("WalkSpeedSlider", {
        Text = "Walk Speed", 
        Min = 1, 
        Max = 300, 
        Default = 16, 
        Rounding = 0,
        Tooltip = "Default Value is 16."
    }):OnChanged(function()
        getgenv().WalkSpeedValue = Options.WalkSpeedSlider.Value
        local Player = game:service'Players'.LocalPlayer
        local Humanoid = Player.Character and Player.Character:FindFirstChildOfClass('Humanoid')
        local HumanoidRootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        local UIS = game:GetService'UserInputService'
    
        if Humanoid and HumanoidRootPart then
            if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.D) then
                if Options.SpeedMode.Value == "Walk" then
                    Humanoid.WalkSpeed = getgenv().WalkSpeedValue
    
                elseif Options.SpeedMode.Value == "Force-Direction" then
                    game:GetService("RunService").Heartbeat:Connect(function()
                        if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.D) then
                            if HumanoidRootPart then
                                local velocity = HumanoidRootPart.Velocity
                                local direction = Vector3.new(0, 0, 0)
    
                                if UIS:IsKeyDown(Enum.KeyCode.W) then
                                    direction = direction + HumanoidRootPart.CFrame.LookVector
                                end
                                if UIS:IsKeyDown(Enum.KeyCode.S) then
                                    direction = direction - HumanoidRootPart.CFrame.LookVector
                                end
                                if UIS:IsKeyDown(Enum.KeyCode.A) then
                                    direction = direction - HumanoidRootPart.CFrame.RightVector
                                end
                                if UIS:IsKeyDown(Enum.KeyCode.D) then
                                    direction = direction + HumanoidRootPart.CFrame.RightVector
                                end
    
                                if direction.Magnitude > 0 then
                                    direction = direction.Unit
                                end
    
                                local newVelocity = direction * Options.WalkSpeedSlider.Value
                                HumanoidRootPart.Velocity = Vector3.new(newVelocity.X, velocity.Y, newVelocity.Z)
                            end
                        end
                    end)
    
                elseif Options.SpeedMode.Value == "Force-Velo" then
                    game:GetService("RunService").Heartbeat:Connect(function()
                        if (UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.S)) and not UIS:IsKeyDown(Enum.KeyCode.D) then
                            if HumanoidRootPart then
                                local velocity = HumanoidRootPart.Velocity
                                local direction = HumanoidRootPart.CFrame.LookVector
    
                                local newVelocity = direction * Options.WalkSpeedSlider.Value
                                HumanoidRootPart.Velocity = Vector3.new(newVelocity.X, velocity.Y, newVelocity.Z)
                            end
                        end
                    end)
                end
            end
        end
    end)
    

    local AntiKBConnection

    Main:AddToggle("AntiKB", {Text = "Anti Speed Modify"}):OnChanged(function(event)
        local RunService = game:GetService("RunService")
        local Player = game.Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
        if event then
            AntiKBConnection = RunService.RenderStepped:Connect(function()
                if not UserInputService:IsKeyDown(Enum.KeyCode.W) and
                   not UserInputService:IsKeyDown(Enum.KeyCode.A) and
                   not UserInputService:IsKeyDown(Enum.KeyCode.S) and
                   not UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    HumanoidRootPart.Velocity = Vector3.zero
                end
            end)
        else
            if AntiKBConnection then
                AntiKBConnection:Disconnect()
                AntiKBConnection = nil
            end
        end
    end)
    
    
end

local FlyBox = MovementTab:AddRightTabbox("Main")
local Main = FlyBox:AddTab("Fly")
Main:AddToggle("Flight", { Text = "Flight", Default = false }):OnChanged(function(event)
    local Player = game:GetService'Players'.LocalPlayer
    local UIS = game:GetService'UserInputService'

    if event then
        startFlying()
    else
        stopFlying()
    end
end)

Main:AddSlider("FlightSlider", {
    Text = "Fly Speed", 
    Min = 1, 
    Max = 400, 
    Default = 50, 
    Rounding = 0
})

local JumpConnection
Main:AddToggle("INFJumps", { Text = "Infinite Jumps", Default = false }):OnChanged(function(event)
    local Player = game:GetService'Players'.LocalPlayer
    local UIS = game:GetService'UserInputService'

    if event then
        function Action(Object, Function)
            if Object ~= nil then
                Function(Object)
            end
        end
        JumpConnection = UIS.InputBegan:Connect(function(UserInput)
            if UserInput.UserInputType == Enum.UserInputType.Keyboard and UserInput.KeyCode == Enum.KeyCode.Space then
                Action(Player.Character.Humanoid, function(self)
                    if self:GetState() == Enum.HumanoidStateType.Jumping or self:GetState() == Enum.HumanoidStateType.Freefall then
                        Action(self.Parent.HumanoidRootPart, function(self)
                            self.Velocity = Vector3.new(self.Velocity.X, Options.JumpFlySlider.Value, self.Velocity.Z)
                        end)
                    end
                end)
            end
        end)
    else
        if JumpConnection then
            JumpConnection:Disconnect()
            JumpConnection = nil
        end
    end
end)

Main:AddSlider("JumpFlySlider", {
    Text = "Jump Height", 
    Min = 1, 
    Max = 150, 
    Default = 50, 
    Rounding = 0,
    Tooltip = "Default Value is 50."
})



-- VISUALS
local VisualTab = Window:AddTab("Visual")
local ESPBox = VisualTab:AddLeftTabbox("ESP") do
    local Main = ESPBox:AddTab("ESP Visuals")

    Main:AddToggle("PlayerESP", {Text = "Player ESP", Default = false}):AddColorPicker("ESPColor", {Default = Color3.fromRGB(255, 0, 4)}):OnChanged(function(event)
        local Players = game:GetService("Players")
        local function applyHighlight(player)
            local function onCharacterAdded(character)
                if not character:FindFirstChild("ESPHighlight") then
                    local highlight = Instance.new("Highlight", character)
                    highlight.Name = "ESPHighlight"
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Options.ESPColor.Value
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = Toggles.ESPFill.Value and 0.5 or 1
                    highlight.OutlineTransparency = 0
                end
            end
            if player.Character then
                onCharacterAdded(player.Character)
            end
            player.CharacterAdded:Connect(onCharacterAdded)
        end

        local function removeHighlight(player)
            if player.Character and player.Character:FindFirstChild("ESPHighlight") then
                player.Character.ESPHighlight:Destroy()
            end
        end

        if event then
            for _, player in pairs(Players:GetPlayers()) do
                applyHighlight(player)
            end
            Players.PlayerAdded:Connect(applyHighlight)
        else
            for _, player in pairs(Players:GetPlayers()) do
                removeHighlight(player)
            end
        end
    end)

    Main:AddToggle("ESPFill", {Text = "Render ESP Fill", Default = false}):OnChanged(function()
        if Toggles.PlayerESP.Value then
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player.Character and player.Character:FindFirstChild("ESPHighlight") then
                    local highlight = player.Character.ESPHighlight
                    highlight.FillTransparency = Toggles.ESPFill.Value and 0.5 or 1
                end
            end
        end
    end)

    Main:AddToggle("ESPHP", {Text = "Render Health", Default = false}):AddColorPicker("ESPHPColor", {Default = Color3.fromRGB(255, 255, 255)}):OnChanged(function(event)
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local healthLabels = {}
    
        local function createHealthLabel(character, player)
            if character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                local humanoid = character.Humanoid
                local billboard = Instance.new("BillboardGui", character.HumanoidRootPart)
                billboard.Name = "HealthDisplay"
                billboard.Size = UDim2.new(3, 0, 0.5, 0)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
    
                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Options.ESPHPColor.Value
                label.TextScaled = false
                label.TextSize = Options.HPSlider.Value
                label.Font = Enum.Font.Gotham
                label.Text = ""
    
                local connection = RunService.RenderStepped:Connect(function()
                    if humanoid and humanoid.Health > 0 then
                        local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                        label.Text = string.format("%s | %d%%", player.Name, healthPercent)
                    else
                        label.Text = string.format("%s | 0%%", player.Name)
                    end
                end)
    
                healthLabels[player] = {billboard = billboard, connection = connection}
            end
        end
        local function removeHealthLabel(player)
            if healthLabels[player] then
                local data = healthLabels[player]
                if data.connection then
                    data.connection:Disconnect()
                end
                if data.billboard then
                    data.billboard:Destroy()
                end
                healthLabels[player] = nil
            end
        end
    
        if event then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    createHealthLabel(player.Character, player)
                end
                player.CharacterAdded:Connect(function(character)
                    createHealthLabel(character, player)
                end)
            end
    
            Players.PlayerAdded:Connect(function(player)
                player.CharacterAdded:Connect(function(character)
                    createHealthLabel(character, player)
                end)
            end)
        else
            for _, player in pairs(Players:GetPlayers()) do
                removeHealthLabel(player)
            end
        end
    end)   
    Main:AddSlider("HPSlider", {
        Text = "Hp Font Size", 
        Min = 1, 
        Max = 70, 
        Default = 15, 
        Rounding = 0
    })
    
    Main:AddToggle("NPCESP", {Text = "NPC ESP", Default = false}):AddColorPicker("NPCESPColor", {Default = Color3.fromRGB(0, 255, 0)}):OnChanged(function(event)
        local NPCFolder = workspace:FindFirstChild("NPCs")
        local function createNameTag(npc)
            if npc:FindFirstChild("HumanoidRootPart") and not npc:FindFirstChild("NameTag") then
                local billboard = Instance.new("BillboardGui", npc.HumanoidRootPart)
                billboard.Name = "NameTag"
                billboard.Size = UDim2.new(2, 0, 1, 0)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                
                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Options.NPCESPColor.Value
                label.TextScaled = false
                label.TextSize = Options.NPCNameSlider.Value
                label.Font = Enum.Font.Gotham
                label.Text = npc.Name
            end
        end
        
        local function removeNameTag(npc)
            if npc:FindFirstChild("NameTag") then
                npc.NameTag:Destroy()
            end
        end

        if event then
            if NPCFolder then
                for _, npc in pairs(NPCFolder:GetChildren()) do
                    createNameTag(npc)
                end
                NPCFolder.ChildAdded:Connect(createNameTag)
            end
        else
            if NPCFolder then
                for _, npc in pairs(NPCFolder:GetChildren()) do
                    removeNameTag(npc)
                end
            end
        end
    end)
    Main:AddSlider("NPCNameSlider", {
        Text = "Npc Name Font Size", 
        Min = 1, 
        Max = 70, 
        Default = 15, 
        Rounding = 0
    })

    Main:AddToggle("DepthsESP", {Text = "Whirlpool ESP", Default = false}):AddColorPicker("DepthsESPColor", {Default = Color3.fromRGB(0, 255, 255)}):OnChanged(function(event)
        local function createNameTag(model)
            if not model:FindFirstChild("NameTag") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "NameTag"
                billboard.Size = UDim2.new(2, 0, 1, 0)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = model
                if model:IsA("Model") then
                    local center = model:GetBoundingBox().Position
                    billboard.Adornee = Instance.new("Attachment", workspace.Terrain)
                    billboard.Adornee.Position = center
                end
                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Options.DepthsESPColor.Value
                label.TextScaled = false
                label.TextSize = Options.WhirlpoolNameSlider.Value
                label.Font = Enum.Font.Gotham
                label.Text = model.Name
            end
        end
    
        local function removeNameTag(model)
            if model:FindFirstChild("NameTag") then
                model.NameTag:Destroy()
            end
        end
    
        if event then
            for _, model in pairs(workspace:GetChildren()) do
                if model:IsA("Model") and model.Name == "DepthsWhirlpool" then
                    createNameTag(model)
                end
            end
            workspace.ChildAdded:Connect(function(child)
                if child:IsA("Model") and child.Name == "DepthsWhirlpool" then
                    createNameTag(child)
                end
            end)
        else
            for _, model in pairs(workspace:GetChildren()) do
                if model:IsA("Model") and model.Name == "DepthsWhirlpool" then
                    removeNameTag(model)
                end
            end
        end
    end)
    
    Main:AddSlider("WhirlpoolNameSlider", {
        Text = "Whirlpool Font Size", 
        Min = 1, 
        Max = 70, 
        Default = 15, 
        Rounding = 0
    })
    
    
    
end
local CameraBox = VisualTab:AddRightTabbox("Camera") do
    local Main = CameraBox:AddTab("Camera")
    Main:AddDropdown("CameraMode", {
        AllowNull = true,
        Text = "Camera Mode",
        Default = nil,
        Values = {
            "First Person",
            "Third Person"
        }
    }):OnChanged(function()
        local player = game.Players.LocalPlayer
        local camera = workspace.CurrentCamera

        if Options.CameraMode.Value == "First Person" then
            player.CameraMode = Enum.CameraMode.LockFirstPerson
            player.CameraMaxZoomDistance = 0.5
            player.CameraMinZoomDistance = 0.5
        elseif Options.CameraMode.Value == "Third Person" then
            player.CameraMode = Enum.CameraMode.Classic
            player.CameraMaxZoomDistance = 128
            player.CameraMinZoomDistance = 0.5
        end
    end)


    Main:AddSlider("FOVSlider", {
        Text = "FOV", 
        Min = 1, 
        Max = 120, 
        Default = 70, 
        Rounding = 0,
        Tooltip = "Default is 70."
    }):OnChanged(function()
        local camera = workspace.CurrentCamera
        camera.FieldOfView = Options.FOVSlider.Value
    end)
end

-- TELEPORTING
local TeleportTab = Window:AddTab("Teleports")
local DeepwokenPOISBox = TeleportTab:AddLeftTabbox("DeepwokenPOIs") do 
    local Main = DeepwokenPOISBox:AddTab("Etrean POIs")
    Main:AddDropdown("locationteleport", {AllowNull = true, Text = "Location", Default = null, Values = {
        "Lower Erisia",
        "Isle Of Vigils",
        "Test"
    }}):OnChanged(function()
        if Options.locationteleport.Value == "Lower Erisia" then
            teleportToCoordinates(-370.8, 195.7, 27.4, 705)
        elseif Options.locationteleport.Value == "Isle Of Vigils" then

            teleportToCoordinates(-2439.9, 195.7, 2934.5, 5)

        elseif Options.locationteleport.Value == "Test" then
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            local currentPosition = humanoidRootPart.Position
            print("Current Location: X = " .. currentPosition.X .. ", Y = " .. currentPosition.Y .. ", Z = " .. currentPosition.Z)
        end
    end)
end

-- MISC
local MiscTab = Window:AddTab("Misc")
local ServerBox = MiscTab:AddLeftTabbox("Server") do 
    local Main = ServerBox:AddTab("Server")
    Main:AddToggle("panicbtn", {Text = "Panic Disconnect", Default = false, Tooltip = "Disconnects You From The Server"}):OnChanged(function(event)
        if event then
            game.Players.LocalPlayer:Kick("Goober Client: Panic Button Clicked.")
        end
    end)    

    local SpawnPart

    Main:AddToggle("partSpawn", {Text = "Make Platform", Default = false, Tooltip = "Spawns A Part Below You."}):OnChanged(function(event)
        if event then
            if not SpawnPart then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local rootPart = LocalPlayer.Character.HumanoidRootPart
                    SpawnPart = Instance.new("Part")
                    SpawnPart.Size = Vector3.new(4, 1, 4)
                    SpawnPart.Anchored = true
                    SpawnPart.BrickColor = BrickColor.new("Bright blue")
                    SpawnPart.Position = rootPart.Position - Vector3.new(0, (rootPart.Size.Y / 2) + 0.5, 0)
                    SpawnPart.Name = "partSpawn"
                    SpawnPart.Parent = Workspace
                end
            end
        else
            if SpawnPart then
                SpawnPart:Destroy()
                SpawnPart = nil
            end
        end
    end)
end

local BypassesBox = MiscTab:AddRightTabbox("Bypasses") do
    local Main = BypassesBox:AddTab("Bypasses")
    Main:AddToggle("voiceUnban", {Text = "Voicechat Bypass", Default = false, Tooltip = "Unbans You From A Voice Ban"}):OnChanged(function(event)
        if event then
            SendNotification("Bypassing...")
            task.delay(2.5, function()
                game:GetService("VoiceChatService"):joinVoice()
                SendNotification("Bypassed!")
            end)            
        else
            SendNotification("Rejoin The Game To Disable!")
        end
    end)
end

-- INFO
local InfoTab = Window:AddTab("Info")
local CreditsBox = InfoTab:AddLeftTabbox("Credits") do
    local Main = CreditsBox:AddTab("Made By swig5")
    Main:AddToggle("DiscordBtn", {Text = "Discord Link", Default = false}):OnChanged(function(event)
        if event then
            local link = "https://discord.gg/mushroom"
            setclipboard(link)
            SendNotification("Link Copied To Clipboard!")
        end
    end)
end

local KeybindsBox = InfoTab:AddRightTabbox("Keybinds") do
    local Main = KeybindsBox:AddTab("Goober Client Keybinds")
    Main:AddLabel("Hide GUI - Right CTRL")
end
local BugsBox = InfoTab:AddLeftTabbox("Bugs") do
    local Main = BugsBox:AddTab("Bugs That Are Being Fixed")
    Main:AddLabel("HP Label Doesn't Disappear")
end
