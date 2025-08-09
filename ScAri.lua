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
local espEnabled = false
local blockWallEnabled = false -- untuk block transparan

-- Colors
local colorBlackGlossy = Color3.fromRGB(20, 20, 20)
local colorBlackGlossyLight = Color3.fromRGB(40, 40, 40)
local colorRedFire = Color3.fromRGB(255, 20, 0)
local colorWhite = Color3.fromRGB(255, 255, 255)

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 360) -- dikasih sedikit tinggi untuk tombol tambahan
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -180)
MainFrame.BackgroundColor3 = colorBlackGlossy
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Glossy effect function (simple gradient overlay)
local function addGlossyEffect(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(0.5, 0.1), NumberSequenceKeypoint.new(1, 0.4)}
    gradient.Parent = parent
end

addGlossyEffect(MainFrame)

-- Title with fire effect
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, -60, 0, 30)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "ARI HUB"
TitleBar.TextColor3 = colorRedFire
TitleBar.TextScaled = true
TitleBar.Font = Enum.Font.GothamBlack
TitleBar.Parent = MainFrame
TitleBar.ZIndex = 10

-- Fire effect (simple flicker animation)
local FireOverlay = Instance.new("Frame")
FireOverlay.Size = TitleBar.Size
FireOverlay.Position = TitleBar.Position
FireOverlay.BackgroundTransparency = 0.8
FireOverlay.BackgroundColor3 = colorRedFire
FireOverlay.BorderSizePixel = 0
FireOverlay.Parent = MainFrame
FireOverlay.ZIndex = 9
Instance.new("UICorner", FireOverlay).CornerRadius = UDim.new(0, 5)

-- Animate flicker fire effect on FireOverlay background color and transparency
spawn(function()
    while FireOverlay.Parent do
        FireOverlay.BackgroundTransparency = 0.6 + math.random() * 0.4
        FireOverlay.BackgroundColor3 = Color3.fromHSV(0, 1, 0.7 + math.random() * 0.3)
        wait(0.1 + math.random() * 0.2)
    end
end)

-- Buttons creation helper function
local function createButton(text, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = position
    btn.BackgroundColor3 = colorBlackGlossyLight
    btn.TextColor3 = colorWhite
    btn.Text = text
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    addGlossyEffect(btn)
    return btn
end

local SpeedBtn = createButton("Speed: OFF", UDim2.new(0, 10, 0, 40))
local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(1, -20, 0, 30)
SpeedBox.Position = UDim2.new(0, 10, 0, 85)
SpeedBox.BackgroundColor3 = colorBlackGlossyLight
SpeedBox.TextColor3 = colorWhite
SpeedBox.Text = tostring(settings.speed)
SpeedBox.TextScaled = true
SpeedBox.Font = Enum.Font.GothamBold
SpeedBox.Parent = MainFrame
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 8)
addGlossyEffect(SpeedBox)

local JumpBtn = createButton("Inf Jump: OFF", UDim2.new(0, 10, 0, 125))
local JumpBox = Instance.new("TextBox")
JumpBox.Size = UDim2.new(1, -20, 0, 30)
JumpBox.Position = UDim2.new(0, 10, 0, 170)
JumpBox.BackgroundColor3 = colorBlackGlossyLight
JumpBox.TextColor3 = colorWhite
JumpBox.Text = tostring(settings.jumpPower)
JumpBox.TextScaled = true
JumpBox.Font = Enum.Font.GothamBold
JumpBox.Parent = MainFrame
Instance.new("UICorner", JumpBox).CornerRadius = UDim.new(0, 8)
addGlossyEffect(JumpBox)

local AntiClipBtn = createButton("Anti Clip: OFF", UDim2.new(0, 10, 0, 210))
local ESPBtn = createButton("ESP: OFF", UDim2.new(0, 10, 0, 260))
local BlockWallBtn = createButton("Block Wall: OFF", UDim2.new(0, 10, 0, 310))

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

-- Anti Clip Implementation (improved, only CanCollide false on all parts)
local function setAntiClip(state)
    local character = player.Character
    if not character then return end

    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
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

-- ESP Implementation
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
    textLabel.TextColor3 = colorWhite
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

-- Update ESP labels every frame
RunService.Heartbeat:Connect(function()
    if not espEnabled then return end
    for plr, label in pairs(espLabels) do
        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
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

-- Block Wall Feature: small transparent block under character to prevent fall and movement
local blockPart = nil

local function createBlockWall()
    if blockPart then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    blockPart = Instance.new("Part")
    blockPart.Size = Vector3.new(4, 0.2, 4)
    blockPart.Transparency = 0.5
    blockPart.CanCollide = true
    blockPart.Anchored = true
    blockPart.Material = Enum.Material.Neon
    blockPart.Color = Color3.fromRGB(255, 255, 255)
    blockPart.Name = "BlockWall"
    blockPart.Parent = workspace

    -- Position block just under HumanoidRootPart (slightly below feet)
    blockPart.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
end

local function removeBlockWall()
    if blockPart then
        blockPart:Destroy()
        blockPart = nil
    end
end

-- Update blockWall position to follow character
RunService.Heartbeat:Connect(function()
    if blockWallEnabled and blockPart then
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                blockPart.CFrame = hrp.CFrame * CFrame.new(0, -3, 0)
            else
                removeBlockWall()
            end
        else
            removeBlockWall()
        end
    end
end)

-- Block Wall Toggle
BlockWallBtn.MouseButton1Click:Connect(function()
    blockWallEnabled = not blockWallEnabled
    BlockWallBtn.Text = blockWallEnabled and "Block Wall: ON" or "Block Wall: OFF"
    if blockWallEnabled then
        createBlockWall()
    else
        removeBlockWall()
    end
end)

-- Minimize and Close buttons
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Text = "-"
MinBtn.TextScaled = true
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BackgroundColor3 = colorBlackGlossyLight
MinBtn.TextColor3 = colorWhite
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
addGlossyEffect(MinBtn)
MinBtn.ZIndex = 20

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = colorWhite
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.ZIndex = 20

-- Minimize Logic
local minimized = false
local elementsToToggle = {SpeedBtn, SpeedBox, JumpBtn, JumpBox, AntiClipBtn, ESPBtn, BlockWallBtn}

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, obj in ipairs(elementsToToggle) do
        obj.Visible = not minimized
    end
    MainFrame.Size = minimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 360)
    MinBtn.Text = minimized and "+" or "-"
end)

-- Close Logic
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Restore on Respawn / Character Added
local function onCharacterAdded(char)
    local hum = char:WaitForChild("Humanoid")
    if speedEnabled then
        hum.WalkSpeed = tonumber(settings.speed) or 16
    else
        hum.WalkSpeed = 16
    end
    setAntiClip(antiClipEnabled)
    
    -- recreate block wall if enabled
    if blockWallEnabled then
        createBlockWall()
    end
end

player.CharacterAdded:Connect(onCharacterAdded)

-- Also, if character already exists on script start
if player.Character then
    onCharacterAdded(player.Character)
end

-- Anti AFK (simple)
local VirtualUser = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
