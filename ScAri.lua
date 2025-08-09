-- Speed & Infinite Jump GUI Script for Roblox (Delta Executor Compatible)
-- Added Anti Clip toggle (CanCollide toggle on HumanoidRootPart)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local fileName = "ARI HUB.json"
local function loadSettings()
    if isfile(fileName) then
        return HttpService:JSONDecode(readfile(fileName))
    else
        return {speed = 16, jumpPower = 50}
    end
end

local function saveSettings(settings)
    writefile(fileName, HttpService:JSONEncode(settings))
end

local settings = loadSettings()

local speedEnabled = false
local infJumpEnabled = false
local antiClipEnabled = false
local UIS = game:GetService("UserInputService")

-- Infinite Jump Handler
UIS.JumpRequest:Connect(function()
    if infJumpEnabled then
        local character = player.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            local hum = character:FindFirstChildOfClass("Humanoid")
            hum.UseJumpPower = true
            hum.JumpPower = tonumber(settings.jumpPower) or 50
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Anti Clip Function
local function setAntiClip(state)
    local character = player.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CanCollide = not state
        end
    end
end

-- Update Anti Clip on character spawn
local function onCharacterAdded(char)
    local hum = char:WaitForChild("Humanoid")
    if speedEnabled then
        hum.WalkSpeed = tonumber(settings.speed) or 16
    else
        hum.WalkSpeed = 16
    end
    -- Apply anti clip state on respawn
    setAntiClip(antiClipEnabled)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- Create GUI (Persistent)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 280) -- tambah tinggi untuk anti clip button
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, -60, 0, 30)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "Speed & Jump Control"
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.TextScaled = true
TitleBar.Font = Enum.Font.GothamBold
TitleBar.Parent = MainFrame

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

-- Anti Clip Button
local AntiClipBtn = Instance.new("TextButton")
AntiClipBtn.Size = UDim2.new(1, -20, 0, 40)
AntiClipBtn.Position = UDim2.new(0, 10, 0, 210)
AntiClipBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
AntiClipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiClipBtn.Text = "Anti Clip: OFF"
AntiClipBtn.TextScaled = true
AntiClipBtn.Font = Enum.Font.GothamBold
AntiClipBtn.Parent = MainFrame
Instance.new("UICorner", AntiClipBtn).CornerRadius = UDim.new(0, 8)

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
    if val and val >= 50 and val <= 1000 then
        settings.jumpPower = val
        saveSettings(settings)
    else
        JumpBox.Text = tostring(settings.jumpPower)
    end
end)

-- Anti Clip Toggle Logic
AntiClipBtn.MouseButton1Click:Connect(function()
    antiClipEnabled = not antiClipEnabled
    AntiClipBtn.Text = antiClipEnabled and "Anti Clip: ON" or "Anti Clip: OFF"
    setAntiClip(antiClipEnabled)
end)

-- Minimize Logic
local minimized = false
local elementsToToggle = {SpeedBtn, SpeedBox, JumpBtn, JumpBox, AntiClipBtn}

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, obj in ipairs(elementsToToggle) do
        obj.Visible = not minimized
    end
    MainFrame.Size = minimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 280)
    MinBtn.Text = minimized and "+" or "-"
end)

-- Close Logic
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Initial apply anti clip if needed on current character
if player.Character then
    setAntiClip(antiClipEnabled)
end
