-- INITIALIZE VERSION NUMBERS

print("Loading Goober Client...")

local ACEWARE_VERSION_NUMBER = "1.5.0"
local ACEWARE_VERSION_VNUM = "v" .. ACEWARE_VERSION_NUMBER
local ACEWARE_VERSION_LONG = "version " .. ACEWARE_VERSION_NUMBER

print("software Version: " .. ACEWARE_VERSION_NUMBER)
print("software Version 'vX.X.X':   " .. ACEWARE_VERSION_VNUM)
print("software Version 'version X.X.X':   " .. ACEWARE_VERSION_LONG)

-- INITIALIZE SERVICES AND LIBRARIES

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

-- INITIALIZE VARIABLES
    -- NAMING CONVENTION
        -- ALL_CAPITAL = Changeable Setting
        -- TitleCase   = Non-Changeable Setting
        -- camelCase   = Non-Setting

     -- GENERAL VARIABLES
    local camera = game.Workspace.CurrentCamera
    local localPlayer = Players.LocalPlayer
    local gameInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    local gameName = gameInfo.Name
    local humanoid = localPlayer.Character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        localPlayer.CharacterAdded:Wait()
        humanoid = localPlayer.Character:WaitForChild("Humanoid")
    end)
    local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")
    local defaultWalkspeed = humanoid.WalkSpeed

     -- AIMBOT VARIABLES
    local AIMBOT_ON = false
    local AIMBOT_FOV = 150
    local AIMBOT_SMOOTHING = 50
    local AIMBOT_FOV_COLOR = Color3.fromRGB(255, 255, 255)
    local AimbotBind = Enum.UserInputType.MouseButton2
    local aiming = false
    local target = nil
    local fovCircle = nil

    local RAGEAIM_ON = false

    -- ESP VARIABLES
    local BOX_ESP_COLOR = Color3.fromRGB(255, 255, 255)
    local SKELETON_ESP_COLOR = Color3.fromRGB(255, 255, 255)
    local CHAMS_COLOR = Color3.fromRGB(255, 255, 255)
    local TRACER_COLOR = Color3.fromRGB(255, 255, 255)
    local ESPBoxToggle = {Value = false}
    local ESPSkeletonToggle = {Value = false}
    local TRACERS_ON = false
    local CHAMS_ON = false
    local skeletonConnections = {}
    local skeletonDrawings = {}
    local boxDrawings = {}
    local highlightedCharacters = {}
    local tracerDrawings = {}
    local BOX_TEAM_COLOR = false
    local SKELETON_TEAM_COLOR = false

    -- FLIGHT VARIABLES
    local SFLY_ON = false
    local FLY_ON = false
    local FLY_SPEED = 50

    -- SPINBOT VARIABLES
    local horizSpinConnection
    local horizSpinAngle = 0

    local vertSpinConnection
    local vertSpinAngle = 0
    local originalY = humanoidRootPart.Position.Y
    
    -- BHOP VARIABLES
    local BHOP_ON = false

    -- RAGDOLL VARIABLES
    local RAGDOLL_ON = false

    -- WALKSPEED VARIABLES
    local IS_MODIFYING = false
    local WALKSPEED = defaultWalkspeed

    -- CAMLOCK VARIABLES
    local isLocked = false
    local CAMLOCK_ON = false

    -- COLOR FILTER VARIABLES
    local COLOR_FILTER_COLOR = Color3.fromRGB(255, 0, 255)
    local COLOR_FILTER_INTENSITY = 50

-- INITIALIZE FUNCTIONS

    function getClosestPlayer()
        local closest = nil
        if RAGEAIM_ON == false then
            local shortestDistance = math.huge
            local mousePos = UserInputService:GetMouseLocation()

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                    local screenPos, onScreen = camera:WorldToScreenPoint(player.Character.Head.Position)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        if distance < shortestDistance and distance <= AIMBOT_FOV then
                            closest = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        else
            local shortestDistance = math.huge
            local localPlayerPosition = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character.HumanoidRootPart.Position

            if localPlayerPosition then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local distance = (player.Character.HumanoidRootPart.Position - localPlayerPosition).Magnitude
                        if distance < shortestDistance then
                            closest = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end

        return closest
    end

    function getClosestAlivePlayerIn3DSpace()
        local closest = nil
        local shortestDistance = math.huge
        local localPlayerPosition = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character.HumanoidRootPart.Position

        if localPlayerPosition then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and isPlayerAlive(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - localPlayerPosition).Magnitude
                    if distance < shortestDistance then
                        closest = player
                        shortestDistance = distance
                    end
                end
            end
        end
        return closest
    end

    function isPlayerAlive(player)
        return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
    end


    local function lockCameraToNearestAlivePlayerHead()
        local nearestPlayer = getClosestAlivePlayerIn3DSpace()
        if nearestPlayer and nearestPlayer.Character and nearestPlayer.Character:FindFirstChild("Head") then
            local targetPosition = nearestPlayer.Character.Head.Position
            camera.CFrame = CFrame.new(camera.CFrame.Position, targetPosition)
        end
    end

    local function toggleCameraLock()
        if CAMLOCK_ON then
            isLocked = not isLocked
            if isLocked then
                camera.CameraType = Enum.CameraType.Scriptable
                RunService:BindToRenderStep("LockCamera", Enum.RenderPriority.Camera.Value, lockCameraToNearestAlivePlayerHead)
            else
                RunService:UnbindFromRenderStep("LockCamera")
                camera.CameraType = Enum.CameraType.Custom
            end
        end
    end



    local function createBone()
        local bone = Drawing.new("Line")
        bone.Visible = false
        bone.Color = SKELETON_ESP_COLOR
        bone.Thickness = 1
        bone.Transparency = 1
        return bone
    end

    local function updateBone(bone, from, to)
        bone.From = from
        bone.To = to
    end

    local function createSkeleton(player)
        local character = player.Character
        if not character then return end
        
        local bones = {
            createBone(), -- Head to Torso/UpperTorso
            createBone(), -- Torso/UpperTorso to LowerTorso (R15 only)
            createBone(), -- Torso/UpperTorso to LeftArm/LeftUpperArm
            createBone(), -- LeftArm/LeftUpperArm to LeftLowerArm (R15 only)
            createBone(), -- LeftLowerArm to LeftHand (R15 only)
            createBone(), -- Torso/UpperTorso to RightArm/RightUpperArm
            createBone(), -- RightArm/RightUpperArm to RightLowerArm (R15 only)
            createBone(), -- RightLowerArm to RightHand (R15 only)
            createBone(), -- Torso/LowerTorso to LeftLeg/LeftUpperLeg
            createBone(), -- LeftLeg/LeftUpperLeg to LeftLowerLeg (R15 only)
            createBone(), -- LeftLowerLeg to LeftFoot (R15 only)
            createBone(), -- Torso/LowerTorso to RightLeg/RightUpperLeg
            createBone(), -- RightLeg/RightUpperLeg to RightLowerLeg (R15 only)
            createBone(), -- RightLowerLeg to RightFoot (R15 only)
        }
        
        skeletonDrawings[player] = bones
        
        local function updateSkeleton()
            if not ESPSkeletonToggle.Value or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                for _, bone in ipairs(bones) do
                    bone.Visible = false
                end
                return
            end

            local function updateBonePositions(bone, part1, part2)
                if not part1 or not part2 then return end
                local p1, vis1 = camera:WorldToViewportPoint(part1.Position)
                local p2, vis2 = camera:WorldToViewportPoint(part2.Position)
                if vis1 and vis2 then
                    updateBone(bone, Vector2.new(p1.X, p1.Y), Vector2.new(p2.X, p2.Y))
                    bone.Visible = true
                else
                    bone.Visible = false
                end
            end

            local isR15 = character:FindFirstChild("UpperTorso") ~= nil
        
            if isR15 then
                updateBonePositions(bones[1], character:FindFirstChild("Head"), character:FindFirstChild("UpperTorso"))
                updateBonePositions(bones[2], character:FindFirstChild("UpperTorso"), character:FindFirstChild("LowerTorso"))
                updateBonePositions(bones[3], character:FindFirstChild("UpperTorso"), character:FindFirstChild("LeftUpperArm"))
                updateBonePositions(bones[4], character:FindFirstChild("LeftUpperArm"), character:FindFirstChild("LeftLowerArm"))
                updateBonePositions(bones[5], character:FindFirstChild("LeftLowerArm"), character:FindFirstChild("LeftHand"))
                updateBonePositions(bones[6], character:FindFirstChild("UpperTorso"), character:FindFirstChild("RightUpperArm"))
                updateBonePositions(bones[7], character:FindFirstChild("RightUpperArm"), character:FindFirstChild("RightLowerArm"))
                updateBonePositions(bones[8], character:FindFirstChild("RightLowerArm"), character:FindFirstChild("RightHand"))
                updateBonePositions(bones[9], character:FindFirstChild("LowerTorso"), character:FindFirstChild("LeftUpperLeg"))
                updateBonePositions(bones[10], character:FindFirstChild("LeftUpperLeg"), character:FindFirstChild("LeftLowerLeg"))
                updateBonePositions(bones[11], character:FindFirstChild("LeftLowerLeg"), character:FindFirstChild("LeftFoot"))
                updateBonePositions(bones[12], character:FindFirstChild("LowerTorso"), character:FindFirstChild("RightUpperLeg"))
                updateBonePositions(bones[13], character:FindFirstChild("RightUpperLeg"), character:FindFirstChild("RightLowerLeg"))
                updateBonePositions(bones[14], character:FindFirstChild("RightLowerLeg"), character:FindFirstChild("RightFoot"))
            else
                updateBonePositions(bones[1], character:FindFirstChild("Head"), character:FindFirstChild("Torso"))
                bones[2].Visible = false -- No UpperTorso to LowerTorso for R6
                updateBonePositions(bones[3], character:FindFirstChild("Torso"), character:FindFirstChild("Left Arm"))
                bones[4].Visible = false -- No LeftUpperArm to LeftLowerArm for R6
                bones[5].Visible = false -- No LeftLowerArm to LeftHand for R6
                updateBonePositions(bones[6], character:FindFirstChild("Torso"), character:FindFirstChild("Right Arm"))
                bones[7].Visible = false -- No RightUpperArm to RightLowerArm for R6
                bones[8].Visible = false -- No RightLowerArm to RightHand for R6
                updateBonePositions(bones[9], character:FindFirstChild("Torso"), character:FindFirstChild("Left Leg"))
                bones[10].Visible = false -- No LeftUpperLeg to LeftLowerLeg for R6
                bones[11].Visible = false -- No LeftLowerLeg to LeftFoot for R6
                updateBonePositions(bones[12], character:FindFirstChild("Torso"), character:FindFirstChild("Right Leg"))
                bones[13].Visible = false -- No RightUpperLeg to RightLowerLeg for R6
                bones[14].Visible = false -- No RightLowerLeg to RightFoot for R6
            end
            
            for _, bone in ipairs(bones) do
                if SKELETON_TEAM_COLOR == false then
                    bone.Color = SKELETON_ESP_COLOR
                else
                    bone.Color = player.TeamColor.Color
                end
            end
        end
        
        skeletonConnections[player] = game:GetService("RunService").RenderStepped:Connect(updateSkeleton)
    end



    local function createBox(player)
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = BOX_ESP_COLOR
        box.Thickness = 1
        box.Transparency = 1
        box.Filled = false
        boxDrawings[player] = box
        return box
    end

    local function updateBox(player, box)
        if not player or not player.Parent or not ESPBoxToggle.Value or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            box.Visible = false
            return
        end

        local rootPart = player.Character.HumanoidRootPart
        local head = player.Character:FindFirstChild("Head")
        if not head then
            box.Visible = false
            return
        end

        local rootPos, rootVis = camera:WorldToViewportPoint(rootPart.Position)
        if not rootVis then
            box.Visible = false
            return
        end

        local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))

        box.Size = Vector2.new(2350 / rootPos.Z, headPos.Y - legPos.Y)
        box.Position = Vector2.new(rootPos.X - box.Size.X / 2, rootPos.Y - box.Size.Y / 2)
        if BOX_TEAM_COLOR == false then
            box.Color = BOX_ESP_COLOR
        else
            box.Color = player.TeamColor.Color
        end
        box.Visible = true
    end

    local function createHighlight(character)
        local highlight = Instance.new("Highlight")
        highlight.FillColor = CHAMS_COLOR
        highlight.FillTransparency = 0
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = character
        highlight.Enabled = CHAMS_ON
        highlight.Parent = character
        highlightedCharacters[character] = highlight
    end

    local function updateHighlights()
        for character, highlight in pairs(highlightedCharacters) do
            highlight.Enabled = CHAMS_ON
            highlight.FillColor = CHAMS_COLOR
        end
    end

    local function createTracer()
        local line = Drawing.new("Line")
        line.Thickness = 1
        line.Color = TRACER_COLOR
        line.Visible = false
        return line
    end

    local function updateTracers()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local torso = player.Character.HumanoidRootPart
                local torsoPosition, onScreen = camera:WorldToViewportPoint(torso.Position)

                if onScreen then
                    local line = tracerDrawings[player]
                    if not line then
                        line = createTracer()
                        tracerDrawings[player] = line
                    end

                    line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                    line.To = Vector2.new(torsoPosition.X, torsoPosition.Y)
                    line.Visible = TRACERS_ON
                elseif tracerDrawings[player] then
                    tracerDrawings[player].Visible = false
                end
            elseif tracerDrawings[player] then
                tracerDrawings[player].Visible = false
            end
        end
    end

                

    local function onCharacterAdded(character, player)
        createSkeleton(player)
        createBox(player)
        createHighlight(character)
        
        local humanoid = character:WaitForChild("Humanoid", 10) -- Wait for the Humanoid to be added, with a timeout of 10 seconds
        if humanoid then
            humanoid.Died:Connect(function()
                if boxDrawings[player] then
                    boxDrawings[player].Visible = false
                    boxDrawings[player] = nil
                end
                if skeletonDrawings[player] then
                    skeletonDrawings[player].Visible = false
                    skeletonDrawings[player] = nil
                end
                if tracerDrawings[player] then
                    tracerDrawings[player].Visible = false
                    tracerDrawings[player] = nil
                end
            end)
        end
    end

    local function onPlayerAdded(player)
        if player ~= localPlayer then
            player.CharacterAdded:Connect(function(character)
                onCharacterAdded(character, player)
            end)
            if player.Character then
                onCharacterAdded(player.Character, player)
            end
        end
    end


    local function onPlayerRemoving(player)
        if skeletonConnections[player] then
            skeletonConnections[player]:Disconnect()
            skeletonConnections[player] = nil
        end
        if skeletonDrawings[player] then
            for _, bone in ipairs(skeletonDrawings[player]) do
                bone:Remove()
            end
            skeletonDrawings[player] = nil
        end
        if boxDrawings[player] then
            boxDrawings[player]:Remove()
            boxDrawings[player] = nil
        end
        if player.Character then
            local highlight = highlightedCharacters[player.Character]
            if highlight then
                highlight:Destroy()
                highlightedCharacters[player.Character] = nil
            end
        end
        if tracerDrawings[player] then
            tracerDrawings[player]:Remove()
            tracerDrawings[player] = nil
        end
    end


    local function spinhoriz(deltaTime)
        if type(SPIN_SPEED) ~= "number" then
            warn("SPIN_SPEED is not a number. Setting to default value of 10.")
            SPIN_SPEED = 10
        end

        horizSpinAngle = horizSpinAngle + math.rad(SPIN_SPEED)
        
        local currentPosition = humanoidRootPart.Position
        local lookVector = humanoidRootPart.CFrame.LookVector
        
        local newCFrame = CFrame.new(currentPosition, currentPosition + lookVector) * CFrame.Angles(0, horizSpinAngle, 0)
        
        humanoidRootPart.CFrame = newCFrame
    end

    local function spinvert(deltaTime)
        originalY = humanoidRootPart.Position.Y

        if type(SPIN_SPEED) ~= "number" then
            warn("SPIN_SPEED is not a number. Setting to default value of 10.")
            SPIN_SPEED = 10
        end

        vertSpinAngle = vertSpinAngle + math.rad(SPIN_SPEED * deltaTime * 60) -- Frame rate independence
        
        local currentPosition = humanoidRootPart.Position
        local lookVector = humanoidRootPart.CFrame.LookVector
        
        -- Create rotation CFrame
        local rotationCF = CFrame.Angles(vertSpinAngle, 0, 0)
        
        -- Apply rotation while preserving original height
        local newCFrame = CFrame.new(currentPosition.X, originalY, currentPosition.Z) * rotationCF
        
        -- Preserve look direction
        newCFrame = newCFrame * CFrame.new(Vector3.new(0, 0, -1), lookVector)
        
        humanoidRootPart.CFrame = newCFrame
    end

    local function checkForBhop()
        if localPlayer.Character then
            if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Running then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end

    local connection
    function fly(delta)
        local moveDirection = Vector3.new()
        local cameraCFrame = workspace.CurrentCamera.CFrame
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - cameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + cameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
        end
        
        humanoidRootPart.Velocity = moveDirection * 50
    end

    local flyForce
    local conn

    local originalGravity = workspace.Gravity

    local function startFlying()
        if flyForce then return end
        
        workspace.Gravity = 0
        
        flyForce = Instance.new("BodyVelocity")
        flyForce.Velocity = Vector3.new(0, 0, 0)
        flyForce.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        flyForce.Parent = humanoidRootPart
        
        humanoid:ChangeState(Enum.HumanoidStateType.Flying)
        
        conn = RunService.Heartbeat:Connect(function()
            local camera = workspace.CurrentCamera
            local lookVector = camera.CFrame.LookVector
            local rightVector = camera.CFrame.RightVector
            
            local moveDirection = Vector3.new(0, 0, 0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection = moveDirection + lookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection = moveDirection - lookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection = moveDirection - rightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection = moveDirection + rightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDirection = moveDirection + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDirection = moveDirection - Vector3.new(0, 1, 0)
            end
            
            if moveDirection.Magnitude > 0 then
                flyForce.Velocity = moveDirection.Unit * FLY_SPEED
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

    local function RemoveColorFilter()
        local existingFilter = Lighting:FindFirstChild("CustomColorFilter")
        if existingFilter then
            existingFilter:Destroy()
        end
    end

    local function ApplyColorFilter(color, intensity)
        RemoveColorFilter()

        local scale = intensity / 100
        local adjustedColor = Color3.new(color.R * scale, color.G * scale, color.B * scale)

        local colorCorrection = Instance.new("ColorCorrectionEffect")
        colorCorrection.Name = "CustomColorFilter"
        colorCorrection.TintColor = adjustedColor
        colorCorrection.Parent = Lighting
    end
-- INITIALIZE RAYFIELD

local Window = Rayfield:CreateWindow({
    Name = "Goober Client" .. ACEWARE_VERSION_VNUM,
    LoadingTitle = "software",
    LoadingSubtitle = ACEWARE_VERSION_LONG
})

-- TABS

local TabInfo = Window:CreateTab("info", 7733964719)
local TabAimbot = Window:CreateTab("aim", 7733765307)
local TabESP = Window:CreateTab("visuals", 7733774602)
local TabMovement = Window:CreateTab("movement", 7743870731)
local TabMisc = Window:CreateTab("misc", 7733993147)
local TabScriptHub = Window:CreateTab("other scripts", 7733954760)

-- ELEMENTS

     -- INFO ELEMENTS
    TabInfo:CreateParagraph({Title = "software version", Content = ACEWARE_VERSION_NUMBER})
    TabInfo:CreateParagraph({Title = "Executor", Content = identifyexecutor()})
    TabInfo:CreateParagraph({Title = "Game", Content = gameName})
    TabInfo:CreateParagraph({Title = "Game ID", Content = game.placeId})
    TabInfo:CreateParagraph({Title = "mintyhack cord ", Content = "discord.gg/emK5DUgZCs"})

    -- AIMBOT ELEMENTS
	TabAimbot:CreateSection("acs")
    TabAimbot:CreateToggle({
        Name = "gun modz",
        CurrentValue = false,
        Callback = function(Value)
            AIMBOT_ON = Value
        end
    })
	
    TabAimbot:CreateSection("Main")
    TabAimbot:CreateToggle({
        Name = "Aimbot Enabled",
        CurrentValue = false,
        Callback = function(Value)
            AIMBOT_ON = Value
        end
    })

    TabAimbot:CreateSlider({
        Name = "FOV Radius",
        Range = {10, 500},
        Increment = 1,
        Suffix = "px",
        CurrentValue = 150,
        Callback = function(Value)
            AIMBOT_FOV = Value
        end,
    })

    TabAimbot:CreateSlider({
        Name = "Smoothing",
        Range = {0, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = 50,
        Callback = function(Value)
            AIMBOT_SMOOTHING = Value
        end,
    })

    TabAimbot:CreateToggle({
        Name = "Rageaim Enabled",
        CurrentValue = false,
        Callback = function(Value)
            RAGEAIM_ON = Value
        end
    })

    TabAimbot:CreateSection("Appearance")    

    TabAimbot:CreateToggle({
        Name = "Show FOV",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                fovCircle = Drawing.new("Circle")
                fovCircle.Visible = true
                fovCircle.Color = AIMBOT_FOV_COLOR
                fovCircle.Thickness = 1
                fovCircle.NumSides = 64
                fovCircle.Radius = AIMBOT_FOV
                fovCircle.Filled = false
                fovCircle.Transparency = 1
            else
                if fovCircle then
                    fovCircle:Remove()
                    fovCircle = nil
                end
            end
        end
    })

    TabAimbot:CreateColorPicker({
        Name = "FOV Circle Color",
        Color = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            AIMBOT_FOV_COLOR = Value
        end
    })

    -- ESP ELEMENTS
    TabESP:CreateSection("Box ESP")
    TabESP:CreateToggle({
        Name = "Box ESP Enabled",
        CurrentValue = false,
        Callback = function(Value)
            ESPBoxToggle.Value = Value
        end
    })
    TabESP:CreateColorPicker({
        Name = "Box ESP Color",
        Color = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            BOX_ESP_COLOR = Value
        end
    })
    TabESP:CreateToggle({
        Name = "Use Team Color",
        CurrentValue = false,
        Callback = function(Value)
            BOX_TEAM_COLOR = Value
        end
    })

    TabESP:CreateSection("Skeleton ESP")
    TabESP:CreateToggle({
        Name = "Skeleton ESP Enabled",
        CurrentValue = false,
        Callback = function(Value)
            ESPSkeletonToggle.Value = Value
        end
    })
    TabESP:CreateColorPicker({
        Name = "Skeleton ESP Color",
        Color = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            SKELETON_ESP_COLOR = Value
        end
    })
    TabESP:CreateToggle({
        Name = "Use Team Color",
        CurrentValue = false,
        Callback = function(Value)
            SKELETON_TEAM_COLOR = Value
        end
    })

    TabESP:CreateSection("Chams")
    TabESP:CreateToggle({
        Name = "Chams Enabled",
        CurrentValue = false,
        Callback = function(Value)
            CHAMS_ON = Value
            updateHighlights()
        end
    })
    TabESP:CreateColorPicker({
        Name = "Chams Color",
        Color = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            CHAMS_COLOR = Value
            updateHighlights()
        end
    })

    TabESP:CreateSection("Tracers")
    TabESP:CreateToggle({
        Name = "Tracers Enabled",
        CurrentValue = false,
        Callback = function(Value)
            TRACERS_ON = Value
            for _, line in pairs(tracerDrawings) do
                line.Visible = not line.Visible
            end
        end
    })
    TabESP:CreateColorPicker({
        Name = "Tracer Color",
        Color = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
            TRACER_COLOR = Value
            for _, line in pairs(tracerDrawings) do
                line.Color = TRACER_COLOR
            end
        end
    })


    -- MOVEMENT ELEMENTS
    TabMovement:CreateSection("Flight")
    TabMovement:CreateToggle({
        Name = "Fly Enabled",
        CurrentValue = false,
        Callback = function(Value)
            FLY_ON = Value
            if FLY_ON == true then
                startFlying()
            else
                stopFlying()
            end
        end
    })
    TabMovement:CreateSlider({
        Name = "Flight Speed",
        Range = {0, 150},
        Increment = 1,
        CurrentValue = 50,
        Callback = function(Value)
            FLY_SPEED = Value
        end,
    })
    TabMovement:CreateToggle({
        Name = "Swim Fly Enabled",
        CurrentValue = false,
        Callback = function(Value)
            SFLY_ON = Value
            if SFLY_ON then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
                
                connection = RunService.Heartbeat:Connect(fly)
            else
                if connection then
                    connection:Disconnect()
                end
                
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    })
    

    TabMovement:CreateSection("Spinbot")
    TabMovement:CreateToggle({
        Name = "Horizontal Spinbot",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                if not horizSpinConnection then
                    horizSpinConnection = game:GetService("RunService").Heartbeat:Connect(spinhoriz)
                end
            else
                if horizSpinConnection then
                    horizSpinConnection:Disconnect()
                    horizSpinConnection = nil
                end
                horizSpinAngle = 0
            end
        end
    })
    TabMovement:CreateToggle({
        Name = "Vertical Spinbot",
        CurrentValue = false,
        Callback = function(Value)
            if Value then
                if not vertSpinConnection then
                    vertSpinConnection = game:GetService("RunService").Heartbeat:Connect(spinvert)
                end
            else
                if vertSpinConnection then
                    vertSpinConnection:Disconnect()
                    vertSpinConnection = nil
                end
                vertSpinAngle = 0
            end
        end
    })

    TabMovement:CreateSection("BHop")

    TabMovement:CreateToggle({
        Name = "BHop Enabled",
        CurrentValue = false,
        Callback = function(Value)
            BHOP_ON = Value
        end
    })

    TabMovement:CreateSection("Walkspeed Modifier")

    TabMovement:CreateToggle({
        Name = "Modify Speed",
        CurrentValue = false,
        Callback = function(Value)
            if Value == true then
                IS_MODIFYING = true
                humanoid.WalkSpeed = WALKSPEED
            else
                IS_MODIFYING = false
                humanoid.WalkSpeed = defaultWalkspeed
            end
        end
    })

    TabMovement:CreateSlider({
        Name = "Walkspeed",
        Range = {0, 250},
        Increment = 1,
        CurrentValue = 30,
        Callback = function(Value)
            WALKSPEED = Value
            if IS_MODIFYING then
                humanoid.WalkSpeed = Value
            end
        end,
    })

    -- MISC ELEMENTS
    TabMisc:CreateSection("Ragdoll")
    TabMisc:CreateToggle({
        Name = "Ragdoll",
        CurrentValue = false,
        Callback = function(Value)
            RAGDOLL_ON = Value
            if RAGDOLL_ON then
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
                humanoid:ChangeState(Enum.HumanoidStateType.Ragdoll)
            else
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, true)
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    })

    TabMisc:CreateSection("Chat Logger")
    TabMisc:CreateButton({
    Name = "Start Logger",
    Callback = function()
        local LogFile = "ChatLog_" .. os.date("%Y-%m-%d") .. ".txt"

        local function LogChat(player, message)
            local timestamp = os.date("%H:%M:%S")
            local logMessage = string.format("[%s] %s: %s\n", timestamp, player.Name, message)
            appendfile(LogFile, logMessage)
        end

        for _, player in ipairs(Players:GetPlayers()) do
            player.Chatted:Connect(function(message)
                LogChat(player, message)
            end)
        end

        Players.PlayerAdded:Connect(function(player)
            player.Chatted:Connect(function(message)
                LogChat(player, message)
            end)
        end)

        Rayfield:Notify({
            Title = "Chat Logger Started",
            Content = "Log will be saved to " .. LogFile,
            Duration = 5,
            Image = 18540617874,
            Actions = {
                Ignore = {
                    Name = "Close",
                }
            }
        })
    end
})

    TabMisc:CreateSection("Camera Lock")
    TabMisc:CreateParagraph({ Title="Instructions", Content="Enable with the toggle, then use the keybind to use and stop using. It will lock to the nearest player."} )
    TabMisc:CreateToggle({
        Name = "Enable Camera Lock",
        CurrentValue = false,
        Callback = function(Value)
            CAMLOCK_ON = Value
        end
    })
    TabMisc:CreateKeybind({
        Name = "Camera Lock Toggle Keybind",
        CurrentKeybind = "H",
        HoldToInteract = false,
        Callback = function()
            toggleCameraLock()
        end
    })

    TabMisc:CreateSection("Color Filter")
    TabMisc:CreateToggle({
        Name = "Enable Color Filters",
        CurrentValue = false,
        Callback = function(Value)
            if Value == true then
                ApplyColorFilter(COLOR_FILTER_COLOR, COLOR_FILTER_INTENSITY)
            else
                RemoveColorFilter()
            end
        end
    })
    TabMisc:CreateColorPicker({
        Name = "Color",
        Color = Color3.fromRGB(255, 0, 255),
        Callback = function(Value)
            COLOR_FILTER_COLOR = Value
            RemoveColorFilter()
            ApplyColorFilter(COLOR_FILTER_COLOR, COLOR_FILTER_INTENSITY)
        end
    })
    TabMisc:CreateSlider({
        Name = "Brightness",
        Range = {0, 100},
        Increment = 1,
        Suffix = "%",
        CurrentValue = 50,
        Callback = function(Value)
            COLOR_FILTER_INTENSITY = Value
            RemoveColorFilter()
            ApplyColorFilter(COLOR_FILTER_COLOR, COLOR_FILTER_INTENSITY)
        end
    })

    TabScriptHub:CreateSection("Infinite Yield")
    TabScriptHub:CreateParagraph({
        Title = "Infinite Yield by Edge",
        Content = "Infinite Yield is a popular Roblox script that provides users with a range of commands. It allows users to fly, noclip, and more."
    })
    TabScriptHub:CreateButton({
        Name = "Execute",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end
    })

    TabScriptHub:CreateSection("Orca")
    TabScriptHub:CreateParagraph({
        Title = "Orca by richie0866",
        Content = "Orca is a beautiful general-purpose script hub that provides users with both scripts and toggles for things like flight, walkspeed, and jump height."
    })
    TabScriptHub:CreateButton({
        Name = "Execute",
        Callback = function()
            loadstring(
                game:HttpGetAsync("https://raw.githubusercontent.com/richie0866/orca/master/public/latest.lua")
            )()
        end
    })

    TabScriptHub:CreateSection("Dex Explorer")
    TabScriptHub:CreateParagraph({
        Title = "Dex by LorekeeperZinnia",
        Content = "Dex is a popular tool that allows users to view and manipulate objects, scripts, and properties."
    })
    TabScriptHub:CreateButton({
        Name = "Execute",
        Callback = function()
            loadstring(
                loadstring(game:GetObjects("rbxassetid://418957341")[1].Source)()
            )()
        end
    })

    TabScriptHub:CreateSection("VG Hub")
    TabScriptHub:CreateParagraph({
        Title = "VG Hub by 1201for",
        Content = "VG Hub is a script hub that provides game-specific cheats for over 140 games."
    })
    TabScriptHub:CreateButton({
        Name = "Execute",
        Callback = function()
            loadstring(
                loadstring(game:HttpGet("https://raw.githubusercontent.com/1201for/V.G-Hub/main/V.Ghub"))()
            )()
        end
    })

-- CONNECT FUNCTIONS TO SERVICES

local inputBeganConnection
local inputEndedConnection
local renderSteppedConnection

local function setupConnections()
    inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == AimbotBind then
            aiming = true
        end
    end)

    inputEndedConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == AimbotBind then
            aiming = false
        end
    end)

    renderSteppedConnection = RunService.RenderStepped:Connect(function()
        if AIMBOT_ON and aiming then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local targetPos = target.Character.Head.Position
                local cameraPos = camera.CFrame.Position
                local newCFrame = CFrame.new(cameraPos, targetPos)
                
                local smoothFactor = math.clamp(1 - (AIMBOT_SMOOTHING / 100), 0.01, 1)
                camera.CFrame = camera.CFrame:Lerp(newCFrame, smoothFactor)
            end
        end

        if fovCircle and fovCircle.Visible then
            fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
            fovCircle.Radius = AIMBOT_FOV
            fovCircle.Color = AIMBOT_FOV_COLOR            
        end

        if BHOP_ON then
            checkForBhop()
        end
    end)
end

-- ESP Connections
    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)

    for _, player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end

    RunService.RenderStepped:Connect(function()
        for player, box in pairs(boxDrawings) do
            updateBox(player, box)
        end

        updateTracers()
    end)

setupConnections()

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- FINISH LOADING
print("software " .. ACEWARE_VERSION_VNUM .. " loaded!")

Rayfield:Notify({
    Title = "Goober Client! [ " .. ACEWARE_VERSION_VNUM .. " ]",
    Content = "Script Loaded!",
    Duration = 5,
    Image = 18540617874,
    Actions = {
        Ignore = {
            Name = "Close",
        }
    }
})