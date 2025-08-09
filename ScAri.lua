-- ARI HUB Script Fix lengkap - Delta Executor Android
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local fileName = "ARI HUB.json"

local config = {
    SpeedEnabled = false,
    SpeedValue = 0,
    InfiniteJump = false,
    Clip = false,
    ESPEnabled = false,
    BlockEnabled = false,
}

-- Save & Load Config
local function saveConfig()
    local json = HttpService:JSONEncode(config)
    if writefile then
        pcall(function() writefile(fileName, json) end)
    end
end

local function loadConfig()
    if isfile and isfile(fileName) then
        local success, content = pcall(function() return readfile(fileName) end)
        if success and content then
            local data = HttpService:JSONDecode(content)
            if type(data) == "table" then
                config = data
            end
        end
    end
end

loadConfig()

-- Bersihkan GUI lama kalau ada
local oldGui = playerGui:FindFirstChild("ARIHUB")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ARIHUB"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

-- Frame Utama (50% dari sebelumnya)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 175, 0, 220) -- 50% ukuran awal (350x440)
MainFrame.Position = UDim2.new(0.5, -87, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 14)

-- Efek gradient glossy sederhana
local UIGradient = Instance.new("UIGradient", MainFrame)
UIGradient.Rotation = 45
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(50,50,60)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30,30,40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50,50,60)),
}

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 22)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleBar.Parent = MainFrame
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 14)

-- Judul dengan glow efek sederhana via TextStroke
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Text = "ARI HUB"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -50, 1, 0)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Parent = TitleBar
TitleLabel.TextStrokeTransparency = 0.6
TitleLabel.TextStrokeColor3 = Color3.fromRGB(255, 50, 50)

-- Minimize / Maximize button
local MinBtn = Instance.new("TextButton")
MinBtn.Name = "MinBtn"
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Position = UDim2.new(1, -40, 0, 0)
MinBtn.Text = "-"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 20
MinBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 0, 0)
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TitleBar
local MinBtnCorner = Instance.new("UICorner", MinBtn)
MinBtnCorner.CornerRadius = UDim.new(0, 10)

-- Frame konten dengan scrolling jika perlu
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -22)
ContentFrame.Position = UDim2.new(0, 0, 0, 22)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame
ContentFrame.ScrollBarThickness = 6
ContentFrame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

local UIListLayout = Instance.new("UIListLayout", ContentFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- Fungsi membuat toggle rapi
local function createToggle(text, parent, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(45,45,55)
    frame.Parent = parent
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.75, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 50, 0, 22)
    toggleBtn.Position = UDim2.new(1, -65, 0.5, -11)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 200, 80) or Color3.fromRGB(150, 150, 150)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 14
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Parent = frame
    local toggleCorner = Instance.new("UICorner", toggleBtn)
    toggleCorner.CornerRadius = UDim.new(0, 8)

    return frame, toggleBtn
end

-- Fungsi membuat label + textbox
local function createTextbox(text, parent, defaultText)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(45,45,55)
    frame.Parent = parent
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = Enum.Font.Gotham
    label.TextSize = 16
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0, 70, 0, 22)
    textbox.Position = UDim2.new(1, -90, 0.5, -11)
    textbox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    textbox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 14
    textbox.Text = tostring(defaultText)
    textbox.ClearTextOnFocus = false
    textbox.Parent = frame
    local textboxCorner = Instance.new("UICorner", textbox)
    textboxCorner.CornerRadius = UDim.new(0, 8)

    return frame, textbox
end

-- Buat UI elemen
local speedFrame, speedToggle = createToggle("Speed", ContentFrame, config.SpeedEnabled)
local _, speedTextbox = createTextbox("Speed Value", ContentFrame, config.SpeedValue)
local infJumpFrame, infJumpToggle = createToggle("Infinite Jump", ContentFrame, config.InfiniteJump)
local clipFrame, clipToggle = createToggle("Clip (Tembus Tembok)", ContentFrame, config.Clip)
local espFrame, espToggle = createToggle("ESP Username + Jarak", ContentFrame, config.ESPEnabled)
local blockFrame, blockToggle = createToggle("Block Mini Transparan", ContentFrame, config.BlockEnabled)

-- Minimize toggle logic
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    if minimized then
        ContentFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 175, 0, 220)
        MinBtn.Text = "-"
        minimized = false
    else
        ContentFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 175, 0, 22)
        MinBtn.Text = "+"
        minimized = true
    end
end)

-- Dragging GUI (Touch & Mouse)
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

-- Fitur speed
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

-- Clip tembus wall
local clipEnabled = config.Clip

-- Metode clip: kita akan set CanCollide = false untuk semua part bertipe "BasePart" dalam character agar bisa tembus
local function updateClip(enabled)
    local char = player.Character
    if not char then return end
    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = not enabled
        end
    end
    -- HumanoidRootPart tetap collidable supaya stabil
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CanCollide = true end
end

-- ESP Username + jarak
local espEnabled = config.ESPEnabled
local espTags = {}

local function createEspTag(plr)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPTag"
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = playerGui

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 0.5
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 14
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
                    local dist = 0
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then dist = (hrp.Position - head.Position).Magnitude end
                    tags.Label.Text = plr.Name .. "\n" .. string.format("%.1f", dist) .. " studs"
                    tags.Billboard.Enabled = true
                else
                    tags.Billboard.Enabled = false
                end
            else
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

-- Block mini transparan di bawah karakter
local blockPart
local blockEnabled = config.BlockEnabled

local function createBlock()
    if blockPart then return end
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

local function updateBlock(enabled)
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if enabled then
        createBlock()
        -- Posisi tetap di bawah HumanoidRootPart, 3.2 studs di bawah
        blockPart.Position = Vector3.new(root.Position.X, root.Position.Y - 3.2, root.Position.Z)
    else
        if blockPart then
            blockPart:Destroy()
            blockPart = nil
        end
    end
end

-- Anti AFK kuat
local VirtualUser = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Update loop
RunService.Heartbeat:Connect(function()
    if config.SpeedEnabled then
        applySpeed(true, tonumber(config.SpeedValue) or 0)
    else
        applySpeed(false)
    end

    updateClip(config.Clip)
    updateBlock(config.BlockEnabled)

    if config.ESPEnabled then
        updateEsp()
    else
        for _, tags in pairs(espTags) do
            if tags.Billboard then
                tags.Billboard.Enabled = false
            end
        end
    end
end)

-- Event UI listeners

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

        
