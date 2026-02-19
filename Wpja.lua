-- ╔══════════════════════════════════════════════════════════════════╗
-- ║       PUDIM HUB — MERGED v4 + V3                                ║
-- ║   UI Completa V3 + ESP/BRING do v4 (99 Nights 2026)            ║
-- ║   ESP: 20 categorias | BRING: 16 individuais                    ║
-- ╚══════════════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Mouse  = Player:GetMouse()
local Cam    = workspace.CurrentCamera

-- ══════════════════════════════
--  SCREEN GUI (V3)
-- ══════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "PudimHubMerged"
ScreenGui.Parent          = game.CoreGui
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn    = false
ScreenGui.DisplayOrder    = 999

-- ══════════════════════════════
--  MAIN FRAME
-- ══════════════════════════════
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
MainStroke.Color     = Color3.fromRGB(55, 58, 66)
MainStroke.Thickness = 1.5

-- ══════════════════════════════
--  TOP BAR
-- ══════════════════════════════
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name             = "TopBar"
TopBar.BackgroundColor3 = Color3.fromRGB(24, 25, 28)
TopBar.Size             = UDim2.new(1, 0, 0, 40)
TopBar.BorderSizePixel  = 0
TopBar.ZIndex           = 3
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local TitleBox = Instance.new("Frame", TopBar)
TitleBox.BackgroundTransparency = 1
TitleBox.Position = UDim2.new(0, 12, 0, 0)
TitleBox.Size     = UDim2.new(0, 220, 1, 0)
TitleBox.ZIndex   = 4

local TitleIcon = Instance.new("ImageLabel", TitleBox)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Position = UDim2.new(0, 0, 0.5, -12)
TitleIcon.Size     = UDim2.new(0, 24, 0, 24)
TitleIcon.Image    = "rbxassetid://12766380903"
TitleIcon.ZIndex   = 5

local TitleLabel = Instance.new("TextLabel", TitleBox)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position       = UDim2.new(0, 30, 0, 0)
TitleLabel.Size           = UDim2.new(1, -30, 1, 0)
TitleLabel.Font           = Enum.Font.GothamBlack
TitleLabel.Text           = "PudimHub v4 Merged"
TitleLabel.TextColor3     = Color3.fromRGB(88, 101, 242)
TitleLabel.TextSize       = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex         = 5

-- ── TOP BAR BUTTONS ──────────────────────────────────────────────
local btnData = {
    { name="Theme",    icon="rbxassetid://7734053495", tip="Boost/Configurações" },
    { name="Minimize", icon="rbxassetid://7733956134", tip="Minimizar"           },
    { name="Maximize", icon="rbxassetid://7733919682", tip="Maximizar"           },
    { name="Close",    icon="rbxassetid://7734053426", tip="Fechar"              },
}

local TopBtns = {}
local btnX = -10
for i, d in ipairs(btnData) do
    local btn = Instance.new("ImageButton", TopBar)
    btn.Name                   = d.name
    btn.BackgroundTransparency = 1
    btn.Position               = UDim2.new(1, btnX - 20, 0.5, -9)
    btn.Size                   = UDim2.new(0, 18, 0, 18)
    btn.Image                  = d.icon
    btn.ImageColor3            = Color3.fromRGB(160, 165, 175)
    btn.ZIndex                 = 5
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(255,255,255)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(160,165,175)}):Play()
    end)
    TopBtns[d.name] = btn
    btnX = btnX - 30
end

-- ══════════════════════════════
--  SIDEBAR
-- ══════════════════════════════
local SideBar = Instance.new("ScrollingFrame", MainFrame)
SideBar.Name                = "SideBar"
SideBar.BackgroundColor3    = Color3.fromRGB(24, 25, 28)
SideBar.Position            = UDim2.new(0, 0, 0, 40)
SideBar.Size                = UDim2.new(0, 175, 1, -78)
SideBar.BorderSizePixel     = 0
SideBar.ScrollBarThickness  = 0
SideBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
SideBar.CanvasSize          = UDim2.new(0, 0, 0, 0)
SideBar.ZIndex              = 3

local SideList = Instance.new("UIListLayout", SideBar)
SideList.Padding             = UDim.new(0, 2)
SideList.SortOrder           = Enum.SortOrder.LayoutOrder
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidePad = Instance.new("UIPadding", SideBar)
SidePad.PaddingTop    = UDim.new(0, 8)
SidePad.PaddingLeft   = UDim.new(0, 8)
SidePad.PaddingRight  = UDim.new(0, 8)
SidePad.PaddingBottom = UDim.new(0, 8)

local Divider = Instance.new("Frame", MainFrame)
Divider.BackgroundColor3 = Color3.fromRGB(14, 15, 17)
Divider.BorderSizePixel  = 0
Divider.Position         = UDim2.new(0, 175, 0, 40)
Divider.Size             = UDim2.new(0, 1, 1, -40)
Divider.ZIndex           = 3

-- ══════════════════════════════
--  CONTENT AREA
-- ══════════════════════════════
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Name             = "ContentArea"
ContentArea.BackgroundColor3 = Color3.fromRGB(36, 38, 42)
ContentArea.Position         = UDim2.new(0, 176, 0, 40)
ContentArea.Size             = UDim2.new(1, -176, 1, -40)
ContentArea.BorderSizePixel  = 0
ContentArea.ZIndex           = 3
ContentArea.ClipsDescendants = true

-- ══════════════════════════════
--  FOOTER
-- ══════════════════════════════
local Footer = Instance.new("Frame", MainFrame)
Footer.BackgroundColor3 = Color3.fromRGB(18, 19, 22)
Footer.BorderSizePixel  = 0
Footer.Position         = UDim2.new(0, 0, 1, -38)
Footer.Size             = UDim2.new(0, 175, 0, 38)
Footer.ZIndex           = 4
Instance.new("UICorner", Footer).CornerRadius = UDim.new(0, 12)

local AvatarBg = Instance.new("Frame", Footer)
AvatarBg.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
AvatarBg.Position         = UDim2.new(0, 8, 0.5, -12)
AvatarBg.Size             = UDim2.new(0, 24, 0, 24)
AvatarBg.ZIndex           = 5
Instance.new("UICorner", AvatarBg).CornerRadius = UDim.new(1, 0)

local AvatarImg = Instance.new("ImageLabel", AvatarBg)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Size   = UDim2.new(1, 0, 1, 0)
AvatarImg.Image  = "https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(Player.UserId).."&width=48&height=48&format=png"
AvatarImg.ZIndex = 6
Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

local OnlineDot = Instance.new("Frame", Footer)
OnlineDot.BackgroundColor3 = Color3.fromRGB(87, 242, 135)
OnlineDot.BorderSizePixel  = 0
OnlineDot.Position         = UDim2.new(0, 24, 0.5, 3)
OnlineDot.Size             = UDim2.new(0, 8, 0, 8)
OnlineDot.ZIndex           = 6
Instance.new("UICorner", OnlineDot).CornerRadius = UDim.new(1, 0)

local FName = Instance.new("TextLabel", Footer)
FName.BackgroundTransparency = 1
FName.Position       = UDim2.new(0, 40, 0, 4)
FName.Size           = UDim2.new(1, -48, 0, 14)
FName.Font           = Enum.Font.GothamBold
FName.Text           = Player.DisplayName
FName.TextColor3     = Color3.fromRGB(225, 228, 232)
FName.TextSize       = 10
FName.TextXAlignment = Enum.TextXAlignment.Left
FName.TextTruncate   = Enum.TextTruncate.AtEnd
FName.ZIndex         = 5

local FTag = Instance.new("TextLabel", Footer)
FTag.BackgroundTransparency = 1
FTag.Position        = UDim2.new(0, 40, 0, 19)
FTag.Size            = UDim2.new(1, -48, 0, 12)
FTag.Font            = Enum.Font.Gotham
FTag.Text            = "@"..Player.Name
FTag.TextColor3      = Color3.fromRGB(80, 90, 110)
FTag.TextSize        = 9
FTag.TextXAlignment  = Enum.TextXAlignment.Left
FTag.TextTruncate    = Enum.TextTruncate.AtEnd
FTag.ZIndex          = 5

-- ══════════════════════════════
--  PAGES (abas de conteúdo)
-- ══════════════════════════════
local Pages  = {}
local C_ACCENT   = Color3.fromRGB(88, 101, 242)
local C_ICON_OFF = Color3.fromRGB(95, 105, 125)
local C_ICON_ON  = Color3.fromRGB(255, 255, 255)
local C_TEXT_OFF = Color3.fromRGB(130, 140, 158)
local C_TEXT_ON  = Color3.fromRGB(240, 242, 255)
local C_BG_HOV   = Color3.fromRGB(40, 43, 52)
local C_BG_ACT   = Color3.fromRGB(48, 52, 72)

local TabConfig = {
    { key="Info",            label="Info"             },
    { key="Status",          label="Status"           },
    { key="Farm",            label="Farm"             },
    { key="Esp",             label="ESP"              },
    { key="Bring",           label="Bring"            },
    { key="AvancadoFarm",    label="Avançado Farm"    },
    { key="Player",          label="Player"           },
    { key="Configuracoes",   label="Configurações"    },
    { key="AvancadoFuncoes", label="Avançado Funções" },
}

local GroupConfig = {
    { label="GERAL",   keys={"Info","Status"}                              },
    { label="COMBATE", keys={"Farm","Esp","Bring","AvancadoFarm"}          },
    { label="EXTRA",   keys={"Player","Configuracoes","AvancadoFuncoes"}   },
}

for _, t in ipairs(TabConfig) do
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Name                = t.key.."Page"
    page.Size                = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible             = false
    page.ScrollBarThickness  = 3
    page.ScrollBarImageColor3= C_ACCENT
    page.BorderSizePixel     = 0
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize          = UDim2.new(0, 0, 0, 0)
    page.ZIndex              = 4

    local pagePad = Instance.new("UIPadding", page)
    pagePad.PaddingTop    = UDim.new(0, 14)
    pagePad.PaddingLeft   = UDim.new(0, 14)
    pagePad.PaddingRight  = UDim.new(0, 14)
    pagePad.PaddingBottom = UDim.new(0, 14)

    local pageList = Instance.new("UIListLayout", page)
    pageList.Padding   = UDim.new(0, 8)
    pageList.SortOrder = Enum.SortOrder.LayoutOrder

    Pages[t.key] = page
end

-- ══════════════════════════════
--  ÍCONES DA SIDEBAR
-- ══════════════════════════════
local C_ICON_IDLE   = Color3.fromRGB(90, 100, 120)
local C_ICON_ACTIVE = Color3.fromRGB(180, 190, 255)

local function mkRect(parent, x, y, w, h, color, radius)
    local f = Instance.new("Frame", parent)
    f.BackgroundColor3 = color or C_ICON_IDLE
    f.BorderSizePixel  = 0
    f.Position         = UDim2.new(0, x, 0, y)
    f.Size             = UDim2.new(0, w, 0, h)
    f.ZIndex           = parent.ZIndex + 1
    if radius then Instance.new("UICorner", f).CornerRadius = UDim.new(0, radius) end
    return f
end
local function mkCircle(parent, x, y, r, color)
    return mkRect(parent, x-r, y-r, r*2, r*2, color, r*2)
end

local function createTabIcon(parent, key)
    local ic = C_ICON_IDLE
    local cont = Instance.new("Frame", parent)
    cont.BackgroundTransparency = 1; cont.BorderSizePixel = 0
    cont.Position = UDim2.new(0, 8, 0.5, -10); cont.Size = UDim2.new(0, 20, 0, 20)
    cont.ZIndex = parent.ZIndex + 2; cont.ClipsDescendants = false

    local parts = {}
    local function p(f) table.insert(parts, f) return f end

    if key == "Info" then
        p(mkCircle(cont, 10, 10, 9, ic))
        local inner = mkCircle(cont, 10, 10, 7, Color3.fromRGB(24,26,32)); inner.ZIndex = cont.ZIndex + 1
        p(mkCircle(cont, 10, 4, 2, ic)); p(mkRect(cont, 8, 8, 4, 8, ic, 2))
    elseif key == "Status" then
        p(mkRect(cont, 0, 12, 4, 8, ic, 1)); p(mkRect(cont, 8, 6, 4, 14, ic, 1)); p(mkRect(cont, 16, 9, 4, 11, ic, 1))
    elseif key == "Farm" then
        p(mkRect(cont, 11, 0, 5, 2, ic, 1)); p(mkRect(cont, 6, 2, 8, 2, ic, 0)); p(mkRect(cont, 4, 4, 10, 2, ic, 0))
        p(mkRect(cont, 8, 6, 8, 2, ic, 0)); p(mkRect(cont, 6, 8, 8, 2, ic, 0)); p(mkRect(cont, 4, 10, 8, 2, ic, 0))
        p(mkRect(cont, 2, 12, 10, 2, ic, 0)); p(mkRect(cont, 4, 14, 6, 2, ic, 0)); p(mkRect(cont, 3, 18, 5, 2, ic, 1))
    elseif key == "Esp" then
        p(mkRect(cont, 2, 6, 16, 8, ic, 8))
        local eyeInner = mkRect(cont, 3, 7, 14, 6, Color3.fromRGB(24,26,32), 7); eyeInner.ZIndex = cont.ZIndex + 1
        p(mkCircle(cont, 10, 10, 4, ic))
        local pupilInner = mkCircle(cont, 10, 10, 2, Color3.fromRGB(24,26,32)); pupilInner.ZIndex = cont.ZIndex + 3
        p(mkCircle(cont, 12, 8, 1, Color3.fromRGB(200,220,255)))
    elseif key == "Bring" then
        p(mkRect(cont, 2, 2, 5, 12, ic, 2)); p(mkRect(cont, 13, 2, 5, 12, ic, 2)); p(mkRect(cont, 2, 2, 16, 5, ic, 2))
        p(mkRect(cont, 2, 14, 5, 4, Color3.fromRGB(220,60,60), 2)); p(mkRect(cont, 13, 14, 5, 4, Color3.fromRGB(60,120,220), 2))
    elseif key == "AvancadoFarm" then
        p(mkRect(cont, 9, 14, 2, 6, ic, 1)); p(mkRect(cont, 9, 2, 2, 12, ic, 1))
        p(mkRect(cont, 3, 4, 6, 3, ic, 2)); p(mkRect(cont, 11, 4, 6, 3, ic, 2))
        p(mkRect(cont, 3, 8, 6, 3, ic, 2)); p(mkRect(cont, 11, 8, 6, 3, ic, 2))
        p(mkRect(cont, 6, 0, 8, 3, ic, 2))
    elseif key == "Player" then
        p(mkCircle(cont, 10, 5, 4, ic)); p(mkRect(cont, 5, 11, 10, 7, ic, 3))
        p(mkRect(cont, 3, 13, 4, 7, ic, 2)); p(mkRect(cont, 13, 13, 4, 7, ic, 2))
    elseif key == "Configuracoes" then
        p(mkCircle(cont, 10, 10, 5, ic))
        local cInner = mkCircle(cont, 10, 10, 3, Color3.fromRGB(24,26,32)); cInner.ZIndex = cont.ZIndex + 2
        local angles = {0,45,90,135,180,225,270,315}
        for _, deg in ipairs(angles) do
            local rad = math.rad(deg)
            p(mkRect(cont, 10 + math.cos(rad)*8 - 2, 10 + math.sin(rad)*8 - 2, 4, 4, ic, 1))
        end
    elseif key == "AvancadoFuncoes" then
        p(mkRect(cont, 1, 13, 12, 4, ic, 2)); p(mkCircle(cont, 15, 6, 5, ic))
        local furo = mkCircle(cont, 15, 6, 3, Color3.fromRGB(24,26,32)); furo.ZIndex = cont.ZIndex + 2
        p(mkRect(cont, 8, 9, 6, 3, ic, 1))
    end
    return cont, parts
end

local function setIconColor(parts, color)
    for _, part in ipairs(parts) do
        if part and part.Parent then part.BackgroundColor3 = color end
    end
end

-- ══════════════════════════════
--  SISTEMA DE ABAS
-- ══════════════════════════════
local allTabs    = {}
local currentTab = nil

local function selectTab(key)
    if currentTab == key then return end
    currentTab = key
    for _, e in ipairs(allTabs) do
        local isThis = (e.key == key)
        TweenService:Create(e.bg, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
            BackgroundTransparency = isThis and 0.72 or 1,
            BackgroundColor3       = isThis and C_BG_ACT or C_BG_HOV,
        }):Play()
        setIconColor(e.iconParts, isThis and C_ICON_ACTIVE or C_ICON_IDLE)
        TweenService:Create(e.label, TweenInfo.new(0.18), { TextColor3 = isThis and C_TEXT_ON or C_TEXT_OFF }):Play()
        e.bar.Visible = isThis
        if Pages[e.key] then Pages[e.key].Visible = isThis end
    end
end

-- ── Grupos colapsáveis ──────────────────────────────────
local layoutOrder = 0

local function makeGroupLabel(text, groupTabs)
    layoutOrder += 1
    if layoutOrder > 1 then
        local line = Instance.new("Frame", SideBar)
        line.BackgroundColor3 = Color3.fromRGB(38, 41, 48)
        line.BorderSizePixel  = 0
        line.Size             = UDim2.new(1, 0, 0, 1)
        line.LayoutOrder      = layoutOrder * 100
    end
    layoutOrder += 1
    local header = Instance.new("TextButton", SideBar)
    header.BackgroundTransparency = 1
    header.Size        = UDim2.new(1, 0, 0, 24)
    header.Text        = ""
    header.LayoutOrder = layoutOrder * 100
    header.ZIndex      = 4
    local headerLbl = Instance.new("TextLabel", header)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Position = UDim2.new(0, 4, 0, 0); headerLbl.Size = UDim2.new(1, -24, 1, 0)
    headerLbl.Font = Enum.Font.GothamBlack; headerLbl.Text = text
    headerLbl.TextColor3 = Color3.fromRGB(88, 101, 242); headerLbl.TextSize = 8
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left; headerLbl.ZIndex = 5
    local arrowFrame = Instance.new("Frame", header)
    arrowFrame.BackgroundTransparency = 1
    arrowFrame.Position = UDim2.new(1, -20, 0.5, -8); arrowFrame.Size = UDim2.new(0, 16, 0, 16); arrowFrame.ZIndex = 5
    local arrow = Instance.new("ImageLabel", arrowFrame)
    arrow.BackgroundTransparency = 1; arrow.Size = UDim2.new(1, 0, 1, 0)
    arrow.Image = "rbxassetid://6034818375"; arrow.ImageColor3 = Color3.fromRGB(88, 101, 242)
    arrow.ScaleType = Enum.ScaleType.Fit; arrow.Rotation = 0; arrow.ZIndex = 6
    local isOpen = true
    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        TweenService:Create(arrow, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Rotation = isOpen and 0 or 180}):Play()
        for _, entry in ipairs(groupTabs) do
            local targetSize = isOpen and UDim2.new(1, 0, 0, 36) or UDim2.new(1, 0, 0, 0)
            TweenService:Create(entry.bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = targetSize}):Play()
            entry.bg.ClipsDescendants = true
        end
    end)
end

local function makeTab(cfg, groupTabs)
    layoutOrder += 1
    local order = layoutOrder * 100
    local bg = Instance.new("Frame", SideBar)
    bg.Name = cfg.key.."Tab"; bg.BackgroundColor3 = C_BG_HOV; bg.BackgroundTransparency = 1
    bg.BorderSizePixel = 0; bg.Size = UDim2.new(1, 0, 0, 36)
    bg.LayoutOrder = order; bg.ZIndex = 4; bg.ClipsDescendants = true
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 7)
    local bar = Instance.new("Frame", bg)
    bar.BackgroundColor3 = C_ACCENT; bar.BorderSizePixel = 0
    bar.Position = UDim2.new(0, 0, 0.2, 0); bar.Size = UDim2.new(0, 3, 0.6, 0)
    bar.Visible = false; bar.ZIndex = 6
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)
    local icon, iconParts = createTabIcon(bg, cfg.key)
    local label = Instance.new("TextLabel", bg)
    label.BackgroundTransparency = 1; label.Position = UDim2.new(0, 37, 0, 0)
    label.Size = UDim2.new(1, -42, 1, 0); label.Font = Enum.Font.GothamSemibold
    label.Text = cfg.label; label.TextColor3 = C_TEXT_OFF; label.TextSize = 11
    label.TextXAlignment = Enum.TextXAlignment.Left; label.TextTruncate = Enum.TextTruncate.AtEnd; label.ZIndex = 6
    local btn = Instance.new("TextButton", bg)
    btn.BackgroundTransparency = 1; btn.Size = UDim2.new(1, 0, 1, 0); btn.Text = ""; btn.ZIndex = 7
    btn.MouseEnter:Connect(function()
        if currentTab ~= cfg.key then
            TweenService:Create(bg, TweenInfo.new(0.15), {BackgroundTransparency = 0.78}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= cfg.key then
            TweenService:Create(bg, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function() selectTab(cfg.key) end)
    local entry = { key=cfg.key, bg=bg, icon=icon, iconParts=iconParts, label=label, bar=bar }
    table.insert(allTabs, entry); table.insert(groupTabs, entry)
end

local keyMap = {}
for _, t in ipairs(TabConfig) do keyMap[t.key] = t end
for _, g in ipairs(GroupConfig) do
    local groupTabs = {}
    makeGroupLabel(g.label, groupTabs)
    for _, k in ipairs(g.keys) do
        if keyMap[k] then makeTab(keyMap[k], groupTabs) end
    end
end

-- ══════════════════════════════
--  BOOST FUNCTIONS
-- ══════════════════════════════
local boosterActive = false
local origMaterials = {}
local origTextures  = {}

local function UltraBooster(state)
    boosterActive = state
    if state then
        pcall(function()
            settings().Network.IncomingReplicationLag = 0
            settings().Network.DataSendRate           = 60
            settings().Network.DataReceiveRate        = 60
        end)
        pcall(function()
            sethiddenproperty(Player,"MaximumSimulationRadius",math.huge)
            sethiddenproperty(Player,"SimulationRadius",math.huge)
        end)
        for _, obj in pairs(workspace:GetDescendants()) do pcall(function()
            if obj:IsA("BasePart") then
                if not origMaterials[obj] then origMaterials[obj]={M=obj.Material,C=obj.Color,R=obj.Reflectance,T=obj.Transparency} end
                obj.Material=Enum.Material.Plastic obj.Color=Color3.fromRGB(128,128,128) obj.Reflectance=0 obj.CastShadow=false
            end
            if obj:IsA("Texture") or obj:IsA("Decal") then
                if not origTextures[obj] then origTextures[obj]=obj.Transparency end
                obj.Transparency=1
            end
        end) end
    else
        for obj,p in pairs(origMaterials) do pcall(function()
            if obj and obj.Parent then obj.Material=p.M obj.Color=p.C obj.Reflectance=p.R obj.Transparency=p.T obj.CastShadow=true end
        end) end
        for obj,t in pairs(origTextures) do pcall(function()
            if obj and obj.Parent then obj.Transparency=t end
        end) end
        origMaterials={} origTextures={}
    end
end

local effectsOff = false; local hidEffects = {}
local function ForceRemoveEffects(s)
    effectsOff=s
    if s then
        for _,v in pairs(Lighting:GetChildren()) do pcall(function()
            if v:IsA("PostEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") or
               v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                hidEffects[v]=v.Enabled v.Enabled=false
            end
        end) end
        for _,o in pairs(workspace:GetDescendants()) do pcall(function()
            if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or
               o:IsA("Smoke") or o:IsA("Fire") or o:IsA("Sparkles") or
               o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then
                hidEffects[o]=o.Enabled o.Enabled=false
            end
        end) end
    else
        for e,w in pairs(hidEffects) do pcall(function() if e and e.Parent then e.Enabled=w end end) end
        hidEffects={}
    end
end

local npcOff = false; local hidNPCs = {}
local function ForceRemoveNPCs(s)
    npcOff=s
    if s then
        for _,v in pairs(workspace:GetChildren()) do pcall(function()
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(v) then
                for _,p in pairs(v:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if not hidNPCs[p] then hidNPCs[p]={T=p.Transparency,CC=p.CanCollide} end
                        p.Transparency=1 p.CanCollide=false
                    end
                end
            end
        end) end
    else
        for p,d in pairs(hidNPCs) do pcall(function()
            if p and p.Parent then p.Transparency=d.T p.CanCollide=d.CC end
        end) end
        hidNPCs={}
    end
end

local lagOff = false; local origSet = {}
local function ForceLagCleaner(s)
    lagOff=s
    if s then pcall(function()
        origSet.Q=settings().Rendering.QualityLevel
        origSet.M=settings().Rendering.MeshPartDetailLevel
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level01
        settings().Physics.AllowSleep=true
    end) else pcall(function()
        if origSet.Q then settings().Rendering.QualityLevel=origSet.Q end
        if origSet.M then settings().Rendering.MeshPartDetailLevel=origSet.M end
    end) origSet={} end
end

-- ══════════════════════════════
--  BOOST POPUP
-- ══════════════════════════════
local BoostPopup = Instance.new("Frame", ScreenGui)
BoostPopup.Name              = "BoostPopup"
BoostPopup.BackgroundColor3  = Color3.fromRGB(28, 29, 34)
BoostPopup.Size              = UDim2.new(0, 190, 0, 0)
BoostPopup.Visible           = false
BoostPopup.ZIndex            = 200
BoostPopup.ClipsDescendants  = true
Instance.new("UICorner", BoostPopup).CornerRadius = UDim.new(0, 10)
local bpStroke = Instance.new("UIStroke", BoostPopup)
bpStroke.Color=C_ACCENT bpStroke.Thickness=1.2
local bpList = Instance.new("UIListLayout", BoostPopup)
bpList.Padding=UDim.new(0,5) bpList.HorizontalAlignment=Enum.HorizontalAlignment.Center
local bpPad = Instance.new("UIPadding", BoostPopup)
bpPad.PaddingTop=UDim.new(0,8) bpPad.PaddingLeft=UDim.new(0,8)
bpPad.PaddingRight=UDim.new(0,8) bpPad.PaddingBottom=UDim.new(0,8)

local popupOpen = false
local function toggleBoostPopup()
    popupOpen = not popupOpen
    if popupOpen then
        local pos = TopBtns["Theme"].AbsolutePosition
        BoostPopup.Position = UDim2.new(0, pos.X - 160, 0, pos.Y + 26)
        BoostPopup.Size = UDim2.new(0, 190, 0, 0); BoostPopup.Visible = true
        TweenService:Create(BoostPopup, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, 190, 0, 248)}):Play()
    else
        TweenService:Create(BoostPopup, TweenInfo.new(0.18, Enum.EasingStyle.Quad),
            {Size = UDim2.new(0, 190, 0, 0)}):Play()
        task.delay(0.19, function() BoostPopup.Visible = false end)
    end
end

local function makePopupToggle(text, callback)
    local row = Instance.new("Frame", BoostPopup)
    row.BackgroundColor3 = Color3.fromRGB(38, 41, 48); row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, 32)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
    local lbl = Instance.new("TextLabel", row)
    lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,8,0,0); lbl.Size=UDim2.new(1,-50,1,0)
    lbl.Font=Enum.Font.GothamSemibold; lbl.Text=text; lbl.TextColor3=Color3.fromRGB(190,195,205)
    lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=201
    local pill = Instance.new("Frame", row)
    pill.BackgroundColor3=Color3.fromRGB(60,65,75); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-42,0.5,-10); pill.Size=UDim2.new(0,36,0,20); pill.ZIndex=201
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame", pill)
    knob.BackgroundColor3=Color3.fromRGB(200,205,215); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,2,0.5,-8); knob.Size=UDim2.new(0,16,0,16); knob.ZIndex=202
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local state = false
    local btn = Instance.new("TextButton", row)
    btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=203
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(pill, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(87,242,135) or Color3.fromRGB(60,65,75)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        }):Play()
        callback(state)
    end)
end

makePopupToggle("⚡ Booster Ultra",     UltraBooster)
makePopupToggle("🎨 Remover Efeitos",   ForceRemoveEffects)
makePopupToggle("👻 Remover NPCs",      ForceRemoveNPCs)
makePopupToggle("🧹 Limpar Lag Total",  ForceLagCleaner)

local rejBtn = Instance.new("TextButton", BoostPopup)
rejBtn.BackgroundColor3=Color3.fromRGB(200, 50, 55); rejBtn.BorderSizePixel=0
rejBtn.Size=UDim2.new(1, 0, 0, 32); rejBtn.Font=Enum.Font.GothamBold
rejBtn.Text="🔄  REJOIN SERVER"; rejBtn.TextColor3=Color3.fromRGB(255,255,255)
rejBtn.TextSize=11; rejBtn.ZIndex=201
Instance.new("UICorner", rejBtn).CornerRadius = UDim.new(0, 7)
rejBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
end)

-- ══════════════════════════════
--  BOTÃO FLUTUANTE
-- ══════════════════════════════
local FloatBtn = Instance.new("Frame", ScreenGui)
FloatBtn.Name = "FloatBtn"; FloatBtn.Size = UDim2.new(0, 68, 0, 68)
FloatBtn.Position = UDim2.new(0.05, 0, 0.08, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(12, 13, 20); FloatBtn.BorderSizePixel = 0
FloatBtn.Visible = false; FloatBtn.ZIndex = 100; FloatBtn.Active = true
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatRing = Instance.new("UIStroke", FloatBtn)
FloatRing.Color = Color3.fromRGB(88, 101, 242); FloatRing.Thickness = 2.2
local PDText = Instance.new("TextLabel", FloatBtn)
PDText.BackgroundTransparency=1; PDText.Position=UDim2.new(0,0,0,0); PDText.Size=UDim2.new(1,0,1,0)
PDText.Font=Enum.Font.GothamBlack; PDText.Text="PD"; PDText.TextColor3=Color3.fromRGB(220,225,255)
PDText.TextSize=20; PDText.TextTransparency=0.05; PDText.ZIndex=105
local PDStroke = Instance.new("UIStroke", PDText)
PDStroke.Color=Color3.fromRGB(88,101,242); PDStroke.Thickness=1.5; PDStroke.Transparency=0.3
local FloatClick = Instance.new("TextButton", FloatBtn)
FloatClick.BackgroundTransparency=1; FloatClick.Size=UDim2.new(1,0,1,0); FloatClick.Text=""; FloatClick.ZIndex=110
FloatClick.MouseEnter:Connect(function()
    TweenService:Create(FloatRing, TweenInfo.new(0.2), {Color=Color3.fromRGB(160,170,255), Thickness=3}):Play()
end)
FloatClick.MouseLeave:Connect(function()
    TweenService:Create(FloatRing, TweenInfo.new(0.2), {Color=Color3.fromRGB(88,101,242), Thickness=2.2}):Play()
end)

local function showFloatBtn()
    FloatBtn.Size=UDim2.new(0,0,0,0); FloatBtn.Position=UDim2.new(0.05,34,0.08,34); FloatBtn.Visible=true
    TweenService:Create(FloatBtn, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size=UDim2.new(0,68,0,68), Position=UDim2.new(0.05,0,0.08,0)
    }):Play()
end

FloatClick.MouseButton1Click:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size=UDim2.new(0,0,0,0), Position=UDim2.new(0.05,34,0.08,34)
    }):Play()
    task.delay(0.22, function()
        FloatBtn.Visible=false; FloatBtn.Size=UDim2.new(0,68,0,68); FloatBtn.Position=UDim2.new(0.05,0,0.08,0)
        MainFrame.Visible=true; MainFrame.Size=UDim2.new(0,540,0,0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            {Size=UDim2.new(0,540,0,370)}):Play()
    end)
end)

-- ── TopBar Button Actions ──────────────────────────────────────────
TopBtns["Theme"].MouseButton1Click:Connect(function() toggleBoostPopup() end)

local isMinimized = false
TopBtns["Minimize"].MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad),
        {Size = isMinimized and UDim2.new(0,540,0,40) or UDim2.new(0,540,0,370)}):Play()
end)

local isMaximized = false
local normalSize = UDim2.new(0, 540, 0, 370)
local normalPos  = MainFrame.Position
TopBtns["Maximize"].MouseButton1Click:Connect(function()
    isMaximized = not isMaximized
    if isMaximized then
        normalPos = MainFrame.Position
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size=UDim2.new(0,760,0,500), Position=UDim2.new(0.5,-380,0.5,-250)
        }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size=normalSize, Position=normalPos
        }):Play()
    end
end)

TopBtns["Close"].MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad),
        {Size=UDim2.new(0,540,0,0)}):Play()
    task.delay(0.22, function()
        MainFrame.Visible=false; MainFrame.Size=UDim2.new(0,540,0,370); showFloatBtn()
    end)
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not popupOpen then return end
    local mp = UserInputService:GetMouseLocation()
    local ap, as = BoostPopup.AbsolutePosition, BoostPopup.AbsoluteSize
    if mp.X<ap.X or mp.X>ap.X+as.X or mp.Y<ap.Y or mp.Y>ap.Y+as.Y then toggleBoostPopup() end
end)

-- ════════════════════════════════════════════════════════════════════
--
--   ███████╗ ███████╗ ██████╗      v4
--   ██╔════╝ ██╔════╝ ██╔══██╗
--   █████╗   ███████╗ ██████╔╝
--   ██╔══╝   ╚════██║ ██╔═══╝
--   ███████╗ ███████║ ██║
--   ╚══════╝ ╚══════╝ ╚═╝
--
--   Sistema ESP v4 — 20 categorias, dados Wiki 2026
--   Integrado na aba Pages["Esp"] do V3
--
-- ════════════════════════════════════════════════════════════════════

-- Canvas para labels flutuantes (overlay separado)
local EspCanvas = Instance.new("Frame", ScreenGui)
EspCanvas.BackgroundTransparency = 1
EspCanvas.Size   = UDim2.new(1, 0, 1, 0)
EspCanvas.ZIndex = 1

-- ── CATEGORIAS ESP (20) ───────────────────────────────────────────
local ESP_CATS = {
    { key="Players", label="👤 Players",
      cor=Color3.fromRGB(255,80,80), tipo="player", alcance=math.huge,
      desc="Todos os players no servidor" },

    { key="Kids", label="👶 Crianças Perdidas",
      cor=Color3.fromRGB(100,220,255), tipo="entity", alcance=math.huge,
      desc="Dino, Kraken, Squid, Koala Kid",
      nomes={"Dino Kid","Kraken Kid","Squid Kid","Koala Kid",
             "DinoKid","KrakenKid","SquidKid","KoalaKid","Kid","Child","MissingChild"} },

    { key="AnimPassivo", label="🐰 Animais Passivos",
      cor=Color3.fromRGB(130,255,170), tipo="entity", alcance=500,
      desc="Bunny, Horse, Kiwi, Turkey — não atacam",
      nomes={"Bunny","Horse","Kiwi","Turkey"} },

    { key="AnimAgressivo", label="🐺 Animais Agressivos",
      cor=Color3.fromRGB(255,175,30), tipo="entity", alcance=600,
      desc="Wolf, Alpha Wolf, Bear, Polar Bear, Arctic Fox, Frog, Scorpion, Hellephant, Meteor Crab, Mammoth",
      nomes={"Wolf","Alpha Wolf","AlphaWolf","Bear","Polar Bear","PolarBear",
             "Arctic Fox","ArcticFox","Frog","Blue Frog","Purple Frog","BlueFrog","PurpleFrog",
             "Scorpion","Hellephant","Meteor Crab","MeteorCrab","Mammoth"} },

    { key="Monstros", label="💀 Monstros",
      cor=Color3.fromRGB(255,50,50), tipo="entity", alcance=math.huge,
      desc="The Deer, The Owl, The Ram, The Bat",
      nomes={"The Deer","TheDeer","Deer","The Owl","TheOwl","Owl",
             "The Ram","TheRam","Ram","The Bat","TheBat","Bat"} },

    { key="Cultistas", label="⚔️ Cultistas",
      cor=Color3.fromRGB(195,60,200), tipo="entity", alcance=math.huge,
      desc="Cultist, Crossbow, Juggernaut, King, Shadow, Brute",
      nomes={"Cultist","Melee Cultist","MeleeCultist","Crossbow Cultist","CrossbowCultist",
             "Juggernaut Cultist","JuggernautCultist","Juggernaut",
             "Cultist King","CultistKing","Shadow Cultist","ShadowCultist",
             "Brute Cultist","BruteCultist"} },

    { key="Aliens", label="👽 Aliens",
      cor=Color3.fromRGB(60,255,200), tipo="entity", alcance=700,
      desc="Alien, Elite Alien",
      nomes={"Alien","Elite Alien","EliteAlien","NormalAlien"} },

    { key="EspLog", label="🪵 Log",
      cor=Color3.fromRGB(190,130,60), tipo="item", alcance=400,
      desc="Log — combustível principal",
      nomes={"Log"} },

    { key="EspCombustivel", label="🔥 Combustível",
      cor=Color3.fromRGB(255,120,30), tipo="item", alcance=400,
      desc="Coal, Biofuel, Fuel Canister, Oil Barrel, Purple Fur Tuft, Chair",
      nomes={"Coal","Biofuel","Oil Barrel","OilBarrel","Fuel Canister","FuelCanister",
             "Purple Fur Tuft","PurpleFurTuft","Chair"} },

    { key="EspCarcacas", label="🦴 Carcaças",
      cor=Color3.fromRGB(180,100,50), tipo="item", alcance=350,
      desc="Wolf/Bear/Cultist/Alien Corpse…",
      nomes={"Wolf Corpse","WolfCorpse","Alpha Wolf Corpse","AlphaWolfCorpse",
             "Bear Corpse","BearCorpse","Cultist Corpse","CultistCorpse",
             "Crossbow Cultist Corpse","CrossbowCultistCorpse",
             "Juggernaut Cultist Corpse","JuggernautCultistCorpse",
             "Cultist King Corpse","CultistKingCorpse",
             "Alien Corpse","AlienCorpse","Elite Alien Corpse","EliteAlienCorpse"} },

    { key="EspSucata", label="🔩 Sucata",
      cor=Color3.fromRGB(155,210,255), tipo="item", alcance=400,
      desc="Bolt, Sheet Metal, UFO Junk, Broken Fan, Old Radio, Tyre…",
      nomes={"Bolt","Sheet Metal","SheetMetal","UFO Junk","UFOJunk",
             "UFO Component","UFOComponent","UFO Scrap","UFOScrap",
             "Broken Fan","BrokenFan","Old Radio","OldRadio","Broken Radio","BrokenRadio",
             "Broken Microwave","BrokenMicrowave","Tyre","Metal Chair","MetalChair",
             "Old Car Engine","OldCarEngine","Washing Machine","WashingMachine",
             "Cultist Experiment","CultistExperiment","Cultist Prototype","CultistPrototype"} },

    { key="EspMateriais", label="💎 Materiais",
      cor=Color3.fromRGB(220,175,255), tipo="item", alcance=400,
      desc="Cultist Gem, Forest Gem, Mossy Coin, Meteor Shard, Obsidiron…",
      nomes={"Cultist Gem","CultistGem","Forest Gem","ForestGem",
             "Forest Gem Fragment","ForestGemFragment","Mossy Coin","MossyCoin",
             "Flower","Sapling","Sacrifice Totem","SacrificeTotem",
             "Meteor Shard","MeteorShard","Gold Shard","GoldShard",
             "Raw Obsidiron Ore","RawObsidironOre","Obsidiron Ingot","ObsidironIngot",
             "Scalding Obsidiron Ingot","ScaldingObsidironIngot","Raw Obsidiron Ore Shard"} },

    { key="EspComidas", label="🍖 Comidas",
      cor=Color3.fromRGB(255,115,165), tipo="item", alcance=350,
      desc="Carrot, Corn, Berry, Steak, Ribs, Stew, Candy…",
      nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake",
             "Morsel","Cooked Morsel","CookedMorsel","Steak","Cooked Steak","CookedSteak",
             "Ribs","Cooked Ribs","CookedRibs","Stew","Hearty Stew","HeartyStew",
             "Meat? Sandwich","MeatSandwich","Seafood Chowder","SeafoodChowder",
             "Steak Dinner","SteakDinner","Pumpkin Soup","PumpkinSoup",
             "BBQ Ribs","BBQRibs","Carrot Cake","CarrotCake","Jar o' Jelly","JarOJelly",
             "Candy Apple","CandyApple","Candy Corn","CandyCorn","Pumpkin Pie","PumpkinPie",
             "Cotton Candy","CottonCandy","Turkey Leg","TurkeyLeg",
             "Cooked Turkey Leg","CookedTurkeyLeg","Stuffing","Sweet Potato","SweetPotato",
             "Berry Juice","BerryJuice","Casserole","Corn on the Cob","CornontheCob",
             "Stuffing Bowl","StuffingBowl","Roast Turkey","RoastTurkey",
             "Stuffed Peppers","StuffedPeppers","Sweet Potato Pie","SweetPotatoPie",
             "Spicy Swordfish","SpicySwordfish","Hearty Thanksgiving Meal"} },

    { key="EspPeixes", label="🐟 Peixes",
      cor=Color3.fromRGB(80,180,255), tipo="item", alcance=400,
      desc="Mackerel, Salmon, Clownfish, Shark, Lava Eel, Lionfish…",
      nomes={"Mackerel","Cooked Mackerel","CookedMackerel",
             "Salmon","Cooked Salmon","CookedSalmon",
             "Clownfish","Cooked Clownfish","CookedClownfish",
             "Jellyfish","Char","Cooked Char","CookedChar",
             "Eel","Cooked Eel","CookedEel","Swordfish","Cooked Swordfish","CookedSwordfish",
             "Shark","Cooked Shark","CookedShark",
             "Lava Eel","LavaEel","Cooked Lava Eel","CookedLavaEel",
             "Lionfish","Cooked Lionfish","CookedLionfish"} },

    { key="EspSementes", label="🌱 Sementes",
      cor=Color3.fromRGB(135,245,115), tipo="item", alcance=350,
      desc="Chili, Berry, Flower, Firefly, Dripleaf, Moonflower…",
      nomes={"Chili Seeds","ChiliSeeds","Flower Seeds","FlowerSeeds",
             "Berry Seeds","BerrySeeds","Firefly Seeds","FireflySeeds",
             "Dripleaf Seeds","DripleafSeeds","Moonflower Seeds","MoonflowerSeeds",
             "Stareweed Seeds","StareweedSeeds","Cavevine Seeds","CavevineSeeds",
             "Mandrake Seeds","MandrakeSeeds"} },

    { key="EspFerr", label="🪓 Ferramentas & Sacos",
      cor=Color3.fromRGB(255,200,55), tipo="item", alcance=500,
      desc="Axes, Sacks, Rods, Flutes, Flashlights, Trim Kits…",
      nomes={"Old Sack","OldSack","Good Sack","GoodSack","Infernal Sack","InfernalSack",
             "Giant Sack","GiantSack","Old Axe","OldAxe","Good Axe","GoodAxe",
             "Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw",
             "Old Rod","OldRod","Good Rod","GoodRod","Strong Rod","StrongRod",
             "Old Taming Flute","OldFlute","Good Taming Flute","GoodFlute",
             "Strong Taming Flute","StrongFlute","Old Flashlight","OldFlashlight",
             "Strong Flashlight","StrongFlashlight","Axe Trim Kit","AxeTrimKit",
             "Armor Trim Kit","ArmorTrimKit","Hammer","Paint Brush","PaintBrush",
             "Watering Can","WateringCan","Cultist Staff","CultistStaff"} },

    { key="EspArmas", label="⚔️ Armas",
      cor=Color3.fromRGB(255,70,70), tipo="item", alcance=500,
      desc="Spear, Morningstar, Crossbow, Ice Sword, Revolver, Rifle…",
      nomes={"Spear","Morningstar","Katana","Laser Sword","LaserSword",
             "Ice Sword","IceSword","Trident","Poison Spear","PoisonSpear",
             "Infernal Sword","InfernalSword","Obsidiron Hammer","ObsidironHammer",
             "Scythe","Crossbow","Infernal Crossbow","InfernalCrossbow",
             "Bouncing Blade","BouncingBlade","Vampire Scythe","VampireScythe",
             "Revolver","Rifle","Tactical Shotgun","TacticalShotgun",
             "Ray Gun","RayGun","Laser Cannon","LaserCannon",
             "Flamethrower","Snowball","Frozen Shuriken","FrozenShuriken",
             "Kunai","Witch Potion","WitchPotion","Wildfire","Blowpipe","Air Rifle","AirRifle"} },

    { key="EspAmmo", label="🔫 Munição",
      cor=Color3.fromRGB(255,155,60), tipo="item", alcance=400,
      desc="Revolver Ammo, Rifle Ammo, Shotgun Ammo",
      nomes={"Revolver Ammo","RevolverAmmo","Rifle Ammo","RifleAmmo",
             "Shotgun Ammo","ShotgunAmmo"} },

    { key="EspCura", label="💊 Cura & Pelts",
      cor=Color3.fromRGB(120,255,200), tipo="item", alcance=450,
      desc="Bandage, Medkit, Wolf Pelt, Bear Pelt, Bunny Foot…",
      nomes={"Bandage","Medkit","Bunny Foot","BunnyFoot","Wolf Pelt","WolfPelt",
             "Alpha Wolf Pelt","AlphaWolfPelt","Bear Pelt","BearPelt",
             "Arctic Fox Pelt","ArcticFoxPelt","Polar Bear Pelt","PolarBearPelt",
             "Mammoth Tusk","MammothTusk","Scorpion Shell","ScorpionShell",
             "Cultist King Antler","CultistKingAntler"} },

    { key="EspChaves", label="🗝️ Chaves",
      cor=Color3.fromRGB(255,230,80), tipo="item", alcance=math.huge,
      desc="Red, Blue, Yellow, Grey, Frog Key",
      nomes={"Red Key","RedKey","Blue Key","BlueKey","Yellow Key","YellowKey",
             "Grey Key","GreyKey","Frog Key","FrogKey"} },

    { key="EspBigorna", label="⚙️ Partes de Bigorna",
      cor=Color3.fromRGB(200,160,255), tipo="item", alcance=math.huge,
      desc="Anvil Front/Back/Base + Meteor Anvil Parts",
      nomes={"Anvil Front","AnvilFront","Anvil Back","AnvilBack","Anvil Base","AnvilBase",
             "Meteor Anvil Front","MeteorAnvilFront","Meteor Anvil Back","MeteorAnvilBack",
             "Meteor Anvil Base","MeteorAnvilBase"} },

    { key="EspPocoes", label="🧪 Poções",
      cor=Color3.fromRGB(195,100,255), tipo="item", alcance=400,
      desc="Dripleaf, Moonflower Bulb, Stareweed Petal, Cave Vine Flower, Mandrake",
      nomes={"Dripleaf","Moonflower Bulb","MoonflowerBulb","Stareweed Petal","StareweedPetal",
             "Cave Vine Flower","CaveVineFlower","Mandrake"} },

    { key="EspBlueprint", label="📋 Blueprints",
      cor=Color3.fromRGB(130,190,255), tipo="item", alcance=500,
      desc="Crafting, Defense, Furniture, Obsidiron Chest Blueprint…",
      nomes={"Crafting Blueprint","CraftingBlueprint","Defense Blueprint","DefenseBlueprint",
             "Furniture Blueprint","FurnitureBlueprint",
             "Obsidiron Chest Blueprint","ObsidironChestBlueprint",
             "Halloween Blueprint","HalloweenBlueprint"} },
}

-- Estado e lookup
local espAtivo = {}
for _, c in ipairs(ESP_CATS) do espAtivo[c.key] = false end

local espLookup = {}
for _, c in ipairs(ESP_CATS) do
    if c.nomes then
        local s = {}
        for _, n in ipairs(c.nomes) do s[n:lower()] = true end
        espLookup[c.key] = s
    end
end

-- ── Pool de labels flutuantes ────────────────────────────────────
local POOL_SIZE  = 120
local labelPool  = {}
local activeList = {}

local function newLabel()
    local f = Instance.new("Frame", EspCanvas)
    f.BackgroundTransparency = 1; f.BorderSizePixel = 0
    f.Size = UDim2.new(0, 210, 0, 30); f.Visible = false; f.ZIndex = 10
    local bg = Instance.new("Frame", f)
    bg.BackgroundColor3 = Color3.fromRGB(6, 8, 14); bg.BackgroundTransparency = 0.3
    bg.BorderSizePixel = 0; bg.Size = UDim2.new(1, 0, 1, 0); bg.ZIndex = 10
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 5)
    local n = Instance.new("TextLabel", f); n.Name = "NL"
    n.BackgroundTransparency = 1; n.Position = UDim2.new(0, 6, 0, 2)
    n.Size = UDim2.new(1, -8, 0, 14); n.Font = Enum.Font.GothamBold; n.TextSize = 11
    n.TextXAlignment = Enum.TextXAlignment.Left; n.TextStrokeTransparency = 0.1
    n.TextStrokeColor3 = Color3.new(0,0,0); n.TextTruncate = Enum.TextTruncate.AtEnd; n.ZIndex = 12
    local d = Instance.new("TextLabel", f); d.Name = "DL"
    d.BackgroundTransparency = 1; d.Position = UDim2.new(0, 6, 0, 16)
    d.Size = UDim2.new(1, -8, 0, 11); d.Font = Enum.Font.Gotham; d.TextSize = 9
    d.TextColor3 = Color3.fromRGB(170, 185, 210); d.TextXAlignment = Enum.TextXAlignment.Left
    d.TextStrokeTransparency = 0.2; d.TextStrokeColor3 = Color3.new(0,0,0); d.ZIndex = 12
    return f
end

for i = 1, POOL_SIZE do table.insert(labelPool, newLabel()) end

local function showLabel(cor, nome, dist, sx, sy)
    local f = table.remove(labelPool)
    if not f then return end
    f.Position = UDim2.new(0, sx - 105, 0, sy - 15); f.Visible = true
    local nl = f:FindFirstChild("NL"); local dl = f:FindFirstChild("DL")
    if nl then nl.Text = nome; nl.TextColor3 = cor end
    if dl then dl.Text = string.format("%.0f m", dist) end
    table.insert(activeList, f)
end

local function releaseAll()
    for _, f in ipairs(activeList) do f.Visible = false; table.insert(labelPool, f) end
    activeList = {}
end

-- ── Cache assíncrono ─────────────────────────────────────────────
local entityCache   = {}
local itemCache     = {}
local cacheBuilding = false
local lastCache     = 0
local CACHE_INTER   = 5

local function isAlive(model)
    local hum = model:FindFirstChildWhichIsA("Humanoid")
    if not hum then return false end
    if hum.Health <= 0 or hum.MaxHealth <= 0 then return false end
    local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not hrp then return false end
    local pos = hrp.Position
    if pos.Y < -400 or pos.Magnitude > 6000 then return false end
    return true
end

local function anyEspActive(tipo)
    for _, c in ipairs(ESP_CATS) do
        if espAtivo[c.key] and c.tipo == tipo then return true end
    end
    return false
end

local function buildCache()
    if cacheBuilding then return end
    local now = tick()
    if now - lastCache < CACHE_INTER then return end
    lastCache = now; cacheBuilding = true
    task.spawn(function()
        local newEnt = {}; local newItem = {}
        local doEnt  = anyEspActive("entity")
        local doItem = anyEspActive("item")
        if not doEnt and not doItem then
            entityCache = newEnt; itemCache = newItem; cacheBuilding = false; return
        end
        local ok, descs = pcall(function() return workspace:GetDescendants() end)
        if not ok then cacheBuilding = false; return end
        local pchars = {}
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl.Character then pchars[pl.Character] = true end
        end
        local batch = 0
        for _, obj in ipairs(descs) do
            batch += 1
            if batch % 100 == 0 then task.wait() end
            if not obj or not obj.Parent then continue end
            local nameLower = obj.Name:lower()
            if doEnt and obj:IsA("Model") then
                if not pchars[obj] and isAlive(obj) then
                    for _, c in ipairs(ESP_CATS) do
                        if espAtivo[c.key] and c.tipo == "entity" then
                            local lk = espLookup[c.key]
                            if lk and lk[nameLower] then
                                local hrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                                if hrp then
                                    table.insert(newEnt, {key=c.key, cor=c.cor, nome=obj.Name, alcance=c.alcance, obj=obj, hrp=hrp})
                                end
                                break
                            end
                        end
                    end
                end
            elseif doItem and obj:IsA("BasePart") and not obj.Anchored then
                if not pchars[obj] then
                    local isNPC = false
                    local p = obj.Parent
                    for _ = 1, 3 do
                        if p and p:IsA("Model") and p:FindFirstChildWhichIsA("Humanoid") then isNPC = true; break end
                        p = p and p.Parent
                    end
                    if not isNPC then
                        for _, c in ipairs(ESP_CATS) do
                            if espAtivo[c.key] and c.tipo == "item" then
                                local lk = espLookup[c.key]
                                if lk and lk[nameLower] then
                                    table.insert(newItem, {key=c.key, cor=c.cor, nome=obj.Name, alcance=c.alcance, obj=obj})
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        entityCache = newEnt; itemCache = newItem; cacheBuilding = false
    end)
end

-- ── Render loop 20fps ────────────────────────────────────────────
local dtAcc = 0
local RENDER_I = 1/20
RunService.Heartbeat:Connect(function(dt)
    dtAcc += dt
    if dtAcc < RENDER_I then return end
    dtAcc = 0
    releaseAll()
    local qualquer = false
    for _, c in ipairs(ESP_CATS) do if espAtivo[c.key] then qualquer = true; break end end
    if not qualquer then return end
    pcall(buildCache)
    local charPos = Vector3.zero
    pcall(function()
        local ch = Player.Character
        if ch and ch:FindFirstChild("HumanoidRootPart") then charPos = ch.HumanoidRootPart.Position end
    end)
    local vp   = Cam.ViewportSize
    local seen = {}
    -- Players
    if espAtivo["Players"] then
        for _, pl in ipairs(Players:GetPlayers()) do
            if pl ~= Player and pl.Character then
                pcall(function()
                    local hrp = pl.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                    local hum = pl.Character:FindFirstChildWhichIsA("Humanoid")
                    if not hum or hum.Health <= 0 then return end
                    local dist = (hrp.Position - charPos).Magnitude
                    local sp, vis = Cam:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
                    if not vis or sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
                    local cell = math.floor(sp.X/12)..","..math.floor(sp.Y/12)
                    if seen[cell] then return end; seen[cell]=true
                    showLabel(Color3.fromRGB(255,80,80), pl.DisplayName, dist, sp.X, sp.Y)
                end)
            end
        end
    end
    -- Entidades
    for _, e in ipairs(entityCache) do
        pcall(function()
            if not espAtivo[e.key] then return end
            if not e.obj or not e.obj.Parent then return end
            local hum = e.obj:FindFirstChildWhichIsA("Humanoid")
            if not hum or hum.Health <= 0 then return end
            local pos = e.hrp.Position
            local dist = (pos - charPos).Magnitude
            if dist > e.alcance then return end
            local sp, vis = Cam:WorldToViewportPoint(pos + Vector3.new(0,2.5,0))
            if not vis or sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
            local cell = math.floor(sp.X/12)..","..math.floor(sp.Y/12)
            if seen[cell] then return end; seen[cell]=true
            showLabel(e.cor, e.nome, dist, sp.X, sp.Y)
        end)
    end
    -- Itens
    for _, e in ipairs(itemCache) do
        pcall(function()
            if not espAtivo[e.key] then return end
            if not e.obj or not e.obj.Parent then return end
            if e.obj.Anchored then return end
            local pos = e.obj.Position
            local dist = (pos - charPos).Magnitude
            if dist > e.alcance then return end
            local sp, vis = Cam:WorldToViewportPoint(pos + Vector3.new(0,0.8,0))
            if not vis or sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
            local cell = math.floor(sp.X/10)..","..math.floor(sp.Y/10)
            if seen[cell] then return end; seen[cell]=true
            showLabel(e.cor, e.nome, dist, sp.X, sp.Y)
        end)
    end
end)

-- ── UI da aba ESP ────────────────────────────────────────────────
local espTabLO = 0
local function espLO() espTabLO += 1; return espTabLO end

local function makeEspSection(titulo, cor)
    local hdr = Instance.new("Frame", Pages["Esp"])
    hdr.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    hdr.BackgroundTransparency = 0.3; hdr.BorderSizePixel = 0
    hdr.Size = UDim2.new(1, 0, 0, 22); hdr.LayoutOrder = espLO(); hdr.ZIndex = 4
    Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 6)
    local bar = Instance.new("Frame", hdr)
    bar.BackgroundColor3 = cor; bar.BorderSizePixel = 0
    bar.Position = UDim2.new(0,0,0,0); bar.Size = UDim2.new(0,3,1,0); bar.ZIndex = 5
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)
    local lbl = Instance.new("TextLabel", hdr)
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0,10,0,0)
    lbl.Size = UDim2.new(1,-14,1,0); lbl.Font = Enum.Font.GothamBlack
    lbl.Text = titulo; lbl.TextColor3 = cor; lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5
end

local function makeEspRow(cat)
    local row = Instance.new("Frame", Pages["Esp"])
    row.BackgroundColor3 = Color3.fromRGB(22, 24, 32); row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, 36); row.LayoutOrder = espLO(); row.ZIndex = 4
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local rStroke = Instance.new("UIStroke", row)
    rStroke.Color = Color3.fromRGB(36, 40, 52); rStroke.Thickness = 1
    local dot = Instance.new("Frame", row)
    dot.BackgroundColor3 = cat.cor; dot.BorderSizePixel = 0
    dot.Position = UDim2.new(0,9,0.5,-5); dot.Size = UDim2.new(0,10,0,10); dot.ZIndex = 5
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local lbl = Instance.new("TextLabel", row)
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0,25,0,4)
    lbl.Size = UDim2.new(1,-80,0,14); lbl.Font = Enum.Font.GothamBold
    lbl.Text = cat.label; lbl.TextColor3 = Color3.fromRGB(205,215,235)
    lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5
    local desc = Instance.new("TextLabel", row)
    desc.BackgroundTransparency = 1; desc.Position = UDim2.new(0,25,0,19)
    desc.Size = UDim2.new(1,-80,0,12); desc.Font = Enum.Font.Gotham
    desc.Text = cat.desc or ""; desc.TextColor3 = Color3.fromRGB(75,88,108)
    desc.TextSize = 8; desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextTruncate = Enum.TextTruncate.AtEnd; desc.ZIndex = 5
    local pill = Instance.new("Frame", row)
    pill.BackgroundColor3 = Color3.fromRGB(36,40,52); pill.BorderSizePixel = 0
    pill.Position = UDim2.new(1,-50,0.5,-11); pill.Size = UDim2.new(0,40,0,22); pill.ZIndex = 5
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", pill)
    knob.BackgroundColor3 = Color3.fromRGB(130,145,165); knob.BorderSizePixel = 0
    knob.Position = UDim2.new(0,2,0.5,-9); knob.Size = UDim2.new(0,18,0,18); knob.ZIndex = 6
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local btn = Instance.new("TextButton", row)
    btn.BackgroundTransparency = 1; btn.Size = UDim2.new(1,0,1,0); btn.Text = ""; btn.ZIndex = 7
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on; espAtivo[cat.key] = on; lastCache = 0
        local tw = TweenInfo.new(0.18)
        TweenService:Create(pill, tw, {BackgroundColor3 = on and cat.cor or Color3.fromRGB(36,40,52)}):Play()
        TweenService:Create(knob, tw, {
            Position = on and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
            BackgroundColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,145,165),
        }):Play()
        TweenService:Create(rStroke, tw, {Color = on and cat.cor or Color3.fromRGB(36,40,52)}):Play()
    end)
end

-- Montar aba ESP com grupos
local espCatMap = {}
for _, c in ipairs(ESP_CATS) do espCatMap[c.key] = c end

local espGroupOrder = {
    {"ESP — Entidades",           Color3.fromRGB(88,101,242),  {"Players","Kids","AnimPassivo","AnimAgressivo","Monstros","Cultistas","Aliens"}},
    {"ESP — Recursos & Combustível", Color3.fromRGB(255,130,40), {"EspLog","EspCombustivel","EspCarcacas","EspSucata","EspMateriais"}},
    {"ESP — Comida & Natureza",   Color3.fromRGB(255,120,170), {"EspComidas","EspPeixes","EspSementes","EspPocoes"}},
    {"ESP — Equipamentos",        Color3.fromRGB(255,200,55),  {"EspFerr","EspArmas","EspAmmo","EspCura","EspChaves","EspBigorna","EspBlueprint"}},
}

for _, grp in ipairs(espGroupOrder) do
    local titulo, cor, keys = grp[1], grp[2], grp[3]
    makeEspSection(titulo, cor)
    for _, k in ipairs(keys) do
        if espCatMap[k] then makeEspRow(espCatMap[k]) end
    end
end

-- Rodapé ESP
do
    local f = Instance.new("Frame", Pages["Esp"])
    f.BackgroundColor3 = Color3.fromRGB(40,20,10); f.BackgroundTransparency = 0.4
    f.BorderSizePixel = 0; f.Size = UDim2.new(1,0,0,44); f.LayoutOrder = espLO(); f.ZIndex = 5
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local s = Instance.new("UIStroke", f); s.Color = Color3.fromRGB(200,130,30); s.Thickness = 1
    local t = Instance.new("TextLabel", f)
    t.BackgroundTransparency = 1; t.Position = UDim2.new(0,8,0,4)
    t.Size = UDim2.new(1,-16,1,-8); t.Font = Enum.Font.Gotham
    t.Text = "ℹ ESP só mostra entidades vivas (Health > 0). Cache async a cada 5s. 20 categorias — dados Wiki 99 Nights 2026."
    t.TextColor3 = Color3.fromRGB(220,170,80); t.TextSize = 8
    t.TextWrapped = true; t.TextXAlignment = Enum.TextXAlignment.Left
    t.TextYAlignment = Enum.TextYAlignment.Top; t.ZIndex = 6
end

-- ════════════════════════════════════════════════════════════════════
--
--   ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗     v4
--   ██╔══██╗██╔══██╗██║████╗  ██║██╔════╝
--   ██████╔╝██████╔╝██║██╔██╗ ██║██║  ███╗
--   ██╔══██╗██╔══██╗██║██║╚██╗██║██║   ██║
--   ██████╔╝██║  ██║██║██║ ╚████║╚██████╔╝
--   ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝
--
--   Sistema BRING v4 — 16 categorias individuais
--   Integrado na aba Pages["Bring"] do V3
--
-- ════════════════════════════════════════════════════════════════════

local BRING_CATS = {
    { key="BLog", label="🪵 Bring Log",
      cor=Color3.fromRGB(190,130,60),
      desc="Só pega: Log",
      nomes={"Log"} },

    { key="BCombust", label="🔥 Bring Combustível",
      cor=Color3.fromRGB(255,120,30),
      desc="Coal, Biofuel, Fuel Canister, Oil Barrel, Purple Fur Tuft, Chair",
      nomes={"Coal","Biofuel","Oil Barrel","OilBarrel","Fuel Canister","FuelCanister",
             "Purple Fur Tuft","PurpleFurTuft","Chair"} },

    { key="BCarcacas", label="🦴 Bring Carcaças",
      cor=Color3.fromRGB(180,100,50),
      desc="Wolf, Alpha Wolf, Bear, Cultist, Alien Corpse…",
      nomes={"Wolf Corpse","WolfCorpse","Alpha Wolf Corpse","AlphaWolfCorpse",
             "Bear Corpse","BearCorpse","Cultist Corpse","CultistCorpse",
             "Crossbow Cultist Corpse","CrossbowCultistCorpse",
             "Juggernaut Cultist Corpse","JuggernautCultistCorpse",
             "Cultist King Corpse","CultistKingCorpse",
             "Alien Corpse","AlienCorpse","Elite Alien Corpse","EliteAlienCorpse"} },

    { key="BSucata", label="🔩 Bring Sucata",
      cor=Color3.fromRGB(155,210,255),
      desc="Bolt, Sheet Metal, UFO Junk, Broken Fan, Old Radio, Tyre…",
      nomes={"Bolt","Sheet Metal","SheetMetal","UFO Junk","UFOJunk",
             "UFO Component","UFOComponent","UFO Scrap","UFOScrap",
             "Broken Fan","BrokenFan","Old Radio","OldRadio","Broken Radio","BrokenRadio",
             "Broken Microwave","BrokenMicrowave","Tyre","Metal Chair","MetalChair",
             "Old Car Engine","OldCarEngine","Washing Machine","WashingMachine",
             "Cultist Experiment","CultistExperiment","Cultist Prototype","CultistPrototype"} },

    { key="BMateriais", label="💎 Bring Materiais",
      cor=Color3.fromRGB(220,175,255),
      desc="Cultist Gem, Forest Gem, Mossy Coin, Meteor Shard…",
      nomes={"Cultist Gem","CultistGem","Forest Gem","ForestGem",
             "Forest Gem Fragment","ForestGemFragment","Mossy Coin","MossyCoin",
             "Flower","Sapling","Sacrifice Totem","SacrificeTotem",
             "Meteor Shard","MeteorShard","Gold Shard","GoldShard",
             "Raw Obsidiron Ore","RawObsidironOre","Obsidiron Ingot","ObsidironIngot",
             "Scalding Obsidiron Ingot"} },

    { key="BComidas", label="🍖 Bring Comidas",
      cor=Color3.fromRGB(255,115,165),
      desc="Carrot, Corn, Steak, Ribs, Stew, Cake, Candy…",
      nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake",
             "Morsel","Cooked Morsel","CookedMorsel","Steak","Cooked Steak","CookedSteak",
             "Ribs","Cooked Ribs","CookedRibs","Stew","Hearty Stew","HeartyStew",
             "Meat? Sandwich","Seafood Chowder","Steak Dinner","Pumpkin Soup","BBQ Ribs",
             "Carrot Cake","Jar o' Jelly","Candy Apple","Candy Corn","Pumpkin Pie",
             "Cotton Candy","Turkey Leg","Cooked Turkey Leg","Stuffing","Sweet Potato",
             "Berry Juice","Casserole","Corn on the Cob","Stuffing Bowl","Roast Turkey",
             "Stuffed Peppers","Sweet Potato Pie","Spicy Swordfish","Hearty Thanksgiving Meal"} },

    { key="BPeixes", label="🐟 Bring Peixes",
      cor=Color3.fromRGB(80,180,255),
      desc="Mackerel, Salmon, Clownfish, Jellyfish, Shark, Lava Eel…",
      nomes={"Mackerel","Cooked Mackerel","CookedMackerel","Salmon","Cooked Salmon","CookedSalmon",
             "Clownfish","Cooked Clownfish","CookedClownfish","Jellyfish","Char","Cooked Char","CookedChar",
             "Eel","Cooked Eel","CookedEel","Swordfish","Cooked Swordfish","CookedSwordfish",
             "Shark","Cooked Shark","CookedShark","Lava Eel","LavaEel",
             "Cooked Lava Eel","CookedLavaEel","Lionfish","Cooked Lionfish","CookedLionfish"} },

    { key="BSementes", label="🌱 Bring Sementes",
      cor=Color3.fromRGB(135,245,115),
      desc="Chili, Berry, Flower, Firefly, Dripleaf, Moonflower, Stareweed, Cavevine, Mandrake Seeds",
      nomes={"Chili Seeds","ChiliSeeds","Flower Seeds","FlowerSeeds",
             "Berry Seeds","BerrySeeds","Firefly Seeds","FireflySeeds",
             "Dripleaf Seeds","DripleafSeeds","Moonflower Seeds","MoonflowerSeeds",
             "Stareweed Seeds","StareweedSeeds","Cavevine Seeds","CavevineSeeds",
             "Mandrake Seeds","MandrakeSeeds"} },

    { key="BFerr", label="🪓 Bring Ferramentas",
      cor=Color3.fromRGB(255,200,55),
      desc="Sacks, Axes, Rods, Flutes, Flashlights, Trim Kits",
      nomes={"Old Sack","OldSack","Good Sack","GoodSack","Infernal Sack","InfernalSack",
             "Giant Sack","GiantSack","Old Axe","OldAxe","Good Axe","GoodAxe",
             "Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw",
             "Old Rod","OldRod","Good Rod","GoodRod","Strong Rod","StrongRod",
             "Old Taming Flute","OldFlute","Good Taming Flute","GoodFlute",
             "Strong Taming Flute","StrongFlute","Old Flashlight","OldFlashlight",
             "Strong Flashlight","StrongFlashlight","Axe Trim Kit","AxeTrimKit",
             "Armor Trim Kit","ArmorTrimKit","Hammer","Paint Brush","PaintBrush",
             "Watering Can","WateringCan"} },

    { key="BArmas", label="⚔️ Bring Armas",
      cor=Color3.fromRGB(255,70,70),
      desc="Spear, Morningstar, Ice Sword, Crossbow, Revolver, Rifle, Shotgun…",
      nomes={"Spear","Morningstar","Katana","Laser Sword","LaserSword",
             "Ice Sword","IceSword","Trident","Poison Spear","PoisonSpear",
             "Infernal Sword","InfernalSword","Obsidiron Hammer","ObsidironHammer",
             "Scythe","Crossbow","Infernal Crossbow","InfernalCrossbow",
             "Bouncing Blade","BouncingBlade","Vampire Scythe","VampireScythe",
             "Revolver","Rifle","Tactical Shotgun","TacticalShotgun",
             "Ray Gun","RayGun","Laser Cannon","LaserCannon",
             "Flamethrower","Snowball","Frozen Shuriken","FrozenShuriken",
             "Kunai","Witch Potion","WitchPotion","Wildfire","Blowpipe","Air Rifle","AirRifle"} },

    { key="BAmmo", label="🔫 Bring Munição",
      cor=Color3.fromRGB(255,155,60),
      desc="Revolver Ammo, Rifle Ammo, Shotgun Ammo",
      nomes={"Revolver Ammo","RevolverAmmo","Rifle Ammo","RifleAmmo","Shotgun Ammo","ShotgunAmmo"} },

    { key="BCura", label="💊 Bring Cura",
      cor=Color3.fromRGB(100,255,180),
      desc="Bandage, Medkit",
      nomes={"Bandage","Medkit"} },

    { key="BPelts", label="🦺 Bring Pelts",
      cor=Color3.fromRGB(210,170,120),
      desc="Bunny Foot, Wolf Pelt, Bear Pelt, Arctic Fox Pelt, Mammoth Tusk…",
      nomes={"Bunny Foot","BunnyFoot","Wolf Pelt","WolfPelt","Alpha Wolf Pelt","AlphaWolfPelt",
             "Bear Pelt","BearPelt","Arctic Fox Pelt","ArcticFoxPelt",
             "Polar Bear Pelt","PolarBearPelt","Mammoth Tusk","MammothTusk",
             "Scorpion Shell","ScorpionShell","Cultist King Antler","CultistKingAntler"} },

    { key="BChaves", label="🗝️ Bring Chaves",
      cor=Color3.fromRGB(255,230,80),
      desc="Red Key, Blue Key, Yellow Key, Grey Key, Frog Key",
      nomes={"Red Key","RedKey","Blue Key","BlueKey","Yellow Key","YellowKey",
             "Grey Key","GreyKey","Frog Key","FrogKey"} },

    { key="BBigorna", label="⚙️ Bring Bigorna",
      cor=Color3.fromRGB(200,160,255),
      desc="Anvil Front/Back/Base + Meteor Anvil Parts",
      nomes={"Anvil Front","AnvilFront","Anvil Back","AnvilBack","Anvil Base","AnvilBase",
             "Meteor Anvil Front","MeteorAnvilFront","Meteor Anvil Back","MeteorAnvilBack",
             "Meteor Anvil Base","MeteorAnvilBase"} },

    { key="BPocoes", label="🧪 Bring Poções",
      cor=Color3.fromRGB(195,100,255),
      desc="Dripleaf, Moonflower Bulb, Stareweed Petal, Cave Vine Flower, Mandrake",
      nomes={"Dripleaf","Moonflower Bulb","MoonflowerBulb","Stareweed Petal","StareweedPetal",
             "Cave Vine Flower","CaveVineFlower","Mandrake"} },

    { key="BBlueprint", label="📋 Bring Blueprints",
      cor=Color3.fromRGB(130,190,255),
      desc="Crafting, Defense, Furniture, Obsidiron Chest Blueprint",
      nomes={"Crafting Blueprint","CraftingBlueprint","Defense Blueprint","DefenseBlueprint",
             "Furniture Blueprint","FurnitureBlueprint",
             "Obsidiron Chest Blueprint","ObsidironChestBlueprint",
             "Halloween Blueprint","HalloweenBlueprint"} },
}

-- Lookup bring (nome exato)
local bringLookup = {}
for _, c in ipairs(BRING_CATS) do
    local s = {}
    for _, n in ipairs(c.nomes) do s[n:lower()] = true end
    bringLookup[c.key] = s
end

-- ── Motor do Bring ────────────────────────────────────────────────
local function executarBring(key)
    local char = Player.Character; if not char then return 0 end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return 0 end
    local lookup = bringLookup[key]; if not lookup then return 0 end
    local cf = hrp.CFrame; local count = 0; local trazidos = {}; local batch = 0
    local pchars = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character then pchars[pl.Character] = true end
    end
    local ok, descs = pcall(function() return workspace:GetDescendants() end)
    if not ok then return 0 end
    for _, obj in ipairs(descs) do
        batch += 1
        if batch % 100 == 0 then
            task.wait()
            char = Player.Character; if not char then break end
            hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then break end
            cf = hrp.CFrame
        end
        pcall(function()
            if not obj or not obj.Parent then return end
            if not obj:IsA("BasePart") then return end
            if obj.Anchored then return end
            for pc in pairs(pchars) do
                if pc == obj or pc:IsAncestorOf(obj) then return end
            end
            local p = obj.Parent
            for _ = 1, 3 do
                if p and p:IsA("Model") and p:FindFirstChildWhichIsA("Humanoid") then return end
                p = p and p.Parent
            end
            if not lookup[obj.Name:lower()] then return end
            local sz = obj.Size
            if sz.X > 14 or sz.Y > 14 or sz.Z > 14 then return end
            local spread = Vector3.new(math.random(-4,4)+math.random()*0.5, 0.5, math.random(-4,4)+math.random()*0.5)
            local target = cf.Position + spread
            for _, s in ipairs(obj:GetChildren()) do
                if s:IsA("Script") or s:IsA("LocalScript") then pcall(function() s.Disabled = true end) end
            end
            obj.CFrame = CFrame.new(target); obj.Velocity = Vector3.zero; obj.CanCollide = true
            count += 1; table.insert(trazidos, {obj=obj, pos=target})
        end)
    end
    if #trazidos > 0 then
        task.spawn(function()
            for _ = 1, 8 do
                task.wait(1)
                for _, e in ipairs(trazidos) do
                    pcall(function()
                        if e.obj and e.obj.Parent and e.obj:IsA("BasePart") then
                            if (e.obj.Position - e.pos).Magnitude > 20 then
                                e.obj.CFrame = CFrame.new(e.pos); e.obj.Velocity = Vector3.zero
                            end
                        end
                    end)
                end
            end
        end)
    end
    return count
end

-- ── UI da aba BRING ───────────────────────────────────────────────
local bringTabLO = 0
local function bringLO() bringTabLO += 1; return bringTabLO end

local function makeBringSection(titulo, cor)
    local hdr = Instance.new("Frame", Pages["Bring"])
    hdr.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    hdr.BackgroundTransparency = 0.3; hdr.BorderSizePixel = 0
    hdr.Size = UDim2.new(1, 0, 0, 22); hdr.LayoutOrder = bringLO(); hdr.ZIndex = 4
    Instance.new("UICorner", hdr).CornerRadius = UDim.new(0, 6)
    local bar = Instance.new("Frame", hdr)
    bar.BackgroundColor3 = cor; bar.BorderSizePixel = 0
    bar.Position = UDim2.new(0,0,0,0); bar.Size = UDim2.new(0,3,1,0); bar.ZIndex = 5
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)
    local lbl = Instance.new("TextLabel", hdr)
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0,10,0,0)
    lbl.Size = UDim2.new(1,-14,1,0); lbl.Font = Enum.Font.GothamBlack
    lbl.Text = titulo; lbl.TextColor3 = cor; lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5
end

local function makeBringRow(bcat)
    local row = Instance.new("Frame", Pages["Bring"])
    row.BackgroundColor3 = Color3.fromRGB(22, 24, 32); row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, 48); row.LayoutOrder = bringLO(); row.ZIndex = 4
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local rStroke = Instance.new("UIStroke", row)
    rStroke.Color = Color3.fromRGB(36, 40, 52); rStroke.Thickness = 1
    local dot = Instance.new("Frame", row)
    dot.BackgroundColor3 = bcat.cor; dot.BorderSizePixel = 0
    dot.Position = UDim2.new(0,9,0.5,-5); dot.Size = UDim2.new(0,10,0,10); dot.ZIndex = 5
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local lbl = Instance.new("TextLabel", row)
    lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0,25,0,5)
    lbl.Size = UDim2.new(1,-100,0,14); lbl.Font = Enum.Font.GothamBold
    lbl.Text = bcat.label; lbl.TextColor3 = Color3.fromRGB(205,215,235)
    lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5
    local desc = Instance.new("TextLabel", row)
    desc.BackgroundTransparency = 1; desc.Position = UDim2.new(0,25,0,20)
    desc.Size = UDim2.new(1,-100,0,12); desc.Font = Enum.Font.Gotham
    desc.Text = bcat.desc or ""; desc.TextColor3 = Color3.fromRGB(75,88,108)
    desc.TextSize = 8; desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextTruncate = Enum.TextTruncate.AtEnd; desc.ZIndex = 5
    local feedback = Instance.new("TextLabel", row)
    feedback.BackgroundTransparency = 1; feedback.Position = UDim2.new(0,25,0,33)
    feedback.Size = UDim2.new(1,-100,0,12); feedback.Font = Enum.Font.GothamBold
    feedback.Text = ""; feedback.TextColor3 = bcat.cor; feedback.TextSize = 8
    feedback.TextXAlignment = Enum.TextXAlignment.Left; feedback.TextTransparency = 1; feedback.ZIndex = 5
    local btnBring = Instance.new("TextButton", row)
    btnBring.BackgroundColor3 = bcat.cor; btnBring.BackgroundTransparency = 0.15
    btnBring.BorderSizePixel = 0; btnBring.Position = UDim2.new(1,-84,0.5,-14)
    btnBring.Size = UDim2.new(0,74,0,28); btnBring.Font = Enum.Font.GothamBold
    btnBring.Text = "▼ BRING"; btnBring.TextColor3 = Color3.fromRGB(255,255,255)
    btnBring.TextSize = 9; btnBring.ZIndex = 6
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
        if running then return end; running = true
        btnBring.Text = "⏳ ..."
        TweenService:Create(rStroke, TweenInfo.new(0.12), {Color=bcat.cor}):Play()
        task.spawn(function()
            local n = executarBring(bcat.key)
            btnBring.Text = "▼ BRING"
            feedback.Text = n > 0 and ("✓ "..n.." item(s) trazido(s)") or "✗ Nenhum item encontrado"
            feedback.TextColor3 = n > 0 and bcat.cor or Color3.fromRGB(200,70,70)
            feedback.TextTransparency = 0
            task.delay(3, function()
                TweenService:Create(feedback, TweenInfo.new(0.4), {TextTransparency=1}):Play()
                task.wait(0.5); feedback.Text = ""; feedback.TextTransparency = 0
            end)
            TweenService:Create(rStroke, TweenInfo.new(0.3), {Color=Color3.fromRGB(36,40,52)}):Play()
            task.wait(2); running = false
        end)
    end)
end

-- Montar aba BRING com grupos
local bringCatMap = {}
for _, c in ipairs(BRING_CATS) do bringCatMap[c.key] = c end

local bringGroupOrder = {
    {"BRING — Combustível & Recursos", Color3.fromRGB(255,130,40),
     {"BLog","BCombust","BCarcacas","BSucata","BMateriais"}},
    {"BRING — Comida & Natureza",      Color3.fromRGB(255,120,170),
     {"BComidas","BPeixes","BSementes","BPocoes"}},
    {"BRING — Equipamentos",           Color3.fromRGB(255,200,55),
     {"BFerr","BArmas","BAmmo","BCura","BPelts"}},
    {"BRING — Especiais",              Color3.fromRGB(255,230,80),
     {"BChaves","BBigorna","BBlueprint"}},
}

for _, grp in ipairs(bringGroupOrder) do
    local titulo, cor, keys = grp[1], grp[2], grp[3]
    makeBringSection(titulo, cor)
    for _, k in ipairs(keys) do
        if bringCatMap[k] then makeBringRow(bringCatMap[k]) end
    end
end

-- Rodapé BRING
do
    local f = Instance.new("Frame", Pages["Bring"])
    f.BackgroundColor3 = Color3.fromRGB(14,30,50); f.BackgroundTransparency = 0.5
    f.BorderSizePixel = 0; f.Size = UDim2.new(1,0,0,52); f.LayoutOrder = bringLO(); f.ZIndex = 4
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local rs = Instance.new("UIStroke", f); rs.Color=Color3.fromRGB(50,120,200); rs.Thickness=1
    local rt = Instance.new("TextLabel", f)
    rt.BackgroundTransparency=1; rt.Position=UDim2.new(0,8,0,4)
    rt.Size=UDim2.new(1,-16,1,-8); rt.Font=Enum.Font.Gotham
    rt.Text="ℹ Bring só pega itens soltos (Anchored=false).\nESP só mostra entidades vivas (Health > 0).\nDados: Wiki 99 Nights in the Forest 2026."
    rt.TextColor3=Color3.fromRGB(90,165,255); rt.TextSize=8
    rt.TextWrapped=true; rt.TextXAlignment=Enum.TextXAlignment.Left
    rt.TextYAlignment=Enum.TextYAlignment.Top; rt.ZIndex=5
end

-- ══════════════════════════════
--  SELECIONAR ABA INICIAL
-- ══════════════════════════════
task.wait(0.05)
selectTab("Info")

print("╔══════════════════════════════════════════════╗")
print("║  PUDIM HUB — MERGED v4 + V3                 ║")
print("╠══════════════════════════════════════════════╣")
print("║  UI Completa V3 + ESP/BRING do Script v4    ║")
print("║  ESP: 20 categorias | Health>0 | Async      ║")
print("║  BRING: 16 botões | Anchored=false | Exact  ║")
print("║  Boost, Minimize, Maximize, Float, Sidebar  ║")
print("╚══════════════════════════════════════════════╝")
