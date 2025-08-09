-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- File handling
local configFile = "ARI HUB.json"
local function loadConfig()
    if isfile(configFile) then
        return HttpService:JSONDecode(readfile(configFile))
    else
        return {speed = 16, jumpPower = 50, antiClip = false, blockUnder = false}
    end
end

local function saveConfig(cfg)
    writefile(configFile, HttpService:JSONEncode(cfg))
end

local config = loadConfig()

-- State variables
local speedEnabled = false
local infJumpEnabled = false
local antiClipEnabled = config.antiClip or false
local blockUnderEnabled = config.blockUnder or false

-- Anti AFK (passive)
LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            hum.UseJumpPower = true
            hum.JumpPower = tonumber(config.jumpPower) or 50
            hum:ChangeState("Jumping")
        end
    end
end)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0.5, -125, 0, 20)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Minimize/Maximize button
local minimized = false
local miniBtn = Instance.new("TextButton")
miniBtn.Size = UDim2.new(0, 30, 0, 30)
miniBtn.Position = UDim2.new(1, -35, 0, 5)
miniBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
miniBtn.Text = "-"
miniBtn.TextScaled = true
miniBtn.Parent = MainFrame
Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "ARI HUB"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

spawn(function()
    while true do
        for hue = 0, 255, 4 do
            Title.TextColor3 = Color3.fromHSV(hue/255, 1, 1)
            wait(0.05)
        end
    end
end)

miniBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, v in ipairs(MainFrame:GetChildren()) do
        if v ~= miniBtn and v ~= Title then
            v.Visible = not minimized
        end
    end
    miniBtn.Text = minimized and "+" or "-"
end)

-- Helper button
local function createButton(text, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local function createTextBox(defaultText, yPos)
    local tb = Instance.new("TextBox")
    tb.Size = UDim2.new(1, -20, 0, 30)
    tb.Position = UDim2.new(0, 10, 0, yPos)
    tb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tb.TextColor3 = Color3.fromRGB(255, 255, 255)
    tb.Text = defaultText
    tb.TextScaled = true
    tb.Font = Enum.Font.GothamBold
    tb.Parent = MainFrame
    Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 8)
    return tb
end

-- Buttons
local speedBtn = createButton("Speed: OFF", 40)
local speedBox = createTextBox(tostring(config.speed), 75)
local jumpBtn = createButton("Inf Jump: OFF", 110)
local antiClipBtn = createButton("Anti Clip: OFF", 145)
local blockUnderBtn = createButton("Block Under: OFF", 180)

-- Speed toggle
speedBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    speedEnabled = not speedEnabled
    if speedEnabled then
        hum.WalkSpeed = tonumber(config.speed) or 16
        speedBtn.Text = "Speed: ON"
    else
        hum.WalkSpeed = 16
        speedBtn.Text = "Speed: OFF"
    end
end)

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val and val >= 16 and val <= 100000 then
        config.speed = val
        saveConfig(config)
        if speedEnabled then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    else
        speedBox.Text = tostring(config.speed)
    end
end)

-- Inf jump toggle
jumpBtn.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    jumpBtn.Text = infJumpEnabled and "Inf Jump: ON" or "Inf Jump: OFF"
end)

-- Anti Clip toggle
RunService.Stepped:Connect(function()
    if antiClipEnabled then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

antiClipBtn.MouseButton1Click:Connect(function()
    antiClipEnabled = not antiClipEnabled
    config.antiClip = antiClipEnabled
    saveConfig(config)
    antiClipBtn.Text = antiClipEnabled and "Anti Clip: ON" or "Anti Clip: OFF"
end)

-- Block Under character (static)
local blockPart
local function createBlockUnder()
    if blockPart then blockPart:Destroy() end
    blockPart = Instance.new("Part")
    blockPart.Anchored = true
    blockPart.CanCollide = true
    blockPart.Size = Vector3.new(5, 1, 5)
    blockPart.Transparency = 0.5
    blockPart.Material = Enum.Material.Neon
    blockPart.Color = Color3.fromRGB(150, 0, 150)
    blockPart.Parent = workspace
    blockPart.Position = Vector3.new(0, 3, 0) -- static position
end

blockUnderBtn.MouseButton1Click:Connect(function()
    blockUnderEnabled = not blockUnderEnabled
    config.blockUnder = blockUnderEnabled
    saveConfig(config)
    if blockUnderEnabled then
        createBlockUnder()
        blockUnderBtn.Text = "Block Under: ON"
    else
        if blockPart then blockPart:Destroy() blockPart = nil end
        blockUnderBtn.Text = "Block Under: OFF"
    end
end)

-- ESP Username + Distance
RunService.RenderStepped:Connect(function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            if not plr.Character.Head:FindFirstChild("ESPTag") then
                local billboard = Instance.new("BillboardGui", plr.Character.Head)
                billboard.Name = "ESPTag"
                billboard.Size = UDim2.new(0, 200, 0, 50)
                billboard.AlwaysOnTop = true
                local text = Instance.new("TextLabel", billboard)
                text.Size = UDim2.new(1, 0, 1, 0)
                text.BackgroundTransparency = 1
                text.TextColor3 = Color3.fromRGB(255, 255, 255)
                text.Font = Enum.Font.GothamBold
                text.TextScaled = true
                billboard.Adornee = plr.Character.Head
            end
            local head = plr.Character.Head
            local tag = head:FindFirstChild("ESPTag")
            if tag and tag:FindFirstChildOfClass("TextLabel") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - head.Position).Magnitude
                tag.TextLabel.Text = string.format("%s | %.0f", plr.Name, dist)
            end
        end
    end
end)

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.WalkSpeed = speedEnabled and (tonumber(config.speed) or 16) or 16
    if blockUnderEnabled then
        createBlockUnder()
    end
end)
