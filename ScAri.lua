-- Speed & Infinite Jump GUI with Adjustable Speed (Saved in ARI HUB.json)
-- Default speed: 16, Max: 10000000

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- File Handling
local fileName = "ARI HUB.json"
local function loadSettings()
    if isfile(fileName) then
        return HttpService:JSONDecode(readfile(fileName))
    else
        return {speed = 16}
    end
end

local function saveSettings(settings)
    writefile(fileName, HttpService:JSONEncode(settings))
end

local settings = loadSettings()

-- Variables
local speedEnabled = false
local UIS = game:GetService("UserInputService")

-- Anti AFK
for _, v in pairs(getconnections or get_signal_cons(getrawmetatable(game.Players.LocalPlayer.Idled))) do
    v:Disable()
end

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 160)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Speed & Inf Jump"
Title.TextScaled = true
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Speed Toggle Button
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

-- Inf Jump Toggle Button
local JumpBtn = Instance.new("TextButton")
JumpBtn.Size = UDim2.new(1, -20, 0, 40)
JumpBtn.Position = UDim2.new(0, 10, 0, 120)
JumpBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
JumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JumpBtn.Text = "Inf Jump: OFF"
JumpBtn.TextScaled = true
JumpBtn.Font = Enum.Font.GothamBold
JumpBtn.Parent = MainFrame
Instance.new("UICorner", JumpBtn).CornerRadius = UDim.new(0, 8)

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
    if val and val >= 16 and val <= 10000000 then
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

-- Inf Jump Logic
local infJumpEnabled = false
UIS.JumpRequest:Connect(function()
    if infJumpEnabled then
        local character = player.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end
end)

JumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    JumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
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
