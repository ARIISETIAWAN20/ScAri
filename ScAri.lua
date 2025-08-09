--[[
ARI HUB v2.0 Obfuscated
Features:
- Speed, Inf Jump, ESP, Anti-Clip, Anti-AFK
- Settings persist across sessions
]]

local _G = getgenv()
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Run = game:GetService("RunService")
local WS = game:GetService("Workspace")
local VIM = game:GetService("VirtualInputManager")
local plr = Players.LocalPlayer

-- Config handling
local configFile = "ARI_CONFIG.json"
local function getConfig()
    if isfile(configFile) then
        return Http:JSONDecode(readfile(configFile))
    end
    return {
        speed = 16,
        jump = 50,
        esp = false,
        noClip = false,
        antiAFK = true
    }
end

local function saveConfig(cfg)
    writefile(configFile, Http:JSONEncode(cfg))
end

local cfg = getConfig()

-- Module variables
local speedActive = false
local jumpActive = false
local espActive = cfg.esp
local clipActive = cfg.noClip
local afkActive = cfg.antiAFK
local UIS = game:GetService("UserInputService")
local espElements = {}
local lastPos = Vector3.new(0, 0, 0)
local lastMove = os.time()

-- Jump handler
UIS.JumpRequest:Connect(function()
    if jumpActive then
        local char = plr.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            hum.UseJumpPower = true
            hum.JumpPower = tonumber(cfg.jump) or 50
            hum:ChangeState("Jumping")
        end
    end
end)

-- Anti-AFK system
local function preventAFK()
    if not afkActive then return end
    
    if os.time() - lastMove > 20 then
        VIM:SendKeyEvent(true, Enum.KeyCode.W, false, nil)
        task.wait(0.1)
        VIM:SendKeyEvent(false, Enum.KeyCode.W, false, nil)
        lastMove = os.time()
    end
end

-- Movement tracking
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        lastMove = os.time()
    end
end)

-- Anti-clip system
local function setupClipProtection(char)
    if not char then return end
    
    local root = char:WaitForChild("HumanoidRootPart")
    local lastValid = root.Position
    
    Run.Stepped:Connect(function()
        if not clipActive or not char or not root then return end
        
        local current = root.Position
        if (current - lastValid).Magnitude > 10 then
            root.CFrame = CFrame.new(lastValid)
        else
            lastValid = current
        end
    end)
end

-- ESP system
local function createESP(target)
    if not espActive or target == plr then return end
    
    local char = target.Character or target.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    
    -- Create ESP elements
    local gui = Instance.new("BillboardGui")
    gui.Name = target.Name .. "_ESP"
    gui.AlwaysOnTop = true
    gui.Size = UDim2.new(0, 200, 0, 50)
    gui.StudsOffset = Vector3.new(0, 2, 0)
    gui.Adornee = root
    gui.Parent = char
    
    local nameTag = Instance.new("TextLabel")
    nameTag.Size = UDim2.new(1, 0, 0.5, 0)
    nameTag.BackgroundTransparency = 1
    nameTag.Text = target.Name
    nameTag.TextColor3 = Color3.new(1, 1, 1)
    nameTag.TextScaled = true
    nameTag.Font = Enum.Font.GothamBold
    nameTag.Parent = gui
    
    local distTag = Instance.new("TextLabel")
    distTag.Size = UDim2.new(1, 0, 0.5, 0)
    distTag.Position = UDim2.new(0, 0, 0.5, 0)
    distTag.BackgroundTransparency = 1
    distTag.TextColor3 = Color3.new(1, 1, 1)
    distTag.TextScaled = true
    distTag.Font = Enum.Font.Gotham
    distTag.Parent = gui
    
    espElements[target] = {gui = gui, name = nameTag, dist = distTag}
    
    -- Update distance
    Run.Heartbeat:Connect(function()
        if not espActive or not char or not root or not plr.Character then return end
        
        local localRoot = plr.Character:FindFirstChild("HumanoidRootPart")
        if localRoot then
            local distance = (root.Position - localRoot.Position).Magnitude
            distTag.Text = string.format("%.1f studs", distance)
        end
    end)
end

local function clearESP()
    for _, data in pairs(espElements) do
        if data.gui then data.gui:Destroy() end
    end
    espElements = {}
end

local function toggleESP(state)
    espActive = state
    cfg.esp = state
    saveConfig(cfg)
    
    if state then
        clearESP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr then createESP(p) end
        end
        Players.PlayerAdded:Connect(createESP)
    else
        clearESP()
    end
end

-- Initialize ESP
if espActive then toggleESP(true) end

-- Create interface
local ui = Instance.new("ScreenGui")
ui.ResetOnSpawn = false
ui.IgnoreGuiInset = true
ui.Parent = plr:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 250, 0, 340)
main.Position = UDim2.new(0.5, -125, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = ui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Title bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 30)
title.BackgroundTransparency = 1
title.Text = "ARI HUB v2.0"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = main

-- Control buttons
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -60, 0, 0)
minBtn.Text = "-"
minBtn.TextScaled = true
minBtn.Font = Enum.Font.GothamBold
minBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Parent = main
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)
minBtn.ZIndex = 2

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Text = "X"
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Parent = main
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.ZIndex = 2

-- Feature controls
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(1, -20, 0, 40)
speedBtn.Position = UDim2.new(0, 10, 0, 40)
speedBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.Text = "Speed: OFF"
speedBtn.TextScaled = true
speedBtn.Font = Enum.Font.GothamBold
speedBtn.Parent = main
Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 8)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 85)
speedBox.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Text = tostring(cfg.speed)
speedBox.TextScaled = true
speedBox.Font = Enum.Font.GothamBold
speedBox.Parent = main
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(1, -20, 0, 40)
jumpBtn.Position = UDim2.new(0, 10, 0, 125)
jumpBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.Text = "Inf Jump: OFF"
jumpBtn.TextScaled = true
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.Parent = main
Instance.new("UICorner", jumpBtn).CornerRadius = UDim.new(0, 8)

local jumpBox = Instance.new("TextBox")
jumpBox.Size = UDim2.new(1, -20, 0, 30)
jumpBox.Position = UDim2.new(0, 10, 0, 170)
jumpBox.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
jumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBox.Text = tostring(cfg.jump)
jumpBox.TextScaled = true
jumpBox.Font = Enum.Font.GothamBold
jumpBox.Parent = main
Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 8)

local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(1, -20, 0, 40)
espBtn.Position = UDim2.new(0, 10, 0, 210)
espBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.Text = "ESP: " .. (espActive and "ON" or "OFF")
espBtn.TextScaled = true
espBtn.Font = Enum.Font.GothamBold
espBtn.Parent = main
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0, 8)

local clipBtn = Instance.new("TextButton")
clipBtn.Size = UDim2.new(1, -20, 0, 40)
clipBtn.Position = UDim2.new(0, 10, 0, 255)
clipBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
clipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clipBtn.Text = "Anti-Clip: " .. (clipActive and "ON" or "OFF")
clipBtn.TextScaled = true
clipBtn.Font = Enum.Font.GothamBold
clipBtn.Parent = main
Instance.new("UICorner", clipBtn).CornerRadius = UDim.new(0, 8)

local afkBtn = Instance.new("TextButton")
afkBtn.Size = UDim2.new(1, -20, 0, 40)
afkBtn.Position = UDim2.new(0, 10, 0, 300)
afkBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
afkBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
afkBtn.Text = "Anti-AFK: " .. (afkActive and "ON" or "OFF")
afkBtn.TextScaled = true
afkBtn.Font = Enum.Font.GothamBold
afkBtn.Parent = main
Instance.new("UICorner", afkBtn).CornerRadius = UDim.new(0, 8)

-- Control logic
speedBtn.MouseButton1Click:Connect(function()
    local char = plr.Character or plr.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    speedActive = not speedActive
    if speedActive then
        hum.WalkSpeed = tonumber(cfg.speed) or 16
        speedBtn.Text = "Speed: ON"
    else
        hum.WalkSpeed = 16
        speedBtn.Text = "Speed: OFF"
    end
end)

speedBox.FocusLost:Connect(function()
    local val = tonumber(speedBox.Text)
    if val and val >= 16 and val <= 100000 then
        cfg.speed = val
        saveConfig(cfg)
        if speedActive then
            local char = plr.Character or plr.CharacterAdded:Wait()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    else
        speedBox.Text = tostring(cfg.speed)
    end
end)

jumpBtn.MouseButton1Click:Connect(function()
    jumpActive = not jumpActive
    jumpBtn.Text = jumpActive and "Inf Jump: ON" or "Inf Jump: OFF"
end)

jumpBox.FocusLost:Connect(function()
    local val = tonumber(jumpBox.Text)
    if val and val >= 50 and val <= 1000 then
        cfg.jump = val
        saveConfig(cfg)
    else
        jumpBox.Text = tostring(cfg.jump)
    end
end)

espBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    espBtn.Text = "ESP: " .. (espActive and "ON" or "OFF")
    toggleESP(espActive)
end)

clipBtn.MouseButton1Click:Connect(function()
    clipActive = not clipActive
    cfg.noClip = clipActive
    saveConfig(cfg)
    clipBtn.Text = "Anti-Clip: " .. (clipActive and "ON" or "OFF")
    
    if clipActive and plr.Character then
        setupClipProtection(plr.Character)
    end
end)

afkBtn.MouseButton1Click:Connect(function()
    afkActive = not afkActive
    cfg.antiAFK = afkActive
    saveConfig(cfg)
    afkBtn.Text = "Anti-AFK: " .. (afkActive and "ON" or "OFF")
end)

-- UI controls
local minimized = false
local uiElements = {speedBtn, speedBox, jumpBtn, jumpBox, espBtn, clipBtn, afkBtn}

minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    for _, el in ipairs(uiElements) do
        el.Visible = not minimized
    end
    main.Size = minimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 340)
    minBtn.Text = minimized and "+" or "-"
end)

closeBtn.MouseButton1Click:Connect(function()
    ui:Destroy()
end)

-- Respawn handler
plr.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    if speedActive then
        hum.WalkSpeed = tonumber(cfg.speed) or 16
    else
        hum.WalkSpeed = 16
    end
    
    if clipActive then
        setupClipProtection(char)
    end
end)

-- AFK prevention loop
while true do
    preventAFK()
    task.wait(1)
end
