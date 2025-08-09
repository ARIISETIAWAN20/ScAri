-- ARI HUB Script for Delta Executor (Android Optimized)
-- By Ari Setiawan

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local playerGui = player:WaitForChild("PlayerGui")

-- Load & Save Settings
local settingsFileName = "ARI_HUB_settings.json"
local defaultSettings = {
    speedEnabled = false,
    speedValue = 50,
    infJumpEnabled = false,
    antiClipEnabled = false,
    espEnabled = false,
    espDistance = math.huge, -- unlimited
    antiAfkEnabled = false,
    platformEnabled = false
}

local function loadSettings()
    if isfile and isfile(settingsFileName) then
        local suc, data = pcall(function()
            return HttpService:JSONDecode(readfile(settingsFileName))
        end)
        if suc and data then return data end
    end
    return defaultSettings
end

local function saveSettings()
    if writefile then
        writefile(settingsFileName, HttpService:JSONEncode(settings))
    end
end

local settings = loadSettings()

-- Character & Humanoid Setup
local function getCharacter()
    return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
    local char = getCharacter()
    return char:FindFirstChildOfClass("Humanoid")
end

local function getRootPart()
    local char = getCharacter()
    return char:FindFirstChild("HumanoidRootPart")
end

-- ESP Setup
local espObjects = {}

local function createESPForPlayer(plr)
    if espObjects[plr] then return end
    local char = plr.Character
    if not char then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ARI_ESP"
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillColor = Color3.new(1, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ARI_ESPInfo"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = char

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextScaled = true
    distanceLabel.Font = Enum.Font.GothamBold
    distanceLabel.Parent = billboard

    espObjects[plr] = {
        highlight = highlight,
        billboard = billboard,
        distanceLabel = distanceLabel,
    }
end

local function removeESPForPlayer(plr)
    if espObjects[plr] then
        espObjects[plr].highlight:Destroy()
        espObjects[plr].billboard:Destroy()
        espObjects[plr] = nil
    end
end

local function updateESP()
    if not settings.espEnabled then
        for plr, _ in pairs(espObjects) do
            removeESPForPlayer(plr)
        end
        return
    end

    local rootPart = getRootPart()
    if not rootPart then return end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local dist = (hrp.Position - rootPart.Position).Magnitude

            if dist <= (settings.espDistance or math.huge) then
                createESPForPlayer(plr)
                local esp = espObjects[plr]
                esp.distanceLabel.Text = string.format("%.1f studs", dist)
                esp.highlight.Parent = plr.Character
                esp.billboard.Parent = plr.Character
            else
                removeESPForPlayer(plr)
            end
        else
            removeESPForPlayer(plr)
        end
    end
end

-- Platform block under player
local platformPart = nil
local function updatePlatform()
    if not settings.platformEnabled then
        if platformPart then
            platformPart:Destroy()
            platformPart = nil
        end
        return
    end

    local rootPart = getRootPart()
    if not rootPart then return end

    if not platformPart then
        platformPart = Instance.new("Part")
        platformPart.Name = "ARI_Platform"
        platformPart.Size = Vector3.new(10, 1, 10)
        platformPart.Anchored = true
        platformPart.CanCollide = true
        platformPart.Transparency = 0.3
        platformPart.Material = Enum.Material.Neon
        platformPart.Color = Color3.fromRGB(0, 170, 255)
        platformPart.Parent = workspace
    end

    platformPart.CFrame = CFrame.new(rootPart.Position.X, rootPart.Position.Y - 5, rootPart.Position.Z)
end

-- Anti-clip: disable collisions of all character parts
local function applyAntiClip()
    if not settings.antiClipEnabled then return end
    local char = getCharacter()
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

-- Speed update
local function updateSpeed()
    local humanoid = getHumanoid()
    if not humanoid then return end
    humanoid.WalkSpeed = settings.speedEnabled and settings.speedValue or 16
end

-- Infinite jump handler
local function initInfiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if settings.infJumpEnabled then
            local humanoid = getHumanoid()
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end

-- Anti AFK
local function initAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        if settings.antiAfkEnabled then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

-- Initialize infinite jump & anti AFK once
initInfiniteJump()
initAntiAFK()

-- GUI Creation (30% smaller size, no CoreGui, parent PlayerGui)
local function createGUI()
    -- Clear old gui
    local oldGui = playerGui:FindFirstChild("ARI_HUB")
    if oldGui then
        oldGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ARI_HUB"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = playerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0.56, 0, 0.42, 0) -- 30% smaller
    mainFrame.Position = UDim2.new(0.22, 0, 0.29, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.2
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = ScreenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 170, 255)
    stroke.Thickness = 2
    stroke.Parent = mainFrame

    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "ARI HUB"
    titleLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    titleLabel.TextScaled = true
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.Parent = titleBar

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0.5, -12.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.Parent = titleBar

    closeButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    -- Minimize Button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 25, 0, 25)
    minimizeButton.Position = UDim2.new(1, -60, 0.5, -12.5)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.Text = "_"
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 14
    minimizeButton.Parent = titleBar

    local minimized = false
    local originalSize = mainFrame.Size
    local originalPosition = mainFrame.Position

    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            mainFrame.Size = UDim2.new(0, 150, 0, 30)
            mainFrame.Position = UDim2.new(0, 10, 0, 10)
            for _, child in pairs(mainFrame:GetChildren()) do
                if child ~= titleBar then
                    child.Visible = false
                end
            end
            minimizeButton.Text = "+"
        else
            mainFrame.Size = originalSize
            mainFrame.Position = originalPosition
            for _, child in pairs(mainFrame:GetChildren()) do
                child.Visible = true
            end
            minimizeButton.Text = "_"
        end
    end)

    -- Buttons settings
    local yOffset = 5
    local buttonHeight = 35

    -- Helper function to create toggle buttons
    local function createToggle(parent, labelText, initialState, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, buttonHeight)
        frame.Position = UDim2.new(0, 5, 0, yOffset)
        frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        frame.BackgroundTransparency = 0.5
        frame.Parent = parent

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = frame

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = Color3.new(1,1,1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.Parent = frame

        local toggleBtn = Instance.new("TextButton")
        toggleBtn.Size = UDim2.new(0, 50, 0, 20)
        toggleBtn.Position = UDim2.new(1, -60, 0.5, -10)
        toggleBtn.BackgroundColor3 = initialState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        toggleBtn.Text = initialState and "ON" or "OFF"
        toggleBtn.TextColor3 = Color3.new(1,1,1)
        toggleBtn.Font = Enum.Font.GothamBold
        toggleBtn.TextSize = 14
        toggleBtn.Parent = frame

        local cornerBtn = Instance.new("UICorner")
        cornerBtn.CornerRadius = UDim.new(0, 10)
        cornerBtn.Parent = toggleBtn

        toggleBtn.MouseButton1Click:Connect(function()
            initialState = not initialState
            toggleBtn.BackgroundColor3 = initialState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            toggleBtn.Text = initialState and "ON" or "OFF"
            callback(initialState)
        end)

        yOffset = yOffset + buttonHeight + 5
    end

    -- Speed toggle
    createToggle(ScrollFrame, "Speed", settings.speedEnabled, function(state)
        settings.speedEnabled = state
        saveSettings()
        updateSpeed()
    end)

    -- Speed Value textbox
    local speedValueFrame = Instance.new("Frame")
    speedValueFrame.Size = UDim2.new(1, -10, 0, buttonHeight)
    speedValueFrame.Position = UDim2.new(0, 5, 0, yOffset)
    speedValueFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    speedValueFrame.BackgroundTransparency = 0.5
    speedValueFrame.Parent = ScrollFrame

    local speedValueCorner = Instance.new("UICorner")
    speedValueCorner.CornerRadius = UDim.new(0, 5)
    speedValueCorner.Parent = speedValueFrame

    local speedValueLabel = Instance.new("TextLabel")
    speedValueLabel.Size = UDim2.new(0.5, 0, 1, 0)
    speedValueLabel.Position = UDim2.new(0, 10, 0, 0)
    speedValueLabel.BackgroundTransparency = 1
    speedValueLabel.Text = "Speed Value:"
    speedValueLabel.TextColor3 = Color3.new(1,1,1)
    speedValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    speedValueLabel.Font = Enum.Font.Gotham
    speedValueLabel.TextSize = 14
    speedValueLabel.Parent = speedValueFrame

    local speedValueBox = Instance.new("TextBox")
    speedValueBox.Size = UDim2.new(0, 80, 0, 25)
    speedValueBox.Position = UDim2.new(1, -90, 0.5, -12.5)
    speedValueBox.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    speedValueBox.TextColor3 = Color3.new(1,1,1)
    speedValueBox.Text = tostring(settings.speedValue)
    speedValueBox.Font = Enum.Font.Gotham
    speedValueBox.TextSize = 14
    speedValueBox.Parent = speedValueFrame

    local speedValueBoxCorner = Instance.new("UICorner")
    speedValueBoxCorner.CornerRadius = UDim.new(0, 5)
    speedValueBoxCorner.Parent = speedValueBox

    speedValueBox.FocusLost:Connect(function()
        local val = tonumber(speedValueBox.Text)
        if val and val > 0 then
            settings.speedValue = val
            saveSettings()
            updateSpeed()
        else
            speedValueBox.Text = tostring(settings.speedValue)
        end
    end)

    yOffset = yOffset + buttonHeight + 5

    -- Other toggles
    createToggle(ScrollFrame, "Infinite Jump", settings.infJumpEnabled, function(state)
        settings.infJumpEnabled = state
        saveSettings()
    end)

    createToggle(ScrollFrame, "Anti Clip", settings.antiClipEnabled, function(state)
        settings.antiClipEnabled = state
        saveSettings()
        if state then
            applyAntiClip()
        else
            -- Restore collisions (optional)
            local char = getCharacter()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end)

    createToggle(ScrollFrame, "ESP Players", settings.espEnabled, function(state)
        settings.espEnabled = state
        saveSettings()
        if not state then
            for plr, _ in pairs(espObjects) do
                removeESPForPlayer(plr)
            end
        end
    end)

    -- ESP distance value
    local espDistanceFrame = Instance.new("Frame")
    
