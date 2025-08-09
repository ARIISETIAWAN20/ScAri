-- Speed & Infinite Jump GUI Script for Roblox (Delta Executor Compatible)
-- Default speed: 16, Max speed: 100000
-- Features: Toggle Speed, Toggle Infinite Jump, Minimize GUI

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variables
local speedEnabled = false
local infJumpEnabled = false
local defaultSpeed = 16
local maxSpeed = 100000
local UIS = game:GetService("UserInputService")

-- Infinite Jump Handler
UIS.JumpRequest:Connect(function()
    if infJumpEnabled then
        humanoid:ChangeState("Jumping")
    end
end)

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 150)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Title Bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, -30, 0, 30)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "Speed & Jump Control"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.TextScaled = true
TitleBar.Font = Enum.Font.GothamBold
TitleBar.Parent = MainFrame

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -30, 0, 0)
MinBtn.Text = "-"
MinBtn.TextScaled = true
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Parent = MainFrame

local MinCorner = Instance.new("UICorner", MinBtn)
MinCorner.CornerRadius = UDim.new(0, 8)

-- Buttons
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(1, -20, 0, 40)
SpeedBtn.Position = UDim2.new(0, 10, 0, 40)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Text = "Speed: OFF"
SpeedBtn.TextScaled = true
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 8)

local JumpBtn = Instance.new("TextButton")
JumpBtn.Size = UDim2.new(1, -20, 0, 40)
JumpBtn.Position = UDim2.new(0, 10, 0, 90)
JumpBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBtn.Text = "Inf Jump: OFF"
JumpBtn.TextScaled = true
JumpBtn.Font = Enum.Font.GothamBold
JumpBtn.Parent = MainFrame
Instance.new("UICorner", JumpBtn).CornerRadius = UDim.new(0, 8)

-- Button Logic
SpeedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        humanoid.WalkSpeed = maxSpeed
        SpeedBtn.Text = "Speed: ON"
    else
        humanoid.WalkSpeed = defaultSpeed
        SpeedBtn.Text = "Speed: OFF"
    end
end)

JumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    JumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
end)

-- Minimize Logic
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        for _, obj in ipairs(MainFrame:GetChildren()) do
            if obj:IsA("TextButton") or obj:IsA("TextLabel") then
                if obj ~= TitleBar and obj ~= MinBtn then
                    obj.Visible = false
                end
            end
        end
        MainFrame.Size = UDim2.new(0, 250, 0, 30)
        MinBtn.Text = "+"
    else
        for _, obj in ipairs(MainFrame:GetChildren()) do
            obj.Visible = true
        end
        MainFrame.Size = UDim2.new(0, 250, 0, 150)
        MinBtn.Text = "-"
    end
end)
