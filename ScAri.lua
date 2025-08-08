-- GUI Pengatur Speed & Infinite Jump untuk Roblox (Kompatibel Delta Executor)
-- Max Speed = 1000, Default = 16
-- Infinite Jump ON/OFF
-- Dibuat sederhana agar ringan di HP

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variabel kontrol
local speedOn = false
local infJumpOn = false
local maxSpeed = 1000
local defaultSpeed = 16

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- Tombol Speed Toggle
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -20, 0, 40)
speedBtn.Position = UDim2.new(0, 10, 0, 10)
speedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.Text = "Speed: OFF"
speedBtn.Parent = Frame

speedBtn.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    if speedOn then
        humanoid.WalkSpeed = maxSpeed
        speedBtn.Text = "Speed: ON"
    else
        humanoid.WalkSpeed = defaultSpeed
        speedBtn.Text = "Speed: OFF"
    end
end)

-- Tombol Infinite Jump Toggle
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(1, -20, 0, 40)
jumpBtn.Position = UDim2.new(0, 10, 0, 60)
jumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.Text = "Inf Jump: OFF"
jumpBtn.Parent = Frame

jumpBtn.MouseButton1Click:Connect(function()
    infJumpOn = not infJumpOn
    jumpBtn.Text = infJumpOn and "Inf Jump: ON" or "Inf Jump: OFF"
end)

-- Infinite Jump Logic
UIS.JumpRequest:Connect(function()
    if infJumpOn and humanoid then
        humanoid:ChangeState("Jumping")
    end
end)

-- Pastikan speed kembali normal jika mati
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    if speedOn then
        humanoid.WalkSpeed = maxSpeed
    else
        humanoid.WalkSpeed = defaultSpeed
    end
end)
