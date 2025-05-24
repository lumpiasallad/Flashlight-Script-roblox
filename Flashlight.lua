local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local backpack = game.Players.LocalPlayer.Backpack
local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local fixedDistance = 1 -- distace op da light
local defaultAngle = 45 -- angle op da  light

local tool = Instance.new("Tool")
tool.Name = "Flash Light"
tool.RequiresHandle = true
tool.Parent = backpack
tool.TextureId = "rbxassetid://96213441150462"
tool.GripForward = Vector3.new(-0.989, 0, 0.149)
tool.GripPos = Vector3.new(0.55, -0.1, -0.1)
tool.GripRight = Vector3.new(-0.149, 0, -0.989)
tool.GripUp = Vector3.new(0, 1, 0)


local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(1, 1, 1)
handle.CanCollide = false
handle.Parent = tool

local mesh = Instance.new("SpecialMesh")
mesh.MeshId = "rbxassetid://6158692587"
mesh.TextureId = "rbxassetid://6158692758"
mesh.Scale = Vector3.new(-0.1, 0.1, -0.1)
mesh.Parent = handle

local flashPart = nil
local updateConnection = nil

local function updateLightSource()
    local character = player.Character
    if not character then return end
    local head = character:FindFirstChild("Head")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not head or not hrp then return end
    
    -- Determine if first-person by checking the distance from head to camera
    local isFirstPerson = (camera.CFrame.Position - head.Position).Magnitude < 5
    local origin, direction
    
    if isFirstPerson then
        origin = camera.CFrame.Position
        direction = (mouse.Hit.p - origin).Unit
        handle.Transparency = 1
    else
        origin = hrp.Position + Vector3.new(0, 2, 0)
        direction = hrp.CFrame.LookVector
        handle.Transparency = 0
    end
    
    local newPos = origin + direction * fixedDistance
    if flashPart then
        flashPart.CFrame = CFrame.new(newPos, newPos + direction)
        local spot = flashPart:FindFirstChildOfClass("SpotLight")
        if spot then
            spot.Angle = defaultAngle
        end
    end
end

local function turnOnLight()
    if flashPart then return end
    
    flashPart = Instance.new("Part")
    flashPart.Name = "FlashLightPart"
    flashPart.Size = Vector3.new(6, 6, 0.1)
    flashPart.Transparency = 1
    flashPart.Anchored = true
    flashPart.CanCollide = false
    flashPart.Parent = workspace
    
    local spot = Instance.new("SpotLight")
    spot.Name = "FlashSpot"
    spot.Angle = defaultAngle
    spot.Brightness = 15 -- change for brightness
    spot.Range = 50
    spot.Shadows = false
    spot.Enabled = true
    spot.Parent = flashPart
    
    updateConnection = RunService.RenderStepped:Connect(updateLightSource)
end

local function turnOffLight()
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end
    if flashPart then
        flashPart:Destroy()
        flashPart = nil
    end
end

local lightOn = false

tool.Activated:Connect(function()
    lightOn = not lightOn
    if lightOn then
        turnOnLight()
    else
        turnOffLight()
    end
end)

tool.Equipped:Connect(function() end)

tool.Unequipped:Connect(function()
    turnOffLight()
    lightOn = false
end)

StarterGui:SetCore("SendNotification", {
    Title = "Flash Light!",
    Text = "Made by:Lumpia",
    Duration = 5,
    Icon = "rbxassetid://22595979"

})
