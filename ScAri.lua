-- ARI HUB Script for Delta Executor (Android Optimized)
-- By [Your Name]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local settings = {
    speedEnabled = false,
    speedValue = 50,
    infJumpEnabled = false,
    antiClipEnabled = false,
    espEnabled = false,
    espDistance = 500,
    antiAfkEnabled = false,
    platformEnabled = false
}

-- Load settings
local function loadSettings()
    if isfile and isfile("ARI_HUB_settings.json") then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile("ARI_HUB_settings.json"))
        end)
        if success then return data end
    end
    return settings
end

-- Save settings
local function saveSettings()
    if writefile then
        writefile("ARI_HUB_settings.json", HttpService:JSONEncode(settings))
    end
end

settings = loadSettings()

-- ESP System
local espObjects = {}
local function updateESP()
    if not settings.espEnabled then
        -- Remove all ESP objects when disabled
        for plr, espData in pairs(espObjects) do
            if espData.highlight then espData.highlight:Destroy() end
            if espData.billboard then espData.billboard:Destroy() end
            espObjects[plr] = nil
        end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local char = plr.Character
            local hrp = char.HumanoidRootPart
            local dist = (hrp.Position - rootPart.Position).Magnitude
            if dist <= settings.espDistance then
                if not espObjects[plr] then
                    -- Create ESP
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ARI_ESP"
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.FillTransparency = 0.5
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = char

                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ARI_ESPInfo"
                    billboard.AlwaysOnTop = true
                    billboard.Size = UDim2.new(0, 150, 0, 40)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.Parent = char

                    local nameLabel = Instance.new("TextLabel")
                    nameLabel.Name = "NameLabel"
                    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    nameLabel.BackgroundTransparency = 1
                    nameLabel.Text = plr.Name
                    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    nameLabel.TextScaled = true
                    nameLabel.Font = Enum.Font.GothamBold
                    nameLabel.Parent = billboard

                    local distanceLabel = Instance.new("TextLabel")
                    distanceLabel.Name = "DistanceLabel"
                    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    distanceLabel.BackgroundTransparency = 1
                    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    distanceLabel.Text = string.format("%.1f studs", dist)
                    distanceLabel.TextScaled = true
                    distanceLabel.Font = Enum.Font.GothamBold
                    distanceLabel.Parent = billboard

                    espObjects[plr] = {
                        highlight = highlight,
                        billboard = billboard
                    }
                else
                    local data = espObjects[plr]
                    data.highlight.Parent = char
                    data.billboard.Parent = char
                    local distanceLabel = data.billboard:FindFirstChild("DistanceLabel")
                    if distanceLabel then
                        distanceLabel.Text = string.format("%.1f studs", dist)
                    end
                end
            else
                if espObjects[plr] then
                    espObjects[plr].highlight.Parent = nil
                    espObjects[plr].billboard.Parent = nil
                end
            end
        else
            -- Clean up if player leaves
            if espObjects[plr] then
                espObjects[plr].highlight:Destroy()
                espObjects[plr].billboard:Destroy()
                espObjects[plr] = nil
            end
        end
    end
end

-- Platform System
local platform = nil
local function updatePlatform()
    if not settings.platformEnabled then
        if platform then
            platform:Destroy()
            platform = nil
        end
        return
    end

    if not platform then
        platform = Instance.new("Part")
        platform.Name = "ARI_Platform"
        platform.Anchored = true
        platform.CanCollide = true
        platform.Transparency = 0.3
        platform.Size = Vector3.new(10, 1, 10)
        platform.Color = Color3.fromRGB(0, 170, 255)
        platform.Material = Enum.Material.Neon
        platform.Parent = workspace
    end

    if rootPart then
        platform.CFrame = CFrame.new(rootPart.Position.X, rootPart.Position.Y - 5, rootPart.Position.Z)
    end
end

-- Anti-Clip (force CanCollide = false on all character parts every frame)
local function antiClip()
    if not settings.antiClipEnabled then return end
    if not character then return end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Speed System
local function updateSpeed()
    if humanoid then
        humanoid.WalkSpeed = settings.speedEnabled and settings.speedValue or 16
    end
end

-- Infinite Jump
local function infiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if settings.infJumpEnabled and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

-- Anti-AFK
local function antiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        if settings.antiAfkEnabled then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

-- Create Mobile GUI (30% smaller)
local function createMobileGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ARI_HUB_Mobile"
    ScreenGui.Parent = CoreGui

    -- Main Frame (30% smaller)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0.56, 0, 0.42, 0) -- Reduced by 30%
    MainFrame.Position = UDim2.new(0.22, 0, 0.29, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    -- Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame

    -- Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 170, 255)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame

    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 30) -- Smaller
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "ARI HUB"
    Title.TextColor3 = Color3.fromRGB(0, 170, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16 -- Smaller
    Title.Parent = TitleBar

    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 25, 0, 25) -- Smaller
    CloseButton.Position = UDim2.new(1, -30, 0.5, -12.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14 -- Smaller
    CloseButton.Parent = TitleBar

    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 25, 0, 25) -- Smaller
    MinimizeButton.Position = UDim2.new(1, -60, 0.5, -12.5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.Text = "_"
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 14 -- Smaller
    MinimizeButton.Parent = TitleBar

    -- Scrolling Frame
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -10, 1, -35) -- Adjusted
    ScrollFrame.Position = UDim2.new(0, 5, 0, 35)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 6 -- Thinner
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 600) -- Smaller
    ScrollFrame.Parent = MainFrame

    -- Minimize functionality
    local minimized = false
    local originalSize = MainFrame.Size
    local originalPosition = MainFrame.Position

    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            MainFrame.Size = UDim2.new(0, 150, 0, 30) -- Minimized size
            MainFrame.Position = UDim2.new(0, 10, 0, 10) -- Top-left corner
            ScrollFrame.Visible = false
            MinimizeButton.Text = "+"
        else
            MainFrame.Size = originalSize
            MainFrame.Position = originalPosition
            ScrollFrame.Visible = true
            MinimizeButton.Text = "_"
        end
    end)

    -- Y offset for buttons
    local yOffset = 5
    local buttonHeight = 35 -- Smaller buttons

    -- Speed Toggle Frame
    local SpeedToggle = Instance.new("Frame")
    SpeedToggle.Size = UDim2.new(1, -10, 0, buttonHeight)
    SpeedToggle.Position = UDim2.new(0, 5, 0, yOffset)
    SpeedToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SpeedToggle.BackgroundTransparency = 0.5
    SpeedToggle.Parent = ScrollFrame

    local SpeedCorner = Instance.new("UICorner")
    SpeedCorner.CornerRadius = UDim.new(0, 5)
    SpeedCorner.Parent = SpeedToggle

    local SpeedLabel = Instance.new("TextLabel")
    SpeedLabel.Size = UDim2.new(0.4, 0, 1, 0)
    SpeedLabel.Position = UDim2.new(0, 10, 0, 0)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Speed"
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextSize = 14 -- Smaller
    SpeedLabel.Parent = SpeedToggle

    -- Speed Enabled Button
    local SpeedSwitch = Instance.new("TextButton")
    SpeedSwitch.Size = UDim2.new(0, 50, 0, 25)
    SpeedSwitch.Position = UDim2.new(1, -60, 0.5, -12.5)
    SpeedSwitch.BackgroundColor3 = settings.speedEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    SpeedSwitch.Text = settings.speedEnabled and "ON" or "OFF"
    SpeedSwitch.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedSwitch.Font = Enum.Font.GothamBold
    SpeedSwitch.TextSize = 14
    SpeedSwitch.Parent = SpeedToggle

    local SpeedSwitchCorner = Instance.new("UICorner")
    SpeedSwitchCorner.CornerRadius = UDim.new(0, 10)
    SpeedSwitchCorner.Parent = SpeedSwitch

    SpeedSwitch.MouseButton1Click:Connect(function()
        settings.speedEnabled = not settings.speedEnabled
        SpeedSwitch.BackgroundColor3 = settings.speedEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        SpeedSwitch.Text = settings.speedEnabled and "ON" or "OFF"
        saveSettings()
        updateSpeed()
    end)

    -- Speed Value TextBox
    local SpeedValueBox = Instance.new("TextBox")
    SpeedValueBox.Size = UDim2.new(0, 80, 0, 25)
    SpeedValueBox.Position = UDim2.new(1, -150, 0.5, -12.5)
    SpeedValueBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SpeedValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedValueBox.Text = tostring(settings.speedValue)
    SpeedValueBox.Font = Enum.Font.Gotham
    SpeedValueBox.TextSize = 14
    SpeedValueBox.Parent = SpeedToggle

    local SpeedValueBoxCorner = Instance.new("UICorner")
    SpeedValueBoxCorner.CornerRadius = UDim.new(0, 5)
    SpeedValueBoxCorner.Parent = SpeedValueBox

    SpeedValueBox.FocusLost:Connect(function(enterPressed)
        local value = tonumber(SpeedValueBox.Text)
        if value and value > 0 then
            settings.speedValue = value
            SpeedValueBox.Text = tostring(settings.speedValue)
            saveSettings()
            updateSpeed()
        else
            SpeedValueBox.Text = tostring(settings.speedValue)
        end
    end)

    yOffset = yOffset + buttonHeight + 5

    -- Infinite Jump Toggle
    local InfJumpToggle = Instance.new("Frame")
    InfJumpToggle.Size = UDim2.new(1, -10, 0, buttonHeight)
    InfJumpToggle.Position = UDim2.new(0, 5, 0, yOffset)
    InfJumpToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    InfJumpToggle.BackgroundTransparency = 0.5
    InfJumpToggle.Parent = ScrollFrame

    local InfJumpCorner = Instance.new("UICorner")
    InfJumpCorner.CornerRadius = UDim.new(0, 5)
    InfJumpCorner.Parent = InfJumpToggle

    local InfJumpLabel = Instance.new("TextLabel")
    InfJumpLabel.Size = UDim2.new(0.6, 0, 1, 0)
    InfJumpLabel.Position = UDim2.new(0, 10, 0, 0)
    InfJumpLabel.BackgroundTransparency = 1
    InfJumpLabel.Text = "Inf Jump"
    InfJumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfJumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfJumpLabel.Font = Enum.Font.Gotham
    InfJumpLabel.TextSize = 14
    InfJumpLabel.Parent = InfJumpToggle

    local InfJumpSwitch = Instance.new("TextButton")
    InfJumpSwitch.Size = UDim2.new(0, 50, 0, 20)
    InfJumpSwitch.Position = UDim2.new(1, -60, 0.5, -10)
    InfJumpSwitch.BackgroundColor3 = settings.infJumpEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    InfJumpSwitch.Text = settings.infJumpEnabled and "ON" or "OFF"
    InfJumpSwitch.TextColor3 = Color3.fromRGB(255, 255, 255)
    InfJumpSwitch.Font = Enum.Font.GothamBold
    InfJumpSwitch.TextSize = 14
    InfJumpSwitch.Parent = InfJumpToggle

    local InfJumpSwitchCorner = Instance.new("UICorner")
    InfJumpSwitchCorner.CornerRadius = UDim.new(0, 10)
    InfJumpSwitchCorner.Parent = InfJumpSwitch

    InfJumpSwitch.MouseButton1Click:Connect(function()
        settings.infJump
            
