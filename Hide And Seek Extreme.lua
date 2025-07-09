local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Sigmoslav Hub - Hide and Seek Extreme", "DarkTheme")
local TweenService = game:GetService("TweenService")

Window.Draggable = true

local function Notify(title, text, duration)
    local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        wait(1)
        playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = playerGui
    
    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(0, 300, 0, 100)
    notificationFrame.Position = UDim2.new(1, -400, 1, -150)
    notificationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    notificationFrame.BorderSizePixel = 0
    notificationFrame.Parent = screenGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = notificationFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 0, 30)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.Parent = notificationFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 0, 50)
    textLabel.Position = UDim2.new(0, 5, 0, 40)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.SourceSans
    textLabel.TextWrapped = true
    textLabel.Parent = notificationFrame
    
    local tweenIn = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -350, 1, -150)})
    tweenIn:Play()
    
    spawn(function()
        wait(duration or 5)
        local tweenOut = TweenService:Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, -400, 1, -150)})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            if screenGui and screenGui.Parent then
                screenGui:Destroy()
            end
        end)
    end)
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local isHidingBehindMap = false
local hidingBox = nil
local farmBox = nil
local coinFarmActive = false
local isMinimized = false
local chamsActive = false
local chamsHighlights = {}
local currentSeeker = nil
local lastSeeker = nil
local lastCheckTime = 0
local checkDelay = 1

local function createExtendedPlatform(position, size)
    local platform = Instance.new("Part")
    platform.Size = size
    platform.Position = position + Vector3.new(0, size.Y / 2, 0)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 0
    platform.BrickColor = BrickColor.new("Really black")
    platform.Parent = Workspace
    return platform
end

local gui = Window.Main
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftAlt then
        isMinimized = not isMinimized
        for _, child in pairs(gui:GetChildren()) do
            if child.Name ~= "TopBar" then
                child.Visible = not isMinimized
            end
        end
        Notify("Menu", isMinimized and "Menu hidden!" or "Menu shown!", 3)
    end
end)

RunService.Heartbeat:Connect(function(deltaTime)
    local currentTime = tick()
    if currentTime - lastCheckTime < checkDelay then return end
    lastCheckTime = currentTime
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local playerData = player:FindFirstChild("PlayerData")
            if playerData and playerData:FindFirstChild("It") then
                local isSeeker = playerData.It.Value
                if isSeeker and currentSeeker ~= player then
                    currentSeeker = player
                    if currentSeeker ~= lastSeeker then
                        lastSeeker = currentSeeker
                    end
                elseif not isSeeker and currentSeeker == player then
                    currentSeeker = nil
                end
            end
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if chamsActive and character and character:FindFirstChild("HumanoidRootPart") then
            local highlight = chamsHighlights[player]
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.OutlineTransparency = 0
                highlight.FillTransparency = 0.5
                local playerData = player:FindFirstChild("PlayerData")
                local isSeeker = playerData and playerData:FindFirstChild("It") and playerData.It.Value or false
                highlight.FillColor = isSeeker and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                highlight.OutlineColor = highlight.FillColor
                highlight.Parent = character
                chamsHighlights[player] = highlight
            end
        end
    end)
end)

local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Utility Functions")

MiscSection:NewButton("Inject Infinite Yield", "Loads Infinite Yield admin commands", function()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        Notify("Infinite Yield", "Infinite Yield injected successfully!", 5)
    end)
end)

MiscSection:NewToggle("Player Chams", "Red for seeker, green for hiders", function(state)
    chamsActive = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local highlight = chamsHighlights[player]
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.OutlineTransparency = 0
                    highlight.FillTransparency = 0.5
                    local playerData = player:FindFirstChild("PlayerData")
                    local isSeeker = playerData and playerData:FindFirstChild("It") and playerData.It.Value or false
                    highlight.FillColor = isSeeker and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                    highlight.OutlineColor = highlight.FillColor
                    highlight.Parent = player.Character
                    chamsHighlights[player] = highlight
                end
            end
        end
        Notify("Chams", "Chams turned on!", 2)
    else
        for player, highlight in pairs(chamsHighlights) do
            if highlight then
                highlight:Destroy()
            end
        end
        chamsHighlights = {}
        Notify("Chams", "Chams turned off!", 2)
    end
end, {Color = Color3.fromRGB(255, 0, 0), ActiveColor = Color3.fromRGB(0, 255, 0)})

MiscSection:NewButton("Copy Discord Link", "Copies our Discord invite link", function()
    local success = false
    if setclipboard then
        success, err = pcall(function()
            setclipboard("https://discord.gg/3AZtEsfFsq")
        end)
    end
    if success then
        Notify("Discord", "Discord link copied to clipboard!", 5)
    else
        Notify("Discord", "Failed to copy link! Clipboard not supported or error: " .. (err or "unknown"), 5)
    end
end)

local SeekerTab = Window:NewTab("Seeker")
local SeekerSection = SeekerTab:NewSection("Seeker Tools")

SeekerSection:NewButton("Teleport to Players", "Teleports to each player in order", function()
    local teleported = false
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
            Notify("Teleport", "Teleported to " .. player.Name, 2)
            teleported = true
            wait(0.5)
        end
    end
    Notify("Teleport", teleported and "Finished teleporting!" or "No players to teleport to!", 5)
end)

local HiderTab = Window:NewTab("Hider")
local HiderSection = HiderTab:NewSection("Hider Tools")

HiderSection:NewButton("Teleport Behind Map", "Teleports to the platform above", function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Notify("Hider", "Waiting for character to load...", 5)
        wait(2)
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        isHidingBehindMap = true
        local platformPos = CFrame.new(1000, 90, 1000)
        LocalPlayer.Character.HumanoidRootPart.CFrame = platformPos
        if not hidingBox then
            hidingBox = createExtendedPlatform(platformPos.Position - Vector3.new(0, 10, 0), Vector3.new(100, 10, 100))
        end
        Notify("Hider", "Teleported to platform above!", 5)
    else
        Notify("Hider", "Failed to teleport: character not found!", 5)
    end
end)

HiderSection:NewButton("Return to Map", "Teleports back to the map", function()
    if isHidingBehindMap then
        isHidingBehindMap = false
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
            Notify("Hider", "Returned to map!", 5)
        else
            Notify("Hider", "Failed to return: character not found!", 5)
        end
    else
        Notify("Hider", "Not behind the map!", 5)
    end
end)

local FarmTab = Window:NewTab("Farm")
local FarmSection = FarmTab:NewSection("Farming Tools")

FarmSection:NewButton("Collect all the coins", "Collects all coins on the map once", function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Notify("Coin Collection", "Waiting for character to load...", 5)
        wait(2)
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local creditsFound = false
        local hasCredits = false
        local currentTime = tick()
        for _, credit in pairs(Workspace:GetDescendants()) do
            if credit:IsA("BasePart") and credit.Name:lower():find("credit") then
                hasCredits = true
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(credit.Position)
                creditsFound = true
                wait(0.1)
            end
        end
        if not hasCredits and currentTime - lastCheckTime >= 5 then
            Notify("Coin Collection", "No Credit found on map!", 5)
            lastCheckTime = currentTime
        elseif creditsFound and currentTime - lastCheckTime >= 5 then
            Notify("Coin Collection", "All coins collected!", 5)
            lastCheckTime = currentTime
        end
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0)
    else
        Notify("Coin Collection", "Failed: character not found!", 5)
    end
end)

Notify("Sigmoslav Hub", "Script loaded successfully! Enjoy Hide and Seek Extreme.", 5)