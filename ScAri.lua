local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local fileName = "ARI HUB.json"

-- Load/Save Settings
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

-- Variables
local speedEnabled = false
local infJumpEnabled = false
local antiClipEnabled = false

-- GUI creation code (sama seperti sebelumnya, saya ringkas di sini)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 320) -- tambah space buat ESP toggle
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -160)
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

local ESPBtn = Instance.new("TextButton")
ESPBtn.Size = UDim2.new(1, -20, 0, 40)
ESPBtn.Position = UDim2.new(0, 10, 0, 260)
ESPBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
ESPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPBtn.Text = "ESP: OFF"
ESPBtn.TextScaled = true
ESPBtn.Font = Enum.Font.GothamBold
ESPBtn.Parent = MainFrame
Instance.new("UICorner", ESPBtn).CornerRadius = UDim.new(0, 8)

-- States
local espEnabled = false

-- Infinite Jump Handler
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local character = player.Character
        if character then
            local hum = character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = tonumber(settings.jumpPower) or 50
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Anti Clip Implementation --
local function setAntiClip(state)
    local character = player.Character
    if not character then return end

    -- Loop all parts and set CanCollide
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not state
        end
    end

    -- HumanoidRootPart special handling
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CanCollide = not state
        if state then
            -- To prevent stuck, add BodyVelocity to maintain movement and disable physics pushback
            if not hrp:FindFirstChild("AntiClipVelocity") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "AntiClipVelocity"
                bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = hrp
            end
        else
            local bv = hrp:FindFirstChild("AntiClipVelocity")
            if bv then bv:Destroy() end
        end
    end
end

-- Speed Toggle
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

-- ESP Functions
local espLabels = {}

local function createEspLabel(plr)
    if plr == player then return end
    if espLabels[plr] then return end

    local character = plr.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP"
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = billboard

    espLabels[plr] = textLabel
end

local function removeEspLabel(plr)
    if espLabels[plr] then
        if espLabels[plr].Parent then
            espLabels[plr].Parent:Destroy()
        end
        espLabels[plr] = nil
    end
end

-- Update ESP every frame
RunService.Heartbeat:Connect(function()
    if not espEnabled then return end
    for plr, label in pairs(espLabels) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local distance = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
            label.Text = plr.Name .. "\n" .. string.format("%.1f", distance) .. " studs"
            label.Parent.Adornee = char:FindFirstChild("Head") or hrp
        else
            removeEspLabel(plr)
        end
    end
end)

-- ESP Toggle
ESPBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    if espEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            createEspLabel(plr)
        end
    else
        for plr, _ in pairs(espLabels) do
            removeEspLabel(plr)
        end
    end
end)

-- Handle player added/removed for ESP
Players.PlayerAdded:Connect(function(plr)
    if espEnabled then
        createEspLabel(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    removeEspLabel(plr)
end)

-- Minimize Logic
local minimized = false
local elementsToToggle = {SpeedBtn, SpeedBox, JumpBtn, JumpBox, AntiClipBtn, ESPBtn}

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, obj in ipairs(elementsToToggle) do
        obj.Visible = not minimized
    end
    MainFrame.Size = minimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 320)
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
    setAntiClip(antiClipEnabled)
end)

-- Anti AFK (simple)
local VirtualUser = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Inisialisasi kalau player sudah ada karakter
if player.Character then
    setAntiClip(antiClipEnabled)
end
