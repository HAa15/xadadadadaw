-- Load essential services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local LockedTarget = nil

-- Error Prevention
if not LocalPlayer then
    warn("LocalPlayer not found! Waiting...")
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Wait for Config to be loaded and initialize default settings
while not getgenv().Config do
    task.wait()
end

-- Initialize Config structure if parts are missing
if not getgenv().Config.Settings then
    getgenv().Config.Settings = {
        SilentAim = {
            HitPart = "Head",
            FOV = 145
        },
        Fly = {
            Speed = 50
        },
        Speed = {
            Value = 16
        },
        ESP = {
            Color = Color3.fromRGB(255, 255, 255),
            TextSize = 14
        }
    }
end

if not getgenv().Config.States then
    getgenv().Config.States = {
        SilentAim = false,
        KillAura = false,
        Fly = false,
        ESP = false,
        Speed = false,
        AntiStomp = false
    }
end

if not getgenv().Config.Keybinds then
    getgenv().Config.Keybinds = {
        SilentAim = "C",
        KillAura = "K",
        Fly = "X",
        ESP = "Z",
        AntiStomp = "G"
    }
end

-- Notification Function
function notify(title, message, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title or "Notification",
        Text = message,
        Duration = duration or 3,
        Icon = "rbxassetid://6031071053"
    })
end

-- Keybind Handler with error handling
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Handle manual shooting when silent aim is enabled
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Config.States.SilentAim and LockedTarget then
        ShootTarget(LockedTarget)
    end
end)

-- Silent Aim Logic
function performSilentAim()
    if not Config or not Config.States or not Config.Settings then return end
    
    -- Only update LockedTarget, don't auto-shoot
    if Config.States.SilentAim then
        local closestPlayer = GetClosestTargetToCursor()
        if closestPlayer and closestPlayer.Character then
            LockedTarget = closestPlayer.Character:FindFirstChild(Config.Settings.SilentAim.HitPart or "Head")
        end
    else
        LockedTarget = nil
    end
end

-- Fly Logic
function updateFly()
    if not Config or not Config.States or not Config.Settings then return end
    
    local character = LocalPlayer.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not Config.States.Fly then
        -- Reset velocity when fly is disabled
        if humanoidRootPart then
            humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        end
        return
    end
    
    if Config.States.Fly and humanoidRootPart then
        local direction = Vector3.new()
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            direction = direction + Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            direction = direction - Camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            direction = direction - Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            direction = direction + Camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            direction = direction + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction = direction - Vector3.new(0, 1, 0)
        end
        
        humanoidRootPart.Velocity = direction * (Config.Settings.Fly.Speed or 50)
    end
end

-- Walkspeed Logic
function updateWalkspeed()
    if not Config or not Config.States or not Config.Settings then return end
    
    if Config.States.Speed then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        
        if humanoid then
            humanoid.WalkSpeed = Config.Settings.Speed.Value or 16
        end
    end
end

-- Name ESP Logic
function updateESP()
    if not Config or not Config.States or not Config.Settings then return end
    
    if Config.States.ESP then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local character = player.Character
                if character then
                    -- Create or update ESP elements
                    local head = character:FindFirstChild("Head")
                    if head then
                        local esp = head:FindFirstChild("ESP") or Instance.new("BillboardGui")
                        esp.Name = "ESP"
                        esp.AlwaysOnTop = true
                        esp.Size = UDim2.new(0, 100, 0, 40)
                        esp.StudsOffset = Vector3.new(0, 2, 0)
                        esp.Parent = head
                        
                        local nameLabel = esp:FindFirstChild("NameLabel") or Instance.new("TextLabel")
                        nameLabel.Name = "NameLabel"
                        nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                        nameLabel.BackgroundTransparency = 1
                        nameLabel.Text = player.Name
                        nameLabel.TextColor3 = Config.Settings.ESP.Color or Color3.fromRGB(255, 255, 255)
                        nameLabel.TextSize = Config.Settings.ESP.TextSize or 14
                        nameLabel.Parent = esp
                    end
                end
            end
        end
    else
        -- Remove ESP elements when disabled
        for _, player in ipairs(Players:GetPlayers()) do
            local character = player.Character
            if character then
                local head = character:FindFirstChild("Head")
                if head then
                    local esp = head:FindFirstChild("ESP")
                    if esp then esp:Destroy() end
                end
            end
        end
    end
end

-- Add these to your RunService.Heartbeat connection
RunService.Heartbeat:Connect(function()
    performSilentAim() -- Always run to handle enable/disable
    updateFly() -- Always run to handle enable/disable
    
    if Config.States.Speed then
        updateWalkspeed()
    end
    
    if Config.States.ESP then
        updateESP()
    end
end)

-- Character Connections
LocalPlayer.CharacterAdded:Connect(function(character)
    -- Setup character connections here
end)

if LocalPlayer.Character then
    -- Initial character setup
end

-- Add these functions for Silent Aim
function GetClosestTargetToCursor()
    local mousePosition = UserInputService:GetMouseLocation()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if IsValidTarget(player) then
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                local screenPoint, onScreen = Camera:WorldToScreenPoint(humanoidRootPart.Position)
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

function IsValidTarget(player)
    if not player.Character then return false end
    if player == LocalPlayer then return false end
    if not player.Character:FindFirstChild("Humanoid") then return false end
    if player.Character.Humanoid.Health <= 0 then return false end
    return true
end

function ShootTarget(Target)
    if not Target then return end
    
    local Tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if Tool and Tool:FindFirstChild("Handle") then
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

-- Add a function to reset all features
function resetAllFeatures()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    -- Reset Silent Aim
    LockedTarget = nil

    -- Reset Fly
    if humanoidRootPart then
        humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
    end

    -- Reset Walkspeed
    if humanoid then
        humanoid.WalkSpeed = 16
    end

    -- Reset ESP
    for _, player in ipairs(Players:GetPlayers()) do
        local playerCharacter = player.Character
        if playerCharacter then
            local head = playerCharacter:FindFirstChild("Head")
            if head then
                local esp = head:FindFirstChild("ESP")
                if esp then esp:Destroy() end
            end
        end
    end
end

-- Modify the keybind handler
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    local keyPressed = input.KeyCode.Name
    local Config = getgenv().Config
    
    pcall(function()
        -- Silent Aim Toggle
        if keyPressed == Config.Keybinds.SilentAim then
            Config.States.SilentAim = not Config.States.SilentAim
            if not Config.States.SilentAim then
                LockedTarget = nil
            end
            notify("Silent Aim", Config.States.SilentAim and "Enabled" or "Disabled")
        end
        
        -- Fly Toggle
        if keyPressed == Config.Keybinds.Fly then
            Config.States.Fly = not Config.States.Fly
            if not Config.States.Fly and LocalPlayer.Character then
                LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            end
            notify("Flight", Config.States.Fly and "Enabled" or "Disabled")
        end
        
        -- ESP Toggle
        if keyPressed == Config.Keybinds.ESP then
            Config.States.ESP = not Config.States.ESP
            if not Config.States.ESP then
                -- Remove all ESP elements
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character then
                        local head = player.Character:FindFirstChild("Head")
                        if head then
                            local esp = head:FindFirstChild("ESP")
                            if esp then esp:Destroy() end
                        end
                    end
                end
            end
            notify("ESP", Config.States.ESP and "Enabled" or "Disabled")
        end
    end)
end)

-- Add this to handle script cleanup
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(resetAllFeatures) 
