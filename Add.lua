--// SERVIÇOS
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

--// VARIÁVEIS
local giveEnabled = false
local dragToggle = false
local dragStart, startPos

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GiveToolHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

--// HUB FRAME
local hub = Instance.new("Frame")
hub.Size = UDim2.fromScale(0.6, 0.6)
hub.Position = UDim2.fromScale(0.2, 0.2)
hub.BackgroundColor3 = Color3.fromRGB(60,60,60)
hub.BorderSizePixel = 0
hub.Active = true
hub.Parent = gui

--// TITLE BAR
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0.12,0)
title.Text = "GIVE TOOLS HUB"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(80,80,80)
title.Parent = hub

--// DRAG MOBILE + PC
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = hub.Position
    end
end)

title.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        hub.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

--// BOTÃO TOGGLE
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9,0,0.1,0)
toggleBtn.Position = UDim2.new(0.05,0,0.14,0)
toggleBtn.Text = "GIVE TOOLS: OFF"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
toggleBtn.Parent = hub

toggleBtn.MouseButton1Click:Connect(function()
    giveEnabled = not giveEnabled
    if giveEnabled then
        toggleBtn.Text = "GIVE TOOLS: ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0,170,0)
    else
        toggleBtn.Text = "GIVE TOOLS: OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
    end
end)

--// SCROLL
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(0.9,0,0.7,0)
list.Position = UDim2.new(0.05,0,0.26,0)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0
list.BackgroundColor3 = Color3.fromRGB(40,40,40)
list.BorderSizePixel = 0
list.Parent = hub

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0,10)

--// BUSCA DE TOOLS
local SEARCH = {
    workspace,
    game:GetService("ReplicatedStorage"),
    game:GetService("ServerStorage")
}

local function getAllTools()
    local found = {}
    for _, place in ipairs(SEARCH) do
        for _, obj in ipairs(place:GetDescendants()) do
            if obj:IsA("Tool") and not found[obj.Name] then
                found[obj.Name] = obj
            end
        end
    end
    return found
end

--// GIVE TOOL
local function giveTool(tool)
    if not giveEnabled then return end
    local clone = tool:Clone()
    clone.Parent = backpack
end

--// GERAR BOTÕES
local tools = getAllTools()
for name, tool in pairs(tools) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,50)
    btn.Text = name
    btn.TextScaled = true
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = Color3.new(1,1,1)
    btn.BackgroundColor3 = Color3.fromRGB(90,90,90)
    btn.Parent = list

    btn.MouseButton1Click:Connect(function()
        giveTool(tool)
    end)
end

task.wait()
list.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20)
