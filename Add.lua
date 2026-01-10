-- ================== HUB ANTI-LAG FINAL ==================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- HUB GUI
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "MasterHub"

local Hub = Instance.new("Frame", ScreenGui)
Hub.Size = UDim2.new(0,220,0,130)
Hub.Position = UDim2.new(0.75,0,0.1,0)
Hub.BackgroundColor3 = Color3.fromRGB(40,40,40)
Hub.BackgroundTransparency = 0.4
Hub.Active = true
Hub.Draggable = true

-- +FPS BUTTON
local FPSButton = Instance.new("TextButton", Hub)
FPSButton.Size = UDim2.new(0,200,0,50)
FPSButton.Position = UDim2.new(0,10,0,10)
FPSButton.Text = "+FPS"
FPSButton.Font = Enum.Font.SourceSansBold
FPSButton.TextScaled = true
FPSButton.TextColor3 = Color3.new(1,1,1)
FPSButton.BackgroundColor3 = Color3.fromRGB(255,0,0)

-- FPS DISPLAY
local FPSLabel = Instance.new("TextLabel", ScreenGui)
FPSLabel.AnchorPoint = Vector2.new(1,1)
FPSLabel.Position = UDim2.new(1,-10,1,-10)
FPSLabel.Size = UDim2.new(0,140,0,35)
FPSLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
FPSLabel.BackgroundTransparency = 0.3
FPSLabel.TextColor3 = Color3.new(1,1,1)
FPSLabel.Font = Enum.Font.SourceSansBold
FPSLabel.TextScaled = true
FPSLabel.Text = "FPS: 0"

-- ================== FPS SYSTEM ==================
local fpsCount,lastTick = 0,tick()
RunService.RenderStepped:Connect(function()
    fpsCount += 1
    if tick() - lastTick >= 1 then
        FPSLabel.Text = "FPS: "..fpsCount
        fpsCount = 0
        lastTick = tick()
        if Camera.ViewportSize.X < 1000 then
            FPSLabel.TextSize = 14
        else
            FPSLabel.TextSize = 20
        end
    end
end)

-- ================== ANTI-LAG ==================
local AntiLagActive = false
local AntiLagCons = {}

local function isOnScreen(part)
    local _, visible = Camera:WorldToViewportPoint(part.Position)
    return visible
end

local function disableEffects(obj)
    for _,v in pairs(obj:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
            v.Enabled = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("AnimationController") then
            v:Destroy()
        elseif v:IsA("Humanoid") and v.Parent ~= LocalPlayer.Character then
            v:Destroy()
        elseif v:IsA("Part") and v.Parent ~= LocalPlayer.Character then
            -- Remove cubos desnecessários nos players
            if v.Size.Magnitude <= 5 then
                v:Destroy()
            end
        end
    end
end

local function renderControl()
    for _,plr in pairs(Players:GetPlayers()) do
        if plr.Character then
            for _,part in pairs(plr.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if plr ~= LocalPlayer and not isOnScreen(part) then
                        part.Transparency = 1
                        part.CanCollide = false
                    else
                        part.Transparency = 0
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end

local function toggleFPS()
    AntiLagActive = not AntiLagActive
    if AntiLagActive then
        FPSButton.BackgroundColor3 = Color3.fromRGB(0,255,0)
        disableEffects(Workspace)
        table.insert(AntiLagCons, Workspace.DescendantAdded:Connect(disableEffects))
        table.insert(AntiLagCons, RunService.RenderStepped:Connect(renderControl))
    else
        FPSButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
        for _,c in pairs(AntiLagCons) do c:Disconnect() end
        AntiLagCons = {}
        for _,plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                for _,part in pairs(plr.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                        part.CanCollide = true
                    end
                end
            end
        end
    end
end

FPSButton.MouseButton1Click:Connect(toggleFPS)
