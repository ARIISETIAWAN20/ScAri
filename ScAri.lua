-- Versi lengkap GUI Speed & Infinite Jump dengan efek aurora + tombol minimize yang tetap terlihat

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local fileName = "ScAri.json"
local speed = 16
local speedOn = false
local infJumpOn = false

local function saveData()
    writefile(fileName, HttpService:JSONEncode({speed = speed, speedOn = speedOn, infJumpOn = infJumpOn}))
end

local function loadData()
    if isfile(fileName) then
        local data = HttpService:JSONDecode(readfile(fileName))
        speed = data.speed or 16
        speedOn = data.speedOn or false
        infJumpOn = data.infJumpOn or false
    end
end

loadData()

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local mainFrame = Instance.new("Frame", ScreenGui)
mainFrame.Size = UDim2.new(0, 200, 0, 150)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
mainFrame.Active = true
mainFrame.Draggable = true

local minimizeButton = Instance.new("TextButton", mainFrame)
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -30, 0, 5)
minimizeButton.Text = "-"

local speedBox = Instance.new("TextBox", mainFrame)
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 40)
speedBox.PlaceholderText = "Speed"
speedBox.Text = tostring(speed)

local speedToggle = Instance.new("TextButton", mainFrame)
speedToggle.Size = UDim2.new(1, -20, 0, 30)
speedToggle.Position = UDim2.new(0, 10, 0, 80)
speedToggle.Text = "Speed: OFF"

local jumpToggle = Instance.new("TextButton", mainFrame)
jumpToggle.Size = UDim2.new(1, -20, 0, 30)
jumpToggle.Position = UDim2.new(0, 10, 0, 120)
jumpToggle.Text = "Inf Jump: OFF"

spawn(function()
    while wait() do
        local t = tick() * 0.5
        local r = math.sin(t) * 127 + 128
        local g = math.sin(t + 2) * 127 + 128
        local b = math.sin(t + 4) * 127 + 128
        mainFrame.BackgroundColor3 = Color3.fromRGB(r, g, b)
        minimizeButton.BackgroundColor3 = Color3.fromRGB(r, g, b)
    end
end)

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, v in pairs(mainFrame:GetChildren()) do
        if v ~= minimizeButton then
            v.Visible = not minimized
        end
    end
end)

speedBox.FocusLost:Connect(function(enter)
    if enter then
        local val = tonumber(speedBox.Text)
        if val and val >= 0 and val <= 1000000 then
            speed = val
            saveData()
            if speedOn then humanoid.WalkSpeed = speed end
        else
            speedBox.Text = tostring(speed)
        end
    end
end)

speedToggle.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    speedToggle.Text = "Speed: " .. (speedOn and "ON" or "OFF")
    humanoid.WalkSpeed = speedOn and speed or 16
    saveData()
end)

jumpToggle.MouseButton1Click:Connect(function()
    infJumpOn = not infJumpOn
    jumpToggle.Text = "Inf Jump: " .. (infJumpOn and "ON" or "OFF")
    saveData()
end)

UIS.JumpRequest:Connect(function()
    if infJumpOn then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    if speedOn then humanoid.WalkSpeed = speed end
end)

speedBox.Text = tostring(speed)
speedToggle.Text = "Speed: " .. (speedOn and "ON" or "OFF")
jumpToggle.Text = "Inf Jump: " .. (infJumpOn and "ON" or "OFF")
if speedOn then humanoid.WalkSpeed = speed end
local color = Color3.fromHSV(hue, 1, 1)
        Frame.BackgroundColor3 = color
    end
end)

-- Tombol Minimize
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -30, 0, 5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.Parent = Frame

minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, child in pairs(Frame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextBox") then
            if child ~= minimizeBtn then
                child.Visible = not minimized
            end
        end
    end
    if minimized then
        Frame.Size = UDim2.new(0, 60, 0, 30)
    else
        Frame.Size = UDim2.new(0, 200, 0, 200)
    end
end)

-- Tombol Speed Toggle
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -20, 0, 40)
speedBtn.Position = UDim2.new(0, 10, 0, 10)
speedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.Text = speedOn and "Speed: ON" or "Speed: OFF"
speedBtn.Parent = Frame

speedBtn.MouseButton1Click:Connect(function()
    speedOn = not speedOn
    if speedOn then
        humanoid.WalkSpeed = math.clamp(customSpeed, 0, maxSpeed)
        speedBtn.Text = "Speed: ON"
    else
        humanoid.WalkSpeed = defaultSpeed
        speedBtn.Text = "Speed: OFF"
    end
    saveData()
end)

-- TextBox untuk Input Speed
local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 55)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.PlaceholderText = "Set Speed (max 1000)"
speedBox.ClearTextOnFocus = false
speedBox.Text = tostring(customSpeed)
speedBox.Parent = Frame

speedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(speedBox.Text)
        if val then
            customSpeed = math.clamp(val, 0, maxSpeed)
            if speedOn then
                humanoid.WalkSpeed = customSpeed
            end
            saveData()
        end
    end
end)

-- Tombol Infinite Jump Toggle
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(1, -20, 0, 40)
jumpBtn.Position = UDim2.new(0, 10, 0, 90)
jumpBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.Text = infJumpOn and "Inf Jump: ON" or "Inf Jump: OFF"
jumpBtn.Parent = Frame

jumpBtn.MouseButton1Click:Connect(function()
    infJumpOn = not infJumpOn
    jumpBtn.Text = infJumpOn and "Inf Jump: ON" or "Inf Jump: OFF"
    saveData()
end)

-- Infinite Jump Logic
UIS.JumpRequest:Connect(function()
    if infJumpOn and humanoid then
        humanoid:ChangeState("Jumping")
    end
end)

-- Restore saat respawn
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    if speedOn then
        humanoid.WalkSpeed = customSpeed
    else
        humanoid.WalkSpeed = defaultSpeed
    end
end)

-- Terapkan setting awal setelah load
if speedOn then
    humanoid.WalkSpeed = customSpeed
else
    humanoid.WalkSpeed = defaultSpeed
end
