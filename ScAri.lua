-- GUI Pengatur Speed & Infinite Jump + Input Speed + Save Data (ScAri.json) + Aurora UI
-- Max Speed = 1000, Default = 16
-- Kompatibel Delta Executor

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variabel kontrol
local maxSpeed = 1000
local defaultSpeed = 16
local customSpeed = defaultSpeed
local speedOn = false
local infJumpOn = false
local saveFile = "ScAri.json"
local minimized = false

-- Fungsi Simpan & Load Data
local function saveData()
    local data = {
        customSpeed = customSpeed,
        speedOn = speedOn,
        infJumpOn = infJumpOn
    }
    writefile(saveFile, HttpService:JSONEncode(data))
end

local function loadData()
    if isfile(saveFile) then
        local data = HttpService:JSONDecode(readfile(saveFile))
        customSpeed = data.customSpeed or defaultSpeed
        speedOn = data.speedOn or false
        infJumpOn = data.infJumpOn or false
    end
end

pcall(loadData)

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 200)
Frame.Position = UDim2.new(0.05, 0, 0.3, 0)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = Frame

-- Animasi Aurora / Rainbow
spawn(function()
    local hue = 0
    while RunService.RenderStepped:Wait() do
        hue = (hue + 0.005) % 1
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
