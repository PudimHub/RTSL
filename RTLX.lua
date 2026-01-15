-- [[ PUDIM HUB - 99 DIAS NA FLORESTA ]]
-- Versão 10.0 - INTERFACE ORIGINAL COM MELHORIAS VOIDWARE (15/01/2026)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local startTime = os.time()
local diamondsCollectedSession = 0

---------------------------------------------------------
-- [ CONFIGURAÇÃO E ESTADO ]
---------------------------------------------------------
local Config = {
    AnimalFarm = false, AnimalFarmRange = 50,
    TreeAura = false, TreeAuraRange = 50,
    Speed = 16, Jump = 50, Fly = false,
    AutoFarmChests = false, AutoFarmMode = 1, SavedPosition = nil,
    NoFog = false, FullBright = false,
    AutoHeal = false, AutoHealHealth = 40,
    AutoExplore = false,
    PlayerTracers = false,
    SelectedChest = nil,
    RemoveChestAnimation = false,
    ESP = {
        Children = false, Animals = false,
        Fruits = false, Chests = false, Wood = false, Trees = false
    }
}

-- ITENS ATUALIZADOS PÓS 10/01/2026
local Targets = {
    PassiveAnimals = {"Bunny", "Deer", "Frog", "Kiwi", "Arctic Fox", "Pet Bunny", "Pet Frog", "Pet Kiwi"},
    Fruits = {"Apple", "Berry", "Carrot", "Pumpkin", "Corn", "Chili", "Steak", "Ribs", "Morsel", "Cooked Morsel", "Cooked Steak", "Cooked Ribs"},
    Wood = {"Log", "Stick", "Super Log"},
    Combustion = {"Coal", "Charcoal", "Gasoline", "Fuel"},
    Seeds = {"Seed Pack", "Carrot Seeds", "Corn Seeds", "Pumpkin Seeds", "Berry Seeds", "Apple Seeds", "Chili Seeds"},
    Medical = {"Medkit", "Bandage", "First Aid Kit", "Trim Kit"},
    Tools = {
        "Old Axe", "Good Axe", "Strong Axe", 
        "Old Rod", "Good Rod", "Strong Rod", 
        "Old Flute", "Good Flute", "Strong Flute",
        "Flashlight", "Strong Flashlight", 
        "Air Rifle", "Revolver", "Crossbow", 
        "Spear", "Morningstar", "Raygun", 
        "Laser Sword", "Laser Cannon", "Poison Spear", "Blowpipe", "Obsidiron Hammer",
        -- NOVOS ITENS 2026
        "Plasma Cutter", "Nano Drill", "Quantum Scanner", "Hologram Projector"
    },
    Armor = {
        "Iron Body", "Obsidiron Body", "Alien Armor", "Vampire Cloak", 
        "Frog Boots", "Obsidiron Boots", "Iron Boots", "Warm Clothing",
        -- NOVOS ITENS 2026
        "Nano Suit", "Quantum Armor", "Hologram Cloak", "Plasma Shield"
    },
    Structures = {"Anvil Base", "Chair Set", "Laser Fence Blueprint", "Campfire", "Bank", "Abandoned Animal Shelter", "Fishing Cabin", "Upgrade Cabin", "Flute Tent", "Daily Quest Machine", "Cauldron", "Mother Tree", "Pelt Trader", "Furniture Trader", "Tool Workshop", "Warm Clothing Shop", "Portal", "Statue", "Altar"},
    Chests = {"Chest", "Rare Chest", "Epic Chest", "Legendary Chest", "Treasure Chest", "Supply Crate"},
    -- NOVAS CATEGORIAS 2026
    Technology = {
        "Nano Core", "Quantum Cell", "Plasma Crystal", 
        "Hologram Disc", "Data Chip", "Energy Module",
        "AI Processor", "Neural Link", "Quantum Battery"
    },
    Minerals = {
        "Iron Ore", "Gold Ingot", "Diamond", "Emerald",
        "Plasma Fragment", "Quantum Ore", "Nano Particle",
        "Alien Crystal", "Void Stone", "Star Metal"
    },
    SpecialItems = {
        "Time Crystal", "Space Fragment", "Reality Shard",
        "Dimension Key", "Portal Stone", "Warp Device",
        "Clone Sample", "DNA Extract", "Evolution Core"
    }
}

-- SISTEMA DE ARMAZENAMENTO DE SELEÇÕES
local SelectedItems = {
    Wood = {},
    Tools = {},
    Armor = {},
    Technology = {},
    Minerals = {},
    Medical = {},
    Fruits = {},
    SpecialItems = {},
    Seeds = {},
    Combustion = {}
}

local AllItemsList = {"Lost Child"}
for _, list in pairs({Targets.Fruits, Targets.Wood, Targets.Combustion, Targets.Seeds, Targets.Medical, Targets.Tools, Targets.Armor, Targets.Technology, Targets.Minerals, Targets.SpecialItems}) do
    for _, item in pairs(list) do table.insert(AllItemsList, item) end
end

---------------------------------------------------------
-- [ UTILITÁRIOS ]
---------------------------------------------------------
local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

local serverLoc = "BR"
task.spawn(function()
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("http://ip-api.com/json/")).countryCode
    end)
    if success then serverLoc = result end
end)

local function notify(title, text, duration)
    local notification = Instance.new("Frame", screenGui)
    notification.Size = UDim2.new(0, 250, 0, 60)
    notification.Position = UDim2.new(1, 10, 0.8, 0)
    notification.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", notification).Color = Color3.fromRGB(255, 60, 60)
    local t = Instance.new("TextLabel", notification)
    t.Size = UDim2.new(1, 0, 0, 25)
    t.Text = title
    t.TextColor3 = Color3.new(1, 1, 1)
    t.Font = Enum.Font.SourceSansBold
    t.BackgroundTransparency = 1
    local m = Instance.new("TextLabel", notification)
    m.Size = UDim2.new(1, 0, 0, 35)
    m.Position = UDim2.new(0, 0, 0, 25)
    m.Text = text
    m.TextColor3 = Color3.fromRGB(200, 200, 200)
    m.Font = Enum.Font.SourceSans
    m.BackgroundTransparency = 1
    TweenService:Create(notification, TweenInfo.new(0.5), {Position = UDim2.new(1, -260, 0.8, 0)}):Play()
    task.delay(duration or 3, function()
        TweenService:Create(notification, TweenInfo.new(0.5), {Position = UDim2.new(1, 10, 0.8, 0)}):Play()
        task.wait(0.5)
        notification:Destroy()
    end)
end

local function teleportTo(pos)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
    end
end

local function findObject(name)
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == name and (v:IsA("BasePart") or v:IsA("Model")) then
            return v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildOfClass("BasePart")) or v
        end
    end
    return nil
end

---------------------------------------------------------
-- [ LÓGICA DE DIAMANTES ]
---------------------------------------------------------
local function getPlayerDiamonds()
    local leaderstats = player:FindFirstChild("leaderstats") or player:FindFirstChild("Data") or player:FindFirstChild("Stats")
    local diamonds = leaderstats and (leaderstats:FindFirstChild("Diamonds") or leaderstats:FindFirstChild("Gems") or leaderstats:FindFirstChild("Diamantes") or leaderstats:FindFirstChild("Diamond"))
    if not diamonds then
        diamonds = player:FindFirstChild("Diamonds", true) or player:FindFirstChild("Gems", true)
    end
    return diamonds and diamonds.Value or 0
end

local initialDiamonds = getPlayerDiamonds()
task.spawn(function()
    while task.wait(1) do
        local current = getPlayerDiamonds()
        if current > initialDiamonds then
            diamondsCollectedSession = current - initialDiamonds
        elseif current < initialDiamonds then
            initialDiamonds = current
        end
    end
end)

---------------------------------------------------------
-- [ LÓGICA DE TRACERS & HITBOX ]
---------------------------------------------------------
local playerVisuals = {}
local function createVisuals(p)
    if p == player then return end
    if playerVisuals[p] then return end
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(255, 0, 0)
    tracer.Thickness = 1
    tracer.Transparency = 1
    local hitbox = Instance.new("BoxHandleAdornment")
    hitbox.Name = "PudimHitbox"
    hitbox.AlwaysOnTop = true
    hitbox.ZIndex = 10
    hitbox.Size = Vector3.new(4, 6, 4)
    hitbox.Transparency = 0.7
    hitbox.Color3 = Color3.fromRGB(255, 0, 0)
    hitbox.Parent = CoreGui
    local billboard = Instance.new("BillboardGui", CoreGui)
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 5000
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 14
    playerVisuals[p] = {Tracer = tracer, Hitbox = hitbox, Billboard = billboard, Label = label}
end

local function updateVisuals()
    if not Config.PlayerTracers then
        for _, v in pairs(playerVisuals) do
            v.Tracer.Visible = false
            v.Hitbox.Adornee = nil
            v.Billboard.Enabled = false
        end
        return
    end
    local myChar = player.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    for p, v in pairs(playerVisuals) do
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local vector, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)
            local myVector, _ = workspace.CurrentCamera:WorldToViewportPoint(myHrp.Position)
            if onScreen then
                v.Tracer.From = Vector2.new(myVector.X, myVector.Y)
                v.Tracer.To = Vector2.new(vector.X, vector.Y)
                v.Tracer.Visible = true
            else
                v.Tracer.Visible = false
            end
            v.Hitbox.Adornee = hrp
            v.Billboard.Adornee = hrp
            v.Billboard.Enabled = true
            local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
            v.Label.Text = string.format("%s\nDist: %d | Vida: %d/%d", p.DisplayName, dist, math.floor(hum.Health), math.floor(hum.MaxHealth))
        else
            v.Tracer.Visible = false
            v.Hitbox.Adornee = nil
            v.Billboard.Enabled = false
        end
    end
end
Players.PlayerAdded:Connect(createVisuals)
Players.PlayerRemoving:Connect(function(p)
    if playerVisuals[p] then
        playerVisuals[p].Tracer:Remove()
        playerVisuals[p].Hitbox:Destroy()
        playerVisuals[p].Billboard:Destroy()
        playerVisuals[p] = nil
    end
end)
for _, p in pairs(Players:GetPlayers()) do createVisuals(p) end
RunService.Heartbeat:Connect(updateVisuals)

---------------------------------------------------------
-- [ LÓGICA DE DANO E CURA ]
---------------------------------------------------------
local function dealDamage(target, isTree)
    local char = player.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not target or not tool then return end
    pcall(function()
        tool:Activate()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
        local eventNames = isTree and {"AxeHit", "AxeEvent", "TreeHit", "Chop", "Harvest", "WoodEvent", "ChopTree"} or {"Damage", "Hit", "Attack", "SwordHit", "WeaponHit", "CombatEvent"}
        for _, name in pairs(eventNames) do
            local event = remotes:FindFirstChild(name)
            if event and event:IsA("RemoteEvent") then event:FireServer(target) if isTree then event:FireServer(target, "Axe") end end
        end
    end)
end

local function useMedicalItem()
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    if not char or not backpack then return end
    for _, itemName in pairs(Targets.Medical) do
        local item = backpack:FindFirstChild(itemName) or char:FindFirstChild(itemName)
        if item and item:IsA("Tool") then
            item.Parent = char
            task.wait(0.05)
            item:Activate()
            task.wait(0.1)
            item.Parent = backpack
            return true
        end
    end
    return false
end

local function performSuperHeal()
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health >= hum.MaxHealth then return end
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
        for _, name in pairs({"Heal", "RestoreHealth", "Regenerate", "AddHealth"}) do
            local event = remotes:FindFirstChild(name)
            if event and event:IsA("RemoteEvent") then event:FireServer(hum.MaxHealth) end
        end
        useMedicalItem()
        hum.Health = hum.MaxHealth
    end)
end

---------------------------------------------------------
-- [ BRING & FARM ]
---------------------------------------------------------
local function bringObjects(targetNames, customPos)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp and not customPos then return end
    local targetPos = customPos or (hrp.CFrame + Vector3.new(0, 0, 5))
    local descendants = workspace:GetDescendants()
    for i = 1, #descendants do
        local obj = descendants[i]
        local isTarget = false
        for j = 1, #targetNames do if obj.Name == targetNames[j] then isTarget = true break end end
        if isTarget then
            if obj:IsA("BasePart") then obj.CFrame = typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos)
            elseif obj:IsA("Model") and obj.PrimaryPart then obj:SetPrimaryPartCFrame(typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos)) end
        end
        if i % 100 == 0 then task.wait() end
    end
end

local function autoFarmChests()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    Config.SavedPosition = hrp.CFrame
    local campfire = workspace:FindFirstChild("Campfire", true)
    local campPos = campfire and (campfire.PrimaryPart and campfire.PrimaryPart.Position or campfire.Position) or Vector3.new(0,0,0)
    local safePos = (Config.AutoFarmMode == 1 and campPos ~= Vector3.new(0,0,0)) and campPos or Config.SavedPosition.Position
    while Config.AutoFarmChests do
        local found = false
        local descendants = workspace:GetDescendants()
        for i = 1, #descendants do
            if not Config.AutoFarmChests then break end
            local obj = descendants[i]
            local isChest = false
            for j = 1, #Targets.Chests do if obj.Name == Targets.Chests[j] or obj.Name:lower():find("chest") then isChest = true break end end
            if isChest and (obj:IsA("Model") or obj:IsA("BasePart")) then
                local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position) or obj.Position
                if pos then
                    found = true
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    task.wait(0.1)
                    
                    local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
                    for _, n in pairs({"OpenChest", "Interact", "ChestEvent", "ClaimChest"}) do
                        local e = remotes:FindFirstChild(n)
                        if e then 
                            if Config.RemoveChestAnimation then
                                e:FireServer(obj)
                            else
                                e:FireServer(obj, true)
                                task.wait(1)
                                e:FireServer(obj, false)
                            end
                        end
                    end
                    
                    local p = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("Prompt", true)
                    if p and p:IsA("ProximityPrompt") then fireproximityprompt(p) end
                    
                    task.wait(0.1)
                    bringObjects(AllItemsList, safePos)
                end
            end
            if i % 200 == 0 then task.wait() end
        end
        if not found then task.wait(1) end
        task.wait(0.1)
    end
    if Config.SavedPosition then hrp.CFrame = Config.SavedPosition end
end

local function autoExplore()
    while Config.AutoExplore do
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local randomPos = hrp.Position + Vector3.new(math.random(-200, 200), 0, math.random(-200, 200))
            hrp.CFrame = CFrame.new(randomPos + Vector3.new(0, 50, 0))
        end
        task.wait(3)
    end
end

---------------------------------------------------------
-- [ ESP ]
---------------------------------------------------------
local espObjects = {}
local function updateESP()
    local anyEsp = false
    for _, v in pairs(Config.ESP) do if v then anyEsp = true break end end
    
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local descendants = workspace:GetDescendants()
    local activeESP = {}

    for i = 1, #descendants do
        local obj = descendants[i]
        local name, color, text, shouldShow = obj.Name, nil, nil, false
        local root = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or (obj:IsA("BasePart") and obj)
        
        if root and root.Parent and root.Parent ~= player.Character then
            local espTag = root:FindFirstChild("PudimESP")
            
            if Config.ESP.Children and name == "Lost Child" then shouldShow, color, text = true, Color3.new(1,1,1), "👶 Criança"
            elseif Config.ESP.Animals then 
                local isMob = false
                for _, a in pairs(Targets.PassiveAnimals) do if name == a then isMob = true color = Color3.new(0.5,1,0.5) break end end
                if isMob then shouldShow, text = true, "👾 " .. name end
            elseif Config.ESP.Fruits then for _, f in pairs(Targets.Fruits) do if name == f then shouldShow, color, text = true, Color3.new(1,0.7,0.7), "🍎 " .. f break end end
            elseif Config.ESP.Chests then for _, c in pairs(Targets.Chests) do if name == c or name:lower():find("chest") then shouldShow, color, text = true, Color3.new(1,0.8,0), "📦 " .. name break end end
            elseif Config.ESP.Wood then for _, w in pairs(Targets.Wood) do if name == w then shouldShow, color, text = true, Color3.new(0.8,0.7,0.5), "🪵 " .. w break end end
            elseif Config.ESP.Trees and (name:lower():find("tree") or name:lower():find("trunk")) then shouldShow, color, text = true, Color3.new(0.1,0.5,0.1), "🌲 Árvore" end
            
            if shouldShow and anyEsp then
                if not espTag then
                    espTag = Instance.new("BillboardGui", root)
                    espTag.Name = "PudimESP"
                    espTag.Size, espTag.AlwaysOnTop, espTag.MaxDistance = UDim2.new(0,150,0,30), true, 1500
                    local l = Instance.new("TextLabel", espTag)
                    l.Name = "Label"
                    l.Size, l.BackgroundTransparency, l.Font, l.TextSize, l.TextStrokeTransparency = UDim2.new(1,0,1,0), 1, Enum.Font.SourceSansBold, 14, 0
                end
                
                local label = espTag:FindFirstChild("Label")
                if label then
                    local dist = math.floor((hrp.Position - root.Position).Magnitude)
                    label.Text = text .. " (" .. dist .. "m)"
                    label.TextColor3 = color
                end
                espTag.Enabled = true
                activeESP[espTag] = true
            elseif espTag then
                espTag.Enabled = false
            end
        end
        if i % 300 == 0 then task.wait() end
    end
    
    for _, child in pairs(workspace:GetDescendants()) do
        local espTag = child:FindFirstChild("PudimESP")
        if espTag and not activeESP[espTag] then
            espTag:Destroy()
        end
    end
end

---------------------------------------------------------
-- [ INTERFACE - CORE ]
---------------------------------------------------------
local Color_NavyStrong = Color3.fromRGB(20, 30, 50)
local Color_NavyWeak = Color3.fromRGB(15, 20, 35)
local Color_TopBar = Color3.fromRGB(10, 15, 25)
local Color_RedStrong = Color3.fromRGB(255, 60, 60)

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "PudimHub_99Days"
screenGui.ResetOnSpawn = false

-- SPLASH SCREEN
local splash1 = Instance.new("Frame", screenGui)
splash1.Size, splash1.BackgroundColor3, splash1.BackgroundTransparency, splash1.ZIndex = UDim2.new(1, 0, 1, 0), Color3.fromRGB(10, 10, 10), 1, 20
local splashTitle = Instance.new("TextLabel", splash1)
splashTitle.Size, splashTitle.Position, splashTitle.BackgroundTransparency, splashTitle.Text, splashTitle.TextColor3, splashTitle.Font, splashTitle.TextSize, splashTitle.TextTransparency = UDim2.new(1, 0, 0, 100), UDim2.new(0, 0, 0.4, 0), 1, "PUDIM HUB", Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 100, 1
local splash2 = Instance.new("Frame", screenGui)
splash2.Size, splash2.BackgroundColor3, splash2.BackgroundTransparency, splash2.ZIndex, splash2.Visible = UDim2.new(1, 0, 1, 0), Color3.fromRGB(10, 10, 10), 1, 19, false
local splashMenu = Instance.new("Frame", splash2)
splashMenu.Size, splashMenu.Position, splashMenu.BackgroundColor3 = UDim2.new(0, 400, 0, 100), UDim2.new(0.5, -200, 0.5, -50), Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", splashMenu).CornerRadius = UDim.new(0, 12)
local splashInfo1 = Instance.new("TextLabel", splashMenu)
splashInfo1.Size, splashInfo1.Position, splashInfo1.BackgroundTransparency, splashInfo1.Text, splashInfo1.TextColor3, splashInfo1.Font, splashInfo1.TextSize, splashInfo1.TextTransparency = UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0.1, 0), 1, "PudimHub - 99 dias na floresta | Roblox", Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 22, 1
local splashInfo2 = Instance.new("TextLabel", splashMenu)
splashInfo2.Size, splashInfo2.Position, splashInfo2.BackgroundTransparency, splashInfo2.Text, splashInfo2.TextColor3, splashInfo2.Font, splashInfo2.TextSize, splashInfo2.TextTransparency = UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0.5, 0), 1, "15/01/2026 | Atualizado", Color3.fromRGB(200, 200, 200), Enum.Font.SourceSans, 18, 1

-- MAIN FRAME
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size, mainFrame.Position, mainFrame.BackgroundColor3, mainFrame.BorderSizePixel, mainFrame.Visible, mainFrame.ClipsDescendants = UDim2.new(0, 500, 0, 350), UDim2.new(0.5, -250, 0.5, -175), Color_NavyWeak, 0, false, true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- TOP BAR
local topBar = Instance.new("Frame", mainFrame)
topBar.Size, topBar.BackgroundColor3, topBar.BorderSizePixel = UDim2.new(1, 0, 0, 40), Color_TopBar, 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)
local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size, titleLabel.Position, titleLabel.BackgroundTransparency, titleLabel.Text, titleLabel.TextColor3, titleLabel.Font, titleLabel.TextSize, titleLabel.TextXAlignment = UDim2.new(1, -100, 1, 0), UDim2.new(0, 15, 0, 0), 1, "PUDIM HUB - 99 DIAS", Color3.fromRGB(255, 255, 255), Enum.Font.SourceSansBold, 18, Enum.TextXAlignment.Left

-- ARRASTAR LOGIC
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
topBar.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- CONTENT AREA
local contentArea = Instance.new("Frame", mainFrame)
contentArea.Size, contentArea.Position, contentArea.BackgroundColor3, contentArea.BorderSizePixel = UDim2.new(1, 0, 1, -100), UDim2.new(0, 0, 0, 40), Color_NavyWeak, 0

-- TAB LIST (Movido para a parte inferior)
local tabList = Instance.new("Frame", mainFrame)
tabList.Size, tabList.Position, tabList.BackgroundColor3, tabList.BorderSizePixel = UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 1, -60), Color_NavyStrong, 0
Instance.new("UICorner", tabList).CornerRadius = UDim.new(0, 10)
local tabLayout = Instance.new("UIListLayout", tabList)
tabLayout.Padding, tabLayout.SortOrder = UDim.new(0, 5), Enum.SortOrder.LayoutOrder
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- PAGES
local pages = Instance.new("Frame", contentArea)
pages.Size, pages.Position, pages.BackgroundColor3, pages.BorderSizePixel = UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Color_NavyWeak, 0
local pageLayout = Instance.new("UIListLayout", pages)
pageLayout.Padding, pageLayout.SortOrder = UDim.new(0, 5), Enum.SortOrder.LayoutOrder
pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- POPUP FRAME (para modos de farm)
local popupFrame = Instance.new("Frame", mainFrame)
popupFrame.Size, popupFrame.BackgroundColor3, popupFrame.Visible, popupFrame.ZIndex = UDim2.new(0, 150, 0, 80), Color3.fromRGB(30, 40, 60), false, 100
Instance.new("UICorner", popupFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", popupFrame).Color = Color3.fromRGB(60, 80, 120)
local popupList = Instance.new("ScrollingFrame", popupFrame)
popupList.Size, popupList.Position, popupList.BackgroundTransparency, popupList.ScrollBarThickness, popupList.CanvasSize = UDim2.new(1, -10, 1, -10), UDim2.new(0, 5, 0, 5), 1, 4, UDim2.new(0, 0, 0, 0)
local popupLayout = Instance.new("UIListLayout", popupList)
popupLayout.Padding = UDim.new(0, 5)
popupList.CanvasSize = UDim2.new(0, 0, 0, popupLayout.AbsoluteContentSize.Y + 10)

-- BOTTOM BAR
local bottomBar = Instance.new("Frame", mainFrame)
bottomBar.Size, bottomBar.Position, bottomBar.BackgroundColor3, bottomBar.BorderSizePixel = UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 1, -30), Color_TopBar, 0
local bottomLabel = Instance.new("TextLabel", bottomBar)
bottomLabel.Size, bottomLabel.Position, bottomLabel.BackgroundTransparency, bottomLabel.Text, bottomLabel.TextColor3, bottomLabel.Font, bottomLabel.TextSize, bottomLabel.TextXAlignment = UDim2.new(1, -100, 1, 0), UDim2.new(0, 15, 0, 0), 1, "Pudim Hub - v10.0", Color3.fromRGB(150, 150, 150), Enum.Font.SourceSans, 14, Enum.TextXAlignment.Left

-- MOBILE TOGGLE
local mobileToggle = Instance.new("TextButton", screenGui)
mobileToggle.Size, mobileToggle.Position, mobileToggle.BackgroundColor3, mobileToggle.Text, mobileToggle.TextColor3, mobileToggle.Font, mobileToggle.TextSize, mobileToggle.Visible = UDim2.new(0, 100, 0, 30), UDim2.new(0.5, -50, 0, -40), Color3.fromRGB(20, 30, 50), "Pudim Hub", Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 16, false
Instance.new("UICorner", mobileToggle).CornerRadius = UDim.new(0, 6)

---------------------------------------------------------
-- [ INTERFACE - COMPONENTS ]
---------------------------------------------------------
local tabs = {}
local function createTab(name, icon)
    local btn = Instance.new("TextButton", tabList)
    btn.Size, btn.BackgroundColor3, btn.Text, btn.TextColor3, btn.Font, btn.TextSize, btn.LayoutOrder = UDim2.new(0, 70, 1, -10), Color_NavyWeak, icon, Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 24, #tabList:GetChildren()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local tooltip = Instance.new("TextLabel", btn)
    tooltip.Size, tooltip.Position, tooltip.BackgroundTransparency, tooltip.Text, tooltip.TextColor3, tooltip.Font, tooltip.TextSize = UDim2.new(0, 100, 0, 20), UDim2.new(0.5, -50, -1, -5), 1, name, Color3.new(1, 1, 1), Enum.Font.SourceSans, 14
    tooltip.Visible = false
    btn.MouseEnter:Connect(function() tooltip.Visible = true end)
    btn.MouseLeave:Connect(function() tooltip.Visible = false end)
    local page = Instance.new("ScrollingFrame", pages)
    page.Size, page.BackgroundTransparency, page.ScrollBarThickness, page.CanvasSize, page.Visible = UDim2.new(1, 0, 1, 0), 1, 4, UDim2.new(0, 0, 0, 0), false
    local layout = Instance.new("UIListLayout", page)
    layout.Padding, layout.SortOrder, layout.HorizontalAlignment = UDim.new(0, 5), Enum.SortOrder.LayoutOrder, Enum.HorizontalAlignment.Center
    page.ChildAdded:Connect(function() page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5) end)
    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color_NavyWeak
            t.Btn.TextColor3 = Color3.new(1, 1, 1)
            t.Tooltip.TextColor3 = Color3.new(1, 1, 1)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color_NavyStrong
        btn.TextColor3 = Color_RedStrong
        tooltip.TextColor3 = Color_RedStrong
    end)
    tabs[name] = {Page = page, Btn = btn, Tooltip = tooltip}
    if #tabList:GetChildren() == 2 then page.Visible = true btn.BackgroundColor3 = Color_NavyStrong btn.TextColor3 = Color_RedStrong tooltip.TextColor3 = Color_RedStrong end
    return page
end

local function createSection(parent, title)
    local label = Instance.new("TextLabel", parent)
    label.Size, label.BackgroundTransparency, label.Text, label.TextColor3, label.Font, label.TextSize, label.TextXAlignment = UDim2.new(1, 0, 0, 25), 1, "  " .. title:upper(), Color3.fromRGB(180, 200, 255), Enum.Font.SourceSansBold, 12, Enum.TextXAlignment.Left
end

local function createToggle(parent, text, callback, initialState)
    local frame = Instance.new("Frame", parent)
    frame.Size, frame.BackgroundColor3 = UDim2.new(1, -10, 0, 40), Color3.fromRGB(30, 45, 70)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local label = Instance.new("TextLabel", frame)
    label.Size, label.Position, label.BackgroundTransparency, label.Text, label.TextColor3, label.Font, label.TextSize, label.TextXAlignment = UDim2.new(1, -60, 1, 0), UDim2.new(0, 15, 0, 0), 1, text, Color3.new(1, 1, 1), Enum.Font.SourceSans, 16, Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", frame)
    btn.Size, btn.Position, btn.BackgroundColor3, btn.Text = UDim2.new(0, 40, 0, 20), UDim2.new(1, -50, 0.5, -10), initialState and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 65, 90), initialState and "✓" or ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local circle = Instance.new("Frame", btn)
    circle.Size, circle.Position, circle.BackgroundColor3 = UDim2.new(0, 16, 0, 16), initialState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), Color3.new(1, 1, 1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    local state = initialState or false
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 65, 90), Text = state and "✓" or ""}):Play()
        TweenService:Create(circle, TweenInfo.new(0.3), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
    return btn, state
end

local function createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size, frame.BackgroundColor3 = UDim2.new(1, -10, 0, 65), Color3.fromRGB(30, 45, 70)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local label = Instance.new("TextLabel", frame)
    label.Size, label.Position, label.BackgroundTransparency, label.Text, label.TextColor3, label.Font, label.TextSize, label.TextXAlignment = UDim2.new(1, -20, 0, 30), UDim2.new(0, 15, 0, 5), 1, text .. ": " .. default, Color3.new(1, 1, 1), Enum.Font.SourceSans, 16, Enum.TextXAlignment.Left
    local sliderBar = Instance.new("TextButton", frame)
    sliderBar.Size, sliderBar.Position, sliderBar.BackgroundColor3, sliderBar.Text = UDim2.new(1, -30, 0, 10), UDim2.new(0, 15, 0, 40), Color3.fromRGB(50, 65, 90), ""
    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", sliderBar)
    fill.Size, fill.BackgroundColor3 = UDim2.new((default - min) / (max - min), 0, 1, 0), Color3.fromRGB(0, 150, 255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local function update(input)
        local p = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * p)
        fill.Size, label.Text = UDim2.new(p, 0, 1, 0), text .. ": " .. v
        callback(v)
    end
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local move, up
            move = UserInputService.InputChanged:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then update(i) end end)
            up = UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then move:Disconnect() up:Disconnect() end end)
            update(input)
        end
    end)
end

local function createButton(parent, text, callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size, btn.BackgroundColor3, btn.Text, btn.TextColor3, btn.Font, btn.TextSize, btn.ZIndex = UDim2.new(1, -10, 0, 35), Color3.fromRGB(40, 60, 90), text, Color3.new(1, 1, 1), Enum.Font.SourceSans, 16, parent.ZIndex
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function createInput(parent, placeholder, callback)
    local box = Instance.new("TextBox", parent)
    box.Size, box.BackgroundColor3, box.PlaceholderText, box.Text, box.TextColor3, box.Font, box.TextSize = UDim2.new(1, -10, 0, 35), Color3.fromRGB(25, 35, 55), placeholder, "", Color3.new(1, 1, 1), Enum.Font.SourceSans, 14
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    box.FocusLost:Connect(function(enter) if enter then callback(box.Text) end end)
    return box
end

-- FUNÇÃO PARA CRIAR DROPDOWN COM SELEÇÃO MÚLTIPLA (ESTILO VOIDWARE)
local function createMultiSelectDropdown(parent, categoryName, items)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -10, 0, 70)
    frame.BackgroundColor3 = Color3.fromRGB(30, 45, 70)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    -- LABEL
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 0, 25)
    label.Position = UDim2.new(0, 15, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = "Selecionar " .. categoryName .. ":"
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    -- CAMPO DE SELEÇÃO
    local selectionField = Instance.new("TextButton", frame)
    selectionField.Size = UDim2.new(0.7, -10, 0, 25)
    selectionField.Position = UDim2.new(0, 15, 0, 30)
    selectionField.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
    selectionField.Text = "Selecionar itens..."
    selectionField.TextColor3 = Color3.fromRGB(150, 160, 180)
    selectionField.TextSize = 14
    selectionField.Font = Enum.Font.SourceSans
    selectionField.TextXAlignment = Enum.TextXAlignment.Left
    selectionField.TextPadding = UDim2.new(0, 10, 0, 0)
    Instance.new("UICorner", selectionField).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", selectionField).Color = Color3.fromRGB(40, 50, 70)
    
    -- SETA
    local arrow = Instance.new("TextLabel", selectionField)
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -25, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Color3.fromRGB(150, 160, 180)
    arrow.Font = Enum.Font.SourceSans
    arrow.TextSize = 12
    arrow.TextXAlignment = Enum.TextXAlignment.Right
    
    -- BOTÃO PEGAR
    local getBtn = Instance.new("TextButton", frame)
    getBtn.Size = UDim2.new(0.3, -10, 0, 25)
    getBtn.Position = UDim2.new(0.7, 5, 0, 30)
    getBtn.BackgroundColor3 = Color3.fromRGB(40, 60, 90)
    getBtn.Text = "🔥 PEGAR"
    getBtn.TextColor3 = Color3.new(1, 1, 1)
    getBtn.TextSize = 14
    getBtn.Font = Enum.Font.SourceSans
    Instance.new("UICorner", getBtn).CornerRadius = UDim.new(0, 4)
    
    -- POPUP DE SELEÇÃO
    local popup = Instance.new("Frame", screenGui)
    popup.Name = "Popup_" .. categoryName
    popup.Size = UDim2.new(0, 250, 0, 200)
    popup.Position = UDim2.new(0, 0, 0, 0)
    popup.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    popup.Visible = false
    popup.ZIndex = 1000
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", popup).Color = Color3.fromRGB(60, 80, 120)
    
    -- SCROLLING FRAME
    local scrollFrame = Instance.new("ScrollingFrame", popup)
    scrollFrame.Size = UDim2.new(1, -20, 1, -20)
    scrollFrame.Position = UDim2.new(0, 10, 0, 10)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local listLayout = Instance.new("UIListLayout", scrollFrame)
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- ATUALIZAR TEXTO DO CAMPO
    local function updateSelectionText()
        local selected = SelectedItems[categoryName]
        if #selected == 0 then
            selectionField.Text = "Selecionar itens..."
            selectionField.TextColor3 = Color3.fromRGB(150, 160, 180)
        else
            local text = table.concat(selected, ", ")
            if #text > 30 then
                text = tostring(#selected) .. " itens selecionados"
            end
            selectionField.Text = text
            selectionField.TextColor3 = Color3.new(1, 1, 1)
        end
    end
    
    -- CRIAR ITENS NO POPUP
    local function createItemButtons()
        -- Limpar itens existentes
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        
        -- Criar botões para cada item
        for _, item in pairs(items) do
            local itemBtn = Instance.new("TextButton", scrollFrame)
            itemBtn.Size = UDim2.new(1, -10, 0, 30)
            itemBtn.BackgroundColor3 = table.find(SelectedItems[categoryName] or {}, item) and Color3.fromRGB(0, 150, 255, 0.3) or Color3.fromRGB(25, 35, 55)
            itemBtn.Text = item
            itemBtn.TextColor3 = Color3.new(1, 1, 1)
            itemBtn.TextSize = 14
            itemBtn.Font = Enum.Font.SourceSans
            itemBtn.TextXAlignment = Enum.TextXAlignment.Left
            itemBtn.TextPadding = UDim2.new(0, 10, 0, 0)
            
            itemBtn.MouseButton1Click:Connect(function()
                -- Garantir que a tabela existe
                if not SelectedItems[categoryName] then
                    SelectedItems[categoryName] = {}
                end
                
                -- Toggle seleção
                local selected = SelectedItems[categoryName]
                local index = table.find(selected, item)
                if index then
                    table.remove(selected, index)
                    itemBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
                else
                    table.insert(selected, item)
                    itemBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255, 0.3)
                end
                updateSelectionText()
            end)
        end
        
        -- Atualizar tamanho do canvas
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #items * 32)
    end
    
    -- ABRIR/FECHAR POPUP
    selectionField.MouseButton1Click:Connect(function()
        if popup.Visible then
            popup.Visible = false
        else
            createItemButtons()
            popup.Position = UDim2.new(0, selectionField.AbsolutePosition.X, 0, selectionField.AbsolutePosition.Y + selectionField.AbsoluteSize.Y + 5)
            popup.Visible = true
            
            -- Fechar ao clicar fora
            local function closePopup(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePos = input.Position
                    local popupPos = popup.AbsolutePosition
                    local popupSize = popup.AbsoluteSize
                    
                    if mousePos.X < popupPos.X or mousePos.X > popupPos.X + popupSize.X or
                       mousePos.Y < popupPos.Y or mousePos.Y > popupPos.Y + popupSize.Y then
                        popup.Visible = false
                        UserInputService.InputBegan:Disconnect(closePopup)
                    end
                end
            end
            
            UserInputService.InputBegan:Connect(closePopup)
        end
    end)
    
    -- BOTÃO PEGAR
    getBtn.MouseButton1Click:Connect(function()
        local selected = SelectedItems[categoryName] or {}
        if #selected > 0 then
            bringObjects(selected)
            notify("Bring", "Pegando " .. #selected .. " itens de " .. categoryName, 2)
        else
            notify("Aviso", "Selecione itens primeiro!", 2)
        end
    end)
    
    return frame
end

---------------------------------------------------------
-- [ ABAS E CONTEÚDO ]
---------------------------------------------------------
-- ABA FARM
local farmPage = createTab("Farm", "🚜")
createSection(farmPage, "Combate")
createToggle(farmPage, "Animal Farm (PASSIVOS)", function(v) Config.AnimalFarm = v end, Config.AnimalFarm)
createSlider(farmPage, "Alcance Animal Farm", 10, 250, Config.AnimalFarmRange, function(v) Config.AnimalFarmRange = v end)
createSection(farmPage, "Recursos")
createToggle(farmPage, "Tree Aura UNIVERSAL", function(v) Config.TreeAura = v end, Config.TreeAura)
createSlider(farmPage, "Alcance Árvores", 1, 100, Config.TreeAuraRange, function(v) Config.TreeAuraRange = v end)
createSection(farmPage, "Automação")
local modesBtn = createButton(farmPage, "Modos: FOGUEIRA", function() 
    popupFrame.Position = UDim2.new(0, modesBtn.AbsolutePosition.X - mainFrame.AbsolutePosition.X, 0, modesBtn.AbsolutePosition.Y - mainFrame.AbsolutePosition.Y - popupFrame.Size.Y.Offset - 5)
    popupFrame.Visible = not popupFrame.Visible 
end)
local function selectMode(mode, name) Config.AutoFarmMode = mode modesBtn.Text = "Modos: " .. name popupFrame.Visible = false end
createButton(popupList, "Modo 1: Fogueira", function() selectMode(1, "FOGUEIRA") end).Size = UDim2.new(1, 0, 0, 30)
createButton(popupList, "Modo 2: Jogador", function() selectMode(2, "JOGADOR") end).Size = UDim2.new(1, 0, 0, 30)
createToggle(farmPage, "Auto Farm Baús", function(v) Config.AutoFarmChests = v if v then task.spawn(autoFarmChests) end end, Config.AutoFarmChests)

-- ABA BRING COM SISTEMA DE SELEÇÃO MÚLTIPLA
local bringPage = createTab("Bring", "🧲")
createButton(bringPage, "🔥 BRING TUDO 🔥", function() bringObjects(AllItemsList) end)

-- CRIAR SEÇÕES PARA CADA CATEGORIA COM SELEÇÃO MÚLTIPLA
local categories = {
    {"Madeira", "Wood", Targets.Wood},
    {"Ferramentas", "Tools", Targets.Tools},
    {"Armaduras", "Armor", Targets.Armor},
    {"Tecnologia", "Technology", Targets.Technology},
    {"Minerais", "Minerals", Targets.Minerals},
    {"Médico", "Medical", Targets.Medical},
    {"Comidas", "Fruits", Targets.Fruits},
    {"Itens Especiais", "SpecialItems", Targets.SpecialItems},
    {"Sementes", "Seeds", Targets.Seeds},
    {"Combustível", "Combustion", Targets.Combustion}
}

for _, category in pairs(categories) do
    local section = createSection(bringPage, "Bring " .. category[1])
    createMultiSelectDropdown(bringPage, category[2], category[3])
end

-- ABA ESP
local espPage = createTab("ESP", "👁️")
local espList = {"Children", "Animals", "Fruits", "Chests", "Wood", "Trees"}
for _, k in pairs(espList) do createToggle(espPage, "ESP "..k, function(v) Config.ESP[k] = v end, Config.ESP[k]) end

-- ABA MOVE
local movePage = createTab("Move", "🏃")
createSlider(movePage, "Velocidade", 16, 300, Config.Speed, function(v) Config.Speed = v end)
createSlider(movePage, "Pulo", 50, 500, Config.Jump, function(v) Config.Jump = v end)
createToggle(movePage, "Full Bright / No Fog", function(v) Config.NoFog, Config.FullBright = v, v end, Config.NoFog)
createToggle(movePage, "Fly", function(v) Config.Fly = v end, Config.Fly)
createSection(movePage, "Sobrevivência")
createToggle(movePage, "Auto Heal (ITENS)", function(v) Config.AutoHeal = v end, Config.AutoHeal)
createSlider(movePage, "Heal em %", 1, 80, Config.AutoHealHealth, function(v) Config.AutoHealHealth = v end)

-- ABA TP (REORGANIZADA)
local tpPage = createTab("Tp", "📍")
createSection(tpPage, "Tp fogueira/acampamento")
createButton(tpPage, "Teleportar para Fogueira", function()
    local campfire = findObject("Campfire")
    if campfire then teleportTo(campfire.Position) else notify("Erro", "Fogueira não encontrada!", 3) end
end)
createSection(tpPage, "Tp crianças")
createButton(tpPage, "Teleportar para Criança Perdida", function()
    local child = findObject("Lost Child")
    if child then teleportTo(child.Position) else notify("Erro", "Nenhuma criança encontrada!", 3) end
end)
createSection(tpPage, "Tp biomes (Dinâmico)")
local dynamicBiomes = {
    {"Vulcão (Novo)", "Volcano"},
    {"Fada (Mini Bioma)", "Fairy"},
    {"Neve", "Snow"},
    {"Polo Norte", "NorthPole"},
    {"Floresta", "Forest"}
}
for _, biome in pairs(dynamicBiomes) do
    local displayName, searchName = biome[1], biome[2]
    createButton(tpPage, "Teleportar para " .. displayName, function()
        local target = findObject(searchName)
        if target then
            teleportTo(target.Position)
            notify("Teleporte Dinâmico", "Indo para " .. displayName, 2)
        else
            notify("Erro", displayName .. " não encontrado!", 3)
        end
    end)
end
createSection(tpPage, "Tp baús")
local chestSelectionBtn = Instance.new("TextButton", tpPage)
chestSelectionBtn.Size, chestSelectionBtn.BackgroundColor3, chestSelectionBtn.Text, chestSelectionBtn.TextColor3, chestSelectionBtn.Font, chestSelectionBtn.TextSize = UDim2.new(1, -10, 0, 40), Color3.fromRGB(45, 65, 100), "Tp baús: (Nenhum)", Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 16
Instance.new("UICorner", chestSelectionBtn).CornerRadius = UDim.new(0, 6)
local chestPopup = Instance.new("Frame", screenGui)
chestPopup.Size, chestPopup.BackgroundColor3, chestPopup.Visible, chestPopup.ZIndex = UDim2.new(0, 200, 0, 200), Color3.fromRGB(30, 40, 60), false, 20
Instance.new("UICorner", chestPopup).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", chestPopup).Color = Color3.fromRGB(60, 80, 120)
local chestScroll = Instance.new("ScrollingFrame", chestPopup)
chestScroll.Size, chestScroll.Position, chestScroll.BackgroundTransparency, chestScroll.ScrollBarThickness, chestScroll.CanvasSize = UDim2.new(1, -10, 1, -10), UDim2.new(0, 5, 0, 5), 1, 4, UDim2.new(0, 0, 0, 0)
local chestLayout = Instance.new("UIListLayout", chestScroll)
chestLayout.Padding = UDim.new(0, 5)
local function updateChestList()
    for _, c in pairs(chestScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local chestCount = 0
    local chestModels = {}
    for _, v in pairs(workspace:GetDescendants()) do
        if table.find(Targets.Chests, v.Name) and v:IsA("Model") and v.PrimaryPart then
            table.insert(chestModels, v)
        end
    end
    for i, chestModel in pairs(chestModels) do
        chestCount = chestCount + 1
        local chestName = chestModel.Name .. " (" .. chestCount .. ")"
        local b = createButton(chestScroll, chestName, function() 
            Config.SelectedChest = chestModel
            chestSelectionBtn.Text = "Tp baús: " .. chestModel.Name
            chestPopup.Visible = false
        end)
        b.Size = UDim2.new(1, 0, 0, 30)
    end
    chestScroll.CanvasSize = UDim2.new(0, 0, 0, chestLayout.AbsoluteContentSize.Y + 10)
end
chestSelectionBtn.MouseButton1Click:Connect(function()
    updateChestList()
    chestPopup.Position = UDim2.new(0, chestSelectionBtn.AbsolutePosition.X, 0, chestSelectionBtn.AbsolutePosition.Y - chestPopup.Size.Y.Offset - 5)
    chestPopup.Visible = not chestPopup.Visible
end)
local teleportChestBtn = createButton(tpPage, "Teleportar", function()
    if Config.SelectedChest then
        local chest = Config.SelectedChest
        if chest and chest.PrimaryPart then
            teleportTo(chest.PrimaryPart.Position)
            notify("Sucesso", "Teleportado para " .. chest.Name, 2)
        else
            notify("Erro", "Baú não encontrado!", 3)
        end
    else
        notify("Aviso", "Selecione um baú primeiro!", 3)
    end
end)
teleportChestBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)

-- ABA CONFIG
local configPage = createTab("Config", "⚙️")
createSection(configPage, "Painel de Informações")
local infoFrame = Instance.new("Frame", configPage)
infoFrame.Size, infoFrame.BackgroundColor3 = UDim2.new(1, -10, 0, 260), Color3.fromRGB(25, 35, 55)
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 8)
local infoLabel = Instance.new("TextLabel", infoFrame)
infoLabel.Size, infoLabel.Position, infoLabel.BackgroundTransparency, infoLabel.Text, infoLabel.TextColor3, infoLabel.Font, infoLabel.TextSize, infoLabel.TextXAlignment, infoLabel.TextWrapped, infoLabel.TextYAlignment = UDim2.new(1, -20, 1, -10), UDim2.new(0, 10, 0, 10), 1, "Carregando...", Color3.new(1, 1, 1), Enum.Font.SourceSans, 14, Enum.TextXAlignment.Left, true, Enum.TextYAlignment.Top
infoLabel.ClipsDescendants = false

local tracerBtn, _ = createToggle(configPage, "Linhas players: OFF", function(v) 
    Config.PlayerTracers = v 
    tracerBtn.Text = "Linhas players: " .. (Config.PlayerTracers and "ON" or "OFF")
    tracerBtn.TextColor3 = Config.PlayerTracers and Color3.fromRGB(0, 255, 0) or Color3.new(1, 1, 1)
    tracerBtn.BackgroundColor3 = Config.PlayerTracers and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 65, 90)
    tracerBtn.Text = Config.PlayerTracers and "✓" or ""
end, Config.PlayerTracers)
tracerBtn.Text = "Linhas players: " .. (Config.PlayerTracers and "ON" or "OFF")
tracerBtn.TextColor3 = Config.PlayerTracers and Color3.fromRGB(0, 255, 0) or Color3.new(1, 1, 1)
tracerBtn.BackgroundColor3 = Config.PlayerTracers and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 65, 90)

-- Nova funcionalidade: Remover animações de baú
local removeChestAnimBtn, _ = createToggle(configPage, "Remover animações de baú: OFF", function(v)
    Config.RemoveChestAnimation = v
    removeChestAnimBtn.Text = "Remover animações de baú: " .. (Config.RemoveChestAnimation and "ON" or "OFF")
    removeChestAnimBtn.TextColor3 = Config.RemoveChestAnimation and Color3.fromRGB(0, 255, 0) or Color3.new(1, 1, 1)
    removeChestAnimBtn.BackgroundColor3 = Config.RemoveChestAnimation and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 65, 90)
    removeChestAnimBtn.Text = Config.RemoveChestAnimation and "✓" or ""
end, Config.RemoveChestAnimation)
removeChestAnimBtn.Text = "Remover animações de baú: " .. (Config.RemoveChestAnimation and "ON" or "OFF")
removeChestAnimBtn.TextColor3 = Config.RemoveChestAnimation and Color3.fromRGB(0, 255, 0) or Color3.new(1, 1, 1)
removeChestAnimBtn.BackgroundColor3 = Config.RemoveChestAnimation and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 65, 90)

createSection(configPage, "Servidor (JobId)")
createButton(configPage, "Copiar JobId Atual", function() setclipboard(game.JobId) notify("Sucesso", "JobId copiado!", 3) end)
createInput(configPage, "Colar JobId aqui...", function(text)
    if text and #text > 5 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, text, player)
    end
end)
createSection(configPage, "Jogadores no Servidor")
local playersFrame = Instance.new("Frame", configPage)
playersFrame.Size, playersFrame.BackgroundColor3 = UDim2.new(1, -10, 0, 150), Color3.fromRGB(25, 35, 55)
Instance.new("UICorner", playersFrame).CornerRadius = UDim.new(0, 8)
local playersScroll = Instance.new("ScrollingFrame", playersFrame)
playersScroll.Size, playersScroll.Position, playersScroll.BackgroundTransparency, playersScroll.ScrollBarThickness, playersScroll.CanvasSize = UDim2.new(1, -10, 1, -10), UDim2.new(0, 5, 0, 5), 1, 2, UDim2.new(0, 0, 0, 0)
local playersLayout = Instance.new("UIListLayout", playersScroll)
playersLayout.Padding = UDim.new(0, 5)
createSection(configPage, "Automação")
createToggle(configPage, "Auto Explorar", function(v) Config.AutoExplore = v if v then task.spawn(autoExplore) end end, Config.AutoExplore)
createSection(configPage, "Teleporte")
createButton(configPage, "Resetar Posição (Fogueira)", function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local campfire = workspace:FindFirstChild("Campfire", true)
    if hrp and campfire then hrp.CFrame = CFrame.new((campfire.PrimaryPart and campfire.PrimaryPart.Position or campfire.Position) + Vector3.new(0, 5, 0)) end
end)

---------------------------------------------------------
-- [ LÓGICA DE MOVIMENTO ]
---------------------------------------------------------
local function updateMovement()
    local h = player.Character and player.Character:FindFirstChild("Humanoid")
    if h then
        h.WalkSpeed, h.JumpPower = Config.Speed, Config.Jump
        if Config.Fly then
            h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            h:SetStateEnabled(Enum.HumanoidStateType.Flying, true)
            h:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
            h:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
            h:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
            h:SetStateEnabled(Enum.HumanoidStateType.Running, false)
            h:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
            h:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
            h:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        else
            h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            h:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
            h:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            h:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
            h:SetStateEnabled(Enum.HumanoidStateType.Landed, true)
            h:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            h:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, true)
            h:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
            h:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        end
    end
end

RunService.Heartbeat:Connect(updateMovement)

---------------------------------------------------------
-- [ LÓGICA DE VISUAL ]
---------------------------------------------------------
local function updateVisualSettings()
    if Config.NoFog or Config.FullBright then
        Lighting.FogEnd, Lighting.ClockTime, Lighting.Brightness, Lighting.GlobalShadows, Lighting.Ambient = 100000, 12, 2, false, Color3.new(1,1,1)
    end
end

RunService.Heartbeat:Connect(updateVisualSettings)

---------------------------------------------------------
-- [ LÓGICA DE CURA ]
---------------------------------------------------------
local function autoHealLoop()
    while Config.AutoHeal do
        local h = player.Character and player.Character:FindFirstChild("Humanoid")
        if h and (h.Health / h.MaxHealth) * 100 <= Config.AutoHealHealth then
            useMedicalItem()
        end
        task.wait(1)
    end
end

task.spawn(function()
    while task.wait(1) do
        if Config.AutoHeal then task.spawn(autoHealLoop) end
    end
end)

---------------------------------------------------------
-- [ LOOPS DE ATUALIZAÇÃO ]
---------------------------------------------------------
task.spawn(function()
    local lastFpsUpdate, fps, frameCount = 0, 0, 0
    RunService.Heartbeat:Connect(function() frameCount = frameCount + 1 end)
    while task.wait(0.5) do
        pcall(function()
            local elapsed = os.time() - startTime
            if tick() - lastFpsUpdate >= 1.4 then fps = math.floor(frameCount / 1.4) frameCount = 0 lastFpsUpdate = tick() end
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            local clockTime = Lighting.ClockTime
            local timeMsg = (clockTime >= 6 and clockTime < 18) and string.format("Tempo para ficar de noite: %.1f min", (18 - clockTime) * 60) or "A noite chegou!"
            infoLabel.Text = string.format("Tempo: %s\nPing: %d ms\nLocal: %s | FPS: %d\nJogadores: %d/%d\n%s\nDiamantes: %d", formatTime(elapsed), ping, serverLoc, fps, #Players:GetPlayers(), Players.MaxPlayers, timeMsg, getPlayerDiamonds())
        end)
    end
end)

task.spawn(function()
    while task.wait(3) do
        pcall(function()
            for _, child in pairs(playersScroll:GetChildren()) do if child:IsA("TextLabel") or child:IsA("Frame") then child:Destroy() end end
            local allPlayers = Players:GetPlayers()
            for i = 1, #allPlayers do
                local p = allPlayers[i]
                local pLabel = Instance.new("TextLabel", playersScroll)
                pLabel.Size, pLabel.BackgroundTransparency, pLabel.TextColor3, pLabel.Font, pLabel.TextSize, pLabel.TextXAlignment, pLabel.Text = UDim2.new(1, 0, 0, 40), 1, Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 14, Enum.TextXAlignment.Left, string.format("%d %s\n   %s", i, p.DisplayName, p.Name)
                local line = Instance.new("Frame", playersScroll)
                line.Size, line.BackgroundColor3, line.BorderSizePixel = UDim2.new(1, 0, 0, 1), Color3.fromRGB(50, 70, 100), 0
            end
            playersScroll.CanvasSize = UDim2.new(0, 0, 0, #allPlayers * 55)
        end)
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local descendants = workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if Config.AnimalFarm and table.find(Targets.PassiveAnimals, obj.Name) and obj:IsA("Model") then
                local r = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
                if r and (hrp.Position - r.Position).Magnitude <= Config.AnimalFarmRange then dealDamage(obj, false) end
            end
            if Config.TreeAura and (obj.Name:lower():find("tree") or obj.Name:lower():find("trunk")) and (obj:IsA("Model") or obj:IsA("BasePart")) then
                local r = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")) or obj
                if r and (hrp.Position - r.Position).Magnitude <= Config.TreeAuraRange then dealDamage(obj, true) end
            end
            if i % 500 == 0 then task.wait() end
        end
        updateESP()
    end
end)

---------------------------------------------------------
-- [ ANIMAÇÕES DE INTERFACE ]
---------------------------------------------------------
-- CLOSE/MINIMIZE/OPEN ANIMATIONS
local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size, closeBtn.Position, closeBtn.BackgroundTransparency, closeBtn.Text, closeBtn.TextColor3, closeBtn.Font, closeBtn.TextSize = UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0.5, -15), 1, "X", Color3.fromRGB(255, 80, 80), Enum.Font.SourceSansBold, 18
local minBtn = Instance.new("TextButton", topBar)
minBtn.Size, minBtn.Position, minBtn.BackgroundTransparency, minBtn.Text, minBtn.TextColor3, minBtn.Font, minBtn.TextSize = UDim2.new(0, 30, 0, 30), UDim2.new(1, -70, 0.5, -15), 1, "-", Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 24
local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 500, 0, 40) or UDim2.new(0, 500, 0, 350)
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    contentArea.Visible = not isMinimized
    bottomBar.Visible = not isMinimized
    tabList.Visible = not isMinimized
    minBtn.Text = isMinimized and "+" or "-"
end)
closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.5)
    mainFrame.Visible = false
    mobileToggle.Visible = true
    TweenService:Create(mobileToggle, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -50, 0, 10)}):Play()
end)
mobileToggle.MouseButton1Click:Connect(function()
    TweenService:Create(mobileToggle, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, -50, 0.5, -17)}):Play()
    task.wait(0.3)
    mobileToggle.Visible = false
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 500, 0, 350)}):Play()
    mobileToggle.Position = UDim2.new(0.5, -50, 0, -40)
    isMinimized = false
    contentArea.Visible = true
    bottomBar.Visible = true
    tabList.Visible = true
    minBtn.Text = "-"
end)

-- STARTUP ANIMATION
task.spawn(function()
    TweenService:Create(splashTitle, TweenInfo.new(1), {TextTransparency = 0}):Play()
    task.wait(2)
    TweenService:Create(splashTitle, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.5)
    splash1.Visible = false
    splash2.Visible = true
    TweenService:Create(splashMenu, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
    TweenService:Create(splashInfo1, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    TweenService:Create(splashInfo2, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    task.wait(4)
    TweenService:Create(splashMenu, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(splashInfo1, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    TweenService:Create(splashInfo2, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
    task.wait(0.5)
    splash2:Destroy()
    mainFrame.Visible = true
    mobileToggle.Visible = true
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 500, 0, 350)}):Play()
    TweenService:Create(mobileToggle, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -50, 0, -40)}):Play()
end)

print("Pudim Hub v10.0 - Atualizado com funcionalidades Voidware carregado com sucesso!")
