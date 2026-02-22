-- ╔══════════════════════════════════════════════════════════════════╗
-- ║ PUDIM HUB — v5 COMPLETE + Notification System v3 ║
-- ║ + Toggle Notifications in the Info tab ║
-- ║ + Integrated notifications in ESP, Bring, Player, Advanced ║
-- ╚══════════════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")
local SoundService     = game:GetService("SoundService")

local Player = Players.LocalPlayer
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
ScreenGui.Parent          = game.CoreGui
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn    = false
ScreenGui.DisplayOrder    = 999

-- ══════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM v3
-- ══════════════════════════════════════════════════════
local notifEnabled = true   -- Toggle global

local NOTIF_CFG = {
    MAX_VISIBLE      = 4,
    HISTORY_MAX      = 50,
    DEFAULT_DURATION = 4.5,
    WIDTH            = 280,   -- mais largo para texto confortável
    CORNER           = "TR",
    PADDING          = 12,
    GAP              = 8,
    SOUND_ENABLED    = true,
}

local NOTIF_TIPOS = {
    success     = { title="Sucesso",    accent=Color3.fromRGB(87,242,135),  icon="✓", bg=Color3.fromRGB(18,38,28),  sound=5928788253 },
    error       = { title="Erro",       accent=Color3.fromRGB(255,75,75),   icon="✕", bg=Color3.fromRGB(38,18,18),  sound=9119713951 },
    warn        = { title="Aviso",      accent=Color3.fromRGB(255,200,50),  icon="⚠", bg=Color3.fromRGB(36,30,14),  sound=5989740700 },
    info        = { title="Info",       accent=Color3.fromRGB(88,150,255),  icon="ℹ", bg=Color3.fromRGB(16,24,44),  sound=5989740700 },
    achievement = { title="Conquista!", accent=Color3.fromRGB(255,210,60),  icon="★", bg=Color3.fromRGB(34,28,10),  sound=6042053626 },
    custom      = { title="Aviso",      accent=Color3.fromRGB(88,101,242),  icon="◆", bg=Color3.fromRGB(22,22,36),  sound=5989740700 },
}

local nQueue     = {}
local nActive    = {}
local nHistory   = {}
local nHistOpen  = false
local nCount     = 0
local nHistLO    = 0
local historyEnabled   = true   -- controla se o histórico guarda notificações
local infoHistScrollRef = nil   -- preenchido quando a aba Info for criada

-- Root container
local NotifRoot = Instance.new("Frame", ScreenGui)
NotifRoot.Name = "PudimNotifRoot"
NotifRoot.BackgroundTransparency = 1
NotifRoot.Size                   = UDim2.new(1,0,1,0)
NotifRoot.ZIndex                 = 500
NotifRoot.BorderSizePixel        = 0

-- Badge 🔔 (mantido mas oculto — histórico agora na aba Info)
local NBadge = Instance.new("Frame", NotifRoot)
NBadge.Name               = "NotifBadge"
NBadge.BackgroundColor3   = Color3.fromRGB(88,101,242)
NBadge.BorderSizePixel    = 0
NBadge.AnchorPoint        = Vector2.new(1,1)
NBadge.Position           = UDim2.new(1,-14,1,-14)
NBadge.Size               = UDim2.new(0,36,0,36)
NBadge.ZIndex             = 502
NBadge.Visible            = false  -- sempre oculto
Instance.new("UICorner",NBadge).CornerRadius = UDim.new(1,0)
local NBadgeStroke = Instance.new("UIStroke",NBadge)
NBadgeStroke.Color = Color3.fromRGB(130,150,255); NBadgeStroke.Thickness=1.5
local NBadgeBell = Instance.new("TextLabel",NBadge)
NBadgeBell.BackgroundTransparency=1; NBadgeBell.Size=UDim2.new(1,0,1,0)
NBadgeBell.Font=Enum.Font.GothamBold; NBadgeBell.Text="🔔"
NBadgeBell.TextSize=16; NBadgeBell.ZIndex=503
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

-- Historical panel
local NHistPanel = Instance.new("Frame",NotifRoot)
NHistPanel.Name="HistPanel"; NHistPanel.BackgroundColor3=Color3.fromRGB(20,21,26)
NHistPanel.BorderSizePixel=0; NHistPanel.AnchorPoint=Vector2.new(1,1)
NHistPanel.Position=UDim2.new(1,-14,1,-58); NHistPanel.Size=UDim2.new(0,340,0,0)
NHistPanel.ZIndex=510; NHistPanel.ClipsDescendants=true; NHistPanel.Visible=false
Instance.new("UICorner",NHistPanel).CornerRadius=UDim.new(0,14)
local NHistStroke=Instance.new("UIStroke",NHistPanel); NHistStroke.Color=Color3.fromRGB(55,60,80); NHistStroke.Thickness=1.5

local NHistHeader=Instance.new("Frame",NHistPanel)
NHistHeader.BackgroundColor3=Color3.fromRGB(14,15,20); NHistHeader.BorderSizePixel=0
NHistHeader.Size=UDim2.new(1,0,0,44); NHistHeader.ZIndex=511
Instance.new("UICorner",NHistHeader).CornerRadius=UDim.new(0,14)
local NHistHeaderFix=Instance.new("Frame",NHistHeader)
NHistHeaderFix.BackgroundColor3=Color3.fromRGB(14,15,20); NHistHeaderFix.BorderSizePixel=0
NHistHeaderFix.Position=UDim2.new(0,0,0.5,0); NHistHeaderFix.Size=UDim2.new(1,0,0.5,0); NHistHeaderFix.ZIndex=511
local NHistTitle=Instance.new("TextLabel",NHistHeader)
NHistTitle.BackgroundTransparency=1; NHistTitle.Position=UDim2.new(0,14,0,0)
NHistTitle.Size=UDim2.new(1,-60,1,0); NHistTitle.Font=Enum.Font.GothamBlack
NHistTitle.Text="🔔 Notifications"; NHistTitle.TextColor3=Color3.fromRGB(200,210,255)
trackLabel(NHistTitle, "notifHistTitle")
NHistTitle.TextSize=12; NHistTitle.TextXAlignment=Enum.TextXAlignment.Left; NHistTitle.ZIndex=512
local NHistClearBtn=Instance.new("TextButton",NHistHeader)
NHistClearBtn.BackgroundColor3=Color3.fromRGB(50,30,30); NHistClearBtn.BackgroundTransparency=0.3
NHistClearBtn.BorderSizePixel=0; NHistClearBtn.AnchorPoint=Vector2.new(1,0.5)
NHistClearBtn.Position=UDim2.new(1,-10,0.5,0); NHistClearBtn.Size=UDim2.new(0,58,0,24)
NHistClearBtn.Font=Enum.Font.GothamBold; NHistClearBtn.Text="Limpar"
trackLabel(NHistClearBtn, "notifHistClear")
NHistClearBtn.TextColor3=Color3.fromRGB(255,100,100); NHistClearBtn.TextSize=9; NHistClearBtn.ZIndex=512
Instance.new("UICorner",NHistClearBtn).CornerRadius=UDim.new(0,7)

local NHistScroll=Instance.new("ScrollingFrame",NHistPanel)
NHistScroll.BackgroundTransparency=1; NHistScroll.BorderSizePixel=0
NHistScroll.Position=UDim2.new(0,0,0,44); NHistScroll.Size=UDim2.new(1,0,1,-44)
NHistScroll.ZIndex=511; NHistScroll.ScrollBarThickness=3
NHistScroll.ScrollBarImageColor3=Color3.fromRGB(88,101,242)
NHistScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; NHistScroll.CanvasSize=UDim2.new(0,0,0,0)
local NHistList=Instance.new("UIListLayout",NHistScroll)
NHistList.Padding=UDim.new(0,4); NHistList.SortOrder=Enum.SortOrder.LayoutOrder
local NHistPad=Instance.new("UIPadding",NHistScroll)
NHistPad.PaddingTop=UDim.new(0,8); NHistPad.PaddingLeft=UDim.new(0,10)
NHistPad.PaddingRight=UDim.new(0,10); NHistPad.PaddingBottom=UDim.new(0,8)
local NEmptyLbl=Instance.new("TextLabel",NHistScroll)
NEmptyLbl.BackgroundTransparency=1; NEmptyLbl.Size=UDim2.new(1,0,0,60)
NEmptyLbl.Font=Enum.Font.GothamSemibold; NEmptyLbl.Text="No notifications yet."
trackLabel(NEmptyLbl, "notifHistEmpty")
NEmptyLbl.TextColor3=Color3.fromRGB(70,80,100); NEmptyLbl.TextSize=11
NEmptyLbl.LayoutOrder=9999; NEmptyLbl.ZIndex=512

-- Internal utilities
local function nPlaySound(id)
    if not NOTIF_CFG.SOUND_ENABLED or not id then return end
    pcall(function()
        local snd=Instance.new("Sound",SoundService); snd.SoundId="rbxassetid://"..tostring(id)
        snd.Volume=0.35; snd.RollOffMaxDistance=0; snd:Play()
        game:GetService("Debris"):AddItem(snd,4)
    end)
end

local function nReflow()
    -- Sempre TR: empilha de cima para baixo no lado direito
    local totalOff = 0
    for _, entry in ipairs(nActive) do
        if entry and entry.frame and entry.frame.Parent then
            local h = entry.frame.AbsoluteSize.Y
            if h == 0 then h = 50 end  -- fallback antes de renderizar
            TweenService:Create(entry.frame, TweenInfo.new(0.26, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -NOTIF_CFG.PADDING, 0, NOTIF_CFG.PADDING + totalOff)
            }):Play()
            totalOff = totalOff + h + NOTIF_CFG.GAP
        end
    end
end

local function nAddHistory(cfg, type)
    if not historyEnabled then return end
    -- Usa o scroll da aba Info se já foi criado, senão usa o panel flutuante legado
    local targetScroll = infoHistScrollRef or NHistScroll
    local emptyLbl = targetScroll:FindFirstChild("InfoHistEmptyLbl") or NEmptyLbl
    emptyLbl.Visible = false
    nHistLO = nHistLO + 1
    local t = NOTIF_TIPOS[type] or NOTIF_TIPOS.custom
    local hRow = Instance.new("Frame", targetScroll)
    hRow.BackgroundColor3 = Color3.fromRGB(26,28,38); hRow.BackgroundTransparency = 0.08
    hRow.BorderSizePixel = 0; hRow.Size = UDim2.new(1,0,0,48); hRow.LayoutOrder = -nHistLO; hRow.ZIndex = 6
    Instance.new("UICorner", hRow).CornerRadius = UDim.new(0,9)
    local hStroke = Instance.new("UIStroke", hRow); hStroke.Color = t.accent; hStroke.Thickness = 1; hStroke.Transparency = 0.72
    local hBar = Instance.new("Frame", hRow); hBar.BackgroundColor3 = t.accent; hBar.BorderSizePixel = 0
    hBar.Size = UDim2.new(0,3,1,-10); hBar.Position = UDim2.new(0,0,0,5); hBar.ZIndex = 7
    Instance.new("UICorner", hBar).CornerRadius = UDim.new(0,2)
    local hIconBg = Instance.new("Frame", hRow); hIconBg.BackgroundColor3 = t.accent
    hIconBg.BackgroundTransparency = 0.8; hIconBg.BorderSizePixel = 0
    hIconBg.Position = UDim2.new(0,10,0.5,-12); hIconBg.Size = UDim2.new(0,24,0,24); hIconBg.ZIndex = 7
    Instance.new("UICorner", hIconBg).CornerRadius = UDim.new(1,0)
    local hIcon = Instance.new("TextLabel", hIconBg); hIcon.BackgroundTransparency = 1
    hIcon.Size = UDim2.new(1,0,1,0); hIcon.Font = Enum.Font.GothamBold
    hIcon.Text = cfg.icon or t.icon; hIcon.TextColor3 = t.accent; hIcon.TextSize = 12; hIcon.ZIndex = 8
    local hTitle = Instance.new("TextLabel", hRow); hTitle.BackgroundTransparency = 1
    hTitle.Position = UDim2.new(0,42,0,7); hTitle.Size = UDim2.new(1,-50,0,14)
    hTitle.Font = Enum.Font.GothamBold; hTitle.Text = cfg.title or t.title
    hTitle.TextColor3 = Color3.fromRGB(220,225,245); hTitle.TextSize = 10
    hTitle.TextXAlignment = Enum.TextXAlignment.Left; hTitle.ZIndex = 7
    local hBadge = Instance.new("Frame", hRow); hBadge.BackgroundColor3 = t.accent
    hBadge.BackgroundTransparency = 0.82; hBadge.BorderSizePixel = 0
    hBadge.Position = UDim2.new(1,-6,0,7); hBadge.Size = UDim2.new(0,0,0,11)
    hBadge.AutomaticSize = Enum.AutomaticSize.X; hBadge.AnchorPoint = Vector2.new(1,0); hBadge.ZIndex = 7
    Instance.new("UICorner", hBadge).CornerRadius = UDim.new(0,4)
    local hBadgePad = Instance.new("UIPadding", hBadge); hBadgePad.PaddingLeft = UDim.new(0,4); hBadgePad.PaddingRight = UDim.new(0,4)
    local hBadgeLbl = Instance.new("TextLabel", hBadge); hBadgeLbl.BackgroundTransparency = 1
    hBadgeLbl.Size = UDim2.new(0,0,1,0); hBadgeLbl.AutomaticSize = Enum.AutomaticSize.X
    hBadgeLbl.Font = Enum.Font.GothamBold; hBadgeLbl.Text = type:upper()
    hBadgeLbl.TextColor3 = t.accent; hBadgeLbl.TextSize = 7; hBadgeLbl.ZIndex = 8
    local hMsg = Instance.new("TextLabel", hRow); hMsg.BackgroundTransparency = 1
    hMsg.Position = UDim2.new(0,42,0,24); hMsg.Size = UDim2.new(1,-50,0,14)
    hMsg.Font = Enum.Font.Gotham; hMsg.Text = cfg.msg or ""
    hMsg.TextColor3 = Color3.fromRGB(105,115,140); hMsg.TextSize = 9
    hMsg.TextXAlignment = Enum.TextXAlignment.Left; hMsg.TextTruncate = Enum.TextTruncate.AtEnd; hMsg.ZIndex = 7
    -- Limite de histórico
    local children = targetScroll:GetChildren(); local rows = {}
    for _,c in ipairs(children) do if c:IsA("Frame") then table.insert(rows,c) end end
    if #rows > NOTIF_CFG.HISTORY_MAX then
        table.sort(rows, function(a,b) return a.LayoutOrder < b.LayoutOrder end); rows[1]:Destroy()
    end
end

local function nRemoveEntry(entry, instant)
    if entry._removed then return end; entry._removed=true
    for i,e in ipairs(nActive) do if e==entry then table.remove(nActive,i); break end end
    local frame=entry.frame
    local dur=instant and 0 or 0.28
    -- Desliza para fora pela direita
    TweenService:Create(frame, TweenInfo.new(dur, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(1, NOTIF_CFG.WIDTH + 40, 0, frame.Position.Y.Offset)
    }):Play()
    task.delay(dur + 0.05, function()
        pcall(function() frame:Destroy() end)
        nReflow()
    end)
end

local Notify = {}

local function nCreateCard(cfg, tipo)
    local t      = NOTIF_TIPOS[tipo] or NOTIF_TIPOS.custom
    local title  = cfg.title   or t.title
    local msg    = cfg.msg     or ""
    local icon   = cfg.icon    or t.icon
    local accent = cfg.accent  or t.accent
    local bg     = cfg.bg      or t.bg
    local dur    = cfg.duration or NOTIF_CFG.DEFAULT_DURATION
    local action = cfg.action

    -- Altura dinâmica: base maior + linha de msg se existir + botão de ação
    local BASE_H  = 74                              -- card base alto
    local extraH  = (msg ~= "" and 0 or 0)          -- msg já cabe no BASE_H
    local HAS_MSG = msg ~= ""
    if HAS_MSG then BASE_H = 78 end                 -- msg presente → um pouco mais alto
    if action   then BASE_H = BASE_H + 32 end
    local TOTAL_H = BASE_H

    local startX  =  NOTIF_CFG.WIDTH + 60
    local targetX = -NOTIF_CFG.PADDING
    local topY    =  NOTIF_CFG.PADDING

    -- ── Card principal ──────────────────────────────────────────
    local card = Instance.new("Frame", NotifRoot)
    card.Name             = "PudimNotif_"..tostring(tick())
    card.BackgroundColor3 = bg
    card.BorderSizePixel  = 0
    card.AnchorPoint      = Vector2.new(1, 0)
    card.Position         = UDim2.new(1, startX, 0, topY)
    card.Size             = UDim2.new(0, NOTIF_CFG.WIDTH, 0, TOTAL_H)
    card.ZIndex           = 520
    card.ClipsDescendants = true
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)

    -- Borda colorida com accent
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color       = accent
    cardStroke.Thickness   = 1.5
    cardStroke.Transparency = 0.45

    -- Glow sutil de fundo
    local glow = Instance.new("Frame", card)
    glow.BackgroundColor3   = accent
    glow.BackgroundTransparency = 0.92
    glow.BorderSizePixel    = 0
    glow.Size               = UDim2.new(1, 0, 1, 0)
    glow.ZIndex             = 520

    -- Barra lateral esquerda (accent)
    local sideBar = Instance.new("Frame", card)
    sideBar.BackgroundColor3 = accent
    sideBar.BorderSizePixel  = 0
    sideBar.Size             = UDim2.new(0, 4, 1, -16)
    sideBar.Position         = UDim2.new(0, 0, 0, 8)
    sideBar.ZIndex           = 521
    Instance.new("UICorner", sideBar).CornerRadius = UDim.new(0, 4)

    -- ── Ícone (círculo grande) ──────────────────────────────────
    local iconBg = Instance.new("Frame", card)
    iconBg.BackgroundColor3     = accent
    iconBg.BackgroundTransparency = 0.72
    iconBg.BorderSizePixel      = 0
    iconBg.AnchorPoint          = Vector2.new(0.5, 0)
    iconBg.Position             = UDim2.new(0, 34, 0, 14)
    iconBg.Size                 = UDim2.new(0, 36, 0, 36)
    iconBg.ZIndex               = 522
    Instance.new("UICorner", iconBg).CornerRadius = UDim.new(1, 0)
    local iconStroke = Instance.new("UIStroke", iconBg)
    iconStroke.Color       = accent
    iconStroke.Thickness   = 1.5
    iconStroke.Transparency = 0.4
    local iconLbl = Instance.new("TextLabel", iconBg)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Size      = UDim2.new(1, 0, 1, 0)
    iconLbl.Font      = Enum.Font.GothamBold
    iconLbl.Text      = icon
    iconLbl.TextColor3 = accent
    iconLbl.TextSize  = 16
    iconLbl.ZIndex    = 523

    -- ── Título ──────────────────────────────────────────────────
    local titleLbl = Instance.new("TextLabel", card)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, 58, 0, HAS_MSG and 12 or 22)
    titleLbl.Size     = UDim2.new(1, -90, 0, 18)
    titleLbl.Font     = Enum.Font.GothamBlack
    titleLbl.Text     = title
    titleLbl.TextColor3 = Color3.fromRGB(240, 244, 255)
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment  = Enum.TextXAlignment.Left
    titleLbl.TextTruncate    = Enum.TextTruncate.AtEnd
    titleLbl.ZIndex   = 522

    -- Badge de tipo (pill pequena)
    local typeBadge = Instance.new("Frame", card)
    typeBadge.BackgroundColor3   = accent
    typeBadge.BackgroundTransparency = 0.78
    typeBadge.BorderSizePixel    = 0
    typeBadge.Position           = UDim2.new(0, 58, 0, HAS_MSG and 32 or 42)
    typeBadge.Size               = UDim2.new(0, 0, 0, 14)
    typeBadge.AutomaticSize      = Enum.AutomaticSize.X
    typeBadge.ZIndex             = 522
    Instance.new("UICorner", typeBadge).CornerRadius = UDim.new(0, 4)
    local typePad = Instance.new("UIPadding", typeBadge)
    typePad.PaddingLeft  = UDim.new(0, 6)
    typePad.PaddingRight = UDim.new(0, 6)
    local typeLbl = Instance.new("TextLabel", typeBadge)
    typeLbl.BackgroundTransparency = 1
    typeLbl.Size             = UDim2.new(0, 0, 1, 0)
    typeLbl.AutomaticSize    = Enum.AutomaticSize.X
    typeLbl.Font             = Enum.Font.GothamBold
    typeLbl.Text             = tipo:upper()
    typeLbl.TextColor3       = accent
    typeLbl.TextSize         = 8
    typeLbl.ZIndex           = 523

    -- ── Mensagem ─────────────────────────────────────────────────
    if HAS_MSG then
        local msgLbl = Instance.new("TextLabel", card)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Position   = UDim2.new(0, 58, 0, 50)
        msgLbl.Size       = UDim2.new(1, -70, 0, 20)
        msgLbl.Font       = Enum.Font.Gotham
        msgLbl.Text       = msg
        msgLbl.TextColor3 = Color3.fromRGB(175, 182, 205)
        msgLbl.TextSize   = 12
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left
        msgLbl.TextWrapped    = true
        msgLbl.ZIndex     = 522
    end

    -- ── Botão de ação ────────────────────────────────────────────
    if action then
        local actionBtn = Instance.new("TextButton", card)
        actionBtn.BackgroundColor3   = accent
        actionBtn.BackgroundTransparency = 0.72
        actionBtn.BorderSizePixel    = 0
        actionBtn.Position           = UDim2.new(0, 58, 0, TOTAL_H - 38)
        actionBtn.Size               = UDim2.new(0, 110, 0, 28)
        actionBtn.Font               = Enum.Font.GothamBold
        actionBtn.Text               = action.label or "Ver"
        actionBtn.TextColor3         = accent
        actionBtn.TextSize           = 11
        actionBtn.ZIndex             = 523
        Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 8)
        local aS = Instance.new("UIStroke", actionBtn)
        aS.Color = accent; aS.Thickness = 1; aS.Transparency = 0.5
        actionBtn.MouseEnter:Connect(function()
            TweenService:Create(actionBtn, TweenInfo.new(0.12), {BackgroundTransparency=0.45}):Play()
        end)
        actionBtn.MouseLeave:Connect(function()
            TweenService:Create(actionBtn, TweenInfo.new(0.12), {BackgroundTransparency=0.72}):Play()
        end)
        actionBtn.MouseButton1Click:Connect(function() pcall(action.callback) end)
    end

    -- ── Botão X — grande, fundo circular, fácil de clicar ───────
    local closeBg = Instance.new("Frame", card)
    closeBg.BackgroundColor3     = Color3.fromRGB(255, 80, 80)
    closeBg.BackgroundTransparency = 0.78
    closeBg.BorderSizePixel      = 0
    closeBg.AnchorPoint          = Vector2.new(1, 0)
    closeBg.Position             = UDim2.new(1, -10, 0, 10)
    closeBg.Size                 = UDim2.new(0, 28, 0, 28)
    closeBg.ZIndex               = 524
    Instance.new("UICorner", closeBg).CornerRadius = UDim.new(1, 0)
    local closeBtn = Instance.new("TextButton", closeBg)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Size     = UDim2.new(1, 0, 1, 0)
    closeBtn.Font     = Enum.Font.GothamBold
    closeBtn.Text     = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
    closeBtn.TextSize = 14
    closeBtn.ZIndex   = 525
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBg, TweenInfo.new(0.12), {BackgroundTransparency=0.3}):Play()
        TweenService:Create(closeBtn, TweenInfo.new(0.12), {TextColor3=Color3.fromRGB(255,255,255)}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBg, TweenInfo.new(0.12), {BackgroundTransparency=0.78}):Play()
        TweenService:Create(closeBtn, TweenInfo.new(0.12), {TextColor3=Color3.fromRGB(255,180,180)}):Play()
    end)

    -- ── Barra de progresso (fundo + fill) ───────────────────────
    local progressBg = Instance.new("Frame", card)
    progressBg.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
    progressBg.BorderSizePixel  = 0
    progressBg.Position         = UDim2.new(0, 0, 1, -4)
    progressBg.Size             = UDim2.new(1, 0, 0, 4)
    progressBg.ZIndex           = 522
    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(0, 2)
    local progressFill = Instance.new("Frame", progressBg)
    progressFill.BackgroundColor3 = accent
    progressFill.BorderSizePixel  = 0
    progressFill.Size             = UDim2.new(1, 0, 1, 0)
    progressFill.ZIndex           = 523
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0, 2)

    -- ── Entry + lógica de hover/pause ───────────────────────────
    local entry = {
        frame=card, cfg=cfg, tipo=tipo,
        startTick=tick(), duration=dur,
        paused=false, pauseAcc=0, pauseFrom=0,
        _removed=false, progress=progressFill
    }
    table.insert(nActive, 1, entry)
    nCount = nCount + 1
    NBadgeCountLbl.Text = tostring(nCount)
    NBadgeCountFrame.Visible = (nCount > 0)

    -- Hitbox para hover pause (fica atrás do closeBtn)
    local hitbox = Instance.new("TextButton", card)
    hitbox.BackgroundTransparency = 1
    hitbox.Size  = UDim2.new(1, 0, 1, 0)
    hitbox.Text  = ""
    hitbox.ZIndex = 521
    hitbox.MouseEnter:Connect(function()
        if entry._removed then return end
        entry.paused   = true
        entry.pauseFrom = tick()
        TweenService:Create(cardStroke, TweenInfo.new(0.15), {Transparency=0.05}):Play()
    end)
    hitbox.MouseLeave:Connect(function()
        if entry._removed then return end
        entry.paused   = false
        entry.pauseAcc = entry.pauseAcc + (tick() - entry.pauseFrom)
        TweenService:Create(cardStroke, TweenInfo.new(0.15), {Transparency=0.45}):Play()
    end)
    closeBtn.MouseButton1Click:Connect(function() nRemoveEntry(entry) end)

    -- ── Animação de entrada ──────────────────────────────────────
    nReflow()
    card.Position = UDim2.new(1, startX, 0, topY)
    task.wait()
    TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, targetX, 0, topY)
    }):Play()
    -- Pop do ícone ao entrar
    task.spawn(function()
        task.wait(0.1)
        TweenService:Create(iconBg, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size=UDim2.new(0,42,0,42), Position=UDim2.new(0,31,0,11)}):Play()
        task.wait(0.15)
        TweenService:Create(iconBg, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size=UDim2.new(0,36,0,36), Position=UDim2.new(0,34,0,14)}):Play()
    end)

    -- ── Timer da barra de progresso ──────────────────────────────
    task.spawn(function()
        while not entry._removed do
            task.wait(0.04)
            if entry._removed then break end
            local elapsed = tick() - entry.startTick - entry.pauseAcc
            if entry.paused then elapsed = entry.pauseFrom - entry.startTick - entry.pauseAcc end
            local pct = math.clamp(1 - (elapsed / entry.duration), 0, 1)
            pcall(function() entry.progress.Size = UDim2.new(pct, 0, 1, 0) end)
            if pct <= 0 and not entry.paused then nRemoveEntry(entry); break end
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

function Notify.success(title,msg,dur) Notify.send({tipo="success",title=title,msg=msg or "",duration=dur}) end
function Notify.error(title,msg,dur)   Notify.send({tipo="error",  title=title,msg=msg or "",duration=dur}) end
function Notify.warn(title,msg,dur)    Notify.send({tipo="warn",   title=title,msg=msg or "",duration=dur}) end
function Notify.info(title,msg,dur)    Notify.send({tipo="info",   title=title,msg=msg or "",duration=dur}) end
function Notify.achievement(title,msg,icon) Notify.send({tipo="achievement",title=title,msg=msg or "",icon=icon or "★",duration=6}) end

-- Badge toggle history
NBadgeBtn.MouseButton1Click:Connect(function()
    nHistOpen=not nHistOpen
    if nHistOpen then
        NHistPanel.Visible=true; NHistPanel.Size=UDim2.new(0,340,0,0)
        TweenService:Create(NHistPanel,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,340,0,360)}):Play()
        TweenService:Create(NBadge,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(130,60,255)}):Play()
    else
        TweenService:Create(NHistPanel,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{Size=UDim2.new(0,340,0,0)}):Play()
        TweenService:Create(NBadge,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(88,101,242)}):Play()
        task.delay(0.25,function() NHistPanel.Visible=false end)
    end
end)
NHistClearBtn.MouseButton1Click:Connect(function()
    for _,c in ipairs(NHistScroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    NEmptyLbl.Visible=true; nHistLO=0
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
        TweenService:Create(NBadge,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(88,101,242)}):Play()
        task.delay(0.25,function() NHistPanel.Visible=false end)
    end
end)

-- ══════════════════════════════════════════════════════
--  MAIN FRAME
-- ══════════════════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Parent           = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(32, 34, 37)
MainFrame.Position         = UDim2.new(0.5, -270, 0.5, -185)
MainFrame.Size             = UDim2.new(0, 540, 0, 370)
MainFrame.BorderSizePixel  = 0
MainFrame.Active           = true
MainFrame.Draggable        = true
MainFrame.ZIndex           = 2
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(55, 58, 66); MainStroke.Thickness = 1.5

-- ══════════════════════════════════════════════════════
-- TOP BAR
-- ══════════════════════════════════════════════════════
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.BackgroundColor3 = Color3.fromRGB(24, 25, 28)
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)
local topFix = Instance.new("Frame", TopBar)
topFix.BackgroundColor3 = Color3.fromRGB(24,25,28)
topFix.BorderSizePixel = 0
topFix.Position = UDim2.new(0,0,0.5,0)
topFix.Size = UDim2.new(1,0,0.5,0)
topFix.ZIndex = 3

local TitleBox = Instance.new("Frame", TopBar)
TitleBox.BackgroundTransparency = 1
TitleBox.Position = UDim2.new(0, 12, 0, 0)
TitleBox.Size     = UDim2.new(0, 220, 1, 0)
TitleBox.ZIndex   = 4

local TitleIcon = Instance.new("ImageLabel", TitleBox)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Position = UDim2.new(0, 0, 0.5, -10)
TitleIcon.Size     = UDim2.new(0, 20, 0, 20)
TitleIcon.Image    = "rbxassetid://12766380903"
TitleIcon.ZIndex   = 5

local TitleLabel = Instance.new("TextLabel", TitleBox)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position       = UDim2.new(0, 26, 0, 0)
TitleLabel.Size           = UDim2.new(1, -26, 1, 0)
TitleLabel.Font           = Enum.Font.GothamBlack
TitleLabel.Text           = "PudimHub v5"
TitleLabel.TextColor3 = Color3.fromRGB(88, 101, 242)
TitleLabel.TextSize       = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex         = 5

local btnData = {
    { name="Theme",    icon="rbxassetid://7734053495" },
    { name="Minimize", icon="rbxassetid://7733956134" },
    { name="Maximize", icon="rbxassetid://7733919682" },
    { name="Close",    icon="rbxassetid://7734053426" },
}
local TopBtns = {}
local btnX = -10
for _, d in ipairs(btnData) do
    local btn = Instance.new("ImageButton", TopBar)
    btn.Name = d.name; btn.BackgroundTransparency = 1
    btn.Position = UDim2.new(1, btnX - 20, 0.5, -9)
    btn.Size = UDim2.new(0, 18, 0, 18); btn.Image = d.icon
    btn.ImageColor3 = Color3.fromRGB(160, 165, 175); btn.ZIndex = 5
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(255,255,255)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(160,165,175)}):Play() end)
    TopBtns[d.name] = btn; btnX = btnX - 30
end

-- ══════════════════════════════════════════════════════
--  SIDEBAR
-- ══════════════════════════════════════════════════════
local SideBar = Instance.new("ScrollingFrame", MainFrame)
SideBar.Name = "SideBar"; SideBar.BackgroundColor3 = Color3.fromRGB(24, 25, 28)
SideBar.Position = UDim2.new(0,0,0,40); SideBar.Size = UDim2.new(0,175,1,-78)
SideBar.BorderSizePixel = 0; SideBar.ScrollBarThickness = 0
SideBar.AutomaticCanvasSize = Enum.AutomaticSize.Y; SideBar.CanvasSize = UDim2.new(0,0,0,0); SideBar.ZIndex = 3
local SideList = Instance.new("UIListLayout", SideBar)
SideList.Padding = UDim.new(0,2); SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SidePad = Instance.new("UIPadding", SideBar)
SidePad.PaddingTop = UDim.new(0,8); SidePad.PaddingLeft = UDim.new(0,8)
SidePad.PaddingRight = UDim.new(0,8); SidePad.PaddingBottom = UDim.new(0,8)

local Divider = Instance.new("Frame", MainFrame)
Divider.BackgroundColor3 = Color3.fromRGB(14,15,17); Divider.BorderSizePixel = 0
Divider.Position = UDim2.new(0,175,0,40); Divider.Size = UDim2.new(0,1,1,-40); Divider.ZIndex = 3

-- ══════════════════════════════════════════════════════
--  CONTENT AREA
-- ══════════════════════════════════════════════════════
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Name = "ContentArea"; ContentArea.BackgroundColor3 = Color3.fromRGB(36,38,42)
ContentArea.Position = UDim2.new(0,176,0,40); ContentArea.Size = UDim2.new(1,-176,1,-40)
ContentArea.BorderSizePixel = 0; ContentArea.ZIndex = 3; ContentArea.ClipsDescendants = true

-- ══════════════════════════════════════════════════════
--  FOOTER
-- ══════════════════════════════════════════════════════
local Footer = Instance.new("Frame", MainFrame)
Footer.BackgroundColor3 = Color3.fromRGB(18,19,22); Footer.BorderSizePixel = 0
Footer.Position = UDim2.new(0,0,1,-38); Footer.Size = UDim2.new(0,175,0,38); Footer.ZIndex = 4
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 12)

local AvatarBg = Instance.new("Frame", Footer)
AvatarBg.BackgroundColor3 = Color3.fromRGB(88,101,242)
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
FName.BackgroundTransparency = 1; FName.Position = UDim2.new(0,40,0,4)
FName.Size = UDim2.new(1,-48,0,14); FName.Font = Enum.Font.GothamBold
FName.Text = Player.DisplayName; FName.TextColor3 = Color3.fromRGB(225,228,232)
FName.TextSize = 10; FName.TextXAlignment = Enum.TextXAlignment.Left
FName.TextTruncate = Enum.TextTruncate.AtEnd; FName.ZIndex = 5

local FTag = Instance.new("TextLabel", Footer)
FTag.BackgroundTransparency = 1; FTag.Position = UDim2.new(0,40,0,19)
FTag.Size = UDim2.new(1,-48,0,12); FTag.Font = Enum.Font.Gotham
FTag.Text = "@"..Player.Name; FTag.TextColor3 = Color3.fromRGB(80,90,110)
FTag.TextSize = 9; FTag.TextXAlignment = Enum.TextXAlignment.Left
FTag.TextTruncate = Enum.TextTruncate.AtEnd; FTag.ZIndex = 5

-- ── Idioma no Footer ──
local FLangFrame = Instance.new("Frame", Footer)
FLangFrame.BackgroundColor3 = Color3.fromRGB(88,101,242)
FLangFrame.BackgroundTransparency = 0.82
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
FLangLbl.AutomaticSize=Enum.AutomaticSize.X
FLangLbl.Font=Enum.Font.GothamBold
FLangLbl.Text = currentLang.flag .. " " .. currentLang.short
FLangLbl.TextColor3=Color3.fromRGB(180,190,255); FLangLbl.TextSize=8; FLangLbl.ZIndex=7

-- Registra referência para atualizar
langFooterLabel = FLangLbl

-- ══════════════════════════════════════════════════════
--  PAGES
-- ══════════════════════════════════════════════════════
local Pages = {}
local C_ACCENT   = Color3.fromRGB(88,101,242)
local C_TEXT_OFF = Color3.fromRGB(130,140,158)
local C_TEXT_ON  = Color3.fromRGB(240,242,255)
local C_BG_HOV   = Color3.fromRGB(40,43,52)
local C_BG_ACT   = Color3.fromRGB(48,52,72)
local C_ICON_IDLE   = Color3.fromRGB(90,100,120)
local C_ICON_ACTIVE = Color3.fromRGB(180,190,255)

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
}
local GroupConfig = {
    {label="GERAL",   trKey="groupGeral",   keys={"Info","Status"}},
    {label="COMBATE", trKey="groupCombate", keys={"Farm","Teleportar","Esp","Bring","AvancadoFarm"}},
    {label="EXTRA",   trKey="groupExtra",   keys={"Player","Configuracoes","AvancadoFuncoes"}},
}

for _, t in ipairs(TabConfig) do
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Name = t.key.."Page"; page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1; page.Visible = false
    page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = C_ACCENT
    page.BorderSizePixel = 0; page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0,0,0,0); page.ZIndex = 4
    local pp = Instance.new("UIPadding", page)
    pp.PaddingTop = UDim.new(0,14); pp.PaddingLeft = UDim.new(0,14)
    pp.PaddingRight = UDim.new(0,14); pp.PaddingBottom = UDim.new(0,14)
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0,8); pl.SortOrder = Enum.SortOrder.LayoutOrder
    Pages[t.key] = page
end

-- ══════════════════════════════════════════════════════
-- ABAS SYSTEM
-- ══════════════════════════════════════════════════════
local allTabs = {}; local currentTab = nil

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
    local cont = Instance.new("Frame",parent); cont.BackgroundTransparency=1; cont.BorderSizePixel=0
    cont.Position=UDim2.new(0,8,0.5,-10); cont.Size=UDim2.new(0,20,0,20)
    cont.ZIndex=parent.ZIndex+2; cont.ClipsDescendants=false
    local parts={}
    local function p(f) table.insert(parts,f); return f end
    if key=="Info" then
        p(mkCircle(cont,10,10,9,ic)); local inner=mkCircle(cont,10,10,7,Color3.fromRGB(24,26,32)); inner.ZIndex=cont.ZIndex+1
        p(mkCircle(cont,10,4,2,ic)); p(mkRect(cont,8,8,4,8,ic,2))
    elseif key=="Status" then
        p(mkRect(cont,0,12,4,8,ic,1)); p(mkRect(cont,8,6,4,14,ic,1)); p(mkRect(cont,16,9,4,11,ic,1))
    elseif key=="Farm" then
        p(mkRect(cont,11,0,5,2,ic,1)); p(mkRect(cont,6,2,8,2,ic,0)); p(mkRect(cont,4,4,10,2,ic,0))
        p(mkRect(cont,8,6,8,2,ic,0)); p(mkRect(cont,6,8,8,2,ic,0)); p(mkRect(cont,4,10,8,2,ic,0))
        p(mkRect(cont,2,12,10,2,ic,0)); p(mkRect(cont,4,14,6,2,ic,0)); p(mkRect(cont,3,18,5,2,ic,1))
    elseif key=="Esp" then
        p(mkRect(cont,2,6,16,8,ic,8)); local ei=mkRect(cont,3,7,14,6,Color3.fromRGB(24,26,32),7); ei.ZIndex=cont.ZIndex+1
        p(mkCircle(cont,10,10,4,ic)); local pi=mkCircle(cont,10,10,2,Color3.fromRGB(24,26,32)); pi.ZIndex=cont.ZIndex+3
        p(mkCircle(cont,12,8,1,Color3.fromRGB(200,220,255)))
    elseif key=="Bring" then
        p(mkRect(cont,2,2,5,12,ic,2)); p(mkRect(cont,13,2,5,12,ic,2)); p(mkRect(cont,2,2,16,5,ic,2))
        p(mkRect(cont,2,14,5,4,Color3.fromRGB(220,60,60),2)); p(mkRect(cont,13,14,5,4,Color3.fromRGB(60,120,220),2))
    elseif key=="AvancadoFarm" then
        p(mkRect(cont,9,14,2,6,ic,1)); p(mkRect(cont,9,2,2,12,ic,1))
        p(mkRect(cont,3,4,6,3,ic,2)); p(mkRect(cont,11,4,6,3,ic,2))
        p(mkRect(cont,3,8,6,3,ic,2)); p(mkRect(cont,11,8,6,3,ic,2)); p(mkRect(cont,6,0,8,3,ic,2))
    elseif key=="Player" then
        p(mkCircle(cont,10,5,4,ic)); p(mkRect(cont,5,11,10,7,ic,3))
        p(mkRect(cont,3,13,4,7,ic,2)); p(mkRect(cont,13,13,4,7,ic,2))
    elseif key=="Configuracoes" then
        p(mkCircle(cont,10,10,5,ic)); local ci=mkCircle(cont,10,10,3,Color3.fromRGB(24,26,32)); ci.ZIndex=cont.ZIndex+2
        for _,deg in ipairs({0,45,90,135,180,225,270,315}) do
            local rad=math.rad(deg)
            p(mkRect(cont,10+math.cos(rad)*8-2,10+math.sin(rad)*8-2,4,4,ic,1))
        end
    elseif key=="AvancadoFuncoes" then
        p(mkRect(cont,1,13,12,4,ic,2)); p(mkCircle(cont,15,6,5,ic))
        local furo=mkCircle(cont,15,6,3,Color3.fromRGB(24,26,32)); furo.ZIndex=cont.ZIndex+2
        p(mkRect(cont,8,9,6,3,ic,1))
    elseif key=="Teleportar" then
        -- ícone de alfinete/pin de mapa
        p(mkCircle(cont,10,7,6,ic))
        local ci=mkCircle(cont,10,7,3,Color3.fromRGB(24,26,32)); ci.ZIndex=cont.ZIndex+2
        p(mkRect(cont,8,12,4,8,ic,2))
    end
    return cont, parts
end

local function setIconColor(parts,color)
    for _,part in ipairs(parts) do if part and part.Parent then part.BackgroundColor3=color end end
end

local function selectTab(key)
    if currentTab==key then return end; currentTab=key
    for _,e in ipairs(allTabs) do
        local isThis=(e.key==key)
        TweenService:Create(e.bg,TweenInfo.new(0.18,Enum.EasingStyle.Quad),{
            BackgroundTransparency=isThis and 0.72 or 1,
            BackgroundColor3=isThis and C_BG_ACT or C_BG_HOV,
        }):Play()
        setIconColor(e.iconParts,isThis and C_ICON_ACTIVE or C_ICON_IDLE)
        TweenService:Create(e.label,TweenInfo.new(0.18),{TextColor3=isThis and C_TEXT_ON or C_TEXT_OFF}):Play()
        e.bar.Visible=isThis
        if Pages[e.key] then Pages[e.key].Visible=isThis end
    end
end

local layoutOrder=0
local function makeGroupLabel(text, trKey, groupTabs)
    layoutOrder+=1
    if layoutOrder>1 then
        local line=Instance.new("Frame",SideBar); line.BackgroundColor3=Color3.fromRGB(38,41,48)
        line.BorderSizePixel=0; line.Size=UDim2.new(1,0,0,1); line.LayoutOrder=layoutOrder*100
    end
    layoutOrder+=1
    local header=Instance.new("TextButton",SideBar); header.BackgroundTransparency=1
    header.Size=UDim2.new(1,0,0,24); header.Text=""; header.LayoutOrder=layoutOrder*100; header.ZIndex=4
    local hl=Instance.new("TextLabel",header); hl.BackgroundTransparency=1
    hl.Position=UDim2.new(0,4,0,0); hl.Size=UDim2.new(1,-24,1,0); hl.Font=Enum.Font.GothamBlack
    hl.Text=text; hl.TextColor3=C_ACCENT; hl.TextSize=8
    hl.TextXAlignment=Enum.TextXAlignment.Left; hl.ZIndex=5
    if trKey then trackLabel(hl, trKey) end
    local af=Instance.new("Frame",header); af.BackgroundTransparency=1
    af.Position=UDim2.new(1,-20,0.5,-8); af.Size=UDim2.new(0,16,0,16); af.ZIndex=5
    local arrow=Instance.new("ImageLabel",af); arrow.BackgroundTransparency=1
    arrow.Size=UDim2.new(1,0,1,0); arrow.Image="rbxassetid://6034818375"
    arrow.ImageColor3=C_ACCENT; arrow.ScaleType=Enum.ScaleType.Fit; arrow.Rotation=0; arrow.ZIndex=6
    local isOpen=true
    header.MouseButton1Click:Connect(function()
        isOpen=not isOpen
        TweenService:Create(arrow,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=isOpen and 0 or 180}):Play()
        for _,entry in ipairs(groupTabs) do
            TweenService:Create(entry.bg,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=isOpen and UDim2.new(1,0,0,36) or UDim2.new(1,0,0,0)}):Play()
            entry.bg.ClipsDescendants=true
        end
    end)
end

local function makeTab(cfg,groupTabs)
    layoutOrder+=1; local order=layoutOrder*100
    local bg=Instance.new("Frame",SideBar); bg.Name=cfg.key.."Tab"
    bg.BackgroundColor3=C_BG_HOV; bg.BackgroundTransparency=1; bg.BorderSizePixel=0
    bg.Size=UDim2.new(1,0,0,36); bg.LayoutOrder=order; bg.ZIndex=4; bg.ClipsDescendants=true
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,7)
    local bar=Instance.new("Frame",bg); bar.BackgroundColor3=C_ACCENT; bar.BorderSizePixel=0
    bar.Position=UDim2.new(0,0,0.2,0); bar.Size=UDim2.new(0,3,0.6,0); bar.Visible=false; bar.ZIndex=6
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,2)
    local icon,iconParts=createTabIcon(bg,cfg.key)
    local label=Instance.new("TextLabel",bg); label.BackgroundTransparency=1
    label.Position=UDim2.new(0,37,0,0); label.Size=UDim2.new(1,-42,1,0)
    label.Font=Enum.Font.GothamSemibold; label.Text=cfg.label; label.TextColor3=C_TEXT_OFF
    label.TextSize=11; label.TextXAlignment=Enum.TextXAlignment.Left
    label.TextTruncate=Enum.TextTruncate.AtEnd; label.ZIndex=6
    if cfg.trKey then trackLabel(label, cfg.trKey) end
    local btn=Instance.new("TextButton",bg); btn.BackgroundTransparency=1
    btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=7
    btn.MouseEnter:Connect(function() if currentTab~=cfg.key then TweenService:Create(bg,TweenInfo.new(0.15),{BackgroundTransparency=0.78}):Play() end end)
    btn.MouseLeave:Connect(function() if currentTab~=cfg.key then TweenService:Create(bg,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play() end end)
    btn.MouseButton1Click:Connect(function() selectTab(cfg.key) end)
    local entry={key=cfg.key,bg=bg,icon=icon,iconParts=iconParts,label=label,bar=bar}
    table.insert(allTabs,entry); table.insert(groupTabs,entry)
end

local keyMap={}
for _,t in ipairs(TabConfig) do keyMap[t.key]=t end
for _,g in ipairs(GroupConfig) do
    local groupTabs={}; makeGroupLabel(g.label, g.trKey, groupTabs)
    for _,k in ipairs(g.keys) do if keyMap[k] then makeTab(keyMap[k],groupTabs) end end
end

-- ══════════════════════════════════════════════════════
--  BOOST FUNCTIONS
-- ══════════════════════════════════════════════════════
do -- [[ BOOST SYSTEM ]]
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
        Notify.warn(T("boosterOn"), T("boosterOnMsg"), 4)
    else
        for obj,p in pairs(origMaterials) do pcall(function() if obj and obj.Parent then obj.Material=p.M; obj.Color=p.C; obj.Reflectance=p.R; obj.Transparency=p.T; obj.CastShadow=true end end) end
        for obj,t in pairs(origTextures) do pcall(function() if obj and obj.Parent then obj.Transparency=t end end) end
        origMaterials={}; origTextures={}
        Notify.info(T("boosterOff"), T("boosterOffMsg"))
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
        Notify.warn(T("remFxOn"), T("remFxOnMsg"))
    else
        for e,w in pairs(hidEffects) do pcall(function() if e and e.Parent then e.Enabled=w end end) end; hidEffects={}
        Notify.info(T("remFxOff"), T("remFxOffMsg"))
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
        Notify.warn(T("remNpcOn"), T("remNpcOnMsg"))
    else
        for p,d in pairs(hidNPCs) do pcall(function() if p and p.Parent then p.Transparency=d.T; p.CanCollide=d.CC end end) end; hidNPCs={}
        Notify.info(T("remNpcOff"), T("remNpcOffMsg"))
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
        Notify.warn(T("clearLagOn"), T("clearLagOnMsg"))
    else pcall(function()
        if origSet.Q then settings().Rendering.QualityLevel=origSet.Q end
        if origSet.M then settings().Rendering.MeshPartDetailLevel=origSet.M end
    end); origSet={}
        Notify.info(T("clearLagOff"), T("clearLagOffMsg"))
    end
end

-- ══════════════════════════════════════════════════════
--  BOOST POPUP
-- ══════════════════════════════════════════════════════
local BoostPopup=Instance.new("Frame",ScreenGui); BoostPopup.Name="BoostPopup"
BoostPopup.BackgroundColor3=Color3.fromRGB(28,29,34); BoostPopup.Size=UDim2.new(0,190,0,0)
BoostPopup.Visible=false; BoostPopup.ZIndex=200; BoostPopup.ClipsDescendants=true
Instance.new("UICorner",BoostPopup).CornerRadius=UDim.new(0,10)
local bpStroke=Instance.new("UIStroke",BoostPopup); bpStroke.Color=C_ACCENT; bpStroke.Thickness=1.2
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
    local row=Instance.new("Frame",BoostPopup); row.BackgroundColor3=Color3.fromRGB(38,41,48)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,32)
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lbl=Instance.new("TextLabel",row); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,8,0,0); lbl.Size=UDim2.new(1,-50,1,0); lbl.Font=Enum.Font.GothamSemibold
    lbl.Text=text; lbl.TextColor3=Color3.fromRGB(190,195,205); lbl.TextSize=10
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=201
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(60,65,75); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-42,0.5,-10); pill.Size=UDim2.new(0,36,0,20); pill.ZIndex=201
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(200,205,215); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,2,0.5,-8); knob.Size=UDim2.new(0,16,0,16); knob.ZIndex=202
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=203
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=state and Color3.fromRGB(87,242,135) or Color3.fromRGB(60,65,75)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.2),{Position=state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
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
FloatBtn.BackgroundColor3=Color3.fromRGB(12,13,20); FloatBtn.BorderSizePixel=0; FloatBtn.Visible=false; FloatBtn.ZIndex=100; FloatBtn.Active=true
Instance.new("UICorner",FloatBtn).CornerRadius=UDim.new(1,0)
local FloatRing=Instance.new("UIStroke",FloatBtn); FloatRing.Color=C_ACCENT; FloatRing.Thickness=2.2
local PDText=Instance.new("TextLabel",FloatBtn); PDText.BackgroundTransparency=1
PDText.Position=UDim2.new(0,0,0,0); PDText.Size=UDim2.new(1,0,1,0); PDText.Font=Enum.Font.GothamBlack
PDText.Text="PD"; PDText.TextColor3=Color3.fromRGB(220,225,255); PDText.TextSize=20; PDText.TextTransparency=0.05; PDText.ZIndex=105
local PDStroke=Instance.new("UIStroke",PDText); PDStroke.Color=C_ACCENT; PDStroke.Thickness=1.5; PDStroke.Transparency=0.3
local FloatClick=Instance.new("TextButton",FloatBtn); FloatClick.BackgroundTransparency=1
FloatClick.Size=UDim2.new(1,0,1,0); FloatClick.Text=""; FloatClick.ZIndex=110
FloatClick.MouseEnter:Connect(function() TweenService:Create(FloatRing,TweenInfo.new(0.2),{Color=Color3.fromRGB(160,170,255),Thickness=3}):Play() end)
FloatClick.MouseLeave:Connect(function() TweenService:Create(FloatRing,TweenInfo.new(0.2),{Color=C_ACCENT,Thickness=2.2}):Play() end)

local function showFloatBtn()
    FloatBtn.Size=UDim2.new(0,0,0,0); FloatBtn.Position=UDim2.new(0.05,34,0.08,34); FloatBtn.Visible=true
    TweenService:Create(FloatBtn,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,68,0,68),Position=UDim2.new(0.05,0,0.08,0)}):Play()
end

FloatClick.MouseButton1Click:Connect(function()
    TweenService:Create(FloatBtn,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.05,34,0.08,34)}):Play()
    task.delay(0.22,function()
        FloatBtn.Visible=false; FloatBtn.Size=UDim2.new(0,68,0,68); FloatBtn.Position=UDim2.new(0.05,0,0.08,0)
        MainFrame.Visible=true; MainFrame.Size=UDim2.new(0,540,0,0)
        TweenService:Create(MainFrame,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,540,0,370)}):Play()
        task.delay(0.2,function() SideBar.Visible=true; ContentArea.Visible=true; Divider.Visible=true; Footer.Visible=true end)
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
        TweenService:Create(MainFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Size=UDim2.new(0,540,0,40)}):Play()
    else
        TweenService:Create(MainFrame,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Size=UDim2.new(0,540,0,370)}):Play()
        task.delay(0.2,function()
            SideBar.Visible=true; ContentArea.Visible=true; Divider.Visible=true; Footer.Visible=true
        end)
    end
end)

local isMaximized=false; local normalPos=MainFrame.Position
TopBtns["Maximize"].MouseButton1Click:Connect(function()
    isMaximized=not isMaximized
    if isMaximized then
        normalPos=MainFrame.Position
        TweenService:Create(MainFrame,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{Size=UDim2.new(0,760,0,500),Position=UDim2.new(0.5,-380,0.5,-250)}):Play()
    else
        TweenService:Create(MainFrame,TweenInfo.new(0.3,Enum.EasingStyle.Quad),{Size=UDim2.new(0,540,0,370),Position=normalPos}):Play()
    end
end)

TopBtns["Close"].MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.new(0,540,0,0)}):Play()
    task.delay(0.22,function()
        MainFrame.Visible=false; MainFrame.Size=UDim2.new(0,540,0,370)
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
end -- [[ BOOST SYSTEM ]]

-- ABA INFO — includes notification toggle
-- ══════════════════════════════════════════════════════
do -- [[ INFO TAB ]]
local function copyToClipboard(text)
    pcall(function() if setclipboard then setclipboard(text) end end)
end


local infoCard=Instance.new("Frame",Pages["Info"])
infoCard.BackgroundColor3=Color3.fromRGB(30,31,34); infoCard.BorderSizePixel=0
infoCard.Size=UDim2.new(1,0,0,136); infoCard.LayoutOrder=0; infoCard.ZIndex=5
Instance.new("UICorner",infoCard).CornerRadius=UDim.new(0,10)
local infoCardStroke=Instance.new("UIStroke",infoCard); infoCardStroke.Color=Color3.fromRGB(55,58,66); infoCardStroke.Thickness=1.2

local infoBanner=Instance.new("Frame",infoCard)
infoBanner.BackgroundColor3=Color3.fromRGB(72,87,210); infoBanner.BorderSizePixel=0
infoBanner.Size=UDim2.new(1,0,0,52); infoBanner.ZIndex=5
Instance.new("UICorner",infoBanner).CornerRadius=UDim.new(0,10)
local banFix=Instance.new("Frame",infoBanner); banFix.BackgroundColor3=Color3.fromRGB(72,87,210)
banFix.BorderSizePixel=0; banFix.Position=UDim2.new(0,0,0.5,0); banFix.Size=UDim2.new(1,0,0.5,0); banFix.ZIndex=5
local bannerTitle=Instance.new("TextLabel",infoBanner)
bannerTitle.BackgroundTransparency=1; bannerTitle.Position=UDim2.new(0,62,0,0)
bannerTitle.Size=UDim2.new(1,-70,1,0); bannerTitle.Font=Enum.Font.GothamBlack
bannerTitle.Text="🌲  PudimHub"; bannerTitle.TextColor3=Color3.fromRGB(255,255,255)
bannerTitle.TextSize=14; bannerTitle.TextXAlignment=Enum.TextXAlignment.Left; bannerTitle.ZIndex=7

local infoAvatarRing=Instance.new("Frame",infoCard)
infoAvatarRing.BackgroundColor3=Color3.fromRGB(30,31,34); infoAvatarRing.BorderSizePixel=0
infoAvatarRing.Position=UDim2.new(0,8,0,30); infoAvatarRing.Size=UDim2.new(0,48,0,48); infoAvatarRing.ZIndex=7
Instance.new("UICorner",infoAvatarRing).CornerRadius=UDim.new(1,0)
local infoAvImg=Instance.new("ImageLabel",infoAvatarRing)
infoAvImg.BackgroundTransparency=1; infoAvImg.Position=UDim2.new(0,2,0,2); infoAvImg.Size=UDim2.new(1,-4,1,-4)
infoAvImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(Player.UserId).."&width=150&height=150&format=png"
infoAvImg.ZIndex=8; Instance.new("UICorner",infoAvImg).CornerRadius=UDim.new(1,0)

local infoGreenRing=Instance.new("Frame",infoCard)
infoGreenRing.BackgroundColor3=Color3.fromRGB(30,31,34); infoGreenRing.BorderSizePixel=0
infoGreenRing.Position=UDim2.new(0,42,0,64); infoGreenRing.Size=UDim2.new(0,14,0,14); infoGreenRing.ZIndex=9
Instance.new("UICorner",infoGreenRing).CornerRadius=UDim.new(1,0)
local infoGreenDot=Instance.new("Frame",infoGreenRing)
infoGreenDot.BackgroundColor3=Color3.fromRGB(87,242,135); infoGreenDot.BorderSizePixel=0
infoGreenDot.Position=UDim2.new(0,2,0,2); infoGreenDot.Size=UDim2.new(0,10,0,10); infoGreenDot.ZIndex=10
Instance.new("UICorner",infoGreenDot).CornerRadius=UDim.new(1,0)

local infoName=Instance.new("TextLabel",infoCard)
infoName.BackgroundTransparency=1; infoName.Position=UDim2.new(0,64,0,54)
infoName.Size=UDim2.new(1,-72,0,18); infoName.Font=Enum.Font.GothamBold
infoName.Text=Player.DisplayName; infoName.TextColor3=Color3.fromRGB(255,255,255)
infoName.TextSize=13; infoName.TextXAlignment=Enum.TextXAlignment.Left; infoName.ZIndex=7
local infoTag=Instance.new("TextLabel",infoCard)
infoTag.BackgroundTransparency=1; infoTag.Position=UDim2.new(0,64,0,72)
infoTag.Size=UDim2.new(1,-72,0,12); infoTag.Font=Enum.Font.Gotham
infoTag.Text="@"..Player.Name; infoTag.TextColor3=Color3.fromRGB(140,150,165)
infoTag.TextSize=10; infoTag.TextXAlignment=Enum.TextXAlignment.Left; infoTag.ZIndex=7

local infoStatus=Instance.new("Frame",infoCard)
infoStatus.BackgroundColor3=Color3.fromRGB(40,42,48); infoStatus.BorderSizePixel=0
infoStatus.Position=UDim2.new(0,8,0,90); infoStatus.Size=UDim2.new(1,-16,0,38); infoStatus.ZIndex=6
Instance.new("UICorner",infoStatus).CornerRadius=UDim.new(0,7)
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
infoStatusSub.TextColor3=Color3.fromRGB(120,130,145); infoStatusSub.TextSize=9
infoStatusSub.TextXAlignment=Enum.TextXAlignment.Left; infoStatusSub.ZIndex=7

-- ── Linha de idioma no painel Discord principal ──
local infoLangRow = Instance.new("Frame", infoCard)
infoLangRow.BackgroundColor3 = Color3.fromRGB(36,38,48)
infoLangRow.BackgroundTransparency = 0.35
infoLangRow.BorderSizePixel = 0
infoLangRow.Position = UDim2.new(0,8,0,136)
infoLangRow.Size = UDim2.new(1,-16,0,28)
infoLangRow.ZIndex = 6
Instance.new("UICorner",infoLangRow).CornerRadius = UDim.new(0,7)

local infoLangIcon = Instance.new("TextLabel",infoLangRow)
infoLangIcon.BackgroundTransparency=1; infoLangIcon.Position=UDim2.new(0,8,0,0)
infoLangIcon.Size=UDim2.new(0,20,1,0); infoLangIcon.Font=Enum.Font.GothamBold
infoLangIcon.Text="🌐"; infoLangIcon.TextSize=13; infoLangIcon.ZIndex=7

infoLangKeyLbl = Instance.new("TextLabel",infoLangRow)
infoLangKeyLbl.BackgroundTransparency=1; infoLangKeyLbl.Position=UDim2.new(0,30,0,0)
infoLangKeyLbl.Size=UDim2.new(0,55,1,0); infoLangKeyLbl.Font=Enum.Font.GothamBold
infoLangKeyLbl.Text="Idioma:"; infoLangKeyLbl.TextColor3=Color3.fromRGB(140,150,170)
infoLangKeyLbl.TextSize=10; infoLangKeyLbl.TextXAlignment=Enum.TextXAlignment.Left; infoLangKeyLbl.ZIndex=7

local infoLangValLbl = Instance.new("TextLabel",infoLangRow)
infoLangValLbl.BackgroundTransparency=1; infoLangValLbl.Position=UDim2.new(0,85,0,0)
infoLangValLbl.Size=UDim2.new(1,-95,1,0); infoLangValLbl.Font=Enum.Font.GothamBlack
infoLangValLbl.Text = currentLang.flag .. "  " .. currentLang.short
infoLangValLbl.TextColor3=Color3.fromRGB(88,101,242)
infoLangValLbl.TextSize=11; infoLangValLbl.TextXAlignment=Enum.TextXAlignment.Left; infoLangValLbl.ZIndex=7

-- Expande o infoCard para acomodar a linha de idioma
infoCard.Size = UDim2.new(1,0,0,172)

-- Registra referência para atualização de idioma
langInfoLabel = infoLangValLbl

-- ═══════════════════════════════════════
-- TOGGLE NOTIFICATIONS (Info tab, LO=1)
-- ═══════════════════════════════════════
local notifToggleRow = Instance.new("Frame", Pages["Info"])
notifToggleRow.BackgroundColor3   = Color3.fromRGB(22,24,32)
notifToggleRow.BorderSizePixel    = 0
notifToggleRow.Size               = UDim2.new(1,0,0,62)
notifToggleRow.LayoutOrder        = 1
notifToggleRow.ZIndex             = 5
Instance.new("UICorner", notifToggleRow).CornerRadius = UDim.new(0,10)
local ntStroke = Instance.new("UIStroke", notifToggleRow)
ntStroke.Color = Color3.fromRGB(88,101,242); ntStroke.Thickness = 1.5

-- Icon 🔔 on the left
local ntIconBg = Instance.new("Frame", notifToggleRow)
ntIconBg.BackgroundColor3   = Color3.fromRGB(88,101,242)
ntIconBg.BackgroundTransparency = 0.75
ntIconBg.BorderSizePixel    = 0
ntIconBg.Position           = UDim2.new(0,10,0.5,-18)
ntIconBg.Size               = UDim2.new(0,36,0,36)
ntIconBg.ZIndex             = 6
Instance.new("UICorner",ntIconBg).CornerRadius=UDim.new(1,0)
local ntIconLbl = Instance.new("TextLabel",ntIconBg)
ntIconLbl.BackgroundTransparency=1; ntIconLbl.Size=UDim2.new(1,0,1,0)
ntIconLbl.Font=Enum.Font.GothamBold; ntIconLbl.Text="🔔"; ntIconLbl.TextSize=18; ntIconLbl.ZIndex=7

-- Texts
local ntTitle = Instance.new("TextLabel",notifToggleRow)
ntTitle.BackgroundTransparency=1; ntTitle.Position=UDim2.new(0,56,0,10)
ntTitle.Size=UDim2.new(1,-110,0,18); ntTitle.Font=Enum.Font.GothamBlack
ntTitle.Text="Notifications"; ntTitle.TextColor3=Color3.fromRGB(220,225,240)
trackLabel(ntTitle, "notifTitle")
ntTitle.TextSize=12; ntTitle.TextXAlignment=Enum.TextXAlignment.Left; ntTitle.ZIndex=6

local ntDesc = Instance.new("TextLabel",notifToggleRow)
ntDesc.BackgroundTransparency=1; ntDesc.Position=UDim2.new(0,56,0,30)
ntDesc.Size=UDim2.new(1,-110,0,24); ntDesc.Font=Enum.Font.Gotham
ntDesc.Text="Enables/disables all hub notifications"; ntDesc.TextColor3=Color3.fromRGB(90,100,120)
trackLabel(ntDesc, "notifDesc")
ntDesc.TextSize=9; ntDesc.TextXAlignment=Enum.TextXAlignment.Left; ntDesc.TextWrapped=true; ntDesc.ZIndex=6

-- Pill toggle
local ntPill = Instance.new("Frame",notifToggleRow)
ntPill.BackgroundColor3 = Color3.fromRGB(88,101,242) -- starts ACTIVE (tealic green)
ntPill.BorderSizePixel    = 0
ntPill.Position           = UDim2.new(1,-58,0.5,-13)
ntPill.Size               = UDim2.new(0,48,0,26)
ntPill.ZIndex             = 7
Instance.new("UICorner",ntPill).CornerRadius=UDim.new(1,0)
local ntKnob = Instance.new("Frame",ntPill)
ntKnob.BackgroundColor3 = Color3.fromRGB(255,255,255); ntKnob.BorderSizePixel=0
ntKnob.Position = UDim2.new(1,-24,0.5,-11); ntKnob.Size=UDim2.new(0,22,0,22); ntKnob.ZIndex=8
Instance.new("UICorner",ntKnob).CornerRadius=UDim.new(1,0)

-- Status label (ON/OFF)
local ntStatusLbl = Instance.new("TextLabel",notifToggleRow)
ntStatusLbl.BackgroundTransparency=1; ntStatusLbl.Position=UDim2.new(1,-58,0,10)
ntStatusLbl.Size=UDim2.new(0,48,0,12); ntStatusLbl.Font=Enum.Font.GothamBold
ntStatusLbl.Text=T("notifOn"); ntStatusLbl.TextColor3=Color3.fromRGB(88,101,242)
ntStatusLbl.TextSize=8; ntStatusLbl.TextXAlignment=Enum.TextXAlignment.Center; ntStatusLbl.ZIndex=7

local ntBtn = Instance.new("TextButton",notifToggleRow)
ntBtn.BackgroundTransparency=1; ntBtn.Size=UDim2.new(1,0,1,0); ntBtn.Text=""; ntBtn.ZIndex=9
ntBtn.MouseButton1Click:Connect(function()
    notifEnabled = not notifEnabled
    local onColor   = Color3.fromRGB(88,101,242)
    local offColor  = Color3.fromRGB(45,50,62)
    TweenService:Create(ntPill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{
        BackgroundColor3 = notifEnabled and onColor or offColor
    }):Play()
    TweenService:Create(ntKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position = notifEnabled and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
        BackgroundColor3 = notifEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
    }):Play()
    TweenService:Create(ntStroke,TweenInfo.new(0.2),{
        Color = notifEnabled and onColor or Color3.fromRGB(55,58,66)
    }):Play()
    TweenService:Create(ntStatusLbl,TweenInfo.new(0.15),{
        TextColor3 = notifEnabled and onColor or Color3.fromRGB(100,110,130)
    }):Play()
    ntStatusLbl.Text = notifEnabled and T("notifOn") or T("notifOff")
    ntIconBg.BackgroundTransparency = notifEnabled and 0.75 or 0.9
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
infoSep.BackgroundColor3=Color3.fromRGB(50,54,65); infoSep.BorderSizePixel=0
infoSep.Size=UDim2.new(1,0,0,1); infoSep.LayoutOrder=2; infoSep.ZIndex=5

-- ══════════════════════════════════════════════════════
-- PAINEL DE HISTÓRICO DE NOTIFICAÇÕES (aba Info, LO=3)
-- ══════════════════════════════════════════════════════
local HIST_PANEL_CONTENT_H = 220  -- altura do conteúdo quando aberto

local histPanelOuter = Instance.new("Frame", Pages["Info"])
histPanelOuter.BackgroundColor3 = Color3.fromRGB(20,22,30)
histPanelOuter.BorderSizePixel  = 0
histPanelOuter.Size             = UDim2.new(1,0,0,44)
histPanelOuter.LayoutOrder      = 3
histPanelOuter.ZIndex           = 5
histPanelOuter.ClipsDescendants = true
Instance.new("UICorner",histPanelOuter).CornerRadius = UDim.new(0,10)
local histPanelStroke = Instance.new("UIStroke",histPanelOuter)
histPanelStroke.Color = Color3.fromRGB(88,101,242); histPanelStroke.Thickness=1.5

-- ── Header clicável ──
local histHeader = Instance.new("Frame", histPanelOuter)
histHeader.BackgroundColor3 = Color3.fromRGB(16,18,26)
histHeader.BorderSizePixel  = 0
histHeader.Size             = UDim2.new(1,0,0,44)
histHeader.ZIndex           = 6
Instance.new("UICorner",histHeader).CornerRadius = UDim.new(0,10)
local histHeaderFix = Instance.new("Frame",histHeader)
histHeaderFix.BackgroundColor3=Color3.fromRGB(16,18,26); histHeaderFix.BorderSizePixel=0
histHeaderFix.Position=UDim2.new(0,0,0.5,0); histHeaderFix.Size=UDim2.new(1,0,0.5,0); histHeaderFix.ZIndex=6

-- Ícone sino
local histHIconBg = Instance.new("Frame",histHeader)
histHIconBg.BackgroundColor3=Color3.fromRGB(88,101,242); histHIconBg.BackgroundTransparency=0.75
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
histHTitle.Text="Histórico de Notificações"; histHTitle.TextColor3=Color3.fromRGB(210,215,235)
trackLabel(histHTitle, "notifHistTitle")
histHTitle.TextSize=11; histHTitle.TextXAlignment=Enum.TextXAlignment.Left; histHTitle.ZIndex=7

-- Seta
local histHArrowFrame=Instance.new("Frame",histHeader)
histHArrowFrame.BackgroundTransparency=1; histHArrowFrame.Position=UDim2.new(1,-24,0.5,-8)
histHArrowFrame.Size=UDim2.new(0,16,0,16); histHArrowFrame.ZIndex=7
local histHArrow=Instance.new("ImageLabel",histHArrowFrame)
histHArrow.BackgroundTransparency=1; histHArrow.Size=UDim2.new(1,0,1,0)
histHArrow.Image="rbxassetid://6034818375"; histHArrow.ImageColor3=Color3.fromRGB(88,101,242)
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
histScroll.ScrollBarImageColor3  = Color3.fromRGB(88,101,242)
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
infoHistEmptyLbl.TextColor3=Color3.fromRGB(65,75,95); infoHistEmptyLbl.TextSize=10
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
        TweenService:Create(histPanelStroke,TweenInfo.new(0.2),{Color=open and Color3.fromRGB(130,145,255) or Color3.fromRGB(88,101,242)}):Play()
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
dadosHeader.BackgroundColor3=Color3.fromRGB(26,28,34); dadosHeader.BorderSizePixel=0
dadosHeader.Size=UDim2.new(1,0,0,32); dadosHeader.LayoutOrder=4; dadosHeader.Text=""; dadosHeader.ZIndex=5
Instance.new("UICorner",dadosHeader).CornerRadius=UDim.new(0,8)
local dadosStroke=Instance.new("UIStroke",dadosHeader); dadosStroke.Color=Color3.fromRGB(55,58,66); dadosStroke.Thickness=1

local dadosTitleLbl=Instance.new("TextLabel",dadosHeader)
dadosTitleLbl.BackgroundTransparency=1; dadosTitleLbl.Position=UDim2.new(0,12,0,0)
dadosTitleLbl.Size=UDim2.new(1,-40,1,0); dadosTitleLbl.Font=Enum.Font.GothamBold
dadosTitleLbl.Text="Dice"; dadosTitleLbl.TextColor3=Color3.fromRGB(180,185,200)
dadosTitleLbl.TextSize=11; dadosTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; dadosTitleLbl.ZIndex=6

local dadosArrowFrame=Instance.new("Frame",dadosHeader)
dadosArrowFrame.BackgroundTransparency=1; dadosArrowFrame.Position=UDim2.new(1,-28,0.5,-8)
dadosArrowFrame.Size=UDim2.new(0,16,0,16); dadosArrowFrame.ZIndex=6
local dadosArrow=Instance.new("ImageLabel",dadosArrowFrame)
dadosArrow.BackgroundTransparency=1; dadosArrow.Size=UDim2.new(1,0,1,0)
dadosArrow.Image="rbxassetid://6034818375"; dadosArrow.ImageColor3=Color3.fromRGB(130,140,160)
dadosArrow.ScaleType=Enum.ScaleType.Fit; dadosArrow.Rotation=180; dadosArrow.ZIndex=7

local dadosContent=Instance.new("Frame",Pages["Info"])
dadosContent.BackgroundColor3=Color3.fromRGB(22,24,30); dadosContent.BorderSizePixel=0
dadosContent.Size=UDim2.new(1,0,0,0); dadosContent.LayoutOrder=5; dadosContent.ZIndex=5
dadosContent.ClipsDescendants=true
Instance.new("UICorner",dadosContent).CornerRadius=UDim.new(0,8)
local dadosStroke2=Instance.new("UIStroke",dadosContent); dadosStroke2.Color=Color3.fromRGB(45,48,58); dadosStroke2.Thickness=1

local dadosPad=Instance.new("UIPadding",dadosContent)
dadosPad.PaddingTop=UDim.new(0,10); dadosPad.PaddingLeft=UDim.new(0,12)
dadosPad.PaddingRight=UDim.new(0,12); dadosPad.PaddingBottom=UDim.new(0,12)
local dadosList=Instance.new("UIListLayout",dadosContent)
dadosList.Padding=UDim.new(0,8); dadosList.SortOrder=Enum.SortOrder.LayoutOrder

local dadosText=Instance.new("TextLabel",dadosContent)
dadosText.BackgroundTransparency=1; dadosText.Size=UDim2.new(1,0,0,0)
dadosText.AutomaticSize=Enum.AutomaticSize.Y; dadosText.Font=Enum.Font.Gotham
dadosText.Text="This script was developed by only 1 person and is being developed by only 1 person as well. Sometimes it may take a while to update the script, sometimes it may be quick, and sometimes it may be very slow. However, I will always try to go as fast as possible, so the delay may be related to other factors. I just wanted to let you know this in case it is outdated and takes a while — this will give you a better idea of ​​the reason for the delay, because 1 person developing a script of this size ALONE is difficult and time-consuming, even with free time sometimes."
dadosText.TextColor3=Color3.fromRGB(160,168,185); dadosText.TextSize=9
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

makeDadosBtn(dadosBtnsRow,"🔗 Discord Link",Color3.fromRGB(88,101,242),function()
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
    TweenService:Create(dadosStroke,TweenInfo.new(0.2),{Color=dataOpen and C_ACCENT or Color3.fromRGB(55,58,66)}):Play()
end)

-- ══════════════════════════════════════════════════════
-- SISTEMA DE IDIOMAS — Seção dropdown na aba Info
-- ══════════════════════════════════════════════════════
local LANG_DROP_H = (#LANGUAGES * 38) + 16  -- altura do dropdown

local langSep=Instance.new("Frame",Pages["Info"])
langSep.BackgroundColor3=Color3.fromRGB(50,54,65); langSep.BorderSizePixel=0
langSep.Size=UDim2.new(1,0,0,1); langSep.LayoutOrder=6; langSep.ZIndex=5

-- Header clicável "Sistema de idiomas"
local langHeader=Instance.new("TextButton",Pages["Info"])
langHeader.BackgroundColor3=Color3.fromRGB(26,28,36); langHeader.BorderSizePixel=0
langHeader.Size=UDim2.new(1,0,0,40); langHeader.LayoutOrder=7; langHeader.Text=""; langHeader.ZIndex=5
Instance.new("UICorner",langHeader).CornerRadius=UDim.new(0,10)
local langHeaderStroke=Instance.new("UIStroke",langHeader)
langHeaderStroke.Color=Color3.fromRGB(88,101,242); langHeaderStroke.Thickness=1.5

-- Ícone globo
local lhIconBg=Instance.new("Frame",langHeader)
lhIconBg.BackgroundColor3=Color3.fromRGB(88,101,242); lhIconBg.BackgroundTransparency=0.75
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
lhTitleLbl.TextColor3=Color3.fromRGB(210,215,235); lhTitleLbl.TextSize=12
lhTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; lhTitleLbl.ZIndex=6

-- Label idioma atual
local lhCurrentLbl=Instance.new("TextLabel",langHeader)
lhCurrentLbl.BackgroundTransparency=1; lhCurrentLbl.Position=UDim2.new(1,-88,0,0)
lhCurrentLbl.Size=UDim2.new(0,60,1,0); lhCurrentLbl.Font=Enum.Font.GothamBold
lhCurrentLbl.Text=currentLang.flag.." "..currentLang.short
lhCurrentLbl.TextColor3=Color3.fromRGB(88,101,242); lhCurrentLbl.TextSize=10
lhCurrentLbl.TextXAlignment=Enum.TextXAlignment.Right; lhCurrentLbl.ZIndex=6

-- Seta
local lhArrowFrame=Instance.new("Frame",langHeader)
lhArrowFrame.BackgroundTransparency=1; lhArrowFrame.Position=UDim2.new(1,-26,0.5,-8)
lhArrowFrame.Size=UDim2.new(0,16,0,16); lhArrowFrame.ZIndex=6
local lhArrow=Instance.new("ImageLabel",lhArrowFrame)
lhArrow.BackgroundTransparency=1; lhArrow.Size=UDim2.new(1,0,1,0)
lhArrow.Image="rbxassetid://6034818375"; lhArrow.ImageColor3=Color3.fromRGB(88,101,242)
lhArrow.ScaleType=Enum.ScaleType.Fit; lhArrow.Rotation=180; lhArrow.ZIndex=7

-- Conteúdo dropdown (lista de idiomas)
local langDropContent=Instance.new("ScrollingFrame",Pages["Info"])
langDropContent.BackgroundColor3=Color3.fromRGB(20,22,30); langDropContent.BorderSizePixel=0
langDropContent.Size=UDim2.new(1,0,0,0); langDropContent.LayoutOrder=8; langDropContent.ZIndex=5
langDropContent.ClipsDescendants=true; langDropContent.ScrollBarThickness=3
langDropContent.ScrollBarImageColor3=Color3.fromRGB(88,101,242)
langDropContent.AutomaticCanvasSize=Enum.AutomaticSize.None
langDropContent.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",langDropContent).CornerRadius=UDim.new(0,10)
local ldStroke=Instance.new("UIStroke",langDropContent); ldStroke.Color=Color3.fromRGB(60,65,90); ldStroke.Thickness=1.2

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
    lBtn.BackgroundColor3=isSelected and Color3.fromRGB(88,101,242) or Color3.fromRGB(30,33,45)
    lBtn.BackgroundTransparency=isSelected and 0.25 or 0.15
    lBtn.BorderSizePixel=0; lBtn.Size=UDim2.new(1,0,0,34)
    lBtn.Text=""; lBtn.LayoutOrder=idx; lBtn.ZIndex=6
    Instance.new("UICorner",lBtn).CornerRadius=UDim.new(0,8)
    if isSelected then
        local lbStroke=Instance.new("UIStroke",lBtn); lbStroke.Color=Color3.fromRGB(88,101,242); lbStroke.Thickness=1.2
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
    lbName.Text=lang.name; lbName.TextColor3=isSelected and Color3.fromRGB(200,210,255) or Color3.fromRGB(180,188,210)
    lbName.TextSize=10; lbName.TextXAlignment=Enum.TextXAlignment.Left; lbName.ZIndex=7

    -- Código
    local lbCode=Instance.new("TextLabel",lBtn)
    lbCode.BackgroundTransparency=1; lbCode.Position=UDim2.new(1,-58,0,0)
    lbCode.Size=UDim2.new(0,50,1,0); lbCode.Font=Enum.Font.GothamBold
    lbCode.Text=lang.short; lbCode.TextColor3=isSelected and Color3.fromRGB(88,101,242) or Color3.fromRGB(90,100,125)
    lbCode.TextSize=9; lbCode.TextXAlignment=Enum.TextXAlignment.Right; lbCode.ZIndex=7

    lBtn.MouseEnter:Connect(function()
        if lang.code~=currentLang.code then
            TweenService:Create(lBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(50,55,75),BackgroundTransparency=0}):Play()
        end
    end)
    lBtn.MouseLeave:Connect(function()
        if lang.code~=currentLang.code then
            TweenService:Create(lBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(30,33,45),BackgroundTransparency=0.15}):Play()
        end
    end)
    lBtn.MouseButton1Click:Connect(function()
        -- Fecha o dropdown
        langDropOpen = false
        TweenService:Create(lhArrow,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=180}):Play()
        TweenService:Create(langDropContent,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Size=UDim2.new(1,0,0,0)}):Play()
        TweenService:Create(langHeaderStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(88,101,242)}):Play()
        -- Atualiza label do header imediatamente
        lhCurrentLbl.Text = lang.flag.." "..lang.short
        -- Aplica o idioma na hora, sem confirmação
        applyLanguage(lang)
        if langInfoLabel   then langInfoLabel.Text   = lang.flag.."  "..lang.short end
        if langFooterLabel then langFooterLabel.Text = lang.flag.." "..lang.short  end
        local T = TRANSLATIONS[lang.code] or TRANSLATIONS["PT-BR"]
        Notify.send({
            type="custom", icon=lang.flag,
            accent=Color3.fromRGB(88,101,242),
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
        TweenService:Create(langHeaderStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(130,145,255)}):Play()
        TweenService:Create(langDropContent,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,LANG_DROP_H)}):Play()
    else
        TweenService:Create(langHeaderStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(88,101,242)}):Play()
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
srvSep.BackgroundColor3=Color3.fromRGB(50,54,65); srvSep.BorderSizePixel=0
srvSep.Size=UDim2.new(1,0,0,1); srvSep.LayoutOrder=9; srvSep.ZIndex=5

local srvCard=Instance.new("Frame",Pages["Info"])
srvCard.BackgroundColor3=Color3.fromRGB(20,22,30); srvCard.BorderSizePixel=0
srvCard.Size=UDim2.new(1,0,0,102); srvCard.LayoutOrder=10; srvCard.ZIndex=5
Instance.new("UICorner",srvCard).CornerRadius=UDim.new(0,10)
local srvStroke=Instance.new("UIStroke",srvCard); srvStroke.Color=Color3.fromRGB(255,170,50); srvStroke.Thickness=1.5

local srvGlow=Instance.new("Frame",srvCard); srvGlow.BackgroundColor3=Color3.fromRGB(255,170,50)
srvGlow.BackgroundTransparency=0.93; srvGlow.BorderSizePixel=0; srvGlow.Size=UDim2.new(1,0,1,0); srvGlow.ZIndex=5
Instance.new("UICorner",srvGlow).CornerRadius=UDim.new(0,10)

local srvBar=Instance.new("Frame",srvCard); srvBar.BackgroundColor3=Color3.fromRGB(255,170,50)
srvBar.BorderSizePixel=0; srvBar.Size=UDim2.new(0,4,0.7,0); srvBar.Position=UDim2.new(0,0,0.15,0); srvBar.ZIndex=6
Instance.new("UICorner",srvBar).CornerRadius=UDim.new(0,2)

local srvIconBg=Instance.new("Frame",srvCard); srvIconBg.BackgroundColor3=Color3.fromRGB(255,170,50)
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
srvTitle.TextColor3=Color3.fromRGB(255,200,100); srvTitle.TextSize=12
srvTitle.TextXAlignment=Enum.TextXAlignment.Left; srvTitle.ZIndex=6

local srvSubTitle=Instance.new("TextLabel",srvCard); srvSubTitle.BackgroundTransparency=1
srvSubTitle.Position=UDim2.new(0,46,0,27); srvSubTitle.Size=UDim2.new(1,-56,0,12)
srvSubTitle.Font=Enum.Font.Gotham; srvSubTitle.Text="Cole o Job ID do servidor para tentar entrar"
trackLabel(srvSubTitle, "srvSub")
srvSubTitle.TextColor3=Color3.fromRGB(110,120,145); srvSubTitle.TextSize=9
srvSubTitle.TextXAlignment=Enum.TextXAlignment.Left; srvSubTitle.ZIndex=6

-- TextBox de ID
local srvBoxBg=Instance.new("Frame",srvCard); srvBoxBg.BackgroundColor3=Color3.fromRGB(28,32,42)
srvBoxBg.BorderSizePixel=0; srvBoxBg.Position=UDim2.new(0,10,0,48); srvBoxBg.Size=UDim2.new(1,-96,0,30)
srvBoxBg.ZIndex=6; Instance.new("UICorner",srvBoxBg).CornerRadius=UDim.new(0,8)
local srvBoxStroke=Instance.new("UIStroke",srvBoxBg); srvBoxStroke.Color=Color3.fromRGB(60,68,88); srvBoxStroke.Thickness=1.2

local srvBox=Instance.new("TextBox",srvBoxBg); srvBox.BackgroundTransparency=1
srvBox.Position=UDim2.new(0,10,0,0); srvBox.Size=UDim2.new(1,-12,1,0)
srvBox.Font=Enum.Font.GothamBold; srvBox.Text=""
srvBox.PlaceholderText="Cole o Job ID aqui..."; srvBox.PlaceholderColor3=Color3.fromRGB(70,80,105)
srvBox.TextColor3=Color3.fromRGB(200,210,235); srvBox.TextSize=10
srvBox.ClearTextOnFocus=false; srvBox.ZIndex=7

srvBox.Focused:Connect(function() TweenService:Create(srvBoxStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(255,170,50)}):Play() end)
srvBox.FocusLost:Connect(function() TweenService:Create(srvBoxStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(60,68,88)}):Play() end)

-- Botão conectar
local srvBtn=Instance.new("TextButton",srvCard); srvBtn.BackgroundColor3=Color3.fromRGB(255,170,50)
srvBtn.BackgroundTransparency=0.15; srvBtn.BorderSizePixel=0
srvBtn.Position=UDim2.new(1,-78,0,48); srvBtn.Size=UDim2.new(0,70,0,30)
srvBtn.Font=Enum.Font.GothamBold; srvBtn.Text="→ Ir"
trackLabel(srvBtn, "srvBtn")
srvBtn.TextColor3=Color3.fromRGB(255,255,255); srvBtn.TextSize=11; srvBtn.ZIndex=7
Instance.new("UICorner",srvBtn).CornerRadius=UDim.new(0,8)
local srvBtnStroke=Instance.new("UIStroke",srvBtn); srvBtnStroke.Color=Color3.fromRGB(255,200,100); srvBtnStroke.Thickness=1; srvBtnStroke.Transparency=0.5
srvBtn.MouseEnter:Connect(function() TweenService:Create(srvBtn,TweenInfo.new(0.1),{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(255,195,70)}):Play() end)
srvBtn.MouseLeave:Connect(function() TweenService:Create(srvBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.15,BackgroundColor3=Color3.fromRGB(255,170,50)}):Play() end)

-- Status label
local srvStatusLbl=Instance.new("TextLabel",srvCard); srvStatusLbl.BackgroundTransparency=1
srvStatusLbl.Position=UDim2.new(0,10,0,82); srvStatusLbl.Size=UDim2.new(1,-20,0,14)
srvStatusLbl.Font=Enum.Font.GothamBold; srvStatusLbl.Text=""
srvStatusLbl.TextColor3=Color3.fromRGB(255,200,100); srvStatusLbl.TextSize=9
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
    srvBtn.Text="⏳"; srvStatusLbl.Text=T("srvConnecting"); srvStatusLbl.TextColor3=Color3.fromRGB(255,200,100)
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
end -- [[ INFO TAB ]]

-- ══════════════════════════════════════════════════════
-- ABA STATUS — Painel de monitoramento em tempo real
-- ══════════════════════════════════════════════════════
do -- [[ STATUS TAB ]]

local statsLO=0
local function stLO() statsLO+=1; return statsLO end

-- ─── helpers visuais ───────────────────────────────
local function mkStatCard(parent, h, lo)
    local c=Instance.new("Frame",parent); c.BackgroundColor3=Color3.fromRGB(22,24,32)
    c.BorderSizePixel=0; c.Size=UDim2.new(1,0,0,h); c.LayoutOrder=lo; c.ZIndex=5
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,10)
    local s=Instance.new("UIStroke",c); s.Color=Color3.fromRGB(50,55,72); s.Thickness=1.2
    return c,s
end

local function mkLabel(parent,pos,size,text,font,size_,color,zidx)
    local l=Instance.new("TextLabel",parent); l.BackgroundTransparency=1
    l.Position=pos; l.Size=size; l.Font=font; l.Text=text
    l.TextColor3=color; l.TextSize=size_; l.TextXAlignment=Enum.TextXAlignment.Left
    l.ZIndex=zidx or 6; return l
end

local function mkAccentBar(parent,color)
    local b=Instance.new("Frame",parent); b.BackgroundColor3=color; b.BorderSizePixel=0
    b.Size=UDim2.new(0,3,0.6,0); b.Position=UDim2.new(0,0,0.2,0); b.ZIndex=6
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,2)
end

-- ─── Título da aba ──────────────────────────────────
local statsTitleCard,_=mkStatCard(Pages["Status"],42,stLO())
statsTitleCard.BackgroundColor3=Color3.fromRGB(16,18,26)
mkAccentBar(statsTitleCard,Color3.fromRGB(88,101,242))
local stMainTitle=mkLabel(statsTitleCard,UDim2.new(0,14,0,0),UDim2.new(1,-20,1,0),"📊  Monitor do Sistema",Enum.Font.GothamBlack,14,Color3.fromRGB(210,215,255))
stMainTitle.TextXAlignment=Enum.TextXAlignment.Left
local stLiveLbl=Instance.new("TextLabel",statsTitleCard); stLiveLbl.BackgroundTransparency=1
stLiveLbl.AnchorPoint=Vector2.new(1,0.5); stLiveLbl.Position=UDim2.new(1,-12,0.5,0); stLiveLbl.Size=UDim2.new(0,44,0,16)
stLiveLbl.Font=Enum.Font.GothamBold; stLiveLbl.Text="● LIVE"; stLiveLbl.TextColor3=Color3.fromRGB(87,242,135)
stLiveLbl.TextSize=9; stLiveLbl.ZIndex=6
-- pulsar o ponto
task.spawn(function()
    while true do
        task.wait(0.8)
        TweenService:Create(stLiveLbl,TweenInfo.new(0.4),{TextTransparency=0.5}):Play()
        task.wait(0.5)
        TweenService:Create(stLiveLbl,TweenInfo.new(0.4),{TextTransparency=0}):Play()
    end
end)

-- ═══════════════════════════════════════════════════
-- CARD 1 — FPS + PING
-- ═══════════════════════════════════════════════════
local fpsPingCard,fpsPingStroke=mkStatCard(Pages["Status"],78,stLO())
mkAccentBar(fpsPingCard,Color3.fromRGB(88,242,135))

-- FPS column
local fpsIconBg=Instance.new("Frame",fpsPingCard); fpsIconBg.BackgroundColor3=Color3.fromRGB(87,242,135)
fpsIconBg.BackgroundTransparency=0.82; fpsIconBg.BorderSizePixel=0
fpsIconBg.Position=UDim2.new(0,10,0,12); fpsIconBg.Size=UDim2.new(0,30,0,30); fpsIconBg.ZIndex=6
Instance.new("UICorner",fpsIconBg).CornerRadius=UDim.new(0,8)
local fpsIconLbl=Instance.new("TextLabel",fpsIconBg); fpsIconLbl.BackgroundTransparency=1
fpsIconLbl.Size=UDim2.new(1,0,1,0); fpsIconLbl.Font=Enum.Font.GothamBlack
fpsIconLbl.Text="⚡"; fpsIconLbl.TextSize=15; fpsIconLbl.ZIndex=7

mkLabel(fpsPingCard,UDim2.new(0,48,0,10),UDim2.new(0.42,0,0,14),"FPS",Enum.Font.GothamBold,9,Color3.fromRGB(120,130,155))
local fpsValLbl=mkLabel(fpsPingCard,UDim2.new(0,48,0,24),UDim2.new(0.42,0,0,24),"--",Enum.Font.GothamBlack,24,Color3.fromRGB(87,242,135))
local fpsBarBg=Instance.new("Frame",fpsPingCard); fpsBarBg.BackgroundColor3=Color3.fromRGB(28,32,42)
fpsBarBg.BorderSizePixel=0; fpsBarBg.Position=UDim2.new(0,48,0,54); fpsBarBg.Size=UDim2.new(0.42,-58,0,5); fpsBarBg.ZIndex=6
Instance.new("UICorner",fpsBarBg).CornerRadius=UDim.new(0,3)
local fpsBarFill=Instance.new("Frame",fpsBarBg); fpsBarFill.BackgroundColor3=Color3.fromRGB(87,242,135)
fpsBarFill.BorderSizePixel=0; fpsBarFill.Size=UDim2.new(0.5,0,1,0); fpsBarFill.ZIndex=7
Instance.new("UICorner",fpsBarFill).CornerRadius=UDim.new(0,3)
local fpsDescLbl=mkLabel(fpsPingCard,UDim2.new(0,48,0,62),UDim2.new(0.42,-58,0,12),"Frames por segundo",Enum.Font.Gotham,8,Color3.fromRGB(75,85,105))

-- Divisor vertical
local div1=Instance.new("Frame",fpsPingCard); div1.BackgroundColor3=Color3.fromRGB(40,45,60)
div1.BorderSizePixel=0; div1.AnchorPoint=Vector2.new(0.5,0.5)
div1.Position=UDim2.new(0.5,0,0.5,0); div1.Size=UDim2.new(0,1,0.7,0); div1.ZIndex=6

-- PING column
local pingIconBg=Instance.new("Frame",fpsPingCard); pingIconBg.BackgroundColor3=Color3.fromRGB(88,150,255)
pingIconBg.BackgroundTransparency=0.82; pingIconBg.BorderSizePixel=0
pingIconBg.Position=UDim2.new(0.5,8,0,12); pingIconBg.Size=UDim2.new(0,30,0,30); pingIconBg.ZIndex=6
Instance.new("UICorner",pingIconBg).CornerRadius=UDim.new(0,8)
local pingIconLbl=Instance.new("TextLabel",pingIconBg); pingIconLbl.BackgroundTransparency=1
pingIconLbl.Size=UDim2.new(1,0,1,0); pingIconLbl.Font=Enum.Font.GothamBlack
pingIconLbl.Text="📶"; pingIconLbl.TextSize=13; pingIconLbl.ZIndex=7

mkLabel(fpsPingCard,UDim2.new(0.5,46,0,10),UDim2.new(0.4,0,0,14),"PING",Enum.Font.GothamBold,9,Color3.fromRGB(120,130,155))
local pingValLbl=mkLabel(fpsPingCard,UDim2.new(0.5,46,0,24),UDim2.new(0.4,0,0,24),"-- ms",Enum.Font.GothamBlack,20,Color3.fromRGB(88,150,255))
local pingBarBg=Instance.new("Frame",fpsPingCard); pingBarBg.BackgroundColor3=Color3.fromRGB(28,32,42)
pingBarBg.BorderSizePixel=0; pingBarBg.Position=UDim2.new(0.5,46,0,54); pingBarBg.Size=UDim2.new(0.4,-56,0,5); pingBarBg.ZIndex=6
Instance.new("UICorner",pingBarBg).CornerRadius=UDim.new(0,3)
local pingBarFill=Instance.new("Frame",pingBarBg); pingBarFill.BackgroundColor3=Color3.fromRGB(88,150,255)
pingBarFill.BorderSizePixel=0; pingBarFill.Size=UDim2.new(0.3,0,1,0); pingBarFill.ZIndex=7
Instance.new("UICorner",pingBarFill).CornerRadius=UDim.new(0,3)
local pingDescLbl=mkLabel(fpsPingCard,UDim2.new(0.5,46,0,62),UDim2.new(0.4,-56,0,12),"Latência da rede",Enum.Font.Gotham,8,Color3.fromRGB(75,85,105))

-- ═══════════════════════════════════════════════════
-- CARD 2 — Hora local + Uptime
-- ═══════════════════════════════════════════════════
local timeCard,_=mkStatCard(Pages["Status"],58,stLO())
mkAccentBar(timeCard,Color3.fromRGB(255,200,50))

local timeIconBg=Instance.new("Frame",timeCard); timeIconBg.BackgroundColor3=Color3.fromRGB(255,200,50)
timeIconBg.BackgroundTransparency=0.82; timeIconBg.BorderSizePixel=0
timeIconBg.Position=UDim2.new(0,10,0,10); timeIconBg.Size=UDim2.new(0,28,0,28); timeIconBg.ZIndex=6
Instance.new("UICorner",timeIconBg).CornerRadius=UDim.new(0,8)
local timeIconLbl=Instance.new("TextLabel",timeIconBg); timeIconLbl.BackgroundTransparency=1
timeIconLbl.Size=UDim2.new(1,0,1,0); timeIconLbl.Font=Enum.Font.GothamBlack; timeIconLbl.Text="🕐"; timeIconLbl.TextSize=14; timeIconLbl.ZIndex=7

mkLabel(timeCard,UDim2.new(0,46,0,8),UDim2.new(0.42,0,0,12),"HORA LOCAL (estimada)",Enum.Font.GothamBold,8,Color3.fromRGB(120,130,155))
local timeValLbl=mkLabel(timeCard,UDim2.new(0,46,0,20),UDim2.new(0.44,0,0,20),"--:-- --",Enum.Font.GothamBlack,18,Color3.fromRGB(255,200,50))
local timeTzLbl=mkLabel(timeCard,UDim2.new(0,46,0,40),UDim2.new(0.44,0,0,12),"detectando fuso...",Enum.Font.Gotham,8,Color3.fromRGB(100,110,130))

local div2=Instance.new("Frame",timeCard); div2.BackgroundColor3=Color3.fromRGB(40,45,60)
div2.BorderSizePixel=0; div2.AnchorPoint=Vector2.new(0.5,0.5)
div2.Position=UDim2.new(0.5,0,0.5,0); div2.Size=UDim2.new(0,1,0.7,0); div2.ZIndex=6

mkLabel(timeCard,UDim2.new(0.5,8,0,8),UDim2.new(0.44,0,0,12),"UPTIME (sessão)",Enum.Font.GothamBold,8,Color3.fromRGB(120,130,155))
local uptimeValLbl=mkLabel(timeCard,UDim2.new(0.5,8,0,20),UDim2.new(0.44,0,0,20),"0m 0s",Enum.Font.GothamBlack,16,Color3.fromRGB(200,180,255))
local uptimeSubLbl=mkLabel(timeCard,UDim2.new(0.5,8,0,40),UDim2.new(0.44,0,0,12),"tempo nesta sessão",Enum.Font.Gotham,8,Color3.fromRGB(100,110,130))
local sessionStart=tick()

-- detectar offset UTC pelo nome da timezone do Lua (melhor esforço)
local function getLocalTimeStr()
    -- Usa os ticks do Roblox para estimar hora local
    -- Tenta detectar UTC offset via os.time vs tick baseline
    local utcNow = os.time()
    local utcH = math.floor((utcNow % 86400) / 3600)
    local utcM = math.floor((utcNow % 3600) / 60)
    local utcS = utcNow % 60
    return string.format("%02d:%02d:%02d UTC", utcH, utcM, utcS), "UTC (use horário local do dispositivo)"
end

-- ═══════════════════════════════════════════════════
-- CARD 3 — Info do servidor
-- ═══════════════════════════════════════════════════
local srvInfoCard,srvInfoStroke=mkStatCard(Pages["Status"],68,stLO())
mkAccentBar(srvInfoCard,Color3.fromRGB(255,120,50))

local srvInfoIconBg=Instance.new("Frame",srvInfoCard); srvInfoIconBg.BackgroundColor3=Color3.fromRGB(255,120,50)
srvInfoIconBg.BackgroundTransparency=0.82; srvInfoIconBg.BorderSizePixel=0
srvInfoIconBg.Position=UDim2.new(0,10,0,10); srvInfoIconBg.Size=UDim2.new(0,28,0,28); srvInfoIconBg.ZIndex=6
Instance.new("UICorner",srvInfoIconBg).CornerRadius=UDim.new(0,8)
local srvInfoIconLbl=Instance.new("TextLabel",srvInfoIconBg); srvInfoIconLbl.BackgroundTransparency=1
srvInfoIconLbl.Size=UDim2.new(1,0,1,0); srvInfoIconLbl.Font=Enum.Font.GothamBlack; srvInfoIconLbl.Text="🌐"; srvInfoIconLbl.TextSize=14; srvInfoIconLbl.ZIndex=7

mkLabel(srvInfoCard,UDim2.new(0,46,0,7),UDim2.new(1,-56,0,12),"SERVIDOR",Enum.Font.GothamBold,8,Color3.fromRGB(120,130,155))
local srvJobLbl=mkLabel(srvInfoCard,UDim2.new(0,46,0,19),UDim2.new(1,-56,0,14),"Job: "..game.JobId:sub(1,22).."...",Enum.Font.GothamSemibold,9,Color3.fromRGB(200,210,235))
local srvPlaceLbl=mkLabel(srvInfoCard,UDim2.new(0,46,0,33),UDim2.new(1,-56,0,12),"Place ID: "..tostring(game.PlaceId),Enum.Font.Gotham,9,Color3.fromRGB(150,160,185))
local srvRegionLbl=mkLabel(srvInfoCard,UDim2.new(0,46,0,46),UDim2.new(1,-56,0,12),"Região: detectando...",Enum.Font.Gotham,8,Color3.fromRGB(110,120,145))

-- tentar detectar região pelo ping
task.spawn(function()
    task.wait(2)
    pcall(function()
        local stats=game:GetService("Stats"); local ping=stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        local region="Desconhecida"
        if ping<50 then region="Possivelmente SA/BR"
        elseif ping<100 then region="Possivelmente NA"
        elseif ping<180 then region="Possivelmente EU/AS"
        else region="Alta latência" end
        srvRegionLbl.Text=T("stRegion")..region.." (~"..math.floor(ping).."ms)"
    end)
end)

-- ═══════════════════════════════════════════════════
-- CARD 4 — Jogadores no servidor
-- ═══════════════════════════════════════════════════
local plrCard,_=mkStatCard(Pages["Status"],44,stLO())
plrCard.Size=UDim2.new(1,0,0,44)  -- será expandido dinamicamente
mkAccentBar(plrCard,Color3.fromRGB(140,100,255))

local plrIconBg=Instance.new("Frame",plrCard); plrIconBg.BackgroundColor3=Color3.fromRGB(140,100,255)
plrIconBg.BackgroundTransparency=0.82; plrIconBg.BorderSizePixel=0
plrIconBg.Position=UDim2.new(0,10,0,8); plrIconBg.Size=UDim2.new(0,28,0,28); plrIconBg.ZIndex=6
Instance.new("UICorner",plrIconBg).CornerRadius=UDim.new(0,8)
local plrIconLbl=Instance.new("TextLabel",plrIconBg); plrIconLbl.BackgroundTransparency=1
plrIconLbl.Size=UDim2.new(1,0,1,0); plrIconLbl.Font=Enum.Font.GothamBlack; plrIconLbl.Text="👥"; plrIconLbl.TextSize=14; plrIconLbl.ZIndex=7

mkLabel(plrCard,UDim2.new(0,46,0,6),UDim2.new(0.6,0,0,12),"JOGADORES NO SERVIDOR",Enum.Font.GothamBold,8,Color3.fromRGB(120,130,155))
local plrCountLbl=mkLabel(plrCard,UDim2.new(0,46,0,18),UDim2.new(0.5,0,0,18),"0 / 0",Enum.Font.GothamBlack,16,Color3.fromRGB(140,100,255))

local plrMaxLbl=Instance.new("TextLabel",plrCard); plrMaxLbl.BackgroundTransparency=1
plrMaxLbl.AnchorPoint=Vector2.new(1,0); plrMaxLbl.Position=UDim2.new(1,-12,0,8); plrMaxLbl.Size=UDim2.new(0,70,0,14)
plrMaxLbl.Font=Enum.Font.GothamBold; plrMaxLbl.Text=T("stPlayersMax")..tostring(game.Players.MaxPlayers)
plrMaxLbl.TextColor3=Color3.fromRGB(90,100,120); plrMaxLbl.TextSize=9; plrMaxLbl.TextXAlignment=Enum.TextXAlignment.Right; plrMaxLbl.ZIndex=6

-- Lista de jogadores (scroll)
local plrListFrame=Instance.new("Frame",plrCard); plrListFrame.BackgroundTransparency=1
plrListFrame.BorderSizePixel=0; plrListFrame.Position=UDim2.new(0,8,0,44)
plrListFrame.Size=UDim2.new(1,-16,0,0); plrListFrame.ZIndex=6; plrListFrame.ClipsDescendants=false

local plrListLayout=Instance.new("UIListLayout",plrListFrame)
plrListLayout.Padding=UDim.new(0,3); plrListLayout.SortOrder=Enum.SortOrder.LayoutOrder

local plrRows={}  -- cache de rows por UserId

local function refreshPlayerList()
    -- Limpa rows removidas
    for uid,row in pairs(plrRows) do
        if not Players:GetPlayerByUserId(uid) then
            row:Destroy(); plrRows[uid]=nil
        end
    end
    -- Adiciona novos
    local allPlrs=Players:GetPlayers()
    for i,plr in ipairs(allPlrs) do
        if not plrRows[plr.UserId] then
            local row=Instance.new("Frame",plrListFrame)
            row.BackgroundColor3=Color3.fromRGB(26,28,38); row.BackgroundTransparency=0.2
            row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,34); row.LayoutOrder=i; row.ZIndex=7
            Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
            -- Avatar
            local avRing=Instance.new("Frame",row); avRing.BackgroundColor3=Color3.fromRGB(140,100,255)
            avRing.BackgroundTransparency=0.7; avRing.BorderSizePixel=0
            avRing.Position=UDim2.new(0,6,0.5,-13); avRing.Size=UDim2.new(0,26,0,26); avRing.ZIndex=8
            Instance.new("UICorner",avRing).CornerRadius=UDim.new(1,0)
            local avImg=Instance.new("ImageLabel",avRing); avImg.BackgroundTransparency=1
            avImg.Position=UDim2.new(0,2,0,2); avImg.Size=UDim2.new(1,-4,1,-4)
            avImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(plr.UserId).."&width=48&height=48&format=png"
            avImg.ZIndex=9; Instance.new("UICorner",avImg).CornerRadius=UDim.new(1,0)
            -- Online dot
            local dot=Instance.new("Frame",avRing); dot.BackgroundColor3=Color3.fromRGB(87,242,135)
            dot.BorderSizePixel=0; dot.AnchorPoint=Vector2.new(1,1)
            dot.Position=UDim2.new(1,2,1,2); dot.Size=UDim2.new(0,7,0,7); dot.ZIndex=10
            Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
            -- Nome
            local nameL=Instance.new("TextLabel",row); nameL.BackgroundTransparency=1
            nameL.Position=UDim2.new(0,38,0,4); nameL.Size=UDim2.new(1,-80,0,14)
            nameL.Font=Enum.Font.GothamBold; nameL.Text=plr.DisplayName
            nameL.TextColor3=Color3.fromRGB(220,225,245); nameL.TextSize=11
            nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=8
            -- @tag
            local tagL=Instance.new("TextLabel",row); tagL.BackgroundTransparency=1
            tagL.Position=UDim2.new(0,38,0,19); tagL.Size=UDim2.new(1,-80,0,11)
            tagL.Font=Enum.Font.Gotham; tagL.Text="@"..plr.Name
            tagL.TextColor3=Color3.fromRGB(90,100,120); tagL.TextSize=9
            tagL.TextXAlignment=Enum.TextXAlignment.Left; tagL.ZIndex=8
            -- Você badge
            if plr==Player then
                local youBadge=Instance.new("Frame",row); youBadge.BackgroundColor3=Color3.fromRGB(88,101,242)
                youBadge.BackgroundTransparency=0.5; youBadge.BorderSizePixel=0
                youBadge.AnchorPoint=Vector2.new(1,0.5); youBadge.Position=UDim2.new(1,-8,0.5,0)
                youBadge.Size=UDim2.new(0,26,0,14); youBadge.ZIndex=8
                Instance.new("UICorner",youBadge).CornerRadius=UDim.new(0,4)
                local youLbl=Instance.new("TextLabel",youBadge); youLbl.BackgroundTransparency=1
                youLbl.Size=UDim2.new(1,0,1,0); youLbl.Font=Enum.Font.GothamBold
                youLbl.Text=T("stPlayersYou"); youLbl.TextColor3=Color3.fromRGB(180,190,255); youLbl.TextSize=8; youLbl.ZIndex=9
            end
            plrRows[plr.UserId]=row
        end
    end
    -- Atualiza altura do card
    local n=#allPlrs
    plrCountLbl.Text=tostring(n).." / "..tostring(game.Players.MaxPlayers)
    local listH = n>0 and (n*37+4) or 0
    plrCard.Size=UDim2.new(1,0,0,44+listH)
    plrListFrame.Size=UDim2.new(1,-16,0,listH)
end

-- ═══════════════════════════════════════════════════
-- CARD 5 — Mini stats extras
-- ═══════════════════════════════════════════════════
local extrasCard,_=mkStatCard(Pages["Status"],64,stLO())
mkAccentBar(extrasCard,Color3.fromRGB(100,220,255))

-- Memória
local memIconBg=Instance.new("Frame",extrasCard); memIconBg.BackgroundColor3=Color3.fromRGB(100,220,255)
memIconBg.BackgroundTransparency=0.82; memIconBg.BorderSizePixel=0
memIconBg.Position=UDim2.new(0,10,0,10); memIconBg.Size=UDim2.new(0,28,0,28); memIconBg.ZIndex=6
Instance.new("UICorner",memIconBg).CornerRadius=UDim.new(0,8)
local memIconLbl=Instance.new("TextLabel",memIconBg); memIconLbl.BackgroundTransparency=1
memIconLbl.Size=UDim2.new(1,0,1,0); memIconLbl.Font=Enum.Font.GothamBlack; memIconLbl.Text="💾"; memIconLbl.TextSize=14; memIconLbl.ZIndex=7

mkLabel(extrasCard,UDim2.new(0,46,0,7),UDim2.new(0.44,0,0,12),"MEMÓRIA CLIENT",Enum.Font.GothamBold,8,Color3.fromRGB(120,130,155))
local memValLbl=mkLabel(extrasCard,UDim2.new(0,46,0,20),UDim2.new(0.44,0,0,18),"-- MB",Enum.Font.GothamBlack,16,Color3.fromRGB(100,220,255))
local memBarBg=Instance.new("Frame",extrasCard); memBarBg.BackgroundColor3=Color3.fromRGB(28,32,42)
memBarBg.BorderSizePixel=0; memBarBg.Position=UDim2.new(0,46,0,42); memBarBg.Size=UDim2.new(0.44,-56,0,4); memBarBg.ZIndex=6
Instance.new("UICorner",memBarBg).CornerRadius=UDim.new(0,2)
local memBarFill=Instance.new("Frame",memBarBg); memBarFill.BackgroundColor3=Color3.fromRGB(100,220,255)
memBarFill.BorderSizePixel=0; memBarFill.Size=UDim2.new(0.3,0,1,0); memBarFill.ZIndex=7
Instance.new("UICorner",memBarFill).CornerRadius=UDim.new(0,2)

local div3=Instance.new("Frame",extrasCard); div3.BackgroundColor3=Color3.fromRGB(40,45,60)
div3.BorderSizePixel=0; div3.AnchorPoint=Vector2.new(0.5,0.5)
div3.Position=UDim2.new(0.5,0,0.5,0); div3.Size=UDim2.new(0,1,0.7,0); div3.ZIndex=6

-- Objetos no workspace
mkLabel(extrasCard,UDim2.new(0.5,8,0,7),UDim2.new(0.44,0,0,12),"OBJETOS (workspace)",Enum.Font.GothamBold,8,Color3.fromRGB(120,130,155))
local objCountLbl=mkLabel(extrasCard,UDim2.new(0.5,8,0,20),UDim2.new(0.44,0,0,18),"--",Enum.Font.GothamBlack,16,Color3.fromRGB(255,180,80))
local objSubLbl=mkLabel(extrasCard,UDim2.new(0.5,8,0,40),UDim2.new(0.44,0,0,12),"instâncias visíveis",Enum.Font.Gotham,8,Color3.fromRGB(100,110,130))

-- ═══════════════════════════════════════════════════
-- LOOP DE ATUALIZAÇÃO (0.6s)
-- ═══════════════════════════════════════════════════
local fpsBuffer={}; local fpsBufMax=10
local lastFpsUpdate=tick(); local fpsFrameCount=0

-- Contador de frames
RunService.RenderStepped:Connect(function()
    fpsFrameCount=fpsFrameCount+1
end)

-- Loop principal
task.spawn(function()
    while true do
        task.wait(0.6)
        pcall(function()
            -- FPS
            local now=tick(); local elapsed=now-lastFpsUpdate
            if elapsed>0 then
                local fps=math.floor(fpsFrameCount/elapsed)
                fpsFrameCount=0; lastFpsUpdate=now
                table.insert(fpsBuffer,fps); if #fpsBuffer>fpsBufMax then table.remove(fpsBuffer,1) end
                local avg=0; for _,v in ipairs(fpsBuffer) do avg=avg+v end; avg=math.floor(avg/#fpsBuffer)
                fpsValLbl.Text=tostring(avg)
                local pct=math.clamp(avg/144,0,1)
                local fpsColor=pct>0.9 and Color3.fromRGB(87,242,135) or pct>0.5 and Color3.fromRGB(255,200,50) or Color3.fromRGB(255,80,80)
                fpsValLbl.TextColor3=fpsColor
                TweenService:Create(fpsBarFill,TweenInfo.new(0.4),{Size=UDim2.new(pct,0,1,0),BackgroundColor3=fpsColor}):Play()
                fpsDescLbl.Text=pct>0.9 and "Excelente" or pct>0.5 and "Bom" or "Baixo"
            end

            -- Ping
            local stats=game:GetService("Stats")
            local ping=math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            pingValLbl.Text=tostring(ping).." ms"
            local pPct=math.clamp(1-(ping/400),0,1)
            local pingColor=pPct>0.75 and Color3.fromRGB(88,150,255) or pPct>0.4 and Color3.fromRGB(255,200,50) or Color3.fromRGB(255,80,80)
            pingValLbl.TextColor3=pingColor
            TweenService:Create(pingBarFill,TweenInfo.new(0.4),{Size=UDim2.new(pPct,0,1,0),BackgroundColor3=pingColor}):Play()
            pingDescLbl.Text=pPct>0.75 and "Boa conexão" or pPct>0.4 and "Moderado" or "Conexão ruim"

            -- Hora UTC
            local hStr,tzStr=getLocalTimeStr()
            timeValLbl.Text=hStr; timeTzLbl.Text=tzStr

            -- Uptime
            local upElapsed=tick()-sessionStart
            local upM=math.floor(upElapsed/60); local upS=math.floor(upElapsed%60)
            if upM>=60 then
                uptimeValLbl.Text=string.format("%dh %dm",math.floor(upM/60),upM%60)
            else
                uptimeValLbl.Text=upM.."m "..upS.."s"
            end

            -- Memória
            local mem=math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb())
            memValLbl.Text=tostring(mem).." MB"
            local memPct=math.clamp(mem/2048,0,1)
            local memColor=memPct<0.4 and Color3.fromRGB(100,220,255) or memPct<0.7 and Color3.fromRGB(255,200,50) or Color3.fromRGB(255,80,80)
            memValLbl.TextColor3=memColor
            TweenService:Create(memBarFill,TweenInfo.new(0.4),{Size=UDim2.new(memPct,0,1,0),BackgroundColor3=memColor}):Play()

            -- Objetos workspace
            local objCount=0; pcall(function() objCount=#workspace:GetDescendants() end)
            objCountLbl.Text=tostring(objCount)

            -- Players
            refreshPlayerList()
        end)
    end
end)

-- Ouvir entrada/saída de jogadores para atualizar imediatamente
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayerList() end)
Players.PlayerRemoving:Connect(function(p)
    task.wait(0.1)
    if plrRows[p.UserId] then pcall(function() plrRows[p.UserId]:Destroy() end); plrRows[p.UserId]=nil end
    refreshPlayerList()
end)

-- Primeira carga
task.delay(0.5, function() refreshPlayerList() end)

end -- [[ STATUS TAB ]]

do -- [[ ESP + BRING ]]
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
    local function dk(f) f.BackgroundColor3=Color3.fromRGB(24,26,32); return f end
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
    local function dk(f) f.BackgroundColor3=Color3.fromRGB(20,22,28); return f end
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

-- ════════════════════════════════════════════════════════
-- ESP v4 SYSTEM — 20 categories
-- ════════════════════════════════════════════════════════
local EspCanvas = Instance.new("Frame", ScreenGui)
EspCanvas.BackgroundTransparency = 1; EspCanvas.Size = UDim2.new(1,0,1,0); EspCanvas.ZIndex = 1

local ESP_CATS = {
    {key="Players",      trLabel="espPlayersLabel",trDesc="espPlayersDesc",label="👤 Players",            cor=Color3.fromRGB(255,80,80),   tipo="player", alcance=math.huge, desc="Todos os players no servidor"},
    {key="Kids", trLabel="espKidsLabel",trDesc="espKidsDesc",label="👶 Lost Children", cor=Color3.fromRGB(100,220,255), tipo="entity", alcance=math.huge, desc="Lost Child 1/2/3/4 (Dino/Kraken/Squid/Koala Kid)",
     nomes={"Lost Child","LostChild","Lost Child 2","LostChild2","Lost Child 3","LostChild3","Lost Child 4","LostChild4",
            "Missing Child","MissingChild","Child","Kid",
            "Dino Kid","DinoKid","Kraken Kid","KrakenKid","Squid Kid","SquidKid","Koala Kid","KoalaKid"}},
    {key="Animais", trLabel="espAnimaisLabel",trDesc="espAnimaisDesc",label="🐾 Animals", cor=Color3.fromRGB(130,220,100), tipo="entity", alcance=700,
     desc="Bunny, Horse, Kiwi, Turkey, Wolf, Alpha Wolf, Bear, Polar Bear, Arctic Fox, Frog, Scorpion, Mammoth, Hellephant, Meteor Crab",
     nomes={
       -- Passivos
       "Bunny","Horse","Kiwi","Turkey","Kiwi Bird",
       -- Agressivos
       "Wolf","Alpha Wolf","AlphaWolf",
       "Bear","Polar Bear","PolarBear",
       "Arctic Fox","ArcticFox",
       "Frog","Blue Frog","Purple Frog","Green Frog","BlueFrog","PurpleFrog","GreenFrog",
       "Scorpion","Hellephant",
       "Meteor Crab","MeteorCrab","Lava Crab","LavaCrab",
       "Mammoth","Lava Mammoth","LavaMammoth",
     }},
    {key="Monstros",     trLabel="espMonstrosLabel",trDesc="espMonstrosDesc",label="💀 Monstros",            cor=Color3.fromRGB(255,50,50),   tipo="entity", alcance=math.huge, desc="The Deer, The Owl, The Ram",
     nomes={"The Deer","TheDeer","Deer",
             "The Owl","TheOwl","Owl",
             "The Ram","TheRam","Ram",
             "The Bat","TheBat","Bat"}},
    {key="Cultistas",    trLabel="espCultistasLabel",trDesc="espCultistasDesc",label="⚔️ Cultistas",           cor=Color3.fromRGB(195,60,200),  tipo="entity", alcance=math.huge, desc="Cultist, Crossbow, Juggernaut, King, Mega…",
     nomes={"Cultist","Axe Cultist","AxeCultist","Melee Cultist","MeleeCultist",
             "Crossbow Cultist","CrossbowCultist",
             "Juggernaut Cultist","JuggernautCultist","Juggernaut",
             "Cultist King","CultistKing",
             "Mega Cultist","MegaCultist"}},
    {key="Aliens",       trLabel="espAliensLabel",trDesc="espAliensDesc",label="👽 Aliens",              cor=Color3.fromRGB(60,255,200),  tipo="entity", alcance=700, desc="Alien, Elite Alien",
     nomes={"Alien","Elite Alien","EliteAlien","NormalAlien"}},
    {key="EspLog", trLabel="espLogLabel",trDesc="espLogDesc",label="🪵 Log", cor=Color3.fromRGB(190,130,60), tipo="item", alcance=400, desc="Log — main fuel", nomes={"Log"}},
    {key="EspCombustivel",trLabel="espCombustivelLabel",trDesc="espCombustivelDesc",label="🔥 Combustível", cor=Color3.fromRGB(255,120,30), tipo="item", alcance=400, desc="Coal, Biofuel, Fuel Canister, Oil Barrel…",
     nomes={"Coal","Biofuel","Oil Barrel","OilBarrel","Fuel Canister","FuelCanister","Purple Fur Tuft","PurpleFurTuft","Chair"}},
    {key="EspCarcacas", trLabel="espCarcacasLabel",trDesc="espCarcacasDesc",label="🦴 Carcasses", cor=Color3.fromRGB(180,100,50), tipo="item", alcance=350, desc="Wolf/Bear/PolarBear/Mammoth/Hellephant Corpse…",
     nomes={
       "Wolf Corpse","WolfCorpse","Alpha Wolf Corpse","AlphaWolfCorpse",
       "Bear Corpse","BearCorpse","Polar Bear Corpse","PolarBearCorpse",
       "Arctic Fox Corpse","ArcticFoxCorpse",
       "Mammoth Corpse","MammothCorpse","Lava Mammoth Corpse","LavaMammothCorpse",
       "Hellephant Corpse","HellephantCorpse",
       "Frog Corpse","FrogCorpse",
       "Scorpion Corpse","ScorpionCorpse",
       "Meteor Crab Corpse","MeteorCrabCorpse",
       "Bunny Corpse","BunnyCorpse","Turkey Corpse","TurkeyCorpse","Horse Corpse","HorseCorpse",
       "Cultist Corpse","CultistCorpse",
       "Crossbow Cultist Corpse","CrossbowCultistCorpse",
       "Juggernaut Cultist Corpse","JuggernautCultistCorpse",
       "Cultist King Corpse","CultistKingCorpse",
       "Alien Corpse","AlienCorpse","Elite Alien Corpse","EliteAlienCorpse",
     }},
    {key="EspSucata",    trLabel="espSucataLabel",trDesc="espSucataDesc",label="🔩 Sucata",              cor=Color3.fromRGB(155,210,255), tipo="item",   alcance=400, desc="Bolt, Sheet Metal, UFO Junk, Tyre…",
     nomes={"Bolt","Sheet Metal","SheetMetal",
             "UFO Junk","UFOJunk","UFO Component","UFOComponent","UFO Scrap","UFOScrap",
             "Broken Fan","BrokenFan","Old Radio","OldRadio","Broken Radio","BrokenRadio",
             "Broken Microwave","BrokenMicrowave","Tyre","Metal Chair","MetalChair",
             "Old Car Engine","OldCarEngine","Washing Machine","WashingMachine",
             "Cultist Experiment","CultistExperiment","Cultist Prototype","CultistPrototype",
             "Alien Junk","AlienJunk","Broken UFO Part","BrokenUFOPart"}},
    {key="EspMateriais", trLabel="espMateriaisLabel",trDesc="espMateriaisDesc",label="💎 Materiais", cor=Color3.fromRGB(220,175,255), tipo="item", alcance=400, desc="Cultist Gem, Forest Gem, Mossy Coin, Obsidiron…",
     nomes={"Cultist Gem","CultistGem",
             "Forest Gem","ForestGem","Forest Gem Fragment","ForestGemFragment","Gem of the Forest","Gem of the Forest Fragment",
             "Mossy Coin","MossyCoin","Flower","Sapling",
             "Sacrifice Totem","SacrificeTotem",
             "Meteor Shard","MeteorShard",
             "Gold Shard","GoldShard",
             "Raw Obsidiron Ore","RawObsidironOre",
             "Obsidiron Ingot","ObsidironIngot",
             "Scalding Obsidiron Ingot","ScaldingObsidironIngot",
             "Raw Obsidiron Ore Shard",
             "Feather","Alien Tech","AlienTech","Alien Energy","AlienEnergy"}},
    {key="EspComidas",   trLabel="espComidasLabel",trDesc="espComidasDesc",label="🍖 Comidas",             cor=Color3.fromRGB(255,115,165), tipo="item",   alcance=350, desc="Carrot, Corn, Berry, Steak, Ribs, Stew, Candy…",
     nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake",
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
    {key="EspPeixes", trLabel="espPeixesLabel",trDesc="espPeixesDesc",label="🐟 Peixes", cor=Color3.fromRGB(80,180,255), tipo="item", alcance=400, desc="Mackerel, Salmon, Clownfish, Shark, Lava Eel…",
     nomes={"Mackerel","Cooked Mackerel","CookedMackerel","Salmon","Cooked Salmon","CookedSalmon","Clownfish","Cooked Clownfish","CookedClownfish","Jellyfish","Char","Cooked Char","CookedChar","Eel","Cooked Eel","CookedEel","Swordfish","Cooked Swordfish","CookedSwordfish","Shark","Cooked Shark","CookedShark","Lava Eel","LavaEel","Cooked Lava Eel","CookedLavaEel","Lionfish","Cooked Lionfish","CookedLionfish"}},
    {key="EspSementes",  trLabel="espSementesLabel",trDesc="espSementesDesc",label="🌱 Sementes",            cor=Color3.fromRGB(135,245,115), tipo="item",   alcance=350, desc="Chili, Berry, Flower, Firefly, Dripleaf…",
     nomes={"Chili Seeds","ChiliSeeds",
             "Flower Seeds","FlowerSeeds",
             "Berry Seeds","BerrySeeds",
             "Apple Seeds","AppleSeeds",
             "Corn Seeds","CornSeeds",
             "Pumpkin Seeds","PumpkinSeeds",
             "Firefly Seeds","FireflySeeds",
             "Dripleaf Seeds","DripleafSeeds",
             "Moonflower Seeds","MoonflowerSeeds",
             "Stareweed Seeds","StareweedSeeds",
             "Cavevine Seeds","CavevineSeeds","Cave Vine Seeds","CaveVineSeeds",
             "Mandrake Seeds","MandrakeSeeds"}},
    {key="EspFerr", trLabel="espFerrLabel",trDesc="espFerrDesc",label="🪓 Tools & Bags", cor=Color3.fromRGB(255,200,55), tipo="item", alcance=500, desc="Axes, Sacks, Rods, Flutes, Armor…",
     nomes={
       "Old Sack","OldSack","Good Sack","GoodSack","Infernal Sack","InfernalSack","Giant Sack","GiantSack","Admin Sack","AdminSack",
       "Old Axe","OldAxe","Good Axe","GoodAxe","Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw","Admin Axe","AdminAxe",
       "Old Rod","OldRod","Good Rod","GoodRod","Strong Rod","StrongRod",
       "Old Taming Flute","Old Flute","OldFlute","Good Taming Flute","Good Flute","GoodFlute","Strong Taming Flute","Strong Flute","StrongFlute",
       "Old Flashlight","OldFlashlight","Strong Flashlight","StrongFlashlight",
       "Axe Trim Kit","AxeTrimKit","Armor Trim Kit","ArmorTrimKit",
       "Hammer","Paint Brush","PaintBrush","Watering Can","WateringCan",
       "Cultist Staff","CultistStaff",
       "Leather Body","LeatherBody","Leather Chestplate","LeatherChestplate",
       "Alien Armour","AlienArmour","Alien Armor","AlienArmor",
       "Frog Boots","FrogBoots","Poison Armour","PoisonArmour","Poison Armor","PoisonArmor",
       "Bone Armor","BoneArmor","Obsidiron Armor","ObsidironArmor",
     }},
    {key="EspArmas", trLabel="espArmasLabel",trDesc="espArmasDesc",label="⚔️ Armas", cor=Color3.fromRGB(255,70,70), tipo="item", alcance=500, desc="Spear, Crossbow, Ice Sword, Revolver, Rifle…",
     nomes={
       "Spear","Morningstar","Katana",
       "Laser Sword","LaserSword","Ice Sword","IceSword",
       "Trident","Poison Spear","PoisonSpear",
       "Infernal Sword","InfernalSword",
       "Obsidiron Hammer","ObsidironHammer",
       "Scythe","Vampire Scythe","VampireScythe",
       "Crossbow","Infernal Crossbow","InfernalCrossbow",
       "Bouncing Blade","BouncingBlade",
       "Revolver","Rifle","Tactical Shotgun","TacticalShotgun",
       "Ray Gun","RayGun","Laser Cannon","LaserCannon","Flamethrower",
       "Snowball","Frozen Shuriken","FrozenShuriken","Kunai",
       "Witch Potion","WitchPotion","Wildfire","Blowpipe","Air Rifle","AirRifle",
       "Bow","Hunting Bow","HuntingBow",
     }},
    {key="EspAmmo", trLabel="espAmmoLabel",trDesc="espAmmoDesc",label="🔫 Ammunition", cor=Color3.fromRGB(255,155,60), tipo="item", alcance=400, desc="Revolver Ammo, Rifle Ammo, Shotgun Ammo",
     nomes={"Revolver Ammo","RevolverAmmo","Rifle Ammo","RifleAmmo","Shotgun Ammo","ShotgunAmmo"}},
    {key="EspCura",      trLabel="espCuraLabel",trDesc="espCuraDesc",label="💊 Cura & Pelts",        cor=Color3.fromRGB(120,255,200), tipo="item",   alcance=450, desc="Bandage, Medkit, Wolf Pelt, Bear Pelt…",
     nomes={"Bandage","Medkit",
             "Bunny Foot","BunnyFoot",
             "Wolf Pelt","WolfPelt","Alpha Wolf Pelt","AlphaWolfPelt",
             "Bear Pelt","BearPelt","Polar Bear Pelt","PolarBearPelt",
             "Arctic Fox Pelt","ArcticFoxPelt",
             "Mammoth Tusk","MammothTusk",
             "Scorpion Shell","ScorpionShell",
             "Cultist King Antler","CultistKingAntler",
             "Frog Scale","FrogScale","Frog Skin","FrogSkin",
             "Hellephant Tusk","HellephantTusk"}},
    {key="EspChaves",    trLabel="espChavesLabel",trDesc="espChavesDesc",label="🗝️ Chaves",              cor=Color3.fromRGB(255,230,80),  tipo="item",   alcance=math.huge, desc="Red, Blue, Yellow, Grey, Frog Key",
     nomes={"Red Key","RedKey","Blue Key","BlueKey","Yellow Key","YellowKey","Grey Key","GreyKey","Frog Key","FrogKey"}},
    {key="EspBigorna", trLabel="espBigornaLabel",trDesc="espBigornaDesc",label="⚙️ Anvil Parts", cor=Color3.fromRGB(200,160,255), tipo="item", alcance=math.huge, desc="Anvil Front/Back/Base + Meteor Anvil",
     nomes={"Anvil Front","AnvilFront","Anvil Back","AnvilBack","Anvil Base","AnvilBase","Meteor Anvil Front","MeteorAnvilFront","Meteor Anvil Back","MeteorAnvilBack","Meteor Anvil Base","MeteorAnvilBase"}},
    {key="EspPocoes",    trLabel="espPocoesLabel",trDesc="espPocoesDesc",label="🧪 Poções",              cor=Color3.fromRGB(195,100,255), tipo="item",   alcance=400, desc="Dripleaf, Moonflower Bulb, Stareweed Petal…",
     nomes={"Dripleaf","Moonflower Bulb","MoonflowerBulb",
             "Stareweed Petal","StareweedPetal",
             "Cave Vine Flower","CaveVineFlower","CaveVine Flower","Cavevine Flower",
             "Mandrake","Mandrake Root","MandrakeRoot",
             "Firefly","Glowing Mushroom","GlowingMushroom"}},
    {key="EspBlueprint", trLabel="espBlueprintLabel",trDesc="espBlueprintDesc",label="📋 Blueprints",          cor=Color3.fromRGB(130,190,255), tipo="item",   alcance=500, desc="Crafting, Defense, Furniture, Obsidiron Chest…",
     nomes={"Crafting Blueprint","CraftingBlueprint","Defense Blueprint","DefenseBlueprint","Furniture Blueprint","FurnitureBlueprint","Obsidiron Chest Blueprint","ObsidironChestBlueprint","Halloween Blueprint","HalloweenBlueprint"}},
}

local espAtivo={}
for _,c in ipairs(ESP_CATS) do espAtivo[c.key]=false end
local espLookup={}
for _,c in ipairs(ESP_CATS) do
    if c.nomes then local s={}; for _,n in ipairs(c.nomes) do s[n:lower()]=true end; espLookup[c.key]=s end
end

local POOL_SIZE=120; local labelPool={}; local activeList={}
local function newLabel()
    local f=Instance.new("Frame",EspCanvas); f.BackgroundTransparency=1; f.BorderSizePixel=0
    f.Size=UDim2.new(0,210,0,30); f.Visible=false; f.ZIndex=10
    local bg=Instance.new("Frame",f); bg.BackgroundColor3=Color3.fromRGB(6,8,14)
    bg.BackgroundTransparency=0.3; bg.BorderSizePixel=0; bg.Size=UDim2.new(1,0,1,0); bg.ZIndex=10
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,5)
    local n=Instance.new("TextLabel",f); n.Name="NL"; n.BackgroundTransparency=1
    n.Position=UDim2.new(0,6,0,2); n.Size=UDim2.new(1,-8,0,14); n.Font=Enum.Font.GothamBold
    n.TextSize=11; n.TextXAlignment=Enum.TextXAlignment.Left; n.TextStrokeTransparency=0.1
    n.TextStrokeColor3=Color3.new(0,0,0); n.TextTruncate=Enum.TextTruncate.AtEnd; n.ZIndex=12
    local d=Instance.new("TextLabel",f); d.Name="DL"; d.BackgroundTransparency=1
    d.Position=UDim2.new(0,6,0,16); d.Size=UDim2.new(1,-8,0,11); d.Font=Enum.Font.Gotham
    d.TextSize=9; d.TextColor3=Color3.fromRGB(170,185,210); d.TextXAlignment=Enum.TextXAlignment.Left
    d.TextStrokeTransparency=0.2; d.TextStrokeColor3=Color3.new(0,0,0); d.ZIndex=12
    return f
end
for i=1,POOL_SIZE do table.insert(labelPool,newLabel()) end

local function showLabel(cor,nome,dist,sx,sy)
    local f=table.remove(labelPool); if not f then return end
    f.Position=UDim2.new(0,sx-105,0,sy-15); f.Visible=true
    local nl=f:FindFirstChild("NL"); local dl=f:FindFirstChild("DL")
    if nl then nl.Text=nome; nl.TextColor3=cor end
    if dl then dl.Text=string.format("%.0f m",dist) end
    table.insert(activeList,f)
end
local function releaseAll()
    for _,f in ipairs(activeList) do f.Visible=false; table.insert(labelPool,f) end; activeList={}
end

local entityCache={}; local itemCache={}; local cacheBuilding=false; local lastCache=0; local CACHE_INTER=1.5
local function isAlive(model)
    local hum=model:FindFirstChildWhichIsA("Humanoid"); if not hum then return false end
    if hum.Health<=0 then return false end
    local hrp=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChildWhichIsA("BasePart")
    if not hrp then return false end
    local ok, pos = pcall(function() return hrp.Position end)
    if not ok then return false end
    if pos.Y < -500 then return false end
    return true
end
local function anyEspActive(tipo)
    for _,c in ipairs(ESP_CATS) do if espAtivo[c.key] and c.tipo==tipo then return true end end; return false
end

-- Lookup por partial match: verifica se o nome do obj contém algum nome da lista
local function matchEspCat(nameL, catKey)
    local lk = espLookup[catKey]
    if not lk then return false end
    -- Exact match primeiro (mais rápido)
    if lk[nameL] then return true end
    -- Partial match: "alpha wolf model" contém "alpha wolf"
    for kName, _ in pairs(lk) do
        if nameL:find(kName, 1, true) then return true end
    end
    return false
end
local function buildCache()
    if cacheBuilding then return end; local now=tick(); if now-lastCache<CACHE_INTER then return end
    lastCache=now; cacheBuilding=true
    task.spawn(function()
        local newEnt={}; local newItem={}
        local doEnt=anyEspActive("entity"); local doItem=anyEspActive("item")
        if not doEnt and not doItem then entityCache=newEnt; itemCache=newItem; cacheBuilding=false; return end
        local ok,descs=pcall(function() return workspace:GetDescendants() end)
        if not ok then cacheBuilding=false; return end
        local pchars={}; for _,pl in ipairs(Players:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end
        -- Scan direto de workspace.Characters (mais confiável para mobs)
        local extraEnts = {}
        pcall(function()
            local charFolder = workspace:FindFirstChild("Characters")
            if charFolder then
                for _, ch in ipairs(charFolder:GetChildren()) do
                    if ch:IsA("Model") and not pchars[ch] then table.insert(extraEnts, ch) end
                end
            end
            -- Também escaneia workspace diretamente para mobs no root
            for _, ch in ipairs(workspace:GetChildren()) do
                if ch:IsA("Model") and not pchars[ch] and ch:FindFirstChildWhichIsA("Humanoid") then
                    table.insert(extraEnts, ch)
                end
            end
        end)
        local batch=0
        local allObjs = {}
        for _,o in ipairs(descs) do table.insert(allObjs, o) end
        for _,o in ipairs(extraEnts) do table.insert(allObjs, o) end
        local seen_ent = {}
        for _,obj in ipairs(allObjs) do
            batch+=1; if batch%80==0 then task.wait() end
            if not obj or not obj.Parent then continue end
            local nl=obj.Name:lower()
            if doEnt and obj:IsA("Model") then
                local objId = tostring(obj)
                if not pchars[obj] and not seen_ent[objId] and isAlive(obj) then
                    seen_ent[objId] = true
                    for _,c in ipairs(ESP_CATS) do
                        if espAtivo[c.key] and c.tipo=="entity" then
                            if matchEspCat(nl, c.key) then
                                local hrp=obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChildWhichIsA("BasePart")
                                if hrp then table.insert(newEnt,{key=c.key,cor=c.cor,nome=obj.Name,alcance=c.alcance,obj=obj,hrp=hrp}) end
                                break
                            end
                        end
                    end
                end
            elseif doItem and obj:IsA("BasePart") then
                if not pchars[obj] then
                    local isNPC=false; local p=obj.Parent
                    for _=1,3 do if p and p:IsA("Model") and p:FindFirstChildWhichIsA("Humanoid") then isNPC=true; break end; p=p and p.Parent end
                    if not isNPC then
                        for _,c in ipairs(ESP_CATS) do
                            if espAtivo[c.key] and c.tipo=="item" then
                                if matchEspCat(nl, c.key) then
                                    table.insert(newItem,{key=c.key,cor=c.cor,nome=obj.Name,alcance=c.alcance,obj=obj}); break
                                end
                            end
                        end
                    end
                end
            elseif doItem and obj:IsA("Model") and not obj:FindFirstChildWhichIsA("Humanoid") then
                if not pchars[obj] then
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        for _,c in ipairs(ESP_CATS) do
                            if espAtivo[c.key] and c.tipo=="item" then
                                if matchEspCat(nl, c.key) then
                                    table.insert(newItem,{key=c.key,cor=c.cor,nome=obj.Name,alcance=c.alcance,obj=part}); break
                                end
                            end
                        end
                    end
                end
            end
        end
        entityCache=newEnt; itemCache=newItem; cacheBuilding=false
    end)
end

local dtAcc=0; local RENDER_I=1/20
RunService.Heartbeat:Connect(function(dt)
    dtAcc+=dt; if dtAcc<RENDER_I then return end; dtAcc=0
    releaseAll()
    local qualquer=false; for _,c in ipairs(ESP_CATS) do if espAtivo[c.key] then qualquer=true; break end end
    if not qualquer then return end
    pcall(buildCache)
    local charPos=Vector3.zero
    pcall(function() local ch=Player.Character; if ch and ch:FindFirstChild("HumanoidRootPart") then charPos=ch.HumanoidRootPart.Position end end)
    local vp=Cam.ViewportSize; local seen={}
    if espAtivo["Players"] then
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=Player and pl.Character then
                pcall(function()
                    local hrp=pl.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                    local hum=pl.Character:FindFirstChildWhichIsA("Humanoid"); if not hum or hum.Health<=0 then return end
                    local dist=(hrp.Position-charPos).Magnitude
                    local sp,vis=Cam:WorldToViewportPoint(hrp.Position+Vector3.new(0,3,0))
                    if not vis or sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
                    local cell=math.floor(sp.X/12)..","..math.floor(sp.Y/12)
                    if seen[cell] then return end; seen[cell]=true
                    showLabel(Color3.fromRGB(255,80,80),pl.DisplayName,dist,sp.X,sp.Y)
                end)
            end
        end
    end
    for _,e in ipairs(entityCache) do
        pcall(function()
            if not espAtivo[e.key] or not e.obj or not e.obj.Parent then return end
            local hum=e.obj:FindFirstChildWhichIsA("Humanoid"); if not hum or hum.Health<=0 then return end
            local pos=e.hrp.Position; local dist=(pos-charPos).Magnitude; if dist>e.alcance then return end
            local sp,vis=Cam:WorldToViewportPoint(pos+Vector3.new(0,2.5,0))
            if not vis or sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
            -- Usa divisor menor (4px) para não colapsar mobs próximos; entidades sempre mostram
            local cell=math.floor(sp.X/4)..","..math.floor(sp.Y/4)
            if seen[cell] then return end; seen[cell]=true
            showLabel(e.cor,e.nome,dist,sp.X,sp.Y)
        end)
    end
    for _,e in ipairs(itemCache) do
        pcall(function()
            if not espAtivo[e.key] or not e.obj or not e.obj.Parent then return end
            local pos=e.obj.Position; local dist=(pos-charPos).Magnitude; if dist>e.alcance then return end
            local sp,vis=Cam:WorldToViewportPoint(pos+Vector3.new(0,0.8,0))
            if not vis or sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
            local cell=math.floor(sp.X/10)..","..math.floor(sp.Y/10)
            if seen[cell] then return end; seen[cell]=true
            showLabel(e.cor,e.nome,dist,sp.X,sp.Y)
        end)
    end
end)

-- UI ESP
local espTabLO=0
local function espLO() espTabLO+=1; return espTabLO end
local function makeEspSection ( titleKey , cor )
    local hdr=Instance.new("Frame",Pages["Esp"]); hdr.BackgroundColor3=Color3.fromRGB(20,22,30)
    hdr.BackgroundTransparency=0.3; hdr.BorderSizePixel=0; hdr.Size=UDim2.new(1,0,0,22); hdr.LayoutOrder=espLO(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",hdr); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Position=UDim2.new(0,0,0,0); bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=5
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,0)
    lbl.Size=UDim2.new(1,-14,1,0); lbl.Font=Enum.Font.GothamBlack
    lbl.TextColor3=cor; lbl.TextSize=9; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    TL(lbl, titleKey)  -- auto-tracked for language switching
end

local function makeEspRow(cat)
    local row=Instance.new("Frame",Pages["Esp"]); row.BackgroundColor3=Color3.fromRGB(30,32,38)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,54); row.LayoutOrder=espLO(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local rowStroke=Instance.new("UIStroke",row); rowStroke.Color=Color3.fromRGB(45,48,58); rowStroke.Thickness=1
    local iconContainer=Instance.new("Frame",row); iconContainer.BackgroundColor3=Color3.fromRGB(20,22,30)
    iconContainer.BackgroundTransparency=0.3; iconContainer.BorderSizePixel=0
    iconContainer.Position=UDim2.new(0,8,0.5,-16); iconContainer.Size=UDim2.new(0,32,0,32); iconContainer.ZIndex=6
    Instance.new("UICorner",iconContainer).CornerRadius=UDim.new(0,7)
    local miniIcon=criarIconeEsp(iconContainer,cat.key,cat.cor)
    miniIcon.Position=UDim2.new(0,9,0,9); miniIcon.Size=UDim2.new(0,14,0,14)
    local labelNome=Instance.new("TextLabel",row); labelNome.BackgroundTransparency=1
    labelNome.Position=UDim2.new(0,50,0,8); labelNome.Size=UDim2.new(1,-110,0,16)
    labelNome.Font=Enum.Font.GothamBold; labelNome.Text=cat.label; labelNome.TextColor3=Color3.fromRGB(220,225,240)
    labelNome.TextSize=11; labelNome.TextXAlignment=Enum.TextXAlignment.Left; labelNome.ZIndex=6
    if cat.trLabel then TL(labelNome, cat.trLabel) end
    local labelDesc=Instance.new("TextLabel",row); labelDesc.BackgroundTransparency=1
    labelDesc.Position=UDim2.new(0,50,0,26); labelDesc.Size=UDim2.new(1,-110,0,20)
    labelDesc.Font=Enum.Font.Gotham; labelDesc.Text=cat.desc or ""; labelDesc.TextColor3=Color3.fromRGB(90,100,120)
    labelDesc.TextSize=9; labelDesc.TextXAlignment=Enum.TextXAlignment.Left; labelDesc.TextWrapped=true; labelDesc.ZIndex=6
    if cat.trDesc then TL(labelDesc, cat.trDesc) end
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(45,50,62); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-52,0.5,-11); pill.Size=UDim2.new(0,42,0,22); pill.ZIndex=7
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(160,170,185); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,2,0.5,-9); knob.Size=UDim2.new(0,18,0,18); knob.ZIndex=8
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=9
    btn.MouseEnter:Connect(function() if currentTab~=cat.key then TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(34,37,45)}):Play() end end)
    btn.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(30,32,38)}):Play() end)
    btn.MouseButton1Click:Connect(function()
        state=not state; espAtivo[cat.key]=state; lastCache=0
        TweenService:Create(pill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundColor3=state and cat.cor or Color3.fromRGB(45,50,62)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
            BackgroundColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185),
        }):Play()
        TweenService:Create(rowStroke,TweenInfo.new(0.2),{Color=state and cat.cor or Color3.fromRGB(45,48,58)}):Play()
        if state then
            Notify.info(T("espOn"), cat.label)
        else
            Notify.info(T("espOff"), cat.label)
        end
    end)
end

local espCatMap={}; for _,c in ipairs(ESP_CATS) do espCatMap[c.key]=c end
local espGroupOrder={
    {"espGroupEntities", Color3.fromRGB(88,101,242), {"Players","Kids","Animais","Monstros","Cultistas","Aliens"}},
    {"espGroupResources", Color3.fromRGB(255,130,40), {"EspLog","EspCombustivel","EspCarcacas","EspSucata","EspMateriais"}},
    {"espGroupFood", Color3.fromRGB(255,120,170), {"EspComidas","EspPeixes","EspSementes","EspPocoes"}},
    {"espGroupEquipment", Color3.fromRGB(255,200,55), {"EspFerr","EspArmas","EspAmmo","EspCura","EspChaves","EspBigorna","EspBlueprint"}},
}
for _,grp in ipairs(espGroupOrder) do
    local titleKey,cor,keys=grp[1],grp[2],grp[3]
    makeEspSection(titleKey,cor)
    for _,k in ipairs(keys) do if espCatMap[k] then makeEspRow(espCatMap[k]) end end
end

-- ════════════════════════════════════════════════════════
-- BRING SYSTEM v4
-- ════════════════════════════════════════════════════════
local BRING_CATS = {
    {key="BLog", trLabel="bLogLabel", trDesc="bLogDesc", label="🪵 Bring Log", cor=Color3.fromRGB(190,130,60), desc="Only gets: Log", nomes={"Log"}},
    {key="BCombust",  trLabel="bCombustLabel", trDesc="bCombustDesc", label="🔥 Bring Combustível", cor=Color3.fromRGB(255,120,30),  desc="Coal, Biofuel, Fuel Canister, Oil Barrel, Chair…",
     nomes={"Coal","Biofuel","Oil Barrel","OilBarrel","Fuel Canister","FuelCanister","Chair"}},
    {key="BCarcacas", trLabel="bCarcacasLabel", trDesc="bCarcacasDesc", label="🦴 Bring Carcaças",    cor=Color3.fromRGB(180,100,50),  desc="Wolf, Bear, PolarBear, Hellephant, Frog, Alien Corpse…",
     nomes={
       "Wolf Corpse","WolfCorpse","Alpha Wolf Corpse","AlphaWolfCorpse",
       "Bear Corpse","BearCorpse","Polar Bear Corpse","PolarBearCorpse",
       "Arctic Fox Corpse","ArcticFoxCorpse",
       "Mammoth Corpse","MammothCorpse","Lava Mammoth Corpse","LavaMammothCorpse",
       "Hellephant Corpse","HellephantCorpse",
       "Frog Corpse","FrogCorpse",
       "Scorpion Corpse","ScorpionCorpse",
       "Meteor Crab Corpse","MeteorCrabCorpse",
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
             "Alien Junk","AlienJunk"}},
    {key="BMateriais",trLabel="bMateriaisLabel",trDesc="bMateriaisDesc",label="💎 Bring Materiais",   cor=Color3.fromRGB(220,175,255), desc="Cultist Gem, Forest Gem, Mossy Coin…",
     nomes={"Cultist Gem","CultistGem","Forest Gem","ForestGem","Forest Gem Fragment","ForestGemFragment",
             "Gem of the Forest","Gem of the Forest Fragment",
             "Mossy Coin","MossyCoin","Flower","Sapling","Sacrifice Totem","SacrificeTotem",
             "Meteor Shard","MeteorShard","Gold Shard","GoldShard",
             "Raw Obsidiron Ore","RawObsidironOre","Obsidiron Ingot","ObsidironIngot",
             "Scalding Obsidiron Ingot","Feather","Alien Tech","AlienTech"}},
    {key="BComidas",  trLabel="bComidasLabel",trDesc="bComidasDesc",label="🍖 Bring Comidas",     cor=Color3.fromRGB(255,115,165), desc="Carrot, Corn, Steak, Ribs, Stew, Candy…",
     nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake",
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
    {key="BFerr", trLabel="bFerrLabel",trDesc="bFerrDesc",label="🪓 Bring Ferramentas", cor=Color3.fromRGB(255,200,55), desc="Sacks, Axes, Rods, Flutes, Armaduras...",
     nomes={"Old Sack","OldSack","Good Sack","GoodSack","Infernal Sack","InfernalSack","Giant Sack","GiantSack","Old Axe","OldAxe","Good Axe","GoodAxe","Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw","Old Rod","OldRod","Good Rod","GoodRod","Strong Rod","StrongRod","Old Taming Flute","OldFlute","Good Taming Flute","GoodFlute","Strong Taming Flute","StrongFlute","Old Flashlight","OldFlashlight","Strong Flashlight","StrongFlashlight","Axe Trim Kit","AxeTrimKit","Armor Trim Kit","ArmorTrimKit","Hammer","Paint Brush","PaintBrush","Watering Can","WateringCan","Leather Body","LeatherBody","Alien Armour","AlienArmour","Frog Boots","FrogBoots","Poison Armour","PoisonArmour"}},
    {key="BArmas",    trLabel="bArmasLabel",trDesc="bArmasDesc",label="⚔️ Bring Armas",       cor=Color3.fromRGB(255,70,70),   desc="Spear, Ice Sword, Crossbow, Revolver, Rifle, Cultist King Mace…",
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
     }},
    {key="BAmmo", trLabel="bAmmoLabel",trDesc="bAmmoDesc",label="🔫 Bring Ammunition", cor=Color3.fromRGB(255,155,60), desc="Revolver Ammo, Rifle Ammo, Shotgun Ammo",
     nomes={"Revolver Ammo","RevolverAmmo","Rifle Ammo","RifleAmmo","Shotgun Ammo","ShotgunAmmo"}},
    {key="BCura",     trLabel="bCuraLabel",trDesc="bCuraDesc",label="💊 Bring Cura",        cor=Color3.fromRGB(100,255,180), desc="Bandage, Medkit", nomes={"Bandage","Medkit"}},
    {key="BPelts",    trLabel="bPeltsLabel",trDesc="bPeltsDesc",label="🦺 Bring Pelts",       cor=Color3.fromRGB(210,170,120), desc="Bunny Foot, Wolf Pelt, Bear Pelt, Arctic Fox, Scorpion Shell, Mammoth Tusk, Cultist King Antler…",
     nomes={"Bunny Foot","BunnyFoot","Wolf Pelt","WolfPelt","Alpha Wolf Pelt","AlphaWolfPelt",
             "Bear Pelt","BearPelt","Polar Bear Pelt","PolarBearPelt","Arctic Fox Pelt","ArcticFoxPelt",
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
    {key="BBlueprint",trLabel="bBlueprintLabel",trDesc="bBlueprintDesc",label="📋 Bring Blueprints",  cor=Color3.fromRGB(130,190,255), desc="Crafting, Defense, Furniture, Obsidiron Chest…",
     nomes={"Crafting Blueprint","CraftingBlueprint","Defense Blueprint","DefenseBlueprint","Furniture Blueprint","FurnitureBlueprint","Obsidiron Chest Blueprint","ObsidironChestBlueprint","Halloween Blueprint","HalloweenBlueprint"}},
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
            if e.obj and e.obj.Parent then
                -- Restaura para posição VERDADEIRA original (antes do 1º bring)
                local trueOrigin = getTrueOrigin(e.obj) or e.originalCFrame
                e.obj.CFrame = trueOrigin
                e.obj.Velocity = Vector3.zero
                if e.modelParts then
                    for _, mp in ipairs(e.modelParts) do
                        pcall(function()
                            if mp.bp and mp.bp.Parent then
                                local mpTrue = getTrueOrigin(mp.bp) or mp.originalCF
                                mp.bp.CFrame = mpTrue
                                mp.bp.Velocity = Vector3.zero
                            end
                        end)
                    end
                end
                clearTrueOrigin(e.obj)
                restored += 1
            end
        end)
    end
    bringHistory[key] = {}
    return restored
end

local function limparBringAll()
    local restored = 0
    for _, e in ipairs(bringAllHistory) do
        pcall(function()
            if e.obj and e.obj.Parent then
                local trueOrigin = getTrueOrigin(e.obj) or e.originalCFrame
                e.obj.CFrame = trueOrigin
                e.obj.Velocity = Vector3.zero
                clearTrueOrigin(e.obj)
                restored += 1
            end
        end)
    end
    bringAllHistory = {}
    return restored
end

local function executarBring(key)
    local char=Player.Character; if not char then return 0 end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return 0 end
    local lookup=bringLookup[key]; if not lookup then return 0 end
    local cf=hrp.CFrame; local count=0; local trazidos={}; local batch=0
    bringHistory[key] = {}
    local pchars={}; for _,pl in ipairs(Players:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end
    local ok,descs=pcall(function() return workspace:GetDescendants() end); if not ok then return 0 end

    -- Aguarda 2 segundos antes de iniciar (solicitado pelo usuário)
    task.wait(2)

    -- Re-verifica personagem após o delay
    char=Player.Character; if not char then return 0 end
    hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return 0 end
    cf=hrp.CFrame

    -- Coleta os objetos elegíveis primeiro
    local eligiveis = {}
    for _,obj in ipairs(descs) do
        batch+=1
        if batch%120==0 then
            task.wait()
            char=Player.Character; if not char then break end
            hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then break end; cf=hrp.CFrame
        end
        pcall(function()
            if not obj or not obj.Parent then return end
            local targetPart = nil
            local checkName = nil
            local savedModelParts = nil
            if obj:IsA("BasePart") then
                targetPart = obj
                checkName = obj.Name:lower()
            elseif obj:IsA("Model") and not obj:FindFirstChildWhichIsA("Humanoid") then
                local p2 = obj:FindFirstChildWhichIsA("BasePart")
                if p2 then
                    targetPart = p2; checkName = obj.Name:lower()
                    savedModelParts = {}
                    for _,bp in ipairs(obj:GetDescendants()) do
                        if bp:IsA("BasePart") and bp ~= p2 then
                            table.insert(savedModelParts, {bp=bp, originalCF=bp.CFrame})
                        end
                    end
                end
            end
            if not targetPart or not checkName then return end
            for pc in pairs(pchars) do if pc==obj or (pc.Parent and pc:IsAncestorOf(obj)) then return end end
            local p=obj.Parent
            for _=1,3 do if p and p:IsA("Model") and p:FindFirstChildWhichIsA("Humanoid") then return end; p=p and p.Parent end
            if not lookup[checkName] then return end
            local sz=targetPart.Size; if sz.X>14 or sz.Y>14 or sz.Z>14 then return end
            table.insert(eligiveis, {obj=obj, targetPart=targetPart, checkName=checkName, savedModelParts=savedModelParts})
        end)
    end

    -- Teleporta com ângulo distribuído uniformemente (não amontoado)
    local total = #eligiveis
    for i, entry in ipairs(eligiveis) do
        local obj         = entry.obj
        local targetPart  = entry.targetPart
        local savedModelParts = entry.savedModelParts

        pcall(function()
            if not targetPart or not targetPart.Parent then return end

            char = Player.Character; if not char then return end
            hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            cf   = hrp.CFrame

            local originalCF = targetPart.CFrame
            saveTrueOrigin(targetPart, originalCF)
            if savedModelParts then
                for _, mp in ipairs(savedModelParts) do
                    saveTrueOrigin(mp.bp, mp.originalCF)
                end
            end

            -- Espalha em círculo AMPLO ao redor do jogador
            -- Distribuição uniforme: ângulo baseado no índice
            local angle  = (i / math.max(total, 1)) * math.pi * 2
            -- Raio variado: itens mais próximos ao centro, mais distantes na borda
            local radius = 2.5 + math.random() * 3.5  -- 2.5 a 6 studs
            local offsetX = math.cos(angle) * radius
            local offsetZ = math.sin(angle) * radius

            -- Posição NO CHÃO: usa Y do personagem - 2.5 (nível dos pés)
            -- O item cai naturalmente pela física
            local groundY = cf.Position.Y - 2.5
            local target  = cf.Position + Vector3.new(offsetX, groundY - cf.Position.Y + 0.5, offsetZ)
            -- Alternativa mais robusta: posição relativa ao personagem ao nível dos pés
            target = Vector3.new(cf.Position.X + offsetX, cf.Position.Y - 2.5, cf.Position.Z + offsetZ)

            -- Desativa scripts locais do item
            for _,s in ipairs(obj:GetDescendants()) do
                if s:IsA("Script") or s:IsA("LocalScript") then
                    pcall(function() s.Disabled=true end)
                end
            end

            -- Posiciona o item SOLTO no chão
            targetPart.CFrame    = CFrame.new(target)
            targetPart.Velocity  = Vector3.zero
            targetPart.RotVelocity = Vector3.zero
            pcall(function() targetPart.CanCollide = true end)

            -- Para modelos com múltiplas peças, mantém agrupadas próximo ao targetPart
            if obj:IsA("Model") and savedModelParts then
                for _,bp in ipairs(obj:GetDescendants()) do
                    if bp:IsA("BasePart") and bp ~= targetPart then
                        pcall(function()
                            bp.CFrame = CFrame.new(target + Vector3.new(
                                (math.random()-0.5)*0.3, 0, (math.random()-0.5)*0.3))
                            bp.Velocity = Vector3.zero
                        end)
                    end
                end
            end

            count+=1
            local histEntry = {obj=targetPart, originalCFrame=originalCF, pos=target, modelParts=savedModelParts}
            table.insert(trazidos, histEntry)
            table.insert(bringHistory[key], histEntry)
        end)
    end

    -- NÃO re-ancora itens — deixa a física do Roblox agir (eles caem no chão naturalmente)
    return count
end

local bringTabLO=0
local function bringLO() bringTabLO+=1; return bringTabLO end
local function makeBringSection(trKey, cor)
    local hdr=Instance.new("Frame",Pages["Bring"]); hdr.BackgroundColor3=Color3.fromRGB(20,22,30)
    hdr.BackgroundTransparency=0.3; hdr.BorderSizePixel=0; hdr.Size=UDim2.new(1,0,0,22); hdr.LayoutOrder=bringLO(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",hdr); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Position=UDim2.new(0,0,0,0); bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=5
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,0)
    lbl.Size=UDim2.new(1,-14,1,0); lbl.Font=Enum.Font.GothamBlack
    lbl.TextColor3=cor; lbl.TextSize=9; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    TL(lbl, trKey)
end

local function makeBringRow(bcat)
    local row=Instance.new("Frame",Pages["Bring"]); row.BackgroundColor3=Color3.fromRGB(28,30,36)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,82); row.LayoutOrder=bringLO(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local rowStroke=Instance.new("UIStroke",row); rowStroke.Color=Color3.fromRGB(42,46,56); rowStroke.Thickness=1
    local gradBg=Instance.new("Frame",row); gradBg.BackgroundColor3=bcat.cor; gradBg.BackgroundTransparency=0.9
    gradBg.BorderSizePixel=0; gradBg.Size=UDim2.new(1,0,1,0); gradBg.ZIndex=5
    Instance.new("UICorner",gradBg).CornerRadius=UDim.new(0,9)
    local iconBox=Instance.new("Frame",row); iconBox.BackgroundColor3=bcat.cor; iconBox.BackgroundTransparency=0.78
    iconBox.BorderSizePixel=0; iconBox.Position=UDim2.new(0,8,0.5,-18); iconBox.Size=UDim2.new(0,36,0,36); iconBox.ZIndex=7
    Instance.new("UICorner",iconBox).CornerRadius=UDim.new(0,8)
    local icon=criarIconeBring(iconBox,bcat.key,bcat.cor); icon.Position=UDim2.new(0,4,0,4); icon.Size=UDim2.new(0,28,0,28)
    local barLeft=Instance.new("Frame",row); barLeft.BackgroundColor3=bcat.cor; barLeft.BorderSizePixel=0
    barLeft.Position=UDim2.new(0,0,0.15,0); barLeft.Size=UDim2.new(0,3,0.7,0); barLeft.ZIndex=8
    Instance.new("UICorner",barLeft).CornerRadius=UDim.new(0,2)
    local labelNome=Instance.new("TextLabel",row); labelNome.BackgroundTransparency=1
    labelNome.Position=UDim2.new(0,54,0,10); labelNome.Size=UDim2.new(1,-168,0,18)
    labelNome.Font=Enum.Font.GothamBold; labelNome.Text=bcat.label; labelNome.TextColor3=Color3.fromRGB(225,230,245)
    labelNome.TextSize=11; labelNome.TextXAlignment=Enum.TextXAlignment.Left; labelNome.ZIndex=7
    if bcat.trLabel then TL(labelNome, bcat.trLabel) end
    local labelDesc=Instance.new("TextLabel",row); labelDesc.BackgroundTransparency=1
    labelDesc.Position=UDim2.new(0,54,0,30); labelDesc.Size=UDim2.new(1,-168,0,24)
    labelDesc.Font=Enum.Font.Gotham; labelDesc.Text=bcat.desc or ""; labelDesc.TextColor3=Color3.fromRGB(90,100,120)
    labelDesc.TextSize=9; labelDesc.TextXAlignment=Enum.TextXAlignment.Left; labelDesc.TextWrapped=true; labelDesc.ZIndex=7
    if bcat.trDesc then TL(labelDesc, bcat.trDesc) end
    local feedbackLbl=Instance.new("TextLabel",row); feedbackLbl.BackgroundTransparency=1
    feedbackLbl.Position=UDim2.new(1,-90,0,62); feedbackLbl.Size=UDim2.new(0,82,0,12)
    feedbackLbl.Font=Enum.Font.Gotham; feedbackLbl.Text=""; feedbackLbl.TextColor3=bcat.cor
    feedbackLbl.TextSize=8; feedbackLbl.TextXAlignment=Enum.TextXAlignment.Center; feedbackLbl.ZIndex=8

    -- Botão BRING
    local btnBring=Instance.new("TextButton",row); btnBring.BackgroundColor3=bcat.cor; btnBring.BackgroundTransparency=0.15
    btnBring.BorderSizePixel=0; btnBring.Position=UDim2.new(1,-90,0,8); btnBring.Size=UDim2.new(0,82,0,28)
    btnBring.Font=Enum.Font.GothamBold; btnBring.Text=T("bringBtnLabel"); btnBring.TextColor3=Color3.fromRGB(255,255,255)
    btnBring.TextSize=10; btnBring.ZIndex=9
    Instance.new("UICorner",btnBring).CornerRadius=UDim.new(0,7)
    local btnStroke=Instance.new("UIStroke",btnBring); btnStroke.Color=bcat.cor; btnStroke.Thickness=1.2; btnStroke.Transparency=0.5
    btnBring.MouseEnter:Connect(function() TweenService:Create(btnBring,TweenInfo.new(0.12),{BackgroundTransparency=0,Size=UDim2.new(0,82,0,30),Position=UDim2.new(1,-90,0,7)}):Play() end)
    btnBring.MouseLeave:Connect(function() TweenService:Create(btnBring,TweenInfo.new(0.12),{BackgroundTransparency=0.15,Size=UDim2.new(0,82,0,28),Position=UDim2.new(1,-90,0,8)}):Play() end)

    -- Botão LIMPAR
    local btnLimpar=Instance.new("TextButton",row); btnLimpar.BackgroundColor3=Color3.fromRGB(55,60,80); btnLimpar.BackgroundTransparency=0.1
    btnLimpar.BorderSizePixel=0; btnLimpar.Position=UDim2.new(1,-90,0,42); btnLimpar.Size=UDim2.new(0,82,0,24)
    btnLimpar.Font=Enum.Font.GothamBold; btnLimpar.Text="🗑 Limpar"; btnLimpar.TextColor3=Color3.fromRGB(180,190,220)
    btnLimpar.TextSize=9; btnLimpar.ZIndex=9
    Instance.new("UICorner",btnLimpar).CornerRadius=UDim.new(0,7)
    local limparStroke=Instance.new("UIStroke",btnLimpar); limparStroke.Color=Color3.fromRGB(100,110,140); limparStroke.Thickness=1; limparStroke.Transparency=0.5
    btnLimpar.MouseEnter:Connect(function() TweenService:Create(btnLimpar,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(200,80,80),BackgroundTransparency=0}):Play() end)
    btnLimpar.MouseLeave:Connect(function() TweenService:Create(btnLimpar,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(55,60,80),BackgroundTransparency=0.1}):Play() end)

    local running=false
    btnBring.MouseButton1Click:Connect(function()
        if running then return end; running=true
        btnBring.Text=T("bringBtnSearching"); TweenService:Create(btnBring,TweenInfo.new(0.08),{BackgroundTransparency=0.4}):Play()
        task.spawn(function()
            local count=executarBring(bcat.key) or 0; task.wait(0.3)
            btnBring.Text=T("bringBtnLabel"); TweenService:Create(btnBring,TweenInfo.new(0.15),{BackgroundTransparency=0.15}):Play()
            if count>0 then
                feedbackLbl.Text="✓ "..tostring(count)..T("bringItemSuccess"); feedbackLbl.TextColor3=bcat.cor; feedbackLbl.TextTransparency=0
                Notify.success(bcat.label, tostring(count)..T("bringItemSuccess"), 3.5)
                task.delay(3,function() TweenService:Create(feedbackLbl,TweenInfo.new(0.5),{TextTransparency=1}):Play(); task.wait(0.6); feedbackLbl.Text=""; feedbackLbl.TextTransparency=0 end)
            else
                feedbackLbl.Text=T("bringItemFail"); feedbackLbl.TextColor3=Color3.fromRGB(200,80,80); feedbackLbl.TextTransparency=0
                Notify.warn(bcat.label, T("bringFail"), 3)
                task.delay(2.5,function() TweenService:Create(feedbackLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); feedbackLbl.Text=""; feedbackLbl.TextTransparency=0; feedbackLbl.TextColor3=bcat.cor end)
            end
            TweenService:Create(rowStroke,TweenInfo.new(0.2),{Color=bcat.cor}):Play()
            task.delay(1.5,function() TweenService:Create(rowStroke,TweenInfo.new(0.4),{Color=Color3.fromRGB(42,46,56)}):Play() end)
            task.wait(1); running=false
        end)
    end)

    btnLimpar.MouseButton1Click:Connect(function()
        local restored = limparBring(bcat.key)
        if restored > 0 then
            feedbackLbl.Text="↩ "..tostring(restored).." restaurado(s)"; feedbackLbl.TextColor3=Color3.fromRGB(255,200,80); feedbackLbl.TextTransparency=0
            Notify.info(bcat.label, "↩ "..tostring(restored).." item(s) devolvido(s) ao lugar.", 3)
            TweenService:Create(btnLimpar,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(87,180,100)}):Play()
            task.delay(0.8, function() TweenService:Create(btnLimpar,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(55,60,80)}):Play() end)
            task.delay(2.5,function() TweenService:Create(feedbackLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); feedbackLbl.Text=""; feedbackLbl.TextTransparency=0; feedbackLbl.TextColor3=bcat.cor end)
        else
            feedbackLbl.Text="⚠ Nada a limpar"; feedbackLbl.TextColor3=Color3.fromRGB(160,160,180); feedbackLbl.TextTransparency=0
            task.delay(2,function() TweenService:Create(feedbackLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); feedbackLbl.Text=""; feedbackLbl.TextTransparency=0; feedbackLbl.TextColor3=bcat.cor end)
        end
    end)
end

local bringCatMap={}; for _,c in ipairs(BRING_CATS) do bringCatMap[c.key]=c end
local bringGroupOrder={
    {"bringGrpFuel",    Color3.fromRGB(255,130,40), {"BLog","BCombust","BCarcacas","BSucata","BMateriais"}},
    {"bringGrpFood",    Color3.fromRGB(255,120,170),{"BComidas","BPeixes","BSementes","BPocoes"}},
    {"bringGrpEquip",   Color3.fromRGB(255,200,55), {"BFerr","BArmas","BAmmo","BCura","BPelts"}},
    {"bringGrpSpecials",Color3.fromRGB(255,230,80), {"BChaves","BBlueprint"}},
}
for _,grp in ipairs(bringGroupOrder) do
    local title,cor,keys=grp[1],grp[2],grp[3]
    makeBringSection(title,cor)
    for _,k in ipairs(keys) do if bringCatMap[k] then makeBringRow(bringCatMap[k]) end end
end

-- ══════════════════════════════════════════════════════
-- BRING ALL — Traz todos os itens de todas as categorias
-- ══════════════════════════════════════════════════════
do
    local baSep=Instance.new("Frame",Pages["Bring"]); baSep.BackgroundColor3=Color3.fromRGB(50,54,65)
    baSep.BorderSizePixel=0; baSep.Size=UDim2.new(1,0,0,1); baSep.LayoutOrder=bringLO(); baSep.ZIndex=5

    local baCard=Instance.new("Frame",Pages["Bring"])
    baCard.BackgroundColor3=Color3.fromRGB(24,26,34); baCard.BorderSizePixel=0
    baCard.Size=UDim2.new(1,0,0,90); baCard.LayoutOrder=bringLO(); baCard.ZIndex=5
    Instance.new("UICorner",baCard).CornerRadius=UDim.new(0,10)
    local baStroke=Instance.new("UIStroke",baCard); baStroke.Color=Color3.fromRGB(88,101,242); baStroke.Thickness=1.8

    -- Glow bg
    local baGlow=Instance.new("Frame",baCard); baGlow.BackgroundColor3=Color3.fromRGB(88,101,242)
    baGlow.BackgroundTransparency=0.92; baGlow.BorderSizePixel=0; baGlow.Size=UDim2.new(1,0,1,0); baGlow.ZIndex=5
    Instance.new("UICorner",baGlow).CornerRadius=UDim.new(0,10)

    -- Barra lateral
    local baBar=Instance.new("Frame",baCard); baBar.BackgroundColor3=Color3.fromRGB(88,101,242)
    baBar.BorderSizePixel=0; baBar.Size=UDim2.new(0,4,0.7,0); baBar.Position=UDim2.new(0,0,0.15,0); baBar.ZIndex=6
    Instance.new("UICorner",baBar).CornerRadius=UDim.new(0,2)

    -- Ícone
    local baIconBg=Instance.new("Frame",baCard); baIconBg.BackgroundColor3=Color3.fromRGB(88,101,242)
    baIconBg.BackgroundTransparency=0.7; baIconBg.BorderSizePixel=0
    baIconBg.Position=UDim2.new(0,10,0.5,-20); baIconBg.Size=UDim2.new(0,40,0,40); baIconBg.ZIndex=6
    Instance.new("UICorner",baIconBg).CornerRadius=UDim.new(0,10)
    local baIconLbl=Instance.new("TextLabel",baIconBg); baIconLbl.BackgroundTransparency=1
    baIconLbl.Size=UDim2.new(1,0,1,0); baIconLbl.Font=Enum.Font.GothamBlack
    baIconLbl.Text="★"; baIconLbl.TextColor3=Color3.fromRGB(180,195,255); baIconLbl.TextSize=22; baIconLbl.ZIndex=7

    -- Título e descrição
    local baTitleLbl=Instance.new("TextLabel",baCard); baTitleLbl.BackgroundTransparency=1
    baTitleLbl.Position=UDim2.new(0,60,0,14); baTitleLbl.Size=UDim2.new(1,-200,0,20)
    baTitleLbl.Font=Enum.Font.GothamBlack; baTitleLbl.Text="⚡ BRING ALL"
    trackLabel(baTitleLbl, "bringAllTitle")
    baTitleLbl.TextColor3=Color3.fromRGB(220,228,255); baTitleLbl.TextSize=14
    baTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; baTitleLbl.ZIndex=6
    local baDescLbl=Instance.new("TextLabel",baCard); baDescLbl.BackgroundTransparency=1
    baDescLbl.Position=UDim2.new(0,60,0,36); baDescLbl.Size=UDim2.new(1,-200,0,28)
    baDescLbl.Font=Enum.Font.Gotham; baDescLbl.Text="Traz TODOS os recursos do mapa de uma só vez"
    trackLabel(baDescLbl, "bringAllDesc")
    baDescLbl.TextColor3=Color3.fromRGB(100,110,140); baDescLbl.TextSize=9
    baDescLbl.TextWrapped=true; baDescLbl.TextXAlignment=Enum.TextXAlignment.Left; baDescLbl.ZIndex=6

    -- Feedback
    local baFeedLbl=Instance.new("TextLabel",baCard); baFeedLbl.BackgroundTransparency=1
    baFeedLbl.Position=UDim2.new(1,-115,0,64); baFeedLbl.Size=UDim2.new(0,107,0,14)
    baFeedLbl.Font=Enum.Font.GothamBold; baFeedLbl.Text=""
    baFeedLbl.TextColor3=Color3.fromRGB(88,101,242); baFeedLbl.TextSize=8
    baFeedLbl.TextXAlignment=Enum.TextXAlignment.Center; baFeedLbl.ZIndex=7

    -- Barra de progresso
    local baProgBg=Instance.new("Frame",baCard); baProgBg.BackgroundColor3=Color3.fromRGB(30,34,46)
    baProgBg.BorderSizePixel=0; baProgBg.Position=UDim2.new(1,-115,0.5,-5); baProgBg.Size=UDim2.new(0,107,0,4); baProgBg.ZIndex=6
    Instance.new("UICorner",baProgBg).CornerRadius=UDim.new(0,2)
    local baProgFill=Instance.new("Frame",baProgBg); baProgFill.BackgroundColor3=Color3.fromRGB(88,101,242)
    baProgFill.BorderSizePixel=0; baProgFill.Size=UDim2.new(0,0,1,0); baProgFill.ZIndex=7
    Instance.new("UICorner",baProgFill).CornerRadius=UDim.new(0,2)

    -- Botão
    local baBtn=Instance.new("TextButton",baCard); baBtn.BackgroundColor3=Color3.fromRGB(88,101,242)
    baBtn.BackgroundTransparency=0.1; baBtn.BorderSizePixel=0
    baBtn.Position=UDim2.new(1,-115,0,12); baBtn.Size=UDim2.new(0,107,0,44)
    baBtn.Font=Enum.Font.GothamBlack; baBtn.Text="▼  BRING ALL"
    trackLabel(baBtn, "bringAllBtn")
    baBtn.TextColor3=Color3.fromRGB(255,255,255); baBtn.TextSize=11; baBtn.ZIndex=7
    Instance.new("UICorner",baBtn).CornerRadius=UDim.new(0,9)
    local baBtnStroke=Instance.new("UIStroke",baBtn); baBtnStroke.Color=Color3.fromRGB(140,155,255); baBtnStroke.Thickness=1.2; baBtnStroke.Transparency=0.5
    baBtn.MouseEnter:Connect(function() TweenService:Create(baBtn,TweenInfo.new(0.12),{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(105,120,255)}):Play() end)
    baBtn.MouseLeave:Connect(function() TweenService:Create(baBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.1,BackgroundColor3=Color3.fromRGB(88,101,242)}):Play() end)

    -- Lookup global de todos os itens
    local ALL_ITEMS_99N = {}
    for _,c in ipairs(BRING_CATS) do for _,n in ipairs(c.nomes) do ALL_ITEMS_99N[n:lower()]=true end end

    local baRunning=false
    baBtn.MouseButton1Click:Connect(function()
        if baRunning then return end; baRunning=true
        baBtn.Text=T("bringAllBtnSearching"); TweenService:Create(baBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.4}):Play()
        TweenService:Create(baProgFill,TweenInfo.new(0.1),{Size=UDim2.new(0,0,1,0)}):Play()
        Notify.info(T("bringAllTitle"), T("bringAllNotifSearching"), 3)
        task.spawn(function()
            -- Delay de 2 segundos antes de trazer
            task.wait(2)
            local char=Player.Character; if not char then baRunning=false; return end
            local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then baRunning=false; return end
            local cf=hrp.CFrame; local count=0; local trazidos={}; local batch=0
            bringAllHistory = {}
            local pchars={}; for _,pl in ipairs(Players:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end
            local ok,descs=pcall(function() return workspace:GetDescendants() end)
            if ok then
                -- Coleta elegíveis primeiro para distribuição de ângulo uniforme
                -- Suporta tanto BasePart solto quanto Model (sem Humanoid) — igual ao executarBring individual
                local eligiveis = {}
                local total=#descs
                local alreadyAdded = {} -- evita duplicar partes do mesmo Model
                for i,obj in ipairs(descs) do
                    batch+=1
                    if batch%80==0 then
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
                            -- Item solto: o nome da própria peça é o nome do item
                            -- Mas só pega se NÃO está dentro de um Model com nome de item
                            -- (evita pegar a BasePart interna quando o Model já foi adicionado)
                            local parentModel = obj.Parent
                            if parentModel and parentModel:IsA("Model") and not parentModel:FindFirstChildWhichIsA("Humanoid") then
                                -- Deixa o bloco do Model cuidar disso
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

                        -- Bloqueia personagens de outros jogadores
                        for pc in pairs(pchars) do if pc==obj or pc:IsAncestorOf(obj) then return end end
                        -- Bloqueia NPCs na hierarquia (até 4 níveis acima)
                        local p=obj.Parent
                        for _=1,4 do if p and p:IsA("Model") and p:FindFirstChildWhichIsA("Humanoid") then return end; p=p and p.Parent end
                        -- Verifica se é um item válido da lista
                        if not ALL_ITEMS_99N[checkName] then return end
                        -- Descarta peças gigantes (construções, terreno)
                        local sz=targetPart.Size; if sz.X>18 or sz.Y>18 or sz.Z>18 then return end

                        if obj:IsA("Model") then alreadyAdded[obj] = true end
                        table.insert(eligiveis, {obj=obj, targetPart=targetPart, savedModelParts=savedModelParts})
                    end)
                end

                -- Teleporta com distribuição uniforme ao redor do jogador
                local nTotal = #eligiveis
                for idx, eEntry in ipairs(eligiveis) do
                    pcall(function()
                        local obj         = eEntry.obj
                        local targetPart  = eEntry.targetPart
                        local savedMP     = eEntry.savedModelParts

                        char=Player.Character; if not char then return end
                        hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                        cf=hrp.CFrame

                        if not targetPart or not targetPart.Parent then return end

                        local originalCF = targetPart.CFrame
                        saveTrueOrigin(targetPart, originalCF)
                        if savedMP then
                            for _, mp in ipairs(savedMP) do saveTrueOrigin(mp.bp, mp.originalCF) end
                        end

                        -- Ângulo uniforme baseado no índice
                        local angle  = (idx / math.max(nTotal, 1)) * math.pi * 2
                        local radius = 2.5 + math.random() * 3.5  -- 2.5 a 6 studs
                        local target = Vector3.new(
                            cf.Position.X + math.cos(angle)*radius,
                            cf.Position.Y - 2.5,   -- ao nível dos pés
                            cf.Position.Z + math.sin(angle)*radius
                        )
                        -- Desativa scripts do item
                        for _,s in ipairs(obj:GetDescendants()) do
                            if s:IsA("Script") or s:IsA("LocalScript") then
                                pcall(function() s.Disabled=true end)
                            end
                        end
                        targetPart.CFrame      = CFrame.new(target)
                        targetPart.Velocity    = Vector3.zero
                        targetPart.RotVelocity = Vector3.zero
                        pcall(function() targetPart.CanCollide = true end)
                        -- Mantém outras partes do Model juntas
                        if savedMP then
                            for _, mp in ipairs(savedMP) do
                                pcall(function()
                                    mp.bp.CFrame = CFrame.new(target + Vector3.new(
                                        (math.random()-0.5)*0.3, 0, (math.random()-0.5)*0.3))
                                    mp.bp.Velocity = Vector3.zero
                                end)
                            end
                        end
                        count+=1
                        local entry = {obj=targetPart, originalCFrame=originalCF, pos=target, modelParts=savedMP}
                        table.insert(trazidos, entry)
                        table.insert(bringAllHistory, entry)
                    end)
                    if idx%30==0 then
                        task.wait()
                        local pct2 = 0.5 + (idx/math.max(nTotal,1))*0.5
                        TweenService:Create(baProgFill,TweenInfo.new(0.1),{Size=UDim2.new(pct2,0,1,0)}):Play()
                    end
                end
            end
            -- NÃO re-ancora: deixa física do Roblox agir (itens caem no chão)
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
                TweenService:Create(baProgFill,TweenInfo.new(0.5),{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(88,101,242)}):Play()
                TweenService:Create(baFeedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play()
                task.wait(0.5); baFeedLbl.Text=""; baFeedLbl.TextTransparency=0
            end)
            task.wait(1.5); baRunning=false
        end)
    end)

    -- Botão LIMPAR ALL
    local baLimparBtn=Instance.new("TextButton",baCard); baLimparBtn.BackgroundColor3=Color3.fromRGB(55,60,80)
    baLimparBtn.BackgroundTransparency=0.1; baLimparBtn.BorderSizePixel=0
    baLimparBtn.Position=UDim2.new(1,-115,0,62); baLimparBtn.Size=UDim2.new(0,107,0,20)
    baLimparBtn.Font=Enum.Font.GothamBold; baLimparBtn.Text="🗑 Limpar Tudo"
    baLimparBtn.TextColor3=Color3.fromRGB(180,190,220); baLimparBtn.TextSize=9; baLimparBtn.ZIndex=8
    Instance.new("UICorner",baLimparBtn).CornerRadius=UDim.new(0,7)
    local baLimparStroke=Instance.new("UIStroke",baLimparBtn); baLimparStroke.Color=Color3.fromRGB(100,110,140); baLimparStroke.Thickness=1; baLimparStroke.Transparency=0.5
    baCard.Size=UDim2.new(1,0,0,92)
    baLimparBtn.MouseEnter:Connect(function() TweenService:Create(baLimparBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(200,80,80),BackgroundTransparency=0}):Play() end)
    baLimparBtn.MouseLeave:Connect(function() TweenService:Create(baLimparBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(55,60,80),BackgroundTransparency=0.1}):Play() end)
    baLimparBtn.MouseButton1Click:Connect(function()
        local restored = limparBringAll()
        if restored > 0 then
            baFeedLbl.Text="↩ "..tostring(restored).." restaurado(s)"; baFeedLbl.TextColor3=Color3.fromRGB(255,200,80); baFeedLbl.TextTransparency=0
            Notify.info(T("bringAllTitle"), "↩ "..tostring(restored).." item(s) devolvido(s) ao lugar.", 3.5)
            TweenService:Create(baLimparBtn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(87,180,100)}):Play()
            task.delay(0.8, function() TweenService:Create(baLimparBtn,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(55,60,80)}):Play() end)
            task.delay(3,function() TweenService:Create(baFeedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); baFeedLbl.Text=""; baFeedLbl.TextTransparency=0 end)
        else
            baFeedLbl.Text="⚠ Nada a limpar"; baFeedLbl.TextColor3=Color3.fromRGB(160,160,180); baFeedLbl.TextTransparency=0
            task.delay(2,function() TweenService:Create(baFeedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); baFeedLbl.Text=""; baFeedLbl.TextTransparency=0 end)
        end
    end)
end

end -- [[ ESP + BRING ]]

-- ══════════════════════════════════════════════════════
--  PLAYER TAB
-- ══════════════════════════════════════════════════════
do -- [[ PLAYER TAB ]]
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
        flyBodyVel.MaxForce = Vector3.new(1e6,1e6,1e6); flyBodyVel.Velocity = Vector3.zero
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
            local dir = Vector3.zero

            -- Horizontal: joystick móvel (MoveDirection) funciona no celular E no PC com WASD
            if hum2 then
                local md = hum2.MoveDirection
                if md.Magnitude > 0.05 then
                    dir = dir + Vector3.new(md.X, 0, md.Z)
                end
            end

            -- Vertical — teclado (PC) e botões overlay (mobile)
            if UIS:IsKeyDown(Enum.KeyCode.Space) or flyUp then
                dir = dir + Vector3.new(0,1,0)
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) or flyDown then
                dir = dir - Vector3.new(0,1,0)
            end

            flyBodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
            flyBodyGyro.CFrame  = cam.CFrame
        end)
        -- Cria overlay mobile na primeira vez
        if not flyControlsGui then flyControlsGui = buildFlyOverlay() end
        flyControlsGui.Enabled = true
        Notify.info(T("flyOn"), "Joystick=mover • ▲UP ▼DOWN na tela • PC: Space/Ctrl")
    else
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        pcall(function() if flyBodyVel  then flyBodyVel:Destroy();  flyBodyVel=nil  end end)
        pcall(function() if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro=nil end end)
        flyUp = false; flyDown = false
        if flyControlsGui then flyControlsGui.Enabled = false end
        Notify.info(T("flyOff"), T("flyOffMsg"))
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
                if py < NOCLIP_VOID_Y then hrp.CFrame = CFrame.new(hrp.Position.X, NOCLIP_VOID_Y+10, hrp.Position.Z); hrp.Velocity = Vector3.zero end
            end
            for _, part in ipairs(ch:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
            if hrp then hrp.CanCollide = false end
        end)
        Notify.warn(T("noclipOn"), T("noclipOnMsg"))
    else
        if noclipConn2 then noclipConn2:Disconnect(); noclipConn2=nil end
        pcall(function()
            local ch=Player.Character; if not ch then return end
            for _, part in ipairs(ch:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
        end)
        Notify.info(T("noclipOff"), T("noclipOffMsg"))
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
        Notify.info(T("tpClickOn"), T("tpClickOnMsg"))
    else
        if tpClickConn then tpClickConn:Disconnect(); tpClickConn=nil end
        Notify.info(T("tpClickOff"), T("tpClickOffMsg"))
    end
end

-- UI PLAYER
local plLO = 0
local function plNextLO() plLO+=1; return plLO end

local function makePlSec(titleKey, cor)
    local hdr=Instance.new("Frame",Pages["Player"]); hdr.BackgroundColor3=Color3.fromRGB(20,22,30)
    hdr.BackgroundTransparency=0.3; hdr.BorderSizePixel=0; hdr.Size=UDim2.new(1,0,0,22)
    hdr.LayoutOrder=plNextLO(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",hdr); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=5; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,0)
    lbl.Size=UDim2.new(1,-14,1,0); lbl.Font=Enum.Font.GothamBlack
    lbl.TextColor3=cor; lbl.TextSize=9; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    TL(lbl, titleKey)  -- auto-tracked for language switching
end

local function makePlToggle(lbl_txt, desc_txt, cor, onToggle)
    local row=Instance.new("Frame",Pages["Player"]); row.BackgroundColor3=Color3.fromRGB(28,30,38)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,56); row.LayoutOrder=plNextLO(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local rowS=Instance.new("UIStroke",row); rowS.Color=Color3.fromRGB(42,46,58); rowS.Thickness=1
    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,8); tl.Size=UDim2.new(1,-80,0,18); tl.Font=Enum.Font.GothamBold
    tl.Text=lbl_txt; tl.TextColor3=Color3.fromRGB(220,225,240); tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local td=Instance.new("TextLabel",row); td.BackgroundTransparency=1
    td.Position=UDim2.new(0,14,0,28); td.Size=UDim2.new(1,-80,0,22); td.Font=Enum.Font.Gotham
    td.Text=desc_txt; td.TextColor3=Color3.fromRGB(90,100,120); td.TextSize=9
    td.TextXAlignment=Enum.TextXAlignment.Left; td.TextWrapped=true; td.ZIndex=7
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(45,50,62); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-56,0.5,-13); pill.Size=UDim2.new(0,48,0,26); pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(160,170,185); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,2,0.5,-11); knob.Size=UDim2.new(0,22,0,22); knob.ZIndex=10
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=11
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(pill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundColor3=state and cor or Color3.fromRGB(45,50,62)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=state and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
            BackgroundColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
        }):Play()
        TweenService:Create(rowS,TweenInfo.new(0.2),{Color=state and cor or Color3.fromRGB(42,46,58)}):Play()
        onToggle(state)
    end)
end

local function makeSliderBar(parentPage, lbl_txt, desc_txt, cor, minV, maxV, initVal, onChange)
    local row = Instance.new("Frame", parentPage)
    row.BackgroundColor3 = Color3.fromRGB(28,30,38); row.BorderSizePixel = 0
    row.Size = UDim2.new(1,0,0,78); row.LayoutOrder = plNextLO(); row.ZIndex = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)
    local rowS = Instance.new("UIStroke", row); rowS.Color = Color3.fromRGB(42,46,58); rowS.Thickness = 1
    local tl = Instance.new("TextLabel", row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,8); tl.Size=UDim2.new(0.65,0,0,16); tl.Font=Enum.Font.GothamBold
    tl.Text=lbl_txt; tl.TextColor3=Color3.fromRGB(220,225,240); tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local valLbl = Instance.new("TextLabel", row); valLbl.BackgroundTransparency=1
    valLbl.Position=UDim2.new(1,-60,0,8); valLbl.Size=UDim2.new(0,52,0,16); valLbl.Font=Enum.Font.GothamBold
    valLbl.Text=tostring(initVal); valLbl.TextColor3=cor; valLbl.TextSize=12; valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=7
    local td = Instance.new("TextLabel", row); td.BackgroundTransparency=1
    td.Position=UDim2.new(0,14,0,26); td.Size=UDim2.new(1,-20,0,14); td.Font=Enum.Font.Gotham
    td.Text=desc_txt; td.TextColor3=Color3.fromRGB(90,100,120); td.TextSize=9; td.TextXAlignment=Enum.TextXAlignment.Left; td.ZIndex=7
    local trackBg = Instance.new("Frame", row); trackBg.BackgroundColor3=Color3.fromRGB(42,48,62)
    trackBg.BorderSizePixel=0; trackBg.Position=UDim2.new(0,14,0,52); trackBg.Size=UDim2.new(1,-28,0,14)
    trackBg.ZIndex=7; Instance.new("UICorner",trackBg).CornerRadius=UDim.new(1,0)
    local pct0 = math.clamp((initVal - minV) / (maxV - minV), 0, 1)
    local fill = Instance.new("Frame", trackBg); fill.BackgroundColor3=cor; fill.BorderSizePixel=0
    fill.Size=UDim2.new(pct0,0,1,0); fill.ZIndex=8; Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local knob = Instance.new("Frame", trackBg); knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    knob.BorderSizePixel=0; knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(pct0,0,0.5,0); knob.Size=UDim2.new(0,18,0,18); knob.ZIndex=9
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local kS=Instance.new("UIStroke",knob); kS.Color=cor; kS.Thickness=2
    local dragging = false
    local function setVal(pct)
        pct = math.clamp(pct, 0, 1)
        local v = math.round(minV + (maxV - minV) * pct)
        valLbl.Text = tostring(v); fill.Size = UDim2.new(pct,0,1,0); knob.Position = UDim2.new(pct,0,0.5,0)
        onChange(v)
    end
    local sliderBtn = Instance.new("TextButton", trackBg)
    sliderBtn.BackgroundTransparency=1; sliderBtn.Size=UDim2.new(1,20,1,20)
    sliderBtn.Position=UDim2.new(0,-10,0,-10); sliderBtn.Text=""; sliderBtn.ZIndex=10
    sliderBtn.MouseButton1Down:Connect(function()
        dragging = true
        local mp = UserInputService:GetMouseLocation()
        local ap = trackBg.AbsolutePosition; local as = trackBg.AbsoluteSize
        setVal((mp.X - ap.X) / as.X)
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local ap = trackBg.AbsolutePosition; local as = trackBg.AbsoluteSize
        setVal((input.Position.X - ap.X) / as.X)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

-- ══════════════════════════════════════════════════════
-- makePlKACard — card estilo Kill Aura (toggle esq + mini slider dir)
-- Usado para Speed, Jump e FlySpeed
-- ══════════════════════════════════════════════════════
local function makePlKACard(COR, titleTxt, descTxt, minV, maxV, defV, maxStr, getDescFn, initEnabled, onToggle, onSlider)
    -- Cores derivadas do accent
    local r,g,b = math.floor(COR.R*255), math.floor(COR.G*255), math.floor(COR.B*255)
    local BG    = Color3.fromRGB(math.clamp(r*0.1+16,16,28), math.clamp(g*0.07+16,16,28), math.clamp(b*0.07+16,16,28))
    local SOFF  = Color3.fromRGB(math.clamp(r*0.25+35,35,75), math.clamp(g*0.18+35,35,75), math.clamp(b*0.18+35,35,75))

    local card = Instance.new("Frame", Pages["Player"])
    card.BackgroundColor3 = BG; card.BorderSizePixel = 0
    card.Size = UDim2.new(1,0,0,82); card.LayoutOrder = plNextLO(); card.ZIndex = 5
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,9)
    local cardS = Instance.new("UIStroke",card); cardS.Thickness = 1
    cardS.Color = initEnabled and COR or SOFF

    -- Título
    local titLbl = Instance.new("TextLabel",card); titLbl.BackgroundTransparency=1
    titLbl.Position=UDim2.new(0,14,0,8); titLbl.Size=UDim2.new(0.5,0,0,18)
    titLbl.Font=Enum.Font.GothamBold; titLbl.Text=titleTxt
    titLbl.TextColor3=Color3.fromRGB(220,225,240); titLbl.TextSize=12
    titLbl.TextXAlignment=Enum.TextXAlignment.Left; titLbl.ZIndex=7

    -- Desc
    local descLbl = Instance.new("TextLabel",card); descLbl.BackgroundTransparency=1
    descLbl.Position=UDim2.new(0,14,0,28); descLbl.Size=UDim2.new(0.5,0,0,28)
    descLbl.Font=Enum.Font.Gotham; descLbl.Text=descTxt
    descLbl.TextColor3=Color3.fromRGB(90,100,120); descLbl.TextSize=9
    descLbl.TextXAlignment=Enum.TextXAlignment.Left; descLbl.TextWrapped=true; descLbl.ZIndex=7

    -- Toggle pill (esquerdo)
    local pill = Instance.new("Frame",card); pill.BorderSizePixel=0
    pill.Position=UDim2.new(0,14,0,60); pill.Size=UDim2.new(0,48,0,16); pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    pill.BackgroundColor3 = initEnabled and COR or Color3.fromRGB(45,50,62)
    local pillKnob = Instance.new("Frame",pill); pillKnob.BorderSizePixel=0
    pillKnob.Size=UDim2.new(0,14,0,14); pillKnob.ZIndex=10
    Instance.new("UICorner",pillKnob).CornerRadius=UDim.new(1,0)
    pillKnob.Position = initEnabled and UDim2.new(1,-15,0.5,-7) or UDim2.new(0,1,0.5,-7)
    pillKnob.BackgroundColor3 = initEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)

    -- Status ON/OFF
    local statusLbl = Instance.new("TextLabel",card); statusLbl.BackgroundTransparency=1
    statusLbl.Position=UDim2.new(0,68,0,60); statusLbl.Size=UDim2.new(0,50,0,16)
    statusLbl.Font=Enum.Font.GothamBlack; statusLbl.TextSize=8; statusLbl.ZIndex=9
    statusLbl.TextXAlignment=Enum.TextXAlignment.Left
    statusLbl.Text = initEnabled and "ATIVO" or "INATIVO"
    statusLbl.TextColor3 = initEnabled and COR or Color3.fromRGB(80,90,110)

    -- Divisória vertical
    local divV = Instance.new("Frame",card); divV.BackgroundColor3=SOFF
    divV.BorderSizePixel=0; divV.Position=UDim2.new(0.52,0,0,8)
    divV.Size=UDim2.new(0,1,1,-16); divV.ZIndex=6

    -- Label "Valor" (topo direito)
    local alcLbl = Instance.new("TextLabel",card); alcLbl.BackgroundTransparency=1
    alcLbl.Position=UDim2.new(0.54,0,0,8); alcLbl.Size=UDim2.new(0.28,0,0,14)
    alcLbl.Font=Enum.Font.GothamBold; alcLbl.Text="Valor"
    alcLbl.TextColor3=COR; alcLbl.TextSize=9
    alcLbl.TextXAlignment=Enum.TextXAlignment.Left; alcLbl.ZIndex=7

    -- Valor numérico (canto direito)
    local valLbl = Instance.new("TextLabel",card); valLbl.BackgroundTransparency=1
    valLbl.Position=UDim2.new(0.82,0,0,6); valLbl.Size=UDim2.new(0.16,0,0,16)
    valLbl.Font=Enum.Font.GothamBlack; valLbl.Text=tostring(defV)
    valLbl.TextColor3=Color3.fromRGB(255,255,255); valLbl.TextSize=10
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=7

    -- Mini track (4px de alto)
    local miniTrack = Instance.new("Frame",card); miniTrack.BackgroundColor3=SOFF
    miniTrack.BorderSizePixel=0; miniTrack.Position=UDim2.new(0.54,0,0,28)
    miniTrack.Size=UDim2.new(0.44,-8,0,4); miniTrack.ZIndex=7
    Instance.new("UICorner",miniTrack).CornerRadius=UDim.new(1,0)

    local pct0 = (defV - minV) / (maxV - minV)
    local miniFill = Instance.new("Frame",miniTrack); miniFill.BackgroundColor3=COR
    miniFill.BorderSizePixel=0; miniFill.Size=UDim2.new(pct0,0,1,0); miniFill.ZIndex=8
    Instance.new("UICorner",miniFill).CornerRadius=UDim.new(1,0)

    local miniDot = Instance.new("Frame",miniTrack); miniDot.BackgroundColor3=Color3.fromRGB(255,255,255)
    miniDot.BorderSizePixel=0; miniDot.AnchorPoint=Vector2.new(0.5,0.5)
    miniDot.Position=UDim2.new(pct0,0,0.5,0); miniDot.Size=UDim2.new(0,12,0,12); miniDot.ZIndex=9
    Instance.new("UICorner",miniDot).CornerRadius=UDim.new(1,0)
    local dotS=Instance.new("UIStroke",miniDot); dotS.Color=COR; dotS.Thickness=2

    -- Balão de valor
    local balloon = Instance.new("Frame",miniDot); balloon.BackgroundColor3=Color3.fromRGB(255,255,255)
    balloon.BorderSizePixel=0; balloon.AnchorPoint=Vector2.new(0.5,1)
    balloon.Position=UDim2.new(0.5,0,0,-6); balloon.Size=UDim2.new(0,30,0,16)
    balloon.ZIndex=11; balloon.Visible=false
    Instance.new("UICorner",balloon).CornerRadius=UDim.new(0,4)
    local ballLbl = Instance.new("TextLabel",balloon); ballLbl.BackgroundTransparency=1
    ballLbl.Size=UDim2.new(1,0,1,0); ballLbl.Font=Enum.Font.GothamBlack
    ballLbl.Text=tostring(defV); ballLbl.TextColor3=Color3.fromRGB(20,20,30)
    ballLbl.TextSize=8; ballLbl.ZIndex=12

    -- Rótulos min / max
    local minLbl2 = Instance.new("TextLabel",card); minLbl2.BackgroundTransparency=1
    minLbl2.Position=UDim2.new(0.54,0,0,36); minLbl2.Size=UDim2.new(0.15,0,0,10)
    minLbl2.Font=Enum.Font.Gotham; minLbl2.Text=tostring(minV)
    minLbl2.TextColor3=Color3.fromRGB(75,80,100); minLbl2.TextSize=7
    minLbl2.TextXAlignment=Enum.TextXAlignment.Left; minLbl2.ZIndex=7
    local maxLbl2 = Instance.new("TextLabel",card); maxLbl2.BackgroundTransparency=1
    maxLbl2.Position=UDim2.new(0.9,-8,0,36); maxLbl2.Size=UDim2.new(0.1,0,0,10)
    maxLbl2.Font=Enum.Font.Gotham; maxLbl2.Text=maxStr
    maxLbl2.TextColor3=Color3.fromRGB(75,80,100); maxLbl2.TextSize=7
    maxLbl2.TextXAlignment=Enum.TextXAlignment.Right; maxLbl2.ZIndex=7

    -- Desc do valor atual
    local valDescLbl = Instance.new("TextLabel",card); valDescLbl.BackgroundTransparency=1
    valDescLbl.Position=UDim2.new(0.54,0,0,50); valDescLbl.Size=UDim2.new(0.44,-8,0,10)
    valDescLbl.Font=Enum.Font.Gotham; valDescLbl.TextSize=8
    valDescLbl.TextXAlignment=Enum.TextXAlignment.Left; valDescLbl.ZIndex=7
    valDescLbl.TextColor3=Color3.fromRGB(
        math.clamp(r*0.45+60,60,170), math.clamp(g*0.3+60,60,170), math.clamp(b*0.3+60,60,170))
    if getDescFn then valDescLbl.Text=getDescFn(defV) end

    -- Estado atual
    local curVal   = defV
    local enabled  = initEnabled

    -- Drag do mini slider (mouse + touch)
    local dragging = false
    local function setMiniVal(screenX)
        local ap = miniTrack.AbsolutePosition; local as = miniTrack.AbsoluteSize
        local pct = math.clamp((screenX - ap.X) / as.X, 0, 1)
        curVal = math.round(minV + (maxV - minV) * pct)
        miniFill.Size    = UDim2.new(pct,0,1,0)
        miniDot.Position = UDim2.new(pct,0,0.5,0)
        valLbl.Text  = tostring(curVal)
        ballLbl.Text = tostring(curVal)
        if getDescFn then valDescLbl.Text = getDescFn(curVal) end
        if onSlider then onSlider(curVal) end
    end

    local dotBtn = Instance.new("TextButton",miniDot); dotBtn.BackgroundTransparency=1
    dotBtn.Size=UDim2.new(1,10,1,10); dotBtn.Position=UDim2.new(0,-5,0,-5); dotBtn.Text=""; dotBtn.ZIndex=13
    dotBtn.MouseButton1Down:Connect(function() dragging=true; balloon.Visible=true end)

    local trackBtn = Instance.new("TextButton",miniTrack); trackBtn.BackgroundTransparency=1
    trackBtn.Size=UDim2.new(1,16,1,16); trackBtn.Position=UDim2.new(0,-8,0,-8); trackBtn.Text=""; trackBtn.ZIndex=10
    trackBtn.MouseButton1Down:Connect(function()
        dragging=true; balloon.Visible=true
        setMiniVal(UserInputService:GetMouseLocation().X)
    end)

    -- Touch support (mobile slider drag)
    trackBtn.TouchLongPress:Connect(function()  dragging=true; balloon.Visible=true end)
    dotBtn.TouchLongPress:Connect(function()    dragging=true; balloon.Visible=true end)

    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            setMiniVal(inp.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging=false; balloon.Visible=false
        end
    end)

    -- Toggle (cobre lado esquerdo do card)
    local toggleBtn = Instance.new("TextButton",card); toggleBtn.BackgroundTransparency=1
    toggleBtn.Position=UDim2.new(0,0,0,0); toggleBtn.Size=UDim2.new(0.52,0,1,0)
    toggleBtn.Text=""; toggleBtn.ZIndex=11
    toggleBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        TweenService:Create(pill,TweenInfo.new(0.22),{BackgroundColor3=enabled and COR or Color3.fromRGB(45,50,62)}):Play()
        TweenService:Create(pillKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=enabled and UDim2.new(1,-15,0.5,-7) or UDim2.new(0,1,0.5,-7),
            BackgroundColor3=enabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
        }):Play()
        TweenService:Create(cardS,TweenInfo.new(0.2),{Color=enabled and COR or SOFF}):Play()
        statusLbl.Text      = enabled and "ATIVO" or "INATIVO"
        statusLbl.TextColor3= enabled and COR or Color3.fromRGB(80,90,110)
        if onToggle then onToggle(enabled, curVal) end
    end)

    return card
end

-- ── Speed ─────────────────────────────────────────────
makePlSec("plSecSpeed", Color3.fromRGB(255,200,50))

makePlKACard(
    Color3.fromRGB(255,180,30),       -- cor
    T("plSpeedTitle"), T("plSpeedDesc"),
    16, 275, 30, "275",               -- min, max, default, maxLabel
    function(v)                        -- desc do valor
        if v<=22 then return "normal"
        elseif v<=60 then return "rápido"
        elseif v<=130 then return "muito rápido"
        else return "máximo" end
    end,
    true,                              -- initEnabled
    function(en, v)                    -- onToggle
        speedEnabled = en
        applySpeed(en and v or 16)
        Notify.info("⚡ Velocidade", en and ("Ativado — "..v.." speed") or "Desativado — speed normal (16)")
    end,
    function(v)                        -- onSlider
        playerSpeed = v
        if speedEnabled then applySpeed(v) end
    end
)

-- ── JumpPower ─────────────────────────────────────────
makePlKACard(
    Color3.fromRGB(100,220,255),      -- cor
    T("plJumpTitle"), T("plJumpDesc"),
    50, 1285, 80, "1285",            -- min, max, default, maxLabel
    function(v)                       -- desc do valor
        if v<=60 then return "normal"
        elseif v<=180 then return "alto"
        elseif v<=500 then return "muito alto"
        else return "máximo" end
    end,
    true,                             -- initEnabled
    function(en, v)                   -- onToggle
        jumpEnabled = en
        applyJump(en and v or 50)
        Notify.info("🦘 Pulo", en and ("Ativado — "..v.." power") or "Desativado — pulo normal (50)")
    end,
    function(v)                       -- onSlider
        playerJump = v
        if jumpEnabled then applyJump(v) end
    end
)

-- ── Fly ───────────────────────────────────────────────
makePlSec("plSecFly", Color3.fromRGB(100,200,255))
makePlToggle(T("plFlyToggle"), T("plFlyDesc"), Color3.fromRGB(80,180,255), function(s) setFly(s) end)

-- ── Fly Speed ─────────────────────────────────────────
makePlKACard(
    Color3.fromRGB(120,200,255),      -- cor
    T("plFlySpeedTitle"), T("plFlySpeedDesc"),
    16, 345, 40, "345",              -- min, max, default, maxLabel
    function(v)                       -- desc do valor
        if v<=25 then return "devagar"
        elseif v<=80 then return "moderado"
        elseif v<=180 then return "rápido"
        else return "máximo" end
    end,
    true,                             -- initEnabled (Fly Speed sempre ativo)
    function(en, v)                   -- onToggle (sem efeito real, só visual)
        flySpeed = en and v or 40
    end,
    function(v)                       -- onSlider
        flySpeed = v
    end
)

makePlToggle(T("plNoclipToggle"), T("plNoclipDesc"), Color3.fromRGB(140,255,140), function(s) setNoclip(s) end)

makePlSec("plSecUtil", Color3.fromRGB(255,210,80))
makePlToggle(T("plTpClickToggle"), T("plTpClickDesc"), Color3.fromRGB(255,220,60), function(s) setTpClick(s) end)

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
makePlToggle("📷 Câmera Alta", "Zoom ilimitado — a câmera pode afastar infinitamente", Color3.fromRGB(100,220,255), function(s) setCamAlta(s) end)

-- ══════════════════════════════════════════════════════
-- CÂMERA X — atravessa paredes
-- ══════════════════════════════════════════════════════
local camXEnabled = false
local camXConn
local camXTranspCache = {}

local function setCamX(state)
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
                iteration += 1
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

makePlToggle("🔭 Câmera X", "Câmera atravessa paredes — sem zoom ao colidir", Color3.fromRGB(180,140,255), function(s) setCamX(s) end)

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

makePlSec("plSecAntiDebuff", Color3.fromRGB(255,180,50))
makePlToggle("🛡 Anti Desaceleração", "Burla armadilhas que reduzem sua velocidade", Color3.fromRGB(255,180,50), function(s) setAntiSlow(s) end)

-- ══════════════════════════════════════════════════════
-- GOD MOD v2 — vida REAL (imortalidade via restauração de HP)
-- 99 Nights usa servidor autoritativo para dano.
-- Solução: loop que seta Health = MaxHealth a cada frame.
-- Resultado: personagem toma dano mas recupera imediatamente.
-- ══════════════════════════════════════════════════════
local godModEnabled = false
local godModConn
local godModCharConn

local function setGodMod(state)
    godModEnabled = state
    if state then
        -- Desconecta loops antigos
        if godModConn then godModConn:Disconnect(); godModConn = nil end

        local function applyGodModToChar(ch)
            if not ch then return end
            local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end

            -- 1. Tenta inflar MaxHealth para um valor altíssimo (nem sempre funciona server-side)
            pcall(function()
                hum.MaxHealth = 1e9
                hum.Health    = 1e9
            end)

            -- 2. Conecta HealthChanged para restaurar instantaneamente no client
            hum.HealthChanged:Connect(function(newHp)
                if not godModEnabled then return end
                if newHp < hum.MaxHealth then
                    pcall(function() hum.Health = hum.MaxHealth end)
                end
            end)

            -- 3. Loop de heartbeat como segurança extra (restaura a cada frame)
            if godModConn then godModConn:Disconnect() end
            godModConn = RunService.Heartbeat:Connect(function()
                if not godModEnabled then return end
                pcall(function()
                    local c2 = Player.Character; if not c2 then return end
                    local h2 = c2:FindFirstChildWhichIsA("Humanoid"); if not h2 then return end
                    if h2.Health > 0 and h2.Health < h2.MaxHealth then
                        h2.Health = h2.MaxHealth
                    end
                end)
            end)
        end

        -- Aplica ao personagem atual
        applyGodModToChar(Player.Character)

        -- Reaplica ao renascer
        if godModCharConn then godModCharConn:Disconnect() end
        godModCharConn = Player.CharacterAdded:Connect(function(ch)
            if not godModEnabled then return end
            task.wait(0.5)
            applyGodModToChar(ch)
        end)

        Notify.send({type="custom", icon="♾️", accent=Color3.fromRGB(140,255,140),
            title="God Mod ATIVO", msg="HP restaurado continuamente — você não morre!", duration=5})
    else
        if godModConn then godModConn:Disconnect(); godModConn = nil end
        if godModCharConn then godModCharConn:Disconnect(); godModCharConn = nil end
        -- Restaura MaxHealth ao normal
        pcall(function()
            local ch = Player.Character; if not ch then return end
            local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
            hum.MaxHealth = 100
            hum.Health    = 100
        end)
        Notify.info("♾️ God Mod", "Desativado — HP normal restaurado.")
    end
end

makePlSec("plSecGod", Color3.fromRGB(140,255,140))
makePlToggle("👻 God Mod", "Invisível para todos os mobs — eles não detectam, não atacam", Color3.fromRGB(140,255,140), function(s) setGodMod(s) end)

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
                    count += 1
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
makePlSec("🎁  BAÚS", ACS_COR)

-- Card estilo Kill Aura (sem slider, só toggle + info lateral)
local acsCard = Instance.new("Frame", Pages["Player"])
acsCard.BackgroundColor3 = Color3.fromRGB(28,22,14)
acsCard.BorderSizePixel  = 0
acsCard.Size             = UDim2.new(1,0,0,82)
acsCard.LayoutOrder      = plNextLO()
acsCard.ZIndex           = 5
Instance.new("UICorner",acsCard).CornerRadius = UDim.new(0,9)
local acsStroke = Instance.new("UIStroke",acsCard)
acsStroke.Color = Color3.fromRGB(80,60,20); acsStroke.Thickness = 1

-- Gradiente sutil
local acsGrad = Instance.new("Frame",acsCard)
acsGrad.BackgroundColor3 = ACS_COR; acsGrad.BackgroundTransparency = 0.92
acsGrad.BorderSizePixel  = 0; acsGrad.Size = UDim2.new(1,0,1,0); acsGrad.ZIndex = 5
Instance.new("UICorner",acsGrad).CornerRadius = UDim.new(0,9)

-- Título
local acsTitLbl = Instance.new("TextLabel",acsCard); acsTitLbl.BackgroundTransparency = 1
acsTitLbl.Position = UDim2.new(0,14,0,8); acsTitLbl.Size = UDim2.new(0.52,0,0,18)
acsTitLbl.Font = Enum.Font.GothamBold; acsTitLbl.Text = "🎁  Baús ACS"
acsTitLbl.TextColor3 = Color3.fromRGB(255,230,150); acsTitLbl.TextSize = 12
acsTitLbl.TextXAlignment = Enum.TextXAlignment.Left; acsTitLbl.ZIndex = 7

-- Desc
local acsDescLbl = Instance.new("TextLabel",acsCard); acsDescLbl.BackgroundTransparency = 1
acsDescLbl.Position = UDim2.new(0,14,0,28); acsDescLbl.Size = UDim2.new(0.52,0,0,30)
acsDescLbl.Font = Enum.Font.Gotham
acsDescLbl.Text = "Abre TODOS os baús do mapa automaticamente. Novos baús são abertos ao aparecer."
acsDescLbl.TextColor3 = Color3.fromRGB(90,100,120); acsDescLbl.TextSize = 9
acsDescLbl.TextXAlignment = Enum.TextXAlignment.Left; acsDescLbl.TextWrapped = true; acsDescLbl.ZIndex = 7

-- Toggle pill
local acsPill = Instance.new("Frame",acsCard); acsPill.BorderSizePixel = 0
acsPill.Position = UDim2.new(0,14,0,60); acsPill.Size = UDim2.new(0,48,0,16); acsPill.ZIndex = 9
Instance.new("UICorner",acsPill).CornerRadius = UDim.new(1,0)
acsPill.BackgroundColor3 = Color3.fromRGB(45,50,62)
local acsKnob = Instance.new("Frame",acsPill); acsKnob.BorderSizePixel = 0
acsKnob.Position = UDim2.new(0,1,0.5,-7); acsKnob.Size = UDim2.new(0,14,0,14); acsKnob.ZIndex = 10
Instance.new("UICorner",acsKnob).CornerRadius = UDim.new(1,0)
acsKnob.BackgroundColor3 = Color3.fromRGB(160,170,185)

-- Status label
local acsStatus = Instance.new("TextLabel",acsCard); acsStatus.BackgroundTransparency = 1
acsStatus.Position = UDim2.new(0,68,0,60); acsStatus.Size = UDim2.new(0,60,0,16)
acsStatus.Font = Enum.Font.GothamBlack; acsStatus.TextSize = 8; acsStatus.ZIndex = 9
acsStatus.TextXAlignment = Enum.TextXAlignment.Left
acsStatus.Text = "INATIVO"; acsStatus.TextColor3 = Color3.fromRGB(80,90,110)

-- Divisória vertical
local acsDivV = Instance.new("Frame",acsCard); acsDivV.BackgroundColor3 = Color3.fromRGB(80,60,20)
acsDivV.BorderSizePixel = 0; acsDivV.Position = UDim2.new(0.52,0,0,8)
acsDivV.Size = UDim2.new(0,1,1,-16); acsDivV.ZIndex = 6

-- Info lado direito
local acsInfoTitle = Instance.new("TextLabel",acsCard); acsInfoTitle.BackgroundTransparency = 1
acsInfoTitle.Position = UDim2.new(0.54,0,0,8); acsInfoTitle.Size = UDim2.new(0.44,-8,0,14)
acsInfoTitle.Font = Enum.Font.GothamBold; acsInfoTitle.Text = "Como funciona"
acsInfoTitle.TextColor3 = ACS_COR; acsInfoTitle.TextSize = 9
acsInfoTitle.TextXAlignment = Enum.TextXAlignment.Left; acsInfoTitle.ZIndex = 7

local acsInfo1 = Instance.new("TextLabel",acsCard); acsInfo1.BackgroundTransparency = 1
acsInfo1.Position = UDim2.new(0.54,0,0,26); acsInfo1.Size = UDim2.new(0.44,-8,0,12)
acsInfo1.Font = Enum.Font.Gotham; acsInfo1.Text = "• Abre todos ao ativar"
acsInfo1.TextColor3 = Color3.fromRGB(160,170,140); acsInfo1.TextSize = 8
acsInfo1.TextXAlignment = Enum.TextXAlignment.Left; acsInfo1.ZIndex = 7

local acsInfo2 = Instance.new("TextLabel",acsCard); acsInfo2.BackgroundTransparency = 1
acsInfo2.Position = UDim2.new(0.54,0,0,40); acsInfo2.Size = UDim2.new(0.44,-8,0,12)
acsInfo2.Font = Enum.Font.Gotham; acsInfo2.Text = "• Novos baús: abertos sozinhos"
acsInfo2.TextColor3 = Color3.fromRGB(160,170,140); acsInfo2.TextSize = 8
acsInfo2.TextXAlignment = Enum.TextXAlignment.Left; acsInfo2.ZIndex = 7

local acsInfo3 = Instance.new("TextLabel",acsCard); acsInfo3.BackgroundTransparency = 1
acsInfo3.Position = UDim2.new(0.54,0,0,54); acsInfo3.Size = UDim2.new(0.44,-8,0,12)
acsInfo3.Font = Enum.Font.Gotham; acsInfo3.Text = "• Desative para parar"
acsInfo3.TextColor3 = Color3.fromRGB(160,170,140); acsInfo3.TextSize = 8
acsInfo3.TextXAlignment = Enum.TextXAlignment.Left; acsInfo3.ZIndex = 7

-- Botão toggle (clicável)
local acsBtnClick = Instance.new("TextButton",acsCard); acsBtnClick.BackgroundTransparency = 1
acsBtnClick.Position = UDim2.new(0,0,0,0); acsBtnClick.Size = UDim2.new(0.52,0,1,0)
acsBtnClick.Text = ""; acsBtnClick.ZIndex = 11

acsBtnClick.MouseButton1Click:Connect(function()
    acsEnabled = not acsEnabled
    TweenService:Create(acsPill,TweenInfo.new(0.22),{
        BackgroundColor3 = acsEnabled and ACS_COR or Color3.fromRGB(45,50,62)
    }):Play()
    TweenService:Create(acsKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position = acsEnabled and UDim2.new(1,-15,0.5,-7) or UDim2.new(0,1,0.5,-7),
        BackgroundColor3 = acsEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
    }):Play()
    TweenService:Create(acsStroke,TweenInfo.new(0.2),{
        Color = acsEnabled and ACS_COR or Color3.fromRGB(80,60,20)
    }):Play()
    acsStatus.Text       = acsEnabled and "ATIVO"   or "INATIVO"
    acsStatus.TextColor3 = acsEnabled and ACS_COR   or Color3.fromRGB(80,90,110)

    if acsEnabled then
        if not acsRemote then
            -- Tenta achar o remote de novo caso o jogo ainda estivesse carregando
            pcall(function()
                acsRemote = game:GetService("ReplicatedStorage")
                    .RemoteEvents.RequestOpenItemChest
            end)
        end
        startACS()
        Notify.send({type="custom", icon="🎁", accent=ACS_COR,
            title="Baús ACS", msg="Ativado — abrindo todos os baús!", duration=4})
    else
        stopACS()
        Notify.info("Baús ACS", "Desativado.")
    end
end)

end -- Baús ACS

end -- [[ PLAYER TAB ]]

-- ══════════════════════════════════════════════════════
-- AIMBOT
-- ══════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════
-- TELEPORTAR TAB
-- ══════════════════════════════════════════════════════════════
do -- [[ TELEPORTAR TAB ]]

local TP_COR_CAMP   = Color3.fromRGB(255, 180, 60)
local TP_COR_VOLC   = Color3.fromRGB(255, 90, 40)
local TP_COR_FOREST = Color3.fromRGB(80, 200, 100)
local TP_COR_CAVE   = Color3.fromRGB(160, 120, 255)
local TP_COR_FAIRY  = Color3.fromRGB(220, 100, 255)
local TP_COR_CHILD  = Color3.fromRGB(100, 200, 255)
local TP_COR_BUILD  = Color3.fromRGB(180, 210, 255)

local tpLO = 0
local function tpNextLO() tpLO += 1; return tpLO end

-- Helper: helper de seção
local function makeTpSec(titleTxt, cor)
    local hdr = Instance.new("Frame", Pages["Teleportar"])
    hdr.BackgroundColor3 = Color3.fromRGB(20,22,30); hdr.BackgroundTransparency = 0.3
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

-- Helper: botão de TP compacto
local function makeTpBtn(icon, titleTxt, descTxt, cor, onClick)
    local card = Instance.new("Frame", Pages["Teleportar"])
    card.BackgroundColor3 = Color3.fromRGB(22,24,32); card.BorderSizePixel = 0
    card.Size = UDim2.new(1,0,0,58); card.LayoutOrder = tpNextLO(); card.ZIndex = 5
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,9)
    local stroke = Instance.new("UIStroke",card); stroke.Color = Color3.fromRGB(42,46,58); stroke.Thickness = 1

    -- Ícone colorido
    local iconBg = Instance.new("Frame",card); iconBg.BackgroundColor3 = cor
    iconBg.BackgroundTransparency = 0.78; iconBg.BorderSizePixel = 0
    iconBg.Position = UDim2.new(0,10,0.5,-18); iconBg.Size = UDim2.new(0,36,0,36); iconBg.ZIndex = 6
    Instance.new("UICorner",iconBg).CornerRadius = UDim.new(0,10)
    local iconLbl = Instance.new("TextLabel",iconBg); iconLbl.BackgroundTransparency = 1
    iconLbl.Size = UDim2.new(1,0,1,0); iconLbl.Font = Enum.Font.GothamBlack
    iconLbl.Text = icon; iconLbl.TextSize = 18; iconLbl.ZIndex = 7

    -- Título + desc
    local tl = Instance.new("TextLabel",card); tl.BackgroundTransparency = 1
    tl.Position = UDim2.new(0,54,0,8); tl.Size = UDim2.new(1,-120,0,18)
    tl.Font = Enum.Font.GothamBold; tl.Text = titleTxt
    tl.TextColor3 = Color3.fromRGB(220,225,240); tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 7
    local td = Instance.new("TextLabel",card); td.BackgroundTransparency = 1
    td.Position = UDim2.new(0,54,0,28); td.Size = UDim2.new(1,-120,0,22)
    td.Font = Enum.Font.Gotham; td.Text = descTxt
    td.TextColor3 = Color3.fromRGB(90,100,120); td.TextSize = 9
    td.TextXAlignment = Enum.TextXAlignment.Left; td.TextWrapped = true; td.ZIndex = 7

    -- Botão TP direita
    local btn = Instance.new("TextButton",card); btn.BackgroundColor3 = cor
    btn.BackgroundTransparency = 0.5; btn.BorderSizePixel = 0
    btn.Position = UDim2.new(1,-54,0.5,-14); btn.Size = UDim2.new(0,46,0,28); btn.ZIndex = 8
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,8)
    local btnL = Instance.new("TextLabel",btn); btnL.BackgroundTransparency = 1
    btnL.Size = UDim2.new(1,0,1,0); btnL.Font = Enum.Font.GothamBlack
    btnL.Text = "TP"; btnL.TextColor3 = Color3.fromRGB(255,255,255); btnL.TextSize = 12; btnL.ZIndex = 9

    -- Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundTransparency=0.1}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.12),{Color=cor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundTransparency=0.5}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.12),{Color=Color3.fromRGB(42,46,58)}):Play()
    end)
    btn.MouseButton1Click:Connect(onClick)

    -- Clique em qualquer parte do card também funciona
    local full = Instance.new("TextButton",card); full.BackgroundTransparency = 1
    full.Size = UDim2.new(1,-60,1,0); full.Text = ""; full.ZIndex = 10
    full.MouseButton1Click:Connect(onClick)

    return card, stroke
end

-- ──────────────────────────────────────────────
-- Função: encontrar a FOGUEIRA REAL (upgradável)
-- Estratégia: procura pelo Model que tem atributo
-- "Level" ou "CampfireLevel" — fogueiras decorativas
-- NUNCA têm esses atributos no 99 Nights
-- ──────────────────────────────────────────────
local function getCampfirePos()
    local best, bestScore = nil, -1

    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end
                local nm = obj.Name:lower()

                -- Descarta objetos claramente decorativos / de ambiente
                if nm:find("decor",1,true) or nm:find("ambient",1,true)
                or nm:find("fake",1,true)   or nm:find("particle",1,true)
                or nm:find("effect",1,true) or nm:find("campfire_small",1,true)
                or nm:find("minifire",1,true) then return end

                local score = 0

                -- Atributo Level = fogueira real (pontuação máxima)
                local hasAttr = false
                pcall(function()
                    local v = obj:GetAttribute("Level")
                           or obj:GetAttribute("CampfireLevel")
                           or obj:GetAttribute("FireLevel")
                           or obj:GetAttribute("Tier")
                    if v ~= nil then hasAttr = true end
                end)
                if hasAttr then score = score + 100 end

                -- Nome sugere fogueira principal
                if nm == "campfire" or nm == "mainfire" or nm == "camp fire"
                or nm == "main campfire" or nm == "centralfire" then
                    score = score + 30
                elseif nm:find("campfire",1,true) or nm:find("mainfire",1,true) then
                    score = score + 10
                end

                -- Está dentro de Campground = fogueira real
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

                -- Descarta score zero
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

    return best
end

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
-- 6. TP CRIANÇA — Teleporta para a criança capturada mais próxima (1 vez, desliga sozinho)
-- ──────────────────────────────────────────────────────────────
makeTpSec("👶  CRIANÇAS CAPTURADAS", TP_COR_CHILD)

-- Nomes das crianças — confirmados (wiki oficial + nome interno workspace)
-- Ordem: 1=Dino Kid, 2=Kraken Kid, 3=Squid Kid, 4=Koala Kid
local CHILD_NAMES = {
    -- ✅ Nomes internos confirmados pelo workspace (child. 1 2 3 4)
    "child. 1", "child. 2", "child. 3", "child. 4",
    -- ✅ Nomes visuais oficiais (wiki 99 Nights in the Forest)
    "dino kid",   "dinokid",
    "kraken kid", "krakenkid",
    "squid kid",  "squidkid",
    "koala kid",  "koalakid",
    -- Variações sem ponto / sem espaço (fallback)
    "child 1", "child 2", "child 3", "child 4",
    "child1",  "child2",  "child3",  "child4",
    "child.",  "child",
}

local tpChildActive = false
local tpChildCard, tpChildStroke, tpChildBtn, tpChildBtnL

-- isPlayerChar inline (evita dependência de definição posterior)
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

local function findNearestCapturedChild()
    local ch  = Player.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local myPos = hrp.Position
    local best, bestScore = nil, -1

    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if not obj:IsA("Model") then return end
            if isPlayerCharLocal(obj)  then return end
            if isRescued(obj)          then return end

            local hum = obj:FindFirstChildWhichIsA("Humanoid")
            if not hum or hum.Health <= 0 then return end

            local nm    = obj.Name
            local score = 0

            -- Pontuação por nome
            if isChildName(nm) then
                score = score + 10
            end

            -- Pontuação por atributos típicos de criança
            pcall(function()
                if obj:GetAttribute("IsChild")   == true then score = score + 8 end
                if obj:GetAttribute("IsMissing") == true then score = score + 6 end
                if obj:GetAttribute("Child")     == true then score = score + 6 end
            end)

            -- Descartar mobs grandes (animais têm Health alto e grande porte)
            -- Crianças normalmente têm Health <= 100
            if hum.MaxHealth > 200 then score = score - 5 end

            -- Qualquer NPC humanóide tem score mínimo como fallback
            if score == 0 then score = 1 end

            local p = obj:FindFirstChild("HumanoidRootPart")
                   or obj:FindFirstChildWhichIsA("BasePart")
            if not p then return end

            -- Bônus por proximidade
            local dist = (p.Position - myPos).Magnitude
            local distBonus = math.max(0, 1 - dist / 5000)
            local total = score + distBonus

            if total > bestScore then
                bestScore = total
                best = p
            end
        end)
    end

    -- Se não achou nada por nome/atributo, avisa
    return best
end

-- Card especial para Tp Criança com indicador de estado
tpChildCard = Instance.new("Frame", Pages["Teleportar"])
tpChildCard.BackgroundColor3 = Color3.fromRGB(22,24,32); tpChildCard.BorderSizePixel = 0
tpChildCard.Size = UDim2.new(1,0,0,70); tpChildCard.LayoutOrder = tpNextLO(); tpChildCard.ZIndex = 5
Instance.new("UICorner",tpChildCard).CornerRadius = UDim.new(0,9)
tpChildStroke = Instance.new("UIStroke",tpChildCard); tpChildStroke.Color = Color3.fromRGB(42,46,58); tpChildStroke.Thickness = 1

local chIconBg = Instance.new("Frame",tpChildCard); chIconBg.BackgroundColor3 = TP_COR_CHILD
chIconBg.BackgroundTransparency = 0.78; chIconBg.BorderSizePixel = 0
chIconBg.Position = UDim2.new(0,10,0.5,-20); chIconBg.Size = UDim2.new(0,40,0,40); chIconBg.ZIndex = 6
Instance.new("UICorner",chIconBg).CornerRadius = UDim.new(0,12)
local chIconLbl = Instance.new("TextLabel",chIconBg); chIconLbl.BackgroundTransparency = 1
chIconLbl.Size = UDim2.new(1,0,1,0); chIconLbl.Text = "👶"; chIconLbl.TextSize = 20; chIconLbl.ZIndex = 7

local chTitle = Instance.new("TextLabel",tpChildCard); chTitle.BackgroundTransparency = 1
chTitle.Position = UDim2.new(0,58,0,8); chTitle.Size = UDim2.new(0.5,0,0,18)
chTitle.Font = Enum.Font.GothamBold; chTitle.Text = "Tp Criança"
chTitle.TextColor3 = Color3.fromRGB(220,225,240); chTitle.TextSize = 12
chTitle.TextXAlignment = Enum.TextXAlignment.Left; chTitle.ZIndex = 7

local chDesc = Instance.new("TextLabel",tpChildCard); chDesc.BackgroundTransparency = 1
chDesc.Position = UDim2.new(0,58,0,28); chDesc.Size = UDim2.new(0.55,0,0,30)
chDesc.Font = Enum.Font.Gotham; chDesc.Text = "Teleporta para a criança capturada mais próxima (1 vez)"
chDesc.TextColor3 = Color3.fromRGB(90,100,120); chDesc.TextSize = 9
chDesc.TextXAlignment = Enum.TextXAlignment.Left; chDesc.TextWrapped = true; chDesc.ZIndex = 7

-- Indicador de status (ponto pulsante)
local chStatusDot = Instance.new("Frame",tpChildCard); chStatusDot.BackgroundColor3 = Color3.fromRGB(90,100,120)
chStatusDot.BorderSizePixel = 0; chStatusDot.AnchorPoint = Vector2.new(0.5,0.5)
chStatusDot.Position = UDim2.new(1,-66,0.5,-8); chStatusDot.Size = UDim2.new(0,8,0,8); chStatusDot.ZIndex = 8
Instance.new("UICorner",chStatusDot).CornerRadius = UDim.new(1,0)

-- Botão TP Criança
tpChildBtn = Instance.new("TextButton",tpChildCard); tpChildBtn.BackgroundColor3 = TP_COR_CHILD
tpChildBtn.BackgroundTransparency = 0.5; tpChildBtn.BorderSizePixel = 0
tpChildBtn.Position = UDim2.new(1,-58,0.5,-14); tpChildBtn.Size = UDim2.new(0,50,0,28); tpChildBtn.ZIndex = 8
Instance.new("UICorner",tpChildBtn).CornerRadius = UDim.new(0,8)
tpChildBtnL = Instance.new("TextLabel",tpChildBtn); tpChildBtnL.BackgroundTransparency = 1
tpChildBtnL.Size = UDim2.new(1,0,1,0); tpChildBtnL.Font = Enum.Font.GothamBlack
tpChildBtnL.Text = "TP"; tpChildBtnL.TextColor3 = Color3.fromRGB(255,255,255); tpChildBtnL.TextSize = 12; tpChildBtnL.ZIndex = 9

tpChildBtn.MouseButton1Click:Connect(function()
    tpChildBtnL.Text = "..."
    local target = findNearestCapturedChild()
    if target then
        safeTp(target.Position, 3)
        tpChildActive = false
        TweenService:Create(tpChildStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(42,46,58)}):Play()
        TweenService:Create(chStatusDot,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(90,100,120)}):Play()
        tpChildBtnL.Text = "✓"
        task.delay(1.5, function() tpChildBtnL.Text = "TP" end)
        Notify.send({type="custom",icon="👶",accent=TP_COR_CHILD,
            title="Tp Criança",msg="Teleportado para: "..target.Parent.Name,duration=3})
    else
        tpChildBtnL.Text = "TP"
        -- Debug: lista todos os NPCs com Humanoid no console
        local found = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("Model") and obj:FindFirstChildWhichIsA("Humanoid") then
                    local isPlayer = false
                    for _, pl in ipairs(game:GetService("Players"):GetPlayers()) do
                        if pl.Character == obj then isPlayer = true end
                    end
                    if not isPlayer then
                        table.insert(found, obj.Name)
                    end
                end
            end)
        end
        if #found > 0 then
            warn("🔍 [Tp Criança] NPCs com Humanoid encontrados no workspace:")
            for _, n in ipairs(found) do warn("  • "..n) end
            warn("  → Cole os nomes acima pra corrigir a busca!")
        end
        Notify.warn("Tp Criança","⚠️ Criança não encontrada! Verifique o console (F9) para ver os NPCs do mapa.")
    end
end)

-- ──────────────────────────────────────────────────────────────
-- 7. PAINEL DE CONSTRUÇÕES — dinâmico, complexo e profissional
-- ──────────────────────────────────────────────────────────────
makeTpSec("🏗️  PAINEL DE CONSTRUÇÕES", TP_COR_BUILD)

-- Lista de nomes de estruturas conhecidas (wiki + jogo)
local KNOWN_STRUCTURES = {
    -- Abrigos e cabanas
    "Small Shed","SmallShed","Wooden Shed","WoodenShed",
    "Medium Cabin","MediumCabin","Large Cabin","LargeCabin",
    "Fishing Cabin","FishingCabin","Hunter Cabin","HunterCabin",
    "Old Cabin","OldCabin","Abandoned Cabin","AbandonedCabin",
    "Cabin","House","Hut","Shack","Cottage","Bungalow","Chalet",
    -- Torres e postos
    "Watchtower","WatchTower","Water Tower","WaterTower",
    "Armory","Lookout Tower","LookoutTower","Guard Tower","GuardTower",
    "Bell Tower","BellTower","Radio Tower","RadioTower",
    -- Construções civis
    "Bank","Barn","Clinic","Hospital","School","Church",
    "Basketball Court","BasketballCourt","Playground","Restroom",
    "Food Warehouse","FoodWarehouse","Storage","Depot",
    "Gas Station","GasStation","Diner","Bakery","Market","Shop",
    -- Acampamentos e instalações ao ar livre
    "Abandoned Camp","AbandonedCamp","Ranger Camp","RangerCamp",
    "Hunter Camp","HunterCamp","Military Camp","MilitaryCamp",
    "Tent","Outpost","Checkpoint","Barricade",
    -- Subterrâneos e minas
    "Mineshaft","Mine Shaft","Mine","Cave","Cavern","Bunker","Tunnel",
    "Underground Base","UndergroundBase",
    -- Estruturas especiais do jogo
    "Cultist Stronghold","CultistStronghold",
    "Cultist Tower","CultistTower","Cultist King Base","CultistKingBase",
    "Cultist Base","CultistBase","Cultist Temple","CultistTemple",
    "Broken UFO","BrokenUFO","Mothership UFO","MothershipUFO","UFO",
    "Meteor Crater","MeteorCrater",
    "Ammo Furnace","AmmoFurnace","Volcanic Church","VolcanicChurch",
    "Lava Pool","LavaPool","Lava Fall","LavaFall",
    "Lava-Isolated Chest","Scorpion Pit","ScorpionPit",
    -- Fazendas e natureza
    "Farm","Greenhouse","Windmill","Stable","Silo",
    "Plane Wreckage","PlaneWreckage","Plane Crash","PlaneCrash","Wreckage",
    -- Pontes e colinas
    "Bridge","Dam","Dock","Harbor","Lighthouse",
    -- Poças e ponds
    "Fresh Pond","FreshPond","Algal Pond","AlgalPond","Bone Pond","BonePond",
    "Cold Pond","ColdPond","Frog Pond","FrogPond","Hot Spring","HotSpring",
    -- Ruínas e abandonados
    "Abandoned Animal Shelter","AbandonedAnimalShelter",
    "Abandoned Pillars","AbandonedPillars","Ruins","Ancient Ruins",
    "Old Fort","OldFort","Fortress","Castle","Keep",
}

-- Keywords para scan dinâmico: qualquer Model cujo nome contenha esses termos
local BUILDING_KEYWORDS = {
    "cabin","shed","house","hut","shack","cottage","bungalow","chalet",
    "tower","watchtower","lighthouse","church","barn","farm","silo",
    "clinic","hospital","bank","depot","warehouse","market","shop",
    "camp","outpost","checkpoint","base","fort","fortress","stronghold","temple",
    "bunker","mine","mineshaft","cave","cavern","tunnel",
    "ruins","ruin","wreckage","crash","crater","pit","pond","pool",
    "armory","barricade","playground","restroom","court","bakery","diner",
    "ufo","alien","cultist","volcanic",
}

local buildingButtons = {}       -- { name, pos, btn, lastVisited }
local buildingSeenKeys = {}      -- set de chaves posição já adicionadas (evita duplicar MESMO ponto)
local tpLastBuilding = nil       -- último botão clicado

-- Gera chave única por posição (grid de 8 studs — cobre mesmo building)
local function posKey(pos)
    return math.floor(pos.X/8)..","..math.floor(pos.Y/8)..","..math.floor(pos.Z/8)
end

-- Container do painel
local buildPanelCard = Instance.new("Frame", Pages["Teleportar"])
buildPanelCard.BackgroundColor3 = Color3.fromRGB(18,20,28); buildPanelCard.BorderSizePixel = 0
buildPanelCard.Size = UDim2.new(1,0,0,320); buildPanelCard.LayoutOrder = tpNextLO(); buildPanelCard.ZIndex = 5
Instance.new("UICorner",buildPanelCard).CornerRadius = UDim.new(0,12)
local panelStroke = Instance.new("UIStroke",buildPanelCard); panelStroke.Color = Color3.fromRGB(60,80,120); panelStroke.Thickness = 1.5

-- Header do painel
local panelHdr = Instance.new("Frame",buildPanelCard); panelHdr.BackgroundColor3 = Color3.fromRGB(25,30,50)
panelHdr.BorderSizePixel = 0; panelHdr.Size = UDim2.new(1,0,0,44); panelHdr.ZIndex = 6
Instance.new("UICorner",panelHdr).CornerRadius = UDim.new(0,10)
-- Canto inferior do header fica reto
local panelHdrFix = Instance.new("Frame",panelHdr); panelHdrFix.BackgroundColor3 = Color3.fromRGB(25,30,50)
panelHdrFix.BorderSizePixel = 0; panelHdrFix.Position = UDim2.new(0,0,0.5,0)
panelHdrFix.Size = UDim2.new(1,0,0.5,0); panelHdrFix.ZIndex = 6

local panelTitle = Instance.new("TextLabel",panelHdr); panelTitle.BackgroundTransparency = 1
panelTitle.Position = UDim2.new(0,14,0,0); panelTitle.Size = UDim2.new(0.5,0,1,0)
panelTitle.Font = Enum.Font.GothamBlack; panelTitle.Text = "🏗 Construções"
panelTitle.TextColor3 = TP_COR_BUILD; panelTitle.TextSize = 12
panelTitle.TextXAlignment = Enum.TextXAlignment.Left; panelTitle.ZIndex = 7

local panelCount = Instance.new("TextLabel",panelHdr); panelCount.BackgroundTransparency = 1
panelCount.Position = UDim2.new(0.5,0,0,4); panelCount.Size = UDim2.new(0.25,0,0.6,0)
panelCount.Font = Enum.Font.GothamSemibold; panelCount.Text = "0 encontradas"
panelCount.TextColor3 = Color3.fromRGB(120,140,180); panelCount.TextSize = 9
panelCount.TextXAlignment = Enum.TextXAlignment.Right; panelCount.ZIndex = 7

-- Botões de controle no header
local btnRefresh = Instance.new("TextButton",panelHdr); btnRefresh.BackgroundColor3 = Color3.fromRGB(60,100,200)
btnRefresh.BackgroundTransparency = 0.5; btnRefresh.BorderSizePixel = 0
btnRefresh.Position = UDim2.new(1,-84,0.5,-12); btnRefresh.Size = UDim2.new(0,36,0,24); btnRefresh.ZIndex = 8
Instance.new("UICorner",btnRefresh).CornerRadius = UDim.new(0,7)
local btnRefreshL = Instance.new("TextLabel",btnRefresh); btnRefreshL.BackgroundTransparency = 1
btnRefreshL.Size = UDim2.new(1,0,1,0); btnRefreshL.Font = Enum.Font.GothamBold
btnRefreshL.Text = "🔄"; btnRefreshL.TextColor3 = Color3.fromRGB(200,220,255); btnRefreshL.TextSize = 13; btnRefreshL.ZIndex = 9

local btnClear = Instance.new("TextButton",panelHdr); btnClear.BackgroundColor3 = Color3.fromRGB(200,60,60)
btnClear.BackgroundTransparency = 0.6; btnClear.BorderSizePixel = 0
btnClear.Position = UDim2.new(1,-44,0.5,-12); btnClear.Size = UDim2.new(0,36,0,24); btnClear.ZIndex = 8
Instance.new("UICorner",btnClear).CornerRadius = UDim.new(0,7)
local btnClearL = Instance.new("TextLabel",btnClear); btnClearL.BackgroundTransparency = 1
btnClearL.Size = UDim2.new(1,0,1,0); btnClearL.Font = Enum.Font.GothamBold
btnClearL.Text = "🗑️"; btnClearL.TextColor3 = Color3.fromRGB(255,180,180); btnClearL.TextSize = 13; btnClearL.ZIndex = 9

-- Área de scroll para os botões de construção
local buildScroll = Instance.new("ScrollingFrame",buildPanelCard); buildScroll.BackgroundTransparency = 1
buildScroll.BorderSizePixel = 0; buildScroll.Position = UDim2.new(0,6,0,48)
buildScroll.Size = UDim2.new(1,-12,0,264); buildScroll.ZIndex = 6
buildScroll.ScrollBarThickness = 3; buildScroll.ScrollBarImageColor3 = TP_COR_BUILD
buildScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; buildScroll.CanvasSize = UDim2.new(0,0,0,0)
local buildLayout = Instance.new("UIListLayout",buildScroll)
buildLayout.Padding = UDim.new(0,4); buildLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Label "vazio"
local buildEmptyLbl = Instance.new("TextLabel",buildScroll); buildEmptyLbl.BackgroundTransparency = 1
buildEmptyLbl.Size = UDim2.new(1,0,0,60); buildEmptyLbl.Font = Enum.Font.GothamSemibold
buildEmptyLbl.Text = "Clique em ↻ para escanear o mapa"
buildEmptyLbl.TextColor3 = Color3.fromRGB(80,90,120); buildEmptyLbl.TextSize = 11
buildEmptyLbl.TextWrapped = true; buildEmptyLbl.ZIndex = 7; buildEmptyLbl.LayoutOrder = 1

-- Função: criar botão de construção
local function makeBuildingBtn(name, pos, isNew)
    local lo = #buildingButtons + 1

    local row = Instance.new("Frame",buildScroll); row.BackgroundColor3 = Color3.fromRGB(28,32,45)
    row.BorderSizePixel = 0; row.Size = UDim2.new(1,0,0,38); row.ZIndex = 7; row.LayoutOrder = lo
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)
    local rowS = Instance.new("UIStroke",row); rowS.Color = Color3.fromRGB(50,60,90); rowS.Thickness = 1

    -- Ícone da construção
    local ico = Instance.new("TextLabel",row); ico.BackgroundTransparency = 1
    ico.Position = UDim2.new(0,6,0.5,-10); ico.Size = UDim2.new(0,20,0,20)
    ico.Font = Enum.Font.GothamBlack; ico.TextSize = 14; ico.ZIndex = 8
    -- Escolhe ícone por tipo
    local icMap = {
        shed="🪵", cabin="🏠", tower="🗼", warehouse="📦", barn="🏚",
        bank="🏦", clinic="🏥", farm="🌾", playground="🎠", pond="🐟",
        ufo="🛸", volcano="🌋", mine="⛏️", cave="⛏️", camp="⛺",
        church="⛪", crater="☄️", stronghold="🏯", armory="⚔️",
        court="🏀", restroom="🚻", shelter="🐾", default="🏗️"
    }
    local nameLow = name:lower()
    local icon = icMap.default
    for k, v in pairs(icMap) do if nameLow:find(k) then icon = v; break end end
    ico.Text = icon

    -- Nome da construção
    local nameLbl = Instance.new("TextLabel",row); nameLbl.BackgroundTransparency = 1
    nameLbl.Position = UDim2.new(0,30,0,4); nameLbl.Size = UDim2.new(0.58,0,0,16)
    nameLbl.Font = Enum.Font.GothamSemibold; nameLbl.Text = name
    nameLbl.TextColor3 = Color3.fromRGB(200,210,235); nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.TextTruncate = Enum.TextTruncate.AtEnd; nameLbl.ZIndex = 8

    -- Distância
    local distLbl = Instance.new("TextLabel",row); distLbl.BackgroundTransparency = 1
    distLbl.Position = UDim2.new(0,30,0,20); distLbl.Size = UDim2.new(0.4,0,0,14)
    distLbl.Font = Enum.Font.Gotham; distLbl.TextColor3 = Color3.fromRGB(80,100,140)
    distLbl.TextSize = 9; distLbl.TextXAlignment = Enum.TextXAlignment.Left; distLbl.ZIndex = 8
    pcall(function()
        local ch = Player.Character; local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            local d = math.floor((pos - hrp.Position).Magnitude)
            distLbl.Text = d.."m de distância"
        end
    end)

    -- Etiqueta NOVA / ANTIGA no topo direito
    local tagBadge = Instance.new("Frame",row); tagBadge.BorderSizePixel = 0
    tagBadge.AnchorPoint = Vector2.new(1,0); tagBadge.Position = UDim2.new(1,-44,0,4)
    tagBadge.Size = UDim2.new(0,42,0,14); tagBadge.ZIndex = 9
    Instance.new("UICorner",tagBadge).CornerRadius = UDim.new(0,4)
    local tagLbl = Instance.new("TextLabel",tagBadge); tagLbl.BackgroundTransparency = 1
    tagLbl.Size = UDim2.new(1,0,1,0); tagLbl.Font = Enum.Font.GothamBlack; tagLbl.TextSize = 8; tagLbl.ZIndex = 10

    if isNew then
        tagBadge.BackgroundColor3 = Color3.fromRGB(60,200,120)
        tagLbl.Text = "NOVA"; tagLbl.TextColor3 = Color3.fromRGB(20,60,30)
    else
        tagBadge.BackgroundColor3 = Color3.fromRGB(60,70,100)
        tagLbl.Text = ""; tagLbl.TextColor3 = Color3.fromRGB(180,180,200)
        tagBadge.Visible = false
    end

    -- Botão de TP
    local tpb = Instance.new("TextButton",row); tpb.BackgroundColor3 = TP_COR_BUILD
    tpb.BackgroundTransparency = 0.6; tpb.BorderSizePixel = 0
    tpb.Position = UDim2.new(1,-38,0.5,-12); tpb.Size = UDim2.new(0,32,0,24); tpb.ZIndex = 8
    Instance.new("UICorner",tpb).CornerRadius = UDim.new(0,7)
    local tpbL = Instance.new("TextLabel",tpb); tpbL.BackgroundTransparency = 1
    tpbL.Size = UDim2.new(1,0,1,0); tpbL.Font = Enum.Font.GothamBlack
    tpbL.Text = "TP"; tpbL.TextColor3 = Color3.fromRGB(255,255,255); tpbL.TextSize = 11; tpbL.ZIndex = 9

    local entry = {name=name, pos=pos, row=row, tagBadge=tagBadge, tagLbl=tagLbl, tpb=tpb, isNew=isNew, visited=false}
    table.insert(buildingButtons, entry)

    local function doTp()
        -- Remove etiqueta NOVA imediatamente (sem tween)
        if entry.isNew then
            entry.isNew = false
            tagBadge.Visible = false
        end
        -- Marca o anterior como ANTIGA imediatamente
        if tpLastBuilding and tpLastBuilding ~= entry and tpLastBuilding.visited then
            tpLastBuilding.tagBadge.BackgroundColor3 = Color3.fromRGB(80,60,40)
            tpLastBuilding.tagLbl.Text = "ANTIGA"
            tpLastBuilding.tagLbl.TextColor3 = Color3.fromRGB(220,180,120)
            tpLastBuilding.tagBadge.Visible = true
            tpLastBuilding.isNew = false  -- garante que não vira NOVA de novo
        end
        safeTp(pos, 55)
        entry.visited = true
        entry.isNew = false  -- visitado = nunca mais vira NOVA
        tpLastBuilding = entry
        TweenService:Create(tpb,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0}):Play()
        task.delay(0.3,function()
            TweenService:Create(tpb,TweenInfo.new(0.2),{BackgroundColor3=TP_COR_BUILD,BackgroundTransparency=0.6}):Play()
        end)
        Notify.send({type="custom",icon="🏗️",accent=TP_COR_BUILD,
            title="Construção",msg=name.." — 55 studs acima!",duration=2.5})
    end
    tpb.MouseButton1Click:Connect(doTp)
    local rowBtn = Instance.new("TextButton",row); rowBtn.BackgroundTransparency=1
    rowBtn.Size=UDim2.new(1,-44,1,0); rowBtn.Text=""; rowBtn.ZIndex=8
    rowBtn.MouseButton1Click:Connect(doTp)

    return entry
end

-- Função: escanear workspace por construções
local scanRunning = false
local function scanBuildings(isRefresh)
    if scanRunning then return end
    scanRunning = true
    btnRefreshL.Text = "⏳"; task.delay(0.8, function() btnRefreshL.Text = "🔄" end)

    task.spawn(function()
        local found = 0
        local knownLookup = {}
        for _, sn in ipairs(KNOWN_STRUCTURES) do knownLookup[sn:lower()] = sn end

        local descs = workspace:GetDescendants()
        local batch = 0
        for _, obj in ipairs(descs) do
            batch += 1
            if batch % 500 == 0 then task.wait() end  -- yield menos frequente = mais rápido

            if not obj:IsA("Model") then continue end

            local oNameOrig = obj.Name
            local oNameLow  = oNameOrig:lower()

            -- Filtro: armadilhas fora
            if oNameLow:find("trap",1,true) or oNameLow:find("spike",1,true)
            or oNameLow:find("snare",1,true) or oNameLow:find("stake",1,true) then continue end

            -- É construção?
            local isBuilding = knownLookup[oNameLow] ~= nil
            if not isBuilding then
                for _, kw in ipairs(BUILDING_KEYWORDS) do
                    if oNameLow:find(kw, 1, true) then isBuilding = true; break end
                end
            end
            if not isBuilding then continue end

            -- Precisa de BasePart grande
            local part, bigEnough = nil, false
            for _, bp in ipairs(obj:GetDescendants()) do
                if bp:IsA("BasePart") then
                    if not part then part = bp end
                    local sz = bp.Size
                    if sz.X > 3 or sz.Y > 3 or sz.Z > 3 then bigEnough = true; part = bp; break end
                end
            end
            if not part or not bigEnough then continue end

            -- Tem Humanoid = NPC
            if obj:FindFirstChildWhichIsA("Humanoid") then continue end

            local pos = part.Position
            if pos.Y < -500 then continue end

            -- Deduplicação
            local pk = posKey(pos)
            if buildingSeenKeys[pk] then continue end
            buildingSeenKeys[pk] = true

            -- Preserva estado "visited/ANTIGA" se já existia esse nome+pos
            local wasVisited = false
            for _, ex in ipairs(buildingButtons) do
                if ex.name == oNameOrig and (ex.pos - pos).Magnitude < 10 then
                    wasVisited = ex.visited; break
                end
            end

            local entry = makeBuildingBtn(oNameOrig, pos, isRefresh and not wasVisited)
            if wasVisited then
                -- Já foi visitada antes do refresh: mantém ANTIGA
                entry.visited = true
                entry.isNew   = false
                entry.tagBadge.BackgroundColor3 = Color3.fromRGB(80,60,40)
                entry.tagLbl.Text = "ANTIGA"
                entry.tagLbl.TextColor3 = Color3.fromRGB(220,180,120)
                entry.tagBadge.Visible = true
            end

            found += 1
            buildEmptyLbl.Visible = false
            if found % 30 == 0 then task.wait() end
        end

        panelCount.Text = tostring(#buildingButtons).." encontrada(s)"
        if found == 0 and isRefresh then
            Notify.info("Painel","Nenhuma construção nova encontrada.")
        elseif found > 0 then
            local msg = isRefresh
                and (tostring(found).." nova(s) construção(ões) adicionadas!")
                or  (tostring(found).." construções encontradas!")
            Notify.send({type="custom",icon="🏗️",accent=TP_COR_BUILD,title="Painel de Construções",msg=msg,duration=3})
        end

        local contentH = #buildingButtons * 42 + 10
        buildPanelCard.Size = UDim2.new(1,0,0, math.clamp(48 + contentH, 100, 480))
        buildScroll.Size    = UDim2.new(1,-12,0, math.clamp(contentH, 40, 424))
        scanRunning = false
    end)
end

-- Botão atualizar
btnRefresh.MouseButton1Click:Connect(function()
    scanBuildings(true)
end)

-- Botão limpar
btnClear.MouseButton1Click:Connect(function()
    for _, entry in ipairs(buildingButtons) do
        pcall(function() entry.row:Destroy() end)
    end
    buildingButtons = {}
    buildingSeenKeys = {}
    tpLastBuilding = nil
    buildEmptyLbl.Visible = true
    panelCount.Text = "0 encontradas"
    buildPanelCard.Size = UDim2.new(1,0,0,320)
    buildScroll.Size = UDim2.new(1,-12,0,264)
    Notify.info("Painel","Lista de construções limpa!")
end)

-- Scan automático ao abrir a aba pela primeira vez
local buildingFirstOpen = true
-- Detecta quando a aba Teleportar fica visível
task.spawn(function()
    while true do
        task.wait(1)
        if Pages["Teleportar"] and Pages["Teleportar"].Visible and buildingFirstOpen then
            buildingFirstOpen = false
            task.wait(0.5)
            scanBuildings(false)
        end
    end
end)


-- ══════════════════════════════════════════════════════════════
-- PAINEL DE BAÚS — dados oficiais (wiki 99 Nights in the Forest)
-- Tipos Clássicos: Common → Good → Iron → Legendary → Gold → Ruby → Diamond
-- Tipos Exclusivos: Ice, Frog, Alien, Obsidiron, Corrupted, Research
-- ══════════════════════════════════════════════════════════════
local TP_COR_CHEST = Color3.fromRGB(255, 200, 60)

makeTpSec("🎁  PAINEL DE BAÚS", TP_COR_CHEST)

-- Tabela de raridade por nome oficial do baú (wiki confirmado Fev 2026)
local CHEST_RARITY = {
    -- ── Exclusivos máximos ──────────────────────────────────────
    { keywords={"obsidiron"},                   tier=10, label="Obsidiron",   tag="OBSIDIRON", cor=Color3.fromRGB(200,80,255),  icon="🔮" },
    { keywords={"fairy","enchanted","giant tree","mother tree","fada"}, tier=9, label="Fairy", tag="FAIRY", cor=Color3.fromRGB(180,255,200), icon="🧚" },
    { keywords={"alien"},                        tier=8,  label="Alien",      tag="ALIEN",     cor=Color3.fromRGB(80,255,180),  icon="🛸" },
    { keywords={"frog"},                         tier=8,  label="Frog",       tag="FROG",      cor=Color3.fromRGB(100,220,80),  icon="🐸" },
    { keywords={"ice chest","ice"},              tier=8,  label="Ice",        tag="ICE",       cor=Color3.fromRGB(160,230,255), icon="❄️" },
    { keywords={"thanksgiving"},                 tier=7,  label="Thanksgiving",tag="THANKS",   cor=Color3.fromRGB(255,150,50),  icon="🦃" },
    { keywords={"corrupted"},                    tier=7,  label="Corrupted",  tag="CORRUPT",   cor=Color3.fromRGB(180,50,50),   icon="☠️" },
    { keywords={"research"},                     tier=7,  label="Research",   tag="RESEARCH",  cor=Color3.fromRGB(120,180,255), icon="🔬" },
    -- ── Clássicos (ordem do mais raro ao mais comum) ─────────────
    { keywords={"diamond"},                      tier=7,  label="Diamond",    tag="DIAMOND",   cor=Color3.fromRGB(100,220,255), icon="💎" },
    { keywords={"ruby","strong chest"},          tier=6,  label="Ruby",       tag="RUBY",      cor=Color3.fromRGB(255,60,80),   icon="❤️‍🔥" },
    { keywords={"gold","golden"},                tier=5,  label="Gold",       tag="GOLD",      cor=Color3.fromRGB(255,200,20),  icon="👑" },
    { keywords={"legendary"},                    tier=4,  label="Legendary",  tag="LEGEND",    cor=Color3.fromRGB(180,80,255),  icon="✨" },
    { keywords={"iron","great"},                 tier=3,  label="Iron",       tag="IRON",      cor=Color3.fromRGB(140,180,220), icon="⚙️" },
    { keywords={"good"},                         tier=2,  label="Good",       tag="GOOD",      cor=Color3.fromRGB(80,200,100),  icon="📦" },
    { keywords={"common","item chest","chest"},  tier=1,  label="Common",     tag="COMMON",    cor=Color3.fromRGB(160,140,110), icon="📦" },
}

local function getRarity(chestModel)
    local nm = chestModel.Name:lower()
    -- Verifica pelo nome do Model
    for _, r in ipairs(CHEST_RARITY) do
        for _, kw in ipairs(r.keywords) do
            if nm:find(kw, 1, true) then return r end
        end
    end
    -- Verifica atributo Level/Tier como fallback
    local level = 0
    pcall(function()
        local v = chestModel:GetAttribute("Level")
              or chestModel:GetAttribute("Tier")
              or chestModel:GetAttribute("ChestLevel")
        if type(v) == "number" then level = v end
    end)
    for i = math.min(level, #CHEST_RARITY), 1, -1 do
        return CHEST_RARITY[i]
    end
    return CHEST_RARITY[#CHEST_RARITY] -- Common como default
end

-- Detecta bioma pelo caminho do objeto no workspace
local BIOME_KEYWORDS = {
    { keys={"fairy","fada","giant tree","mother tree","brightwood","enchanted","acorn"}, label="Fada",       icon="🧚" },
    { keys={"volcano","volcanic","lava","vulcao","vulcão"},                              label="Vulcão",     icon="🌋" },
    { keys={"ice","snow","frozen","winter","temple","gelo","iceberg"},                   label="Gelo",       icon="❄️" },
    { keys={"frog","swamp","pantano","pântano","marsh"},                                 label="Pântano",    icon="🐸" },
    { keys={"ufo","alien","mothership","nave"},                                          label="UFO",        icon="🛸" },
    { keys={"stronghold","cultist","fortress","fortaleza"},                              label="Fortaleza",  icon="⚔️" },
    { keys={"cave","cavern","mine","caverna","mina"},                                    label="Caverna",    icon="🕳️" },
    { keys={"research","outpost","hard mode"},                                           label="Posto",      icon="🔬" },
    { keys={"meteor","crater"},                                                          label="Meteoro",    icon="☄️" },
    { keys={"ruin","ancient","abandon"},                                                 label="Ruínas",     icon="🏚️" },
    { keys={"camp","campfire","campground","acampamento"},                               label="Acampamento",icon="🔥" },
}

local function getBiome(chestModel)
    -- Sobe a hierarquia do objeto para encontrar bioma pelo nome dos pais
    local obj = chestModel
    for _ = 1, 5 do
        if not obj or obj == workspace then break end
        local nm = obj.Name:lower()
        for _, b in ipairs(BIOME_KEYWORDS) do
            for _, kw in ipairs(b.keys) do
                if nm:find(kw, 1, true) then
                    return b.label, b.icon
                end
            end
        end
        obj = obj.Parent
    end
    -- Verifica a posição para tentar adivinhar o bioma
    local pos = nil
    pcall(function()
        local bp = chestModel:FindFirstChildWhichIsA("BasePart")
        if bp then pos = bp.Position end
    end)
    return "Floresta", "🌲"
end

-- Estado do painel
local chestButtons    = {}
local chestSeenKeys   = {}
local tpLastChest     = nil
local chestScanRun    = false

local function chestPosKey(pos)
    return math.floor(pos.X/6)..","..math.floor(pos.Y/6)..","..math.floor(pos.Z/6)
end

-- Container do painel
local chestPanelCard = Instance.new("Frame", Pages["Teleportar"])
chestPanelCard.BackgroundColor3 = Color3.fromRGB(20,18,14)
chestPanelCard.BorderSizePixel = 0
chestPanelCard.Size = UDim2.new(1,0,0,320); chestPanelCard.LayoutOrder = tpNextLO(); chestPanelCard.ZIndex = 5
Instance.new("UICorner",chestPanelCard).CornerRadius = UDim.new(0,12)
local chestPanelStroke = Instance.new("UIStroke",chestPanelCard)
chestPanelStroke.Color = Color3.fromRGB(120,90,30); chestPanelStroke.Thickness = 1.5

-- Header
local chestHdr = Instance.new("Frame",chestPanelCard)
chestHdr.BackgroundColor3 = Color3.fromRGB(30,24,14)
chestHdr.BorderSizePixel = 0; chestHdr.Size = UDim2.new(1,0,0,44); chestHdr.ZIndex = 6
Instance.new("UICorner",chestHdr).CornerRadius = UDim.new(0,10)
local chestHdrFix = Instance.new("Frame",chestHdr)
chestHdrFix.BackgroundColor3 = Color3.fromRGB(30,24,14)
chestHdrFix.BorderSizePixel = 0; chestHdrFix.Position = UDim2.new(0,0,0.5,0)
chestHdrFix.Size = UDim2.new(1,0,0.5,0); chestHdrFix.ZIndex = 6

local chestTitle = Instance.new("TextLabel",chestHdr)
chestTitle.BackgroundTransparency = 1
chestTitle.Position = UDim2.new(0,14,0,0); chestTitle.Size = UDim2.new(0.5,0,1,0)
chestTitle.Font = Enum.Font.GothamBlack; chestTitle.Text = "🎁 Baús"
chestTitle.TextColor3 = TP_COR_CHEST; chestTitle.TextSize = 12
chestTitle.TextXAlignment = Enum.TextXAlignment.Left; chestTitle.ZIndex = 7

local chestCount = Instance.new("TextLabel",chestHdr)
chestCount.BackgroundTransparency = 1
chestCount.Position = UDim2.new(0.5,0,0,4); chestCount.Size = UDim2.new(0.25,0,0.6,0)
chestCount.Font = Enum.Font.GothamSemibold; chestCount.Text = "0 encontrados"
chestCount.TextColor3 = Color3.fromRGB(160,140,80); chestCount.TextSize = 9
chestCount.TextXAlignment = Enum.TextXAlignment.Right; chestCount.ZIndex = 7

-- Botão Atualizar
local chestBtnRef = Instance.new("TextButton",chestHdr)
chestBtnRef.BackgroundColor3 = Color3.fromRGB(180,120,20)
chestBtnRef.BackgroundTransparency = 0.5; chestBtnRef.BorderSizePixel = 0
chestBtnRef.Position = UDim2.new(1,-84,0.5,-12); chestBtnRef.Size = UDim2.new(0,36,0,24); chestBtnRef.ZIndex = 8
Instance.new("UICorner",chestBtnRef).CornerRadius = UDim.new(0,7)
local chestBtnRefL = Instance.new("TextLabel",chestBtnRef)
chestBtnRefL.BackgroundTransparency = 1; chestBtnRefL.Size = UDim2.new(1,0,1,0)
chestBtnRefL.Font = Enum.Font.GothamBold; chestBtnRefL.Text = "🔄"
chestBtnRefL.TextColor3 = Color3.fromRGB(255,220,150); chestBtnRefL.TextSize = 13; chestBtnRefL.ZIndex = 9

-- Botão Limpar
local chestBtnClr = Instance.new("TextButton",chestHdr)
chestBtnClr.BackgroundColor3 = Color3.fromRGB(200,60,60)
chestBtnClr.BackgroundTransparency = 0.6; chestBtnClr.BorderSizePixel = 0
chestBtnClr.Position = UDim2.new(1,-44,0.5,-12); chestBtnClr.Size = UDim2.new(0,36,0,24); chestBtnClr.ZIndex = 8
Instance.new("UICorner",chestBtnClr).CornerRadius = UDim.new(0,7)
local chestBtnClrL = Instance.new("TextLabel",chestBtnClr)
chestBtnClrL.BackgroundTransparency = 1; chestBtnClrL.Size = UDim2.new(1,0,1,0)
chestBtnClrL.Font = Enum.Font.GothamBold; chestBtnClrL.Text = "🗑️"
chestBtnClrL.TextColor3 = Color3.fromRGB(255,180,180); chestBtnClrL.TextSize = 13; chestBtnClrL.ZIndex = 9

-- Scroll area
local chestScroll = Instance.new("ScrollingFrame",chestPanelCard)
chestScroll.BackgroundTransparency = 1; chestScroll.BorderSizePixel = 0
chestScroll.Position = UDim2.new(0,6,0,48); chestScroll.Size = UDim2.new(1,-12,0,264); chestScroll.ZIndex = 6
chestScroll.ScrollBarThickness = 3; chestScroll.ScrollBarImageColor3 = TP_COR_CHEST
chestScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; chestScroll.CanvasSize = UDim2.new(0,0,0,0)
local chestLayout = Instance.new("UIListLayout",chestScroll)
chestLayout.Padding = UDim.new(0,4); chestLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Label vazio
local chestEmptyLbl = Instance.new("TextLabel",chestScroll)
chestEmptyLbl.BackgroundTransparency = 1; chestEmptyLbl.Size = UDim2.new(1,0,0,60)
chestEmptyLbl.Font = Enum.Font.GothamSemibold
chestEmptyLbl.Text = "Clique em ↻ para escanear os baús"
chestEmptyLbl.TextColor3 = Color3.fromRGB(100,85,40); chestEmptyLbl.TextSize = 11
chestEmptyLbl.TextWrapped = true; chestEmptyLbl.ZIndex = 7; chestEmptyLbl.LayoutOrder = 1

-- ── Cria botão de baú ───────────────────────────────────────────
local function makeChestBtn(name, pos, rarity, biomeLabel, biomeIcon, isNew)
    local lo = #chestButtons + 1
    local COR = rarity.cor

    local row = Instance.new("Frame",chestScroll)
    row.BackgroundColor3 = Color3.fromRGB(26,22,14)
    row.BorderSizePixel = 0; row.Size = UDim2.new(1,0,0,44); row.ZIndex = 7; row.LayoutOrder = lo
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,8)
    local rowS = Instance.new("UIStroke",row); rowS.Color = Color3.fromRGB(60,50,20); rowS.Thickness = 1

    -- Fundo colorido com raridade
    local rarBg = Instance.new("Frame",row)
    rarBg.BackgroundColor3 = COR; rarBg.BackgroundTransparency = 0.88
    rarBg.BorderSizePixel = 0; rarBg.Size = UDim2.new(1,0,1,0); rarBg.ZIndex = 7
    Instance.new("UICorner",rarBg).CornerRadius = UDim.new(0,8)

    -- Barra lateral de raridade
    local rarBar = Instance.new("Frame",row)
    rarBar.BackgroundColor3 = COR; rarBar.BorderSizePixel = 0
    rarBar.Position = UDim2.new(0,0,0.1,0); rarBar.Size = UDim2.new(0,3,0.8,0); rarBar.ZIndex = 8
    Instance.new("UICorner",rarBar).CornerRadius = UDim.new(0,2)

    -- Ícone da raridade
    local ico = Instance.new("TextLabel",row)
    ico.BackgroundTransparency = 1; ico.Position = UDim2.new(0,8,0.5,-10)
    ico.Size = UDim2.new(0,20,0,20); ico.Font = Enum.Font.GothamBlack
    ico.Text = rarity.icon; ico.TextSize = 14; ico.ZIndex = 8

    -- Nome do baú
    local nameLbl = Instance.new("TextLabel",row)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Position = UDim2.new(0,32,0,4); nameLbl.Size = UDim2.new(0.5,0,0,15)
    nameLbl.Font = Enum.Font.GothamSemibold; nameLbl.Text = name
    nameLbl.TextColor3 = Color3.fromRGB(235,220,180); nameLbl.TextSize = 10
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd; nameLbl.ZIndex = 8

    -- Linha inferior: raridade + bioma + distância
    local infoLbl = Instance.new("TextLabel",row)
    infoLbl.BackgroundTransparency = 1
    infoLbl.Position = UDim2.new(0,32,0,22); infoLbl.Size = UDim2.new(0.55,0,0,14)
    infoLbl.Font = Enum.Font.GothamBold; infoLbl.TextSize = 8
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left; infoLbl.ZIndex = 8
    local distTxt = ""
    pcall(function()
        local ch = Player.Character; local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then distTxt = " • "..math.floor((pos-hrp.Position).Magnitude).."m" end
    end)
    infoLbl.TextColor3 = COR
    infoLbl.Text = rarity.label.." "..biomeIcon.." "..biomeLabel..distTxt

    -- Etiqueta NOVO / ANTIGO (canto superior direito)
    local tagBadge = Instance.new("Frame",row)
    tagBadge.BorderSizePixel = 0; tagBadge.AnchorPoint = Vector2.new(1,0)
    tagBadge.Position = UDim2.new(1,-42,0,5); tagBadge.Size = UDim2.new(0,38,0,13); tagBadge.ZIndex = 9
    Instance.new("UICorner",tagBadge).CornerRadius = UDim.new(0,4)
    local tagLbl = Instance.new("TextLabel",tagBadge)
    tagLbl.BackgroundTransparency = 1; tagLbl.Size = UDim2.new(1,0,1,0)
    tagLbl.Font = Enum.Font.GothamBlack; tagLbl.TextSize = 7; tagLbl.ZIndex = 10

    if isNew then
        tagBadge.BackgroundColor3 = Color3.fromRGB(60,200,120)
        tagLbl.Text = "NOVO"; tagLbl.TextColor3 = Color3.fromRGB(20,60,30)
    else
        tagBadge.Visible = false
    end

    -- Botão TP
    local tpb = Instance.new("TextButton",row)
    tpb.BackgroundColor3 = COR; tpb.BackgroundTransparency = 0.5; tpb.BorderSizePixel = 0
    tpb.Position = UDim2.new(1,-36,0.5,-13); tpb.Size = UDim2.new(0,30,0,26); tpb.ZIndex = 9
    Instance.new("UICorner",tpb).CornerRadius = UDim.new(0,7)
    local tpbL = Instance.new("TextLabel",tpb)
    tpbL.BackgroundTransparency = 1; tpbL.Size = UDim2.new(1,0,1,0)
    tpbL.Font = Enum.Font.GothamBlack; tpbL.Text = "TP"
    tpbL.TextColor3 = Color3.fromRGB(255,255,255); tpbL.TextSize = 10; tpbL.ZIndex = 10

    local entry = {
        name=name, pos=pos, rarity=rarity, row=row,
        tagBadge=tagBadge, tagLbl=tagLbl, rowS=rowS,
        tpb=tpb, isNew=isNew, visited=false
    }
    table.insert(chestButtons, entry)

    local function doTp()
        -- Remove NOVO imediatamente
        if entry.isNew then
            entry.isNew = false
            tagBadge.Visible = false
        end
        -- Marca anterior como ANTIGO imediatamente (sem tween, sem delay)
        if tpLastChest and tpLastChest ~= entry and tpLastChest.visited then
            tpLastChest.tagBadge.BackgroundColor3 = Color3.fromRGB(80,60,30)
            tpLastChest.tagLbl.Text  = "ANTIGO"
            tpLastChest.tagLbl.TextColor3 = Color3.fromRGB(220,180,100)
            tpLastChest.tagBadge.Visible = true
            tpLastChest.isNew = false  -- nunca mais vira NOVO
        end
        safeTp(pos, 5)
        entry.visited = true
        entry.isNew   = false  -- visitado = nunca mais vira NOVO no refresh
        tpLastChest = entry
        TweenService:Create(tpb,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.15),{Color=COR}):Play()
        task.delay(0.3, function()
            TweenService:Create(tpb,TweenInfo.new(0.2),{BackgroundColor3=COR,BackgroundTransparency=0.5}):Play()
            task.delay(1.5,function() TweenService:Create(rowS,TweenInfo.new(0.4),{Color=Color3.fromRGB(60,50,20)}):Play() end)
        end)
        Notify.send({type="custom",icon=rarity.icon,accent=COR,
            title="Baú",msg=name.." ("..rarity.label..") "..biomeIcon..biomeLabel,duration=2.5})
    end
    tpb.MouseButton1Click:Connect(doTp)
    local rowBtn = Instance.new("TextButton",row)
    rowBtn.BackgroundTransparency=1; rowBtn.Size=UDim2.new(1,-40,1,0); rowBtn.Text=""; rowBtn.ZIndex=8
    rowBtn.MouseButton1Click:Connect(doTp)

    return entry
end

-- ── Scan de baús no workspace ───────────────────────────────────
local function scanChests(isRefresh)
    if chestScanRun then return end
    chestScanRun = true
    chestBtnRefL.Text = "⏳"; task.delay(0.8, function() chestBtnRefL.Text = "🔄" end)

    task.spawn(function()
        local found = 0
        local descs = workspace:GetDescendants()
        local batch = 0
        for _, obj in ipairs(descs) do
            batch += 1
            if batch % 500 == 0 then task.wait() end  -- yield menos frequente = mais rápido

            if not obj:IsA("Model") then continue end

            local nm = obj.Name:lower()
            if not (nm:find("chest",1,true) or nm:find("bau",1,true) or nm:find("baú",1,true)) then continue end

            -- Pega maior BasePart (mais representativa do tamanho)
            local part, maxSz = nil, 0
            for _, bp in ipairs(obj:GetDescendants()) do
                if bp:IsA("BasePart") then
                    local s = bp.Size.X + bp.Size.Y + bp.Size.Z
                    if s > maxSz then maxSz = s; part = bp end
                end
            end
            if not part then continue end

            -- Ignora muito grandes (construções com "chest" no nome)
            if part.Size.X > 14 or part.Size.Y > 14 or part.Size.Z > 14 then continue end
            if part.Position.Y < -400 then continue end

            local pk = chestPosKey(part.Position)
            if chestSeenKeys[pk] then continue end
            chestSeenKeys[pk] = true

            local rarity = getRarity(obj)
            local biomeLabel, biomeIcon = getBiome(obj)

            -- Preserva estado visited/ANTIGO após refresh
            local wasVisited = false
            for _, ex in ipairs(chestButtons) do
                if ex.name == obj.Name and (ex.pos - part.Position).Magnitude < 8 then
                    wasVisited = ex.visited; break
                end
            end

            local entry = makeChestBtn(obj.Name, part.Position, rarity, biomeLabel, biomeIcon, isRefresh and not wasVisited)
            if wasVisited then
                entry.visited = true
                entry.isNew   = false
                entry.tagBadge.BackgroundColor3 = Color3.fromRGB(80,60,30)
                entry.tagLbl.Text  = "ANTIGO"
                entry.tagLbl.TextColor3 = Color3.fromRGB(220,180,100)
                entry.tagBadge.Visible = true
            end

            found += 1
            chestEmptyLbl.Visible = false
            if found % 30 == 0 then task.wait() end
        end

        -- Ordena por tier (mais raro no topo)
        table.sort(chestButtons, function(a, b)
            return (a.rarity.tier or 0) > (b.rarity.tier or 0)
        end)
        for i, entry in ipairs(chestButtons) do
            entry.row.LayoutOrder = i
        end

        chestCount.Text = tostring(#chestButtons).." encontrado(s)"
        if found == 0 and isRefresh then
            Notify.info("Tp Baús","Nenhum baú novo encontrado.")
        elseif found > 0 then
            local msg = isRefresh
                and (tostring(found).." novo(s) baú(s) adicionado(s)!")
                or  (tostring(found).." baús encontrados!")
            Notify.send({type="custom",icon="🎁",accent=TP_COR_CHEST,
                title="Painel de Baús",msg=msg,duration=3})
        end

        local contentH = #chestButtons * 48 + 10
        chestPanelCard.Size = UDim2.new(1,0,0, math.clamp(48 + contentH, 100, 480))
        chestScroll.Size    = UDim2.new(1,-12,0, math.clamp(contentH, 40, 424))
        chestScanRun = false
    end)
end

-- Botão atualizar
chestBtnRef.MouseButton1Click:Connect(function() scanChests(true) end)

-- Botão limpar
chestBtnClr.MouseButton1Click:Connect(function()
    for _, entry in ipairs(chestButtons) do
        pcall(function() entry.row:Destroy() end)
    end
    chestButtons = {}; chestSeenKeys = {}; tpLastChest = nil
    chestEmptyLbl.Visible = true
    chestCount.Text = "0 encontrados"
    chestPanelCard.Size = UDim2.new(1,0,0,320)
    chestScroll.Size    = UDim2.new(1,-12,0,264)
    Notify.info("Tp Baús","Lista de baús limpa!")
end)

-- Scan automático ao abrir a aba pela primeira vez
local chestFirstOpen = true
task.spawn(function()
    while true do
        task.wait(1)
        if Pages["Teleportar"] and Pages["Teleportar"].Visible and chestFirstOpen then
            chestFirstOpen = false
            task.wait(0.8)
            scanChests(false)
        end
    end
end)

end -- [[ TELEPORTAR TAB ]]

-- ══════════════════════════════════════════════════════════════
-- FARM TAB + AVANÇADO FARM TAB
-- ══════════════════════════════════════════════════════════════
do -- [[ FARM + AVANÇADO FARM ]]

-- ─── Utilitários de UI para Farm ──────────────────────────────
local farmLO  = 0
local avfLO   = 0
local function fNextLO()  farmLO+=1;  return farmLO  end
local function afNextLO() avfLO+=1;   return avfLO   end

-- Seção (cabeçalho colorido) genérica para qualquer página
local function makeSec(page, lo_fn, titleKey, cor)
    local hdr=Instance.new("Frame", page)
    hdr.BackgroundColor3=Color3.fromRGB(20,22,30); hdr.BackgroundTransparency=0.3
    hdr.BorderSizePixel=0; hdr.Size=UDim2.new(1,0,0,22); hdr.LayoutOrder=lo_fn(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",hdr); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=5; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,0)
    lbl.Size=UDim2.new(1,-14,1,0); lbl.Font=Enum.Font.GothamBlack
    lbl.TextColor3=cor; lbl.TextSize=9; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    TL(lbl, titleKey)  -- auto-tracked for language switching
end

-- Toggle genérico para qualquer página
local function makeToggle(page, lo_fn, lbl_txt, desc_txt, cor, onToggle)
    local row=Instance.new("Frame", page)
    row.BackgroundColor3=Color3.fromRGB(28,30,38); row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,60); row.LayoutOrder=lo_fn(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local rowS=Instance.new("UIStroke",row); rowS.Color=Color3.fromRGB(42,46,58); rowS.Thickness=1
    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,8); tl.Size=UDim2.new(1,-80,0,18); tl.Font=Enum.Font.GothamBold
    tl.Text=lbl_txt; tl.TextColor3=Color3.fromRGB(220,225,240); tl.TextSize=12
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local td=Instance.new("TextLabel",row); td.BackgroundTransparency=1
    td.Position=UDim2.new(0,14,0,28); td.Size=UDim2.new(1,-80,0,26); td.Font=Enum.Font.Gotham
    td.Text=desc_txt; td.TextColor3=Color3.fromRGB(90,100,120); td.TextSize=9
    td.TextXAlignment=Enum.TextXAlignment.Left; td.TextWrapped=true; td.ZIndex=7
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(45,50,62); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-56,0.5,-13); pill.Size=UDim2.new(0,48,0,26); pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(160,170,185); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,2,0.5,-11); knob.Size=UDim2.new(0,22,0,22); knob.ZIndex=10
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=11
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(pill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundColor3=state and cor or Color3.fromRGB(45,50,62)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=state and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
            BackgroundColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
        }):Play()
        TweenService:Create(rowS,TweenInfo.new(0.2),{Color=state and cor or Color3.fromRGB(42,46,58)}):Play()
        onToggle(state)
    end)
    return function() return state end
end

-- Slider genérico para qualquer página
local function makeSlider(page, lo_fn, lbl_txt, minV, maxV, defV, cor, fmt, onChange)
    local BASE_H = 64
    local row=Instance.new("Frame", page)
    row.BackgroundColor3=Color3.fromRGB(28,30,38); row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,BASE_H); row.LayoutOrder=lo_fn(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    Instance.new("UIStroke",row).Color=Color3.fromRGB(42,46,58)
    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,8); tl.Size=UDim2.new(1,-100,0,18); tl.Font=Enum.Font.GothamBold
    tl.Text=lbl_txt; tl.TextColor3=Color3.fromRGB(200,210,235); tl.TextSize=11
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local valLbl=Instance.new("TextLabel",row); valLbl.BackgroundTransparency=1
    valLbl.Position=UDim2.new(1,-90,0,8); valLbl.Size=UDim2.new(0,80,0,18)
    valLbl.Font=Enum.Font.GothamBold; valLbl.TextColor3=cor; valLbl.TextSize=12
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=7
    -- Track
    local track=Instance.new("Frame",row); track.BackgroundColor3=Color3.fromRGB(40,44,58)
    track.BorderSizePixel=0; track.Position=UDim2.new(0,14,0,38); track.Size=UDim2.new(1,-28,0,6)
    track.ZIndex=6; Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",track); fill.BackgroundColor3=cor; fill.BorderSizePixel=0
    fill.Size=UDim2.new(0,0,1,0); fill.ZIndex=7; Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local thumb=Instance.new("Frame",track); thumb.BackgroundColor3=Color3.fromRGB(255,255,255)
    thumb.BorderSizePixel=0; thumb.AnchorPoint=Vector2.new(0.5,0.5)
    thumb.Position=UDim2.new(0,0,0.5,0); thumb.Size=UDim2.new(0,16,0,16); thumb.ZIndex=8
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    Instance.new("UIStroke",thumb).Color=cor
    local curVal = defV
    local isInfinite = (maxV == math.huge)
    local function updateSlider(v)
        curVal = v
        local displayMax = isInfinite and 9999 or maxV
        local t = (v - minV) / (displayMax - minV)
        t = math.clamp(t, 0, 1)
        fill.Size = UDim2.new(t, 0, 1, 0)
        thumb.Position = UDim2.new(t, 0, 0.5, 0)
        if fmt then
            valLbl.Text = fmt(v)
        elseif isInfinite and v >= 9999 then
            valLbl.Text = "∞"
        else
            valLbl.Text = tostring(math.floor(v))
        end
        onChange(v)
    end
    -- Inicializa
    local displayMax2 = isInfinite and 9999 or maxV
    local t0 = math.clamp((defV - minV)/(displayMax2-minV),0,1)
    fill.Size = UDim2.new(t0,0,1,0); thumb.Position = UDim2.new(t0,0,0.5,0)
    if fmt then valLbl.Text=fmt(defV)
    elseif isInfinite and defV>=9999 then valLbl.Text="∞"
    else valLbl.Text=tostring(math.floor(defV)) end
    -- Input de arrastar
    local dragging = false
    local function onInput(x)
        local rel = track.AbsolutePosition.X
        local w   = track.AbsoluteSize.X
        local dmax = isInfinite and 9999 or maxV
        local t = math.clamp((x - rel) / w, 0, 1)
        local v = minV + t * (dmax - minV)
        v = math.clamp(math.floor(v+0.5), minV, dmax)
        if isInfinite and v >= 9990 then v = math.huge end
        updateSlider(v)
    end
    local uis = game:GetService("UserInputService")
    thumb.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=true end end)
    track.InputBegan:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 then onInput(inp.Position.X) end end)
    uis.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            onInput(inp.Position.X)
        end
    end)
    uis.InputEnded:Connect(function(inp) if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
    return function() return curVal end
end

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
local freezeEnabled  = false
local freezeRadius   = 185
local frozenMobs     = {}

-- Círculo visual do raio
local FreezeCircle = nil
local FreezeCircleAdorn = nil

local function createFreezeCircle()
    if FreezeCircleAdorn then pcall(function() FreezeCircleAdorn:Destroy() end) end
    if FreezeCircle then pcall(function() FreezeCircle:Destroy() end) end
    local ch = Player.Character; if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local part = Instance.new("Part")
    part.Name = "FreezeAuraCircle"
    part.Size = Vector3.new(freezeRadius*2, 0.15, freezeRadius*2)
    part.Shape = Enum.PartType.Cylinder
    part.CanCollide = false; part.Anchored = false; part.CastShadow = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(0, 200, 255)
    part.Transparency = 0.55
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp; weld.Part1 = part
    part.CFrame = hrp.CFrame * CFrame.new(0,-2.8,0) * CFrame.Angles(0,0,math.pi/2)
    weld.Parent = part; part.Parent = workspace
    local highlight = Instance.new("SelectionBox")
    highlight.Adornee = part
    highlight.Color3 = Color3.fromRGB(0, 200, 255)
    highlight.LineThickness = 0.05
    highlight.SurfaceTransparency = 1
    highlight.Parent = workspace
    FreezeCircle = part
    FreezeCircleAdorn = highlight
    task.spawn(function()
        while freezeEnabled and FreezeCircle and FreezeCircle.Parent do
            task.wait(0.04)
            pcall(function()
                local alpha = math.abs(math.sin(tick() * 2.0))
                FreezeCircle.Transparency = 0.45 + alpha * 0.35
                highlight.Color3 = Color3.fromRGB(
                    math.floor(alpha * 80),
                    math.floor(180 + alpha * 75),
                    255
                )
            end)
        end
    end)
end

local function destroyFreezeCircle()
    pcall(function() if FreezeCircle then FreezeCircle:Destroy(); FreezeCircle=nil end end)
    pcall(function() if FreezeCircleAdorn then FreezeCircleAdorn:Destroy(); FreezeCircleAdorn=nil end end)
end

local function updateCircleRadius()
    if not FreezeCircle or not FreezeCircle.Parent then return end
    FreezeCircle.Size = Vector3.new(freezeRadius*2, 0.15, freezeRadius*2)
end

-- FREEZE ULTRA-FORTE: força 1e12, sem escapatória
local function freezeMobStrong(entry)
    pcall(function()
        local hum = entry.hum; local hrp = entry.hrp
        if not hum or not hum.Parent then return end
        entry.origSpeed = hum.WalkSpeed
        entry.origJump  = hum.JumpPower
        hum.WalkSpeed = 0; hum.JumpPower = 0
        if hrp and hrp.Parent then
            -- Remove constraints antigos
            for _, c in ipairs(hrp:GetChildren()) do
                if c.Name == "FreezeBodyPos" or c.Name == "FreezeBodyGyro" or c.Name == "FreezeLinear" or c.Name == "FreezeAngular" then
                    pcall(function() c:Destroy() end)
                end
            end
            -- BodyPosition com força absurda
            local bp = Instance.new("BodyPosition")
            bp.Name = "FreezeBodyPos"
            bp.MaxForce = Vector3.new(1e12, 1e12, 1e12)
            bp.D = 500000; bp.P = 5000000
            bp.Position = hrp.Position
            bp.Parent = hrp
            entry.bodyPos = bp
            -- BodyGyro ultra-forte
            local bg = Instance.new("BodyGyro")
            bg.Name = "FreezeBodyGyro"
            bg.MaxTorque = Vector3.new(1e12, 1e12, 1e12)
            bg.D = 100000; bg.P = 1000000
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
            entry.bodyGyro = bg
            -- Para animações
            pcall(function()
                local anim = hum:FindFirstChild("Animator")
                if anim then
                    for _, t in ipairs(anim:GetPlayingAnimationTracks()) do
                        t:AdjustSpeed(0)
                    end
                end
            end)
        end
    end)
end

local function unfreezeMobStrong(entry)
    pcall(function()
        local hum = entry.hum; local hrp = entry.hrp
        if hum and hum.Parent then
            hum.WalkSpeed = entry.origSpeed or 16
            hum.JumpPower = entry.origJump  or 50
        end
        if entry.bodyPos and entry.bodyPos.Parent then entry.bodyPos:Destroy() end
        if entry.bodyGyro and entry.bodyGyro.Parent then entry.bodyGyro:Destroy() end
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
    for _, entry in ipairs(frozenMobs) do
        unfreezeMobStrong(entry)
    end
    frozenMobs = {}
end

local freezeConn = nil

local function startFreezeAura()
    if freezeConn then freezeConn:Disconnect(); freezeConn=nil end
    if Player.Character then createFreezeCircle() end
    Player.CharacterAdded:Connect(function()
        if freezeEnabled then task.wait(1); createFreezeCircle() end
    end)
    freezeConn = RunService.Heartbeat:Connect(function()
        if not freezeEnabled then return end
        local ch = Player.Character; if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local origin = hrp.Position
        local radius = freezeRadius
        -- Descongela mobs fora do raio ou mortos
        local stillFrozen = {}
        for _, entry in ipairs(frozenMobs) do
            pcall(function()
                if not entry.model or not entry.model.Parent then
                    unfreezeMobStrong(entry); return
                end
                local hum2 = entry.hum
                if not hum2 or not hum2.Parent or hum2.Health <= 0 then
                    unfreezeMobStrong(entry); return
                end
                if entry.hrp and entry.hrp.Parent then
                    local d = (entry.hrp.Position - origin).Magnitude
                    if d > radius + 5 then
                        unfreezeMobStrong(entry); return
                    end
                    -- Reforça posição continuamente com força máxima
                    if entry.bodyPos and entry.bodyPos.Parent then
                        entry.bodyPos.Position = entry.hrp.Position
                        entry.bodyPos.MaxForce = Vector3.new(1e12, 1e12, 1e12)
                    end
                    if entry.bodyGyro and entry.bodyGyro.Parent then
                        entry.bodyGyro.CFrame = entry.hrp.CFrame
                        entry.bodyGyro.MaxTorque = Vector3.new(1e12, 1e12, 1e12)
                    end
                    -- Garante WalkSpeed=0 mesmo que o jogo tente restaurar
                    if entry.hum and entry.hum.Parent then
                        entry.hum.WalkSpeed = 0
                        entry.hum.JumpPower = 0
                    end
                end
                table.insert(stillFrozen, entry)
            end)
        end
        frozenMobs = stillFrozen
        -- Congela novos mobs dentro do raio
        local frozenSet = {}
        for _, e in ipairs(frozenMobs) do frozenSet[e.model] = true end
        local newMobs = getMobsInRange(origin, radius)
        for _, entry in ipairs(newMobs) do
            if not frozenSet[entry.model] then
                freezeMobStrong(entry)
                table.insert(frozenMobs, entry)
            end
        end
    end)
end

local function stopFreezeAura()
    if freezeConn then freezeConn:Disconnect(); freezeConn=nil end
    destroyFreezeCircle()
    unfreezeAll()
end

-- ══════════════════════════════════════════════════════════════
-- KILL AURA — Farm Tab
-- Funciona: você equipa uma arma e clica normalmente.
-- A cada clique o Remote é disparado para TODOS os mobs no range.
-- Remote: ReplicatedStorage.RemoteEvents.ToolDamageObject
-- Args: mob, weapon (Inventory), attackId "1_XXXXXXXXXX", hitCFrame
-- ══════════════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════
-- KILL AURA v3 — Abordagem: jogador vai até o mob (câmera travada + invisível)
-- O swing REAL toca fisicamente o hitbox do mob → servidor aceita 100%
-- Funciona com QUALQUER arma incluindo todos os Machados
-- ══════════════════════════════════════════════════════════════

local kaEnabled  = false
local kaRange    = 30
local kaToolConn = nil
local kaCharConn = nil
local kaBusy     = false  -- evita execuções sobrepostas

-- Torna o personagem invisível/visível localmente (só client-side)
local kaTranspCache = {}
local function kaSetInvis(ch, invis)
    if invis then
        kaTranspCache = {}
        for _, p in ipairs(ch:GetDescendants()) do
            if p:IsA("BasePart") then
                kaTranspCache[p] = p.LocalTransparencyModifier
                p.LocalTransparencyModifier = 1
            end
        end
    else
        for p, v in pairs(kaTranspCache) do
            if p and p.Parent then p.LocalTransparencyModifier = v end
        end
        kaTranspCache = {}
    end
end

-- Congela a câmera na CFrame atual por N frames e restaura
local function kaLockCamera(frames)
    local cam = workspace.CurrentCamera
    local savedType = cam.CameraType
    local savedCF   = cam.CFrame
    cam.CameraType  = Enum.CameraType.Scriptable
    cam.CFrame      = savedCF
    task.delay(frames / 60, function()
        pcall(function()
            cam.CameraType = savedType
        end)
    end)
end

-- Coleta todos os mobs vivos no range (inclui passivos como Bunny, Horse, Kiwi, Turkey)
local function getMobsInRange(hrp, range)
    local mobs = {}
    local sources = {workspace}
    pcall(function()
        local cf = workspace:FindFirstChild("Characters")
        if cf then table.insert(sources, cf) end
        local lv = workspace:FindFirstChild("LiveObjects") or workspace:FindFirstChild("Mobs")
        if lv then table.insert(sources, lv) end
    end)
    local seen = {}
    for _, src in ipairs(sources) do
        for _, obj in ipairs(src:GetChildren()) do
            pcall(function()
                if not obj:IsA("Model") then return end
                if isPlayerChar(obj) then return end
                local objId = tostring(obj)
                if seen[objId] then return end
                local hum = obj:FindFirstChildWhichIsA("Humanoid")
                if not hum or hum.Health <= 0 then return end
                -- Suporta HumanoidRootPart E Torso como root
                local mhrp = obj:FindFirstChild("HumanoidRootPart")
                    or obj:FindFirstChild("Torso")
                    or obj:FindFirstChildWhichIsA("BasePart")
                if not mhrp then return end
                if (mhrp.Position - hrp.Position).Magnitude <= range then
                    seen[objId] = true
                    table.insert(mobs, mhrp)
                end
            end)
        end
    end
    -- Também escaneia GetDescendants para mobs nested (ex.: dentro de Models)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and not isPlayerChar(obj) then
                local objId = tostring(obj)
                if not seen[objId] then
                    local hum = obj:FindFirstChildWhichIsA("Humanoid")
                    if hum and hum.Health > 0 then
                        local mhrp = obj:FindFirstChild("HumanoidRootPart")
                            or obj:FindFirstChild("Torso")
                            or obj:FindFirstChildWhichIsA("BasePart")
                        if mhrp and (mhrp.Position - hrp.Position).Magnitude <= range then
                            seen[objId] = true
                            table.insert(mobs, mhrp)
                        end
                    end
                end
            end
        end
    end)
    return mobs
end

-- ── Núcleo do Kill Aura ─────────────────────────────────────
-- A cada swing:
--   1. Salva posição original
--   2. Câmera trava
--   3. Jogador fica invisível
--   4. Para cada mob: tp até 1.5 studs da frente → dispara Activated → espera 1 frame
--   5. Volta para posição original
--   6. Câmera destrava, jogador fica visível
local function onWeaponActivated(tool)
    if not kaEnabled or kaBusy then return end
    local ch = Player.Character; if not ch then return end
    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end

    local mobs = getMobsInRange(hrp, kaRange)
    if #mobs == 0 then return end

    kaBusy = true

    -- Salva posição e câmera
    local origCF = hrp.CFrame

    -- Trava câmera e esconde personagem
    kaLockCamera(#mobs * 2 + 4)
    kaSetInvis(ch, true)

    -- Desativa física do personagem temporariamente para o tp ser suave
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)

    -- Loop pelos mobs
    for _, mhrp in ipairs(mobs) do
        pcall(function()
            if not kaEnabled then return end
            -- Posição atrás do mob olhando para ele (hitbox do swing acerta)
            local mobPos = mhrp.Position
            local toMob = (mobPos - origCF.Position)
            local dir = toMob.Magnitude > 0 and toMob.Unit or Vector3.new(0,0,-1)
            -- Posiciona 1.5 studs na frente do mob (hitbox mais garantido)
            local attackCF = CFrame.new(mobPos - dir * 1.5, mobPos)
            hrp.CFrame = attackCF

            -- Aguarda 4 frames para o servidor receber a nova posição do jogador
            for _=1,4 do
                local stepped = false
                local conn; conn = RunService.Stepped:Connect(function()
                    stepped = true; conn:Disconnect()
                end)
                local t = tick()
                while not stepped and (tick()-t) < 0.06 do task.wait() end
            end

            -- Dispara o Activated da tool — usa o handler REAL do jogo
            pcall(function() tool:Activate() end)
            -- Tenta também ativar via RemoteEvent se existir (fallback)
            pcall(function()
                local re = game:GetService("ReplicatedStorage"):FindFirstChild("RemoteEvents")
                if re then
                    local dmg = re:FindFirstChild("ToolDamageObject")
                        or re:FindFirstChild("DamageEntity")
                        or re:FindFirstChild("HitEntity")
                        or re:FindFirstChild("SwingTool")
                    if dmg then
                        dmg:FireServer(mhrp.Parent, tool, attackCF)
                    end
                end
            end)

            -- Aguarda mais 3 frames para o hitbox registrar no servidor
            for _=1,3 do
                local stepped2 = false
                local conn2; conn2 = RunService.Stepped:Connect(function()
                    stepped2 = true; conn2:Disconnect()
                end)
                local t2 = tick()
                while not stepped2 and (tick()-t2) < 0.06 do task.wait() end
            end
        end)
    end

    -- Volta para posição original
    pcall(function()
        hrp.CFrame = origCF
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true) end)
    end)

    -- Restaura visibilidade após 1 frame
    task.wait()
    kaSetInvis(ch, false)

    kaBusy = false
end

local function connectToEquippedTool(tool)
    if kaToolConn then pcall(function() kaToolConn:Disconnect() end); kaToolConn = nil end
    if not tool then return end
    -- Conecta no Activated da tool — usa o handler real do jogo
    kaToolConn = tool.Activated:Connect(function()
        task.spawn(onWeaponActivated, tool)
    end)
    Notify.info("Kill Aura", "⚔️ "..tool.Name.." — clique para acertar todos no range!")
end

local function startKillAura()
    local ch = Player.Character
    if ch then
        connectToEquippedTool(ch:FindFirstChildWhichIsA("Tool"))
        ch.ChildAdded:Connect(function(child)
            if kaEnabled and child:IsA("Tool") then
                task.wait(0.05); connectToEquippedTool(child)
            end
        end)
        ch.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") and kaToolConn then
                pcall(function() kaToolConn:Disconnect() end); kaToolConn = nil
                kaBusy = false
            end
        end)
    end
    if kaCharConn then pcall(function() kaCharConn:Disconnect() end) end
    kaCharConn = Player.CharacterAdded:Connect(function(char)
        task.wait(1); if not kaEnabled then return end
        connectToEquippedTool(char:FindFirstChildWhichIsA("Tool"))
        char.ChildAdded:Connect(function(child)
            if kaEnabled and child:IsA("Tool") then
                task.wait(0.05); connectToEquippedTool(child)
            end
        end)
    end)
end

local function stopKillAura()
    if kaToolConn then pcall(function() kaToolConn:Disconnect() end); kaToolConn = nil end
    if kaCharConn then pcall(function() kaCharConn:Disconnect() end); kaCharConn = nil end
    kaBusy = false
    -- Restaura visibilidade caso tenha ficado invisível
    pcall(function()
        local ch = Player.Character; if not ch then return end
        kaSetInvis(ch, false)
        local cam = workspace.CurrentCamera
        if cam.CameraType == Enum.CameraType.Scriptable then
            cam.CameraType = Enum.CameraType.Custom
        end
    end)
end

-- ── UI Kill Aura — Farm Tab (card único: toggle esquerda + mini slider direita) ──
local KA_COR = Color3.fromRGB(255, 80, 80)

local kaSecHdr = Instance.new("Frame", Pages["Farm"])
kaSecHdr.BackgroundColor3 = Color3.fromRGB(20,22,30)
kaSecHdr.BackgroundTransparency = 0.3; kaSecHdr.BorderSizePixel = 0
kaSecHdr.Size = UDim2.new(1,0,0,22); kaSecHdr.LayoutOrder = fNextLO(); kaSecHdr.ZIndex = 4
Instance.new("UICorner",kaSecHdr).CornerRadius = UDim.new(0,6)
local kaBar = Instance.new("Frame",kaSecHdr); kaBar.BackgroundColor3 = KA_COR; kaBar.BorderSizePixel = 0
kaBar.Size = UDim2.new(0,3,1,0); kaBar.ZIndex = 5; Instance.new("UICorner",kaBar).CornerRadius = UDim.new(0,3)
local kaSecLbl = Instance.new("TextLabel",kaSecHdr); kaSecLbl.BackgroundTransparency = 1
kaSecLbl.Position = UDim2.new(0,10,0,0); kaSecLbl.Size = UDim2.new(1,-14,1,0)
kaSecLbl.Font = Enum.Font.GothamBlack; TL(kaSecLbl, "kaSecTitle")
kaSecLbl.TextColor3 = KA_COR; kaSecLbl.TextSize = 9
kaSecLbl.TextXAlignment = Enum.TextXAlignment.Left; kaSecLbl.ZIndex = 5

-- Card único combinado (altura 82)
local kaCard = Instance.new("Frame", Pages["Farm"])
kaCard.BackgroundColor3 = Color3.fromRGB(28,20,20)
kaCard.BorderSizePixel = 0; kaCard.Size = UDim2.new(1,0,0,82)
kaCard.LayoutOrder = fNextLO(); kaCard.ZIndex = 5
Instance.new("UICorner",kaCard).CornerRadius = UDim.new(0,9)
local kaStroke = Instance.new("UIStroke",kaCard); kaStroke.Color = Color3.fromRGB(58,42,42); kaStroke.Thickness = 1

-- ── Lado esquerdo: título + desc + toggle ──
local kaTitleLbl = Instance.new("TextLabel",kaCard); kaTitleLbl.BackgroundTransparency = 1
kaTitleLbl.Position = UDim2.new(0,14,0,8); kaTitleLbl.Size = UDim2.new(0.5,0,0,18)
kaTitleLbl.Font = Enum.Font.GothamBold; TL(kaTitleLbl, "kaTitle")
kaTitleLbl.TextColor3 = Color3.fromRGB(255,200,200); kaTitleLbl.TextSize = 12
kaTitleLbl.TextXAlignment = Enum.TextXAlignment.Left; kaTitleLbl.ZIndex = 7

local kaDescLbl = Instance.new("TextLabel",kaCard); kaDescLbl.BackgroundTransparency = 1
kaDescLbl.Position = UDim2.new(0,14,0,28); kaDescLbl.Size = UDim2.new(0.5,0,0,30)
kaDescLbl.Font = Enum.Font.Gotham; kaDescLbl.TextColor3 = Color3.fromRGB(90,100,120)
TL(kaDescLbl, "kaDesc")
kaDescLbl.TextSize = 9; kaDescLbl.TextXAlignment = Enum.TextXAlignment.Left
kaDescLbl.TextWrapped = true; kaDescLbl.ZIndex = 7

-- Toggle pill no lado esquerdo (abaixo da desc)
local kaPill = Instance.new("Frame",kaCard); kaPill.BackgroundColor3 = Color3.fromRGB(45,50,62); kaPill.BorderSizePixel = 0
kaPill.Position = UDim2.new(0,14,0,60); kaPill.Size = UDim2.new(0,48,0,16); kaPill.ZIndex = 9
Instance.new("UICorner",kaPill).CornerRadius = UDim.new(1,0)
local kaKnob = Instance.new("Frame",kaPill); kaKnob.BackgroundColor3 = Color3.fromRGB(160,170,185); kaKnob.BorderSizePixel = 0
kaKnob.Position = UDim2.new(0,1,0.5,-7); kaKnob.Size = UDim2.new(0,14,0,14); kaKnob.ZIndex = 10
Instance.new("UICorner",kaKnob).CornerRadius = UDim.new(1,0)

-- Divisória vertical
local kaDivV = Instance.new("Frame",kaCard); kaDivV.BackgroundColor3 = Color3.fromRGB(58,42,42)
kaDivV.BorderSizePixel = 0; kaDivV.Position = UDim2.new(0.52,0,0,8)
kaDivV.Size = UDim2.new(0,1,0,-16); kaDivV.Size = UDim2.new(0,1,1,-16); kaDivV.ZIndex = 6

-- ── Lado direito: mini slim slider "Alcance" ──
local kaAlcLbl = Instance.new("TextLabel",kaCard); kaAlcLbl.BackgroundTransparency = 1
kaAlcLbl.Position = UDim2.new(0.54,0,0,8); kaAlcLbl.Size = UDim2.new(0.28,0,0,14)
kaAlcLbl.Font = Enum.Font.GothamBold; kaAlcLbl.Text = "Alcance"
kaAlcLbl.TextColor3 = KA_COR; kaAlcLbl.TextSize = 9
kaAlcLbl.TextXAlignment = Enum.TextXAlignment.Left; kaAlcLbl.ZIndex = 7

-- Valor do alcance (canto direito)
local kaValLbl = Instance.new("TextLabel",kaCard); kaValLbl.BackgroundTransparency = 1
kaValLbl.Position = UDim2.new(0.82,0,0,6); kaValLbl.Size = UDim2.new(0.16,0,0,16)
kaValLbl.Font = Enum.Font.GothamBlack; kaValLbl.Text = tostring(kaRange)
kaValLbl.TextColor3 = Color3.fromRGB(255,255,255); kaValLbl.TextSize = 10
kaValLbl.TextXAlignment = Enum.TextXAlignment.Right; kaValLbl.ZIndex = 7

-- Mini track (slim, 4px de alto)
local kaMiniTrack = Instance.new("Frame",kaCard); kaMiniTrack.BackgroundColor3 = Color3.fromRGB(55,35,35)
kaMiniTrack.BorderSizePixel = 0; kaMiniTrack.Position = UDim2.new(0.54,0,0,28)
kaMiniTrack.Size = UDim2.new(0.44,-8,0,4); kaMiniTrack.ZIndex = 7
Instance.new("UICorner",kaMiniTrack).CornerRadius = UDim.new(1,0)

local pct0ka = kaRange / 125
local kaMiniFill = Instance.new("Frame",kaMiniTrack); kaMiniFill = kaMiniTrack:FindFirstChild("Fill") or kaMiniTrack:GetChildren()[1]
kaMiniTrack:ClearAllChildren()
local kaMiniF = Instance.new("Frame",kaMiniTrack); kaMiniF.BackgroundColor3 = KA_COR
kaMiniF.BorderSizePixel = 0; kaMiniF.Size = UDim2.new(pct0ka,0,1,0); kaMiniF.ZIndex = 8
Instance.new("UICorner",kaMiniF).CornerRadius = UDim.new(1,0)

-- Ponto branco arrastável
local kaMiniDot = Instance.new("Frame",kaMiniTrack); kaMiniDot.BackgroundColor3 = Color3.fromRGB(255,255,255)
kaMiniDot.BorderSizePixel = 0; kaMiniDot.AnchorPoint = Vector2.new(0.5,0.5)
kaMiniDot.Position = UDim2.new(pct0ka,0,0.5,0); kaMiniDot.Size = UDim2.new(0,12,0,12); kaMiniDot.ZIndex = 9
Instance.new("UICorner",kaMiniDot).CornerRadius = UDim.new(1,0)
local kaMiniDotS = Instance.new("UIStroke",kaMiniDot); kaMiniDotS.Color = KA_COR; kaMiniDotS.Thickness = 2

-- Balão de valor acima do ponto (aparece ao arrastar)
local kaBalloon = Instance.new("Frame",kaMiniDot); kaBalloon.BackgroundColor3 = Color3.fromRGB(255,255,255)
kaBalloon.BorderSizePixel = 0; kaBalloon.AnchorPoint = Vector2.new(0.5,1)
kaBalloon.Position = UDim2.new(0.5,0,0,-6); kaBalloon.Size = UDim2.new(0,26,0,16); kaBalloon.ZIndex = 11
Instance.new("UICorner",kaBalloon).CornerRadius = UDim.new(0,4)
local kaBallLbl = Instance.new("TextLabel",kaBalloon); kaBallLbl.BackgroundTransparency = 1
kaBallLbl.Size = UDim2.new(1,0,1,0); kaBallLbl.Font = Enum.Font.GothamBlack
kaBallLbl.Text = tostring(kaRange); kaBallLbl.TextColor3 = Color3.fromRGB(20,10,10)
kaBallLbl.TextSize = 8; kaBallLbl.ZIndex = 12

-- Sliders mini desc
local kaSliderDescs = {}
local descTexts = {"Toque rápido","Perto","Médio","Longe","Máximo"}
for i, txt in ipairs(descTexts) do
    local d = Instance.new("TextLabel",kaCard); d.BackgroundTransparency=1
    d.Font=Enum.Font.Gotham; d.TextColor3=Color3.fromRGB(90,100,120); d.TextSize=8
    d.TextXAlignment=Enum.TextXAlignment.Left; d.ZIndex=7; d.Visible=false
    table.insert(kaSliderDescs,d)
end

-- Rótulos de escala (0 e 125)
local kaMin0 = Instance.new("TextLabel",kaCard); kaMin0.BackgroundTransparency=1
kaMin0.Position=UDim2.new(0.54,0,0,36); kaMin0.Size=UDim2.new(0.1,0,0,10)
kaMin0.Font=Enum.Font.Gotham; kaMin0.Text="0"; kaMin0.TextColor3=Color3.fromRGB(80,60,60)
kaMin0.TextSize=7; kaMin0.TextXAlignment=Enum.TextXAlignment.Left; kaMin0.ZIndex=7
local kaMax125 = Instance.new("TextLabel",kaCard); kaMax125.BackgroundTransparency=1
kaMax125.Position=UDim2.new(0.9,-8,0,36); kaMax125.Size=UDim2.new(0.1,0,0,10)
kaMax125.Font=Enum.Font.Gotham; kaMax125.Text="125"; kaMax125.TextColor3=Color3.fromRGB(80,60,60)
kaMax125.TextSize=7; kaMax125.TextXAlignment=Enum.TextXAlignment.Right; kaMax125.ZIndex=7

-- Desc de alcance atual
local kaRangeDesc = Instance.new("TextLabel",kaCard); kaRangeDesc.BackgroundTransparency=1
kaRangeDesc.Position=UDim2.new(0.54,0,0,50); kaRangeDesc.Size=UDim2.new(0.44,-8,0,10)
kaRangeDesc.Font=Enum.Font.Gotham; kaRangeDesc.Text=""
kaRangeDesc.TextColor3=Color3.fromRGB(120,80,80); kaRangeDesc.TextSize=8
kaRangeDesc.TextXAlignment=Enum.TextXAlignment.Left; kaRangeDesc.ZIndex=7

local function kaGetDesc(v)
    if v <= 10 then return "toque rápido"
    elseif v <= 30 then return "perto"
    elseif v <= 60 then return "médio"
    elseif v <= 100 then return "longe"
    else return "máximo" end
end
kaRangeDesc.Text = kaGetDesc(kaRange)

-- Drag logic para mini slider
local kaDragging = false
local function kaMiniSetVal(screenX)
    local ap = kaMiniTrack.AbsolutePosition
    local as = kaMiniTrack.AbsoluteSize
    local pct = math.clamp((screenX - ap.X) / as.X, 0, 1)
    kaRange = math.floor(pct * 125 + 0.5)
    kaMiniF.Size = UDim2.new(pct,0,1,0)
    kaMiniDot.Position = UDim2.new(pct,0,0.5,0)
    kaValLbl.Text = tostring(kaRange)
    kaBallLbl.Text = tostring(kaRange)
    kaRangeDesc.Text = kaGetDesc(kaRange)
end

local kaDotBtn = Instance.new("TextButton",kaMiniDot); kaDotBtn.BackgroundTransparency=1
kaDotBtn.Size=UDim2.new(1,8,1,8); kaDotBtn.Position=UDim2.new(0,-4,0,-4)
kaDotBtn.Text=""; kaDotBtn.ZIndex=13
kaDotBtn.MouseButton1Down:Connect(function()
    kaDragging = true
    kaBalloon.Visible = true
end)

local kaTrackBtn = Instance.new("TextButton",kaMiniTrack); kaTrackBtn.BackgroundTransparency=1
kaTrackBtn.Size=UDim2.new(1,16,1,16); kaTrackBtn.Position=UDim2.new(0,-8,0,-8)
kaTrackBtn.Text=""; kaTrackBtn.ZIndex=10
kaTrackBtn.MouseButton1Down:Connect(function()
    kaDragging = true; kaBalloon.Visible = true
    kaMiniSetVal(UserInputService:GetMouseLocation().X)
end)

UserInputService.InputChanged:Connect(function(inp)
    if not kaDragging then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement then
        kaMiniSetVal(inp.Position.X)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        kaDragging = false; kaBalloon.Visible = false
    end
end)

-- Toggle button (cobre o lado esquerdo do card)
local kaBtnClick = Instance.new("TextButton",kaCard); kaBtnClick.BackgroundTransparency = 1
kaBtnClick.Position = UDim2.new(0,0,0,0); kaBtnClick.Size = UDim2.new(0.52,0,1,0)
kaBtnClick.Text = ""; kaBtnClick.ZIndex = 11
kaBtnClick.MouseButton1Click:Connect(function()
    kaEnabled = not kaEnabled
    TweenService:Create(kaPill,TweenInfo.new(0.22),{BackgroundColor3=kaEnabled and KA_COR or Color3.fromRGB(45,50,62)}):Play()
    TweenService:Create(kaKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position=kaEnabled and UDim2.new(1,-15,0.5,-7) or UDim2.new(0,1,0.5,-7),
        BackgroundColor3=kaEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
    }):Play()
    TweenService:Create(kaStroke,TweenInfo.new(0.2),{Color=kaEnabled and KA_COR or Color3.fromRGB(58,42,42)}):Play()
    if kaEnabled then
        startKillAura()
        Notify.send({type="custom",icon="⚔️",accent=KA_COR,
            title="Kill Aura",
            msg=T("kaOnMsg").." ("..kaRange.." st).",
            duration=5})
    else
        stopKillAura()
        Notify.info("Kill Aura", T("kaOffMsg"))
    end
end)

makeSec(Pages["AvancadoFarm"], afNextLO, "avFarmSecFreeze", Color3.fromRGB(0,200,255))

local FREEZE_COR = Color3.fromRGB(0,200,255)

-- Card principal toggle
local freezeCard = Instance.new("Frame", Pages["AvancadoFarm"])
freezeCard.BackgroundColor3 = Color3.fromRGB(16,20,34)
freezeCard.BorderSizePixel = 0
freezeCard.Size = UDim2.new(1,0,0,70)
freezeCard.LayoutOrder = afNextLO(); freezeCard.ZIndex=5
Instance.new("UICorner",freezeCard).CornerRadius=UDim.new(0,9)
local fzStroke=Instance.new("UIStroke",freezeCard); fzStroke.Color=Color3.fromRGB(42,46,58); fzStroke.Thickness=1

local fzTitleLbl=Instance.new("TextLabel",freezeCard); fzTitleLbl.BackgroundTransparency=1
fzTitleLbl.Position=UDim2.new(0,14,0,6); fzTitleLbl.Size=UDim2.new(1,-80,0,18); fzTitleLbl.Font=Enum.Font.GothamBold
fzTitleLbl.Text=T("freezeTitle"); fzTitleLbl.TextColor3=Color3.fromRGB(220,225,240); fzTitleLbl.TextSize=12
fzTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; fzTitleLbl.ZIndex=7
trackLabel(fzTitleLbl, "freezeTitle")
local fzDescLbl=Instance.new("TextLabel",freezeCard); fzDescLbl.BackgroundTransparency=1
fzDescLbl.Position=UDim2.new(0,14,0,26); fzDescLbl.Size=UDim2.new(1,-80,0,36); fzDescLbl.Font=Enum.Font.Gotham
fzDescLbl.Text=T("freezeDesc"); fzDescLbl.TextColor3=Color3.fromRGB(90,100,120)
fzDescLbl.TextSize=9; fzDescLbl.TextXAlignment=Enum.TextXAlignment.Left; fzDescLbl.TextWrapped=true; fzDescLbl.ZIndex=7
trackLabel(fzDescLbl, "freezeDesc")

local fzPill=Instance.new("Frame",freezeCard); fzPill.BackgroundColor3=Color3.fromRGB(45,50,62); fzPill.BorderSizePixel=0
fzPill.Position=UDim2.new(1,-56,0.5,-13); fzPill.Size=UDim2.new(0,48,0,26); fzPill.ZIndex=9
Instance.new("UICorner",fzPill).CornerRadius=UDim.new(1,0)
local fzKnob=Instance.new("Frame",fzPill); fzKnob.BackgroundColor3=Color3.fromRGB(160,170,185); fzKnob.BorderSizePixel=0
fzKnob.Position=UDim2.new(0,2,0.5,-11); fzKnob.Size=UDim2.new(0,22,0,22); fzKnob.ZIndex=10
Instance.new("UICorner",fzKnob).CornerRadius=UDim.new(1,0)

local fzBtn=Instance.new("TextButton",freezeCard); fzBtn.BackgroundTransparency=1; fzBtn.Size=UDim2.new(1,0,1,0); fzBtn.Text=""; fzBtn.ZIndex=11
fzBtn.MouseButton1Click:Connect(function()
    freezeEnabled = not freezeEnabled
    TweenService:Create(fzPill,TweenInfo.new(0.22),{BackgroundColor3=freezeEnabled and FREEZE_COR or Color3.fromRGB(45,50,62)}):Play()
    TweenService:Create(fzKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position=freezeEnabled and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
        BackgroundColor3=freezeEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
    }):Play()
    TweenService:Create(fzStroke,TweenInfo.new(0.2),{Color=freezeEnabled and FREEZE_COR or Color3.fromRGB(42,46,58)}):Play()
    if freezeEnabled then
        startFreezeAura()
        Notify.send({type="custom",icon="❄️",accent=FREEZE_COR,
            title=T("freezeOn"),
            msg=tostring(freezeRadius)..T("freezeOnMsg"),duration=4})
    else
        stopFreezeAura()
        Notify.info(T("freezeOff"), T("freezeOffMsg"))
    end
end)

-- Card raio com botões +/-
local fzRadiusCard = Instance.new("Frame", Pages["AvancadoFarm"])
fzRadiusCard.BackgroundColor3 = Color3.fromRGB(22,26,40)
fzRadiusCard.BorderSizePixel = 0
fzRadiusCard.Size = UDim2.new(1,0,0,54)
fzRadiusCard.LayoutOrder = afNextLO(); fzRadiusCard.ZIndex=5
Instance.new("UICorner",fzRadiusCard).CornerRadius=UDim.new(0,9)
Instance.new("UIStroke",fzRadiusCard).Color=Color3.fromRGB(0,150,200)

local fzRLbl=Instance.new("TextLabel",fzRadiusCard); fzRLbl.BackgroundTransparency=1
fzRLbl.Position=UDim2.new(0,14,0,6); fzRLbl.Size=UDim2.new(0.5,0,0,18); fzRLbl.Font=Enum.Font.GothamBold
fzRLbl.Text="❄️ "..T("freezeRadius"); fzRLbl.TextColor3=FREEZE_COR; fzRLbl.TextSize=12
fzRLbl.TextXAlignment=Enum.TextXAlignment.Left; fzRLbl.ZIndex=7
trackLabel(fzRLbl, "freezeRadius")

local fzValLbl=Instance.new("TextLabel",fzRadiusCard); fzValLbl.BackgroundTransparency=1
fzValLbl.Position=UDim2.new(0,14,0,28); fzValLbl.Size=UDim2.new(0.4,0,0,18); fzValLbl.Font=Enum.Font.GothamBlack
fzValLbl.Text=tostring(freezeRadius).." st"; fzValLbl.TextColor3=Color3.fromRGB(255,255,255); fzValLbl.TextSize=14
fzValLbl.TextXAlignment=Enum.TextXAlignment.Left; fzValLbl.ZIndex=7

-- Botão MINUS
local fzMinus=Instance.new("TextButton",fzRadiusCard); fzMinus.BackgroundColor3=Color3.fromRGB(30,40,60)
fzMinus.BorderSizePixel=0; fzMinus.Position=UDim2.new(1,-110,0.5,-16); fzMinus.Size=UDim2.new(0,32,0,32)
fzMinus.Text="-"; fzMinus.TextColor3=FREEZE_COR; fzMinus.Font=Enum.Font.GothamBlack; fzMinus.TextSize=18; fzMinus.ZIndex=8
Instance.new("UICorner",fzMinus).CornerRadius=UDim.new(0,8)
fzMinus.MouseButton1Click:Connect(function()
    freezeRadius = math.max(10, freezeRadius - 10)
    fzValLbl.Text = tostring(freezeRadius).." st"
    updateCircleRadius()
end)

-- Botão PLUS
local fzPlus=Instance.new("TextButton",fzRadiusCard); fzPlus.BackgroundColor3=Color3.fromRGB(0,60,90)
fzPlus.BorderSizePixel=0; fzPlus.Position=UDim2.new(1,-70,0.5,-16); fzPlus.Size=UDim2.new(0,32,0,32)
fzPlus.Text="+"; fzPlus.TextColor3=FREEZE_COR; fzPlus.Font=Enum.Font.GothamBlack; fzPlus.TextSize=18; fzPlus.ZIndex=8
Instance.new("UICorner",fzPlus).CornerRadius=UDim.new(0,8)
fzPlus.MouseButton1Click:Connect(function()
    freezeRadius = math.min(500, freezeRadius + 10)
    fzValLbl.Text = tostring(freezeRadius).." st"
    updateCircleRadius()
end)

-- Botão reset ao padrão 185
local fzReset=Instance.new("TextButton",fzRadiusCard); fzReset.BackgroundColor3=Color3.fromRGB(0,80,110)
fzReset.BorderSizePixel=0; fzReset.Position=UDim2.new(1,-34,0.5,-10); fzReset.Size=UDim2.new(0,28,0,20)
fzReset.Text="↺"; fzReset.TextColor3=Color3.fromRGB(180,240,255); fzReset.Font=Enum.Font.GothamBold; fzReset.TextSize=13; fzReset.ZIndex=8
Instance.new("UICorner",fzReset).CornerRadius=UDim.new(0,6)
fzReset.MouseButton1Click:Connect(function()
    freezeRadius = 185
    fzValLbl.Text = "185 st"
    updateCircleRadius()
end)

end -- [[ FARM + AVANÇADO FARM ]]

do -- [[ AIMBOT + ADVANCED ]]
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
      keywords={"child. 1","child.1","child 1","child1","dino kid","dinokid","dino"} },
    { name="🐙 Kraken Kid", desc="4-5 Lobos Alfa • Toca Azul • Fogueira Nível 4", col=Color3.fromRGB(100,160,255),
      keywords={"child. 2","child.2","child 2","child2","kraken kid","krakenkid","kraken"} },
    { name="🦑 Squid Kid",  desc="2 Ursos • Toca Amarela • Fogueira Nível 5",    col=Color3.fromRGB(255,220,60),
      keywords={"child. 3","child.3","child 3","child3","squid kid","squidkid","squid"} },
    { name="🐨 Koala Kid",  desc="6 Ursos • Toca Cinza • Fogueira Nível 6",      col=Color3.fromRGB(180,230,255),
      keywords={"child. 4","child.4","child 4","child4","koala kid","koalakid","koala"} },
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

makeAvSec("🎯 AIMBOT CLÁSSICO (Projéteis)", Color3.fromRGB(255,140,40))
makeAvToggle("🎯 Aimbot (Guided)", "Projéteis se movem automaticamente para o animal mais próximo.", Color3.fromRGB(255,140,40), function(s)
    aimbotEnabled = s
    if s then Notify.warn(T("aimbotOn"), T("aimbotOnMsg")) else Notify.info(T("aimbotOff"), T("aimbotOffMsg")) end
end)
makeAvToggle("🤖 Aimbot AUTO", "Com arma ranged equipada: mira e atira automaticamente nos animais.", Color3.fromRGB(255,180,40), function(s)
    aimbotAutoEnabled = s
    if s then startAimbotAuto(); Notify.warn(T("aimbotAutoOn"), T("aimbotAutoOnMsg")) else Notify.info(T("aimbotAutoOff"), T("aimbotAutoOffMsg")) end
end)

makeAvSec("🗺️ TELEPORT", Color3.fromRGB(100,200,255))
makeTpBiomesPanel()
makeTpCriancasPanel()

-- ══════════════════════════════════════════════════════
end -- [[ AIMBOT + ADVANCED ]]

-- HOME TAB + WELCOME NOTIFICATION
-- ══════════════════════════════════════════════════════
task.wait(0.05)
selectTab("Info")

task.delay(1.5, function()
    Notify.send({
        type   = "custom",
        icon   = "🌲",
        accent = Color3.fromRGB(88,101,242),
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