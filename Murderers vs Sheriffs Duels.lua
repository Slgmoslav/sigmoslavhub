local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Sigmoslav Hub", "DarkTheme")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

Window.Draggable = true

local function Notify(title, text, duration)
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        wait(1)
        playerGui = LocalPlayer:FindFirstChild("PlayerGui")
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

local chamsActive = false
local hitboxesActive = false
local speedBoostActive = false
local chamsHighlights = {}
local hitboxCubes = {}
local frameCounter = 0
local CHECK_INTERVAL = 5 -- Check every 5 frames

local function createHighlight(player)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") and not chamsHighlights[player] then
        local highlight = Instance.new("Highlight")
        highlight.OutlineTransparency = 0
        highlight.FillTransparency = 0.7
        highlight.FillColor = Color3.fromRGB(0, 255, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
        highlight.Parent = character
        chamsHighlights[player] = highlight
    end
end

local function createEsp(player)
    spawn(function()
        while wait(0.5) do
            if chamsActive and player.Character and player.Character:FindFirstChild("Humanoid") and player ~= LocalPlayer and not player.Character:FindFirstChild("EspBox") then
                local esp = Instance.new("BoxHandleAdornment", player.Character)
                esp.Adornee = player.Character
                esp.ZIndex = 0
                esp.Size = Vector3.new(5, 6, 2)
                esp.Transparency = 0.5
                esp.Color3 = Color3.fromRGB(0, 255, 0)
                esp.AlwaysOnTop = true
                esp.Name = "EspBox"
            end
        end
    end)
end

local function createHitbox(player)
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") and not hitboxCubes[player] then
        local humanoidRootPart = character.HumanoidRootPart
        local hitboxCube = Instance.new("Part")
        hitboxCube.Size = Vector3.new(20, 20, 10) -- 10x scale (20x20x10 based on 2x2x1 root part)
        hitboxCube.Position = humanoidRootPart.Position
        hitboxCube.Anchored = true
        hitboxCube.CanCollide = false
        hitboxCube.Transparency = 0.5
        hitboxCube.BrickColor = BrickColor.new("Bright red")
        hitboxCube.Parent = Workspace
        hitboxCubes[player] = hitboxCube
        
        RunService.RenderStepped:Connect(function()
            if hitboxCubes[player] and humanoidRootPart then
                hitboxCube.Position = humanoidRootPart.Position
                if hitboxCube.Size ~= Vector3.new(20, 20, 10) then
                    hitboxCube.Size = Vector3.new(20, 20, 10)
                end
            end
        end)
    end
end

local function removeHitbox(player)
    if hitboxCubes[player] then
        hitboxCubes[player]:Destroy()
        hitboxCubes[player] = nil
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            character.HumanoidRootPart.Transparency = 0
            character.HumanoidRootPart.CanCollide = true
        end
    end
end

-- Global enforcement loops with optimization
RunService.RenderStepped:Connect(function()
    frameCounter = (frameCounter + 1) % CHECK_INTERVAL
    if frameCounter == 0 then
        if hitboxesActive then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        local humanoidRootPart = character.HumanoidRootPart
                        pcall(function()
                            humanoidRootPart.Size = Vector3.new(20, 20, 10) -- 10x scale
                            humanoidRootPart.Transparency = 0.7
                            humanoidRootPart.CanCollide = false
                            if not hitboxCubes[player] then
                                createHitbox(player)
                            end
                        end)
                    end
                end
            end
        end
        if speedBoostActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            if humanoid.WalkSpeed ~= 35 then
                humanoid.WalkSpeed = 35
            end
        elseif not speedBoostActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            if humanoid.WalkSpeed ~= 16 then
                humanoid.WalkSpeed = 16
            end
        end
        if chamsActive then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        if not chamsHighlights[player] then
                            createHighlight(player)
                        end
                        if character:FindFirstChild("Humanoid") and not character:FindFirstChild("EspBox") then
                            createEsp(player)
                        end
                    end
                end
            end
        end
    end
end)

local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Functions")

MiscSection:NewToggle("Chams", "Green chams for all players, persist after death", function(state)
    chamsActive = state
    if state then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    createHighlight(player)
                end
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    createEsp(player)
                end
                player.CharacterAdded:Connect(function(character)
                    if chamsActive and character and character:FindFirstChild("HumanoidRootPart") then
                        createHighlight(player)
                    end
                    if chamsActive and character and character:FindFirstChild("Humanoid") then
                        createEsp(player)
                    end
                end)
            end
        end
        Notify("Chams", "Chams enabled!", 2)
    else
        for player, highlight in pairs(chamsHighlights) do
            if highlight then
                highlight:Destroy()
            end
        end
        chamsHighlights = {}
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("EspBox") then
                player.Character.EspBox:Destroy()
            end
        end
        Notify("Chams", "Chams disabled!", 2)
    end
end, {Color = Color3.fromRGB(0, 255, 0), ActiveColor = Color3.fromRGB(0, 255, 0)})

MiscSection:NewToggle("Hitboxes", "Increases hitboxes by 10x and marks with red cube", function(state)
    hitboxesActive = state
    if state then
        _G.HeadSize = 20 -- 10x scale (20x20x10 based on 2x2x1 root part)
        _G.Disabled = true
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                createHitbox(player)
            end
            player.CharacterAdded:Connect(function(character)
                if hitboxesActive and character and character:FindFirstChild("HumanoidRootPart") then
                    createHitbox(player)
                end
            end)
        end
        Notify("Hitboxes", "Hitboxes enabled!", 2)
    else
        for player, _ in pairs(hitboxCubes) do
            removeHitbox(player)
        end
        Notify("Hitboxes", "Hitboxes disabled!", 2)
    end
end, {Color = Color3.fromRGB(255, 0, 0), ActiveColor = Color3.fromRGB(255, 0, 0)})

MiscSection:NewToggle("Speed Boost", "Sets speed to 35 when enabled", function(state)
    speedBoostActive = state
    Notify("Speed", "Speed set to " .. (state and 35 or 16), 2)
end, {Color = Color3.fromRGB(0, 0, 255), ActiveColor = Color3.fromRGB(0, 0, 255)})

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            if chamsActive and character and character:FindFirstChild("HumanoidRootPart") then
                createHighlight(player)
            end
            if chamsActive and character and character:FindFirstChild("Humanoid") then
                createEsp(player)
            end
            if hitboxesActive and character and character:FindFirstChild("HumanoidRootPart") then
                createHitbox(player)
            end
        end)
        player.CharacterRemoving:Connect(function()
            if chamsHighlights[player] then
                chamsHighlights[player] = nil
            end
            if hitboxCubes[player] then
                removeHitbox(player)
            end
            if player.Character and player.Character:FindFirstChild("EspBox") then
                player.Character.EspBox:Destroy()
            end
        end)
    end
end)

Notify("Sigmoslav Hub", "Script loaded successfully! Enjoy the game.", 5)