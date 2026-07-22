
-- ╔══════════════════════════════════════════════════════════════════╗
-- ║ PUDIM HUB — v5 COMPLETE + Notification System v3 ║
-- ║ + Toggle Notifications in the Info tab ║
-- ║ + Integrated notifications in ESP, Bring, Player, Advanced ║
-- ╚══════════════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")
local SoundService     = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ══════════════════════════════════════════════════════════════════════
-- PUDIM HUB — GATE: só executa o hub depois do clique em JOGAR
-- ══════════════════════════════════════════════════════════════════════
local _LaunchHub  -- forward declaration
local _hubLaunched = false
local _SplashGui   = nil


-- ══════════════════════════════════════════════════════════════════════
-- PUDIM HUB — INICIALIZAÇÃO INSTANTÂNEA (Sem Splash Screen)
-- ══════════════════════════════════════════════════════════════════════
task.defer(function()
    local success, err = pcall(function()
        if _LaunchHub then
            _LaunchHub()
        end
    end)
    if not success then
        warn("⚠️ Ocorreu um erro ao abrir o Pudim Hub instantaneamente:")
        print(err)
    end
end)


-- ══════════════════════════════════════════════════════════════════════
-- WRAP: todo o hub fica dentro de _LaunchHub (só roda ao clicar JOGAR)
-- ══════════════════════════════════════════════════════════════════════
-- Paleta VoidWare — constantes globais (usadas em múltiplos blocos)
local VD_BG      = Color3.fromRGB(68,  44, 108)
local VD_SIDEBAR = Color3.fromRGB(56,  36,  92)
local VD_TOPBAR  = Color3.fromRGB(58,  38,  96)
local VD_ROW     = Color3.fromRGB(88,  62, 132)
local VD_ROW_HOV = Color3.fromRGB(100, 74, 148)
local VD_TAB_ACT = Color3.fromRGB(96,  66, 148)
local VD_TEXT    = Color3.fromRGB(255, 248, 255)
local VD_MUTED   = Color3.fromRGB(175, 155, 210)
local VD_SECTION = Color3.fromRGB(215, 198, 240)
local VD_STROKE  = Color3.fromRGB(108, 82, 158)
local VD_DIVIDER = Color3.fromRGB(100, 76, 148)
local _vdOpen    = nil

_LaunchHub = function()
-- Upvalues compartilhados entre blocos de função
local getCampfirePos, _campfirePosCache
local fNextLO, afNextLO, makeSec
local freezeEnabled, freezeRadius
local startFreezeAura, stopFreezeAura, updateCircleRadius
local BRING_CATS
local makeToggle
-- ── Player layout order (compartilhado entre PLAYER TAB e FARM PART 2) ──
local plLO = 0
local plNextLO

-- ── Estilo de Bring global (padrão, espalhado, juntos, circulo) ──
local bringStyle    = "padrao"   -- padrão inicial
local bringDestMode = "jogador"  -- padrão: Jogador (sem cadeado)
local bringSpeed    = "normal"   -- normal | rapido | mega

local Player = Players.LocalPlayer

-- ── Helpers globais — disponíveis em todos os tabs ───────────────
local _remDragStart = nil
local _remDragStop  = nil
local function _getDragRemotes()
    if _remDragStart and _remDragStop then return true end
    local ok = pcall(function()
        local re = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents",3)
        _remDragStart = re:WaitForChild("RequestStartDraggingItem",3)
        _remDragStop  = re:WaitForChild("StopDraggingItem",3)
    end)
    return ok and _remDragStart and _remDragStop
end

local function moveItem(item, pos)
    if not item or not item:IsDescendantOf(workspace) then return end
    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
    if not part then return end
    if not item.PrimaryPart then pcall(function() item.PrimaryPart = part end) end
    if not _getDragRemotes() then return end
    pcall(function()
        _remDragStart:FireServer(item)
        if bringSpeed == "normal" then task.wait(0.05)
        elseif bringSpeed == "rapido" then task.wait(0.01)
        end -- mega: sem delay
        item:SetPrimaryPartCFrame(CFrame.new(pos))
        if bringSpeed == "normal" then task.wait(0.05)
        elseif bringSpeed == "rapido" then task.wait(0.01)
        end -- mega: sem delay
        _remDragStop:FireServer(item)
    end)
end

local function _getItemsFolder()
    return workspace:FindFirstChild("Items")
end

local Cam    = workspace.CurrentCamera

-- ══════════════════════════════════════════════════════
-- SISTEMA DE IDIOMAS — Dados
-- ══════════════════════════════════════════════════════
local LANGUAGES = {
    { code="PT-BR", flag="🇧🇷", name="Português (Brasil)",   short="PT-BR" },
    { code="EN-US", flag="🇺🇸", name="English (USA)",         short="EN-US" },
    { code="ES-ES", flag="🇪🇸", name="Español",               short="ES-ES" },
    { code="ZH-CN", flag="🇨🇳", name="中文 (普通话)",          short="ZH-CN" },
    { code="HI-IN", flag="🇮🇳", name="हिन्दी",               short="HI-IN" },
    { code="AR-SA", flag="🇸🇦", name="العربية",               short="AR-SA" },
    { code="BN-BD", flag="🇧🇩", name="বাংলা",                short="BN-BD" },
    { code="RU-RU", flag="🇷🇺", name="Русский",               short="RU-RU" },
}

-- ══════════════════════════════════════════════════════
-- SISTEMA DE TRADUÇÃO INTELIGENTE v2
-- Base: PT-BR. Outros idiomas só definem o que muda.
-- T(key) busca: idioma atual → EN-US → PT-BR → key
-- ══════════════════════════════════════════════════════
local TR_BASE = {
    -- ── Abas ──────────────────────────────────────────
    tabInfo="Info",               tabStatus="Status",       tabFarm="Farm",
    tabTeleportar="Teleportar",
    tabEsp="ESP",                 tabBring="Bring",         tabAvFarm="Avançado Farm",
    tabPlayer="Player",           tabConfig="Configurações",tabAvFunc="Avançado Funções",
    -- ── Bring: grupo novo (update Aliens Revenge / Bat Cave / Fairy Biome) ──
    bringGrpNovo="BRING — Novidades (Atualização 2026)",
    -- ── Grupos sidebar ────────────────────────────────
    groupGeral="GERAL",           groupCombate="COMBATE",   groupExtra="EXTRA",
    -- ── Sistema de idiomas ────────────────────────────
    langSystem="Sistema de idiomas", langCurrent="Idioma",
    popupTitle="Deseja mudar o idioma?", popupYes="Sim",    popupNo="Não",
    notifLangChanged="Idioma alterado para ",
    -- ── Info Tab ──────────────────────────────────────
    infoStatus="🎮  Jogando 99 Nights in the Forest",
    infoStatusSub="Hub v5",
    -- ── Notificações toggle ───────────────────────────
    notifTitle="Notificações",    notifDesc="Ativa/desativa todas as notificações do hub",
    notifOn="ATIVO",              notifOff="DESATIVO",
    notifHistTitle="Histórico de Notificações",
    notifHistClear="🗑 Limpar",   notifHistEmpty="📭  Nenhuma notificação ainda.",
    notifHistOn="Histórico ativado — notificações serão salvas. ✓",
    notifHistCleared="Histórico de notificações limpo.",
    -- ── Welcome / Tip ─────────────────────────────────
    notifWelcome="Carregado!",    notifWelcomeMsg="Bem-vindo, ",
    notifTip="Dica",              notifTipMsg="Passe o mouse na notificação para pausar o timer 🔔",
    -- ── Status Tab ────────────────────────────────────
    stLive="● LIVE",
    stFps="FPS",                  stFpsExc="Excelente",      stFpsBom="Bom",             stFpsBaixo="Baixo",
    stPing="Ping",                stPingBoa="Boa conexão",   stPingMod="Moderado",       stPingRuim="Ruim",
    stPlayers="Jogadores",        stPlayersYou="você",     stPlayersMax="Max: ",
    stRegion="Região: ",          stMemory="Memória",
    -- ── Servidor por ID ───────────────────────────────
    srvTitle="Servidor por ID",
    srvSub="Cole o Job ID do servidor para tentar entrar",
    srvBtn="→ Ir",                srvConnecting="🔄 Tentando conectar...",
    srvTeleporting="✓ Teleportando...", srvInvalidId="⚠ Insira um Job ID válido",
    srvNotifTitle="Servidor por ID", srvNotifConnecting="Conectando ao servidor: ",
    srvNotifError="Não foi possível conectar. Verifique o ID.",
    -- ── Rejoin ────────────────────────────────────────
    rejoinBtn="🔄  REJOIN SERVER",
    rejoinNotif="Rejoin",         rejoinMsg="Reconectando ao servidor...",
    -- ── Farm Tab — Aura Congelar ──────────────────────
    freezeTitle="❄️  Aura Congelar",
    freezeDesc="Força TODOS os mobs no raio a ficarem imóveis/presos no chão com força máxima.",
    freezeOn="❄️ Aura Congelar",  freezeOnMsg=" studs — mobs congelados com força máxima!",
    freezeOff="❄️ Aura Congelar", freezeOffMsg="Desativada — mobs descongelados.",
    freezeRadius="Raio",          freezePlus="+",  freezeMinus="-",
    -- ── Player Tab ────────────────────────────────────
    flyTitle="✈️  Fly",           flyDesc="Voe livremente pelo mapa. W/A/S/D para mover.",
    flyOn="Fly Ativo",            flyOnMsg="W/A/S/D mover • Space subir • Ctrl descer",
    flyOff="Fly",                 flyOffMsg="Voo desativado.",
    noclipTitle="👻  Noclip",     noclipDesc="Atravessa paredes e objetos sólidos.",
    noclipOn="Noclip",            noclipOnMsg="Atravessando paredes. Anti-void ativo.",
    noclipOff="Noclip",           noclipOffMsg="Colisão restaurada.",
    tpClickTitle="🖱️  TP Click",  tpClickDesc="Clique no chão para se teleportar até lá.",
    tpClickOn="TP Click",         tpClickOnMsg="Clique no chão para teleportar.",
    tpClickOff="TP Click",        tpClickOffMsg="Teleporte por clique desativado.",
    boosterTitle="⚡  Booster Ultra",  boosterDesc="Reduz visuais para máxima performance.",
    boosterOn="Booster Ultra",    boosterOnMsg="Ativo — visuais reduzidos para máxima performance.",
    boosterOff="Booster Ultra",   boosterOffMsg="Desativado — visuais restaurados.",
    remFxTitle="🎆  Remover Efeitos",  remFxDesc="Remove partículas e luzes do mapa.",
    remFxOn="Remover Efeitos",    remFxOnMsg="Partículas e luzes desativadas.",
    remFxOff="Remover Efeitos",   remFxOffMsg="Efeitos restaurados.",
    remNpcTitle="🚫  Remover NPCs",    remNpcDesc="NPCs ficam invisíveis e sem colisão.",
    remNpcOn="Remover NPCs",      remNpcOnMsg="NPCs invisíveis e sem colisão.",
    remNpcOff="Remover NPCs",     remNpcOffMsg="NPCs restaurados.",
    clearLagTitle="🧹  Clear Lag",     clearLagDesc="Reduz qualidade gráfica ao mínimo.",
    clearLagOn="Clear Lag",       clearLagOnMsg="Qualidade reduzida ao mínimo.",
    clearLagOff="Clear Lag",      clearLagOffMsg="Qualidade restaurada.",
    -- ── Bring Tab ─────────────────────────────────────
    bringAllTitle="⚡ BRING ALL",
    bringAllDesc="Traz TODOS os recursos do mapa de uma só vez",
    bringAllBtn="▼  BRING ALL",   bringAllBtnSearching="⏳ Buscando...",
    bringSuccess=" itens coletados com sucesso! ★",
    bringFail="Nenhum item encontrado no mapa.",
    bringBtnLabel="▼ BRING",      bringBtnSearching="⏳...",
    bringItemSuccess=" item(s) coletado(s) com sucesso! ✓",
    bringItemFail="Nenhum item encontrado.",
    -- ── Teleporte (painel) ────────────────────────────
    tpPanelSelect="▼  Selecionar", tpPanelClose="▲  Fechar",
    tpPanelBtn="🚀  Teleportar",   tpPanelSearching="🔍 Buscando...",
    tpPanelArrived="✅  Chegou!",  tpPanelError="⚠️ Erro ao teleportar. Tente novamente.",
    tpPanelNotFound=" não encontrado. Explore mais o mapa!",
    tpPanelSuccess="Teleportado para ",tpPanelSuccessEnd=" ✓",
    tpPanelFail="Falha no teleporte. Tente novamente.",
    -- ── Aimbot ────────────────────────────────────────
    aimbotSecTitle="🎯 AIMBOT CLÁSSICO (Projéteis)",
    aimbotTitle="🎯 Aimbot (Guided)",
    aimbotDesc="Projéteis se movem automaticamente para o animal mais próximo.",
    aimbotOn="Aimbot",            aimbotOnMsg="Projéteis guiados ativados.",
    aimbotOff="Aimbot",           aimbotOffMsg="Desativado.",
    aimbotAutoTitle="🤖 Aimbot AUTO",
    aimbotAutoDesc="Com arma ranged equipada: mira e atira automaticamente nos animais.",
    aimbotAutoOn="Aimbot AUTO",   aimbotAutoOnMsg="Modo automático ativado — atira sozinho!",
    aimbotAutoOff="Aimbot AUTO",  aimbotAutoOffMsg="Modo automático desativado.",
    -- ── ESP ───────────────────────────────────────────
    espOn="ESP Ativo",            espOff="ESP Inativo",
    -- ── Copied ────────────────────────────────────────
    copied="✓ Copiado!",
    -- ── ESP Grupos ────────────────────────────────────
    espGroupEntities="ESP — Entidades",     espGroupResources="ESP — Recursos & Combustível",
    espGroupFood="ESP — Comida & Natureza", espGroupEquipment="ESP — Equipamentos",
    -- ── Player Tab seções ─────────────────────────────
    plSecSpeed="⚡ VELOCIDADE & PULO",      plSecFly="✈️ VOO & NOCLIP",
    plSecUtil="🔧 UTILIDADES",
    plSecCamera="📷 CÂMERA",               plSecAntiDebuff="🛡 PROTEÇÃO",
    plSecGod="👻 INVISIBILIDADE",
    -- ── Avançado Farm seção ───────────────────────────
    avFarmSecFreeze="❄️  CONGELAR",
    -- ── Bring All notif ───────────────────────────────
    bringAllNotifSearching="Localizando todos os itens no mapa...",
    -- ── Player Tab ────────────────────────────────────────────────
    plSpeedTitle="⚡ Velocidade",   plSpeedDesc="Velocidade de caminhada (padrão: 16)",
    plJumpTitle="🦘 Pulo",          plJumpDesc="Altura do pulo (padrão: 50)",
    plFlyToggle="✈️ Fly",           plFlyDesc="W/A/S/D mover • Space = subir • Ctrl = descer",
    plFlySpeedTitle="💨 Vel. Voo",  plFlySpeedDesc="Velocidade de voo (padrão: 40)",
    plNoclipToggle="👻 Noclip",     plNoclipDesc="Atravessa paredes • Anti-void Y = -100",
    plTpClickToggle="🖱️ TP Click",  plTpClickDesc="Clique no chão para se teleportar",
    -- ── Kill Aura ─────────────────────────────────────────────────
    kaSecTitle="⚔️  KILL AURA",
    kaTitle="⚔️  Kill Aura",
    kaDesc="Equipe uma arma e clique normalmente — 1 clique acerta TODOS os mobs no range.",
    kaRangeLabel="⚔️ Range",
    -- ── ESP Animais (unificado) ────────────────────────────────────
    espAnimaisLabel="🐾 Animais",
    espAnimaisDesc="Coelho, Cavalo, Kiwi, Peru + Lobo, Urso, Urso Polar, Raposa Ártica, Sapo, Escorpião, Mamute, Helefante, Caranguejo Meteoro",
    -- ── Bring Grupos ───────────────────────────────────────────────
    bringGrpFuel="BRING — Combustível & Recursos",
    bringGrpFood="BRING — Comida & Natureza",
    bringGrpEquip="BRING — Equipamentos",
    bringGrpSpecials="BRING — Especiais",
    -- ── Bring Labels ───────────────────────────────────────────────
    bLogLabel="🪵 Bring Log",
    bCombustLabel="🔥 Bring Combustível",
    bCarcacasLabel="🦴 Bring Carcaças",
    bSucataLabel="🔩 Bring Sucata",
    bMateriaisLabel="💎 Bring Materiais",
    bComidasLabel="🍖 Bring Comidas",
    bPeixesLabel="🐟 Bring Peixes",
    bSementesLabel="🌱 Bring Sementes",
    bFerrLabel="🪓 Bring Ferramentas",
    bArmasLabel="⚔️ Bring Armas",
    bAmmoLabel="🔫 Bring Munição",
    bCuraLabel="💊 Bring Cura",
    bPeltsLabel="🦺 Bring Pelts",
    bChavesLabel="🗝️ Bring Chaves",
    bPocoesLabel="🧪 Bring Poções",
    bBlueprintLabel="📋 Bring Blueprints",
    -- ── Bring Descs ────────────────────────────────────────────────
    bLogDesc="Apenas: Log",
    bCombustDesc="Carvão, Biocombustível, Galão, Barril de Óleo…",
    bCarcacasDesc="Lobo, Urso, Urso Polar, Helefante, Sapo, Corpo Alien…",
    bSucataDesc="Parafuso, Chapa de Metal, Lixo OVNI, Pneu…",
    bMateriaisDesc="Gema Cultista, Gema Floresta, Moeda Musgo…",
    bComidasDesc="Cenoura, Milho, Bife, Costela, Ensopado, Doce…",
    bPeixesDesc="Cavala, Salmão, Peixe-Palhaço, Tubarão, Enguia de Lava…",
    bSementesDesc="Pimenta, Baga, Flor, Dripleaf, Moonflower…",
    bFerrDesc="Sacos, Machados, Varas, Flautas, Armaduras…",
    bArmasDesc="Lança, Espada de Gelo, Besta, Revólver, Rifle…",
    bAmmoDesc="Munição Revólver, Munição Rifle, Munição Espingarda",
    bCuraDesc="Curativo, Kit Médico",
    bPeltsDesc="Pata de Coelho, Pele de Lobo, Pele de Urso, Raposa Ártica…",
    bChavesDesc="Chave Vermelha, Azul, Amarela, Cinza, Sapo",
    bPocoesDesc="Dripleaf, Bulbo Moonflower, Pétala Stareweed, Mandrágora",
    bBlueprintDesc="Blueprint Criação, Defesa, Móveis, Baú Obsidiron…",
    -- ── ESP Labels ─────────────────────────────────────────────────
    espPlayersLabel="👤 Jogadores",
    espPlayersDesc="Todos os jogadores no servidor",
    espKidsLabel="👶 Crianças Perdidas",
    espKidsDesc="Dino, Kraken, Squid, Koala Kid",
    espMonstrosLabel="💀 Monstros",
    espMonstrosDesc="The Deer, The Owl, The Ram",
    espCultistasLabel="⚔️ Cultistas",
    espCultistasDesc="Cultista, Besta, Juggernaut, Rei, Mega…",
    espAliensLabel="👽 Aliens",
    espAliensDesc="Alien, Elite Alien",
    espLogLabel="🪵 Log",
    espLogDesc="Log — combustível principal",
    espCombustivelLabel="🔥 Combustível",
    espCombustivelDesc="Carvão, Biocombustível, Galão, Barril…",
    espCarcacasLabel="🦴 Carcaças",
    espCarcacasDesc="Corpos de Lobo/Urso/Urso Polar/Mamute/Helefante…",
    espSucataLabel="🔩 Sucata",
    espSucataDesc="Parafuso, Chapa de Metal, Lixo OVNI, Pneu…",
    espMateriaisLabel="💎 Materiais",
    espMateriaisDesc="Gema Cultista, Gema Floresta, Moeda Musgo, Obsidiron…",
    espComidasLabel="🍖 Comidas",
    espComidasDesc="Cenoura, Milho, Baga, Bife, Costela, Ensopado, Doce…",
    espPeixesLabel="🐟 Peixes",
    espPeixesDesc="Cavala, Salmão, Peixe-Palhaço, Tubarão, Enguia de Lava…",
    espSementesLabel="🌱 Sementes",
    espSementesDesc="Pimenta, Baga, Flor, Vaga-Lume, Dripleaf…",
    espFerrLabel="🪓 Ferramentas & Bolsas",
    espFerrDesc="Machados, Sacos, Varas, Flautas, Armadura…",
    espArmasLabel="⚔️ Armas",
    espArmasDesc="Lança, Besta, Espada de Gelo, Revólver, Rifle…",
    espAmmoLabel="🔫 Munição",
    espAmmoDesc="Munição Revólver, Munição Rifle, Munição Espingarda",
    espCuraLabel="💊 Cura & Pelts",
    espCuraDesc="Curativo, Kit Médico, Pele de Lobo, Pele de Urso…",
    espChavesLabel="🗝️ Chaves",
    espChavesDesc="Chave Vermelha, Azul, Amarela, Cinza, Sapo",
    espBigornaLabel="⚙️ Peças de Bigorna",
    espBigornaDesc="Parte Dianteira/Traseira/Base da Bigorna + Meteoro",
    espPocoesLabel="🧪 Poções",
    espPocoesDesc="Dripleaf, Bulbo Moonflower, Pétala Stareweed, Mandrágora",
    espBlueprintLabel="📋 Blueprints",
    espBlueprintDesc="Blueprint Criação, Defesa, Móveis, Baú Obsidiron…",
    -- ── Kill Aura notif ────────────────────────────────────────────
    kaOnMsg="Ativo! Equipe uma arma e clique para acertar todos no range",
    kaOffMsg="Desativado.",
}

-- Cada idioma: só as chaves que diferem do PT-BR
local TR_LANGS = {
    ["EN-US"] = {
        -- Abas
        tabAvFarm="Advanced Farm",      tabConfig="Settings",       tabAvFunc="Advanced Functions",
        tabTeleportar="Teleport",
        -- Grupos
        groupGeral="GENERAL",           groupCombate="COMBAT",
        -- Idioma
        langSystem="Language System",   langCurrent="Language",
        popupTitle="Change language?",  popupYes="Yes",             popupNo="No",
        notifLangChanged="Language changed to ",
        -- Info
        infoStatus="🎮  Playing 99 Nights in the Forest",
        -- Notif toggle
        notifTitle="Notifications",     notifDesc="Enables/disables all hub notifications",
        notifOn="ON",                   notifOff="OFF",
        notifHistTitle="Notification History",
        notifHistClear="🗑 Clear",      notifHistEmpty="📭  No notifications yet.",
        notifHistOn="History enabled — notifications will be saved. ✓",
        notifHistCleared="Notification history cleared.",
        -- Welcome/Tip
        notifWelcome="Loaded!",         notifWelcomeMsg="Welcome, ",
        notifTip="Tip",                 notifTipMsg="Hover over the notification to pause the timer 🔔",
        -- Status
        stFpsExc="Excellent",           stFpsBom="Good",            stFpsBaixo="Low",
        stPingBoa="Good connection",    stPingMod="Moderate",       stPingRuim="Poor connection",
        stPlayersYou="you",             stPlayersMax="Max: ",
        stRegion="Region: ",
        -- Servidor
        srvTitle="Server by ID",
        srvSub="Paste the Job ID to try joining",
        srvBtn="→ Go",                  srvConnecting="🔄 Connecting...",
        srvTeleporting="✓ Teleporting...", srvInvalidId="⚠ Enter a valid Job ID",
        srvNotifTitle="Server by ID",   srvNotifConnecting="Connecting to server: ",
        srvNotifError="Could not connect. Check the ID.",
        -- Rejoin
        rejoinMsg="Reconnecting to server...",
        -- Kill Aura
        kaSecTitle="⚔️  KILL AURA",
        kaTitle="⚔️  Kill Aura",
        kaDesc="Equip a melee weapon and click normally — 1 click hits ALL mobs in range.",
        kaRangeLabel="⚔️ Range",
        -- ESP Animals
        espAnimaisLabel="🐾 Animals",
        espAnimaisDesc="Bunny, Horse, Kiwi, Turkey + Wolf, Bear, Polar Bear, Arctic Fox, Frog, Scorpion, Mammoth, Hellephant, Meteor Crab",
        -- Aimbot
        aimbotSecTitle="🎯 CLASSIC AIMBOT (Projectiles)",
        aimbotTitle="🎯 Aimbot (Guided)",
        aimbotDesc="Projectiles move automatically to the nearest animal.",
        aimbotOnMsg="Guided projectiles activated.",
        aimbotOffMsg="Deactivated.",
        aimbotAutoTitle="🤖 Auto Aimbot",
        aimbotAutoDesc="With ranged weapon equipped: aims and shoots nearby animals automatically.",
        aimbotAutoOnMsg="Auto mode activated — fires automatically!",
        aimbotAutoOffMsg="Auto mode deactivated.",
        -- ESP
        espOn="ESP Active",            espOff="ESP Inactive",
        -- Copied
        copied="✓ Copied!",
        -- Bring Groups
        bringGrpFuel="BRING — Fuel & Resources",
        bringGrpFood="BRING — Food & Nature",
        bringGrpEquip="BRING — Equipment",
        bringGrpSpecials="BRING — Specials",
        -- Bring Labels
        bLogLabel="🪵 Bring Log",
        bCombustLabel="🔥 Bring Fuel",
        bCarcacasLabel="🦴 Bring Carcasses",
        bSucataLabel="🔩 Bring Scrap",
        bMateriaisLabel="💎 Bring Materials",
        bComidasLabel="🍖 Bring Food",
        bPeixesLabel="🐟 Bring Fish",
        bSementesLabel="🌱 Bring Seeds",
        bFerrLabel="🪓 Bring Tools",
        bArmasLabel="⚔️ Bring Weapons",
        bAmmoLabel="🔫 Bring Ammo",
        bCuraLabel="💊 Bring Healing",
        bPeltsLabel="🦺 Bring Pelts",
        bChavesLabel="🗝️ Bring Keys",
        bPocoesLabel="🧪 Bring Potions",
        bBlueprintLabel="📋 Bring Blueprints",
        -- Bring Descs
        bLogDesc="Only: Log",
        bCombustDesc="Coal, Biofuel, Fuel Canister, Oil Barrel…",
        bCarcacasDesc="Wolf, Bear, PolarBear, Hellephant, Frog, Alien Corpse…",
        bSucataDesc="Bolt, Sheet Metal, UFO Junk, Tyre…",
        bMateriaisDesc="Cultist Gem, Forest Gem, Mossy Coin…",
        bComidasDesc="Carrot, Corn, Steak, Ribs, Stew, Candy…",
        bPeixesDesc="Mackerel, Salmon, Clownfish, Shark, Lava Eel…",
        bSementesDesc="Chili, Berry, Flower, Dripleaf, Moonflower…",
        bFerrDesc="Sacks, Axes, Rods, Flutes, Armor…",
        bArmasDesc="Spear, Ice Sword, Crossbow, Revolver, Rifle…",
        bAmmoDesc="Revolver Ammo, Rifle Ammo, Shotgun Ammo",
        bCuraDesc="Bandage, Medkit",
        bPeltsDesc="Bunny Foot, Wolf Pelt, Bear Pelt, Arctic Fox…",
        bChavesDesc="Red, Blue, Yellow, Grey, Frog Key",
        bPocoesDesc="Dripleaf, Moonflower Bulb, Stareweed Petal, Mandrake",
        bBlueprintDesc="Crafting, Defense, Furniture, Obsidiron Chest…",
        -- ESP Labels
        espPlayersLabel="👤 Players",
        espPlayersDesc="All players on the server",
        espKidsLabel="👶 Lost Children",
        espKidsDesc="Dino, Kraken, Squid, Koala Kid",
        espMonstrosLabel="💀 Monsters",
        espMonstrosDesc="The Deer, The Owl, The Ram",
        espCultistasLabel="⚔️ Cultists",
        espCultistasDesc="Cultist, Crossbow, Juggernaut, King, Mega…",
        espAliensLabel="👽 Aliens",
        espAliensDesc="Alien, Elite Alien",
        espLogLabel="🪵 Log",
        espLogDesc="Log — main fuel",
        espCombustivelLabel="🔥 Fuel",
        espCombustivelDesc="Coal, Biofuel, Fuel Canister, Oil Barrel…",
        espCarcacasLabel="🦴 Carcasses",
        espCarcacasDesc="Wolf/Bear/PolarBear/Mammoth/Hellephant Corpse…",
        espSucataLabel="🔩 Scrap",
        espSucataDesc="Bolt, Sheet Metal, UFO Junk, Tyre…",
        espMateriaisLabel="💎 Materials",
        espMateriaisDesc="Cultist Gem, Forest Gem, Mossy Coin, Obsidiron…",
        espComidasLabel="🍖 Food",
        espComidasDesc="Carrot, Corn, Berry, Steak, Ribs, Stew, Candy…",
        espPeixesLabel="🐟 Fish",
        espPeixesDesc="Mackerel, Salmon, Clownfish, Shark, Lava Eel…",
        espSementesLabel="🌱 Seeds",
        espSementesDesc="Chili, Berry, Flower, Firefly, Dripleaf…",
        espFerrLabel="🪓 Tools & Bags",
        espFerrDesc="Axes, Sacks, Rods, Flutes, Armor…",
        espArmasLabel="⚔️ Weapons",
        espArmasDesc="Spear, Crossbow, Ice Sword, Revolver, Rifle…",
        espAmmoLabel="🔫 Ammo",
        espAmmoDesc="Revolver Ammo, Rifle Ammo, Shotgun Ammo",
        espCuraLabel="💊 Healing & Pelts",
        espCuraDesc="Bandage, Medkit, Wolf Pelt, Bear Pelt…",
        espChavesLabel="🗝️ Keys",
        espChavesDesc="Red, Blue, Yellow, Grey, Frog Key",
        espBigornaLabel="⚙️ Anvil Parts",
        espBigornaDesc="Anvil Front/Back/Base + Meteor Anvil",
        espPocoesLabel="🧪 Potions",
        espPocoesDesc="Dripleaf, Moonflower Bulb, Stareweed Petal, Mandrake",
        espBlueprintLabel="📋 Blueprints",
        espBlueprintDesc="Crafting, Defense, Furniture, Obsidiron Chest…",
        kaOnMsg="Active! Equip a weapon and click to hit all in range",
        kaOffMsg="Deactivated.",
        freezeDesc="Forces ALL mobs in radius to stay immobile/frozen on the ground with maximum force.",
        freezeOn="❄️ Freeze Aura",  freezeOnMsg=" studs — mobs frozen with maximum force!",
        freezeOffMsg="Deactivated — mobs unfrozen.",
        freezeRadius="Radius",
        -- Player
        flyTitle="✈️  Fly",            flyDesc="Fly freely around the map. W/A/S/D to move.",
        flyOnMsg="W/A/S/D move • Space up • Ctrl down",
        flyOffMsg="Flight disabled.",
        noclipTitle="👻  Noclip",      noclipDesc="Walk through walls and solid objects.",
        noclipOnMsg="Walking through walls. Anti-void active.",
        noclipOffMsg="Collision restored.",
        tpClickTitle="🖱️  TP Click",  tpClickDesc="Click on the ground to teleport there.",
        tpClickOnMsg="Click on the ground to teleport.",
        tpClickOffMsg="Teleport by click disabled.",
        boosterTitle="⚡  Booster Ultra", boosterDesc="Reduces visuals for maximum performance.",
        boosterOnMsg="Active — Reduced visuals for maximum performance.",
        boosterOffMsg="Disabled — Visuals restored.",
        remFxTitle="🎆  Remove Effects", remFxDesc="Removes particles and lights from the map.",
        remFxOnMsg="Particles and lights disabled.",
        remFxOffMsg="Effects restored.",
        remNpcTitle="🚫  Remove NPCs", remNpcDesc="NPCs become invisible and have no collision.",
        remNpcOnMsg="Invisible and non-collision NPCs.",
        remNpcOffMsg="NPCs restored.",
        clearLagTitle="🧹  Clear Lag", clearLagDesc="Reduces graphics quality to minimum.",
        clearLagOnMsg="Quality reduced to a minimum.",
        clearLagOffMsg="Quality restored.",
        -- Bring
        bringAllTitle="⚡ BRING ALL",
        bringAllDesc="Brings ALL resources from the map at once",
        bringAllBtn="▼  BRING ALL",    bringAllBtnSearching="⏳ Searching...",
        bringSuccess=" items collected successfully! ★",
        bringFail="No items found on the map.",
        bringBtnLabel="▼ BRING",       bringBtnSearching="⏳...",
        bringItemSuccess=" item(s) successfully retrieved! ✓",
        bringItemFail="No items found.",
        bringAllNotifSearching="Locating all items on the map...",
        -- Teleporte
        tpPanelSelect="▼  Select",     tpPanelClose="▲  Close",
        tpPanelBtn="🚀  Teleport",     tpPanelSearching="🔍 Searching...",
        tpPanelArrived="✅  Arrived!", tpPanelError="⚠️ Teleport failed. Try again.",
        tpPanelNotFound=" not found. Explore the map more!",
        tpPanelSuccess="Teleported to ", tpPanelSuccessEnd=" ✓",
        tpPanelFail="Teleport failed. Try again.",
        -- Freeze Aura
        freezeTitle="❄️  Freeze Aura",
        freezeDesc="Forces ALL mobs in radius to stay immobile/frozen on the ground with maximum force.",
        freezeOn="❄️ Freeze Aura",  freezeOnMsg=" studs — mobs frozen with maximum force!",
        freezeOff="❄️ Freeze Aura", freezeOffMsg="Deactivated — mobs unfrozen.",
        freezeRadius="Radius",
        -- ESP Groups
        espGroupEntities="ESP — Entities",     espGroupResources="ESP — Resources & Fuel",
        espGroupFood="ESP — Food & Nature",    espGroupEquipment="ESP — Equipment",
        -- Player sections
        plSecSpeed="⚡ SPEED & JUMP",          plSecFly="✈️ FLY & NOCLIP",
        plSecUtil="🔧 UTILITIES",
        plSecCamera="📷 CAMERA",               plSecAntiDebuff="🛡 PROTECTION",
        plSecGod="👻 INVISIBILITY",
        avFarmSecFreeze="❄️  FREEZE",
        -- Player tab
        plSpeedTitle="⚡ Speed",        plSpeedDesc="Walking speed (default: 16)",
        plJumpTitle="🦘 Jump Power",    plJumpDesc="Jump height (default: 50)",
        plFlyToggle="✈️ Fly",           plFlyDesc="W/A/S/D move • Space = up • Ctrl = down",
        plFlySpeedTitle="💨 Fly Speed", plFlySpeedDesc="Flight speed (default: 40)",
        plNoclipToggle="👻 Noclip",     plNoclipDesc="Walk through walls • Anti-void Y = -100",
        plTpClickToggle="🖱️ TP Click",  plTpClickDesc="Click on the ground to teleport",
        -- Kill Aura
        kaSecTitle="⚔️  KILL AURA",
        kaTitle="⚔️  Kill Aura",
        kaDesc="Equip a melee weapon and click normally — 1 click hits ALL mobs in range.",
        kaRangeLabel="⚔️ Range",
        -- ESP Animals
        espAnimaisLabel="🐾 Animals",
        espAnimaisDesc="Bunny, Horse, Kiwi, Turkey + Wolf, Bear, Polar Bear, Arctic Fox, Frog, Scorpion, Mammoth, Hellephant, Meteor Crab",
        -- Aimbot
        aimbotSecTitle="🎯 CLASSIC AIMBOT (Projectiles)",
        aimbotTitle="🎯 Aimbot (Guided)",
        aimbotDesc="Projectiles move automatically to the nearest animal.",
        aimbotOnMsg="Guided projectiles activated.",
        aimbotOffMsg="Deactivated.",
        aimbotAutoTitle="🤖 Auto Aimbot",
        aimbotAutoDesc="With ranged weapon equipped: aims and shoots nearby animals automatically.",
        aimbotAutoOnMsg="Auto mode activated — fires automatically!",
        aimbotAutoOffMsg="Auto mode deactivated.",
        -- ESP
        espOn="ESP Active",            espOff="ESP Inactive",
        -- Copied
        copied="✓ Copied!",
    },
    ["ES-ES"] = {
        tabStatus="Estado",             tabAvFarm="Farm Avanzado",  tabPlayer="Jugador",
        tabConfig="Configuración",      tabAvFunc="Funciones Avanzadas",
        groupGeral="GENERAL",           groupCombate="COMBATE",
        langCurrent="Idioma",           popupTitle="¿Cambiar idioma?", popupYes="Sí",
        notifLangChanged="Idioma cambiado a ",
        infoStatus="🎮  Jugando 99 Nights in the Forest",
        notifTitle="Notificaciones",    notifDesc="Activa/desactiva las notificaciones del hub",
        notifOn="ON",                   notifOff="OFF",
        notifHistTitle="Historial de Notificaciones",
        notifHistClear="🗑 Limpiar",    notifHistEmpty="📭  Sin notificaciones aún.",
        notifWelcome="¡Cargado!",       notifWelcomeMsg="¡Bienvenido, ",
        notifTip="Consejo",             notifTipMsg="Pasa el ratón sobre la notificación para pausar 🔔",
        stFpsExc="Excelente",           stFpsBom="Bueno",           stFpsBaixo="Bajo",
        stPingBoa="Buena conexión",     stPingMod="Moderado",       stPingRuim="Conexión mala",
        stPlayersYou="tú",              stRegion="Región: ",
        srvTitle="Servidor por ID",     srvSub="Pega el Job ID para intentar unirte",
        srvBtn="→ Ir",                  srvConnecting="🔄 Conectando...",
        srvNotifError="No se pudo conectar. Verifica el ID.",
        freezeTitle="❄️  Aura de Hielo",freezeDesc="Congela todos los mobs en el radio.",
        flyTitle="✈️  Volar",           flyDesc="Vuela libremente por el mapa.",
        noclipTitle="👻  Noclip",       noclipDesc="Atraviesa paredes y objetos sólidos.",
        bringAllTitle="⚡ TRAER TODO",  bringAllBtn="▼  TRAER TODO",
        bringSuccess=" objetos recogidos con éxito! ★",
        bringFail="No se encontraron objetos en el mapa.",
        tpPanelSelect="▼  Seleccionar", tpPanelBtn="🚀  Teleportar",
        copied="✓ ¡Copiado!",
        bringGrpFuel="BRING — Combustible & Recursos",
        bringGrpFood="BRING — Comida & Naturaleza",
        bringGrpEquip="BRING — Equipamiento",
        bringGrpSpecials="BRING — Especiales",
        bLogLabel="🪵 Traer Tronco",      bCombustLabel="🔥 Traer Combustible",
        bCarcacasLabel="🦴 Traer Carcasas", bSucataLabel="🔩 Traer Chatarra",
        bMateriaisLabel="💎 Traer Materiales", bComidasLabel="🍖 Traer Comida",
        bPeixesLabel="🐟 Traer Peces",    bSementesLabel="🌱 Traer Semillas",
        bFerrLabel="🪓 Traer Herramientas", bArmasLabel="⚔️ Traer Armas",
        bAmmoLabel="🔫 Traer Munición",   bCuraLabel="💊 Traer Curación",
        bPeltsLabel="🦺 Traer Pieles",    bChavesLabel="🗝️ Traer Llaves",
        bPocoesLabel="🧪 Traer Pociones", bBlueprintLabel="📋 Traer Planos",
        bLogDesc="Solo: Tronco",          bCombustDesc="Carbón, Biocombustible, Bidón, Barril…",
        bCarcacasDesc="Lobo, Oso, Oso Polar, Helefante, Rana, Alien…",
        bSucataDesc="Tornillo, Chapa, Basura OVNI, Neumático…",
        bMateriaisDesc="Gema Cultista, Gema Forestal, Moneda Musgo…",
        bComidasDesc="Zanahoria, Maíz, Bistec, Costillas, Estofado…",
        bPeixesDesc="Caballa, Salmón, Pez Payaso, Tiburón, Anguila Lava…",
        bSementesDesc="Chile, Baya, Flor, Dripleaf, Moonflower…",
        bFerrDesc="Sacos, Hachas, Cañas, Flautas, Armaduras…",
        bArmasDesc="Lanza, Espada de Hielo, Ballesta, Revólver, Rifle…",
        bAmmoDesc="Munición Revólver, Munición Rifle, Munición Escopeta",
        bCuraDesc="Vendaje, Botiquín",
        bPeltsDesc="Pata de Conejo, Piel de Lobo, Piel de Oso…",
        bChavesDesc="Llave Roja, Azul, Amarilla, Gris, Rana",
        bPocoesDesc="Dripleaf, Bulbo Moonflower, Pétalo Stareweed, Mandrágora",
        bBlueprintDesc="Plano Artesanía, Defensa, Muebles, Baúl Obsidiron…",
        espPlayersLabel="👤 Jugadores",   espPlayersDesc="Todos los jugadores en el servidor",
        espKidsLabel="👶 Niños Perdidos", espKidsDesc="Dino, Kraken, Squid, Koala Kid",
        espMonstrosLabel="💀 Monstruos",  espMonstrosDesc="The Deer, The Owl, The Ram",
        espCultistasLabel="⚔️ Cultistas", espCultistasDesc="Cultista, Ballesta, Juggernaut, Rey, Mega…",
        espAliensLabel="👽 Aliens",       espAliensDesc="Alien, Elite Alien",
        espLogLabel="🪵 Tronco",          espLogDesc="Tronco — combustible principal",
        espCombustivelLabel="🔥 Combustible", espCombustivelDesc="Carbón, Biocombustible, Bidón…",
        espCarcacasLabel="🦴 Carcasas",   espCarcacasDesc="Cuerpos de Lobo/Oso/Oso Polar/Mamut…",
        espSucataLabel="🔩 Chatarra",     espSucataDesc="Tornillo, Chapa, Basura OVNI, Neumático…",
        espMateriaisLabel="💎 Materiales", espMateriaisDesc="Gema Cultista, Gema Forestal, Moneda Musgo…",
        espComidasLabel="🍖 Comida",      espComidasDesc="Zanahoria, Maíz, Baya, Bistec, Costillas…",
        espPeixesLabel="🐟 Peces",        espPeixesDesc="Caballa, Salmón, Pez Payaso, Tiburón…",
        espSementesLabel="🌱 Semillas",   espSementesDesc="Chile, Baya, Flor, Luciérnaga, Dripleaf…",
        espFerrLabel="🪓 Herramientas",   espFerrDesc="Hachas, Sacos, Cañas, Flautas, Armadura…",
        espArmasLabel="⚔️ Armas",         espArmasDesc="Lanza, Ballesta, Espada de Hielo, Revólver…",
        espAmmoLabel="🔫 Munición",       espAmmoDesc="Munición Revólver, Munición Rifle, Escopeta",
        espCuraLabel="💊 Curación & Pieles", espCuraDesc="Vendaje, Botiquín, Piel de Lobo…",
        espChavesLabel="🗝️ Llaves",       espChavesDesc="Llave Roja, Azul, Amarilla, Gris, Rana",
        espBigornaLabel="⚙️ Piezas Yunque", espBigornaDesc="Frente/Espalda/Base del Yunque + Meteoro",
        espPocoesLabel="🧪 Pociones",     espPocoesDesc="Dripleaf, Bulbo Moonflower, Pétalo Stareweed",
        espBlueprintLabel="📋 Planos",    espBlueprintDesc="Plano Artesanía, Defensa, Muebles…",
        kaSecTitle="⚔️  KILL AURA",       kaTitle="⚔️  Kill Aura",
        kaDesc="Equipa un arma cuerpo a cuerpo y haz clic — ¡1 clic golpea TODOS los mobs!",
        kaOnMsg="¡Activo! Equipa un arma y haz clic para golpear a todos",
        kaOffMsg="Desactivado.",          espAnimaisLabel="🐾 Animales",
        espAnimaisDesc="Conejo, Caballo, Kiwi, Pavo + Lobo, Oso, Oso Polar, Raposa Ártica, Rana, Escorpión, Mamut, Helefante, Cangrejo Meteoro",
    },
    ["ZH-CN"] = {
        tabInfo="信息",                 tabStatus="状态",           tabFarm="农场",
        tabBring="传送",                tabAvFarm="高级农场",       tabPlayer="玩家",
        tabConfig="设置",               tabAvFunc="高级功能",
        groupGeral="常规",              groupCombate="战斗",        groupExtra="额外",
        langSystem="语言系统",          langCurrent="语言",
        popupTitle="更改语言？",        popupYes="是",              popupNo="否",
        notifLangChanged="语言已更改为 ",
        infoStatus="🎮  正在游玩 99 Nights in the Forest",
        notifTitle="通知",              notifDesc="启用/禁用所有Hub通知",
        notifOn="开启",                 notifOff="关闭",
        notifHistTitle="通知历史",      notifHistClear="🗑 清除",
        notifHistEmpty="📭  暂无通知。",
        notifWelcome="已加载！",        notifWelcomeMsg="欢迎，",
        notifTip="提示",                notifTipMsg="将鼠标悬停在通知上可暂停计时器 🔔",
        stFpsExc="优秀",                stFpsBom="良好",            stFpsBaixo="差",
        stPingBoa="连接良好",           stPingMod="一般",           stPingRuim="连接差",
        stPlayersYou="你",              stRegion="地区：",
        srvTitle="按ID加入服务器",      srvBtn="→ 加入",
        flyTitle="✈️  飞行",            noclipTitle="👻  穿墙",
        bringAllTitle="⚡ 全部带来",    bringAllBtn="▼  全部带来",
        bringSuccess=" 个物品收集成功！★",bringFail="地图上未找到物品。",
        tpPanelSelect="▼  选择",        tpPanelBtn="🚀  传送",
        copied="✓ 已复制！",
        bringGrpFuel="BRING — 燃料与资源",   bringGrpFood="BRING — 食物与自然",
        bringGrpEquip="BRING — 装备",        bringGrpSpecials="BRING — 特殊",
        bLogLabel="🪵 获取木头",         bCombustLabel="🔥 获取燃料",
        bCarcacasLabel="🦴 获取尸体",    bSucataLabel="🔩 获取废料",
        bMateriaisLabel="💎 获取材料",   bComidasLabel="🍖 获取食物",
        bPeixesLabel="🐟 获取鱼类",      bSementesLabel="🌱 获取种子",
        bFerrLabel="🪓 获取工具",        bArmasLabel="⚔️ 获取武器",
        bAmmoLabel="🔫 获取弹药",        bCuraLabel="💊 获取治疗",
        bPeltsLabel="🦺 获取皮毛",       bChavesLabel="🗝️ 获取钥匙",
        bPocoesLabel="🧪 获取药水",      bBlueprintLabel="📋 获取蓝图",
        bLogDesc="仅限：木头",
        bCombustDesc="煤炭, 生物燃料, 燃料桶, 油桶…",
        bCarcacasDesc="狼, 熊, 北极熊, 地狱象, 青蛙, 外星人尸体…",
        bSucataDesc="螺栓, 钢板, UFO垃圾, 轮胎…",
        bMateriaisDesc="邪教宝石, 森林宝石, 苔藓硬币…",
        bComidasDesc="胡萝卜, 玉米, 牛排, 排骨, 炖菜, 糖果…",
        bPeixesDesc="鲭鱼, 三文鱼, 小丑鱼, 鲨鱼, 熔岩鳗…",
        bSementesDesc="辣椒, 浆果, 花, Dripleaf, Moonflower…",
        bFerrDesc="袋子, 斧头, 钓竿, 长笛, 盔甲…",
        bArmasDesc="矛, 冰剑, 弩, 左轮, 步枪…",
        bAmmoDesc="左轮弹药, 步枪弹药, 霰弹枪弹药",
        bCuraDesc="绷带, 医疗包",
        bPeltsDesc="兔子脚, 狼皮, 熊皮, 北极狐…",
        bChavesDesc="红色, 蓝色, 黄色, 灰色, 青蛙钥匙",
        bPocoesDesc="Dripleaf, Moonflower球茎, Stareweed花瓣, 曼德拉草",
        bBlueprintDesc="制作, 防御, 家具, 黑曜铁箱蓝图…",
        espPlayersLabel="👤 玩家",        espPlayersDesc="服务器上的所有玩家",
        espKidsLabel="👶 失踪儿童",       espKidsDesc="恐龙, 海怪, 鱿鱼, 考拉孩子",
        espMonstrosLabel="💀 怪物",       espMonstrosDesc="The Deer, The Owl, The Ram",
        espCultistasLabel="⚔️ 邪教徒",    espCultistasDesc="邪教徒, 弩手, 重装, 国王, 大型…",
        espAliensLabel="👽 外星人",       espAliensDesc="外星人, 精英外星人",
        espLogLabel="🪵 木头",            espLogDesc="木头 — 主要燃料",
        espCombustivelLabel="🔥 燃料",    espCombustivelDesc="煤炭, 生物燃料, 燃料桶…",
        espCarcacasLabel="🦴 尸体",       espCarcacasDesc="狼/熊/北极熊/猛犸象/地狱象尸体…",
        espSucataLabel="🔩 废料",         espSucataDesc="螺栓, 钢板, UFO垃圾, 轮胎…",
        espMateriaisLabel="💎 材料",      espMateriaisDesc="邪教宝石, 森林宝石, 苔藓硬币…",
        espComidasLabel="🍖 食物",        espComidasDesc="胡萝卜, 玉米, 浆果, 牛排…",
        espPeixesLabel="🐟 鱼类",         espPeixesDesc="鲭鱼, 三文鱼, 小丑鱼, 鲨鱼…",
        espSementesLabel="🌱 种子",       espSementesDesc="辣椒, 浆果, 花, 萤火虫, Dripleaf…",
        espFerrLabel="🪓 工具与袋子",     espFerrDesc="斧头, 袋子, 钓竿, 长笛, 盔甲…",
        espArmasLabel="⚔️ 武器",          espArmasDesc="矛, 弩, 冰剑, 左轮, 步枪…",
        espAmmoLabel="🔫 弹药",           espAmmoDesc="左轮, 步枪, 霰弹枪弹药",
        espCuraLabel="💊 治疗与皮毛",     espCuraDesc="绷带, 医疗包, 狼皮, 熊皮…",
        espChavesLabel="🗝️ 钥匙",         espChavesDesc="红色, 蓝色, 黄色, 灰色, 青蛙钥匙",
        espBigornaLabel="⚙️ 砧座零件",    espBigornaDesc="砧座前/后/底座 + 陨石砧座",
        espPocoesLabel="🧪 药水",         espPocoesDesc="Dripleaf, Moonflower球茎, Stareweed花瓣",
        espBlueprintLabel="📋 蓝图",      espBlueprintDesc="制作, 防御, 家具, 黑曜铁箱蓝图…",
        kaSecTitle="⚔️  杀戮光环",        kaTitle="⚔️  杀戮光环",
        kaDesc="装备近战武器并正常点击 — 1次点击击中范围内所有怪物。",
        kaOnMsg="激活！装备武器并点击以击中所有目标",
        kaOffMsg="已停用。",              espAnimaisLabel="🐾 动物",
        espAnimaisDesc="兔子, 马, 奇异鸟, 火鸡 + 狼, 熊, 北极熊, 北极狐, 青蛙, 蝎子, 猛犸象, 地狱象, 陨石螃蟹",
    },
    ["HI-IN"] = {
        tabInfo="जानकारी",              tabStatus="स्थिति",         tabFarm="फार्म",
        tabBring="लाएं",                tabAvFarm="उन्नत फार्म",   tabPlayer="खिलाड़ी",
        tabConfig="सेटिंग्स",           tabAvFunc="उन्नत कार्य",
        groupGeral="सामान्य",           groupCombate="युद्ध",       groupExtra="अतिरिक्त",
        langSystem="भाषा प्रणाली",      langCurrent="भाषा",
        popupTitle="भाषा बदलें?",       popupYes="हाँ",             popupNo="नहीं",
        notifLangChanged="भाषा बदली गई ",
        infoStatus="🎮  खेल रहे हैं 99 Nights in the Forest",
        notifTitle="सूचनाएं",           notifDesc="सभी हब सूचनाओं को चालू/बंद करें",
        notifOn="चालू",                 notifOff="बंद",
        notifWelcome="लोड हो गया!",     notifWelcomeMsg="स्वागत है, ",
        notifTip="सुझाव",               notifTipMsg="टाइमर रोकने के लिए नोटिफिकेशन पर होवर करें 🔔",
        copied="✓ कॉपी हो गया!",
        bringGrpFuel="BRING — ईंधन और संसाधन", bringGrpFood="BRING — खाना और प्रकृति",
        bringGrpEquip="BRING — उपकरण",          bringGrpSpecials="BRING — विशेष",
        bLogLabel="🪵 लाएं लकड़ी",       bCombustLabel="🔥 लाएं ईंधन",
        bCarcacasLabel="🦴 लाएं शव",     bSucataLabel="🔩 लाएं स्क्रैप",
        bMateriaisLabel="💎 लाएं सामग्री", bComidasLabel="🍖 लाएं खाना",
        bPeixesLabel="🐟 लाएं मछली",     bSementesLabel="🌱 लाएं बीज",
        bFerrLabel="🪓 लाएं उपकरण",      bArmasLabel="⚔️ लाएं हथियार",
        bAmmoLabel="🔫 लाएं गोला-बारूद", bCuraLabel="💊 लाएं उपचार",
        bPeltsLabel="🦺 लाएं खाल",       bChavesLabel="🗝️ लाएं चाबियां",
        bPocoesLabel="🧪 लाएं औषधि",     bBlueprintLabel="📋 लाएं ब्लूप्रिंट",
        bLogDesc="केवल: लकड़ी",
        bCombustDesc="कोयला, जैव ईंधन, ईंधन डिब्बा, तेल बैरल…",
        bCarcacasDesc="भेड़िया, भालू, ध्रुवीय भालू, हेलीफेंट, मेंढक, एलियन शव…",
        bSucataDesc="बोल्ट, शीट मेटल, UFO कचरा, टायर…",
        bMateriaisDesc="कल्टिस्ट रत्न, वन रत्न, काई सिक्का…",
        bComidasDesc="गाजर, मकई, स्टेक, पसलियां, स्टू, कैंडी…",
        bPeixesDesc="मैकेरल, सामन, क्लाउनफिश, शार्क, लावा ईल…",
        bSementesDesc="मिर्च, बेरी, फूल, Dripleaf, Moonflower…",
        bFerrDesc="बोरे, कुल्हाड़ी, छड़, बांसुरी, कवच…",
        bArmasDesc="भाला, बर्फ तलवार, क्रॉसबो, रिवॉल्वर, राइफल…",
        bAmmoDesc="रिवॉल्वर, राइफल, शॉटगन गोला-बारूद",
        bCuraDesc="पट्टी, मेडकिट",
        bPeltsDesc="खरगोश पैर, भेड़िया खाल, भालू खाल, आर्कटिक लोमड़ी…",
        bChavesDesc="लाल, नीली, पीली, ग्रे, मेंढक चाबी",
        bPocoesDesc="Dripleaf, Moonflower बल्ब, Stareweed पंखुड़ी, मैनड्रेक",
        bBlueprintDesc="शिल्प, रक्षा, फर्नीचर, ओब्सीडियन छाती ब्लूप्रिंट…",
        espPlayersLabel="👤 खिलाड़ी",     espPlayersDesc="सर्वर पर सभी खिलाड़ी",
        espKidsLabel="👶 लापता बच्चे",   espKidsDesc="Dino, Kraken, Squid, Koala Kid",
        espMonstrosLabel="💀 राक्षस",     espMonstrosDesc="The Deer, The Owl, The Ram",
        espCultistasLabel="⚔️ कल्टिस्ट",  espCultistasDesc="कल्टिस्ट, क्रॉसबो, जगरनॉट, राजा…",
        espAliensLabel="👽 एलियन",        espAliensDesc="एलियन, एलीट एलियन",
        espLogLabel="🪵 लकड़ी",           espLogDesc="लकड़ी — मुख्य ईंधन",
        espCombustivelLabel="🔥 ईंधन",   espCombustivelDesc="कोयला, जैव ईंधन, ईंधन डिब्बा…",
        espCarcacasLabel="🦴 शव",         espCarcacasDesc="भेड़िया/भालू/ध्रुवीय भालू शव…",
        espSucataLabel="🔩 स्क्रैप",      espSucataDesc="बोल्ट, शीट मेटल, UFO कचरा…",
        espMateriaisLabel="💎 सामग्री",   espMateriaisDesc="कल्टिस्ट रत्न, वन रत्न…",
        espComidasLabel="🍖 खाना",        espComidasDesc="गाजर, मकई, बेरी, स्टेक…",
        espPeixesLabel="🐟 मछली",         espPeixesDesc="मैकेरल, सामन, क्लाउनफिश, शार्क…",
        espSementesLabel="🌱 बीज",        espSementesDesc="मिर्च, बेरी, फूल, जुगनू, Dripleaf…",
        espFerrLabel="🪓 उपकरण और बोरे", espFerrDesc="कुल्हाड़ी, बोरे, छड़, बांसुरी, कवच…",
        espArmasLabel="⚔️ हथियार",        espArmasDesc="भाला, क्रॉसबो, बर्फ तलवार, रिवॉल्वर…",
        espAmmoLabel="🔫 गोला-बारूद",    espAmmoDesc="रिवॉल्वर, राइफल, शॉटगन गोला-बारूद",
        espCuraLabel="💊 उपचार और खाल",  espCuraDesc="पट्टी, मेडकिट, भेड़िया खाल, भालू खाल…",
        espChavesLabel="🗝️ चाबियां",      espChavesDesc="लाल, नीली, पीली, ग्रे, मेंढक चाबी",
        espBigornaLabel="⚙️ निहाई के पुर्जे", espBigornaDesc="निहाई अगला/पिछला/आधार + उल्का",
        espPocoesLabel="🧪 औषधि",         espPocoesDesc="Dripleaf, Moonflower बल्ब, Stareweed पंखुड़ी",
        espBlueprintLabel="📋 ब्लूप्रिंट", espBlueprintDesc="शिल्प, रक्षा, फर्नीचर ब्लूप्रिंट…",
        kaSecTitle="⚔️  किल ऑरा",         kaTitle="⚔️  किल ऑरा",
        kaDesc="हाथापाई हथियार लैस करें और सामान्य रूप से क्लिक करें — 1 क्लिक रेंज में सभी को हिट करता है।",
        kaOnMsg="सक्रिय! हथियार लैस करें और सभी को हिट करने के लिए क्लिक करें",
        kaOffMsg="निष्क्रिय।",            espAnimaisLabel="🐾 जानवर",
        espAnimaisDesc="खरगोश, घोड़ा, कीवी, टर्की + भेड़िया, भालू, ध्रुवीय भालू, आर्कटिक लोमड़ी, मेंढक, बिच्छू, मैमथ, हेलीफेंट",
    },
    ["AR-SA"] = {
        tabInfo="معلومات",              tabStatus="الحالة",         tabFarm="مزرعة",
        tabBring="جلب",                 tabAvFarm="مزرعة متقدمة",  tabPlayer="لاعب",
        tabConfig="إعدادات",            tabAvFunc="وظائف متقدمة",
        groupGeral="عام",               groupCombate="قتال",        groupExtra="إضافي",
        langSystem="نظام اللغات",       langCurrent="اللغة",
        popupTitle="تغيير اللغة؟",      popupYes="نعم",             popupNo="لا",
        notifLangChanged="تم تغيير اللغة إلى ",
        infoStatus="🎮  تلعب 99 Nights in the Forest",
        notifTitle="الإشعارات",         notifDesc="تفعيل/تعطيل جميع إشعارات الهاب",
        notifOn="مفعّل",                notifOff="معطّل",
        notifWelcome="تم التحميل!",     notifWelcomeMsg="مرحباً، ",
        notifTip="نصيحة",               notifTipMsg="مرر الماوس على الإشعار لإيقاف المؤقت 🔔",
        copied="✓ تم النسخ!",
        bringGrpFuel="BRING — الوقود والموارد",  bringGrpFood="BRING — الطعام والطبيعة",
        bringGrpEquip="BRING — المعدات",           bringGrpSpecials="BRING — خاص",
        bLogLabel="🪵 جلب خشب",          bCombustLabel="🔥 جلب وقود",
        bCarcacasLabel="🦴 جلب جثث",     bSucataLabel="🔩 جلب خردة",
        bMateriaisLabel="💎 جلب مواد",   bComidasLabel="🍖 جلب طعام",
        bPeixesLabel="🐟 جلب أسماك",     bSementesLabel="🌱 جلب بذور",
        bFerrLabel="🪓 جلب أدوات",       bArmasLabel="⚔️ جلب أسلحة",
        bAmmoLabel="🔫 جلب ذخيرة",       bCuraLabel="💊 جلب علاج",
        bPeltsLabel="🦺 جلب جلود",       bChavesLabel="🗝️ جلب مفاتيح",
        bPocoesLabel="🧪 جلب جرعات",     bBlueprintLabel="📋 جلب مخططات",
        bLogDesc="فقط: خشب",
        bCombustDesc="فحم، وقود حيوي، خزان وقود، برميل نفط…",
        bCarcacasDesc="ذئب، دب، دب قطبي، هيليفانت، ضفدع، جثة كيان فضائي…",
        bSucataDesc="مسمار، صفيحة معدنية، نفايات UFO، إطار…",
        bMateriaisDesc="جوهرة الطائفة، جوهرة الغابة، عملة طحلبية…",
        bComidasDesc="جزر، ذرة، ستيك، ضلوع، حساء، حلوى…",
        bPeixesDesc="إسقمري، سلمون، سمكة مهرج، قرش، ثعبان الحمم…",
        bSementesDesc="فلفل، توت، زهرة، Dripleaf، Moonflower…",
        bFerrDesc="أكياس، فؤوس، قضبان، مزامير، دروع…",
        bArmasDesc="رمح، سيف ثلجي، قوس عبور، مسدس، بندقية…",
        bAmmoDesc="ذخيرة مسدس، ذخيرة بندقية، ذخيرة فردية",
        bCuraDesc="ضمادة، حقيبة إسعاف",
        bPeltsDesc="قدم أرنب، جلد ذئب، جلد دب، ثعلب القطب…",
        bChavesDesc="مفتاح أحمر، أزرق، أصفر، رمادي، ضفدع",
        bPocoesDesc="Dripleaf، بصلة Moonflower، بتلة Stareweed، الراعي",
        bBlueprintDesc="مخطط الصنع، الدفاع، الأثاث، صندوق أوبسيديرون…",
        espPlayersLabel="👤 لاعبون",      espPlayersDesc="جميع اللاعبين في الخادم",
        espKidsLabel="👶 أطفال مفقودون", espKidsDesc="Dino, Kraken, Squid, Koala Kid",
        espMonstrosLabel="💀 وحوش",       espMonstrosDesc="الغزال، البومة، الكبش",
        espCultistasLabel="⚔️ طائفيون",   espCultistasDesc="طائفي، قوس عبور، جاغرنوت، ملك…",
        espAliensLabel="👽 كيانات فضائية", espAliensDesc="كيان فضائي، نخبة فضائية",
        espLogLabel="🪵 خشب",             espLogDesc="خشب — وقود رئيسي",
        espCombustivelLabel="🔥 وقود",    espCombustivelDesc="فحم، وقود حيوي، خزان وقود…",
        espCarcacasLabel="🦴 جثث",        espCarcacasDesc="جثة ذئب/دب/دب قطبي/ماموث…",
        espSucataLabel="🔩 خردة",         espSucataDesc="مسمار، صفيحة معدنية، نفايات UFO…",
        espMateriaisLabel="💎 مواد",       espMateriaisDesc="جوهرة الطائفة، جوهرة الغابة…",
        espComidasLabel="🍖 طعام",         espComidasDesc="جزر، ذرة، توت، ستيك…",
        espPeixesLabel="🐟 أسماك",         espPeixesDesc="إسقمري، سلمون، سمكة مهرج، قرش…",
        espSementesLabel="🌱 بذور",        espSementesDesc="فلفل، توت، زهرة، يراعة، Dripleaf…",
        espFerrLabel="🪓 أدوات وأكياس",   espFerrDesc="فؤوس، أكياس، قضبان، مزامير، دروع…",
        espArmasLabel="⚔️ أسلحة",          espArmasDesc="رمح، قوس عبور، سيف ثلجي، مسدس…",
        espAmmoLabel="🔫 ذخيرة",           espAmmoDesc="ذخيرة مسدس، بندقية، فردية",
        espCuraLabel="💊 علاج وجلود",      espCuraDesc="ضمادة، حقيبة إسعاف، جلد ذئب…",
        espChavesLabel="🗝️ مفاتيح",        espChavesDesc="مفتاح أحمر، أزرق، أصفر، رمادي، ضفدع",
        espBigornaLabel="⚙️ أجزاء السندان", espBigornaDesc="أمامي/خلفي/قاعدة السندان + نيزك",
        espPocoesLabel="🧪 جرعات",         espPocoesDesc="Dripleaf، بصلة Moonflower، بتلة Stareweed",
        espBlueprintLabel="📋 مخططات",     espBlueprintDesc="مخطط الصنع، الدفاع، الأثاث…",
        kaSecTitle="⚔️  طاقة القتل",       kaTitle="⚔️  طاقة القتل",
        kaDesc="جهز سلاحاً قريباً وانقر بشكل طبيعي — نقرة واحدة تضرب جميع الأعداء في النطاق.",
        kaOnMsg="نشط! جهز سلاحاً وانقر لضرب الجميع",
        kaOffMsg="غير مفعّل.",             espAnimaisLabel="🐾 حيوانات",
        espAnimaisDesc="أرنب، حصان، كيوي، ديك رومي + ذئب، دب، دب قطبي، ثعلب قطبي، ضفدع، عقرب، ماموث، هيليفانت",
    },
    ["BN-BD"] = {
        tabInfo="তথ্য",                 tabStatus="অবস্থা",         tabFarm="ফার্ম",
        tabBring="আনুন",                tabAvFarm="উন্নত ফার্ম",   tabPlayer="খেলোয়াড়",
        tabConfig="সেটিংস",             tabAvFunc="উন্নত ফাংশন",
        groupGeral="সাধারণ",            groupCombate="যুদ্ধ",       groupExtra="অতিরিক্ত",
        langSystem="ভাষা সিস্টেম",      langCurrent="ভাষা",
        popupTitle="ভাষা পরিবর্তন?",    popupYes="হ্যাঁ",           popupNo="না",
        notifLangChanged="ভাষা পরিবর্তিত হয়েছে ",
        infoStatus="🎮  খেলছেন 99 Nights in the Forest",
        notifTitle="বিজ্ঞপ্তি",         notifDesc="সমস্ত হাব বিজ্ঞপ্তি চালু/বন্ধ করুন",
        notifOn="চালু",                 notifOff="বন্ধ",
        notifWelcome="লোড হয়েছে!",      notifWelcomeMsg="স্বাগতম, ",
        notifTip="পরামর্শ",             notifTipMsg="টাইমার থামাতে বিজ্ঞপ্তির উপর হোভার করুন 🔔",
        copied="✓ কপি হয়েছে!",
        bringGrpFuel="BRING — জ্বালানি ও সম্পদ",  bringGrpFood="BRING — খাবার ও প্রকৃতি",
        bringGrpEquip="BRING — সরঞ্জাম",             bringGrpSpecials="BRING — বিশেষ",
        bLogLabel="🪵 আনুন কাঠ",         bCombustLabel="🔥 আনুন জ্বালানি",
        bCarcacasLabel="🦴 আনুন মৃতদেহ", bSucataLabel="🔩 আনুন স্ক্র্যাপ",
        bMateriaisLabel="💎 আনুন উপকরণ", bComidasLabel="🍖 আনুন খাবার",
        bPeixesLabel="🐟 আনুন মাছ",      bSementesLabel="🌱 আনুন বীজ",
        bFerrLabel="🪓 আনুন সরঞ্জাম",    bArmasLabel="⚔️ আনুন অস্ত্র",
        bAmmoLabel="🔫 আনুন গোলাবারুদ",  bCuraLabel="💊 আনুন নিরাময়",
        bPeltsLabel="🦺 আনুন চামড়া",     bChavesLabel="🗝️ আনুন চাবি",
        bPocoesLabel="🧪 আনুন পানীয়",    bBlueprintLabel="📋 আনুন ব্লুপ্রিন্ট",
        bLogDesc="শুধুমাত্র: কাঠ",
        bCombustDesc="কয়লা, জৈব জ্বালানি, জ্বালানি ক্যানিস্টার, তেলের ব্যারেল…",
        bCarcacasDesc="নেকড়ে, ভালুক, মেরু ভালুক, হেলিফ্যান্ট, ব্যাঙ, এলিয়েন মৃতদেহ…",
        bSucataDesc="বোল্ট, শীট মেটাল, UFO জঙ্ক, টায়ার…",
        bMateriaisDesc="কাল্টিস্ট রত্ন, বন রত্ন, শ্যাওলা মুদ্রা…",
        bComidasDesc="গাজর, ভুট্টা, স্টেক, পাঁজর, স্টু, ক্যান্ডি…",
        bPeixesDesc="ম্যাকেরেল, স্যামন, ক্লাউনফিশ, হাঙর, লাভা ঈল…",
        bSementesDesc="মরিচ, বেরি, ফুল, Dripleaf, Moonflower…",
        bFerrDesc="বস্তা, কুড়াল, ছড়ি, বাঁশি, বর্ম…",
        bArmasDesc="বর্শা, বরফ তরোয়াল, ক্রসবো, রিভলভার, রাইফেল…",
        bAmmoDesc="রিভলভার, রাইফেল, শটগান গোলাবারুদ",
        bCuraDesc="ব্যান্ডেজ, মেডকিট",
        bPeltsDesc="খরগোশের পা, নেকড়ে চামড়া, ভালুক চামড়া, আর্কটিক ফক্স…",
        bChavesDesc="লাল, নীল, হলুদ, ধূসর, ব্যাঙ চাবি",
        bPocoesDesc="Dripleaf, Moonflower বাল্ব, Stareweed পাপড়ি, ম্যানড্রেক",
        bBlueprintDesc="কারুকাজ, প্রতিরক্ষা, আসবাবপত্র, অবসিডিয়রন বুক ব্লুপ্রিন্ট…",
        espPlayersLabel="👤 খেলোয়াড়",   espPlayersDesc="সার্ভারের সমস্ত খেলোয়াড়",
        espKidsLabel="👶 হারিয়ে যাওয়া শিশু", espKidsDesc="Dino, Kraken, Squid, Koala Kid",
        espMonstrosLabel="💀 দানব",       espMonstrosDesc="The Deer, The Owl, The Ram",
        espCultistasLabel="⚔️ কাল্টিস্ট",  espCultistasDesc="কাল্টিস্ট, ক্রসবো, জাগারনট, রাজা…",
        espAliensLabel="👽 এলিয়েন",      espAliensDesc="এলিয়েন, এলিট এলিয়েন",
        espLogLabel="🪵 কাঠ",             espLogDesc="কাঠ — প্রধান জ্বালানি",
        espCombustivelLabel="🔥 জ্বালানি", espCombustivelDesc="কয়লা, জৈব জ্বালানি, ক্যানিস্টার…",
        espCarcacasLabel="🦴 মৃতদেহ",     espCarcacasDesc="নেকড়ে/ভালুক/মেরু ভালুক মৃতদেহ…",
        espSucataLabel="🔩 স্ক্র্যাপ",    espSucataDesc="বোল্ট, শীট মেটাল, UFO জঙ্ক…",
        espMateriaisLabel="💎 উপকরণ",     espMateriaisDesc="কাল্টিস্ট রত্ন, বন রত্ন…",
        espComidasLabel="🍖 খাবার",        espComidasDesc="গাজর, ভুট্টা, বেরি, স্টেক…",
        espPeixesLabel="🐟 মাছ",           espPeixesDesc="ম্যাকেরেল, স্যামন, ক্লাউনফিশ, হাঙর…",
        espSementesLabel="🌱 বীজ",         espSementesDesc="মরিচ, বেরি, ফুল, জোনাকি, Dripleaf…",
        espFerrLabel="🪓 সরঞ্জাম ও বস্তা", espFerrDesc="কুড়াল, বস্তা, ছড়ি, বাঁশি, বর্ম…",
        espArmasLabel="⚔️ অস্ত্র",         espArmasDesc="বর্শা, ক্রসবো, বরফ তরোয়াল, রিভলভার…",
        espAmmoLabel="🔫 গোলাবারুদ",       espAmmoDesc="রিভলভার, রাইফেল, শটগান গোলাবারুদ",
        espCuraLabel="💊 নিরাময় ও চামড়া", espCuraDesc="ব্যান্ডেজ, মেডকিট, নেকড়ে চামড়া…",
        espChavesLabel="🗝️ চাবি",          espChavesDesc="লাল, নীল, হলুদ, ধূসর, ব্যাঙ চাবি",
        espBigornaLabel="⚙️ অ্যানভিল পার্টস", espBigornaDesc="সামনে/পেছনে/ভিত্তি + উল্কাপিণ্ড",
        espPocoesLabel="🧪 পানীয়",         espPocoesDesc="Dripleaf, Moonflower বাল্ব, Stareweed পাপড়ি",
        espBlueprintLabel="📋 ব্লুপ্রিন্ট",  espBlueprintDesc="কারুকাজ, প্রতিরক্ষা, আসবাবপত্র ব্লুপ্রিন্ট…",
        kaSecTitle="⚔️  কিল অরা",          kaTitle="⚔️  কিল অরা",
        kaDesc="একটি হাতাহাতি অস্ত্র সজ্জিত করুন এবং স্বাভাবিকভাবে ক্লিক করুন — ১ ক্লিকে পরিসীমার সমস্ত শত্রু আঘাত পাবে।",
        kaOnMsg="সক্রিয়! অস্ত্র সজ্জিত করুন এবং সকলকে আঘাত করতে ক্লিক করুন",
        kaOffMsg="নিষ্ক্রিয়।",            espAnimaisLabel="🐾 প্রাণী",
        espAnimaisDesc="খরগোশ, ঘোড়া, কিউই, টার্কি + নেকড়ে, ভালুক, মেরু ভালুক, আর্কটিক ফক্স, ব্যাঙ, বিচ্ছু, ম্যামথ, হেলিফ্যান্ট",
    },
    ["RU-RU"] = {
        tabInfo="Инфо",                 tabStatus="Статус",         tabFarm="Фарм",
        tabBring="Принести",            tabAvFarm="Прод. Фарм",     tabPlayer="Игрок",
        tabConfig="Настройки",          tabAvFunc="Прод. Функции",
        groupGeral="ОБЩЕЕ",             groupCombate="БОЕВЫЕ",      groupExtra="ДОПОЛН.",
        langSystem="Система языков",    langCurrent="Язык",
        popupTitle="Изменить язык?",    popupYes="Да",              popupNo="Нет",
        notifLangChanged="Язык изменён на ",
        infoStatus="🎮  Играет в 99 Nights in the Forest",
        notifTitle="Уведомления",       notifDesc="Включить/выключить все уведомления хаба",
        notifOn="ВКЛ",                  notifOff="ВЫКЛ",
        notifHistTitle="История уведомлений",
        notifHistClear="🗑 Очистить",   notifHistEmpty="📭  Уведомлений пока нет.",
        notifWelcome="Загружено!",      notifWelcomeMsg="Добро пожаловать, ",
        notifTip="Совет",               notifTipMsg="Наведите на уведомление чтобы остановить таймер 🔔",
        stFpsExc="Отлично",             stFpsBom="Хорошо",          stFpsBaixo="Плохо",
        stPingBoa="Хорошее соединение", stPingMod="Умеренно",       stPingRuim="Плохое соединение",
        stPlayersYou="вы",              stRegion="Регион: ",
        srvTitle="Сервер по ID",        srvBtn="→ Войти",
        freezeTitle="❄️  Аура заморозки",
        flyTitle="✈️  Полёт",           noclipTitle="👻  Нет клипа",
        bringAllTitle="⚡ ПРИНЕСТИ ВСЁ", bringAllBtn="▼  ПРИНЕСТИ ВСЁ",
        bringSuccess=" предметов успешно собрано! ★",
        bringFail="Предметов на карте не найдено.",
        tpPanelSelect="▼  Выбрать",     tpPanelBtn="🚀  Телепорт",
        copied="✓ Скопировано!",
        bringGrpFuel="BRING — Топливо и ресурсы", bringGrpFood="BRING — Еда и природа",
        bringGrpEquip="BRING — Снаряжение",        bringGrpSpecials="BRING — Особые",
        bLogLabel="🪵 Принести Брёвна",  bCombustLabel="🔥 Принести Топливо",
        bCarcacasLabel="🦴 Принести Туши", bSucataLabel="🔩 Принести Металлолом",
        bMateriaisLabel="💎 Принести Материалы", bComidasLabel="🍖 Принести Еду",
        bPeixesLabel="🐟 Принести Рыбу", bSementesLabel="🌱 Принести Семена",
        bFerrLabel="🪓 Принести Инструменты", bArmasLabel="⚔️ Принести Оружие",
        bAmmoLabel="🔫 Принести Патроны", bCuraLabel="💊 Принести Лечение",
        bPeltsLabel="🦺 Принести Шкуры", bChavesLabel="🗝️ Принести Ключи",
        bPocoesLabel="🧪 Принести Зелья", bBlueprintLabel="📋 Принести Чертежи",
        bLogDesc="Только: Брёвна",
        bCombustDesc="Уголь, Биотопливо, Канистра топлива, Бочка нефти…",
        bCarcacasDesc="Волк, Медведь, Полярный медведь, Адский слон, Лягушка, Труп инопланетянина…",
        bSucataDesc="Болт, Листовой металл, Мусор НЛО, Шина…",
        bMateriaisDesc="Культистский самоцвет, Лесной самоцвет, Замшелая монета…",
        bComidasDesc="Морковь, Кукуруза, Стейк, Рёбра, Рагу, Конфеты…",
        bPeixesDesc="Скумбрия, Лосось, Рыба-клоун, Акула, Лавовый угорь…",
        bSementesDesc="Перец, Ягода, Цветок, Dripleaf, Moonflower…",
        bFerrDesc="Мешки, Топоры, Удочки, Флейты, Доспехи…",
        bArmasDesc="Копьё, Ледяной меч, Арбалет, Револьвер, Винтовка…",
        bAmmoDesc="Патроны для револьвера, винтовки, дробовика",
        bCuraDesc="Бинт, Аптечка",
        bPeltsDesc="Кроличья лапка, Шкура волка, Шкура медведя, Песец…",
        bChavesDesc="Красный, Синий, Жёлтый, Серый, Лягушачий ключ",
        bPocoesDesc="Dripleaf, Луковица Moonflower, Лепесток Stareweed, Мандрагора",
        bBlueprintDesc="Крафтинг, Защита, Мебель, Сундук Обсидирон…",
        espPlayersLabel="👤 Игроки",      espPlayersDesc="Все игроки на сервере",
        espKidsLabel="👶 Пропавшие дети", espKidsDesc="Dino, Kraken, Squid, Koala Kid",
        espMonstrosLabel="💀 Монстры",    espMonstrosDesc="The Deer, The Owl, The Ram",
        espCultistasLabel="⚔️ Культисты", espCultistasDesc="Культист, Арбалетчик, Джаггернаут, Король…",
        espAliensLabel="👽 Инопланетяне", espAliensDesc="Инопланетянин, Элитный инопланетянин",
        espLogLabel="🪵 Брёвна",           espLogDesc="Брёвна — основное топливо",
        espCombustivelLabel="🔥 Топливо",  espCombustivelDesc="Уголь, Биотопливо, Канистра…",
        espCarcacasLabel="🦴 Туши",        espCarcacasDesc="Туши волка/медведя/полярного медведя…",
        espSucataLabel="🔩 Металлолом",    espSucataDesc="Болт, Листовой металл, Мусор НЛО…",
        espMateriaisLabel="💎 Материалы",  espMateriaisDesc="Культистский самоцвет, Лесной самоцвет…",
        espComidasLabel="🍖 Еда",          espComidasDesc="Морковь, Кукуруза, Ягода, Стейк…",
        espPeixesLabel="🐟 Рыба",          espPeixesDesc="Скумбрия, Лосось, Рыба-клоун, Акула…",
        espSementesLabel="🌱 Семена",      espSementesDesc="Перец, Ягода, Цветок, Светлячок, Dripleaf…",
        espFerrLabel="🪓 Инструменты",     espFerrDesc="Топоры, Мешки, Удочки, Флейты, Доспехи…",
        espArmasLabel="⚔️ Оружие",         espArmasDesc="Копьё, Арбалет, Ледяной меч, Револьвер…",
        espAmmoLabel="🔫 Патроны",         espAmmoDesc="Патроны для револьвера, винтовки, дробовика",
        espCuraLabel="💊 Лечение и шкуры", espCuraDesc="Бинт, Аптечка, Шкура волка, Медведя…",
        espChavesLabel="🗝️ Ключи",         espChavesDesc="Красный, Синий, Жёлтый, Серый, Лягушачий ключ",
        espBigornaLabel="⚙️ Части наковальни", espBigornaDesc="Перед/Зад/Основание наковальни + Метеор",
        espPocoesLabel="🧪 Зелья",          espPocoesDesc="Dripleaf, Луковица Moonflower, Лепесток Stareweed",
        espBlueprintLabel="📋 Чертежи",     espBlueprintDesc="Крафтинг, Защита, Мебель, Сундук…",
        kaSecTitle="⚔️  АУРА УБИЙСТВА",     kaTitle="⚔️  Аура убийства",
        kaDesc="Оснастите оружие ближнего боя и кликайте нормально — 1 клик бьёт ВСЕХ мобов в радиусе.",
        kaOnMsg="Активно! Оснастите оружие и кликните, чтобы ударить всех",
        kaOffMsg="Деактивировано.",         espAnimaisLabel="🐾 Животные",
        espAnimaisDesc="Кролик, Лошадь, Киви, Индейка + Волк, Медведь, Полярный медведь, Песец, Лягушка, Скорпион, Мамонт, Адский слон",
    },
}

-- Constrói tabela final mesclando base + overrides do idioma
local function buildTranslation(code)
    local out = {}
    -- Copia base PT-BR
    for k,v in pairs(TR_BASE) do out[k]=v end
    -- Aplica overrides do idioma (ou EN-US como intermediário)
    local en = TR_LANGS["EN-US"]
    if en then for k,v in pairs(en) do out[k]=v end end
    local specific = TR_LANGS[code]
    if specific then for k,v in pairs(specific) do out[k]=v end end
    return out
end

-- Cache de traduções compiladas
local TRANSLATIONS = {}
TRANSLATIONS["PT-BR"] = (function()
    local t={}; for k,v in pairs(TR_BASE) do t[k]=v end; return t
end)()
for _, lang in ipairs(LANGUAGES) do
    if lang.code ~= "PT-BR" then
        TRANSLATIONS[lang.code] = buildTranslation(lang.code)
    end
end

local currentLang = LANGUAGES[1]  -- Default: PT-BR

-- ══════════════════════════════════════════════════════
-- SISTEMA DE TRADUÇÃO DINÂMICA v3
-- langUpdaters: lista de funções chamadas ao trocar idioma
-- TL(label, key): cria vínculo permanente label ↔ chave
-- trackLabel: compatível com código antigo
-- ══════════════════════════════════════════════════════
local langUpdaters = {}
local langTrackedLabels = {}  -- mantido para compatibilidade

local function T(key)
    local trans = TRANSLATIONS[currentLang and currentLang.code or "PT-BR"]
    return (trans and trans[key]) or TR_BASE[key] or key
end

-- TL: vincula label a uma chave — atualiza SEMPRE que o idioma muda
local function TL(label, key)
    if label then label.Text = T(key) end
    table.insert(langUpdaters, function()
        if label and label.Parent then label.Text = T(key) end
    end)
end

-- trackLabel: compatível com código antigo + registra no novo sistema
local function trackLabel(label, key)
    if not langTrackedLabels[key] then langTrackedLabels[key] = {} end
    table.insert(langTrackedLabels[key], label)
    -- registra no novo sistema também
    table.insert(langUpdaters, function()
        if label and label.Parent then label.Text = T(key) end
    end)
end

local function applyLanguage(lang)
    currentLang = lang
    -- Chama TODOS os updaters registrados (labels, seções, botões, tudo)
    for _, fn in ipairs(langUpdaters) do pcall(fn) end
    -- Atualiza label "Idioma:"
    if infoLangKeyLbl then
        infoLangKeyLbl.Text = T("langCurrent") .. ":"
    end
end

-- ══════════════════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "PudimHubMerged"
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn    = false
ScreenGui.DisplayOrder    = 999
-- Fallback seguro: tenta CoreGui, se falhar usa PlayerGui
local _sgOk = pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
if not _sgOk or not ScreenGui.Parent then
    ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- ══════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM v3
-- ══════════════════════════════════════════════════════
local notifEnabled  = true   -- Toggle global
local notifSilent   = false  -- Modo silencioso (sem sons)
local notifPosition = "TR"   -- TR | TC | TL | BR | BC | BL | MR | ML

local NOTIF_CFG = {
    MAX_VISIBLE      = 5,
    HISTORY_MAX      = 100,
    DEFAULT_DURATION = 4.5,
    WIDTH            = 290,
    PADDING          = 12,
    GAP              = 8,
    SOUND_ENABLED    = true,
    SOUND_VOLUME     = 35,   -- 0-100
    GROUP_WINDOW     = 3,
    STYLE            = "card",  -- "card" | "pill" | "banner" | "toast"
}

local NOTIF_TIPOS = {
    success     = { title="Sucesso",    accent=Color3.fromRGB(60,220,120),   icon="✅", bg=Color3.fromRGB(6,22,12),   sound=6031221736, shake=false, bounce=true,  pulse=false },
    error       = { title="Erro",       accent=Color3.fromRGB(255,60,60),    icon="❌", bg=Color3.fromRGB(24,6,6),    sound=2544086171, shake=true,  bounce=false, pulse=false },
    warn        = { title="Aviso",      accent=Color3.fromRGB(255,185,0),    icon="⚠️", bg=Color3.fromRGB(22,14,0),   sound=3386627205, shake=false, bounce=false, pulse=true  },
    info        = { title="Info",       accent=Color3.fromRGB(60,160,255),   icon="💬", bg=Color3.fromRGB(6,12,26),   sound=4613146380, shake=false, bounce=false, pulse=false },
    achievement = { title="Conquista!", accent=Color3.fromRGB(255,210,0),    icon="🏆", bg=Color3.fromRGB(22,16,0),   sound=6042053626, shake=false, bounce=true,  pulse=false },
    custom      = { title="Aviso",      accent=Color3.fromRGB(180,100,255),  icon="💡", bg=Color3.fromRGB(14,8,22),   sound=6012002983, shake=false, bounce=false, pulse=false },
}

local nQueue      = {}   -- fila de notificações pendentes
local nActive     = {}   -- notificações visíveis
local nHistory    = {}   -- histórico completo
local nHistOpen   = false
local nCount      = 0
local nHistLO     = 0
local nGroupMap   = {}   -- [chave] = entry, para agrupamento
local historyEnabled   = true
local infoHistScrollRef = nil

-- ── Root container (reposicionado conforme notifPosition) ──────
local NotifRoot = Instance.new("Frame", ScreenGui)
NotifRoot.Name                = "PudimNotifRoot"
NotifRoot.BackgroundTransparency = 1
NotifRoot.Size                = UDim2.new(1,0,1,0)
NotifRoot.ZIndex              = 500
NotifRoot.BorderSizePixel     = 0

-- Badge 🔔 (oculto — histórico na aba Info)
local NBadge = Instance.new("Frame", NotifRoot)
NBadge.Name               = "NotifBadge"
NBadge.BackgroundColor3   = Color3.fromRGB(120,86,188)
NBadge.BorderSizePixel    = 0
NBadge.AnchorPoint        = Vector2.new(1,1)
NBadge.Position           = UDim2.new(1,-14,1,-14)
NBadge.Size               = UDim2.new(0,36,0,36)
NBadge.ZIndex             = 502
NBadge.Visible            = false
Instance.new("UICorner",NBadge).CornerRadius = UDim.new(1,0)
do
local NBadgeStroke = Instance.new("UIStroke",NBadge)
NBadgeStroke.Color = Color3.fromRGB(148,112,220); NBadgeStroke.Thickness=1.5
local NBadgeBell = Instance.new("TextLabel",NBadge)
NBadgeBell.BackgroundTransparency=1; NBadgeBell.Size=UDim2.new(1,0,1,0)
NBadgeBell.Font=Enum.Font.GothamBold; NBadgeBell.Text="🔔"; NBadgeBell.TextSize=16; NBadgeBell.ZIndex=503
end
local NBadgeCountFrame = Instance.new("Frame",NBadge)
NBadgeCountFrame.BackgroundColor3=Color3.fromRGB(255,60,60); NBadgeCountFrame.BorderSizePixel=0
NBadgeCountFrame.AnchorPoint=Vector2.new(1,0); NBadgeCountFrame.Position=UDim2.new(1,5,0,-5)
NBadgeCountFrame.Size=UDim2.new(0,18,0,18); NBadgeCountFrame.ZIndex=504; NBadgeCountFrame.Visible=false
Instance.new("UICorner",NBadgeCountFrame).CornerRadius=UDim.new(1,0)
local NBadgeCountLbl = Instance.new("TextLabel",NBadgeCountFrame)
NBadgeCountLbl.BackgroundTransparency=1; NBadgeCountLbl.Size=UDim2.new(1,0,1,0)
NBadgeCountLbl.Font=Enum.Font.GothamBlack; NBadgeCountLbl.Text="0"
NBadgeCountLbl.TextSize=9; NBadgeCountLbl.TextColor3=Color3.fromRGB(255,255,255); NBadgeCountLbl.ZIndex=505
local NBadgeBtn = Instance.new("TextButton",NBadge)
NBadgeBtn.BackgroundTransparency=1; NBadgeBtn.Size=UDim2.new(1,0,1,0); NBadgeBtn.Text=""; NBadgeBtn.ZIndex=506

-- ── Painel histórico expandido ─────────────────────────────────
local NHistPanel = Instance.new("Frame",NotifRoot)
NHistPanel.Name="HistPanel"; NHistPanel.BackgroundColor3=Color3.fromRGB(38,22,66)
NHistPanel.BorderSizePixel=0; NHistPanel.AnchorPoint=Vector2.new(1,1)
NHistPanel.Position=UDim2.new(1,-14,1,-58); NHistPanel.Size=UDim2.new(0,340,0,0)
NHistPanel.ZIndex=510; NHistPanel.ClipsDescendants=true; NHistPanel.Visible=false
Instance.new("UICorner",NHistPanel).CornerRadius=UDim.new(0,14)
do local NHistStroke=Instance.new("UIStroke",NHistPanel); NHistStroke.Color=Color3.fromRGB(148,112,220); NHistStroke.Thickness=2.5; NHistStroke.Transparency=0.55 end

local NHistClearBtn
do
local NHistHeader=Instance.new("Frame",NHistPanel)
NHistHeader.BackgroundColor3=Color3.fromRGB(54,34,88); NHistHeader.BorderSizePixel=0
NHistHeader.Size=UDim2.new(1,0,0,44); NHistHeader.ZIndex=511
Instance.new("UICorner",NHistHeader).CornerRadius=UDim.new(0,14)
local NHistHeaderFix=Instance.new("Frame",NHistHeader)
NHistHeaderFix.BackgroundColor3=Color3.fromRGB(14,15,20); NHistHeaderFix.BorderSizePixel=0
NHistHeaderFix.Position=UDim2.new(0,0,0.5,0); NHistHeaderFix.Size=UDim2.new(1,0,0.5,0); NHistHeaderFix.ZIndex=511
local NHistTitle=Instance.new("TextLabel",NHistHeader)
NHistTitle.BackgroundTransparency=1; NHistTitle.Position=UDim2.new(0,14,0,0)
NHistTitle.Size=UDim2.new(1,-60,1,0); NHistTitle.Font=Enum.Font.GothamBlack
NHistTitle.Text="🔔 Histórico"; NHistTitle.TextColor3=Color3.fromRGB(148,112,220)
trackLabel(NHistTitle, "notifHistTitle")
NHistTitle.TextSize=12; NHistTitle.TextXAlignment=Enum.TextXAlignment.Left; NHistTitle.ZIndex=512

NHistClearBtn=Instance.new("TextButton",NHistHeader)
NHistClearBtn.BackgroundColor3=Color3.fromRGB(70,40,100); NHistClearBtn.BackgroundTransparency=0.25
NHistClearBtn.BorderSizePixel=0; NHistClearBtn.AnchorPoint=Vector2.new(1,0.5)
NHistClearBtn.Position=UDim2.new(1,-10,0.5,0); NHistClearBtn.Size=UDim2.new(0,58,0,24)
NHistClearBtn.Font=Enum.Font.GothamBold; NHistClearBtn.Text="Limpar"
trackLabel(NHistClearBtn, "notifHistClear")
NHistClearBtn.TextColor3=Color3.fromRGB(255,100,100); NHistClearBtn.TextSize=9; NHistClearBtn.ZIndex=512
Instance.new("UICorner",NHistClearBtn).CornerRadius=UDim.new(0,7)
end -- NHistHeader block

-- Filtro por tipo no histórico (9. Histórico Expandido)
do -- NHistFilter block
local NHistFilterRow = Instance.new("Frame",NHistPanel)
NHistFilterRow.BackgroundColor3=Color3.fromRGB(28,16,50); NHistFilterRow.BorderSizePixel=0
NHistFilterRow.Size=UDim2.new(1,0,0,28); NHistFilterRow.Position=UDim2.new(0,0,0,44); NHistFilterRow.ZIndex=511
local NHistFilterLayout = Instance.new("UIListLayout",NHistFilterRow)
NHistFilterLayout.FillDirection=Enum.FillDirection.Horizontal; NHistFilterLayout.Padding=UDim.new(0,2)
NHistFilterLayout.VerticalAlignment=Enum.VerticalAlignment.Center; NHistFilterLayout.SortOrder=Enum.SortOrder.LayoutOrder
local NHistFilterPad=Instance.new("UIPadding",NHistFilterRow); NHistFilterPad.PaddingLeft=UDim.new(0,6)
local nHistFilter = "all"
local filterBtns = {}
for i, ft in ipairs({"all","success","error","warn","info"}) do
    local fb = Instance.new("TextButton",NHistFilterRow)
    fb.BackgroundColor3 = i==1 and Color3.fromRGB(120,86,188) or Color3.fromRGB(40,24,66)
    fb.BackgroundTransparency=0.2; fb.BorderSizePixel=0
    fb.Size=UDim2.new(0,50,0,20); fb.Font=Enum.Font.GothamBold
    fb.Text=ft=="all" and "Todos" or ft:sub(1,1):upper()..ft:sub(2)
    fb.TextColor3=Color3.fromRGB(220,210,240); fb.TextSize=8; fb.ZIndex=512; fb.LayoutOrder=i
    Instance.new("UICorner",fb).CornerRadius=UDim.new(0,6)
    filterBtns[ft]=fb
    fb.MouseButton1Click:Connect(function()
        nHistFilter=ft
        for k,b in pairs(filterBtns) do
            TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=k==ft and Color3.fromRGB(120,86,188) or Color3.fromRGB(40,24,66)}):Play()
        end
        -- Mostrar/ocultar rows conforme filtro
        local targetScroll = infoHistScrollRef or NHistScroll
        for _,c in ipairs(targetScroll:GetChildren()) do
            if c:IsA("Frame") then
                local tag = c:GetAttribute("notifType") or "info"
                c.Visible = (ft=="all" or tag==ft)
            end
        end
    end)
end
end -- NHistFilter block

local NHistScroll=Instance.new("ScrollingFrame",NHistPanel)
NHistScroll.BackgroundTransparency=1; NHistScroll.BorderSizePixel=0
NHistScroll.Position=UDim2.new(0,0,0,72); NHistScroll.Size=UDim2.new(1,0,1,-72)
NHistScroll.ZIndex=511; NHistScroll.ScrollBarThickness=3
NHistScroll.ScrollBarImageColor3=Color3.fromRGB(120,86,188)
NHistScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; NHistScroll.CanvasSize=UDim2.new(0,0,0,0)
do
local NHistList=Instance.new("UIListLayout",NHistScroll)
NHistList.Padding=UDim.new(0,4); NHistList.SortOrder=Enum.SortOrder.LayoutOrder
local NHistPad=Instance.new("UIPadding",NHistScroll)
NHistPad.PaddingTop=UDim.new(0,8); NHistPad.PaddingLeft=UDim.new(0,10)
NHistPad.PaddingRight=UDim.new(0,10); NHistPad.PaddingBottom=UDim.new(0,8)
end
local NEmptyLbl=Instance.new("TextLabel",NHistScroll)
NEmptyLbl.BackgroundTransparency=1; NEmptyLbl.Size=UDim2.new(1,0,0,60)
NEmptyLbl.Font=Enum.Font.GothamSemibold; NEmptyLbl.Text="Nenhuma notificação ainda."
trackLabel(NEmptyLbl, "notifHistEmpty")
NEmptyLbl.TextColor3=Color3.fromRGB(150,110,55); NEmptyLbl.TextSize=11
NEmptyLbl.LayoutOrder=9999; NEmptyLbl.ZIndex=512

-- ── Utilitários internos ───────────────────────────────────────
local function nPlaySound(id)
    if notifSilent or not NOTIF_CFG.SOUND_ENABLED or not id then return end
    task.spawn(function()
        pcall(function()
            local snd = Instance.new("Sound")
            snd.SoundId = "rbxassetid://"..tostring(id)
            snd.Volume = (NOTIF_CFG.SOUND_VOLUME or 35) / 100
            snd.RollOffMaxDistance = 0
            snd.Parent = SoundService
            if not snd.IsLoaded then snd.Loaded:Wait() end
            snd:Play()
            game:GetService("Debris"):AddItem(snd, 4)
        end)
    end)
end

-- ── Calcula posição de ancoragem baseada em notifPosition ──────
local function nGetAnchorPos(idx)
    local p = NOTIF_CFG.PADDING
    local g = NOTIF_CFG.GAP
    local w = NOTIF_CFG.WIDTH
    -- idx = offset acumulado de cima para baixo ou baixo para cima
    if notifPosition == "TR" then
        return UDim2.new(1, -p, 0, p + idx), UDim2.new(1, w+60, 0, p + idx), Vector2.new(1,0)
    elseif notifPosition == "BR" then
        return UDim2.new(1, -p, 1, -(p + idx)), UDim2.new(1, w+60, 1, -(p + idx)), Vector2.new(1,1)
    elseif notifPosition == "TL" then
        return UDim2.new(0, p, 0, p + idx), UDim2.new(0, -(w+60), 0, p + idx), Vector2.new(0,0)
    elseif notifPosition == "BL" then
        return UDim2.new(0, p, 1, -(p + idx)), UDim2.new(0, -(w+60), 1, -(p + idx)), Vector2.new(0,1)
    elseif notifPosition == "TC" then
        return UDim2.new(0.5, 0, 0, p + idx), UDim2.new(0.5, 0, 0, -(w+60)), Vector2.new(0.5,0)
    elseif notifPosition == "BC" then
        return UDim2.new(0.5, 0, 1, -(p + idx)), UDim2.new(0.5, 0, 1, w+60), Vector2.new(0.5,1)
    elseif notifPosition == "MR" then
        return UDim2.new(1, -p, 0.5, idx), UDim2.new(1, w+60, 0.5, idx), Vector2.new(1,0)
    elseif notifPosition == "ML" then
        return UDim2.new(0, p, 0.5, idx), UDim2.new(0, -(w+60), 0.5, idx), Vector2.new(0,0)
    end
    return UDim2.new(1, -p, 0, p + idx), UDim2.new(1, w+60, 0, p + idx), Vector2.new(1,0)
end

local function nReflow()
    local totalOff = 0
    local isBottom = (notifPosition == "BR" or notifPosition == "BL" or notifPosition == "BC")
    local isMiddle = (notifPosition == "MR" or notifPosition == "ML")
    local list = isBottom and {unpack(nActive)} or nActive
    if isMiddle then
        -- Empilha para baixo a partir do meio, centraliza o bloco
        local totalH = 0
        for _, entry in ipairs(nActive) do
            if entry and entry.frame and entry.frame.Parent then
                local h = entry.frame.AbsoluteSize.Y; if h==0 then h=50 end
                totalH = totalH + h + NOTIF_CFG.GAP
            end
        end
        totalH = totalH - NOTIF_CFG.GAP
        local startOff = -math.floor(totalH / 2)
        for _, entry in ipairs(nActive) do
            if entry and entry.frame and entry.frame.Parent then
                local h = entry.frame.AbsoluteSize.Y; if h==0 then h=50 end
                local targetPos, _, anch = nGetAnchorPos(startOff)
                entry.frame.AnchorPoint = anch
                TweenService:Create(entry.frame,TweenInfo.new(0.26,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=targetPos}):Play()
                startOff = startOff + h + NOTIF_CFG.GAP
            end
        end
    elseif isBottom then
        -- empilha de baixo para cima
        for i = #list, 1, -1 do
            local entry = list[i]
            if entry and entry.frame and entry.frame.Parent then
                local h = entry.frame.AbsoluteSize.Y; if h==0 then h=50 end
                local targetPos, _, anch = nGetAnchorPos(totalOff)
                entry.frame.AnchorPoint = anch
                TweenService:Create(entry.frame,TweenInfo.new(0.26,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=targetPos}):Play()
                totalOff = totalOff + h + NOTIF_CFG.GAP
            end
        end
    else
        for _, entry in ipairs(nActive) do
            if entry and entry.frame and entry.frame.Parent then
                local h = entry.frame.AbsoluteSize.Y; if h==0 then h=50 end
                local targetPos, _, anch = nGetAnchorPos(totalOff)
                entry.frame.AnchorPoint = anch
                TweenService:Create(entry.frame,TweenInfo.new(0.26,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Position=targetPos}):Play()
                totalOff = totalOff + h + NOTIF_CFG.GAP
            end
        end
    end
end

-- 9. HISTÓRICO EXPANDIDO com timestamp e tipo
local function nAddHistory(cfg, tipo)
    if not historyEnabled then return end
    local targetScroll = infoHistScrollRef or NHistScroll
    local emptyLbl = targetScroll:FindFirstChild("InfoHistEmptyLbl") or NEmptyLbl
    emptyLbl.Visible = false
    nHistLO = nHistLO + 1
    local t = NOTIF_TIPOS[tipo] or NOTIF_TIPOS.custom
    -- Timestamp
    local dt = os.date("*t")
    local timeStr = string.format("%02d:%02d:%02d", dt.hour, dt.min, dt.sec)
    local hRow = Instance.new("Frame", targetScroll)
    hRow.BackgroundColor3=Color3.fromRGB(26,28,38); hRow.BackgroundTransparency=0.08
    hRow.BorderSizePixel=0; hRow.Size=UDim2.new(1,0,0,52); hRow.LayoutOrder=-nHistLO; hRow.ZIndex=6
    hRow:SetAttribute("notifType", tipo)
    if nHistFilter ~= "all" and tipo ~= nHistFilter then hRow.Visible = false end
    Instance.new("UICorner",hRow).CornerRadius=UDim.new(0,9)
    local hStroke=Instance.new("UIStroke",hRow); hStroke.Color=t.accent; hStroke.Thickness=1; hStroke.Transparency=0.72
    local hBar=Instance.new("Frame",hRow); hBar.BackgroundColor3=t.accent; hBar.BorderSizePixel=0
    hBar.Size=UDim2.new(0,3,1,-10); hBar.Position=UDim2.new(0,0,0,5); hBar.ZIndex=7
    Instance.new("UICorner",hBar).CornerRadius=UDim.new(0,2)
    local hIconBg=Instance.new("Frame",hRow); hIconBg.BackgroundColor3=t.accent
    hIconBg.BackgroundTransparency=0.8; hIconBg.BorderSizePixel=0
    hIconBg.Position=UDim2.new(0,10,0.5,-12); hIconBg.Size=UDim2.new(0,24,0,24); hIconBg.ZIndex=7
    Instance.new("UICorner",hIconBg).CornerRadius=UDim.new(1,0)
    local hIcon=Instance.new("TextLabel",hIconBg); hIcon.BackgroundTransparency=1
    hIcon.Size=UDim2.new(1,0,1,0); hIcon.Font=Enum.Font.GothamBold
    hIcon.Text=cfg.icon or t.icon; hIcon.TextColor3=t.accent; hIcon.TextSize=12; hIcon.ZIndex=8
    local hTitle=Instance.new("TextLabel",hRow); hTitle.BackgroundTransparency=1
    hTitle.Position=UDim2.new(0,42,0,6); hTitle.Size=UDim2.new(1,-80,0,14)
    hTitle.Font=Enum.Font.GothamBold; hTitle.Text=cfg.title or t.title
    hTitle.TextColor3=Color3.fromRGB(255,235,200); hTitle.TextSize=10
    hTitle.TextXAlignment=Enum.TextXAlignment.Left; hTitle.ZIndex=7
    -- Timestamp no canto direito
    local hTime=Instance.new("TextLabel",hRow); hTime.BackgroundTransparency=1
    hTime.AnchorPoint=Vector2.new(1,0); hTime.Position=UDim2.new(1,-6,0,6); hTime.Size=UDim2.new(0,52,0,12)
    hTime.Font=Enum.Font.GothamBold; hTime.Text=timeStr
    hTime.TextColor3=Color3.fromRGB(100,90,120); hTime.TextSize=7
    hTime.TextXAlignment=Enum.TextXAlignment.Right; hTime.ZIndex=7
    -- Badge tipo
    local hBadge=Instance.new("Frame",hRow); hBadge.BackgroundColor3=t.accent
    hBadge.BackgroundTransparency=0.82; hBadge.BorderSizePixel=0
    hBadge.Position=UDim2.new(1,-6,0,20); hBadge.Size=UDim2.new(0,0,0,11)
    hBadge.AutomaticSize=Enum.AutomaticSize.X
    hBadge.AnchorPoint=Vector2.new(1,0); hBadge.ZIndex=7
    Instance.new("UICorner",hBadge).CornerRadius=UDim.new(0,4)
    local hBadgePad=Instance.new("UIPadding",hBadge); hBadgePad.PaddingLeft=UDim.new(0,4); hBadgePad.PaddingRight=UDim.new(0,4)
    local hBadgeLbl=Instance.new("TextLabel",hBadge); hBadgeLbl.BackgroundTransparency=1
    hBadgeLbl.Size=UDim2.new(1,0,1,0); hBadgeLbl.AutomaticSize=Enum.AutomaticSize.X
    hBadgeLbl.Font=Enum.Font.GothamBold; hBadgeLbl.Text=tipo:upper()
    hBadgeLbl.TextColor3=t.accent; hBadgeLbl.TextSize=7; hBadgeLbl.ZIndex=8
    local hMsg=Instance.new("TextLabel",hRow); hMsg.BackgroundTransparency=1
    hMsg.Position=UDim2.new(0,42,0,24); hMsg.Size=UDim2.new(1,-52,0,14)
    hMsg.Font=Enum.Font.Gotham; hMsg.Text=cfg.msg or ""
    hMsg.TextColor3=Color3.fromRGB(155,120,70); hMsg.TextSize=9
    hMsg.TextXAlignment=Enum.TextXAlignment.Left; hMsg.TextTruncate=Enum.TextTruncate.AtEnd; hMsg.ZIndex=7
    -- Limite histórico
    local children=targetScroll:GetChildren(); local rows={}
    for _,c in ipairs(children) do if c:IsA("Frame") then table.insert(rows,c) end end
    if #rows>NOTIF_CFG.HISTORY_MAX then
        table.sort(rows,function(a,b) return a.LayoutOrder<b.LayoutOrder end); rows[1]:Destroy()
    end
end

local function nRemoveEntry(entry, instant)
    if entry._removed then return end; entry._removed=true
    for i,e in ipairs(nActive) do if e==entry then table.remove(nActive,i); break end end
    -- Remove do mapa de grupos
    for k,v in pairs(nGroupMap) do if v==entry then nGroupMap[k]=nil; break end end
    local frame=entry.frame
    local dur=instant and 0 or 0.25
    local _, exitPos, _ = nGetAnchorPos(0)
    TweenService:Create(frame,TweenInfo.new(dur,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{
        Position=exitPos, BackgroundTransparency=0.6
    }):Play()
    task.delay(dur+0.05,function()
        pcall(function() frame:Destroy() end)
        nReflow()
    end)
end

-- 10. ÍCONE ANIMADO por tipo
local function nAnimateIcon(iconLbl, tipo)
    local t = NOTIF_TIPOS[tipo] or NOTIF_TIPOS.custom
    if t.bounce then
        -- Bounce: cresce e volta (success, achievement)
        TweenService:Create(iconLbl,TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{TextSize=22}):Play()
        task.delay(0.2,function()
            TweenService:Create(iconLbl,TweenInfo.new(0.2,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out),{TextSize=16}):Play()
        end)
    elseif t.shake then
        -- Shake: rotação rápida (error)
        local function shake(deg, d)
            TweenService:Create(iconLbl,TweenInfo.new(d),{Rotation=deg}):Play()
        end
        task.spawn(function()
            for _,r in ipairs({-8,8,-6,6,-3,3,0}) do shake(r,0.04); task.wait(0.05) end
        end)
    elseif t.pulse then
        -- Pulse: pisca 2x (warn)
        task.spawn(function()
            for _=1,2 do
                TweenService:Create(iconLbl,TweenInfo.new(0.12),{TextTransparency=0.6}):Play()
                task.wait(0.15)
                TweenService:Create(iconLbl,TweenInfo.new(0.12),{TextTransparency=0}):Play()
                task.wait(0.15)
            end
        end)
    end
end

-- 7. ANIMAÇÃO DE ENTRADA por tipo
local function nGetEntryAnimation(tipo)
    -- Retorna TweenInfo e propriedades extras de entrada
    if tipo == "error" then
        return TweenInfo.new(0.25,Enum.EasingStyle.Bounce,Enum.EasingDirection.Out), {}
    elseif tipo == "success" or tipo == "achievement" then
        return TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {}
    elseif tipo == "warn" then
        return TweenInfo.new(0.28,Enum.EasingStyle.Elastic,Enum.EasingDirection.Out), {}
    else
        return TweenInfo.new(0.30,Enum.EasingStyle.Quint,Enum.EasingDirection.Out), {}
    end
end

-- ── Card principal ─────────────────────────────────────────────
local Notify = {}

local function nCreateCard(cfg, tipo)
    local t      = NOTIF_TIPOS[tipo] or NOTIF_TIPOS.custom
    local title  = cfg.title   or t.title
    local msg    = cfg.msg     or ""
    local icon   = cfg.icon    or t.icon
    local accent = cfg.accent  or t.accent
    local dur    = cfg.duration or NOTIF_CFG.DEFAULT_DURATION
    local action = cfg.action
    local HAS_MSG = msg ~= ""

    -- 4. AGRUPAMENTO DE REPETIDAS
    local groupKey = title.."|"..msg.."|"..tipo
    if nGroupMap[groupKey] and not nGroupMap[groupKey]._removed then
        local existing = nGroupMap[groupKey]
        existing.groupCount = (existing.groupCount or 1) + 1
        -- Atualiza label de contagem
        if existing.countLbl then
            existing.countLbl.Text = "×"..existing.groupCount
            existing.countLbl.Visible = true
            TweenService:Create(existing.countLbl,TweenInfo.new(0.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{TextSize=12}):Play()
            task.delay(0.2,function() TweenService:Create(existing.countLbl,TweenInfo.new(0.1),{TextSize=10}):Play() end)
        end
        -- Reseta o timer
        existing.startTick  = tick()
        existing.pauseAcc   = 0
        existing.duration   = dur
        -- Pulso visual no card
        TweenService:Create(existing.frame,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(30,30,40)}):Play()
        task.delay(0.15,function() TweenService:Create(existing.frame,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(18,18,24)}):Play() end)
        nPlaySound(t.sound)
        return existing
    end

    local TOTAL_H = HAS_MSG and 72 or 52
    if action then TOTAL_H = TOTAL_H + 32 end

    -- Ajustes por estilo
    local sty = NOTIF_CFG.STYLE or "card"
    local cardW = NOTIF_CFG.WIDTH
    if sty == "pill" then
        TOTAL_H = 40; HAS_MSG = false; cardW = math.min(cardW, 240)
    elseif sty == "banner" then
        TOTAL_H = HAS_MSG and 58 or 42; cardW = math.min(500, workspace.CurrentCamera.ViewportSize.X - 24)
    elseif sty == "toast" then
        TOTAL_H = 36; HAS_MSG = false; cardW = math.min(cardW, 220)
    end

    -- Card
    local card = Instance.new("Frame", NotifRoot)
    card.Name             = "PudimNotif_"..tostring(tick())
    card.BorderSizePixel  = 0
    card.AnchorPoint      = Vector2.new(1,0)
    card.Size             = UDim2.new(0,cardW,0,TOTAL_H)
    card.ZIndex           = 520
    card.ClipsDescendants = true

    -- Aparência varia por estilo
    if sty == "pill" then
        card.BackgroundColor3 = Color3.fromRGB(18,18,28)
        Instance.new("UICorner",card).CornerRadius = UDim.new(1,0)
        local pStroke = Instance.new("UIStroke",card)
        pStroke.Color = accent; pStroke.Thickness = 1.8
        pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; pStroke.Transparency = 0.2
        -- Gradiente lateral accent
        local pGrad = Instance.new("UIGradient",card)
        pGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, accent),
            ColorSequenceKeypoint.new(0.35, Color3.fromRGB(18,18,28)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(18,18,28)),
        }); pGrad.Rotation = 0

    elseif sty == "banner" then
        card.BackgroundColor3 = Color3.fromRGB(14,14,20)
        Instance.new("UICorner",card).CornerRadius = UDim.new(0,8)
        local bStroke = Instance.new("UIStroke",card)
        bStroke.Color = accent; bStroke.Thickness = 0
        bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        -- Linha accent esquerda grossa
        local bBar = Instance.new("Frame",card)
        bBar.BackgroundColor3 = accent; bBar.BorderSizePixel = 0
        bBar.Size = UDim2.new(0,5,1,0); bBar.ZIndex = 521
        Instance.new("UICorner",bBar).CornerRadius = UDim.new(0,4)
        -- Fundo tintado com a cor accent
        local bGrad = Instance.new("UIGradient",card)
        bGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, accent),
            ColorSequenceKeypoint.new(0.15, Color3.fromRGB(14,14,20)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(14,14,20)),
        }); bGrad.Rotation = 0
        bGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.82),
            NumberSequenceKeypoint.new(0.15, 0),
            NumberSequenceKeypoint.new(1, 0),
        })

    elseif sty == "toast" then
        card.BackgroundColor3 = Color3.fromRGB(30,30,38)
        card.BackgroundTransparency = 0.12
        Instance.new("UICorner",card).CornerRadius = UDim.new(0,20)
        local tStroke = Instance.new("UIStroke",card)
        tStroke.Color = Color3.fromRGB(80,80,100); tStroke.Thickness = 1
        tStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; tStroke.Transparency = 0.6

    else -- "card" (padrão)
        card.BackgroundColor3 = Color3.fromRGB(18,18,24)
        Instance.new("UICorner",card).CornerRadius = UDim.new(0,10)
        -- Borda accent colorida por tipo
        local cardStroke = Instance.new("UIStroke",card)
        cardStroke.Color           = accent
        cardStroke.Thickness       = 1.4
        cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        cardStroke.Transparency    = 0.6
        -- Linha accent no topo (cor do tipo)
        local topLine = Instance.new("Frame",card)
        topLine.BackgroundColor3 = accent; topLine.BorderSizePixel=0
        topLine.Size=UDim2.new(1,0,0,2); topLine.ZIndex=521
        -- Brilho topo
        local shine = Instance.new("Frame",card)
        shine.BackgroundColor3=Color3.fromRGB(255,255,255); shine.BackgroundTransparency=0.92
        shine.BorderSizePixel=0; shine.Size=UDim2.new(1,0,0,1); shine.Position=UDim2.new(0,0,0,2); shine.ZIndex=521
    end

    -- Referência do cardStroke para hover (só existe no estilo card)
    local cardStroke = card:FindFirstChildOfClass("UIStroke")

    -- 10. Ícone animado
    local iconBg, iconLbl
    if sty == "pill" or sty == "toast" then
        -- Ícone simples sem fundo
        iconLbl = Instance.new("TextLabel",card)
        iconLbl.BackgroundTransparency=1
        iconLbl.Position=UDim2.new(0,10,0.5,-10); iconLbl.Size=UDim2.new(0,22,0,22)
        iconLbl.Font=Enum.Font.GothamBold; iconLbl.Text=icon
        iconLbl.TextColor3=accent; iconLbl.TextSize=14; iconLbl.ZIndex=522
        iconBg = iconLbl -- alias para compatibilidade
    else
        iconBg = Instance.new("Frame",card)
        iconBg.BackgroundColor3=accent; iconBg.BackgroundTransparency=0.82; iconBg.BorderSizePixel=0
        if sty == "banner" then
            iconBg.Position=UDim2.new(0,16,0.5,-12); iconBg.Size=UDim2.new(0,24,0,24)
        else
            iconBg.Position=UDim2.new(0,10,0.5,-14); iconBg.Size=UDim2.new(0,28,0,28)
        end
        iconBg.ZIndex=521
        Instance.new("UICorner",iconBg).CornerRadius=UDim.new(1,0)
        iconLbl = Instance.new("TextLabel",iconBg)
        iconLbl.BackgroundTransparency=1; iconLbl.Size=UDim2.new(1,0,1,0)
        iconLbl.Font=Enum.Font.GothamBold; iconLbl.Text=icon
        iconLbl.TextSize=16; iconLbl.ZIndex=522
    end

    -- Título
    local iconOffX = (sty=="banner") and 54 or 46
    local titleY = HAS_MSG and 10 or math.floor(TOTAL_H/2-9)
    if sty=="pill" or sty=="toast" then titleY = math.floor(TOTAL_H/2-9) end
    local titleLbl = Instance.new("TextLabel",card)
    titleLbl.BackgroundTransparency=1
    titleLbl.Position=UDim2.new(0,iconOffX,0,titleY); titleLbl.Size=UDim2.new(1,-80,0,18)
    titleLbl.Font=Enum.Font.GothamBlack; titleLbl.Text=title
    titleLbl.TextColor3=Color3.fromRGB(245,245,250); titleLbl.TextSize=(sty=="pill" or sty=="toast") and 11 or 12
    titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.TextTruncate=Enum.TextTruncate.AtEnd; titleLbl.ZIndex=522

    -- Mensagem
    local msgLblRef = nil
    if HAS_MSG then
        local msgLbl = Instance.new("TextLabel",card)
        msgLbl.BackgroundTransparency=1
        msgLbl.Position=UDim2.new(0,46,0,titleY+20); msgLbl.Size=UDim2.new(1,-76,0,26)
        msgLbl.Font=Enum.Font.Gotham; msgLbl.Text=msg
        msgLbl.TextColor3=Color3.fromRGB(150,150,162); msgLbl.TextSize=10
        msgLbl.TextXAlignment=Enum.TextXAlignment.Left; msgLbl.TextWrapped=true; msgLbl.ZIndex=522
        msgLblRef=msgLbl
    end

    -- 5. BOTÃO DE AÇÃO INLINE melhorado
    if action then
        local actionBtn = Instance.new("TextButton",card)
        actionBtn.BackgroundColor3=accent; actionBtn.BackgroundTransparency=0.75; actionBtn.BorderSizePixel=0
        actionBtn.Position=UDim2.new(0,46,0,TOTAL_H-36); actionBtn.Size=UDim2.new(0,100,0,24)
        actionBtn.Font=Enum.Font.GothamBold; actionBtn.Text=action.label or "Ver"
        actionBtn.TextColor3=Color3.fromRGB(240,235,255); actionBtn.TextSize=10; actionBtn.ZIndex=524
        Instance.new("UICorner",actionBtn).CornerRadius=UDim.new(0,6)
        local actionStroke=Instance.new("UIStroke",actionBtn); actionStroke.Color=accent; actionStroke.Thickness=1; actionStroke.Transparency=0.4
        actionBtn.MouseEnter:Connect(function() TweenService:Create(actionBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.4}):Play() end)
        actionBtn.MouseLeave:Connect(function() TweenService:Create(actionBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.75}):Play() end)
        actionBtn.MouseButton1Click:Connect(function() pcall(action.callback) end)
    end

    -- Botão × fechar
    local closeBtn = Instance.new("TextButton",card)
    closeBtn.BackgroundTransparency=1; closeBtn.BorderSizePixel=0; closeBtn.AutoButtonColor=false
    closeBtn.AnchorPoint=Vector2.new(1,0); closeBtn.Position=UDim2.new(1,-6,0,6)
    closeBtn.Size=UDim2.new(0,20,0,20); closeBtn.Font=Enum.Font.GothamBlack
    closeBtn.Text="×"; closeBtn.TextColor3=Color3.fromRGB(120,120,132); closeBtn.TextSize=16; closeBtn.ZIndex=528
    closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn,TweenInfo.new(0.1),{TextColor3=Color3.fromRGB(255,100,100)}):Play() end)
    closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn,TweenInfo.new(0.1),{TextColor3=Color3.fromRGB(120,120,132)}):Play() end)

    -- 4. Contador de agrupamento
    local countLbl = Instance.new("TextLabel",card)
    countLbl.BackgroundColor3=accent; countLbl.BackgroundTransparency=0.3; countLbl.BorderSizePixel=0
    countLbl.AnchorPoint=Vector2.new(0,0.5); countLbl.Position=UDim2.new(0,46,0,6)
    countLbl.Size=UDim2.new(0,28,0,16); countLbl.Font=Enum.Font.GothamBlack
    countLbl.Text="×1"; countLbl.TextColor3=Color3.fromRGB(255,255,255); countLbl.TextSize=10; countLbl.ZIndex=525
    countLbl.Visible=false
    Instance.new("UICorner",countLbl).CornerRadius=UDim.new(0,5)

    -- 2. BARRA DE PROGRESSO mais grossa e visível
    local progressBg = Instance.new("Frame",card)
    progressBg.BackgroundColor3=Color3.fromRGB(30,30,42); progressBg.BackgroundTransparency=0
    progressBg.BorderSizePixel=0; progressBg.Position=UDim2.new(0,0,1,-4)
    progressBg.Size=UDim2.new(1,0,0,4); progressBg.ZIndex=522
    Instance.new("UICorner",progressBg).CornerRadius=UDim.new(1,0)
    local progressFill = Instance.new("Frame",progressBg)
    progressFill.BackgroundColor3=accent; progressFill.BorderSizePixel=0
    progressFill.Size=UDim2.new(1,0,1,0); progressFill.ZIndex=523
    Instance.new("UICorner",progressFill).CornerRadius=UDim.new(1,0)
    -- Brilho na barra de progresso
    local progShine = Instance.new("Frame",progressFill)
    progShine.BackgroundColor3=Color3.fromRGB(255,255,255); progShine.BackgroundTransparency=0.7
    progShine.BorderSizePixel=0; progShine.Size=UDim2.new(1,0,0,1); progShine.ZIndex=524

    -- Entry
    local entry = {
        frame=card, cfg=cfg, tipo=tipo,
        startTick=tick(), duration=dur,
        paused=false, pauseAcc=0, pauseFrom=0,
        _removed=false, progress=progressFill,
        msgLblRef=msgLblRef, countLbl=countLbl, groupCount=1,
        accentColor=accent,
    }
    nGroupMap[groupKey] = entry
    table.insert(nActive,1,entry)
    nCount=nCount+1
    NBadgeCountLbl.Text=tostring(nCount); NBadgeCountFrame.Visible=(nCount>0)

    -- 3. FECHAR AO CLICAR no card inteiro
    local hitbox = Instance.new("TextButton",card)
    hitbox.BackgroundTransparency=1; hitbox.BorderSizePixel=0; hitbox.AutoButtonColor=false
    hitbox.Size=UDim2.new(1,0,1,0); hitbox.Text=""; hitbox.ZIndex=521

    -- Hover: pausa timer + destaque borda
    hitbox.MouseEnter:Connect(function()
        if entry._removed then return end
        entry.paused=true; entry.pauseFrom=tick()
        if cardStroke then TweenService:Create(cardStroke,TweenInfo.new(0.12),{Transparency=0.15,Thickness=1.8}):Play() end
        TweenService:Create(card,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(24,24,34)}):Play()
    end)
    hitbox.MouseLeave:Connect(function()
        if entry._removed then return end
        entry.paused=false; entry.pauseAcc=entry.pauseAcc+(tick()-entry.pauseFrom)
        if cardStroke then TweenService:Create(cardStroke,TweenInfo.new(0.12),{Transparency=0.6,Thickness=1.4}):Play() end
        TweenService:Create(card,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(18,18,24)}):Play()
    end)

    -- 3. Clique no card fecha
    hitbox.MouseButton1Click:Connect(function() nRemoveEntry(entry) end)
    closeBtn.MouseButton1Click:Connect(function() nRemoveEntry(entry) end)

    -- 7. Animação de entrada por tipo
    local entryTI, _ = nGetEntryAnimation(tipo)
    local _, startPos, anch = nGetAnchorPos(0)
    card.AnchorPoint = anch
    card.Position    = startPos
    nReflow()
    task.wait()
    local targetPos, _, _ = nGetAnchorPos(0)
    TweenService:Create(card,entryTI,{Position=targetPos}):Play()

    -- 10. Anima ícone
    task.delay(0.2,function() nAnimateIcon(iconLbl, tipo) end)

    -- Timer + barra de progresso
    task.spawn(function()
        while not entry._removed do
            task.wait(0.04)
            if entry._removed then break end
            local elapsed=tick()-entry.startTick-entry.pauseAcc
            if entry.paused then elapsed=entry.pauseFrom-entry.startTick-entry.pauseAcc end
            local pct=math.clamp(1-(elapsed/entry.duration),0,1)
            pcall(function()
                entry.progress.Size=UDim2.new(pct,0,1,0)
                -- Cor muda conforme tempo restante: accent → amarelo → vermelho
                if pct < 0.25 then
                    TweenService:Create(entry.progress,TweenInfo.new(0.5),{BackgroundColor3=Color3.fromRGB(255,80,80)}):Play()
                elseif pct < 0.5 then
                    TweenService:Create(entry.progress,TweenInfo.new(0.5),{BackgroundColor3=Color3.fromRGB(255,200,50)}):Play()
                end
            end)
            if pct<=0 and not entry.paused then nRemoveEntry(entry); break end
        end
    end)

    nPlaySound(t.sound)
    return entry
end

function Notify.send(cfg)
    if not notifEnabled then return end
    local type=cfg.type or "info"
    if #nActive>=NOTIF_CFG.MAX_VISIBLE then table.insert(nQueue,cfg); return end
    local entry=nCreateCard(cfg,type); nAddHistory(cfg,type)
    task.spawn(function()
        while not entry._removed do task.wait(0.1) end
        if #nQueue>0 then local next=table.remove(nQueue,1); Notify.send(next) end
        nCount=math.max(0,nCount-1); NBadgeCountLbl.Text=tostring(nCount); NBadgeCountFrame.Visible=(nCount>0)
        if #nActive==0 then
            task.delay(3,function()
                if #nActive==0 then
                    TweenService:Create(NBadge,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
                    task.wait(0.5); NBadge.Visible=false; NBadge.BackgroundTransparency=0
                end
            end)
        end
    end)
end

function Notify.success(title,msg,dur) Notify.send({type="success",title=title,msg=msg or "",duration=dur}) end
function Notify.error(title,msg,dur)   Notify.send({type="error",  title=title,msg=msg or "",duration=dur}) end
function Notify.warn(title,msg,dur)    Notify.send({type="warn",   title=title,msg=msg or "",duration=dur}) end
function Notify.info(title,msg,dur)    Notify.send({type="info",   title=title,msg=msg or "",duration=dur}) end
function Notify.achievement(title,msg,icon) Notify.send({type="achievement",title=title,msg=msg or "",icon=icon or "★",duration=6}) end

-- 6. POSIÇÃO CUSTOMIZÁVEL — função para trocar posição em runtime
function Notify.setPosition(pos)
    local valid = {TR=true,TC=true,TL=true,BR=true,BC=true,BL=true,MR=true,ML=true}
    if valid[pos] then
        notifPosition=pos
        nReflow()
    end
end

-- 8. MODO SILENCIOSO
function Notify.setSilent(on) notifSilent=on end
function Notify.isSilent() return notifSilent end

-- Badge toggle histórico
NBadgeBtn.MouseButton1Click:Connect(function()
    nHistOpen=not nHistOpen
    if nHistOpen then
        NHistPanel.Visible=true; NHistPanel.Size=UDim2.new(0,340,0,0)
        TweenService:Create(NHistPanel,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,340,0,400)}):Play()
        TweenService:Create(NBadge,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(148,112,220)}):Play()
    else
        TweenService:Create(NHistPanel,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{Size=UDim2.new(0,340,0,0)}):Play()
        TweenService:Create(NBadge,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(120,86,188)}):Play()
        task.delay(0.25,function() NHistPanel.Visible=false end)
    end
end)
NHistClearBtn.MouseButton1Click:Connect(function()
    for _,c in ipairs(NHistScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    NEmptyLbl.Visible=true; nHistLO=0; nGroupMap={}
    Notify.info(T("notifHistTitle"),T("notifHistCleared"))
end)
UserInputService.InputBegan:Connect(function(input)
    if not nHistOpen then return end
    if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    local mp=UserInputService:GetMouseLocation()
    local ap,as=NHistPanel.AbsolutePosition,NHistPanel.AbsoluteSize
    local bp,bs=NBadge.AbsolutePosition,NBadge.AbsoluteSize
    local inH=mp.X>=ap.X and mp.X<=ap.X+as.X and mp.Y>=ap.Y and mp.Y<=ap.Y+as.Y
    local inB=mp.X>=bp.X and mp.X<=bp.X+bs.X and mp.Y>=bp.Y and mp.Y<=bp.Y+bs.Y
    if not inH and not inB then
        nHistOpen=false
        TweenService:Create(NHistPanel,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{Size=UDim2.new(0,340,0,0)}):Play()
        TweenService:Create(NBadge,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(120,86,188)}):Play()
        task.delay(0.25,function() NHistPanel.Visible=false end)
    end
end)


-- ══════════════════════════════════════════════════════
--  MAIN FRAME — Voidware Style
-- ══════════════════════════════════════════════════════
-- Voidware color palette
-- (paleta VoidWare definida antes de _LaunchHub)

local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Parent           = ScreenGui
MainFrame.BackgroundColor3 = VD_BG
MainFrame.Position         = UDim2.new(0.5, -270, 1.8, 0)
MainFrame.Size             = UDim2.new(0, 540, 0, 370)
MainFrame.BorderSizePixel  = 0
MainFrame.Active           = true
MainFrame.Draggable        = true
MainFrame.ZIndex           = 2
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(105, 78, 158); MainStroke.Thickness = 2

-- Sombra do MainFrame
local MainShadow = Instance.new("Frame", ScreenGui)
MainShadow.Name              = "MainShadow"
MainShadow.BackgroundColor3  = Color3.fromRGB(0,0,0)
MainShadow.BackgroundTransparency = 0.55
MainShadow.BorderSizePixel   = 0
MainShadow.Position          = UDim2.new(0.5,-263,1.8,10)
MainShadow.Size              = UDim2.new(0,546,0,376)
MainShadow.ZIndex            = 1
MainShadow.Visible           = false
Instance.new("UICorner",MainShadow).CornerRadius = UDim.new(0,18)

-- Animação de entrada da interface (Back bounce do splash para o centro)
task.delay(0.05, function()
    TweenService:Create(MainShadow, TweenInfo.new(0.7,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(0.5,-263,0.5,-175)}):Play()
    TweenService:Create(MainFrame,  TweenInfo.new(0.7,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(0.5,-270,0.5,-185)}):Play()
end)

-- ══════════════════════════════════════════════════════
-- TOP BAR — Voidware Style
-- ══════════════════════════════════════════════════════
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.BackgroundColor3 = VD_TOPBAR
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)
-- Fix cantos inferiores
local topFix = Instance.new("Frame", TopBar)
topFix.BackgroundColor3 = VD_TOPBAR
topFix.BorderSizePixel = 0
topFix.Position = UDim2.new(0,0,0.5,0)
topFix.Size = UDim2.new(1,0,0.5,0)
topFix.ZIndex = 3
-- Linha separadora sutil na borda inferior
local TopDivider = Instance.new("Frame", TopBar)
TopDivider.BackgroundColor3 = VD_DIVIDER
TopDivider.BackgroundTransparency = 0.6
TopDivider.BorderSizePixel = 0
TopDivider.Position = UDim2.new(0,0,1,-1)
TopDivider.Size = UDim2.new(1,0,0,1)
TopDivider.ZIndex = 4

-- Ícone + título
local TitleBox = Instance.new("Frame", TopBar)
TitleBox.BackgroundTransparency = 1
TitleBox.Position = UDim2.new(0, 14, 0, 0)
TitleBox.Size     = UDim2.new(0, 220, 1, 0)
TitleBox.ZIndex   = 4

local TitleIcon = Instance.new("TextLabel", TitleBox)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Position = UDim2.new(0, 0, 0.5, -11)
TitleIcon.Size     = UDim2.new(0, 22, 0, 22)
TitleIcon.Text     = "🍮"
TitleIcon.TextSize = 18
TitleIcon.Font     = Enum.Font.GothamBold
TitleIcon.ZIndex   = 5

local TitleLabel = Instance.new("TextLabel", TitleBox)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position       = UDim2.new(0, 28, 0, 6)
TitleLabel.Size           = UDim2.new(1, -28, 0, 18)
TitleLabel.Font           = Enum.Font.GothamBold
TitleLabel.Text           = "PudimHub v5"
TitleLabel.TextColor3     = VD_TEXT
TitleLabel.TextSize       = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex         = 5

local TitleSub = Instance.new("TextLabel", TitleBox)
TitleSub.BackgroundTransparency = 1
TitleSub.Position       = UDim2.new(0, 28, 0, 26)
TitleSub.Size           = UDim2.new(1, -28, 0, 12)
TitleSub.Font           = Enum.Font.Gotham
TitleSub.Text           = "discord.gg/pudim"
TitleSub.TextColor3     = VD_MUTED
TitleSub.TextSize       = 9
TitleSub.TextXAlignment = Enum.TextXAlignment.Left
TitleSub.ZIndex         = 5

local TopBtns = {}
local _topBtnCfg = {
    {name="Theme",    bgN=Color3.fromRGB(120,50,200),  bgH=Color3.fromRGB(150,70,240)},
    {name="Minimize", bgN=Color3.fromRGB(70,70,80),    bgH=Color3.fromRGB(110,110,120)},
    {name="Maximize", bgN=Color3.fromRGB(30,120,220),  bgH=Color3.fromRGB(50,150,255)},
    {name="Close",    bgN=Color3.fromRGB(200,45,45),   bgH=Color3.fromRGB(255,65,65)},
}
local _topBtnSounds = {
    Theme    = 6012002983,
    Minimize = 6031221736,
    Maximize = 4610432017,
    Close    = 2544086171,
}

local function _drawTopIcon(parent, name)
    local W = Color3.fromRGB(255,255,255)
    local z = parent.ZIndex + 1
    local function px(x,y,w,h,r)
        local f = Instance.new("Frame",parent)
        f.BackgroundColor3=W; f.BorderSizePixel=0
        f.Position=UDim2.new(0,x,0,y); f.Size=UDim2.new(0,w,0,h); f.ZIndex=z
        if r and r>0 then Instance.new("UICorner",f).CornerRadius=UDim.new(0,r) end
    end
    local function cpx(x,y,w,h,col)
        local f = Instance.new("Frame",parent)
        f.BackgroundColor3=col; f.BorderSizePixel=0
        f.Position=UDim2.new(0,x,0,y); f.Size=UDim2.new(0,w,0,h); f.ZIndex=z+1
        Instance.new("UICorner",f).CornerRadius=UDim.new(1,0)
    end

    if name=="Theme" then
        -- Paleta: anel branco + buraco + 3 pontos de cor
        local ring=Instance.new("Frame",parent); ring.BackgroundColor3=W; ring.BorderSizePixel=0
        ring.AnchorPoint=Vector2.new(0.5,0.5); ring.Position=UDim2.new(0.5,0,0.5,0)
        ring.Size=UDim2.new(0,14,0,14); ring.ZIndex=z
        Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
        local hole=Instance.new("Frame",ring); hole.BackgroundColor3=parent.BackgroundColor3
        hole.BorderSizePixel=0; hole.AnchorPoint=Vector2.new(0.5,0.5)
        hole.Position=UDim2.new(0.5,0,0.5,0); hole.Size=UDim2.new(0,6,0,6); hole.ZIndex=z+1
        Instance.new("UICorner",hole).CornerRadius=UDim.new(1,0)
        cpx(3,2,3,3,Color3.fromRGB(255,90,90))
        cpx(8,2,3,3,Color3.fromRGB(255,210,50))
        cpx(3,8,3,3,Color3.fromRGB(80,200,255))
        -- cabo do pincel
        px(10,14,3,6,1)

    elseif name=="Minimize" then
        -- Traço horizontal grosso (—)
        px(4,10,14,3,2)

    elseif name=="Maximize" then
        -- 4 setas apontando para fora (expand)
        -- ↖ canto superior esquerdo
        px(3,3,6,2,0); px(3,3,2,6,0)
        -- ↗ canto superior direito
        px(13,3,6,2,0); px(17,3,2,6,0)
        -- ↙ canto inferior esquerdo
        px(3,17,6,2,0); px(3,13,2,6,0)
        -- ↘ canto inferior direito
        px(13,17,6,2,0); px(17,13,2,6,0)

    elseif name=="Close" then
        -- X: dois traços diagonais de 2px de espessura
        for i=0,8 do
            px(4+i, 4+i, 2,2,0)   -- diagonal \
            px(14-i,4+i, 2,2,0)   -- diagonal /
        end
    end
end

local _tbX = -10
for i = #_topBtnCfg, 1, -1 do
    local d = _topBtnCfg[i]
    local circ = Instance.new("Frame", TopBar)
    circ.Name = d.name.."Btn"
    circ.BackgroundColor3 = d.bgN
    circ.BorderSizePixel = 0; circ.ZIndex = 5
    circ.AnchorPoint = Vector2.new(1, 0.5)
    circ.Position = UDim2.new(1, _tbX, 0.5, 0)
    circ.Size = UDim2.new(0, 22, 0, 22)
    Instance.new("UICorner", circ).CornerRadius = UDim.new(1, 0)
    _drawTopIcon(circ, d.name)
    local btn = Instance.new("TextButton", circ)
    btn.Name = d.name; btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1,4,1,4); btn.Position = UDim2.new(0,-2,0,-2)
    btn.Text = ""; btn.ZIndex = 7
    btn.AutoButtonColor = false
    btn.MouseEnter:Connect(function()
        TweenService:Create(circ,TweenInfo.new(0.12),{BackgroundColor3=d.bgH, Size=UDim2.new(0,24,0,24)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(circ,TweenInfo.new(0.15),{BackgroundColor3=d.bgN, Size=UDim2.new(0,22,0,22)}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(circ,TweenInfo.new(0.08),{Size=UDim2.new(0,18,0,18)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(circ,TweenInfo.new(0.12,Enum.EasingStyle.Back),{Size=UDim2.new(0,22,0,22)}):Play()
        if _topBtnSounds[d.name] then
            task.spawn(function()
                pcall(function()
                    local snd = Instance.new("Sound")
                    snd.SoundId = "rbxassetid://"..tostring(_topBtnSounds[d.name])
                    snd.Volume = 0.4; snd.RollOffMaxDistance = 0
                    snd.Parent = SoundService
                    if not snd.IsLoaded then snd.Loaded:Wait() end
                    snd:Play()
                    game:GetService("Debris"):AddItem(snd, 3)
                end)
            end)
        end
    end)
    TopBtns[d.name] = btn
    _tbX = _tbX - 30
end


-- ══════════════════════════════════════════════════════
--  SEARCH BAR — Voidware Style
-- ══════════════════════════════════════════════════════
local SearchFrame = Instance.new("Frame", MainFrame)
SearchFrame.Name = "SearchFrame"
SearchFrame.BackgroundColor3 = VD_SIDEBAR
SearchFrame.BorderSizePixel = 0
SearchFrame.Position = UDim2.new(0, 0, 0, 50)
SearchFrame.Size = UDim2.new(0, 175, 0, 44)
SearchFrame.ZIndex = 3
-- Fix cantos inferiores
local sfFix = Instance.new("Frame", SearchFrame)
sfFix.BackgroundColor3 = VD_SIDEBAR; sfFix.BorderSizePixel = 0
sfFix.Position = UDim2.new(0,0,0,0); sfFix.Size = UDim2.new(1,0,0.5,0); sfFix.ZIndex = 3
-- Linha separadora inferior sutil
local SFLine = Instance.new("Frame", SearchFrame)
SFLine.BackgroundColor3 = VD_DIVIDER; SFLine.BackgroundTransparency = 0.6
SFLine.BorderSizePixel = 0
SFLine.Position = UDim2.new(0,0,1,-1); SFLine.Size = UDim2.new(1,0,0,1); SFLine.ZIndex = 4

local SearchBg = Instance.new("Frame", SearchFrame)
SearchBg.BackgroundColor3 = Color3.fromRGB(44,28,72)
SearchBg.BorderSizePixel = 0
SearchBg.Position = UDim2.new(0,8,0.5,-12)
SearchBg.Size = UDim2.new(1,-16,0,24)
SearchBg.ZIndex = 4
Instance.new("UICorner", SearchBg).CornerRadius = UDim.new(0,8)
local SearchBgS = Instance.new("UIStroke", SearchBg)
SearchBgS.Color = VD_STROKE; SearchBgS.Thickness = 1; SearchBgS.Transparency = 0.7

local SearchIcon = Instance.new("TextLabel", SearchBg)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Position = UDim2.new(0,5,0,0); SearchIcon.Size = UDim2.new(0,18,1,0)
SearchIcon.Font = Enum.Font.GothamBold; SearchIcon.Text = "🔍"
SearchIcon.TextSize = 11; SearchIcon.ZIndex = 5

local SearchBox = Instance.new("TextBox", SearchBg)
SearchBox.BackgroundTransparency = 1
SearchBox.Position = UDim2.new(0,22,0,0); SearchBox.Size = UDim2.new(1,-28,1,0)
SearchBox.Font = Enum.Font.Gotham
SearchBox.PlaceholderText = "Buscar..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(120,100,155)
SearchBox.Text = ""; SearchBox.TextColor3 = VD_TEXT
SearchBox.TextSize = 10; SearchBox.ZIndex = 5
SearchBox.ClearTextOnFocus = false

-- ══════════════════════════════════════════════════════
--  SIDEBAR — Voidware Style
-- ══════════════════════════════════════════════════════
local SideBar = Instance.new("ScrollingFrame", MainFrame)
SideBar.Name = "SideBar"; SideBar.BackgroundColor3 = VD_SIDEBAR
SideBar.Position = UDim2.new(0,0,0,94); SideBar.Size = UDim2.new(0,175,1,-132)
SideBar.BorderSizePixel = 0; SideBar.ScrollBarThickness = 0
SideBar.AutomaticCanvasSize = Enum.AutomaticSize.Y; SideBar.CanvasSize = UDim2.new(0,0,0,0); SideBar.ZIndex = 3
SideBar.ClipsDescendants = true
local SideList = Instance.new("UIListLayout", SideBar)
SideList.Padding = UDim.new(0,2); SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SidePad = Instance.new("UIPadding", SideBar)
SidePad.PaddingTop = UDim.new(0,8); SidePad.PaddingLeft = UDim.new(0,8)
SidePad.PaddingRight = UDim.new(0,8); SidePad.PaddingBottom = UDim.new(0,8)

-- Linha separadora vertical sutil entre sidebar e content
local Divider = Instance.new("Frame", MainFrame)
Divider.BackgroundColor3 = VD_DIVIDER; Divider.BackgroundTransparency = 0.7
Divider.BorderSizePixel = 0
Divider.Position = UDim2.new(0,175,0,50); Divider.Size = UDim2.new(0,1,1,-50); Divider.ZIndex = 3

-- ══════════════════════════════════════════════════════
--  CONTENT AREA — Voidware
-- ══════════════════════════════════════════════════════
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Name = "ContentArea"; ContentArea.BackgroundColor3 = VD_BG
ContentArea.Position = UDim2.new(0,176,0,50); ContentArea.Size = UDim2.new(1,-176,1,-50)
ContentArea.BorderSizePixel = 0; ContentArea.ZIndex = 3; ContentArea.ClipsDescendants = true

-- ══════════════════════════════════════════════════════
--  FOOTER — Voidware
-- ══════════════════════════════════════════════════════
local Footer = Instance.new("Frame", MainFrame)
Footer.BackgroundColor3 = VD_SIDEBAR; Footer.BorderSizePixel = 0
Footer.Position = UDim2.new(0,0,1,-38); Footer.Size = UDim2.new(0,175,0,38); Footer.ZIndex = 4
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 12)
-- Linha topo do footer
local FooterTopLine = Instance.new("Frame", Footer)
FooterTopLine.BackgroundColor3 = VD_DIVIDER
FooterTopLine.BackgroundTransparency = 0.6
FooterTopLine.BorderSizePixel = 0
FooterTopLine.Position = UDim2.new(0,0,0,0)
FooterTopLine.Size = UDim2.new(1,0,0,1)
FooterTopLine.ZIndex = 5

local AvatarBg = Instance.new("Frame", Footer)
AvatarBg.BackgroundColor3 = VD_TAB_ACT
AvatarBg.Position = UDim2.new(0,8,0.5,-12); AvatarBg.Size = UDim2.new(0,24,0,24); AvatarBg.ZIndex = 5
Instance.new("UICorner", AvatarBg).CornerRadius = UDim.new(1,0)
local AvatarImg = Instance.new("ImageLabel", AvatarBg)
AvatarImg.BackgroundTransparency = 1; AvatarImg.Size = UDim2.new(1,0,1,0)
AvatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(Player.UserId).."&width=48&height=48&format=png"
AvatarImg.ZIndex = 6; Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1,0)

local OnlineDot = Instance.new("Frame", Footer)
OnlineDot.BackgroundColor3 = Color3.fromRGB(87,242,135); OnlineDot.BorderSizePixel = 0
OnlineDot.Position = UDim2.new(0,24,0.5,3); OnlineDot.Size = UDim2.new(0,8,0,8); OnlineDot.ZIndex = 6
Instance.new("UICorner", OnlineDot).CornerRadius = UDim.new(1,0)

local FName = Instance.new("TextLabel", Footer)
FName.BackgroundTransparency = 1; FName.Position = UDim2.new(0,40,0,5)
FName.Size = UDim2.new(1,-48,0,14); FName.Font = Enum.Font.GothamBold
FName.Text = Player.DisplayName; FName.TextColor3 = VD_TEXT
FName.TextSize = 10; FName.TextXAlignment = Enum.TextXAlignment.Left
FName.TextTruncate = Enum.TextTruncate.AtEnd; FName.ZIndex = 5

local FTag = Instance.new("TextLabel", Footer)
FTag.BackgroundTransparency = 1; FTag.Position = UDim2.new(0,40,0,20)
FTag.Size = UDim2.new(1,-48,0,12); FTag.Font = Enum.Font.Gotham
FTag.Text = "@"..Player.Name; FTag.TextColor3 = VD_MUTED
FTag.TextSize = 9; FTag.TextXAlignment = Enum.TextXAlignment.Left
FTag.TextTruncate = Enum.TextTruncate.AtEnd; FTag.ZIndex = 5

-- ── Idioma no Footer ──
local FLangFrame = Instance.new("Frame", Footer)
FLangFrame.BackgroundColor3 = VD_ROW
FLangFrame.BackgroundTransparency = 0.5
FLangFrame.BorderSizePixel = 0
FLangFrame.AnchorPoint = Vector2.new(1,0.5)
FLangFrame.Position = UDim2.new(1,-6,0.5,0)
FLangFrame.Size = UDim2.new(0,0,0,20)
FLangFrame.AutomaticSize = Enum.AutomaticSize.X
FLangFrame.ZIndex = 6
Instance.new("UICorner",FLangFrame).CornerRadius = UDim.new(0,5)
local flPad = Instance.new("UIPadding",FLangFrame)
flPad.PaddingLeft=UDim.new(0,5); flPad.PaddingRight=UDim.new(0,5)

local FLangLbl = Instance.new("TextLabel", FLangFrame)
FLangLbl.BackgroundTransparency=1
FLangLbl.Size=UDim2.new(0,0,1,0)
FLangLbl.AutomaticSize = Enum.AutomaticSize.X
FLangLbl.Font=Enum.Font.GothamBold
FLangLbl.Text = currentLang.flag .. " " .. currentLang.short
FLangLbl.TextColor3=VD_TEXT; FLangLbl.TextSize=8; FLangLbl.ZIndex=7

-- Registra referência para atualizar
langFooterLabel = FLangLbl

-- ══════════════════════════════════════════════════════
--  PAGES
-- ══════════════════════════════════════════════════════
local Pages = {}
-- Voidware accent (scrollbar, etc.)
local C_ACCENT   = Color3.fromRGB(148, 112, 220)  -- violet accent
local C_ICON_IDLE   = VD_MUTED
local C_ICON_ACTIVE = VD_TEXT

local TabConfig = {
    {key="Info",          label="Info",             trKey="tabInfo"},
    {key="Status",        label="Status",           trKey="tabStatus"},
    {key="Farm",          label="Farm",             trKey="tabFarm"},
    {key="Teleportar",    label="Teleportar",       trKey="tabTeleportar"},
    {key="Esp",           label="ESP",              trKey="tabEsp"},
    {key="Bring",         label="Bring",            trKey="tabBring"},
    {key="AvancadoFarm",  label="Avançado Farm",    trKey="tabAvFarm"},
    {key="Player",        label="Player",           trKey="tabPlayer"},
    {key="Configuracoes", label="Configurações",    trKey="tabConfig"},
    {key="AvancadoFuncoes",label="Avançado Funcoes",trKey="tabAvFunc"},
    {key="Atualizacao",   label="Atualização",     trKey="tabAtualizacao"},
}
local GroupConfig = {
    {label="GERAL",   trKey="groupGeral",   keys={"Info","Status"}},
    {label="COMBATE", trKey="groupCombate", keys={"Farm","Teleportar","Esp","Bring","AvancadoFarm"}},
    {label="EXTRA",   trKey="groupExtra",   keys={"Player","Configuracoes","AvancadoFuncoes","Atualizacao"}},
}

for _, t in ipairs(TabConfig) do
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Name = t.key.."Page"; page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1; page.Visible = false
    page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = C_ACCENT
    page.BorderSizePixel = 0; page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0,0,0,0); page.ZIndex = 4
    local pp = Instance.new("UIPadding", page)
    pp.PaddingTop = UDim.new(0,12); pp.PaddingLeft = UDim.new(0,12)
    pp.PaddingRight = UDim.new(0,12); pp.PaddingBottom = UDim.new(0,60)
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0,4); pl.SortOrder = Enum.SortOrder.LayoutOrder
    -- Spacer no fim para garantir scroll completo (fix AutomaticCanvasSize bug)
    local _spacer = Instance.new("Frame", page)
    _spacer.BackgroundTransparency = 1; _spacer.BorderSizePixel = 0
    _spacer.Size = UDim2.new(1,0,0,48); _spacer.LayoutOrder = 99999
    Pages[t.key] = page
end

-- ══════════════════════════════════════════════════════
-- ABAS SYSTEM
-- ══════════════════════════════════════════════════════
local allTabs = {}; local currentTab = nil
local selectTab

do -- bloco de construção de tabs (mkRect, mkCircle, etc. — usados apenas aqui)
local function mkRect(parent,x,y,w,h,color,radius)
    local f=Instance.new("Frame",parent); f.BackgroundColor3=color or C_ICON_IDLE
    f.BorderSizePixel=0; f.Position=UDim2.new(0,x,0,y); f.Size=UDim2.new(0,w,0,h)
    f.ZIndex=parent.ZIndex+1
    if radius then Instance.new("UICorner",f).CornerRadius=UDim.new(0,radius) end
    return f
end
local function mkCircle(parent,x,y,r,color) return mkRect(parent,x-r,y-r,r*2,r*2,color,r*2) end

local function createTabIcon(parent,key)
    local ic = C_ICON_IDLE
    local ibg = Color3.fromRGB(18,10,36)
    local cont = Instance.new("Frame",parent); cont.BackgroundTransparency=1; cont.BorderSizePixel=0
    cont.Position=UDim2.new(0,8,0.5,-10); cont.Size=UDim2.new(0,20,0,20)
    cont.ZIndex=parent.ZIndex+2; cont.ClipsDescendants=false
    local parts={}
    local function p(f) table.insert(parts,f); return f end
    if key=="Info" then
        -- Documento com linhas de texto
        p(mkRect(cont,3,1,14,17,ic,2))
        local bg2=mkRect(cont,4,2,12,15,ibg,1); bg2.ZIndex=cont.ZIndex+1
        p(mkRect(cont,6,5,8,2,ic,1))
        p(mkRect(cont,6,9,8,2,ic,1))
        p(mkRect(cont,6,13,5,2,ic,1))
        -- Dobra canto superior direito
        p(mkRect(cont,13,1,4,4,ibg,0))
        p(mkRect(cont,13,1,4,1,ic,0))
        p(mkRect(cont,16,1,1,4,ic,0))
    elseif key=="Status" then
        -- Gráfico de barras crescendo
        p(mkRect(cont,1,14,4,6,ic,1))
        p(mkRect(cont,7,9,4,11,ic,1))
        p(mkRect(cont,13,4,4,16,ic,1))
        -- Linha base
        p(mkRect(cont,0,19,20,2,ic,0))
        -- Ponto no topo da barra maior
        p(mkCircle(cont,15,3,2,Color3.fromRGB(120,255,160)))
    elseif key=="Farm" then
        -- Árvore: tronco + 3 camadas de folhas
        p(mkRect(cont,8,15,4,5,Color3.fromRGB(140,80,30),1))
        p(mkRect(cont,4,11,12,6,ic,2))
        p(mkRect(cont,5,7,10,5,ic,2))
        p(mkRect(cont,6,3,8,5,ic,2))
        p(mkCircle(cont,10,3,3,ic))
    elseif key=="Esp" then
        -- Olho estilizado
        p(mkRect(cont,1,7,18,7,ic,9))
        local eyeInner=mkRect(cont,2,8,16,5,ibg,8); eyeInner.ZIndex=cont.ZIndex+1
        p(mkCircle(cont,10,10,4,ic))
        local pupil=mkCircle(cont,10,10,2,ibg); pupil.ZIndex=cont.ZIndex+3
        p(mkCircle(cont,11,9,1,Color3.fromRGB(255,240,80)))
        -- Cílios/sobrancelha
        p(mkRect(cont,4,5,2,3,ic,1))
        p(mkRect(cont,9,4,2,3,ic,1))
        p(mkRect(cont,14,5,2,3,ic,1))
    elseif key=="Bring" then
        -- Ímã em U
        p(mkRect(cont,2,2,5,13,ic,2))
        p(mkRect(cont,13,2,5,13,ic,2))
        p(mkRect(cont,2,2,16,6,ic,3))
        local mbg=mkRect(cont,4,4,12,4,ibg,1); mbg.ZIndex=cont.ZIndex+1
        -- Pólos coloridos
        p(mkRect(cont,2,14,5,4,Color3.fromRGB(255,60,60),2))
        p(mkRect(cont,13,14,5,4,Color3.fromRGB(60,140,255),2))
        -- Faíscas
        p(mkCircle(cont,10,17,1,Color3.fromRGB(255,220,60)))
    elseif key=="AvancadoFarm" then
        -- Raio/trovão
        p(mkRect(cont,10,0,5,8,ic,1))
        p(mkRect(cont,5,7,10,2,ic,0))
        p(mkRect(cont,5,8,8,8,ic,1))
        p(mkRect(cont,3,15,8,2,ic,0))
        p(mkRect(cont,3,16,5,4,ic,1))
        -- Brilho
        p(mkCircle(cont,15,3,2,Color3.fromRGB(255,220,0)))
        p(mkCircle(cont,4,18,1,Color3.fromRGB(255,220,0)))
    elseif key=="Player" then
        -- Personagem: cabeça + corpo + braços
        p(mkCircle(cont,10,5,5,ic))
        local face=mkCircle(cont,10,5,3,ibg); face.ZIndex=cont.ZIndex+1
        p(mkRect(cont,6,11,8,8,ic,2))
        -- Braços
        p(mkRect(cont,1,11,5,3,ic,2))
        p(mkRect(cont,14,11,5,3,ic,2))
        -- Pernas
        p(mkRect(cont,6,18,3,3,ic,1))
        p(mkRect(cont,11,18,3,3,ic,1))
    elseif key=="Configuracoes" then
        -- Engrenagem mais definida
        p(mkCircle(cont,10,10,5,ic))
        local ci=mkCircle(cont,10,10,3,ibg); ci.ZIndex=cont.ZIndex+2
        -- Dentes da engrenagem (8 dentes)
        for _,deg in ipairs({0,45,90,135,180,225,270,315}) do
            local rad=math.rad(deg)
            local tx=10+math.cos(rad)*8-2
            local ty=10+math.sin(rad)*8-2
            p(mkRect(cont,tx,ty,4,4,ic,1))
        end
        -- Ponto central
        p(mkCircle(cont,10,10,1,Color3.fromRGB(180,140,255)))
    elseif key=="AvancadoFuncoes" then
        -- Chave inglesa
        p(mkCircle(cont,15,5,5,ic))
        local furo=mkCircle(cont,15,5,3,ibg); furo.ZIndex=cont.ZIndex+2
        p(mkRect(cont,0,12,14,4,ic,2))
        p(mkRect(cont,8,9,6,3,ic,1))
        -- Detalhe ponta
        p(mkRect(cont,0,11,4,6,ic,2))
        local pontaI=mkRect(cont,0,12,4,4,ibg,1); pontaI.ZIndex=cont.ZIndex+1
        p(mkRect(cont,0,12,2,4,ic,0))
        p(mkRect(cont,2,11,2,2,ic,0))
        p(mkRect(cont,2,16,2,2,ic,0))
    elseif key=="Teleportar" then
        -- Pin de localização
        p(mkCircle(cont,10,7,7,ic))
        local ci=mkCircle(cont,10,7,4,ibg); ci.ZIndex=cont.ZIndex+2
        p(mkCircle(cont,10,7,2,ic))
        -- Seta para baixo (ponta do pin)
        p(mkRect(cont,7,13,6,1,ic,0))
        p(mkRect(cont,8,14,4,1,ic,0))
        p(mkRect(cont,9,15,2,1,ic,0))
        p(mkRect(cont,9,16,2,2,ic,1))
        -- Ondas de sinal
        p(mkCircle(cont,10,7,6,Color3.fromRGB(100,180,255)))
        local wave2=mkCircle(cont,10,7,5,ibg); wave2.ZIndex=cont.ZIndex+1
    elseif key=="Atualizacao" then
        -- Seta circular (refresh)
        -- Arco superior
        p(mkRect(cont,3,3,14,3,ic,2))
        p(mkRect(cont,3,3,3,8,ic,2))
        p(mkRect(cont,3,8,7,3,ic,2))
        -- Arco inferior
        p(mkRect(cont,3,14,14,3,ic,2))
        p(mkRect(cont,14,9,3,8,ic,2))
        p(mkRect(cont,10,9,7,3,ic,2))
        -- Pontas das setas
        p(mkRect(cont,14,1,3,3,ic,0))
        p(mkRect(cont,17,1,3,3,ic,0))
        p(mkRect(cont,17,1,3,6,ic,0))
        p(mkRect(cont,3,14,3,3,ic,0))
        p(mkRect(cont,0,14,3,3,ic,0))
        p(mkRect(cont,0,11,3,6,ic,0))
    end
    return cont, parts
end

local function setIconColor(parts,color)
    for _,part in ipairs(parts) do if part and part.Parent then part.BackgroundColor3=color end end
end

selectTab = function(key)
    if currentTab==key then return end; currentTab=key
    for _,e in ipairs(allTabs) do
        local isThis=(e.key==key)
        -- Highlight bg (Voidware style)
        if e.actBg then
            TweenService:Create(e.actBg,TweenInfo.new(0.15),{
                BackgroundTransparency=isThis and 0.72 or 1
            }):Play()
        end
        if e.hovBg then
            TweenService:Create(e.hovBg,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play()
        end
        -- Ícone e label
        setIconColor(e.iconParts, isThis and Color3.fromRGB(255,240,255) or C_ICON_IDLE)
        TweenService:Create(e.label,TweenInfo.new(0.15),{
            TextColor3=isThis and Color3.fromRGB(255,245,255) or Color3.fromRGB(155,135,185)
        }):Play()
        if Pages[e.key] then Pages[e.key].Visible=isThis end
    end
end

local layoutOrder=0
-- ── makeGroupLabel — Voidware estilo plano ────────────────────────
local function makeGroupLabel(text, trKey, groupTabs)
    layoutOrder = layoutOrder + 1
    if layoutOrder>1 then
        local spacer=Instance.new("Frame",SideBar)
        spacer.BackgroundTransparency=1; spacer.BorderSizePixel=0
        spacer.Size=UDim2.new(1,0,0,4); spacer.LayoutOrder=layoutOrder*100
    end
    layoutOrder = layoutOrder + 1

    local header=Instance.new("Frame",SideBar)
    header.BackgroundTransparency=1; header.BorderSizePixel=0
    header.Size=UDim2.new(1,0,0,22); header.LayoutOrder=layoutOrder*100; header.ZIndex=4

    local hl=Instance.new("TextLabel",header); hl.BackgroundTransparency=1
    hl.Position=UDim2.new(0,4,0,0); hl.Size=UDim2.new(1,-8,1,0)
    hl.Font=Enum.Font.GothamBold; hl.Text=text
    hl.TextColor3=VD_MUTED; hl.TextSize=9
    hl.TextXAlignment=Enum.TextXAlignment.Left; hl.ZIndex=5
    if trKey then trackLabel(hl, trKey) end
end

-- ── makeTab — Voidware estilo flat ────────────────────
local function makeTab(cfg,groupTabs)
    layoutOrder = layoutOrder + 1; local order=layoutOrder*100

    local bg=Instance.new("Frame",SideBar); bg.Name=cfg.key.."Tab"
    bg.BackgroundTransparency=1; bg.BorderSizePixel=0
    bg.Size=UDim2.new(1,0,0,36); bg.LayoutOrder=order; bg.ZIndex=4

    -- Fundo ativo (Voidware: rounded rect levemente iluminado)
    local actBg=Instance.new("Frame",bg)
    actBg.BackgroundColor3=VD_TAB_ACT; actBg.BackgroundTransparency=1
    actBg.BorderSizePixel=0
    actBg.Size=UDim2.new(1,0,1,0); actBg.ZIndex=4
    Instance.new("UICorner",actBg).CornerRadius=UDim.new(0,8)

    -- Fundo hover
    local hovBg=Instance.new("Frame",bg)
    hovBg.BackgroundColor3=VD_ROW_HOV; hovBg.BackgroundTransparency=1
    hovBg.BorderSizePixel=0
    hovBg.Size=UDim2.new(1,0,1,0); hovBg.ZIndex=4
    Instance.new("UICorner",hovBg).CornerRadius=UDim.new(0,8)

    -- Ícone
    local icon,iconParts=createTabIcon(bg,cfg.key)
    icon.Position=UDim2.new(0,10,0.5,-10); icon.ZIndex=6

    -- Label
    local label=Instance.new("TextLabel",bg); label.BackgroundTransparency=1
    label.Position=UDim2.new(0,36,0,0); label.Size=UDim2.new(1,-40,1,0)
    label.Font=Enum.Font.GothamBold; label.Text=cfg.label
    label.TextColor3=VD_MUTED; label.TextSize=11
    label.TextXAlignment=Enum.TextXAlignment.Left
    label.TextTruncate=Enum.TextTruncate.AtEnd; label.ZIndex=6
    if cfg.trKey then trackLabel(label, cfg.trKey) end

    local btn=Instance.new("TextButton",bg); btn.BackgroundTransparency=1
    btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=7
    btn.BorderSizePixel=0; btn.AutoButtonColor=false
    btn.MouseEnter:Connect(function()
        if currentTab~=cfg.key then
            TweenService:Create(hovBg,TweenInfo.new(0.12),{BackgroundTransparency=0.85}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(hovBg,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play()
    end)
    btn.MouseButton1Click:Connect(function() selectTab(cfg.key) end)

    local entry={
        key=cfg.key, bg=bg,
        actBg=actBg, hovBg=hovBg,
        idleBadge=nil, idleS=nil, actBadge=nil,  -- compat
        icon=icon, iconParts=iconParts,
        label=label,
        bar=Instance.new("Frame")
    }
    table.insert(allTabs,entry); table.insert(groupTabs,entry)
end

local keyMap={}
for _,t in ipairs(TabConfig) do keyMap[t.key]=t end
for _,g in ipairs(GroupConfig) do
    local groupTabs={}; makeGroupLabel(g.label, g.trKey, groupTabs)
    for _,k in ipairs(g.keys) do if keyMap[k] then makeTab(keyMap[k],groupTabs) end end
end
end -- bloco de construção de tabs

-- Filtro de busca da sidebar
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local query = SearchBox.Text:lower():gsub("^%s+",""):gsub("%s+$","")
    for _, e in ipairs(allTabs) do
        if e.bg then
            if query == "" then
                e.bg.Visible = true
            else
                local tabName = (e.key):lower()
                local tabLbl  = (e.label and e.label.Text or ""):lower()
                e.bg.Visible = tabName:find(query,1,true) ~= nil or tabLbl:find(query,1,true) ~= nil
            end
        end
    end
end)



-- ══════════════════════════════════════════════════════
--  BOOST FUNCTIONS
-- ══════════════════════════════════════════════════════
pcall(function() -- [[ BOOST SYSTEM ]]
local origMaterials={}; local origTextures={}
local function UltraBooster(state)
    if state then
        pcall(function() settings().Network.IncomingReplicationLag=0; settings().Network.DataSendRate=60; settings().Network.DataReceiveRate=60 end)
        pcall(function() sethiddenproperty(Player,"MaximumSimulationRadius",math.huge); sethiddenproperty(Player,"SimulationRadius",math.huge) end)
        for _,obj in pairs(workspace:GetDescendants()) do pcall(function()
            if obj:IsA("BasePart") then
                if not origMaterials[obj] then origMaterials[obj]={M=obj.Material,C=obj.Color,R=obj.Reflectance,T=obj.Transparency} end
                obj.Material=Enum.Material.Plastic; obj.Color=Color3.fromRGB(128,128,128); obj.Reflectance=0; obj.CastShadow=false
            end
            if obj:IsA("Texture") or obj:IsA("Decal") then
                if not origTextures[obj] then origTextures[obj]=obj.Transparency end; obj.Transparency=1
            end
        end) end
        Notify.success(T("boosterOn"), T("boosterOnMsg"), 4)
    else
        for obj,p in pairs(origMaterials) do pcall(function() if obj and obj.Parent then obj.Material=p.M; obj.Color=p.C; obj.Reflectance=p.R; obj.Transparency=p.T; obj.CastShadow=true end end) end
        for obj,t in pairs(origTextures) do pcall(function() if obj and obj.Parent then obj.Transparency=t end end) end
        origMaterials={}; origTextures={}
        Notify.error(T("boosterOff"), T("boosterOffMsg"))
    end
end

local hidEffects={}
local function ForceRemoveEffects(s)
    if s then
        for _,v in pairs(Lighting:GetChildren()) do pcall(function()
            if v:IsA("PostEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                hidEffects[v]=v.Enabled; v.Enabled=false
            end
        end) end
        for _,o in pairs(workspace:GetDescendants()) do pcall(function()
            if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then
                hidEffects[o]=o.Enabled; o.Enabled=false
            end
        end) end
        Notify.success(T("remFxOn"), T("remFxOnMsg"))
    else
        for e,w in pairs(hidEffects) do pcall(function() if e and e.Parent then e.Enabled=w end end) end; hidEffects={}
        Notify.error(T("remFxOff"), T("remFxOffMsg"))
    end
end

local hidNPCs={}
local function ForceRemoveNPCs(s)
    if s then
        for _,v in pairs(workspace:GetChildren()) do pcall(function()
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(v) then
                for _,p in pairs(v:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if not hidNPCs[p] then hidNPCs[p]={T=p.Transparency,CC=p.CanCollide} end
                        p.Transparency=1; p.CanCollide=false
                    end
                end
            end
        end) end
        Notify.success(T("remNpcOn"), T("remNpcOnMsg"))
    else
        for p,d in pairs(hidNPCs) do pcall(function() if p and p.Parent then p.Transparency=d.T; p.CanCollide=d.CC end end) end; hidNPCs={}
        Notify.error(T("remNpcOff"), T("remNpcOffMsg"))
    end
end

local origSet={}
local function ForceLagCleaner(s)
    if s then pcall(function()
        origSet.Q=settings().Rendering.QualityLevel; origSet.M=settings().Rendering.MeshPartDetailLevel
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level01
        settings().Physics.AllowSleep=true
    end)
        Notify.success(T("clearLagOn"), T("clearLagOnMsg"))
    else pcall(function()
        if origSet.Q then settings().Rendering.QualityLevel=origSet.Q end
        if origSet.M then settings().Rendering.MeshPartDetailLevel=origSet.M end
    end); origSet={}
        Notify.error(T("clearLagOff"), T("clearLagOffMsg"))
    end
end

-- ══════════════════════════════════════════════════════
--  BOOST POPUP
-- ══════════════════════════════════════════════════════
local BoostPopup=Instance.new("Frame",ScreenGui); BoostPopup.Name="BoostPopup"
BoostPopup.BackgroundColor3=Color3.fromRGB(54,34,88); BoostPopup.Size=UDim2.new(0,190,0,0)
BoostPopup.Visible=false; BoostPopup.ZIndex=200; BoostPopup.ClipsDescendants=true
Instance.new("UICorner",BoostPopup).CornerRadius=UDim.new(0,12)
local bpStroke=Instance.new("UIStroke",BoostPopup); bpStroke.Color=C_ACCENT; bpStroke.Thickness=4
local bpList=Instance.new("UIListLayout",BoostPopup); bpList.Padding=UDim.new(0,5); bpList.HorizontalAlignment=Enum.HorizontalAlignment.Center
local bpPad=Instance.new("UIPadding",BoostPopup)
bpPad.PaddingTop=UDim.new(0,8); bpPad.PaddingLeft=UDim.new(0,8); bpPad.PaddingRight=UDim.new(0,8); bpPad.PaddingBottom=UDim.new(0,8)

local popupOpen=false
local function toggleBoostPopup()
    popupOpen=not popupOpen
    if popupOpen then
        local pos=TopBtns["Theme"].AbsolutePosition
        BoostPopup.Position=UDim2.new(0,pos.X-160,0,pos.Y+26)
        BoostPopup.Size=UDim2.new(0,190,0,0); BoostPopup.Visible=true
        TweenService:Create(BoostPopup,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,190,0,248)}):Play()
    else
        TweenService:Create(BoostPopup,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{Size=UDim2.new(0,190,0,0)}):Play()
        task.delay(0.19,function() BoostPopup.Visible=false end)
    end
end

local function makePopupToggle(text,callback)
    local row=Instance.new("Frame",BoostPopup); row.BackgroundColor3=Color3.fromRGB(54,34,88)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,32)
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lbl=Instance.new("TextLabel",row); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,8,0,0); lbl.Size=UDim2.new(1,-50,1,0); lbl.Font=Enum.Font.GothamSemibold
    lbl.Text=text; lbl.TextColor3=Color3.fromRGB(215,195,252); lbl.TextSize=10
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=201
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(100,80,120)
    pill.BorderSizePixel=0; pill.AnchorPoint=Vector2.new(1,0.5); pill.Position=UDim2.new(1,-8,0.5,0)
    pill.Size=UDim2.new(0,44,0,24); pill.ZIndex=201
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BorderSizePixel=0
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.ZIndex=202; knob.Size=UDim2.new(0,18,0,18); knob.Position=UDim2.new(0,13,0.5,0)
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=203
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=state and Color3.fromRGB(87,242,135) or Color3.fromRGB(100,80,120)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=state and UDim2.new(1,-13,0.5,0) or UDim2.new(0,13,0.5,0)
        }):Play()
        callback(state)
    end)
end

makePopupToggle("⚡ Booster Ultra",    UltraBooster)
makePopupToggle("🎨 Remove Effects", ForceRemoveEffects)
makePopupToggle("👻 Remover NPCs",     ForceRemoveNPCs)
makePopupToggle("🧹 Limpar Lag Total", ForceLagCleaner)

local rejBtn=Instance.new("TextButton",BoostPopup)
rejBtn.BackgroundColor3=Color3.fromRGB(200,50,55); rejBtn.BorderSizePixel=0
rejBtn.Size=UDim2.new(1,0,0,32); rejBtn.Font=Enum.Font.GothamBold
rejBtn.Text="🔄  REJOIN SERVER"; rejBtn.TextColor3=Color3.fromRGB(255,255,255); rejBtn.TextSize=11; rejBtn.ZIndex=201
trackLabel(rejBtn, "rejoinBtn")
Instance.new("UICorner",rejBtn).CornerRadius=UDim.new(0,7)
rejBtn.MouseButton1Click:Connect(function()
    Notify.warn(T("rejoinNotif"), T("rejoinMsg"))
    task.delay(1, function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,Player)
    end)
end)

-- ══════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════
-- FLOATING PD BUTTON
-- ══════════════════════════════════════════════════════
local FloatBtn=Instance.new("Frame",ScreenGui)
FloatBtn.Name="FloatBtn"; FloatBtn.Size=UDim2.new(0,68,0,68); FloatBtn.Position=UDim2.new(0.05,0,0.08,0)
FloatBtn.BackgroundColor3=Color3.fromRGB(96,66,148); FloatBtn.BorderSizePixel=0; FloatBtn.Visible=false; FloatBtn.ZIndex=100; FloatBtn.Active=true
Instance.new("UICorner",FloatBtn).CornerRadius=UDim.new(1,0)
local FloatRing=Instance.new("UIStroke",FloatBtn); FloatRing.Color=Color3.fromRGB(40,20,80); FloatRing.Thickness=3
local FloatGrad=Instance.new("UIGradient",FloatBtn)
FloatGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(190,165,245)),ColorSequenceKeypoint.new(1,Color3.fromRGB(185,120,0))})
FloatGrad.Rotation=135
local PDText=Instance.new("TextLabel",FloatBtn); PDText.BackgroundTransparency=1
PDText.Position=UDim2.new(0,0,0,0); PDText.Size=UDim2.new(1,0,1,0); PDText.Font=Enum.Font.GothamBlack
PDText.Text="🍮"; PDText.TextColor3=Color3.fromRGB(255,255,255); PDText.TextSize=30; PDText.ZIndex=105
local FloatClick=Instance.new("TextButton",FloatBtn); FloatClick.BackgroundTransparency=1
FloatClick.Size=UDim2.new(1,0,1,0); FloatClick.Text=""; FloatClick.ZIndex=110
FloatClick.MouseEnter:Connect(function()
    TweenService:Create(FloatBtn,TweenInfo.new(0.15),{Size=UDim2.new(0,74,0,74),Position=UDim2.new(0.05,-3,0.08,-3)}):Play()
end)
FloatClick.MouseLeave:Connect(function()
    TweenService:Create(FloatBtn,TweenInfo.new(0.15),{Size=UDim2.new(0,68,0,68),Position=UDim2.new(0.05,0,0.08,0)}):Play()
end)

local function showFloatBtn()
    FloatBtn.Size=UDim2.new(0,0,0,0); FloatBtn.Position=UDim2.new(0.05,34,0.08,34); FloatBtn.Visible=true
    TweenService:Create(FloatBtn,TweenInfo.new(0.38,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,68,0,68),Position=UDim2.new(0.05,0,0.08,0)}):Play()
end

FloatClick.MouseButton1Click:Connect(function()
    TweenService:Create(FloatBtn,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.05,34,0.08,34)}):Play()
    task.delay(0.22,function()
        FloatBtn.Visible=false; FloatBtn.Size=UDim2.new(0,68,0,68); FloatBtn.Position=UDim2.new(0.05,0,0.08,0)
        MainFrame.Visible=true; MainShadow.Visible=true
        MainFrame.Position=UDim2.new(0.5,-270,1.8,0); MainShadow.Position=UDim2.new(0.5,-263,1.8,10)
        TweenService:Create(MainShadow,TweenInfo.new(0.65,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-263,0.5,-175)}):Play()
        TweenService:Create(MainFrame, TweenInfo.new(0.65,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,-270,0.5,-185)}):Play()
        task.delay(0.45,function() SideBar.Visible=true; ContentArea.Visible=true; Divider.Visible=true; Footer.Visible=true end)
    end)
end)

-- ══════════════════════════════════════════════════════
--  TOPBAR BUTTON ACTIONS
-- ══════════════════════════════════════════════════════
TopBtns["Theme"].MouseButton1Click:Connect(function() toggleBoostPopup() end)

local isMinimized=false
TopBtns["Minimize"].MouseButton1Click:Connect(function()
    isMinimized=not isMinimized
    if isMinimized then
        Footer.Visible=false
        SideBar.Visible=false; ContentArea.Visible=false; Divider.Visible=false
        TweenService:Create(MainFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Size=UDim2.new(0,540,0,44)}):Play()
        TweenService:Create(MainShadow,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Size=UDim2.new(0,546,0,50)}):Play()
    else
        TweenService:Create(MainFrame,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,540,0,370)}):Play()
        TweenService:Create(MainShadow,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,546,0,376)}):Play()
        task.delay(0.22,function()
            SideBar.Visible=true; ContentArea.Visible=true; Divider.Visible=true; Footer.Visible=true
        end)
    end
end)

local isMaximized=false; local normalPos=MainFrame.Position
TopBtns["Maximize"].MouseButton1Click:Connect(function()
    isMaximized=not isMaximized
    if isMaximized then
        normalPos=MainFrame.Position
        TweenService:Create(MainFrame,TweenInfo.new(0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,760,0,500),Position=UDim2.new(0.5,-380,0.5,-250)}):Play()
        TweenService:Create(MainShadow,TweenInfo.new(0.32,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,766,0,506),Position=UDim2.new(0.5,-374,0.5,-240)}):Play()
    else
        TweenService:Create(MainFrame,TweenInfo.new(0.28,Enum.EasingStyle.Quad),{Size=UDim2.new(0,540,0,370),Position=normalPos}):Play()
        TweenService:Create(MainShadow,TweenInfo.new(0.28,Enum.EasingStyle.Quad),{Size=UDim2.new(0,546,0,376),Position=UDim2.new(normalPos.X.Scale,normalPos.X.Offset+7,normalPos.Y.Scale,normalPos.Y.Offset+10)}):Play()
    end
end)

TopBtns["Close"].MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame,TweenInfo.new(0.32,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Position=UDim2.new(0.5,-270,1.8,0)}):Play()
    TweenService:Create(MainShadow,TweenInfo.new(0.32,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Position=UDim2.new(0.5,-263,1.8,10)}):Play()
    task.delay(0.36,function()
        MainFrame.Visible=false; MainShadow.Visible=false
        SideBar.Visible=true; ContentArea.Visible=true; Divider.Visible=true; Footer.Visible=true
        showFloatBtn()
    end)
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    if not popupOpen then return end
    local mp=UserInputService:GetMouseLocation(); local ap,as=BoostPopup.AbsolutePosition,BoostPopup.AbsoluteSize
    if mp.X<ap.X or mp.X>ap.X+as.X or mp.Y<ap.Y or mp.Y>ap.Y+as.Y then toggleBoostPopup() end
end)

-- ══════════════════════════════════════════════════════
end) -- [[ BOOST SYSTEM ]]

-- ABA INFO — includes notification toggle
-- ══════════════════════════════════════════════════════
pcall(function() -- [[ INFO TAB ]]
local function copyToClipboard(text)
    pcall(function() if setclipboard then setclipboard(text) end end)
end


local infoCard=Instance.new("Frame",Pages["Info"])
infoCard.BackgroundColor3=Color3.fromRGB(54,34,88); infoCard.BorderSizePixel=0
infoCard.Size=UDim2.new(1,0,0,136); infoCard.LayoutOrder=0; infoCard.ZIndex=5
Instance.new("UICorner",infoCard).CornerRadius=UDim.new(0,12)
local infoCardStroke=Instance.new("UIStroke",infoCard)
infoCardStroke.Color=Color3.fromRGB(148,112,220); infoCardStroke.Thickness=2.5; infoCardStroke.Transparency=0.55

local infoBanner=Instance.new("Frame",infoCard)
infoBanner.BackgroundColor3=Color3.fromRGB(72,48,116); infoBanner.BorderSizePixel=0
infoBanner.Size=UDim2.new(1,0,0,54); infoBanner.ZIndex=5
Instance.new("UICorner",infoBanner).CornerRadius=UDim.new(0,12)
local banFix=Instance.new("Frame",infoBanner); banFix.BackgroundColor3=Color3.fromRGB(100,68,160)
banFix.BorderSizePixel=0; banFix.Position=UDim2.new(0,0,0.5,0); banFix.Size=UDim2.new(1,0,0.5,0); banFix.ZIndex=5
-- Gradiente no banner
local banGrad=Instance.new("UIGradient",infoBanner)
banGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,215,0)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(220,160,0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(160,90,0)),
})
-- Shine no banner
local banShine=Instance.new("Frame",infoBanner)
banShine.Size=UDim2.new(0,60,0,14); banShine.Position=UDim2.new(0,8,0,6)
banShine.BackgroundColor3=Color3.fromRGB(255,255,255); banShine.BackgroundTransparency=0.65
banShine.BorderSizePixel=0; banShine.Rotation=-4; banShine.ZIndex=6
Instance.new("UICorner",banShine).CornerRadius=UDim.new(1,0)

local bannerTitle=Instance.new("TextLabel",infoBanner)
bannerTitle.BackgroundTransparency=1; bannerTitle.Position=UDim2.new(0,62,0,0)
bannerTitle.Size=UDim2.new(1,-70,1,0); bannerTitle.Font=Enum.Font.GothamBlack
bannerTitle.Text="🍮  PudimHub"; bannerTitle.TextColor3=Color3.fromRGB(25,10,0)
bannerTitle.TextSize=15; bannerTitle.TextXAlignment=Enum.TextXAlignment.Left; bannerTitle.ZIndex=7
local banTitleS=Instance.new("UIStroke",bannerTitle)
banTitleS.Color=Color3.fromRGB(40,20,80); banTitleS.Thickness=1.5

local infoAvatarRing=Instance.new("Frame",infoCard)
infoAvatarRing.BackgroundColor3=Color3.fromRGB(148,112,220); infoAvatarRing.BorderSizePixel=0
infoAvatarRing.Position=UDim2.new(0,8,0,30); infoAvatarRing.Size=UDim2.new(0,48,0,48); infoAvatarRing.ZIndex=7
Instance.new("UICorner",infoAvatarRing).CornerRadius=UDim.new(1,0)
local avS=Instance.new("UIStroke",infoAvatarRing); avS.Color=Color3.fromRGB(15,8,30); avS.Thickness=2
local infoAvImg=Instance.new("ImageLabel",infoAvatarRing)
infoAvImg.BackgroundTransparency=1; infoAvImg.Position=UDim2.new(0,2,0,2); infoAvImg.Size=UDim2.new(1,-4,1,-4)
infoAvImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(Player.UserId).."&width=150&height=150&format=png"
infoAvImg.ZIndex=8; Instance.new("UICorner",infoAvImg).CornerRadius=UDim.new(1,0)

local infoGreenRing=Instance.new("Frame",infoCard)
infoGreenRing.BackgroundColor3=Color3.fromRGB(54,34,88); infoGreenRing.BorderSizePixel=0
infoGreenRing.Position=UDim2.new(0,42,0,64); infoGreenRing.Size=UDim2.new(0,14,0,14); infoGreenRing.ZIndex=9
Instance.new("UICorner",infoGreenRing).CornerRadius=UDim.new(1,0)
local infoGreenDot=Instance.new("Frame",infoGreenRing)
infoGreenDot.BackgroundColor3=Color3.fromRGB(87,242,135); infoGreenDot.BorderSizePixel=0
infoGreenDot.Position=UDim2.new(0,2,0,2); infoGreenDot.Size=UDim2.new(0,10,0,10); infoGreenDot.ZIndex=10
Instance.new("UICorner",infoGreenDot).CornerRadius=UDim.new(1,0)

local infoName=Instance.new("TextLabel",infoCard)
infoName.BackgroundTransparency=1; infoName.Position=UDim2.new(0,64,0,54)
infoName.Size=UDim2.new(1,-72,0,18); infoName.Font=Enum.Font.GothamBold
infoName.Text=Player.DisplayName; infoName.TextColor3=Color3.fromRGB(252,210,40)
infoName.TextSize=13; infoName.TextXAlignment=Enum.TextXAlignment.Left; infoName.ZIndex=7
local infoTag=Instance.new("TextLabel",infoCard)
infoTag.BackgroundTransparency=1; infoTag.Position=UDim2.new(0,64,0,72)
infoTag.Size=UDim2.new(1,-72,0,12); infoTag.Font=Enum.Font.Gotham
infoTag.Text="@"..Player.Name; infoTag.TextColor3=Color3.fromRGB(155,135,185)
infoTag.TextSize=10; infoTag.TextXAlignment=Enum.TextXAlignment.Left; infoTag.ZIndex=7

local infoStatus=Instance.new("Frame",infoCard)
infoStatus.BackgroundColor3=Color3.fromRGB(64,42,100); infoStatus.BorderSizePixel=0
infoStatus.Position=UDim2.new(0,8,0,90); infoStatus.Size=UDim2.new(1,-16,0,38); infoStatus.ZIndex=6
Instance.new("UICorner",infoStatus).CornerRadius=UDim.new(0,8)
local infoStatusS=Instance.new("UIStroke",infoStatus)
infoStatusS.Color=Color3.fromRGB(148,112,220); infoStatusS.Thickness=1; infoStatusS.Transparency=0.78
local infoStatusLbl=Instance.new("TextLabel",infoStatus)
infoStatusLbl.BackgroundTransparency=1; infoStatusLbl.Position=UDim2.new(0,8,0,3)
infoStatusLbl.Size=UDim2.new(1,-16,0,14); infoStatusLbl.Font=Enum.Font.GothamBold
infoStatusLbl.Text="🎮  Jogando 99 Nights in the Forest"
infoStatusLbl.TextColor3=Color3.fromRGB(87,242,135); infoStatusLbl.TextSize=10
infoStatusLbl.TextXAlignment=Enum.TextXAlignment.Left; infoStatusLbl.ZIndex=7
local infoStatusSub=Instance.new("TextLabel",infoStatus)
infoStatusSub.BackgroundTransparency=1; infoStatusSub.Position=UDim2.new(0,8,0,18)
infoStatusSub.Size=UDim2.new(1,-16,0,14); infoStatusSub.Font=Enum.Font.Gotham
infoStatusSub.Text="ID: "..tostring(game.PlaceId).."  •  Hub v5"
infoStatusSub.TextColor3=Color3.fromRGB(155,135,185); infoStatusSub.TextSize=9
infoStatusSub.TextXAlignment=Enum.TextXAlignment.Left; infoStatusSub.ZIndex=7

-- ── Linha de idioma no painel principal ──
local infoLangRow = Instance.new("Frame", infoCard)
infoLangRow.BackgroundColor3 = Color3.fromRGB(64,42,100)
infoLangRow.BackgroundTransparency = 0.2
infoLangRow.BorderSizePixel = 0
infoLangRow.Position = UDim2.new(0,8,0,136)
infoLangRow.Size = UDim2.new(1,-16,0,28)
infoLangRow.ZIndex = 6
Instance.new("UICorner",infoLangRow).CornerRadius = UDim.new(0,8)
local infoLangRowS=Instance.new("UIStroke",infoLangRow)
infoLangRowS.Color=Color3.fromRGB(148,112,220); infoLangRowS.Thickness=1; infoLangRowS.Transparency=0.78

local infoLangIcon = Instance.new("TextLabel",infoLangRow)
infoLangIcon.BackgroundTransparency=1; infoLangIcon.Position=UDim2.new(0,8,0,0)
infoLangIcon.Size=UDim2.new(0,20,1,0); infoLangIcon.Font=Enum.Font.GothamBold
infoLangIcon.Text="🌐"; infoLangIcon.TextSize=13; infoLangIcon.ZIndex=7

infoLangKeyLbl = Instance.new("TextLabel",infoLangRow)
infoLangKeyLbl.BackgroundTransparency=1; infoLangKeyLbl.Position=UDim2.new(0,30,0,0)
infoLangKeyLbl.Size=UDim2.new(0,55,1,0); infoLangKeyLbl.Font=Enum.Font.GothamBold
infoLangKeyLbl.Text="Idioma:"; infoLangKeyLbl.TextColor3=Color3.fromRGB(170,130,70)
infoLangKeyLbl.TextSize=10; infoLangKeyLbl.TextXAlignment=Enum.TextXAlignment.Left; infoLangKeyLbl.ZIndex=7

local infoLangValLbl = Instance.new("TextLabel",infoLangRow)
infoLangValLbl.BackgroundTransparency=1; infoLangValLbl.Position=UDim2.new(0,85,0,0)
infoLangValLbl.Size=UDim2.new(1,-95,1,0); infoLangValLbl.Font=Enum.Font.GothamBlack
infoLangValLbl.Text = currentLang.flag .. "  " .. currentLang.short
infoLangValLbl.TextColor3=Color3.fromRGB(148,112,220)
infoLangValLbl.TextSize=11; infoLangValLbl.TextXAlignment=Enum.TextXAlignment.Left; infoLangValLbl.ZIndex=7

-- Expande o infoCard para acomodar a linha de idioma
infoCard.Size = UDim2.new(1,0,0,172)

-- Registra referência para atualização de idioma
langInfoLabel = infoLangValLbl

-- ═══════════════════════════════════════
-- TOGGLE NOTIFICATIONS (Info tab, LO=1)
-- ═══════════════════════════════════════
local notifToggleRow = Instance.new("Frame", Pages["Info"])
notifToggleRow.BackgroundColor3   = Color3.fromRGB(60,38,96)
notifToggleRow.BorderSizePixel    = 0
notifToggleRow.Size               = UDim2.new(1,0,0,62)
notifToggleRow.LayoutOrder        = 1
notifToggleRow.ZIndex             = 5
Instance.new("UICorner", notifToggleRow).CornerRadius = UDim.new(0,10)
local ntStroke = Instance.new("UIStroke", notifToggleRow)
ntStroke.Color = Color3.fromRGB(148,112,220); ntStroke.Thickness = 1.5; ntStroke.Transparency = 0.72

-- Icon 🔔 on the left
local ntIconBg = Instance.new("Frame", notifToggleRow)
ntIconBg.BackgroundColor3   = Color3.fromRGB(148,112,220)
ntIconBg.BackgroundTransparency = 0.72
ntIconBg.BorderSizePixel    = 0
ntIconBg.Position           = UDim2.new(0,10,0.5,-18)
ntIconBg.Size               = UDim2.new(0,36,0,36)
ntIconBg.ZIndex             = 6
Instance.new("UICorner",ntIconBg).CornerRadius=UDim.new(1,0)
local ntIconS=Instance.new("UIStroke",ntIconBg)
ntIconS.Color=Color3.fromRGB(100,68,160); ntIconS.Thickness=1.5
local ntIconLbl = Instance.new("TextLabel",ntIconBg)
ntIconLbl.BackgroundTransparency=1; ntIconLbl.Size=UDim2.new(1,0,1,0)
ntIconLbl.Font=Enum.Font.GothamBold; ntIconLbl.Text="🔔"; ntIconLbl.TextSize=18; ntIconLbl.ZIndex=7

-- Texts
local ntTitle = Instance.new("TextLabel",notifToggleRow)
ntTitle.BackgroundTransparency=1; ntTitle.Position=UDim2.new(0,56,0,10)
ntTitle.Size=UDim2.new(1,-110,0,18); ntTitle.Font=Enum.Font.GothamBlack
ntTitle.Text="Notifications"; ntTitle.TextColor3=Color3.fromRGB(220,200,255)
trackLabel(ntTitle, "notifTitle")
ntTitle.TextSize=12; ntTitle.TextXAlignment=Enum.TextXAlignment.Left; ntTitle.ZIndex=6

local ntDesc = Instance.new("TextLabel",notifToggleRow)
ntDesc.BackgroundTransparency=1; ntDesc.Position=UDim2.new(0,56,0,30)
ntDesc.Size=UDim2.new(1,-110,0,24); ntDesc.Font=Enum.Font.Gotham
ntDesc.Text="Enables/disables all hub notifications"; ntDesc.TextColor3=Color3.fromRGB(160,120,70)
trackLabel(ntDesc, "notifDesc")
ntDesc.TextSize=9; ntDesc.TextXAlignment=Enum.TextXAlignment.Left; ntDesc.TextWrapped=true; ntDesc.ZIndex=6

-- Pill toggle
local ntPill = Instance.new("Frame",notifToggleRow)
ntPill.BackgroundColor3 = Color3.fromRGB(148,112,220)
ntPill.BorderSizePixel    = 0
ntPill.Position           = UDim2.new(1,-58,0.5,-13)
ntPill.Size               = UDim2.new(0,48,0,26)
ntPill.ZIndex             = 7
Instance.new("UICorner",ntPill).CornerRadius=UDim.new(1,0)
local ntPillS=Instance.new("UIStroke",ntPill)
ntPillS.Color=Color3.fromRGB(100,68,160); ntPillS.Thickness=1.5
local ntKnob = Instance.new("Frame",ntPill)
ntKnob.BackgroundColor3 = Color3.fromRGB(255,255,255); ntKnob.BorderSizePixel=0
ntKnob.Position = UDim2.new(1,-24,0.5,-11); ntKnob.Size=UDim2.new(0,22,0,22); ntKnob.ZIndex=8
Instance.new("UICorner",ntKnob).CornerRadius=UDim.new(1,0)

-- Status label (ON/OFF)
local ntStatusLbl = Instance.new("TextLabel",notifToggleRow)
ntStatusLbl.BackgroundTransparency=1; ntStatusLbl.Position=UDim2.new(1,-58,0,10)
ntStatusLbl.Size=UDim2.new(0,48,0,12); ntStatusLbl.Font=Enum.Font.GothamBold
ntStatusLbl.Text=T("notifOn"); ntStatusLbl.TextColor3=Color3.fromRGB(148,112,220)
ntStatusLbl.TextSize=8; ntStatusLbl.TextXAlignment=Enum.TextXAlignment.Center; ntStatusLbl.ZIndex=7

local ntBtn = Instance.new("TextButton",notifToggleRow)
ntBtn.BackgroundTransparency=1; ntBtn.Size=UDim2.new(1,0,1,0); ntBtn.Text=""; ntBtn.ZIndex=9
ntBtn.MouseButton1Click:Connect(function()
    notifEnabled = not notifEnabled
    local onColor   = Color3.fromRGB(148,112,220)
    local offColor  = Color3.fromRGB(64,42,100)
    TweenService:Create(ntPill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{
        BackgroundColor3 = notifEnabled and onColor or offColor
    }):Play()
    TweenService:Create(ntKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position = notifEnabled and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
        BackgroundColor3 = notifEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(100,60,140)
    }):Play()
    TweenService:Create(ntStroke,TweenInfo.new(0.2),{
        Color = notifEnabled and onColor or Color3.fromRGB(100,65,25),
        Transparency = notifEnabled and 0.45 or 0.72
    }):Play()
    TweenService:Create(ntStatusLbl,TweenInfo.new(0.15),{
        TextColor3 = notifEnabled and onColor or Color3.fromRGB(150,110,55)
    }):Play()
    ntStatusLbl.Text = notifEnabled and T("notifOn") or T("notifOff")
    ntIconBg.BackgroundTransparency = notifEnabled and 0.72 or 0.92
    -- Confirmation notification (always triggers, regardless of the toggle)
    -- To ensure feedback even when deactivated:
    if notifEnabled then
        task.delay(0.1, function()
            Notify.info(T("notifTitle"), T("notifOn").." ✓")
        end)
    else
        -- Manually triggers without checking notifEnabled
        local cfg = {type="warn", title="Notifications", msg="Notifications disabled.", duration=3}
        local type = "warn"
        if #nActive < NOTIF_CFG.MAX_VISIBLE then
            nCreateCard(cfg, type); nAddHistory(cfg, type)
        end
    end
end)

local infoSep=Instance.new("Frame",Pages["Info"])
infoSep.BackgroundColor3=Color3.fromRGB(148,112,220); infoSep.BackgroundTransparency=0.82; infoSep.BorderSizePixel=0
infoSep.Size=UDim2.new(1,0,0,1); infoSep.LayoutOrder=2; infoSep.ZIndex=5

-- ══════════════════════════════════════════════════════
-- PAINEL DE HISTÓRICO DE NOTIFICAÇÕES (aba Info, LO=3)
-- ══════════════════════════════════════════════════════
local HIST_PANEL_CONTENT_H = 220  -- altura do conteúdo quando aberto

local histPanelOuter = Instance.new("Frame", Pages["Info"])
histPanelOuter.BackgroundColor3 = Color3.fromRGB(44,28,72)
histPanelOuter.BorderSizePixel  = 0
histPanelOuter.Size             = UDim2.new(1,0,0,44)
histPanelOuter.LayoutOrder      = 3
histPanelOuter.ZIndex           = 5
histPanelOuter.ClipsDescendants = true
Instance.new("UICorner",histPanelOuter).CornerRadius = UDim.new(0,10)
local histPanelStroke = Instance.new("UIStroke",histPanelOuter)
histPanelStroke.Color = Color3.fromRGB(120,86,188); histPanelStroke.Thickness=1.5

-- ── Header clicável ──
local histHeader = Instance.new("Frame", histPanelOuter)
histHeader.BackgroundColor3 = Color3.fromRGB(16,18,26)
histHeader.BorderSizePixel  = 0
histHeader.Size             = UDim2.new(1,0,0,44)
histHeader.ZIndex           = 6
Instance.new("UICorner",histHeader).CornerRadius = UDim.new(0,10)
local histHeaderFix = Instance.new("Frame",histHeader)
histHeaderFix.BackgroundColor3=Color3.fromRGB(54,34,88); histHeaderFix.BorderSizePixel=0
histHeaderFix.Position=UDim2.new(0,0,0.5,0); histHeaderFix.Size=UDim2.new(1,0,0.5,0); histHeaderFix.ZIndex=6

-- Ícone sino
local histHIconBg = Instance.new("Frame",histHeader)
histHIconBg.BackgroundColor3=Color3.fromRGB(120,86,188); histHIconBg.BackgroundTransparency=0.75
histHIconBg.BorderSizePixel=0; histHIconBg.Position=UDim2.new(0,8,0.5,-14)
histHIconBg.Size=UDim2.new(0,28,0,28); histHIconBg.ZIndex=7
Instance.new("UICorner",histHIconBg).CornerRadius=UDim.new(1,0)
local histHIconLbl=Instance.new("TextLabel",histHIconBg)
histHIconLbl.BackgroundTransparency=1; histHIconLbl.Size=UDim2.new(1,0,1,0)
histHIconLbl.Font=Enum.Font.GothamBold; histHIconLbl.Text="🔔"; histHIconLbl.TextSize=13; histHIconLbl.ZIndex=8

-- Título
local histHTitle=Instance.new("TextLabel",histHeader)
histHTitle.BackgroundTransparency=1; histHTitle.Position=UDim2.new(0,46,0,0)
histHTitle.Size=UDim2.new(1,-170,1,0); histHTitle.Font=Enum.Font.GothamBlack
histHTitle.Text="Histórico de Notificações"; histHTitle.TextColor3=Color3.fromRGB(215,195,252)
trackLabel(histHTitle, "notifHistTitle")
histHTitle.TextSize=11; histHTitle.TextXAlignment=Enum.TextXAlignment.Left; histHTitle.ZIndex=7

-- Seta
local histHArrowFrame=Instance.new("Frame",histHeader)
histHArrowFrame.BackgroundTransparency=1; histHArrowFrame.Position=UDim2.new(1,-24,0.5,-8)
histHArrowFrame.Size=UDim2.new(0,16,0,16); histHArrowFrame.ZIndex=7
local histHArrow=Instance.new("ImageLabel",histHArrowFrame)
histHArrow.BackgroundTransparency=1; histHArrow.Size=UDim2.new(1,0,1,0)
histHArrow.Image="rbxassetid://6034818375"; histHArrow.ImageColor3=Color3.fromRGB(120,86,188)
histHArrow.ScaleType=Enum.ScaleType.Fit; histHArrow.Rotation=180; histHArrow.ZIndex=8
-- Botão clicável na seta
local histArrowBtn=Instance.new("TextButton",histHeader)
histArrowBtn.BackgroundTransparency=1
histArrowBtn.Position=UDim2.new(1,-30,0,0); histArrowBtn.Size=UDim2.new(0,30,1,0)
histArrowBtn.Text=""; histArrowBtn.ZIndex=9
histArrowBtn.MouseButton1Click:Connect(function() setHistPanelOpen(not histPanelOpen, true) end)

-- Botões de ação no header (Clear + Toggle)
local histClearBtn=Instance.new("TextButton",histHeader)
histClearBtn.BackgroundColor3=Color3.fromRGB(255,70,70); histClearBtn.BackgroundTransparency=0.75
histClearBtn.BorderSizePixel=0; histClearBtn.AnchorPoint=Vector2.new(1,0.5)
histClearBtn.Position=UDim2.new(1,-38,0.5,0); histClearBtn.Size=UDim2.new(0,52,0,24)
histClearBtn.Font=Enum.Font.GothamBold; histClearBtn.Text="🗑 Limpar"
trackLabel(histClearBtn, "notifHistClear")
histClearBtn.TextColor3=Color3.fromRGB(255,120,120); histClearBtn.TextSize=8; histClearBtn.ZIndex=8
Instance.new("UICorner",histClearBtn).CornerRadius=UDim.new(0,7)
histClearBtn.MouseEnter:Connect(function() TweenService:Create(histClearBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.5}):Play() end)
histClearBtn.MouseLeave:Connect(function() TweenService:Create(histClearBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.75}):Play() end)

-- Toggle ativo/desativo do histórico
local histTogglePill=Instance.new("Frame",histHeader)
histTogglePill.BackgroundColor3=Color3.fromRGB(87,242,135); histTogglePill.BorderSizePixel=0
histTogglePill.AnchorPoint=Vector2.new(1,0.5)
histTogglePill.Position=UDim2.new(1,-96,0.5,0); histTogglePill.Size=UDim2.new(0,32,0,18); histTogglePill.ZIndex=7
Instance.new("UICorner",histTogglePill).CornerRadius=UDim.new(1,0)
local histToggleKnob=Instance.new("Frame",histTogglePill)
histToggleKnob.BackgroundColor3=Color3.fromRGB(255,255,255); histToggleKnob.BorderSizePixel=0
histToggleKnob.Position=UDim2.new(1,-17,0.5,-7); histToggleKnob.Size=UDim2.new(0,14,0,14); histToggleKnob.ZIndex=8
Instance.new("UICorner",histToggleKnob).CornerRadius=UDim.new(1,0)
-- Botão clicável APENAS sobre o pill (NÃO cobre o header inteiro)
local histToggleBtn=Instance.new("TextButton",histHeader)
histToggleBtn.BackgroundTransparency=1
histToggleBtn.AnchorPoint=Vector2.new(1,0.5)
histToggleBtn.Position=UDim2.new(1,-88,0.5,0)
histToggleBtn.Size=UDim2.new(0,48,0,30)   -- só sobre o pill + pequena margem
histToggleBtn.Text=""; histToggleBtn.ZIndex=10   -- ZIndex alto para ficar sobre o headerBtn

-- ── Conteúdo (scroll) ──
local histContent = Instance.new("Frame", histPanelOuter)
histContent.BackgroundTransparency = 1
histContent.BorderSizePixel = 0
histContent.Position = UDim2.new(0,0,0,44)
histContent.Size     = UDim2.new(1,0,0,HIST_PANEL_CONTENT_H)
histContent.ZIndex   = 6
histContent.ClipsDescendants = true

-- Scroll frame interno
local histScroll = Instance.new("ScrollingFrame", histContent)
histScroll.Name                  = "InfoHistScroll"
histScroll.BackgroundTransparency= 1
histScroll.BorderSizePixel       = 0
histScroll.Size                  = UDim2.new(1,0,1,0)
histScroll.ZIndex                = 7
histScroll.ScrollBarThickness    = 3
histScroll.ScrollBarImageColor3  = Color3.fromRGB(120,86,188)
histScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
histScroll.CanvasSize            = UDim2.new(0,0,0,0)
local histScrollList=Instance.new("UIListLayout",histScroll)
histScrollList.Padding=UDim.new(0,4); histScrollList.SortOrder=Enum.SortOrder.LayoutOrder
local histScrollPad=Instance.new("UIPadding",histScroll)
histScrollPad.PaddingTop=UDim.new(0,8); histScrollPad.PaddingLeft=UDim.new(0,10)
histScrollPad.PaddingRight=UDim.new(0,12); histScrollPad.PaddingBottom=UDim.new(0,8)

-- Label vazio
local infoHistEmptyLbl=Instance.new("TextLabel",histScroll)
infoHistEmptyLbl.Name="InfoHistEmptyLbl"
infoHistEmptyLbl.BackgroundTransparency=1; infoHistEmptyLbl.Size=UDim2.new(1,0,0,60)
infoHistEmptyLbl.Font=Enum.Font.GothamSemibold
infoHistEmptyLbl.Text="📭  Nenhuma notificação ainda."
trackLabel(infoHistEmptyLbl, "notifHistEmpty")
infoHistEmptyLbl.TextColor3=Color3.fromRGB(120,100,155); infoHistEmptyLbl.TextSize=10
infoHistEmptyLbl.LayoutOrder=9999; infoHistEmptyLbl.ZIndex=8; infoHistEmptyLbl.Visible=true

-- Registrar referência global para nAddHistory
infoHistScrollRef = histScroll

-- ── Lógica do painel ──
local histPanelOpen = false

local function setHistPanelOpen(open, animated)
    histPanelOpen = open
    local targetH = open and (44 + HIST_PANEL_CONTENT_H) or 44
    TweenService:Create(histHArrow,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=open and 0 or 180}):Play()
    if animated then
        TweenService:Create(histPanelOuter,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,targetH)}):Play()
        TweenService:Create(histPanelStroke,TweenInfo.new(0.2),{Color=open and Color3.fromRGB(148,112,220) or Color3.fromRGB(120,86,188)}):Play()
    else
        histPanelOuter.Size=UDim2.new(1,0,0,targetH)
    end
end

-- Botão header abre/fecha — só cobre a parte esquerda (não sobrepõe os botões de ação)
local histHeaderBtn=Instance.new("TextButton",histHeader)
histHeaderBtn.BackgroundTransparency=1
histHeaderBtn.Position=UDim2.new(0,0,0,0)
histHeaderBtn.Size=UDim2.new(1,-155,1,0)   -- deixa os ~155px da direita livres para toggle+clear+seta
histHeaderBtn.Text=""; histHeaderBtn.ZIndex=8
histHeaderBtn.MouseButton1Click:Connect(function() setHistPanelOpen(not histPanelOpen, true) end)

-- Limpar histórico
histClearBtn.MouseButton1Click:Connect(function()
    for _,c in ipairs(histScroll:GetChildren()) do
        if c:IsA("Frame") then
            TweenService:Create(c,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play()
            task.delay(0.16, function() pcall(function() c:Destroy() end) end)
        end
    end
    task.delay(0.2, function()
        infoHistEmptyLbl.Visible=true; nHistLO=0
    end)
    Notify.info(T("notifHistTitle"), T("notifHistCleared"), 2.5)
end)

-- Toggle ativar/desativar histórico
histToggleBtn.MouseButton1Click:Connect(function()
    historyEnabled = not historyEnabled
    local onC  = Color3.fromRGB(87,242,135)
    local offC = Color3.fromRGB(55,60,75)
    TweenService:Create(histTogglePill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{
        BackgroundColor3 = historyEnabled and onC or offC
    }):Play()
    TweenService:Create(histToggleKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position = historyEnabled and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    }):Play()
    histHIconBg.BackgroundTransparency = historyEnabled and 0.75 or 0.9
    if historyEnabled then
        Notify.info(T("notifHistTitle"), T("notifHistOn"), 3)
    else
        local cfg={type="warn",title="Histórico",msg="Histórico desativado — notificações não serão salvas.",duration=3}
        if #nActive < NOTIF_CFG.MAX_VISIBLE then nCreateCard(cfg,"warn"); nAddHistory(cfg,"warn") end
    end
end)

local dadosHeader=Instance.new("TextButton",Pages["Info"])
dadosHeader.BackgroundColor3=Color3.fromRGB(60,38,96); dadosHeader.BorderSizePixel=0
dadosHeader.Size=UDim2.new(1,0,0,32); dadosHeader.LayoutOrder=4; dadosHeader.Text=""; dadosHeader.ZIndex=5
Instance.new("UICorner",dadosHeader).CornerRadius=UDim.new(0,8)
local dadosStroke=Instance.new("UIStroke",dadosHeader); dadosStroke.Color=Color3.fromRGB(148,112,220); dadosStroke.Thickness=1; dadosStroke.Transparency=0.82

local dadosTitleLbl=Instance.new("TextLabel",dadosHeader)
dadosTitleLbl.BackgroundTransparency=1; dadosTitleLbl.Position=UDim2.new(0,12,0,0)
dadosTitleLbl.Size=UDim2.new(1,-40,1,0); dadosTitleLbl.Font=Enum.Font.GothamBold
dadosTitleLbl.Text="Dice"; dadosTitleLbl.TextColor3=Color3.fromRGB(210,190,250)
dadosTitleLbl.TextSize=11; dadosTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; dadosTitleLbl.ZIndex=6

local dadosArrowFrame=Instance.new("Frame",dadosHeader)
dadosArrowFrame.BackgroundTransparency=1; dadosArrowFrame.Position=UDim2.new(1,-28,0.5,-8)
dadosArrowFrame.Size=UDim2.new(0,16,0,16); dadosArrowFrame.ZIndex=6
local dadosArrow=Instance.new("ImageLabel",dadosArrowFrame)
dadosArrow.BackgroundTransparency=1; dadosArrow.Size=UDim2.new(1,0,1,0)
dadosArrow.Image="rbxassetid://6034818375"; dadosArrow.ImageColor3=Color3.fromRGB(148,112,220)
dadosArrow.ScaleType=Enum.ScaleType.Fit; dadosArrow.Rotation=180; dadosArrow.ZIndex=7

local dadosContent=Instance.new("Frame",Pages["Info"])
dadosContent.BackgroundColor3=Color3.fromRGB(40,24,68); dadosContent.BorderSizePixel=0
dadosContent.Size=UDim2.new(1,0,0,0); dadosContent.LayoutOrder=5; dadosContent.ZIndex=5
dadosContent.ClipsDescendants=true
Instance.new("UICorner",dadosContent).CornerRadius=UDim.new(0,8)
local dadosStroke2=Instance.new("UIStroke",dadosContent); dadosStroke2.Color=Color3.fromRGB(148,112,220); dadosStroke2.Thickness=1; dadosStroke2.Transparency=0.85

local dadosPad=Instance.new("UIPadding",dadosContent)
dadosPad.PaddingTop=UDim.new(0,10); dadosPad.PaddingLeft=UDim.new(0,12)
dadosPad.PaddingRight=UDim.new(0,12); dadosPad.PaddingBottom=UDim.new(0,12)
local dadosList=Instance.new("UIListLayout",dadosContent)
dadosList.Padding=UDim.new(0,8); dadosList.SortOrder=Enum.SortOrder.LayoutOrder

local dadosText=Instance.new("TextLabel",dadosContent)
dadosText.BackgroundTransparency=1; dadosText.Size=UDim2.new(1,0,0,0)
dadosText.AutomaticSize=Enum.AutomaticSize.Y
dadosText.Font=Enum.Font.Gotham
dadosText.Text="This script was developed by only 1 person and is being developed by only 1 person as well. Sometimes it may take a while to update the script, sometimes it may be quick, and sometimes it may be very slow. However, I will always try to go as fast as possible, so the delay may be related to other factors. I just wanted to let you know this in case it is outdated and takes a while — this will give you a better idea of ​​the reason for the delay, because 1 person developing a script of this size ALONE is difficult and time-consuming, even with free time sometimes."
dadosText.TextColor3=Color3.fromRGB(160,120,65); dadosText.TextSize=9
dadosText.TextWrapped=true; dadosText.TextXAlignment=Enum.TextXAlignment.Left
dadosText.TextYAlignment=Enum.TextYAlignment.Top; dadosText.ZIndex=6; dadosText.LayoutOrder=0

local dadosBtnsRow=Instance.new("Frame",dadosContent)
dadosBtnsRow.BackgroundTransparency=1; dadosBtnsRow.BorderSizePixel=0
dadosBtnsRow.Size=UDim2.new(1,0,0,30); dadosBtnsRow.LayoutOrder=1; dadosBtnsRow.ZIndex=6
local dadosBtnsList=Instance.new("UIListLayout",dadosBtnsRow)
dadosBtnsList.FillDirection=Enum.FillDirection.Horizontal; dadosBtnsList.Padding=UDim.new(0,8)
dadosBtnsList.SortOrder=Enum.SortOrder.LayoutOrder

local function makeDadosBtn(parent,txt,cor,callback,order)
    local btn=Instance.new("TextButton",parent)
    btn.BackgroundColor3=cor; btn.BackgroundTransparency=0.15; btn.BorderSizePixel=0
    btn.Size=UDim2.new(0,120,0,28); btn.Font=Enum.Font.GothamBold
    btn.Text=txt; btn.TextColor3=Color3.fromRGB(255,255,255); btn.TextSize=9
    btn.LayoutOrder=order; btn.ZIndex=7
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
    local bs=Instance.new("UIStroke",btn); bs.Color=cor; bs.Thickness=1; bs.Transparency=0.5
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.15}):Play() end)
    btn.MouseButton1Click:Connect(function()
        callback()
        local orig=btn.Text; btn.Text=T("copied")
        task.delay(1.5,function() btn.Text=orig end)
    end)
end

makeDadosBtn(dadosBtnsRow,"🔗 Discord Link",Color3.fromRGB(120,86,188),function()
    copyToClipboard("No link currently available")
end,0)
makeDadosBtn(dadosBtnsRow,"📋CopyID",Color3.fromRGB(60,160,80),function()
    copyToClipboard(tostring(game.JobId))
    Notify.info(T("copied"), T("srvTitle"))
end,1)

local dataOpen=false
local DATA_H=160

dadosHeader.MouseButton1Click:Connect(function()
    dataOpen=not dataOpen
    TweenService:Create(dadosArrow,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=dataOpen and 0 or 180}):Play()
    TweenService:Create(dadosContent,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,dataOpen and DATA_H or 0)}):Play()
    TweenService:Create(dadosStroke,TweenInfo.new(0.2),{Color=C_ACCENT,Transparency=dataOpen and 0.45 or 0.82}):Play()
end)

-- ══════════════════════════════════════════════════════
-- SISTEMA DE IDIOMAS — Seção dropdown na aba Info
-- ══════════════════════════════════════════════════════
local LANG_DROP_H = (#LANGUAGES * 38) + 16  -- altura do dropdown

local langSep=Instance.new("Frame",Pages["Info"])
langSep.BackgroundColor3=Color3.fromRGB(148,112,220); langSep.BackgroundTransparency=0.82; langSep.BorderSizePixel=0
langSep.Size=UDim2.new(1,0,0,1); langSep.LayoutOrder=6; langSep.ZIndex=5

-- Header clicável "Sistema de idiomas"
local langHeader=Instance.new("TextButton",Pages["Info"])
langHeader.BackgroundColor3=Color3.fromRGB(46,28,76); langHeader.BorderSizePixel=0
langHeader.Size=UDim2.new(1,0,0,40); langHeader.LayoutOrder=7; langHeader.Text=""; langHeader.ZIndex=5
Instance.new("UICorner",langHeader).CornerRadius=UDim.new(0,10)
local langHeaderStroke=Instance.new("UIStroke",langHeader)
langHeaderStroke.Color=Color3.fromRGB(148,112,220); langHeaderStroke.Thickness=1.8; langHeaderStroke.Transparency=0.45

-- Ícone globo
local lhIconBg=Instance.new("Frame",langHeader)
lhIconBg.BackgroundColor3=Color3.fromRGB(148,112,220); lhIconBg.BackgroundTransparency=0.72
lhIconBg.BorderSizePixel=0; lhIconBg.Position=UDim2.new(0,8,0.5,-14)
lhIconBg.Size=UDim2.new(0,28,0,28); lhIconBg.ZIndex=6
Instance.new("UICorner",lhIconBg).CornerRadius=UDim.new(1,0)
local lhIconLbl=Instance.new("TextLabel",lhIconBg)
lhIconLbl.BackgroundTransparency=1; lhIconLbl.Size=UDim2.new(1,0,1,0)
lhIconLbl.Font=Enum.Font.GothamBold; lhIconLbl.Text="🌐"; lhIconLbl.TextSize=14; lhIconLbl.ZIndex=7

-- Título
local lhTitleLbl=Instance.new("TextLabel",langHeader)
lhTitleLbl.BackgroundTransparency=1; lhTitleLbl.Position=UDim2.new(0,46,0,0)
lhTitleLbl.Size=UDim2.new(1,-100,1,0); lhTitleLbl.Font=Enum.Font.GothamBlack
lhTitleLbl.Text="Sistema de idiomas"
lhTitleLbl.TextColor3=Color3.fromRGB(220,200,255); lhTitleLbl.TextSize=12
lhTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; lhTitleLbl.ZIndex=6

-- Label idioma atual
local lhCurrentLbl=Instance.new("TextLabel",langHeader)
lhCurrentLbl.BackgroundTransparency=1; lhCurrentLbl.Position=UDim2.new(1,-88,0,0)
lhCurrentLbl.Size=UDim2.new(0,60,1,0); lhCurrentLbl.Font=Enum.Font.GothamBold
lhCurrentLbl.Text=currentLang.flag.." "..currentLang.short
lhCurrentLbl.TextColor3=Color3.fromRGB(148,112,220); lhCurrentLbl.TextSize=10
lhCurrentLbl.TextXAlignment=Enum.TextXAlignment.Right; lhCurrentLbl.ZIndex=6

-- Seta
local lhArrowFrame=Instance.new("Frame",langHeader)
lhArrowFrame.BackgroundTransparency=1; lhArrowFrame.Position=UDim2.new(1,-26,0.5,-8)
lhArrowFrame.Size=UDim2.new(0,16,0,16); lhArrowFrame.ZIndex=6
local lhArrow=Instance.new("ImageLabel",lhArrowFrame)
lhArrow.BackgroundTransparency=1; lhArrow.Size=UDim2.new(1,0,1,0)
lhArrow.Image="rbxassetid://6034818375"; lhArrow.ImageColor3=Color3.fromRGB(148,112,220)
lhArrow.ScaleType=Enum.ScaleType.Fit; lhArrow.Rotation=180; lhArrow.ZIndex=7

-- Conteúdo dropdown (lista de idiomas)
local langDropContent=Instance.new("ScrollingFrame",Pages["Info"])
langDropContent.BackgroundColor3=Color3.fromRGB(10,5,20); langDropContent.BorderSizePixel=0
langDropContent.Size=UDim2.new(1,0,0,0); langDropContent.LayoutOrder=8; langDropContent.ZIndex=5
langDropContent.ClipsDescendants=true; langDropContent.ScrollBarThickness=3
langDropContent.ScrollBarImageColor3=Color3.fromRGB(148,112,220)
langDropContent.AutomaticCanvasSize=Enum.AutomaticSize.None
langDropContent.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",langDropContent).CornerRadius=UDim.new(0,10)
local ldStroke=Instance.new("UIStroke",langDropContent); ldStroke.Color=Color3.fromRGB(148,112,220); ldStroke.Thickness=1.5; ldStroke.Transparency=0.65

local ldPad=Instance.new("UIPadding",langDropContent)
ldPad.PaddingTop=UDim.new(0,8); ldPad.PaddingLeft=UDim.new(0,10)
ldPad.PaddingRight=UDim.new(0,10); ldPad.PaddingBottom=UDim.new(0,8)
local ldList=Instance.new("UIListLayout",langDropContent)
ldList.Padding=UDim.new(0,4); ldList.SortOrder=Enum.SortOrder.LayoutOrder

local langDropOpen = false
-- Criar botão de idioma
for idx, lang in ipairs(LANGUAGES) do
    local isSelected = (lang.code == currentLang.code)
    local lBtn=Instance.new("TextButton",langDropContent)
    lBtn.BackgroundColor3=isSelected and Color3.fromRGB(148,112,220) or Color3.fromRGB(64,42,100)
    lBtn.BackgroundTransparency=isSelected and 0.25 or 0.15
    lBtn.BorderSizePixel=0; lBtn.Size=UDim2.new(1,0,0,34)
    lBtn.Text=""; lBtn.LayoutOrder=idx; lBtn.ZIndex=6
    Instance.new("UICorner",lBtn).CornerRadius=UDim.new(0,8)
    if isSelected then
        local lbStroke=Instance.new("UIStroke",lBtn); lbStroke.Color=Color3.fromRGB(148,112,220); lbStroke.Thickness=1.8
    end

    -- Flag
    local lbFlag=Instance.new("TextLabel",lBtn)
    lbFlag.BackgroundTransparency=1; lbFlag.Position=UDim2.new(0,8,0,0)
    lbFlag.Size=UDim2.new(0,28,1,0); lbFlag.Font=Enum.Font.GothamBold
    lbFlag.Text=lang.flag; lbFlag.TextSize=16; lbFlag.ZIndex=7

    -- Nome do idioma
    local lbName=Instance.new("TextLabel",lBtn)
    lbName.BackgroundTransparency=1; lbName.Position=UDim2.new(0,40,0,0)
    lbName.Size=UDim2.new(1,-90,1,0); lbName.Font=Enum.Font.GothamBold
    lbName.Text=lang.name; lbName.TextColor3=isSelected and Color3.fromRGB(15,8,30) or Color3.fromRGB(240,210,150)
    lbName.TextSize=10; lbName.TextXAlignment=Enum.TextXAlignment.Left; lbName.ZIndex=7

    -- Código
    local lbCode=Instance.new("TextLabel",lBtn)
    lbCode.BackgroundTransparency=1; lbCode.Position=UDim2.new(1,-58,0,0)
    lbCode.Size=UDim2.new(0,50,1,0); lbCode.Font=Enum.Font.GothamBold
    lbCode.Text=lang.short; lbCode.TextColor3=isSelected and Color3.fromRGB(120,86,188) or Color3.fromRGB(140,105,50)
    lbCode.TextSize=9; lbCode.TextXAlignment=Enum.TextXAlignment.Right; lbCode.ZIndex=7

    lBtn.MouseEnter:Connect(function()
        if lang.code~=currentLang.code then
            TweenService:Create(lBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,40,100),BackgroundTransparency=0}):Play()
        end
    end)
    lBtn.MouseLeave:Connect(function()
        if lang.code~=currentLang.code then
            TweenService:Create(lBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(64,42,100),BackgroundTransparency=0.15}):Play()
        end
    end)
    lBtn.MouseButton1Click:Connect(function()
        -- Fecha o dropdown
        langDropOpen = false
        TweenService:Create(lhArrow,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=180}):Play()
        TweenService:Create(langDropContent,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Size=UDim2.new(1,0,0,0)}):Play()
        TweenService:Create(langHeaderStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(120,86,188)}):Play()
        -- Atualiza label do header imediatamente
        lhCurrentLbl.Text = lang.flag.." "..lang.short
        -- Aplica o idioma na hora, sem confirmação
        applyLanguage(lang)
        if langInfoLabel   then langInfoLabel.Text   = lang.flag.."  "..lang.short end
        if langFooterLabel then langFooterLabel.Text = lang.flag.." "..lang.short  end
        local T = TRANSLATIONS[lang.code] or TRANSLATIONS["PT-BR"]
        Notify.send({
            type="custom", icon=lang.flag,
            accent=Color3.fromRGB(120,86,188),
            title=T.langSystem or "Idioma",
            msg=(T.notifLangChanged or "Idioma alterado para ")..lang.name,
            duration=3,
        })
    end)
end

langHeader.MouseButton1Click:Connect(function()
    langDropOpen = not langDropOpen
    TweenService:Create(lhArrow,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=langDropOpen and 0 or 180}):Play()
    if langDropOpen then
        TweenService:Create(langHeaderStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(148,112,220)}):Play()
        TweenService:Create(langDropContent,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,LANG_DROP_H)}):Play()
    else
        TweenService:Create(langHeaderStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(120,86,188)}):Play()
        TweenService:Create(langDropContent,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{Size=UDim2.new(1,0,0,0)}):Play()
    end
end)

-- Registrar labels para tradução
trackLabel(lhTitleLbl, "langSystem")
trackLabel(ntTitle, "notifTitle")
trackLabel(ntDesc, "notifDesc")
trackLabel(infoStatusLbl, "infoStatus")

-- ══════════════════════════════════════════════════════
-- SERVIDOR POR ID — aba Info
-- ══════════════════════════════════════════════════════
local srvSep=Instance.new("Frame",Pages["Info"])
srvSep.BackgroundColor3=Color3.fromRGB(148,112,220); srvSep.BackgroundTransparency=0.82; srvSep.BorderSizePixel=0
srvSep.Size=UDim2.new(1,0,0,1); srvSep.LayoutOrder=9; srvSep.ZIndex=5

local srvCard=Instance.new("Frame",Pages["Info"])
srvCard.BackgroundColor3=Color3.fromRGB(60,38,96); srvCard.BorderSizePixel=0
srvCard.Size=UDim2.new(1,0,0,102); srvCard.LayoutOrder=10; srvCard.ZIndex=5
Instance.new("UICorner",srvCard).CornerRadius=UDim.new(0,10)
local srvStroke=Instance.new("UIStroke",srvCard); srvStroke.Color=Color3.fromRGB(148,112,220); srvStroke.Thickness=1.5

local srvGlow=Instance.new("Frame",srvCard); srvGlow.BackgroundColor3=Color3.fromRGB(148,112,220)
srvGlow.BackgroundTransparency=0.93; srvGlow.BorderSizePixel=0; srvGlow.Size=UDim2.new(1,0,1,0); srvGlow.ZIndex=5
Instance.new("UICorner",srvGlow).CornerRadius=UDim.new(0,10)

local srvBar=Instance.new("Frame",srvCard); srvBar.BackgroundColor3=Color3.fromRGB(148,112,220)
srvBar.BorderSizePixel=0; srvBar.Size=UDim2.new(0,4,0.7,0); srvBar.Position=UDim2.new(0,0,0.15,0); srvBar.ZIndex=6
Instance.new("UICorner",srvBar).CornerRadius=UDim.new(0,2)

local srvIconBg=Instance.new("Frame",srvCard); srvIconBg.BackgroundColor3=Color3.fromRGB(148,112,220)
srvIconBg.BackgroundTransparency=0.75; srvIconBg.BorderSizePixel=0
srvIconBg.Position=UDim2.new(0,10,0,10); srvIconBg.Size=UDim2.new(0,28,0,28); srvIconBg.ZIndex=6
Instance.new("UICorner",srvIconBg).CornerRadius=UDim.new(1,0)
local srvIconLbl=Instance.new("TextLabel",srvIconBg); srvIconLbl.BackgroundTransparency=1
srvIconLbl.Size=UDim2.new(1,0,1,0); srvIconLbl.Font=Enum.Font.GothamBold
srvIconLbl.Text="🔗"; srvIconLbl.TextSize=14; srvIconLbl.ZIndex=7

local srvTitle=Instance.new("TextLabel",srvCard); srvTitle.BackgroundTransparency=1
srvTitle.Position=UDim2.new(0,46,0,10); srvTitle.Size=UDim2.new(1,-56,0,16)
srvTitle.Font=Enum.Font.GothamBlack; srvTitle.Text="Servidor por ID"
trackLabel(srvTitle, "srvTitle")
srvTitle.TextColor3=Color3.fromRGB(175,148,238); srvTitle.TextSize=12
srvTitle.TextXAlignment=Enum.TextXAlignment.Left; srvTitle.ZIndex=6

local srvSubTitle=Instance.new("TextLabel",srvCard); srvSubTitle.BackgroundTransparency=1
srvSubTitle.Position=UDim2.new(0,46,0,27); srvSubTitle.Size=UDim2.new(1,-56,0,12)
srvSubTitle.Font=Enum.Font.Gotham; srvSubTitle.Text="Cole o Job ID do servidor para tentar entrar"
trackLabel(srvSubTitle, "srvSub")
srvSubTitle.TextColor3=Color3.fromRGB(150,115,60); srvSubTitle.TextSize=9
srvSubTitle.TextXAlignment=Enum.TextXAlignment.Left; srvSubTitle.ZIndex=6

-- TextBox de ID
local srvBoxBg=Instance.new("Frame",srvCard); srvBoxBg.BackgroundColor3=Color3.fromRGB(60,38,96)
srvBoxBg.BorderSizePixel=0; srvBoxBg.Position=UDim2.new(0,10,0,48); srvBoxBg.Size=UDim2.new(1,-96,0,30)
srvBoxBg.ZIndex=6; Instance.new("UICorner",srvBoxBg).CornerRadius=UDim.new(0,8)
local srvBoxStroke=Instance.new("UIStroke",srvBoxBg); srvBoxStroke.Color=Color3.fromRGB(100,70,30); srvBoxStroke.Thickness=1.2

local srvBox=Instance.new("TextBox",srvBoxBg); srvBox.BackgroundTransparency=1
srvBox.Position=UDim2.new(0,10,0,0); srvBox.Size=UDim2.new(1,-12,1,0)
srvBox.Font=Enum.Font.GothamBold; srvBox.Text=""
srvBox.PlaceholderText="Cole o Job ID aqui..."; srvBox.PlaceholderColor3=Color3.fromRGB(130,95,45)
srvBox.TextColor3=Color3.fromRGB(240,215,160); srvBox.TextSize=10
srvBox.ClearTextOnFocus=false; srvBox.ZIndex=7

srvBox.Focused:Connect(function() TweenService:Create(srvBoxStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(148,112,220)}):Play() end)
srvBox.FocusLost:Connect(function() TweenService:Create(srvBoxStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(100,70,30)}):Play() end)

-- Botão conectar
local srvBtn=Instance.new("TextButton",srvCard); srvBtn.BackgroundColor3=Color3.fromRGB(148,112,220)
srvBtn.BackgroundTransparency=0.15; srvBtn.BorderSizePixel=0
srvBtn.Position=UDim2.new(1,-78,0,48); srvBtn.Size=UDim2.new(0,70,0,30)
srvBtn.Font=Enum.Font.GothamBold; srvBtn.Text="→ Ir"
trackLabel(srvBtn, "srvBtn")
srvBtn.TextColor3=Color3.fromRGB(255,255,255); srvBtn.TextSize=11; srvBtn.ZIndex=7
Instance.new("UICorner",srvBtn).CornerRadius=UDim.new(0,8)
local srvBtnStroke=Instance.new("UIStroke",srvBtn); srvBtnStroke.Color=Color3.fromRGB(175,148,238); srvBtnStroke.Thickness=1; srvBtnStroke.Transparency=0.5
srvBtn.MouseEnter:Connect(function() TweenService:Create(srvBtn,TweenInfo.new(0.1),{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(255,195,70)}):Play() end)
srvBtn.MouseLeave:Connect(function() TweenService:Create(srvBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.15,BackgroundColor3=Color3.fromRGB(148,112,220)}):Play() end)

-- Status label
local srvStatusLbl=Instance.new("TextLabel",srvCard); srvStatusLbl.BackgroundTransparency=1
srvStatusLbl.Position=UDim2.new(0,10,0,82); srvStatusLbl.Size=UDim2.new(1,-20,0,14)
srvStatusLbl.Font=Enum.Font.GothamBold; srvStatusLbl.Text=""
srvStatusLbl.TextColor3=Color3.fromRGB(175,148,238); srvStatusLbl.TextSize=9
srvStatusLbl.TextXAlignment=Enum.TextXAlignment.Left; srvStatusLbl.ZIndex=6

local srvConnecting=false
srvBtn.MouseButton1Click:Connect(function()
    if srvConnecting then return end
    local id=srvBox.Text:match("^%s*(.-)%s*$")  -- trim
    if id=="" then
        srvStatusLbl.Text=T("srvInvalidId"); srvStatusLbl.TextColor3=Color3.fromRGB(255,90,90)
        return
    end
    srvConnecting=true
    srvBtn.Text="⏳"; srvStatusLbl.Text=T("srvConnecting"); srvStatusLbl.TextColor3=Color3.fromRGB(175,148,238)
    srvCard.Size=UDim2.new(1,0,0,102)
    Notify.info(T("srvNotifTitle"), T("srvNotifConnecting")..id:sub(1,20).."...", 4)
    task.spawn(function()
        local ok,err=pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, id, Player)
        end)
        task.wait(0.5)
        if not ok then
            srvStatusLbl.Text="✗ Falha: ID inválido ou servidor fechado"; srvStatusLbl.TextColor3=Color3.fromRGB(255,90,90)
            srvBtn.Text="→ Ir"
            Notify.error(T("srvNotifTitle"), T("srvNotifError"), 4)
            task.delay(4, function() srvStatusLbl.Text=""; srvConnecting=false end)
        else
            srvStatusLbl.Text=T("srvTeleporting"); srvStatusLbl.TextColor3=Color3.fromRGB(87,242,135)
            srvBtn.Text=T("srvBtn")
        end
        srvConnecting=false
    end)
end)

-- Enter no textbox também confirma
srvBox.FocusLost:Connect(function(enter)
    if enter then srvBtn:Invoke() end
end)


-- ══════════════════════════════════════════════════════
-- ANTI-AFK
-- ══════════════════════════════════════════════════════
do
local AFK_COR     = Color3.fromRGB(100, 220, 160)
local afkEnabled  = false
local afkConn     = nil
local afkVU       = nil
pcall(function() afkVU = game:GetService("VirtualUser") end)

local afkCard = Instance.new("Frame", Pages["Info"])
afkCard.BackgroundColor3 = Color3.fromRGB(20, 14, 36)
afkCard.BackgroundTransparency = 0
afkCard.BorderSizePixel = 0
afkCard.Size = UDim2.new(1, 0, 0, 58)
afkCard.LayoutOrder = 97
afkCard.ZIndex = 5
Instance.new("UICorner", afkCard).CornerRadius = UDim.new(0, 12)
local afkStroke = Instance.new("UIStroke", afkCard)
afkStroke.Color = AFK_COR; afkStroke.Thickness = 1.5; afkStroke.Transparency = 0.65
afkStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Gradiente
local afkG = Instance.new("UIGradient", afkCard)
afkG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22,38,30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(14,20,28)),
}); afkG.Rotation = 135

-- Ícone
local afkIcoBox = Instance.new("Frame", afkCard)
afkIcoBox.BackgroundColor3 = AFK_COR; afkIcoBox.BackgroundTransparency = 0.7
afkIcoBox.BorderSizePixel = 0
afkIcoBox.Position = UDim2.new(0, 10, 0.5, -16); afkIcoBox.Size = UDim2.new(0, 32, 0, 32)
afkIcoBox.ZIndex = 6
Instance.new("UICorner", afkIcoBox).CornerRadius = UDim.new(0, 8)
local afkIcoLbl = Instance.new("TextLabel", afkIcoBox)
afkIcoLbl.BackgroundTransparency = 1; afkIcoLbl.Size = UDim2.new(1,0,1,0)
afkIcoLbl.Font = Enum.Font.GothamBold; afkIcoLbl.Text = "💤"
afkIcoLbl.TextSize = 17; afkIcoLbl.ZIndex = 7

-- Título
local afkTitle = Instance.new("TextLabel", afkCard)
afkTitle.BackgroundTransparency = 1
afkTitle.Position = UDim2.new(0, 52, 0, 10); afkTitle.Size = UDim2.new(1, -110, 0, 18)
afkTitle.Font = Enum.Font.GothamBlack; afkTitle.Text = "Anti-AFK"
afkTitle.TextColor3 = Color3.fromRGB(220, 255, 235); afkTitle.TextSize = 13
afkTitle.TextXAlignment = Enum.TextXAlignment.Left; afkTitle.ZIndex = 6

-- Descrição
local afkDesc = Instance.new("TextLabel", afkCard)
afkDesc.BackgroundTransparency = 1
afkDesc.Position = UDim2.new(0, 52, 0, 30); afkDesc.Size = UDim2.new(1, -110, 0, 16)
afkDesc.Font = Enum.Font.Gotham; afkDesc.Text = "Evita kick automático por inatividade."
afkDesc.TextColor3 = Color3.fromRGB(140, 200, 165); afkDesc.TextSize = 9
afkDesc.TextXAlignment = Enum.TextXAlignment.Left; afkDesc.ZIndex = 6

-- Toggle pill
local afkPillBg = Instance.new("Frame", afkCard)
afkPillBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60); afkPillBg.BackgroundTransparency = 0
afkPillBg.BorderSizePixel = 0
afkPillBg.AnchorPoint = Vector2.new(1, 0.5); afkPillBg.Position = UDim2.new(1, -12, 0.5, 0)
afkPillBg.Size = UDim2.new(0, 44, 0, 24); afkPillBg.ZIndex = 7
Instance.new("UICorner", afkPillBg).CornerRadius = UDim.new(1, 0)
local afkKnob = Instance.new("Frame", afkPillBg)
afkKnob.BackgroundColor3 = Color3.fromRGB(160, 160, 175); afkKnob.BorderSizePixel = 0
afkKnob.Position = UDim2.new(0, 2, 0.5, -10); afkKnob.Size = UDim2.new(0, 20, 0, 20)
afkKnob.ZIndex = 8
Instance.new("UICorner", afkKnob).CornerRadius = UDim.new(1, 0)

local afkBtn = Instance.new("TextButton", afkCard)
afkBtn.BackgroundTransparency = 1; afkBtn.BorderSizePixel = 0
afkBtn.Size = UDim2.new(1, 0, 1, 0); afkBtn.Text = ""; afkBtn.ZIndex = 9

local function setAfk(on)
    afkEnabled = on
    TweenService:Create(afkPillBg, TweenInfo.new(0.18), {
        BackgroundColor3 = on and AFK_COR or Color3.fromRGB(40,40,60)
    }):Play()
    TweenService:Create(afkKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = on and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10),
        BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,175),
    }):Play()
    TweenService:Create(afkStroke, TweenInfo.new(0.2), {
        Transparency = on and 0.2 or 0.65, Color = on and AFK_COR or Color3.fromRGB(80,60,120)
    }):Play()

    if on then
        -- Método 1: VirtualUser — simula input real
        if afkVU then
            afkConn = Players.LocalPlayer.Idled:Connect(function()
                pcall(function()
                    afkVU:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(0.1)
                    afkVU:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end)
        end
        -- Método 2: loop de movimento mínimo a cada 60s como backup
        task.spawn(function()
            while afkEnabled do
                task.wait(55)
                if not afkEnabled then break end
                pcall(function()
                    local hum = Player.Character and Player.Character:FindFirstChildWhichIsA("Humanoid")
                    if hum then
                        local orig = hum.WalkSpeed
                        hum.WalkSpeed = 0.01
                        task.wait(0.1)
                        hum.WalkSpeed = orig
                    end
                end)
            end
        end)
        Notify.success("Anti-AFK", "💤 Ativado — não será kickado por inatividade.")
    else
        if afkConn then afkConn:Disconnect(); afkConn = nil end
        Notify.info("Anti-AFK", "Desativado.")
    end
end

afkBtn.MouseButton1Click:Connect(function()
    setAfk(not afkEnabled)
end)
end -- Anti-AFK

-- ══════════════════════════════════════════════════════
end) -- [[ INFO TAB ]]

-- ══════════════════════════════════════════════════════
-- ABA STATUS — Painel de monitoramento em tempo real
-- ══════════════════════════════════════════════════════
pcall(function() -- [[ STATUS TAB ]]
-- ══════════════════════════════════════════════════════════════════
-- STATUS TAB v2 — Painel completo: Servidor, Noite, Jogadores,
--                  Sessão, Mapa de Referência, Dicas, Changelog
-- ══════════════════════════════════════════════════════════════════
local statsLO    = 0
local sessionStart = tick()
local function stLO() statsLO = statsLO + 1; return statsLO end

-- ── Paleta ────────────────────────────────────────────────────────
local S_PURPLE  = Color3.fromRGB(148,112,220)
local S_VIOLET  = Color3.fromRGB(190,160,255)
local S_GOLD    = Color3.fromRGB(255,200,60)
local S_GREEN   = Color3.fromRGB(87,242,135)
local S_CYAN    = Color3.fromRGB(80,210,255)
local S_RED     = Color3.fromRGB(255,90,90)
local S_ORANGE  = Color3.fromRGB(255,160,60)
local S_DARK    = Color3.fromRGB(14,8,28)

-- ── Helpers ───────────────────────────────────────────────────────
local function mkCard(h, cor)
    local c = Instance.new("Frame", Pages["Status"])
    c.BackgroundColor3 = Color3.fromRGB(16,9,32)
    c.BackgroundTransparency = 0; c.BorderSizePixel = 0
    c.Size = UDim2.new(1,0,0,h); c.LayoutOrder = stLO(); c.ZIndex = 5
    Instance.new("UICorner",c).CornerRadius = UDim.new(0,14)
    local g = Instance.new("UIGradient",c)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(22,12,45)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10,5,22)),
    }); g.Rotation = 135
    local s = Instance.new("UIStroke",c)
    s.Color = cor or S_PURPLE; s.Thickness = 1.5; s.Transparency = 0.6
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    -- Linha de brilho topo
    local shine = Instance.new("Frame",c); shine.BackgroundColor3 = cor or S_PURPLE
    shine.BackgroundTransparency = 0.7; shine.BorderSizePixel = 0
    shine.Size = UDim2.new(0.6,0,0,1); shine.Position = UDim2.new(0.2,0,0,0); shine.ZIndex = 6
    local sg = Instance.new("UIGradient",shine)
    sg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
    })
    return c, s
end

local function mkHdr(parent, icon, title, cor, y)
    -- Ícone bg
    local ibg = Instance.new("Frame",parent)
    ibg.BackgroundColor3 = cor; ibg.BackgroundTransparency = 0.72; ibg.BorderSizePixel = 0
    ibg.Position = UDim2.new(0,10,0,y or 12); ibg.Size = UDim2.new(0,32,0,32); ibg.ZIndex = 6
    Instance.new("UICorner",ibg).CornerRadius = UDim.new(0,9)
    local il = Instance.new("TextLabel",ibg); il.BackgroundTransparency = 1
    il.Size = UDim2.new(1,0,1,0); il.Text = icon; il.TextSize = 17; il.ZIndex = 7
    -- Título
    local tl = Instance.new("TextLabel",parent); tl.BackgroundTransparency = 1
    tl.Position = UDim2.new(0,50,0,(y or 12)+2); tl.Size = UDim2.new(0.65,0,0,14)
    tl.Font = Enum.Font.GothamBlack; tl.Text = title
    tl.TextColor3 = cor; tl.TextSize = 11
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 6
    return ibg, tl
end

local function mkVal(parent, x, y, w, h, val, font, fs, col, zi)
    local l = Instance.new("TextLabel",parent); l.BackgroundTransparency = 1
    l.Position = UDim2.new(0,x,0,y); l.Size = UDim2.new(0,w,0,h)
    l.Font = font or Enum.Font.GothamBlack; l.Text = val or ""
    l.TextColor3 = col or S_VIOLET; l.TextSize = fs or 14
    l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = zi or 6; return l
end

local function mkSep(parent, y, cor)
    local f = Instance.new("Frame",parent); f.BackgroundColor3 = cor or S_PURPLE
    f.BackgroundTransparency = 0.75; f.BorderSizePixel = 0
    f.Position = UDim2.new(0,10,0,y); f.Size = UDim2.new(1,-20,0,1); f.ZIndex = 6
    local g = Instance.new("UIGradient",f)
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.4,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.6,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
    })
end

local function mkBar(parent, x, y, w, cor)
    local bg = Instance.new("Frame",parent); bg.BackgroundColor3 = Color3.fromRGB(20,10,40)
    bg.BackgroundTransparency = 0.3; bg.BorderSizePixel = 0
    bg.Position = UDim2.new(0,x,0,y); bg.Size = UDim2.new(0,w,0,5); bg.ZIndex = 6
    Instance.new("UICorner",bg).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame",bg); fill.BackgroundColor3 = cor or S_PURPLE
    fill.BackgroundTransparency = 0; fill.BorderSizePixel = 0
    fill.Size = UDim2.new(0,0,1,0); fill.ZIndex = 7
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)
    local bg2 = Instance.new("UIGradient",fill)
    bg2.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,cor or S_PURPLE),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(
            math.min(255,(cor or S_PURPLE).R*255+60),
            math.min(255,(cor or S_PURPLE).G*255+40),
            math.min(255,(cor or S_PURPLE).B*255+60)
        )),
    })
    return fill
end

-- ══════════════════════════════════════════════════════════════════
-- CARD 1 — INFORMAÇÕES DO SERVIDOR
-- ══════════════════════════════════════════════════════════════════
local srvCard, srvStroke = mkCard(148, S_CYAN)
mkHdr(srvCard, "🖥️", "INFORMAÇÕES DO SERVIDOR", S_CYAN, 10)

-- Ping
local pingDot = Instance.new("Frame",srvCard)
pingDot.BackgroundColor3 = S_GREEN; pingDot.BackgroundTransparency = 0; pingDot.BorderSizePixel = 0
pingDot.AnchorPoint = Vector2.new(1,0); pingDot.Position = UDim2.new(1,-12,0,14)
pingDot.Size = UDim2.new(0,8,0,8); pingDot.ZIndex = 7
Instance.new("UICorner",pingDot).CornerRadius = UDim.new(1,0)
local pingLbl = mkVal(srvCard, 50,30, 140,12, "Ping", Enum.Font.GothamBold, 8, Color3.fromRGB(120,130,155))
local pingVal = mkVal(srvCard, 50,42,  90,18, "-- ms", Enum.Font.GothamBlack, 16, S_GREEN)
local pingBar = mkBar(srvCard, 10,64, 140, S_GREEN)

mkSep(srvCard, 72, S_CYAN)

-- Job ID + Players inline
local jobLbl = mkVal(srvCard, 10,80, 200,10, "JOB ID", Enum.Font.GothamBold, 8, Color3.fromRGB(100,120,150))
local jobVal = mkVal(srvCard, 10,90, 220,11, "buscando...", Enum.Font.Gotham, 9, Color3.fromRGB(160,200,255))
jobVal.TextTruncate = Enum.TextTruncate.AtEnd

-- Copiar Job ID
local copyBtn = Instance.new("TextButton",srvCard)
copyBtn.BackgroundColor3 = S_CYAN; copyBtn.BackgroundTransparency = 0.7; copyBtn.BorderSizePixel = 0
copyBtn.AnchorPoint = Vector2.new(1,0); copyBtn.Position = UDim2.new(1,-10,0,84)
copyBtn.Size = UDim2.new(0,46,0,22); copyBtn.Font = Enum.Font.GothamBold
copyBtn.Text = "📋 Copy"; copyBtn.TextColor3 = Color3.fromRGB(200,240,255); copyBtn.TextSize = 8; copyBtn.ZIndex = 7
Instance.new("UICorner",copyBtn).CornerRadius = UDim.new(0,7)
copyBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard(tostring(game.JobId)) end)
    local orig = copyBtn.Text; copyBtn.Text = "✓ Copiado"
    task.delay(1.5, function() copyBtn.Text = orig end)
    Notify.success("Servidor","Job ID copiado!")
end)

local plrLbl  = mkVal(srvCard, 10,108, 180,10, "JOGADORES", Enum.Font.GothamBold, 8, Color3.fromRGB(100,120,150))
local plrVal  = mkVal(srvCard, 10,118, 100,16, "0 / 0", Enum.Font.GothamBlack, 15, S_VIOLET)
local plrBar  = mkBar(srvCard, 10,138, 220, S_VIOLET)

-- ══════════════════════════════════════════════════════════════════
-- CARD 2 — STATUS DA NOITE
-- ══════════════════════════════════════════════════════════════════
local nightCard, nightStroke = mkCard(158, S_GOLD)
mkHdr(nightCard, "🌙", "STATUS DA NOITE", S_GOLD, 10)

-- Dia atual grande
local dayBig = mkVal(nightCard, 50,28, 120,24, "Dia --", Enum.Font.GothamBlack, 22, S_GOLD)

-- Badge DIA/NOITE
local phaseBadge = Instance.new("Frame",nightCard)
phaseBadge.BackgroundColor3 = S_GOLD; phaseBadge.BackgroundTransparency = 0.55; phaseBadge.BorderSizePixel = 0
phaseBadge.AnchorPoint = Vector2.new(1,0); phaseBadge.Position = UDim2.new(1,-10,0,28)
phaseBadge.Size = UDim2.new(0,56,0,22); phaseBadge.ZIndex = 7
Instance.new("UICorner",phaseBadge).CornerRadius = UDim.new(0,8)
local phaseLbl = Instance.new("TextLabel",phaseBadge); phaseLbl.BackgroundTransparency = 1
phaseLbl.Size = UDim2.new(1,0,1,0); phaseLbl.Font = Enum.Font.GothamBold
phaseLbl.Text = "☀️ DIA"; phaseLbl.TextColor3 = Color3.fromRGB(255,255,255); phaseLbl.TextSize = 9; phaseLbl.ZIndex = 8

local daySubLbl2 = mkVal(nightCard, 50,52, 160,10, "buscando informação...", Enum.Font.Gotham, 8, Color3.fromRGB(180,160,100))

mkSep(nightCard, 66, S_GOLD)

-- Tempo de sessão
local sessLbl = mkVal(nightCard, 10,74, 120,10, "SESSÃO ATIVA", Enum.Font.GothamBold, 8, Color3.fromRGB(120,130,155))
local sessVal = mkVal(nightCard, 10,85, 180,18, "0m 0s", Enum.Font.GothamBlack, 17, S_VIOLET)

-- Barra de progresso da noite
local nightLblTxt = mkVal(nightCard, 10,106, 180,10, "CICLO DIA/NOITE", Enum.Font.GothamBold, 8, Color3.fromRGB(120,130,155))
local nightBarFill = mkBar(nightCard, 10,118, 220, S_GOLD)
local nightPctLbl = mkVal(nightCard, 0,130, 240,10, "detectando...", Enum.Font.GothamBold, 8, Color3.fromRGB(180,155,100))
nightPctLbl.TextXAlignment = Enum.TextXAlignment.Center

-- Alerta de noite chegando
local nightAlert = Instance.new("Frame",nightCard)
nightAlert.BackgroundColor3 = S_RED; nightAlert.BackgroundTransparency = 0.65; nightAlert.BorderSizePixel = 0
nightAlert.Position = UDim2.new(0,10,0,144); nightAlert.Size = UDim2.new(1,-20,0,10)
nightAlert.ZIndex = 7; nightAlert.Visible = false
Instance.new("UICorner",nightAlert).CornerRadius = UDim.new(0,5)
local alertLbl = Instance.new("TextLabel",nightAlert); alertLbl.BackgroundTransparency = 1
alertLbl.Size = UDim2.new(1,0,1,0); alertLbl.Font = Enum.Font.GothamBlack
alertLbl.Text = "⚠️  NOITE SE APROXIMANDO — VOLTE À FOGUEIRA!"
alertLbl.TextColor3 = Color3.fromRGB(255,220,220); alertLbl.TextSize = 8; alertLbl.ZIndex = 8

-- ══════════════════════════════════════════════════════════════════
-- CARD 3 — JOGADORES NA PARTIDA
-- ══════════════════════════════════════════════════════════════════
local plrCard2, plrStroke2 = mkCard(56, S_VIOLET)
mkHdr(plrCard2, "👥", "JOGADORES NA PARTIDA", S_VIOLET, 10)
local plrCountBig = mkVal(plrCard2, 50,28, 80,18, "0/0", Enum.Font.GothamBlack, 17, S_VIOLET)
local plrMaxBig   = mkVal(plrCard2, 136,32, 60,12, "Máx: "..tostring(game.Players.MaxPlayers), Enum.Font.Gotham, 9, Color3.fromRGB(140,120,175))
local plrBarFill  = mkBar(plrCard2, 10,48, 220, S_VIOLET)

-- Lista expandível de jogadores
local plrListOuter = Instance.new("Frame",Pages["Status"])
plrListOuter.BackgroundColor3 = Color3.fromRGB(14,8,28); plrListOuter.BackgroundTransparency = 0.1
plrListOuter.BorderSizePixel = 0; plrListOuter.Size = UDim2.new(1,0,0,0)
plrListOuter.LayoutOrder = stLO(); plrListOuter.ZIndex = 5; plrListOuter.ClipsDescendants = true
Instance.new("UICorner",plrListOuter).CornerRadius = UDim.new(0,12)
local plrListS = Instance.new("UIStroke",plrListOuter)
plrListS.Color = S_VIOLET; plrListS.Thickness = 1; plrListS.Transparency = 0.7
plrListS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local plrListInner = Instance.new("Frame",plrListOuter)
plrListInner.BackgroundTransparency = 1; plrListInner.BorderSizePixel = 0
plrListInner.Size = UDim2.new(1,0,1,0); plrListInner.ZIndex = 6
local plrLL = Instance.new("UIListLayout",plrListInner)
plrLL.Padding = UDim.new(0,4); plrLL.SortOrder = Enum.SortOrder.LayoutOrder
local plrPad = Instance.new("UIPadding",plrListInner)
plrPad.PaddingTop = UDim.new(0,6); plrPad.PaddingBottom = UDim.new(0,6)
plrPad.PaddingLeft = UDim.new(0,8); plrPad.PaddingRight = UDim.new(0,8)

local plrRowCache = {}
local function refreshPlrList()
    -- Remove saídos
    for uid, row in pairs(plrRowCache) do
        if not Players:GetPlayerByUserId(uid) then
            pcall(function() row:Destroy() end); plrRowCache[uid] = nil
        end
    end
    local all = Players:GetPlayers()
    for idx, plr in ipairs(all) do
        if not plrRowCache[plr.UserId] then
            local row = Instance.new("Frame",plrListInner)
            row.BackgroundColor3 = Color3.fromRGB(24,14,46)
            row.BackgroundTransparency = 0.3; row.BorderSizePixel = 0
            row.Size = UDim2.new(1,0,0,38); row.LayoutOrder = idx; row.ZIndex = 7
            Instance.new("UICorner",row).CornerRadius = UDim.new(0,10)
            -- Avatar
            local avBg = Instance.new("Frame",row)
            avBg.BackgroundColor3 = S_VIOLET; avBg.BackgroundTransparency = 0.65
            avBg.BorderSizePixel = 0; avBg.Position = UDim2.new(0,6,0.5,-14)
            avBg.Size = UDim2.new(0,28,0,28); avBg.ZIndex = 8
            Instance.new("UICorner",avBg).CornerRadius = UDim.new(1,0)
            local avImg = Instance.new("ImageLabel",avBg)
            avImg.BackgroundTransparency = 1; avImg.Size = UDim2.new(1,-4,1,-4)
            avImg.Position = UDim2.new(0,2,0,2)
            avImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..plr.UserId.."&width=48&height=48&format=png"
            avImg.ZIndex = 9
            Instance.new("UICorner",avImg).CornerRadius = UDim.new(1,0)
            -- Dot online
            local onDot = Instance.new("Frame",row)
            onDot.BackgroundColor3 = S_GREEN; onDot.BackgroundTransparency = 0
            onDot.BorderSizePixel = 0; onDot.AnchorPoint = Vector2.new(0,1)
            onDot.Position = UDim2.new(0,30,0.5,12); onDot.Size = UDim2.new(0,7,0,7); onDot.ZIndex = 10
            Instance.new("UICorner",onDot).CornerRadius = UDim.new(1,0)
            -- Nome
            local nLbl = Instance.new("TextLabel",row); nLbl.BackgroundTransparency = 1
            nLbl.Position = UDim2.new(0,42,0,5); nLbl.Size = UDim2.new(1,-90,0,14)
            nLbl.Font = Enum.Font.GothamBold; nLbl.Text = plr.DisplayName
            nLbl.TextColor3 = plr==Player and S_GOLD or Color3.fromRGB(225,215,245)
            nLbl.TextSize = 11; nLbl.TextXAlignment = Enum.TextXAlignment.Left; nLbl.ZIndex = 8
            -- Username
            local uLbl = Instance.new("TextLabel",row); uLbl.BackgroundTransparency = 1
            uLbl.Position = UDim2.new(0,42,0,20); uLbl.Size = UDim2.new(1,-90,0,10)
            uLbl.Font = Enum.Font.Gotham; uLbl.Text = "@"..plr.Name
            uLbl.TextColor3 = Color3.fromRGB(140,120,180); uLbl.TextSize = 9
            uLbl.TextXAlignment = Enum.TextXAlignment.Left; uLbl.ZIndex = 8
            -- Badge "Você"
            if plr == Player then
                local yBg = Instance.new("Frame",row)
                yBg.BackgroundColor3 = S_GOLD; yBg.BackgroundTransparency = 0.55; yBg.BorderSizePixel = 0
                yBg.AnchorPoint = Vector2.new(1,0.5); yBg.Position = UDim2.new(1,-8,0.5,0)
                yBg.Size = UDim2.new(0,34,0,16); yBg.ZIndex = 8
                Instance.new("UICorner",yBg).CornerRadius = UDim.new(0,5)
                local yL = Instance.new("TextLabel",yBg); yL.BackgroundTransparency = 1
                yL.Size = UDim2.new(1,0,1,0); yL.Font = Enum.Font.GothamBold
                yL.Text = "⭐ Você"; yL.TextColor3 = Color3.fromRGB(255,235,150); yL.TextSize = 8; yL.ZIndex = 9
            end
            plrRowCache[plr.UserId] = row
        end
    end
    local n = #all
    local lh = n * 42 + 16
    plrCountBig.Text = tostring(n).."/"..tostring(game.Players.MaxPlayers)
    TweenService:Create(plrBarFill,TweenInfo.new(0.4),{Size=UDim2.new(n/math.max(game.Players.MaxPlayers,1),0,1,0)}):Play()
    TweenService:Create(plrListOuter,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{Size=UDim2.new(1,0,0,lh)}):Play()
end
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlrList() end)
Players.PlayerRemoving:Connect(function(p)
    task.wait(0.1)
    if plrRowCache[p.UserId] then pcall(function() plrRowCache[p.UserId]:Destroy() end); plrRowCache[p.UserId]=nil end
    refreshPlrList()
end)
task.delay(0.5, refreshPlrList)

-- LOOP PRINCIPAL — atualiza Ping, Noite, Sessão
-- ══════════════════════════════════════════════════════════════════
local function getGameDay()
    local day = nil
    pcall(function()
        for _, n in ipairs({"Day","CurrentDay","GameDay","NightNumber","DayCount","DaysElapsed","DaysSurvived"}) do
            local v = game:GetAttribute(n) or workspace:GetAttribute(n)
            if type(v)=="number" and v>0 then day=math.floor(v); return end
        end
        local ls = Player:FindFirstChild("leaderstats") or Player:FindFirstChildWhichIsA("Folder")
        if ls then
            for _, n in ipairs({"Day","Days","DaysSurvived","Night","Nights"}) do
                local val = ls:FindFirstChild(n)
                if val and (val:IsA("IntValue") or val:IsA("NumberValue")) and val.Value>0 then
                    day = math.floor(val.Value); return
                end
            end
        end
    end)
    return day
end

local function getIsNight()
    local isNight = false
    pcall(function()
        local lighting = game:GetService("Lighting")
        local hr = lighting.ClockTime
        isNight = (hr >= 18 or hr < 6)
    end)
    return isNight
end

local function getNightProgress()
    local pct = 0
    pcall(function()
        local lighting = game:GetService("Lighting")
        local hr = lighting.ClockTime
        -- Dia: 6 a 18 (12h), Noite: 18 a 6 (12h)
        if hr >= 6 and hr < 18 then
            pct = (hr - 6) / 12  -- progresso do dia
        else
            local nightHr = hr >= 18 and (hr - 18) or (hr + 6)
            pct = nightHr / 12  -- progresso da noite
        end
    end)
    return pct
end

local alertShown = false
task.spawn(function()
    jobVal.Text = tostring(game.JobId):sub(1,32).."..."
    while true do
        task.wait(1)
        pcall(function()
            -- Ping
            local ping = Players.LocalPlayer.NetworkStats and
                math.floor(Players.LocalPlayer.NetworkStats.ServerStatsItem["Data Ping"].Value) or
                math.floor(Players.LocalPlayer:GetAttribute("Ping") or 0)
            -- fallback via Stats
            if ping == 0 then
                pcall(function()
                    ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"].Value)
                end)
            end
            pingVal.Text = tostring(ping).." ms"
            local pingPct = math.max(0, 1 - ping/300)
            TweenService:Create(pingBar,TweenInfo.new(0.5),{Size=UDim2.new(pingPct,0,1,0)}):Play()
            if ping < 80 then
                pingVal.TextColor3 = S_GREEN; pingDot.BackgroundColor3 = S_GREEN
            elseif ping < 180 then
                pingVal.TextColor3 = S_GOLD; pingDot.BackgroundColor3 = S_GOLD
            else
                pingVal.TextColor3 = S_RED; pingDot.BackgroundColor3 = S_RED
            end

            -- Jogadores
            local np = #Players:GetPlayers()
            local mp = game.Players.MaxPlayers
            plrVal.Text = tostring(np).." / "..tostring(mp)
            TweenService:Create(plrBar,TweenInfo.new(0.5),{Size=UDim2.new(np/math.max(mp,1),0,1,0)}):Play()

            -- Sessão
            local el = tick() - sessionStart
            local h,m,s2 = math.floor(el/3600), math.floor((el%3600)/60), math.floor(el%60)
            sessVal.Text = h>0 and string.format("%dh %dm %ds",h,m,s2) or string.format("%dm %ds",m,s2)

            -- Dia
            local day = getGameDay()
            if day then
                dayBig.Text = "Dia "..tostring(day)
                daySubLbl2.Text = day==1 and "Primeiro dia!" or tostring(day).." dias sobrevividos"
            end

            -- Ciclo dia/noite
            local isNight = getIsNight()
            local pct = getNightProgress()
            TweenService:Create(nightBarFill,TweenInfo.new(0.8),{Size=UDim2.new(pct,0,1,0)}):Play()
            if isNight then
                phaseLbl.Text = "🌙 NOITE"
                TweenService:Create(phaseBadge,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(60,40,120)}):Play()
                nightBarFill.BackgroundColor3 = S_VIOLET
                nightPctLbl.Text = string.format("Noite — %.0f%% completa", pct*100)
                -- Alerta início da noite
                if not alertShown then
                    alertShown = true; nightAlert.Visible = true
                    task.spawn(function()
                        for _ = 1,3 do
                            TweenService:Create(nightAlert,TweenInfo.new(0.25),{BackgroundTransparency=0.2}):Play()
                            task.wait(0.3)
                            TweenService:Create(nightAlert,TweenInfo.new(0.25),{BackgroundTransparency=0.65}):Play()
                            task.wait(0.3)
                        end
                        task.wait(4); nightAlert.Visible = false
                    end)
                end
            else
                phaseLbl.Text = "☀️ DIA"
                TweenService:Create(phaseBadge,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(120,80,0)}):Play()
                nightBarFill.BackgroundColor3 = S_GOLD
                nightPctLbl.Text = string.format("Dia — %.0f%% completo", pct*100)
                alertShown = false
                nightAlert.Visible = false
            end
        end)
    end
end)

end) -- [[ STATUS TAB ]]


-- ══════════════════════════════════════════════════════════════════
pcall(function() -- [[ ATUALIZACAO TAB ]]
-- ══════════════════════════════════════════════════════════════════
-- ABA ATUALIZAÇÃO v2 — Sistema profissional de changelog
-- Atual (expandido) + Histórico (accordion colapsável)
-- ══════════════════════════════════════════════════════════════════

local U_PURPLE = Color3.fromRGB(148,112,220)
local U_VIOLET = Color3.fromRGB(190,160,255)
local U_GOLD   = Color3.fromRGB(255,200,60)
local U_GREEN  = Color3.fromRGB(87,242,135)
local U_CYAN   = Color3.fromRGB(80,210,255)
local U_RED    = Color3.fromRGB(255,90,90)
local U_ORANGE = Color3.fromRGB(255,160,60)
local U_MUTED  = Color3.fromRGB(110,90,150)
local updLO    = 0
local function uLO() updLO = updLO + 1; return updLO end

-- ── Helpers ───────────────────────────────────────────────────────
local function mkSeparator(icon, title, cor, isHistory)
    local f = Instance.new("Frame", Pages["Atualizacao"])
    f.BackgroundTransparency = 1; f.BorderSizePixel = 0
    f.Size = UDim2.new(1,0,0,28); f.LayoutOrder = uLO(); f.ZIndex = 5
    -- Linha esquerda
    local lL = Instance.new("Frame",f); lL.BackgroundColor3 = cor
    lL.BackgroundTransparency = isHistory and 0.6 or 0.3; lL.BorderSizePixel = 0
    lL.Position = UDim2.new(0,0,0.5,-1); lL.Size = UDim2.new(0,8,0,2); lL.ZIndex = 6
    -- Ícone
    local iL = Instance.new("TextLabel",f); iL.BackgroundTransparency = 1
    iL.Position = UDim2.new(0,12,0,4); iL.Size = UDim2.new(0,18,0,20)
    iL.Text = icon; iL.TextSize = 13; iL.ZIndex = 6
    -- Título
    local tL = Instance.new("TextLabel",f); tL.BackgroundTransparency = 1
    tL.Position = UDim2.new(0,32,0,5); tL.Size = UDim2.new(0.7,0,0,18)
    tL.Font = Enum.Font.GothamBlack; tL.Text = title
    tL.TextColor3 = isHistory and U_MUTED or cor; tL.TextSize = isHistory and 10 or 11
    tL.TextXAlignment = Enum.TextXAlignment.Left; tL.ZIndex = 6
    -- Linha direita
    local lR = Instance.new("Frame",f); lR.BackgroundColor3 = cor
    lR.BackgroundTransparency = isHistory and 0.75 or 0.5; lR.BorderSizePixel = 0
    lR.AnchorPoint = Vector2.new(1,0.5); lR.Position = UDim2.new(1,0,0.5,0)
    lR.Size = UDim2.new(0,0,0,1); lR.ZIndex = 5
    local lRG = Instance.new("UIGradient",lR)
    lRG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
    })
    -- Calcula largura da linha direita dinamicamente
    task.defer(function()
        local titleEnd = 32 + tL.TextBounds.X + 8
        local remain = math.max(0, f.AbsoluteSize.X - titleEnd - 8)
        lR.Position = UDim2.new(0, titleEnd, 0.5, 0)
        lR.Size = UDim2.new(0, remain, 0, 1)
    end)
    return f
end

local function mkStatBadge(parent, x, y, text, cor, textCor)
    local bg = Instance.new("Frame",parent)
    bg.BackgroundColor3 = cor; bg.BackgroundTransparency = 0.55; bg.BorderSizePixel = 0
    bg.Position = UDim2.new(0,x,0,y); bg.Size = UDim2.new(0,0,0,17); bg.ZIndex = 7
    bg.AutomaticSize = Enum.AutomaticSize.X
    Instance.new("UICorner",bg).CornerRadius = UDim.new(0,6)
    local pad = Instance.new("UIPadding",bg)
    pad.PaddingLeft = UDim.new(0,6); pad.PaddingRight = UDim.new(0,6)
    local bL = Instance.new("TextLabel",bg); bL.BackgroundTransparency = 1
    bL.Size = UDim2.new(0,0,1,0); bL.AutomaticSize = Enum.AutomaticSize.X
    bL.Font = Enum.Font.GothamBlack; bL.Text = text
    bL.TextColor3 = textCor or Color3.fromRGB(240,235,255); bL.TextSize = 8; bL.ZIndex = 8
    return bg
end

-- ── Cria card de entrada de changelog ─────────────────────────────
local function mkChangelogCard(parent, entry, isOld)
    local itemCount = 0
    for _, grp in ipairs(entry.grupos) do itemCount = itemCount + #grp.items end
    local HEADER_H = 56
    local ITEM_H   = 20
    local GRP_H    = 18  -- altura do header do grupo
    local totalGrps = #entry.grupos
    local contentH = 0
    for _, grp in ipairs(entry.grupos) do
        contentH = contentH + GRP_H + #grp.items * ITEM_H + 6
    end
    local FULL_H   = HEADER_H + 2 + contentH + 8  -- 2 = sep, 8 = padding bot
    local CLOSED_H = HEADER_H

    local card = Instance.new("Frame", parent)
    card.BackgroundColor3 = Color3.fromRGB(16,9,32)
    card.BackgroundTransparency = isOld and 0.15 or 0
    card.BorderSizePixel = 0; card.ClipsDescendants = true
    card.Size = UDim2.new(1,0,0, isOld and CLOSED_H or FULL_H)
    card.LayoutOrder = uLO(); card.ZIndex = 5
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,14)

    -- Gradiente fundo
    local cg = Instance.new("UIGradient",card)
    local dark1 = isOld and Color3.fromRGB(18,10,36) or Color3.fromRGB(24,13,50)
    local dark2 = isOld and Color3.fromRGB(8,4,18)  or Color3.fromRGB(10,5,22)
    cg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,dark1),
        ColorSequenceKeypoint.new(1,dark2),
    }); cg.Rotation = 135

    -- Borda
    local cs = Instance.new("UIStroke",card)
    cs.Color = isOld and U_MUTED or entry.cor
    cs.Thickness = isOld and 1 or 1.5
    cs.Transparency = isOld and 0.75 or 0.5
    cs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Brilho linha topo
    local shine = Instance.new("Frame",card)
    shine.BackgroundColor3 = isOld and U_MUTED or entry.cor
    shine.BackgroundTransparency = isOld and 0.85 or 0.6
    shine.BorderSizePixel = 0
    shine.Size = UDim2.new(0.55,0,0,1); shine.Position = UDim2.new(0.22,0,0,0); shine.ZIndex = 6
    local shG = Instance.new("UIGradient",shine)
    shG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
    })

    -- Barra lateral
    local sBar = Instance.new("Frame",card)
    sBar.BackgroundColor3 = isOld and U_MUTED or entry.cor
    sBar.BackgroundTransparency = isOld and 0.6 or 0.15
    sBar.BorderSizePixel = 0
    sBar.Position = UDim2.new(0,0,0.1,0); sBar.Size = UDim2.new(0,3,0.8,0); sBar.ZIndex = 7
    Instance.new("UICorner",sBar).CornerRadius = UDim.new(0,2)

    -- ── HEADER ──────────────────────────────────────────────────
    -- Nome da versão
    local vLbl = Instance.new("TextLabel",card); vLbl.BackgroundTransparency = 1
    vLbl.Position = UDim2.new(0,14,0,9); vLbl.Size = UDim2.new(0.5,0,0,20)
    vLbl.Font = Enum.Font.GothamBlack
    vLbl.Text = entry.ver
    vLbl.TextColor3 = isOld and U_MUTED or entry.cor
    vLbl.TextSize = isOld and 13 or 16
    vLbl.TextXAlignment = Enum.TextXAlignment.Left; vLbl.ZIndex = 6
    -- Gradiente no texto da versão (só recentes)
    if not isOld then
        local vG = Instance.new("UIGradient",vLbl)
        vG.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,entry.cor),
            ColorSequenceKeypoint.new(0.6,Color3.fromRGB(
                math.min(255,entry.cor.R*255+60),
                math.min(255,entry.cor.G*255+40),
                math.min(255,entry.cor.B*255+60)
            )),
            ColorSequenceKeypoint.new(1,entry.cor),
        })
    end

    -- Label descritivo
    local rLbl = Instance.new("TextLabel",card); rLbl.BackgroundTransparency = 1
    rLbl.Position = UDim2.new(0,14,0,30); rLbl.Size = UDim2.new(0.58,0,0,12)
    rLbl.Font = Enum.Font.GothamBold; rLbl.Text = entry.label
    rLbl.TextColor3 = isOld and Color3.fromRGB(120,105,150) or Color3.fromRGB(170,155,205)
    rLbl.TextSize = 9; rLbl.TextXAlignment = Enum.TextXAlignment.Left; rLbl.ZIndex = 6

    -- Badges no canto direito
    local badgeX = -10
    -- Badge principal (MAJOR/FIX/BASE etc)
    local mainBadge = mkStatBadge(card, 0, 9, entry.badge, isOld and U_MUTED or entry.badgeCor,
        isOld and Color3.fromRGB(160,145,185) or Color3.fromRGB(240,235,255))
    mainBadge.AnchorPoint = Vector2.new(1,0); mainBadge.Position = UDim2.new(1,badgeX,0,9)

    -- Badge de contagem de itens
    local cntBadge = mkStatBadge(card, 0, 30, "📦 "..tostring(itemCount).." itens",
        Color3.fromRGB(30,18,55), Color3.fromRGB(160,145,195))
    cntBadge.AnchorPoint = Vector2.new(1,0); cntBadge.Position = UDim2.new(1,badgeX,0,30)

    -- Data
    local dLbl = Instance.new("TextLabel",card); dLbl.BackgroundTransparency = 1
    dLbl.AnchorPoint = Vector2.new(1,0); dLbl.Position = UDim2.new(1,badgeX,0,48)
    dLbl.Size = UDim2.new(0.6,0,0,10); dLbl.Font = Enum.Font.Gotham
    dLbl.Text = "📅 "..entry.date
    dLbl.TextColor3 = isOld and Color3.fromRGB(120,105,145) or Color3.fromRGB(160,145,200)
    dLbl.TextSize = 8; dLbl.TextXAlignment = Enum.TextXAlignment.Right; dLbl.ZIndex = 6

    -- Seta accordion (só para antigas)
    local arrowLbl = nil
    if isOld then
        arrowLbl = Instance.new("TextLabel",card); arrowLbl.BackgroundTransparency = 1
        arrowLbl.Position = UDim2.new(0,14,0,36); arrowLbl.Size = UDim2.new(0,16,0,14)
        arrowLbl.Font = Enum.Font.GothamBlack; arrowLbl.Text = "▸"
        arrowLbl.TextColor3 = U_MUTED; arrowLbl.TextSize = 11; arrowLbl.ZIndex = 7
    end

    -- Separador header/conteúdo
    local sep = Instance.new("Frame",card)
    sep.BackgroundColor3 = isOld and U_MUTED or entry.cor
    sep.BackgroundTransparency = isOld and 0.8 or 0.65; sep.BorderSizePixel = 0
    sep.Position = UDim2.new(0,10,0,HEADER_H); sep.Size = UDim2.new(1,-20,0,1); sep.ZIndex = 6
    local sepG = Instance.new("UIGradient",sep)
    sepG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.3,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.7,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
    })

    -- ── CONTEÚDO: grupos de itens ────────────────────────────────
    local iy = HEADER_H + 8
    for gi, grp in ipairs(entry.grupos) do
        -- Header do grupo (categoria)
        local ghBg = Instance.new("Frame",card)
        ghBg.BackgroundColor3 = grp.cor or entry.cor
        ghBg.BackgroundTransparency = 0.82; ghBg.BorderSizePixel = 0
        ghBg.Position = UDim2.new(0,10,0,iy); ghBg.Size = UDim2.new(1,-20,0,GRP_H); ghBg.ZIndex = 6
        Instance.new("UICorner",ghBg).CornerRadius = UDim.new(0,6)
        local ghIco = Instance.new("TextLabel",ghBg); ghIco.BackgroundTransparency = 1
        ghIco.Position = UDim2.new(0,6,0,0); ghIco.Size = UDim2.new(0,16,1,0)
        ghIco.Text = grp.icon or "📌"; ghIco.TextSize = 10; ghIco.ZIndex = 7
        local ghLbl = Instance.new("TextLabel",ghBg); ghLbl.BackgroundTransparency = 1
        ghLbl.Position = UDim2.new(0,24,0,0); ghLbl.Size = UDim2.new(1,-36,1,0)
        ghLbl.Font = Enum.Font.GothamBlack; ghLbl.Text = grp.nome
        ghLbl.TextColor3 = isOld and Color3.fromRGB(140,120,175) or (grp.cor or entry.cor)
        ghLbl.TextSize = 8; ghLbl.TextXAlignment = Enum.TextXAlignment.Left; ghLbl.ZIndex = 7
        -- Contagem de itens do grupo
        local ghCnt = Instance.new("TextLabel",ghBg); ghCnt.BackgroundTransparency = 1
        ghCnt.AnchorPoint = Vector2.new(1,0.5); ghCnt.Position = UDim2.new(1,-6,0.5,0)
        ghCnt.Size = UDim2.new(0,30,1,0)
        ghCnt.Font = Enum.Font.GothamBold; ghCnt.Text = tostring(#grp.items)
        ghCnt.TextColor3 = Color3.fromRGB(160,145,195); ghCnt.TextSize = 8
        ghCnt.TextXAlignment = Enum.TextXAlignment.Right; ghCnt.ZIndex = 7
        iy = iy + GRP_H + 4

        -- Itens do grupo
        for _, item in ipairs(grp.items) do
            local tipoCor = item.tipo=="new"  and U_GREEN  or
                            item.tipo=="fix"  and U_CYAN   or
                            item.tipo=="old"  and Color3.fromRGB(110,90,150) or
                            item.tipo=="del"  and U_RED    or
                            Color3.fromRGB(180,160,220)
            -- Dot
            local dot = Instance.new("Frame",card)
            dot.BackgroundColor3 = isOld and Color3.fromRGB(100,80,140) or tipoCor
            dot.BackgroundTransparency = isOld and 0.5 or 0.25; dot.BorderSizePixel = 0
            dot.Position = UDim2.new(0,15,0,iy+7); dot.Size = UDim2.new(0,5,0,5); dot.ZIndex = 7
            Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)
            -- Ícone
            local ico = Instance.new("TextLabel",card); ico.BackgroundTransparency = 1
            ico.Position = UDim2.new(0,24,0,iy+1); ico.Size = UDim2.new(0,16,0,16)
            ico.Text = item.icon; ico.TextSize = 10
            ico.TextTransparency = isOld and 0.4 or 0; ico.ZIndex = 7
            -- Texto
            local txt = Instance.new("TextLabel",card); txt.BackgroundTransparency = 1
            txt.Position = UDim2.new(0,42,0,iy+1); txt.Size = UDim2.new(1,-60,0,16)
            txt.Font = isOld and Enum.Font.Gotham or Enum.Font.GothamBold
            txt.Text = item.text
            txt.TextColor3 = isOld and Color3.fromRGB(140,125,170) or Color3.fromRGB(210,200,235)
            txt.TextSize = isOld and 8 or 9
            txt.TextXAlignment = Enum.TextXAlignment.Left
            txt.TextTruncate = Enum.TextTruncate.AtEnd
            txt.TextTransparency = isOld and 0.2 or 0; txt.ZIndex = 7
            -- Mini tag NEW/FIX/DEL
            if not isOld and item.tipo ~= "old" then
                local tagBg = Instance.new("Frame",card)
                tagBg.BackgroundColor3 = tipoCor; tagBg.BackgroundTransparency = 0.7
                tagBg.BorderSizePixel = 0; tagBg.AnchorPoint = Vector2.new(1,0)
                tagBg.Position = UDim2.new(1,-6,0,iy+3); tagBg.Size = UDim2.new(0,0,0,12); tagBg.ZIndex = 8
                tagBg.AutomaticSize = Enum.AutomaticSize.X
                Instance.new("UICorner",tagBg).CornerRadius = UDim.new(0,4)
                local tagPad = Instance.new("UIPadding",tagBg)
                tagPad.PaddingLeft = UDim.new(0,4); tagPad.PaddingRight = UDim.new(0,4)
                local tagL = Instance.new("TextLabel",tagBg); tagL.BackgroundTransparency = 1
                tagL.Size = UDim2.new(0,0,1,0); tagL.AutomaticSize = Enum.AutomaticSize.X
                tagL.Font = Enum.Font.GothamBlack
                tagL.Text = item.tipo=="new" and "NEW" or item.tipo=="fix" and "FIX" or "DEL"
                tagL.TextColor3 = Color3.fromRGB(220,255,230); tagL.TextSize = 7; tagL.ZIndex = 9
            end
            iy = iy + ITEM_H
        end
        iy = iy + 6
    end

    -- ── ACCORDION para antigas ────────────────────────────────────
    if isOld then
        local expanded = false
        local hitbox = Instance.new("TextButton",card)
        hitbox.BackgroundTransparency = 1; hitbox.BorderSizePixel = 0
        hitbox.Size = UDim2.new(1,0,0,CLOSED_H); hitbox.Text = ""; hitbox.ZIndex = 20
        hitbox.MouseButton1Click:Connect(function()
            expanded = not expanded
            local targetH = expanded and FULL_H or CLOSED_H
            TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size=UDim2.new(1,0,0,targetH)}):Play()
            TweenService:Create(arrowLbl, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Rotation = expanded and 90 or 0}):Play()
            TweenService:Create(cs, TweenInfo.new(0.2),
                {Transparency = expanded and 0.45 or 0.75, Color = expanded and U_VIOLET or U_MUTED}):Play()
        end)
        -- Hover
        hitbox.MouseEnter:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundTransparency=0.05}):Play()
        end)
        hitbox.MouseLeave:Connect(function()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundTransparency=0.15}):Play()
        end)
    end
    return card
end

-- ════════════════════════════════════════════════════════════════
-- DADOS DO CHANGELOG
-- Para adicionar nova versão: inserir no topo de RECENTES
-- ════════════════════════════════════════════════════════════════

-- ── VERSÕES RECENTES (aparecem expandidas) ────────────────────────
local RECENTES = {
    {
        ver     = "Atualização 1",
        date    = "19/03/26 Às 22:00 (Quinta)",
        label   = "Grande Atualização — Interface completa",
        cor     = U_GOLD,
        badge   = "MAJOR",
        badgeCor= U_GOLD,
        grupos  = {
            {
                icon="🎨", nome="INTERFACE & VISUAL", cor=U_VIOLET,
                items={
                    {icon="✨", text="Interface Voidware refeita do zero",     tipo="new"},
                    {icon="🎬", text="Splash screen com vidro quebrado",       tipo="new"},
                    {icon="✍️", text="Efeito typewriter no splash",             tipo="new"},
                    {icon="💡", text="Dropdowns com visual glassmorphism",     tipo="new"},
                    {icon="📋", text="Aba Atualização com changelog completo", tipo="new"},
                    {icon="🌙", text="Splash removido — hub abre direto",      tipo="fix"},
                }
            },
            {
                icon="⚔️", nome="COMBATE", cor=U_RED,
                items={
                    {icon="⚔️", text="Kill Aura com hitbox real (mouse1press)", tipo="new"},
                    {icon="📏", text="Slider de alcance 1~125 studs",          tipo="new"},
                    {icon="❄️", text="Freeze Aura com auto-attack integrado",   tipo="new"},
                    {icon="💉", text="HP drain removido (era client-only)",     tipo="fix"},
                }
            },
            {
                icon="🌾", nome="FARM", cor=U_GREEN,
                items={
                    {icon="🔥", text="Auto Feed Campfire com moveItem real",   tipo="fix"},
                    {icon="❤️", text="Auto Feed HP Based corrigido",            tipo="fix"},
                    {icon="🍖", text="Auto Cook Food corrigido",               tipo="fix"},
                    {icon="⚙️", text="Auto Machine Grind corrigido",           tipo="fix"},
                    {icon="🧪", text="Auto Biofuel corrigido",                 tipo="fix"},
                    {icon="🍽️", text="Auto Comer com InvokeServer direto",     tipo="fix"},
                }
            },
            {
                icon="🛠️", nome="UTILITÁRIOS", cor=U_CYAN,
                items={
                    {icon="👶", text="Tp Criança com dropdown Child 1-4",      tipo="new"},
                    {icon="💤", text="Anti-AFK dupla proteção",               tipo="new"},
                    {icon="🗺️", text="Aba Status: Mapa, Ping, Noite, Dicas",   tipo="new"},
                    {icon="📊", text="Changelog e aba Atualização",           tipo="new"},
                    {icon="🔧", text="_getItemsFolder movido para o topo",    tipo="fix"},
                }
            },
        }
    },
}

-- ── VERSÕES ANTIGAS (aparecem colapsadas) ─────────────────────────
local ANTIGAS = {
    {
        ver     = "Versão Inicial",
        date    = "12/01/25 Às 18:30 (Domingo)",
        label   = "Lançamento original do PudimHub",
        cor     = U_PURPLE,
        badge   = "BASE",
        badgeCor= Color3.fromRGB(100,80,145),
        grupos  = {
            {
                icon="🏗️", nome="ESTRUTURA BASE", cor=U_PURPLE,
                items={
                    {icon="🔧", text="Sistema de abas com sidebar",           tipo="old"},
                    {icon="🔧", text="ESP básico de entidades e recursos",    tipo="old"},
                    {icon="🔧", text="Bring por categoria",                   tipo="old"},
                    {icon="🔧", text="Farm básico (fogueira, grind)",         tipo="old"},
                    {icon="🔧", text="Teleporte para pontos do mapa",         tipo="old"},
                }
            },
        }
    },
}

-- ════════════════════════════════════════════════════════════════
-- RENDERIZAÇÃO
-- ════════════════════════════════════════════════════════════════

-- ── CARD TOPO: versão mais recente em destaque ───────────────────
local latest = RECENTES[1]
local topCard = Instance.new("Frame", Pages["Atualizacao"])
topCard.BackgroundColor3 = Color3.fromRGB(30,18,5)
topCard.BackgroundTransparency = 0; topCard.BorderSizePixel = 0
topCard.Size = UDim2.new(1,0,0,78); topCard.LayoutOrder = uLO(); topCard.ZIndex = 5
Instance.new("UICorner",topCard).CornerRadius = UDim.new(0,14)
local topG = Instance.new("UIGradient",topCard)
topG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(44,26,4)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16,8,2)),
}); topG.Rotation = 135
local topS2 = Instance.new("UIStroke",topCard)
topS2.Color = U_GOLD; topS2.Thickness = 1.8; topS2.Transparency = 0.3
topS2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
-- Ícone 🍮
local tIco = Instance.new("Frame",topCard)
tIco.BackgroundColor3 = U_GOLD; tIco.BackgroundTransparency = 0.65; tIco.BorderSizePixel = 0
tIco.Position = UDim2.new(0,12,0.5,-22); tIco.Size = UDim2.new(0,44,0,44); tIco.ZIndex = 6
Instance.new("UICorner",tIco).CornerRadius = UDim.new(0,14)
local tIcoL = Instance.new("TextLabel",tIco); tIcoL.BackgroundTransparency = 1
tIcoL.Size = UDim2.new(1,0,1,0); tIcoL.Text = "🍮"; tIcoL.TextSize = 24; tIcoL.ZIndex = 7
-- Nome do hub
local tTitle = Instance.new("TextLabel",topCard); tTitle.BackgroundTransparency = 1
tTitle.Position = UDim2.new(0,66,0,10); tTitle.Size = UDim2.new(0.58,0,0,24)
tTitle.Font = Enum.Font.GothamBlack; tTitle.Text = "PUDIM HUB"
tTitle.TextColor3 = U_GOLD; tTitle.TextSize = 18
tTitle.TextXAlignment = Enum.TextXAlignment.Left; tTitle.ZIndex = 6
local tTG = Instance.new("UIGradient",tTitle)
tTG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,U_GOLD),
    ColorSequenceKeypoint.new(0.6,Color3.fromRGB(255,235,140)),
    ColorSequenceKeypoint.new(1,U_ORANGE),
})
-- Versão atual
local tVer = Instance.new("TextLabel",topCard); tVer.BackgroundTransparency = 1
tVer.Position = UDim2.new(0,66,0,34); tVer.Size = UDim2.new(0.7,0,0,14)
tVer.Font = Enum.Font.GothamBold; tVer.Text = latest.ver.."  ·  "..latest.label
tVer.TextColor3 = Color3.fromRGB(200,170,100); tVer.TextSize = 9
tVer.TextXAlignment = Enum.TextXAlignment.Left; tVer.ZIndex = 6
-- Data
local tDate = Instance.new("TextLabel",topCard); tDate.BackgroundTransparency = 1
tDate.Position = UDim2.new(0,66,0,50); tDate.Size = UDim2.new(0.7,0,0,12)
tDate.Font = Enum.Font.Gotham; tDate.Text = "📅 "..latest.date
tDate.TextColor3 = Color3.fromRGB(160,135,90); tDate.TextSize = 8
tDate.TextXAlignment = Enum.TextXAlignment.Left; tDate.ZIndex = 6
-- Badge LATEST
local latBg = Instance.new("Frame",topCard)
latBg.BackgroundColor3 = U_GREEN; latBg.BackgroundTransparency = 0.35; latBg.BorderSizePixel = 0
latBg.AnchorPoint = Vector2.new(1,0); latBg.Position = UDim2.new(1,-10,0,10)
latBg.Size = UDim2.new(0,62,0,18); latBg.ZIndex = 7
Instance.new("UICorner",latBg).CornerRadius = UDim.new(0,6)
local latL = Instance.new("TextLabel",latBg); latL.BackgroundTransparency = 1
latL.Size = UDim2.new(1,0,1,0); latL.Font = Enum.Font.GothamBlack
latL.Text = "✓ LATEST"; latL.TextColor3 = Color3.fromRGB(200,255,215); latL.TextSize = 9; latL.ZIndex = 8
-- Pulsação do LATEST
task.spawn(function()
    while topCard.Parent do
        TweenService:Create(latBg,TweenInfo.new(1.2,Enum.EasingStyle.Sine),{BackgroundTransparency=0.6}):Play()
        task.wait(1.3)
        TweenService:Create(latBg,TweenInfo.new(0.8,Enum.EasingStyle.Sine),{BackgroundTransparency=0.35}):Play()
        task.wait(0.9)
    end
end)

-- ── CARD: Versão atual do script ───────────────────────────────
local verCard = Instance.new("Frame", Pages["Atualizacao"])
verCard.BackgroundColor3 = Color3.fromRGB(12,7,26)
verCard.BackgroundTransparency = 0; verCard.BorderSizePixel = 0
verCard.Size = UDim2.new(1,0,0,52); verCard.LayoutOrder = uLO(); verCard.ZIndex = 5
Instance.new("UICorner",verCard).CornerRadius = UDim.new(0,14)
-- Gradiente
local vcG = Instance.new("UIGradient",verCard)
vcG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28,16,56)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,5,22)),
}); vcG.Rotation = 90
-- Borda roxa suave
local vcS = Instance.new("UIStroke",verCard)
vcS.Color = U_PURPLE; vcS.Thickness = 1.2; vcS.Transparency = 0.55
vcS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
-- Linha brilho topo
local vcLine = Instance.new("Frame",verCard)
vcLine.BackgroundColor3 = U_PURPLE; vcLine.BackgroundTransparency = 0.6
vcLine.BorderSizePixel = 0
vcLine.Size = UDim2.new(0.5,0,0,1); vcLine.Position = UDim2.new(0.25,0,0,0); vcLine.ZIndex = 6
local vcLG = Instance.new("UIGradient",vcLine)
vcLG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
})
-- Texto "Versão atual do script"
local vcSub = Instance.new("TextLabel",verCard); vcSub.BackgroundTransparency = 1
vcSub.Position = UDim2.new(0,14,0,8); vcSub.Size = UDim2.new(1,-28,0,14)
vcSub.Font = Enum.Font.GothamBold; vcSub.Text = "VERSÃO ATUAL DO SCRIPT"
vcSub.TextColor3 = Color3.fromRGB(120,100,165); vcSub.TextSize = 9
vcSub.TextXAlignment = Enum.TextXAlignment.Left; vcSub.ZIndex = 6
-- Nome da versão em destaque
local vcVer = Instance.new("TextLabel",verCard); vcVer.BackgroundTransparency = 1
vcVer.Position = UDim2.new(0,14,0,24); vcVer.Size = UDim2.new(0.75,0,0,22)
vcVer.Font = Enum.Font.GothamBlack; vcVer.Text = RECENTES[1].ver
vcVer.TextColor3 = U_GOLD; vcVer.TextSize = 17
vcVer.TextXAlignment = Enum.TextXAlignment.Left; vcVer.ZIndex = 6
local vcVG = Instance.new("UIGradient",vcVer)
vcVG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, U_GOLD),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(255,235,140)),
    ColorSequenceKeypoint.new(1, U_ORANGE),
})
-- Data no canto direito
local vcDate = Instance.new("TextLabel",verCard); vcDate.BackgroundTransparency = 1
vcDate.AnchorPoint = Vector2.new(1,1); vcDate.Position = UDim2.new(1,-12,1,-8)
vcDate.Size = UDim2.new(0,180,0,12); vcDate.Font = Enum.Font.Gotham
vcDate.Text = "📅 "..RECENTES[1].date
vcDate.TextColor3 = Color3.fromRGB(130,110,160); vcDate.TextSize = 8
vcDate.TextXAlignment = Enum.TextXAlignment.Right; vcDate.ZIndex = 6

-- ── SEPARADOR "ATUAL" ────────────────────────────────────────────
mkSeparator("✦", "VERSÃO ATUAL", U_GOLD, false)

-- Renderiza versões recentes (expandidas)
for _, entry in ipairs(RECENTES) do
    mkChangelogCard(Pages["Atualizacao"], entry, false)
end

-- ── SEPARADOR "HISTÓRICO" ────────────────────────────────────────
mkSeparator("📂", "HISTÓRICO DE VERSÕES", U_MUTED, true)

-- Pequena nota sobre o histórico
local histNote = Instance.new("Frame", Pages["Atualizacao"])
histNote.BackgroundColor3 = Color3.fromRGB(20,12,38); histNote.BackgroundTransparency = 0.3
histNote.BorderSizePixel = 0; histNote.Size = UDim2.new(1,0,0,22)
histNote.LayoutOrder = uLO(); histNote.ZIndex = 5
Instance.new("UICorner",histNote).CornerRadius = UDim.new(0,8)
local histNoteL = Instance.new("TextLabel",histNote); histNoteL.BackgroundTransparency = 1
histNoteL.Position = UDim2.new(0,12,0,0); histNoteL.Size = UDim2.new(1,-20,1,0)
histNoteL.Font = Enum.Font.Gotham
histNoteL.Text = "ℹ️  Clique em uma versão para expandir os detalhes"
histNoteL.TextColor3 = Color3.fromRGB(120,105,155); histNoteL.TextSize = 8
histNoteL.TextXAlignment = Enum.TextXAlignment.Left; histNoteL.ZIndex = 6

-- Renderiza versões antigas (colapsadas / accordion)
for _, entry in ipairs(ANTIGAS) do
    mkChangelogCard(Pages["Atualizacao"], entry, true)
end

-- ── RODAPÉ ───────────────────────────────────────────────────────
local footCard = Instance.new("Frame", Pages["Atualizacao"])
footCard.BackgroundColor3 = Color3.fromRGB(14,10,32); footCard.BackgroundTransparency = 0.1
footCard.BorderSizePixel = 0; footCard.Size = UDim2.new(1,0,0,48)
footCard.LayoutOrder = uLO(); footCard.ZIndex = 5
Instance.new("UICorner",footCard).CornerRadius = UDim.new(0,14)
local footS2 = Instance.new("UIStroke",footCard)
footS2.Color = Color3.fromRGB(88,101,242); footS2.Thickness = 1.2; footS2.Transparency = 0.55
footS2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local footG = Instance.new("UIGradient",footCard)
footG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(24,18,58)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(10,6,28)),
}); footG.Rotation = 90
-- Ícone discord
local fIco = Instance.new("TextLabel",footCard); fIco.BackgroundTransparency = 1
fIco.Position = UDim2.new(0,14,0.5,-10); fIco.Size = UDim2.new(0,20,0,20)
fIco.Text = "💬"; fIco.TextSize = 16; fIco.ZIndex = 6
-- Links
local fMain = Instance.new("TextLabel",footCard); fMain.BackgroundTransparency = 1
fMain.Position = UDim2.new(0,40,0,8); fMain.Size = UDim2.new(0.6,0,0,14)
fMain.Font = Enum.Font.GothamBlack; fMain.Text = "discord.gg/pudim"
fMain.TextColor3 = Color3.fromRGB(180,190,255); fMain.TextSize = 11
fMain.TextXAlignment = Enum.TextXAlignment.Left; fMain.ZIndex = 6
local fSub = Instance.new("TextLabel",footCard); fSub.BackgroundTransparency = 1
fSub.Position = UDim2.new(0,40,0,24); fSub.Size = UDim2.new(0.75,0,0,12)
fSub.Font = Enum.Font.Gotham; fSub.Text = "Sugestões, bugs e novidades do hub"
fSub.TextColor3 = Color3.fromRGB(130,140,200); fSub.TextSize = 9
fSub.TextXAlignment = Enum.TextXAlignment.Left; fSub.ZIndex = 6
-- Versão no rodapé
local fVer = Instance.new("TextLabel",footCard); fVer.BackgroundTransparency = 1
fVer.AnchorPoint = Vector2.new(1,0.5); fVer.Position = UDim2.new(1,-12,0.5,0)
fVer.Size = UDim2.new(0,80,0,14); fVer.Font = Enum.Font.GothamBold
fVer.Text = "v6  ·  2026"; fVer.TextColor3 = Color3.fromRGB(100,90,140); fVer.TextSize = 9
fVer.TextXAlignment = Enum.TextXAlignment.Right; fVer.ZIndex = 6

end) -- [[ ATUALIZACAO TAB ]]





-- ACCORDION SYSTEM v1 — Pudim Hub v6
-- Cards expansíveis com 1 aberto por vez
-- ══════════════════════════════════════════════════════════════
local _accOpenCard  = nil
local _accCloseCard = nil

local function makeAccordionCard(parent, loFn, cfg)
    local HEADER_H  = 44
    local CONTENT_H = cfg.contentH or 100
    local TOTAL_H   = HEADER_H + CONTENT_H
    local COR       = cfg.color or Color3.fromRGB(148,112,220)
    local isOpen    = false
    local dropExtra = 0

    local card = Instance.new("Frame", parent)
    card.BackgroundColor3       = Color3.fromRGB(16,20,38)
    card.BackgroundTransparency = 0.12
    card.BorderSizePixel        = 0
    card.Size                   = UDim2.new(1,0,0,HEADER_H)
    card.LayoutOrder            = loFn()
    card.ZIndex                 = 5
    card.ClipsDescendants       = true
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,12)

    local stroke = Instance.new("UIStroke",card)
    stroke.Color          = COR
    stroke.Thickness      = 1.4
    stroke.Transparency   = 0.72
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local acBar = Instance.new("Frame",card)
    acBar.BackgroundColor3 = COR; acBar.BorderSizePixel = 0
    acBar.Size = UDim2.new(0,3,0,22)
    acBar.Position = UDim2.new(0,0,0,(HEADER_H-22)/2); acBar.ZIndex = 6
    Instance.new("UICorner",acBar).CornerRadius = UDim.new(0,2)

    local iconBg = Instance.new("Frame",card)
    iconBg.BackgroundColor3      = COR
    iconBg.BackgroundTransparency = 0.78; iconBg.BorderSizePixel = 0
    iconBg.Position = UDim2.new(0,10,0,(HEADER_H-26)/2)
    iconBg.Size = UDim2.new(0,26,0,26); iconBg.ZIndex = 6
    Instance.new("UICorner",iconBg).CornerRadius = UDim.new(0,7)
    local iconLbl = Instance.new("TextLabel",iconBg)
    iconLbl.BackgroundTransparency=1; iconLbl.Size=UDim2.new(1,0,1,0)
    iconLbl.Font=Enum.Font.GothamBold; iconLbl.Text=cfg.icon or "⚙️"
    iconLbl.TextSize=14; iconLbl.ZIndex=7

    local titleLbl = Instance.new("TextLabel",card)
    titleLbl.BackgroundTransparency=1
    titleLbl.Position=UDim2.new(0,44,0,0); titleLbl.Size=UDim2.new(1,-80,0,HEADER_H)
    titleLbl.Font=Enum.Font.GothamBlack; titleLbl.Text=cfg.title or "Função"
    titleLbl.TextColor3=Color3.fromRGB(238,232,255); titleLbl.TextSize=11
    titleLbl.TextXAlignment=Enum.TextXAlignment.Left
    titleLbl.TextYAlignment=Enum.TextYAlignment.Center; titleLbl.ZIndex=6

    local arrowLbl = Instance.new("TextLabel",card)
    arrowLbl.BackgroundTransparency=1
    arrowLbl.AnchorPoint=Vector2.new(1,0)
    arrowLbl.Position=UDim2.new(1,-12,0,(HEADER_H-18)/2)
    arrowLbl.Size=UDim2.new(0,18,0,18)
    arrowLbl.Font=Enum.Font.GothamBlack; arrowLbl.Text="▼"
    arrowLbl.TextColor3=COR; arrowLbl.TextSize=9; arrowLbl.ZIndex=7

    local divLine = Instance.new("Frame",card)
    divLine.BackgroundColor3=COR; divLine.BackgroundTransparency=0.78; divLine.BorderSizePixel=0
    divLine.Position=UDim2.new(0,10,0,HEADER_H-1)
    divLine.Size=UDim2.new(1,-20,0,1); divLine.ZIndex=6; divLine.Visible=false

    local contentFrame = Instance.new("Frame",card)
    contentFrame.BackgroundTransparency=1; contentFrame.BorderSizePixel=0
    contentFrame.Position=UDim2.new(0,0,0,HEADER_H)
    contentFrame.Size=UDim2.new(1,0,0,CONTENT_H); contentFrame.ZIndex=6
    contentFrame.ClipsDescendants=false

    if cfg.summary then
        local sumLbl = Instance.new("TextLabel",contentFrame)
        sumLbl.BackgroundTransparency=1
        sumLbl.Position=UDim2.new(0,12,0,5); sumLbl.Size=UDim2.new(1,-24,0,28)
        sumLbl.Font=Enum.Font.Gotham; sumLbl.Text=cfg.summary
        sumLbl.TextColor3=Color3.fromRGB(150,144,172); sumLbl.TextSize=9
        sumLbl.TextWrapped=true; sumLbl.TextXAlignment=Enum.TextXAlignment.Left
        sumLbl.TextYAlignment=Enum.TextYAlignment.Top; sumLbl.ZIndex=7
    end

    local function closeCard(instant)
        isOpen=false; divLine.Visible=false
        TweenService:Create(arrowLbl,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Rotation=0}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.2),{Transparency=0.72}):Play()
        if instant then card.Size=UDim2.new(1,0,0,HEADER_H)
        else TweenService:Create(card,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(1,0,0,HEADER_H)}):Play() end
        if _accOpenCard==card then _accOpenCard=nil; _accCloseCard=nil end
    end

    local function openCard()
        if _accCloseCard then _accCloseCard(true) end
        _accOpenCard=card; _accCloseCard=closeCard; isOpen=true; divLine.Visible=true
        TweenService:Create(arrowLbl,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=180}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.2),{Transparency=0.3}):Play()
        TweenService:Create(card,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,TOTAL_H+dropExtra)}):Play()
    end

    local function setDropExtraH(extra)
        dropExtra=extra or 0
        if isOpen then TweenService:Create(card,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Size=UDim2.new(1,0,0,TOTAL_H+dropExtra)}):Play() end
    end

    local hBtn=Instance.new("TextButton",card); hBtn.BackgroundTransparency=1
    hBtn.Size=UDim2.new(1,0,0,HEADER_H); hBtn.Text=""; hBtn.ZIndex=10; hBtn.AutoButtonColor=false
    hBtn.MouseButton1Click:Connect(function() if isOpen then closeCard() else openCard() end end)
    hBtn.MouseEnter:Connect(function() TweenService:Create(stroke,TweenInfo.new(0.15),{Transparency=isOpen and 0.25 or 0.55}):Play() end)
    hBtn.MouseLeave:Connect(function() TweenService:Create(stroke,TweenInfo.new(0.15),{Transparency=isOpen and 0.3 or 0.72}):Play() end)

    return card, contentFrame, setDropExtraH, openCard, closeCard
end

-- Dropdown inline profissional
local function makeMultiDropdown(parent, yPos, cfg)
    -- ════════════════════════════════════════════════════════════
    -- Dropdown multi-seleção profissional — popup no ScreenGui
    -- Checkboxes animados, categorias, botão de contagem
    -- ════════════════════════════════════════════════════════════
    local COR      = cfg.color or Color3.fromRGB(148,112,220)
    local ITEMS    = cfg.items
    local SEL      = cfg.sel
    local BTN_H    = 30
    local ITEM_H   = 36  -- altura item estilo foto
    local POP_W    = 200  -- largura popup estilo foto
    local MAX_VIS  = cfg.maxVisible or 7
    local POP_H    = math.min(MAX_VIS, #ITEMS) * ITEM_H + 56  -- 40 busca + 16 padding
    local isOpen   = false

    -- ── Monta categorias para separadores ─────────────────────
    local cats = {}; local catOrder = {}
    for _, item in ipairs(ITEMS) do
        local c = item.cat or "outros"
        if not cats[c] then cats[c] = {}; table.insert(catOrder, c) end
        table.insert(cats[c], item)
    end
    local CAT_LABELS = {
        wood="🪵 Madeira", liquid="⛽ Líquidos", chair="🪑 Móveis",
        corpse="💀 Carcaças", metal="🔩 Metais", gem="💎 Gemas",
        outros="📦 Itens",
    }

    -- ── Função buildLabel — mostra itens selecionados (estilo foto) ──
    local function buildLabel()
        local sel={} ; local n=0
        for _, item in ipairs(ITEMS) do
            if SEL[item.key] then n=n+1; table.insert(sel, item.label) end
        end
        if n==0 then return "Selecionar..." end
        if n==#ITEMS then return "Todos" end
        -- Mostra nomes separados por vírgula, trunca com "..." se necessário
        local txt = table.concat(sel, ", ")
        if #txt > 16 then txt = txt:sub(1,14).."..." end
        return txt
    end

    -- ── Label do campo à esquerda ──────────────────────────────
    local trigDdLbl = Instance.new("TextLabel", parent)
    trigDdLbl.BackgroundTransparency = 1; trigDdLbl.BorderSizePixel = 0
    trigDdLbl.Position = UDim2.new(0, 10, 0, yPos)
    trigDdLbl.Size     = UDim2.new(0.45, 0, 0, BTN_H)
    trigDdLbl.Font     = Enum.Font.GothamBold
    trigDdLbl.Text     = cfg.title or "Itens"
    trigDdLbl.TextColor3 = Color3.fromRGB(220, 210, 240); trigDdLbl.TextSize = 11
    trigDdLbl.TextXAlignment = Enum.TextXAlignment.Left
    trigDdLbl.TextYAlignment = Enum.TextYAlignment.Center; trigDdLbl.ZIndex = 7
    -- ── Botão trigger — estilo foto: marsala escuro, texto itens + ⇅ ──
    local trigBtn = Instance.new("TextButton", parent)
    trigBtn.BackgroundColor3       = Color3.fromRGB(100, 40, 50)
    trigBtn.BackgroundTransparency = 0.1
    trigBtn.BorderSizePixel        = 0
    trigBtn.AnchorPoint            = Vector2.new(1, 0.5)
    trigBtn.Position               = UDim2.new(1, -10, 0, yPos + BTN_H/2)
    trigBtn.Size                   = UDim2.new(0, 140, 0, 28)
    trigBtn.Font                   = Enum.Font.GothamBold
    trigBtn.Text                   = buildLabel()
    trigBtn.TextColor3             = Color3.fromRGB(240, 225, 235)
    trigBtn.TextSize               = 10
    trigBtn.ZIndex                 = 8
    trigBtn.AutoButtonColor        = false
    trigBtn.TextTruncate           = Enum.TextTruncate.AtEnd
    -- Padding direito para a seta não sobrepor o texto
    local trigPad = Instance.new("UIPadding", trigBtn)
    trigPad.PaddingLeft  = UDim.new(0,8)
    trigPad.PaddingRight = UDim.new(0,22)
    Instance.new("UICorner", trigBtn).CornerRadius = UDim.new(0, 8)
    -- Borda sutil
    local trigS = Instance.new("UIStroke", trigBtn)
    trigS.Color = Color3.fromRGB(160, 60, 80); trigS.Thickness = 1; trigS.Transparency = 0.4
    trigS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    -- Seta ⇅ no canto direito
    local trigArrow = Instance.new("TextLabel", trigBtn)
    trigArrow.BackgroundTransparency = 1
    trigArrow.AnchorPoint            = Vector2.new(1, 0.5)
    trigArrow.Position               = UDim2.new(1, -6, 0.5, 0)
    trigArrow.Size                   = UDim2.new(0, 14, 0, 18)
    trigArrow.Font                   = Enum.Font.GothamBold
    trigArrow.Text                   = "⇅"
    trigArrow.TextColor3             = Color3.fromRGB(200, 160, 170); trigArrow.TextSize = 11; trigArrow.ZIndex = 9

    -- ── Popup — estilo foto: marsala escuro, busca no topo, itens texto+círculo ──
    local pop = Instance.new("Frame", ScreenGui)
    pop.BackgroundColor3       = Color3.fromRGB(72, 22, 30)
    pop.BackgroundTransparency = 0
    pop.BorderSizePixel        = 0
    pop.ZIndex                 = 430
    pop.Visible                = false
    pop.Size                   = UDim2.new(0, POP_W, 0, 0)
    pop.ClipsDescendants       = true
    Instance.new("UICorner", pop).CornerRadius = UDim.new(0, 10)
    local popS = Instance.new("UIStroke", pop)
    popS.Color = Color3.fromRGB(140,50,65); popS.Thickness = 1; popS.Transparency = 0.3
    popS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Barra de busca — topo do popup, fundo levemente mais claro
    local popSearch = Instance.new("Frame", pop)
    popSearch.BackgroundColor3 = Color3.fromRGB(90, 32, 42)
    popSearch.BackgroundTransparency = 0
    popSearch.BorderSizePixel = 0
    popSearch.Size = UDim2.new(1, 0, 0, 40)
    popSearch.Position = UDim2.new(0, 0, 0, 0)
    popSearch.ZIndex = 431
    Instance.new("UICorner", popSearch).CornerRadius = UDim.new(0, 10)
    -- Fix cantos inferiores do search
    local popSearchFix = Instance.new("Frame", popSearch)
    popSearchFix.BackgroundColor3 = Color3.fromRGB(90, 32, 42)
    popSearchFix.BorderSizePixel = 0
    popSearchFix.Position = UDim2.new(0,0,0.5,0); popSearchFix.Size = UDim2.new(1,0,0.5,0); popSearchFix.ZIndex = 431
    -- Ícone lupa
    local popSearchIco = Instance.new("TextLabel", popSearch); popSearchIco.BackgroundTransparency = 1
    popSearchIco.Position = UDim2.new(0, 10, 0, 0); popSearchIco.Size = UDim2.new(0, 20, 1, 0)
    popSearchIco.Font = Enum.Font.GothamBold; popSearchIco.Text = "🔍"
    popSearchIco.TextSize = 12; popSearchIco.ZIndex = 432
    -- TextBox
    local popSearchBox = Instance.new("TextBox", popSearch); popSearchBox.BackgroundTransparency = 1
    popSearchBox.Position = UDim2.new(0, 32, 0, 0); popSearchBox.Size = UDim2.new(1, -40, 1, 0)
    popSearchBox.Font = Enum.Font.Gotham; popSearchBox.PlaceholderText = "Search..."
    popSearchBox.PlaceholderColor3 = Color3.fromRGB(180, 130, 140); popSearchBox.Text = ""
    popSearchBox.TextColor3 = Color3.fromRGB(245, 230, 235); popSearchBox.TextSize = 11
    popSearchBox.ClearTextOnFocus = false; popSearchBox.ZIndex = 432

    -- hdrAll / hdrNone como funções internas (sem UI) para manter API
    local hdrAll  = Instance.new("TextButton", pop); hdrAll.Visible=false; hdrAll.Size=UDim2.new(0,0,0,0); hdrAll.Text=""
    local hdrNone = Instance.new("TextButton", pop); hdrNone.Visible=false; hdrNone.Size=UDim2.new(0,0,0,0); hdrNone.Text=""

    -- ScrollingFrame dos itens
    local scroll = Instance.new("ScrollingFrame", pop)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel        = 0
    scroll.Position               = UDim2.new(0, 0, 0, 42)
    scroll.Size                   = UDim2.new(1, 0, 1, -44)
    scroll.ScrollBarThickness     = 2
    scroll.ScrollBarImageColor3   = Color3.fromRGB(180, 80, 100)
    scroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    scroll.ZIndex                 = 431
    local scrollLayout = Instance.new("UIListLayout", scroll)
    scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
    scrollLayout.Padding   = UDim.new(0, 0)
    local scrollPad = Instance.new("UIPadding", scroll)
    scrollPad.PaddingTop    = UDim.new(0, 4)
    scrollPad.PaddingBottom = UDim.new(0, 4)
    scrollPad.PaddingLeft   = UDim.new(0, 8)
    scrollPad.PaddingRight  = UDim.new(0, 8)

    -- ── Itens estilo foto: texto + circulinho cinza, sem ícones, sem categorias ──
    local itemRefs = {}
    local _itemVisRows = {}  -- key -> row (para filtro de busca)
    local lo = 0

    for _, item in ipairs(ITEMS) do
        local isSel = SEL[item.key] or false

        -- Row 36px — clean, sem background por padrão
        local row = Instance.new("Frame", scroll)
        row.BackgroundColor3       = Color3.fromRGB(110, 40, 52)
        row.BackgroundTransparency = isSel and 0.55 or 1
        row.BorderSizePixel        = 0
        row.Size                   = UDim2.new(1, 0, 0, 36)
        lo = lo + 1; row.LayoutOrder = lo
        row.ZIndex                 = 432
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        -- Nome do item (esquerda)
        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Position = UDim2.new(0, 8, 0, 0)
        nameLbl.Size     = UDim2.new(1, -42, 1, 0)
        nameLbl.Font     = isSel and Enum.Font.GothamBold or Enum.Font.Gotham
        nameLbl.Text     = item.label
        nameLbl.TextColor3 = isSel and Color3.fromRGB(255,240,245) or Color3.fromRGB(210,185,195)
        nameLbl.TextSize = 11
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextYAlignment = Enum.TextYAlignment.Center
        nameLbl.ZIndex   = 433

        -- Circulinho direita — cinza = desmarcado, cor do acento = marcado
        local circ = Instance.new("Frame", row)
        circ.BackgroundColor3       = isSel and Color3.fromRGB(200,90,110) or Color3.fromRGB(140,100,115)
        circ.BackgroundTransparency = isSel and 0 or 0.2
        circ.BorderSizePixel        = 0
        circ.AnchorPoint            = Vector2.new(1, 0.5)
        circ.Position               = UDim2.new(1, -8, 0.5, 0)
        circ.Size                   = UDim2.new(0, 16, 0, 16)
        circ.ZIndex                 = 433
        Instance.new("UICorner", circ).CornerRadius = UDim.new(1, 0)

        -- Botão invisível
        local iBtn = Instance.new("TextButton", row)
        iBtn.BackgroundTransparency = 1
        iBtn.Size = UDim2.new(1, 0, 1, 0)
        iBtn.Text = ""; iBtn.ZIndex = 434; iBtn.AutoButtonColor = false

        local function refreshRow(hover)
            local on = SEL[item.key]
            TweenService:Create(row, TweenInfo.new(0.1), {
                BackgroundTransparency = on and 0.55 or (hover and 0.75 or 1),
            }):Play()
            TweenService:Create(circ, TweenInfo.new(0.15), {
                BackgroundColor3       = on and Color3.fromRGB(200,90,110) or Color3.fromRGB(140,100,115),
                BackgroundTransparency = on and 0 or 0.2,
            }):Play()
            nameLbl.TextColor3 = on and Color3.fromRGB(255,240,245) or (hover and Color3.fromRGB(235,210,220) or Color3.fromRGB(210,185,195))
            nameLbl.Font       = on and Enum.Font.GothamBold or Enum.Font.Gotham
        end

        itemRefs[item.key] = refreshRow
        _itemVisRows[item.key] = row

        iBtn.MouseEnter:Connect(function()
            if not SEL[item.key] then refreshRow(true) end
        end)
        iBtn.MouseLeave:Connect(function() refreshRow(false) end)
        iBtn.MouseButton1Click:Connect(function()
            SEL[item.key] = not SEL[item.key]
            refreshRow(false)
            trigBtn.Text = buildLabel()
            if cfg.onUpdate then cfg.onUpdate() end
        end)
    end

    -- ── Filtro de busca ───────────────────────────────────────
    popSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = popSearchBox.Text:lower()
        local ord = 0
        for _, item in ipairs(ITEMS) do
            local vis = q=="" or item.label:lower():find(q,1,true)
            if _itemVisRows[item.key] then
                _itemVisRows[item.key].Visible = vis and true or false
                if vis then ord=ord+1; _itemVisRows[item.key].LayoutOrder=ord end
            end
        end
    end)

    -- ── selectAll / clearAll ──────────────────────────────────
    local function selectAll()
        for _, item in ipairs(ITEMS) do SEL[item.key] = true end
        for _, fn in pairs(itemRefs) do pcall(fn, false) end
        trigBtn.Text = buildLabel()
        if cfg.onUpdate then cfg.onUpdate() end
    end
    local function clearAll()
        for _, item in ipairs(ITEMS) do SEL[item.key] = false end
        for _, fn in pairs(itemRefs) do pcall(fn, false) end
        trigBtn.Text = buildLabel()
        if cfg.onUpdate then cfg.onUpdate() end
    end
    hdrAll.MouseButton1Click:Connect(function()
        selectAll()
        TweenService:Create(hdrAll,TweenInfo.new(0.1),{BackgroundTransparency=0.1}):Play()
        task.delay(0.2,function() TweenService:Create(hdrAll,TweenInfo.new(0.15),{BackgroundTransparency=0.6}):Play() end)
    end)
    hdrNone.MouseButton1Click:Connect(function()
        clearAll()
        TweenService:Create(hdrNone,TweenInfo.new(0.1),{BackgroundTransparency=0.05}):Play()
        task.delay(0.2,function() TweenService:Create(hdrNone,TweenInfo.new(0.15),{BackgroundTransparency=0.5}):Play() end)
    end)

    -- ── Abrir / Fechar ────────────────────────────────────────
    local function closePop()
        if not isOpen then return end; isOpen = false
        TweenService:Create(pop,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Size=UDim2.new(0,POP_W,0,0),BackgroundTransparency=0.3}):Play()
        task.delay(0.16,function() pop.Visible=false; pop.BackgroundTransparency=0 end)
        _vdOpen = nil
        TweenService:Create(trigArrow,TweenInfo.new(0.18),{Rotation=0}):Play()
        TweenService:Create(trigS,TweenInfo.new(0.1),{Transparency=0.5,Color=Color3.fromRGB(80,60,120)}):Play()
    end
    local function openPop()
        if _vdOpen and _vdOpen~=pop then
            TweenService:Create(_vdOpen,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
                {Size=UDim2.new(0,_vdOpen.AbsoluteSize.X,0,0)}):Play()
            task.delay(0.13,function() _vdOpen.Visible=false end)
        end
        -- Refresh todos os itens antes de abrir
        for _, fn in pairs(itemRefs) do pcall(fn, false) end
        -- Posiciona à direita do painel principal (estilo foto)
        local ap=trigBtn.AbsolutePosition; local as=trigBtn.AbsoluteSize
        local vp=workspace.CurrentCamera.ViewportSize
        -- Tenta abrir à direita do botão
        local px = ap.X + as.X + 6
        -- Se não cabe à direita, abre à esquerda
        if px + POP_W > vp.X - 8 then px = ap.X - POP_W - 6 end
        px = math.clamp(px, 8, vp.X - POP_W - 8)
        -- Alinha verticalmente ao botão
        local py = math.clamp(ap.Y, 8, vp.Y - POP_H - 8)
        pop.Position=UDim2.new(0,px,0,py)
        pop.Size=UDim2.new(0,POP_W,0,0); pop.BackgroundTransparency=0.3; pop.Visible=true
        TweenService:Create(pop,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Size=UDim2.new(0,POP_W,0,POP_H),BackgroundTransparency=0}):Play()
        isOpen=true; _vdOpen=pop
        TweenService:Create(trigArrow,TweenInfo.new(0.2),{Rotation=180}):Play()
        TweenService:Create(trigS,TweenInfo.new(0.1),{Transparency=0.1}):Play()
        popSearchBox.Text=""
    end

    trigBtn.MouseButton1Click:Connect(function()
        if isOpen then closePop() else openPop() end
    end)
    UserInputService.InputBegan:Connect(function(inp)
        if not isOpen then return end
        if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        local mp=UserInputService:GetMouseLocation()
        local function inside(f) local a,s=f.AbsolutePosition,f.AbsoluteSize
            return mp.X>=a.X and mp.X<=a.X+s.X and mp.Y>=a.Y and mp.Y<=a.Y+s.Y end
        if not inside(pop) and not inside(trigBtn) then closePop() end
    end)

    -- setDropH não é mais necessário (popup flutua no ScreenGui)
    local function noopDropH(_) end

    return trigBtn, nil, buildLabel, selectAll, clearAll, closePop
end
-- Alias de compatibilidade
local makeInlineDropdown = makeMultiDropdown

-- Helpers rápidos de UI
local _btnStateMap = {}  -- [btn] -> setState(bool) function
local function _accActivBtn(parent, y, icon, color)
    -- ── AMG-style: label esquerda + pill direita ──
    local iconStr = icon or "▶"
    local lbl=Instance.new("TextLabel",parent); lbl.BackgroundTransparency=1; lbl.BorderSizePixel=0
    lbl.Position=UDim2.new(0,10,0,y); lbl.Size=UDim2.new(1,-70,0,40)
    lbl.Font=Enum.Font.GothamBold; lbl.Text=iconStr.."  Ativar"
    lbl.TextColor3=Color3.fromRGB(210,200,230); lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.TextYAlignment=Enum.TextYAlignment.Center; lbl.ZIndex=7
    local btn=Instance.new("TextButton",parent)
    btn.BackgroundColor3=color or Color3.fromRGB(50,120,255); btn.BackgroundTransparency=0.1
    btn.BorderSizePixel=0; btn.AnchorPoint=Vector2.new(1,0.5)
    btn.Position=UDim2.new(1,-10,0,y+20); btn.Size=UDim2.new(0,44,0,22)
    btn.Font=Enum.Font.GothamBold; btn.Text=""
    btn.TextColor3=Color3.fromRGB(230,225,255); btn.TextSize=9; btn.ZIndex=8; btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(1,0)
    local s=Instance.new("UIStroke",btn); s.Color=color or Color3.fromRGB(80,140,255)
    s.Thickness=1.2; s.Transparency=0.45; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.1}):Play() end)
    -- setState: true=ativo, false=inativo
    local COR_OFF = color or Color3.fromRGB(50,120,255)
    local COR_ON  = Color3.fromRGB(200,50,50)
    _btnStateMap[btn] = function(on)
        TweenService:Create(btn,TweenInfo.new(0.18),{
            BackgroundColor3 = on and COR_ON or COR_OFF,
            BackgroundTransparency = 0.1,
        }):Play()
        lbl.Text = on and ("⏹  Parar") or (iconStr.."  Ativar")
        lbl.TextColor3 = on and Color3.fromRGB(255,160,160) or Color3.fromRGB(210,200,230)
    end
    return btn, s
end
local function _accStatusLbl(parent, y)
    local l=Instance.new("TextLabel",parent); l.BackgroundTransparency=1
    l.Position=UDim2.new(0,12,0,y); l.Size=UDim2.new(1,-24,0,14)
    l.Font=Enum.Font.GothamBold; l.Text=""
    l.TextColor3=Color3.fromRGB(140,200,255); l.TextSize=9
    l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=7; return l
end
local function _accDivLine(parent, y, color)
    local d=Instance.new("Frame",parent); d.BackgroundColor3=color or Color3.fromRGB(60,50,90)
    d.BackgroundTransparency=0.6; d.BorderSizePixel=0
    d.Position=UDim2.new(0,10,0,y); d.Size=UDim2.new(1,-20,0,1); d.ZIndex=7; return d
end
local function _accToggle(parent, y, label, initOn, COR, onToggle)
    -- ── Toggle iOS style: pill + knob branco deslizante ──
    local H=44
    local C_OFF = Color3.fromRGB(100,80,120)
    local tl=Instance.new("TextLabel",parent); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,12,0,y); tl.Size=UDim2.new(1,-76,0,H)
    tl.Font=Enum.Font.GothamBold; tl.Text=label
    tl.TextColor3=Color3.fromRGB(220,215,245); tl.TextSize=11
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.TextYAlignment=Enum.TextYAlignment.Center
    tl.TextWrapped=true; tl.ZIndex=7
    -- Pill container
    local pill=Instance.new("Frame",parent); pill.BorderSizePixel=0
    pill.AnchorPoint=Vector2.new(1,0.5); pill.Position=UDim2.new(1,-12,0,y+H/2)
    pill.Size=UDim2.new(0,44,0,24); pill.ZIndex=8
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    pill.BackgroundColor3=initOn and COR or C_OFF
    -- Knob branco
    local knob=Instance.new("Frame",pill); knob.BorderSizePixel=0
    knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    knob.AnchorPoint=Vector2.new(0.5,0.5); knob.ZIndex=9
    knob.Size=UDim2.new(0,18,0,18)
    knob.Position=initOn and UDim2.new(1,-13,0.5,0) or UDim2.new(0,13,0.5,0)
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    -- Sombra suave no knob
    local knobS=Instance.new("UIStroke",knob); knobS.Color=Color3.fromRGB(0,0,0)
    knobS.Thickness=0.8; knobS.Transparency=0.7; knobS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local en=initOn
    local hbtn=Instance.new("TextButton",parent); hbtn.BackgroundTransparency=1
    hbtn.Position=UDim2.new(0,0,0,y); hbtn.Size=UDim2.new(1,0,0,H); hbtn.Text=""; hbtn.ZIndex=11
    hbtn.MouseButton1Click:Connect(function()
        en=not en
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=en and COR or C_OFF}):Play()
        TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=en and UDim2.new(1,-13,0.5,0) or UDim2.new(0,13,0.5,0)
        }):Play()
        if onToggle then onToggle(en) end
    end)
    return H, pill, knob
end
-- ══════════════════════════════════════════════════════════════
-- FIM DO ACCORDION SYSTEM
-- ══
-- ══════════════════════════════════════════════════════
-- BRING ICONS (28x28)
-- ══════════════════════════════════════════════════════
local function criarIconeBring(parent, key, cor)
    local cont = Instance.new("Frame", parent)
    cont.BackgroundTransparency = 1; cont.BorderSizePixel = 0
    cont.Size = UDim2.new(0, 28, 0, 28); cont.ZIndex = parent.ZIndex + 2; cont.ClipsDescendants = false
    local function r(x,y,w,h,radius)
        local f=Instance.new("Frame",cont); f.BackgroundColor3=cor; f.BorderSizePixel=0
        f.Position=UDim2.new(0,x,0,y); f.Size=UDim2.new(0,w,0,h); f.ZIndex=cont.ZIndex+1
        if radius then Instance.new("UICorner",f).CornerRadius=UDim.new(0,radius) end; return f
    end
    local function c(cx,cy,rad) return r(cx-rad,cy-rad,rad*2,rad*2,rad*2) end
    local function dk(f) f.BackgroundColor3=Color3.fromRGB(14,8,22); return f end
    if key == "BLog" then
        r(1,8,26,12,5); local a1=r(3,10,22,8,4); a1.BackgroundColor3=Color3.fromRGB(130,80,30)
        local a2=r(7,12,14,4,3); a2.BackgroundColor3=Color3.fromRGB(100,60,20)
        r(1,8,4,12,2); r(23,8,4,12,2)
        for i=0,2 do local ln=r(5,10+i*3,18,1,0); ln.BackgroundColor3=Color3.fromRGB(150,90,35); ln.BackgroundTransparency=0.5 end
    elseif key == "BCombust" then
        r(10,0,8,10,4); r(5,6,18,14,5); r(3,12,22,8,4); dk(r(9,8,10,10,4))
        local brasa=r(11,14,6,5,3); brasa.BackgroundColor3=Color3.fromRGB(255,230,100)
    elseif key == "BCarcacas" then
        c(6,6,4); c(22,6,4); c(6,22,4); c(22,22,4); r(8,10,12,8,0)
    elseif key == "BSucata" then
        r(10,0,8,4,1); r(4,4,20,8,1); r(6,12,16,8,1); r(10,20,8,6,2); dk(r(12,5,4,6,2))
    elseif key == "BMateriais" then
        r(10,0,8,4,0); r(4,4,20,10,0); r(6,14,16,8,0); r(12,22,4,4,0)
        local shine=r(12,5,4,6,2); shine.BackgroundColor3=Color3.fromRGB(255,255,255); shine.BackgroundTransparency=0.5
    elseif key == "BComidas" then
        r(12,0,4,5,2); local leaf=r(14,1,8,5,2); leaf.BackgroundColor3=Color3.fromRGB(60,180,60)
        c(14,16,11); local brightness=r(8,7,5,5,3); brightness.BackgroundColor3=Color3.fromRGB(255,255,255); brightness.BackgroundTransparency=0.4
        local base=r(11,24,6,3,2); base.BackgroundColor3=Color3.fromRGB(180,40,40)
    elseif key == "BPeixes" then
        r(0,10,6,8,2); r(6,6,16,16,4); c(22,14,6); dk(c(23,12,2))
    elseif key == "BSementes" then
        r(12,20,4,8,1); local fl=r(2,10,10,8,4); fl.BackgroundColor3=Color3.fromRGB(60,200,70)
        local fr=r(16,10,10,8,4); fr.BackgroundColor3=Color3.fromRGB(60,200,70)
        r(12,8,4,14,2); c(14,6,5); dk(r(12,4,4,4,2))
    elseif key == "BFerr" then
        r(12,8,4,20,2); r(4,2,16,14,3); local gume=r(2,4,6,10,2); gume.BackgroundColor3=Color3.fromRGB(220,220,240); r(4,1,12,4,2)
    elseif key == "BArmas" then
        r(12,0,4,18,2); r(2,16,24,4,2); r(12,20,4,8,2)
        local edge=r(12,1,2,17,1); edge.BackgroundColor3=Color3.fromRGB(255,255,255); edge.BackgroundTransparency=0.4
    elseif key == "BAmmo" then
        r(14,0,6,3,1); r(12,3,4,3,1); r(10,6,6,2,1); r(13,8,2,14,0)
        local p1=r(8,22,6,3,1); p1.BackgroundColor3=Color3.fromRGB(255,200,80)
        local p2=r(14,22,6,3,1); p2.BackgroundColor3=Color3.fromRGB(255,200,80); r(12,25,4,3,1)
    elseif key == "BCura" then
        r(10,2,8,24,3); r(2,10,24,8,3); dk(r(11,11,6,6,2))
    elseif key == "BPelts" then
        r(4,0,20,4,2); r(1,4,26,16,2); r(3,20,22,4,1)
        local s1=r(6,2,4,20,1); s1.BackgroundTransparency=0.5
        local s2=r(18,2,4,20,1); s2.BackgroundTransparency=0.5; dk(r(9,6,10,10,2))
    elseif key == "BChaves" then
        c(8,8,7); dk(c(8,8,4)); r(13,6,12,4,2); r(21,10,4,4,0); r(17,10,4,4,0)
    elseif key == "BBigorna" then
        r(6,0,16,6,2); r(2,6,24,4,0); r(6,10,16,12,2); r(8,22,12,4,1)
    elseif key == "BPocoes" then
        r(10,0,8,4,0); r(8,4,12,4,0); r(4,8,20,16,5); dk(r(7,11,14,8,3))
        local bubble=r(10,13,4,4,5); bubble.BackgroundColor3=Color3.fromRGB(255,255,255); bubble.BackgroundTransparency=0.5
    elseif key == "BMadeira" then
        -- Tronco de árvore com anéis
        r(10,16,8,10,2); r(6,8,16,10,2); r(8,2,12,8,2)
        local ring=r(12,10,4,4,5); ring.BackgroundColor3=Color3.fromRGB(140,80,30); ring.BackgroundTransparency=0.4
        local ring2=r(11,18,6,4,5); ring2.BackgroundColor3=Color3.fromRGB(140,80,30); ring2.BackgroundTransparency=0.4
    elseif key == "BBlueprint" then
        r(4,0,20,24,2)
        local l1=r(7,4,14,2,0); l1.BackgroundColor3=Color3.fromRGB(100,160,255)
        local l2=r(7,8,14,2,0); l2.BackgroundColor3=Color3.fromRGB(100,160,255)
        local l3=r(7,12,10,2,0); l3.BackgroundColor3=Color3.fromRGB(100,160,255)
        local l4=r(7,16,12,2,0); l4.BackgroundColor3=Color3.fromRGB(100,160,255)
        dk(r(18,18,6,6,0))
    end
    return cont
end

local ESP_ACCENT = Color3.fromRGB(148,112,220)
local _dbgOk_5249, _dbgErr_5249 = pcall(function() -- [[ ESP1 ]]
-- ESP ICONS (14x14)
-- ══════════════════════════════════════════════════════
local function criarIconeEsp(parent, key, cor)
    local cont = Instance.new("Frame", parent)
    cont.BackgroundTransparency = 1; cont.BorderSizePixel = 0
    cont.Size = UDim2.new(0, 14, 0, 14); cont.ZIndex = parent.ZIndex + 2; cont.ClipsDescendants = false
    local function r(x,y,w,h,radius)
        local f=Instance.new("Frame",cont); f.BackgroundColor3=cor; f.BorderSizePixel=0
        f.Position=UDim2.new(0,x,0,y); f.Size=UDim2.new(0,w,0,h); f.ZIndex=cont.ZIndex+1
        if radius then Instance.new("UICorner",f).CornerRadius=UDim.new(0,radius) end; return f
    end
    local function c(cx,cy,rad) return r(cx-rad,cy-rad,rad*2,rad*2,rad*2) end
    local function dk(f) f.BackgroundColor3=Color3.fromRGB(40,24,68); return f end
    if key == "Players" then
        c(7,4,3); r(4,8,6,5,2); r(4,13,2,5,1); r(8,13,2,5,1)
    elseif key == "Kids" then
        c(7,3,2); r(5,6,4,3,1); r(2,5,3,2,1); r(9,5,3,2,1); r(5,9,2,4,1); r(7,9,2,4,1)
    elseif key == "Animais" then
        -- pata: círculo central + 3 dedos em cima + polegar
        c(7,9,4); c(3,5,2); c(7,4,2); c(11,5,2); c(2,9,2)
    elseif key == "Monstros" then
        c(7,5,5); r(3,8,8,5,1); dk(r(4,9,2,2,1)); dk(r(8,9,2,2,1)); dk(r(6,11,2,2,0))
    elseif key == "Cultistas" then
        c(7,3,2); r(3,2,8,4,2); r(2,6,10,7,3); dk(r(6,5,2,5,0))
    elseif key == "Aliens" then
        c(7,5,5); r(4,1,6,5,3); dk(c(4,6,2)); dk(c(10,6,2)); r(5,10,4,1,0)
    elseif key == "EspLog" then
        r(1,4,12,6,2); c(1,7,3); c(13,7,3)
    elseif key == "EspCombustivel" then
        r(5,0,4,5,2); r(3,4,8,5,2); r(1,7,12,5,2); dk(r(5,9,4,3,2))
    elseif key == "EspCarcacas" then
        c(3,3,2); c(11,3,2); c(3,11,2); c(11,11,2); r(4,5,6,4,0)
    elseif key == "EspSucata" then
        r(5,0,4,2,0); r(3,2,8,8,1); dk(c(7,6,3)); r(5,10,4,4,0)
    elseif key == "EspMateriais" then
        r(4,0,6,2,0); r(1,2,12,5,0); r(3,7,8,5,0); r(6,12,2,2,0)
    elseif key == "EspComidas" then
        c(7,8,5); r(6,2,2,4,1)
        local leaf=r(8,2,4,3,2); leaf.BackgroundColor3=Color3.fromRGB(60,180,60)
    elseif key == "EspPeixes" then
        r(0,5,3,4,1); r(3,3,8,8,3); c(11,7,3); dk(c(12,6,1))
    elseif key == "EspSementes" then
        c(7,2,2); r(6,4,2,6,0)
        local lf=c(3,6,2); local rf=c(11,6,2)
        lf.BackgroundColor3=Color3.fromRGB(60,200,70); rf.BackgroundColor3=Color3.fromRGB(60,200,70); c(7,11,2)
    elseif key == "EspFerr" then
        r(6,0,2,10,1); r(2,2,8,6,2); r(1,3,3,4,1)
    elseif key == "EspArmas" then
        r(6,0,2,10,1); r(2,9,10,2,1); r(6,11,2,3,1)
    elseif key == "EspAmmo" then
        c(7,3,3); r(5,3,4,7,0); r(4,10,6,3,1)
    elseif key == "EspCura" then
        r(5,0,4,14,2); r(0,5,14,4,2)
    elseif key == "EspChaves" then
        c(4,4,4); dk(c(4,4,2)); r(7,3,6,2,1); r(11,5,2,2,0); r(9,5,2,2,0)
    elseif key == "EspBigorna" then
        r(3,0,8,3,1); r(1,3,12,2,0); r(3,5,8,7,1); r(4,12,6,2,0)
    elseif key == "EspPocoes" then
        r(5,0,4,2,0); r(4,2,6,2,0); r(2,4,10,8,3); dk(r(4,6,6,4,2))
    elseif key == "EspBlueprint" then
        r(2,0,10,12,2)
        local l1=r(4,2,6,1,0); local l2=r(4,4,6,1,0); local l3=r(4,6,4,1,0); local l4=r(4,8,5,1,0)
        l1.BackgroundColor3=Color3.fromRGB(100,150,255); l2.BackgroundColor3=Color3.fromRGB(100,150,255)
        l3.BackgroundColor3=Color3.fromRGB(100,150,255); l4.BackgroundColor3=Color3.fromRGB(100,150,255)
        dk(r(8,9,4,3,0))
    end
    return cont
end

-- ════════════════════════════════════════════════════════
-- ESP v4 SYSTEM — 20 categories
-- ════════════════════════════════════════════════════════
-- ════════════════════════════════════════════════════════════════
-- ESP SYSTEM v2 — Pudim Hub v6
-- Estilos: Notificação | Simples | Profissional
-- Cores: global + por categoria + intensidade
-- ════════════════════════════════════════════════════════════════

local EspCanvas = Instance.new("Frame", ScreenGui)
EspCanvas.BackgroundTransparency = 1; EspCanvas.Size = UDim2.new(1,0,1,0); EspCanvas.ZIndex = 1

-- ── Variáveis de estado globais ──────────────────────────────────
local espStyle     = "profissional"  -- "notificacao" | "simples" | "profissional"
local espGlobalCor = Color3.fromRGB(148, 112, 220)  -- cor padrão (roxo)
local espIntensity = "normal"  -- "mega_fraca" | "fraca" | "normal" | "forte" | "mega_forte" | "neon" | "transparente"
local espCatColors = {}        -- [catKey] = Color3 override por categoria
local espAtivo     = {}
local lastCache    = 0
local cacheBuilding= false
local CACHE_INTER  = 2.0
local entityCache  = {}
local itemCache    = {}
local dtAcc        = 0
local RENDER_I     = 1/20

-- ── Notificação style state ───────────────────────────────────────
local notifQueue   = {}  -- fila de notifESP pendentes
local notifActive  = {}  -- [key] = frame ativo
local NOTIF_MAX    = 6   -- máximo de notifs ESP na tela

-- ── Color helpers ─────────────────────────────────────────────────
local function espGetCor(catKey, baseCor)
    local cor = espCatColors[catKey] or espGlobalCor or baseCor
    local a = espIntensity
    if a == "mega_fraca"    then return Color3.new(cor.R*0.35+0.6, cor.G*0.35+0.6, cor.B*0.35+0.6) end
    if a == "fraca"         then return Color3.new(cor.R*0.6+0.35, cor.G*0.6+0.35, cor.B*0.6+0.35) end
    if a == "forte"         then return Color3.new(math.min(cor.R*1.3,1), math.min(cor.G*1.3,1), math.min(cor.B*1.3,1)) end
    if a == "mega_forte"    then return Color3.new(math.min(cor.R*1.7,1), math.min(cor.G*1.7,1), math.min(cor.B*1.7,1)) end
    if a == "neon"          then return Color3.new(math.min(cor.R*2,1), math.min(cor.G*2,1), math.min(cor.B*2,1)) end
    if a == "transparente"  then return cor end  -- transparency handled by alpha
    return cor  -- normal / padrão
end
local function espGetAlpha(base)
    local a = espIntensity
    if a == "mega_fraca"    then return base + 0.65 end
    if a == "fraca"         then return base + 0.35 end
    if a == "forte"         then return math.max(base - 0.15, 0) end
    if a == "mega_forte"    then return math.max(base - 0.3, 0) end
    if a == "neon"          then return math.max(base - 0.45, 0) end
    if a == "transparente"  then return base + 0.5 end
    return base
end

-- ── ESP CATS (mantidas iguais) ─────────────────────────────────────
local ESP_CATS = {
    {key="Players",      trLabel="espPlayersLabel",trDesc="espPlayersDesc",label="👤 Players",            cor=Color3.fromRGB(255,80,80),   tipo="player", alcance=math.huge, desc="Todos os players no servidor"},
    {key="Kids", trLabel="espKidsLabel",trDesc="espKidsDesc",label="👶 Lost Children", cor=Color3.fromRGB(100,220,255), tipo="entity", alcance=math.huge, desc="Lost Child, Lost Child2, Lost Child3, Lost Child4",
     nomes={"Lost Child","Lost Child2","Lost Child3","Lost Child4",
            "LostChild","LostChild2","LostChild3","LostChild4",
            "Dino Kid","DinoKid","Kraken Kid","KrakenKid","Squid Kid","SquidKid","Koala Kid","KoalaKid",
            "child. 1","child.1","child 1","child1",
            "child. 2","child.2","child 2","child2",
            "child. 3","child.3","child 3","child3",
            "child. 4","child.4","child 4","child4"}},
    {key="Animais", trLabel="espAnimaisLabel",trDesc="espAnimaisDesc",label="🐾 Animals", cor=Color3.fromRGB(130,220,100), tipo="entity", alcance=700,
     desc="Bunny, Horse, Kiwi, Turkey, Wolf, Alpha Wolf, Bear, Polar Bear, Arctic Fox, Frog, Scorpion, Mammoth, Hellephant, Meteor Crab, Boar, Mossy Mammoth, Cat",
     nomes={"Bunny","Horse","Kiwi","Turkey","Kiwi Bird","Wolf","Alpha Wolf","AlphaWolf",
             "Bear","Polar Bear","PolarBear","Arctic Fox","ArcticFox",
             "Frog","Blue Frog","Purple Frog","Green Frog","Red Frog","BlueFrog","PurpleFrog","GreenFrog","RedFrog",
             "Scorpion","Mammoth","Mossy Mammoth","MossyMammoth",
             "Hellephant","Meteor Crab","MeteorCrab",
             "Boar","boar"}},
    {key="Monstros", trLabel="espMonstrosLabel",trDesc="espMonstrosDesc",label="💀 Monsters", cor=Color3.fromRGB(255,50,50), tipo="entity", alcance=math.huge,
     nomes={"The Deer","TheDeer","Hungry Deer","HungryDeer",
             "The Owl","TheOwl",
             "The Ram","TheRam",
             "The Bat","TheBat","Giant Bat","GiantBat",
             "The Cat","TheCat","Cat Entity","CatEntity",
             "Shadow","Nightmare","Phantom"}},
    {key="Cultistas", trLabel="espCultistasLabel",trDesc="espCultistasDesc",label="⚔️ Cultists", cor=Color3.fromRGB(200,80,255), tipo="entity", alcance=600,
     nomes={"Cultist","Cultist Beast","CultistBeast","Cultist Juggernaut","CultistJuggernaut",
             "Cultist King","CultistKing","Mega Cultist","MegaCultist",
             "Cultist Archer","CultistArcher","Cultist Mage","CultistMage",
             "Jungle Cultist","JungleCultist",
             "Shadow Cultist","ShadowCultist",
             "Brute Cultist","BruteCultist",
             "Dasksting Cultist","DaskstingCultist","Darksting Cultist","DarkstingCultist"}},
    {key="Aliens", trLabel="espAliensLabel",trDesc="espAliensDesc",label="👽 Aliens", cor=Color3.fromRGB(100,255,180), tipo="entity", alcance=800,
     nomes={"Alien","Elite Alien","EliteAlien","Alien Boss","AlienBoss","UFO Alien","UFOAlien"}},
    {key="EspLog",       trLabel="espLogLabel",      trDesc="espLogDesc",      label="🪵 Log",          cor=Color3.fromRGB(190,130,60),  tipo="item", alcance=300, nomes={"Log","Super Log","SuperLog"}},
    {key="EspCombustivel",trLabel="espCombustivelLabel",trDesc="espCombustivelDesc",label="🔥 Fuel",    cor=Color3.fromRGB(255,120,30),  tipo="item", alcance=250, nomes={"Coal","Biofuel","Oil Barrel","OilBarrel","Fuel Canister","FuelCanister","Chair"}},
    {key="EspCarcacas",  trLabel="espCarcacasLabel",  trDesc="espCarcacasDesc",  label="🦴 Corpses",    cor=Color3.fromRGB(180,100,50),  tipo="item", alcance=350,
     nomes={"Wolf Corpse","WolfCorpse","Alpha Wolf Corpse","AlphaWolfCorpse",
             "Bear Corpse","BearCorpse","Polar Bear Corpse","PolarBearCorpse",
             "Arctic Fox Corpse","ArcticFoxCorpse",
             "Mammoth Corpse","MammothCorpse","Mossy Mammoth Corpse","MossyMammothCorpse",
             "Hellephant Corpse","HellephantCorpse",
             "Frog Corpse","FrogCorpse",
             "Scorpion Corpse","ScorpionCorpse",
             "Meteor Crab Corpse","MeteorCrabCorpse",
             "Boar Corpse","BoarCorpse",
             "Cat Corpse","CatCorpse",
             "Deer Corpse","DeerCorpse","Bunny Corpse","BunnyCorpse",
             "Cultist Corpse","CultistCorpse"}},
    {key="EspSucata",    trLabel="espSucataLabel",    trDesc="espSucataDesc",    label="🔩 Scrap",      cor=Color3.fromRGB(160,170,180), tipo="item", alcance=300,
     nomes={"Bolt","Sheet Metal","SheetMetal","Tyre",
             "Broken Fan","BrokenFan","Old Radio","OldRadio","Broken Radio","BrokenRadio",
             "Metal Chair","MetalChair","Broken Microwave","BrokenMicrowave",
             "Old Car Engine","OldCarEngine","Washing Machine","WashingMachine",
             "UFO Junk","UFOJunk","UFO Component","UFOComponent","UFO Scrap","UFOScrap",
             "Alien Junk","AlienJunk",
             "Meteor Shard","MeteorShard","Gold Shard","GoldShard"}},
    {key="EspMateriais", trLabel="espMateriaisLabel", trDesc="espMateriaisDesc", label="💎 Materials",  cor=Color3.fromRGB(180,120,255), tipo="item", alcance=300,
     nomes={"Cultist Gem","CultistGem","Cultist Experiment","CultistExperiment","Cultist Prototype","CultistPrototype",
             "Raw Obsidiron Ore","RawObsidironOre","Obsidiron Ingot","ObsidironIngot","Scalding Obsidiron Ingot","ScaldingObsidironIngot",
             "Forest Gem","ForestGem","Forest Gem Fragment","ForestGemFragment","Gem of the Forest Fragment",
             "Moss Coin","MossCoin","Mossy Coin","MossyCoin",
             "Feather","Alien Tech","AlienTech"}},
    {key="EspComidas",   trLabel="espComidasLabel",   trDesc="espComidasDesc",   label="🍖 Food",       cor=Color3.fromRGB(255,180,60),  tipo="item", alcance=250,
     nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake","Mushroom","Truffle",
             "Giant Carrot","GiantCarrot",
             "Steak","Cooked Steak","CookedSteak",
             "Ribs","Cooked Ribs","CookedRibs",
             "Turkey Leg","TurkeyLeg","Cooked Turkey Leg","CookedTurkeyLeg",
             "Morsel","Morsel?","Cooked Morsel","CookedMorsel",
             "Stew","Hearty Stew","HeartyStew",
             "BBQ Ribs","BBQRibs","Steak Dinner","SteakDinner",
             "Seafood Chowder","SeafoodChowder","Pumpkin Soup","PumpkinSoup",
             "Carrot Cake","CarrotCake","Stuffing","Sweet Potato","SweetPotato"}},
    {key="EspPeixes",    trLabel="espPeixesLabel",    trDesc="espPeixesDesc",    label="🐟 Fish",        cor=Color3.fromRGB(80,200,220),  tipo="item", alcance=350, nomes={"Mackerel","Salmon","Clownfish","Shark","Eel","Lava Eel","LavaEel","Swordfish","Char","Lionfish","Jellyfish"}},
    {key="EspSementes",  trLabel="espSementesLabel",  trDesc="espSementesDesc",  label="🌱 Seeds",      cor=Color3.fromRGB(100,220,100), tipo="item", alcance=200,
     nomes={"Pepper Seed","Berry Seed","Flower Seed","Firefly Seed","Dripleaf Seed",
             "Chili Seeds","ChiliSeeds","Berry Seeds","BerrySeeds","Flower Seeds","FlowerSeeds",
             "Moonflower Seeds","MoonflowerSeeds","Stareweed Seeds","StareweedSeeds",
             "Cavevine Seeds","CavevineSeeds","Cave Vine Seeds","CaveVineSeeds",
             "Mandrake Seeds","MandrakeSeeds","Firefly Seeds","FireflySeeds"}},
    {key="EspFerr",      trLabel="espFerrLabel",      trDesc="espFerrDesc",      label="🪓 Tools",      cor=Color3.fromRGB(200,180,100), tipo="item", alcance=400,
     nomes={"Axe","Bag","Rod","Flute","Armor","Pickaxe","Shovel","Hammer","Fishing Rod",
             "Flashlight","Old Flashlight","OldFlashlight","Strong Flashlight","StrongFlashlight",
             "Sack","Old Sack","OldSack","Good Sack","GoodSack","Giant Sack","GiantSack",
             "Trim Kit","TrimKit","Axe Trim Kit","AxeTrimKit","Armor Trim Kit","ArmorTrimKit",
             "Watering Can","WateringCan","Taming Flute","TamingFlute",
             "Egg Basket","EggBasket"}},
    {key="EspArmas",     trLabel="espArmasLabel",     trDesc="espArmasDesc",     label="⚔️ Weapons",    cor=Color3.fromRGB(255,100,100), tipo="item", alcance=500,
     nomes={"Spear","Crossbow","Ice Sword","IceSword","Revolver","Rifle","Bow","Arrow","Sword","Knife","Dagger",
             "Carrot Dart","CarrotDart",
             "Blowpipe","Kunai","Katana","Trident",
             "Poison Spear","PoisonSpear","Morningstar","Scythe",
             "Laser Sword","LaserSword","Infernal Sword","InfernalSword",
             "Obsidiron Hammer","ObsidironHammer",
             "Tactical Shotgun","TacticalShotgun","Ray Gun","RayGun",
             "Laser Cannon","LaserCannon","Flamethrower","Wildfire",
             "Frozen Shuriken","FrozenShuriken","Cultist King Mace","CultistKingMace"}},
    {key="EspAmmo",      trLabel="espAmmoLabel",      trDesc="espAmmoDesc",      label="🔫 Ammo",       cor=Color3.fromRGB(255,160,60),  tipo="item", alcance=400,
     nomes={"Bullet","Arrow","Bolt Ammo","BoltAmmo","Shell","Magazine",
             "Carrot Dart","CarrotDart",
             "Revolver Ammo","RevolverAmmo","Rifle Ammo","RifleAmmo",
             "Shotgun Ammo","ShotgunAmmo",
             "Crossbow Bolt","CrossbowBolt","Crossbow Bolts","CrossbowBolts"}},
    {key="EspCura",      trLabel="espCuraLabel",      trDesc="espCuraDesc",      label="💊 Medical",    cor=Color3.fromRGB(100,255,150), tipo="item", alcance=350, nomes={"Bandage","Health Potion","HealthPotion","Antidote","Medkit","Healing Herb"}},
    {key="EspChaves",    trLabel="espChavesLabel",    trDesc="espChavesDesc",    label="🗝️ Keys",        cor=Color3.fromRGB(255,220,80),  tipo="item", alcance=500, nomes={"Key","Master Key","MasterKey","Keycard","Access Key","AccessKey","Red Key","RedKey","Blue Key","BlueKey","Yellow Key","YellowKey","Grey Key","GreyKey","Frog Key","FrogKey"}},
    {key="EspBigorna",   trLabel="espBigornaLabel",   trDesc="espBigornaDesc",   label="⚒️ Anvil",       cor=Color3.fromRGB(160,160,180), tipo="item", alcance=600, nomes={"Anvil","Forge","Workbench","Recycler"}},
    {key="EspBlueprint", trLabel="espBlueprintLabel", trDesc="espBlueprintDesc", label="📋 Blueprint",   cor=Color3.fromRGB(100,180,255), tipo="item", alcance=400,
     nomes={"Blueprint","Schematic","Recipe",
             "Recycler Blueprint","RecyclerBlueprint",
             "Log Gate Blueprint","LogGateBlueprint",
             "Flag Blueprint","FlagBlueprint",
             "Totem Pole Blueprint","TotemPoleBlueprint"}},
    {key="EspPelts",     trLabel="espPeltsLabel",     trDesc="espPeltsDesc",     label="🦺 Pelts",       cor=Color3.fromRGB(200,150,100), tipo="item", alcance=300,
     nomes={"Wolf Pelt","WolfPelt","Alpha Wolf Pelt","AlphaWolfPelt",
             "Bear Pelt","BearPelt","Polar Bear Pelt","PolarBearPelt",
             "Arctic Fox Pelt","ArcticFoxPelt",
             "Boar Pelt","BoarPelt",
             "Bunny Foot","BunnyFoot",
             "Mammoth Tusk","MammothTusk",
             "Scorpion Shell","ScorpionShell",
             "Cultist King Antler","CultistKingAntler",
             "Fur","Hide","Leather"}},
    {key="EspPocoes",    trLabel="espPocoesLabel",    trDesc="espPocoesDesc",    label="🧪 Potions",     cor=Color3.fromRGB(200,100,255), tipo="item", alcance=350,
     nomes={"Potion","Energy Drink","EnergyDrink","Speed Potion","SpeedPotion","Strength Potion","StrengthPotion",
             "Dripleaf","Moonflower","Stareweed","Cave Vine","CaveVine","Mandrake","Firefly","Glowing Mushroom","GlowingMushroom"}},
}

for _,c in ipairs(ESP_CATS) do espAtivo[c.key]=false end

-- Build lookup
local espLookup = {}
for _,c in ipairs(ESP_CATS) do
    if c.nomes then
        local s={}; for _,n in ipairs(c.nomes) do s[n:lower()]=true end
        espLookup[c.key]=s
    end
end

-- ── Match helpers ─────────────────────────────────────────────────
local function anyEspActive(tipo)
    for _,c in ipairs(ESP_CATS) do
        if espAtivo[c.key] and c.tipo==tipo then return true end
    end
    return false
end
local function matchEspCat(nameL, catKey)
    local lk = espLookup[catKey]; if not lk then return false end
    if lk[nameL] then return true end
    for kName in pairs(lk) do
        if nameL:find(kName,1,true) then return true end
    end
    return false
end
local function findCat(nameL, tipo, ignoreActive)
    for _,c in ipairs(ESP_CATS) do
        if (ignoreActive or espAtivo[c.key]) and c.tipo==tipo and matchEspCat(nameL,c.key) then
            return c
        end
    end
    return nil
end

-- ══════════════════════════════════════════════════════════════════
-- CACHE SYSTEM (mantido igual, robusto)
-- ══════════════════════════════════════════════════════════════════
local function buildCache()
    if cacheBuilding then return end
    local now = tick(); if now - lastCache < CACHE_INTER then return end
    lastCache = now; cacheBuilding = true
    task.spawn(function()
        local newEnt={};  local newItem={}
        local doEnt  = true  -- cacheia todas entidades sempre (filtro no render)
        local doItem = true  -- cacheia todos items sempre (filtro no render)
        if not doEnt and not doItem then
            entityCache=newEnt; itemCache=newItem; cacheBuilding=false; return
        end
        local pchars={}
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl.Character then pchars[pl.Character]=true end
        end
        local allObjs={}
        pcall(function()
            for _,o in ipairs(workspace:GetDescendants()) do allObjs[#allObjs+1]=o end
        end)
        pcall(function()
            local iF=workspace:FindFirstChild("Items")
            if iF then for _,o in ipairs(iF:GetChildren()) do allObjs[#allObjs+1]=o end end
        end)
        local seenEnt={};  local batch=0
        for _,obj in ipairs(allObjs) do
            batch=batch+1; if batch%100==0 then task.wait() end
            if obj and obj.Parent then
                if doEnt and obj:IsA("Model") and not pchars[obj] then
                    local id=tostring(obj)
                    if not seenEnt[id] then
                        local hum=obj:FindFirstChildWhichIsA("Humanoid")
                        if hum and hum.Health>0 then
                            local hrp=obj:FindFirstChild("HumanoidRootPart")
                                   or obj:FindFirstChild("Torso")
                                   or obj:FindFirstChildWhichIsA("BasePart")
                            if hrp then
                                local cat=findCat(obj.Name:lower(),"entity",true)
                                if cat then
                                    seenEnt[id]=true
                                    newEnt[#newEnt+1]={key=cat.key,cor=cat.cor,nome=obj.Name,alcance=cat.alcance,obj=obj,hrp=hrp,icon=cat.label:sub(1,2)}
                                end
                            end
                        end
                    end
                elseif doItem and obj:IsA("Model") and not pchars[obj] then
                    if not obj:FindFirstChildWhichIsA("Humanoid") then
                        local cat=findCat(obj.Name:lower(),"item",true)
                        if cat then
                            local part=obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
                            if part then
                                newItem[#newItem+1]={key=cat.key,cor=cat.cor,nome=obj.Name,alcance=cat.alcance,obj=part,icon=cat.label:sub(1,2)}
                            end
                        end
                    end
                elseif doItem and obj:IsA("BasePart") then
                    local par=obj.Parent
                    local isNPC=par and par:IsA("Model") and par:FindFirstChildWhichIsA("Humanoid")
                    if not isNPC and not pchars[par] then
                        local nmCheck=(par and par:IsA("Model")) and par.Name:lower() or obj.Name:lower()
                        local dispName=(par and par:IsA("Model")) and par.Name or obj.Name
                        local cat=findCat(nmCheck,"item",true)
                        if cat then
                            newItem[#newItem+1]={key=cat.key,cor=cat.cor,nome=dispName,alcance=cat.alcance,obj=obj,icon=cat.label:sub(1,2)}
                        end
                    end
                end
            end
        end
        entityCache=newEnt; itemCache=newItem; cacheBuilding=false
    end)
end

-- ══════════════════════════════════════════════════════════════════
-- RENDER: ESTILO "SIMPLES" — Hitbox + nome + distância + ícone
-- ══════════════════════════════════════════════════════════════════
local POOL_SIZE=150; local labelPool={}; local activeLabels={}

local function newSimpleLabel()
    local f=Instance.new("Frame",EspCanvas)
    f.BackgroundTransparency=1; f.BorderSizePixel=0
    f.Size=UDim2.new(0,160,0,36); f.Visible=false; f.ZIndex=12

    -- Fundo pill
    local bg=Instance.new("Frame",f); bg.Name="BG"
    bg.BackgroundColor3=Color3.fromRGB(8,6,18); bg.BackgroundTransparency=0.25
    bg.BorderSizePixel=0; bg.Size=UDim2.new(1,0,1,0); bg.ZIndex=12
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,8)
    -- Borda colorida
    local bg_s=Instance.new("UIStroke",bg); bg_s.Name="S"
    bg_s.Thickness=1.5; bg_s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

    -- Ícone
    local ico=Instance.new("TextLabel",f); ico.Name="ICO"
    ico.BackgroundTransparency=1; ico.Position=UDim2.new(0,6,0,0)
    ico.Size=UDim2.new(0,22,1,0); ico.Font=Enum.Font.GothamBold
    ico.TextSize=16; ico.ZIndex=13

    -- Nome
    local nl=Instance.new("TextLabel",f); nl.Name="NL"
    nl.BackgroundTransparency=1; nl.Position=UDim2.new(0,30,0,2)
    nl.Size=UDim2.new(1,-36,0,16); nl.Font=Enum.Font.GothamBlack
    nl.TextSize=11; nl.TextXAlignment=Enum.TextXAlignment.Left
    nl.TextStrokeTransparency=0.2; nl.TextStrokeColor3=Color3.new(0,0,0)
    nl.TextTruncate=Enum.TextTruncate.AtEnd; nl.ZIndex=13

    -- Distância
    local dl=Instance.new("TextLabel",f); dl.Name="DL"
    dl.BackgroundTransparency=1; dl.Position=UDim2.new(0,30,0,18)
    dl.Size=UDim2.new(1,-36,0,12); dl.Font=Enum.Font.GothamBold
    dl.TextSize=9; dl.TextColor3=Color3.fromRGB(200,200,220)
    dl.TextXAlignment=Enum.TextXAlignment.Left; dl.ZIndex=13

    -- Linha accent esquerda
    local bar=Instance.new("Frame",f); bar.Name="BAR"
    bar.BorderSizePixel=0; bar.Position=UDim2.new(0,0,0.1,0)
    bar.Size=UDim2.new(0,3,0.8,0); bar.ZIndex=13
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)

    return f
end

for i=1,POOL_SIZE do table.insert(labelPool,newSimpleLabel()) end

local function showSimple(cor,icon,nome,dist,sx,sy)
    local f=table.remove(labelPool); if not f then return end
    local c=espGetCor(nil,cor)
    local a=espGetAlpha(0.25)
    f.Position=UDim2.new(0,sx-80,0,sy-18); f.Visible=true
    local bg=f:FindFirstChild("BG")
    if bg then
        bg.BackgroundTransparency=a
        local s=bg:FindFirstChildOfClass("UIStroke")
        if s then s.Color=c; s.Transparency=math.max(0,a-0.2) end
    end
    local bar=f:FindFirstChild("BAR"); if bar then bar.BackgroundColor3=c end
    local ico=f:FindFirstChild("ICO"); if ico then ico.Text=icon; ico.TextColor3=c end
    local nl=f:FindFirstChild("NL"); if nl then nl.Text=nome; nl.TextColor3=c end
    local dl=f:FindFirstChild("DL"); if dl then dl.Text=string.format("%.0f m",dist) end
    table.insert(activeLabels,f)
end

local function releaseAllSimple()
    for _,f in ipairs(activeLabels) do
        f.Visible=false; table.insert(labelPool,f)
    end
    activeLabels={}
end

-- ══════════════════════════════════════════════════════════════════
-- RENDER: ESTILO "PROFISSIONAL" — Elegante com HP bar e ícone
-- ══════════════════════════════════════════════════════════════════
local proPool={}; local proActive={}
local PRO_POOL=100

local function newProLabel()
    local f=Instance.new("Frame",EspCanvas)
    f.BackgroundTransparency=1; f.BorderSizePixel=0
    f.Size=UDim2.new(0,180,0,44); f.Visible=false; f.ZIndex=12

    -- Card glass
    local card=Instance.new("Frame",f); card.Name="CARD"
    card.BackgroundColor3=Color3.fromRGB(5,4,12); card.BackgroundTransparency=0.15
    card.BorderSizePixel=0; card.Size=UDim2.new(1,0,1,0); card.ZIndex=12
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
    -- Borda
    local cs=Instance.new("UIStroke",card); cs.Name="CS"
    cs.Thickness=1.2; cs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    -- Brilho topo
    local shine=Instance.new("Frame",card)
    shine.BackgroundColor3=Color3.fromRGB(255,255,255); shine.BackgroundTransparency=0.88
    shine.BorderSizePixel=0; shine.Size=UDim2.new(0.5,0,0,1)
    shine.Position=UDim2.new(0.25,0,0,0); shine.ZIndex=13

    -- Ícone circle
    local ic=Instance.new("Frame",card); ic.Name="IC"
    ic.BorderSizePixel=0; ic.Position=UDim2.new(0,6,0.5,-14)
    ic.Size=UDim2.new(0,28,0,28); ic.ZIndex=13
    Instance.new("UICorner",ic).CornerRadius=UDim.new(1,0)
    local ico=Instance.new("TextLabel",ic); ico.Name="ICO"
    ico.BackgroundTransparency=1; ico.Size=UDim2.new(1,0,1,0)
    ico.Font=Enum.Font.GothamBold; ico.TextSize=15; ico.ZIndex=14

    -- Nome
    local nl=Instance.new("TextLabel",card); nl.Name="NL"
    nl.BackgroundTransparency=1; nl.Position=UDim2.new(0,40,0,4)
    nl.Size=UDim2.new(1,-44,0,16); nl.Font=Enum.Font.GothamBlack
    nl.TextSize=12; nl.TextXAlignment=Enum.TextXAlignment.Left
    nl.TextStrokeTransparency=0.1; nl.TextStrokeColor3=Color3.new(0,0,0)
    nl.TextTruncate=Enum.TextTruncate.AtEnd; nl.ZIndex=14

    -- Distância pill
    local dp=Instance.new("Frame",card); dp.Name="DP"
    dp.BorderSizePixel=0; dp.Position=UDim2.new(0,40,0,22)
    dp.Size=UDim2.new(0,80,0,14); dp.ZIndex=13
    Instance.new("UICorner",dp).CornerRadius=UDim.new(0,4)
    local dpad=Instance.new("UIPadding",dp)
    dpad.PaddingLeft=UDim.new(0,5); dpad.PaddingRight=UDim.new(0,5)
    local dl=Instance.new("TextLabel",dp); dl.Name="DL"
    dl.BackgroundTransparency=1; dl.Size=UDim2.new(0,100,1,0)
    dl.Font=Enum.Font.GothamBold
    dl.TextSize=8; dl.ZIndex=14

    -- Seta indicadora (triângulo apontando para o target)
    local arr=Instance.new("TextLabel",f); arr.Name="ARR"
    arr.BackgroundTransparency=1; arr.AnchorPoint=Vector2.new(0.5,0.5)
    arr.Position=UDim2.new(0.5,0,1,8); arr.Size=UDim2.new(0,16,0,16)
    arr.Font=Enum.Font.GothamBlack; arr.Text="▼"; arr.TextSize=8; arr.ZIndex=12

    return f
end

for i=1,PRO_POOL do table.insert(proPool,newProLabel()) end

local function showPro(cor,icon,nome,dist,sx,sy,catKey)
    local f=table.remove(proPool); if not f then return end
    local c=espGetCor(catKey,cor)
    local a=espGetAlpha(0.15)
    f.Position=UDim2.new(0,sx-90,0,sy-22); f.Visible=true

    local card=f:FindFirstChild("CARD")
    if card then
        card.BackgroundTransparency=a
        local cs=card:FindFirstChildOfClass("UIStroke")
        if cs then cs.Color=c; cs.Transparency=math.max(0,a-0.3) end
    end
    local ic=f:FindFirstChild("IC"); if ic then
        ic.BackgroundColor3=c; ic.BackgroundTransparency=espGetAlpha(0.5)
        local ico=ic:FindFirstChild("ICO"); if ico then ico.Text=icon end
    end
    local nl=f:FindFirstChild("NL"); if nl then nl.Text=nome; nl.TextColor3=Color3.fromRGB(245,240,255) end
    local dp=f:FindFirstChild("DP"); if dp then
        dp.BackgroundColor3=c; dp.BackgroundTransparency=espGetAlpha(0.65)
        local dl=dp:FindFirstChild("DL"); if dl then dl.Text=string.format("%.0f m",dist); dl.TextColor3=Color3.new(1,1,1) end
    end
    local arr=f:FindFirstChild("ARR"); if arr then arr.TextColor3=c; arr.TextTransparency=espGetAlpha(0.3) end

    table.insert(proActive,f)
end

local function releaseAllPro()
    for _,f in ipairs(proActive) do f.Visible=false; table.insert(proPool,f) end
    proActive={}
end

-- ══════════════════════════════════════════════════════════════════
-- RENDER: ESTILO "NOTIFICAÇÃO" — Mini card flutuante com ícone
-- ══════════════════════════════════════════════════════════════════
local notifPool={}; local notifActive2={}
local NOTIF_POOL=60

local function newNotifLabel()
    local f=Instance.new("Frame",EspCanvas)
    f.BackgroundTransparency=1; f.BorderSizePixel=0
    f.Size=UDim2.new(0,140,0,28); f.Visible=false; f.ZIndex=12

    local bg=Instance.new("Frame",f); bg.Name="BG"
    bg.BackgroundColor3=Color3.fromRGB(10,6,20); bg.BackgroundTransparency=0.1
    bg.BorderSizePixel=0; bg.Size=UDim2.new(1,0,1,0); bg.ZIndex=12
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,6)
    -- Left accent bar
    local bar=Instance.new("Frame",bg); bar.Name="BAR"
    bar.BorderSizePixel=0; bar.Position=UDim2.new(0,0,0,0)
    bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=13
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    -- Ícone
    local ico=Instance.new("TextLabel",f); ico.Name="ICO"
    ico.BackgroundTransparency=1; ico.Position=UDim2.new(0,5,0,0)
    ico.Size=UDim2.new(0,18,1,0); ico.Font=Enum.Font.GothamBold
    ico.TextSize=13; ico.ZIndex=13
    -- Nome (bold)
    local nl=Instance.new("TextLabel",f); nl.Name="NL"
    nl.BackgroundTransparency=1; nl.Position=UDim2.new(0,24,0,2)
    nl.Size=UDim2.new(1,-52,0,12); nl.Font=Enum.Font.GothamBold
    nl.TextSize=10; nl.TextXAlignment=Enum.TextXAlignment.Left
    nl.TextTruncate=Enum.TextTruncate.AtEnd; nl.ZIndex=13
    -- Distância
    local dl=Instance.new("TextLabel",f); dl.Name="DL"
    dl.BackgroundTransparency=1; dl.Position=UDim2.new(0,24,0,14)
    dl.Size=UDim2.new(1,-52,0,10); dl.Font=Enum.Font.Gotham
    dl.TextSize=8; dl.TextColor3=Color3.fromRGB(180,170,210)
    dl.TextXAlignment=Enum.TextXAlignment.Left; dl.ZIndex=13
    -- Dist badge right
    local badge=Instance.new("Frame",f); badge.Name="BADGE"
    badge.BorderSizePixel=0; badge.AnchorPoint=Vector2.new(1,0.5)
    badge.Position=UDim2.new(1,-3,0.5,0); badge.Size=UDim2.new(0,32,0,16)
    badge.ZIndex=13
    Instance.new("UICorner",badge).CornerRadius=UDim.new(0,4)
    local bpad=Instance.new("UIPadding",badge)
    bpad.PaddingLeft=UDim.new(0,4); bpad.PaddingRight=UDim.new(0,4)
    local bl=Instance.new("TextLabel",badge); bl.Name="BL"
    bl.BackgroundTransparency=1; bl.Size=UDim2.new(0,0,1,0)
    bl.Font=Enum.Font.GothamBold
    bl.TextSize=7; bl.ZIndex=14

    return f
end

for i=1,NOTIF_POOL do table.insert(notifPool,newNotifLabel()) end

local function showNotif(cor,icon,nome,dist,sx,sy,catKey)
    local f=table.remove(notifPool); if not f then return end
    local c=espGetCor(catKey,cor)
    f.Position=UDim2.new(0,sx-70,0,sy-14); f.Visible=true
    local bg=f:FindFirstChild("BG"); if bg then
        bg.BackgroundTransparency=espGetAlpha(0.1)
        local bar=bg:FindFirstChild("BAR"); if bar then bar.BackgroundColor3=c end
    end
    local ico=f:FindFirstChild("ICO"); if ico then ico.Text=icon; ico.TextColor3=c end
    local nl=f:FindFirstChild("NL"); if nl then nl.Text=nome; nl.TextColor3=Color3.new(1,1,1) end
    local dl=f:FindFirstChild("DL"); if dl then dl.Text=string.format("%.0f m",dist) end
    local badge=f:FindFirstChild("BADGE"); if badge then
        badge.BackgroundColor3=c; badge.BackgroundTransparency=espGetAlpha(0.6)
        local bl=badge:FindFirstChild("BL"); if bl then bl.Text=string.format("%.0fm",dist); bl.TextColor3=Color3.new(1,1,1) end
    end
    table.insert(notifActive2,f)
end

local function releaseAllNotif()
    for _,f in ipairs(notifActive2) do f.Visible=false; table.insert(notifPool,f) end
    notifActive2={}
end

-- ══════════════════════════════════════════════════════════════════
-- HEARTBEAT — renderiza conforme estilo selecionado
-- ══════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    dtAcc = dtAcc + dt; if dtAcc < RENDER_I then return end; dtAcc = 0

    releaseAllSimple(); releaseAllPro(); releaseAllNotif()

    local qualquer = false
    for _,c in ipairs(ESP_CATS) do if espAtivo[c.key] then qualquer=true; break end end
    if not qualquer then return end

    pcall(buildCache)

    local charPos = Vector3.new(0,0,0)
    pcall(function()
        local ch=Player.Character
        if ch and ch:FindFirstChild("HumanoidRootPart") then charPos=ch.HumanoidRootPart.Position end
    end)

    local vp   = Cam.ViewportSize
    local seen = {}

    local function dispatch(cor,icon,nome,dist,sx,sy,catKey)
        if espStyle=="simples" then
            showSimple(cor,icon,nome,dist,sx,sy)
        elseif espStyle=="notificacao" then
            showNotif(cor,icon,nome,dist,sx,sy,catKey)
        else
            showPro(cor,icon,nome,dist,sx,sy,catKey)
        end
    end

    -- Players
    if espAtivo["Players"] then
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl ~= Player and pl.Character then
                pcall(function()
                    local hrp=pl.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                    local hum=pl.Character:FindFirstChildWhichIsA("Humanoid"); if not hum or hum.Health<=0 then return end
                    local dist=(hrp.Position-charPos).Magnitude
                    local sp=Cam:WorldToViewportPoint(hrp.Position+Vector3.new(0,3,0))
                    if sp.Z<=0 or sp.X<-80 or sp.X>vp.X+80 or sp.Y<-50 or sp.Y>vp.Y+50 then return end
                    local cell=math.floor(sp.X/16)..","..math.floor(sp.Y/16)
                    if seen[cell] then return end; seen[cell]=true
                    local c=espGetCor("Players",Color3.fromRGB(255,80,80))
                    dispatch(c,"👤",pl.DisplayName,dist,sp.X,sp.Y,"Players")
                end)
            end
        end
    end

    -- Entities
    for _,e in ipairs(entityCache) do
        pcall(function()
            if not espAtivo[e.key] or not e.obj or not e.obj.Parent then return end
            if not e.hrp or not e.hrp.Parent then return end
            local hum=e.obj:FindFirstChildWhichIsA("Humanoid"); if not hum or hum.Health<=0 then return end
            local pos=e.hrp.Position; local dist=(pos-charPos).Magnitude; if dist>e.alcance then return end
            local sp=Cam:WorldToViewportPoint(pos+Vector3.new(0,2.5,0))
            if sp.Z<=0 or sp.X<-80 or sp.X>vp.X+80 or sp.Y<-50 or sp.Y>vp.Y+50 then return end
            local cell=math.floor(sp.X/6)..","..math.floor(sp.Y/6)
            if seen[cell] then return end; seen[cell]=true
            local c=espGetCor(e.key,e.cor)
            dispatch(c,e.icon or "👾",e.nome,dist,sp.X,sp.Y,e.key)
        end)
    end

    -- Items
    for _,e in ipairs(itemCache) do
        pcall(function()
            if not espAtivo[e.key] or not e.obj or not e.obj.Parent then return end
            local pos=e.obj.Position; local dist=(pos-charPos).Magnitude; if dist>e.alcance then return end
            local sp=Cam:WorldToViewportPoint(pos+Vector3.new(0,0.8,0))
            if sp.Z<=0 or sp.X<-80 or sp.X>vp.X+80 or sp.Y<-50 or sp.Y>vp.Y+50 then return end
            local cell=math.floor(sp.X/12)..","..math.floor(sp.Y/12)
            if seen[cell] then return end; seen[cell]=true
            local c=espGetCor(e.key,e.cor)
            dispatch(c,e.icon or "📦",e.nome,dist,sp.X,sp.Y,e.key)
        end)
    end
end)

-- ══════════════════════════════════════════════════════════════════
-- UI ESP — Painel de controle no topo da aba
-- ══════════════════════════════════════════════════════════════════
local espTabLO=0
local function espLO() espTabLO=espTabLO+1; return espTabLO end
local function updateEspCount() end  -- stub (badge removido com painel antigo)

-- ══════════════════════════════════════════════════════════════════
-- ESP TOPO — Apenas dropdown de Estilo
-- ══════════════════════════════════════════════════════════════════

-- ── Card topo com dropdown de Estilo ──────────────────────────────
local espStyleCard = Instance.new("Frame", Pages["Esp"])
espStyleCard.BackgroundColor3 = Color3.fromRGB(16,9,32)
espStyleCard.BackgroundTransparency = 0; espStyleCard.BorderSizePixel = 0
espStyleCard.Size = UDim2.new(1,0,0,46); espStyleCard.LayoutOrder = espLO(); espStyleCard.ZIndex = 5
Instance.new("UICorner",espStyleCard).CornerRadius = UDim.new(0,14)
local escG = Instance.new("UIGradient",espStyleCard)
escG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(24,13,50)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(10,5,22)),
}); escG.Rotation = 135
local escS = Instance.new("UIStroke",espStyleCard)
escS.Color = ESP_ACCENT; escS.Thickness = 1.5; escS.Transparency = 0.55
escS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
-- Shine
local escShine = Instance.new("Frame",espStyleCard)
escShine.BackgroundColor3 = Color3.fromRGB(255,255,255); escShine.BackgroundTransparency = 0.82
escShine.BorderSizePixel = 0; escShine.Position = UDim2.new(0,8,0,2)
escShine.Size = UDim2.new(0.45,0,0,1); escShine.ZIndex = 6
Instance.new("UICorner",escShine).CornerRadius = UDim.new(1,0)

-- Label "Estilo de ESP"
local escLbl = Instance.new("TextLabel",espStyleCard); escLbl.BackgroundTransparency = 1
escLbl.Position = UDim2.new(0,12,0,0); escLbl.Size = UDim2.new(0.42,0,1,0)
escLbl.Font = Enum.Font.GothamBlack; escLbl.Text = "⚡  Estilo de ESP"
escLbl.TextColor3 = Color3.fromRGB(200,185,255); escLbl.TextSize = 11
escLbl.TextXAlignment = Enum.TextXAlignment.Left; escLbl.ZIndex = 6

-- Botão dropdown glassmorphism
local escBtn = Instance.new("TextButton",espStyleCard)
escBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
escBtn.BackgroundTransparency = 0.88; escBtn.BorderSizePixel = 0
escBtn.AnchorPoint = Vector2.new(1,0.5); escBtn.Position = UDim2.new(1,-10,0.5,0)
escBtn.Size = UDim2.new(0,145,0,30); escBtn.Font = Enum.Font.GothamBold
escBtn.TextSize = 10; escBtn.ZIndex = 7; escBtn.AutoButtonColor = false
escBtn.TextTruncate = Enum.TextTruncate.AtEnd
Instance.new("UICorner",escBtn).CornerRadius = UDim.new(0,9)
local escBtnS = Instance.new("UIStroke",escBtn)
escBtnS.Thickness = 1.3; escBtnS.Transparency = 0.25; escBtnS.Color = ESP_ACCENT
escBtnS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local escTint = Instance.new("Frame",escBtn)
escTint.BackgroundColor3 = ESP_ACCENT; escTint.BackgroundTransparency = 0.82
escTint.BorderSizePixel = 0; escTint.Size = UDim2.new(1,0,1,0); escTint.ZIndex = 6
Instance.new("UICorner",escTint).CornerRadius = UDim.new(0,9)
local escGlass = Instance.new("Frame",escBtn)
escGlass.BackgroundColor3 = Color3.fromRGB(255,255,255); escGlass.BackgroundTransparency = 0.72
escGlass.BorderSizePixel = 0; escGlass.Position = UDim2.new(0,6,0,2)
escGlass.Size = UDim2.new(0.5,0,0,1); escGlass.ZIndex = 8
Instance.new("UICorner",escGlass).CornerRadius = UDim.new(1,0)
local escArr = Instance.new("TextLabel",escBtn); escArr.BackgroundTransparency = 1
escArr.AnchorPoint = Vector2.new(1,0.5); escArr.Position = UDim2.new(1,-6,0.5,0)
escArr.Size = UDim2.new(0,12,0,14); escArr.Font = Enum.Font.GothamBlack
escArr.Text = "▾"; escArr.TextSize = 9; escArr.ZIndex = 8

-- Dados dos estilos
local STYLE_OPTS = {
    {key="profissional", label="Profissional", icon="✨", cor=Color3.fromRGB(180,120,255)},
    {key="simples",      label="Simples",      icon="📦", cor=Color3.fromRGB(100,200,255)},
    {key="notificacao",  label="Notificação",  icon="🔔", cor=Color3.fromRGB(255,180,60)},
}

local function updateEscBtn()
    for _,s in ipairs(STYLE_OPTS) do
        if s.key==espStyle then
            escBtn.Text = s.icon.."  "..s.label
            escBtn.TextColor3 = s.cor; escBtnS.Color = s.cor
            escTint.BackgroundColor3 = s.cor; escArr.TextColor3 = s.cor
            return
        end
    end
    escBtn.Text = "✨  Profissional"
    escBtn.TextColor3 = Color3.fromRGB(180,120,255)
end
updateEscBtn()

-- Popup do estilo
local escPop = Instance.new("Frame",ScreenGui)
escPop.BackgroundColor3 = Color3.fromRGB(14,8,28); escPop.BackgroundTransparency = 0
escPop.BorderSizePixel = 0; escPop.ZIndex = 450; escPop.Visible = false
escPop.Size = UDim2.new(0,0,0,0); escPop.ClipsDescendants = true
Instance.new("UICorner",escPop).CornerRadius = UDim.new(0,12)
local escPopS = Instance.new("UIStroke",escPop)
escPopS.Color = ESP_ACCENT; escPopS.Thickness = 1.5; escPopS.Transparency = 0.25
escPopS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local escPopLayout = Instance.new("UIListLayout",escPop)
escPopLayout.SortOrder = Enum.SortOrder.LayoutOrder; escPopLayout.Padding = UDim.new(0,4)
local escPopPad = Instance.new("UIPadding",escPop)
escPopPad.PaddingTop = UDim.new(0,6); escPopPad.PaddingBottom = UDim.new(0,6)
escPopPad.PaddingLeft = UDim.new(0,6); escPopPad.PaddingRight = UDim.new(0,6)

local ESC_POP_H = #STYLE_OPTS * 46 + 16
for idx,opt in ipairs(STYLE_OPTS) do
    local item = Instance.new("Frame",escPop)
    item.BackgroundColor3 = espStyle==opt.key and Color3.fromRGB(34,20,60) or Color3.fromRGB(20,11,40)
    item.BackgroundTransparency = espStyle==opt.key and 0.1 or 0.5
    item.BorderSizePixel = 0; item.Size = UDim2.new(1,0,0,38)
    item.LayoutOrder = idx; item.ZIndex = 451; item.ClipsDescendants = false
    Instance.new("UICorner",item).CornerRadius = UDim.new(0,8)
    local iS = Instance.new("UIStroke",item); iS.Color = opt.cor
    iS.Thickness = 1; iS.Transparency = espStyle==opt.key and 0.2 or 0.85
    iS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local iIco = Instance.new("TextLabel",item); iIco.BackgroundTransparency = 1
    iIco.Position = UDim2.new(0,8,0,0); iIco.Size = UDim2.new(0,20,1,0)
    iIco.Text = opt.icon; iIco.TextSize = 14; iIco.ZIndex = 452
    local iLbl = Instance.new("TextLabel",item); iLbl.BackgroundTransparency = 1
    iLbl.Position = UDim2.new(0,30,0,0); iLbl.Size = UDim2.new(1,-50,1,0)
    iLbl.Font = Enum.Font.GothamBold; iLbl.Text = opt.label
    iLbl.TextColor3 = espStyle==opt.key and Color3.new(1,1,1) or Color3.fromRGB(190,175,225)
    iLbl.TextSize = 12; iLbl.TextXAlignment = Enum.TextXAlignment.Left; iLbl.ZIndex = 452
    local iChk = Instance.new("TextLabel",item); iChk.BackgroundTransparency = 1
    iChk.AnchorPoint = Vector2.new(1,0.5); iChk.Position = UDim2.new(1,-8,0.5,0)
    iChk.Size = UDim2.new(0,14,0,14); iChk.Font = Enum.Font.GothamBlack
    iChk.Text = espStyle==opt.key and "✓" or ""; iChk.TextColor3 = opt.cor; iChk.TextSize = 11; iChk.ZIndex = 452

    local ib = Instance.new("TextButton",item); ib.BackgroundTransparency = 1
    ib.Size = UDim2.new(1,0,1,0); ib.Text = ""; ib.ZIndex = 453
    ib.MouseButton1Click:Connect(function()
        espStyle = opt.key; lastCache = 0; updateEscBtn()
        -- Fecha popup
        TweenService:Create(escPop,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Size=UDim2.new(0,escPop.AbsoluteSize.X,0,0),BackgroundTransparency=0.4}):Play()
        task.delay(0.16,function() escPop.Visible=false; escPop.BackgroundTransparency=0 end)
        TweenService:Create(escArr,TweenInfo.new(0.18),{Rotation=0}):Play()
        TweenService:Create(escBtnS,TweenInfo.new(0.1),{Transparency=0.25}):Play()
        _vdOpen = nil
        Notify.send({type="info",icon=opt.icon,accent=opt.cor,title="Estilo ESP",msg=opt.label,duration=2})
    end)
end

local escOpen = false
local function openEscPop()
    if _vdOpen and _vdOpen~=escPop then
        TweenService:Create(_vdOpen,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Size=UDim2.new(0,_vdOpen.AbsoluteSize.X,0,0)}):Play()
        task.delay(0.13,function() _vdOpen.Visible=false end)
    end
    local ap=escBtn.AbsolutePosition; local as=escBtn.AbsoluteSize
    local vp=workspace.CurrentCamera.ViewportSize
    local px=math.clamp(ap.X,8,vp.X-155); local py=ap.Y+as.Y+6
    escPop.Position = UDim2.new(0,px,0,py)
    escPop.Size = UDim2.new(0,145,0,0)
    escPop.BackgroundTransparency = 0.4; escPop.Visible = true
    TweenService:Create(escPop,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,145,0,ESC_POP_H),BackgroundTransparency=0}):Play()
    escOpen = true; _vdOpen = escPop
    TweenService:Create(escArr,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=180}):Play()
end
local function closeEscPop()
    escOpen = false
    TweenService:Create(escPop,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,145,0,0),BackgroundTransparency=0.4}):Play()
    task.delay(0.16,function() escPop.Visible=false; escPop.BackgroundTransparency=0 end)
    _vdOpen = nil
    TweenService:Create(escArr,TweenInfo.new(0.18),{Rotation=0}):Play()
end
escBtn.MouseButton1Click:Connect(function()
    if escOpen then closeEscPop() else openEscPop() end
end)
UserInputService.InputBegan:Connect(function(inp)
    if not escOpen then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    local mp=UserInputService:GetMouseLocation()
    local function inside(f) local a,sz=f.AbsolutePosition,f.AbsoluteSize
        return mp.X>=a.X and mp.X<=a.X+sz.X and mp.Y>=a.Y and mp.Y<=a.Y+sz.Y end
    if not inside(escPop) and not inside(escBtn) then closeEscPop() end
end)


-- ══════════════════════════════════════════════════════════════════
-- COLOR PICKER RAYFIELD — shared, um por vez
-- Estrutura: Hue bar + SV square + Preview + HEX input
-- ══════════════════════════════════════════════════════════════════
local CP_W, CP_H = 240, 280
local cpPop = Instance.new("Frame", ScreenGui)
cpPop.BackgroundColor3 = Color3.fromRGB(12,7,24)
cpPop.BackgroundTransparency = 0; cpPop.BorderSizePixel = 0
cpPop.ZIndex = 500; cpPop.Visible = false
cpPop.Size = UDim2.new(0,CP_W,0,CP_H)
cpPop.ClipsDescendants = false
Instance.new("UICorner",cpPop).CornerRadius = UDim.new(0,14)
local cpS = Instance.new("UIStroke",cpPop)
cpS.Color = ESP_ACCENT; cpS.Thickness = 1.5; cpS.Transparency = 0.2
cpS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
-- Header
local cpHdr = Instance.new("Frame",cpPop)
cpHdr.BackgroundColor3 = Color3.fromRGB(20,10,40); cpHdr.BackgroundTransparency = 0
cpHdr.BorderSizePixel = 0; cpHdr.Size = UDim2.new(1,0,0,34); cpHdr.ZIndex = 501
Instance.new("UICorner",cpHdr).CornerRadius = UDim.new(0,14)
local cpHdrFix = Instance.new("Frame",cpHdr); cpHdrFix.BackgroundColor3 = Color3.fromRGB(20,10,40)
cpHdrFix.BorderSizePixel = 0; cpHdrFix.Position = UDim2.new(0,0,0.5,0)
cpHdrFix.Size = UDim2.new(1,0,0.5,0); cpHdrFix.ZIndex = 501
local cpTitle = Instance.new("TextLabel",cpHdr); cpTitle.BackgroundTransparency = 1
cpTitle.Position = UDim2.new(0,12,0,0); cpTitle.Size = UDim2.new(0.7,0,1,0)
cpTitle.Font = Enum.Font.GothamBlack; cpTitle.Text = "🎨  Cor do ESP"
cpTitle.TextColor3 = ESP_ACCENT; cpTitle.TextSize = 11
cpTitle.TextXAlignment = Enum.TextXAlignment.Left; cpTitle.ZIndex = 502
local cpClose = Instance.new("TextButton",cpHdr); cpClose.BackgroundTransparency = 1
cpClose.AnchorPoint = Vector2.new(1,0.5); cpClose.Position = UDim2.new(1,-8,0.5,0)
cpClose.Size = UDim2.new(0,20,0,20); cpClose.Font = Enum.Font.GothamBlack
cpClose.Text = "✕"; cpClose.TextColor3 = Color3.fromRGB(180,160,220); cpClose.TextSize = 12; cpClose.ZIndex = 502
cpClose.MouseButton1Click:Connect(function() cpPop.Visible = false end)

-- SV Square (Saturation-Value)
local SV_W, SV_H = 200, 130
local svFrame = Instance.new("Frame",cpPop)
svFrame.BackgroundColor3 = Color3.fromHSV(0,1,1)
svFrame.BorderSizePixel = 0; svFrame.ZIndex = 501
svFrame.Position = UDim2.new(0.5,-SV_W/2,0,42); svFrame.Size = UDim2.new(0,SV_W,0,SV_H)
Instance.new("UICorner",svFrame).CornerRadius = UDim.new(0,8)
-- White gradient (left→right: white→transparent)
local svWhite = Instance.new("Frame",svFrame)
svWhite.BackgroundColor3 = Color3.fromRGB(255,255,255); svWhite.BackgroundTransparency = 0
svWhite.BorderSizePixel = 0; svWhite.Size = UDim2.new(1,0,1,0); svWhite.ZIndex = 502
Instance.new("UICorner",svWhite).CornerRadius = UDim.new(0,8)
local svWG = Instance.new("UIGradient",svWhite)
svWG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255)),
}); svWG.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,0),
    NumberSequenceKeypoint.new(1,1),
})
-- Black gradient (top→bottom: transparent→black)
local svBlack = Instance.new("Frame",svFrame)
svBlack.BackgroundColor3 = Color3.fromRGB(0,0,0); svBlack.BackgroundTransparency = 0
svBlack.BorderSizePixel = 0; svBlack.Size = UDim2.new(1,0,1,0); svBlack.ZIndex = 503
Instance.new("UICorner",svBlack).CornerRadius = UDim.new(0,8)
local svBG = Instance.new("UIGradient",svBlack)
svBG.Color = ColorSequence.new(Color3.fromRGB(0,0,0))
svBG.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0,1),
    NumberSequenceKeypoint.new(1,0),
}); svBG.Rotation = 90
-- Cursor SV
local svCursor = Instance.new("Frame",svFrame)
svCursor.BackgroundColor3 = Color3.fromRGB(255,255,255); svCursor.BackgroundTransparency = 0
svCursor.BorderSizePixel = 0; svCursor.AnchorPoint = Vector2.new(0.5,0.5)
svCursor.Position = UDim2.new(1,0,0,0); svCursor.Size = UDim2.new(0,12,0,12); svCursor.ZIndex = 505
Instance.new("UICorner",svCursor).CornerRadius = UDim.new(1,0)
local svCursorS = Instance.new("UIStroke",svCursor)
svCursorS.Color = Color3.fromRGB(255,255,255); svCursorS.Thickness = 2; svCursorS.Transparency = 0
svCursorS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
-- HIT button para arrastar no SV
local svHit = Instance.new("TextButton",svFrame)
svHit.BackgroundTransparency = 1; svHit.BorderSizePixel = 0
svHit.Size = UDim2.new(1,0,1,0); svHit.Text = ""; svHit.ZIndex = 506

-- Hue bar
local HUE_W, HUE_H = 200, 14
local hueBar = Instance.new("Frame",cpPop)
hueBar.BackgroundColor3 = Color3.fromRGB(255,0,0); hueBar.BackgroundTransparency = 0
hueBar.BorderSizePixel = 0; hueBar.ZIndex = 501
hueBar.Position = UDim2.new(0.5,-HUE_W/2,0,182); hueBar.Size = UDim2.new(0,HUE_W,0,HUE_H)
Instance.new("UICorner",hueBar).CornerRadius = UDim.new(1,0)
local hueG = Instance.new("UIGradient",hueBar)
hueG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,    Color3.fromHSV(0,1,1)),
    ColorSequenceKeypoint.new(0.167,Color3.fromHSV(0.167,1,1)),
    ColorSequenceKeypoint.new(0.333,Color3.fromHSV(0.333,1,1)),
    ColorSequenceKeypoint.new(0.5,  Color3.fromHSV(0.5,1,1)),
    ColorSequenceKeypoint.new(0.667,Color3.fromHSV(0.667,1,1)),
    ColorSequenceKeypoint.new(0.833,Color3.fromHSV(0.833,1,1)),
    ColorSequenceKeypoint.new(1,    Color3.fromHSV(1,1,1)),
})
-- Cursor hue
local hueCursor = Instance.new("Frame",cpPop)
hueCursor.BackgroundColor3 = Color3.fromRGB(255,255,255); hueCursor.BackgroundTransparency = 0
hueCursor.BorderSizePixel = 0; hueCursor.AnchorPoint = Vector2.new(0.5,0.5)
hueCursor.ZIndex = 502; hueCursor.Size = UDim2.new(0,8,0,20)
Instance.new("UICorner",hueCursor).CornerRadius = UDim.new(0,4)
local hueCursorS = Instance.new("UIStroke",hueCursor)
hueCursorS.Color = Color3.fromRGB(255,255,255); hueCursorS.Thickness = 1.5; hueCursorS.Transparency = 0.2
hueCursorS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local hueHit = Instance.new("TextButton",hueBar)
hueHit.BackgroundTransparency = 1; hueHit.BorderSizePixel = 0
hueHit.Size = UDim2.new(1,0,1,0); hueHit.Text = ""; hueHit.ZIndex = 503

-- Preview + HEX
local cpPreview = Instance.new("Frame",cpPop)
cpPreview.BackgroundColor3 = Color3.fromRGB(148,112,220); cpPreview.BackgroundTransparency = 0
cpPreview.BorderSizePixel = 0; cpPreview.ZIndex = 501
cpPreview.Position = UDim2.new(0.5,-HUE_W/2,0,205); cpPreview.Size = UDim2.new(0,32,0,32)
Instance.new("UICorner",cpPreview).CornerRadius = UDim.new(0,8)
local cpPrevS = Instance.new("UIStroke",cpPreview)
cpPrevS.Color = Color3.fromRGB(255,255,255); cpPrevS.Thickness = 1.5; cpPrevS.Transparency = 0.3
cpPrevS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local cpHexBg = Instance.new("Frame",cpPop)
cpHexBg.BackgroundColor3 = Color3.fromRGB(20,10,40); cpHexBg.BackgroundTransparency = 0.2
cpHexBg.BorderSizePixel = 0; cpHexBg.ZIndex = 501
cpHexBg.Position = UDim2.new(0.5,-HUE_W/2+40,0,209); cpHexBg.Size = UDim2.new(0,156,0,24)
Instance.new("UICorner",cpHexBg).CornerRadius = UDim.new(0,7)
local cpHexS = Instance.new("UIStroke",cpHexBg)
cpHexS.Color = ESP_ACCENT; cpHexS.Thickness = 1; cpHexS.Transparency = 0.6
cpHexS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local cpHexLabel = Instance.new("TextLabel",cpHexBg); cpHexLabel.BackgroundTransparency = 1
cpHexLabel.Position = UDim2.new(0,8,0,0); cpHexLabel.Size = UDim2.new(0,16,1,0)
cpHexLabel.Font = Enum.Font.GothamBold; cpHexLabel.Text = "#"
cpHexLabel.TextColor3 = Color3.fromRGB(140,120,180); cpHexLabel.TextSize = 10; cpHexLabel.ZIndex = 502
local cpHexBox = Instance.new("TextBox",cpHexBg); cpHexBox.BackgroundTransparency = 1
cpHexBox.Position = UDim2.new(0,22,0,0); cpHexBox.Size = UDim2.new(1,-30,1,0)
cpHexBox.Font = Enum.Font.GothamBold; cpHexBox.Text = "9470DC"
cpHexBox.TextColor3 = Color3.fromRGB(210,195,250); cpHexBox.TextSize = 10
cpHexBox.ClearTextOnFocus = false; cpHexBox.ZIndex = 502

-- Botão Aplicar
local cpApplyBtn = Instance.new("TextButton",cpPop)
cpApplyBtn.BackgroundColor3 = ESP_ACCENT; cpApplyBtn.BackgroundTransparency = 0.3
cpApplyBtn.BorderSizePixel = 0; cpApplyBtn.ZIndex = 501
cpApplyBtn.AnchorPoint = Vector2.new(0.5,0); cpApplyBtn.Position = UDim2.new(0.5,0,0,245)
cpApplyBtn.Size = UDim2.new(0,HUE_W,0,26); cpApplyBtn.Font = Enum.Font.GothamBlack
cpApplyBtn.Text = "✓  Aplicar Cor"; cpApplyBtn.TextColor3 = Color3.fromRGB(255,255,255); cpApplyBtn.TextSize = 11; cpApplyBtn.ZIndex = 502
Instance.new("UICorner",cpApplyBtn).CornerRadius = UDim.new(0,9)
local cpApplyS = Instance.new("UIStroke",cpApplyBtn); cpApplyS.Color = Color3.fromRGB(190,160,255)
cpApplyS.Thickness = 1; cpApplyS.Transparency = 0.4; cpApplyS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Estado interno do color picker
local cpHue = 0.667  -- roxo inicial (ESP default)
local cpSat = 0.5
local cpVal = 0.8
local cpCurrentCallback = nil  -- função chamada ao aplicar
local cpDragSV = false
local cpDragHue = false

local function cpColor() return Color3.fromHSV(cpHue,cpSat,cpVal) end

local function cpHexStr(c)
    return string.format("%02X%02X%02X",
        math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
end

local function refreshCP()
    local c = cpColor()
    svFrame.BackgroundColor3 = Color3.fromHSV(cpHue,1,1)
    cpPreview.BackgroundColor3 = c
    cpHexBox.Text = cpHexStr(c)
    cpS.Color = c
    -- Cursor SV
    svCursor.Position = UDim2.new(cpSat,0,1-cpVal,0)
    -- Cursor hue
    local _hbPos = hueBar.AbsolutePosition; local _hbSz = hueBar.AbsoluteSize
    local _huePx = _hbPos.X + cpHue * _hbSz.X
    local _huePy = _hbPos.Y + _hbSz.Y/2
    hueCursor.Position = UDim2.new(0, _huePx, 0, _huePy)
end

-- SV dragging
local function updateSV(mouseX, mouseY)
    local ab = svFrame.AbsolutePosition; local as2 = svFrame.AbsoluteSize
    cpSat = math.clamp((mouseX - ab.X)/as2.X, 0, 1)
    cpVal = 1 - math.clamp((mouseY - ab.Y)/as2.Y, 0, 1)
    refreshCP()
end

-- Hue dragging
local function updateHue(mouseX)
    local ab = hueBar.AbsolutePosition; local as2 = hueBar.AbsoluteSize
    cpHue = math.clamp((mouseX - ab.X)/as2.X, 0, 1)
    refreshCP()
end

svHit.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        cpDragSV = true; updateSV(i.Position.X, i.Position.Y)
    end
end)
hueHit.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        cpDragHue = true; updateHue(i.Position.X)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        cpDragSV = false; cpDragHue = false
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not cpPop.Visible then return end
    if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
    if cpDragSV  then updateSV(i.Position.X,i.Position.Y) end
    if cpDragHue then updateHue(i.Position.X) end
end)

cpHexBox.FocusLost:Connect(function()
    local hex = cpHexBox.Text:gsub("[^%x]","")
    hex = hex:upper():sub(1,6)
    if #hex==6 then
        local r=tonumber(hex:sub(1,2),16)/255
        local g=tonumber(hex:sub(3,4),16)/255
        local b=tonumber(hex:sub(5,6),16)/255
        local _tmpC = Color3.fromRGB(r*255,g*255,b*255)
        local h,s,v = _tmpC:ToHSV()
        cpHue=h; cpSat=s; cpVal=v; refreshCP()
    else
        cpHexBox.Text = cpHexStr(cpColor())
    end
end)

cpApplyBtn.MouseButton1Click:Connect(function()
    if cpCurrentCallback then pcall(cpCurrentCallback, cpColor()) end
    cpPop.Visible = false
    Notify.success("Cor do ESP", "✓ Cor aplicada!")
end)

-- Fecha ao clicar fora
UserInputService.InputBegan:Connect(function(inp)
    if not cpPop.Visible then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    local mp = UserInputService:GetMouseLocation()
    local ab = cpPop.AbsolutePosition; local as2 = cpPop.AbsoluteSize
    if mp.X<ab.X or mp.X>ab.X+as2.X or mp.Y<ab.Y or mp.Y>ab.Y+as2.Y then
        cpPop.Visible = false
    end
end)

-- Função para abrir o color picker para um ESP específico
local function openColorPicker(catKey, currentCor, onApply)
    -- Seta cor inicial
    if currentCor then
        local h,s,v = currentCor:ToHSV()
        cpHue=h; cpSat=s; cpVal=v
    end
    cpCurrentCallback = function(newCor)
        espCatColors[catKey] = newCor
        lastCache = 0
        if onApply then onApply(newCor) end
    end
    cpTitle.Text = "🎨  Cor: "
    refreshCP()
    -- Posiciona no centro da tela
    local vp = workspace.CurrentCamera.ViewportSize
    cpPop.Position = UDim2.new(0,math.floor(vp.X/2-CP_W/2),0,math.floor(vp.Y/2-CP_H/2))
    cpPop.Size = UDim2.new(0,CP_W,0,CP_H)
    cpPop.Visible = true
    -- Garante que está na frente de tudo
    cpPop.ZIndex = 500
end

-- Posição inicial do hueCursor (calculada depois do layout)
task.spawn(function() task.wait() refreshCP() end)

-- Função para criar bolinha de cor num row do ESP
local function addColorDot(row, catKey, catCor)
    local dot = Instance.new("TextButton",row)
    dot.BackgroundColor3 = espCatColors[catKey] or catCor or Color3.fromRGB(255,255,255)
    dot.BackgroundTransparency = 0; dot.BorderSizePixel = 0
    dot.AnchorPoint = Vector2.new(1,0.5); dot.Position = UDim2.new(1,-58,0.5,0)
    dot.Size = UDim2.new(0,14,0,14); dot.Text = ""; dot.ZIndex = 13; dot.AutoButtonColor = false
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)
    local dotS = Instance.new("UIStroke",dot)
    dotS.Color = Color3.fromRGB(255,255,255); dotS.Thickness = 1.5; dotS.Transparency = 0.3
    dotS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    dot.MouseButton1Click:Connect(function()
        local currentCor = espCatColors[catKey] or catCor or Color3.fromRGB(148,112,220)
        openColorPicker(catKey, currentCor, function(newCor)
            dot.BackgroundColor3 = newCor
            dotS.Color = newCor
        end)
    end)
    return dot
end
-- ── ACCORDION CARDS POR GRUPO (mantido igual) ─────────────────────
local ESP_GROUPS = {
    {key="espGroupEntities",  cor=Color3.fromRGB(120,86,188), icon="👥", title="Entidades",   keys={"Players","Kids","Animais","Monstros","Cultistas","Aliens"}},
    {key="espGroupResources", cor=Color3.fromRGB(255,130,40), icon="📦", title="Recursos",    keys={"EspLog","EspCombustivel","EspCarcacas","EspSucata","EspMateriais"}},
    {key="espGroupFood",      cor=Color3.fromRGB(255,120,170),icon="🍖", title="Comida",      keys={"EspComidas","EspPeixes","EspSementes","EspPocoes"}},
    {key="espGroupEquipment", cor=Color3.fromRGB(255,200,55), icon="⚔️", title="Equipamentos",keys={"EspFerr","EspArmas","EspAmmo","EspCura","EspChaves","EspBigorna","EspBlueprint","EspPelts"}},
}

local espCatMap={}; for _,c in ipairs(ESP_CATS) do espCatMap[c.key]=c end

for _,grp in ipairs(ESP_GROUPS) do
    local validCats={}
    for _,k in ipairs(grp.keys) do if espCatMap[k] then table.insert(validCats,espCatMap[k]) end end
    if #validCats>0 then
        local itemH=40; local cH=36+9+#validCats*itemH+8
        local _egCard,_egCF=makeAccordionCard(Pages["Esp"],espLO,{
            icon=grp.icon, title=T(grp.key), summary=nil, color=grp.cor, contentH=cH,
        })
        local _ey=36+8
        local _ed=Instance.new("Frame",_egCF); _ed.BackgroundColor3=grp.cor
        _ed.BackgroundTransparency=0.78; _ed.BorderSizePixel=0
        _ed.Position=UDim2.new(0,10,0,_ey); _ed.Size=UDim2.new(1,-20,0,1); _ed.ZIndex=7
        _ey=_ey+9
        for i,cat in ipairs(validCats) do
            local row=Instance.new("Frame",_egCF); row.BackgroundTransparency=1; row.BorderSizePixel=0
            row.Position=UDim2.new(0,0,0,_ey); row.Size=UDim2.new(1,0,0,itemH-2); row.ZIndex=7
            local icoBox=Instance.new("Frame",row); icoBox.BackgroundColor3=cat.cor
            icoBox.BackgroundTransparency=0.75; icoBox.BorderSizePixel=0
            icoBox.Position=UDim2.new(0,10,0.5,-12); icoBox.Size=UDim2.new(0,24,0,24); icoBox.ZIndex=8
            Instance.new("UICorner",icoBox).CornerRadius=UDim.new(0,6)
            local miniIcon=criarIconeEsp(icoBox,cat.key,cat.cor)
            miniIcon.Position=UDim2.new(0,5,0,5); miniIcon.Size=UDim2.new(0,14,0,14)
            local lbl=Instance.new("TextLabel",row); lbl.BackgroundTransparency=1
            lbl.Position=UDim2.new(0,42,0,0); lbl.Size=UDim2.new(1,-100,1,0)
            lbl.Font=Enum.Font.GothamBold; lbl.Text=cat.label
            lbl.TextColor3=Color3.fromRGB(210,195,240); lbl.TextSize=10
            lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextYAlignment=Enum.TextYAlignment.Center; lbl.ZIndex=8
            if cat.trLabel then TL(lbl,cat.trLabel) end
            local pill=Instance.new("Frame",row); pill.BorderSizePixel=0
            pill.AnchorPoint=Vector2.new(1,0.5); pill.Position=UDim2.new(1,-10,0.5,0)
            pill.Size=UDim2.new(0,44,0,22); pill.ZIndex=9
            Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
            pill.BackgroundColor3=Color3.fromRGB(100,80,120)
            local knob=Instance.new("Frame",pill); knob.BorderSizePixel=0
            knob.BackgroundColor3=Color3.fromRGB(255,255,255)
            knob.AnchorPoint=Vector2.new(0.5,0.5); knob.ZIndex=10
            knob.Size=UDim2.new(0,16,0,16); knob.Position=UDim2.new(0,13,0.5,0)
            Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
            local knobS2=Instance.new("UIStroke",knob); knobS2.Color=Color3.fromRGB(0,0,0)
            knobS2.Thickness=0.8; knobS2.Transparency=0.7; knobS2.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            -- Bolinha de cor (Color Picker Rayfield)
            addColorDot(row, cat.key, cat.cor)

            local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1
            btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=12
            local state=false
            btn.MouseButton1Click:Connect(function()
                state=not state; espAtivo[cat.key]=state; lastCache=0
                local displayCor=espGetCor(cat.key,cat.cor)
                TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=state and displayCor or Color3.fromRGB(100,80,120)}):Play()
                TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
                    Position=state and UDim2.new(1,-13,0.5,0) or UDim2.new(0,13,0.5,0)
                }):Play()
                TweenService:Create(_egCard:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{Transparency=state and 0.35 or 0.72}):Play()
                if state then Notify.success(T("espOn"),cat.label) else Notify.error(T("espOff"),cat.label) end
                updateEspCount()
            end)
            _ey=_ey+itemH
        end
    end -- validCats>0
end

end); if not _dbgOk_5249 then warn('[PudimHub DEBUG] Erro na secao ESP: '..tostring(_dbgErr_5249)) end
local _dbgOk_6571, _dbgErr_6571 = pcall(function() -- [[ BRING ]]

-- ════════════════════════════════════════════════════════
-- BRING SYSTEM v4 — Remote legítimo (abordagem GG.lua)
-- Usa RequestStartDraggingItem / StopDraggingItem do jogo.
-- O servidor aplica física real → itens ficam soltos naturalmente.
-- ════════════════════════════════════════════════════════

local _bringItemsFolder  = nil   -- workspace.Items
local _bringDragRemote   = nil   -- RemoteEvents.RequestStartDraggingItem
local _bringStopRemote   = nil   -- RemoteEvents.StopDraggingItem
local _bringRemotesReady = false

local function _initBringRemotes()
    if _bringRemotesReady then return true end
    pcall(function()
        _bringItemsFolder = workspace:FindFirstChild("Items")
            or workspace:WaitForChild("Items", 6)
        local re = game:GetService("ReplicatedStorage")
            :WaitForChild("RemoteEvents", 6)
        _bringDragRemote = re:WaitForChild("RequestStartDraggingItem", 5)
        _bringStopRemote = re:WaitForChild("StopDraggingItem", 5)
    end)
    _bringRemotesReady = (_bringDragRemote ~= nil and _bringStopRemote ~= nil)
    return _bringRemotesReady
end

-- Move um Model via drag remote.
-- targetPos: Vector3 do destino — o servidor solta e a física faz o item cair.
local function moveItemViaRemote(model, targetPos)
    pcall(function()
        _bringDragRemote:FireServer(model)
        task.wait(0.05)
        if model.PrimaryPart then
            model:SetPrimaryPartCFrame(CFrame.new(targetPos))
        else
            local p = model:FindFirstChildWhichIsA("BasePart")
            if p then
                model.PrimaryPart = p
                model:SetPrimaryPartCFrame(CFrame.new(targetPos))
            end
        end
        task.wait(0.05)
        _bringStopRemote:FireServer(model)
    end)
end

BRING_CATS = {
    {key="BLog", trLabel="bLogLabel", trDesc="bLogDesc", label="🪵 Bring Log", cor=Color3.fromRGB(190,130,60), desc="Only gets: Log", nomes={"Log"}},
    {key="BCombust",  trLabel="bCombustLabel", trDesc="bCombustDesc", label="🔥 Bring Combustível", cor=Color3.fromRGB(255,120,30),  desc="Coal, Biofuel, Fuel Canister, Oil Barrel, Chair…",
     nomes={"Coal","Biofuel","Oil Barrel","OilBarrel","Fuel Canister","FuelCanister","Chair"}},
    {key="BCarcacas", trLabel="bCarcacasLabel", trDesc="bCarcacasDesc", label="🦴 Bring Carcaças",    cor=Color3.fromRGB(180,100,50),  desc="Wolf, Bear, PolarBear, Hellephant, Frog, Alien Corpse…",
     nomes={
       "Wolf Corpse","WolfCorpse","Alpha Wolf Corpse","AlphaWolfCorpse",
       "Bear Corpse","BearCorpse","Polar Bear Corpse","PolarBearCorpse",
       "Arctic Fox Corpse","ArcticFoxCorpse",
       "Mammoth Corpse","MammothCorpse","Lava Mammoth Corpse","LavaMammothCorpse",
       "Mossy Mammoth Corpse","MossyMammothCorpse",
       "Hellephant Corpse","HellephantCorpse",
       "Frog Corpse","FrogCorpse",
       "Scorpion Corpse","ScorpionCorpse",
       "Meteor Crab Corpse","MeteorCrabCorpse",
       "Boar Corpse","BoarCorpse",
       "Cat Corpse","CatCorpse",
       "Bunny Corpse","BunnyCorpse","Turkey Corpse","TurkeyCorpse","Horse Corpse","HorseCorpse",
       "Cultist Corpse","CultistCorpse",
       "Crossbow Cultist Corpse","CrossbowCultistCorpse",
       "Juggernaut Cultist Corpse","JuggernautCultistCorpse",
       "Cultist King Corpse","CultistKingCorpse",
       "Alien Corpse","AlienCorpse","Elite Alien Corpse","EliteAlienCorpse",
     }},
    {key="BSucata",   trLabel="bSucataLabel", trDesc="bSucataDesc", label="🔩 Bring Sucata",      cor=Color3.fromRGB(155,210,255), desc="Bolt, Sheet Metal, UFO Junk, Tyre…",
     nomes={"Bolt","Sheet Metal","SheetMetal",
             "UFO Junk","UFOJunk","UFO Component","UFOComponent","UFO Scrap","UFOScrap",
             "Broken Fan","BrokenFan","Old Radio","OldRadio","Broken Radio","BrokenRadio",
             "Broken Microwave","BrokenMicrowave","Tyre","Metal Chair","MetalChair",
             "Old Car Engine","OldCarEngine","Washing Machine","WashingMachine",
             "Cultist Experiment","CultistExperiment","Cultist Prototype","CultistPrototype",
             "Alien Junk","AlienJunk",
             "Meteor Shard","MeteorShard","Gold Shard","GoldShard"}},
    {key="BMateriais",trLabel="bMateriaisLabel",trDesc="bMateriaisDesc",label="💎 Bring Materiais",   cor=Color3.fromRGB(220,175,255), desc="Cultist Gem, Forest Gem, Mossy Coin…",
     nomes={"Cultist Gem","CultistGem","Forest Gem","ForestGem","Forest Gem Fragment","ForestGemFragment",
             "Gem of the Forest","Gem of the Forest Fragment",
             "Mossy Coin","MossyCoin","Flower","Sapling","Sacrifice Totem","SacrificeTotem",
             "Raw Obsidiron Ore","RawObsidironOre","Obsidiron Ingot","ObsidironIngot",
             "Scalding Obsidiron Ingot","Feather","Alien Tech","AlienTech"}},
    {key="BMadeira",  trLabel="bMadeiraLabel", trDesc="bMadeiraDesc", label="🌲 Bring Madeira",     cor=Color3.fromRGB(150,100,50),  desc="Wood, Plank, Sapling, Log Gate, Flag…",
     nomes={"Wood","Plank","Sapling","Log","Super Log","SuperLog","Log Gate","LogGate","Flag","Totem Pole","TotemPole"}},
    {key="BComidas",  trLabel="bComidasLabel",trDesc="bComidasDesc",label="🍖 Bring Comidas",     cor=Color3.fromRGB(255,115,165), desc="Carrot, Corn, Steak, Ribs, Stew, Candy…",
     nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake",
             "Giant Carrot","GiantCarrot",
             "Cooked Egg","CookedEgg",
             "Morsel","Morsel?","Cooked Morsel","CookedMorsel",
             "Steak","Cooked Steak","CookedSteak",
             "Ribs","Cooked Ribs","CookedRibs",
             "Stew","Hearty Stew","HeartyStew",
             "Meat? Sandwich","MeatSandwich",
             "Seafood Chowder","SeafoodChowder",
             "Steak Dinner","SteakDinner",
             "Pumpkin Soup","PumpkinSoup",
             "BBQ Ribs","BBQRibs",
             "Carrot Cake","CarrotCake",
             "Jar o' Jelly","JarOJelly",
             "Candy Apple","CandyApple","Candy Corn","CandyCorn",
             "Pumpkin Pie","PumpkinPie","Cotton Candy","CottonCandy",
             "Turkey Leg","TurkeyLeg","Cooked Turkey Leg","CookedTurkeyLeg",
             "Stuffing","Sweet Potato","SweetPotato","Berry Juice","BerryJuice",
             "Casserole","Corn on the Cob","CornOnTheCob",
             "Stuffing Bowl","StuffingBowl","Roast Turkey","RoastTurkey",
             "Stuffed Peppers","StuffedPeppers","Sweet Potato Pie","SweetPotatoPie",
             "Spicy Swordfish","SpicySwordfish",
             "Hearty Thanksgiving Meal","HeartyThanksgivingMeal"}},
    {key="BPeixes",   trLabel="bPeixesLabel",trDesc="bPeixesDesc",label="🐟 Bring Peixes",      cor=Color3.fromRGB(80,180,255),  desc="Mackerel, Salmon, Clownfish, Shark, Lava Eel…",
     nomes={"Mackerel","Cooked Mackerel","CookedMackerel","Salmon","Cooked Salmon","CookedSalmon","Clownfish","Cooked Clownfish","CookedClownfish","Jellyfish","Char","Cooked Char","CookedChar","Eel","Cooked Eel","CookedEel","Swordfish","Cooked Swordfish","CookedSwordfish","Shark","Cooked Shark","CookedShark","Lava Eel","LavaEel","Cooked Lava Eel","CookedLavaEel","Lionfish","Cooked Lionfish","CookedLionfish"}},
    {key="BSementes", trLabel="bSementesLabel",trDesc="bSementesDesc",label="🌱 Bring Sementes",    cor=Color3.fromRGB(135,245,115), desc="Chili, Berry, Flower, Dripleaf, Moonflower, Stareweed, Cavevine, Firefly, Mandrake…",
     nomes={"Chili Seeds","ChiliSeeds",
             "Flower Seeds","FlowerSeeds",
             "Berry Seeds","BerrySeeds",
             "Firefly Seeds","FireflySeeds",
             "Dripleaf Seeds","DripleafSeeds",
             "Moonflower Seeds","MoonflowerSeeds",
             "Stareweed Seeds","StareweedSeeds",
             "Cavevine Seeds","CavevineSeeds","Cave Vine Seeds","CaveVineSeeds",
             "Mandrake Seeds","MandrakeSeeds"}},
    {key="BFerr", trLabel="bFerrLabel",trDesc="bFerrDesc",label="🪓 Bring Ferramentas", cor=Color3.fromRGB(255,200,55), desc="Sacks, Axes, Rods, Flutes, Armaduras, Egg Basket…",
     nomes={"Old Sack","OldSack","Good Sack","GoodSack","Infernal Sack","InfernalSack","Giant Sack","GiantSack",
             "Old Axe","OldAxe","Good Axe","GoodAxe","Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw",
             "Old Rod","OldRod","Good Rod","GoodRod","Strong Rod","StrongRod",
             "Old Taming Flute","OldFlute","Good Taming Flute","GoodFlute","Strong Taming Flute","StrongFlute",
             "Old Flashlight","OldFlashlight","Strong Flashlight","StrongFlashlight",
             "Axe Trim Kit","AxeTrimKit","Armor Trim Kit","ArmorTrimKit",
             "Hammer","Paint Brush","PaintBrush","Watering Can","WateringCan",
             "Leather Body","LeatherBody","Alien Armour","AlienArmour","Frog Boots","FrogBoots","Poison Armour","PoisonArmour",
             "Egg Basket","EggBasket","Easter Basket","EasterBasket",
             "Recycler","Log Gate","LogGate","Flag"}},
    {key="BArmas",    trLabel="bArmasLabel",trDesc="bArmasDesc",label="⚔️ Bring Armas",       cor=Color3.fromRGB(255,70,70),   desc="Spear, Ice Sword, Crossbow, Revolver, Rifle, Carrot Dart…",
     nomes={
       "Spear","Morningstar","Katana",
       "Laser Sword","LaserSword","Ice Sword","IceSword",
       "Trident","Poison Spear","PoisonSpear",
       "Infernal Sword","InfernalSword",
       "Obsidiron Hammer","ObsidironHammer",
       "Scythe","Vampire Scythe","VampireScythe",
       "Cultist King Mace","CultistKingMace",
       "Crossbow","Infernal Crossbow","InfernalCrossbow",
       "Revolver","Rifle","Tactical Shotgun","TacticalShotgun",
       "Ray Gun","RayGun","Laser Cannon","LaserCannon","Flamethrower",
       "Snowball","Frozen Shuriken","FrozenShuriken","Kunai",
       "Wildfire","Blowpipe",
       "Carrot Dart","CarrotDart",
     }},
    {key="BAmmo", trLabel="bAmmoLabel",trDesc="bAmmoDesc",label="🔫 Bring Ammunition", cor=Color3.fromRGB(255,155,60), desc="Revolver Ammo, Rifle Ammo, Shotgun Ammo, Carrot Dart, Crossbow Bolts",
     nomes={"Revolver Ammo","RevolverAmmo","Rifle Ammo","RifleAmmo","Shotgun Ammo","ShotgunAmmo",
             "Carrot Dart","CarrotDart",
             "Crossbow Bolt","CrossbowBolt","Crossbow Bolts","CrossbowBolts","Bolt Ammo","BoltAmmo"}},
    {key="BCura",     trLabel="bCuraLabel",trDesc="bCuraDesc",label="💊 Bring Cura",        cor=Color3.fromRGB(100,255,180), desc="Bandage, Medkit", nomes={"Bandage","Medkit"}},
    {key="BPelts",    trLabel="bPeltsLabel",trDesc="bPeltsDesc",label="🦺 Bring Pelts",       cor=Color3.fromRGB(210,170,120), desc="Bunny Foot, Wolf Pelt, Bear Pelt, Arctic Fox, Scorpion Shell, Mammoth Tusk, Boar Pelt…",
     nomes={"Bunny Foot","BunnyFoot","Wolf Pelt","WolfPelt","Alpha Wolf Pelt","AlphaWolfPelt",
             "Easter Alpha Wolf Pelt","EasterAlphaWolfPelt",
             "Bear Pelt","BearPelt","Polar Bear Pelt","PolarBearPelt","Arctic Fox Pelt","ArcticFoxPelt",
             "Boar Pelt","BoarPelt",
             "Mammoth Tusk","MammothTusk","Scorpion Shell","ScorpionShell",
             "Cultist King Antler","CultistKingAntler"}},
    {key="BChaves",   trLabel="bChavesLabel",trDesc="bChavesDesc",label="🗝️ Bring Chaves",      cor=Color3.fromRGB(255,230,80),  desc="Red, Blue, Yellow, Grey, Frog Key",
     nomes={"Red Key","RedKey","Blue Key","BlueKey","Yellow Key","YellowKey","Grey Key","GreyKey","Frog Key","FrogKey"}},

    {key="BPocoes",   trLabel="bPocoesLabel",trDesc="bPocoesDesc",label="🧪 Bring Poções",      cor=Color3.fromRGB(195,100,255), desc="Dripleaf, Moonflower, Stareweed, Cave Vine, Mandrake, Firefly, Glowing Mushroom",
     nomes={"Dripleaf",
             "Moonflower","Moonflower Bulb","MoonflowerBulb",
             "Stareweed","Stareweed Petal","StareweedPetal",
             "Cave Vine","CaveVine","Cave Vine Flower","CaveVineFlower","CaveVine Flower","Cavevine Flower",
             "Mandrake","Mandrake Plant","MandrakePlant","Mandrake Root","MandrakeRoot",
             "Firefly","Glowing Mushroom","GlowingMushroom"}},
    {key="BBlueprint",trLabel="bBlueprintLabel",trDesc="bBlueprintDesc",label="📋 Bring Blueprints",  cor=Color3.fromRGB(130,190,255), desc="Crafting, Defense, Furniture, Recycler, Log Gate, Flag…",
     nomes={"Crafting Blueprint","CraftingBlueprint","Defense Blueprint","DefenseBlueprint",
             "Furniture Blueprint","FurnitureBlueprint","Obsidiron Chest Blueprint","ObsidironChestBlueprint",
             "Halloween Blueprint","HalloweenBlueprint",
             "Recycler Blueprint","RecyclerBlueprint",
             "Log Gate Blueprint","LogGateBlueprint",
             "Flag Blueprint","FlagBlueprint",
             "Totem Pole Blueprint","TotemPoleBlueprint"}},

    -- ══════════════════════════════════════════════════════════════
    -- NOVIDADES 2026 — Aliens Revenge (27/jun), Bat Cave Part 2, Fairy/Mini Biome
    -- ══════════════════════════════════════════════════════════════
    {key="BAlien2",   label="👽 Bring Tech Alien",  cor=Color3.fromRGB(120,255,150), desc="UFO Battery, Alien Shotgun, Dissolve Ray, Alien Chest itens…",
     nomes={"UFO Battery","UFOBattery","Alien Battery","AlienBattery",
             "Alien Shotgun","AlienShotgun","Dissolve Ray","DissolveRay",
             "Alien Egg","AlienEgg","Alien Chest Key","AlienChestKey"}},
    {key="BExplosivos", label="💣 Bring Explosivos", cor=Color3.fromRGB(255,90,40), desc="Dynamite, Concussion Grenade, Exploding Ammo, Ammo Box…",
     nomes={"Dynamite","Concussion Grenade","ConcussionGrenade","Impact Grenade","ImpactGrenade",
             "Exploding Revolver Ammo","ExplodingRevolverAmmo","Exploding Rifle Ammo","ExplodingRifleAmmo",
             "Explosive Ammo","ExplosiveAmmo","Ammo Box","AmmoBox","Ammo Box Recipe Tablet","AmmoBoxRecipeTablet"}},
    {key="BCorrompidos", label="☠️ Bring Corrompidos", cor=Color3.fromRGB(150,40,200), desc="Corrupted Revolver, Shotgun, Axe, Armor, Throwing Axe…",
     nomes={"Corrupted Revolver","CorruptedRevolver","Corrupted Shotgun","CorruptedShotgun",
             "Corrupted Axe","CorruptedAxe","Corrupted Armor","CorruptedArmor","Corrupted Armour","CorruptedArmour",
             "Corrupted Throwing Axe","CorruptedThrowingAxe","Corrupted Gear","CorruptedGear"}},
    {key="BFada",     label="🧚 Bring Fada (Fairy Biome)", cor=Color3.fromRGB(255,180,255), desc="Acorn, Farm Recipe Tablet, Strawberry/Rose/Tree Seeds…",
     nomes={"Acorn","Acorns","Farm Recipe Tablet","FarmRecipeTablet",
             "Strawberry","Strawberry Seeds","StrawberrySeeds",
             "Rose","Rose Seeds","RoseSeeds","Tree Seeds","TreeSeeds",
             "Fairy Dust","FairyDust"}},
    {key="BDinoKid",  label="🦕 Bring Dino Kid",  cor=Color3.fromRGB(255,150,100), desc="Lunchbox, Yo-Yo, Crayon, Plush (trinkets do Dino Kid)",
     nomes={"Lunchbox","Yo-Yo","YoYo","Crayon","Plush"}},
}

local bringLookup={}
for _,c in ipairs(BRING_CATS) do
    local s={}; for _,n in ipairs(c.nomes) do s[n:lower()]=true end; bringLookup[c.key]=s
end

-- ══════════════════════════════════════════════════════
-- BRING HISTORY — salva posições originais para Limpar
-- ══════════════════════════════════════════════════════
local bringHistory = {}    -- [key] = lista de entries do bring atual
local bringAllHistory = {} -- para Bring All
-- Posição VERDADEIRA (antes do PRIMEIRO bring) — nunca sobrescrita enquanto o item existir
local bringTrueOrigin = {} -- [BasePart] = CFrame original verdadeira

local function saveTrueOrigin(part, cf)
    if not bringTrueOrigin[part] then
        bringTrueOrigin[part] = cf
    end
end

local function getTrueOrigin(part)
    return bringTrueOrigin[part]
end

local function clearTrueOrigin(part)
    bringTrueOrigin[part] = nil
end

local function limparBring(key)
    local hist = bringHistory[key]
    if not hist or #hist == 0 then return 0 end
    local restored = 0
    for _, e in ipairs(hist) do
        pcall(function()
            local part = e.obj  -- BasePart (primaryPart) salva no histórico
            if not part or not part.Parent then return end
            local trueOrigin = getTrueOrigin(part) or e.originalCFrame
            if not trueOrigin then return end

            -- Devolve via remote (mesmo protocolo do bring — server aceita)
            if _bringRemotesReady and e.isModel and e.model and e.model.Parent then
                moveItemViaRemote(e.model, trueOrigin.Position)
            else
                -- Fallback direto para BaseParts ou sem remote
                pcall(function() part.CFrame = trueOrigin end)
                pcall(function() part.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
            end
            clearTrueOrigin(part)
            restored = restored + 1
        end)
    end
    bringHistory[key] = {}
    return restored
end

local function limparBringAll()
    local restored = 0
    for _, e in ipairs(bringAllHistory) do
        pcall(function()
            local part = e.obj
            if not part or not part.Parent then return end
            local trueOrigin = getTrueOrigin(part) or e.originalCFrame
            if not trueOrigin then return end

            if _bringRemotesReady and e.isModel and e.model and e.model.Parent then
                moveItemViaRemote(e.model, trueOrigin.Position)
            else
                pcall(function() part.CFrame = trueOrigin end)
                pcall(function() part.AssemblyLinearVelocity = Vector3.new(0,0,0) end)
            end
            clearTrueOrigin(part)
            restored = restored + 1
        end)
    end
    bringAllHistory = {}
    return restored
end

local function executarBring(key)
    -- Garante que os remotes do jogo estão prontos
    _initBringRemotes()

    local char = Player.Character; if not char then return 0 end
    local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return 0 end
    local lookup = bringLookup[key]; if not lookup then return 0 end
    local cf = hrp.CFrame; local count = 0
    bringHistory[key] = {}

    -- Fonte dos itens: workspace.Items (pasta oficial do jogo, igual ao GG.lua)
    -- Fallback para GetDescendants se a pasta não existir
    local itemSource = _bringItemsFolder and _bringItemsFolder:GetChildren() or workspace:GetDescendants()
    local useRemote  = _bringRemotesReady

    -- ── Coleta Models elegíveis ───────────────────────────────────────────────
    local eligiveis = {}
    local pchars = {}
    for _,pl in ipairs(Players:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end
    local seen = {}  -- dedup: evita contar o mesmo Model duas vezes

    for _, obj in ipairs(itemSource) do
        pcall(function()
            if not obj or not obj.Parent then return end
            if seen[obj] then return end

            -- Aceita Model sem Humanoid (item do mundo) ou BasePart solta
            local model     = nil
            local checkName = nil

            if obj:IsA("Model") and not obj:FindFirstChildWhichIsA("Humanoid") then
                model     = obj
                checkName = obj.Name:lower()
            elseif obj:IsA("BasePart") then
                -- BasePart solta (não dentro de um Model de jogador)
                local par = obj.Parent
                local isPlayerChar = false
                for pc in pairs(pchars) do
                    if par == pc or (par and par:IsAncestorOf(pc)) then isPlayerChar=true; break end
                end
                if isPlayerChar then return end
                model     = obj          -- trata como entidade individual
                checkName = obj.Name:lower()
            else
                return
            end

            -- Filtra por nome
            if not lookup[checkName] then return end

            -- Filtra NPC characters
            for pc in pairs(pchars) do
                if pc == obj or (pc.IsAncestorOf and pc:IsAncestorOf(obj)) then return end
            end

            -- Filtro de tamanho (apenas para BasePart solta)
            if obj:IsA("BasePart") then
                local sz = obj.Size
                if sz.X > 14 or sz.Y > 14 or sz.Z > 14 then return end
            end

            seen[obj] = true
            table.insert(eligiveis, {model=model, isModel=obj:IsA("Model")})
        end)
    end

    -- ── Raycast params ────────────────────────────────────────────────────────
    local rayP = RaycastParams.new()
    rayP.FilterType = Enum.RaycastFilterType.Exclude

    local total = #eligiveis
    for i, entry in ipairs(eligiveis) do
        pcall(function()
            local model   = entry.model
            local isModel = entry.isModel

            if not model or not model.Parent then return end

            char = Player.Character; if not char then return end
            hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            cf   = hrp.CFrame

            -- Posição original para histórico (PrimaryPart ou BasePart)
            local primaryPart = isModel
                and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart"))
                or  model  -- é uma BasePart diretamente
            if not primaryPart then return end

            local originalCF = primaryPart.CFrame
            saveTrueOrigin(primaryPart, originalCF)

            -- ── Calcula offset pelo estilo de bring ───────────────────────
            local offsetX, offsetZ
            local _bs = bringStyle
            if _bs == "espalhado" then
                local angle  = math.random() * math.pi * 2
                local radius = 10 + math.random() * 25
                offsetX = math.cos(angle) * radius; offsetZ = math.sin(angle) * radius
            elseif _bs == "juntos" then
                local layer  = math.floor((i-1) / 8)
                local slot   = (i-1) % 8
                local angle  = (slot / 8) * math.pi * 2
                local radius = 1.5 + layer * 1.2
                offsetX = math.cos(angle) * radius; offsetZ = math.sin(angle) * radius
            elseif _bs == "circulo" then
                local angle  = ((i-1) / total) * math.pi * 2
                local radius = 6
                offsetX = math.cos(angle) * radius; offsetZ = math.sin(angle) * radius
            else
                local layer  = math.floor((i-1) / 12)
                local slot   = (i-1) % 12
                local angle  = (slot / 12) * math.pi * 2 + layer * 0.5
                local radius = 4 + layer * 3.5 + math.random() * 1.5
                offsetX = math.cos(angle) * radius; offsetZ = math.sin(angle) * radius
            end

            -- ── Calcula posição final pelo modo de destino ────────────────
            local target
            local _bdm = bringDestMode
            if _bdm == "ceu" then
                local angle  = ((i-1)/total) * math.pi * 2
                local radius = 3 + math.floor((i-1)/8) * 1.5
                target = Vector3.new(
                    cf.Position.X + math.cos(angle)*radius,
                    cf.Position.Y + 120,
                    cf.Position.Z + math.sin(angle)*radius)
            elseif _bdm == "fogueira" then
                local fogPos = _campfirePosCache or cf.Position
                local angle  = ((i-1)/total) * math.pi * 2
                local radius = 3 + math.floor((i-1)/8) * 1.5
                local groundY = fogPos.Y
                pcall(function()
                    rayP.FilterDescendantsInstances = {char, model}
                    local ro = Vector3.new(fogPos.X + math.cos(angle)*radius, fogPos.Y+30, fogPos.Z + math.sin(angle)*radius)
                    local res = workspace:Raycast(ro, Vector3.new(0,-60,0), rayP)
                    if res then groundY = res.Position.Y end
                end)
                target = Vector3.new(fogPos.X + math.cos(angle)*radius, groundY + 4, fogPos.Z + math.sin(angle)*radius)
            else
                local groundY = cf.Position.Y - 2.5
                pcall(function()
                    rayP.FilterDescendantsInstances = {char, model}
                    local ro = Vector3.new(cf.Position.X+offsetX, cf.Position.Y+30, cf.Position.Z+offsetZ)
                    local res = workspace:Raycast(ro, Vector3.new(0,-100,0), rayP)
                    if res then groundY = res.Position.Y end
                end)
                target = Vector3.new(cf.Position.X + offsetX, groundY + 4, cf.Position.Z + offsetZ)
            end

            -- ── Move o item via remote (abordagem GG.lua) ────────────────
            -- O servidor valida o drag → item cai com física real (solto, não bugado)
            if useRemote and isModel then
                moveItemViaRemote(model, target)
            else
                -- Fallback: modelo antigo para BaseParts soltas ou sem remote
                pcall(function() primaryPart.Anchored = false end)
                primaryPart.CanCollide = true
                primaryPart.CFrame = CFrame.new(target)
                pcall(function() primaryPart.AssemblyLinearVelocity = Vector3.new(0,-5,0) end)
            end

            count = count + 1
            table.insert(bringHistory[key], {
                model        = model,
                isModel      = isModel,
                obj          = primaryPart,     -- compatibilidade com limparBring
                originalCFrame = originalCF,
            })
        end)
    end

    return count
end

local bringTabLO=0
local function bringLO() bringTabLO = bringTabLO + 1; return bringTabLO end

-- Declaradas fora do do-block para que makeBringRow possa acessá-las
local _bringUnlockCallbacks = {}
local function registerBringUnlockCb(fn)
    table.insert(_bringUnlockCallbacks, fn)
end

-- ══════════════════════════════════════════════════════
-- makeBringDropdown — conecta botão já criado a ciclo de opções
-- Parâmetros: cfg.opts, cfg.getVal, cfg.setVal, cfg.btn, cfg.onSelect
-- ══════════════════════════════════════════════════════
local function makeBringDropdown(cfg)
    local opts    = cfg.opts
    local btn     = cfg.btn
    local getVal  = cfg.getVal
    local setVal  = cfg.setVal
    local onSel   = cfg.onSelect
    if not btn or not opts or #opts == 0 then return end
    btn.MouseButton1Click:Connect(function()
        -- Encontra índice atual e avança para o próximo
        local cur = getVal()
        local idx = 1
        for i, o in ipairs(opts) do
            if o.key == cur then idx = i; break end
        end
        idx = (idx % #opts) + 1
        local opt = opts[idx]
        setVal(opt.key)
        if onSel then onSel(opt) end
        -- Feedback visual: pisca o botão
        TweenService:Create(btn, TweenInfo.new(0.08), {BackgroundTransparency=0.5}):Play()
        task.delay(0.12, function()
            TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency=0.15}):Play()
        end)
    end)
end

-- ══════════════════════════════════════════════════════
-- PAINEL INFO BRING — exibe count, delay e modo de destino
-- Fica NO TOPO da aba Bring (LayoutOrder = 0)
-- ══════════════════════════════════════════════════════
do
    -- ═══════════════════════════════════════════════════════════════
    -- ACCORDION: Bring Configuração — Premium VoidWare UI
    -- ═══════════════════════════════════════════════════════════════
    local BRING_CFG_COR = Color3.fromRGB(148,112,220)
    local _bcTitleLbl = nil
    local _bcCard, _bcCF, _bcDrop = makeAccordionCard(Pages["Bring"], bringLO, {
        icon     = "⚙️",
        title    = "Bring Configuração (Normal)",
        summary  = "Estilo, destino e velocidade dos itens trazidos.",
        color    = BRING_CFG_COR,
        contentH = 36 + 9 + 20 + 58 + 6 + 20 + 58 + 6 + 20 + 58 + 16,
    })
    for _, obj in ipairs(_bcCard:GetChildren()) do
        if obj:IsA("TextLabel") and obj.Font == Enum.Font.GothamBlack then
            _bcTitleLbl = obj; break
        end
    end
    local _bcy = 36
    _accDivLine(_bcCF, _bcy, BRING_CFG_COR); _bcy = _bcy + 9

    local ROW_H       = 58
    local GAP         = 6
    local SEC_LBL_H   = 20
    local POP_ITEM_H  = 52

    local _openDropFrame = nil
    local _openDropArr   = nil

    local function closeCurrentDrop()
        if _openDropFrame then
            TweenService:Create(_openDropFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quart),
                {Size = UDim2.new(1, -20, 0, 0)}):Play()
            if _openDropArr then
                TweenService:Create(_openDropArr, TweenInfo.new(0.2), {Rotation = 0}):Play()
            end
            task.delay(0.2, function()
                if _openDropFrame then _openDropFrame.Visible = false end
            end)
            _openDropFrame = nil; _openDropArr = nil
            _bcDrop(0)
        end
    end

    -- ── Cria trigger premium ──────────────────────────────────────
    -- [strip 3px][iconBox 44px][label+desc][tagBadge][arrow]
    local function makePremiumRow(y, rowLabel, rowIcon, initOpt)
        local cor = initOpt.cor or BRING_CFG_COR

        -- Label de seção
        local secLbl = Instance.new("TextLabel", _bcCF)
        secLbl.BackgroundTransparency = 1
        secLbl.Position = UDim2.new(0, 14, 0, y)
        secLbl.Size = UDim2.new(0.55, 0, 0, SEC_LBL_H)
        secLbl.Font = Enum.Font.GothamBold
        secLbl.Text = rowIcon.."  "..rowLabel:upper()
        secLbl.TextColor3 = Color3.fromRGB(160, 140, 200)
        secLbl.TextSize = 9
        secLbl.TextXAlignment = Enum.TextXAlignment.Left
        secLbl.ZIndex = 8

        -- Linha à direita do label
        local secLine = Instance.new("Frame", _bcCF)
        secLine.BackgroundColor3 = cor
        secLine.BackgroundTransparency = 0.65
        secLine.BorderSizePixel = 0
        secLine.Position = UDim2.new(0.58, 0, 0, y + 9)
        secLine.Size = UDim2.new(0.38, -14, 0, 1)
        secLine.ZIndex = 8

        -- Trigger frame
        local ty = y + SEC_LBL_H
        local trigger = Instance.new("Frame", _bcCF)
        trigger.BackgroundColor3 = Color3.fromRGB(18, 10, 38)
        trigger.BorderSizePixel = 0
        trigger.Position = UDim2.new(0, 10, 0, ty)
        trigger.Size = UDim2.new(1, -20, 0, ROW_H)
        trigger.ZIndex = 8
        trigger.ClipsDescendants = true
        Instance.new("UICorner", trigger).CornerRadius = UDim.new(0, 10)

        local tGrad = Instance.new("UIGradient", trigger)
        tGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(28, 14, 60)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(16,  8, 38)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(10,  5, 22)),
        })
        tGrad.Rotation = 135

        local tStroke = Instance.new("UIStroke", trigger)
        tStroke.Color = cor; tStroke.Thickness = 1.5; tStroke.Transparency = 0.45
        tStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        -- Glow line no topo
        local glowLine = Instance.new("Frame", trigger)
        glowLine.BackgroundColor3 = cor
        glowLine.BackgroundTransparency = 0.5
        glowLine.BorderSizePixel = 0
        glowLine.AnchorPoint = Vector2.new(0.5, 0)
        glowLine.Position = UDim2.new(0.5, 0, 0, 0)
        glowLine.Size = UDim2.new(0.7, 0, 0, 1)
        glowLine.ZIndex = 9
        Instance.new("UICorner", glowLine).CornerRadius = UDim.new(1, 0)

        -- Strip lateral colorida
        local strip = Instance.new("Frame", trigger)
        strip.BackgroundColor3 = cor
        strip.BackgroundTransparency = 0.1
        strip.BorderSizePixel = 0
        strip.Position = UDim2.new(0, 0, 0.2, 0)
        strip.Size = UDim2.new(0, 3, 0.6, 0)
        strip.ZIndex = 9
        Instance.new("UICorner", strip).CornerRadius = UDim.new(0, 2)

        -- Icon box
        local iconBox = Instance.new("Frame", trigger)
        iconBox.BackgroundColor3 = cor
        iconBox.BackgroundTransparency = 0.76
        iconBox.BorderSizePixel = 0
        iconBox.Position = UDim2.new(0, 3, 0, 0)
        iconBox.Size = UDim2.new(0, 44, 1, 0)
        iconBox.ZIndex = 9
        local ibGrad = Instance.new("UIGradient", iconBox)
        ibGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 30, 110)),
        })
        ibGrad.Rotation = 135
        local iconLbl = Instance.new("TextLabel", iconBox)
        iconLbl.BackgroundTransparency = 1
        iconLbl.Size = UDim2.new(1, 0, 1, 0)
        iconLbl.Font = Enum.Font.Gotham; iconLbl.TextSize = 18
        iconLbl.Text = initOpt.icon or "●"; iconLbl.ZIndex = 10

        -- Bloco de texto
        local textBlock = Instance.new("Frame", trigger)
        textBlock.BackgroundTransparency = 1
        textBlock.Position = UDim2.new(0, 52, 0, 0)
        textBlock.Size = UDim2.new(1, -130, 1, 0)
        textBlock.ZIndex = 9

        local mainLbl = Instance.new("TextLabel", textBlock)
        mainLbl.BackgroundTransparency = 1
        mainLbl.Position = UDim2.new(0, 0, 0, 10)
        mainLbl.Size = UDim2.new(1, 0, 0, 18)
        mainLbl.Font = Enum.Font.GothamBold; mainLbl.TextSize = 13
        mainLbl.Text = initOpt.label or ""
        mainLbl.TextColor3 = cor
        mainLbl.TextXAlignment = Enum.TextXAlignment.Left; mainLbl.ZIndex = 10

        local descLbl = Instance.new("TextLabel", textBlock)
        descLbl.BackgroundTransparency = 1
        descLbl.Position = UDim2.new(0, 0, 0, 30)
        descLbl.Size = UDim2.new(1, 0, 0, 12)
        descLbl.Font = Enum.Font.Gotham; descLbl.TextSize = 10
        descLbl.Text = initOpt.desc or ""
        descLbl.TextColor3 = Color3.fromRGB(95, 78, 130)
        descLbl.TextXAlignment = Enum.TextXAlignment.Left
        descLbl.TextTruncate = Enum.TextTruncate.AtEnd; descLbl.ZIndex = 10

        -- Tag badge
        local tagBadge = Instance.new("Frame", trigger)
        tagBadge.BackgroundColor3 = cor
        tagBadge.BackgroundTransparency = 0.75
        tagBadge.BorderSizePixel = 0
        tagBadge.AnchorPoint = Vector2.new(1, 0.5)
        tagBadge.Position = UDim2.new(1, -34, 0.5, 0)
        tagBadge.Size = UDim2.new(0, 54, 0, 18)
        tagBadge.ZIndex = 10
        Instance.new("UICorner", tagBadge).CornerRadius = UDim.new(1, 0)
        local tagStroke = Instance.new("UIStroke", tagBadge)
        tagStroke.Color = cor; tagStroke.Thickness = 1; tagStroke.Transparency = 0.45
        local tagLbl = Instance.new("TextLabel", tagBadge)
        tagLbl.BackgroundTransparency = 1
        tagLbl.Size = UDim2.new(1, 0, 1, 0)
        tagLbl.Font = Enum.Font.GothamBold; tagLbl.TextSize = 9
        tagLbl.Text = initOpt.tag or initOpt.label or ""
        tagLbl.TextColor3 = cor; tagLbl.ZIndex = 11

        -- Seta
        local arr = Instance.new("TextLabel", trigger)
        arr.BackgroundTransparency = 1
        arr.AnchorPoint = Vector2.new(1, 0.5)
        arr.Position = UDim2.new(1, -8, 0.5, 0)
        arr.Size = UDim2.new(0, 18, 0, 18)
        arr.Font = Enum.Font.GothamBlack; arr.TextSize = 11
        arr.Text = "▾"; arr.TextColor3 = cor; arr.ZIndex = 10

        -- Botão invisível
        local btn = Instance.new("TextButton", trigger)
        btn.BackgroundTransparency = 1
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.Text = ""; btn.ZIndex = 12

        btn.MouseEnter:Connect(function()
            TweenService:Create(tStroke,  TweenInfo.new(0.15), {Transparency=0.1}):Play()
            TweenService:Create(glowLine, TweenInfo.new(0.15), {BackgroundTransparency=0.1}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(tStroke,  TweenInfo.new(0.15), {Transparency=0.45}):Play()
            TweenService:Create(glowLine, TweenInfo.new(0.15), {BackgroundTransparency=0.5}):Play()
        end)

        return btn, tStroke, tagLbl, tagBadge, arr, iconLbl, mainLbl, descLbl, strip, glowLine, ty
    end

    -- ── Cria dropdown popup premium ───────────────────────────────
    -- Constrói um item dentro do popup (função separada para economizar registros)
    local function _buildDropItem(pop, opt, iy, isSelFn)
        local cor = opt.cor or BRING_CFG_COR
        local itemF = Instance.new("Frame", pop)
        itemF.BackgroundColor3 = Color3.fromRGB(20,12,40)
        itemF.BackgroundTransparency = 0.15
        itemF.BorderSizePixel = 0
        itemF.Position = UDim2.new(0,0,0,iy)
        itemF.Size = UDim2.new(1,0,0,POP_ITEM_H)
        itemF.ZIndex = 31; itemF.ClipsDescendants = true

        local bar = Instance.new("Frame", itemF)
        bar.BackgroundColor3 = cor; bar.BackgroundTransparency = 0.5
        bar.BorderSizePixel = 0
        bar.Position = UDim2.new(0,0,0.2,0)
        bar.Size = UDim2.new(0,3,0.6,0); bar.ZIndex = 33
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0,2)

        local iBox = Instance.new("Frame", itemF)
        iBox.BackgroundColor3 = cor; iBox.BackgroundTransparency = 0.78
        iBox.BorderSizePixel = 0
        iBox.Position = UDim2.new(0,3,0,0)
        iBox.Size = UDim2.new(0,44,1,0); iBox.ZIndex = 32
        local ibG = Instance.new("UIGradient", iBox)
        ibG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(40,20,80))})
        ibG.Rotation = 135
        local iIcon = Instance.new("TextLabel", iBox)
        iIcon.BackgroundTransparency = 1; iIcon.Size = UDim2.new(1,0,1,0)
        iIcon.Font = Enum.Font.Gotham; iIcon.TextSize = 16
        iIcon.Text = opt.icon or "●"; iIcon.ZIndex = 33

        local iMain = Instance.new("TextLabel", itemF)
        iMain.BackgroundTransparency = 1
        iMain.Position = UDim2.new(0,52,0,7)
        iMain.Size = UDim2.new(1,-115,0,16)
        iMain.Font = Enum.Font.GothamBold; iMain.TextSize = 12
        iMain.Text = opt.label or opt.key; iMain.TextColor3 = cor
        iMain.TextXAlignment = Enum.TextXAlignment.Left; iMain.ZIndex = 33

        local iTagF = Instance.new("Frame", itemF)
        iTagF.BackgroundColor3 = cor; iTagF.BackgroundTransparency = 0.78
        iTagF.BorderSizePixel = 0
        iTagF.Position = UDim2.new(0,52,0,25)
        iTagF.Size = UDim2.new(0,58,0,14); iTagF.ZIndex = 33
        Instance.new("UICorner", iTagF).CornerRadius = UDim.new(1,0)
        local iTagS = Instance.new("UIStroke", iTagF)
        iTagS.Color = cor; iTagS.Thickness = 1; iTagS.Transparency = 0.5
        local iTagLbl = Instance.new("TextLabel", iTagF)
        iTagLbl.BackgroundTransparency = 1; iTagLbl.Size = UDim2.new(1,0,1,0)
        iTagLbl.Font = Enum.Font.GothamBold; iTagLbl.TextSize = 8
        iTagLbl.Text = opt.tag or ""; iTagLbl.TextColor3 = cor; iTagLbl.ZIndex = 34

        local iDesc = Instance.new("TextLabel", itemF)
        iDesc.BackgroundTransparency = 1
        iDesc.Position = UDim2.new(0,52,0,35)
        iDesc.Size = UDim2.new(1,-115,0,11)
        iDesc.Font = Enum.Font.Gotham; iDesc.TextSize = 9
        iDesc.Text = opt.desc or ""; iDesc.TextColor3 = Color3.fromRGB(88,72,118)
        iDesc.TextXAlignment = Enum.TextXAlignment.Left
        iDesc.TextTruncate = Enum.TextTruncate.AtEnd; iDesc.ZIndex = 33

        if opt.ms then
            local iMs = Instance.new("TextLabel", itemF)
            iMs.BackgroundTransparency = 1
            iMs.Position = UDim2.new(1,-80,0,7)
            iMs.Size = UDim2.new(0,68,0,16)
            iMs.Font = Enum.Font.GothamBold; iMs.TextSize = 10
            iMs.Text = "⏱  "..opt.ms; iMs.TextColor3 = cor
            iMs.TextXAlignment = Enum.TextXAlignment.Right; iMs.ZIndex = 33
        end

        local sel0 = isSelFn(opt.key)
        local chkF = Instance.new("Frame", itemF)
        chkF.AnchorPoint = Vector2.new(1,0.5)
        chkF.Position = UDim2.new(1,-10,0.5,0)
        chkF.Size = UDim2.new(0,18,0,18)
        chkF.BackgroundColor3 = sel0 and cor or Color3.fromRGB(20,12,40)
        chkF.BackgroundTransparency = sel0 and 0.15 or 0.4
        chkF.BorderSizePixel = 0; chkF.ZIndex = 34
        Instance.new("UICorner", chkF).CornerRadius = UDim.new(1,0)
        local chkS = Instance.new("UIStroke", chkF)
        chkS.Color = cor; chkS.Thickness = 1.5; chkS.Transparency = 0.4
        local chkLbl = Instance.new("TextLabel", chkF)
        chkLbl.BackgroundTransparency = 1; chkLbl.Size = UDim2.new(1,0,1,0)
        chkLbl.Font = Enum.Font.GothamBlack; chkLbl.TextSize = 10
        chkLbl.Text = sel0 and "●" or ""
        chkLbl.TextColor3 = Color3.fromRGB(255,255,255); chkLbl.ZIndex = 35

        if sel0 then
            itemF.BackgroundColor3 = Color3.fromRGB(26,16,52)
            itemF.BackgroundTransparency = 0.05
            bar.BackgroundTransparency = 0
        end

        local iBtnReal = Instance.new("TextButton", itemF)
        iBtnReal.BackgroundTransparency = 1
        iBtnReal.Size = UDim2.new(1,0,1,0)
        iBtnReal.Text = ""; iBtnReal.ZIndex = 36

        return {btn=iBtnReal, chk=chkLbl, chkF=chkF, bar=bar, frame=itemF, opt=opt, main=iMain}
    end

    local function makePremiumDrop(triggerY, opts, getVal, setVal, onSel,
                                   btnRef, strokeRef, tagLblRef, tagBadgeRef, arrRef,
                                   iconRef, mainRef, descRef, stripRef, glowRef)
        local POP_H = #opts * POP_ITEM_H + 10
        local pop = Instance.new("Frame", _bcCF)
        pop.BackgroundColor3 = Color3.fromRGB(13,7,27)
        pop.BackgroundTransparency = 0.04
        pop.BorderSizePixel = 0
        pop.Position = UDim2.new(0,10,0,triggerY + ROW_H + 4)
        pop.Size = UDim2.new(1,-20,0,0)
        pop.ZIndex = 30; pop.Visible = false; pop.ClipsDescendants = true
        Instance.new("UICorner", pop).CornerRadius = UDim.new(0,10)
        local popStroke = Instance.new("UIStroke", pop)
        popStroke.Thickness = 1.5; popStroke.Transparency = 0.35
        local popGrad = Instance.new("UIGradient", pop)
        popGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(22,12,48)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8,4,20)),
        })
        popGrad.Rotation = 160
        local topDiv = Instance.new("Frame", pop)
        topDiv.BackgroundColor3 = BRING_CFG_COR; topDiv.BackgroundTransparency = 0.55
        topDiv.BorderSizePixel = 0; topDiv.AnchorPoint = Vector2.new(0.5,0)
        topDiv.Position = UDim2.new(0.5,0,0,0)
        topDiv.Size = UDim2.new(0.8,0,0,1); topDiv.ZIndex = 31
        Instance.new("UICorner", topDiv).CornerRadius = UDim.new(1,0)

        local function updateTrigger(opt)
            local cor = opt.cor or BRING_CFG_COR
            mainRef.Text = opt.label or opt.key; mainRef.TextColor3 = cor
            descRef.Text = opt.desc or ""; iconRef.Text = opt.icon or "●"
            tagLblRef.Text = opt.tag or opt.label or ""; tagLblRef.TextColor3 = cor
            tagBadgeRef.BackgroundColor3 = cor; arrRef.TextColor3 = cor
            stripRef.BackgroundColor3 = cor; glowRef.BackgroundColor3 = cor
            TweenService:Create(strokeRef, TweenInfo.new(0.2), {Color=cor}):Play()
            popStroke.Color = cor; topDiv.BackgroundColor3 = cor
        end

        local itemBtns = {}
        for i, opt in ipairs(opts) do
            local entry = _buildDropItem(pop, opt, 5+(i-1)*POP_ITEM_H, function(k) return k == getVal() end)
            if i < #opts then
                local div = Instance.new("Frame", entry.frame)
                div.BackgroundColor3 = Color3.fromRGB(30,18,55); div.BackgroundTransparency = 0.4
                div.BorderSizePixel = 0; div.Position = UDim2.new(0.04,0,1,-1)
                div.Size = UDim2.new(0.92,0,0,1); div.ZIndex = 32
            end
            table.insert(itemBtns, entry)
            local opt2, frame2, bar2, main2 = opt, entry.frame, entry.bar, entry.main
            entry.btn.MouseEnter:Connect(function()
                if opt2.key ~= getVal() then
                    TweenService:Create(frame2, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(24,14,48),BackgroundTransparency=0.05}):Play()
                    TweenService:Create(bar2,   TweenInfo.new(0.1), {BackgroundTransparency=0.2}):Play()
                    TweenService:Create(main2,  TweenInfo.new(0.1), {TextColor3=Color3.fromRGB(190,148,255)}):Play()
                end
            end)
            entry.btn.MouseLeave:Connect(function()
                if opt2.key ~= getVal() then
                    TweenService:Create(frame2, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(20,12,40),BackgroundTransparency=0.15}):Play()
                    TweenService:Create(bar2,   TweenInfo.new(0.1), {BackgroundTransparency=0.5}):Play()
                    TweenService:Create(main2,  TweenInfo.new(0.1), {TextColor3=opt2.cor or BRING_CFG_COR}):Play()
                end
            end)
            entry.btn.MouseButton1Click:Connect(function()
                setVal(opt2.key); updateTrigger(opt2)
                for _, ib in ipairs(itemBtns) do
                    local sel = (ib.opt.key == opt2.key)
                    ib.chk.Text = sel and "●" or ""
                    TweenService:Create(ib.chkF,  TweenInfo.new(0.15), {BackgroundColor3=ib.opt.cor or BRING_CFG_COR, BackgroundTransparency=sel and 0.15 or 0.4}):Play()
                    TweenService:Create(ib.bar,   TweenInfo.new(0.15), {BackgroundTransparency=sel and 0 or 0.5}):Play()
                    TweenService:Create(ib.frame, TweenInfo.new(0.15), {BackgroundColor3=sel and Color3.fromRGB(26,16,52) or Color3.fromRGB(20,12,40), BackgroundTransparency=sel and 0.05 or 0.15}):Play()
                    TweenService:Create(ib.main,  TweenInfo.new(0.15), {TextColor3=sel and (ib.opt.cor or BRING_CFG_COR) or Color3.fromRGB(100,85,140)}):Play()
                end
                if onSel then onSel(opt2) end
                closeCurrentDrop()
            end)
        end

        for _, o in ipairs(opts) do
            if o.key == getVal() then updateTrigger(o); break end
        end

        btnRef.MouseButton1Click:Connect(function()
            if _openDropFrame and _openDropFrame ~= pop then closeCurrentDrop() end
            local opening = not pop.Visible
            if opening then
                pop.Visible = true; pop.Size = UDim2.new(1,-20,0,0)
                TweenService:Create(pop,       TweenInfo.new(0.22,Enum.EasingStyle.Quart), {Size=UDim2.new(1,-20,0,POP_H)}):Play()
                TweenService:Create(arrRef,    TweenInfo.new(0.2), {Rotation=180}):Play()
                TweenService:Create(strokeRef, TweenInfo.new(0.15), {Transparency=0.1}):Play()
                _openDropFrame = pop; _openDropArr = arrRef; _bcDrop(POP_H+8)
            else
                TweenService:Create(pop,       TweenInfo.new(0.18,Enum.EasingStyle.Quart), {Size=UDim2.new(1,-20,0,0)}):Play()
                TweenService:Create(arrRef,    TweenInfo.new(0.2), {Rotation=0}):Play()
                TweenService:Create(strokeRef, TweenInfo.new(0.15), {Transparency=0.45}):Play()
                task.delay(0.2, function() if _openDropFrame ~= pop then pop.Visible = false end end)
                pop.Visible = false; _openDropFrame = nil; _openDropArr = nil; _bcDrop(0)
            end
        end)
    end

    -- ── Opções ───────────────────────────────────────────────────
    local STYLE_OPTS = {
        {key="padrao",    label="Padrão",    icon="🔵", tag="Default",   desc="Itens se movem em linha reta até o destino.",      cor=Color3.fromRGB(94, 168, 255)},
        {key="espalhado", label="Espalhado", icon="🟠", tag="Dinâmico",  desc="Itens chegam em trajetórias diferentes, em leque.", cor=Color3.fromRGB(255, 140, 56)},
        {key="juntos",    label="Juntos",    icon="🟢", tag="Agrupado",  desc="Todos os itens se agrupam em um único ponto.",      cor=Color3.fromRGB(66,  224, 120)},
        {key="circulo",   label="Círculo",   icon="🔴", tag="Orbital",   desc="Itens formam um círculo ao redor do destino.",      cor=Color3.fromRGB(255,  90,  90)},
    }
    local SPEED_OPTS = {
        {key="normal", label="Normal",  icon="🐢", tag="Estável",     ms="50ms", desc="Delay padrão entre cada item (0.05s).",  cor=Color3.fromRGB(94,  200, 255)},
        {key="rapido", label="Rápido",  icon="🐇", tag="Veloz",       ms="10ms", desc="Delay reduzido pela metade (0.01s).",    cor=Color3.fromRGB(66,  224, 120)},
        {key="mega",   label="Mega",    icon="⚡", tag="Instantâneo", ms="0ms",  desc="Sem delay — todos chegam de uma vez.",   cor=Color3.fromRGB(255, 200,  56)},
    }
    local MODE_OPTS = {
        {key="jogador",  label="Jogador",  icon="🧍", tag="Pessoal", desc="Itens teleportados diretamente até você.",        cor=Color3.fromRGB(94,  200, 255)},
        {key="fogueira", label="Fogueira", icon="🔥", tag="Base",    desc="Itens são enviados para a fogueira mais próxima.", cor=Color3.fromRGB(255, 120,  40)},
        {key="ceu",      label="Céu",      icon="🌤️", tag="Aéreo",   desc="Itens são lançados ao céu e caem no destino.",    cor=Color3.fromRGB(140, 200, 255)},
    }

    local function findOpt(opts, key)
        for _, o in ipairs(opts) do if o.key == key then return o end end
        return opts[1]
    end

    -- ── Row 1: Estilo ────────────────────────────────────────────
    local sBtn,sSt,sTagLbl,sTagBadge,sArr,sIcon,sMain,sDesc,sStrip,sGlow,sTY =
        makePremiumRow(_bcy, "Estilo", "✨", findOpt(STYLE_OPTS, bringStyle))
    makePremiumDrop(sTY, STYLE_OPTS,
        function() return bringStyle end,
        function(k) bringStyle = k end,
        function(opt) Notify.send({type="custom",icon=opt.icon,accent=opt.cor,title="Estilo Bring",msg=opt.tag.." — "..opt.desc,duration=2.5}) end,
        sBtn,sSt,sTagLbl,sTagBadge,sArr,sIcon,sMain,sDesc,sStrip,sGlow)
    _bcy = _bcy + SEC_LBL_H + ROW_H + GAP

    -- ── Row 2: Velocidade ─────────────────────────────────────────
    local vBtn,vSt,vTagLbl,vTagBadge,vArr,vIcon,vMain,vDesc,vStrip,vGlow,vTY =
        makePremiumRow(_bcy, "Velocidade", "⚡", findOpt(SPEED_OPTS, bringSpeed))
    makePremiumDrop(vTY, SPEED_OPTS,
        function() return bringSpeed end,
        function(k)
            bringSpeed = k
            for _, s in ipairs(SPEED_OPTS) do
                if s.key == k then
                    pcall(function()
                        local txt = "Bring Configuração ("..s.label..")"
                        if _bcTitleLbl then _bcTitleLbl.Text = txt
                        else
                            local lbl = _bcCard:FindFirstChild("TextLabel", true)
                            if lbl then lbl.Text = txt end
                        end
                    end)
                    break
                end
            end
        end,
        function(opt) Notify.send({type="custom",icon=opt.icon,accent=opt.cor,title="Velocidade Bring",msg=opt.ms.." — "..opt.desc,duration=2.5}) end,
        vBtn,vSt,vTagLbl,vTagBadge,vArr,vIcon,vMain,vDesc,vStrip,vGlow)
    _bcy = _bcy + SEC_LBL_H + ROW_H + GAP

    -- ── Row 3: Destino ────────────────────────────────────────────
    local function fireBringUnlock()
        for _, fn in ipairs(_bringUnlockCallbacks) do pcall(fn) end
    end
    local initDestOpt = bringDestMode
        and findOpt(MODE_OPTS, bringDestMode)
        or {key="jogador",label="Selecionar",icon="🔒",tag="Bloqueado",desc="Selecione um destino para desbloquear.",cor=Color3.fromRGB(180,130,60)}
    local dBtn,dSt,dTagLbl,dTagBadge,dArr,dIcon,dMain,dDesc,dStrip,dGlow,dTY =
        makePremiumRow(_bcy, "Destino", "🎯", initDestOpt)
    makePremiumDrop(dTY, MODE_OPTS,
        function() return bringDestMode end,
        function(k)
            local wasNil = (bringDestMode == nil)
            bringDestMode = k
            if wasNil then fireBringUnlock() end
        end,
        function(opt) Notify.send({type="info",icon=opt.icon,accent=opt.cor,title="Modo Bring",msg=opt.tag.." — "..opt.desc,duration=2.5}) end,
        dBtn,dSt,dTagLbl,dTagBadge,dArr,dIcon,dMain,dDesc,dStrip,dGlow)
    _bcy = _bcy + SEC_LBL_H + ROW_H + GAP

    -- ── Status: contagem de itens ─────────────────────────────────
    local countLb = _accStatusLbl(_bcCF, _bcy)

    -- Atualiza contagem de itens em background (sem travar — processa em chunks)
    task.spawn(function()
        while true do
            task.wait(20) -- intervalo longo entre cada contagem
            pcall(function()
                local descs = workspace:GetDescendants()
                local total = 0
                local CHUNK = 200 -- processa 200 objetos por frame
                for i, obj in ipairs(descs) do
                    pcall(function()
                        local nm = obj.Name:lower()
                        if bringLookup then
                            for _, lk in pairs(bringLookup) do
                                if lk[nm] then total = total + 1; break end
                            end
                        end
                    end)
                    if i % CHUNK == 0 then task.wait() end -- yield por frame
                end
                countLb.Text = "📦 "..tostring(total).." itens no mapa"
            end)
        end
    end)



local function makeBringSection(trKey, cor)
    local hdr=Instance.new("Frame",Pages["Bring"])
    hdr.BackgroundColor3=Color3.fromRGB(46,28,76); hdr.BorderSizePixel=0
    hdr.Size=UDim2.new(1,0,0,30); hdr.LayoutOrder=bringLO(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,10)
    local hdrG=Instance.new("UIGradient",hdr)
    hdrG.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(
            math.floor(cor.R*255*0.15+18), math.floor(cor.G*255*0.1+10), math.floor(cor.B*255*0.1+4)
        )),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(40,24,68))
    }); hdrG.Rotation=90
    local hdrS=Instance.new("UIStroke",hdr)
    hdrS.Color=cor; hdrS.Thickness=1.5; hdrS.Transparency=0.7
    hdrS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local pill=Instance.new("Frame",hdr); pill.BackgroundColor3=cor; pill.BorderSizePixel=0
    pill.Position=UDim2.new(0,8,0.5,-9); pill.Size=UDim2.new(0,4,0,18); pill.ZIndex=5
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local pillGlow=Instance.new("Frame",hdr); pillGlow.BackgroundColor3=cor
    pillGlow.BackgroundTransparency=0.75; pillGlow.BorderSizePixel=0
    pillGlow.Position=UDim2.new(0,6,0.5,-11); pillGlow.Size=UDim2.new(0,8,0,22); pillGlow.ZIndex=4
    Instance.new("UICorner",pillGlow).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,20,0,0); lbl.Size=UDim2.new(1,-28,1,0)
    lbl.Font=Enum.Font.GothamBlack; lbl.TextColor3=Color3.fromRGB(245,230,200)
    lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    local lblS=Instance.new("UIStroke",lbl); lblS.Color=Color3.fromRGB(0,0,0); lblS.Thickness=0.8; lblS.Transparency=0.5
    local divR=Instance.new("Frame",hdr); divR.BackgroundColor3=cor; divR.BackgroundTransparency=0.8
    divR.BorderSizePixel=0; divR.AnchorPoint=Vector2.new(1,0.5)
    divR.Position=UDim2.new(1,-8,0.5,0); divR.Size=UDim2.new(0,28,0,1); divR.ZIndex=5
    TL(lbl, trKey)
end

local function makeBringRow(bcat)
    local row=Instance.new("Frame",Pages["Bring"]); row.BackgroundColor3=Color3.fromRGB(52,32,84)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,82); row.LayoutOrder=bringLO(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)
    -- Gradiente cartoon
    local rowG=Instance.new("UIGradient",row)
    rowG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(60,38,96)),ColorSequenceKeypoint.new(1,Color3.fromRGB(44,28,72))}); rowG.Rotation=135
    -- Borda preta Brawl Stars
    local rowStroke=Instance.new("UIStroke",row)
    rowStroke.Color=Color3.fromRGB(8,4,20); rowStroke.Thickness=3
    rowStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    -- Shine cartoon
    local rowShine=Instance.new("Frame",row); rowShine.BackgroundColor3=Color3.fromRGB(255,255,255)
    rowShine.BackgroundTransparency=0.82; rowShine.BorderSizePixel=0
    rowShine.Position=UDim2.new(0,8,0,3); rowShine.Size=UDim2.new(0,55,0,4); rowShine.ZIndex=6
    Instance.new("UICorner",rowShine).CornerRadius=UDim.new(1,0)
    -- Barra lateral colorida
    local barLeft=Instance.new("Frame",row); barLeft.BackgroundColor3=bcat.cor; barLeft.BorderSizePixel=0
    barLeft.Position=UDim2.new(0,0,0.12,0); barLeft.Size=UDim2.new(0,5,0.76,0); barLeft.ZIndex=8
    Instance.new("UICorner",barLeft).CornerRadius=UDim.new(0,4)
    -- Caixa de ícone cartoon
    local iconBox=Instance.new("Frame",row); iconBox.BackgroundColor3=bcat.cor; iconBox.BackgroundTransparency=0.55
    iconBox.BorderSizePixel=0; iconBox.Position=UDim2.new(0,8,0.5,-18); iconBox.Size=UDim2.new(0,36,0,36); iconBox.ZIndex=7
    Instance.new("UICorner",iconBox).CornerRadius=UDim.new(0,9)
    local icoS=Instance.new("UIStroke",iconBox); icoS.Color=Color3.fromRGB(8,4,20); icoS.Thickness=2.5
    icoS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local icon=criarIconeBring(iconBox,bcat.key,bcat.cor); icon.Position=UDim2.new(0,4,0,4); icon.Size=UDim2.new(0,28,0,28)
    -- Nome da categoria (branco + stroke preta)
    local labelNome=Instance.new("TextLabel",row); labelNome.BackgroundTransparency=1
    labelNome.Position=UDim2.new(0,54,0,10); labelNome.Size=UDim2.new(1,-168,0,18)
    labelNome.Font=Enum.Font.GothamBlack; labelNome.Text=bcat.label; labelNome.TextColor3=Color3.fromRGB(255,255,255)
    labelNome.TextSize=11; labelNome.TextXAlignment=Enum.TextXAlignment.Left; labelNome.ZIndex=7
    local labelNomeS=Instance.new("UIStroke",labelNome); labelNomeS.Color=Color3.fromRGB(8,4,20); labelNomeS.Thickness=1.6
    if bcat.trLabel then TL(labelNome, bcat.trLabel) end
    local labelDesc=Instance.new("TextLabel",row); labelDesc.BackgroundTransparency=1
    labelDesc.Position=UDim2.new(0,54,0,30); labelDesc.Size=UDim2.new(1,-168,0,24)
    labelDesc.Font=Enum.Font.Gotham; labelDesc.Text=bcat.desc or ""; labelDesc.TextColor3=Color3.fromRGB(155,135,185)
    labelDesc.TextSize=9; labelDesc.TextXAlignment=Enum.TextXAlignment.Left; labelDesc.TextWrapped=true; labelDesc.ZIndex=7
    if bcat.trDesc then TL(labelDesc, bcat.trDesc) end
    local feedbackLbl=Instance.new("TextLabel",row); feedbackLbl.BackgroundTransparency=1
    feedbackLbl.Position=UDim2.new(1,-90,0,62); feedbackLbl.Size=UDim2.new(0,82,0,12)
    feedbackLbl.Font=Enum.Font.Gotham; feedbackLbl.Text=""; feedbackLbl.TextColor3=bcat.cor
    feedbackLbl.TextSize=8; feedbackLbl.TextXAlignment=Enum.TextXAlignment.Center; feedbackLbl.ZIndex=8

    -- Botão BRING — dourado cartoon (Brawl Stars style)
    local btnBring=Instance.new("TextButton",row); btnBring.BackgroundColor3=Color3.fromRGB(148,112,220)
    btnBring.BackgroundTransparency=0; btnBring.BorderSizePixel=0
    btnBring.Position=UDim2.new(1,-90,0,8); btnBring.Size=UDim2.new(0,82,0,28)
    btnBring.Font=Enum.Font.GothamBlack; btnBring.Text=T("bringBtnLabel"); btnBring.TextColor3=Color3.fromRGB(16,8,30)
    btnBring.TextSize=10; btnBring.ZIndex=9
    Instance.new("UICorner",btnBring).CornerRadius=UDim.new(0,9)
    local btnStroke=Instance.new("UIStroke",btnBring)
    btnStroke.Color=Color3.fromRGB(8,4,20); btnStroke.Thickness=2.5; btnStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local btnG=Instance.new("UIGradient",btnBring)
    btnG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,238,80)),ColorSequenceKeypoint.new(1,Color3.fromRGB(118,82,182))}); btnG.Rotation=90
    local btnShine=Instance.new("Frame",btnBring); btnShine.BackgroundColor3=Color3.fromRGB(255,255,255)
    btnShine.BackgroundTransparency=0.65; btnShine.BorderSizePixel=0
    btnShine.Position=UDim2.new(0,4,0,3); btnShine.Size=UDim2.new(0,40,0,7); btnShine.ZIndex=10
    Instance.new("UICorner",btnShine).CornerRadius=UDim.new(1,0)
    btnBring.MouseEnter:Connect(function()
        TweenService:Create(btnBring,TweenInfo.new(0.1),{Size=UDim2.new(0,84,0,30),Position=UDim2.new(1,-91,0,7)}):Play()
    end)
    btnBring.MouseLeave:Connect(function()
        TweenService:Create(btnBring,TweenInfo.new(0.1),{Size=UDim2.new(0,82,0,28),Position=UDim2.new(1,-90,0,8)}):Play()
    end)

    -- Botão LIMPAR — vermelho cartoon
    local btnLimpar=Instance.new("TextButton",row); btnLimpar.BackgroundColor3=Color3.fromRGB(180,40,40)
    btnLimpar.BackgroundTransparency=0.1; btnLimpar.BorderSizePixel=0
    btnLimpar.Position=UDim2.new(1,-90,0,42); btnLimpar.Size=UDim2.new(0,82,0,24)
    btnLimpar.Font=Enum.Font.GothamBold; btnLimpar.Text="🗑 Limpar"; btnLimpar.TextColor3=Color3.fromRGB(255,220,220)
    btnLimpar.TextSize=9; btnLimpar.ZIndex=9
    Instance.new("UICorner",btnLimpar).CornerRadius=UDim.new(0,8)
    local limparStroke=Instance.new("UIStroke",btnLimpar)
    limparStroke.Color=Color3.fromRGB(8,4,20); limparStroke.Thickness=2; limparStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    btnLimpar.MouseEnter:Connect(function() TweenService:Create(btnLimpar,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(220,50,50),BackgroundTransparency=0}):Play() end)
    btnLimpar.MouseLeave:Connect(function() TweenService:Create(btnLimpar,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(180,40,40),BackgroundTransparency=0.1}):Play() end)

    -- Lock: registra callback para desabilitar/habilitar com o modo
    local function applyLockState()
        local locked = (bringDestMode == nil)
        if locked then
            btnBring.BackgroundColor3 = Color3.fromRGB(52,32,84)
            btnBring.TextColor3 = Color3.fromRGB(120,90,30)
            btnBring.Text = "🔒 Bloqueado"
            TweenService:Create(btnStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(100,70,150),Transparency=0.5}):Play()
        else
            btnBring.BackgroundColor3 = Color3.fromRGB(148,112,220)
            btnBring.TextColor3 = Color3.fromRGB(16,8,30)
            btnBring.Text = T("bringBtnLabel")
            TweenService:Create(btnStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(8,4,20),Transparency=0}):Play()
        end
    end
    applyLockState()
    registerBringUnlockCb(applyLockState)

    local running=false
    btnBring.MouseButton1Click:Connect(function()
        if bringDestMode == nil then
            Notify.warn("Bring Bloqueado", "🔒 Selecione um modo no topo antes de usar o Bring!")
            return
        end
        if running then return end; running=true
        btnBring.Text=T("bringBtnSearching"); TweenService:Create(btnBring,TweenInfo.new(0.08),{BackgroundTransparency=0.4}):Play()
        -- Notificação de carregamento com contagem regressiva
        local _bringDur = 4
        local _bringEntry = Notify.send({type="info", icon="⏳", accent=bcat.cor,
            title="⏳ "..bcat.label, msg="Coletando itens... 0%", duration=_bringDur+2})
        task.spawn(function()
            for _p=1,10 do
                task.wait(_bringDur/10)
                pcall(function()
                    if _bringEntry and not _bringEntry._removed then
                        local entryMsg = _bringEntry.frame and _bringEntry.frame:FindFirstChildWhichIsA("TextLabel",true)
                        -- update progress text via direct search
                        for _,c in ipairs(_bringEntry.frame:GetDescendants()) do
                            if c:IsA("TextLabel") and c.Text:find("Coletando") then
                                c.Text = "Coletando itens... "..(tostring(_p*10)).."%"; break
                            end
                        end
                    end
                end)
            end
        end)
        task.spawn(function()
            local count=executarBring(bcat.key) or 0; task.wait(0.3)
            btnBring.Text=T("bringBtnLabel"); TweenService:Create(btnBring,TweenInfo.new(0.15),{BackgroundTransparency=0.15}):Play()
            pcall(function() if _bringEntry and not _bringEntry._removed then nRemoveEntry(_bringEntry,true) end end)
            if count>0 then
                feedbackLbl.Text="✓ "..tostring(count)..T("bringItemSuccess"); feedbackLbl.TextColor3=bcat.cor; feedbackLbl.TextTransparency=0
                Notify.success(bcat.label, "✓ "..tostring(count)..T("bringItemSuccess"), 3.5)
                task.delay(3,function() TweenService:Create(feedbackLbl,TweenInfo.new(0.5),{TextTransparency=1}):Play(); task.wait(0.6); feedbackLbl.Text=""; feedbackLbl.TextTransparency=0 end)
            else
                feedbackLbl.Text=T("bringItemFail"); feedbackLbl.TextColor3=Color3.fromRGB(200,80,80); feedbackLbl.TextTransparency=0
                Notify.send({type="error", icon="⚠️", accent=Color3.fromRGB(255,75,75), title=bcat.label, msg=T("bringFail"), duration=3})
                task.delay(2.5,function() TweenService:Create(feedbackLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); feedbackLbl.Text=""; feedbackLbl.TextTransparency=0; feedbackLbl.TextColor3=bcat.cor end)
            end
            TweenService:Create(rowStroke,TweenInfo.new(0.2),{Color=bcat.cor}):Play()
            task.delay(1.5,function() TweenService:Create(rowStroke,TweenInfo.new(0.4),{Color=Color3.fromRGB(148,112,220),Transparency=0.82}):Play() end)
            task.wait(1); running=false
        end)
    end)

    btnLimpar.MouseButton1Click:Connect(function()
        local restored = limparBring(bcat.key)
        if restored > 0 then
            feedbackLbl.Text="↩ "..tostring(restored).." restaurado(s)"; feedbackLbl.TextColor3=Color3.fromRGB(255,200,80); feedbackLbl.TextTransparency=0
            Notify.info(bcat.label, "↩ "..tostring(restored).." item(s) devolvido(s) ao lugar.", 3)
            TweenService:Create(btnLimpar,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(87,180,100)}):Play()
            task.delay(0.8, function() TweenService:Create(btnLimpar,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(50,32,80)}):Play() end)
            task.delay(2.5,function() TweenService:Create(feedbackLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); feedbackLbl.Text=""; feedbackLbl.TextTransparency=0; feedbackLbl.TextColor3=bcat.cor end)
        else
            feedbackLbl.Text="⚠ Nada a limpar"; feedbackLbl.TextColor3=Color3.fromRGB(160,160,180); feedbackLbl.TextTransparency=0
            task.delay(2,function() TweenService:Create(feedbackLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); feedbackLbl.Text=""; feedbackLbl.TextTransparency=0; feedbackLbl.TextColor3=bcat.cor end)
        end
    end)
    end -- validCats > 0


-- ══════════════════════════════════════════════════════
do
    local baSep=Instance.new("Frame",Pages["Bring"]); baSep.BackgroundColor3=Color3.fromRGB(148,112,220); baSep.BackgroundTransparency=0.82
    baSep.BorderSizePixel=0; baSep.Size=UDim2.new(1,0,0,1); baSep.LayoutOrder=bringLO(); baSep.ZIndex=5

    local baCard=Instance.new("Frame",Pages["Bring"])
    baCard.BackgroundColor3=Color3.fromRGB(54,34,88); baCard.BorderSizePixel=0
    baCard.Size=UDim2.new(1,0,0,90); baCard.LayoutOrder=bringLO(); baCard.ZIndex=5
    Instance.new("UICorner",baCard).CornerRadius=UDim.new(0,10)
    local baStroke=Instance.new("UIStroke",baCard); baStroke.Color=Color3.fromRGB(148,112,220); baStroke.Thickness=2.5; baStroke.Transparency=0.4

    -- Glow bg
    local baGlow=Instance.new("Frame",baCard); baGlow.BackgroundColor3=Color3.fromRGB(148,112,220)
    baGlow.BackgroundTransparency=0.92; baGlow.BorderSizePixel=0; baGlow.Size=UDim2.new(1,0,1,0); baGlow.ZIndex=5
    Instance.new("UICorner",baGlow).CornerRadius=UDim.new(0,10)

    -- Barra lateral
    local baBar=Instance.new("Frame",baCard); baBar.BackgroundColor3=Color3.fromRGB(148,112,220)
    baBar.BorderSizePixel=0; baBar.Size=UDim2.new(0,4,0.7,0); baBar.Position=UDim2.new(0,0,0.15,0); baBar.ZIndex=6
    Instance.new("UICorner",baBar).CornerRadius=UDim.new(0,2)

    -- Ícone
    local baIconBg=Instance.new("Frame",baCard); baIconBg.BackgroundColor3=Color3.fromRGB(148,112,220)
    baIconBg.BackgroundTransparency=0.72; baIconBg.BorderSizePixel=0
    baIconBg.Position=UDim2.new(0,10,0.5,-20); baIconBg.Size=UDim2.new(0,40,0,40); baIconBg.ZIndex=6
    Instance.new("UICorner",baIconBg).CornerRadius=UDim.new(0,10)
    local baIconLbl=Instance.new("TextLabel",baIconBg); baIconLbl.BackgroundTransparency=1
    baIconLbl.Size=UDim2.new(1,0,1,0); baIconLbl.Font=Enum.Font.GothamBlack
    baIconLbl.Text="⚡"; baIconLbl.TextColor3=Color3.fromRGB(15,8,30); baIconLbl.TextSize=22; baIconLbl.ZIndex=7

    -- Título e descrição
    local baTitleLbl=Instance.new("TextLabel",baCard); baTitleLbl.BackgroundTransparency=1
    baTitleLbl.Position=UDim2.new(0,60,0,14); baTitleLbl.Size=UDim2.new(1,-200,0,20)
    baTitleLbl.Font=Enum.Font.GothamBlack; baTitleLbl.Text="⚡ BRING ALL"
    trackLabel(baTitleLbl, "bringAllTitle")
    baTitleLbl.TextColor3=Color3.fromRGB(252,210,40); baTitleLbl.TextSize=14
    baTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; baTitleLbl.ZIndex=6
    local baDescLbl=Instance.new("TextLabel",baCard); baDescLbl.BackgroundTransparency=1
    baDescLbl.Position=UDim2.new(0,60,0,36); baDescLbl.Size=UDim2.new(1,-200,0,28)
    baDescLbl.Font=Enum.Font.Gotham; baDescLbl.Text="Traz TODOS os recursos do mapa de uma só vez"
    trackLabel(baDescLbl, "bringAllDesc")
    baDescLbl.TextColor3=Color3.fromRGB(155,135,185); baDescLbl.TextSize=9
    baDescLbl.TextWrapped=true; baDescLbl.TextXAlignment=Enum.TextXAlignment.Left; baDescLbl.ZIndex=6

    -- Feedback
    local baFeedLbl=Instance.new("TextLabel",baCard); baFeedLbl.BackgroundTransparency=1
    baFeedLbl.Position=UDim2.new(1,-115,0,64); baFeedLbl.Size=UDim2.new(0,107,0,14)
    baFeedLbl.Font=Enum.Font.GothamBold; baFeedLbl.Text=""
    baFeedLbl.TextColor3=Color3.fromRGB(148,112,220); baFeedLbl.TextSize=8
    baFeedLbl.TextXAlignment=Enum.TextXAlignment.Center; baFeedLbl.ZIndex=7

    -- Barra de progresso
    local baProgBg=Instance.new("Frame",baCard); baProgBg.BackgroundColor3=Color3.fromRGB(64,42,100)
    baProgBg.BorderSizePixel=0; baProgBg.Position=UDim2.new(1,-115,0.5,-5); baProgBg.Size=UDim2.new(0,107,0,4); baProgBg.ZIndex=6
    Instance.new("UICorner",baProgBg).CornerRadius=UDim.new(0,2)
    local baProgFill=Instance.new("Frame",baProgBg); baProgFill.BackgroundColor3=Color3.fromRGB(148,112,220)
    baProgFill.BorderSizePixel=0; baProgFill.Size=UDim2.new(0,0,1,0); baProgFill.ZIndex=7
    Instance.new("UICorner",baProgFill).CornerRadius=UDim.new(0,2)

    -- Botão
    local baBtn=Instance.new("TextButton",baCard); baBtn.BackgroundColor3=Color3.fromRGB(148,112,220)
    baBtn.BackgroundTransparency=0.05; baBtn.BorderSizePixel=0
    baBtn.Position=UDim2.new(1,-115,0,12); baBtn.Size=UDim2.new(0,107,0,44)
    baBtn.Font=Enum.Font.GothamBlack; baBtn.Text="▼  BRING ALL"
    trackLabel(baBtn, "bringAllBtn")
    baBtn.TextColor3=Color3.fromRGB(15,8,30); baBtn.TextSize=11; baBtn.ZIndex=7
    Instance.new("UICorner",baBtn).CornerRadius=UDim.new(0,9)
    local baBtnStroke=Instance.new("UIStroke",baBtn); baBtnStroke.Color=Color3.fromRGB(15,8,30); baBtnStroke.Thickness=1.2; baBtnStroke.Transparency=0.5
    baBtn.MouseEnter:Connect(function() TweenService:Create(baBtn,TweenInfo.new(0.12),{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(255,220,50)}):Play() end)
    baBtn.MouseLeave:Connect(function() TweenService:Create(baBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.05,BackgroundColor3=Color3.fromRGB(148,112,220)}):Play() end)

    -- Lookup global de todos os itens
    local ALL_ITEMS_99N = {}
    for _,c in ipairs(BRING_CATS) do for _,n in ipairs(c.nomes) do ALL_ITEMS_99N[n:lower()]=true end end

    local baRunning=false
    baBtn.MouseButton1Click:Connect(function()
        if bringDestMode == nil then
            Notify.warn("Bring All Bloqueado", "🔒 Selecione um modo de destino no topo antes de usar o Bring All!")
            return
        end
        if baRunning then return end; baRunning=true
        baBtn.Text=T("bringAllBtnSearching"); TweenService:Create(baBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.4}):Play()
        TweenService:Create(baProgFill,TweenInfo.new(0.1),{Size=UDim2.new(0,0,1,0)}):Play()
        Notify.info(T("bringAllTitle"), T("bringAllNotifSearching"), 3)
        task.spawn(function()
            -- Sem delay — executa imediatamente
            local char=Player.Character; if not char then baRunning=false; return end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then baRunning=false; return end
            local cf=hrp.CFrame; local count=0; local trazidos={}
            bringAllHistory = {}
            local pchars={}; for _,pl in ipairs(Players:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end
            local ok,descs=pcall(function() return workspace:GetDescendants() end)
            local rayParamsBA = RaycastParams.new()
            rayParamsBA.FilterType = Enum.RaycastFilterType.Exclude
            if ok then
                local eligiveis = {}
                local total=#descs
                local alreadyAdded = {}
                local batch = 0
                for i,obj in ipairs(descs) do
                    batch = batch + 1
                    if batch%200==0 then  -- batch maior = mais rápido
                        task.wait()
                        local pct=i/total
                        TweenService:Create(baProgFill,TweenInfo.new(0.1),{Size=UDim2.new(pct*0.5,0,1,0)}):Play()
                        char=Player.Character; if not char then break end
                        hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then break end; cf=hrp.CFrame
                    end
                    pcall(function()
                        if not obj or not obj.Parent then return end

                        local targetPart   = nil
                        local checkName    = nil
                        local savedModelParts = nil

                        if obj:IsA("BasePart") then
                            local parentModel = obj.Parent
                            if parentModel and parentModel:IsA("Model") and not parentModel:FindFirstChildWhichIsA("Humanoid") then
                                return
                            end
                            targetPart = obj
                            checkName  = obj.Name:lower()
                        elseif obj:IsA("Model") and not obj:FindFirstChildWhichIsA("Humanoid") then
                            local p2 = obj:FindFirstChildWhichIsA("BasePart")
                            if not p2 then return end
                            if alreadyAdded[obj] then return end
                            targetPart = p2
                            checkName  = obj.Name:lower()
                            savedModelParts = {}
                            for _,bp in ipairs(obj:GetDescendants()) do
                                if bp:IsA("BasePart") and bp ~= p2 then
                                    table.insert(savedModelParts, {bp=bp, originalCF=bp.CFrame})
                                end
                            end
                        else
                            return
                        end

                        if not targetPart or not checkName then return end
                        for pc in pairs(pchars) do if pc==obj or pc:IsAncestorOf(obj) then return end end
                        local p=obj.Parent
                        for _=1,4 do if p and p:IsA("Model") and p:FindFirstChildWhichIsA("Humanoid") then return end; p=p and p.Parent end
                        if not ALL_ITEMS_99N[checkName] then return end
                        local sz=targetPart.Size; if sz.X>18 or sz.Y>18 or sz.Z>18 then return end

                        if obj:IsA("Model") then alreadyAdded[obj] = true end
                        table.insert(eligiveis, {obj=obj, targetPart=targetPart, savedModelParts=savedModelParts})
                    end)
                end

                -- Move com remote legítimo (GG.lua approach) — compatível com destMode
                local nTotal = #eligiveis
                local useRemoteBA = _bringRemotesReady

                for idx, eEntry in ipairs(eligiveis) do
                    pcall(function()
                        local obj    = eEntry.obj
                        local isModelBA = eEntry.obj:IsA("Model")
                        local primaryBA = isModelBA
                            and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"))
                            or  obj

                        char = Player.Character; if not char then return end
                        hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                        cf   = hrp.CFrame

                        if not primaryBA or not primaryBA.Parent then return end

                        local originalCF = primaryBA.CFrame
                        saveTrueOrigin(primaryBA, originalCF)

                        -- Raio em camadas (12 por camada)
                        local layer  = math.floor((idx-1) / 12)
                        local slot   = (idx-1) % 12
                        local angle  = (slot / 12) * math.pi * 2 + layer * 0.5
                        local radius = 4 + layer * 3.5 + math.random() * 1.5
                        local offsetX = math.cos(angle) * radius
                        local offsetZ = math.sin(angle) * radius

                        -- Destino respeitando bringDestMode
                        local target
                        local _bdmBA = bringDestMode
                        if _bdmBA == "ceu" then
                            local a2 = ((idx-1)/nTotal) * math.pi * 2
                            local r2 = 3 + math.floor((idx-1)/8) * 1.5
                            target = Vector3.new(
                                cf.Position.X + math.cos(a2)*r2,
                                cf.Position.Y + 120,
                                cf.Position.Z + math.sin(a2)*r2)
                        elseif _bdmBA == "fogueira" then
                            local fogPos = _campfirePosCache or cf.Position
                            local a2 = ((idx-1)/nTotal) * math.pi * 2
                            local r2 = 3 + math.floor((idx-1)/8) * 1.5
                            local groundY = fogPos.Y
                            pcall(function()
                                rayParamsBA.FilterDescendantsInstances = {char, obj}
                                local ro = Vector3.new(fogPos.X+math.cos(a2)*r2, fogPos.Y+30, fogPos.Z+math.sin(a2)*r2)
                                local res = workspace:Raycast(ro, Vector3.new(0,-60,0), rayParamsBA)
                                if res then groundY = res.Position.Y end
                            end)
                            target = Vector3.new(fogPos.X+math.cos(a2)*r2, groundY+4, fogPos.Z+math.sin(a2)*r2)
                        else
                            local groundY = cf.Position.Y - 2.5
                            pcall(function()
                                rayParamsBA.FilterDescendantsInstances = {char, obj}
                                local ro = Vector3.new(cf.Position.X+offsetX, cf.Position.Y+30, cf.Position.Z+offsetZ)
                                local res = workspace:Raycast(ro, Vector3.new(0,-100,0), rayParamsBA)
                                if res then groundY = res.Position.Y end
                            end)
                            target = Vector3.new(cf.Position.X+offsetX, groundY+4, cf.Position.Z+offsetZ)
                        end

                        -- Move via remote (Model) ou fallback (BasePart solta)
                        if useRemoteBA and isModelBA then
                            moveItemViaRemote(obj, target)
                        else
                            pcall(function() primaryBA.Anchored = false end)
                            primaryBA.CanCollide = true
                            primaryBA.CFrame = CFrame.new(target)
                            pcall(function() primaryBA.AssemblyLinearVelocity = Vector3.new(0,-5,0) end)
                        end

                        count = count + 1
                        local entry = {
                            model          = obj,
                            isModel        = isModelBA,
                            obj            = primaryBA,
                            originalCFrame = originalCF,
                        }
                        table.insert(trazidos, entry)
                        table.insert(bringAllHistory, entry)
                    end)
                    if idx % 30 == 0 then
                        task.wait()
                        local pct2 = 0.5 + (idx / math.max(nTotal,1)) * 0.5
                        TweenService:Create(baProgFill, TweenInfo.new(0.1), {Size=UDim2.new(pct2,0,1,0)}):Play()
                    end
                end
            end
            -- Remote solta os itens com física real — não precisa re-ancorar
            -- Feedback
            task.wait(0.2)
            TweenService:Create(baProgFill,TweenInfo.new(0.3),{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(87,242,135)}):Play()
            baBtn.Text=T("bringAllBtn"); TweenService:Create(baBtn,TweenInfo.new(0.15),{BackgroundTransparency=0.1}):Play()
            if count>0 then
                baFeedLbl.Text="✓ "..count.." itens coletados!"; baFeedLbl.TextColor3=Color3.fromRGB(87,242,135)
                Notify.success(T("bringAllTitle"), tostring(count)..T("bringSuccess"), 4.5)
            else
                baFeedLbl.Text="✗ Nenhum item encontrado"; baFeedLbl.TextColor3=Color3.fromRGB(255,90,90)
                Notify.warn(T("bringAllTitle"), T("bringFail"), 3)
            end
            task.delay(3.5,function()
                TweenService:Create(baProgFill,TweenInfo.new(0.5),{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(120,86,188)}):Play()
                TweenService:Create(baFeedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play()
                task.wait(0.5); baFeedLbl.Text=""; baFeedLbl.TextTransparency=0
            end)
            task.wait(1.5); baRunning=false
        end)
    end)

    -- Botão LIMPAR ALL
    local baLimparBtn=Instance.new("TextButton",baCard); baLimparBtn.BackgroundColor3=Color3.fromRGB(50,32,80)
    baLimparBtn.BackgroundTransparency=0.1; baLimparBtn.BorderSizePixel=0
    baLimparBtn.Position=UDim2.new(1,-115,0,62); baLimparBtn.Size=UDim2.new(0,107,0,20)
    baLimparBtn.Font=Enum.Font.GothamBold; baLimparBtn.Text="🗑 Limpar Tudo"
    baLimparBtn.TextColor3=Color3.fromRGB(180,190,220); baLimparBtn.TextSize=9; baLimparBtn.ZIndex=8
    Instance.new("UICorner",baLimparBtn).CornerRadius=UDim.new(0,7)
    local baLimparStroke=Instance.new("UIStroke",baLimparBtn); baLimparStroke.Color=Color3.fromRGB(155,115,50); baLimparStroke.Thickness=1; baLimparStroke.Transparency=0.5
    baCard.Size=UDim2.new(1,0,0,92)
    baLimparBtn.MouseEnter:Connect(function() TweenService:Create(baLimparBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(200,80,80),BackgroundTransparency=0}):Play() end)
    baLimparBtn.MouseLeave:Connect(function() TweenService:Create(baLimparBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(50,32,80),BackgroundTransparency=0.1}):Play() end)
    baLimparBtn.MouseButton1Click:Connect(function()
        local restored = limparBringAll()
        if restored > 0 then
            baFeedLbl.Text="↩ "..tostring(restored).." restaurado(s)"; baFeedLbl.TextColor3=Color3.fromRGB(255,200,80); baFeedLbl.TextTransparency=0
            Notify.info(T("bringAllTitle"), "↩ "..tostring(restored).." item(s) devolvido(s) ao lugar.", 3.5)
            TweenService:Create(baLimparBtn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(87,180,100)}):Play()
            task.delay(0.8, function() TweenService:Create(baLimparBtn,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(50,32,80)}):Play() end)
            task.delay(3,function() TweenService:Create(baFeedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); baFeedLbl.Text=""; baFeedLbl.TextTransparency=0 end)
        else
            baFeedLbl.Text="⚠ Nada a limpar"; baFeedLbl.TextColor3=Color3.fromRGB(160,160,180); baFeedLbl.TextTransparency=0
            task.delay(2,function() TweenService:Create(baFeedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); baFeedLbl.Text=""; baFeedLbl.TextTransparency=0 end)
        end
    end)
end

-- ── Bring — Accordion por grupo ─────────────────────────────
local bringCatMap={}; for _,c in ipairs(BRING_CATS) do bringCatMap[c.key]=c end

local BRING_GROUPS = {
    {key="bringGrpFuel",     cor=Color3.fromRGB(255,130,40), icon="🔥", keys={"BLog","BCombust","BCarcacas","BSucata","BMateriais"}},
    {key="bringGrpFood",     cor=Color3.fromRGB(255,120,170),icon="🍖", keys={"BComidas","BPeixes","BSementes","BPocoes"}},
    {key="bringGrpEquip",    cor=Color3.fromRGB(255,200,55), icon="⚔️", keys={"BFerr","BArmas","BAmmo","BCura","BPelts"}},
    {key="bringGrpSpecials", cor=Color3.fromRGB(255,230,80), icon="🗝️", keys={"BChaves","BBlueprint"}},
    {key="bringGrpNovo",     cor=Color3.fromRGB(150,255,180),icon="🆕", keys={"BAlien2","BExplosivos","BCorrompidos","BFada","BDinoKid"}},
}

for _,grp in ipairs(BRING_GROUPS) do
    local validCats = {}
    for _,k in ipairs(grp.keys) do if bringCatMap[k] then table.insert(validCats,bringCatMap[k]) end end
    if #validCats > 0 then

    local rowH = 76
    local cH = 36+9+#validCats*rowH+8
    local _bgCard, _bgCF = makeAccordionCard(Pages["Bring"], bringLO, {
        icon=grp.icon, title=T(grp.key), summary=nil,
        color=grp.cor, contentH=cH,
    })

    local _by = 36+8
    local _bdiv=Instance.new("Frame",_bgCF); _bdiv.BackgroundColor3=grp.cor
    _bdiv.BackgroundTransparency=0.78; _bdiv.BorderSizePixel=0
    _bdiv.Position=UDim2.new(0,10,0,_by); _bdiv.Size=UDim2.new(1,-20,0,1); _bdiv.ZIndex=7
    _by=_by+9

    for i, bcat in ipairs(validCats) do do -- scope: libera locais a cada iteração
        -- Row compacta dentro do accordion
        local row=Instance.new("Frame",_bgCF)
        row.BackgroundColor3=Color3.fromRGB(44,26,68); row.BackgroundTransparency=0.3
        row.BorderSizePixel=0; row.Size=UDim2.new(1,-20,0,rowH-4)
        row.Position=UDim2.new(0,10,0,_by); row.ZIndex=7
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
        local rowS=Instance.new("UIStroke",row)
        rowS.Color=bcat.cor; rowS.Thickness=1.2; rowS.Transparency=0.72
        rowS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

        -- Ícone
        local iconBox=Instance.new("Frame",row); iconBox.BackgroundColor3=bcat.cor
        iconBox.BackgroundTransparency=0.6; iconBox.BorderSizePixel=0
        iconBox.Position=UDim2.new(0,8,0.5,-16); iconBox.Size=UDim2.new(0,32,0,32); iconBox.ZIndex=8
        Instance.new("UICorner",iconBox).CornerRadius=UDim.new(0,8)
        local icon2=criarIconeBring(iconBox,bcat.key,bcat.cor)
        icon2.Position=UDim2.new(0,4,0,4); icon2.Size=UDim2.new(0,24,0,24)

        -- Nome
        local lNome=Instance.new("TextLabel",row); lNome.BackgroundTransparency=1
        lNome.Position=UDim2.new(0,48,0,8); lNome.Size=UDim2.new(1,-160,0,16)
        lNome.Font=Enum.Font.GothamBlack; lNome.Text=bcat.label
        lNome.TextColor3=Color3.fromRGB(255,255,255); lNome.TextSize=11
        lNome.TextXAlignment=Enum.TextXAlignment.Left; lNome.ZIndex=8
        if bcat.trLabel then TL(lNome,bcat.trLabel) end
        local lNomeS=Instance.new("UIStroke",lNome); lNomeS.Color=Color3.fromRGB(8,4,20); lNomeS.Thickness=1.4

        -- Feedback label
        local feedLbl=Instance.new("TextLabel",row); feedLbl.BackgroundTransparency=1
        feedLbl.Position=UDim2.new(1,-84,0,52); feedLbl.Size=UDim2.new(0,76,0,12)
        feedLbl.Font=Enum.Font.Gotham; feedLbl.Text=""; feedLbl.TextColor3=bcat.cor
        feedLbl.TextSize=8; feedLbl.TextXAlignment=Enum.TextXAlignment.Center; feedLbl.ZIndex=9

        -- Botão BRING
        local btnBring=Instance.new("TextButton",row); btnBring.BackgroundColor3=Color3.fromRGB(148,112,220)
        btnBring.BackgroundTransparency=0; btnBring.BorderSizePixel=0
        btnBring.Position=UDim2.new(1,-84,0,8); btnBring.Size=UDim2.new(0,76,0,26)
        btnBring.Font=Enum.Font.GothamBlack; btnBring.Text=T("bringBtnLabel")
        btnBring.TextColor3=Color3.fromRGB(16,8,30); btnBring.TextSize=10; btnBring.ZIndex=9
        Instance.new("UICorner",btnBring).CornerRadius=UDim.new(0,8)
        local btnStroke=Instance.new("UIStroke",btnBring)
        btnStroke.Color=Color3.fromRGB(8,4,20); btnStroke.Thickness=2; btnStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        local btnG=Instance.new("UIGradient",btnBring)
        btnG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,238,80)),ColorSequenceKeypoint.new(1,Color3.fromRGB(118,82,182))}); btnG.Rotation=90
        local btnShine=Instance.new("Frame",btnBring); btnShine.BackgroundColor3=Color3.fromRGB(255,255,255)
        btnShine.BackgroundTransparency=0.65; btnShine.BorderSizePixel=0
        btnShine.Position=UDim2.new(0,4,0,3); btnShine.Size=UDim2.new(0,36,0,6); btnShine.ZIndex=10
        Instance.new("UICorner",btnShine).CornerRadius=UDim.new(1,0)
        btnBring.MouseEnter:Connect(function() TweenService:Create(btnBring,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(255,220,50)}):Play() end)
        btnBring.MouseLeave:Connect(function() TweenService:Create(btnBring,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(148,112,220)}):Play() end)

        -- Botão LIMPAR
        local btnLimpar=Instance.new("TextButton",row); btnLimpar.BackgroundColor3=Color3.fromRGB(180,40,40)
        btnLimpar.BackgroundTransparency=0.15; btnLimpar.BorderSizePixel=0
        btnLimpar.Position=UDim2.new(1,-84,0,38); btnLimpar.Size=UDim2.new(0,76,0,20)
        btnLimpar.Font=Enum.Font.GothamBold; btnLimpar.Text="🗑 Limpar"
        btnLimpar.TextColor3=Color3.fromRGB(255,220,220); btnLimpar.TextSize=9; btnLimpar.ZIndex=9
        Instance.new("UICorner",btnLimpar).CornerRadius=UDim.new(0,7)
        Instance.new("UIStroke",btnLimpar).Color=Color3.fromRGB(8,4,20)
        btnLimpar.MouseEnter:Connect(function() TweenService:Create(btnLimpar,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(220,50,50),BackgroundTransparency=0}):Play() end)
        btnLimpar.MouseLeave:Connect(function() TweenService:Create(btnLimpar,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(180,40,40),BackgroundTransparency=0.15}):Play() end)

        -- Lock state
        local function applyLockState()
            local locked=(bringDestMode==nil)
            if locked then
                btnBring.BackgroundColor3=Color3.fromRGB(52,32,84); btnBring.TextColor3=Color3.fromRGB(120,90,30)
                btnBring.Text="🔒 Bloqueado"; btnG.Enabled=false
                TweenService:Create(btnStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(100,70,150),Transparency=0.5}):Play()
            else
                btnBring.BackgroundColor3=Color3.fromRGB(148,112,220); btnBring.TextColor3=Color3.fromRGB(16,8,30)
                btnBring.Text=T("bringBtnLabel"); btnG.Enabled=true
                TweenService:Create(btnStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(8,4,20),Transparency=0}):Play()
            end
        end
        applyLockState(); registerBringUnlockCb(applyLockState)

        local running=false
        btnBring.MouseButton1Click:Connect(function()
            if bringDestMode==nil then Notify.warn("Bring Bloqueado","🔒 Selecione um modo de destino!"); return end
            if running then return end; running=true
            btnBring.Text=T("bringBtnSearching"); TweenService:Create(btnBring,TweenInfo.new(0.08),{BackgroundTransparency=0.4}):Play()
            TweenService:Create(rowS,TweenInfo.new(0.15),{Color=bcat.cor,Transparency=0.3}):Play()
            task.spawn(function()
                local count=executarBring(bcat.key) or 0; task.wait(0.3)
                btnBring.Text=T("bringBtnLabel"); TweenService:Create(btnBring,TweenInfo.new(0.15),{BackgroundTransparency=0.15}):Play()
                if count>0 then
                    feedLbl.Text="✓ "..count..T("bringItemSuccess"); feedLbl.TextColor3=bcat.cor; feedLbl.TextTransparency=0
                    Notify.success(bcat.label,"✓ "..count..T("bringItemSuccess"),3.5)
                    task.delay(3,function() TweenService:Create(feedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); feedLbl.Text=""; feedLbl.TextTransparency=0 end)
                else
                    feedLbl.Text=T("bringItemFail"); feedLbl.TextColor3=Color3.fromRGB(200,80,80)
                    Notify.send({type="error",icon="⚠️",accent=Color3.fromRGB(255,75,75),title=bcat.label,msg=T("bringFail"),duration=3})
                    task.delay(2.5,function() TweenService:Create(feedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); feedLbl.Text=""; feedLbl.TextTransparency=0; feedLbl.TextColor3=bcat.cor end)
                end
                TweenService:Create(rowS,TweenInfo.new(0.2),{Transparency=0.72}):Play()
                task.wait(1); running=false
            end)
        end)

        btnLimpar.MouseButton1Click:Connect(function()
            local restored=limparBring(bcat.key)
            if restored>0 then
                feedLbl.Text="↩ "..restored.." restaurado(s)"; feedLbl.TextColor3=Color3.fromRGB(255,200,80)
                Notify.info(bcat.label,"↩ "..restored.." item(s) devolvido(s).",3)
                TweenService:Create(btnLimpar,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(87,180,100)}):Play()
                task.delay(0.8,function() TweenService:Create(btnLimpar,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(50,32,80)}):Play() end)
                task.delay(2.5,function() TweenService:Create(feedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); feedLbl.Text=""; feedLbl.TextTransparency=0 end)
            end
        end)

        if i < #validCats then
            local sep=Instance.new("Frame",_bgCF); sep.BackgroundColor3=grp.cor
            sep.BackgroundTransparency=0.85; sep.BorderSizePixel=0
            sep.Position=UDim2.new(0,20,0,_by+rowH-6); sep.Size=UDim2.new(1,-40,0,1); sep.ZIndex=7
        end
        end -- fecha scope do
        _by=_by+rowH
    end
    end -- validCats > 0
end -- for BRING_GROUPS

-- ══════════════════════════════════════════════════════
-- BRING ALL — Traz todos os itens de todas as categorias════════════════════════════════════════════════════════════
end -- do (Bring Configuração)


end); if not _dbgOk_6571 then warn('[PudimHub DEBUG] Erro na secao BRING: '..tostring(_dbgErr_6571)) end

-- ══════════════════════════════════════════════════════
--  PLAYER TAB
-- ══════════════════════════════════════════════════════
pcall(function() -- [[ PLAYER TAB PART 1 ]]
local playerSpeed   = 30
local playerJump    = 80
local speedEnabled  = true   -- toggle ON/OFF velocidade
local jumpEnabled   = true   -- toggle ON/OFF pulo
local flyEnabled    = false
local flySpeed      = 40
local flyUp         = false  -- botão ▲ mobile
local flyDown       = false  -- botão ▼ mobile
local flyBodyVel, flyBodyGyro, flyConn
local flyControlsGui = nil   -- overlay mobile fly
local noclipEnabled = false
local tpClickEnabled = false
local tpClickConn

local function applySpeed(v)
    pcall(function()
        local ch=Player.Character; if not ch then return end
        local hum=ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
        hum.WalkSpeed = speedEnabled and v or 16
    end)
end
local function applyJump(v)
    pcall(function()
        local ch=Player.Character; if not ch then return end
        local hum=ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
        hum.UseJumpPower = true; hum.JumpPower = jumpEnabled and v or 50
    end)
end
Player.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed(playerSpeed)
    applyJump(playerJump)
end)

-- ══════════════════════════════════════════════════════
-- FLY — Overlay mobile (botões ▲▼ na tela)
-- ══════════════════════════════════════════════════════
local function buildFlyOverlay()
    local sg = Instance.new("ScreenGui")
    sg.Name = "PudimFlyControls"; sg.ResetOnSpawn = false; sg.Enabled = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() sg.Parent = game:GetService("CoreGui") end)
    if not sg.Parent then sg.Parent = Player.PlayerGui end

    local FLY_COR = Color3.fromRGB(80,180,255)
    local frame = Instance.new("Frame", sg); frame.BackgroundTransparency = 1
    frame.AnchorPoint = Vector2.new(1,1); frame.Position = UDim2.new(1,-18,1,-110)
    frame.Size = UDim2.new(0,72,0,155)

    local function makeVBtn(label, yPos)
        local btn = Instance.new("TextButton", frame)
        btn.BackgroundColor3 = FLY_COR; btn.BackgroundTransparency = 0.25
        btn.BorderSizePixel = 0; btn.Position = UDim2.new(0,0,0,yPos)
        btn.Size = UDim2.new(1,0,0,68)
        btn.Font = Enum.Font.GothamBlack; btn.Text = label
        btn.TextColor3 = Color3.fromRGB(255,255,255); btn.TextSize = 13
        Instance.new("UICorner",btn).CornerRadius = UDim.new(0,14)
        local stroke = Instance.new("UIStroke",btn); stroke.Color=FLY_COR; stroke.Thickness=1.5; stroke.Transparency=0.5
        btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.25}):Play() end)
        return btn
    end

    local btnUp   = makeVBtn("▲\nUP",   0)
    local btnDown = makeVBtn("▼\nDOWN", 83)

    -- Suporte touch e mouse
    local function bindHold(btn, setVar)
        btn.MouseButton1Down:Connect(function() setVar(true)  end)
        btn.MouseButton1Up:Connect(function()   setVar(false) end)
        btn.MouseLeave:Connect(function()       setVar(false) end)
        btn.TouchLongPress:Connect(function()   setVar(true)  end)
        btn.TouchTap:Connect(function()         setVar(false) end)
    end
    bindHold(btnUp,   function(v) flyUp   = v end)
    bindHold(btnDown, function(v) flyDown = v end)

    return sg
end

local function setFly(state)
    flyEnabled = state
    if state then
        local ch=Player.Character; if not ch then return end
        local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if flyBodyVel  then pcall(function() flyBodyVel:Destroy()  end) end
        if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) end
        flyBodyVel  = Instance.new("BodyVelocity", hrp)
        flyBodyVel.MaxForce = Vector3.new(1e6,1e6,1e6); flyBodyVel.Velocity = Vector3.new(0,0,0)
        flyBodyGyro = Instance.new("BodyGyro", hrp)
        flyBodyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6); flyBodyGyro.CFrame = hrp.CFrame
        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.Heartbeat:Connect(function()
            if not flyEnabled then return end
            local c2=Player.Character; if not c2 then return end
            local h2=c2:FindFirstChild("HumanoidRootPart"); if not h2 then return end
            local hum2=c2:FindFirstChildWhichIsA("Humanoid")
            if not flyBodyVel or not flyBodyVel.Parent then return end
            local cam = workspace.CurrentCamera
            local UIS = UserInputService
            local dir = Vector3.new(0,0,0)

            -- Fly 3D: usa o movimento padrão do Roblox (WASD/joystick) mapeado
            -- para a direção COMPLETA da câmera (incluindo pitch vertical).
            -- Olhar para cima + W = voa para cima. Sem apertar teclas extras.
            if hum2 then
                local md = hum2.MoveDirection  -- vetor horizontal do input (world space, Y=0)
                if md.Magnitude > 0.05 then
                    local camCF      = cam.CFrame
                    local camLook    = camCF.LookVector          -- 3D (inclui pitch)
                    local camRight   = camCF.RightVector
                    -- Projeção horizontal da câmera para saber forward vs strafe
                    local flatLook   = Vector3.new(camLook.X, 0, camLook.Z)
                    local flatRight  = Vector3.new(camRight.X, 0, camRight.Z)
                    local dotFwd   = (flatLook.Magnitude  > 0.01) and md:Dot(flatLook.Unit)  or 0
                    local dotRight = (flatRight.Magnitude > 0.01) and md:Dot(flatRight.Unit) or 0
                    -- Forward usa look 3D (voa na direção que a câmera aponta)
                    -- Strafe usa right horizontal (não inclina ao andar de lado)
                    local flyDir = camLook * dotFwd + Vector3.new(camRight.X, 0, camRight.Z) * dotRight
                    if flyDir.Magnitude > 0.01 then
                        dir = dir + flyDir.Unit
                    end
                end
            end

            -- Vertical extra — botões overlay (mobile) ou Space/Ctrl (PC)
            if UIS:IsKeyDown(Enum.KeyCode.Space) or flyUp then
                dir = dir + Vector3.new(0,1,0)
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) or flyDown then
                dir = dir - Vector3.new(0,1,0)
            end

            flyBodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.new(0,0,0)
            flyBodyGyro.CFrame  = cam.CFrame
        end)
        -- Cria overlay mobile na primeira vez
        if not flyControlsGui then flyControlsGui = buildFlyOverlay() end
        flyControlsGui.Enabled = true
    else
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        pcall(function() if flyBodyVel  then flyBodyVel:Destroy();  flyBodyVel=nil  end end)
        pcall(function() if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro=nil end end)
        flyUp = false; flyDown = false
        if flyControlsGui then flyControlsGui.Enabled = false end
    end
end

local noclipConn2
local NOCLIP_VOID_Y = -100
local function setNoclip(state)
    noclipEnabled = state
    if state then
        if noclipConn2 then noclipConn2:Disconnect() end
        noclipConn2 = RunService.Stepped:Connect(function()
            local ch = Player.Character; if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if hrp then
                local py = hrp.Position.Y
                if py < NOCLIP_VOID_Y then hrp.CFrame = CFrame.new(hrp.Position.X, NOCLIP_VOID_Y+10, hrp.Position.Z); hrp.Velocity = Vector3.new(0,0,0) end
            end
            for _, part in ipairs(ch:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
            if hrp then hrp.CanCollide = false end
        end)
    else
        if noclipConn2 then noclipConn2:Disconnect(); noclipConn2=nil end
        pcall(function()
            local ch=Player.Character; if not ch then return end
            for _, part in ipairs(ch:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
        end)
    end
end

local function setTpClick(state)
    tpClickEnabled=state
    if state then
        if tpClickConn then tpClickConn:Disconnect() end
        tpClickConn=UserInputService.InputBegan:Connect(function(input,gpe)
            if not tpClickEnabled or gpe then return end
            if input.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            local ch=Player.Character; if not ch then return end
            local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local mp=UserInputService:GetMouseLocation()
            local ray=workspace:Raycast(Cam.CFrame.Position,Cam:ScreenPointToRay(mp.X,mp.Y).Direction*2000)
            if ray then
                local safeY=math.max(ray.Position.Y+3,-90)
                hrp.CFrame=CFrame.new(ray.Position.X,safeY,ray.Position.Z)
            end
        end)
    else
        if tpClickConn then tpClickConn:Disconnect(); tpClickConn=nil end
    end
end

-- UI PLAYER
plLO = 0  -- reseta e usa o upvalue compartilhado
plNextLO = function() plLO = plLO + 1; return plLO end

local function makePlSec(titleKey, cor)
    local hdr=Instance.new("Frame",Pages["Player"])
    hdr.BackgroundColor3=Color3.fromRGB(46,28,76); hdr.BorderSizePixel=0
    hdr.Size=UDim2.new(1,0,0,30); hdr.LayoutOrder=plNextLO(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,10)
    local hdrG=Instance.new("UIGradient",hdr)
    hdrG.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(
            math.floor(cor.R*255*0.16+18), math.floor(cor.G*255*0.11+10), math.floor(cor.B*255*0.11+4)
        )),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40,24,68))
    }); hdrG.Rotation=90
    local hdrS=Instance.new("UIStroke",hdr)
    hdrS.Color=cor; hdrS.Thickness=1.5; hdrS.Transparency=0.7
    hdrS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local pill=Instance.new("Frame",hdr); pill.BackgroundColor3=cor; pill.BorderSizePixel=0
    pill.Position=UDim2.new(0,8,0.5,-9); pill.Size=UDim2.new(0,4,0,18); pill.ZIndex=5
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local pillGlow=Instance.new("Frame",hdr); pillGlow.BackgroundColor3=cor
    pillGlow.BackgroundTransparency=0.75; pillGlow.BorderSizePixel=0
    pillGlow.Position=UDim2.new(0,6,0.5,-11); pillGlow.Size=UDim2.new(0,8,0,22); pillGlow.ZIndex=4
    Instance.new("UICorner",pillGlow).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,20,0,0); lbl.Size=UDim2.new(1,-28,1,0)
    lbl.Font=Enum.Font.GothamBlack; lbl.TextColor3=Color3.fromRGB(245,230,200)
    lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    local lblS=Instance.new("UIStroke",lbl); lblS.Color=Color3.fromRGB(0,0,0); lblS.Thickness=0.8; lblS.Transparency=0.5
    local divR=Instance.new("Frame",hdr); divR.BackgroundColor3=cor; divR.BackgroundTransparency=0.8
    divR.BorderSizePixel=0; divR.AnchorPoint=Vector2.new(1,0.5)
    divR.Position=UDim2.new(1,-8,0.5,0); divR.Size=UDim2.new(0,28,0,1); divR.ZIndex=5
    TL(lbl, titleKey)
end

local function makePlToggle(lbl_txt, desc_txt, cor, onToggle)
    local row=Instance.new("Frame",Pages["Player"]); row.BackgroundColor3=Color3.fromRGB(46,28,76)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,60); row.LayoutOrder=plNextLO(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,14)
    local rowG=Instance.new("UIGradient",row)
    rowG.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(28,16,6)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(14,8,2))
    }); rowG.Rotation=135
    local rowS=Instance.new("UIStroke",row); rowS.Color=cor; rowS.Thickness=1.5; rowS.Transparency=0.7
    rowS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    -- Accent bar
    local rBar=Instance.new("Frame",row); rBar.BackgroundColor3=cor; rBar.BorderSizePixel=0
    rBar.Position=UDim2.new(0,0,0.12,0); rBar.Size=UDim2.new(0,4,0.76,0); rBar.ZIndex=6
    Instance.new("UICorner",rBar).CornerRadius=UDim.new(0,4)
    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,10); tl.Size=UDim2.new(1,-80,0,18); tl.Font=Enum.Font.GothamBlack
    tl.Text=lbl_txt; tl.TextColor3=Color3.fromRGB(220,205,255); tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local tlS=Instance.new("UIStroke",tl); tlS.Color=Color3.fromRGB(0,0,0); tlS.Thickness=0.7; tlS.Transparency=0.4
    local td=Instance.new("TextLabel",row); td.BackgroundTransparency=1
    td.Position=UDim2.new(0,14,0,30); td.Size=UDim2.new(1,-80,0,22); td.Font=Enum.Font.Gotham
    td.Text=desc_txt; td.TextColor3=Color3.fromRGB(155,135,185); td.TextSize=9
    td.TextXAlignment=Enum.TextXAlignment.Left; td.TextWrapped=true; td.ZIndex=7
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(100,80,120)
    pill.BorderSizePixel=0; pill.AnchorPoint=Vector2.new(1,0.5); pill.Position=UDim2.new(1,-14,0.5,0)
    pill.Size=UDim2.new(0,44,0,24); pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BorderSizePixel=0
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.ZIndex=10; knob.Size=UDim2.new(0,18,0,18); knob.Position=UDim2.new(0,13,0.5,0)
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=11
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(rowS,TweenInfo.new(0.2),{Transparency=state and 0.3 or 0.7}):Play()
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=state and cor or Color3.fromRGB(100,80,120)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=state and UDim2.new(1,-13,0.5,0) or UDim2.new(0,13,0.5,0)
        }):Play()
        TweenService:Create(rowS,TweenInfo.new(0.2),{Color=state and cor or Color3.fromRGB(148,112,220),Transparency=state and 0.35 or 0.82}):Play()
        -- Som de ligar/desligar
        task.spawn(function()
            pcall(function()
                local sndId = state and 6031221736 or 2544086171
                local snd = Instance.new("Sound")
                snd.SoundId = "rbxassetid://"..tostring(sndId)
                snd.Volume = 0.45; snd.RollOffMaxDistance = 0
                snd.Parent = SoundService
                if not snd.IsLoaded then snd.Loaded:Wait() end
                snd:Play()
                game:GetService("Debris"):AddItem(snd, 3)
            end)
        end)
        -- Notificação automática: verde ao ativar, vermelha ao desativar
        if state then
            Notify.success(lbl_txt, "✓ Ativado")
        else
            Notify.send({type="error", icon="✕", accent=Color3.fromRGB(255,75,75), title=lbl_txt, msg="✗ Desativado"})
        end
        onToggle(state)
    end)
end

local function makeSliderBar(parentPage, lo_fn, lbl_txt, desc_txt, cor, minV, maxV, initVal, onChange)
    local row=Instance.new("Frame",parentPage)
    row.BackgroundColor3=Color3.fromRGB(72,50,108); row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,66); row.LayoutOrder=lo_fn(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)

    -- Label (esquerda, quebra linha)
    local lbl=Instance.new("TextLabel",row); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,14,0,0); lbl.Size=UDim2.new(0.50,0,1,0)
    lbl.Font=Enum.Font.GothamBold; lbl.Text=lbl_txt
    lbl.TextColor3=Color3.fromRGB(215,205,235); lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.TextYAlignment=Enum.TextYAlignment.Center
    lbl.TextWrapped=true; lbl.ZIndex=6

    -- Número do valor
    local valLbl=Instance.new("TextLabel",row); valLbl.BackgroundTransparency=1
    valLbl.Position=UDim2.new(0.52,0,0.5,-10); valLbl.Size=UDim2.new(0,28,0,20)
    valLbl.Font=Enum.Font.GothamBold; valLbl.Text=tostring(initVal)
    valLbl.TextColor3=Color3.fromRGB(215,205,235); valLbl.TextSize=12
    valLbl.TextXAlignment=Enum.TextXAlignment.Left; valLbl.ZIndex=7

    -- Track fino
    local trackBg=Instance.new("Frame",row)
    trackBg.BackgroundColor3=Color3.fromRGB(90,68,124); trackBg.BorderSizePixel=0
    trackBg.Position=UDim2.new(0.52,34,0.5,-2)
    trackBg.Size=UDim2.new(0.45,-50,0,4); trackBg.ZIndex=7
    Instance.new("UICorner",trackBg).CornerRadius=UDim.new(1,0)

    local pct0=math.clamp((initVal-minV)/(maxV-minV),0,1)

    -- Fill (cor da feature)
    local fill=Instance.new("Frame",trackBg); fill.BackgroundColor3=cor
    fill.BorderSizePixel=0; fill.Size=UDim2.new(pct0,0,1,0); fill.ZIndex=8
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    -- Knob círculo escuro sólido (● da foto)
    local knob=Instance.new("Frame",trackBg)
    knob.BackgroundColor3=Color3.fromRGB(50,32,80); knob.BorderSizePixel=0
    knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(pct0,0,0.5,0); knob.Size=UDim2.new(0,18,0,18); knob.ZIndex=9
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local dragging=false
    local function setVal(pct)
        pct=math.clamp(pct,0,1)
        local v=math.round(minV+(maxV-minV)*pct)
        valLbl.Text=tostring(v)
        fill.Size=UDim2.new(pct,0,1,0); knob.Position=UDim2.new(pct,0,0.5,0)
        onChange(v)
    end
    local sBtn=Instance.new("TextButton",trackBg); sBtn.BackgroundTransparency=1
    sBtn.Size=UDim2.new(1,24,1,24); sBtn.Position=UDim2.new(0,-12,0,-12)
    sBtn.Text=""; sBtn.ZIndex=10
    sBtn.MouseButton1Down:Connect(function()
        dragging=true
        local ap=trackBg.AbsolutePosition; local as=trackBg.AbsoluteSize
        setVal((UserInputService:GetMouseLocation().X-ap.X)/as.X)
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local ap=trackBg.AbsolutePosition; local as=trackBg.AbsoluteSize
        setVal((inp.Position.X-ap.X)/as.X)
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
end

-- ══════════════════════════════════════════════════════════════════
-- makePlKACard — estilo foto: row toggle + row slider separados
-- ══════════════════════════════════════════════════════════════════
local function makePlKACard(COR, titleTxt, descTxt, minV, maxV, defV, maxStr, getDescFn, initEnabled, onToggle, onSlider)
    local curVal=defV; local enabled=initEnabled

    -- ── ROW TOGGLE ─────────────────────────────────────────────
    local tRow=Instance.new("Frame",Pages["Player"])
    tRow.BackgroundColor3=Color3.fromRGB(72,50,108); tRow.BorderSizePixel=0
    tRow.Size=UDim2.new(1,0,0,62); tRow.LayoutOrder=plNextLO(); tRow.ZIndex=5
    Instance.new("UICorner",tRow).CornerRadius=UDim.new(0,12)

    local tLbl=Instance.new("TextLabel",tRow); tLbl.BackgroundTransparency=1
    tLbl.Position=UDim2.new(0,14,0,0); tLbl.Size=UDim2.new(0.68,0,1,0)
    tLbl.Font=Enum.Font.GothamBold; tLbl.Text=titleTxt
    tLbl.TextColor3=Color3.fromRGB(215,205,235); tLbl.TextSize=11
    tLbl.TextXAlignment=Enum.TextXAlignment.Left
    tLbl.TextYAlignment=Enum.TextYAlignment.Center
    tLbl.TextWrapped=true; tLbl.ZIndex=6

    -- Pill toggle (direita) — fundo cinza-roxo, bolinha branca com ✓
    local pill=Instance.new("Frame",tRow); pill.BorderSizePixel=0
    pill.AnchorPoint=Vector2.new(1,0.5)
    pill.Position=UDim2.new(1,-14,0.5,0); pill.Size=UDim2.new(0,52,0,30); pill.ZIndex=8
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    pill.BackgroundColor3=enabled and Color3.fromRGB(110,90,145) or Color3.fromRGB(100,80,120)
    local knob=Instance.new("Frame",pill); knob.BorderSizePixel=0
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.ZIndex=9; knob.Size=UDim2.new(0,20,0,20)
    knob.Position=enabled and UDim2.new(1,-15,0.5,0) or UDim2.new(0,15,0.5,0)
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local toggleBtn=Instance.new("TextButton",tRow); toggleBtn.BackgroundTransparency=1
    toggleBtn.Size=UDim2.new(1,0,1,0); toggleBtn.Text=""; toggleBtn.ZIndex=11
    toggleBtn.MouseButton1Click:Connect(function()
        enabled=not enabled
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=enabled and Color3.fromRGB(110,90,145) or Color3.fromRGB(100,80,120)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=enabled and UDim2.new(1,-15,0.5,0) or UDim2.new(0,15,0.5,0)
        }):Play()
        if onToggle then onToggle(enabled,curVal) end
    end)

    -- ── ROW SLIDER ─────────────────────────────────────────────
    local sRow=Instance.new("Frame",Pages["Player"])
    sRow.BackgroundColor3=Color3.fromRGB(72,50,108); sRow.BorderSizePixel=0
    sRow.Size=UDim2.new(1,0,0,66); sRow.LayoutOrder=plNextLO(); sRow.ZIndex=5
    Instance.new("UICorner",sRow).CornerRadius=UDim.new(0,12)

    local sLbl=Instance.new("TextLabel",sRow); sLbl.BackgroundTransparency=1
    sLbl.Position=UDim2.new(0,14,0,0); sLbl.Size=UDim2.new(0.50,0,1,0)
    sLbl.Font=Enum.Font.GothamBold; sLbl.Text=descTxt
    sLbl.TextColor3=Color3.fromRGB(215,205,235); sLbl.TextSize=11
    sLbl.TextXAlignment=Enum.TextXAlignment.Left
    sLbl.TextYAlignment=Enum.TextYAlignment.Center
    sLbl.TextWrapped=true; sLbl.ZIndex=6

    -- Número valor
    local valLbl=Instance.new("TextLabel",sRow); valLbl.BackgroundTransparency=1
    valLbl.Position=UDim2.new(0.52,0,0.5,-10); valLbl.Size=UDim2.new(0,28,0,20)
    valLbl.Font=Enum.Font.GothamBold; valLbl.Text=tostring(defV)
    valLbl.TextColor3=Color3.fromRGB(215,205,235); valLbl.TextSize=12
    valLbl.TextXAlignment=Enum.TextXAlignment.Left; valLbl.ZIndex=7

    -- Track fino
    local pct0=(defV-minV)/(maxV-minV)
    local trackBg=Instance.new("Frame",sRow)
    trackBg.BackgroundColor3=Color3.fromRGB(90,68,124); trackBg.BorderSizePixel=0
    trackBg.Position=UDim2.new(0.52,34,0.5,-2)
    trackBg.Size=UDim2.new(0.45,-50,0,4); trackBg.ZIndex=7
    Instance.new("UICorner",trackBg).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame",trackBg); fill.BackgroundColor3=COR
    fill.BorderSizePixel=0; fill.Size=UDim2.new(pct0,0,1,0); fill.ZIndex=8
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    -- Knob círculo escuro
    local skn=Instance.new("Frame",trackBg)
    skn.BackgroundColor3=Color3.fromRGB(50,32,80); skn.BorderSizePixel=0
    skn.AnchorPoint=Vector2.new(0.5,0.5)
    skn.Position=UDim2.new(pct0,0,0.5,0); skn.Size=UDim2.new(0,18,0,18); skn.ZIndex=9
    Instance.new("UICorner",skn).CornerRadius=UDim.new(1,0)

    local dragging=false
    local function setVal(pct)
        pct=math.clamp(pct,0,1)
        curVal=math.round(minV+(maxV-minV)*pct)
        valLbl.Text=tostring(curVal)
        fill.Size=UDim2.new(pct,0,1,0); skn.Position=UDim2.new(pct,0,0.5,0)
        if onSlider then onSlider(curVal) end
    end
    local sb=Instance.new("TextButton",trackBg); sb.BackgroundTransparency=1
    sb.Size=UDim2.new(1,24,1,24); sb.Position=UDim2.new(0,-12,0,-12); sb.Text=""; sb.ZIndex=10
    sb.MouseButton1Down:Connect(function()
        dragging=true
        local ap=trackBg.AbsolutePosition; local as=trackBg.AbsoluteSize
        setVal((UserInputService:GetMouseLocation().X-ap.X)/as.X)
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local ap=trackBg.AbsolutePosition; local as=trackBg.AbsoluteSize
        setVal((inp.Position.X-ap.X)/as.X)
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    return tRow
end

-- ══════════════════════════════════════════════════════════════════
-- ABSD — Seletor de funções com popup (azul marinho + popup vermelho)
-- ══════════════════════════════════════════════════════════════════
do
local ABSD_OPTS = {
    { key="A",  label="A",  desc="Função A" },
    { key="S",  label="S",  desc="Função S" },
    { key="D",  label="D",  desc="Função D" },
    { key="TT", label="TT", desc="Função TT" },
}
local absdSel = {}         -- set de selecionados
local absdPopupOpen = false
local absdRef = {}

-- ── Seção header ─────────────────────────────────────────────────
local absdSec=Instance.new("Frame",Pages["Player"])
absdSec.BackgroundColor3=Color3.fromRGB(18,30,60); absdSec.BackgroundTransparency=0.35
absdSec.BorderSizePixel=0; absdSec.Size=UDim2.new(1,0,0,28); absdSec.LayoutOrder=plNextLO(); absdSec.ZIndex=4
Instance.new("UICorner",absdSec).CornerRadius=UDim.new(0,9)
local absdSecS=Instance.new("UIStroke",absdSec)
absdSecS.Color=Color3.fromRGB(60,90,160); absdSecS.Thickness=1; absdSecS.Transparency=0.5
absdSecS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local absdPill=Instance.new("Frame",absdSec); absdPill.BackgroundColor3=Color3.fromRGB(80,120,220)
absdPill.BorderSizePixel=0; absdPill.Position=UDim2.new(0,8,0.5,-8); absdPill.Size=UDim2.new(0,4,0,16); absdPill.ZIndex=5
Instance.new("UICorner",absdPill).CornerRadius=UDim.new(1,0)
local absdSecLbl=Instance.new("TextLabel",absdSec); absdSecLbl.BackgroundTransparency=1
absdSecLbl.Position=UDim2.new(0,18,0,0); absdSecLbl.Size=UDim2.new(1,-26,1,0)
absdSecLbl.Font=Enum.Font.GothamBlack; absdSecLbl.Text="⚙️  ABSD"
absdSecLbl.TextColor3=Color3.fromRGB(180,210,255); absdSecLbl.TextSize=11
absdSecLbl.TextXAlignment=Enum.TextXAlignment.Left; absdSecLbl.ZIndex=5

-- ── Card fino ────────────────────────────────────────────────────
local absdCard=Instance.new("Frame",Pages["Player"])
absdCard.BackgroundColor3=Color3.fromRGB(12,24,56); absdCard.BackgroundTransparency=0.30
absdCard.BorderSizePixel=0; absdCard.Size=UDim2.new(1,0,0,168); absdCard.LayoutOrder=plNextLO(); absdCard.ZIndex=5
Instance.new("UICorner",absdCard).CornerRadius=UDim.new(0,12)
local absdCardS=Instance.new("UIStroke",absdCard)
absdCardS.Color=Color3.fromRGB(50,80,160); absdCardS.Thickness=1; absdCardS.Transparency=0.5
absdCardS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

-- ── Linha 1: ABSD + dropdown (Y=0 a 52) ──────────────────────
local absdTit=Instance.new("TextLabel",absdCard); absdTit.BackgroundTransparency=1
absdTit.Position=UDim2.new(0,14,0,0); absdTit.Size=UDim2.new(0.5,0,0,52)
absdTit.Font=Enum.Font.GothamBlack; absdTit.Text="ABSD"
absdTit.TextColor3=Color3.fromRGB(180,210,255); absdTit.TextSize=13
absdTit.TextXAlignment=Enum.TextXAlignment.Left; absdTit.TextYAlignment=Enum.TextYAlignment.Center; absdTit.ZIndex=6

-- Botão dropdown direita
local absdBtn=Instance.new("TextButton",absdCard)
absdBtn.BackgroundColor3=Color3.fromRGB(255,255,255); absdBtn.BackgroundTransparency=0.88
absdBtn.BorderSizePixel=0; absdBtn.AutoButtonColor=false
absdBtn.AnchorPoint=Vector2.new(1,0)
absdBtn.Position=UDim2.new(1,-10,0,10); absdBtn.Size=UDim2.new(0,120,0,32); absdBtn.ZIndex=8
Instance.new("UICorner",absdBtn).CornerRadius=UDim.new(0,10)
local absdBtnS=Instance.new("UIStroke",absdBtn)
absdBtnS.Color=Color3.fromRGB(120,160,255); absdBtnS.Thickness=1.2; absdBtnS.Transparency=0.5
absdBtnS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local absdBtnLbl=Instance.new("TextLabel",absdBtn); absdBtnLbl.BackgroundTransparency=1
absdBtnLbl.Size=UDim2.new(1,-8,1,0); absdBtnLbl.Position=UDim2.new(0,4,0,0)
absdBtnLbl.Font=Enum.Font.GothamBold; absdBtnLbl.Text="Selecionar ⌄"
absdBtnLbl.TextColor3=Color3.fromRGB(180,210,255); absdBtnLbl.TextSize=10; absdBtnLbl.ZIndex=9
absdBtnLbl.TextXAlignment=Enum.TextXAlignment.Center; absdBtnLbl.TextWrapped=true
absdRef.btn=absdBtn; absdRef.btnLbl=absdBtnLbl; absdRef.btnS=absdBtnS

-- ── Divisória ────────────────────────────────────────────────
local absdDiv1=Instance.new("Frame",absdCard); absdDiv1.BackgroundColor3=Color3.fromRGB(50,80,160)
absdDiv1.BackgroundTransparency=0.6; absdDiv1.BorderSizePixel=0
absdDiv1.Position=UDim2.new(0,12,0,56); absdDiv1.Size=UDim2.new(1,-24,0,1); absdDiv1.ZIndex=6

-- ── Linha 2: ATTSYUPO + toggle (Y=58 a 110) ─────────────────
local attsLbl=Instance.new("TextLabel",absdCard); attsLbl.BackgroundTransparency=1
attsLbl.Position=UDim2.new(0,14,0,60); attsLbl.Size=UDim2.new(0.55,0,0,46)
attsLbl.Font=Enum.Font.GothamBlack; attsLbl.Text="ATTSYUPO"
attsLbl.TextColor3=Color3.fromRGB(180,210,255); attsLbl.TextSize=11
attsLbl.TextXAlignment=Enum.TextXAlignment.Left; attsLbl.TextYAlignment=Enum.TextYAlignment.Center
attsLbl.TextWrapped=true; attsLbl.ZIndex=6

-- Toggle pill (direita)
local attsOn = false
local attsPill=Instance.new("Frame",absdCard); attsPill.BorderSizePixel=0
attsPill.AnchorPoint=Vector2.new(1,0)
attsPill.Position=UDim2.new(1,-12,0,70); attsPill.Size=UDim2.new(0,54,0,28); attsPill.ZIndex=8
Instance.new("UICorner",attsPill).CornerRadius=UDim.new(1,0)
attsPill.BackgroundColor3=Color3.fromRGB(80,90,110)  -- OFF: cinza

local attsKnob=Instance.new("Frame",attsPill); attsKnob.BorderSizePixel=0
attsKnob.Size=UDim2.new(0,22,0,22); attsKnob.ZIndex=10
Instance.new("UICorner",attsKnob).CornerRadius=UDim.new(1,0)
attsKnob.BackgroundColor3=Color3.fromRGB(255,255,255)
attsKnob.Position=UDim2.new(0,3,0.5,-11)  -- OFF: esquerda

-- Símbolo dentro da bolinha (X ou ✓)
local attsIcon=Instance.new("TextLabel",attsKnob); attsIcon.BackgroundTransparency=1
attsIcon.Size=UDim2.new(1,0,1,0); attsIcon.Font=Enum.Font.GothamBlack
attsIcon.Text="✕"; attsIcon.TextColor3=Color3.fromRGB(80,90,110)
attsIcon.TextSize=11; attsIcon.ZIndex=11

-- Botão invisível para clicar
local attsToggleBtn=Instance.new("TextButton",absdCard); attsToggleBtn.BackgroundTransparency=1
attsToggleBtn.Position=UDim2.new(0,0,0,58); attsToggleBtn.Size=UDim2.new(1,0,0,50)
attsToggleBtn.Text=""; attsToggleBtn.ZIndex=12
attsToggleBtn.MouseButton1Click:Connect(function()
    attsOn = not attsOn
    TweenService:Create(attsPill,TweenInfo.new(0.2),{
        BackgroundColor3=attsOn and Color3.fromRGB(50,120,255) or Color3.fromRGB(80,90,110)
    }):Play()
    TweenService:Create(attsKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        
    }):Play()
    attsIcon.Text = attsOn and "✓" or "✕"
    attsIcon.TextColor3 = attsOn and Color3.fromRGB(50,120,255) or Color3.fromRGB(80,90,110)
end)

-- ── Divisória ────────────────────────────────────────────────
local absdDiv2=Instance.new("Frame",absdCard); absdDiv2.BackgroundColor3=Color3.fromRGB(50,80,160)
absdDiv2.BackgroundTransparency=0.6; absdDiv2.BorderSizePixel=0
absdDiv2.Position=UDim2.new(0,12,0,112); absdDiv2.Size=UDim2.new(1,-24,0,1); absdDiv2.ZIndex=6

-- ── Linha 3: HPSUAO + slider (Y=114 a 168) ──────────────────
local hpsLbl=Instance.new("TextLabel",absdCard); hpsLbl.BackgroundTransparency=1
hpsLbl.Position=UDim2.new(0,14,0,116); hpsLbl.Size=UDim2.new(0.42,0,0,46)
hpsLbl.Font=Enum.Font.GothamBlack; hpsLbl.Text="HPSUAO"
hpsLbl.TextColor3=Color3.fromRGB(180,210,255); hpsLbl.TextSize=11
hpsLbl.TextXAlignment=Enum.TextXAlignment.Left; hpsLbl.TextYAlignment=Enum.TextYAlignment.Center
hpsLbl.TextWrapped=true; hpsLbl.ZIndex=6

-- Track do slider
local hpsMin,hpsMax,hpsCur = 10,500,10
local hpsPct0 = (hpsCur-hpsMin)/(hpsMax-hpsMin)
local hpsTrack=Instance.new("Frame",absdCard)
hpsTrack.BackgroundColor3=Color3.fromRGB(30,50,100); hpsTrack.BorderSizePixel=0
hpsTrack.Position=UDim2.new(0.44,0,0,134); hpsTrack.Size=UDim2.new(0.5,0,0,4); hpsTrack.ZIndex=7
Instance.new("UICorner",hpsTrack).CornerRadius=UDim.new(1,0)

-- Fill azul
local hpsFill=Instance.new("Frame",hpsTrack); hpsFill.BackgroundColor3=Color3.fromRGB(50,120,255)
hpsFill.BorderSizePixel=0; hpsFill.Size=UDim2.new(hpsPct0,0,1,0); hpsFill.ZIndex=8
Instance.new("UICorner",hpsFill).CornerRadius=UDim.new(1,0)

-- Knob branco grande com valor dentro
local hpsKnob=Instance.new("Frame",hpsTrack)
hpsKnob.BackgroundColor3=Color3.fromRGB(255,255,255); hpsKnob.BorderSizePixel=0
hpsKnob.AnchorPoint=Vector2.new(0.5,0.5)
hpsKnob.Position=UDim2.new(hpsPct0,0,0.5,0); hpsKnob.Size=UDim2.new(0,32,0,32); hpsKnob.ZIndex=9
Instance.new("UICorner",hpsKnob).CornerRadius=UDim.new(1,0)
local hpsKnobS=Instance.new("UIStroke",hpsKnob)
hpsKnobS.Color=Color3.fromRGB(50,120,255); hpsKnobS.Thickness=2
hpsKnobS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

-- Valor dentro da bolinha branca
local hpsValLbl=Instance.new("TextLabel",hpsKnob); hpsValLbl.BackgroundTransparency=1
hpsValLbl.Size=UDim2.new(1,0,1,0); hpsValLbl.Font=Enum.Font.GothamBlack
hpsValLbl.Text=tostring(hpsCur); hpsValLbl.TextColor3=Color3.fromRGB(30,60,140)
hpsValLbl.TextSize=8; hpsValLbl.ZIndex=10

-- Drag slider
local hpsDragging=false
local function hpsSetVal(pct)
    pct=math.clamp(pct,0,1)
    hpsCur=math.round(hpsMin+(hpsMax-hpsMin)*pct)
    hpsFill.Size=UDim2.new(pct,0,1,0); hpsKnob.Position=UDim2.new(pct,0,0.5,0)
    hpsValLbl.Text=tostring(hpsCur)
end
local hpsBtn=Instance.new("TextButton",hpsTrack); hpsBtn.BackgroundTransparency=1
hpsBtn.Size=UDim2.new(1,40,1,40); hpsBtn.Position=UDim2.new(0,-20,0,-20); hpsBtn.Text=""; hpsBtn.ZIndex=11
hpsBtn.MouseButton1Down:Connect(function()
    hpsDragging=true
    local ap=hpsTrack.AbsolutePosition; local as=hpsTrack.AbsoluteSize
    hpsSetVal((UserInputService:GetMouseLocation().X-ap.X)/as.X)
end)
UserInputService.InputChanged:Connect(function(inp)
    if not hpsDragging then return end
    if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
    local ap=hpsTrack.AbsolutePosition; local as=hpsTrack.AbsoluteSize
    hpsSetVal((inp.Position.X-ap.X)/as.X)
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then hpsDragging=false end
end)

-- Função para atualizar texto do botão
local function absdUpdateBtnLabel()
    local sel={}
    for _,opt in ipairs(ABSD_OPTS) do
        if absdSel[opt.key] then table.insert(sel,opt.label) end
    end
    if #sel==0 then
        absdBtnLbl.Text="Selecionar ⌄"
    else
        absdBtnLbl.Text=table.concat(sel,", ").." ⌄"
    end
end

-- ── Popup vermelho fraco ──────────────────────────────────────
local absdPopup=Instance.new("Frame",ScreenGui)
absdPopup.Name="AbsdPopup"; absdPopup.BackgroundColor3=Color3.fromRGB(80,18,24)
absdPopup.BackgroundTransparency=0.08; absdPopup.BorderSizePixel=0
absdPopup.Size=UDim2.new(0,160,0,0); absdPopup.Visible=false; absdPopup.ZIndex=450
absdPopup.ClipsDescendants=true
Instance.new("UICorner",absdPopup).CornerRadius=UDim.new(0,12)
local absdPopS=Instance.new("UIStroke",absdPopup)
absdPopS.Color=Color3.fromRGB(200,60,70); absdPopS.Thickness=1.2; absdPopS.Transparency=0.5
absdPopS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

-- Padding interno
local absdPadding=Instance.new("UIPadding",absdPopup)
absdPadding.PaddingTop=UDim.new(0,8); absdPadding.PaddingBottom=UDim.new(0,8)
absdPadding.PaddingLeft=UDim.new(0,8); absdPadding.PaddingRight=UDim.new(0,8)

-- Layout dos itens
local absdLayout=Instance.new("UIListLayout",absdPopup)
absdLayout.SortOrder=Enum.SortOrder.LayoutOrder; absdLayout.Padding=UDim.new(0,6)

-- Itens do popup
local absdItemBtns={}
local ABSD_POP_ITEM_H=36
local ABSD_POP_TOTAL=8 + ABSD_POP_ITEM_H*#ABSD_OPTS + 6*(#ABSD_OPTS-1) + 8

for i, opt in ipairs(ABSD_OPTS) do
    local item=Instance.new("TextButton",absdPopup)
    item.BackgroundTransparency=1; item.BorderSizePixel=0
    item.Size=UDim2.new(1,0,0,ABSD_POP_ITEM_H); item.LayoutOrder=i
    item.Font=Enum.Font.GothamBold; item.Text=opt.label
    item.TextColor3=Color3.fromRGB(255,220,220); item.TextSize=12; item.AutoButtonColor=false; item.ZIndex=452
    instance_new_UICorner = Instance.new("UICorner",item)
    instance_new_UICorner.CornerRadius=UDim.new(0,8)
    -- Stroke da borda (branco transparente quando selecionado)
    local iS=Instance.new("UIStroke",item)
    iS.Color=Color3.fromRGB(255,255,255); iS.Thickness=1.5; iS.Transparency=1
    iS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

    local function updateItem()
        local on=absdSel[opt.key]
        item.BackgroundTransparency = on and 0.85 or 1
        item.BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(80,18,24)
        TweenService:Create(iS,TweenInfo.new(0.15),{Transparency=on and 0 or 1}):Play()
        item.TextColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(255,200,200)
    end
    absdItemBtns[opt.key]=updateItem

    item.MouseButton1Click:Connect(function()
        absdSel[opt.key] = not absdSel[opt.key]
        updateItem()
        absdUpdateBtnLabel()
    end)
    item.MouseEnter:Connect(function()
        if not absdSel[opt.key] then
            TweenService:Create(item,TweenInfo.new(0.1),{BackgroundTransparency=0.92}):Play()
            item.BackgroundColor3=Color3.fromRGB(200,80,90)
        end
    end)
    item.MouseLeave:Connect(function()
        if not absdSel[opt.key] then
            TweenService:Create(item,TweenInfo.new(0.1),{BackgroundTransparency=1}):Play()
        end
    end)
end

-- Open / Close do popup
local function absdClosePopup()
    if not absdPopupOpen then return end
    absdPopupOpen=false
    TweenService:Create(absdPopup,TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
        Size=UDim2.new(0,160,0,0), BackgroundTransparency=1
    }):Play()
    task.delay(0.18,function() absdPopup.Visible=false; absdPopup.BackgroundTransparency=0.08 end)
    TweenService:Create(absdBtnS,TweenInfo.new(0.15),{Transparency=0.5}):Play()
    absdBtnLbl.Text=absdBtnLbl.Text:gsub("⌃","⌄")
end

local function absdOpenPopup()
    if absdPopupOpen then absdClosePopup(); return end
    absdPopupOpen=true
    local ap=absdBtn.AbsolutePosition; local ms=MainFrame.AbsolutePosition
    local rx=ap.X-ms.X+(absdBtn.AbsoluteSize.X-160)/2
    local ry=ap.Y-ms.Y+absdBtn.AbsoluteSize.Y+6
    -- Se não couber abaixo, abre acima
    if ry+ABSD_POP_TOTAL > MainFrame.AbsoluteSize.Y-20 then
        ry=ap.Y-ms.Y-ABSD_POP_TOTAL-4
    end
    absdPopup.Position=UDim2.new(0,rx,0,ry)
    absdPopup.Size=UDim2.new(0,160,0,0)
    absdPopup.BackgroundTransparency=1; absdPopup.Visible=true
    TweenService:Create(absdPopup,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Size=UDim2.new(0,160,0,ABSD_POP_TOTAL), BackgroundTransparency=0.08
    }):Play()
    TweenService:Create(absdBtnS,TweenInfo.new(0.15),{Transparency=0}):Play()
    absdBtnLbl.Text=absdBtnLbl.Text:gsub("⌄","⌃")
end

absdBtn.MouseButton1Click:Connect(absdOpenPopup)

-- Fechar ao clicar fora
UserInputService.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 and absdPopupOpen then
        local mx,my=inp.Position.X,inp.Position.Y
        local pa=absdPopup.AbsolutePosition; local ps=absdPopup.AbsoluteSize
        if mx<pa.X or mx>pa.X+ps.X or my<pa.Y or my>pa.Y+ps.Y then
            absdClosePopup()
        end
    end
end)
end -- ABSD

-- ── Speed
-- ── Speed ─────────────────────────────────────────────

-- ═══════════════════════════════════════════════════════════════════
-- HELPER: Cards agrupados azul marinho transparente (estilo ABSD)
-- ═══════════════════════════════════════════════════════════════════
local _NB = Color3.fromRGB(10,20,52)     -- navy bg
local _NS = Color3.fromRGB(45,75,155)    -- navy stroke
local _NT = Color3.fromRGB(200,215,245)  -- navy text
local _ND = Color3.fromRGB(45,75,155)    -- navy divider
local _ON = Color3.fromRGB(50,120,255)   -- toggle on azul
local _OF = Color3.fromRGB(65,72,90)     -- toggle off cinza

-- Cria card shell azul marinho, retorna o frame
local function _nc(loFn)
    local c=Instance.new("Frame",Pages["Player"])
    c.BackgroundColor3=_NB; c.BackgroundTransparency=0.28
    c.BorderSizePixel=0; c.LayoutOrder=loFn(); c.ZIndex=5
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,12)
    local s=Instance.new("UIStroke",c)
    s.Color=_NS; s.Thickness=1; s.Transparency=0.50
    s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    return c
end

-- Divisória dentro do card
local function _nd(c,y)
    local d=Instance.new("Frame",c); d.BackgroundColor3=_ND
    d.BackgroundTransparency=0.58; d.BorderSizePixel=0
    d.Position=UDim2.new(0,12,0,y); d.Size=UDim2.new(1,-24,0,1); d.ZIndex=6
    return 1
end

-- Row de toggle (44px) dentro do card
-- Retorna 44
local function _nt(c,y,lbl,initOn,onToggle)
    local H=44
    local tl=Instance.new("TextLabel",c); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,y); tl.Size=UDim2.new(0.65,0,0,H)
    tl.Font=Enum.Font.GothamBold; tl.Text=lbl
    tl.TextColor3=_NT; tl.TextSize=11
    tl.TextXAlignment=Enum.TextXAlignment.Left
    tl.TextYAlignment=Enum.TextYAlignment.Center
    tl.TextWrapped=true; tl.ZIndex=6
    local pill=Instance.new("Frame",c); pill.BorderSizePixel=0
    pill.AnchorPoint=Vector2.new(1,0.5)
    pill.Position=UDim2.new(1,-12,0,y+H/2)
    pill.Size=UDim2.new(0,44,0,22); pill.ZIndex=8
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    pill.BackgroundColor3=initOn and _ON or Color3.fromRGB(100,80,120)
    local knob=Instance.new("Frame",pill); knob.BorderSizePixel=0
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.ZIndex=10; knob.Size=UDim2.new(0,16,0,16)
    knob.Position=initOn and UDim2.new(1,-11,0.5,0) or UDim2.new(0,11,0.5,0)
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local en=initOn
    local btn=Instance.new("TextButton",c); btn.BackgroundTransparency=1
    btn.Position=UDim2.new(0,0,0,y); btn.Size=UDim2.new(1,0,0,H)
    btn.Text=""; btn.ZIndex=11
    btn.MouseButton1Click:Connect(function()
        en=not en
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=en and _ON or Color3.fromRGB(100,80,120)}):Play()
    TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position=en and UDim2.new(1,-11,0.5,0) or UDim2.new(0,11,0.5,0)
    }):Play()
        if onToggle then onToggle(en) end
    end)
    return H
end

-- Row de slider (50px) dentro do card — track fino + knob escuro
-- Retorna 50
local function _ns(c,y,lbl,minV,maxV,defV,cor,onChange)
    local H=50
    local tl=Instance.new("TextLabel",c); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,y); tl.Size=UDim2.new(0.44,0,0,H)
    tl.Font=Enum.Font.GothamBold; tl.Text=lbl
    tl.TextColor3=_NT; tl.TextSize=10
    tl.TextXAlignment=Enum.TextXAlignment.Left
    tl.TextYAlignment=Enum.TextYAlignment.Center
    tl.TextWrapped=true; tl.ZIndex=6
    local vl=Instance.new("TextLabel",c); vl.BackgroundTransparency=1
    vl.Position=UDim2.new(0.46,0,0,y+(H-16)/2); vl.Size=UDim2.new(0,28,0,16)
    vl.Font=Enum.Font.GothamBold; vl.Text=tostring(defV)
    vl.TextColor3=_NT; vl.TextSize=11
    vl.TextXAlignment=Enum.TextXAlignment.Left; vl.ZIndex=7
    local p0=math.clamp((defV-minV)/(maxV-minV),0,1)
    local tr=Instance.new("Frame",c); tr.BackgroundColor3=Color3.fromRGB(20,36,80)
    tr.BorderSizePixel=0
    tr.Position=UDim2.new(0.46,32,0,y+H/2-2)
    tr.Size=UDim2.new(0.51,-46,0,4); tr.ZIndex=7
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
    local fi=Instance.new("Frame",tr); fi.BackgroundColor3=cor
    fi.BorderSizePixel=0; fi.Size=UDim2.new(p0,0,1,0); fi.ZIndex=8
    Instance.new("UICorner",fi).CornerRadius=UDim.new(1,0)
    local kn=Instance.new("Frame",tr); kn.BackgroundColor3=Color3.fromRGB(25,48,105)
    kn.BorderSizePixel=0; kn.AnchorPoint=Vector2.new(0.5,0.5)
    kn.Position=UDim2.new(p0,0,0.5,0); kn.Size=UDim2.new(0,16,0,16); kn.ZIndex=9
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local ks=Instance.new("UIStroke",kn); ks.Color=cor; ks.Thickness=1.5
    ks.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local dr=false
    local function sv(pct)
        pct=math.clamp(pct,0,1)
        local v=math.round(minV+(maxV-minV)*pct)
        vl.Text=tostring(v); fi.Size=UDim2.new(pct,0,1,0); kn.Position=UDim2.new(pct,0,0.5,0)
        if onChange then onChange(v) end
    end
    local sb=Instance.new("TextButton",tr); sb.BackgroundTransparency=1
    sb.Size=UDim2.new(1,24,1,24); sb.Position=UDim2.new(0,-12,0,-12); sb.Text=""; sb.ZIndex=10
    sb.MouseButton1Down:Connect(function()
        dr=true
        local ap=tr.AbsolutePosition; local as=tr.AbsoluteSize
        sv((UserInputService:GetMouseLocation().X-ap.X)/as.X)
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dr then return end
        if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local ap=tr.AbsolutePosition; local as=tr.AbsoluteSize
        sv((inp.Position.X-ap.X)/as.X)
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end
    end)
    return H
end

-- ── Velocidade & Pulo — Accordion ───────────────────────────
do
local _sc,_scCF=makeAccordionCard(Pages["Player"],plNextLO,{icon="⚡",title=T("plSpeedTitle"),summary="Controla a velocidade de caminhada e a força do pulo.",color=Color3.fromRGB(170,140,235),contentH=36+9+44+50+9+44+50+14})
local _sy=36+8; _accDivLine(_scCF,_sy,Color3.fromRGB(170,140,235)); _sy=_sy+9
_sy=_sy+_accToggle(_scCF,_sy,"⚡ "..T("plSpeedTitle"),true,Color3.fromRGB(255,180,30),function(en) speedEnabled=en; applySpeed(en and playerSpeed or 16); Notify.info("⚡ Velocidade",en and ("Ativado — "..playerSpeed.." speed") or "Desativado") end)
_sy=_sy+_ns(_scCF,_sy,T("plSpeedDesc"),16,275,30,Color3.fromRGB(255,180,30),function(v) playerSpeed=v; if speedEnabled then applySpeed(v) end end)
_accDivLine(_scCF,_sy,Color3.fromRGB(100,220,255)); _sy=_sy+9
_sy=_sy+_accToggle(_scCF,_sy,"🦘 "..T("plJumpTitle"),true,Color3.fromRGB(100,220,255),function(en) jumpEnabled=en; applyJump(en and playerJump or 50); Notify.info("🦘 Pulo",en and ("Ativado — "..playerJump.." power") or "Desativado") end)
_sy=_sy+_ns(_scCF,_sy,T("plJumpDesc"),50,1285,80,Color3.fromRGB(100,220,255),function(v) playerJump=v; if jumpEnabled then applyJump(v) end end)
end

-- ── Fly ───────────────────────────────────────────────
-- ── Voo & Noclip — Accordion ─────────────────────────────────
do
local _fc,_fcCF=makeAccordionCard(Pages["Player"],plNextLO,{icon="✈️",title=T("plFlyToggle"),summary="Ativa voo e noclip. Ajuste a velocidade do voo.",color=Color3.fromRGB(100,200,255),contentH=36+9+44+50+9+44+14})
local _fy=36+8; _accDivLine(_fcCF,_fy,Color3.fromRGB(100,200,255)); _fy=_fy+9
_fy=_fy+_accToggle(_fcCF,_fy,"✈️ "..T("plFlyToggle"),false,Color3.fromRGB(100,200,255),function(en) setFly(en) end)
_fy=_fy+_ns(_fcCF,_fy,T("plFlySpeedTitle"),16,345,40,Color3.fromRGB(120,200,255),function(v) flySpeed=v end)
_accDivLine(_fcCF,_fy,Color3.fromRGB(140,180,255)); _fy=_fy+9
_accToggle(_fcCF,_fy,"🫥 "..T("plNoclipToggle"),false,Color3.fromRGB(140,180,255),function(en) setNoclip(en) end)
end

-- declarações antecipadas: os do-blocks abaixo são locais;
-- as closures _nt precisam capturá-las antes da definição
local setNoFov, setInfJump

-- ── Utilitários — Accordion ──────────────────────────────────
do
local _uc,_ucCF=makeAccordionCard(Pages["Player"],plNextLO,{icon="🛠️",title="Utilitários",summary="Teleporte por clique, visão melhorada e pulo infinito.",color=Color3.fromRGB(255,210,80),contentH=36+9+44+9+44+9+44+14})
local _uy=36+8; _accDivLine(_ucCF,_uy,Color3.fromRGB(255,210,80)); _uy=_uy+9
_uy=_uy+_accToggle(_ucCF,_uy,"🖱️ "..T("plTpClickToggle"),false,Color3.fromRGB(255,210,80),function(en) setTpClick(en) end)
_accDivLine(_ucCF,_uy,Color3.fromRGB(255,210,80)); _uy=_uy+9
_uy=_uy+_accToggle(_ucCF,_uy,"👁 Visão Melhorada (NoFov)",false,Color3.fromRGB(200,220,255),function(en) if setNoFov then setNoFov(en) end end)
_accDivLine(_ucCF,_uy,Color3.fromRGB(255,210,80)); _uy=_uy+9
_accToggle(_ucCF,_uy,"♾️ Pulo Infinito",false,Color3.fromRGB(180,255,180),function(en) if setInfJump then setInfJump(en) end end)
end

-- ══════════════════════════════════════════════════════
-- CÂMERA ALTA — zoom infinito
-- ══════════════════════════════════════════════════════
local camAltaEnabled = false
local camAltaConn
local function setCamAlta(state)
    camAltaEnabled = state
    if state then
        -- Zoom máximo ilimitado
        pcall(function()
            local cam = workspace.CurrentCamera
            cam.FieldOfView = 70
            local ps = Players.LocalPlayer
            if ps then
                pcall(function() ps.CameraMaxZoomDistance = 9999 end)
                pcall(function() ps.CameraMinZoomDistance = 0.5 end)
            end
        end)
        -- Mantém o zoom mesmo que o jogo tente resetar
        camAltaConn = RunService.RenderStepped:Connect(function()
            pcall(function()
                local ps = Players.LocalPlayer
                if ps and ps.CameraMaxZoomDistance < 9999 then
                    ps.CameraMaxZoomDistance = 9999
                end
            end)
        end)
        Notify.info("📷 Câmera Alta", "Zoom ilimitado ativado!")
    else
        if camAltaConn then camAltaConn:Disconnect(); camAltaConn = nil end
        pcall(function()
            local ps = Players.LocalPlayer
            if ps then ps.CameraMaxZoomDistance = 128; ps.CameraMinZoomDistance = 0.5 end
        end)
        Notify.info("📷 Câmera Alta", "Zoom restaurado.")
    end
end

makePlSec("plSecCamera", Color3.fromRGB(100,220,255))
do -- camera card agrupado
local setCamX -- declaração antecipada: definida mais abaixo no mesmo bloco
local _camc=_nc(plNextLO); local _camy=0
_camy=_camy+_nt(_camc,_camy,"📷 Câmera Alta",false,function(en) setCamAlta(en) end)
_camy=_camy+_nd(_camc,_camy)
_camy=_camy+_nt(_camc,_camy,"🔭 Câmera X — atravessa paredes",false,function(en) if setCamX then setCamX(en) end end)
_camy=_camy+_nd(_camc,_camy)

-- ══════════════════════════════════════════════════════
-- CÂMERA X — atravessa paredes
-- ══════════════════════════════════════════════════════
local camXEnabled = false
local camXConn
local camXTranspCache = {}

-- setCamX atribuída ao upvalue declarado acima no do-block
setCamX = function(state)
    camXEnabled = state
    if state then
        camXConn = RunService.RenderStepped:Connect(function()
            if not camXEnabled then return end
            local cam = workspace.CurrentCamera
            local ch = Player.Character
            if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Detecta partes entre câmera e personagem e as torna transparentes localmente
            local camPos = cam.CFrame.Position
            local hrpPos = hrp.Position
            local dir = (hrpPos - camPos)
            local dist = dir.Magnitude
            if dist < 0.5 then return end

            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {ch}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude

            -- Restaura partes que já não estão mais na frente
            for part, origT in pairs(camXTranspCache) do
                if part and part.Parent then
                    part.LocalTransparencyModifier = origT
                end
            end
            camXTranspCache = {}

            -- Raio da câmera até o personagem
            local result = workspace:Raycast(camPos, dir, rayParams)
            local iteration = 0
            local checkPos = camPos
            local remaining = dir
            while result and iteration < 8 do
                local hitPart = result.Instance
                if hitPart and hitPart:IsA("BasePart") and not hitPart:IsDescendantOf(ch) then
                    if not camXTranspCache[hitPart] then
                        camXTranspCache[hitPart] = hitPart.LocalTransparencyModifier
                    end
                    hitPart.LocalTransparencyModifier = 0.85
                end
                -- Continua o raio atrás da parte atingida
                local newStart = result.Position + dir.Unit * 0.1
                remaining = hrpPos - newStart
                if remaining.Magnitude < 0.3 then break end
                result = workspace:Raycast(newStart, remaining, rayParams)
                iteration = iteration + 1
            end
        end)
        Notify.info("🔭 Câmera X", "Câmera atravessa paredes ativado!")
    else
        if camXConn then camXConn:Disconnect(); camXConn = nil end
        -- Restaura transparências
        for part, origT in pairs(camXTranspCache) do
            if part and part.Parent then part.LocalTransparencyModifier = origT end
        end
        camXTranspCache = {}
        Notify.info("🔭 Câmera X", "Desativado.")
    end
end

-- CamX já adicionado no card agrupado acima

-- ══════════════════════════════════════════════════════
-- DISTÂNCIA DE CÂMERA — slider de zoom + toggle
-- ══════════════════════════════════════════════════════
do
local camDistValue   = 60   -- distância padrão quando ativo
local camDistEnabled = false

local function applyCamDist(dist, enabled)
    pcall(function()
        if enabled then
            Player.CameraMaxZoomDistance = dist
            Player.CameraMinZoomDistance = dist * 0.1
        else
            Player.CameraMaxZoomDistance = 128
            Player.CameraMinZoomDistance = 0.5
        end
    end)
end

-- ── Distância de Câmera — toggle + slider dentro do card agrupado
local CD_COR = Color3.fromRGB(100,220,255)
local cdValLbl -- referência para a lógica de toggle abaixo

do -- toggle dist cam
local _ty=_camy
_camy=_camy+_nt(_camc,_camy,"📐 Distância de Câmera",false,function(en)
    camDistEnabled=en
    applyCamDist(camDistValue,en)
    if en then Notify.success("🔭 Distância","Zoom fixo: "..camDistValue.." studs!")
    else Notify.info("🔭 Distância","Restaurado.") end
end)
end -- toggle dist
-- slider dist dentro do card
local _cdvl=Instance.new("TextLabel",_camc); _cdvl.BackgroundTransparency=1
_cdvl.Position=UDim2.new(0.46,0,0,_camy+17); _cdvl.Size=UDim2.new(0,28,0,16)
_cdvl.Font=Enum.Font.GothamBold; _cdvl.Text="60"
_cdvl.TextColor3=Color3.fromRGB(200,215,245); _cdvl.TextSize=11
_cdvl.TextXAlignment=Enum.TextXAlignment.Left; _cdvl.ZIndex=7
cdValLbl=_cdvl
local cdTrack_inner=Instance.new("Frame",_camc)
cdTrack_inner.BackgroundColor3=Color3.fromRGB(20,36,80); cdTrack_inner.BorderSizePixel=0
cdTrack_inner.Position=UDim2.new(0.46,32,0,_camy+25)
cdTrack_inner.Size=UDim2.new(0.51,-46,0,4); cdTrack_inner.ZIndex=7
Instance.new("UICorner",cdTrack_inner).CornerRadius=UDim.new(1,0)
local cdFill_inner=Instance.new("Frame",cdTrack_inner); cdFill_inner.BackgroundColor3=CD_COR
cdFill_inner.BorderSizePixel=0; cdFill_inner.Size=UDim2.new(0.22,0,1,0); cdFill_inner.ZIndex=8
Instance.new("UICorner",cdFill_inner).CornerRadius=UDim.new(1,0)
local cdTrack=cdTrack_inner
local cdFill=cdFill_inner
local cdDot=Instance.new("Frame",cdTrack_inner)
cdDot.BackgroundColor3=Color3.fromRGB(25,48,105); cdDot.BorderSizePixel=0
cdDot.AnchorPoint=Vector2.new(0.5,0.5); cdDot.Position=UDim2.new(0.22,0,0.5,0); cdDot.Size=UDim2.new(0,16,0,16); cdDot.ZIndex=9
Instance.new("UICorner",cdDot).CornerRadius=UDim.new(1,0)
-- Slider logic
local cdDragging=false
local cdMin,cdMax=20,500
local function cdSetVal(pct)
    pct=math.clamp(pct,0,1)
    camDistValue=math.floor(cdMin+(cdMax-cdMin)*pct+0.5)
    cdFill.Size=UDim2.new(pct,0,1,0); cdDot.Position=UDim2.new(pct,0,0.5,0)
    cdValLbl.Text=tostring(camDistValue)
    if camDistEnabled then applyCamDist(camDistValue, true) end
end
local cdSliderBtn=Instance.new("TextButton",cdTrack); cdSliderBtn.BackgroundTransparency=1
cdSliderBtn.Size=UDim2.new(1,20,1,20); cdSliderBtn.Position=UDim2.new(0,-10,0,-10); cdSliderBtn.Text=""; cdSliderBtn.ZIndex=10
cdSliderBtn.MouseButton1Down:Connect(function()
    cdDragging=true
    local ap=cdTrack.AbsolutePosition; local as=cdTrack.AbsoluteSize
    cdSetVal((UserInputService:GetMouseLocation().X-ap.X)/as.X)
end)
UserInputService.InputChanged:Connect(function(inp)
    if not cdDragging then return end
    if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
    local ap=cdTrack.AbsolutePosition; local as=cdTrack.AbsoluteSize
    cdSetVal((inp.Position.X-ap.X)/as.X)
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then cdDragging=false end
end)
-- Toggle logic
-- toggle dist câmera gerenciado pelo _nt acima
_camy=_camy+50 -- slider dist

-- ══════════════════════════════════════════════════════
-- FOV — Field of View slider
-- ══════════════════════════════════════════════════════
do
local FOV_COR = Color3.fromRGB(100,220,255)
local fovDefault = 70
local fovCurrent = 70
local fovEnabled = false

local function applyFov(v)
    pcall(function()
        workspace.CurrentCamera.FieldOfView = v
    end)
end
local function resetFov()
    pcall(function()
        workspace.CurrentCamera.FieldOfView = fovDefault
    end)
end

_camy=_camy+_nd(_camc,_camy)
_camy=_camy+_nt(_camc,_camy,"🎥  FOV Customizado",false,function(en)
    fovEnabled=en
    if en then
        applyFov(fovCurrent)
        Notify.success("🎥 FOV","FOV: "..fovCurrent.."°")
    else
        resetFov()
        Notify.info("🎥 FOV","FOV restaurado para "..fovDefault.."°")
    end
end)

-- Valor label
local fovValLbl=Instance.new("TextLabel",_camc); fovValLbl.BackgroundTransparency=1
fovValLbl.Position=UDim2.new(0.46,0,0,_camy+17); fovValLbl.Size=UDim2.new(0,36,0,16)
fovValLbl.Font=Enum.Font.GothamBold; fovValLbl.Text="70°"
fovValLbl.TextColor3=Color3.fromRGB(200,215,245); fovValLbl.TextSize=11
fovValLbl.TextXAlignment=Enum.TextXAlignment.Left; fovValLbl.ZIndex=7

-- Track
local fovTrack=Instance.new("Frame",_camc)
fovTrack.BackgroundColor3=Color3.fromRGB(20,36,80); fovTrack.BorderSizePixel=0
fovTrack.Position=UDim2.new(0.46,42,0,_camy+25)
fovTrack.Size=UDim2.new(0.51,-54,0,4); fovTrack.ZIndex=7
Instance.new("UICorner",fovTrack).CornerRadius=UDim.new(1,0)

local fovFill=Instance.new("Frame",fovTrack); fovFill.BackgroundColor3=FOV_COR
fovFill.BorderSizePixel=0; fovFill.Size=UDim2.new(0.25,0,1,0); fovFill.ZIndex=8
Instance.new("UICorner",fovFill).CornerRadius=UDim.new(1,0)
local fovFG=Instance.new("UIGradient",fovFill)
fovFG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(60,180,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(140,230,255))})

local fovKnob=Instance.new("Frame",fovTrack)
fovKnob.BackgroundColor3=Color3.fromRGB(25,48,105); fovKnob.BorderSizePixel=0
fovKnob.AnchorPoint=Vector2.new(0.5,0.5); fovKnob.Position=UDim2.new(0.25,0,0.5,0)
fovKnob.Size=UDim2.new(0,16,0,16); fovKnob.ZIndex=9
Instance.new("UICorner",fovKnob).CornerRadius=UDim.new(1,0)
local fovKS=Instance.new("UIStroke",fovKnob); fovKS.Color=FOV_COR; fovKS.Thickness=1.5; fovKS.Transparency=0.3; fovKS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

local FOV_MIN,FOV_MAX = 30,120
local function fovSetVal(pct)
    pct=math.clamp(pct,0,1)
    fovCurrent=math.floor(FOV_MIN+(FOV_MAX-FOV_MIN)*pct+0.5)
    fovFill.Size=UDim2.new(pct,0,1,0); fovKnob.Position=UDim2.new(pct,0,0.5,0)
    fovValLbl.Text=tostring(fovCurrent).."°"
    if fovEnabled then applyFov(fovCurrent) end
end

local fovDrag=false
local fovSb=Instance.new("TextButton",fovTrack); fovSb.BackgroundTransparency=1
fovSb.Size=UDim2.new(1,20,1,20); fovSb.Position=UDim2.new(0,-10,0,-10); fovSb.Text=""; fovSb.ZIndex=10
fovSb.MouseButton1Down:Connect(function()
    fovDrag=true
    local ap=fovTrack.AbsolutePosition; local as=fovTrack.AbsoluteSize
    fovSetVal((UserInputService:GetMouseLocation().X-ap.X)/as.X)
end)
UserInputService.InputChanged:Connect(function(inp)
    if not fovDrag then return end
    if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
    local ap=fovTrack.AbsolutePosition; local as=fovTrack.AbsoluteSize
    fovSetVal((inp.Position.X-ap.X)/as.X)
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then fovDrag=false end
end)

_camy=_camy+50 -- slider FOV
end -- FOV

_camc.Size=UDim2.new(1,0,0,_camy)
end -- camera card agrupado
end -- camDist

-- ══════════════════════════════════════════════════════
-- VISÃO MELHORADA (NoFov) — remove neblina/fog total
-- ══════════════════════════════════════════════════════
do
local noFovEnabled   = false
local fogOrigEnd, fogOrigStart, fogOrigColor
local atmOrigDensity, atmOrigHaze, atmOrigGlare

-- setNoFov atribuída ao upvalue declarado antes do plSecUtil
setNoFov = function(state)
    noFovEnabled = state
    local Lighting = game:GetService("Lighting")
    if state then
        -- Salva valores originais
        fogOrigEnd   = Lighting.FogEnd
        fogOrigStart = Lighting.FogStart
        fogOrigColor = Lighting.FogColor
        -- Remove fog completamente
        Lighting.FogEnd   = 100000
        Lighting.FogStart = 100000
        -- Remove Atmosphere (neblina volumétrica)
        pcall(function()
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then
                atmOrigDensity = atm.Density
                atmOrigHaze    = atm.Haze
                atmOrigGlare   = atm.Glare
                atm.Density = 0
                atm.Haze    = 0
                atm.Glare   = 0
            end
        end)
        -- Aumenta visibilidade distante: remove DepthOfField se existir
        pcall(function()
            for _, eff in ipairs(Lighting:GetDescendants()) do
                if eff:IsA("DepthOfFieldEffect") or eff:IsA("BlurEffect") then
                    eff.Enabled = false
                end
            end
        end)
        Notify.success("👁 Visão Melhorada","Neblina removida — você enxerga tudo!")
    else
        pcall(function()
            Lighting.FogEnd   = fogOrigEnd   or 1000
            Lighting.FogStart = fogOrigStart or 0
            if fogOrigColor then Lighting.FogColor = fogOrigColor end
            local atm = Lighting:FindFirstChildOfClass("Atmosphere")
            if atm then
                atm.Density = atmOrigDensity or 0.395
                atm.Haze    = atmOrigHaze    or 0
                atm.Glare   = atmOrigGlare   or 0
            end
            for _, eff in ipairs(Lighting:GetDescendants()) do
                if eff:IsA("DepthOfFieldEffect") or eff:IsA("BlurEffect") then
                    eff.Enabled = true
                end
            end
        end)
        Notify.info("👁 Visão Melhorada","Neblina restaurada.")
    end
end

end -- noFov

end) -- [[ PLAYER TAB PART 1 ]]
-- ══════════════════════════════════════════════════════════════
-- ABA CONFIGURAÇÕES — Walk Speed, Jump Power, Gravidade, Sons
-- ══════════════════════════════════════════════════════════════
-- Helpers compartilhados entre blocos de Configurações (escopo externo)
local cfgLO2 = 200
local function cfg2NextLO() cfgLO2 = cfgLO2 + 1; return cfgLO2 end
local cfgMkSec
cfgMkSec = function(titleTxt, cor)
    local hdr = Instance.new("Frame", Pages["Configuracoes"])
    hdr.BackgroundColor3 = Color3.fromRGB(44,28,72); hdr.BackgroundTransparency = 0.25
    hdr.BorderSizePixel = 0; hdr.Size = UDim2.new(1,0,0,22)
    hdr.LayoutOrder = cfg2NextLO(); hdr.ZIndex = 4
    Instance.new("UICorner",hdr).CornerRadius = UDim.new(0,6)
    local bar = Instance.new("Frame",hdr); bar.BackgroundColor3 = cor; bar.BorderSizePixel = 0
    bar.Size = UDim2.new(0,3,1,0); bar.ZIndex = 5
    Instance.new("UICorner",bar).CornerRadius = UDim.new(0,3)
    local lbl = Instance.new("TextLabel",hdr); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,10,0,0); lbl.Size = UDim2.new(1,-14,1,0)
    lbl.Font = Enum.Font.GothamBlack; lbl.Text = titleTxt
    lbl.TextColor3 = cor; lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5
end

-- Helper: slider moderno para Configuracoes
local function cfgMkSlider(titleTxt, descTxt, cor, minV, maxV, defV, fmt, onChange)
    local row=Instance.new("Frame",Pages["Configuracoes"])
    row.BackgroundColor3=Color3.fromRGB(72,50,108); row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,66); row.LayoutOrder=cfg2NextLO(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)

    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,0); tl.Size=UDim2.new(0.50,0,1,0)
    tl.Font=Enum.Font.GothamBold; tl.Text=titleTxt
    tl.TextColor3=Color3.fromRGB(215,205,235); tl.TextSize=11
    tl.TextXAlignment=Enum.TextXAlignment.Left
    tl.TextYAlignment=Enum.TextYAlignment.Center
    tl.TextWrapped=true; tl.ZIndex=6

    local curVal=defV
    local valLbl=Instance.new("TextLabel",row); valLbl.BackgroundTransparency=1
    valLbl.Position=UDim2.new(0.52,0,0.5,-10); valLbl.Size=UDim2.new(0,32,0,20)
    valLbl.Font=Enum.Font.GothamBold
    valLbl.Text=string.format(fmt or "%d",defV)
    valLbl.TextColor3=Color3.fromRGB(215,205,235); valLbl.TextSize=12
    valLbl.TextXAlignment=Enum.TextXAlignment.Left; valLbl.ZIndex=7

    local pct0=(defV-minV)/(maxV-minV)
    local trackBg=Instance.new("Frame",row)
    trackBg.BackgroundColor3=Color3.fromRGB(90,68,124); trackBg.BorderSizePixel=0
    trackBg.Position=UDim2.new(0.52,38,0.5,-2)
    trackBg.Size=UDim2.new(0.45,-52,0,4); trackBg.ZIndex=7
    Instance.new("UICorner",trackBg).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame",trackBg); fill.BackgroundColor3=cor
    fill.BorderSizePixel=0; fill.Size=UDim2.new(pct0,0,1,0); fill.ZIndex=8
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame",trackBg)
    knob.BackgroundColor3=Color3.fromRGB(50,32,80); knob.BorderSizePixel=0
    knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(pct0,0,0.5,0); knob.Size=UDim2.new(0,18,0,18); knob.ZIndex=9
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local dragging=false
    local function setV(pct)
        pct=math.clamp(pct,0,1)
        curVal=math.floor(minV+(maxV-minV)*pct+0.5)
        fill.Size=UDim2.new(pct,0,1,0); knob.Position=UDim2.new(pct,0,0.5,0)
        valLbl.Text=string.format(fmt or "%d",curVal)
        pcall(onChange,curVal)
    end
    local sb=Instance.new("TextButton",trackBg); sb.BackgroundTransparency=1
    sb.Size=UDim2.new(1,24,1,24); sb.Position=UDim2.new(0,-12,0,-12); sb.Text=""; sb.ZIndex=10
    sb.MouseButton1Down:Connect(function()
        dragging=true
        local ap=trackBg.AbsolutePosition; local as=trackBg.AbsoluteSize
        setV((UserInputService:GetMouseLocation().X-ap.X)/as.X)
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local ap=trackBg.AbsolutePosition; local as=trackBg.AbsoluteSize
        setV((inp.Position.X-ap.X)/as.X)
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
end

local _dbgOk_9512, _dbgErr_9512 = pcall(function() -- [[ PLAYER2/CONFIG ]]

-- ══════════════════════════════════════════════════════
-- PULO INFINITO — pula indefinidamente no ar
-- ══════════════════════════════════════════════════════
do
local infJumpEnabled = false
local infJumpConn

-- setInfJump atribuída ao upvalue declarado antes do plSecUtil
setInfJump = function(state)
    infJumpEnabled = state
    if state then
        if infJumpConn then infJumpConn:Disconnect() end
        infJumpConn = UserInputService.JumpRequest:Connect(function()
            if not infJumpEnabled then return end
            pcall(function()
                local ch = Player.Character; if not ch then return end
                local hum = ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end)
        Notify.success("♾️ Pulo Infinito","Pode pular no ar infinitamente!")
    else
        if infJumpConn then infJumpConn:Disconnect(); infJumpConn=nil end
        Notify.info("♾️ Pulo Infinito","Desativado — pulo normal restaurado.")
    end
end

end -- infJump

-- ══════════════════════════════════════════════════════
-- ANTI DESACELERAÇÃO — burla armadilhas que reduzem velocidade
-- ══════════════════════════════════════════════════════
local antiSlowEnabled = false
local antiSlowConn

local function setAntiSlow(state)
    antiSlowEnabled = state
    if state then
        antiSlowConn = RunService.Heartbeat:Connect(function()
            if not antiSlowEnabled then return end
            pcall(function()
                local ch = Player.Character; if not ch then return end
                local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
                -- Força WalkSpeed mínimo — ignora redução de armadilhas
                if hum.WalkSpeed < playerSpeed * 0.85 then
                    hum.WalkSpeed = playerSpeed
                end
                -- Remove efeitos de status de desaceleração
                for _, eff in ipairs(hum:GetChildren()) do
                    if eff:IsA("NumberValue") or eff:IsA("StringValue") then
                        local n = eff.Name:lower()
                        if n:find("slow") or n:find("trap") or n:find("debuff") or n:find("snare") then
                            pcall(function() eff:Destroy() end)
                        end
                    end
                end
                -- Remove BodyVelocity impostos por armadilhas
                local hrp = ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in ipairs(hrp:GetChildren()) do
                        if v:IsA("BodyVelocity") and v.Name:lower():find("trap") then
                            pcall(function() v:Destroy() end)
                        end
                    end
                end
            end)
        end)
        Notify.info("🛡 Anti Desaceleração", "Armadilhas de velocidade ignoradas!")
    else
        if antiSlowConn then antiSlowConn:Disconnect(); antiSlowConn = nil end
        Notify.info("🛡 Anti Desaceleração", "Desativado.")
    end
end

-- ── Anti-Debuff — Accordion ──────────────────────────────────
do
local _ac,_acCF=makeAccordionCard(Pages["Player"],plNextLO,{icon="🛡️",title="Anti-Debuff",summary="Protege contra desaceleração, void e traversal.",color=Color3.fromRGB(255,180,50),contentH=36+9+44+9+44+14})
local _ay=36+8; _accDivLine(_acCF,_ay,Color3.fromRGB(255,180,50)); _ay=_ay+9
_ay=_ay+_accToggle(_acCF,_ay,"🛡 Anti Desaceleração",false,Color3.fromRGB(255,180,50),function(en) setAntiSlow(en) end)
_accDivLine(_acCF,_ay,Color3.fromRGB(255,140,40)); _ay=_ay+9
_accToggle(_acCF,_ay,"🕳️ Anti-Void / Anti-Traversal",false,Color3.fromRGB(255,140,40),function(en) setAntiVoid(en) end)
end

-- ══════════════════════════════════════════════════════════════
-- ANTI-VOID & ANTI-TRAVERSAL — Resgate automático
-- ══════════════════════════════════════════════════════════════
-- Detecta DOIS cenários:
--   1. VOID  — jogador cai abaixo de Y_VOID_THRESHOLD (-120)
--              → imediatamente teleporta para última posição segura
--   2. CHÃO  — jogador fica por > TRAVERSE_FRAMES frames consecutivos
--              DENTRO do chão (Y do HRP <= Y da parte abaixo − 1.5)
--              usando Raycast para baixo a cada frame.
--              → teleporta 3 studs acima do ponto de contato
-- Última posição segura = salva a cada SAFE_SAVE_INTERVAL frames
-- se o jogador estiver no chão (isOnGround via Humanoid.FloorMaterial)
-- ══════════════════════════════════════════════════════════════
local AV_COR               = Color3.fromRGB(255, 140, 40)
local avEnabled            = false
local avConn               = nil

local Y_VOID_THRESHOLD     = -120   -- abaixo disso = void
local Y_VOID_SAFE_OFFSET   = 8      -- altura acima do ground ao teleportar
local TRAVERSE_FRAMES      = 4      -- frames dentro do chão para considerar atravessado
local SAFE_SAVE_INTERVAL   = 20     -- salva posição segura a cada N frames
local RAY_DOWN_LEN         = 80     -- comprimento do raio para baixo

local avLastSafePos        = nil    -- última posição segura salva
local avTraverseCount      = 0      -- contador de frames dentro do chão
local avFrameCount         = 0      -- contador geral de frames
local avRescuing           = false  -- flag para evitar rescues duplicados
local avCooldown           = 0      -- tick do último resgate

local function avRescue(reason, hrp)
    if avRescuing then return end
    if tick() - avCooldown < 1.5 then return end  -- cooldown 1.5s entre resgates
    avRescuing = true
    avCooldown = tick()
    avTraverseCount = 0

    pcall(function()
        -- Para velocidade atual para não continuar caindo
        hrp.Velocity       = Vector3.new(0,0,0)
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
    end)

    if reason == "void" then
        -- Tenta encontrar chão acima pelo Raycast
        local dest = nil
        pcall(function()
            local rayOrigin = Vector3.new(hrp.Position.X, Y_VOID_THRESHOLD + 20, hrp.Position.Z)
            local rayDir    = Vector3.new(0, 1000, 0)  -- sobe até achar chão
            local params    = RaycastParams.new()
            params.FilterDescendantsInstances = {Player.Character}
            params.FilterType = Enum.RaycastFilterType.Exclude
            local result = workspace:Raycast(rayOrigin, rayDir, params)
            if result then
                dest = Vector3.new(result.Position.X, result.Position.Y + Y_VOID_SAFE_OFFSET, result.Position.Z)
            end
        end)
        -- Se achou chão acima, vai lá; senão usa última posição segura
        if dest then
            hrp.CFrame = CFrame.new(dest)
        elseif avLastSafePos then
            hrp.CFrame = CFrame.new(avLastSafePos)
        else
            -- Fallback total: fogueira
            local camp = getCampfirePos()
            if camp then hrp.CFrame = CFrame.new(camp.X, camp.Y + 5, camp.Z) end
        end
        Notify.send({type="custom", icon="🛡", accent=AV_COR,
            title="Anti-Void", msg="⚠️ Void detectado! Resgatado.", duration=3})

    elseif reason == "traverse" then
        -- Raycast para cima para achar a superfície que foi atravessada
        local dest = nil
        pcall(function()
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {Player.Character}
            params.FilterType = Enum.RaycastFilterType.Exclude
            -- Raio para cima a partir da posição atual
            local result = workspace:Raycast(hrp.Position, Vector3.new(0, RAY_DOWN_LEN, 0), params)
            if result then
                dest = Vector3.new(result.Position.X, result.Position.Y + Y_VOID_SAFE_OFFSET, result.Position.Z)
            end
        end)
        if dest then
            hrp.CFrame = CFrame.new(dest)
        elseif avLastSafePos then
            hrp.CFrame = CFrame.new(avLastSafePos)
        end
        Notify.send({type="custom", icon="🛡", accent=AV_COR,
            title="Anti-Traversal", msg="⚠️ Chão atravessado! Resgatado.", duration=3})
    end

    task.wait(0.1)
    avRescuing = false
end

local function avSavePos(hrp, hum)
    -- Só salva se estiver no chão de verdade
    local onGround = false
    pcall(function()
        onGround = hum.FloorMaterial ~= Enum.Material.Air
    end)
    if onGround and hrp.Position.Y > Y_VOID_THRESHOLD then
        avLastSafePos = hrp.Position + Vector3.new(0, 1, 0)
    end
end

local function setAntiVoid(state)
    avEnabled = state
    if aeConn then end  -- não conflita com outros sistemas

    if state then
        if avConn then avConn:Disconnect() end

        avConn = RunService.Heartbeat:Connect(function()
            if not avEnabled then return end
            pcall(function()
                local ch  = Player.Character; if not ch then return end
                local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
                if avRescuing then return end

                avFrameCount = avFrameCount + 1
                local py = hrp.Position.Y

                -- ── DETECÇÃO 1: VOID ────────────────────────────────
                if py < Y_VOID_THRESHOLD then
                    avRescue("void", hrp)
                    return
                end

                -- ── DETECÇÃO 2: ATRAVESSOU O CHÃO ───────────────────
                -- Raycast para baixo a partir dos pés (HRP - metade da altura)
                local feetY = py - 3.1  -- ~metade do HRP padrão
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {ch}
                params.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(
                    Vector3.new(hrp.Position.X, feetY, hrp.Position.Z),
                    Vector3.new(0, -RAY_DOWN_LEN, 0),
                    params
                )

                -- Se o resultado do raycast está ACIMA dos pés → atravessou
                if result and result.Position.Y > feetY + 0.3 then
                    avTraverseCount = avTraverseCount + 1
                    if avTraverseCount >= TRAVERSE_FRAMES then
                        avRescue("traverse", hrp)
                    end
                else
                    avTraverseCount = 0
                end

                -- ── SALVA POSIÇÃO SEGURA ─────────────────────────────
                if avFrameCount % SAFE_SAVE_INTERVAL == 0 then
                    avSavePos(hrp, hum)
                end
            end)
        end)

    else
        if avConn then avConn:Disconnect(); avConn = nil end
        avLastSafePos   = nil
        avTraverseCount = 0
        avRescuing      = false
    end
end

-- Anti-Void toggle agrupado no card plSecAntiDebuff acima

-- ══════════════════════════════════════════════════════
-- GOD MOD v2 — vida REAL (imortalidade via restauração de HP)
-- 99 Nights usa servidor autoritativo para dano.
-- Solução: loop que seta Health = MaxHealth a cada frame.
-- Resultado: personagem toma dano mas recupera imediatamente.
-- ══════════════════════════════════════════════════════
local godModEnabled  = false
local godModConn     = nil   -- Heartbeat principal
local godModCharConn = nil   -- CharacterAdded
local godDiedConns   = {}    -- conexões Died por personagem

-- ──────────────────────────────────────────────────────────────────
-- GOD MODE v4 — Abordagem correta para 99 Nights in the Forest
--
-- PROBLEMA DO SISTEMA ANTERIOR:
--   O servidor controla Health via replicação. Quando seta Health=0,
--   o cliente restaura mas o servidor sobrescreve antes do próximo frame.
--   hookfunction em hum.TakeDamage não bloqueia chamadas SERVER-SIDE.
--
-- SOLUÇÃO REAL (3 camadas que de fato funcionam):
--
--   CAMADA 1 — __namecall metamethod (MAIS FORTE):
--     Intercepta TODOS os métodos chamados com ":" no jogo.
--     Bloqueia hum:TakeDamage() antes de qualquer execução.
--     Funciona mesmo se chamado de LocalScript do jogo ou do servidor.
--
--   CAMADA 2 — __newindex metamethod no Humanoid (SEGUNDA LINHA):
--     Intercepta qualquer atribuição de propriedade no Humanoid.
--     Quando alguém tenta setar Health para valor baixo, retorna sem fazer nada.
--     Bloqueia atribuição direta: hum.Health = 0
--
--   CAMADA 3 — Heartbeat ultra-rápido (BACKUP):
--     Restaura HP a cada frame como última linha de defesa.
--     Agora com MaxHealth = 9e9 (valor extremo para absorver dano rápido).
--
--   + BreakJointsOnDeath = false: evita ragdoll/câmera presa
--   + RequiresNeck = false: não morre por perder cabeça
--   + Died handler: cancela estado de morte via ChangeState
-- ──────────────────────────────────────────────────────────────────

-- Guarda os metamethods originais para restaurar ao desligar
local godOrigNamecall  = nil
local godOrigNewindex  = nil
local godMtGame        = nil
local godMtHum         = nil

local function setGodMod(state)
    godModEnabled = state

    if state then
        if godModConn then godModConn:Disconnect(); godModConn = nil end

        -- ── CAMADA 1: __namecall — bloqueia hum:TakeDamage() ─────────────
        -- Intercepta chamadas de método em qualquer objeto do jogo.
        -- Se for TakeDamage no humanoid do player → cancela.
        pcall(function()
            if not getrawmetatable or not setreadonly then return end
            godMtGame = getrawmetatable(game)
            setreadonly(godMtGame, false)
            if not godOrigNamecall then
                godOrigNamecall = godMtGame.__namecall
            end
            godMtGame.__namecall = newcclosure(function(self, ...)
                if godModEnabled then
                    local method = getnamecallmethod and getnamecallmethod() or ""
                    if method == "TakeDamage" then
                        local ch = Player.Character
                        if ch and self == ch:FindFirstChildWhichIsA("Humanoid") then
                            return  -- cancela o dano no humanoid do player
                        end
                    end
                end
                return godOrigNamecall(self, ...)
            end)
            setreadonly(godMtGame, true)
        end)

        local function applyGodModToChar(ch)
            if not ch then return end
            local hum = ch:FindFirstChildWhichIsA("Humanoid")
            if not hum then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart")

            -- CAMADA A: propriedades básicas
            pcall(function() hum.BreakJointsOnDeath = false end)
            pcall(function() hum.RequiresNeck = false end)
            hum.MaxHealth = hum.MaxHealth  -- força sync
            hum.Health    = hum.MaxHealth

            -- CAMADA B: ForceField — proteção server-side real
            -- O servidor respeita ForceField e bloqueia dano automaticamente
            pcall(function()
                local ff = ch:FindFirstChildWhichIsA("ForceField")
                if not ff then
                    local newff = Instance.new("ForceField")
                    newff.Visible = false
                    newff.Parent  = ch
                end
            end)

            -- CAMADA C: __namecall intercepta TakeDamage
            pcall(function()
                if not getrawmetatable or not setreadonly then return end
                godMtGame = getrawmetatable(game)
                setreadonly(godMtGame, false)
                if not godOrigNamecall then
                    godOrigNamecall = godMtGame.__namecall
                end
                godMtGame.__namecall = newcclosure(function(self, ...)
                    if godModEnabled then
                        local method = getnamecallmethod and getnamecallmethod() or ""
                        if method == "TakeDamage" then
                            local pch = Player.Character
                            if pch and self == pch:FindFirstChildWhichIsA("Humanoid") then
                                return
                            end
                        end
                    end
                    return godOrigNamecall(self, ...)
                end)
                setreadonly(godMtGame, true)
            end)

            -- CAMADA D: HealthChanged — restaura instantaneamente
            local hcConn
            hcConn = hum.HealthChanged:Connect(function(newHp)
                if not godModEnabled then hcConn:Disconnect(); return end
                pcall(function()
                    if newHp < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                        -- Recria ForceField se sumiu
                        local pch = Player.Character
                        if pch and not pch:FindFirstChildWhichIsA("ForceField") then
                            local ff2 = Instance.new("ForceField")
                            ff2.Visible = false; ff2.Parent = pch
                        end
                    end
                end)
            end)
            table.insert(godDiedConns, hcConn)

            -- CAMADA E: Died → ressuscita imediatamente
            local diedConn
            diedConn = hum.Died:Connect(function()
                if not godModEnabled then diedConn:Disconnect(); return end
                task.defer(function()
                    pcall(function()
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                        hum.Health = hum.MaxHealth
                    end)
                end)
            end)
            table.insert(godDiedConns, diedConn)
        end

        applyGodModToChar(Player.Character)

        -- ── CAMADA 3: Heartbeat — múltiplas proteções a cada frame ─────
        local ffCheckTick = 0
        godModConn = RunService.Heartbeat:Connect(function()
            if not godModEnabled then return end
            pcall(function()
                local c2 = Player.Character; if not c2 then return end
                local h2 = c2:FindFirstChildWhichIsA("Humanoid"); if not h2 then return end
                -- Anti-morte
                h2.BreakJointsOnDeath = false
                h2.RequiresNeck       = false
                -- Restaura HP
                local maxHp = h2.MaxHealth
                if maxHp > 0 and h2.Health < maxHp then
                    h2.Health = maxHp
                end
                -- Força GettingUp se morreu
                if h2:GetState() == Enum.HumanoidStateType.Dead then
                    h2:ChangeState(Enum.HumanoidStateType.GettingUp)
                    h2.Health = maxHp
                end
                -- Recria ForceField a cada 2s (servidor pode remover)
                local now = tick()
                if now - ffCheckTick > 2 then
                    ffCheckTick = now
                    if not c2:FindFirstChildWhichIsA("ForceField") then
                        local ff = Instance.new("ForceField")
                        ff.Visible = false; ff.Parent = c2
                    end
                end
            end)
        end)

        if godModCharConn then godModCharConn:Disconnect() end
        godModCharConn = Player.CharacterAdded:Connect(function(ch)
            if not godModEnabled then return end
            task.wait(0.1)
            applyGodModToChar(ch)
        end)

        Notify.send({type="custom", icon="♾️", accent=Color3.fromRGB(140,255,140),
            title="God Mod ATIVO",
            msg="__namecall + __newindex + Heartbeat: dano bloqueado!",
            duration=4})
    else
        -- ── DESLIGAR ───────────────────────────────────────────────────────
        if godModConn     then godModConn:Disconnect();     godModConn     = nil end
        if godModCharConn then godModCharConn:Disconnect(); godModCharConn = nil end

        for _, c in ipairs(godDiedConns) do pcall(function() c:Disconnect() end) end
        godDiedConns = {}

        -- Restaura __namecall original
        pcall(function()
            if godMtGame and godOrigNamecall and setreadonly then
                setreadonly(godMtGame, false)
                godMtGame.__namecall = godOrigNamecall
                setreadonly(godMtGame, true)
                godOrigNamecall = nil
            end
        end)

        -- Restaura __newindex original do Humanoid
        pcall(function()
            if godMtHum and godOrigNewindex and setreadonly then
                setreadonly(godMtHum, false)
                godMtHum.__newindex = godOrigNewindex
                setreadonly(godMtHum, true)
                godOrigNewindex = nil
                godMtHum = nil
            end
        end)

        -- Remove ForceField e restaura normais
        pcall(function()
            local ch = Player.Character; if not ch then return end
            -- Remove ForceField criado pelo God Mode
            for _, ff in ipairs(ch:GetChildren()) do
                if ff:IsA("ForceField") then pcall(function() ff:Destroy() end) end
            end
            local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
            hum.BreakJointsOnDeath = true
            hum.MaxHealth = 100
            hum.Health    = 100
        end)

        Notify.error("♾️ God Mod", "✗ Desativado — HP e morte normais restaurados.")
    end
end

-- ── God Mode — Accordion ─────────────────────────────────────
do
local _gc,_gcCF=makeAccordionCard(Pages["Player"],plNextLO,{icon="👻",title="God Mode",summary="Ativa invulnerabilidade total no personagem.",color=Color3.fromRGB(140,255,140),contentH=36+9+44+14})
local _gy=36+8; _accDivLine(_gcCF,_gy,Color3.fromRGB(140,255,140)); _gy=_gy+9
_accToggle(_gcCF,_gy,"👻 God Mod",false,Color3.fromRGB(140,255,140),function(en) setGodMod(en) end)
end

-- ══════════════════════════════════════════════════════
-- BAÚS ACS — Abre todos os baús automaticamente
-- Remote: ReplicatedStorage.RemoteEvents.RequestOpenItemChest
-- Arg:    Model "Item Chest" em Workspace.Items
-- ══════════════════════════════════════════════════════
do
local ACS_COR    = Color3.fromRGB(255, 200, 60)
local acsEnabled = false
local acsConn    = nil

-- Pega o RemoteEvent do baú
local acsRemote = nil
pcall(function()
    acsRemote = game:GetService("ReplicatedStorage")
        :WaitForChild("RemoteEvents", 5)
        :WaitForChild("RequestOpenItemChest", 5)
end)

local function abrirTodosOsBaus()
    if not acsRemote then
        Notify.warn("Baús ACS", "⚠️ RemoteEvent não encontrado!")
        return 0
    end
    local count = 0
    local itemsFolder = workspace:FindFirstChild("Items")
    local toSearch = itemsFolder and itemsFolder:GetDescendants() or workspace:GetDescendants()
    for _, obj in ipairs(toSearch) do
        if obj:IsA("Model") then
            local nm = obj.Name:lower()
            if nm:find("chest",1,true) or nm:find("bau",1,true) or nm:find("baú",1,true) then
                pcall(function()
                    acsRemote:FireServer(obj)
                    count = count + 1
                end)
                task.wait(0.05) -- pequeno delay entre cada baú
            end
        end
    end
    return count
end

-- Loop automático quando ativo
local function startACS()
    if acsConn then acsConn:Disconnect() end
    -- Abre imediatamente ao ativar
    task.spawn(function()
        local n = abrirTodosOsBaus()
        Notify.success("Baús ACS", "✓ "..n.." baú(s) aberto(s)!")
    end)
    -- Continua abrindo novos baús que aparecerem
    acsConn = workspace.DescendantAdded:Connect(function(obj)
        if not acsEnabled then return end
        if not obj:IsA("Model") then return end
        local nm = obj.Name:lower()
        if nm:find("chest",1,true) or nm:find("bau",1,true) or nm:find("baú",1,true) then
            task.wait(0.3) -- aguarda o baú carregar
            pcall(function()
                if acsRemote and obj.Parent then
                    acsRemote:FireServer(obj)
                end
            end)
        end
    end)
end

local function stopACS()
    if acsConn then acsConn:Disconnect(); acsConn = nil end
end

-- ── Seção ─────────────────────────────────────────────
-- ── Baús ACS — Accordion ─────────────────────────────────────
do
local _acsCard,_acsCF=makeAccordionCard(Pages["Player"],plNextLO,{icon="🎁",title="Baús ACS",summary="Abre automaticamente todos os baús ao aproximar usando RemoteEvent.",color=ACS_COR,contentH=36+9+44+14})
local _ay=36+8; _accDivLine(_acsCF,_ay,ACS_COR); _ay=_ay+9
local _,acsPill2,acsKnob2=_accToggle(_acsCF,_ay,"🎁  Baús ACS",false,ACS_COR,function(s)
    acsEnabled=s
    if s then
        pcall(function() if not acsRemote then acsRemote=game:GetService("ReplicatedStorage").RemoteEvents.RequestOpenItemChest end end)
        startACS(); Notify.send({type="custom",icon="🎁",accent=ACS_COR,title="Baús ACS",msg="Ativado!",duration=4})
    else stopACS(); Notify.info("Baús ACS","Desativado.") end
end)
acsPill=acsPill2; acsKnob=acsKnob2; acsCard=_acsCard
end -- Baús ACS accordion
end -- do ACS

-- ══════════════════════════════════════════════════════════════
-- ABRIR BAÚS INSTANTANEAMENTE — Abre o baú ao 1º toque (sem cooldown)
-- Usa o mesmo RemoteEvent do ACS: ReplicatedStorage.RemoteEvents.RequestOpenItemChest
-- A diferença: escuta o ProximityPrompt de cada baú e dispara o Remote na hora.
-- ══════════════════════════════════════════════════════════════
do
local IBC_COR = Color3.fromRGB(255, 215, 60)
local ibcEnabled  = false
local ibcConns    = {}  -- lista de conexões ativas nos ProximityPrompts

-- Pega o mesmo remote do ACS
local ibcRemote = nil
pcall(function()
    ibcRemote = game:GetService("ReplicatedStorage")
        :WaitForChild("RemoteEvents", 5)
        :WaitForChild("RequestOpenItemChest", 5)
end)

-- Verifica se obj é um baú
local function ibcIsChest(obj)
    if not obj:IsA("Model") then return false end
    local nm = obj.Name:lower()
    return nm:find("chest",1,true) or nm:find("bau",1,true) or nm:find("baú",1,true)
end

-- Conecta num ProximityPrompt de baú para abri-lo instantaneamente
local function ibcHookChest(chest)
    if not ibcEnabled then return end
    -- Tenta achar o ProximityPrompt dentro do modelo
    local pp = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not pp then return end
    -- Ao iniciar o prompt (segurar), dispara o remote imediatamente
    local c1 = pp.PromptButtonHoldBegan:Connect(function()
        if not ibcEnabled then return end
        pcall(function()
            if ibcRemote and chest and chest.Parent then
                ibcRemote:FireServer(chest)
            end
        end)
    end)
    -- Armazena conexão para desligar depois
    table.insert(ibcConns, c1)
end

local function ibcStart()
    -- Hookeia todos os baús já existentes
    local itemsFolder = workspace:FindFirstChild("Items")
    local toSearch = itemsFolder and itemsFolder:GetDescendants() or workspace:GetDescendants()
    for _, obj in ipairs(toSearch) do
        if ibcIsChest(obj) then
            ibcHookChest(obj)
        end
    end
    -- Escuta novos baús adicionados
    local descConn = workspace.DescendantAdded:Connect(function(obj)
        if not ibcEnabled then return end
        task.wait(0.2)
        if ibcIsChest(obj) and obj.Parent then
            ibcHookChest(obj)
        end
    end)
    table.insert(ibcConns, descConn)
end

local function ibcStop()
    for _, c in ipairs(ibcConns) do pcall(function() c:Disconnect() end) end
    ibcConns = {}
end

-- ── UI — Seção no Player tab ────────────────────────────────
do
-- ── Baús Instantâneos (IBC) — Accordion ─────────────────────
do
local IBC_COR2 = Color3.fromRGB(255, 215, 60)
local _ibcCard,_ibcCF=makeAccordionCard(Pages["Player"],plNextLO,{icon="🔓",title="Baús Instantâneos",summary="Abre o baú ao 1º toque sem cooldown via ProximityPrompt.",color=IBC_COR2,contentH=36+9+44+14})
local _iy=36+8; _accDivLine(_ibcCF,_iy,IBC_COR2); _iy=_iy+9
_accToggle(_ibcCF,_iy,"🔓  Baús Instantâneos",false,IBC_COR2,function(s)
    ibcEnabled=s
    if s then ibcStart() else ibcStop() end
end)
ibcCard=_ibcCard
end -- Baús Instantâneos accordion
end -- do IBC UI
end -- do IBC logic

-- ══════════════════════════════════════════════════════════════

-- ── SEÇÃO: SONS DAS NOTIFICAÇÕES ─────────────────────────────
cfgMkSec("🔊  SONS DAS NOTIFICAÇÕES", Color3.fromRGB(200,140,255))

-- ── Accordion: Sons das Notificações ─────────────────────────
do
local SND_COR = Color3.fromRGB(180,130,255)
local function srgb(r,g,b) return Color3.fromRGB(r,g,b) end

-- Tipos de notificação com sons e cores
local TIPOS_SONS = {
    { key="success",     label="✅  Sucesso",     cor=srgb(60,220,120),  id=6031221736 },
    { key="error",       label="❌  Erro",         cor=srgb(255,80,80),   id=2544086171 },
    { key="warn",        label="⚠️  Aviso",        cor=srgb(255,185,0),   id=3386627205 },
    { key="info",        label="💬  Info",          cor=srgb(60,160,255),  id=4613146380 },
    { key="achievement", label="🏆  Conquista",    cor=srgb(255,210,0),   id=6042053626 },
    { key="custom",      label="💡  Custom",        cor=srgb(180,100,255), id=6012002983 },
}

-- contentH: toggle(44) + divider(9) + slider(68) + divider(9) + 6 tipos × 44px + padding(14)
local TIPOS_H = #TIPOS_SONS * 44
local _,_cf = makeAccordionCard(Pages["Configuracoes"], cfg2NextLO, {
    icon="🔊", title="Sons das Notificações", color=SND_COR,
    summary="Volume e sons individuais para cada tipo de notificação.",
    contentH = 36 + 9 + 44 + 9 + 68 + 9 + TIPOS_H + 14,
})
local _y = 36 + 8

-- ── Toggle global ────────────────────────────────────────────
_accDivLine(_cf, _y, SND_COR); _y = _y + 9
local _, pill, knob = _accToggle(_cf, _y, "🔊  Sons das Notificações", NOTIF_CFG.SOUND_ENABLED, SND_COR, function(en)
    NOTIF_CFG.SOUND_ENABLED = en
    if en then
        Notify.success("🔊 Sons", "Sons de notificações ativados.")
    else
        Notify.info("🔊 Sons", "Sons de notificações desativados.")
    end
end)
_y = _y + 44

-- ── Slider de volume ─────────────────────────────────────────
_accDivLine(_cf, _y, SND_COR); _y = _y + 9

local volRow = Instance.new("Frame", _cf)
volRow.BackgroundColor3 = srgb(72,50,108); volRow.BorderSizePixel = 0
volRow.Position = UDim2.new(0,10,0,_y); volRow.Size = UDim2.new(1,-20,0,60); volRow.ZIndex = 7
Instance.new("UICorner", volRow).CornerRadius = UDim.new(0,12)

local volTl = Instance.new("TextLabel", volRow); volTl.BackgroundTransparency = 1
volTl.Position = UDim2.new(0,14,0,0); volTl.Size = UDim2.new(0.50,0,1,0)
volTl.Font = Enum.Font.GothamBold; volTl.Text = "🔉  Volume"
volTl.TextColor3 = srgb(215,205,235); volTl.TextSize = 11
volTl.TextXAlignment = Enum.TextXAlignment.Left
volTl.TextYAlignment = Enum.TextYAlignment.Center; volTl.ZIndex = 8

local volVal = Instance.new("TextLabel", volRow); volVal.BackgroundTransparency = 1
volVal.Position = UDim2.new(0.52,0,0.5,-10); volVal.Size = UDim2.new(0,38,0,20)
volVal.Font = Enum.Font.GothamBold
volVal.Text = tostring(NOTIF_CFG.SOUND_VOLUME).."%"
volVal.TextColor3 = srgb(215,205,235); volVal.TextSize = 12
volVal.TextXAlignment = Enum.TextXAlignment.Left; volVal.ZIndex = 9

local volTrack = Instance.new("Frame", volRow)
volTrack.BackgroundColor3 = srgb(90,68,124); volTrack.BorderSizePixel = 0
volTrack.Position = UDim2.new(0.52,44,0.5,-2)
volTrack.Size = UDim2.new(0.45,-54,0,4); volTrack.ZIndex = 9
Instance.new("UICorner", volTrack).CornerRadius = UDim.new(1,0)

local volFill = Instance.new("Frame", volTrack)
volFill.BackgroundColor3 = SND_COR; volFill.BorderSizePixel = 0
volFill.Size = UDim2.new(NOTIF_CFG.SOUND_VOLUME/100, 0, 1, 0); volFill.ZIndex = 10
Instance.new("UICorner", volFill).CornerRadius = UDim.new(1,0)
local volFillG = Instance.new("UIGradient", volFill)
volFillG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, srgb(120,80,200)),
    ColorSequenceKeypoint.new(1, srgb(200,150,255)),
})

local volKnob = Instance.new("Frame", volTrack)
volKnob.BackgroundColor3 = srgb(50,32,80); volKnob.BorderSizePixel = 0
volKnob.AnchorPoint = Vector2.new(0.5,0.5)
volKnob.Position = UDim2.new(NOTIF_CFG.SOUND_VOLUME/100, 0, 0.5, 0)
volKnob.Size = UDim2.new(0,18,0,18); volKnob.ZIndex = 11
Instance.new("UICorner", volKnob).CornerRadius = UDim.new(1,0)
local volKS = Instance.new("UIStroke", volKnob)
volKS.Color = SND_COR; volKS.Thickness = 1.5; volKS.Transparency = 0.3
volKS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local volDragging = false
local function setVol(pct)
    pct = math.clamp(pct, 0, 1)
    local v = math.floor(pct * 100 + 0.5)
    NOTIF_CFG.SOUND_VOLUME = v
    volFill.Size = UDim2.new(pct, 0, 1, 0)
    volKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    -- Ícone muda conforme volume
    if v == 0 then volTl.Text = "🔇  Volume"
    elseif v < 40 then volTl.Text = "🔈  Volume"
    elseif v < 75 then volTl.Text = "🔉  Volume"
    else volTl.Text = "🔊  Volume" end
    volVal.Text = tostring(v).."%"
end
local volSb = Instance.new("TextButton", volTrack)
volSb.BackgroundTransparency = 1
volSb.Size = UDim2.new(1,24,1,24); volSb.Position = UDim2.new(0,-12,0,-12)
volSb.Text = ""; volSb.ZIndex = 12
volSb.MouseButton1Down:Connect(function()
    volDragging = true
    local ap = volTrack.AbsolutePosition; local as = volTrack.AbsoluteSize
    setVol((UserInputService:GetMouseLocation().X - ap.X) / as.X)
end)
UserInputService.InputChanged:Connect(function(inp)
    if not volDragging then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local ap = volTrack.AbsolutePosition; local as = volTrack.AbsoluteSize
    setVol((inp.Position.X - ap.X) / as.X)
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then volDragging = false end
end)

_y = _y + 68

-- ── Sons individuais por tipo ────────────────────────────────
_accDivLine(_cf, _y, SND_COR); _y = _y + 9

for _, ts in ipairs(TIPOS_SONS) do
    local row = Instance.new("Frame", _cf)
    row.BackgroundColor3 = srgb(58,38,88); row.BorderSizePixel = 0
    row.Position = UDim2.new(0,10,0,_y); row.Size = UDim2.new(1,-20,0,38); row.ZIndex = 7
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,10)
    local rowS = Instance.new("UIStroke", row)
    rowS.Color = ts.cor; rowS.Thickness = 1.2; rowS.Transparency = 0.65
    rowS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Barra colorida lateral
    local bar = Instance.new("Frame", row)
    bar.BackgroundColor3 = ts.cor; bar.BorderSizePixel = 0
    bar.Size = UDim2.new(0,3,0,22); bar.Position = UDim2.new(0,0,0.5,-11); bar.ZIndex = 8
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,2)

    -- Label do tipo
    local lbl = Instance.new("TextLabel", row)
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,10,0,0); lbl.Size = UDim2.new(1,-90,1,0)
    lbl.Font = Enum.Font.GothamBold; lbl.Text = ts.label
    lbl.TextColor3 = srgb(220,212,245); lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Center; lbl.ZIndex = 8

    -- Botão TESTAR
    local testBtn = Instance.new("TextButton", row)
    testBtn.BackgroundColor3 = ts.cor
    testBtn.BackgroundTransparency = 0.7; testBtn.BorderSizePixel = 0
    testBtn.AnchorPoint = Vector2.new(1,0.5)
    testBtn.Position = UDim2.new(1,-8,0.5,0)
    testBtn.Size = UDim2.new(0,64,0,26)
    testBtn.Font = Enum.Font.GothamBold; testBtn.Text = "▶ Testar"
    testBtn.TextColor3 = srgb(255,255,255); testBtn.TextSize = 9; testBtn.ZIndex = 9
    Instance.new("UICorner", testBtn).CornerRadius = UDim.new(0,7)
    local tS = Instance.new("UIStroke", testBtn)
    tS.Color = ts.cor; tS.Thickness = 1.2; tS.Transparency = 0.3
    tS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    testBtn.MouseEnter:Connect(function()
        TweenService:Create(testBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.3}):Play()
    end)
    testBtn.MouseLeave:Connect(function()
        TweenService:Create(testBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.7}):Play()
    end)
    testBtn.MouseButton1Click:Connect(function()
        -- Toca o som do tipo diretamente com volume atual
        task.spawn(function()
            pcall(function()
                local snd = Instance.new("Sound")
                snd.SoundId = "rbxassetid://"..tostring(ts.id)
                snd.Volume = NOTIF_CFG.SOUND_VOLUME / 100
                snd.RollOffMaxDistance = 0
                snd.Parent = SoundService
                if not snd.IsLoaded then snd.Loaded:Wait() end
                snd:Play()
                game:GetService("Debris"):AddItem(snd, 4)
            end)
        end)
        TweenService:Create(testBtn,TweenInfo.new(0.08),{Size=UDim2.new(0,60,0,22)}):Play()
        task.delay(0.15,function() pcall(function() TweenService:Create(testBtn,TweenInfo.new(0.15,Enum.EasingStyle.Back),{Size=UDim2.new(0,64,0,26)}):Play() end) end)
    end)

    _y = _y + 44
end

end -- Sons accordion


-- ══════════════════════════════════════════════════════════════
-- TRANSPARÊNCIA — Configurações Tab
-- ══════════════════════════════════════════════════════════════
cfgMkSec("🔲  TRANSPARÊNCIA", Color3.fromRGB(160,140,255))
do
local TC = Color3.fromRGB(160,140,255)
local _, _tCF = makeAccordionCard(Pages["Configuracoes"], cfg2NextLO, {
    icon="🔲", title="Transparência", color=TC,
    summary="Ajusta a opacidade do hub — TopBar e botões ficam normais.",
    contentH = 36+9+62+14,
})
local _ty = 36+8
_accDivLine(_tCF, _ty, TC); _ty = _ty+9

local function _isInTopBar(obj)
    local p = obj.Parent
    while p and p ~= MainFrame do
        if p == TopBar then return true end
        p = p.Parent
    end
    return false
end

local function _applyTransp(pct)
    local add = (pct/100) * 0.88
    -- MainFrame
    pcall(function()
        if MainFrame:GetAttribute("_tb") == nil then MainFrame:SetAttribute("_tb", MainFrame.BackgroundTransparency) end
        local b = MainFrame:GetAttribute("_tb")
        MainFrame.BackgroundTransparency = math.clamp(b + add*(1-b), 0, 0.94)
    end)
    -- Todos os frames filhos (exceto TopBar)
    for _, obj in ipairs(MainFrame:GetDescendants()) do
        if _isInTopBar(obj) then continue end
        pcall(function()
            if obj:IsA("Frame") or obj:IsA("ScrollingFrame") then
                if obj:GetAttribute("_tb") == nil then obj:SetAttribute("_tb", obj.BackgroundTransparency) end
                local b = obj:GetAttribute("_tb")
                if b < 0.99 then
                    obj.BackgroundTransparency = math.clamp(b + add*(1-b), 0, 0.97)
                end
            end
        end)
    end
end

-- Slider row
local tSlRow = Instance.new("Frame", _tCF)
tSlRow.BackgroundColor3 = Color3.fromRGB(72,50,108); tSlRow.BorderSizePixel=0
tSlRow.Position = UDim2.new(0,10,0,_ty); tSlRow.Size = UDim2.new(1,-20,0,56); tSlRow.ZIndex=7
Instance.new("UICorner", tSlRow).CornerRadius = UDim.new(0,12)

local tSlLbl = Instance.new("TextLabel", tSlRow)
tSlLbl.BackgroundTransparency=1; tSlLbl.Position=UDim2.new(0,14,0,0); tSlLbl.Size=UDim2.new(0.45,0,1,0)
tSlLbl.Font=Enum.Font.GothamBold; tSlLbl.Text="🔲  Opacidade"
tSlLbl.TextColor3=Color3.fromRGB(215,205,235); tSlLbl.TextSize=11
tSlLbl.TextXAlignment=Enum.TextXAlignment.Left; tSlLbl.TextYAlignment=Enum.TextYAlignment.Center; tSlLbl.ZIndex=8

local tSlValLbl = Instance.new("TextLabel", tSlRow)
tSlValLbl.BackgroundTransparency=1; tSlValLbl.Position=UDim2.new(0.47,0,0.5,-10); tSlValLbl.Size=UDim2.new(0,42,0,20)
tSlValLbl.Font=Enum.Font.GothamBold; tSlValLbl.Text="0%"; tSlValLbl.TextColor3=Color3.fromRGB(215,205,235)
tSlValLbl.TextSize=12; tSlValLbl.TextXAlignment=Enum.TextXAlignment.Left; tSlValLbl.ZIndex=9

local tTrack = Instance.new("Frame", tSlRow)
tTrack.BackgroundColor3=Color3.fromRGB(90,68,124); tTrack.BorderSizePixel=0
tTrack.Position=UDim2.new(0.47,48,0.5,-2); tTrack.Size=UDim2.new(0.50,-58,0,4); tTrack.ZIndex=9
Instance.new("UICorner",tTrack).CornerRadius=UDim.new(1,0)

local tFill=Instance.new("Frame",tTrack); tFill.BackgroundColor3=TC; tFill.BorderSizePixel=0
tFill.Size=UDim2.new(0,0,1,0); tFill.ZIndex=10
Instance.new("UICorner",tFill).CornerRadius=UDim.new(1,0)
local tFG=Instance.new("UIGradient",tFill)
tFG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(100,70,180)),ColorSequenceKeypoint.new(1,Color3.fromRGB(190,150,255))})

local tKnob=Instance.new("Frame",tTrack); tKnob.BackgroundColor3=Color3.fromRGB(50,32,80); tKnob.BorderSizePixel=0
tKnob.AnchorPoint=Vector2.new(0.5,0.5); tKnob.Position=UDim2.new(0,0,0.5,0); tKnob.Size=UDim2.new(0,18,0,18); tKnob.ZIndex=11
Instance.new("UICorner",tKnob).CornerRadius=UDim.new(1,0)
local tKS=Instance.new("UIStroke",tKnob); tKS.Color=TC; tKS.Thickness=1.5; tKS.Transparency=0.3; tKS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

local tDrag=false
local function setTSlider(pct)
    pct=math.clamp(pct,0,100)
    local p=pct/100
    tFill.Size=UDim2.new(p,0,1,0); tKnob.Position=UDim2.new(p,0,0.5,0)
    tSlValLbl.Text=tostring(math.floor(pct)).."%"
    _applyTransp(pct)
end
local tSb=Instance.new("TextButton",tTrack); tSb.BackgroundTransparency=1
tSb.Size=UDim2.new(1,24,1,24); tSb.Position=UDim2.new(0,-12,0,-12); tSb.Text=""; tSb.ZIndex=12
tSb.MouseButton1Down:Connect(function()
    tDrag=true
    local ap=tTrack.AbsolutePosition; local as=tTrack.AbsoluteSize
    setTSlider(((UserInputService:GetMouseLocation().X-ap.X)/as.X)*100)
end)
UserInputService.InputChanged:Connect(function(i)
    if not tDrag then return end
    if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
    local ap=tTrack.AbsolutePosition; local as=tTrack.AbsoluteSize
    setTSlider(((i.Position.X-ap.X)/as.X)*100)
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then tDrag=false end
end)
end -- Transparência

end); if not _dbgOk_9512 then warn('[PudimHub DEBUG] Erro na secao PLAYER2/CONFIG: '..tostring(_dbgErr_9512)) end
local _dbgOk_10579, _dbgErr_10579 = pcall(function() -- [[ PLAYER3/CONFIG ]]


-- ══════════════════════════════════════════════════════════════
-- ESTILO DE INTERFACE — Configurações Tab
-- ══════════════════════════════════════════════════════════════
cfgMkSec("🎨  ESTILO DE INTERFACE", Color3.fromRGB(255,160,80))
do
local EST_COR = Color3.fromRGB(255,160,80)

-- ── Estado global de estilo ───────────────────────────────────
local _themeAccent   = Color3.fromRGB(105,78,158)  -- padrão roxo
local _textColorOver = nil    -- nil = padrão
local _textSizeOff   = 0      -- offset aplicado ao TextSize base
local _borderNeon    = false
local _rounded       = false
local _rgbActive     = false
local _rgbConn       = nil

-- ── Helpers internos ─────────────────────────────────────────
local function _isInTopBar(obj)
    local p = obj.Parent
    while p and p ~= MainFrame do
        if p == TopBar then return true end
        p = p.Parent
    end
    return false
end

-- ── TEMA — 18 cores únicas + padrão ──────────────────────────
local TEMAS = {
    { name="🍮 Padrão",    hue=Color3.fromRGB(105, 78,158) },
    { name="🔴 Carmim",    hue=Color3.fromRGB(210, 25, 55) },
    { name="🟠 Laranja",   hue=Color3.fromRGB(230, 90, 15) },
    { name="🟡 Âmbar",    hue=Color3.fromRGB(220,170,  0) },
    { name="🟢 Esmeralda", hue=Color3.fromRGB(  0,200, 90) },
    { name="🌿 Floresta",  hue=Color3.fromRGB( 15,140, 60) },
    { name="🩵 Ciano",     hue=Color3.fromRGB(  0,210,230) },
    { name="🔵 Safira",    hue=Color3.fromRGB( 20, 80,230) },
    { name="🟣 Violeta",   hue=Color3.fromRGB(140, 30,220) },
    { name="🩷 Magenta",   hue=Color3.fromRGB(230, 20,155) },
    { name="⚪ Prata",     hue=Color3.fromRGB(170,170,195) },
    { name="⚫ Obsidiana", hue=Color3.fromRGB( 28, 18, 50) },
    { name="🔥 Inferno",   hue=Color3.fromRGB(255, 50,  0) },
    { name="🌊 Oceano",    hue=Color3.fromRGB(  0,145,210) },
    { name="🌸 Sakura",    hue=Color3.fromRGB(255,100,165) },
    { name="☣️ Tóxico",    hue=Color3.fromRGB( 90,255, 55) },
    { name="🌙 Noite",     hue=Color3.fromRGB( 18,  8, 60) },
    { name="🍇 Uva",       hue=Color3.fromRGB(110,  0,190) },
    { name="☀️ Solar",     hue=Color3.fromRGB(255,210, 30) },
}

local function _applyTheme(accent)
    _themeAccent = accent
    pcall(function() MainStroke.Color = accent end)
    for _, obj in ipairs(MainFrame:GetDescendants()) do
        pcall(function()
            if obj:IsA("UIStroke") and not _isInTopBar(obj) then
                obj.Color = accent
            end
        end)
    end
end

-- ── COR DE ESCRITA — 16 cores ─────────────────────────────────
local TEXT_COLORS = {
    { name="↩️ Padrão",   col=nil },
    { name="⬜ Branco",   col=Color3.fromRGB(255,255,255) },
    { name="🟡 Amarelo",  col=Color3.fromRGB(255,230,  0) },
    { name="🟢 Verde",    col=Color3.fromRGB( 60,255,130) },
    { name="🔵 Azul",     col=Color3.fromRGB( 80,165,255) },
    { name="🔴 Vermelho", col=Color3.fromRGB(255, 75, 75) },
    { name="🟣 Roxo",     col=Color3.fromRGB(205,115,255) },
    { name="🩷 Rosa",     col=Color3.fromRGB(255,115,185) },
    { name="🟠 Laranja",  col=Color3.fromRGB(255,148, 30) },
    { name="🩵 Ciano",    col=Color3.fromRGB(  0,235,245) },
    { name="🤍 Gelo",     col=Color3.fromRGB(200,218,255) },
    { name="☀️ Ouro",     col=Color3.fromRGB(255,200,  0) },
    { name="🌿 Lima",     col=Color3.fromRGB(160,255, 55) },
    { name="🌸 Lilás",    col=Color3.fromRGB(225,170,255) },
    { name="🔥 Coral",    col=Color3.fromRGB(255, 90, 55) },
    { name="🌊 Índigo",   col=Color3.fromRGB( 80,100,255) },
}

local _textColEntries = {}
local _textColCollected = false
local function _collectTextCols()
    if _textColCollected then return end
    _textColCollected = true
    for _, obj in ipairs(ScreenGui:GetDescendants()) do
        pcall(function()
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if obj == TitleLabel then return end
                if _isInTopBar(obj) then return end
                table.insert(_textColEntries, {obj=obj, col=obj.TextColor3})
            end
        end)
    end
end
local function _applyTextColor(col)
    _collectTextCols()
    _textColorOver = col
    for _, e in ipairs(_textColEntries) do
        pcall(function()
            if e.obj and e.obj.Parent then e.obj.TextColor3 = col or e.col end
        end)
    end
end

-- ── TAMANHO DA LETRA ─────────────────────────────────────────
local _szEntries = {}
local _szCollected = false
local function _collectSizes()
    if _szCollected then return end
    _szCollected = true
    for _, obj in ipairs(ScreenGui:GetDescendants()) do
        pcall(function()
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if obj == TitleLabel then return end
                if _isInTopBar(obj) then return end
                table.insert(_szEntries, {obj=obj, sz=obj.TextSize})
            end
        end)
    end
end
local function _applyTextSize(offset)
    _collectSizes()
    _textSizeOff = offset
    for _, e in ipairs(_szEntries) do
        pcall(function()
            if e.obj and e.obj.Parent then
                e.obj.TextSize = math.clamp(e.sz + offset, 6, 38)
            end
        end)
    end
end

-- ── BORDAS NEON ───────────────────────────────────────────────
local _neonEntries = {} -- {stroke, created, origThick, origTransp}
local function _applyBorderNeon(en)
    if en then
        for _, obj in ipairs(MainFrame:GetDescendants()) do
            pcall(function()
                if _isInTopBar(obj) then return end
                if not (obj:IsA("Frame") or obj:IsA("ScrollingFrame")) then return end
                if obj.BackgroundTransparency >= 0.98 then return end
                local uc = obj:FindFirstChildOfClass("UICorner")
                if not uc or uc.CornerRadius == UDim.new(0,0) then return end
                local existing = obj:FindFirstChildOfClass("UIStroke")
                if existing then
                    table.insert(_neonEntries, {stroke=existing, created=false, origThick=existing.Thickness, origTransp=existing.Transparency})
                    TweenService:Create(existing, TweenInfo.new(0.3), {Thickness=2.5, Transparency=0}):Play()
                    existing.Color = _themeAccent
                else
                    local ns = Instance.new("UIStroke", obj)
                    ns.Color = _themeAccent; ns.Thickness = 2.5
                    ns.Transparency = 0; ns.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    -- Adiciona brilho animado
                    table.insert(_neonEntries, {stroke=ns, created=true, origThick=0, origTransp=1})
                    task.spawn(function()
                        while ns.Parent and _borderNeon do
                            TweenService:Create(ns, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0.25}):Play()
                            task.wait(0.85)
                            TweenService:Create(ns, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0}):Play()
                            task.wait(0.85)
                        end
                    end)
                end
            end)
        end
    else
        for _, e in ipairs(_neonEntries) do
            pcall(function()
                if e.created then
                    e.stroke:Destroy()
                else
                    TweenService:Create(e.stroke, TweenInfo.new(0.2), {Thickness=e.origThick, Transparency=e.origTransp}):Play()
                end
            end)
        end
        _neonEntries = {}
    end
end

-- ── ARREDONDAR ────────────────────────────────────────────────
local _cornerEntries = {}
local function _applyRounded(en)
    if en then
        for _, obj in ipairs(MainFrame:GetDescendants()) do
            pcall(function()
                if _isInTopBar(obj) then return end
                if obj:IsA("UICorner") then
                    local orig = obj.CornerRadius
                    table.insert(_cornerEntries, {obj=obj, orig=orig})
                    TweenService:Create(obj, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {CornerRadius=UDim.new(0,20)}):Play()
                end
            end)
        end
        local mfUC = MainFrame:FindFirstChildOfClass("UICorner")
        if mfUC then TweenService:Create(mfUC, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {CornerRadius=UDim.new(0,26)}):Play() end
    else
        for _, e in ipairs(_cornerEntries) do
            pcall(function()
                if e.obj and e.obj.Parent then
                    TweenService:Create(e.obj, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {CornerRadius=e.orig}):Play()
                end
            end)
        end
        _cornerEntries = {}
        local mfUC = MainFrame:FindFirstChildOfClass("UICorner")
        if mfUC then TweenService:Create(mfUC, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {CornerRadius=UDim.new(0,14)}):Play() end
    end
end

-- ── BORDAS RGB ────────────────────────────────────────────────
local function _startRGB()
    if _rgbConn then _rgbConn:Disconnect(); _rgbConn=nil end
    _rgbConn = RunService.Heartbeat:Connect(function()
        local col = Color3.fromHSV((tick()*0.4) % 1, 1, 1)
        pcall(function() MainStroke.Color = col end)
        for _, obj in ipairs(MainFrame:GetDescendants()) do
            pcall(function()
                if obj:IsA("UIStroke") and not _isInTopBar(obj) then
                    obj.Color = col
                end
            end)
        end
    end)
end
local function _stopRGB()
    if _rgbConn then _rgbConn:Disconnect(); _rgbConn=nil end
    _applyTheme(_themeAccent)
end

-- ── DROPDOWN PROFISSIONAL ─────────────────────────────────────
local _activeDropdown = nil
local function _closeDropdown()
    if _activeDropdown then
        TweenService:Create(_activeDropdown, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size=UDim2.new(_activeDropdown.Size.X.Scale, _activeDropdown.Size.X.Offset, 0, 0),
             BackgroundTransparency=1}):Play()
        task.delay(0.20, function() pcall(function() _activeDropdown:Destroy() end) end)
        _activeDropdown = nil
    end
end

local function _openDropdown(btn, items, onSelect, cols)
    _closeDropdown()
    cols = cols or 3
    local ITEM_H = 38
    local rows = math.ceil(#items / cols)
    local totalH = rows * ITEM_H + 16
    local VP = workspace.CurrentCamera.ViewportSize
    local dropW = math.min(400, math.max(270, VP.X * 0.42))

    local drop = Instance.new("Frame", ScreenGui)
    drop.BackgroundColor3 = Color3.fromRGB(14, 8, 30)
    drop.BackgroundTransparency = 0
    drop.BorderSizePixel = 0; drop.ZIndex = 950
    drop.ClipsDescendants = true; drop.Size = UDim2.new(0, dropW, 0, 0)
    Instance.new("UICorner", drop).CornerRadius = UDim.new(0, 14)
    local dStroke = Instance.new("UIStroke", drop)
    dStroke.Color = _themeAccent; dStroke.Thickness = 2; dStroke.Transparency = 0.1
    dStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    -- Gradiente fundo
    local dGrad = Instance.new("UIGradient", drop)
    dGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(24,14,48)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10,5,22)),
    }); dGrad.Rotation = 135

    -- Header do dropdown
    local dHdr = Instance.new("Frame", drop)
    dHdr.BackgroundColor3 = Color3.fromRGB(36,20,68); dHdr.BorderSizePixel=0
    dHdr.Size = UDim2.new(1,0,0,30); dHdr.ZIndex=951
    Instance.new("UICorner", dHdr).CornerRadius = UDim.new(0,14)
    local dHdrFix = Instance.new("Frame", dHdr)
    dHdrFix.BackgroundColor3=Color3.fromRGB(36,20,68); dHdrFix.BorderSizePixel=0
    dHdrFix.Position=UDim2.new(0,0,0.5,0); dHdrFix.Size=UDim2.new(1,0,0.5,0); dHdrFix.ZIndex=951
    local dHdrLbl = Instance.new("TextLabel", dHdr)
    dHdrLbl.BackgroundTransparency=1; dHdrLbl.Size=UDim2.new(1,-10,1,0); dHdrLbl.Position=UDim2.new(0,12,0,0)
    dHdrLbl.Font=Enum.Font.GothamBlack; dHdrLbl.Text="▾  Selecionar"
    dHdrLbl.TextColor3=Color3.fromRGB(200,180,240); dHdrLbl.TextSize=10; dHdrLbl.ZIndex=952
    dHdrLbl.TextXAlignment=Enum.TextXAlignment.Left

    -- Posicionamento
    local bAP = btn.AbsolutePosition; local bAS = btn.AbsoluteSize
    local dropX = math.clamp(bAP.X, 8, VP.X - dropW - 8)
    local dropY = bAP.Y + bAS.Y + 5
    if dropY + totalH + 30 > VP.Y - 8 then dropY = bAP.Y - totalH - 30 - 5 end
    drop.Position = UDim2.new(0, dropX, 0, dropY)

    -- Animar abertura
    TweenService:Create(drop, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size=UDim2.new(0, dropW, 0, totalH+30)}):Play()

    -- Grid de itens
    for i, item in ipairs(items) do
        local row = math.floor((i-1)/cols)
        local col = (i-1) % cols
        local cell = Instance.new("TextButton", drop)
        cell.BackgroundColor3 = Color3.fromRGB(38,22,68)
        cell.BackgroundTransparency = 0.2; cell.BorderSizePixel=0
        cell.Position = UDim2.new(col/cols, 4, 0, 30 + row*ITEM_H + 6)
        cell.Size = UDim2.new(1/cols, -8, 0, ITEM_H-4)
        cell.Font = Enum.Font.GothamBold; cell.Text = item.name
        cell.TextColor3 = Color3.fromRGB(228,218,255); cell.TextSize=10
        cell.ZIndex=952; cell.AutoButtonColor=false
        cell.TextXAlignment = Enum.TextXAlignment.Left
        local cPad = Instance.new("UIPadding", cell)
        cPad.PaddingLeft = UDim.new(0,8); cPad.PaddingRight = UDim.new(0,26)
        Instance.new("UICorner", cell).CornerRadius = UDim.new(0,9)
        local cellS = Instance.new("UIStroke", cell)
        cellS.Color = Color3.fromRGB(80,50,120); cellS.Thickness=1; cellS.Transparency=0.6
        cellS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        -- Swatch de cor (canto direito)
        local swatchCol = item.hue or item.col
        if swatchCol then
            local sw = Instance.new("Frame", cell)
            sw.BackgroundColor3 = swatchCol; sw.BorderSizePixel=0
            sw.AnchorPoint = Vector2.new(1,0.5); sw.Position=UDim2.new(1,-6,0.5,0)
            sw.Size=UDim2.new(0,14,0,14); sw.ZIndex=953
            Instance.new("UICorner",sw).CornerRadius=UDim.new(1,0)
            local swS = Instance.new("UIStroke",sw)
            swS.Color=Color3.fromRGB(255,255,255); swS.Thickness=1; swS.Transparency=0.6
        end
        cell.MouseEnter:Connect(function()
            TweenService:Create(cell,TweenInfo.new(0.1),{BackgroundTransparency=0, BackgroundColor3=Color3.fromRGB(60,38,100)}):Play()
            TweenService:Create(cellS,TweenInfo.new(0.1),{Transparency=0, Color=_themeAccent}):Play()
        end)
        cell.MouseLeave:Connect(function()
            TweenService:Create(cell,TweenInfo.new(0.12),{BackgroundTransparency=0.2, BackgroundColor3=Color3.fromRGB(38,22,68)}):Play()
            TweenService:Create(cellS,TweenInfo.new(0.12),{Transparency=0.6, Color=Color3.fromRGB(80,50,120)}):Play()
        end)
        cell.MouseButton1Click:Connect(function()
            TweenService:Create(cell,TweenInfo.new(0.08),{Size=UDim2.new(1/cols,-12,0,ITEM_H-8)}):Play()
            task.delay(0.09, function() pcall(function()
                TweenService:Create(cell,TweenInfo.new(0.15,Enum.EasingStyle.Back),{Size=UDim2.new(1/cols,-8,0,ITEM_H-4)}):Play()
            end) end)
            onSelect(item, i); _closeDropdown()
        end)
    end

    -- Fechar ao clicar fora
    local _ccConn
    _ccConn = UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            task.wait() -- espera 1 frame
            local mp = UserInputService:GetMouseLocation()
            local dp = drop.AbsolutePosition; local ds = drop.AbsoluteSize
            if mp.X<dp.X or mp.X>dp.X+ds.X or mp.Y<dp.Y or mp.Y>dp.Y+ds.Y then
                _closeDropdown(); if _ccConn then _ccConn:Disconnect() end
            end
        end
    end)
    _activeDropdown = drop
end

-- ── ACCORDION: Estilo de Interface ───────────────────────────
local _ESTILO_H = 36+9 + 44+9 + 44+9 + 44+9 + 44+9 + 44+9 + 44 + 14
local _estCard, _estCF = makeAccordionCard(Pages["Configuracoes"], cfg2NextLO, {
    icon="🎨", title="Estilo de Interface", color=EST_COR,
    summary="Tema, tamanho de letra, bordas neon, arredondamento, cor e RGB.",
    contentH = _ESTILO_H,
})
local _ey = 36+8

-- ─── Helper: row com label + botão dropdown ──────────────────
local function _estBtnRow(yOff, icon_label, btnTxt, cor, onClick)
    local row=Instance.new("Frame",_estCF)
    row.BackgroundColor3=Color3.fromRGB(52,32,82); row.BorderSizePixel=0
    row.Position=UDim2.new(0,10,0,yOff); row.Size=UDim2.new(1,-20,0,38); row.ZIndex=7
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local rowS=Instance.new("UIStroke",row); rowS.Color=cor; rowS.Thickness=1.2; rowS.Transparency=0.65; rowS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local bar=Instance.new("Frame",row); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Size=UDim2.new(0,3,0,22); bar.Position=UDim2.new(0,0,0.5,-11); bar.ZIndex=8
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,2)
    local lbl=Instance.new("TextLabel",row); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,10,0,0); lbl.Size=UDim2.new(1,-100,1,0)
    lbl.Font=Enum.Font.GothamBold; lbl.Text=icon_label
    lbl.TextColor3=Color3.fromRGB(222,214,248); lbl.TextSize=10
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextYAlignment=Enum.TextYAlignment.Center; lbl.ZIndex=8
    local btn=Instance.new("TextButton",row)
    btn.BackgroundColor3=cor; btn.BackgroundTransparency=0.35; btn.BorderSizePixel=0
    btn.AnchorPoint=Vector2.new(1,0.5); btn.Position=UDim2.new(1,-8,0.5,0)
    btn.Size=UDim2.new(0,82,0,26); btn.Font=Enum.Font.GothamBold; btn.Text=btnTxt
    btn.TextColor3=Color3.fromRGB(255,255,255); btn.TextSize=9; btn.ZIndex=9; btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local bS=Instance.new("UIStroke",btn); bS.Color=cor; bS.Thickness=1.2; bS.Transparency=0.2; bS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0, Size=UDim2.new(0,86,0,28)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundTransparency=0.35, Size=UDim2.new(0,82,0,26)}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.07),{Size=UDim2.new(0,76,0,22)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12,Enum.EasingStyle.Back),{Size=UDim2.new(0,82,0,26)}):Play()
        onClick(btn)
    end)
    return btn
end

-- ─── Helper: slider compacto inline ─────────────────────────
local function _estSlider(yOff, icon_label, minV, maxV, defV, cor, onChange)
    local row=Instance.new("Frame",_estCF)
    row.BackgroundColor3=Color3.fromRGB(52,32,82); row.BorderSizePixel=0
    row.Position=UDim2.new(0,10,0,yOff); row.Size=UDim2.new(1,-20,0,38); row.ZIndex=7
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)
    local rowS=Instance.new("UIStroke",row); rowS.Color=cor; rowS.Thickness=1.2; rowS.Transparency=0.65; rowS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local bar=Instance.new("Frame",row); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Size=UDim2.new(0,3,0,22); bar.Position=UDim2.new(0,0,0.5,-11); bar.ZIndex=8
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,2)
    local lbl=Instance.new("TextLabel",row); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,10,0,0); lbl.Size=UDim2.new(0.36,0,1,0)
    lbl.Font=Enum.Font.GothamBold; lbl.Text=icon_label
    lbl.TextColor3=Color3.fromRGB(222,214,248); lbl.TextSize=10
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextYAlignment=Enum.TextYAlignment.Center; lbl.ZIndex=8
    local valLbl=Instance.new("TextLabel",row); valLbl.BackgroundTransparency=1
    valLbl.Position=UDim2.new(0.38,0,0.5,-10); valLbl.Size=UDim2.new(0,26,0,20)
    valLbl.Font=Enum.Font.GothamBlack; valLbl.Text=tostring(defV)
    valLbl.TextColor3=cor; valLbl.TextSize=12; valLbl.TextXAlignment=Enum.TextXAlignment.Center; valLbl.ZIndex=9
    local track=Instance.new("Frame",row); track.BackgroundColor3=Color3.fromRGB(88,62,120); track.BorderSizePixel=0
    track.Position=UDim2.new(0.38,32,0.5,-2); track.Size=UDim2.new(0.60,-42,0,4); track.ZIndex=9
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local defPct=(defV-minV)/(maxV-minV)
    local fill=Instance.new("Frame",track); fill.BackgroundColor3=cor; fill.BorderSizePixel=0
    fill.Size=UDim2.new(defPct,0,1,0); fill.ZIndex=10
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",track); knob.BackgroundColor3=Color3.fromRGB(50,32,80); knob.BorderSizePixel=0
    knob.AnchorPoint=Vector2.new(0.5,0.5); knob.Position=UDim2.new(defPct,0,0.5,0); knob.Size=UDim2.new(0,18,0,18); knob.ZIndex=11
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local kS=Instance.new("UIStroke",knob); kS.Color=cor; kS.Thickness=1.5; kS.Transparency=0.25; kS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local drag=false
    local function setV(pct)
        pct=math.clamp(pct,0,1)
        local v=math.floor(minV+(maxV-minV)*pct+0.5)
        fill.Size=UDim2.new(pct,0,1,0); knob.Position=UDim2.new(pct,0,0.5,0)
        valLbl.Text=tostring(v); pcall(onChange,v)
    end
    local sb=Instance.new("TextButton",track); sb.BackgroundTransparency=1
    sb.Size=UDim2.new(1,24,1,24); sb.Position=UDim2.new(0,-12,0,-12); sb.Text=""; sb.ZIndex=12
    sb.MouseButton1Down:Connect(function()
        drag=true
        local ap=track.AbsolutePosition; local as=track.AbsoluteSize
        setV((UserInputService:GetMouseLocation().X-ap.X)/as.X)
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local ap=track.AbsolutePosition; local as=track.AbsoluteSize
        setV((i.Position.X-ap.X)/as.X)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
end

-- ═════════════════════════════════════════════════════
-- 1. TEMA
-- ═════════════════════════════════════════════════════
_accDivLine(_estCF, _ey, EST_COR); _ey=_ey+9
_estBtnRow(_ey, "🎨  Tema", "▾  Tema", Color3.fromRGB(255,160,80), function(btn)
    _openDropdown(btn, TEMAS, function(item)
        _applyTheme(item.hue)
        Notify.send({type="custom",icon="🎨",accent=item.hue,title="Tema",msg="Tema "..item.name.." aplicado!",duration=3})
    end, 3)
end)
_ey=_ey+44

-- ═════════════════════════════════════════════════════
-- 2. TAMANHO DA LETRA  (slider 1–10, centro=5 = padrão)
-- ═════════════════════════════════════════════════════
_accDivLine(_estCF, _ey, EST_COR); _ey=_ey+9
_estSlider(_ey, "🔡  Letra", 1, 10, 5, Color3.fromRGB(100,200,255), function(v)
    _applyTextSize((v-5)*2)   -- 5→0, 1→-8, 10→+10
end)
_ey=_ey+44

-- ═════════════════════════════════════════════════════
-- 3. BORDAS NEON
-- ═════════════════════════════════════════════════════
_accDivLine(_estCF, _ey, EST_COR); _ey=_ey+9
_accToggle(_estCF, _ey, "✨  Bordas Neon", false, Color3.fromRGB(200,150,255), function(s)
    _borderNeon=s
    _applyBorderNeon(s)
    if s then Notify.success("✨ Bordas Neon","Brilho neon ativado nos accordions!")
    else Notify.info("✨ Bordas Neon","Desativado.") end
end)
_ey=_ey+44

-- ═════════════════════════════════════════════════════
-- 4. ARREDONDAR TUDO
-- ═════════════════════════════════════════════════════
_accDivLine(_estCF, _ey, EST_COR); _ey=_ey+9
_accToggle(_estCF, _ey, "⬜  Arredondar Tudo", false, Color3.fromRGB(150,220,255), function(s)
    _rounded=s
    _applyRounded(s)
    if s then Notify.success("⬜ Arredondar","Toda a interface arredondada!")
    else Notify.info("⬜ Arredondar","Bordas restauradas.") end
end)
_ey=_ey+44

-- ═════════════════════════════════════════════════════
-- 5. COR DE ESCRITA
-- ═════════════════════════════════════════════════════
_accDivLine(_estCF, _ey, EST_COR); _ey=_ey+9
_estBtnRow(_ey, "🖊️  Cor de Escrita", "▾  Cor", Color3.fromRGB(255,200,80), function(btn)
    _openDropdown(btn, TEXT_COLORS, function(item)
        _applyTextColor(item.col)
        local accent = item.col or Color3.fromRGB(255,248,255)
        Notify.send({type="custom",icon="🖊️",accent=accent,title="Cor de Escrita",msg=item.name.." aplicada!",duration=3})
    end, 4)
end)
_ey=_ey+44

-- ═════════════════════════════════════════════════════
-- 6. BORDAS RGB
-- ═════════════════════════════════════════════════════
_accDivLine(_estCF, _ey, EST_COR); _ey=_ey+9
_accToggle(_estCF, _ey, "🌈  Bordas RGB", false, Color3.fromRGB(255,100,200), function(s)
    _rgbActive=s
    if s then
        _startRGB()
        Notify.warn("🌈 Bordas RGB","Modo arco-íris ativado em todas as bordas!")
    else
        _stopRGB()
        Notify.info("🌈 Bordas RGB","Desativado — tema restaurado.")
    end
end)
_ey=_ey+44

end -- Estilo de Interface


-- ══════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES DAS NOTIFICAÇÕES — Posição, Duração, Estilo
-- ══════════════════════════════════════════════════════════════
cfgMkSec("🔔  CONFIGURAÇÕES DAS NOTIFICAÇÕES", Color3.fromRGB(100,200,255))
do
local NC = Color3.fromRGB(100,200,255)
local function nrgb(r,g,b) return Color3.fromRGB(r,g,b) end

-- Altura total do accordion:
-- header(36) + div(9) + grid posições(120) + div(9) + slider duração(62) + div(9) + grid estilos(100) + padding(14)
local _,_ncf = makeAccordionCard(Pages["Configuracoes"], cfg2NextLO, {
    icon="🔔", title="Configurações das Notificações", color=NC,
    summary="Posição na tela, duração e estilo visual das notificações.",
    contentH = 36+9+120+9+62+9+100+14,
})
local _ny = 36+8

-- ─── SEÇÃO: POSIÇÃO ──────────────────────────────────────────
_accDivLine(_ncf, _ny, NC); _ny = _ny+9

-- Label seção
local posSecLbl = Instance.new("TextLabel", _ncf)
posSecLbl.BackgroundTransparency=1
posSecLbl.Position=UDim2.new(0,12,0,_ny); posSecLbl.Size=UDim2.new(1,-24,0,16)
posSecLbl.Font=Enum.Font.GothamBold; posSecLbl.Text="📍  Posição na tela"
posSecLbl.TextColor3=NC; posSecLbl.TextSize=10
posSecLbl.TextXAlignment=Enum.TextXAlignment.Left; posSecLbl.ZIndex=7
_ny = _ny+18

-- Grid 3×3 de posições (8 botões + centro vazio)
-- Layout: TL  TC  TR
--         ML  ·   MR
--         BL  BC  BR
local POS_GRID = {
    {pos="TL", label="↖", row=0, col=0},
    {pos="TC", label="↑", row=0, col=1},
    {pos="TR", label="↗", row=0, col=2},
    {pos="ML", label="←", row=1, col=0},
    {pos=nil,  label="·", row=1, col=1}, -- centro vazio
    {pos="MR", label="→", row=1, col=2},
    {pos="BL", label="↙", row=2, col=0},
    {pos="BC", label="↓", row=2, col=1},
    {pos="BR", label="↘", row=2, col=2},
}
local CELL_W = 32; local CELL_H = 30; local CELL_GAP = 4
local gridTotalW = 3*CELL_W + 2*CELL_GAP
local gridOffX = math.floor(((_ncf.AbsoluteSize ~= Vector2.new(0,0)) and _ncf.AbsoluteSize.X or 320) / 2 - gridTotalW/2)
-- Fallback seguro de offset
local _gridX = 0.5  -- 50% da largura menos metade do grid

local posButtons = {}
local function _setPosActive(activePos)
    notifPosition = activePos
    nReflow()
    for _, pb in pairs(posButtons) do
        if pb.pos then
            local isActive = pb.pos == activePos
            TweenService:Create(pb.btn, TweenInfo.new(0.15), {
                BackgroundColor3 = isActive and NC or nrgb(40,28,62),
                BackgroundTransparency = isActive and 0.1 or 0.5,
            }):Play()
            TweenService:Create(pb.lbl, TweenInfo.new(0.15), {
                TextColor3 = isActive and nrgb(10,10,20) or nrgb(200,190,230),
                TextSize = isActive and 14 or 12,
            }):Play()
        end
    end
    Notify.info("🔔 Notificações", "Posição: "..activePos, 2)
end

for _, cell in ipairs(POS_GRID) do
    local btnFrame = Instance.new("Frame", _ncf)
    btnFrame.BackgroundTransparency = 1; btnFrame.BorderSizePixel = 0
    -- Posição: centraliza o grid horizontalmente
    local offX = cell.col * (CELL_W + CELL_GAP)
    local offY = cell.row * (CELL_H + CELL_GAP)
    btnFrame.Position = UDim2.new(0.5, -math.floor(gridTotalW/2) + offX, 0, _ny + offY)
    btnFrame.Size = UDim2.new(0, CELL_W, 0, CELL_H)
    btnFrame.ZIndex = 7

    if cell.pos == nil then
        -- Centro: ícone de "hub"
        local cLbl = Instance.new("TextLabel", btnFrame)
        cLbl.BackgroundTransparency=1; cLbl.Size=UDim2.new(1,0,1,0)
        cLbl.Font=Enum.Font.GothamBlack; cLbl.Text="HUB"
        cLbl.TextColor3=nrgb(80,60,110); cLbl.TextSize=8; cLbl.ZIndex=8
    else
        local isActive = notifPosition == cell.pos
        local btn = Instance.new("TextButton", btnFrame)
        btn.BackgroundColor3 = isActive and NC or nrgb(40,28,62)
        btn.BackgroundTransparency = isActive and 0.1 or 0.5
        btn.BorderSizePixel=0; btn.Size=UDim2.new(1,0,1,0); btn.ZIndex=8
        btn.AutoButtonColor=false; btn.Text=""
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
        local bStroke=Instance.new("UIStroke",btn)
        bStroke.Color=NC; bStroke.Thickness=1.2; bStroke.Transparency=0.5
        bStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        local lbl = Instance.new("TextLabel", btn)
        lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,0,1,0)
        lbl.Font=Enum.Font.GothamBlack
        lbl.Text=cell.label
        lbl.TextColor3 = isActive and nrgb(10,10,20) or nrgb(200,190,230)
        lbl.TextSize = isActive and 14 or 12; lbl.ZIndex=9
        btn.MouseEnter:Connect(function()
            if notifPosition~=cell.pos then
                TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.25}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if notifPosition~=cell.pos then
                TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundTransparency=0.5}):Play()
            end
        end)
        btn.MouseButton1Click:Connect(function() _setPosActive(cell.pos) end)
        table.insert(posButtons, {pos=cell.pos, btn=btn, lbl=lbl})
    end
end
_ny = _ny + 3*CELL_H + 2*CELL_GAP + 6

-- ─── SEÇÃO: DURAÇÃO ──────────────────────────────────────────
_accDivLine(_ncf, _ny, NC); _ny = _ny+9

local durRow = Instance.new("Frame", _ncf)
durRow.BackgroundColor3=nrgb(52,34,82); durRow.BorderSizePixel=0
durRow.Position=UDim2.new(0,10,0,_ny); durRow.Size=UDim2.new(1,-20,0,56); durRow.ZIndex=7
Instance.new("UICorner",durRow).CornerRadius=UDim.new(0,12)

local durLbl = Instance.new("TextLabel",durRow)
durLbl.BackgroundTransparency=1; durLbl.Position=UDim2.new(0,14,0,0); durLbl.Size=UDim2.new(0.45,0,1,0)
durLbl.Font=Enum.Font.GothamBold; durLbl.Text="⏱️  Duração"
durLbl.TextColor3=nrgb(215,205,235); durLbl.TextSize=11
durLbl.TextXAlignment=Enum.TextXAlignment.Left; durLbl.TextYAlignment=Enum.TextYAlignment.Center; durLbl.ZIndex=8

local durValLbl = Instance.new("TextLabel",durRow)
durValLbl.BackgroundTransparency=1; durValLbl.Position=UDim2.new(0.47,0,0.5,-10); durValLbl.Size=UDim2.new(0,40,0,20)
durValLbl.Font=Enum.Font.GothamBlack
durValLbl.Text=string.format("%.1fs", NOTIF_CFG.DEFAULT_DURATION)
durValLbl.TextColor3=NC; durValLbl.TextSize=12
durValLbl.TextXAlignment=Enum.TextXAlignment.Left; durValLbl.ZIndex=9

local durTrack=Instance.new("Frame",durRow)
durTrack.BackgroundColor3=nrgb(80,58,112); durTrack.BorderSizePixel=0
durTrack.Position=UDim2.new(0.47,46,0.5,-2); durTrack.Size=UDim2.new(0.50,-56,0,4); durTrack.ZIndex=9
Instance.new("UICorner",durTrack).CornerRadius=UDim.new(1,0)

local durPct0 = (NOTIF_CFG.DEFAULT_DURATION - 1) / 9  -- range 1-10
local durFill=Instance.new("Frame",durTrack); durFill.BackgroundColor3=NC; durFill.BorderSizePixel=0
durFill.Size=UDim2.new(durPct0,0,1,0); durFill.ZIndex=10
Instance.new("UICorner",durFill).CornerRadius=UDim.new(1,0)
local durFG=Instance.new("UIGradient",durFill)
durFG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,nrgb(40,140,220)),ColorSequenceKeypoint.new(1,nrgb(120,220,255))})

local durKnob=Instance.new("Frame",durTrack)
durKnob.BackgroundColor3=nrgb(50,32,80); durKnob.BorderSizePixel=0
durKnob.AnchorPoint=Vector2.new(0.5,0.5); durKnob.Position=UDim2.new(durPct0,0,0.5,0)
durKnob.Size=UDim2.new(0,18,0,18); durKnob.ZIndex=11
Instance.new("UICorner",durKnob).CornerRadius=UDim.new(1,0)
local durKS=Instance.new("UIStroke",durKnob); durKS.Color=NC; durKS.Thickness=1.5; durKS.Transparency=0.3; durKS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

local durDrag=false
local function setDur(pct)
    pct=math.clamp(pct,0,1)
    local v=math.floor(1+(9*pct)*10+0.5)/10  -- 1.0 a 10.0 com 1 casa
    v=math.clamp(v,1,10)
    NOTIF_CFG.DEFAULT_DURATION=v
    durFill.Size=UDim2.new(pct,0,1,0); durKnob.Position=UDim2.new(pct,0,0.5,0)
    durValLbl.Text=string.format("%.1fs",v)
end
local durSb=Instance.new("TextButton",durTrack); durSb.BackgroundTransparency=1
durSb.Size=UDim2.new(1,24,1,24); durSb.Position=UDim2.new(0,-12,0,-12); durSb.Text=""; durSb.ZIndex=12
durSb.MouseButton1Down:Connect(function()
    durDrag=true
    local ap=durTrack.AbsolutePosition; local as=durTrack.AbsoluteSize
    setDur((UserInputService:GetMouseLocation().X-ap.X)/as.X)
end)
UserInputService.InputChanged:Connect(function(inp)
    if not durDrag then return end
    if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
    local ap=durTrack.AbsolutePosition; local as=durTrack.AbsoluteSize
    setDur((inp.Position.X-ap.X)/as.X)
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 then durDrag=false end
end)
_ny = _ny+62

-- ─── SEÇÃO: ESTILO VISUAL ─────────────────────────────────────
_accDivLine(_ncf, _ny, NC); _ny = _ny+9

local stySecLbl = Instance.new("TextLabel", _ncf)
stySecLbl.BackgroundTransparency=1
stySecLbl.Position=UDim2.new(0,12,0,_ny); stySecLbl.Size=UDim2.new(1,-24,0,16)
stySecLbl.Font=Enum.Font.GothamBold; stySecLbl.Text="🎨  Estilo visual"
stySecLbl.TextColor3=NC; stySecLbl.TextSize=10
stySecLbl.TextXAlignment=Enum.TextXAlignment.Left; stySecLbl.ZIndex=7
_ny = _ny+18

local ESTILOS = {
    { key="card",   label="Card",   icon="🃏", desc="Padrão — card com borda e ícone" },
    { key="pill",   label="Pill",   icon="💊", desc="Compacto e arredondado" },
    { key="banner", label="Banner", icon="📢", desc="Largo, estilo banner" },
    { key="toast",  label="Toast",  icon="🍞", desc="Minimalista, discreto" },
}

local STY_BTN_W = 68; local STY_BTN_H = 34; local STY_GAP = 6
local styButtons = {}

local function _setStyActive(activeKey)
    NOTIF_CFG.STYLE = activeKey
    for _, sb in ipairs(styButtons) do
        local isA = sb.key == activeKey
        TweenService:Create(sb.btn,TweenInfo.new(0.15),{
            BackgroundColor3 = isA and NC or nrgb(40,28,62),
            BackgroundTransparency = isA and 0.1 or 0.45,
        }):Play()
        TweenService:Create(sb.lbl,TweenInfo.new(0.15),{
            TextColor3 = isA and nrgb(10,10,20) or nrgb(200,190,230),
        }):Play()
    end
    -- Preview da notificação com o estilo selecionado
    local styInfo = {card="🃏 Card ativado",pill="💊 Pill ativado",banner="📢 Banner ativado",toast="🍞 Toast ativado"}
    Notify.info("🎨 Estilo", styInfo[activeKey] or activeKey, 2.5)
end

local totalStyW = #ESTILOS * STY_BTN_W + (#ESTILOS-1) * STY_GAP
for i, sty in ipairs(ESTILOS) do
    local offX = (i-1)*(STY_BTN_W+STY_GAP)
    local sbf = Instance.new("Frame", _ncf)
    sbf.BackgroundTransparency=1; sbf.BorderSizePixel=0
    sbf.Position=UDim2.new(0.5,-math.floor(totalStyW/2)+offX,0,_ny)
    sbf.Size=UDim2.new(0,STY_BTN_W,0,STY_BTN_H); sbf.ZIndex=7
    local isA = NOTIF_CFG.STYLE == sty.key
    local sbtn = Instance.new("TextButton",sbf)
    sbtn.BackgroundColor3 = isA and NC or nrgb(40,28,62)
    sbtn.BackgroundTransparency = isA and 0.1 or 0.45
    sbtn.BorderSizePixel=0; sbtn.Size=UDim2.new(1,0,1,0); sbtn.ZIndex=8
    sbtn.AutoButtonColor=false; sbtn.Text=""
    Instance.new("UICorner",sbtn).CornerRadius=UDim.new(0,9)
    local sbS=Instance.new("UIStroke",sbtn); sbS.Color=NC; sbS.Thickness=1.2; sbS.Transparency=0.5; sbS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    -- Ícone
    local sibLbl=Instance.new("TextLabel",sbtn); sibLbl.BackgroundTransparency=1
    sibLbl.Position=UDim2.new(0,0,0,2); sibLbl.Size=UDim2.new(1,0,0,18)
    sibLbl.Font=Enum.Font.GothamBold; sibLbl.Text=sty.icon
    sibLbl.TextColor3=nrgb(200,190,230); sibLbl.TextSize=14; sibLbl.ZIndex=9
    -- Label
    local slbl=Instance.new("TextLabel",sbtn); slbl.BackgroundTransparency=1
    slbl.Position=UDim2.new(0,0,0,18); slbl.Size=UDim2.new(1,0,0,14)
    slbl.Font=Enum.Font.GothamBold; slbl.Text=sty.label
    slbl.TextColor3 = isA and nrgb(10,10,20) or nrgb(200,190,230)
    slbl.TextSize=9; slbl.ZIndex=9
    sbtn.MouseEnter:Connect(function()
        if NOTIF_CFG.STYLE~=sty.key then TweenService:Create(sbtn,TweenInfo.new(0.1),{BackgroundTransparency=0.25}):Play() end
    end)
    sbtn.MouseLeave:Connect(function()
        if NOTIF_CFG.STYLE~=sty.key then TweenService:Create(sbtn,TweenInfo.new(0.12),{BackgroundTransparency=0.45}):Play() end
    end)
    sbtn.MouseButton1Click:Connect(function() _setStyActive(sty.key) end)
    table.insert(styButtons, {key=sty.key, btn=sbtn, lbl=slbl})
end

end -- Configurações das Notificações
-- ══════════════════════════════════════════════════════════════
-- Fluxo:
--   1. Encontra todos os baús no workspace
--   2. Dispara RequestOpenItemChest em cada um (igual ao ACS)
--   3. Aguarda 2.5s o servidor spawnar os itens
--   4. Varre o workspace coletando todos os itens soltos conhecidos
--   5. Teleporta cada item para 120 studs acima da fogueira → caem
-- ══════════════════════════════════════════════════════════════
do
local PIB_COR = Color3.fromRGB(255, 200, 80)

-- Lookup de todos os nomes de itens conhecidos
local PIB_ITEMS_LOOKUP = {}
for _, c in ipairs(BRING_CATS) do
    for _, n in ipairs(c.nomes) do
        PIB_ITEMS_LOOKUP[n:lower()] = true
    end
end

local pibRunning = false

-- Função que lança um conjunto de itens do céu na fogueira
local function pibLancarDoSky(encontrados, campPos)
    local ALTURA = 120
    local RAIO   = 14
    local total  = #encontrados

    for i, entry in ipairs(encontrados) do
        pcall(function()
            local part = entry.part
            local obj  = entry.obj
            if not part or not part.Parent then return end

            local angle  = (i / math.max(total, 1)) * math.pi * 2 + math.random() * 0.6
            local dist   = 1 + math.random() * RAIO
            local skyPos = Vector3.new(
                campPos.X + math.cos(angle) * dist,
                campPos.Y + ALTURA,
                campPos.Z + math.sin(angle) * dist)

            -- Desativa scripts do item
            for _, s in ipairs(obj:GetDescendants()) do
                if s:IsA("Script") or s:IsA("LocalScript") then
                    pcall(function() s.Disabled = true end)
                end
            end

            -- Lança do céu totalmente solto
            pcall(function() part.Anchored = false end)
            part.CanCollide  = true
            part.CFrame      = CFrame.new(skyPos)
            pcall(function()
                part.AssemblyLinearVelocity  = Vector3.new((math.random()-0.5)*4, 0, (math.random()-0.5)*4)
                part.AssemblyAngularVelocity = Vector3.new((math.random()-0.5)*2,(math.random()-0.5)*2,(math.random()-0.5)*2)
            end)
            pcall(function() part.Velocity = Vector3.new((math.random()-0.5)*4, 0, (math.random()-0.5)*4) end)

            -- Multi-parte: move o Model inteiro junto
            if obj:IsA("Model") then
                local offset = skyPos - part.Position
                for _, bp in ipairs(obj:GetDescendants()) do
                    if bp:IsA("BasePart") and bp ~= part then
                        pcall(function()
                            bp.Anchored   = false
                            bp.CanCollide = true
                            bp.CFrame     = CFrame.new(bp.Position + offset)
                            pcall(function() bp.AssemblyLinearVelocity = part.AssemblyLinearVelocity end)
                        end)
                    end
                end
            end
        end)

        if i % 20 == 0 then task.wait(0.04) end
    end
end

-- Função que coleta itens soltos no workspace
local function pibColetarItens(pchars)
    local encontrados = {}
    local alreadySeen = {}
    local ok, descs = pcall(function() return workspace:GetDescendants() end)
    if not ok then return encontrados end

    for _, obj in ipairs(descs) do
        pcall(function()
            if not obj or not obj.Parent then return end

            local targetPart = nil
            local checkName  = nil

            if obj:IsA("BasePart") then
                local pm = obj.Parent
                -- Ignora parts dentro de Models (o Model é processado como unidade)
                if pm and pm:IsA("Model") and not pm:FindFirstChildWhichIsA("Humanoid") then return end
                targetPart = obj
                checkName  = obj.Name:lower()
            elseif obj:IsA("Model") and not obj:FindFirstChildWhichIsA("Humanoid") then
                if alreadySeen[obj] then return end
                local p2 = obj:FindFirstChildWhichIsA("BasePart")
                if not p2 then return end
                targetPart = p2
                checkName  = obj.Name:lower()
                alreadySeen[obj] = true
            else
                return
            end

            if not targetPart or not checkName then return end

            -- Bloqueia personagens de jogadores
            for pc in pairs(pchars) do
                if pc == obj or pc:IsAncestorOf(obj) then return end
            end
            -- Bloqueia NPCs na hierarquia
            local p = obj.Parent
            for _ = 1, 4 do
                if p and p:IsA("Model") and p:FindFirstChildWhichIsA("Humanoid") then return end
                p = p and p.Parent
            end
            -- Só itens conhecidos
            if not PIB_ITEMS_LOOKUP[checkName] then return end
            -- Descarta peças grandes (construções/terreno)
            local sz = targetPart.Size
            if sz.X > 18 or sz.Y > 18 or sz.Z > 18 then return end

            table.insert(encontrados, {obj=obj, part=targetPart})
        end)
    end
    return encontrados
end

local function pegarItensBaus(statusLbl)
    if pibRunning then return end
    pibRunning = true

    local campPos = getCampfirePos() or Vector3.new(0, 5, 0)
    local pchars  = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character then pchars[pl.Character] = true end
    end

    -- Coleta todos os itens soltos no mundo
    if statusLbl then statusLbl.Text = "🔍 Buscando itens..." end
    local encontrados = pibColetarItens(pchars)

    if #encontrados == 0 then
        Notify.warn("🎁 Pegar Itens Baús", "Nenhum item solto encontrado. Abra os baús primeiro com o ACS!", 4)
        if statusLbl then statusLbl.Text = "Nenhum item solto" end
        pibRunning = false
        return
    end

    -- Lança do céu na fogueira
    if statusLbl then statusLbl.Text = string.format("☁️ %d itens caindo...", #encontrados) end

    Notify.send({type="custom", icon="🎁", accent=PIB_COR,
        title="Pegar Itens Baús",
        msg=string.format("Lançando %d item(s) do céu na fogueira!", #encontrados),
        duration=4})

    pibLancarDoSky(encontrados, campPos)

    Notify.send({type="custom", icon="✅", accent=Color3.fromRGB(87,242,135),
        title="Pegar Itens Baús — Concluído!",
        msg=string.format("%d item(s) caindo perto da fogueira!", #encontrados),
        duration=5})

    if statusLbl then statusLbl.Text = "✓ Concluído!" end
    task.wait(2)
    if statusLbl then statusLbl.Text = "" end

    pibRunning = false
end

-- ── UI ────────────────────────────────────────────────────────
-- ── Pegar Itens Baús (PIB) — Accordion ──────────────────────
do
local PIB_COR2 = Color3.fromRGB(255, 200, 80)
local _pibCard,_pibCF=makeAccordionCard(Pages["Player"],plNextLO,{icon="🎒",title="Pegar Itens Baús",summary="Coleta automaticamente todos os itens soltos ao redor dos baús.",color=PIB_COR2,contentH=36+9+32+14})
local _py=36+8; _accDivLine(_pibCF,_py,PIB_COR2); _py=_py+9
local _pBtn,_=_accActivBtn(_pibCF,_py,"🎒",PIB_COR2); _py=_py+40
local _pSt=_accStatusLbl(_pibCF,_py)
pibCard=_pibCard
_pBtn.MouseButton1Click:Connect(function()
    if pibRunning then return end
    _pBtn.Text="⏳ Aguarda..."
    TweenService:Create(_pBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.4}):Play()
    task.spawn(function()
        pegarItensBaus(_pSt)
        _pBtn.Text="🎒  PEGAR"
        TweenService:Create(_pBtn,TweenInfo.new(0.2),{BackgroundTransparency=0.1}):Play()
    end)
end)
end -- Pegar Itens Baús
end -- do (escopo Pegar Itens Baús)

-- ══════════════════════════════════════════════════════
-- AUTO FOGUEIRA ANOITECER
-- ══════════════════════════════════════════════════════
do
local NIGHT_COR2 = Color3.fromRGB(120,80,255)
local nightAutoEnabled  = false
local nightAlreadyTped  = false  -- evita TP repetido na mesma noite
local nightConn         = nil

-- Função de teleporte para a fogueira
local function doNightTp()
    local pos = getCampfirePos()
    if pos then
        safeTp(pos, 4)
        Notify.send({type="custom",icon="🌙",accent=NIGHT_COR2,
            title="🌙 Auto Fogueira",msg="Noite caiu — teleportado para a fogueira!",duration=4})
    else
        Notify.warn("🌙 Auto Fogueira","⚠️ Fogueira não encontrada no workspace!")
    end
end

-- Loop de monitoramento da noite
local function startNightWatch()
    if nightConn then nightConn:Disconnect(); nightConn = nil end
    nightAlreadyTped = false
    local lastCheckDay = false  -- era dia no tick anterior
    nightConn = RunService.Heartbeat:Connect(function()
        if not nightAutoEnabled then
            if nightConn then nightConn:Disconnect(); nightConn = nil end
            return
        end
        pcall(function()
            local hr = game:GetService("Lighting").ClockTime
            local isNight = (hr >= 18 or hr < 6)
            -- Detecta transição dia→noite
            if isNight and lastCheckDay and not nightAlreadyTped then
                nightAlreadyTped = true
                doNightTp()
            end
            -- Reseta flag quando volta a ser dia
            if not isNight then
                nightAlreadyTped = false
            end
            lastCheckDay = not isNight
        end)
    end)
end

local _nightCard,_nightCF=makeAccordionCard(Pages["Player"],plNextLO,{icon="🌙",title="Auto Fogueira Anoitecer",summary="Teleporta para a fogueira automaticamente quando a noite cair.",color=NIGHT_COR2,contentH=36+9+44+14})
local _ny=36+8; _accDivLine(_nightCF,_ny,NIGHT_COR2); _ny=_ny+9
_accToggle(_nightCF,_ny,"🌙  Auto Fogueira Anoitecer",false,NIGHT_COR2,function(s)
    nightAutoEnabled = s
    if s then
        startNightWatch()
        Notify.success("🌙 Auto Fogueira","Ativado — teleportará ao anoitecer!")
    else
        if nightConn then nightConn:Disconnect(); nightConn = nil end
        Notify.info("🌙 Auto Fogueira","Desativado.")
    end
end)
end -- Auto Fogueira Anoitecer

-- ══════════════════════════════════════════════════════
-- AUTO COMER — Accordion Card (Player Tab)
-- ══════════════════════════════════════════════════════
do
local ATE_COR_P = Color3.fromRGB(90,210,255)

-- Lista de alimentos
local EAT_NAMES = {}
do
    local foods = {
        "cooked morsel","cooked steak","cooked ribs","cooked turkey leg",
        "cooked mackerel","cooked salmon","cooked clownfish","cooked char",
        "cooked eel","cooked swordfish","cooked shark","cooked lava eel","cooked lionfish",
        "berry","carrot","apple","mushroom","truffle",
        "energy drink","energydrink","potion","health potion",
    }
    for _, n in ipairs(foods) do EAT_NAMES[n] = true end
end

local eatRunning   = false
local eatThreshold = 25
local eatConn      = nil
local eatRef       = {}

local function getHungerPct()
    local pct = nil
    pcall(function()
        local ch = Players.LocalPlayer.Character; if not ch then return end
        local v = ch:GetAttribute("Hunger") or ch:GetAttribute("Food")
                 or ch:GetAttribute("Satiation") or ch:GetAttribute("Fullness")
        if type(v)=="number" and v>=0 and v<=100 then pct=v; return end
        local names={"Hunger","Food","Satiation","Fullness","FoodLevel","HungerLevel","Satiety"}
        for _, nm in ipairs(names) do
            local c=ch:FindFirstChild(nm,true)
            if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then
                local maxV=100
                local mc=ch:FindFirstChild("MaxHunger",true) or ch:FindFirstChild("MaxFood",true)
                if mc then maxV=math.max(mc.Value,1) end
                pct=math.clamp(math.floor((c.Value/maxV)*100),0,100); return
            end
        end
    end)
    return pct
end

local function eatOneFood()
    local remConsume=nil
    pcall(function()
        remConsume=game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents",3):WaitForChild("RequestConsumeItem",3)
    end)
    if not remConsume then return false end
    local itemsF=_getItemsFolder()
    local avail={}
    if itemsF then
        for _,item in ipairs(itemsF:GetChildren()) do
            if EAT_NAMES[item.Name:lower()] then table.insert(avail,item) end
        end
    end
    -- Also check workspace descendants as fallback
    if #avail==0 then
        pcall(function()
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj and obj.Parent and EAT_NAMES[obj.Name:lower()] then
                    table.insert(avail,obj); if #avail>=5 then break end
                end
            end
        end)
    end
    if #avail==0 then return false end
    local e=avail[math.random(1,#avail)]
    pcall(function()
        if remConsume:IsA("RemoteFunction") then remConsume:InvokeServer(e)
        else remConsume:FireServer(e) end
    end)
    return true
end

local function startAutoEat()
    if eatConn then eatConn:Disconnect(); eatConn=nil end
    eatRunning=true
    local lastEat=0
    eatConn=RunService.Heartbeat:Connect(function()
        if not eatRunning then eatConn:Disconnect(); eatConn=nil; return end
        if tick()-lastEat < 1.5 then return end
        local pct=getHungerPct()
        if pct==nil then
            pcall(function() if eatRef.status then eatRef.status.Text="🍖 Detectando fome..." end end)
            return
        end
        pcall(function() if eatRef.status then eatRef.status.Text=string.format("🍖 Fome: %d%% / limite: %d%%",pct,eatThreshold) end end)
        if pct<=eatThreshold then
            lastEat=tick()
            local ok=eatOneFood()
            if ok then pcall(function() if eatRef.status then eatRef.status.Text=string.format("🍖 Comendo! (%d%%)",pct) end end) end
        end
    end)
end

local function stopAutoEat()
    eatRunning=false
    if eatConn then eatConn:Disconnect(); eatConn=nil end
end

-- ── UI: Accordion Card ───────────────────────────────
local _eatCard, _eatCF, _eatDrop = makeAccordionCard(Pages["Player"], plNextLO, {
    icon    = "🍖",
    title   = "Auto Comer",
    summary = "Come automaticamente quando a fome cair abaixo do % configurado.",
    color   = ATE_COR_P,
    contentH = 36+9+50+9+32+14,
})
eatCard = _eatCard

local _y = 36+8
_accDivLine(_eatCF, _y, ATE_COR_P); _y = _y+9

-- Slider threshold
local EAT_STEPS={5,15,25,35,45,55,65,75,85,95}
local EAT_MIN=EAT_STEPS[1]; local EAT_MAX=EAT_STEPS[#EAT_STEPS]
local defPct=(25-EAT_MIN)/(EAT_MAX-EAT_MIN)

local _slRow=Instance.new("Frame",_eatCF); _slRow.BackgroundTransparency=1; _slRow.BorderSizePixel=0
_slRow.Position=UDim2.new(0,12,0,_y); _slRow.Size=UDim2.new(1,-24,0,44); _slRow.ZIndex=7

local _slLbl=Instance.new("TextLabel",_slRow); _slLbl.BackgroundTransparency=1
_slLbl.Position=UDim2.new(0,0,0,0); _slLbl.Size=UDim2.new(1,0,0,16)
_slLbl.Font=Enum.Font.GothamBold; _slLbl.Text="Limite: 25% da fome"
_slLbl.TextColor3=Color3.fromRGB(180,210,255); _slLbl.TextSize=10
_slLbl.TextXAlignment=Enum.TextXAlignment.Left; _slLbl.ZIndex=8

local _slTrack=Instance.new("Frame",_slRow); _slTrack.BackgroundColor3=Color3.fromRGB(20,36,80)
_slTrack.BorderSizePixel=0; _slTrack.Position=UDim2.new(0,0,0,24)
_slTrack.Size=UDim2.new(1,0,0,4); _slTrack.ZIndex=8
Instance.new("UICorner",_slTrack).CornerRadius=UDim.new(1,0)

local _slFill=Instance.new("Frame",_slTrack); _slFill.BackgroundColor3=ATE_COR_P
_slFill.BorderSizePixel=0; _slFill.Size=UDim2.new(defPct,0,1,0); _slFill.ZIndex=9
Instance.new("UICorner",_slFill).CornerRadius=UDim.new(1,0)

local _slThumb=Instance.new("TextButton",_slTrack); _slThumb.BackgroundColor3=Color3.fromRGB(25,48,105)
_slThumb.BorderSizePixel=0; _slThumb.AnchorPoint=Vector2.new(0.5,0.5)
_slThumb.Position=UDim2.new(defPct,0,0.5,0); _slThumb.Size=UDim2.new(0,18,0,18)
_slThumb.Text=""; _slThumb.ZIndex=10; _slThumb.AutoButtonColor=false
Instance.new("UICorner",_slThumb).CornerRadius=UDim.new(1,0)
local _slThumbS=Instance.new("UIStroke",_slThumb); _slThumbS.Color=ATE_COR_P; _slThumbS.Thickness=1.5

-- Ticks
for _, v in ipairs(EAT_STEPS) do
    local p=(v-EAT_MIN)/(EAT_MAX-EAT_MIN)
    local tk=Instance.new("Frame",_slTrack); tk.BackgroundColor3=Color3.fromRGB(60,40,90)
    tk.BorderSizePixel=0; tk.AnchorPoint=Vector2.new(0.5,0)
    tk.Position=UDim2.new(p,0,1,2); tk.Size=UDim2.new(0,2,0,5); tk.ZIndex=9
end

local _slDragging=false
local function _slSetVal(screenX)
    local ap=_slTrack.AbsolutePosition; local as=_slTrack.AbsoluteSize
    local t=math.clamp((screenX-ap.X)/as.X,0,1)
    local raw=EAT_MIN+t*(EAT_MAX-EAT_MIN)
    local best,bestD=EAT_STEPS[1],math.huge
    for _, sv in ipairs(EAT_STEPS) do if math.abs(sv-raw)<bestD then bestD=math.abs(sv-raw); best=sv end end
    eatThreshold=best
    local p=(best-EAT_MIN)/(EAT_MAX-EAT_MIN)
    _slFill.Size=UDim2.new(p,0,1,0); _slThumb.Position=UDim2.new(p,0,0.5,0)
    _slLbl.Text=string.format("Limite: %d%% da fome",eatThreshold)
end
_slThumb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _slDragging=true end end)
_slTrack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then _slSetVal(i.Position.X) end end)
UserInputService.InputChanged:Connect(function(i)
    if _slDragging and i.UserInputType==Enum.UserInputType.MouseMovement then _slSetVal(i.Position.X) end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then _slDragging=false end
end)
_y = _y+50

_accDivLine(_eatCF, _y, ATE_COR_P); _y = _y+9

-- Botão ATIVAR
local _eatBtn, _eatBtnS = _accActivBtn(_eatCF, _y, "🍖", ATE_COR_P)
eatRef.btn = _eatBtn; _y = _y+40

local _eatStatus = _accStatusLbl(_eatCF, _y)
eatRef.status = _eatStatus

_eatBtn.MouseButton1Click:Connect(function()
    if eatRunning then
        stopAutoEat()
        
        if _btnStateMap[_eatBtn] then _btnStateMap[_eatBtn](false) end
        _eatStatus.Text="⏹ Parado"; Notify.error("🍖 Auto Comer","⏹ Desativado")
        task.delay(1.5,function() pcall(function() _eatStatus.Text="" end) end)
    else
        
        TweenService:Create(_eatBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(200,50,60)}):Play()
        Notify.send({type="info",icon="🍖",accent=ATE_COR_P,title="Auto Comer",msg=string.format("Come quando fome ≤ %d%%!",eatThreshold),duration=3})
        startAutoEat()
    end
end)
end -- Auto Comer

end); if not _dbgOk_10579 then warn('[PudimHub DEBUG] Erro na secao PLAYER3/CONFIG: '..tostring(_dbgErr_10579)) end


-- ══════════════════════════════════════════════════════
-- AIMBOT
-- ══════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════
-- TELEPORTAR TAB
-- ══════════════════════════════════════════════════════════════
local _dbgOk_11847, _dbgErr_11847 = pcall(function() -- [[ TELEPORTAR ]]

local TP_COR_CAMP   = Color3.fromRGB(255, 180, 60)
local TP_COR_VOLC   = Color3.fromRGB(255, 90, 40)
local TP_COR_FOREST = Color3.fromRGB(80, 200, 100)
local TP_COR_CAVE   = Color3.fromRGB(160, 120, 255)
local TP_COR_FAIRY  = Color3.fromRGB(220, 100, 255)
local TP_COR_CHILD  = Color3.fromRGB(100, 200, 255)
local TP_COR_BUILD  = Color3.fromRGB(180, 210, 255)

local tpLO = 0
local function tpNextLO() tpLO = tpLO + 1; return tpLO end

-- Helper: seção de TP
local function makeTpSec(titleTxt, cor)
    local hdr = Instance.new("Frame", Pages["Teleportar"])
    hdr.BackgroundColor3 = Color3.fromRGB(44,28,72); hdr.BackgroundTransparency = 0.3
    hdr.BorderSizePixel = 0; hdr.Size = UDim2.new(1,0,0,22)
    hdr.LayoutOrder = tpNextLO(); hdr.ZIndex = 4
    Instance.new("UICorner",hdr).CornerRadius = UDim.new(0,6)
    local bar = Instance.new("Frame",hdr); bar.BackgroundColor3 = cor; bar.BorderSizePixel = 0
    bar.Size = UDim2.new(0,3,1,0); bar.ZIndex = 5; Instance.new("UICorner",bar).CornerRadius = UDim.new(0,3)
    local lbl = Instance.new("TextLabel",hdr); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,10,0,0); lbl.Size = UDim2.new(1,-14,1,0)
    lbl.Font = Enum.Font.GothamBlack; lbl.Text = titleTxt
    lbl.TextColor3 = cor; lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5
end

-- Helper: botão de TP (card largo, visual original)
local function makeTpBtn(icon, titleTxt, descTxt, cor, onClick)
    local card = Instance.new("Frame", Pages["Teleportar"])
    card.BackgroundColor3 = Color3.fromRGB(64,42,104); card.BorderSizePixel = 0
    card.Size = UDim2.new(1,0,0,58); card.LayoutOrder = tpNextLO(); card.ZIndex = 5
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,12)
    local stroke = Instance.new("UIStroke",card); stroke.Color = Color3.fromRGB(148,112,220); stroke.Thickness = 3.5; stroke.Transparency = 0.55

    -- Ícone colorido (estilo cartoon)
    local iconBg = Instance.new("Frame",card); iconBg.BackgroundColor3 = cor
    iconBg.BackgroundTransparency = 0.6; iconBg.BorderSizePixel = 0
    iconBg.Position = UDim2.new(0,10,0.5,-18); iconBg.Size = UDim2.new(0,36,0,36); iconBg.ZIndex = 6
    Instance.new("UICorner",iconBg).CornerRadius = UDim.new(0,10)
    local iconBgStroke = Instance.new("UIStroke",iconBg)
    iconBgStroke.Color = Color3.fromRGB(15,8,30); iconBgStroke.Thickness = 2.5; iconBgStroke.Transparency = 0.3
    local iconLbl = Instance.new("TextLabel",iconBg); iconLbl.BackgroundTransparency = 1
    iconLbl.Size = UDim2.new(1,0,1,0); iconLbl.Font = Enum.Font.GothamBlack
    iconLbl.Text = icon; iconLbl.TextSize = 18; iconLbl.ZIndex = 7

    -- Título + desc
    local tl = Instance.new("TextLabel",card); tl.BackgroundTransparency = 1
    tl.Position = UDim2.new(0,54,0,8); tl.Size = UDim2.new(1,-120,0,18)
    tl.Font = Enum.Font.GothamBold; tl.Text = titleTxt
    tl.TextColor3 = Color3.fromRGB(220,200,255); tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 7
    local td = Instance.new("TextLabel",card); td.BackgroundTransparency = 1
    td.Position = UDim2.new(0,54,0,28); td.Size = UDim2.new(1,-120,0,22)
    td.Font = Enum.Font.Gotham; td.Text = descTxt
    td.TextColor3 = Color3.fromRGB(155,135,185); td.TextSize = 9
    td.TextXAlignment = Enum.TextXAlignment.Left; td.TextWrapped = true; td.ZIndex = 7

    -- Botão TP direita (estilo NOVO badge — amarelo cartoon)
    local btn = Instance.new("TextButton",card); btn.BackgroundColor3 = Color3.fromRGB(148,112,220)
    btn.BackgroundTransparency = 0; btn.BorderSizePixel = 0; btn.Text = ""
    btn.Position = UDim2.new(1,-60,0.5,-14); btn.Size = UDim2.new(0,52,0,28); btn.ZIndex = 8
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,9)
    local btnStroke = Instance.new("UIStroke",btn); btnStroke.Color = Color3.fromRGB(15,8,30); btnStroke.Thickness = 3
    local btnGrad = Instance.new("UIGradient",btn)
    btnGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(190,165,245)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(108,74,170)),
    }); btnGrad.Rotation = 90
    -- Shine no botão TP
    local btnShine = Instance.new("Frame",btn); btnShine.Size = UDim2.new(0,28,0,7)
    btnShine.Position = UDim2.new(0,4,0,3); btnShine.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btnShine.BackgroundTransparency = 0.65; btnShine.BorderSizePixel = 0; btnShine.ZIndex = 9
    Instance.new("UICorner",btnShine).CornerRadius = UDim.new(1,0)
    local btnL = Instance.new("TextLabel",btn); btnL.BackgroundTransparency = 1
    btnL.Size = UDim2.new(1,0,1,0); btnL.Font = Enum.Font.GothamBlack
    btnL.Text = "TP"; btnL.TextColor3 = Color3.fromRGB(16,8,30); btnL.TextSize = 12; btnL.ZIndex = 9

    -- Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(255,240,80)}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.12),{Color=Color3.fromRGB(148,112,220),Transparency=0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(148,112,220)}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.12),{Color=Color3.fromRGB(148,112,220),Transparency=0.55}):Play()
    end)
    btn.MouseButton1Click:Connect(onClick)

    return card, stroke
end

-- ──────────────────────────────────────────────
-- Função: encontrar a FOGUEIRA REAL (upgradável)
-- Cache: só faz o scan pesado uma vez por sessão.
-- O scan roda em background na primeira chamada.
-- ──────────────────────────────────────────────
_campfirePosCache = nil   -- posição cacheada
local _campfireCacheTime = 0    -- quando foi cacheado (tick)
local _campfireScanDone = false

local function _scanCampfireBackground()
    -- Roda em background para não travar o clique
    task.spawn(function()
        local best, bestScore = nil, -1
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end
                    local nm = obj.Name:lower()

                    if nm:find("decor",1,true) or nm:find("ambient",1,true)
                    or nm:find("fake",1,true)   or nm:find("particle",1,true)
                    or nm:find("effect",1,true) or nm:find("campfire_small",1,true)
                    or nm:find("minifire",1,true) then return end

                    local score = 0

                    local hasAttr = false
                    pcall(function()
                        local v = obj:GetAttribute("Level")
                               or obj:GetAttribute("CampfireLevel")
                               or obj:GetAttribute("FireLevel")
                               or obj:GetAttribute("Tier")
                        if v ~= nil then hasAttr = true end
                    end)
                    if hasAttr then score = score + 100 end

                    if nm == "campfire" or nm == "mainfire" or nm == "camp fire"
                    or nm == "main campfire" or nm == "centralfire" then
                        score = score + 30
                    elseif nm:find("campfire",1,true) or nm:find("mainfire",1,true) then
                        score = score + 10
                    end

                    local parent = obj.Parent
                    for _ = 1, 4 do
                        if not parent or parent == workspace then break end
                        if parent.Name:lower():find("campground",1,true)
                        or parent.Name:lower():find("basecamp",1,true)
                        or parent.Name:lower() == "camp" then
                            score = score + 50; break
                        end
                        parent = parent.Parent
                    end

                    if score == 0 then return end

                    local bp = nil
                    if obj:IsA("BasePart") then bp = obj
                    else
                        bp = obj:FindFirstChild("Center")
                         or obj:FindFirstChild("Base")
                         or obj:FindFirstChildWhichIsA("BasePart")
                    end
                    if not bp then return end
                    if bp.Position.Y < -100 then return end

                    if score > bestScore then
                        bestScore = score; best = bp.Position
                    end
                end)
            end
        end)
        if best then
            _campfirePosCache = best
            _campfireCacheTime = tick()
        end
        _campfireScanDone = true
    end)
end

getCampfirePos = function()
    -- Se tem cache válido (menos de 120s), retorna direto — zero travamento
    if _campfirePosCache and (tick() - _campfireCacheTime) < 120 then
        return _campfirePosCache
    end

    -- Primeira chamada: tenta caminho rápido (sem varrer tudo)
    local fast = nil
    pcall(function()
        -- Caminho direto mais comum no 99 Nights
        local camp = workspace:FindFirstChild("Campground")
        if camp then
            local mf = camp:FindFirstChild("MainFire")
            if mf then
                local center = mf:FindFirstChild("Center")
                if center and center:IsA("BasePart") then
                    fast = center.Position; return
                end
                local bp = mf:FindFirstChildWhichIsA("BasePart")
                if bp then fast = bp.Position; return end
            end
        end
    end)

    if fast then
        _campfirePosCache = fast
        _campfireCacheTime = tick()
        -- Agenda scan completo em background para refinar o cache
        if not _campfireScanDone then _scanCampfireBackground() end
        return fast
    end

    -- Se scan já rodou e achou algo, usa o resultado
    if _campfireScanDone and _campfirePosCache then
        return _campfirePosCache
    end

    -- Scan ainda não rodou: dispara agora e espera resultado
    if not _campfireScanDone then
        _campfireScanDone = true  -- evita disparar duas vezes
        local best, bestScore = nil, -1
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end
                    local nm = obj.Name:lower()
                    if nm:find("decor",1,true) or nm:find("ambient",1,true)
                    or nm:find("fake",1,true)   or nm:find("particle",1,true)
                    or nm:find("effect",1,true) then return end

                    local score = 0
                    pcall(function()
                        local v = obj:GetAttribute("Level") or obj:GetAttribute("CampfireLevel")
                        if v ~= nil then score = score + 100 end
                    end)
                    if nm:find("campfire",1,true) or nm:find("mainfire",1,true) then score = score + 10 end
                    local par = obj.Parent
                    for _ = 1, 4 do
                        if not par or par == workspace then break end
                        if par.Name:lower():find("campground",1,true) then score = score + 50; break end
                        par = par.Parent
                    end
                    if score == 0 then return end
                    local bp = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if not bp or bp.Position.Y < -100 then return end
                    if score > bestScore then bestScore = score; best = bp.Position end
                end)
            end
        end)
        if best then
            _campfirePosCache = best
            _campfireCacheTime = tick()
            return best
        end
    end

    return _campfirePosCache  -- retorna o que tiver (pode ser nil)
end

-- Pré-aquece o cache em background quando a aba carrega
task.spawn(function()
    task.wait(2)  -- espera o jogo carregar
    if not _campfirePosCache then _scanCampfireBackground() end
end)

-- ──────────────────────────────────────────────
-- Função: teleportar seguro (verifica Y > -100)
-- ──────────────────────────────────────────────
local function safeTp(pos, heightOffset)
    local ch = Player.Character; if not ch then return false end
    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
    local safeY = math.max((pos.Y + (heightOffset or 3)), -90)
    hrp.CFrame = CFrame.new(pos.X, safeY, pos.Z)
    return true
end

-- ──────────────────────────────────────────────────────────────
-- 1. TP FOGUEIRA — workspace.Campground.MainFire.Center
-- ──────────────────────────────────────────────────────────────
makeTpSec("📍  LOCALIZAÇÕES RÁPIDAS", TP_COR_CAMP)

makeTpBtn("🔥","Tp Fogueira","Teleporta até o centro da fogueira principal",TP_COR_CAMP, function()
    local pos = getCampfirePos()
    if pos then
        safeTp(pos, 4)
        Notify.send({type="custom",icon="🔥",accent=TP_COR_CAMP,title="Teleporte",msg="Fogueira principal!",duration=2.5})
    else
        Notify.warn("Teleporte","⚠️ Fogueira não encontrada no workspace!")
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 2. TP FLORESTA — 65 studs da fogueira
-- ──────────────────────────────────────────────────────────────
makeTpBtn("🌲","Tp Floresta","Teleporta 65 studs da fogueira, dentro da floresta",TP_COR_FOREST, function()
    local pos = getCampfirePos()
    if pos then
        local angle = math.random() * math.pi * 2
        local fx = pos.X + math.cos(angle) * 65
        local fz = pos.Z + math.sin(angle) * 65
        -- Encontra o chão nessa posição
        local groundY = pos.Y
        pcall(function()
            local ray = workspace:Raycast(
                Vector3.new(fx, pos.Y + 100, fz),
                Vector3.new(0, -200, 0)
            )
            if ray then groundY = ray.Position.Y end
        end)
        safeTp(Vector3.new(fx, groundY, fz), 4)
        Notify.send({type="custom",icon="🌲",accent=TP_COR_FOREST,title="Teleporte",msg="Floresta — 65 studs da fogueira!",duration=2.5})
    else
        Notify.warn("Teleporte","⚠️ Fogueira não encontrada!")
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 3. TP VULCÃO — Bioma Vulcânico, zona segura (borda)
-- ──────────────────────────────────────────────────────────────
makeTpBtn("🌋","Tp Vulcão","Teleporta para borda segura do Vulcão (Bioma Vulcânico)",TP_COR_VOLC, function()
    local found = false
    -- Procura modelo chamado "Volcano" ou similar no workspace
    local volcNames = {"Volcano","Volcanic","VolcanoBiome","Vulcao","VolcanoBase","MainVolcano"}
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local n = obj.Name
                for _, vn in ipairs(volcNames) do
                    if n:lower():find(vn:lower()) then
                        local pos
                        if obj:IsA("Model") then
                            local p = obj:FindFirstChildWhichIsA("BasePart")
                            if p then pos = p.Position end
                        else
                            pos = obj.Position
                        end
                        if pos then
                            -- Offset de 30 studs da borda para evitar lava
                            local ch = Player.Character
                            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                            local dir = hrp and (pos - hrp.Position).Unit or Vector3.new(1,0,0)
                            local safePos = pos - dir * 30 + Vector3.new(0, 8, 0)
                            safeTp(safePos, 0)
                            Notify.send({type="custom",icon="🌋",accent=TP_COR_VOLC,
                                title="Teleporte",msg="Borda segura do Vulcão!",duration=3})
                            found = true
                            return
                        end
                    end
                end
                if found then break end
            end
        end
    end)
    if not found then
        -- Fallback: bioma vulcânico costuma estar em X > 500 ou Z extremo — scan por BaseParts com lava
        local lavaFound = false
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    local n = obj.Name:lower()
                    if n:find("lava") or n:find("volcano") or n:find("volcanic") then
                        safeTp(obj.Position + Vector3.new(0,20,0), 0)
                        Notify.send({type="custom",icon="🌋",accent=TP_COR_VOLC,
                            title="Teleporte",msg="Área volcânica encontrada!",duration=3})
                        lavaFound = true
                        return
                    end
                end
            end
        end)
        if not lavaFound then
            Notify.warn("Teleporte","⚠️ Bioma Vulcânico não encontrado. Pode não estar ativo nesta partida!")
        end
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 4. TP CAVERNA — procura "Mineshaft" ou cave entrance
-- ──────────────────────────────────────────────────────────────
makeTpBtn("⛏️","Tp Caverna de Mineração","Teleporta para a entrada da caverna (Mineshaft)",TP_COR_CAVE, function()
    local caveNames = {"Mineshaft","Cave","CaveEntrance","CaveEntry","Caverna","Mine","BatCave","CaveMain"}
    local found = false
    pcall(function()
        local bestDist = math.huge
        local bestPos = nil
        local ch = Player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local myPos = hrp and hrp.Position or Vector3.new(0,0,0)
        for _, obj in ipairs(workspace:GetDescendants()) do
            local n = obj.Name:lower()
            for _, cn in ipairs(caveNames) do
                if n:find(cn:lower()) then
                    local pos
                    if obj:IsA("BasePart") then pos = obj.Position
                    elseif obj:IsA("Model") then
                        local p = obj:FindFirstChildWhichIsA("BasePart")
                        if p then pos = p.Position end
                    end
                    if pos then
                        local d = (pos - myPos).Magnitude
                        if d < bestDist then bestDist = d; bestPos = pos end
                    end
                end
            end
        end
        if bestPos then
            -- Tp para entrada: acima da posição detectada
            safeTp(bestPos, 5)
            Notify.send({type="custom",icon="⛏️",accent=TP_COR_CAVE,
                title="Teleporte",msg="Entrada da Caverna de Mineração!",duration=3})
            found = true
        end
    end)
    if not found then
        Notify.warn("Teleporte","⚠️ Caverna não encontrada no mapa!")
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 5. TP FADA — Bioma Fairy (pode não estar ativo)
-- ──────────────────────────────────────────────────────────────
makeTpBtn("🧚","Tp Fada","Teleporta para o Bioma da Fada (se ativo nesta partida)",TP_COR_FAIRY, function()
    local fairyNames = {"FairyBiome","Fairy","FairyArea","FairyZone","FairyForest","GiantTree","MotherTree"}
    local found = false
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            local n = obj.Name:lower()
            for _, fn in ipairs(fairyNames) do
                if n:find(fn:lower()) then
                    local pos
                    if obj:IsA("BasePart") then pos = obj.Position
                    elseif obj:IsA("Model") then
                        local p = obj:FindFirstChildWhichIsA("BasePart")
                        if p then pos = p.Position end
                    end
                    if pos then
                        safeTp(pos, 5)
                        Notify.send({type="custom",icon="🧚",accent=TP_COR_FAIRY,
                            title="Teleporte",msg="Bioma da Fada!",duration=3})
                        found = true
                        return
                    end
                end
            end
            if found then break end
        end
    end)
    if not found then
        Notify.warn("Teleporte","⚠️ Bioma da Fada não encontrado. Pode ser evento limitado!")
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 6. TP NEVE — Teleporta para o Bioma de Neve
-- ──────────────────────────────────────────────────────────────
local TP_COR_SNOW = Color3.fromRGB(180, 220, 255)

makeTpBtn("❄️","Tp Neve","Teleporta para o Bioma de Neve",TP_COR_SNOW, function()
    local snowNames = {
        "Snow","SnowBiome","SnowArea","SnowZone","IceBiome","IceArea",
        "FrozenLand","FrozenBiome","WinterBiome","ArcticBiome","Tundra",
        "Neve","BiomaGelo","BiomaFrio","Frio","Gelo","IceZone",
        "SnowRegion","SnowField","Blizzard","FrostBiome",
    }
    local found = false
    pcall(function()
        -- Tenta encontrar por nome de Model/Part
        for _, obj in ipairs(workspace:GetDescendants()) do
            if found then break end
            local n = obj.Name:lower()
            for _, sn in ipairs(snowNames) do
                if n:find(sn:lower(), 1, true) then
                    local pos
                    if obj:IsA("BasePart") then
                        pos = obj.Position
                    elseif obj:IsA("Model") then
                        local p = obj:FindFirstChildWhichIsA("BasePart")
                        if p then pos = p.Position end
                    end
                    if pos then
                        safeTp(pos, 5)
                        Notify.send({type="custom",icon="❄️",accent=TP_COR_SNOW,
                            title="Teleporte",msg="Bioma de Neve!",duration=3})
                        found = true
                        break
                    end
                end
            end
        end
    end)
    -- Fallback: coordenadas conhecidas do bioma de neve do 99 Nights
    if not found then
        pcall(function()
            local ch = Player.Character
            if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            -- Coordenadas aproximadas do bioma de neve (canto norte do mapa)
            hrp.CFrame = CFrame.new(0, 50, -800)
            Notify.send({type="custom",icon="❄️",accent=TP_COR_SNOW,
                title="Teleporte",msg="Bioma de Neve (coordenadas estimadas)!",duration=3})
        end)
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 7. TP SELVA — Teleporta para o Bioma da Selva (update Março 2026)
-- ──────────────────────────────────────────────────────────────
local TP_COR_JUNGLE = Color3.fromRGB(60, 200, 80)

makeTpBtn("🌿","Tp Selva","Teleporta para o Bioma da Selva (Jungle Biome – Mar 2026)",TP_COR_JUNGLE, function()
    local jungleNames = {
        "Jungle","JungleBiome","JungleArea","JungleZone","JungleGround","JungleFloor",
        "JungleBase","JungleTerrain","JungleLand","SelvaZone","Selva","BiomaSeva",
        "JungleTree","MotherTemple","JungleTemple","JungleCultist","Boar",
        "TarPit","Tar Pit","JungleChest","JunglePath",
    }
    local found = false
    -- 1. Tenta encontrar o bioma pelo workspace
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if found then break end
            local n = obj.Name:lower()
            for _, jn in ipairs(jungleNames) do
                if n:find(jn:lower(), 1, true) then
                    local pos
                    if obj:IsA("BasePart") then
                        pos = obj.Position
                    elseif obj:IsA("Model") then
                        local p = obj:FindFirstChildWhichIsA("BasePart")
                        if p then pos = p.Position end
                    end
                    if pos and pos.Y > -200 and pos.Magnitude < 15000 then
                        safeTp(pos, 5)
                        Notify.send({type="custom",icon="🌿",accent=TP_COR_JUNGLE,
                            title="Teleporte",msg="🌿 Bioma da Selva!",duration=3})
                        found = true
                        break
                    end
                end
            end
        end
    end)
    -- 2. Fallback: coordenadas estimadas da Selva (bioma distante da fogueira, requer nível 3+)
    if not found then
        pcall(function()
            local ch = Player.Character
            if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            -- A Selva fica a sudeste do mapa no 99 Nights — coordenadas estimadas
            hrp.CFrame = CFrame.new(800, 50, 800)
            Notify.send({type="custom",icon="🌿",accent=TP_COR_JUNGLE,
                title="Teleporte",msg="🌿 Selva (coords estimadas) — precisa Fogueira Nível 3+!",duration=4})
        end)
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 8. TP JUNGLE FIGHT PITS — Arenas de combate na Selva (Mar 2026)
-- ──────────────────────────────────────────────────────────────
local TP_COR_FIGHTPIT = Color3.fromRGB(255, 140, 30)

makeTpBtn("⚔️","Tp Jungle Fight Pits","Teleporta para as arenas de combate da Selva",TP_COR_FIGHTPIT, function()
    local pitNames = {
        "FightPit","Fight Pit","FightArena","JungleFightPit","JungleFight",
        "JungleArena","CombatPit","CombatArena","JunglePit","Arena",
        "FightingPit","BattlePit","JungleBattle","FightZone","JungleFightZone",
    }
    local found = false
    pcall(function()
        local bestDist = math.huge
        local bestPos = nil
        local ch = Player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local myPos = hrp and hrp.Position or Vector3.new(0,0,0)
        for _, obj in ipairs(workspace:GetDescendants()) do
            local n = obj.Name:lower()
            for _, pn in ipairs(pitNames) do
                if n:find(pn:lower(), 1, true) then
                    local pos
                    if obj:IsA("BasePart") then pos = obj.Position
                    elseif obj:IsA("Model") then
                        local p = obj:FindFirstChildWhichIsA("BasePart")
                        if p then pos = p.Position end
                    end
                    if pos then
                        local d = (pos - myPos).Magnitude
                        if d < bestDist then bestDist = d; bestPos = pos end
                    end
                end
            end
        end
        if bestPos then
            safeTp(bestPos, 5)
            Notify.send({type="custom",icon="⚔️",accent=TP_COR_FIGHTPIT,
                title="Teleporte",msg="⚔️ Jungle Fight Pits!",duration=3})
            found = true
        end
    end)
    if not found then
        -- Fallback: Fight Pits ficam dentro da Selva, offset da posição da selva
        pcall(function()
            local ch = Player.Character
            if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = CFrame.new(850, 50, 820)
            Notify.send({type="custom",icon="⚔️",accent=TP_COR_FIGHTPIT,
                title="Teleporte",msg="⚔️ Jungle Fight Pits (coords estimadas)!",duration=4})
        end)
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 9. TP CULTIST STRONGHOLD — Fortaleza dos Cultistas
-- ──────────────────────────────────────────────────────────────
local TP_COR_STRONGHOLD = Color3.fromRGB(180, 50, 255)

makeTpBtn("🏰","Tp Cultist Stronghold","Teleporta para a Fortaleza dos Cultistas",TP_COR_STRONGHOLD, function()
    local strongholdNames = {
        "Stronghold","CultistStronghold","Cultist Stronghold","CultistFort",
        "CultistBase","CultistCastle","CultistTemple","CultistTower",
        "EvilBase","EvilFort","DarkStronghold","CultistHQ","CultistMain",
        "StrongholdBase","FortressMain","CultistKingBase","FinalStronghold",
    }
    local found = false
    pcall(function()
        local bestDist = math.huge
        local bestPos = nil
        local ch = Player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local myPos = hrp and hrp.Position or Vector3.new(0,0,0)
        for _, obj in ipairs(workspace:GetDescendants()) do
            local n = obj.Name:lower()
            for _, sn in ipairs(strongholdNames) do
                if n:find(sn:lower(), 1, true) then
                    local pos
                    if obj:IsA("BasePart") then pos = obj.Position
                    elseif obj:IsA("Model") then
                        local p = obj:FindFirstChildWhichIsA("BasePart")
                        if p then pos = p.Position end
                    end
                    if pos then
                        local d = (pos - myPos).Magnitude
                        if d < bestDist then bestDist = d; bestPos = pos end
                    end
                end
            end
        end
        if bestPos then
            safeTp(bestPos, 6)
            Notify.send({type="custom",icon="🏰",accent=TP_COR_STRONGHOLD,
                title="Teleporte",msg="🏰 Cultist Stronghold!",duration=3})
            found = true
        end
    end)
    if not found then
        -- Fallback: Stronghold costuma estar em zona afastada do camp
        pcall(function()
            local ch = Player.Character
            if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = CFrame.new(-600, 50, -600)
            Notify.send({type="custom",icon="🏰",accent=TP_COR_STRONGHOLD,
                title="Teleporte",msg="🏰 Cultist Stronghold (coords estimadas)!",duration=4})
        end)
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 10. TP RESEARCH OUTPOST — Posto de Pesquisa (Hard Mode lever)
-- ──────────────────────────────────────────────────────────────
local TP_COR_OUTPOST = Color3.fromRGB(60, 180, 255)

makeTpBtn("🔬","Tp Research Outpost","Teleporta para o Research Outpost (Hard Mode — porão)",TP_COR_OUTPOST, function()
    local outpostNames = {
        "ResearchOutpost","Research Outpost","Outpost","OutpostBase",
        "ResearchBase","ResearchStation","Laboratory","Lab","HardModeLever",
        "BasementLever","OutpostBasement","Basement","ResearchLab",
        "OutpostMain","Outpost Main","ResearchCenter","OutpostBuilding",
    }
    local found = false
    pcall(function()
        local bestDist = math.huge
        local bestPos = nil
        local ch = Player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        local myPos = hrp and hrp.Position or Vector3.new(0,0,0)
        for _, obj in ipairs(workspace:GetDescendants()) do
            local n = obj.Name:lower()
            for _, on in ipairs(outpostNames) do
                if n:find(on:lower(), 1, true) then
                    local pos
                    if obj:IsA("BasePart") then pos = obj.Position
                    elseif obj:IsA("Model") then
                        local p = obj:FindFirstChildWhichIsA("BasePart")
                        if p then pos = p.Position end
                    end
                    if pos then
                        local d = (pos - myPos).Magnitude
                        if d < bestDist then bestDist = d; bestPos = pos end
                    end
                end
            end
        end
        if bestPos then
            safeTp(bestPos, 5)
            Notify.send({type="custom",icon="🔬",accent=TP_COR_OUTPOST,
                title="Teleporte",msg="🔬 Research Outpost! Entre no porão para Hard Mode.",duration=4})
            found = true
        end
    end)
    if not found then
        -- Fallback: Research Outpost é uma estrutura fixa no mapa
        pcall(function()
            local ch = Player.Character
            if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            hrp.CFrame = CFrame.new(300, 50, -400)
            Notify.send({type="custom",icon="🔬",accent=TP_COR_OUTPOST,
                title="Teleporte",msg="🔬 Research Outpost (coords estimadas) — entre no porão!",duration=4})
        end)
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 11. TP CRIANÇA — Teleporta para a criança capturada mais próxima (1 vez, desliga sozinho)
-- ──────────────────────────────────────────────────────────────
makeTpSec("👶  CRIANÇAS CAPTURADAS", TP_COR_CHILD)

-- Nomes reais confirmados das crianças
local CHILD_OPTIONS = {
    {name="Child 1", icon="👶", cor=Color3.fromRGB(100,220,255)},
    {name="Child 2", icon="👧", cor=Color3.fromRGB(255,180,100)},
    {name="Child 3", icon="🧒", cor=Color3.fromRGB(150,255,150)},
    {name="Child 4", icon="👦", cor=Color3.fromRGB(255,150,200)},
}
local selectedChildName = "Child 1"  -- padrão

local CHILD_NAMES = {
    -- Nomes reais confirmados no workspace
    "Lost Child", "Lost Child2", "Lost Child3", "Lost Child4",
    "lostchild", "lostchild2", "lostchild3", "lostchild4",
    "lost child", "lost child2", "lost child3", "lost child4",
    -- Variações antigas (compatibilidade)
    "child 1", "child 2", "child 3", "child 4",
    "child. 1", "child. 2", "child. 3", "child. 4",
    "child1", "child2", "child3", "child4",
    "dino kid", "dinokid", "kraken kid", "krakenkid",
    "squid kid", "squidkid", "koala kid", "koalakid",
    "kid", "missing child", "capturedchild", "captured child",
    "crianca", "criança",
}

local tpChildActive = false
local tpChildCard, tpChildStroke, tpChildBtn, tpChildBtnL

local function isPlayerCharLocal(model)
    for _, pl in ipairs(game:GetService("Players"):GetPlayers()) do
        if pl.Character == model then return true end
    end
    return false
end

local function isChildName(name)
    local low = name:lower()
    for _, cn in ipairs(CHILD_NAMES) do
        if low == cn or low:find(cn, 1, true) then return true end
    end
    return false
end

local function isRescued(model)
    local ok = false
    pcall(function()
        ok = model:GetAttribute("Rescued") == true
          or model:GetAttribute("Saved")   == true
          or model:GetAttribute("IsSaved") == true
          or model:GetAttribute("Free")    == true
    end)
    return ok
end

-- Nomes de mobs/animais que NUNCA são crianças
local ANIMAL_BLACKLIST = {
    "bunny","rabbit","coelho","bear","urso","wolf","lobo","deer","veado",
    "fox","raposa","boar","javali","spider","aranha","bat","morcego",
    "bird","passaro","snake","cobra","frog","sapo","bee","abelha",
    "scorpion","escorpiao","rat","rato","crow","corvo","goat","cabra",
    "pig","porco","cat","gato","dog","cachorro","horse","cavalo",
    "monster","mob","enemy","inimigo","cultist","cultista","zombie",
    "skeleton","esqueleto","ghost","fantasma","alien","goblin","troll",
    "giant","gigante","boss","dragon","dragao","slime","creature",
}

local function isAnimal(name)
    local low = name:lower()
    for _, a in ipairs(ANIMAL_BLACKLIST) do
        if low:find(a, 1, true) then return true end
    end
    return false
end

local function findChildByName(targetName)
    -- Busca criança pelo nome exato (ex: "Child 1")
    local target = targetName:lower()
    for _, obj in ipairs(workspace:GetDescendants()) do
        local found = nil
        pcall(function()
            if not obj:IsA("Model") then return end
            if isPlayerCharLocal(obj) then return end
            local hum = obj:FindFirstChildWhichIsA("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local nm = obj.Name:lower()
            if nm == target or nm:find(target, 1, true) then
                local hrp2 = obj:FindFirstChild("HumanoidRootPart")
                            or obj:FindFirstChildWhichIsA("BasePart")
                if hrp2 then found = hrp2.Position end
            end
        end)
        if found then return found end
    end
    return nil
end

local function findNearestCapturedChild()
    local ch  = Player.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local myPos = hrp.Position
    local best, bestScore = nil, -1

    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if not obj:IsA("Model") then return end
            if isPlayerCharLocal(obj) then return end
            if isRescued(obj)         then return end
            if isAnimal(obj.Name)     then return end

            local hum = obj:FindFirstChildWhichIsA("Humanoid")
            if not hum or hum.Health <= 0 then return end

            local nm    = obj.Name
            local score = 0

            if isChildName(nm) then score = score + 10 end

            -- Atributos de criança
            pcall(function()
                if obj:GetAttribute("IsChild")   == true then score = score + 8 end
                if obj:GetAttribute("IsMissing") == true then score = score + 6 end
                if obj:GetAttribute("Child")     == true then score = score + 6 end
                if obj:GetAttribute("Captured")  == true then score = score + 6 end
            end)

            -- ❌ SEM fallback de score=1 — se score=0 NÃO é criança
            if score <= 0 then return end

            -- Mobs grandes demais não são crianças
            if hum.MaxHealth > 200 then return end

            local p = obj:FindFirstChild("HumanoidRootPart")
                   or obj:FindFirstChildWhichIsA("BasePart")
            if not p then return end

            local dist = (p.Position - myPos).Magnitude
            local distBonus = math.max(0, 1 - dist / 5000)
            local total = score + distBonus

            if total > bestScore then
                bestScore = total
                best = p
            end
        end)
    end

    return best
end

-- Debug: lista todos os NPCs no workspace para identificar nomes reais
local function debugListNPCs()
    local found = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj:FindFirstChildWhichIsA("Humanoid") then
                local isPlayer = false
                for _, pl in ipairs(game:GetService("Players"):GetPlayers()) do
                    if pl.Character == obj then isPlayer = true end
                end
                if not isPlayer then
                    local hum = obj:FindFirstChildWhichIsA("Humanoid")
                    local hp = hum and math.floor(hum.Health) or 0
                    table.insert(found, obj.Name.." (HP:"..hp..")")
                end
            end
        end)
    end

    if #found > 0 then
        -- Mostra no console
        warn("🔍 [Tp Criança] NPCs encontrados no workspace:")
        for _, n in ipairs(found) do warn("  • "..n) end
        warn("  → Cole o nome correto no CHILD_NAMES!")

        -- Mostra os primeiros 4 como notificação na tela
        local preview = ""
        for i = 1, math.min(4, #found) do
            preview = preview .. "• " .. found[i] .. "\n"
        end
        if #found > 4 then preview = preview .. "... mais "..tostring(#found-4).." no F9" end

        Notify.send({type="warn", icon="🔍",
            title="Debug NPCs ("..tostring(#found)..")",
            msg=preview,
            duration=12})
    else
        Notify.warn("Debug","Nenhum NPC encontrado no workspace!")
    end
end

-- ── Tp Criança — Card com dropdown de seleção ──────────────────
do
local CHILD_COR = TP_COR_CHILD
local childDropOpen = false
local childDropPop  = nil

tpChildCard = Instance.new("Frame", Pages["Teleportar"])
tpChildCard.BackgroundColor3 = Color3.fromRGB(18,12,34)
tpChildCard.BorderSizePixel = 0
tpChildCard.Size = UDim2.new(1,0,0,90)
tpChildCard.LayoutOrder = tpNextLO(); tpChildCard.ZIndex = 5
Instance.new("UICorner",tpChildCard).CornerRadius = UDim.new(0,12)
tpChildStroke = Instance.new("UIStroke",tpChildCard)
tpChildStroke.Color = CHILD_COR; tpChildStroke.Thickness = 1.5; tpChildStroke.Transparency = 0.55
tpChildStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
-- Gradiente
local chG = Instance.new("UIGradient",tpChildCard)
chG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30,18,55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16,10,32)),
}); chG.Rotation = 135

-- Ícone
local chIconBg = Instance.new("Frame",tpChildCard)
chIconBg.BackgroundColor3 = CHILD_COR; chIconBg.BackgroundTransparency = 0.72
chIconBg.BorderSizePixel = 0
chIconBg.Position = UDim2.new(0,10,0.5,-18); chIconBg.Size = UDim2.new(0,36,0,36)
chIconBg.ZIndex = 6
Instance.new("UICorner",chIconBg).CornerRadius = UDim.new(0,10)
local chIconLbl = Instance.new("TextLabel",chIconBg); chIconLbl.BackgroundTransparency = 1
chIconLbl.Size = UDim2.new(1,0,1,0); chIconLbl.Text = "👶"
chIconLbl.TextSize = 18; chIconLbl.ZIndex = 7

-- Título
local chTitle = Instance.new("TextLabel",tpChildCard); chTitle.BackgroundTransparency = 1
chTitle.Position = UDim2.new(0,54,0,8); chTitle.Size = UDim2.new(0.45,0,0,18)
chTitle.Font = Enum.Font.GothamBlack; chTitle.Text = "Tp Criança"
chTitle.TextColor3 = Color3.fromRGB(220,210,255); chTitle.TextSize = 13
chTitle.TextXAlignment = Enum.TextXAlignment.Left; chTitle.ZIndex = 6

-- Descrição
local chDesc = Instance.new("TextLabel",tpChildCard); chDesc.BackgroundTransparency = 1
chDesc.Position = UDim2.new(0,54,0,28); chDesc.Size = UDim2.new(0.48,0,0,14)
chDesc.Font = Enum.Font.Gotham; chDesc.Text = "Selecione a criança e teleporte"
chDesc.TextColor3 = Color3.fromRGB(150,130,190); chDesc.TextSize = 9
chDesc.TextXAlignment = Enum.TextXAlignment.Left; chDesc.ZIndex = 6

-- ── Botão Dropdown de seleção ──────────────────────────────
local chSelBtn = Instance.new("TextButton",tpChildCard)
chSelBtn.BackgroundColor3 = Color3.fromRGB(28,16,52); chSelBtn.BackgroundTransparency = 0.1
chSelBtn.BorderSizePixel = 0
chSelBtn.Position = UDim2.new(0,10,0,50); chSelBtn.Size = UDim2.new(0.6,-18,0,28)
chSelBtn.ZIndex = 7; chSelBtn.AutoButtonColor = false
chSelBtn.TextTruncate = Enum.TextTruncate.AtEnd
Instance.new("UICorner",chSelBtn).CornerRadius = UDim.new(0,9)
local chSelS = Instance.new("UIStroke",chSelBtn)
chSelS.Color = CHILD_COR; chSelS.Thickness = 1.2; chSelS.Transparency = 0.5
chSelS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Label do dropdown
local chSelLbl = Instance.new("TextLabel",chSelBtn); chSelLbl.BackgroundTransparency = 1
chSelLbl.Position = UDim2.new(0,8,0,0); chSelLbl.Size = UDim2.new(1,-24,1,0)
chSelLbl.Font = Enum.Font.GothamBold; chSelLbl.Text = "👶  Child 1"
chSelLbl.TextColor3 = CHILD_COR; chSelLbl.TextSize = 10
chSelLbl.TextXAlignment = Enum.TextXAlignment.Left; chSelLbl.ZIndex = 8

-- Seta
local chSelArr = Instance.new("TextLabel",chSelBtn); chSelArr.BackgroundTransparency = 1
chSelArr.AnchorPoint = Vector2.new(1,0.5); chSelArr.Position = UDim2.new(1,-4,0.5,0)
chSelArr.Size = UDim2.new(0,14,0,14)
chSelArr.Font = Enum.Font.GothamBlack; chSelArr.Text = "▾"
chSelArr.TextColor3 = CHILD_COR; chSelArr.TextSize = 10; chSelArr.ZIndex = 8

-- ── Botão TP ──────────────────────────────────────────────
tpChildBtn = Instance.new("TextButton",tpChildCard)
tpChildBtn.BackgroundColor3 = CHILD_COR; tpChildBtn.BackgroundTransparency = 0.3
tpChildBtn.BorderSizePixel = 0
tpChildBtn.AnchorPoint = Vector2.new(1,1); tpChildBtn.Position = UDim2.new(1,-10,1,-8)
tpChildBtn.Size = UDim2.new(0,64,0,28); tpChildBtn.ZIndex = 7; tpChildBtn.AutoButtonColor = false
Instance.new("UICorner",tpChildBtn).CornerRadius = UDim.new(0,9)
local tpChildBtnS = Instance.new("UIStroke",tpChildBtn)
tpChildBtnS.Color = CHILD_COR; tpChildBtnS.Thickness = 1.2; tpChildBtnS.Transparency = 0.4
tpChildBtnS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tpChildBtnL = Instance.new("TextLabel",tpChildBtn); tpChildBtnL.BackgroundTransparency = 1
tpChildBtnL.Size = UDim2.new(1,0,1,0); tpChildBtnL.Font = Enum.Font.GothamBlack
tpChildBtnL.Text = "→ TP"; tpChildBtnL.TextColor3 = Color3.fromRGB(255,255,255)
tpChildBtnL.TextSize = 11; tpChildBtnL.ZIndex = 8

-- Hover TP
tpChildBtn.MouseEnter:Connect(function()
    TweenService:Create(tpChildBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.05}):Play()
end)
tpChildBtn.MouseLeave:Connect(function()
    TweenService:Create(tpChildBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.3}):Play()
end)

-- ── Popup dropdown das crianças ───────────────────────────
childDropPop = Instance.new("Frame", ScreenGui)
childDropPop.BackgroundColor3 = Color3.fromRGB(16,10,30)
childDropPop.BorderSizePixel = 0; childDropPop.ZIndex = 450
childDropPop.Visible = false; childDropPop.Size = UDim2.new(0,0,0,0)
childDropPop.ClipsDescendants = true
Instance.new("UICorner",childDropPop).CornerRadius = UDim.new(0,12)
local cdPopS = Instance.new("UIStroke",childDropPop)
cdPopS.Color = CHILD_COR; cdPopS.Thickness = 1.5; cdPopS.Transparency = 0.3
cdPopS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local cdLayout = Instance.new("UIListLayout",childDropPop)
cdLayout.SortOrder = Enum.SortOrder.LayoutOrder; cdLayout.Padding = UDim.new(0,3)
local cdPad = Instance.new("UIPadding",childDropPop)
cdPad.PaddingTop = UDim.new(0,6); cdPad.PaddingBottom = UDim.new(0,6)
cdPad.PaddingLeft = UDim.new(0,6); cdPad.PaddingRight = UDim.new(0,6)

local CHILD_POP_H = #CHILD_OPTIONS * 42 + 16

-- Cria itens do dropdown
for idx, opt in ipairs(CHILD_OPTIONS) do
    local item = Instance.new("TextButton",childDropPop)
    item.BackgroundColor3 = selectedChildName==opt.name and Color3.fromRGB(40,22,68) or Color3.fromRGB(24,14,44)
    item.BackgroundTransparency = selectedChildName==opt.name and 0.1 or 0.5
    item.BorderSizePixel = 0; item.Size = UDim2.new(1,0,0,36)
    item.LayoutOrder = idx; item.ZIndex = 451; item.AutoButtonColor = false
    Instance.new("UICorner",item).CornerRadius = UDim.new(0,8)
    local itemS = Instance.new("UIStroke",item)
    itemS.Color = opt.cor; itemS.Thickness = 1.1
    itemS.Transparency = selectedChildName==opt.name and 0.2 or 0.8
    itemS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Ícone
    local icoLbl = Instance.new("TextLabel",item); icoLbl.BackgroundTransparency = 1
    icoLbl.Position = UDim2.new(0,8,0,0); icoLbl.Size = UDim2.new(0,24,1,0)
    icoLbl.Font = Enum.Font.GothamBold; icoLbl.Text = opt.icon
    icoLbl.TextSize = 16; icoLbl.ZIndex = 452

    -- Nome
    local nameLbl = Instance.new("TextLabel",item); nameLbl.BackgroundTransparency = 1
    nameLbl.Position = UDim2.new(0,36,0,0); nameLbl.Size = UDim2.new(1,-50,1,0)
    nameLbl.Font = Enum.Font.GothamBold; nameLbl.Text = opt.name
    nameLbl.TextColor3 = selectedChildName==opt.name and Color3.new(1,1,1) or Color3.fromRGB(190,175,225)
    nameLbl.TextSize = 11; nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 452

    -- Check
    local chkLbl = Instance.new("TextLabel",item); chkLbl.BackgroundTransparency = 1
    chkLbl.AnchorPoint = Vector2.new(1,0.5); chkLbl.Position = UDim2.new(1,-8,0.5,0)
    chkLbl.Size = UDim2.new(0,16,0,16)
    chkLbl.Font = Enum.Font.GothamBlack; chkLbl.Text = selectedChildName==opt.name and "✓" or ""
    chkLbl.TextColor3 = opt.cor; chkLbl.TextSize = 11; chkLbl.ZIndex = 452

    item.MouseEnter:Connect(function()
        if selectedChildName ~= opt.name then
            TweenService:Create(item,TweenInfo.new(0.1),{BackgroundTransparency=0.3}):Play()
        end
    end)
    item.MouseLeave:Connect(function()
        if selectedChildName ~= opt.name then
            TweenService:Create(item,TweenInfo.new(0.1),{BackgroundTransparency=0.5}):Play()
        end
    end)

    item.MouseButton1Click:Connect(function()
        selectedChildName = opt.name
        -- Atualiza visual de todos os itens
        for i2, opt2 in ipairs(CHILD_OPTIONS) do
            local itm = cdLayout.Parent:GetChildren()[i2+2]  -- skip Layout + Padding
            if itm and itm:IsA("TextButton") then
                local sel = (opt2.name == selectedChildName)
                TweenService:Create(itm,TweenInfo.new(0.12),{
                    BackgroundColor3 = sel and Color3.fromRGB(40,22,68) or Color3.fromRGB(24,14,44),
                    BackgroundTransparency = sel and 0.1 or 0.5,
                }):Play()
            end
        end
        nameLbl.TextColor3 = Color3.new(1,1,1); chkLbl.Text = "✓"
        -- Atualiza botão
        chSelLbl.Text = opt.icon.."  "..opt.name
        chSelLbl.TextColor3 = opt.cor; chSelS.Color = opt.cor; chSelArr.TextColor3 = opt.cor
        tpChildBtnS.Color = opt.cor
        TweenService:Create(chSelBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.1}):Play()
        -- Fecha dropdown
        childDropOpen = false
        TweenService:Create(childDropPop,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Size=UDim2.new(0,childDropPop.AbsoluteSize.X,0,0),BackgroundTransparency=0.4}):Play()
        task.delay(0.16,function() childDropPop.Visible=false; childDropPop.BackgroundTransparency=0 end)
        TweenService:Create(chSelArr,TweenInfo.new(0.18),{Rotation=0}):Play()
        Notify.send({type="info",icon=opt.icon,accent=opt.cor,
            title="Criança selecionada",msg=opt.name,duration=2})
    end)
end

-- Abrir/fechar dropdown
local function openChildDrop()
    if _vdOpen and _vdOpen~=childDropPop then
        TweenService:Create(_vdOpen,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Size=UDim2.new(0,_vdOpen.AbsoluteSize.X,0,0)}):Play()
        task.delay(0.13,function() _vdOpen.Visible=false end)
    end
    local ap=chSelBtn.AbsolutePosition; local as=chSelBtn.AbsoluteSize
    childDropPop.Position = UDim2.new(0,ap.X,0,ap.Y+as.Y+6)
    childDropPop.Size = UDim2.new(0,as.X,0,0)
    childDropPop.BackgroundTransparency = 0.4; childDropPop.Visible = true
    TweenService:Create(childDropPop,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,as.X,0,CHILD_POP_H),BackgroundTransparency=0}):Play()
    childDropOpen = true; _vdOpen = childDropPop
    TweenService:Create(chSelArr,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=180}):Play()
    TweenService:Create(chSelS,TweenInfo.new(0.1),{Transparency=0.1}):Play()
end

local function closeChildDrop()
    childDropOpen = false
    TweenService:Create(childDropPop,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,childDropPop.AbsoluteSize.X,0,0),BackgroundTransparency=0.4}):Play()
    task.delay(0.16,function() childDropPop.Visible=false; childDropPop.BackgroundTransparency=0 end)
    _vdOpen = nil
    TweenService:Create(chSelArr,TweenInfo.new(0.18),{Rotation=0}):Play()
    TweenService:Create(chSelS,TweenInfo.new(0.1),{Transparency=0.5}):Play()
end

chSelBtn.MouseButton1Click:Connect(function()
    if childDropOpen then closeChildDrop() else openChildDrop() end
end)
UserInputService.InputBegan:Connect(function(inp)
    if not childDropOpen then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    local mp = UserInputService:GetMouseLocation()
    local function inside(f) local a,s=f.AbsolutePosition,f.AbsoluteSize
        return mp.X>=a.X and mp.X<=a.X+s.X and mp.Y>=a.Y and mp.Y<=a.Y+s.Y end
    if not inside(childDropPop) and not inside(chSelBtn) then closeChildDrop() end
end)

-- ── Botão TP action ───────────────────────────────────────
tpChildBtn.MouseButton1Click:Connect(function()
    tpChildBtnL.Text = "⏳"
    TweenService:Create(tpChildBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.55}):Play()
    task.spawn(function()
        -- Tenta pelo nome exato primeiro
        local pos = findChildByName(selectedChildName)
        if pos then
            safeTp(pos, 3)
            tpChildBtnL.Text = "✓"
            TweenService:Create(tpChildBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.3}):Play()
            TweenService:Create(tpChildStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(87,242,135),Transparency=0.2}):Play()
            task.delay(2, function()
                tpChildBtnL.Text = "→ TP"
                TweenService:Create(tpChildStroke,TweenInfo.new(0.3),{Color=CHILD_COR,Transparency=0.55}):Play()
            end)
            local opt = CHILD_OPTIONS[1]
            for _,o in ipairs(CHILD_OPTIONS) do if o.name==selectedChildName then opt=o; break end end
            Notify.send({type="custom",icon=opt.icon,accent=opt.cor,
                title="Tp Criança",msg="Teleportado para "..selectedChildName,duration=3})
        else
            tpChildBtnL.Text = "→ TP"
            TweenService:Create(tpChildBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.3}):Play()
            TweenService:Create(tpChildStroke,TweenInfo.new(0.1),{Color=Color3.fromRGB(255,60,60),Transparency=0.2}):Play()
            task.delay(1.5, function()
                TweenService:Create(tpChildStroke,TweenInfo.new(0.3),{Color=CHILD_COR,Transparency=0.55}):Play()
            end)
            Notify.warn("Tp Criança","⚠️ "..selectedChildName.." não encontrada no workspace!")
        end
    end)
end)
end -- do Tp Criança

-- ══════════════════════════════════════════════════════════════
-- 7. PAINEL DE CONSTRUÇÕES v3 — Grupos por BIOMA, sem mistura
-- ══════════════════════════════════════════════════════════════
makeTpSec("🏗️  PAINEL DE CONSTRUÇÕES", TP_COR_BUILD)

-- ── Biomas com keywords para detectar pelo nome do objeto OU ancestrais
-- A detecção SOBE a hierarquia até 6 níveis para pegar o folder do bioma
-- Ordem importa: mais específico primeiro para evitar match errado
-- Cada entrada tem dois grupos de keys:
--   nameKeys = detecta pelo NOME DO PRÓPRIO OBJETO
--   hierKeys = detecta pelo nome de QUALQUER ANCESTRAL
local BUILD_BIOMES = {
    { label="Vulcão",    icon="🌋", cor=Color3.fromRGB(255,90,20),
      nameKeys={"volcano","volcanic","lava","scorpion pit","ammo furnace","hellephant","lava pool","lava fall","volcanic church","volcano entrance","infernal","molten","cinder","magma","igneo","ignea","caldera","ember","scorch"},
      hierKeys={"volcano","vulcao","vulcão","lava biome","volcanic biome","volcano_biome","vulcao_biome"} },
    { label="Selva",     icon="🌿", cor=Color3.fromRGB(40,200,80),
      nameKeys={"jungle temple","mother temple","jungle cultist","tarpit","tar pit","jungle ruins","jungle outpost","jungle camp","ancient temple","overgrown"},
      hierKeys={"jungle","selva","jungle_biome","selva_biome","tropics","rainforest"} },
    { label="Neve/Gelo", icon="❄️", cor=Color3.fromRGB(140,220,255),
      nameKeys={"ice cabin","snow cabin","frozen tower","ice cave","blizzard","tundra outpost","frozen ruins","arctic camp","glacier","iceberg","ice fortress","ice mine","ice tower","snowstorm","frozen church"},
      hierKeys={"ice","snow","frozen","winter","gelo","neve","blizzard","tundra","glacier","arctic","ice_biome","snow_biome","frozen_biome","winter_biome"} },
    { label="Pântano",   icon="🐸", cor=Color3.fromRGB(90,200,70),
      nameKeys={"frog tower","swamp hut","swamp cabin","marsh camp","bog","swamp temple","frog shrine","swampland","pantano","pântano","murky"},
      hierKeys={"frog","swamp","pantano","pântano","marsh","swampland","bog","swamp_biome","frog_biome"} },
    { label="UFO/Alien", icon="🛸", cor=Color3.fromRGB(60,255,170),
      nameKeys={"broken ufo","mothership","alien base","alien lab","ufo crash","alien outpost","alien ruins","alien tower","ufo facility","nave mae","nave-mãe","ovni","alien ship"},
      hierKeys={"ufo","alien","mothership","nave","alien_biome","ufo_biome"} },
    { label="Fada",      icon="🧚", cor=Color3.fromRGB(255,150,255),
      nameKeys={"giant tree","mother tree","fairy tower","enchanted","brightwood","fairy shrine","fairy ruins","fairy camp","fairy outpost","fada","faerie","elven","elf tower","fairy"},
      hierKeys={"fairy","fada","brightwood","enchanted forest","fairy_biome","fada_biome","fairytale","fairyforest"} },
    { label="Cultistas", icon="⚔️", cor=Color3.fromRGB(200,100,50),
      nameKeys={"cultist stronghold","cultist tower","cultist temple","cultist base","cultist king","cultist camp","cultist outpost","cultist ruins","dark shrine","black altar","demonic"},
      hierKeys={"cultist","cultistas","dark biome","cultist_biome"} },
    { label="Caverna",   icon="🕳️", cor=Color3.fromRGB(140,100,60),
      nameKeys={"mine entrance","mine shaft","mineshaft","cavern entrance","cave entrance","underground camp","cave mine","deep mine","crystal cave","mushroom cave"},
      hierKeys={"cave","cavern","mine","caverna","mina","underground","subterranean","cave_biome","mine_biome"} },
}

-- Detecta bioma em 3 passes:
-- 1) Nome do próprio objeto (nameKeys)
-- 2) Hierarquia de ancestrais (hierKeys) — até 10 níveis
-- 3) Fallback: Floresta
local function bpGetBiomeFromObj(obj)
    local ownName = obj.Name:lower()
    -- Passe 1: nome do próprio objeto
    for _, b in ipairs(BUILD_BIOMES) do
        for _, kw in ipairs(b.nameKeys) do
            if ownName:find(kw,1,true) then return b.label, b.icon, b.cor end
        end
    end
    -- Passe 2: ancestrais (hierKeys)
    local cur = obj.Parent
    for _ = 1, 10 do
        if not cur or cur == workspace or cur == game then break end
        local nm = cur.Name:lower()
        for _, b in ipairs(BUILD_BIOMES) do
            for _, kw in ipairs(b.hierKeys) do
                if nm:find(kw,1,true) then return b.label, b.icon, b.cor end
            end
        end
        -- Passe 1.5: hierarquia também checa nameKeys para pastas de bioma
        for _, b in ipairs(BUILD_BIOMES) do
            for _, kw in ipairs(b.nameKeys) do
                if nm:find(kw,1,true) then return b.label, b.icon, b.cor end
            end
        end
        cur = cur.Parent
    end
    return "Floresta", "🌲", Color3.fromRGB(80,200,80)
end

-- ── Estruturas especiais: detectadas pelo nome exato OU substring
-- Mostradas com ícone próprio dentro do grupo do bioma
local SPECIAL_STRUCTS = {
    -- Fada
    { name="giant tree",   icon="🌳", label="Árvore Gigante" },
    { name="mother tree",  icon="🌳", label="Mãe das Árvores" },
    { name="fairy tower",  icon="🗼", label="Torre Fada" },
    { name="enchanted",    icon="✨", label="Estrutura Encantada" },
    -- Vulcão
    { name="volcano entrance", icon="🌋", label="Entrada do Vulcão" },
    { name="volcano_entrance", icon="🌋", label="Entrada do Vulcão" },
    { name="volcanic church",  icon="⛪", label="Igreja Vulcânica" },
    { name="ammo furnace",     icon="🔥", label="Fornalha de Munição" },
    { name="scorpion pit",     icon="🦂", label="Fosso do Escorpião" },
    { name="lava pool",        icon="🌊", label="Piscina de Lava" },
    { name="lava fall",        icon="💧", label="Cachoeira de Lava" },
    { name="hellephant",       icon="🐘", label="Hellephant" },
    -- UFO
    { name="broken ufo",    icon="🛸", label="UFO Partido" },
    { name="mothership",    icon="🛸", label="Nave-Mãe" },
    -- Selva
    { name="jungle temple", icon="🏛️", label="Templo da Selva" },
    { name="mother temple", icon="🏛️", label="Templo da Mãe" },
    { name="tar pit",       icon="⬛", label="Fosso de Alcatrão" },
    -- Cultistas
    { name="cultist stronghold", icon="⚔️", label="Fortaleza Cultista" },
    { name="cultist tower",      icon="🗼", label="Torre Cultista" },
    { name="cultist king",       icon="👑", label="Rei Cultista" },
    { name="cultist base",       icon="🏚️", label="Base Cultista" },
    { name="cultist temple",     icon="🏛️", label="Templo Cultista" },
    -- Gerais especiais
    { name="meteor crater",  icon="☄️", label="Cratera Meteoro" },
    { name="watchtower",     icon="🗼", label="Torre de Vigia" },
    { name="watch tower",    icon="🗼", label="Torre de Vigia" },
    { name="lookout tower",  icon="🗼", label="Torre de Observação" },
    { name="guard tower",    icon="🗼", label="Torre de Guarda" },
    { name="bell tower",     icon="🔔", label="Torre do Sino" },
    { name="radio tower",    icon="📡", label="Torre de Rádio" },
    { name="water tower",    icon="🚰", label="Torre d'Água" },
}

local function bpGetStructIcon(nameLow)
    for _, s in ipairs(SPECIAL_STRUCTS) do
        if nameLow:find(s.name, 1, true) then return s.icon, s.label end
    end
    -- Ícone padrão por tipo
    if nameLow:find("tower",1,true) or nameLow:find("watchtower",1,true) then return "🗼", nil end
    if nameLow:find("cabin",1,true) or nameLow:find("lodge",1,true) then return "🏠", nil end
    if nameLow:find("house",1,true) or nameLow:find("hut",1,true) or nameLow:find("cottage",1,true) then return "🏡", nil end
    if nameLow:find("mine",1,true) or nameLow:find("cave",1,true) or nameLow:find("bunker",1,true) then return "⛏️", nil end
    if nameLow:find("church",1,true) or nameLow:find("temple",1,true) then return "⛪", nil end
    if nameLow:find("camp",1,true) or nameLow:find("tent",1,true) then return "⛺", nil end
    if nameLow:find("farm",1,true) or nameLow:find("barn",1,true) or nameLow:find("silo",1,true) then return "🌾", nil end
    if nameLow:find("pond",1,true) or nameLow:find("spring",1,true) or nameLow:find("pool",1,true) then return "🐟", nil end
    if nameLow:find("wreck",1,true) or nameLow:find("crash",1,true) or nameLow:find("ruin",1,true) then return "🏚️", nil end
    if nameLow:find("fort",1,true) or nameLow:find("stronghold",1,true) or nameLow:find("base",1,true) then return "⚔️", nil end
    return "🏗️", nil
end

-- Keywords para detectar se um Model é uma construção
local BUILD_KW = {
    "cabin","shed","house","hut","shack","cottage","bungalow","chalet","home",
    "tower","watchtower","lighthouse","church","barn","farm","silo","windmill",
    "clinic","hospital","bank","depot","warehouse","market","shop","diner","bakery",
    "camp","outpost","checkpoint","base","fort","fortress","stronghold","temple",
    "bunker","mine","mineshaft","cave","cavern","tunnel",
    "ruins","ruin","wreckage","crash","crater","pit","pond","pool","spring",
    "armory","barricade","playground","restroom","court",
    "ufo","alien","cultist","volcanic","volcano",
    "jungle","tarpit","tar pit","mother temple",
    "giant tree","mother tree","enchanted","fairy",
    "scorpion","furnace","hellephant","mothership",
    "shelter","lodge","station","post office","museum","library","school",
}
local function bpIsBuilding(nm)
    for _, kw in ipairs(BUILD_KW) do
        if nm:find(kw, 1, true) then return true end
    end
    return false
end

-- ── Estado ────────────────────────────────────────────────────
local buildGroups    = {}   -- { biomeLabel, icon, cor, entries={}, groupBtn, countLbl }
local buildGroupMap  = {}   -- [biomeLabel] -> group
local buildSeenKeys  = {}   -- dedup por posição
local buildVisited   = {}   -- [nameKey] -> true
local bpScanRunning  = false
local bpCurrentGroup = nil

local function bpNameKey(name, pos)
    return name:lower()..":"..math.floor(pos.X/8)..","..math.floor(pos.Z/8)
end
local function bpPosKey(pos)
    return math.floor(pos.X/8)..","..math.floor(pos.Y/8)..","..math.floor(pos.Z/8)
end

-- ── Container principal ──────────────────────────────────────
local bpCard = Instance.new("Frame", Pages["Teleportar"])
bpCard.BackgroundColor3 = Color3.fromRGB(48,30,78)
bpCard.BorderSizePixel = 0; bpCard.Size = UDim2.new(1,0,0,310)
bpCard.LayoutOrder = tpNextLO(); bpCard.ZIndex = 5
Instance.new("UICorner",bpCard).CornerRadius = UDim.new(0,14)
local bpCardStroke = Instance.new("UIStroke",bpCard)
bpCardStroke.Color = Color3.fromRGB(148,112,220); bpCardStroke.Thickness = 4.5
local bpCardGrad = Instance.new("UIGradient",bpCard)
bpCardGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(38,24,12)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,4)),
}); bpCardGrad.Rotation = 140

-- ── Header ──────────────────────────────────────────────────
local bpHdr = Instance.new("Frame",bpCard)
bpHdr.BackgroundColor3 = Color3.fromRGB(148,112,220)
bpHdr.BorderSizePixel = 0; bpHdr.Size = UDim2.new(1,0,0,48); bpHdr.ZIndex = 6
Instance.new("UICorner",bpHdr).CornerRadius = UDim.new(0,12)
local bpHdrFix = Instance.new("Frame",bpHdr)
bpHdrFix.BackgroundColor3 = Color3.fromRGB(148,112,220); bpHdrFix.BorderSizePixel = 0
bpHdrFix.Position = UDim2.new(0,0,0.5,0); bpHdrFix.Size = UDim2.new(1,0,0.5,0); bpHdrFix.ZIndex = 6
local bpHdrGrad = Instance.new("UIGradient",bpHdr)
bpHdrGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(190,165,245)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(148,112,220)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(108,74,170)),
}); bpHdrGrad.Rotation = 0
local bpHdrStroke = Instance.new("UIStroke",bpHdr)
bpHdrStroke.Color = Color3.fromRGB(15,8,30); bpHdrStroke.Thickness = 3
local bpHdrShine = Instance.new("Frame",bpHdr)
bpHdrShine.Size = UDim2.new(0,60,0,10); bpHdrShine.Position = UDim2.new(0,8,0,5)
bpHdrShine.BackgroundColor3 = Color3.fromRGB(255,255,255); bpHdrShine.BackgroundTransparency = 0.6
bpHdrShine.BorderSizePixel = 0; bpHdrShine.Rotation = -4; bpHdrShine.ZIndex = 8
Instance.new("UICorner",bpHdrShine).CornerRadius = UDim.new(1,0)

local bpHdrIco = Instance.new("TextLabel",bpHdr); bpHdrIco.BackgroundTransparency = 1
bpHdrIco.Position = UDim2.new(0,10,0.5,-14); bpHdrIco.Size = UDim2.new(0,28,0,28)
bpHdrIco.Font = Enum.Font.GothamBlack; bpHdrIco.Text = "🏗️"; bpHdrIco.TextSize = 20; bpHdrIco.ZIndex = 7

local bpHdrTitle = Instance.new("TextLabel",bpHdr); bpHdrTitle.BackgroundTransparency = 1
bpHdrTitle.Position = UDim2.new(0,44,0,6); bpHdrTitle.Size = UDim2.new(0,140,0,18)
bpHdrTitle.Font = Enum.Font.GothamBlack; bpHdrTitle.Text = "Construções"
bpHdrTitle.TextColor3 = Color3.fromRGB(16,8,30); bpHdrTitle.TextSize = 13
bpHdrTitle.TextXAlignment = Enum.TextXAlignment.Left; bpHdrTitle.ZIndex = 7
local bpHdrTS = Instance.new("UIStroke",bpHdrTitle); bpHdrTS.Color=Color3.fromRGB(180,110,0); bpHdrTS.Thickness=1.2

local bpHdrSub = Instance.new("TextLabel",bpHdr); bpHdrSub.BackgroundTransparency = 1
bpHdrSub.Position = UDim2.new(0,44,0,26); bpHdrSub.Size = UDim2.new(0,180,0,14)
bpHdrSub.Font = Enum.Font.Gotham; bpHdrSub.Text = "0 biomas · 0 construções"
bpHdrSub.TextColor3 = Color3.fromRGB(80,50,10); bpHdrSub.TextSize = 9
bpHdrSub.TextXAlignment = Enum.TextXAlignment.Left; bpHdrSub.ZIndex = 7

local bpBtnRef = Instance.new("TextButton",bpHdr)
bpBtnRef.BackgroundColor3 = Color3.fromRGB(16,8,30); bpBtnRef.BackgroundTransparency = 0.1; bpBtnRef.Text = ""
bpBtnRef.BorderSizePixel = 0; bpBtnRef.Position = UDim2.new(1,-88,0.5,-14)
bpBtnRef.Size = UDim2.new(0,38,0,28); bpBtnRef.ZIndex = 8
Instance.new("UICorner",bpBtnRef).CornerRadius = UDim.new(0,9)
local bpBtnRefS = Instance.new("UIStroke",bpBtnRef); bpBtnRefS.Color=Color3.fromRGB(15,8,30); bpBtnRefS.Thickness=2.5
local bpBtnRefL = Instance.new("TextLabel",bpBtnRef); bpBtnRefL.BackgroundTransparency = 1
bpBtnRefL.Size = UDim2.new(1,0,1,0); bpBtnRefL.Font = Enum.Font.GothamBlack
bpBtnRefL.Text = "🔄"; bpBtnRefL.TextColor3 = Color3.fromRGB(210,190,250); bpBtnRefL.TextSize = 14; bpBtnRefL.ZIndex = 9

local bpBtnClr = Instance.new("TextButton",bpHdr)
bpBtnClr.BackgroundColor3 = Color3.fromRGB(200,50,50); bpBtnClr.BackgroundTransparency = 0.1; bpBtnClr.Text = ""
bpBtnClr.BorderSizePixel = 0; bpBtnClr.Position = UDim2.new(1,-44,0.5,-14)
bpBtnClr.Size = UDim2.new(0,38,0,28); bpBtnClr.ZIndex = 8
Instance.new("UICorner",bpBtnClr).CornerRadius = UDim.new(0,9)
local bpBtnClrS = Instance.new("UIStroke",bpBtnClr); bpBtnClrS.Color=Color3.fromRGB(80,0,0); bpBtnClrS.Thickness=2.5
local bpBtnClrL = Instance.new("TextLabel",bpBtnClr); bpBtnClrL.BackgroundTransparency = 1
bpBtnClrL.Size = UDim2.new(1,0,1,0); bpBtnClrL.Font = Enum.Font.GothamBlack
bpBtnClrL.Text = "🗑️"; bpBtnClrL.TextColor3 = Color3.fromRGB(255,180,180); bpBtnClrL.TextSize = 14; bpBtnClrL.ZIndex = 9

-- ── Vista de Biomas (nível 1) ────────────────────────────────
local bpGroupView = Instance.new("ScrollingFrame",bpCard)
bpGroupView.BackgroundTransparency = 1; bpGroupView.BorderSizePixel = 0
bpGroupView.Position = UDim2.new(0,0,0,52); bpGroupView.Size = UDim2.new(1,0,1,-56)
bpGroupView.ZIndex = 6; bpGroupView.ScrollBarThickness = 3
bpGroupView.ScrollBarImageColor3 = TP_COR_BUILD
bpGroupView.AutomaticCanvasSize = Enum.AutomaticSize.Y; bpGroupView.CanvasSize = UDim2.new(0,0,0,0)
local bpGroupLayout = Instance.new("UIListLayout",bpGroupView)
bpGroupLayout.Padding = UDim.new(0,6); bpGroupLayout.SortOrder = Enum.SortOrder.LayoutOrder
local bpGroupPad = Instance.new("UIPadding",bpGroupView)
bpGroupPad.PaddingTop = UDim.new(0,6); bpGroupPad.PaddingLeft = UDim.new(0,8)
bpGroupPad.PaddingRight = UDim.new(0,8); bpGroupPad.PaddingBottom = UDim.new(0,8)

local bpEmptyLbl = Instance.new("TextLabel",bpGroupView)
bpEmptyLbl.BackgroundTransparency = 1; bpEmptyLbl.Size = UDim2.new(1,0,0,60)
bpEmptyLbl.Font = Enum.Font.GothamBold; bpEmptyLbl.Text = "🔍  Clique em 🔄 para escanear construções"
bpEmptyLbl.TextColor3 = Color3.fromRGB(100,80,30); bpEmptyLbl.TextSize = 11
bpEmptyLbl.TextWrapped = true; bpEmptyLbl.TextXAlignment = Enum.TextXAlignment.Center
bpEmptyLbl.ZIndex = 7; bpEmptyLbl.LayoutOrder = 999

-- ── Vista de Estruturas do bioma (nível 2) ───────────────────
local bpDetailView = Instance.new("Frame",bpCard)
bpDetailView.BackgroundTransparency = 1; bpDetailView.BorderSizePixel = 0
bpDetailView.Position = UDim2.new(1,0,0,52); bpDetailView.Size = UDim2.new(1,0,1,-56)
bpDetailView.ZIndex = 7; bpDetailView.Visible = false

local bpDetailHdr = Instance.new("Frame",bpDetailView)
bpDetailHdr.BackgroundColor3 = Color3.fromRGB(56,36,92); bpDetailHdr.BorderSizePixel = 0
bpDetailHdr.Size = UDim2.new(1,0,0,40); bpDetailHdr.ZIndex = 8
Instance.new("UICorner",bpDetailHdr).CornerRadius = UDim.new(0,10)
local bpDetailHdrS = Instance.new("UIStroke",bpDetailHdr)
bpDetailHdrS.Color = Color3.fromRGB(148,112,220); bpDetailHdrS.Thickness = 2.5; bpDetailHdrS.Transparency = 0.5

local bpBackBtn = Instance.new("TextButton",bpDetailHdr)
bpBackBtn.BackgroundColor3 = Color3.fromRGB(148,112,220); bpBackBtn.BackgroundTransparency = 0.1; bpBackBtn.Text = ""
bpBackBtn.BorderSizePixel = 0; bpBackBtn.Position = UDim2.new(0,8,0.5,-14); bpBackBtn.Size = UDim2.new(0,64,0,28); bpBackBtn.ZIndex = 9
Instance.new("UICorner",bpBackBtn).CornerRadius = UDim.new(0,9)
local bpBackBtnS = Instance.new("UIStroke",bpBackBtn); bpBackBtnS.Color=Color3.fromRGB(15,8,30); bpBackBtnS.Thickness=2.5
local bpBackBtnL = Instance.new("TextLabel",bpBackBtn); bpBackBtnL.BackgroundTransparency = 1
bpBackBtnL.Size = UDim2.new(1,0,1,0); bpBackBtnL.Font = Enum.Font.GothamBlack
bpBackBtnL.Text = "◀ Voltar"; bpBackBtnL.TextColor3 = Color3.fromRGB(16,8,30); bpBackBtnL.TextSize = 9; bpBackBtnL.ZIndex = 10

local bpDetailTitle = Instance.new("TextLabel",bpDetailHdr); bpDetailTitle.BackgroundTransparency = 1
bpDetailTitle.Position = UDim2.new(0,80,0.5,-10); bpDetailTitle.Size = UDim2.new(1,-170,0,20)
bpDetailTitle.Font = Enum.Font.GothamBlack; bpDetailTitle.Text = ""
bpDetailTitle.TextColor3 = Color3.fromRGB(148,112,220); bpDetailTitle.TextSize = 12
bpDetailTitle.TextXAlignment = Enum.TextXAlignment.Left; bpDetailTitle.ZIndex = 9

local bpDetailCount = Instance.new("TextLabel",bpDetailHdr); bpDetailCount.BackgroundTransparency = 1
bpDetailCount.Position = UDim2.new(1,-80,0.5,-8); bpDetailCount.Size = UDim2.new(0,72,0,16)
bpDetailCount.Font = Enum.Font.GothamBold; bpDetailCount.Text = "0 local"
bpDetailCount.TextColor3 = Color3.fromRGB(180,140,50); bpDetailCount.TextSize = 9
bpDetailCount.TextXAlignment = Enum.TextXAlignment.Right; bpDetailCount.ZIndex = 9

-- !! SCROLL POR GRUPO: cada grupo tem seu próprio ScrollingFrame !!
-- Criados dinamicamente quando o grupo é criado
-- Todos filhos de bpDetailView, só o atual fica visível

-- ── Navegação ────────────────────────────────────────────────
local function bpShowDetail(grp)
    bpCurrentGroup = grp
    bpDetailTitle.Text = grp.icon.." "..grp.label
    bpDetailTitle.TextColor3 = grp.cor
    bpDetailCount.Text = tostring(grp.totalCount).." local(is)"
    -- Oculta scroll de outros grupos, mostra o do grupo atual
    for _, g in pairs(buildGroupMap) do
        if g.scroll then g.scroll.Visible = (g == grp) end
    end
    TweenService:Create(bpGroupView,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{Position=UDim2.new(-1,0,0,52)}):Play()
    task.delay(0.15, function()
        bpGroupView.Visible = false; bpGroupView.Position = UDim2.new(0,0,0,52)
        bpDetailView.Position = UDim2.new(1,0,0,52); bpDetailView.Visible = true
        TweenService:Create(bpDetailView,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,52)}):Play()
    end)
end

local function bpShowGroups()
    TweenService:Create(bpDetailView,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{Position=UDim2.new(1,0,0,52)}):Play()
    task.delay(0.15, function()
        bpDetailView.Visible = false; bpDetailView.Position = UDim2.new(0,0,0,52)
        bpGroupView.Position = UDim2.new(-1,0,0,52); bpGroupView.Visible = true
        TweenService:Create(bpGroupView,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,52)}):Play()
    end)
    bpCurrentGroup = nil
end

bpBackBtn.MouseButton1Click:Connect(bpShowGroups)

-- ── Cria grupo de bioma ───────────────────────────────────────
-- ── Tipos de estrutura para sub-agrupamento dentro do bioma ──────
local STRUCT_TYPES = {
    {key="especial",     label="Especiais",      icon="✨", lo=1000,
     kw={"giant tree","mother tree","mothership","hellephant","cultist king","lava pool","lava fall","scorpion pit","ammo furnace","volcanic church","tar pit","mother temple","broken ufo","meteor crater","fairy tower","enchanted","alien lab","alien base"}},
    {key="templo",       label="Templos & Igrejas",icon="⛪",lo=2000,
     kw={"temple","church","shrine","altar","sanctum","cathedral","chapel","tabernacle"}},
    {key="torre",        label="Torres",          icon="🗼", lo=3000,
     kw={"tower","watchtower","lighthouse","radio tower","bell tower","guard tower","lookout tower","turret","watchtower"}},
    {key="forte",        label="Fortes & Bases",  icon="⚔️", lo=4000,
     kw={"stronghold","fortress","fort","bunker","armory","barricade","checkpoint","outpost","base","citadel"}},
    {key="abrigo",       label="Abrigos",         icon="🏠", lo=5000,
     kw={"cabin","house","hut","shack","cottage","chalet","bungalow","shed","lodge","shelter","home","diner","bakery","clinic","shop","market","bank","depot","warehouse","barn","farm","silo","windmill","station","museum","library","school","restroom"}},
    {key="acampamento",  label="Acampamentos",    icon="⛺", lo=6000,
     kw={"camp","tent","campsite","bivouac"}},
    {key="mina",         label="Minas & Cavernas",icon="⛏️",lo=7000,
     kw={"mine","mineshaft","cave","cavern","tunnel","underground","quarry","grotto"}},
    {key="ruinas",       label="Ruínas",          icon="🏚️", lo=8000,
     kw={"ruin","ruins","wreckage","crash","abandoned","ancient","relic","remains","crater","wreck","debris"}},
}
local function bpGetStructType(nm)
    for _, t in ipairs(STRUCT_TYPES) do
        for _, kw in ipairs(t.kw) do
            if nm:find(kw,1,true) then return t end
        end
    end
    return {key="outros", label="Outros", icon="🏗️", lo=9000}
end

local bpBiomeOrder = 0
local function bpGetOrCreateGroup(biomeLabel, biomeIcon, biomeCor)
    if buildGroupMap[biomeLabel] then return buildGroupMap[biomeLabel] end
    bpBiomeOrder = bpBiomeOrder + 1
    local lo = (biomeLabel == "Floresta") and 0 or bpBiomeOrder
    local COR = biomeCor or Color3.fromRGB(150,180,100)
    local grp = {
        label=biomeLabel, icon=biomeIcon, cor=COR,
        entries={}, groupBtn=nil, countLbl=nil, scroll=nil,
        typeHeaders={},   -- [typeKey] -> Frame header
        typeCounts={},    -- [typeKey] -> count added
        totalCount=0,     -- total entries this biome
    }
    buildGroupMap[biomeLabel] = grp
    table.insert(buildGroups, grp)

    -- ── Botão do bioma ──────────────────────────────────────────
    local btn = Instance.new("Frame", bpGroupView)
    btn.BackgroundColor3 = Color3.fromRGB(56,36,92); btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1,0,0,72); btn.ZIndex = 7; btn.LayoutOrder = lo
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,14)
    local btnS = Instance.new("UIStroke",btn); btnS.Color=COR; btnS.Thickness=4; btnS.Transparency=0.2
    local btnBg = Instance.new("Frame",btn); btnBg.BackgroundColor3=COR; btnBg.BackgroundTransparency=0.88
    btnBg.BorderSizePixel=0; btnBg.Size=UDim2.new(1,0,1,0); btnBg.ZIndex=7
    Instance.new("UICorner",btnBg).CornerRadius=UDim.new(0,14)
    -- Barra lateral
    local btnBar = Instance.new("Frame",btn); btnBar.BackgroundColor3=COR; btnBar.BorderSizePixel=0
    btnBar.Position=UDim2.new(0,0,0.18,0); btnBar.Size=UDim2.new(0,5,0.64,0); btnBar.ZIndex=9
    Instance.new("UICorner",btnBar).CornerRadius=UDim.new(0,3)
    -- Ícone bioma
    local icoBox = Instance.new("Frame",btn); icoBox.BackgroundColor3=COR; icoBox.BackgroundTransparency=0.52
    icoBox.BorderSizePixel=0; icoBox.Position=UDim2.new(0,12,0.5,-26); icoBox.Size=UDim2.new(0,52,0,52); icoBox.ZIndex=8
    Instance.new("UICorner",icoBox).CornerRadius=UDim.new(0,13)
    local icoBoxS = Instance.new("UIStroke",icoBox); icoBoxS.Color=Color3.fromRGB(15,8,30); icoBoxS.Thickness=2.5; icoBoxS.Transparency=0.25
    local icoLbl = Instance.new("TextLabel",icoBox); icoLbl.BackgroundTransparency=1
    icoLbl.Size=UDim2.new(1,0,1,0); icoLbl.Font=Enum.Font.GothamBlack
    icoLbl.Text=biomeIcon; icoLbl.TextSize=28; icoLbl.ZIndex=9
    -- Nome
    local nameLbl = Instance.new("TextLabel",btn); nameLbl.BackgroundTransparency=1
    nameLbl.Position=UDim2.new(0,74,0,12); nameLbl.Size=UDim2.new(1,-130,0,22)
    nameLbl.Font=Enum.Font.GothamBlack; nameLbl.Text=biomeLabel
    nameLbl.TextColor3=Color3.fromRGB(220,200,255); nameLbl.TextSize=13
    nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=8
    local nameS = Instance.new("UIStroke",nameLbl); nameS.Color=Color3.fromRGB(0,0,0); nameS.Thickness=0.8; nameS.Transparency=0.5
    -- Badge contador
    local cntBadge = Instance.new("Frame",btn); cntBadge.BackgroundColor3=COR; cntBadge.BackgroundTransparency=0.12
    cntBadge.BorderSizePixel=0; cntBadge.Position=UDim2.new(0,74,0,38); cntBadge.Size=UDim2.new(0,80,0,20); cntBadge.ZIndex=8
    Instance.new("UICorner",cntBadge).CornerRadius=UDim.new(0,7)
    local cntBadgeS = Instance.new("UIStroke",cntBadge); cntBadgeS.Color=Color3.fromRGB(15,8,30); cntBadgeS.Thickness=1.8
    local cntLbl = Instance.new("TextLabel",cntBadge); cntLbl.BackgroundTransparency=1
    cntLbl.Size=UDim2.new(1,0,1,0); cntLbl.Font=Enum.Font.GothamBold
    cntLbl.Text="0 construções"; cntLbl.TextColor3=Color3.fromRGB(255,255,255); cntLbl.TextSize=9; cntLbl.ZIndex=9
    grp.countLbl = cntLbl
    -- Seta
    local arrowLbl = Instance.new("TextLabel",btn); arrowLbl.BackgroundTransparency=1
    arrowLbl.AnchorPoint=Vector2.new(1,0.5); arrowLbl.Position=UDim2.new(1,-14,0.5,0)
    arrowLbl.Size=UDim2.new(0,22,0,22); arrowLbl.Font=Enum.Font.GothamBlack
    arrowLbl.Text="▶"; arrowLbl.TextColor3=COR; arrowLbl.TextSize=16; arrowLbl.ZIndex=8
    grp.groupBtn = btn

    -- ── Scroll exclusivo para este bioma (dentro de bpDetailView) ─
    local scroll = Instance.new("ScrollingFrame", bpDetailView)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
    scroll.Position=UDim2.new(0,0,0,44); scroll.Size=UDim2.new(1,0,1,-48)
    scroll.ZIndex=8; scroll.ScrollBarThickness=3
    scroll.ScrollBarImageColor3=COR
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.CanvasSize=UDim2.new(0,0,0,0)
    scroll.Visible=false
    local scrollLayout = Instance.new("UIListLayout",scroll)
    scrollLayout.Padding=UDim.new(0,4); scrollLayout.SortOrder=Enum.SortOrder.LayoutOrder
    local scrollPad = Instance.new("UIPadding",scroll)
    scrollPad.PaddingTop=UDim.new(0,4); scrollPad.PaddingLeft=UDim.new(0,6)
    scrollPad.PaddingRight=UDim.new(0,6); scrollPad.PaddingBottom=UDim.new(0,8)
    grp.scroll = scroll

    -- ── Clique no botão ─────────────────────────────────────────
    local hitBtn = Instance.new("TextButton",btn); hitBtn.BackgroundTransparency=1
    hitBtn.Size=UDim2.new(1,0,1,0); hitBtn.Text=""; hitBtn.ZIndex=10
    hitBtn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(72,48,112)}):Play()
        TweenService:Create(btnS,TweenInfo.new(0.12),{Transparency=0}):Play()
        TweenService:Create(arrowLbl,TweenInfo.new(0.12),{TextColor3=Color3.fromRGB(255,255,255)}):Play()
    end)
    hitBtn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(56,36,92)}):Play()
        TweenService:Create(btnS,TweenInfo.new(0.12),{Transparency=0.2}):Play()
        TweenService:Create(arrowLbl,TweenInfo.new(0.12),{TextColor3=COR}):Play()
    end)
    hitBtn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=COR}):Play()
        task.delay(0.12, function()
            TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(64,42,100)}):Play()
            task.delay(0.12, function() bpShowDetail(grp) end)
        end)
    end)
    return grp
end

-- ── Cria/obtém header de tipo dentro do scroll do grupo ──────────
local function bpGetOrCreateTypeHeader(grp, structType)
    if grp.typeHeaders[structType.key] then return end
    grp.typeHeaders[structType.key] = true
    local COR = grp.cor
    local hdr = Instance.new("Frame", grp.scroll)
    hdr.BackgroundColor3 = Color3.fromRGB(32,20,52); hdr.BackgroundTransparency=0.3
    hdr.BorderSizePixel=0; hdr.Size=UDim2.new(1,0,0,28)
    hdr.LayoutOrder = structType.lo - 1; hdr.ZIndex=9
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,8)
    local hdrS = Instance.new("UIStroke",hdr); hdrS.Color=COR; hdrS.Thickness=1.2; hdrS.Transparency=0.6
    hdrS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    -- Pill colorida
    local pill = Instance.new("Frame",hdr); pill.BackgroundColor3=COR; pill.BorderSizePixel=0
    pill.Position=UDim2.new(0,6,0.5,-8); pill.Size=UDim2.new(0,4,0,16); pill.ZIndex=10
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local hdrLbl = Instance.new("TextLabel",hdr); hdrLbl.BackgroundTransparency=1
    hdrLbl.Position=UDim2.new(0,16,0,0); hdrLbl.Size=UDim2.new(1,-20,1,0)
    hdrLbl.Font=Enum.Font.GothamBlack
    hdrLbl.Text=structType.icon.."  "..structType.label:upper()
    hdrLbl.TextColor3=COR; hdrLbl.TextSize=9
    hdrLbl.TextXAlignment=Enum.TextXAlignment.Left; hdrLbl.ZIndex=10
end

-- ── Adiciona entrada ao grupo, agrupada por tipo ─────────────────
local function bpAddEntry(grp, name, pos, structIcon, isNew)
    local nk = bpNameKey(name, pos)
    local wasVisited = buildVisited[nk] == true
    local COR = grp.cor
    local sType = bpGetStructType(name:lower())
    bpGetOrCreateTypeHeader(grp, sType)
    grp.typeCounts[sType.key] = (grp.typeCounts[sType.key] or 0) + 1
    grp.totalCount = grp.totalCount + 1
    local typeIdx = grp.typeCounts[sType.key]
    local globalIdx = grp.totalCount
    local entry = { name=name, pos=pos, nk=nk, visited=wasVisited, row=nil }
    table.insert(grp.entries, entry)

    local row = Instance.new("Frame", grp.scroll)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,56); row.ZIndex=9
    row.LayoutOrder = sType.lo + typeIdx
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)
    local baseClr = wasVisited and Color3.fromRGB(60,18,12) or Color3.fromRGB(38,24,58)
    row.BackgroundColor3 = baseClr
    local rowS = Instance.new("UIStroke",row)
    rowS.Color = wasVisited and Color3.fromRGB(200,60,60) or COR
    rowS.Thickness=2; rowS.Transparency = wasVisited and 0.1 or 0.7
    local rowBg = Instance.new("Frame",row); rowBg.BackgroundColor3=COR; rowBg.BackgroundTransparency=0.93
    rowBg.BorderSizePixel=0; rowBg.Size=UDim2.new(1,0,1,0); rowBg.ZIndex=9
    Instance.new("UICorner",rowBg).CornerRadius=UDim.new(0,12)
    -- Barra lateral colorida
    local colorBar = Instance.new("Frame",row); colorBar.BackgroundColor3=COR; colorBar.BorderSizePixel=0
    colorBar.Position=UDim2.new(0,0,0.1,0); colorBar.Size=UDim2.new(0,4,0.8,0); colorBar.ZIndex=10
    Instance.new("UICorner",colorBar).CornerRadius=UDim.new(0,2)
    -- Badge número
    local numBadge = Instance.new("Frame",row); numBadge.BackgroundColor3=COR; numBadge.BackgroundTransparency=0.25
    numBadge.BorderSizePixel=0; numBadge.Position=UDim2.new(0,8,0.5,-12); numBadge.Size=UDim2.new(0,24,0,24); numBadge.ZIndex=10
    Instance.new("UICorner",numBadge).CornerRadius=UDim.new(0,6)
    local numS = Instance.new("UIStroke",numBadge); numS.Color=Color3.fromRGB(0,0,0); numS.Thickness=1.5; numS.Transparency=0.5
    local numLbl = Instance.new("TextLabel",numBadge); numLbl.BackgroundTransparency=1
    numLbl.Size=UDim2.new(1,0,1,0); numLbl.Font=Enum.Font.GothamBlack
    numLbl.Text=tostring(globalIdx); numLbl.TextColor3=Color3.fromRGB(16,8,30); numLbl.TextSize=9; numLbl.ZIndex=11
    -- Ícone da estrutura
    local ico = Instance.new("TextLabel",row); ico.BackgroundTransparency=1
    ico.Position=UDim2.new(0,36,0.5,-11); ico.Size=UDim2.new(0,22,0,22)
    ico.Font=Enum.Font.GothamBlack; ico.Text=structIcon or sType.icon; ico.TextSize=14; ico.ZIndex=10
    -- Nome
    local nameLbl = Instance.new("TextLabel",row); nameLbl.BackgroundTransparency=1
    nameLbl.Position=UDim2.new(0,60,0,8); nameLbl.Size=UDim2.new(1,-170,0,18)
    nameLbl.Font=Enum.Font.GothamBold; nameLbl.Text=name
    nameLbl.TextColor3 = wasVisited and Color3.fromRGB(200,130,130) or Color3.fromRGB(230,215,255)
    nameLbl.TextSize=11; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    nameLbl.TextTruncate=Enum.TextTruncate.AtEnd; nameLbl.ZIndex=10
    entry.nameLbl=nameLbl
    -- Info (bioma + distância)
    local distTxt=""
    pcall(function()
        local ch=Player.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then distTxt=" · "..math.floor((pos-hrp.Position).Magnitude).."m" end
    end)
    local infoLbl = Instance.new("TextLabel",row); infoLbl.BackgroundTransparency=1
    infoLbl.Position=UDim2.new(0,60,0,28); infoLbl.Size=UDim2.new(1,-170,0,16)
    infoLbl.Font=Enum.Font.Gotham; infoLbl.TextSize=9
    infoLbl.Text=grp.icon.." "..grp.label..distTxt
    infoLbl.TextColor3 = wasVisited and Color3.fromRGB(160,100,100) or Color3.fromRGB(155,135,195)
    infoLbl.TextXAlignment=Enum.TextXAlignment.Left; infoLbl.ZIndex=10
    -- Badge Tag (NOVO / Teleportou)
    local tagBadge = Instance.new("Frame",row); tagBadge.BorderSizePixel=0
    tagBadge.AnchorPoint=Vector2.new(1,0); tagBadge.Position=UDim2.new(1,-54,0,6)
    tagBadge.Size=UDim2.new(0,0,0,16); tagBadge.ZIndex=11
    Instance.new("UICorner",tagBadge).CornerRadius=UDim.new(0,5)
    local tagLbl = Instance.new("TextLabel",tagBadge); tagLbl.BackgroundTransparency=1
    tagLbl.Size=UDim2.new(1,0,1,0); tagLbl.Font=Enum.Font.GothamBlack; tagLbl.TextSize=7; tagLbl.ZIndex=12
    entry.tagBadge=tagBadge; entry.tagLbl=tagLbl
    if wasVisited then
        tagBadge.BackgroundColor3=Color3.fromRGB(240,200,40); tagBadge.Size=UDim2.new(0,72,0,16)
        tagLbl.Text="✓ Teleportou!"; tagLbl.TextColor3=Color3.fromRGB(50,30,5)
    elseif isNew then
        tagBadge.BackgroundColor3=Color3.fromRGB(60,220,110); tagBadge.Size=UDim2.new(0,0,0,16)
        tagLbl.Text="★ NOVO"; tagLbl.TextColor3=Color3.fromRGB(10,40,20)
        TweenService:Create(tagBadge,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,52,0,16)}):Play()
    end
    entry.row=row; entry.rowS=rowS; entry.rowBg=rowBg
    -- Botão TP
    local tpb = Instance.new("TextButton",row)
    tpb.BackgroundColor3=Color3.fromRGB(148,112,220); tpb.BackgroundTransparency=0; tpb.Text=""
    tpb.BorderSizePixel=0; tpb.AnchorPoint=Vector2.new(1,0.5)
    tpb.Position=UDim2.new(1,-8,0.5,0); tpb.Size=UDim2.new(0,42,0,34); tpb.ZIndex=11
    Instance.new("UICorner",tpb).CornerRadius=UDim.new(0,10)
    local tpbS = Instance.new("UIStroke",tpb); tpbS.Color=Color3.fromRGB(15,8,30); tpbS.Thickness=2.5
    local tpbG = Instance.new("UIGradient",tpb)
    tpbG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(195,170,250)),ColorSequenceKeypoint.new(1,Color3.fromRGB(110,76,175))}); tpbG.Rotation=90
    local tpbShine = Instance.new("Frame",tpb); tpbShine.BackgroundColor3=Color3.fromRGB(255,255,255)
    tpbShine.BackgroundTransparency=0.65; tpbShine.BorderSizePixel=0
    tpbShine.Position=UDim2.new(0,4,0,3); tpbShine.Size=UDim2.new(0.7,0,0,5); tpbShine.ZIndex=12
    Instance.new("UICorner",tpbShine).CornerRadius=UDim.new(1,0)
    local tpbL = Instance.new("TextLabel",tpb); tpbL.BackgroundTransparency=1
    tpbL.Size=UDim2.new(1,0,1,0); tpbL.Font=Enum.Font.GothamBlack
    tpbL.Text="TP"; tpbL.TextColor3=Color3.fromRGB(16,8,30); tpbL.TextSize=12; tpbL.ZIndex=13
    local function doTp()
        buildVisited[nk]=true; entry.visited=true
        TweenService:Create(tpb,TweenInfo.new(0.08),{BackgroundTransparency=0.5}):Play()
        task.delay(0.15,function() TweenService:Create(tpb,TweenInfo.new(0.15),{BackgroundTransparency=0}):Play() end)
        TweenService:Create(row,TweenInfo.new(0.25),{BackgroundColor3=Color3.fromRGB(60,18,12)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.25),{Color=Color3.fromRGB(200,60,60),Transparency=0.1}):Play()
        TweenService:Create(nameLbl,TweenInfo.new(0.2),{TextColor3=Color3.fromRGB(200,130,130)}):Play()
        tagBadge.BackgroundColor3=Color3.fromRGB(240,200,40)
        tagLbl.Text="✓ Teleportou!"; tagLbl.TextColor3=Color3.fromRGB(50,30,5)
        if tagBadge.Size.X.Offset < 70 then
            TweenService:Create(tagBadge,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,72,0,16)}):Play()
        end
        safeTp(pos, 5)
        Notify.send({type="custom",icon=structIcon or sType.icon,accent=COR,
            title=grp.label,msg="#"..globalIdx.." "..name,duration=2.5})
    end
    tpb.MouseButton1Click:Connect(doTp)
    local rowHit = Instance.new("TextButton",row); rowHit.BackgroundTransparency=1
    rowHit.Size=UDim2.new(1,-52,1,0); rowHit.Text=""; rowHit.ZIndex=10
    rowHit.MouseButton1Click:Connect(doTp)
    rowHit.MouseEnter:Connect(function() if not entry.visited then
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(72,48,110)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Transparency=0.35}):Play() end end)
    rowHit.MouseLeave:Connect(function() if not entry.visited then
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=baseClr}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Transparency=0.7}):Play() end end)
    return entry
end


-- ── Scan ─────────────────────────────────────────────────────
local function bpScanBuildings(isRefresh)
    if bpScanRunning then return end
    bpScanRunning = true
    bpBtnRefL.Text = "⏳"; task.delay(1, function() bpBtnRefL.Text = "🔄" end)
    -- Snapshot das posições já conhecidas (para detectar NOVO)
    local knownKeys = {}
    for k in pairs(buildSeenKeys) do knownKeys[k] = true end
    task.spawn(function()
        local ok, err = pcall(function()
        local found = 0
        local batch = 0
        local seenModels = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            batch = batch + 1
            if batch % 300 == 0 then task.wait() end

            -- Só processa Models (construções são sempre Models)
            if not obj:IsA("Model") then continue end
            -- Ignora personagens de jogadores/NPCs com Humanoid
            if obj:FindFirstChildWhichIsA("Humanoid") then continue end
            -- Evita duplicatas (Model já processado)
            if seenModels[obj] then continue end
            seenModels[obj] = true

            local nm = obj.Name:lower()

            -- WHITELIST: só aceita o que for reconhecido como construção
            -- (BUILD_KW ou SPECIAL_STRUCTS — qualquer um basta)
            local isBuilding = bpIsBuilding(nm)
            if not isBuilding then
                for _, s in ipairs(SPECIAL_STRUCTS) do
                    if nm:find(s.name,1,true) then isBuilding=true; break end
                end
            end
            -- Também aceita qualquer nome que bata com nameKeys dos biomas
            if not isBuilding then
                for _, b in ipairs(BUILD_BIOMES) do
                    for _, kw in ipairs(b.nameKeys) do
                        if nm:find(kw,1,true) then isBuilding=true; break end
                    end
                    if isBuilding then break end
                end
            end
            if not isBuilding then continue end

            -- Rejeita explicitamente itens, drops e npcs mesmo que tenham keyword
            if nm:find("chest",1,true) or nm:find("bau",1,true) or nm:find("baú",1,true)
            or nm:find("corpse",1,true) or nm:find("carcass",1,true)
            or nm:find("trap",1,true) or nm:find("spike",1,true)
            or nm:find("item",1,true) or nm:find("drop",1,true)
            or nm:find("weapon",1,true) or nm:find("ammo",1,true) then continue end

            -- Pega parte representativa (preferência para partes grandes)
            local part = nil
            pcall(function()
                for _, bp in ipairs(obj:GetDescendants()) do
                    if bp:IsA("BasePart") then
                        if not part then part = bp end
                        if bp.Size.X > 3 or bp.Size.Y > 3 or bp.Size.Z > 3 then
                            part = bp; break
                        end
                    end
                end
                -- fallback: tenta PrimaryPart
                if not part then part = obj.PrimaryPart end
            end)
            if not part then continue end -- sem BasePart alguma, pula

            pcall(function()
                local pk = bpPosKey(part.Position)
                if buildSeenKeys[pk] then return end -- posição já registrada
                buildSeenKeys[pk] = true

                local biomeLabel, biomeIcon, biomeCor = bpGetBiomeFromObj(obj)
                local structIcon = bpGetStructIcon(nm)
                local grp = bpGetOrCreateGroup(biomeLabel, biomeIcon, biomeCor)
                local isNew = isRefresh and not knownKeys[pk]
                bpAddEntry(grp, obj.Name, part.Position, structIcon, isNew)
                grp.countLbl.Text = tostring(grp.totalCount).." construção(ões)"
                found = found + 1
                bpEmptyLbl.Visible = false
                if bpCurrentGroup == grp then
                    bpDetailCount.Text = tostring(grp.totalCount).." local(is)"
                end
            end)
            if found % 20 == 0 then task.wait() end
        end
        -- Atualiza subtítulo
        local totalB, totalE = 0, 0
        for _, g in pairs(buildGroupMap) do totalB = totalB + 1; totalE = totalE + #g.entries end
        bpHdrSub.Text = tostring(totalB).." biomas · "..tostring(totalE).." construções"
        if found == 0 and isRefresh then
            Notify.info("Construções","Nenhuma construção nova encontrada.")
        elseif found > 0 then
            Notify.send({type="custom",icon="🏗️",accent=TP_COR_BUILD,
                title="Construções",
                msg=(isRefresh and tostring(found).." nova(s)!" or tostring(found).." em "..totalB.." biomas!"),
                duration=3})
        end
        end) -- fim pcall
        if not ok then
            warn("[PudimHub] bpScanBuildings error: "..tostring(err))
        end
        bpScanRunning = false -- sempre reseta, mesmo em erro
    end)
end

bpBtnRef.MouseButton1Click:Connect(function() bpScanBuildings(true) end)
bpBtnClr.MouseButton1Click:Connect(function()
    for _, grp in pairs(buildGroupMap) do
        pcall(function() if grp.groupBtn then grp.groupBtn:Destroy() end end)
        pcall(function() if grp.scroll then grp.scroll:Destroy() end end)
    end
    buildGroups={}; buildGroupMap={}; buildSeenKeys={}; buildVisited={}; bpBiomeOrder=0
    bpGroupView.Visible=true; bpGroupView.Position=UDim2.new(0,0,0,52)
    bpDetailView.Visible=false; bpDetailView.Position=UDim2.new(1,0,0,52)
    bpCurrentGroup=nil; bpEmptyLbl.Visible=true
    bpHdrSub.Text="0 biomas · 0 construções"
    Notify.info("Construções","Lista limpa!")
end)

local bpFirstOpen = true
task.spawn(function()
    while true do task.wait(1)
        if Pages["Teleportar"] and Pages["Teleportar"].Visible and bpFirstOpen then
            bpFirstOpen=false; task.wait(0.5); bpScanBuildings(false)
        end
    end
end)



-- ══════════════════════════════════════════════════════════════
-- PAINEL DE BAÚS v3 — Grupos por BIOMA → (Floresta: Raridade) → Baús
-- Outros biomas: Bioma → Lista de baús direto
-- Floresta: Floresta → Sub-grupo de Raridade → Lista de baús
-- ══════════════════════════════════════════════════════════════
local TP_COR_CHEST = Color3.fromRGB(255, 200, 60)

makeTpSec("🎁  PAINEL DE BAÚS", TP_COR_CHEST)

-- IMPORTANTE: ordem alta→baixa; keywords mais específicas primeiro para evitar match errado
-- "stronghold" NÃO é raridade Ruby — é bioma Fortaleza (detectado pelo getBiome)
local CHEST_RARITY = {
    { keywords={"diamond","diamante","gem chest","crystal chest","legendary chest","prismatic"},
      tier=5, label="Diamante", tag="DIAMOND", cor=Color3.fromRGB(100,220,255), icon="💎" },
    { keywords={"obsidiron chest","ruby chest","rubi","red chest","scarlet chest","crimson chest","fire chest"},
      tier=4, label="Rubi", tag="RUBY", cor=Color3.fromRGB(255,60,80), icon="🔴" },
    { keywords={"golden chest","gold chest","dourado","gilded chest","royal chest","amber chest"},
      tier=3, label="Dourado", tag="GOLD", cor=Color3.fromRGB(255,200,20), icon="👑" },
    { keywords={"epic chest","purple chest","legendary chest","great chest","mythic","rare chest","enchanted chest","magic chest","arcane","obsidiron","epic","purple","great"},
      tier=2, label="Épico", tag="EPIC", cor=Color3.fromRGB(180,80,255), icon="🟣" },
    { keywords={"item chest","iron chest","common chest","wood chest","wooden chest","basic chest","simple chest","small chest","loot crate","chest","baú","bau","crate","box"},
      tier=1, label="Comum", tag="COMMON", cor=Color3.fromRGB(160,140,110), icon="📦" },
}
local function getRarity(chestModel)
    local nm = chestModel.Name:lower()
    for _, r in ipairs(CHEST_RARITY) do
        for _, kw in ipairs(r.keywords) do
            if nm:find(kw,1,true) then return r end
        end
    end
    return CHEST_RARITY[#CHEST_RARITY]
end

-- Tabela de biomas (ordem de exibição)
-- "Floresta" é o bioma padrão e recebe sub-grupos de raridade
-- "Floresta" é o bioma padrão e recebe sub-grupos de raridade
local BIOME_DEFS = {
    -- Keywords mais específicas (com "chest") primeiro para evitar match genérico errado
    { nameKeys={"volcano chest","lava chest","volcanic chest","infernal chest","molten chest","scorpion chest","hellephant chest","magma chest","ember chest"},
      hierKeys={"volcano","volcanic","lava","vulcao","vulão","volcano_biome","lava_biome","infernal","molten","magma","scorpion pit","hellephant"},
      label="Vulcão", icon="🌋", cor=Color3.fromRGB(255,100,30) },
    { nameKeys={"jungle chest","selva chest","temple chest","tarpit chest"},
      hierKeys={"jungle","selva","jungle_biome","selva_biome","tropics","rainforest","tarpit","tar pit"},
      label="Selva", icon="🌿", cor=Color3.fromRGB(60,200,80) },
    { nameKeys={"ice chest","snow chest","frozen chest","winter chest","arctic chest","glacier chest","blizzard chest","tundra chest"},
      hierKeys={"ice","snow","frozen","winter","gelo","neve","iceberg","blizzard","tundra","glacier","arctic","ice_biome","snow_biome","frozen_biome"},
      label="Neve/Gelo", icon="❄️", cor=Color3.fromRGB(160,230,255) },
    { nameKeys={"frog chest","swamp chest","pantano chest","marsh chest","bog chest"},
      hierKeys={"frog","swamp","pantano","pântano","marsh","swampland","bog","swamp_biome","frog_biome"},
      label="Pântano", icon="🐸", cor=Color3.fromRGB(100,220,80) },
    { nameKeys={"alien chest","ufo chest","mothership chest","nave chest"},
      hierKeys={"ufo","alien","mothership","nave","ovni","alien_biome","ufo_biome"},
      label="UFO/Alien", icon="🛸", cor=Color3.fromRGB(80,255,180) },
    { nameKeys={"fairy chest","fada chest","brightwood chest","mother tree chest","giant tree chest","faerie chest","enchanted chest"},
      hierKeys={"fairy","fada","brightwood","enchanted forest","fairy_biome","fada_biome","fairytale","giant tree","mother tree"},
      label="Fada", icon="🧚", cor=Color3.fromRGB(255,180,255) },
    { nameKeys={"stronghold chest","cultist chest","fortress chest","fortaleza chest","dark chest","cultist king chest"},
      hierKeys={"stronghold","cultist","fortress","fortaleza","cultist_biome","dark_biome"},
      label="Fortaleza", icon="⚔️", cor=Color3.fromRGB(200,160,80) },
    { nameKeys={"cave chest","mine chest","cavern chest","underground chest","crystal cave chest","deep chest"},
      hierKeys={"cave","cavern","mine","caverna","mina","underground","subterranean","cave_biome","mine_biome"},
      label="Caverna", icon="🕳️", cor=Color3.fromRGB(140,100,60) },
    { nameKeys={"meteor chest","crater chest"},
      hierKeys={"meteor","crater","meteor_biome"},
      label="Meteoro", icon="☄️", cor=Color3.fromRGB(255,140,40) },
    { nameKeys={"ruin chest","ancient chest","abandoned chest"},
      hierKeys={"ruin","ancient","abandon","ruinas","ruin_biome"},
      label="Ruínas", icon="🏚️", cor=Color3.fromRGB(160,140,100) },
    { nameKeys={"halloween chest","thanksgiving chest","event chest","seasonal chest","holiday chest"},
      hierKeys={"halloween","thanksgiving","event","seasonal","holiday"},
      label="Evento", icon="🎃", cor=Color3.fromRGB(255,150,50) },
}
-- Detecção em 3 passes:
-- 1) nameKeys no nome do próprio baú
-- 2) Ancestrais com hierKeys (até 12 níveis)
-- 3) Floresta (padrão)
local function getBiome(chestModel)
    local ownName = chestModel.Name:lower()
    -- Passe 1: nome do próprio baú
    for _, b in ipairs(BIOME_DEFS) do
        for _, kw in ipairs(b.nameKeys) do
            if ownName:find(kw,1,true) then return b.label, b.icon, b.cor end
        end
    end
    -- Passe 2: ancestrais
    local cur = chestModel.Parent
    for _ = 1, 12 do
        if not cur or cur == workspace or cur == game then break end
        local nm = cur.Name:lower()
        for _, b in ipairs(BIOME_DEFS) do
            for _, kw in ipairs(b.hierKeys) do
                if nm:find(kw,1,true) then return b.label, b.icon, b.cor end
            end
        end
        for _, b in ipairs(BIOME_DEFS) do
            for _, kw in ipairs(b.nameKeys) do
                if nm:find(kw,1,true) then return b.label, b.icon, b.cor end
            end
        end
        cur = cur.Parent
    end
    return "Floresta", "🌲", Color3.fromRGB(80,200,80)
end

-- ── Estado ────────────────────────────────────────────────
-- biomeData[biomeLabel] = { icon, cor, entries={}, btn, countLbl,
--   rarSubs={ [rarTag]={ rarity, entries={}, btn, countLbl } } }
local biomeData      = {}
local chestSeenKeys2 = {}
local chestVisited   = {}
local chestScanRun2  = false
local curRarTag      = nil

local function cpNameKey(name,pos) return name:lower()..":"..math.floor(pos.X/6)..","..math.floor(pos.Z/6) end
local function cpPosKey(pos) return math.floor(pos.X/6)..","..math.floor(pos.Y/6)..","..math.floor(pos.Z/6) end

-- ── Estado ────────────────────────────────────────────────────────
local biomeOrder     = 0
local biomeData      = {}   -- [label] = { icon, cor, entries, btn, countLbl, scroll }
local chestSeenKeys2 = {}
local chestVisited   = {}
local chestScanRun2  = false
local cpCurrentBiome = nil

-- ── Container principal ──────────────────────────────────────────
local cpCard = Instance.new("Frame", Pages["Teleportar"])
cpCard.BackgroundColor3 = Color3.fromRGB(26,14,44)
cpCard.BorderSizePixel = 0; cpCard.Size = UDim2.new(1,0,0,310)
cpCard.LayoutOrder = tpNextLO(); cpCard.ZIndex = 5
Instance.new("UICorner",cpCard).CornerRadius = UDim.new(0,14)
local cpStroke = Instance.new("UIStroke",cpCard)
cpStroke.Color = Color3.fromRGB(255,200,60); cpStroke.Thickness = 3.5; cpStroke.Transparency = 0.3
local cpCardGrad = Instance.new("UIGradient",cpCard)
cpCardGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(40,22,8)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,4)),
}); cpCardGrad.Rotation = 140

-- ── Header ──────────────────────────────────────────────────────
local cpHdr = Instance.new("Frame",cpCard)
cpHdr.BackgroundColor3 = Color3.fromRGB(200,155,40)
cpHdr.BorderSizePixel = 0; cpHdr.Size = UDim2.new(1,0,0,52); cpHdr.ZIndex = 6
Instance.new("UICorner",cpHdr).CornerRadius = UDim.new(0,12)
local cpHdrFix = Instance.new("Frame",cpHdr)
cpHdrFix.BackgroundColor3 = Color3.fromRGB(200,155,40); cpHdrFix.BorderSizePixel = 0
cpHdrFix.Position = UDim2.new(0,0,0.5,0); cpHdrFix.Size = UDim2.new(1,0,0.5,0); cpHdrFix.ZIndex = 6
local cpHdrGrad = Instance.new("UIGradient",cpHdr)
cpHdrGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,220,80)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(220,168,40)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(160,110,20)),
}); cpHdrGrad.Rotation = 0
local cpHdrStroke = Instance.new("UIStroke",cpHdr)
cpHdrStroke.Color = Color3.fromRGB(80,50,0); cpHdrStroke.Thickness = 3
local cpHdrShine = Instance.new("Frame",cpHdr)
cpHdrShine.Size = UDim2.new(0,70,0,10); cpHdrShine.Position = UDim2.new(0,8,0,5)
cpHdrShine.BackgroundColor3 = Color3.fromRGB(255,255,255); cpHdrShine.BackgroundTransparency = 0.62
cpHdrShine.BorderSizePixel = 0; cpHdrShine.Rotation = -3; cpHdrShine.ZIndex = 8
Instance.new("UICorner",cpHdrShine).CornerRadius = UDim.new(1,0)

local cpHdrIco = Instance.new("TextLabel",cpHdr); cpHdrIco.BackgroundTransparency = 1
cpHdrIco.Position = UDim2.new(0,10,0.5,-15); cpHdrIco.Size = UDim2.new(0,30,0,30)
cpHdrIco.Font = Enum.Font.GothamBlack; cpHdrIco.Text = "🎁"; cpHdrIco.TextSize = 22; cpHdrIco.ZIndex = 7

local cpHdrTitle = Instance.new("TextLabel",cpHdr); cpHdrTitle.BackgroundTransparency = 1
cpHdrTitle.Position = UDim2.new(0,46,0,6); cpHdrTitle.Size = UDim2.new(0,150,0,20)
cpHdrTitle.Font = Enum.Font.GothamBlack; cpHdrTitle.Text = "Painel de Baús"
cpHdrTitle.TextColor3 = Color3.fromRGB(16,8,0); cpHdrTitle.TextSize = 13
cpHdrTitle.TextXAlignment = Enum.TextXAlignment.Left; cpHdrTitle.ZIndex = 7
local cpHdrTS = Instance.new("UIStroke",cpHdrTitle); cpHdrTS.Color=Color3.fromRGB(200,140,0); cpHdrTS.Thickness=1.2

local cpHdrSub = Instance.new("TextLabel",cpHdr); cpHdrSub.BackgroundTransparency = 1
cpHdrSub.Position = UDim2.new(0,46,0,28); cpHdrSub.Size = UDim2.new(0,180,0,14)
cpHdrSub.Font = Enum.Font.Gotham; cpHdrSub.Text = "0 biomas · 0 baús"
cpHdrSub.TextColor3 = Color3.fromRGB(80,50,0); cpHdrSub.TextSize = 9
cpHdrSub.TextXAlignment = Enum.TextXAlignment.Left; cpHdrSub.ZIndex = 7

-- Botão atualizar
local cpBtnRef = Instance.new("TextButton",cpHdr)
cpBtnRef.BackgroundColor3 = Color3.fromRGB(16,8,0); cpBtnRef.BackgroundTransparency = 0.1; cpBtnRef.Text = ""
cpBtnRef.BorderSizePixel = 0; cpBtnRef.Position = UDim2.new(1,-88,0.5,-15)
cpBtnRef.Size = UDim2.new(0,38,0,30); cpBtnRef.ZIndex = 8
Instance.new("UICorner",cpBtnRef).CornerRadius = UDim.new(0,9)
local cpBtnRefStroke = Instance.new("UIStroke",cpBtnRef)
cpBtnRefStroke.Color=Color3.fromRGB(80,50,0); cpBtnRefStroke.Thickness=2.5
local cpBtnRefL = Instance.new("TextLabel",cpBtnRef); cpBtnRefL.BackgroundTransparency = 1
cpBtnRefL.Size = UDim2.new(1,0,1,0); cpBtnRefL.Font = Enum.Font.GothamBlack
cpBtnRefL.Text = "🔄"; cpBtnRefL.TextColor3 = Color3.fromRGB(255,220,80); cpBtnRefL.TextSize = 14; cpBtnRefL.ZIndex = 9

-- Botão limpar
local cpBtnClr = Instance.new("TextButton",cpHdr)
cpBtnClr.BackgroundColor3 = Color3.fromRGB(200,50,50); cpBtnClr.BackgroundTransparency = 0.1; cpBtnClr.Text = ""
cpBtnClr.BorderSizePixel = 0; cpBtnClr.Position = UDim2.new(1,-44,0.5,-15)
cpBtnClr.Size = UDim2.new(0,38,0,30); cpBtnClr.ZIndex = 8
Instance.new("UICorner",cpBtnClr).CornerRadius = UDim.new(0,9)
local cpBtnClrStroke = Instance.new("UIStroke",cpBtnClr)
cpBtnClrStroke.Color=Color3.fromRGB(80,0,0); cpBtnClrStroke.Thickness=2.5
local cpBtnClrL = Instance.new("TextLabel",cpBtnClr); cpBtnClrL.BackgroundTransparency = 1
cpBtnClrL.Size = UDim2.new(1,0,1,0); cpBtnClrL.Font = Enum.Font.GothamBlack
cpBtnClrL.Text = "🗑️"; cpBtnClrL.TextColor3 = Color3.fromRGB(255,180,180); cpBtnClrL.TextSize = 14; cpBtnClrL.ZIndex = 9

-- ── NÍVEL 1: Lista de Biomas ─────────────────────────────────────
local OFFSET_CP = UDim2.new(0,0,0,56)
local LEFT_CP   = UDim2.new(-1,0,0,56)
local RIGHT_CP  = UDim2.new(1,0,0,56)

local cpGroupView = Instance.new("ScrollingFrame",cpCard)
cpGroupView.BackgroundTransparency = 1; cpGroupView.BorderSizePixel = 0
cpGroupView.Position = OFFSET_CP; cpGroupView.Size = UDim2.new(1,0,1,-60)
cpGroupView.ZIndex = 6; cpGroupView.ScrollBarThickness = 3
cpGroupView.ScrollBarImageColor3 = TP_COR_CHEST
cpGroupView.AutomaticCanvasSize = Enum.AutomaticSize.Y; cpGroupView.CanvasSize = UDim2.new(0,0,0,0)
local cpGroupLayout = Instance.new("UIListLayout",cpGroupView)
cpGroupLayout.Padding = UDim.new(0,6); cpGroupLayout.SortOrder = Enum.SortOrder.LayoutOrder
local cpGroupPad = Instance.new("UIPadding",cpGroupView)
cpGroupPad.PaddingTop = UDim.new(0,6); cpGroupPad.PaddingLeft = UDim.new(0,8)
cpGroupPad.PaddingRight = UDim.new(0,8); cpGroupPad.PaddingBottom = UDim.new(0,8)

local cpEmptyLbl = Instance.new("TextLabel",cpGroupView)
cpEmptyLbl.BackgroundTransparency = 1; cpEmptyLbl.Size = UDim2.new(1,0,0,60)
cpEmptyLbl.Font = Enum.Font.GothamBold; cpEmptyLbl.Text = "🔍  Clique em 🔄 para escanear baús"
cpEmptyLbl.TextColor3 = Color3.fromRGB(120,90,20); cpEmptyLbl.TextSize = 11
cpEmptyLbl.TextWrapped = true; cpEmptyLbl.TextXAlignment = Enum.TextXAlignment.Center
cpEmptyLbl.ZIndex = 7; cpEmptyLbl.LayoutOrder = 999

-- ── NÍVEL 2: Lista de Baús do Bioma ─────────────────────────────
local cpDetailView = Instance.new("Frame",cpCard)
cpDetailView.BackgroundTransparency = 1; cpDetailView.BorderSizePixel = 0
cpDetailView.Position = RIGHT_CP; cpDetailView.Size = UDim2.new(1,0,1,-60)
cpDetailView.ZIndex = 7; cpDetailView.Visible = false

local cpDetailHdr = Instance.new("Frame",cpDetailView)
cpDetailHdr.BackgroundColor3 = Color3.fromRGB(40,26,70); cpDetailHdr.BorderSizePixel = 0
cpDetailHdr.Size = UDim2.new(1,0,0,40); cpDetailHdr.ZIndex = 8
Instance.new("UICorner",cpDetailHdr).CornerRadius = UDim.new(0,10)
local cpDetailHdrS = Instance.new("UIStroke",cpDetailHdr)
cpDetailHdrS.Color = Color3.fromRGB(255,200,60); cpDetailHdrS.Thickness = 2; cpDetailHdrS.Transparency = 0.4

local cpBackBtn = Instance.new("TextButton",cpDetailHdr)
cpBackBtn.BackgroundColor3 = Color3.fromRGB(255,200,60); cpBackBtn.BackgroundTransparency = 0.1; cpBackBtn.Text = ""
cpBackBtn.BorderSizePixel = 0; cpBackBtn.Position = UDim2.new(0,8,0.5,-14); cpBackBtn.Size = UDim2.new(0,64,0,28); cpBackBtn.ZIndex = 9
Instance.new("UICorner",cpBackBtn).CornerRadius = UDim.new(0,9)
local cpBackBtnS = Instance.new("UIStroke",cpBackBtn); cpBackBtnS.Color=Color3.fromRGB(80,50,0); cpBackBtnS.Thickness=2.5
local cpBackBtnL = Instance.new("TextLabel",cpBackBtn); cpBackBtnL.BackgroundTransparency = 1
cpBackBtnL.Size = UDim2.new(1,0,1,0); cpBackBtnL.Font = Enum.Font.GothamBlack
cpBackBtnL.Text = "◀ Voltar"; cpBackBtnL.TextColor3 = Color3.fromRGB(16,8,0); cpBackBtnL.TextSize = 9; cpBackBtnL.ZIndex = 10

local cpDetailTitle = Instance.new("TextLabel",cpDetailHdr); cpDetailTitle.BackgroundTransparency = 1
cpDetailTitle.Position = UDim2.new(0,80,0.5,-10); cpDetailTitle.Size = UDim2.new(1,-170,0,20)
cpDetailTitle.Font = Enum.Font.GothamBlack; cpDetailTitle.Text = ""
cpDetailTitle.TextColor3 = Color3.fromRGB(255,210,60); cpDetailTitle.TextSize = 12
cpDetailTitle.TextXAlignment = Enum.TextXAlignment.Left; cpDetailTitle.ZIndex = 9

local cpDetailCount = Instance.new("TextLabel",cpDetailHdr); cpDetailCount.BackgroundTransparency = 1
cpDetailCount.Position = UDim2.new(1,-80,0.5,-8); cpDetailCount.Size = UDim2.new(0,72,0,16)
cpDetailCount.Font = Enum.Font.GothamBold; cpDetailCount.Text = "0 baús"
cpDetailCount.TextColor3 = Color3.fromRGB(200,155,40); cpDetailCount.TextSize = 9
cpDetailCount.TextXAlignment = Enum.TextXAlignment.Right; cpDetailCount.ZIndex = 9

-- ── Navegação ────────────────────────────────────────────────────
local function cpSlideIn(frame)
    frame.Position = RIGHT_CP; frame.Visible = true
    TweenService:Create(frame,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=OFFSET_CP}):Play()
end
local function cpSlideOut(frame)
    TweenService:Create(frame,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{Position=LEFT_CP}):Play()
    task.delay(0.2,function() frame.Visible=false; frame.Position=OFFSET_CP end)
end
local function cpShowBiomes()
    if cpDetailView.Visible then cpSlideOut(cpDetailView) end
    cpGroupView.Position = LEFT_CP; cpGroupView.Visible = true
    TweenService:Create(cpGroupView,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=OFFSET_CP}):Play()
    cpCurrentBiome = nil
end
local function cpShowDetail(bd)
    cpCurrentBiome = bd
    cpDetailTitle.Text = bd.icon.."  "..bd.label
    cpDetailTitle.TextColor3 = bd.cor
    cpDetailCount.Text = tostring(#bd.entries).." baú(s)"
    for _, b in pairs(biomeData) do if b.scroll then b.scroll.Visible = (b == bd) end end
    cpSlideOut(cpGroupView)
    task.delay(0.15, function() cpSlideIn(cpDetailView) end)
end
cpBackBtn.MouseButton1Click:Connect(cpShowBiomes)

-- ── Cria botão de bioma ──────────────────────────────────────────
local function cpGetOrCreateBiome(biomeLabel, biomeIcon, biomeCor)
    if biomeData[biomeLabel] then return biomeData[biomeLabel] end
    biomeOrder = biomeOrder + 1
    local COR = biomeCor or Color3.fromRGB(180,180,100)
    local isForest = (biomeLabel == "Floresta")
    local bd = { label=biomeLabel, icon=biomeIcon, cor=COR, entries={}, btn=nil, countLbl=nil, scroll=nil }
    biomeData[biomeLabel] = bd

    local btn = Instance.new("Frame",cpGroupView)
    btn.BackgroundColor3 = Color3.fromRGB(40,26,62); btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1,0,0,72); btn.ZIndex = 7
    btn.LayoutOrder = isForest and 0 or biomeOrder
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,14)
    local btnS = Instance.new("UIStroke",btn); btnS.Color=COR; btnS.Thickness=4; btnS.Transparency=0.2
    local btnBg = Instance.new("Frame",btn); btnBg.BackgroundColor3=COR; btnBg.BackgroundTransparency=0.88
    btnBg.BorderSizePixel=0; btnBg.Size=UDim2.new(1,0,1,0); btnBg.ZIndex=7
    Instance.new("UICorner",btnBg).CornerRadius=UDim.new(0,14)
    local btnBar = Instance.new("Frame",btn); btnBar.BackgroundColor3=COR; btnBar.BorderSizePixel=0
    btnBar.Position=UDim2.new(0,0,0.18,0); btnBar.Size=UDim2.new(0,5,0.64,0); btnBar.ZIndex=9
    Instance.new("UICorner",btnBar).CornerRadius=UDim.new(0,3)
    local icoBox = Instance.new("Frame",btn); icoBox.BackgroundColor3=COR; icoBox.BackgroundTransparency=0.52
    icoBox.BorderSizePixel=0; icoBox.Position=UDim2.new(0,12,0.5,-26); icoBox.Size=UDim2.new(0,52,0,52); icoBox.ZIndex=8
    Instance.new("UICorner",icoBox).CornerRadius=UDim.new(0,13)
    local icoBoxS = Instance.new("UIStroke",icoBox); icoBoxS.Color=Color3.fromRGB(15,8,30); icoBoxS.Thickness=2.5; icoBoxS.Transparency=0.25
    local icoLbl = Instance.new("TextLabel",icoBox); icoLbl.BackgroundTransparency=1
    icoLbl.Size=UDim2.new(1,0,1,0); icoLbl.Font=Enum.Font.GothamBlack
    icoLbl.Text=biomeIcon; icoLbl.TextSize=28; icoLbl.ZIndex=9
    local nameLbl = Instance.new("TextLabel",btn); nameLbl.BackgroundTransparency=1
    nameLbl.Position=UDim2.new(0,74,0,12); nameLbl.Size=UDim2.new(1,-130,0,22)
    nameLbl.Font=Enum.Font.GothamBlack; nameLbl.Text=biomeLabel
    nameLbl.TextColor3=Color3.fromRGB(230,215,255); nameLbl.TextSize=13
    nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=8
    local nameS = Instance.new("UIStroke",nameLbl); nameS.Color=Color3.fromRGB(0,0,0); nameS.Thickness=0.8; nameS.Transparency=0.5
    local cntBadge = Instance.new("Frame",btn); cntBadge.BackgroundColor3=COR; cntBadge.BackgroundTransparency=0.12
    cntBadge.BorderSizePixel=0; cntBadge.Position=UDim2.new(0,74,0,38); cntBadge.Size=UDim2.new(0,80,0,20); cntBadge.ZIndex=8
    Instance.new("UICorner",cntBadge).CornerRadius=UDim.new(0,7)
    local cntBadgeS = Instance.new("UIStroke",cntBadge); cntBadgeS.Color=Color3.fromRGB(15,8,30); cntBadgeS.Thickness=1.8
    local cntLbl = Instance.new("TextLabel",cntBadge); cntLbl.BackgroundTransparency=1
    cntLbl.Size=UDim2.new(1,0,1,0); cntLbl.Font=Enum.Font.GothamBold
    cntLbl.Text="0 baús"; cntLbl.TextColor3=Color3.fromRGB(255,255,255); cntLbl.TextSize=9; cntLbl.ZIndex=9
    bd.countLbl = cntLbl
    local arrowLbl = Instance.new("TextLabel",btn); arrowLbl.BackgroundTransparency=1
    arrowLbl.AnchorPoint=Vector2.new(1,0.5); arrowLbl.Position=UDim2.new(1,-14,0.5,0)
    arrowLbl.Size=UDim2.new(0,22,0,22); arrowLbl.Font=Enum.Font.GothamBlack
    arrowLbl.Text="▶"; arrowLbl.TextColor3=COR; arrowLbl.TextSize=16; arrowLbl.ZIndex=8
    bd.btn = btn

    -- Scroll exclusivo deste bioma
    local scroll = Instance.new("ScrollingFrame",cpDetailView)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
    scroll.Position=UDim2.new(0,0,0,44); scroll.Size=UDim2.new(1,0,1,-48)
    scroll.ZIndex=8; scroll.ScrollBarThickness=3; scroll.ScrollBarImageColor3=COR
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.CanvasSize=UDim2.new(0,0,0,0)
    scroll.Visible=false
    local sl = Instance.new("UIListLayout",scroll); sl.Padding=UDim.new(0,5); sl.SortOrder=Enum.SortOrder.LayoutOrder
    local sp = Instance.new("UIPadding",scroll)
    sp.PaddingTop=UDim.new(0,4); sp.PaddingLeft=UDim.new(0,6); sp.PaddingRight=UDim.new(0,6); sp.PaddingBottom=UDim.new(0,8)
    bd.scroll = scroll

    local hitBtn = Instance.new("TextButton",btn); hitBtn.BackgroundTransparency=1
    hitBtn.Size=UDim2.new(1,0,1,0); hitBtn.Text=""; hitBtn.ZIndex=10
    hitBtn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(62,42,98)}):Play()
        TweenService:Create(btnS,TweenInfo.new(0.12),{Transparency=0}):Play()
        TweenService:Create(arrowLbl,TweenInfo.new(0.12),{TextColor3=Color3.fromRGB(255,255,255)}):Play()
    end)
    hitBtn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(40,26,62)}):Play()
        TweenService:Create(btnS,TweenInfo.new(0.12),{Transparency=0.2}):Play()
        TweenService:Create(arrowLbl,TweenInfo.new(0.12),{TextColor3=COR}):Play()
    end)
    hitBtn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=COR}):Play()
        task.delay(0.12,function()
            TweenService:Create(btn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(36,22,58)}):Play()
            task.delay(0.08, function() cpShowDetail(bd) end)
        end)
    end)
    return bd
end

-- ── Adiciona baú ao scroll do bioma ──────────────────────────────
local function cpAddEntry(bd, rarity, name, pos, isNew)
    local nk = cpNameKey(name, pos)
    local wasVisited = chestVisited[nk] == true
    local COR = rarity and rarity.cor or Color3.fromRGB(160,140,110)
    local BIOME_COR = bd.cor
    local idx = #bd.entries + 1
    -- LayoutOrder: raridade alta → cima (5=diamante vira 0, 1=comum vira 4)
    local lo = (6 - (rarity and rarity.tier or 1)) * 1000 + idx
    local entry = { name=name, pos=pos, nk=nk, visited=wasVisited, row=nil }
    table.insert(bd.entries, entry)

    local row = Instance.new("Frame", bd.scroll)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,60); row.ZIndex=9; row.LayoutOrder=lo
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)
    local baseClr = wasVisited and Color3.fromRGB(55,18,10) or Color3.fromRGB(32,20,50)
    row.BackgroundColor3 = baseClr
    local rowS = Instance.new("UIStroke",row)
    rowS.Color = wasVisited and Color3.fromRGB(200,60,60) or BIOME_COR
    rowS.Thickness=2; rowS.Transparency = wasVisited and 0.1 or 0.68
    local rowBg = Instance.new("Frame",row); rowBg.BackgroundColor3=BIOME_COR; rowBg.BackgroundTransparency=0.93
    rowBg.BorderSizePixel=0; rowBg.Size=UDim2.new(1,0,1,0); rowBg.ZIndex=9
    Instance.new("UICorner",rowBg).CornerRadius=UDim.new(0,12)
    -- Barra lateral raridade
    local colorBar = Instance.new("Frame",row); colorBar.BackgroundColor3=COR; colorBar.BorderSizePixel=0
    colorBar.Position=UDim2.new(0,0,0.1,0); colorBar.Size=UDim2.new(0,5,0.8,0); colorBar.ZIndex=10
    Instance.new("UICorner",colorBar).CornerRadius=UDim.new(0,2)
    -- Badge número
    local numBadge = Instance.new("Frame",row); numBadge.BackgroundColor3=BIOME_COR; numBadge.BackgroundTransparency=0.22
    numBadge.BorderSizePixel=0; numBadge.Position=UDim2.new(0,8,0.5,-13); numBadge.Size=UDim2.new(0,26,0,26); numBadge.ZIndex=10
    Instance.new("UICorner",numBadge).CornerRadius=UDim.new(0,7)
    local numS = Instance.new("UIStroke",numBadge); numS.Color=Color3.fromRGB(0,0,0); numS.Thickness=1.5; numS.Transparency=0.4
    local numLbl = Instance.new("TextLabel",numBadge); numLbl.BackgroundTransparency=1
    numLbl.Size=UDim2.new(1,0,1,0); numLbl.Font=Enum.Font.GothamBlack
    numLbl.Text=tostring(idx); numLbl.TextColor3=Color3.fromRGB(255,255,255); numLbl.TextSize=9; numLbl.ZIndex=11
    -- Ícone baú (raridade)
    local ico = Instance.new("TextLabel",row); ico.BackgroundTransparency=1
    ico.Position=UDim2.new(0,38,0.5,-12); ico.Size=UDim2.new(0,24,0,24)
    ico.Font=Enum.Font.GothamBlack; ico.Text=rarity and rarity.icon or "📦"; ico.TextSize=16; ico.ZIndex=10
    -- Nome
    local nameLbl = Instance.new("TextLabel",row); nameLbl.BackgroundTransparency=1
    nameLbl.Position=UDim2.new(0,64,0,8); nameLbl.Size=UDim2.new(1,-175,0,18)
    nameLbl.Font=Enum.Font.GothamBold; nameLbl.Text=name
    nameLbl.TextColor3 = wasVisited and Color3.fromRGB(200,130,130) or Color3.fromRGB(230,215,255)
    nameLbl.TextSize=11; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    nameLbl.TextTruncate=Enum.TextTruncate.AtEnd; nameLbl.ZIndex=10
    -- Badge raridade
    local rarBadge = Instance.new("Frame",row); rarBadge.BackgroundColor3=COR; rarBadge.BackgroundTransparency=0.15
    rarBadge.BorderSizePixel=0; rarBadge.Position=UDim2.new(0,64,0,28); rarBadge.Size=UDim2.new(0,80,0,18); rarBadge.ZIndex=10
    Instance.new("UICorner",rarBadge).CornerRadius=UDim.new(0,6)
    local rarBadgeS = Instance.new("UIStroke",rarBadge); rarBadgeS.Color=Color3.fromRGB(0,0,0); rarBadgeS.Thickness=1.5; rarBadgeS.Transparency=0.4
    local rarLbl = Instance.new("TextLabel",rarBadge); rarLbl.BackgroundTransparency=1
    rarLbl.Size=UDim2.new(1,0,1,0); rarLbl.Font=Enum.Font.GothamBold
    rarLbl.Text=(rarity and (rarity.icon.." "..rarity.label) or "📦 Comum")
    rarLbl.TextColor3=Color3.fromRGB(255,255,255); rarLbl.TextSize=8; rarLbl.ZIndex=11
    -- Badge NOVO / Teleportou
    local tagBadge = Instance.new("Frame",row); tagBadge.BorderSizePixel=0
    tagBadge.AnchorPoint=Vector2.new(1,0); tagBadge.Position=UDim2.new(1,-54,0,6)
    tagBadge.Size=UDim2.new(0,0,0,16); tagBadge.ZIndex=11
    Instance.new("UICorner",tagBadge).CornerRadius=UDim.new(0,5)
    local tagLbl = Instance.new("TextLabel",tagBadge); tagLbl.BackgroundTransparency=1
    tagLbl.Size=UDim2.new(1,0,1,0); tagLbl.Font=Enum.Font.GothamBlack; tagLbl.TextSize=7; tagLbl.ZIndex=12
    entry.tagBadge=tagBadge; entry.tagLbl=tagLbl
    if wasVisited then
        tagBadge.BackgroundColor3=Color3.fromRGB(240,200,40); tagBadge.Size=UDim2.new(0,72,0,16)
        tagLbl.Text="✓ Teleportou!"; tagLbl.TextColor3=Color3.fromRGB(50,30,5)
    elseif isNew then
        tagBadge.BackgroundColor3=Color3.fromRGB(60,220,110); tagBadge.Size=UDim2.new(0,0,0,16)
        tagLbl.Text="★ NOVO"; tagLbl.TextColor3=Color3.fromRGB(10,40,20)
        TweenService:Create(tagBadge,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,52,0,16)}):Play()
    end
    entry.row=row; entry.rowS=rowS; entry.nameLbl=nameLbl
    -- Botão TP
    local tpb = Instance.new("TextButton",row)
    tpb.BackgroundColor3=Color3.fromRGB(255,200,60); tpb.BackgroundTransparency=0; tpb.Text=""
    tpb.BorderSizePixel=0; tpb.AnchorPoint=Vector2.new(1,0.5)
    tpb.Position=UDim2.new(1,-8,0.5,0); tpb.Size=UDim2.new(0,42,0,36); tpb.ZIndex=11
    Instance.new("UICorner",tpb).CornerRadius=UDim.new(0,10)
    local tpbS = Instance.new("UIStroke",tpb); tpbS.Color=Color3.fromRGB(80,50,0); tpbS.Thickness=2.5
    local tpbG = Instance.new("UIGradient",tpb)
    tpbG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,230,90)),ColorSequenceKeypoint.new(1,Color3.fromRGB(200,140,20))}); tpbG.Rotation=90
    local tpbShine = Instance.new("Frame",tpb); tpbShine.BackgroundColor3=Color3.fromRGB(255,255,255)
    tpbShine.BackgroundTransparency=0.62; tpbShine.BorderSizePixel=0
    tpbShine.Position=UDim2.new(0,4,0,3); tpbShine.Size=UDim2.new(0.7,0,0,5); tpbShine.ZIndex=12
    Instance.new("UICorner",tpbShine).CornerRadius=UDim.new(1,0)
    local tpbL = Instance.new("TextLabel",tpb); tpbL.BackgroundTransparency=1
    tpbL.Size=UDim2.new(1,0,1,0); tpbL.Font=Enum.Font.GothamBlack
    tpbL.Text="TP"; tpbL.TextColor3=Color3.fromRGB(16,8,0); tpbL.TextSize=12; tpbL.ZIndex=13
    local function doTp()
        chestVisited[nk]=true; entry.visited=true
        TweenService:Create(tpb,TweenInfo.new(0.08),{BackgroundTransparency=0.5}):Play()
        task.delay(0.15,function() TweenService:Create(tpb,TweenInfo.new(0.15),{BackgroundTransparency=0}):Play() end)
        TweenService:Create(row,TweenInfo.new(0.25),{BackgroundColor3=Color3.fromRGB(55,18,10)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.25),{Color=Color3.fromRGB(200,60,60),Transparency=0.1}):Play()
        TweenService:Create(nameLbl,TweenInfo.new(0.2),{TextColor3=Color3.fromRGB(200,130,130)}):Play()
        tagBadge.BackgroundColor3=Color3.fromRGB(240,200,40)
        tagLbl.Text="✓ Teleportou!"; tagLbl.TextColor3=Color3.fromRGB(50,30,5)
        if tagBadge.Size.X.Offset < 70 then
            TweenService:Create(tagBadge,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,72,0,16)}):Play()
        end
        safeTp(pos, 5)
        Notify.send({type="custom",icon=rarity and rarity.icon or "🎁",accent=COR,
            title=bd.label,msg="#"..idx.." "..name,duration=2.5})
    end
    tpb.MouseButton1Click:Connect(doTp)
    local rowHit = Instance.new("TextButton",row); rowHit.BackgroundTransparency=1
    rowHit.Size=UDim2.new(1,-52,1,0); rowHit.Text=""; rowHit.ZIndex=10
    rowHit.MouseButton1Click:Connect(doTp)
    rowHit.MouseEnter:Connect(function() if not entry.visited then
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(58,38,86)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Transparency=0.3}):Play() end end)
    rowHit.MouseLeave:Connect(function() if not entry.visited then
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=baseClr}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Transparency=0.68}):Play() end end)
    return entry
end

-- ── Scan ─────────────────────────────────────────────────────────
local function cpScanChests(isRefresh)
    if chestScanRun2 then return end
    chestScanRun2 = true
    cpBtnRefL.Text = "⏳"; task.delay(1, function() cpBtnRefL.Text = "🔄" end)
    -- Snapshot dos baús já conhecidos (para detectar NOVO)
    local knownKeys = {}
    for k in pairs(chestSeenKeys2) do knownKeys[k] = true end
    task.spawn(function()
        local ok, err = pcall(function()
        local found = 0
        local batch = 0
        local seenModels = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            batch = batch + 1
            if batch % 300 == 0 then task.wait() end
            if not obj:IsA("Model") then continue end
            if obj:FindFirstChildWhichIsA("Humanoid") then continue end
            if seenModels[obj] then continue end
            seenModels[obj] = true
            local nm = obj.Name:lower()
            if not (nm:find("chest",1,true) or nm:find("bau",1,true) or
                    nm:find("baú",1,true) or nm:find("crate",1,true) or
                    nm:find("loot",1,true)) then continue end
            if nm:find("corpse",1,true) or nm:find("npc",1,true) then continue end
            local part = nil
            pcall(function()
                local maxSz = 0
                for _, bp in ipairs(obj:GetDescendants()) do
                    if bp:IsA("BasePart") then
                        local s = bp.Size.X+bp.Size.Y+bp.Size.Z
                        if s > maxSz then maxSz=s; part=bp end
                    end
                end
                if not part then part = obj.PrimaryPart end
            end)
            if not part then continue end
            local pk = cpPosKey(part.Position)
            if chestSeenKeys2[pk] then continue end
            chestSeenKeys2[pk] = true
            local isNew = isRefresh and not knownKeys[pk]
            pcall(function()
                local biomeLabel, biomeIcon, biomeCor = getBiome(obj)
                local rarity = getRarity(obj)
                local bd = cpGetOrCreateBiome(biomeLabel, biomeIcon, biomeCor)
                cpAddEntry(bd, rarity, obj.Name, part.Position, isNew)
                bd.countLbl.Text = tostring(#bd.entries).." baús"
                found = found + 1
                cpEmptyLbl.Visible = false
                -- Atualiza contagem do detalhe se aberto neste bioma
                if cpCurrentBiome == bd then
                    cpDetailCount.Text = tostring(#bd.entries).." baú(s)"
                end
            end)
            if found % 20 == 0 then task.wait() end
        end
        local totalBiomes, totalChests = 0, 0
        for _, bd in pairs(biomeData) do totalBiomes=totalBiomes+1; totalChests=totalChests+#bd.entries end
        cpHdrSub.Text = tostring(totalBiomes).." biomas · "..tostring(totalChests).." baús"
        if found == 0 and isRefresh then Notify.info("Tp Baús","Nenhum baú novo encontrado.")
        elseif found > 0 then
            Notify.send({type="custom",icon="🎁",accent=TP_COR_CHEST,
                title="Baús",msg=(isRefresh and tostring(found).." novo(s) marcados!" or tostring(found).." baús em "..totalBiomes.." biomas!"),duration=3})
        end
        end)
        if not ok then warn("[PudimHub] cpScanChests: "..tostring(err)) end
        chestScanRun2 = false
    end)
end

cpBtnRef.MouseButton1Click:Connect(function() cpScanChests(true) end)
cpBtnClr.MouseButton1Click:Connect(function()
    -- Destrói todos os botões de bioma e scrolls
    for _, bd in pairs(biomeData) do
        pcall(function() if bd.btn then bd.btn:Destroy() end end)
        pcall(function() if bd.scroll then bd.scroll:Destroy() end end)
    end
    biomeData={}; chestSeenKeys2={}; chestVisited={}; biomeOrder=0; cpCurrentBiome=nil
    cpGroupView.Position=OFFSET_CP; cpGroupView.Visible=true
    cpDetailView.Visible=false; cpDetailView.Position=RIGHT_CP
    cpEmptyLbl.Visible=true; cpHdrSub.Text="0 biomas · 0 baús"
    Notify.info("Tp Baús","Lista de baús limpa!")
end)

local chestFirstOpen2 = true
task.spawn(function()
    while true do task.wait(1)
        if Pages["Teleportar"] and Pages["Teleportar"].Visible and chestFirstOpen2 then
            chestFirstOpen2=false; task.wait(0.8); cpScanChests(false)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
-- TP ANIMAIS — Accordion com todos os animais do jogo
-- ══════════════════════════════════════════════════════════════
local TP_COR_ANIMAL = Color3.fromRGB(120, 220, 100)

makeTpSec("🐾  ANIMAIS & ENTIDADES", TP_COR_ANIMAL)

do -- Accordion Tp Animais
local ANIMAIS = {
    -- Passivos
    { label="🐇 Coelho",         cor=Color3.fromRGB(220,200,180), names={"Bunny","Rabbit","bunny","rabbit"} },
    { label="🦃 Peru",            cor=Color3.fromRGB(180,120,60),  names={"Turkey","turkey","Thanksgiving"} },
    { label="🥝 Kiwi",            cor=Color3.fromRGB(120,180,60),  names={"Kiwi","kiwi"} },
    { label="🐴 Cavalo",          cor=Color3.fromRGB(160,120,80),  names={"Horse","horse"} },
    -- Neutros
    { label="🦣 Mamute",          cor=Color3.fromRGB(180,160,140), names={"Mammoth","mammoth","WoollyMammoth","Woolly Mammoth"} },
    { label="🦣 Mamute Musgoso",  cor=Color3.fromRGB(80,140,60),   names={"MossyMammoth","Mossy Mammoth","MossyMammouth","Mossy"} },
    -- Hostis Floresta
    { label="🐺 Lobo",            cor=Color3.fromRGB(160,160,180), names={"Wolf","wolf"} },
    { label="🐺 Lobo Alfa",       cor=Color3.fromRGB(100,100,220), names={"AlphaWolf","Alpha Wolf","alphawolf","alpha wolf"} },
    { label="🐺 Lobo Fada",       cor=Color3.fromRGB(200,100,255), names={"FairyWolf","MushroomWolf","Mushroom Wolf","Fairy Wolf","AcornWolf","Acorn Wolf"} },
    { label="🐻 Urso",            cor=Color3.fromRGB(140,90,50),   names={"Bear","bear","BrownBear","Brown Bear"} },
    { label="🐻‍❄️ Urso Polar",    cor=Color3.fromRGB(200,230,255), names={"PolarBear","Polar Bear","polarbear"} },
    { label="🦊 Raposa Ártica",   cor=Color3.fromRGB(255,160,80),  names={"ArcticFox","Arctic Fox","arcticfox","arctic fox"} },
    -- Bioma Vulcão
    { label="🦏 Helefante",       cor=Color3.fromRGB(255,80,40),   names={"Hellephant","hellephant","LavaMammoth","Lava Mammoth"} },
    { label="🦂 Escorpião",       cor=Color3.fromRGB(200,160,40),  names={"Scorpion","scorpion"} },
    -- Bioma Neve
    -- Bioma Selva
    { label="🐗 Javali",          cor=Color3.fromRGB(120,80,40),   names={"Boar","boar"} },
    -- Sapos (múltiplas variantes)
    { label="🐸 Sapo Verde",      cor=Color3.fromRGB(60,200,60),   names={"GreenFrog","Green Frog","greenfrog"} },
    { label="🐸 Sapo Azul",       cor=Color3.fromRGB(60,120,255),  names={"BlueFrog","Blue Frog","bluefrog"} },
    { label="🐸 Sapo Roxo",       cor=Color3.fromRGB(160,60,220),  names={"PurpleFrog","Purple Frog","purplefrog"} },
    { label="🐸 Sapo Vermelho",   cor=Color3.fromRGB(220,40,40),   names={"RedFrog","Red Frog","redfrog","BigFrog","Big Frog"} },
    { label="🐸 Sapo (geral)",    cor=Color3.fromRGB(80,180,80),   names={"Frog","frog","Toad","toad"} },
    -- Meteor
    { label="🦀 Caranguejo Meteoro", cor=Color3.fromRGB(180,80,220), names={"MeteorCrab","Meteor Crab","meteorcrab","meteor crab"} },
    -- Entidades Principais (Imortais)
    { label="🦌 The Deer",        cor=Color3.fromRGB(80,60,40),    names={"Deer","TheDeer","The Deer","HungryDeer","Hungry Deer"} },
    { label="🦉 The Owl",         cor=Color3.fromRGB(140,100,60),  names={"Owl","TheOwl","The Owl"} },
    { label="🐏 The Ram",         cor=Color3.fromRGB(100,80,60),   names={"Ram","TheRam","The Ram"} },
    { label="🦇 The Bat",         cor=Color3.fromRGB(60,40,80),    names={"Bat","TheBat","The Bat","GiantBat","Giant Bat"} },
    { label="🐱 The Cat",         cor=Color3.fromRGB(80,60,60),    names={"Cat","TheCat","The Cat","CatEntity","Cat Entity"} },
    -- Easter
    { label="🐰 Evil Bunny",      cor=Color3.fromRGB(255,100,150), names={"EvilBunny","Evil Bunny","evilbunny","EasterBunny","Easter Bunny"} },
}

-- Altura do accordion: header(36) + div(9) + N botões × 44px + padding(14)
local _animH = 36 + 9 + (#ANIMAIS * 44) + 14
local _animCard, _animCF = makeAccordionCard(Pages["Teleportar"], tpNextLO, {
    icon="🐾", title="Tp Animais", color=TP_COR_ANIMAL,
    summary="Teleporta para o animal mais próximo de você no servidor.",
    contentH=_animH,
})
local _ay = 36 + 8
_accDivLine(_animCF, _ay, TP_COR_ANIMAL); _ay = _ay + 9

for _, animal in ipairs(ANIMAIS) do
    local row = Instance.new("Frame", _animCF)
    row.BackgroundColor3 = Color3.fromRGB(44,28,68); row.BorderSizePixel = 0
    row.Position = UDim2.new(0,8,0,_ay); row.Size = UDim2.new(1,-16,0,38); row.ZIndex = 7
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,10)
    local rS = Instance.new("UIStroke",row); rS.Color=animal.cor; rS.Thickness=1.2; rS.Transparency=0.65; rS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local bar = Instance.new("Frame",row); bar.BackgroundColor3=animal.cor; bar.BorderSizePixel=0
    bar.Size=UDim2.new(0,3,0,22); bar.Position=UDim2.new(0,0,0.5,-11); bar.ZIndex=8
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,2)
    local lbl = Instance.new("TextLabel",row); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,10,0,0); lbl.Size=UDim2.new(1,-90,1,0)
    lbl.Font=Enum.Font.GothamBold; lbl.Text=animal.label
    lbl.TextColor3=Color3.fromRGB(220,212,245); lbl.TextSize=10
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextYAlignment=Enum.TextYAlignment.Center; lbl.ZIndex=8

    local tpBtn = Instance.new("TextButton",row)
    tpBtn.BackgroundColor3=animal.cor; tpBtn.BackgroundTransparency=0.5; tpBtn.BorderSizePixel=0
    tpBtn.AnchorPoint=Vector2.new(1,0.5); tpBtn.Position=UDim2.new(1,-8,0.5,0)
    tpBtn.Size=UDim2.new(0,64,0,26); tpBtn.Font=Enum.Font.GothamBold; tpBtn.Text="🚀 Tp"
    tpBtn.TextColor3=Color3.fromRGB(255,255,255); tpBtn.TextSize=10; tpBtn.ZIndex=9; tpBtn.AutoButtonColor=false
    Instance.new("UICorner",tpBtn).CornerRadius=UDim.new(0,7)
    local bS=Instance.new("UIStroke",tpBtn); bS.Color=animal.cor; bS.Thickness=1.2; bS.Transparency=0.2; bS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

    tpBtn.MouseEnter:Connect(function() TweenService:Create(tpBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.2}):Play() end)
    tpBtn.MouseLeave:Connect(function() TweenService:Create(tpBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.5}):Play() end)

    local _anim = animal
    tpBtn.MouseButton1Click:Connect(function()
        TweenService:Create(tpBtn,TweenInfo.new(0.08),{Size=UDim2.new(0,58,0,22)}):Play()
        task.delay(0.15,function() pcall(function() TweenService:Create(tpBtn,TweenInfo.new(0.15,Enum.EasingStyle.Back),{Size=UDim2.new(0,64,0,26)}):Play() end) end)
        local found = false
        pcall(function()
            local ch = Player.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local myPos = hrp.Position
            local bestDist = math.huge
            local bestPos = nil
            for _, obj in ipairs(workspace:GetDescendants()) do
                local n = obj.Name
                for _, nm in ipairs(_anim.names) do
                    if n:lower():find(nm:lower(), 1, true) then
                        local pos
                        if obj:IsA("BasePart") then pos = obj.Position
                        elseif obj:IsA("Model") then
                            local p = obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart
                            if p then pos = p.Position end
                        end
                        if pos then
                            local d = (pos - myPos).Magnitude
                            if d < bestDist then bestDist = d; bestPos = pos end
                        end
                    end
                end
            end
            if bestPos then
                hrp.CFrame = CFrame.new(bestPos + Vector3.new(0,4,0))
                Notify.send({type="custom",icon=_anim.label:sub(1,2),accent=_anim.cor,
                    title="Teleporte",msg=_anim.label.." — "..math.floor(bestDist).." studs!",duration=2.5})
                found = true
            end
        end)
        if not found then
            Notify.warn("Tp Animais","⚠️ "..animal.label:gsub("^..", "").." não encontrado no mapa!")
        end
    end)

    _ay = _ay + 44
end
end -- Accordion Tp Animais

-- ══════════════════════════════════════════════════════════════
-- TP JOGADOR — Dropdown com todos os jogadores do servidor
-- ══════════════════════════════════════════════════════════════
local TP_COR_PLAYER = Color3.fromRGB(80, 180, 255)
makeTpSec("👤  JOGADORES", TP_COR_PLAYER)

do -- Tp Jogador block
local _selectedPlayer = nil  -- PlrObject selecionado
local _tpPlrDropOpen = false
local _tpPlrDrop = nil

-- Row principal
local plrRow = Instance.new("Frame", Pages["Teleportar"])
plrRow.BackgroundColor3 = Color3.fromRGB(44,28,68); plrRow.BorderSizePixel=0
plrRow.Size=UDim2.new(1,0,0,54); plrRow.LayoutOrder=tpNextLO(); plrRow.ZIndex=5
Instance.new("UICorner",plrRow).CornerRadius=UDim.new(0,12)
local prS=Instance.new("UIStroke",plrRow); prS.Color=TP_COR_PLAYER; prS.Thickness=1.2; prS.Transparency=0.6; prS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

-- Botão de seleção (dropdown trigger)
local selBtn = Instance.new("TextButton", plrRow)
selBtn.BackgroundColor3=Color3.fromRGB(36,20,62); selBtn.BorderSizePixel=0
selBtn.Position=UDim2.new(0,8,0.5,-14); selBtn.Size=UDim2.new(0.60,-12,0,28)
selBtn.Font=Enum.Font.GothamBold; selBtn.Text="▾  Selecionar jogador"
selBtn.TextColor3=Color3.fromRGB(160,140,210); selBtn.TextSize=10; selBtn.ZIndex=6; selBtn.AutoButtonColor=false
selBtn.TextXAlignment=Enum.TextXAlignment.Left
local selPad=Instance.new("UIPadding",selBtn); selPad.PaddingLeft=UDim.new(0,10)
Instance.new("UICorner",selBtn).CornerRadius=UDim.new(0,8)
local selS=Instance.new("UIStroke",selBtn); selS.Color=TP_COR_PLAYER; selS.Thickness=1; selS.Transparency=0.5; selS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

-- Botão Tp
local tpPlrBtn = Instance.new("TextButton", plrRow)
tpPlrBtn.BackgroundColor3=TP_COR_PLAYER; tpPlrBtn.BackgroundTransparency=0.4; tpPlrBtn.BorderSizePixel=0
tpPlrBtn.AnchorPoint=Vector2.new(1,0.5); tpPlrBtn.Position=UDim2.new(1,-8,0.5,0)
tpPlrBtn.Size=UDim2.new(0,74,0,28); tpPlrBtn.Font=Enum.Font.GothamBold; tpPlrBtn.Text="🚀  Tp"
tpPlrBtn.TextColor3=Color3.fromRGB(255,255,255); tpPlrBtn.TextSize=11; tpPlrBtn.ZIndex=6; tpPlrBtn.AutoButtonColor=false
Instance.new("UICorner",tpPlrBtn).CornerRadius=UDim.new(0,8)
local tpPS=Instance.new("UIStroke",tpPlrBtn); tpPS.Color=TP_COR_PLAYER; tpPS.Thickness=1.2; tpPS.Transparency=0.2; tpPS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

-- Label de status abaixo
local statusLbl = Instance.new("TextLabel", plrRow)
statusLbl.BackgroundTransparency=1
statusLbl.Position=UDim2.new(0,10,0.5,4); statusLbl.Size=UDim2.new(1,-20,0,14)
statusLbl.Font=Enum.Font.Gotham; statusLbl.Text="Nenhum jogador selecionado"
statusLbl.TextColor3=Color3.fromRGB(120,100,160); statusLbl.TextSize=9
statusLbl.TextXAlignment=Enum.TextXAlignment.Left; statusLbl.ZIndex=6

-- Hover tpPlrBtn
tpPlrBtn.MouseEnter:Connect(function() TweenService:Create(tpPlrBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.1}):Play() end)
tpPlrBtn.MouseLeave:Connect(function() TweenService:Create(tpPlrBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.4}):Play() end)

-- Fecha dropdown
local function closePlrDrop()
    _tpPlrDropOpen = false
    if _tpPlrDrop then
        TweenService:Create(_tpPlrDrop,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Size=UDim2.new(_tpPlrDrop.Size.X.Scale,_tpPlrDrop.Size.X.Offset,0,0),BackgroundTransparency=1}):Play()
        task.delay(0.18,function() pcall(function() _tpPlrDrop:Destroy() end) end)
        _tpPlrDrop = nil
    end
end

-- Abre dropdown com lista de jogadores
local function openPlrDrop()
    closePlrDrop()
    _tpPlrDropOpen = true

    local plrs = game:GetService("Players"):GetPlayers()
    local ITEM_H = 40
    local dropH = #plrs * ITEM_H + 8
    local VP = workspace.CurrentCamera.ViewportSize
    local dropW = math.min(300, VP.X * 0.38)

    local drop = Instance.new("Frame", ScreenGui)
    drop.BackgroundColor3=Color3.fromRGB(14,8,28); drop.BorderSizePixel=0
    drop.ZIndex=960; drop.ClipsDescendants=true
    drop.Size=UDim2.new(0,dropW,0,0)
    Instance.new("UICorner",drop).CornerRadius=UDim.new(0,12)
    local dStroke=Instance.new("UIStroke",drop); dStroke.Color=TP_COR_PLAYER; dStroke.Thickness=1.8; dStroke.Transparency=0.15; dStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local dGrad=Instance.new("UIGradient",drop)
    dGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(20,12,44)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,5,22))}); dGrad.Rotation=135

    -- Posição abaixo do selBtn
    local bAP=selBtn.AbsolutePosition; local bAS=selBtn.AbsoluteSize
    local dropX=math.clamp(bAP.X,8,VP.X-dropW-8)
    local dropY=bAP.Y+bAS.Y+4
    if dropY+dropH>VP.Y-8 then dropY=bAP.Y-dropH-4 end
    drop.Position=UDim2.new(0,dropX,0,dropY)

    -- Animar abertura
    TweenService:Create(drop,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,dropW,0,dropH+8)}):Play()

    -- Lista de jogadores
    local list=Instance.new("UIListLayout",drop); list.Padding=UDim.new(0,2); list.SortOrder=Enum.SortOrder.LayoutOrder
    local pad=Instance.new("UIPadding",drop); pad.PaddingTop=UDim.new(0,4); pad.PaddingLeft=UDim.new(0,4); pad.PaddingRight=UDim.new(0,4); pad.PaddingBottom=UDim.new(0,4)

    for i, plr in ipairs(plrs) do
        local isMe = plr == Player
        local cell = Instance.new("TextButton",drop)
        cell.BackgroundColor3=isMe and Color3.fromRGB(30,18,55) or Color3.fromRGB(24,14,44)
        cell.BackgroundTransparency=0.2; cell.BorderSizePixel=0
        cell.Size=UDim2.new(1,0,0,ITEM_H-2); cell.LayoutOrder=i
        cell.Font=Enum.Font.GothamBold; cell.Text=""
        cell.ZIndex=961; cell.AutoButtonColor=false
        Instance.new("UICorner",cell).CornerRadius=UDim.new(0,8)
        local cS=Instance.new("UIStroke",cell); cS.Color=TP_COR_PLAYER; cS.Thickness=1; cS.Transparency=0.7; cS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

        -- Avatar mini
        local avatarBg=Instance.new("Frame",cell); avatarBg.BackgroundColor3=TP_COR_PLAYER; avatarBg.BackgroundTransparency=0.7; avatarBg.BorderSizePixel=0
        avatarBg.AnchorPoint=Vector2.new(0,0.5); avatarBg.Position=UDim2.new(0,6,0.5,0); avatarBg.Size=UDim2.new(0,26,0,26); avatarBg.ZIndex=962
        Instance.new("UICorner",avatarBg).CornerRadius=UDim.new(1,0)
        local avatarImg=Instance.new("ImageLabel",avatarBg); avatarImg.BackgroundTransparency=1; avatarImg.Size=UDim2.new(1,0,1,0)
        avatarImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(plr.UserId).."&width=48&height=48&format=png"
        avatarImg.ZIndex=963; Instance.new("UICorner",avatarImg).CornerRadius=UDim.new(1,0)

        -- Nome
        local nameLbl=Instance.new("TextLabel",cell); nameLbl.BackgroundTransparency=1
        nameLbl.Position=UDim2.new(0,38,0,2); nameLbl.Size=UDim2.new(1,-44,0,18)
        nameLbl.Font=Enum.Font.GothamBold; nameLbl.Text=plr.DisplayName
        nameLbl.TextColor3=isMe and TP_COR_PLAYER or Color3.fromRGB(225,215,250); nameLbl.TextSize=11
        nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.TextTruncate=Enum.TextTruncate.AtEnd; nameLbl.ZIndex=962

        -- Username
        local userLbl=Instance.new("TextLabel",cell); userLbl.BackgroundTransparency=1
        userLbl.Position=UDim2.new(0,38,0,20); userLbl.Size=UDim2.new(1,-44,0,12)
        userLbl.Font=Enum.Font.Gotham; userLbl.Text="@"..plr.Name..(isMe and "  (você)" or "")
        userLbl.TextColor3=Color3.fromRGB(100,85,140); userLbl.TextSize=9
        userLbl.TextXAlignment=Enum.TextXAlignment.Left; userLbl.TextTruncate=Enum.TextTruncate.AtEnd; userLbl.ZIndex=962

        -- Hover
        cell.MouseEnter:Connect(function()
            TweenService:Create(cell,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(40,24,72),BackgroundTransparency=0}):Play()
            TweenService:Create(cS,TweenInfo.new(0.1),{Transparency=0.3}):Play()
        end)
        cell.MouseLeave:Connect(function()
            TweenService:Create(cell,TweenInfo.new(0.12),{BackgroundColor3=isMe and Color3.fromRGB(30,18,55) or Color3.fromRGB(24,14,44),BackgroundTransparency=0.2}):Play()
            TweenService:Create(cS,TweenInfo.new(0.12),{Transparency=0.7}):Play()
        end)

        cell.MouseButton1Click:Connect(function()
            _selectedPlayer = plr
            selBtn.Text = "▸  "..plr.DisplayName
            selBtn.TextColor3 = TP_COR_PLAYER
            statusLbl.Text = "@"..plr.Name.." selecionado"
            TweenService:Create(prS,TweenInfo.new(0.15),{Transparency=0.2}):Play()
            closePlrDrop()
        end)
    end

    -- Fechar ao clicar fora
    local _conn
    _conn = UserInputService.InputBegan:Connect(function(inp,gp)
        if gp then return end
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then
            task.wait()
            local mp=UserInputService:GetMouseLocation()
            local dp=drop.AbsolutePosition; local ds=drop.AbsoluteSize
            if mp.X<dp.X or mp.X>dp.X+ds.X or mp.Y<dp.Y or mp.Y>dp.Y+ds.Y then
                closePlrDrop(); if _conn then _conn:Disconnect() end
            end
        end
    end)
    _tpPlrDrop = drop
end

-- Click no selBtn = abre dropdown
selBtn.MouseButton1Click:Connect(function()
    if _tpPlrDropOpen then closePlrDrop()
    else openPlrDrop() end
end)

-- Click no tpPlrBtn = teleporta
tpPlrBtn.MouseButton1Click:Connect(function()
    TweenService:Create(tpPlrBtn,TweenInfo.new(0.08),{Size=UDim2.new(0,66,0,24)}):Play()
    task.delay(0.12,function() pcall(function() TweenService:Create(tpPlrBtn,TweenInfo.new(0.15,Enum.EasingStyle.Back),{Size=UDim2.new(0,74,0,28)}):Play() end) end)

    if not _selectedPlayer then
        Notify.warn("Tp Jogador","⚠️ Selecione um jogador primeiro!"); return
    end
    -- Verifica se ainda está no servidor
    local stillIn = false
    for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p == _selectedPlayer then stillIn=true; break end
    end
    if not stillIn then
        Notify.warn("Tp Jogador","⚠️ ".._selectedPlayer.Name.." saiu do servidor!")
        _selectedPlayer=nil; selBtn.Text="▾  Selecionar jogador"
        selBtn.TextColor3=Color3.fromRGB(160,140,210)
        statusLbl.Text="Nenhum jogador selecionado"
        return
    end
    pcall(function()
        local ch = Player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local tCh = _selectedPlayer.Character
        local tHrp = tCh and tCh:FindFirstChild("HumanoidRootPart")
        if tHrp then
            hrp.CFrame = tHrp.CFrame + Vector3.new(2,0,2)
            Notify.send({type="custom",icon="👤",accent=TP_COR_PLAYER,
                title="Tp Jogador",msg="Teleportado para ".._selectedPlayer.DisplayName.."!",duration=2.5})
        else
            Notify.warn("Tp Jogador","⚠️ Personagem de ".._selectedPlayer.Name.." não encontrado!")
        end
    end)
end)

end -- Tp Jogador block

end); if not _dbgOk_11847 then warn('[PudimHub DEBUG] Erro na secao TELEPORTAR: '..tostring(_dbgErr_11847)) end

-- ══════════════════════════════════════════════════════════════
-- FARM TAB + AVANÇADO FARM TAB
-- ══════════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════
-- ═══════════════════════════════════════════════════════════════════
-- HELPERS NAVY — Farm (definidos FORA dos pcalls para serem
--   acessíveis em Farm Part 1 e Farm Part 2)
-- ═══════════════════════════════════════════════════════════════════
local _NB_F=Color3.fromRGB(10,20,52)
local _NS_F=Color3.fromRGB(45,75,155)
local _NT_F=Color3.fromRGB(200,215,245)
local _ND_F=Color3.fromRGB(45,75,155)
local _ON_F=Color3.fromRGB(50,120,255)
local _OF_F=Color3.fromRGB(65,72,90)

local function _nfc(loFn)
    local c2=Instance.new("Frame",Pages["Farm"])
    c2.BackgroundColor3=_NB_F; c2.BackgroundTransparency=0.28
    c2.BorderSizePixel=0; c2.LayoutOrder=loFn(); c2.ZIndex=5
    Instance.new("UICorner",c2).CornerRadius=UDim.new(0,12)
    local s2=Instance.new("UIStroke",c2)
    s2.Color=_NS_F; s2.Thickness=1; s2.Transparency=0.50
    s2.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    return c2
end

local function _nfd(c2,y)
    local d2=Instance.new("Frame",c2); d2.BackgroundColor3=_ND_F
    d2.BackgroundTransparency=0.58; d2.BorderSizePixel=0
    d2.Position=UDim2.new(0,12,0,y); d2.Size=UDim2.new(1,-24,0,1); d2.ZIndex=6
    return 1
end

local function _nft(c2,y,lbl,initOn,onToggle)
    local H=44
    local tl=Instance.new("TextLabel",c2); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,y); tl.Size=UDim2.new(0.65,0,0,H)
    tl.Font=Enum.Font.GothamBold; tl.Text=lbl
    tl.TextColor3=_NT_F; tl.TextSize=11
    tl.TextXAlignment=Enum.TextXAlignment.Left
    tl.TextYAlignment=Enum.TextYAlignment.Center
    tl.TextWrapped=true; tl.ZIndex=6
    local pill=Instance.new("Frame",c2); pill.BorderSizePixel=0
    pill.AnchorPoint=Vector2.new(1,0.5)
    pill.Position=UDim2.new(1,-12,0,y+H/2)
    pill.Size=UDim2.new(0,44,0,22); pill.ZIndex=8
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    pill.BackgroundColor3=initOn and _ON_F or Color3.fromRGB(100,80,120)
    local knob=Instance.new("Frame",pill); knob.BorderSizePixel=0
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.ZIndex=10; knob.Size=UDim2.new(0,16,0,16)
    knob.Position=initOn and UDim2.new(1,-11,0.5,0) or UDim2.new(0,11,0.5,0)
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local en=initOn
    local btn=Instance.new("TextButton",c2); btn.BackgroundTransparency=1
    btn.Position=UDim2.new(0,0,0,y); btn.Size=UDim2.new(1,0,0,H)
    btn.Text=""; btn.ZIndex=11
    btn.MouseButton1Click:Connect(function()
        en=not en
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=en and _ON_F or Color3.fromRGB(100,80,120)}):Play()
    TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position=en and UDim2.new(1,-11,0.5,0) or UDim2.new(0,11,0.5,0)
    }):Play()
        if onToggle then onToggle(en) end
    end)
    return H
end

local function _nfs(c2,y,lbl,minV,maxV,defV,cor,onChange)
    local H=50
    local tl=Instance.new("TextLabel",c2); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,y); tl.Size=UDim2.new(0.44,0,0,H)
    tl.Font=Enum.Font.GothamBold; tl.Text=lbl
    tl.TextColor3=_NT_F; tl.TextSize=10
    tl.TextXAlignment=Enum.TextXAlignment.Left
    tl.TextYAlignment=Enum.TextYAlignment.Center
    tl.TextWrapped=true; tl.ZIndex=6
    local vl=Instance.new("TextLabel",c2); vl.BackgroundTransparency=1
    vl.Position=UDim2.new(0.46,0,0,y+(H-16)/2); vl.Size=UDim2.new(0,28,0,16)
    vl.Font=Enum.Font.GothamBold; vl.Text=tostring(defV)
    vl.TextColor3=_NT_F; vl.TextSize=11
    vl.TextXAlignment=Enum.TextXAlignment.Left; vl.ZIndex=7
    local p0=math.clamp((defV-minV)/(maxV-minV),0,1)
    local tr=Instance.new("Frame",c2); tr.BackgroundColor3=Color3.fromRGB(20,36,80)
    tr.BorderSizePixel=0
    tr.Position=UDim2.new(0.46,32,0,y+H/2-2)
    tr.Size=UDim2.new(0.51,-46,0,4); tr.ZIndex=7
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
    local fi=Instance.new("Frame",tr); fi.BackgroundColor3=cor
    fi.BorderSizePixel=0; fi.Size=UDim2.new(p0,0,1,0); fi.ZIndex=8
    Instance.new("UICorner",fi).CornerRadius=UDim.new(1,0)
    local kn=Instance.new("Frame",tr); kn.BackgroundColor3=Color3.fromRGB(25,48,105)
    kn.BorderSizePixel=0; kn.AnchorPoint=Vector2.new(0.5,0.5)
    kn.Position=UDim2.new(p0,0,0.5,0); kn.Size=UDim2.new(0,16,0,16); kn.ZIndex=9
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local ks=Instance.new("UIStroke",kn); ks.Color=cor; ks.Thickness=1.5
    ks.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local dr=false
    local function sv(pct)
        pct=math.clamp(pct,0,1)
        local v=math.round(minV+(maxV-minV)*pct)
        vl.Text=tostring(v); fi.Size=UDim2.new(pct,0,1,0); kn.Position=UDim2.new(pct,0,0.5,0)
        if onChange then onChange(v) end
    end
    local sb=Instance.new("TextButton",tr); sb.BackgroundTransparency=1
    sb.Size=UDim2.new(1,24,1,24); sb.Position=UDim2.new(0,-12,0,-12); sb.Text=""; sb.ZIndex=10
    sb.MouseButton1Down:Connect(function()
        dr=true
        local ap=tr.AbsolutePosition; local as=tr.AbsoluteSize
        sv((UserInputService:GetMouseLocation().X-ap.X)/as.X)
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dr then return end
        if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local ap=tr.AbsolutePosition; local as=tr.AbsoluteSize
        sv((inp.Position.X-ap.X)/as.X)
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end
    end)
    return H
end

local function _nfSec(title, cor)
    local sec=Instance.new("Frame",Pages["Farm"])
    sec.BackgroundColor3=Color3.fromRGB(18,30,60); sec.BackgroundTransparency=0.65; sec.BorderSizePixel=0
    sec.Size=UDim2.new(1,0,0,26); sec.LayoutOrder=fNextLO(); sec.ZIndex=4
    Instance.new("UICorner",sec).CornerRadius=UDim.new(0,9)
    local pill=Instance.new("Frame",sec); pill.BackgroundColor3=cor or _ON_F; pill.BorderSizePixel=0
    pill.Size=UDim2.new(0,4,0.7,0); pill.Position=UDim2.new(0,8,0.15,0); pill.ZIndex=5
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",sec); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,18,0,0); lbl.Size=UDim2.new(1,-22,1,0)
    lbl.Font=Enum.Font.GothamBlack; lbl.Text=title
    lbl.TextColor3=Color3.fromRGB(180,210,255); lbl.TextSize=10
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
end

local _dbgOk_14823, _dbgErr_14823 = pcall(function() -- [[ FARM1 ]]

-- ─── Utilitários de UI para Farm ──────────────────────────────
local farmLO  = 0
local avfLO   = 0
fNextLO = function()  farmLO = farmLO + 1;  return farmLO  end
afNextLO = function() avfLO = avfLO + 1;   return avfLO   end

-- Seção (cabeçalho) genérica — Voidware: só texto, sem card
makeSec = function(page, lo_fn, titleKey, cor)
    local hdr=Instance.new("Frame", page)
    hdr.BackgroundTransparency=1
    hdr.BorderSizePixel=0; hdr.Size=UDim2.new(1,0,0,26); hdr.LayoutOrder=lo_fn(); hdr.ZIndex=4
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,4,0,0)
    lbl.Size=UDim2.new(1,-8,1,0); lbl.Font=Enum.Font.GothamBold
    lbl.TextColor3=VD_SECTION; lbl.TextSize=11
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    TL(lbl, titleKey)
end

-- Toggle genérico — Voidware: row plana + pill toggle
makeToggle = function(page, lo_fn, lbl_txt, desc_txt, cor, onToggle)
    local row=Instance.new("Frame", page)
    row.BackgroundColor3=VD_ROW; row.BackgroundTransparency=0.65; row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,48); row.LayoutOrder=lo_fn(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    -- Título
    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,8); tl.Size=UDim2.new(1,-80,0,18); tl.Font=Enum.Font.GothamBold
    tl.Text=lbl_txt; tl.TextColor3=VD_TEXT; tl.TextSize=12
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    -- Descrição
    local td=Instance.new("TextLabel",row); td.BackgroundTransparency=1
    td.Position=UDim2.new(0,14,0,27); td.Size=UDim2.new(1,-80,0,16); td.Font=Enum.Font.Gotham
    td.Text=desc_txt; td.TextColor3=VD_MUTED; td.TextSize=9
    td.TextXAlignment=Enum.TextXAlignment.Left; td.TextWrapped=true; td.ZIndex=7
    -- Pill toggle iOS-style
    local pill=Instance.new("Frame",row)
    pill.BackgroundColor3=Color3.fromRGB(100,80,120); pill.BorderSizePixel=0
    pill.AnchorPoint=Vector2.new(1,0.5); pill.Position=UDim2.new(1,-10,0.5,0)
    pill.Size=UDim2.new(0,44,0,24); pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BorderSizePixel=0
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.ZIndex=10; knob.Size=UDim2.new(0,18,0,18); knob.Position=UDim2.new(0,13,0.5,0)
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.BorderSizePixel=0
    btn.AutoButtonColor=false; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=11
    btn.MouseEnter:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.12),{BackgroundTransparency=0.5}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.12),{BackgroundTransparency=0.65}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=state and cor or Color3.fromRGB(100,80,120)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=state and UDim2.new(1,-13,0.5,0) or UDim2.new(0,13,0.5,0)
        }):Play()
        task.spawn(function()
            pcall(function()
                local sndId = state and 6031221736 or 2544086171
                local snd = Instance.new("Sound")
                snd.SoundId = "rbxassetid://"..tostring(sndId)
                snd.Volume = 0.35; snd.RollOffMaxDistance = 0
                snd.Parent = SoundService
                if not snd.IsLoaded then snd.Loaded:Wait() end
                snd:Play()
                game:GetService("Debris"):AddItem(snd, 3)
            end)
        end)
        if state then
            Notify.success(lbl_txt, "✓ Ativado")
        else
            Notify.send({type="error", icon="✕", accent=Color3.fromRGB(255,75,75), title=lbl_txt, msg="✗ Desativado"})
        end
        onToggle(state)
    end)
    return function() return state end
end

-- Slider genérico — Voidware: row plana, track fino, thumb branco
local function makeSlider(page, lo_fn, lbl_txt, minV, maxV, defV, cor, fmt, onChange)
    -- ── Estilo foto: label esquerda, valor + track fino + knob branco ──
    local FILL_COR = Color3.fromRGB(220,60,100)  -- rosa/vermelho igual foto
    local row=Instance.new("Frame",page)
    row.BackgroundColor3=Color3.fromRGB(60,38,72); row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,48); row.LayoutOrder=lo_fn(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)

    -- Label esquerda
    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,12,0,0); tl.Size=UDim2.new(0.48,0,1,0)
    tl.Font=Enum.Font.GothamBold; tl.Text=lbl_txt
    tl.TextColor3=Color3.fromRGB(230,220,245); tl.TextSize=11
    tl.TextXAlignment=Enum.TextXAlignment.Left
    tl.TextYAlignment=Enum.TextYAlignment.Center
    tl.TextWrapped=true; tl.ZIndex=7

    local curVal=defV
    local isInfinite=(maxV==math.huge)
    local displayMax=isInfinite and 9999 or maxV
    local t0=math.clamp((defV-minV)/(displayMax-minV),0,1)

    -- Valor numérico — imediatamente antes do track
    local valLbl=Instance.new("TextLabel",row); valLbl.BackgroundTransparency=1
    valLbl.AnchorPoint=Vector2.new(1,0.5)
    valLbl.Position=UDim2.new(0.52,0,0.5,0); valLbl.Size=UDim2.new(0,28,0,20)
    valLbl.Font=Enum.Font.GothamBold; valLbl.TextSize=11
    valLbl.TextColor3=Color3.fromRGB(230,220,245)
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=7

    -- Track background fino (3px)
    local trackBg=Instance.new("Frame",row)
    trackBg.BackgroundColor3=Color3.fromRGB(80,58,100); trackBg.BorderSizePixel=0
    trackBg.Position=UDim2.new(0.52,6,0.5,-1.5)
    trackBg.Size=UDim2.new(0.44,-18,0,3); trackBg.ZIndex=7
    Instance.new("UICorner",trackBg).CornerRadius=UDim.new(1,0)

    -- Fill rosa/vermelho
    local fill=Instance.new("Frame",trackBg)
    fill.BackgroundColor3=FILL_COR; fill.BorderSizePixel=0
    fill.Size=UDim2.new(t0,0,1,0); fill.ZIndex=8
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    -- Knob branco círculo na ponta do fill
    local knob=Instance.new("Frame",trackBg)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0
    knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(t0,0,0.5,0); knob.Size=UDim2.new(0,14,0,14); knob.ZIndex=9
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    -- Sombra suave
    local knobS=Instance.new("UIStroke",knob); knobS.Color=Color3.fromRGB(0,0,0)
    knobS.Thickness=0.8; knobS.Transparency=0.6; knobS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

    local function updateSlider(v)
        curVal=v
        local t=math.clamp((v-minV)/(displayMax-minV),0,1)
        fill.Size=UDim2.new(t,0,1,0); knob.Position=UDim2.new(t,0,0.5,0)
        if fmt then valLbl.Text=fmt(v)
        elseif isInfinite and v>=9999 then valLbl.Text="∞"
        else valLbl.Text=tostring(math.floor(v)) end
        onChange(v)
    end
    if fmt then valLbl.Text=fmt(defV)
    elseif isInfinite and defV>=9999 then valLbl.Text="∞"
    else valLbl.Text=tostring(math.floor(defV)) end

    local dragging=false
    local function onInput(x)
        local rel=trackBg.AbsolutePosition.X; local w=trackBg.AbsoluteSize.X
        local t=math.clamp((x-rel)/w,0,1)
        local v=math.clamp(math.floor(minV+t*(displayMax-minV)+0.5),minV,displayMax)
        if isInfinite and v>=9990 then v=math.huge end
        updateSlider(v)
    end
    local sb=Instance.new("TextButton",trackBg); sb.BackgroundTransparency=1
    sb.Size=UDim2.new(1,24,1,24); sb.Position=UDim2.new(0,-12,0,-12); sb.Text=""; sb.ZIndex=10
    sb.MouseButton1Down:Connect(function() dragging=true; onInput(UserInputService:GetMouseLocation().X) end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then onInput(inp.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    return function() return curVal end
end

-- ─────────────────────────────────────────────────────
-- ─────────────────────────────────────────────────────
-- UTILITÁRIOS DE MOBS (compartilhado entre Farm + AvFarm)
-- ─────────────────────────────────────────────────────

-- Nomes de MOBS do 99 Nights in the Forest (hostis + passivos caçáveis)
local MOB_NAMES_SET = {
    -- Animais passivos (caçáveis para carne/pelt)
    ["bunny"]=true, ["horse"]=true, ["kiwi"]=true, ["kiwi bird"]=true,
    ["turkey"]=true,
    -- Animais agressivos
    ["wolf"]=true, ["alpha wolf"]=true, ["alphawolf"]=true,
    ["bear"]=true, ["polar bear"]=true, ["polarbear"]=true,
    ["frog"]=true, ["blue frog"]=true, ["purple frog"]=true, ["green frog"]=true,
    ["bluefrog"]=true, ["purplefrog"]=true, ["greenfrog"]=true,
    ["scorpion"]=true, ["hellephant"]=true, ["meteor crab"]=true, ["meteorcrab"]=true,
    ["lava crab"]=true, ["lavacrab"]=true,
    ["mammoth"]=true, ["lava mammoth"]=true, ["lavamammoth"]=true,
    ["arctic fox"]=true, ["arcticfox"]=true,
    -- Cultistas
    ["cultist"]=true, ["axe cultist"]=true, ["axecultist"]=true,
    ["melee cultist"]=true, ["meleecultist"]=true,
    ["crossbow cultist"]=true, ["crossbowcultist"]=true,
    ["juggernaut cultist"]=true, ["juggernauttcultist"]=true, ["juggernaut"]=true,
    ["cultist king"]=true, ["cultistking"]=true,
    ["mega cultist"]=true, ["megacultist"]=true,
    -- Aliens
    ["alien"]=true, ["elite alien"]=true, ["elitealien"]=true,
    -- Monstros
    ["the deer"]=true, ["thedeer"]=true, ["deer"]=true,
    ["the owl"]=true, ["theowl"]=true, ["owl"]=true,
    ["the ram"]=true, ["theram"]=true, ["ram"]=true,
    ["the bat"]=true, ["thebat"]=true, ["bat"]=true,
}

local function isMob(model)
    if not model or not model:IsA("Model") then return false end
    local nm = model.Name:lower()
    return MOB_NAMES_SET[nm] == true
end

local function isPlayerChar(model)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character == model then return true end
    end
    return false
end

local function getMobsInRange(origin, radius)
    local list = {}
    local useInfinite = (radius == math.huge or radius >= 9999)
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if not isMob(obj) then return end
            if isPlayerChar(obj) then return end
            local hum = obj:FindFirstChildWhichIsA("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local hrp = obj:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if not useInfinite then
                local d = (hrp.Position - origin).Magnitude
                if d > radius then return end
            end
            table.insert(list, {model=obj, hum=hum, hrp=hrp})
        end)
    end
    return list
end

-- ══════════════════════════════════════════════════════
--  ❄️ AURA CONGELAR — Avançado Farm
-- ══════════════════════════════════════════════════════
--
-- ANÁLISE DOS PROBLEMAS DA VERSÃO ANTERIOR:
--
--  PROBLEMA 1 — Mobs não ficavam imóveis:
--    BodyPosition/BodyGyro e WalkSpeed=0 são CLIENT-SIDE.
--    O servidor ignora completamente e continua movendo os mobs.
--
--  PROBLEMA 2 — Trava o jogo:
--    Heartbeat (60x/s) + workspace:GetDescendants() = catástrofe.
--    Com 500+ objetos no workspace, isso é 30.000+ iterações/segundo.
--
-- SOLUÇÃO v2:
--
--  FREEZE REAL: CFrame Lock por teleporte contínuo
--    A cada 0.05s, o script teleporta o HRP do mob de volta
--    para a posição congelada. Isso REPLICA para o servidor
--    porque o cliente tem autoridade sobre objetos sem owner.
--    Além disso tenta Anchored=true que também replica em alguns casos.
--
--  PERFORMANCE: Loop separado a 0.05s (20x/s em vez de 60x/s)
--    Varredura de novos mobs só a cada 0.5s (não a cada frame).
--    Cache de mobs congelados em tabela hash para lookup O(1).
--    Nunca chama GetDescendants dentro do Heartbeat.
-- ══════════════════════════════════════════════════════
freezeEnabled = false
freezeRadius  = 185
local frozenMobs     = {}   -- {model, hum, hrp, frozenCF, frozenPos}
local frozenSet      = {}   -- hash model→true para lookup rápido

-- Círculo visual do raio
local FreezeCircle      = nil
local FreezeCircleAdorn = nil

local function createFreezeCircle()
    if FreezeCircleAdorn then pcall(function() FreezeCircleAdorn:Destroy() end) end
    if FreezeCircle      then pcall(function() FreezeCircle:Destroy()      end) end
    local ch = Player.Character; if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local part = Instance.new("Part")
    part.Name = "FreezeAuraCircle"
    part.Size = Vector3.new(freezeRadius*2, 0.15, freezeRadius*2)
    part.Shape = Enum.PartType.Cylinder
    part.CanCollide = false; part.Anchored = false; part.CastShadow = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(0, 200, 255); part.Transparency = 0.55
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp; weld.Part1 = part
    part.CFrame = hrp.CFrame * CFrame.new(0,-2.8,0) * CFrame.Angles(0,0,math.pi/2)
    weld.Parent = part; part.Parent = workspace
    local highlight = Instance.new("SelectionBox")
    highlight.Adornee = part; highlight.Color3 = Color3.fromRGB(0,200,255)
    highlight.LineThickness = 0.05; highlight.SurfaceTransparency = 1
    highlight.Parent = workspace
    FreezeCircle = part; FreezeCircleAdorn = highlight
    -- Animação de pulso (task separada, não bloqueia nada)
    task.spawn(function()
        while freezeEnabled and FreezeCircle and FreezeCircle.Parent do
            task.wait(0.05)
            pcall(function()
                local a = math.abs(math.sin(tick()*2))
                FreezeCircle.Transparency = 0.45 + a*0.35
                highlight.Color3 = Color3.fromRGB(math.floor(a*80), math.floor(180+a*75), 255)
            end)
        end
    end)
end

local function destroyFreezeCircle()
    pcall(function() if FreezeCircle      then FreezeCircle:Destroy();      FreezeCircle=nil      end end)
    pcall(function() if FreezeCircleAdorn then FreezeCircleAdorn:Destroy(); FreezeCircleAdorn=nil end end)
end

updateCircleRadius = function()
    if not FreezeCircle or not FreezeCircle.Parent then return end
    FreezeCircle.Size = Vector3.new(freezeRadius*2, 0.15, freezeRadius*2)
end

-- ── Congela um mob: salva posição e trava por CFrame lock ──────
local function freezeMob(entry)
    pcall(function()
        local hum = entry.hum
        local hrp = entry.hrp
        if not hum or not hum.Parent then return end
        if not hrp  or not hrp.Parent  then return end

        entry.frozenPos = hrp.Position
        entry.frozenCF  = hrp.CFrame
        entry.origSpeed = hum.WalkSpeed
        entry.origJump  = hum.JumpPower

        -- Zera velocidade de movimento
        hum.WalkSpeed = 0
        hum.JumpPower = 0

        -- Tenta Anchored (replica em mobs sem network owner no servidor)
        pcall(function()
            for _, bp in ipairs(entry.model:GetDescendants()) do
                if bp:IsA("BasePart") and bp ~= hrp then
                    bp.Anchored = true
                end
            end
            hrp.Anchored = true
        end)

        -- Para animações de movimento
        pcall(function()
            local anim = hum:FindFirstChild("Animator")
            if anim then
                for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
                    t:AdjustSpeed(0)
                end
            end
        end)

        -- Remove constraints do servidor que movem o mob
        pcall(function()
            for _, c in ipairs(hrp:GetChildren()) do
                if c:IsA("BodyMover") or c:IsA("Constraint") then
                    pcall(function() c:Destroy() end)
                end
            end
        end)
    end)
end

-- ── Descongela um mob ──────────────────────────────────────────
local function unfreezeMob(entry)
    pcall(function()
        local hum = entry.hum
        local hrp  = entry.hrp
        if hum and hum.Parent then
            hum.WalkSpeed = entry.origSpeed or 16
            hum.JumpPower = entry.origJump  or 50
        end
        -- Restaura Anchored
        pcall(function()
            if entry.model and entry.model.Parent then
                for _, bp in ipairs(entry.model:GetDescendants()) do
                    if bp:IsA("BasePart") then bp.Anchored = false end
                end
            end
        end)
        -- Restaura animações
        pcall(function()
            if hum and hum.Parent then
                local anim = hum:FindFirstChild("Animator")
                if anim then
                    for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
                        t:AdjustSpeed(1)
                    end
                end
            end
        end)
    end)
end

local function unfreezeAll()
    for _, e in ipairs(frozenMobs) do pcall(unfreezeMob, e) end
    frozenMobs = {}
    frozenSet  = {}
end

local freezeConn      = nil
local freezeScanCo    = nil  -- coroutine de varredura separada
local _freezeLastAttack = 0  -- controle de cadência do auto-attack

startFreezeAura = function()
    if freezeConn   then freezeConn:Disconnect();   freezeConn   = nil end
    if freezeScanCo then task.cancel(freezeScanCo); freezeScanCo = nil end
    if Player.Character then createFreezeCircle() end
    Player.CharacterAdded:Connect(function()
        if freezeEnabled then task.wait(1); createFreezeCircle() end
    end)

    -- ── Loop de CFrame Lock (20x/s) ────────────────────────────
    -- Reaplica a posição congelada a cada 0.05s.
    -- ESTE é o mecanismo real de freeze — sobrescreve o movimento do servidor.
    -- Separado da varredura para ser leve e consistente.
    freezeConn = RunService.Heartbeat:Connect(function()
        if not freezeEnabled then return end
        if #frozenMobs == 0  then return end

        -- Auto-attack mobs congelados com mouse1press (dano real via servidor)
        local now2 = tick()
        if now2 - _freezeLastAttack >= 0.15 then
            _freezeLastAttack = now2
            local ch2 = Player.Character
            if ch2 and ch2:FindFirstChildWhichIsA("Tool") then
                pcall(function()
                    mouse1press()
                    task.wait(0.05)
                    mouse1release()
                end)
            end
        end

        for _, entry in ipairs(frozenMobs) do
            pcall(function()
                local hrp = entry.hrp
                if not hrp or not hrp.Parent then return end
                if not entry.frozenCF then return end

                -- Teleporte contínuo: força o mob a ficar no lugar
                hrp.CFrame = entry.frozenCF
                pcall(function() hrp.AssemblyLinearVelocity  = Vector3.new(0,0,0) end)
                pcall(function() hrp.AssemblyAngularVelocity = Vector3.new(0,0,0) end)
            end)
        end
    end)

    -- ── Varredura de novos mobs (a cada 0.5s) ─────────────────
    -- Separada do Heartbeat para não travar o jogo.
    -- workspace:GetDescendants() só é chamado 2x/s, não 60x/s.
    freezeScanCo = task.spawn(function()
        while freezeEnabled do
            task.wait(0.5)
            if not freezeEnabled then break end
            pcall(function()
                local ch = Player.Character; if not ch then return end
                local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                local origin = hrp.Position
                local radius = freezeRadius

                -- Filtra mobs mortos ou fora do raio da lista de congelados
                local stillFrozen = {}
                local newFrozenSet = {}
                for _, entry in ipairs(frozenMobs) do
                    pcall(function()
                        if not entry.model or not entry.model.Parent then
                            unfreezeMob(entry); return
                        end
                        if not entry.hum or not entry.hum.Parent or entry.hum.Health <= 0 then
                            unfreezeMob(entry); return
                        end
                        if not entry.hrp or not entry.hrp.Parent then
                            unfreezeMob(entry); return
                        end
                        local d = (entry.hrp.Position - origin).Magnitude
                        if d > radius + 8 then
                            unfreezeMob(entry); return
                        end
                        -- Ainda no raio e vivo: mantém congelado
                        -- Garante WalkSpeed=0 (o servidor pode restaurar)
                        pcall(function() entry.hum.WalkSpeed = 0 end)
                        pcall(function() entry.hum.JumpPower  = 0 end)
                        table.insert(stillFrozen, entry)
                        newFrozenSet[entry.model] = true
                    end)
                end
                frozenMobs = stillFrozen
                frozenSet  = newFrozenSet

                -- Congela novos mobs no raio (usa getMobsInRange que já existe)
                local candidates = getMobsInRange(origin, radius)
                for _, entry in ipairs(candidates) do
                    if not frozenSet[entry.model] then
                        freezeMob(entry)
                        table.insert(frozenMobs, entry)
                        frozenSet[entry.model] = true
                    end
                end
            end)
        end
    end)
end

stopFreezeAura = function()
    if freezeConn   then freezeConn:Disconnect();   freezeConn   = nil end
    if freezeScanCo then task.cancel(freezeScanCo); freezeScanCo = nil end
    destroyFreezeCircle()
    unfreezeAll()
end

-- ══════════════════════════════════════════════════════════════
-- KILL AURA v5 — 99 Nights in the Forest
-- ══════════════════════════════════════════════════════════════
--
-- ANÁLISE DO PROBLEMA DOS MÉTODOS ANTERIORES:
--
--  v1-v3: firetouchinterest → O 99 Nights NÃO usa Touched para dano.
--         Usa overlap/raycast server-side. FTI não chega ao servidor.
--
--  v4: tool:Activate() em loop → O jogo ignora Activate sem animação.
--
-- SOLUÇÃO v5 — TELEPORTE + SWING REAL:
--   1. Salva posição original do jogador
--   2. Para cada mob no range:
--      a. Teleporta HRP do jogador para JUNTO do mob (1.5 studs de distância)
--      b. Orienta o personagem para o mob
--      c. Ativa a tool (Activate) — agora o personagem ESTÁ ao lado do mob
--      d. Aguarda 0.08s (tempo do hitbox da swing)
--   3. Volta para posição original
--
--   Por que funciona: o servidor valida se o jogador está próximo do alvo.
--   Com o teleporte, essa validação passa 100% das vezes.
--
--   BONUS: tenta também firetouchinterest + fireremote como camadas extras.
-- ══════════════════════════════════════════════════════════════
local kaEnabled  = false
local kaRange    = 30
local kaAutoLoop = nil
local kaCharConn = nil

-- ── Nomes de armas que causam dano a mobs ─────────────────────
local KA_WEAPON_NAMES = {
    -- Lanças
    "Spear","Old Spear","Good Spear","Strong Spear","Poison Spear","PoisonSpear","Trident",
    -- Espadas
    "Sword","Ice Sword","IceSword","Katana","Morningstar","Cultist King Mace","CultistKingMace","Dagger","Knife",
    -- Arcos / Rifles
    "Crossbow","Bow","Revolver","Rifle",
    -- Machados (também servem pra mobs)
    "Axe","Old Axe","OldAxe","Good Axe","GoodAxe","Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw",
    -- Outros
    "Pickaxe","Hammer",
}

-- ── Pega a melhor arma disponível (Inventory custom > equipada > backpack) ─
local function getWeapon()
    local ch = Player.Character
    -- 1. Inventory customizado do jogo (onde o SimpleSpy mostrou a real fonte da Tool)
    local inv = Player:FindFirstChild("Inventory")
    if inv then
        for _, name in ipairs(KA_WEAPON_NAMES) do
            local t = inv:FindFirstChild(name)
            if t then return t, false end
        end
        local t = inv:FindFirstChildWhichIsA("Tool")
        if t then return t, false end
    end
    -- 2. Já tem ferramenta equipada? Usa ela
    if ch then
        local t = ch:FindFirstChildWhichIsA("Tool")
        if t then return t, false end
    end
    -- 3. Backpack padrão do Roblox (fallback)
    local bp = Player.Backpack
    if bp then
        for _, name in ipairs(KA_WEAPON_NAMES) do
            local t = bp:FindFirstChild(name)
            if t then return t, true end
        end
        local t = bp:FindFirstChildWhichIsA("Tool")
        if t then return t, true end
    end
    return nil, false
end

-- ══════════════════════════════════════════════════════════════
--  SESSÃO DO ToolDamageObject — capturada via hook __namecall
--
--  Descoberto via SimpleSpy: ToolDamageObject:InvokeServer(alvo, tool,
--  "CONTADOR_IDSESSAO", cframeDoJogador, false)
--
--  O IDSESSAO é fixo durante toda a sessão (mesmo número em hits
--  diferentes). O CONTADOR sobe a cada golpe real, não depende do alvo.
--  Capturamos o IDSESSAO automaticamente no primeiro InvokeServer real
--  que o próprio jogo disparar (seu ataque manual), sem precisar chutar.
-- ══════════════════════════════════════════════════════════════
local KA_sessionId   = nil
local KA_hitCounter  = 0
local KA_hookMt, KA_origNamecall, KA_hookInstalled = nil, nil, false

local function installKaSessionHook()
    if KA_hookInstalled then return end
    pcall(function()
        if not getrawmetatable or not setreadonly or not newcclosure then return end
        KA_hookInstalled = true
        KA_hookMt = getrawmetatable(game)
        setreadonly(KA_hookMt, false)
        KA_origNamecall = KA_hookMt.__namecall
        KA_hookMt.__namecall = newcclosure(function(self, ...)
            local ok, method = pcall(function() return getnamecallmethod and getnamecallmethod() or "" end)
            if ok and method == "InvokeServer" and self and self.Name == "ToolDamageObject" then
                local a = {...}
                local tok = a[3]
                if type(tok) == "string" then
                    local sid = tok:match("_(%d+)$")
                    local cnt = tonumber(tok:match("^(%d+)_"))
                    if sid then KA_sessionId = sid end
                    if cnt and cnt > KA_hitCounter then KA_hitCounter = cnt end
                end
            end
            return KA_origNamecall(self, ...)
        end)
        setreadonly(KA_hookMt, true)
    end)
end

-- ── Ataca um mob via ToolDamageObject:InvokeServer (remote real) ──
local function attackMob(mob)
    local ch = Player.Character; if not ch then return end
    local myHRP = ch:FindFirstChild("HumanoidRootPart"); if not myHRP then return end
    local mobHRP = getMobRoot(mob); if not mobHRP then return end

    local tool, fromBackpack = getWeapon()
    if not tool then return end

    -- Equipa se necessário (o remote real espera a Tool "ativa")
    if fromBackpack then
        pcall(function() tool.Parent = ch end)
        task.wait(0.05)
    end

    installKaSessionHook()

    -- Sem ID de sessão capturado ainda? Dá um golpe manual simulado
    -- (mouse1press/release) só pra "nascer" o hook, e tenta de novo no próximo tick.
    if not KA_sessionId then
        pcall(function()
            if mouse1press then mouse1press(); task.wait(0.05); mouse1release() end
        end)
        if fromBackpack and tool and tool.Parent == ch then
            pcall(function() tool.Parent = Player.Backpack end)
        end
        return
    end

    KA_hitCounter = KA_hitCounter + 1
    local tok = tostring(KA_hitCounter).."_"..KA_sessionId

    local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
    local tdo = remotes and remotes:FindFirstChild("ToolDamageObject")
    if tdo then
        pcall(function()
            tdo:InvokeServer(mob, tool, tok, myHRP.CFrame, false)
        end)
    end

    -- Devolve ferramenta pro backpack
    if fromBackpack and tool and tool.Parent == ch then
        task.wait(0.05)
        pcall(function() tool.Parent = Player.Backpack end)
    end
end

local function startKillAura()
    if kaAutoLoop then pcall(function() kaAutoLoop:Disconnect() end) end

    local lastAttack = 0
    kaAutoLoop = RunService.Heartbeat:Connect(function()
        if not kaEnabled then return end
        local now = tick()
        if now - lastAttack < 0.2 then return end

        local ch = Player.Character; if not ch then return end
        local hum = ch:FindFirstChildWhichIsA("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end

        -- Pega mobs no range e ataca o mais próximo
        local mobs = getMobsInRange(hrp.Position, kaRange)
        if #mobs == 0 then return end

        lastAttack = now
        -- Ataca todos no range (firetouchinterest é rápido)
        for _, m in ipairs(mobs) do
            task.spawn(function()
                pcall(function() attackMob(m.model) end)
            end)
        end
    end)

    if kaCharConn then pcall(function() kaCharConn:Disconnect() end) end
    kaCharConn = Player.CharacterAdded:Connect(function()
        task.wait(0.5)
    end)
end

local function stopKillAura()
    if kaAutoLoop then pcall(function() kaAutoLoop:Disconnect() end); kaAutoLoop = nil end
    if kaCharConn then pcall(function() kaCharConn:Disconnect() end); kaCharConn = nil end
end

-- ══════════════════════════════════════════════════════════════
--  🪓 TREE AURA — Corta árvores automaticamente sem equipar nada
-- ══════════════════════════════════════════════════════════════
local taEnabled  = false
local taRange    = 20
local taLoop     = nil

-- Nomes de machados do jogo (únicos que cortam árvores)
local AXE_NAMES = {
    "Old Axe","OldAxe","Good Axe","GoodAxe","Ice Axe","IceAxe",
    "Strong Axe","StrongAxe","Chainsaw",
    "Axe", -- genérico
}

-- Nomes de árvores/plantas cortáveis do 99 Nights
local TREE_NAMES_SET = {
    ["tree"]=true,["pinetree"]=true,["pine tree"]=true,
    ["birchtree"]=true,["birch tree"]=true,
    ["birch"]=true,["pine"]=true,
    ["deadtree"]=true,["dead tree"]=true,
    ["jungletree"]=true,["jungle tree"]=true,
    ["palmtree"]=true,["palm tree"]=true,
    ["catuaba"]=true,["oak"]=true,["oaktree"]=true,
    ["log"]=true, -- tronco já caído
}

local function isTree(obj)
    if not obj or not obj:IsA("Model") then return false end
    local nm = obj.Name:lower()
    -- verifica set exato
    if TREE_NAMES_SET[nm] then return true end
    -- verifica se contém "tree" ou "wood" no nome
    if nm:find("tree") or nm:find("wood") or nm:find("stump") then return true end
    return false
end

local function getAxe()
    local ch = Player.Character
    -- 1. Inventory customizado do jogo
    local inv = Player:FindFirstChild("Inventory")
    if inv then
        for _, name in ipairs(AXE_NAMES) do
            local t = inv:FindFirstChild(name)
            if t then return t, false end
        end
    end
    -- 2. Machado já equipado
    if ch then
        local t = ch:FindFirstChildWhichIsA("Tool")
        if t and (t.Name:lower():find("axe") or t.Name:lower() == "chainsaw") then
            return t, false
        end
    end
    -- 3. Machado no backpack padrão
    local bp = Player.Backpack
    if bp then
        for _, name in ipairs(AXE_NAMES) do
            local t = bp:FindFirstChild(name)
            if t then return t, true end
        end
    end
    return nil, false
end

-- ── Corta uma árvore via ToolDamageObject:InvokeServer (remote real) ──
-- treeModel = o Model da árvore (não a part do tronco — visto no SimpleSpy)
local function chopTree(treeModel, treePart)
    local ch = Player.Character; if not ch then return end
    local myHRP = ch:FindFirstChild("HumanoidRootPart"); if not myHRP then return end

    local axe, fromBackpack = getAxe()
    if not axe then return end

    if fromBackpack then
        pcall(function() axe.Parent = ch end)
        task.wait(0.06)
    end

    installKaSessionHook()

    if not KA_sessionId then
        pcall(function()
            if mouse1press then mouse1press(); task.wait(0.05); mouse1release() end
        end)
        if fromBackpack and axe and axe.Parent == ch then
            pcall(function() axe.Parent = Player.Backpack end)
        end
        return
    end

    KA_hitCounter = KA_hitCounter + 1
    local tok = tostring(KA_hitCounter).."_"..KA_sessionId

    local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents")
    local tdo = remotes and remotes:FindFirstChild("ToolDamageObject")
    if tdo then
        pcall(function()
            tdo:InvokeServer(treeModel, axe, tok, myHRP.CFrame, false)
        end)
    end

    if fromBackpack and axe and axe.Parent == ch then
        task.wait(0.05)
        pcall(function() axe.Parent = Player.Backpack end)
    end
end

local function startTreeAura()
    if taLoop then pcall(function() taLoop:Disconnect() end) end

    local lastChop = 0
    taLoop = RunService.Heartbeat:Connect(function()
        if not taEnabled then return end
        local now = tick()
        if now - lastChop < 0.25 then return end

        local ch = Player.Character; if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hrpPos = hrp.Position

        -- Encontra árvores no range
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if not isTree(obj) then return end
                local root = obj:FindFirstChild("Trunk") or obj:FindFirstChild("Log")
                    or obj:FindFirstChild("Wood") or obj.PrimaryPart
                    or obj:FindFirstChildWhichIsA("BasePart")
                if not root then return end
                local dist = (root.Position - hrpPos).Magnitude
                if dist > taRange then return end

                lastChop = now
                task.spawn(function()
                    pcall(function() chopTree(obj, root) end)
                end)
            end)
        end
    end)
end

local function stopTreeAura()
    if taLoop then pcall(function() taLoop:Disconnect() end); taLoop = nil end
end


-- ── UI Kill Aura — Farm Tab (card único: toggle esquerda + mini slider direita) ──
local KA_COR = Color3.fromRGB(255, 80, 80)

-- ── KILL AURA UI — Voidware style ─────────────────────────────

-- Seção header

-- [helpers movidos para fora do pcall]

local function _nfd(c2,y)
    local d2=Instance.new("Frame",c2); d2.BackgroundColor3=_ND_F
    d2.BackgroundTransparency=0.58; d2.BorderSizePixel=0
    d2.Position=UDim2.new(0,12,0,y); d2.Size=UDim2.new(1,-24,0,1); d2.ZIndex=6
    return 1
end

local function _nft(c2,y,lbl,initOn,onToggle)
    local H=44
    local tl=Instance.new("TextLabel",c2); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,y); tl.Size=UDim2.new(0.65,0,0,H)
    tl.Font=Enum.Font.GothamBold; tl.Text=lbl
    tl.TextColor3=_NT_F; tl.TextSize=11
    tl.TextXAlignment=Enum.TextXAlignment.Left
    tl.TextYAlignment=Enum.TextYAlignment.Center
    tl.TextWrapped=true; tl.ZIndex=6
    local pill=Instance.new("Frame",c2); pill.BorderSizePixel=0
    pill.AnchorPoint=Vector2.new(1,0.5)
    pill.Position=UDim2.new(1,-12,0,y+H/2)
    pill.Size=UDim2.new(0,44,0,22); pill.ZIndex=8
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    pill.BackgroundColor3=initOn and _ON_F or Color3.fromRGB(100,80,120)
    local knob=Instance.new("Frame",pill); knob.BorderSizePixel=0
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.ZIndex=10; knob.Size=UDim2.new(0,16,0,16)
    knob.Position=initOn and UDim2.new(1,-11,0.5,0) or UDim2.new(0,11,0.5,0)
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local en=initOn
    local btn=Instance.new("TextButton",c2); btn.BackgroundTransparency=1
    btn.Position=UDim2.new(0,0,0,y); btn.Size=UDim2.new(1,0,0,H)
    btn.Text=""; btn.ZIndex=11
    btn.MouseButton1Click:Connect(function()
        en=not en
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=en and _ON_F or Color3.fromRGB(100,80,120)}):Play()
    TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position=en and UDim2.new(1,-11,0.5,0) or UDim2.new(0,11,0.5,0)
    }):Play()
        if onToggle then onToggle(en) end
    end)
    return H
end

local function _nfs(c2,y,lbl,minV,maxV,defV,cor,onChange)
    local H=50
    local tl=Instance.new("TextLabel",c2); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,y); tl.Size=UDim2.new(0.44,0,0,H)
    tl.Font=Enum.Font.GothamBold; tl.Text=lbl
    tl.TextColor3=_NT_F; tl.TextSize=10
    tl.TextXAlignment=Enum.TextXAlignment.Left
    tl.TextYAlignment=Enum.TextYAlignment.Center
    tl.TextWrapped=true; tl.ZIndex=6
    local vl=Instance.new("TextLabel",c2); vl.BackgroundTransparency=1
    vl.Position=UDim2.new(0.46,0,0,y+(H-16)/2); vl.Size=UDim2.new(0,28,0,16)
    vl.Font=Enum.Font.GothamBold; vl.Text=tostring(defV)
    vl.TextColor3=_NT_F; vl.TextSize=11
    vl.TextXAlignment=Enum.TextXAlignment.Left; vl.ZIndex=7
    local p0=math.clamp((defV-minV)/(maxV-minV),0,1)
    local tr=Instance.new("Frame",c2); tr.BackgroundColor3=Color3.fromRGB(20,36,80)
    tr.BorderSizePixel=0
    tr.Position=UDim2.new(0.46,32,0,y+H/2-2)
    tr.Size=UDim2.new(0.51,-46,0,4); tr.ZIndex=7
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
    local fi=Instance.new("Frame",tr); fi.BackgroundColor3=cor
    fi.BorderSizePixel=0; fi.Size=UDim2.new(p0,0,1,0); fi.ZIndex=8
    Instance.new("UICorner",fi).CornerRadius=UDim.new(1,0)
    local kn=Instance.new("Frame",tr); kn.BackgroundColor3=Color3.fromRGB(25,48,105)
    kn.BorderSizePixel=0; kn.AnchorPoint=Vector2.new(0.5,0.5)
    kn.Position=UDim2.new(p0,0,0.5,0); kn.Size=UDim2.new(0,16,0,16); kn.ZIndex=9
    Instance.new("UICorner",kn).CornerRadius=UDim.new(1,0)
    local ks=Instance.new("UIStroke",kn); ks.Color=cor; ks.Thickness=1.5
    ks.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local dr=false
    local function sv(pct)
        pct=math.clamp(pct,0,1)
        local v=math.round(minV+(maxV-minV)*pct)
        vl.Text=tostring(v); fi.Size=UDim2.new(pct,0,1,0); kn.Position=UDim2.new(pct,0,0.5,0)
        if onChange then onChange(v) end
    end
    local sb=Instance.new("TextButton",tr); sb.BackgroundTransparency=1
    sb.Size=UDim2.new(1,24,1,24); sb.Position=UDim2.new(0,-12,0,-12); sb.Text=""; sb.ZIndex=10
    sb.MouseButton1Down:Connect(function()
        dr=true
        local ap=tr.AbsolutePosition; local as=tr.AbsoluteSize
        sv((UserInputService:GetMouseLocation().X-ap.X)/as.X)
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dr then return end
        if inp.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local ap=tr.AbsolutePosition; local as=tr.AbsoluteSize
        sv((inp.Position.X-ap.X)/as.X)
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end
    end)
    return H
end

-- Botão de ação navy dentro de card
local function _nfb(c2,y,lbl,cor,onClick)
    local H=44
    local tl=Instance.new("TextLabel",c2); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,y); tl.Size=UDim2.new(0.55,0,0,H)
    tl.Font=Enum.Font.GothamBold; tl.Text=lbl
    tl.TextColor3=_NT_F; tl.TextSize=11
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.TextYAlignment=Enum.TextYAlignment.Center; tl.ZIndex=6
    local btn=Instance.new("TextButton",c2)
    btn.BackgroundColor3=cor or _ON_F; btn.BackgroundTransparency=0.15; btn.BorderSizePixel=0
    btn.AnchorPoint=Vector2.new(1,0); btn.Position=UDim2.new(1,-10,0,y+6)
    btn.Size=UDim2.new(0,100,0,32); btn.Font=Enum.Font.GothamBlack
    btn.Text="▶ Ativar"; btn.TextColor3=Color3.fromRGB(220,235,255); btn.TextSize=10; btn.ZIndex=8
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    if onClick then btn.MouseButton1Click:Connect(onClick) end
    return H, btn
end

-- Seção header navy para Farm
local function _nfSec(title, cor)
    local sec=Instance.new("Frame",Pages["Farm"])
    sec.BackgroundColor3=Color3.fromRGB(18,30,60); sec.BackgroundTransparency=0.65; sec.BorderSizePixel=0
    sec.Size=UDim2.new(1,0,0,26); sec.LayoutOrder=fNextLO(); sec.ZIndex=4
    Instance.new("UICorner",sec).CornerRadius=UDim.new(0,9)
    local pill=Instance.new("Frame",sec); pill.BackgroundColor3=cor or _ON_F; pill.BorderSizePixel=0
    pill.Size=UDim2.new(0,4,0.7,0); pill.Position=UDim2.new(0,8,0.15,0); pill.ZIndex=5
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",sec); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,18,0,0); lbl.Size=UDim2.new(1,-22,1,0)
    lbl.Font=Enum.Font.GothamBlack; lbl.Text=title
    lbl.TextColor3=Color3.fromRGB(180,210,255); lbl.TextSize=10
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
end

-- ── Kill Aura — Accordion Card ───────────────────────────────
do
local _kac, _kacCF, _kacDrop = makeAccordionCard(Pages["Farm"], fNextLO, {
    icon="⚔️", title=T("kaTitle"),
    summary="Ataca automaticamente os animais mais próximos no raio configurado.",
    color=KA_COR, contentH=36+9+44+9+50+14,
})
local _y=36+8
_accDivLine(_kacCF,_y,KA_COR); _y=_y+9
local _, kaPill2, kaKnob2 = _accToggle(_kacCF, _y, T("kaTitle"), false, KA_COR, function(s)
    kaEnabled=s
    if s then startKillAura(); Notify.send({type="custom",icon="⚔️",accent=KA_COR,title="Kill Aura",msg="✓ Ativado — "..kaRange.." studs",duration=5})
    else stopKillAura(); Notify.error("Kill Aura","✗ Desativado") end
end)
kaPill=kaPill2; kaKnob=kaKnob2; _y=_y+44
_accDivLine(_kacCF,_y,KA_COR); _y=_y+9
_y=_y+_nfs(_kacCF,_y,"Alcance",1,125,kaRange,KA_COR,function(v) kaRange=v end)
_accStatusLbl(_kacCF,_y)
end -- Kill Aura accordion

-- ── Tree Aura — Accordion Card ───────────────────────────────
local TA_COR = Color3.fromRGB(100, 200, 80)
do
local _tac, _tacCF, _tacDrop = makeAccordionCard(Pages["Farm"], fNextLO, {
    icon="🪓", title="Tree Aura",
    summary="Corta árvores próximas automaticamente. Usa o machado do Backpack.",
    color=TA_COR, contentH=36+9+44+9+50+14,
})
local _y=36+8
_accDivLine(_tacCF,_y,TA_COR); _y=_y+9
_accToggle(_tacCF, _y, "🪓 Tree Aura (sem equipar)", false, TA_COR, function(s)
    taEnabled=s
    if s then
        -- Verifica se tem machado
        local axe = getAxe()
        if not axe then
            Notify.send({type="warn",icon="⚠️",accent=TA_COR,
                title="Tree Aura",msg="Nenhum machado no Backpack!",duration=4})
            taEnabled=false; return
        end
        startTreeAura()
        Notify.send({type="custom",icon="🪓",accent=TA_COR,
            title="Tree Aura",msg="✓ Ativado — "..taRange.." studs",duration=5})
    else
        stopTreeAura()
        Notify.error("Tree Aura","✗ Desativado")
    end
end)
_y=_y+44
_accDivLine(_tacCF,_y,TA_COR); _y=_y+9
_y=_y+_nfs(_tacCF,_y,"Alcance",5,80,taRange,TA_COR,function(v) taRange=v end)
_accStatusLbl(_tacCF,_y)
end -- Tree Aura accordion

end); if not _dbgOk_14823 then warn('[PudimHub DEBUG] Erro na secao FARM1: '..tostring(_dbgErr_14823)) end
local _dbgOk_15817, _dbgErr_15817 = pcall(function() -- [[ FARM2 ]]

-- ══════════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════
-- AUTO EXPLORAR — Voo em espiral com raio DINÂMICO
-- ══════════════════════════════════════════════════════════════
-- FONTE DO RAIO (em ordem de prioridade):
--   1. Lighting.FogEnd × 0.85
--      → O servidor ajusta FogEnd quando a fogueira sobe de nível.
--        É a fonte mais precisa e se atualiza automaticamente.
--   2. Atributo no Model da fogueira (Level, FireLevel, CampfireLevel, Tier)
--        → Se existir, converte para studs via tabela de referência.
--   3. Tabela de fallback por nível estimado (dados da wiki):
--        Nível 1→90  2→160  3→230  4→300  5→360  6→430
--   Quando a fogueira sobe durante a exploração: o raio se expande
--   automaticamente e uma notificação avisa o jogador.
-- ══════════════════════════════════════════════════════════════
local AE_COR         = Color3.fromRGB(120, 220, 255)
local aeEnabled      = false
local aeConn         = nil
local aeFogConn      = nil   -- monitora FogEnd em tempo real
local aeBodyVel      = nil
local aeBodyGyro     = nil
local aeStartTime    = 0
local aeCurAngle     = 0
local aeCurRadius    = 0
local aeHeight       = 0
local aeDynMaxRadius = 90    -- raio alvo dinâmico (atualizado pelo sistema)
local aePrevFogEnd   = 0     -- valor anterior para detectar mudança
local aeCampLevel    = 0     -- nível da fogueira detectado

local AE_MIN_RADIUS  = 25    -- raio inicial fixo
local AE_SPEED       = 80    -- velocidade de voo (studs/s)
local AE_HEIGHT_OFF  = 35    -- altura acima da fogueira
local AE_STEP        = 0.7   -- crescimento do raio por frame
local AE_FOG_FACTOR  = 0.85  -- percentagem do FogEnd a cobrir

-- Tabela de referência nível → raio estimado (studs)
-- Baseada em: wiki confirma 6 níveis, nível 6 = mapa inteiro (~430 studs)
local AE_LEVEL_RADIUS = {
    [1] = 90,
    [2] = 160,
    [3] = 230,
    [4] = 300,
    [5] = 360,
    [6] = 430,
}

-- Referências de UI
local aeCard, aeStroke, aePill, aeKnob, aeLabelState
local aeProgressFill, aeTimerLabel, aeRadiusLbl, aeLevelLbl

-- Noclip (módulo-level para poder ser chamado de stopAutoExplore)
local aeNoclipConn = nil
local function aeStopNoclip()
    if aeNoclipConn then aeNoclipConn:Disconnect(); aeNoclipConn = nil end
    pcall(function()
        local ch = Player.Character; if not ch then return end
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end)
end
local function aeStartNoclip()
    if aeNoclipConn then aeNoclipConn:Disconnect() end
    aeNoclipConn = RunService.Stepped:Connect(function()
        pcall(function()
            local ch = Player.Character; if not ch then return end
            for _, p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end)
    end)
end

-- ── DETECÇÃO DO RAIO ──────────────────────────────────────────
local function aeReadCampfireLevel()
    local level = 0
    pcall(function()
        -- 1. Busca por nome no workspace (recursiva)
        local camp = workspace:FindFirstChild("Campfire",true)
                  or workspace:FindFirstChild("MainCampfire",true)
                  or workspace:FindFirstChild("Campground",true)
                  or workspace:FindFirstChild("Camp",true)
                  or workspace:FindFirstChild("Fogueira",true)
                  or workspace:FindFirstChild("MainFire",true)
        -- 2. Busca ampla nos filhos diretos do workspace
        if not camp then
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") or obj:IsA("Folder") then
                    local n = obj.Name:lower()
                    if n:find("campfire") or n:find("fogueira") or n:find("camp")
                    or n:find("mainfire") or n:find("basecamp") then
                        camp = obj; break
                    end
                end
            end
        end
        if not camp then return end
        -- Tenta atributos
        local attrs = {"Level","FireLevel","CampfireLevel","Tier","campLevel",
                        "fire_level","Level_Number","CurrentLevel","CampLevel","FireTier"}
        for _, attr in ipairs(attrs) do
            local v = camp:GetAttribute(attr)
            if type(v) == "number" and v >= 1 and v <= 10 then
                level = math.floor(v)
                break
            end
        end
        -- Tenta IntValues/NumberValues dentro do model
        if level == 0 then
            local names = {"Level","FireLevel","CampfireLevel","Tier","CurrentLevel"}
            for _, n in ipairs(names) do
                local iv = camp:FindFirstChild(n)
                if iv and (iv:IsA("IntValue") or iv:IsA("NumberValue")) and iv.Value >= 1 then
                    level = math.floor(iv.Value)
                    break
                end
            end
        end
    end)
    return level
end

-- Nível manual escolhido pelo jogador (0 = automático)
local aeManualLevel = 0

local function aeComputeMaxRadius()
    local fogEnd = 0
    pcall(function() fogEnd = game:GetService("Lighting").FogEnd or 0 end)

    -- FONTE 0: nível escolhido manualmente pelo jogador (sempre prevalece)
    if aeManualLevel >= 1 then
        local radius = AE_LEVEL_RADIUS[math.clamp(aeManualLevel, 1, 6)]
        return radius, fogEnd, "Manual·Nv"..aeManualLevel
    end

    -- FONTE 1: atributo do model da fogueira
    local lvl = aeReadCampfireLevel()
    if lvl >= 1 then
        local radius = AE_LEVEL_RADIUS[math.clamp(lvl, 1, 6)]
        return radius, fogEnd, "Fogueira·Nv"..lvl
    end

    -- FONTE 2: FogEnd com faixas calibradas para 99 Nights in the Forest
    -- (valores medidos no jogo real — cada nível tem FogEnd fixo)
    if fogEnd > 0 and fogEnd < 9e8 then
        local lvlPorFog
        if    fogEnd < 130  then lvlPorFog = 1
        elseif fogEnd < 210 then lvlPorFog = 2
        elseif fogEnd < 295 then lvlPorFog = 3
        elseif fogEnd < 380 then lvlPorFog = 4
        elseif fogEnd < 460 then lvlPorFog = 5
        else                     lvlPorFog = 6 end
        local radius = AE_LEVEL_RADIUS[lvlPorFog]
        return radius, fogEnd, string.format("FogEnd%.0f→Nv%d", fogEnd, lvlPorFog)
    end

    -- FONTE 3: fallback nível 1
    return AE_LEVEL_RADIUS[1], fogEnd, "Fallback"
end

local function aeRefreshLevel()
    local radius, fogEnd, source = aeComputeMaxRadius()
    aeDynMaxRadius = radius
    aePrevFogEnd   = fogEnd

    -- Estima o nível pela tabela de referência
    local bestLvl = 1
    for lvl = 6, 1, -1 do
        if radius >= AE_LEVEL_RADIUS[lvl] then
            bestLvl = lvl
            break
        end
    end
    aeCampLevel = bestLvl

    -- Atualiza label na UI
    pcall(function()
        if aeLevelLbl then
            aeLevelLbl.Text = string.format(
                "🔥 Fogueira Nível %d  •  Raio: ~%d studs  [%s]",
                bestLvl, radius, source)
        end
        if aeRadiusLbl then
            aeRadiusLbl.Text = string.format(
                "FogEnd: %.0f  •  Vel: %d st/s  •  Alt: +%d  •  Fator: %.0f%%",
                fogEnd, AE_SPEED, AE_HEIGHT_OFF, AE_FOG_FACTOR*100)
        end
    end)
    return radius, bestLvl
end

-- ── UTILITÁRIOS ───────────────────────────────────────────────
local function aeGetCampfire()
    local pos = getCampfirePos()
    return pos or Vector3.new(0, 5, 0)
end

local function aeCleanPhysics()
    pcall(function() if aeBodyVel  and aeBodyVel.Parent  then aeBodyVel:Destroy()  end end)
    pcall(function() if aeBodyGyro and aeBodyGyro.Parent then aeBodyGyro:Destroy() end end)
    aeBodyVel  = nil
    aeBodyGyro = nil
end

local function aeFormatTime(secs)
    local m = math.floor(secs/60)
    local s = secs%60
    return string.format("%d min %02d s", m, s)
end

local function aeUpdateUI(pct)
    pcall(function()
        if aeProgressFill then
            TweenService:Create(aeProgressFill, TweenInfo.new(0.3), {
                Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0)
            }):Play()
        end
    end)
end

-- ── STOP ─────────────────────────────────────────────────────
local function stopAutoExplore(tpBack)
    aeEnabled = false
    if aeConn    then pcall(function() aeConn:Disconnect()    end); aeConn    = nil end
    if aeFogConn then pcall(function() aeFogConn:Disconnect() end); aeFogConn = nil end
    aeCleanPhysics()
    pcall(function() aeStopNoclip() end)

    pcall(function()
        local ch = Player.Character; if not ch then return end
        local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end)

    if tpBack then
        task.wait(0.1)
        pcall(function()
            local ch = Player.Character; if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local pos = aeGetCampfire()
            hrp.CFrame = CFrame.new(pos.X, pos.Y + 4, pos.Z)
        end)
    end

    pcall(function()
        if aePill   then TweenService:Create(aePill,  TweenInfo.new(0.22), {BackgroundColor3=Color3.fromRGB(64,42,100)}):Play() end
        if aeKnob   then TweenService:Create(aeKnob,  TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                            {Position=UDim2.new(0,2,0.5,-11), BackgroundColor3=Color3.fromRGB(160,170,185)}):Play() end
        if aeStroke then TweenService:Create(aeStroke, TweenInfo.new(0.2), {Color=Color3.fromRGB(80,55,20)}):Play() end
        if aeLabelState  then aeLabelState.Text  = "AGUARDANDO"; aeLabelState.TextColor3 = Color3.fromRGB(100,120,160) end
        if aeProgressFill then aeProgressFill.Size = UDim2.new(0,0,1,0) end
        if aeTimerLabel  then aeTimerLabel.Text  = "0:00  0%" end
    end)
end

-- ── START ─────────────────────────────────────────────────────
-- Sistema inteligente de descoberta de névoa:
--   1. Detecta o nível da fogueira → calcula raio máximo de névoa
--   2. Divide o mapa em células de 50x50 studs
--   3. Categoriza cada célula: DENTRO_NÉVOA, BORDA_NÉVOA, JÁ_DESCOBERTA
--   4. Visita APENAS células que estão na borda da névoa (zona entre descoberto e não descoberto)
--   5. Quando a fogueira sobe de nível → novas células de borda são adicionadas
--   6. Ignora células já descobertas (adjacentes à névoa mas já visitadas)
local function startAutoExplore()
    local ch = Player.Character; if not ch then return end
    local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end

    local maxRadius, campLvl = aeRefreshLevel()
    local campPos  = aeGetCampfire()
    aeHeight       = campPos.Y + AE_HEIGHT_OFF
    aeStartTime    = tick()

    -- ── Configurações do grid de descoberta ──
    local CELL      = 50   -- tamanho da célula (studs) — cobre um chunk
    local OVERSHOOT = 1.10 -- vai 10% além do raio para ter certeza de revelar
    local UNDERSHOOT = 0.50 -- ignora o centro já revelado (dentro de 50% do raio)

    -- ── Tabela de células já visitadas (chave = "x,z") ────────────
    local visitadasSet = {}  -- células que já voamos por cima

    -- ── Gera todas as células de "borda de névoa" ──────────────────
    -- Uma célula é de "borda" se:
    --   • Está a uma distância entre UNDERSHOOT e OVERSHOOT do raio da fogueira
    --   • NÃO foi visitada ainda
    local function gerarCelulasBorda(raio)
        local cells = {}
        local outer = raio * OVERSHOOT
        local inner = raio * UNDERSHOOT
        local x = -outer
        while x <= outer do
            local z = -outer
            while z <= outer do
                local dist = math.sqrt(x*x + z*z)
                if dist >= inner and dist <= outer then
                    local cx = math.floor((campPos.X + x) / CELL + 0.5) * CELL
                    local cz = math.floor((campPos.Z + z) / CELL + 0.5) * CELL
                    local key = cx..","..cz
                    if not visitadasSet[key] then
                        visitadasSet[key] = false  -- pendente
                        table.insert(cells, Vector3.new(cx, aeHeight, cz))
                    end
                end
                z = z + CELL
            end
            x = x + CELL
        end
        return cells
    end

    -- ── Ordena por "varredura em espiral" partindo da posição atual ─
    -- Isso garante que descobre a névoa progressivamente, sem zig-zag
    local function ordenarEspiral(cells, posAtual)
        -- Agrupa por anel (distância do campfire)
        -- E dentro de cada anel, ordena por proximidade ao jogador
        table.sort(cells, function(a, b)
            local da = math.sqrt((a.X-campPos.X)^2+(a.Z-campPos.Z)^2)
            local db = math.sqrt((b.X-campPos.X)^2+(b.Z-campPos.Z)^2)
            if math.abs(da - db) > CELL * 0.5 then
                return da < db  -- anel mais interno primeiro
            end
            -- Mesmo anel: mais próximo do jogador primeiro
            local dpa = (a - posAtual).Magnitude
            local dpb = (b - posAtual).Magnitude
            return dpa < dpb
        end)
        return cells
    end

    local pendentes    = gerarCelulasBorda(maxRadius)
    pendentes          = ordenarEspiral(pendentes, hrp.Position)
    local totalPontos  = #pendentes
    local visitados    = 0
    local targetAtual  = nil
    local lastFogCheck = tick()

    -- ── Inicia noclip + voo por LinearVelocity ─────────────────────
    aeCleanPhysics()
    aeStartNoclip()

    -- Usa LinearVelocity (moderno, mais estável que BodyVelocity)
    -- Fallback para BodyVelocity se LinearVelocity não existir
    local useLinearVel = pcall(function()
        aeBodyVel = Instance.new("LinearVelocity", hrp)
        aeBodyVel.MaxForce = math.huge
        aeBodyVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        aeBodyVel.RelativeTo = Enum.ActuatorRelativeTo.World
        aeBodyVel.VectorVelocity = Vector3.new(0,0,0)
        aeBodyVel.Name = "AE_LinVel"
        local att = Instance.new("Attachment", hrp); att.Name = "AE_Att"
        aeBodyVel.Attachment0 = att
    end)
    if not useLinearVel then
        pcall(function() if aeBodyVel and aeBodyVel.Parent then aeBodyVel:Destroy() end end)
        aeBodyVel = Instance.new("BodyVelocity", hrp)
        aeBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        aeBodyVel.Velocity = Vector3.new(0,0,0)
        aeBodyVel.Name = "AE_BodyVel"
    end
    aeBodyGyro = Instance.new("BodyGyro", hrp)
    aeBodyGyro.MaxTorque = Vector3.new(0, 1e5, 0)
    aeBodyGyro.D = 80; aeBodyGyro.CFrame = hrp.CFrame
    aeBodyGyro.Name = "AE_BodyGyro"
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)

    pcall(function()
        if aeLabelState then aeLabelState.Text = "EXPLORANDO"; aeLabelState.TextColor3 = AE_COR end
    end)

    Notify.send({type="custom", icon="🗺️", accent=AE_COR,
        title="Auto Explorar INICIADO",
        msg=string.format("🔥 Nível %d  •  Raio: %d studs  •  %d células de névoa",
            campLvl, maxRadius, totalPontos),
        duration=5})

    -- ── Monitor FogEnd: fogueira subiu → adiciona nova borda ───────
    aeFogConn = game:GetService("Lighting"):GetPropertyChangedSignal("FogEnd"):Connect(function()
        if not aeEnabled then return end
        pcall(function()
            local newRadius, newLvl = aeRefreshLevel()
            if newRadius > aeDynMaxRadius + 15 then
                local oldRadius = aeDynMaxRadius
                aeDynMaxRadius  = newRadius
                -- Gera novos pontos da borda expandida (não visitados)
                local novas = gerarCelulasBorda(newRadius)
                local adicionados = 0
                for _, np in ipairs(novas) do
                    local distCamp = math.sqrt((np.X-campPos.X)^2+(np.Z-campPos.Z)^2)
                    -- Só adiciona se estiver na nova zona (além do raio antigo)
                    if distCamp > oldRadius * 0.85 then
                        table.insert(pendentes, np)
                        adicionados = adicionados + 1
                    end
                end
                totalPontos = totalPontos + adicionados
                Notify.send({type="custom", icon="🔥", accent=Color3.fromRGB(255,200,80),
                    title="🔥 Fogueira Nível "..newLvl.."!",
                    msg=string.format("Raio %d→%d studs  •  +%d células novas de névoa!",
                        oldRadius, newRadius, adicionados),
                    duration=5})
            end
        end)
    end)

    -- ── Loop principal (Heartbeat) ──────────────────────────────────
    aeConn = RunService.Heartbeat:Connect(function(dt)
        if not aeEnabled then return end
        pcall(function()
            local ch2  = Player.Character; if not ch2  then return end
            local hrp2 = ch2:FindFirstChild("HumanoidRootPart"); if not hrp2 then return end

            -- Re-checa nível a cada 10s
            if tick() - lastFogCheck > 10 then
                lastFogCheck = tick()
                aeRefreshLevel()
            end

            -- Concluído
            if #pendentes == 0 then
                local totalTime = math.floor(tick() - aeStartTime)
                aeEnabled = false
                task.defer(function()
                    stopAutoExplore(true)
                    aeUpdateUI(1)
                    Notify.send({type="custom", icon="✅", accent=Color3.fromRGB(87,242,135),
                        title="Auto Explorar — CONCLUÍDO!",
                        msg=string.format("Nível %d explorado em %s! %d células visitadas.",
                            aeCampLevel, aeFormatTime(totalTime), visitados),
                        duration=8})
                end)
                return
            end

            -- Próximo alvo
            if not targetAtual then
                if #pendentes > 0 then
                    targetAtual = table.remove(pendentes, 1)
                end
            end
            if not targetAtual then return end

            local dir  = targetAtual - hrp2.Position
            local dist = dir.Magnitude

            if dist > 5 then
                -- Move por CFrame (mais confiável com noclip ativo)
                local step   = math.min(AE_SPEED * dt, dist)
                local newPos = hrp2.Position + dir.Unit * step
                -- Mantém a altura de voo fixa (evita mergulhar no chão)
                newPos = Vector3.new(newPos.X, aeHeight, newPos.Z)
                hrp2.CFrame = CFrame.new(newPos, newPos + Vector3.new(dir.X, 0, dir.Z))
                -- Velocity para auxiliar a física
                local vel = dir.Unit * AE_SPEED
                pcall(function()
                    if aeBodyVel and aeBodyVel.Parent then
                        if aeBodyVel:IsA("LinearVelocity") then
                            aeBodyVel.VectorVelocity = vel
                        else
                            aeBodyVel.Velocity = vel
                        end
                    end
                end)
            else
                -- Chegou na célula → marca como visitada
                local key = math.floor(targetAtual.X/CELL+0.5)*CELL ..",".. math.floor(targetAtual.Z/CELL+0.5)*CELL
                visitadasSet[key] = true
                visitados   = visitados + 1
                targetAtual = nil
                pcall(function()
                    if aeBodyVel and aeBodyVel.Parent then
                        if aeBodyVel:IsA("LinearVelocity") then
                            aeBodyVel.VectorVelocity = Vector3.new(0,0,0)
                        else
                            aeBodyVel.Velocity = Vector3.new(0,0,0)
                        end
                    end
                end)
            end

            -- UI: progresso e timer
            local pct = math.clamp(visitados / math.max(totalPontos, 1), 0, 1)
            aeUpdateUI(pct)
            pcall(function()
                if aeTimerLabel then
                    local el = math.floor(tick()-aeStartTime)
                    local m,s = math.floor(el/60), el%60
                    aeTimerLabel.Text = string.format("%d:%02d  %.0f%%  •  %d / %d zonas",
                        m, s, pct*100, visitados, totalPontos)
                end
                if aeLevelLbl then
                    aeLevelLbl.Text = string.format(
                        "🔥 Nível %d  •  Raio: %d studs  •  Névoa restante: %d zonas",
                        aeCampLevel, aeDynMaxRadius, #pendentes)
                end
            end)
        end)
    end)
end

-- ══════════════════════════════════════════════════════════════
-- FARM CARDS — Accordion v6 (substitui toda UI abaixo)
-- A lógica das funções permanece igual acima
-- ══════════════════════════════════════════════════════════════

-- ── 1. AUTO EXPLORAR ─────────────────────────────────────────
_nfSec("🗺️  AUTO EXPLORAR", AE_COR)
do
local _aeCard, _aeCF, _aeDrop = makeAccordionCard(Pages["Farm"], fNextLO, {
    icon="🗺️", title="Auto Explorar",
    summary="Voa em espiral saindo da fogueira para explorar o mapa automaticamente.",
    color=AE_COR, contentH=36+9+44+9+28+22+14,
})
aeCard=_aeCard; aeStroke=_aeCard:FindFirstChildOfClass("UIStroke")
local _y=36+8
_accDivLine(_aeCF,_y,AE_COR); _y=_y+9
local _h, _ap, _ak = _accToggle(_aeCF, _y, "🗺️  Auto Explorar", false, AE_COR, function(s)
    aeEnabled=s
    if s then startAutoExplore() else stopAutoExplore() end
end)
aePill=_ap; aeKnob=_ak; _y=_y+_h
_accDivLine(_aeCF,_y,AE_COR); _y=_y+9
-- Barra progresso
local _aeProgBg=Instance.new("Frame",_aeCF); _aeProgBg.BackgroundColor3=Color3.fromRGB(12,24,55)
_aeProgBg.BorderSizePixel=0; _aeProgBg.Position=UDim2.new(0,12,0,_y)
_aeProgBg.Size=UDim2.new(1,-24,0,8); _aeProgBg.ZIndex=7
Instance.new("UICorner",_aeProgBg).CornerRadius=UDim.new(1,0)
aeProgressFill=Instance.new("Frame",_aeProgBg); aeProgressFill.BackgroundColor3=AE_COR
aeProgressFill.BorderSizePixel=0; aeProgressFill.Size=UDim2.new(0,0,1,0); aeProgressFill.ZIndex=8
Instance.new("UICorner",aeProgressFill).CornerRadius=UDim.new(1,0)
_y=_y+14
-- Raio / Nível
local _aeRow=Instance.new("Frame",_aeCF); _aeRow.BackgroundTransparency=1; _aeRow.BorderSizePixel=0
_aeRow.Position=UDim2.new(0,12,0,_y); _aeRow.Size=UDim2.new(1,-24,0,22); _aeRow.ZIndex=7
aeRadiusLbl=Instance.new("TextLabel",_aeRow); aeRadiusLbl.BackgroundTransparency=1
aeRadiusLbl.Size=UDim2.new(0.5,0,1,0); aeRadiusLbl.Font=Enum.Font.GothamBold
aeRadiusLbl.Text="Raio: 25"; aeRadiusLbl.TextColor3=AE_COR
aeRadiusLbl.TextSize=9; aeRadiusLbl.TextXAlignment=Enum.TextXAlignment.Left; aeRadiusLbl.ZIndex=8
aeLevelLbl=Instance.new("TextLabel",_aeRow); aeLevelLbl.BackgroundTransparency=1
aeLevelLbl.Position=UDim2.new(0.5,0,0,0); aeLevelLbl.Size=UDim2.new(0.5,0,1,0)
aeLevelLbl.Font=Enum.Font.GothamBold; aeLevelLbl.Text="Nível: ?"
aeLevelLbl.TextColor3=Color3.fromRGB(180,220,255); aeLevelLbl.TextSize=9
aeLevelLbl.TextXAlignment=Enum.TextXAlignment.Right; aeLevelLbl.ZIndex=8
_y=_y+28
aeLabelState=_accStatusLbl(_aeCF,_y); aeTimerLabel=aeLabelState
end

task.spawn(aeRefreshLevel)
task.spawn(function()
    while true do task.wait(8); if not aeEnabled then pcall(aeRefreshLevel) end end
end)

makeSec(Pages["AvancadoFarm"], afNextLO, "avFarmSecFreeze", Color3.fromRGB(0,200,255))

local FREEZE_COR = Color3.fromRGB(0,200,255)

-- ── FREEZE ANIMALS (Avançado Farm) ───────────────────────────
do
local _fzCard, _fzCF, _fzDrop = makeAccordionCard(Pages["AvancadoFarm"], afNextLO, {
    icon="❄️", title=T("freezeTitle"),
    summary=T("freezeDesc"),
    color=FREEZE_COR, contentH=36+9+44+9+50+14,
})
freezeCard=_fzCard; fzStroke=_fzCard:FindFirstChildOfClass("UIStroke")
local _y=36+8
_accDivLine(_fzCF,_y,FREEZE_COR); _y=_y+9
local _h, _fp, _fk = _accToggle(_fzCF, _y, "❄️  "..T("freezeTitle"), false, FREEZE_COR, function(s)
    freezeEnabled=s
    TweenService:Create(_fzCard:FindFirstChildOfClass("UIStroke"),TweenInfo.new(0.2),{Transparency=s and 0.3 or 0.72}):Play()
    if s then startFreezeAura(); Notify.send({type="custom",icon="❄️",accent=Color3.fromRGB(87,242,135),title=T("freezeOn"),msg="✓ "..tostring(freezeRadius)..T("freezeOnMsg"),duration=4})
    else stopFreezeAura(); Notify.error(T("freezeOff"),T("freezeOffMsg")) end
end)
fzPill=_fp; fzKnob=_fk; _y=_y+_h
_accDivLine(_fzCF,_y,FREEZE_COR); _y=_y+9
-- Raio label
local _fzValLbl=Instance.new("TextLabel",_fzCF); _fzValLbl.BackgroundTransparency=1
_fzValLbl.Position=UDim2.new(0,12,0,_y); _fzValLbl.Size=UDim2.new(0.45,0,0,20)
_fzValLbl.Font=Enum.Font.GothamBlack; _fzValLbl.Text=tostring(freezeRadius).." st"
_fzValLbl.TextColor3=FREEZE_COR; _fzValLbl.TextSize=13; _fzValLbl.TextXAlignment=Enum.TextXAlignment.Left; _fzValLbl.ZIndex=7
-- Botões -/+/reset
local _fzMinus=Instance.new("TextButton",_fzCF); _fzMinus.BackgroundColor3=Color3.fromRGB(60,38,96); _fzMinus.BorderSizePixel=0
_fzMinus.Position=UDim2.new(1,-116,0,_y-4); _fzMinus.Size=UDim2.new(0,32,0,32)
_fzMinus.Text="-"; _fzMinus.TextColor3=FREEZE_COR; _fzMinus.Font=Enum.Font.GothamBlack; _fzMinus.TextSize=18; _fzMinus.ZIndex=8
Instance.new("UICorner",_fzMinus).CornerRadius=UDim.new(0,8)
local _fzPlus=Instance.new("TextButton",_fzCF); _fzPlus.BackgroundColor3=Color3.fromRGB(0,160,220); _fzPlus.BorderSizePixel=0
_fzPlus.Position=UDim2.new(1,-76,0,_y-4); _fzPlus.Size=UDim2.new(0,32,0,32)
_fzPlus.Text="+"; _fzPlus.TextColor3=FREEZE_COR; _fzPlus.Font=Enum.Font.GothamBlack; _fzPlus.TextSize=18; _fzPlus.ZIndex=8
Instance.new("UICorner",_fzPlus).CornerRadius=UDim.new(0,8)
local _fzReset=Instance.new("TextButton",_fzCF); _fzReset.BackgroundColor3=Color3.fromRGB(0,140,200); _fzReset.BorderSizePixel=0
_fzReset.Position=UDim2.new(1,-38,0,_y+2); _fzReset.Size=UDim2.new(0,28,0,20)
_fzReset.Text="↺"; _fzReset.TextColor3=Color3.fromRGB(180,240,255); _fzReset.Font=Enum.Font.GothamBold; _fzReset.TextSize=13; _fzReset.ZIndex=8
Instance.new("UICorner",_fzReset).CornerRadius=UDim.new(0,6)
_fzMinus.MouseButton1Click:Connect(function() freezeRadius=math.max(10,freezeRadius-10); _fzValLbl.Text=tostring(freezeRadius).." st"; updateCircleRadius() end)
_fzPlus.MouseButton1Click:Connect(function() freezeRadius=math.min(500,freezeRadius+10); _fzValLbl.Text=tostring(freezeRadius).." st"; updateCircleRadius() end)
_fzReset.MouseButton1Click:Connect(function() freezeRadius=185; _fzValLbl.Text="185 st"; updateCircleRadius() end)
fzRadiusCard=_fzCard
end

do -- NOVOS_FARM_V2

local AF2_COR = Color3.fromRGB(255,210,50)
local AC_COR  = Color3.fromRGB(100,220,100)
local AHP_COR = Color3.fromRGB(255,80,120)
local ATE_COR = Color3.fromRGB(90,210,255)

local function collectItemsByNames(nameSet)
    local found,seen,pchars={},{},{}
    for _,pl in ipairs(Players:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end
    local ok,descs=pcall(function() return workspace:GetDescendants() end)
    if not ok then return found end
    for _,obj in ipairs(descs) do
        pcall(function()
            if not obj or not obj.Parent then return end
            local targetPart,checkName
            if obj:IsA("BasePart") then
                local pm=obj.Parent
                if pm and pm:IsA("Model") and not pm:FindFirstChildWhichIsA("Humanoid") then return end
                targetPart=obj; checkName=obj.Name:lower()
            elseif obj:IsA("Model") and not obj:FindFirstChildWhichIsA("Humanoid") then
                local p2=obj:FindFirstChildWhichIsA("BasePart"); if not p2 then return end
                targetPart=p2; checkName=obj.Name:lower()
            else return end
            if not nameSet[checkName] then return end
            for pc in pairs(pchars) do if pc==obj or pc:IsAncestorOf(obj) then return end end
            local key=tostring(targetPart)
            if seen[key] then return end; seen[key]=true
            table.insert(found,{part=targetPart,obj=obj})
        end)
    end
    return found
end

local function getCampfirePos()
    local pos=nil
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            local nm=obj.Name:lower()
            if nm:find("campfire",1,true) or nm:find("fogueira",1,true) or nm:find("bonfire",1,true) then
                local part=obj:FindFirstChildWhichIsA("BasePart") or (obj:IsA("BasePart") and obj)
                if part then pos=part.Position; break end
            end
        end
    end)
    return pos
end

local function dropNearCampfire(part,obj,fogPos,slot,lote)
    pcall(function()
        local ang=(slot/math.max(lote,1))*math.pi*2
        local r=1.5+slot*0.3
        local target=Vector3.new(fogPos.X+math.cos(ang)*r,fogPos.Y+1,fogPos.Z+math.sin(ang)*r)
        if obj:IsA("Model") then
            local pp=obj.PrimaryPart or part
            obj:SetPrimaryPartCFrame(CFrame.new(target))
        else
            part.CFrame=CFrame.new(target)
        end
    end)
end

local function dropAtPos(part,obj,target)
    pcall(function()
        if obj:IsA("Model") then obj:SetPrimaryPartCFrame(CFrame.new(target))
        else part.CFrame=CFrame.new(target) end
    end)
end

local function waitConsumed(entries,timeout,running)
    local t=0
    while t<timeout and running[1] do
        local allGone=true
        for _,e in ipairs(entries) do
            if e.part and e.part.Parent then allGone=false; break end
        end
        if allGone then break end
        task.wait(0.3); t=t+0.3
    end
end

-- Lista de combustíveis
local AFC_ALL_ITEMS = {
    {key="log",label="Log",icon="🪵",cat="wood"},{key="super log",label="Super Log",icon="🪵",cat="wood"},
    {key="sapling",label="Sapling",icon="🌱",cat="wood"},{key="chair",label="Chair",icon="🪑",cat="chair"},
    {key="metal chair",label="Metal Chair",icon="🪑",cat="chair"},{key="coal",label="Coal",icon="⬛",cat="liquid"},
    {key="fuel canister",label="Fuel Canister",icon="⛽",cat="liquid"},{key="biofuel",label="Biofuel",icon="💩",cat="liquid"},
    {key="oil barrel",label="Oil Barrel",icon="🛢️",cat="liquid"},{key="wolf corpse",label="Wolf Corpse",icon="🐺",cat="corpse"},
    {key="bear corpse",label="Bear Corpse",icon="🐻",cat="corpse"},{key="cultist corpse",label="Cultist Corpse",icon="🧟",cat="corpse"},
    {key="deer corpse",label="Deer Corpse",icon="🦌",cat="corpse"},{key="bunny corpse",label="Bunny Corpse",icon="🐰",cat="corpse"},
    {key="frog corpse",label="Frog Corpse",icon="🐸",cat="corpse"},
}
local afcSel={}
for _,item in ipairs(AFC_ALL_ITEMS) do afcSel[item.key]=false end
local function afcBuildNameSet() local ns={} for _,i in ipairs(AFC_ALL_ITEMS) do if afcSel[i.key] then ns[i.key]=true end end return ns end
local function afcHasSelection() for _,i in ipairs(AFC_ALL_ITEMS) do if afcSel[i.key] then return true end end return false end
local function afcSelLabel()
    local sel,n={},0; for _,i in ipairs(AFC_ALL_ITEMS) do if afcSel[i.key] then table.insert(sel,i.label); n=n+1 end end
    if n==0 then return "Selecione ▾" elseif n<=#AFC_ALL_ITEMS then
        if n<=3 then return table.concat(sel,", ").." ▾" end
        return sel[1]..", "..sel[2]..", "..sel[3].." +"..  (n-3).." ▾"
    end
end
local afcRef={}; local afcRunning=false; local AFC_COR=Color3.fromRGB(255,130,30)

-- (moveItem and _getItemsFolder moved to _LaunchHub top)
local function autoFeedCampfire()
    if afcRunning then return end; afcRunning=true
    local ns=afcBuildNameSet()
    Notify.send({type="warn",icon="🔥",accent=AFC_COR,title="Auto Feed Campfire",msg="Alimentando fogueira!",duration=3})
    while afcRunning do
        local fogPos=getCampfirePos()
        if not fogPos then task.wait(3); break end
        local itemsF=_getItemsFolder()
        if itemsF then
            local fed=0
            for _,item in ipairs(itemsF:GetChildren()) do
                if not afcRunning then break end
                if ns[item.Name:lower()] then
                    moveItem(item, fogPos)
                    fed=fed+1
                    pcall(function() if afcRef.status then afcRef.status.Text=string.format("🔥 %d itens enviados",fed) end end)
                end
            end
        end
        task.wait(2)
    end
    pcall(function() if afcRef.status then afcRef.status.Text="" end end)
    afcRunning=false
    pcall(function() if afcRef.btn then if _btnStateMap[afcRef.btn] then _btnStateMap[afcRef.btn](false) end end end)
end


-- ── AUTO FEED CAMPFIRE (SEMPRE) — Accordion ───────────────────
_nfSec("🔥  AUTO FEED CAMPFIRE (SEMPRE)", AFC_COR)
do
local _afCard, _afCF, _afDrop = makeAccordionCard(Pages["Farm"], fNextLO, {
    icon="🔥", title="Auto Feed Campfire",
    summary="Alimenta a fogueira continuamente com os combustíveis selecionados.",
    color=AFC_COR, contentH=36+9+30+8+32+8+14,
})
local _y=36+8
_accDivLine(_afCF,_y,AFC_COR); _y=_y+9
local _afSelBtn,_,_afBuildLbl,_afSelAll,_afClearAll=makeInlineDropdown(_afCF,_y,{
    title="Combustíveis",items=AFC_ALL_ITEMS,sel=afcSel,color=AFC_COR,maxVisible=6,setDropH=_afDrop,
})
afcRef.selBtn=_afSelBtn; afcRef.selBtnS=_afSelBtn:FindFirstChildOfClass("UIStroke")
_y=_y+34+8
local _afBtn,_afBtnS=_accActivBtn(_afCF,_y,"🔥",AFC_COR)
afcRef.btn=_afBtn; afcRef.btnG=_afBtnS; _y=_y+40
afcRef.status=_accStatusLbl(_afCF,_y)
afcRef.stroke=_afCard:FindFirstChildOfClass("UIStroke")
_afBtn.MouseButton1Click:Connect(function()
    if not afcHasSelection() then Notify.warn("Auto Feed","⚠️ Selecione combustível!"); return end
    if afcRunning then
        afcRunning=false; if _btnStateMap[_afBtn] then _btnStateMap[_afBtn](false) end
        afcRef.status.Text="⏹ Parado"; Notify.error("Auto Feed Campfire","⏹ Desativado")
        task.delay(1.5,function() pcall(function() afcRef.status.Text="" end) end)
    else
        if _btnStateMap[_afBtn] then _btnStateMap[_afBtn](true) end
        task.spawn(function() autoFeedCampfire()
            if not afcRunning then pcall(function() if _btnStateMap[_afBtn] then _btnStateMap[_afBtn](false) end end) end
        end)
    end
end)
end

pcall(function() -- [[ FARM PART B ]]

-- AUTO FEED HP BASED lógica
local afhpRef={}; local afhpRunning=false; local afhpThreshold=70; local AFHP_COR=Color3.fromRGB(255,80,120)
local function autoFeedHP()
    if afhpRunning then return end; afhpRunning=true
    Notify.send({type="warn",icon="❤️",accent=AFHP_COR,title="Auto Feed HP",msg=string.format("Alimenta quando HP ≤ %d%%",afhpThreshold),duration=3})
    while afhpRunning do
        local fogPos=getCampfirePos()
        if not fogPos then task.wait(3); break end
        local ok,campfire=pcall(function() return workspace.Map.Campground.MainFire end)
        local shouldFeed=false
        if ok and campfire then
            pcall(function()
                local fill=campfire.Center.BillboardGui.Frame.Background.Fill
                if fill.Size.X.Scale < (afhpThreshold/100) then shouldFeed=true end
            end)
        end
        if shouldFeed then
            local ns=afcBuildNameSet()
            local itemsF=_getItemsFolder()
            if itemsF then
                local fed=0
                for _,item in ipairs(itemsF:GetChildren()) do
                    if not afhpRunning then break end
                    if ns[item.Name:lower()] then
                        moveItem(item, fogPos)
                        fed=fed+1
                        pcall(function() if afhpRef.status then afhpRef.status.Text=string.format("❤️ %d itens enviados",fed) end end)
                    end
                end
            end
        end
        task.wait(2)
    end
    pcall(function() if afhpRef.status then afhpRef.status.Text="" end end)
    afhpRunning=false
end


-- ── AUTO FEED HP BASED — Accordion ───────────────────────────
_nfSec("🔥  AUTO FEED CAMPFIRE (HP BASED)", AFHP_COR)
do
local _afhpCard, _afhpCF, _afhpDrop = makeAccordionCard(Pages["Farm"], fNextLO, {
    icon="❤️", title="Auto Feed HP Based",
    summary="Alimenta a fogueira só quando seu HP cair abaixo do limite configurado.",
    color=AFHP_COR, contentH=36+9+44+9+34+8+32+8+14,
})
local _y=36+8
_accDivLine(_afhpCF,_y,AFHP_COR); _y=_y+9
-- HP threshold via toggle+slot
local _tRow=Instance.new("Frame",_afhpCF); _tRow.BackgroundTransparency=1; _tRow.BorderSizePixel=0
_tRow.Position=UDim2.new(0,12,0,_y); _tRow.Size=UDim2.new(1,-24,0,44); _tRow.ZIndex=7
local _tLbl=Instance.new("TextLabel",_tRow); _tLbl.BackgroundTransparency=1
_tLbl.Size=UDim2.new(0,80,1,0); _tLbl.Font=Enum.Font.GothamBold; _tLbl.Text="Limite HP:"
_tLbl.TextColor3=Color3.fromRGB(200,180,255); _tLbl.TextSize=10; _tLbl.TextXAlignment=Enum.TextXAlignment.Left; _tLbl.ZIndex=8
local _tbBox=Instance.new("Frame",_tRow); _tbBox.BackgroundColor3=Color3.fromRGB(20,12,40); _tbBox.BorderSizePixel=0
_tbBox.Position=UDim2.new(0,86,0.5,-14); _tbBox.Size=UDim2.new(0,52,0,28); _tbBox.ZIndex=9
Instance.new("UICorner",_tbBox).CornerRadius=UDim.new(0,7)
local _tbBoxS=Instance.new("UIStroke",_tbBox); _tbBoxS.Color=AFHP_COR; _tbBoxS.Thickness=1.8; _tbBoxS.Transparency=0.4; _tbBoxS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local _tb=Instance.new("TextBox",_tbBox); _tb.BackgroundTransparency=1; _tb.BorderSizePixel=0
_tb.Size=UDim2.new(1,-4,1,0); _tb.Position=UDim2.new(0,2,0,0)
_tb.Font=Enum.Font.GothamBlack; _tb.Text=tostring(afhpThreshold)
_tb.TextColor3=Color3.fromRGB(255,255,255); _tb.TextSize=14; _tb.ClearTextOnFocus=true; _tb.ZIndex=10
local _tPct=Instance.new("TextLabel",_tRow); _tPct.BackgroundTransparency=1
_tPct.Position=UDim2.new(0,142,0,0); _tPct.Size=UDim2.new(0,20,1,0)
_tPct.Font=Enum.Font.GothamBlack; _tPct.Text="%"; _tPct.TextColor3=Color3.fromRGB(160,210,255); _tPct.TextSize=14; _tPct.ZIndex=9
_tb:GetPropertyChangedSignal("Text"):Connect(function()
    local c=_tb.Text:gsub("%D",""); if #c>3 then c=c:sub(1,3) end; if _tb.Text~=c then _tb.Text=c end
end)
_tb.FocusLost:Connect(function()
    local v=tonumber(_tb.Text)
    if v then afhpThreshold=math.clamp(math.floor(v),1,100); _tb.Text=tostring(afhpThreshold)
    else _tb.Text=tostring(afhpThreshold) end
end)
_y=_y+44
_accDivLine(_afhpCF,_y,AFHP_COR); _y=_y+9
local _afhpSel,_=makeInlineDropdown(_afhpCF,_y,{
    title="Combustíveis",items=AFC_ALL_ITEMS,sel=afcSel,color=AFHP_COR,maxVisible=5,setDropH=_afhpDrop,
})
afcRef.hpSelBtn=_afhpSel; _y=_y+34+8
local _afhpBtn,_afhpBtnS=_accActivBtn(_afhpCF,_y,"❤️",AFHP_COR)
afhpRef.btn=_afhpBtn; afhpRef.btnG=_afhpBtnS; _y=_y+40
afhpRef.status=_accStatusLbl(_afhpCF,_y)
afhpRef.stroke=_afhpCard:FindFirstChildOfClass("UIStroke")
_afhpBtn.MouseButton1Click:Connect(function()
    if afhpRunning then
        afhpRunning=false; if _btnStateMap[_afhpBtn] then _btnStateMap[_afhpBtn](false) end
        afhpRef.status.Text="⏹ Parado"; Notify.error("Auto Feed HP","⏹ Desativado")
        task.delay(1.5,function() pcall(function() afhpRef.status.Text="" end) end)
    else
        if _btnStateMap[_afhpBtn] then _btnStateMap[_afhpBtn](true) end
        task.spawn(function() autoFeedHP()
            if not afhpRunning then pcall(function() if _btnStateMap[_afhpBtn] then _btnStateMap[_afhpBtn](false) end end) end
        end)
    end
end)
end

-- AUTO COOK FOOD lógica
local ackRef={}; local ackRunning=false; local ACK_COR=Color3.fromRGB(80,210,100)
local ACK_NAMES={}
for _,n in ipairs({"morsel","steak","ribs","turkey leg","fish","mackerel","salmon","clownfish","eel","swordfish","shark","lava eel","lionfish","raw meat","chicken","chicken leg","pork","raw fish","crab","crab leg"}) do ACK_NAMES[n]=true end
local function autoCookFood()
    if ackRunning then return end; ackRunning=true
    Notify.send({type="info",icon="🍖",accent=ACK_COR,title="Auto Cook Food",msg="Cozinhando itens crus!",duration=3})
    while ackRunning do
        local fogPos=getCampfirePos()
        if not fogPos then task.wait(3); break end
        local itemsF=_getItemsFolder()
        local cooked=0
        if itemsF then
            for _,item in ipairs(itemsF:GetChildren()) do
                if not ackRunning then break end
                if ACK_NAMES[item.Name:lower()] then
                    moveItem(item, fogPos)
                    cooked=cooked+1
                    pcall(function() if ackRef.status then ackRef.status.Text=string.format("🍖 %d itens cozinhando",cooked) end end)
                end
            end
        end
        task.wait(2.5)
    end
    pcall(function() if ackRef.status then ackRef.status.Text="" end end)
    ackRunning=false
    pcall(function() if ackRef.btn then if _btnStateMap[ackRef.btn] then _btnStateMap[ackRef.btn](false) end end end)
end


-- ── AUTO COOK FOOD — Accordion ────────────────────────────────
_nfSec("🍖  AUTO COOK FOOD", ACK_COR)
do
local _ackCard,_ackCF,_ = makeAccordionCard(Pages["Farm"], fNextLO, {
    icon="🍖", title="Auto Cook Food",
    summary="Pega itens crus do inventário e cozinha automaticamente na fogueira.",
    color=ACK_COR, contentH=36+9+32+14,
})
local _y=36+8; _accDivLine(_ackCF,_y,ACK_COR); _y=_y+9
local _ackBtn,_ackBtnS=_accActivBtn(_ackCF,_y,"🍖",ACK_COR); _y=_y+40
ackRef.btn=_ackBtn; ackRef.btnG=_ackBtnS; ackRef.status=_accStatusLbl(_ackCF,_y)
ackRef.stroke=_ackCard:FindFirstChildOfClass("UIStroke")
local function _ackUpdate(on) _ackBtn.Text=on and "⏹  PARAR" or "🍖  ATIVAR"; TweenService:Create(_ackBtn,TweenInfo.new(0.15),{BackgroundColor3=on and Color3.fromRGB(200,50,50) or ACK_COR}):Play() end
_ackBtn.MouseButton1Click:Connect(function()
    if ackRunning then ackRunning=false; _ackUpdate(false); ackRef.status.Text="⏹ Parado"; Notify.error("Auto Cook Food","⏹ Desativado")
        task.delay(1.5,function() pcall(function() ackRef.status.Text="" end) end)
    else _ackUpdate(true); task.spawn(function() autoCookFood(); if not ackRunning then _ackUpdate(false) end end) end
end)
end

-- AUTO MACHINE GRIND lógica
local AMG_ALL_ITEMS={
    {key="bolt",label="Bolt",icon="🔩",scrap=1,cat="metal"},{key="sheet metal",label="Sheet Metal",icon="🪨",scrap=1,cat="metal"},
    {key="broken fan",label="Broken Fan",icon="💨",scrap=2,cat="metal"},{key="old radio",label="Old Radio",icon="📻",scrap=2,cat="metal"},
    {key="broken radio",label="Broken Radio",icon="📻",scrap=2,cat="metal"},{key="metal chair",label="Metal Chair",icon="🪑",scrap=2,cat="metal"},
    {key="tyre",label="Tyre",icon="⭕",scrap=2,cat="metal"},{key="broken microwave",label="Broken Microwave",icon="📦",scrap=3,cat="metal"},
    {key="old car engine",label="Old Car Engine",icon="⚙️",scrap=4,cat="metal"},{key="washing machine",label="Washing Machine",icon="🫧",scrap=4,cat="metal"},
    {key="ufo junk",label="UFO Junk",icon="🛸",scrap=2,cat="metal"},{key="ufo component",label="UFO Component",icon="🛸",scrap=3,cat="metal"},
    {key="ufo scrap",label="UFO Scrap",icon="🛸",scrap=4,cat="metal"},{key="alien junk",label="Alien Junk",icon="👽",scrap=2,cat="metal"},
    {key="meteor shard",label="Meteor Shard",icon="☄️",scrap=3,cat="metal"},{key="gold shard",label="Gold Shard",icon="🥇",scrap=3,cat="metal"},
    {key="cultist gem",label="Cultist Gem",icon="💎",scrap=1,cat="gem"},{key="cultist experiment",label="Cultist Experiment",icon="🧪",scrap=2,cat="gem"},
    {key="cultist prototype",label="Cultist Prototype",icon="🔬",scrap=3,cat="gem"},{key="raw obsidiron ore",label="Obsidiron Ore",icon="🪨",scrap=2,cat="gem"},
    {key="obsidiron ingot",label="Obsidiron Ingot",icon="⬛",scrap=3,cat="gem"},{key="scalding obsidiron ingot",label="Scalding Ingot",icon="🔥",scrap=4,cat="gem"},
    {key="log",label="Log",icon="🪵",scrap=1,cat="wood"},
}
local amgSel={}; for _,i in ipairs(AMG_ALL_ITEMS) do amgSel[i.key]=false end
local function amgBuildNameSet() local ns={} for _,i in ipairs(AMG_ALL_ITEMS) do if amgSel[i.key] then ns[i.key]=true end end return ns end
local function amgHasSelection() for _,i in ipairs(AMG_ALL_ITEMS) do if amgSel[i.key] then return true end end return false end
local function amgSelLabel()
    local sel,n={},0; for _,i in ipairs(AMG_ALL_ITEMS) do if amgSel[i.key] then table.insert(sel,i.label); n=n+1 end end
    if n==0 then return "Selecione ▾" elseif n<=3 then return table.concat(sel,", ").." ▾"
    else return sel[1]..", "..sel[2]..", "..sel[3].." +".. (n-3).." ▾" end
end
local function findMachinePos()
    local pos=nil
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            local nm=obj.Name:lower()
            if nm:find("grind",1,true) or nm:find("shredder",1,true) or nm:find("craft",1,true) then
                local part=obj.PrimaryPart or (obj:IsA("BasePart") and obj) or obj:FindFirstChildWhichIsA("BasePart")
                if part then pos=part.Position+Vector3.new(0,9,0); break end
            end
        end
        if not pos then pos=Vector3.new(21,25,-5) end
    end)
    return pos
end
local amgRef={}; local amgRunning=false; local AMG_COR=Color3.fromRGB(100,180,255)
local function autoMachineGrind()
    if amgRunning then return end; amgRunning=true
    local machPos=findMachinePos()
    if not machPos then Notify.warn("Auto Machine Grind","Máquina não encontrada!",4); amgRunning=false; return end
    local ns=amgBuildNameSet()
    Notify.send({type="info",icon="⚙️",accent=AMG_COR,title="Auto Machine Grind",msg="Triturando: "..amgSelLabel():gsub(" ▾",""),duration=3})
    while amgRunning do
        local itemsF=_getItemsFolder()
        local ground=0
        if itemsF then
            for _,item in ipairs(itemsF:GetChildren()) do
                if not amgRunning then break end
                if ns[item.Name:lower()] then
                    moveItem(item, machPos)
                    ground=ground+1
                    pcall(function() if amgRef.status then amgRef.status.Text=string.format("⚙️ %d itens triturados",ground) end end)
                end
            end
        end
        task.wait(2.5)
    end
    pcall(function() if amgRef.status then amgRef.status.Text="" end end)
    amgRunning=false
    pcall(function() if amgRef.btn then if _btnStateMap[amgRef.btn] then _btnStateMap[amgRef.btn](false) end end end)
end


-- ── AUTO MACHINE GRIND — Estilo Voidware ──────────────────────
_nfSec("⚙️  AUTO MACHINE GRIND", AMG_COR)
do
-- Calcula altura: sep(9) + linha dropdown(40) + linha toggle(44) + status(14) + padding
local AMG_CONTENT_H = 36 + 9 + 44 + 44 + 14
local _amgCard, _amgCF, _amgDrop = makeAccordionCard(Pages["Farm"], fNextLO, {
    icon="⚙️", title="Auto Machine Grind",
    summary="Leva itens selecionados até a trituradora e converte em Scrap automaticamente.",
    color=AMG_COR, contentH=AMG_CONTENT_H,
})
amgCard = _amgCard
amgRef.stroke = _amgCard:FindFirstChildOfClass("UIStroke")

local _y = 36 + 8
_accDivLine(_amgCF, _y, AMG_COR); _y = _y + 9

-- ── LINHA 1: Dropdown "Itens para Triturar" estilo Voidware ──────
local ROW_H = 40

-- Label à esquerda
local _amgDdLbl = Instance.new("TextLabel", _amgCF)
_amgDdLbl.BackgroundTransparency = 1; _amgDdLbl.BorderSizePixel = 0
_amgDdLbl.Position = UDim2.new(0,10,0,_y)
_amgDdLbl.Size = UDim2.new(0.5,0,0,ROW_H)
_amgDdLbl.Font = Enum.Font.GothamBold; _amgDdLbl.Text = "Itens para Triturar"
_amgDdLbl.TextColor3 = Color3.fromRGB(210,200,230); _amgDdLbl.TextSize = 11
_amgDdLbl.TextXAlignment = Enum.TextXAlignment.Left
_amgDdLbl.TextYAlignment = Enum.TextYAlignment.Center; _amgDdLbl.ZIndex = 7

-- Botão dropdown estilo Voidware (compacto, canto direito)
local _amgDdBtn = Instance.new("TextButton", _amgCF)
_amgDdBtn.BackgroundColor3 = Color3.fromRGB(22,14,40)
_amgDdBtn.BackgroundTransparency = 0.2; _amgDdBtn.BorderSizePixel = 0
_amgDdBtn.AnchorPoint = Vector2.new(1,0)
_amgDdBtn.Position = UDim2.new(1,-10,0,_y+8)
_amgDdBtn.Size = UDim2.new(0,120,0,24)
_amgDdBtn.Font = Enum.Font.GothamBold; _amgDdBtn.TextSize = 9
_amgDdBtn.TextColor3 = Color3.fromRGB(180,165,210)
_amgDdBtn.TextTruncate = Enum.TextTruncate.AtEnd
_amgDdBtn.ZIndex = 8; _amgDdBtn.AutoButtonColor = false
Instance.new("UICorner",_amgDdBtn).CornerRadius = UDim.new(0,8)
local _amgDdBtnS = Instance.new("UIStroke",_amgDdBtn)
_amgDdBtnS.Color = Color3.fromRGB(80,60,120); _amgDdBtnS.Thickness = 1
_amgDdBtnS.Transparency = 0.5; _amgDdBtnS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
-- Seta ↕ estilo Voidware
local _amgDdArr = Instance.new("TextLabel",_amgDdBtn)
_amgDdArr.BackgroundTransparency = 1
_amgDdArr.AnchorPoint = Vector2.new(1,0.5); _amgDdArr.Position = UDim2.new(1,-5,0.5,0)
_amgDdArr.Size = UDim2.new(0,12,0,16); _amgDdArr.Font = Enum.Font.GothamBold
_amgDdArr.Text = "⇅"; _amgDdArr.TextColor3 = Color3.fromRGB(140,120,180); _amgDdArr.TextSize = 10; _amgDdArr.ZIndex = 9

-- Função para atualizar label do botão
local function amgDdUpdate()
    local n = 0
    for _,i in ipairs(AMG_ALL_ITEMS) do if amgSel[i.key] then n=n+1 end end
    if n == 0 then
        _amgDdBtn.Text = "Selecionar..."
        _amgDdBtn.TextColor3 = Color3.fromRGB(140,120,175)
    elseif n == #AMG_ALL_ITEMS then
        _amgDdBtn.Text = "Todos ("..n..")"
        _amgDdBtn.TextColor3 = Color3.fromRGB(200,185,235)
    else
        -- Mostra primeiro selecionado + quantidade extra
        local first = ""
        for _,i in ipairs(AMG_ALL_ITEMS) do
            if amgSel[i.key] then first=i.label; break end
        end
        _amgDdBtn.Text = n<=1 and first or (first:sub(1,8).."+"..tostring(n-1))
        _amgDdBtn.TextColor3 = Color3.fromRGB(200,185,235)
    end
end
amgDdUpdate()

-- Popup Voidware: fundo escuro, barra de busca, lista de itens com toggle
local _amgPop = Instance.new("Frame",ScreenGui)
_amgPop.BackgroundColor3 = Color3.fromRGB(18,10,34)
_amgPop.BackgroundTransparency = 0; _amgPop.BorderSizePixel = 0
_amgPop.ZIndex = 460; _amgPop.Visible = false; _amgPop.Size = UDim2.new(0,220,0,0)
_amgPop.ClipsDescendants = true
Instance.new("UICorner",_amgPop).CornerRadius = UDim.new(0,12)
local _amgPopS = Instance.new("UIStroke",_amgPop)
_amgPopS.Color = AMG_COR; _amgPopS.Thickness = 1.2; _amgPopS.Transparency = 0.45
_amgPopS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Barra de busca
local _amgSearch = Instance.new("Frame",_amgPop)
_amgSearch.BackgroundColor3 = Color3.fromRGB(28,16,50); _amgSearch.BackgroundTransparency = 0
_amgSearch.BorderSizePixel = 0; _amgSearch.Size = UDim2.new(1,0,0,36); _amgSearch.ZIndex = 461
Instance.new("UICorner",_amgSearch).CornerRadius = UDim.new(0,12)
local _amgSearchFix = Instance.new("Frame",_amgSearch)
_amgSearchFix.BackgroundColor3 = Color3.fromRGB(28,16,50); _amgSearchFix.BorderSizePixel = 0
_amgSearchFix.Position = UDim2.new(0,0,0.5,0); _amgSearchFix.Size = UDim2.new(1,0,0.5,0); _amgSearchFix.ZIndex = 461
local _amgSearchIco = Instance.new("TextLabel",_amgSearch); _amgSearchIco.BackgroundTransparency=1
_amgSearchIco.Position=UDim2.new(0,10,0,0); _amgSearchIco.Size=UDim2.new(0,18,1,0)
_amgSearchIco.Font=Enum.Font.GothamBold; _amgSearchIco.Text="🔍"; _amgSearchIco.TextSize=12; _amgSearchIco.ZIndex=462
local _amgSearchBox = Instance.new("TextBox",_amgSearch); _amgSearchBox.BackgroundTransparency=1
_amgSearchBox.Position=UDim2.new(0,30,0,0); _amgSearchBox.Size=UDim2.new(1,-38,1,0)
_amgSearchBox.Font=Enum.Font.Gotham; _amgSearchBox.PlaceholderText="Buscar..."
_amgSearchBox.PlaceholderColor3=Color3.fromRGB(110,90,150); _amgSearchBox.Text=""
_amgSearchBox.TextColor3=Color3.fromRGB(210,200,235); _amgSearchBox.TextSize=11
_amgSearchBox.ClearTextOnFocus=false; _amgSearchBox.ZIndex=462

-- Lista de itens com scroll
local _amgList = Instance.new("ScrollingFrame",_amgPop)
_amgList.BackgroundTransparency = 1; _amgList.BorderSizePixel = 0
_amgList.Position = UDim2.new(0,0,0,36); _amgList.Size = UDim2.new(1,0,1,-36)
_amgList.ScrollBarThickness = 2; _amgList.ScrollBarImageColor3 = AMG_COR
_amgList.CanvasSize = UDim2.new(0,0,0,0); _amgList.AutomaticCanvasSize = Enum.AutomaticSize.Y
_amgList.ZIndex = 461
local _amgListLayout = Instance.new("UIListLayout",_amgList)
_amgListLayout.SortOrder = Enum.SortOrder.LayoutOrder; _amgListLayout.Padding = UDim.new(0,0)
local _amgListPad = Instance.new("UIPadding",_amgList)
_amgListPad.PaddingTop=UDim.new(0,4); _amgListPad.PaddingBottom=UDim.new(0,4)
_amgListPad.PaddingLeft=UDim.new(0,6); _amgListPad.PaddingRight=UDim.new(0,6)

-- Cria linhas dos itens estilo Voidware
local _amgItemRows = {}
for idx, item in ipairs(AMG_ALL_ITEMS) do
    local iRow = Instance.new("Frame",_amgList)
    iRow.BackgroundColor3 = Color3.fromRGB(28,16,50)
    iRow.BackgroundTransparency = 1; iRow.BorderSizePixel = 0
    iRow.Size = UDim2.new(1,0,0,38); iRow.LayoutOrder = idx; iRow.ZIndex = 462
    Instance.new("UICorner",iRow).CornerRadius = UDim.new(0,8)
    -- Ícone do item
    local iIco = Instance.new("TextLabel",iRow); iIco.BackgroundTransparency = 1
    iIco.Position = UDim2.new(0,6,0,0); iIco.Size = UDim2.new(0,22,1,0)
    iIco.Text = item.icon or "•"; iIco.TextSize = 13; iIco.ZIndex = 463
    -- Label do item
    local iLbl = Instance.new("TextLabel",iRow); iLbl.BackgroundTransparency = 1
    iLbl.Position = UDim2.new(0,30,0,0); iLbl.Size = UDim2.new(1,-72,1,0)
    iLbl.Font = Enum.Font.Gotham; iLbl.Text = item.label
    iLbl.TextColor3 = Color3.fromRGB(205,195,230); iLbl.TextSize = 11
    iLbl.TextXAlignment = Enum.TextXAlignment.Left; iLbl.ZIndex = 463
    -- Toggle pill estilo Voidware (sem knob, só pill)
    local iPill = Instance.new("Frame",iRow)
    iPill.BackgroundColor3 = amgSel[item.key] and AMG_COR or Color3.fromRGB(55,40,80)
    iPill.BackgroundTransparency = amgSel[item.key] and 0 or 0.3
    iPill.BorderSizePixel = 0
    iPill.AnchorPoint = Vector2.new(1,0.5); iPill.Position = UDim2.new(1,-6,0.5,0)
    iPill.Size = UDim2.new(0,36,0,18); iPill.ZIndex = 463
    Instance.new("UICorner",iPill).CornerRadius = UDim.new(1,0)
    -- Botão invisível para clicar
    local iBtn = Instance.new("TextButton",iRow); iBtn.BackgroundTransparency = 1
    iBtn.Size = UDim2.new(1,0,1,0); iBtn.Text = ""; iBtn.ZIndex = 464
    -- Hover
    iBtn.MouseEnter:Connect(function()
        TweenService:Create(iRow,TweenInfo.new(0.1),{BackgroundTransparency=0.6}):Play()
    end)
    iBtn.MouseLeave:Connect(function()
        TweenService:Create(iRow,TweenInfo.new(0.1),{BackgroundTransparency=1}):Play()
    end)
    -- Estado inicial com fundo destacado se já selecionado
    if amgSel[item.key] then
        iRow.BackgroundTransparency = 0.75
        iRow.BackgroundColor3 = AMG_COR
        iLbl.TextColor3 = Color3.fromRGB(255,245,255)
        iLbl.Font = Enum.Font.GothamBold
        iIco.TextTransparency = 0
    end

    iBtn.MouseButton1Click:Connect(function()
        amgSel[item.key] = not amgSel[item.key]
        local sel = amgSel[item.key]
        -- Pill
        TweenService:Create(iPill,TweenInfo.new(0.15),{
            BackgroundColor3 = sel and AMG_COR or Color3.fromRGB(55,40,80),
            BackgroundTransparency = sel and 0 or 0.3,
        }):Play()
        -- Fundo da linha
        TweenService:Create(iRow,TweenInfo.new(0.15),{
            BackgroundColor3 = sel and AMG_COR or Color3.fromRGB(28,16,50),
            BackgroundTransparency = sel and 0.75 or 1,
        }):Play()
        -- Texto
        iLbl.TextColor3 = sel and Color3.fromRGB(255,245,255) or Color3.fromRGB(205,195,230)
        iLbl.Font = sel and Enum.Font.GothamBold or Enum.Font.Gotham
        amgDdUpdate()
    end)
    _amgItemRows[item.key] = {row=iRow}
end

-- Busca filtra itens
local AMG_POP_ITEM_H = 38
local AMG_POP_MAX_VISIBLE = 7
local AMG_POP_H = 36 + math.min(#AMG_ALL_ITEMS, AMG_POP_MAX_VISIBLE) * AMG_POP_ITEM_H + 12

_amgSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q = _amgSearchBox.Text:lower()
    local ord = 0
    for _,item in ipairs(AMG_ALL_ITEMS) do
        local row = _amgItemRows[item.key]
        if row then
            local visible = q=="" or item.label:lower():find(q,1,true)
            row.row.Visible = visible and true or false
            if visible then ord=ord+1; row.row.LayoutOrder=ord end
        end
    end
end)

-- Abrir/fechar popup
local _amgPopOpen = false
local function amgOpenPop()
    if _vdOpen and _vdOpen~=_amgPop then
        TweenService:Create(_vdOpen,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Size=UDim2.new(0,_vdOpen.AbsoluteSize.X,0,0)}):Play()
        task.delay(0.13,function() _vdOpen.Visible=false end)
    end
    local ap=_amgDdBtn.AbsolutePosition; local as=_amgDdBtn.AbsoluteSize
    local vp=workspace.CurrentCamera.ViewportSize
    local px=math.clamp(ap.X+as.X-220,8,vp.X-228)
    local py=ap.Y+as.Y+4
    if py+AMG_POP_H > vp.Y-8 then py=ap.Y-AMG_POP_H-4 end
    _amgPop.Position=UDim2.new(0,px,0,py)
    _amgPop.Size=UDim2.new(0,220,0,0); _amgPop.Visible=true
    _amgPop.BackgroundTransparency=0.3
    TweenService:Create(_amgPop,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,220,0,AMG_POP_H),BackgroundTransparency=0}):Play()
    TweenService:Create(_amgDdArr,TweenInfo.new(0.2),{Rotation=180}):Play()
    TweenService:Create(_amgDdBtnS,TweenInfo.new(0.1),{Transparency=0.1,Color=AMG_COR}):Play()
    _amgPopOpen=true; _vdOpen=_amgPop
    _amgSearchBox.Text=""
end
local function amgClosePop()
    _amgPopOpen=false
    TweenService:Create(_amgPop,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,220,0,0),BackgroundTransparency=0.3}):Play()
    task.delay(0.16,function() _amgPop.Visible=false; _amgPop.BackgroundTransparency=0 end)
    TweenService:Create(_amgDdArr,TweenInfo.new(0.18),{Rotation=0}):Play()
    TweenService:Create(_amgDdBtnS,TweenInfo.new(0.1),{Transparency=0.5,Color=Color3.fromRGB(80,60,120)}):Play()
    _vdOpen=nil
end
_amgDdBtn.MouseButton1Click:Connect(function()
    if _amgPopOpen then amgClosePop() else amgOpenPop() end
end)
UserInputService.InputBegan:Connect(function(inp)
    if not _amgPopOpen then return end
    if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    local mp=UserInputService:GetMouseLocation()
    local function inside(f) local a,s=f.AbsolutePosition,f.AbsoluteSize
        return mp.X>=a.X and mp.X<=a.X+s.X and mp.Y>=a.Y and mp.Y<=a.Y+s.Y end
    if not inside(_amgPop) and not inside(_amgDdBtn) then amgClosePop() end
end)

_y = _y + ROW_H + 4

-- ── LINHA 2: Toggle Ativar/Desativar estilo Voidware ─────────────
local _togRow = Instance.new("Frame",_amgCF)
_togRow.BackgroundTransparency=1; _togRow.BorderSizePixel=0
_togRow.Position=UDim2.new(0,10,0,_y); _togRow.Size=UDim2.new(1,-20,0,40); _togRow.ZIndex=7

local _togLbl = Instance.new("TextLabel",_togRow); _togLbl.BackgroundTransparency=1
_togLbl.Position=UDim2.new(0,0,0,0); _togLbl.Size=UDim2.new(1,-58,1,0)
_togLbl.Font=Enum.Font.GothamBold; _togLbl.Text="Auto Machine Grind"
_togLbl.TextColor3=Color3.fromRGB(210,200,230); _togLbl.TextSize=11
_togLbl.TextXAlignment=Enum.TextXAlignment.Left; _togLbl.TextYAlignment=Enum.TextYAlignment.Center; _togLbl.ZIndex=8

-- Pill toggle Voidware (sem knob, só a pill muda de cor)
local _togPill = Instance.new("Frame",_togRow)
_togPill.BackgroundColor3=Color3.fromRGB(55,40,80); _togPill.BackgroundTransparency=0.3
_togPill.BorderSizePixel=0; _togPill.AnchorPoint=Vector2.new(1,0.5)
_togPill.Position=UDim2.new(1,0,0.5,0); _togPill.Size=UDim2.new(0,44,0,22); _togPill.ZIndex=8
Instance.new("UICorner",_togPill).CornerRadius=UDim.new(1,0)

local _togBtn = Instance.new("TextButton",_togRow); _togBtn.BackgroundTransparency=1
_togBtn.Size=UDim2.new(1,0,1,0); _togBtn.Text=""; _togBtn.ZIndex=9

amgRef.btn=_togBtn; amgRef.status=_accStatusLbl(_amgCF,_y+44)

local function amgSetToggle(on)
    TweenService:Create(_togPill,TweenInfo.new(0.18),{
        BackgroundColor3=on and AMG_COR or Color3.fromRGB(55,40,80),
        BackgroundTransparency=on and 0 or 0.3,
    }):Play()
    if amgRef.stroke then
        TweenService:Create(amgRef.stroke,TweenInfo.new(0.2),{Transparency=on and 0.35 or 0.72}):Play()
    end
end

_togBtn.MouseButton1Click:Connect(function()
    if amgRunning then
        amgRunning=false
        amgSetToggle(false)
        amgRef.status.Text="⏹ Parado"
        Notify.error("Auto Machine Grind","⏹ Desativado")
        task.delay(1.5,function() pcall(function() amgRef.status.Text="" end) end)
    else
        if not amgHasSelection() then
            Notify.warn("Auto Machine Grind","⚠️ Selecione ao menos 1 item!",4)
            TweenService:Create(_amgDdBtnS,TweenInfo.new(0.1),{Color=Color3.fromRGB(255,80,80),Transparency=0}):Play()
            task.delay(0.8,function() TweenService:Create(_amgDdBtnS,TweenInfo.new(0.2),{Color=Color3.fromRGB(80,60,120),Transparency=0.5}):Play() end)
            return
        end
        amgSetToggle(true)
        amgRef.status.Text="⚙️ Rodando..."
        task.spawn(function() autoMachineGrind()
            if not amgRunning then amgSetToggle(false) end
        end)
    end
end)
end

-- AUTO BIOFUEL lógica
local abfRef={}; local abfRunning=false; local abfPos=nil; local ABF_COR=Color3.fromRGB(100,220,160)
local ABF_NAMES={}; for _,n in ipairs({"carrot","cooked morsel","morsel","steak","cooked steak","log"}) do ABF_NAMES[n]=true end
local function findBiofuelPos()
    local pos=nil
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            local nm=obj.Name:lower()
            if nm:find("biofuel",1,true) and (nm:find("process",1,true) or nm:find("machine",1,true) or nm:find("station",1,true) or nm:find("refin",1,true)) then
                local part=obj.PrimaryPart or (obj:IsA("BasePart") and obj) or obj:FindFirstChildWhichIsA("BasePart")
                if part then pos=part.Position+Vector3.new(0,5,0); break end
            end
        end
    end)
    return pos
end
local function autoBiofuel()
    if abfRunning then return end; abfRunning=true
    if not abfPos then abfPos=findBiofuelPos() end
    if not abfPos then Notify.warn("Auto Biofuel","Biofuel Processor não encontrado!",4); abfRunning=false; return end
    Notify.send({type="info",icon="🧪",accent=ABF_COR,title="Auto Biofuel Processor",msg="Processando itens!",duration=3})
    while abfRunning do
        local itemsF=_getItemsFolder()
        local processed=0
        if itemsF then
            for _,item in ipairs(itemsF:GetChildren()) do
                if not abfRunning then break end
                if ABF_NAMES[item.Name:lower()] then
                    moveItem(item, abfPos)
                    processed=processed+1
                    pcall(function() if abfRef.status then abfRef.status.Text=string.format("🧪 %d itens processados",processed) end end)
                end
            end
        end
        task.wait(2)
    end
    pcall(function() if abfRef.status then abfRef.status.Text="" end end)
    abfRunning=false; abfPos=nil
    pcall(function() if abfRef.btn then if _btnStateMap[abfRef.btn] then _btnStateMap[abfRef.btn](false) end end end)
end


-- ── AUTO BIOFUEL — Accordion ──────────────────────────────────
_nfSec("🧪  AUTO BIOFUEL PROCESSOR", ABF_COR)
do
local _abfCard,_abfCF,_ = makeAccordionCard(Pages["Farm"], fNextLO, {
    icon="🧪", title="Auto Biofuel Processor",
    summary="Leva itens orgânicos até o Biofuel Processor para produzir combustível.",
    color=ABF_COR, contentH=36+9+32+14,
})
local _y=36+8; _accDivLine(_abfCF,_y,ABF_COR); _y=_y+9
local _abfBtn,_abfBtnS=_accActivBtn(_abfCF,_y,"🧪",ABF_COR); _y=_y+40
abfRef.btn=_abfBtn; abfRef.btnG=_abfBtnS; abfRef.status=_accStatusLbl(_abfCF,_y)
abfRef.stroke=_abfCard:FindFirstChildOfClass("UIStroke")
local function _abfUpdate(on) _abfBtn.Text=on and "⏹  PARAR" or "🧪  ATIVAR"; TweenService:Create(_abfBtn,TweenInfo.new(0.15),{BackgroundColor3=on and Color3.fromRGB(200,50,50) or ABF_COR}):Play() end
_abfBtn.MouseButton1Click:Connect(function()
    if abfRunning then abfRunning=false; _abfUpdate(false); abfRef.status.Text="⏹ Parado"; Notify.error("Auto Biofuel","⏹ Desativado")
        task.delay(1.5,function() pcall(function() abfRef.status.Text="" end) end)
    else _abfUpdate(true); task.spawn(function() autoBiofuel(); if not abfRunning then _abfUpdate(false) end end) end
end)
end

end) -- [[ FARM PART B ]]
end -- do NOVOS_FARM_V2

-- ── FARM BAÚS — Accordion ─────────────────────────────────────
do
local FBC_COR=Color3.fromRGB(255,185,40); local fbcRunning=false; local fbcMode="jogador"
local FBC_MODES={
    {key="jogador",  label="Jogador",      icon="🧍", desc="Itens vêm para perto de você",     color=Color3.fromRGB(100,200,255)},
    {key="fogueira", label="Fogueira",     icon="🔥", desc="Itens depositados na fogueira",     color=Color3.fromRGB(255,120,40)},
    {key="pertofog", label="Perto da Fog.",icon="🪵", desc="Itens ao redor da fogueira (~8 st)",color=Color3.fromRGB(200,160,60)},
}
_nfSec("🎁  FARM BAÚS", FBC_COR)
local _fbcCard,_fbcCF,_fbcSetDrop = makeAccordionCard(Pages["Farm"], fNextLO, {
    icon="🎁", title="Farm Baús",
    summary="Teleporta em cada baú do mapa, coleta os itens e os leva ao destino.",
    color=FBC_COR, contentH=36+9+14+30+8+32+8+14,
})
fbcCard=_fbcCard
local _y=36+8; _accDivLine(_fbcCF,_y,FBC_COR); _y=_y+9

-- ── Label "Destino" ──────────────────────────────────────────
local _fbcDestLbl=Instance.new("TextLabel",_fbcCF); _fbcDestLbl.BackgroundTransparency=1
_fbcDestLbl.Position=UDim2.new(0,12,0,_y); _fbcDestLbl.Size=UDim2.new(1,-24,0,13)
_fbcDestLbl.Font=Enum.Font.GothamBold; _fbcDestLbl.Text="📍  Destino dos itens"
_fbcDestLbl.TextColor3=Color3.fromRGB(180,165,210); _fbcDestLbl.TextSize=9
_fbcDestLbl.TextXAlignment=Enum.TextXAlignment.Left; _fbcDestLbl.ZIndex=7
_y=_y+14

-- ── Trigger button ────────────────────────────────────────────
local _fbcModeBtn=Instance.new("TextButton",_fbcCF)
_fbcModeBtn.BackgroundColor3=Color3.fromRGB(22,14,42)
_fbcModeBtn.BackgroundTransparency=0.2; _fbcModeBtn.BorderSizePixel=0
_fbcModeBtn.Position=UDim2.new(0,10,0,_y); _fbcModeBtn.Size=UDim2.new(1,-20,0,28)
_fbcModeBtn.Font=Enum.Font.GothamBold; _fbcModeBtn.ZIndex=8; _fbcModeBtn.AutoButtonColor=false
_fbcModeBtn.TextTruncate=Enum.TextTruncate.AtEnd
Instance.new("UICorner",_fbcModeBtn).CornerRadius=UDim.new(0,9)
local _fbcModeBtnS=Instance.new("UIStroke",_fbcModeBtn)
_fbcModeBtnS.Thickness=1.3; _fbcModeBtnS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

-- Shine no botão
local _fbcBtnShine=Instance.new("Frame",_fbcModeBtn)
_fbcBtnShine.BackgroundColor3=Color3.fromRGB(255,255,255); _fbcBtnShine.BackgroundTransparency=0.85
_fbcBtnShine.BorderSizePixel=0; _fbcBtnShine.Position=UDim2.new(0,6,0,3)
_fbcBtnShine.Size=UDim2.new(0,50,0,5); _fbcBtnShine.ZIndex=9
Instance.new("UICorner",_fbcBtnShine).CornerRadius=UDim.new(1,0)

-- Seta ▾ à direita
local _fbcArrow=Instance.new("TextLabel",_fbcModeBtn)
_fbcArrow.BackgroundTransparency=1; _fbcArrow.AnchorPoint=Vector2.new(1,0.5)
_fbcArrow.Position=UDim2.new(1,-8,0.5,0); _fbcArrow.Size=UDim2.new(0,14,0,14)
_fbcArrow.Font=Enum.Font.GothamBlack; _fbcArrow.Text="▾"; _fbcArrow.TextSize=10; _fbcArrow.ZIndex=9

local function _fbcUpdateBtn()
    for _,m in ipairs(FBC_MODES) do
        if m.key==fbcMode then
            _fbcModeBtn.Text=m.icon.."   "..m.label
            _fbcModeBtn.TextColor3=m.color
            _fbcModeBtnS.Color=m.color
            _fbcArrow.TextColor3=m.color
            return
        end
    end
end
_fbcUpdateBtn()

-- ── Popup dropdown ────────────────────────────────────────────
local _fbcPop=Instance.new("Frame",ScreenGui)
_fbcPop.BackgroundColor3=Color3.fromRGB(20,12,36); _fbcPop.BackgroundTransparency=0
_fbcPop.BorderSizePixel=0; _fbcPop.ZIndex=420; _fbcPop.Visible=false
_fbcPop.Size=UDim2.new(0,240,0,0); _fbcPop.ClipsDescendants=true
Instance.new("UICorner",_fbcPop).CornerRadius=UDim.new(0,12)
local _fbcPopS=Instance.new("UIStroke",_fbcPop)
_fbcPopS.Color=FBC_COR; _fbcPopS.Thickness=1.5; _fbcPopS.Transparency=0.35
_fbcPopS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

-- Brilho topo
local _fbcPopShine=Instance.new("Frame",_fbcPop)
_fbcPopShine.BackgroundColor3=Color3.fromRGB(255,255,255); _fbcPopShine.BackgroundTransparency=0.88
_fbcPopShine.BorderSizePixel=0; _fbcPopShine.Size=UDim2.new(0.5,0,0,1)
_fbcPopShine.Position=UDim2.new(0.25,0,0,0); _fbcPopShine.ZIndex=421

local _fbcPopLayout=Instance.new("UIListLayout",_fbcPop)
_fbcPopLayout.SortOrder=Enum.SortOrder.LayoutOrder; _fbcPopLayout.Padding=UDim.new(0,0)
local _fbcPopPad=Instance.new("UIPadding",_fbcPop)
_fbcPopPad.PaddingTop=UDim.new(0,6); _fbcPopPad.PaddingBottom=UDim.new(0,6)
_fbcPopPad.PaddingLeft=UDim.new(0,6); _fbcPopPad.PaddingRight=UDim.new(0,6)

local ITEM_H=52; local TOTAL_H=#FBC_MODES*ITEM_H+16
local _fbcOpen=false

-- Referências dos itens para refresh
local _fbcItemRefs={}

for i,mode in ipairs(FBC_MODES) do
    local isSel=(fbcMode==mode.key)

    local item=Instance.new("Frame",_fbcPop)
    item.BackgroundColor3=isSel and Color3.fromRGB(52,32,80) or Color3.fromRGB(28,16,48)
    item.BackgroundTransparency=isSel and 0.1 or 0.5
    item.BorderSizePixel=0; item.Size=UDim2.new(1,0,0,ITEM_H-2)
    item.LayoutOrder=i; item.ZIndex=422
    Instance.new("UICorner",item).CornerRadius=UDim.new(0,9)

    local itemS=Instance.new("UIStroke",item)
    itemS.Color=mode.color; itemS.Thickness=1.3
    itemS.Transparency=isSel and 0.15 or 0.82
    itemS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

    -- Spacer entre itens
    if i < #FBC_MODES then
        local sp=Instance.new("Frame",_fbcPop)
        sp.BackgroundTransparency=1; sp.BorderSizePixel=0
        sp.Size=UDim2.new(1,0,0,3); sp.LayoutOrder=i*10+5; sp.ZIndex=421
    end

    -- Ícone com fundo colorido
    local iconBg=Instance.new("Frame",item)
    iconBg.BackgroundColor3=mode.color; iconBg.BackgroundTransparency=isSel and 0.5 or 0.78
    iconBg.BorderSizePixel=0; iconBg.Position=UDim2.new(0,8,0.5,-16)
    iconBg.Size=UDim2.new(0,32,0,32); iconBg.ZIndex=423
    Instance.new("UICorner",iconBg).CornerRadius=UDim.new(0,8)
    local iconLbl=Instance.new("TextLabel",iconBg); iconLbl.BackgroundTransparency=1
    iconLbl.Size=UDim2.new(1,0,1,0); iconLbl.Text=mode.icon; iconLbl.TextSize=18; iconLbl.ZIndex=424

    -- Nome do modo (bold)
    local nameLbl=Instance.new("TextLabel",item); nameLbl.BackgroundTransparency=1
    nameLbl.Position=UDim2.new(0,48,0,7); nameLbl.Size=UDim2.new(1,-70,0,16)
    nameLbl.Font=Enum.Font.GothamBlack; nameLbl.Text=mode.label
    nameLbl.TextColor3=isSel and Color3.fromRGB(255,250,255) or Color3.fromRGB(200,185,230)
    nameLbl.TextSize=12; nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=423

    -- Descrição (pequena)
    local descLbl=Instance.new("TextLabel",item); descLbl.BackgroundTransparency=1
    descLbl.Position=UDim2.new(0,48,0,25); descLbl.Size=UDim2.new(1,-70,0,20)
    descLbl.Font=Enum.Font.Gotham; descLbl.Text=mode.desc
    descLbl.TextColor3=isSel and Color3.fromRGB(180,165,210) or Color3.fromRGB(140,125,170)
    descLbl.TextSize=9; descLbl.TextWrapped=true
    descLbl.TextXAlignment=Enum.TextXAlignment.Left; descLbl.ZIndex=423

    -- Check ✓ direita
    local checkLbl=Instance.new("TextLabel",item); checkLbl.BackgroundTransparency=1
    checkLbl.AnchorPoint=Vector2.new(1,0.5); checkLbl.Position=UDim2.new(1,-8,0.5,0)
    checkLbl.Size=UDim2.new(0,18,0,18); checkLbl.Font=Enum.Font.GothamBlack
    checkLbl.Text=isSel and "✓" or ""; checkLbl.TextColor3=mode.color; checkLbl.TextSize=12; checkLbl.ZIndex=424

    -- Função refresh (corrige bug visual)
    local function refreshItem(hover)
        local sel=(fbcMode==mode.key)
        local bgColor, bgTrans, sTrans, icoTrans, nameColor, descColor
        if sel then
            bgColor=Color3.fromRGB(52,32,80); bgTrans=0.1; sTrans=0.15; icoTrans=0.5
            nameColor=Color3.fromRGB(255,250,255); descColor=Color3.fromRGB(180,165,210)
        elseif hover then
            bgColor=Color3.fromRGB(40,24,64); bgTrans=0.25; sTrans=0.55; icoTrans=0.65
            nameColor=Color3.fromRGB(225,210,250); descColor=Color3.fromRGB(160,145,190)
        else
            bgColor=Color3.fromRGB(28,16,48); bgTrans=0.5; sTrans=0.82; icoTrans=0.78
            nameColor=Color3.fromRGB(200,185,230); descColor=Color3.fromRGB(140,125,170)
        end
        TweenService:Create(item,TweenInfo.new(0.14),{BackgroundColor3=bgColor,BackgroundTransparency=bgTrans}):Play()
        TweenService:Create(itemS,TweenInfo.new(0.14),{Transparency=sTrans}):Play()
        TweenService:Create(iconBg,TweenInfo.new(0.14),{BackgroundTransparency=icoTrans}):Play()
        nameLbl.TextColor3=nameColor; descLbl.TextColor3=descColor
        checkLbl.Text=sel and "✓" or ""
    end
    _fbcItemRefs[mode.key]=refreshItem

    local itemBtn=Instance.new("TextButton",item); itemBtn.BackgroundTransparency=1
    itemBtn.BorderSizePixel=0; itemBtn.Size=UDim2.new(1,0,1,0); itemBtn.Text=""; itemBtn.ZIndex=425
    itemBtn.AutoButtonColor=false
    itemBtn.MouseEnter:Connect(function() if fbcMode~=mode.key then refreshItem(true) end end)
    itemBtn.MouseLeave:Connect(function() refreshItem(false) end)
    itemBtn.MouseButton1Click:Connect(function()
        fbcMode=mode.key
        -- Refresh todos os itens
        for _,fn in pairs(_fbcItemRefs) do pcall(fn,false) end
        -- Fechar popup
        _fbcOpen=false
        TweenService:Create(_fbcPop,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Size=UDim2.new(0,240,0,0),BackgroundTransparency=0.4}):Play()
        task.delay(0.2,function() _fbcPop.Visible=false; _fbcPop.BackgroundTransparency=0 end)
        _vdOpen=nil
        -- Anima seta
        TweenService:Create(_fbcArrow,TweenInfo.new(0.2),{Rotation=0}):Play()
        TweenService:Create(_fbcModeBtn,TweenInfo.new(0.15),{BackgroundTransparency=0.2}):Play()
        -- Atualiza botão
        _fbcUpdateBtn()
        Notify.send({type="info",icon=mode.icon,accent=mode.color,title="Farm Baús",msg="Destino: "..mode.label,duration=2})
    end)
end

-- Funções abrir/fechar
local function _fbcClosePop()
    if not _fbcOpen then return end
    _fbcOpen=false
    TweenService:Create(_fbcPop,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,240,0,0),BackgroundTransparency=0.4}):Play()
    task.delay(0.2,function() _fbcPop.Visible=false; _fbcPop.BackgroundTransparency=0 end)
    _vdOpen=nil
    TweenService:Create(_fbcArrow,TweenInfo.new(0.2),{Rotation=0}):Play()
    TweenService:Create(_fbcModeBtn,TweenInfo.new(0.15),{BackgroundTransparency=0.2}):Play()
end

local function _fbcOpenPop()
    if _vdOpen and _vdOpen~=_fbcPop then
        TweenService:Create(_vdOpen,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Size=UDim2.new(0,_vdOpen.AbsoluteSize.X,0,0)}):Play()
        task.delay(0.13,function() _vdOpen.Visible=false end)
    end
    -- Refresh visuais
    for _,fn in pairs(_fbcItemRefs) do pcall(fn,false) end
    local ap=_fbcModeBtn.AbsolutePosition; local as=_fbcModeBtn.AbsoluteSize
    _fbcPop.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+6)
    _fbcPop.Size=UDim2.new(0,240,0,0); _fbcPop.BackgroundTransparency=0.4; _fbcPop.Visible=true
    TweenService:Create(_fbcPop,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,240,0,TOTAL_H),BackgroundTransparency=0}):Play()
    _fbcOpen=true; _vdOpen=_fbcPop
    TweenService:Create(_fbcArrow,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=180}):Play()
    TweenService:Create(_fbcModeBtn,TweenInfo.new(0.15),{BackgroundTransparency=0.05}):Play()
end

_fbcModeBtn.MouseButton1Click:Connect(function()
    if _fbcOpen then _fbcClosePop() else _fbcOpenPop() end
end)

UserInputService.InputBegan:Connect(function(inp)
    if not _fbcOpen then return end
    if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    local mp=UserInputService:GetMouseLocation()
    local function inside(f) local a,s=f.AbsolutePosition,f.AbsoluteSize
        return mp.X>=a.X and mp.X<=a.X+s.X and mp.Y>=a.Y and mp.Y<=a.Y+s.Y end
    if not inside(_fbcPop) and not inside(_fbcModeBtn) then _fbcClosePop() end
end)

_y=_y+36
local _fbcBtn,_fbcBtnS=_accActivBtn(_fbcCF,_y,"🎁",FBC_COR); _y=_y+40
local _fbcStatus=_accStatusLbl(_fbcCF,_y); fbcStatus=_fbcStatus
-- Lógica Farm Baús
local function findAllChests()
    local chests={}
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local nm=obj.Name:lower()
                if nm:find("chest",1,true) or nm:find("bau",1,true) or nm:find("baú",1,true) then
                    local pp=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if pp and pp.Position.Y>-200 then table.insert(chests,{model=obj,part=pp}) end
                end
            end
        end
    end)
    return chests
end
local function autoFarmBaus()
    if fbcRunning then return end; fbcRunning=true
    Notify.send({type="info",icon="🎁",accent=FBC_COR,title="Farm Baús",msg="Iniciando farm de baús!",duration=3})
    local chests=findAllChests()
    if #chests==0 then Notify.warn("Farm Baús","Nenhum baú encontrado!",4); fbcRunning=false; return end
    local collected=0
    for i,chest in ipairs(chests) do
        if not fbcRunning then break end
        pcall(function()
            local ch=Player.Character; if not ch then return end
            local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            hrp.CFrame=CFrame.new(chest.part.Position+Vector3.new(0,4,0))
            task.wait(0.3)
            local fogPos=nil
            if fbcMode=="fogueira" or fbcMode=="pertofog" then fogPos=getCampfirePos() end
            local nearItems={}
            for _,obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if not obj:IsA("BasePart") and not obj:IsA("Model") then return end
                    local p2=obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") or obj
                    if not p2 then return end
                    local dist=(p2.Position-chest.part.Position).Magnitude
                    if dist<12 then table.insert(nearItems,{part=p2,obj=obj}) end
                end)
            end
            local dest=hrp.Position
            if fogPos and (fbcMode=="fogueira" or fbcMode=="pertofog") then dest=fogPos end
            for si,e in ipairs(nearItems) do
                if e.part and e.part.Parent then
                    local ang=(si/math.max(#nearItems,1))*math.pi*2; local r=2+math.floor((si-1)/8)*1.5
                    local target=Vector3.new(dest.X+math.cos(ang)*r,dest.Y+1,dest.Z+math.sin(ang)*r)
                    dropAtPos(e.part,e.obj,target); collected = collected + 1; task.wait(0.05)
                end
            end
        end)
        pcall(function() _fbcStatus.Text=string.format("🎁 Baú %d/%d — %d itens",i,#chests,collected) end)
        task.wait(0.2)
    end
    if total then end
    Notify.success("Farm Baús",string.format("✅ %d itens coletados de %d baús!",collected,#chests),5)
    fbcRunning=false
    pcall(function() if _btnStateMap[_fbcBtn] then _btnStateMap[_fbcBtn](false) end end)
    pcall(function() _fbcStatus.Text="" end)
end
_fbcBtn.MouseButton1Click:Connect(function()
    if fbcRunning then
        fbcRunning=false; if _btnStateMap[_fbcBtn] then _btnStateMap[_fbcBtn](false) end
        _fbcStatus.Text="⏹ Parado"; Notify.error("Farm Baús","⏹ Desativado")
        task.delay(1.5,function() pcall(function() _fbcStatus.Text="" end) end)
    else
        if _btnStateMap[_fbcBtn] then _btnStateMap[_fbcBtn](true) end
        task.spawn(function() autoFarmBaus(); if not fbcRunning then pcall(function() if _btnStateMap[_fbcBtn] then _btnStateMap[_fbcBtn](false) end end) end end)
    end
end)
end -- Farm Baús accordion

end); if not _dbgOk_15817 then warn('[PudimHub DEBUG] Erro na secao FARM2: '..tostring(_dbgErr_15817)) end

pcall(function() -- [[ AIMBOT + ADVANCED ]]

-- ── UI helpers para AvancadoFuncoes ────────────────────────────
local avfuncLO = 0
local function avfNextLO() avfuncLO = avfuncLO + 1; return avfuncLO end

local function makeAvSec(titleTxt, cor)
    local hdr = Instance.new("Frame", Pages["AvancadoFuncoes"])
    hdr.BackgroundColor3 = Color3.fromRGB(52,32,84); hdr.BorderSizePixel = 0
    hdr.Size = UDim2.new(1,0,0,26); hdr.LayoutOrder = avfNextLO(); hdr.ZIndex = 4
    Instance.new("UICorner",hdr).CornerRadius = UDim.new(0,9)
    local hdrG = Instance.new("UIGradient",hdr)
    hdrG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40,22,8)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(44,28,72)),
    }); hdrG.Rotation = 135
    local gborder = Instance.new("UIStroke",hdr)
    gborder.Color = Color3.fromRGB(8,4,20); gborder.Thickness = 2.5
    gborder.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local bar = Instance.new("Frame",hdr); bar.BackgroundColor3 = cor; bar.BorderSizePixel = 0
    bar.Size = UDim2.new(0,5,0.75,0); bar.Position = UDim2.new(0,0,0.12,0); bar.ZIndex = 5
    Instance.new("UICorner",bar).CornerRadius = UDim.new(0,4)
    local shine = Instance.new("Frame",hdr); shine.BackgroundColor3 = Color3.fromRGB(255,255,255)
    shine.BackgroundTransparency = 0.82; shine.BorderSizePixel = 0
    shine.Position = UDim2.new(0,8,0,2); shine.Size = UDim2.new(0,50,0,4); shine.ZIndex = 5
    Instance.new("UICorner",shine).CornerRadius = UDim.new(1,0)
    local lbl = Instance.new("TextLabel",hdr); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,14,0,0); lbl.Size = UDim2.new(1,-18,1,0)
    lbl.Font = Enum.Font.GothamBlack; lbl.Text = titleTxt
    lbl.TextColor3 = Color3.fromRGB(255,255,255); lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5
    local lblS = Instance.new("UIStroke",lbl); lblS.Color = Color3.fromRGB(8,4,20); lblS.Thickness = 1.5
end

local function makeAvToggle(lbl_txt, desc_txt, cor, onToggle)
    local row = Instance.new("Frame", Pages["AvancadoFuncoes"])
    row.BackgroundColor3 = Color3.fromRGB(52,32,84); row.BorderSizePixel = 0
    row.Size = UDim2.new(1,0,0,64); row.LayoutOrder = avfNextLO(); row.ZIndex = 5
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,12)
    local rowG = Instance.new("UIGradient",row)
    rowG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60,38,96)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(44,28,72))
    }); rowG.Rotation = 135
    local rowS = Instance.new("UIStroke",row)
    rowS.Color = Color3.fromRGB(8,4,20); rowS.Thickness = 3
    rowS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local lbar = Instance.new("Frame",row); lbar.BackgroundColor3 = cor; lbar.BorderSizePixel = 0
    lbar.Size = UDim2.new(0,5,0.72,0); lbar.Position = UDim2.new(0,0,0.14,0); lbar.ZIndex = 6
    Instance.new("UICorner",lbar).CornerRadius = UDim.new(0,4)
    local shine2 = Instance.new("Frame",row); shine2.BackgroundColor3 = Color3.fromRGB(255,255,255)
    shine2.BackgroundTransparency = 0.82; shine2.BorderSizePixel = 0
    shine2.Position = UDim2.new(0,8,0,3); shine2.Size = UDim2.new(0,55,0,4); shine2.ZIndex = 6
    Instance.new("UICorner",shine2).CornerRadius = UDim.new(1,0)
    local tl = Instance.new("TextLabel",row); tl.BackgroundTransparency = 1
    tl.Position = UDim2.new(0,16,0,10); tl.Size = UDim2.new(1,-80,0,20); tl.Font = Enum.Font.GothamBlack
    tl.Text = lbl_txt; tl.TextColor3 = Color3.fromRGB(255,255,255); tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 7
    local tlS = Instance.new("UIStroke",tl); tlS.Color = Color3.fromRGB(8,4,20); tlS.Thickness = 1.8
    local td = Instance.new("TextLabel",row); td.BackgroundTransparency = 1
    td.Position = UDim2.new(0,16,0,32); td.Size = UDim2.new(1,-80,0,26); td.Font = Enum.Font.Gotham
    td.Text = desc_txt; td.TextColor3 = Color3.fromRGB(155,135,185); td.TextSize = 9
    td.TextXAlignment = Enum.TextXAlignment.Left; td.TextWrapped = true; td.ZIndex = 7
    local pill = Instance.new("Frame",row); pill.BackgroundColor3 = Color3.fromRGB(100,80,120)
    pill.BorderSizePixel = 0; pill.AnchorPoint = Vector2.new(1,0.5)
    pill.Position = UDim2.new(1,-14,0.5,0); pill.Size = UDim2.new(0,44,0,24); pill.ZIndex = 9
    Instance.new("UICorner",pill).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame",pill); knob.BorderSizePixel = 0
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255); knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.ZIndex = 10; knob.Size = UDim2.new(0,18,0,18); knob.Position = UDim2.new(0,13,0.5,0)
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    local state = false
    local btn = Instance.new("TextButton",row); btn.BackgroundTransparency = 1; btn.BorderSizePixel = 0
    btn.AutoButtonColor = false; btn.Size = UDim2.new(1,0,1,0); btn.Text = ""; btn.ZIndex = 11
    btn.MouseEnter:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(50,32,80)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Thickness=4}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(52,32,84)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Thickness=3}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3 = state and cor or Color3.fromRGB(100,80,120)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position = state and UDim2.new(1,-13,0.5,0) or UDim2.new(0,13,0.5,0)
        }):Play()
        TweenService:Create(lbar,TweenInfo.new(0.18),{
            BackgroundColor3 = state and cor or Color3.fromRGB(80,55,120)
        }):Play()
        TweenService:Create(row,TweenInfo.new(0.08),{BackgroundColor3=state and cor or Color3.fromRGB(70,40,100)}):Play()
        task.delay(0.1,function() TweenService:Create(row,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(52,32,84)}):Play() end)
        -- Som de ligar/desligar
        task.spawn(function()
            pcall(function()
                local sndId = state and 6031221736 or 2544086171
                local snd = Instance.new("Sound")
                snd.SoundId = "rbxassetid://"..tostring(sndId)
                snd.Volume = 0.45; snd.RollOffMaxDistance = 0
                snd.Parent = SoundService
                if not snd.IsLoaded then snd.Loaded:Wait() end
                snd:Play()
                game:GetService("Debris"):AddItem(snd, 3)
            end)
        end)
        if state then
            Notify.success(lbl_txt, "✓ Ativado")
        else
            Notify.send({type="error", icon="✕", accent=Color3.fromRGB(255,75,75), title=lbl_txt, msg="✗ Desativado"})
        end
        onToggle(state)
    end)
end

-- ══════════════════════════════════════════════════════════════
-- makeTeleportPanel — Estilo Voidware (foto referência)
-- [Select Label  |  Item Selecionado... ⟨⟩]  ← dropdown overlay
-- [        🚀 Teleportar para X              ]  ← botão ação
-- ══════════════════════════════════════════════════════════════
local _vdOpenDropdown = nil  -- guarda referência do dropdown aberto (fecha o anterior)

local function makeTeleportPanel(cfg)
    local parent      = cfg.parent
    local items       = cfg.items or {}
    local accent      = cfg.accentColor or Color3.fromRGB(148,112,220)
    local notifTag    = cfg.notifTag or cfg.title or "Teleport"
    local getPos      = cfg.getPos
    local selIdx      = 1

    -- CARD PRINCIPAL
    local card = Instance.new("Frame", parent)
    card.BackgroundColor3 = Color3.fromRGB(50,30,82)
    card.BackgroundTransparency = 0.05
    card.BorderSizePixel = 0
    card.Size = UDim2.new(1,0,0,0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.LayoutOrder = avfNextLO()
    card.ZIndex = 5
    card.ClipsDescendants = false
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,10)
    local cardS = Instance.new("UIStroke",card)
    cardS.Color = Color3.fromRGB(90,65,130); cardS.Thickness = 1
    cardS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local cLayout = Instance.new("UIListLayout",card)
    cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cLayout.Padding = UDim.new(0,0)

    -- ── LINHA 1: header com ícone + título ───────────────────
    local hdr = Instance.new("Frame",card)
    hdr.BackgroundColor3 = Color3.fromRGB(60,38,100)
    hdr.BackgroundTransparency = 0.2; hdr.BorderSizePixel = 0
    hdr.Size = UDim2.new(1,0,0,40); hdr.LayoutOrder = 1; hdr.ZIndex = 6
    Instance.new("UICorner",hdr).CornerRadius = UDim.new(0,10)

    local hIco = Instance.new("TextLabel",hdr); hIco.BackgroundTransparency=1
    hIco.Position=UDim2.new(0,12,0.5,-12); hIco.Size=UDim2.new(0,24,0,24)
    hIco.Font=Enum.Font.GothamBold; hIco.Text=cfg.icon or "🚀"; hIco.TextSize=18; hIco.ZIndex=7

    local hTit = Instance.new("TextLabel",hdr); hTit.BackgroundTransparency=1
    hTit.Position=UDim2.new(0,42,0,0); hTit.Size=UDim2.new(1,-48,1,0)
    hTit.Font=Enum.Font.GothamBold; hTit.Text=cfg.title or "Teleporte"
    hTit.TextColor3=Color3.fromRGB(255,248,255); hTit.TextSize=12
    hTit.TextXAlignment=Enum.TextXAlignment.Left; hTit.ZIndex=7

    -- ── LINHA 2: SELECT ROW ──────────────────────────────────
    --   [Select [title]      |  [NomeSel...  ⟨⟩] ]
    local selRow = Instance.new("Frame",card)
    selRow.BackgroundTransparency = 1; selRow.BorderSizePixel = 0
    selRow.Size = UDim2.new(1,0,0,42); selRow.LayoutOrder = 2; selRow.ZIndex = 6

    local selLbl = Instance.new("TextLabel",selRow)
    selLbl.BackgroundTransparency=1
    selLbl.Position=UDim2.new(0,14,0,0); selLbl.Size=UDim2.new(0.44,0,1,0)
    selLbl.Font=Enum.Font.GothamBold
    selLbl.Text="Select "..(cfg.title or "Item")
    selLbl.TextColor3=Color3.fromRGB(220,205,245); selLbl.TextSize=11
    selLbl.TextXAlignment=Enum.TextXAlignment.Left; selLbl.ZIndex=7

    local dropBtn = Instance.new("TextButton",selRow)
    dropBtn.BackgroundColor3=Color3.fromRGB(38,22,66)
    dropBtn.BackgroundTransparency=0; dropBtn.BorderSizePixel=0
    dropBtn.AutoButtonColor=false
    dropBtn.AnchorPoint=Vector2.new(1,0.5)
    dropBtn.Position=UDim2.new(1,-12,0.5,0)
    dropBtn.Size=UDim2.new(0.52,-6,0,28); dropBtn.ZIndex=8
    Instance.new("UICorner",dropBtn).CornerRadius=UDim.new(0,7)
    local dropBtnS=Instance.new("UIStroke",dropBtn)
    dropBtnS.Color=Color3.fromRGB(90,65,130); dropBtnS.Thickness=1

    local dropValLbl = Instance.new("TextLabel",dropBtn)
    dropValLbl.BackgroundTransparency=1
    dropValLbl.Position=UDim2.new(0,10,0,0); dropValLbl.Size=UDim2.new(1,-28,1,0)
    dropValLbl.Font=Enum.Font.GothamBold
    dropValLbl.Text = #items>0 and items[1].name or "—"
    dropValLbl.TextColor3=Color3.fromRGB(230,215,255); dropValLbl.TextSize=10
    dropValLbl.TextXAlignment=Enum.TextXAlignment.Left
    dropValLbl.TextTruncate=Enum.TextTruncate.AtEnd; dropValLbl.ZIndex=9

    local dropArrow = Instance.new("TextLabel",dropBtn)
    dropArrow.BackgroundTransparency=1
    dropArrow.AnchorPoint=Vector2.new(1,0.5)
    dropArrow.Position=UDim2.new(1,-4,0.5,1); dropArrow.Size=UDim2.new(0,16,0,16)
    dropArrow.Font=Enum.Font.GothamBold; dropArrow.Text="⌄"
    dropArrow.TextColor3=Color3.fromRGB(160,140,200); dropArrow.TextSize=13; dropArrow.ZIndex=9

    -- ── LINHA 3: divider ─────────────────────────────────────
    local div = Instance.new("Frame",card)
    div.BackgroundColor3=Color3.fromRGB(90,65,130); div.BackgroundTransparency=0.6
    div.BorderSizePixel=0; div.Size=UDim2.new(1,-20,0,1)
    div.Position=UDim2.new(0,10,0,0); div.LayoutOrder=3; div.ZIndex=6

    -- ── LINHA 4: BOTÃO TELEPORTAR ─────────────────────────────
    local tpRow = Instance.new("Frame",card)
    tpRow.BackgroundTransparency=1; tpRow.BorderSizePixel=0
    tpRow.Size=UDim2.new(1,0,0,48); tpRow.LayoutOrder=4; tpRow.ZIndex=6

    local tpBtn = Instance.new("TextButton",tpRow)
    tpBtn.BackgroundColor3=Color3.fromRGB(72,48,120)
    tpBtn.BackgroundTransparency=0; tpBtn.BorderSizePixel=0
    tpBtn.AutoButtonColor=false
    tpBtn.AnchorPoint=Vector2.new(0.5,0.5)
    tpBtn.Position=UDim2.new(0.5,0,0.5,0); tpBtn.Size=UDim2.new(1,-20,0,32)
    tpBtn.Font=Enum.Font.GothamBold
    tpBtn.Text="Teleport To "..(cfg.title or "Item")
    tpBtn.TextColor3=Color3.fromRGB(230,215,255); tpBtn.TextSize=11; tpBtn.ZIndex=7
    Instance.new("UICorner",tpBtn).CornerRadius=UDim.new(0,8)
    local tpBtnS=Instance.new("UIStroke",tpBtn)
    tpBtnS.Color=Color3.fromRGB(100,75,150); tpBtnS.Thickness=1

    -- ── OVERLAY DROPDOWN (ScreenGui level) ───────────────────
    local ITEM_H = 36
    local POPUP_W = 200

    local overlay = Instance.new("Frame", ScreenGui)
    overlay.BackgroundColor3=Color3.fromRGB(44,26,72)
    overlay.BackgroundTransparency=0; overlay.BorderSizePixel=0
    overlay.ZIndex=500; overlay.Visible=false
    overlay.Size=UDim2.new(0,POPUP_W,0,0)
    overlay.ClipsDescendants=true
    Instance.new("UICorner",overlay).CornerRadius=UDim.new(0,10)
    local ovS=Instance.new("UIStroke",overlay)
    ovS.Color=Color3.fromRGB(90,65,130); ovS.Thickness=1.2
    ovS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

    local ovLayout=Instance.new("UIListLayout",overlay)
    ovLayout.SortOrder=Enum.SortOrder.LayoutOrder
    ovLayout.Padding=UDim.new(0,0)
    local ovPad=Instance.new("UIPadding",overlay)
    ovPad.PaddingTop=UDim.new(0,6); ovPad.PaddingBottom=UDim.new(0,6)
    ovPad.PaddingLeft=UDim.new(0,0); ovPad.PaddingRight=UDim.new(0,0)

    local FULL_H = #items*ITEM_H + 12
    local dropOpen = false

    -- Criar itens no overlay
    local function updateSelected()
        for i,it in ipairs(items) do
            local sel = (i==selIdx)
            if it._frame then
                TweenService:Create(it._frame,TweenInfo.new(0.1),{
                    BackgroundColor3 = sel and Color3.fromRGB(72,50,110) or Color3.fromRGB(44,26,72),
                    BackgroundTransparency = sel and 0 or 0,
                }):Play()
                if it._lbl then
                    it._lbl.TextColor3 = sel and Color3.fromRGB(255,248,255) or Color3.fromRGB(190,175,220)
                end
            end
        end
        if items[selIdx] then
            dropValLbl.Text = items[selIdx].name
        end
    end

    for i, item in ipairs(items) do
        local itFrame=Instance.new("Frame",overlay)
        itFrame.BackgroundColor3=Color3.fromRGB(44,26,72)
        itFrame.BackgroundTransparency=0; itFrame.BorderSizePixel=0
        itFrame.Size=UDim2.new(1,0,0,ITEM_H); itFrame.LayoutOrder=i; itFrame.ZIndex=501

        -- Divider entre itens (não no primeiro)
        if i > 1 then
            local idiv=Instance.new("Frame",itFrame)
            idiv.BackgroundColor3=Color3.fromRGB(80,58,118); idiv.BackgroundTransparency=0.5
            idiv.BorderSizePixel=0; idiv.Size=UDim2.new(1,-24,0,1)
            idiv.Position=UDim2.new(0,12,0,0); idiv.ZIndex=502
        end

        local itLbl=Instance.new("TextLabel",itFrame)
        itLbl.BackgroundTransparency=1
        itLbl.Position=UDim2.new(0,16,0,0); itLbl.Size=UDim2.new(1,-20,1,0)
        itLbl.Font=Enum.Font.GothamBold; itLbl.Text=item.name
        itLbl.TextColor3=Color3.fromRGB(190,175,220); itLbl.TextSize=12
        itLbl.TextXAlignment=Enum.TextXAlignment.Left; itLbl.ZIndex=502

        local itBtn=Instance.new("TextButton",itFrame)
        itBtn.BackgroundTransparency=1; itBtn.BorderSizePixel=0
        itBtn.Size=UDim2.new(1,0,1,0); itBtn.Text=""; itBtn.ZIndex=503
        itBtn.AutoButtonColor=false

        itBtn.MouseEnter:Connect(function()
            TweenService:Create(itFrame,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(62,42,96)}):Play()
        end)
        itBtn.MouseLeave:Connect(function()
            local sel=(i==selIdx)
            TweenService:Create(itFrame,TweenInfo.new(0.08),{
                BackgroundColor3=sel and Color3.fromRGB(72,50,110) or Color3.fromRGB(44,26,72)
            }):Play()
        end)
        itBtn.MouseButton1Click:Connect(function()
            selIdx=i
            updateSelected()
            -- Fechar dropdown
            dropOpen=false
            dropArrow.Text="⌄"
            TweenService:Create(overlay,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
                {Size=UDim2.new(0,POPUP_W,0,0)}):Play()
            task.delay(0.13,function() overlay.Visible=false end)
            _vdOpenDropdown=nil
        end)

        item._frame=itFrame; item._lbl=itLbl
    end

    -- Abrir/fechar dropdown
    local function openDropdown()
        -- Fecha outro se aberto
        if _vdOpenDropdown and _vdOpenDropdown ~= overlay then
            local prev=_vdOpenDropdown
            TweenService:Create(prev,TweenInfo.new(0.1),{Size=UDim2.new(0,POPUP_W,0,0)}):Play()
            task.delay(0.11,function() prev.Visible=false end)
        end
        -- Posicionar abaixo do dropBtn
        local ap=dropBtn.AbsolutePosition; local as=dropBtn.AbsoluteSize
        overlay.Position=UDim2.new(0,ap.X+as.X-POPUP_W,0,ap.Y+as.Y+4)
        overlay.Size=UDim2.new(0,POPUP_W,0,0)
        overlay.Visible=true
        TweenService:Create(overlay,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
            {Size=UDim2.new(0,POPUP_W,0,FULL_H)}):Play()
        _vdOpenDropdown=overlay
        dropOpen=true
        dropArrow.Text="⌃"
        TweenService:Create(dropBtnS,TweenInfo.new(0.1),{Color=accent}):Play()
    end

    local function closeDropdown()
        dropOpen=false
        dropArrow.Text="⌄"
        TweenService:Create(overlay,TweenInfo.new(0.13,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
            {Size=UDim2.new(0,POPUP_W,0,0)}):Play()
        task.delay(0.14,function() overlay.Visible=false end)
        TweenService:Create(dropBtnS,TweenInfo.new(0.1),{Color=Color3.fromRGB(90,65,130)}):Play()
        _vdOpenDropdown=nil
    end

    dropBtn.MouseButton1Click:Connect(function()
        if dropOpen then closeDropdown() else openDropdown() end
    end)
    dropBtn.MouseEnter:Connect(function()
        TweenService:Create(dropBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(50,32,84)}):Play()
    end)
    dropBtn.MouseLeave:Connect(function()
        TweenService:Create(dropBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(38,22,66)}):Play()
    end)

    -- Clique fora fecha
    UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 and dropOpen then
            local mx,my=inp.Position.X,inp.Position.Y
            local op=overlay.AbsolutePosition; local os=overlay.AbsoluteSize
            local dp=dropBtn.AbsolutePosition; local ds=dropBtn.AbsoluteSize
            local inOverlay=(mx>=op.X and mx<=op.X+os.X and my>=op.Y and my<=op.Y+os.Y)
            local inBtn=(mx>=dp.X and mx<=dp.X+ds.X and my>=dp.Y and my<=dp.Y+ds.Y)
            if not inOverlay and not inBtn then closeDropdown() end
        end
    end)

    -- Hover tpBtn
    tpBtn.MouseEnter:Connect(function()
        TweenService:Create(tpBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(90,62,148)}):Play()
        TweenService:Create(tpBtnS,TweenInfo.new(0.1),{Color=accent}):Play()
    end)
    tpBtn.MouseLeave:Connect(function()
        TweenService:Create(tpBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(72,48,120)}):Play()
        TweenService:Create(tpBtnS,TweenInfo.new(0.1),{Color=Color3.fromRGB(100,75,150)}):Play()
    end)

    -- Lógica teleporte
    tpBtn.MouseButton1Click:Connect(function()
        local item=items[selIdx]
        if not item then return end
        tpBtn.Text="🔍  Buscando..."; tpBtn.TextColor3=Color3.fromRGB(180,160,220)
        task.spawn(function()
            local pos = getPos and getPos(item)
            if pos then
                local ch=Player.Character
                local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame=CFrame.new(pos+Vector3.new(0,4,0))
                    tpBtn.Text="✅  Chegou!"; tpBtn.TextColor3=Color3.fromRGB(87,242,135)
                    TweenService:Create(tpBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(30,120,70)}):Play()
                    Notify.send({type="success",icon="🚀",accent=accent,title=notifTag,msg="Teleportado para "..item.name.." ✓",duration=3})
                    task.wait(1.5)
                    TweenService:Create(tpBtn,TweenInfo.new(0.25),{BackgroundColor3=Color3.fromRGB(72,48,120)}):Play()
                    tpBtn.Text="Teleport To "..(cfg.title or "Item"); tpBtn.TextColor3=Color3.fromRGB(230,215,255)
                end
            else
                tpBtn.Text="❌  Não encontrado"; tpBtn.TextColor3=Color3.fromRGB(255,90,90)
                TweenService:Create(tpBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(120,30,30)}):Play()
                Notify.warn(notifTag, item.name.." não encontrado. Explore mais o mapa!")
                task.wait(2)
                TweenService:Create(tpBtn,TweenInfo.new(0.25),{BackgroundColor3=Color3.fromRGB(72,48,120)}):Play()
                tpBtn.Text="Teleport To "..(cfg.title or "Item"); tpBtn.TextColor3=Color3.fromRGB(230,215,255)
            end
        end)
    end)

    -- Inicializa
    updateSelected()
end
-- ══════════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════
-- BIOMAS 99 Nights — lista para Tp Biomes
-- ══════════════════════════════════════════════════════
local BIOMES_99N = {
    { name="🌲 Floresta",      desc="Bioma inicial",                  col=Color3.fromRGB(60,180,80),
      keywords={"forest","floresta","spawn","base","camp","start"} },
    { name="🌋 Vulcão",        desc="Zona de lava e perigo",          col=Color3.fromRGB(255,90,20),
      keywords={"volcano","volcanic","lava","vulcao","vulcão","scorpion pit","ammo furnace"} },
    { name="🌿 Selva",         desc="Templo e cultistas",             col=Color3.fromRGB(40,200,80),
      keywords={"jungle","selva","mother temple","jungle temple","tar pit","tarpit"} },
    { name="❄️ Neve/Gelo",     desc="Bioma ártico",                   col=Color3.fromRGB(140,220,255),
      keywords={"ice","snow","frozen","winter","gelo","neve","iceberg","blizzard","tundra"} },
    { name="🐸 Pântano",       desc="Zona do sapo gigante",           col=Color3.fromRGB(90,200,70),
      keywords={"frog","swamp","pantano","pântano","marsh","swampland","bog"} },
    { name="🛸 UFO/Alien",     desc="Nave extraterrestre",            col=Color3.fromRGB(60,255,170),
      keywords={"ufo","alien","mothership","nave","ovni","broken ufo","alien base"} },
    { name="🧚 Fada",          desc="Floresta encantada",             col=Color3.fromRGB(255,150,255),
      keywords={"fairy","fada","giant tree","mother tree","brightwood","enchanted","fairy forest"} },
    { name="🏚️ Cultistas",    desc="Fortaleza cultista",             col=Color3.fromRGB(200,80,255),
      keywords={"cultist stronghold","cultist tower","cultist base","cultist temple","cultist king"} },
    { name="☄️ Meteoro",       desc="Cratera do meteoro",             col=Color3.fromRGB(255,200,80),
      keywords={"meteor","crater","meteor crater","meteor shard"} },
}

-- Encontra posição de um bioma no mapa
local function findBiomePos(biome)
    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local playerPos = hrp and hrp.Position or Vector3.new(0,0,0)
    local bestPos, bestScore = nil, 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if not obj or not obj.Parent then return end
            local nm = obj.Name:lower()
            local score = 0
            for _, kw in ipairs(biome.keywords) do
                if nm == kw then score = score + 5
                elseif nm:find(kw, 1, true) then score = score + 2 end
            end
            if score == 0 then return end
            local pos
            if obj:IsA("BasePart") then pos = obj.Position
            elseif obj:IsA("Model") then
                local bp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                if bp then pos = bp.Position end
            end
            if not pos then return end
            if pos.Magnitude > 18000 then return end
            local dist = (pos - playerPos).Magnitude
            local total = score + math.max(0, 1 - dist/8000)
            if total > bestScore then bestScore = total; bestPos = pos end
        end)
    end
    return bestPos
end

local function makeTpBiomesPanel()
    makeTeleportPanel({
        title      = "Tp Biomes",
        subtitle   = "99 Nights in the Forest • 2026",
        icon       = "🗺️",
        accentColor= Color3.fromRGB(100,200,255),
        accent2    = Color3.fromRGB(87,242,135),
        items      = BIOMES_99N,
        itemH      = 44,
        parent     = Pages["AvancadoFuncoes"],
        notifTag   = "Tp Biomes",
        getPos     = findBiomePos,
    })
end

-- ══════════════════════════════════════════════════════
-- TP CRIANÇAS v1 — 99 Nights in the Forest 2026
-- ══════════════════════════════════════════════════════
-- Crianças desaparecidas — ordem e guardas corretos (Wiki 2026)
-- Crianças — nomes oficiais confirmados (wiki + workspace)
-- Ordem por número interno: child. 1 → child. 4
local CRIANCAS_99N = {
    { name="🦕 Dino Kid",   desc="5 Lobos • Toca Vermelha • Fogueira Nível 2",  col=Color3.fromRGB(255,120,100),
      keywords={"Lost Child","LostChild","lost child","child. 1","child.1","child 1","child1","dino kid","dinokid","dino"} },
    { name="🐙 Kraken Kid", desc="4-5 Lobos Alfa • Toca Azul • Fogueira Nível 4", col=Color3.fromRGB(100,160,255),
      keywords={"Lost Child2","LostChild2","lost child2","child. 2","child.2","child 2","child2","kraken kid","krakenkid","kraken"} },
    { name="🦑 Squid Kid",  desc="2 Ursos • Toca Amarela • Fogueira Nível 5",    col=Color3.fromRGB(255,220,60),
      keywords={"Lost Child3","LostChild3","lost child3","child. 3","child.3","child 3","child3","squid kid","squidkid","squid"} },
    { name="🐨 Koala Kid",  desc="6 Ursos • Toca Cinza • Fogueira Nível 6",      col=Color3.fromRGB(180,230,255),
      keywords={"Lost Child4","LostChild4","lost child4","child. 4","child.4","child 4","child4","koala kid","koalakid","koala"} },
}

-- Busca inteligente de crianças: score por NPC + distância + nome exato tem prioridade
local function findCriancaPos(crianca)
    local bestPos   = nil
    local bestScore = 0
    local playerPos = Vector3.new(0,0,0)
    pcall(function()
        local ch = Player.Character
        if ch then
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            if hrp then playerPos = hrp.Position end
        end
    end)
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            -- Prioriza Humanoid (NPCs reais) > BasePart > Model
            local isHumanoid = obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid")
            if not (isHumanoid or obj:IsA("BasePart") or obj:IsA("Model")) then return end
            local nm = obj.Name:lower()
            local score = 0
            for _, kw in ipairs(crianca.keywords) do
                if nm == kw then score = score + 5
                elseif nm:find(kw, 1, true) then score = score + 2 end
            end
            if isHumanoid then score = score + 3 end -- bônus por ser NPC
            if score == 0 then return end
            local pos
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") then
                local hrpObj = obj:FindFirstChild("HumanoidRootPart")
                if hrpObj then pos = hrpObj.Position
                else
                    local bp = obj:FindFirstChildWhichIsA("BasePart")
                    if bp then pos = bp.Position end
                end
            end
            if not pos then return end
            if pos.Y < -300 or pos.Magnitude > 18000 then return end
            local dist = (pos - playerPos).Magnitude
            local distBonus = math.max(0, 1 - dist / 8000)
            local total = score + distBonus
            if total > bestScore then
                bestScore = total; bestPos = pos
            end
        end)
    end
    return bestPos
end

local function makeTpCriancasPanel()
    makeTeleportPanel({
        title       = "Tp Crianças",
        subtitle    = "4 crianças perdidas • 99 Nights 2026",
        icon        = "👶",
        accentColor = Color3.fromRGB(255,160,220),
        accent2     = Color3.fromRGB(255,210,100),
        items       = CRIANCAS_99N,
        itemH       = 44,
        parent      = Pages["AvancadoFuncoes"],
        notifTag    = "Tp Crianças",
        getPos      = findCriancaPos,
    })
end

-- ── Aimbot Guiado — Accordion ───────────────────────────────
do
local _avA,_avACF=makeAccordionCard(Pages["AvancadoFuncoes"],avfNextLO,{icon="🎯",title="Aimbot Guiado",summary="Projéteis se movem automaticamente para o animal mais próximo.",color=Color3.fromRGB(255,140,40),contentH=36+9+44+14})
local _ay=36+8; _accDivLine(_avACF,_ay,Color3.fromRGB(255,140,40)); _ay=_ay+9
_accToggle(_avACF,_ay,"🎯  Aimbot (Guided)",false,Color3.fromRGB(255,140,40),function(s)
    aimbotEnabled=s
    if s then Notify.warn(T("aimbotOn"),T("aimbotOnMsg")) else Notify.info(T("aimbotOff"),T("aimbotOffMsg")) end
end)
end
-- ── Aimbot AUTO — Accordion ───────────────────────────────────
do
local _avB,_avBCF=makeAccordionCard(Pages["AvancadoFuncoes"],avfNextLO,{icon="🤖",title="Aimbot AUTO",summary="Com arma ranged equipada: mira e atira automaticamente nos animais.",color=Color3.fromRGB(255,180,40),contentH=36+9+44+14})
local _ay=36+8; _accDivLine(_avBCF,_ay,Color3.fromRGB(255,180,40)); _ay=_ay+9
_accToggle(_avBCF,_ay,"🤖  Aimbot AUTO",false,Color3.fromRGB(255,180,40),function(s)
    aimbotAutoEnabled=s
    if s then startAimbotAuto(); Notify.warn(T("aimbotAutoOn"),T("aimbotAutoOnMsg")) else Notify.info(T("aimbotAutoOff"),T("aimbotAutoOffMsg")) end
end)
end

-- ── Teleporte accordion abaixo ─────────────────────────────
makeTpBiomesPanel()
makeTpCriancasPanel()

-- ══════════════════════════════════════════════════════
end) -- [[ AIMBOT + ADVANCED ]]

-- HOME TAB + WELCOME NOTIFICATION
-- ══════════════════════════════════════════════════════
task.wait(0.05)
selectTab("Info")

task.delay(1.5, function()
    Notify.send({
        type   = "custom",
        icon   = "🌲",
        accent = Color3.fromRGB(120,86,188),
        title  = T("notifWelcome"),
        msg    = T("notifWelcomeMsg")..Player.DisplayName.." ✨",
        duration = 5,
    })
end)
task.delay(2.8, function()
    Notify.info(T("notifTip"), T("notifTipMsg"))
end)

print("╔══════════════════════════════════════════════════════╗")
print("║ PUDIM HUB v5 COMPLETE + Notifications v3 Feb 2026 ║")
print("║ Toggle Notifs for Info ║")
print("╚══════════════════════════════════════════════════════╝")
end -- _LaunchHub
