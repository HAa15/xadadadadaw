-- Configuration
 

-- Load essential services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Keybind Handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Convert input to key name
    local keyPressed = input.KeyCode.Name
    
    -- Silent Aim Toggle
    if keyPressed == Config.SilentAim.Keybind then
        Config.SilentAim.Enabled = not Config.SilentAim.Enabled
        notify("Silent Aim", Config.SilentAim.Enabled and "Enabled" or "Disabled")
    end
    
    -- Combat Keybinds
    if keyPressed == Config.Combat.KillAuraKeybind then
        Config.Combat.KillAura = not Config.Combat.KillAura
        notify("Kill Aura", Config.Combat.KillAura and "Enabled" or "Disabled")
    end
    
    -- Movement Keybinds
    if keyPressed == Config.Movement.Fly.Keybind then
        Config.Movement.Fly.Enabled = not Config.Movement.Fly.Enabled
        notify("Flight", Config.Movement.Fly.Enabled and "Enabled" or "Disabled")
    end
    
    -- Visual Keybinds
    if keyPressed == Config.Visuals.ESP.Keybind then
        Config.Visuals.ESP.Enabled = not Config.Visuals.ESP.Enabled
        notify("ESP", Config.Visuals.ESP.Enabled and "Enabled" or "Disabled")
    end
    
    -- Safety Keybinds
    if keyPressed == Config.Safety.AntiStomp.Keybind then
        Config.Safety.AntiStomp.Enabled = not Config.Safety.AntiStomp.Enabled
        notify("Anti Stomp", Config.Safety.AntiStomp.Enabled and "Enabled" or "Disabled")
    end
end)

-- Notification Function
function notify(title, message, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Notification",
        Text = message,
        Duration = duration or 3,
        Icon = "rbxassetid://6031071053" -- You can change this to any icon ID
    })
end

-- Initialize Features
do
    -- Start necessary loops and connections
    RunService.Heartbeat:Connect(function()
        if Config.Combat.KillAura then
            performKillAura()
        end
        
        if Config.Movement.Fly.Enabled then
            updateFly()
        end
        
        if Config.Visuals.ESP.Enabled then
            updateESP()
        end
    end)
    
    -- Set up character connections
    LocalPlayer.CharacterAdded:Connect(function(character)
        setupCharacterConnections(character)
    end)
    
    if LocalPlayer.Character then
        setupCharacterConnections(LocalPlayer.Character)
    end
end

-- The rest of your existing feature implementations would remain the same,
-- just modified to use the new Config structure instead of the UI elements 

    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    function onPlayerChatted(player, message)
        if player.Name == ownerName and player ~= LocalPlayer and message:sub(1, #commandPrefix) == commandPrefix then
            local sayMessage = message:sub(#commandPrefix + 1)
            LocalPlayer:Chat(sayMessage)
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        player.Chatted:Connect(function(message)
            onPlayerChatted(player, message)
        end)
    end

    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message)
            onPlayerChatted(player, message)
        end)
    end)

    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TeleportService = game:GetService("TeleportService")
    local CurrentCamera = workspace.CurrentCamera

    function findPlayerByName(partialName)
        if not partialName or partialName == "" then
            return nil
        end
        local match
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name:lower():sub(1, #partialName) == partialName:lower() or 
            player.DisplayName:lower():sub(1, #partialName) == partialName:lower() then
                match = player
                break
            end
        end
        return match
    end

    function stompPlayer(targetPlayer)
        if not targetPlayer then return end
        local targetCharacter = targetPlayer.Character
        if targetCharacter and targetCharacter:FindFirstChild("UpperTorso") then
            local torso = targetCharacter:FindFirstChild("UpperTorso")
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character:SetPrimaryPartCFrame(torso.CFrame)
                
                for i = 1, 10 do
                    task.wait(0.2)
                    ReplicatedStorage.MainEvent:FireServer("Stomp")
                end
            end
        end
    end

    LocalPlayer.Chatted:Connect(function(message)
        local command, targetName = message:match("$(%w+)%s*(.*)")
        if command then
            command = command:lower()
        end
        if targetName then
            targetName = targetName:lower()
        end
        
        if command and targetName and #targetName >= 2 then
            local targetPlayer = findPlayerByName(targetName)
            
            if command == "goto" and targetPlayer then
                local targetCharacter = targetPlayer.Character
                if targetCharacter and targetCharacter.PrimaryPart then
                    local offset = targetCharacter.PrimaryPart.CFrame.LookVector * -10
                    LocalPlayer.Character:SetPrimaryPartCFrame(targetCharacter.PrimaryPart.CFrame + offset)
                end
            elseif command == "view" and targetPlayer then
                local targetCharacter = targetPlayer.Character
                if targetCharacter and targetCharacter.PrimaryPart then
                    CurrentCamera.CameraSubject = targetCharacter.PrimaryPart
                end
            elseif command == "unview" then
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
                end
            elseif command == "stomp" and targetPlayer then
                stompPlayer(targetPlayer)
            elseif not targetPlayer then
                game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                    Text = "Player not found!";
                    Color = Color3.new(1, 0, 0);
                    Font = Enum.Font.SourceSansBold;
                })
            end
        elseif command == "unview" then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                CurrentCamera.CameraSubject = LocalPlayer.Character:FindFirstChild("Humanoid")
            end
        elseif command == "rejoin" then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)

    local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

    local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
    local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
    local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

    local Window = Library:CreateWindow({

        Title = 'Patchmade (HVH) | Private | @florsas3x',
        Center = false,
        AutoShow = true,
        TabPadding = 8,
        MenuFadeTime = 0.2
    })


    local Tabs = {

        Rage = Window:AddTab('Main'),
        Misc = Window:AddTab('Misc'),
        Players = Window:AddTab('Players'),
        Visuals = Window:AddTab('Visuals'),
        ['UI Settings'] = Window:AddTab('UI Settings'),
    }

    getgenv().Settings = {
        SilentAim = {
            HitPart = "Head",
            Bind = "C",
            Enabled = false
        },

        KillAura = false,
        AutoShoot = false,
        Ragebait = true,
        Tracer = true,
        LookAt = false,
        ViewTarget = false,

        KOCheck = false,
        CrewCheck = false,

        AutoUnlock = false,
        FriendCheck = false,
        ForceFieldCheck = false,

        Highlight = {
            Enabled = true,
            FillColor = Color3.fromRGB(229, 229, 229),
            OutlineColor = Color3.fromRGB(99, 255, 184),
            FillTransparency = 0.4,
            OutlineTransparency = 0,
            VisibleOnly = false
        },

        FieldOfView = {
            Visible = true,
            Radius = 145,
            Filled = false,
            Transparency = 0.5,
            Color = Color3.fromRGB(255, 255, 255)
        },

        Rage = {
            KillAuraRange = 15
        },

        allahuakbar = {
            "why aim when Loss . cc does it for you?", "try getting a Loss. cc invite next time", "1 tapped xd", "Loss. cc Kill ALL ✅✅", "99-0", "outplayed"
        }
    }

    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local Camera = game:GetService("Workspace").CurrentCamera
    local Target = nil
    local RapidFireEnabled = false
    local LockedTarget = nil

    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))

    local TargetInfoFrame = Instance.new("Frame", ScreenGui)
    local TargetInfoOutline = Instance.new("Frame", TargetInfoFrame)
    local TargetNameLabel = Instance.new("TextLabel", TargetInfoFrame)
    local AvatarImage = Instance.new("ImageLabel", TargetInfoFrame)
    local HealthBarFrame = Instance.new("Frame", TargetInfoFrame)
    local HealthBar = Instance.new("Frame", HealthBarFrame)
    local HealthIcon = Instance.new("TextLabel", TargetInfoFrame)

    ScreenGui.ResetOnSpawn = false

    TargetInfoFrame.Size = UDim2.new(0, 300, 0, 80)
    TargetInfoFrame.Position = UDim2.new(0.5, 0, 0.75, 0)
    TargetInfoFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    TargetInfoFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TargetInfoFrame.BorderSizePixel = 2

    TargetInfoOutline.Size = UDim2.new(1, 4, 1, 4)
    TargetInfoOutline.Position = UDim2.new(0, -2, 0, -2)
    TargetInfoOutline.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    TargetInfoOutline.BorderSizePixel = 0
    TargetInfoOutline.ZIndex = -1
    TargetInfoOutline.Parent = TargetInfoFrame

    TargetNameLabel.Size = UDim2.new(1, -80, 0, 25)
    TargetNameLabel.Position = UDim2.new(0, 70, 0, 10)
    TargetNameLabel.BackgroundTransparency = 1
    TargetNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TargetNameLabel.TextScaled = true
    TargetNameLabel.Font = Enum.Font.GothamBold
    TargetNameLabel.Text = "Target"
    TargetNameLabel.TextXAlignment = Enum.TextXAlignment.Left

    AvatarImage.Size = UDim2.new(0, 50, 0, 50)
    AvatarImage.Position = UDim2.new(0, 10, 0.5, 0)
    AvatarImage.AnchorPoint = Vector2.new(0, 0.5)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"

    HealthIcon.Size = UDim2.new(0, 20, 0, 20)
    HealthIcon.Position = UDim2.new(0, 70, 0, 40)
    HealthIcon.BackgroundTransparency = 1
    HealthIcon.Text = "❤️"
    HealthIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    HealthIcon.TextScaled = true
    HealthIcon.Font = Enum.Font.GothamBold

    HealthBarFrame.Size = UDim2.new(0, 200, 0, 10)
    HealthBarFrame.Position = UDim2.new(0, 100, 0, 45)
    HealthBarFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    HealthBarFrame.BorderSizePixel = 2

    HealthBar.Size = UDim2.new(1, 0, 1, 0)
    HealthBar.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    HealthBar.BorderSizePixel = 0

    function GetAvatarImage(userId)
        return game.Players:GetUserThumbnailAsync(
            userId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
    end

    local CurrentTarget

    function UpdateTargetInfo()
        if LockedTarget and LockedTarget.Parent and LockedTarget ~= CurrentTarget then
            CurrentTarget = LockedTarget

            local targetPlayer = game:GetService("Players"):GetPlayerFromCharacter(LockedTarget.Parent)
            if targetPlayer then
                TargetNameLabel.Text = targetPlayer.Name
                TargetInfoFrame.Visible = true

                local success, avatarImage = pcall(function()
                    return GetAvatarImage(targetPlayer.UserId)
                end)
                if success then
                    AvatarImage.Image = avatarImage
                else
                    AvatarImage.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
                end

                local targetHumanoid = LockedTarget.Parent:FindFirstChild("Humanoid")
                if targetHumanoid then
                    local healthPercent = math.clamp(targetHumanoid.Health / targetHumanoid.MaxHealth, 0, 1)
                    HealthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
                end
            end
        elseif not LockedTarget or not LockedTarget.Parent then
            CurrentTarget = nil
            TargetInfoFrame.Visible = false
        end
    end

    game:GetService("RunService").RenderStepped:Connect(UpdateTargetInfo)

    function GetCrew(player)
        local dataFolder = player:FindFirstChild("DataFolder")
        if dataFolder then
            local info = dataFolder:FindFirstChild("Information")
            if info then
                return info:FindFirstChild("Crew")
            end
        end
        return nil
    end

    function IsInSameCrew(player)
        if not getgenv().Settings.CrewCheck then return false end
        local localCrew = GetCrew(game.Players.LocalPlayer)
        local targetCrew = GetCrew(player)

        return localCrew and targetCrew and localCrew.Value == targetCrew.Value
    end

    function IsKO(player)
        if not getgenv().Settings.KOCheck then return false end
        local playerEffects = workspace.Players:FindFirstChild(player.Name)
            and workspace.Players[player.Name]:FindFirstChild("BodyEffects")
        local koValue = playerEffects and playerEffects:FindFirstChild("K.O")
        return koValue and koValue.Value == true
    end

    function UnlockIfKO(targetPlayer)
        if not targetPlayer then return end
        local isKnocked = IsKO(targetPlayer)
        if isKnocked then
            Target = nil
            LockedTarget = nil
            UpdateTargetInfo()
        end
    end

    function IsFriendWithLocalPlayer(targetPlayer)
        if not getgenv().Settings.FriendCheck then return false end
        return game.Players.LocalPlayer:IsFriendsWith(targetPlayer.UserId)
    end

    function HasForceField(player)
        if not getgenv().Settings.ForceFieldCheck then return false end
        local character = player.Character
        return character and character:FindFirstChildOfClass("ForceField") ~= nil
    end

    function IsValidTarget(player)
        if not player.Character then return false end
        if player == game.Players.LocalPlayer then return false end
        if IsInSameCrew(player) then return false end
        if IsFriendWithLocalPlayer(player) then return false end
        if HasForceField(player) then return false end
        if IsKO(player) then return false end
        local humanoid = player.Character:FindFirstChild("Humanoid")
        return humanoid and humanoid.Health > 0
    end

    function GetClosestTargetToCursor()
        local mousePosition = game:GetService("UserInputService"):GetMouseLocation()
        local closestPlayer = nil
        local closestDistance = math.huge

        for _, player in ipairs(game.Players:GetPlayers()) do
            if IsValidTarget(player) then
                local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    local worldPoint = humanoidRootPart.Position
                    local screenPoint, onScreen = workspace.CurrentCamera:WorldToScreenPoint(worldPoint)
                    if onScreen then
                        local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePosition).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPlayer = player
                        end
                    end
                end
            end
        end

        return closestPlayer
    end

    function LockOntoTarget()
        if getgenv().Settings.SilentAim.Enabled then
            local closestPlayer = GetClosestTargetToCursor()
            if closestPlayer and closestPlayer.Character then
                LockedTarget = closestPlayer.Character:FindFirstChild(getgenv().Settings.SilentAim.HitPart)
                print("Locked onto target: " .. closestPlayer.Name)
                UpdateTargetInfo()
            else
                LockedTarget = nil
                UpdateTargetInfo()
            end
        else
            LockedTarget = nil
            UpdateTargetInfo()
        end
    end

    -- Modify the ShootTarget function to support PSilent
    function ShootTarget(Target)
        if Target then
            local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if Tool and Tool:FindFirstChild("Handle") then
                -- Get target position
                local targetPos = Target.Position
                local handlePos = Tool.Handle.Position
                
                -- Create multiple shot positions for better penetration
                local shotPositions = {
                    handlePos,  -- Original gun position
                    targetPos + Vector3.new(0, 0.5, 0),  -- Slightly above target
                    targetPos + Vector3.new(0, -0.5, 0), -- Slightly below target
                }
                
                -- Fire from each position
                for _, pos in ipairs(shotPositions) do
                    game:GetService("ReplicatedStorage").MainEvent:FireServer(
                        "ShootGun",
                        Tool.Handle,
                        pos,
                        targetPos,
                        Target,
                        Vector3.new(0, 0, 0)  -- No spread
                    )
                end
            end
        end
    end
    function DrawTracer(startPos, endPos)
        local beam = Instance.new("Beam")
        beam.FaceCamera = true
        beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        beam.Width0 = 0.1
        beam.Width1 = 0.1

        local attachment0 = Instance.new("Attachment", LocalPlayer.Character.Head)
        attachment0.WorldPosition = startPos
        beam.Attachment0 = attachment0

        local attachment1 = Instance.new("Attachment", workspace.Terrain)
        attachment1.WorldPosition = endPos
        beam.Attachment1 = attachment1

        beam.Parent = LocalPlayer.Character.Head
        task.wait(0.03)
        beam:Destroy()
    end
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
            if getgenv().Settings.SilentAim.Enabled and LockedTarget then
                ShootTarget(LockedTarget)
            end
        end
    end)

    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode[getgenv().Settings.SilentAim.Bind] then
                getgenv().Settings.SilentAim.Enabled = not getgenv().Settings.SilentAim.Enabled
                if not getgenv().Settings.SilentAim.Enabled then
                    LockedTarget = nil
                else
                    LockOntoTarget()
                end
                UpdateTargetInfo()
            elseif input.KeyCode == getgenv().Settings.KOCheckKeybind then
                getgenv().Settings.KOCheck = not getgenv().Settings.KOCheck
                StarterGui:SetCore("SendNotification", {
                    Title = "K.O. Check",
                    Text = "K.O. Check: " .. (getgenv().Settings.KOCheck and "Enabled" or "Disabled"),
                    Duration = 3
                })
            end
        end
    end)

    game:GetService("RunService").Stepped:Connect(function()
        if getgenv().Settings.KillAura then
            local closestTarget = nil
            local closestDistance = math.huge
            local localCharacter = LocalPlayer.Character
            local localRootPart = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

            if localRootPart then
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if IsValidTarget(player) then
                        local humanoid = player.Character:FindFirstChild("Humanoid")
                        local head = player.Character:FindFirstChild("Head")

                        if humanoid and humanoid.Health > 0 and head then
                            local distance = (head.Position - localRootPart.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestTarget = {player = player, part = head}
                            end
                        end
                    end
                end
            end

            if closestTarget then
                UnlockIfKO(closestTarget.player)
                if getgenv().Settings.AutoShoot then
                    ShootTarget(closestTarget.part)
                end
            end
        elseif LockedTarget and getgenv().Settings.AutoShoot then
            UnlockIfKO(game.Players:GetPlayerFromCharacter(LockedTarget.Parent))
            ShootTarget(LockedTarget)
        end
    end)


    local RageGroupBox = Tabs.Rage:AddLeftGroupbox('Silent Aim')

    RageGroupBox:AddToggle('SilentAimToggle', {
        Text = 'PSilent',
        Default = false,
        Callback = function(Value)
            getgenv().Settings.SilentAim.Enabled = Value
        end
    })

    RageGroupBox:AddLabel('Keybind'):AddKeyPicker('SilentAimKeybind', {
        Default = 'C',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Silent Aim',
        NoUI = false,
        ChangedCallback = function(New)
            getgenv().Settings.SilentAim.Bind = New.Name
        end
    })

    RageGroupBox:AddDropdown('HitPartDropdown', {
        Values = {"Head", "UpperTorso", "LowerTorso"},
        Default = "Head",
        Text = 'Hit Part',
        Callback = function(Value)
            getgenv().Settings.SilentAim.HitPart = Value
        end
    })

    RageGroupBox:AddToggle('LookAtToggle', {
        Text = 'Look At Target',
        Default = false,
        Callback = function(Value)
            getgenv().Settings.LookAt = Value
        end
    })

    -- Find the ViewTargetToggle section and replace it with:
    RageGroupBox:AddToggle('ViewTargetToggle', {
        Text = 'spectate ',
        Default = false,
        Callback = function(Value)
            getgenv().Settings.ViewTarget = Value
            
            -- Create a loop to handle spectating
            if Value then
                task.spawn(function()
                    while getgenv().Settings.ViewTarget and task.wait() do
                        if LockedTarget and LockedTarget.Parent then
                            -- Get the humanoid of the target
                            local targetHumanoid = LockedTarget.Parent:FindFirstChild("Humanoid")
                            if targetHumanoid then
                                workspace.CurrentCamera.CameraSubject = targetHumanoid
                            end
                        else
                            -- If no target or target is invalid, reset camera to local player
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                                workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
                            end
                        end
                    end
                end)
            else
                -- Reset camera when disabled
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
                end
            end
        end
    })
    local KillAuraGroupBox = Tabs.Rage:AddLeftGroupbox('Kill Aura')

    KillAuraGroupBox:AddToggle('KillAuraToggle', {
        Text = 'Kill Aura',
        Default = false,
        Callback = function(Value)
            getgenv().Settings.KillAura = Value
        end
    })

    KillAuraGroupBox:AddSlider('KillAuraRangeSlider', {
        Text = 'Kill Aura Range',
        Default = 15,
        Min = 1,
        Max = 500,
        Rounding = 0,
        Callback = function(Value)
            getgenv().Settings.KillAuraRange = Value
        end
    })

    KillAuraGroupBox:AddToggle('AutoShootToggle', {
        Text = 'Auto Shoot',
        Default = false,
        Callback = function(Value)
            getgenv().Settings.AutoShoot = Value
        end
    })

    KillAuraGroupBox:AddToggle('StompWhenKnockedToggle', {
        Text = 'remove on death',
        Default = false,
        Callback = function(Value)
            getgenv().StompSettings.StompWhenKnocked = Value
        end
    })

    local CamlockGroupBox = Tabs.Rage:AddRightGroupbox('Camlock')

    local camlockEnabled = false
    local camlockTarget = nil
    local keybind = Enum.KeyCode.Q
    local selectedHitPart = "Head"


    CamlockGroupBox:AddToggle('EnableCamlock', {
        Text = 'Camlock',
        Default = false,
        Callback = function(Value)
            getgenv().Settings.CamlockEnabled = Value
            if not Value then
                camlockTarget = nil 
            end
        end
    })


    CamlockGroupBox:AddLabel('Key'):AddKeyPicker('CamlockKeybind', {
        Default = 'Q',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Camlock',
        NoUI = false,
        ChangedCallback = function(NewKey)
            keybind = Enum.KeyCode[NewKey]
        end
    })

    CamlockGroupBox:AddDropdown('HitPartSelector', {
        Text = 'HitPart',
        Default = 'Head',
        Values = { 'Head', 'HumanoidRootPart', 'UpperTorso' },
        Callback = function(Value)
            selectedHitPart = Value
        end
    })

    function isTyping()
        local UIS = game:GetService("UserInputService")
        return UIS:GetFocusedTextBox() ~= nil
    end

    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or isTyping() then return end

        if input.KeyCode == keybind and getgenv().Settings.CamlockEnabled then
            if camlockTarget then
                camlockTarget = nil
            else
                local closestPlayer = nil
                local closestDistance = math.huge
                local localCharacter = game.Players.LocalPlayer.Character
                local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")

                if localRoot then
                    for _, player in ipairs(game.Players:GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and player.Character then
                            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                            local targetHumanoid = player.Character:FindFirstChild("Humanoid")

                            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                                local distance = (localRoot.Position - targetRoot.Position).Magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                end

                camlockTarget = closestPlayer
            end
        end
    end)

    game:GetService("RunService").RenderStepped:Connect(function()
        if camlockTarget and getgenv().Settings.CamlockEnabled then
            local targetPart = camlockTarget.Character and camlockTarget.Character:FindFirstChild(selectedHitPart)

            if targetPart then
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
            else
                camlockTarget = nil
            end
        end
    end)

    local MiscGroupBox = Tabs.Rage:AddLeftGroupbox('Checks/')

    RageGroupBox:AddToggle('RemoveFireCooldownToggle', {
        Text = 'Remove Fire Cooldown',
        Default = false,
        Callback = function(Value)
            RapidFireEnabled = Value
        end
    })

    MiscGroupBox:AddToggle('autoReloadToggle', {
        Text = 'Auto Reload',
        Default = false,
        Callback = function(Value)
            _G.AutoReloadEnabled = Value
            if Value then
                startAutoReload()
            end
        end
    })

    MiscGroupBox:AddToggle('CrewCheck', {
        Text = 'Crew Check',
        Default = false,
        Callback = function(Value)
            getgenv().Settings.CrewCheck = Value
        end
    })

    game.Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function()
            if IsInSameCrew(newPlayer) then
                print(newPlayer.Name .. " is in the same crew!")
            else
                print(newPlayer.Name .. " is NOT in the same crew.")
            end
        end)
    end)

    MiscGroupBox:AddToggle('rq', {
        Text = 'K.O check',
        Default = false,
        Callback = function(Value)
            getgenv().Settings.KOCheck = Value
        end
    })



    MiscGroupBox:AddToggle('fcheck', {
        Text = 'Friend check',
        Default = false,
        Callback = function(Value)
            getgenv().Settings.FriendCheck = Value
        end
    })



    MiscGroupBox:AddToggle('ffcheck', {
        Text = 'Forcefield check',
        Default = false,
        Callback = function(Value)
            getgenv().Settings.ForceFieldCheck = Value
        end
    })
    -- Replace all otify() calls with StarterGui notifications like this:
    
    function startAutoReload()
        _G.Connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not _G.AutoReloadEnabled then
                _G.Connection:Disconnect()
                return
            end

            if game.Players.LocalPlayer.Character then
                local tool = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                if tool then
                    local ammo = tool:FindFirstChild("Ammo")
                    if ammo and ammo.Value <= 0 then
                        game:GetService("ReplicatedStorage").MainEvent:FireServer("Reload", tool)
                        task.wait(0.4)
                    end
                end
            end
        end)
    end

    local ermmGroupBox = Tabs.Rage:AddRightGroupbox('ermm')

    local chinatalk = {
        "Hey maybe try buying a good cheat",
        "why aim when Loss. cc does it for you?",
        "1 tapped btw xd",
        "99-0 for Loss btw",
        "ur paste cant compare to Loss",
        "dont go in destroy cheaters after 2 rounds",
        "well i expected more from a exploiter..",
        "script difference probably 😂😂"
    }
-- Find and replace the MagicShoot function with this:
-- Find and replace the existing MagicShoot function with this safer version:
function MagicShoot(Target)
    if not Target then return end
    
    local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not Tool or not Tool:FindFirstChild("Handle") then return end
    
    -- Store original CFrame
    local originalCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    
    -- Teleport to target, shoot, then return
    task.spawn(function()
        -- Teleport behind target
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Target.Position - Target.CFrame.LookVector * 4)
        
        -- Small delay to ensure teleport registers
        task.wait(0.1)
        
        -- Fire multiple shots
        for i = 1, 3 do
            game:GetService("ReplicatedStorage").MainEvent:FireServer("MousePos", Target.Position)
            task.wait(0.1)
        end
        
        -- Return to original position
        LocalPlayer.Character.HumanoidRootPart.CFrame = originalCFrame
    end)
end
 

-- Also update the ermmGroupBox MagicBullet toggle to use safer intervals:

ermmGroupBox:AddToggle('MagicBulletToggle', {
    Text = 'Range Assist',
    Default = false,
    Callback = function(Value)
        getgenv().MagicBullet = Value
        
        if Value then
            task.spawn(function()
                while getgenv().MagicBullet do
                    if LockedTarget then
                        MagicShoot(LockedTarget)
                        task.wait(math.random(3, 5) / 10) -- Random delay between shots
                    else
                        task.wait(0.2)
                    end
                end
            end)
        end
    end
})
    -- Replace the ermmGroupBox TrashTalk section with this Target Strafe implementation

    -- Add these near the top with other variables
-- Replace the existing Target Strafe implementation with this updated version

-- Target Strafe Variables
local strafeAngle = 0
local visualCircle
local strafeConnection
local lastPosition = nil

local TargetStrafeSettings = {
    Enabled = false,
    Radius = 4,
    Speed = 2,
    Height = 0,
    Visualize = false,
    Smoothness = 0.5, -- New setting for smoother movement
    JumpEnabled = false, -- New setting for jump while strafing
    AutoShoot = false -- New setting for auto-shooting while strafing
}

-- Function to create visualization circle
function createVisualization()
    if visualCircle then visualCircle:Destroy() end
    
    visualCircle = Instance.new("Model")
    visualCircle.Name = "StrafeCircle"
    
    -- Create points around the circle with better visibility
    local segments = 32
    for i = 1, segments do
        local angle = (i / segments) * math.pi * 2
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.2, 0.2, 0.2)
        part.Anchored = true
        part.CanCollide = false
        part.Material = Enum.Material.Neon
        part.Color = Color3.fromRGB(255, 0, 0)
        part.Parent = visualCircle
    end
    
    visualCircle.Parent = workspace
end

-- Function to update visualization position with smooth transitions
function updateVisualization(targetPos)
    if not visualCircle then return end
    
    local segments = #visualCircle:GetChildren()
    for i = 1, segments do
        local angle = (i / segments) * math.pi * 2
        local offset = Vector3.new(
            math.cos(angle) * TargetStrafeSettings.Radius,
            TargetStrafeSettings.Height,
            math.sin(angle) * TargetStrafeSettings.Radius
        )
        local part = visualCircle:GetChildren()[i]
        part.Position = targetPos + offset
    end
end

-- Main strafe update function with improved movement
function updateStrafe()
    if not TargetStrafeSettings.Enabled or not LockedTarget then return end
    
    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")
    if not humanoidRootPart or not humanoid then return end
    
    local targetChar = LockedTarget.Parent
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    -- Update visualization
    if TargetStrafeSettings.Visualize then
        updateVisualization(targetRoot.Position)
    end
    
    -- Calculate strafe position with smooth movement
    strafeAngle = strafeAngle + (TargetStrafeSettings.Speed * 0.1)
    local targetPos = targetRoot.Position + Vector3.new(
        math.cos(strafeAngle) * TargetStrafeSettings.Radius,
        TargetStrafeSettings.Height,
        math.sin(strafeAngle) * TargetStrafeSettings.Radius
    )
    
    -- Smooth movement using lerp
    if lastPosition then
        targetPos = lastPosition:Lerp(targetPos, TargetStrafeSettings.Smoothness)
    end
    lastPosition = targetPos
    
    -- Apply movement
    humanoidRootPart.CFrame = CFrame.new(targetPos, targetRoot.Position)
    
    -- Handle jumping if enabled
    if TargetStrafeSettings.JumpEnabled and humanoid.FloorMaterial == Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    
    -- Handle auto-shooting if enabled
    if TargetStrafeSettings.AutoShoot then
        game:GetService("ReplicatedStorage").MainEvent:FireServer("MousePos", targetRoot.Position)
    end
end

-- Replace the existing Target Strafe UI section with this updated version
ermmGroupBox:AddToggle('TargetStrafeToggle', {
    Text = 'Target Strafe',
    Default = false,
    Callback = function(Value)
        TargetStrafeSettings.Enabled = Value
        
        if Value then
            if strafeConnection then strafeConnection:Disconnect() end
            strafeConnection = RunService.Heartbeat:Connect(updateStrafe)
            
            if TargetStrafeSettings.Visualize then
                createVisualization()
            end
        else
            if strafeConnection then
                strafeConnection:Disconnect()
                strafeConnection = nil
            end
            
            if visualCircle then
                visualCircle:Destroy()
                visualCircle = nil
            end
            
            lastPosition = nil
        end
    end
})

ermmGroupBox:AddToggle('VisualizeStrafe', {
    Text = 'Visualize Circle',
    Default = false,
    Callback = function(Value)
        TargetStrafeSettings.Visualize = Value
        
        if Value and TargetStrafeSettings.Enabled then
            createVisualization()
        else
            if visualCircle then
                visualCircle:Destroy()
                visualCircle = nil
            end
        end
    end
})

ermmGroupBox:AddToggle('JumpWhileStrafe', {
    Text = 'Jump While Strafing',
    Default = false,
    Callback = function(Value)
        TargetStrafeSettings.JumpEnabled = Value
    end
})

ermmGroupBox:AddToggle('AutoShootStrafe', {
    Text = 'Auto Shoot While Strafing',
    Default = false,
    Callback = function(Value)
        TargetStrafeSettings.AutoShoot = Value
    end
})

ermmGroupBox:AddSlider('StrafeRadius', {
    Text = 'Strafe Radius',
    Default = 4,
    Min = 2,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        TargetStrafeSettings.Radius = Value
    end
})

ermmGroupBox:AddSlider('StrafeSpeed', {
    Text = 'Strafe Speed',
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        TargetStrafeSettings.Speed = Value
    end
})

ermmGroupBox:AddSlider('StrafeHeight', {
    Text = 'Height Offset',
    Default = 0,
    Min = -5,
    Max = 5,
    Rounding = 1,
    Callback = function(Value)
        TargetStrafeSettings.Height = Value
    end
})

ermmGroupBox:AddSlider('StrafeSmoothness', {
    Text = 'Movement Smoothness',
    Default = 0.5,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        TargetStrafeSettings.Smoothness = Value
    end
})
 

    ermmGroupBox:AddButton({
        Text = 'Anti-Slow',
        Func = function()
            local Services = game:GetService("Players")
            if Services.LocalPlayer.Character and Services.LocalPlayer.Character:FindFirstChild("BodyEffects") then
                for _, slow in pairs(Services.LocalPlayer.Character.BodyEffects.Movement:GetDescendants()) do
                    if slow.Name == "NoWalkSpeed" or slow.Name == "ReduceWalk" or slow.Name == "NoJumping" then
                        slow:Destroy()
                    end
                end
            end
        end,
        Tooltip = 'Removes slow effects from your character'
    })


    function sendTrashTalk()
        if getgenv().Settings.TrashTalkEnabled then
            local randomPhrase = chinatalk[math.random(1, #chinatalk)]
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(randomPhrase, "All")
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed 
        and input.KeyCode == (getgenv().Settings.TrashTalkKeybind or Enum.KeyCode.B) 
        and getgenv().Settings.TrashTalkEnabled then
            sendTrashTalk()
        end
    end)



    local player = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    local spinSpeed = 0
    local animationId = "rbxassetid://10714340543"
    local animation = Instance.new("Animation")
    animation.AnimationId = animationId
    local animationTrack
    local isPlaying = false
    local spinConnection

    function setupCharacter(character)
        local humanoid = character:WaitForChild("Humanoid")

        animationTrack = humanoid:LoadAnimation(animation)

        if isPlaying then
            animationTrack:Play()
        end

        if spinConnection then spinConnection:Disconnect() end
        local rootPart = character:WaitForChild("HumanoidRootPart")
        spinConnection = RunService.Heartbeat:Connect(function(deltaTime)
            rootPart.CFrame *= CFrame.Angles(0, math.rad(spinSpeed * deltaTime * 60), 0)
        end)
    end

    player.CharacterAdded:Connect(setupCharacter)
    if player.Character then setupCharacter(player.Character) end

    ermmGroupBox:AddToggle('FlossToggle', {
        Text = 'floss ',
        Default = false,
        Callback = function(Value)
            if Value then
                if not isPlaying and animationTrack then
                    animationTrack:Play()
                    isPlaying = true
                end
            else
                if isPlaying and animationTrack then
                    animationTrack:Stop()
                    isPlaying = false
                end
            end
        end
    })

    ermmGroupBox:AddSlider('SpinSpeed', {
        Text = 'Spinbot',
        Min = 0,
        Max = 50,
        Default = 0,
        Rounding = 0,
        Callback = function(Value)
            spinSpeed = Value
        end,
    })

    RunService.Heartbeat:Connect(function()
        if RapidFireEnabled then
            local Character = LocalPlayer.Character
            if Character and Character:FindFirstChildOfClass("Tool") and Character:FindFirstChildOfClass("Tool"):FindFirstChild("GunScript") then
                for _, v in ipairs(getconnections(Character:FindFirstChildOfClass("Tool").Activated)) do
                    local funcinfo = debug.getinfo(v.Function)

                    for i = 1, funcinfo.nups do
                        local c, n = debug.getupvalue(v.Function, i)
                        if type(c) == "number" and c > 0 then 
                            debug.setupvalue(v.Function, i, 0)
                        end
                    end
                end
            end
        end
    end)

    local RageGroupBox2 = Tabs.Rage:AddRightGroupbox('movement')

    -- Variables for Fly and CFrame Speed Configuration
    getgenv().ScriptConfig = {
        FlyConfig = {
            Speed = 50,
            VerticalSpeed = 50,
            Keybind = Enum.KeyCode.X,
            FlyEnabled = false
        },
        SpeedConfig = {
            Multiplier = 2,
            SpeedEnabled = false, -- CFrame speed state
            Keybind = Enum.KeyCode.T -- Keybind to toggle CFrame speed
        }
    }


    -- Character and HumanoidRootPart reference
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HRP = character:FindFirstChild("HumanoidRootPart")

    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        HRP = newCharacter:WaitForChild("HumanoidRootPart")
    end)

    -- Fly control state
    local flyActive = false

    -- Function to start flying
    function startFlying()
        if flyActive or not getgenv().ScriptConfig.FlyConfig.FlyEnabled then return end
        flyActive = true

        local flyLoop
        flyLoop = RunService.RenderStepped:Connect(function()
            if not flyActive then
                flyLoop:Disconnect()
                if HRP then HRP.Velocity = Vector3.zero end
                return
            end

            local direction = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction += Workspace.CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction -= Workspace.CurrentCamera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction -= Workspace.CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction += Workspace.CurrentCamera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction += Vector3.new(0, getgenv().ScriptConfig.FlyConfig.VerticalSpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction -= Vector3.new(0, getgenv().ScriptConfig.FlyConfig.VerticalSpeed, 0)
            end

            if HRP then
                HRP.Velocity = direction.Magnitude > 0 and direction.Unit * getgenv().ScriptConfig.FlyConfig.Speed or Vector3.zero
            end
        end)
    end

    -- Function to stop flying
    function stopFlying()
        flyActive = false
        if HRP then HRP.Velocity = Vector3.zero end
    end

    -- Function to toggle flying
    function toggleFly()
        if not getgenv().ScriptConfig.FlyConfig.FlyEnabled then return end
        if flyActive then
            stopFlying()
        else
            startFlying()
        end
    end

    -- Function to Handle CFrame Speed
    function handleCFrameSpeed(enable)
        if not enable then
            RunService:UnbindFromRenderStep("cframeSpeed")
            return
        end

        RunService:BindToRenderStep("cframeSpeed", Enum.RenderPriority.Character.Value, function()
            if not HRP then
                character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                HRP = character:WaitForChild("HumanoidRootPart")
            end

            local moveDirection = Vector3.zero
            local camera = Workspace.CurrentCamera

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDirection += (camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDirection -= (camera.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDirection -= (camera.CFrame.RightVector * Vector3.new(1, 0, 1)).Unit
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDirection += (camera.CFrame.RightVector * Vector3.new(1, 0, 1)).Unit
            end

            if HRP then
                HRP.CFrame = HRP.CFrame + (moveDirection * getgenv().ScriptConfig.SpeedConfig.Multiplier)
            end
        end)
    end

    -- Function to toggle CFrame Speed
    function toggleCFrameSpeed()
        if not getgenv().ScriptConfig.SpeedConfig.SpeedEnabled then
            getgenv().ScriptConfig.SpeedConfig.SpeedEnabled = true
            handleCFrameSpeed(true)
        else
            getgenv().ScriptConfig.SpeedConfig.SpeedEnabled = false
            handleCFrameSpeed(false)
        end
    end

    -- Check if Player is Chatting
    function isChatting()
        return UserInputService:GetFocusedTextBox() ~= nil
    end

    -- Keybind Listener
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or isChatting() then return end

        -- Toggle CFrame Speed with Keybind
        if input.KeyCode == getgenv().ScriptConfig.SpeedConfig.Keybind then
            toggleCFrameSpeed()
        end

        -- Toggle Fly with Keybind
        if input.KeyCode == getgenv().ScriptConfig.FlyConfig.Keybind then
            toggleFly()
        end
    end)

    -- UI Setup
    RageGroupBox2:AddToggle('FlyToggle', {
        Text = 'Fly',
        Default = false,
        Callback = function(Value)
            getgenv().ScriptConfig.FlyConfig.FlyEnabled = Value
            if not Value then
                stopFlying()
            end
        end
    })

    RageGroupBox2:AddLabel('Fly Keybind'):AddKeyPicker('FlyKeybind', {
        Default = 'X',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Fly',
        NoUI = false,
        ChangedCallback = function(NewKey)
            getgenv().ScriptConfig.FlyConfig.Keybind = Enum.KeyCode[NewKey]
        end
    })

    RageGroupBox2:AddSlider('FlySpeed', {
        Text = 'Fly Speed',
        Min = 10,
        Max = 1500,
        Default = 50,
        Rounding = 0,
        Callback = function(Value)
            getgenv().ScriptConfig.FlyConfig.Speed = Value
        end,
    })

    RageGroupBox2:AddToggle('CFrameSpeedToggle', {
        Text = 'CFrame Speed',
        Default = false,
        Callback = function(Value)
            if not Value then
                getgenv().ScriptConfig.SpeedConfig.SpeedEnabled = false
                handleCFrameSpeed(false)
            end
        end
    })

    RageGroupBox2:AddLabel('CFrame Speed Keybind'):AddKeyPicker('CFrameSpeedKeybind', {
        Default = 'T',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'CFrame Speed',
        NoUI = false,
        ChangedCallback = function(NewKey)
            getgenv().ScriptConfig.SpeedConfig.Keybind = Enum.KeyCode[NewKey]
        end
    })

    RageGroupBox2:AddSlider('CFrameSpeedMultiplier', {
        Text = 'CFrame Multiplier',
        Min = 1,
        Max = 10,
        Default = 2,
        Rounding = 1,
        Callback = function(Value)
            getgenv().ScriptConfig.SpeedConfig.Multiplier = Value
        end
    })

    local StarterGui = game:GetService("StarterGui")
    local Workspace = game:GetService("Workspace")

    local guns = {
        "[AK47] - $2387",
        "[Revolver] - $1379",
        "[LMG] - $3978",
        "[AUG] - $2069",
        "[RPG] - $21218",
        "[Money Gun] - $824",
        "[SMG] - $796",
        "[Shotgun] - $1326",
        "[TacticalShotgun] - $1857",
        "[P90] - $1061",
        "[AR] - $1061",
        "[SilencerAR] - $1326",
        "[Double-Barrel SG] - $1432",
        "[Drum-Shotgun] - $1167",
        "[Flamethrower] - $9548",
        "[GrenadeLauncher] - $10609",
        "[Knife] - $159",
        "[PepperSpray] - $80"
    }

    local ammo = {
        ["[AK47] - $2387"] = "90 [AK47 Ammo] - $85",
        ["[Revolver] - $1379"] = "12 [Revolver Ammo] - $80",
        ["[LMG] - $3978"] = "200 [LMG Ammo] - $318",
        ["[AUG] - $2069"] = "90 [AUG Ammo] - $85",
        ["[RPG] - $21218"] = "5 [RPG Ammo] - $1061",
        ["[SMG] - $796"] = "80 [SMG Ammo] - $64",
        ["[Shotgun] - $1326"] = "20 [Shotgun Ammo] - $64",
        ["[TacticalShotgun] - $1857"] = "20 [TacticalShotgun Ammo] - $64",
        ["[P90] - $1061"] = "120 [P90 Ammo] - $64",
        ["[AR] - $1061"] = "100 [AR Ammo] - $80",
        ["[SilencerAR] - $1326"] = "120 [SilencerAR Ammo] - $80",
        ["[Double-Barrel SG] - $1432"] = "18 [Double-Barrel SG Ammo] - $64",
        ["[Drum-Shotgun] - $1167"] = "18 [Drum-Shotgun Ammo] - $69",
        ["[Flamethrower] - $9548"] = "140 [Flamethrower Ammo] - $1061",
        ["[GrenadeLauncher] - $10609"] = "12 [GrenadeLauncher Ammo] - $3183"
    }

    local ammoKeys = {
        "90 [AK47 Ammo] - $85",
        "12 [Revolver Ammo] - $80",
        "200 [LMG Ammo] - $318",
        "90 [AUG Ammo] - $85",
        "5 [RPG Ammo] - $1061",
        "80 [SMG Ammo] - $64",
        "20 [Shotgun Ammo] - $64",
        "20 [TacticalShotgun Ammo] - $64",
        "120 [P90 Ammo] - $64",
        "100 [AR Ammo] - $80",
        "120 [SilencerAR Ammo] - $80",
        "18 [Double-Barrel SG Ammo] - $64",
        "18 [Drum-Shotgun Ammo] - $69",
        "140 [Flamethrower Ammo] - $1061",
        "12 [GrenadeLauncher Ammo] - $3183"
    }

    local meleeWeapons = {
        "[StopSign] - $318",
        "[SledgeHammer] - $371",
        "[Pitchfork] - $339",
        "[Shovel] - $339",
        "[Bat] - $265",
        "[Whip] - $265",
        "[Knife] - $159"
    }

    local miscItems = {
        "[Taco] - $4",
        "[Lemonade] - $3",
        "[High-Medium Armor] - $3183",
        "[Fire Armor] - $2546",
        "[Hair Glue] - $21",
        "[Firework] - $10609",
        "[Grenade] - $743",
        "[Donut] - $5",
        "[Hamburger] - $11",
        "[Chicken] - $7",
        "[Weights] - $127",
        "[HeavyWeights] - $265",
        "[Popcorn] - $7",
        "[Pizza] - $11",
        "[Cranberry] - $3",
        "[Starblox Latte] - $5",
        "[Flashbang] - $583",
        "[Paintball Mask] - $64",
        "[Ninja Mask] - $64",
        "[Hockey Mask] - $64",
        "[Pumpkin Mask] - $64",
        "[Skull Mask] - $64",
        "[Breathing Mask] - $64",
        "[Flowers] - $5",
        "[BrownBag] - $27",
        "[Camera] - $106",
        "[PinkPhone] - $424",
        "[Original Phone] - $53",
        "[iPhone] - $637",
        "[iPhoneG] - $637",
        "[iPhoneB] - $637",
        "[iPhoneP] - $637",
        "[Orange Phone] - $424",
        "[Old Phone] - $106",
        "[Tele] - $159",
        "[AntiBodies] - $106",
        "[Surgeon Mask] - $27",
        "[Starblox Latte] - $5",
        "[Meat] - $13",
        "[FoodsCart] - $16",
        "[Da Milk] - $7",
        "[HotDog] - $8"
    }


    function enableNoclip()
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end

    function disableNoclip()
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end

    function freezeCharacter()
        local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.Anchored = true
        end
    end

    function unfreezeCharacter()
        local humanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.Anchored = false
        end
    end

    function teleportTo(position)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            enableNoclip()
            LocalPlayer.Character.HumanoidRootPart.CFrame = position
            task.wait(0.1)
        end
    end

    function buyItem(itemName, quantity)
        local selectedItem = Workspace.Ignored.Shop:FindFirstChild(itemName)
        if not selectedItem then
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "Item not found: " .. itemName,
                Color = Color3.new(1, 0, 0),
            })
            return
        end

        local clickDetector = selectedItem:FindFirstChild("ClickDetector")
        if clickDetector then
            local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame -- Save current position
            teleportTo(selectedItem.Head.CFrame * CFrame.new(0, -9, 0))
            task.wait(0.1) -- Teleport below item
            freezeCharacter() -- Freeze character for stability

            task.wait(0.1) -- Wait at the location to ensure loading stability

            for i = 1, quantity do
                task.spawn(function()
                    pcall(function()
                        for _ = 1, 5 do -- Fire the click detector multiple times
                            fireclickdetector(clickDetector, 1)
                        end
                    end)
                end)
                task.wait(0.1) -- Ensure some delay between actions
            end

            -- Restore state
            unfreezeCharacter()
            disableNoclip()
            LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
        else
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text = "Unable to interact with: " .. itemName,
                Color = Color3.new(1, 0, 0),
            })
        end
    end

    -- UI Setup
    local MiscGroupBox = Tabs.Misc:AddLeftGroupbox('Item Buyer')

    MiscGroupBox:AddDropdown('GunsDropdown', {
        Values = guns,
        Default = 1,
        Text = 'Guns',
        Callback = function(Value)
            getgenv().SelectedItem = Value
        end,
    })

    MiscGroupBox:AddDropdown('AmmoDropdown', {
        Values = ammoKeys,
        Default = 1,
        Text = 'Ammo',
        Callback = function(Value)
            getgenv().SelectedItem = Value
        end,
    })

    MiscGroupBox:AddDropdown('MeleeWeaponsDropdown', {
        Values = meleeWeapons,
        Default = 1,
        Text = 'Melee Weapons',
        Callback = function(Value)
            getgenv().SelectedItem = Value
        end,
    })

    MiscGroupBox:AddDropdown('MiscItemsDropdown', {
        Values = miscItems,
        Default = 1,
        Text = 'Misc Items',
        Callback = function(Value)
            getgenv().SelectedItem = Value
        end,
    })

    MiscGroupBox:AddSlider('QuantitySlider', {
        Text = 'Amount',
        Min = 1,
        Max = 100,
        Default = 1,
        Rounding = 0,
        Callback = function(Value)
            getgenv().SelectedQuantity = Value
        end,
    })

    MiscGroupBox:AddButton({
        Text = 'Buy Selected',
        Func = function()
            if getgenv().SelectedItem and getgenv().SelectedQuantity then
                buyItem(getgenv().SelectedItem, getgenv().SelectedQuantity)
            else
                StarterGui:SetCore("ChatMakeSystemMessage", {
                    Text = "Please select an item and quantity!",
                    Color = Color3.new(1, 0.5, 0),
                })
            end
        end,
        Tooltip = 'Buys the selected item with the set quantity',
    })


    local MiscGroupBox2 = Tabs.Misc:AddRightGroupbox('Desync')

    local playerCharacter = player.Character
    local playerHumanoidRootPart = playerCharacter:FindFirstChild("HumanoidRootPart") or playerCharacter:WaitForChild("HumanoidRootPart")

    --> Desync Config <--
    getgenv().DesyncConfig = {
        Toggled = false,
        Speed = 8,
        Mode = "Walkable",
        AssemblyLinearVelocity = {
            X = 7000,
            Y = 7000,
            Z = 7000,
        },
        Bind = "Y" -- Default keybind
    }

    --> Function To Handle When LocalPlayer Respawns <--
    player.CharacterAdded:Connect(function(NewCharacter)
        playerCharacter = NewCharacter
        playerHumanoidRootPart = playerCharacter:FindFirstChild("HumanoidRootPart") or playerCharacter:WaitForChild("HumanoidRootPart")
    end)

    --> Desync Function <--
    RunService.Heartbeat:Connect(function()
        if DesyncConfig.Toggled then
            if DesyncConfig.Mode == "Default" then
                local playerHumanoidRootPartAssemblyLinearVelocity = playerHumanoidRootPart.AssemblyLinearVelocity

                playerHumanoidRootPart.CFrame = playerHumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(DesyncConfig.Speed), 0)
                playerHumanoidRootPart.AssemblyLinearVelocity = Vector3.new(DesyncConfig.AssemblyLinearVelocity.X, DesyncConfig.AssemblyLinearVelocity.Y, DesyncConfig.AssemblyLinearVelocity.Z)
                RunService.RenderStepped:Wait()
                playerHumanoidRootPart.AssemblyLinearVelocity = playerHumanoidRootPartAssemblyLinearVelocity

            elseif DesyncConfig.Mode == "Random" then
                local playerHumanoidRootPartAssemblyLinearVelocity = playerHumanoidRootPart.AssemblyLinearVelocity

                playerHumanoidRootPart.CFrame = playerHumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(DesyncConfig.Speed), 0)
                playerHumanoidRootPart.Velocity = Vector3.new(math.random(-DesyncConfig.AssemblyLinearVelocity.X, DesyncConfig.AssemblyLinearVelocity.X), math.random(-DesyncConfig.AssemblyLinearVelocity.Y, DesyncConfig.AssemblyLinearVelocity.Y), math.random(-DesyncConfig.AssemblyLinearVelocity.Z, DesyncConfig.AssemblyLinearVelocity.Z))
                RunService.RenderStepped:Wait()
                playerHumanoidRootPart.AssemblyLinearVelocity = playerHumanoidRootPartAssemblyLinearVelocity

            elseif DesyncConfig.Mode == "Walkable" then
                local playerHumanoidRootPartAssemblyLinearVelocity = playerHumanoidRootPart.AssemblyLinearVelocity
                playerHumanoidRootPart.CFrame = playerHumanoidRootPart.CFrame * CFrame.Angles(0, 0, 0)
                playerHumanoidRootPart.Velocity = Vector3.new(math.random(-DesyncConfig.AssemblyLinearVelocity.X, DesyncConfig.AssemblyLinearVelocity.X), math.random(-DesyncConfig.AssemblyLinearVelocity.Y, DesyncConfig.AssemblyLinearVelocity.Y), math.random(-DesyncConfig.AssemblyLinearVelocity.Z, DesyncConfig.AssemblyLinearVelocity.Z))
                playerHumanoidRootPart.CFrame = playerHumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(DesyncConfig.Speed), 0)
                RunService.RenderStepped:Wait()
                playerHumanoidRootPart.AssemblyLinearVelocity = playerHumanoidRootPartAssemblyLinearVelocity
            elseif DesyncConfig.Mode == "Void" then
                Workspace.FallenPartsDestroyHeight = -math.huge * 3252357
                local playerHumanoidRootPartAssemblyLinearVelocity = playerHumanoidRootPart.AssemblyLinearVelocity
                playerHumanoidRootPart.Velocity = Vector3.new(9e9, 9e9, 9e9)
                RunService.RenderStepped:Wait()
                playerHumanoidRootPart.AssemblyLinearVelocity = playerHumanoidRootPartAssemblyLinearVelocity
            end
            
        end
    end)

    --> Keybind Input Handling <--
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        if input.KeyCode.Name == DesyncConfig.Bind then
            DesyncConfig.Toggled = not DesyncConfig.Toggled
        end
    end)

    --> UI Integration <--
    MiscGroupBox2:AddToggle('Invis', {
        Text = 'Desync',
        Default = false,
        Callback = function(Value)
            getgenv().DesyncConfig.Toggled = Value
        end
    })

    MiscGroupBox2:AddDropdown('Desync Mode', {
        Values = { 'Default', 'Random', 'Walkable', 'Void' }, -- Added 'Void' option
        Default = 1,
        Multi = false,

        Text = 'Desync mode',
        Tooltip = 'Desync mode',

        Callback = function(Value)
            getgenv().DesyncConfig.Mode = Value
        end
    })

    MiscGroupBox2:AddLabel('Keybind'):AddKeyPicker('DesyncKeybind', {
        Default = 'Y',
        SyncToggleState = true,
        Mode = 'Toggle',
        Text = 'Desync',
        NoUI = false,
        ChangedCallback = function(New)
            getgenv().DesyncConfig.Bind = New.Name
        end
    })


    local MiscGroupBox3 = Tabs.Misc:AddRightGroupbox('misc')

    local Xmin, Xmax = -10000000, 10000000
    local Ymin, Ymax = -10000000, 10000000
    local Zmin, Zmax = -10000000, 10000000

    local detectRadius = 15
    local plr = game.Players.LocalPlayer
    local dodgeActive = false

    -- Function to check proximity
    function isNear(part, char)
        return part and (part.Position - char.PrimaryPart.Position).Magnitude <= detectRadius
    end

    function checkProximity()
        while dodgeActive do
            local char = plr.Character or plr.CharacterAdded:Wait()
            local launcher = workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild("Model") and workspace.Ignored.Model:FindFirstChild("Launcher")
            local handle = workspace.Ignored and workspace.Ignored:FindFirstChild("Handle")
            
            if (launcher and isNear(launcher, char)) or (handle and isNear(handle, char)) then
                getgenv().Shake = true
            else
                getgenv().Shake = false
            end

            wait(0.1)
        end
        getgenv().Shake = false
    end

    -- Heartbeat handler for shaking effect
    game:GetService("RunService").Heartbeat:Connect(function()
        if getgenv().Shake then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local originalVel = root.Velocity
                root.Velocity = Vector3.new(
                    math.random(Xmin, Xmax),
                    math.random(Ymin, Ymax),
                    math.random(Zmin, Zmax)
                )
                game:GetService("RunService").RenderStepped:Wait()
                root.Velocity = originalVel
            end
        end
    end)

    MiscGroupBox3:AddToggle('Anti Arab', {
        Text = 'Anti Arab',
        Default = false,
        Callback = function(Value)
            dodgeActive = Value
            if dodgeActive then
                function startDodge()
                    local char = plr.Character or plr.CharacterAdded:Wait()
                    task.spawn(checkProximity)
                end
        
                startDodge()
                plr.CharacterAdded:Connect(startDodge)
            else
                getgenv().Shake = false
            end
        end
    })

    --[[ 
        WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk! 
    ]]

    -- Chat Spy Configuration
    local enabled = false -- Default is disabled; toggled via UI
    local spyOnMyself = true -- If true, will also spy on your own messages
    local public = false -- If true, logs will be public (risky, fun)
    local publicItalics = true -- If true, public logs will use /me to stand out
    local privateProperties = { -- Customize private logs
        Color = Color3.fromRGB(0, 255, 255), 
        Font = Enum.Font.SourceSansBold, 
        TextSize = 18
    }

    -- Services
    local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer

    -- Chat Events
    local sayMessageRequest = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest")
    local onMessageDoneFiltering = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("OnMessageDoneFiltering")

    -- Chat Spy State
    local instance = (_G.chatSpyInstance or 0) + 1
    _G.chatSpyInstance = instance

    -- Spy Functionality
    function toggleSpy(state)
        enabled = state
        privateProperties.Text = "{SPY " .. (enabled and "ENABLED" or "DISABLED") .. "}"
        StarterGui:SetCore("ChatMakeSystemMessage", privateProperties)
    end

    function onChatted(player, message)
        if _G.chatSpyInstance ~= instance or not enabled then return end

        -- Handle toggle command if spying on self
        if player == LocalPlayer and message:lower():sub(1, 4) == "/spy" then
            toggleSpy(not enabled)
            return
        end

        -- Skip if spying is off or player is yourself and spyOnMyself is false
        if not enabled or (player == LocalPlayer and not spyOnMyself) then return end

        -- Clean up the message
        message = message:gsub("[\n\r]", ""):gsub("\t", " "):gsub("[ ]+", " ")

        -- Detect if the message is hidden
        local hidden = true
        local conn = onMessageDoneFiltering.OnClientEvent:Connect(function(packet, channel)
            if packet.SpeakerUserId == player.UserId and packet.Message == message:sub(#message - #packet.Message + 1) and 
            (channel == "All" or (channel == "Team" and not public and Players[packet.FromSpeaker].Team == LocalPlayer.Team)) then
                hidden = false
            end
        end)

        wait(1)
        conn:Disconnect()

        -- Log the message if it's hidden
        if hidden then
            if public then
                local chatMessage = (publicItalics and "/me " or "") .. "{SPY} [" .. player.Name .. "]: " .. message
                sayMessageRequest:FireServer(chatMessage, "All")
            else
                privateProperties.Text = "{SPY} [" .. player.Name .. "]: " .. message
                StarterGui:SetCore("ChatMakeSystemMessage", privateProperties)
            end
        end
    end

    -- Connect to existing players
    for _, player in ipairs(Players:GetPlayers()) do
        player.Chatted:Connect(function(message)
            onChatted(player, message)
        end)
    end

    -- Connect to newly added players
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(message)
            onChatted(player, message)
        end)
    end)

    -- Ensure chat visibility for better experience
    if not LocalPlayer.PlayerGui:FindFirstChild("Chat") then wait(3) end
    local chatFrame = LocalPlayer.PlayerGui.Chat.Frame
    chatFrame.ChatChannelParentFrame.Visible = true
    chatFrame.ChatBarParentFrame.Position = chatFrame.ChatChannelParentFrame.Position + UDim2.new(UDim.new(), chatFrame.ChatChannelParentFrame.Size.Y)

    -- UI Integration
    MiscGroupBox3:AddToggle('Chat Spy', {
        Text = 'Chat Spy',
        Default = false,
        Callback = function(Value)
            -- Toggle Chat Spy
            toggleSpy(Value)
        end
    })


    -- Variables
    local antiStompEnabled = false
    local antiStompMethod = "Head" -- Default method

    -- Random Function Names
    function F7NpKv(player)
        if not player.Character then return false end
        local G6YxQw = player.Character:FindFirstChild("BodyEffects")
        if not G6YxQw then return false end
        local L9PwYz = G6YxQw:FindFirstChild("K.O")
        return L9PwYz and L9PwYz.Value == true
    end

    -- Destroy Character Parts Method
    function B2ZqXv()
        local player = Players.LocalPlayer
        if not player or not F7NpKv(player) then return end -- Check for K.O. effect before continuing
        
        local D4KwJr = player.Character
        if not D4KwJr then return end

        for _, T9JkXr in pairs(D4KwJr:GetDescendants()) do
            if T9JkXr:IsA("BasePart") then
                T9JkXr:Destroy()
            end
        end
    end

    -- Anti-Stomp Logic (Head Method)
    function W3PnVz()
        local player = Players.LocalPlayer
        if not player or not F7NpKv(player) then return end
        local head = player.Character and player.Character:FindFirstChild("Head")
        if head then
            head:Destroy()
        end
    end

    -- Anti-Stomp Logic (Humanoid Method)
    function M4ZxWk()
        local player = Players.LocalPlayer
        if not player or not F7NpKv(player) then return end
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        end
    end

    -- Anti-Stomp Main Loop
    task.spawn(function()
        while task.wait(0.1) do
            if antiStompEnabled then
                pcall(function()
                    if antiStompMethod == "Head" then
                        W3PnVz()
                    elseif antiStompMethod == "Humanoid" then
                        M4ZxWk()
                    elseif antiStompMethod == "Destroy" then
                        B2ZqXv()
                    end
                end)
            end
        end
    end)

    -- UI Setup
    -- Ensure MiscGroupBox3 is properly defined
    assert(MiscGroupBox3 and MiscGroupBox3.AddToggle, "MiscGroupBox3 or AddToggle is not defined.")
    assert(MiscGroupBox3.AddDropdown, "MiscGroupBox3:AddDropdown is not defined.")


    MiscGroupBox3:AddToggle('Anti Stomp', {
        Text = 'Anti Stomp',
        Default = false,
        Callback = function(Value)
            antiStompEnabled = Value
        end
    })

    local cloneref = getgenv().cloneref or function(...) return ... end

    local Game = cloneref(Game)

    if not Game:IsLoaded() then Game.Loaded:Wait() end

    local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local LocalHumanoid = LocalCharacter:FindFirstChildOfClass("Humanoid") or LocalCharacter:FindFirstChildWhichIsA("Humanoid") or LocalCharacter:WaitForChild("Humanoid")
    local LocalRootPart = LocalHumanoid.RootPart or LocalCharacter:WaitForChild("HumanoidRootPart")

    --// Anti Sit Toggle \\--
    local antiSitEnabled = false -- Default state

    MiscGroupBox3:AddToggle('Anti Sit', {
        Text = 'Anti Sit',
        Default = false,
        Callback = function(Value)
            antiSitEnabled = Value
        end
    })

    --// Functions \\--

    -- Function to handle "Sit" property changes
    function onSitChanged()
        if antiSitEnabled and LocalHumanoid.Sit then
            task.wait(0.01)
            LocalHumanoid.Sit = false
        end
    end

    -- Function to connect Anti Sit functionality to the humanoid
    function setupAntiSitForCharacter(Character)
        LocalCharacter = Character
        LocalHumanoid = LocalCharacter:FindFirstChildOfClass("Humanoid") or LocalCharacter:FindFirstChildWhichIsA("Humanoid") or LocalCharacter:WaitForChild("Humanoid")
        LocalRootPart = LocalHumanoid.RootPart or LocalCharacter:WaitForChild("HumanoidRootPart")
        
        if LocalCharacter and LocalHumanoid and LocalRootPart then
            LocalHumanoid:GetPropertyChangedSignal("Sit"):Connect(onSitChanged)
        end
    end

    -- Connect the CharacterAdded event
    LocalPlayer.CharacterAdded:Connect(setupAntiSitForCharacter)

    -- Initial setup for the current character
    if LocalCharacter and LocalHumanoid and LocalRootPart then
        LocalHumanoid:GetPropertyChangedSignal("Sit"):Connect(onSitChanged)
    end


    -- Toggle for Auto Armor
    MiscGroupBox3:AddToggle('AutoArmor', {
        Text = 'Auto armor',
        Default = false,
        Callback = function(Value)
            getgenv().AutoBuyArmorEnabled = Value
        end
    })

    MiscGroupBox:AddToggle('NoclipToggle', {
        Text = 'Noclip',
        Default = false,
        Callback = function(Value)
            getgenv().NoclipEnabled = Value
            
            if Value then
                -- Enable noclip
                task.spawn(function()
                    while getgenv().NoclipEnabled do
                        local character = LocalPlayer.Character
                        if character then
                            for _, part in pairs(character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                        task.wait(0.1) -- Continuously keep noclip active
                    end
                end)
            else
                -- Disable noclip
                local character = LocalPlayer.Character
                if character then
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    })

    local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Clone = nil
    local Loop = nil
    local isToggled = false
    local storedPosition = nil
    local originalPosition = nil
    local dataFolder = LocalPlayer:WaitForChild("DataFolder")
    local armorInfo = dataFolder:WaitForChild("Information"):WaitForChild("ArmorSave")
    local armorShop = workspace.Ignored.Shop["[High-Medium Armor] - $3183"]
    local shopHead = armorShop.Head
    local shopClickDetector = armorShop.ClickDetector
    local armorCooldown = 0.2
    getgenv().AutoBuyArmorEnabled = true

    function novel(part)
        if part then
            part.AssemblyLinearVelocity = Vector3.zero
            part.AssemblyAngularVelocity = Vector3.zero
            part.Velocity = Vector3.zero
        end
    end

    function CloneHumanoidAnimations(targetHumanoid, cloneHumanoid)
        local animator = targetHumanoid:FindFirstChild("Animator")
        if animator then
            animator:Clone().Parent = cloneHumanoid
        end
    end

    function SyncTools(realChar, cloneChar)
        for _, tool in pairs(cloneChar:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Destroy()
            end
        end
        for _, tool in pairs(realChar:GetChildren()) do
            if tool:IsA("Tool") then
                tool:Clone().Parent = cloneChar
            end
        end
    end

    function CreateFullClone()
        local clone = Char:Clone()
        for _, obj in ipairs(clone:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Anchored = false
                obj.CanCollide = false
                obj.Material = Enum.Material.SmoothPlastic
                obj.Transparency = 0
            end
        end
        clone.Parent = workspace
        return clone
    end

    function StartClone()
        Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        storedPosition = Char.HumanoidRootPart.CFrame
        Clone = CreateFullClone()
        workspace.Camera.CameraSubject = Clone:FindFirstChild("Humanoid")
        SyncTools(Char, Clone)
        Loop = RunService.RenderStepped:Connect(function()
            Char.HumanoidRootPart.CFrame = storedPosition
            for _, part in pairs(Char:GetChildren()) do
                if part:IsA("BasePart") then
                    novel(part)
                end
            end
            Clone.Humanoid:Move(Char.Humanoid.MoveDirection, false)
            Clone.Humanoid.Jump = Char.Humanoid.Jump
            SyncTools(Char, Clone)
        end)
    end

    function StopClone()
        if Loop then
            Loop:Disconnect()
            Loop = nil
        end
        if Clone then
            Char.HumanoidRootPart.CFrame = Clone.HumanoidRootPart.CFrame
            Clone:Destroy()
            Clone = nil
        end
        workspace.Camera.CameraSubject = Char:FindFirstChild("Humanoid")
    end

    function autoBuyArmor()
        local charHRP = Char:FindFirstChild("HumanoidRootPart")
        if not originalPosition then
            originalPosition = charHRP.CFrame
        end
        if Loop then Loop:Disconnect() Loop = nil end
        charHRP.CFrame = shopHead.CFrame * CFrame.new(0, 3, 0)
        task.wait(armorCooldown)
        fireclickdetector(shopClickDetector)
        task.wait(armorCooldown)
        charHRP.CFrame = originalPosition
        originalPosition = nil
        Loop = RunService.RenderStepped:Connect(function()
            Char.HumanoidRootPart.CFrame = storedPosition
            for _, part in pairs(Char:GetChildren()) do
                if part:IsA("BasePart") then
                    novel(part)
                end
            end
            Clone.Humanoid:Move(Char.Humanoid.MoveDirection, false)
            Clone.Humanoid.Jump = Char.Humanoid.Jump
            SyncTools(Char, Clone)
        end)
    end

    function monitorArmor()
        while task.wait(0.1) do
            if getgenv().AutoBuyArmorEnabled and tonumber(armorInfo.Value) < 50 then
                StartClone()
                autoBuyArmor()
                StopClone()
            end
        end
    end

    LocalPlayer.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        originalPosition = nil
        task.spawn(monitorArmor)
    end)

    task.spawn(monitorArmor)


    MiscGroupBox3:AddDropdown('StompMethod', {
        Values = { 'Head', 'Humanoid', 'Destroy' }, -- Dropdown options
        Default = 1, -- Default index (1 = "Head")
        Multi = false, -- Single selection only
        Text = 'Anti-Stomp Method', -- Dropdown label
        Tooltip = 'Select the method to prevent being stomped.', -- Tooltip
        Callback = function(Selected)
            if Selected == 'Head' or Selected == 'Humanoid' or Selected == 'Destroy' then
                antiStompMethod = Selected
            else
                warn("Invalid selection: " .. tostring(Selected))
            end
        end
    })




    -- Variables for Force Reset
    local forceResetMethod = "Humanoid" -- Default method

    -- Force Reset Methods
    function humanoid()
        local player = Players.LocalPlayer
        if not player.Character then return end

        -- Kill the Humanoid
        local characterHumanoid = player.Character:FindFirstChild("Humanoid")
        if characterHumanoid then
            characterHumanoid:TakeDamage(characterHumanoid.MaxHealth) -- Inflict damage to kill the character
        end
    end

    function head()
        local player = Players.LocalPlayer
        if not player.Character then return end

        -- Destroy the Head
        local characterHead = player.Character:FindFirstChild("Head")
        if characterHead then
            characterHead:Destroy()
        end
    end

    function destroy()
        local player = Players.LocalPlayer
        if not player.Character then return end

        -- Destroy all BaseParts in the character
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part:Destroy()
            end
        end
    end

    -- UI Setup for Force Reset
    assert(MiscGroupBox3 and MiscGroupBox3.AddDropdown, "MiscGroupBox4 or AddDropdown is not defined.")
    assert(MiscGroupBox3.AddButton, "MiscGroupBox4:AddButton is not defined.")

    -- Add Dropdown for Force Reset Method
    MiscGroupBox3:AddDropdown('ForceResetMethod', {
        Values = { 'Humanoid', 'Head', 'Destroy' }, -- Dropdown options (shortened names)
        Default = 1, -- Default index (1 = "Humanoid")
        Multi = false, -- Single selection only
        Text = 'Force Reset Method', -- Dropdown label
        Tooltip = 'Select the method for force resetting your character.', -- Tooltip
        Callback = function(Selected)
            if Selected == 'Humanoid' or Selected == 'Head' or Selected == 'Destroy' then
                forceResetMethod = Selected -- Update the selected method
            else
                warn("Invalid selection: " .. tostring(Selected))
            end
        end
    })

    MiscGroupBox3:AddButton({
        Text = 'Force Reset',
        Func = function()
            if forceResetMethod == "Humanoid" then
                pcall(humanoid)
            elseif forceResetMethod == "Head" then
                pcall(head)
            elseif forceResetMethod == "Destroy" then
                pcall(destroy)
            else
                StarterGui:SetCore("ChatMakeSystemMessage", {
                    Text = "Invalid reset method selected!",
                    Color = Color3.new(1, 0, 0),
                    Font = Enum.Font.SourceSansBold,
                })
            end
        end,
        Tooltip = 'yes',
    })

    --> Variables <--
    _G.AutoStomp = false

    --> Auto Stomp Functionality <--
    function AutoStomp()
        task.spawn(function()
            while _G.AutoStomp do
                game:GetService("ReplicatedStorage").MainEvent:FireServer("Stomp")
                task.wait(0.1)
            end
        end)
    end

    --> UI Element <--
    MiscGroupBox3:AddToggle('Auto Stomp', {
        Text = 'Auto Stomp',
        Default = false,
        Tooltip = 'Automatically stomps repeatedly.',
        Callback = function(Value)
            _G.AutoStomp = Value
            if _G.AutoStomp then
                AutoStomp()
            end
        end
    })


    --> Variables <--
    _G.AntiModNi = false
    local action = "Notify" -- Default action
    local modList = {
        163721789, 15427717, 201454243, 822999, 63794379, 17260230, 28357488,
        93101606, 8195210, 89473551, 16917269, 85989579, 1553950697, 476537893,
        155627580, 31163456, 7200829, 25717070, 201454243, 15427717, 63794379,
        16138978, 60660789, 17260230, 16138978, 1161411094, 9125623, 11319153,
        34758833, 194109750, 35616559, 1257271138, 28885841, 23558830, 25717070,
        4255947062, 29242182, 2395613299, 3314981799, 3390225662, 2459178,
        2846299656, 2967502742, 7001683347, 7312775547, 328566086, 170526279,
        99356639, 352087139, 6074834798, 2212830051, 3944434729, 5136267958,
        84570351, 542488819, 1830168970, 3950637598
    }

    local NotifyLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/XK5NG/XK5NG.github.io/main/Notify"))()
    local Notify = NotifyLibrary.Notify

    function antiMod()
        while _G.AntiModNi do
            task.wait(0.7)
            for _, player in ipairs(game.Players:GetPlayers()) do
                if table.find(modList, player.UserId) then
                    Library:Notify("very bad guy here: " .. player.Name, 2)

                    if action == "Kick" then
                        game.Players.LocalPlayer:Kick("very bad guy here " .. player.Name)
                    end
                end
            end
        end
    end

    MiscGroupBox3:AddToggle('Anti Mod', {
        Text = 'Anti Mod',
        Default = false,
        Callback = function(Value)
            _G.AntiModNi = Value
            if _G.AntiModNi then
                task.spawn(antiMod) -- Run Anti Mod in a separate thread
            end
        end
    })

    MiscGroupBox3:AddDropdown('AntiModAction', {
        Values = { "Notify", "Kick" },
        Default = 1,
        Multi = false,
        Text = 'Action',
        Tooltip = 'Choose what happens',
        Callback = function(Selected)
            action = Selected 
        end
    })

    MiscGroupBox3:AddButton({
        Text = 'Use Codes',
        Func = function()
            local codes = {
                "HOODMAS24", "GRUMPY", "GPO2", 
                "TRADEME!", "RUBY", 
                "HALLOWEEN2024", "DACARNIVAL", "GHOST",
                "THANKSGIVING24"
            }

            local player = game.Players.LocalPlayer
            local dataFolder = player:WaitForChild("DataFolder")
            local currency = dataFolder:WaitForChild("Currency")
            local mainEvent = game:GetService("ReplicatedStorage"):WaitForChild("MainEvent")
            
            for _, code in pairs(codes) do
                local initialCurrency = currency.Value
                
                while true do
                    mainEvent:FireServer("EnterPromoCode", code)
                    Library:Notify("Trying code: " .. code, 2)
                    task.wait(3.8)
                    
                    if currency.Value ~= initialCurrency then
                        Library:Notify("Code redeemed: " .. code, 2)
                        break
                    end
                end
            end
        end
    })



    Library:SetWatermarkVisibility(true)

    local FrameTimer = tick()
    local FrameCounter = 0;
    local FPS = 60;

    local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
        FrameCounter += 1;

        if (tick() - FrameTimer) >= 1 then
            FPS = FrameCounter;
            FrameTimer = tick();
            FrameCounter = 0;
        end;

        Library:SetWatermark(('Patchmade | Private | @florsas3x | UID: 1 | %s fps | %s ms'):format(
            math.floor(FPS),
            math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
        ));
    end);

    Library.KeybindFrame.Visible = true;

    Library:OnUnload(function()
        WatermarkConnection:Disconnect()

        print('Unloaded!')
        Library.Unloaded = true
    end)

    local PLRvisuals = Tabs.Visuals:AddLeftGroupbox('Visuals')

    local Settings = {
        Tracers_Enabled = false,
        Tracer_Origin = "Cursor",
        Tracer_Color = Color3.fromRGB(255, 0, 0),
        Tracer_Thickness = 1,
        NameESP_Enabled = false,
        NameESP_Mode = "Both",
        NameESP_Color = Color3.fromRGB(0, 255, 0),
        Text_Size = 14,
        HealthBar_Enabled = true,
        CornerRadius = 8
    }

    local ESP_Library = {}
    local Tracer_Library = {}
    local Connections = {}

    function createDrawingLine(color, thickness)
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = color
        line.Thickness = thickness
        line.Transparency = 1
        return line
    end

    function createHealthBar()
        local healthBar = Instance.new("Frame")
        healthBar.Name = "HealthBar"
        healthBar.Size = UDim2.new(0.1, 0, 0.4, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBar.BorderSizePixel = 0

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, Settings.CornerRadius)
        corner.Parent = healthBar

        return healthBar
    end

    function cleanUpPlayer(player)
        if Tracer_Library[player] then
            Tracer_Library[player].Tracer:Remove()
            Tracer_Library[player].Outline:Remove()
            Tracer_Library[player] = nil
        end

        if ESP_Library[player] then
            ESP_Library[player].Billboard:Destroy()
            ESP_Library[player] = nil
        end

        if Connections[player] then
            Connections[player]:Disconnect()
            Connections[player] = nil
        end
    end

    function UpdateESP(player)
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local character = player.Character
        local humanoidRootPart = character.HumanoidRootPart

        if Settings.Tracers_Enabled and not Tracer_Library[player] then
            Tracer_Library[player] = {
                Tracer = createDrawingLine(Settings.Tracer_Color, Settings.Tracer_Thickness),
                Outline = createDrawingLine(Color3.fromRGB(0, 0, 0), Settings.Tracer_Thickness + 1)
            }
        end

        if Settings.NameESP_Enabled and not ESP_Library[player] then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "NameESP"
            billboard.Size = UDim2.new(2, 0, 0.5, 0)
            billboard.StudsOffset = Vector3.new(0, 2, 0)
            billboard.AlwaysOnTop = true

            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundTransparency = 0.5
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, Settings.CornerRadius)
            corner.Parent = frame
            frame.Parent = billboard

            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = Settings.NameESP_Color
            textLabel.Font = Enum.Font.SourceSans
            textLabel.TextSize = Settings.Text_Size
            textLabel.TextStrokeTransparency = 0.5
            textLabel.Parent = frame

            if Settings.HealthBar_Enabled then
                local healthBar = createHealthBar()
                healthBar.Parent = frame
            end

            ESP_Library[player] = {Billboard = billboard, Label = textLabel}
        end

        if not Connections[player] then
            Connections[player] = RunService.Heartbeat:Connect(function()
                if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
                    cleanUpPlayer(player)
                    return
                end

                local humanoidRootPart = player.Character.HumanoidRootPart
                local humanoid = player.Character:FindFirstChild("Humanoid")
                local screenPosition, onScreen = Camera:WorldToViewportPoint(humanoidRootPart.Position)

                if Settings.Tracers_Enabled then
                    local tracerData = Tracer_Library[player]
                    if tracerData then
                        local tracerStart
                        if Settings.Tracer_Origin == "Cursor" then
                            tracerStart = UserInputService:GetMouseLocation()
                        elseif Settings.Tracer_Origin == "Top" then
                            tracerStart = Vector2.new(Camera.ViewportSize.X / 2, 0)
                        elseif Settings.Tracer_Origin == "Bottom" then
                            tracerStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        end

                        local tracer = tracerData.Tracer
                        local outline = tracerData.Outline
                        if onScreen then
                            tracer.From = tracerStart
                            tracer.To = Vector2.new(screenPosition.X, screenPosition.Y)
                            tracer.Visible = true

                            outline.From = tracerStart
                            outline.To = Vector2.new(screenPosition.X, screenPosition.Y)
                            outline.Visible = true
                        else
                            tracer.Visible = false
                            outline.Visible = false
                        end
                    end
                end

                if Settings.NameESP_Enabled then
                    local espData = ESP_Library[player]
                    if espData then
                        espData.Billboard.Adornee = humanoidRootPart
                        espData.Billboard.Enabled = true

                        local text = ""
                        if Settings.NameESP_Mode == "DisplayName" then
                            text = player.DisplayName
                        elseif Settings.NameESP_Mode == "Username" then
                            text = player.Name
                        elseif Settings.NameESP_Mode == "Both" then
                            text = player.DisplayName .. " (" .. player.Name .. ")"
                        end

                        espData.Label.Text = text
                        espData.Label.TextColor3 = Settings.NameESP_Color
                        espData.Billboard.Parent = humanoidRootPart

                        if humanoid and Settings.HealthBar_Enabled then
                            local healthBar = espData.Billboard:FindFirstChild("HealthBar")
                            if healthBar then
                                healthBar.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 0.4, 0)
                                healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), humanoid.Health / humanoid.MaxHealth)
                            end
                        end
                    end
                end
            end)
        end
    end

    function EnableESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                UpdateESP(player)
            end
        end

        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                UpdateESP(player)
            end)
            UpdateESP(player)
        end)

        Players.PlayerRemoving:Connect(cleanUpPlayer)
    end

    function DisableESP()
        for _, player in pairs(Players:GetPlayers()) do
            cleanUpPlayer(player)
        end
    end

    PLRvisuals:AddToggle('Tracer Toggle', {
        Text = 'Enable Tracers',
        Default = false,
        Tooltip = 'Enable or disable tracers to players.',
        Callback = function(Value)
            Settings.Tracers_Enabled = Value
            if Value then
                EnableESP()
            else
                DisableESP()
            end
        end
    })

    PLRvisuals:AddDropdown('Tracer Origin', {
        Text = 'Tracer Origin',
        Default = "Cursor",
        Tooltip = 'Choose the origin of the tracers.',
        Values = {"Cursor", "Top", "Bottom"},
        Callback = function(Value)
            Settings.Tracer_Origin = Value
        end
    })

    PLRvisuals:AddLabel('Tracer Color'):AddColorPicker('TracerColorPicker', {
        Default = Settings.Tracer_Color,
        Title = 'Tracer Color',
        Callback = function(Value)
            Settings.Tracer_Color = Value
        end
    })

    PLRvisuals:AddToggle('Name ESP Toggle', {
        Text = 'Enable Name ESP',
        Default = false,
        Tooltip = 'Enable or disable name ESP.',
        Callback = function(Value)
            Settings.NameESP_Enabled = Value
            if Value then
                EnableESP()
            else
                DisableESP()
            end
        end
    })

    PLRvisuals:AddDropdown('Name ESP Mode', {
        Text = 'Name ESP Display Mode',
        Default = "Both",
        Tooltip = 'Choose how to display the player's name.',
        Values = {"Username", "DisplayName", "Both"},
        Callback = function(Value)
            Settings.NameESP_Mode = Value
        end
    })

    PLRvisuals:AddLabel('Name ESP Color'):AddColorPicker('NameESPColorPicker', {
        Default = Settings.NameESP_Color,
        Title = 'Name ESP Color',
        Callback = function(Value)
            Settings.NameESP_Color = Value
        end
    })

    PLRvisuals:AddSlider('NameESP Text Size', {
        Text = 'Name ESP Text Size',
        Min = 10,
        Max = 30,
        Default = 14,
        Rounding = 0,
        Callback = function(Value)
            Settings.Text_Size = Value
        end
    })



    local PLRvisuals2 = Tabs.Visuals:AddRightGroupbox('Self Visuals')

    local SelfChams_Enabled = false
    local ToolChams_Enabled = false
    local ChamsMaterial = Enum.Material.ForceField
    local ChamsColor = Color3.new(1, 0, 0)

    function ApplySelfChams()
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Material = ChamsMaterial
                    part.Color = ChamsColor
                end
            end
        end

        LocalPlayer.CharacterAdded:Connect(function(character)
            repeat task.wait() until character:FindFirstChild("UpperTorso")
            if SelfChams_Enabled then
                ApplySelfChams()
            end
        end)
    end

    function RemoveSelfChams()
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Material = Enum.Material.Plastic
                    part.Color = Color3.new(1, 1, 1)
                end
            end
        end
    end

    function ApplyToolChams()
        if LocalPlayer.Backpack then
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, part in ipairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material = ChamsMaterial
                            part.Color = ChamsColor
                        end
                    end
                end
            end
        end
    end

    function RemoveToolChams()
        if LocalPlayer.Backpack then
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, part in ipairs(tool:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material = Enum.Material.Plastic
                            part.Color = Color3.new(1, 1, 1)
                        end
                    end
                end
            end
        end
    end

    PLRvisuals2:AddToggle('SelfChamsToggle', {
        Text = 'Enable Self Chams',
        Default = false,
        Tooltip = 'Enable or disable chams for your character.',
        Callback = function(Value)
            SelfChams_Enabled = Value
            if SelfChams_Enabled then
                ApplySelfChams()
            else
                RemoveSelfChams()
            end
        end
    })

    PLRvisuals2:AddToggle('ToolChamsToggle', {
        Text = 'Enable Tool Chams',
        Default = false,
        Tooltip = 'Enable or disable chams for your tools.',
        Callback = function(Value)
            ToolChams_Enabled = Value
            if ToolChams_Enabled then
                ApplyToolChams()
            else
                RemoveToolChams()
            end
        end
    })

    PLRvisuals2:AddDropdown('ChamsMaterialDropdown', {
        Values = { 'ForceField', 'Neon' },
        Default = 1,
        Multi = false,
        Text = 'Chams Material',
        Tooltip = 'Select the material for chams.',
        Callback = function(Selected)
            if Selected == 'ForceField' then
                ChamsMaterial = Enum.Material.ForceField
            elseif Selected == 'Neon' then
                ChamsMaterial = Enum.Material.Neon
            else
                warn("Invalid selection: " .. tostring(Selected))
            end

            if SelfChams_Enabled then
                ApplySelfChams()
            end
            if ToolChams_Enabled then
                ApplyToolChams()
            end
        end
    })

    PLRvisuals2:AddLabel('Chams Color'):AddColorPicker('ChamsColorPicker', {
        Default = Color3.new(1, 0, 0),
        Title = 'Select Chams Color',
        Tooltip = 'Change the color of your chams.',
        Callback = function(Value)
            ChamsColor = Value

            if SelfChams_Enabled then
                ApplySelfChams()
            end
            if ToolChams_Enabled then
                ApplyToolChams()
            end
        end
    })

    local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()

    getgenv().VisualSettings = {
        TrailEnabled = false,
        AuraEnabled = false,
        TrailColor = Color3.new(1, 0, 0),
        AuraColor = Color3.new(0, 1, 0),
        AuraRadius = 5,
        AmbientEnabled = false,
        AmbientColor = Color3.new(1, 1, 1),
        AmbientBrightness = 2,
        AuraParticleLifetime = 1,
        AuraParticleRate = 10
    }

    local trailInstance, auraEmitter
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    function ApplyTrail(character)
        if trailInstance then
            trailInstance:Destroy()
        end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        local attachment1 = Instance.new("Attachment", rootPart)
        local attachment2 = Instance.new("Attachment", rootPart)
        attachment2.Position = Vector3.new(0, -2, 0)

        trailInstance = Instance.new("Trail")
        trailInstance.Attachment0 = attachment1
        trailInstance.Attachment1 = attachment2
        trailInstance.Color = ColorSequence.new(VisualSettings.TrailColor)
        trailInstance.Transparency = NumberSequence.new(0.2, 1)
        trailInstance.Lifetime = 0.5
        trailInstance.WidthScale = NumberSequence.new(1)
        trailInstance.Parent = rootPart
    end

    function RemoveTrail()
        if trailInstance then
            trailInstance:Destroy()
            trailInstance = nil
        end
    end

    function UpdateAmbient()
        if VisualSettings.AmbientEnabled then
            Lighting.ColorShift_Top = VisualSettings.AmbientColor
            Lighting.Brightness = VisualSettings.AmbientBrightness
        else
            Lighting.ColorShift_Top = Color3.new(0, 0, 0)
            Lighting.Brightness = 2
        end
    end

    function ApplyAura(character)
        if auraEmitter then
            auraEmitter:Destroy()
        end

        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end

        auraEmitter = Instance.new("ParticleEmitter")
        auraEmitter.Texture = "rbxassetid://243660373"
        auraEmitter.Color = ColorSequence.new(VisualSettings.AuraColor)
        auraEmitter.Lifetime = NumberRange.new(VisualSettings.AuraParticleLifetime)
        auraEmitter.Size = NumberSequence.new(VisualSettings.AuraRadius)
        auraEmitter.Rate = VisualSettings.AuraParticleRate
        auraEmitter.Speed = NumberRange.new(0)
        auraEmitter.Parent = rootPart
    end

    function RemoveAura()
        if auraEmitter then
            auraEmitter:Destroy()
            auraEmitter = nil
        end
    end

    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        if VisualSettings.TrailEnabled then
            ApplyTrail(character)
        end
        if VisualSettings.AuraEnabled then
            ApplyAura(character)
        end
        UpdateAmbient()
    end)

    PLRvisuals2:AddToggle('EnableTrailToggle', {
        Text = 'Enable Trail',
        Default = false,
        Callback = function(Value)
            VisualSettings.TrailEnabled = Value
            if Value then
                ApplyTrail(character)
            else
                RemoveTrail()
            end
        end
    })

    PLRvisuals2:AddLabel('Trail Color'):AddColorPicker('TrailColorPicker', {
        Default = VisualSettings.TrailColor,
        Callback = function(Value)
            VisualSettings.TrailColor = Value
            if VisualSettings.TrailEnabled then
                ApplyTrail(character)
            end
        end
    })

    PLRvisuals2:AddToggle('EnableAuraToggle', {
        Text = 'Enable Aura',
        Default = false,
        Callback = function(Value)
            VisualSettings.AuraEnabled = Value
            if Value then
                ApplyAura(character)
            else
                RemoveAura()
            end
        end
    })

    PLRvisuals2:AddLabel('Aura Color'):AddColorPicker('AuraColorPicker', {
        Default = VisualSettings.AuraColor,
        Callback = function(Value)
            VisualSettings.AuraColor = Value
            if VisualSettings.AuraEnabled then
                ApplyAura(character)
            end
        end
    })

    PLRvisuals2:AddSlider('AuraRadiusSlider', {
        Text = 'Aura Radius',
        Min = 1,
        Max = 20,
        Default = 5,
        Rounding = 1,
        Callback = function(Value)
            VisualSettings.AuraRadius = Value
            if VisualSettings.AuraEnabled then
                ApplyAura(character)
            end
        end
    })

    PLRvisuals2:AddToggle('EnableAmbientToggle', {
        Text = 'Enable Ambient Changer',
        Default = false,
        Callback = function(Value)
            VisualSettings.AmbientEnabled = Value
            UpdateAmbient()
        end
    })

    PLRvisuals2:AddLabel('Ambient Color'):AddColorPicker('AmbientColorPicker', {
        Default = VisualSettings.AmbientColor,
        Callback = function(Value)
            VisualSettings.AmbientColor = Value
            UpdateAmbient()
        end
    })

    PLRvisuals2:AddSlider('AmbientBrightnessSlider', {
        Text = 'Ambient Brightness',
        Min = 0,
        Max = 10,
        Default = 2,
        Rounding = 1,
        Callback = function(Value)
            VisualSettings.AmbientBrightness = Value
            UpdateAmbient()
        end
    })


    local playertab = Tabs.Players:AddLeftGroupbox('Dashboard')
    local PlayerInfoCategory = Tabs.Players:AddRightGroupbox("Player Info")


    local SelectedPlayer = nil
    local OriginalPosition = nil
    local BringActive = false
    local ViewActive = false
    local LockedTarget = nil
    local PlayerDropdown = nil
    local PlayerInfoLabels = {}

    function UpdatePlayerInfo()
        for _, label in ipairs(PlayerInfoLabels) do
            label:SetText("")
        end
        PlayerInfoLabels = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            local displayName = player.DisplayName or "Unknown"
            local accountAge = player.AccountAge or 0
            local wantedLevel = "Unknown"
            local dataFolder = player:FindFirstChild("DataFolder")
            
            if dataFolder and dataFolder:FindFirstChild("Information") and dataFolder.Information:FindFirstChild("Wanted") then
                wantedLevel = tostring(dataFolder.Information.Wanted.Value)
            end
            
            local label = PlayerInfoCategory:AddLabel(string.format(
                "Name: %s\nDisplay Name: %s\nAccount Age: %d days\nWanted Level: %s",
                player.Name, displayName, accountAge, wantedLevel
            ))
            table.insert(PlayerInfoLabels, label)
        end
    end

    function TeleportToTarget(targetPosition, offset)
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = targetPosition * offset
        end
    end

    function ResetCamera()
        Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character
    end

    function StartBringLoop()
        BringActive = true
        OriginalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame -- Save original position
        
        while BringActive do
            if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local target = SelectedPlayer.Character
                local targetHRP = target:FindFirstChild("HumanoidRootPart")
                local targetKO = target:FindFirstChild("BodyEffects") and target.BodyEffects:FindFirstChild("K.O")
                
                if targetKO and targetKO.Value then
                    TeleportToTarget(OriginalPosition, CFrame.new())
                    break 
                else
                    TeleportToTarget(targetHRP.CFrame, CFrame.new(0, -10, 0))
                end
            end
            task.wait(0.1)
        end
    end

    function StopBringLoop()
        BringActive = false
        if OriginalPosition then
            TeleportToTarget(OriginalPosition, CFrame.new())
        end
    end

    playertab:AddButton({
        Text = "Goto Selected Player",
        Tooltip = "Teleport to the selected player's position.",
        Func = function()
            if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character.PrimaryPart then
                TeleportToTarget(SelectedPlayer.Character.PrimaryPart.CFrame, CFrame.new())
            else
                warn("No valid player selected or target player has no character.")
            end
        end
    })

    playertab:AddToggle("ViewToggle", {
        Text = "View Selected Player",
        Default = false,
        Callback = function(Value)
            ViewActive = Value
            if ViewActive then
                if SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character.PrimaryPart then
                    Workspace.CurrentCamera.CameraSubject = SelectedPlayer.Character.PrimaryPart
                else
                    warn("No valid player selected or target player has no character.")
                    ViewActive = false
                end
            else
                ResetCamera()
            end
        end
    })

    playertab:AddToggle("BringToggle", {
        Text = "Bring",
        Default = false,
        Callback = function(Value)
            if Value then
                if SelectedPlayer then
                    StartBringLoop()
                else
                    warn("No player selected for bring functionality.")
                end
            else
                StopBringLoop()
            end
        end
    })

    PlayerDropdown = playertab:AddDropdown("PlayerSelection", {
        Values = {},
        Default = 1,
        Text = "Select Player",
        Tooltip = "Select a target for bring functionality.",
        Callback = function(selectedName)
            SelectedPlayer = Players:FindFirstChild(selectedName)
            LockedTarget = SelectedPlayer
            if SelectedPlayer then
                warn("Target selected: " .. SelectedPlayer.Name)
            else
                warn("No valid target selected.")
            end
        end
    })

    function UpdatePlayerDropdown()
        local playerNames = {}
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                table.insert(playerNames, player.Name)
            end
        end
        if PlayerDropdown then
            PlayerDropdown:SetValues(playerNames)
        end
        UpdatePlayerInfo()
    end

    Players.PlayerAdded:Connect(UpdatePlayerDropdown)
    Players.PlayerRemoving:Connect(function(removedPlayer)
        if SelectedPlayer == removedPlayer then
            SelectedPlayer = nil
            LockedTarget = nil
            ResetCamera()
        end
        UpdatePlayerDropdown()
    end)

    UpdatePlayerDropdown()

    local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

    MenuGroup:AddButton('Unload', function() Library:Unload() end)
    MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

    Library.ToggleKeybind = Options.MenuKeybind
    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    SaveManager:IgnoreThemeSettings()
    ThemeManager:SetFolder('MyScriptHub')
    SaveManager:SetFolder('MyScriptHub/specific-game')
    SaveManager:BuildConfigSection(Tabs['UI Settings'])
    ThemeManager:ApplyToTab(Tabs['UI Settings'])
    SaveManager:LoadAutoloadConfig()
