local StarterGui = game:GetService("StarterGui")
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "Made by: lumpia",
        Text = "Press F to toggle",
        Duration = 5,
    })
end)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local function createFlashLightTool()
    local tool = Instance.new("Tool")
    tool.Name = "Flash Light"
    tool.RequiresHandle = false  

    
    local lightEnabled = false
    local flashPart = nil       
    local updateConnection = nil 
    local toggleConnection = nil

    local fixedDistance = 25 -- change this number if you dont like the range

    -- Function to turn on the light
    local function turnOnLight()
        if lightEnabled then return end
        lightEnabled = true

        
        flashPart = Instance.new("Part")
        flashPart.Name = "FlashLightPart"
        flashPart.Size = Vector3.new(1, 1, 1)
        flashPart.Transparency = 1       
        flashPart.Anchored = true
        flashPart.CanCollide = false
        flashPart.Parent = workspace

        local spotLight = Instance.new("SpotLight", flashPart)
        spotLight.Name = "FlashLightSpot"
        spotLight.Angle = 45
        spotLight.Brightness = 10
        spotLight.Range = 50
        spotLight.Shadows = false

        local circleEffectPart = Instance.new("Part")
        circleEffectPart.Name = "CircleEffectPart"
        circleEffectPart.Size = Vector3.new(6, 6, 0.1)  -- set the circle size here
        circleEffectPart.Transparency = 1             
        circleEffectPart.Anchored = true
        circleEffectPart.CanCollide = false
        circleEffectPart.Parent = workspace

        updateConnection = RunService.RenderStepped:Connect(function()
            local character = player.Character
            if not character then return end

            local hrp = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")
            if not hrp or not head then return end

            local originPos
            local direction

            -- Determine if we are in first-person mode:
            local isFirstPerson = (camera.CFrame.Position - head.Position).Magnitude < 2
            if isFirstPerson then
                -- if in first person  use the mouse hit position if available.
                if mouse and mouse.Hit then
                    originPos = camera.CFrame.Position
                    direction = (mouse.Hit.p - camera.CFrame.Position).Unit
                else
                    originPos = camera.CFrame.Position
                    direction = camera.CFrame.LookVector
                end
            else
                -- In third person use position of character.
                originPos = hrp.Position + (hrp.CFrame.LookVector * 5) + Vector3.new(0, 2, 0)
                direction = hrp.CFrame.LookVector
            end

            flashPart.CFrame = CFrame.new(originPos, originPos + direction)

            local targetPos = originPos + direction * fixedDistance
            circleEffectPart.CFrame = CFrame.new(targetPos, targetPos - direction)
        end)

        print("Flashlight ON")
    end

    -- Function to turn the light off
    local function turnOffLight()
        if not lightEnabled then return end
        lightEnabled = false

        if updateConnection then
            updateConnection:Disconnect()
            updateConnection = nil
        end
        if flashPart then
            flashPart:Destroy()
            flashPart = nil
        end
        local circleEffectPart = workspace:FindFirstChild("CircleEffectPart")
        if circleEffectPart then
            circleEffectPart:Destroy()
        end

        print("Flashlight OFF")
    end

   
    -- Toggle Light with F When the Tool is Equipped
    tool.Equipped:Connect(function()
        toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.F then
                if lightEnabled then
                    turnOffLight()
                else
                    turnOnLight()
                end
            end
        end)
        print("Flash Light tool equipped.")
    end)

    tool.Unequipped:Connect(function()
        if toggleConnection then
            toggleConnection:Disconnect()
            toggleConnection = nil
        end
        turnOffLight()
        print("Flash Light tool unequipped.")
    end)

    return tool
end

local flashTool = createFlashLightTool()
flashTool.Parent = backpack
print("Press F to toggle")
