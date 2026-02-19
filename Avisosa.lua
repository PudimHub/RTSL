-- ╔══════════════════════════════════════════════════════════════════╗
-- ║     PUDIM HUB — v6 ULTRA COMPLETO (Player + Aimbot + TP)       ║
-- ║  ✓ criarIconePlayer e criarIconeAvancado definidos              ║
-- ║  ✓ Speed/Jump: SliderBar arrastável com líquido azul animado    ║
-- ║  ✓ InfinitoZoom | CameraLivre | FullBright | InfiniteJump      ║
-- ║  ✓ SlopeBoost | GodMode (imortalidade real)                     ║
-- ║  ✓ Aba TP: Dropdown bonito + busca dinâmica de biomas           ║
-- ║  ✓ Biomas: Floresta|Neve|Vulcão|Cavernas|Fada|PoloNorte        ║
-- ╚══════════════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Cam    = workspace.CurrentCamera

-- Novas variáveis v5
local infinitoZoomEnabled = false
local cameraLivreEnabled = false
local fullBrightEnabled = false
local infiniteJumpEnabled = false
local slopeBoostEnabled = false
local godModeEnabled = false
local originalBrightness = Lighting.Brightness
local originalFogEnd = Lighting.FogEnd
local originalClockTime = Lighting.ClockTime
local infJumpConn, godModeConn


-- ══════════════════════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "PudimHubFinal"
ScreenGui.Parent          = game.CoreGui
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn    = false
ScreenGui.DisplayOrder    = 999

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
--  TOP BAR
-- ══════════════════════════════════════════════════════
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Name             = "TopBar"
TopBar.BackgroundColor3 = Color3.fromRGB(24, 25, 28)
TopBar.Size             = UDim2.new(1, 0, 0, 40)
TopBar.BorderSizePixel  = 0
TopBar.ZIndex           = 3
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
TitleLabel.Text           = "PudimHub v6"
TitleLabel.TextColor3     = Color3.fromRGB(88, 101, 242)
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
    {key="Info",label="Info"},{key="Status",label="Status"},{key="Farm",label="Farm"},
    {key="Esp",label="ESP"},{key="Bring",label="Bring"},{key="AvancadoFarm",label="Avançado Farm"},
    {key="Player",label="Player"},{key="Configuracoes",label="Configurações"},{key="TP",label="Teleporte"},{key="AvancadoFuncoes",label="Avançado Funções"},
}
local GroupConfig = {
    {label="GERAL",   keys={"Info","Status"}},
    {label="COMBATE", keys={"Farm","Esp","Bring","AvancadoFarm"}},
    {label="EXTRA",   keys={"Player","Configuracoes","TP","AvancadoFuncoes"}},
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
--  SISTEMA DE ABAS
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
        elseif key=="TP" then
        p(mkCircle(cont,10,10,8,ic)); local ci=mkCircle(cont,10,10,6,Color3.fromRGB(24,26,32)); ci.ZIndex=cont.ZIndex+2
        p(mkRect(cont,9,4,2,12,ic,1)); p(mkRect(cont,6,7,8,2,ic,1))
    elseif key=="AvancadoFuncoes" then
        p(mkRect(cont,1,13,12,4,ic,2)); p(mkCircle(cont,15,6,5,ic))
        local furo=mkCircle(cont,15,6,3,Color3.fromRGB(24,26,32)); furo.ZIndex=cont.ZIndex+2
        p(mkRect(cont,8,9,6,3,ic,1))
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
local function makeGroupLabel(text,groupTabs)
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
    local groupTabs={}; makeGroupLabel(g.label,groupTabs)
    for _,k in ipairs(g.keys) do if keyMap[k] then makeTab(keyMap[k],groupTabs) end end
end

-- ══════════════════════════════════════════════════════
--  BOOST FUNCTIONS
-- ══════════════════════════════════════════════════════
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
    else
        for obj,p in pairs(origMaterials) do pcall(function() if obj and obj.Parent then obj.Material=p.M; obj.Color=p.C; obj.Reflectance=p.R; obj.Transparency=p.T; obj.CastShadow=true end end) end
        for obj,t in pairs(origTextures) do pcall(function() if obj and obj.Parent then obj.Transparency=t end end) end
        origMaterials={}; origTextures={}
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
    else
        for e,w in pairs(hidEffects) do pcall(function() if e and e.Parent then e.Enabled=w end end) end; hidEffects={}
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
    else
        for p,d in pairs(hidNPCs) do pcall(function() if p and p.Parent then p.Transparency=d.T; p.CanCollide=d.CC end end) end; hidNPCs={}
    end
end

local origSet={}
local function ForceLagCleaner(s)
    if s then pcall(function()
        origSet.Q=settings().Rendering.QualityLevel; origSet.M=settings().Rendering.MeshPartDetailLevel
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        settings().Rendering.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level01
        settings().Physics.AllowSleep=true
    end) else pcall(function()
        if origSet.Q then settings().Rendering.QualityLevel=origSet.Q end
        if origSet.M then settings().Rendering.MeshPartDetailLevel=origSet.M end
    end); origSet={} end
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
makePopupToggle("🎨 Remover Efeitos",  ForceRemoveEffects)
makePopupToggle("👻 Remover NPCs",     ForceRemoveNPCs)
makePopupToggle("🧹 Limpar Lag Total", ForceLagCleaner)

local rejBtn=Instance.new("TextButton",BoostPopup)
rejBtn.BackgroundColor3=Color3.fromRGB(200,50,55); rejBtn.BorderSizePixel=0
rejBtn.Size=UDim2.new(1,0,0,32); rejBtn.Font=Enum.Font.GothamBold
rejBtn.Text="🔄  REJOIN SERVER"; rejBtn.TextColor3=Color3.fromRGB(255,255,255); rejBtn.TextSize=11; rejBtn.ZIndex=201
Instance.new("UICorner",rejBtn).CornerRadius=UDim.new(0,7)
rejBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,Player)
end)

-- ══════════════════════════════════════════════════════
--  BOTÃO FLUTUANTE PD
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
--  ABA INFO
-- ══════════════════════════════════════════════════════
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
infoStatusSub.Text="ID: "..tostring(game.PlaceId).."  •  Hub v4"
infoStatusSub.TextColor3=Color3.fromRGB(120,130,145); infoStatusSub.TextSize=9
infoStatusSub.TextXAlignment=Enum.TextXAlignment.Left; infoStatusSub.ZIndex=7

local infoSep=Instance.new("Frame",Pages["Info"])
infoSep.BackgroundColor3=Color3.fromRGB(50,54,65); infoSep.BorderSizePixel=0
infoSep.Size=UDim2.new(1,0,0,1); infoSep.LayoutOrder=1; infoSep.ZIndex=5

local dadosHeader=Instance.new("TextButton",Pages["Info"])
dadosHeader.BackgroundColor3=Color3.fromRGB(26,28,34); dadosHeader.BorderSizePixel=0
dadosHeader.Size=UDim2.new(1,0,0,32); dadosHeader.LayoutOrder=2; dadosHeader.Text=""; dadosHeader.ZIndex=5
Instance.new("UICorner",dadosHeader).CornerRadius=UDim.new(0,8)
local dadosStroke=Instance.new("UIStroke",dadosHeader); dadosStroke.Color=Color3.fromRGB(55,58,66); dadosStroke.Thickness=1

local dadosTitleLbl=Instance.new("TextLabel",dadosHeader)
dadosTitleLbl.BackgroundTransparency=1; dadosTitleLbl.Position=UDim2.new(0,12,0,0)
dadosTitleLbl.Size=UDim2.new(1,-40,1,0); dadosTitleLbl.Font=Enum.Font.GothamBold
dadosTitleLbl.Text="Dados"; dadosTitleLbl.TextColor3=Color3.fromRGB(180,185,200)
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
dadosContent.Size=UDim2.new(1,0,0,0); dadosContent.LayoutOrder=3; dadosContent.ZIndex=5
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
dadosText.Text="Este script foi desenvolvido por apenas 1 pessoa. Às vezes pode demorar para atualizar, às vezes pode ser rápido. Irei tentar ir o mais rápido possível — 1 pessoa desenvolvendo um script desse tamanho SOZINHO é difícil e demorado."
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
        local orig=btn.Text; btn.Text="✓ Copiado!"
        task.delay(1.5,function() btn.Text=orig end)
    end)
end

makeDadosBtn(dadosBtnsRow,"🔗 Discord Link",Color3.fromRGB(88,101,242),function()
    copyToClipboard("Sem link no momento")
end,0)
makeDadosBtn(dadosBtnsRow,"📋 Copy ID",Color3.fromRGB(60,160,80),function()
    copyToClipboard(tostring(game.JobId))
end,1)

local dadosOpen=false
local DADOS_H=160

dadosHeader.MouseButton1Click:Connect(function()
    dadosOpen=not dadosOpen
    TweenService:Create(dadosArrow,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=dadosOpen and 0 or 180}):Play()
    TweenService:Create(dadosContent,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,dadosOpen and DADOS_H or 0)}):Play()
    TweenService:Create(dadosStroke,TweenInfo.new(0.2),{Color=dadosOpen and C_ACCENT or Color3.fromRGB(55,58,66)}):Play()
end)

-- ══════════════════════════════════════════════════════
--  ÍCONES ESP (14x14)
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
    elseif key == "AnimPassivo" then
        r(3,0,2,5,1); r(9,0,2,5,1); c(7,6,2); c(7,10,4)
    elseif key == "AnimAgressivo" then
        r(1,0,4,5,1); r(9,0,4,5,1); c(7,7,5); r(4,11,2,3,0); r(8,11,2,3,0)
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
    elseif key == "InfinitoZoom" then
        c(12,12,8); dk(c(12,12,5)); r(18,18,8,4,2); clr(r(10,10,4,4,2), Color3.fromRGB(100,200,255))
    elseif key == "CameraLivre" then
        r(4,8,20,12,3); c(14,14,4); dk(c(14,14,2)); r(2,4,4,4,1); clr(r(0,10,4,8,1), Color3.fromRGB(200,200,200))
    elseif key == "FullBright" then
        c(14,14,6); for i=0,7 do local a=math.rad(i*45) r(14+math.cos(a)*10-1,14+math.sin(a)*10-1,2,2,1) end
    elseif key == "InfiniteJump" then
        r(12,0,4,10,1); clr(r(8,4,12,4,1), Color3.fromRGB(255,255,255)); r(12,12,4,10,1); clr(r(8,16,12,4,1), Color3.fromRGB(255,255,255))
    elseif key == "SlopeBoost" then
        r(2,14,24,4,2); r(18,6,8,8,1); clr(r(20,8,4,4,1), Color3.fromRGB(100,255,100))
    elseif key == "GodMode" then
        r(4,2,20,22,5); clr(r(12,6,4,14,1), Color3.fromRGB(255,255,255)); clr(r(7,11,14,4,1), Color3.fromRGB(255,255,255))
    end
    return cont
end

-- ══════════════════════════════════════════════════════
--  ÍCONES BRING (28x28)
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
        r(1,8,26,12,5)
        local a1=r(3,10,22,8,4); a1.BackgroundColor3=Color3.fromRGB(130,80,30)
        r(1,8,4,12,2); r(23,8,4,12,2)
    elseif key == "BCombust" then
        r(10,0,8,10,4); r(5,6,18,14,5); r(3,12,22,8,4)
        dk(r(9,8,10,10,4))
        local brasa=r(11,14,6,5,3); brasa.BackgroundColor3=Color3.fromRGB(255,230,100)
    elseif key == "BCarcacas" then
        c(6,6,4); c(22,6,4); c(6,22,4); c(22,22,4); r(8,10,12,8,0)
    elseif key == "BSucata" then
        r(10,0,8,4,1); r(4,4,20,8,1); r(6,12,16,8,1); r(10,20,8,6,2)
        dk(r(12,5,4,6,2))
    elseif key == "BMateriais" then
        r(10,0,8,4,0); r(4,4,20,10,0); r(6,14,16,8,0); r(12,22,4,4,0)
        local shine=r(12,5,4,6,2); shine.BackgroundColor3=Color3.fromRGB(255,255,255); shine.BackgroundTransparency=0.5
    elseif key == "BComidas" then
        r(12,0,4,5,2)
        local folha=r(14,1,8,5,2); folha.BackgroundColor3=Color3.fromRGB(60,180,60)
        c(14,16,11)
    elseif key == "BPeixes" then
        r(0,10,6,8,2); r(6,6,16,16,4); c(22,14,6); dk(c(23,12,2))
    elseif key == "BSementes" then
        r(12,20,4,8,1)
        local fl=r(2,10,10,8,4); fl.BackgroundColor3=Color3.fromRGB(60,200,70)
        local fr=r(16,10,10,8,4); fr.BackgroundColor3=Color3.fromRGB(60,200,70)
        r(12,8,4,14,2); c(14,6,5)
    elseif key == "BFerr" then
        r(12,8,4,20,2); r(4,2,16,14,3)
        local gume=r(2,4,6,10,2); gume.BackgroundColor3=Color3.fromRGB(220,220,240)
    elseif key == "BArmas" then
        r(12,0,4,18,2); r(2,16,24,4,2); r(12,20,4,8,2)
    elseif key == "BAmmo" then
        r(14,0,6,3,1); r(12,3,4,3,1); r(10,6,6,2,1); r(13,8,2,14,0)
        local p1=r(8,22,6,3,1); p1.BackgroundColor3=Color3.fromRGB(255,200,80)
        local p2=r(14,22,6,3,1); p2.BackgroundColor3=Color3.fromRGB(255,200,80)
    elseif key == "BCura" then
        r(10,2,8,24,3); r(2,10,24,8,3); dk(r(11,11,6,6,2))
    elseif key == "BPelts" then
        r(4,0,20,4,2); r(1,4,26,16,2); r(3,20,22,4,1)
        dk(r(9,6,10,10,2))
    elseif key == "BChaves" then
        c(8,8,7); dk(c(8,8,4)); r(13,6,12,4,2); r(21,10,4,4,0); r(17,10,4,4,0)
    elseif key == "BBigorna" then
        r(6,0,16,6,2); r(2,6,24,4,0); r(6,10,16,12,2); r(8,22,12,4,1)
    elseif key == "BPocoes" then
        r(10,0,8,4,0); r(8,4,12,4,0); r(4,8,20,16,5); dk(r(7,11,14,8,3))
    elseif key == "BBlueprint" then
        r(4,0,20,24,2)
        local l1=r(7,4,14,2,0); l1.BackgroundColor3=Color3.fromRGB(100,160,255)
        local l2=r(7,8,14,2,0); l2.BackgroundColor3=Color3.fromRGB(100,160,255)
        local l3=r(7,12,10,2,0); l3.BackgroundColor3=Color3.fromRGB(100,160,255)
        local l4=r(7,16,12,2,0); l4.BackgroundColor3=Color3.fromRGB(100,160,255)
        dk(r(18,18,6,6,0))
    elseif key == "InfinitoZoom" then
        c(12,12,8); dk(c(12,12,5)); r(18,18,8,4,2); clr(r(10,10,4,4,2), Color3.fromRGB(100,200,255))
    elseif key == "CameraLivre" then
        r(4,8,20,12,3); c(14,14,4); dk(c(14,14,2)); r(2,4,4,4,1); clr(r(0,10,4,8,1), Color3.fromRGB(200,200,200))
    elseif key == "FullBright" then
        c(14,14,6); for i=0,7 do local a=math.rad(i*45) r(14+math.cos(a)*10-1,14+math.sin(a)*10-1,2,2,1) end
    elseif key == "InfiniteJump" then
        r(12,0,4,10,1); clr(r(8,4,12,4,1), Color3.fromRGB(255,255,255)); r(12,12,4,10,1); clr(r(8,16,12,4,1), Color3.fromRGB(255,255,255))
    elseif key == "SlopeBoost" then
        r(2,14,24,4,2); r(18,6,8,8,1); clr(r(20,8,4,4,1), Color3.fromRGB(100,255,100))
    elseif key == "GodMode" then
        r(4,2,20,22,5); clr(r(12,6,4,14,1), Color3.fromRGB(255,255,255)); clr(r(7,11,14,4,1), Color3.fromRGB(255,255,255))
    end
    return cont
end

-- ══════════════════════════════════════════════════════
--  ÍCONES PLAYER (28x28) — NOVO
-- ══════════════════════════════════════════════════════
local function criarIconePlayer(parent, key, cor)
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
    local function clr(f,rgb) f.BackgroundColor3=rgb; return f end

    if key == "Speed" then
        -- Relâmpago / Lightning bolt
        r(16,0,10,14,2)          -- parte superior do raio
        r(8,10,12,2,1)           -- barra diagonal meio
        r(2,12,12,16,2)          -- parte inferior do raio
        clr(r(18,2,6,10,1), Color3.fromRGB(255,255,200))  -- brilho
    elseif key == "JumpPower" then
        -- Pessoa pulando com seta para cima
        c(14,5,4)                -- cabeça
        r(11,10,6,8,2)           -- corpo
        r(8,14,4,8,1)            -- perna esq
        r(16,14,4,8,1)           -- perna dir
        -- seta cima
        r(12,0,4,7,1)            -- haste seta
        clr(r(6,3,6,5,1), Color3.fromRGB(255,220,60))   -- ponta esq seta
        clr(r(16,3,6,5,1), Color3.fromRGB(255,220,60))  -- ponta dir seta
    elseif key == "Fly" then
        -- Asas abertas + personagem no centro
        r(0,10,10,6,3)           -- asa esquerda
        r(18,10,10,6,3)          -- asa direita
        r(1,7,8,4,2)             -- asa esq alta
        r(19,7,8,4,2)            -- asa dir alta
        c(14,10,4)               -- corpo
        clr(r(4,12,6,2,1), Color3.fromRGB(200,220,255))  -- detalhe asa esq
        clr(r(18,12,6,2,1), Color3.fromRGB(200,220,255)) -- detalhe asa dir
    elseif key == "Noclip" then
        -- Fantasma atravessando parede
        -- parede
        clr(r(0,4,10,20,2), Color3.fromRGB(80,90,110))
        -- fantasma (metade dentro, metade fora)
        c(18,8,6)                -- cabeça fantasma
        r(12,8,12,14,1)          -- corpo fantasma
        r(12,20,4,4,2)           -- cauda esq
        r(18,20,4,4,2)           -- cauda mei
        r(20,20,4,4,2)           -- cauda dir
        dk(c(17,7,2))            -- olho esq
        dk(c(21,7,2))            -- olho dir
    elseif key == "TpClick" then
        -- Cursor com efeito de teleporte
        r(2,0,4,20,1)            -- haste cursor
        r(2,0,18,4,1)            -- cabeça cursor
        r(2,8,10,2,1)            -- meio cursor
        r(10,8,10,2,1)           -- braço cursor
        clr(r(16,0,10,14,2), Color3.fromRGB(255,230,50))   -- estrela tp
        clr(r(14,6,12,8,2), Color3.fromRGB(255,230,50))    -- brilho tp
        dk(r(18,2,6,10,2))       -- buraco estrela
    elseif key == "BauANC" then
        -- Baú com raio (abertura instantânea)
        r(2,10,24,14,3)          -- corpo do baú
        r(2,6,24,6,2)            -- tampa do baú
        clr(r(10,14,8,6,2), Color3.fromRGB(255,200,50))  -- cadeado
        dk(r(12,10,4,3,1))       -- buraco cadeado
        -- raio no canto
        clr(r(18,0,8,12,2), Color3.fromRGB(255,220,60))  -- raio cima
        clr(r(14,8,8,10,2), Color3.fromRGB(255,220,60))  -- raio baixo
        dk(r(20,2,4,8,1))        -- contorno raio
    elseif key == "InfinitoZoom" then
        -- Lupa com símbolo de infinito
        c(10,10,7)               -- círculo lupa externo
        dk(c(10,10,5))           -- anel lupa
        c(10,10,2)               -- centro lupa
        r(15,15,8,3,1)           -- cabo lupa diagonal
        -- símbolo de mais (zoom in)
        clr(r(7,7,6,2,1), Color3.fromRGB(100,220,255))   -- barra horiz inf
        clr(r(9,5,2,6,1), Color3.fromRGB(100,220,255))   -- barra vert inf
    elseif key == "CameraLivre" then
        -- Câmera com seta atravessando parede
        r(3,7,18,13,3)           -- corpo câmera
        c(12,13,4)               -- lente câmera
        dk(c(12,13,2))           -- pupila lente
        r(18,4,8,5,2)            -- flash câmera (topo dir)
        -- seta atravessando (indicando noclip)
        clr(r(0,12,8,3,1), Color3.fromRGB(255,120,60))   -- seta esq
        clr(r(0,9,3,9,1), Color3.fromRGB(255,120,60))    -- ponta seta
        clr(r(0,15,3,9,1), Color3.fromRGB(255,120,60))   -- ponta seta baixo
    elseif key == "FullBright" then
        -- Sol brilhante com raios fortes
        c(14,14,6)               -- sol centro
        dk(c(14,14,3))           -- núcleo sol
        -- raios sol
        r(12,0,4,5,2)            -- raio cima
        r(12,23,4,5,2)           -- raio baixo
        r(0,12,5,4,2)            -- raio esq
        r(23,12,5,4,2)           -- raio dir
        clr(r(3,3,4,4,2), Color3.fromRGB(255,240,100))   -- raio diagonal
        clr(r(21,3,4,4,2), Color3.fromRGB(255,240,100))  -- raio diagonal
        clr(r(3,21,4,4,2), Color3.fromRGB(255,240,100))  -- raio diagonal
        clr(r(21,21,4,4,2), Color3.fromRGB(255,240,100)) -- raio diagonal
    elseif key == "InfiniteJump" then
        -- Seta tripla subindo (pulo infinito)
        -- seta 1 (baixo, mais fraca)
        clr(r(11,20,6,6,1), Color3.fromRGB(100,180,255))  -- haste baixa
        clr(r(7,16,14,5,1), Color3.fromRGB(100,180,255))  -- ponta baixa
        -- seta 2 (meio)
        clr(r(11,13,6,6,1), Color3.fromRGB(150,210,255))  -- haste meio
        clr(r(7,9,14,5,1), Color3.fromRGB(150,210,255))   -- ponta meio
        -- seta 3 (topo, mais brilhante)
        r(11,6,6,6,1)            -- haste topo
        clr(r(7,2,14,5,1), Color3.fromRGB(255,255,255))   -- ponta topo
    elseif key == "SlopeBoost" then
        -- Personagem em rampa com raio (ignora slowdown)
        -- rampa/plataforma
        r(0,20,28,4,2)           -- chão
        r(0,8,8,12,2)            -- rampa/degrau
        -- personagem correndo
        c(20,6,4)                -- cabeça
        r(17,11,6,8,2)           -- corpo
        -- raio verde (velocidade mantida)
        clr(r(8,4,12,10,2), Color3.fromRGB(80,255,120))   -- raio topo
        clr(r(4,10,12,8,2), Color3.fromRGB(80,255,120))   -- raio baixo
        dk(r(10,7,6,4,1))        -- contorno raio
    elseif key == "GodMode" then
        -- Escudo brilhante com estrela (deus imortal)
        r(4,2,20,22,8)           -- escudo externo
        clr(r(6,4,16,16,6), Color3.fromRGB(255,200,50))   -- escudo dourado
        dk(r(8,6,12,12,4))       -- escudo interior
        -- estrela no centro
        clr(r(11,8,6,12,1), Color3.fromRGB(255,240,100))  -- barra vert estrela
        clr(r(7,12,14,4,1), Color3.fromRGB(255,240,100))  -- barra horiz estrela
        -- brilho no topo
        clr(c(14,2,3), Color3.fromRGB(255,255,200))        -- brilho topo
-- ══════════════════════════════════════════════════════
local function criarIconeAvancado(parent, key, cor)
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
    local function clr(f,rgb) f.BackgroundColor3=rgb; return f end

    if key == "Aimbot" then
        -- Mira/Crosshair com alvo teleguiado
        c(14,14,12)              -- círculo externo
        dk(c(14,14,9))           -- anel
        c(14,14,5)               -- círculo meio
        dk(c(14,14,2))           -- ponto central
        -- linhas da mira
        r(0,13,5,2,1)            -- linha esq
        r(23,13,5,2,1)           -- linha dir
        r(13,0,2,5,1)            -- linha cima
        r(13,23,2,5,1)           -- linha baixo
        -- triangulo indicando guia
        clr(r(20,0,6,4,1), Color3.fromRGB(255,80,80))   -- indicador
        clr(r(22,0,2,8,1), Color3.fromRGB(255,80,80))

    elseif key == "AimbotAuto" then
        -- Mira com símbolo AUTO (robô/engrenagem)
        c(12,14,10)              -- círculo externo
        dk(c(12,14,7))           -- anel
        c(12,14,4)               -- ponto
        dk(c(12,14,1))           -- centro
        -- linhas mira
        r(0,13,3,2,1)
        r(21,13,3,2,1)
        r(11,2,2,4,1)
        r(11,22,2,4,1)
        -- engrenagem AUTO no canto
        c(22,6,5)                -- engrenagem
        dk(c(22,6,3))            -- furo engrenagem
        -- dentes engrenagem
        r(21,0,2,4,1)
        r(21,8,2,4,1)
        r(16,5,4,2,1)
        r(22,5,4,2,1) -- erro intencional: usa var
        -- relâmpago auto
        clr(r(19,2,6,8,1), Color3.fromRGB(255,230,60))
        clr(r(16,6,6,6,1), Color3.fromRGB(255,230,60))
        dk(r(21,4,2,4,1))
    elseif key == "InfinitoZoom" then
        c(12,12,8); dk(c(12,12,5)); r(18,18,8,4,2); clr(r(10,10,4,4,2), Color3.fromRGB(100,200,255))
    elseif key == "CameraLivre" then
        r(4,8,20,12,3); c(14,14,4); dk(c(14,14,2)); r(2,4,4,4,1); clr(r(0,10,4,8,1), Color3.fromRGB(200,200,200))
    elseif key == "FullBright" then
        c(14,14,6); for i=0,7 do local a=math.rad(i*45) r(14+math.cos(a)*10-1,14+math.sin(a)*10-1,2,2,1) end
    elseif key == "InfiniteJump" then
        r(12,0,4,10,1); clr(r(8,4,12,4,1), Color3.fromRGB(255,255,255)); r(12,12,4,10,1); clr(r(8,16,12,4,1), Color3.fromRGB(255,255,255))
    elseif key == "SlopeBoost" then
        r(2,14,24,4,2); r(18,6,8,8,1); clr(r(20,8,4,4,1), Color3.fromRGB(100,255,100))
    elseif key == "GodMode" then
        r(4,2,20,22,5); clr(r(12,6,4,14,1), Color3.fromRGB(255,255,255)); clr(r(7,11,14,4,1), Color3.fromRGB(255,255,255))
    end
    return cont
end

-- ════════════════════════════════════════════════════════
--  SISTEMA ESP v4 — 20 categorias
-- ════════════════════════════════════════════════════════
local EspCanvas = Instance.new("Frame", ScreenGui)
EspCanvas.BackgroundTransparency = 1; EspCanvas.Size = UDim2.new(1,0,1,0); EspCanvas.ZIndex = 1

local ESP_CATS = {
    {key="Players",      label="👤 Players",            cor=Color3.fromRGB(255,80,80),   tipo="player", alcance=math.huge, desc="Todos os players no servidor"},
    {key="Kids",         label="👶 Crianças Perdidas",   cor=Color3.fromRGB(100,220,255), tipo="entity", alcance=math.huge, desc="Dino, Kraken, Squid, Koala Kid",
     nomes={"Dino Kid","Kraken Kid","Squid Kid","Koala Kid","DinoKid","KrakenKid","SquidKid","KoalaKid","Kid","Child","MissingChild"}},
    {key="AnimPassivo",  label="🐰 Animais Passivos",    cor=Color3.fromRGB(130,255,170), tipo="entity", alcance=500, desc="Bunny, Horse, Kiwi, Turkey",
     nomes={"Bunny","Horse","Kiwi","Turkey"}},
    {key="AnimAgressivo",label="🐺 Animais Agressivos",  cor=Color3.fromRGB(255,175,30),  tipo="entity", alcance=600, desc="Wolf, Bear, Polar Bear, Frog (Verde/Azul/Roxo), Scorpion…",
     nomes={"Wolf","Alpha Wolf","AlphaWolf","Bear","Polar Bear","PolarBear","Arctic Fox","ArcticFox","Frog","Blue Frog","Purple Frog","Green Frog","BlueFrog","PurpleFrog","GreenFrog","Scorpion","Hellephant","Meteor Crab","MeteorCrab","Mammoth"}},
    {key="Monstros",     label="💀 Monstros",            cor=Color3.fromRGB(255,50,50),   tipo="entity", alcance=math.huge, desc="The Deer, The Owl, The Ram (imortais)",
     nomes={"The Deer","TheDeer","Deer","The Owl","TheOwl","Owl","The Ram","TheRam","Ram"}},
    {key="Cultistas",    label="⚔️ Cultistas",           cor=Color3.fromRGB(195,60,200),  tipo="entity", alcance=math.huge, desc="Cultist, Crossbow, Juggernaut, King, Mega Cultist…",
     nomes={"Cultist","Melee Cultist","MeleeCultist","Crossbow Cultist","CrossbowCultist","Juggernaut Cultist","JuggernautCultist","Juggernaut","Cultist King","CultistKing","Mega Cultist","MegaCultist"}},
    {key="Aliens",       label="👽 Aliens",              cor=Color3.fromRGB(60,255,200),  tipo="entity", alcance=700, desc="Alien, Elite Alien",
     nomes={"Alien","Elite Alien","EliteAlien","NormalAlien"}},
    {key="EspLog",       label="🪵 Log",                 cor=Color3.fromRGB(190,130,60),  tipo="item",   alcance=400, desc="Log — combustível principal", nomes={"Log"}},
    {key="EspCombustivel",label="🔥 Combustível",        cor=Color3.fromRGB(255,120,30),  tipo="item",   alcance=400, desc="Coal, Biofuel, Fuel Canister, Oil Barrel…",
     nomes={"Coal","Biofuel","Oil Barrel","OilBarrel","Fuel Canister","FuelCanister","Purple Fur Tuft","PurpleFurTuft","Chair"}},
    {key="EspCarcacas",  label="🦴 Carcaças",            cor=Color3.fromRGB(180,100,50),  tipo="item",   alcance=350, desc="Wolf/Bear/PolarBear/Mammoth/Hellephant/Frog Corpse…",
     nomes={"Wolf Corpse","WolfCorpse","Alpha Wolf Corpse","AlphaWolfCorpse","Bear Corpse","BearCorpse","Polar Bear Corpse","PolarBearCorpse","Arctic Fox Corpse","ArcticFoxCorpse","Mammoth Corpse","MammothCorpse","Hellephant Corpse","HellephantCorpse","Frog Corpse","FrogCorpse","Cultist Corpse","CultistCorpse","Crossbow Cultist Corpse","CrossbowCultistCorpse","Juggernaut Cultist Corpse","JuggernautCultistCorpse","Cultist King Corpse","CultistKingCorpse","Alien Corpse","AlienCorpse","Elite Alien Corpse","EliteAlienCorpse"}},
    {key="EspSucata",    label="🔩 Sucata",              cor=Color3.fromRGB(155,210,255), tipo="item",   alcance=400, desc="Bolt, Sheet Metal, UFO Junk, Tyre…",
     nomes={"Bolt","Sheet Metal","SheetMetal","UFO Junk","UFOJunk","UFO Component","UFOComponent","UFO Scrap","UFOScrap","Broken Fan","BrokenFan","Old Radio","OldRadio","Broken Radio","BrokenRadio","Broken Microwave","BrokenMicrowave","Tyre","Metal Chair","MetalChair","Old Car Engine","OldCarEngine","Washing Machine","WashingMachine","Cultist Experiment","CultistExperiment","Cultist Prototype","CultistPrototype"}},
    {key="EspMateriais", label="💎 Materiais",           cor=Color3.fromRGB(220,175,255), tipo="item",   alcance=400, desc="Cultist Gem, Forest Gem, Mossy Coin, Obsidiron…",
     nomes={"Cultist Gem","CultistGem","Forest Gem","ForestGem","Forest Gem Fragment","ForestGemFragment","Mossy Coin","MossyCoin","Flower","Sapling","Sacrifice Totem","SacrificeTotem","Meteor Shard","MeteorShard","Gold Shard","GoldShard","Raw Obsidiron Ore","RawObsidironOre","Obsidiron Ingot","ObsidironIngot","Scalding Obsidiron Ingot","ScaldingObsidironIngot","Raw Obsidiron Ore Shard"}},
    {key="EspComidas",   label="🍖 Comidas",             cor=Color3.fromRGB(255,115,165), tipo="item",   alcance=350, desc="Carrot, Corn, Berry, Steak, Ribs, Stew, Candy…",
     nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake","Morsel","Cooked Morsel","CookedMorsel","Steak","Cooked Steak","CookedSteak","Ribs","Cooked Ribs","CookedRibs","Stew","Hearty Stew","HeartyStew","Meat? Sandwich","Seafood Chowder","Steak Dinner","Pumpkin Soup","BBQ Ribs","Carrot Cake","Jar o' Jelly","Candy Apple","Candy Corn","Pumpkin Pie","Cotton Candy","Turkey Leg","Cooked Turkey Leg","Stuffing","Sweet Potato","Berry Juice","Casserole","Corn on the Cob","Stuffing Bowl","Roast Turkey","Stuffed Peppers","Sweet Potato Pie","Spicy Swordfish","Hearty Thanksgiving Meal"}},
    {key="EspPeixes",    label="🐟 Peixes",              cor=Color3.fromRGB(80,180,255),  tipo="item",   alcance=400, desc="Mackerel, Salmon, Clownfish, Shark, Lava Eel…",
     nomes={"Mackerel","Cooked Mackerel","CookedMackerel","Salmon","Cooked Salmon","CookedSalmon","Clownfish","Cooked Clownfish","CookedClownfish","Jellyfish","Char","Cooked Char","CookedChar","Eel","Cooked Eel","CookedEel","Swordfish","Cooked Swordfish","CookedSwordfish","Shark","Cooked Shark","CookedShark","Lava Eel","LavaEel","Cooked Lava Eel","CookedLavaEel","Lionfish","Cooked Lionfish","CookedLionfish"}},
    {key="EspSementes",  label="🌱 Sementes",            cor=Color3.fromRGB(135,245,115), tipo="item",   alcance=350, desc="Chili, Berry, Flower, Firefly, Dripleaf…",
     nomes={"Chili Seeds","ChiliSeeds","Flower Seeds","FlowerSeeds","Berry Seeds","BerrySeeds","Firefly Seeds","FireflySeeds","Dripleaf Seeds","DripleafSeeds","Moonflower Seeds","MoonflowerSeeds","Stareweed Seeds","StareweedSeeds","Cavevine Seeds","CavevineSeeds","Mandrake Seeds","MandrakeSeeds"}},
    {key="EspFerr",      label="🪓 Ferramentas & Armaduras", cor=Color3.fromRGB(255,200,55), tipo="item", alcance=500, desc="Axes, Sacks, Rods, Flutes, Leather Body, Alien Armour…",
     nomes={"Old Sack","OldSack","Good Sack","GoodSack","Infernal Sack","InfernalSack","Giant Sack","GiantSack","Old Axe","OldAxe","Good Axe","GoodAxe","Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw","Old Rod","OldRod","Good Rod","GoodRod","Strong Rod","StrongRod","Old Taming Flute","OldFlute","Good Taming Flute","GoodFlute","Strong Taming Flute","StrongFlute","Old Flashlight","OldFlashlight","Strong Flashlight","StrongFlashlight","Axe Trim Kit","AxeTrimKit","Armor Trim Kit","ArmorTrimKit","Hammer","Paint Brush","PaintBrush","Watering Can","WateringCan","Cultist Staff","CultistStaff","Leather Body","LeatherBody","Alien Armour","AlienArmour","Frog Boots","FrogBoots","Poison Armour","PoisonArmour"}},
    {key="EspArmas",     label="⚔️ Armas",              cor=Color3.fromRGB(255,70,70),   tipo="item",   alcance=500, desc="Spear, Crossbow, Ice Sword, Revolver, Rifle…",
     nomes={"Spear","Morningstar","Katana","Laser Sword","LaserSword","Ice Sword","IceSword","Trident","Poison Spear","PoisonSpear","Infernal Sword","InfernalSword","Obsidiron Hammer","ObsidironHammer","Scythe","Crossbow","Infernal Crossbow","InfernalCrossbow","Bouncing Blade","BouncingBlade","Vampire Scythe","VampireScythe","Revolver","Rifle","Tactical Shotgun","TacticalShotgun","Ray Gun","RayGun","Laser Cannon","LaserCannon","Flamethrower","Snowball","Frozen Shuriken","FrozenShuriken","Kunai","Witch Potion","WitchPotion","Wildfire","Blowpipe","Air Rifle","AirRifle"}},
    {key="EspAmmo",      label="🔫 Munição",             cor=Color3.fromRGB(255,155,60),  tipo="item",   alcance=400, desc="Revolver Ammo, Rifle Ammo, Shotgun Ammo",
     nomes={"Revolver Ammo","RevolverAmmo","Rifle Ammo","RifleAmmo","Shotgun Ammo","ShotgunAmmo"}},
    {key="EspCura",      label="💊 Cura & Pelts",        cor=Color3.fromRGB(120,255,200), tipo="item",   alcance=450, desc="Bandage, Medkit, Wolf Pelt, Bear Pelt…",
     nomes={"Bandage","Medkit","Bunny Foot","BunnyFoot","Wolf Pelt","WolfPelt","Alpha Wolf Pelt","AlphaWolfPelt","Bear Pelt","BearPelt","Arctic Fox Pelt","ArcticFoxPelt","Polar Bear Pelt","PolarBearPelt","Mammoth Tusk","MammothTusk","Scorpion Shell","ScorpionShell","Cultist King Antler","CultistKingAntler"}},
    {key="EspChaves",    label="🗝️ Chaves",              cor=Color3.fromRGB(255,230,80),  tipo="item",   alcance=math.huge, desc="Red, Blue, Yellow, Grey, Frog Key",
     nomes={"Red Key","RedKey","Blue Key","BlueKey","Yellow Key","YellowKey","Grey Key","GreyKey","Frog Key","FrogKey"}},
    {key="EspBigorna",   label="⚙️ Partes de Bigorna",   cor=Color3.fromRGB(200,160,255), tipo="item",   alcance=math.huge, desc="Anvil Front/Back/Base + Meteor Anvil",
     nomes={"Anvil Front","AnvilFront","Anvil Back","AnvilBack","Anvil Base","AnvilBase","Meteor Anvil Front","MeteorAnvilFront","Meteor Anvil Back","MeteorAnvilBack","Meteor Anvil Base","MeteorAnvilBase"}},
    {key="EspPocoes",    label="🧪 Poções",              cor=Color3.fromRGB(195,100,255), tipo="item",   alcance=400, desc="Dripleaf, Moonflower Bulb, Stareweed Petal…",
     nomes={"Dripleaf","Moonflower Bulb","MoonflowerBulb","Stareweed Petal","StareweedPetal","Cave Vine Flower","CaveVineFlower","Mandrake"}},
    {key="EspBlueprint", label="📋 Blueprints",          cor=Color3.fromRGB(130,190,255), tipo="item",   alcance=500, desc="Crafting, Defense, Furniture, Obsidiron Chest…",
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

local entityCache={}; local itemCache={}; local cacheBuilding=false; local lastCache=0; local CACHE_INTER=5
local function isAlive(model)
    local hum=model:FindFirstChildWhichIsA("Humanoid"); if not hum then return false end
    if hum.Health<=0 or hum.MaxHealth<=0 then return false end
    local hrp=model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not hrp then return false end
    local pos=hrp.Position; if pos.Y<-400 or pos.Magnitude>6000 then return false end
    return true
end
local function anyEspActive(tipo)
    for _,c in ipairs(ESP_CATS) do if espAtivo[c.key] and c.tipo==tipo then return true end end; return false
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
        local batch=0
        for _,obj in ipairs(descs) do
            batch+=1; if batch%100==0 then task.wait() end
            if not obj or not obj.Parent then continue end
            local nl=obj.Name:lower()
            if doEnt and obj:IsA("Model") then
                if not pchars[obj] and isAlive(obj) then
                    for _,c in ipairs(ESP_CATS) do
                        if espAtivo[c.key] and c.tipo=="entity" then
                            local lk=espLookup[c.key]
                            if lk and lk[nl] then
                                local hrp=obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                                if hrp then table.insert(newEnt,{key=c.key,cor=c.cor,nome=obj.Name,alcance=c.alcance,obj=obj,hrp=hrp}) end
                                break
                            end
                        end
                    end
                end
            elseif doItem and obj:IsA("BasePart") and not obj.Anchored then
                if not pchars[obj] then
                    local isNPC=false; local p=obj.Parent
                    for _=1,3 do if p and p:IsA("Model") and p:FindFirstChildWhichIsA("Humanoid") then isNPC=true; break end; p=p and p.Parent end
                    if not isNPC then
                        for _,c in ipairs(ESP_CATS) do
                            if espAtivo[c.key] and c.tipo=="item" then
                                local lk=espLookup[c.key]
                                if lk and lk[nl] then table.insert(newItem,{key=c.key,cor=c.cor,nome=obj.Name,alcance=c.alcance,obj=obj}); break end
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
            local cell=math.floor(sp.X/12)..","..math.floor(sp.Y/12)
            if seen[cell] then return end; seen[cell]=true
            showLabel(e.cor,e.nome,dist,sp.X,sp.Y)
        end)
    end
    for _,e in ipairs(itemCache) do
        pcall(function()
            if not espAtivo[e.key] or not e.obj or not e.obj.Parent then return end
            if e.obj.Anchored then return end
            local pos=e.obj.Position; local dist=(pos-charPos).Magnitude; if dist>e.alcance then return end
            local sp,vis=Cam:WorldToViewportPoint(pos+Vector3.new(0,0.8,0))
            if not vis or sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
            local cell=math.floor(sp.X/10)..","..math.floor(sp.Y/10)
            if seen[cell] then return end; seen[cell]=true
            showLabel(e.cor,e.nome,dist,sp.X,sp.Y)
        end)
    end
end)

-- UI da aba ESP
local espTabLO=0
local function espLO() espTabLO+=1; return espTabLO end
local function makeEspSection(titulo,cor)
    local hdr=Instance.new("Frame",Pages["Esp"]); hdr.BackgroundColor3=Color3.fromRGB(20,22,30)
    hdr.BackgroundTransparency=0.3; hdr.BorderSizePixel=0; hdr.Size=UDim2.new(1,0,0,22); hdr.LayoutOrder=espLO(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",hdr); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Position=UDim2.new(0,0,0,0); bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=5
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,0)
    lbl.Size=UDim2.new(1,-14,1,0); lbl.Font=Enum.Font.GothamBlack; lbl.Text=titulo
    lbl.TextColor3=cor; lbl.TextSize=9; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
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
    local labelDesc=Instance.new("TextLabel",row); labelDesc.BackgroundTransparency=1
    labelDesc.Position=UDim2.new(0,50,0,26); labelDesc.Size=UDim2.new(1,-110,0,20)
    labelDesc.Font=Enum.Font.Gotham; labelDesc.Text=cat.desc or ""; labelDesc.TextColor3=Color3.fromRGB(90,100,120)
    labelDesc.TextSize=9; labelDesc.TextXAlignment=Enum.TextXAlignment.Left; labelDesc.TextWrapped=true; labelDesc.ZIndex=6
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(45,50,62); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-52,0.5,-11); pill.Size=UDim2.new(0,42,0,22); pill.ZIndex=7
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(160,170,185); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,2,0.5,-9); knob.Size=UDim2.new(0,18,0,18); knob.ZIndex=8
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local estado=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=9
    btn.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(34,37,45)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(30,32,38)}):Play() end)
    btn.MouseButton1Click:Connect(function()
        estado=not estado; espAtivo[cat.key]=estado; lastCache=0
        TweenService:Create(pill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundColor3=estado and cat.cor or Color3.fromRGB(45,50,62)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=estado and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
            BackgroundColor3=estado and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185),
        }):Play()
        TweenService:Create(rowStroke,TweenInfo.new(0.2),{Color=estado and cat.cor or Color3.fromRGB(45,48,58)}):Play()
    end)
end

local espCatMap={}; for _,c in ipairs(ESP_CATS) do espCatMap[c.key]=c end
local espGroupOrder={
    {"ESP — Entidades",              Color3.fromRGB(88,101,242),  {"Players","Kids","AnimPassivo","AnimAgressivo","Monstros","Cultistas","Aliens"}},
    {"ESP — Recursos & Combustível", Color3.fromRGB(255,130,40),  {"EspLog","EspCombustivel","EspCarcacas","EspSucata","EspMateriais"}},
    {"ESP — Comida & Natureza",      Color3.fromRGB(255,120,170), {"EspComidas","EspPeixes","EspSementes","EspPocoes"}},
    {"ESP — Equipamentos",           Color3.fromRGB(255,200,55),  {"EspFerr","EspArmas","EspAmmo","EspCura","EspChaves","EspBigorna","EspBlueprint"}},
}
for _,grp in ipairs(espGroupOrder) do
    local titulo,cor,keys=grp[1],grp[2],grp[3]
    makeEspSection(titulo,cor)
    for _,k in ipairs(keys) do if espCatMap[k] then makeEspRow(espCatMap[k]) end end
end

-- ════════════════════════════════════════════════════════
--  SISTEMA BRING v4
-- ════════════════════════════════════════════════════════
local BRING_CATS = {
    {key="BLog",      label="🪵 Bring Log",         cor=Color3.fromRGB(190,130,60),  desc="Só pega: Log", nomes={"Log"}},
    {key="BCombust",  label="🔥 Bring Combustível", cor=Color3.fromRGB(255,120,30),  desc="Coal, Biofuel, Fuel Canister, Oil Barrel…",
     nomes={"Coal","Biofuel","Oil Barrel","OilBarrel","Fuel Canister","FuelCanister","Purple Fur Tuft","PurpleFurTuft","Chair"}},
    {key="BCarcacas", label="🦴 Bring Carcaças",    cor=Color3.fromRGB(180,100,50),  desc="Wolf, Bear, PolarBear, Hellephant, Frog, Alien Corpse…",
     nomes={"Wolf Corpse","WolfCorpse","Alpha Wolf Corpse","AlphaWolfCorpse","Bear Corpse","BearCorpse","Polar Bear Corpse","PolarBearCorpse","Arctic Fox Corpse","ArcticFoxCorpse","Mammoth Corpse","MammothCorpse","Hellephant Corpse","HellephantCorpse","Frog Corpse","FrogCorpse","Cultist Corpse","CultistCorpse","Crossbow Cultist Corpse","CrossbowCultistCorpse","Juggernaut Cultist Corpse","JuggernautCultistCorpse","Cultist King Corpse","CultistKingCorpse","Alien Corpse","AlienCorpse","Elite Alien Corpse","EliteAlienCorpse"}},
    {key="BSucata",   label="🔩 Bring Sucata",      cor=Color3.fromRGB(155,210,255), desc="Bolt, Sheet Metal, UFO Junk, Tyre…",
     nomes={"Bolt","Sheet Metal","SheetMetal","UFO Junk","UFOJunk","UFO Component","UFOComponent","UFO Scrap","UFOScrap","Broken Fan","BrokenFan","Old Radio","OldRadio","Broken Radio","BrokenRadio","Broken Microwave","BrokenMicrowave","Tyre","Metal Chair","MetalChair","Old Car Engine","OldCarEngine","Washing Machine","WashingMachine","Cultist Experiment","CultistExperiment","Cultist Prototype","CultistPrototype"}},
    {key="BMateriais",label="💎 Bring Materiais",   cor=Color3.fromRGB(220,175,255), desc="Cultist Gem, Forest Gem, Mossy Coin…",
     nomes={"Cultist Gem","CultistGem","Forest Gem","ForestGem","Forest Gem Fragment","ForestGemFragment","Mossy Coin","MossyCoin","Flower","Sapling","Sacrifice Totem","SacrificeTotem","Meteor Shard","MeteorShard","Gold Shard","GoldShard","Raw Obsidiron Ore","RawObsidironOre","Obsidiron Ingot","ObsidironIngot","Scalding Obsidiron Ingot"}},
    {key="BComidas",  label="🍖 Bring Comidas",     cor=Color3.fromRGB(255,115,165), desc="Carrot, Corn, Steak, Ribs, Stew, Candy…",
     nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake","Morsel","Cooked Morsel","CookedMorsel","Steak","Cooked Steak","CookedSteak","Ribs","Cooked Ribs","CookedRibs","Stew","Hearty Stew","HeartyStew","Meat? Sandwich","Seafood Chowder","Steak Dinner","Pumpkin Soup","BBQ Ribs","Carrot Cake","Jar o' Jelly","Candy Apple","Candy Corn","Pumpkin Pie","Cotton Candy","Turkey Leg","Cooked Turkey Leg","Stuffing","Sweet Potato","Berry Juice","Casserole","Corn on the Cob","Stuffing Bowl","Roast Turkey","Stuffed Peppers","Sweet Potato Pie","Spicy Swordfish","Hearty Thanksgiving Meal"}},
    {key="BPeixes",   label="🐟 Bring Peixes",      cor=Color3.fromRGB(80,180,255),  desc="Mackerel, Salmon, Clownfish, Shark, Lava Eel…",
     nomes={"Mackerel","Cooked Mackerel","CookedMackerel","Salmon","Cooked Salmon","CookedSalmon","Clownfish","Cooked Clownfish","CookedClownfish","Jellyfish","Char","Cooked Char","CookedChar","Eel","Cooked Eel","CookedEel","Swordfish","Cooked Swordfish","CookedSwordfish","Shark","Cooked Shark","CookedShark","Lava Eel","LavaEel","Cooked Lava Eel","CookedLavaEel","Lionfish","Cooked Lionfish","CookedLionfish"}},
    {key="BSementes", label="🌱 Bring Sementes",    cor=Color3.fromRGB(135,245,115), desc="Chili, Berry, Flower, Dripleaf, Moonflower…",
     nomes={"Chili Seeds","ChiliSeeds","Flower Seeds","FlowerSeeds","Berry Seeds","BerrySeeds","Firefly Seeds","FireflySeeds","Dripleaf Seeds","DripleafSeeds","Moonflower Seeds","MoonflowerSeeds","Stareweed Seeds","StareweedSeeds","Cavevine Seeds","CavevineSeeds","Mandrake Seeds","MandrakeSeeds"}},
    {key="BFerr",     label="🪓 Bring Ferramentas", cor=Color3.fromRGB(255,200,55),  desc="Sacks, Axes, Rods, Flutes, Armaduras…",
     nomes={"Old Sack","OldSack","Good Sack","GoodSack","Infernal Sack","InfernalSack","Giant Sack","GiantSack","Old Axe","OldAxe","Good Axe","GoodAxe","Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw","Old Rod","OldRod","Good Rod","GoodRod","Strong Rod","StrongRod","Old Taming Flute","OldFlute","Good Taming Flute","GoodFlute","Strong Taming Flute","StrongFlute","Old Flashlight","OldFlashlight","Strong Flashlight","StrongFlashlight","Axe Trim Kit","AxeTrimKit","Armor Trim Kit","ArmorTrimKit","Hammer","Paint Brush","PaintBrush","Watering Can","WateringCan","Leather Body","LeatherBody","Alien Armour","AlienArmour","Frog Boots","FrogBoots","Poison Armour","PoisonArmour"}},
    {key="BArmas",    label="⚔️ Bring Armas",       cor=Color3.fromRGB(255,70,70),   desc="Spear, Ice Sword, Crossbow, Revolver, Rifle…",
     nomes={"Spear","Morningstar","Katana","Laser Sword","LaserSword","Ice Sword","IceSword","Trident","Poison Spear","PoisonSpear","Infernal Sword","InfernalSword","Obsidiron Hammer","ObsidironHammer","Scythe","Crossbow","Infernal Crossbow","InfernalCrossbow","Bouncing Blade","BouncingBlade","Vampire Scythe","VampireScythe","Revolver","Rifle","Tactical Shotgun","TacticalShotgun","Ray Gun","RayGun","Laser Cannon","LaserCannon","Flamethrower","Snowball","Frozen Shuriken","FrozenShuriken","Kunai","Witch Potion","WitchPotion","Wildfire","Blowpipe","Air Rifle","AirRifle"}},
    {key="BAmmo",     label="🔫 Bring Munição",     cor=Color3.fromRGB(255,155,60),  desc="Revolver Ammo, Rifle Ammo, Shotgun Ammo",
     nomes={"Revolver Ammo","RevolverAmmo","Rifle Ammo","RifleAmmo","Shotgun Ammo","ShotgunAmmo"}},
    {key="BCura",     label="💊 Bring Cura",        cor=Color3.fromRGB(100,255,180), desc="Bandage, Medkit",
     nomes={"Bandage","Medkit"}},
    {key="BPelts",    label="🦺 Bring Pelts",       cor=Color3.fromRGB(210,170,120), desc="Bunny Foot, Wolf Pelt, Bear Pelt, Arctic Fox…",
     nomes={"Bunny Foot","BunnyFoot","Wolf Pelt","WolfPelt","Alpha Wolf Pelt","AlphaWolfPelt","Bear Pelt","BearPelt","Arctic Fox Pelt","ArcticFoxPelt","Polar Bear Pelt","PolarBearPelt","Mammoth Tusk","MammothTusk","Scorpion Shell","ScorpionShell","Cultist King Antler","CultistKingAntler"}},
    {key="BChaves",   label="🗝️ Bring Chaves",      cor=Color3.fromRGB(255,230,80),  desc="Red, Blue, Yellow, Grey, Frog Key",
     nomes={"Red Key","RedKey","Blue Key","BlueKey","Yellow Key","YellowKey","Grey Key","GreyKey","Frog Key","FrogKey"}},
    {key="BBigorna",  label="⚙️ Bring Bigorna",     cor=Color3.fromRGB(200,160,255), desc="Anvil Front/Back/Base + Meteor Anvil Parts",
     nomes={"Anvil Front","AnvilFront","Anvil Back","AnvilBack","Anvil Base","AnvilBase","Meteor Anvil Front","MeteorAnvilFront","Meteor Anvil Back","MeteorAnvilBack","Meteor Anvil Base","MeteorAnvilBase"}},
    {key="BPocoes",   label="🧪 Bring Poções",      cor=Color3.fromRGB(195,100,255), desc="Dripleaf, Moonflower Bulb, Stareweed, Mandrake",
     nomes={"Dripleaf","Moonflower Bulb","MoonflowerBulb","Stareweed Petal","StareweedPetal","Cave Vine Flower","CaveVineFlower","Mandrake"}},
    {key="BBlueprint",label="📋 Bring Blueprints",  cor=Color3.fromRGB(130,190,255), desc="Crafting, Defense, Furniture, Obsidiron Chest…",
     nomes={"Crafting Blueprint","CraftingBlueprint","Defense Blueprint","DefenseBlueprint","Furniture Blueprint","FurnitureBlueprint","Obsidiron Chest Blueprint","ObsidironChestBlueprint","Halloween Blueprint","HalloweenBlueprint"}},
}

local bringLookup={}
for _,c in ipairs(BRING_CATS) do
    local s={}; for _,n in ipairs(c.nomes) do s[n:lower()]=true end; bringLookup[c.key]=s
end

local function executarBring(key)
    local char=Player.Character; if not char then return 0 end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return 0 end
    local lookup=bringLookup[key]; if not lookup then return 0 end
    local cf=hrp.CFrame; local count=0; local trazidos={}; local batch=0
    local pchars={}; for _,pl in ipairs(Players:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end
    local ok,descs=pcall(function() return workspace:GetDescendants() end); if not ok then return 0 end
    for _,obj in ipairs(descs) do
        batch+=1
        if batch%100==0 then
            task.wait(); char=Player.Character; if not char then break end
            hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then break end; cf=hrp.CFrame
        end
        pcall(function()
            if not obj or not obj.Parent or not obj:IsA("BasePart") then return end
            if obj.Anchored then return end
            for pc in pairs(pchars) do if pc==obj or pc:IsAncestorOf(obj) then return end end
            local p=obj.Parent
            for _=1,3 do if p and p:IsA("Model") and p:FindFirstChildWhichIsA("Humanoid") then return end; p=p and p.Parent end
            if not lookup[obj.Name:lower()] then return end
            local sz=obj.Size; if sz.X>14 or sz.Y>14 or sz.Z>14 then return end
            local spread=Vector3.new(math.random(-4,4)+math.random()*0.5,0.5,math.random(-4,4)+math.random()*0.5)
            local target=cf.Position+spread
            for _,s in ipairs(obj:GetChildren()) do if s:IsA("Script") or s:IsA("LocalScript") then pcall(function() s.Disabled=true end) end end
            obj.CFrame=CFrame.new(target); obj.Velocity=Vector3.zero; obj.CanCollide=true
            count+=1; table.insert(trazidos,{obj=obj,pos=target})
        end)
    end
    if #trazidos>0 then
        task.spawn(function()
            for _=1,8 do
                task.wait(1)
                for _,e in ipairs(trazidos) do
                    pcall(function()
                        if e.obj and e.obj.Parent and e.obj:IsA("BasePart") then
                            if (e.obj.Position-e.pos).Magnitude>20 then e.obj.CFrame=CFrame.new(e.pos); e.obj.Velocity=Vector3.zero end
                        end
                    end)
                end
            end
        end)
    end
    return count
end

-- UI da aba BRING
local bringTabLO=0
local function bringLO() bringTabLO+=1; return bringTabLO end
local function makeBringSection(titulo,cor)
    local hdr=Instance.new("Frame",Pages["Bring"]); hdr.BackgroundColor3=Color3.fromRGB(20,22,30)
    hdr.BackgroundTransparency=0.3; hdr.BorderSizePixel=0; hdr.Size=UDim2.new(1,0,0,22); hdr.LayoutOrder=bringLO(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",hdr); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Position=UDim2.new(0,0,0,0); bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=5
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,0)
    lbl.Size=UDim2.new(1,-14,1,0); lbl.Font=Enum.Font.GothamBlack; lbl.Text=titulo
    lbl.TextColor3=cor; lbl.TextSize=9; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
end

local function makeBringRow(bcat)
    local row=Instance.new("Frame",Pages["Bring"]); row.BackgroundColor3=Color3.fromRGB(28,30,36)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,60); row.LayoutOrder=bringLO(); row.ZIndex=5
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
    labelNome.Position=UDim2.new(0,54,0,8); labelNome.Size=UDim2.new(1,-160,0,18)
    labelNome.Font=Enum.Font.GothamBold; labelNome.Text=bcat.label; labelNome.TextColor3=Color3.fromRGB(225,230,245)
    labelNome.TextSize=11; labelNome.TextXAlignment=Enum.TextXAlignment.Left; labelNome.ZIndex=7
    local labelDesc=Instance.new("TextLabel",row); labelDesc.BackgroundTransparency=1
    labelDesc.Position=UDim2.new(0,54,0,28); labelDesc.Size=UDim2.new(1,-160,0,24)
    labelDesc.Font=Enum.Font.Gotham; labelDesc.Text=bcat.desc or ""; labelDesc.TextColor3=Color3.fromRGB(90,100,120)
    labelDesc.TextSize=9; labelDesc.TextXAlignment=Enum.TextXAlignment.Left; labelDesc.TextWrapped=true; labelDesc.ZIndex=7
    local feedbackLbl=Instance.new("TextLabel",row); feedbackLbl.BackgroundTransparency=1
    feedbackLbl.Position=UDim2.new(1,-82,0.5,16); feedbackLbl.Size=UDim2.new(0,74,0,12)
    feedbackLbl.Font=Enum.Font.Gotham; feedbackLbl.Text=""; feedbackLbl.TextColor3=bcat.cor
    feedbackLbl.TextSize=8; feedbackLbl.TextXAlignment=Enum.TextXAlignment.Center; feedbackLbl.ZIndex=8
    local btnBring=Instance.new("TextButton",row); btnBring.BackgroundColor3=bcat.cor; btnBring.BackgroundTransparency=0.15
    btnBring.BorderSizePixel=0; btnBring.Position=UDim2.new(1,-82,0.5,-14); btnBring.Size=UDim2.new(0,74,0,28)
    btnBring.Font=Enum.Font.GothamBold; btnBring.Text="▼ BRING"; btnBring.TextColor3=Color3.fromRGB(255,255,255)
    btnBring.TextSize=10; btnBring.ZIndex=9
    Instance.new("UICorner",btnBring).CornerRadius=UDim.new(0,7)
    local btnStroke=Instance.new("UIStroke",btnBring); btnStroke.Color=bcat.cor; btnStroke.Thickness=1.2; btnStroke.Transparency=0.5
    btnBring.MouseEnter:Connect(function() TweenService:Create(btnBring,TweenInfo.new(0.12),{BackgroundTransparency=0,Size=UDim2.new(0,74,0,30),Position=UDim2.new(1,-82,0.5,-15)}):Play() end)
    btnBring.MouseLeave:Connect(function() TweenService:Create(btnBring,TweenInfo.new(0.12),{BackgroundTransparency=0.15,Size=UDim2.new(0,74,0,28),Position=UDim2.new(1,-82,0.5,-14)}):Play() end)
    local running=false
    btnBring.MouseButton1Click:Connect(function()
        if running then return end; running=true
        btnBring.Text="⏳..."; TweenService:Create(btnBring,TweenInfo.new(0.08),{BackgroundTransparency=0.4}):Play()
        task.spawn(function()
            local count=executarBring(bcat.key) or 0; task.wait(0.3)
            btnBring.Text="▼ BRING"; TweenService:Create(btnBring,TweenInfo.new(0.15),{BackgroundTransparency=0.15}):Play()
            if count>0 then
                feedbackLbl.Text="✓ "..count.." item(s)"; feedbackLbl.TextColor3=bcat.cor; feedbackLbl.TextTransparency=0
                task.delay(3,function() TweenService:Create(feedbackLbl,TweenInfo.new(0.5),{TextTransparency=1}):Play(); task.wait(0.6); feedbackLbl.Text=""; feedbackLbl.TextTransparency=0 end)
            else
                feedbackLbl.Text="✗ Nenhum item"; feedbackLbl.TextColor3=Color3.fromRGB(200,80,80); feedbackLbl.TextTransparency=0
                task.delay(2.5,function() TweenService:Create(feedbackLbl,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); feedbackLbl.Text=""; feedbackLbl.TextTransparency=0; feedbackLbl.TextColor3=bcat.cor end)
            end
            TweenService:Create(rowStroke,TweenInfo.new(0.2),{Color=bcat.cor}):Play()
            task.delay(1.5,function() TweenService:Create(rowStroke,TweenInfo.new(0.4),{Color=Color3.fromRGB(42,46,56)}):Play() end)
            task.wait(1); running=false
        end)
    end)
end

local bringCatMap={}; for _,c in ipairs(BRING_CATS) do bringCatMap[c.key]=c end
local bringGroupOrder={
    {"BRING — Combustível & Recursos", Color3.fromRGB(255,130,40), {"BLog","BCombust","BCarcacas","BSucata","BMateriais"}},
    {"BRING — Comida & Natureza",      Color3.fromRGB(255,120,170),{"BComidas","BPeixes","BSementes","BPocoes"}},
    {"BRING — Equipamentos",           Color3.fromRGB(255,200,55), {"BFerr","BArmas","BAmmo","BCura","BPelts"}},
    {"BRING — Especiais",              Color3.fromRGB(255,230,80), {"BChaves","BBigorna","BBlueprint"}},
}
for _,grp in ipairs(bringGroupOrder) do
    local titulo,cor,keys=grp[1],grp[2],grp[3]
    makeBringSection(titulo,cor)
    for _,k in ipairs(keys) do if bringCatMap[k] then makeBringRow(bringCatMap[k]) end end
end

-- ═══════════════════════════════════════════════════════════════
--  FUNÇÕES PLAYER — Speed, Jump, Fly, Noclip, TpClick, BauANC
-- ═══════════════════════════════════════════════════════════════
local playerSpeed   = 30
local playerJump    = 80
local flyEnabled    = false
local flySpeed      = 40
local flyBodyVel, flyBodyGyro, flyConn
local noclipEnabled = false
local noclipConn
local tpClickEnabled = false
local tpClickConn
local bauANCEnabled  = false
local bauANCConn

-- Valores de chão — protege contra noclip atravessar
local VOID_MIN_Y = -120

local function applySpeed(v)
    pcall(function()
        local ch = Player.Character; if not ch then return end
        local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
        hum.WalkSpeed = v
    end)
end

local function applyJump(v)
    pcall(function()
        local ch = Player.Character; if not ch then return end
        local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
        hum.UseJumpPower = true; hum.JumpPower = v
    end)
end

Player.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed(playerSpeed)
    applyJump(playerJump)
    -- Reativar voo se estava ativo
    if flyEnabled then
        task.wait(0.5)
        local ch = Player.Character; if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if flyBodyVel then pcall(function() flyBodyVel:Destroy() end) end
        if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) end
        flyBodyVel = Instance.new("BodyVelocity", hrp)
        flyBodyVel.MaxForce = Vector3.new(1e6,1e6,1e6); flyBodyVel.Velocity = Vector3.zero
        flyBodyGyro = Instance.new("BodyGyro", hrp)
        flyBodyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6); flyBodyGyro.CFrame = hrp.CFrame
    end
end)

-- ──────────────────────────────────────
--  FLY — W/A/S/D + Espaço + Ctrl
-- ──────────────────────────────────────
local function setFly(state)
    flyEnabled = state
    if state then
        local ch = Player.Character; if not ch then return end
        local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        -- Desativa gravidade local via BodyMover
        if flyBodyVel then pcall(function() flyBodyVel:Destroy() end) end
        if flyBodyGyro then pcall(function() flyBodyGyro:Destroy() end) end
        flyBodyVel = Instance.new("BodyVelocity", hrp)
        flyBodyVel.MaxForce = Vector3.new(1e6,1e6,1e6)
        flyBodyVel.Velocity  = Vector3.zero
        flyBodyGyro = Instance.new("BodyGyro", hrp)
        flyBodyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
        flyBodyGyro.CFrame    = hrp.CFrame
        if flyConn then flyConn:Disconnect() end
        flyConn = RunService.Heartbeat:Connect(function()
            if not flyEnabled then return end
            local c2 = Player.Character; if not c2 then return end
            local h2 = c2:FindFirstChild("HumanoidRootPart"); if not h2 then return end
            if not flyBodyVel or not flyBodyVel.Parent then return end
            local camCF = workspace.CurrentCamera.CFrame
            local dir   = Vector3.zero
            local UIS   = UserInputService
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCF.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCF.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                dir = dir + Vector3.new(0,1,0)
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                dir = dir - Vector3.new(0,1,0)
            end
            if dir.Magnitude > 0 then
                flyBodyVel.Velocity = dir.Unit * flySpeed
            else
                flyBodyVel.Velocity = Vector3.zero
            end
            flyBodyGyro.CFrame = camCF
        end)
    else
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        pcall(function() if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel = nil end end)
        pcall(function() if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end end)
    end
end

-- ──────────────────────────────────────
--  NOCLIP — atravessa paredes, NÃO chão
-- ──────────────────────────────────────
local noclipOrigCC  = {}   -- salva CanCollide original de cada parte
local noclipFloorCC = {}   -- partes de "chão" que devem manter colisão

local FLOOR_TAGS = {
    "terrain", "ground", "floor", "basplate", "baseplate", "road",
    "terrain", "platform", "bridge"
}

local function isFloorPart(part)
    if part:IsA("Terrain") then return true end
    local n = part.Name:lower()
    for _, tag in ipairs(FLOOR_TAGS) do
        if n:find(tag) then return true end
    end
    -- Parte horizontal grande e ancorada = chão
    if part.Anchored and part.Size.Y < 2 and (part.Size.X > 20 or part.Size.Z > 20) then
        return true
    end
    return false
end

local function setNoclip(state)
    noclipEnabled = state
    if state then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RunService.Stepped:Connect(function()
            if not noclipEnabled then return end
            local ch = Player.Character; if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart")
            -- Segurança anti-void: se cair muito, teleporta de volta
            if hrp and hrp.Position.Y < VOID_MIN_Y then
                hrp.CFrame = CFrame.new(hrp.Position.X, VOID_MIN_Y + 15, hrp.Position.Z)
                hrp.Velocity = Vector3.zero
            end
            -- Desativa colisão do personagem
            for _, part in ipairs(ch:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        -- Restaura colisão do personagem
        pcall(function()
            local ch = Player.Character; if not ch then return end
            for _, part in ipairs(ch:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end)
    end
end

-- ──────────────────────────────────────
--  TP CLICK — clique para teleportar
-- ──────────────────────────────────────
local function setTpClick(state)
    tpClickEnabled = state
    if state then
        if tpClickConn then tpClickConn:Disconnect() end
        tpClickConn = UserInputService.InputBegan:Connect(function(input, gpe)
            if not tpClickEnabled or gpe then return end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
            local ch = Player.Character; if not ch then return end
            local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local mp = UserInputService:GetMouseLocation()
            local ray = workspace:Raycast(
                Cam.CFrame.Position,
                Cam:ScreenPointToRay(mp.X, mp.Y).Direction * 2000
            )
            if ray then
                local safeY = math.max(ray.Position.Y + 3, VOID_MIN_Y + 20)
                hrp.CFrame = CFrame.new(ray.Position.X, safeY, ray.Position.Z)
            end
        end)
    else
        if tpClickConn then tpClickConn:Disconnect(); tpClickConn = nil end
    end
end

-- ──────────────────────────────────────
--  BAÚ ANC — remove animação de baús
-- ──────────────────────────────────────
local function setBauANC(state)
    bauANCEnabled = state
    if state then
        if bauANCConn then bauANCConn:Disconnect() end
        -- Acelera todas as AnimationTracks já tocando
        local function acelerarAnimator(obj)
            if not obj or not obj.Parent then return end
            if obj:IsA("Animator") then
                for _, tr in ipairs(obj:GetPlayingAnimationTracks()) do
                    pcall(function() tr:AdjustSpeed(9999) end)
                end
            end
        end
        -- Para novos objetos adicionados (baús sendo abertos)
        bauANCConn = workspace.DescendantAdded:Connect(function(obj)
            if not bauANCEnabled then return end
            task.defer(function()
                acelerarAnimator(obj)
                -- Verifica se é modelo de baú
                if obj:IsA("Model") then
                    for _, desc in ipairs(obj:GetDescendants()) do
                        acelerarAnimator(desc)
                    end
                end
            end)
        end)
        -- Aplica em todos os existentes agora
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function() acelerarAnimator(obj) end)
        end
    else
        if bauANCConn then bauANCConn:Disconnect(); bauANCConn = nil end
    end
end

-- ══════════════════════════════════════════════════════════
--  UI ABA PLAYER — COMPLETAMENTE REFEITA
-- ══════════════════════════════════════════════════════════
local plTabLO = 0
local function plLO() plTabLO += 1; return plTabLO end

-- Seção
local function makePlSec(titulo, cor)
    local hdr = Instance.new("Frame", Pages["Player"])
    hdr.BackgroundColor3 = Color3.fromRGB(20,22,30); hdr.BackgroundTransparency = 0.3
    hdr.BorderSizePixel = 0; hdr.Size = UDim2.new(1,0,0,22); hdr.LayoutOrder = plLO(); hdr.ZIndex = 4
    Instance.new("UICorner", hdr).CornerRadius = UDim.new(0,6)
    local bar = Instance.new("Frame", hdr); bar.BackgroundColor3 = cor; bar.BorderSizePixel = 0
    bar.Position = UDim2.new(0,0,0,0); bar.Size = UDim2.new(0,3,1,0); bar.ZIndex = 5
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,3)
    local lbl = Instance.new("TextLabel", hdr); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,10,0,0); lbl.Size = UDim2.new(1,-14,1,0)
    lbl.Font = Enum.Font.GothamBlack; lbl.Text = titulo
    lbl.TextColor3 = cor; lbl.TextSize = 9; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5
end

-- ──────────────────────────────────────────────────
--  Row com ORBITAL DIAL — sistema inovador de scroll
--  Scroll do mouse no dial = aumenta/diminui valor
--  Clique e arrasta vertical = controle fino
--  Dois anéis concêntricos giram mostrando o valor
-- ──────────────────────────────────────────────────
local function makePlRow_Slider(iconKey, cor, lblTxt, descTxt, minV, maxV, stepSm, stepLg, initVal, onChange)
    local row = Instance.new("Frame", Pages["Player"])
    row.BackgroundColor3 = Color3.fromRGB(22,24,32); row.BorderSizePixel = 0
    row.Size = UDim2.new(1,0,0,90); row.LayoutOrder = plLO(); row.ZIndex = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,12)
    local rowS = Instance.new("UIStroke", row); rowS.Color = Color3.fromRGB(42,46,58); rowS.Thickness = 1.5

    -- Fundo glow sutil
    local gb = Instance.new("Frame", row); gb.BackgroundColor3 = cor; gb.BackgroundTransparency = 0.92
    gb.BorderSizePixel = 0; gb.Size = UDim2.new(1,0,1,0); gb.ZIndex = 5
    Instance.new("UICorner", gb).CornerRadius = UDim.new(0,12)

    -- Barra lateral colorida
    local bl = Instance.new("Frame", row); bl.BackgroundColor3 = cor; bl.BorderSizePixel = 0
    bl.Position = UDim2.new(0,0,0.15,0); bl.Size = UDim2.new(0,3,0.7,0); bl.ZIndex = 8
    Instance.new("UICorner", bl).CornerRadius = UDim.new(0,2)

    -- Ícone
    local ib = Instance.new("Frame", row); ib.BackgroundColor3 = cor; ib.BackgroundTransparency = 0.78
    ib.BorderSizePixel = 0; ib.Position = UDim2.new(0,10,0.5,-20); ib.Size = UDim2.new(0,36,0,36); ib.ZIndex = 7
    Instance.new("UICorner", ib).CornerRadius = UDim.new(0,8)
    local ic = criarIconePlayer(ib, iconKey, cor)
    ic.Position = UDim2.new(0,4,0,4); ic.Size = UDim2.new(0,28,0,28)

    -- Título
    local tl = Instance.new("TextLabel", row); tl.BackgroundTransparency = 1
    tl.Position = UDim2.new(0,56,0,10); tl.Size = UDim2.new(0,130,0,16)
    tl.Font = Enum.Font.GothamBold; tl.Text = lblTxt; tl.TextColor3 = Color3.fromRGB(220,225,240)
    tl.TextSize = 11; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 7

    -- Desc
    local td = Instance.new("TextLabel", row); td.BackgroundTransparency = 1
    td.Position = UDim2.new(0,56,0,27); td.Size = UDim2.new(0,140,0,28)
    td.Font = Enum.Font.Gotham; td.Text = descTxt; td.TextColor3 = Color3.fromRGB(80,90,110)
    td.TextSize = 7; td.TextXAlignment = Enum.TextXAlignment.Left; td.TextWrapped = true; td.ZIndex = 7

    -- Dica de uso
    local hint = Instance.new("TextLabel", row); hint.BackgroundTransparency = 1
    hint.Position = UDim2.new(0,56,0,60); hint.Size = UDim2.new(0,140,0,22)
    hint.Font = Enum.Font.Gotham; hint.Text = "🖱 Scroll  •  Arrastar ↕  •  ±1/±10"
    hint.TextColor3 = Color3.fromRGB(cor.R*255*0.7, cor.G*255*0.7, cor.B*255*0.7)
    hint.TextSize = 7; hint.TextXAlignment = Enum.TextXAlignment.Left; hint.TextWrapped = true; hint.ZIndex = 7
    hint.TextColor3 = Color3.new(cor.R*0.6, cor.G*0.6, cor.B*0.6)

    -- ═══════════════════════════════════════════════
    --  ORBITAL DIAL — lado direito do card
    -- ═══════════════════════════════════════════════
    local DIAL_SIZE = 74
    local dialZone = Instance.new("Frame", row)
    dialZone.BackgroundTransparency = 1; dialZone.BorderSizePixel = 0
    dialZone.Position = UDim2.new(1, -(DIAL_SIZE+8), 0.5, -(DIAL_SIZE/2))
    dialZone.Size = UDim2.new(0, DIAL_SIZE, 0, DIAL_SIZE); dialZone.ZIndex = 9

    -- Anel externo (fundo escuro)
    local ringOuter = Instance.new("Frame", dialZone)
    ringOuter.BackgroundColor3 = Color3.fromRGB(14,16,22); ringOuter.BorderSizePixel = 0
    ringOuter.Size = UDim2.new(1,0,1,0); ringOuter.ZIndex = 9
    Instance.new("UICorner", ringOuter).CornerRadius = UDim.new(1,0)
    local ringOuterStroke = Instance.new("UIStroke", ringOuter)
    ringOuterStroke.Color = cor; ringOuterStroke.Thickness = 2; ringOuterStroke.Transparency = 0.4

    -- Anel interno (fundo médio)
    local ringMid = Instance.new("Frame", dialZone)
    ringMid.BackgroundColor3 = Color3.fromRGB(20,22,32); ringMid.BorderSizePixel = 0
    ringMid.Position = UDim2.new(0,9,0,9); ringMid.Size = UDim2.new(1,-18,1,-18); ringMid.ZIndex = 10
    Instance.new("UICorner", ringMid).CornerRadius = UDim.new(1,0)
    local ringMidStroke = Instance.new("UIStroke", ringMid)
    ringMidStroke.Color = cor; ringMidStroke.Thickness = 1; ringMidStroke.Transparency = 0.65

    -- Centro do dial
    local dialCenter = Instance.new("Frame", dialZone)
    dialCenter.BackgroundColor3 = Color3.fromRGB(26,28,38); dialCenter.BorderSizePixel = 0
    dialCenter.Position = UDim2.new(0,20,0,20); dialCenter.Size = UDim2.new(1,-40,1,-40); dialCenter.ZIndex = 11
    Instance.new("UICorner", dialCenter).CornerRadius = UDim.new(1,0)
    local dialCenterStroke = Instance.new("UIStroke", dialCenter)
    dialCenterStroke.Color = cor; dialCenterStroke.Thickness = 1.5; dialCenterStroke.Transparency = 0.2

    -- Valor numérico no centro
    local dialVal = Instance.new("TextLabel", dialCenter)
    dialVal.BackgroundTransparency = 1; dialVal.Size = UDim2.new(1,0,0.55,0); dialVal.Position = UDim2.new(0,0,0.1,0)
    dialVal.Font = Enum.Font.GothamBlack; dialVal.TextColor3 = Color3.fromRGB(255,255,255)
    dialVal.TextSize = 13; dialVal.Text = tostring(initVal); dialVal.ZIndex = 14

    -- Label mini abaixo do número
    local dialLblMini = Instance.new("TextLabel", dialCenter)
    dialLblMini.BackgroundTransparency = 1; dialLblMini.Size = UDim2.new(1,0,0.4,0); dialLblMini.Position = UDim2.new(0,0,0.6,0)
    dialLblMini.Font = Enum.Font.Gotham; dialLblMini.TextColor3 = Color3.new(cor.R*0.8, cor.G*0.8, cor.B*0.8)
    dialLblMini.TextSize = 7; dialLblMini.Text = iconKey == "Speed" and "spd" or "jmp"; dialLblMini.ZIndex = 14

    -- Ponteiro do dial (seta giratória no anel externo)
    local pointer = Instance.new("Frame", ringOuter)
    pointer.BackgroundColor3 = Color3.fromRGB(255,255,255); pointer.BorderSizePixel = 0
    pointer.AnchorPoint = Vector2.new(0.5, 1)
    pointer.Position = UDim2.new(0.5,0,0.5,0); pointer.Size = UDim2.new(0,3,0,DIAL_SIZE/2-4); pointer.ZIndex = 12
    Instance.new("UICorner", pointer).CornerRadius = UDim.new(0,2)
    -- Ponto brilhante na ponta
    local pointerDot = Instance.new("Frame", pointer)
    pointerDot.BackgroundColor3 = cor; pointerDot.BorderSizePixel = 0
    pointerDot.Position = UDim2.new(0.5,-5,0,0); pointerDot.Size = UDim2.new(0,10,0,10); pointerDot.ZIndex = 13
    Instance.new("UICorner", pointerDot).CornerRadius = UDim.new(1,0)
    local pdStroke = Instance.new("UIStroke", pointerDot); pdStroke.Color = Color3.fromRGB(255,255,255); pdStroke.Thickness = 1.5; pdStroke.Transparency = 0.4

    -- Marcadores de escala (8 traços ao redor do anel externo)
    for i = 0, 7 do
        local ang = math.rad(i * 45)
        local tick = Instance.new("Frame", ringOuter)
        tick.BackgroundColor3 = cor; tick.BackgroundTransparency = i % 2 == 0 and 0.2 or 0.7
        tick.BorderSizePixel = 0
        tick.AnchorPoint = Vector2.new(0.5, 0.5)
        local r = DIAL_SIZE/2 - 4
        tick.Position = UDim2.new(0.5, math.sin(ang)*r - (i%2==0 and 2 or 1), 0.5, -math.cos(ang)*r - (i%2==0 and 2 or 1))
        tick.Size = UDim2.new(0, i%2==0 and 4 or 2, 0, i%2==0 and 4 or 2)
        tick.ZIndex = 10; Instance.new("UICorner", tick).CornerRadius = UDim.new(1,0)
    end

    -- Botões - e + pequenos abaixo do dial
    local btnRow = Instance.new("Frame", row)
    btnRow.BackgroundTransparency = 1; btnRow.BorderSizePixel = 0
    btnRow.Position = UDim2.new(1, -(DIAL_SIZE+8), 1, -20)
    btnRow.Size = UDim2.new(0, DIAL_SIZE, 0, 16); btnRow.ZIndex = 9

    local function makeTinyBtn(txt, xOffset, callback)
        local btn = Instance.new("TextButton", btnRow)
        btn.BackgroundColor3 = Color3.fromRGB(30,32,42); btn.BorderSizePixel = 0
        btn.Position = UDim2.new(0, xOffset, 0, 0); btn.Size = UDim2.new(0, 30, 0, 14)
        btn.Font = Enum.Font.GothamBold; btn.Text = txt
        btn.TextColor3 = cor; btn.TextSize = 9; btn.ZIndex = 12
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        local bs = Instance.new("UIStroke", btn); bs.Color = cor; bs.Thickness = 1; bs.Transparency = 0.6
        btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(40,42,58)}):Play(); TweenService:Create(bs,TweenInfo.new(0.1),{Transparency=0.1}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(30,32,42)}):Play(); TweenService:Create(bs,TweenInfo.new(0.1),{Transparency=0.6}):Play() end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local curVal = {initVal}

    -- Calcula rotação do ponteiro baseado no valor (225 graus de arco: -112.5 a +112.5)
    local function valToRot(v)
        local pct = (v - minV) / (maxV - minV)
        return -135 + pct * 270
    end

    local function applyDial(v, animate)
        v = math.clamp(math.round(v), minV, maxV)
        curVal[1] = v
        dialVal.Text = tostring(v)
        local rot = valToRot(v)
        local pct = (v - minV) / (maxV - minV)
        -- Cor do ponteiro muda de frio (azul) a quente (laranja/vermelho) conforme sobe
        local r = pct < 0.5 and pct*2 or 1
        local g = pct < 0.5 and 1 or 2*(1-pct)
        local newCor = Color3.new(
            cor.R * (0.5 + pct*0.5),
            cor.G * (1 - pct*0.3),
            cor.B * (1 - pct*0.6)
        )
        if animate then
            TweenService:Create(pointer, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Rotation = rot}):Play()
            TweenService:Create(pointerDot, TweenInfo.new(0.18), {BackgroundColor3 = newCor}):Play()
            TweenService:Create(dialVal, TweenInfo.new(0.1), {TextColor3 = newCor}):Play()
            TweenService:Create(ringOuterStroke, TweenInfo.new(0.15), {Color = newCor, Transparency = 0.15}):Play()
            TweenService:Create(dialCenterStroke, TweenInfo.new(0.15), {Color = newCor}):Play()
            -- Pulse no centro
            TweenService:Create(dialCenter, TweenInfo.new(0.08), {BackgroundColor3 = Color3.fromRGB(34,36,50)}):Play()
            task.delay(0.12, function() TweenService:Create(dialCenter, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26,28,38)}):Play() end)
        else
            pointer.Rotation = rot
            pointerDot.BackgroundColor3 = newCor
            dialVal.TextColor3 = newCor
        end
        onChange(v)
    end

    -- Inicializar sem animação
    task.spawn(function() task.wait(0.1); applyDial(initVal, false) end)

    -- Botões ±1 e ±10
    makeTinyBtn("−10", 0, function() applyDial(curVal[1] - stepLg, true) end)
    makeTinyBtn("−1", 34, function() applyDial(curVal[1] - stepSm, true) end)
    makeTinyBtn("+1", 68, function() applyDial(curVal[1] + stepSm, true) end) -- Adjusted X to fit

    -- Scroll do mouse no dial (forma mais intuitiva)
    local dialScrollBtn = Instance.new("TextButton", dialZone)
    dialScrollBtn.BackgroundTransparency = 1; dialScrollBtn.Size = UDim2.new(1,0,1,0)
    dialScrollBtn.Text = ""; dialScrollBtn.ZIndex = 16

    -- Drag vertical no dial
    local dragY = nil
    local dragStartVal = initVal
    dialScrollBtn.MouseButton1Down:Connect(function()
        dragY = UserInputService:GetMouseLocation().Y
        dragStartVal = curVal[1]
        TweenService:Create(ringOuterStroke,TweenInfo.new(0.1),{Transparency=0}):Play()
        TweenService:Create(dialCenterStroke,TweenInfo.new(0.1),{Thickness=2.5}):Play()
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 and dragY then
            dragY = nil
            TweenService:Create(ringOuterStroke,TweenInfo.new(0.25),{Transparency=0.4}):Play()
            TweenService:Create(dialCenterStroke,TweenInfo.new(0.2),{Thickness=1.5}):Play()
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragY and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local curY = UserInputService:GetMouseLocation().Y
            local delta = dragY - curY -- arrastar para cima = aumentar
            local range = maxV - minV
            local newVal = dragStartVal + math.floor(delta / 1.5) * stepSm
            applyDial(newVal, false)
            -- atualiza visual sem tween para suavidade no drag
            pointer.Rotation = valToRot(curVal[1])
            dialVal.Text = tostring(curVal[1])
        end
    end)

    -- SCROLL do mouse = ajuste fino
    dialScrollBtn.MouseWheelForward:Connect(function() applyDial(curVal[1] + stepSm, true) end)
    dialScrollBtn.MouseWheelBackward:Connect(function() applyDial(curVal[1] - stepSm, true) end)

    -- Hover geral na row
    row.MouseEnter:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,30,42)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.2),{Color=cor,Transparency=0.5}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(22,24,32)}):Play()
        TweenService:Create(rowS,TweenInfo.new(0.3),{Color=Color3.fromRGB(42,46,58),Transparency=0}):Play()
    end)
end

-- ──────────────────────────────────────────────────
--  Row Toggle (com ou sem mini-slider lateral para velocidade)
-- ──────────────────────────────────────────────────
local function makePlRow_Toggle(iconKey, cor, lblTxt, descTxt, onToggle, speedRef)
    local hasSpeed = speedRef ~= nil
    local row = Instance.new("Frame", Pages["Player"])
    row.BackgroundColor3 = Color3.fromRGB(28,30,38); row.BorderSizePixel = 0
    row.Size = UDim2.new(1,0,0, hasSpeed and 80 or 58); row.LayoutOrder = plLO(); row.ZIndex = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)
    local rowS = Instance.new("UIStroke", row); rowS.Color = Color3.fromRGB(42,46,58); rowS.Thickness = 1
    local gb = Instance.new("Frame", row); gb.BackgroundColor3 = cor; gb.BackgroundTransparency = 0.9
    gb.BorderSizePixel = 0; gb.Size = UDim2.new(1,0,1,0); gb.ZIndex = 5
    Instance.new("UICorner", gb).CornerRadius = UDim.new(0,9)
    local bl = Instance.new("Frame", row); bl.BackgroundColor3 = cor; bl.BorderSizePixel = 0
    bl.Position = UDim2.new(0,0,0.15,0); bl.Size = UDim2.new(0,3,0.7,0); bl.ZIndex = 8
    Instance.new("UICorner", bl).CornerRadius = UDim.new(0,2)
    local ib = Instance.new("Frame", row); ib.BackgroundColor3 = cor; ib.BackgroundTransparency = 0.78
    ib.BorderSizePixel = 0; ib.Position = UDim2.new(0,8,0,hasSpeed and 10 or 11); ib.Size = UDim2.new(0,36,0,36); ib.ZIndex = 7
    Instance.new("UICorner", ib).CornerRadius = UDim.new(0,8)
    local ic = criarIconePlayer(ib, iconKey, cor)
    ic.Position = UDim2.new(0,4,0,4); ic.Size = UDim2.new(0,28,0,28)
    local tl = Instance.new("TextLabel", row); tl.BackgroundTransparency = 1
    tl.Position = UDim2.new(0,54,0,8); tl.Size = UDim2.new(1,-118,0,16)
    tl.Font = Enum.Font.GothamBold; tl.Text = lblTxt; tl.TextColor3 = Color3.fromRGB(220,225,240)
    tl.TextSize = 11; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 7
    local td = Instance.new("TextLabel", row); td.BackgroundTransparency = 1
    td.Position = UDim2.new(0,54,0,26); td.Size = UDim2.new(1,-118,0, hasSpeed and 16 or 24)
    td.Font = Enum.Font.Gotham; td.Text = descTxt; td.TextColor3 = Color3.fromRGB(90,100,120)
    td.TextSize = 9; td.TextXAlignment = Enum.TextXAlignment.Left; td.TextWrapped = true; td.ZIndex = 7

    -- Mini Orbital Dial de velocidade (apenas para Fly)
    if hasSpeed then
        local sf = speedRef
        local MINI_D = 46

        -- Área do mini dial, posicionado à esquerda do toggle
        local miniDialZone = Instance.new("Frame", row)
        miniDialZone.BackgroundTransparency = 1; miniDialZone.BorderSizePixel = 0
        miniDialZone.Position = UDim2.new(0, 54, 0, 16)
        miniDialZone.Size = UDim2.new(0, MINI_D, 0, MINI_D); miniDialZone.ZIndex = 10

        local mRingOut = Instance.new("Frame", miniDialZone)
        mRingOut.BackgroundColor3 = Color3.fromRGB(14,16,22); mRingOut.BorderSizePixel = 0
        mRingOut.Size = UDim2.new(1,0,1,0); mRingOut.ZIndex = 10
        Instance.new("UICorner", mRingOut).CornerRadius = UDim.new(1,0)
        local mRingStroke = Instance.new("UIStroke", mRingOut); mRingStroke.Color = cor; mRingStroke.Thickness = 1.5; mRingStroke.Transparency = 0.4

        local mCenter = Instance.new("Frame", miniDialZone)
        mCenter.BackgroundColor3 = Color3.fromRGB(22,24,34); mCenter.BorderSizePixel = 0
        mCenter.Position = UDim2.new(0,10,0,10); mCenter.Size = UDim2.new(1,-20,1,-20); mCenter.ZIndex = 11
        Instance.new("UICorner", mCenter).CornerRadius = UDim.new(1,0)
        local mCStroke = Instance.new("UIStroke", mCenter); mCStroke.Color = cor; mCStroke.Thickness = 1; mCStroke.Transparency = 0.3

        local mValLbl = Instance.new("TextLabel", mCenter)
        mValLbl.BackgroundTransparency = 1; mValLbl.Size = UDim2.new(1,0,0.6,0); mValLbl.Position = UDim2.new(0,0,0.05,0)
        mValLbl.Font = Enum.Font.GothamBlack; mValLbl.TextColor3 = cor; mValLbl.TextSize = 8
        mValLbl.Text = tostring(sf.val[1]); mValLbl.ZIndex = 14

        local mLblMini = Instance.new("TextLabel", mCenter)
        mLblMini.BackgroundTransparency = 1; mLblMini.Size = UDim2.new(1,0,0.4,0); mLblMini.Position = UDim2.new(0,0,0.6,0)
        mLblMini.Font = Enum.Font.Gotham; mLblMini.TextColor3 = Color3.new(cor.R*0.6, cor.G*0.6, cor.B*0.6)
        mLblMini.TextSize = 6; mLblMini.Text = "vel"; mLblMini.ZIndex = 14

        local mPointer = Instance.new("Frame", mRingOut)
        mPointer.BackgroundColor3 = Color3.fromRGB(255,255,255); mPointer.BorderSizePixel = 0
        mPointer.AnchorPoint = Vector2.new(0.5, 1)
        mPointer.Position = UDim2.new(0.5,0,0.5,0); mPointer.Size = UDim2.new(0,2,0,MINI_D/2-3); mPointer.ZIndex = 12
        Instance.new("UICorner", mPointer).CornerRadius = UDim.new(0,2)
        local mPDot = Instance.new("Frame", mPointer)
        mPDot.BackgroundColor3 = cor; mPDot.BorderSizePixel = 0
        mPDot.Position = UDim2.new(0.5,-4,0,-1); mPDot.Size = UDim2.new(0,8,0,8); mPDot.ZIndex = 13
        Instance.new("UICorner", mPDot).CornerRadius = UDim.new(1,0)

        local function updateMsDial(v, anim)
            v = math.clamp(math.round(v), sf.min, sf.max); sf.val[1] = v
            mValLbl.Text = tostring(v)
            local pct = (v - sf.min) / (sf.max - sf.min)
            local rot = -135 + pct * 270
            local newC = Color3.new(cor.R*(0.6+pct*0.4), cor.G*(1-pct*0.2), cor.B*(1-pct*0.5))
            if anim then
                TweenService:Create(mPointer, TweenInfo.new(0.18, Enum.EasingStyle.Back), {Rotation = rot}):Play()
                TweenService:Create(mPDot, TweenInfo.new(0.12), {BackgroundColor3 = newC}):Play()
                TweenService:Create(mValLbl, TweenInfo.new(0.1), {TextColor3 = newC}):Play()
            else
                mPointer.Rotation = rot; mPDot.BackgroundColor3 = newC; mValLbl.TextColor3 = newC
            end
            if sf.onChange then sf.onChange(v) end
        end
        task.spawn(function() task.wait(0.12); updateMsDial(sf.val[1], false) end)

        local mDragBtn = Instance.new("TextButton", miniDialZone)
        mDragBtn.BackgroundTransparency = 1; mDragBtn.Size = UDim2.new(1,0,1,0); mDragBtn.Text = ""; mDragBtn.ZIndex = 16

        local mDragY = nil; local mDragStart = sf.val[1]
        mDragBtn.MouseButton1Down:Connect(function()
            mDragY = UserInputService:GetMouseLocation().Y; mDragStart = sf.val[1]
            TweenService:Create(mRingStroke,TweenInfo.new(0.1),{Transparency=0}):Play()
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 and mDragY then
                mDragY = nil
                TweenService:Create(mRingStroke,TweenInfo.new(0.25),{Transparency=0.4}):Play()
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if mDragY and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local d = mDragY - UserInputService:GetMouseLocation().Y
                updateMsDial(mDragStart + math.floor(d/2)*5, false)
                mPointer.Rotation = -135 + ((sf.val[1]-sf.min)/(sf.max-sf.min))*270
            end
        end)
        mDragBtn.MouseWheelForward:Connect(function() updateMsDial(sf.val[1]+5, true) end)
        mDragBtn.MouseWheelBackward:Connect(function() updateMsDial(sf.val[1]-5, true) end)
    end

    -- Toggle pill
    local pill = Instance.new("Frame", row); pill.BackgroundColor3 = Color3.fromRGB(45,50,62)
    pill.BorderSizePixel = 0; pill.Position = UDim2.new(1,-56,0,10); pill.Size = UDim2.new(0,48,0,24); pill.ZIndex = 9
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame", pill); knob.BackgroundColor3 = Color3.fromRGB(160,170,185)
    knob.BorderSizePixel = 0; knob.Position = UDim2.new(0,2,0.5,-10); knob.Size = UDim2.new(0,20,0,20); knob.ZIndex = 10
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    -- Status dot
    local dot = Instance.new("Frame", row); dot.BackgroundColor3 = Color3.fromRGB(70,75,90)
    dot.BorderSizePixel = 0; dot.Position = UDim2.new(1,-58,0,40); dot.Size = UDim2.new(0,8,0,8); dot.ZIndex = 9
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    local estado = false
    -- Botão invisível no pill
    local pillBtn = Instance.new("TextButton", row); pillBtn.BackgroundTransparency = 1
    pillBtn.Position = UDim2.new(1,-60,0,6); pillBtn.Size = UDim2.new(0,54,0,32); pillBtn.Text = ""; pillBtn.ZIndex = 11
    pillBtn.MouseButton1Click:Connect(function()
        estado = not estado
        TweenService:Create(pill, TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundColor3=estado and cor or Color3.fromRGB(45,50,62)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position = estado and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10),
            BackgroundColor3 = estado and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
        }):Play()
        TweenService:Create(rowS, TweenInfo.new(0.2),{Color=estado and cor or Color3.fromRGB(42,46,58)}):Play()
        TweenService:Create(dot, TweenInfo.new(0.2),{BackgroundColor3=estado and Color3.fromRGB(87,242,135) or Color3.fromRGB(70,75,90)}):Play()
        onToggle(estado)
    end)
    row.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(33,36,46)}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,30,38)}):Play() end)
end

-- Referência para velocidade do voo
local flySpeedRef = {
    val = {40}, min = 5, max = 300,
    onChange = function(v) flySpeed = v end
}

-- ── Construir aba Player ───────────────────────────────────
makePlSec("⚡ VELOCIDADE & PULO", Color3.fromRGB(255,200,50))

makePlRow_Slider(
    "Speed", Color3.fromRGB(255,180,30),
    "⚡ Speed",
    "Velocidade de corrida  |  mín: 1  •  máx: 200  |  padrão: 16",
    1, 200, 5, 20, 30,
    function(v) playerSpeed = v; applySpeed(v) end
)

makePlRow_Slider(
    "JumpPower", Color3.fromRGB(100,220,255),
    "🦘 Jump Power",
    "Força do pulo  |  mín: 10  •  máx: 500  |  padrão: 50",
    10, 500, 10, 50, 80,
    function(v) playerJump = v; applyJump(v) end
)

makePlSec("✈️ VOO & NOCLIP", Color3.fromRGB(100,200,255))

makePlRow_Toggle(
    "Fly", Color3.fromRGB(80,180,255),
    "✈️ Fly",
    "W/A/S/D = mover  •  Espaço = subir  •  Ctrl/Shift = descer",
    function(s) setFly(s) end,
    flySpeedRef  -- passa referência do slider de velocidade
)

makePlRow_Toggle(
    "Noclip", Color3.fromRGB(140,255,140),
    "👻 Noclip",
    "Atravessa paredes  |  Anti-void ativo  |  NÃO atravessa o chão",
    function(s) setNoclip(s) end
)

makePlSec("🔧 UTILIDADES", Color3.fromRGB(255,210,80))

makePlRow_Toggle(
    "TpClick", Color3.fromRGB(255,220,60),
    "⚡ TP Click",
    "Clique em qualquer lugar da tela para teleportar instantaneamente",
    function(s) setTpClick(s) end
)

makePlRow_Toggle(
    "BauANC", Color3.fromRGB(210,160,80),
    "📦 Baú ANC",
    "Acelera animação dos baús — abrem instantaneamente ao clicar",
    function(s) setBauANC(s) end
)

makePlSec("🔮 CÂMERA & VISUAL", Color3.fromRGB(100,200,255))

makePlRow_Toggle(
    "InfinitoZoom", Color3.fromRGB(100,200,255),
    "🔍 Infinito Zoom",
    "Remove o limite de zoom da câmera — pode dar zoom infinito para longe ou perto",
    function(s)
        infinitoZoomEnabled = s
        pcall(function()
            if s then
                Player.CameraMaxZoomDistance = 999999
                Player.CameraMinZoomDistance = 0
            else
                Player.CameraMaxZoomDistance = 128
                Player.CameraMinZoomDistance = 0.5
            end
        end)
    end
)

makePlRow_Toggle(
    "CameraLivre", Color3.fromRGB(180,130,255),
    "📷 Câmera Livre",
    "A câmera atravessa paredes e objetos — visão sem obstáculos (noclip de câmera)",
    function(s)
        cameraLivreEnabled = s
        pcall(function()
            local cam = workspace.CurrentCamera
            if s then
                cam.CameraType = Enum.CameraType.Custom
                -- Faz a câmera ignorar colisão atravessando paredes
                for _, part in pairs(workspace:GetDescendants()) do
                    if part:IsA("BasePart") and not part:IsDescendantOf(Player.Character or Instance.new("Model")) then
                        pcall(function() part.CastShadow = part.CastShadow end) -- força avaliação
                    end
                end
            end
        end)
        -- Câmera livre via LockFirstPerson trick
        if s then
            pcall(function()
                local camConn
                camConn = RunService.RenderStepped:Connect(function()
                    if not cameraLivreEnabled then camConn:Disconnect(); return end
                    workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame
                end)
            end)
        end
    end
)

makePlRow_Toggle(
    "FullBright", Color3.fromRGB(255,230,50),
    "☀️ FullBright",
    "Deixa o ambiente extremamente iluminado — noite vira dia, remove chuva e neblina",
    function(s)
        fullBrightEnabled = s
        pcall(function()
            if s then
                Lighting.Brightness = 10
                Lighting.ClockTime = 14
                Lighting.FogEnd = 999999
                Lighting.FogStart = 999999
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(200,200,200)
                Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
                -- Remove efeitos de clima
                for _, v in pairs(Lighting:GetChildren()) do
                    pcall(function()
                        if v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") then
                            v.Enabled = false
                        end
                    end)
                end
                -- Remove chuva/neve no workspace
                for _, v in pairs(workspace:GetDescendants()) do
                    pcall(function()
                        if v:IsA("ParticleEmitter") then
                            local n = v.Name:lower()
                            if n:find("rain") or n:find("snow") or n:find("fog") or n:find("chuva") or n:find("neve") then
                                v.Enabled = false
                            end
                        end
                    end)
                end
            else
                Lighting.Brightness = originalBrightness
                Lighting.FogEnd = originalFogEnd
                Lighting.ClockTime = originalClockTime
                Lighting.GlobalShadows = true
                Lighting.Ambient = Color3.fromRGB(70,70,70)
                Lighting.OutdoorAmbient = Color3.fromRGB(70,70,70)
                for _, v in pairs(Lighting:GetChildren()) do
                    pcall(function()
                        if v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") then
                            v.Enabled = true
                        end
                    end)
                end
            end
        end)
    end
)

makePlSec("⚡ HABILIDADES ESPECIAIS", Color3.fromRGB(100,255,180))

makePlRow_Toggle(
    "InfiniteJump", Color3.fromRGB(80,220,255),
    "🔄 Infinite Jump",
    "Permite pular no ar infinitas vezes — sem toque no chão necessário",
    function(s)
        infiniteJumpEnabled = s
        if infJumpConn then infJumpConn:Disconnect(); infJumpConn = nil end
        if s then
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                if not infiniteJumpEnabled then return end
                local ch = Player.Character; if not ch then return end
                local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end)
        end
    end
)

makePlRow_Toggle(
    "SlopeBoost", Color3.fromRGB(80,255,120),
    "🏃 Slope Boost",
    "Ignora armadilhas de desaceleração — passa nas armadilhas sem perder velocidade",
    function(s)
        slopeBoostEnabled = s
        if s then
            -- Detecta e anula qualquer efeito de slowdown de armadilhas
            -- Remove SpeedBoosts/SlowEffects e força WalkSpeed do personagem
            task.spawn(function()
                while slopeBoostEnabled do
                    task.wait(0.1)
                    pcall(function()
                        local ch = Player.Character; if not ch then return end
                        local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
                        -- Se detectar que a velocidade foi reduzida por algo externo, corrige
                        if hum.WalkSpeed < playerSpeed * 0.9 then
                            hum.WalkSpeed = playerSpeed
                        end
                        -- Remove qualquer BodyVelocity/Force external que desacelere
                        for _, child in pairs(ch:GetDescendants()) do
                            if child:IsA("BodyVelocity") or child:IsA("BodyForce") then
                                if child.Name:lower():find("slow") or child.Name:lower():find("trap") or child.Name:lower():find("snare") then
                                    pcall(function() child:Destroy() end)
                                end
                            end
                        end
                    end)
                end
            end)
        end
    end
)

makePlRow_Toggle(
    "GodMode", Color3.fromRGB(255,200,50),
    "🛡️ God Mode",
    "Imortalidade REAL — anula todos os danos, projéteis e ataques de mobs. Você NUNCA morre.",
    function(s)
        godModeEnabled = s
        if godModeConn then godModeConn:Disconnect(); godModeConn = nil end
        if s then
            godModeConn = RunService.Heartbeat:Connect(function()
                if not godModeEnabled then return end
                pcall(function()
                    local ch = Player.Character; if not ch then return end
                    local hum = ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
                    -- Mantém HP máximo sempre
                    if hum.Health < hum.MaxHealth then
                        hum.Health = hum.MaxHealth
                    end
                    -- Evita estados de morte
                    if hum:GetState() == Enum.HumanoidStateType.Dead then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                    -- Destrói projéteis próximos que possam causar dano
                    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                    for _, v in pairs(workspace:GetDescendants()) do
                        pcall(function()
                            if not v or not v.Parent then return end
                            if v:IsA("BasePart") then
                                local n = v.Name:lower()
                                -- Detecta projéteis por nome
                                if n:find("bullet") or n:find("arrow") or n:find("bolt") or n:find("projectile") or n:find("fireball") or n:find("magic") or n:find("spell") or n:find("attack") then
                                    local dist = (v.Position - hrp.Position).Magnitude
                                    if dist < 8 then
                                        v:Destroy()
                                    end
                                end
                            end
                        end)
                    end
                end)
            end)
        end
    end
)

-- Info box Player
do
    local f = Instance.new("Frame", Pages["Player"])
    f.BackgroundColor3 = Color3.fromRGB(14,20,35); f.BackgroundTransparency = 0.5
    f.BorderSizePixel = 0; f.Size = UDim2.new(1,0,0,54); f.LayoutOrder = plLO(); f.ZIndex = 4
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", f).Color = Color3.fromRGB(88,101,242)
    local t = Instance.new("TextLabel", f); t.BackgroundTransparency = 1
    t.Position = UDim2.new(0,8,0,4); t.Size = UDim2.new(1,-16,1,-8)
    t.Font = Enum.Font.Gotham; t.Text = "ℹ️  Player v6  |  Speed/Jump: SliderBar arrastável com líquido animado  |  FullBright: remove chuva/neblina  |  GodMode: imortalidade real + anula projéteis  |  SlopeBoost: ignora armadilhas  |  InfJump: pulo infinito"
    t.TextColor3 = Color3.fromRGB(100,175,255); t.TextSize = 8; t.TextWrapped = true
    t.TextXAlignment = Enum.TextXAlignment.Left; t.TextYAlignment = Enum.TextYAlignment.Top; t.ZIndex = 5
end

-- ═══════════════════════════════════════════════════════════
--  FUNÇÕES AIMBOT — AVANÇADO
-- ═══════════════════════════════════════════════════════════
local ANIMAL_NAMES = {
    "wolf","alpha wolf","alphawolf","bear","polar bear","polarbear",
    "arctic fox","arcticfox","frog","blue frog","purple frog","green frog",
    "bluefrog","purplefrog","greenfrog","scorpion","hellephant",
    "meteor crab","meteorcrab","mammoth","bunny","horse","kiwi","turkey",
    "alien","elite alien","elitealien"
}
local ANIMAL_SET = {}
for _, n in ipairs(ANIMAL_NAMES) do ANIMAL_SET[n] = true end

-- Retorna o HumanoidRootPart do animal mais próximo
local function findNearestAnimalHrp()
    local ch = Player.Character; if not ch then return nil end
    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local myPos = hrp.Position
    local best, bestDist = nil, math.huge
    local pchars = {}
    for _, pl in ipairs(Players:GetPlayers()) do if pl.Character then pchars[pl.Character] = true end end
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if not obj:IsA("Model") then return end
            if pchars[obj] then return end
            local hum = obj:FindFirstChildWhichIsA("Humanoid")
            if not hum or hum.Health <= 0 then return end
            if not ANIMAL_SET[obj.Name:lower()] then return end
            local anHrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
            if not anHrp then return end
            local d = (anHrp.Position - myPos).Magnitude
            if d < bestDist then bestDist = d; best = anHrp end
        end)
    end
    return best
end

-- ──────────────────────────────────────
--  AIMBOT — teleguia projéteis existentes
-- ──────────────────────────────────────
local aimbotEnabled = false

workspace.DescendantAdded:Connect(function(obj)
    if not aimbotEnabled then return end
    task.defer(function()
        if not obj or not obj.Parent or not obj:IsA("BasePart") then return end
        -- Só projéteis com velocidade alta
        local spd = obj.AssemblyLinearVelocity.Magnitude
        if spd < 8 then return end
        -- Ignora projéteis de NPCs (para não guiar ao contrário)
        local par = obj.Parent
        for _ = 1, 3 do
            if par and par:IsA("Model") then
                local hum = par:FindFirstChildWhichIsA("Humanoid")
                if hum then
                    local isPlayer = false
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl.Character == par then isPlayer = true; break end
                    end
                    if not isPlayer then return end  -- é projétil de NPC → ignora
                end
            end
            par = par and par.Parent
        end
        local anHrp = findNearestAnimalHrp()
        if not anHrp then return end
        local steps = 0
        local conn; conn = RunService.Heartbeat:Connect(function()
            steps += 1
            if not aimbotEnabled or not obj or not obj.Parent or steps > 150 then
                conn:Disconnect(); return
            end
            if not anHrp or not anHrp.Parent then
                -- Tentar novo alvo
                anHrp = findNearestAnimalHrp()
                if not anHrp then conn:Disconnect(); return end
            end
            local dir = anHrp.Position - obj.Position
            if dir.Magnitude < 2 then conn:Disconnect(); return end
            -- Usa a velocidade máxima mantida ou pelo menos 80
            local vel = math.max(spd, 80)
            obj.AssemblyLinearVelocity = dir.Unit * vel
        end)
    end)
end)

-- ──────────────────────────────────────
--  AIMBOT AUTO — dispara automaticamente
--  Estratégia: usa VirtualInputManager para
--  simular click invisível na posição do animal
-- ──────────────────────────────────────
local aimbotAutoEnabled = false
local aimbotAutoRunning = false

local RANGED_WEAPONS = {
    "revolver","rifle","tactical shotgun","tacticalshotgun","ray gun","raygun",
    "laser cannon","lasercannon","flamethrower","crossbow","infernal crossbow",
    "infernalcrossbow","blowpipe","air rifle","airrifle","snowball",
    "bouncing blade","bouncingblade","witch potion","witchpotion","wildfire",
    "frozen shuriken","frozenshuriken","kunai"
}
local RANGED_SET = {}
for _, n in ipairs(RANGED_WEAPONS) do RANGED_SET[n] = true end

local function getEquippedRangedTool()
    local ch = Player.Character; if not ch then return nil end
    for _, obj in ipairs(ch:GetChildren()) do
        if obj:IsA("Tool") and RANGED_SET[obj.Name:lower()] then return obj end
    end
    return nil
end

local function startAimbotAuto()
    if aimbotAutoRunning then return end
    aimbotAutoRunning = true
    task.spawn(function()
        while aimbotAutoEnabled do
            task.wait(0.12)  -- ~8 disparos/s máximo
            pcall(function()
                local tool = getEquippedRangedTool()
                if not tool then return end
                local anHrp = findNearestAnimalHrp()
                if not anHrp then return end
                local ch = Player.Character; if not ch then return end
                local myHrp = ch:FindFirstChild("HumanoidRootPart"); if not myHrp then return end

                -- Calcula a posição de tela do alvo
                local targetPos = anHrp.Position + Vector3.new(0, 1, 0)
                local sp, onScreen = Cam:WorldToScreenPoint(targetPos)
                if not onScreen then return end

                -- Rotaciona personagem + câmera invisível para o alvo
                local dir = (anHrp.Position - myHrp.Position)
                local flatDir = Vector3.new(dir.X, 0, dir.Z).Unit
                local yaw = math.atan2(flatDir.X, flatDir.Z)
                myHrp.CFrame = CFrame.new(myHrp.Position) * CFrame.Angles(0, yaw + math.pi, 0)

                -- Tenta disparar via RemoteEvent da ferramenta
                local fired = false
                for _, child in ipairs(tool:GetChildren()) do
                    if child:IsA("RemoteEvent") then
                        pcall(function() child:FireServer(targetPos) end)
                        fired = true; break
                    end
                end
                -- Fallback: VirtualInputManager (click invisível na posição do alvo na tela)
                if not fired then
                    pcall(function()
                        local vim = game:GetService("VirtualInputManager")
                        local sx, sy = math.floor(sp.X), math.floor(sp.Y)
                        vim:SendMouseButtonEvent(sx, sy, 0, true,  game, 0)
                        task.wait(0.03)
                        vim:SendMouseButtonEvent(sx, sy, 0, false, game, 0)
                    end)
                end
            end)
        end
        aimbotAutoRunning = false
    end)
end

-- ══════════════════════════════════════════════════════════
--  UI ABA AVANÇADO FUNÇÕES — REFEITA
-- ══════════════════════════════════════════════════════════
local avTabLO = 0
local function avLO() avTabLO += 1; return avTabLO end

local function makeAvSec(titulo, cor)
    local hdr = Instance.new("Frame", Pages["AvancadoFuncoes"])
    hdr.BackgroundColor3 = Color3.fromRGB(20,22,30); hdr.BackgroundTransparency = 0.3
    hdr.BorderSizePixel = 0; hdr.Size = UDim2.new(1,0,0,22); hdr.LayoutOrder = avLO(); hdr.ZIndex = 4
    Instance.new("UICorner", hdr).CornerRadius = UDim.new(0,6)
    local bar = Instance.new("Frame", hdr); bar.BackgroundColor3 = cor; bar.BorderSizePixel = 0
    bar.Position = UDim2.new(0,0,0,0); bar.Size = UDim2.new(0,3,1,0); bar.ZIndex = 5
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,3)
    local lbl = Instance.new("TextLabel", hdr); lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0,10,0,0); lbl.Size = UDim2.new(1,-14,1,0)
    lbl.Font = Enum.Font.GothamBlack; lbl.Text = titulo
    lbl.TextColor3 = cor; lbl.TextSize = 9; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 5
end

local function makeAvRow_Toggle(iconKey, cor, lblTxt, descTxt, onToggle)
    local row = Instance.new("Frame", Pages["AvancadoFuncoes"])
    row.BackgroundColor3 = Color3.fromRGB(28,30,38); row.BorderSizePixel = 0
    row.Size = UDim2.new(1,0,0,78); row.LayoutOrder = avLO(); row.ZIndex = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)
    local rowS = Instance.new("UIStroke", row); rowS.Color = Color3.fromRGB(42,46,58); rowS.Thickness = 1.2
    local gb = Instance.new("Frame", row); gb.BackgroundColor3 = cor; gb.BackgroundTransparency = 0.88
    gb.BorderSizePixel = 0; gb.Size = UDim2.new(1,0,1,0); gb.ZIndex = 5
    Instance.new("UICorner", gb).CornerRadius = UDim.new(0,9)
    -- Barra lateral grossa
    local bl = Instance.new("Frame", row); bl.BackgroundColor3 = cor; bl.BorderSizePixel = 0
    bl.Position = UDim2.new(0,0,0.1,0); bl.Size = UDim2.new(0,4,0.8,0); bl.ZIndex = 8
    Instance.new("UICorner", bl).CornerRadius = UDim.new(0,2)
    -- Ícone grande
    local ib = Instance.new("Frame", row); ib.BackgroundColor3 = cor; ib.BackgroundTransparency = 0.72
    ib.BorderSizePixel = 0; ib.Position = UDim2.new(0,8,0.5,-22); ib.Size = UDim2.new(0,44,0,44); ib.ZIndex = 7
    Instance.new("UICorner", ib).CornerRadius = UDim.new(0,10)
    -- Brilho ícone
    local ibgl = Instance.new("UIStroke", ib); ibgl.Color = cor; ibgl.Thickness = 1; ibgl.Transparency = 0.4
    local ic = criarIconeAvancado(ib, iconKey, cor)
    ic.Position = UDim2.new(0,8,0,8); ic.Size = UDim2.new(0,28,0,28)
    -- Textos
    local tl = Instance.new("TextLabel", row); tl.BackgroundTransparency = 1
    tl.Position = UDim2.new(0,60,0,8); tl.Size = UDim2.new(1,-120,0,18)
    tl.Font = Enum.Font.GothamBlack; tl.Text = lblTxt; tl.TextColor3 = Color3.fromRGB(230,235,255)
    tl.TextSize = 12; tl.TextXAlignment = Enum.TextXAlignment.Left; tl.ZIndex = 7
    local td = Instance.new("TextLabel", row); td.BackgroundTransparency = 1
    td.Position = UDim2.new(0,60,0,28); td.Size = UDim2.new(1,-120,0,42)
    td.Font = Enum.Font.Gotham; td.Text = descTxt; td.TextColor3 = Color3.fromRGB(95,108,130)
    td.TextSize = 9; td.TextXAlignment = Enum.TextXAlignment.Left; td.TextWrapped = true; td.ZIndex = 7
    -- Badge estado
    local badge = Instance.new("Frame", row); badge.BackgroundColor3 = Color3.fromRGB(40,45,58)
    badge.BorderSizePixel = 0; badge.Position = UDim2.new(1,-84,0,8); badge.Size = UDim2.new(0,72,0,16); badge.ZIndex = 9
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0,8)
    local badgeTxt = Instance.new("TextLabel", badge); badgeTxt.BackgroundTransparency = 1
    badgeTxt.Size = UDim2.new(1,0,1,0); badgeTxt.Font = Enum.Font.GothamBold; badgeTxt.Text = "● INATIVO"
    badgeTxt.TextColor3 = Color3.fromRGB(90,100,120); badgeTxt.TextSize = 7; badgeTxt.ZIndex = 10
    -- Toggle pill
    local pill = Instance.new("Frame", row); pill.BackgroundColor3 = Color3.fromRGB(45,50,62)
    pill.BorderSizePixel = 0; pill.Position = UDim2.new(1,-58,0,32); pill.Size = UDim2.new(0,50,0,26); pill.ZIndex = 9
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame", pill); knob.BackgroundColor3 = Color3.fromRGB(160,170,185)
    knob.BorderSizePixel = 0; knob.Position = UDim2.new(0,2,0.5,-11); knob.Size = UDim2.new(0,22,0,22); knob.ZIndex = 10
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local estado = false
    local pillBtn = Instance.new("TextButton", row); pillBtn.BackgroundTransparency = 1
    pillBtn.Position = UDim2.new(1,-62,0,28); pillBtn.Size = UDim2.new(0,56,0,34); pillBtn.Text = ""; pillBtn.ZIndex = 11
    pillBtn.MouseButton1Click:Connect(function()
        estado = not estado
        TweenService:Create(pill, TweenInfo.new(0.25,Enum.EasingStyle.Quad),{BackgroundColor3=estado and cor or Color3.fromRGB(45,50,62)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position = estado and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
            BackgroundColor3 = estado and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
        }):Play()
        TweenService:Create(rowS, TweenInfo.new(0.2),{Color=estado and cor or Color3.fromRGB(42,46,58)}):Play()
        TweenService:Create(badge, TweenInfo.new(0.2),{BackgroundColor3=estado and cor or Color3.fromRGB(40,45,58)}):Play()
        badgeTxt.Text = estado and "● ATIVO" or "● INATIVO"
        badgeTxt.TextColor3 = estado and Color3.fromRGB(255,255,255) or Color3.fromRGB(90,100,120)
        onToggle(estado)
    end)
    row.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(33,36,48)}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,30,38)}):Play() end)
end

-- Construir aba Avançado Funções
makeAvSec("🎯 AIMBOT — COMBATE AUTOMÁTICO", Color3.fromRGB(255,60,80))

makeAvRow_Toggle(
    "Aimbot", Color3.fromRGB(255,60,80),
    "🎯 Aimbot Teleguiado",
    "Projéteis de TODAS as armas (Revolver, Rifle, Crossbow, Flamethrower, etc.) são teleguiados automaticamente para o animal mais próximo. Pode atirar em QUALQUER direção — 100% de acerto garantido. Funciona enquanto o projétil existe no workspace.",
    function(s) aimbotEnabled = s end
)

makeAvRow_Toggle(
    "AimbotAuto", Color3.fromRGB(255,140,30),
    "🤖 Aimbot AUTO (Disparo Automático)",
    "Com arma ranged equipada, o script dispara sozinho nos animais mais próximos sem clicar. Usa VirtualInputManager invisível — não interfere na câmera. Detecta: Revolver, Rifle, Shotgun, Ray Gun, Crossbow, Flamethrower e mais. Mira sempre no animal mais perto, depois no seguinte.",
    function(s)
        aimbotAutoEnabled = s
        if s then startAimbotAuto() end
    end
)

-- Info box Avançado
do
    local f = Instance.new("Frame", Pages["AvancadoFuncoes"])
    f.BackgroundColor3 = Color3.fromRGB(14,20,35); f.BackgroundTransparency = 0.45
    f.BorderSizePixel = 0; f.Size = UDim2.new(1,0,0,52); f.LayoutOrder = avLO(); f.ZIndex = 4
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,8)
    local fs = Instance.new("UIStroke", f); fs.Color = Color3.fromRGB(255,100,30); fs.Thickness = 1
    local ft = Instance.new("TextLabel", f); ft.BackgroundTransparency = 1
    ft.Position = UDim2.new(0,8,0,4); ft.Size = UDim2.new(1,-16,1,-8)
    ft.Font = Enum.Font.Gotham
    ft.Text = "⚠️  AIMBOT: Funciona melhor com projéteis físicos (Revolver, Rifle, Crossbow, Flamethrower).\n🤖  AIMBOT AUTO: Equipe a arma ranged → dispara automaticamente. Requer exploit com VirtualInputManager.\n🎮  Wiki 99 Nights in the Forest 2026 — PudimHub v6 FINAL"
    ft.TextColor3 = Color3.fromRGB(255,160,60); ft.TextSize = 8; ft.TextWrapped = true
    ft.TextXAlignment = Enum.TextXAlignment.Left; ft.TextYAlignment = Enum.TextYAlignment.Top; ft.ZIndex = 5
end

-- ══════════════════════════════════════════════════════
--  ABA INICIAL
-- ══════════════════════════════════════════════════════
task.wait(0.05)
selectTab("Info")

print("╔══════════════════════════════════════════════════════════════╗")
print("║  PUDIM HUB v6 ULTRA — Fev 2026                              ║")
print("╠══════════════════════════════════════════════════════════════╣")
print("║  ✓ Speed/Jump: SliderBar arrastável com líquido animado     ║")
print("║  ✓ InfinitoZoom | CameraLivre | FullBright | InfiniteJump  ║")
print("║  ✓ SlopeBoost | GodMode: imortalidade real                  ║")
print("║  ✓ TP v6: dropdown bonito + grid acesso rápido              ║")
print("║  ✓ Biomas dinâmicos: Floresta|Neve|Vulcão|Cavernas|Fada|NP  ║")
print("║  ✓ ESP: 20 cats | BRING: 17 cats | Wiki 2026                ║")
print("╚══════════════════════════════════════════════════════════════╝")
-- ══════════════════════════════════════════════════════════════
--  ABA TELEPORTE TP — Sistema Biomas Dinâmico v6 ULTRA
--  Biomas: Floresta | Neve | Vulcão | Cavernas | Fada | Polo Norte
--  Busca dinâmica por tags/nomes do workspace (sem posição fixa)
-- ══════════════════════════════════════════════════════════════

local BIOME_DATA = {
    {
        key="Floresta",
        label="🌲 Floresta",
        cor=Color3.fromRGB(60,200,80),
        desc="Bioma principal — Veado, Campfire, estruturas de madeira",
        icon="forest",
        -- Termos de busca para encontrar o bioma dinamicamente
        searchTags={"campfire","camp fire","bonfire","startcamp","spawn"},
        fallbackTags={"log","cabin","tree","bush","grass"},
    },
    {
        key="Neve",
        label="❄️ Neve",
        cor=Color3.fromRGB(150,220,255),
        desc="Bioma de neve — Coruja, Ursos Polares, Mamutes",
        icon="snow",
        searchTags={"snow","snowbiome","snowzone","icezone","icebiome","snowregion","coldzone","freezezone","blizzard","arctic"},
        fallbackTags={"snowtree","icetree","snowfloor","icespike","snowground"},
    },
    {
        key="Vulcao",
        label="🌋 Vulcão",
        cor=Color3.fromRGB(255,80,30),
        desc="Bioma vulcânico — Carneiro, Cultistas, Lava",
        icon="volcano",
        searchTags={"volcanic","volcanozone","lavabiome","lavafloorzome","volcanobiome","volcanoregion","volcano","lavazone","magmazone"},
        fallbackTags={"lavapool","lava","volcano","lavapuddle","hotzone","infernal","scorpion"},
    },
    {
        key="Cavernas",
        label="🦇 Cavernas",
        cor=Color3.fromRGB(160,100,220),
        desc="Sistema de cavernas — Morcegos, baús especiais",
        icon="cave",
        searchTags={"cave","caveentrance","cavebiome","cavezone","underground","cavern","tunnel","mineentrance"},
        fallbackTags={"bat","cavewall","stalactite","stalagmite","cavefloor"},
    },
    {
        key="Fada",
        label="🧚 Fada",
        cor=Color3.fromRGB(120,255,200),
        desc="Mini-biome Fada — Lobos de Cogumelo, Árvore Mãe",
        icon="fairy",
        searchTags={"fairy","fairybiome","fairyzone","mushroom","fairyland","fairyforest","minibiome","mothertre","greattree"},
        fallbackTags={"mushroombig","fairyring","acornwolf","teal","mushball"},
    },
    {
        key="PoloNorte",
        label="🎅 Polo Norte",
        cor=Color3.fromRGB(100,200,255),
        desc="Polo Norte — Papai Noel, Elfos, estruturas natalinas",
        icon="northpole",
        searchTags={"northpole","north pole","christmas","xmas","santa","santazone","northpolebiome","winterzone","elves","elf","snowflake"},
        fallbackTags={"christmastree","santahouse","giftbox","present","elf","northzone"},
    },
}

-- Função para encontrar posição de bioma dinamicamente
local function encontrarBioma(biome)
    local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    -- Prioridade 1: busca por folders/modelos com nome do bioma
    for _, searchTag in ipairs(biome.searchTags) do
        for _, obj in pairs(workspace:GetDescendants()) do
            local found = nil
            pcall(function()
                local nameL = obj.Name:lower()
                if nameL:find(searchTag:lower()) then
                    if obj:IsA("BasePart") then
                        found = obj.Position + Vector3.new(0,6,0)
                    elseif obj:IsA("Model") then
                        local cf = obj:GetBoundingBox()
                        found = cf.Position + Vector3.new(0,6,0)
                    end
                end
            end)
            if found then return found end
        end
    end
    -- Prioridade 2: fallback tags
    for _, tag in ipairs(biome.fallbackTags) do
        for _, obj in pairs(workspace:GetDescendants()) do
            local found = nil
            pcall(function()
                if obj:IsA("BasePart") and obj.Name:lower():find(tag:lower()) then
                    found = obj.Position + Vector3.new(0,6,0)
                end
            end)
            if found then return found end
        end
    end
    return nil
end

local function teleportarBioma(biome)
    local pos = encontrarBioma(biome)
    local ch = Player.Character; if not ch then return false, "Personagem não encontrado" end
    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return false, "HRP não encontrado" end
    if pos then
        -- Anti-void
        pos = Vector3.new(pos.X, math.max(pos.Y, -80), pos.Z)
        hrp.CFrame = CFrame.new(pos)
        return true, biome.label
    end
    return false, "Bioma '"..biome.label.."' não encontrado nesta partida"
end

-- ══════════════ UI DA ABA TP ══════════════
local tpPage = Pages["TP"]
local tpLO = 0
local function tpLayoutOrder() tpLO += 1; return tpLO end

-- Cabeçalho decorativo
local tpHeader = Instance.new("Frame", tpPage)
tpHeader.BackgroundColor3 = Color3.fromRGB(20,22,32); tpHeader.BackgroundTransparency = 0.2
tpHeader.BorderSizePixel = 0; tpHeader.Size = UDim2.new(1,0,0,48); tpHeader.LayoutOrder = tpLayoutOrder(); tpHeader.ZIndex = 4
Instance.new("UICorner", tpHeader).CornerRadius = UDim.new(0,10)
local tpHStroke = Instance.new("UIStroke",tpHeader); tpHStroke.Color=Color3.fromRGB(88,101,242); tpHStroke.Thickness=1.2
-- Gradiente no header
local tpHGrad = pcall(function()
    local g = Instance.new("UIGradient", tpHeader)
    g.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(30,30,60)),ColorSequenceKeypoint.new(1,Color3.fromRGB(20,22,32))})
    g.Rotation = 90
end)
local tpHIcon = Instance.new("TextLabel",tpHeader)
tpHIcon.BackgroundTransparency=1; tpHIcon.Position=UDim2.new(0,12,0,0); tpHIcon.Size=UDim2.new(0,30,1,0)
tpHIcon.Font=Enum.Font.GothamBlack; tpHIcon.Text="🗺️"; tpHIcon.TextSize=22; tpHIcon.ZIndex=5
local tpHTitle = Instance.new("TextLabel",tpHeader)
tpHTitle.BackgroundTransparency=1; tpHTitle.Position=UDim2.new(0,46,0,4); tpHTitle.Size=UDim2.new(1,-50,0,20)
tpHTitle.Font=Enum.Font.GothamBlack; tpHTitle.Text="TELEPORTE — BIOMAS"; tpHTitle.TextColor3=Color3.fromRGB(88,101,242); tpHTitle.TextSize=13; tpHTitle.TextXAlignment=Enum.TextXAlignment.Left; tpHTitle.ZIndex=5
local tpHSub = Instance.new("TextLabel",tpHeader)
tpHSub.BackgroundTransparency=1; tpHSub.Position=UDim2.new(0,46,0,24); tpHSub.Size=UDim2.new(1,-50,0,16)
tpHSub.Font=Enum.Font.Gotham; tpHSub.Text="Busca dinâmica — funciona mesmo com biomas em posições diferentes"; tpHSub.TextColor3=Color3.fromRGB(80,90,120); tpHSub.TextSize=8; tpHSub.TextXAlignment=Enum.TextXAlignment.Left; tpHSub.ZIndex=5

-- Painel principal de seleção
local tpMainPanel = Instance.new("Frame", tpPage)
tpMainPanel.BackgroundColor3 = Color3.fromRGB(22,24,32); tpMainPanel.BorderSizePixel=0
tpMainPanel.Size = UDim2.new(1,0,0,110); tpMainPanel.LayoutOrder = tpLayoutOrder(); tpMainPanel.ZIndex=4
Instance.new("UICorner",tpMainPanel).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",tpMainPanel).Color=Color3.fromRGB(40,44,60)
pcall(function()
    local tpPanelGrad = Instance.new("UIGradient",tpMainPanel)
    tpPanelGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(25,28,42)),ColorSequenceKeypoint.new(1,Color3.fromRGB(18,20,28))})
    tpPanelGrad.Rotation=135
end)

-- === VARIÁVEL DO BIOMA SELECIONADO ===
local selectedBiomeData = BIOME_DATA[1]

-- === BOTÃO SELECTOR (dropdown trigger) ===
local selectorFrame = Instance.new("Frame",tpMainPanel)
selectorFrame.BackgroundColor3=Color3.fromRGB(28,30,44); selectorFrame.BorderSizePixel=0
selectorFrame.Position=UDim2.new(0,10,0,10); selectorFrame.Size=UDim2.new(1,-20,0,40); selectorFrame.ZIndex=5
Instance.new("UICorner",selectorFrame).CornerRadius=UDim.new(0,10)
local selStroke = Instance.new("UIStroke",selectorFrame); selStroke.Color=BIOME_DATA[1].cor; selStroke.Thickness=1.5

-- Ícone bioma selecionado
local selBiomeIcon = Instance.new("TextLabel",selectorFrame)
selBiomeIcon.BackgroundTransparency=1; selBiomeIcon.Position=UDim2.new(0,10,0,0); selBiomeIcon.Size=UDim2.new(0,30,1,0)
selBiomeIcon.Font=Enum.Font.GothamBlack; selBiomeIcon.Text="🌲"; selBiomeIcon.TextSize=18; selBiomeIcon.ZIndex=6

-- Label "Bioma Selecionado:"
local selPrefix = Instance.new("TextLabel",selectorFrame)
selPrefix.BackgroundTransparency=1; selPrefix.Position=UDim2.new(0,44,0,4); selPrefix.Size=UDim2.new(1,-100,0,14)
selPrefix.Font=Enum.Font.Gotham; selPrefix.Text="Bioma Selecionado:"; selPrefix.TextColor3=Color3.fromRGB(80,90,115); selPrefix.TextSize=8; selPrefix.TextXAlignment=Enum.TextXAlignment.Left; selPrefix.ZIndex=6

-- Nome do bioma selecionado
local selBiomeName = Instance.new("TextLabel",selectorFrame)
selBiomeName.BackgroundTransparency=1; selBiomeName.Position=UDim2.new(0,44,0,18); selBiomeName.Size=UDim2.new(1,-100,0,16)
selBiomeName.Font=Enum.Font.GothamBlack; selBiomeName.Text=BIOME_DATA[1].label; selBiomeName.TextColor3=BIOME_DATA[1].cor; selBiomeName.TextSize=12; selBiomeName.TextXAlignment=Enum.TextXAlignment.Left; selBiomeName.ZIndex=6

-- Seta dropdown
local selArrowFrame = Instance.new("Frame",selectorFrame)
selArrowFrame.BackgroundTransparency=1; selArrowFrame.Position=UDim2.new(1,-32,0.5,-8); selArrowFrame.Size=UDim2.new(0,16,0,16); selArrowFrame.ZIndex=6
local selArrow = Instance.new("TextLabel",selArrowFrame)
selArrow.BackgroundTransparency=1; selArrow.Size=UDim2.new(1,0,1,0); selArrow.Font=Enum.Font.GothamBlack; selArrow.Text="▼"; selArrow.TextColor3=BIOME_DATA[1].cor; selArrow.TextSize=14; selArrow.ZIndex=7

-- Badge "CLIQUE PARA ESCOLHER"
local selBadge = Instance.new("Frame",selectorFrame)
selBadge.BackgroundColor3=BIOME_DATA[1].cor; selBadge.BackgroundTransparency=0.7; selBadge.BorderSizePixel=0
selBadge.Position=UDim2.new(1,-92,0.5,-8); selBadge.Size=UDim2.new(0,56,0,16); selBadge.ZIndex=7
Instance.new("UICorner",selBadge).CornerRadius=UDim.new(0,8)
local selBadgeTxt = Instance.new("TextLabel",selBadge)
selBadgeTxt.BackgroundTransparency=1; selBadgeTxt.Size=UDim2.new(1,0,1,0); selBadgeTxt.Font=Enum.Font.GothamBold; selBadgeTxt.Text="ESCOLHER"; selBadgeTxt.TextColor3=Color3.fromRGB(255,255,255); selBadgeTxt.TextSize=7; selBadgeTxt.ZIndex=8

-- Botão TP
local tpActionBtn = Instance.new("TextButton",tpMainPanel)
tpActionBtn.BackgroundColor3=BIOME_DATA[1].cor; tpActionBtn.BorderSizePixel=0
tpActionBtn.Position=UDim2.new(0,10,0,58); tpActionBtn.Size=UDim2.new(1,-20,0,42); tpActionBtn.ZIndex=5
Instance.new("UICorner",tpActionBtn).CornerRadius=UDim.new(0,10)
local tpBtnStroke = Instance.new("UIStroke",tpActionBtn); tpBtnStroke.Color=Color3.fromRGB(255,255,255); tpBtnStroke.Thickness=1.2; tpBtnStroke.Transparency=0.8

-- Conteúdo do botão TP
local tpBtnIconLbl = Instance.new("TextLabel",tpActionBtn)
tpBtnIconLbl.BackgroundTransparency=1; tpBtnIconLbl.Position=UDim2.new(0,10,0,0); tpBtnIconLbl.Size=UDim2.new(0,30,1,0)
tpBtnIconLbl.Font=Enum.Font.GothamBlack; tpBtnIconLbl.Text="🌀"; tpBtnIconLbl.TextSize=20; tpBtnIconLbl.ZIndex=6

local tpBtnMainTxt = Instance.new("TextLabel",tpActionBtn)
tpBtnMainTxt.BackgroundTransparency=1; tpBtnMainTxt.Position=UDim2.new(0,44,0,4); tpBtnMainTxt.Size=UDim2.new(1,-54,0,18)
tpBtnMainTxt.Font=Enum.Font.GothamBlack; tpBtnMainTxt.Text="TP → "..BIOME_DATA[1].label; tpBtnMainTxt.TextColor3=Color3.fromRGB(255,255,255); tpBtnMainTxt.TextSize=12; tpBtnMainTxt.TextXAlignment=Enum.TextXAlignment.Left; tpBtnMainTxt.ZIndex=6

local tpBtnSubTxt = Instance.new("TextLabel",tpActionBtn)
tpBtnSubTxt.BackgroundTransparency=1; tpBtnSubTxt.Position=UDim2.new(0,44,0,22); tpBtnSubTxt.Size=UDim2.new(1,-54,0,14)
tpBtnSubTxt.Font=Enum.Font.Gotham; tpBtnSubTxt.Text=BIOME_DATA[1].desc; tpBtnSubTxt.TextColor3=Color3.fromRGB(220,225,240); tpBtnSubTxt.BackgroundTransparency=1; tpBtnSubTxt.TextSize=8; tpBtnSubTxt.TextXAlignment=Enum.TextXAlignment.Left; tpBtnSubTxt.ZIndex=6

-- Feedback label
local tpFeedback = Instance.new("TextLabel", tpPage)
tpFeedback.BackgroundTransparency=1; tpFeedback.Size=UDim2.new(1,0,0,18); tpFeedback.LayoutOrder=tpLayoutOrder(); tpFeedback.ZIndex=4
tpFeedback.Font=Enum.Font.GothamBold; tpFeedback.Text=""; tpFeedback.TextColor3=Color3.fromRGB(100,255,150); tpFeedback.TextSize=9

-- ================================================================
-- DROPDOWN BONITO — aparece acima do panel, com animação elegante
-- ================================================================
local dropdownContainer = Instance.new("Frame", ScreenGui)
dropdownContainer.BackgroundTransparency=1; dropdownContainer.BorderSizePixel=0
dropdownContainer.Size=UDim2.new(0,240,0,0); dropdownContainer.ZIndex=500
dropdownContainer.Visible=false; dropdownContainer.ClipsDescendants=false
dropdownContainer.Name="BiomeDropdown"

local dropBg = Instance.new("Frame",dropdownContainer)
dropBg.BackgroundColor3=Color3.fromRGB(18,20,30); dropBg.BorderSizePixel=0
dropBg.Size=UDim2.new(1,0,1,0); dropBg.ZIndex=501; dropBg.ClipsDescendants=true
Instance.new("UICorner",dropBg).CornerRadius=UDim.new(0,14)
local dropStroke = Instance.new("UIStroke",dropBg); dropStroke.Color=Color3.fromRGB(88,101,242); dropStroke.Thickness=1.5

-- Gradiente fundo dropdown
pcall(function()
    local dropGrad = Instance.new("UIGradient",dropBg)
    dropGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(22,25,40)),ColorSequenceKeypoint.new(1,Color3.fromRGB(15,16,24))})
    dropGrad.Rotation=135
end)

-- Header do dropdown
local dropHeader = Instance.new("Frame",dropBg)
dropHeader.BackgroundColor3=Color3.fromRGB(88,101,242); dropHeader.BackgroundTransparency=0.8; dropHeader.BorderSizePixel=0
dropHeader.Size=UDim2.new(1,0,0,30); dropHeader.ZIndex=502
Instance.new("UICorner",dropHeader).CornerRadius=UDim.new(0,12)
local dropHeaderFix = Instance.new("Frame",dropHeader)
dropHeaderFix.BackgroundColor3=Color3.fromRGB(88,101,242); dropHeaderFix.BackgroundTransparency=0.8; dropHeaderFix.BorderSizePixel=0
dropHeaderFix.Position=UDim2.new(0,0,0.5,0); dropHeaderFix.Size=UDim2.new(1,0,0.5,0); dropHeaderFix.ZIndex=502
local dropTitle = Instance.new("TextLabel",dropHeader)
dropTitle.BackgroundTransparency=1; dropTitle.Position=UDim2.new(0,10,0,0); dropTitle.Size=UDim2.new(1,-40,1,0)
dropTitle.Font=Enum.Font.GothamBlack; dropTitle.Text="🗺️  ESCOLHER BIOMA"; dropTitle.TextColor3=Color3.fromRGB(180,190,255); dropTitle.TextSize=10; dropTitle.TextXAlignment=Enum.TextXAlignment.Left; dropTitle.ZIndex=503

local dropCloseBtn = Instance.new("TextButton",dropHeader)
dropCloseBtn.BackgroundTransparency=1; dropCloseBtn.Position=UDim2.new(1,-28,0.5,-10); dropCloseBtn.Size=UDim2.new(0,20,0,20)
dropCloseBtn.Font=Enum.Font.GothamBlack; dropCloseBtn.Text="✕"; dropCloseBtn.TextColor3=Color3.fromRGB(180,100,100); dropCloseBtn.TextSize=12; dropCloseBtn.ZIndex=503

-- Lista de biomas
local dropList = Instance.new("ScrollingFrame",dropBg)
dropList.BackgroundTransparency=1; dropList.BorderSizePixel=0
dropList.Position=UDim2.new(0,0,0,32); dropList.Size=UDim2.new(1,0,1,-34); dropList.ZIndex=502
dropList.ScrollBarThickness=3; dropList.ScrollBarImageColor3=Color3.fromRGB(88,101,242)
dropList.AutomaticCanvasSize=Enum.AutomaticSize.Y; dropList.CanvasSize=UDim2.new(0,0,0,0)
local dropListLayout = Instance.new("UIListLayout",dropList)
dropListLayout.Padding=UDim.new(0,3); dropListLayout.SortOrder=Enum.SortOrder.LayoutOrder
local dropListPad = Instance.new("UIPadding",dropList)
dropListPad.PaddingTop=UDim.new(0,4); dropListPad.PaddingLeft=UDim.new(0,6); dropListPad.PaddingRight=UDim.new(0,6); dropListPad.PaddingBottom=UDim.new(0,6)

local dropOpen = false
local DROP_FULL_H = 42 * #BIOME_DATA + 70

-- Função para atualizar UI com bioma selecionado
local function selectBiome(b)
    selectedBiomeData = b
    selBiomeName.Text = b.label
    selBiomeName.TextColor3 = b.cor
    selBiomeIcon.Text = b.label:sub(1,2)  -- pega emoji
    selArrow.TextColor3 = b.cor
    selStroke.Color = b.cor
    selBadge.BackgroundColor3 = b.cor
    tpActionBtn.BackgroundColor3 = b.cor
    tpBtnMainTxt.Text = "TP → "..b.label
    tpBtnSubTxt.Text = b.desc
    dropStroke.Color = b.cor
end

-- Criar itens do dropdown
for i, biome in ipairs(BIOME_DATA) do
    local item = Instance.new("TextButton",dropList)
    item.BackgroundColor3=Color3.fromRGB(24,26,38); item.BorderSizePixel=0
    item.Size=UDim2.new(1,0,0,38); item.Text=""; item.LayoutOrder=i; item.ZIndex=503
    Instance.new("UICorner",item).CornerRadius=UDim.new(0,9)
    local itemStroke = Instance.new("UIStroke",item); itemStroke.Color=biome.cor; itemStroke.Thickness=1; itemStroke.Transparency=0.7

    -- Barra colorida lateral
    local itemBar = Instance.new("Frame",item)
    itemBar.BackgroundColor3=biome.cor; itemBar.BorderSizePixel=0
    itemBar.Position=UDim2.new(0,0,0.15,0); itemBar.Size=UDim2.new(0,3,0.7,0); itemBar.ZIndex=504
    Instance.new("UICorner",itemBar).CornerRadius=UDim.new(0,2)

    -- Fundo gradiente cor do bioma
    local itemFill = Instance.new("Frame",item)
    itemFill.BackgroundColor3=biome.cor; itemFill.BackgroundTransparency=0.88; itemFill.BorderSizePixel=0
    itemFill.Size=UDim2.new(1,0,1,0); itemFill.ZIndex=503
    Instance.new("UICorner",itemFill).CornerRadius=UDim.new(0,9)

    -- Emoji/ícone
    local itemIcon = Instance.new("TextLabel",item)
    itemIcon.BackgroundTransparency=1; itemIcon.Position=UDim2.new(0,8,0,0); itemIcon.Size=UDim2.new(0,24,1,0)
    itemIcon.Font=Enum.Font.GothamBlack; itemIcon.Text=biome.label:sub(1,2); itemIcon.TextSize=16; itemIcon.ZIndex=505

    -- Nome do bioma
    local itemName = Instance.new("TextLabel",item)
    itemName.BackgroundTransparency=1; itemName.Position=UDim2.new(0,36,0,4); itemName.Size=UDim2.new(1,-80,0,16)
    itemName.Font=Enum.Font.GothamBlack; itemName.Text=biome.label; itemName.TextColor3=biome.cor; itemName.TextSize=11; itemName.TextXAlignment=Enum.TextXAlignment.Left; itemName.ZIndex=505

    -- Descrição
    local itemDesc = Instance.new("TextLabel",item)
    itemDesc.BackgroundTransparency=1; itemDesc.Position=UDim2.new(0,36,0,20); itemDesc.Size=UDim2.new(1,-80,0,12)
    itemDesc.Font=Enum.Font.Gotham; itemDesc.Text=biome.desc; itemDesc.TextColor3=Color3.fromRGB(80,90,115); itemDesc.TextSize=7; itemDesc.TextXAlignment=Enum.TextXAlignment.Left; itemDesc.TextTruncate=Enum.TextTruncate.AtEnd; itemDesc.ZIndex=505

    -- Checkmark (visível quando selecionado)
    local itemCheck = Instance.new("TextLabel",item)
    itemCheck.BackgroundTransparency=1; itemCheck.Position=UDim2.new(1,-28,0.5,-9); itemCheck.Size=UDim2.new(0,18,0,18)
    itemCheck.Font=Enum.Font.GothamBlack; itemCheck.Text="✓"; itemCheck.TextColor3=biome.cor; itemCheck.TextSize=14; itemCheck.ZIndex=505
    itemCheck.TextTransparency = (i==1) and 0 or 1

    -- Hover
    item.MouseEnter:Connect(function()
        TweenService:Create(item,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(30,34,50)}):Play()
        TweenService:Create(itemStroke,TweenInfo.new(0.12),{Transparency=0.3}):Play()
    end)
    item.MouseLeave:Connect(function()
        TweenService:Create(item,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(24,26,38)}):Play()
        TweenService:Create(itemStroke,TweenInfo.new(0.12),{Transparency=0.7}):Play()
    end)

    local localBiome = biome
    local localCheck = itemCheck
    item.MouseButton1Click:Connect(function()
        -- Esconde todos os checks
        for _, ch2 in pairs(dropList:GetDescendants()) do
            if ch2.Name == "" and ch2:IsA("TextLabel") and ch2.Text == "✓" then
                TweenService:Create(ch2,TweenInfo.new(0.15),{TextTransparency=1}):Play()
            end
        end
        TweenService:Create(localCheck,TweenInfo.new(0.15),{TextTransparency=0}):Play()
        selectBiome(localBiome)
        -- Fechar dropdown
        dropOpen = false
        TweenService:Create(dropdownContainer,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,240,0,0)}):Play()
        TweenService:Create(selArrow,TweenInfo.new(0.2),{Rotation=0}):Play()
        task.delay(0.23,function() dropdownContainer.Visible=false end)
    end)
end

-- Fechar dropdown
dropCloseBtn.MouseButton1Click:Connect(function()
    dropOpen = false
    TweenService:Create(dropdownContainer,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,240,0,0)}):Play()
    TweenService:Create(selArrow,TweenInfo.new(0.2),{Rotation=0}):Play()
    task.delay(0.23,function() dropdownContainer.Visible=false end)
end)

-- Abrir/fechar dropdown ao clicar no selector
local selBtn = Instance.new("TextButton",selectorFrame)
selBtn.BackgroundTransparency=1; selBtn.Size=UDim2.new(1,0,1,0); selBtn.Text=""; selBtn.ZIndex=10
selBtn.MouseButton1Click:Connect(function()
    dropOpen = not dropOpen
    if dropOpen then
        -- Posicionar o dropdown sobre o painel
        local abs = tpMainPanel.AbsolutePosition
        local absSize = tpMainPanel.AbsoluteSize
        dropdownContainer.Position = UDim2.new(0, abs.X, 0, abs.Y - math.min(DROP_FULL_H, 300) - 4)
        dropdownContainer.Size = UDim2.new(0,240,0,0)
        dropdownContainer.Visible = true
        TweenService:Create(dropdownContainer,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,240,0,math.min(DROP_FULL_H,300))}):Play()
        TweenService:Create(selArrow,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=180}):Play()
    else
        TweenService:Create(dropdownContainer,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,240,0,0)}):Play()
        TweenService:Create(selArrow,TweenInfo.new(0.2),{Rotation=0}):Play()
        task.delay(0.23,function() dropdownContainer.Visible=false end)
    end
end)

-- Animações botão TP
tpActionBtn.MouseEnter:Connect(function()
    TweenService:Create(tpActionBtn,TweenInfo.new(0.15),{Size=UDim2.new(1,-16,0,44),Position=UDim2.new(0,8,0,57)}):Play()
    TweenService:Create(tpBtnStroke,TweenInfo.new(0.15),{Transparency=0.3}):Play()
end)
tpActionBtn.MouseLeave:Connect(function()
    TweenService:Create(tpActionBtn,TweenInfo.new(0.15),{Size=UDim2.new(1,-20,0,42),Position=UDim2.new(0,10,0,58)}):Play()
    TweenService:Create(tpBtnStroke,TweenInfo.new(0.15),{Transparency=0.8}):Play()
end)

local tpCooldown = false
tpActionBtn.MouseButton1Click:Connect(function()
    if tpCooldown then return end; tpCooldown = true
    tpBtnIconLbl.Text = "⏳"
    tpBtnMainTxt.Text = "Buscando "..selectedBiomeData.label.."..."
    task.spawn(function()
        local ok, msg = teleportarBioma(selectedBiomeData)
        task.wait(0.2)
        if ok then
            tpBtnIconLbl.Text = "✅"
            tpBtnMainTxt.Text = "TP concluído! — "..selectedBiomeData.label
            tpFeedback.Text = "✓ Teleportado para "..selectedBiomeData.label
            tpFeedback.TextColor3 = selectedBiomeData.cor
        else
            tpBtnIconLbl.Text = "❌"
            tpBtnMainTxt.Text = "Não encontrado nesta partida"
            tpFeedback.Text = "✗ "..msg
            tpFeedback.TextColor3 = Color3.fromRGB(255,80,80)
        end
        task.wait(2)
        tpBtnIconLbl.Text = "🌀"
        tpBtnMainTxt.Text = "TP → "..selectedBiomeData.label
        tpFeedback.Text = ""
        tpCooldown = false
    end)
end)

-- Grid de biomas (mini cards rápidos)
local tpGridSec = Instance.new("Frame",tpPage)
tpGridSec.BackgroundColor3=Color3.fromRGB(20,22,30); tpGridSec.BackgroundTransparency=0.3; tpGridSec.BorderSizePixel=0
tpGridSec.Size=UDim2.new(1,0,0,22); tpGridSec.LayoutOrder=tpLayoutOrder(); tpGridSec.ZIndex=4
Instance.new("UICorner",tpGridSec).CornerRadius=UDim.new(0,6)
local tpGridBar=Instance.new("Frame",tpGridSec); tpGridBar.BackgroundColor3=Color3.fromRGB(88,101,242); tpGridBar.BorderSizePixel=0
tpGridBar.Position=UDim2.new(0,0,0,0); tpGridBar.Size=UDim2.new(0,3,1,0); tpGridBar.ZIndex=5
Instance.new("UICorner",tpGridBar).CornerRadius=UDim.new(0,3)
local tpGridLabel=Instance.new("TextLabel",tpGridSec); tpGridLabel.BackgroundTransparency=1
tpGridLabel.Position=UDim2.new(0,10,0,0); tpGridLabel.Size=UDim2.new(1,-14,1,0); tpGridLabel.Font=Enum.Font.GothamBlack; tpGridLabel.Text="⚡ ACESSO RÁPIDO — Clique para selecionar e teleportar"
tpGridLabel.TextColor3=Color3.fromRGB(88,101,242); tpGridLabel.TextSize=9; tpGridLabel.TextXAlignment=Enum.TextXAlignment.Left; tpGridLabel.ZIndex=5

-- Mini cards de bioma (acesso rápido)
local tpGrid = Instance.new("Frame",tpPage)
tpGrid.BackgroundTransparency=1; tpGrid.BorderSizePixel=0
local tpGridRows = math.ceil(#BIOME_DATA/2)
tpGrid.Size=UDim2.new(1,0,0, tpGridRows*68); tpGrid.LayoutOrder=tpLayoutOrder(); tpGrid.ZIndex=4
pcall(function()
    local tpGridLayout = Instance.new("UIGridLayout",tpGrid)
    tpGridLayout.CellSize=UDim2.new(0.5,-4,0,62); tpGridLayout.CellPadding=UDim2.new(0,6,0,6); tpGridLayout.SortOrder=Enum.SortOrder.LayoutOrder
end)

for i, biome in ipairs(BIOME_DATA) do
    local card = Instance.new("Frame",tpGrid)
    card.BackgroundColor3=Color3.fromRGB(22,24,34); card.BorderSizePixel=0; card.LayoutOrder=i; card.ZIndex=5
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
    local cardStroke=Instance.new("UIStroke",card); cardStroke.Color=biome.cor; cardStroke.Thickness=1.2; cardStroke.Transparency=0.6
    local cardFill=Instance.new("Frame",card); cardFill.BackgroundColor3=biome.cor; cardFill.BackgroundTransparency=0.88; cardFill.BorderSizePixel=0
    cardFill.Size=UDim2.new(1,0,1,0); cardFill.ZIndex=5; Instance.new("UICorner",cardFill).CornerRadius=UDim.new(0,10)
    local cardBar=Instance.new("Frame",card); cardBar.BackgroundColor3=biome.cor; cardBar.BorderSizePixel=0
    cardBar.Position=UDim2.new(0,0,0.1,0); cardBar.Size=UDim2.new(0,3,0.8,0); cardBar.ZIndex=6; Instance.new("UICorner",cardBar).CornerRadius=UDim.new(0,2)

    local cardIcon=Instance.new("TextLabel",card); cardIcon.BackgroundTransparency=1
    cardIcon.Position=UDim2.new(0,8,0,6); cardIcon.Size=UDim2.new(0,22,0,22)
    cardIcon.Font=Enum.Font.GothamBlack; cardIcon.Text=biome.label:sub(1,2); cardIcon.TextSize=18; cardIcon.ZIndex=7

    local cardName=Instance.new("TextLabel",card); cardName.BackgroundTransparency=1
    cardName.Position=UDim2.new(0,8,0,28); cardName.Size=UDim2.new(1,-16,0,14)
    cardName.Font=Enum.Font.GothamBold; cardName.Text=biome.label:sub(3):gsub("^%s+",""); cardName.TextColor3=biome.cor
    cardName.TextSize=9; cardName.TextXAlignment=Enum.TextXAlignment.Left; cardName.ZIndex=7

    local cardTp=Instance.new("TextButton",card); cardTp.BackgroundColor3=biome.cor; cardTp.BackgroundTransparency=0.2; cardTp.BorderSizePixel=0
    cardTp.Position=UDim2.new(1,-42,0.5,-10); cardTp.Size=UDim2.new(0,36,0,20)
    cardTp.Font=Enum.Font.GothamBlack; cardTp.Text="TP"; cardTp.TextColor3=Color3.fromRGB(255,255,255); cardTp.TextSize=9; cardTp.ZIndex=8
    Instance.new("UICorner",cardTp).CornerRadius=UDim.new(0,6)

    card.MouseEnter:Connect(function() TweenService:Create(card,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,32,46)}):Play(); TweenService:Create(cardStroke,TweenInfo.new(0.12),{Transparency=0.2}):Play() end)
    card.MouseLeave:Connect(function() TweenService:Create(card,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(22,24,34)}):Play(); TweenService:Create(cardStroke,TweenInfo.new(0.12),{Transparency=0.6}):Play() end)

    local localBiome2=biome
    cardTp.MouseButton1Click:Connect(function()
        if tpCooldown then return end; tpCooldown=true
        selectBiome(localBiome2)
        cardTp.Text="⏳"; cardTp.BackgroundTransparency=0.5
        task.spawn(function()
            local ok,msg=teleportarBioma(localBiome2); task.wait(0.2)
            if ok then
                cardTp.Text="✅"; tpFeedback.Text="✓ TP "..localBiome2.label; tpFeedback.TextColor3=localBiome2.cor
            else
                cardTp.Text="❌"; tpFeedback.Text="✗ "..localBiome2.label.." não encontrado"; tpFeedback.TextColor3=Color3.fromRGB(255,80,80)
            end
            task.wait(2); cardTp.Text="TP"; cardTp.BackgroundTransparency=0.2; tpFeedback.Text=""; tpCooldown=false
        end)
    end)
end

-- Info box TP
local tpInfoBox = Instance.new("Frame",tpPage)
tpInfoBox.BackgroundColor3=Color3.fromRGB(10,15,28); tpInfoBox.BackgroundTransparency=0.4; tpInfoBox.BorderSizePixel=0
tpInfoBox.Size=UDim2.new(1,0,0,50); tpInfoBox.LayoutOrder=tpLayoutOrder(); tpInfoBox.ZIndex=4
Instance.new("UICorner",tpInfoBox).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",tpInfoBox).Color=Color3.fromRGB(88,101,242)
local tpInfoTxt=Instance.new("TextLabel",tpInfoBox); tpInfoTxt.BackgroundTransparency=1
tpInfoTxt.Position=UDim2.new(0,8,0,4); tpInfoTxt.Size=UDim2.new(1,-16,1,-8)
tpInfoTxt.Font=Enum.Font.Gotham; tpInfoTxt.TextColor3=Color3.fromRGB(100,175,255); tpInfoTxt.TextSize=8; tpInfoTxt.TextWrapped=true
tpInfoTxt.TextXAlignment=Enum.TextXAlignment.Left; tpInfoTxt.TextYAlignment=Enum.TextYAlignment.Top; tpInfoTxt.ZIndex=5
tpInfoTxt.Text="ℹ️  TP v6 — Busca dinâmica: encontra o bioma pelo nome de objetos no workspace. Sem posições fixas — funciona em qualquer partida mesmo que os biomas mudem de lugar. Se um bioma não for encontrado, significa que ele não gerou nesta partida."
