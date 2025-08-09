-- ARI HUB Script for Delta Executor Android
-- All features requested, GUI draggable, minimize/maximize, save/load config

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- File path untuk simpan load config
local fileName = "ARI HUB.json"

-- Default config
local config = {
    SpeedEnabled = false,
    SpeedValue = 0,
    InfiniteJump = false,
    Clip = false,
    ESPEnabled = false,
    BlockEnabled = false,
}

-- Fungsi simpan config ke file json
local function saveConfig()
    local json = HttpService:JSONEncode(config)
    if writefile then -- check executor mendukung writefile
        pcall(function()
            writefile(fileName, json)
        end)
    end
end

-- Fungsi load config dari file json
local function loadConfig()
    if isfile and isfile(fileName) then
        local success, content = pcall(function()
            return readfile(fileName)
        end)
        if success and content then
            local data = HttpService:JSONDecode(content)
            if type(data) == "table" then
                config = data
            end
        end
    end
end

loadConfig()

-- Setup GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ARIHUB"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

-- Main frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 420)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Rounded corners
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1,0,0,40)
TitleBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Text = "ARI HUB"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 22
TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Position = UDim2.new(0,15,0,0)
TitleLabel.Parent = TitleBar

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 60, 1, 0)
MinBtn.Position = UDim2.new(1, -60, 0, 0)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 24
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
local MinBtnCorner = Instance.new("UICorner", MinBtn)
MinBtnCorner.CornerRadius = UDim.new(0, 5)

-- Content frame (untuk isi tombol dan textbox)
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Helper function untuk buat toggle switch
local function createToggle(name, parent, default)
    local frame = Instance.new("Frame")
    frame.Name = name.."Frame"
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 5)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -60, 0.5, -12)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 16
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150,150,150)
    toggle.TextColor3 = Color3.fromRGB(255,255,255)
    toggle.Text = default and "ON" or "OFF"
    toggle.Parent = frame
    local toggleCorner = Instance.new("UICorner", toggle)
    toggleCorner.CornerRadius = UDim.new(0, 6)

    return frame, toggle
end

-- Helper function buat label + textbox (untuk speed)
local function createTextbox(name, parent, defaultText)
    local frame = Instance.new("Frame")
    frame.Name = name.."Frame"
    frame.Size = UDim2.new(1, -20, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 5)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local textbox = Instance.new("TextBox")
    textbox.Name = "TextBox"
    textbox.Size = UDim2.new(0, 70, 0, 25)
    textbox.Position = UDim2.new(1, -90, 0.5, -12)
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 18
    textbox.TextColor3 = Color3.fromRGB(255,255,255)
    textbox.BackgroundColor3 = Color3.fromRGB(50,50,50)
    textbox.Text = tostring(defaultText)
    textbox.ClearTextOnFocus = false
    textbox.Parent = frame
    local textboxCorner = Instance.new("UICorner", textbox)
    textboxCorner.CornerRadius = UDim.new(0, 6)

    return frame, textbox
end

-- Tempat semua elemen UI
local UIElements = {}

-- Speed toggle & textbox
local speedFrame, speedToggle = createToggle("Speed", ContentFrame, config.SpeedEnabled)
speedFrame.Position = UDim2.new(0, 10, 0, 10)
local _, speedTextbox = createTextbox("Speed Value", speedFrame, config.SpeedValue)
speedTextbox.Position = UDim2.new(1, -90, 0.5, -12)
speedTextbox.Parent = speedFrame

-- Infinite Jump toggle
local infJumpFrame, infJumpToggle = createToggle("Infinite Jump", ContentFrame, config.InfiniteJump)
infJumpFrame.Position = UDim2.new(0, 10, 0, 55)

-- Clip toggle
local clipFrame, clipToggle = createToggle("Clip (Tembus Tembok)", ContentFrame, config.Clip)
clipFrame.Position = UDim2.new(0, 10, 0, 100)

-- ESP toggle
local espFrame, espToggle = createToggle("ESP Username + Jarak", ContentFrame, config.ESPEnabled)
espFrame.Position = UDim2.new(0, 10, 0, 145)

-- Block mini toggle
local blockFrame, blockToggle = createToggle("Block Mini Transparan", ContentFrame, config.BlockEnabled)
blockFrame.Position = UDim2.new(0, 10, 0, 190)

-- --- FUNGSI MINIMIZE/MAXIMIZE ---
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    if minimized then
        -- maximize
        ContentFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 320, 0, 420)
        MinBtn.Text = "-"
        minimized = false
    else
        -- minimize
        ContentFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 320, 0, 40)
        MinBtn.Text = "+"
        minimized = true
    end
end)

-- --- Dragging GUI ---
local dragging = false
local dragInput, mousePos, framePos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        local newPos = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        MainFrame.Position = newPos
    end
end)

-- --- FEATURE IMPLEMENTATION ---

-- Speed
local function applySpeed(enabled, speedValue)
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if enabled then
            humanoid.WalkSpeed = speedValue
        else
            humanoid.WalkSpeed = 16
        end
    end
end

-- Infinite jump
local infJumpEnabled = config.InfiniteJump
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Clip (tembus tembok)
local clipEnabled = config.Clip
local clipPart
local function updateClip(enabled)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if enabled then
        -- Buat block transparan tembus tembok di sekitar rootPart supaya bisa clip
        if not clipPart then
            clipPart = Instance.new("Part")
            clipPart.Name = "ClipPart"
            clipPart.Size = Vector3.new(2, 5, 2)
            clipPart.Transparency = 1
            clipPart.CanCollide = false
            clipPart.Anchored = false
            clipPart.Parent = workspace
            local weld = Instance.new("WeldConstraint", clipPart)
            weld.Part0 = clipPart
            weld.Part1 = root
        end
    else
        if clipPart then
            clipPart:Destroy()
            clipPart = nil
        end
    end
end

-- ESP Username + jarak
local espEnabled = config.ESPEnabled
local espTags = {}

local function createEspTag(plr)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPTag"
    billboard.Adornee = plr.Character and plr.Character:FindFirstChild("Head")
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.Parent = playerGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 0.5
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 18
    textLabel.TextStrokeTransparency = 0.7
    textLabel.Parent = billboard

    return billboard, textLabel
end

local function updateEsp()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then
            if espEnabled then
                if not espTags[plr] then
                    local billboard, textLabel = createEspTag(plr)
                    espTags[plr] = {Billboard = billboard, Label = textLabel}
                end
                local tags = espTags[plr]
                local head = plr.Character and plr.Character:FindFirstChild("Head")
                if head then
                    tags.Billboard.Adornee = head
                    local dist = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
                    (player.Character.HumanoidRootPart.Position - head.Position).Magnitude) or 0
                    tags.Label.Text = plr.Name .. "\n" .. string.format("%.1f", dist) .. " studs"
                    tags.Billboard.Enabled = true
                else
                    tags.Billboard.Enabled = false
                end
            else
                -- remove esp jika ada
                if espTags[plr] then
                    espTags[plr].Billboard:Destroy()
                    espTags[plr] = nil
                end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    if espTags[plr] then
        espTags[plr].Billboard:Destroy()
        espTags[plr] = nil
    end
end)

-- Block mini transparan di bawah karakter (seperti plat)
local blockPart
local blockEnabled = config.BlockEnabled
local function updateBlock(enabled)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if enabled then
        if not blockPart then
            blockPart = Instance.new("Part")
            blockPart.Name = "MiniBlock"
            blockPart.Size = Vector3.new(6, 0.5, 6)
            blockPart.Transparency = 0.5
            blockPart.Anchored = true
            blockPart.CanCollide = true
            blockPart.Material = Enum.Material.Neon
            blockPart.Color = Color3.fromRGB(0, 170, 255)
            blockPart.Parent = workspace
        end
        blockPart.Position = Vector3.new(root.Position.X, root.Position.Y - 3.2, root.Position.Z)
    else
        if blockPart then
            blockPart:Destroy()
            blockPart = nil
        end
    end
end

-- Anti AFK kuat
for _, v in pairs(getconnections or {})() do
    if v and type(v) == "function" then
        -- disable connections to idle event
        pcall(function()
            v:Disable()
        end)
    end
end

-- Alternatively strong anti afk
local VirtualUser = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Update loop untuk fitur aktif
RunService.Heartbeat:Connect(function()
    -- Speed
    if config.SpeedEnabled then
        applySpeed(true, tonumber(config.SpeedValue) or 0)
    else
        applySpeed(false)
    end

    -- Clip
    updateClip(config.Clip)

    -- Block mini
    updateBlock(config.BlockEnabled)

    -- ESP update
    if config.ESPEnabled then
        updateEsp()
    else
        -- Hapus semua ESP jika disable
        for plr, tags in pairs(espTags) do
            if tags and tags.Billboard then
                tags.Billboard.Enabled = false
            end
        end
    end
end)

-- EVENT LISTENER UNTUK UI TOGGLE

speedToggle.MouseButton1Click:Connect(function()
    config.SpeedEnabled = not config.SpeedEnabled
    speedToggle.Text = config.SpeedEnabled and "ON" or "OFF"
    speedToggle.BackgroundColor3 = config.SpeedEnabled and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150,150,150)
    saveConfig()
end)

speedTextbox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local val = tonumber(speedTextbox.Text)
        if val and val >= 0 then
            config.SpeedValue = val
            saveConfig()
        else
            speedTextbox.Text = tostring(config.SpeedValue)
        end
    end
end)

infJumpToggle.MouseButton1Click:Connect(function()
    config.InfiniteJump = not config.InfiniteJump
    infJumpToggle.Text = config.InfiniteJump and "ON" or "OFF"
    infJumpToggle.BackgroundColor3 = config.InfiniteJump and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150,150,150)
    infJumpEnabled = config.InfiniteJump
    saveConfig()
end)

clipToggle.MouseButton1Click:Connect(function()
    config.Clip = not config.Clip
    clipToggle.Text = config.Clip and "ON" or "OFF"
    clipToggle.BackgroundColor3 = config.Clip and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150,150,150)
    clipEnabled = config.Clip
    updateClip(clipEnabled)
    saveConfig()
end)

espToggle.MouseButton1Click:Connect(function()
    config.ESPEnabled = not config.ESPEnabled
    espToggle.Text = config.ESPEnabled and "ON" or "OFF"
    espToggle.BackgroundColor3 = config.ESPEnabled and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150,150,150)
    espEnabled = config.ESPEnabled
    if not espEnabled then
        for _, tags in pairs(espTags) do
            if tags.Billboard then
                tags.Billboard.Enabled = false
            end
        end
    end
    saveConfig()
end)

blockToggle.MouseButton1Click:Connect(function()
    config.BlockEnabled = not config.BlockEnabled
    blockToggle.Text = config.BlockEnabled and "ON" or "OFF"
    blockToggle.BackgroundColor3 = config.BlockEnabled and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150,150,150)
    blockEnabled = config.BlockEnabled
    updateBlock(blockEnabled)
    saveConfig()
end)

-- Set UI initial values sesuai config
speedToggle.Text = config.SpeedEnabled and "ON" or "OFF"
speedToggle.BackgroundColor3 = config.SpeedEnabled and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150,150,150)
speedTextbox.Text = tostring(config.SpeedValue)

infJumpToggle.Text = config.InfiniteJump and "ON" or "OFF"
infJumpToggle.BackgroundColor3 = config.InfiniteJump and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150,150,150)

clipToggle.Text = config.Clip and "ON" or "OFF"
clipToggle.BackgroundColor3 = config.Clip and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150,150,150)

espToggle.Text = config.ESPEnabled and "ON" or "OFF"
espToggle.BackgroundColor3 = config.ESPEnabled and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150,150,150)

blockToggle.Text = config.BlockEnabled and "ON" or "OFF"
blockToggle.BackgroundColor3 = config.BlockEnabled and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150,150,150)

-- Respawn handling (re-apply block, clip, esp)
player.CharacterAdded:Connect(function(char)
    wait(1)
    updateClip(config.Clip)
    updateBlock(config.BlockEnabled)
end)

