--==================================================
-- GIVE TOOLS OP  |  HUB AVANÇADO
--==================================================

--// SERVIÇOS
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

--// CONFIG
local COLOR_SPEED = 12 -- quanto maior, mais rápido o efeito OP
local MAX_BUTTON_HEIGHT = 48

--// VAR
local enabled = false
local dragging = false
local dragStart, startPos
local toolCache = {}

--==================================================
-- GUI BASE
--==================================================
local gui = Instance.new("ScreenGui")
gui.Name = "GiveToolsOP"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local hub = Instance.new("Frame")
hub.Size = UDim2.fromScale(0.65, 0.65)
hub.Position = UDim2.fromScale(0.175, 0.175)
hub.BackgroundColor3 = Color3.fromRGB(70,70,70)
hub.BorderSizePixel = 0
hub.Active = true
hub.Parent = gui

--==================================================
-- TITLE BAR
--==================================================
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0.12,0)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.Text = "GIVE TOOLS OP"
title.TextColor3 = Color3.new(1,1,1)
title.Parent = hub

-- EFEITO OP COLORIDO RÁPIDO
RunService.RenderStepped:Connect(function()
    local t = tick() * COLOR_SPEED
    title.TextColor3 = Color3.fromHSV((t % 1), 1, 1)
end)

--==================================================
-- DRAG (MOBILE + PC)
--==================================================
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = hub.Position
    end
end)

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        hub.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- BOTÃO ON/OFF
--==================================================
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0.9,0,0.09,0)
toggle.Position = UDim2.new(0.05,0,0.14,0)
toggle.TextScaled = true
toggle.Font = Enum.Font.GothamBold
toggle.Text = "STATUS: OFF"
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(150,0,0)
toggle.Parent = hub

toggle.MouseButton1Click:Connect(function()
    enabled = not enabled
    if enabled then
        toggle.Text = "STATUS: ON"
        toggle.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        toggle.Text = "STATUS: OFF"
        toggle.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
end)

--==================================================
-- SCROLL FRAME INTELIGENTE
--==================================================
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(0.9,0,0.7,0)
scroll.Position = UDim2.new(0.05,0,0.25,0)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarImageTransparency = 0
scroll.BackgroundColor3 = Color3.fromRGB(35,35,35)
scroll.BorderSizePixel = 0
scroll.Parent = hub

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0,8)

-- AJUSTE AUTOMÁTICO QUANDO TEM MUITA TOOL
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20)
end)

--==================================================
-- BUSCA TOTAL DE TOOLS
--==================================================
local SEARCH = {
    workspace,
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerStorage"),
}

local function scanTools()
    table.clear(toolCache)

    for _, place in ipairs(SEARCH) do
        for _, obj in ipairs(place:GetDescendants()) do
            if obj:IsA("Tool") and not toolCache[obj.Name] then
                toolCache[obj.Name] = obj
            end
        end
    end
end

--==================================================
-- LIMPAR LISTA
--==================================================
local function clearList()
    for _, v in ipairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then
            v:Destroy()
        end
    end
end

--==================================================
-- GIVE TOOL
--==================================================
local function giveTool(tool)
    if not enabled then return end
    local clone = tool:Clone()
    clone.Parent = backpack
end

--==================================================
-- GERAR LISTA
--==================================================
local function buildList()
    clearList()

    for name, tool in pairs(toolCache) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,MAX_BUTTON_HEIGHT)
        btn.Text = name
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(90,90,90)
        btn.Parent = scroll

        btn.MouseButton1Click:Connect(function()
            giveTool(tool)
        end)
    end
end

--==================================================
-- BOTÃO REFRESH (PEGA NOVAS TOOLS AO REINJETAR)
--==================================================
local refresh = Instance.new("TextButton")
refresh.Size = UDim2.new(0.9,0,0.08,0)
refresh.Position = UDim2.new(0.05,0,0.92,0)
refresh.Text = "REFRESH TOOLS"
refresh.TextScaled = true
refresh.Font = Enum.Font.GothamBold
refresh.TextColor3 = Color3.new(1,1,1)
refresh.BackgroundColor3 = Color3.fromRGB(100,100,100)
refresh.Parent = hub

refresh.MouseButton1Click:Connect(function()
    scanTools()
    buildList()
end)

--==================================================
-- INIT
--==================================================
scanTools()
buildList()
