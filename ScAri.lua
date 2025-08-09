local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DeltaAPI = {}

if type(getgenv) == "function" and type(getgenv().Delta) == "table" then
    DeltaAPI.isfile = getgenv().Delta.isfile
    DeltaAPI.readfile = getgenv().Delta.readfile
    DeltaAPI.writefile = getgenv().Delta.writefile
else
    DeltaAPI.isfile = isfile
    DeltaAPI.readfile = readfile
    DeltaAPI.writefile = writefile
end

local fileName = "ARI HUB.json"

local function safeIsFile(fname)
    if type(DeltaAPI.isfile) == "function" then
        return DeltaAPI.isfile(fname)
    else
        return false
    end
end

local function safeReadFile(fname)
    if type(DeltaAPI.readfile) == "function" and safeIsFile(fname) then
        return DeltaAPI.readfile(fname)
    else
        return nil
    end
end

local function safeWriteFile(fname, content)
    if type(DeltaAPI.writefile) == "function" then
        DeltaAPI.writefile(fname, content)
    end
end

local function loadSettings()
    local data = safeReadFile(fileName)
    if data then
        local suc, res = pcall(function() return HttpService:JSONDecode(data) end)
        if suc and type(res) == "table" then
            return res
        end
    end
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

local function saveSettings(tbl)
    local json = HttpService:JSONEncode(tbl)
    safeWriteFile(fileName, json)
end

local settings = loadSettings()

-- Colors
local cBlack = Color3.fromRGB(20, 20, 20)
local cBlackLight = Color3.fromRGB(40, 40, 40)
local cRed = Color3.fromRGB(255, 20, 0)
local cWhite = Color3.fromRGB(255, 255, 255)

local guiScale = 0.9 -- 90% dari ukuran default

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ARI_HUB_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250 * guiScale, 0, 350 * guiScale)
MainFrame.Position = UDim2.new(0.5, -(125 * guiScale), 0.5, -(175 * guiScale))
MainFrame.BackgroundColor3 = cBlack
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local function addGlossyEffect(obj)
    local grad = Instance.new("UIGradient")
    grad.Rotation = 45
    grad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 0.4),
    }
    grad.Parent = obj
end

addGlossyEffect(MainFrame)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60 * guiScale, 0, 30 * guiScale)
Title.Position = UDim2.new(0, 10 * guiScale, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ARI HUB"
Title.TextColor3 = cRed
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = MainFrame
Title.ZIndex = 10

local FireFrame = Instance.new("Frame")
FireFrame.Size = Title.Size
FireFrame.Position = Title.Position
FireFrame.BackgroundTransparency = 0.8
FireFrame.BackgroundColor3 = cRed
FireFrame.BorderSizePixel = 0
FireFrame.Parent = MainFrame
FireFrame.ZIndex = 9
Instance.new("UICorner", FireFrame).CornerRadius = UDim.new(0, 5)

-- Flicker fire effect
coroutine.wrap(function()
    while FireFrame.Parent do
        FireFrame.BackgroundTransparency = 0.6 + math.random() * 0.4
        FireFrame.BackgroundColor3 = Color3.fromHSV(0, 1, 0.7 + math.random() * 0.3)
        wait(0.1 + math.random() * 0.2)
    end
end)()

-- Fungsi buat efek api merah mengelilingi MainFrame
local function createFireParticle(posScale, size)
    local fire = Instance.new("ImageLabel")
    fire.Size = UDim2.new(0, size, 0, size)
    fire.AnchorPoint = Vector2.new(0.5, 0.5)
    fire.BackgroundTransparency = 1
    fire.Image = "rbxassetid://241837157" -- id image api kecil (bisa diganti)
    fire.ImageColor3 = Color3.fromRGB(255, 50, 0)
    fire.Parent = MainFrame
    fire.ZIndex = 15

    -- Posisi relatif terhadap MainFrame
    fire.Position = UDim2.new(posScale.X.Scale, posScale.X.Offset, posScale.Y.Scale, posScale.Y.Offset)

    return fire
end

local fires = {}

-- Buat beberapa efek api di sekitar frame (posisi relatif)
local firePositions = {
    {X = UDim.new(0, 0), Y = UDim.new(0, 0)},
    {X = UDim.new(1, 0), Y = UDim.new(0, 0)},
    {X = UDim.new(1, 0), Y = UDim.new(1, 0)},
    {X = UDim.new(0, 0), Y = UDim.new(1, 0)},
    {X = UDim.new(0.5, 0), Y = UDim.new(0, -10)},
    {X = UDim.new(1, 10), Y = UDim.new(0.5, 0)},
    {X = UDim.new(0.5, 0), Y = UDim.new(1, 10)},
    {X = UDim.new(-10, 0), Y = UDim.new(0.5, 0)},
}

for _, pos in ipairs(firePositions) do
    local fire = createFireParticle({X = pos.X, Y = pos.Y}, 30 * guiScale)
    table.insert(fires, fire)
end

-- Animasi api bergerak mengelilingi frame secara sederhana
local angle = 0
RunService.Heartbeat:Connect(function(dt)
    angle = angle + dt * math.rad(50) -- kecepatan rotasi

    local cx = MainFrame.AbsoluteSize.X / 2
    local cy = MainFrame.AbsoluteSize.Y / 2
    local radiusX = cx + 10 * guiScale
    local radiusY = cy + 10 * guiScale

    for i, fire in ipairs(fires) do
        local offsetAngle = angle + (2 * math.pi / #fires) * i
        local x = cx + math.cos(offsetAngle) * radiusX
        local y = cy + math.sin(offsetAngle) * radiusY
        fire.Position = UDim2.new(0, x, 0, y)
    end
end)

local function createButton(text, pos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20 * guiScale, 0, 40 * guiScale)
    btn.Position = pos
    btn.BackgroundColor3 = cBlackLight
    btn.TextColor3 = cWhite
    btn.Text = text
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    addGlossyEffect(btn)
    return btn
end

local SpeedBtn = createButton("Speed: OFF", UDim2.new(0, 10 * guiScale, 0, 40 * guiScale))
local JumpBtn = createButton("Inf Jump: OFF", UDim2.new(0, 10 * guiScale, 0, 125 * guiScale))
local AntiClipBtn = createButton("Anti Clip: OFF", UDim2.new(0, 10 * guiScale, 0, 210 * guiScale))
local ESPBtn = createButton("ESP: OFF", UDim2.new(0, 10 * guiScale, 0, 260 * guiScale))
local BlockBtn = createButton("Block Under: OFF", UDim2.new(0, 10 * guiScale, 0, 305 * guiScale))

local function createTextBox(text, pos)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(1, -20 * guiScale, 0, 30 * guiScale)
    tb.Position = pos
    tb.BackgroundColor3 = cBlackLight
    tb.TextColor3 = cWhite
    tb.Text = text
    tb.TextScaled = true
    tb.Font = Enum.Font.GothamBold
    tb.Parent = MainFrame
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    addGlossyEffect(tb)
    return tb
end

local SpeedBox = createTextBox(tostring(settings.speed), UDim2.new(0, 10 * guiScale, 0, 85 * guiScale))
local JumpBox = createTextBox(tostring(settings.jumpPower), UDim2.new(0, 10 * guiScale, 0, 170 * guiScale))

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30 * guiScale, 0, 30 * guiScale)
MinBtn.Position = UDim2.new(1, -60 * guiScale, 0, 0)
MinBtn.Text = "-"
MinBtn.TextScaled = true
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BackgroundColor3 = cBlackLight
MinBtn.TextColor3 = cWhite
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 8)
addGlossyEffect(MinBtn)
MinBtn.ZIndex = 20

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30 * guiScale, 0, 30 * guiScale)
CloseBtn.Position = UDim2.new(1, -30 * guiScale, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = cWhite
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.ZIndex = 20

-- Status variables
local speedEnabled = settings.speedEnabled
local infJumpEnabled = settings.infJumpEnabled
local antiClipEnabled = settings.antiClipEnabled
local espEnabled = settings.espEnabled
local blockEnabled = settings.blockEnabled

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = tonumber(settings.jumpPower) or 50
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Anti Clip Function
local function setAntiClip(state)
    local char = player.Character
    if not char then return end
    for _, p in pairs(char:GetChildren()) do
        if p:IsA("BasePart") then
            p.CanCollide = not state
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

-- Speed TextBox Save
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

-- Jump TextBox Save
JumpBox.FocusLost:Connect(function()
    local val = tonumber(JumpBox.Text)
    if val and val >= 50 and val <= 1000 then
        settings.jumpPower = val
        saveSettings(settings)
    else
        JumpBox.Text = tostring(settings.jumpPower)
    end
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
    billboard.Size = UDim2.new(0, 200 * guiScale, 0, 50 * guiScale)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = head

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = cWhite
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
            local dist = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
            label.Text = plr.Name .. "\n" .. string.format("%.1f", dist) .. " studs"
            label.Parent.Adornee = char:FindFirstChild("Head") or hrp
        else
            removeEspLabel(plr)
        end
    end
end)

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

-- Block Under Character (statik di spawn location)
local blockPart = nil
local spawnPosition = nil

local function createBlockUnder()
    local char = player.Character
    if not char then return end

    if not spawnPosition then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            spawnPosition = hrp.Position - Vector3.new(0, hrp.Size.Y/2 + 0.3, 0)
        else
            spawnPosition = Vector3.new(0, 0, 0)
        end

        
