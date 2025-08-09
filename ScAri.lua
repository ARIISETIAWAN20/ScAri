-- ARI HUB Script for Delta Executor (Android Compatible)
-- Tanpa CoreGui, pakai PlayerGui
-- Semua fitur lengkap: Speed (input bebas), Infinite Jump, Anti Clip, ESP unlimited distance, Platform transparan, Anti AFK, Minimize GUI

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local settings = {
    speedEnabled = false,
    speedValue = 50,
    infJumpEnabled = false,
    antiClipEnabled = false,
    espEnabled = false,
    antiAfkEnabled = false,
    platformEnabled = false
}

-- Save & Load Settings (optional, Delta executor support check)
local function saveSettings()
    if writefile then
        pcall(function()
            writefile("ARI_HUB_settings.json", HttpService:JSONEncode(settings))
        end)
    end
end
local function loadSettings()
    if isfile then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile("ARI_HUB_settings.json"))
        end)
        if success and data then
            for k,v in pairs(data) do settings[k] = v end
        end
    end
end
loadSettings()

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ARI_HUB"
ScreenGui.Parent = playerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 380)
MainFrame.Position = UDim2.new(0.35, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,30,40)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0,170,255)
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,30)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "ARI HUB"
TitleLabel.TextColor3 = Color3.fromRGB(0,170,255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1,-80,1,0)
TitleLabel.Position = UDim2.new(0,10,0,0)
TitleLabel.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,30,0,25)
CloseBtn.Position = UDim2.new(1,-35,0.5,-12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255,50,50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = TitleBar
UICorner:Clone().Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0,30,0,25)
MinimizeBtn.Position = UDim2.new(1,-70,0.5,-12)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100,100,100)
MinimizeBtn.Text = "_"
MinimizeBtn.TextColor3 = Color3.new(1,1,1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.Parent = TitleBar
UICorner:Clone().Parent = MinimizeBtn

local minimized = false
local originalSize = MainFrame.Size
local originalPosition = MainFrame.Position

MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        MainFrame.Size = UDim2.new(0, 120, 0, 30)
        MainFrame.Position = UDim2.new(0, 10, 0, 10)
        for _,child in pairs(MainFrame:GetChildren()) do
            if child ~= TitleBar then
                child.Visible = false
            end
        end
        MinimizeBtn.Text = "+"
    else
        MainFrame.Size = originalSize
        MainFrame.Position = originalPosition
        for _,child in pairs(MainFrame:GetChildren()) do
            child.Visible = true
        end
        MinimizeBtn.Text = "_"
    end
end)

-- Container Frame for buttons
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1,-10,1,-40)
Container.Position = UDim2.new(0,5,0,35)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 6
Container.CanvasSize = UDim2.new(0,0,2,0) -- panjang scroll area
Container.Parent = MainFrame

-- Function to create toggle button + label
local function createToggle(name, defaultValue, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,35)
    frame.Position = UDim2.new(0,0,0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,50)
    frame.BackgroundTransparency = 0.5
    frame.Parent = Container
    UICorner:Clone().Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 50, 0, 25)
    toggle.Position = UDim2.new(1, -60, 0.5, -12)
    toggle.BackgroundColor3 = defaultValue and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
    toggle.Text = defaultValue and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1,1,1)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 18
    toggle.Parent = frame
    UICorner:Clone().Parent = toggle

    return frame, toggle
end

-- Function to create textbox input with label
local function createTextbox(name, defaultText, yPos)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,35)
    frame.Position = UDim2.new(0,0,0,yPos)
    frame.BackgroundColor3 = Color3.fromRGB(40,40,50)
    frame.BackgroundTransparency = 0.5
    frame.Parent = Container
    UICorner:Clone().Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1,1,1)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.Parent = frame

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(0, 100, 0, 25)
    textbox.Position = UDim2.new(1,-110,0.5,-12)
    textbox.BackgroundColor3 = Color3.fromRGB(60,60,70)
    textbox.TextColor3 = Color3.new(1,1,1)
    textbox.Text = defaultText
    textbox.Font = Enum.Font.Gotham
    textbox.TextSize = 18
    textbox.ClearTextOnFocus = false
    textbox.Parent = frame
    UICorner:Clone().Parent = textbox

    return frame, textbox
end

-- Create toggles and inputs with positions
local y = 0
local SpeedFrame, SpeedToggle = createToggle("Speed", settings.speedEnabled, y)
y = y + 40
local SpeedInputFrame, SpeedInputBox = createTextbox("Speed Value", tostring(settings.speedValue), y)
y = y + 40
local InfJumpFrame, InfJumpToggle = createToggle("Infinite Jump", settings.infJumpEnabled, y)
y = y + 40
local AntiClipFrame, AntiClipToggle = createToggle("Anti Clip", settings.antiClipEnabled, y)
y = y + 40
local ESPFrame, ESPToggle = createToggle("ESP (Unlimited Distance)", settings.espEnabled, y)
y = y + 40
local PlatformFrame, PlatformToggle = createToggle("Platform", settings.platformEnabled, y)
y = y + 40
local AntiAfkFrame, AntiAfkToggle = createToggle("Anti AFK", settings.antiAfkEnabled, y)

-- Update functions
local function updateSpeed()
    humanoid.WalkSpeed = settings.speedEnabled and settings.speedValue or 16
end

-- Speed toggle event
SpeedToggle.MouseButton1Click:Connect(function()
    settings.speedEnabled = not settings.speedEnabled
    SpeedToggle.BackgroundColor3 = settings.speedEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    SpeedToggle.Text = settings.speedEnabled and "ON" or "OFF"
    saveSettings()
    updateSpeed()
end)

-- Speed input validation
SpeedInputBox.FocusLost:Connect(function()
    local val = tonumber(SpeedInputBox.Text)
    if val and val > 0 then
        settings.speedValue = val
    else
        SpeedInputBox.Text = tostring(settings.speedValue)
    end
    saveSettings()
    updateSpeed()
end)

-- Infinite jump toggle
InfJumpToggle.MouseButton1Click:Connect(function()
    settings.infJumpEnabled = not settings.infJumpEnabled
    InfJumpToggle.BackgroundColor3 = settings.infJumpEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    InfJumpToggle.Text = settings.infJumpEnabled and "ON" or "OFF"
    saveSettings()
end)

-- Anti clip toggle
AntiClipToggle.MouseButton1Click:Connect(function()
    settings.antiClipEnabled = not settings.antiClipEnabled
    AntiClipToggle.BackgroundColor3 = settings.antiClipEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    AntiClipToggle.Text = settings.antiClipEnabled and "ON" or "OFF"
    saveSettings()
end)

-- ESP toggle
ESPToggle.MouseButton1Click:Connect(function()
    settings.espEnabled = not settings.espEnabled
    ESPToggle.BackgroundColor3 = settings.espEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    ESPToggle.Text = settings.espEnabled and "ON" or "OFF"
    saveSettings()
end)

-- Platform toggle
PlatformToggle.MouseButton1Click:Connect(function()
    settings.platformEnabled = not settings.platformEnabled
    PlatformToggle.BackgroundColor3 = settings.platformEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    PlatformToggle.Text = settings.platformEnabled and "ON" or "OFF"
    saveSettings()
end)

-- Anti AFK toggle
AntiAfkToggle.MouseButton1Click:Connect(function()
    settings.antiAfkEnabled = not settings.antiAfkEnabled
    AntiAfkToggle.BackgroundColor3 = settings.antiAfkEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    AntiAfkToggle.Text = settings.antiAfkEnabled and "ON" or "OFF"
    saveSettings()
end)

-- Infinite Jump implementation
UserInputService.JumpRequest:Connect(function()
    if settings.infJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti AFK implementation
if settings.antiAfkEnabled then
    local VirtualUser = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        if settings.antiAfkEnabled then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

-- Platform creation
local platformPart = nil
local function updatePlatform()
    if not settings.platformEnabled then
        if platformPart then
            platformPart:Destroy()
            platformPart = nil
        end
        return
    end
    if not platformPart then
        platformPart = Instance.new("Part")
        platformPart.Name = "ARI_HUB_Platform"
        platformPart.Anchored = true
        platformPart.CanCollide = true
        platformPart.Size = Vector3.new(10,1,10)
        platformPart.Color = Color3.fromRGB(0,170,255)
        platformPart.Material = Enum.Material.Neon
        platformPart.Transparency = 0.3
        platformPart.Parent = workspace
    end
    if rootPart then
        platformPart.CFrame = CFrame.new(rootPart.Position.X, rootPart.Position.Y - 5, rootPart.Position.Z)
    end
end

-- Anti Clip function (force CanCollide = false)
local function doAntiClip()
    if not settings.antiClipEnabled then return end
    if character then
        for _,part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end

-- ESP implementation unlimited distance
local espObjects = {}
local function updateESP()
    if not settings.espEnabled then
        for plr,data in pairs(espObjects) do
            if data.highlight then data.highlight:Destroy() end
            if data.billboard then data.billboard:Destroy() end
            espObjects[plr] = nil
        end
        return
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local dist = (hrp.Position - rootPart.Position).Magnitude
            if not espObjects[plr] then
                -- Create highlight
                local highlight = Instance.new("Highlight")
                highlight.Name = "ARI_HUB_ESP"
                highlight.OutlineColor = Color3.fromRGB(255,255,255)
                highlight.FillColor = Color3.fromRGB(255,0,0)
                highlight.FillTransparency = 0.5
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                highlight.Parent = plr.Character

                -- BillboardGui with name + distance
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "ARI_HUB_ESP_Billboard"
                billboard.Adornee = hrp
                billboard.AlwaysOnTop = true
                billboard.Size = UDim2.new(0,150,0,40)
                billboard.StudsOffset = Vector3.new(0,3,0)
                billboard.Parent = plr.Character

                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.new(1,0,0.5,0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = plr.Name
                nameLabel.TextColor3 = Color3.new(1,1,1)
                nameLabel.TextScaled = true
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.Parent = billboard

                local distLabel = Instance.new("TextLabel")
                distLabel.Size = UDim2.new(1,0,0.5,0)
                distLabel.Position = UDim2.new(0,0,0.5,0)
                distLabel.BackgroundTransparency = 1
                distLabel.TextColor3 = Color3.new(1,1,1)
                distLabel.TextScaled = true
                distLabel.Font = Enum.Font.GothamBold
                distLabel.Parent = billboard

                espObjects[plr] = {
                    highlight = highlight,
                    billboard = billboard,
                    distLabel = distLabel
                }
            else
                -- Update distance text
                local data = espObjects[plr]
                data.distLabel.Text = string.format("%.1f studs", dist)
                -- Make sure highlight & billboard still parented
                if not data.highlight.Parent then
                    data.highlight.Parent = plr.Character
                end
                if not data.billboard.Parent then
                    data.billboard.Parent = plr.Character
                end
            end
        else
            -- Cleanup if character missing
            if espObjects[plr] then
                if espObjects[plr].highlight then espObjects[plr].highlight:Destroy() end
                if espObjects[plr].billboard then espObjects[plr].billboard:Destroy() end
                espObjects[plr] = nil
            end
        end
    end
end

-- Main loops
RunService.Heartbeat:Connect(function()
    -- Update character refs if respawn
    if not character or not character.Parent then
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
        updateSpeed()
    end

    -- Run features
    updateSpeed()
    doAntiClip()
    updatePlatform()
    updateESP()
end)

print("ARI HUB loaded! GUI ready and all
    
