-- init
if not game:IsLoaded() then 
    game.Loaded:Wait()
end

if not syn or not protectgui then
    getgenv().protectgui = function() end
end

-- variables
getgenv().SilentAimSettings = Settings
local MainFileName = "GooberClient"
local SelectedFile, FileToSave = "", ""

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local resume = coroutine.resume 
local create = coroutine.create

-- functions

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
    Main:AddToggle("Phase", {Text = "Phase"}):OnChanged(function()
        noclip = Toggles.Phase.Value
        if not NoClipFirstEnabled then
            NoClipFirstEnabled = true
        end
    end)
    Main:AddToggle("AntiRagdoll", {Text = "Anti Ragdoll"}):OnChanged(function()
        local Player = game.Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid")
        
        if Toggles.AntiRagdoll.Value then
            Humanoid.StateChanged:Connect(function(_, newState)
                if newState == Enum.HumanoidStateType.Physics then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
        end
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

    Main:AddToggle("AntiKB", {Text = "Anti Speed Modify"}):OnChanged(function()
        local RunService = game:GetService("RunService")
        local Player = game.Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
        if Toggles.AntiKB.Value then
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
    Main:AddDropdown("FlyMethod", {AllowNull = false, Text = "Fly Mode", Default = "Off", Values = {
        "Off",
        "Jump"
    }}):OnChanged(function()
        local Player = game:GetService'Players'.LocalPlayer
        local UIS = game:GetService'UserInputService'
        local JumpConnection

        if Options.FlyMethod.Value == "Off" then
            if JumpConnection then
                JumpConnection:Disconnect()
                JumpConnection = nil
            end
        end

        if Options.FlyMethod.Value == "Jump" then
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

    Main:AddToggle("PlayerESP", {Text = "Player ESP", Default = false}):AddColorPicker("ESPColor", {Default = Color3.fromRGB(255, 0, 4)}):OnChanged(function()
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

        if Toggles.PlayerESP.Value then
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

    Main:AddToggle("ESPHP", {Text = "Render Health", Default = false}):AddColorPicker("ESPHPColor", {Default = Color3.fromRGB(255, 255, 255)}):OnChanged(function()
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
    
        if Toggles.ESPHP.Value then
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
        Default = 30, 
        Rounding = 0
    })
    
    Main:AddToggle("NPCESP", {Text = "NPC ESP", Default = false}):AddColorPicker("NPCESPColor", {Default = Color3.fromRGB(0, 255, 0)}):OnChanged(function()
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

        if Toggles.NPCESP.Value then
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

-- MISC
local MiscTab = Window:AddTab("Misc")
local MiscBox = MiscTab:AddLeftTabbox("Misc") do 
    local Main = MiscBox:AddTab("Server Hop")

    Main:AddToggle("serverHop", {Text = "Server Hop", Default = false}):OnChanged(function(enabled)
        if enabled then
            -- Fetch available servers
            local HttpService = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            local PlaceId = game.PlaceId

            local function getServers(cursor)
                local url = "https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                if cursor then
                    url = url .. "&cursor=" .. cursor
                end
                local response = HttpService:JSONDecode(game:HttpGet(url))
                return response
            end

            local function serverHop()
                local servers = getServers()
                while servers do
                    for _, server in ipairs(servers.data) do
                        if server.playing < server.maxPlayers and server.id ~= game.JobId then
                            TeleportService:TeleportToPlaceInstance(PlaceId, server.id)
                            return
                        end
                    end
                    if servers.nextPageCursor then
                        servers = getServers(servers.nextPageCursor)
                    else
                        servers = nil
                    end
                end
                SendNotification("No available servers to join!")
            end

            -- Trigger server hop
            serverHop()
        end
    end)
end


-- INFO
local InfoTab = Window:AddTab("Info")
local CreditsBox = InfoTab:AddLeftTabbox("Credits") do
    local Main = CreditsBox:AddTab("Made By swig5")
    Main:AddToggle("DiscordBtn", {Text = "Discord Link", Default = false}):OnChanged(function()
        local link = "https://discord.gg/mushroom"
        setclipboard(link)
        SendNotification("Link Copied To Clipboard!")
    end)
end
local KeybindsBox = InfoTab:AddRightTabbox("Keybinds") do
    local Main = KeybindsBox:AddTab("Goober Client Keybinds")
    Main:AddLabel("Hide GUI - Right CTRL")
end
local BugsBox = InfoTab:AddLeftTabbox("Bugs") do
    local Main = BugsBox:AddTab("Bugs That Are Being Fixed")
    Main:AddLabel("Jump Fly Can't Turn Off")
end