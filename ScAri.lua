-- ARI HUB Script for Delta Executor (Android Optimized)
-- By [Your Name]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")

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

-- Improved ESP System
local espObjects = {}
local function updateESP()
    if not settings.espEnabled then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character then
            local char = plr.Character
            local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart and rootPart then
                local distance = (humanoidRootPart.Position - rootPart.Position).Magnitude
                
                if distance <= settings.espDistance then
                    if not espObjects[plr] then
                        -- Create ESP objects
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
                        billboard.Size = UDim2.new(0, 200, 0, 50)
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
                        distanceLabel.Text = string.format("%.1f studs", distance)
                        distanceLabel.TextScaled = true
                        distanceLabel.Font = Enum.Font.GothamBold
                        distanceLabel.Parent = billboard
                        
                        espObjects[plr] = {
                            highlight = highlight,
                            billboard = billboard
                        }
                    else
                        -- Update existing ESP
                        espObjects[plr].highlight.Parent = char
                        espObjects[plr].billboard.Parent = char
                        local distanceLabel = espObjects[plr].billboard:FindFirstChild("DistanceLabel")
                        if distanceLabel then
                            distanceLabel.Text = string.format("%.1f studs", distance)
                        end
                    end
                elseif espObjects[plr] then
                    -- Hide if too far
                    espObjects[plr].highlight.Parent = nil
                    espObjects[plr].billboard.Parent = nil
                end
            end
        elseif espObjects[plr] then
            -- Clean up if player left
            espObjects[plr].highlight:Destroy()
            espObjects[plr].billboard:Destroy()
            espObjects[plr] = nil
        end
    end
end

-- Improved Platform System
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

-- Improved Anti-Clip (Now allows clipping)
local function antiClip()
    if not settings.antiClipEnabled then return end
    
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
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
    
    -- Create toggle buttons with smaller size
    local yOffset = 5
    local buttonHeight = 35 -- Smaller buttons
    
    -- Speed Toggle
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
    SpeedLabel.Size = UDim2.new(0.6, 0, 1, 0)
    SpeedLabel.Position = UDim2.new(0, 10, 0, 0)
    SpeedLabel.BackgroundTransparency = 1
    SpeedLabel.Text = "Speed"
    SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextSize = 14 -- Smaller
    SpeedLabel.Parent = SpeedToggle
    
    local SpeedSwitch = Instance.new("TextButton")
    SpeedSwitch.Size = UDim2.new(0, 50, 0, 20) -- Smaller
    SpeedSwitch.Position = UDim2.new(1, -60, 0.5, -10)
    SpeedSwitch.BackgroundColor3 = settings.speedEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    SpeedSwitch.Text = settings.speedEnabled and "ON" or "OFF"
    SpeedSwitch.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedSwitch.Font = Enum.Font.GothamBold
    SpeedSwitch.TextSize = 14 -- Smaller
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
    
    yOffset = yOffset + buttonHeight + 5
    
    -- Speed Value TextBox
    local SpeedValueFrame = Instance.new("Frame")
    SpeedValueFrame.Size = UDim2.new(1, -10, 0, buttonHeight)
    SpeedValueFrame.Position = UDim2.new(0, 5, 0, yOffset)
    SpeedValueFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SpeedValueFrame.BackgroundTransparency = 0.5
    SpeedValueFrame.Parent = ScrollFrame
    
    local SpeedValueCorner = Instance.new("UICorner")
    SpeedValueCorner.CornerRadius = UDim.new(0, 5)
    SpeedValueCorner.Parent = SpeedValueFrame
    
    local SpeedValueLabel = Instance.new("TextLabel")
    SpeedValueLabel.Size = UDim2.new(0.5, 0, 1, 0)
    SpeedValueLabel.Position = UDim2.new(0, 10, 0, 0)
    SpeedValueLabel.BackgroundTransparency = 1
    SpeedValueLabel.Text = "Speed Value:"
    SpeedValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    SpeedValueLabel.Font = Enum.Font.Gotham
    SpeedValueLabel.TextSize = 14 -- Smaller
    SpeedValueLabel.Parent = SpeedValueFrame
    
    local SpeedValueBox = Instance.new("TextBox")
    SpeedValueBox.Size = UDim2.new(0, 80, 0, 25) -- Smaller
    SpeedValueBox.Position = UDim2.new(1, -90, 0.5, -12.5)
    SpeedValueBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    SpeedValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SpeedValueBox.Text = tostring(settings.speedValue)
    SpeedValueBox.Font = Enum.Font.Gotham
    SpeedValueBox.TextSize = 14 -- Smaller
    SpeedValueBox.Parent = SpeedValueFrame
    
    local SpeedValueBoxCorner = Instance.new("UICorner")
    SpeedValueBoxCorner.CornerRadius = UDim.new(0, 5)
    SpeedValueBoxCorner.Parent = SpeedValueBox
    
    SpeedValueBox.FocusLost:Connect(function()
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
    
    -- Create other toggle buttons (same pattern as SpeedToggle)
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
        settings.infJumpEnabled = not settings.infJumpEnabled
        InfJumpSwitch.BackgroundColor3 = settings.infJumpEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        InfJumpSwitch.Text = settings.infJumpEnabled and "ON" or "OFF"
        saveSettings()
    end)
    
    yOffset = yOffset + buttonHeight + 5
    
    -- Anti-Clip Toggle
    local AntiClipToggle = Instance.new("Frame")
    AntiClipToggle.Size = UDim2.new(1, -10, 0, buttonHeight)
    AntiClipToggle.Position = UDim2.new(0, 5, 0, yOffset)
    AntiClipToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    AntiClipToggle.BackgroundTransparency = 0.5
    AntiClipToggle.Parent = ScrollFrame
    
    local AntiClipCorner = Instance.new("UICorner")
    AntiClipCorner.CornerRadius = UDim.new(0, 5)
    AntiClipCorner.Parent = AntiClipToggle
    
    local AntiClipLabel = Instance.new("TextLabel")
    AntiClipLabel.Size = UDim2.new(0.6, 0, 1, 0)
    AntiClipLabel.Position = UDim2.new(0, 10, 0, 0)
    AntiClipLabel.BackgroundTransparency = 1
    AntiClipLabel.Text = "Anti-Clip"
    AntiClipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    AntiClipLabel.TextXAlignment = Enum.TextXAlignment.Left
    AntiClipLabel.Font = Enum.Font.Gotham
    AntiClipLabel.TextSize = 14
    AntiClipLabel.Parent = AntiClipToggle
    
    local AntiClipSwitch = Instance.new("TextButton")
    AntiClipSwitch.Size = UDim2.new(0, 50, 0, 20)
    AntiClipSwitch.Position = UDim2.new(1, -60, 0.5, -10)
    AntiClipSwitch.BackgroundColor3 = settings.antiClipEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    AntiClipSwitch.Text = settings.antiClipEnabled and "ON" or "OFF"
    AntiClipSwitch.TextColor3 = Color3.fromRGB(255, 255, 255)
    AntiClipSwitch.Font = Enum.Font.GothamBold
    AntiClipSwitch.TextSize = 14
    AntiClipSwitch.Parent = AntiClipToggle
    
    local AntiClipSwitchCorner = Instance.new("UICorner")
    AntiClipSwitchCorner.CornerRadius = UDim.new(0, 10)
    AntiClipSwitchCorner.Parent = AntiClipSwitch
    
    AntiClipSwitch.MouseButton1Click:Connect(function()
        settings.antiClipEnabled = not settings.antiClipEnabled
        AntiClipSwitch.BackgroundColor3 = settings.antiClipEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        AntiClipSwitch.Text = settings.antiClipEnabled and "ON" or "OFF"
        saveSettings()
        antiClip()
    end)
    
    yOffset = yOffset + buttonHeight + 5
    
    -- ESP Toggle
    local EspToggle = Instance.new("Frame")
    EspToggle.Size = UDim2.new(1, -10, 0, buttonHeight)
    EspToggle.Position = UDim2.new(0, 5, 0, yOffset)
    EspToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    EspToggle.BackgroundTransparency = 0.5
    EspToggle.Parent = ScrollFrame
    
    local EspCorner = Instance.new("UICorner")
    EspCorner.CornerRadius = UDim.new(0, 5)
    EspCorner.Parent = EspToggle
    
    local EspLabel = Instance.new("TextLabel")
    EspLabel.Size = UDim2.new(0.6, 0, 1, 0)
    EspLabel.Position = UDim2.new(0, 10, 0, 0)
    EspLabel.BackgroundTransparency = 1
    EspLabel.Text = "ESP Players"
    EspLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    EspLabel.TextXAlignment = Enum.TextXAlignment.Left
    EspLabel.Font = Enum.Font.Gotham
    E
