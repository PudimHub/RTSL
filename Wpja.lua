-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║        PUDIM HUB v4 — 99 Nights in the Forest 2026              ║
-- ║  ESP + BRING INDIVIDUAL — Dados reais Wiki Fandom 2026           ║
-- ║                                                                   ║
-- ║  ESP:   20 categorias separadas (toggle individual)              ║
-- ║  BRING: 16 brings individuais (1 botão por tipo de item)         ║
-- ║                                                                   ║
-- ║  FIXES:                                                           ║
-- ║   • ESP só mostra entidades com Health > 0 (sem mortos)          ║
-- ║   • ESP descarta entidades fora do mapa (pré-spawn)              ║
-- ║   • Bring só pega Anchored = false (itens soltos)                ║
-- ║   • Bring match EXATO de nome (sem substring)                    ║
-- ║   • Cache assíncrono (task.spawn + yield/100) — zero freeze      ║
-- ║   • Re-validação de Health a cada frame no render                ║
-- ╚═══════════════════════════════════════════════════════════════════╝

local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")

local Player = Players.LocalPlayer
local Cam    = workspace.CurrentCamera

-- ════════════════════════════════════════════════════════
--  GUI RAIZ
-- ════════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "PudimHub2026"
ScreenGui.Parent         = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn   = false
ScreenGui.DisplayOrder   = 999
ScreenGui.IgnoreGuiInset = true

-- Janela principal
local Win = Instance.new("Frame", ScreenGui)
Win.Name             = "Win"
Win.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
Win.BorderSizePixel  = 0
Win.Position         = UDim2.new(0, 12, 0.5, -320)
Win.Size             = UDim2.new(0, 258, 0, 640)
Win.Active           = true
Win.Draggable        = true
Win.ZIndex           = 2
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 12)
local winStroke = Instance.new("UIStroke", Win)
winStroke.Color = Color3.fromRGB(50, 55, 75); winStroke.Thickness = 1.4

-- ── Header ──────────────────────────────────────────────
local Header = Instance.new("Frame", Win)
Header.BackgroundColor3 = Color3.fromRGB(72, 87, 210)
Header.BorderSizePixel  = 0
Header.Size             = UDim2.new(1, 0, 0, 40)
Header.ZIndex           = 5
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

-- Fix visual (tampa canto inferior do header)
local headerFix = Instance.new("Frame", Header)
headerFix.BackgroundColor3 = Color3.fromRGB(72, 87, 210)
headerFix.BorderSizePixel  = 0
headerFix.Position         = UDim2.new(0, 0, 0.5, 0)
headerFix.Size             = UDim2.new(1, 0, 0.5, 0)
headerFix.ZIndex           = 5

local HTitle = Instance.new("TextLabel", Header)
HTitle.BackgroundTransparency = 1
HTitle.Position       = UDim2.new(0, 12, 0, 0)
HTitle.Size           = UDim2.new(1, -50, 1, 0)
HTitle.Font           = Enum.Font.GothamBlack
HTitle.Text           = "🌲  PUDIM HUB 2026"
HTitle.TextColor3     = Color3.fromRGB(255, 255, 255)
HTitle.TextSize       = 13
HTitle.TextXAlignment = Enum.TextXAlignment.Left
HTitle.ZIndex         = 6

local HVer = Instance.new("TextLabel", Header)
HVer.BackgroundTransparency = 1
HVer.Position       = UDim2.new(1, -48, 0, 0)
HVer.Size           = UDim2.new(0, 44, 1, 0)
HVer.Font           = Enum.Font.Gotham
HVer.Text           = "v4.0"
HVer.TextColor3     = Color3.fromRGB(180, 200, 255)
HVer.TextSize       = 10
HVer.TextXAlignment = Enum.TextXAlignment.Right
HVer.ZIndex         = 6

-- ── Tabs (ESP / BRING) ────────────────────────────────────
local TabBar = Instance.new("Frame", Win)
TabBar.BackgroundColor3 = Color3.fromRGB(14, 15, 20)
TabBar.BorderSizePixel  = 0
TabBar.Position         = UDim2.new(0, 0, 0, 40)
TabBar.Size             = UDim2.new(1, 0, 0, 34)
TabBar.ZIndex           = 5

local TabLayout = Instance.new("UIListLayout", TabBar)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Padding  = UDim.new(0, 6)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeTab(txt, color, order)
    local btn = Instance.new("TextButton", TabBar)
    btn.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
    btn.BorderSizePixel  = 0
    btn.Size             = UDim2.new(0, 108, 0, 26)
    btn.Font             = Enum.Font.GothamBold
    btn.Text             = txt
    btn.TextColor3       = Color3.fromRGB(130, 145, 175)
    btn.TextSize         = 10
    btn.LayoutOrder      = order
    btn.ZIndex           = 6
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", btn)
    s.Color = Color3.fromRGB(40, 44, 58); s.Thickness = 1
    return btn, s
end

local tabEspBtn,   tabEspStroke   = makeTab("👁  ESP",    Color3.fromRGB(72,87,210),  1)
local tabBringBtn, tabBringStroke = makeTab("⬇  BRING",  Color3.fromRGB(255,120,40), 2)

-- ── Scroll para ESP ────────────────────────────────────
local function makeScroll(yOff)
    local sf = Instance.new("ScrollingFrame", Win)
    sf.BackgroundTransparency  = 1
    sf.BorderSizePixel         = 0
    sf.Position                = UDim2.new(0, 0, 0, yOff)
    sf.Size                    = UDim2.new(1, 0, 1, -yOff)
    sf.ScrollBarThickness      = 3
    sf.ScrollBarImageColor3    = Color3.fromRGB(72, 87, 210)
    sf.AutomaticCanvasSize     = Enum.AutomaticSize.Y
    sf.CanvasSize              = UDim2.new(0, 0, 0, 0)
    sf.ZIndex                  = 3
    sf.Visible                 = false
    local ul = Instance.new("UIListLayout", sf)
    ul.Padding   = UDim.new(0, 4)
    ul.SortOrder = Enum.SortOrder.LayoutOrder
    local up = Instance.new("UIPadding", sf)
    up.PaddingTop    = UDim.new(0, 8)
    up.PaddingLeft   = UDim.new(0, 8)
    up.PaddingRight  = UDim.new(0, 8)
    up.PaddingBottom = UDim.new(0, 10)
    return sf
end

local EspScroll   = makeScroll(74)
local BringScroll = makeScroll(74)

-- ── Lógica das Tabs ──────────────────────────────────────
local activeTab = "esp"
local function selectTab(which)
    activeTab = which
    EspScroll.Visible   = (which == "esp")
    BringScroll.Visible = (which == "bring")

    -- ESP tab style
    if which == "esp" then
        TweenService:Create(tabEspBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(72,87,210),
            TextColor3       = Color3.fromRGB(255,255,255),
        }):Play()
        tabEspStroke.Color = Color3.fromRGB(100,120,255)
        TweenService:Create(tabBringBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(24,26,34),
            TextColor3       = Color3.fromRGB(130,145,175),
        }):Play()
        tabBringStroke.Color = Color3.fromRGB(40,44,58)
    else
        TweenService:Create(tabBringBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(200,90,20),
            TextColor3       = Color3.fromRGB(255,255,255),
        }):Play()
        tabBringStroke.Color = Color3.fromRGB(255,150,60)
        TweenService:Create(tabEspBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(24,26,34),
            TextColor3       = Color3.fromRGB(130,145,175),
        }):Play()
        tabEspStroke.Color = Color3.fromRGB(40,44,58)
    end
end

tabEspBtn.MouseButton1Click:Connect(function()   selectTab("esp")   end)
tabBringBtn.MouseButton1Click:Connect(function() selectTab("bring") end)

-- ════════════════════════════════════════════════════════
--  CANVAS ESP (labels flutuantes)
-- ════════════════════════════════════════════════════════
local EspCanvas = Instance.new("Frame", ScreenGui)
EspCanvas.BackgroundTransparency = 1
EspCanvas.Size   = UDim2.new(1, 0, 1, 0)
EspCanvas.ZIndex = 1

-- ════════════════════════════════════════════════════════
--  DEFINIÇÃO — CATEGORIAS ESP
-- ════════════════════════════════════════════════════════
-- tipo = "player" | "entity" | "item"
-- Para "entity": nomes dos Models no workspace
-- Para "item":   nomes de BasePart/Tool (Anchored = false)

local ESP_CATS = {

    -- ─── PLAYERS ────────────────────────────────────────
    { key="Players", label="👤 Players",
      cor=Color3.fromRGB(255,80,80), tipo="player", alcance=math.huge,
      desc="Todos os players no servidor" },

    -- ─── CRIANÇAS ───────────────────────────────────────
    { key="Kids", label="👶 Crianças Perdidas",
      cor=Color3.fromRGB(100,220,255), tipo="entity", alcance=math.huge,
      desc="Dino, Kraken, Squid, Koala Kid",
      nomes={"Dino Kid","Kraken Kid","Squid Kid","Koala Kid",
             "DinoKid","KrakenKid","SquidKid","KoalaKid","Kid","Child","MissingChild"} },

    -- ─── ANIMAIS PASSIVOS (wiki: Animals — passive) ─────
    { key="AnimPassivo", label="🐰 Animais Passivos",
      cor=Color3.fromRGB(130,255,170), tipo="entity", alcance=500,
      desc="Bunny, Horse, Kiwi, Turkey — não atacam",
      nomes={"Bunny","Horse","Kiwi","Turkey"} },

    -- ─── ANIMAIS AGRESSIVOS (wiki: Hostile Entities — animais) ──
    { key="AnimAgressivo", label="🐺 Animais Agressivos",
      cor=Color3.fromRGB(255,175,30), tipo="entity", alcance=600,
      desc="Wolf, Alpha Wolf, Bear, Polar Bear, Arctic Fox, Frog, Scorpion, Hellephant, Meteor Crab, Mammoth",
      nomes={"Wolf","Alpha Wolf","AlphaWolf",
             "Bear","Polar Bear","PolarBear",
             "Arctic Fox","ArcticFox",
             "Frog","Blue Frog","Purple Frog","BlueFrog","PurpleFrog",
             "Scorpion","Hellephant",
             "Meteor Crab","MeteorCrab",
             "Mammoth"} },

    -- ─── MONSTROS (wiki: Monsters) ──────────────────────
    { key="Monstros", label="💀 Monstros",
      cor=Color3.fromRGB(255,50,50), tipo="entity", alcance=math.huge,
      desc="The Deer, The Owl, The Ram, The Bat",
      nomes={"The Deer","TheDeer","Deer",
             "The Owl","TheOwl","Owl",
             "The Ram","TheRam","Ram",
             "The Bat","TheBat","Bat"} },

    -- ─── CULTISTAS ──────────────────────────────────────
    { key="Cultistas", label="⚔️ Cultistas",
      cor=Color3.fromRGB(195,60,200), tipo="entity", alcance=math.huge,
      desc="Cultist, Crossbow, Juggernaut, King, Shadow, Brute",
      nomes={"Cultist","Melee Cultist","MeleeCultist",
             "Crossbow Cultist","CrossbowCultist",
             "Juggernaut Cultist","JuggernautCultist","Juggernaut",
             "Cultist King","CultistKing",
             "Shadow Cultist","ShadowCultist",
             "Brute Cultist","BruteCultist"} },

    -- ─── ALIENS ─────────────────────────────────────────
    { key="Aliens", label="👽 Aliens",
      cor=Color3.fromRGB(60,255,200), tipo="entity", alcance=700,
      desc="Alien, Elite Alien",
      nomes={"Alien","Elite Alien","EliteAlien","NormalAlien"} },

    -- ════ ITENS ═══════════════════════════════════════════

    -- ─── LOG (separado para facilidade) ─────────────────
    { key="EspLog", label="🪵 Log",
      cor=Color3.fromRGB(190,130,60), tipo="item", alcance=400,
      desc="Log — combustível principal",
      nomes={"Log"} },

    -- ─── COMBUSTÍVEL GERAL ──────────────────────────────
    { key="EspCombustivel", label="🔥 Combustível",
      cor=Color3.fromRGB(255,120,30), tipo="item", alcance=400,
      desc="Coal, Biofuel, Fuel Canister, Oil Barrel, Purple Fur Tuft, Chair",
      nomes={"Coal","Biofuel","Oil Barrel","OilBarrel",
             "Fuel Canister","FuelCanister",
             "Purple Fur Tuft","PurpleFurTuft","Chair"} },

    -- ─── CARCAÇAS ───────────────────────────────────────
    { key="EspCarcacas", label="🦴 Carcaças",
      cor=Color3.fromRGB(180,100,50), tipo="item", alcance=350,
      desc="Wolf/Bear/Cultist/Alien Corpse…",
      nomes={"Wolf Corpse","WolfCorpse","Alpha Wolf Corpse","AlphaWolfCorpse",
             "Bear Corpse","BearCorpse","Cultist Corpse","CultistCorpse",
             "Crossbow Cultist Corpse","CrossbowCultistCorpse",
             "Juggernaut Cultist Corpse","JuggernautCultistCorpse",
             "Cultist King Corpse","CultistKingCorpse",
             "Alien Corpse","AlienCorpse","Elite Alien Corpse","EliteAlienCorpse"} },

    -- ─── SUCATA ─────────────────────────────────────────
    { key="EspSucata", label="🔩 Sucata",
      cor=Color3.fromRGB(155,210,255), tipo="item", alcance=400,
      desc="Bolt, Sheet Metal, UFO Junk, Broken Fan, Old Radio, Tyre…",
      nomes={"Bolt","Sheet Metal","SheetMetal","UFO Junk","UFOJunk",
             "UFO Component","UFOComponent","UFO Scrap","UFOScrap",
             "Broken Fan","BrokenFan","Old Radio","OldRadio",
             "Broken Radio","BrokenRadio","Broken Microwave","BrokenMicrowave",
             "Tyre","Metal Chair","MetalChair","Old Car Engine","OldCarEngine",
             "Washing Machine","WashingMachine",
             "Cultist Experiment","CultistExperiment",
             "Cultist Prototype","CultistPrototype"} },

    -- ─── MATERIAIS ──────────────────────────────────────
    { key="EspMateriais", label="💎 Materiais",
      cor=Color3.fromRGB(220,175,255), tipo="item", alcance=400,
      desc="Cultist Gem, Forest Gem, Mossy Coin, Meteor Shard, Obsidiron…",
      nomes={"Cultist Gem","CultistGem","Forest Gem","ForestGem",
             "Forest Gem Fragment","ForestGemFragment",
             "Mossy Coin","MossyCoin","Flower","Sapling",
             "Sacrifice Totem","SacrificeTotem",
             "Meteor Shard","MeteorShard","Gold Shard","GoldShard",
             "Raw Obsidiron Ore","RawObsidironOre",
             "Obsidiron Ingot","ObsidironIngot",
             "Scalding Obsidiron Ingot","ScaldingObsidironIngot",
             "Raw Obsidiron Ore Shard"} },

    -- ─── COMIDAS (sem peixes) ────────────────────────────
    { key="EspComidas", label="🍖 Comidas",
      cor=Color3.fromRGB(255,115,165), tipo="item", alcance=350,
      desc="Carrot, Corn, Berry, Steak, Ribs, Stew, Candy…",
      nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake",
             "Morsel","Cooked Morsel","CookedMorsel",
             "Steak","Cooked Steak","CookedSteak",
             "Ribs","Cooked Ribs","CookedRibs",
             "Stew","Hearty Stew","HeartyStew",
             "Meat? Sandwich","MeatSandwich",
             "Seafood Chowder","SeafoodChowder",
             "Steak Dinner","SteakDinner",
             "Pumpkin Soup","PumpkinSoup",
             "BBQ Ribs","BBQRibs","Carrot Cake","CarrotCake",
             "Jar o' Jelly","JarOJelly",
             "Candy Apple","CandyApple","Candy Corn","CandyCorn",
             "Pumpkin Pie","PumpkinPie","Cotton Candy","CottonCandy",
             "Turkey Leg","TurkeyLeg","Cooked Turkey Leg","CookedTurkeyLeg",
             "Stuffing","Sweet Potato","SweetPotato",
             "Turkey Legs","TurkeyLegs","Berry Juice","BerryJuice",
             "Casserole","Corn on the Cob","CornontheCob",
             "Stuffing Bowl","StuffingBowl","Roast Turkey","RoastTurkey",
             "Stuffed Peppers","StuffedPeppers","Sweet Potato Pie","SweetPotatoPie",
             "Spicy Swordfish","SpicySwordfish","Hearty Thanksgiving Meal"} },

    -- ─── PEIXES ─────────────────────────────────────────
    { key="EspPeixes", label="🐟 Peixes",
      cor=Color3.fromRGB(80,180,255), tipo="item", alcance=400,
      desc="Mackerel, Salmon, Clownfish, Shark, Lava Eel, Lionfish…",
      nomes={"Mackerel","Cooked Mackerel","CookedMackerel",
             "Salmon","Cooked Salmon","CookedSalmon",
             "Clownfish","Cooked Clownfish","CookedClownfish",
             "Jellyfish","Char","Cooked Char","CookedChar",
             "Eel","Cooked Eel","CookedEel",
             "Swordfish","Cooked Swordfish","CookedSwordfish",
             "Shark","Cooked Shark","CookedShark",
             "Lava Eel","LavaEel","Cooked Lava Eel","CookedLavaEel",
             "Lionfish","Cooked Lionfish","CookedLionfish"} },

    -- ─── SEMENTES ───────────────────────────────────────
    { key="EspSementes", label="🌱 Sementes",
      cor=Color3.fromRGB(135,245,115), tipo="item", alcance=350,
      desc="Chili, Berry, Flower, Firefly, Dripleaf, Moonflower…",
      nomes={"Chili Seeds","ChiliSeeds","Flower Seeds","FlowerSeeds",
             "Berry Seeds","BerrySeeds","Firefly Seeds","FireflySeeds",
             "Dripleaf Seeds","DripleafSeeds",
             "Moonflower Seeds","MoonflowerSeeds",
             "Stareweed Seeds","StareweedSeeds",
             "Cavevine Seeds","CavevineSeeds",
             "Mandrake Seeds","MandrakeSeeds"} },

    -- ─── FERRAMENTAS ────────────────────────────────────
    { key="EspFerr", label="🪓 Ferramentas & Sacos",
      cor=Color3.fromRGB(255,200,55), tipo="item", alcance=500,
      desc="Axes, Sacks, Rods, Flutes, Flashlights, Trim Kits…",
      nomes={"Old Sack","OldSack","Good Sack","GoodSack",
             "Infernal Sack","InfernalSack","Giant Sack","GiantSack",
             "Old Axe","OldAxe","Good Axe","GoodAxe",
             "Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw",
             "Old Rod","OldRod","Good Rod","GoodRod",
             "Strong Rod","StrongRod",
             "Old Taming Flute","OldFlute","Good Taming Flute","GoodFlute",
             "Strong Taming Flute","StrongFlute",
             "Old Flashlight","OldFlashlight",
             "Strong Flashlight","StrongFlashlight",
             "Axe Trim Kit","AxeTrimKit","Armor Trim Kit","ArmorTrimKit",
             "Hammer","Paint Brush","PaintBrush",
             "Watering Can","WateringCan","Cultist Staff","CultistStaff"} },

    -- ─── ARMAS ──────────────────────────────────────────
    { key="EspArmas", label="⚔️ Armas",
      cor=Color3.fromRGB(255,70,70), tipo="item", alcance=500,
      desc="Spear, Morningstar, Crossbow, Ice Sword, Revolver, Rifle…",
      nomes={"Spear","Morningstar","Katana","Laser Sword","LaserSword",
             "Ice Sword","IceSword","Trident","Poison Spear","PoisonSpear",
             "Infernal Sword","InfernalSword",
             "Obsidiron Hammer","ObsidironHammer",
             "Scythe","Crossbow","Infernal Crossbow","InfernalCrossbow",
             "Bouncing Blade","BouncingBlade","Vampire Scythe","VampireScythe",
             "Revolver","Rifle","Tactical Shotgun","TacticalShotgun",
             "Ray Gun","RayGun","Laser Cannon","LaserCannon",
             "Flamethrower","Snowball","Frozen Shuriken","FrozenShuriken",
             "Kunai","Witch Potion","WitchPotion","Wildfire","Blowpipe",
             "Air Rifle","AirRifle"} },

    -- ─── MUNIÇÃO ────────────────────────────────────────
    { key="EspAmmo", label="🔫 Munição",
      cor=Color3.fromRGB(255,155,60), tipo="item", alcance=400,
      desc="Revolver Ammo, Rifle Ammo, Shotgun Ammo, Fuel Canister, Oil Barrel",
      nomes={"Revolver Ammo","RevolverAmmo","Rifle Ammo","RifleAmmo",
             "Shotgun Ammo","ShotgunAmmo"} },

    -- ─── CURA & PELTS ───────────────────────────────────
    { key="EspCura", label="💊 Cura & Pelts",
      cor=Color3.fromRGB(120,255,200), tipo="item", alcance=450,
      desc="Bandage, Medkit, Wolf Pelt, Bear Pelt, Bunny Foot…",
      nomes={"Bandage","Medkit",
             "Bunny Foot","BunnyFoot","Wolf Pelt","WolfPelt",
             "Alpha Wolf Pelt","AlphaWolfPelt","Bear Pelt","BearPelt",
             "Arctic Fox Pelt","ArcticFoxPelt",
             "Polar Bear Pelt","PolarBearPelt",
             "Mammoth Tusk","MammothTusk",
             "Scorpion Shell","ScorpionShell",
             "Cultist King Antler","CultistKingAntler"} },

    -- ─── CHAVES ─────────────────────────────────────────
    { key="EspChaves", label="🗝️ Chaves",
      cor=Color3.fromRGB(255,230,80), tipo="item", alcance=math.huge,
      desc="Red, Blue, Yellow, Grey, Frog Key",
      nomes={"Red Key","RedKey","Blue Key","BlueKey",
             "Yellow Key","YellowKey","Grey Key","GreyKey",
             "Frog Key","FrogKey"} },

    -- ─── BIGORNA ────────────────────────────────────────
    { key="EspBigorna", label="⚙️ Partes de Bigorna",
      cor=Color3.fromRGB(200,160,255), tipo="item", alcance=math.huge,
      desc="Anvil Front/Back/Base + Meteor Anvil Parts",
      nomes={"Anvil Front","AnvilFront","Anvil Back","AnvilBack",
             "Anvil Base","AnvilBase",
             "Meteor Anvil Front","MeteorAnvilFront",
             "Meteor Anvil Back","MeteorAnvilBack",
             "Meteor Anvil Base","MeteorAnvilBase"} },

    -- ─── INGREDIENTES DE POÇÃO ──────────────────────────
    { key="EspPocoes", label="🧪 Poções",
      cor=Color3.fromRGB(195,100,255), tipo="item", alcance=400,
      desc="Dripleaf, Moonflower Bulb, Stareweed Petal, Cave Vine Flower, Mandrake",
      nomes={"Dripleaf","Moonflower Bulb","MoonflowerBulb",
             "Stareweed Petal","StareweedPetal",
             "Cave Vine Flower","CaveVineFlower","Mandrake"} },

    -- ─── BLUEPRINTS ─────────────────────────────────────
    { key="EspBlueprint", label="📋 Blueprints",
      cor=Color3.fromRGB(130,190,255), tipo="item", alcance=500,
      desc="Crafting, Defense, Furniture, Obsidiron Chest Blueprint…",
      nomes={"Crafting Blueprint","CraftingBlueprint",
             "Defense Blueprint","DefenseBlueprint",
             "Furniture Blueprint","FurnitureBlueprint",
             "Obsidiron Chest Blueprint","ObsidironChestBlueprint",
             "Halloween Blueprint","HalloweenBlueprint"} },
}

-- Estado de cada ESP
local espAtivo = {}
for _, c in ipairs(ESP_CATS) do espAtivo[c.key] = false end

-- Lookup de nomes por categoria (case-insensitive)
local espLookup = {}
for _, c in ipairs(ESP_CATS) do
    if c.nomes then
        local s = {}
        for _, n in ipairs(c.nomes) do s[n:lower()] = true end
        espLookup[c.key] = s
    end
end

-- ════════════════════════════════════════════════════════
--  DEFINIÇÃO — BRINGS INDIVIDUAIS
--  Cada categoria tem seu próprio botão
-- ════════════════════════════════════════════════════════
local BRING_CATS = {

    -- ─── LOG ────────────────────────────────────────────
    { key="BLog", label="🪵 Bring Log",
      cor=Color3.fromRGB(190,130,60),
      desc="Só pega: Log",
      nomes={"Log"} },

    -- ─── COMBUSTÍVEL SEM LOG ────────────────────────────
    { key="BCombust", label="🔥 Bring Combustível",
      cor=Color3.fromRGB(255,120,30),
      desc="Coal, Biofuel, Fuel Canister, Oil Barrel, Purple Fur Tuft, Chair",
      nomes={"Coal","Biofuel","Oil Barrel","OilBarrel",
             "Fuel Canister","FuelCanister",
             "Purple Fur Tuft","PurpleFurTuft","Chair"} },

    -- ─── CARCAÇAS ───────────────────────────────────────
    { key="BCarcacas", label="🦴 Bring Carcaças",
      cor=Color3.fromRGB(180,100,50),
      desc="Wolf, Alpha Wolf, Bear, Cultist, Alien Corpse…",
      nomes={"Wolf Corpse","WolfCorpse",
             "Alpha Wolf Corpse","AlphaWolfCorpse",
             "Bear Corpse","BearCorpse",
             "Cultist Corpse","CultistCorpse",
             "Crossbow Cultist Corpse","CrossbowCultistCorpse",
             "Juggernaut Cultist Corpse","JuggernautCultistCorpse",
             "Cultist King Corpse","CultistKingCorpse",
             "Alien Corpse","AlienCorpse",
             "Elite Alien Corpse","EliteAlienCorpse"} },

    -- ─── SUCATA ─────────────────────────────────────────
    { key="BSucata", label="🔩 Bring Sucata",
      cor=Color3.fromRGB(155,210,255),
      desc="Bolt, Sheet Metal, UFO Junk, Broken Fan, Old Radio, Tyre…",
      nomes={"Bolt","Sheet Metal","SheetMetal",
             "UFO Junk","UFOJunk","UFO Component","UFOComponent",
             "UFO Scrap","UFOScrap","Broken Fan","BrokenFan",
             "Old Radio","OldRadio","Broken Radio","BrokenRadio",
             "Broken Microwave","BrokenMicrowave",
             "Tyre","Metal Chair","MetalChair",
             "Old Car Engine","OldCarEngine",
             "Washing Machine","WashingMachine",
             "Cultist Experiment","CultistExperiment",
             "Cultist Prototype","CultistPrototype"} },

    -- ─── MATERIAIS ──────────────────────────────────────
    { key="BMateriais", label="💎 Bring Materiais",
      cor=Color3.fromRGB(220,175,255),
      desc="Cultist Gem, Forest Gem, Mossy Coin, Meteor Shard…",
      nomes={"Cultist Gem","CultistGem",
             "Forest Gem","ForestGem",
             "Forest Gem Fragment","ForestGemFragment",
             "Mossy Coin","MossyCoin","Flower","Sapling",
             "Sacrifice Totem","SacrificeTotem",
             "Meteor Shard","MeteorShard","Gold Shard","GoldShard",
             "Raw Obsidiron Ore","RawObsidironOre",
             "Obsidiron Ingot","ObsidironIngot",
             "Scalding Obsidiron Ingot"} },

    -- ─── COMIDAS ────────────────────────────────────────
    { key="BComidas", label="🍖 Bring Comidas",
      cor=Color3.fromRGB(255,115,165),
      desc="Carrot, Corn, Steak, Ribs, Stew, Cake, Candy…",
      nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake",
             "Morsel","Cooked Morsel","CookedMorsel",
             "Steak","Cooked Steak","CookedSteak",
             "Ribs","Cooked Ribs","CookedRibs",
             "Stew","Hearty Stew","HeartyStew",
             "Meat? Sandwich","Seafood Chowder","Steak Dinner",
             "Pumpkin Soup","BBQ Ribs","Carrot Cake",
             "Jar o' Jelly","Candy Apple","Candy Corn",
             "Pumpkin Pie","Cotton Candy",
             "Turkey Leg","Cooked Turkey Leg","Stuffing","Sweet Potato",
             "Turkey Legs","Berry Juice","Casserole",
             "Corn on the Cob","Stuffing Bowl","Roast Turkey",
             "Stuffed Peppers","Sweet Potato Pie",
             "Spicy Swordfish","Hearty Thanksgiving Meal"} },

    -- ─── PEIXES ─────────────────────────────────────────
    { key="BPeixes", label="🐟 Bring Peixes",
      cor=Color3.fromRGB(80,180,255),
      desc="Mackerel, Salmon, Clownfish, Jellyfish, Shark, Lava Eel…",
      nomes={"Mackerel","Cooked Mackerel","CookedMackerel",
             "Salmon","Cooked Salmon","CookedSalmon",
             "Clownfish","Cooked Clownfish","CookedClownfish",
             "Jellyfish","Char","Cooked Char","CookedChar",
             "Eel","Cooked Eel","CookedEel",
             "Swordfish","Cooked Swordfish","CookedSwordfish",
             "Shark","Cooked Shark","CookedShark",
             "Lava Eel","LavaEel","Cooked Lava Eel","CookedLavaEel",
             "Lionfish","Cooked Lionfish","CookedLionfish"} },

    -- ─── SEMENTES ───────────────────────────────────────
    { key="BSementes", label="🌱 Bring Sementes",
      cor=Color3.fromRGB(135,245,115),
      desc="Chili, Berry, Flower, Firefly, Dripleaf, Moonflower, Stareweed, Cavevine, Mandrake Seeds",
      nomes={"Chili Seeds","ChiliSeeds",
             "Flower Seeds","FlowerSeeds",
             "Berry Seeds","BerrySeeds",
             "Firefly Seeds","FireflySeeds",
             "Dripleaf Seeds","DripleafSeeds",
             "Moonflower Seeds","MoonflowerSeeds",
             "Stareweed Seeds","StareweedSeeds",
             "Cavevine Seeds","CavevineSeeds",
             "Mandrake Seeds","MandrakeSeeds"} },

    -- ─── FERRAMENTAS ────────────────────────────────────
    { key="BFerr", label="🪓 Bring Ferramentas",
      cor=Color3.fromRGB(255,200,55),
      desc="Sacks, Axes, Rods, Flutes, Flashlights, Trim Kits",
      nomes={"Old Sack","OldSack","Good Sack","GoodSack",
             "Infernal Sack","InfernalSack","Giant Sack","GiantSack",
             "Old Axe","OldAxe","Good Axe","GoodAxe",
             "Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw",
             "Old Rod","OldRod","Good Rod","GoodRod","Strong Rod","StrongRod",
             "Old Taming Flute","OldFlute",
             "Good Taming Flute","GoodFlute",
             "Strong Taming Flute","StrongFlute",
             "Old Flashlight","OldFlashlight",
             "Strong Flashlight","StrongFlashlight",
             "Axe Trim Kit","AxeTrimKit",
             "Armor Trim Kit","ArmorTrimKit",
             "Hammer","Paint Brush","PaintBrush",
             "Watering Can","WateringCan"} },

    -- ─── ARMAS ──────────────────────────────────────────
    { key="BArmas", label="⚔️ Bring Armas",
      cor=Color3.fromRGB(255,70,70),
      desc="Spear, Morningstar, Ice Sword, Crossbow, Revolver, Rifle, Shotgun…",
      nomes={"Spear","Morningstar","Katana","Laser Sword","LaserSword",
             "Ice Sword","IceSword","Trident","Poison Spear","PoisonSpear",
             "Infernal Sword","InfernalSword",
             "Obsidiron Hammer","ObsidironHammer",
             "Scythe","Crossbow","Infernal Crossbow","InfernalCrossbow",
             "Bouncing Blade","BouncingBlade","Vampire Scythe","VampireScythe",
             "Revolver","Rifle","Tactical Shotgun","TacticalShotgun",
             "Ray Gun","RayGun","Laser Cannon","LaserCannon",
             "Flamethrower","Snowball","Frozen Shuriken","FrozenShuriken",
             "Kunai","Witch Potion","WitchPotion","Wildfire","Blowpipe",
             "Air Rifle","AirRifle"} },

    -- ─── MUNIÇÃO ────────────────────────────────────────
    { key="BAmmo", label="🔫 Bring Munição",
      cor=Color3.fromRGB(255,155,60),
      desc="Revolver Ammo, Rifle Ammo, Shotgun Ammo",
      nomes={"Revolver Ammo","RevolverAmmo",
             "Rifle Ammo","RifleAmmo",
             "Shotgun Ammo","ShotgunAmmo"} },

    -- ─── CURA ───────────────────────────────────────────
    { key="BCura", label="💊 Bring Cura",
      cor=Color3.fromRGB(100,255,180),
      desc="Bandage, Medkit",
      nomes={"Bandage","Medkit"} },

    -- ─── PELTS ──────────────────────────────────────────
    { key="BPelts", label="🦺 Bring Pelts",
      cor=Color3.fromRGB(210,170,120),
      desc="Bunny Foot, Wolf Pelt, Bear Pelt, Arctic Fox Pelt, Mammoth Tusk…",
      nomes={"Bunny Foot","BunnyFoot","Wolf Pelt","WolfPelt",
             "Alpha Wolf Pelt","AlphaWolfPelt","Bear Pelt","BearPelt",
             "Arctic Fox Pelt","ArcticFoxPelt",
             "Polar Bear Pelt","PolarBearPelt",
             "Mammoth Tusk","MammothTusk",
             "Scorpion Shell","ScorpionShell",
             "Cultist King Antler","CultistKingAntler"} },

    -- ─── CHAVES ─────────────────────────────────────────
    { key="BChaves", label="🗝️ Bring Chaves",
      cor=Color3.fromRGB(255,230,80),
      desc="Red Key, Blue Key, Yellow Key, Grey Key, Frog Key",
      nomes={"Red Key","RedKey","Blue Key","BlueKey",
             "Yellow Key","YellowKey","Grey Key","GreyKey",
             "Frog Key","FrogKey"} },

    -- ─── BIGORNA ────────────────────────────────────────
    { key="BBigorna", label="⚙️ Bring Bigorna",
      cor=Color3.fromRGB(200,160,255),
      desc="Anvil Front/Back/Base + Meteor Anvil Parts",
      nomes={"Anvil Front","AnvilFront","Anvil Back","AnvilBack",
             "Anvil Base","AnvilBase","Meteor Anvil Front","MeteorAnvilFront",
             "Meteor Anvil Back","MeteorAnvilBack",
             "Meteor Anvil Base","MeteorAnvilBase"} },

    -- ─── POÇÕES ─────────────────────────────────────────
    { key="BPocoes", label="🧪 Bring Poções",
      cor=Color3.fromRGB(195,100,255),
      desc="Dripleaf, Moonflower Bulb, Stareweed Petal, Cave Vine Flower, Mandrake",
      nomes={"Dripleaf","Moonflower Bulb","MoonflowerBulb",
             "Stareweed Petal","StareweedPetal",
             "Cave Vine Flower","CaveVineFlower","Mandrake"} },

    -- ─── BLUEPRINTS ─────────────────────────────────────
    { key="BBlueprint", label="📋 Bring Blueprints",
      cor=Color3.fromRGB(130,190,255),
      desc="Crafting, Defense, Furniture, Obsidiron Chest Blueprint",
      nomes={"Crafting Blueprint","CraftingBlueprint",
             "Defense Blueprint","DefenseBlueprint",
             "Furniture Blueprint","FurnitureBlueprint",
             "Obsidiron Chest Blueprint","ObsidironChestBlueprint",
             "Halloween Blueprint","HalloweenBlueprint"} },
}

-- Lookup de nomes para o Bring
local bringLookup = {}
for _, c in ipairs(BRING_CATS) do
    local s = {}
    for _, n in ipairs(c.nomes) do s[n:lower()] = true end
    bringLookup[c.key] = s
end

-- ════════════════════════════════════════════════════════
--  POOL DE LABELS (ESP)
-- ════════════════════════════════════════════════════════
local POOL_SIZE  = 120
local labelPool  = {}
local activeList = {}

local function newLabel()
    local f = Instance.new("Frame", EspCanvas)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Size    = UDim2.new(0, 210, 0, 30)
    f.Visible = false
    f.ZIndex  = 10

    local bg = Instance.new("Frame", f)
    bg.BackgroundColor3       = Color3.fromRGB(6, 8, 14)
    bg.BackgroundTransparency = 0.3
    bg.BorderSizePixel        = 0
    bg.Size   = UDim2.new(1, 0, 1, 0)
    bg.ZIndex = 10
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 5)

    local n = Instance.new("TextLabel", f)
    n.Name                   = "NL"
    n.BackgroundTransparency = 1
    n.Position               = UDim2.new(0, 6, 0, 2)
    n.Size                   = UDim2.new(1, -8, 0, 14)
    n.Font                   = Enum.Font.GothamBold
    n.TextSize               = 11
    n.TextXAlignment         = Enum.TextXAlignment.Left
    n.TextStrokeTransparency = 0.1
    n.TextStrokeColor3       = Color3.new(0,0,0)
    n.TextTruncate           = Enum.TextTruncate.AtEnd
    n.ZIndex                 = 12

    local d = Instance.new("TextLabel", f)
    d.Name                   = "DL"
    d.BackgroundTransparency = 1
    d.Position               = UDim2.new(0, 6, 0, 16)
    d.Size                   = UDim2.new(1, -8, 0, 11)
    d.Font                   = Enum.Font.Gotham
    d.TextSize               = 9
    d.TextColor3             = Color3.fromRGB(170, 185, 210)
    d.TextXAlignment         = Enum.TextXAlignment.Left
    d.TextStrokeTransparency = 0.2
    d.TextStrokeColor3       = Color3.new(0,0,0)
    d.ZIndex                 = 12
    return f
end

for i = 1, POOL_SIZE do table.insert(labelPool, newLabel()) end

local function showLabel(cor, nome, dist, sx, sy)
    local f = table.remove(labelPool)
    if not f then return end
    f.Position = UDim2.new(0, sx - 105, 0, sy - 15)
    f.Visible  = true
    local nl = f:FindFirstChild("NL")
    local dl = f:FindFirstChild("DL")
    if nl then nl.Text = nome; nl.TextColor3 = cor end
    if dl then dl.Text = string.format("%.0f m", dist) end
    table.insert(activeList, f)
end

local function releaseAll()
    for _, f in ipairs(activeList) do
        f.Visible = false
        table.insert(labelPool, f)
    end
    activeList = {}
end

-- ════════════════════════════════════════════════════════
--  CACHE ASSÍNCRONO
-- ════════════════════════════════════════════════════════
local entityCache   = {}
local itemCache     = {}
local cacheBuilding = false
local lastCache     = 0
local CACHE_INTER   = 5  -- segundos

-- ── Verifica entidade VIVA ───────────────────────────────
-- FIX CRÍTICO: evita mostrar mortos e pré-spawnados
local function isAlive(model)
    local hum = model:FindFirstChildWhichIsA("Humanoid")
    if not hum then return false end
    if hum.Health <= 0 then return false end
    if hum.MaxHealth <= 0 then return false end

    local hrp = model:FindFirstChild("HumanoidRootPart")
             or model:FindFirstChildWhichIsA("BasePart")
    if not hrp then return false end

    local pos = hrp.Position
    -- Fora do mapa = ainda não spawnado
    if pos.Y < -400 then return false end
    if pos.Magnitude > 6000 then return false end
    return true
end

local function isPlayerChar(obj)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character and (pl.Character == obj or pl.Character:IsAncestorOf(obj)) then
            return true
        end
    end
    return false
end

local function anyActive(tipo)
    for _, c in ipairs(ESP_CATS) do
        if espAtivo[c.key] and c.tipo == tipo then return true end
    end
    return false
end

local function buildCache()
    if cacheBuilding then return end
    local now = tick()
    if now - lastCache < CACHE_INTER then return end
    lastCache   = now
    cacheBuilding = true

    task.spawn(function()
        local newEnt  = {}
        local newItem = {}

        local doEnt  = anyActive("entity")
        local doItem = anyActive("item")

        if not doEnt and not doItem then
            entityCache = newEnt; itemCache = newItem
            cacheBuilding = false; return
        end

        local ok, descs = pcall(function() return workspace:GetDescendants() end)
        if not ok then cacheBuilding = false return end

        -- Cache de chars de players para velocidade
        local pchars = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Character then pchars[pl.Character] = true end
        end

        local batch = 0
        for _, obj in ipairs(descs) do
            batch += 1
            if batch % 100 == 0 then task.wait() end  -- yield — zero freeze

            if not obj or not obj.Parent then continue end

            local nameLower = obj.Name:lower()

            -- ── Entidades ──
            if doEnt and obj:IsA("Model") then
                if not pchars[obj] then
                    -- FIX: só vivas
                    if isAlive(obj) then
                        for _, c in ipairs(ESP_CATS) do
                            if espAtivo[c.key] and c.tipo == "entity" then
                                local lk = espLookup[c.key]
                                if lk and lk[nameLower] then
                                    local hrp = obj:FindFirstChild("HumanoidRootPart")
                                             or obj:FindFirstChildWhichIsA("BasePart")
                                    if hrp then
                                        table.insert(newEnt, {
                                            key=c.key, cor=c.cor,
                                            nome=obj.Name, alcance=c.alcance,
                                            obj=obj, hrp=hrp
                                        })
                                    end
                                    break
                                end
                            end
                        end
                    end
                end

            -- ── Itens ──
            elseif doItem and obj:IsA("BasePart") and not obj.Anchored then
                if not pchars[obj] then
                    -- Verifica que não é parte de NPC
                    local isNPC = false
                    local p = obj.Parent
                    for _ = 1, 3 do
                        if p and p:IsA("Model") and p:FindFirstChildWhichIsA("Humanoid") then
                            isNPC = true; break
                        end
                        p = p and p.Parent
                    end

                    if not isNPC then
                        for _, c in ipairs(ESP_CATS) do
                            if espAtivo[c.key] and c.tipo == "item" then
                                local lk = espLookup[c.key]
                                if lk and lk[nameLower] then
                                    table.insert(newItem, {
                                        key=c.key, cor=c.cor,
                                        nome=obj.Name, alcance=c.alcance,
                                        obj=obj
                                    })
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end

        entityCache = newEnt; itemCache = newItem
        cacheBuilding = false
    end)
end

-- ════════════════════════════════════════════════════════
--  RENDER LOOP — 20fps
-- ════════════════════════════════════════════════════════
local dtAcc = 0
local RENDER_I = 1/20

RunService.Heartbeat:Connect(function(dt)
    dtAcc += dt
    if dtAcc < RENDER_I then return end
    dtAcc = 0

    releaseAll()

    local qualquer = false
    for _, c in ipairs(ESP_CATS) do
        if espAtivo[c.key] then qualquer = true; break end
    end
    if not qualquer then return end

    pcall(buildCache)

    local charPos = Vector3.zero
    pcall(function()
        local ch = Player.Character
        if ch and ch:FindFirstChild("HumanoidRootPart") then
            charPos = ch.HumanoidRootPart.Position
        end
    end)

    local vp   = Cam.ViewportSize
    local seen = {}

    -- ── Players ──
    if espAtivo["Players"] then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= Player and pl.Character then
                pcall(function()
                    local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    local hum = pl.Character:FindFirstChildWhichIsA("Humanoid")
                    if not hum or hum.Health <= 0 then return end
                    local dist = (hrp.Position - charPos).Magnitude
                    local sp, vis = Cam:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
                    if not vis then return end
                    if sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
                    local cell = math.floor(sp.X/12)..","..math.floor(sp.Y/12)
                    if seen[cell] then return end; seen[cell] = true
                    showLabel(Color3.fromRGB(255,80,80), pl.DisplayName, dist, sp.X, sp.Y)
                end)
            end
        end
    end

    -- ── Entidades ──
    for _, e in ipairs(entityCache) do
        pcall(function()
            if not espAtivo[e.key] then return end
            if not e.obj or not e.obj.Parent then return end
            -- FIX: re-verifica saúde todo frame
            local hum = e.obj:FindFirstChildWhichIsA("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local pos  = e.hrp.Position
            local dist = (pos - charPos).Magnitude
            if dist > e.alcance then return end
            local sp, vis = Cam:WorldToViewportPoint(pos + Vector3.new(0,2.5,0))
            if not vis then return end
            if sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
            local cell = math.floor(sp.X/12)..","..math.floor(sp.Y/12)
            if seen[cell] then return end; seen[cell] = true
            showLabel(e.cor, e.nome, dist, sp.X, sp.Y)
        end)
    end

    -- ── Itens ──
    for _, e in ipairs(itemCache) do
        pcall(function()
            if not espAtivo[e.key] then return end
            if not e.obj or not e.obj.Parent then return end
            if e.obj.Anchored then return end  -- pode ter sido ancorado depois
            local pos  = e.obj.Position
            local dist = (pos - charPos).Magnitude
            if dist > e.alcance then return end
            local sp, vis = Cam:WorldToViewportPoint(pos + Vector3.new(0,0.8,0))
            if not vis then return end
            if sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
            local cell = math.floor(sp.X/10)..","..math.floor(sp.Y/10)
            if seen[cell] then return end; seen[cell] = true
            showLabel(e.cor, e.nome, dist, sp.X, sp.Y)
        end)
    end
end)

-- ════════════════════════════════════════════════════════
--  BRING — MOTOR CENTRAL
--  Cada categoria chama executarBring(key)
-- ════════════════════════════════════════════════════════
local function executarBring(key)
    local char = Player.Character
    if not char then return 0 end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end

    local lookup = bringLookup[key]
    if not lookup then return 0 end

    -- Cache de chars de players (evita teleportar partes de outros players)
    local pchars = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character then pchars[pl.Character] = true end
    end

    local cf       = hrp.CFrame
    local count    = 0
    local trazidos = {}
    local batch    = 0

    local ok, descs = pcall(function() return workspace:GetDescendants() end)
    if not ok then return 0 end

    for _, obj in ipairs(descs) do
        batch += 1
        if batch % 100 == 0 then
            task.wait()
            -- Re-valida char após yield (pode ter morrido)
            char = Player.Character
            if not char then break end
            hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then break end
            cf = hrp.CFrame
        end

        pcall(function()
            if not obj or not obj.Parent then return end
            if not obj:IsA("BasePart") then return end

            -- FILTRO 1: só itens SOLTOS
            if obj.Anchored then return end

            -- FILTRO 2: não é parte de player
            for pc in pairs(pchars) do
                if pc == obj or pc:IsAncestorOf(obj) then return end
            end

            -- FILTRO 3: não dentro de NPC com Humanoid
            local p = obj.Parent
            for _ = 1, 3 do
                if p and p:IsA("Model") and p:FindFirstChildWhichIsA("Humanoid") then
                    return
                end
                p = p and p.Parent
            end

            -- FILTRO 4: nome exato
            if not lookup[obj.Name:lower()] then return end

            -- FILTRO 5: tamanho razoável (item real ≤ 14 studs/lado)
            local sz = obj.Size
            if sz.X > 14 or sz.Y > 14 or sz.Z > 14 then return end

            -- Posição alvo: perto do player com spread
            local spread = Vector3.new(
                math.random(-4,4) + math.random()*0.5,
                0.5,
                math.random(-4,4) + math.random()*0.5
            )
            local target = cf.Position + spread

            -- Desabilita scripts do item para evitar comportamento estranho
            for _, s in ipairs(obj:GetChildren()) do
                if s:IsA("Script") or s:IsA("LocalScript") then
                    pcall(function() s.Disabled = true end)
                end
            end

            obj.CFrame     = CFrame.new(target)
            obj.Velocity   = Vector3.zero
            obj.CanCollide = true

            count += 1
            table.insert(trazidos, {obj=obj, pos=target})
        end)
    end

    -- Anti-desaparecimento: mantém por 8s
    if #trazidos > 0 then
        task.spawn(function()
            for _ = 1, 8 do
                task.wait(1)
                for _, e in ipairs(trazidos) do
                    pcall(function()
                        if e.obj and e.obj.Parent and e.obj:IsA("BasePart") then
                            if (e.obj.Position - e.pos).Magnitude > 20 then
                                e.obj.CFrame   = CFrame.new(e.pos)
                                e.obj.Velocity = Vector3.zero
                            end
                        end
                    end)
                end
            end
        end)
    end

    return count
end

-- ════════════════════════════════════════════════════════
--  HELPERS DE UI
-- ════════════════════════════════════════════════════════
local uiOrder = 0
local function nextOrder() uiOrder += 1; return uiOrder * 10 end

-- ── Seção header ────────────────────────────────────────
local function makeSection(parent, titulo, cor)
    local lo = nextOrder()

    local div = Instance.new("Frame", parent)
    div.BackgroundColor3 = Color3.fromRGB(36, 40, 52)
    div.BorderSizePixel  = 0
    div.Size             = UDim2.new(1, 0, 0, 1)
    div.LayoutOrder      = lo - 5

    local hdr = Instance.new("Frame", parent)
    hdr.BackgroundColor3       = Color3.fromRGB(20, 22, 30)
    hdr.BackgroundTransparency = 0.3
    hdr.BorderSizePixel        = 0
    hdr.Size             = UDim2.new(1, 0, 0, 22)
    hdr.LayoutOrder      = lo
    hdr.ZIndex           = 4
    Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 6)

    local bar = Instance.new("Frame", hdr)
    bar.BackgroundColor3 = cor
    bar.BorderSizePixel  = 0
    bar.Position         = UDim2.new(0, 0, 0, 0)
    bar.Size             = UDim2.new(0, 3, 1, 0)
    bar.ZIndex           = 5
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)

    local lbl = Instance.new("TextLabel", hdr)
    lbl.BackgroundTransparency = 1
    lbl.Position       = UDim2.new(0, 10, 0, 0)
    lbl.Size           = UDim2.new(1, -14, 1, 0)
    lbl.Font           = Enum.Font.GothamBlack
    lbl.Text           = titulo
    lbl.TextColor3     = cor
    lbl.TextSize       = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex         = 5
end

-- ── Row ESP (toggle) ────────────────────────────────────
local function makeEspRow(cat)
    local lo = nextOrder()

    local row = Instance.new("Frame", EspScroll)
    row.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
    row.BorderSizePixel  = 0
    row.Size             = UDim2.new(1, 0, 0, 36)
    row.LayoutOrder      = lo
    row.ZIndex           = 4
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local rStroke = Instance.new("UIStroke", row)
    rStroke.Color = Color3.fromRGB(36, 40, 52); rStroke.Thickness = 1

    -- Dot colorido
    local dot = Instance.new("Frame", row)
    dot.BackgroundColor3 = cat.cor
    dot.BorderSizePixel  = 0
    dot.Position         = UDim2.new(0, 9, 0.5, -5)
    dot.Size             = UDim2.new(0, 10, 0, 10)
    dot.ZIndex           = 5
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel", row)
    lbl.BackgroundTransparency = 1
    lbl.Position       = UDim2.new(0, 25, 0, 4)
    lbl.Size           = UDim2.new(1, -80, 0, 14)
    lbl.Font           = Enum.Font.GothamBold
    lbl.Text           = cat.label
    lbl.TextColor3     = Color3.fromRGB(205, 215, 235)
    lbl.TextSize       = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex         = 5

    local desc = Instance.new("TextLabel", row)
    desc.BackgroundTransparency = 1
    desc.Position       = UDim2.new(0, 25, 0, 19)
    desc.Size           = UDim2.new(1, -80, 0, 12)
    desc.Font           = Enum.Font.Gotham
    desc.Text           = cat.desc or ""
    desc.TextColor3     = Color3.fromRGB(75, 88, 108)
    desc.TextSize       = 8
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextTruncate   = Enum.TextTruncate.AtEnd
    desc.ZIndex         = 5

    -- Toggle pill
    local pill = Instance.new("Frame", row)
    pill.BackgroundColor3 = Color3.fromRGB(36, 40, 52)
    pill.BorderSizePixel  = 0
    pill.Position         = UDim2.new(1, -50, 0.5, -11)
    pill.Size             = UDim2.new(0, 40, 0, 22)
    pill.ZIndex           = 5
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.BackgroundColor3 = Color3.fromRGB(130, 145, 165)
    knob.BorderSizePixel  = 0
    knob.Position         = UDim2.new(0, 2, 0.5, -9)
    knob.Size             = UDim2.new(0, 18, 0, 18)
    knob.ZIndex           = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", row)
    btn.BackgroundTransparency = 1
    btn.Size   = UDim2.new(1, 0, 1, 0)
    btn.Text   = ""; btn.ZIndex = 7

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        espAtivo[cat.key] = on
        lastCache = 0  -- força rebuild

        local tw = TweenInfo.new(0.18)
        TweenService:Create(pill, tw, {BackgroundColor3 = on and cat.cor or Color3.fromRGB(36,40,52)}):Play()
        TweenService:Create(knob, tw, {
            Position         = on and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
            BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,145,165),
        }):Play()
        TweenService:Create(rStroke, tw, {Color = on and cat.cor or Color3.fromRGB(36,40,52)}):Play()
    end)
end

-- ── Row BRING (botão individual) ────────────────────────
local function makeBringRow(bcat)
    local lo = nextOrder()

    local row = Instance.new("Frame", BringScroll)
    row.BackgroundColor3 = Color3.fromRGB(22, 24, 32)
    row.BorderSizePixel  = 0
    row.Size             = UDim2.new(1, 0, 0, 48)
    row.LayoutOrder      = lo
    row.ZIndex           = 4
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local rStroke = Instance.new("UIStroke", row)
    rStroke.Color = Color3.fromRGB(36, 40, 52); rStroke.Thickness = 1

    local dot = Instance.new("Frame", row)
    dot.BackgroundColor3 = bcat.cor
    dot.BorderSizePixel  = 0
    dot.Position         = UDim2.new(0, 9, 0.5, -5)
    dot.Size             = UDim2.new(0, 10, 0, 10)
    dot.ZIndex           = 5
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel", row)
    lbl.BackgroundTransparency = 1
    lbl.Position       = UDim2.new(0, 25, 0, 5)
    lbl.Size           = UDim2.new(1, -100, 0, 14)
    lbl.Font           = Enum.Font.GothamBold
    lbl.Text           = bcat.label
    lbl.TextColor3     = Color3.fromRGB(205, 215, 235)
    lbl.TextSize       = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex         = 5

    local desc = Instance.new("TextLabel", row)
    desc.BackgroundTransparency = 1
    desc.Position       = UDim2.new(0, 25, 0, 20)
    desc.Size           = UDim2.new(1, -100, 0, 12)
    desc.Font           = Enum.Font.Gotham
    desc.Text           = bcat.desc or ""
    desc.TextColor3     = Color3.fromRGB(75, 88, 108)
    desc.TextSize       = 8
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextTruncate   = Enum.TextTruncate.AtEnd
    desc.ZIndex         = 5

    local feedback = Instance.new("TextLabel", row)
    feedback.BackgroundTransparency = 1
    feedback.Position       = UDim2.new(0, 25, 0, 33)
    feedback.Size           = UDim2.new(1, -100, 0, 12)
    feedback.Font           = Enum.Font.GothamBold
    feedback.Text           = ""
    feedback.TextColor3     = bcat.cor
    feedback.TextSize       = 8
    feedback.TextXAlignment = Enum.TextXAlignment.Left
    feedback.TextTransparency = 1
    feedback.ZIndex         = 5

    local btnBring = Instance.new("TextButton", row)
    btnBring.BackgroundColor3       = bcat.cor
    btnBring.BackgroundTransparency = 0.15
    btnBring.BorderSizePixel        = 0
    btnBring.Position               = UDim2.new(1, -84, 0.5, -14)
    btnBring.Size                   = UDim2.new(0, 74, 0, 28)
    btnBring.Font                   = Enum.Font.GothamBold
    btnBring.Text                   = "▼ BRING"
    btnBring.TextColor3             = Color3.fromRGB(255,255,255)
    btnBring.TextSize               = 9
    btnBring.ZIndex                 = 6
    Instance.new("UICorner", btnBring).CornerRadius = UDim.new(0, 7)
    local bStroke = Instance.new("UIStroke", btnBring)
    bStroke.Color = bcat.cor; bStroke.Thickness = 1; bStroke.Transparency = 0.4

    btnBring.MouseEnter:Connect(function()
        TweenService:Create(btnBring, TweenInfo.new(0.1), {BackgroundTransparency=0}):Play()
    end)
    btnBring.MouseLeave:Connect(function()
        TweenService:Create(btnBring, TweenInfo.new(0.1), {BackgroundTransparency=0.15}):Play()
    end)

    local running = false
    btnBring.MouseButton1Click:Connect(function()
        if running then return end
        running = true
        btnBring.Text = "⏳ ..."
        TweenService:Create(rStroke, TweenInfo.new(0.12), {Color=bcat.cor}):Play()

        task.spawn(function()
            local n = executarBring(bcat.key)
            btnBring.Text = "▼ BRING"

            feedback.Text             = n > 0 and ("✓ "..n.." item(s) trazido(s)") or "✗ Nenhum item encontrado"
            feedback.TextColor3       = n > 0 and bcat.cor or Color3.fromRGB(200,70,70)
            feedback.TextTransparency = 0

            task.delay(3, function()
                TweenService:Create(feedback, TweenInfo.new(0.4), {TextTransparency=1}):Play()
                task.wait(0.5)
                feedback.Text = ""; feedback.TextTransparency = 0
            end)

            TweenService:Create(rStroke, TweenInfo.new(0.3), {Color=Color3.fromRGB(36,40,52)}):Play()
            task.wait(2)
            running = false
        end)
    end)
end

-- ════════════════════════════════════════════════════════
--  MONTAR UI — TAB ESP
-- ════════════════════════════════════════════════════════
-- Grupos por tipo para organizar visualmente
local espGroupOrder = {
    -- Entidades
    {"ESP — Entidades", Color3.fromRGB(88,101,242), {"Players","Kids","AnimPassivo","AnimAgressivo","Monstros","Cultistas","Aliens"}},
    -- Recursos
    {"ESP — Recursos & Combustível", Color3.fromRGB(255,130,40), {"EspLog","EspCombustivel","EspCarcacas","EspSucata","EspMateriais"}},
    -- Comida
    {"ESP — Comida & Natureza", Color3.fromRGB(255,120,170), {"EspComidas","EspPeixes","EspSementes","EspPocoes"}},
    -- Equipamento
    {"ESP — Equipamentos", Color3.fromRGB(255,200,55), {"EspFerr","EspArmas","EspAmmo","EspCura","EspChaves","EspBigorna","EspBlueprint"}},
}

local espCatMap = {}
for _, c in ipairs(ESP_CATS) do espCatMap[c.key] = c end

for _, grp in ipairs(espGroupOrder) do
    local titulo, cor, keys = grp[1], grp[2], grp[3]
    makeSection(EspScroll, titulo, cor)
    for _, k in ipairs(keys) do
        if espCatMap[k] then makeEspRow(espCatMap[k]) end
    end
end

-- ════════════════════════════════════════════════════════
--  MONTAR UI — TAB BRING
-- ════════════════════════════════════════════════════════
uiOrder = 0  -- reset para bring

local bringGroupOrder = {
    {"BRING — Combustível & Recursos", Color3.fromRGB(255,130,40),
     {"BLog","BCombust","BCarcacas","BSucata","BMateriais"}},
    {"BRING — Comida & Natureza", Color3.fromRGB(255,120,170),
     {"BComidas","BPeixes","BSementes","BPocoes"}},
    {"BRING — Equipamentos", Color3.fromRGB(255,200,55),
     {"BFerr","BArmas","BAmmo","BCura","BPelts"}},
    {"BRING — Especiais", Color3.fromRGB(255,230,80),
     {"BChaves","BBigorna","BBlueprint"}},
}

local bringCatMap = {}
for _, c in ipairs(BRING_CATS) do bringCatMap[c.key] = c end

for _, grp in ipairs(bringGroupOrder) do
    local titulo, cor, keys = grp[1], grp[2], grp[3]

    local lo = nextOrder()
    local hdr = Instance.new("Frame", BringScroll)
    hdr.BackgroundColor3       = Color3.fromRGB(20, 22, 30)
    hdr.BackgroundTransparency = 0.3
    hdr.BorderSizePixel        = 0
    hdr.Size             = UDim2.new(1, 0, 0, 22)
    hdr.LayoutOrder      = lo
    hdr.ZIndex           = 4
    Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 6)
    local bar = Instance.new("Frame", hdr)
    bar.BackgroundColor3 = cor
    bar.BorderSizePixel  = 0
    bar.Position = UDim2.new(0,0,0,0); bar.Size = UDim2.new(0,3,1,0); bar.ZIndex=5
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,3)
    local lbl = Instance.new("TextLabel", hdr)
    lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,0)
    lbl.Size=UDim2.new(1,-14,1,0); lbl.Font=Enum.Font.GothamBlack
    lbl.Text=titulo; lbl.TextColor3=cor; lbl.TextSize=9
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5

    for _, k in ipairs(keys) do
        if bringCatMap[k] then makeBringRow(bringCatMap[k]) end
    end
end

-- ── Rodapé BRING ──
local lo2 = nextOrder()
local rodape = Instance.new("Frame", BringScroll)
rodape.BackgroundColor3       = Color3.fromRGB(14,30,50)
rodape.BackgroundTransparency = 0.5
rodape.BorderSizePixel        = 0
rodape.Size        = UDim2.new(1, 0, 0, 52)
rodape.LayoutOrder = lo2
rodape.ZIndex      = 4
Instance.new("UICorner", rodape).CornerRadius = UDim.new(0, 8)
local rs = Instance.new("UIStroke", rodape)
rs.Color=Color3.fromRGB(50,120,200); rs.Thickness=1
local rt = Instance.new("TextLabel", rodape)
rt.BackgroundTransparency=1; rt.Position=UDim2.new(0,8,0,4)
rt.Size=UDim2.new(1,-16,1,-8); rt.Font=Enum.Font.Gotham
rt.Text="ℹ Bring só pega itens soltos (Anchored=false).\nESP só mostra entidades vivas (Health > 0).\nDados: Wiki 99 Nights in the Forest 2026."
rt.TextColor3=Color3.fromRGB(90,165,255); rt.TextSize=8
rt.TextWrapped=true; rt.TextXAlignment=Enum.TextXAlignment.Left
rt.TextYAlignment=Enum.TextYAlignment.Top; rt.ZIndex=5

-- ── Inicializa na tab ESP ────────────────────────────────
selectTab("esp")

print("╔══════════════════════════════════════════╗")
print("║  PUDIM HUB v4 — 99 Nights 2026          ║")
print("╠══════════════════════════════════════════╣")
print("║  ESP: 20 categorias (animais, itens…)   ║")
print("║  BRING: 16 botões individuais            ║")
print("║  FIX: Health>0 | Anchored=false          ║")
print("║  FIX: yield/100 obj — zero freeze        ║")
print("╚══════════════════════════════════════════╝")
