-- [[ PUDIM HUB - 99 DIAS NA FLORESTA ]]
-- Versão 10.1 - COM NOVO SISTEMA DE ACCORDION (15/01/2026)
-- MODIFICAÇÕES: Sistema de accordion com mini janelas flutuantes para TPs e Brings

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
    Notifications = true,
    
    HitboxAura = false, HitboxRange = 40, HitboxSize = 50,
    IceAura = false, IceRange = 40,
    AutoFeedCampfire = false,
    TreeHitbox = false, TreeHitboxRange = 40, TreeHitboxSize = 25,
    AutoClick = false,
    Speed = 16, Jump = 50, Fly = false,
    AutoFarmChests = false, AutoFarmMode = 1, SavedPosition = nil,
    NoFog = false, FullBright = false,
    AutoHeal = false, AutoHealHealth = 40,
    AutoExplore = false,
    AutoGrinder = false,
    PlayerTracers = false,
    SelectedChest = nil,
    RemoveChestAnimation = false,
    ESP = {
        Children = false, Animals = false,
        Fruits = false, Chests = false, Wood = false, Trees = false
    }
}

local Targets = {
    PassiveAnimals = {"Bunny", "Deer", "Frog", "Kiwi", "Arctic Fox", "Pet Bunny", "Pet Frog", "Pet Kiwi", "Fairy Wolf", "Fairy", "Mushroom Wolf"},
    Fruits = {"Apple", "Berry", "Carrot", "Pumpkin", "Corn", "Chili", "Steak", "Ribs", "Morsel", "Cooked Morsel", "Cooked Steak", "Cooked Ribs", "Acorn", "Cake"},
    Wood = {"Log", "Stick", "Super Log", "Sapling"},
    Combustion = {"Coal", "Charcoal", "Gasoline", "Fuel", "Fuel Canister", "Oil", "Biofuel", "Cultist Corpse", "Crossbow Cultist Corpse", "Juggernaut Cultist Corpse", "Cultist King Corpse"},
    Seeds = {"Seed Pack", "Carrot Seeds", "Corn Seeds", "Pumpkin Seeds", "Berry Seeds", "Apple Seeds", "Chili Seeds", "Firefly Seeds", "Flower Seeds"},
    Medical = {"Medkit", "Bandage", "First Aid Kit", "Trim Kit"},
    Tools = {"Old Axe", "Good Axe", "Strong Axe", "Old Rod", "Good Rod", "Strong Rod", "Old Flute", "Good Flute", "Strong Flute", "Flashlight", "Strong Flashlight", "Air Rifle", "Revolver", "Crossbow", "Spear", "Morningstar", "Raygun", "Laser Sword", "Laser Cannon", "Poison Spear", "Blowpipe", "Obsidiron Hammer", "Old Sack", "Good Sack", "Infernal Sack", "Giant Sack", "Enchanted Farm Tablet"},
    Armor = {"Iron Body", "Obsidiron Body", "Alien Armor", "Vampire Cloak", "Frog Boots", "Obsidiron Boots", "Iron Boots", "Warm Clothing"},
    Structures = {"Anvil Base", "Chair Set", "Laser Fence Blueprint", "Campfire", "Bank", "Abandoned Animal Shelter", "Fishing Cabin", "Upgrade Cabin", "Flute Tent", "Daily Quest Machine", "Cauldron", "Mother Tree", "Pelt Trader", "Furniture Trader", "Tool Workshop", "Warm Clothing Shop", "Portal", "Statue", "Altar"},
    Chests = {"Chest", "Rare Chest", "Epic Chest", "Legendary Chest", "Treasure Chest", "Supply Crate", "Infernal Chest", "Gold Chest", "Obsidiron Chest"},
    GrinderItems = {"Log", "Stick", "Super Log", "Radio", "Screws", "Metal Plate", "Metal Chair", "Scrap Metal", "Bolt", "Sheet Metal", "Broken Microwave", "Tire", "UFO Junk", "UFO Component", "Broken Fan", "Old Car Engine", "Super Bolt"}
}

local AllItemsList = {"Lost Child"}
for _, list in pairs({Targets.Fruits, Targets.Wood, Targets.Combustion, Targets.Seeds, Targets.Medical, Targets.Tools, Targets.Armor, Targets.GrinderItems}) do
    for _, item in pairs(list) do table.insert(AllItemsList, item) end
end

---------------------------------------------------------
-- [ NOVO SISTEMA: ACCORDION E SELEÇÃO MÚLTIPLA ]
---------------------------------------------------------

-- Estrutura para armazenar categorias de TP
local TPCategories = {
    {
        id = "tp-biomes",
        name = "Tp-Biomas",
        icon = "🌍",
        items = {
            {id = "volcano", name = "Vulcão (Novo)", icon = "🌋", internalName = "Volcano"},
            {id = "fairy", name = "Fada (Mini Bioma)", icon = "🧚", internalName = "Fairy"},
            {id = "snow", name = "Neve", icon = "❄️", internalName = "Snow"},
            {id = "northpole", name = "Polo Norte", icon = "🧊", internalName = "NorthPole"},
            {id = "forest", name = "Floresta", icon = "🌲", internalName = "Forest"}
        }
    },
    {
        id = "tp-chests",
        name = "Tp-Baús",
        icon = "📦",
        items = {
            {id = "random-chest", name = "Baú Aleatório", icon = "🎲", internalName = "RandomChest"}
        }
    },
    {
        id = "tp-children",
        name = "Tp-Crianças",
        icon = "👶",
        items = {
            {id = "nearest-child", name = "Criança Próxima", icon = "👶", internalName = "NearestChild"}
        }
    },
    {
        id = "tp-campfire",
        name = "Tp-Fogueira",
        icon = "🔥",
        items = {
            {id = "campfire", name = "Fogueira/Acampamento", icon = "🔥", internalName = "Campfire"}
        }
    }
}

-- Estrutura para armazenar categorias de Bring
local BringCategories = {
    {id = "bring-logs", name = "Bring Logs", icon = "🪵", items = {{id = "log", name = "Log", icon = "🪵"}, {id = "stick", name = "Stick", icon = "🌿"}, {id = "super-log", name = "Super Log", icon = "🪵"}}},
    {id = "bring-metals", name = "Bring Metais", icon = "⚙️", items = {{id = "coal", name = "Carvão", icon = "⚫"}, {id = "charcoal", name = "Carvão Vegetal", icon = "🖤"}, {id = "gasoline", name = "Gasolina", icon = "⛽"}, {id = "fuel", name = "Combustível", icon = "🔋"}, {id = "radio", name = "Rádio", icon = "📻"}, {id = "screws", name = "Parafusos", icon = "🔩"}, {id = "metal-plate", name = "Placa de Metal", icon = "🛡️"}, {id = "metal-chair", name = "Cadeira de Metal", icon = "🪑"}}},
    {id = "bring-tools", name = "Bring Ferramentas", icon = "🛠️", items = {{id = "good-axe", name = "Bom Machado", icon = "🪓"}, {id = "strong-axe", name = "Machado Forte", icon = "🪓"}, {id = "good-rod", name = "Boa Vara", icon = "🎣"}, {id = "strong-rod", name = "Vara Forte", icon = "🎣"}, {id = "crossbow", name = "Arco-íris", icon = "🏹"}, {id = "spear", name = "Lança", icon = "🔱"}, {id = "laser-sword", name = "Espada Laser", icon = "⚔️"}, {id = "laser-cannon", name = "Canhão Laser", icon = "🔫"}}},
    {id = "bring-armor", name = "Bring Armaduras", icon = "🛡️", items = {{id = "iron-body", name = "Corpo de Ferro", icon = "🛡️"}, {id = "obsidiron-body", name = "Corpo Obsidião", icon = "🛡️"}, {id = "alien-armor", name = "Armadura Alienígena", icon = "👽"}, {id = "vampire-cloak", name = "Capa de Vampiro", icon = "🧛"}}},
    {id = "bring-food", name = "Bring Comidas", icon = "🍎", items = {{id = "apple", name = "Maçã", icon = "🍎"}, {id = "berry", name = "Baga", icon = "🫐"}, {id = "carrot", name = "Cenoura", icon = "🥕"}, {id = "steak", name = "Bife", icon = "🥩"}, {id = "cooked-steak", name = "Bife Cozido", icon = "🥩"}}},
    {id = "bring-seeds", name = "Bring Seeds", icon = "🌱", items = {{id = "seed-pack", name = "Pacote de Sementes", icon = "🌱"}, {id = "carrot-seeds", name = "Sementes de Cenoura", icon = "🌱"}, {id = "corn-seeds", name = "Sementes de Milho", icon = "🌱"}}},
    {id = "bring-medical", name = "Bring Médico", icon = "🩹", items = {{id = "medkit", name = "Kit Médico", icon = "🩹"}, {id = "bandage", name = "Bandagem", icon = "🩹"}, {id = "first-aid-kit", name = "Kit de Primeiros Socorros", icon = "🚑"}}},
    {id = "bring-combustion", name = "Bring Combustão", icon = "🔥", items = {{id = "coal", name = "Carvão", icon = "⚫"}, {id = "charcoal", name = "Carvão Vegetal", icon = "🖤"}, {id = "gasoline", name = "Gasolina", icon = "⛽"}, {id = "fuel", name = "Combustível", icon = "🔋"}}}
}

-- Variáveis de controle para accordion e seleção
local ExpandedCategories = {}
local SelectedItems = {tp = {}, bring = {}}
local ActivePopup = nil

---------------------------------------------------------
-- [ UTILITÁRIOS ]
---------------------------------------------------------

---------------------------------------------------------

---------------------------------------------------------
-- [ SISTEMA DE HITBOX OTIMIZADO (SEM LAG) ]
---------------------------------------------------------
local MobCache = {}
local TreeCache = {}

local function applyMobHitbox()
    if not Config.HitboxAura then return end
    for _, obj in pairs(workspace:GetChildren()) do -- Usar GetChildren para ser mais rápido que Descendants
        if obj:IsA("Model") and (obj:FindFirstChild("Humanoid") or Targets.PassiveAnimals[obj.Name]) then
            local root = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head")
            if root and root:IsA("BasePart") then
                root.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                root.Transparency = 0.8
                root.CanCollide = false
                root.Massless = true -- Evita problemas de física
            end
        end
    end
end

local function applyTreeHitbox()
    if not Config.TreeHitbox then return end
    -- Focar apenas em objetos que pareçam árvores no workspace
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("tree") or obj.Name:lower():find("trunk") or obj.Name == "Log") then
            obj.Size = Vector3.new(Config.TreeHitboxSize, Config.TreeHitboxSize, Config.TreeHitboxSize)
            obj.Transparency = 0.8
            obj.CanCollide = false
            obj.Massless = true
        end
    end
end

local function applyIceAura()
    if not Config.IceAura then return end
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name ~= player.Name then
            local root = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - hrp.Position).Magnitude < 100 then -- Apenas inimigos próximos (100 studs)
                root.Anchored = true
            end
        end
    end
end

-- Loop de performance (dividido para não sobrecarregar um único frame)
task.spawn(function()
    while task.wait(2) do -- Aumentado para 2 segundos para reduzir uso de CPU
        if Config.HitboxAura then pcall(applyMobHitbox) end
        task.wait(0.5) -- Pequena pausa entre operações
        if Config.TreeHitbox then pcall(applyTreeHitbox) end
        task.wait(0.5)
        if Config.IceAura then pcall(applyIceAura) end
    end
end)


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


local function terminateScript()
    Config.Notifications = false
    -- Desativar todas as funções
    for k, v in pairs(Config) do
        if type(v) == "boolean" then Config[k] = false end
    end
    if Config.ESP then
        for k, v in pairs(Config.ESP) do Config.ESP[k] = false end
    end
    -- Resetar Hitboxes e Âncoras
    Config.HitboxAura = false
    Config.TreeHitbox = false
    Config.IceAura = false
    applyMobHitbox()
    applyTreeHitbox()
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local root = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
            if root then root.Anchored = false end
        end
    end
    -- Remover UI
    screenGui:Destroy()
end

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "PudimHub_99Days"
screenGui.ResetOnSpawn = false

-- Sistema de Notificações Empilhadas (Superior Direito)
local notifyContainer = Instance.new("Frame", screenGui)
notifyContainer.Size = UDim2.new(0, 300, 1, 0)
notifyContainer.Position = UDim2.new(1, -310, 0, 10)
notifyContainer.BackgroundTransparency = 1

local notifyLayout = Instance.new("UIListLayout", notifyContainer)
notifyLayout.Padding = UDim.new(0, 10)
notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local function notify(title, text, duration)
    if not Config.Notifications then return end
    local isError = title:lower():find("erro")
    local frame = Instance.new("Frame", notifyContainer)
    frame.Size = UDim2.new(0, 280, 0, 0) -- Começa com altura 0 para animação
    frame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    frame.ClipsDescendants = true
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = isError and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 180, 255)
    stroke.Thickness = 2
    
    local tLabel = Instance.new("TextLabel", frame)
    tLabel.Size = UDim2.new(1, -20, 0, 25)
    tLabel.Position = UDim2.new(0, 10, 0, 5)
    tLabel.Text = title:upper()
    tLabel.TextColor3 = stroke.Color
    tLabel.Font = Enum.Font.SourceSansBold
    tLabel.TextSize = 16
    tLabel.BackgroundTransparency = 1
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local mLabel = Instance.new("TextLabel", frame)
    mLabel.Size = UDim2.new(1, -20, 0, 0)
    mLabel.Position = UDim2.new(0, 10, 0, 30)
    mLabel.Text = text
    mLabel.TextColor3 = Color3.new(1, 1, 1)
    mLabel.Font = Enum.Font.SourceSans
    mLabel.TextSize = 14
    mLabel.BackgroundTransparency = 1
    mLabel.TextXAlignment = Enum.TextXAlignment.Left
    mLabel.TextWrapped = true
    mLabel.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Ajustar altura baseada no texto
    local textHeight = game:GetService("TextService"):GetTextSize(text, 14, Enum.Font.SourceSans, Vector2.new(260, 1000)).Y
    local targetHeight = textHeight + 45
    
    TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, targetHeight)}):Play()
    TweenService:Create(mLabel, TweenInfo.new(0.3), {Size = UDim2.new(1, -20, 0, textHeight)}):Play()
    
    task.delay(duration or 2, function()
        local t = TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(0, 280, 0, 0), BackgroundTransparency = 1})
        t:Play()
        t.Completed:Connect(function() frame:Destroy() end)
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
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    
    if name == "RandomChest" then
        local nearest, minDist = nil, math.huge
        for _, v in pairs(workspace:GetDescendants()) do
            local isChest = false
            for _, cName in pairs(Targets.Chests) do if v.Name == cName or v.Name:lower():find("chest") then isChest = true break end end
            if isChest and (v:IsA("BasePart") or v:IsA("Model")) then
                local root = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildOfClass("BasePart")) or v
                if root and hrp then
                    local dist = (hrp.Position - root.Position).Magnitude
                    if dist < minDist then minDist = dist nearest = root end
                end
            end
        end
        return nearest
    elseif name == "NearestChild" then
        local nearest, minDist = nil, math.huge
        for _, v in pairs(workspace:GetDescendants()) do
            if v.Name == "Lost Child" and (v:IsA("BasePart") or v:IsA("Model")) then
                local root = v:IsA("Model") and (v.PrimaryPart or v:FindFirstChildOfClass("BasePart")) or v
                if root and hrp then
                    local dist = (hrp.Position - root.Position).Magnitude
                    if dist < minDist then minDist = dist nearest = root end
                end
            end
        end
        return nearest
    end

    -- Busca padrão com suporte a biomas (busca por nome parcial ou pasta)
    for _, v in pairs(workspace:GetDescendants()) do
        if (v.Name == name or v.Name:lower():find(name:lower())) and (v:IsA("BasePart") or v:IsA("Model")) then
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
local OriginalSizes = {}
local OriginalTreeSizes = {}
local TreeCache = nil
local FrozenMobs = {}
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
    local collected = {}
    local total = 0
    
    for i = 1, #descendants do
        local obj = descendants[i]
        local isTarget = false
        for j = 1, #targetNames do if obj.Name == targetNames[j] then isTarget = true break end end
        if isTarget then
            if obj:IsA("BasePart") then 
                obj.CFrame = typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos)
                collected[obj.Name] = (collected[obj.Name] or 0) + 1
                total = total + 1
            elseif obj:IsA("Model") and obj.PrimaryPart then 
                obj:SetPrimaryPartCFrame(typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos)) 
                collected[obj.Name] = (collected[obj.Name] or 0) + 1
                total = total + 1
            end
        end
    end
    
    if total > 0 then
        local msg = "Você pegou " .. total .. " itens no momento:\n"
        local countList = {}
        for name, count in pairs(collected) do table.insert(countList, count .. "x " .. name) end
        notify("Aviso", msg .. table.concat(countList, ", "), 5)
    else
        notify("Erro", "Não existem mais recursos desse tipo no mapa!", 4)
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
                    task.wait(0.05)
                    local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents") or ReplicatedStorage
                    for _, n in pairs({"OpenChest", "Interact", "ChestEvent", "ClaimChest"}) do
                        local e = remotes:FindFirstChild(n)
                        if e then 
                            if Config.RemoveChestAnimation then
                                e:FireServer(obj)
                            else
                                e:FireServer(obj, true)
                                task.wait(0.1)
                                e:FireServer(obj, false)
                            end
                        end
                    end
                    local p = obj:FindFirstChildOfClass("ProximityPrompt") or obj:FindFirstChild("Prompt", true)
                    if p and p:IsA("ProximityPrompt") then fireproximityprompt(p) end
                    task.wait(0.05)
                    bringObjects(AllItemsList, safePos)
                    task.wait(2)
                end
            end
        end
        if not found then task.wait(0.5) end
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

local function autoFeedCampfire()
    local itemsFed = 0
    while Config.AutoFeedCampfire do
        local campfire = workspace:FindFirstChild("Campfire", true)
        local campPos = campfire and (campfire.PrimaryPart and campfire.PrimaryPart.Position or campfire.Position)
        
        if campPos then
            local foundFuel = false
            for _, obj in pairs(workspace:GetDescendants()) do
                if not Config.AutoFeedCampfire then break end
                local isFuel = false
                for _, fuelName in pairs(Targets.Combustion) do
                    if obj.Name == fuelName then isFuel = true break end
                end
                
                if isFuel and (obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart)) then
                    foundFuel = true
                    local fuelPart = obj:IsA("Model") and obj.PrimaryPart or obj
                    fuelPart.CFrame = CFrame.new(campPos + Vector3.new(0, 5, 0))
                    itemsFed = itemsFed + 1
                    notify("Aviso", "Alimentando fogueira!\nItens jogados na fogueira: " .. itemsFed .. " itens", 2)
                    task.wait(0.8)
                end
            end
            if not foundFuel then task.wait(1) end
        else
            notify("Erro", "Fogueira não encontrada no mapa!", 2)
            task.wait(2)
        end
        task.wait(0.1)
    end
    notify("Aviso", "Alimentando fogueira!\nItens jogados na fogueira: " .. itemsFed .. " itens\n(Desligado)", 2)
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
    end
    
    for _, child in pairs(workspace:GetDescendants()) do
        local espTag = child:FindFirstChild("PudimESP")
        if espTag and not activeESP[espTag] then
            espTag:Destroy()
        end
    end
end

---------------------------------------------------------
-- [ FUNÇÕES DE UI PARA ACCORDION ]
---------------------------------------------------------

local function createAccordionHeader(parent, category, categoryType)
    local header = Instance.new("TextButton", parent)
    header.Name = "AccordionHeader_" .. category.id
    header.Size = UDim2.new(1, -10, 0, 40)
    header.BackgroundColor3 = Color3.fromRGB(30, 45, 70)
    header.TextColor3 = Color3.new(1, 1, 1)
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 14
    header.Text = category.icon .. " " .. category.name .. " ▼"
    header.BorderSizePixel = 0
    
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", header)
    stroke.Color = Color3.fromRGB(0, 217, 255)
    stroke.Thickness = 1
    
    header.MouseButton1Click:Connect(function()
        ExpandedCategories[category.id] = not ExpandedCategories[category.id]
        header.Text = category.icon .. " " .. category.name .. (ExpandedCategories[category.id] and " ▲" or " ▼")
        
        local content = parent:FindFirstChild("Content_" .. category.id)
        if content then
            content.Visible = ExpandedCategories[category.id]
        end
    end)
    
    return header
end

local function createItemSelectorPopup(parent, category, categoryType)
    local popup = Instance.new("Frame", parent)
    popup.Name = "Popup_" .. category.id
    popup.Size = UDim2.new(0, 250, 0, 300)
    popup.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
    popup.Visible = false
    popup.ZIndex = 100
    
    Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", popup)
    stroke.Color = Color3.fromRGB(157, 0, 255)
    stroke.Thickness = 2
    
    local header = Instance.new("TextLabel", popup)
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    header.Text = category.name
    header.TextColor3 = Color3.new(1, 1, 1)
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 12
    header.BorderSizePixel = 0
    
    local scroll = Instance.new("ScrollingFrame", popup)
    scroll.Size = UDim2.new(1, -10, 1, -50)
    scroll.Position = UDim2.new(0, 5, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 4
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    for _, item in pairs(category.items) do
        local itemBtn = Instance.new("TextButton", scroll)
        itemBtn.Name = "Item_" .. item.id
        itemBtn.Size = UDim2.new(1, 0, 0, 30)
        itemBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
        itemBtn.TextColor3 = Color3.new(1, 1, 1)
        itemBtn.Font = Enum.Font.SourceSans
        itemBtn.TextSize = 12
        itemBtn.Text = item.icon .. " " .. item.name
        itemBtn.BorderSizePixel = 0
        
        Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)
        
        itemBtn.MouseButton1Click:Connect(function()
            local isSelected = table.find(SelectedItems[categoryType], item.id)
            if isSelected then
                table.remove(SelectedItems[categoryType], isSelected)
                itemBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
            else
                table.insert(SelectedItems[categoryType], item.id)
                itemBtn.BackgroundColor3 = Color3.fromRGB(157, 0, 255)
            end
        end)
    end
    
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
    
    return popup
end

local function createAccordionContent(parent, category, categoryType)
    local content = Instance.new("Frame", parent)
    content.Name = "Content_" .. category.id
    content.Size = UDim2.new(1, -10, 0, 80)
    content.BackgroundTransparency = 1
    content.Visible = false
    
    if categoryType == "bring" then
        local label = Instance.new("TextLabel", content)
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = "Escolher " .. category.name:lower() .. ":"
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.SourceSans
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        
        local selectBtn = Instance.new("TextButton", content)
        selectBtn.Name = "SelectBtn_" .. category.id
        selectBtn.Size = UDim2.new(1, 0, 0, 30)
        selectBtn.Position = UDim2.new(0, 0, 0, 20)
        selectBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
        selectBtn.TextColor3 = Color3.new(1, 1, 1)
        selectBtn.Font = Enum.Font.SourceSans
        selectBtn.TextSize = 12
        selectBtn.Text = "Selecionar..."
        selectBtn.BorderSizePixel = 0
        
        Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 4)
        local stroke = Instance.new("UIStroke", selectBtn)
        stroke.Color = Color3.fromRGB(157, 0, 255)
        stroke.Thickness = 1
        
        local popup = createItemSelectorPopup(parent, category, categoryType)
        
        selectBtn.MouseButton1Click:Connect(function()
            popup.Visible = not popup.Visible
            if popup.Visible then
                popup.Position = UDim2.new(0, selectBtn.AbsolutePosition.X, 0, selectBtn.AbsolutePosition.Y - popup.Size.Y.Offset - 5)
            end
        end)
        
        local actionBtn = Instance.new("TextButton", content)
        actionBtn.Size = UDim2.new(1, 0, 0, 30)
        actionBtn.Position = UDim2.new(0, 0, 0, 50)
        actionBtn.BackgroundColor3 = Color3.fromRGB(157, 0, 255)
        actionBtn.TextColor3 = Color3.new(1, 1, 1)
        actionBtn.Font = Enum.Font.SourceSansBold
        actionBtn.TextSize = 12
        actionBtn.Text = "🔥 PEGAR"
        actionBtn.BorderSizePixel = 0
        
        Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 4)
        
        actionBtn.MouseButton1Click:Connect(function()
            notify("Bring", "Buscando " .. #SelectedItems.bring .. " item(ns)...", 2)
        end)
    else
        local itemsContainer = Instance.new("Frame", content)
        itemsContainer.Size = UDim2.new(1, 0, 1, 0)
        itemsContainer.BackgroundTransparency = 1
        
        local itemsLayout = Instance.new("UIListLayout", itemsContainer)
        itemsLayout.Padding = UDim.new(0, 5)
        itemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        for _, item in pairs(category.items) do
            local itemBtn = Instance.new("TextButton", itemsContainer)
            itemBtn.Size = UDim2.new(1, 0, 0, 30)
            itemBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
            itemBtn.TextColor3 = Color3.new(1, 1, 1)
            itemBtn.Font = Enum.Font.SourceSans
            itemBtn.TextSize = 12
            itemBtn.Text = item.icon .. " " .. item.name .. " [TP]"
            itemBtn.BorderSizePixel = 0
            
            Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)
            
            itemBtn.MouseButton1Click:Connect(function()
                local target = findObject(item.internalName)
                if target then
                    notify("Aviso", "Teleportando para " .. item.name .. "...", 3)
                    teleportTo(target.Position)
                else
                    notify("Erro", "Não foi possível encontrar " .. item.name .. " no momento!", 4)
                end
            end)
        end
        
        content.Size = UDim2.new(1, -10, 0, #category.items * 35)
    end
    
    return content
end

---------------------------------------------------------
-- [ INTERFACE ]
---------------------------------------------------------
local Color_NavyStrong = Color3.fromRGB(20, 30, 50)
local Color_NavyWeak = Color3.fromRGB(15, 20, 35)
local Color_TopBar = Color3.fromRGB(10, 15, 25)
local Color_RedStrong = Color3.fromRGB(255, 60, 60)

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
splashInfo2.Size, splashInfo2.Position, splashInfo2.BackgroundTransparency, splashInfo2.Text, splashInfo2.TextColor3, splashInfo2.Font, splashInfo2.TextSize, splashInfo2.TextTransparency = UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0.5, 0), 1, "15/01/2026 | Com Novo Sistema de Accordion", Color3.fromRGB(200, 200, 200), Enum.Font.SourceSans, 18, 1

-- MAIN FRAME
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size, mainFrame.Position, mainFrame.BackgroundColor3, mainFrame.BorderSizePixel, mainFrame.Visible, mainFrame.ClipsDescendants = UDim2.new(0, 500, 0, 350), UDim2.new(0.5, -250, 0.5, -175), Color_NavyWeak, 0, false, true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- TOP BAR
local topBar = Instance.new("Frame", mainFrame)
topBar.Size, topBar.BackgroundColor3, topBar.BorderSizePixel = UDim2.new(1, 0, 0, 40), Color_TopBar, 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 10)
local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Size, titleLabel.Position, titleLabel.BackgroundTransparency, titleLabel.Text, titleLabel.TextColor3, titleLabel.Font, titleLabel.TextSize, titleLabel.TextXAlignment = UDim2.new(1, -100, 1, 0), UDim2.new(0, 15, 0, 0), 1, "Pudim Hub v10.1", Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 18, Enum.TextXAlignment.Left

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

-- TAB LIST
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

-- POPUP FRAME
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
bottomLabel.Size, bottomLabel.Position, bottomLabel.BackgroundTransparency, bottomLabel.Text, bottomLabel.TextColor3, bottomLabel.Font, bottomLabel.TextSize, bottomLabel.TextXAlignment = UDim2.new(1, -100, 1, 0), UDim2.new(0, 15, 0, 0), 1, "Pudim Hub - v10.1", Color3.fromRGB(150, 150, 150), Enum.Font.SourceSans, 14, Enum.TextXAlignment.Left

-- MOBILE TOGGLE
local mobileToggle = Instance.new("TextButton", screenGui)
mobileToggle.Size, mobileToggle.Position, mobileToggle.BackgroundColor3, mobileToggle.Text, mobileToggle.TextColor3, mobileToggle.Font, mobileToggle.TextSize, mobileToggle.Visible = UDim2.new(0, 100, 0, 30), UDim2.new(0.5, -50, 0, -40), Color3.fromRGB(20, 30, 50), "Pudim Hub", Color3.new(1, 1, 1), Enum.Font.SourceSansBold, 16, false
Instance.new("UICorner", mobileToggle).CornerRadius = UDim.new(0, 6)

-- FUNÇÕES DE GUI
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

local function createToggle(parent, text, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size, frame.BackgroundColor3 = UDim2.new(1, -10, 0, 40), Color3.fromRGB(30, 45, 70)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    local label = Instance.new("TextLabel", frame)
    label.Size, label.Position, label.BackgroundTransparency, label.Text, label.TextColor3, label.Font, label.TextSize, label.TextXAlignment = UDim2.new(1, -60, 1, 0), UDim2.new(0, 15, 0, 0), 1, text, Color3.new(1, 1, 1), Enum.Font.SourceSans, 16, Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", frame)
    btn.Size, btn.Position, btn.BackgroundColor3, btn.Text = UDim2.new(0, 40, 0, 20), UDim2.new(1, -50, 0.5, -10), Color3.fromRGB(50, 65, 90), ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local circle = Instance.new("Frame", btn)
    circle.Size, circle.Position, circle.BackgroundColor3 = UDim2.new(0, 16, 0, 16), UDim2.new(0, 2, 0.5, -8), Color3.new(1, 1, 1)
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(50, 65, 90)}):Play()
        TweenService:Create(circle, TweenInfo.new(0.3), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        
        if state then
            notify("Aviso", "Você ativou " .. text .. ".", 3)
        end
        
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

-- ABAS
local farmPage = createTab("Farm", "🚜")
createSection(farmPage, "Combate")
createToggle(farmPage, "Animal Farm (PASSIVOS)", function(v) Config.AnimalFarm = v end)
createSlider(farmPage, "Alcance Animal Farm", 10, 375, 50, function(v) Config.AnimalFarmRange = v end)
createSection(farmPage, "Combate")
createToggle(farmPage, "Hit box Aura", function(v) Config.HitboxAura = v end)
createSlider(farmPage, "Alcance Hitbox", 0, 375, 40, function(v) Config.HitboxRange = v end)
createSection(farmPage, "Controle")
createToggle(farmPage, "Aura de Gelo", function(v) 
    Config.IceAura = v 
    if not v then
        for mob, root in pairs(FrozenMobs) do
            if root and root.Parent then root.Anchored = false end
        end
        FrozenMobs = {}
    end
end)
createSlider(farmPage, "Alcance Gelo", 0, 375, 40, function(v) Config.IceRange = v end)
createSection(farmPage, "Automação")
createToggle(farmPage, "Alimentar fogueira", function(v) 
    Config.AutoFeedCampfire = v 
    if v then task.spawn(autoFeedCampfire) end 
end)
createSection(farmPage, "Hitbox")
createToggle(farmPage, "Hitbox Árvores", function(v) Config.TreeHitbox = v end)
createSlider(farmPage, "Alcance Hitbox Árvore", 0, 375, 40, function(v) Config.TreeHitboxRange = v end)
createSlider(farmPage, "Tamanho Hitbox Árvore", 0, 375, 25, function(v) Config.TreeHitboxSize = v end)
createSection(farmPage, "Automação")
local modesBtn = createButton(farmPage, "Modos: FOGUEIRA", function() 
    popupFrame.Position = UDim2.new(0, modesBtn.AbsolutePosition.X - mainFrame.AbsolutePosition.X, 0, modesBtn.AbsolutePosition.Y - mainFrame.AbsolutePosition.Y - popupFrame.Size.Y.Offset - 5)
    popupFrame.Visible = not popupFrame.Visible 
end)
local function selectMode(mode, name) Config.AutoFarmMode = mode modesBtn.Text = "Modos: " .. name popupFrame.Visible = false end
createButton(popupList, "Modo 1: Fogueira", function() selectMode(1, "FOGUEIRA") end).Size = UDim2.new(1, 0, 0, 30)
createButton(popupList, "Modo 2: Jogador", function() selectMode(2, "JOGADOR") end).Size = UDim2.new(1, 0, 0, 30)
createToggle(farmPage, "Auto Farm Baús", function(v) Config.AutoFarmChests = v if v then task.spawn(autoFarmChests) end end)
createToggle(farmPage, "Auto Farm Triturador", function(v) 
    Config.AutoGrinder = v 
    if v then 
        task.spawn(function()
            local itemsProcessed = 0
            while Config.AutoGrinder do
                local grinder = nil
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj.Name:lower():find("grinder") or obj.Name:lower():find("triturador") then
                        grinder = obj.PrimaryPart or (obj:IsA("BasePart") and obj) or obj:FindFirstChildOfClass("BasePart")
                        if grinder then break end
                    end
                end
                
                if grinder then
                    local foundItem = false
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if not Config.AutoGrinder then break end
                        local isTarget = false
                        for _, name in pairs(Targets.GrinderItems) do
                            if obj.Name == name then isTarget = true break end
                        end
                        
                        if isTarget and (obj:IsA("BasePart") or (obj:IsA("Model") and obj.PrimaryPart)) then
                            foundItem = true
                            local itemPart = obj:IsA("Model") and obj.PrimaryPart or obj
                            itemPart.CFrame = CFrame.new(grinder.Position + Vector3.new(0, 5, 0))
                            itemsProcessed = itemsProcessed + 1
                            notify("Auto Triturador", "Triturando: " .. obj.Name .. "\nTotal: " .. itemsProcessed, 2)
                            task.wait(1)
                        end
                    end
                    if not foundItem then task.wait(1) end
                else
                    notify("Erro", "Triturador não encontrado!", 2)
                    task.wait(5)
                end
                task.wait(0.1)
            end
            notify("Auto Triturador", "Processo finalizado.\nTotal triturado: " .. itemsProcessed, 3)
        end)
    end 
end)

local bringPage = createTab("Bring", "🧲")
createButton(bringPage, "🔥 BRING TUDO 🔥", function() bringObjects(AllItemsList) end)
local bFuncs = {{"👶 Crianças", {"Lost Child"}}, {"🍎 Comidas", Targets.Fruits}, {"🛠️ Ferramentas", Targets.Tools}, {"🩹 Médico", Targets.Medical}, {"🌱 Seeds", Targets.Seeds}, {"🪵 Logs", Targets.Wood}, {"🔥 Combustão", Targets.Combustion}, {"🛡️ Armaduras", Targets.Armor}}
for _, f in pairs(bFuncs) do createButton(bringPage, "Bring " .. f[1], function() bringObjects(f[2]) end) end

local espPage = createTab("ESP", "👁️")
local espList = {"Children", "Animals", "Fruits", "Chests", "Wood", "Trees"}
for _, k in pairs(espList) do createToggle(espPage, "ESP "..k, function(v) Config.ESP[k] = v end) end

local movePage = createTab("Move", "🏃")
createSection(movePage, "Automação")
createToggle(movePage, "Auto Click", function(v) 
    Config.AutoClick = v 
    if v then
        task.spawn(function()
            local VirtualUser = game:GetService("VirtualUser")
            while Config.AutoClick do
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(0,0))
                task.wait(1)
            end
        end)
    end
end)
createSection(movePage, "Personagem")
createSlider(movePage, "Velocidade", 16, 300, 16, function(v) Config.Speed = v end)
createSlider(movePage, "Pulo", 50, 500, 50, function(v) Config.Jump = v end)
createToggle(movePage, "Full Bright / No Fog", function(v) Config.NoFog, Config.FullBright = v, v end)
createToggle(movePage, "Fly", function(v) Config.Fly = v end)
createSection(movePage, "Sobrevivência")
createToggle(movePage, "Auto Heal (ITENS)", function(v) Config.AutoHeal = v end)
createSlider(movePage, "Heal em %", 1, 80, 40, function(v) Config.AutoHealHealth = v end)

-- NOVA ABA TP COM ACCORDION
local tpPage = createTab("Tp", "📍")
createSection(tpPage, "Teleportes - Sistema Accordion")
for _, category in pairs(TPCategories) do
    createAccordionHeader(tpPage, category, "tp")
    createAccordionContent(tpPage, category, "tp")
end


local configPage = createTab("Config", "⚙️")
createSection(configPage, "Painel de Informações")
local infoFrame = Instance.new("Frame", configPage)
infoFrame.Size, infoFrame.BackgroundColor3 = UDim2.new(1, -10, 0, 260), Color3.fromRGB(25, 35, 55)
Instance.new("UICorner", infoFrame).CornerRadius = UDim.new(0, 8)
local infoLabel = Instance.new("TextLabel", infoFrame)
infoLabel.Size, infoLabel.Position, infoLabel.BackgroundTransparency, infoLabel.Text, infoLabel.TextColor3, infoLabel.Font, infoLabel.TextSize, infoLabel.TextXAlignment, infoLabel.TextWrapped, infoLabel.TextYAlignment = UDim2.new(1, -20, 1, -10), UDim2.new(0, 10, 0, 10), 1, "Carregando...", Color3.new(1, 1, 1), Enum.Font.SourceSans, 14, Enum.TextXAlignment.Left, true, Enum.TextYAlignment.Top
infoLabel.ClipsDescendants = false

local tracerBtn = createButton(configPage, "Linhas players: OFF", function()
    Config.PlayerTracers = not Config.PlayerTracers
    tracerBtn.Text = "Linhas players: " .. (Config.PlayerTracers and "ON" or "OFF")
    tracerBtn.TextColor3 = Config.PlayerTracers and Color3.fromRGB(0, 255, 0) or Color3.new(1, 1, 1)
end)
tracerBtn.Size, tracerBtn.Position = UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 300)

local removeChestAnimBtn = createButton(configPage, "Remover animações de baú: OFF", function()
    Config.RemoveChestAnimation = not Config.RemoveChestAnimation
    removeChestAnimBtn.Text = "Remover animações de baú: " .. (Config.RemoveChestAnimation and "ON" or "OFF")
    removeChestAnimBtn.TextColor3 = Config.RemoveChestAnimation and Color3.fromRGB(0, 255, 0) or Color3.new(1, 1, 1)
end)
removeChestAnimBtn.Size = UDim2.new(1, -20, 0, 30)
removeChestAnimBtn.Position = UDim2.new(0, 10, 0, 340)

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
createToggle(configPage, "Auto Explorar", function(v) Config.AutoExplore = v if v then task.spawn(autoExplore) end end)
createSection(configPage, "Teleporte")
createButton(configPage, "Resetar Posição (Fogueira)", function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    local campfire = workspace:FindFirstChild("Campfire", true)
    if hrp and campfire then hrp.CFrame = CFrame.new((campfire.PrimaryPart and campfire.PrimaryPart.Position or campfire.Position) + Vector3.new(0, 5, 0)) end
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
    while task.wait(0.1) do
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local descendants = workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if Config.AnimalFarm and table.find(Targets.PassiveAnimals, obj.Name) and obj:IsA("Model") then
                local r = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
                if r and (hrp.Position - r.Position).Magnitude <= Config.AnimalFarmRange then dealDamage(obj, false) end
            end

        end
        updateESP()
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if Config.AutoHeal and player.Character and player.Character:FindFirstChild("Humanoid") then
            local h = player.Character.Humanoid
            if (h.Health / h.MaxHealth) * 100 <= Config.AutoHealHealth then useMedicalItem() end
        end
        
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local targets = {}
            local npcFolders = {workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Monsters"), workspace:FindFirstChild("Mobs"), workspace:FindFirstChild("Animals"), workspace:FindFirstChild("Creatures")}
            for _, folder in pairs(npcFolders) do
                if folder then for _, obj in pairs(folder:GetChildren()) do table.insert(targets, obj) end end
            end
            for _, obj in pairs(workspace:GetChildren()) do
                if obj:IsA("Model") and not game.Players:GetPlayerFromCharacter(obj) and obj:FindFirstChildOfClass("Humanoid") then
                    table.insert(targets, obj)
                end
            end

            for _, obj in pairs(targets) do
                local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Head") or obj:FindFirstChildOfClass("BasePart")
                if root and root:IsA("BasePart") then
                    local dist = (hrp.Position - root.Position).Magnitude
                    
                    -- Lógica de Hitbox Aura
                    if Config.HitboxAura then
                        local head = obj:FindFirstChild("Head")
                        if head and head:IsA("BasePart") then
                            if not OriginalSizes[head] then OriginalSizes[head] = head.Size end
                            if dist <= Config.HitboxRange then
                                head.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                                head.Transparency = 1
                                head.CanCollide = false
                            else
                                head.Size = OriginalSizes[head]
                                head.Transparency = 0
                            end
                        end
                    end

                    -- Lógica de Aura de Gelo
                    if Config.IceAura then
                        if dist <= Config.IceRange then
                            root.Anchored = true
                            FrozenMobs[obj] = root
                        elseif FrozenMobs[obj] then
                            root.Anchored = false
                            FrozenMobs[obj] = nil
                        end
                    end
                end
            end

            -- Lógica de Hitbox de Árvores (V4 OTIMIZADA - SEM LAG)
            if Config.TreeHitbox then
                -- Cache das árvores para não usar GetDescendants toda hora (causa do lag)
                if not TreeCache then
                    TreeCache = {}
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("BasePart") then
                            local name = obj.Name:lower()
                            if name:find("tree") or name:find("trunk") then
                                if not obj:FindFirstAncestorOfClass("Player") and not obj.Parent:FindFirstChildOfClass("Humanoid") then
                                    table.insert(TreeCache, obj)
                                end
                            end
                        end
                    end
                    -- Limpa o cache a cada 30 segundos para novos objetos
                    task.delay(30, function() TreeCache = nil end)
                end

                for _, obj in pairs(TreeCache) do
                    if obj and obj.Parent then
                        if not OriginalTreeSizes[obj] then OriginalTreeSizes[obj] = {Size = obj.Size, Trans = obj.Transparency} end
                        local dist = (hrp.Position - obj.Position).Magnitude
                        if dist <= Config.TreeHitboxRange then
                            obj.Size = Vector3.new(Config.TreeHitboxSize, Config.TreeHitboxSize, Config.TreeHitboxSize)
                            obj.Transparency = 1 -- Invisível conforme solicitado
                            obj.CanCollide = false -- REMOVE A PAREDE INVISÍVEL
                        else
                            if OriginalTreeSizes[obj] then
                                obj.Size = OriginalTreeSizes[obj].Size
                                obj.Transparency = OriginalTreeSizes[obj].Trans
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Lógica de Fly (Voo)
local flyBV, flyBG
task.spawn(function()
    while true do
        task.wait()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local h = char and char:FindFirstChild("Humanoid")
        
        if Config.Fly and hrp and h then
            if not flyBV then
                flyBV = Instance.new("BodyVelocity", hrp)
                flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                flyBV.Velocity = Vector3.new(0, 0, 0)
                flyBG = Instance.new("BodyGyro", hrp)
                flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                flyBG.CFrame = hrp.CFrame
            end
            h.PlatformStand = true
            local moveDir = h.MoveDirection
            local camCF = workspace.CurrentCamera.CFrame
            local vel = Vector3.new(0, 0, 0)
            
            if moveDir.Magnitude > 0 then
                vel = moveDir * Config.Speed
            end
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vel = vel + Vector3.new(0, Config.Speed, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vel = vel + Vector3.new(0, -Config.Speed, 0)
            end
            
            flyBV.Velocity = vel
            flyBG.CFrame = camCF
        else
            if flyBV then flyBV:Destroy() flyBV = nil end
            if flyBG then flyBG:Destroy() flyBG = nil end
            if h then h.PlatformStand = false end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local h = char and char:FindFirstChild("Humanoid")
    if h and not Config.Fly then
        h.WalkSpeed = Config.Speed
        h.JumpPower = Config.Jump
        h.UseJumpPower = true
    end
    if Config.NoFog or Config.FullBright then
        Lighting.FogEnd, Lighting.ClockTime, Lighting.Brightness, Lighting.GlobalShadows, Lighting.Ambient = 100000, 12, 2, false, Color3.new(1,1,1)
    end
end)

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

print("✅ Pudim Hub v10.1 - Carregado com Sucesso!")
print("📍 Sistema de Accordion para TPs e Brings ativado!")
print("🎯 Nova aba: 'Tp' (Accordion)")


local advLabel = Instance.new("TextLabel", container)
advLabel.Size = UDim2.new(1, 0, 0, 30)
advLabel.Text = "--- AVANÇADO ---"
advLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
advLabel.BackgroundTransparency = 1
advLabel.Font = Enum.Font.SourceSansBold

createToggle("Notificações", "Notifications")
\n-- [[ INTEGRACAO AUTO GRINDER ]]\n
-- [[ NOVO BLOCO DE CÓDIGO: AUTO FARM TRITURADOR ]]

-- 1. ADICIONE ESTA OPÇÃO NA SUA TABELA 'Config' (Linha 24 do seu script)
-- Exemplo:
-- local Config = {
--     Notifications = true,
--     AutoGrinder = false, -- << NOVO
--     HitboxAura = false, HitboxRange = 40, HitboxSize = 50,
--     -- ... restante da Config
-- }

-- 2. LISTA DE ITENS PARA TRITURAR (Ajuste conforme o nome exato no jogo)
local GrinderItems = {
    "Log", "Stick", "Super Log", 
    "Coal", "Charcoal", "Gasoline", "Fuel", "Fuel Canister", "Oil", "Biofuel",
    "Radio", "Screws", "Metal Plate", "Metal Chair", "Scrap Metal"
}

-- 3. FUNÇÃO DE NOTIFICAÇÃO (Adapte para a sua função de notificação, se for diferente de 'SendNotification')
-- Se você já tem uma função de notificação no seu script, use-a. Caso contrário, use esta:
local function SendNotification(title, message)
    -- Esta é uma implementação básica. Use a sua função de notificação existente.
    print("[NOTIFICAÇÃO] " .. title .. ": " .. message)
end

-- 4. FUNÇÃO PARA ENCONTRAR O TRITURADOR (GRINDER)
local function FindGrinder()
    -- Procura o Triturador no workspace. O nome pode variar (Grinder, Triturador, etc.)
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Tenta encontrar a parte principal do Triturador
        if obj.Name:lower():find("grinder") or obj.Name:lower():find("triturador") then
            return obj.PrimaryPart or obj:FindFirstChild("Part") or obj
        end
    end
    return nil
end

-- 5. FUNÇÃO PRINCIPAL DE AUTO FARM TRITURADOR
local function AutoFarmGrinder()
    if not Config.AutoGrinder then return end

    local grinder = FindGrinder()
    if not grinder then
        SendNotification("Auto Triturador", "Triturador não encontrado no mapa!")
        return
    end

    local itemsFound = 0
    -- Posição para teleportar o item (um pouco acima do Triturador)
    local grinderPosition = grinder.Position + Vector3.new(0, 5, 0) 

    -- Itera sobre todos os itens no workspace
    for _, item in pairs(workspace:GetDescendants()) do
        -- Verifica se o item é um Part e se o nome está na lista de itens para triturar
        if item:IsA("BasePart") and table.find(GrinderItems, item.Name) then
            
            -- Teleporta o item para a posição acima do Triturador
            item.CFrame = CFrame.new(grinderPosition)
            item.Anchored = false -- Garante que ele caia no Triturador
            
            itemsFound = itemsFound + 1
            SendNotification("Auto Triturador", "Triturando item: " .. item.Name .. " (" .. itemsFound .. " itens processados)")
            
            -- Espera 1 segundo antes de processar o próximo item
            task.wait(1) 
        end
    end

    if itemsFound > 0 then
        SendNotification("Auto Triturador", "Processo concluído! " .. itemsFound .. " itens triturados.")
    else
        SendNotification("Auto Triturador", "Nenhum item para triturar encontrado no mapa.")
    end
end

-- 6. LOOP DE EXECUÇÃO (Adicione ao seu loop principal de tarefas)
task.spawn(function()
    while task.wait(5) do -- Verifica a cada 5 segundos se a função está ativa
        if Config.AutoGrinder then
            pcall(AutoFarmGrinder)
        end
    end
end)

-- 7. INTEGRAÇÃO COM A GUI (Você precisará adicionar um botão/checkbox na sua GUI)
-- O botão deve alternar o valor de Config.AutoGrinder entre true e false.
-- Exemplo de como o código da GUI deve ser:
-- Checkbox.MouseButton1Click:Connect(function()
--     Config.AutoGrinder = not Config.AutoGrinder
--     if Config.AutoGrinder then
--         SendNotification("Auto Triturador", "Ativado!")
--     else
--         SendNotification("Auto Triturador", "Desativado!")
--     end
-- end)
