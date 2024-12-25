-- Load essential services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Error Prevention
if not LocalPlayer then
    warn("LocalPlayer not found! Waiting...")
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- Wait for Config to be loaded
while not getgenv().Config do
    task.wait()
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
    
    local keyPressed = input.KeyCode.Name
    local Config = getgenv().Config
    
    pcall(function()
        -- Silent Aim Toggle
        if keyPressed == Config.Keybinds.SilentAim then
            Config.States.SilentAim = not Config.States.SilentAim
            notify("Silent Aim", Config.States.SilentAim and "Enabled" or "Disabled")
        end
        
        -- Kill Aura Toggle
        if keyPressed == Config.Keybinds.KillAura then
            Config.States.KillAura = not Config.States.KillAura
            notify("Kill Aura", Config.States.KillAura and "Enabled" or "Disabled")
        end
        
        -- Fly Toggle
        if keyPressed == Config.Keybinds.Fly then
            Config.States.Fly = not Config.States.Fly
            notify("Flight", Config.States.Fly and "Enabled" or "Disabled")
        end
        
        -- ESP Toggle
        if keyPressed == Config.Keybinds.ESP then
            Config.States.ESP = not Config.States.ESP
            notify("ESP", Config.States.ESP and "Enabled" or "Disabled")
        end
        
        -- Anti Stomp Toggle
        if keyPressed == Config.Keybinds.AntiStomp then
            Config.States.AntiStomp = not Config.States.AntiStomp
            notify("Anti Stomp", Config.States.AntiStomp and "Enabled" or "Disabled")
        end
    end)
end)

-- Silent Aim Logic
function performSilentAim()
    if Config.States.SilentAim then
        local closestPlayer = GetClosestTargetToCursor()
        if closestPlayer and closestPlayer.Character then
            LockedTarget = closestPlayer.Character:FindFirstChild(Config.Settings.SilentAim.HitPart)
            if LockedTarget then
                ShootTarget(LockedTarget)
            end
        end
    end
end

-- Fly Logic
function updateFly()
    if Config.States.Fly then
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoidRootPart then
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
            
            humanoidRootPart.Velocity = direction * Config.Settings.Fly.Speed
        end
    end
end

-- Walkspeed Logic
function updateWalkspeed()
    if Config.States.Speed then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        
        if humanoid then
            humanoid.WalkSpeed = Config.Settings.Speed.Value
        end
    end
end

-- Name ESP Logic
function updateESP()
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
                        nameLabel.TextColor3 = Config.Settings.ESP.Color
                        nameLabel.TextSize = Config.Settings.ESP.TextSize
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
    if Config.States.SilentAim then
        performSilentAim()
    end
    
    if Config.States.Fly then
        updateFly()
    end
    
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
