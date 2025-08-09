-- ARI HUB Script
-- By [Mang Ari]

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Variables
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local settings = {
    speedEnabled = false,
    speedValue = 0,
    infJumpEnabled = false,
    antiClipEnabled = false,
    espEnabled = false,
    espDistance = 100,
    antiAfkEnabled = false,
    platformEnabled = false
}

local platform = nil
local espParts = {}
local connections = {}

-- Load saved settings
local function loadSettings()
    if isfile("ARI HUB/ARI HUB.json") then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("ARI HUB/ARI HUB.json"))
        end)
        if success and data then
            settings = data
        end
    end
end

-- Save settings
local function saveSettings()
    if not isfolder("ARI HUB") then
        makefolder("ARI HUB")
    end
    writefile("ARI HUB/ARI HUB.json", game:GetService("HttpService"):JSONEncode(settings))
end

-- Create platform
local function createPlatform()
    if platform then platform:Destroy() end
    
    platform = Instance.new("Part")
    platform.Name = "ARIHUB_Platform"
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0.7
    platform.Size = Vector3.new(10, 1, 10)
    platform.Color = Color3.fromRGB(0, 170, 255)
    platform.Material = Enum.Material.Neon
    platform.Parent = workspace
    
    -- Position platform below player
    if rootPart then
        platform.CFrame = CFrame.new(rootPart.Position.X, rootPart.Position.Y - 5, rootPart.Position.Z)
    end
    
    return platform
end

-- Update platform position
local function updatePlatform()
    if not platform or not platform.Parent then
        platform = createPlatform()
    end
    
    if rootPart then
        platform.CFrame = CFrame.new(rootPart.Position.X, rootPart.Position.Y - 5, rootPart.Position.Z)
    end
end

-- ESP functions
local function createESP(player)
    if player == Players.LocalPlayer then return end
    
    local character = player.Character
    if not character then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "ARIHUB_ESP"
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ARIHUB_ESPInfo"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = character
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SciFi
    nameLabel.Parent = billboard
    
    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.SciFi
    distanceLabel.Parent = billboard
    
    espParts[player] = {highlight = highlight, billboard = billboard}
end

local function updateESP()
    for player, esp in pairs(espParts) do
        if player and player.Character and rootPart then
            local char = player.Character
            local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart then
                local distance = (humanoidRootPart.Position - rootPart.Position).Magnitude
                
                if distance <= settings.espDistance then
                    if not esp.highlight.Parent then
                        esp.highlight.Parent = char
                    end
                    if not esp.billboard.Parent then
                        esp.billboard.Parent = char
                    end
                    
                    local distanceLabel = esp.billboard:FindFirstChild("DistanceLabel")
                    if distanceLabel then
                        distanceLabel.Text = string.format("%.1f studs", distance)
                    end
                else
                    esp.highlight.Parent = nil
                    esp.billboard.Parent = nil
                end
            end
        else
            if esp.highlight then esp.highlight:Destroy() end
            if esp.billboard then esp.billboard:Destroy() end
            espParts[player] = nil
        end
    end
end

local function clearESP()
    for _, esp in pairs(espParts) do
        if esp.highlight then esp.highlight:Destroy() end
        if esp.billboard then esp.billboard:Destroy() end
    end
    espParts = {}
end

-- Anti-AFK
local function antiAFK()
    local virtualUser = game:GetService("VirtualUser")
    player.Idled:connect(function()
        if settings.antiAfkEnabled then
            virtualUser:CaptureController()
            virtualUser:ClickButton2(Vector2.new())
        end
    end)
end

-- Anti-Clip
local function antiClip()
    if not settings.antiClipEnabled then return end
    
    if character and rootPart then
        local lastPosition = rootPart.Position
        
        RunService.Stepped:Connect(function()
            if not settings.antiClipEnabled then return end
            
            if character and rootPart then
                local currentPosition = rootPart.Position
                local delta = (currentPosition - lastPosition).Magnitude
                
                if delta > 10 then -- Threshold for detecting clipping
                    rootPart.CFrame = CFrame.new(lastPosition)
                end
                
                lastPosition = rootPart.Position
            end
        end)
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

-- Speed
local function updateSpeed()
    if humanoid then
        if settings.speedEnabled then
            humanoid.WalkSpeed = settings.speedValue
        else
            humanoid.WalkSpeed = 16 -- Default walk speed
        end
    end
end

-- GUI Creation
local function createGUI()
    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ARIHUB_GUI"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame
    
    -- Stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 170, 255)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "ARI HUB"
    title.TextColor3 = Color3.fromRGB(0, 170, 255)
    title.TextScaled = true
    title.Font = Enum.Font.SciFi
    title.Parent = mainFrame
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0, 5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.BackgroundTransparency = 0.5
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.SciFi
    closeButton.TextSize = 18
    closeButton.Parent = mainFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Scrolling Frame
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ScrollFrame"
    scrollFrame.Size = UDim2.new(1, -20, 1, -60)
    scrollFrame.Position = UDim2.new(0, 10, 0, 50)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 5
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 700)
    scrollFrame.Parent = mainFrame
    
    -- Speed Toggle
    local speedToggle = Instance.new("Frame")
    speedToggle.Name = "SpeedToggle"
    speedToggle.Size = UDim2.new(1, -10, 0, 40)
    speedToggle.Position = UDim2.new(0, 5, 0, 5)
    speedToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    speedToggle.BackgroundTransparency = 0.5
    speedToggle.Parent = scrollFrame
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 5)
    speedCorner.Parent = speedToggle
    
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(0.6, 0, 1, 0)
    speedLabel.Position = UDim2.new(0, 10, 0, 0)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Text = "Speed Hack"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedLabel.Font = Enum.Font.SciFi
    speedLabel.TextSize = 16
    speedLabel.Parent = speedToggle
    
    local speedSwitch = Instance.new("TextButton")
    speedSwitch.Name = "SpeedSwitch"
    speedSwitch.Size = UDim2.new(0, 50, 0, 25)
    speedSwitch.Position = UDim2.new(1, -60, 0.5, -12.5)
    speedSwitch.BackgroundColor3 = settings.speedEnabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
    speedSwitch.Text = ""
    speedSwitch.Parent = speedToggle
    
    local speedSwitchCorner = Instance.new("UICorner")
    speedSwitchCorner.CornerRadius = UDim.new(0, 12)
    speedSwitchCorner.Parent = speedSwitch
    
    local speedSwitchIndicator = Instance.new("Frame")
    speedSwitchIndicator.Name = "Indicator"
    speedSwitchIndicator.Size = UDim2.new(0, 21, 0, 21)
    speedSwitchIndicator.Position = settings.speedEnabled and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
    speedSwitchIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    speedSwitchIndicator.Parent = speedSwitch
    
    local speedIndicatorCorner = Instance.new("UICorner")
    speedIndicatorCorner.CornerRadius = UDim.new(0, 10)
    speedIndicatorCorner.Parent = speedSwitchIndicator
    
    speedSwitch.MouseButton1Click:Connect(function()
        settings.speedEnabled = not settings.speedEnabled
        speedSwitch.BackgroundColor3 = settings.speedEnabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
        
        if settings.speedEnabled then
            TweenService:Create(speedSwitchIndicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -23, 0.5, -10.5)}):Play()
        else
            TweenService:Create(speedSwitchIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -10.5)}):Play()
        end
        
        updateSpeed()
        saveSettings()
    end)
    
    -- Speed Value
    local speedValueFrame = Instance.new("Frame")
    speedValueFrame.Name = "SpeedValueFrame"
    speedValueFrame.Size = UDim2.new(1, -10, 0, 40)
    speedValueFrame.Position = UDim2.new(0, 5, 0, 50)
    speedValueFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    speedValueFrame.BackgroundTransparency = 0.5
    speedValueFrame.Parent = scrollFrame
    
    local speedValueCorner = Instance.new("UICorner")
    speedValueCorner.CornerRadius = UDim.new(0, 5)
    speedValueCorner.Parent = speedValueFrame
    
    local speedValueLabel = Instance.new("TextLabel")
    speedValueLabel.Name = "SpeedValueLabel"
    speedValueLabel.Size = UDim2.new(0.6, 0, 1, 0)
    speedValueLabel.Position = UDim2.new(0, 10, 0, 0)
    speedValueLabel.BackgroundTransparency = 1
    speedValueLabel.Text = "Speed Value: " .. settings.speedValue
    speedValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedValueLabel.Font = Enum.Font.SciFi
    speedValueLabel.TextSize = 16
    speedValueLabel.Parent = speedValueFrame
    
    local speedValueBox = Instance.new("TextBox")
    speedValueBox.Name = "SpeedValueBox"
    speedValueBox.Size = UDim2.new(0, 80, 0, 25)
    speedValueBox.Position = UDim2.new(1, -90, 0.5, -12.5)
    speedValueBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    speedValueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedValueBox.Text = tostring(settings.speedValue)
    speedValueBox.Font = Enum.Font.SciFi
    speedValueBox.TextSize = 14
    speedValueBox.Parent = speedValueFrame
    
    local speedValueBoxCorner = Instance.new("UICorner")
    speedValueBoxCorner.CornerRadius = UDim.new(0, 5)
    speedValueBoxCorner.Parent = speedValueBox
    
    speedValueBox.FocusLost:Connect(function()
        local value = tonumber(speedValueBox.Text)
        if value then
            settings.speedValue = math.clamp(value, 0, 1000)
            speedValueBox.Text = tostring(settings.speedValue)
            speedValueLabel.Text = "Speed Value: " .. settings.speedValue
            updateSpeed()
            saveSettings()
        else
            speedValueBox.Text = tostring(settings.speedValue)
        end
    end)
    
    -- Infinite Jump Toggle
    local infJumpToggle = Instance.new("Frame")
    infJumpToggle.Name = "InfJumpToggle"
    infJumpToggle.Size = UDim2.new(1, -10, 0, 40)
    infJumpToggle.Position = UDim2.new(0, 5, 0, 95)
    infJumpToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    infJumpToggle.BackgroundTransparency = 0.5
    infJumpToggle.Parent = scrollFrame
    
    local infJumpCorner = Instance.new("UICorner")
    infJumpCorner.CornerRadius = UDim.new(0, 5)
    infJumpCorner.Parent = infJumpToggle
    
    local infJumpLabel = Instance.new("TextLabel")
    infJumpLabel.Name = "InfJumpLabel"
    infJumpLabel.Size = UDim2.new(0.6, 0, 1, 0)
    infJumpLabel.Position = UDim2.new(0, 10, 0, 0)
    infJumpLabel.BackgroundTransparency = 1
    infJumpLabel.Text = "Infinite Jump"
    infJumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infJumpLabel.TextXAlignment = Enum.TextXAlignment.Left
    infJumpLabel.Font = Enum.Font.SciFi
    infJumpLabel.TextSize = 16
    infJumpLabel.Parent = infJumpToggle
    
    local infJumpSwitch = Instance.new("TextButton")
    infJumpSwitch.Name = "InfJumpSwitch"
    infJumpSwitch.Size = UDim2.new(0, 50, 0, 25)
    infJumpSwitch.Position = UDim2.new(1, -60, 0.5, -12.5)
    infJumpSwitch.BackgroundColor3 = settings.infJumpEnabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
    infJumpSwitch.Text = ""
    infJumpSwitch.Parent = infJumpToggle
    
    local infJumpSwitchCorner = Instance.new("UICorner")
    infJumpSwitchCorner.CornerRadius = UDim.new(0, 12)
    infJumpSwitchCorner.Parent = infJumpSwitch
    
    local infJumpSwitchIndicator = Instance.new("Frame")
    infJumpSwitchIndicator.Name = "Indicator"
    infJumpSwitchIndicator.Size = UDim2.new(0, 21, 0, 21)
    infJumpSwitchIndicator.Position = settings.infJumpEnabled and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
    infJumpSwitchIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    infJumpSwitchIndicator.Parent = infJumpSwitch
    
    local infJumpIndicatorCorner = Instance.new("UICorner")
    infJumpIndicatorCorner.CornerRadius = UDim.new(0, 10)
    infJumpIndicatorCorner.Parent = infJumpSwitchIndicator
    
    infJumpSwitch.MouseButton1Click:Connect(function()
        settings.infJumpEnabled = not settings.infJumpEnabled
        infJumpSwitch.BackgroundColor3 = settings.infJumpEnabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
        
        if settings.infJumpEnabled then
            TweenService:Create(infJumpSwitchIndicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -23, 0.5, -10.5)}):Play()
        else
            TweenService:Create(infJumpSwitchIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -10.5)}):Play()
        end
        
        saveSettings()
    end)
    
    -- Anti-Clip Toggle
    local antiClipToggle = Instance.new("Frame")
    antiClipToggle.Name = "AntiClipToggle"
    antiClipToggle.Size = UDim2.new(1, -10, 0, 40)
    antiClipToggle.Position = UDim2.new(0, 5, 0, 140)
    antiClipToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    antiClipToggle.BackgroundTransparency = 0.5
    antiClipToggle.Parent = scrollFrame
    
    local antiClipCorner = Instance.new("UICorner")
    antiClipCorner.CornerRadius = UDim.new(0, 5)
    antiClipCorner.Parent = antiClipToggle
    
    local antiClipLabel = Instance.new("TextLabel")
    antiClipLabel.Name = "AntiClipLabel"
    antiClipLabel.Size = UDim2.new(0.6, 0, 1, 0)
    antiClipLabel.Position = UDim2.new(0, 10, 0, 0)
    antiClipLabel.BackgroundTransparency = 1
    antiClipLabel.Text = "Anti-Clip"
    antiClipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    antiClipLabel.TextXAlignment = Enum.TextXAlignment.Left
    antiClipLabel.Font = Enum.Font.SciFi
    antiClipLabel.TextSize = 16
    antiClipLabel.Parent = antiClipToggle
    
    local antiClipSwitch = Instance.new("TextButton")
    antiClipSwitch.Name = "AntiClipSwitch"
    antiClipSwitch.Size = UDim2.new(0, 50, 0, 25)
    antiClipSwitch.Position = UDim2.new(1, -60, 0.5, -12.5)
    antiClipSwitch.BackgroundColor3 = settings.antiClipEnabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
    antiClipSwitch.Text = ""
    antiClipSwitch.Parent = antiClipToggle
    
    local antiClipSwitchCorner = Instance.new("UICorner")
    antiClipSwitchCorner.CornerRadius = UDim.new(0, 12)
    antiClipSwitchCorner.Parent = antiClipSwitch
    
    local antiClipSwitchIndicator = Instance.new("Frame")
    antiClipSwitchIndicator.Name = "Indicator"
    antiClipSwitchIndicator.Size = UDim2.new(0, 21, 0, 21)
    antiClipSwitchIndicator.Position = settings.antiClipEnabled and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
    antiClipSwitchIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    antiClipSwitchIndicator.Parent = antiClipSwitch
    
    local antiClipIndicatorCorner = Instance.new("UICorner")
    antiClipIndicatorCorner.CornerRadius = UDim.new(0, 10)
    antiClipIndicatorCorner.Parent = antiClipSwitchIndicator
    
    antiClipSwitch.MouseButton1Click:Connect(function()
        settings.antiClipEnabled = not settings.antiClipEnabled
        antiClipSwitch.BackgroundColor3 = settings.antiClipEnabled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(80, 80, 80)
        
        if settings.antiClipEnabled then
            TweenService:Create(antiClipSwitchIndicator, TweenInfo.new(0.2), {Position = UDim2.new(1, -23, 0.5, -10.5)}):Play()
            antiClip()
        else
            TweenService:Create(antiClipSwitchIndicator, TweenInfo
