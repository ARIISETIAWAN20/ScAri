-- ARI HUB Script for Delta Executor (Android Compatible)
-- By [Mang Ari]

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

-- Mobile-friendly GUI
local function createMobileGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ARI_HUB_Mobile"
    ScreenGui.Parent = CoreGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0.8, 0, 0.6, 0)
    MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MainFrame.BackgroundTransparency = 0.2
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = MainFrame
    
    -- Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(0, 170, 255)
    Stroke.Thickness = 2
    Stroke.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "ARI HUB MOBILE"
    Title.TextColor3 = Color3.fromRGB(0, 170, 255)
    Title.TextScaled = true
    Title.Font = Enum.Font.GothamBold
    Title.Parent = TitleBar
    
    -- Close Button (Mobile-friendly size)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.Text = "X"
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 18
    CloseButton.Parent = TitleBar
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Scrolling Frame (For mobile touch)
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, -10, 1, -50)
    ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 8  -- Thicker for mobile
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 800)
    ScrollFrame.Parent = MainFrame
    
    -- Create mobile-friendly toggle buttons
    local function createToggleButton(name, yPos, settingName)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -10, 0, 50)  -- Taller for mobile
        Frame.Position = UDim2.new(0, 5, 0, yPos)
        Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = ScrollFrame
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 8)
        Corner.Parent = Frame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 15, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.Gotham
        Label.TextSize = 18  -- Larger text
        Label.Parent = Frame
        
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0, 60, 0, 30)  -- Bigger toggle
        Toggle.Position = UDim2.new(1, -70, 0.5, -15)
        Toggle.BackgroundColor3 = settings[settingName] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        Toggle.Text = settings[settingName] and "ON" or "OFF"
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.Font = Enum.Font.GothamBold
        Toggle.TextSize = 16
        Toggle.Parent = Frame
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 15)
        Corner.Parent = Toggle
        
        Toggle.MouseButton1Click:Connect(function()
            settings[settingName] = not settings[settingName]
            Toggle.BackgroundColor3 = settings[settingName] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            Toggle.Text = settings[settingName] and "ON" or "OFF"
            saveSettings()
            
            -- Update features
            if settingName == "speedEnabled" then
                updateSpeed()
            elseif settingName == "antiClipEnabled" then
                if settings.antiClipEnabled then
                    antiClip()
                end
            end
        end)
        
        return Frame
    end
    
    -- Create all toggle buttons
    createToggleButton("Speed Hack", 10, "speedEnabled")
    
    -- Speed value slider (mobile-friendly)
    local SpeedFrame = Instance.new("Frame")
    SpeedFrame.Size = UDim2.new(1, -10, 0, 60)  -- Taller for mobile
    SpeedFrame.Position = UDim2.new(0, 5, 0, 70)
    SpeedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SpeedFrame.BackgroundTransparency = 0.5
    SpeedFrame.Parent = ScrollFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = SpeedFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = "Speed: "..settings.speedValue
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.Parent = SpeedFrame
    
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, -20, 0, 20)
    Slider.Position = UDim2.new(0, 10, 0, 35)
    Slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    Slider.Parent = SpeedFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 10)
    SliderCorner.Parent = Slider
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((settings.speedValue or 50)/100, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Fill.Parent = Slider
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 10)
    FillCorner.Parent = Fill
    
    -- Slider logic for mobile
    local function updateSlider(input)
        local posX = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
        settings.speedValue = math.floor(posX * 100)
        Fill.Size = UDim2.new(posX, 0, 1, 0)
        Label.Text = "Speed: "..settings.speedValue
        saveSettings()
        updateSpeed()
    end
    
    Slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
        end
    end)
    
    Slider.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
        end
    end)
    
    -- Create other toggle buttons
    createToggleButton("Infinite Jump", 140, "infJumpEnabled")
    createToggleButton("Anti-Clip", 210, "antiClipEnabled")
    createToggleButton("Anti-AFK", 280, "antiAfkEnabled")
    createToggleButton("ESP", 350, "espEnabled")
    createToggleButton("Platform", 420, "platformEnabled")
    
    -- ESP Distance slider
    local ESPFrame = Instance.new("Frame")
    ESPFrame.Size = UDim2.new(1, -10, 0, 60)
    ESPFrame.Position = UDim2.new(0, 5, 0, 490)
    ESPFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ESPFrame.BackgroundTransparency = 0.5
    ESPFrame.Parent = ScrollFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = ESPFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = "ESP Distance: "..settings.espDistance
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 16
    Label.Parent = ESPFrame
    
    local Slider = Instance.new("Frame")
    Slider.Size = UDim2.new(1, -20, 0, 20)
    Slider.Position = UDim2.new(0, 10, 0, 35)
    Slider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    Slider.Parent = ESPFrame
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 10)
    SliderCorner.Parent = Slider
    
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((settings.espDistance or 500)/1000, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Fill.Parent = Slider
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(0, 10)
    FillCorner.Parent = Fill
    
    -- Slider logic for mobile
    local function updateESPSlider(input)
        local posX = math.clamp((input.Position.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0, 1)
        settings.espDistance = math.floor(posX * 1000)
        Fill.Size = UDim2.new(posX, 0, 1, 0)
        Label.Text = "ESP Distance: "..settings.espDistance
        saveSettings()
    end
    
    Slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            updateESPSlider(input)
        end
    end)
    
    Slider.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            updateESPSlider(input)
        end
    end)
    
    return ScreenGui
end

-- Feature implementations
function updateSpeed()
    if humanoid then
        humanoid.WalkSpeed = settings.speedEnabled and settings.speedValue or 16
    end
end

function antiClip()
    if not settings.antiClipEnabled then return end
    
    local lastPosition = rootPart.Position
    RunService.Stepped:Connect(function()
        if settings.antiClipEnabled and rootPart then
            local delta = (rootPart.Position - lastPosition).Magnitude
            if delta > 10 then
                rootPart.CFrame = CFrame.new(lastPosition)
            end
            lastPosition = rootPart.Position
        end
    end)
end

function infiniteJump()
    UserInputService.JumpRequest:Connect(function()
        if settings.infJumpEnabled and humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

function antiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        if settings.antiAfkEnabled then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end

-- Initialize features
updateSpeed()
infiniteJump()
antiAFK()
if settings.antiClipEnabled then antiClip() end

-- Create the mobile GUI
local mobileGUI = createMobileGUI()

-- Character respawn handling
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    
    -- Reapply settings
    updateSpeed()
    if settings.antiClipEnabled then antiClip() end
end)
