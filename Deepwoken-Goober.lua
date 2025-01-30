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
local Player = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Workspace = game:GetService("Workspace")
local UIS = game:GetService'UserInputService'
local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
local HumanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local Character = game.Players.LocalPlayer.Character
local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

local flyForce
local conn
local originalGravity = workspace.Gravity
local FLY_SPEED = 50
local noclip = false
local NoClipFirstEnabled = false
local SpawnPart
local originalServerInfo = nil
local originalPlayername = nil
local originalPlayerList = nil
local healthLabels = {}

local ShowLeaderBoardToggle = true

-- functions
local function createNameTag(parent, name, color, textSize)
    local billboard = Instance.new("BillboardGui", parent)
    billboard.Name = "NameTag"
    billboard.Size = UDim2.new(2, 0, 1, 0)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color
    label.TextScaled = false
    label.TextSize = textSize
    label.Font = Enum.Font.Gotham
    label.Text = name
end

local function removeNameTag(parent)
    if parent:FindFirstChild("NameTag") then
        parent.NameTag:Destroy()
    end
end

local function toggleESP(event, folder, createFn, removeFn)
    if event then
        for _, obj in pairs(folder:GetChildren()) do
            createFn(obj)
        end
        folder.ChildAdded:Connect(createFn)
    else
        for _, obj in pairs(folder:GetChildren()) do
            removeFn(obj)
        end
    end
end

local function toggleHealthLabels(event, player, createFn, removeFn)
    local function onCharacterAdded(character)
        if character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
            createFn(character, player)
        end
    end
    
    if event then
        onCharacterAdded(player.Character)
        player.CharacterAdded:Connect(onCharacterAdded)
    else
        removeFn(player)
    end
end

local function AllowRagdoll(Toggle)
    if Humanoid then
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, Toggle)
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    else
        warn("Humanoid is nil, cannot change ragdoll state.")
    end
end

local firstLoad = true
local function onPlayerAdded(player)
    if firstLoad then
        task.wait(3)
        firstLoad = false
    end
    if Toggles and Toggles.moddc and Toggles.moddc.Value then
        if player:IsInGroup(5212858) then
            local dcText = "Moderator detected: " .. player.Name .. ". Disconnecting..."
            Library:Notify(dcText)
            SendNotification(dcText)
            task.wait(1)
            game.Players.LocalPlayer:Kick("Goober Client: Mod Detected.")
        end
    end
end

game.Players.PlayerAdded:Connect(onPlayerAdded)

local function startFlying()
    if flyForce then return end
    if not Toggles.AntiRagdoll.Value then
        AllowRagdoll(false)
    end
    workspace.Gravity = 0

    flyForce = Instance.new("BodyVelocity")
    flyForce.Velocity = Vector3.new(0, 0, 0)
    flyForce.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyForce.Parent = HumanoidRootPart

    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    conn = game:GetService("RunService").Heartbeat:Connect(function()
        local lookVector = Camera.CFrame.LookVector
        local rightVector = Camera.CFrame.RightVector
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

    for _, child in pairs(HumanoidRootPart:GetChildren()) do
        if child:IsA("BodyGyro") then
            child:Destroy()
        end
    end

    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

local function teleportToCoordinates(x, y, z, duration)
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000) 
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = HumanoidRootPart

    local startPosition = HumanoidRootPart.Position
    local targetPosition = Vector3.new(x, y, z)
    local startTime = tick()
    while (HumanoidRootPart.Position - targetPosition).Magnitude > 0.1 do
        local elapsed = tick() - startTime
        local progress = math.min(elapsed / duration, 1)
        local newPosition = startPosition:Lerp(targetPosition, progress)
        HumanoidRootPart.CFrame = CFrame.new(newPosition)
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

local function applyVelocity(velocity)
    if HumanoidRootPart then
        local newVelocity = velocity * Options.WalkSpeedSlider.Value
        HumanoidRootPart.Velocity = Vector3.new(newVelocity.X, HumanoidRootPart.Velocity.Y, newVelocity.Z)
    end
end

local function ToggleNoClip(Character, enable)
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = not enable
        end
    end
end

-- ui creating & handling
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
Library:SetWatermark("discord.gg/mushroom")
Library.OutlineColor = Color3.fromRGB(49, 169, 246)
Library.AccentColor = Color3.fromRGB(49, 169, 246)
local Window = Library:CreateWindow({Title = 'Goober Client | Made By swig5 | V1.0', Center = true, AutoShow = true, TabPadding = 8, MenuFadeTime = 0.2})

-- ON LOAD
SendNotification("Goober Client Has Successfully Loaded!")
local function ResetCollisions(Character)
    for _, part in pairs(Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

game.Players.LocalPlayer.CharacterAdded:Connect(function(Character)
    Character:WaitForChild("HumanoidRootPart")
    ResetCollisions(Character)

    game:GetService('RunService').Stepped:Connect(function(_, dt)
        if NoClipFirstEnabled and noclip then
            ToggleNoClip(Character, true)
        else
            ToggleNoClip(Character, false)
        end
    end)
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

    Main:AddDropdown("SpeedMode", {AllowNull = false, Text = "Speed Mode", Default = "Force-Direction", Values = {
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
        local RunService = game:GetService("RunService")
        
        local function createHealthLabel(character, player)
            if character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
                if player == game.Players.LocalPlayer then return end
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
                    if Humanoid and Humanoid.Health > 0 then
                        local healthPercent = math.floor((Humanoid.Health / Humanoid.MaxHealth) * 100)
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

    local npcTags = {}

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
    
                npcTags[npc] = billboard
            end
        end
    
        local function removeNameTag(npc)
            if npcTags[npc] then
                npcTags[npc]:Destroy()
                npcTags[npc] = nil
            end
        end
    
        if event then
            if NPCFolder then
                for _, npc in pairs(NPCFolder:GetChildren()) do
                    createNameTag(npc)
                end
            end
        else
            for npc, tag in pairs(npcTags) do
                tag:Destroy()
            end
            npcTags = {}
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
        toggleESP(event, workspace, function(model)
            if model.Name == "DepthsWhirlpool" then
                createNameTag(model, model.Name, Options.DepthsESPColor.Value, Options.WhirlpoolNameSlider.Value)
            end
        end, function(model)
            if model.Name == "DepthsWhirlpool" then
                removeNameTag(model)
            end
        end)
    end)
    Main:AddSlider("WhirlpoolNameSlider", {Text = "Whirlpool Font Size", Min = 1, Max = 70, Default = 15, Rounding = 0})

    Main:AddToggle("ShipsESP", {Text = "Ship ESP", Default = false}):AddColorPicker("ShipESPColor", {Default = Color3.fromRGB(255, 255, 0)}):OnChanged(function(event)
        local ShipFolder = workspace:FindFirstChild("Ships")
        
        local function createNameTag(ship)
            if ship:IsA("Model") and ship.PrimaryPart and not ship.PrimaryPart:FindFirstChild("NameTag") then
                local billboard = Instance.new("BillboardGui", ship.PrimaryPart)
                billboard.Name = "NameTag"
                billboard.Size = UDim2.new(2, 0, 1, 0)
                billboard.StudsOffset = Vector3.new(0, 3, 0)
                billboard.AlwaysOnTop = true
                
                local label = Instance.new("TextLabel", billboard)
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Options.ShipESPColor.Value
                label.TextScaled = false
                label.TextSize = Options.ShipNameSlider.Value
                label.Font = Enum.Font.Gotham
                label.Text = ship.Name
            end
        end
        
        local function removeNameTag(ship)
            if ship:IsA("Model") and ship.PrimaryPart and ship.PrimaryPart:FindFirstChild("NameTag") then
                ship.PrimaryPart.NameTag:Destroy()
            end
        end
    
        if event then
            if ShipFolder then
                for _, ship in pairs(ShipFolder:GetChildren()) do
                    createNameTag(ship)
                end
                ShipFolder.ChildAdded:Connect(createNameTag)
            end
        else
            if ShipFolder then
                for _, ship in pairs(ShipFolder:GetChildren()) do
                    removeNameTag(ship)
                end
            end
        end
    end)
    
    Main:AddSlider("ShipNameSlider", {
        Text = "Ships Font Size", 
        Min = 1, 
        Max = 70, 
        Default = 15, 
        Rounding = 0
    })
end

local OverlayBox = VisualTab:AddRightTabbox("Overlay") do
    local Main = OverlayBox:AddTab("Overlay")
    Main:AddToggle("SanityBarOverlay", {Text = "Sanity Bar", Default = false}):OnChanged(function(event)
        local playerName = LocalPlayer.Name
        local liveFolder = game.Workspace:FindFirstChild("Live")
        local playerModel = liveFolder and liveFolder:FindFirstChild(playerName)
        local statsGui = playerGui:FindFirstChild("StatsGui")
        local survivalStats = statsGui:FindFirstChild("SurvivalStats")
        local waterFrame = survivalStats:FindFirstChild("Water")
        
        local sanityObject = playerModel and playerModel:FindFirstChild("Sanity")
        local sanity = sanityObject and sanityObject:IsA("DoubleConstrainedValue") and sanityObject.Value or nil
        local maxSanity = sanityObject and sanityObject:IsA("DoubleConstrainedValue") and sanityObject.MaxValue or nil
        if event then
            if playerGui and statsGui and statsGui:IsA("ScreenGui") and survivalStats and survivalStats:IsA("Frame") and waterFrame and waterFrame:IsA("Frame") then
                local sanityFrame = survivalStats:FindFirstChild("Sanity")
                if not sanityFrame and event then
                    sanityFrame = waterFrame:Clone()
                    sanityFrame.Name = "Sanity"
                    sanityFrame.Parent = survivalStats
                    sanityFrame.Position = UDim2.new(0, 72, 1, 0)
                    local slider = sanityFrame:FindFirstChild("Slider")
                    if slider and slider:IsA("Frame") then
                        slider.BackgroundColor3 = Color3.fromRGB(0, 40, 150)
                        if maxSanity and maxSanity > 0 then
                            slider.Size = UDim2.fromScale(1, sanity / maxSanity)
                        end
                    end
                end
                if sanityObject and maxSanity then
                    sanityObject.Changed:Connect(function()
                        if sanityFrame and sanityFrame.Parent then
                            local slider = sanityFrame:FindFirstChild("Slider")
                            if slider then
                                if maxSanity and maxSanity > 0 then
                                    slider.Size = UDim2.fromScale(1, sanityObject.Value / maxSanity)
                                end
                            end
                        end
                    end)
                end
            end
        else
            local existingSanity = survivalStats:FindFirstChild("Sanity")
            if existingSanity then
                existingSanity:Destroy()
            end
        end
    end)

    

    Main:AddToggle("StreamerMode", {Text = "Streamer Mode", Default = false}):OnChanged(function(enabled)
        local infoFrame = Player.PlayerGui:FindFirstChild("WorldInfo") and Player.PlayerGui.WorldInfo:FindFirstChild("InfoFrame")
        local leaderboardGui = Player.PlayerGui:FindFirstChild("LeaderboardGui")
    
        if infoFrame then
            local serverInfo = infoFrame:FindFirstChild("ServerInfo")
            local Playername = infoFrame:FindFirstChild("CharacterInfo")
    
            if enabled then
                if serverInfo and not originalServerInfo then
                    originalServerInfo = serverInfo
                    serverInfo.Parent = nil
                end
                if Playername and not originalPlayername then
                    originalPlayername = Playername
                    Playername.Parent = nil
                end
                if leaderboardGui and not ShowLeaderBoardToggle and not originalPlayerList then
                    originalPlayerList = leaderboardGui
                    leaderboardGui.Parent = nil
                end
            else
                if originalServerInfo then
                    originalServerInfo.Parent = infoFrame
                    originalServerInfo = nil
                end
                if originalPlayername then
                    originalPlayername.Parent = infoFrame
                    originalPlayername = nil
                end
                if originalPlayerList and not ShowLeaderBoardToggle then
                    originalPlayerList.Parent = Player.PlayerGui
                    originalPlayerList = nil
                end
            end
        end
    end)
    
    Main:AddToggle("leaderboardShowToggle", {Text = "Show Leaderboard", Default = true, Tooltip = "Show Leaderboard for streamer mode"}):OnChanged(function(event)
        ShowLeaderBoardToggle = event
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
            local currentPosition = HumanoidRootPart.Position
            print("Current Location: X = " .. currentPosition.X .. ", Y = " .. currentPosition.Y .. ", Z = " .. currentPosition.Z)
        end
    end)
end

-- MISC
local MiscTab = Window:AddTab("Misc")
local ServerBox = MiscTab:AddLeftTabbox("Server") do 
    local Main = ServerBox:AddTab("Server")
    Main:AddToggle("panicbtn", {Text = "Panic Disconnect", Default = false, Tooltip = "Disconnects You From The Server"}):OnChanged(function(event)
        if event then game.Players.LocalPlayer:Kick("Goober Client: Panic Button Clicked.") end
    end) 
    local playerWarningDistance = 1000
    local warnedPlayers = {}
    local playerCheckLoop = nil
    
    Main:AddToggle("playerdiswaring", {
        Text = "Nearby Player Warning",
        Default = true,
        Tooltip = "Warns You Of Nearby Players"
    }):OnChanged(function(enabled)
        if enabled then
            local function calculateDistance(position1, position2)
                return (position1 - position2).Magnitude
            end
    
            playerCheckLoop = RunService.RenderStepped:Connect(function()
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local playerPosition = player.Character.HumanoidRootPart.Position
                        local localPlayerPosition = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    
                        if localPlayerPosition then
                            local distance = calculateDistance(localPlayerPosition, playerPosition)
    
                            if distance <= playerWarningDistance then
                                if not warnedPlayers[player] then
                                    warnedPlayers[player] = true
                                    Library:Notify(string.format("Player %s is nearby! Distance: %.2f", player.Name, distance))
                                end
                            else
                                warnedPlayers[player] = nil
                            end
                        end
                    end
                end
            end)
        else
            if playerCheckLoop then
                playerCheckLoop:Disconnect()
                playerCheckLoop = nil
            end
            warnedPlayers = {}
        end
    end)    
    Main:AddSlider("playerdiswaringslider", {
        Text = "Player Warning Distance", 
        Min = 1, 
        Max = 10000, 
        Default = playerWarningDistance, 
        Rounding = 0
    }):OnChanged(function(value)
        playerWarningDistance = value
    end)
    


    Main:AddToggle("partSpawn", {Text = "Make Platform", Default = false, Tooltip = "Client Side Only, Will AA Gun you"}):OnChanged(function(event)
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
    Main:AddToggle("moddc", {Text = "Disconnect On Mod Join", Default = true})

end
local FunnyBox = MiscTab:AddRightTabbox("Funny") do
    local Main = FunnyBox:AddTab("Funny")
    Main:AddToggle("StealTalentsBtn", {Text = "Steal Talents", Default = false}):OnChanged(function(event)
    
        local function CopyTalents()
            local localBackpack = LocalPlayer:FindFirstChild("Backpack")
            if not localBackpack or not localBackpack:IsA("Backpack") then
                warn("Local player does not have a valid Backpack instance.")
                return
            end
        

            local function TalentExists(talentName)
                for _, item in pairs(localBackpack:GetChildren()) do
                    if item.Name == talentName and item:IsA("Folder") then
                        return true
                    end
                end
                return false
            end

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    print("Checking player:", player.Name)
                    local playerFolder = Players:FindFirstChild(player.Name)
    
                    local otherBackpack = player.Backpack
    
                    if otherBackpack then
                        for _, item in pairs(otherBackpack:GetChildren()) do
                            if item:IsA("Folder") and string.match(item.Name, "^Talent:") then
                                if not TalentExists(item.Name) then
                                    local clonedTalent = item:Clone()
                                    clonedTalent.Parent = localBackpack
                                end
                            end
                        end
                    end
                end
            end
            SendNotification("Done!")
        end
    
        if event then CopyTalents() end
    end)    
end

local RandomBox = MiscTab:AddLeftTabbox("Random") do
    local Main = RandomBox:AddTab("Random")
    Main:AddToggle("autoFriends", {Text = "Auto Charisma", Default = false, Tooltip = "Auto Does How To Make Friends"}):OnChanged(function(enabled)
        
        while enabled do
            local choicePrompt = game.Players.LocalPlayer.PlayerGui:FindFirstChild("ChoicePrompt")
            
            if choicePrompt then
                local choiceFrame = choicePrompt:FindFirstChild("ChoiceFrame")
                if choiceFrame then
                    local popup = choiceFrame:FindFirstChild("Popup")
                    if popup then
                        local mouseButton1ClickSignal = popup:FindFirstChild("MouseButton1Click")
                        if mouseButton1ClickSignal then
                            firesignal(mouseButton1ClickSignal)
                            wait(0.1)
                            popup = choiceFrame:FindFirstChild("Popup")
                            if popup then
                                local mouseButton1ClickSignal = popup:FindFirstChild("MouseButton1Click")
                                if mouseButton1ClickSignal then
                                    firesignal(mouseButton1ClickSignal)
                                end
                            end
                        end
                    end
                end
                
                while choicePrompt and choicePrompt.Parent do
                    wait(0.1)
                end
            end
            wait(0.1)
        end
    end)
end

local BypassesBox = MiscTab:AddRightTabbox("Bypasses") do
    local Main = BypassesBox:AddTab("Bypasses")
    Main:AddButton({Text = "Voicechat Bypass", Tooltip = "Unbans You From A Voice Ban", Func = function()
        SendNotification("Bypassing...")
        task.delay(2.5, function()
            game:GetService("VoiceChatService"):joinVoice()
            SendNotification("Bypassed!")
        end)            
    end})
end

-- CLIENT
local ClientTab = Window:AddTab("Client")
local ClientBox = ClientTab:AddLeftTabbox("Client") do 
    local Main = ClientBox:AddTab("Client")

end

-- INFO
local InfoTab = Window:AddTab("Info")
local CreditsBox = InfoTab:AddLeftTabbox("Credits") do
    local Main = CreditsBox:AddTab("Made By swig5 & catpics")
    Main:AddButton({Text = "Copy Discord Link", Func = function()
        setclipboard("https://discord.gg/mushroom")
        SendNotification("Link Copied To Clipboard!")
    end})    
end

local KeybindsBox = InfoTab:AddRightTabbox("Keybinds") do
    local Main = KeybindsBox:AddTab("Goober Client Keybinds")
    Main:AddLabel("Hide GUI - Right CTRL")
end
local BugsBox = InfoTab:AddLeftTabbox("Bugs") do
    local Main = BugsBox:AddTab("Bugs That Are Being Fixed")
    Main:AddLabel("None ATM!")
end
