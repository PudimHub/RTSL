-- =====================================================
-- 99 NIGHTS HUB | PudimHub
-- GUI 100% própria, zero libs externas
-- =====================================================

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local CoreGui         = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService    = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local player      = LocalPlayer
local Character   = player.Character or player.CharacterAdded:Wait()
local Humanoid    = Character:WaitForChild("Humanoid")
local RootPart    = Character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(c)
    Character = c
    Humanoid  = c:WaitForChild("Humanoid")
    RootPart  = c:WaitForChild("HumanoidRootPart")
end)

-- =====================================================
-- GUI BUILDER
-- =====================================================
local gui = Instance.new("ScreenGui")
gui.Name = "PudimHub99"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

-- Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 420, 0, 520)
main.Position = UDim2.new(0.5, -210, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Stroke
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(80, 80, 180)
stroke.Thickness = 2

-- TopBar
local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 38)
topbar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
topbar.BorderSizePixel = 0
topbar.Parent = main
Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🌲 99 Nights Hub | PudimHub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topbar

-- Botão minimizar
local btnMin = Instance.new("TextButton")
btnMin.Size = UDim2.new(0, 26, 0, 26)
btnMin.Position = UDim2.new(1, -58, 0, 6)
btnMin.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
btnMin.Text = "─"
btnMin.TextColor3 = Color3.fromRGB(20,20,20)
btnMin.TextSize = 14
btnMin.Font = Enum.Font.GothamBold
btnMin.BorderSizePixel = 0
btnMin.Parent = topbar
Instance.new("UICorner", btnMin).CornerRadius = UDim.new(0,6)

-- Botão fechar
local btnClose = Instance.new("TextButton")
btnClose.Size = UDim2.new(0, 26, 0, 26)
btnClose.Position = UDim2.new(1, -28, 0, 6)
btnClose.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
btnClose.Text = "✕"
btnClose.TextColor3 = Color3.fromRGB(255,255,255)
btnClose.TextSize = 14
btnClose.Font = Enum.Font.GothamBold
btnClose.BorderSizePixel = 0
btnClose.Parent = topbar
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,6)

-- Botão flutuante
local floatGui = Instance.new("ScreenGui")
floatGui.Name = "PudimHubFloat"
floatGui.ResetOnSpawn = false
floatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
floatGui.Parent = CoreGui

local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 54, 0, 54)
floatBtn.Position = UDim2.new(0, 20, 0.5, -27)
floatBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
floatBtn.Text = "99\n🌲"
floatBtn.TextColor3 = Color3.fromRGB(255,255,255)
floatBtn.TextSize = 11
floatBtn.Font = Enum.Font.GothamBold
floatBtn.BorderSizePixel = 0
floatBtn.Visible = false
floatBtn.ZIndex = 99
floatBtn.Parent = floatGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(0, 14)
local fstroke = Instance.new("UIStroke", floatBtn)
fstroke.Color = Color3.fromRGB(80,80,180)
fstroke.Thickness = 2

-- Arrastar janela principal
do
    local dragging, dragStart, startPos = false, nil, nil
    topbar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- Arrastar botão flutuante
do
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    floatBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false; dragStart = i.Position; startPos = floatBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            if math.abs(d.X)+math.abs(d.Y) > 4 then moved = true end
            local vp = workspace.CurrentCamera.ViewportSize
            floatBtn.Position = UDim2.new(0, math.clamp(startPos.X.Offset+d.X,0,vp.X-54), 0, math.clamp(startPos.Y.Offset+d.Y,0,vp.Y-54))
        end
    end)
    floatBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            if not moved then gui.Enabled = true; floatBtn.Visible = false end
        end
    end)
end

-- Minimizar / Fechar
local isMin = false
local fullSize = main.Size

btnMin.MouseButton1Click:Connect(function()
    isMin = not isMin
    if isMin then
        main.Size = UDim2.new(0, 420, 0, 38)
        btnMin.Text = "□"
    else
        main.Size = fullSize
        btnMin.Text = "─"
    end
end)

btnClose.MouseButton1Click:Connect(function()
    gui.Enabled = false
    floatBtn.Visible = true
end)

-- =====================================================
-- TAB SYSTEM
-- =====================================================
local tabBar = Instance.new("ScrollingFrame")
tabBar.Size = UDim2.new(1, -8, 0, 32)
tabBar.Position = UDim2.new(0, 4, 0, 42)
tabBar.BackgroundTransparency = 1
tabBar.ScrollBarThickness = 0
tabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
tabBar.Parent = main

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 4)

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -8, 1, -82)
content.Position = UDim2.new(0, 4, 0, 78)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Color3.fromRGB(80,80,180)
content.CanvasSize = UDim2.new(0,0,0,0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main

local contentLayout = Instance.new("UIListLayout", content)
contentLayout.Padding = UDim.new(0, 6)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

local tabs = {}
local activeTab = nil
local tabFrames = {}
local tabButtons = {}

local function newTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 0, 1, 0)
    btn.AutomaticSize = Enum.AutomaticSize.X
    btn.BackgroundColor3 = Color3.fromRGB(30,30,50)
    btn.TextColor3 = Color3.fromRGB(180,180,200)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Text = "  "..name.."  "
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1,0,0,0)
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.BackgroundTransparency = 1
    frame.Visible = false
    frame.LayoutOrder = #tabs+1
    frame.Parent = content

    local fl = Instance.new("UIListLayout", frame)
    fl.Padding = UDim.new(0,6)
    fl.SortOrder = Enum.SortOrder.LayoutOrder

    local t = {btn=btn, frame=frame, order=0}
    table.insert(tabs, t)
    table.insert(tabFrames, frame)
    table.insert(tabButtons, btn)

    btn.MouseButton1Click:Connect(function()
        for _, tb in ipairs(tabs) do
            tb.frame.Visible = false
            tb.btn.BackgroundColor3 = Color3.fromRGB(30,30,50)
            tb.btn.TextColor3 = Color3.fromRGB(180,180,200)
        end
        t.frame.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(80,80,180)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        activeTab = t
    end)

    if #tabs == 1 then
        t.frame.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(80,80,180)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        activeTab = t
    end
    return t
end

-- Widget helpers
local function addToggle(tab, labelText, callback)
    tab.order = tab.order + 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,34)
    row.BackgroundColor3 = Color3.fromRGB(28,28,42)
    row.BorderSizePixel = 0
    row.LayoutOrder = tab.order
    row.Parent = tab.frame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-60,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local togBg = Instance.new("Frame")
    togBg.Size = UDim2.new(0,40,0,22)
    togBg.Position = UDim2.new(1,-50,0.5,-11)
    togBg.BackgroundColor3 = Color3.fromRGB(60,60,80)
    togBg.BorderSizePixel = 0
    togBg.Parent = row
    Instance.new("UICorner", togBg).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,18,0,18)
    knob.Position = UDim2.new(0,2,0.5,-9)
    knob.BackgroundColor3 = Color3.fromRGB(200,200,200)
    knob.BorderSizePixel = 0
    knob.Parent = togBg
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local on = false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = row

    btn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            TweenService:Create(togBg, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(80,80,220)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position=UDim2.new(0,20,0.5,-9)}):Play()
        else
            TweenService:Create(togBg, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(60,60,80)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position=UDim2.new(0,2,0.5,-9)}):Play()
        end
        callback(on)
    end)
end

local function addButton(tab, labelText, callback)
    tab.order = tab.order + 1
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,34)
    btn.BackgroundColor3 = Color3.fromRGB(60,60,160)
    btn.Text = labelText
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.LayoutOrder = tab.order
    btn.Parent = tab.frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    btn.MouseButton1Click:Connect(callback)
end

local function addSlider(tab, labelText, min, max, default, callback)
    tab.order = tab.order + 1
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,50)
    row.BackgroundColor3 = Color3.fromRGB(28,28,42)
    row.BorderSizePixel = 0
    row.LayoutOrder = tab.order
    row.Parent = tab.frame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-10,0,22)
    lbl.Position = UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText..": "..default
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,-20,0,6)
    track.Position = UDim2.new(0,10,0,32)
    track.BackgroundColor3 = Color3.fromRGB(50,50,80)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(80,80,220)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0,14,0,14)
    knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.Position = UDim2.new((default-min)/(max-min),0,0.5,0)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.Text = ""
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local sliding = false
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local abs = track.AbsolutePosition
            local sz  = track.AbsoluteSize
            local pct = math.clamp((i.Position.X - abs.X)/sz.X, 0, 1)
            local val = math.floor(min + (max-min)*pct)
            fill.Size = UDim2.new(pct,0,1,0)
            knob.Position = UDim2.new(pct,0,0.5,0)
            lbl.Text = labelText..": "..val
            callback(val)
        end
    end)
end

local function addLabel(tab, text)
    tab.order = tab.order + 1
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,0,24)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  "..text
    lbl.TextColor3 = Color3.fromRGB(150,150,180)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = tab.order
    lbl.Parent = tab.frame
end

-- =====================================================
-- TABS
-- =====================================================
local tMain   = newTab("Main")
local tAuto   = newTab("Auto")
local tItemTP = newTab("Item TP")
local tGameTP = newTab("Game TP")
local tMobTP  = newTab("Mob TP")
local tPlayer = newTab("Player")
local tVisual = newTab("Visuals")
local tMisc   = newTab("Misc")

-- =====================================================
-- MAIN TAB
-- =====================================================
local remEvt = ReplicatedStorage:WaitForChild("RemoteEvents")
local killOn = false
local killRadius = 200

local toolsDmg = {
    ["Old Axe"]="1_8982038982",["Good Axe"]="112_8982038982",
    ["Strong Axe"]="116_8982038982",["Chainsaw"]="647_8992824875",["Spear"]="196_8999010016"
}
local function getTool()
    for n,id in pairs(toolsDmg) do
        local t = player.Backpack:FindFirstChild(n) or (Character and Character:FindFirstChild(n))
        if t then return t,id end
    end
end

addToggle(tMain, "Kill Aura", function(v)
    killOn = v
    if v then task.spawn(function()
        while killOn do
            local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local tool,id = getTool()
                if tool and id then
                    remEvt.EquipItemHandle:FireServer("FireAllClients", tool)
                    for _,mob in ipairs(workspace:GetDescendants()) do
                        if mob:IsA("Model") and mob ~= Character and mob:FindFirstChild("Humanoid") then
                            local p = mob:FindFirstChildWhichIsA("BasePart")
                            if p and (p.Position-hrp.Position).Magnitude<=killRadius then
                                pcall(function() remEvt.ToolDamageObject:InvokeServer(mob,tool,id,CFrame.new(p.Position)) end)
                            end
                        end
                    end
                    task.wait(0.1)
                else task.wait(1) end
            else task.wait(0.5) end
        end
    end) end
end)

addSlider(tMain, "Kill Aura Radius", 20, 500, 200, function(v) killRadius = v end)

addButton(tMain, "TP → Stronghold", function()
    local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local p = workspace:FindFirstChild("Map")
    p = p and p:FindFirstChild("Landmarks")
    p = p and p:FindFirstChild("Stronghold")
    p = p and p:FindFirstChild("Functional")
    p = p and p:FindFirstChild("EntryDoors")
    p = p and p:FindFirstChild("DoorRight")
    p = p and p:FindFirstChild("Model")
    if p then
        local dest = p:GetChildren()[5]
        if dest and dest:IsA("BasePart") then hrp.CFrame = dest.CFrame + Vector3.new(0,5,0) end
    end
end)

addButton(tMain, "TP → Diamond Chest", function()
    local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local items = workspace:FindFirstChild("Items")
    local chest = items and items:FindFirstChild("Stronghold Diamond Chest")
    local lid   = chest and chest:FindFirstChild("ChestLid")
    local mesh  = lid and lid:FindFirstChild("Meshes/diamondchest_Cube.002")
    if mesh then hrp.CFrame = mesh.CFrame + Vector3.new(0,5,0) end
end)

-- =====================================================
-- AUTO FARM TAB
-- =====================================================
local itemsF = workspace:WaitForChild("Items")
local remAuto = ReplicatedStorage:WaitForChild("RemoteEvents")
local remConsume = remAuto:WaitForChild("RequestConsumeItem")

local campPos    = Vector3.new(0,19,0)
local machinePos = Vector3.new(21,16,-5)
local fuelItems  = {"Log","Coal","Fuel Canister","Oil Barrel","Biofuel"}
local cookItems  = {"Morsel","Steak"}
local grindItems = {"UFO Junk","UFO Component","Old Car Engine","Broken Fan","Old Microwave","Bolt","Cultist Gem","Sheet Metal","Tyre","Washing Machine","Broken Microwave"}
local eatFoods   = {"Cooked Steak","Cooked Morsel","Berry","Carrot","Apple"}
local bfItems    = {"Carrot","Cooked Morsel","Morsel","Steak","Cooked Steak","Log"}

local autoAlways,autoHP,autoCook,autoGrind,autoEat,autoBiofuel = false,false,false,false,false,false

local function moveItem(item, pos)
    if not item or not item:IsDescendantOf(workspace) then return end
    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
    if not part then return end
    if not item.PrimaryPart then pcall(function() item.PrimaryPart = part end) end
    pcall(function()
        remAuto.RequestStartDraggingItem:FireServer(item)
        task.wait(0.05)
        item:SetPrimaryPartCFrame(CFrame.new(pos))
        task.wait(0.05)
        remAuto.StopDraggingItem:FireServer(item)
    end)
end

addToggle(tAuto,"Auto Feed Campfire (Always)",  function(v) autoAlways=v end)
addToggle(tAuto,"Auto Feed Campfire (HP Based)", function(v) autoHP=v end)
addToggle(tAuto,"Auto Cook Food",                function(v) autoCook=v end)
addToggle(tAuto,"Auto Machine Grind",            function(v) autoGrind=v end)
addToggle(tAuto,"Auto Eat (3s)",                 function(v) autoEat=v end)
addToggle(tAuto,"Auto Biofuel Processor",        function(v) autoBiofuel=v end)

-- Coroutines
coroutine.wrap(function() while true do
    if autoAlways then for _,item in ipairs(itemsF:GetChildren()) do for _,n in ipairs(fuelItems) do if item.Name==n then moveItem(item,campPos) end end end end
    task.wait(2)
end end)()

coroutine.wrap(function() while true do
    if autoHP then
        local ok,campfire = pcall(function() return workspace.Map.Campground.MainFire end)
        if ok and campfire then
            local fill = campfire.Center.BillboardGui.Frame.Background.Fill
            if fill.Size.X.Scale < 0.7 then
                for _,item in ipairs(itemsF:GetChildren()) do for _,n in ipairs(fuelItems) do if item.Name==n then moveItem(item,campPos) end end end
            end
        end
    end
    task.wait(2)
end end)()

coroutine.wrap(function() while true do
    if autoCook then for _,item in ipairs(itemsF:GetChildren()) do for _,n in ipairs(cookItems) do if item.Name==n then moveItem(item,campPos) end end end end
    task.wait(2.5)
end end)()

coroutine.wrap(function() while true do
    if autoGrind then for _,item in ipairs(itemsF:GetChildren()) do for _,n in ipairs(grindItems) do if item.Name==n then moveItem(item,machinePos) end end end end
    task.wait(2.5)
end end)()

coroutine.wrap(function() while true do
    if autoEat then
        local avail={}
        for _,item in ipairs(itemsF:GetChildren()) do if table.find(eatFoods,item.Name) then table.insert(avail,item) end end
        if #avail>0 then pcall(function() remConsume:InvokeServer(avail[math.random(1,#avail)]) end) end
    end
    task.wait(3)
end end)()

coroutine.wrap(function()
    local bfPos
    while true do
        if autoBiofuel then
            if not bfPos then
                local proc = workspace:FindFirstChild("Structures") and workspace.Structures:FindFirstChild("Biofuel Processor")
                local part = proc and proc:FindFirstChild("Part")
                if part then bfPos = part.Position+Vector3.new(0,5,0) end
            end
            if bfPos then for _,item in ipairs(itemsF:GetChildren()) do for _,n in ipairs(bfItems) do if item.Name==n then moveItem(item,bfPos) end end end end
        end
        task.wait(2)
    end
end)()

-- Trees
local origCFrames,treesBrought={},false
local function findTrunk(t) for _,p in ipairs(t:GetDescendants()) do if p:IsA("BasePart") and p.Name=="Trunk" then return p end end end
local function getSmallTrees()
    local trees={}
    local map=workspace:FindFirstChild("Map")
    if not map then return trees end
    local function sc(f) for _,o in ipairs(f:GetChildren()) do if o:IsA("Model") and o.Name=="Small Tree" then table.insert(trees,o) end end end
    if map:FindFirstChild("Foliage") then sc(map.Foliage) end
    if map:FindFirstChild("Landmarks") then sc(map.Landmarks) end
    return trees
end
addToggle(tAuto,"Auto Bring Small Trees",function(v)
    if v and not treesBrought then
        local hrp=Character and Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local target=CFrame.new(hrp.Position+hrp.CFrame.LookVector*10)
        for _,tree in ipairs(getSmallTrees()) do
            local trunk=findTrunk(tree)
            if trunk then
                if not origCFrames[tree] then origCFrames[tree]=trunk.CFrame end
                tree.PrimaryPart=trunk; trunk.Anchored=false; trunk.CanCollide=false; task.wait()
                tree:SetPrimaryPartCFrame(target+Vector3.new(math.random(-5,5),0,math.random(-5,5)))
                trunk.Anchored=true
            end
        end
        treesBrought=true
    elseif not v and treesBrought then
        for tree,cf in pairs(origCFrames) do
            local trunk=findTrunk(tree)
            if trunk then tree.PrimaryPart=trunk; tree:SetPrimaryPartCFrame(cf); trunk.Anchored=true; trunk.CanCollide=true end
        end
        origCFrames={}; treesBrought=false
    end
end)

-- =====================================================
-- ITEM TP TAB
-- =====================================================
local allItems={"Alien Chest","Alpha Wolf Pelt","Apple","Bandage","Bear Pelt","Berry","Biofuel","Bolt","Broken Fan","Bunny Foot","Carrot","Chainsaw","Coal","Coin Stack","Cooked Morsel","Cooked Steak","Cultist Gem","Flower","Fuel Canister","Giant Sack","Good Axe","Good Sack","Hologram Emitter","Iron Body","Item Chest","Laser Fence Blueprint","Leather Body","Log","MedKit","Morsel","Oil Barrel","Old Car Engine","Old Flashlight","Old Radio","Raygun","Revolver","Revolver Ammo","Rifle","Rifle Ammo","Sheet Metal","Steak","Strong Axe","Thorn Body","Tyre","Washing Machine","Wolf Pelt"}

local function bringItem(name)
    local hrp=Character and Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local count=0
    for _,item in ipairs(itemsF:GetChildren()) do
        if item.Name==name then
            local part=item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if part then
                pcall(function()
                    remAuto.RequestStartDraggingItem:FireServer(item)
                    part.CFrame=hrp.CFrame+Vector3.new(0,count*2,0)
                    remAuto.StopDraggingItem:FireServer(item)
                end)
                count=count+1
            end
        end
    end
end

addLabel(tItemTP,"Clique no item para trazer até você:")
for _,name in ipairs(allItems) do
    addButton(tItemTP, name, function() bringItem(name) end)
end

-- Item ESP
local espItemOn=false
addToggle(tItemTP,"Item ESP",function(v)
    espItemOn=v
    if not v then
        for _,m in ipairs(itemsF:GetChildren()) do
            local b=m:FindFirstChild("_IESP") if b then b:Destroy() end
        end
    else
        for _,m in ipairs(itemsF:GetChildren()) do
            local part=m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
            if part and not m:FindFirstChild("_IESP") then
                local bb=Instance.new("BillboardGui"); bb.Name="_IESP"
                bb.Size=UDim2.new(0,100,0,26); bb.StudsOffset=Vector3.new(0,3,0)
                bb.AlwaysOnTop=true; bb.Adornee=part; bb.Parent=m
                local lbl=Instance.new("TextLabel",bb)
                lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
                lbl.TextColor3=Color3.new(1,1,0); lbl.TextStrokeTransparency=0.4
                lbl.TextScaled=true; lbl.Text=m.Name
            end
        end
    end
end)

-- =====================================================
-- GAME TP TAB
-- =====================================================
local tps={{"Camp Site",Vector3.new(0,8,0)},{"Safe Zone",Vector3.new(0,110,0)},{"Caves",Vector3.new(300,-50,400)},{"Stronghold",Vector3.new(300,20,400)}}
for _,tp in ipairs(tps) do
    addButton(tGameTP,"TP → "..tp[1],function()
        local hrp=Character and Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame=CFrame.new(tp[2]) end
    end)
end

-- =====================================================
-- MOB TP TAB
-- =====================================================
local mobs={"Alpha Wolf","Bear","Lost Child","Lost Child2","Lost Child3","Lost Child4","Wolf","Bunny","Cultist","Alien"}
for _,mob in ipairs(mobs) do
    addButton(tMobTP,"Bring "..mob,function()
        local hrp=Character and Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local cf=workspace:FindFirstChild("Characters")
        if not cf then return end
        local c=0
        for _,m in ipairs(cf:GetChildren()) do
            if m.Name==mob then
                local p=m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                if p then
                    if m.PrimaryPart then m:SetPrimaryPartCFrame(hrp.CFrame+Vector3.new(0,c*3,0))
                    else p.CFrame=hrp.CFrame+Vector3.new(0,c*3,0) end
                    c=c+1
                end
            end
        end
    end)
end

-- =====================================================
-- PLAYER TAB
-- =====================================================
addSlider(tPlayer,"WalkSpeed",16,500,16,function(v)
    _G.HWS=v
    local hum=Character and Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed=v end
end)

addSlider(tPlayer,"JumpPower",50,500,50,function(v)
    local hum=Character and Character:FindFirstChild("Humanoid")
    if hum then hum.JumpPower=v end
end)

addToggle(tPlayer,"God Mode",function(v)
    task.spawn(function() while v do
        task.wait(0.1)
        local hum=Character and Character:FindFirstChild("Humanoid")
        if hum then hum.Health=math.huge; hum.MaxHealth=math.huge end
    end end)
end)

local noclipOn=false
addToggle(tPlayer,"Noclip",function(v)
    noclipOn=v
    task.spawn(function() while noclipOn do
        task.wait()
        if Character then for _,p in ipairs(Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    end end)
end)

local ijConn
addToggle(tPlayer,"Infinite Jump",function(v)
    if v then ijConn=UserInputService.JumpRequest:Connect(function()
        local hum=Character and Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
    elseif ijConn then ijConn:Disconnect() end
end)

local flyOn=false
addToggle(tPlayer,"Fly",function(v)
    flyOn=v
    local hrp=Character and Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if v then
        local bg=Instance.new("BodyGyro",hrp); bg.MaxTorque=Vector3.new(9e9,9e9,9e9); bg.P=9e4
        local bv=Instance.new("BodyVelocity",hrp); bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.P=9e4
        task.spawn(function() while flyOn do
            task.wait()
            local cam=workspace.CurrentCamera
            local spd=(Character:FindFirstChild("Humanoid") and Character.Humanoid.WalkSpeed or 16)*2
            local fwd=cam.CFrame.LookVector
            local move=Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move=move+fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move=move-fwd end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move=move-Vector3.new(0,1,0) end
            bv.Velocity=move*spd; bg.CFrame=cam.CFrame
        end
        if hrp:FindFirstChildOfClass("BodyGyro") then hrp:FindFirstChildOfClass("BodyGyro"):Destroy() end
        if hrp:FindFirstChildOfClass("BodyVelocity") then hrp:FindFirstChildOfClass("BodyVelocity"):Destroy() end
        end)
    end
end)

-- =====================================================
-- VISUALS TAB
-- =====================================================
local BillESPs,ChamsESPs,ESPConns={},{},{}
local espOn,chamsOn=false,false

local function createBillESP(plr)
    if BillESPs[plr] or plr==LocalPlayer then return end
    if not plr.Character or not plr.Character:FindFirstChild("Head") then return end
    local g=Instance.new("BillboardGui"); g.Name="BESP"; g.Adornee=plr.Character.Head
    g.Parent=plr.Character.Head; g.Size=UDim2.new(0,100,0,38); g.AlwaysOnTop=true; g.StudsOffset=Vector3.new(0,2,0)
    local l=Instance.new("TextLabel",g); l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
    l.TextColor3=Color3.new(1,1,1); l.TextStrokeTransparency=0.5; l.TextScaled=true; l.Font=Enum.Font.GothamBold
    local conn; conn=RunService.RenderStepped:Connect(function()
        if not plr.Character or not plr.Character:FindFirstChild("Humanoid") then
            g:Destroy(); if conn then conn:Disconnect() end; BillESPs[plr]=nil; ESPConns[plr]=nil; return
        end
        local hp=math.floor(plr.Character.Humanoid.Health/math.max(plr.Character.Humanoid.MaxHealth,1)*100)
        l.Text=plr.Name.." | "..hp.."%"
    end)
    BillESPs[plr]=g; ESPConns[plr]=conn
end

local function createChams(plr)
    if ChamsESPs[plr] or plr==LocalPlayer or not plr.Character then return end
    local f=Instance.new("Folder"); f.Name="Chams"; f.Parent=CoreGui; ChamsESPs[plr]=f
    for _,p in pairs(plr.Character:GetChildren()) do
        if p:IsA("BasePart") then
            local b=Instance.new("BoxHandleAdornment"); b.Adornee=p; b.AlwaysOnTop=true
            b.ZIndex=10; b.Size=p.Size; b.Transparency=0.4; b.Color=BrickColor.new("Bright red"); b.Parent=f
        end
    end
end

local function cleanBill() for _,g in pairs(BillESPs) do if g then g:Destroy() end end for _,c in pairs(ESPConns) do if c then c:Disconnect() end end BillESPs={};ESPConns={} end
local function cleanChams() for _,f in pairs(ChamsESPs) do if f then f:Destroy() end end ChamsESPs={} end

local function initESP(plr)
    if espOn then createBillESP(plr) end
    if chamsOn then createChams(plr) end
    plr.CharacterAdded:Connect(function() task.wait(1); if espOn then createBillESP(plr) end; if chamsOn then createChams(plr) end end)
end

addToggle(tVisual,"Player ESP",function(v) espOn=v; if not v then cleanBill() else for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then createBillESP(p) end end end end)
addToggle(tVisual,"Player Chams",function(v) chamsOn=v; if not v then cleanChams() else for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then createChams(p) end end end end)

for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then initESP(p) end end
Players.PlayerAdded:Connect(initESP)

local fovCircle=Drawing.new("Circle")
fovCircle.Visible=false; fovCircle.Color=Color3.new(1,1,1); fovCircle.Transparency=1
fovCircle.Thickness=1.5; fovCircle.Filled=false
local fovR=100
RunService.RenderStepped:Connect(function()
    if fovCircle.Visible then fovCircle.Radius=fovR; fovCircle.Position=UserInputService:GetMouseLocation() end
end)
addToggle(tVisual,"FOV Circle",function(v) fovCircle.Visible=v end)
addSlider(tVisual,"FOV Radius",10,500,100,function(v) fovR=v end)

-- =====================================================
-- MISC TAB
-- =====================================================
addButton(tMisc,"Infinite Yield",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)
addButton(tMisc,"Server Hop",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/oofid/SynapseXScriptHub/main/serverhop.lua"))()
end)
addButton(tMisc,"Anti-AFK",function()
    local vu=game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
    end)
end)
addButton(tMisc,"Emote GUI",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dimension-sources/random-scripts-i-found/refs/heads/main/r6%20animations"))()
end)

print("✅ 99 Nights Hub carregado! | PudimHub")
