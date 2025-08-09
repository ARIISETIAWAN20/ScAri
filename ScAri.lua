local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local fileName = "ARI HUB.json"

-- API File System untuk Delta Executor & fallback
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

local function safeIsFile(fname)
    return type(DeltaAPI.isfile) == "function" and DeltaAPI.isfile(fname)
end

local function safeReadFile(fname)
    if safeIsFile(fname) and type(DeltaAPI.readfile) == "function" then
        return DeltaAPI.readfile(fname)
    end
    return nil
end

local function safeWriteFile(fname, content)
    if type(DeltaAPI.writefile) == "function" then
        DeltaAPI.writefile(fname, content)
    end
end

-- Load dan simpan pengaturan
local function loadSettings()
    local data = safeReadFile(fileName)
    if data then
        local success, result = pcall(function() return HttpService:JSONDecode(data) end)
        if success and type(result) == "table" then
            return result
        end
    end
    return {speed = 16, jumpPower = 50, speedEnabled = false, infJumpEnabled = false, antiClipEnabled = false, espEnabled = false, blockEnabled = false}
end

local function saveSettings(tbl)
    local json = HttpService:JSONEncode(tbl)
    safeWriteFile(fileName, json)
end

local settings = loadSettings()

-- Warna
local colorBlack = Color3.fromRGB(20, 20, 20)
local colorBlackLight = Color3.fromRGB(40, 40, 40)
local colorWhite = Color3.fromRGB(255, 255, 255)

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ARI_HUB_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local mainWidth = 260
local mainHeight = 360

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, mainWidth, 0, mainHeight)
MainFrame.Position = UDim2.new(0.5, -mainWidth/2, 0, 10) -- Tengah atas layar
MainFrame.BackgroundColor3 = colorBlack
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local function addGlossyEffect(obj)
    local grad = Instance.new("UIGradient")
    grad.Rotation = 45
    grad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.35),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 0.35)
    }
    grad.Parent = obj
end
addGlossyEffect(MainFrame)

-- Rainbow Effect untuk Title "ARI HUB"
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "ARI HUB"
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = MainFrame

-- Fungsi rainbow warna
spawn(function()
    while Title.Parent do
        for hue = 0, 1, 0.01 do
            Title.TextColor3 = Color3.fromHSV(hue, 1, 1)
            wait(0.03)
        end
    end
end)

-- Helper buat tombol dan textbox dengan jarak rapih
local function createButton(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 40)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = colorBlackLight
    btn.TextColor3 = colorWhite
    btn.Text = text
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    addGlossyEffect(btn)
    return btn
end

local function createTextBox(text, yPos)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(1, -20, 0, 30)
    tb.Position = UDim2.new(0, 10, 0, yPos)
    tb.BackgroundColor3 = colorBlackLight
    tb.TextColor3 = colorWhite
    tb.Text = text
    tb.TextScaled = true
    tb.Font = Enum.Font.GothamBold
    tb.Parent = MainFrame
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 10)
    addGlossyEffect(tb)
    return tb
end

-- Buat tombol dan textbox dengan jarak
local SpeedBtn = createButton("Speed: OFF", 65)
local SpeedBox = createTextBox(tostring(settings.speed), 110)

local JumpBtn = createButton("Inf Jump: OFF", 150)
local JumpBox = createTextBox(tostring(settings.jumpPower), 195)

local AntiClipBtn = createButton("Anti Clip: OFF", 235)
local ESPBtn = createButton("ESP: OFF", 280)
local BlockBtn = createButton("Block Under: OFF", 325)

-- Minimize dan Close button
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -65, 0, 10)
MinBtn.Text = "-"
MinBtn.TextScaled = true
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BackgroundColor3 = colorBlackLight
MinBtn.TextColor3 = colorWhite
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 10)
addGlossyEffect(MinBtn)
MinBtn.ZIndex = 20

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 10)
CloseBtn.Text = "X"
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = colorWhite
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)
CloseBtn.ZIndex = 20

-- Status toggle
local speedEnabled = settings.speedEnabled
local infJumpEnabled = settings.infJumpEnabled
local antiClipEnabled = settings.antiClipEnabled
local espEnabled = settings.espEnabled
local blockEnabled = settings.blockEnabled

-- Update tombol sesuai status awal
SpeedBtn.Text = speedEnabled and "Speed: ON" or "Speed: OFF"
JumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
AntiClipBtn.Text = antiClipEnabled and "Anti Clip: ON" or "Anti Clip: OFF"
ESPBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
BlockBtn.Text = blockEnabled and "Block Under: ON" or "Block Under: OFF"

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

-- Anti Clip function
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

-- Block transparan di bawah karakter
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
    blockPart.Size = Vector3.new(6, 0.5, 6)
    blockPart.Transparency
    
