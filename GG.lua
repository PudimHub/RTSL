-- =====================================================
-- 99 NIGHTS IN THE FOREST - SCRIPT COMPLETO
-- UI: Orion Library (funciona no Delta)
-- =====================================================

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "99 Nights Hub | PudimHub",
    HidePremium = true,
    SaveConfig = false,
    IntroEnabled = false,
})

-- =====================================================
-- SERVICES & PLAYER
-- =====================================================
local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local CoreGui         = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer  = Players.LocalPlayer
local player       = LocalPlayer
local Character    = player.Character or player.CharacterAdded:Wait()
local Humanoid     = Character:WaitForChild("Humanoid")
local rootPart     = Character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(c)
    Character  = c
    Humanoid   = c:WaitForChild("Humanoid")
    rootPart   = c:WaitForChild("HumanoidRootPart")
end)

-- =====================================================
-- TABS
-- =====================================================
local MainTab    = Window:MakeTab({ Name = "Main",     Icon = "rbxassetid://4483345998" })
local AutoTab    = Window:MakeTab({ Name = "Auto Farm",Icon = "rbxassetid://4483345998" })
local ItemTab    = Window:MakeTab({ Name = "Item TP",  Icon = "rbxassetid://4483345998" })
local GameTPTab  = Window:MakeTab({ Name = "Game TP",  Icon = "rbxassetid://4483345998" })
local MobTab     = Window:MakeTab({ Name = "Mob TP",   Icon = "rbxassetid://4483345998" })
local PlayerTab  = Window:MakeTab({ Name = "Player",   Icon = "rbxassetid://4483345998" })
local VisualTab  = Window:MakeTab({ Name = "Visuals",  Icon = "rbxassetid://4483345998" })
local MiscTab    = Window:MakeTab({ Name = "Misc",     Icon = "rbxassetid://4483345998" })

-- =====================================================
-- MAIN TAB — Kill Aura + Stronghold
-- =====================================================
local remoteEventsMain = ReplicatedStorage:WaitForChild("RemoteEvents")

local killAuraToggle = false
local radius = 200

local toolsDamageIDs = {
    ["Old Axe"]   = "1_8982038982",
    ["Good Axe"]  = "112_8982038982",
    ["Strong Axe"]= "116_8982038982",
    ["Chainsaw"]  = "647_8992824875",
    ["Spear"]     = "196_8999010016",
}

local function getAnyToolWithDamageID()
    for toolName, damageID in pairs(toolsDamageIDs) do
        local tool = player.Backpack:FindFirstChild(toolName)
            or (Character and Character:FindFirstChild(toolName))
        if tool then return tool, damageID end
    end
    return nil, nil
end

local function killAuraLoop()
    while killAuraToggle do
        local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local tool, damageID = getAnyToolWithDamageID()
            if tool and damageID then
                for _, mob in ipairs(workspace:GetDescendants()) do
                    if mob:IsA("Model") and mob:FindFirstChild("Humanoid")
                    and mob ~= Character then
                        local part = mob:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - hrp.Position).Magnitude <= radius then
                            pcall(function()
                                remoteEventsMain.ToolDamageObject:InvokeServer(
                                    mob, tool, damageID, CFrame.new(part.Position))
                            end)
                        end
                    end
                end
                task.wait(0.1)
            else
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end

MainTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(v)
        killAuraToggle = v
        if v then task.spawn(killAuraLoop) end
    end
})

MainTab:AddSlider({
    Name = "Kill Aura Radius",
    Min = 20, Max = 500, Default = 200,
    Increment = 5,
    ValueName = "studs",
    Callback = function(v) radius = v end
})

-- Stronghold Timer
MainTab:AddLabel("Stronghold Timer: carregando...")
local function getStrongholdTimerLabel()
    local ok = workspace:FindFirstChild("Map")
    if not ok then return nil end
    local l = ok:FindFirstChild("Landmarks")
    if not l then return nil end
    local s = l:FindFirstChild("Stronghold")
    if not s then return nil end
    local f = s:FindFirstChild("Functional")
    if not f then return nil end
    local sg = f:FindFirstChild("Sign")
    if not sg then return nil end
    local sui = sg:FindFirstChild("SurfaceGui")
    if not sui then return nil end
    local fr = sui:FindFirstChild("Frame")
    if not fr then return nil end
    return fr:FindFirstChild("Body")
end

task.spawn(function()
    while true do
        task.wait(1)
        local lbl = getStrongholdTimerLabel()
        -- label só de display, sem API de update na Orion
    end
end)

MainTab:AddButton({
    Name = "TP Stronghold",
    Callback = function()
        local path = workspace:FindFirstChild("Map")
        if not path then warn("Map not found") return end
        local lm = path:FindFirstChild("Landmarks") if not lm then return end
        local sh = lm:FindFirstChild("Stronghold") if not sh then return end
        local fn = sh:FindFirstChild("Functional") if not fn then return end
        local ed = fn:FindFirstChild("EntryDoors") if not ed then return end
        local dr = ed:FindFirstChild("DoorRight") if not dr then return end
        local mo = dr:FindFirstChild("Model") if not mo then return end
        local dest = mo:GetChildren()[5]
        local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
        if dest and dest:IsA("BasePart") and hrp then
            hrp.CFrame = dest.CFrame + Vector3.new(0,5,0)
        end
    end
})

MainTab:AddButton({
    Name = "TP Diamond Chest",
    Callback = function()
        local items = workspace:FindFirstChild("Items") if not items then return end
        local chest = items:FindFirstChild("Stronghold Diamond Chest") if not chest then return end
        local lid   = chest:FindFirstChild("ChestLid") if not lid then return end
        local mesh  = lid:FindFirstChild("Meshes/diamondchest_Cube.002") if not mesh then return end
        local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = mesh.CFrame + Vector3.new(0,5,0) end
    end
})

-- =====================================================
-- AUTO FARM TAB
-- =====================================================
local remoteEventsAuto = ReplicatedStorage:WaitForChild("RemoteEvents")
local remoteConsume    = remoteEventsAuto:WaitForChild("RequestConsumeItem")
local itemsFolder      = workspace:WaitForChild("Items")

local campfireDropPos  = Vector3.new(0, 19, 0)
local machineDropPos   = Vector3.new(21, 16, -5)

local campfireFuelItems = {"Log","Coal","Fuel Canister","Oil Barrel","Biofuel"}
local autocookItems     = {"Morsel","Steak"}
local autoGrindItems    = {"UFO Junk","UFO Component","Old Car Engine","Broken Fan","Old Microwave","Bolt","Log","Cultist Gem","Sheet Metal","Old Radio","Tyre","Washing Machine","Broken Microwave"}
local autoEatFoods      = {"Cooked Steak","Cooked Morsel","Berry","Carrot","Apple"}
local biofuelItems      = {"Carrot","Cooked Morsel","Morsel","Steak","Cooked Steak","Log"}

local autoFuelEnabled   = false
local alwaysFeedEnabled = false
local autoCookEnabled   = false
local autoGrindEnabled  = false
local autoEatEnabled    = false
local autoBiofuelEnabled= false
local autoBreakEnabled  = false

local function moveItemToPos(item, position)
    if not item or not item:IsDescendantOf(workspace) then return end
    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
    if not part then return end
    if not item.PrimaryPart then pcall(function() item.PrimaryPart = part end) end
    pcall(function()
        remoteEventsAuto.RequestStartDraggingItem:FireServer(item)
        task.wait(0.05)
        item:SetPrimaryPartCFrame(CFrame.new(position))
        task.wait(0.05)
        remoteEventsAuto.StopDraggingItem:FireServer(item)
    end)
end

AutoTab:AddToggle({ Name = "Auto Feed Campfire (Always)",  Default = false, Callback = function(v) alwaysFeedEnabled = v end })
AutoTab:AddToggle({ Name = "Auto Feed Campfire (HP Based)",Default = false, Callback = function(v) autoFuelEnabled   = v end })
AutoTab:AddToggle({ Name = "Auto Cook Food",               Default = false, Callback = function(v) autoCookEnabled   = v end })
AutoTab:AddToggle({ Name = "Auto Machine Grind",           Default = false, Callback = function(v) autoGrindEnabled  = v end })
AutoTab:AddToggle({ Name = "Auto Eat (3s interval)",       Default = false, Callback = function(v) autoEatEnabled    = v end })
AutoTab:AddToggle({ Name = "Auto Biofuel Processor",       Default = false, Callback = function(v) autoBiofuelEnabled= v end })

AutoTab:AddDropdown({
    Name = "Fuel Item",
    Default = "Log",
    Options = campfireFuelItems,
    Callback = function(v) end
})

-- Coroutines
coroutine.wrap(function()
    while true do
        if alwaysFeedEnabled then
            for _, item in ipairs(itemsFolder:GetChildren()) do
                for _, name in ipairs(campfireFuelItems) do
                    if item.Name == name then moveItemToPos(item, campfireDropPos) end
                end
            end
        end
        task.wait(2)
    end
end)()

coroutine.wrap(function()
    while true do
        if autoFuelEnabled then
            local ok, campfire = pcall(function()
                return workspace:FindFirstChild("Map")
                    :FindFirstChild("Campground"):FindFirstChild("MainFire")
            end)
            if ok and campfire then
                local fill = campfire.Center.BillboardGui.Frame.Background.Fill
                if fill.Size.X.Scale < 0.7 then
                    for _, item in ipairs(itemsFolder:GetChildren()) do
                        for _, name in ipairs(campfireFuelItems) do
                            if item.Name == name then moveItemToPos(item, campfireDropPos) end
                        end
                    end
                end
            end
        end
        task.wait(2)
    end
end)()

coroutine.wrap(function()
    while true do
        if autoCookEnabled then
            for _, item in ipairs(itemsFolder:GetChildren()) do
                for _, name in ipairs(autocookItems) do
                    if item.Name == name then moveItemToPos(item, campfireDropPos) end
                end
            end
        end
        task.wait(2.5)
    end
end)()

coroutine.wrap(function()
    while true do
        if autoGrindEnabled then
            for _, item in ipairs(itemsFolder:GetChildren()) do
                for _, name in ipairs(autoGrindItems) do
                    if item.Name == name then moveItemToPos(item, machineDropPos) end
                end
            end
        end
        task.wait(2.5)
    end
end)()

coroutine.wrap(function()
    while true do
        if autoEatEnabled then
            local available = {}
            for _, item in ipairs(itemsFolder:GetChildren()) do
                if table.find(autoEatFoods, item.Name) then
                    table.insert(available, item)
                end
            end
            if #available > 0 then
                pcall(function() remoteConsume:InvokeServer(available[math.random(1,#available)]) end)
            end
        end
        task.wait(3)
    end
end)()

coroutine.wrap(function()
    local biofuelPos
    while true do
        if autoBiofuelEnabled then
            if not biofuelPos then
                local proc = workspace:FindFirstChild("Structures")
                    and workspace.Structures:FindFirstChild("Biofuel Processor")
                local part = proc and proc:FindFirstChild("Part")
                if part then biofuelPos = part.Position + Vector3.new(0,5,0) end
            end
            if biofuelPos then
                for _, item in ipairs(itemsFolder:GetChildren()) do
                    for _, name in ipairs(biofuelItems) do
                        if item.Name == name then moveItemToPos(item, biofuelPos) end
                    end
                end
            end
        end
        task.wait(2)
    end
end)()

-- Tree System
local originalTreeCFrames = {}
local treesBrought = false

local function findTrunk(tree)
    for _, p in ipairs(tree:GetDescendants()) do
        if p:IsA("BasePart") and p.Name == "Trunk" then return p end
    end
end

local function getAllSmallTrees()
    local trees = {}
    local map = workspace:FindFirstChild("Map")
    if not map then return trees end
    local function scan(folder)
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj.Name == "Small Tree" then
                table.insert(trees, obj)
            end
        end
    end
    if map:FindFirstChild("Foliage")   then scan(map.Foliage)   end
    if map:FindFirstChild("Landmarks") then scan(map.Landmarks) end
    return trees
end

local function bringAllTrees()
    local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local target = CFrame.new(hrp.Position + hrp.CFrame.LookVector * 10)
    for _, tree in ipairs(getAllSmallTrees()) do
        local trunk = findTrunk(tree)
        if trunk then
            if not originalTreeCFrames[tree] then originalTreeCFrames[tree] = trunk.CFrame end
            tree.PrimaryPart = trunk
            trunk.Anchored = false
            trunk.CanCollide = false
            task.wait()
            tree:SetPrimaryPartCFrame(target + Vector3.new(math.random(-5,5),0,math.random(-5,5)))
            trunk.Anchored = true
        end
    end
    treesBrought = true
end

local function restoreTrees()
    for tree, cf in pairs(originalTreeCFrames) do
        local trunk = findTrunk(tree)
        if trunk then
            tree.PrimaryPart = trunk
            tree:SetPrimaryPartCFrame(cf)
            trunk.Anchored  = true
            trunk.CanCollide= true
        end
    end
    originalTreeCFrames = {}
    treesBrought = false
end

AutoTab:AddToggle({
    Name = "Auto Bring Small Trees",
    Default = false,
    Callback = function(v)
        autoBreakEnabled = v
        if v and not treesBrought then bringAllTrees()
        elseif not v and treesBrought then restoreTrees() end
    end
})

-- =====================================================
-- ITEM TP TAB
-- =====================================================
local remoteEventsItem = ReplicatedStorage:WaitForChild("RemoteEvents")

local possibleItems = {
    "Alien Chest","Alpha Wolf Pelt","Anvil Front","Anvil Back","Apple","Bandage",
    "Bear Corpse","Bear Pelt","Berry","Biofuel","Bolt","Broken Fan","Bunny Foot",
    "Carrot","Coal","Coin Stack","Cooked Morsel","Cooked Steak","Chainsaw",
    "Cultist Gem","Flower","Fuel Canister","Hologram Emitter","Item Chest",
    "Laser Fence Blueprint","Leather Body","Iron Body","Thorn Body","Log",
    "MedKit","Morsel","Old Flashlight","Old Radio","Good Sack","Good Axe",
    "Raygun","Giant Sack","Strong Axe","Oil Barrel","Old Car Engine","Rifle",
    "Rifle Ammo","Revolver","Revolver Ammo","Sapling","Sheet Metal","Steak",
    "Wolf Pelt","Gem of the Forest Fragment","Tyre","Washing Machine","Broken Microwave",
}

local function findTeleportablePart(item)
    for _, d in ipairs(item:GetDescendants()) do
        if d:IsA("BasePart") then return d end
    end
    return nil
end

local function teleportItemToMe(itemName)
    local stackOffsetY, count = 2, 0
    local sources = { itemsFolder }
    local ts = pcall(function()
        table.insert(sources, ReplicatedStorage:WaitForChild("TempStorage", 1))
    end)
    for _, source in ipairs(sources) do
        for _, item in ipairs(source:GetChildren()) do
            if item.Name == itemName then
                local part = findTeleportablePart(item)
                if part then
                    local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        remoteEventsItem.RequestStartDraggingItem:FireServer(item)
                        part.CFrame = hrp.CFrame + Vector3.new(0, count * stackOffsetY, 0)
                        remoteEventsItem.StopDraggingItem:FireServer(item)
                        count = count + 1
                    end
                end
            end
        end
    end
end

ItemTab:AddDropdown({
    Name = "Teleport Item to Me",
    Default = possibleItems[1],
    Options = possibleItems,
    Callback = function(v)
        teleportItemToMe(v)
    end
})

-- Item ESP
local itemESPEnabled = false
local itemESPConnections = {}

local function createItemESP(model)
    if model:FindFirstChild("ESP_Bill") then return end
    local part = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not part then return end
    local bill = Instance.new("BillboardGui")
    bill.Name = "ESP_Bill"
    bill.Size = UDim2.new(0,100,0,28)
    bill.StudsOffset = Vector3.new(0,3,0)
    bill.AlwaysOnTop = true
    bill.Adornee = part
    bill.Parent = model
    local lbl = Instance.new("TextLabel", bill)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1,1,0)
    lbl.TextStrokeTransparency = 0.4
    lbl.TextScaled = true
    lbl.Text = model.Name
end

local function removeAllItemESP()
    for _, model in ipairs(itemsFolder:GetChildren()) do
        local b = model:FindFirstChild("ESP_Bill")
        if b then b:Destroy() end
    end
    for _, c in ipairs(itemESPConnections) do c:Disconnect() end
    itemESPConnections = {}
end

ItemTab:AddToggle({
    Name = "Item ESP",
    Default = false,
    Callback = function(v)
        itemESPEnabled = v
        if v then
            for _, m in ipairs(itemsFolder:GetChildren()) do createItemESP(m) end
            table.insert(itemESPConnections, itemsFolder.ChildAdded:Connect(function(m)
                task.wait(0.1)
                if itemESPEnabled then createItemESP(m) end
            end))
        else
            removeAllItemESP()
        end
    end
})

-- =====================================================
-- GAME TP TAB
-- =====================================================
local gameTPs = {
    { "Camp Site",  Vector3.new(0,   8,  0)  },
    { "Safe Zone",  Vector3.new(0, 110,  0)  },
    { "Stronghold", Vector3.new(300, 20, 400) },
    { "Caves",      Vector3.new(300,-50, 400) },
}

for _, tp in ipairs(gameTPs) do
    local name, pos = tp[1], tp[2]
    GameTPTab:AddButton({
        Name = "TP → " .. name,
        Callback = function()
            local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(pos) end
        end
    })
end

-- =====================================================
-- MOB TP TAB
-- =====================================================
local possibleMobs = {
    "Alpha Wolf","Bear","Lost Child","Lost Child2",
    "Lost Child3","Lost Child4","Wolf","Bunny","Cultist","Alien"
}

local function teleportMobToMe(mobName)
    local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local charFolder = workspace:FindFirstChild("Characters")
    if not charFolder then return end
    local count = 0
    for _, mob in ipairs(charFolder:GetChildren()) do
        if mob.Name == mobName then
            local part = mob.PrimaryPart or mob:FindFirstChildWhichIsA("BasePart")
            if part then
                if mob.PrimaryPart then
                    mob:SetPrimaryPartCFrame(hrp.CFrame + Vector3.new(0, count*3, 0))
                else
                    part.CFrame = hrp.CFrame + Vector3.new(0, count*3, 0)
                end
                count = count + 1
            end
        end
    end
end

MobTab:AddDropdown({
    Name = "Teleport Mob to Me",
    Default = possibleMobs[1],
    Options = possibleMobs,
    Callback = function(v)
        teleportMobToMe(v)
    end
})

-- =====================================================
-- PLAYER TAB
-- =====================================================
PlayerTab:AddSlider({
    Name = "Walk Speed",
    Min = 16, Max = 500, Default = 16,
    Increment = 1, ValueName = "speed",
    Callback = function(v)
        _G.HackedWalkSpeed = v
        local hum = Character and Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})

PlayerTab:AddSlider({
    Name = "Jump Power",
    Min = 50, Max = 500, Default = 50,
    Increment = 5, ValueName = "power",
    Callback = function(v)
        local hum = Character and Character:FindFirstChild("Humanoid")
        if hum then hum.JumpPower = v end
    end
})

PlayerTab:AddToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(v)
        task.spawn(function()
            while v do
                task.wait(0.1)
                local hum = Character and Character:FindFirstChild("Humanoid")
                if hum then hum.Health = math.huge hum.MaxHealth = math.huge end
            end
        end)
    end
})

local noclipOn = false
PlayerTab:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(v)
        noclipOn = v
        task.spawn(function()
            while noclipOn do
                task.wait()
                if Character then
                    for _, p in ipairs(Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end
        end)
    end
})

local infiniteJumpConn
PlayerTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(v)
        if v then
            infiniteJumpConn = UserInputService.JumpRequest:Connect(function()
                local hum = Character and Character:FindFirstChild("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        else
            if infiniteJumpConn then infiniteJumpConn:Disconnect() end
        end
    end
})

-- Fly
local flyEnabled = false
PlayerTab:AddToggle({
    Name = "Fly",
    Default = false,
    Callback = function(v)
        flyEnabled = v
        local hrp = Character and Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if v then
            local bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(9e9,9e9,9e9); bg.P = 9e4
            local bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.P = 9e4
            task.spawn(function()
                while flyEnabled do
                    task.wait()
                    local cam = workspace.CurrentCamera
                    local spd = (Character:FindFirstChild("Humanoid") and Character.Humanoid.WalkSpeed or 16)
                    local fwd = cam.CFrame.LookVector
                    local move = Vector3.new(0,0,0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + fwd end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - fwd end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space)      then move = move + Vector3.new(0,1,0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)  then move = move - Vector3.new(0,1,0) end
                    bv.Velocity = move * spd * 2
                    bg.CFrame   = cam.CFrame
                end
                if hrp:FindFirstChildOfClass("BodyGyro")     then hrp:FindFirstChildOfClass("BodyGyro"):Destroy()     end
                if hrp:FindFirstChildOfClass("BodyVelocity") then hrp:FindFirstChildOfClass("BodyVelocity"):Destroy() end
            end)
        end
    end
})

-- =====================================================
-- VISUALS TAB
-- =====================================================
local espTransparency = 0.4
local BillboardESPs  = {}
local ChamsESPs      = {}
local ESPConnections = {}
local ESPEnabled     = false
local ChamsEnabled   = false
local customFont = Font.new("rbxassetid://16658246179", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local function createBillboardESP(plr)
    if BillboardESPs[plr] or plr == LocalPlayer then return end
    if not plr.Character or not plr.Character:FindFirstChild("Head") then return end
    local gui = Instance.new("BillboardGui")
    gui.Name = "Billboard_ESP"
    gui.Adornee = plr.Character.Head
    gui.Parent  = plr.Character.Head
    gui.Size    = UDim2.new(0,100,0,40)
    gui.AlwaysOnTop = true
    gui.StudsOffset = Vector3.new(0,2,0)
    local lbl = Instance.new("TextLabel", gui)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.TextStrokeTransparency = 0.5
    lbl.TextScaled = true
    lbl.FontFace = customFont
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not plr.Character or not plr.Character:FindFirstChild("Humanoid") then
            gui:Destroy()
            if conn then conn:Disconnect() end
            BillboardESPs[plr] = nil
            ESPConnections[plr] = nil
            return
        end
        local hp = math.floor(plr.Character.Humanoid.Health / math.max(plr.Character.Humanoid.MaxHealth,1) * 100)
        lbl.Text = plr.Name .. " | " .. hp .. "%"
    end)
    BillboardESPs[plr] = gui
    ESPConnections[plr] = conn
end

local function createChamsESP(plr)
    if ChamsESPs[plr] or plr == LocalPlayer then return end
    if not plr.Character then return end
    local folder = Instance.new("Folder")
    folder.Name = "Chams_ESP"
    folder.Parent = CoreGui
    ChamsESPs[plr] = folder
    for _, part in pairs(plr.Character:GetChildren()) do
        if part:IsA("BasePart") then
            local box = Instance.new("BoxHandleAdornment")
            box.Adornee = part
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Size  = part.Size
            box.Transparency = espTransparency
            box.Color = BrickColor.new("Bright red")
            box.Parent = folder
        end
    end
end

local function cleanupBillboardESP()
    for _, g in pairs(BillboardESPs) do if g then g:Destroy() end end
    for _, c in pairs(ESPConnections) do if c then c:Disconnect() end end
    BillboardESPs = {}; ESPConnections = {}
end

local function cleanupChamsESP()
    for _, f in pairs(ChamsESPs) do if f then f:Destroy() end end
    ChamsESPs = {}
end

local function handlePlayerESP(plr)
    if ESPEnabled  then createBillboardESP(plr) end
    if ChamsEnabled then createChamsESP(plr) end
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if ESPEnabled  then createBillboardESP(plr) end
        if ChamsEnabled then createChamsESP(plr) end
    end)
end

VisualTab:AddToggle({ Name = "Player ESP (Billboard)", Default = false, Callback = function(v)
    ESPEnabled = v
    if not v then cleanupBillboardESP()
    else for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then createBillboardESP(p) end end end
end})

VisualTab:AddToggle({ Name = "Player Chams", Default = false, Callback = function(v)
    ChamsEnabled = v
    if not v then cleanupChamsESP()
    else for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then createChamsESP(p) end end end
end})

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then handlePlayerESP(p) end end
Players.PlayerAdded:Connect(handlePlayerESP)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255,255,255)
FOVCircle.Transparency = 1
FOVCircle.Thickness = 1
FOVCircle.Filled = false
local FOVRadius = 100
RunService.RenderStepped:Connect(function()
    if FOVCircle.Visible then
        FOVCircle.Radius = FOVRadius
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end
end)

VisualTab:AddToggle({ Name = "FOV Circle", Default = false, Callback = function(v) FOVCircle.Visible = v end })
VisualTab:AddSlider({ Name = "FOV Radius", Min = 10, Max = 500, Default = 100, Increment = 5, ValueName = "px",
    Callback = function(v) FOVRadius = v end })

-- =====================================================
-- MISC TAB
-- =====================================================
MiscTab:AddButton({ Name = "Infinite Yield", Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end})

MiscTab:AddButton({ Name = "Server Hop", Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/oofid/SynapseXScriptHub/main/serverhop.lua"))()
end})

MiscTab:AddButton({ Name = "Anti-AFK", Callback = function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end})

MiscTab:AddButton({ Name = "Emote GUI", Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dimension-sources/random-scripts-i-found/refs/heads/main/r6%20animations"))()
end})

OrionLib:Init()
print("99 Nights Hub carregado! | PudimHub")
