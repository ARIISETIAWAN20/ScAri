-- Speed & Infinite Jump GUI Script for Roblox (Delta Executor Compatible)
-- Default speed: 16, Max speed: 100000
-- Default JumpPower: 0 (Roblox default), Max JumpPower: 100
-- Features: Adjustable Speed & JumpPower, Toggle Speed, Toggle Infinite Jump, Minimize/Maximize, Close GUI, Persistent across respawn

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- File Handling
local fileName = "ARI HUB.json"
local function loadSettings()
    if isfile(fileName) then
        return HttpService:JSONDecode(readfile(fileName))
    else
        return {speed = 16, jumpPower = 0}
    end
end

local function saveSettings(settings)
    writefile(fileName, HttpService:JSONEncode(settings))
end

local settings = loadSettings()

-- Variables
local speedEnabled = false
local infJumpEnabled = false

-- Infinite Jump Handler
UIS.JumpRequest:Connect(function()
    if infJumpEnabled then
        local character = player.Character
        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = tonumber(settings.jumpPower) or 0
            hum:ChangeState("Jumping")
        end
    end
end)

-- Create GUI (Persistent)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 240)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Title Bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, -60, 0, 30)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "Speed & Jump Control"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.TextScaled = true
TitleBar.Font = Enum.Font.GothamBold
TitleBar.Parent = MainFrame

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Text = "-"
MinBtn.TextScaled = true
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
MinBtn.ZIndex = 2

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.ZIndex = 2

-- Speed Button
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

-- Speed TextBox
local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(1, -20, 0, 30)
SpeedBox.Position = UDim2.new(0, 10, 0, 85)
SpeedBox.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.Text = tostring(settings.speed)
SpeedBox.TextScaled = true
SpeedBox.Font = Enum.Font.GothamBold
SpeedBox.Parent = MainFrame
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 8)

-- Jump Button
local JumpBtn = Instance.new("TextButton")
JumpBtn.Size = UDim2.new(1, -20, 0, 40)
JumpBtn.Position = UDim2.new(0, 10, 0, 125)
JumpBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBtn.Text = "Inf Jump: OFF"
JumpBtn.TextScaled = true
JumpBtn.Font = Enum.Font.GothamBold
JumpBtn.Parent = MainFrame
Instance.new("UICorner", JumpBtn).CornerRadius = UDim.new(0, 8)

-- Jump Power TextBox
local JumpBox = Instance.new("TextBox")
JumpBox.Size = UDim2.new(1, -20, 0, 30)
JumpBox.Position = UDim2.new(0, 10, 0, 170)
JumpBox.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
JumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBox.Text = tostring(settings.jumpPower)
JumpBox.TextScaled = true
JumpBox.Font = Enum.Font.GothamBold
JumpBox.Parent = MainFrame
Instance.new("UICorner", JumpBox).CornerRadius = UDim.new(0, 8)

-- Speed Toggle Logic
SpeedBtn.MouseButton1Click:Connect(function()
    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    speedEnabled = not speedEnabled
    if speedEnabled then
        hum.WalkSpeed = tonumber(settings.speed) or 16
        SpeedBtn.Text = "Speed: ON"
    else
        hum.WalkSpeed = 16
        SpeedBtn.Text = "Speed: OFF"
    end
end)

-- Save Speed Setting
SpeedBox.FocusLost:Connect(function()
    local val = tonumber(SpeedBox.Text)
    if val and val >= 16 and val <= 100000 then
        settings.speed = val
        saveSettings(settings)
        if speedEnabled then
            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    else
        SpeedBox.Text = tostring(settings.speed)
    end
end)

-- Jump Toggle Logic
JumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    JumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
end)

-- Save Jump Power Setting
JumpBox.FocusLost:Connect(function()
    local val = tonumber(JumpBox.Text)
    if val and val >= 0 and val <= 100 then
        settings.jumpPower = val
        saveSettings(settings)
    else
        JumpBox.Text = tostring(settings.jumpPower)
    end
end)

-- Minimize Logic
local minimized = false
local elementsToToggle = {SpeedBtn, SpeedBox, JumpBtn, JumpBox}

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, obj in ipairs(elementsToToggle) do
        obj.Visible = not minimized
    end
    MainFrame.Size = minimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 240)
    MinBtn.Text = minimized and "+" or "-"
end)

-- Close Logic
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Restore on Respawn
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if speedEnabled then
        hum.WalkSpeed = tonumber(settings.speed) or 16
    else
        hum.WalkSpeed = 16
    end
end)
