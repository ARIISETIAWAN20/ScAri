-- ARI HUB GUI v1.0 | Delta Executor Compatible
-- Full fitur lengkap, drag manual, api animasi, simpan setting, blok transparan statis bawah karakter

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local fileName = "ARI HUB.json"

-- Load/Save Settings
local function loadSettings()
    if isfile(fileName) then
        local suc, data = pcall(function()
            return HttpService:JSONDecode(readfile(fileName))
        end)
        if suc and type(data) == "table" then return data end
    end
    return {
        speed = 16,
        jumpPower = 50,
        speedEnabled = false,
        infJumpEnabled = false,
        antiClipEnabled = false,
        espEnabled = false,
        blockEnabled = false,
        minimized = false
    }
end

local function saveSettings(settings)
    pcall(function()
        writefile(fileName, HttpService:JSONEncode(settings))
    end)
end

local settings = loadSettings()

-- Colors
local colorBlackGlossy = Color3.fromRGB(20, 20, 20)
local colorBlackGlossyLight = Color3.fromRGB(40, 40, 40)
local colorRedFire = Color3.fromRGB(255, 20, 0)
local colorWhite = Color3.fromRGB(255, 255, 255)

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ARI_HUB_GUI"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

-- Main Frame (original size)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 225, 0, 285)
MainFrame.Position = UDim2.new(0.5, -112, 0.5, -142)
MainFrame.BackgroundColor3 = colorBlackGlossy
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Fire effect around MainFrame
local function createFireEffect(parent)
    local fireFrames = {}
    local count = 8
    local radius = 115
    for i = 1, count do
        local fire = Instance.new("Frame")
        fire.Size = UDim2.new(0, 20, 0, 20)
        fire.AnchorPoint = Vector2.new(0.5, 0.5)
        fire.BackgroundColor3 = colorRedFire
        fire.Position = UDim2.new(0.5 + math.cos(i/count*2*math.pi)*radius/MainFrame.Size.X.Offset/2, 0,
                                0.5 + math.sin(i/count*2*math.pi)*radius/MainFrame.Size.Y.Offset/2, 0)
        fire.BorderSizePixel = 0
        fire.BackgroundTransparency = 0.5
        fire.Parent = parent
        Instance.new("UICorner", fire).CornerRadius = UDim.new(0, 10)
        table.insert(fireFrames, fire)
    end
    
    spawn(function()
        while parent.Parent do
            for i, fire in ipairs(fireFrames) do
                local t = tick()
                local xOffset = math.cos(t*2 + i) * 3
                local yOffset = math.sin(t*3 + i) * 3
                fire.Position = UDim2.new(0.5 + math.cos(i/#fireFrames*2*math.pi)*radius/MainFrame.Size.X.Offset/2 + xOffset/MainFrame.Size.X.Offset,
                                                        0,
                                                        0.5 + math.sin(i/#fireFrames*2*math.pi)*radius/MainFrame.Size.Y.Offset/2 + yOffset/MainFrame.Size.Y.Offset,
                                                        0)
                fire.BackgroundTransparency = 0.4 + 0.3 * math.sin(t*6 + i)
            end
            wait(0.05)
        end
    end)
end

createFireEffect(MainFrame)

-- Title Bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, -60, 0, 30)
TitleBar.Position = UDim2.new(0, 10, 0, 5)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "ARI HUB"
TitleBar.TextColor3 = colorRedFire
TitleBar.TextScaled = true
TitleBar.Font = Enum.Font.GothamBlack
TitleBar.TextStrokeTransparency = 0
TitleBar.TextStrokeColor3 = Color3.new(0, 0, 0)
TitleBar.Parent = MainFrame
TitleBar.ZIndex = 10

-- Fire overlay behind TitleBar
local FireOverlay = Instance.new("Frame")
FireOverlay.Size = TitleBar.Size
FireOverlay.Position = TitleBar.Position
FireOverlay.BackgroundTransparency = 0.8
FireOverlay.BackgroundColor3 = colorRedFire
FireOverlay.BorderSizePixel = 0
FireOverlay.Parent = MainFrame
FireOverlay.ZIndex = 9
Instance.new("UICorner", FireOverlay).CornerRadius = UDim.new(0, 5)

spawn(function()
    while FireOverlay.Parent do
        FireOverlay.BackgroundTransparency = 0.6 + math.random() * 0.4
        FireOverlay.BackgroundColor3 = Color3.fromHSV(0, 1, 0.7 + math.random() * 0.3)
        wait(0.1 + math.random() * 0.2)
    end
end)

-- Button creator function
local function createButton(text, position)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = position
    btn.BackgroundColor3 = colorBlackGlossyLight
    btn.TextColor3 = colorWhite
    btn.Text = text
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.TextStrokeTransparency = 0
    btn.TextStrokeColor3 = Color3.new(0, 0, 0)
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

-- Speed Section
local SpeedBtn = createButton("Speed: OFF", UDim2.new(0, 10, 0, 40))
local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(1, -20, 0, 25)
SpeedBox.Position = UDim2.new(0, 10, 0, 80)
SpeedBox.BackgroundColor3 = colorBlackGlossyLight
SpeedBox.TextColor3 = colorWhite
SpeedBox.Text = tostring(settings.speed)
SpeedBox.TextScaled = true
SpeedBox.Font = Enum.Font.GothamBold
SpeedBox.TextStrokeTransparency = 0
SpeedBox.TextStrokeColor3 = Color3.new(0, 0, 0)
SpeedBox.Parent = MainFrame
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 6)

-- Other Buttons (arranged neatly with consistent spacing)
local JumpBtn = createButton("Inf Jump: OFF", UDim2.new(0, 10, 0, 110))
local AntiClipBtn = createButton("Anti Clip: OFF", UDim2.new(0, 10, 0, 150))
local ESPBtn = createButton("ESP: OFF", UDim2.new(0, 10, 0, 190))
local BlockBtn = createButton("Block Bawah: OFF", UDim2.new(0, 10, 0, 230))

-- Variables
local speedEnabled = settings.speedEnabled or false
local infJumpEnabled = settings.infJumpEnabled or false
local antiClipEnabled = settings.antiClipEnabled or false
local espEnabled = settings.espEnabled or false
local blockEnabled = settings.blockEnabled or false

-- Infinite Jump Handler
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Anti Clip Implementation
local function setAntiClip(state)
    local char = player.Character
    if not char then return end

    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = not state
        end
    end
end

-- Speed Toggle
SpeedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    settings.speedEnabled = speedEnabled
    saveSettings(settings)

    local char = player.Character or player.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

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

-- Jump Toggle
JumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    settings.infJumpEnabled = infJumpEnabled
    saveSettings(settings)
    JumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
end)

-- Anti Clip Toggle
AntiClipBtn.MouseButton1Click:Connect(function()
    antiClipEnabled = not antiClipEnabled
    settings.antiClipEnabled = antiClipEnabled
    saveSettings(settings)
    AntiClipBtn.Text = antiClipEnabled and "Anti Clip: ON" or "Anti Clip: OFF"
    setAntiClip(antiClipEnabled)
end)

-- ESP Implementation
local espLabels = {}

local function createEspLabel(plr)
    if plr == player then return end
    if espLabels[plr] then return end

    local char = plr.Character
    if not char then return end

    local head = char:FindFirstChild("Head")
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
    settings.espEnabled = espEnabled
    saveSettings(settings)
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

Players.PlayerAdded:Connect(function(plr)
    if espEnabled then
        createEspLabel(plr)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    removeEspLabel(plr)
end)

-- Block below character
local blockPart
local function createBlock()
    if blockPart then blockPart:Destroy() end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    blockPart = Instance.new("Part")
    blockPart.Name = "ARI_HUB_Block"
    blockPart.Size = Vector3.new(6, 0.5, 6)
    blockPart.Transparency = 0.6
    blockPart.Anchored = true
    blockPart.CanCollide = true
    blockPart.Material = Enum.Material.Neon
    blockPart.Color = Color3.fromRGB(255, 20, 0)
    blockPart.Parent = workspace

    local pos = hrp.Position
    blockPart.CFrame = CFrame.new(pos.X, pos.Y - (hrp.Size.Y / 2 + blockPart.Size.Y/2), pos.Z)
end

local function removeBlock()
    if blockPart then
        blockPart:Destroy()
        blockPart = nil
    end
end

-- Block toggle
BlockBtn.MouseButton1Click:Connect(function()
    blockEnabled = not blockEnabled
    settings.blockEnabled = blockEnabled
    saveSettings(settings)
    if blockEnabled then
        createBlock()
        BlockBtn.Text = "Block Bawah: ON"
    else
        removeBlock()
        BlockBtn.Text = "Block Bawah: OFF"
    end
end)

-- Character added event
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    local hrp = char:WaitForChild("HumanoidRootPart")

    if speedEnabled then
        hum.WalkSpeed = tonumber(settings.speed) or 16
    else
        hum.WalkSpeed = 16
    end

    setAntiClip(antiClipEnabled)

    if blockEnabled then
        wait(0.1)
        createBlock()
    else
        removeBlock()
    end
end)

-- Anti AFK
local VirtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Minimize and Close buttons
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Text = settings.minimized and "+" or "-"
MinBtn.TextScaled = true
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BackgroundColor3 = colorBlackGlossyLight
MinBtn.TextColor3 = colorWhite
MinBtn.TextStrokeTransparency = 0
MinBtn.TextStrokeColor3 = Color3.new(0, 0, 0)
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
MinBtn.ZIndex = 20

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = colorWhite
CloseBtn.TextStrokeTransparency = 0
CloseBtn.TextStrokeColor3 = Color3.new(0, 0, 0)
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.ZIndex = 20

local elementsToToggle = {SpeedBtn, SpeedBox, JumpBtn, AntiClipBtn, ESPBtn, BlockBtn}

-- Restore minimized state
if settings.minimized then
    for _, v in ipairs(elementsToToggle) do v.Visible = false end
    MainFrame.Size = UDim2.new(0, 225, 0, 40)
    MinBtn.Text = "+"
else
    for _, v in ipairs(elementsToToggle) do v.Visible = true end
    MainFrame.Size = UDim2.new(0, 225, 0, 285)
    MinBtn.Text = "-"
end

MinBtn.MouseButton1Click:Connect(function()
    settings.minimized = not settings.minimized
    saveSettings(settings)

    if settings.minimized then
        for _, v in ipairs(elementsToToggle) do v.Visible = false end
        MainFrame.Size = UDim2.new(0, 225, 0, 40)
        MinBtn.Text = "+"
    else
        for _, v in ipairs(elementsToToggle) do v.Visible = true end
        MainFrame.Size = UDim2.new(0, 225, 0, 285)
        MinBtn.Text = "-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Dragging functionality
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale,
        startPos.X.Offset + delta.X,
        startPos.Y.Scale,
        startPos.Y.Offset + delta.Y
    )
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Apply saved settings on script start
if player.Character then
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = speedEnabled and (tonumber(settings.speed) or 16) or 16
    end
    setAntiClip(antiClipEnabled)

    if blockEnabled then
        createBlock()
    end
end

-- Set initial button states
SpeedBtn.Text = speedEnabled and "Speed: ON" or "Speed: OFF"
JumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
AntiClipBtn.Text = antiClipEnabled and "Anti Clip: ON" or "Anti Clip: OFF"
ESPBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
BlockBtn.Text = blockEnabled and "Block Bawah: ON" or "Block Bawah: OFF"
