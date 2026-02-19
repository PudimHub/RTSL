-- ╔══════════════════════════════════════════════════════════════════╗
-- ║         PUDIM HUB V3 - SCRIPT COMPLETO COM ESP                  ║
-- ║   UI Profissional + ESP 99 Dias na Floresta 2026                ║
-- ║   FIX v2: ESP async (sem freeze 4s) + Bring filtros rigorosos   ║
-- ╚══════════════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")

local Player    = Players.LocalPlayer
local Mouse     = Player:GetMouse()

-- ══════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "PudimHubV3"
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
TitleLabel.Text           = "PudimHub Discord"
TitleLabel.TextColor3     = Color3.fromRGB(88, 101, 242)
TitleLabel.TextSize       = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex         = 5

-- ══════════════════════════════
--  TOP BAR BUTTONS
-- ══════════════════════════════
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
    btn.Name                 = d.name
    btn.BackgroundTransparency = 1
    btn.Position             = UDim2.new(1, btnX - 20, 0.5, -9)
    btn.Size                 = UDim2.new(0, 18, 0, 18)
    btn.Image                = d.icon
    btn.ImageColor3          = Color3.fromRGB(160, 165, 175)
    btn.ZIndex               = 5

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
ContentArea.Name              = "ContentArea"
ContentArea.BackgroundColor3  = Color3.fromRGB(36, 38, 42)
ContentArea.Position          = UDim2.new(0, 176, 0, 40)
ContentArea.Size              = UDim2.new(1, -176, 1, -40)
ContentArea.BorderSizePixel   = 0
ContentArea.ZIndex            = 3
ContentArea.ClipsDescendants  = true

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
AvatarImg.Size     = UDim2.new(1, 0, 1, 0)
AvatarImg.Image    = "https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(Player.UserId).."&width=48&height=48&format=png"
AvatarImg.ZIndex   = 6
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
--  SISTEMA DE ABAS
-- ══════════════════════════════
local Pages   = {}
local allTabs = {}
local currentTab = nil

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
--  ÍCONES DA SIDEBAR (Frames)
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
    if radius then
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, radius)
    end
    return f
end

local function mkCircle(parent, x, y, r, color)
    return mkRect(parent, x-r, y-r, r*2, r*2, color, r*2)
end

local function createTabIcon(parent, key)
    local ic = C_ICON_IDLE
    local cont = Instance.new("Frame", parent)
    cont.BackgroundTransparency = 1
    cont.BorderSizePixel        = 0
    cont.Position               = UDim2.new(0, 8, 0.5, -10)
    cont.Size                   = UDim2.new(0, 20, 0, 20)
    cont.ZIndex                 = parent.ZIndex + 2
    cont.ClipsDescendants       = false

    local parts = {}
    local function p(f) table.insert(parts, f) return f end

    if key == "Info" then
        p(mkCircle(cont, 10, 10, 9, ic))
        local inner = mkCircle(cont, 10, 10, 7, Color3.fromRGB(24,26,32))
        inner.ZIndex = cont.ZIndex + 1
        p(mkCircle(cont, 10, 4,  2, ic))
        p(mkRect  (cont,  8, 8,  4, 8, ic, 2))
    elseif key == "Status" then
        p(mkRect(cont,  0, 12, 4, 8, ic, 1))
        p(mkRect(cont,  8,  6, 4,14, ic, 1))
        p(mkRect(cont, 16,  9, 4,11, ic, 1))
    elseif key == "Farm" then
        p(mkRect(cont, 11,  0, 5, 2, ic, 1))
        p(mkRect(cont,  6,  2, 8, 2, ic, 0))
        p(mkRect(cont,  4,  4,10, 2, ic, 0))
        p(mkRect(cont,  8,  6, 8, 2, ic, 0))
        p(mkRect(cont,  6,  8, 8, 2, ic, 0))
        p(mkRect(cont,  4, 10, 8, 2, ic, 0))
        p(mkRect(cont,  2, 12,10, 2, ic, 0))
        p(mkRect(cont,  4, 14, 6, 2, ic, 0))
        p(mkRect(cont,  3, 18, 5, 2, ic, 1))
    elseif key == "Esp" then
        p(mkRect(cont,  2,  6, 16, 8, ic, 8))
        local eyeInner = mkRect(cont, 3, 7, 14, 6, Color3.fromRGB(24,26,32), 7)
        eyeInner.ZIndex = cont.ZIndex + 1
        p(mkCircle(cont, 10, 10, 4, ic))
        local pupilInner = mkCircle(cont, 10, 10, 2, Color3.fromRGB(24,26,32))
        pupilInner.ZIndex = cont.ZIndex + 3
        p(mkCircle(cont, 12,  8, 1, Color3.fromRGB(200,220,255)))
    elseif key == "Bring" then
        p(mkRect(cont,  2,  2, 5, 12, ic, 2))
        p(mkRect(cont, 13,  2, 5, 12, ic, 2))
        p(mkRect(cont,  2,  2, 16, 5, ic, 2))
        p(mkRect(cont,  2, 14, 5,  4, Color3.fromRGB(220,60,60),  2))
        p(mkRect(cont, 13, 14, 5,  4, Color3.fromRGB(60,120,220), 2))
    elseif key == "AvancadoFarm" then
        p(mkRect(cont,  9,  14, 2, 6, ic, 1))
        p(mkRect(cont,  9,   2, 2,12, ic, 1))
        p(mkRect(cont,  3,  4,  6, 3, ic, 2))
        p(mkRect(cont, 11,  4,  6, 3, ic, 2))
        p(mkRect(cont,  3,  8,  6, 3, ic, 2))
        p(mkRect(cont, 11,  8,  6, 3, ic, 2))
        p(mkRect(cont,  6,  0,  8, 3, ic, 2))
    elseif key == "Player" then
        p(mkCircle(cont, 10,  5, 4, ic))
        p(mkRect  (cont,  5, 11, 10, 7, ic, 3))
        p(mkRect  (cont,  3, 13,  4, 7, ic, 2))
        p(mkRect  (cont, 13, 13,  4, 7, ic, 2))
    elseif key == "Configuracoes" then
        p(mkCircle(cont, 10, 10, 5, ic))
        local cInner = mkCircle(cont, 10, 10, 3, Color3.fromRGB(24,26,32))
        cInner.ZIndex = cont.ZIndex + 2
        local angles = {0,45,90,135,180,225,270,315}
        for _, deg in ipairs(angles) do
            local rad = math.rad(deg)
            local tx = 10 + math.cos(rad)*8
            local ty = 10 + math.sin(rad)*8
            p(mkRect(cont, tx-2, ty-2, 4, 4, ic, 1))
        end
    elseif key == "AvancadoFuncoes" then
        p(mkRect(cont,  1, 13, 12, 4, ic, 2))
        p(mkCircle(cont, 15, 6, 5, ic))
        local furo = mkCircle(cont, 15, 6, 3, Color3.fromRGB(24,26,32))
        furo.ZIndex = cont.ZIndex + 2
        p(mkRect(cont,  8,  9, 6, 3, ic, 1))
    end

    return cont, parts
end

local function setIconColor(parts, color)
    for _, part in ipairs(parts) do
        if part and part.Parent then
            part.BackgroundColor3 = color
        end
    end
end

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

        if Pages[e.key] then
            Pages[e.key].Visible = isThis
        end
    end
end

-- ══════════════════════════════
--  GRUPOS COLAPSÁVEIS
-- ══════════════════════════════
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
    header.Size             = UDim2.new(1, 0, 0, 24)
    header.Text             = ""
    header.LayoutOrder      = layoutOrder * 100
    header.ZIndex           = 4

    local headerLbl = Instance.new("TextLabel", header)
    headerLbl.BackgroundTransparency = 1
    headerLbl.Position       = UDim2.new(0, 4, 0, 0)
    headerLbl.Size           = UDim2.new(1, -24, 1, 0)
    headerLbl.Font           = Enum.Font.GothamBlack
    headerLbl.Text           = text
    headerLbl.TextColor3     = Color3.fromRGB(88, 101, 242)
    headerLbl.TextSize       = 8
    headerLbl.TextXAlignment = Enum.TextXAlignment.Left
    headerLbl.ZIndex         = 5

    local arrowFrame = Instance.new("Frame", header)
    arrowFrame.BackgroundTransparency = 1
    arrowFrame.Position = UDim2.new(1, -20, 0.5, -8)
    arrowFrame.Size     = UDim2.new(0, 16, 0, 16)
    arrowFrame.ZIndex   = 5

    local arrow = Instance.new("ImageLabel", arrowFrame)
    arrow.BackgroundTransparency = 1
    arrow.Size           = UDim2.new(1, 0, 1, 0)
    arrow.Image          = "rbxassetid://6034818375"
    arrow.ImageColor3    = Color3.fromRGB(88, 101, 242)
    arrow.ScaleType      = Enum.ScaleType.Fit
    arrow.Rotation       = 0
    arrow.ZIndex         = 6

    local isOpen = true

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        TweenService:Create(arrow, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Rotation = isOpen and 0 or 180
        }):Play()
        for _, entry in ipairs(groupTabs) do
            local targetSize = isOpen and UDim2.new(1, 0, 0, 36) or UDim2.new(1, 0, 0, 0)
            TweenService:Create(entry.bg, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = targetSize
            }):Play()
            entry.bg.ClipsDescendants = true
        end
    end)
end

local function makeTab(cfg, groupTabs)
    layoutOrder += 1
    local order = layoutOrder * 100

    local bg = Instance.new("Frame", SideBar)
    bg.Name                   = cfg.key.."Tab"
    bg.BackgroundColor3       = C_BG_HOV
    bg.BackgroundTransparency = 1
    bg.BorderSizePixel        = 0
    bg.Size                   = UDim2.new(1, 0, 0, 36)
    bg.LayoutOrder            = order
    bg.ZIndex                 = 4
    bg.ClipsDescendants       = true
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 7)

    local bar = Instance.new("Frame", bg)
    bar.BackgroundColor3 = C_ACCENT
    bar.BorderSizePixel  = 0
    bar.Position         = UDim2.new(0, 0, 0.2, 0)
    bar.Size             = UDim2.new(0, 3, 0.6, 0)
    bar.Visible          = false
    bar.ZIndex           = 6
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

    local icon, iconParts = createTabIcon(bg, cfg.key)

    local label = Instance.new("TextLabel", bg)
    label.BackgroundTransparency = 1
    label.Position       = UDim2.new(0, 37, 0, 0)
    label.Size           = UDim2.new(1, -42, 1, 0)
    label.Font           = Enum.Font.GothamSemibold
    label.Text           = cfg.label
    label.TextColor3     = C_TEXT_OFF
    label.TextSize       = 11
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate   = Enum.TextTruncate.AtEnd
    label.ZIndex         = 6

    local btn = Instance.new("TextButton", bg)
    btn.BackgroundTransparency = 1
    btn.Size    = UDim2.new(1, 0, 1, 0)
    btn.Text    = ""
    btn.ZIndex  = 7

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

    btn.MouseButton1Click:Connect(function()
        selectTab(cfg.key)
    end)

    local entry = { key=cfg.key, bg=bg, icon=icon, iconParts=iconParts, label=label, bar=bar }
    table.insert(allTabs,   entry)
    table.insert(groupTabs, entry)
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

local effectsOff = false
local hidEffects = {}
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

local npcOff  = false
local hidNPCs = {}
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

local lagOff  = false
local origSet = {}
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
--  POPUP DE BOOST
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
bpPad.PaddingTop=UDim.new(0,8) bpPad.PaddingLeft=UDim.new(0,8) bpPad.PaddingRight=UDim.new(0,8) bpPad.PaddingBottom=UDim.new(0,8)

local popupOpen = false
local function toggleBoostPopup()
    popupOpen = not popupOpen
    if popupOpen then
        local pos = TopBtns["Theme"].AbsolutePosition
        BoostPopup.Position = UDim2.new(0, pos.X - 160, 0, pos.Y + 26)
        BoostPopup.Size     = UDim2.new(0, 190, 0, 0)
        BoostPopup.Visible  = true
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
    row.BackgroundColor3 = Color3.fromRGB(38, 41, 48)
    row.BorderSizePixel  = 0
    row.Size             = UDim2.new(1, 0, 0, 32)
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel", row)
    lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,8,0,0) lbl.Size=UDim2.new(1,-50,1,0)
    lbl.Font=Enum.Font.GothamSemibold lbl.Text=text lbl.TextColor3=Color3.fromRGB(190,195,205)
    lbl.TextSize=10 lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=201

    local pill = Instance.new("Frame", row)
    pill.BackgroundColor3 = Color3.fromRGB(60,65,75)
    pill.BorderSizePixel  = 0
    pill.Position         = UDim2.new(1,-42,0.5,-10)
    pill.Size             = UDim2.new(0,36,0,20)
    pill.ZIndex           = 201
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)

    local knob = Instance.new("Frame", pill)
    knob.BackgroundColor3 = Color3.fromRGB(200,205,215)
    knob.BorderSizePixel  = 0
    knob.Position         = UDim2.new(0,2,0.5,-8)
    knob.Size             = UDim2.new(0,16,0,16)
    knob.ZIndex           = 202
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

    local state = false
    local btn = Instance.new("TextButton", row)
    btn.BackgroundTransparency=1 btn.Size=UDim2.new(1,0,1,0) btn.Text="" btn.ZIndex=203
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
rejBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 55)
rejBtn.BorderSizePixel  = 0
rejBtn.Size             = UDim2.new(1, 0, 0, 32)
rejBtn.Font             = Enum.Font.GothamBold
rejBtn.Text             = "🔄  REJOIN SERVER"
rejBtn.TextColor3       = Color3.fromRGB(255,255,255)
rejBtn.TextSize         = 11
rejBtn.ZIndex           = 201
Instance.new("UICorner", rejBtn).CornerRadius = UDim.new(0, 7)
rejBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
end)

-- ══════════════════════════════
--  BOTÃO FLUTUANTE PUDIM
-- ══════════════════════════════
local FloatBtn = Instance.new("Frame", ScreenGui)
FloatBtn.Name                  = "FloatBtn"
FloatBtn.Size                  = UDim2.new(0, 68, 0, 68)
FloatBtn.Position              = UDim2.new(0.05, 0, 0.08, 0)
FloatBtn.BackgroundColor3      = Color3.fromRGB(12, 13, 20)
FloatBtn.BorderSizePixel       = 0
FloatBtn.Visible               = false
FloatBtn.ZIndex                = 100
FloatBtn.Active                = true
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local FloatRing = Instance.new("UIStroke", FloatBtn)
FloatRing.Color     = Color3.fromRGB(88, 101, 242)
FloatRing.Thickness = 2.2

local FloatGrad = Instance.new("UIGradient", FloatBtn)
FloatGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 24, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 11, 18)),
})
FloatGrad.Rotation = 135

local PDText = Instance.new("TextLabel", FloatBtn)
PDText.BackgroundTransparency = 1
PDText.Position    = UDim2.new(0, 0, 0, 0)
PDText.Size        = UDim2.new(1, 0, 1, 0)
PDText.Font        = Enum.Font.GothamBlack
PDText.Text        = "PD"
PDText.TextColor3  = Color3.fromRGB(220, 225, 255)
PDText.TextSize    = 20
PDText.TextTransparency = 0.05
PDText.ZIndex      = 105
local PDStroke = Instance.new("UIStroke", PDText)
PDStroke.Color       = Color3.fromRGB(88, 101, 242)
PDStroke.Thickness   = 1.5
PDStroke.Transparency= 0.3

local FloatClick = Instance.new("TextButton", FloatBtn)
FloatClick.BackgroundTransparency = 1
FloatClick.Size   = UDim2.new(1, 0, 1, 0)
FloatClick.Text   = ""
FloatClick.ZIndex = 110

FloatClick.MouseEnter:Connect(function()
    TweenService:Create(FloatRing, TweenInfo.new(0.2), {Color=Color3.fromRGB(160,170,255), Thickness=3}):Play()
end)
FloatClick.MouseLeave:Connect(function()
    TweenService:Create(FloatRing, TweenInfo.new(0.2), {Color=Color3.fromRGB(88,101,242), Thickness=2.2}):Play()
end)

local function showFloatBtn()
    FloatBtn.Size     = UDim2.new(0, 0, 0, 0)
    FloatBtn.Position = UDim2.new(0.05, 34, 0.08, 34)
    FloatBtn.Visible  = true
    TweenService:Create(FloatBtn, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size     = UDim2.new(0, 68, 0, 68),
        Position = UDim2.new(0.05, 0, 0.08, 0),
    }):Play()
end

FloatClick.MouseButton1Click:Connect(function()
    TweenService:Create(FloatBtn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.05, 34, 0.08, 34),
    }):Play()
    task.delay(0.22, function()
        FloatBtn.Visible  = false
        FloatBtn.Size     = UDim2.new(0, 68, 0, 68)
        FloatBtn.Position = UDim2.new(0.05, 0, 0.08, 0)
        MainFrame.Visible = true
        MainFrame.Size    = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 540, 0, 370)
        }):Play()
    end)
end)

-- ══════════════════════════════
--  TOPBAR BUTTON ACTIONS
-- ══════════════════════════════
TopBtns["Theme"].MouseButton1Click:Connect(function()
    toggleBoostPopup()
end)

local isMinimized = false
TopBtns["Minimize"].MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad),
            {Size = UDim2.new(0, 540, 0, 40)}):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad),
            {Size = UDim2.new(0, 540, 0, 370)}):Play()
    end
end)

local isMaximized = false
local normalSize  = UDim2.new(0, 540, 0, 370)
local normalPos   = MainFrame.Position
TopBtns["Maximize"].MouseButton1Click:Connect(function()
    isMaximized = not isMaximized
    if isMaximized then
        normalPos = MainFrame.Position
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size     = UDim2.new(0, 760, 0, 500),
            Position = UDim2.new(0.5, -380, 0.5, -250),
        }):Play()
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size     = normalSize,
            Position = normalPos,
        }):Play()
    end
end)

TopBtns["Close"].MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad),
        {Size = UDim2.new(0, 540, 0, 0)}):Play()
    task.delay(0.22, function()
        MainFrame.Visible = false
        MainFrame.Size    = UDim2.new(0, 540, 0, 370)
        showFloatBtn()
    end)
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not popupOpen then return end
    local mp = UserInputService:GetMouseLocation()
    local ap, as = BoostPopup.AbsolutePosition, BoostPopup.AbsoluteSize
    if mp.X < ap.X or mp.X > ap.X+as.X or mp.Y < ap.Y or mp.Y > ap.Y+as.Y then
        toggleBoostPopup()
    end
end)

-- ══════════════════════════════════════════════════════════════════════════
--  ██████████  ESP SYSTEM — FIX v2 (async cache sem freeze)  ██████████
--
--  PROBLEMA ORIGINAL: updateCache() chamava workspace:GetDescendants()
--  de forma SÍNCRONA no thread principal a cada 4s → congelava o jogo.
--
--  FIX APLICADO:
--   • updateCache agora roda em task.spawn() (thread separado)
--   • Yield a cada 150 objetos processados (task.wait())
--   • Flag espCacheBuilding impede múltiplas rebuilds simultâneas
--   • Intervalo aumentado para 6s (suficiente para o jogo)
-- ══════════════════════════════════════════════════════════════════════════

local EspGui = Instance.new("ScreenGui")
EspGui.Name            = "PudimESP_Overlay"
EspGui.Parent          = game.CoreGui
EspGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
EspGui.DisplayOrder    = 997
EspGui.ResetOnSpawn    = false
EspGui.IgnoreGuiInset  = true

local EspCanvas = Instance.new("Frame", EspGui)
EspCanvas.BackgroundTransparency = 1
EspCanvas.Size = UDim2.new(1, 0, 1, 0)
EspCanvas.ZIndex = 1

local Cam = workspace.CurrentCamera

local ESP_CFG = {
    { key="Players",    label="ESP Players",         cor=Color3.fromRGB(255, 70,  70),  alcance=math.huge, desc="Todos os players | Sem limite" },
    { key="Animals",    label="ESP Animais",          cor=Color3.fromRGB(255, 215,  0),  alcance=625,       desc="Lobos, Ursos, Coelhos… | 625 studs" },
    { key="Children",   label="ESP Crianças",         cor=Color3.fromRGB(100, 200, 255), alcance=math.huge, desc="Missing Kids | Sem limite" },
    { key="Trees",      label="ESP Árvores",          cor=Color3.fromRGB(80,  210,  80), alcance=450,       desc="Todas as árvores | 450 studs" },
    { key="Equipment",  label="ESP Equipamentos",     cor=Color3.fromRGB(255, 165,  30), alcance=500,       desc="Armas, Machados, Ferramentas | 500 studs" },
    { key="Food",       label="ESP Comidas",          cor=Color3.fromRGB(255, 110, 160), alcance=500,       desc="Carnes, Frutas, Sopas… | 500 studs" },
    { key="Seeds",      label="ESP Sementes",         cor=Color3.fromRGB(140, 240, 120), alcance=400,       desc="Mudas, Sementes | 400 studs" },
    { key="Camp",       label="ESP Acampamento",      cor=Color3.fromRGB(255, 200,  60), alcance=math.huge, desc="Fogueiras e Bases | Sem limite" },
    { key="Structures", label="ESP Estruturas",       cor=Color3.fromRGB(180, 140, 255), alcance=600,       desc="Torres, Cabanas, Ruínas | 600 studs" },
    { key="Biomes",     label="ESP Biomas",           cor=Color3.fromRGB(0,   200, 230), alcance=math.huge, desc="Neve, Vulcão, Floresta… | Sem limite" },
    { key="Fuel",       label="ESP Combustível",      cor=Color3.fromRGB(255, 100,  30), alcance=400,       desc="Madeira, Carvão, Carcaças | 400 studs" },
    { key="Metals",     label="ESP Metais/Sucata",    cor=Color3.fromRGB(170, 225, 255), alcance=400,       desc="Gemas, Sucata, Minérios | 400 studs" },
}

local KEYWORDS = {
    Animals = {
        "Wolf","Alpha","Bear","Deer","Rabbit","Fox","Mammoth","Boar","Elk","Moose",
        "Lobo","Urso","Cervo","Coelho","Raposa","Mamute","Javali","Alce",
        "PolarBear","ArcticFox","Ram","Owl","Cultist","NightCreature","WildBoar",
        "AlphaWolf","NpcWolf","NpcBear","NpcRabbit","WolfAlpha","BossAnimal",
        "Bison","Snake","Serpent","Wolverine","Lynx","Puma","MeteorCrab",
    },
    Children = {
        "Child","Kid","MissingKid","MissingChild","Children","Crianca","Criança",
        "RescueKid","FoundChild","KidModel","ChildModel","LostKid","Hostage",
        "Child1","Child2","Child3","Child4","Child5","Kid1","Kid2","Kid3",
    },
    Trees = {
        "Tree","Pine","Oak","Birch","Spruce","Fir","Maple","Willow","Baobab",
        "TreeModel","TreePart","ForestTree","BigTree","SmallTree",
        "PineTree","BirchTree","OakTree","SpruceTree","StumpTree","DeadTree","SnowTree",
        "TropicalTree","PalmTree","BambooTree","Treetrunk","Woodpile",
    },
    Equipment = {
        "OldAxe","GoodAxe","IceAxe","TrimAxe","LumberAxe","SteelAxe","GoldenAxe","Axe","Hatchet",
        "Sword","Spear","Bow","Crossbow","Mace","Dagger","Knife","Staff","Club",
        "ShadowDagger","InfernoCrossbow","BoneSword","StoneSword","WoodSpear",
        "CultistMace","LightningRod","FishingRod","OldRod","GoodRod",
        "Flashlight","Lantern","Torch","Flute","WoodFlute","BoneFlute","CrystalFlute",
        "Armor","Shield","Helmet","Chestplate","Leggings","Boots",
        "TrimKit","OldSack","GoodSack","GiantSack","InfernalSack",
        "Bandage","HealingKit","MedKit",
    },
    Food = {
        "Apple","Berry","Blueberry","Mushroom","Potato","Carrot","Wheat","Corn","Pumpkin",
        "Meat","RabbitMeat","WolfMeat","BearMeat","DeerMeat","FoxMeat","CookedMeat","RawMeat",
        "Fish","CookedFish","RawFish",
        "Soup","Stew","Broth","Porridge","Pie","Bread","Cake",
        "RareCrop","RarePlant","GoldenApple","BerryBush","HealFood",
        "Food","Comida","Snack","Ration","CookedFood",
    },
    Seeds = {
        "Seed","TreeSeed","CropSeed","PlantSeed","SeedPack","SeedBag",
        "Semente","Muda","TreeSapling","Seedling","Sprout",
        "CarrotSeed","PotatoSeed","WheatSeed","CornSeed","PumpkinSeed",
        "ForestSeed","WinterSeed","RareSeed","MagicSeed",
    },
    Camp = {
        "Campfire","Fogueira","Bonfire","BaseFireplace","FireBase","HomeFire",
        "Campfire_Lv1","Campfire_Lv2","Campfire_Lv3","Campfire_Lv4","Campfire_Lv5",
        "CampBase","PlayerBase","HomeBase","BaseModel","BaseCamp",
        "Bed","Cama","SleepingBag","Hammock","BunkBed",
        "CraftingBench","WorkBench","Bancada","Anvil","BigAnvil",
        "StorageBox","StorageChest","PlayerChest",
        "WallBase","FenceBase","Gate",
    },
    Structures = {
        "Watchtower","ObservationTower","WatchTower","Lookout","Torre","Tower",
        "Cabin","Hut","House","Shack","Shed","Choupana","Cabana","Barraca",
        "EnemyCamp","CultistBase","CultistCamp","EnemyStructure","HostileBase",
        "Ruins","OldStructure","AbandonedBuilding","AbandonedHouse",
        "FairyShrine","Shrine","Altar","Santuario",
        "Bunker","Underground","Cave","Caverna","Gruta","Toca",
        "Volcano","Vulcao","VolcanoArea","VolcanicStructure",
    },
    Biomes = {
        "SnowBiome","SnowArea","WinterBiome","WinterZone","SnowZone","TundraZone",
        "TundraArea","IceBiome","FrozenArea",
        "ForestBiome","ForestArea","WoodsBiome",
        "CaveArea","CaveBiome","UndergroundBiome","CavernArea",
        "LakeArea","LakeBiome","WaterBiome","SwampArea",
        "VolcanicBiome","VolcanoZone","LavaBiome","FireBiome",
        "MountainBiome","MountainArea","HighlandBiome","SnowyMountain",
        "CrashSite","MeteorCrashArea","UFOArea","CrashArea",
        "GraveyardArea","CemeteryBiome","DarkForest","ShadowZone",
    },
    Fuel = {
        "Log","Tronco","Wood","Madeira","Plank","WoodLog","LogPile",
        "Firewood","Lenha","Lumber","Timber",
        "Coal","Carvao","Carvão","Charcoal","CoalPile","CoalChunk",
        "Carcass","CarcacaLobo","AlphaCarcass","WolfCarcass","BearCarcass","CultistBody",
        "DryLog","RottenLog","PineLog","OakLog","BigLog",
        "SticksBundle","Sticks","Gravetos","Galhos",
        "FireCrystal","FireGem","LavaRock","VolcanicRock",
    },
    Metals = {
        "Scrap","Sucata","Metal","ScrapMetal","SheetMetal",
        "Bolt","BrokenFan","BrokenRadio","OldRadio","MetalChair",
        "BrokenMicrowave","Tire","UFOJunk","UFOComponent","OldEngine","MetalPipe","Pipe",
        "Stone","Pedra","Rock","Ore","Minerio","RockChunk",
        "IronOre","CopperOre","GoldOre","SilverOre",
        "Gem","Gema","Crystal","Cristal","CultistGem","ForestGem","GemFragment",
        "IronBar","CopperBar","GoldBar","SteelBar","MetalBar",
        "AncientMetal","DarkMetal","VoidCrystal","ShadowGem","LavaGem",
    },
}

local espAtivo = {}
for _, cfg in ipairs(ESP_CFG) do espAtivo[cfg.key] = false end

-- ── Ícones ESP ──
local function criarIconeEsp(parent, key, cor)
    local cont = Instance.new("Frame", parent)
    cont.BackgroundTransparency = 1
    cont.BorderSizePixel = 0
    cont.Size = UDim2.new(0, 14, 0, 14)
    cont.ZIndex = parent.ZIndex + 2
    cont.ClipsDescendants = false

    local function r(x, y, w, h, radius)
        local f = Instance.new("Frame", cont)
        f.BackgroundColor3 = cor
        f.BorderSizePixel  = 0
        f.Position = UDim2.new(0, x, 0, y)
        f.Size     = UDim2.new(0, w, 0, h)
        f.ZIndex   = cont.ZIndex + 1
        if radius then Instance.new("UICorner", f).CornerRadius = UDim.new(0, radius) end
        return f
    end
    local function c(cx, cy, rad) return r(cx-rad, cy-rad, rad*2, rad*2, rad*2) end

    if key == "Players" then
        c(7, 4, 3) r(4, 8, 6, 5, 2) r(4, 13, 2, 5, 1) r(8, 13, 2, 5, 1)
    elseif key == "Animals" then
        c(3, 3, 2) c(7, 2, 2) c(11, 3, 2) c(7, 9, 4)
    elseif key == "Children" then
        c(7, 3, 3) r(4, 7, 6, 4, 2) r(3, 12, 2, 4, 1) r(9, 12, 2, 4, 1)
        r(1, 8, 2, 2, 1) r(11, 8, 2, 2, 1)
    elseif key == "Trees" then
        r(5, 0, 4, 4, 1) r(3, 4, 8, 4, 1) r(1, 8, 12, 4, 1) r(5, 12, 4, 5, 1)
    elseif key == "Equipment" then
        r(6, 0, 2, 10, 1) r(2, 9, 10, 2, 1) r(5, 11, 4, 4, 1)
    elseif key == "Food" then
        c(7, 8, 5) r(6, 2, 2, 3, 1) r(8, 2, 4, 3, 2)
    elseif key == "Seeds" then
        c(7, 2, 2) c(2, 7, 2) c(12, 7, 2) c(7, 12, 2) c(7, 7, 2)
    elseif key == "Camp" then
        r(5, 4, 4, 6, 3) r(3, 7, 3, 5, 2) r(8, 7, 3, 5, 2) r(1, 12, 12, 2, 1)
    elseif key == "Structures" then
        r(5, 0, 4, 4, 1) r(2, 4, 10, 2, 1) r(2, 6, 10, 8, 0) r(5, 10, 4, 4, 0)
    elseif key == "Biomes" then
        c(7, 7, 6)
        local eq = r(1, 6, 12, 2, 0) eq.BackgroundTransparency = 0.5
        local mer = r(6, 1, 2, 12, 0) mer.BackgroundTransparency = 0.5
    elseif key == "Fuel" then
        r(1, 5, 12, 4, 3) r(3, 7, 8, 1, 0) r(5, 0, 4, 4, 2)
    elseif key == "Metals" then
        r(5, 0, 4, 2, 0) r(2, 2, 10, 5, 1) r(4, 7, 6, 4, 1) r(6, 11, 2, 3, 1)
    end

    return cont
end

-- ── Pool de Labels ──
local POOL_SIZE  = 80
local labelPool  = {}
local activeList = {}

local function buildPoolFrame()
    local frame = Instance.new("Frame", EspCanvas)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.Size  = UDim2.new(0, 185, 0, 26)
    frame.ZIndex = 10
    frame.Visible = false

    local bg = Instance.new("Frame", frame)
    bg.Name = "Bg"
    bg.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    bg.BackgroundTransparency = 0.45
    bg.BorderSizePixel = 0
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.ZIndex = 10
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 5)

    local iconHolder = Instance.new("Frame", frame)
    iconHolder.Name = "IconHolder"
    iconHolder.BackgroundTransparency = 1
    iconHolder.BorderSizePixel = 0
    iconHolder.Position = UDim2.new(0, 3, 0.5, -7)
    iconHolder.Size = UDim2.new(0, 14, 0, 14)
    iconHolder.ZIndex = 11

    local nameLbl = Instance.new("TextLabel", frame)
    nameLbl.Name = "NameLabel"
    nameLbl.BackgroundTransparency = 1
    nameLbl.Position = UDim2.new(0, 20, 0, 1)
    nameLbl.Size     = UDim2.new(1, -22, 0, 14)
    nameLbl.Font     = Enum.Font.GothamBold
    nameLbl.TextSize = 11
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextStrokeTransparency = 0.2
    nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = 12

    local distLbl = Instance.new("TextLabel", frame)
    distLbl.Name = "DistLabel"
    distLbl.BackgroundTransparency = 1
    distLbl.Position = UDim2.new(0, 20, 0, 14)
    distLbl.Size     = UDim2.new(1, -22, 0, 10)
    distLbl.Font     = Enum.Font.Gotham
    distLbl.TextSize = 9
    distLbl.TextColor3 = Color3.fromRGB(185, 195, 210)
    distLbl.TextXAlignment = Enum.TextXAlignment.Left
    distLbl.TextStrokeTransparency = 0.3
    distLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLbl.ZIndex = 12

    return frame
end

for i = 1, POOL_SIZE do
    table.insert(labelPool, buildPoolFrame())
end

local function getLabel(key, cor, nome, dist, posX, posY)
    local frame = table.remove(labelPool)
    if not frame then return nil end

    frame.Position = UDim2.new(0, posX - 92, 0, posY - 13)
    frame.Visible = true

    local nl = frame:FindFirstChild("NameLabel")
    local dl = frame:FindFirstChild("DistLabel")

    if nl then nl.Text = nome; nl.TextColor3 = cor end
    if dl then dl.Text = string.format("%.0f studs", dist) end

    local holder = frame:FindFirstChild("IconHolder")
    if holder then
        local curKey = holder:GetAttribute("EspKey")
        if curKey ~= key then
            for _, c in ipairs(holder:GetChildren()) do c:Destroy() end
            criarIconeEsp(holder, key, cor)
            holder:SetAttribute("EspKey", key)
        else
            for _, c in ipairs(holder:GetDescendants()) do
                if c:IsA("Frame") and c.BackgroundTransparency < 0.9 then
                    c.BackgroundColor3 = cor
                end
            end
        end
    end

    table.insert(activeList, frame)
    return frame
end

local function returnAllActive()
    for _, frame in ipairs(activeList) do
        frame.Visible = false
        table.insert(labelPool, frame)
    end
    activeList = {}
end

-- ══════════════════════════════════════════════════════════════════
--  FIX: updateCache ASSÍNCRONO
--  ▸ Roda em task.spawn() → não bloqueia o thread principal
--  ▸ Yield a cada 150 objetos → frames não congelam
--  ▸ Flag espCacheBuilding → sem builds simultâneas
--  ▸ Intervalo: 6 segundos (antes era 4s, que ainda congelava)
-- ══════════════════════════════════════════════════════════════════
local objectCache      = {}
local lastCacheTime    = 0
local CACHE_INTERVAL   = 6       -- FIX: 6s é suficiente e menos pesado
local espCacheBuilding = false   -- FIX: flag anti-sobreposição de builds

local function matchKeywords(name, lista)
    if not name then return false end
    local lower = name:lower()
    for _, kw in ipairs(lista) do
        if lower:find(kw:lower(), 1, true) then return true end
    end
    return false
end

local function getObjPos(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        local firstPart = obj:FindFirstChildWhichIsA("BasePart", true)
        if firstPart then return firstPart.Position end
        local ok, cf = pcall(function() return obj:GetModelCFrame() end)
        if ok and cf then return cf.Position end
    end
    return nil
end

local function updateCache()
    local now = tick()
    if now - lastCacheTime < CACHE_INTERVAL then return end
    if espCacheBuilding then return end   -- FIX: já está buildando, aguarda

    lastCacheTime    = now
    espCacheBuilding = true

    -- FIX PRINCIPAL: task.spawn → roda em paralelo, não congela o jogo
    task.spawn(function()
        local newCache = {}

        local anyActive = false
        for _, cfg in ipairs(ESP_CFG) do
            if cfg.key ~= "Players" and espAtivo[cfg.key] then anyActive = true; break end
        end

        if not anyActive then
            objectCache      = newCache
            espCacheBuilding = false
            return
        end

        local ok, descendants = pcall(function() return workspace:GetDescendants() end)
        if not ok then
            espCacheBuilding = false
            return
        end

        local batch = 0
        for _, obj in ipairs(descendants) do
            batch += 1
            -- FIX: yield a cada 150 objetos → frames fluidos
            if batch % 150 == 0 then
                task.wait()
            end

            if not obj or not obj.Parent then continue end
            local name = obj.Name
            if not name or name == "" then continue end

            -- Pula personagens de players
            local isPlayerChar = false
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl.Character == obj or (pl.Character and pl.Character:IsAncestorOf(obj)) then
                    isPlayerChar = true; break
                end
            end
            if isPlayerChar then continue end

            for _, cfg in ipairs(ESP_CFG) do
                if cfg.key == "Players" then continue end
                if not espAtivo[cfg.key] then continue end
                local kws = KEYWORDS[cfg.key]
                if not kws then continue end
                if matchKeywords(name, kws) then
                    local pos = getObjPos(obj)
                    if pos then
                        table.insert(newCache, {
                            key=cfg.key, cor=cfg.cor, nome=name,
                            pos=pos, alcance=cfg.alcance, obj=obj,
                        })
                    end
                    break
                end
            end
        end

        -- Só substitui o cache quando a varredura terminou completamente
        objectCache      = newCache
        espCacheBuilding = false
    end)
end

-- ── Loop de renderização (20fps via Heartbeat) ──
local espConn
local espDeltaAcc      = 0
local ESP_RENDER_INTERVAL = 1/20

local function iniciarESP()
    if espConn then espConn:Disconnect() end
    espDeltaAcc = 0

    espConn = RunService.Heartbeat:Connect(function(dt)
        espDeltaAcc += dt
        if espDeltaAcc < ESP_RENDER_INTERVAL then return end
        espDeltaAcc = 0

        returnAllActive()

        local qualquerAtivo = false
        for _, cfg in ipairs(ESP_CFG) do
            if espAtivo[cfg.key] then qualquerAtivo = true; break end
        end
        if not qualquerAtivo then return end

        -- Dispara atualização de cache (roda assíncrono, não trava aqui)
        pcall(updateCache)

        local charPos = Vector3.new(0, 0, 0)
        pcall(function()
            local c = Player.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                charPos = c.HumanoidRootPart.Position
            end
        end)

        local vp = Cam.ViewportSize

        if espAtivo.Players then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl == Player then continue end
                pcall(function()
                    if not pl.Character then return end
                    local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    local dist = (hrp.Position - charPos).Magnitude
                    local screenPos, onScreen = Cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.8, 0))
                    if not onScreen then return end
                    if screenPos.X < -50 or screenPos.X > vp.X + 50 then return end
                    if screenPos.Y < -30 or screenPos.Y > vp.Y + 30 then return end
                    getLabel("Players", Color3.fromRGB(255,70,70), pl.DisplayName, dist, screenPos.X, screenPos.Y)
                end)
            end
        end

        local seen = {}
        for _, entry in ipairs(objectCache) do
            pcall(function()
                if not espAtivo[entry.key] then return end
                if not entry.obj or not entry.obj.Parent then return end
                local pos = getObjPos(entry.obj)
                if not pos then return end
                local dist = (pos - charPos).Magnitude
                if dist > entry.alcance then return end
                local screenPos, onScreen = Cam:WorldToViewportPoint(pos + Vector3.new(0, 1.5, 0))
                if not onScreen then return end
                if screenPos.X < -50 or screenPos.X > vp.X + 50 then return end
                if screenPos.Y < -30 or screenPos.Y > vp.Y + 30 then return end
                local key2d = math.floor(screenPos.X / 10)..","..math.floor(screenPos.Y / 10)
                if seen[key2d] then return end
                seen[key2d] = true
                getLabel(entry.key, entry.cor, entry.nome, dist, screenPos.X, screenPos.Y)
            end)
        end
    end)
end

iniciarESP()

-- ── Interface ESP na aba ──
local espPageTitle = Instance.new("TextLabel", Pages["Esp"])
espPageTitle.BackgroundTransparency = 1
espPageTitle.Size     = UDim2.new(1, -8, 0, 20)
espPageTitle.Font     = Enum.Font.GothamBlack
espPageTitle.Text     = "ESP — 99 Dias na Floresta"
espPageTitle.TextColor3 = Color3.fromRGB(88, 101, 242)
espPageTitle.TextSize = 13
espPageTitle.TextXAlignment = Enum.TextXAlignment.Left
espPageTitle.LayoutOrder = 0
espPageTitle.ZIndex = 5

local espSubtitle = Instance.new("TextLabel", Pages["Esp"])
espSubtitle.BackgroundTransparency = 1
espSubtitle.Size     = UDim2.new(1, -8, 0, 14)
espSubtitle.Font     = Enum.Font.Gotham
espSubtitle.Text     = "Ative/desative cada categoria de ESP abaixo"
espSubtitle.TextColor3 = Color3.fromRGB(90, 100, 120)
espSubtitle.TextSize = 9
espSubtitle.TextXAlignment = Enum.TextXAlignment.Left
espSubtitle.LayoutOrder = 1
espSubtitle.ZIndex = 5

local espSep = Instance.new("Frame", Pages["Esp"])
espSep.BackgroundColor3 = Color3.fromRGB(50, 54, 65)
espSep.BorderSizePixel  = 0
espSep.Size = UDim2.new(1, -8, 0, 1)
espSep.LayoutOrder = 2
espSep.ZIndex = 5

local espRowOrder = 3

local function makeEspToggleRow(cfg)
    espRowOrder += 1

    local row = Instance.new("Frame", Pages["Esp"])
    row.BackgroundColor3    = Color3.fromRGB(30, 32, 38)
    row.BorderSizePixel     = 0
    row.Size                = UDim2.new(1, -8, 0, 54)
    row.LayoutOrder         = espRowOrder
    row.ZIndex              = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color     = Color3.fromRGB(45, 48, 58)
    rowStroke.Thickness = 1

    local iconContainer = Instance.new("Frame", row)
    iconContainer.BackgroundColor3    = Color3.fromRGB(20, 22, 30)
    iconContainer.BackgroundTransparency = 0.3
    iconContainer.BorderSizePixel     = 0
    iconContainer.Position            = UDim2.new(0, 8, 0.5, -16)
    iconContainer.Size                = UDim2.new(0, 32, 0, 32)
    iconContainer.ZIndex              = 6
    Instance.new("UICorner", iconContainer).CornerRadius = UDim.new(0, 7)

    local miniIcon = criarIconeEsp(iconContainer, cfg.key, cfg.cor)
    miniIcon.Position = UDim2.new(0, 9, 0, 9)
    miniIcon.Size     = UDim2.new(0, 14, 0, 14)

    local labelNome = Instance.new("TextLabel", row)
    labelNome.BackgroundTransparency = 1
    labelNome.Position       = UDim2.new(0, 50, 0, 8)
    labelNome.Size           = UDim2.new(1, -110, 0, 16)
    labelNome.Font           = Enum.Font.GothamBold
    labelNome.Text           = cfg.label
    labelNome.TextColor3     = Color3.fromRGB(220, 225, 240)
    labelNome.TextSize       = 11
    labelNome.TextXAlignment = Enum.TextXAlignment.Left
    labelNome.ZIndex         = 6

    local labelDesc = Instance.new("TextLabel", row)
    labelDesc.BackgroundTransparency = 1
    labelDesc.Position       = UDim2.new(0, 50, 0, 26)
    labelDesc.Size           = UDim2.new(1, -110, 0, 20)
    labelDesc.Font           = Enum.Font.Gotham
    labelDesc.Text           = cfg.desc
    labelDesc.TextColor3     = Color3.fromRGB(90, 100, 120)
    labelDesc.TextSize       = 9
    labelDesc.TextXAlignment = Enum.TextXAlignment.Left
    labelDesc.TextWrapped    = true
    labelDesc.ZIndex         = 6

    local pill = Instance.new("Frame", row)
    pill.BackgroundColor3 = Color3.fromRGB(45, 50, 62)
    pill.BorderSizePixel  = 0
    pill.Position         = UDim2.new(1, -52, 0.5, -11)
    pill.Size             = UDim2.new(0, 42, 0, 22)
    pill.ZIndex           = 7
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame", pill)
    knob.BackgroundColor3 = Color3.fromRGB(160, 170, 185)
    knob.BorderSizePixel  = 0
    knob.Position         = UDim2.new(0, 2, 0.5, -9)
    knob.Size             = UDim2.new(0, 18, 0, 18)
    knob.ZIndex           = 8
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local estado = false

    local btn = Instance.new("TextButton", row)
    btn.BackgroundTransparency = 1
    btn.Size   = UDim2.new(1, 0, 1, 0)
    btn.Text   = ""
    btn.ZIndex = 9

    btn.MouseEnter:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(34,37,45)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(30,32,38)}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        estado = not estado
        espAtivo[cfg.key] = estado

        TweenService:Create(pill, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
            BackgroundColor3 = estado and cfg.cor or Color3.fromRGB(45,50,62)
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = estado and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
            BackgroundColor3 = estado and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185),
        }):Play()
        TweenService:Create(rowStroke, TweenInfo.new(0.2), {
            Color = estado and cfg.cor or Color3.fromRGB(45,48,58)
        }):Play()

        lastCacheTime = 0
    end)
end

for _, cfg in ipairs(ESP_CFG) do
    makeEspToggleRow(cfg)
    espRowOrder += 1
    local miniSep = Instance.new("Frame", Pages["Esp"])
    miniSep.BackgroundTransparency = 1
    miniSep.Size = UDim2.new(1, 0, 0, 2)
    miniSep.LayoutOrder = espRowOrder
end

espRowOrder += 1
local aviso = Instance.new("Frame", Pages["Esp"])
aviso.BackgroundColor3 = Color3.fromRGB(60, 40, 20)
aviso.BackgroundTransparency = 0.4
aviso.BorderSizePixel = 0
aviso.Size = UDim2.new(1, -8, 0, 44)
aviso.LayoutOrder = espRowOrder
aviso.ZIndex = 5
Instance.new("UICorner", aviso).CornerRadius = UDim.new(0, 8)
local avisoStroke = Instance.new("UIStroke", aviso)
avisoStroke.Color = Color3.fromRGB(200, 130, 30)
avisoStroke.Thickness = 1
local avisoText = Instance.new("TextLabel", aviso)
avisoText.BackgroundTransparency = 1
avisoText.Position = UDim2.new(0, 8, 0, 4)
avisoText.Size     = UDim2.new(1, -16, 1, -8)
avisoText.Font     = Enum.Font.Gotham
avisoText.Text     = "NOTA: ESP detecta objetos pelo nome no workspace. Atualizações do jogo podem renomear itens."
avisoText.TextColor3 = Color3.fromRGB(220, 170, 80)
avisoText.TextSize   = 9
avisoText.TextWrapped = true
avisoText.TextXAlignment = Enum.TextXAlignment.Left
avisoText.TextYAlignment = Enum.TextYAlignment.Top
avisoText.ZIndex = 6

-- ══════════════════════════════════════════════════════════════════════════
--  ████████  BRING SYSTEM — FIX v2 (filtros rigorosos + sem freeze)  ████
--
--  PROBLEMA 1: matchKeywordsBring usava :find() → substring match.
--    "Log" encontrava "LogCabin", "WoodlogHouse", árvores, estruturas.
--  FIX 1: Função matchBringExact() — compara nome EXATO (case-insensitive).
--    O nome do objeto no workspace deve ser igual à keyword (sem substrings).
--
--  PROBLEMA 2: executarBring iterava todos os descendentes sem yield.
--  FIX 2: Yield a cada 100 objetos (task.wait()) → jogo não trava.
--
--  PROBLEMA 3: Sem filtros de segurança → pegava NPCs, estruturas, partes.
--  FIX 3: Filtros adicionados:
--    ✗ Objetos Anchored com Size > 8 studs (estruturas fixas do mapa)
--    ✗ Objetos dentro de modelos com Humanoid (NPCs, mobs, players)
--    ✗ Objetos com nome na BLACKLIST global
--    ✗ Modelos com muitos descendentes (>30 parts → provável estrutura)
--    ✗ Partes com massa extremamente grande (terrain, mapas)
-- ══════════════════════════════════════════════════════════════════════════

-- ── Blacklist global — NUNCA fazer bring desses nomes ──
local BRING_BLACKLIST = {
    -- Árvores e vegetação
    "tree","pinetree","oaktree","birchtree","sprucetree","palmetree",
    "deathbush","bush","grass","bamboo","mushroom_bush","forestground",
    -- Terreno e estruturas do mapa
    "baseplate","terrain","rock","stone","boulder","cliff","mountain",
    "ground","floor","wall","ceiling","door","window","roof","pillar",
    "bridge","path","road","plank_floor","plank_wall","planks",
    "cabin","house","hut","shack","shed","tower","watchtower","bunker",
    "fence","gate","railing","stairs","step","platform",
    -- Objetos de ambiente/decoração
    "sky","sun","moon","star","cloud","fog","rain","snow","waterfall",
    "lake","river","ocean","sea","pond","stream",
    -- NPCs e mobs (pega pelo parent com Humanoid, mas reforça aqui)
    "wolf","bear","deer","rabbit","cultist","npc","mob","enemy","boss",
    "alphaWolf","polarbear","boar","elk","moose","mammoth","bison",
}

-- Converte para lookup rápido
local BLACKLIST_SET = {}
for _, v in ipairs(BRING_BLACKLIST) do
    BLACKLIST_SET[v:lower()] = true
end

-- ── FIX: Match EXATO (não substring) ──
-- O nome do objeto deve ser IGUAL à keyword (ignora maiúsculas/minúsculas)
-- Isso evita que "Log" pegue "WoodLogCabin" ou "LogWall"
local function matchBringExact(objName, lista)
    if not objName then return false end
    local lower = objName:lower()

    -- Primeiro: check blacklist (prioridade máxima)
    if BLACKLIST_SET[lower] then return false end

    -- Segundo: match exato na lista de keywords
    for _, kw in ipairs(lista) do
        if lower == kw:lower() then return true end
    end
    return false
end

-- ── Verificação se objeto é de player ──
local function isPlayerObject(obj)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character then
            if pl.Character == obj then return true end
            if pl.Character:IsAncestorOf(obj) then return true end
        end
    end
    return false
end

-- ── Verificação se objeto é NPC/Mob ──
local function hasHumanoidInChain(obj)
    -- Sobe até 4 níveis na hierarquia procurando Humanoid
    local check = obj
    for _ = 1, 4 do
        if not check then break end
        if check:IsA("Model") and check:FindFirstChild("Humanoid") then
            return true
        end
        check = check.Parent
    end
    return false
end

-- ── Verificação se BasePart é estrutura do mapa ──
local function isMapStructure(part)
    -- Partes ancoradas com volume grande = parte do mapa
    if part.Anchored then
        local size = part.Size
        local volume = size.X * size.Y * size.Z
        if volume > 512 then return true end    -- > 8x8x8 ancorado → estrutura
        if size.Magnitude > 20 then return true end  -- dimensão >20 studs → mapa
    end
    return false
end

-- ── Verificação se Model é estrutura (muitas partes) ──
local function isLargeModel(model)
    local count = 0
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            count += 1
            if count > 25 then return true end  -- >25 partes = estrutura/construção
        end
    end
    return false
end

-- ── Keywords de Bring (EXATAS — sem substrings) ──
-- IMPORTANTE: Os nomes aqui devem ser idênticos ao .Name do objeto no jogo
local BRING_KEYWORDS = {
    Equipamentos = {
        -- Sacos
        "OldSack","GoodSack","InfernalSack","GiantSack",
        -- Machados
        "OldAxe","GoodAxe","IceAxe","StrongAxe","Chainsaw",
        -- Varas de pescar
        "OldRod","GoodRod","StrongRod",
        -- Flautas
        "OldFlute","GoodFlute","StrongFlute",
        "OldTamingFlute","GoodTamingFlute","StrongTamingFlute",
        -- Iluminação (itens coletáveis, não estruturas)
        "Flashlight","Lantern","Torch","FlashlightOld","FlashlightGood",
        -- Kits
        "TrimKit","OldTrimKit","GoodTrimKit","StrongTrimKit",
        "Bandage","MedKit","HealingKit","ReviveKit","FirstAid",
        -- Armaduras (itens coletáveis)
        "LeatherBody","IronBody","ThornBody","AlienArmor","RiotShield",
        "Helmet","Boots","WarmClothing","Armor","Shield",
        -- Plantas (blueprint)
        "Blueprint","CorruptionTracker",
    },
    Combustao = {
        -- Lenha/madeira de chão (item coletável, não árvore)
        "Log","WetLog","DryLog","BigLog","PineLog","OakLog","RottenLog",
        -- Carvão
        "Coal","CoalChunk","Charcoal",
        -- Combustível líquido
        "Biofuel","Gasoline","FuelCanister","FuelCan",
        -- Carcaças (para combustão)
        "WolfCorpse","AlphaWolfCorpse","BearCorpse","CultistCorpse","AlienCorpse",
        "RabbitCorpse","DeerCorpse","FoxCorpse",
        -- Partes animais
        "BunnyFoot","RabbitFoot","WolfPelt","BearPelt",
    },
    Log = {
        -- Somente o item "Log" exato
        "Log","WetLog","DryLog",
    },
    Metais = {
        -- Sucata/junk
        "BrokenFan","OldRadio","MetalChair","BrokenWashingMachine","OldCarEngine",
        "UFOWreckage","UFOJunk","LargeDebris","Junk","BrokenAppliance",
        "Scrap","ScrapMetal","Metal","SheetMetal","MetalPipe","Pipe",
        -- Gemas e cristais
        "CultistGem","ForestGem","GemFragment","ForestGemFragment",
        "Gem","Gema","Crystal","Cristal","VoidCrystal","ShadowGem","LavaGem",
        -- Moedas
        "MossyCoin","Coin",
        -- Medalhas/amuletos
        "CultistMedallion","Medallion","Amulet","CultistAmulet",
        -- Partes de bigorna (item especial)
        "AnvilPart","AnvilParts","AnvilComponent",
        -- Ingredientes de poção
        "PotionIngredient","PotionItem","Ingredient",
        -- Minérios
        "IronOre","CopperOre","GoldOre","SilverOre",
        -- Barras
        "IronBar","CopperBar","GoldBar","SteelBar","MetalBar",
        -- Pedras coletáveis (pequenas)
        "SmallRock","RockFragment","StoneChunk",
    },
    Comidas = {
        "Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake",
        "Morsel","CookedMorsel","Steak","CookedSteak","Ribs","CookedRibs",
        "Mackerel","CookedMackerel","Salmon","CookedSalmon",
        "Clownfish","CookedClownfish","Jellyfish","Char","CookedChar",
        "Eel","CookedEel","Swordfish","CookedSwordfish","Shark","CookedShark",
        "Stew","HeartyStew","SeafoodChowder","SteakDinner","PumpkinSoup","BBQRibs",
        "CarrotCake","JarOJelly","JarOfJelly",
        "CandyApple","CandyCorn","PumpkinPie","CottonCandy",
        "ThanksgivingDinner","MeatSandwich","Sandwich",
        "Food","CookedFood","RawFood","Ration","Snack",
    },
    Sementes = {
        "BerrySeed","CarrotSeed","ChiliSeed","CornSeed","PumpkinSeed","AppleSeed",
        "Seed","SeedPack","SeedBag","TreeSapling","Seedling","Sprout",
        "ForestSeed","WinterSeed","RareSeed","MagicSeed","FireflySeed",
    },
    Ferramentas = {
        "Spear","WoodSpear","MorningStar","LaserSword",
        "Revolver","Rifle","Shotgun","TacticalShotgun",
        "RayGun","LaserCannon","Flamethrower","Crossbow","CrossbowWeapon",
        "StoneSword","BoneSword","ShadowDagger","BoneSpear",
        "Sword","Dagger","Mace","Club","CultistMace",
    },
    Municao = {
        "Arrow","Arrows","CrossbowBolt","CrossbowAmmo",
        "Bullet","Bullets","Ammo","Ammunition","Shells",
        "BulletPack","AmmoPack","AmmoBox",
        "RevolverAmmo","RifleAmmo","ShotgunAmmo","TacticalShotgunAmmo",
        "GasCan","GasCanister",
    },
}

local BRING_COR = {
    Equipamentos = Color3.fromRGB(255, 165,  30),
    Combustao    = Color3.fromRGB(255, 100,  30),
    Log          = Color3.fromRGB(160, 110,  60),
    Metais       = Color3.fromRGB(170, 225, 255),
    Comidas      = Color3.fromRGB(255, 110, 160),
    Sementes     = Color3.fromRGB(140, 240, 120),
    Ferramentas  = Color3.fromRGB(200,  80,  80),
    Municao      = Color3.fromRGB(230, 200,  60),
}

local function criarIconeBring(parent, key, cor)
    local cont = Instance.new("Frame", parent)
    cont.BackgroundTransparency = 1
    cont.BorderSizePixel = 0
    cont.Size = UDim2.new(0, 28, 0, 28)
    cont.ZIndex = parent.ZIndex + 2
    cont.ClipsDescendants = false

    local function r(x, y, w, h, radius)
        local f = Instance.new("Frame", cont)
        f.BackgroundColor3 = cor
        f.BorderSizePixel  = 0
        f.Position = UDim2.new(0, x, 0, y)
        f.Size     = UDim2.new(0, w, 0, h)
        f.ZIndex   = cont.ZIndex + 1
        if radius then Instance.new("UICorner", f).CornerRadius = UDim.new(0, radius) end
        return f
    end
    local function c(cx, cy, rad)
        return r(cx - rad, cy - rad, rad * 2, rad * 2, rad * 2)
    end
    local function rDark(x, y, w, h, radius)
        local f = r(x, y, w, h, radius)
        f.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
        return f
    end

    if key == "Equipamentos" then
        r(3, 2, 22, 20, 4) rDark(6, 5, 16, 14, 3)
        r(12, 4, 4, 16, 1) r(5, 11, 18, 4, 1)
        r(10, 20, 8, 6, 3)
    elseif key == "Combustao" then
        r(10, 0,  8, 10, 4) r(5,  6, 18, 14, 5) r(3, 12, 22,  8, 4)
        rDark(9, 8, 10, 10, 4)
        local brasa = r(11, 14, 6, 5, 3)
        brasa.BackgroundColor3 = Color3.fromRGB(255, 230, 100)
    elseif key == "Log" then
        r(1, 8, 26, 12, 5)
        local a1 = r(3, 10, 22, 8, 4) a1.BackgroundColor3 = Color3.fromRGB(130, 80, 30)
        local a2 = r(7, 12, 14, 4, 3) a2.BackgroundColor3 = Color3.fromRGB(100, 60, 20)
        r(1, 8, 4, 12, 2) r(23, 8, 4, 12, 2)
        for i = 0, 2 do
            local line = r(5, 10 + i*3, 18, 1, 0)
            line.BackgroundColor3 = Color3.fromRGB(150, 90, 35)
            line.BackgroundTransparency = 0.5
        end
    elseif key == "Metais" then
        r(10, 0,  8, 4, 1) r(4,  4, 20, 8, 1) r(6, 12, 16, 8, 1) r(10, 20, 8, 6, 2)
        local brilho = r(12, 5, 4, 6, 2) brilho.BackgroundColor3 = Color3.fromRGB(255,255,255) brilho.BackgroundTransparency = 0.4
    elseif key == "Comidas" then
        r(12, 0,  4, 5, 2)
        local folha = r(14, 1, 8, 5, 2) folha.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
        c(14, 16, 11)
        local brilho = r(8, 7, 5, 5, 3) brilho.BackgroundColor3 = Color3.fromRGB(255,255,255) brilho.BackgroundTransparency = 0.4
        local base = r(11, 24, 6, 3, 2) base.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    elseif key == "Sementes" then
        r(12, 20, 4, 8, 1)
        local fl = r(2, 10, 10, 8, 4) fl.BackgroundColor3 = Color3.fromRGB(60, 200, 70)
        local fr = r(16, 10, 10, 8, 4) fr.BackgroundColor3 = Color3.fromRGB(60, 200, 70)
        r(12, 8, 4, 14, 2)
        c(14, 6, 5)
        rDark(12, 4, 4, 4, 2)
    elseif key == "Ferramentas" then
        r(12, 8, 4, 20, 2)
        r(4,  2, 16, 14, 3)
        local gume = r(2, 4, 6, 10, 2) gume.BackgroundColor3 = Color3.fromRGB(220,220,240)
        local fio  = r(2, 6, 2, 6, 1)  fio.BackgroundColor3  = Color3.fromRGB(255,255,255)
        r(4, 1, 12, 4, 2)
    elseif key == "Municao" then
        r(14, 0, 6, 3, 1) r(12, 3, 4, 3, 1) r(10, 6, 6, 2, 1)
        r(13, 8, 2, 14, 0)
        local p1 = r(8,  22, 6, 3, 1) p1.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
        local p2 = r(14, 22, 6, 3, 1) p2.BackgroundColor3 = Color3.fromRGB(255, 200, 80)
        r(12, 25, 4, 3, 1)
    end

    return cont
end

-- ══════════════════════════════════════════════════════════════════
--  executarBring — FIX v2 COMPLETO
--  ▸ matchBringExact() em vez de :find() → sem falsos positivos
--  ▸ Yield a cada 100 objetos → sem freeze
--  ▸ Filtros: Anchored+Size, Humanoid, Blacklist, LargeModel
--  ▸ Anti-desaparecimento por 8s (igual antes, sem mudança)
-- ══════════════════════════════════════════════════════════════════
local function executarBring(keywords)
    local char = Player.Character
    if not char then return 0 end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return 0 end

    local cf = hrp.CFrame
    local count = 0

    -- Cache de personagens de players para comparação rápida
    local playerChars = {}
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character then playerChars[pl.Character] = true end
    end

    local ok, descendants = pcall(function() return workspace:GetDescendants() end)
    if not ok then return 0 end

    local trazidos = {}
    local batch    = 0

    for _, obj in ipairs(descendants) do
        batch += 1
        -- FIX: yield a cada 100 objetos → não trava o frame
        if batch % 100 == 0 then
            task.wait()
            -- Re-verifica personagem após yield (pode ter morrido)
            char = Player.Character
            if not char then break end
            hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then break end
            cf = hrp.CFrame
        end

        pcall(function()
            if not obj or not obj.Parent then return end

            -- FIX: Verifica se é objeto de player
            if playerChars[obj] then return end
            for pc, _ in pairs(playerChars) do
                if pc:IsAncestorOf(obj) then return end
            end

            -- FIX: Verifica se está dentro de NPC/Mob
            if hasHumanoidInChain(obj) then return end

            local name = obj.Name
            if not name or name == "" then return end

            -- FIX: Usa match exato (não substring)
            if not matchBringExact(name, keywords) then return end

            local spread = Vector3.new(
                math.random(-4, 4),
                0.5,
                math.random(-4, 4)
            )
            local targetPos = cf.Position + spread

            if obj:IsA("BasePart") then
                -- FIX: Pula estruturas do mapa (ancoradas e grandes)
                if isMapStructure(obj) then return end

                for _, s in pairs(obj:GetChildren()) do
                    if s:IsA("Script") or s:IsA("LocalScript") then
                        pcall(function() s.Disabled = true end)
                    end
                end
                obj.CFrame     = CFrame.new(targetPos)
                obj.Anchored   = false
                obj.CanCollide = true
                obj.Velocity   = Vector3.new(0, 0, 0)
                table.insert(trazidos, { obj = obj, pos = targetPos })
                count += 1

            elseif obj:IsA("Model") then
                if playerChars[obj] then return end

                -- FIX: Pula modelos com Humanoid (NPCs)
                if obj:FindFirstChild("Humanoid") then return end

                -- FIX: Pula modelos grandes (estruturas)
                if isLargeModel(obj) then return end

                local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                if not primary then return end

                -- FIX: Pula se a parte primária é estrutura de mapa
                if isMapStructure(primary) then return end

                pcall(function() obj:SetPrimaryPartCFrame(CFrame.new(targetPos)) end)
                for _, part in pairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Anchored   = false
                        part.CanCollide = true
                        part.Velocity   = Vector3.new(0, 0, 0)
                    end
                    if part:IsA("Script") or part:IsA("LocalScript") then
                        pcall(function() part.Disabled = true end)
                    end
                end
                table.insert(trazidos, { obj = obj, pos = targetPos })
                count += 1
            end
        end)
    end

    -- Anti-desaparecimento (8 segundos)
    if #trazidos > 0 then
        task.spawn(function()
            for i = 1, 8 do
                task.wait(1)
                for _, entry in ipairs(trazidos) do
                    pcall(function()
                        if not entry.obj or not entry.obj.Parent then return end
                        if entry.obj:IsA("BasePart") then
                            if (entry.obj.Position - entry.pos).Magnitude > 20 then
                                entry.obj.CFrame  = CFrame.new(entry.pos)
                                entry.obj.Velocity = Vector3.new(0,0,0)
                            end
                        elseif entry.obj:IsA("Model") and entry.obj.PrimaryPart then
                            if (entry.obj.PrimaryPart.Position - entry.pos).Magnitude > 20 then
                                pcall(function() entry.obj:SetPrimaryPartCFrame(CFrame.new(entry.pos)) end)
                            end
                        end
                    end)
                end
            end
            trazidos = nil
        end)
    end

    return count
end

-- ── Configuração das linhas de Bring ──
local BRING_CFG = {
    { key="Equipamentos", label="Bring Equipamentos", desc="Sacos, Machados, Armaduras, Kits, Lanternas" },
    { key="Combustao",    label="Bring Combustão",    desc="Logs, Carvão, Carcaças, Combustível" },
    { key="Log",          label="Bring Log",          desc="Somente itens Log, WetLog, DryLog" },
    { key="Metais",       label="Bring Metais",       desc="Sucata, Gemas, Minérios, Barras" },
    { key="Comidas",      label="Bring Comidas",      desc="Carnes, Frutas, Sopas, Peixes" },
    { key="Sementes",     label="Bring Sementes",     desc="Sementes, Mudas, Brotos" },
    { key="Ferramentas",  label="Bring Ferramentas",  desc="Espadas, Arcos, Bestas, Lanças" },
    { key="Municao",      label="Bring Munição",      desc="Flechas, Virotes, Balas, Munição" },
}

-- ── Interface Bring na aba ──
local bringTitle = Instance.new("TextLabel", Pages["Bring"])
bringTitle.BackgroundTransparency = 1
bringTitle.Size     = UDim2.new(1, -8, 0, 20)
bringTitle.Font     = Enum.Font.GothamBlack
bringTitle.Text     = "BRING — 99 Dias na Floresta"
bringTitle.TextColor3 = Color3.fromRGB(88, 101, 242)
bringTitle.TextSize = 13
bringTitle.TextXAlignment = Enum.TextXAlignment.Left
bringTitle.LayoutOrder = 0
bringTitle.ZIndex = 5

local bringSubtitle = Instance.new("TextLabel", Pages["Bring"])
bringSubtitle.BackgroundTransparency = 1
bringSubtitle.Size     = UDim2.new(1, -8, 0, 14)
bringSubtitle.Font     = Enum.Font.Gotham
bringSubtitle.Text     = "Clique para teleportar os itens até você (filtros rigorosos ativados)"
bringSubtitle.TextColor3 = Color3.fromRGB(90, 100, 120)
bringSubtitle.TextSize = 9
bringSubtitle.TextXAlignment = Enum.TextXAlignment.Left
bringSubtitle.LayoutOrder = 1
bringSubtitle.ZIndex = 5

local bringDivider = Instance.new("Frame", Pages["Bring"])
bringDivider.BackgroundColor3 = Color3.fromRGB(50, 54, 65)
bringDivider.BorderSizePixel  = 0
bringDivider.Size = UDim2.new(1, -8, 0, 1)
bringDivider.LayoutOrder = 2
bringDivider.ZIndex = 5

local bringRowOrder = 3

local function makeBringRow(cfg)
    bringRowOrder += 1
    local cor = BRING_COR[cfg.key] or Color3.fromRGB(130, 140, 200)

    local row = Instance.new("Frame", Pages["Bring"])
    row.BackgroundColor3    = Color3.fromRGB(28, 30, 36)
    row.BorderSizePixel     = 0
    row.Size                = UDim2.new(1, -8, 0, 60)
    row.LayoutOrder         = bringRowOrder
    row.ZIndex              = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 9)

    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color     = Color3.fromRGB(42, 46, 56)
    rowStroke.Thickness = 1

    local gradBg = Instance.new("Frame", row)
    gradBg.BackgroundColor3 = cor
    gradBg.BackgroundTransparency = 0.9
    gradBg.BorderSizePixel = 0
    gradBg.Size = UDim2.new(1, 0, 1, 0)
    gradBg.ZIndex = 5
    Instance.new("UICorner", gradBg).CornerRadius = UDim.new(0, 9)

    local iconBox = Instance.new("Frame", row)
    iconBox.BackgroundColor3 = cor
    iconBox.BackgroundTransparency = 0.78
    iconBox.BorderSizePixel = 0
    iconBox.Position = UDim2.new(0, 8, 0.5, -18)
    iconBox.Size     = UDim2.new(0, 36, 0, 36)
    iconBox.ZIndex   = 7
    Instance.new("UICorner", iconBox).CornerRadius = UDim.new(0, 8)

    local icon = criarIconeBring(iconBox, cfg.key, cor)
    icon.Position = UDim2.new(0, 4, 0, 4)
    icon.Size     = UDim2.new(0, 28, 0, 28)

    local barLeft = Instance.new("Frame", row)
    barLeft.BackgroundColor3 = cor
    barLeft.BorderSizePixel  = 0
    barLeft.Position = UDim2.new(0, 0, 0.15, 0)
    barLeft.Size     = UDim2.new(0, 3, 0.7, 0)
    barLeft.ZIndex   = 8
    Instance.new("UICorner", barLeft).CornerRadius = UDim.new(0, 2)

    local labelNome = Instance.new("TextLabel", row)
    labelNome.BackgroundTransparency = 1
    labelNome.Position       = UDim2.new(0, 54, 0, 8)
    labelNome.Size           = UDim2.new(1, -160, 0, 18)
    labelNome.Font           = Enum.Font.GothamBold
    labelNome.Text           = cfg.label
    labelNome.TextColor3     = Color3.fromRGB(225, 230, 245)
    labelNome.TextSize       = 11
    labelNome.TextXAlignment = Enum.TextXAlignment.Left
    labelNome.ZIndex         = 7

    local labelDesc = Instance.new("TextLabel", row)
    labelDesc.BackgroundTransparency = 1
    labelDesc.Position       = UDim2.new(0, 54, 0, 28)
    labelDesc.Size           = UDim2.new(1, -160, 0, 24)
    labelDesc.Font           = Enum.Font.Gotham
    labelDesc.Text           = cfg.desc
    labelDesc.TextColor3     = Color3.fromRGB(90, 100, 120)
    labelDesc.TextSize       = 9
    labelDesc.TextXAlignment = Enum.TextXAlignment.Left
    labelDesc.TextWrapped    = true
    labelDesc.ZIndex         = 7

    local btnBring = Instance.new("TextButton", row)
    btnBring.BackgroundColor3 = cor
    btnBring.BackgroundTransparency = 0.15
    btnBring.BorderSizePixel  = 0
    btnBring.Position         = UDim2.new(1, -82, 0.5, -14)
    btnBring.Size             = UDim2.new(0, 74, 0, 28)
    btnBring.Font             = Enum.Font.GothamBold
    btnBring.Text             = "▼ BRING"
    btnBring.TextColor3       = Color3.fromRGB(255, 255, 255)
    btnBring.TextSize         = 10
    btnBring.ZIndex           = 9
    Instance.new("UICorner", btnBring).CornerRadius = UDim.new(0, 7)

    local btnStroke = Instance.new("UIStroke", btnBring)
    btnStroke.Color     = cor
    btnStroke.Thickness = 1.2
    btnStroke.Transparency = 0.5

    local feedbackLbl = Instance.new("TextLabel", row)
    feedbackLbl.BackgroundTransparency = 1
    feedbackLbl.Position       = UDim2.new(1, -82, 0.5, 16)
    feedbackLbl.Size           = UDim2.new(0, 74, 0, 12)
    feedbackLbl.Font           = Enum.Font.Gotham
    feedbackLbl.Text           = ""
    feedbackLbl.TextColor3     = cor
    feedbackLbl.TextSize       = 8
    feedbackLbl.TextXAlignment = Enum.TextXAlignment.Center
    feedbackLbl.ZIndex         = 8

    btnBring.MouseEnter:Connect(function()
        TweenService:Create(btnBring, TweenInfo.new(0.12), {
            BackgroundTransparency = 0,
            Size = UDim2.new(0, 74, 0, 30),
            Position = UDim2.new(1, -82, 0.5, -15),
        }):Play()
    end)
    btnBring.MouseLeave:Connect(function()
        TweenService:Create(btnBring, TweenInfo.new(0.12), {
            BackgroundTransparency = 0.15,
            Size = UDim2.new(0, 74, 0, 28),
            Position = UDim2.new(1, -82, 0.5, -14),
        }):Play()
    end)

    local bringRunning = false

    btnBring.MouseButton1Click:Connect(function()
        if bringRunning then return end
        bringRunning = true

        btnBring.Text = "⏳..."
        TweenService:Create(btnBring, TweenInfo.new(0.08), {
            BackgroundTransparency = 0.4
        }):Play()

        task.spawn(function()
            local count = executarBring(BRING_KEYWORDS[cfg.key]) or 0
            task.wait(0.3)

            btnBring.Text = "▼ BRING"
            TweenService:Create(btnBring, TweenInfo.new(0.15), {
                BackgroundTransparency = 0.15
            }):Play()

            if count > 0 then
                feedbackLbl.Text = "✓ "..count.." item(s)"
                feedbackLbl.TextColor3 = cor
                feedbackLbl.TextTransparency = 0
                task.delay(3, function()
                    TweenService:Create(feedbackLbl, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
                    task.wait(0.6)
                    feedbackLbl.Text = ""
                    feedbackLbl.TextTransparency = 0
                end)
            else
                feedbackLbl.Text = "✗ Nenhum item"
                feedbackLbl.TextColor3 = Color3.fromRGB(200, 80, 80)
                feedbackLbl.TextTransparency = 0
                task.delay(2.5, function()
                    TweenService:Create(feedbackLbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
                    task.wait(0.5)
                    feedbackLbl.Text = ""
                    feedbackLbl.TextTransparency = 0
                    feedbackLbl.TextColor3 = cor
                end)
            end

            TweenService:Create(rowStroke, TweenInfo.new(0.2), {Color=cor}):Play()
            task.delay(1.5, function()
                TweenService:Create(rowStroke, TweenInfo.new(0.4), {Color=Color3.fromRGB(42,46,56)}):Play()
            end)

            task.wait(1)
            bringRunning = false
        end)
    end)
end

for _, cfg in ipairs(BRING_CFG) do
    makeBringRow(cfg)
    bringRowOrder += 1
    local sep = Instance.new("Frame", Pages["Bring"])
    sep.BackgroundTransparency = 1
    sep.Size = UDim2.new(1, 0, 0, 3)
    sep.LayoutOrder = bringRowOrder
end

bringRowOrder += 1
local bringAviso = Instance.new("Frame", Pages["Bring"])
bringAviso.BackgroundColor3 = Color3.fromRGB(25, 40, 60)
bringAviso.BackgroundTransparency = 0.35
bringAviso.BorderSizePixel = 0
bringAviso.Size = UDim2.new(1, -8, 0, 60)
bringAviso.LayoutOrder = bringRowOrder
bringAviso.ZIndex = 5
Instance.new("UICorner", bringAviso).CornerRadius = UDim.new(0, 8)
local bringAvisoStroke = Instance.new("UIStroke", bringAviso)
bringAvisoStroke.Color = Color3.fromRGB(60, 120, 200)
bringAvisoStroke.Thickness = 1

local bringAvisoText = Instance.new("TextLabel", bringAviso)
bringAvisoText.BackgroundTransparency = 1
bringAvisoText.Position = UDim2.new(0, 10, 0, 5)
bringAvisoText.Size     = UDim2.new(1, -20, 1, -10)
bringAvisoText.Font     = Enum.Font.Gotham
bringAvisoText.Text     = "FIX v2: Match EXATO de nomes (sem substring). Filtros: Anchored+Size, Humanoid, Blacklist, LargeModel. Yield a cada 100 objs (sem freeze). Anti-desaparecimento por 8s."
bringAvisoText.TextColor3 = Color3.fromRGB(100, 170, 255)
bringAvisoText.TextSize   = 9
bringAvisoText.TextWrapped = true
bringAvisoText.TextXAlignment = Enum.TextXAlignment.Left
bringAvisoText.TextYAlignment = Enum.TextYAlignment.Top
bringAvisoText.ZIndex = 6

-- ══════════════════════════════
--  SELECIONAR ABA INICIAL
-- ══════════════════════════════
task.wait(0.05)
selectTab("Info")

print("✅ PudimHub V3 FIX v2 carregado!")
print("🔧 ESP: updateCache ASSÍNCRONO (task.spawn + yield/150) → sem freeze de 4s")
print("🔧 Bring: matchBringExact() → match exato, sem substring falso-positivo")
print("🔧 Bring: Filtros → Anchored+Size, Humanoid, Blacklist, LargeModel")
print("🔧 Bring: Yield a cada 100 objs → sem congelamento")
print("🗂 9 Abas | 👁 12 ESP | 🧲 8 Brings | ⚡ Boost | ✅ Script único")
