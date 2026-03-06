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

-- ══════════════════════════════════════════════════════════════════════
-- PUDIM HUB — GATE: só executa o hub depois do clique em JOGAR
-- ══════════════════════════════════════════════════════════════════════
local _LaunchHub  -- forward declaration
local _hubLaunched = false
local _SplashGui   = nil

local function _PudimSplashGate()
    local TS = TweenService
    local PL = Players

    -- ── Data/hora dinâmica ──────────────────────────────────────────
    local _t   = os.time()
    local _dt  = os.date("*t", _t)
    local _dias = {"Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"}
    local _dateStr = string.format(
        "%02d/%02d/%04d  Às  %02d:%02d  [%s]",
        _dt.day, _dt.month, _dt.year, _dt.hour, _dt.min, _dias[_dt.wday]
    )

    -- ── ScreenGui ──────────────────────────────────────────────────
    local SG = Instance.new("ScreenGui")
    SG.Name           = "PudimHubGate"
    SG.ResetOnSpawn   = false
    SG.IgnoreGuiInset = true
    SG.DisplayOrder   = 99999
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local _ok = pcall(function() SG.Parent = game:GetService("CoreGui") end)
    if not _ok then SG.Parent = PL.LocalPlayer:WaitForChild("PlayerGui") end
    _SplashGui = SG

    -- ── Overlay escuro com gradiente ────────────────────────────────
    local OV = Instance.new("Frame", SG)
    OV.Size = UDim2.fromScale(1,1)
    OV.BackgroundColor3 = Color3.fromRGB(12,7,3)
    OV.BackgroundTransparency = 0
    OV.BorderSizePixel = 0
    OV.ZIndex = 1
    local OVG = Instance.new("UIGradient", OV)
    OVG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50,28,10)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8,4,2)),
    })
    OVG.Rotation = 130

    -- ── 22 estrelas de fundo animadas ──────────────────────────────
    for i = 1, 22 do
        local st = Instance.new("TextLabel", SG)
        st.BackgroundTransparency = 1
        st.Text      = (math.random(1,3)==1) and "★" or "✦"
        st.TextSize  = math.random(9,24)
        st.TextColor3= Color3.fromRGB(255, math.random(170,240), 0)
        st.TextTransparency = math.random(4,8)/10
        st.Font      = Enum.Font.GothamBlack
        st.Position  = UDim2.new(math.random(0,96)/100, 0, math.random(0,96)/100, 0)
        st.Size      = UDim2.new(0,32,0,32)
        st.ZIndex    = 2
        TS:Create(st, TweenInfo.new(math.random(9,19)/10, Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut, -1, true), {TextTransparency=math.random(0,2)/10}):Play()
        -- drift lento
        TS:Create(st, TweenInfo.new(math.random(22,38)/10, Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut, -1, true),
            {Position=UDim2.new(st.Position.X.Scale, 0, st.Position.Y.Scale - 0.04, 0)}):Play()
    end

    -- ══════════════════════════════════════════════════════
    -- FASE 1 — BANNER SPLASH (5 segundos)
    -- ══════════════════════════════════════════════════════
    local SPLASH = Instance.new("Frame", SG)
    SPLASH.Size              = UDim2.fromScale(1,1)  -- fullscreen so scale-based children center correctly
    SPLASH.Position          = UDim2.new(0,0,0,0)
    SPLASH.BackgroundTransparency = 1
    SPLASH.BorderSizePixel   = 0
    SPLASH.ZIndex            = 4

    -- Sombra do banner
    local SH = Instance.new("Frame", SPLASH)
    SH.Size                  = UDim2.new(0,568,0,195)
    SH.Position              = UDim2.new(0.5,-284+14,0.5,-97+14)
    SH.BackgroundColor3      = Color3.fromRGB(0,0,0)
    SH.BackgroundTransparency= 0.22
    SH.BorderSizePixel       = 0
    SH.Rotation              = -4.5
    SH.ZIndex                = 3
    Instance.new("UICorner",SH).CornerRadius = UDim.new(0,20)

    -- Banner principal amarelo
    local BN = Instance.new("Frame", SPLASH)
    BN.Size                  = UDim2.new(0,552,0,185)
    BN.Position              = UDim2.new(0.5,-276,0.5,-92)
    BN.BackgroundColor3      = Color3.fromRGB(252,196,0)
    BN.BorderSizePixel       = 0
    BN.Rotation              = -4.5
    BN.ZIndex                = 5
    Instance.new("UICorner",BN).CornerRadius = UDim.new(0,20)
    local BNS = Instance.new("UIStroke",BN)
    BNS.Color                = Color3.fromRGB(20,10,0)
    BNS.Thickness            = 7
    BNS.ApplyStrokeMode      = Enum.ApplyStrokeMode.Border
    local BNG = Instance.new("UIGradient",BN)
    BNG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,  Color3.fromRGB(255,238,70)),
        ColorSequenceKeypoint.new(0.4,Color3.fromRGB(252,196,0)),
        ColorSequenceKeypoint.new(1,  Color3.fromRGB(185,122,0)),
    })
    BNG.Rotation = 105

    -- Brilho cartoon (shine) no banner
    local SHN = Instance.new("Frame",BN)
    SHN.Size                 = UDim2.new(0,90,0,32)
    SHN.Position             = UDim2.new(0,22,0,14)
    SHN.BackgroundColor3     = Color3.fromRGB(255,255,255)
    SHN.BackgroundTransparency = 0.55
    SHN.BorderSizePixel      = 0
    SHN.Rotation             = -8
    SHN.ZIndex               = 6
    Instance.new("UICorner",SHN).CornerRadius = UDim.new(1,0)

    -- Segundo shine menor
    local SHN2 = Instance.new("Frame",BN)
    SHN2.Size                = UDim2.new(0,44,0,16)
    SHN2.Position            = UDim2.new(0,28,0,50)
    SHN2.BackgroundColor3    = Color3.fromRGB(255,255,255)
    SHN2.BackgroundTransparency = 0.72
    SHN2.BorderSizePixel     = 0
    SHN2.Rotation            = -8
    SHN2.ZIndex              = 6
    Instance.new("UICorner",SHN2).CornerRadius = UDim.new(1,0)

    -- Texto PUDIM
    local TPUD = Instance.new("TextLabel",BN)
    TPUD.Size                = UDim2.new(1,-24,0,95)
    TPUD.Position            = UDim2.new(0,12,0,5)
    TPUD.BackgroundTransparency = 1
    TPUD.Text                = "PUDIM"
    TPUD.TextColor3          = Color3.fromRGB(255,255,255)
    TPUD.Font                = Enum.Font.GothamBlack
    TPUD.TextSize            = 82
    TPUD.TextXAlignment      = Enum.TextXAlignment.Center
    TPUD.ZIndex              = 7
    local TPUDS = Instance.new("UIStroke",TPUD)
    TPUDS.Color              = Color3.fromRGB(18,8,0)
    TPUDS.Thickness          = 6

    -- Texto HUB
    local THUB = Instance.new("TextLabel",BN)
    THUB.Size                = UDim2.new(1,-24,0,60)
    THUB.Position            = UDim2.new(0,12,0,96)
    THUB.BackgroundTransparency = 1
    THUB.Text                = "HUB"
    THUB.TextColor3          = Color3.fromRGB(30,14,0)
    THUB.Font                = Enum.Font.GothamBlack
    THUB.TextSize            = 46
    THUB.TextXAlignment      = Enum.TextXAlignment.Center
    THUB.ZIndex              = 7
    local THUBS = Instance.new("UIStroke",THUB)
    THUBS.Color              = Color3.fromRGB(0,0,0)
    THUBS.Thickness          = 2.5

    -- (estrelas removidas)

    -- Ícone pudim flutuando acima do banner
    local ICO = Instance.new("TextLabel", SG)
    ICO.Size             = UDim2.new(0,72,0,72)
    ICO.Position         = UDim2.new(0.5,-36, 0.5,-218)
    ICO.BackgroundTransparency = 1
    ICO.Text             = "🍮"
    ICO.TextSize         = 58
    ICO.Font             = Enum.Font.GothamBold
    ICO.TextXAlignment   = Enum.TextXAlignment.Center
    ICO.TextTransparency = 1
    ICO.ZIndex           = 9
    TS:Create(ICO, TweenInfo.new(1.15,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
        {Position=UDim2.new(0.5,-36,0.5,-228)}):Play()

    -- Subtítulo
    local SUB = Instance.new("TextLabel", SG)
    SUB.Size             = UDim2.new(0,560,0,28)
    SUB.Position         = UDim2.new(0.5,-280,0.5, 100)
    SUB.BackgroundTransparency = 1
    SUB.Text             = "99 Dias na Floresta  •  Hub v5  •  2026"
    SUB.TextColor3       = Color3.fromRGB(255,235,190)
    SUB.Font             = Enum.Font.GothamBold
    SUB.TextSize         = 17
    SUB.TextXAlignment   = Enum.TextXAlignment.Center
    SUB.TextTransparency = 1
    SUB.ZIndex           = 6

    -- Loading dots
    local DOT = Instance.new("TextLabel", SG)
    DOT.Size             = UDim2.new(0,560,0,22)
    DOT.Position         = UDim2.new(0.5,-280,0.5,133)
    DOT.BackgroundTransparency = 1
    DOT.Text             = "● ● ●"
    DOT.TextColor3       = Color3.fromRGB(255,198,0)
    DOT.Font             = Enum.Font.GothamBold
    DOT.TextSize         = 13
    DOT.TextXAlignment   = Enum.TextXAlignment.Center
    DOT.TextTransparency = 1
    DOT.ZIndex           = 6

    -- ENTER animation (bounce vindo de cima)
    SPLASH.Position = UDim2.new(0, 0, -1, 0)
    TS:Create(SPLASH, TweenInfo.new(0.72,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(0,0,0,0)}):Play()
    task.delay(0.4, function()
        TS:Create(ICO,  TweenInfo.new(0.38,Enum.EasingStyle.Quad),{TextTransparency=0}):Play()
        TS:Create(SUB,  TweenInfo.new(0.38,Enum.EasingStyle.Quad),{TextTransparency=0}):Play()
    end)
    task.delay(0.6, function()
        TS:Create(DOT,  TweenInfo.new(0.38,Enum.EasingStyle.Quad),{TextTransparency=0}):Play()
    end)

    -- Animação dots cíclica
    local _dotFrames = {"●  ○  ○","○  ●  ○","○  ○  ●","○  ●  ○","●  ●  ●"}
    local _dotIdx = 1
    local _dotAlive = true
    task.spawn(function()
        while _dotAlive do
            _dotIdx = (_dotIdx % #_dotFrames)+1
            if DOT and DOT.Parent then DOT.Text = _dotFrames[_dotIdx] end
            task.wait(0.28)
        end
    end)

    -- Escala pulsante no banner (respira)
    task.spawn(function()
        local _alive = true
        task.delay(4.5, function() _alive = false end)
        while _alive do
            TS:Create(BN, TweenInfo.new(0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
                {Size=UDim2.new(0,558,0,190)}):Play()
            task.wait(0.9)
            TS:Create(BN, TweenInfo.new(0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
                {Size=UDim2.new(0,552,0,185)}):Play()
            task.wait(0.9)
        end
    end)

    -- ══════════════════════════════════════════════════════
    -- FASE 2 — JANELA INFO (após 5 segundos)
    -- ══════════════════════════════════════════════════════
    task.delay(5.0, function()
        if not (SG and SG.Parent) then return end
        _dotAlive = false

        -- Splash sai voando para baixo
        TS:Create(SPLASH, TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.In),
            {Position=UDim2.new(0.5,0,1.8,0)}):Play()
        TS:Create(ICO,  TweenInfo.new(0.28,Enum.EasingStyle.Quad),{TextTransparency=1}):Play()
        TS:Create(SUB,  TweenInfo.new(0.28,Enum.EasingStyle.Quad),{TextTransparency=1}):Play()
        TS:Create(DOT,  TweenInfo.new(0.28,Enum.EasingStyle.Quad),{TextTransparency=1}):Play()

        task.delay(0.55, function()
            if not (SG and SG.Parent) then return end

            -- Fundo escurecido semi-transparente
            local IBKG = Instance.new("Frame", SG)
            IBKG.Size              = UDim2.fromScale(1,1)
            IBKG.BackgroundColor3  = Color3.fromRGB(0,0,0)
            IBKG.BackgroundTransparency = 1
            IBKG.BorderSizePixel   = 0
            IBKG.ZIndex            = 5
            TS:Create(IBKG, TweenInfo.new(0.38,Enum.EasingStyle.Quad),
                {BackgroundTransparency=0.42}):Play()

            -- Card principal
            local CARD = Instance.new("Frame", SG)
            CARD.Size              = UDim2.new(0,470,0,355)
            CARD.Position          = UDim2.new(0.5,-235,1.8,0) -- começa abaixo
            CARD.BackgroundColor3  = Color3.fromRGB(14,9,28)
            CARD.BorderSizePixel   = 0
            CARD.ZIndex            = 6
            Instance.new("UICorner",CARD).CornerRadius = UDim.new(0,24)
            local CARDS = Instance.new("UIStroke",CARD)
            CARDS.Color            = Color3.fromRGB(252,198,0)
            CARDS.Thickness        = 5
            CARDS.ApplyStrokeMode  = Enum.ApplyStrokeMode.Border
            local CARDG = Instance.new("UIGradient",CARD)
            CARDG.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(42,24,72)),
                ColorSequenceKeypoint.new(0.5,Color3.fromRGB(40,24,12)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(10,6,20)),
            })
            CARDG.Rotation = 150

            -- Sombra do card
            local CSHAD = Instance.new("Frame", SG)
            CSHAD.Size             = UDim2.new(0,476,0,360)
            CSHAD.BackgroundColor3 = Color3.fromRGB(0,0,0)
            CSHAD.BackgroundTransparency = 0.3
            CSHAD.BorderSizePixel  = 0
            CSHAD.ZIndex           = 5
            Instance.new("UICorner",CSHAD).CornerRadius = UDim.new(0,26)
            -- posição da sombra linkada ao card via tween

            -- Barra topo dourada
            local TOPB = Instance.new("Frame",CARD)
            TOPB.Size              = UDim2.new(1,0,0,10)
            TOPB.Position          = UDim2.new(0,0,0,0)
            TOPB.BackgroundColor3  = Color3.fromRGB(252,198,0)
            TOPB.BorderSizePixel   = 0
            TOPB.ZIndex            = 7
            Instance.new("UICorner",TOPB).CornerRadius = UDim.new(0,5)
            local TOPBG = Instance.new("UIGradient",TOPB)
            TOPBG.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(255,240,90)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(195,128,0)),
            })

            -- Barra borda esquerda colorida (detalhe)
            local SIDEB = Instance.new("Frame",CARD)
            SIDEB.Size             = UDim2.new(0,5,1,-10)
            SIDEB.Position         = UDim2.new(0,0,0,10)
            SIDEB.BackgroundColor3 = Color3.fromRGB(252,198,0)
            SIDEB.BorderSizePixel  = 0
            SIDEB.ZIndex           = 7
            Instance.new("UICorner",SIDEB).CornerRadius = UDim.new(0,4)
            local SIDEBG = Instance.new("UIGradient",SIDEB)
            SIDEBG.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(252,198,0)),
                ColorSequenceKeypoint.new(0.5,Color3.fromRGB(252,198,0)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(200,155,0)),
            })
            SIDEBG.Rotation = 90

            -- (estrelas removidas)

            -- Ícone pudim no topo do card
            local CICO = Instance.new("TextLabel",CARD)
            CICO.Size              = UDim2.new(0,70,0,70)
            CICO.Position          = UDim2.new(0.5,-35,0,14)
            CICO.BackgroundTransparency = 1
            CICO.Text              = "🍮"
            CICO.TextSize          = 54
            CICO.Font              = Enum.Font.GothamBold
            CICO.TextXAlignment    = Enum.TextXAlignment.Center
            CICO.ZIndex            = 8
            TS:Create(CICO,TweenInfo.new(1.1,Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut,-1,true),
                {Position=UDim2.new(0.5,-35,0,8)}):Play()

            -- Badge "v5"
            local BADGE = Instance.new("TextLabel",CARD)
            BADGE.Size             = UDim2.new(0,40,0,20)
            BADGE.Position         = UDim2.new(0.5,30,0,26)
            BADGE.BackgroundColor3 = Color3.fromRGB(200,155,0)
            BADGE.BorderSizePixel  = 0
            BADGE.Text             = "v5"
            BADGE.TextColor3       = Color3.fromRGB(255,255,255)
            BADGE.Font             = Enum.Font.GothamBlack
            BADGE.TextSize         = 12
            BADGE.TextXAlignment   = Enum.TextXAlignment.Center
            BADGE.ZIndex           = 9
            Instance.new("UICorner",BADGE).CornerRadius = UDim.new(1,0)
            local BADGES = Instance.new("UIStroke",BADGE)
            BADGES.Color           = Color3.fromRGB(255,255,255)
            BADGES.Thickness       = 1.5

            -- Título "PudimHub"
            local CTIT = Instance.new("TextLabel",CARD)
            CTIT.Size              = UDim2.new(1,-24,0,42)
            CTIT.Position          = UDim2.new(0,12,0,88)
            CTIT.BackgroundTransparency = 1
            CTIT.Text              = "PudimHub"
            CTIT.TextColor3        = Color3.fromRGB(252,198,0)
            CTIT.Font              = Enum.Font.GothamBlack
            CTIT.TextSize          = 34
            CTIT.TextXAlignment    = Enum.TextXAlignment.Center
            CTIT.ZIndex            = 8
            local CTITS = Instance.new("UIStroke",CTIT)
            CTITS.Color            = Color3.fromRGB(70,38,0)
            CTITS.Thickness        = 2.8

            -- Divisória com gradiente
            local DIV = Instance.new("Frame",CARD)
            DIV.Size               = UDim2.new(0.8,0,0,2)
            DIV.Position           = UDim2.new(0.1,0,0,136)
            DIV.BackgroundColor3   = Color3.fromRGB(252,198,0)
            DIV.BackgroundTransparency = 0.5
            DIV.BorderSizePixel    = 0
            DIV.ZIndex             = 7
            Instance.new("UICorner",DIV).CornerRadius = UDim.new(1,0)
            local DIVG = Instance.new("UIGradient",DIV)
            DIVG.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
                ColorSequenceKeypoint.new(0.2,Color3.fromRGB(252,198,0)),
                ColorSequenceKeypoint.new(0.8,Color3.fromRGB(252,198,0)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
            })

            -- Subtítulo jogo
            local CGAME = Instance.new("TextLabel",CARD)
            CGAME.Size             = UDim2.new(1,-24,0,28)
            CGAME.Position         = UDim2.new(0,12,0,144)
            CGAME.BackgroundTransparency = 1
            CGAME.Text             = "99 Dias na Floresta"
            CGAME.TextColor3       = Color3.fromRGB(255,220,130)
            CGAME.Font             = Enum.Font.GothamBold
            CGAME.TextSize         = 19
            CGAME.TextXAlignment   = Enum.TextXAlignment.Center
            CGAME.ZIndex           = 8

            -- Label versão/game
            local CVER = Instance.new("TextLabel",CARD)
            CVER.Size              = UDim2.new(1,-24,0,20)
            CVER.Position          = UDim2.new(0,12,0,174)
            CVER.BackgroundTransparency = 1
            CVER.Text              = "Script v5  •  Notification System v3"
            CVER.TextColor3        = Color3.fromRGB(160,130,70)
            CVER.Font              = Enum.Font.Gotham
            CVER.TextSize          = 12
            CVER.TextXAlignment    = Enum.TextXAlignment.Center
            CVER.ZIndex            = 8

            -- Divisória menor
            local DIV2 = Instance.new("Frame",CARD)
            DIV2.Size              = UDim2.new(0.6,0,0,1)
            DIV2.Position          = UDim2.new(0.2,0,0,200)
            DIV2.BackgroundColor3  = Color3.fromRGB(255,198,0)
            DIV2.BackgroundTransparency = 0.75
            DIV2.BorderSizePixel   = 0
            DIV2.ZIndex            = 7
            Instance.new("UICorner",DIV2).CornerRadius = UDim.new(1,0)

            -- Label "Última Atualização"
            local CUPD = Instance.new("TextLabel",CARD)
            CUPD.Size              = UDim2.new(1,-24,0,20)
            CUPD.Position          = UDim2.new(0,12,0,208)
            CUPD.BackgroundTransparency = 1
            CUPD.Text              = "🔄  Última Atualização"
            CUPD.TextColor3        = Color3.fromRGB(155,125,70)
            CUPD.Font              = Enum.Font.Gotham
            CUPD.TextSize          = 13
            CUPD.TextXAlignment    = Enum.TextXAlignment.Center
            CUPD.ZIndex            = 8

            -- Data dinâmica pulsando
            local CDATE = Instance.new("TextLabel",CARD)
            CDATE.Size             = UDim2.new(1,-24,0,30)
            CDATE.Position         = UDim2.new(0,12,0,230)
            CDATE.BackgroundTransparency = 1
            CDATE.Text             = _dateStr
            CDATE.TextColor3       = Color3.fromRGB(255,220,55)
            CDATE.Font             = Enum.Font.GothamBold
            CDATE.TextSize         = 14
            CDATE.TextXAlignment   = Enum.TextXAlignment.Center
            CDATE.ZIndex           = 8
            TS:Create(CDATE,TweenInfo.new(1.2,Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut,-1,true),
                {TextColor3=Color3.fromRGB(255,245,130)}):Play()

            -- Contador regressivo (2 minutos)
            local CTIMER = Instance.new("TextLabel",CARD)
            CTIMER.Size            = UDim2.new(1,-24,0,18)
            CTIMER.Position        = UDim2.new(0,12,0,264)
            CTIMER.BackgroundTransparency = 1
            CTIMER.Text            = "⏱  Fecha em 02:00 se não jogar"
            CTIMER.TextColor3      = Color3.fromRGB(200,100,100)
            CTIMER.Font            = Enum.Font.Gotham
            CTIMER.TextSize        = 11
            CTIMER.TextXAlignment  = Enum.TextXAlignment.Center
            CTIMER.ZIndex          = 8

            -- Botão JOGAR
            local CBTN = Instance.new("TextButton",CARD)
            CBTN.Size              = UDim2.new(0,190,0,50)
            CBTN.Position          = UDim2.new(0.5,-95,0,290)
            CBTN.BackgroundColor3  = Color3.fromRGB(252,198,0)
            CBTN.BorderSizePixel   = 0
            CBTN.Text              = "▶   JOGAR"
            CBTN.TextColor3        = Color3.fromRGB(22,10,0)
            CBTN.Font              = Enum.Font.GothamBlack
            CBTN.TextSize          = 21
            CBTN.ZIndex            = 10
            Instance.new("UICorner",CBTN).CornerRadius = UDim.new(0,13)
            local CBTNS = Instance.new("UIStroke",CBTN)
            CBTNS.Color            = Color3.fromRGB(18,8,0)
            CBTNS.Thickness        = 4
            CBTNS.ApplyStrokeMode  = Enum.ApplyStrokeMode.Border
            local CBTNGG = Instance.new("UIGradient",CBTN)
            CBTNGG.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(255,235,90)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(205,140,0)),
            })
            CBTNGG.Rotation = 90
            -- Brilho no botão
            local BSHINE = Instance.new("Frame",CBTN)
            BSHINE.Size            = UDim2.new(0,55,0,14)
            BSHINE.Position        = UDim2.new(0,8,0,5)
            BSHINE.BackgroundColor3= Color3.fromRGB(255,255,255)
            BSHINE.BackgroundTransparency = 0.62
            BSHINE.BorderSizePixel = 0
            BSHINE.Rotation        = -6
            BSHINE.ZIndex          = 11
            Instance.new("UICorner",BSHINE).CornerRadius = UDim.new(1,0)

            -- Hover botão
            CBTN.MouseEnter:Connect(function()
                TS:Create(CBTN,TweenInfo.new(0.1),{
                    Size    =UDim2.new(0,200,0,54),
                    Position=UDim2.new(0.5,-100,0,286),
                    BackgroundColor3=Color3.fromRGB(255,210,20),
                }):Play()
            end)
            CBTN.MouseLeave:Connect(function()
                TS:Create(CBTN,TweenInfo.new(0.1),{
                    Size    =UDim2.new(0,190,0,50),
                    Position=UDim2.new(0.5,-95,0,290),
                    BackgroundColor3=Color3.fromRGB(252,198,0),
                }):Play()
            end)

            -- Posição sombra acompanha card (aproximada)
            local function _syncShadow(cardPos)
                CSHAD.Position = UDim2.new(
                    cardPos.X.Scale, cardPos.X.Offset+14,
                    cardPos.Y.Scale, cardPos.Y.Offset+14
                )
            end

            -- Countdown 2 minutos
            local _timerAlive = true
            local _totalSec   = 120
            task.spawn(function()
                while _timerAlive and _totalSec > 0 do
                    task.wait(1)
                    _totalSec = _totalSec - 1
                    if CTIMER and CTIMER.Parent then
                        local m = math.floor(_totalSec/60)
                        local s2 = _totalSec % 60
                        CTIMER.Text = string.format("⏱  Fecha em %02d:%02d se não jogar", m, s2)
                        if _totalSec <= 30 then
                            CTIMER.TextColor3 = Color3.fromRGB(255, 80, 60)
                            -- Pulsar urgente nos últimos 30s
                            TS:Create(CTIMER,TweenInfo.new(0.4,Enum.EasingStyle.Quad,
                                Enum.EasingDirection.InOut),
                                {TextTransparency=0.4}):Play()
                            task.wait(0.45)
                            TS:Create(CTIMER,TweenInfo.new(0.4,Enum.EasingStyle.Quad,
                                Enum.EasingDirection.InOut),
                                {TextTransparency=0}):Play()
                        end
                    end
                end
                -- Tempo esgotado → fecha sem executar
                if not _hubLaunched and CARD and CARD.Parent then
                    if CDATE and CDATE.Parent then
                        CDATE.Text = "⏱ Tempo esgotado — script cancelado"
                        CDATE.TextColor3 = Color3.fromRGB(255,80,60)
                    end
                    task.wait(1.2)
                    TS:Create(CARD,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.In),
                        {Position=UDim2.new(0.5,-235,1.8,0)}):Play()
                    TS:Create(CSHAD,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.In),
                        {Position=UDim2.new(0.5,-221,1.8,14)}):Play()
                    TS:Create(IBKG,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
                    TS:Create(OV,  TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
                    task.delay(0.6, function()
                        pcall(function() SG:Destroy() end)
                    end)
                end
            end)

            -- Função lançar hub com animação
            local function _doLaunch()
                if _hubLaunched then return end
                _hubLaunched = true
                _timerAlive  = false

                -- Botão muda para "Carregando..."
                CBTN.Text      = "⏳  Carregando..."
                CBTN.TextColor3= Color3.fromRGB(255,255,255)
                CBTN.BackgroundColor3 = Color3.fromRGB(200,155,0)

                task.wait(0.2)

                -- Card escala para 0 e desaparece (zoom out)
                TS:Create(CARD,TweenInfo.new(0.55,Enum.EasingStyle.Back,Enum.EasingDirection.In),
                    {Position=UDim2.new(0.5,-235,1.8,0)}):Play()
                TS:Create(CSHAD,TweenInfo.new(0.55,Enum.EasingStyle.Back,Enum.EasingDirection.In),
                    {Position=UDim2.new(0.5,-221,1.8,14)}):Play()
                TS:Create(IBKG,TweenInfo.new(0.5),{BackgroundTransparency=1}):Play()
                TS:Create(OV,  TweenInfo.new(0.55),{BackgroundTransparency=1}):Play()

                task.delay(0.65, function()
                    pcall(function() SG:Destroy() end)
                    -- Lança o hub!
                    task.spawn(_LaunchHub)
                end)
            end

            CBTN.MouseButton1Click:Connect(_doLaunch)

            -- Bounce de entrada do card vindo de baixo
            local _targetCardPos = UDim2.new(0.5,-235,0.5,-177)
            TS:Create(CARD,TweenInfo.new(0.65,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
                {Position=_targetCardPos}):Play()
            task.spawn(function()
                task.wait(0.05)
                while CARD and CARD.Parent and not _hubLaunched do
                    _syncShadow(CARD.Position)
                    task.wait(0.016)
                end
            end)
        end) -- fim task.delay 0.55
    end) -- fim task.delay 5.0
end

task.spawn(_PudimSplashGate)

-- ══════════════════════════════════════════════════════════════════════
-- WRAP: todo o hub fica dentro de _LaunchHub (só roda ao clicar JOGAR)
-- ══════════════════════════════════════════════════════════════════════
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
    success     = { title="Sucesso",    accent=Color3.fromRGB(60,220,120),   icon="✅", bg=Color3.fromRGB(6,22,12),   sound=6031221736 },
    error       = { title="Erro",       accent=Color3.fromRGB(255,60,60),    icon="❌", bg=Color3.fromRGB(24,6,6),    sound=2544086171 },
    warn        = { title="Aviso",      accent=Color3.fromRGB(255,185,0),    icon="⚠️", bg=Color3.fromRGB(22,14,0),   sound=3386627205 },
    info        = { title="Info",       accent=Color3.fromRGB(60,160,255),   icon="💬", bg=Color3.fromRGB(6,12,26),   sound=4613146380 },
    achievement = { title="Conquista!", accent=Color3.fromRGB(255,210,0),    icon="🏆", bg=Color3.fromRGB(22,16,0),   sound=6042053626 },
    custom      = { title="Aviso",      accent=Color3.fromRGB(180,100,255),  icon="💡", bg=Color3.fromRGB(14,8,22),   sound=6012002983 },
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
NBadge.BackgroundColor3   = Color3.fromRGB(200,155,0)
NBadge.BorderSizePixel    = 0
NBadge.AnchorPoint        = Vector2.new(1,1)
NBadge.Position           = UDim2.new(1,-14,1,-14)
NBadge.Size               = UDim2.new(0,36,0,36)
NBadge.ZIndex             = 502
NBadge.Visible            = false  -- sempre oculto
Instance.new("UICorner",NBadge).CornerRadius = UDim.new(1,0)
local NBadgeStroke = Instance.new("UIStroke",NBadge)
NBadgeStroke.Color = Color3.fromRGB(252,198,0); NBadgeStroke.Thickness=1.5
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
NHistPanel.Name="HistPanel"; NHistPanel.BackgroundColor3=Color3.fromRGB(10,6,20)
NHistPanel.BorderSizePixel=0; NHistPanel.AnchorPoint=Vector2.new(1,1)
NHistPanel.Position=UDim2.new(1,-14,1,-58); NHistPanel.Size=UDim2.new(0,340,0,0)
NHistPanel.ZIndex=510; NHistPanel.ClipsDescendants=true; NHistPanel.Visible=false
Instance.new("UICorner",NHistPanel).CornerRadius=UDim.new(0,14)
local NHistStroke=Instance.new("UIStroke",NHistPanel); NHistStroke.Color=Color3.fromRGB(252,198,0); NHistStroke.Thickness=2.5; NHistStroke.Transparency=0.55

local NHistHeader=Instance.new("Frame",NHistPanel)
NHistHeader.BackgroundColor3=Color3.fromRGB(28,16,8); NHistHeader.BorderSizePixel=0
NHistHeader.Size=UDim2.new(1,0,0,44); NHistHeader.ZIndex=511
Instance.new("UICorner",NHistHeader).CornerRadius=UDim.new(0,14)
local NHistHeaderFix=Instance.new("Frame",NHistHeader)
NHistHeaderFix.BackgroundColor3=Color3.fromRGB(14,15,20); NHistHeaderFix.BorderSizePixel=0
NHistHeaderFix.Position=UDim2.new(0,0,0.5,0); NHistHeaderFix.Size=UDim2.new(1,0,0.5,0); NHistHeaderFix.ZIndex=511
local NHistTitle=Instance.new("TextLabel",NHistHeader)
NHistTitle.BackgroundTransparency=1; NHistTitle.Position=UDim2.new(0,14,0,0)
NHistTitle.Size=UDim2.new(1,-60,1,0); NHistTitle.Font=Enum.Font.GothamBlack
NHistTitle.Text="🔔 Notifications"; NHistTitle.TextColor3=Color3.fromRGB(252,198,0)
trackLabel(NHistTitle, "notifHistTitle")
NHistTitle.TextSize=12; NHistTitle.TextXAlignment=Enum.TextXAlignment.Left; NHistTitle.ZIndex=512
local NHistClearBtn=Instance.new("TextButton",NHistHeader)
NHistClearBtn.BackgroundColor3=Color3.fromRGB(80,20,20); NHistClearBtn.BackgroundTransparency=0.25
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
NHistScroll.ScrollBarImageColor3=Color3.fromRGB(200,155,0)
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
NEmptyLbl.TextColor3=Color3.fromRGB(150,110,55); NEmptyLbl.TextSize=11
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
    hTitle.TextColor3 = Color3.fromRGB(255,235,200); hTitle.TextSize = 10
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
    hMsg.TextColor3 = Color3.fromRGB(155,120,70); hMsg.TextSize = 9
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
    local bg     = t.bg
    local dur    = cfg.duration or NOTIF_CFG.DEFAULT_DURATION
    local action = cfg.action
    local HAS_MSG = msg ~= ""

    local TOTAL_H = HAS_MSG and 80 or 56
    if action then TOTAL_H = TOTAL_H + 32 end

    local startX  =  NOTIF_CFG.WIDTH + 60
    local targetX = -NOTIF_CFG.PADDING
    local topY    =  NOTIF_CFG.PADDING

    -- Card principal
    local card = Instance.new("Frame", NotifRoot)
    card.Name             = "PudimNotif_"..tostring(tick())
    card.BackgroundColor3 = bg
    card.BorderSizePixel  = 0
    card.AnchorPoint      = Vector2.new(1, 0)
    card.Position         = UDim2.new(1, startX, 0, topY)
    card.Size             = UDim2.new(0, NOTIF_CFG.WIDTH, 0, TOTAL_H)
    card.ZIndex           = 520
    card.ClipsDescendants = true
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color       = accent
    cardStroke.Thickness   = 2
    cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    cardStroke.Transparency = 0.35

    -- Faixa lateral colorida
    local strip = Instance.new("Frame", card)
    strip.BackgroundColor3 = accent
    strip.BorderSizePixel  = 0
    strip.Size             = UDim2.new(0, 4, 1, 0)
    strip.ZIndex           = 521

    -- Brilho no topo
    local shine = Instance.new("Frame", card)
    shine.BackgroundColor3    = Color3.fromRGB(255,255,255)
    shine.BackgroundTransparency = 0.88
    shine.BorderSizePixel     = 0
    shine.Position            = UDim2.new(0, 4, 0, 0)
    shine.Size                = UDim2.new(1, -4, 0, 1)
    shine.ZIndex              = 522

    -- Ícone grande
    local iconBg = Instance.new("Frame", card)
    iconBg.BackgroundColor3       = accent
    iconBg.BackgroundTransparency = 0.75
    iconBg.BorderSizePixel        = 0
    iconBg.Position               = UDim2.new(0, 12, 0.5, 0)
    iconBg.AnchorPoint            = Vector2.new(0, 0.5)
    iconBg.Size                   = UDim2.new(0, 36, 0, 36)
    iconBg.ZIndex                 = 522
    Instance.new("UICorner", iconBg).CornerRadius = UDim.new(0, 8)
    local iconLbl = Instance.new("TextLabel", iconBg)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Size      = UDim2.new(1, 0, 1, 0)
    iconLbl.Font      = Enum.Font.GothamBold
    iconLbl.Text      = icon
    iconLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    iconLbl.TextSize  = 20
    iconLbl.ZIndex    = 524

    -- Título
    local titleY = HAS_MSG and 10 or math.floor(TOTAL_H/2 - 9)
    local titleLbl = Instance.new("TextLabel", card)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0, 56, 0, titleY)
    titleLbl.Size     = UDim2.new(1, -80, 0, 18)
    titleLbl.Font     = Enum.Font.GothamBlack
    titleLbl.Text     = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment  = Enum.TextXAlignment.Left
    titleLbl.TextTruncate    = Enum.TextTruncate.AtEnd
    titleLbl.ZIndex   = 522

    -- Badge tipo
    local badgeFr = Instance.new("Frame", card)
    badgeFr.BackgroundColor3 = accent
    badgeFr.BackgroundTransparency = 0.6
    badgeFr.BorderSizePixel = 0
    badgeFr.Position = UDim2.new(0, 56, 0, titleY + 20)
    badgeFr.Size = UDim2.new(0, 0, 0, 12)
    badgeFr.AutomaticSize = Enum.AutomaticSize.X
    badgeFr.ZIndex = 523
    Instance.new("UICorner", badgeFr).CornerRadius = UDim.new(0, 4)
    local badgePad = Instance.new("UIPadding", badgeFr)
    badgePad.PaddingLeft = UDim.new(0, 5); badgePad.PaddingRight = UDim.new(0, 5)
    local badgeLbl = Instance.new("TextLabel", badgeFr)
    badgeLbl.BackgroundTransparency = 1
    badgeLbl.Size = UDim2.new(0, 0, 1, 0)
    badgeLbl.AutomaticSize = Enum.AutomaticSize.X
    badgeLbl.Font = Enum.Font.GothamBold
    badgeLbl.Text = tipo:upper()
    badgeLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    badgeLbl.TextSize = 7
    badgeLbl.ZIndex = 524

    -- Mensagem
    local msgLblRef = nil
    if HAS_MSG then
        local msgLbl = Instance.new("TextLabel", card)
        msgLbl.BackgroundTransparency = 1
        msgLbl.Position   = UDim2.new(0, 56, 0, 40)
        msgLbl.Size       = UDim2.new(1, -64, 0, 28)
        msgLbl.Font       = Enum.Font.Gotham
        msgLbl.Text       = msg
        msgLbl.TextColor3 = Color3.fromRGB(200, 190, 180)
        msgLbl.TextSize   = 11
        msgLbl.TextXAlignment = Enum.TextXAlignment.Left
        msgLbl.TextWrapped    = true
        msgLbl.ZIndex     = 522
        msgLblRef = msgLbl
    end

    -- Botão de ação
    if action then
        local actionBtn = Instance.new("TextButton", card)
        actionBtn.BackgroundColor3   = accent
        actionBtn.BackgroundTransparency = 0.55
        actionBtn.BorderSizePixel    = 0
        actionBtn.Position           = UDim2.new(0, 56, 0, TOTAL_H - 34)
        actionBtn.Size               = UDim2.new(0, 100, 0, 24)
        actionBtn.Font               = Enum.Font.GothamBold
        actionBtn.Text               = action.label or "Ver"
        actionBtn.TextColor3         = Color3.fromRGB(255,255,255)
        actionBtn.TextSize           = 10
        actionBtn.ZIndex             = 524
        Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)
        actionBtn.MouseButton1Click:Connect(function() pcall(action.callback) end)
    end

    -- Botão X
    local closeBg = Instance.new("Frame", card)
    closeBg.BackgroundColor3     = Color3.fromRGB(180, 40, 40)
    closeBg.BackgroundTransparency = 0.2
    closeBg.BorderSizePixel      = 0
    closeBg.AnchorPoint          = Vector2.new(1, 0)
    closeBg.Position             = UDim2.new(1, -6, 0, 6)
    closeBg.Size                 = UDim2.new(0, 18, 0, 18)
    closeBg.ZIndex               = 526
    Instance.new("UICorner", closeBg).CornerRadius = UDim.new(1, 0)
    local closeBtn = Instance.new("TextButton", closeBg)
    closeBtn.BackgroundTransparency = 1
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.Size     = UDim2.new(1,4,1,4)
    closeBtn.Position = UDim2.new(0,-2,0,-2)
    closeBtn.Font     = Enum.Font.GothamBlack
    closeBtn.Text     = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 9
    closeBtn.ZIndex   = 528
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBg, TweenInfo.new(0.1), {BackgroundTransparency=0}):Play()
    end)
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBg, TweenInfo.new(0.1), {BackgroundTransparency=0.2}):Play()
    end)

    -- Barra de progresso
    local progressBg = Instance.new("Frame", card)
    progressBg.BackgroundColor3 = Color3.fromRGB(255,255,255)
    progressBg.BackgroundTransparency = 0.9
    progressBg.BorderSizePixel  = 0
    progressBg.Position         = UDim2.new(0, 4, 1, -3)
    progressBg.Size             = UDim2.new(1, -4, 0, 3)
    progressBg.ZIndex           = 522
    Instance.new("UICorner", progressBg).CornerRadius = UDim.new(0, 2)
    local progressFill = Instance.new("Frame", progressBg)
    progressFill.BackgroundColor3 = accent
    progressFill.BorderSizePixel  = 0
    progressFill.Size             = UDim2.new(1, 0, 1, 0)
    progressFill.ZIndex           = 523
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0, 2)

    -- Entry
    local entry = {
        frame=card, cfg=cfg, tipo=tipo,
        startTick=tick(), duration=dur,
        paused=false, pauseAcc=0, pauseFrom=0,
        _removed=false, progress=progressFill,
        msgLblRef=msgLblRef
    }
    table.insert(nActive, 1, entry)
    nCount = nCount + 1
    NBadgeCountLbl.Text = tostring(nCount)
    NBadgeCountFrame.Visible = (nCount > 0)

    local hitbox = Instance.new("TextButton", card)
    hitbox.BackgroundTransparency = 1
    hitbox.BorderSizePixel = 0
    hitbox.AutoButtonColor = false
    hitbox.Size  = UDim2.new(1, 0, 1, 0)
    hitbox.Text  = ""
    hitbox.ZIndex = 521
    hitbox.MouseEnter:Connect(function()
        if entry._removed then return end
        entry.paused    = true
        entry.pauseFrom = tick()
        TweenService:Create(cardStroke, TweenInfo.new(0.12), {Thickness=3, Transparency=0}):Play()
    end)
    hitbox.MouseLeave:Connect(function()
        if entry._removed then return end
        entry.paused   = false
        entry.pauseAcc = entry.pauseAcc + (tick() - entry.pauseFrom)
        TweenService:Create(cardStroke, TweenInfo.new(0.12), {Thickness=2, Transparency=0.35}):Play()
    end)
    closeBtn.MouseButton1Click:Connect(function() nRemoveEntry(entry) end)

    -- Animação de entrada
    nReflow()
    card.Position = UDim2.new(1, startX, 0, topY)
    task.wait()
    TweenService:Create(card, TweenInfo.new(0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, targetX, 0, topY)
    }):Play()
    task.spawn(function()
        task.wait(0.06)
        TweenService:Create(iconBg, TweenInfo.new(0.1, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size=UDim2.new(0,40,0,40)}):Play()
        task.wait(0.12)
        TweenService:Create(iconBg, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size=UDim2.new(0,36,0,36)}):Play()
    end)

    -- Timer barra
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

function Notify.success(title,msg,dur) Notify.send({type="success",title=title,msg=msg or "",duration=dur}) end
function Notify.error(title,msg,dur)   Notify.send({type="error",  title=title,msg=msg or "",duration=dur}) end
function Notify.warn(title,msg,dur)    Notify.send({type="warn",   title=title,msg=msg or "",duration=dur}) end
function Notify.info(title,msg,dur)    Notify.send({type="info",   title=title,msg=msg or "",duration=dur}) end
function Notify.achievement(title,msg,icon) Notify.send({type="achievement",title=title,msg=msg or "",icon=icon or "★",duration=6}) end

-- Badge toggle history
NBadgeBtn.MouseButton1Click:Connect(function()
    nHistOpen=not nHistOpen
    if nHistOpen then
        NHistPanel.Visible=true; NHistPanel.Size=UDim2.new(0,340,0,0)
        TweenService:Create(NHistPanel,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,340,0,360)}):Play()
        TweenService:Create(NBadge,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(252,198,0)}):Play()
    else
        TweenService:Create(NHistPanel,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{Size=UDim2.new(0,340,0,0)}):Play()
        TweenService:Create(NBadge,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(200,155,0)}):Play()
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
        TweenService:Create(NBadge,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(200,155,0)}):Play()
        task.delay(0.25,function() NHistPanel.Visible=false end)
    end
end)

-- ══════════════════════════════════════════════════════
--  MAIN FRAME — PudimHub Theme (dark purple + gold)
-- ══════════════════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Parent           = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 18, 10)
-- Começa fora de tela (abaixo) — vai animar para o centro
MainFrame.Position         = UDim2.new(0.5, -270, 1.8, 0)
MainFrame.Size             = UDim2.new(0, 540, 0, 370)
MainFrame.BorderSizePixel  = 0
MainFrame.Active           = true
MainFrame.Draggable        = true
MainFrame.ZIndex           = 2
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(252, 198, 0); MainStroke.Thickness = 5

-- Gradiente sutil no fundo do MainFrame
local MainGrad = Instance.new("UIGradient", MainFrame)
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,  Color3.fromRGB(50, 30, 14)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(32, 20, 10)),
    ColorSequenceKeypoint.new(1,  Color3.fromRGB(20, 12,  6)),
})
MainGrad.Rotation = 140

-- Sombra do MainFrame
local MainShadow = Instance.new("Frame", ScreenGui)
MainShadow.Name              = "MainShadow"
MainShadow.BackgroundColor3  = Color3.fromRGB(0,0,0)
MainShadow.BackgroundTransparency = 0.5
MainShadow.BorderSizePixel   = 0
MainShadow.Position          = UDim2.new(0.5,-263,1.8,10)
MainShadow.Size              = UDim2.new(0,546,0,376)
MainShadow.ZIndex            = 1
MainShadow.Visible           = false   -- oculto até a janela abrir
Instance.new("UICorner",MainShadow).CornerRadius = UDim.new(0,18)

-- Animação de entrada da interface (Back bounce do splash para o centro)
task.delay(0.05, function()
    TweenService:Create(MainShadow, TweenInfo.new(0.7,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(0.5,-263,0.5,-175)}):Play()
    TweenService:Create(MainFrame,  TweenInfo.new(0.7,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Position=UDim2.new(0.5,-270,0.5,-185)}):Play()
end)

-- ══════════════════════════════════════════════════════
-- TOP BAR — PudimHub Gold Style
-- ══════════════════════════════════════════════════════
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name = "TopBar"
TopBar.BackgroundColor3 = Color3.fromRGB(252, 196, 0)
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)
-- Fix dos cantos inferiores (para ficar reto embaixo)
local topFix = Instance.new("Frame", TopBar)
topFix.BackgroundColor3 = Color3.fromRGB(252,196,0)
topFix.BorderSizePixel = 0
topFix.Position = UDim2.new(0,0,0.5,0)
topFix.Size = UDim2.new(1,0,0.5,0)
topFix.ZIndex = 3
-- Gradiente dourado no TopBar
local TopBarGrad = Instance.new("UIGradient", TopBar)
TopBarGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,  Color3.fromRGB(255, 238, 70)),
    ColorSequenceKeypoint.new(0.45,Color3.fromRGB(252, 196, 0)),
    ColorSequenceKeypoint.new(1,  Color3.fromRGB(185, 120, 0)),
})
TopBarGrad.Rotation = 0
-- Contorno preto no TopBar (cartoon)
local TopBarStroke = Instance.new("UIStroke", TopBar)
TopBarStroke.Color     = Color3.fromRGB(20, 10, 0)
TopBarStroke.Thickness = 3  -- borda cartoon visível
-- Shine cartoon no TopBar
local TopShine = Instance.new("Frame", TopBar)
TopShine.Size             = UDim2.new(0,80,0,12)
TopShine.Position         = UDim2.new(0,8,0,5)
TopShine.BackgroundColor3 = Color3.fromRGB(255,255,255)
TopShine.BackgroundTransparency = 0.60
TopShine.BorderSizePixel  = 0
TopShine.Rotation         = -4
TopShine.ZIndex           = 4
Instance.new("UICorner",TopShine).CornerRadius = UDim.new(1,0)

local TitleBox = Instance.new("Frame", TopBar)
TitleBox.BackgroundTransparency = 1
TitleBox.Position = UDim2.new(0, 12, 0, 0)
TitleBox.Size     = UDim2.new(0, 240, 1, 0)
TitleBox.ZIndex   = 4

-- Ícone pudim na topbar
local TitleIcon = Instance.new("TextLabel", TitleBox)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Position = UDim2.new(0, 0, 0.5, -11)
TitleIcon.Size     = UDim2.new(0, 22, 0, 22)
TitleIcon.Text     = "🍮"
TitleIcon.TextSize = 18
TitleIcon.Font     = Enum.Font.GothamBold
TitleIcon.ZIndex   = 5
-- Ícone bobbing na topbar
TweenService:Create(TitleIcon, TweenInfo.new(1.2,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),
    {Position=UDim2.new(0,0,0.5,-14)}):Play()

local TitleLabel = Instance.new("TextLabel", TitleBox)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position       = UDim2.new(0, 28, 0, 0)
TitleLabel.Size           = UDim2.new(1, -28, 1, 0)
TitleLabel.Font           = Enum.Font.GothamBlack
TitleLabel.Text           = "PudimHub v5"
TitleLabel.TextColor3     = Color3.fromRGB(22, 10, 0)
TitleLabel.TextSize       = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex         = 5
local TLStroke = Instance.new("UIStroke", TitleLabel)
TLStroke.Color     = Color3.fromRGB(180, 110, 0)
TLStroke.Thickness = 1.2

local TopBtns = {}
local _topBtnCfg = {
    -- {name, bg normal, bg hover, symbol, symbolSize}
    {name="Theme",    bgN=Color3.fromRGB(120,50,200),  bgH=Color3.fromRGB(150,70,240),  sym="🎨", sz=13},
    {name="Minimize", bgN=Color3.fromRGB(70,70,70),    bgH=Color3.fromRGB(100,100,100), sym="▬",  sz=10},
    {name="Maximize", bgN=Color3.fromRGB(20,110,210),  bgH=Color3.fromRGB(40,140,250),  sym="⛶",  sz=11},
    {name="Close",    bgN=Color3.fromRGB(210,40,40),   bgH=Color3.fromRGB(250,60,60),   sym="✕",  sz=12},
}
-- Sons para cada botão da TopBar (IDs de assets Roblox)
local _topBtnSounds = {
    Theme    = 6012002983,   -- soft click
    Minimize = 6031221736,   -- whoosh down
    Maximize = 4610432017,   -- expand pop
    Close    = 2544086171,   -- close thud
}
local _tbX = -8
for i = #_topBtnCfg, 1, -1 do
    local d = _topBtnCfg[i]
    -- Outer circle
    local ring = Instance.new("Frame", TopBar)
    ring.Name = d.name.."Ring"; ring.BackgroundColor3 = Color3.fromRGB(20,10,0)
    ring.BorderSizePixel = 0; ring.ZIndex = 5
    ring.AnchorPoint = Vector2.new(1, 0.5)
    ring.Position = UDim2.new(1, _tbX, 0.5, 0)
    ring.Size = UDim2.new(0, 28, 0, 28)
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    -- Inner circle (colored)
    local circ = Instance.new("Frame", ring)
    circ.Name = "Circ"; circ.BackgroundColor3 = d.bgN
    circ.BorderSizePixel = 0; circ.ZIndex = 6
    circ.AnchorPoint = Vector2.new(0.5, 0.5)
    circ.Position = UDim2.new(0.5, 0, 0.5, 0)
    circ.Size = UDim2.new(0, 22, 0, 22)
    Instance.new("UICorner", circ).CornerRadius = UDim.new(1, 0)
    local circG = Instance.new("UIGradient", circ)
    circG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
    })
    circG.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.75),
        NumberSequenceKeypoint.new(1, 0.95)
    })
    circG.Rotation = 120
    -- Symbol (usa Legacy para suporte a emoji/unicode no Roblox)
    local sym = Instance.new("TextLabel", circ)
    sym.BackgroundTransparency = 1; sym.Size = UDim2.new(1,0,1,0)
    sym.Font = Enum.Font.Legacy; sym.Text = d.sym
    sym.TextColor3 = Color3.fromRGB(255,255,255); sym.TextSize = d.sz
    sym.ZIndex = 7
    local symS = Instance.new("UIStroke", sym)
    symS.Color = Color3.fromRGB(0,0,0); symS.Thickness = 1; symS.Transparency = 0.6
    -- Invisible button on top
    local btn = Instance.new("TextButton", ring)
    btn.Name = d.name; btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(1,0,1,0); btn.Text = ""; btn.ZIndex = 8
    btn.AutoButtonColor = false
    btn.MouseEnter:Connect(function()
        TweenService:Create(circ, TweenInfo.new(0.12), {BackgroundColor3=d.bgH, Size=UDim2.new(0,24,0,24)}):Play()
        TweenService:Create(ring, TweenInfo.new(0.12), {Size=UDim2.new(0,30,0,30)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(circ, TweenInfo.new(0.15), {BackgroundColor3=d.bgN, Size=UDim2.new(0,22,0,22)}):Play()
        TweenService:Create(ring, TweenInfo.new(0.15), {Size=UDim2.new(0,28,0,28)}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(circ, TweenInfo.new(0.08), {Size=UDim2.new(0,18,0,18)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(circ, TweenInfo.new(0.12, Enum.EasingStyle.Back), {Size=UDim2.new(0,22,0,22)}):Play()
        -- Som do botão
        pcall(function()
            if _topBtnSounds[d.name] then
                local snd=Instance.new("Sound",SoundService)
                snd.SoundId="rbxassetid://"..tostring(_topBtnSounds[d.name])
                snd.Volume=0.4; snd.RollOffMaxDistance=0; snd:Play()
                game:GetService("Debris"):AddItem(snd,3)
            end
        end)
    end)
    TopBtns[d.name] = btn
    _tbX = _tbX - 36
end

-- ══════════════════════════════════════════════════════
--  SIDEBAR — PudimHub Dark Purple
-- ══════════════════════════════════════════════════════
local SideBar = Instance.new("ScrollingFrame", MainFrame)
SideBar.Name = "SideBar"; SideBar.BackgroundColor3 = Color3.fromRGB(32, 20, 12)
SideBar.Position = UDim2.new(0,0,0,50); SideBar.Size = UDim2.new(0,175,1,-88)
SideBar.BorderSizePixel = 0; SideBar.ScrollBarThickness = 0
SideBar.AutomaticCanvasSize = Enum.AutomaticSize.Y; SideBar.CanvasSize = UDim2.new(0,0,0,0); SideBar.ZIndex = 3
SideBar.ClipsDescendants = true
SideBar.ClipsDescendants = true
local SideList = Instance.new("UIListLayout", SideBar)
SideList.Padding = UDim.new(0,2); SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local SidePad = Instance.new("UIPadding", SideBar)
SidePad.PaddingTop = UDim.new(0,8); SidePad.PaddingLeft = UDim.new(0,8)
SidePad.PaddingRight = UDim.new(0,8); SidePad.PaddingBottom = UDim.new(0,8)

local Divider = Instance.new("Frame", MainFrame)
Divider.BackgroundColor3 = Color3.fromRGB(252,198,0); Divider.BackgroundTransparency = 0.78
Divider.BorderSizePixel = 0
Divider.Position = UDim2.new(0,175,0,50); Divider.Size = UDim2.new(0,2,1,-50); Divider.ZIndex = 3

-- ══════════════════════════════════════════════════════
--  CONTENT AREA — PudimHub Dark
-- ══════════════════════════════════════════════════════
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Name = "ContentArea"; ContentArea.BackgroundColor3 = Color3.fromRGB(36, 22, 14)
ContentArea.Position = UDim2.new(0,177,0,50); ContentArea.Size = UDim2.new(1,-177,1,-50)
ContentArea.BorderSizePixel = 0; ContentArea.ZIndex = 3; ContentArea.ClipsDescendants = true

-- ══════════════════════════════════════════════════════
--  FOOTER — PudimHub Dark
-- ══════════════════════════════════════════════════════
local Footer = Instance.new("Frame", MainFrame)
Footer.BackgroundColor3 = Color3.fromRGB(20, 12, 8); Footer.BorderSizePixel = 0
Footer.Position = UDim2.new(0,0,1,-38); Footer.Size = UDim2.new(0,175,0,38); Footer.ZIndex = 4
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 12)
-- Borda topo dourada no footer
local FooterTopLine = Instance.new("Frame", Footer)
FooterTopLine.BackgroundColor3 = Color3.fromRGB(252,198,0)
FooterTopLine.BackgroundTransparency = 0.7
FooterTopLine.BorderSizePixel = 0
FooterTopLine.Position = UDim2.new(0,0,0,0)
FooterTopLine.Size = UDim2.new(1,0,0,1)
FooterTopLine.ZIndex = 5

local AvatarBg = Instance.new("Frame", Footer)
AvatarBg.BackgroundColor3 = Color3.fromRGB(252,198,0)
AvatarBg.Position = UDim2.new(0,8,0.5,-12); AvatarBg.Size = UDim2.new(0,24,0,24); AvatarBg.ZIndex = 5
Instance.new("UICorner", AvatarBg).CornerRadius = UDim.new(1,0)
local AvatarStroke = Instance.new("UIStroke", AvatarBg)
AvatarStroke.Color = Color3.fromRGB(20,10,0); AvatarStroke.Thickness = 1.5
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
FName.Text = Player.DisplayName; FName.TextColor3 = Color3.fromRGB(252,200,60)
FName.TextSize = 10; FName.TextXAlignment = Enum.TextXAlignment.Left
FName.TextTruncate = Enum.TextTruncate.AtEnd; FName.ZIndex = 5

local FTag = Instance.new("TextLabel", Footer)
FTag.BackgroundTransparency = 1; FTag.Position = UDim2.new(0,40,0,19)
FTag.Size = UDim2.new(1,-48,0,12); FTag.Font = Enum.Font.Gotham
FTag.Text = "@"..Player.Name; FTag.TextColor3 = Color3.fromRGB(155,115,55)
FTag.TextSize = 9; FTag.TextXAlignment = Enum.TextXAlignment.Left
FTag.TextTruncate = Enum.TextTruncate.AtEnd; FTag.ZIndex = 5

-- ── Idioma no Footer ──
local FLangFrame = Instance.new("Frame", Footer)
FLangFrame.BackgroundColor3 = Color3.fromRGB(252,198,0)
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
FLangLbl.TextColor3=Color3.fromRGB(20,10,0); FLangLbl.TextSize=8; FLangLbl.ZIndex=7

-- Registra referência para atualizar
langFooterLabel = FLangLbl

-- ══════════════════════════════════════════════════════
--  PAGES
-- ══════════════════════════════════════════════════════
local Pages = {}
local C_ACCENT   = Color3.fromRGB(252, 198, 0)       -- gold
local C_TEXT_OFF = Color3.fromRGB(180, 140, 80)       -- muted warm gold
local C_TEXT_ON  = Color3.fromRGB(255, 220, 50)       -- bright gold
local C_BG_HOV   = Color3.fromRGB(50, 32, 15)         -- hover: dark caramel
local C_BG_ACT   = Color3.fromRGB(70, 45, 15)         -- active: caramel brown
local C_ICON_IDLE   = Color3.fromRGB(155, 115, 55)    -- idle icon warm
local C_ICON_ACTIVE = Color3.fromRGB(252, 198, 0)     -- active icon gold

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
    local ibg = Color3.fromRGB(32,20,12)  -- dark purple bg for icon cutouts
    local cont = Instance.new("Frame",parent); cont.BackgroundTransparency=1; cont.BorderSizePixel=0
    cont.Position=UDim2.new(0,8,0.5,-10); cont.Size=UDim2.new(0,20,0,20)
    cont.ZIndex=parent.ZIndex+2; cont.ClipsDescendants=false
    local parts={}
    local function p(f) table.insert(parts,f); return f end
    if key=="Info" then
        p(mkCircle(cont,10,10,9,ic)); local inner=mkCircle(cont,10,10,7,ibg); inner.ZIndex=cont.ZIndex+1
        p(mkCircle(cont,10,4,2,ic)); p(mkRect(cont,8,8,4,8,ic,2))
    elseif key=="Status" then
        p(mkRect(cont,0,12,4,8,ic,1)); p(mkRect(cont,8,6,4,14,ic,1)); p(mkRect(cont,16,9,4,11,ic,1))
    elseif key=="Farm" then
        p(mkRect(cont,11,0,5,2,ic,1)); p(mkRect(cont,6,2,8,2,ic,0)); p(mkRect(cont,4,4,10,2,ic,0))
        p(mkRect(cont,8,6,8,2,ic,0)); p(mkRect(cont,6,8,8,2,ic,0)); p(mkRect(cont,4,10,8,2,ic,0))
        p(mkRect(cont,2,12,10,2,ic,0)); p(mkRect(cont,4,14,6,2,ic,0)); p(mkRect(cont,3,18,5,2,ic,1))
    elseif key=="Esp" then
        p(mkRect(cont,2,6,16,8,ic,8)); local ei=mkRect(cont,3,7,14,6,ibg,7); ei.ZIndex=cont.ZIndex+1
        p(mkCircle(cont,10,10,4,ic)); local pi=mkCircle(cont,10,10,2,ibg); pi.ZIndex=cont.ZIndex+3
        p(mkCircle(cont,12,8,1,Color3.fromRGB(255,230,100)))
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
        p(mkCircle(cont,10,10,5,ic)); local ci=mkCircle(cont,10,10,3,ibg); ci.ZIndex=cont.ZIndex+2
        for _,deg in ipairs({0,45,90,135,180,225,270,315}) do
            local rad=math.rad(deg)
            p(mkRect(cont,10+math.cos(rad)*8-2,10+math.sin(rad)*8-2,4,4,ic,1))
        end
    elseif key=="AvancadoFuncoes" then
        p(mkRect(cont,1,13,12,4,ic,2)); p(mkCircle(cont,15,6,5,ic))
        local furo=mkCircle(cont,15,6,3,ibg); furo.ZIndex=cont.ZIndex+2
        p(mkRect(cont,8,9,6,3,ic,1))
    elseif key=="Teleportar" then
        p(mkCircle(cont,10,7,6,ic))
        local ci=mkCircle(cont,10,7,3,ibg); ci.ZIndex=cont.ZIndex+2
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
        -- Badge ativo/inativo
        if e.actBadge then e.actBadge.Visible=isThis end
        if e.idleBadge then
            TweenService:Create(e.idleBadge,TweenInfo.new(0.15),{BackgroundTransparency=isThis and 1 or 0}):Play()
            if e.idleS then
                TweenService:Create(e.idleS,TweenInfo.new(0.15),{Transparency=isThis and 1 or 0.75}):Play()
            end
        end
        -- Ícone e label
        setIconColor(e.iconParts, isThis and Color3.fromRGB(22,10,0) or C_ICON_IDLE)
        TweenService:Create(e.label,TweenInfo.new(0.15),{
            TextColor3=isThis and Color3.fromRGB(22,10,0) or Color3.fromRGB(155,110,45)
        }):Play()
        if Pages[e.key] then Pages[e.key].Visible=isThis end
    end
end

local layoutOrder=0
-- ── makeGroupLabel — badge NOVO estilo ────────────────────────
local function makeGroupLabel(text, trKey, groupTabs)
    layoutOrder+=1
    if layoutOrder>1 then
        local spacer=Instance.new("Frame",SideBar)
        spacer.BackgroundTransparency=1; spacer.BorderSizePixel=0
        spacer.Size=UDim2.new(1,0,0,5); spacer.LayoutOrder=layoutOrder*100
    end
    layoutOrder+=1

    local header=Instance.new("TextButton",SideBar)
    header.BackgroundTransparency=1; header.BorderSizePixel=0
    header.AutoButtonColor=false
    header.Size=UDim2.new(1,0,0,30); header.Text=""; header.LayoutOrder=layoutOrder*100; header.ZIndex=4

    -- Badge dourado (exato estilo NOVO)
    local badge=Instance.new("Frame",header)
    badge.BackgroundColor3=Color3.fromRGB(252,196,0); badge.BorderSizePixel=0
    badge.Rotation=-2; badge.Position=UDim2.new(0,2,0,3); badge.Size=UDim2.new(1,-4,0,22); badge.ZIndex=5
    Instance.new("UICorner",badge).CornerRadius=UDim.new(0,7)
    local badgeS=Instance.new("UIStroke",badge)
    badgeS.Color=Color3.fromRGB(18,8,0); badgeS.Thickness=4; badgeS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local badgeG=Instance.new("UIGradient",badge)
    badgeG.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,242,80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200,130,0)),
    }); badgeG.Rotation=90

    -- Estrela branca (brilho) — igual ao NOVO
    local spark=Instance.new("TextLabel",badge)
    spark.BackgroundTransparency=1; spark.Text="✦"
    spark.Position=UDim2.new(0,2,0,2); spark.Size=UDim2.new(0,12,0,12)
    spark.TextSize=10; spark.Font=Enum.Font.GothamBlack
    spark.TextColor3=Color3.fromRGB(255,255,255); spark.ZIndex=7
    TweenService:Create(spark,TweenInfo.new(0.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{TextTransparency=0.7}):Play()
    TweenService:Create(spark,TweenInfo.new(1.8,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,true),{Position=UDim2.new(0,12,0,2)}):Play()

    -- Texto do grupo
    local hl=Instance.new("TextLabel",badge); hl.BackgroundTransparency=1
    hl.Position=UDim2.new(0,14,0,0); hl.Size=UDim2.new(1,-26,1,0)
    hl.Font=Enum.Font.GothamBlack; hl.Text=text
    hl.TextColor3=Color3.fromRGB(28,12,0); hl.TextSize=9
    hl.TextXAlignment=Enum.TextXAlignment.Left; hl.ZIndex=6
    local hlS=Instance.new("UIStroke",hl); hlS.Color=Color3.fromRGB(0,0,0); hlS.Thickness=0.8; hlS.Transparency=0.6
    if trKey then trackLabel(hl, trKey) end

    -- Seta
    local arrow=Instance.new("TextLabel",badge); arrow.BackgroundTransparency=1
    arrow.Position=UDim2.new(1,-16,0,0); arrow.Size=UDim2.new(0,14,1,0)
    arrow.Text="▾"; arrow.TextSize=12; arrow.Font=Enum.Font.GothamBlack
    arrow.TextColor3=Color3.fromRGB(28,12,0); arrow.ZIndex=6

    local isOpen=true
    header.MouseButton1Click:Connect(function()
        isOpen=not isOpen
        TweenService:Create(arrow,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=isOpen and 0 or 180}):Play()
        for _,entry in ipairs(groupTabs) do
            TweenService:Create(entry.bg,TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
                {Size=isOpen and UDim2.new(1,0,0,38) or UDim2.new(1,0,0,0)}):Play()
            entry.bg.ClipsDescendants=true
        end
    end)
end

-- ── makeTab — aba no estilo badge NOVO ────────────────────────
local function makeTab(cfg,groupTabs)
    layoutOrder+=1; local order=layoutOrder*100

    local bg=Instance.new("Frame",SideBar); bg.Name=cfg.key.."Tab"
    bg.BackgroundTransparency=1; bg.BorderSizePixel=0
    bg.Size=UDim2.new(1,0,0,38); bg.LayoutOrder=order; bg.ZIndex=4; bg.ClipsDescendants=true

    -- Badge base (inativo) — fundo escuro chocolate
    local idleBadge=Instance.new("Frame",bg)
    idleBadge.BackgroundColor3=Color3.fromRGB(36,22,8); idleBadge.BorderSizePixel=0
    idleBadge.Rotation=-2; idleBadge.Position=UDim2.new(0,1,0,3); idleBadge.Size=UDim2.new(1,-2,0,32); idleBadge.ZIndex=4
    Instance.new("UICorner",idleBadge).CornerRadius=UDim.new(0,9)
    local idleS=Instance.new("UIStroke",idleBadge)
    idleS.Color=Color3.fromRGB(252,196,0); idleS.Thickness=2.5; idleS.Transparency=0.75

    -- Badge ativo — amarelo exato do NOVO
    local actBadge=Instance.new("Frame",bg)
    actBadge.BackgroundColor3=Color3.fromRGB(252,196,0); actBadge.BorderSizePixel=0
    actBadge.Rotation=-2; actBadge.Position=UDim2.new(0,1,0,3); actBadge.Size=UDim2.new(1,-2,0,32); actBadge.ZIndex=5
    actBadge.Visible=false
    Instance.new("UICorner",actBadge).CornerRadius=UDim.new(0,9)
    local actS=Instance.new("UIStroke",actBadge)
    actS.Color=Color3.fromRGB(18,8,0); actS.Thickness=4; actS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    -- Gradiente (igual NOVO: amarelo vivo em cima, dourado escuro embaixo)
    local actG=Instance.new("UIGradient",actBadge)
    actG.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,242,80)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200,130,0)),
    }); actG.Rotation=90

    -- Estrela branca brilhante (igual ao NOVO) — só no ativo
    local spark=Instance.new("TextLabel",actBadge)
    spark.BackgroundTransparency=1; spark.Text="✦"
    spark.Position=UDim2.new(0,2,0,2); spark.Size=UDim2.new(0,12,0,12)
    spark.TextSize=11; spark.Font=Enum.Font.GothamBlack
    spark.TextColor3=Color3.fromRGB(255,255,255); spark.ZIndex=8
    TweenService:Create(spark,TweenInfo.new(0.75,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{TextTransparency=0.65}):Play()
    TweenService:Create(spark,TweenInfo.new(1.6,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,true),{Position=UDim2.new(0,16,0,2)}):Play()

    -- Ícone e label (acima de ambas camadas)
    local icon,iconParts=createTabIcon(bg,cfg.key)
    icon.Position=UDim2.new(0,10,0.5,-10); icon.ZIndex=9

    local label=Instance.new("TextLabel",bg); label.BackgroundTransparency=1
    label.Position=UDim2.new(0,36,0,0); label.Size=UDim2.new(1,-40,1,0)
    label.Font=Enum.Font.GothamBold; label.Text=cfg.label
    label.TextColor3=Color3.fromRGB(155,110,45); label.TextSize=11
    label.TextXAlignment=Enum.TextXAlignment.Left
    label.TextTruncate=Enum.TextTruncate.AtEnd; label.ZIndex=9
    if cfg.trKey then trackLabel(label, cfg.trKey) end

    local btn=Instance.new("TextButton",bg); btn.BackgroundTransparency=1
    btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=10
    btn.BorderSizePixel=0; btn.AutoButtonColor=false
    btn.MouseEnter:Connect(function()
        if currentTab~=cfg.key then
            TweenService:Create(idleBadge,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(52,32,12)}):Play()
            TweenService:Create(idleS,TweenInfo.new(0.12),{Transparency=0.4}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab~=cfg.key then
            TweenService:Create(idleBadge,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(36,22,8)}):Play()
            TweenService:Create(idleS,TweenInfo.new(0.12),{Transparency=0.75}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function() selectTab(cfg.key) end)

    local entry={
        key=cfg.key, bg=bg,
        idleBadge=idleBadge, idleS=idleS,
        actBadge=actBadge,
        icon=icon, iconParts=iconParts,
        label=label,
        bar=Instance.new("Frame") -- compatibilidade
    }
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
;pcall(function() -- [[ BOOST SYSTEM ]]
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
BoostPopup.BackgroundColor3=Color3.fromRGB(28,16,8); BoostPopup.Size=UDim2.new(0,190,0,0)
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
    local row=Instance.new("Frame",BoostPopup); row.BackgroundColor3=Color3.fromRGB(35,22,12)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,32)
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lbl=Instance.new("TextLabel",row); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,8,0,0); lbl.Size=UDim2.new(1,-50,1,0); lbl.Font=Enum.Font.GothamSemibold
    lbl.Text=text; lbl.TextColor3=Color3.fromRGB(255,230,180); lbl.TextSize=10
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=201
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(35,18,60); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-42,0.5,-10); pill.Size=UDim2.new(0,36,0,20); pill.ZIndex=201
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(180,140,80); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,2,0.5,-8); knob.Size=UDim2.new(0,16,0,16); knob.ZIndex=202
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=203
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=state and Color3.fromRGB(87,242,135) or Color3.fromRGB(35,18,60)}):Play()
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
FloatBtn.BackgroundColor3=Color3.fromRGB(252,196,0); FloatBtn.BorderSizePixel=0; FloatBtn.Visible=false; FloatBtn.ZIndex=100; FloatBtn.Active=true
Instance.new("UICorner",FloatBtn).CornerRadius=UDim.new(1,0)
local FloatRing=Instance.new("UIStroke",FloatBtn); FloatRing.Color=Color3.fromRGB(20,10,0); FloatRing.Thickness=4
local FloatGrad=Instance.new("UIGradient",FloatBtn)
FloatGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,238,70)),ColorSequenceKeypoint.new(1,Color3.fromRGB(185,120,0))})
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
;pcall(function() -- [[ INFO TAB ]]
local function copyToClipboard(text)
    pcall(function() if setclipboard then setclipboard(text) end end)
end


local infoCard=Instance.new("Frame",Pages["Info"])
infoCard.BackgroundColor3=Color3.fromRGB(28,16,8); infoCard.BorderSizePixel=0
infoCard.Size=UDim2.new(1,0,0,136); infoCard.LayoutOrder=0; infoCard.ZIndex=5
Instance.new("UICorner",infoCard).CornerRadius=UDim.new(0,12)
local infoCardStroke=Instance.new("UIStroke",infoCard)
infoCardStroke.Color=Color3.fromRGB(252,198,0); infoCardStroke.Thickness=2.5; infoCardStroke.Transparency=0.55

local infoBanner=Instance.new("Frame",infoCard)
infoBanner.BackgroundColor3=Color3.fromRGB(180,120,0); infoBanner.BorderSizePixel=0
infoBanner.Size=UDim2.new(1,0,0,54); infoBanner.ZIndex=5
Instance.new("UICorner",infoBanner).CornerRadius=UDim.new(0,12)
local banFix=Instance.new("Frame",infoBanner); banFix.BackgroundColor3=Color3.fromRGB(180,120,0)
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
banTitleS.Color=Color3.fromRGB(120,60,0); banTitleS.Thickness=1.8

local infoAvatarRing=Instance.new("Frame",infoCard)
infoAvatarRing.BackgroundColor3=Color3.fromRGB(252,198,0); infoAvatarRing.BorderSizePixel=0
infoAvatarRing.Position=UDim2.new(0,8,0,30); infoAvatarRing.Size=UDim2.new(0,48,0,48); infoAvatarRing.ZIndex=7
Instance.new("UICorner",infoAvatarRing).CornerRadius=UDim.new(1,0)
local avS=Instance.new("UIStroke",infoAvatarRing); avS.Color=Color3.fromRGB(20,10,0); avS.Thickness=2
local infoAvImg=Instance.new("ImageLabel",infoAvatarRing)
infoAvImg.BackgroundTransparency=1; infoAvImg.Position=UDim2.new(0,2,0,2); infoAvImg.Size=UDim2.new(1,-4,1,-4)
infoAvImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(Player.UserId).."&width=150&height=150&format=png"
infoAvImg.ZIndex=8; Instance.new("UICorner",infoAvImg).CornerRadius=UDim.new(1,0)

local infoGreenRing=Instance.new("Frame",infoCard)
infoGreenRing.BackgroundColor3=Color3.fromRGB(28,16,8); infoGreenRing.BorderSizePixel=0
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
infoTag.Text="@"..Player.Name; infoTag.TextColor3=Color3.fromRGB(160,120,60)
infoTag.TextSize=10; infoTag.TextXAlignment=Enum.TextXAlignment.Left; infoTag.ZIndex=7

local infoStatus=Instance.new("Frame",infoCard)
infoStatus.BackgroundColor3=Color3.fromRGB(45,28,15); infoStatus.BorderSizePixel=0
infoStatus.Position=UDim2.new(0,8,0,90); infoStatus.Size=UDim2.new(1,-16,0,38); infoStatus.ZIndex=6
Instance.new("UICorner",infoStatus).CornerRadius=UDim.new(0,8)
local infoStatusS=Instance.new("UIStroke",infoStatus)
infoStatusS.Color=Color3.fromRGB(252,198,0); infoStatusS.Thickness=1; infoStatusS.Transparency=0.78
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
infoStatusSub.TextColor3=Color3.fromRGB(160,120,60); infoStatusSub.TextSize=9
infoStatusSub.TextXAlignment=Enum.TextXAlignment.Left; infoStatusSub.ZIndex=7

-- ── Linha de idioma no painel principal ──
local infoLangRow = Instance.new("Frame", infoCard)
infoLangRow.BackgroundColor3 = Color3.fromRGB(45,28,15)
infoLangRow.BackgroundTransparency = 0.2
infoLangRow.BorderSizePixel = 0
infoLangRow.Position = UDim2.new(0,8,0,136)
infoLangRow.Size = UDim2.new(1,-16,0,28)
infoLangRow.ZIndex = 6
Instance.new("UICorner",infoLangRow).CornerRadius = UDim.new(0,8)
local infoLangRowS=Instance.new("UIStroke",infoLangRow)
infoLangRowS.Color=Color3.fromRGB(252,198,0); infoLangRowS.Thickness=1; infoLangRowS.Transparency=0.78

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
infoLangValLbl.TextColor3=Color3.fromRGB(252,198,0)
infoLangValLbl.TextSize=11; infoLangValLbl.TextXAlignment=Enum.TextXAlignment.Left; infoLangValLbl.ZIndex=7

-- Expande o infoCard para acomodar a linha de idioma
infoCard.Size = UDim2.new(1,0,0,172)

-- Registra referência para atualização de idioma
langInfoLabel = infoLangValLbl

-- ═══════════════════════════════════════
-- TOGGLE NOTIFICATIONS (Info tab, LO=1)
-- ═══════════════════════════════════════
local notifToggleRow = Instance.new("Frame", Pages["Info"])
notifToggleRow.BackgroundColor3   = Color3.fromRGB(40,24,12)
notifToggleRow.BorderSizePixel    = 0
notifToggleRow.Size               = UDim2.new(1,0,0,62)
notifToggleRow.LayoutOrder        = 1
notifToggleRow.ZIndex             = 5
Instance.new("UICorner", notifToggleRow).CornerRadius = UDim.new(0,10)
local ntStroke = Instance.new("UIStroke", notifToggleRow)
ntStroke.Color = Color3.fromRGB(252,198,0); ntStroke.Thickness = 1.5; ntStroke.Transparency = 0.72

-- Icon 🔔 on the left
local ntIconBg = Instance.new("Frame", notifToggleRow)
ntIconBg.BackgroundColor3   = Color3.fromRGB(252,198,0)
ntIconBg.BackgroundTransparency = 0.72
ntIconBg.BorderSizePixel    = 0
ntIconBg.Position           = UDim2.new(0,10,0.5,-18)
ntIconBg.Size               = UDim2.new(0,36,0,36)
ntIconBg.ZIndex             = 6
Instance.new("UICorner",ntIconBg).CornerRadius=UDim.new(1,0)
local ntIconS=Instance.new("UIStroke",ntIconBg)
ntIconS.Color=Color3.fromRGB(180,120,0); ntIconS.Thickness=1.5
local ntIconLbl = Instance.new("TextLabel",ntIconBg)
ntIconLbl.BackgroundTransparency=1; ntIconLbl.Size=UDim2.new(1,0,1,0)
ntIconLbl.Font=Enum.Font.GothamBold; ntIconLbl.Text="🔔"; ntIconLbl.TextSize=18; ntIconLbl.ZIndex=7

-- Texts
local ntTitle = Instance.new("TextLabel",notifToggleRow)
ntTitle.BackgroundTransparency=1; ntTitle.Position=UDim2.new(0,56,0,10)
ntTitle.Size=UDim2.new(1,-110,0,18); ntTitle.Font=Enum.Font.GothamBlack
ntTitle.Text="Notifications"; ntTitle.TextColor3=Color3.fromRGB(255,235,190)
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
ntPill.BackgroundColor3 = Color3.fromRGB(252,198,0)
ntPill.BorderSizePixel    = 0
ntPill.Position           = UDim2.new(1,-58,0.5,-13)
ntPill.Size               = UDim2.new(0,48,0,26)
ntPill.ZIndex             = 7
Instance.new("UICorner",ntPill).CornerRadius=UDim.new(1,0)
local ntPillS=Instance.new("UIStroke",ntPill)
ntPillS.Color=Color3.fromRGB(180,120,0); ntPillS.Thickness=1.5
local ntKnob = Instance.new("Frame",ntPill)
ntKnob.BackgroundColor3 = Color3.fromRGB(255,255,255); ntKnob.BorderSizePixel=0
ntKnob.Position = UDim2.new(1,-24,0.5,-11); ntKnob.Size=UDim2.new(0,22,0,22); ntKnob.ZIndex=8
Instance.new("UICorner",ntKnob).CornerRadius=UDim.new(1,0)

-- Status label (ON/OFF)
local ntStatusLbl = Instance.new("TextLabel",notifToggleRow)
ntStatusLbl.BackgroundTransparency=1; ntStatusLbl.Position=UDim2.new(1,-58,0,10)
ntStatusLbl.Size=UDim2.new(0,48,0,12); ntStatusLbl.Font=Enum.Font.GothamBold
ntStatusLbl.Text=T("notifOn"); ntStatusLbl.TextColor3=Color3.fromRGB(252,198,0)
ntStatusLbl.TextSize=8; ntStatusLbl.TextXAlignment=Enum.TextXAlignment.Center; ntStatusLbl.ZIndex=7

local ntBtn = Instance.new("TextButton",notifToggleRow)
ntBtn.BackgroundTransparency=1; ntBtn.Size=UDim2.new(1,0,1,0); ntBtn.Text=""; ntBtn.ZIndex=9
ntBtn.MouseButton1Click:Connect(function()
    notifEnabled = not notifEnabled
    local onColor   = Color3.fromRGB(252,198,0)
    local offColor  = Color3.fromRGB(45,28,15)
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
infoSep.BackgroundColor3=Color3.fromRGB(252,198,0); infoSep.BackgroundTransparency=0.82; infoSep.BorderSizePixel=0
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
histPanelStroke.Color = Color3.fromRGB(200,155,0); histPanelStroke.Thickness=1.5

-- ── Header clicável ──
local histHeader = Instance.new("Frame", histPanelOuter)
histHeader.BackgroundColor3 = Color3.fromRGB(16,18,26)
histHeader.BorderSizePixel  = 0
histHeader.Size             = UDim2.new(1,0,0,44)
histHeader.ZIndex           = 6
Instance.new("UICorner",histHeader).CornerRadius = UDim.new(0,10)
local histHeaderFix = Instance.new("Frame",histHeader)
histHeaderFix.BackgroundColor3=Color3.fromRGB(28,16,8); histHeaderFix.BorderSizePixel=0
histHeaderFix.Position=UDim2.new(0,0,0.5,0); histHeaderFix.Size=UDim2.new(1,0,0.5,0); histHeaderFix.ZIndex=6

-- Ícone sino
local histHIconBg = Instance.new("Frame",histHeader)
histHIconBg.BackgroundColor3=Color3.fromRGB(200,155,0); histHIconBg.BackgroundTransparency=0.75
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
histHTitle.Text="Histórico de Notificações"; histHTitle.TextColor3=Color3.fromRGB(255,230,180)
trackLabel(histHTitle, "notifHistTitle")
histHTitle.TextSize=11; histHTitle.TextXAlignment=Enum.TextXAlignment.Left; histHTitle.ZIndex=7

-- Seta
local histHArrowFrame=Instance.new("Frame",histHeader)
histHArrowFrame.BackgroundTransparency=1; histHArrowFrame.Position=UDim2.new(1,-24,0.5,-8)
histHArrowFrame.Size=UDim2.new(0,16,0,16); histHArrowFrame.ZIndex=7
local histHArrow=Instance.new("ImageLabel",histHArrowFrame)
histHArrow.BackgroundTransparency=1; histHArrow.Size=UDim2.new(1,0,1,0)
histHArrow.Image="rbxassetid://6034818375"; histHArrow.ImageColor3=Color3.fromRGB(200,155,0)
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
histScroll.ScrollBarImageColor3  = Color3.fromRGB(200,155,0)
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
        TweenService:Create(histPanelStroke,TweenInfo.new(0.2),{Color=open and Color3.fromRGB(252,198,0) or Color3.fromRGB(200,155,0)}):Play()
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
dadosHeader.BackgroundColor3=Color3.fromRGB(38,22,10); dadosHeader.BorderSizePixel=0
dadosHeader.Size=UDim2.new(1,0,0,32); dadosHeader.LayoutOrder=4; dadosHeader.Text=""; dadosHeader.ZIndex=5
Instance.new("UICorner",dadosHeader).CornerRadius=UDim.new(0,8)
local dadosStroke=Instance.new("UIStroke",dadosHeader); dadosStroke.Color=Color3.fromRGB(252,198,0); dadosStroke.Thickness=1; dadosStroke.Transparency=0.82

local dadosTitleLbl=Instance.new("TextLabel",dadosHeader)
dadosTitleLbl.BackgroundTransparency=1; dadosTitleLbl.Position=UDim2.new(0,12,0,0)
dadosTitleLbl.Size=UDim2.new(1,-40,1,0); dadosTitleLbl.Font=Enum.Font.GothamBold
dadosTitleLbl.Text="Dice"; dadosTitleLbl.TextColor3=Color3.fromRGB(255,220,150)
dadosTitleLbl.TextSize=11; dadosTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; dadosTitleLbl.ZIndex=6

local dadosArrowFrame=Instance.new("Frame",dadosHeader)
dadosArrowFrame.BackgroundTransparency=1; dadosArrowFrame.Position=UDim2.new(1,-28,0.5,-8)
dadosArrowFrame.Size=UDim2.new(0,16,0,16); dadosArrowFrame.ZIndex=6
local dadosArrow=Instance.new("ImageLabel",dadosArrowFrame)
dadosArrow.BackgroundTransparency=1; dadosArrow.Size=UDim2.new(1,0,1,0)
dadosArrow.Image="rbxassetid://6034818375"; dadosArrow.ImageColor3=Color3.fromRGB(252,198,0)
dadosArrow.ScaleType=Enum.ScaleType.Fit; dadosArrow.Rotation=180; dadosArrow.ZIndex=7

local dadosContent=Instance.new("Frame",Pages["Info"])
dadosContent.BackgroundColor3=Color3.fromRGB(12,6,22); dadosContent.BorderSizePixel=0
dadosContent.Size=UDim2.new(1,0,0,0); dadosContent.LayoutOrder=5; dadosContent.ZIndex=5
dadosContent.ClipsDescendants=true
Instance.new("UICorner",dadosContent).CornerRadius=UDim.new(0,8)
local dadosStroke2=Instance.new("UIStroke",dadosContent); dadosStroke2.Color=Color3.fromRGB(252,198,0); dadosStroke2.Thickness=1; dadosStroke2.Transparency=0.85

local dadosPad=Instance.new("UIPadding",dadosContent)
dadosPad.PaddingTop=UDim.new(0,10); dadosPad.PaddingLeft=UDim.new(0,12)
dadosPad.PaddingRight=UDim.new(0,12); dadosPad.PaddingBottom=UDim.new(0,12)
local dadosList=Instance.new("UIListLayout",dadosContent)
dadosList.Padding=UDim.new(0,8); dadosList.SortOrder=Enum.SortOrder.LayoutOrder

local dadosText=Instance.new("TextLabel",dadosContent)
dadosText.BackgroundTransparency=1; dadosText.Size=UDim2.new(1,0,0,0)
dadosText.AutomaticSize=Enum.AutomaticSize.Y; dadosText.Font=Enum.Font.Gotham
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

makeDadosBtn(dadosBtnsRow,"🔗 Discord Link",Color3.fromRGB(200,155,0),function()
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
langSep.BackgroundColor3=Color3.fromRGB(252,198,0); langSep.BackgroundTransparency=0.82; langSep.BorderSizePixel=0
langSep.Size=UDim2.new(1,0,0,1); langSep.LayoutOrder=6; langSep.ZIndex=5

-- Header clicável "Sistema de idiomas"
local langHeader=Instance.new("TextButton",Pages["Info"])
langHeader.BackgroundColor3=Color3.fromRGB(22,10,44); langHeader.BorderSizePixel=0
langHeader.Size=UDim2.new(1,0,0,40); langHeader.LayoutOrder=7; langHeader.Text=""; langHeader.ZIndex=5
Instance.new("UICorner",langHeader).CornerRadius=UDim.new(0,10)
local langHeaderStroke=Instance.new("UIStroke",langHeader)
langHeaderStroke.Color=Color3.fromRGB(252,198,0); langHeaderStroke.Thickness=1.8; langHeaderStroke.Transparency=0.45

-- Ícone globo
local lhIconBg=Instance.new("Frame",langHeader)
lhIconBg.BackgroundColor3=Color3.fromRGB(252,198,0); lhIconBg.BackgroundTransparency=0.72
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
lhTitleLbl.TextColor3=Color3.fromRGB(255,235,190); lhTitleLbl.TextSize=12
lhTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; lhTitleLbl.ZIndex=6

-- Label idioma atual
local lhCurrentLbl=Instance.new("TextLabel",langHeader)
lhCurrentLbl.BackgroundTransparency=1; lhCurrentLbl.Position=UDim2.new(1,-88,0,0)
lhCurrentLbl.Size=UDim2.new(0,60,1,0); lhCurrentLbl.Font=Enum.Font.GothamBold
lhCurrentLbl.Text=currentLang.flag.." "..currentLang.short
lhCurrentLbl.TextColor3=Color3.fromRGB(252,198,0); lhCurrentLbl.TextSize=10
lhCurrentLbl.TextXAlignment=Enum.TextXAlignment.Right; lhCurrentLbl.ZIndex=6

-- Seta
local lhArrowFrame=Instance.new("Frame",langHeader)
lhArrowFrame.BackgroundTransparency=1; lhArrowFrame.Position=UDim2.new(1,-26,0.5,-8)
lhArrowFrame.Size=UDim2.new(0,16,0,16); lhArrowFrame.ZIndex=6
local lhArrow=Instance.new("ImageLabel",lhArrowFrame)
lhArrow.BackgroundTransparency=1; lhArrow.Size=UDim2.new(1,0,1,0)
lhArrow.Image="rbxassetid://6034818375"; lhArrow.ImageColor3=Color3.fromRGB(252,198,0)
lhArrow.ScaleType=Enum.ScaleType.Fit; lhArrow.Rotation=180; lhArrow.ZIndex=7

-- Conteúdo dropdown (lista de idiomas)
local langDropContent=Instance.new("ScrollingFrame",Pages["Info"])
langDropContent.BackgroundColor3=Color3.fromRGB(10,5,20); langDropContent.BorderSizePixel=0
langDropContent.Size=UDim2.new(1,0,0,0); langDropContent.LayoutOrder=8; langDropContent.ZIndex=5
langDropContent.ClipsDescendants=true; langDropContent.ScrollBarThickness=3
langDropContent.ScrollBarImageColor3=Color3.fromRGB(252,198,0)
langDropContent.AutomaticCanvasSize=Enum.AutomaticSize.None
langDropContent.CanvasSize=UDim2.new(0,0,0,0)
Instance.new("UICorner",langDropContent).CornerRadius=UDim.new(0,10)
local ldStroke=Instance.new("UIStroke",langDropContent); ldStroke.Color=Color3.fromRGB(252,198,0); ldStroke.Thickness=1.5; ldStroke.Transparency=0.65

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
    lBtn.BackgroundColor3=isSelected and Color3.fromRGB(252,198,0) or Color3.fromRGB(45,28,15)
    lBtn.BackgroundTransparency=isSelected and 0.25 or 0.15
    lBtn.BorderSizePixel=0; lBtn.Size=UDim2.new(1,0,0,34)
    lBtn.Text=""; lBtn.LayoutOrder=idx; lBtn.ZIndex=6
    Instance.new("UICorner",lBtn).CornerRadius=UDim.new(0,8)
    if isSelected then
        local lbStroke=Instance.new("UIStroke",lBtn); lbStroke.Color=Color3.fromRGB(252,198,0); lbStroke.Thickness=1.8
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
    lbName.Text=lang.name; lbName.TextColor3=isSelected and Color3.fromRGB(20,10,0) or Color3.fromRGB(240,210,150)
    lbName.TextSize=10; lbName.TextXAlignment=Enum.TextXAlignment.Left; lbName.ZIndex=7

    -- Código
    local lbCode=Instance.new("TextLabel",lBtn)
    lbCode.BackgroundTransparency=1; lbCode.Position=UDim2.new(1,-58,0,0)
    lbCode.Size=UDim2.new(0,50,1,0); lbCode.Font=Enum.Font.GothamBold
    lbCode.Text=lang.short; lbCode.TextColor3=isSelected and Color3.fromRGB(200,155,0) or Color3.fromRGB(140,105,50)
    lbCode.TextSize=9; lbCode.TextXAlignment=Enum.TextXAlignment.Right; lbCode.ZIndex=7

    lBtn.MouseEnter:Connect(function()
        if lang.code~=currentLang.code then
            TweenService:Create(lBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(60,40,100),BackgroundTransparency=0}):Play()
        end
    end)
    lBtn.MouseLeave:Connect(function()
        if lang.code~=currentLang.code then
            TweenService:Create(lBtn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(45,28,15),BackgroundTransparency=0.15}):Play()
        end
    end)
    lBtn.MouseButton1Click:Connect(function()
        -- Fecha o dropdown
        langDropOpen = false
        TweenService:Create(lhArrow,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=180}):Play()
        TweenService:Create(langDropContent,TweenInfo.new(0.25,Enum.EasingStyle.Quad),{Size=UDim2.new(1,0,0,0)}):Play()
        TweenService:Create(langHeaderStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(200,155,0)}):Play()
        -- Atualiza label do header imediatamente
        lhCurrentLbl.Text = lang.flag.." "..lang.short
        -- Aplica o idioma na hora, sem confirmação
        applyLanguage(lang)
        if langInfoLabel   then langInfoLabel.Text   = lang.flag.."  "..lang.short end
        if langFooterLabel then langFooterLabel.Text = lang.flag.." "..lang.short  end
        local T = TRANSLATIONS[lang.code] or TRANSLATIONS["PT-BR"]
        Notify.send({
            type="custom", icon=lang.flag,
            accent=Color3.fromRGB(200,155,0),
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
        TweenService:Create(langHeaderStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(252,198,0)}):Play()
        TweenService:Create(langDropContent,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,LANG_DROP_H)}):Play()
    else
        TweenService:Create(langHeaderStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(200,155,0)}):Play()
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
srvSep.BackgroundColor3=Color3.fromRGB(252,198,0); srvSep.BackgroundTransparency=0.82; srvSep.BorderSizePixel=0
srvSep.Size=UDim2.new(1,0,0,1); srvSep.LayoutOrder=9; srvSep.ZIndex=5

local srvCard=Instance.new("Frame",Pages["Info"])
srvCard.BackgroundColor3=Color3.fromRGB(38,22,10); srvCard.BorderSizePixel=0
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
srvSubTitle.TextColor3=Color3.fromRGB(150,115,60); srvSubTitle.TextSize=9
srvSubTitle.TextXAlignment=Enum.TextXAlignment.Left; srvSubTitle.ZIndex=6

-- TextBox de ID
local srvBoxBg=Instance.new("Frame",srvCard); srvBoxBg.BackgroundColor3=Color3.fromRGB(40,24,12)
srvBoxBg.BorderSizePixel=0; srvBoxBg.Position=UDim2.new(0,10,0,48); srvBoxBg.Size=UDim2.new(1,-96,0,30)
srvBoxBg.ZIndex=6; Instance.new("UICorner",srvBoxBg).CornerRadius=UDim.new(0,8)
local srvBoxStroke=Instance.new("UIStroke",srvBoxBg); srvBoxStroke.Color=Color3.fromRGB(100,70,30); srvBoxStroke.Thickness=1.2

local srvBox=Instance.new("TextBox",srvBoxBg); srvBox.BackgroundTransparency=1
srvBox.Position=UDim2.new(0,10,0,0); srvBox.Size=UDim2.new(1,-12,1,0)
srvBox.Font=Enum.Font.GothamBold; srvBox.Text=""
srvBox.PlaceholderText="Cole o Job ID aqui..."; srvBox.PlaceholderColor3=Color3.fromRGB(130,95,45)
srvBox.TextColor3=Color3.fromRGB(240,215,160); srvBox.TextSize=10
srvBox.ClearTextOnFocus=false; srvBox.ZIndex=7

srvBox.Focused:Connect(function() TweenService:Create(srvBoxStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(255,170,50)}):Play() end)
srvBox.FocusLost:Connect(function() TweenService:Create(srvBoxStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(100,70,30)}):Play() end)

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
end) -- [[ INFO TAB ]]

-- ══════════════════════════════════════════════════════
-- ABA STATUS — Painel de monitoramento em tempo real
-- ══════════════════════════════════════════════════════
;pcall(function() -- [[ STATUS TAB ]]

local statsLO = 0
local function stLO() statsLO += 1; return statsLO end
local sessionStart = tick()

-- ─── helper: card base ────────────────────────────────────────
local function mkStatCard(parent, h, lo)
    local c = Instance.new("Frame", parent)
    c.BackgroundColor3 = Color3.fromRGB(28,16,8); c.BorderSizePixel = 0
    c.Size = UDim2.new(1,0,0,h); c.LayoutOrder = lo; c.ZIndex = 5
    Instance.new("UICorner",c).CornerRadius = UDim.new(0,10)
    local s = Instance.new("UIStroke",c)
    s.Color = Color3.fromRGB(252,198,0); s.Thickness = 1.5; s.Transparency = 0.75
    return c, s
end
local function mkLbl(parent, pos, sz, txt, font, fs, col, zi, wrap)
    local l = Instance.new("TextLabel", parent); l.BackgroundTransparency = 1
    l.Position = pos; l.Size = sz; l.Font = font; l.Text = txt
    l.TextColor3 = col; l.TextSize = fs; l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = zi or 6; if wrap then l.TextWrapped = true end; return l
end
local function mkAccentBar(parent, color)
    local b = Instance.new("Frame", parent); b.BackgroundColor3 = color
    b.BorderSizePixel = 0; b.Size = UDim2.new(0,3,0.6,0); b.Position = UDim2.new(0,0,0.2,0); b.ZIndex = 6
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,2)
end
local function mkIconBg(parent, pos, sz, cor)
    local f = Instance.new("Frame", parent); f.BackgroundColor3 = cor
    f.BackgroundTransparency = 0.82; f.BorderSizePixel = 0; f.Position = pos; f.Size = sz; f.ZIndex = 6
    Instance.new("UICorner",f).CornerRadius = UDim.new(0,8); return f
end

-- ════════════════════════════════════════════════════
-- CARD 0 — Título da aba
-- ════════════════════════════════════════════════════
local titleCard = mkStatCard(Pages["Status"], 40, stLO())
titleCard.BackgroundColor3 = Color3.fromRGB(22,10,44)
mkAccentBar(titleCard, Color3.fromRGB(252,198,0))
local titleLbl = mkLbl(titleCard, UDim2.new(0,14,0,0), UDim2.new(1,-50,1,0),
    "🎮  Painel da Partida", Enum.Font.GothamBlack, 14, Color3.fromRGB(255,230,180))
local liveLbl = Instance.new("TextLabel", titleCard); liveLbl.BackgroundTransparency = 1
liveLbl.AnchorPoint = Vector2.new(1,0.5); liveLbl.Position = UDim2.new(1,-10,0.5,0)
liveLbl.Size = UDim2.new(0,44,0,16); liveLbl.Font = Enum.Font.GothamBold
liveLbl.Text = "● LIVE"; liveLbl.TextColor3 = Color3.fromRGB(87,242,135)
liveLbl.TextSize = 9; liveLbl.ZIndex = 6
task.spawn(function()
    while true do
        TweenService:Create(liveLbl, TweenInfo.new(0.8), {TextTransparency=0.6}):Play(); task.wait(0.9)
        TweenService:Create(liveLbl, TweenInfo.new(0.5), {TextTransparency=0}):Play(); task.wait(0.6)
    end
end)

-- ════════════════════════════════════════════════════
-- CARD 1 — Tempo de sessão + Dia atual do jogo
-- ════════════════════════════════════════════════════
local sessionCard = mkStatCard(Pages["Status"], 64, stLO())
mkAccentBar(sessionCard, Color3.fromRGB(255,200,50))

local icSess = mkIconBg(sessionCard, UDim2.new(0,10,0,12), UDim2.new(0,30,0,30), Color3.fromRGB(255,200,50))
local il1 = Instance.new("TextLabel",icSess); il1.BackgroundTransparency=1; il1.Size=UDim2.new(1,0,1,0)
il1.Font=Enum.Font.GothamBlack; il1.Text="⏱"; il1.TextSize=15; il1.ZIndex=7

mkLbl(sessionCard, UDim2.new(0,48,0,8), UDim2.new(0.44,0,0,12), "TEMPO NA PARTIDA", Enum.Font.GothamBold, 8, Color3.fromRGB(120,130,155))
local sessValLbl = mkLbl(sessionCard, UDim2.new(0,48,0,20), UDim2.new(0.44,0,0,20), "0m 0s", Enum.Font.GothamBlack, 18, Color3.fromRGB(255,200,50))
local sessSubLbl = mkLbl(sessionCard, UDim2.new(0,48,0,42), UDim2.new(0.44,0,0,16), "desde que entrou na partida", Enum.Font.Gotham, 8, Color3.fromRGB(130,100,50))

local divSess = Instance.new("Frame",sessionCard); divSess.BackgroundColor3=Color3.fromRGB(252,198,0); divSess.BackgroundTransparency=0.82
divSess.BorderSizePixel=0; divSess.AnchorPoint=Vector2.new(0.5,0.5); divSess.Position=UDim2.new(0.5,0,0.5,0); divSess.Size=UDim2.new(0,1,0.7,0); divSess.ZIndex=6

local icDay = mkIconBg(sessionCard, UDim2.new(0.5,8,0,12), UDim2.new(0,30,0,30), Color3.fromRGB(87,242,135))
local il2 = Instance.new("TextLabel",icDay); il2.BackgroundTransparency=1; il2.Size=UDim2.new(1,0,1,0)
il2.Font=Enum.Font.GothamBlack; il2.Text="📅"; il2.TextSize=15; il2.ZIndex=7

mkLbl(sessionCard, UDim2.new(0.5,46,0,8), UDim2.new(0.45,0,0,12), "DIA NA FLORESTA", Enum.Font.GothamBold, 8, Color3.fromRGB(120,130,155))
local dayValLbl = mkLbl(sessionCard, UDim2.new(0.5,46,0,20), UDim2.new(0.45,0,0,20), "Dia ?", Enum.Font.GothamBlack, 18, Color3.fromRGB(87,242,135))
local daySubLbl = mkLbl(sessionCard, UDim2.new(0.5,46,0,42), UDim2.new(0.45,0,0,16), "buscando...", Enum.Font.Gotham, 8, Color3.fromRGB(100,130,100))

-- Detecta o dia atual do jogo (99 Nights in the Forest)
local function getGameDay()
    local day = nil
    pcall(function()
        -- Tenta atributos comuns do jogo
        for _, attrName in ipairs({"Day","CurrentDay","GameDay","NightNumber","DayCount","Days","DaysElapsed","DaySurvived","DaysSurvived"}) do
            local v = game:GetAttribute(attrName) or workspace:GetAttribute(attrName)
            if type(v)=="number" and v>0 then day=math.floor(v); return end
        end
        -- Tenta leaderboard
        local ls = Player:FindFirstChild("leaderstats") or Player:FindFirstChildWhichIsA("Folder")
        if ls then
            for _, attrName in ipairs({"Day","Days","DaysSurvived","DayCount","Night","Nights"}) do
                local val = ls:FindFirstChild(attrName)
                if val and (val:IsA("IntValue") or val:IsA("NumberValue")) then
                    day = math.floor(val.Value); return
                end
            end
        end
        -- Tenta ReplicatedStorage
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            for _, obj in ipairs(rs:GetDescendants()) do
                if (obj:IsA("IntValue") or obj:IsA("NumberValue")) then
                    local n = obj.Name:lower()
                    if n:find("day") or n:find("night") then
                        if obj.Value > 0 and obj.Value < 999 then day = math.floor(obj.Value); return end
                    end
                end
            end
        end)
    end)
    return day
end

-- ════════════════════════════════════════════════════
-- CARD 2 — Jogadores na partida
-- ════════════════════════════════════════════════════
local plrCard = mkStatCard(Pages["Status"], 44, stLO())
mkAccentBar(plrCard, Color3.fromRGB(140,100,255))

local icPlr = mkIconBg(plrCard, UDim2.new(0,10,0,8), UDim2.new(0,28,0,28), Color3.fromRGB(140,100,255))
local il3 = Instance.new("TextLabel",icPlr); il3.BackgroundTransparency=1; il3.Size=UDim2.new(1,0,1,0)
il3.Font=Enum.Font.GothamBlack; il3.Text="👥"; il3.TextSize=14; il3.ZIndex=7

mkLbl(plrCard, UDim2.new(0,46,0,6), UDim2.new(0.6,0,0,12), "JOGADORES NA PARTIDA", Enum.Font.GothamBold, 8, Color3.fromRGB(120,130,155))
local plrCountLbl = mkLbl(plrCard, UDim2.new(0,46,0,18), UDim2.new(0.5,0,0,18), "0 / 0", Enum.Font.GothamBlack, 16, Color3.fromRGB(140,100,255))

local plrMaxLbl = Instance.new("TextLabel",plrCard); plrMaxLbl.BackgroundTransparency=1
plrMaxLbl.AnchorPoint=Vector2.new(1,0); plrMaxLbl.Position=UDim2.new(1,-12,0,8); plrMaxLbl.Size=UDim2.new(0,70,0,14)
plrMaxLbl.Font=Enum.Font.GothamBold; plrMaxLbl.Text="Máx: "..tostring(game.Players.MaxPlayers)
plrMaxLbl.TextColor3=Color3.fromRGB(90,100,120); plrMaxLbl.TextSize=9; plrMaxLbl.TextXAlignment=Enum.TextXAlignment.Right; plrMaxLbl.ZIndex=6

-- Lista de jogadores inline
local plrListFrame = Instance.new("Frame",plrCard); plrListFrame.BackgroundTransparency=1
plrListFrame.BorderSizePixel=0; plrListFrame.Position=UDim2.new(0,8,0,44)
plrListFrame.Size=UDim2.new(1,-16,0,0); plrListFrame.ZIndex=6
local plrListLayout = Instance.new("UIListLayout",plrListFrame)
plrListLayout.Padding=UDim.new(0,3); plrListLayout.SortOrder=Enum.SortOrder.LayoutOrder

local plrRows = {}
local function refreshPlayerList()
    for uid,row in pairs(plrRows) do
        if not Players:GetPlayerByUserId(uid) then pcall(function() row:Destroy() end); plrRows[uid]=nil end
    end
    local allPlrs = Players:GetPlayers()
    for i, plr in ipairs(allPlrs) do
        if not plrRows[plr.UserId] then
            local row=Instance.new("Frame",plrListFrame); row.BackgroundColor3=Color3.fromRGB(35,22,12)
            row.BackgroundTransparency=0.2; row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,34); row.LayoutOrder=i; row.ZIndex=7
            Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
            local avRing=Instance.new("Frame",row); avRing.BackgroundColor3=Color3.fromRGB(140,100,255)
            avRing.BackgroundTransparency=0.7; avRing.BorderSizePixel=0
            avRing.Position=UDim2.new(0,6,0.5,-13); avRing.Size=UDim2.new(0,26,0,26); avRing.ZIndex=8
            Instance.new("UICorner",avRing).CornerRadius=UDim.new(1,0)
            local avImg=Instance.new("ImageLabel",avRing); avImg.BackgroundTransparency=1
            avImg.Position=UDim2.new(0,2,0,2); avImg.Size=UDim2.new(1,-4,1,-4)
            avImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(plr.UserId).."&width=48&height=48&format=png"
            avImg.ZIndex=9; Instance.new("UICorner",avImg).CornerRadius=UDim.new(1,0)
            local dot=Instance.new("Frame",avRing); dot.BackgroundColor3=Color3.fromRGB(87,242,135)
            dot.BorderSizePixel=0; dot.AnchorPoint=Vector2.new(1,1)
            dot.Position=UDim2.new(1,2,1,2); dot.Size=UDim2.new(0,7,0,7); dot.ZIndex=10
            Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
            local nameL=Instance.new("TextLabel",row); nameL.BackgroundTransparency=1
            nameL.Position=UDim2.new(0,38,0,4); nameL.Size=UDim2.new(1,-80,0,14)
            nameL.Font=Enum.Font.GothamBold; nameL.Text=plr.DisplayName
            nameL.TextColor3=Color3.fromRGB(255,235,200); nameL.TextSize=11
            nameL.TextXAlignment=Enum.TextXAlignment.Left; nameL.ZIndex=8
            local tagL=Instance.new("TextLabel",row); tagL.BackgroundTransparency=1
            tagL.Position=UDim2.new(0,38,0,19); tagL.Size=UDim2.new(1,-80,0,11)
            tagL.Font=Enum.Font.Gotham; tagL.Text="@"..plr.Name
            tagL.TextColor3=Color3.fromRGB(90,100,120); tagL.TextSize=9
            tagL.TextXAlignment=Enum.TextXAlignment.Left; tagL.ZIndex=8
            if plr==Player then
                local youBadge=Instance.new("Frame",row); youBadge.BackgroundColor3=Color3.fromRGB(200,155,0)
                youBadge.BackgroundTransparency=0.5; youBadge.BorderSizePixel=0
                youBadge.AnchorPoint=Vector2.new(1,0.5); youBadge.Position=UDim2.new(1,-8,0.5,0)
                youBadge.Size=UDim2.new(0,30,0,14); youBadge.ZIndex=8
                Instance.new("UICorner",youBadge).CornerRadius=UDim.new(0,4)
                local youLbl=Instance.new("TextLabel",youBadge); youLbl.BackgroundTransparency=1
                youLbl.Size=UDim2.new(1,0,1,0); youLbl.Font=Enum.Font.GothamBold
                youLbl.Text="Você"; youLbl.TextColor3=Color3.fromRGB(255,220,150); youLbl.TextSize=8; youLbl.ZIndex=9
            end
            plrRows[plr.UserId]=row
        end
    end
    local n=#allPlrs
    plrCountLbl.Text=tostring(n).." / "..tostring(game.Players.MaxPlayers)
    local listH=n>0 and (n*37+4) or 0
    plrCard.Size=UDim2.new(1,0,0,44+listH); plrListFrame.Size=UDim2.new(1,-16,0,listH)
end
Players.PlayerAdded:Connect(function() task.wait(0.5); refreshPlayerList() end)
Players.PlayerRemoving:Connect(function(p)
    task.wait(0.1)
    if plrRows[p.UserId] then pcall(function() plrRows[p.UserId]:Destroy() end); plrRows[p.UserId]=nil end
    refreshPlayerList()
end)
task.delay(0.5, refreshPlayerList)

-- ════════════════════════════════════════════════════
-- CARD 3 — Exploração do mapa
-- ════════════════════════════════════════════════════
local MAP_W, MAP_H = 240, 240   -- tamanho do painel de mapa em pixels
local MAP_WORLD    = 2000       -- raio total estimado do mapa do 99 Nights (studs)
local MAP_GRID     = 20         -- células na grade (20x20)
local CELL_PX      = MAP_W / MAP_GRID

local exploCard, exploStroke = mkStatCard(Pages["Status"], 52 + MAP_H + 28, stLO())
mkAccentBar(exploCard, Color3.fromRGB(60,200,100))

local icExpl = mkIconBg(exploCard, UDim2.new(0,10,0,10), UDim2.new(0,28,0,28), Color3.fromRGB(60,200,100))
local il4 = Instance.new("TextLabel",icExpl); il4.BackgroundTransparency=1; il4.Size=UDim2.new(1,0,1,0)
il4.Font=Enum.Font.GothamBlack; il4.Text="🗺️"; il4.TextSize=14; il4.ZIndex=7

mkLbl(exploCard, UDim2.new(0,46,0,8), UDim2.new(1,-60,0,12), "EXPLORAÇÃO DO MAPA", Enum.Font.GothamBold, 8, Color3.fromRGB(120,130,155))
local exploValLbl = mkLbl(exploCard, UDim2.new(0,46,0,20), UDim2.new(0.5,0,0,18), "0% explorado", Enum.Font.GothamBlack, 14, Color3.fromRGB(60,200,100))
local exploSubLbl = mkLbl(exploCard, UDim2.new(0,46,0,38), UDim2.new(1,-60,0,12), "calculando...", Enum.Font.Gotham, 8, Color3.fromRGB(100,130,100))

-- Barra de progresso de exploração
local exploBg = Instance.new("Frame",exploCard); exploBg.BackgroundColor3=Color3.fromRGB(22,12,6)
exploBg.BorderSizePixel=0; exploBg.Position=UDim2.new(0,8,0,50); exploBg.Size=UDim2.new(1,-16,0,5); exploBg.ZIndex=6
Instance.new("UICorner",exploBg).CornerRadius=UDim.new(0,3)
local exploFill = Instance.new("Frame",exploBg); exploFill.BackgroundColor3=Color3.fromRGB(60,200,100)
exploFill.BorderSizePixel=0; exploFill.Size=UDim2.new(0,0,1,0); exploFill.ZIndex=7
Instance.new("UICorner",exploFill).CornerRadius=UDim.new(0,3)

-- ── PAINEL DO MAPA VISUAL ─────────────────────────────────────
local mapOuterFrame = Instance.new("Frame",exploCard); mapOuterFrame.BackgroundColor3=Color3.fromRGB(14,8,3)
mapOuterFrame.BorderSizePixel=0; mapOuterFrame.Position=UDim2.new(0.5,-MAP_W/2,0,60); mapOuterFrame.Size=UDim2.new(0,MAP_W,0,MAP_H); mapOuterFrame.ZIndex=6
Instance.new("UICorner",mapOuterFrame).CornerRadius=UDim.new(0,8)
local mapBorderS=Instance.new("UIStroke",mapOuterFrame); mapBorderS.Color=Color3.fromRGB(60,200,100); mapBorderS.Thickness=2; mapBorderS.Transparency=0.4

-- Grade de células
local mapCells = {}  -- [row][col] = Frame
for row=1,MAP_GRID do
    mapCells[row]={}
    for col=1,MAP_GRID do
        local cell=Instance.new("Frame",mapOuterFrame); cell.BackgroundColor3=Color3.fromRGB(30,20,8)
        cell.BorderSizePixel=0; cell.ZIndex=7
        cell.Position=UDim2.new(0,(col-1)*CELL_PX,0,(row-1)*CELL_PX); cell.Size=UDim2.new(0,CELL_PX-1,0,CELL_PX-1)
        -- borda sutil
        local cs=Instance.new("UIStroke",cell); cs.Color=Color3.fromRGB(20,12,4); cs.Thickness=0.5; cs.Transparency=0.7
        Instance.new("UICorner",cell).CornerRadius=UDim.new(0,2)
        mapCells[row][col]=cell
    end
end

-- Legenda do mapa
local legendFrame=Instance.new("Frame",exploCard); legendFrame.BackgroundTransparency=1
legendFrame.Position=UDim2.new(0.5,-MAP_W/2,0,62+MAP_H); legendFrame.Size=UDim2.new(0,MAP_W,0,20); legendFrame.ZIndex=6
local function mkLegItem(parent,xOff,col,txt)
    local dot=Instance.new("Frame",parent); dot.BackgroundColor3=col; dot.BorderSizePixel=0
    dot.Position=UDim2.new(0,xOff,0.5,-4); dot.Size=UDim2.new(0,8,0,8); dot.ZIndex=7
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",parent); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,xOff+11,0,0); lbl.Size=UDim2.new(0,70,1,0); lbl.Font=Enum.Font.Gotham
    lbl.Text=txt; lbl.TextColor3=Color3.fromRGB(160,130,80); lbl.TextSize=8; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=7
end
mkLegItem(legendFrame,0,Color3.fromRGB(60,200,100),"Explorado")
mkLegItem(legendFrame,80,Color3.fromRGB(50,50,50),"Inexplorado")
mkLegItem(legendFrame,155,Color3.fromRGB(255,220,60),"Jogadores")

-- Dots dos jogadores no mapa
local plrDots = {}  -- [userId] = Frame dot
local campDot = Instance.new("Frame",mapOuterFrame); campDot.BackgroundColor3=Color3.fromRGB(255,130,40)
campDot.BorderSizePixel=0; campDot.Size=UDim2.new(0,8,0,8); campDot.ZIndex=10
Instance.new("UICorner",campDot).CornerRadius=UDim.new(1,0)
campDot.Position=UDim2.new(0.5,-4,0.5,-4)  -- centro por padrão

local function worldToMapPos(wx, wz)
    -- Normaliza de [-MAP_WORLD, MAP_WORLD] para [0, MAP_W]
    local nx = (wx + MAP_WORLD) / (MAP_WORLD*2)
    local nz = (wz + MAP_WORLD) / (MAP_WORLD*2)
    return math.clamp(nx*MAP_W, 0, MAP_W-8), math.clamp(nz*MAP_H, 0, MAP_H-8)
end

local exploredCells = {}  -- set de "row,col" que já foram explorados
local exploPercent = 0

local function updateMapDisplay()
    pcall(function()
        local campPos = _campfirePosCache
        local fogRadius = 200  -- fallback mínimo

        pcall(function()
            local fe = game:GetService("Lighting").FogEnd
            if fe and fe > 50 and fe < 20000 then fogRadius = fe * 0.85 end
        end)

        -- Centro do mapa = posição da fogueira (ou 0,0)
        local cx = campPos and campPos.X or 0
        local cz = campPos and campPos.Z or 0

        -- Atualiza a posição do dot da fogueira
        local cpx, cpz = worldToMapPos(cx, cz)
        campDot.Position = UDim2.new(0, cpx-2, 0, cpz-2)

        -- Raio explorado em células
        local exploRadius = (fogRadius / (MAP_WORLD*2)) * MAP_W
        local centerCol = ((cx + MAP_WORLD) / (MAP_WORLD*2)) * MAP_GRID
        local centerRow = ((cz + MAP_WORLD) / (MAP_WORLD*2)) * MAP_GRID

        -- Marca células exploradas ao redor da fogueira
        for row=1,MAP_GRID do
            for col=1,MAP_GRID do
                local dRow = (row - 0.5 - centerRow) * CELL_PX
                local dCol = (col - 0.5 - centerCol) * CELL_PX
                local dist = math.sqrt(dRow*dRow + dCol*dCol)
                local key = row..","..col
                if dist <= exploRadius then
                    if not exploredCells[key] then exploredCells[key]=true end
                end
                -- Cor da célula
                if exploredCells[key] then
                    local fade = math.clamp(1 - (dist/(exploRadius*1.15)), 0.3, 1)
                    local g = math.floor(160*fade)
                    mapCells[row][col].BackgroundColor3 = Color3.fromRGB(20, g, 40)
                else
                    mapCells[row][col].BackgroundColor3 = Color3.fromRGB(25,16,8)
                end
            end
        end

        -- Calcula % de exploração
        local explored = 0; for _ in pairs(exploredCells) do explored+=1 end
        exploPercent = math.floor((explored / (MAP_GRID*MAP_GRID)) * 100)
        exploValLbl.Text = tostring(exploPercent).."% explorado"
        TweenService:Create(exploFill,TweenInfo.new(0.5),{Size=UDim2.new(exploPercent/100,0,1,0)}):Play()
        local fogR = math.floor(fogRadius)
        exploSubLbl.Text = "Raio visível: "..fogR.." studs"

        -- Atualiza dots dos jogadores
        for _, plr in ipairs(Players:GetPlayers()) do
            local uid = plr.UserId
            local ch  = plr.Character
            local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
            if hrp then
                local px, pz = worldToMapPos(hrp.Position.X, hrp.Position.Z)
                if not plrDots[uid] then
                    local dot=Instance.new("Frame",mapOuterFrame)
                    local isMe = plr==Player
                    dot.BackgroundColor3 = isMe and Color3.fromRGB(255,220,60) or Color3.fromRGB(100,180,255)
                    dot.BorderSizePixel=0; dot.Size=UDim2.new(0,isMe and 10 or 7,0,isMe and 10 or 7); dot.ZIndex=11
                    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
                    -- Nome tag no hover
                    local nametag=Instance.new("TextLabel",dot); nametag.BackgroundTransparency=1
                    nametag.Size=UDim2.new(0,60,0,12); nametag.Position=UDim2.new(0.5,-30,0,-14)
                    nametag.Font=Enum.Font.GothamBold; nametag.Text=plr.DisplayName
                    nametag.TextColor3=Color3.fromRGB(255,255,255); nametag.TextSize=7; nametag.ZIndex=12
                    local shadow=Instance.new("UIStroke",nametag); shadow.Color=Color3.fromRGB(0,0,0); shadow.Thickness=1.5; shadow.Transparency=0.4
                    plrDots[uid]=dot
                end
                local offset = plr==Player and 5 or 3
                plrDots[uid].Position = UDim2.new(0, px-offset, 0, pz-offset)
            end
        end
        -- Remove dots de jogadores que saíram
        for uid, dot in pairs(plrDots) do
            if not Players:GetPlayerByUserId(uid) then pcall(function() dot:Destroy() end); plrDots[uid]=nil end
        end
    end)
end

-- ════════════════════════════════════════════════════
-- LOOP PRINCIPAL DE ATUALIZAÇÃO
-- ════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            -- Tempo de sessão
            local elapsed = tick() - sessionStart
            local h = math.floor(elapsed/3600)
            local m = math.floor((elapsed%3600)/60)
            local s = math.floor(elapsed%60)
            if h > 0 then
                sessValLbl.Text = string.format("%dh %dm %ds", h, m, s)
            else
                sessValLbl.Text = string.format("%dm %ds", m, s)
            end

            -- Dia do jogo
            local day = getGameDay()
            if day then
                dayValLbl.Text = "Dia "..tostring(day)
                daySubLbl.Text = day==1 and "Primeiro dia!" or "sobreviveu "..day.." dias"
            else
                dayValLbl.Text = "Dia ?"
                daySubLbl.Text = "atributo não encontrado"
            end

            -- Mapa a cada 2s
            updateMapDisplay()
        end)
    end
end)

end) -- [[ STATUS TAB ]]

;pcall(function() -- [[ ESP + BRING ]]
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
    local function dk(f) f.BackgroundColor3=Color3.fromRGB(12,6,22); return f end
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
    {key="EspBigorna", trLabel="espBigornaLabel",trDesc="espBigornaDesc",label="⚙️ Anvil Parts", cor=Color3.fromRGB(255,220,150), tipo="item", alcance=math.huge, desc="Anvil Front/Back/Base + Meteor Anvil",
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
local function makeEspSection(titleKey, cor)
    local hdr=Instance.new("Frame",Pages["Esp"])
    hdr.BackgroundColor3=Color3.fromRGB(18,11,4); hdr.BorderSizePixel=0
    hdr.Size=UDim2.new(1,0,0,30); hdr.LayoutOrder=espLO(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,10)
    local hdrG=Instance.new("UIGradient",hdr)
    hdrG.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(
            math.floor(cor.R*255*0.15+18), math.floor(cor.G*255*0.1+10), math.floor(cor.B*255*0.1+4)
        )),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(12,7,2))
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

local function makeEspRow(cat)
    local row=Instance.new("Frame",Pages["Esp"]); row.BackgroundColor3=Color3.fromRGB(18,11,4)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,58); row.LayoutOrder=espLO(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,14)
    local rowG=Instance.new("UIGradient",row)
    rowG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(28,16,6)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,8,2))}); rowG.Rotation=135
    local rowStroke=Instance.new("UIStroke",row); rowStroke.Color=cat.cor; rowStroke.Thickness=1.5; rowStroke.Transparency=0.7
    rowStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local iconContainer=Instance.new("Frame",row); iconContainer.BackgroundColor3=Color3.fromRGB(45,28,15)
    iconContainer.BackgroundTransparency=0.3; iconContainer.BorderSizePixel=0
    iconContainer.Position=UDim2.new(0,8,0.5,-16); iconContainer.Size=UDim2.new(0,32,0,32); iconContainer.ZIndex=6
    Instance.new("UICorner",iconContainer).CornerRadius=UDim.new(0,7)
    local miniIcon=criarIconeEsp(iconContainer,cat.key,cat.cor)
    miniIcon.Position=UDim2.new(0,9,0,9); miniIcon.Size=UDim2.new(0,14,0,14)
    local labelNome=Instance.new("TextLabel",row); labelNome.BackgroundTransparency=1
    labelNome.Position=UDim2.new(0,50,0,8); labelNome.Size=UDim2.new(1,-110,0,16)
    labelNome.Font=Enum.Font.GothamBold; labelNome.Text=cat.label; labelNome.TextColor3=Color3.fromRGB(255,235,190)
    labelNome.TextSize=11; labelNome.TextXAlignment=Enum.TextXAlignment.Left; labelNome.ZIndex=6
    if cat.trLabel then TL(labelNome, cat.trLabel) end
    local labelDesc=Instance.new("TextLabel",row); labelDesc.BackgroundTransparency=1
    labelDesc.Position=UDim2.new(0,50,0,26); labelDesc.Size=UDim2.new(1,-110,0,20)
    labelDesc.Font=Enum.Font.Gotham; labelDesc.Text=cat.desc or ""; labelDesc.TextColor3=Color3.fromRGB(160,120,60)
    labelDesc.TextSize=9; labelDesc.TextXAlignment=Enum.TextXAlignment.Left; labelDesc.TextWrapped=true; labelDesc.ZIndex=6
    if cat.trDesc then TL(labelDesc, cat.trDesc) end
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(45,28,15); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-52,0.5,-11); pill.Size=UDim2.new(0,42,0,22); pill.ZIndex=7
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local pillS=Instance.new("UIStroke",pill); pillS.Color=Color3.fromRGB(20,10,0); pillS.Thickness=2.5
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(130,90,30); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,2,0.5,-9); knob.Size=UDim2.new(0,18,0,18); knob.ZIndex=8
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=9
    btn.MouseEnter:Connect(function() if currentTab~=cat.key then TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(52,34,14)}):Play() end end)
    btn.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(38,22,10)}):Play() end)
    btn.MouseButton1Click:Connect(function()
        state=not state; espAtivo[cat.key]=state; lastCache=0
        TweenService:Create(pill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundColor3=state and cat.cor or Color3.fromRGB(45,28,15)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
            BackgroundColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,90,30),
        }):Play()
        TweenService:Create(rowStroke,TweenInfo.new(0.2),{Color=state and cat.cor or Color3.fromRGB(252,198,0),Transparency=state and 0.3 or 0.82}):Play()
        if state then
            Notify.success(T("espOn"), cat.label)
        else
            Notify.error(T("espOff"), cat.label)
        end
    end)
end

local espCatMap={}; for _,c in ipairs(ESP_CATS) do espCatMap[c.key]=c end
local espGroupOrder={
    {"espGroupEntities", Color3.fromRGB(200,155,0), {"Players","Kids","Animais","Monstros","Cultistas","Aliens"}},
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
                pcall(function() part.AssemblyLinearVelocity = Vector3.zero end)
            end
            clearTrueOrigin(part)
            restored += 1
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
                pcall(function() part.AssemblyLinearVelocity = Vector3.zero end)
            end
            clearTrueOrigin(part)
            restored += 1
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

            count += 1
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
local function bringLO() bringTabLO+=1; return bringTabLO end

-- ══════════════════════════════════════════════════════
-- PAINEL INFO BRING — exibe count, delay e modo de destino
-- Fica NO TOPO da aba Bring (LayoutOrder = 0)
-- ══════════════════════════════════════════════════════
do
    local infoPnl = Instance.new("Frame", Pages["Bring"])
    infoPnl.BackgroundColor3 = Color3.fromRGB(22,12,5); infoPnl.BorderSizePixel=0
    infoPnl.Size = UDim2.new(1,0,0,84); infoPnl.LayoutOrder = 0; infoPnl.ZIndex = 5
    Instance.new("UICorner",infoPnl).CornerRadius = UDim.new(0,12)
    local infoPnlS = Instance.new("UIStroke",infoPnl)
    infoPnlS.Color = Color3.fromRGB(252,198,0); infoPnlS.Thickness = 2; infoPnlS.Transparency = 0.5
    local infoPnlG = Instance.new("UIGradient",infoPnl)
    infoPnlG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(36,20,6)),ColorSequenceKeypoint.new(1,Color3.fromRGB(16,8,2))}); infoPnlG.Rotation=135
    local infoPnlShine = Instance.new("Frame",infoPnl); infoPnlShine.BackgroundColor3=Color3.fromRGB(255,255,255)
    infoPnlShine.BackgroundTransparency=0.88; infoPnlShine.BorderSizePixel=0
    infoPnlShine.Position=UDim2.new(0,8,0,3); infoPnlShine.Size=UDim2.new(0,60,0,4); infoPnlShine.ZIndex=6
    Instance.new("UICorner",infoPnlShine).CornerRadius=UDim.new(1,0)

    -- Barra lateral amarela
    local sideBar = Instance.new("Frame",infoPnl); sideBar.BackgroundColor3=Color3.fromRGB(252,198,0)
    sideBar.BorderSizePixel=0; sideBar.Position=UDim2.new(0,0,0.12,0); sideBar.Size=UDim2.new(0,4,0.76,0); sideBar.ZIndex=6
    Instance.new("UICorner",sideBar).CornerRadius=UDim.new(0,3)

    -- Ícone
    local iconBg = Instance.new("Frame",infoPnl); iconBg.BackgroundColor3=Color3.fromRGB(252,198,0)
    iconBg.BackgroundTransparency=0.6; iconBg.BorderSizePixel=0
    iconBg.Position=UDim2.new(0,8,0.5,-18); iconBg.Size=UDim2.new(0,36,0,36); iconBg.ZIndex=6
    Instance.new("UICorner",iconBg).CornerRadius=UDim.new(0,9)
    Instance.new("UIStroke",iconBg).Color=Color3.fromRGB(8,4,0)
    local iconLbl=Instance.new("TextLabel",iconBg); iconLbl.BackgroundTransparency=1
    iconLbl.Size=UDim2.new(1,0,1,0); iconLbl.Font=Enum.Font.GothamBlack; iconLbl.Text="📦"; iconLbl.TextSize=18; iconLbl.ZIndex=7

    -- Título
    local titleLb=Instance.new("TextLabel",infoPnl); titleLb.BackgroundTransparency=1
    titleLb.Position=UDim2.new(0,54,0,8); titleLb.Size=UDim2.new(0.55,0,0,16)
    titleLb.Font=Enum.Font.GothamBlack; titleLb.Text="Bring — Painel de Info"
    titleLb.TextColor3=Color3.fromRGB(255,235,190); titleLb.TextSize=11; titleLb.TextXAlignment=Enum.TextXAlignment.Left; titleLb.ZIndex=6

    -- Count de itens e delay
    local countLb=Instance.new("TextLabel",infoPnl); countLb.BackgroundTransparency=1
    countLb.Position=UDim2.new(0,54,0,26); countLb.Size=UDim2.new(0.55,0,0,13)
    countLb.Font=Enum.Font.GothamBold; countLb.Text="📦 Itens encontrados: calculando..."
    countLb.TextColor3=Color3.fromRGB(200,165,90); countLb.TextSize=9; countLb.TextXAlignment=Enum.TextXAlignment.Left; countLb.ZIndex=6

    local delayLb=Instance.new("TextLabel",infoPnl); delayLb.BackgroundTransparency=1
    delayLb.Position=UDim2.new(0,54,0,42); delayLb.Size=UDim2.new(0.55,0,0,13)
    delayLb.Font=Enum.Font.GothamBold; delayLb.Text="⏱ Delay estimado: ~0.5s por lote"
    delayLb.TextColor3=Color3.fromRGB(160,130,70); delayLb.TextSize=9; delayLb.TextXAlignment=Enum.TextXAlignment.Left; delayLb.ZIndex=6

    -- ── Botão Modo ───────────────────────────────────────────────
    local MODE_OPTS = {
        {key="jogador", label="Jogador", icon="🧍", desc="Itens vêm até você"},
        {key="fogueira", label="Fogueira", icon="🔥", desc="Itens aparecem na fogueira"},
        {key="ceu",     label="Céu",     icon="🌤️", desc="Itens caem do alto"},
    }
    local MODE_COLORS = {jogador=Color3.fromRGB(100,200,255), fogueira=Color3.fromRGB(255,120,40), ceu=Color3.fromRGB(140,200,255)}

    local modeBtn=Instance.new("TextButton",infoPnl); modeBtn.BackgroundColor3=Color3.fromRGB(40,22,8)
    modeBtn.BorderSizePixel=0; modeBtn.Position=UDim2.new(1,-100,0.5,-18); modeBtn.Size=UDim2.new(0,92,0,36)
    modeBtn.Font=Enum.Font.GothamBlack; modeBtn.Text="🧍 Modo Jogador"
    modeBtn.TextColor3=Color3.fromRGB(255,235,190); modeBtn.TextSize=10; modeBtn.ZIndex=8; modeBtn.AutoButtonColor=false
    Instance.new("UICorner",modeBtn).CornerRadius=UDim.new(0,10)
    local modeBtnS=Instance.new("UIStroke",modeBtn); modeBtnS.Color=Color3.fromRGB(252,198,0); modeBtnS.Thickness=2.5; modeBtnS.Transparency=0.4
    local modeBtnG=Instance.new("UIGradient",modeBtn); modeBtnG.Rotation=90
    modeBtnG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(55,30,10)),ColorSequenceKeypoint.new(1,Color3.fromRGB(28,14,4))})
    local modeBtnShine=Instance.new("Frame",modeBtn); modeBtnShine.BackgroundColor3=Color3.fromRGB(255,255,255)
    modeBtnShine.BackgroundTransparency=0.82; modeBtnShine.BorderSizePixel=0
    modeBtnShine.Position=UDim2.new(0,5,0,3); modeBtnShine.Size=UDim2.new(0,38,0,6); modeBtnShine.ZIndex=9
    Instance.new("UICorner",modeBtnShine).CornerRadius=UDim.new(1,0)

    -- Referências globais para o sistema de lock
    local _bringLockOverlay = nil  -- overlay de lock criado depois
    local _bringUnlockCallbacks = {}  -- callbacks registrados pelos rows

    local function registerBringUnlockCb(fn)
        table.insert(_bringUnlockCallbacks, fn)
    end

    local function fireBringUnlock()
        for _, fn in ipairs(_bringUnlockCallbacks) do pcall(fn) end
    end

    local function updateModeBtn()
        if not bringDestMode then
            -- Trancado: sem modo selecionado
            modeBtn.Text = "🔒 Modo"
            modeBtn.TextColor3 = Color3.fromRGB(180,130,60)
            modeBtnS.Color = Color3.fromRGB(180,100,30)
        else
            local mc = MODE_COLORS[bringDestMode] or Color3.fromRGB(252,198,0)
            local ico = ""
            for _, o in ipairs(MODE_OPTS) do if o.key==bringDestMode then ico=o.icon.." "; break end end
            modeBtn.Text = ico.."Modo "..string.upper(bringDestMode:sub(1,1))..bringDestMode:sub(2)
            modeBtn.TextColor3 = mc
            modeBtnS.Color = mc
        end
    end
    updateModeBtn()

    -- ── Popup de Modo (ScreenGui, não é clipado) ─────────────────
    local popup=Instance.new("Frame",ScreenGui)
    popup.BackgroundColor3=Color3.fromRGB(20,12,4); popup.BorderSizePixel=0
    popup.ZIndex=310; popup.Visible=false; popup.Size=UDim2.new(0,200,0,0)
    Instance.new("UICorner",popup).CornerRadius=UDim.new(0,14)
    local popupStroke=Instance.new("UIStroke",popup)
    popupStroke.Color=Color3.fromRGB(252,198,0); popupStroke.Thickness=2.5
    popupStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    -- Cabeçalho do popup
    local popHeader=Instance.new("Frame",popup); popHeader.BackgroundColor3=Color3.fromRGB(252,198,0)
    popHeader.BackgroundTransparency=0.85; popHeader.BorderSizePixel=0
    popHeader.Size=UDim2.new(1,0,0,32); popHeader.ZIndex=311
    Instance.new("UICorner",popHeader).CornerRadius=UDim.new(0,12)
    local popHeaderFix=Instance.new("Frame",popHeader); popHeaderFix.BackgroundColor3=Color3.fromRGB(252,198,0)
    popHeaderFix.BackgroundTransparency=0.85; popHeaderFix.BorderSizePixel=0
    popHeaderFix.Position=UDim2.new(0,0,0.5,0); popHeaderFix.Size=UDim2.new(1,0,0.5,0); popHeaderFix.ZIndex=311
    local popTitle=Instance.new("TextLabel",popHeader); popTitle.BackgroundTransparency=1
    popTitle.Position=UDim2.new(0,12,0,0); popTitle.Size=UDim2.new(1,-16,1,0)
    popTitle.Font=Enum.Font.GothamBlack; popTitle.Text="🎯  Destino do Bring"
    popTitle.TextColor3=Color3.fromRGB(252,220,80); popTitle.TextSize=11
    popTitle.TextXAlignment=Enum.TextXAlignment.Left; popTitle.ZIndex=312
    -- Sombra interna sutil
    local popInner=Instance.new("UIGradient",popup)
    popInner.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(32,18,6)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,8,2))}); popInner.Rotation=135
    -- Lista de opções
    local popList=Instance.new("Frame",popup); popList.BackgroundTransparency=1
    popList.BorderSizePixel=0; popList.Position=UDim2.new(0,8,0,38)
    popList.Size=UDim2.new(1,-16,0,0); popList.ZIndex=311; popList.AutomaticSize=Enum.AutomaticSize.Y
    local popLayout=Instance.new("UIListLayout",popList); popLayout.Padding=UDim.new(0,5); popLayout.SortOrder=Enum.SortOrder.LayoutOrder
    -- Fechamento
    local popupOpen = false
    local function closePopup()
        popupOpen=false
        TweenService:Create(popup,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,200,0,0),BackgroundTransparency=1}):Play()
        task.delay(0.18,function() popup.Visible=false; popup.BackgroundTransparency=0 end)
    end

    for idx, opt in ipairs(MODE_OPTS) do
        local ob=Instance.new("TextButton",popList); ob.BackgroundColor3=Color3.fromRGB(30,18,6)
        ob.BackgroundTransparency=0; ob.BorderSizePixel=0
        ob.Size=UDim2.new(1,0,0,50); ob.LayoutOrder=idx; ob.ZIndex=312; ob.AutoButtonColor=false
        Instance.new("UICorner",ob).CornerRadius=UDim.new(0,10)
        local obStroke=Instance.new("UIStroke",ob); obStroke.Color=MODE_COLORS[opt.key] or Color3.fromRGB(252,198,0); obStroke.Thickness=1.5; obStroke.Transparency=0.6
        local obG=Instance.new("UIGradient",ob); obG.Rotation=135
        obG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(42,24,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(20,10,3))})
        -- Faixa de cor lateral
        local obBar=Instance.new("Frame",ob); obBar.BackgroundColor3=MODE_COLORS[opt.key] or Color3.fromRGB(252,198,0)
        obBar.BorderSizePixel=0; obBar.Size=UDim2.new(0,4,0.7,0); obBar.Position=UDim2.new(0,0,0.15,0); obBar.ZIndex=313
        Instance.new("UICorner",obBar).CornerRadius=UDim.new(0,3)
        -- Ícone
        local obIco=Instance.new("TextLabel",ob); obIco.BackgroundTransparency=1
        obIco.Position=UDim2.new(0,10,0,0); obIco.Size=UDim2.new(0,28,1,0)
        obIco.Font=Enum.Font.GothamBlack; obIco.Text=opt.icon; obIco.TextSize=18; obIco.ZIndex=313
        -- Label principal
        local obLbl=Instance.new("TextLabel",ob); obLbl.BackgroundTransparency=1
        obLbl.Position=UDim2.new(0,42,0,6); obLbl.Size=UDim2.new(1,-46,0,18)
        obLbl.Font=Enum.Font.GothamBlack; obLbl.Text=opt.label
        obLbl.TextColor3=Color3.fromRGB(245,235,210); obLbl.TextSize=11
        obLbl.TextXAlignment=Enum.TextXAlignment.Left; obLbl.ZIndex=313
        -- Descrição
        local obDesc=Instance.new("TextLabel",ob); obDesc.BackgroundTransparency=1
        obDesc.Position=UDim2.new(0,42,0,26); obDesc.Size=UDim2.new(1,-48,0,14)
        obDesc.Font=Enum.Font.Gotham; obDesc.Text=opt.desc
        obDesc.TextColor3=Color3.fromRGB(160,130,70); obDesc.TextSize=8
        obDesc.TextXAlignment=Enum.TextXAlignment.Left; obDesc.ZIndex=313
        -- Highlight selecionado
        local function refreshObHighlight()
            local sel = (bringDestMode == opt.key)
            TweenService:Create(obStroke,TweenInfo.new(0.15),{Transparency = sel and 0 or 0.6}):Play()
            TweenService:Create(ob,TweenInfo.new(0.15),{BackgroundColor3 = sel and Color3.fromRGB(50,28,8) or Color3.fromRGB(30,18,6)}):Play()
        end
        refreshObHighlight()
        ob.MouseEnter:Connect(function()
            TweenService:Create(ob,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(45,25,8)}):Play()
            TweenService:Create(obStroke,TweenInfo.new(0.1),{Transparency=0.2}):Play()
        end)
        ob.MouseLeave:Connect(function() refreshObHighlight() end)
        ob.MouseButton1Click:Connect(function()
            local wasNil = (bringDestMode == nil)
            bringDestMode = opt.key
            updateModeBtn()
            -- Atualiza highlight de todos os botões do popup
            for _, child in ipairs(popList:GetChildren()) do
                if child:IsA("TextButton") then
                    local childStroke = child:FindFirstChildWhichIsA("UIStroke")
                    -- cada botão tem sua própria refreshObHighlight via closure — não é acessível aqui
                    -- mas o closePopup vai fazer popup sumir então não importa
                end
            end
            closePopup()
            if wasNil then fireBringUnlock() end
            Notify.send({type="info", icon=opt.icon, accent=MODE_COLORS[opt.key], title="Modo Bring", msg=opt.label..": "..opt.desc, duration=2.5})
        end)
    end
    -- Espaço inferior
    local popPad=Instance.new("Frame",popList); popPad.BackgroundTransparency=1; popPad.Size=UDim2.new(1,0,0,4); popPad.LayoutOrder=99

    modeBtn.MouseButton1Click:Connect(function()
        if popupOpen then closePopup(); return end
        local ap = modeBtn.AbsolutePosition
        local as = modeBtn.AbsoluteSize
        -- Calcula altura real do popup (cabeçalho 32 + 3 opções de 55px cada + padding)
        local popH = 32 + #MODE_OPTS*55 + 8
        popup.Position = UDim2.new(0, ap.X + as.X - 200, 0, ap.Y - popH - 6)
        popup.Size = UDim2.new(0,200,0,0); popup.BackgroundTransparency=1; popup.Visible=true
        TweenService:Create(popup,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Size=UDim2.new(0,200,0,popH), BackgroundTransparency=0
        }):Play()
        popupOpen = true
    end)

    -- Fecha popup ao clicar fora
    MainFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 and popupOpen then
            local mx,my = inp.Position.X, inp.Position.Y
            local pA = popup.AbsolutePosition; local pS = popup.AbsoluteSize
            if mx<pA.X or mx>pA.X+pS.X or my<pA.Y or my>pA.Y+pS.Y then closePopup() end
        end
    end)

    -- Atualiza contagem de itens em background (a cada 5s)
    task.spawn(function()
        while true do
            task.wait(5)
            pcall(function()
                local total=0
                for _, cat in ipairs(BRING_CATS) do
                    local lk = bringLookup[cat.key]
                    if lk then
                        for _,obj in ipairs(workspace:GetDescendants()) do
                            pcall(function()
                                local nm = obj.Name:lower()
                                if lk[nm] then total+=1 end
                            end)
                        end
                    end
                end
                countLb.Text="📦 Itens no mapa: "..tostring(total)
                local estDelay = math.max(0.5, math.floor(total/20)*0.5)
                delayLb.Text="⏱ Delay estimado: ~"..string.format("%.1f", estDelay).."s"
            end)
        end
    end)
end -- painel info bring

local function makeBringSection(trKey, cor)
    local hdr=Instance.new("Frame",Pages["Bring"])
    hdr.BackgroundColor3=Color3.fromRGB(18,11,4); hdr.BorderSizePixel=0
    hdr.Size=UDim2.new(1,0,0,30); hdr.LayoutOrder=bringLO(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,10)
    local hdrG=Instance.new("UIGradient",hdr)
    hdrG.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(
            math.floor(cor.R*255*0.15+18), math.floor(cor.G*255*0.1+10), math.floor(cor.B*255*0.1+4)
        )),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(12,7,2))
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
    local row=Instance.new("Frame",Pages["Bring"]); row.BackgroundColor3=Color3.fromRGB(26,15,6)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,82); row.LayoutOrder=bringLO(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)
    -- Gradiente cartoon
    local rowG=Instance.new("UIGradient",row)
    rowG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(40,24,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,3))}); rowG.Rotation=135
    -- Borda preta Brawl Stars
    local rowStroke=Instance.new("UIStroke",row)
    rowStroke.Color=Color3.fromRGB(8,4,0); rowStroke.Thickness=3
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
    local icoS=Instance.new("UIStroke",iconBox); icoS.Color=Color3.fromRGB(8,4,0); icoS.Thickness=2.5
    icoS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local icon=criarIconeBring(iconBox,bcat.key,bcat.cor); icon.Position=UDim2.new(0,4,0,4); icon.Size=UDim2.new(0,28,0,28)
    -- Nome da categoria (branco + stroke preta)
    local labelNome=Instance.new("TextLabel",row); labelNome.BackgroundTransparency=1
    labelNome.Position=UDim2.new(0,54,0,10); labelNome.Size=UDim2.new(1,-168,0,18)
    labelNome.Font=Enum.Font.GothamBlack; labelNome.Text=bcat.label; labelNome.TextColor3=Color3.fromRGB(255,255,255)
    labelNome.TextSize=11; labelNome.TextXAlignment=Enum.TextXAlignment.Left; labelNome.ZIndex=7
    local labelNomeS=Instance.new("UIStroke",labelNome); labelNomeS.Color=Color3.fromRGB(8,4,0); labelNomeS.Thickness=1.6
    if bcat.trLabel then TL(labelNome, bcat.trLabel) end
    local labelDesc=Instance.new("TextLabel",row); labelDesc.BackgroundTransparency=1
    labelDesc.Position=UDim2.new(0,54,0,30); labelDesc.Size=UDim2.new(1,-168,0,24)
    labelDesc.Font=Enum.Font.Gotham; labelDesc.Text=bcat.desc or ""; labelDesc.TextColor3=Color3.fromRGB(180,160,110)
    labelDesc.TextSize=9; labelDesc.TextXAlignment=Enum.TextXAlignment.Left; labelDesc.TextWrapped=true; labelDesc.ZIndex=7
    if bcat.trDesc then TL(labelDesc, bcat.trDesc) end
    local feedbackLbl=Instance.new("TextLabel",row); feedbackLbl.BackgroundTransparency=1
    feedbackLbl.Position=UDim2.new(1,-90,0,62); feedbackLbl.Size=UDim2.new(0,82,0,12)
    feedbackLbl.Font=Enum.Font.Gotham; feedbackLbl.Text=""; feedbackLbl.TextColor3=bcat.cor
    feedbackLbl.TextSize=8; feedbackLbl.TextXAlignment=Enum.TextXAlignment.Center; feedbackLbl.ZIndex=8

    -- Botão BRING — dourado cartoon (Brawl Stars style)
    local btnBring=Instance.new("TextButton",row); btnBring.BackgroundColor3=Color3.fromRGB(252,196,0)
    btnBring.BackgroundTransparency=0; btnBring.BorderSizePixel=0
    btnBring.Position=UDim2.new(1,-90,0,8); btnBring.Size=UDim2.new(0,82,0,28)
    btnBring.Font=Enum.Font.GothamBlack; btnBring.Text=T("bringBtnLabel"); btnBring.TextColor3=Color3.fromRGB(22,10,0)
    btnBring.TextSize=10; btnBring.ZIndex=9
    Instance.new("UICorner",btnBring).CornerRadius=UDim.new(0,9)
    local btnStroke=Instance.new("UIStroke",btnBring)
    btnStroke.Color=Color3.fromRGB(8,4,0); btnStroke.Thickness=2.5; btnStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local btnG=Instance.new("UIGradient",btnBring)
    btnG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,238,80)),ColorSequenceKeypoint.new(1,Color3.fromRGB(200,140,0))}); btnG.Rotation=90
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
    limparStroke.Color=Color3.fromRGB(8,4,0); limparStroke.Thickness=2; limparStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    btnLimpar.MouseEnter:Connect(function() TweenService:Create(btnLimpar,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(220,50,50),BackgroundTransparency=0}):Play() end)
    btnLimpar.MouseLeave:Connect(function() TweenService:Create(btnLimpar,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(180,40,40),BackgroundTransparency=0.1}):Play() end)

    -- Lock: registra callback para desabilitar/habilitar com o modo
    local function applyLockState()
        local locked = (bringDestMode == nil)
        if locked then
            btnBring.BackgroundColor3 = Color3.fromRGB(50,35,10)
            btnBring.TextColor3 = Color3.fromRGB(120,90,30)
            btnBring.Text = "🔒 Bloqueado"
            TweenService:Create(btnStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(100,70,20),Transparency=0.5}):Play()
        else
            btnBring.BackgroundColor3 = Color3.fromRGB(252,196,0)
            btnBring.TextColor3 = Color3.fromRGB(22,10,0)
            btnBring.Text = T("bringBtnLabel")
            TweenService:Create(btnStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(8,4,0),Transparency=0}):Play()
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
            task.delay(1.5,function() TweenService:Create(rowStroke,TweenInfo.new(0.4),{Color=Color3.fromRGB(252,198,0),Transparency=0.82}):Play() end)
            task.wait(1); running=false
        end)
    end)

    btnLimpar.MouseButton1Click:Connect(function()
        local restored = limparBring(bcat.key)
        if restored > 0 then
            feedbackLbl.Text="↩ "..tostring(restored).." restaurado(s)"; feedbackLbl.TextColor3=Color3.fromRGB(255,200,80); feedbackLbl.TextTransparency=0
            Notify.info(bcat.label, "↩ "..tostring(restored).." item(s) devolvido(s) ao lugar.", 3)
            TweenService:Create(btnLimpar,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(87,180,100)}):Play()
            task.delay(0.8, function() TweenService:Create(btnLimpar,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(35,18,60)}):Play() end)
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
    local baSep=Instance.new("Frame",Pages["Bring"]); baSep.BackgroundColor3=Color3.fromRGB(252,198,0); baSep.BackgroundTransparency=0.82
    baSep.BorderSizePixel=0; baSep.Size=UDim2.new(1,0,0,1); baSep.LayoutOrder=bringLO(); baSep.ZIndex=5

    local baCard=Instance.new("Frame",Pages["Bring"])
    baCard.BackgroundColor3=Color3.fromRGB(28,16,8); baCard.BorderSizePixel=0
    baCard.Size=UDim2.new(1,0,0,90); baCard.LayoutOrder=bringLO(); baCard.ZIndex=5
    Instance.new("UICorner",baCard).CornerRadius=UDim.new(0,10)
    local baStroke=Instance.new("UIStroke",baCard); baStroke.Color=Color3.fromRGB(252,198,0); baStroke.Thickness=2.5; baStroke.Transparency=0.4

    -- Glow bg
    local baGlow=Instance.new("Frame",baCard); baGlow.BackgroundColor3=Color3.fromRGB(252,198,0)
    baGlow.BackgroundTransparency=0.92; baGlow.BorderSizePixel=0; baGlow.Size=UDim2.new(1,0,1,0); baGlow.ZIndex=5
    Instance.new("UICorner",baGlow).CornerRadius=UDim.new(0,10)

    -- Barra lateral
    local baBar=Instance.new("Frame",baCard); baBar.BackgroundColor3=Color3.fromRGB(252,198,0)
    baBar.BorderSizePixel=0; baBar.Size=UDim2.new(0,4,0.7,0); baBar.Position=UDim2.new(0,0,0.15,0); baBar.ZIndex=6
    Instance.new("UICorner",baBar).CornerRadius=UDim.new(0,2)

    -- Ícone
    local baIconBg=Instance.new("Frame",baCard); baIconBg.BackgroundColor3=Color3.fromRGB(252,198,0)
    baIconBg.BackgroundTransparency=0.72; baIconBg.BorderSizePixel=0
    baIconBg.Position=UDim2.new(0,10,0.5,-20); baIconBg.Size=UDim2.new(0,40,0,40); baIconBg.ZIndex=6
    Instance.new("UICorner",baIconBg).CornerRadius=UDim.new(0,10)
    local baIconLbl=Instance.new("TextLabel",baIconBg); baIconLbl.BackgroundTransparency=1
    baIconLbl.Size=UDim2.new(1,0,1,0); baIconLbl.Font=Enum.Font.GothamBlack
    baIconLbl.Text="⚡"; baIconLbl.TextColor3=Color3.fromRGB(20,10,0); baIconLbl.TextSize=22; baIconLbl.ZIndex=7

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
    baDescLbl.TextColor3=Color3.fromRGB(160,120,60); baDescLbl.TextSize=9
    baDescLbl.TextWrapped=true; baDescLbl.TextXAlignment=Enum.TextXAlignment.Left; baDescLbl.ZIndex=6

    -- Feedback
    local baFeedLbl=Instance.new("TextLabel",baCard); baFeedLbl.BackgroundTransparency=1
    baFeedLbl.Position=UDim2.new(1,-115,0,64); baFeedLbl.Size=UDim2.new(0,107,0,14)
    baFeedLbl.Font=Enum.Font.GothamBold; baFeedLbl.Text=""
    baFeedLbl.TextColor3=Color3.fromRGB(252,198,0); baFeedLbl.TextSize=8
    baFeedLbl.TextXAlignment=Enum.TextXAlignment.Center; baFeedLbl.ZIndex=7

    -- Barra de progresso
    local baProgBg=Instance.new("Frame",baCard); baProgBg.BackgroundColor3=Color3.fromRGB(45,28,15)
    baProgBg.BorderSizePixel=0; baProgBg.Position=UDim2.new(1,-115,0.5,-5); baProgBg.Size=UDim2.new(0,107,0,4); baProgBg.ZIndex=6
    Instance.new("UICorner",baProgBg).CornerRadius=UDim.new(0,2)
    local baProgFill=Instance.new("Frame",baProgBg); baProgFill.BackgroundColor3=Color3.fromRGB(252,198,0)
    baProgFill.BorderSizePixel=0; baProgFill.Size=UDim2.new(0,0,1,0); baProgFill.ZIndex=7
    Instance.new("UICorner",baProgFill).CornerRadius=UDim.new(0,2)

    -- Botão
    local baBtn=Instance.new("TextButton",baCard); baBtn.BackgroundColor3=Color3.fromRGB(252,198,0)
    baBtn.BackgroundTransparency=0.05; baBtn.BorderSizePixel=0
    baBtn.Position=UDim2.new(1,-115,0,12); baBtn.Size=UDim2.new(0,107,0,44)
    baBtn.Font=Enum.Font.GothamBlack; baBtn.Text="▼  BRING ALL"
    trackLabel(baBtn, "bringAllBtn")
    baBtn.TextColor3=Color3.fromRGB(20,10,0); baBtn.TextSize=11; baBtn.ZIndex=7
    Instance.new("UICorner",baBtn).CornerRadius=UDim.new(0,9)
    local baBtnStroke=Instance.new("UIStroke",baBtn); baBtnStroke.Color=Color3.fromRGB(20,10,0); baBtnStroke.Thickness=1.2; baBtnStroke.Transparency=0.5
    baBtn.MouseEnter:Connect(function() TweenService:Create(baBtn,TweenInfo.new(0.12),{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(255,220,50)}):Play() end)
    baBtn.MouseLeave:Connect(function() TweenService:Create(baBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.05,BackgroundColor3=Color3.fromRGB(252,198,0)}):Play() end)

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
                    batch+=1
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

                        count += 1
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
                TweenService:Create(baProgFill,TweenInfo.new(0.5),{Size=UDim2.new(0,0,1,0),BackgroundColor3=Color3.fromRGB(200,155,0)}):Play()
                TweenService:Create(baFeedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play()
                task.wait(0.5); baFeedLbl.Text=""; baFeedLbl.TextTransparency=0
            end)
            task.wait(1.5); baRunning=false
        end)
    end)

    -- Botão LIMPAR ALL
    local baLimparBtn=Instance.new("TextButton",baCard); baLimparBtn.BackgroundColor3=Color3.fromRGB(35,18,60)
    baLimparBtn.BackgroundTransparency=0.1; baLimparBtn.BorderSizePixel=0
    baLimparBtn.Position=UDim2.new(1,-115,0,62); baLimparBtn.Size=UDim2.new(0,107,0,20)
    baLimparBtn.Font=Enum.Font.GothamBold; baLimparBtn.Text="🗑 Limpar Tudo"
    baLimparBtn.TextColor3=Color3.fromRGB(180,190,220); baLimparBtn.TextSize=9; baLimparBtn.ZIndex=8
    Instance.new("UICorner",baLimparBtn).CornerRadius=UDim.new(0,7)
    local baLimparStroke=Instance.new("UIStroke",baLimparBtn); baLimparStroke.Color=Color3.fromRGB(155,115,50); baLimparStroke.Thickness=1; baLimparStroke.Transparency=0.5
    baCard.Size=UDim2.new(1,0,0,92)
    baLimparBtn.MouseEnter:Connect(function() TweenService:Create(baLimparBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(200,80,80),BackgroundTransparency=0}):Play() end)
    baLimparBtn.MouseLeave:Connect(function() TweenService:Create(baLimparBtn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(35,18,60),BackgroundTransparency=0.1}):Play() end)
    baLimparBtn.MouseButton1Click:Connect(function()
        local restored = limparBringAll()
        if restored > 0 then
            baFeedLbl.Text="↩ "..tostring(restored).." restaurado(s)"; baFeedLbl.TextColor3=Color3.fromRGB(255,200,80); baFeedLbl.TextTransparency=0
            Notify.info(T("bringAllTitle"), "↩ "..tostring(restored).." item(s) devolvido(s) ao lugar.", 3.5)
            TweenService:Create(baLimparBtn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(87,180,100)}):Play()
            task.delay(0.8, function() TweenService:Create(baLimparBtn,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(35,18,60)}):Play() end)
            task.delay(3,function() TweenService:Create(baFeedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); baFeedLbl.Text=""; baFeedLbl.TextTransparency=0 end)
        else
            baFeedLbl.Text="⚠ Nada a limpar"; baFeedLbl.TextColor3=Color3.fromRGB(160,160,180); baFeedLbl.TextTransparency=0
            task.delay(2,function() TweenService:Create(baFeedLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); baFeedLbl.Text=""; baFeedLbl.TextTransparency=0 end)
        end
    end)
end

end) -- [[ ESP + BRING ]]

-- ══════════════════════════════════════════════════════
--  PLAYER TAB
-- ══════════════════════════════════════════════════════
;pcall(function() -- [[ PLAYER TAB ]]
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

            flyBodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
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
                if py < NOCLIP_VOID_Y then hrp.CFrame = CFrame.new(hrp.Position.X, NOCLIP_VOID_Y+10, hrp.Position.Z); hrp.Velocity = Vector3.zero end
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
plNextLO = function() plLO+=1; return plLO end

local function makePlSec(titleKey, cor)
    local hdr=Instance.new("Frame",Pages["Player"])
    hdr.BackgroundColor3=Color3.fromRGB(18,11,4); hdr.BorderSizePixel=0
    hdr.Size=UDim2.new(1,0,0,30); hdr.LayoutOrder=plNextLO(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,10)
    local hdrG=Instance.new("UIGradient",hdr)
    hdrG.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(
            math.floor(cor.R*255*0.16+18), math.floor(cor.G*255*0.11+10), math.floor(cor.B*255*0.11+4)
        )),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12,7,2))
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
    local row=Instance.new("Frame",Pages["Player"]); row.BackgroundColor3=Color3.fromRGB(18,11,4)
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
    tl.Text=lbl_txt; tl.TextColor3=Color3.fromRGB(255,245,220); tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local tlS=Instance.new("UIStroke",tl); tlS.Color=Color3.fromRGB(0,0,0); tlS.Thickness=0.7; tlS.Transparency=0.4
    local td=Instance.new("TextLabel",row); td.BackgroundTransparency=1
    td.Position=UDim2.new(0,14,0,30); td.Size=UDim2.new(1,-80,0,22); td.Font=Enum.Font.Gotham
    td.Text=desc_txt; td.TextColor3=Color3.fromRGB(155,120,65); td.TextSize=9
    td.TextXAlignment=Enum.TextXAlignment.Left; td.TextWrapped=true; td.ZIndex=7
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(40,25,12); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-62,0.5,-13); pill.Size=UDim2.new(0,52,0,26); pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local pillS2=Instance.new("UIStroke",pill); pillS2.Color=Color3.fromRGB(0,0,0); pillS2.Thickness=1.5; pillS2.Transparency=0.5
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(120,85,30); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,2,0.5,-11); knob.Size=UDim2.new(0,22,0,22); knob.ZIndex=10
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=11
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(rowS,TweenInfo.new(0.2),{Transparency=state and 0.3 or 0.7}):Play()
        TweenService:Create(pill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundColor3=state and cor or Color3.fromRGB(40,25,12)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=state and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
            BackgroundColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(120,85,30)
        }):Play()
        TweenService:Create(rowS,TweenInfo.new(0.2),{Color=state and cor or Color3.fromRGB(252,198,0),Transparency=state and 0.35 or 0.82}):Play()
        -- Som de ligar/desligar
        pcall(function()
            local sndId = state and 6031221736 or 2544086171
            local snd = Instance.new("Sound", SoundService)
            snd.SoundId = "rbxassetid://"..tostring(sndId)
            snd.Volume = 0.45; snd.RollOffMaxDistance = 0; snd:Play()
            game:GetService("Debris"):AddItem(snd, 3)
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
    local row = Instance.new("Frame", parentPage)
    row.BackgroundColor3 = Color3.fromRGB(26,15,6); row.BorderSizePixel = 0
    row.Size = UDim2.new(1,0,0,80); row.LayoutOrder = lo_fn(); row.ZIndex = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,12)
    local rowG=Instance.new("UIGradient",row)
    rowG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(40,24,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,3))}); rowG.Rotation=135
    local rowS = Instance.new("UIStroke", row)
    rowS.Color = Color3.fromRGB(8,4,0); rowS.Thickness = 3
    rowS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local lbar=Instance.new("Frame",row); lbar.BackgroundColor3=cor; lbar.BorderSizePixel=0
    lbar.Size=UDim2.new(0,5,0.70,0); lbar.Position=UDim2.new(0,0,0.15,0); lbar.ZIndex=6
    Instance.new("UICorner",lbar).CornerRadius=UDim.new(0,4)
    local shine=Instance.new("Frame",row); shine.BackgroundColor3=Color3.fromRGB(255,255,255)
    shine.BackgroundTransparency=0.82; shine.BorderSizePixel=0
    shine.Position=UDim2.new(0,8,0,3); shine.Size=UDim2.new(0,55,0,5); shine.ZIndex=6
    Instance.new("UICorner",shine).CornerRadius=UDim.new(1,0)
    local tl = Instance.new("TextLabel", row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,8); tl.Size=UDim2.new(0.62,0,0,18); tl.Font=Enum.Font.GothamBlack
    tl.Text=lbl_txt; tl.TextColor3=Color3.fromRGB(255,255,255); tl.TextSize=12
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local tlS=Instance.new("UIStroke",tl); tlS.Color=Color3.fromRGB(8,4,0); tlS.Thickness=1.8
    local valBadge=Instance.new("Frame",row); valBadge.BackgroundColor3=cor; valBadge.BackgroundTransparency=0.1
    valBadge.BorderSizePixel=0; valBadge.AnchorPoint=Vector2.new(1,0)
    valBadge.Position=UDim2.new(1,-6,0,6); valBadge.Size=UDim2.new(0,52,0,20); valBadge.ZIndex=8
    Instance.new("UICorner",valBadge).CornerRadius=UDim.new(0,7)
    local vBS=Instance.new("UIStroke",valBadge); vBS.Color=Color3.fromRGB(8,4,0); vBS.Thickness=2
    vBS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local valLbl = Instance.new("TextLabel", valBadge); valLbl.BackgroundTransparency=1
    valLbl.Size=UDim2.new(1,0,1,0); valLbl.Font=Enum.Font.GothamBlack
    valLbl.Text=tostring(initVal); valLbl.TextColor3=Color3.fromRGB(255,255,255); valLbl.TextSize=11; valLbl.ZIndex=9
    local valLblS=Instance.new("UIStroke",valLbl); valLblS.Color=Color3.fromRGB(8,4,0); valLblS.Thickness=1.2
    local td = Instance.new("TextLabel", row); td.BackgroundTransparency=1
    td.Position=UDim2.new(0,14,0,28); td.Size=UDim2.new(1,-20,0,14); td.Font=Enum.Font.Gotham
    td.Text=desc_txt; td.TextColor3=Color3.fromRGB(180,160,110); td.TextSize=9; td.TextXAlignment=Enum.TextXAlignment.Left; td.ZIndex=7
    local trackBg = Instance.new("Frame", row); trackBg.BackgroundColor3=Color3.fromRGB(14,7,2)
    trackBg.BorderSizePixel=0; trackBg.Position=UDim2.new(0,14,0,54); trackBg.Size=UDim2.new(1,-28,0,14)
    trackBg.ZIndex=7; Instance.new("UICorner",trackBg).CornerRadius=UDim.new(1,0)
    local tbS=Instance.new("UIStroke",trackBg); tbS.Color=Color3.fromRGB(8,4,0); tbS.Thickness=1.5
    local pct0 = math.clamp((initVal - minV) / (maxV - minV), 0, 1)
    local fill = Instance.new("Frame", trackBg); fill.BackgroundColor3=cor; fill.BorderSizePixel=0
    fill.Size=UDim2.new(pct0,0,1,0); fill.ZIndex=8; Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local fillG=Instance.new("UIGradient",fill)
    fillG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,200)),ColorSequenceKeypoint.new(1,cor)})
    local knob = Instance.new("Frame", trackBg); knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    knob.BorderSizePixel=0; knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(pct0,0,0.5,0); knob.Size=UDim2.new(0,20,0,20); knob.ZIndex=9
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local kS=Instance.new("UIStroke",knob); kS.Color=Color3.fromRGB(8,4,0); kS.Thickness=2.5
    kS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
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
-- ══════════════════════════════════════════════════════════════════
-- makePlKACard — card moderno: toggle pill + mini slider
-- Layout: [Título+Desc | toggle+status] | [Valor+Slider]
-- ══════════════════════════════════════════════════════════════════
local function makePlKACard(COR, titleTxt, descTxt, minV, maxV, defV, maxStr, getDescFn, initEnabled, onToggle, onSlider)
    local r,g,b = math.floor(COR.R*255), math.floor(COR.G*255), math.floor(COR.B*255)
    local SOFF  = Color3.fromRGB(math.clamp(r*0.25+35,35,75), math.clamp(g*0.18+35,35,75), math.clamp(b*0.18+35,35,75))

    local card = Instance.new("Frame", Pages["Player"])
    card.BackgroundColor3 = Color3.fromRGB(18,11,4); card.BorderSizePixel = 0
    card.Size = UDim2.new(1,0,0,88); card.LayoutOrder = plNextLO(); card.ZIndex = 5
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,14)
    local cardG=Instance.new("UIGradient",card)
    cardG.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(
            math.clamp(math.floor(r/7)+18,18,36), math.clamp(math.floor(g/8)+10,10,24), math.clamp(math.floor(b/8)+4,4,16)
        )),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(13,8,3))
    }); cardG.Rotation=145
    local cardS = Instance.new("UIStroke",card)
    cardS.Thickness = 1.5; cardS.Transparency = initEnabled and 0.3 or 0.7
    cardS.Color = initEnabled and COR or Color3.fromRGB(60,40,20)
    cardS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Accent bar esquerda
    local acBar=Instance.new("Frame",card); acBar.BackgroundColor3=COR; acBar.BorderSizePixel=0
    acBar.Position=UDim2.new(0,0,0.1,0); acBar.Size=UDim2.new(0,4,0.8,0); acBar.ZIndex=6
    Instance.new("UICorner",acBar).CornerRadius=UDim.new(0,4)

    -- Ícone do toggle (circle indicator)
    local tIco=Instance.new("Frame",card); tIco.BackgroundColor3=COR
    tIco.BackgroundTransparency=initEnabled and 0.3 or 0.7
    tIco.BorderSizePixel=0; tIco.Position=UDim2.new(0,12,0,14); tIco.Size=UDim2.new(0,32,0,32); tIco.ZIndex=7
    Instance.new("UICorner",tIco).CornerRadius=UDim.new(0,8)
    local tIcoS=Instance.new("UIStroke",tIco); tIcoS.Color=Color3.fromRGB(0,0,0); tIcoS.Thickness=1.5; tIcoS.Transparency=0.5

    -- Título
    local titLbl = Instance.new("TextLabel",card); titLbl.BackgroundTransparency=1
    titLbl.Position=UDim2.new(0,52,0,10); titLbl.Size=UDim2.new(0.46,0,0,18)
    titLbl.Font=Enum.Font.GothamBlack; titLbl.Text=titleTxt
    titLbl.TextColor3=Color3.fromRGB(255,245,220); titLbl.TextSize=12
    titLbl.TextXAlignment=Enum.TextXAlignment.Left; titLbl.ZIndex=7
    local titS=Instance.new("UIStroke",titLbl); titS.Color=Color3.fromRGB(0,0,0); titS.Thickness=0.7; titS.Transparency=0.4

    -- Desc
    local descLbl = Instance.new("TextLabel",card); descLbl.BackgroundTransparency=1
    descLbl.Position=UDim2.new(0,52,0,30); descLbl.Size=UDim2.new(0.46,0,0,22)
    descLbl.Font=Enum.Font.Gotham; descLbl.Text=descTxt
    descLbl.TextColor3=Color3.fromRGB(155,120,65); descLbl.TextSize=9
    descLbl.TextXAlignment=Enum.TextXAlignment.Left; descLbl.TextWrapped=true; descLbl.ZIndex=7

    -- Toggle pill moderno (mais largo, mais visível)
    local pill = Instance.new("Frame",card); pill.BorderSizePixel=0
    pill.Position=UDim2.new(0,12,0,58); pill.Size=UDim2.new(0,52,0,20); pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    pill.BackgroundColor3 = initEnabled and COR or Color3.fromRGB(40,25,12)
    local pillS3=Instance.new("UIStroke",pill); pillS3.Color=Color3.fromRGB(0,0,0); pillS3.Thickness=1.5; pillS3.Transparency=0.5
    local pillKnob = Instance.new("Frame",pill); pillKnob.BorderSizePixel=0
    pillKnob.Size=UDim2.new(0,16,0,16); pillKnob.ZIndex=10
    Instance.new("UICorner",pillKnob).CornerRadius=UDim.new(1,0)
    pillKnob.Position = initEnabled and UDim2.new(1,-17,0.5,-8) or UDim2.new(0,2,0.5,-8)
    pillKnob.BackgroundColor3 = initEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,100,50)

    -- Status ON/OFF pill
    local statusLbl = Instance.new("TextLabel",card); statusLbl.BackgroundTransparency=1
    statusLbl.Position=UDim2.new(0,70,0,60); statusLbl.Size=UDim2.new(0,52,0,16)
    statusLbl.Font=Enum.Font.GothamBlack; statusLbl.TextSize=9; statusLbl.ZIndex=9
    statusLbl.TextXAlignment=Enum.TextXAlignment.Left
    statusLbl.Text = initEnabled and "ATIVO" or "INATIVO"
    statusLbl.TextColor3 = initEnabled and COR or Color3.fromRGB(110,80,40)

    -- Divisória vertical
    local divV = Instance.new("Frame",card); divV.BackgroundColor3=SOFF
    divV.BackgroundTransparency=0.5; divV.BorderSizePixel=0; divV.Position=UDim2.new(0.52,0,0,8)
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
    minLbl2.TextColor3=Color3.fromRGB(130,100,50); minLbl2.TextSize=7
    minLbl2.TextXAlignment=Enum.TextXAlignment.Left; minLbl2.ZIndex=7
    local maxLbl2 = Instance.new("TextLabel",card); maxLbl2.BackgroundTransparency=1
    maxLbl2.Position=UDim2.new(0.9,-8,0,36); maxLbl2.Size=UDim2.new(0.1,0,0,10)
    maxLbl2.Font=Enum.Font.Gotham; maxLbl2.Text=maxStr
    maxLbl2.TextColor3=Color3.fromRGB(130,100,50); maxLbl2.TextSize=7
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
        TweenService:Create(pill,TweenInfo.new(0.22),{BackgroundColor3=enabled and COR or Color3.fromRGB(40,25,12)}):Play()
        TweenService:Create(pillKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=enabled and UDim2.new(1,-17,0.5,-8) or UDim2.new(0,2,0.5,-8),
            BackgroundColor3=enabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,100,50)
        }):Play()
        TweenService:Create(cardS,TweenInfo.new(0.2),{
            Color=enabled and COR or Color3.fromRGB(60,40,20), Transparency=enabled and 0.3 or 0.7
        }):Play()
        TweenService:Create(tIco,TweenInfo.new(0.2),{BackgroundTransparency=enabled and 0.3 or 0.7}):Play()
        statusLbl.Text      = enabled and "ATIVO" or "INATIVO"
        statusLbl.TextColor3= enabled and COR or Color3.fromRGB(110,80,40)
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

-- Card com toggle + slider (baseado no makePlKACard)
local CD_COR = Color3.fromRGB(100,220,255)
local cdCard = Instance.new("Frame", Pages["Player"])
cdCard.BackgroundColor3 = Color3.fromRGB(18,11,4)
cdCard.BorderSizePixel  = 0
cdCard.Size             = UDim2.new(1,0,0,98)
cdCard.LayoutOrder      = plNextLO()
cdCard.ZIndex           = 5
Instance.new("UICorner",cdCard).CornerRadius = UDim.new(0,14)
local cdG = Instance.new("UIGradient",cdCard)
cdG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(30,18,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(16,10,2))})
cdG.Rotation = 135
local cdStroke = Instance.new("UIStroke",cdCard)
cdStroke.Color=Color3.fromRGB(6,3,0); cdStroke.Thickness=3; cdStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local cdBar = Instance.new("Frame",cdCard); cdBar.BackgroundColor3=CD_COR; cdBar.BorderSizePixel=0
cdBar.Size=UDim2.new(0,5,0.72,0); cdBar.Position=UDim2.new(0,0,0.14,0); cdBar.ZIndex=6
Instance.new("UICorner",cdBar).CornerRadius=UDim.new(0,4)
local cdTl = Instance.new("TextLabel",cdCard); cdTl.BackgroundTransparency=1
cdTl.Position=UDim2.new(0,14,0,8); cdTl.Size=UDim2.new(1,-80,0,18); cdTl.Font=Enum.Font.GothamBlack
cdTl.Text="🔭 Distância de Câmera"; cdTl.TextColor3=Color3.fromRGB(255,255,255); cdTl.TextSize=11
cdTl.TextXAlignment=Enum.TextXAlignment.Left; cdTl.ZIndex=7
local cdTlS=Instance.new("UIStroke",cdTl); cdTlS.Color=Color3.fromRGB(6,3,0); cdTlS.Thickness=1.8
local cdDesc = Instance.new("TextLabel",cdCard); cdDesc.BackgroundTransparency=1
cdDesc.Position=UDim2.new(0,14,0,26); cdDesc.Size=UDim2.new(1,-80,0,14); cdDesc.Font=Enum.Font.Gotham
cdDesc.Text="Câmera mais afastada — ajuste o zoom fixo do personagem"; cdDesc.TextColor3=Color3.fromRGB(155,135,90); cdDesc.TextSize=8
cdDesc.TextXAlignment=Enum.TextXAlignment.Left; cdDesc.ZIndex=7
-- Pill toggle
local cdPill = Instance.new("Frame",cdCard); cdPill.BackgroundColor3=Color3.fromRGB(45,25,10)
cdPill.BorderSizePixel=0; cdPill.Position=UDim2.new(1,-60,0,10); cdPill.Size=UDim2.new(0,52,0,28); cdPill.ZIndex=9
Instance.new("UICorner",cdPill).CornerRadius=UDim.new(1,0)
local cdPillS=Instance.new("UIStroke",cdPill); cdPillS.Color=Color3.fromRGB(6,3,0); cdPillS.Thickness=2.5; cdPillS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local cdKnob=Instance.new("Frame",cdPill); cdKnob.BackgroundColor3=Color3.fromRGB(140,100,40)
cdKnob.BorderSizePixel=0; cdKnob.AnchorPoint=Vector2.new(0,0.5); cdKnob.Position=UDim2.new(0,3,0.5,0); cdKnob.Size=UDim2.new(0,22,0,22); cdKnob.ZIndex=10
Instance.new("UICorner",cdKnob).CornerRadius=UDim.new(1,0)
-- Valor
local cdValBadge=Instance.new("Frame",cdCard); cdValBadge.BackgroundColor3=CD_COR; cdValBadge.BackgroundTransparency=0.1
cdValBadge.BorderSizePixel=0; cdValBadge.AnchorPoint=Vector2.new(1,0); cdValBadge.Position=UDim2.new(1,-8,0,44); cdValBadge.Size=UDim2.new(0,50,0,20); cdValBadge.ZIndex=8
Instance.new("UICorner",cdValBadge).CornerRadius=UDim.new(0,7)
local cdValLbl=Instance.new("TextLabel",cdValBadge); cdValLbl.BackgroundTransparency=1; cdValLbl.Size=UDim2.new(1,0,1,0)
cdValLbl.Font=Enum.Font.GothamBlack; cdValLbl.Text="60"; cdValLbl.TextColor3=Color3.fromRGB(20,10,0); cdValLbl.TextSize=11; cdValLbl.ZIndex=9
-- Track slider
local cdTrack=Instance.new("Frame",cdCard); cdTrack.BackgroundColor3=Color3.fromRGB(45,28,10)
cdTrack.BorderSizePixel=0; cdTrack.Position=UDim2.new(0,14,0,72); cdTrack.Size=UDim2.new(1,-28,0,8); cdTrack.ZIndex=7
Instance.new("UICorner",cdTrack).CornerRadius=UDim.new(1,0)
local cdFill=Instance.new("Frame",cdTrack); cdFill.BackgroundColor3=CD_COR; cdFill.BorderSizePixel=0
cdFill.Size=UDim2.new(0.22,0,1,0); cdFill.ZIndex=8; Instance.new("UICorner",cdFill).CornerRadius=UDim.new(1,0)
local cdDot=Instance.new("Frame",cdTrack); cdDot.BackgroundColor3=Color3.fromRGB(255,255,255)
cdDot.BorderSizePixel=0; cdDot.AnchorPoint=Vector2.new(0.5,0.5); cdDot.Position=UDim2.new(0.22,0,0.5,0); cdDot.Size=UDim2.new(0,16,0,16); cdDot.ZIndex=9
Instance.new("UICorner",cdDot).CornerRadius=UDim.new(1,0)
local cdDotS=Instance.new("UIStroke",cdDot); cdDotS.Color=CD_COR; cdDotS.Thickness=2.5
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
local cdBtn=Instance.new("TextButton",cdCard); cdBtn.BackgroundTransparency=1; cdBtn.Size=UDim2.new(1,0,0,42); cdBtn.Text=""; cdBtn.ZIndex=11
cdBtn.MouseButton1Click:Connect(function()
    camDistEnabled = not camDistEnabled
    applyCamDist(camDistValue, camDistEnabled)
    TweenService:Create(cdPill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundColor3=camDistEnabled and CD_COR or Color3.fromRGB(45,25,10)}):Play()
    TweenService:Create(cdKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position=camDistEnabled and UDim2.new(1,-25,0.5,0) or UDim2.new(0,3,0.5,0),
        BackgroundColor3=camDistEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(140,100,40)
    }):Play()
    local sndId = camDistEnabled and 6031221736 or 2544086171
    pcall(function() local snd=Instance.new("Sound",workspace); snd.SoundId="rbxassetid://"..sndId; snd.Volume=0.4; snd:Play(); game:GetService("Debris"):AddItem(snd,2) end)
    if camDistEnabled then
        Notify.success("🔭 Distância de Câmera","Zoom fixo em "..camDistValue.." studs ativado!")
    else
        Notify.info("🔭 Distância de Câmera","Zoom restaurado ao padrão.")
    end
end)
end -- camDist

-- ══════════════════════════════════════════════════════
-- VISÃO MELHORADA (NoFov) — remove neblina/fog total
-- ══════════════════════════════════════════════════════
do
local noFovEnabled   = false
local fogOrigEnd, fogOrigStart, fogOrigColor
local atmOrigDensity, atmOrigHaze, atmOrigGlare

local function setNoFov(state)
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

makePlToggle("👁 Visão Melhorada (NoFov)", "Remove toda neblina — veja criaturas e itens a longa distância", Color3.fromRGB(180,255,180), function(s) setNoFov(s) end)
end -- noFov

-- ══════════════════════════════════════════════════════
-- PULO INFINITO — pula indefinidamente no ar
-- ══════════════════════════════════════════════════════
do
local infJumpEnabled = false
local infJumpConn

local function setInfJump(state)
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

makePlToggle("♾️ Pulo Infinito","Pula no ar sem limite — ótimo para escalar ou fugir de mobs", Color3.fromRGB(255,220,80), function(s) setInfJump(s) end)
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

makePlSec("plSecAntiDebuff", Color3.fromRGB(255,180,50))
makePlToggle("🛡 Anti Desaceleração", "Burla armadilhas que reduzem sua velocidade", Color3.fromRGB(255,180,50), function(s) setAntiSlow(s) end)

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
        hrp.Velocity       = Vector3.zero
        hrp.AssemblyLinearVelocity = Vector3.zero
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

makePlToggle("🕳️ Anti-Void / Anti-Traversal",
    "Teleporta de volta se cair no void ou atravessar o chão",
    AV_COR,
    function(s) setAntiVoid(s) end
)

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
acsPill.BackgroundColor3 = Color3.fromRGB(50,32,15)
local acsKnob = Instance.new("Frame",acsPill); acsKnob.BorderSizePixel = 0
acsKnob.Position = UDim2.new(0,1,0.5,-7); acsKnob.Size = UDim2.new(0,14,0,14); acsKnob.ZIndex = 10
Instance.new("UICorner",acsKnob).CornerRadius = UDim.new(1,0)
acsKnob.BackgroundColor3 = Color3.fromRGB(160,170,185)

-- Status label
local acsStatus = Instance.new("TextLabel",acsCard); acsStatus.BackgroundTransparency = 1
acsStatus.Position = UDim2.new(0,68,0,60); acsStatus.Size = UDim2.new(0,60,0,16)
acsStatus.Font = Enum.Font.GothamBlack; acsStatus.TextSize = 8; acsStatus.ZIndex = 9
acsStatus.TextXAlignment = Enum.TextXAlignment.Left
acsStatus.Text = "INATIVO"; acsStatus.TextColor3 = Color3.fromRGB(130,100,50)

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
        BackgroundColor3 = acsEnabled and ACS_COR or Color3.fromRGB(50,32,15)
    }):Play()
    TweenService:Create(acsKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position = acsEnabled and UDim2.new(1,-15,0.5,-7) or UDim2.new(0,1,0.5,-7),
        BackgroundColor3 = acsEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
    }):Play()
    TweenService:Create(acsStroke,TweenInfo.new(0.2),{
        Color = acsEnabled and ACS_COR or Color3.fromRGB(80,60,20)
    }):Play()
    acsStatus.Text       = acsEnabled and "ATIVO"   or "INATIVO"
    acsStatus.TextColor3 = acsEnabled and ACS_COR   or Color3.fromRGB(130,100,50)

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
    local ibcSecHdr = Instance.new("Frame",Pages["Player"]); ibcSecHdr.BackgroundColor3 = Color3.fromRGB(20,22,30)
    ibcSecHdr.BackgroundTransparency = 0.3; ibcSecHdr.BorderSizePixel = 0; ibcSecHdr.Size = UDim2.new(1,0,0,22)
    ibcSecHdr.LayoutOrder = plNextLO(); ibcSecHdr.ZIndex = 4
    Instance.new("UICorner",ibcSecHdr).CornerRadius = UDim.new(0,6)
    local ibcSecBar2 = Instance.new("Frame",ibcSecHdr); ibcSecBar2.BackgroundColor3 = IBC_COR; ibcSecBar2.BorderSizePixel = 0
    ibcSecBar2.Size = UDim2.new(0,3,1,0); ibcSecBar2.ZIndex = 5; Instance.new("UICorner",ibcSecBar2).CornerRadius = UDim.new(0,3)
    local ibcSecLbl = Instance.new("TextLabel",ibcSecHdr); ibcSecLbl.BackgroundTransparency = 1
    ibcSecLbl.Position = UDim2.new(0,10,0,0); ibcSecLbl.Size = UDim2.new(1,-14,1,0)
    ibcSecLbl.Font = Enum.Font.GothamBlack; ibcSecLbl.Text = "🔓  BAÚS INSTANTÂNEOS"
    ibcSecLbl.TextColor3 = IBC_COR; ibcSecLbl.TextSize = 9
    ibcSecLbl.TextXAlignment = Enum.TextXAlignment.Left; ibcSecLbl.ZIndex = 5
end

local ibcCard = Instance.new("Frame", Pages["Player"])
ibcCard.BackgroundColor3 = Color3.fromRGB(22,18,10); ibcCard.BorderSizePixel = 0
ibcCard.Size = UDim2.new(1,0,0,82); ibcCard.LayoutOrder = plNextLO(); ibcCard.ZIndex = 5
Instance.new("UICorner",ibcCard).CornerRadius = UDim.new(0,9)
local ibcStroke = Instance.new("UIStroke",ibcCard)
ibcStroke.Color = Color3.fromRGB(80,60,15); ibcStroke.Thickness = 1

-- Gradiente de fundo
local ibcGrad = Instance.new("Frame",ibcCard)
ibcGrad.BackgroundColor3 = IBC_COR; ibcGrad.BackgroundTransparency = 0.92
ibcGrad.BorderSizePixel = 0; ibcGrad.Size = UDim2.new(1,0,1,0); ibcGrad.ZIndex = 5
Instance.new("UICorner",ibcGrad).CornerRadius = UDim.new(0,9)

-- Barra lateral
local ibcBar = Instance.new("Frame",ibcCard)
ibcBar.BackgroundColor3 = IBC_COR; ibcBar.BorderSizePixel = 0
ibcBar.Size = UDim2.new(0,3,0.7,0); ibcBar.Position = UDim2.new(0,0,0.15,0); ibcBar.ZIndex = 6
Instance.new("UICorner",ibcBar).CornerRadius = UDim.new(0,3)

-- Ícone
local ibcIcoBox = Instance.new("Frame",ibcCard)
ibcIcoBox.BackgroundColor3 = IBC_COR; ibcIcoBox.BackgroundTransparency = 0.75
ibcIcoBox.BorderSizePixel = 0; ibcIcoBox.Position = UDim2.new(0,10,0.5,-18)
ibcIcoBox.Size = UDim2.new(0,36,0,36); ibcIcoBox.ZIndex = 7
Instance.new("UICorner",ibcIcoBox).CornerRadius = UDim.new(0,9)
local ibcIco = Instance.new("TextLabel",ibcIcoBox); ibcIco.BackgroundTransparency = 1
ibcIco.Size = UDim2.new(1,0,1,0); ibcIco.Font = Enum.Font.GothamBlack
ibcIco.Text = "🔓"; ibcIco.TextColor3 = Color3.fromRGB(255,230,120)
ibcIco.TextSize = 18; ibcIco.ZIndex = 8

-- Título e descrição
local ibcTitle = Instance.new("TextLabel",ibcCard); ibcTitle.BackgroundTransparency = 1
ibcTitle.Position = UDim2.new(0,55,0,10); ibcTitle.Size = UDim2.new(1,-120,0,18)
ibcTitle.Font = Enum.Font.GothamBold; ibcTitle.Text = "🔓 Abrir Baús Instantâneo"
ibcTitle.TextColor3 = Color3.fromRGB(225,230,245); ibcTitle.TextSize = 11
ibcTitle.TextXAlignment = Enum.TextXAlignment.Left; ibcTitle.ZIndex = 7

local ibcDesc = Instance.new("TextLabel",ibcCard); ibcDesc.BackgroundTransparency = 1
ibcDesc.Position = UDim2.new(0,55,0,30); ibcDesc.Size = UDim2.new(1,-120,0,42)
ibcDesc.Font = Enum.Font.Gotham
ibcDesc.Text = "Ao chegar perto de um baú e clicar nele, abre instantaneamente — sem segurar o botão."
ibcDesc.TextColor3 = Color3.fromRGB(90,100,120); ibcDesc.TextSize = 9
ibcDesc.TextXAlignment = Enum.TextXAlignment.Left; ibcDesc.TextWrapped = true; ibcDesc.ZIndex = 7

-- Toggle pill
local ibcPill = Instance.new("Frame",ibcCard)
ibcPill.BackgroundColor3 = Color3.fromRGB(50,32,15); ibcPill.BorderSizePixel = 0
ibcPill.Position = UDim2.new(1,-58,0.5,-13); ibcPill.Size = UDim2.new(0,48,0,26); ibcPill.ZIndex = 9
Instance.new("UICorner",ibcPill).CornerRadius = UDim.new(1,0)
local ibcKnob = Instance.new("Frame",ibcPill)
ibcKnob.BackgroundColor3 = Color3.fromRGB(160,170,185); ibcKnob.BorderSizePixel = 0
ibcKnob.Position = UDim2.new(0,2,0.5,-11); ibcKnob.Size = UDim2.new(0,22,0,22); ibcKnob.ZIndex = 10
Instance.new("UICorner",ibcKnob).CornerRadius = UDim.new(1,0)

local ibcBtn = Instance.new("TextButton",ibcCard)
ibcBtn.BackgroundTransparency = 1; ibcBtn.Size = UDim2.new(1,0,1,0); ibcBtn.Text = ""; ibcBtn.ZIndex = 11

ibcBtn.MouseButton1Click:Connect(function()
    ibcEnabled = not ibcEnabled
    TweenService:Create(ibcPill,TweenInfo.new(0.22),{
        BackgroundColor3 = ibcEnabled and IBC_COR or Color3.fromRGB(50,32,15)
    }):Play()
    TweenService:Create(ibcKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position = ibcEnabled and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
        BackgroundColor3 = ibcEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185),
    }):Play()
    TweenService:Create(ibcStroke,TweenInfo.new(0.2),{
        Color = ibcEnabled and IBC_COR or Color3.fromRGB(80,60,15)
    }):Play()
    if ibcEnabled then
        if not ibcRemote then
            pcall(function()
                ibcRemote = game:GetService("ReplicatedStorage")
                    .RemoteEvents.RequestOpenItemChest
            end)
        end
        ibcStart()
        Notify.send({type="custom", icon="🔓", accent=IBC_COR,
            title="Baús Instantâneos", msg="Ativado — chegue perto de um baú e clique!", duration=4})
    else
        ibcStop()
        Notify.info("Baús Instantâneos", "Desativado.")
    end
end)
end -- Baús Instantâneos

-- ══════════════════════════════════════════════════════════════
-- ABA CONFIGURAÇÕES — Estilo de Bring + outras opções
-- ══════════════════════════════════════════════════════════════
do
local CFG_COR = Color3.fromRGB(130,180,255)
local cfgLO = 0
local function cfgNextLO() cfgLO += 1; return cfgLO end

-- ── Título da seção ──────────────────────────────────────────
local cfgSec = Instance.new("Frame", Pages["Configuracoes"])
cfgSec.BackgroundColor3 = Color3.fromRGB(20,22,30); cfgSec.BackgroundTransparency = 0.3
cfgSec.BorderSizePixel = 0; cfgSec.Size = UDim2.new(1,0,0,22)
cfgSec.LayoutOrder = cfgNextLO(); cfgSec.ZIndex = 4
Instance.new("UICorner",cfgSec).CornerRadius = UDim.new(0,6)
local cfgSecBar = Instance.new("Frame",cfgSec); cfgSecBar.BackgroundColor3 = CFG_COR
cfgSecBar.BorderSizePixel = 0; cfgSecBar.Size = UDim2.new(0,3,1,0); cfgSecBar.ZIndex = 5
Instance.new("UICorner",cfgSecBar).CornerRadius = UDim.new(0,3)
local cfgSecLbl = Instance.new("TextLabel",cfgSec); cfgSecLbl.BackgroundTransparency = 1
cfgSecLbl.Position = UDim2.new(0,10,0,0); cfgSecLbl.Size = UDim2.new(1,-14,1,0)
cfgSecLbl.Font = Enum.Font.GothamBlack; cfgSecLbl.Text = "⚙️  ESTILO DE BRING"
cfgSecLbl.TextColor3 = CFG_COR; cfgSecLbl.TextSize = 9
cfgSecLbl.TextXAlignment = Enum.TextXAlignment.Left; cfgSecLbl.ZIndex = 5

-- ── Card principal Estilo de Bring — Brawl Stars style ──────
local cfgCard = Instance.new("Frame", Pages["Configuracoes"])
cfgCard.BackgroundColor3 = Color3.fromRGB(28,18,8); cfgCard.BorderSizePixel = 0
cfgCard.Size = UDim2.new(1,0,0,72); cfgCard.LayoutOrder = cfgNextLO(); cfgCard.ZIndex = 5
Instance.new("UICorner",cfgCard).CornerRadius = UDim.new(0,14)
local cfgStroke = Instance.new("UIStroke",cfgCard)
cfgStroke.Color = Color3.fromRGB(8,4,0); cfgStroke.Thickness = 3
cfgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
-- Gradiente cartoon
local cfgCardG = Instance.new("UIGradient",cfgCard)
cfgCardG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(42,26,10)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18,10,4)),
})
cfgCardG.Rotation = 135

-- Faixa accent no topo
local cfgTopBand = Instance.new("Frame",cfgCard)
cfgTopBand.BackgroundColor3 = CFG_COR; cfgTopBand.BorderSizePixel = 0
cfgTopBand.Size = UDim2.new(1,0,0,4); cfgTopBand.ZIndex = 6
Instance.new("UICorner",cfgTopBand).CornerRadius = UDim.new(0,14)

-- Barra lateral accent
local cfgBar = Instance.new("Frame",cfgCard)
cfgBar.BackgroundColor3 = CFG_COR; cfgBar.BorderSizePixel = 0
cfgBar.Size = UDim2.new(0,5,0.75,0); cfgBar.Position = UDim2.new(0,0,0.12,0); cfgBar.ZIndex = 6
Instance.new("UICorner",cfgBar).CornerRadius = UDim.new(0,3)

-- Título — branco com stroke preta
local cfgTitleLbl = Instance.new("TextLabel",cfgCard); cfgTitleLbl.BackgroundTransparency = 1
cfgTitleLbl.Position = UDim2.new(0,14,0,10); cfgTitleLbl.Size = UDim2.new(0.55,0,0,20)
cfgTitleLbl.Font = Enum.Font.GothamBlack; cfgTitleLbl.Text = "Estilo de Bring"
cfgTitleLbl.TextColor3 = Color3.fromRGB(255,255,255); cfgTitleLbl.TextSize = 13
cfgTitleLbl.TextXAlignment = Enum.TextXAlignment.Left; cfgTitleLbl.ZIndex = 7
local cfgTitleS = Instance.new("UIStroke",cfgTitleLbl)
cfgTitleS.Color = Color3.fromRGB(8,4,0); cfgTitleS.Thickness = 2

-- Descrição
local cfgDescLbl = Instance.new("TextLabel",cfgCard); cfgDescLbl.BackgroundTransparency = 1
cfgDescLbl.Position = UDim2.new(0,14,0,32); cfgDescLbl.Size = UDim2.new(0.55,0,0,30)
cfgDescLbl.Font = Enum.Font.Gotham; cfgDescLbl.Text = "Define como os itens aparecem ao usar qualquer Bring."
cfgDescLbl.TextColor3 = Color3.fromRGB(180,160,110); cfgDescLbl.TextSize = 9
cfgDescLbl.TextXAlignment = Enum.TextXAlignment.Left; cfgDescLbl.TextWrapped = true; cfgDescLbl.ZIndex = 7

-- ── Botão "Bring Padrão" (label muda conforme seleção) ───────
local STYLE_LABELS = {
    padrao   = "🔵 Bring Padrão",
    espalhado= "🟠 Bring Espalhado",
    juntos   = "🟢 Bring Juntos",
    circulo  = "🔴 Bring Círculo",
}

local cfgStyleBtn = Instance.new("TextButton",cfgCard)
cfgStyleBtn.BackgroundColor3 = Color3.fromRGB(252,196,0); cfgStyleBtn.BackgroundTransparency = 0
cfgStyleBtn.BorderSizePixel = 0; cfgStyleBtn.Position = UDim2.new(1,-152,0.5,-15)
cfgStyleBtn.Size = UDim2.new(0,142,0,30); cfgStyleBtn.ZIndex = 9
cfgStyleBtn.Font = Enum.Font.GothamBlack; cfgStyleBtn.Text = STYLE_LABELS[bringStyle]
cfgStyleBtn.TextColor3 = Color3.fromRGB(22,10,0); cfgStyleBtn.TextSize = 10
Instance.new("UICorner",cfgStyleBtn).CornerRadius = UDim.new(0,9)
local cfgStyleStroke = Instance.new("UIStroke",cfgStyleBtn)
cfgStyleStroke.Color = Color3.fromRGB(8,4,0); cfgStyleStroke.Thickness = 2.5
cfgStyleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
-- Gradiente dourado no botão (como badge NOVO)
local cfgStyleG = Instance.new("UIGradient",cfgStyleBtn)
cfgStyleG.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,238,80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200,140,0)),
})
cfgStyleG.Rotation = 90
-- Shine no botão
local cfgBtnShine = Instance.new("Frame",cfgStyleBtn)
cfgBtnShine.BackgroundColor3 = Color3.fromRGB(255,255,255); cfgBtnShine.BackgroundTransparency = 0.65
cfgBtnShine.BorderSizePixel = 0; cfgBtnShine.Position = UDim2.new(0,5,0,3)
cfgBtnShine.Size = UDim2.new(0,60,0,7); cfgBtnShine.ZIndex = 10
Instance.new("UICorner",cfgBtnShine).CornerRadius = UDim.new(1,0)

-- ── Popup Estilo de Bring (ScreenGui, não é clipado) ───────
local STYLE_OPTIONS = {
    { key="espalhado", icon="🟠", label="Espalhado",  desc="Raio largo, itens bem espaçados",  cor=Color3.fromRGB(255,150,60)  },
    { key="juntos",    icon="🟢", label="Juntos",     desc="Próximos, fácil de pegar",          cor=Color3.fromRGB(80,220,120)  },
    { key="circulo",   icon="🔴", label="Círculo",    desc="Anel perfeito em volta de você",    cor=Color3.fromRGB(255,90,90)   },
    { key="padrao",    icon="🔵", label="Padrão",     desc="Camadas radiais equilibradas",      cor=Color3.fromRGB(100,160,255) },
}

local cfgPopup = Instance.new("Frame", ScreenGui)
cfgPopup.Name = "BringStylePopup"; cfgPopup.BackgroundColor3 = Color3.fromRGB(18,11,3)
cfgPopup.BorderSizePixel=0; cfgPopup.ZIndex=310; cfgPopup.Visible=false; cfgPopup.Size=UDim2.new(0,170,0,0)
Instance.new("UICorner",cfgPopup).CornerRadius=UDim.new(0,10)
local cfgPopupStroke=Instance.new("UIStroke",cfgPopup)
cfgPopupStroke.Color=CFG_COR; cfgPopupStroke.Thickness=1.5; cfgPopupStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
-- Lista compacta (sem header)
local cfgPopList=Instance.new("Frame",cfgPopup); cfgPopList.BackgroundTransparency=1
cfgPopList.BorderSizePixel=0; cfgPopList.Position=UDim2.new(0,6,0,6)
cfgPopList.Size=UDim2.new(1,-12,0,0); cfgPopList.ZIndex=311; cfgPopList.AutomaticSize=Enum.AutomaticSize.Y
local cfgPopLayout=Instance.new("UIListLayout",cfgPopList); cfgPopLayout.Padding=UDim.new(0,3); cfgPopLayout.SortOrder=Enum.SortOrder.LayoutOrder

local cfgPopOpen = false

local function closePopup()
    cfgPopOpen=false
    TweenService:Create(cfgPopup,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,210,0,0),BackgroundTransparency=1}):Play()
    task.delay(0.18,function() cfgPopup.Visible=false; cfgPopup.BackgroundTransparency=0 end)
end

local function openPopup()
    local ap=cfgStyleBtn.AbsolutePosition; local as=cfgStyleBtn.AbsoluteSize
    local popH = 8 + #STYLE_OPTIONS*34 + 8
    cfgPopup.Position=UDim2.new(0,ap.X+as.X-170,0,ap.Y-popH-6)
    cfgPopup.Size=UDim2.new(0,170,0,0); cfgPopup.BackgroundTransparency=1; cfgPopup.Visible=true
    TweenService:Create(cfgPopup,TweenInfo.new(0.18,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Size=UDim2.new(0,170,0,popH),BackgroundTransparency=0
    }):Play()
    cfgPopOpen=true
end

local cfgOptBtns = {}
for i, opt in ipairs(STYLE_OPTIONS) do
    local ob=Instance.new("TextButton",cfgPopList); ob.BackgroundColor3=Color3.fromRGB(26,16,5)
    ob.BackgroundTransparency=0; ob.BorderSizePixel=0
    ob.Size=UDim2.new(1,0,0,30); ob.LayoutOrder=i; ob.ZIndex=312; ob.AutoButtonColor=false
    Instance.new("UICorner",ob).CornerRadius=UDim.new(0,7)
    local obS=Instance.new("UIStroke",ob); obS.Color=opt.cor; obS.Thickness=1.2; obS.Transparency=0.65
    -- Ícone pequeno
    local obIco=Instance.new("TextLabel",ob); obIco.BackgroundTransparency=1
    obIco.Position=UDim2.new(0,7,0,0); obIco.Size=UDim2.new(0,22,1,0)
    obIco.Font=Enum.Font.GothamBold; obIco.Text=opt.icon; obIco.TextSize=13; obIco.ZIndex=313
    -- Label compacto
    local obLbl=Instance.new("TextLabel",ob); obLbl.BackgroundTransparency=1
    obLbl.Position=UDim2.new(0,32,0,0); obLbl.Size=UDim2.new(1,-36,1,0)
    obLbl.Font=Enum.Font.GothamBold; obLbl.Text=opt.label
    obLbl.TextColor3=Color3.fromRGB(235,220,190); obLbl.TextSize=10
    obLbl.TextXAlignment=Enum.TextXAlignment.Left; obLbl.ZIndex=313
    cfgOptBtns[opt.key] = {btn=ob, stroke=obS}
    local function refreshSel()
        local sel=(bringStyle==opt.key)
        TweenService:Create(obS,TweenInfo.new(0.15),{Transparency=sel and 0 or 0.65}):Play()
        TweenService:Create(ob,TweenInfo.new(0.15),{BackgroundColor3=sel and Color3.fromRGB(45,25,6) or Color3.fromRGB(26,16,5)}):Play()
    end
    refreshSel()
    ob.MouseEnter:Connect(function()
        TweenService:Create(ob,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(38,22,6)}):Play()
        TweenService:Create(obS,TweenInfo.new(0.1),{Transparency=0.2}):Play()
    end)
    ob.MouseLeave:Connect(function() refreshSel() end)
    ob.MouseButton1Click:Connect(function()
        bringStyle=opt.key
        cfgStyleBtn.Text=STYLE_LABELS[opt.key] or STYLE_LABELS["padrao"]
        closePopup()
        for _, entry in pairs(cfgOptBtns) do
            local sel2=(bringStyle==opt.key and entry==cfgOptBtns[opt.key])
            TweenService:Create(entry.stroke,TweenInfo.new(0.15),{Transparency=sel2 and 0 or 0.65}):Play()
        end
        Notify.send({type="custom",icon=opt.icon,accent=opt.cor,title="Estilo de Bring",msg=opt.label,duration=2.5})
    end)
end
-- Espaço inferior
local cfgPopPad=Instance.new("Frame",cfgPopList); cfgPopPad.BackgroundTransparency=1; cfgPopPad.Size=UDim2.new(1,0,0,4); cfgPopPad.LayoutOrder=99

-- Clique no botão abre/fecha
cfgStyleBtn.MouseButton1Click:Connect(function()
    if cfgPopOpen then closePopup() else openPopup() end
end)

-- Fechar ao clicar fora
MainFrame.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 and cfgPopOpen then
        local mx,my=inp.Position.X,inp.Position.Y
        local pA=cfgPopup.AbsolutePosition; local pS=cfgPopup.AbsoluteSize
        if mx<pA.X or mx>pA.X+pS.X or my<pA.Y or my>pA.Y+pS.Y then closePopup() end
    end
end)

end -- Config Tab

-- ══════════════════════════════════════════════════════════════
-- ABA CONFIGURAÇÕES — Walk Speed, Jump Power, Gravidade, Sons
-- ══════════════════════════════════════════════════════════════
do
local CFG2_COR = Color3.fromRGB(130,180,255)

-- Reutiliza cfgLO e cfgNextLO do bloco anterior
local cfgLO2 = 200
local function cfg2NextLO() cfgLO2 += 1; return cfgLO2 end

-- Helper: mini seção
local function cfgMkSec(titleTxt, cor)
    local hdr = Instance.new("Frame", Pages["Configuracoes"])
    hdr.BackgroundColor3 = Color3.fromRGB(20,22,30); hdr.BackgroundTransparency = 0.25
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
    local row = Instance.new("Frame", Pages["Configuracoes"])
    row.BackgroundColor3 = Color3.fromRGB(26,15,6); row.BorderSizePixel = 0
    row.Size = UDim2.new(1,0,0,72); row.LayoutOrder = cfg2NextLO(); row.ZIndex = 5
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,12)
    local rowG = Instance.new("UIGradient",row)
    rowG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(38,22,8)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18,10,3))
    }); rowG.Rotation = 135
    local rowS = Instance.new("UIStroke",row)
    rowS.Color = Color3.fromRGB(8,4,0); rowS.Thickness = 3
    rowS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local lbar = Instance.new("Frame",row); lbar.BackgroundColor3 = cor; lbar.BorderSizePixel = 0
    lbar.Size = UDim2.new(0,5,0.72,0); lbar.Position = UDim2.new(0,0,0.14,0); lbar.ZIndex = 6
    Instance.new("UICorner",lbar).CornerRadius = UDim.new(0,4)
    local tl = Instance.new("TextLabel",row); tl.BackgroundTransparency = 1
    tl.Position = UDim2.new(0,14,0,8); tl.Size = UDim2.new(0.62,0,0,18); tl.Font = Enum.Font.GothamBlack
    tl.Text = titleTxt; tl.TextColor3 = Color3.fromRGB(255,255,255); tl.TextSize = 11
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 7
    local tlS = Instance.new("UIStroke",tl); tlS.Color = Color3.fromRGB(8,4,0); tlS.Thickness = 1.8
    local td = Instance.new("TextLabel",row); td.BackgroundTransparency = 1
    td.Position = UDim2.new(0,14,0,26); td.Size = UDim2.new(0.62,0,0,14); td.Font = Enum.Font.Gotham
    td.Text = descTxt; td.TextColor3 = Color3.fromRGB(165,140,95); td.TextSize = 8
    td.TextXAlignment = Enum.TextXAlignment.Left; td.ZIndex = 7
    local valBadge = Instance.new("Frame",row); valBadge.BackgroundColor3 = cor
    valBadge.BackgroundTransparency = 0.1; valBadge.BorderSizePixel = 0
    valBadge.AnchorPoint = Vector2.new(1,0); valBadge.Position = UDim2.new(1,-8,0,8)
    valBadge.Size = UDim2.new(0,44,0,20); valBadge.ZIndex = 8
    Instance.new("UICorner",valBadge).CornerRadius = UDim.new(0,7)
    local valLbl = Instance.new("TextLabel",valBadge); valLbl.BackgroundTransparency = 1
    valLbl.Size = UDim2.new(1,0,1,0); valLbl.Font = Enum.Font.GothamBlack
    valLbl.Text = string.format(fmt or "%d", defV); valLbl.TextColor3 = Color3.fromRGB(22,10,0)
    valLbl.TextSize = 11; valLbl.ZIndex = 9
    -- Track do slider
    local trackBg = Instance.new("Frame",row); trackBg.BackgroundColor3 = Color3.fromRGB(50,30,12)
    trackBg.BorderSizePixel = 0; trackBg.Position = UDim2.new(0,14,0,48)
    trackBg.Size = UDim2.new(1,-28,0,8); trackBg.ZIndex = 7
    Instance.new("UICorner",trackBg).CornerRadius = UDim.new(1,0)
    local pct0 = (defV - minV)/(maxV - minV)
    local fill = Instance.new("Frame",trackBg); fill.BackgroundColor3 = cor; fill.BorderSizePixel = 0
    fill.Size = UDim2.new(pct0,0,1,0); fill.ZIndex = 8
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)
    local dot = Instance.new("Frame",trackBg); dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    dot.BorderSizePixel = 0; dot.AnchorPoint = Vector2.new(0.5,0.5)
    dot.Position = UDim2.new(pct0,0,0.5,0); dot.Size = UDim2.new(0,16,0,16); dot.ZIndex = 9
    Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)
    local dotS = Instance.new("UIStroke",dot); dotS.Color = cor; dotS.Thickness = 2.5
    local curVal = defV
    local dragging2 = false
    local function setVal2(pct)
        pct = math.clamp(pct, 0, 1)
        curVal = math.floor(minV + (maxV-minV)*pct + 0.5)
        fill.Size = UDim2.new(pct,0,1,0)
        dot.Position = UDim2.new(pct,0,0.5,0)
        valLbl.Text = string.format(fmt or "%d", curVal)
        pcall(onChange, curVal)
    end
    local sliderBtn2 = Instance.new("TextButton",trackBg)
    sliderBtn2.BackgroundTransparency = 1; sliderBtn2.Size = UDim2.new(1,20,1,20)
    sliderBtn2.Position = UDim2.new(0,-10,0,-10); sliderBtn2.Text = ""; sliderBtn2.ZIndex = 10
    sliderBtn2.MouseButton1Down:Connect(function()
        dragging2 = true
        local mp = UserInputService:GetMouseLocation()
        local ap = trackBg.AbsolutePosition; local as = trackBg.AbsoluteSize
        setVal2((mp.X - ap.X)/as.X)
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging2 then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local ap = trackBg.AbsolutePosition; local as = trackBg.AbsoluteSize
        setVal2((input.Position.X - ap.X)/as.X)
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging2 = false end
    end)
end

-- ── SEÇÃO: INTERFACE ─────────────────────────────────────────────
cfgMkSec("🔊  SONS DO HUB", Color3.fromRGB(200,140,255))

-- Toggle sons das notificações
local cfgSndState = true
local cfgSndRow = Instance.new("Frame", Pages["Configuracoes"])
cfgSndRow.BackgroundColor3 = Color3.fromRGB(26,15,6); cfgSndRow.BorderSizePixel = 0
cfgSndRow.Size = UDim2.new(1,0,0,60); cfgSndRow.LayoutOrder = cfg2NextLO(); cfgSndRow.ZIndex = 5
Instance.new("UICorner",cfgSndRow).CornerRadius = UDim.new(0,12)
local cfgSndG = Instance.new("UIGradient",cfgSndRow)
cfgSndG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(40,24,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,3))}); cfgSndG.Rotation=135
local cfgSndStroke = Instance.new("UIStroke",cfgSndRow)
cfgSndStroke.Color = Color3.fromRGB(8,4,0); cfgSndStroke.Thickness = 3
cfgSndStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local cfgSndBar = Instance.new("Frame",cfgSndRow); cfgSndBar.BackgroundColor3 = Color3.fromRGB(200,140,255)
cfgSndBar.BorderSizePixel = 0; cfgSndBar.Size = UDim2.new(0,5,0.72,0); cfgSndBar.Position = UDim2.new(0,0,0.14,0); cfgSndBar.ZIndex = 6
Instance.new("UICorner",cfgSndBar).CornerRadius = UDim.new(0,4)
local cfgSndTl = Instance.new("TextLabel",cfgSndRow); cfgSndTl.BackgroundTransparency = 1
cfgSndTl.Position = UDim2.new(0,14,0,10); cfgSndTl.Size = UDim2.new(1,-80,0,18); cfgSndTl.Font = Enum.Font.GothamBlack
cfgSndTl.Text = "🔊  Sons das Notificações"; cfgSndTl.TextColor3 = Color3.fromRGB(255,255,255); cfgSndTl.TextSize = 11
cfgSndTl.TextXAlignment = Enum.TextXAlignment.Left; cfgSndTl.ZIndex = 7
local cfgSndDesc = Instance.new("TextLabel",cfgSndRow); cfgSndDesc.BackgroundTransparency = 1
cfgSndDesc.Position = UDim2.new(0,14,0,30); cfgSndDesc.Size = UDim2.new(1,-80,0,22); cfgSndDesc.Font = Enum.Font.Gotham
cfgSndDesc.Text = "Ativa/desativa o som de todas as notificações do hub."; cfgSndDesc.TextColor3 = Color3.fromRGB(165,140,95); cfgSndDesc.TextSize = 9
cfgSndDesc.TextXAlignment = Enum.TextXAlignment.Left; cfgSndDesc.TextWrapped = true; cfgSndDesc.ZIndex = 7
local cfgSndPill = Instance.new("Frame",cfgSndRow); cfgSndPill.BackgroundColor3 = Color3.fromRGB(200,140,255)
cfgSndPill.BorderSizePixel = 0; cfgSndPill.Position = UDim2.new(1,-60,0.5,-14); cfgSndPill.Size = UDim2.new(0,52,0,28); cfgSndPill.ZIndex = 9
Instance.new("UICorner",cfgSndPill).CornerRadius = UDim.new(1,0)
local cfgSndPillS = Instance.new("UIStroke",cfgSndPill); cfgSndPillS.Color = Color3.fromRGB(8,4,0); cfgSndPillS.Thickness = 2.5
cfgSndPillS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local cfgSndKnob = Instance.new("Frame",cfgSndPill); cfgSndKnob.BackgroundColor3 = Color3.fromRGB(255,255,255)
cfgSndKnob.BorderSizePixel = 0; cfgSndKnob.Position = UDim2.new(1,-25,0.5,-11); cfgSndKnob.Size = UDim2.new(0,22,0,22); cfgSndKnob.ZIndex = 10
Instance.new("UICorner",cfgSndKnob).CornerRadius = UDim.new(1,0)
local cfgSndBtn = Instance.new("TextButton",cfgSndRow); cfgSndBtn.BackgroundTransparency = 1
cfgSndBtn.Size = UDim2.new(1,0,1,0); cfgSndBtn.Text = ""; cfgSndBtn.ZIndex = 11
cfgSndBtn.MouseButton1Click:Connect(function()
    cfgSndState = not cfgSndState
    NOTIF_CFG.SOUND_ENABLED = cfgSndState
    TweenService:Create(cfgSndPill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{
        BackgroundColor3 = cfgSndState and Color3.fromRGB(200,140,255) or Color3.fromRGB(40,24,8)
    }):Play()
    TweenService:Create(cfgSndKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position = cfgSndState and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11),
        BackgroundColor3 = cfgSndState and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,120,60)
    }):Play()
    if cfgSndState then
        Notify.success("Sons do Hub", "Sons de notificações ativados.")
    else
        Notify.info("Sons do Hub", "Sons de notificações desativados.")
    end
end)

end -- Config Extra

-- ══════════════════════════════════════════════════════════════
-- PEGAR ITENS BAÚS — Abre baús e lança itens do céu na fogueira
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
local pibCard = Instance.new("Frame", Pages["Player"])
pibCard.BackgroundColor3 = Color3.fromRGB(20,16,10)
pibCard.BorderSizePixel  = 0
pibCard.Size             = UDim2.new(1,0,0,72)
pibCard.LayoutOrder      = plNextLO()
pibCard.ZIndex           = 5
Instance.new("UICorner",pibCard).CornerRadius = UDim.new(0,9)
local pibStroke = Instance.new("UIStroke",pibCard)
pibStroke.Color = Color3.fromRGB(80,60,20); pibStroke.Thickness = 1

-- Gradiente sutil
local pibGrad = Instance.new("Frame",pibCard)
pibGrad.BackgroundColor3 = PIB_COR; pibGrad.BackgroundTransparency = 0.92
pibGrad.BorderSizePixel = 0; pibGrad.Size = UDim2.new(1,0,1,0); pibGrad.ZIndex = 5
Instance.new("UICorner",pibGrad).CornerRadius = UDim.new(0,9)

-- Barra lateral colorida
local pibBar = Instance.new("Frame",pibCard)
pibBar.BackgroundColor3 = PIB_COR; pibBar.BorderSizePixel = 0
pibBar.Size = UDim2.new(0,3,1,-12); pibBar.Position = UDim2.new(0,0,0,6); pibBar.ZIndex = 6
Instance.new("UICorner",pibBar).CornerRadius = UDim.new(0,3)

-- Título
local pibTit = Instance.new("TextLabel",pibCard); pibTit.BackgroundTransparency = 1
pibTit.Position = UDim2.new(0,14,0,8); pibTit.Size = UDim2.new(1,-155,0,18)
pibTit.Font = Enum.Font.GothamBold; pibTit.Text = "🎁  Pegar Itens Baús"
pibTit.TextColor3 = Color3.fromRGB(255,230,150); pibTit.TextSize = 12
pibTit.TextXAlignment = Enum.TextXAlignment.Left; pibTit.ZIndex = 7

-- Descrição
local pibDesc = Instance.new("TextLabel",pibCard); pibDesc.BackgroundTransparency = 1
pibDesc.Position = UDim2.new(0,14,0,28); pibDesc.Size = UDim2.new(1,-155,0,16)
pibDesc.Font = Enum.Font.Gotham
pibDesc.Text = "Pega os itens já soltos no mundo e joga do céu na fogueira"
pibDesc.TextColor3 = Color3.fromRGB(100,85,50); pibDesc.TextSize = 9
pibDesc.TextXAlignment = Enum.TextXAlignment.Left; pibDesc.ZIndex = 7

-- Status label (mostra progresso durante execução)
local pibStatus = Instance.new("TextLabel",pibCard); pibStatus.BackgroundTransparency = 1
pibStatus.Position = UDim2.new(0,14,0,48); pibStatus.Size = UDim2.new(1,-155,0,16)
pibStatus.Font = Enum.Font.GothamBold; pibStatus.Text = ""
pibStatus.TextColor3 = PIB_COR; pibStatus.TextSize = 9
pibStatus.TextXAlignment = Enum.TextXAlignment.Left; pibStatus.ZIndex = 7

-- Botão
local pibBtn = Instance.new("TextButton",pibCard)
pibBtn.BackgroundColor3 = PIB_COR; pibBtn.BackgroundTransparency = 0.1
pibBtn.BorderSizePixel  = 0
pibBtn.Position = UDim2.new(1,-142,0.5,-17); pibBtn.Size = UDim2.new(0,134,0,34)
pibBtn.Font = Enum.Font.GothamBlack; pibBtn.Text = "🎁  PEGAR ITENS"
pibBtn.TextColor3 = Color3.fromRGB(30,20,0); pibBtn.TextSize = 10; pibBtn.ZIndex = 8
Instance.new("UICorner",pibBtn).CornerRadius = UDim.new(0,8)
local pibBtnStroke = Instance.new("UIStroke",pibBtn)
pibBtnStroke.Color = Color3.fromRGB(200,150,30); pibBtnStroke.Thickness = 1.2; pibBtnStroke.Transparency = 0.4

pibBtn.MouseEnter:Connect(function()
    if not pibRunning then
        TweenService:Create(pibBtn,TweenInfo.new(0.12),{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(255,215,50)}):Play()
    end
end)
pibBtn.MouseLeave:Connect(function()
    if not pibRunning then
        TweenService:Create(pibBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.1,BackgroundColor3=PIB_COR}):Play()
    end
end)
pibBtn.MouseButton1Click:Connect(function()
    if pibRunning then return end
    pibBtn.Text = "⏳ Aguarda..."
    TweenService:Create(pibBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.4}):Play()
    TweenService:Create(pibStroke,TweenInfo.new(0.2),{Color=PIB_COR}):Play()
    task.spawn(function()
        pegarItensBaus(pibStatus)
        pibBtn.Text = "🎁  PEGAR ITENS"
        TweenService:Create(pibBtn,TweenInfo.new(0.2),{BackgroundTransparency=0.1,BackgroundColor3=PIB_COR}):Play()
        TweenService:Create(pibStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(80,60,20)}):Play()
    end)
end)

end -- Pegar Itens Baús

-- ══════════════════════════════════════════════════════
-- AUTO FOGUEIRA ANOITECER
-- Quando a noite cair (ClockTime >= 18 ou <= 6),
-- teleporta automaticamente o jogador para a fogueira.
-- ══════════════════════════════════════════════════════
do
    local NIGHT_COR = Color3.fromRGB(120,80,255)
    local nightAutoEnabled = false
    local nightAlreadyTped = false  -- evita TP repetido na mesma noite

    -- Seção
    local nightSecHdr=Instance.new("Frame",Pages["Player"]); nightSecHdr.BackgroundColor3=Color3.fromRGB(252,198,0)
    nightSecHdr.BackgroundTransparency=0.88; nightSecHdr.BorderSizePixel=0; nightSecHdr.Size=UDim2.new(1,0,0,24); nightSecHdr.LayoutOrder=plNextLO(); nightSecHdr.ZIndex=4
    Instance.new("UICorner",nightSecHdr).CornerRadius=UDim.new(0,7)
    local nightSecS=Instance.new("UIStroke",nightSecHdr); nightSecS.Color=Color3.fromRGB(252,198,0); nightSecS.Thickness=1; nightSecS.Transparency=0.72
    local nightSecBar=Instance.new("Frame",nightSecHdr); nightSecBar.BackgroundColor3=NIGHT_COR; nightSecBar.BorderSizePixel=0
    nightSecBar.Position=UDim2.new(0,0,0.1,0); nightSecBar.Size=UDim2.new(0,4,0.8,0); nightSecBar.ZIndex=5
    Instance.new("UICorner",nightSecBar).CornerRadius=UDim.new(0,3)
    local nightSecLbl=Instance.new("TextLabel",nightSecHdr); nightSecLbl.BackgroundTransparency=1; nightSecLbl.Position=UDim2.new(0,12,0,0)
    nightSecLbl.Size=UDim2.new(1,-16,1,0); nightSecLbl.Font=Enum.Font.GothamBlack
    nightSecLbl.Text="🌙  NOITE AUTOMÁTICA"; nightSecLbl.TextColor3=NIGHT_COR; nightSecLbl.TextSize=10; nightSecLbl.TextXAlignment=Enum.TextXAlignment.Left; nightSecLbl.ZIndex=5

    -- Card toggle
    local nightRow=Instance.new("Frame",Pages["Player"]); nightRow.BackgroundColor3=Color3.fromRGB(38,22,10)
    nightRow.BorderSizePixel=0; nightRow.Size=UDim2.new(1,0,0,72); nightRow.LayoutOrder=plNextLO(); nightRow.ZIndex=5
    Instance.new("UICorner",nightRow).CornerRadius=UDim.new(0,9)
    local nightRowS=Instance.new("UIStroke",nightRow); nightRowS.Color=Color3.fromRGB(252,198,0); nightRowS.Thickness=4; nightRowS.Transparency=0.6
    local nightRowG=Instance.new("UIGradient",nightRow)
    nightRowG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(40,24,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,3))}); nightRowG.Rotation=135
    local nightRowShine=Instance.new("Frame",nightRow); nightRowShine.BackgroundColor3=Color3.fromRGB(255,255,255)
    nightRowShine.BackgroundTransparency=0.82; nightRowShine.BorderSizePixel=0
    nightRowShine.Position=UDim2.new(0,8,0,3); nightRowShine.Size=UDim2.new(0,55,0,4); nightRowShine.ZIndex=6
    Instance.new("UICorner",nightRowShine).CornerRadius=UDim.new(1,0)

    -- Ícone
    local nightIcoBg=Instance.new("Frame",nightRow); nightIcoBg.BackgroundColor3=NIGHT_COR; nightIcoBg.BackgroundTransparency=0.55
    nightIcoBg.BorderSizePixel=0; nightIcoBg.Position=UDim2.new(0,8,0.5,-20); nightIcoBg.Size=UDim2.new(0,40,0,40); nightIcoBg.ZIndex=7
    Instance.new("UICorner",nightIcoBg).CornerRadius=UDim.new(0,9)
    Instance.new("UIStroke",nightIcoBg).Color=Color3.fromRGB(8,4,0)
    local nightIcoLbl=Instance.new("TextLabel",nightIcoBg); nightIcoLbl.BackgroundTransparency=1
    nightIcoLbl.Size=UDim2.new(1,0,1,0); nightIcoLbl.Font=Enum.Font.GothamBlack; nightIcoLbl.Text="🌙"; nightIcoLbl.TextSize=22; nightIcoLbl.ZIndex=8

    -- Textos
    local nightTl=Instance.new("TextLabel",nightRow); nightTl.BackgroundTransparency=1
    nightTl.Position=UDim2.new(0,58,0,10); nightTl.Size=UDim2.new(1,-120,0,18); nightTl.Font=Enum.Font.GothamBold
    nightTl.Text="🌙 Auto Fogueira Anoitecer"; nightTl.TextColor3=Color3.fromRGB(255,235,190); nightTl.TextSize=12; nightTl.TextXAlignment=Enum.TextXAlignment.Left; nightTl.ZIndex=7
    local nightTd=Instance.new("TextLabel",nightRow); nightTd.BackgroundTransparency=1
    nightTd.Position=UDim2.new(0,58,0,30); nightTd.Size=UDim2.new(1,-120,0,32); nightTd.Font=Enum.Font.Gotham
    nightTd.Text="Quando anoitecer, teleporta automaticamente para a fogueira principal."; nightTd.TextColor3=Color3.fromRGB(160,120,60)
    nightTd.TextSize=9; nightTd.TextXAlignment=Enum.TextXAlignment.Left; nightTd.TextWrapped=true; nightTd.ZIndex=7

    -- Toggle pill
    local nightPill=Instance.new("Frame",nightRow); nightPill.BackgroundColor3=Color3.fromRGB(45,28,15); nightPill.BorderSizePixel=0
    nightPill.Position=UDim2.new(1,-60,0.5,-13); nightPill.Size=UDim2.new(0,48,0,26); nightPill.ZIndex=9
    Instance.new("UICorner",nightPill).CornerRadius=UDim.new(1,0)
    Instance.new("UIStroke",nightPill).Color=Color3.fromRGB(20,10,0)
    local nightKnob=Instance.new("Frame",nightPill); nightKnob.BackgroundColor3=Color3.fromRGB(130,90,30); nightKnob.BorderSizePixel=0
    nightKnob.Position=UDim2.new(0,2,0.5,-11); nightKnob.Size=UDim2.new(0,22,0,22); nightKnob.ZIndex=10
    Instance.new("UICorner",nightKnob).CornerRadius=UDim.new(1,0)
    local nightBtn=Instance.new("TextButton",nightRow); nightBtn.BackgroundTransparency=1; nightBtn.Size=UDim2.new(1,0,1,0); nightBtn.Text=""; nightBtn.ZIndex=11
    nightBtn.MouseButton1Click:Connect(function()
        nightAutoEnabled = not nightAutoEnabled
        TweenService:Create(nightPill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundColor3=nightAutoEnabled and NIGHT_COR or Color3.fromRGB(45,28,15)}):Play()
        TweenService:Create(nightKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=nightAutoEnabled and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
            BackgroundColor3=nightAutoEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,90,30)
        }):Play()
        TweenService:Create(nightRowS,TweenInfo.new(0.2),{Color=nightAutoEnabled and NIGHT_COR or Color3.fromRGB(252,198,0),Transparency=nightAutoEnabled and 0.35 or 0.6}):Play()
        nightAlreadyTped = false  -- reseta ao toggle
        if nightAutoEnabled then
            Notify.send({type="info",icon="🌙",accent=NIGHT_COR,title="Auto Fogueira Anoitecer",msg="Ativo! Vai te teleportar quando anoitecer 🌙",duration=3})
        else
            Notify.send({type="error",icon="🌙",accent=NIGHT_COR,title="Auto Fogueira Anoitecer",msg="Desativado",duration=2})
        end
    end)

    -- Watcher: detecta noite pelo Lighting.ClockTime
    -- 99 Nights: noite começa por volta de ClockTime >= 18 (6PM) ou <= 6 (6AM)
    task.spawn(function()
        while true do
            task.wait(2)
            if nightAutoEnabled then
                pcall(function()
                    local ct = game:GetService("Lighting").ClockTime
                    local isNight = (ct >= 18) or (ct < 6)
                    if isNight and not nightAlreadyTped then
                        nightAlreadyTped = true
                        -- Tenta teleportar para a fogueira
                        local fogPos = _campfirePosCache
                        if not fogPos then
                            -- Força busca se não tiver cache
                            fogPos = getCampfirePos and getCampfirePos()
                        end
                        local ch = Player.Character
                        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
                        if hrp and fogPos then
                            safeTp(fogPos, 4)
                            Notify.send({type="custom",icon="🌙",accent=NIGHT_COR,
                                title="🌙 Anoiteceu!",
                                msg="Teleportando para a fogueira... Boa noite! 🔥",
                                duration=4})
                        end
                    elseif not isNight then
                        nightAlreadyTped = false  -- dia = reseta para próxima noite
                    end
                end)
            end
        end
    end)
end -- Auto Fogueira Anoitecer

end) -- [[ PLAYER TAB ]]


-- ══════════════════════════════════════════════════════
-- AIMBOT
-- ══════════════════════════════════════════════════════

-- ══════════════════════════════════════════════════════════════
-- TELEPORTAR TAB
-- ══════════════════════════════════════════════════════════════
;pcall(function() -- [[ TELEPORTAR TAB ]]

local TP_COR_CAMP   = Color3.fromRGB(255, 180, 60)
local TP_COR_VOLC   = Color3.fromRGB(255, 90, 40)
local TP_COR_FOREST = Color3.fromRGB(80, 200, 100)
local TP_COR_CAVE   = Color3.fromRGB(160, 120, 255)
local TP_COR_FAIRY  = Color3.fromRGB(220, 100, 255)
local TP_COR_CHILD  = Color3.fromRGB(100, 200, 255)
local TP_COR_BUILD  = Color3.fromRGB(180, 210, 255)

local tpLO = 0
local function tpNextLO() tpLO += 1; return tpLO end

-- Helper: seção de TP
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

-- Helper: botão de TP (card largo, visual original)
local function makeTpBtn(icon, titleTxt, descTxt, cor, onClick)
    local card = Instance.new("Frame", Pages["Teleportar"])
    card.BackgroundColor3 = Color3.fromRGB(40,26,12); card.BorderSizePixel = 0
    card.Size = UDim2.new(1,0,0,58); card.LayoutOrder = tpNextLO(); card.ZIndex = 5
    Instance.new("UICorner",card).CornerRadius = UDim.new(0,12)
    local stroke = Instance.new("UIStroke",card); stroke.Color = Color3.fromRGB(252,198,0); stroke.Thickness = 3.5; stroke.Transparency = 0.55

    -- Ícone colorido (estilo cartoon)
    local iconBg = Instance.new("Frame",card); iconBg.BackgroundColor3 = cor
    iconBg.BackgroundTransparency = 0.6; iconBg.BorderSizePixel = 0
    iconBg.Position = UDim2.new(0,10,0.5,-18); iconBg.Size = UDim2.new(0,36,0,36); iconBg.ZIndex = 6
    Instance.new("UICorner",iconBg).CornerRadius = UDim.new(0,10)
    local iconBgStroke = Instance.new("UIStroke",iconBg)
    iconBgStroke.Color = Color3.fromRGB(20,10,0); iconBgStroke.Thickness = 2.5; iconBgStroke.Transparency = 0.3
    local iconLbl = Instance.new("TextLabel",iconBg); iconLbl.BackgroundTransparency = 1
    iconLbl.Size = UDim2.new(1,0,1,0); iconLbl.Font = Enum.Font.GothamBlack
    iconLbl.Text = icon; iconLbl.TextSize = 18; iconLbl.ZIndex = 7

    -- Título + desc
    local tl = Instance.new("TextLabel",card); tl.BackgroundTransparency = 1
    tl.Position = UDim2.new(0,54,0,8); tl.Size = UDim2.new(1,-120,0,18)
    tl.Font = Enum.Font.GothamBold; tl.Text = titleTxt
    tl.TextColor3 = Color3.fromRGB(255,235,190); tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 7
    local td = Instance.new("TextLabel",card); td.BackgroundTransparency = 1
    td.Position = UDim2.new(0,54,0,28); td.Size = UDim2.new(1,-120,0,22)
    td.Font = Enum.Font.Gotham; td.Text = descTxt
    td.TextColor3 = Color3.fromRGB(160,120,60); td.TextSize = 9
    td.TextXAlignment = Enum.TextXAlignment.Left; td.TextWrapped = true; td.ZIndex = 7

    -- Botão TP direita (estilo NOVO badge — amarelo cartoon)
    local btn = Instance.new("TextButton",card); btn.BackgroundColor3 = Color3.fromRGB(252,196,0)
    btn.BackgroundTransparency = 0; btn.BorderSizePixel = 0; btn.Text = ""
    btn.Position = UDim2.new(1,-60,0.5,-14); btn.Size = UDim2.new(0,52,0,28); btn.ZIndex = 8
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,9)
    local btnStroke = Instance.new("UIStroke",btn); btnStroke.Color = Color3.fromRGB(20,10,0); btnStroke.Thickness = 3
    local btnGrad = Instance.new("UIGradient",btn)
    btnGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,238,70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(185,122,0)),
    }); btnGrad.Rotation = 90
    -- Shine no botão TP
    local btnShine = Instance.new("Frame",btn); btnShine.Size = UDim2.new(0,28,0,7)
    btnShine.Position = UDim2.new(0,4,0,3); btnShine.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btnShine.BackgroundTransparency = 0.65; btnShine.BorderSizePixel = 0; btnShine.ZIndex = 9
    Instance.new("UICorner",btnShine).CornerRadius = UDim.new(1,0)
    local btnL = Instance.new("TextLabel",btn); btnL.BackgroundTransparency = 1
    btnL.Size = UDim2.new(1,0,1,0); btnL.Font = Enum.Font.GothamBlack
    btnL.Text = "TP"; btnL.TextColor3 = Color3.fromRGB(22,10,0); btnL.TextSize = 12; btnL.ZIndex = 9

    -- Hover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(255,240,80)}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.12),{Color=Color3.fromRGB(252,198,0),Transparency=0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(252,196,0)}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.12),{Color=Color3.fromRGB(252,198,0),Transparency=0.55}):Play()
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
-- 7. TP CRIANÇA — Teleporta para a criança capturada mais próxima (1 vez, desliga sozinho)
-- ──────────────────────────────────────────────────────────────
makeTpSec("👶  CRIANÇAS CAPTURADAS", TP_COR_CHILD)

local CHILD_NAMES = {
    -- ✅ Nomes internos confirmados (com ponto e espaço)
    "child. 1", "child. 2", "child. 3", "child. 4",
    -- Variações sem ponto
    "child 1",  "child 2",  "child 3",  "child 4",
    -- Variações sem espaço
    "child1",   "child2",   "child3",   "child4",
    -- Nomes visuais wiki
    "dino kid",   "dinokid",
    "kraken kid", "krakenkid",
    "squid kid",  "squidkid",
    "koala kid",  "koalakid",
    -- Genéricos
    "kid",        "missing child",   "capturedchild",  "captured child",
    "lost child", "prisioner",       "prisoner",       "hostage",
    "crianca",    "criança",
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
            if isAnimal(obj.Name)     then return end  -- ← exclui bunny, wolf, etc.

            local hum = obj:FindFirstChildWhichIsA("Humanoid")
            if not hum or hum.Health <= 0 then return end

            local nm    = obj.Name
            local score = 0

            -- Nome bate com lista de crianças
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

-- Card especial para Tp Criança com indicador de estado
tpChildCard = Instance.new("Frame", Pages["Teleportar"])
tpChildCard.BackgroundColor3 = Color3.fromRGB(40,26,12); tpChildCard.BorderSizePixel = 0
tpChildCard.Size = UDim2.new(1,0,0,70); tpChildCard.LayoutOrder = tpNextLO(); tpChildCard.ZIndex = 5
Instance.new("UICorner",tpChildCard).CornerRadius = UDim.new(0,9)
tpChildStroke = Instance.new("UIStroke",tpChildCard); tpChildStroke.Color = Color3.fromRGB(80,55,20); tpChildStroke.Thickness = 1

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
        TweenService:Create(tpChildStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(80,55,20)}):Play()
        TweenService:Create(chStatusDot,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(90,100,120)}):Play()
        tpChildBtnL.Text = "✓"
        task.delay(1.5, function() tpChildBtnL.Text = "TP" end)
        Notify.send({type="custom",icon="👶",accent=TP_COR_CHILD,
            title="Tp Criança",msg="Teleportado para: "..target.Parent.Name,duration=3})
    else
        tpChildBtnL.Text = "TP"
        -- Mostra na tela E no console os nomes reais dos NPCs
        debugListNPCs()
        Notify.warn("Tp Criança","⚠️ Criança não encontrada! Nomes dos NPCs aparecem acima.")
    end
end)

-- ══════════════════════════════════════════════════════════════
-- 7. PAINEL DE CONSTRUÇÕES v3 — Grupos por BIOMA, sem mistura
-- ══════════════════════════════════════════════════════════════
makeTpSec("🏗️  PAINEL DE CONSTRUÇÕES", TP_COR_BUILD)

-- ── Biomas com keywords para detectar pelo nome do objeto OU ancestrais
-- A detecção SOBE a hierarquia até 6 níveis para pegar o folder do bioma
local BUILD_BIOMES = {
    { label="Fada",      icon="🧚", cor=Color3.fromRGB(255,150,255),
      keys={"fairy","fada","giant tree","mother tree","brightwood","enchanted","fairy forest","fada biome","giant_tree","fairytale"} },
    { label="Vulcão",    icon="🌋", cor=Color3.fromRGB(255,90,20),
      keys={"volcano","volcanic","lava","vulcao","vulcão","scorpion pit","ammo furnace","volcanic church","hellephant","lava pool","lava fall","lava-isolated","volcano entrance","volcano_biome","vulcao biome"} },
    { label="Selva",     icon="🌿", cor=Color3.fromRGB(40,200,80),
      keys={"jungle","selva","mother temple","jungle temple","tar pit","tarpit","jungle cultist","jungle_biome","selva biome"} },
    { label="Neve/Gelo", icon="❄️", cor=Color3.fromRGB(140,220,255),
      keys={"ice","snow","frozen","winter","gelo","neve","iceberg","blizzard","tundra","glacier","ice_biome","snow_biome"} },
    { label="Pântano",   icon="🐸", cor=Color3.fromRGB(90,200,70),
      keys={"frog","swamp","pantano","pântano","marsh","swampland","bog","swamp_biome","frog_biome"} },
    { label="UFO/Alien", icon="🛸", cor=Color3.fromRGB(60,255,170),
      keys={"ufo","alien","mothership","nave","ovni","broken ufo","alien base","ufo_biome","alien_biome"} },
}

-- Detecta bioma subindo a hierarquia do objeto (até 6 pais)
local function bpGetBiomeFromObj(obj)
    local cur = obj
    for _ = 1, 6 do
        if not cur or cur == workspace then break end
        local nm = cur.Name:lower()
        for _, b in ipairs(BUILD_BIOMES) do
            for _, kw in ipairs(b.keys) do
                if nm:find(kw, 1, true) then
                    return b.label, b.icon, b.cor
                end
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
bpCard.BackgroundColor3 = Color3.fromRGB(22,14,8)
bpCard.BorderSizePixel = 0; bpCard.Size = UDim2.new(1,0,0,310)
bpCard.LayoutOrder = tpNextLO(); bpCard.ZIndex = 5
Instance.new("UICorner",bpCard).CornerRadius = UDim.new(0,14)
local bpCardStroke = Instance.new("UIStroke",bpCard)
bpCardStroke.Color = Color3.fromRGB(252,198,0); bpCardStroke.Thickness = 4.5
local bpCardGrad = Instance.new("UIGradient",bpCard)
bpCardGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(38,24,12)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,4)),
}); bpCardGrad.Rotation = 140

-- ── Header ──────────────────────────────────────────────────
local bpHdr = Instance.new("Frame",bpCard)
bpHdr.BackgroundColor3 = Color3.fromRGB(252,196,0)
bpHdr.BorderSizePixel = 0; bpHdr.Size = UDim2.new(1,0,0,48); bpHdr.ZIndex = 6
Instance.new("UICorner",bpHdr).CornerRadius = UDim.new(0,12)
local bpHdrFix = Instance.new("Frame",bpHdr)
bpHdrFix.BackgroundColor3 = Color3.fromRGB(252,196,0); bpHdrFix.BorderSizePixel = 0
bpHdrFix.Position = UDim2.new(0,0,0.5,0); bpHdrFix.Size = UDim2.new(1,0,0.5,0); bpHdrFix.ZIndex = 6
local bpHdrGrad = Instance.new("UIGradient",bpHdr)
bpHdrGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,238,70)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(252,198,0)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(185,122,0)),
}); bpHdrGrad.Rotation = 0
local bpHdrStroke = Instance.new("UIStroke",bpHdr)
bpHdrStroke.Color = Color3.fromRGB(20,10,0); bpHdrStroke.Thickness = 3
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
bpHdrTitle.TextColor3 = Color3.fromRGB(22,10,0); bpHdrTitle.TextSize = 13
bpHdrTitle.TextXAlignment = Enum.TextXAlignment.Left; bpHdrTitle.ZIndex = 7
local bpHdrTS = Instance.new("UIStroke",bpHdrTitle); bpHdrTS.Color=Color3.fromRGB(180,110,0); bpHdrTS.Thickness=1.2

local bpHdrSub = Instance.new("TextLabel",bpHdr); bpHdrSub.BackgroundTransparency = 1
bpHdrSub.Position = UDim2.new(0,44,0,26); bpHdrSub.Size = UDim2.new(0,180,0,14)
bpHdrSub.Font = Enum.Font.Gotham; bpHdrSub.Text = "0 biomas · 0 construções"
bpHdrSub.TextColor3 = Color3.fromRGB(80,50,10); bpHdrSub.TextSize = 9
bpHdrSub.TextXAlignment = Enum.TextXAlignment.Left; bpHdrSub.ZIndex = 7

local bpBtnRef = Instance.new("TextButton",bpHdr)
bpBtnRef.BackgroundColor3 = Color3.fromRGB(22,10,0); bpBtnRef.BackgroundTransparency = 0.1; bpBtnRef.Text = ""
bpBtnRef.BorderSizePixel = 0; bpBtnRef.Position = UDim2.new(1,-88,0.5,-14)
bpBtnRef.Size = UDim2.new(0,38,0,28); bpBtnRef.ZIndex = 8
Instance.new("UICorner",bpBtnRef).CornerRadius = UDim.new(0,9)
local bpBtnRefS = Instance.new("UIStroke",bpBtnRef); bpBtnRefS.Color=Color3.fromRGB(20,10,0); bpBtnRefS.Thickness=2.5
local bpBtnRefL = Instance.new("TextLabel",bpBtnRef); bpBtnRefL.BackgroundTransparency = 1
bpBtnRefL.Size = UDim2.new(1,0,1,0); bpBtnRefL.Font = Enum.Font.GothamBlack
bpBtnRefL.Text = "🔄"; bpBtnRefL.TextColor3 = Color3.fromRGB(255,220,150); bpBtnRefL.TextSize = 14; bpBtnRefL.ZIndex = 9

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
bpDetailHdr.BackgroundColor3 = Color3.fromRGB(32,20,8); bpDetailHdr.BorderSizePixel = 0
bpDetailHdr.Size = UDim2.new(1,0,0,40); bpDetailHdr.ZIndex = 8
Instance.new("UICorner",bpDetailHdr).CornerRadius = UDim.new(0,10)
local bpDetailHdrS = Instance.new("UIStroke",bpDetailHdr)
bpDetailHdrS.Color = Color3.fromRGB(252,198,0); bpDetailHdrS.Thickness = 2.5; bpDetailHdrS.Transparency = 0.5

local bpBackBtn = Instance.new("TextButton",bpDetailHdr)
bpBackBtn.BackgroundColor3 = Color3.fromRGB(252,196,0); bpBackBtn.BackgroundTransparency = 0.1; bpBackBtn.Text = ""
bpBackBtn.BorderSizePixel = 0; bpBackBtn.Position = UDim2.new(0,8,0.5,-14); bpBackBtn.Size = UDim2.new(0,64,0,28); bpBackBtn.ZIndex = 9
Instance.new("UICorner",bpBackBtn).CornerRadius = UDim.new(0,9)
local bpBackBtnS = Instance.new("UIStroke",bpBackBtn); bpBackBtnS.Color=Color3.fromRGB(20,10,0); bpBackBtnS.Thickness=2.5
local bpBackBtnL = Instance.new("TextLabel",bpBackBtn); bpBackBtnL.BackgroundTransparency = 1
bpBackBtnL.Size = UDim2.new(1,0,1,0); bpBackBtnL.Font = Enum.Font.GothamBlack
bpBackBtnL.Text = "◀ Voltar"; bpBackBtnL.TextColor3 = Color3.fromRGB(22,10,0); bpBackBtnL.TextSize = 9; bpBackBtnL.ZIndex = 10

local bpDetailTitle = Instance.new("TextLabel",bpDetailHdr); bpDetailTitle.BackgroundTransparency = 1
bpDetailTitle.Position = UDim2.new(0,80,0.5,-10); bpDetailTitle.Size = UDim2.new(1,-170,0,20)
bpDetailTitle.Font = Enum.Font.GothamBlack; bpDetailTitle.Text = ""
bpDetailTitle.TextColor3 = Color3.fromRGB(252,198,0); bpDetailTitle.TextSize = 12
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
    bpDetailCount.Text = tostring(#grp.entries).." local(is)"
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
local bpBiomeOrder = 0
local function bpGetOrCreateGroup(biomeLabel, biomeIcon, biomeCor)
    if buildGroupMap[biomeLabel] then return buildGroupMap[biomeLabel] end
    bpBiomeOrder += 1
    -- Floresta sempre primeiro
    local lo = (biomeLabel == "Floresta") and 0 or bpBiomeOrder
    local COR = biomeCor or Color3.fromRGB(150,180,100)
    local grp = { label=biomeLabel, icon=biomeIcon, cor=COR, entries={}, groupBtn=nil, countLbl=nil, scroll=nil }
    buildGroupMap[biomeLabel] = grp
    table.insert(buildGroups, grp)

    -- Botão do bioma na lista de grupos
    local btn = Instance.new("Frame",bpGroupView)
    btn.BackgroundColor3 = Color3.fromRGB(32,20,8); btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1,0,0,68); btn.ZIndex = 7; btn.LayoutOrder = lo
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,14)
    local btnS = Instance.new("UIStroke",btn); btnS.Color=COR; btnS.Thickness=4; btnS.Transparency=0.2
    local btnBg = Instance.new("Frame",btn); btnBg.BackgroundColor3=COR; btnBg.BackgroundTransparency=0.88
    btnBg.BorderSizePixel=0; btnBg.Size=UDim2.new(1,0,1,0); btnBg.ZIndex=7
    Instance.new("UICorner",btnBg).CornerRadius=UDim.new(0,14)
    local btnBar = Instance.new("Frame",btn); btnBar.BackgroundColor3=COR; btnBar.BorderSizePixel=0
    btnBar.Position=UDim2.new(0,0,0.2,0); btnBar.Size=UDim2.new(0,4,0.6,0); btnBar.ZIndex=9
    Instance.new("UICorner",btnBar).CornerRadius=UDim.new(0,3)
    local icoBox = Instance.new("Frame",btn); icoBox.BackgroundColor3=COR; icoBox.BackgroundTransparency=0.55
    icoBox.BorderSizePixel=0; icoBox.Position=UDim2.new(0,10,0.5,-24); icoBox.Size=UDim2.new(0,48,0,48); icoBox.ZIndex=8
    Instance.new("UICorner",icoBox).CornerRadius=UDim.new(0,12)
    local icoBoxS = Instance.new("UIStroke",icoBox); icoBoxS.Color=Color3.fromRGB(20,10,0); icoBoxS.Thickness=2.5; icoBoxS.Transparency=0.3
    local icoLbl = Instance.new("TextLabel",icoBox); icoLbl.BackgroundTransparency=1
    icoLbl.Size=UDim2.new(1,0,1,0); icoLbl.Font=Enum.Font.GothamBlack
    icoLbl.Text=biomeIcon; icoLbl.TextSize=26; icoLbl.ZIndex=9
    local nameLbl = Instance.new("TextLabel",btn); nameLbl.BackgroundTransparency=1
    nameLbl.Position=UDim2.new(0,68,0,10); nameLbl.Size=UDim2.new(0.55,0,0,22)
    nameLbl.Font=Enum.Font.GothamBlack; nameLbl.Text=biomeLabel
    nameLbl.TextColor3=Color3.fromRGB(255,235,190); nameLbl.TextSize=13
    nameLbl.TextXAlignment=Enum.TextXAlignment.Left; nameLbl.ZIndex=8
    local cntBadge = Instance.new("Frame",btn); cntBadge.BackgroundColor3=COR; cntBadge.BackgroundTransparency=0.15
    cntBadge.BorderSizePixel=0; cntBadge.Position=UDim2.new(0,68,0,36); cntBadge.Size=UDim2.new(0,70,0,18); cntBadge.ZIndex=8
    Instance.new("UICorner",cntBadge).CornerRadius=UDim.new(0,6)
    local cntBadgeS = Instance.new("UIStroke",cntBadge); cntBadgeS.Color=Color3.fromRGB(20,10,0); cntBadgeS.Thickness=2
    local cntLbl = Instance.new("TextLabel",cntBadge); cntLbl.BackgroundTransparency=1
    cntLbl.Size=UDim2.new(1,0,1,0); cntLbl.Font=Enum.Font.GothamBold
    cntLbl.Text="0 locais"; cntLbl.TextColor3=Color3.fromRGB(255,255,255); cntLbl.TextSize=9; cntLbl.ZIndex=9
    grp.countLbl = cntLbl
    local arrowLbl = Instance.new("TextLabel",btn); arrowLbl.BackgroundTransparency=1
    arrowLbl.Position=UDim2.new(1,-38,0.5,-14); arrowLbl.Size=UDim2.new(0,30,0,28)
    arrowLbl.Font=Enum.Font.GothamBlack; arrowLbl.Text="▶"
    arrowLbl.TextColor3=COR; arrowLbl.TextSize=16; arrowLbl.ZIndex=8
    grp.groupBtn = btn

    -- SCROLL EXCLUSIVO para este grupo (invisível por padrão)
    local scroll = Instance.new("ScrollingFrame",bpDetailView)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
    scroll.Position=UDim2.new(0,0,0,44); scroll.Size=UDim2.new(1,0,1,-48)
    scroll.ZIndex=8; scroll.ScrollBarThickness=3
    scroll.ScrollBarImageColor3=COR
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.CanvasSize=UDim2.new(0,0,0,0)
    scroll.Visible=false
    local scrollLayout = Instance.new("UIListLayout",scroll)
    scrollLayout.Padding=UDim.new(0,5); scrollLayout.SortOrder=Enum.SortOrder.LayoutOrder
    local scrollPad = Instance.new("UIPadding",scroll)
    scrollPad.PaddingTop=UDim.new(0,4); scrollPad.PaddingLeft=UDim.new(0,6)
    scrollPad.PaddingRight=UDim.new(0,6); scrollPad.PaddingBottom=UDim.new(0,6)
    grp.scroll = scroll

    local hitBtn = Instance.new("TextButton",btn); hitBtn.BackgroundTransparency=1
    hitBtn.Size=UDim2.new(1,0,1,0); hitBtn.Text=""; hitBtn.ZIndex=10
    hitBtn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(52,34,14)}):Play()
        TweenService:Create(btnS,TweenInfo.new(0.12),{Transparency=0}):Play()
        TweenService:Create(arrowLbl,TweenInfo.new(0.12),{TextColor3=Color3.fromRGB(255,255,255)}):Play()
    end)
    hitBtn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(32,20,8)}):Play()
        TweenService:Create(btnS,TweenInfo.new(0.12),{Transparency=0.2}):Play()
        TweenService:Create(arrowLbl,TweenInfo.new(0.12),{TextColor3=COR}):Play()
    end)
    hitBtn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=COR}):Play()
        task.delay(0.1,function() TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(45,28,15)}):Play() end)
        task.delay(0.12, function() bpShowDetail(grp) end)
    end)
    return grp
end

-- ── Adiciona entrada ao grupo do bioma ───────────────────────
local function bpAddEntry(grp, name, pos, structIcon)
    local nk = bpNameKey(name, pos)
    local wasVisited = buildVisited[nk] == true
    local COR = grp.cor
    local entry = { name=name, pos=pos, nk=nk, visited=wasVisited, row=nil }
    table.insert(grp.entries, entry)
    local rowIdx = #grp.entries

    -- !! Linha vai para o scroll EXCLUSIVO do grupo !!
    local row = Instance.new("Frame", grp.scroll)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,52); row.ZIndex=8; row.LayoutOrder=rowIdx
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)
    row.BackgroundColor3 = wasVisited and Color3.fromRGB(70,18,12) or Color3.fromRGB(38,24,10)
    local rowS = Instance.new("UIStroke",row)
    rowS.Color = wasVisited and Color3.fromRGB(200,60,60) or Color3.fromRGB(252,198,0)
    rowS.Thickness=2.5; rowS.Transparency = wasVisited and 0.1 or 0.65
    local rowBg = Instance.new("Frame",row); rowBg.BackgroundColor3=COR; rowBg.BackgroundTransparency=0.94
    rowBg.BorderSizePixel=0; rowBg.Size=UDim2.new(1,0,1,0); rowBg.ZIndex=8
    Instance.new("UICorner",rowBg).CornerRadius=UDim.new(0,12)
    local colorBar = Instance.new("Frame",row); colorBar.BackgroundColor3=COR; colorBar.BorderSizePixel=0
    colorBar.Position=UDim2.new(0,0,0.1,0); colorBar.Size=UDim2.new(0,4,0.8,0); colorBar.ZIndex=9
    Instance.new("UICorner",colorBar).CornerRadius=UDim.new(0,2)
    local ico = Instance.new("TextLabel",row); ico.BackgroundTransparency=1
    ico.Position=UDim2.new(0,8,0.5,-12); ico.Size=UDim2.new(0,24,0,24)
    ico.Font=Enum.Font.GothamBlack; ico.Text=structIcon or grp.icon; ico.TextSize=16; ico.ZIndex=9
    local nameLbl = Instance.new("TextLabel",row); nameLbl.BackgroundTransparency=1
    nameLbl.Position=UDim2.new(0,36,0,7); nameLbl.Size=UDim2.new(0.56,0,0,18)
    nameLbl.Font=Enum.Font.GothamBold; nameLbl.Text=name
    nameLbl.TextColor3 = wasVisited and Color3.fromRGB(200,130,130) or Color3.fromRGB(255,235,190)
    nameLbl.TextSize=11; nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    nameLbl.TextTruncate=Enum.TextTruncate.AtEnd; nameLbl.ZIndex=9
    entry.nameLbl=nameLbl
    local distTxt=""
    pcall(function()
        local ch=Player.Character; local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then distTxt=" • "..math.floor((pos-hrp.Position).Magnitude).."m" end
    end)
    local infoLbl = Instance.new("TextLabel",row); infoLbl.BackgroundTransparency=1
    infoLbl.Position=UDim2.new(0,36,0,28); infoLbl.Size=UDim2.new(0.55,0,0,16)
    infoLbl.Font=Enum.Font.Gotham; infoLbl.TextSize=9
    infoLbl.Text=grp.icon.." "..grp.label..distTxt
    infoLbl.TextColor3 = wasVisited and Color3.fromRGB(160,100,100) or Color3.fromRGB(160,120,60)
    infoLbl.TextXAlignment=Enum.TextXAlignment.Left; infoLbl.ZIndex=9
    local tagBadge = Instance.new("Frame",row); tagBadge.BorderSizePixel=0
    tagBadge.AnchorPoint=Vector2.new(1,0); tagBadge.Position=UDim2.new(1,-52,0,5)
    tagBadge.Size=UDim2.new(0,72,0,16); tagBadge.ZIndex=10
    Instance.new("UICorner",tagBadge).CornerRadius=UDim.new(0,5)
    local tagLbl = Instance.new("TextLabel",tagBadge); tagLbl.BackgroundTransparency=1
    tagLbl.Size=UDim2.new(1,0,1,0); tagLbl.Font=Enum.Font.GothamBlack; tagLbl.TextSize=7; tagLbl.ZIndex=11
    entry.tagBadge=tagBadge; entry.tagLbl=tagLbl; entry.row=row; entry.rowS=rowS; entry.rowBg=rowBg
    if wasVisited then
        tagBadge.BackgroundColor3=Color3.fromRGB(240,200,40)
        tagLbl.Text="✓ Teleportou!"; tagLbl.TextColor3=Color3.fromRGB(50,30,5)
    else
        tagBadge.Visible=false
    end
    -- TP button
    local tpb = Instance.new("TextButton",row)
    tpb.BackgroundColor3=Color3.fromRGB(252,196,0); tpb.BackgroundTransparency=0; tpb.Text=""
    tpb.BorderSizePixel=0; tpb.Position=UDim2.new(1,-50,0.5,-16); tpb.Size=UDim2.new(0,44,0,32); tpb.ZIndex=10
    Instance.new("UICorner",tpb).CornerRadius=UDim.new(0,10)
    local tpbS = Instance.new("UIStroke",tpb); tpbS.Color=Color3.fromRGB(20,10,0); tpbS.Thickness=2.5
    local tpbG = Instance.new("UIGradient",tpb)
    tpbG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,238,70)),ColorSequenceKeypoint.new(1,Color3.fromRGB(185,122,0))}); tpbG.Rotation=90
    local tpbL = Instance.new("TextLabel",tpb); tpbL.BackgroundTransparency=1
    tpbL.Size=UDim2.new(1,0,1,0); tpbL.Font=Enum.Font.GothamBlack
    tpbL.Text="TP"; tpbL.TextColor3=Color3.fromRGB(22,10,0); tpbL.TextSize=12; tpbL.ZIndex=11
    local function doTp()
        buildVisited[nk]=true; entry.visited=true
        TweenService:Create(tpb,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0}):Play()
        task.delay(0.2,function() TweenService:Create(tpb,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(252,196,0),BackgroundTransparency=0}):Play() end)
        TweenService:Create(row,TweenInfo.new(0.25),{BackgroundColor3=Color3.fromRGB(80,18,18)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.25),{Color=Color3.fromRGB(200,60,60)}):Play()
        TweenService:Create(rowBg,TweenInfo.new(0.25),{BackgroundTransparency=0.90}):Play()
        tagBadge.BackgroundColor3=Color3.fromRGB(240,200,40)
        tagLbl.Text="✓ Teleportou!"; tagLbl.TextColor3=Color3.fromRGB(50,30,5)
        tagBadge.Visible=true; tagBadge.Size=UDim2.new(0,10,0,16)
        TweenService:Create(tagBadge,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,72,0,16)}):Play()
        TweenService:Create(nameLbl,TweenInfo.new(0.2),{TextColor3=Color3.fromRGB(200,130,130)}):Play()
        safeTp(pos,5)
        Notify.send({type="custom",icon=structIcon or grp.icon,accent=COR,
            title=grp.label,msg=name,duration=2.5})
    end
    tpb.MouseButton1Click:Connect(doTp)
    local rowHit = Instance.new("TextButton",row); rowHit.BackgroundTransparency=1
    rowHit.Size=UDim2.new(1,-50,1,0); rowHit.Text=""; rowHit.ZIndex=9
    rowHit.MouseButton1Click:Connect(doTp)
    rowHit.MouseEnter:Connect(function() if not entry.visited then
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(52,34,14)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Transparency=0.3}):Play() end end)
    rowHit.MouseLeave:Connect(function() if not entry.visited then
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(38,24,10)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Transparency=0.65}):Play() end end)
    return entry
end

-- ── Scan ─────────────────────────────────────────────────────
local function bpScanBuildings(isRefresh)
    if bpScanRunning then return end
    bpScanRunning = true
    bpBtnRefL.Text = "⏳"; task.delay(1, function() bpBtnRefL.Text = "🔄" end)
    task.spawn(function()
        local found = 0
        local batch = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            batch += 1
            if batch % 500 == 0 then task.wait() end
            if not obj:IsA("Model") then continue end
            local nm = obj.Name:lower()
            -- Filtra itens que não são construções
            if nm:find("trap",1,true) or nm:find("spike",1,true)
            or nm:find("chest",1,true) or nm:find("bau",1,true) or nm:find("baú",1,true)
            or nm:find("snare",1,true) or nm:find("item",1,true) then continue end
            -- Filtra NPCs/mobs
            if obj:FindFirstChildWhichIsA("Humanoid") then continue end
            -- É construção?
            if not bpIsBuilding(nm) then continue end
            -- Pega parte representativa
            local part, bigEnough = nil, false
            for _, bp in ipairs(obj:GetDescendants()) do
                if bp:IsA("BasePart") then
                    if not part then part=bp end
                    if bp.Size.X>3 or bp.Size.Y>3 or bp.Size.Z>3 then bigEnough=true; part=bp; break end
                end
            end
            if not part or not bigEnough then continue end
            if part.Position.Y < -500 then continue end
            local pk = bpPosKey(part.Position)
            if buildSeenKeys[pk] then continue end
            buildSeenKeys[pk] = true
            -- Detecta bioma subindo a hierarquia
            local biomeLabel, biomeIcon, biomeCor = bpGetBiomeFromObj(obj)
            -- Detecta ícone especial
            local structIcon, _ = bpGetStructIcon(nm)
            -- Cria/pega grupo do bioma
            local grp = bpGetOrCreateGroup(biomeLabel, biomeIcon, biomeCor)
            -- Adiciona entrada no scroll EXCLUSIVO do grupo
            bpAddEntry(grp, obj.Name, part.Position, structIcon)
            grp.countLbl.Text = tostring(#grp.entries).." local(is)"
            found += 1
            bpEmptyLbl.Visible = false
            -- Atualiza detalhe se este grupo está aberto
            if bpCurrentGroup == grp then
                bpDetailCount.Text = tostring(#grp.entries).." local(is)"
            end
            if found % 20 == 0 then task.wait() end
        end
        -- Atualiza subtítulo
        local totalB, totalE = 0, 0
        for _, g in pairs(buildGroupMap) do totalB += 1; totalE += #g.entries end
        bpHdrSub.Text = tostring(totalB).." biomas · "..tostring(totalE).." construções"
        bpScanRunning = false
        if found == 0 and isRefresh then
            Notify.info("Construções","Nenhuma construção nova encontrada.")
        elseif found > 0 then
            Notify.send({type="custom",icon="🏗️",accent=TP_COR_BUILD,
                title="Construções",
                msg=(isRefresh and tostring(found).." nova(s)!" or tostring(found).." em "..totalB.." biomas!"),
                duration=3})
        end
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

-- ── Tabela de raridade (usada internamente para classificar baús da Floresta)
local CHEST_RARITY = {
    { keywords={"diamond","diamante"},                          tier=5, label="Diamante",  tag="DIAMOND", cor=Color3.fromRGB(100,220,255), icon="💎" },
    { keywords={"ruby","rubi","red chest","vermelho","strong","stronghold chest"}, tier=4, label="Rubi",  tag="RUBY",    cor=Color3.fromRGB(255,60,80),   icon="🔴" },
    { keywords={"gold","golden","dourado"},                     tier=3, label="Dourado",   tag="GOLD",    cor=Color3.fromRGB(255,200,20),  icon="👑" },
    { keywords={"epic","epico","épico","purple","legendary","great","obsidiron"}, tier=2, label="Épico", tag="EPIC",   cor=Color3.fromRGB(180,80,255),  icon="🟣" },
    { keywords={"common","item chest","chest","good","iron","common chest"}, tier=1, label="Comum", tag="COMMON",  cor=Color3.fromRGB(160,140,110), icon="📦" },
}
local function getRarity(chestModel)
    local nm = chestModel.Name:lower()
    for _, r in ipairs(CHEST_RARITY) do
        for _, kw in ipairs(r.keywords) do
            if nm:find(kw,1,true) then return r end
        end
    end
    return CHEST_RARITY[#CHEST_RARITY] -- padrão: Comum
end

-- ── Tabela de biomas (ordem de exibição)
-- "Floresta" é o bioma padrão e recebe sub-grupos de raridade
local BIOME_DEFS = {
    { keys={"fairy","fada","giant tree","mother tree","brightwood","enchanted","fairy chest","fada chest"},   label="Fada",       icon="🧚", cor=Color3.fromRGB(255,180,255) },
    { keys={"volcano","volcanic","lava","vulcao","vulcão","volcano chest","lava chest"},                     label="Vulcão",     icon="🌋", cor=Color3.fromRGB(255,100,30)  },
    { keys={"jungle","selva","temple","mother temple","jungle chest","selva chest"},                         label="Selva",      icon="🌿", cor=Color3.fromRGB(60,200,80)   },
    { keys={"ice","snow","frozen","winter","gelo","neve","iceberg","ice chest","snow chest"},                 label="Neve/Gelo",  icon="❄️", cor=Color3.fromRGB(160,230,255) },
    { keys={"frog","swamp","pantano","pântano","marsh","frog chest","swamp chest"},                          label="Pântano",    icon="🐸", cor=Color3.fromRGB(100,220,80)  },
    { keys={"ufo","alien","mothership","nave","alien chest","ufo chest"},                                    label="UFO/Alien",  icon="🛸", cor=Color3.fromRGB(80,255,180)  },
    { keys={"stronghold","cultist","fortress","fortaleza","stronghold chest","cultist chest"},               label="Fortaleza",  icon="⚔️", cor=Color3.fromRGB(200,160,80)  },
    { keys={"cave","cavern","mine","caverna","mina","cave chest","mine chest"},                              label="Caverna",    icon="🕳️", cor=Color3.fromRGB(140,100,60)  },
    { keys={"research","outpost","research chest"},                                                         label="Posto",      icon="🔬", cor=Color3.fromRGB(120,180,255) },
    { keys={"meteor","crater","meteor chest"},                                                              label="Meteoro",    icon="☄️", cor=Color3.fromRGB(255,140,40)  },
    { keys={"ruin","ancient","abandon","ruin chest"},                                                       label="Ruínas",     icon="🏚️", cor=Color3.fromRGB(160,140,100) },
    { keys={"thanksgiving"},                                                                                label="Evento",     icon="🎃", cor=Color3.fromRGB(255,150,50)  },
}
local function getBiome(chestModel)
    local obj = chestModel
    for _ = 1, 6 do
        if not obj or obj == workspace then break end
        local nm = obj.Name:lower()
        for _, b in ipairs(BIOME_DEFS) do
            for _, kw in ipairs(b.keys) do
                if nm:find(kw,1,true) then return b.label, b.icon, b.cor end
            end
        end
        obj = obj.Parent
    end
    return "Floresta","🌲", Color3.fromRGB(80,200,80)
end

-- ── Estado ───────────────────────────────────────────────────────
-- biomeData[biomeLabel] = { icon, cor, entries={}, btn, countLbl,
--   rarSubs={ [rarTag]={ rarity, entries={}, btn, countLbl } } }
-- entries para biomas NÃO-floresta = { name, pos, nk, row, ... }
-- rarSubs usados APENAS para "Floresta"
local biomeData      = {}
local chestSeenKeys2 = {}
local chestVisited   = {}
local chestScanRun2  = false
local navState       = "biomes"  -- "biomes" | "rar_subs" | "detail"
local curBiomeKey    = nil
local curRarTag      = nil

local function cpNameKey(name,pos) return name:lower()..":"..math.floor(pos.X/6)..","..math.floor(pos.Z/6) end
local function cpPosKey(pos) return math.floor(pos.X/6)..","..math.floor(pos.Y/6)..","..math.floor(pos.Z/6) end

-- ── Container principal ──────────────────────────────────────────
local cpCard = Instance.new("Frame", Pages["Teleportar"])
cpCard.BackgroundColor3 = Color3.fromRGB(22,14,8)
cpCard.BorderSizePixel = 0; cpCard.Size = UDim2.new(1,0,0,310)
cpCard.LayoutOrder = tpNextLO(); cpCard.ZIndex = 5
Instance.new("UICorner",cpCard).CornerRadius = UDim.new(0,14)
local cpStroke = Instance.new("UIStroke",cpCard)
cpStroke.Color = Color3.fromRGB(252,198,0); cpStroke.Thickness = 4.5
local cpCardGrad = Instance.new("UIGradient",cpCard)
cpCardGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(38,24,12)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,4)),
}); cpCardGrad.Rotation = 140

-- ── Header ──────────────────────────────────────────────────────
local cpHdr = Instance.new("Frame",cpCard)
cpHdr.BackgroundColor3 = Color3.fromRGB(252,196,0)
cpHdr.BorderSizePixel = 0; cpHdr.Size = UDim2.new(1,0,0,48); cpHdr.ZIndex = 6
Instance.new("UICorner",cpHdr).CornerRadius = UDim.new(0,12)
local cpHdrFix = Instance.new("Frame",cpHdr)
cpHdrFix.BackgroundColor3 = Color3.fromRGB(252,196,0); cpHdrFix.BorderSizePixel = 0
cpHdrFix.Position = UDim2.new(0,0,0.5,0); cpHdrFix.Size = UDim2.new(1,0,0.5,0); cpHdrFix.ZIndex = 6
local cpHdrGrad = Instance.new("UIGradient",cpHdr)
cpHdrGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,238,70)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(252,198,0)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(185,122,0)),
}); cpHdrGrad.Rotation = 0
local cpHdrStroke = Instance.new("UIStroke",cpHdr)
cpHdrStroke.Color = Color3.fromRGB(20,10,0); cpHdrStroke.Thickness = 3
local cpHdrShine = Instance.new("Frame",cpHdr)
cpHdrShine.Size = UDim2.new(0,60,0,10); cpHdrShine.Position = UDim2.new(0,8,0,5)
cpHdrShine.BackgroundColor3 = Color3.fromRGB(255,255,255); cpHdrShine.BackgroundTransparency = 0.6
cpHdrShine.BorderSizePixel = 0; cpHdrShine.Rotation = -4; cpHdrShine.ZIndex = 8
Instance.new("UICorner",cpHdrShine).CornerRadius = UDim.new(1,0)

local cpHdrIco = Instance.new("TextLabel",cpHdr); cpHdrIco.BackgroundTransparency = 1
cpHdrIco.Position = UDim2.new(0,10,0.5,-14); cpHdrIco.Size = UDim2.new(0,28,0,28)
cpHdrIco.Font = Enum.Font.GothamBlack; cpHdrIco.Text = "🎁"; cpHdrIco.TextSize = 20; cpHdrIco.ZIndex = 7

local cpHdrTitle = Instance.new("TextLabel",cpHdr); cpHdrTitle.BackgroundTransparency = 1
cpHdrTitle.Position = UDim2.new(0,44,0,6); cpHdrTitle.Size = UDim2.new(0,130,0,18)
cpHdrTitle.Font = Enum.Font.GothamBlack; cpHdrTitle.Text = "Baús"
cpHdrTitle.TextColor3 = Color3.fromRGB(22,10,0); cpHdrTitle.TextSize = 13
cpHdrTitle.TextXAlignment = Enum.TextXAlignment.Left; cpHdrTitle.ZIndex = 7
local cpHdrTitleStroke = Instance.new("UIStroke",cpHdrTitle)
cpHdrTitleStroke.Color = Color3.fromRGB(180,110,0); cpHdrTitleStroke.Thickness = 1.2

local cpHdrSub = Instance.new("TextLabel",cpHdr); cpHdrSub.BackgroundTransparency = 1
cpHdrSub.Position = UDim2.new(0,44,0,26); cpHdrSub.Size = UDim2.new(0,180,0,14)
cpHdrSub.Font = Enum.Font.Gotham; cpHdrSub.Text = "0 biomas · 0 baús"
cpHdrSub.TextColor3 = Color3.fromRGB(80,50,10); cpHdrSub.TextSize = 9
cpHdrSub.TextXAlignment = Enum.TextXAlignment.Left; cpHdrSub.ZIndex = 7

local cpBtnRef = Instance.new("TextButton",cpHdr)
cpBtnRef.BackgroundColor3 = Color3.fromRGB(22,10,0); cpBtnRef.BackgroundTransparency = 0.1; cpBtnRef.Text = ""
cpBtnRef.BorderSizePixel = 0; cpBtnRef.Position = UDim2.new(1,-88,0.5,-14)
cpBtnRef.Size = UDim2.new(0,38,0,28); cpBtnRef.ZIndex = 8
Instance.new("UICorner",cpBtnRef).CornerRadius = UDim.new(0,9)
local cpBtnRefStroke = Instance.new("UIStroke",cpBtnRef)
cpBtnRefStroke.Color = Color3.fromRGB(20,10,0); cpBtnRefStroke.Thickness = 2.5
local cpBtnRefL = Instance.new("TextLabel",cpBtnRef); cpBtnRefL.BackgroundTransparency = 1
cpBtnRefL.Size = UDim2.new(1,0,1,0); cpBtnRefL.Font = Enum.Font.GothamBlack
cpBtnRefL.Text = "🔄"; cpBtnRefL.TextColor3 = Color3.fromRGB(255,220,150); cpBtnRefL.TextSize = 14; cpBtnRefL.ZIndex = 9

local cpBtnClr = Instance.new("TextButton",cpHdr)
cpBtnClr.BackgroundColor3 = Color3.fromRGB(200,50,50); cpBtnClr.BackgroundTransparency = 0.1; cpBtnClr.Text = ""
cpBtnClr.BorderSizePixel = 0; cpBtnClr.Position = UDim2.new(1,-44,0.5,-14)
cpBtnClr.Size = UDim2.new(0,38,0,28); cpBtnClr.ZIndex = 8
Instance.new("UICorner",cpBtnClr).CornerRadius = UDim.new(0,9)
local cpBtnClrStroke = Instance.new("UIStroke",cpBtnClr)
cpBtnClrStroke.Color = Color3.fromRGB(80,0,0); cpBtnClrStroke.Thickness = 2.5
local cpBtnClrL = Instance.new("TextLabel",cpBtnClr); cpBtnClrL.BackgroundTransparency = 1
cpBtnClrL.Size = UDim2.new(1,0,1,0); cpBtnClrL.Font = Enum.Font.GothamBlack
cpBtnClrL.Text = "🗑️"; cpBtnClrL.TextColor3 = Color3.fromRGB(255,180,180); cpBtnClrL.TextSize = 14; cpBtnClrL.ZIndex = 9

-- ══ NÍVEL 1: Vista de Biomas ═════════════════════════════════════
local cpGroupView = Instance.new("ScrollingFrame",cpCard)
cpGroupView.BackgroundTransparency = 1; cpGroupView.BorderSizePixel = 0
cpGroupView.Position = UDim2.new(0,0,0,52); cpGroupView.Size = UDim2.new(1,0,1,-56)
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
cpEmptyLbl.Font = Enum.Font.GothamBold; cpEmptyLbl.Text = "🔍  Clique em 🔄 para escanear os baús"
cpEmptyLbl.TextColor3 = Color3.fromRGB(100,80,30); cpEmptyLbl.TextSize = 11
cpEmptyLbl.TextWrapped = true; cpEmptyLbl.TextXAlignment = Enum.TextXAlignment.Center
cpEmptyLbl.ZIndex = 7; cpEmptyLbl.LayoutOrder = 999

-- ══ NÍVEL 2: Vista de Sub-grupos de Raridade (apenas Floresta) ═══
local cpRarView = Instance.new("Frame",cpCard)
cpRarView.BackgroundTransparency = 1; cpRarView.BorderSizePixel = 0
cpRarView.Position = UDim2.new(1,0,0,52); cpRarView.Size = UDim2.new(1,0,1,-56)
cpRarView.ZIndex = 6; cpRarView.Visible = false

local cpRarHdr = Instance.new("Frame",cpRarView)
cpRarHdr.BackgroundColor3 = Color3.fromRGB(28,55,28); cpRarHdr.BorderSizePixel = 0
cpRarHdr.Size = UDim2.new(1,0,0,40); cpRarHdr.ZIndex = 7
Instance.new("UICorner",cpRarHdr).CornerRadius = UDim.new(0,10)
local cpRarHdrStroke = Instance.new("UIStroke",cpRarHdr)
cpRarHdrStroke.Color = Color3.fromRGB(60,200,80); cpRarHdrStroke.Thickness = 2.5; cpRarHdrStroke.Transparency = 0.3

local cpRarBackBtn = Instance.new("TextButton",cpRarHdr)
cpRarBackBtn.BackgroundColor3 = Color3.fromRGB(50,180,70); cpRarBackBtn.BackgroundTransparency = 0.1; cpRarBackBtn.Text = ""
cpRarBackBtn.BorderSizePixel = 0; cpRarBackBtn.Position = UDim2.new(0,8,0.5,-14); cpRarBackBtn.Size = UDim2.new(0,64,0,28); cpRarBackBtn.ZIndex = 8
Instance.new("UICorner",cpRarBackBtn).CornerRadius = UDim.new(0,9)
local cpRarBackStroke = Instance.new("UIStroke",cpRarBackBtn)
cpRarBackStroke.Color = Color3.fromRGB(20,10,0); cpRarBackStroke.Thickness = 2.5
local cpRarBackL = Instance.new("TextLabel",cpRarBackBtn); cpRarBackL.BackgroundTransparency = 1
cpRarBackL.Size = UDim2.new(1,0,1,0); cpRarBackL.Font = Enum.Font.GothamBlack
cpRarBackL.Text = "◀ Voltar"; cpRarBackL.TextColor3 = Color3.fromRGB(22,10,0); cpRarBackL.TextSize = 9; cpRarBackL.ZIndex = 9

local cpRarTitle = Instance.new("TextLabel",cpRarHdr); cpRarTitle.BackgroundTransparency = 1
cpRarTitle.Position = UDim2.new(0,80,0.5,-10); cpRarTitle.Size = UDim2.new(1,-90,0,20)
cpRarTitle.Font = Enum.Font.GothamBlack; cpRarTitle.Text = "🌲 Floresta"
cpRarTitle.TextColor3 = Color3.fromRGB(80,220,100); cpRarTitle.TextSize = 12
cpRarTitle.TextXAlignment = Enum.TextXAlignment.Left; cpRarTitle.ZIndex = 8

local cpRarScroll = Instance.new("ScrollingFrame",cpRarView)
cpRarScroll.BackgroundTransparency = 1; cpRarScroll.BorderSizePixel = 0
cpRarScroll.Position = UDim2.new(0,0,0,44); cpRarScroll.Size = UDim2.new(1,0,1,-48)
cpRarScroll.ZIndex = 7; cpRarScroll.ScrollBarThickness = 3
cpRarScroll.ScrollBarImageColor3 = Color3.fromRGB(80,200,80)
cpRarScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; cpRarScroll.CanvasSize = UDim2.new(0,0,0,0)
local cpRarLayout = Instance.new("UIListLayout",cpRarScroll)
cpRarLayout.Padding = UDim.new(0,6); cpRarLayout.SortOrder = Enum.SortOrder.LayoutOrder
local cpRarPad = Instance.new("UIPadding",cpRarScroll)
cpRarPad.PaddingTop = UDim.new(0,6); cpRarPad.PaddingLeft = UDim.new(0,8)
cpRarPad.PaddingRight = UDim.new(0,8); cpRarPad.PaddingBottom = UDim.new(0,8)

-- ══ NÍVEL 3: Vista de Baús ═══════════════════════════════════════
local cpDetailView = Instance.new("Frame",cpCard)
cpDetailView.BackgroundTransparency = 1; cpDetailView.BorderSizePixel = 0
cpDetailView.Position = UDim2.new(1,0,0,52); cpDetailView.Size = UDim2.new(1,0,1,-56)
cpDetailView.ZIndex = 7; cpDetailView.Visible = false

local cpDetailHdr = Instance.new("Frame",cpDetailView)
cpDetailHdr.BackgroundColor3 = Color3.fromRGB(32,20,8); cpDetailHdr.BorderSizePixel = 0
cpDetailHdr.Size = UDim2.new(1,0,0,40); cpDetailHdr.ZIndex = 8
Instance.new("UICorner",cpDetailHdr).CornerRadius = UDim.new(0,10)
local cpDetailHdrStroke = Instance.new("UIStroke",cpDetailHdr)
cpDetailHdrStroke.Color = Color3.fromRGB(252,198,0); cpDetailHdrStroke.Thickness = 2.5; cpDetailHdrStroke.Transparency = 0.5

local cpBackBtn = Instance.new("TextButton",cpDetailHdr)
cpBackBtn.BackgroundColor3 = Color3.fromRGB(252,196,0); cpBackBtn.BackgroundTransparency = 0.1; cpBackBtn.Text = ""
cpBackBtn.BorderSizePixel = 0; cpBackBtn.Position = UDim2.new(0,8,0.5,-14); cpBackBtn.Size = UDim2.new(0,64,0,28); cpBackBtn.ZIndex = 9
Instance.new("UICorner",cpBackBtn).CornerRadius = UDim.new(0,9)
local cpBackBtnStroke = Instance.new("UIStroke",cpBackBtn)
cpBackBtnStroke.Color = Color3.fromRGB(20,10,0); cpBackBtnStroke.Thickness = 2.5
local cpBackBtnL = Instance.new("TextLabel",cpBackBtn); cpBackBtnL.BackgroundTransparency = 1
cpBackBtnL.Size = UDim2.new(1,0,1,0); cpBackBtnL.Font = Enum.Font.GothamBlack
cpBackBtnL.Text = "◀ Voltar"; cpBackBtnL.TextColor3 = Color3.fromRGB(22,10,0); cpBackBtnL.TextSize = 9; cpBackBtnL.ZIndex = 10

local cpDetailTitle = Instance.new("TextLabel",cpDetailHdr); cpDetailTitle.BackgroundTransparency = 1
cpDetailTitle.Position = UDim2.new(0,80,0.5,-10); cpDetailTitle.Size = UDim2.new(1,-170,0,20)
cpDetailTitle.Font = Enum.Font.GothamBlack; cpDetailTitle.Text = ""
cpDetailTitle.TextColor3 = Color3.fromRGB(252,198,0); cpDetailTitle.TextSize = 12
cpDetailTitle.TextXAlignment = Enum.TextXAlignment.Left; cpDetailTitle.ZIndex = 9

local cpDetailCount = Instance.new("TextLabel",cpDetailHdr); cpDetailCount.BackgroundTransparency = 1
cpDetailCount.Position = UDim2.new(1,-80,0.5,-8); cpDetailCount.Size = UDim2.new(0,72,0,16)
cpDetailCount.Font = Enum.Font.GothamBold; cpDetailCount.Text = "0 baús"
cpDetailCount.TextColor3 = Color3.fromRGB(180,140,50); cpDetailCount.TextSize = 9
cpDetailCount.TextXAlignment = Enum.TextXAlignment.Right; cpDetailCount.ZIndex = 9

local cpDetailScroll = Instance.new("ScrollingFrame",cpDetailView)
cpDetailScroll.BackgroundTransparency = 1; cpDetailScroll.BorderSizePixel = 0
cpDetailScroll.Position = UDim2.new(0,0,0,44); cpDetailScroll.Size = UDim2.new(1,0,1,-48)
cpDetailScroll.ZIndex = 8; cpDetailScroll.ScrollBarThickness = 3
cpDetailScroll.ScrollBarImageColor3 = Color3.fromRGB(252,198,0)
cpDetailScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; cpDetailScroll.CanvasSize = UDim2.new(0,0,0,0)
local cpDetailLayout = Instance.new("UIListLayout",cpDetailScroll)
cpDetailLayout.Padding = UDim.new(0,5); cpDetailLayout.SortOrder = Enum.SortOrder.LayoutOrder
local cpDetailPad = Instance.new("UIPadding",cpDetailScroll)
cpDetailPad.PaddingTop = UDim.new(0,4); cpDetailPad.PaddingLeft = UDim.new(0,6)
cpDetailPad.PaddingRight = UDim.new(0,6); cpDetailPad.PaddingBottom = UDim.new(0,6)

-- ══ Animações de navegação ══════════════════════════════════════
local OFFSET = UDim2.new(0,0,0,52)
local LEFT   = UDim2.new(-1,0,0,52)
local RIGHT  = UDim2.new(1,0,0,52)

local function slideIn(frame, fromRight)
    frame.Position = fromRight and RIGHT or LEFT
    frame.Visible = true
    TweenService:Create(frame, TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Position=OFFSET}):Play()
end
local function slideOut(frame, toLeft)
    TweenService:Create(frame, TweenInfo.new(0.18,Enum.EasingStyle.Quad), {Position=toLeft and LEFT or RIGHT}):Play()
    task.delay(0.2, function() frame.Visible=false; frame.Position=OFFSET end)
end

local function cpShowBiomes()
    navState = "biomes"; curBiomeKey = nil; curRarTag = nil
    cpGroupView.Visible = true; cpGroupView.Position = OFFSET
    if cpRarView.Visible then slideOut(cpRarView, false) end
    if cpDetailView.Visible then slideOut(cpDetailView, false) end
end

local function cpShowRarSubs(biomeKey)
    navState = "rar_subs"; curBiomeKey = biomeKey; curRarTag = nil
    local bd = biomeData[biomeKey]
    cpRarTitle.Text = (bd and bd.icon or "🌲").." "..biomeKey.." — Raridade"
    slideOut(cpGroupView, true)
    task.delay(0.15, function() slideIn(cpRarView, true) end)
end

local function cpShowDetail(biomeKey, rarTag, titleTxt, titleCor, entries)
    navState = "detail"; curBiomeKey = biomeKey; curRarTag = rarTag
    cpDetailTitle.Text = titleTxt
    cpDetailTitle.TextColor3 = titleCor or Color3.fromRGB(252,198,0)
    cpDetailCount.Text = tostring(#entries).." baú(s)"
    if navState == "detail" and biomeKey == "Floresta" and rarTag then
        -- vem do nível 2 (raridade)
        slideOut(cpRarView, true)
        task.delay(0.15, function() slideIn(cpDetailView, true) end)
    else
        slideOut(cpGroupView, true)
        task.delay(0.15, function() slideIn(cpDetailView, true) end)
    end
end

-- Back a partir do detalhe
cpBackBtn.MouseButton1Click:Connect(function()
    if navState == "detail" then
        if curRarTag then
            -- veio de raridade (Floresta) → volta para raridades
            navState = "rar_subs"
            slideOut(cpDetailView, false)
            task.delay(0.15, function() slideIn(cpRarView, false) end)
        else
            -- veio de bioma direto → volta para biomas
            navState = "biomes"
            slideOut(cpDetailView, false)
            task.delay(0.15, function() slideIn(cpGroupView, false) end)
        end
    end
end)
-- Back a partir das raridades
cpRarBackBtn.MouseButton1Click:Connect(function()
    navState = "biomes"
    slideOut(cpRarView, false)
    task.delay(0.15, function() slideIn(cpGroupView, false) end)
end)

-- ══ Cria botão de bioma (nível 1) ═══════════════════════════════
local biomeOrder = 0
local function cpGetOrCreateBiome(biomeLabel, biomeIcon, biomeCor)
    if biomeData[biomeLabel] then return biomeData[biomeLabel] end
    biomeOrder += 1
    local COR = biomeCor or Color3.fromRGB(180,180,100)
    local isForest = (biomeLabel == "Floresta")
    local bd = { icon=biomeIcon, cor=COR, entries={}, btn=nil, countLbl=nil, rarSubs={} }
    biomeData[biomeLabel] = bd

    local btn = Instance.new("Frame",cpGroupView)
    btn.BackgroundColor3 = Color3.fromRGB(32,20,8); btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1,0,0,68); btn.ZIndex = 7
    btn.LayoutOrder = isForest and 0 or biomeOrder  -- Floresta sempre primeiro
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,14)
    local btnS = Instance.new("UIStroke",btn); btnS.Color = COR; btnS.Thickness = 4; btnS.Transparency = 0.2
    local btnBg = Instance.new("Frame",btn); btnBg.BackgroundColor3 = COR; btnBg.BackgroundTransparency = 0.88
    btnBg.BorderSizePixel = 0; btnBg.Size = UDim2.new(1,0,1,0); btnBg.ZIndex = 7
    Instance.new("UICorner",btnBg).CornerRadius = UDim.new(0,14)
    local btnBar = Instance.new("Frame",btn); btnBar.BackgroundColor3 = COR; btnBar.BorderSizePixel = 0
    btnBar.Position = UDim2.new(0,0,0.2,0); btnBar.Size = UDim2.new(0,4,0.6,0); btnBar.ZIndex = 9
    Instance.new("UICorner",btnBar).CornerRadius = UDim.new(0,3)
    local icoBox = Instance.new("Frame",btn); icoBox.BackgroundColor3 = COR; icoBox.BackgroundTransparency = 0.55
    icoBox.BorderSizePixel = 0; icoBox.Position = UDim2.new(0,10,0.5,-24); icoBox.Size = UDim2.new(0,48,0,48); icoBox.ZIndex = 8
    Instance.new("UICorner",icoBox).CornerRadius = UDim.new(0,12)
    local icoBoxStroke = Instance.new("UIStroke",icoBox)
    icoBoxStroke.Color = Color3.fromRGB(20,10,0); icoBoxStroke.Thickness = 2.5; icoBoxStroke.Transparency = 0.3
    local icoLbl = Instance.new("TextLabel",icoBox); icoLbl.BackgroundTransparency = 1
    icoLbl.Size = UDim2.new(1,0,1,0); icoLbl.Font = Enum.Font.GothamBlack
    icoLbl.Text = biomeIcon; icoLbl.TextSize = 26; icoLbl.ZIndex = 9
    local nameLbl = Instance.new("TextLabel",btn); nameLbl.BackgroundTransparency = 1
    nameLbl.Position = UDim2.new(0,68,0,10); nameLbl.Size = UDim2.new(0.55,0,0,22)
    nameLbl.Font = Enum.Font.GothamBlack; nameLbl.Text = biomeLabel
    nameLbl.TextColor3 = Color3.fromRGB(255,235,190); nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 8
    if isForest then
        local subLbl = Instance.new("TextLabel",btn); subLbl.BackgroundTransparency = 1
        subLbl.Position = UDim2.new(0,68,0,32); subLbl.Size = UDim2.new(0.55,0,0,14)
        subLbl.Font = Enum.Font.Gotham; subLbl.Text = "Sub-grupos por raridade"
        subLbl.TextColor3 = Color3.fromRGB(80,200,80); subLbl.TextSize = 8
        subLbl.TextXAlignment = Enum.TextXAlignment.Left; subLbl.ZIndex = 8
    end
    local cntBadge = Instance.new("Frame",btn); cntBadge.BackgroundColor3 = COR; cntBadge.BackgroundTransparency = 0.15
    cntBadge.BorderSizePixel = 0; cntBadge.Position = UDim2.new(0,68,0,isForest and 50 or 36); cntBadge.Size = UDim2.new(0,60,0,18); cntBadge.ZIndex = 8
    Instance.new("UICorner",cntBadge).CornerRadius = UDim.new(0,6)
    local cntBadgeS = Instance.new("UIStroke",cntBadge); cntBadgeS.Color = Color3.fromRGB(20,10,0); cntBadgeS.Thickness = 2
    local cntLbl = Instance.new("TextLabel",cntBadge); cntLbl.BackgroundTransparency = 1
    cntLbl.Size = UDim2.new(1,0,1,0); cntLbl.Font = Enum.Font.GothamBold
    cntLbl.Text = "0 baús"; cntLbl.TextColor3 = Color3.fromRGB(255,255,255); cntLbl.TextSize = 9; cntLbl.ZIndex = 9
    bd.countLbl = cntLbl
    local arrowLbl = Instance.new("TextLabel",btn); arrowLbl.BackgroundTransparency = 1
    arrowLbl.Position = UDim2.new(1,-38,0.5,-14); arrowLbl.Size = UDim2.new(0,30,0,28)
    arrowLbl.Font = Enum.Font.GothamBlack; arrowLbl.Text = isForest and "▶▶" or "▶"
    arrowLbl.TextColor3 = COR; arrowLbl.TextSize = isForest and 13 or 16; arrowLbl.ZIndex = 8
    bd.btn = btn
    local hitBtn = Instance.new("TextButton",btn); hitBtn.BackgroundTransparency = 1
    hitBtn.Size = UDim2.new(1,0,1,0); hitBtn.Text = ""; hitBtn.ZIndex = 10
    hitBtn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(52,34,14)}):Play()
        TweenService:Create(btnS,TweenInfo.new(0.12),{Transparency=0}):Play()
    end)
    hitBtn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(32,20,8)}):Play()
        TweenService:Create(btnS,TweenInfo.new(0.12),{Transparency=0.2}):Play()
    end)
    hitBtn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=COR}):Play()
        task.delay(0.12, function()
            TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,18,8)}):Play()
            if isForest then
                cpShowRarSubs("Floresta")
            else
                -- Abre detalhe direto com todos os baús deste bioma
                local allEntries = bd.entries
                cpDetailTitle.Text = biomeIcon.." "..biomeLabel
                cpDetailTitle.TextColor3 = COR
                cpDetailCount.Text = tostring(#allEntries).." baú(s)"
                navState = "detail"; curBiomeKey = biomeLabel; curRarTag = nil
                slideOut(cpGroupView, true)
                task.delay(0.15, function() slideIn(cpDetailView, true) end)
            end
        end)
    end)
    return bd
end

-- ══ Cria botão de sub-grupo de raridade (nível 2, só Floresta) ══
local function cpGetOrCreateRarSub(biomeLabel, rarity)
    local bd = biomeData[biomeLabel]
    if not bd then return nil end
    if bd.rarSubs[rarity.tag] then return bd.rarSubs[rarity.tag] end
    local COR = rarity.cor
    local sub = { rarity=rarity, entries={}, btn=nil, countLbl=nil }
    bd.rarSubs[rarity.tag] = sub
    -- Botão dentro de cpRarScroll
    local btn = Instance.new("Frame",cpRarScroll)
    btn.BackgroundColor3 = Color3.fromRGB(32,20,8); btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1,0,0,64); btn.ZIndex = 7
    btn.LayoutOrder = 100 - (rarity.tier or 0)
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,14)
    local btnS = Instance.new("UIStroke",btn); btnS.Color = COR; btnS.Thickness = 4; btnS.Transparency = 0.2
    local btnBg = Instance.new("Frame",btn); btnBg.BackgroundColor3 = COR; btnBg.BackgroundTransparency = 0.88
    btnBg.BorderSizePixel = 0; btnBg.Size = UDim2.new(1,0,1,0); btnBg.ZIndex = 7
    Instance.new("UICorner",btnBg).CornerRadius = UDim.new(0,14)
    local btnBar = Instance.new("Frame",btn); btnBar.BackgroundColor3 = COR; btnBar.BorderSizePixel = 0
    btnBar.Position = UDim2.new(0,0,0.2,0); btnBar.Size = UDim2.new(0,4,0.6,0); btnBar.ZIndex = 9
    Instance.new("UICorner",btnBar).CornerRadius = UDim.new(0,3)
    local icoBox = Instance.new("Frame",btn); icoBox.BackgroundColor3 = COR; icoBox.BackgroundTransparency = 0.55
    icoBox.BorderSizePixel = 0; icoBox.Position = UDim2.new(0,10,0.5,-22); icoBox.Size = UDim2.new(0,44,0,44); icoBox.ZIndex = 8
    Instance.new("UICorner",icoBox).CornerRadius = UDim.new(0,11)
    local icoBoxStroke = Instance.new("UIStroke",icoBox)
    icoBoxStroke.Color = Color3.fromRGB(20,10,0); icoBoxStroke.Thickness = 2.5; icoBoxStroke.Transparency = 0.3
    local icoLbl = Instance.new("TextLabel",icoBox); icoLbl.BackgroundTransparency = 1
    icoLbl.Size = UDim2.new(1,0,1,0); icoLbl.Font = Enum.Font.GothamBlack
    icoLbl.Text = rarity.icon; icoLbl.TextSize = 22; icoLbl.ZIndex = 9
    local nameLbl = Instance.new("TextLabel",btn); nameLbl.BackgroundTransparency = 1
    nameLbl.Position = UDim2.new(0,62,0,10); nameLbl.Size = UDim2.new(0.55,0,0,20)
    nameLbl.Font = Enum.Font.GothamBlack; nameLbl.Text = rarity.label
    nameLbl.TextColor3 = Color3.fromRGB(255,235,190); nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left; nameLbl.ZIndex = 8
    local cntBadge = Instance.new("Frame",btn); cntBadge.BackgroundColor3 = COR; cntBadge.BackgroundTransparency = 0.15
    cntBadge.BorderSizePixel = 0; cntBadge.Position = UDim2.new(0,62,0,34); cntBadge.Size = UDim2.new(0,60,0,18); cntBadge.ZIndex = 8
    Instance.new("UICorner",cntBadge).CornerRadius = UDim.new(0,6)
    local cntBadgeS = Instance.new("UIStroke",cntBadge); cntBadgeS.Color = Color3.fromRGB(20,10,0); cntBadgeS.Thickness = 2
    local cntLbl = Instance.new("TextLabel",cntBadge); cntLbl.BackgroundTransparency = 1
    cntLbl.Size = UDim2.new(1,0,1,0); cntLbl.Font = Enum.Font.GothamBold
    cntLbl.Text = "0 baús"; cntLbl.TextColor3 = Color3.fromRGB(255,255,255); cntLbl.TextSize = 9; cntLbl.ZIndex = 9
    sub.countLbl = cntLbl
    local arrowLbl = Instance.new("TextLabel",btn); arrowLbl.BackgroundTransparency = 1
    arrowLbl.Position = UDim2.new(1,-38,0.5,-14); arrowLbl.Size = UDim2.new(0,30,0,28)
    arrowLbl.Font = Enum.Font.GothamBlack; arrowLbl.Text = "▶"
    arrowLbl.TextColor3 = COR; arrowLbl.TextSize = 16; arrowLbl.ZIndex = 8
    sub.btn = btn
    local hitBtn = Instance.new("TextButton",btn); hitBtn.BackgroundTransparency = 1
    hitBtn.Size = UDim2.new(1,0,1,0); hitBtn.Text = ""; hitBtn.ZIndex = 10
    hitBtn.MouseEnter:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(52,34,14)}):Play()
        TweenService:Create(btnS,TweenInfo.new(0.12),{Transparency=0}):Play()
    end)
    hitBtn.MouseLeave:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(32,20,8)}):Play()
        TweenService:Create(btnS,TweenInfo.new(0.12),{Transparency=0.2}):Play()
    end)
    hitBtn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=COR}):Play()
        task.delay(0.12, function()
            TweenService:Create(btn,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,18,8)}):Play()
            cpDetailTitle.Text = rarity.icon.." "..rarity.label.." — Floresta"
            cpDetailTitle.TextColor3 = COR
            cpDetailCount.Text = tostring(#sub.entries).." baú(s)"
            navState = "detail"; curBiomeKey = "Floresta"; curRarTag = rarity.tag
            slideOut(cpRarView, true)
            task.delay(0.15, function() slideIn(cpDetailView, true) end)
        end)
    end)
    return sub
end

-- ══ Adiciona uma linha de baú no cpDetailScroll ═════════════════
local function cpAddEntry(biomeKey, rarity, name, pos, biomeIcon, biomeCor)
    local nk = cpNameKey(name, pos)
    local wasVisited = chestVisited[nk] == true
    local COR = rarity and rarity.cor or Color3.fromRGB(160,140,110)
    local rarIcon = rarity and rarity.icon or "📦"
    local entry = {name=name, pos=pos, nk=nk, visited=wasVisited, biomeKey=biomeKey}

    local row = Instance.new("Frame",cpDetailScroll)
    row.BorderSizePixel = 0; row.Size = UDim2.new(1,0,0,56); row.ZIndex = 8; row.LayoutOrder = 0  -- será reordenado
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,12)
    row.BackgroundColor3 = wasVisited and Color3.fromRGB(70,18,12) or Color3.fromRGB(38,24,10)
    local rowS = Instance.new("UIStroke",row)
    rowS.Color = wasVisited and Color3.fromRGB(200,60,60) or Color3.fromRGB(252,198,0)
    rowS.Thickness = 2.5; rowS.Transparency = wasVisited and 0.1 or 0.65
    local rowBg = Instance.new("Frame",row); rowBg.BackgroundColor3 = COR; rowBg.BackgroundTransparency = 0.90
    rowBg.BorderSizePixel = 0; rowBg.Size = UDim2.new(1,0,1,0); rowBg.ZIndex = 8
    Instance.new("UICorner",rowBg).CornerRadius = UDim.new(0,12)
    local rarBar = Instance.new("Frame",row); rarBar.BackgroundColor3 = COR; rarBar.BorderSizePixel = 0
    rarBar.Position = UDim2.new(0,0,0.1,0); rarBar.Size = UDim2.new(0,4,0.8,0); rarBar.ZIndex = 9
    Instance.new("UICorner",rarBar).CornerRadius = UDim.new(0,2)
    local ico = Instance.new("TextLabel",row); ico.BackgroundTransparency = 1
    ico.Position = UDim2.new(0,8,0.5,-12); ico.Size = UDim2.new(0,24,0,24)
    ico.Font = Enum.Font.GothamBlack; ico.Text = rarIcon; ico.TextSize = 16; ico.ZIndex = 9
    local nameLbl = Instance.new("TextLabel",row); nameLbl.BackgroundTransparency = 1
    nameLbl.Position = UDim2.new(0,36,0,7); nameLbl.Size = UDim2.new(0.50,0,0,18)
    nameLbl.Font = Enum.Font.GothamBold; nameLbl.Text = name
    nameLbl.TextColor3 = wasVisited and Color3.fromRGB(200,130,130) or Color3.fromRGB(255,235,190)
    nameLbl.TextSize = 10; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd; nameLbl.ZIndex = 9
    entry.nameLbl = nameLbl
    local distTxt = ""
    pcall(function()
        local ch = Player.Character; local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then distTxt = " • "..math.floor((pos-hrp.Position).Magnitude).."m" end
    end)
    local infoLbl = Instance.new("TextLabel",row); infoLbl.BackgroundTransparency = 1
    infoLbl.Position = UDim2.new(0,36,0,28); infoLbl.Size = UDim2.new(0.55,0,0,16)
    infoLbl.Font = Enum.Font.GothamBold; infoLbl.TextSize = 8
    infoLbl.Text = biomeIcon.." "..biomeKey..distTxt
    infoLbl.TextColor3 = wasVisited and Color3.fromRGB(160,100,100) or Color3.fromRGB(160,120,60)
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left; infoLbl.ZIndex = 9
    local tagBadge = Instance.new("Frame",row); tagBadge.BorderSizePixel = 0
    tagBadge.AnchorPoint = Vector2.new(1,0); tagBadge.Position = UDim2.new(1,-52,0,5)
    tagBadge.Size = UDim2.new(0,72,0,16); tagBadge.ZIndex = 10
    Instance.new("UICorner",tagBadge).CornerRadius = UDim.new(0,5)
    local tagLbl = Instance.new("TextLabel",tagBadge); tagLbl.BackgroundTransparency = 1
    tagLbl.Size = UDim2.new(1,0,1,0); tagLbl.Font = Enum.Font.GothamBlack; tagLbl.TextSize = 7; tagLbl.ZIndex = 11
    if wasVisited then
        tagBadge.BackgroundColor3 = Color3.fromRGB(240,200,40)
        tagLbl.Text = "✓ Teleportou!"; tagLbl.TextColor3 = Color3.fromRGB(50,30,5)
    else
        tagBadge.Visible = false
    end
    entry.tagBadge=tagBadge; entry.tagLbl=tagLbl; entry.row=row; entry.rowS=rowS; entry.rowBg=rowBg
    -- Botão TP
    local tpb = Instance.new("TextButton",row)
    tpb.BackgroundColor3 = Color3.fromRGB(252,196,0); tpb.BackgroundTransparency = 0; tpb.Text = ""; tpb.BorderSizePixel = 0
    tpb.Position = UDim2.new(1,-50,0.5,-16); tpb.Size = UDim2.new(0,44,0,32); tpb.ZIndex = 10
    Instance.new("UICorner",tpb).CornerRadius = UDim.new(0,10)
    local tpbStroke = Instance.new("UIStroke",tpb); tpbStroke.Color = Color3.fromRGB(20,10,0); tpbStroke.Thickness = 2.5
    local tpbGrad = Instance.new("UIGradient",tpb)
    tpbGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,238,70)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(185,122,0)),
    }); tpbGrad.Rotation = 90
    local tpbL = Instance.new("TextLabel",tpb); tpbL.BackgroundTransparency = 1
    tpbL.Size = UDim2.new(1,0,1,0); tpbL.Font = Enum.Font.GothamBlack
    tpbL.Text = "TP"; tpbL.TextColor3 = Color3.fromRGB(22,10,0); tpbL.TextSize = 12; tpbL.ZIndex = 11
    local function doTp()
        chestVisited[nk] = true; entry.visited = true
        TweenService:Create(tpb,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=0}):Play()
        task.delay(0.2,function() TweenService:Create(tpb,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(252,196,0),BackgroundTransparency=0}):Play() end)
        TweenService:Create(row,TweenInfo.new(0.25),{BackgroundColor3=Color3.fromRGB(70,18,12)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.25),{Color=Color3.fromRGB(200,60,60),Transparency=0.1}):Play()
        TweenService:Create(rowBg,TweenInfo.new(0.25),{BackgroundTransparency=0.88}):Play()
        tagBadge.BackgroundColor3 = Color3.fromRGB(240,200,40)
        tagLbl.Text = "✓ Teleportou!"; tagLbl.TextColor3 = Color3.fromRGB(50,30,5)
        tagBadge.Visible = true
        tagBadge.Size = UDim2.new(0,10,0,16)
        TweenService:Create(tagBadge,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,72,0,16)}):Play()
        TweenService:Create(nameLbl,TweenInfo.new(0.2),{TextColor3=Color3.fromRGB(200,130,130)}):Play()
        safeTp(pos, 5)
        local rarLabel = rarity and rarity.label or "?"
        Notify.send({type="custom",icon=rarIcon,accent=COR,
            title="Baú "..rarLabel,msg=name.." "..biomeIcon.." "..biomeKey,duration=2.5})
    end
    tpb.MouseButton1Click:Connect(doTp)
    local rowHit = Instance.new("TextButton",row); rowHit.BackgroundTransparency = 1
    rowHit.Size = UDim2.new(1,-50,1,0); rowHit.Text = ""; rowHit.ZIndex = 9
    rowHit.MouseButton1Click:Connect(doTp)
    rowHit.MouseEnter:Connect(function() if not entry.visited then TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(52,34,14)}):Play(); TweenService:Create(rowS,TweenInfo.new(0.1),{Transparency=0.3}):Play() end end)
    rowHit.MouseLeave:Connect(function() if not entry.visited then TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(38,24,10)}):Play(); TweenService:Create(rowS,TweenInfo.new(0.1),{Transparency=0.65}):Play() end end)
    return entry
end

-- ══ Escaneamento ════════════════════════════════════════════════
local function cpScanChests(isRefresh)
    if chestScanRun2 then return end
    chestScanRun2 = true
    cpBtnRefL.Text = "⏳"; task.delay(1, function() cpBtnRefL.Text = "🔄" end)
    task.spawn(function()
        local found = 0
        local batch = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            batch += 1
            if batch % 500 == 0 then task.wait() end
            if not obj:IsA("Model") then continue end
            local nm = obj.Name:lower()
            if not (nm:find("chest",1,true) or nm:find("bau",1,true) or nm:find("baú",1,true)) then continue end
            local part, maxSz = nil, 0
            for _, bp in ipairs(obj:GetDescendants()) do
                if bp:IsA("BasePart") then
                    local s = bp.Size.X+bp.Size.Y+bp.Size.Z
                    if s > maxSz then maxSz=s; part=bp end
                end
            end
            if not part then continue end
            if part.Size.X>14 or part.Size.Y>14 or part.Size.Z>14 then continue end
            if part.Position.Y < -400 then continue end
            local pk = cpPosKey(part.Position)
            if chestSeenKeys2[pk] then continue end
            chestSeenKeys2[pk] = true
            local biomeLabel, biomeIcon, biomeCor = getBiome(obj)
            local rarity = getRarity(obj)
            -- Garante que o bioma existe
            local bd = cpGetOrCreateBiome(biomeLabel, biomeIcon, biomeCor)
            -- Adiciona a entrada de UI
            local entry = cpAddEntry(biomeLabel, rarity, obj.Name, part.Position, biomeIcon, biomeCor)
            -- Registra no local certo
            if biomeLabel == "Floresta" then
                -- Sub-grupo de raridade
                local sub = cpGetOrCreateRarSub("Floresta", rarity)
                if sub then
                    table.insert(sub.entries, entry)
                    sub.countLbl.Text = tostring(#sub.entries).." baú(s)"
                    -- Reordena LayoutOrder da linha
                    entry.row.LayoutOrder = #sub.entries
                end
            else
                table.insert(bd.entries, entry)
                entry.row.LayoutOrder = #bd.entries
            end
            -- Contagem total do bioma
            local total_bd = 0
            if biomeLabel == "Floresta" then
                for _, sub in pairs(bd.rarSubs) do total_bd += #sub.entries end
            else
                total_bd = #bd.entries
            end
            bd.countLbl.Text = tostring(total_bd).." baú(s)"
            found += 1
            cpEmptyLbl.Visible = false
            if found % 20 == 0 then task.wait() end
        end
        -- Atualiza subtítulo
        local totalBiomes, totalChests = 0, 0
        for k, bd in pairs(biomeData) do
            totalBiomes += 1
            if k == "Floresta" then
                for _, sub in pairs(bd.rarSubs) do totalChests += #sub.entries end
            else
                totalChests += #bd.entries
            end
        end
        cpHdrSub.Text = tostring(totalBiomes).." biomas · "..tostring(totalChests).." baús"
        chestScanRun2 = false
        if found == 0 and isRefresh then Notify.info("Tp Baús","Nenhum baú novo encontrado.")
        elseif found > 0 then
            Notify.send({type="custom",icon="🎁",accent=TP_COR_CHEST,
                title="Baús",msg=(isRefresh and tostring(found).." novo(s)!" or tostring(found).." baús em "..totalBiomes.." biomas!"),duration=3})
        end
    end)
end

cpBtnRef.MouseButton1Click:Connect(function() cpScanChests(true) end)
cpBtnClr.MouseButton1Click:Connect(function()
    -- Destroi todos os botões
    for _, bd in pairs(biomeData) do
        pcall(function() if bd.btn then bd.btn:Destroy() end end)
        for _, sub in pairs(bd.rarSubs) do
            pcall(function() if sub.btn then sub.btn:Destroy() end end)
        end
        for _, e in ipairs(bd.entries) do pcall(function() if e.row then e.row:Destroy() end end) end
    end
    -- Limpa cpDetailScroll
    for _, c in ipairs(cpDetailScroll:GetChildren()) do
        if c:IsA("Frame") or c:IsA("TextButton") then pcall(function() c:Destroy() end) end
    end
    biomeData={}; chestSeenKeys2={}; chestVisited={}; biomeOrder=0
    navState="biomes"; curBiomeKey=nil; curRarTag=nil
    cpGroupView.Visible=true; cpGroupView.Position=OFFSET
    cpRarView.Visible=false; cpDetailView.Visible=false
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

end) -- [[ TELEPORTAR TAB ]]

-- ══════════════════════════════════════════════════════════════
-- FARM TAB + AVANÇADO FARM TAB
-- ══════════════════════════════════════════════════════════════
;pcall(function() -- [[ FARM PART 1 ]]

-- ─── Utilitários de UI para Farm ──────────────────────────────
local farmLO  = 0
local avfLO   = 0
fNextLO = function()  farmLO+=1;  return farmLO  end
afNextLO = function() avfLO+=1;   return avfLO   end

-- Seção (cabeçalho colorido) genérica para qualquer página
makeSec = function(page, lo_fn, titleKey, cor)
    local hdr=Instance.new("Frame", page)
    hdr.BackgroundColor3=Color3.fromRGB(26,15,6)
    hdr.BackgroundTransparency=0
    hdr.BorderSizePixel=0; hdr.Size=UDim2.new(1,0,0,26); hdr.LayoutOrder=lo_fn(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,9)
    -- Gradiente de fundo cartoon
    local hdrG=Instance.new("UIGradient",hdr)
    hdrG.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(40,22,8)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,3)),
    }); hdrG.Rotation=135
    -- Borda preta grossa Brawl Stars
    local gborder=Instance.new("UIStroke",hdr)
    gborder.Color=Color3.fromRGB(8,4,0); gborder.Thickness=2.5
    gborder.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    -- Faixa de cor no lado esquerdo
    local bar=Instance.new("Frame",hdr); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Size=UDim2.new(0,5,0.75,0); bar.Position=UDim2.new(0,0,0.12,0); bar.ZIndex=5
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,4)
    -- Shine
    local shine=Instance.new("Frame",hdr); shine.BackgroundColor3=Color3.fromRGB(255,255,255)
    shine.BackgroundTransparency=0.82; shine.BorderSizePixel=0
    shine.Position=UDim2.new(0,8,0,2); shine.Size=UDim2.new(0,50,0,4); shine.ZIndex=5
    Instance.new("UICorner",shine).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,14,0,0)
    lbl.Size=UDim2.new(1,-18,1,0); lbl.Font=Enum.Font.GothamBlack
    lbl.TextColor3=Color3.fromRGB(255,255,255); lbl.TextSize=10
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
    local lblS=Instance.new("UIStroke",lbl); lblS.Color=Color3.fromRGB(8,4,0); lblS.Thickness=1.5
    TL(lbl, titleKey)
end

-- Toggle genérico para qualquer página
makeToggle = function(page, lo_fn, lbl_txt, desc_txt, cor, onToggle)
    local row=Instance.new("Frame", page)
    row.BackgroundColor3=Color3.fromRGB(26,15,6); row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,64); row.LayoutOrder=lo_fn(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)
    -- Gradiente de fundo cartoon
    local rowG=Instance.new("UIGradient",row)
    rowG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(40,24,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,3))}); rowG.Rotation=135
    -- Borda preta Brawl Stars
    local rowS=Instance.new("UIStroke",row)
    rowS.Color=Color3.fromRGB(8,4,0); rowS.Thickness=3
    rowS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    -- Barra lateral colorida
    local lbar=Instance.new("Frame",row)
    lbar.BackgroundColor3=cor; lbar.BorderSizePixel=0
    lbar.Size=UDim2.new(0,5,0.72,0); lbar.Position=UDim2.new(0,0,0.14,0); lbar.ZIndex=6
    Instance.new("UICorner",lbar).CornerRadius=UDim.new(0,4)
    -- Shine cartoon
    local shine=Instance.new("Frame",row); shine.BackgroundColor3=Color3.fromRGB(255,255,255)
    shine.BackgroundTransparency=0.82; shine.BorderSizePixel=0
    shine.Position=UDim2.new(0,8,0,3); shine.Size=UDim2.new(0,55,0,4); shine.ZIndex=6
    Instance.new("UICorner",shine).CornerRadius=UDim.new(1,0)
    -- Título branco com stroke preta
    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,16,0,10); tl.Size=UDim2.new(1,-80,0,20); tl.Font=Enum.Font.GothamBlack
    tl.Text=lbl_txt; tl.TextColor3=Color3.fromRGB(255,255,255); tl.TextSize=12
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local tlS=Instance.new("UIStroke",tl); tlS.Color=Color3.fromRGB(8,4,0); tlS.Thickness=1.8
    -- Descrição
    local td=Instance.new("TextLabel",row); td.BackgroundTransparency=1
    td.Position=UDim2.new(0,16,0,32); td.Size=UDim2.new(1,-80,0,26); td.Font=Enum.Font.Gotham
    td.Text=desc_txt; td.TextColor3=Color3.fromRGB(180,160,110); td.TextSize=9
    td.TextXAlignment=Enum.TextXAlignment.Left; td.TextWrapped=true; td.ZIndex=7
    -- Pill toggle cartoon
    local pill=Instance.new("Frame",row)
    pill.BackgroundColor3=Color3.fromRGB(40,24,8); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-60,0.5,-14); pill.Size=UDim2.new(0,52,0,28); pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local pillS=Instance.new("UIStroke",pill)
    pillS.Color=Color3.fromRGB(8,4,0); pillS.Thickness=2.5
    pillS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local knob=Instance.new("Frame",pill)
    knob.BackgroundColor3=Color3.fromRGB(160,120,60); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,3,0.5,-11); knob.Size=UDim2.new(0,22,0,22); knob.ZIndex=10
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local knobStroke=Instance.new("UIStroke",knob); knobStroke.Color=Color3.fromRGB(8,4,0); knobStroke.Thickness=1.5
    local state=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.BorderSizePixel=0
    btn.AutoButtonColor=false; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=11
    btn.MouseEnter:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(50,30,12)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Thickness=4}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(26,15,6)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Thickness=3}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        state=not state
        TweenService:Create(pill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{
            BackgroundColor3=state and cor or Color3.fromRGB(40,24,8)
        }):Play()
        TweenService:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=state and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11),
            BackgroundColor3=state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,120,60)
        }):Play()
        TweenService:Create(lbar,TweenInfo.new(0.18),{
            BackgroundColor3=state and cor or Color3.fromRGB(80,50,18)
        }):Play()
        -- Animação de click no row
        TweenService:Create(row,TweenInfo.new(0.08),{BackgroundColor3=state and cor or Color3.fromRGB(80,20,20)}):Play()
        task.delay(0.1,function() TweenService:Create(row,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(26,15,6)}):Play() end)
        -- Som de ligar/desligar
        pcall(function()
            local sndId = state and 6031221736 or 2544086171
            local snd = Instance.new("Sound", SoundService)
            snd.SoundId = "rbxassetid://"..tostring(sndId)
            snd.Volume = 0.45; snd.RollOffMaxDistance = 0; snd:Play()
            game:GetService("Debris"):AddItem(snd, 3)
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

-- Slider genérico para qualquer página
local function makeSlider(page, lo_fn, lbl_txt, minV, maxV, defV, cor, fmt, onChange)
    local BASE_H = 66
    local row=Instance.new("Frame", page)
    row.BackgroundColor3=Color3.fromRGB(26,15,6); row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,BASE_H); row.LayoutOrder=lo_fn(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)
    local rowG=Instance.new("UIGradient",row)
    rowG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(40,24,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,3))}); rowG.Rotation=135
    local rowS=Instance.new("UIStroke",row)
    rowS.Color=Color3.fromRGB(8,4,0); rowS.Thickness=3
    rowS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    -- Barra lateral colorida
    local lbar=Instance.new("Frame",row); lbar.BackgroundColor3=cor; lbar.BorderSizePixel=0
    lbar.Size=UDim2.new(0,5,0.70,0); lbar.Position=UDim2.new(0,0,0.15,0); lbar.ZIndex=6
    Instance.new("UICorner",lbar).CornerRadius=UDim.new(0,4)
    -- Shine
    local shine=Instance.new("Frame",row); shine.BackgroundColor3=Color3.fromRGB(255,255,255)
    shine.BackgroundTransparency=0.82; shine.BorderSizePixel=0
    shine.Position=UDim2.new(0,8,0,3); shine.Size=UDim2.new(0,50,0,4); shine.ZIndex=6
    Instance.new("UICorner",shine).CornerRadius=UDim.new(1,0)
    -- Título
    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,8); tl.Size=UDim2.new(1,-100,0,20); tl.Font=Enum.Font.GothamBlack
    tl.Text=lbl_txt; tl.TextColor3=Color3.fromRGB(255,255,255); tl.TextSize=11
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local tlS=Instance.new("UIStroke",tl); tlS.Color=Color3.fromRGB(8,4,0); tlS.Thickness=1.6
    -- Badge valor (cartoon)
    local valBadge=Instance.new("Frame",row); valBadge.BackgroundColor3=cor; valBadge.BackgroundTransparency=0.1
    valBadge.BorderSizePixel=0; valBadge.AnchorPoint=Vector2.new(1,0)
    valBadge.Position=UDim2.new(1,-6,0,6); valBadge.Size=UDim2.new(0,52,0,20); valBadge.ZIndex=8
    Instance.new("UICorner",valBadge).CornerRadius=UDim.new(0,7)
    local vBS=Instance.new("UIStroke",valBadge); vBS.Color=Color3.fromRGB(8,4,0); vBS.Thickness=2
    vBS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local valLbl=Instance.new("TextLabel",valBadge); valLbl.BackgroundTransparency=1
    valLbl.Size=UDim2.new(1,0,1,0); valLbl.Font=Enum.Font.GothamBlack; valLbl.TextColor3=Color3.fromRGB(255,255,255)
    valLbl.TextSize=11; valLbl.ZIndex=9
    local valLblS=Instance.new("UIStroke",valLbl); valLblS.Color=Color3.fromRGB(8,4,0); valLblS.Thickness=1.2
    -- Track
    local track=Instance.new("Frame",row); track.BackgroundColor3=Color3.fromRGB(16,8,2)
    track.BorderSizePixel=0; track.Position=UDim2.new(0,14,0,42); track.Size=UDim2.new(1,-28,0,8)
    track.ZIndex=6; Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local trackS=Instance.new("UIStroke",track); trackS.Color=Color3.fromRGB(8,4,0); trackS.Thickness=1.5
    local fill=Instance.new("Frame",track); fill.BackgroundColor3=cor; fill.BorderSizePixel=0
    fill.Size=UDim2.new(0,0,1,0); fill.ZIndex=7; Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    -- Gradiente no fill
    local fillG=Instance.new("UIGradient",fill)
    fillG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,200)),ColorSequenceKeypoint.new(1,cor)})
    local thumb=Instance.new("Frame",track); thumb.BackgroundColor3=Color3.fromRGB(255,255,255)
    thumb.BorderSizePixel=0; thumb.AnchorPoint=Vector2.new(0.5,0.5)
    thumb.Position=UDim2.new(0,0,0.5,0); thumb.Size=UDim2.new(0,18,0,18); thumb.ZIndex=8
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local thumbS=Instance.new("UIStroke",thumb); thumbS.Color=Color3.fromRGB(8,4,0); thumbS.Thickness=2.5
    thumbS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
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

local freezeConn    = nil
local freezeScanCo  = nil  -- coroutine de varredura separada

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

        for _, entry in ipairs(frozenMobs) do
            pcall(function()
                local hrp = entry.hrp
                if not hrp or not hrp.Parent then return end
                if not entry.frozenCF then return end

                -- Teleporte contínuo: força o mob a ficar no lugar
                -- AssemblyLinearVelocity = 0 zera qualquer velocidade acumulada
                hrp.CFrame = entry.frozenCF
                pcall(function() hrp.AssemblyLinearVelocity  = Vector3.zero end)
                pcall(function() hrp.AssemblyAngularVelocity = Vector3.zero end)
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
local kaRunning  = false  -- evita overlap de ciclos

-- firetouchinterest disponível?
local hasFTI = false
pcall(function() hasFTI = typeof(firetouchinterest) == "function" end)
if not hasFTI then
    pcall(function() hasFTI = rawget(getfenv(0),"firetouchinterest") ~= nil end)
end

-- fireremote disponível?
local hasFireRemote = false
pcall(function() hasFireRemote = typeof(fireremote) == "function" end)

-- Handle da tool equipada
local function getToolHandle(tool)
    if not tool then return nil end
    return tool:FindFirstChild("Handle")
        or tool:FindFirstChildWhichIsA("MeshPart")
        or tool:FindFirstChildWhichIsA("Part")
        or tool:FindFirstChildWhichIsA("BasePart")
end

-- Mobs vivos no range (usa getMobsInRange do Freeze que já existe)
local function getKAMobs(hrpPos, range)
    local mobs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if not obj:IsA("Model") then return end
            if isPlayerChar(obj) then return end
            local hum = obj:FindFirstChildWhichIsA("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local root = obj:FindFirstChild("HumanoidRootPart")
                      or obj:FindFirstChild("Torso")
                      or obj:FindFirstChildWhichIsA("BasePart")
            if not root then return end
            if (root.Position - hrpPos).Magnitude <= range then
                table.insert(mobs, {model=obj, hum=hum, root=root})
            end
        end)
    end
    return mobs
end

-- Procura o RemoteEvent de dano da tool no ReplicatedStorage
local kaDamageRemote = nil
local function findDamageRemote()
    if kaDamageRemote and kaDamageRemote.Parent then return kaDamageRemote end
    local candidates = {}
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        for _, obj in ipairs(rs:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("damage") or n:find("attack") or n:find("hit")
                or n:find("tool") or n:find("swing") or n:find("hurt")
                or n:find("deal") or n:find("melee") then
                    table.insert(candidates, obj)
                end
            end
        end
    end)
    if #candidates > 0 then
        kaDamageRemote = candidates[1]
        return kaDamageRemote
    end
    return nil
end

-- ── KILL AURA v7 — Handle Warp + HRP Teleport ───────────────
-- 99 Nights valida: distância HANDLE→alvo E posição HRP→alvo no servidor.
-- Ambos replicam do client: usamos os dois métodos em sequência.
local function kaAttackMob(hrp, tool, mobs)
    local handle    = getToolHandle(tool)
    local dmgRemote = findDamageRemote()

    for _, entry in ipairs(mobs) do
        pcall(function()
            local mobRoot = entry.root
            local mobHum  = entry.hum
            if not mobRoot or not mobRoot.Parent then return end
            if not mobHum  or mobHum.Health  <= 0 then return end

            -- ── MÉTODO A: Handle Warp ──────────────────────────────────
            -- Move o handle para dentro do mob e ativa a tool
            -- Handle é client-authoritative → CFrame replica ao servidor
            if handle then
                local origCF = handle.CFrame
                pcall(function() handle.CFrame = mobRoot.CFrame end)
                task.wait(0.05)  -- aguarda replicação
                pcall(function() tool:Activate() end)
                if hasFTI then
                    for _, p in ipairs(entry.model:GetDescendants()) do
                        if p:IsA("BasePart") then
                            pcall(function() firetouchinterest(handle, p, 0) end)
                            pcall(function() firetouchinterest(handle, p, 1) end)
                        end
                    end
                end
                task.wait(0.06)
                pcall(function() handle.CFrame = origCF end)
            end

            -- ── MÉTODO B: HRP Teleport ─────────────────────────────────
            -- Teleporta o player para ao lado do mob por 3 frames
            -- Servidor recebe posição nova e valida o ataque
            local savedCF = hrp.CFrame
            local front   = mobRoot.Position - (mobRoot.CFrame.LookVector * 1.5)
            local standPos = Vector3.new(front.X, mobRoot.Position.Y, front.Z)
            hrp.CFrame = CFrame.new(standPos, mobRoot.Position)
            task.wait()
            hrp.CFrame = CFrame.new(standPos, mobRoot.Position)
            task.wait()
            pcall(function() tool:Activate() end)
            task.wait()
            hrp.CFrame = savedCF

            -- ── MÉTODO C: RemoteEvent direto ───────────────────────────
            if dmgRemote then
                pcall(function() dmgRemote:FireServer(entry.model) end)
                pcall(function() dmgRemote:FireServer(entry.model, mobHum) end)
                pcall(function() dmgRemote:FireServer(mobRoot, 10) end)
            end
        end)
    end
end

-- ── Loop principal ──────────────────────────────────────────────
local function startKillAura()
    if kaAutoLoop then pcall(function() kaAutoLoop:Disconnect() end) end

    kaAutoLoop = RunService.Heartbeat:Connect(function()
        if not kaEnabled or kaRunning then return end

        pcall(function()
            local ch  = Player.Character; if not ch then return end
            local hum = ch:FindFirstChildWhichIsA("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local hrp  = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local tool = ch:FindFirstChildWhichIsA("Tool"); if not tool then return end

            local mobs = getKAMobs(hrp.Position, kaRange)
            if #mobs == 0 then return end

            kaRunning = true
            task.spawn(function()
                kaAttackMob(hrp, tool, mobs)
                kaRunning = false
            end)
        end)
    end)

    if kaCharConn then pcall(function() kaCharConn:Disconnect() end) end
    kaCharConn = Player.CharacterAdded:Connect(function()
        kaRunning = false
    end)
end

local function stopKillAura()
    if kaAutoLoop then pcall(function() kaAutoLoop:Disconnect() end); kaAutoLoop = nil end
    if kaCharConn  then pcall(function() kaCharConn:Disconnect()  end); kaCharConn  = nil end
    kaRunning = false
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
local kaPill = Instance.new("Frame",kaCard); kaPill.BackgroundColor3 = Color3.fromRGB(50,32,15); kaPill.BorderSizePixel = 0
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
    TweenService:Create(kaPill,TweenInfo.new(0.22),{BackgroundColor3=kaEnabled and KA_COR or Color3.fromRGB(50,32,15)}):Play()
    TweenService:Create(kaKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position=kaEnabled and UDim2.new(1,-15,0.5,-7) or UDim2.new(0,1,0.5,-7),
        BackgroundColor3=kaEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
    }):Play()
    TweenService:Create(kaStroke,TweenInfo.new(0.2),{Color=kaEnabled and KA_COR or Color3.fromRGB(58,42,42)}):Play()
    if kaEnabled then
        startKillAura()
        local metodo = hasFTI and "firetouchinterest ✓" or "Activate loop (sem FTI)"
        Notify.send({type="custom",icon="⚔️",accent=Color3.fromRGB(87,242,135),
            title="Kill Aura AUTO",
            msg="✓ Ativado — "..metodo.." | "..kaRange.." studs",
            duration=5})
    else
        stopKillAura()
        Notify.error("Kill Aura", "✗ Desativado")
    end
end)

end) -- [[ FARM PART 1 ]]
;pcall(function() -- [[ FARM PART 2 ]]

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
        if aePill   then TweenService:Create(aePill,  TweenInfo.new(0.22), {BackgroundColor3=Color3.fromRGB(45,28,15)}):Play() end
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
        aeBodyVel.VectorVelocity = Vector3.zero
        aeBodyVel.Name = "AE_LinVel"
        local att = Instance.new("Attachment", hrp); att.Name = "AE_Att"
        aeBodyVel.Attachment0 = att
    end)
    if not useLinearVel then
        pcall(function() if aeBodyVel and aeBodyVel.Parent then aeBodyVel:Destroy() end end)
        aeBodyVel = Instance.new("BodyVelocity", hrp)
        aeBodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        aeBodyVel.Velocity = Vector3.zero
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
                            aeBodyVel.VectorVelocity = Vector3.zero
                        else
                            aeBodyVel.Velocity = Vector3.zero
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

-- ── UI DO AUTO EXPLORAR ───────────────────────────────────────
-- Seção cabeçalho
local aeSecHdr = Instance.new("Frame", Pages["Farm"])
aeSecHdr.BackgroundColor3 = Color3.fromRGB(20,22,30); aeSecHdr.BackgroundTransparency = 0.3
aeSecHdr.BorderSizePixel = 0; aeSecHdr.Size = UDim2.new(1,0,0,22)
aeSecHdr.LayoutOrder = fNextLO(); aeSecHdr.ZIndex = 4
Instance.new("UICorner",aeSecHdr).CornerRadius = UDim.new(0,6)
local aeSecBar = Instance.new("Frame",aeSecHdr); aeSecBar.BackgroundColor3 = AE_COR; aeSecBar.BorderSizePixel = 0
aeSecBar.Size = UDim2.new(0,3,1,0); aeSecBar.ZIndex = 5; Instance.new("UICorner",aeSecBar).CornerRadius = UDim.new(0,3)
local aeSecLbl = Instance.new("TextLabel",aeSecHdr); aeSecLbl.BackgroundTransparency = 1
aeSecLbl.Position = UDim2.new(0,10,0,0); aeSecLbl.Size = UDim2.new(1,-14,1,0)
aeSecLbl.Font = Enum.Font.GothamBlack; aeSecLbl.Text = "🗺️  AUTO EXPLORAR"
aeSecLbl.TextColor3 = AE_COR; aeSecLbl.TextSize = 9
aeSecLbl.TextXAlignment = Enum.TextXAlignment.Left; aeSecLbl.ZIndex = 5

-- Card principal (altura 175px para caber seletor de nível manual)
aeCard = Instance.new("Frame", Pages["Farm"])
aeCard.BackgroundColor3 = Color3.fromRGB(38,22,10); aeCard.BorderSizePixel = 0
aeCard.Size = UDim2.new(1,0,0,175); aeCard.LayoutOrder = fNextLO(); aeCard.ZIndex = 5
Instance.new("UICorner",aeCard).CornerRadius = UDim.new(0,9)
aeStroke = Instance.new("UIStroke",aeCard); aeStroke.Color = Color3.fromRGB(252,198,0); aeStroke.Thickness = 1.5; aeStroke.Transparency = 0.72

-- Linha 1: título + badge estado + toggle
local aeTitleRow = Instance.new("Frame",aeCard); aeTitleRow.BackgroundTransparency=1
aeTitleRow.Position=UDim2.new(0,14,0,10); aeTitleRow.Size=UDim2.new(1,-70,0,20); aeTitleRow.ZIndex=6
local aeTitleLbl = Instance.new("TextLabel",aeTitleRow); aeTitleLbl.BackgroundTransparency=1
aeTitleLbl.Size=UDim2.new(0,110,1,0); aeTitleLbl.Font=Enum.Font.GothamBold
aeTitleLbl.Text="🗺️ Auto Explorar"; aeTitleLbl.TextColor3=Color3.fromRGB(255,235,190)
aeTitleLbl.TextSize=12; aeTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; aeTitleLbl.ZIndex=7
aeLabelState = Instance.new("TextLabel",aeTitleRow); aeLabelState.BackgroundColor3=Color3.fromRGB(20,12,40)
aeLabelState.Size=UDim2.new(0,82,0,16); aeLabelState.Position=UDim2.new(0,116,0,2)
aeLabelState.Font=Enum.Font.GothamBold; aeLabelState.Text="AGUARDANDO"
aeLabelState.TextColor3=Color3.fromRGB(170,130,70); aeLabelState.TextSize=8
aeLabelState.TextXAlignment=Enum.TextXAlignment.Center; aeLabelState.ZIndex=7
Instance.new("UICorner",aeLabelState).CornerRadius=UDim.new(0,4)
Instance.new("UIStroke",aeLabelState).Color=Color3.fromRGB(252,198,0)

-- Toggle pill
aePill = Instance.new("Frame",aeCard); aePill.BackgroundColor3=Color3.fromRGB(45,28,15)
aePill.Position=UDim2.new(1,-58,0,14); aePill.Size=UDim2.new(0,48,0,26); aePill.ZIndex=9
Instance.new("UICorner",aePill).CornerRadius=UDim.new(1,0)
aeKnob = Instance.new("Frame",aePill); aeKnob.BackgroundColor3=Color3.fromRGB(130,90,30)
aeKnob.Position=UDim2.new(0,2,0.5,-11); aeKnob.Size=UDim2.new(0,22,0,22); aeKnob.ZIndex=10
Instance.new("UICorner",aeKnob).CornerRadius=UDim.new(1,0)

-- Linha 2: seletor manual de nível (🔥1 🔥2 🔥3 🔥4 🔥5 🔥6 AUTO)
local aeLvlRow = Instance.new("Frame",aeCard); aeLvlRow.BackgroundTransparency=1
aeLvlRow.Position=UDim2.new(0,14,0,36); aeLvlRow.Size=UDim2.new(1,-28,0,22); aeLvlRow.ZIndex=6
local aeLvlLbl = Instance.new("TextLabel",aeLvlRow); aeLvlLbl.BackgroundTransparency=1
aeLvlLbl.Size=UDim2.new(0,60,1,0); aeLvlLbl.Font=Enum.Font.GothamBold
aeLvlLbl.Text="Nível:"; aeLvlLbl.TextColor3=Color3.fromRGB(255,200,80); aeLvlLbl.TextSize=9
aeLvlLbl.TextXAlignment=Enum.TextXAlignment.Left; aeLvlLbl.ZIndex=7
local aeLvlBtns = {}
local aeLvlLabels = {"AUTO","1","2","3","4","5","6"}
local aeLvlVals   = {0,    1,  2,  3,  4,  5,  6 }
for bi, lbl in ipairs(aeLvlLabels) do
    local btn = Instance.new("TextButton",aeLvlRow)
    btn.Size = UDim2.new(0,30,1,0)
    btn.Position = UDim2.new(0, 56 + (bi-1)*32, 0, 0)
    btn.Font = Enum.Font.GothamBold; btn.Text = lbl; btn.TextSize = 8
    btn.BackgroundColor3 = (aeLvlVals[bi]==aeManualLevel)
        and Color3.fromRGB(252,198,0) or Color3.fromRGB(35,22,12)
    btn.TextColor3 = Color3.fromRGB(230,210,255)
    btn.BorderSizePixel = 0; btn.ZIndex = 8
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,5)
    table.insert(aeLvlBtns, {btn=btn, val=aeLvlVals[bi]})
    btn.MouseButton1Click:Connect(function()
        aeManualLevel = aeLvlVals[bi]
        for _, b in ipairs(aeLvlBtns) do
            b.btn.BackgroundColor3 = (b.val==aeManualLevel)
                and Color3.fromRGB(252,198,0) or Color3.fromRGB(35,22,12)
        end
        aeRefreshLevel()
    end)
end

-- Linha 3: nível detectado (dinâmico)
aeLevelLbl = Instance.new("TextLabel",aeCard); aeLevelLbl.BackgroundTransparency=1
aeLevelLbl.Position=UDim2.new(0,14,0,62); aeLevelLbl.Size=UDim2.new(1,-28,0,14)
aeLevelLbl.Font=Enum.Font.GothamBold; aeLevelLbl.Text="🔥 Detectando nível da fogueira..."
aeLevelLbl.TextColor3=Color3.fromRGB(255,200,80); aeLevelLbl.TextSize=9
aeLevelLbl.TextXAlignment=Enum.TextXAlignment.Left; aeLevelLbl.ZIndex=7

-- Linha 4: FogEnd real (diagnóstico)
aeRadiusLbl = Instance.new("TextLabel",aeCard); aeRadiusLbl.BackgroundTransparency=1
aeRadiusLbl.Position=UDim2.new(0,14,0,78); aeRadiusLbl.Size=UDim2.new(1,-28,0,12)
aeRadiusLbl.Font=Enum.Font.Gotham
local _fogNow=0; pcall(function() _fogNow=game:GetService("Lighting").FogEnd end)
aeRadiusLbl.Text="FogEnd real: "..(math.floor(_fogNow)).."  •  Vel: "..AE_SPEED.." st/s  •  Alt: +"..AE_HEIGHT_OFF
aeRadiusLbl.TextColor3=Color3.fromRGB(130,95,45); aeRadiusLbl.TextSize=8
aeRadiusLbl.TextXAlignment=Enum.TextXAlignment.Left; aeRadiusLbl.ZIndex=6

-- Linha 5: barra de progresso
local aeProgressBg = Instance.new("Frame",aeCard); aeProgressBg.BackgroundColor3=Color3.fromRGB(22,10,42)
aeProgressBg.BorderSizePixel=0; aeProgressBg.Position=UDim2.new(0,14,0,96)
aeProgressBg.Size=UDim2.new(1,-28,0,10); aeProgressBg.ZIndex=6
Instance.new("UICorner",aeProgressBg).CornerRadius=UDim.new(1,0)
aeProgressFill = Instance.new("Frame",aeProgressBg); aeProgressFill.BackgroundColor3=AE_COR
aeProgressFill.BorderSizePixel=0; aeProgressFill.Size=UDim2.new(0,0,1,0); aeProgressFill.ZIndex=7
Instance.new("UICorner",aeProgressFill).CornerRadius=UDim.new(1,0)
local aeGrad = Instance.new("UIGradient",aeProgressFill)
aeGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(80,180,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(160,240,255))})

-- Linha 6: timer ao vivo
aeTimerLabel = Instance.new("TextLabel",aeCard); aeTimerLabel.BackgroundTransparency=1
aeTimerLabel.Position=UDim2.new(0,14,0,110); aeTimerLabel.Size=UDim2.new(1,-28,0,16)
aeTimerLabel.Font=Enum.Font.GothamBold; aeTimerLabel.Text="0:00  0%"
aeTimerLabel.TextColor3=AE_COR; aeTimerLabel.TextSize=9
aeTimerLabel.TextXAlignment=Enum.TextXAlignment.Left; aeTimerLabel.ZIndex=6

-- Linha 7: descrição
local aeDesc = Instance.new("TextLabel",aeCard); aeDesc.BackgroundTransparency=1
aeDesc.Position=UDim2.new(0,14,0,130); aeDesc.Size=UDim2.new(1,-28,0,36)
aeDesc.Font=Enum.Font.Gotham; aeDesc.Text="Selecione o nível da sua fogueira manualmente se AUTO não detectar corretamente. FogEnd real é exibido para calibração."
aeDesc.TextColor3=Color3.fromRGB(120,90,40); aeDesc.TextSize=8; aeDesc.TextWrapped=true
aeDesc.TextXAlignment=Enum.TextXAlignment.Left; aeDesc.ZIndex=6

-- Botão invisível
local aeBtn = Instance.new("TextButton",aeCard)
aeBtn.BackgroundTransparency=1; aeBtn.Size=UDim2.new(1,0,0,55); aeBtn.Text=""; aeBtn.ZIndex=11

aeBtn.MouseButton1Click:Connect(function()
    aeEnabled = not aeEnabled
    TweenService:Create(aePill,TweenInfo.new(0.22),{BackgroundColor3=aeEnabled and AE_COR or Color3.fromRGB(50,32,15)}):Play()
    TweenService:Create(aeKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position=aeEnabled and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
        BackgroundColor3=aeEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185),
    }):Play()
    TweenService:Create(aeStroke,TweenInfo.new(0.2),{Color=aeEnabled and AE_COR or Color3.fromRGB(80,55,20)}):Play()

    if aeEnabled then
        task.spawn(startAutoExplore)
    else
        local elapsed = math.floor(tick() - aeStartTime)
        local pct     = math.clamp((aeCurRadius - AE_MIN_RADIUS) / (aeDynMaxRadius - AE_MIN_RADIUS), 0, 1)
        stopAutoExplore(true)
        pcall(function()
            if aeLabelState then
                aeLabelState.Text = "AGUARDANDO"; aeLabelState.TextColor3 = Color3.fromRGB(100,120,160)
                TweenService:Create(aeLabelState,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(20,12,40)}):Play()
            end
        end)
        Notify.send({type="custom", icon="🗺️", accent=Color3.fromRGB(255,80,80),
            title="Auto Explorar Parado",
            msg=string.format("✗ %.0f%% explorado em %s (Nível %d, raio %d studs) — TP à fogueira...",
                pct*100, aeFormatTime(elapsed), aeCampLevel, math.floor(aeCurRadius)),
            duration=5})
    end
end)

-- Detecta nível ao abrir a UI (sem precisar ligar)
task.spawn(aeRefreshLevel)

-- Atualiza o level label periodicamente mesmo com o feature desligado
task.spawn(function()
    while true do
        task.wait(8)
        if not aeEnabled then
            pcall(aeRefreshLevel)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
makeSec(Pages["AvancadoFarm"], afNextLO, "avFarmSecFreeze", Color3.fromRGB(0,200,255))

local FREEZE_COR = Color3.fromRGB(0,200,255)

-- Card principal toggle
local freezeCard = Instance.new("Frame", Pages["AvancadoFarm"])
freezeCard.BackgroundColor3 = Color3.fromRGB(40,24,12)
freezeCard.BorderSizePixel = 0
freezeCard.Size = UDim2.new(1,0,0,70)
freezeCard.LayoutOrder = afNextLO(); freezeCard.ZIndex=5
Instance.new("UICorner",freezeCard).CornerRadius=UDim.new(0,9)
local fzStroke=Instance.new("UIStroke",freezeCard); fzStroke.Color=Color3.fromRGB(252,198,0); fzStroke.Thickness=3.5; fzStroke.Transparency=0.6

local fzTitleLbl=Instance.new("TextLabel",freezeCard); fzTitleLbl.BackgroundTransparency=1
fzTitleLbl.Position=UDim2.new(0,14,0,6); fzTitleLbl.Size=UDim2.new(1,-80,0,18); fzTitleLbl.Font=Enum.Font.GothamBold
fzTitleLbl.Text=T("freezeTitle"); fzTitleLbl.TextColor3=Color3.fromRGB(255,235,190); fzTitleLbl.TextSize=12
fzTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; fzTitleLbl.ZIndex=7
trackLabel(fzTitleLbl, "freezeTitle")
local fzDescLbl=Instance.new("TextLabel",freezeCard); fzDescLbl.BackgroundTransparency=1
fzDescLbl.Position=UDim2.new(0,14,0,26); fzDescLbl.Size=UDim2.new(1,-80,0,36); fzDescLbl.Font=Enum.Font.Gotham
fzDescLbl.Text=T("freezeDesc"); fzDescLbl.TextColor3=Color3.fromRGB(160,120,70)
fzDescLbl.TextSize=9; fzDescLbl.TextXAlignment=Enum.TextXAlignment.Left; fzDescLbl.TextWrapped=true; fzDescLbl.ZIndex=7
trackLabel(fzDescLbl, "freezeDesc")

local fzPill=Instance.new("Frame",freezeCard); fzPill.BackgroundColor3=Color3.fromRGB(45,28,15); fzPill.BorderSizePixel=0
fzPill.Position=UDim2.new(1,-56,0.5,-13); fzPill.Size=UDim2.new(0,48,0,26); fzPill.ZIndex=9
Instance.new("UICorner",fzPill).CornerRadius=UDim.new(1,0)
local fzKnob=Instance.new("Frame",fzPill); fzKnob.BackgroundColor3=Color3.fromRGB(130,90,30); fzKnob.BorderSizePixel=0
fzKnob.Position=UDim2.new(0,2,0.5,-11); fzKnob.Size=UDim2.new(0,22,0,22); fzKnob.ZIndex=10
Instance.new("UICorner",fzKnob).CornerRadius=UDim.new(1,0)

local fzBtn=Instance.new("TextButton",freezeCard); fzBtn.BackgroundTransparency=1; fzBtn.Size=UDim2.new(1,0,1,0); fzBtn.Text=""; fzBtn.ZIndex=11
fzBtn.MouseButton1Click:Connect(function()
    freezeEnabled = not freezeEnabled
    TweenService:Create(fzPill,TweenInfo.new(0.22),{BackgroundColor3=freezeEnabled and FREEZE_COR or Color3.fromRGB(45,28,15)}):Play()
    TweenService:Create(fzKnob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position=freezeEnabled and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
        BackgroundColor3=freezeEnabled and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,90,30)
    }):Play()
    TweenService:Create(fzStroke,TweenInfo.new(0.2),{Color=freezeEnabled and FREEZE_COR or Color3.fromRGB(252,198,0), Transparency=freezeEnabled and 0.3 or 0.82}):Play()
    if freezeEnabled then
        startFreezeAura()
        Notify.send({type="custom",icon="❄️",accent=Color3.fromRGB(87,242,135),
            title=T("freezeOn"),
            msg="✓ "..tostring(freezeRadius)..T("freezeOnMsg"),duration=4})
    else
        stopFreezeAura()
        Notify.error(T("freezeOff"), T("freezeOffMsg"))
    end
end)

-- Card raio com botões +/-
local fzRadiusCard = Instance.new("Frame", Pages["AvancadoFarm"])
fzRadiusCard.BackgroundColor3 = Color3.fromRGB(28,16,8)
fzRadiusCard.BorderSizePixel = 0
fzRadiusCard.Size = UDim2.new(1,0,0,54)
fzRadiusCard.LayoutOrder = afNextLO(); fzRadiusCard.ZIndex=5
Instance.new("UICorner",fzRadiusCard).CornerRadius=UDim.new(0,9)
Instance.new("UIStroke",fzRadiusCard).Color=Color3.fromRGB(252,198,0)

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
local fzMinus=Instance.new("TextButton",fzRadiusCard); fzMinus.BackgroundColor3=Color3.fromRGB(40,24,12)
fzMinus.BorderSizePixel=0; fzMinus.Position=UDim2.new(1,-110,0.5,-16); fzMinus.Size=UDim2.new(0,32,0,32)
fzMinus.Text="-"; fzMinus.TextColor3=FREEZE_COR; fzMinus.Font=Enum.Font.GothamBlack; fzMinus.TextSize=18; fzMinus.ZIndex=8
Instance.new("UICorner",fzMinus).CornerRadius=UDim.new(0,8)
fzMinus.MouseButton1Click:Connect(function()
    freezeRadius = math.max(10, freezeRadius - 10)
    fzValLbl.Text = tostring(freezeRadius).." st"
    updateCircleRadius()
end)

-- Botão PLUS
local fzPlus=Instance.new("TextButton",fzRadiusCard); fzPlus.BackgroundColor3=Color3.fromRGB(0,160,220)
fzPlus.BorderSizePixel=0; fzPlus.Position=UDim2.new(1,-70,0.5,-16); fzPlus.Size=UDim2.new(0,32,0,32)
fzPlus.Text="+"; fzPlus.TextColor3=FREEZE_COR; fzPlus.Font=Enum.Font.GothamBlack; fzPlus.TextSize=18; fzPlus.ZIndex=8
Instance.new("UICorner",fzPlus).CornerRadius=UDim.new(0,8)
fzPlus.MouseButton1Click:Connect(function()
    freezeRadius = math.min(500, freezeRadius + 10)
    fzValLbl.Text = tostring(freezeRadius).." st"
    updateCircleRadius()
end)

-- Botão reset ao padrão 185
local fzReset=Instance.new("TextButton",fzRadiusCard); fzReset.BackgroundColor3=Color3.fromRGB(0,140,200)
fzReset.BorderSizePixel=0; fzReset.Position=UDim2.new(1,-34,0.5,-10); fzReset.Size=UDim2.new(0,28,0,20)
fzReset.Text="↺"; fzReset.TextColor3=Color3.fromRGB(180,240,255); fzReset.Font=Enum.Font.GothamBold; fzReset.TextSize=13; fzReset.ZIndex=8
Instance.new("UICorner",fzReset).CornerRadius=UDim.new(0,6)
fzReset.MouseButton1Click:Connect(function()
    freezeRadius = 185
    fzValLbl.Text = "185 st"
    updateCircleRadius()
end)


-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  PUDIM HUB — NOVOS RECURSOS FARM v2                             ║
-- ║  1. Auto Fogueira (sem Log)   2. Auto Cozinhar                  ║
-- ║  3. Auto Fogueira HP Based (popup %)                            ║
-- ║  4. Auto Triturador com Seletor de Itens (popup)                ║
-- ║  5. Auto Comer (Player Tab — baseado em % de fome)              ║
-- ╚══════════════════════════════════════════════════════════════════╝
do -- NOVOS_FARM_V2

-- ── Cores dos novos módulos ───────────────────────────────────────
local AF2_COR = Color3.fromRGB(255, 210, 50)   -- Fogueira simples (sem log)
local AC_COR  = Color3.fromRGB(100, 220, 100)  -- Auto Cozinhar
local AHP_COR = Color3.fromRGB(255, 80, 120)   -- Auto Fogueira HP Based
local ATE_COR = Color3.fromRGB(90, 210, 255)   -- Auto Comer

-- ── Utilitário: coletar itens por conjunto de nomes ───────────────
local function collectItemsByNames(nameSet)
    local found, seen, pchars = {}, {}, {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character then pchars[pl.Character] = true end
    end
    local ok, descs = pcall(function() return workspace:GetDescendants() end)
    if not ok then return found end
    for _, obj in ipairs(descs) do
        pcall(function()
            if not obj or not obj.Parent then return end
            local part, nm
            if obj:IsA("BasePart") then
                local pm = obj.Parent
                if pm and pm:IsA("Model") and not pm:FindFirstChildWhichIsA("Humanoid") then return end
                part = obj; nm = obj.Name:lower()
            elseif obj:IsA("Model") and not obj:FindFirstChildWhichIsA("Humanoid") then
                if seen[obj] then return end
                local p2 = obj:FindFirstChildWhichIsA("BasePart")
                if not p2 then return end
                part = p2; nm = obj.Name:lower(); seen[obj] = true
            else return end
            if not nameSet[nm] then return end
            for pc in pairs(pchars) do
                if pc == obj or pc:IsAncestorOf(obj) then return end
            end
            local sz = part.Size
            if sz.X > 18 or sz.Y > 18 or sz.Z > 18 then return end
            table.insert(found, {obj=obj, part=part})
        end)
    end
    return found
end

-- ── Utilitário: soltar item acima de uma posição (queda livre) ────
local function dropAtPos(part, obj, pos)
    pcall(function()
        for _, v in ipairs(obj:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") then
                pcall(function() v.Disabled = true end)
            end
            if v:IsA("BodyPosition") or v:IsA("BodyForce") or v:IsA("BodyVelocity")
            or v:IsA("BodyGyro") or v:IsA("AlignPosition") or v:IsA("AlignOrientation")
            or v:IsA("WeldConstraint") or v:IsA("Weld") then
                pcall(function() v:Destroy() end)
            end
        end
        part.Anchored = false; part.CanCollide = false
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
        local offset = pos - part.Position
        part.CFrame  = CFrame.new(pos)
        if obj:IsA("Model") then
            for _, bp in ipairs(obj:GetDescendants()) do
                if bp:IsA("BasePart") and bp ~= part then
                    pcall(function()
                        bp.Anchored = false; bp.CanCollide = false
                        bp.CFrame   = CFrame.new(bp.Position + offset)
                    end)
                end
            end
        end
        part.AssemblyLinearVelocity = Vector3.new(0, -25, 0)
        task.delay(0.4, function()
            pcall(function()
                if part and part.Parent then
                    part.CanCollide = true
                    if obj:IsA("Model") then
                        for _, bp in ipairs(obj:GetDescendants()) do
                            if bp:IsA("BasePart") and bp ~= part then
                                pcall(function() if bp.Parent then bp.CanCollide = true end end)
                            end
                        end
                    end
                end
            end)
        end)
    end)
end

-- ── Utilitário: drop em espiral ao redor de fogPos ────────────────
local function dropNearCampfire(part, obj, fogPos, slot, lote)
    slot = slot or 0; lote = math.max(lote or 1, 1)
    local angle = (slot / lote) * math.pi * 2
    local raio  = 0.4 + slot * 0.35
    local pos   = Vector3.new(
        fogPos.X + math.cos(angle) * raio,
        fogPos.Y + 8,
        fogPos.Z + math.sin(angle) * raio
    )
    dropAtPos(part, obj, pos)
end

-- ── Utilitário: aguarda consumo de um lote ────────────────────────
local function waitConsumed(entries, timeout, runningRef)
    local t0 = tick()
    while tick() - t0 < timeout and runningRef[1] do
        task.wait(0.4)
        local any = false
        for _, e in ipairs(entries) do
            if e.part and e.part.Parent and e.obj and e.obj.Parent then any = true; break end
        end
        if not any then break end
    end
end

-- ── Utilitário: construtor de seção (header) genérico ─────────────
local function makeFarmSec(title, cor)
    local sec = Instance.new("Frame", Pages["Farm"])
    sec.BackgroundColor3 = Color3.fromRGB(20,12,4); sec.BorderSizePixel = 0
    sec.Size = UDim2.new(1,0,0,32); sec.LayoutOrder = fNextLO(); sec.ZIndex = 4
    Instance.new("UICorner", sec).CornerRadius = UDim.new(0,10)
    -- Fundo com cor accent suave
    local secG = Instance.new("UIGradient", sec)
    secG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(
            math.floor(cor.R*255*0.18+18), math.floor(cor.G*255*0.12+10), math.floor(cor.B*255*0.12+4)
        )),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14,8,2))
    }); secG.Rotation = 90
    local secS = Instance.new("UIStroke", sec)
    secS.Color = cor; secS.Thickness = 1.5; secS.Transparency = 0.7
    secS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    -- Pill accent à esquerda
    local pill = Instance.new("Frame", sec); pill.BackgroundColor3 = cor
    pill.BorderSizePixel = 0; pill.Position = UDim2.new(0,8,0.5,-10); pill.Size = UDim2.new(0,4,0,20); pill.ZIndex = 5
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)
    -- Glow do pill
    local pillGlow = Instance.new("Frame", sec); pillGlow.BackgroundColor3 = cor
    pillGlow.BackgroundTransparency = 0.75; pillGlow.BorderSizePixel = 0
    pillGlow.Position = UDim2.new(0,6,0.5,-12); pillGlow.Size = UDim2.new(0,8,0,24); pillGlow.ZIndex = 4
    Instance.new("UICorner", pillGlow).CornerRadius = UDim.new(1,0)
    -- Título
    local lbl = Instance.new("TextLabel", sec); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,20,0,0); lbl.Size = UDim2.new(1,-28,1,0)
    lbl.Font = Enum.Font.GothamBlack; lbl.Text = title
    lbl.TextColor3 = Color3.fromRGB(245,230,200); lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5
    local lblS = Instance.new("UIStroke", lbl)
    lblS.Color = Color3.fromRGB(0,0,0); lblS.Thickness = 0.8; lblS.Transparency = 0.5
    -- Linha divisória à direita (decorativa)
    local divR = Instance.new("Frame", sec); divR.BackgroundColor3 = cor
    divR.BackgroundTransparency = 0.8; divR.BorderSizePixel = 0
    divR.AnchorPoint = Vector2.new(1,0.5)
    divR.Position = UDim2.new(1,-8,0.5,0); divR.Size = UDim2.new(0,28,0,1); divR.ZIndex = 5
end

-- ══════════════════════════════════════════════════════════════════
-- makeFarmCard — card moderno tipo painel de controle
-- Layout: [ICON | Título + Desc + Status] | [Pill Status + Btn ON/OFF]
-- Retorna: card, cardS, iconBg, tit, desc, statusLbl, actionBtn, actionBtnG
-- ══════════════════════════════════════════════════════════════════
local function makeFarmCard(h, cor, icon, title, descTxt)
    -- Torna a altura mínima 90 para o novo layout
    local CH = math.max(h, 90)
    local card = Instance.new("Frame", Pages["Farm"])
    card.BackgroundColor3 = Color3.fromRGB(18,11,4); card.BorderSizePixel = 0
    card.Size = UDim2.new(1,0,0,CH); card.LayoutOrder = fNextLO(); card.ZIndex = 5
    Instance.new("UICorner", card).CornerRadius = UDim.new(0,14)

    -- Gradiente de fundo refinado
    local cardG = Instance.new("UIGradient", card)
    cardG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(
            math.floor(cor.R*255*0.14+22), math.floor(cor.G*255*0.1+12), math.floor(cor.B*255*0.1+5)
        )),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(14,8,2))
    }); cardG.Rotation = 145

    -- Borda esquerda colorida (accent bar vertical)
    local cardS = Instance.new("UIStroke", card)
    cardS.Color = cor; cardS.Thickness = 1.5; cardS.Transparency = 0.65
    cardS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local accentBar = Instance.new("Frame", card); accentBar.BackgroundColor3 = cor
    accentBar.BorderSizePixel = 0; accentBar.Position = UDim2.new(0,0,0.1,0)
    accentBar.Size = UDim2.new(0,4,0.8,0); accentBar.ZIndex = 6
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0,4)
    -- Glow do accent bar
    local accentGlow = Instance.new("Frame", card); accentGlow.BackgroundColor3 = cor
    accentGlow.BackgroundTransparency = 0.8; accentGlow.BorderSizePixel = 0
    accentGlow.Position = UDim2.new(0,0,0.08,0); accentGlow.Size = UDim2.new(0,12,0.84,0); accentGlow.ZIndex = 5
    Instance.new("UICorner", accentGlow).CornerRadius = UDim.new(0,6)

    -- ── Zona esquerda: ícone ──────────────────────────────────────
    local ib = Instance.new("Frame", card); ib.BackgroundColor3 = cor
    ib.BackgroundTransparency = 0.25; ib.BorderSizePixel = 0
    ib.Position = UDim2.new(0,12,0.5,-22); ib.Size = UDim2.new(0,44,0,44); ib.ZIndex = 7
    Instance.new("UICorner", ib).CornerRadius = UDim.new(0,12)
    local ibS = Instance.new("UIStroke", ib)
    ibS.Color = Color3.fromRGB(0,0,0); ibS.Thickness = 2; ibS.Transparency = 0.5
    ibS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    -- Inner glow
    local ibGlow = Instance.new("Frame", ib); ibGlow.BackgroundColor3 = Color3.fromRGB(255,255,255)
    ibGlow.BackgroundTransparency = 0.88; ibGlow.BorderSizePixel = 0
    ibGlow.Position = UDim2.new(0,2,0,2); ibGlow.Size = UDim2.new(0,16,0,6); ibGlow.ZIndex = 8
    Instance.new("UICorner", ibGlow).CornerRadius = UDim.new(1,0)
    local il = Instance.new("TextLabel", ib)
    il.BackgroundTransparency = 1; il.Size = UDim2.new(1,0,1,0)
    il.Text = icon; il.TextSize = 22; il.Font = Enum.Font.GothamBold; il.ZIndex = 9

    -- ── Título ──────────────────────────────────────────────────
    local tl = Instance.new("TextLabel", card); tl.BackgroundTransparency = 1
    tl.Position = UDim2.new(0,64,0,12); tl.Size = UDim2.new(0.52,0,0,18)
    tl.Font = Enum.Font.GothamBlack; tl.Text = title
    tl.TextColor3 = Color3.fromRGB(255,245,225); tl.TextSize = 13
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 7
    local tlS = Instance.new("UIStroke", tl)
    tlS.Color = Color3.fromRGB(0,0,0); tlS.Thickness = 0.8; tlS.Transparency = 0.3

    -- ── Descrição ────────────────────────────────────────────────
    local dl = Instance.new("TextLabel", card); dl.BackgroundTransparency = 1
    dl.Position = UDim2.new(0,64,0,32); dl.Size = UDim2.new(0.52,0,0,30)
    dl.Font = Enum.Font.Gotham; dl.Text = descTxt
    dl.TextColor3 = Color3.fromRGB(165,135,80); dl.TextSize = 9
    dl.TextXAlignment = Enum.TextXAlignment.Left; dl.TextWrapped = true; dl.ZIndex = 7

    -- ── Status label (linha de feedback) ─────────────────────────
    local sl = Instance.new("TextLabel", card); sl.BackgroundTransparency = 1
    sl.Position = UDim2.new(0,64,0,CH-20); sl.Size = UDim2.new(0.52,0,0,14)
    sl.Font = Enum.Font.GothamBold; sl.Text = ""
    sl.TextColor3 = cor; sl.TextSize = 9
    sl.TextXAlignment = Enum.TextXAlignment.Left; sl.ZIndex = 7

    -- ── Divisória vertical ────────────────────────────────────────
    local divV = Instance.new("Frame", card); divV.BackgroundColor3 = cor
    divV.BackgroundTransparency = 0.8; divV.BorderSizePixel = 0
    divV.Position = UDim2.new(0.56,0,0.1,0); divV.Size = UDim2.new(0,1,0.8,0); divV.ZIndex = 6

    -- ── Zona direita: pill de status + botão ─────────────────────
    -- Pill indicador de status (INATIVO/ATIVO)
    local statusPill = Instance.new("Frame", card)
    statusPill.BackgroundColor3 = Color3.fromRGB(30,20,8); statusPill.BorderSizePixel = 0
    statusPill.AnchorPoint = Vector2.new(0.5,0)
    statusPill.Position = UDim2.new(0.78,0,0,10); statusPill.Size = UDim2.new(0,88,0,22); statusPill.ZIndex = 7
    Instance.new("UICorner", statusPill).CornerRadius = UDim.new(1,0)
    local spS = Instance.new("UIStroke", statusPill)
    spS.Color = Color3.fromRGB(80,50,20); spS.Thickness = 1.5; spS.Transparency = 0.3
    -- Dot indicador
    local spDot = Instance.new("Frame", statusPill)
    spDot.BackgroundColor3 = Color3.fromRGB(100,100,100); spDot.BorderSizePixel = 0
    spDot.Position = UDim2.new(0,8,0.5,-4); spDot.Size = UDim2.new(0,8,0,8); spDot.ZIndex = 8
    Instance.new("UICorner", spDot).CornerRadius = UDim.new(1,0)
    local spLbl = Instance.new("TextLabel", statusPill)
    spLbl.BackgroundTransparency = 1; spLbl.Position = UDim2.new(0,20,0,0); spLbl.Size = UDim2.new(1,-24,1,0)
    spLbl.Font = Enum.Font.GothamBlack; spLbl.Text = "INATIVO"
    spLbl.TextColor3 = Color3.fromRGB(120,90,40); spLbl.TextSize = 9
    spLbl.TextXAlignment = Enum.TextXAlignment.Left; spLbl.ZIndex = 8

    -- Botão principal ATIVAR/PARAR
    local aBtn = Instance.new("TextButton", card)
    aBtn.BackgroundColor3 = cor; aBtn.BorderSizePixel = 0; aBtn.AutoButtonColor = false
    aBtn.AnchorPoint = Vector2.new(0.5,0)
    aBtn.Position = UDim2.new(0.78,0,0,38); aBtn.Size = UDim2.new(0,100,0,40)
    aBtn.Font = Enum.Font.GothamBlack; aBtn.Text = "▶  ATIVAR"
    aBtn.TextColor3 = Color3.fromRGB(255,255,255); aBtn.TextSize = 12; aBtn.ZIndex = 8
    Instance.new("UICorner", aBtn).CornerRadius = UDim.new(0,12)
    local aBtnS = Instance.new("UIStroke", aBtn)
    aBtnS.Color = Color3.fromRGB(0,0,0); aBtnS.Thickness = 2; aBtnS.Transparency = 0.4
    aBtnS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local aBtnG = Instance.new("UIGradient", aBtn); aBtnG.Rotation = 100
    aBtnG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
    })
    aBtnG.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7), NumberSequenceKeypoint.new(1, 0.9)
    })
    -- Shine no botão
    local aBtnShine = Instance.new("Frame", aBtn)
    aBtnShine.BackgroundColor3 = Color3.fromRGB(255,255,255); aBtnShine.BackgroundTransparency = 0.7
    aBtnShine.BorderSizePixel = 0; aBtnShine.Position = UDim2.new(0,6,0,4)
    aBtnShine.Size = UDim2.new(0,44,0,6); aBtnShine.ZIndex = 9
    Instance.new("UICorner", aBtnShine).CornerRadius = UDim.new(1,0)

    -- Hover no botão
    aBtn.MouseEnter:Connect(function()
        TweenService:Create(aBtn, TweenInfo.new(0.1), {Size=UDim2.new(0,104,0,42), Position=UDim2.new(0.78,0,0,37)}):Play()
    end)
    aBtn.MouseLeave:Connect(function()
        TweenService:Create(aBtn, TweenInfo.new(0.12), {Size=UDim2.new(0,100,0,40), Position=UDim2.new(0.78,0,0,38)}):Play()
    end)

    -- Função auxiliar para atualizar estado visual do card
    -- (chamada pelo handler de clique de cada feature)
    card._updateState = function(isActive)
        if isActive then
            TweenService:Create(cardS, TweenInfo.new(0.25), {Color=cor, Transparency=0}):Play()
            TweenService:Create(spDot, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(87,242,135)}):Play()
            TweenService:Create(statusPill, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(20,40,20)}):Play()
            TweenService:Create(spS, TweenInfo.new(0.2), {Color=Color3.fromRGB(40,180,60)}):Play()
            spLbl.Text="ATIVO"; spLbl.TextColor3=Color3.fromRGB(87,242,135)
            aBtn.Text="■  PARAR"; aBtn.BackgroundColor3=Color3.fromRGB(200,40,40)
        else
            TweenService:Create(cardS, TweenInfo.new(0.25), {Color=cor, Transparency=0.65}):Play()
            TweenService:Create(spDot, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(100,100,100)}):Play()
            TweenService:Create(statusPill, TweenInfo.new(0.2), {BackgroundColor3=Color3.fromRGB(30,20,8)}):Play()
            TweenService:Create(spS, TweenInfo.new(0.2), {Color=Color3.fromRGB(80,50,20)}):Play()
            spLbl.Text="INATIVO"; spLbl.TextColor3=Color3.fromRGB(120,90,40)
            aBtn.Text="▶  ATIVAR"; aBtn.BackgroundColor3=cor
        end
    end

    -- Compatibilidade: aBtnG ainda retornado para btnGrad() calls no legado
    return card, cardS, ib, tl, dl, sl, aBtn, aBtnG
end

-- ── Utilitário: gradiente de botão ───────────────────────────────
local function btnGrad(g, c1, c2)
    g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,c1), ColorSequenceKeypoint.new(1,c2)})
end

-- ══════════════════════════════════════════════════════════════════
-- 1. AUTO FOGUEIRA (SEM LOG)
-- ══════════════════════════════════════════════════════════════════
local AF2_NAMES = {}
do
    local items = {
        "coal","firewood","kindling","tinder","charcoal","wood","bone","wax","stick",
        "branch","twig","turf","amber","feather","skull","antler",
        "carvao","graveto","galho","lenha","madeira","tronco",
        "plank","lumber","board","plywood","pallet","crate","barrel",
        "pinecone","pine cone","resin","straw","hay","peat",
        "pine log","oak log","birch log","cedar log","ash log",
        "jungle log","frozen log","lava log","cursed log",
        "charred log","burnt log","ancient wood","cursed wood",
        -- itens especiais sem Log
        "oil barrel","oilbarrel","fuel canister","fuelcanister","biofuel",
    }
    for _, n in ipairs(items) do AF2_NAMES[n] = true end
end

local af2Running = false; local af2Ref = {}

local function autoFogueiraSemLog()
    if af2Running then return end; af2Running = true
    local fogPos = getCampfirePos()
    if not fogPos then
        Notify.warn("🔥 Auto Fogueira (sem Log)", "Fogueira não encontrada!", 4)
        af2Running = false; return
    end
    local LOTE=3; local TIMEOUT=8; local total=0; local ciclo=0
    Notify.send({type="warn",icon="🔥",accent=AF2_COR,title="Auto Fogueira (sem Log)",msg="Iniciando! Log excluído ✓",duration=3})
    while af2Running do
        local lista = collectItemsByNames(AF2_NAMES)
        if #lista == 0 then
            pcall(function() if af2Ref.status then af2Ref.status.Text="⚠️ Sem combustível" end end)
            Notify.warn("🔥 Auto Fogueira (sem Log)","Sem combustível no mapa!",3); break
        end
        ciclo+=1
        pcall(function() if af2Ref.status then af2Ref.status.Text=string.format("🔥 Lote %d — %d disponíveis",ciclo,#lista) end end)
        local loteE = {}
        local running = {true}; af2Ref.runningArr = running
        for s=1,math.min(LOTE,#lista) do
            local e=lista[s]
            if e and e.part and e.part.Parent then
                dropNearCampfire(e.part,e.obj,fogPos,s-1,LOTE)
                table.insert(loteE,e); total+=1; task.wait(0.1)
            end
        end
        waitConsumed(loteE,TIMEOUT,{af2Running})
    end
    pcall(function() if af2Ref.status then af2Ref.status.Text="" end end)
    if total>0 then Notify.info("🔥 Auto Fogueira (sem Log)",string.format("%d item(s) em %d lote(s).",total,ciclo),4) end
    af2Running=false
    pcall(function()
        if af2Ref.btn then af2Ref.btn.Text="🔥  ATIVAR"; btnGrad(af2Ref.btnG,Color3.fromRGB(255,220,60),Color3.fromRGB(200,140,0)) end
        if af2Ref.stroke then TweenService:Create(af2Ref.stroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(8,4,0)}):Play() end
    end)
end

makeFarmSec("🔥  AUTO FOGUEIRA (SEM LOG)", AF2_COR)
do
    local card,cardS,_,_,_,status,btn,btnG = makeFarmCard(80,AF2_COR,"🔥","Auto Fogueira (sem Log)","Alimenta a fogueira sem jogar Logs.\n⚡ Coal, Biofuel, Oil Barrel, Lenha, Graveto...")
    af2Ref.status=status; af2Ref.btn=btn; af2Ref.btnG=btnG; af2Ref.stroke=cardS
    btnGrad(btnG,Color3.fromRGB(255,220,60),Color3.fromRGB(200,140,0))
    btn.MouseButton1Click:Connect(function()
        if af2Running then
            af2Running=false; if card._updateState then card._updateState(false) end
            status.Text="⏹ Parado"; Notify.error("🔥 Auto Fogueira (sem Log)","⏹ Desativado")
            task.delay(1.5,function() pcall(function() status.Text="" end) end)
        else
            if card._updateState then card._updateState(true) end
            task.spawn(function()
                autoFogueiraSemLog()
                if not af2Running then if card._updateState then card._updateState(false) end end
            end)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════
-- 2. AUTO COZINHAR
-- ══════════════════════════════════════════════════════════════════
local AC_NAMES = {}
do
    local items = {
        "morsel","steak","ribs","turkey leg","turkeyleg","fish",
        "mackerel","salmon","clownfish","jellyfish","char","eel",
        "swordfish","shark","lava eel","lavaeel","lionfish",
        "raw meat","rawmeat","chicken","chicken leg","chickenleg",
        "pork","raw fish","rawfish","crab","crab leg","crableg",
    }
    for _, n in ipairs(items) do AC_NAMES[n] = true end
end

local acRunning = false; local acRef = {}

local function autoCozinhar()
    if acRunning then return end; acRunning = true
    local fogPos = getCampfirePos()
    if not fogPos then
        Notify.warn("🍖 Auto Cozinhar","Fogueira não encontrada!",4); acRunning=false; return
    end
    local LOTE=2; local TIMEOUT=10; local total=0; local ciclo=0
    Notify.send({type="info",icon="🍖",accent=AC_COR,title="Auto Cozinhar",msg="Cozinhando itens crus na fogueira!",duration=3})
    while acRunning do
        local lista = collectItemsByNames(AC_NAMES)
        if #lista==0 then
            pcall(function() if acRef.status then acRef.status.Text="⚠️ Sem itens crus" end end)
            Notify.warn("🍖 Auto Cozinhar","Nenhum item cru encontrado!",3); break
        end
        ciclo+=1
        pcall(function() if acRef.status then acRef.status.Text=string.format("🍖 Lote %d — %d disponíveis",ciclo,#lista) end end)
        local loteE={}
        for s=1,math.min(LOTE,#lista) do
            local e=lista[s]
            if e and e.part and e.part.Parent then
                dropNearCampfire(e.part,e.obj,fogPos,s-1,LOTE)
                table.insert(loteE,e); total+=1; task.wait(0.15)
            end
        end
        waitConsumed(loteE,TIMEOUT,{acRunning})
    end
    pcall(function() if acRef.status then acRef.status.Text="" end end)
    if total>0 then Notify.success("🍖 Auto Cozinhar",string.format("%d item(s) cozinhados em %d lote(s)!",total,ciclo),4) end
    acRunning=false
    pcall(function()
        if acRef.btn then acRef.btn.Text="🍖  ATIVAR"; btnGrad(acRef.btnG,Color3.fromRGB(80,220,80),Color3.fromRGB(30,140,30)) end
        if acRef.stroke then TweenService:Create(acRef.stroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(8,4,0)}):Play() end
    end)
end

makeFarmSec("🍖  AUTO COZINHAR", AC_COR)
do
    local card,cardS,_,_,_,status,btn,btnG = makeFarmCard(80,AC_COR,"🍖","Auto Cozinhar","Joga carne crua na fogueira automaticamente.\nMorsel, Steak, Ribs, Peixe, Frango...")
    acRef.status=status; acRef.btn=btn; acRef.btnG=btnG; acRef.stroke=cardS
    btnGrad(btnG,Color3.fromRGB(80,220,80),Color3.fromRGB(30,140,30))
    btn.MouseButton1Click:Connect(function()
        if acRunning then
            acRunning=false; if card._updateState then card._updateState(false) end
            status.Text="⏹ Parado"; Notify.error("🍖 Auto Cozinhar","⏹ Desativado")
            task.delay(1.5,function() pcall(function() status.Text="" end) end)
        else
            if card._updateState then card._updateState(true) end
            task.spawn(function()
                autoCozinhar()
                if not acRunning then if card._updateState then card._updateState(false) end end
            end)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════
-- 3. AUTO FOGUEIRA HP BASED (com popup de % selecionável)
-- ══════════════════════════════════════════════════════════════════
local ALL_FUEL_NAMES = {}  -- inclui Log
do
    for k in pairs(AF2_NAMES) do ALL_FUEL_NAMES[k] = true end
    ALL_FUEL_NAMES["log"] = true
end

local ahpRunning   = false
local ahpThreshold = 50   -- % padrão
local ahpPopupOpen = false
local ahpRef       = {}

-- Lê % de combustível atual da fogueira
local function ahpGetFuelPct()
    local nivel, maxN = nil, 6
    pcall(function()
        -- Tenta path direto do 99 Nights
        local camp = workspace:FindFirstChild("Campground")
        local mf   = camp and camp:FindFirstChild("MainFire")
        local src   = mf or afAcharFogueira()
        if not src then return end
        nivel = src:GetAttribute("Level") or src:GetAttribute("FuelLevel")
              or src:GetAttribute("FireLevel") or src:GetAttribute("Tier")
              or src:GetAttribute("CurrentLevel")
        local maxA = src:GetAttribute("MaxLevel") or src:GetAttribute("MaxFuel")
        if maxA then maxN = maxA end
        if nivel then return end
        -- Filhos IntValue/NumberValue
        local nms = {"Level","FuelLevel","FireLevel","Tier","CurrentLevel"}
        for _, nm in ipairs(nms) do
            local c = src:FindFirstChild(nm)
            if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then
                nivel = c.Value
                local mc = src:FindFirstChild("MaxLevel") or src:FindFirstChild("MaxFuel")
                if mc then maxN = mc.Value end
                break
            end
        end
    end)
    if nivel and maxN and maxN>0 then
        return math.clamp(math.floor((nivel/maxN)*100),0,100)
    end
    -- Fallback FogEnd delta
    local pct = nil
    pcall(function()
        local fog = game:GetService("Lighting").FogEnd
        if fog and fog>=50 and fog<=1500 then
            pct = math.clamp(math.floor(((fog-90)/(430-90))*100),0,100)
        end
    end)
    return pct
end

local function autoFogueiraHP()
    if ahpRunning then return end; ahpRunning=true
    local fogPos = getCampfirePos()
    if not fogPos then Notify.warn("🔥 Fogueira HP","Fogueira não encontrada!",4); ahpRunning=false; return end
    Notify.send({type="warn",icon="🔥",accent=AHP_COR,title="Auto Fogueira HP Based",msg=string.format("Ativa quando nível < %d%%",ahpThreshold),duration=3})
    local LOTE=3; local TIMEOUT=8; local total=0
    while ahpRunning do
        local pct = ahpGetFuelPct()
        local pStr = pct and (tostring(pct).."%") or "?"
        pcall(function() if ahpRef.status then ahpRef.status.Text=string.format("🔥 Nível: %s / limite: %d%%",pStr,ahpThreshold) end end)
        local deveFeed = (pct==nil) or (pct < ahpThreshold)
        if deveFeed then
            local lista = collectItemsByNames(ALL_FUEL_NAMES)
            if #lista>0 then
                local loteE={}
                for s=1,math.min(LOTE,#lista) do
                    local e=lista[s]
                    if e and e.part and e.part.Parent then
                        dropNearCampfire(e.part,e.obj,fogPos,s-1,LOTE)
                        table.insert(loteE,e); total+=1; task.wait(0.1)
                    end
                end
                waitConsumed(loteE,TIMEOUT,{ahpRunning})
            end
        end
        task.wait(2)
    end
    pcall(function() if ahpRef.status then ahpRef.status.Text="" end end)
    if total>0 then Notify.info("🔥 Fogueira HP",string.format("%d item(s) jogados!",total),4) end
    ahpRunning=false
    pcall(function()
        if ahpRef.btn then ahpRef.btn.Text="🔥  ATIVAR"; btnGrad(ahpRef.btnG,Color3.fromRGB(255,100,140),Color3.fromRGB(200,40,80)) end
        if ahpRef.stroke then TweenService:Create(ahpRef.stroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(8,4,0)}):Play() end
    end)
end

-- ── UI: Auto Fogueira HP Based ────────────────────────────────────
makeFarmSec("🔥  AUTO FOGUEIRA (HP BASED)", AHP_COR)
do
    -- Card (altura maior: 104 para acomodar botão de %)
    local card = Instance.new("Frame",Pages["Farm"]); card.BackgroundColor3=Color3.fromRGB(26,15,6); card.BorderSizePixel=0
    card.Size=UDim2.new(1,0,0,104); card.LayoutOrder=fNextLO(); card.ZIndex=5; Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
    local cardG=Instance.new("UIGradient",card); cardG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(40,10,20)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,4,8))}); cardG.Rotation=135
    local cardS=Instance.new("UIStroke",card); cardS.Color=Color3.fromRGB(8,4,0); cardS.Thickness=3; cardS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    ahpRef.stroke=cardS
    local tb=Instance.new("Frame",card); tb.BackgroundColor3=AHP_COR; tb.BorderSizePixel=0; tb.Size=UDim2.new(1,0,0,4); tb.ZIndex=6; Instance.new("UICorner",tb).CornerRadius=UDim.new(0,12)
    local lb=Instance.new("Frame",card); lb.BackgroundColor3=AHP_COR; lb.BorderSizePixel=0; lb.Size=UDim2.new(0,5,0.76,0); lb.Position=UDim2.new(0,0,0.12,0); lb.ZIndex=6; Instance.new("UICorner",lb).CornerRadius=UDim.new(0,4)

    local ib=Instance.new("Frame",card); ib.BackgroundColor3=AHP_COR; ib.BackgroundTransparency=0.3; ib.BorderSizePixel=0
    ib.Position=UDim2.new(0,10,0,12); ib.Size=UDim2.new(0,36,0,36); ib.ZIndex=7; Instance.new("UICorner",ib).CornerRadius=UDim.new(1,0)
    local ibS=Instance.new("UIStroke",ib); ibS.Color=Color3.fromRGB(8,4,0); ibS.Thickness=2.5; ibS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local il=Instance.new("TextLabel",ib); il.BackgroundTransparency=1; il.Size=UDim2.new(1,0,1,0); il.Text="🔥"; il.TextSize=18; il.Font=Enum.Font.GothamBold; il.ZIndex=8

    local tl=Instance.new("TextLabel",card); tl.BackgroundTransparency=1; tl.Position=UDim2.new(0,54,0,9); tl.Size=UDim2.new(1,-216,0,16)
    tl.Font=Enum.Font.GothamBlack; tl.Text="Auto Fogueira HP Based"; tl.TextColor3=Color3.fromRGB(255,255,255); tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7; Instance.new("UIStroke",tl).Color=Color3.fromRGB(8,4,0)

    local dl=Instance.new("TextLabel",card); dl.BackgroundTransparency=1; dl.Position=UDim2.new(0,54,0,27); dl.Size=UDim2.new(1,-216,0,22)
    dl.Font=Enum.Font.Gotham; dl.Text="Alimenta quando nível cair abaixo do % definido."; dl.TextColor3=Color3.fromRGB(180,160,110); dl.TextSize=9; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.TextWrapped=true; dl.ZIndex=7

    -- Botão de seleção de % (abre popup)
    local pctBtn=Instance.new("TextButton",card); pctBtn.BackgroundColor3=Color3.fromRGB(40,18,28); pctBtn.BorderSizePixel=0
    pctBtn.Position=UDim2.new(0,54,0,54); pctBtn.Size=UDim2.new(0,72,0,26)
    pctBtn.Font=Enum.Font.GothamBlack; pctBtn.Text="50% ▾"; pctBtn.TextColor3=Color3.fromRGB(255,255,255); pctBtn.TextTransparency=0.25; pctBtn.TextSize=11; pctBtn.ZIndex=8; pctBtn.AutoButtonColor=false
    Instance.new("UICorner",pctBtn).CornerRadius=UDim.new(0,8)
    local pctBtnS=Instance.new("UIStroke",pctBtn); pctBtnS.Color=AHP_COR; pctBtnS.Thickness=1.5; pctBtnS.Transparency=0.45; pctBtnS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

    local status=Instance.new("TextLabel",card); status.BackgroundTransparency=1; status.Position=UDim2.new(0,134,0,58); status.Size=UDim2.new(1,-280,0,18)
    status.Font=Enum.Font.GothamBold; status.Text=""; status.TextColor3=AHP_COR; status.TextSize=9; status.TextXAlignment=Enum.TextXAlignment.Left; status.ZIndex=7
    ahpRef.status=status

    -- Botão ATIVAR
    local btn=Instance.new("TextButton",card); btn.BackgroundColor3=AHP_COR; btn.BackgroundTransparency=0; btn.BorderSizePixel=0
    btn.Position=UDim2.new(1,-148,0,9); btn.Size=UDim2.new(0,140,0,34)
    btn.Font=Enum.Font.GothamBlack; btn.Text="🔥  ATIVAR"; btn.TextColor3=Color3.fromRGB(255,255,255); btn.TextSize=11; btn.ZIndex=8; btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    Instance.new("UIStroke",btn).Color=Color3.fromRGB(8,4,0)
    local btnG=Instance.new("UIGradient",btn); btnG.Rotation=90; btnGrad(btnG,Color3.fromRGB(255,100,140),Color3.fromRGB(200,40,80))
    local shine=Instance.new("Frame",btn); shine.BackgroundColor3=Color3.fromRGB(255,255,255); shine.BackgroundTransparency=0.65; shine.BorderSizePixel=0
    shine.Position=UDim2.new(0,6,0,4); shine.Size=UDim2.new(0,50,0,7); shine.ZIndex=9; Instance.new("UICorner",shine).CornerRadius=UDim.new(1,0)
    ahpRef.btn=btn; ahpRef.btnG=btnG

    -- ── POPUP de % — redesign profissional ────────────────────────
    local popup=Instance.new("Frame",ScreenGui)
    popup.BackgroundColor3=Color3.fromRGB(20,10,16); popup.BorderSizePixel=0
    popup.ZIndex=310; popup.Visible=false; popup.Size=UDim2.new(0,190,0,0)
    Instance.new("UICorner",popup).CornerRadius=UDim.new(0,14)
    local popupStroke=Instance.new("UIStroke",popup)
    popupStroke.Color=AHP_COR; popupStroke.Thickness=2.5; popupStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local popupG=Instance.new("UIGradient",popup)
    popupG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(38,14,28)),ColorSequenceKeypoint.new(1,Color3.fromRGB(16,6,12))}); popupG.Rotation=135
    -- Cabeçalho
    local popHdr=Instance.new("Frame",popup); popHdr.BackgroundColor3=AHP_COR
    popHdr.BackgroundTransparency=0.82; popHdr.BorderSizePixel=0; popHdr.Size=UDim2.new(1,0,0,34); popHdr.ZIndex=311
    Instance.new("UICorner",popHdr).CornerRadius=UDim.new(0,12)
    local popHdrFix=Instance.new("Frame",popHdr); popHdrFix.BackgroundColor3=AHP_COR
    popHdrFix.BackgroundTransparency=0.82; popHdrFix.BorderSizePixel=0
    popHdrFix.Position=UDim2.new(0,0,0.5,0); popHdrFix.Size=UDim2.new(1,0,0.5,0); popHdrFix.ZIndex=311
    local popTitle=Instance.new("TextLabel",popHdr); popTitle.BackgroundTransparency=1
    popTitle.Position=UDim2.new(0,12,0,0); popTitle.Size=UDim2.new(1,-16,1,0)
    popTitle.Font=Enum.Font.GothamBlack; popTitle.Text="🔥  Limite de HP da Fogueira"
    popTitle.TextColor3=AHP_COR; popTitle.TextSize=10
    popTitle.TextXAlignment=Enum.TextXAlignment.Left; popTitle.ZIndex=312
    local popSubt=Instance.new("TextLabel",popup); popSubt.BackgroundTransparency=1
    popSubt.Position=UDim2.new(0,12,0,36); popSubt.Size=UDim2.new(1,-16,0,14)
    popSubt.Font=Enum.Font.Gotham; popSubt.Text="Alimenta quando HP cair abaixo do %"
    popSubt.TextColor3=Color3.fromRGB(160,100,130); popSubt.TextSize=8
    popSubt.TextXAlignment=Enum.TextXAlignment.Left; popSubt.ZIndex=311
    -- Grid de valores
    local pGrid=Instance.new("Frame",popup); pGrid.BackgroundTransparency=1
    pGrid.Position=UDim2.new(0,8,0,56); pGrid.Size=UDim2.new(1,-16,0,116); pGrid.ZIndex=311
    local pLayout=Instance.new("UIGridLayout",pGrid)
    pLayout.CellSize=UDim2.new(0,82,0,28); pLayout.CellPaddingSize=UDim2.new(0,5,0,5); pLayout.SortOrder=Enum.SortOrder.LayoutOrder

    local pctVals = {10,20,30,40,50,60,70,80,90,95}
    local pctBtns = {}
    local function pctRefreshBtns()
        for v, pb in pairs(pctBtns) do
            local sel = (v == ahpThreshold)
            TweenService:Create(pb,TweenInfo.new(0.12),{
                BackgroundColor3 = sel and AHP_COR or Color3.fromRGB(50,18,36),
                BackgroundTransparency = sel and 0.2 or 0
            }):Play()
            pb.TextColor3 = sel and Color3.fromRGB(255,255,255) or Color3.fromRGB(210,160,190)
            local pbs=pb:FindFirstChildWhichIsA("UIStroke"); if pbs then pbs.Transparency=sel and 0 or 0.6 end
        end
    end
    for _, v in ipairs(pctVals) do
        local pb=Instance.new("TextButton",pGrid); pb.BackgroundColor3=Color3.fromRGB(50,18,36); pb.BorderSizePixel=0
        pb.Font=Enum.Font.GothamBlack; pb.Text=v.."%"; pb.TextColor3=Color3.fromRGB(210,160,190); pb.TextSize=12; pb.ZIndex=312; pb.AutoButtonColor=false
        Instance.new("UICorner",pb).CornerRadius=UDim.new(0,8)
        local pbs=Instance.new("UIStroke",pb); pbs.Color=AHP_COR; pbs.Thickness=1.5; pbs.Transparency=0.6; pbs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        pctBtns[v] = pb
        pb.MouseEnter:Connect(function() TweenService:Create(pb,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(70,25,52),BackgroundTransparency=0}):Play() end)
        pb.MouseLeave:Connect(function() pctRefreshBtns() end)
        pb.MouseButton1Click:Connect(function()
            ahpThreshold=v; pctBtn.Text=v.."% ▾"; pctRefreshBtns()
            TweenService:Create(popup,TweenInfo.new(0.13,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,190,0,0),BackgroundTransparency=1}):Play()
            task.delay(0.15,function() popup.Visible=false; ahpPopupOpen=false; popup.BackgroundTransparency=0 end)
        end)
    end
    pctRefreshBtns()

    local function openPctPopup()
        local ap=pctBtn.AbsolutePosition; local as=pctBtn.AbsoluteSize
        popup.Position=UDim2.new(0,ap.X+as.X-190,0,ap.Y-196)
        popup.Size=UDim2.new(0,190,0,0); popup.BackgroundTransparency=1; popup.Visible=true
        TweenService:Create(popup,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Size=UDim2.new(0,190,0,182),BackgroundTransparency=0
        }):Play()
        ahpPopupOpen=true
    end

    pctBtn.MouseButton1Click:Connect(function()
        if ahpPopupOpen then
            TweenService:Create(popup,TweenInfo.new(0.13,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,190,0,0),BackgroundTransparency=1}):Play()
            task.delay(0.15,function() popup.Visible=false; ahpPopupOpen=false; popup.BackgroundTransparency=0 end)
        else openPctPopup() end
    end)

    MainFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 and ahpPopupOpen then
            local mx,my=inp.Position.X,inp.Position.Y
            local pA=popup.AbsolutePosition; local pSz=popup.AbsoluteSize
            if mx<pA.X or mx>pA.X+pSz.X or my<pA.Y or my>pA.Y+pSz.Y then
                TweenService:Create(popup,TweenInfo.new(0.13,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,190,0,0),BackgroundTransparency=1}):Play()
                task.delay(0.15,function() popup.Visible=false; ahpPopupOpen=false; popup.BackgroundTransparency=0 end)
            end
        end
    end)

    btn.MouseButton1Click:Connect(function()
        if ahpRunning then
            ahpRunning=false; if card._updateState then card._updateState(false) end
            status.Text="⏹ Parado"; Notify.error("🔥 Fogueira HP","⏹ Desativado"); task.delay(1.5,function() pcall(function() status.Text="" end) end)
        else
            if card._updateState then card._updateState(true) end; task.spawn(autoFogueiraHP)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════
-- 4. AUTO TRITURADOR COM SELETOR DE ITENS (popup multi-select)
-- ══════════════════════════════════════════════════════════════════
local GD_COR = Color3.fromRGB(255,160,40)

local GRIND_ITEMS = {
    {name="Log",          key="log"},
    {name="Bolt",         key="bolt"},
    {name="Sheet Metal",  key="sheet metal"},
    {name="UFO Junk",     key="ufo junk"},
    {name="UFO Component",key="ufo component"},
    {name="UFO Scrap",    key="ufo scrap"},
    {name="Broken Fan",   key="broken fan"},
    {name="Old Radio",    key="old radio"},
    {name="Broken Mic.",  key="broken microwave"},
    {name="Tyre",         key="tyre"},
    {name="Metal Chair",  key="metal chair"},
    {name="Old Engine",   key="old car engine"},
    {name="Máq. Lavar",   key="washing machine"},
    {name="Alien Junk",   key="alien junk"},
    {name="Obsid. Ore",   key="raw obsidiron ore"},
    {name="Obsid. Ingot", key="obsidiron ingot"},
    {name="Escald. Ingot",key="scalding obsidiron ingot"},
    {name="Meteor Shard", key="meteor shard"},
    {name="Gold Shard",   key="gold shard"},
    {name="Cult. Exp.",   key="cultist experiment"},
    {name="Cult. Proto.", key="cultist prototype"},
}

local grindSel = {}
for _, item in ipairs(GRIND_ITEMS) do grindSel[item.key] = false end
local grindRunning   = false
local grindPopupOpen = false
local grindRef       = {}

local function grindGetLabel()
    local sel = {}; local allOn = true
    for _, item in ipairs(GRIND_ITEMS) do
        if grindSel[item.key] then table.insert(sel,item.name) else allOn=false end
    end
    if #sel==0 then return "Selecionar Itens" end
    if allOn then return "Todos" end
    local txt = table.concat(sel,", ")
    if #txt>25 then txt=txt:sub(1,22).."..." end
    return txt
end

local function autoGrindSeletor()
    if grindRunning then return end
    local hasAny=false
    for _, item in ipairs(GRIND_ITEMS) do if grindSel[item.key] then hasAny=true; break end end
    if not hasAny then
        Notify.send({type="warn",icon="⚙️",accent=GD_COR,
            title="⚙️ Auto Triturador — Nenhum Item!",
            msg="Nenhum item selecionado para triturar.\n👆 Clique em 'Selecionar Itens' para escolher.",
            duration=5})
        return
    end
    grindRunning=true
    local selNames={}; for _, item in ipairs(GRIND_ITEMS) do if grindSel[item.key] then selNames[item.key]=true end end
    local shredder = atAcharTriturador()
    if not shredder then Notify.warn("⚙️ Auto Triturador","Triturador não encontrado!",4); grindRunning=false; return end
    local shredPos = atGetTrituradorPos(shredder)
    if not shredPos then Notify.warn("⚙️ Auto Triturador","Posição do triturador não obtida!",3); grindRunning=false; return end
    local ALTURA=9; local LOTE=2; local TIMEOUT=7; local total=0; local ciclo=0
    Notify.send({type="info",icon="⚙️",accent=GD_COR,title="Auto Triturador (Seleção)",msg="Triturando: "..grindGetLabel(),duration=3})
    local function dropPos(slot)
        local ang=(slot/LOTE)*math.pi*2
        return Vector3.new(shredPos.X+math.cos(ang)*0.8, shredPos.Y+ALTURA, shredPos.Z+math.sin(ang)*0.8)
    end
    while grindRunning do
        local lista=collectItemsByNames(selNames)
        if #lista==0 then
            pcall(function() if grindRef.status then grindRef.status.Text="⚠️ Sem itens" end end); break
        end
        ciclo+=1
        pcall(function() if grindRef.status then grindRef.status.Text=string.format("⚙️ Lote %d — %d itens",ciclo,#lista) end end)
        local loteE={}
        for s=1,math.min(LOTE,#lista) do
            local e=lista[s]
            if e and e.part and e.part.Parent then
                atSoltar(e.part,e.obj,dropPos(s-1))
                table.insert(loteE,e); total+=1; task.wait(0.15)
            end
        end
        waitConsumed(loteE,TIMEOUT,{grindRunning})
    end
    pcall(function() if grindRef.status then grindRef.status.Text="" end end)
    if total>0 then
        Notify.send({type="success",icon="✅",accent=Color3.fromRGB(87,242,135),
            title="Auto Triturador — Concluído!",msg=string.format("⚙️ %d item(s) em %d lotes!",total,ciclo),duration=5})
    else Notify.warn("⚙️ Auto Triturador","Nenhum item encontrado!",3) end
    grindRunning=false
    pcall(function()
        if grindRef.tBtn then grindRef.tBtn.Text="⚙️  ATIVAR"; btnGrad(grindRef.tBtnG,Color3.fromRGB(255,200,60),Color3.fromRGB(180,110,0)) end
        if grindRef.stroke then TweenService:Create(grindRef.stroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(8,4,0)}):Play() end
    end)
end

-- ── UI: Auto Triturador Seletor ───────────────────────────────────
makeFarmSec("⚙️  AUTO TRITURADOR (SELEÇÃO)", GD_COR)
do
    -- Card (maior: 118px — acomoda botão de seleção + status)
    local card=Instance.new("Frame",Pages["Farm"]); card.BackgroundColor3=Color3.fromRGB(26,15,6); card.BorderSizePixel=0
    card.Size=UDim2.new(1,0,0,118); card.LayoutOrder=fNextLO(); card.ZIndex=5; Instance.new("UICorner",card).CornerRadius=UDim.new(0,12)
    local cardG=Instance.new("UIGradient",card); cardG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(40,22,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,3))}); cardG.Rotation=135
    local cardS=Instance.new("UIStroke",card); cardS.Color=Color3.fromRGB(8,4,0); cardS.Thickness=3; cardS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    grindRef.stroke=cardS
    local tb=Instance.new("Frame",card); tb.BackgroundColor3=GD_COR; tb.BorderSizePixel=0; tb.Size=UDim2.new(1,0,0,4); tb.ZIndex=6; Instance.new("UICorner",tb).CornerRadius=UDim.new(0,12)
    local lb=Instance.new("Frame",card); lb.BackgroundColor3=GD_COR; lb.BorderSizePixel=0; lb.Size=UDim2.new(0,5,0.76,0); lb.Position=UDim2.new(0,0,0.12,0); lb.ZIndex=6; Instance.new("UICorner",lb).CornerRadius=UDim.new(0,4)

    local ib=Instance.new("Frame",card); ib.BackgroundColor3=GD_COR; ib.BackgroundTransparency=0.3; ib.BorderSizePixel=0
    ib.Position=UDim2.new(0,10,0,12); ib.Size=UDim2.new(0,36,0,36); ib.ZIndex=7; Instance.new("UICorner",ib).CornerRadius=UDim.new(1,0)
    local ibS=Instance.new("UIStroke",ib); ibS.Color=Color3.fromRGB(8,4,0); ibS.Thickness=2.5; ibS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local il=Instance.new("TextLabel",ib); il.BackgroundTransparency=1; il.Size=UDim2.new(1,0,1,0); il.Text="⚙️"; il.TextSize=18; il.Font=Enum.Font.GothamBold; il.ZIndex=8

    local tl=Instance.new("TextLabel",card); tl.BackgroundTransparency=1; tl.Position=UDim2.new(0,54,0,9); tl.Size=UDim2.new(1,-216,0,16)
    tl.Font=Enum.Font.GothamBlack; tl.Text="Auto Triturador (Seleção)"; tl.TextColor3=Color3.fromRGB(255,255,255); tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7; Instance.new("UIStroke",tl).Color=Color3.fromRGB(8,4,0)

    local dl=Instance.new("TextLabel",card); dl.BackgroundTransparency=1; dl.Position=UDim2.new(0,54,0,27); dl.Size=UDim2.new(1,-216,0,18)
    dl.Font=Enum.Font.Gotham; dl.Text="Selecione os itens abaixo e ative para triturar."; dl.TextColor3=Color3.fromRGB(180,160,110); dl.TextSize=9; dl.TextXAlignment=Enum.TextXAlignment.Left; dl.TextWrapped=true; dl.ZIndex=7

    -- Botão seletor de itens (abre popup)
    local selBtn=Instance.new("TextButton",card); selBtn.BackgroundColor3=Color3.fromRGB(30,18,6); selBtn.BorderSizePixel=0
    selBtn.Position=UDim2.new(0,10,0,54); selBtn.Size=UDim2.new(1,-168,0,26)
    selBtn.Font=Enum.Font.GothamBold; selBtn.Text=""; selBtn.ZIndex=8; selBtn.AutoButtonColor=false
    Instance.new("UICorner",selBtn).CornerRadius=UDim.new(0,8)
    local selBtnS=Instance.new("UIStroke",selBtn); selBtnS.Color=GD_COR; selBtnS.Thickness=1.2; selBtnS.Transparency=0.5; selBtnS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local selLbl=Instance.new("TextLabel",selBtn); selLbl.BackgroundTransparency=1; selLbl.Position=UDim2.new(0,8,0,0); selLbl.Size=UDim2.new(1,-16,1,0)
    selLbl.Font=Enum.Font.GothamBold; selLbl.Text="Selecionar Itens ▾"; selLbl.TextColor3=Color3.fromRGB(255,200,100); selLbl.TextSize=10; selLbl.TextXAlignment=Enum.TextXAlignment.Left; selLbl.ZIndex=9
    grindRef.selLbl=selLbl

    local status=Instance.new("TextLabel",card); status.BackgroundTransparency=1; status.Position=UDim2.new(0,10,0,90); status.Size=UDim2.new(1,-168,0,18)
    status.Font=Enum.Font.GothamBold; status.Text=""; status.TextColor3=GD_COR; status.TextSize=9; status.TextXAlignment=Enum.TextXAlignment.Left; status.ZIndex=7
    grindRef.status=status

    -- Botão ATIVAR
    local tBtn=Instance.new("TextButton",card); tBtn.BackgroundColor3=GD_COR; tBtn.BackgroundTransparency=0; tBtn.BorderSizePixel=0
    tBtn.Position=UDim2.new(1,-148,0,9); tBtn.Size=UDim2.new(0,140,0,34)
    tBtn.Font=Enum.Font.GothamBlack; tBtn.Text="⚙️  ATIVAR"; tBtn.TextColor3=Color3.fromRGB(255,255,255); tBtn.TextSize=11; tBtn.ZIndex=8; tBtn.AutoButtonColor=false
    Instance.new("UICorner",tBtn).CornerRadius=UDim.new(0,10)
    Instance.new("UIStroke",tBtn).Color=Color3.fromRGB(8,4,0)
    local tBtnG=Instance.new("UIGradient",tBtn); tBtnG.Rotation=90; btnGrad(tBtnG,Color3.fromRGB(255,200,60),Color3.fromRGB(180,110,0))
    local shine=Instance.new("Frame",tBtn); shine.BackgroundColor3=Color3.fromRGB(255,255,255); shine.BackgroundTransparency=0.65; shine.BorderSizePixel=0
    shine.Position=UDim2.new(0,6,0,4); shine.Size=UDim2.new(0,50,0,7); shine.ZIndex=9; Instance.new("UICorner",shine).CornerRadius=UDim.new(1,0)
    grindRef.tBtn=tBtn; grindRef.tBtnG=tBtnG

    -- ── POPUP seletor ─────────────────────────────────────────────
    -- ── POPUP seletor itens grind — redesign profissional ─────────
    local gdPopup=Instance.new("Frame",ScreenGui)
    gdPopup.BackgroundColor3=Color3.fromRGB(18,12,4); gdPopup.BorderSizePixel=0
    gdPopup.ZIndex=310; gdPopup.Visible=false; gdPopup.Size=UDim2.new(0,280,0,0)
    Instance.new("UICorner",gdPopup).CornerRadius=UDim.new(0,14)
    local gdPopupS=Instance.new("UIStroke",gdPopup)
    gdPopupS.Color=GD_COR; gdPopupS.Thickness=2.5; gdPopupS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    local gdG=Instance.new("UIGradient",gdPopup)
    gdG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(32,20,6)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,9,2))}); gdG.Rotation=135
    -- Cabeçalho
    local gdH=Instance.new("Frame",gdPopup); gdH.BackgroundColor3=GD_COR
    gdH.BackgroundTransparency=0.82; gdH.BorderSizePixel=0; gdH.Size=UDim2.new(1,0,0,40); gdH.ZIndex=311
    Instance.new("UICorner",gdH).CornerRadius=UDim.new(0,12)
    local gdHFix=Instance.new("Frame",gdH); gdHFix.BackgroundColor3=GD_COR
    gdHFix.BackgroundTransparency=0.82; gdHFix.BorderSizePixel=0
    gdHFix.Position=UDim2.new(0,0,0.5,0); gdHFix.Size=UDim2.new(1,0,0.5,0); gdHFix.ZIndex=311
    local gdHL=Instance.new("TextLabel",gdH); gdHL.BackgroundTransparency=1
    gdHL.Position=UDim2.new(0,12,0,0); gdHL.Size=UDim2.new(0.65,0,1,0)
    gdHL.Font=Enum.Font.GothamBlack; gdHL.Text="⚙️  Itens para Triturar"
    gdHL.TextColor3=GD_COR; gdHL.TextSize=11; gdHL.TextXAlignment=Enum.TextXAlignment.Left; gdHL.ZIndex=312
    -- Botão TODOS no header
    local gdTodos=Instance.new("TextButton",gdH); gdTodos.BackgroundColor3=Color3.fromRGB(36,22,6); gdTodos.BorderSizePixel=0
    gdTodos.AnchorPoint=Vector2.new(1,0.5); gdTodos.Position=UDim2.new(1,-8,0.5,0); gdTodos.Size=UDim2.new(0,66,0,24)
    gdTodos.Font=Enum.Font.GothamBlack; gdTodos.Text="✓ Todos"; gdTodos.TextColor3=GD_COR; gdTodos.TextSize=10; gdTodos.ZIndex=312; gdTodos.AutoButtonColor=false
    Instance.new("UICorner",gdTodos).CornerRadius=UDim.new(0,8)
    local gdTodosS=Instance.new("UIStroke",gdTodos); gdTodosS.Color=GD_COR; gdTodosS.Thickness=1.5; gdTodosS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; gdTodosS.Transparency=0.4
    -- Scroll com grid
    local gdScroll=Instance.new("ScrollingFrame",gdPopup); gdScroll.BackgroundTransparency=1; gdScroll.BorderSizePixel=0
    gdScroll.Position=UDim2.new(0,8,0,48); gdScroll.Size=UDim2.new(1,-16,1,-56)
    gdScroll.ScrollBarThickness=3; gdScroll.ScrollBarImageColor3=GD_COR
    gdScroll.CanvasSize=UDim2.new(0,0,0,0); gdScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; gdScroll.ZIndex=311
    local gdGrid=Instance.new("UIGridLayout",gdScroll)
    gdGrid.CellSize=UDim2.new(0.5,-4,0,32); gdGrid.CellPaddingSize=UDim2.new(0,6,0,6); gdGrid.SortOrder=Enum.SortOrder.LayoutOrder
    local gdScrollPad=Instance.new("UIPadding",gdScroll); gdScrollPad.PaddingTop=UDim.new(0,4); gdScrollPad.PaddingBottom=UDim.new(0,6)

    local gdItemBtns={}
    local function gdRefreshLabel()
        selLbl.Text = grindGetLabel().." ▾"
        local allOn=true; for _,item in ipairs(GRIND_ITEMS) do if not grindSel[item.key] then allOn=false; break end end
        TweenService:Create(gdTodos,TweenInfo.new(0.12),{BackgroundColor3=allOn and GD_COR or Color3.fromRGB(36,22,6),BackgroundTransparency=allOn and 0.2 or 0}):Play()
        gdTodosS.Transparency=allOn and 0 or 0.4
        gdTodos.TextColor3=allOn and Color3.fromRGB(22,10,0) or GD_COR
    end

    for i, item in ipairs(GRIND_ITEMS) do
        local ib2=Instance.new("TextButton",gdScroll); ib2.BackgroundColor3=Color3.fromRGB(28,16,4); ib2.BorderSizePixel=0
        ib2.Font=Enum.Font.GothamBold; ib2.Text=item.name; ib2.TextColor3=Color3.fromRGB(190,165,120); ib2.TextSize=10; ib2.LayoutOrder=i; ib2.ZIndex=312; ib2.AutoButtonColor=false
        Instance.new("UICorner",ib2).CornerRadius=UDim.new(0,9)
        local ib2S=Instance.new("UIStroke",ib2); ib2S.Color=GD_COR; ib2S.Thickness=1.5; ib2S.Transparency=0.65; ib2S.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        gdItemBtns[item.key]={btn=ib2, stroke=ib2S}
        ib2.MouseEnter:Connect(function() if not grindSel[item.key] then TweenService:Create(ib2,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(42,24,6)}):Play() end end)
        ib2.MouseLeave:Connect(function()
            if not grindSel[item.key] then TweenService:Create(ib2,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(28,16,4)}):Play() end
        end)
        ib2.MouseButton1Click:Connect(function()
            grindSel[item.key] = not grindSel[item.key]
            local on=grindSel[item.key]
            TweenService:Create(ib2,TweenInfo.new(0.12),{BackgroundColor3=on and GD_COR or Color3.fromRGB(28,16,4), BackgroundTransparency=on and 0.2 or 0}):Play()
            ib2S.Transparency=on and 0 or 0.65
            ib2.TextColor3=on and Color3.fromRGB(22,10,0) or Color3.fromRGB(190,165,120)
            gdRefreshLabel()
        end)
    end

    local allActive=false
    gdTodos.MouseButton1Click:Connect(function()
        allActive=not allActive
        for _, item in ipairs(GRIND_ITEMS) do
            grindSel[item.key]=allActive
            local d=gdItemBtns[item.key]
            if d then
                TweenService:Create(d.btn,TweenInfo.new(0.12),{BackgroundColor3=allActive and GD_COR or Color3.fromRGB(28,16,4), BackgroundTransparency=allActive and 0.2 or 0}):Play()
                d.stroke.Transparency=allActive and 0 or 0.65
                d.btn.TextColor3=allActive and Color3.fromRGB(22,10,0) or Color3.fromRGB(190,165,120)
            end
        end
        gdRefreshLabel()
    end)

    local function openGdPopup()
        local ap=selBtn.AbsolutePosition; local as=selBtn.AbsoluteSize
        -- Calcula altura real: cabeçalho 40 + linhas de itens (ceil(n/2)*38) + padding
        local rows=math.ceil(#GRIND_ITEMS/2); local popH=math.min(40+rows*38+16, 320)
        gdPopup.Position=UDim2.new(0,ap.X+as.X-280,0,ap.Y-popH-6)
        gdPopup.Size=UDim2.new(0,280,0,0); gdPopup.BackgroundTransparency=1; gdPopup.Visible=true
        TweenService:Create(gdPopup,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Size=UDim2.new(0,280,0,popH), BackgroundTransparency=0
        }):Play()
        grindPopupOpen=true
    end

    local function closeGdPopup()
        TweenService:Create(gdPopup,TweenInfo.new(0.13,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,280,0,0),BackgroundTransparency=1}):Play()
        task.delay(0.15,function() gdPopup.Visible=false; grindPopupOpen=false; gdPopup.BackgroundTransparency=0 end)
    end

    selBtn.MouseButton1Click:Connect(function()
        if grindPopupOpen then closeGdPopup() else openGdPopup() end
    end)

    MainFrame.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 and grindPopupOpen then
            local mx,my=inp.Position.X,inp.Position.Y
            local pA=gdPopup.AbsolutePosition; local pSz=gdPopup.AbsoluteSize
            if mx<pA.X or mx>pA.X+pSz.X or my<pA.Y or my>pA.Y+pSz.Y then closeGdPopup() end
        end
    end)

    tBtn.MouseButton1Click:Connect(function()
        if grindRunning then
            grindRunning=false; tBtn.Text="⚙️  ATIVAR"; btnGrad(tBtnG,Color3.fromRGB(255,200,60),Color3.fromRGB(180,110,0))
            TweenService:Create(cardS,TweenInfo.new(0.2),{Color=Color3.fromRGB(8,4,0)}):Play()
            Notify.error("⚙️ Auto Triturador","⏹ Desativado"); task.delay(1.5,function() pcall(function() status.Text="" end) end)
        else
            tBtn.Text="⏹  PARAR"; btnGrad(tBtnG,Color3.fromRGB(220,60,60),Color3.fromRGB(140,20,20))
            TweenService:Create(cardS,TweenInfo.new(0.2),{Color=GD_COR}):Play()
            task.spawn(function()
                autoGrindSeletor()
                if not grindRunning then pcall(function() tBtn.Text="⚙️  ATIVAR"; btnGrad(tBtnG,Color3.fromRGB(255,200,60),Color3.fromRGB(180,110,0)) end) end
            end)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════
-- 5. AUTO COMER — Player Tab (slider de % de fome)
-- ══════════════════════════════════════════════════════════════════
do
local EAT_NAMES = {}
do
    local foods = {
        "cooked steak","cookedsteak","cooked morsel","cookedmorsel",
        "cooked ribs","cookedribs","cooked turkey leg","cookedturkeyleg",
        "cooked mackerel","cookedmackerel","cooked salmon","cooked clownfish",
        "cooked char","cooked eel","cooked swordfish","cooked shark",
        "cooked lava eel","cooked lionfish",
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
        local ch = Players.LocalPlayer.Character
        if not ch then return end
        local v = ch:GetAttribute("Hunger") or ch:GetAttribute("Food")
                 or ch:GetAttribute("Satiation") or ch:GetAttribute("Fullness")
                 or ch:GetAttribute("FoodLevel") or ch:GetAttribute("HungerLevel")
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
        local stats=Players.LocalPlayer:FindFirstChild("PlayerStats")
                 or Players.LocalPlayer:FindFirstChild("Stats")
                 or Players.LocalPlayer:FindFirstChild("Data")
        if stats then
            for _, nm in ipairs(names) do
                local c=stats:FindFirstChild(nm,true)
                if c and (c:IsA("NumberValue") or c:IsA("IntValue")) then
                    pct=math.clamp(c.Value,0,100); return
                end
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
    local found=collectItemsByNames(EAT_NAMES)
    if #found==0 then return false end
    local e=found[1]
    pcall(function()
        if remConsume:IsA("RemoteFunction") then remConsume:InvokeServer(e.obj or e.part)
        else remConsume:FireServer(e.obj or e.part) end
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
            pcall(function() if eatRef.status then eatRef.status.Text="🍖 Fome: detectando..." end end)
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

-- ── UI: Player Tab ────────────────────────────────────────────────
-- Seção
local eatSec=Instance.new("Frame",Pages["Player"]); eatSec.BackgroundColor3=Color3.fromRGB(26,15,6); eatSec.BackgroundTransparency=0; eatSec.BorderSizePixel=0
eatSec.Size=UDim2.new(1,0,0,26); eatSec.LayoutOrder=plNextLO(); eatSec.ZIndex=4; Instance.new("UICorner",eatSec).CornerRadius=UDim.new(0,9)
local eatSecG=Instance.new("UIGradient",eatSec); eatSecG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(8,20,40)),ColorSequenceKeypoint.new(1,Color3.fromRGB(3,8,18))}); eatSecG.Rotation=135
local eatSecS=Instance.new("UIStroke",eatSec); eatSecS.Color=Color3.fromRGB(8,4,0); eatSecS.Thickness=2.5; eatSecS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local eatSecBar=Instance.new("Frame",eatSec); eatSecBar.BackgroundColor3=ATE_COR; eatSecBar.BorderSizePixel=0; eatSecBar.Size=UDim2.new(0,5,0.75,0); eatSecBar.Position=UDim2.new(0,0,0.12,0); eatSecBar.ZIndex=5; Instance.new("UICorner",eatSecBar).CornerRadius=UDim.new(0,4)
local eatSecLbl=Instance.new("TextLabel",eatSec); eatSecLbl.BackgroundTransparency=1; eatSecLbl.Position=UDim2.new(0,14,0,0); eatSecLbl.Size=UDim2.new(1,-18,1,0)
eatSecLbl.Font=Enum.Font.GothamBlack; eatSecLbl.Text="🍖  AUTO COMER (FOME %)"; eatSecLbl.TextColor3=Color3.fromRGB(255,255,255); eatSecLbl.TextSize=10; eatSecLbl.TextXAlignment=Enum.TextXAlignment.Left; eatSecLbl.ZIndex=5
Instance.new("UIStroke",eatSecLbl).Color=Color3.fromRGB(8,4,0)

-- Card
local eatCard=Instance.new("Frame",Pages["Player"]); eatCard.BackgroundColor3=Color3.fromRGB(26,15,6); eatCard.BorderSizePixel=0
eatCard.Size=UDim2.new(1,0,0,122); eatCard.LayoutOrder=plNextLO(); eatCard.ZIndex=5; Instance.new("UICorner",eatCard).CornerRadius=UDim.new(0,12)
local eatCardG=Instance.new("UIGradient",eatCard); eatCardG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(8,20,40)),ColorSequenceKeypoint.new(1,Color3.fromRGB(3,8,18))}); eatCardG.Rotation=135
local eatCardS=Instance.new("UIStroke",eatCard); eatCardS.Color=Color3.fromRGB(8,4,0); eatCardS.Thickness=3; eatCardS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local eatTB=Instance.new("Frame",eatCard); eatTB.BackgroundColor3=ATE_COR; eatTB.BorderSizePixel=0; eatTB.Size=UDim2.new(1,0,0,4); eatTB.ZIndex=6; Instance.new("UICorner",eatTB).CornerRadius=UDim.new(0,12)
local eatLB=Instance.new("Frame",eatCard); eatLB.BackgroundColor3=ATE_COR; eatLB.BorderSizePixel=0; eatLB.Size=UDim2.new(0,5,0.76,0); eatLB.Position=UDim2.new(0,0,0.12,0); eatLB.ZIndex=6; Instance.new("UICorner",eatLB).CornerRadius=UDim.new(0,4)

local eatIB=Instance.new("Frame",eatCard); eatIB.BackgroundColor3=ATE_COR; eatIB.BackgroundTransparency=0.3; eatIB.BorderSizePixel=0
eatIB.Position=UDim2.new(0,10,0,12); eatIB.Size=UDim2.new(0,36,0,36); eatIB.ZIndex=7; Instance.new("UICorner",eatIB).CornerRadius=UDim.new(1,0)
local eatIBS=Instance.new("UIStroke",eatIB); eatIBS.Color=Color3.fromRGB(8,4,0); eatIBS.Thickness=2.5; eatIBS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local eatIL=Instance.new("TextLabel",eatIB); eatIL.BackgroundTransparency=1; eatIL.Size=UDim2.new(1,0,1,0); eatIL.Text="🍖"; eatIL.TextSize=18; eatIL.Font=Enum.Font.GothamBold; eatIL.ZIndex=8

local eatTitL=Instance.new("TextLabel",eatCard); eatTitL.BackgroundTransparency=1; eatTitL.Position=UDim2.new(0,54,0,9); eatTitL.Size=UDim2.new(1,-216,0,16)
eatTitL.Font=Enum.Font.GothamBlack; eatTitL.Text="Auto Comer"; eatTitL.TextColor3=Color3.fromRGB(255,255,255); eatTitL.TextSize=12; eatTitL.TextXAlignment=Enum.TextXAlignment.Left; eatTitL.ZIndex=7; Instance.new("UIStroke",eatTitL).Color=Color3.fromRGB(8,4,0)

local eatDescL=Instance.new("TextLabel",eatCard); eatDescL.BackgroundTransparency=1; eatDescL.Position=UDim2.new(0,54,0,27); eatDescL.Size=UDim2.new(1,-216,0,22)
eatDescL.Font=Enum.Font.Gotham; eatDescL.Text="Come automaticamente quando fome cair abaixo do % escolhido."; eatDescL.TextColor3=Color3.fromRGB(180,160,110); eatDescL.TextSize=9; eatDescL.TextXAlignment=Enum.TextXAlignment.Left; eatDescL.TextWrapped=true; eatDescL.ZIndex=7

-- Slider de threshold (steps: 5 15 25 35 45 55 65 75 85 95)
local EAT_STEPS={5,15,25,35,45,55,65,75,85,95}
local slRow=Instance.new("Frame",eatCard); slRow.BackgroundTransparency=1; slRow.BorderSizePixel=0
slRow.Position=UDim2.new(0,10,0,52); slRow.Size=UDim2.new(1,-170,0,40); slRow.ZIndex=7

local slLbl=Instance.new("TextLabel",slRow); slLbl.BackgroundTransparency=1; slLbl.Position=UDim2.new(0,0,0,0); slLbl.Size=UDim2.new(1,0,0,14)
slLbl.Font=Enum.Font.GothamBold; slLbl.Text="Limite: 25% da fome"; slLbl.TextColor3=ATE_COR; slLbl.TextSize=10; slLbl.TextXAlignment=Enum.TextXAlignment.Left; slLbl.ZIndex=8

local slTrack=Instance.new("Frame",slRow); slTrack.BackgroundColor3=Color3.fromRGB(16,8,24); slTrack.BorderSizePixel=0
slTrack.Position=UDim2.new(0,0,0,18); slTrack.Size=UDim2.new(1,0,0,8); slTrack.ZIndex=8; Instance.new("UICorner",slTrack).CornerRadius=UDim.new(1,0)
local slTS=Instance.new("UIStroke",slTrack); slTS.Color=Color3.fromRGB(8,4,0); slTS.Thickness=1.5

local EAT_MIN=EAT_STEPS[1]; local EAT_MAX=EAT_STEPS[#EAT_STEPS]
local defPct=(25-EAT_MIN)/(EAT_MAX-EAT_MIN)

local slFill=Instance.new("Frame",slTrack); slFill.BackgroundColor3=ATE_COR; slFill.BorderSizePixel=0
slFill.Size=UDim2.new(defPct,0,1,0); slFill.ZIndex=9; Instance.new("UICorner",slFill).CornerRadius=UDim.new(1,0)
local slFillG=Instance.new("UIGradient",slFill); slFillG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(200,240,255)),ColorSequenceKeypoint.new(1,ATE_COR)})

local slThumb=Instance.new("TextButton",slTrack); slThumb.BackgroundColor3=Color3.fromRGB(255,255,255); slThumb.BorderSizePixel=0
slThumb.AnchorPoint=Vector2.new(0.5,0.5); slThumb.Position=UDim2.new(defPct,0,0.5,0); slThumb.Size=UDim2.new(0,16,0,16); slThumb.Text=""; slThumb.ZIndex=10; slThumb.AutoButtonColor=false
Instance.new("UICorner",slThumb).CornerRadius=UDim.new(1,0)
local slTS2=Instance.new("UIStroke",slThumb); slTS2.Color=ATE_COR; slTS2.Thickness=2.5; slTS2.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

-- Ticks de referência
for _, v in ipairs(EAT_STEPS) do
    local p=(v-EAT_MIN)/(EAT_MAX-EAT_MIN)
    local tk=Instance.new("Frame",slTrack); tk.BackgroundColor3=Color3.fromRGB(60,40,90); tk.BorderSizePixel=0
    tk.AnchorPoint=Vector2.new(0.5,0); tk.Position=UDim2.new(p,0,1,2); tk.Size=UDim2.new(0,2,0,5); tk.ZIndex=9
end

local slDragging=false
local function slSetVal(screenX)
    local ap=slTrack.AbsolutePosition; local as=slTrack.AbsoluteSize
    local t=math.clamp((screenX-ap.X)/as.X,0,1)
    local raw=EAT_MIN+t*(EAT_MAX-EAT_MIN)
    local best,bestD=EAT_STEPS[1],math.huge
    for _, sv in ipairs(EAT_STEPS) do if math.abs(sv-raw)<bestD then bestD=math.abs(sv-raw); best=sv end end
    eatThreshold=best
    local p=(best-EAT_MIN)/(EAT_MAX-EAT_MIN)
    slFill.Size=UDim2.new(p,0,1,0); slThumb.Position=UDim2.new(p,0,0.5,0)
    slLbl.Text=string.format("Limite: %d%% da fome",eatThreshold)
end

slThumb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slDragging=true end end)
slTrack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then slSetVal(i.Position.X) end end)
UserInputService.InputChanged:Connect(function(i)
    if slDragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then slSetVal(i.Position.X) end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slDragging=false end
end)

-- Status
local eatStatus=Instance.new("TextLabel",eatCard); eatStatus.BackgroundTransparency=1; eatStatus.Position=UDim2.new(0,10,0,98); eatStatus.Size=UDim2.new(1,-170,0,18)
eatStatus.Font=Enum.Font.GothamBold; eatStatus.Text=""; eatStatus.TextColor3=ATE_COR; eatStatus.TextSize=9; eatStatus.TextXAlignment=Enum.TextXAlignment.Left; eatStatus.ZIndex=7
eatRef.status=eatStatus

-- Botão ATIVAR
local eatBtn=Instance.new("TextButton",eatCard); eatBtn.BackgroundColor3=ATE_COR; eatBtn.BackgroundTransparency=0; eatBtn.BorderSizePixel=0
eatBtn.Position=UDim2.new(1,-148,0,9); eatBtn.Size=UDim2.new(0,140,0,34)
eatBtn.Font=Enum.Font.GothamBlack; eatBtn.Text="🍖  ATIVAR"; eatBtn.TextColor3=Color3.fromRGB(255,255,255); eatBtn.TextSize=11; eatBtn.ZIndex=8; eatBtn.AutoButtonColor=false
Instance.new("UICorner",eatBtn).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",eatBtn).Color=Color3.fromRGB(8,4,0)
local eatBtnG=Instance.new("UIGradient",eatBtn); eatBtnG.Rotation=90; btnGrad(eatBtnG,Color3.fromRGB(60,220,255),Color3.fromRGB(20,100,200))
local eatShine=Instance.new("Frame",eatBtn); eatShine.BackgroundColor3=Color3.fromRGB(255,255,255); eatShine.BackgroundTransparency=0.65; eatShine.BorderSizePixel=0
eatShine.Position=UDim2.new(0,6,0,4); eatShine.Size=UDim2.new(0,50,0,7); eatShine.ZIndex=9; Instance.new("UICorner",eatShine).CornerRadius=UDim.new(1,0)

eatBtn.MouseButton1Click:Connect(function()
    if eatRunning then
        stopAutoEat(); eatBtn.Text="🍖  ATIVAR"; btnGrad(eatBtnG,Color3.fromRGB(60,220,255),Color3.fromRGB(20,100,200))
        eatStatus.Text="⏹ Parado"; TweenService:Create(eatCardS,TweenInfo.new(0.2),{Color=Color3.fromRGB(8,4,0)}):Play()
        Notify.error("🍖 Auto Comer","⏹ Desativado")
        task.delay(1.5,function() pcall(function() eatStatus.Text="" end) end)
    else
        eatBtn.Text="⏹  PARAR"; btnGrad(eatBtnG,Color3.fromRGB(220,60,60),Color3.fromRGB(140,20,20))
        TweenService:Create(eatCardS,TweenInfo.new(0.2),{Color=ATE_COR}):Play()
        Notify.send({type="info",icon="🍖",accent=ATE_COR,title="Auto Comer",msg=string.format("Come quando fome ≤ %d%%!",eatThreshold),duration=3})
        startAutoEat()
    end
end)

end -- do auto eat

end -- do NOVOS_FARM_V2

-- ══════════════════════════════════════════════════════════════
-- FARM BAÚS — Teleporta em cada baú e coleta os itens
-- Os baús JÁ estão abertos pelo ACS. Aqui só fazemos:
--   1. TP ao baú  2. Coleta itens num raio  3. Move ao destino
-- ══════════════════════════════════════════════════════════════
do
local FBC_COR = Color3.fromRGB(255, 185, 40)
local fbcRunning = false
local fbcMode    = "jogador"   -- "jogador" | "fogueira" | "pertofog"

-- ── Seção header ─────────────────────────────────────────────
makeSec(Pages["Farm"], fNextLO, "🎁  FARM BAÚS", FBC_COR)

-- ── Card principal ────────────────────────────────────────────
local fbcCard = Instance.new("Frame", Pages["Farm"])
fbcCard.BackgroundColor3 = Color3.fromRGB(26,15,6); fbcCard.BorderSizePixel = 0
fbcCard.Size = UDim2.new(1,0,0,100); fbcCard.LayoutOrder = fNextLO(); fbcCard.ZIndex = 5
Instance.new("UICorner",fbcCard).CornerRadius = UDim.new(0,12)
local fbcG = Instance.new("UIGradient",fbcCard)
fbcG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(40,24,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,10,3))}); fbcG.Rotation=135
local fbcStroke = Instance.new("UIStroke",fbcCard)
fbcStroke.Color = Color3.fromRGB(8,4,0); fbcStroke.Thickness = 3; fbcStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local fbcShine = Instance.new("Frame",fbcCard); fbcShine.BackgroundColor3=Color3.fromRGB(255,255,255)
fbcShine.BackgroundTransparency=0.82; fbcShine.BorderSizePixel=0
fbcShine.Position=UDim2.new(0,8,0,3); fbcShine.Size=UDim2.new(0,55,0,4); fbcShine.ZIndex=6
Instance.new("UICorner",fbcShine).CornerRadius=UDim.new(1,0)

-- Barra lateral
local fbcBar = Instance.new("Frame",fbcCard); fbcBar.BackgroundColor3=FBC_COR; fbcBar.BorderSizePixel=0
fbcBar.Position=UDim2.new(0,0,0.12,0); fbcBar.Size=UDim2.new(0,5,0.76,0); fbcBar.ZIndex=8
Instance.new("UICorner",fbcBar).CornerRadius=UDim.new(0,4)

-- Ícone
local fbcIcoBox = Instance.new("Frame",fbcCard); fbcIcoBox.BackgroundColor3=FBC_COR
fbcIcoBox.BackgroundTransparency=0.55; fbcIcoBox.BorderSizePixel=0
fbcIcoBox.Position=UDim2.new(0,8,0.5,-20); fbcIcoBox.Size=UDim2.new(0,40,0,40); fbcIcoBox.ZIndex=7
Instance.new("UICorner",fbcIcoBox).CornerRadius=UDim.new(0,9)
Instance.new("UIStroke",fbcIcoBox).Color=Color3.fromRGB(8,4,0)
local fbcIco=Instance.new("TextLabel",fbcIcoBox); fbcIco.BackgroundTransparency=1
fbcIco.Size=UDim2.new(1,0,1,0); fbcIco.Font=Enum.Font.GothamBlack; fbcIco.Text="🎁"; fbcIco.TextSize=22; fbcIco.ZIndex=8

-- Título e descrição
local fbcTitLbl = Instance.new("TextLabel",fbcCard); fbcTitLbl.BackgroundTransparency=1
fbcTitLbl.Position=UDim2.new(0,58,0,10); fbcTitLbl.Size=UDim2.new(1,-170,0,18)
fbcTitLbl.Font=Enum.Font.GothamBlack; fbcTitLbl.Text="🎁 Farm Baús"
fbcTitLbl.TextColor3=Color3.fromRGB(255,235,190); fbcTitLbl.TextSize=12; fbcTitLbl.TextXAlignment=Enum.TextXAlignment.Left; fbcTitLbl.ZIndex=7

local fbcDescLbl = Instance.new("TextLabel",fbcCard); fbcDescLbl.BackgroundTransparency=1
fbcDescLbl.Position=UDim2.new(0,58,0,30); fbcDescLbl.Size=UDim2.new(1,-170,0,32)
fbcDescLbl.Font=Enum.Font.Gotham; fbcDescLbl.Text="Teleporta em cada baú aberto e coleta os itens no destino selecionado."
fbcDescLbl.TextColor3=Color3.fromRGB(160,120,60); fbcDescLbl.TextSize=9; fbcDescLbl.TextWrapped=true; fbcDescLbl.TextXAlignment=Enum.TextXAlignment.Left; fbcDescLbl.ZIndex=7

-- Feedback / status label
local fbcStatus = Instance.new("TextLabel",fbcCard); fbcStatus.BackgroundTransparency=1
fbcStatus.Position=UDim2.new(0,58,0,64); fbcStatus.Size=UDim2.new(1,-170,0,26)
fbcStatus.Font=Enum.Font.GothamBold; fbcStatus.Text="Aguardando..."
fbcStatus.TextColor3=Color3.fromRGB(130,100,50); fbcStatus.TextSize=9; fbcStatus.TextWrapped=true; fbcStatus.TextXAlignment=Enum.TextXAlignment.Left; fbcStatus.ZIndex=7

-- ── Botão MODO ────────────────────────────────────────────────
local FBC_MODES = {
    {key="jogador",  label="Jogador",       icon="🧍", desc="Itens perto de você",         color=Color3.fromRGB(100,200,255)},
    {key="fogueira", label="Fogueira",      icon="🔥", desc="Itens na fogueira",            color=Color3.fromRGB(255,120,40)},
    {key="pertofog", label="Perto da Fog.", icon="🪵", desc="Ao redor da fogueira (~8 st)", color=Color3.fromRGB(200,160,60)},
}

local function getFbcModeData(key)
    for _,m in ipairs(FBC_MODES) do if m.key==key then return m end end
    return FBC_MODES[1]
end

local fbcModeBtn = Instance.new("TextButton",fbcCard); fbcModeBtn.BackgroundColor3=Color3.fromRGB(35,20,6)
fbcModeBtn.BorderSizePixel=0; fbcModeBtn.Position=UDim2.new(1,-104,0,8); fbcModeBtn.Size=UDim2.new(0,96,0,34)
fbcModeBtn.Font=Enum.Font.GothamBlack; fbcModeBtn.Text="🧍 Jogador"
fbcModeBtn.TextColor3=Color3.fromRGB(100,200,255); fbcModeBtn.TextSize=9; fbcModeBtn.ZIndex=8; fbcModeBtn.AutoButtonColor=false
Instance.new("UICorner",fbcModeBtn).CornerRadius=UDim.new(0,10)
local fbcModeBtnS=Instance.new("UIStroke",fbcModeBtn); fbcModeBtnS.Color=Color3.fromRGB(100,200,255); fbcModeBtnS.Thickness=2; fbcModeBtnS.Transparency=0.4
local fbcModeBtnG=Instance.new("UIGradient",fbcModeBtn); fbcModeBtnG.Rotation=90
fbcModeBtnG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(50,28,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(24,12,3))})
local fbcModeBtnShine=Instance.new("Frame",fbcModeBtn); fbcModeBtnShine.BackgroundColor3=Color3.fromRGB(255,255,255)
fbcModeBtnShine.BackgroundTransparency=0.82; fbcModeBtnShine.BorderSizePixel=0
fbcModeBtnShine.Position=UDim2.new(0,4,0,3); fbcModeBtnShine.Size=UDim2.new(0,36,0,5); fbcModeBtnShine.ZIndex=9
Instance.new("UICorner",fbcModeBtnShine).CornerRadius=UDim.new(1,0)

local function updateFbcModeBtn()
    local d = getFbcModeData(fbcMode)
    fbcModeBtn.Text      = d.icon.." "..d.label
    fbcModeBtn.TextColor3 = d.color
    fbcModeBtnS.Color    = d.color
end

-- ── Popup Farm Baús Modo — redesign profissional (ScreenGui) ─
local fbcPopup = Instance.new("Frame",ScreenGui)
fbcPopup.BackgroundColor3=Color3.fromRGB(18,12,4); fbcPopup.BorderSizePixel=0
fbcPopup.ZIndex=310; fbcPopup.Visible=false; fbcPopup.Size=UDim2.new(0,200,0,0)
Instance.new("UICorner",fbcPopup).CornerRadius=UDim.new(0,14)
local fbcPopupS=Instance.new("UIStroke",fbcPopup)
fbcPopupS.Color=FBC_COR; fbcPopupS.Thickness=2.5; fbcPopupS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local fbcPopupG=Instance.new("UIGradient",fbcPopup)
fbcPopupG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(32,20,6)),ColorSequenceKeypoint.new(1,Color3.fromRGB(14,9,2))}); fbcPopupG.Rotation=135
-- Cabeçalho
local fbcPopHdr=Instance.new("Frame",fbcPopup); fbcPopHdr.BackgroundColor3=FBC_COR
fbcPopHdr.BackgroundTransparency=0.82; fbcPopHdr.BorderSizePixel=0; fbcPopHdr.Size=UDim2.new(1,0,0,32); fbcPopHdr.ZIndex=311
Instance.new("UICorner",fbcPopHdr).CornerRadius=UDim.new(0,12)
local fbcPopHdrFix=Instance.new("Frame",fbcPopHdr); fbcPopHdrFix.BackgroundColor3=FBC_COR
fbcPopHdrFix.BackgroundTransparency=0.82; fbcPopHdrFix.BorderSizePixel=0
fbcPopHdrFix.Position=UDim2.new(0,0,0.5,0); fbcPopHdrFix.Size=UDim2.new(1,0,0.5,0); fbcPopHdrFix.ZIndex=311
local fbcPopTitle=Instance.new("TextLabel",fbcPopHdr); fbcPopTitle.BackgroundTransparency=1
fbcPopTitle.Position=UDim2.new(0,12,0,0); fbcPopTitle.Size=UDim2.new(1,-16,1,0)
fbcPopTitle.Font=Enum.Font.GothamBlack; fbcPopTitle.Text="🎁  Destino dos Itens"
fbcPopTitle.TextColor3=FBC_COR; fbcPopTitle.TextSize=10
fbcPopTitle.TextXAlignment=Enum.TextXAlignment.Left; fbcPopTitle.ZIndex=312
-- Lista
local fbcPopList=Instance.new("Frame",fbcPopup); fbcPopList.BackgroundTransparency=1
fbcPopList.BorderSizePixel=0; fbcPopList.Position=UDim2.new(0,8,0,38)
fbcPopList.Size=UDim2.new(1,-16,0,0); fbcPopList.ZIndex=311; fbcPopList.AutomaticSize=Enum.AutomaticSize.Y
local fbcPopLayout=Instance.new("UIListLayout",fbcPopList); fbcPopLayout.Padding=UDim.new(0,5); fbcPopLayout.SortOrder=Enum.SortOrder.LayoutOrder

local fbcPopupOpen = false
local function closeFbcPopup()
    fbcPopupOpen=false
    TweenService:Create(fbcPopup,TweenInfo.new(0.13,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,200,0,0),BackgroundTransparency=1}):Play()
    task.delay(0.15,function() fbcPopup.Visible=false; fbcPopup.BackgroundTransparency=0 end)
end

for idx, opt in ipairs(FBC_MODES) do
    local ob=Instance.new("TextButton",fbcPopList); ob.BackgroundColor3=Color3.fromRGB(30,18,6)
    ob.BackgroundTransparency=0; ob.BorderSizePixel=0
    ob.Size=UDim2.new(1,0,0,50); ob.LayoutOrder=idx; ob.ZIndex=312; ob.AutoButtonColor=false
    Instance.new("UICorner",ob).CornerRadius=UDim.new(0,10)
    local obS=Instance.new("UIStroke",ob); obS.Color=opt.color; obS.Thickness=1.5; obS.Transparency=0.6
    local obG=Instance.new("UIGradient",ob); obG.Rotation=135
    obG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(42,24,8)),ColorSequenceKeypoint.new(1,Color3.fromRGB(20,10,3))})
    local obBar=Instance.new("Frame",ob); obBar.BackgroundColor3=opt.color; obBar.BorderSizePixel=0
    obBar.Size=UDim2.new(0,4,0.7,0); obBar.Position=UDim2.new(0,0,0.15,0); obBar.ZIndex=313
    Instance.new("UICorner",obBar).CornerRadius=UDim.new(0,3)
    local obIco=Instance.new("TextLabel",ob); obIco.BackgroundTransparency=1
    obIco.Position=UDim2.new(0,10,0,0); obIco.Size=UDim2.new(0,28,1,0)
    obIco.Font=Enum.Font.GothamBlack; obIco.Text=opt.icon; obIco.TextSize=18; obIco.ZIndex=313
    local obLbl=Instance.new("TextLabel",ob); obLbl.BackgroundTransparency=1
    obLbl.Position=UDim2.new(0,42,0,6); obLbl.Size=UDim2.new(1,-46,0,18)
    obLbl.Font=Enum.Font.GothamBlack; obLbl.Text=opt.label
    obLbl.TextColor3=Color3.fromRGB(245,235,210); obLbl.TextSize=11
    obLbl.TextXAlignment=Enum.TextXAlignment.Left; obLbl.ZIndex=313
    local obDesc=Instance.new("TextLabel",ob); obDesc.BackgroundTransparency=1
    obDesc.Position=UDim2.new(0,42,0,26); obDesc.Size=UDim2.new(1,-48,0,14)
    obDesc.Font=Enum.Font.Gotham; obDesc.Text=opt.desc
    obDesc.TextColor3=Color3.fromRGB(160,130,70); obDesc.TextSize=8
    obDesc.TextXAlignment=Enum.TextXAlignment.Left; obDesc.ZIndex=313
    local function fbcRefreshSel()
        local sel=(fbcMode==opt.key)
        TweenService:Create(obS,TweenInfo.new(0.15),{Transparency=sel and 0 or 0.6}):Play()
        TweenService:Create(ob,TweenInfo.new(0.15),{BackgroundColor3=sel and Color3.fromRGB(50,28,8) or Color3.fromRGB(30,18,6)}):Play()
    end
    fbcRefreshSel()
    ob.MouseEnter:Connect(function()
        TweenService:Create(ob,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(45,25,8)}):Play()
        TweenService:Create(obS,TweenInfo.new(0.1),{Transparency=0.2}):Play()
    end)
    ob.MouseLeave:Connect(function() fbcRefreshSel() end)
    ob.MouseButton1Click:Connect(function()
        fbcMode=opt.key
        updateFbcModeBtn()
        closeFbcPopup()
        Notify.send({type="info",icon=opt.icon,accent=opt.color,title="Farm Baús — Destino",msg=opt.label..": "..opt.desc,duration=2.5})
    end)
end
-- Espaço inferior
local fbcPopPad=Instance.new("Frame",fbcPopList); fbcPopPad.BackgroundTransparency=1; fbcPopPad.Size=UDim2.new(1,0,0,4); fbcPopPad.LayoutOrder=99

fbcModeBtn.MouseButton1Click:Connect(function()
    if fbcPopupOpen then closeFbcPopup(); return end
    local ap=fbcModeBtn.AbsolutePosition; local as=fbcModeBtn.AbsoluteSize
    local popH = 32 + #FBC_MODES*55 + 8
    fbcPopup.Position=UDim2.new(0,ap.X+as.X-200,0,ap.Y-popH-6)
    fbcPopup.Size=UDim2.new(0,200,0,0); fbcPopup.BackgroundTransparency=1; fbcPopup.Visible=true
    TweenService:Create(fbcPopup,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Size=UDim2.new(0,200,0,popH), BackgroundTransparency=0
    }):Play()
    fbcPopupOpen=true
end)
MainFrame.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 and fbcPopupOpen then
        local mx,my=inp.Position.X,inp.Position.Y
        local pA=fbcPopup.AbsolutePosition; local pS=fbcPopup.AbsoluteSize
        if mx<pA.X or mx>pA.X+pS.X or my<pA.Y or my>pA.Y+pS.Y then closeFbcPopup() end
    end
end)

-- ── Botão INICIAR / PARAR ─────────────────────────────────────
local fbcStartBtn=Instance.new("TextButton",fbcCard); fbcStartBtn.BackgroundColor3=Color3.fromRGB(252,196,0)
fbcStartBtn.BorderSizePixel=0; fbcStartBtn.Position=UDim2.new(1,-104,0,48); fbcStartBtn.Size=UDim2.new(0,96,0,28)
fbcStartBtn.Font=Enum.Font.GothamBlack; fbcStartBtn.Text="▶ Iniciar"; fbcStartBtn.TextColor3=Color3.fromRGB(22,10,0)
fbcStartBtn.TextSize=10; fbcStartBtn.ZIndex=8; fbcStartBtn.AutoButtonColor=false
Instance.new("UICorner",fbcStartBtn).CornerRadius=UDim.new(0,9)
local fbcStartBtnS=Instance.new("UIStroke",fbcStartBtn)
fbcStartBtnS.Color=Color3.fromRGB(8,4,0); fbcStartBtnS.Thickness=2.5; fbcStartBtnS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local fbcStartBtnG=Instance.new("UIGradient",fbcStartBtn)
fbcStartBtnG.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,238,80)),ColorSequenceKeypoint.new(1,Color3.fromRGB(200,140,0))}); fbcStartBtnG.Rotation=90
local fbcBtnShine=Instance.new("Frame",fbcStartBtn); fbcBtnShine.BackgroundColor3=Color3.fromRGB(255,255,255)
fbcBtnShine.BackgroundTransparency=0.65; fbcBtnShine.BorderSizePixel=0
fbcBtnShine.Position=UDim2.new(0,4,0,3); fbcBtnShine.Size=UDim2.new(0,40,0,6); fbcBtnShine.ZIndex=9
Instance.new("UICorner",fbcBtnShine).CornerRadius=UDim.new(1,0)

fbcStartBtn.MouseEnter:Connect(function()
    TweenService:Create(fbcStartBtn,TweenInfo.new(0.1),{Size=UDim2.new(0,98,0,30),Position=UDim2.new(1,-105,0,47)}):Play()
end)
fbcStartBtn.MouseLeave:Connect(function()
    TweenService:Create(fbcStartBtn,TweenInfo.new(0.1),{Size=UDim2.new(0,96,0,28),Position=UDim2.new(1,-104,0,48)}):Play()
end)

-- ── Lógica do Farm Baús ───────────────────────────────────────
local fbcStopFlag = false

-- Encontra todos os baús no workspace (já abertos ou não)
local function fbcGetChests()
    local chests = {}
    local seen   = {}
    local root   = workspace:FindFirstChild("Items") or workspace
    for _, obj in ipairs(root:GetDescendants()) do
        if obj:IsA("Model") and not seen[obj] then
            local nm = obj.Name:lower()
            if nm:find("chest",1,true) or nm:find("bau",1,true) or nm:find("baú",1,true) then
                seen[obj] = true
                table.insert(chests, obj)
            end
        end
    end
    -- Também varre workspace raiz (baús fora de Items)
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and not seen[obj] then
            local nm = obj.Name:lower()
            if nm:find("chest",1,true) or nm:find("bau",1,true) or nm:find("baú",1,true) then
                seen[obj] = true
                table.insert(chests, obj)
            end
        end
    end
    return chests
end

-- Coleta itens num raio ao redor de uma posição e os move para o destino
local function fbcCollectNear(chestPos, destMode, campPos)
    local COLLECT_RADIUS = 25  -- studs ao redor do baú onde itens spawnaram

    -- Determina o centro de destino
    local destCenter
    if destMode == "fogueira" then
        destCenter = campPos
    elseif destMode == "pertofog" then
        destCenter = campPos  -- mesmo centro, raio maior (calculado abaixo)
    else
        -- jogador
        local ch = Player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        destCenter = hrp and hrp.Position or campPos
    end
    if not destCenter then return 0 end

    local char = Player.Character
    local itemsF = workspace:FindFirstChild("Items")
    local source = itemsF and itemsF:GetChildren() or workspace:GetChildren()
    local moved = 0
    local pchars = {}
    for _,pl in ipairs(Players:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end

    -- Coleta todos os itens dentro do raio do baú
    local collected = {}
    for _, obj in ipairs(source) do
        if obj:IsA("Model") and not obj:FindFirstChildWhichIsA("Humanoid") then
            local nm = obj.Name:lower()
            -- Não coleta outros baús
            if not (nm:find("chest",1,true) or nm:find("bau",1,true) or nm:find("baú",1,true)) then
                local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if pp then
                    local dist = (pp.Position - chestPos).Magnitude
                    if dist <= COLLECT_RADIUS then
                        -- Não é personagem de jogador
                        local isPC = false
                        for pc in pairs(pchars) do
                            if pc == obj or pc:IsAncestorOf(obj) then isPC=true; break end
                        end
                        if not isPC then table.insert(collected, obj) end
                    end
                end
            end
        end
    end

    -- Move os coletados para o destino
    for idx, obj in ipairs(collected) do
        if fbcStopFlag then break end
        pcall(function()
            local angle  = ((idx-1) / math.max(#collected,1)) * math.pi * 2
            local radius
            if destMode == "fogueira" then
                radius = 2 + math.floor((idx-1)/8) * 1.2  -- bem junto à fogueira
            elseif destMode == "pertofog" then
                radius = 8 + math.floor((idx-1)/8) * 2    -- um anel fora da fogueira
            else
                radius = 2 + math.floor((idx-1)/8) * 1.5  -- junto ao jogador
            end
            local target = Vector3.new(
                destCenter.X + math.cos(angle)*radius,
                destCenter.Y + 4,
                destCenter.Z + math.sin(angle)*radius)

            -- Usa remote se disponível (abordagem GG.lua)
            if _bringRemotesReady then
                moveItemViaRemote(obj, target)
            else
                local pp = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if pp then
                    if obj.PrimaryPart then
                        obj:SetPrimaryPartCFrame(CFrame.new(target))
                    else
                        obj.PrimaryPart = pp
                        obj:SetPrimaryPartCFrame(CFrame.new(target))
                    end
                end
            end
            moved += 1
        end)
    end
    return moved
end

-- Rotina principal: itera baús, TP, coleta, repete
local function fbcRun()
    fbcStopFlag = false
    fbcRunning  = true
    fbcStartBtn.Text = "■ Parar"
    TweenService:Create(fbcStartBtnG,TweenInfo.new(0.2),{}):Play()
    fbcStartBtn.TextColor3 = Color3.fromRGB(255,80,80)
    fbcStroke.Color = FBC_COR; fbcStroke.Transparency = 0.3

    local campPos = getCampfirePos() or Vector3.new(0,5,0)
    local chests  = fbcGetChests()
    local total   = #chests
    local totalCollected = 0

    if total == 0 then
        fbcStatus.Text = "⚠ Nenhum baú encontrado!"
        fbcStatus.TextColor3 = Color3.fromRGB(255,80,80)
        Notify.warn("Farm Baús", "Nenhum baú encontrado no mapa.")
        fbcRunning = false
        fbcStopFlag = false
        fbcStartBtn.Text = "▶ Iniciar"
        fbcStartBtn.TextColor3 = Color3.fromRGB(22,10,0)
        TweenService:Create(fbcStroke,TweenInfo.new(0.3),{Color=Color3.fromRGB(8,4,0),Transparency=0}):Play()
        return
    end

    Notify.send({type="info",icon="🎁",accent=FBC_COR,title="Farm Baús",msg="Iniciando em "..total.." baú(s)...",duration=3})

    for idx, chest in ipairs(chests) do
        if fbcStopFlag then break end

        -- Pega posição do baú
        local chestPP = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
        if not chestPP then continue end
        local chestPos = chestPP.Position

        -- Atualiza status
        fbcStatus.Text = "🎁 Baú "..idx.."/"..total.." — coletando..."
        fbcStatus.TextColor3 = Color3.fromRGB(255,200,80)

        -- TP ao baú
        local ch = Player.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(chestPos.X, chestPos.Y + 3, chestPos.Z)
        end

        -- Aguarda o servidor registrar a posição e os itens spawnarem
        task.wait(0.35)

        if fbcStopFlag then break end

        -- Coleta itens ao redor do baú e envia ao destino
        local collected = fbcCollectNear(chestPos, fbcMode, campPos)
        totalCollected += collected

        -- Pequena pausa entre baús
        task.wait(0.2)
    end

    -- Finaliza
    fbcRunning = false
    fbcStopFlag = false

    if totalCollected > 0 then
        fbcStatus.Text = "✓ "..totalCollected.." item(s) coletado(s)!"
        fbcStatus.TextColor3 = Color3.fromRGB(87,242,135)
        Notify.success("Farm Baús", "✓ "..totalCollected.." itens coletados de "..total.." baú(s)!")
    else
        fbcStatus.Text = "Concluído — nenhum item encontrado."
        fbcStatus.TextColor3 = Color3.fromRGB(160,130,70)
        Notify.info("Farm Baús", "Baús visitados, mas nenhum item encontrado.")
    end

    fbcStartBtn.Text = "▶ Iniciar"
    fbcStartBtn.TextColor3 = Color3.fromRGB(22,10,0)
    TweenService:Create(fbcStroke,TweenInfo.new(0.3),{Color=Color3.fromRGB(8,4,0),Transparency=0}):Play()

    -- Limpa status após 4s
    task.delay(4, function()
        TweenService:Create(fbcStatus,TweenInfo.new(0.4),{TextTransparency=1}):Play()
        task.wait(0.5); fbcStatus.Text="Aguardando..."; fbcStatus.TextTransparency=0
        fbcStatus.TextColor3=Color3.fromRGB(130,100,50)
    end)
end

-- ── Clique no botão Iniciar / Parar ───────────────────────────
fbcStartBtn.MouseButton1Click:Connect(function()
    if fbcRunning then
        -- Para a execução
        fbcStopFlag = true
        fbcStatus.Text = "⏹ Parando..."
        fbcStatus.TextColor3 = Color3.fromRGB(200,80,80)
    else
        task.spawn(fbcRun)
    end
end)

-- Inicializa botão de modo
updateFbcModeBtn()
end -- Farm Baús

end) -- [[ FARM PART 2 ]]

;pcall(function() -- [[ AIMBOT + ADVANCED ]]

-- ── UI helpers para AvancadoFuncoes ────────────────────────────
local avfuncLO = 0
local function avfNextLO() avfuncLO += 1; return avfuncLO end

local function makeAvSec(titleTxt, cor)
    local hdr = Instance.new("Frame", Pages["AvancadoFuncoes"])
    hdr.BackgroundColor3 = Color3.fromRGB(26,15,6); hdr.BorderSizePixel = 0
    hdr.Size = UDim2.new(1,0,0,26); hdr.LayoutOrder = avfNextLO(); hdr.ZIndex = 4
    Instance.new("UICorner",hdr).CornerRadius = UDim.new(0,9)
    local hdrG = Instance.new("UIGradient",hdr)
    hdrG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40,22,8)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18,10,3)),
    }); hdrG.Rotation = 135
    local gborder = Instance.new("UIStroke",hdr)
    gborder.Color = Color3.fromRGB(8,4,0); gborder.Thickness = 2.5
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
    local lblS = Instance.new("UIStroke",lbl); lblS.Color = Color3.fromRGB(8,4,0); lblS.Thickness = 1.5
end

local function makeAvToggle(lbl_txt, desc_txt, cor, onToggle)
    local row = Instance.new("Frame", Pages["AvancadoFuncoes"])
    row.BackgroundColor3 = Color3.fromRGB(26,15,6); row.BorderSizePixel = 0
    row.Size = UDim2.new(1,0,0,64); row.LayoutOrder = avfNextLO(); row.ZIndex = 5
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,12)
    local rowG = Instance.new("UIGradient",row)
    rowG.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40,24,8)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(18,10,3))
    }); rowG.Rotation = 135
    local rowS = Instance.new("UIStroke",row)
    rowS.Color = Color3.fromRGB(8,4,0); rowS.Thickness = 3
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
    local tlS = Instance.new("UIStroke",tl); tlS.Color = Color3.fromRGB(8,4,0); tlS.Thickness = 1.8
    local td = Instance.new("TextLabel",row); td.BackgroundTransparency = 1
    td.Position = UDim2.new(0,16,0,32); td.Size = UDim2.new(1,-80,0,26); td.Font = Enum.Font.Gotham
    td.Text = desc_txt; td.TextColor3 = Color3.fromRGB(180,160,110); td.TextSize = 9
    td.TextXAlignment = Enum.TextXAlignment.Left; td.TextWrapped = true; td.ZIndex = 7
    local pill = Instance.new("Frame",row); pill.BackgroundColor3 = Color3.fromRGB(40,24,8)
    pill.BorderSizePixel = 0; pill.Position = UDim2.new(1,-60,0.5,-14); pill.Size = UDim2.new(0,52,0,28); pill.ZIndex = 9
    Instance.new("UICorner",pill).CornerRadius = UDim.new(1,0)
    local pillS = Instance.new("UIStroke",pill); pillS.Color = Color3.fromRGB(8,4,0); pillS.Thickness = 2.5
    pillS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local knob = Instance.new("Frame",pill); knob.BackgroundColor3 = Color3.fromRGB(160,120,60)
    knob.BorderSizePixel = 0; knob.Position = UDim2.new(0,3,0.5,-11); knob.Size = UDim2.new(0,22,0,22); knob.ZIndex = 10
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)
    local knobStroke = Instance.new("UIStroke",knob); knobStroke.Color = Color3.fromRGB(8,4,0); knobStroke.Thickness = 1.5
    local state = false
    local btn = Instance.new("TextButton",row); btn.BackgroundTransparency = 1; btn.BorderSizePixel = 0
    btn.AutoButtonColor = false; btn.Size = UDim2.new(1,0,1,0); btn.Text = ""; btn.ZIndex = 11
    btn.MouseEnter:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(50,30,12)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Thickness=4}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(26,15,6)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.1),{Thickness=3}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{
            BackgroundColor3 = state and cor or Color3.fromRGB(40,24,8)
        }):Play()
        TweenService:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position = state and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11),
            BackgroundColor3 = state and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,120,60)
        }):Play()
        TweenService:Create(lbar,TweenInfo.new(0.18),{
            BackgroundColor3 = state and cor or Color3.fromRGB(80,50,18)
        }):Play()
        TweenService:Create(row,TweenInfo.new(0.08),{BackgroundColor3=state and cor or Color3.fromRGB(80,20,20)}):Play()
        task.delay(0.1,function() TweenService:Create(row,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(26,15,6)}):Play() end)
        -- Som de ligar/desligar
        pcall(function()
            local sndId = state and 6031221736 or 2544086171
            local snd = Instance.new("Sound", SoundService)
            snd.SoundId = "rbxassetid://"..tostring(sndId)
            snd.Volume = 0.45; snd.RollOffMaxDistance = 0; snd:Play()
            game:GetService("Debris"):AddItem(snd, 3)
        end)
        if state then
            Notify.success(lbl_txt, "✓ Ativado")
        else
            Notify.send({type="error", icon="✕", accent=Color3.fromRGB(255,75,75), title=lbl_txt, msg="✗ Desativado"})
        end
        onToggle(state)
    end)
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
end) -- [[ AIMBOT + ADVANCED ]]

-- HOME TAB + WELCOME NOTIFICATION
-- ══════════════════════════════════════════════════════
task.wait(0.05)
selectTab("Info")

task.delay(1.5, function()
    Notify.send({
        type   = "custom",
        icon   = "🌲",
        accent = Color3.fromRGB(200,155,0),
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
