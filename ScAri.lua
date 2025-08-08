--[[
    Roblox Speed & Infinite Jump Script (Fixed GUI Version)
    Features:
    - Custom speed (default 16, max 1000)
    - Infinite jump
    - Beautiful GUI
    - Works with Delta Executor
]]

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Player setup
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedControlGUI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Title.Text = "Speed & Jump Control"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- Speed Control
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(0.8, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.1, 0, 0.3, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 16"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

local SpeedSlider = Instance.new("Frame")
SpeedSlider.Name = "SpeedSlider"
SpeedSlider.Size = UDim2.new(0.8, 0, 0, 20)
SpeedSlider.Position = UDim2.new(0.1, 0, 0.4, 0)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
SpeedSlider.BorderSizePixel = 0
SpeedSlider.Parent = MainFrame

local SliderCorner = Instance.new("UICorner")
SliderCorner.CornerRadius = UDim.new(0, 4)
SliderCorner.Parent = SpeedSlider

local SliderFill = Instance.new("Frame")
SliderFill.Name = "SliderFill"
SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
SliderFill.Position = UDim2.new(0, 0, 0, 0)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SpeedSlider

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 4)
FillCorner.Parent = SliderFill

local SliderButton = Instance.new("TextButton")
SliderButton.Name = "SliderButton"
SliderButton.Size = UDim2.new(1, 0, 1, 0)
SliderButton.Position = UDim2.new(0, 0, 0, 0)
SliderButton.BackgroundTransparency = 1
SliderButton.Text = ""
SliderButton.Parent = SpeedSlider

-- Toggle Buttons
local SpeedToggle = Instance.new("TextButton")
SpeedToggle.Name = "SpeedToggle"
SpeedToggle.Size = UDim2.new(0.35, 0, 0, 30)
SpeedToggle.Position = UDim2.new(0.1, 0, 0.6, 0)
SpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SpeedToggle.Text = "Enable Speed"
SpeedToggle.TextColor3 = Color3.white
SpeedToggle.Font = Enum.Font.GothamBold
SpeedToggle.TextSize = 14
SpeedToggle.Parent = MainFrame

local ToggleCorner1 = Instance.new("UICorner")
ToggleCorner1.CornerRadius = UDim.new(0, 6)
ToggleCorner1.Parent = SpeedToggle

local JumpToggle = Instance.new("TextButton")
JumpToggle.Name = "JumpToggle"
JumpToggle.Size = UDim2.new(0.35, 0, 0, 30)
JumpToggle.Position = UDim2.new(0.55, 0, 0.6, 0)
JumpToggle.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
JumpToggle.Text = "Enable Jump"
JumpToggle.TextColor3 = Color3.white
JumpToggle.Font = Enum.Font.GothamBold
JumpToggle.TextSize = 14
JumpToggle.Parent = MainFrame

local ToggleCorner2 = Instance.new("UICorner")
ToggleCorner2.CornerRadius = UDim.new(0, 6)
ToggleCorner2.Parent = JumpToggle

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0.8, 0, 0, 30)
CloseButton.Position = UDim2.new(0.1, 0, 0.8, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
CloseButton.Text = "Close GUI"
CloseButton.TextColor3 = Color3.white
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- Variables
local speedEnabled = false
local jumpEnabled = false
local currentSpeed = 16

-- Slider functionality
local function updateSlider(value)
    local min = 16
    local max = 1000
    local percent = (value - min) / (max - min)
    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
    SpeedLabel.Text = "Speed: " .. math.floor(value)
    currentSpeed = value
    
    if speedEnabled then
        humanoid.WalkSpeed = currentSpeed
    end
end

SliderButton.MouseButton1Down:Connect(function()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local mouse = game:GetService("Players").LocalPlayer:GetMouse()
        local x = math.clamp(mouse.X - SpeedSlider.AbsolutePosition.X, 0, SpeedSlider.AbsoluteSize.X)
        local percent = x / SpeedSlider.AbsoluteSize.X
        local value = math.floor(16 + (1000 - 16) * percent)
        updateSlider(value)
    end)
    
    local function disconnect()
        connection:Disconnect()
    end
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            disconnect()
        end
    end)
end)

-- Initialize slider
updateSlider(16)

-- Speed functionality
SpeedToggle.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        SpeedToggle.Text = "Disable Speed"
        humanoid.WalkSpeed = currentSpeed
        
        -- Keep speed applied
        humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if speedEnabled and humanoid.WalkSpeed ~= currentSpeed then
                humanoid.WalkSpeed = currentSpeed
            end
        end)
    else
        SpeedToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        SpeedToggle.Text = "Enable Speed"
        humanoid.WalkSpeed = 16
    end
end)

-- Infinite jump functionality
JumpToggle.MouseButton1Click:Connect(function()
    jumpEnabled = not jumpEnabled
    if jumpEnabled then
        JumpToggle.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        JumpToggle.Text = "Disable Jump"
        
        -- Infinite jump
        UIS.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == Enum.KeyCode.Space then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    else
        JumpToggle.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        JumpToggle.Text = "Enable Jump"
    end
end)

-- Close GUI
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Character respawn handling
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    
    if speedEnabled then
        humanoid.WalkSpeed = currentSpeed
    end
end)
