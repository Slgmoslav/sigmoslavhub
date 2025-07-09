local supportedGames = {
    [12355337193] = "Murderers vs Sheriffs Duels",
    [205224386] = "Hide And Seek Extreme"
}

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
    
    local tweenIn = game:GetService("TweenService"):Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -350, 1, -150)})
    tweenIn:Play()
    
    spawn(function()
        wait(duration or 5)
        local tweenOut = game:GetService("TweenService"):Create(notificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, -400, 1, -150)})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            if screenGui and screenGui.Parent then
                screenGui:Destroy()
            end
        end)
    end)
end

local gameId = game.PlaceId
if gameId == 12355337193 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Slgmoslav/sigmoslavhub/refs/heads/main/Murderers%20vs%20Sheriffs%20Duels.lua"))()
    Notify("Sigmoslav Hub", "Script loaded for Murderers vs Sheriffs Duels!", 5)
elseif gameId == 205224386 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Slgmoslav/sigmoslavhub/refs/heads/main/Hide%20And%20Seek%20Extreme.lua"))()
    Notify("Sigmoslav Hub", "Script loaded for Hide And Seek Extreme!", 5)
else
    Notify("Unsupported Game", "This script is not supported in this game.", 5)
end