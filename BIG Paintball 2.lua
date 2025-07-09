local SessionID = string.gsub(tostring(math.random()):sub(3), "%d", function(c)
    return string.char(96 + math.random(1, 26))
end)
print('✅ | Running Sigmoslav Hub for BigPaintball2 made by Sigmoslav with [SessionID ' .. SessionID .. ']')

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Sigmoslav Hub", "DarkTheme")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local Enabled = false

local function safeExecute(func)
    local success, errorMessage = pcall(func)
    if not success then
        warn('⛔ | Error occurred: ' .. errorMessage .. ' [SessionID ' .. SessionID .. ']')
    end
end

local function teleportEntities(cframe, team)
    local spawnPosition = cframe * CFrame.new(0, 0, -15)

    for _, entity in ipairs(Workspace.__THINGS.__ENTITIES:GetChildren()) do
        if entity:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart = entity.HumanoidRootPart
            humanoidRootPart.CanCollide = false
            humanoidRootPart.Anchored = true
            humanoidRootPart.CFrame = spawnPosition
        elseif entity:FindFirstChild("Hitbox") then
            local directory = entity:GetAttribute("Directory")
            if not (directory == "White" and entity:GetAttribute("OwnerUID") == LocalPlayer.UserId) and 
               (not team or directory ~= team.Name) then
                entity.Hitbox.CanCollide = false
                entity.Hitbox.Anchored = true
                entity.Hitbox.CFrame = spawnPosition * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not team or team.Name ~= player.Team.Name then
                if not player.Character:FindFirstChild("ForceField") then
                    local humanoidRootPart = player.Character.HumanoidRootPart
                    humanoidRootPart.CanCollide = false
                    humanoidRootPart.Anchored = true
                    humanoidRootPart.CFrame = spawnPosition * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
                end
            end
        end
    end
end

local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Features")

MainSection:NewToggle("Teleport Entities", "Teleport enemies and players to a fixed position", function(state)
    Enabled = state
    if Enabled then
        print('✅ | Enabled Sigmoslav Hub for BigPaintball2 [SessionID ' .. SessionID .. ']')
    else
        print('❌ | Disabled Sigmoslav Hub for BigPaintball2 [SessionID ' .. SessionID .. ']')
    end
end, {Color = Color3.fromRGB(0, 255, 0), ActiveColor = Color3.fromRGB(0, 255, 0)})

while wait(0.1) do
    safeExecute(function()
        if not Enabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local cframe = LocalPlayer.Character.HumanoidRootPart.CFrame
        local team = LocalPlayer.Team
        teleportEntities(cframe, team)
    end)
end