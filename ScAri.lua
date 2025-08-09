-- ARI HUB Full Version tanpa flicker fire, tanpa drag, posisi fixed di tengah atas layar
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

local function saveSettings(settings)
    local json = HttpService:JSONEncode(settings)
    safeWriteFile(fileName, json)
end

local settings = loadSettings()

local cBlack = Color3.fromRGB(20, 20, 20)
local cBlackLight = Color3.fromRGB(40, 40, 40)
local cRed = Color3.fromRGB(255, 20, 0)
local cWhite = Color3.fromRGB(255, 255, 255)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ARI_HUB_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = playerGui

local scale = 0.9
local mainWidth = 250 * scale
local mainHeight = 350 * scale
local btnHeight = 40 * scale
local tbHeight = 30 * scale

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, mainWidth, 0, mainHeight)
MainFrame.Position = UDim2.new(0.5, -mainWidth / 2, 0, 10) -- posisi fixed tengah atas dengan offset 10px dari atas
MainFrame.BackgroundColor3 = cBlack
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false -- Nonaktifkan drag
MainFrame.Parent = ScreenGui
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

-- Padding dalam frame
local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.Parent = MainFrame

-- Efek glossy sederhana untuk objek UI
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

-- Judul dengan efek api (animasi glow sederhana)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60 * scale, 0, 30 * scale)
Title.Position = UDim2.new(0, 10 * scale, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "ARI HUB"
Title.TextColor3 = cRed
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = MainFrame
Title.ZIndex = 10

-- Efek api glow sederhana dengan Frame animasi alpha
local FireFrame = Instance.new("Frame")
FireFrame.Size = Title.Size
FireFrame.Position = Title.Position
FireFrame.BackgroundColor3 = cRed
FireFrame.BackgroundTransparency = 0.8
FireFrame.BorderSizePixel = 0
FireFrame.Parent = MainFrame
FireFrame.ZIndex = 9
local fireCorner = Instance.new("UICorner")
fireCorner.CornerRadius = UDim.new(0, 5)
fireCorner.Parent = FireFrame

-- Animasi alpha glow api
spawn(function()
    local increasing = true
    while FireFrame.Parent do
        local alpha = FireFrame.BackgroundTransparency
        if increasing then
            alpha = alpha - 0.02
            if alpha <= 0.5 then increasing = false end
        else
            alpha = alpha + 0.02
            if alpha >= 0.8 then increasing = true end
        end
        FireFrame.BackgroundTransparency = alpha
        wait(0.05)
    end
end)

-- Container tombol dan textbox dengan UIListLayout agar rapih
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, 0, 1, -40 * scale) -- ruang di bawah judul
contentFrame.Position = UDim2.new(0, 0, 0, 40 * scale)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = MainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 10 * scale)
listLayout.Parent = contentFrame

-- Fungsi pembuat tombol & textbox
local currentLayoutOrder = 1
local function createButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, btnHeight)
    btn.BackgroundColor3 = cBlackLight
    btn.TextColor3 = cWhite
    btn.Text = text
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = contentFrame
    btn.LayoutOrder = currentLayoutOrder
    currentLayoutOrder += 1
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    addGlossyEffect(btn)
    return btn
end

local function createTextBox(text)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(1, 0, 0, tbHeight)
    tb.BackgroundColor3 = cBlackLight
    tb.TextColor3 = cWhite
    tb.Text = text
    tb.TextScaled = true
    tb.Font = Enum.Font.GothamBold
    tb.Parent = contentFrame
    tb.LayoutOrder = currentLayoutOrder
    currentLayoutOrder += 1
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    addGlossyEffect(tb)
    return tb
end

-- Buat tombol dan textbox
local SpeedBtn = createButton("Speed: OFF")
local SpeedBox = createTextBox(tostring(settings.speed))

local JumpBtn = createButton("Inf Jump: OFF")
local JumpBox = createTextBox(tostring(settings.jumpPower))

local AntiClipBtn = createButton("Anti Clip: OFF")
local ESPBtn = createButton("ESP: OFF")
local BlockBtn = createButton("Block Under: OFF")

-- Tombol minimize dan close di kanan atas frame
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30 * scale, 0, 30 * scale)
MinBtn.Position = UDim2.new(1, -60 * scale, 0, 0)
MinBtn.Text = "-"
MinBtn.TextScaled = true
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BackgroundColor3 = cBlackLight
MinBtn.TextColor3 = cWhite
MinBtn.Parent = MainFrame
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = MinBtn
addGlossyEffect(MinBtn)
MinBtn.ZIndex = 20

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30 * scale, 0, 30 * scale)
CloseBtn.Position = UDim2.new(1, -30 * scale, 0, 0)
CloseBtn.Text = "X"
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = cWhite
CloseBtn.Parent = MainFrame
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = CloseBtn
CloseBtn.ZIndex = 20

-- State vars
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
    if hum then
        if speedEnabled then
            hum.WalkSpeed = tonumber(settings.speed) or 16
            SpeedBtn.Text = "Speed: ON"
        else
            hum.WalkSpeed = 16
            SpeedBtn.Text = "Speed: OFF"
        end
    end
end)

-- SpeedBox Save
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

-- Jump Toggle
JumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    settings.infJumpEnabled = infJumpEnabled
    saveSettings(settings)
    JumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
end)

-- JumpBox Save
JumpBox.FocusLost:Connect(function()
    local val = tonumber(JumpBox.Text)
    if val and val >= 50 and val <= 1000 then
        settings.jumpPower = val
        saveSettings(settings)
    else
        JumpBox.Text = tostring(settings.jumpPower)
    end
end)

-- AntiClip Toggle
AntiClipBtn.MouseButton1Click:Connect(function()
    antiClipEnabled = not antiClipEnabled
    settings.antiClipEnabled = antiClipEnabled
    saveSettings(settings)
    setAntiClip(antiClipEnabled)
    AntiClipBtn.Text = antiClipEnabled and "Anti Clip: ON" or "Anti Clip: OFF"
end)

-- ESP
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

-- Block Under Character (transparan block)
local blockPart

local function createBlock()
    if blockPart and blockPart.Parent then
        blockPart:Destroy()
    end
    blockPart = Instance.new("Part")
    blockPart.Name = "AntiFallBlock"
    blockPart.Size = Vector3.new(6, 0.5, 6)
    blockPart.Transparency = 0.7
    blockPart.Anchored = true
    blockPart.CanCollide = true
    blockPart.Material = Enum.Material.Neon
    blockPart.Color = Color3.fromRGB(255, 0, 0)
    blockPart.Parent = workspace
end

local function updateBlockPosition()
    if not blockPart or not blockPart.Parent then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    blockPart.CFrame = CFrame.new(root.Position.X, root.Position.Y - 5, root.Position.Z)
end

local blockConnection

BlockBtn.MouseButton1Click:Connect(function()
    blockEnabled = not blockEnabled
    settings.blockEnabled = blockEnabled
    saveSettings(settings)

    local char = player.Character
    if blockEnabled then
        createBlock
            
