-- ╔══════════════════════════════════════════════════════════════════╗
-- ║     PUDIM HUB — v5  (Tp Biomes + SliderBars + Fixes)           ║
-- ║  + Tp Biomes em Avançado Funções                                ║
-- ║  + SliderBar no Fly Speed / Speed / Jump Power                  ║
-- ║  + LayoutOrder correto no Player tab                            ║
-- ╚══════════════════════════════════════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local Lighting         = game:GetService("Lighting")

local Player = Players.LocalPlayer
local Cam    = workspace.CurrentCamera

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
TitleLabel.Text           = "PudimHub v5"
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
    {key="Player",label="Player"},{key="Configuracoes",label="Configurações"},{key="AvancadoFuncoes",label="Avançado Funções"},
}
local GroupConfig = {
    {label="GERAL",   keys={"Info","Status"}},
    {label="COMBATE", keys={"Farm","Esp","Bring","AvancadoFarm"}},
    {label="EXTRA",   keys={"Player","Configuracoes","AvancadoFuncoes"}},
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
infoStatusSub.Text="ID: "..tostring(game.PlaceId).."  •  Hub v5"
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
dadosText.Text="Este script foi desenvolvido por apenas 1 pessoa e está sendo desenvolvido por apenas 1 pessoa também. Às vezes pode demorar para atualizar o script, às vezes pode ser rápido e às vezes pode ser bem devagar. Porém, eu sempre irei tentar ir o mais rápido possível, então a demora pode estar relacionada a outros fatores. Só queria avisar isso para quando ele estiver desatualizado e demorar um pouco — aqui dá para saber melhor o motivo da demora, pois 1 pessoa desenvolvendo um script desse tamanho SOZINHO é difícil e demorado, mesmo tendo tempo livre às vezes."
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
        r(12,0,4,5,2); local folha=r(14,1,8,5,2); folha.BackgroundColor3=Color3.fromRGB(60,180,60)
        c(14,16,11); local brilho=r(8,7,5,5,3); brilho.BackgroundColor3=Color3.fromRGB(255,255,255); brilho.BackgroundTransparency=0.4
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
    {key="AnimAgressivo",label="🐺 Animais Agressivos",  cor=Color3.fromRGB(255,175,30),  tipo="entity", alcance=600, desc="Wolf, Bear, Polar Bear, Frog, Scorpion…",
     nomes={"Wolf","Alpha Wolf","AlphaWolf","Bear","Polar Bear","PolarBear","Arctic Fox","ArcticFox","Frog","Blue Frog","Purple Frog","Green Frog","BlueFrog","PurpleFrog","GreenFrog","Scorpion","Hellephant","Meteor Crab","MeteorCrab","Mammoth"}},
    {key="Monstros",     label="💀 Monstros",            cor=Color3.fromRGB(255,50,50),   tipo="entity", alcance=math.huge, desc="The Deer, The Owl, The Ram",
     nomes={"The Deer","TheDeer","Deer","The Owl","TheOwl","Owl","The Ram","TheRam","Ram"}},
    {key="Cultistas",    label="⚔️ Cultistas",           cor=Color3.fromRGB(195,60,200),  tipo="entity", alcance=math.huge, desc="Cultist, Crossbow, Juggernaut, King, Mega…",
     nomes={"Cultist","Melee Cultist","MeleeCultist","Crossbow Cultist","CrossbowCultist","Juggernaut Cultist","JuggernautCultist","Juggernaut","Cultist King","CultistKing","Mega Cultist","MegaCultist"}},
    {key="Aliens",       label="👽 Aliens",              cor=Color3.fromRGB(60,255,200),  tipo="entity", alcance=700, desc="Alien, Elite Alien",
     nomes={"Alien","Elite Alien","EliteAlien","NormalAlien"}},
    {key="EspLog",       label="🪵 Log",                 cor=Color3.fromRGB(190,130,60),  tipo="item",   alcance=400, desc="Log — combustível principal", nomes={"Log"}},
    {key="EspCombustivel",label="🔥 Combustível",        cor=Color3.fromRGB(255,120,30),  tipo="item",   alcance=400, desc="Coal, Biofuel, Fuel Canister, Oil Barrel…",
     nomes={"Coal","Biofuel","Oil Barrel","OilBarrel","Fuel Canister","FuelCanister","Purple Fur Tuft","PurpleFurTuft","Chair"}},
    {key="EspCarcacas",  label="🦴 Carcaças",            cor=Color3.fromRGB(180,100,50),  tipo="item",   alcance=350, desc="Wolf/Bear/PolarBear/Mammoth/Hellephant Corpse…",
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
    {key="EspFerr",      label="🪓 Ferramentas & Sacos", cor=Color3.fromRGB(255,200,55),  tipo="item",   alcance=500, desc="Axes, Sacks, Rods, Flutes, Armaduras…",
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

-- UI ESP (mantida igual à v4)
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
    btn.MouseEnter:Connect(function() if currentTab~=cat.key then TweenService:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(34,37,45)}):Play() end end)
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
    {key="BCura",     label="💊 Bring Cura",        cor=Color3.fromRGB(100,255,180), desc="Bandage, Medkit", nomes={"Bandage","Medkit"}},
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

-- ══════════════════════════════════════════════════════
--  PLAYER TAB — Speed, Jump, Fly, Noclip, TpClick, BauANC
--  (CORRIGIDO: LayoutOrder fixo + SliderBars)
-- ══════════════════════════════════════════════════════
local playerSpeed = 30
local playerJump  = 80
local flyEnabled  = false
local flySpeed    = 40
local flyBodyVel, flyBodyGyro, flyConn
local noclipEnabled = false
local tpClickEnabled = false
local tpClickConn
local bauANCEnabled  = false
local bauANCConn

local function applySpeed(v)
    pcall(function()
        local ch=Player.Character; if not ch then return end
        local hum=ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
        hum.WalkSpeed = v
    end)
end
local function applyJump(v)
    pcall(function()
        local ch=Player.Character; if not ch then return end
        local hum=ch:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
        hum.UseJumpPower = true; hum.JumpPower = v
    end)
end
Player.CharacterAdded:Connect(function()
    task.wait(1); applySpeed(playerSpeed); applyJump(playerJump)
end)

local function setFly(state)
    flyEnabled = state
    if state then
        local ch=Player.Character; if not ch then return end
        local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if flyBodyVel then flyBodyVel:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        flyBodyVel=Instance.new("BodyVelocity",hrp)
        flyBodyVel.MaxForce=Vector3.new(1e6,1e6,1e6); flyBodyVel.Velocity=Vector3.zero
        flyBodyGyro=Instance.new("BodyGyro",hrp)
        flyBodyGyro.MaxTorque=Vector3.new(1e6,1e6,1e6); flyBodyGyro.CFrame=hrp.CFrame
        if flyConn then flyConn:Disconnect() end
        flyConn=RunService.Heartbeat:Connect(function()
            if not flyEnabled then return end
            local c2=Player.Character; if not c2 then return end
            local h2=c2:FindFirstChild("HumanoidRootPart"); if not h2 then return end
            if not flyBodyVel or not flyBodyVel.Parent then return end
            local cam=workspace.CurrentCamera; local dir=Vector3.zero
            local UIS=UserInputService
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
            flyBodyVel.Velocity=dir.Magnitude>0 and dir.Unit*flySpeed or Vector3.zero
            flyBodyGyro.CFrame=cam.CFrame
        end)
    else
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        pcall(function() if flyBodyVel then flyBodyVel:Destroy(); flyBodyVel=nil end end)
        pcall(function() if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro=nil end end)
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

local function setBauANC(state)
    bauANCEnabled=state
    if state then
        if bauANCConn then bauANCConn:Disconnect() end
        bauANCConn=workspace.DescendantAdded:Connect(function(obj)
            if not bauANCEnabled then return end
            task.defer(function()
                if not obj or not obj.Parent then return end
                if obj:IsA("Animator") then
                    for _,tr in ipairs(obj:GetPlayingAnimationTracks()) do pcall(function() tr:AdjustSpeed(9999) end) end
                end
            end)
        end)
    else
        if bauANCConn then bauANCConn:Disconnect(); bauANCConn=nil end
    end
end

-- ══════════════════════════════════════════════════════
--  UI PLAYER — LayoutOrder FIXO com contador
-- ══════════════════════════════════════════════════════
local plLO = 0
local function plNextLO() plLO+=1; return plLO end

-- Seção header (usa plNextLO para ordem correta)
local function makePlSec(titulo, cor)
    local hdr=Instance.new("Frame",Pages["Player"]); hdr.BackgroundColor3=Color3.fromRGB(20,22,30)
    hdr.BackgroundTransparency=0.3; hdr.BorderSizePixel=0; hdr.Size=UDim2.new(1,0,0,22)
    hdr.LayoutOrder=plNextLO()  -- CORRIGIDO: usa contador fixo
    hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",hdr); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=5; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,0)
    lbl.Size=UDim2.new(1,-14,1,0); lbl.Font=Enum.Font.GothamBlack; lbl.Text=titulo
    lbl.TextColor3=cor; lbl.TextSize=9; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
end

-- Toggle para player tab
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
    local estado=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=11
    btn.MouseButton1Click:Connect(function()
        estado=not estado
        TweenService:Create(pill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundColor3=estado and cor or Color3.fromRGB(45,50,62)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=estado and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
            BackgroundColor3=estado and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
        }):Play()
        TweenService:Create(rowS,TweenInfo.new(0.2),{Color=estado and cor or Color3.fromRGB(42,46,58)}):Play()
        onToggle(estado)
    end)
end

-- ══════════════════════════════════════════════════════
--  SLIDERBAR (drag) — substitui os botões de +/-
-- ══════════════════════════════════════════════════════
local function makeSliderBar(parentPage, lbl_txt, desc_txt, cor, minV, maxV, initVal, onChange)
    local row = Instance.new("Frame", parentPage)
    row.BackgroundColor3 = Color3.fromRGB(28,30,38)
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1,0,0,78)
    row.LayoutOrder = plNextLO()
    row.ZIndex = 5
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)
    local rowS = Instance.new("UIStroke", row); rowS.Color = Color3.fromRGB(42,46,58); rowS.Thickness = 1

    -- Labels
    local tl = Instance.new("TextLabel", row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,8); tl.Size=UDim2.new(0.65,0,0,16); tl.Font=Enum.Font.GothamBold
    tl.Text=lbl_txt; tl.TextColor3=Color3.fromRGB(220,225,240); tl.TextSize=12
    tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7

    local valLbl = Instance.new("TextLabel", row); valLbl.BackgroundTransparency=1
    valLbl.Position=UDim2.new(1,-60,0,8); valLbl.Size=UDim2.new(0,52,0,16); valLbl.Font=Enum.Font.GothamBold
    valLbl.Text=tostring(initVal); valLbl.TextColor3=cor; valLbl.TextSize=12
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.ZIndex=7

    local td = Instance.new("TextLabel", row); td.BackgroundTransparency=1
    td.Position=UDim2.new(0,14,0,26); td.Size=UDim2.new(1,-20,0,14); td.Font=Enum.Font.Gotham
    td.Text=desc_txt; td.TextColor3=Color3.fromRGB(90,100,120); td.TextSize=9
    td.TextXAlignment=Enum.TextXAlignment.Left; td.ZIndex=7

    -- Track
    local trackBg = Instance.new("Frame", row); trackBg.BackgroundColor3=Color3.fromRGB(42,48,62)
    trackBg.BorderSizePixel=0; trackBg.Position=UDim2.new(0,14,0,52); trackBg.Size=UDim2.new(1,-28,0,14)
    trackBg.ZIndex=7; Instance.new("UICorner",trackBg).CornerRadius=UDim.new(1,0)

    local pct0 = math.clamp((initVal - minV) / (maxV - minV), 0, 1)

    local fill = Instance.new("Frame", trackBg); fill.BackgroundColor3=cor; fill.BorderSizePixel=0
    fill.Size=UDim2.new(pct0,0,1,0); fill.ZIndex=8
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local knob = Instance.new("Frame", trackBg); knob.BackgroundColor3=Color3.fromRGB(255,255,255)
    knob.BorderSizePixel=0; knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Position=UDim2.new(pct0,0,0.5,0); knob.Size=UDim2.new(0,18,0,18); knob.ZIndex=9
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local kS=Instance.new("UIStroke",knob); kS.Color=cor; kS.Thickness=2

    local dragging = false
    local curV = {initVal}

    local function setVal(pct)
        pct = math.clamp(pct, 0, 1)
        local v = math.round(minV + (maxV - minV) * pct)
        curV[1] = v; valLbl.Text = tostring(v)
        fill.Size = UDim2.new(pct,0,1,0); knob.Position = UDim2.new(pct,0,0.5,0)
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
--  CONSTRUÇÃO DA ABA PLAYER (ordem correta)
-- ══════════════════════════════════════════════════════
makePlSec("⚡ VELOCIDADE & PULO", Color3.fromRGB(255,200,50))
makeSliderBar(Pages["Player"], "⚡ Speed", "Velocidade de caminhada  (padrão: 16)", Color3.fromRGB(255,180,30), 16, 275, 30, function(v) playerSpeed=v; applySpeed(v) end)
makeSliderBar(Pages["Player"], "🦘 Jump Power", "Altura do pulo  (padrão: 50)", Color3.fromRGB(100,220,255), 50, 1285, 80, function(v) playerJump=v; applyJump(v) end)

makePlSec("✈️ VOO & NOCLIP", Color3.fromRGB(100,200,255))
makePlToggle("✈️ Fly", "W/A/S/D mover  •  Espaço = subir  •  Ctrl = descer", Color3.fromRGB(80,180,255), function(s) setFly(s) end)
makeSliderBar(Pages["Player"], "💨 Fly Speed", "Velocidade do voo  (padrão: 40)", Color3.fromRGB(120,200,255), 16, 345, 40, function(v) flySpeed=v end)
makePlToggle("👻 Noclip", "Atravessa paredes  •  Anti-void Y = -100", Color3.fromRGB(140,255,140), function(s) setNoclip(s) end)

makePlSec("🔧 UTILIDADES", Color3.fromRGB(255,210,80))
makePlToggle("⚡ TP Click", "Clique em qualquer lugar para teleportar", Color3.fromRGB(255,220,60), function(s) setTpClick(s) end)
makePlToggle("📦 Baú ANC", "Baús abrem instantaneamente", Color3.fromRGB(210,160,80), function(s) setBauANC(s) end)

-- ══════════════════════════════════════════════════════
--  AIMBOT
-- ══════════════════════════════════════════════════════
local ANIMAL_NAMES = {
    "wolf","alpha wolf","alphawolf","bear","polar bear","polarbear","arctic fox","arcticfox",
    "frog","blue frog","purple frog","green frog","bluefrog","purplefrog","greenfrog",
    "scorpion","hellephant","meteor crab","meteorcrab","mammoth",
    "bunny","horse","kiwi","turkey","alien","elite alien","elitealien"
}
local ANIMAL_SET = {}
for _, n in ipairs(ANIMAL_NAMES) do ANIMAL_SET[n] = true end

local function findNearestAnimalHrp()
    local ch = Player.Character; if not ch then return nil end
    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local myPos = hrp.Position
    local best, bestDist = nil, math.huge
    local pchars={}; for _,pl in ipairs(Players:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end
    for _, obj in ipairs(workspace:GetDescendants()) do
        pcall(function()
            if not obj:IsA("Model") then return end
            if pchars[obj] then return end
            local hum = obj:FindFirstChildWhichIsA("Humanoid"); if not hum or hum.Health<=0 then return end
            if not ANIMAL_SET[obj.Name:lower()] then return end
            local anHrp = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
            if not anHrp then return end
            local d = (anHrp.Position - myPos).Magnitude
            if d < bestDist then bestDist=d; best=anHrp end
        end)
    end
    return best
end

local aimbotEnabled = false
local aimbotAutoEnabled = false
local aimbotAutoRunning = false

workspace.DescendantAdded:Connect(function(obj)
    if not aimbotEnabled then return end
    task.defer(function()
        if not obj or not obj.Parent or not obj:IsA("BasePart") then return end
        local speed = obj.AssemblyLinearVelocity.Magnitude
        if speed < 10 then return end
        local par = obj.Parent
        for _ = 1, 3 do
            if par and par:IsA("Model") and par:FindFirstChildWhichIsA("Humanoid") then
                local isPlayer = false
                for _, pl in ipairs(Players:GetPlayers()) do if pl.Character==par then isPlayer=true; break end end
                if not isPlayer then return end
            end
            par = par and par.Parent
        end
        local anHrp = findNearestAnimalHrp()
        if not anHrp then return end
        local steps = 0
        local conn; conn = RunService.Heartbeat:Connect(function()
            steps+=1
            if not aimbotEnabled or not obj or not obj.Parent or steps>120 then conn:Disconnect(); return end
            if not anHrp or not anHrp.Parent then conn:Disconnect(); return end
            local dir = (anHrp.Position - obj.Position)
            if dir.Magnitude < 3 then conn:Disconnect(); return end
            obj.AssemblyLinearVelocity = dir.Unit * math.max(speed, 80)
        end)
    end)
end)

local function startAimbotAuto()
    if aimbotAutoRunning then return end; aimbotAutoRunning = true
    task.spawn(function()
        while aimbotAutoEnabled do
            task.wait(0.15)
            pcall(function()
                local anHrp = findNearestAnimalHrp()
                if not anHrp then return end
                local ch = Player.Character; if not ch then return end
                local myHrp = ch:FindFirstChild("HumanoidRootPart"); if not myHrp then return end
                local dir = (anHrp.Position - myHrp.Position).Unit
                myHrp.CFrame = CFrame.new(myHrp.Position) * CFrame.Angles(0, math.atan2(dir.X, dir.Z) + math.pi, 0)
                pcall(function()
                    local sp = Cam:WorldToScreenPoint(anHrp.Position)
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendMouseButtonEvent(sp.X, sp.Y, 0, true, game, 0)
                    task.wait(0.05)
                    vim:SendMouseButtonEvent(sp.X, sp.Y, 0, false, game, 0)
                end)
            end)
        end
        aimbotAutoRunning = false
    end)
end

-- ══════════════════════════════════════════════════════
--  ABA AVANÇADO FUNÇÕES
-- ══════════════════════════════════════════════════════
local avLO2 = 0
local function avNextLO() avLO2+=1; return avLO2 end

local function makeAvSec(titulo, cor)
    local hdr=Instance.new("Frame",Pages["AvancadoFuncoes"]); hdr.BackgroundColor3=Color3.fromRGB(20,22,30)
    hdr.BackgroundTransparency=0.3; hdr.BorderSizePixel=0; hdr.Size=UDim2.new(1,0,0,22); hdr.LayoutOrder=avNextLO(); hdr.ZIndex=4
    Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",hdr); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=5; Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",hdr); lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,10,0,0)
    lbl.Size=UDim2.new(1,-14,1,0); lbl.Font=Enum.Font.GothamBlack; lbl.Text=titulo
    lbl.TextColor3=cor; lbl.TextSize=9; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=5
end

local function makeAvToggle(lbl_txt, desc_txt, cor, onToggle)
    local row=Instance.new("Frame",Pages["AvancadoFuncoes"]); row.BackgroundColor3=Color3.fromRGB(28,30,38)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,60); row.LayoutOrder=avNextLO(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local rowS=Instance.new("UIStroke",row); rowS.Color=Color3.fromRGB(42,46,58); rowS.Thickness=1
    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,14,0,8); tl.Size=UDim2.new(1,-80,0,18); tl.Font=Enum.Font.GothamBold
    tl.Text=lbl_txt; tl.TextColor3=Color3.fromRGB(220,225,240); tl.TextSize=12; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
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
    local estado=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=11
    btn.MouseButton1Click:Connect(function()
        estado=not estado
        TweenService:Create(pill,TweenInfo.new(0.22,Enum.EasingStyle.Quad),{BackgroundColor3=estado and cor or Color3.fromRGB(45,50,62)}):Play()
        TweenService:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=estado and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
            BackgroundColor3=estado and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
        }):Play()
        TweenService:Create(rowS,TweenInfo.new(0.2),{Color=estado and cor or Color3.fromRGB(42,46,58)}):Play()
        onToggle(estado)
    end)
end

-- ══════════════════════════════════════════════════════
--  TP BIOMES — sistema completo
-- ══════════════════════════════════════════════════════
local BIOMES_99N = {
    { name="🌲 Floresta",    keywords={"spawn","spawnpoint","forestground","foresttree","greentree","treestump","forestbiome"} },
    { name="🏜️ Deserto",     keywords={"desert","desertground","cactus","sanddune","desertrock","desertbiome","sandbiome"} },
    { name="❄️ Tundra",      keywords={"tundra","arctic","tundraground","icesheet","snowfield","tundrabiome","icebiome","arcticbiome","snowbiome"} },
    { name="🌋 Vulcão",      keywords={"volcano","lavapool","lavarock","volcanoground","lavabiome","volcanozone","volcanobiome","lavafloor"} },
    { name="🌿 Pântano",     keywords={"swamp","swampground","swamptree","bog","swampbiome","marshbiome"} },
    { name="⛏️ Caverna",     keywords={"cave","underground","caveentrance","cavern","cavebiome","cavetunnel","caveground","cavewall"} },
    { name="👽 Área Alien",  keywords={"alien","ufo","crashsite","alienbase","ufowreck","alienbiome","alienzone","alienground"} },
    { name="🎃 Halloween",   keywords={"halloween","halloweenbiome","pumpkin","hauntedhouse","graveyard","cauldron","halloween"} },
    { name="🌊 Praia",       keywords={"beach","shore","coastalrock","beachsand","coastalbiome","shorebiome"} },
    { name="⛰️ Montanha",    keywords={"mountain","mountainpeak","mountainbiome","highground","peak","cliffbiome"} },
}

local function findBiomePos(biome)
    local best = nil
    for _, obj in ipairs(workspace:GetDescendants()) do
        if best then break end
        pcall(function()
            if not (obj:IsA("BasePart") or obj:IsA("Model")) then return end
            local nm = obj.Name:lower()
            for _, kw in ipairs(biome.keywords) do
                if nm:find(kw, 1, true) then
                    local pos
                    if obj:IsA("BasePart") then
                        pos = obj.Position
                    elseif obj:IsA("Model") then
                        local bp = obj:FindFirstChildWhichIsA("BasePart")
                        if bp then pos = bp.Position end
                    end
                    if pos and pos.Y > -300 and pos.Magnitude < 15000 then
                        best = pos
                    end
                    return
                end
            end
        end)
    end
    return best
end

-- UI do painel Tp Biomes
local function makeTpBiomesPanel()
    local BIOME_COR     = Color3.fromRGB(100,200,255)
    local BIOME_COR_SEL = Color3.fromRGB(87,242,135)
    local BASE_H  = 56
    local DROP_H  = #BIOMES_99N * 36 + 16
    local SEL_H   = 50
    local ERR_H   = 40

    local panel = Instance.new("Frame", Pages["AvancadoFuncoes"])
    panel.BackgroundColor3 = Color3.fromRGB(20,22,32); panel.BorderSizePixel=0
    panel.Size = UDim2.new(1,0,0,BASE_H); panel.LayoutOrder=avNextLO(); panel.ZIndex=5; panel.ClipsDescendants=true
    Instance.new("UICorner",panel).CornerRadius=UDim.new(0,10)
    local panStroke=Instance.new("UIStroke",panel); panStroke.Color=Color3.fromRGB(60,80,130); panStroke.Thickness=1.3

    -- Header row
    local hdrRow=Instance.new("Frame",panel); hdrRow.BackgroundTransparency=1; hdrRow.BorderSizePixel=0
    hdrRow.Position=UDim2.new(0,0,0,0); hdrRow.Size=UDim2.new(1,0,0,BASE_H); hdrRow.ZIndex=6

    local hdrIcon=Instance.new("TextLabel",hdrRow); hdrIcon.BackgroundTransparency=1
    hdrIcon.Position=UDim2.new(0,12,0,0); hdrIcon.Size=UDim2.new(0,26,1,0)
    hdrIcon.Font=Enum.Font.GothamBold; hdrIcon.Text="🗺️"; hdrIcon.TextSize=18; hdrIcon.ZIndex=7

    local hdrTitle=Instance.new("TextLabel",hdrRow); hdrTitle.BackgroundTransparency=1
    hdrTitle.Position=UDim2.new(0,42,0,0); hdrTitle.Size=UDim2.new(0.55,0,1,0); hdrTitle.Font=Enum.Font.GothamBold
    hdrTitle.Text="Tp Biomes"; hdrTitle.TextColor3=BIOME_COR; hdrTitle.TextSize=13
    hdrTitle.TextXAlignment=Enum.TextXAlignment.Left; hdrTitle.ZIndex=7

    local selBtn=Instance.new("TextButton",hdrRow)
    selBtn.BackgroundColor3=BIOME_COR; selBtn.BackgroundTransparency=0.22; selBtn.BorderSizePixel=0
    selBtn.Position=UDim2.new(1,-114,0.5,-15); selBtn.Size=UDim2.new(0,104,0,30)
    selBtn.Font=Enum.Font.GothamBold; selBtn.Text="▼ Selecione"; selBtn.TextColor3=Color3.fromRGB(255,255,255)
    selBtn.TextSize=10; selBtn.ZIndex=8
    Instance.new("UICorner",selBtn).CornerRadius=UDim.new(0,8)

    -- Dropdown frame (aparece abaixo do header)
    local dropdown=Instance.new("ScrollingFrame",panel)
    dropdown.BackgroundColor3=Color3.fromRGB(16,18,26); dropdown.BorderSizePixel=0
    dropdown.Position=UDim2.new(0,0,0,BASE_H); dropdown.Size=UDim2.new(1,0,0,0) -- começa fechado
    dropdown.ZIndex=7; dropdown.ClipsDescendants=true; dropdown.ScrollBarThickness=3
    dropdown.ScrollBarImageColor3=BIOME_COR; dropdown.CanvasSize=UDim2.new(0,0,0,0)
    dropdown.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local dropList=Instance.new("UIListLayout",dropdown); dropList.Padding=UDim.new(0,4); dropList.SortOrder=Enum.SortOrder.LayoutOrder
    local dropPad=Instance.new("UIPadding",dropdown)
    dropPad.PaddingTop=UDim.new(0,8); dropPad.PaddingLeft=UDim.new(0,10)
    dropPad.PaddingRight=UDim.new(0,10); dropPad.PaddingBottom=UDim.new(0,8)

    -- Linha de biome selecionado (abaixo do dropdown quando fechado)
    local selRow=Instance.new("Frame",panel); selRow.BackgroundColor3=Color3.fromRGB(18,22,30)
    selRow.BackgroundTransparency=0.4; selRow.BorderSizePixel=0
    selRow.Position=UDim2.new(0,0,0,BASE_H); selRow.Size=UDim2.new(1,0,0,SEL_H)
    selRow.Visible=false; selRow.ZIndex=6
    Instance.new("UICorner",selRow).CornerRadius=UDim.new(0,8)

    local selNameLbl=Instance.new("TextLabel",selRow); selNameLbl.BackgroundTransparency=1
    selNameLbl.Position=UDim2.new(0,14,0,0); selNameLbl.Size=UDim2.new(1,-128,1,0); selNameLbl.Font=Enum.Font.GothamBold
    selNameLbl.Text=""; selNameLbl.TextColor3=BIOME_COR_SEL; selNameLbl.TextSize=12
    selNameLbl.TextXAlignment=Enum.TextXAlignment.Left; selNameLbl.ZIndex=7

    local tpBtn=Instance.new("TextButton",selRow)
    tpBtn.BackgroundColor3=BIOME_COR_SEL; tpBtn.BackgroundTransparency=0.18; tpBtn.BorderSizePixel=0
    tpBtn.Position=UDim2.new(1,-114,0.5,-15); tpBtn.Size=UDim2.new(0,104,0,30)
    tpBtn.Font=Enum.Font.GothamBold; tpBtn.Text="▼  Tp"; tpBtn.TextColor3=Color3.fromRGB(255,255,255)
    tpBtn.TextSize=11; tpBtn.ZIndex=8
    Instance.new("UICorner",tpBtn).CornerRadius=UDim.new(0,8)

    -- Aviso de biome não encontrado
    local errRow=Instance.new("Frame",panel); errRow.BackgroundColor3=Color3.fromRGB(60,20,20)
    errRow.BackgroundTransparency=0.35; errRow.BorderSizePixel=0
    errRow.Position=UDim2.new(0,0,0,BASE_H+SEL_H); errRow.Size=UDim2.new(1,0,0,ERR_H)
    errRow.Visible=false; errRow.ZIndex=6
    Instance.new("UICorner",errRow).CornerRadius=UDim.new(0,8)
    local errLbl=Instance.new("TextLabel",errRow); errLbl.BackgroundTransparency=1
    errLbl.Position=UDim2.new(0,10,0,0); errLbl.Size=UDim2.new(1,-14,1,0); errLbl.Font=Enum.Font.GothamSemibold
    errLbl.Text="⚠️  Biome não localizado, Por favor explore o mapa novamente!"
    errLbl.TextColor3=Color3.fromRGB(255,120,120); errLbl.TextSize=9; errLbl.TextWrapped=true
    errLbl.TextXAlignment=Enum.TextXAlignment.Left; errLbl.ZIndex=7

    -- Estado do painel
    local dropOpen     = false
    local selectedBiome = nil

    local function calcHeight()
        local h = BASE_H
        if dropOpen  then h = h + DROP_H end
        if selRow.Visible and not dropOpen then h = h + SEL_H end
        if errRow.Visible and not dropOpen then h = h + ERR_H end
        return h
    end

    local function refreshPanel(animated)
        local h = calcHeight()
        -- posicionar selRow abaixo do dropdown
        selRow.Position = UDim2.new(0,0,0, dropOpen and BASE_H + DROP_H or BASE_H)
        errRow.Position = UDim2.new(0,0,0, (dropOpen and BASE_H + DROP_H or BASE_H) + (selRow.Visible and SEL_H or 0))
        if animated then
            TweenService:Create(panel,TweenInfo.new(0.28,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,h)}):Play()
        else
            panel.Size=UDim2.new(1,0,0,h)
        end
    end

    local function openDrop()
        dropOpen=true; selBtn.Text="▲ Fechar"
        TweenService:Create(panStroke,TweenInfo.new(0.2),{Color=BIOME_COR}):Play()
        TweenService:Create(dropdown,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,DROP_H)}):Play()
        refreshPanel(true)
    end

    local function closeDrop()
        dropOpen=false; selBtn.Text="▼ Selecione"
        TweenService:Create(panStroke,TweenInfo.new(0.2),{Color=Color3.fromRGB(60,80,130)}):Play()
        TweenService:Create(dropdown,TweenInfo.new(0.2,Enum.EasingStyle.Quad),{Size=UDim2.new(1,0,0,0)}):Play()
        task.delay(0.22,function() refreshPanel(true) end)
    end

    selBtn.MouseButton1Click:Connect(function() if dropOpen then closeDrop() else openDrop() end end)

    -- Criar botões dos biomes no dropdown
    for idx, biome in ipairs(BIOMES_99N) do
        local bBtn=Instance.new("TextButton",dropdown); bBtn.BackgroundColor3=Color3.fromRGB(26,30,44)
        bBtn.BackgroundTransparency=0.25; bBtn.BorderSizePixel=0; bBtn.Size=UDim2.new(1,0,0,32)
        bBtn.Font=Enum.Font.GothamSemibold; bBtn.Text="  "..biome.name; bBtn.TextColor3=Color3.fromRGB(200,215,240)
        bBtn.TextSize=11; bBtn.TextXAlignment=Enum.TextXAlignment.Left; bBtn.ZIndex=9; bBtn.LayoutOrder=idx
        Instance.new("UICorner",bBtn).CornerRadius=UDim.new(0,7)

        bBtn.MouseEnter:Connect(function()
            TweenService:Create(bBtn,TweenInfo.new(0.1),{BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(40,50,80)}):Play()
        end)
        bBtn.MouseLeave:Connect(function()
            TweenService:Create(bBtn,TweenInfo.new(0.1),{BackgroundTransparency=0.25,BackgroundColor3=Color3.fromRGB(26,30,44)}):Play()
        end)
        bBtn.MouseButton1Click:Connect(function()
            selectedBiome = biome
            selNameLbl.Text = biome.name.."  selecionado"
            errRow.Visible = false
            selRow.Visible = true
            tpBtn.Text = "▼  Tp"
            tpBtn.BackgroundTransparency = 0.18
            closeDrop()
        end)
    end

    -- Tp button
    tpBtn.MouseButton1Click:Connect(function()
        if not selectedBiome then return end
        errRow.Visible = false
        tpBtn.Text = "⏳ Buscando..."; tpBtn.BackgroundTransparency=0.5
        task.spawn(function()
            local pos = findBiomePos(selectedBiome)
            if pos then
                local ok = pcall(function()
                    local ch = Player.Character; if not ch then error("sem personagem") end
                    local hrp = ch:FindFirstChild("HumanoidRootPart"); if not hrp then error("sem hrp") end
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0,6,0))
                end)
                if ok then
                    tpBtn.Text = "✓ Teleportado!"; tpBtn.BackgroundTransparency=0.15
                    task.delay(2.5, function() tpBtn.Text="▼  Tp"; tpBtn.BackgroundTransparency=0.18 end)
                else
                    tpBtn.Text = "▼  Tp"; tpBtn.BackgroundTransparency=0.18
                    errRow.Visible=true; refreshPanel(true)
                end
            else
                -- Biome não encontrado
                tpBtn.Text = "▼  Tp"; tpBtn.BackgroundTransparency=0.18
                errRow.Visible = true
                refreshPanel(true)
                task.delay(5, function()
                    TweenService:Create(errRow,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play()
                    task.wait(0.5); errRow.Visible=false; errRow.BackgroundTransparency=0.35; refreshPanel(true)
                end)
            end
        end)
    end)
end

-- Montar aba Avançado Funções
makeAvSec("🎯 COMBATE AUTOMÁTICO", Color3.fromRGB(255,80,80))
makeAvToggle("🎯 Aimbot (Teleguiado)", "Projéteis se movem automaticamente para o animal mais próximo.", Color3.fromRGB(255,80,80), function(s) aimbotEnabled = s end)
makeAvToggle("🤖 Aimbot AUTO", "Com arma ranged equipada: atira sozinho nos animais próximos.", Color3.fromRGB(255,140,40), function(s) aimbotAutoEnabled = s; if s then startAimbotAuto() end end)

makeAvSec("🗺️ TELEPORTE", Color3.fromRGB(100,200,255))
makeTpBiomesPanel()

-- ══════════════════════════════════════════════════════
--  ABA INICIAL
-- ══════════════════════════════════════════════════════
task.wait(0.05)
selectTab("Info")

print("╔══════════════════════════════════════════════════════╗")
print("║  PUDIM HUB v5 — COMPLETO  Fev 2026                  ║")
print("║  + Tp Biomes | SliderBars | Player LayoutOrder fix   ║")
print("╚══════════════════════════════════════════════════════╝")
