-- ARI HUB Key System with lifetime key support (HELLO ARI)
-- Keys: HELLO ARI (lifetime), HELLO WORLD, HELLO BRO (11-hour cache)

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local keyFile = "KEY ARI HUB.json"
local savedData = nil

if isfile(keyFile) then
    local data = readfile(keyFile)
    pcall(function()
        savedData = HttpService:JSONDecode(data)
    end)
end

local function hasValidSession()
    if savedData and savedData.key and savedData.lastUsed then
        if savedData.key == "HELLO ARI" then
            return true -- Lifetime key
        end
        local elapsed = os.time() - savedData.lastUsed
        return elapsed <= (11 * 3600)
    elseif savedData and savedData.key == "HELLO ARI" then
        return true
    end
    return false
end

local function loadMainScript()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/ARIISETIAWAN20/ScAri/main/ScAri.lua"))()
    end)
    if not success then
        warn("Failed to load main script:", err)
    end
end

local function createKeyGui()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 300, 0, 150)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
    Frame.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
    Frame.Parent = ScreenGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "ARI HUB - Key System"
    Title.Font = Enum.Font.GothamBold
    Title.TextScaled = true
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Parent = Frame

    local KeyBox = Instance.new("TextBox")
    KeyBox.Size = UDim2.new(1, -20, 0, 40)
    KeyBox.Position = UDim2.new(0, 10, 0, 50)
    KeyBox.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
    KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyBox.TextScaled = true
    KeyBox.Font = Enum.Font.GothamBold
    KeyBox.PlaceholderText = "Enter Key"
    KeyBox.Parent = Frame
    Instance.new("UICorner", KeyBox).CornerRadius = UDim.new(0, 8)

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, 0, 0, 20)
    Status.Position = UDim2.new(0, 0, 1, -25)
    Status.BackgroundTransparency = 1
    Status.Text = ""
    Status.Font = Enum.Font.Gotham
    Status.TextScaled = true
    Status.TextColor3 = Color3.fromRGB(255, 100, 100)
    Status.Parent = Frame

    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Size = UDim2.new(1, -20, 0, 40)
    SubmitBtn.Position = UDim2.new(0, 10, 0, 100)
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 180)
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.Text = "Submit"
    SubmitBtn.TextScaled = true
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.Parent = Frame
    Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 8)

    local validKeys = {
        ["HELLO ARI"] = true,
        ["HELLO WORLD"] = true,
        ["HELLO BRO"] = true
    }

    local function validateKey(inputKey)
        return validKeys[inputKey] == true
    end

    SubmitBtn.MouseButton1Click:Connect(function()
        local inputKey = KeyBox.Text
        if inputKey == "" then
            Status.Text = "Please enter a key."
            return
        end

        if validateKey(inputKey) then
            local saveData = { key = inputKey }
            if inputKey ~= "HELLO ARI" then
                saveData.lastUsed = os.time()
            end
            writefile(keyFile, HttpService:JSONEncode(saveData))
            Status.TextColor3 = Color3.fromRGB(100, 255, 100)
            Status.Text = "Access Granted!"
            wait(0.5)
            ScreenGui:Destroy()
            loadMainScript()
        else
            Status.TextColor3 = Color3.fromRGB(255, 100, 100)
            Status.Text = "Invalid Key!"
        end
    end)
end

if hasValidSession() then
    loadMainScript()
else
    createKeyGui()
end
