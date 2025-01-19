-- init
if not game:IsLoaded() then 
    game.Loaded:Wait()
end

if not syn or not protectgui then
    getgenv().protectgui = function() end
end

-- variables
getgenv().SilentAimSettings = Settings
local MainFileName = "ShroomClient"
local SelectedFile, FileToSave = "", ""

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local GetChildren = game.GetChildren
local GetPlayers = Players.GetPlayers
local WorldToScreen = Camera.WorldToScreenPoint
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local FindFirstChild = game.FindFirstChild
local RenderStepped = RunService.RenderStepped
local GuiInset = GuiService.GetGuiInset
local GetMouseLocation = UserInputService.GetMouseLocation

local resume = coroutine.resume 
local create = coroutine.create

--[[file handling]] do 
    if not isfolder(MainFileName) then 
        makefolder(MainFileName);
    end
    
    if not isfolder(string.format("%s/%s", MainFileName, tostring(game.PlaceId))) then 
        makefolder(string.format("%s/%s", MainFileName, tostring(game.PlaceId)))
    end
end

local Files = listfiles(string.format("%s/%s", "ShroomClient", tostring(game.PlaceId)))

-- functions
local function GetFiles()
    local out = {}
    for i = 1, #Files do
        local file = Files[i]
        if file:sub(-4) == '.lua' then
            local pos = file:find('.lua', 1, true)
            local start = pos
            local char = file:sub(pos, pos)
            while char ~= '/' and char ~= '\\' and char ~= '' do
                pos = pos - 1
                char = file:sub(pos, pos)
            end

            if char == '/' or char == '\\' then
                table.insert(out, file:sub(pos + 1, start - 1))
            end
        end
    end
    
    return out
end

local function UpdateFile(FileName)
    assert(FileName or FileName == "string", "oopsies");
    writefile(string.format("%s/%s/%s.lua", MainFileName, tostring(game.PlaceId), FileName), HttpService:JSONEncode(SilentAimSettings))
end

local function LoadFile(FileName)
    assert(FileName or FileName == "string", "oopsies");
    
    local File = string.format("%s/%s/%s.lua", MainFileName, tostring(game.PlaceId), FileName)
    local ConfigData = HttpService:JSONDecode(readfile(File))
    for Index, Value in next, ConfigData do
        SilentAimSettings[Index] = Value
    end
end

local function getPositionOnScreen(Vector)
    local Vec3, OnScreen = WorldToScreen(Camera, Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function ValidateArguments(Args, RayMethod)
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then
        return false
    end
    for Pos, Argument in next, Args do
        if typeof(Argument) == RayMethod.Args[Pos] then
            Matches = Matches + 1
        end
    end
    return Matches >= RayMethod.ArgCountRequired
end

local function getMousePosition()
    return GetMouseLocation(UserInputService)
end

-- ui creating & handling
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
Library:SetWatermark("discord.gg/mushroom")
Library.OutlineColor = Color3.fromRGB(49, 169, 246)
Library.AccentColor = Color3.fromRGB(49, 169, 246)
local Window = Library:CreateWindow({Title = 'Goober Client | Made By: swig5 | V1.0', Center = true, AutoShow = true, TabPadding = 8, MenuFadeTime = 0.2})

noclip = false

game:GetService('RunService').Stepped:connect(function()
    local Character = game.Players.LocalPlayer.Character
    if Character then
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
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
end)

-- PLAYER
local PlayerTab = Window:AddTab("Player")
local MainBOX = PlayerTab:AddLeftTabbox("Main") do
    local Main = MainBOX:AddTab("Main")
    Main:AddToggle("Phase", {Text = "Phase"}):OnChanged(function()
        noclip = Toggles.Phase.Value
    end)
    Main:AddToggle("AntiRagdoll", {Text = "Anti Ragdoll"}):OnChanged(function()
        local Player = game.Players.LocalPlayer
        local Character = Player.Character or Player.CharacterAdded:Wait()
        local Humanoid = Character:WaitForChild("Humanoid")
        if Toggles.AntiRagdoll.Value then
            game:GetService("RunService").Heartbeat:Connect(function()
                if Humanoid:GetState() == Enum.HumanoidStateType.Physics then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Seated)
                end
            end)
        else
            Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
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
    

    Main:AddToggle("AntiKB", {Text = "Anti Speed Modify", Tooltip = "Denys The Server To Move You"}):OnChanged(function()
        local UIS = game:GetService("UserInputService")
        local RunService = game:GetService("RunService")
        local HumanoidRootPart = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
        if Toggles.AntiKB.Value then
            RunService.Heartbeat:Connect(function()
                if not (UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Space)) then
                    HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                end
            end)
        else
            HumanoidRootPart.Velocity = HumanoidRootPart.Velocity
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
    local Main = ESPBox:AddTab("Player Visuals")
    Main:AddToggle("ESP", {Text = "ESP", Default = false}):AddColorPicker("ESPColor", {Default = Color3.fromRGB(255, 0, 4)}):OnChanged(function()
        local Players = game:GetService("Players")
        local function applyHighlight(player)
            local function onCharacterAdded(character)
                if not character:FindFirstChild("ESPHighlight") then
                    local highlight = Instance.new("Highlight", character)
                    highlight.Name = "ESPHighlight"
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.FillColor = Options.ESPColor.Value
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
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
                local highlight = player.Character:FindFirstChild("ESPHighlight")
                highlight:Destroy()
            end
        end

        if Toggles.ESP.Value then
            for _, player in pairs(Players:GetPlayers()) do
                applyHighlight(player)
            end
            Players.PlayerAdded:Connect(applyHighlight)
        else
            for _, player in pairs(Players:GetPlayers()) do
                removeHighlight(player)
            end
            Players.PlayerAdded:Connect(removeHighlight)
        end
    end)
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

-- CONFIG
local ConfigTab = Window:AddTab("Config")
local CreateConfigurationBOX = ConfigTab:AddLeftTabbox("Create Configuration") do 
    local Main = CreateConfigurationBOX:AddTab("Create Configuration")
    Main:AddInput("CreateConfigTextBox", {Default = "", Numeric = false, Finished = false, Text = "Create Configuration to Create", Tooltip = "Creates a configuration file containing settings you can save and load", Placeholder = "File Name here"}):OnChanged(function()
        if Options.CreateConfigTextBox.Value and string.len(Options.CreateConfigTextBox.Value) ~= "" then 
            FileToSave = Options.CreateConfigTextBox.Value
        end
    end)
    
    Main:AddButton("Create Configuration File", function()
        if FileToSave ~= "" or FileToSave ~= nil then 
            UpdateFile(FileToSave)
        end
    end)
end

local SaveConfigurationBOX = ConfigTab:AddLeftTabbox("Save Configuration") do 
    local Main = SaveConfigurationBOX:AddTab("Save Configuration")
    Main:AddDropdown("SaveConfigurationDropdown", {AllowNull = true, Values = GetFiles(), Text = "Choose Configuration to Save"})
    Main:AddButton("Save Configuration", function()
        if Options.SaveConfigurationDropdown.Value then 
            UpdateFile(Options.SaveConfigurationDropdown.Value)
        end
    end)
end

local LoadConfigurationBOX = ConfigTab:AddLeftTabbox("Load Configuration") do 
    local Main = LoadConfigurationBOX:AddTab("Load Configuration")
    
    Main:AddDropdown("LoadConfigurationDropdown", {AllowNull = true, Values = GetFiles(), Text = "Choose Configuration to Load"})
    Main:AddButton("Load Configuration", function()
        if table.find(GetFiles(), Options.LoadConfigurationDropdown.Value) then
            LoadFile(Options.LoadConfigurationDropdown.Value)
        end
    end)
end

-- HELP
local HelpTab = Window:AddTab("Help")
local CreditsBox = HelpTab:AddLeftTabbox("Credits") do
    local Main = CreditsBox:AddTab("Made By swig5")
end
local KeybindsBox = HelpTab:AddRightTabbox("Keybinds") do
    local Main = KeybindsBox:AddTab("Goober Client Keybinds")
    Main:AddLabel("Unload Client - Right ALT")
    Main:AddLabel("Hide GUI - Right CTRL")
end
local BugsBox = HelpTab:AddLeftTabbox("Bugs") do
    local Main = BugsBox:AddTab("Bugs That Are Being Fixed")
    Main:AddLabel("Doesn't unload properly")
    Main:AddLabel("Jump Fly Can't Turn Off")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightAlt and not gameProcessed then
        local Player = game:GetService('Players').LocalPlayer
        local Humanoid = Player.Character and Player.Character:FindFirstChildOfClass('Humanoid')
        
        -- Reset WalkSpeed
        if Humanoid then
            Humanoid.WalkSpeed = 16
        end
        
        -- Disconnect Jump connection if it exists
        if JumpConnection then
            JumpConnection:Disconnect()
            JumpConnection = nil
        end
        
        -- Disable ESP and remove highlights for all players
        if Toggles.ESP.Value then
            Toggles.ESP.Value = false
            for _, player in pairs(Players:GetPlayers()) do
                removeHighlight(player)
            end
            Players.PlayerAdded:Connect(function(player)
                removeHighlight(player)
            end)
        end

        -- Unload the library
        Library:Unload()
    end
end)

