--[[ 
HUB FPS + ANTI-HACKS DEFINITIVO
Autor: você
Tipo: LocalScript
]]

-- ================== SERVICES ==================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ================== GUI ==================
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "MasterHub"

local Hub = Instance.new("Frame", ScreenGui)
Hub.Size = UDim2.new(0, 220, 0, 170)
Hub.Position = UDim2.new(0.75, 0, 0.1, 0)
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

-- ANTI-HACK BUTTON
local AntiHackButton = Instance.new("TextButton", Hub)
AntiHackButton.Size = UDim2.new(0,200,0,50)
AntiHackButton.Position = UDim2.new(0,10,0,70)
AntiHackButton.Text = "ANTI-HACKS"
AntiHackButton.Font = Enum.Font.SourceSansBold
AntiHackButton.TextScaled = true
AntiHackButton.TextColor3 = Color3.new(1,1,1)
AntiHackButton.BackgroundColor3 = Color3.fromRGB(255,0,0)

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
local fpsCount, lastTick = 0, tick()

RunService.RenderStepped:Connect(function()
    fpsCount += 1
    if tick() - lastTick >= 1 then
        FPSLabel.Text = "FPS: "..fpsCount
        fpsCount = 0
        lastTick = tick()

        -- Ajuste PC / Mobile
        if Camera.ViewportSize.X < 1000 then
            FPSLabel.TextSize = 14
        else
            FPSLabel.TextSize = 20
        end
    end
end)

-- ================== +FPS (ANTI-LAG) ==================
local AntiLag = false
local AntiLagCons = {}

local function isOnScreen(part)
    local _, visible = Camera:WorldToViewportPoint(part.Position)
    return visible
end

local function disableEffects(obj)
    for _,v in pairs(obj:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail")
        or v:IsA("Smoke") or v:IsA("Fire") then
            v.Enabled = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("AnimationController") then
            v:Destroy()
        elseif v:IsA("Humanoid") and v.Parent ~= LocalPlayer.Character then
            v:Destroy()
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
    AntiLag = not AntiLag

    if AntiLag then
        FPSButton.BackgroundColor3 = Color3.fromRGB(0,255,0)
        Lighting.GlobalShadows = false
        disableEffects(Workspace)

        table.insert(AntiLagCons,
            Workspace.DescendantAdded:Connect(disableEffects)
        )
        table.insert(AntiLagCons,
            RunService.RenderStepped:Connect(renderControl)
        )
    else
        FPSButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
        Lighting.GlobalShadows = true
        for _,c in pairs(AntiLagCons) do c:Disconnect() end
        AntiLagCons = {}

        for _,plr in pairs(Players:GetPlayers()) do
            if plr.Character then
                for _,p in pairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") then
                        p.Transparency = 0
                        p.CanCollide = true
                    end
                end
            end
        end
    end
end

FPSButton.MouseButton1Click:Connect(toggleFPS)

-- ================== ANTI-HACKS ==================
local AntiHack = false
local AntiHackCons = {}

local function getChar()
    return LocalPlayer.Character
end

local function antiFling()
    local char = getChar()
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    hum.Sit = false
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero

    hrp.CustomPhysicalProperties = PhysicalProperties.new(100,0,0,0,0)
end

local function blockSeats()
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Seat") or v:IsA("VehicleSeat") then
            v.Disabled = true
        end
    end
end

local function restoreSeats()
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Seat") or v:IsA("VehicleSeat") then
            v.Disabled = false
        end
    end
end

local function toggleAntiHack()
    AntiHack = not AntiHack

    if AntiHack then
        AntiHackButton.BackgroundColor3 = Color3.fromRGB(0,255,0)
        blockSeats()

        table.insert(AntiHackCons,
            RunService.Stepped:Connect(antiFling)
        )
    else
        AntiHackButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
        for _,c in pairs(AntiHackCons) do c:Disconnect() end
        AntiHackCons = {}
        restoreSeats()

        local char = getChar()
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CustomPhysicalProperties = nil
        end
    end
end

AntiHackButton.MouseButton1Click:Connect(toggleAntiHack)
