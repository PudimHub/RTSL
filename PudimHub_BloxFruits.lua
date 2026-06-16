-- ============================================================
--                    PUDIMHUB - RAYFIELD
--                    Com funções reais na Farm 1
-- ============================================================

-- Carregar Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Serviços
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
--                    VARIÁVEIS GLOBAIS
-- ============================================================
SelectWeaponFarm = "Melee"
AutoFarmType = "Above"
DisFarm = 30
FastAttack = true
FastShot = false
AttackToPlayersNow = false
bringfrec = 250
BringMobs = true
ByPassTP = false
AutoSetSpawn = true

_G.SkillZ = false
_G.SkillX = false
_G.SkillC = false
_G.SkillV = false
_G.SkillF = false

BusoHaki = true
KenHaki = false
DeleteAudioEffect = false
HideNotification = false

-- Variáveis do Farm
LevelFarmQuest = false
AutoFarmBossQuest = false
SelectBoss = "The Gorrila King"

-- ============================================================
--                    FUNÇÕES AUXILIARES
-- ============================================================
function getHead()
    local returntable = {}
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if (v.Head.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 70 then
                table.insert(returntable, v.HumanoidRootPart)
            end
        end
    end
    return returntable
end

function FastShooted()
    local ShootGunEvent = ReplicatedStorage.Modules.Net["RE/ShootGunEvent"]
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            local toolEquiped = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 50 then
                if toolEquiped and toolEquiped.ToolTip == "Gun" then
                    pcall(function()
                        LocalPlayer.Character[SelectWeaponFarm].RemoteFunctionShoot:InvokeServer(v.HumanoidRootPart.Position, v.HumanoidRootPart)
                        ShootGunEvent:FireServer(v.HumanoidRootPart.Position, { v.HumanoidRootPart })
                    end)
                end
            end
        end
    end
end

function FastAttacked()
    local getHeadAttack = getHead()
    local RegisterAttack = ReplicatedStorage.Modules.Net["RE/RegisterAttack"]
    local RegisterHit = ReplicatedStorage.Modules.Net["RE/RegisterHit"]
    for _, part in ipairs(getHeadAttack) do
        pcall(function()
            local toolEquiped = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if toolEquiped and (toolEquiped.ToolTip == "Melee" or toolEquiped.ToolTip == "Sword") then
                RegisterAttack:FireServer(0.0000001)
                RegisterHit:FireServer(part, {})
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end
        end)
    end
end

function AttackToPlayers()
    local RegisterAttack = ReplicatedStorage.Modules.Net["RE/RegisterAttack"]
    local RegisterHit = ReplicatedStorage.Modules.Net["RE/RegisterHit"]
    for _, v in pairs(Players:GetChildren()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 50 then
                local toolEquiped = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if toolEquiped and (toolEquiped.ToolTip == "Melee" or toolEquiped.ToolTip == "Sword") then
                    RegisterAttack:FireServer(0.1)
                    RegisterHit:FireServer(v.Character.Head, {})
                end
            end
        end
    end
end

function BringMonster(TargetName, TargetCFrame)
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v.Name == TargetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            if (v.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < bringfrec then
                v.HumanoidRootPart.CFrame = TargetCFrame
                v.HumanoidRootPart.CanCollide = false
                v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                v.HumanoidRootPart.Transparency = 1
                v.Humanoid:ChangeState(11)
                v.Humanoid:ChangeState(14)
                if v.Humanoid:FindFirstChild("Animator") then v.Humanoid.Animator:Destroy() end
            end
        end
    end
    pcall(sethiddenproperty, LocalPlayer, "SimulationRadius", math.huge)
end

function Tween(P1)
    local Distance = (P1.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    local Speed = 350
    if Distance > 1 then
        game:GetService("TweenService"):Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(Distance/Speed, Enum.EasingStyle.Linear), {CFrame = P1}):Play()
    end
end

function EquipTool(Tool)
    pcall(function()
        LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack[Tool])
    end)
end

function BTP(Tarpos)
    if (Tarpos.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude > 2000 then
        LocalPlayer.Character.Head:Destroy()
        LocalPlayer.Character.HumanoidRootPart.CFrame = Tarpos
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
        wait(1)
        LocalPlayer.Character.HumanoidRootPart.CFrame = Tarpos
        ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
        wait(7)
    elseif (Tarpos.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 2000 then
        Tween(Tarpos)
    end
end

-- ============================================================
--                    FUNÇÕES DE FARM
-- ============================================================

-- Check World
local First_Sea = false
local Second_Sea = false
local Third_Sea = false
local placeId = game.PlaceId
if placeId == 2753915549 then First_Sea = true
elseif placeId == 4442272183 then Second_Sea = true
elseif placeId == 7449423635 then Third_Sea = true end

-- Variáveis globais do farm
Ms = ""
NameQuest = ""
QuestLv = 1
NameMon = ""
CFrameQ = CFrame.new()
CFrameMon = CFrame.new()
Level_Farm_Name = ""
Level_Farm_CFrame = CFrame.new()

-- ============================================================
--                    CHECK LEVEL (FARM QUEST)
-- ============================================================
function CheckLevel()
    local Lv = LocalPlayer.Data.Level.Value
    if First_Sea then
        if Lv == 1 or Lv <= 9 then
            Ms = "Bandit"
            NameQuest = "BanditQuest1"
            QuestLv = 1
            NameMon = "Bandit"
            CFrameQ = CFrame.new(1060.9383544922, 16.455066680908, 1547.7841796875)
            CFrameMon = CFrame.new(1038.5533447266, 41.296249389648, 1576.5098876953)
        elseif Lv == 10 or Lv <= 14 then
            Ms = "Monkey"
            NameQuest = "JungleQuest"
            QuestLv = 1
            NameMon = "Monkey"
            CFrameQ = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102)
            CFrameMon = CFrame.new(-1448.1446533203, 50.851993560791, 63.60718536377)
        elseif Lv == 15 or Lv <= 29 then
            Ms = "Gorilla"
            NameQuest = "JungleQuest"
            QuestLv = 2
            NameMon = "Gorilla"
            CFrameQ = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102)
            CFrameMon = CFrame.new(-1142.6488037109, 40.462348937988, -515.39227294922)
        elseif Lv == 30 or Lv <= 39 then
            Ms = "Pirate"
            NameQuest = "BuggyQuest1"
            QuestLv = 1
            NameMon = "Pirate"
            CFrameQ = CFrame.new(-1140.1761474609, 4.752049446106, 3827.4057617188)
            CFrameMon = CFrame.new(-1201.0881347656, 40.628940582275, 3857.5966796875)
        elseif Lv == 40 or Lv <= 59 then
            Ms = "Brute"
            NameQuest = "BuggyQuest1"
            QuestLv = 2
            NameMon = "Brute"
            CFrameQ = CFrame.new(-1140.1761474609, 4.752049446106, 3827.4057617188)
            CFrameMon = CFrame.new(-1387.5324707031, 24.592035293579, 4100.9575195313)
        elseif Lv == 60 or Lv <= 74 then
            Ms = "Desert Bandit"
            NameQuest = "DesertQuest"
            QuestLv = 1
            NameMon = "Desert Bandit"
            CFrameQ = CFrame.new(896.51721191406, 6.4384617805481, 4390.1494140625)
            CFrameMon = CFrame.new(984.99896240234, 16.109552383423, 4417.91015625)
        elseif Lv == 75 or Lv <= 89 then
            Ms = "Desert Officer"
            NameQuest = "DesertQuest"
            QuestLv = 2
            NameMon = "Desert Officer"
            CFrameQ = CFrame.new(896.51721191406, 6.4384617805481, 4390.1494140625)
            CFrameMon = CFrame.new(1547.1510009766, 14.452038764954, 4381.8002929688)
        elseif Lv == 90 or Lv <= 99 then
            Ms = "Snow Bandit"
            NameQuest = "SnowQuest"
            QuestLv = 1
            NameMon = "Snow Bandit"
            CFrameQ = CFrame.new(1386.8073730469, 87.272789001465, -1298.3576660156)
            CFrameMon = CFrame.new(1356.3028564453, 105.76865386963, -1328.2418212891)
        elseif Lv == 100 or Lv <= 119 then
            Ms = "Snowman"
            NameQuest = "SnowQuest"
            QuestLv = 2
            NameMon = "Snowman"
            CFrameQ = CFrame.new(1386.8073730469, 87.272789001465, -1298.3576660156)
            CFrameMon = CFrame.new(1218.7956542969, 138.01184082031, -1488.0262451172)
        elseif Lv == 120 or Lv <= 149 then
            Ms = "Chief Petty Officer"
            NameQuest = "MarineQuest2"
            QuestLv = 1
            NameMon = "Chief Petty Officer"
            CFrameQ = CFrame.new(-5035.49609375, 28.677835464478, 4324.1840820313)
            CFrameMon = CFrame.new(-4931.1552734375, 65.793113708496, 4121.8393554688)
        elseif Lv == 150 or Lv <= 174 then
            Ms = "Sky Bandit"
            NameQuest = "SkyQuest"
            QuestLv = 1
            NameMon = "Sky Bandit"
            CFrameQ = CFrame.new(-4842.1372070313, 717.69543457031, -2623.0483398438)
            CFrameMon = CFrame.new(-4955.6411132813, 365.46365356445, -2908.1865234375)
        elseif Lv == 175 or Lv <= 189 then
            Ms = "Dark Master"
            NameQuest = "SkyQuest"
            QuestLv = 2
            NameMon = "Dark Master"
            CFrameQ = CFrame.new(-4842.1372070313, 717.69543457031, -2623.0483398438)
            CFrameMon = CFrame.new(-5148.1650390625, 439.04571533203, -2332.9611816406)
        elseif Lv == 190 or Lv <= 209 then
            Ms = "Prisoner"
            NameQuest = "PrisonerQuest"
            QuestLv = 1
            NameMon = "Prisoner"
            CFrameQ = CFrame.new(5310.60547, 0.350014925, 474.946594)
            CFrameMon = CFrame.new(4937.31885, 0.332031399, 649.574524)
        elseif Lv == 210 or Lv <= 249 then
            Ms = "Dangerous Prisoner"
            NameQuest = "PrisonerQuest"
            QuestLv = 2
            NameMon = "Dangerous Prisoner"
            CFrameQ = CFrame.new(5310.60547, 0.350014925, 474.946594)
            CFrameMon = CFrame.new(5099.6626, 0.351562679, 1055.7583)
        elseif Lv == 250 or Lv <= 274 then
            Ms = "Toga Warrior"
            NameQuest = "ColosseumQuest"
            QuestLv = 1
            NameMon = "Toga Warrior"
            CFrameQ = CFrame.new(-1577.7890625, 7.4151420593262, -2984.4838867188)
            CFrameMon = CFrame.new(-1872.5166015625, 49.080215454102, -2913.810546875)
        elseif Lv == 275 or Lv <= 299 then
            Ms = "Gladiator"
            NameQuest = "ColosseumQuest"
            QuestLv = 2
            NameMon = "Gladiator"
            CFrameQ = CFrame.new(-1577.7890625, 7.4151420593262, -2984.4838867188)
            CFrameMon = CFrame.new(-1521.3740234375, 81.203170776367, -3066.3139648438)
        elseif Lv == 300 or Lv <= 324 then
            Ms = "Military Soldier"
            NameQuest = "MagmaQuest"
            QuestLv = 1
            NameMon = "Military Soldier"
            CFrameQ = CFrame.new(-5316.1157226563, 12.262831687927, 8517.00390625)
            CFrameMon = CFrame.new(-5369.0004882813, 61.24352645874, 8556.4921875)
        elseif Lv == 325 or Lv <= 374 then
            Ms = "Military Spy"
            NameQuest = "MagmaQuest"
            QuestLv = 2
            NameMon = "Military Spy"
            CFrameQ = CFrame.new(-5316.1157226563, 12.262831687927, 8517.00390625)
            CFrameMon = CFrame.new(-5787.00293, 75.8262634, 8651.69922)
        elseif Lv == 375 or Lv <= 399 then
            Ms = "Fishman Warrior"
            NameQuest = "FishmanQuest"
            QuestLv = 1
            NameMon = "Fishman Warrior"
            CFrameQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            CFrameMon = CFrame.new(60844.10546875, 98.462875366211, 1298.3985595703)
        elseif Lv == 400 or Lv <= 449 then
            Ms = "Fishman Commando"
            NameQuest = "FishmanQuest"
            QuestLv = 2
            NameMon = "Fishman Commando"
            CFrameQ = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            CFrameMon = CFrame.new(61738.3984375, 64.207321166992, 1433.8375244141)
        elseif Lv == 450 or Lv <= 474 then
            Ms = "God's Guard"
            NameQuest = "SkyExp1Quest"
            QuestLv = 1
            NameMon = "God's Guard"
            CFrameQ = CFrame.new(-4721.8603515625, 845.30297851563, -1953.8489990234)
            CFrameMon = CFrame.new(-4628.0498046875, 866.92877197266, -1931.2352294922)
        elseif Lv == 475 or Lv <= 524 then
            Ms = "Shanda"
            NameQuest = "SkyExp1Quest"
            QuestLv = 2
            NameMon = "Shanda"
            CFrameQ = CFrame.new(-7863.1596679688, 5545.5190429688, -378.42266845703)
            CFrameMon = CFrame.new(-7685.1474609375, 5601.0751953125, -441.38876342773)
        elseif Lv == 525 or Lv <= 549 then
            Ms = "Royal Squad"
            NameQuest = "SkyExp2Quest"
            QuestLv = 1
            NameMon = "Royal Squad"
            CFrameQ = CFrame.new(-7903.3828125, 5635.9897460938, -1410.923828125)
            CFrameMon = CFrame.new(-7654.2514648438, 5637.1079101563, -1407.7550048828)
        elseif Lv == 550 or Lv <= 624 then
            Ms = "Royal Soldier"
            NameQuest = "SkyExp2Quest"
            QuestLv = 2
            NameMon = "Royal Soldier"
            CFrameQ = CFrame.new(-7903.3828125, 5635.9897460938, -1410.923828125)
            CFrameMon = CFrame.new(-7760.4106445313, 5679.9077148438, -1884.8112792969)
        elseif Lv == 625 or Lv <= 649 then
            Ms = "Galley Pirate"
            NameQuest = "FountainQuest"
            QuestLv = 1
            NameMon = "Galley Pirate"
            CFrameQ = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875)
            CFrameMon = CFrame.new(5557.1684570313, 152.32717895508, 3998.7758789063)
        elseif Lv >= 650 then
            Ms = "Galley Captain"
            NameQuest = "FountainQuest"
            QuestLv = 2
            NameMon = "Galley Captain"
            CFrameQ = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875)
            CFrameMon = CFrame.new(5677.6772460938, 92.786109924316, 4966.6323242188)
        end
    end
    if Second_Sea then
        if Lv == 700 or Lv <= 724 then
            Ms = "Raider"
            NameQuest = "Area1Quest"
            QuestLv = 1
            NameMon = "Raider"
            CFrameQ = CFrame.new(-427.72567749023, 72.99634552002, 1835.9426269531)
            CFrameMon = CFrame.new(68.874565124512, 93.635643005371, 2429.6752929688)
        elseif Lv == 725 or Lv <= 774 then
            Ms = "Mercenary"
            NameQuest = "Area1Quest"
            QuestLv = 2
            NameMon = "Mercenary"
            CFrameQ = CFrame.new(-427.72567749023, 72.99634552002, 1835.9426269531)
            CFrameMon = CFrame.new(-864.85009765625, 122.47104644775, 1453.1505126953)
        elseif Lv == 775 or Lv <= 799 then
            Ms = "Swan Pirate"
            NameQuest = "Area2Quest"
            QuestLv = 1
            NameMon = "Swan Pirate"
            CFrameQ = CFrame.new(635.61151123047, 73.096351623535, 917.81298828125)
            CFrameMon = CFrame.new(1065.3669433594, 137.64012145996, 1324.3798828125)
        elseif Lv == 800 or Lv <= 874 then
            Ms = "Factory Staff"
            NameQuest = "Area2Quest"
            QuestLv = 2
            NameMon = "Factory Staff"
            CFrameQ = CFrame.new(635.61151123047, 73.096351623535, 917.81298828125)
            CFrameMon = CFrame.new(533.22045898438, 128.46876525879, 355.62615966797)
        elseif Lv == 875 or Lv <= 899 then
            Ms = "Marine Lieutenant"
            NameQuest = "MarineQuest3"
            QuestLv = 1
            NameMon = "Marine Lieutenant"
            CFrameQ = CFrame.new(-2440.9934082031, 73.04190826416, -3217.7082519531)
            CFrameMon = CFrame.new(-2489.2622070313, 84.613594055176, -3151.8830566406)
        elseif Lv == 900 or Lv <= 949 then
            Ms = "Marine Captain"
            NameQuest = "MarineQuest3"
            QuestLv = 2
            NameMon = "Marine Captain"
            CFrameQ = CFrame.new(-2440.9934082031, 73.04190826416, -3217.7082519531)
            CFrameMon = CFrame.new(-2335.2026367188, 79.786659240723, -3245.8674316406)
        elseif Lv == 950 or Lv <= 974 then
            Ms = "Zombie"
            NameQuest = "ZombieQuest"
            QuestLv = 1
            NameMon = "Zombie"
            CFrameQ = CFrame.new(-5494.3413085938, 48.505931854248, -794.59094238281)
            CFrameMon = CFrame.new(-5536.4970703125, 101.08577728271, -835.59075927734)
        elseif Lv == 975 or Lv <= 999 then
            Ms = "Vampire"
            NameQuest = "ZombieQuest"
            QuestLv = 2
            NameMon = "Vampire"
            CFrameQ = CFrame.new(-5494.3413085938, 48.505931854248, -794.59094238281)
            CFrameMon = CFrame.new(-5806.1098632813, 16.722528457642, -1164.4384765625)
        elseif Lv == 1000 or Lv <= 1049 then
            Ms = "Snow Trooper"
            NameQuest = "SnowMountainQuest"
            QuestLv = 1
            NameMon = "Snow Trooper"
            CFrameQ = CFrame.new(607.05963134766, 401.44781494141, -5370.5546875)
            CFrameMon = CFrame.new(535.21051025391, 432.74209594727, -5484.9165039063)
        elseif Lv == 1050 or Lv <= 1099 then
            Ms = "Winter Warrior"
            NameQuest = "SnowMountainQuest"
            QuestLv = 2
            NameMon = "Winter Warrior"
            CFrameQ = CFrame.new(607.05963134766, 401.44781494141, -5370.5546875)
            CFrameMon = CFrame.new(1234.4449462891, 456.95419311523, -5174.130859375)
        elseif Lv == 1100 or Lv <= 1124 then
            Ms = "Lab Subordinate"
            NameQuest = "IceSideQuest"
            QuestLv = 1
            NameMon = "Lab Subordinate"
            CFrameQ = CFrame.new(-6061.841796875, 15.926671981812, -4902.0385742188)
            CFrameMon = CFrame.new(-5720.5576171875, 63.309471130371, -4784.6103515625)
        elseif Lv == 1125 or Lv <= 1174 then
            Ms = "Horned Warrior"
            NameQuest = "IceSideQuest"
            QuestLv = 2
            NameMon = "Horned Warrior"
            CFrameQ = CFrame.new(-6061.841796875, 15.926671981812, -4902.0385742188)
            CFrameMon = CFrame.new(-6292.751953125, 91.181983947754, -5502.6499023438)
        elseif Lv == 1175 or Lv <= 1199 then
            Ms = "Magma Ninja"
            NameQuest = "FireSideQuest"
            QuestLv = 1
            NameMon = "Magma Ninja"
            CFrameQ = CFrame.new(-5429.0473632813, 15.977565765381, -5297.9614257813)
            CFrameMon = CFrame.new(-5461.8388671875, 130.36347961426, -5836.4702148438)
        elseif Lv == 1200 or Lv <= 1249 then
            Ms = "Lava Pirate"
            NameQuest = "FireSideQuest"
            QuestLv = 2
            NameMon = "Lava Pirate"
            CFrameQ = CFrame.new(-5429.0473632813, 15.977565765381, -5297.9614257813)
            CFrameMon = CFrame.new(-5251.1889648438, 55.164535522461, -4774.4096679688)
        elseif Lv == 1250 or Lv <= 1274 then
            Ms = "Ship Deckhand"
            NameQuest = "ShipQuest1"
            QuestLv = 1
            NameMon = "Ship Deckhand"
            CFrameQ = CFrame.new(1040.2927246094, 125.08293151855, 32911.0390625)
            CFrameMon = CFrame.new(921.12365722656, 125.9839553833, 33088.328125)
        elseif Lv == 1275 or Lv <= 1299 then
            Ms = "Ship Engineer"
            NameQuest = "ShipQuest1"
            QuestLv = 2
            NameMon = "Ship Engineer"
            CFrameQ = CFrame.new(1040.2927246094, 125.08293151855, 32911.0390625)
            CFrameMon = CFrame.new(886.28179931641, 40.47790145874, 32800.83203125)
        elseif Lv == 1300 or Lv <= 1324 then
            Ms = "Ship Steward"
            NameQuest = "ShipQuest2"
            QuestLv = 1
            NameMon = "Ship Steward"
            CFrameQ = CFrame.new(971.42065429688, 125.08293151855, 33245.54296875)
            CFrameMon = CFrame.new(943.85504150391, 129.58183288574, 33444.3671875)
        elseif Lv == 1325 or Lv <= 1349 then
            Ms = "Ship Officer"
            NameQuest = "ShipQuest2"
            QuestLv = 2
            NameMon = "Ship Officer"
            CFrameQ = CFrame.new(971.42065429688, 125.08293151855, 33245.54296875)
            CFrameMon = CFrame.new(955.38458251953, 181.08335876465, 33331.890625)
        elseif Lv == 1350 or Lv <= 1374 then
            Ms = "Arctic Warrior"
            NameQuest = "FrostQuest"
            QuestLv = 1
            NameMon = "Arctic Warrior"
            CFrameQ = CFrame.new(5668.1372070313, 28.202531814575, -6484.6005859375)
            CFrameMon = CFrame.new(5935.4541015625, 77.26016998291, -6472.7568359375)
        elseif Lv == 1375 or Lv <= 1424 then
            Ms = "Snow Lurker"
            NameQuest = "FrostQuest"
            QuestLv = 2
            NameMon = "Snow Lurker"
            CFrameQ = CFrame.new(5668.1372070313, 28.202531814575, -6484.6005859375)
            CFrameMon = CFrame.new(5628.482421875, 57.574996948242, -6618.3481445313)
        elseif Lv == 1425 or Lv <= 1449 then
            Ms = "Sea Soldier"
            NameQuest = "ForgottenQuest"
            QuestLv = 1
            NameMon = "Sea Soldier"
            CFrameQ = CFrame.new(-3054.5827636719, 236.87213134766, -10147.790039063)
            CFrameMon = CFrame.new(-3185.0153808594, 58.789089202881, -9663.6064453125)
        elseif Lv >= 1450 then
            Ms = "Water Fighter"
            NameQuest = "ForgottenQuest"
            QuestLv = 2
            NameMon = "Water Fighter"
            CFrameQ = CFrame.new(-3054.5827636719, 236.87213134766, -10147.790039063)
            CFrameMon = CFrame.new(-3262.9301757813, 298.69036865234, -10552.529296875)
        end
    end
    if Third_Sea then
        if Lv == 1500 or Lv <= 1524 then
            Ms = "Pirate Millionaire"
            NameQuest = "PiratePortQuest"
            QuestLv = 1
            NameMon = "Pirate Millionaire"
            CFrameQ = CFrame.new(-289.61752319336, 43.819011688232, 5580.0903320313)
            CFrameMon = CFrame.new(-435.68109130859, 189.69866943359, 5551.0756835938)
        elseif Lv == 1525 or Lv <= 1574 then
            Ms = "Pistol Billionaire"
            NameQuest = "PiratePortQuest"
            QuestLv = 2
            NameMon = "Pistol Billionaire"
            CFrameQ = CFrame.new(-289.61752319336, 43.819011688232, 5580.0903320313)
            CFrameMon = CFrame.new(-236.53652954102, 217.46676635742, 6006.0883789063)
        elseif Lv == 1575 or Lv <= 1599 then
            Ms = "Dragon Crew Warrior"
            NameQuest = "AmazonQuest"
            QuestLv = 1
            NameMon = "Dragon Crew Warrior"
            CFrameQ = CFrame.new(5833.1147460938, 51.60498046875, -1103.0693359375)
            CFrameMon = CFrame.new(6301.9975585938, 104.77153015137, -1082.6075439453)
        elseif Lv == 1600 or Lv <= 1624 then
            Ms = "Dragon Crew Archer"
            NameQuest = "AmazonQuest"
            QuestLv = 2
            NameMon = "Dragon Crew Archer"
            CFrameQ = CFrame.new(5833.1147460938, 51.60498046875, -1103.0693359375)
            CFrameMon = CFrame.new(6831.1171875, 441.76708984375, 446.58615112305)
        elseif Lv == 1625 or Lv <= 1649 then
            Ms = "Female Islander"
            NameQuest = "AmazonQuest2"
            QuestLv = 1
            NameMon = "Female Islander"
            CFrameQ = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422)
            CFrameMon = CFrame.new(5792.5166015625, 848.14392089844, 1084.1818847656)
        elseif Lv == 1650 or Lv <= 1699 then
            Ms = "Giant Islander"
            NameQuest = "AmazonQuest2"
            QuestLv = 2
            NameMon = "Giant Islander"
            CFrameQ = CFrame.new(5446.8793945313, 601.62945556641, 749.45672607422)
            CFrameMon = CFrame.new(5009.5068359375, 664.11071777344, -40.960144042969)
        elseif Lv == 1700 or Lv <= 1724 then
            Ms = "Marine Commodore"
            NameQuest = "MarineTreeIsland"
            QuestLv = 1
            NameMon = "Marine Commodore"
            CFrameQ = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813)
            CFrameMon = CFrame.new(2198.0063476563, 128.71075439453, -7109.5043945313)
        elseif Lv == 1725 or Lv <= 1774 then
            Ms = "Marine Rear Admiral"
            NameQuest = "MarineTreeIsland"
            QuestLv = 2
            NameMon = "Marine Rear Admiral"
            CFrameQ = CFrame.new(2179.98828125, 28.731239318848, -6740.0551757813)
            CFrameMon = CFrame.new(3294.3142089844, 385.41125488281, -7048.6342773438)
        elseif Lv == 1775 or Lv <= 1799 then
            Ms = "Fishman Raider"
            NameQuest = "DeepForestIsland3"
            QuestLv = 1
            NameMon = "Fishman Raider"
            CFrameQ = CFrame.new(-10582.759765625, 331.78845214844, -8757.666015625)
            CFrameMon = CFrame.new(-10553.268554688, 521.38439941406, -8176.9458007813)
        elseif Lv == 1800 or Lv <= 1824 then
            Ms = "Fishman Captain"
            NameQuest = "DeepForestIsland3"
            QuestLv = 2
            NameMon = "Fishman Captain"
            CFrameQ = CFrame.new(-10583.099609375, 331.78845214844, -8759.4638671875)
            CFrameMon = CFrame.new(-10789.401367188, 427.18637084961, -9131.4423828125)
        elseif Lv == 1825 or Lv <= 1849 then
            Ms = "Forest Pirate"
            NameQuest = "DeepForestIsland"
            QuestLv = 1
            NameMon = "Forest Pirate"
            CFrameQ = CFrame.new(-13232.662109375, 332.40396118164, -7626.4819335938)
            CFrameMon = CFrame.new(-13489.397460938, 400.30349731445, -7770.251953125)
        elseif Lv == 1850 or Lv <= 1899 then
            Ms = "Mythological Pirate"
            NameQuest = "DeepForestIsland"
            QuestLv = 2
            NameMon = "Mythological Pirate"
            CFrameQ = CFrame.new(-13232.662109375, 332.40396118164, -7626.4819335938)
            CFrameMon = CFrame.new(-13508.616210938, 582.46228027344, -6985.3037109375)
        elseif Lv == 1900 or Lv <= 1924 then
            Ms = "Jungle Pirate"
            NameQuest = "DeepForestIsland2"
            QuestLv = 1
            NameMon = "Jungle Pirate"
            CFrameQ = CFrame.new(-12682.096679688, 390.88653564453, -9902.1240234375)
            CFrameMon = CFrame.new(-12267.103515625, 459.75262451172, -10277.200195313)
        elseif Lv == 1925 or Lv <= 1974 then
            Ms = "Musketeer Pirate"
            NameQuest = "DeepForestIsland2"
            QuestLv = 2
            NameMon = "Musketeer Pirate"
            CFrameQ = CFrame.new(-12682.096679688, 390.88653564453, -9902.1240234375)
            CFrameMon = CFrame.new(-13291.5078125, 520.47338867188, -9904.638671875)
        elseif Lv == 1975 or Lv <= 1999 then
            Ms = "Reborn Skeleton"
            NameQuest = "HauntedQuest1"
            QuestLv = 1
            NameMon = "Reborn Skeleton"
            CFrameQ = CFrame.new(-9480.80762, 142.130661, 5566.37305)
            CFrameMon = CFrame.new(-8761.77148, 183.431747, 6168.33301)
        elseif Lv == 2000 or Lv <= 2024 then
            Ms = "Living Zombie"
            NameQuest = "HauntedQuest1"
            QuestLv = 2
            NameMon = "Living Zombie"
            CFrameQ = CFrame.new(-9480.80762, 142.130661, 5566.37305)
            CFrameMon = CFrame.new(-10103.7529, 238.565979, 6179.75977)
        elseif Lv == 2025 or Lv <= 2049 then
            Ms = "Demonic Soul"
            NameQuest = "HauntedQuest2"
            QuestLv = 1
            NameMon = "Demonic Soul"
            CFrameQ = CFrame.new(-9516.9931640625, 178.00651550293, 6078.4653320313)
            CFrameMon = CFrame.new(-9712.03125, 204.69589233398, 6193.322265625)
        elseif Lv == 2050 or Lv <= 2074 then
            Ms = "Posessed Mummy"
            NameQuest = "HauntedQuest2"
            QuestLv = 2
            NameMon = "Posessed Mummy"
            CFrameQ = CFrame.new(-9516.9931640625, 178.00651550293, 6078.4653320313)
            CFrameMon = CFrame.new(-9545.7763671875, 69.619895935059, 6339.5615234375)
        elseif Lv == 2075 or Lv <= 2099 then
            Ms = "Peanut Scout"
            NameQuest = "NutsIslandQuest"
            QuestLv = 1
            NameMon = "Peanut Scout"
            CFrameQ = CFrame.new(-2105.53198, 37.2495995, -10195.5088)
            CFrameMon = CFrame.new(-2150.587890625, 122.49767303467, -10358.994140625)
        elseif Lv == 2100 or Lv <= 2124 then
            Ms = "Peanut President"
            NameQuest = "NutsIslandQuest"
            QuestLv = 2
            NameMon = "Peanut President"
            CFrameQ = CFrame.new(-2105.53198, 37.2495995, -10195.5088)
            CFrameMon = CFrame.new(-2150.587890625, 122.49767303467, -10358.994140625)
        elseif Lv == 2125 or Lv <= 2149 then
            Ms = "Ice Cream Chef"
            NameQuest = "IceCreamIslandQuest"
            QuestLv = 1
            NameMon = "Ice Cream Chef"
            CFrameQ = CFrame.new(-819.376709, 64.9259796, -10967.2832)
            CFrameMon = CFrame.new(-789.941528, 209.382889, -11009.9805)
        elseif Lv == 2150 or Lv <= 2199 then
            Ms = "Ice Cream Commander"
            NameQuest = "IceCreamIslandQuest"
            QuestLv = 2
            NameMon = "Ice Cream Commander"
            CFrameQ = CFrame.new(-819.376709, 64.9259796, -10967.2832)
            CFrameMon = CFrame.new(-789.941528, 209.382889, -11009.9805)
        elseif Lv == 2200 or Lv <= 2224 then
            Ms = "Cookie Crafter"
            NameQuest = "CakeQuest1"
            QuestLv = 1
            NameMon = "Cookie Crafter"
            CFrameQ = CFrame.new(-2022.29858, 36.9275894, -12030.9766)
            CFrameMon = CFrame.new(-2321.71216, 36.699482, -12216.7871)
        elseif Lv == 2225 or Lv <= 2249 then
            Ms = "Cake Guard"
            NameQuest = "CakeQuest1"
            QuestLv = 2
            NameMon = "Cake Guard"
            CFrameQ = CFrame.new(-2022.29858, 36.9275894, -12030.9766)
            CFrameMon = CFrame.new(-1418.11011, 36.6718941, -12255.7324)
        elseif Lv == 2250 or Lv <= 2274 then
            Ms = "Baking Staff"
            NameQuest = "CakeQuest2"
            QuestLv = 1
            NameMon = "Baking Staff"
            CFrameQ = CFrame.new(-1928.31763, 37.7296638, -12840.626)
            CFrameMon = CFrame.new(-1980.43848, 36.6716766, -12983.8418)
        elseif Lv == 2275 or Lv <= 2299 then
            Ms = "Head Baker"
            NameQuest = "CakeQuest2"
            QuestLv = 2
            NameMon = "Head Baker"
            CFrameQ = CFrame.new(-1928.31763, 37.7296638, -12840.626)
            CFrameMon = CFrame.new(-2251.5791, 52.2714615, -13033.3965)
        elseif Lv == 2300 or Lv <= 2324 then
            Ms = "Cocoa Warrior"
            NameQuest = "ChocQuest1"
            QuestLv = 1
            NameMon = "Cocoa Warrior"
            CFrameQ = CFrame.new(231.75, 23.9003029, -12200.292)
            CFrameMon = CFrame.new(167.978516, 26.2254658, -12238.874)
        elseif Lv == 2325 or Lv <= 2349 then
            Ms = "Chocolate Bar Battler"
            NameQuest = "ChocQuest1"
            QuestLv = 2
            NameMon = "Chocolate Bar Battler"
            CFrameQ = CFrame.new(231.75, 23.9003029, -12200.292)
            CFrameMon = CFrame.new(701.312073, 25.5824986, -12708.2148)
        elseif Lv == 2350 or Lv <= 2374 then
            Ms = "Sweet Thief"
            NameQuest = "ChocQuest2"
            QuestLv = 1
            NameMon = "Sweet Thief"
            CFrameQ = CFrame.new(151.198242, 23.8907146, -12774.6172)
            CFrameMon = CFrame.new(-140.258301, 25.5824986, -12652.3115)
        elseif Lv == 2375 or Lv <= 2400 then
            Ms = "Candy Rebel"
            NameQuest = "ChocQuest2"
            QuestLv = 2
            NameMon = "Candy Rebel"
            CFrameQ = CFrame.new(151.198242, 23.8907146, -12774.6172)
            CFrameMon = CFrame.new(47.9231453, 25.5824986, -13029.2402)
        elseif Lv == 2400 or Lv <= 2424 then
            Ms = "Candy Pirate"
            NameQuest = "CandyQuest1"
            QuestLv = 1
            NameMon = "Candy Pirate"
            CFrameQ = CFrame.new(-1149.328, 13.5759039, -14445.6143)
            CFrameMon = CFrame.new(-1437.56348, 17.1481285, -14385.6934)
        elseif Lv == 2425 or Lv <= 2449 then
            Ms = "Snow Demon"
            NameQuest = "CandyQuest1"
            QuestLv = 2
            NameMon = "Snow Demon"
            CFrameQ = CFrame.new(-1149.328, 13.5759039, -14445.6143)
            CFrameMon = CFrame.new(-916.222656, 17.1481285, -14638.8125)
        elseif Lv == 2450 or Lv <= 2474 then
            Ms = "Isle Outlaw"
            NameQuest = "TikiQuest1"
            QuestLv = 1
            NameMon = "Isle Outlaw"
            CFrameQ = CFrame.new(-16548.8164, 55.6059914, -172.8125)
            CFrameMon = CFrame.new(-16122.4062, 10.6328173, -257.351685)
        elseif Lv == 2475 or Lv <= 2499 then
            Ms = "Island Boy"
            NameQuest = "TikiQuest1"
            QuestLv = 2
            NameMon = "Island Boy"
            CFrameQ = CFrame.new(-16548.8164, 55.6059914, -172.8125)
            CFrameMon = CFrame.new(-16736.2266, 20.533947, -131.718811)
        elseif Lv == 2500 or Lv <= 2524 then
            Ms = "Sun-kissed Warrior"
            NameQuest = "TikiQuest2"
            QuestLv = 1
            NameMon = "Sun-kissed Warrior"
            CFrameQ = CFrame.new(-16541.0215, 54.770813, 1051.46118)
            CFrameMon = CFrame.new(-16413.5078, 54.6350479, 1054.43555)
        elseif Lv == 2525 or Lv <= 2549 then
            Ms = "Isle Champion"
            NameQuest = "TikiQuest2"
            QuestLv = 2
            NameMon = "Isle Champion"
            CFrameQ = CFrame.new(-16541.0215, 54.770813, 1051.46118)
            CFrameMon = CFrame.new(-16787.3203, 20.6350517, 992.131836)
        elseif Lv == 2550 or Lv <= 2574 then
            Ms = "Serpent Hunter"
            NameQuest = "TikiQuest3"
            QuestLv = 1
            NameMon = "Serpent Hunter"
            CFrameQ = CFrame.new(-16665.1914, 104.596405, 1579.69434)
            CFrameMon = CFrame.new(-16654.7754, 105.286232, 1579.67444)
        elseif Lv >= 2575 then
            Ms = "Skull Slayer"
            NameQuest = "TikiQuest3"
            QuestLv = 2
            NameMon = "Skull Slayer"
            CFrameQ = CFrame.new(-16665.1914, 104.596405, 1579.69434)
            CFrameMon = CFrame.new(-16654.7754, 105.286232, 1579.67444)
        end
    end
end

-- ============================================================
--                    CHECK BOSS QUEST
-- ============================================================
function CheckBossQuest()
    if First_Sea then
        if SelectBoss == "The Gorrila King" then
            BossMon = "The Gorilla King [Lv. 25] [Boss]"
            NameBoss = 'The Gorrila King'
            NameQuestBoss = "JungleQuest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-1601.6553955078, 36.85213470459, 153.38809204102)
            CFrameBoss = CFrame.new(-1088.75977, 8.13463783, -488.559906)
        elseif SelectBoss == "Bobby" then
            BossMon = "Bobby [Lv. 55] [Boss]"
            NameBoss = 'Bobby'
            NameQuestBoss = "BuggyQuest1"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-1140.1761474609, 4.752049446106, 3827.4057617188)
            CFrameBoss = CFrame.new(-1087.3760986328, 46.949409484863, 4040.1462402344)
        elseif SelectBoss == "The Saw" then
            BossMon = "The Saw [Lv. 100] [Boss]"
            NameBoss = 'The Saw'
            CFrameBoss = CFrame.new(-784.89715576172, 72.427383422852, 1603.5822753906)
        elseif SelectBoss == "Yeti" then
            BossMon = "Yeti [Lv. 110] [Boss]"
            NameBoss = 'Yeti'
            NameQuestBoss = "SnowQuest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(1386.8073730469, 87.272789001465, -1298.3576660156)
            CFrameBoss = CFrame.new(1218.7956542969, 138.01184082031, -1488.0262451172)
        elseif SelectBoss == "Mob Leader" then
            BossMon = "Mob Leader [Lv. 120] [Boss]"
            NameBoss = 'Mob Leader'
            CFrameBoss = CFrame.new(-2844.7307128906, 7.4180502891541, 5356.6723632813)
        elseif SelectBoss == "Vice Admiral" then
            BossMon = "Vice Admiral [Lv. 130] [Boss]"
            NameBoss = 'Vice Admiral'
            NameQuestBoss = "MarineQuest2"
            QuestLvBoss = 2
            CFrameQBoss = CFrame.new(-5036.2465820313, 28.677835464478, 4324.56640625)
            CFrameBoss = CFrame.new(-5006.5454101563, 88.032081604004, 4353.162109375)
        elseif SelectBoss == "Saber Expert" then
            NameBoss = 'Saber Expert'
            BossMon = "Saber Expert [Lv. 200] [Boss]"
            CFrameBoss = CFrame.new(-1458.89502, 29.8870335, -50.633564)
        elseif SelectBoss == "Warden" then
            BossMon = "Warden [Lv. 220] [Boss]"
            NameBoss = 'Warden'
            NameQuestBoss = "ImpelQuest"
            QuestLvBoss = 1
            CFrameBoss = CFrame.new(5278.04932, 2.15167475, 944.101929)
            CFrameQBoss = CFrame.new(5191.86133, 2.84020686, 686.438721)
        elseif SelectBoss == "Chief Warden" then
            BossMon = "Chief Warden [Lv. 230] [Boss]"
            NameBoss = 'Chief Warden'
            NameQuestBoss = "ImpelQuest"
            QuestLvBoss = 2
            CFrameBoss = CFrame.new(5206.92578, 0.997753382, 814.976746)
            CFrameQBoss = CFrame.new(5191.86133, 2.84020686, 686.438721)
        elseif SelectBoss == "Swan" then
            BossMon = "Swan [Lv. 240] [Boss]"
            NameBoss = 'Swan'
            NameQuestBoss = "ImpelQuest"
            QuestLvBoss = 3
            CFrameBoss = CFrame.new(5325.09619, 7.03906584, 719.570679)
            CFrameQBoss = CFrame.new(5191.86133, 2.84020686, 686.438721)
        elseif SelectBoss == "Magma Admiral" then
            BossMon = "Magma Admiral [Lv. 350] [Boss]"
            NameBoss = 'Magma Admiral'
            NameQuestBoss = "MagmaQuest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-5314.6220703125, 12.262420654297, 8517.279296875)
            CFrameBoss = CFrame.new(-5765.8969726563, 82.92064666748, 8718.3046875)
        elseif SelectBoss == "Fishman Lord" then
            BossMon = "Fishman Lord [Lv. 425] [Boss]"
            NameBoss = 'Fishman Lord'
            NameQuestBoss = "FishmanQuest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            CFrameBoss = CFrame.new(61260.15234375, 30.950881958008, 1193.4329833984)
        elseif SelectBoss == "Wysper" then
            BossMon = "Wysper [Lv. 500] [Boss]"
            NameBoss = 'Wysper'
            NameQuestBoss = "SkyExp1Quest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-7861.947265625, 5545.517578125, -379.85974121094)
            CFrameBoss = CFrame.new(-7866.1333007813, 5576.4311523438, -546.74816894531)
        elseif SelectBoss == "Thunder God" then
            BossMon = "Thunder God [Lv. 575] [Boss]"
            NameBoss = 'Thunder God'
            NameQuestBoss = "SkyExp2Quest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-7903.3828125, 5635.9897460938, -1410.923828125)
            CFrameBoss = CFrame.new(-7994.984375, 5761.025390625, -2088.6479492188)
        elseif SelectBoss == "Cyborg" then
            BossMon = "Cyborg [Lv. 675] [Boss]"
            NameBoss = 'Cyborg'
            NameQuestBoss = "FountainQuest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(5258.2788085938, 38.526931762695, 4050.044921875)
            CFrameBoss = CFrame.new(6094.0249023438, 73.770050048828, 3825.7348632813)
        elseif SelectBoss == "Ice Admiral" then
            BossMon = "Ice Admiral [Lv. 700] [Boss]"
            NameBoss = 'Ice Admiral'
            CFrameBoss = CFrame.new(1266.08948, 26.1757946, -1399.57678)
        elseif SelectBoss == "Greybeard" then
            BossMon = "Greybeard [Lv. 750] [Raid Boss]"
            NameBoss = 'Greybeard'
            CFrameBoss = CFrame.new(-5081.3452148438, 85.221641540527, 4257.3588867188)
        end
    end
    if Second_Sea then
        if SelectBoss == "Diamond" then
            BossMon = "Diamond [Lv. 750] [Boss]"
            NameBoss = 'Diamond'
            NameQuestBoss = "Area1Quest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-427.5666809082, 73.313781738281, 1835.4208984375)
            CFrameBoss = CFrame.new(-1576.7166748047, 198.59265136719, 13.724286079407)
        elseif SelectBoss == "Jeremy" then
            BossMon = "Jeremy [Lv. 850] [Boss]"
            NameBoss = 'Jeremy'
            NameQuestBoss = "Area2Quest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(636.79943847656, 73.413787841797, 918.00415039063)
            CFrameBoss = CFrame.new(2006.9261474609, 448.95666503906, 853.98284912109)
        elseif SelectBoss == "Fajita" then
            BossMon = "Fajita [Lv. 925] [Boss]"
            NameBoss = 'Fajita'
            NameQuestBoss = "MarineQuest3"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-2441.986328125, 73.359344482422, -3217.5324707031)
            CFrameBoss = CFrame.new(-2172.7399902344, 103.32216644287, -4015.025390625)
        elseif SelectBoss == "Don Swan" then
            BossMon = "Don Swan [Lv. 1000] [Boss]"
            NameBoss = 'Don Swan'
            CFrameBoss = CFrame.new(2286.2004394531, 15.177839279175, 863.8388671875)
        elseif SelectBoss == "Smoke Admiral" then
            BossMon = "Smoke Admiral [Lv. 1150] [Boss]"
            NameBoss = 'Smoke Admiral'
            NameQuestBoss = "IceSideQuest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-5429.0473632813, 15.977565765381, -5297.9614257813)
            CFrameBoss = CFrame.new(-5275.1987304688, 20.757257461548, -5260.6669921875)
        elseif SelectBoss == "Awakened Ice Admiral" then
            BossMon = "Awakened Ice Admiral [Lv. 1400] [Boss]"
            NameBoss = 'Awakened Ice Admiral'
            NameQuestBoss = "FrostQuest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(5668.9780273438, 28.519989013672, -6483.3520507813)
            CFrameBoss = CFrame.new(6403.5439453125, 340.29766845703, -6894.5595703125)
        elseif SelectBoss == "Tide Keeper" then
            BossMon = "Tide Keeper [Lv. 1475] [Boss]"
            NameBoss = 'Tide Keeper'
            NameQuestBoss = "ForgottenQuest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-3053.9814453125, 237.18954467773, -10145.0390625)
            CFrameBoss = CFrame.new(-3795.6423339844, 105.88877105713, -11421.307617188)
        elseif SelectBoss == "Darkbeard" then
            BossMon = "Darkbeard [Lv. 1000] [Raid Boss]"
            NameBoss = 'Darkbeard'
            CFrameBoss = CFrame.new(3677.08203125, 62.751937866211, -3144.8332519531)
        elseif SelectBoss == "Cursed Captain" then
            BossMon = "Cursed Captain [Lv. 1325] [Raid Boss]"
            NameBoss = 'Cursed Captain'
            CFrameBoss = CFrame.new(916.928589, 181.092773, 33422)
        elseif SelectBoss == "Order" then
            BossMon = "Order [Lv. 1250] [Raid Boss]"
            NameBoss = 'Order'
            CFrameBoss = CFrame.new(-6217.2021484375, 28.047645568848, -5053.1357421875)
        end
    end
    if Third_Sea then
        if SelectBoss == "Stone" then
            BossMon = "Stone [Lv. 1550] [Boss]"
            NameBoss = 'Stone'
            NameQuestBoss = "PiratePortQuest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-289.76705932617, 43.819011688232, 5579.9384765625)
            CFrameBoss = CFrame.new(-1027.6512451172, 92.404174804688, 6578.8530273438)
        elseif SelectBoss == "Island Empress" then
            BossMon = "Island Empress [Lv. 1675] [Boss]"
            NameBoss = 'Island Empress'
            NameQuestBoss = "AmazonQuest2"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(5445.9541015625, 601.62945556641, 751.43792724609)
            CFrameBoss = CFrame.new(5543.86328125, 668.97399902344, 199.0341796875)
        elseif SelectBoss == "Kilo Admiral" then
            BossMon = "Kilo Admiral [Lv. 1750] [Boss]"
            NameBoss = 'Kilo Admiral'
            NameQuestBoss = "MarineTreeIsland"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(2179.3010253906, 28.731239318848, -6739.9741210938)
            CFrameBoss = CFrame.new(2764.2233886719, 432.46154785156, -7144.4580078125)
        elseif SelectBoss == "Captain Elephant" then
            BossMon = "Captain Elephant [Lv. 1875] [Boss]"
            NameBoss = 'Captain Elephant'
            NameQuestBoss = "DeepForestIsland"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-13232.682617188, 332.40396118164, -7626.01171875)
            CFrameBoss = CFrame.new(-13376.7578125, 433.28689575195, -8071.392578125)
        elseif SelectBoss == "Beautiful Pirate" then
            BossMon = "Beautiful Pirate [Lv. 1950] [Boss]"
            NameBoss = 'Beautiful Pirate'
            NameQuestBoss = "DeepForestIsland2"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-12682.096679688, 390.88653564453, -9902.1240234375)
            CFrameBoss = CFrame.new(5283.609375, 22.56223487854, -110.78285217285)
        elseif SelectBoss == "Cake Queen" then
            BossMon = "Cake Queen [Lv. 2175] [Boss]"
            NameBoss = 'Cake Queen'
            NameQuestBoss = "IceCreamIslandQuest"
            QuestLvBoss = 3
            CFrameQBoss = CFrame.new(-819.376709, 64.9259796, -10967.2832)
            CFrameBoss = CFrame.new(-678.648804, 381.353943, -11114.2012)
        elseif SelectBoss == "Longma" then
            BossMon = "Longma [Lv. 2000] [Boss]"
            NameBoss = 'Longma'
            CFrameBoss = CFrame.new(-10238.875976563, 389.7912902832, -9549.7939453125)
        elseif SelectBoss == "Soul Reaper" then
            BossMon = "Soul Reaper [Lv. 2100] [Raid Boss]"
            NameBoss = 'Soul Reaper'
            CFrameBoss = CFrame.new(-9524.7890625, 315.80429077148, 6655.7192382813)
        elseif SelectBoss == "rip_indra True Form" then
            BossMon = "rip_indra True Form [Lv. 5000] [Raid Boss]"
            NameBoss = 'rip_indra True Form'
            CFrameBoss = CFrame.new(-5415.3920898438, 505.74133300781, -2814.0166015625)
        end
    end
end

-- ============================================================
--                    CRIAÇÃO DA JANELA
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "PudimHub",
    LoadingTitle = "PudimHub",
    LoadingSubtitle = "Carregando...",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "PudimHub"
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

-- Notificação de inicialização
Rayfield:Notify({
    Title = "PudimHub",
    Content = "Carregado com sucesso!",
    Duration = 3,
    Image = 4483362458
})

-- ============================================================
--                        ABAS
-- ============================================================

-- ========== HOME ==========
local HomeTab = Window:CreateTab("🏠 Home", 4483362458)
local HomeSection = HomeTab:CreateSection("Informações do Jogador")

HomeTab:CreateParagraph({
    Title = "📊 Status do Jogador",
    Content = "Level: 2450\n💰 Dinheiro: $12.450.000\n💎 Fragmentos: 8.250\n🏴‍☠️ Bounty: 15.000.000"
})

local ServerSection = HomeTab:CreateSection("Informações do Servidor")
HomeTab:CreateParagraph({
    Title = "🌐 Status do Servidor",
    Content = "Servidor: BR-01 (São Paulo)\nPing: 32ms\nJogadores: 12/32\nTempo de Atividade: 3h 24m"
})

-- ========== FARM 1 (COM FUNÇÕES REAIS) ==========
local Farm1Tab = Window:CreateTab("⚔️ Farm 1", 4483362458)
local Farm1Section = Farm1Tab:CreateSection("Configurações de Farm")

-- LEVEL FARM QUEST (COM FUNÇÕES REAIS)
Farm1Tab:CreateToggle({
    Name = "🤖 Level Farm Quest",
    CurrentValue = false,
    Flag = "LevelFarmQuest",
    Callback = function(Value)
        LevelFarmQuest = Value
    end
})

-- Loop do Level Farm Quest
spawn(function()
    while task.wait() do
        if LevelFarmQuest then
            pcall(function()
                CheckLevel()
                if not string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon) or LocalPlayer.PlayerGui.Main.Quest.Visible == false then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                    if ByPassTP then
                        BTP(CFrameQ)
                    else
                        Tween(CFrameQ)
                    end
                    if (CFrameQ.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 5 then
                        wait(1)
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, QuestLv)
                    end
                elseif string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameMon) or LocalPlayer.PlayerGui.Main.Quest.Visible == true then
                    if Workspace.Enemies:FindFirstChild(Ms) then
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                if v.Name == Ms then
                                    repeat
                                        task.wait()
                                        EquipTool(SelectWeapon)
                                        Tween(v.HumanoidRootPart.CFrame * Farm_Mode)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                        v.HumanoidRootPart.Transparency = 1
                                        Level_Farm_Name = v.Name
                                        Level_Farm_CFrame = v.HumanoidRootPart.CFrame
                                        -- Auto Click
                                        local toolEquiped = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                        if toolEquiped and (toolEquiped.ToolTip == "Melee" or toolEquiped.ToolTip == "Sword") then
                                            local RegisterAttack = ReplicatedStorage.Modules.Net["RE/RegisterAttack"]
                                            local RegisterHit = ReplicatedStorage.Modules.Net["RE/RegisterHit"]
                                            RegisterAttack:FireServer(0.0000001)
                                            RegisterHit:FireServer(v.HumanoidRootPart, {})
                                        end
                                    until not LevelFarmQuest or not v.Parent or v.Humanoid.Health <= 0 or not Workspace.Enemies:FindFirstChild(v.Name) or LocalPlayer.PlayerGui.Main.Quest.Visible == false
                                end
                            end
                        end
                    else
                        Tween(CFrameMon)
                    end
                end
            end)
        end
    end
end)

-- ========== FARM 1 - BOSS FARM ==========
local BossSection = Farm1Tab:CreateSection("Auto Farm Boss")

-- SELECT BOSS (DROPDOWN COM LISTA DE CHEFES)
local BossList = {}
if First_Sea then
    BossList = {"The Gorrila King", "Bobby", "The Saw", "Yeti", "Mob Leader", "Vice Admiral", "Saber Expert", "Warden", "Chief Warden", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Ice Admiral", "Greybeard"}
elseif Second_Sea then
    BossList = {"Diamond", "Jeremy", "Fajita", "Don Swan", "Smoke Admiral", "Awakened Ice Admiral", "Tide Keeper", "Darkbeard", "Cursed Captain", "Order"}
elseif Third_Sea then
    BossList = {"Stone", "Island Empress", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "Cake Queen", "Longma", "Soul Reaper", "rip_indra True Form"}
end

Farm1Tab:CreateDropdown({
    Name = "🎮 Seletor de Chefes",
    Options = BossList,
    CurrentOption = BossList[1] or "Nenhum chefe disponível",
    Flag = "BossSelector",
    Callback = function(Value)
        SelectBoss = Value
    end
})

-- AUTO FARM BOSS (QUEST)
Farm1Tab:CreateToggle({
    Name = "👑 Auto Farm Boss (Quest)",
    CurrentValue = false,
    Flag = "AutoFarmBossQuest",
    Callback = function(Value)
        AutoFarmBossQuest = Value
    end
})

-- Loop do Auto Farm Boss
spawn(function()
    while task.wait() do
        if AutoFarmBossQuest then
            pcall(function()
                CheckBossQuest()
                if not string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameBoss) or LocalPlayer.PlayerGui.Main.Quest.Visible == false then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                    if ByPassTP then
                        BTP(CFrameQBoss)
                    else
                        Tween(CFrameQBoss)
                    end
                    if (CFrameQBoss.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 5 then
                        wait(1)
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuestBoss, QuestLvBoss)
                    end
                elseif string.find(LocalPlayer.PlayerGui.Main.Quest.Container.QuestTitle.Title.Text, NameBoss) or LocalPlayer.PlayerGui.Main.Quest.Visible == true then
                    if Workspace.Enemies:FindFirstChild(SelectBoss) then
                        for _, v in pairs(Workspace.Enemies:GetChildren()) do
                            if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                if v.Name == SelectBoss then
                                    repeat
                                        task.wait()
                                        EquipTool(SelectWeapon)
                                        Tween(v.HumanoidRootPart.CFrame * Farm_Mode)
                                        v.HumanoidRootPart.CanCollide = false
                                        v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                        v.HumanoidRootPart.Transparency = 1
                                        v.Humanoid:ChangeState(11)
                                        v.Humanoid:ChangeState(14)
                                        -- Auto Click
                                        local toolEquiped = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                                        if toolEquiped and (toolEquiped.ToolTip == "Melee" or toolEquiped.ToolTip == "Sword") then
                                            local RegisterAttack = ReplicatedStorage.Modules.Net["RE/RegisterAttack"]
                                            local RegisterHit = ReplicatedStorage.Modules.Net["RE/RegisterHit"]
                                            RegisterAttack:FireServer(0.0000001)
                                            RegisterHit:FireServer(v.HumanoidRootPart, {})
                                        end
                                    until not AutoFarmBossQuest or not v.Parent or v.Humanoid.Health <= 0 or not Workspace.Enemies:FindFirstChild(v.Name) or LocalPlayer.PlayerGui.Main.Quest.Visible == false
                                end
                            end
                        end
                    else
                        Tween(CFrameBoss)
                    end
                end
            end)
        end
    end
end)

-- ========== FARM 2 ==========
local Farm2Tab = Window:CreateTab("📈 Farm 2", 4483362458)
local Farm2Section = Farm2Tab:CreateSection("Auto Farm Mastery")

Farm2Tab:CreateToggle({
    Name = "⚔️ Auto Farm Mastery - Sword",
    CurrentValue = false,
    Flag = "MasterySword",
    Callback = function() end
})

Farm2Tab:CreateToggle({
    Name = "👊 Auto Farm Mastery - Melee",
    CurrentValue = false,
    Flag = "MasteryMelee",
    Callback = function() end
})

Farm2Tab:CreateToggle({
    Name = "🍎 Auto Farm Mastery - Devil Fruit",
    CurrentValue = false,
    Flag = "MasteryDevil",
    Callback = function() end
})

-- ========== FARM 3 ==========
local Farm3Tab = Window:CreateTab("👑 Farm 3", 4483362458)
local Farm3Section = Farm3Tab:CreateSection("Auto Farm Bosses")

Farm3Tab:CreateToggle({
    Name = "👑 Auto Farm Bosses (Todos)",
    CurrentValue = false,
    Flag = "AutoFarmBosses",
    Callback = function() end
})

Farm3Tab:CreateDropdown({
    Name = "🎮 Seletor de Chefes",
    Options = {"Saber Expert", "Greybeard", "Cake Queen", "Diamond", "Fajita", "Don Swan", "Cursed Captain", "Rip_indra"},
    CurrentOption = "Saber Expert",
    Flag = "BossSelector2",
    Callback = function() end
})

-- ========== FARM MORE ==========
local FarmMoreTab = Window:CreateTab("📦 Farm More", 4483362458)
local FarmMoreSection = FarmMoreTab:CreateSection("Farms Secundários")

FarmMoreTab:CreateToggle({
    Name = "📦 Auto Chest Collector",
    CurrentValue = false,
    Flag = "FarmChest",
    Callback = function() end
})

FarmMoreTab:CreateToggle({
    Name = "⚙️ Auto Material Farm",
    CurrentValue = false,
    Flag = "FarmMaterial",
    Callback = function() end
})

FarmMoreTab:CreateToggle({
    Name = "🦴 Auto Bones Farm",
    CurrentValue = false,
    Flag = "FarmBones",
    Callback = function() end
})

FarmMoreTab:CreateToggle({
    Name = "🍎 Auto Fruit Finder",
    CurrentValue = false,
    Flag = "FarmFruit",
    Callback = function() end
})

-- ========== TELEPORT ==========
local TeleportTab = Window:CreateTab("🗺️ Teleport", 4483362458)
local TeleportSection = TeleportTab:CreateSection("Sistema de Teleporte")

TeleportTab:CreateDropdown({
    Name = "🌍 Seletor de Mundo",
    Options = {"Primeiro Mar", "Segundo Mar", "Terceiro Mar"},
    CurrentOption = "Primeiro Mar",
    Flag = "WorldSelector",
    Callback = function() end
})

TeleportTab:CreateDropdown({
    Name = "🏝️ Seletor de Ilhas",
    Options = {"Starter Island", "Jungle", "Pirate Village", "Desert", "Frozen Village", "Marine Ford", "Skypiea", "Colosseum"},
    CurrentOption = "Starter Island",
    Flag = "IslandSelector",
    Callback = function() end
})

TeleportTab:CreateButton({
    Name = "🚀 Teleportar",
    Callback = function()
        Rayfield:Notify({
            Title = "Teleporte",
            Content = "Simulação de teleporte",
            Duration = 2
        })
    end
})

-- ========== SEA EVENTS ==========
local SeaTab = Window:CreateTab("🌊 Sea Events", 4483362458)
local SeaSection = SeaTab:CreateSection("Eventos Marítimos")

SeaTab:CreateToggle({
    Name = "🐋 Auto Sea Beast Hunter",
    CurrentValue = false,
    Flag = "SeaBeast",
    Callback = function() end
})

SeaTab:CreateToggle({
    Name = "🚢 Auto Ship Raid",
    CurrentValue = false,
    Flag = "ShipRaid",
    Callback = function() end
})

SeaTab:CreateToggle({
    Name = "🔍 Auto Find Mirage Island",
    CurrentValue = false,
    Flag = "FindMirage",
    Callback = function() end
})

SeaTab:CreateParagraph({
    Title = "📡 Status dos Eventos",
    Content = "Sea Beasts: 0\nShips: 0\nMirage Island: ❌"
})

-- ========== ISLANDS ==========
local IslandsTab = Window:CreateTab("🏝️ Islands", 4483362458)
local IslandsSection = IslandsTab:CreateSection("Informações das Ilhas")

local islands = {"Starter Island (Lv 1-10)", "Jungle (Lv 15-30)", "Pirate Village (Lv 35-45)", "Desert (Lv 50-70)", "Frozen Village (Lv 80-100)", "Marine Ford (Lv 120-150)", "Skypiea (Lv 160-200)", "Colosseum (Lv 210-250)"}

for _, island in ipairs(islands) do
    IslandsTab:CreateButton({
        Name = "📍 " .. island .. " - Check-in",
        Callback = function()
            Rayfield:Notify({
                Title = "Check-in",
                Content = "Visitando " .. island,
                Duration = 2
            })
        end
    })
end

-- ========== RACE V4 ==========
local RaceTab = Window:CreateTab("⭐ Race V4", 4483362458)
local RaceSection = RaceTab:CreateSection("Progresso Racial V4")

RaceTab:CreateToggle({
    Name = "⚡ Auto Trial Completion",
    CurrentValue = false,
    Flag = "AutoTrial",
    Callback = function() end
})

RaceTab:CreateToggle({
    Name = "🌀 Auto Mirage Gear Collection",
    CurrentValue = false,
    Flag = "AutoMirageGear",
    Callback = function() end
})

RaceTab:CreateToggle({
    Name = "💪 Train Mastery V4",
    CurrentValue = false,
    Flag = "TrainMasteryV4",
    Callback = function() end
})

RaceTab:CreateParagraph({
    Title = "📊 Progresso Atual",
    Content = "Raça Atual: Human\nTrials Completos: 2/5\nGears Encontrados: 1/3\nMastery V4: 47%"
})

-- ========== SHOP ==========
local ShopTab = Window:CreateTab("🛒 Shop", 4483362458)

local ShopFighting = ShopTab:CreateSection("Estilos de Luta")
for _, style in ipairs({"Dragon Talon", "Electric Claw", "Death Step", "Sharkman Karate", "Superhuman", "Godhuman"}) do
    ShopTab:CreateButton({
        Name = "🥋 " .. style .. " - 3.000 Fragmentos",
        Callback = function()
            Rayfield:Notify({
                Title = "Loja",
                Content = "Simulação: " .. style .. " adquirido",
                Duration = 2
            })
        end
    })
end

local ShopSword = ShopTab:CreateSection("Espadas")
for _, sword in ipairs({"True Triple Katana", "Dark Blade", "Cursed Dual Katana", "Saber V2", "Hallow Scythe"}) do
    ShopTab:CreateButton({
        Name = "⚔️ " .. sword .. " - 5.000 Fragmentos",
        Callback = function()
            Rayfield:Notify({
                Title = "Loja",
                Content = "Simulação: " .. sword .. " adquirida",
                Duration = 2
            })
        end
    })
end

local ShopFruit = ShopTab:CreateSection("Frutas")
for _, fruit in ipairs({"Dragon (Mítico)", "Leopard (Mítico)", "Dough (Mítico)", "Spirit (Lendário)", "Control (Lendário)"}) do
    ShopTab:CreateButton({
        Name = "🍎 " .. fruit .. " - 3.500 Fragmentos",
        Callback = function()
            Rayfield:Notify({
                Title = "Loja",
                Content = "Simulação: " .. fruit .. " adicionada",
                Duration = 2
            })
        end
    })
end

-- ========== RAID ==========
local RaidTab = Window:CreateTab("🐉 Raid", 4483362458)
local RaidSection = RaidTab:CreateSection("Configurações de Raid")

RaidTab:CreateDropdown({
    Name = "🌀 Tipo de Raid",
    Options = {"Flame Raid", "Ice Raid", "Dark Raid", "Light Raid", "Earth Raid"},
    CurrentOption = "Flame Raid",
    Flag = "RaidType",
    Callback = function() end
})

RaidTab:CreateDropdown({
    Name = "💠 Seletor de Chips",
    Options = {"Fire Chip", "Water Chip", "Thunder Chip", "Wind Chip", "Crystal Chip"},
    CurrentOption = "Fire Chip",
    Flag = "ChipSelector",
    Callback = function() end
})

RaidTab:CreateToggle({
    Name = "🚀 Auto Start Raid",
    CurrentValue = false,
    Flag = "AutoStartRaid",
    Callback = function() end
})

-- ========== MORE ==========
local MoreTab = Window:CreateTab("⋯ More", 4483362458)
local MoreSection = MoreTab:CreateSection("Extras")

MoreTab:CreateButton({
    Name = "🎁 Menu de Códigos",
    Callback = function()
        Rayfield:Notify({
            Title = "Códigos",
            Content = "Códigos: PUDIM2024, BLOXFRUITS, ULTIMATE",
            Duration = 3
        })
    end
})

MoreTab:CreateButton({
    Name = "👥 Créditos",
    Callback = function()
        Rayfield:Notify({
            Title = "Créditos",
            Content = "Design: PudimHub Team | Rayfield UI",
            Duration = 3
        })
    end
})

MoreTab:CreateButton({
    Name = "📱 Discord Oficial",
    Callback = function()
        Rayfield:Notify({
            Title = "Discord",
            Content = "discord.gg/pudimhub (Servidor fictício)",
            Duration = 3
        })
    end
})

MoreTab:CreateButton({
    Name = "🐙 GitHub do Projeto",
    Callback = function()
        Rayfield:Notify({
            Title = "GitHub",
            Content = "github.com/pudimhub/rayfield-ui",
            Duration = 3
        })
    end
})

-- ============================================================
--                    ABA SETTINGS (COM FUNÇÕES)
-- ============================================================
local SettingsTab = Window:CreateTab("⚙️ Settings", 4483362458)

-- Main Setting
local MainSettingSection = SettingsTab:CreateSection("Main Setting")

SettingsTab:CreateDropdown({
    Name = "Select Weapon",
    Options = {"Melee", "Blox Fruit", "Sword", "Gun"},
    CurrentOption = "Melee",
    Flag = "SelectWeapon",
    Callback = function(Value)
        SelectWeaponFarm = Value
    end
})

SettingsTab:CreateDropdown({
    Name = "Select Farm Type",
    Options = {"Above", "Beside"},
    CurrentOption = "Above",
    Flag = "FarmType",
    Callback = function(Value)
        AutoFarmType = Value
    end
})

SettingsTab:CreateInput({
    Name = "Distance Farm",
    PlaceholderText = "30",
    RemoveTextAfterFocus = false,
    Flag = "DistanceFarm",
    Callback = function(Value)
        DisFarm = tonumber(Value) or 30
    end
})

SettingsTab:CreateToggle({
    Name = "Fast Attack (Melee and Sword)",
    CurrentValue = true,
    Flag = "FastAttack",
    Callback = function(Value)
        FastAttack = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Fast Attack (Gun)",
    CurrentValue = false,
    Flag = "FastShot",
    Callback = function(Value)
        FastShot = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Attack Melee Player",
    CurrentValue = false,
    Flag = "AttackPlayers",
    Callback = function(Value)
        AttackToPlayersNow = Value
    end
})

SettingsTab:CreateInput({
    Name = "Bring Mobs Distance",
    PlaceholderText = "250",
    RemoveTextAfterFocus = false,
    Flag = "BringDistance",
    Callback = function(Value)
        bringfrec = tonumber(Value) or 250
    end
})

SettingsTab:CreateToggle({
    Name = "Bring Mob",
    CurrentValue = true,
    Flag = "BringMobs",
    Callback = function(Value)
        BringMobs = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Bypass Teleport",
    CurrentValue = false,
    Flag = "BypassTeleport",
    Callback = function(Value)
        ByPassTP = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Set Spawn Point",
    CurrentValue = true,
    Flag = "AutoSetSpawn",
    Callback = function(Value)
        AutoSetSpawn = Value
    end
})

SettingsTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        local pc = LocalPlayer.Character
        if pc then
            for _, p in pairs(pc:GetDescendants()) do
                if p:IsA("BasePart") then
                    p:Destroy()
                end
            end
        end
        Rayfield:Notify({
            Title = "Reset",
            Content = "Personagem resetado!",
            Duration = 2
        })
    end
})

-- Skill Mastery
local SkillSection = SettingsTab:CreateSection("Skill Mastery")

SettingsTab:CreateToggle({
    Name = "Use Skill Z",
    CurrentValue = false,
    Flag = "SkillZ",
    Callback = function(Value)
        _G.SkillZ = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Use Skill X",
    CurrentValue = false,
    Flag = "SkillX",
    Callback = function(Value)
        _G.SkillX = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Use Skill C",
    CurrentValue = false,
    Flag = "SkillC",
    Callback = function(Value)
        _G.SkillC = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Use Skill V",
    CurrentValue = false,
    Flag = "SkillV",
    Callback = function(Value)
        _G.SkillV = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Use Skill F",
    CurrentValue = false,
    Flag = "SkillF",
    Callback = function(Value)
        _G.SkillF = Value
    end
})

-- Ability Settings
local AbilitySection = SettingsTab:CreateSection("Ability Settings")

SettingsTab:CreateToggle({
    Name = "Buso Haki",
    CurrentValue = true,
    Flag = "BusoHaki",
    Callback = function(Value)
        BusoHaki = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Ken Haki",
    CurrentValue = false,
    Flag = "KenHaki",
    Callback = function(Value)
        KenHaki = Value
    end
})

-- Misc Settings
local MiscSection = SettingsTab:CreateSection("Misc Settings")

SettingsTab:CreateToggle({
    Name = "Disable Audio Effect",
    CurrentValue = false,
    Flag = "DisableAudio",
    Callback = function(Value)
        DeleteAudioEffect = Value
    end
})

SettingsTab:CreateToggle({
    Name = "Hide Notification",
    CurrentValue = false,
    Flag = "HideNotification",
    Callback = function(Value)
        HideNotification = Value
    end
})

SettingsTab:CreateButton({
    Name = "Destroy Effect Animation",
    Callback = function()
        pcall(function()
            ReplicatedStorage.Assets.Models:Destroy()
            ReplicatedStorage.Assets.GUI:Destroy()
            ReplicatedStorage.Assets.SlashHit:Destroy()
            Rayfield:Notify({
                Title = "Efeitos",
                Content = "Efeitos destruídos!",
                Duration = 2
            })
        end)
    end
})

-- ============================================================
--                    LOOPS DE FUNÇÕES
-- ============================================================
spawn(function()
    while wait() do
        if AutoFarmType == "Above" then
            Farm_Mode = CFrame.new(0, DisFarm, 0) * CFrame.Angles(math.rad(-90), 0, 0)
        else
            Farm_Mode = CFrame.new(0, 2, DisFarm) * CFrame.Angles(math.rad(0), 0, 0)
        end
    end
end)

spawn(function()
    while task.wait() do
        if FastAttack then
            pcall(function()
                repeat task.wait()
                    FastAttacked()
                until not FastAttack
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if FastShot then
            pcall(function()
                repeat task.wait()
                    FastShooted()
                until not FastShot
            end)
        end
    end
end)

spawn(function()
    while task.wait() do
        if AttackToPlayersNow then
            pcall(AttackToPlayers)
        end
    end
end)

spawn(function()
    while wait() do
        if AutoSetSpawn then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SetSpawnPoint")
            end)
        end
    end
end)

spawn(function()
    while wait() do
        if BusoHaki and not LocalPlayer.Character:FindFirstChild("HasBuso") then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
            end)
        end
    end
end)

spawn(function()
    while wait() do
        if KenHaki and not LocalPlayer.Character:FindFirstChild("Highlight") then
            VirtualInputManager:SendKeyEvent(true, "K", false, game)
            wait(0.1)
            VirtualInputManager:SendKeyEvent(false, "K", false, game)
        end
    end
end)

spawn(function()
    while wait() do
        if DeleteAudioEffect then
            for _, v in pairs(Workspace["_WorldOrigin"]:GetChildren()) do
                if v.Name == "Sounds" then
                    for _, s in pairs(v:GetChildren()) do
                        if s:IsA("Part") then s:Destroy() end
                    end
                end
                if v.Name == "CurvedRing" or v.Name == "SlashHit" or v.Name == "SwordSlash" then
                    v:Destroy()
                end
            end
        end
    end
end)

spawn(function()
    while task.wait() do
        if HideNotification then
            for _, n in pairs(LocalPlayer.PlayerGui.Notifications:GetChildren()) do
                n:Destroy()
            end
        end
    end
end)

-- ============================================================
--                    NOTIFICAÇÃO FINAL
-- ============================================================
Rayfield:Notify({
    Title = "PudimHub",
    Content = "Interface carregada com sucesso!",
    Duration = 4
})