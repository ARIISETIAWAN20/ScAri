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
        return {
            speed = 16,
            jumpPower = 50,
            speedEnabled = false,
            infJumpEnabled = false,
            antiClipEnabled = false,
            espEnabled = false,
            blockEnabled = false,
        }
    end
end

local function saveSettings(settings)
    writefile(fileName, HttpService:JSONEncode(settings))
end

local settings = loadSettings()

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
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.BackgroundColor3 = colorBlackGlossy
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local function addGlossyEffect(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 45
    gradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(0.5, 0.1), NumberSequenceKeypoint.new(1, 0.4)}
    gradient.Parent = parent
end

addGlossyEffect(MainFrame)

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, -60, 0, 30)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "ARI HUB"
TitleBar.TextColor3 = colorRedFire
TitleBar.TextScaled = true
TitleBar.Font = Enum.Font.GothamBlack
TitleBar.Parent = MainFrame
TitleBar.ZIndex = 10

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
local JumpBtn = createButton("Inf Jump: OFF", UDim2.new(0, 10, 0, 125))
local AntiClipBtn = createButton("Anti Clip: OFF", UDim2.new(0, 10, 0, 210))
local ESPBtn = createButton("ESP: OFF", UDim2.new(0, 10, 0, 260))
local BlockBtn = createButton("Block Under: OFF", UDim2.new(0, 10, 0, 305))

local function createTextBox(text, position)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(1, -20, 0, 30)
    tb.Position = position
    tb.BackgroundColor3 = colorBlackGlossyLight
    tb.TextColor3 = colorWhite
    tb.Text = text
    tb.TextScaled = true
    tb.Font = Enum.Font.GothamBold
    tb.Parent = MainFrame
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    addGlossyEffect(tb)
    return tb
end

local SpeedBox = createTextBox(tostring(settings.speed), UDim2.new(0, 10, 0, 85))
local JumpBox = createTextBox(tostring(settings.jumpPower), UDim2.new(0, 10, 0, 170))

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

-- Variables
local speedEnabled = settings.speedEnabled or false
local infJumpEnabled = settings.infJumpEnabled or false
local antiClipEnabled = settings.antiClipEnabled or false
local espEnabled = settings.espEnabled or false
local blockEnabled = settings.blockEnabled or false

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

-- Anti Clip Implementation
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
    settings.speedEnabled = speedEnabled
    saveSettings(settings)
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

-- Jump Toggle Logic
JumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    settings.infJumpEnabled = infJumpEnabled
    saveSettings(settings)
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

-- Block Under Character Implementation
local blockPart = nil
local function createBlockUnder()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if blockPart then
        blockPart:Destroy()
        blockPart = nil
    end

    blockPart = Instance.new("Part")
    blockPart.Name = "BlockUnderCharacter"
    blockPart.Anchored = true
    blockPart.CanCollide = true
    blockPart.Size = Vector3.new(5, 0.5, 5)
    blockPart.Transparency = 0.5
    blockPart.Material = Enum.Material.Neon
    blockPart.Color = Color3.fromRGB(200, 0, 200)
    blockPart.Position = hrp.Position - Vector3.new(0, hrp.Size.Y/2 + 0.3, 0)
    blockPart.Parent = workspace
end

local function updateBlockUnder()
    if not blockPart then return end
    local char = player.Character
    if not char then
        blockPart:Destroy()
        blockPart = nil
        return
    end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        blockPart:Destroy()
        blockPart = nil
        return
    end
    blockPart.Position = hrp.Position - Vector3.new(0, hrp.Size.Y/2 + 0.3, 0)
end

local function removeBlock()
    if blockPart then
        blockPart:Destroy()
        blockPart = nil
    end
end

local function enableBlock(state)
    if state then
        createBlockUnder()
        RunService:BindToRenderStep("UpdateBlock", 1, updateBlockUnder)
    else
        RunService:UnbindFromRenderStep("UpdateBlock")
        removeBlock()
    end
end

BlockBtn.MouseButton1Click:Connect(function()
    blockEnabled = not blockEnabled
    settings.blockEnabled = blockEnabled
    saveSettings(settings)
    BlockBtn.Text = blockEnabled and "Block Under: ON" or "Block Under: OFF"
    enableBlock(blockEnabled)
end)

-- Minimize and Close buttons
local minimized = false
local elementsToToggle = {SpeedBtn, SpeedBox, JumpBtn, JumpBox, AntiClipBtn, ESPBtn, BlockBtn}

MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, obj in ipairs(elementsToToggle) do
        obj.Visible = not minimized
    end
    MainFrame.Size = minimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 350)
    MinBtn.Text = minimized and "+" or "-"
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Restore on Respawn
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitFor
    
