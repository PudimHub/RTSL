-- ╔══════════════════════════════════════════════════════════════╗
-- ║   PUDIM HUB v4.1 — SCRIPT COMPLETO E INTEGRADO              ║
-- ║  Player: Speed/Jump Sliders | Fly | Noclip | TpClick | BauANC
-- ║  Novidades: InfZoom | CamLivre | FullBright | InfJump       ║
-- ║             SlopeBoost | GodMode                             ║
-- ║  Aimbot Teleguiado | Aimbot AUTO                             ║
-- ║  ESP 20 cats | Bring 17 cats                                 ║
-- ║  Aba TP — 15 biomas com detecção dinâmica                   ║
-- ╚══════════════════════════════════════════════════════════════╝

local TS   = game:GetService("TweenService")
local UIS  = game:GetService("UserInputService")
local RS   = game:GetService("RunService")
local Plrs = game:GetService("Players")
local Lite = game:GetService("Lighting")

local Plr  = Plrs.LocalPlayer
local Cam  = workspace.CurrentCamera

-- ── GUI raiz ──────────────────────────────────────────────────
local SGui = Instance.new("ScreenGui")
SGui.Name           = "PudimHubV41"
SGui.Parent         = game.CoreGui
SGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SGui.ResetOnSpawn   = false
SGui.DisplayOrder   = 999

-- ── Cores globais ─────────────────────────────────────────────
local CA   = Color3.fromRGB(88,101,242)   -- accent roxo
local CB1  = Color3.fromRGB(32,34,37)
local CB2  = Color3.fromRGB(24,25,28)
local CB3  = Color3.fromRGB(36,38,42)
local CT1  = Color3.fromRGB(240,242,255)
local CT2  = Color3.fromRGB(130,140,158)

-- ── Frame principal ───────────────────────────────────────────
local MF = Instance.new("Frame")
MF.Name             = "Main"
MF.Parent           = SGui
MF.BackgroundColor3 = CB1
MF.Position         = UDim2.new(0.5,-270,0.5,-185)
MF.Size             = UDim2.new(0,540,0,370)
MF.BorderSizePixel  = 0
MF.Active           = true
MF.Draggable        = true
MF.ZIndex           = 2
MF.ClipsDescendants = true
Instance.new("UICorner",MF).CornerRadius = UDim.new(0,12)
local MFS = Instance.new("UIStroke",MF)
MFS.Color=Color3.fromRGB(55,58,66); MFS.Thickness=1.5

-- ── Top bar ───────────────────────────────────────────────────
local TB = Instance.new("Frame",MF)
TB.BackgroundColor3=CB2; TB.Size=UDim2.new(1,0,0,40); TB.BorderSizePixel=0; TB.ZIndex=3
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,12)
local tbfix=Instance.new("Frame",TB); tbfix.BackgroundColor3=CB2; tbfix.BorderSizePixel=0
tbfix.Position=UDim2.new(0,0,0.5,0); tbfix.Size=UDim2.new(1,0,0.5,0); tbfix.ZIndex=3

local TitleL = Instance.new("TextLabel",TB)
TitleL.BackgroundTransparency=1; TitleL.Position=UDim2.new(0,38,0,0); TitleL.Size=UDim2.new(0,200,1,0)
TitleL.Font=Enum.Font.GothamBlack; TitleL.Text="PudimHub v4.1"; TitleL.TextColor3=CA
TitleL.TextSize=15; TitleL.TextXAlignment=Enum.TextXAlignment.Left; TitleL.ZIndex=5

-- Ícone
local TIcon=Instance.new("ImageLabel",TB); TIcon.BackgroundTransparency=1
TIcon.Position=UDim2.new(0,12,0.5,-10); TIcon.Size=UDim2.new(0,20,0,20)
TIcon.Image="rbxassetid://12766380903"; TIcon.ZIndex=5

-- Botões topo
local TopBtns={}
local topBD={{"Theme","rbxassetid://7734053495"},{"Minimize","rbxassetid://7733956134"},
             {"Maximize","rbxassetid://7733919682"},{"Close","rbxassetid://7734053426"}}
local bx=-10
for _,d in ipairs(topBD) do
    local b=Instance.new("ImageButton",TB); b.Name=d[1]; b.BackgroundTransparency=1
    b.Position=UDim2.new(1,bx-20,0.5,-9); b.Size=UDim2.new(0,18,0,18); b.Image=d[2]
    b.ImageColor3=Color3.fromRGB(160,165,175); b.ZIndex=5
    b.MouseEnter:Connect(function() TS:Create(b,TweenInfo.new(0.15),{ImageColor3=Color3.fromRGB(255,255,255)}):Play() end)
    b.MouseLeave:Connect(function() TS:Create(b,TweenInfo.new(0.15),{ImageColor3=Color3.fromRGB(160,165,175)}):Play() end)
    TopBtns[d[1]]=b; bx=bx-30
end

-- ── Sidebar ───────────────────────────────────────────────────
local SB=Instance.new("ScrollingFrame",MF)
SB.BackgroundColor3=CB2; SB.Position=UDim2.new(0,0,0,40); SB.Size=UDim2.new(0,175,1,-78)
SB.BorderSizePixel=0; SB.ScrollBarThickness=0; SB.AutomaticCanvasSize=Enum.AutomaticSize.Y
SB.CanvasSize=UDim2.new(0,0,0,0); SB.ZIndex=3
local SBList=Instance.new("UIListLayout",SB)
SBList.Padding=UDim.new(0,2); SBList.SortOrder=Enum.SortOrder.LayoutOrder
SBList.HorizontalAlignment=Enum.HorizontalAlignment.Center
local SBPad=Instance.new("UIPadding",SB)
SBPad.PaddingTop=UDim.new(0,8); SBPad.PaddingLeft=UDim.new(0,8)
SBPad.PaddingRight=UDim.new(0,8); SBPad.PaddingBottom=UDim.new(0,8)

local Div=Instance.new("Frame",MF)
Div.BackgroundColor3=Color3.fromRGB(14,15,17); Div.BorderSizePixel=0
Div.Position=UDim2.new(0,175,0,40); Div.Size=UDim2.new(0,1,1,-40); Div.ZIndex=3

-- ── Content area ──────────────────────────────────────────────
local CA2=Instance.new("Frame",MF)
CA2.BackgroundColor3=CB3; CA2.Position=UDim2.new(0,176,0,40); CA2.Size=UDim2.new(1,-176,1,-40)
CA2.BorderSizePixel=0; CA2.ZIndex=3; CA2.ClipsDescendants=true

-- ── Footer ────────────────────────────────────────────────────
local Foot=Instance.new("Frame",MF)
Foot.BackgroundColor3=Color3.fromRGB(18,19,22); Foot.BorderSizePixel=0
Foot.Position=UDim2.new(0,0,1,-38); Foot.Size=UDim2.new(0,175,0,38); Foot.ZIndex=4
Instance.new("UICorner",Foot).CornerRadius=UDim.new(0,12)

local AvBg=Instance.new("Frame",Foot); AvBg.BackgroundColor3=CA
AvBg.Position=UDim2.new(0,8,0.5,-12); AvBg.Size=UDim2.new(0,24,0,24); AvBg.ZIndex=5
Instance.new("UICorner",AvBg).CornerRadius=UDim.new(1,0)
local AvImg=Instance.new("ImageLabel",AvBg); AvImg.BackgroundTransparency=1
AvImg.Size=UDim2.new(1,0,1,0); AvImg.ZIndex=6
AvImg.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..Plr.UserId.."&width=48&height=48&format=png"
Instance.new("UICorner",AvImg).CornerRadius=UDim.new(1,0)

local GrDot=Instance.new("Frame",Foot); GrDot.BackgroundColor3=Color3.fromRGB(87,242,135)
GrDot.BorderSizePixel=0; GrDot.Position=UDim2.new(0,24,0.5,3); GrDot.Size=UDim2.new(0,8,0,8); GrDot.ZIndex=6
Instance.new("UICorner",GrDot).CornerRadius=UDim.new(1,0)

local FN=Instance.new("TextLabel",Foot); FN.BackgroundTransparency=1
FN.Position=UDim2.new(0,40,0,4); FN.Size=UDim2.new(1,-48,0,14); FN.Font=Enum.Font.GothamBold
FN.Text=Plr.DisplayName; FN.TextColor3=Color3.fromRGB(225,228,232); FN.TextSize=10
FN.TextXAlignment=Enum.TextXAlignment.Left; FN.TextTruncate=Enum.TextTruncate.AtEnd; FN.ZIndex=5
local FT=Instance.new("TextLabel",Foot); FT.BackgroundTransparency=1
FT.Position=UDim2.new(0,40,0,19); FT.Size=UDim2.new(1,-48,0,12); FT.Font=Enum.Font.Gotham
FT.Text="@"..Plr.Name; FT.TextColor3=Color3.fromRGB(80,90,110); FT.TextSize=9
FT.TextXAlignment=Enum.TextXAlignment.Left; FT.TextTruncate=Enum.TextTruncate.AtEnd; FT.ZIndex=5


-- ══════════════════════════════════════════════════════
--  PÁGINAS
-- ══════════════════════════════════════════════════════
local Pages={}
local TabCfg={
    {k="Info",lb="Info"},{k="Status",lb="Status"},{k="Farm",lb="Farm"},
    {k="Esp",lb="ESP"},{k="Bring",lb="Bring"},{k="AvFarm",lb="Avançado Farm"},
    {k="Player",lb="Player"},{k="Config",lb="Configurações"},
    {k="AvFunc",lb="Avançado Funções"},{k="Tp",lb="Tp"},
}
local GrpCfg={
    {lb="GERAL",  ks={"Info","Status"}},
    {lb="COMBATE",ks={"Farm","Esp","Bring","AvFarm"}},
    {lb="EXTRA",  ks={"Player","Config","AvFunc","Tp"}},
}
for _,t in ipairs(TabCfg) do
    local pg=Instance.new("ScrollingFrame",CA2); pg.Name=t.k.."Pg"
    pg.Size=UDim2.new(1,0,1,0); pg.BackgroundTransparency=1; pg.Visible=false
    pg.ScrollBarThickness=3; pg.ScrollBarImageColor3=CA; pg.BorderSizePixel=0
    pg.AutomaticCanvasSize=Enum.AutomaticSize.Y; pg.CanvasSize=UDim2.new(0,0,0,0); pg.ZIndex=4
    local pp=Instance.new("UIPadding",pg)
    pp.PaddingTop=UDim.new(0,14); pp.PaddingLeft=UDim.new(0,14)
    pp.PaddingRight=UDim.new(0,14); pp.PaddingBottom=UDim.new(0,14)
    local pl=Instance.new("UIListLayout",pg); pl.Padding=UDim.new(0,8); pl.SortOrder=Enum.SortOrder.LayoutOrder
    Pages[t.k]=pg
end

-- ── Sistema de abas ───────────────────────────────────────────
local allTabs={}; local curTab=nil
local CI = Color3.fromRGB(90,100,120)  -- icon idle
local CA3= Color3.fromRGB(180,190,255) -- icon active

local function rect(p,x,y,w,h,cor,r)
    local f=Instance.new("Frame",p); f.BackgroundColor3=cor or CI; f.BorderSizePixel=0
    f.Position=UDim2.new(0,x,0,y); f.Size=UDim2.new(0,w,0,h); f.ZIndex=p.ZIndex+1
    if r then Instance.new("UICorner",f).CornerRadius=UDim.new(0,r) end; return f
end
local function circ(p,cx,cy,r,cor) return rect(p,cx-r,cy-r,r*2,r*2,cor,r*2) end

local function mkIcon(par,key)
    local cont=Instance.new("Frame",par); cont.BackgroundTransparency=1; cont.BorderSizePixel=0
    cont.Position=UDim2.new(0,8,0.5,-10); cont.Size=UDim2.new(0,20,0,20); cont.ZIndex=par.ZIndex+2
    local pts={}
    local function p(f) table.insert(pts,f) end
    local dk=Color3.fromRGB(24,26,32)
    if key=="Info" then
        p(circ(cont,10,10,9,CI)); local i=circ(cont,10,10,7,dk); i.ZIndex=cont.ZIndex+1
        p(circ(cont,10,4,2,CI)); p(rect(cont,8,8,4,8,CI,2))
    elseif key=="Status" then
        p(rect(cont,0,12,4,8,CI,1)); p(rect(cont,8,6,4,14,CI,1)); p(rect(cont,16,9,4,11,CI,1))
    elseif key=="Farm" then
        p(rect(cont,11,0,5,2,CI,1)); p(rect(cont,6,2,8,2,CI)); p(rect(cont,4,4,10,2,CI))
        p(rect(cont,8,6,8,2,CI)); p(rect(cont,6,8,8,2,CI)); p(rect(cont,4,10,8,2,CI))
        p(rect(cont,2,12,10,2,CI)); p(rect(cont,4,14,6,2,CI)); p(rect(cont,3,18,5,2,CI,1))
    elseif key=="Esp" then
        p(rect(cont,2,6,16,8,CI,8))
        local ei=rect(cont,3,7,14,6,dk,7); ei.ZIndex=cont.ZIndex+1
        p(circ(cont,10,10,4,CI)); local pi=circ(cont,10,10,2,dk); pi.ZIndex=cont.ZIndex+3
        p(circ(cont,12,8,1,Color3.fromRGB(200,220,255)))
    elseif key=="Bring" then
        p(rect(cont,2,2,5,12,CI,2)); p(rect(cont,13,2,5,12,CI,2)); p(rect(cont,2,2,16,5,CI,2))
        p(rect(cont,2,14,5,4,Color3.fromRGB(220,60,60),2)); p(rect(cont,13,14,5,4,Color3.fromRGB(60,120,220),2))
    elseif key=="AvFarm" then
        p(rect(cont,9,14,2,6,CI,1)); p(rect(cont,9,2,2,12,CI,1))
        p(rect(cont,3,4,6,3,CI,2)); p(rect(cont,11,4,6,3,CI,2))
        p(rect(cont,3,8,6,3,CI,2)); p(rect(cont,11,8,6,3,CI,2)); p(rect(cont,6,0,8,3,CI,2))
    elseif key=="Player" then
        p(circ(cont,10,5,4,CI)); p(rect(cont,5,11,10,7,CI,3))
        p(rect(cont,3,13,4,7,CI,2)); p(rect(cont,13,13,4,7,CI,2))
    elseif key=="Config" then
        p(circ(cont,10,10,5,CI)); local ci=circ(cont,10,10,3,dk); ci.ZIndex=cont.ZIndex+2
        for _,deg in ipairs({0,45,90,135,180,225,270,315}) do
            local rad=math.rad(deg); p(rect(cont,10+math.cos(rad)*8-2,10+math.sin(rad)*8-2,4,4,CI,1))
        end
    elseif key=="AvFunc" then
        p(rect(cont,1,13,12,4,CI,2)); p(circ(cont,15,6,5,CI))
        local furo=circ(cont,15,6,3,dk); furo.ZIndex=cont.ZIndex+2
        p(rect(cont,8,9,6,3,CI,1))
    elseif key=="Tp" then
        p(circ(cont,14,4,3,CI)); p(rect(cont,11,8,6,6,CI,2))
        p(rect(cont,10,14,3,5,CI,1)); p(rect(cont,14,14,3,5,CI,1))
        p(circ(cont,5,12,5,CI)); local pi2=circ(cont,5,12,3,dk); pi2.ZIndex=cont.ZIndex+2
        p(rect(cont,8,11,5,2,CI,1)); p(rect(cont,11,8,2,4,CI,1)); p(rect(cont,11,13,2,4,CI,1))
    end
    return cont,pts
end

local function setIconClr(pts,cor)
    for _,p in ipairs(pts) do if p and p.Parent then p.BackgroundColor3=cor end end
end

local function selTab(key)
    if curTab==key then return end; curTab=key
    for _,e in ipairs(allTabs) do
        local is=(e.k==key)
        TS:Create(e.bg,TweenInfo.new(0.18),{
            BackgroundTransparency=is and 0.72 or 1,
            BackgroundColor3=is and Color3.fromRGB(48,52,72) or Color3.fromRGB(40,43,52),
        }):Play()
        setIconClr(e.pts,is and CA3 or CI)
        TS:Create(e.lbl,TweenInfo.new(0.18),{TextColor3=is and CT1 or CT2}):Play()
        e.bar.Visible=is
        if Pages[e.k] then Pages[e.k].Visible=is end
    end
end

local lo=0
local function grpHdr(txt,grpTabs)
    lo+=1
    if lo>1 then
        local line=Instance.new("Frame",SB); line.BackgroundColor3=Color3.fromRGB(38,41,48)
        line.BorderSizePixel=0; line.Size=UDim2.new(1,0,0,1); line.LayoutOrder=lo*100
    end
    lo+=1
    local hdr=Instance.new("TextButton",SB); hdr.BackgroundTransparency=1
    hdr.Size=UDim2.new(1,0,0,24); hdr.Text=""; hdr.LayoutOrder=lo*100; hdr.ZIndex=4
    local hl=Instance.new("TextLabel",hdr); hl.BackgroundTransparency=1
    hl.Position=UDim2.new(0,4,0,0); hl.Size=UDim2.new(1,-24,1,0); hl.Font=Enum.Font.GothamBlack
    hl.Text=txt; hl.TextColor3=CA; hl.TextSize=8; hl.TextXAlignment=Enum.TextXAlignment.Left; hl.ZIndex=5
    local af=Instance.new("Frame",hdr); af.BackgroundTransparency=1
    af.Position=UDim2.new(1,-20,0.5,-8); af.Size=UDim2.new(0,16,0,16); af.ZIndex=5
    local arr=Instance.new("ImageLabel",af); arr.BackgroundTransparency=1; arr.Size=UDim2.new(1,0,1,0)
    arr.Image="rbxassetid://6034818375"; arr.ImageColor3=CA; arr.ScaleType=Enum.ScaleType.Fit; arr.Rotation=0; arr.ZIndex=6
    local open=true
    hdr.MouseButton1Click:Connect(function()
        open=not open
        TS:Create(arr,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Rotation=open and 0 or 180}):Play()
        for _,e in ipairs(grpTabs) do
            TS:Create(e.bg,TweenInfo.new(0.25),{Size=open and UDim2.new(1,0,0,36) or UDim2.new(1,0,0,0)}):Play()
            e.bg.ClipsDescendants=true
        end
    end)
end

local function mkTab(cfg,grpTabs)
    lo+=1; local ord=lo*100
    local bg=Instance.new("Frame",SB); bg.Name=cfg.k.."Tab"
    bg.BackgroundColor3=Color3.fromRGB(40,43,52); bg.BackgroundTransparency=1; bg.BorderSizePixel=0
    bg.Size=UDim2.new(1,0,0,36); bg.LayoutOrder=ord; bg.ZIndex=4; bg.ClipsDescendants=true
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,7)
    local bar=Instance.new("Frame",bg); bar.BackgroundColor3=CA; bar.BorderSizePixel=0
    bar.Position=UDim2.new(0,0,0.2,0); bar.Size=UDim2.new(0,3,0.6,0); bar.Visible=false; bar.ZIndex=6
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,2)
    local icon,pts=mkIcon(bg,cfg.k)
    local lbl=Instance.new("TextLabel",bg); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,37,0,0); lbl.Size=UDim2.new(1,-42,1,0); lbl.Font=Enum.Font.GothamSemibold
    lbl.Text=cfg.lb; lbl.TextColor3=CT2; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.TextTruncate=Enum.TextTruncate.AtEnd; lbl.ZIndex=6
    local btn=Instance.new("TextButton",bg); btn.BackgroundTransparency=1
    btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=7
    btn.MouseEnter:Connect(function() if curTab~=cfg.k then TS:Create(bg,TweenInfo.new(0.15),{BackgroundTransparency=0.78}):Play() end end)
    btn.MouseLeave:Connect(function() if curTab~=cfg.k then TS:Create(bg,TweenInfo.new(0.15),{BackgroundTransparency=1}):Play() end end)
    btn.MouseButton1Click:Connect(function() selTab(cfg.k) end)
    local e={k=cfg.k,bg=bg,icon=icon,pts=pts,lbl=lbl,bar=bar}
    table.insert(allTabs,e); table.insert(grpTabs,e)
end

local km={}; for _,t in ipairs(TabCfg) do km[t.k]=t end
for _,g in ipairs(GrpCfg) do
    local gt={}; grpHdr(g.lb,gt)
    for _,k in ipairs(g.ks) do if km[k] then mkTab(km[k],gt) end end
end


-- ══════════════════════════════════════════════════════
--  BOTÃO FLUTUANTE
-- ══════════════════════════════════════════════════════
local FB=Instance.new("Frame",SGui)
FB.Size=UDim2.new(0,68,0,68); FB.Position=UDim2.new(0.05,0,0.08,0)
FB.BackgroundColor3=Color3.fromRGB(12,13,20); FB.BorderSizePixel=0; FB.Visible=false; FB.ZIndex=100; FB.Active=true
Instance.new("UICorner",FB).CornerRadius=UDim.new(1,0)
local FBR=Instance.new("UIStroke",FB); FBR.Color=CA; FBR.Thickness=2.2
local FBL=Instance.new("TextLabel",FB); FBL.BackgroundTransparency=1; FBL.Size=UDim2.new(1,0,1,0)
FBL.Font=Enum.Font.GothamBlack; FBL.Text="PD"; FBL.TextColor3=Color3.fromRGB(220,225,255); FBL.TextSize=20; FBL.ZIndex=105
local FBS=Instance.new("UIStroke",FBL); FBS.Color=CA; FBS.Thickness=1.5; FBS.Transparency=0.3
local FBBtn=Instance.new("TextButton",FB); FBBtn.BackgroundTransparency=1; FBBtn.Size=UDim2.new(1,0,1,0); FBBtn.Text=""; FBBtn.ZIndex=110

local function showFB()
    FB.Size=UDim2.new(0,0,0,0); FB.Position=UDim2.new(0.05,34,0.08,34); FB.Visible=true
    TS:Create(FB,TweenInfo.new(0.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,68,0,68),Position=UDim2.new(0.05,0,0.08,0)}):Play()
end
FBBtn.MouseEnter:Connect(function() TS:Create(FBR,TweenInfo.new(0.2),{Color=Color3.fromRGB(160,170,255),Thickness=3}):Play() end)
FBBtn.MouseLeave:Connect(function() TS:Create(FBR,TweenInfo.new(0.2),{Color=CA,Thickness=2.2}):Play() end)
FBBtn.MouseButton1Click:Connect(function()
    TS:Create(FB,TweenInfo.new(0.2,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0.05,34,0.08,34)}):Play()
    task.delay(0.22,function()
        FB.Visible=false; FB.Size=UDim2.new(0,68,0,68); FB.Position=UDim2.new(0.05,0,0.08,0)
        MF.Visible=true; MF.Size=UDim2.new(0,540,0,0)
        TS:Create(MF,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,540,0,370)}):Play()
        task.delay(0.2,function() SB.Visible=true; CA2.Visible=true; Div.Visible=true; Foot.Visible=true end)
    end)
end)

-- ── Ações topbar ──────────────────────────────────────────────
local isMin=false
TopBtns["Minimize"].MouseButton1Click:Connect(function()
    isMin=not isMin
    if isMin then
        Foot.Visible=false; SB.Visible=false; CA2.Visible=false; Div.Visible=false
        TS:Create(MF,TweenInfo.new(0.25),{Size=UDim2.new(0,540,0,40)}):Play()
    else
        TS:Create(MF,TweenInfo.new(0.25),{Size=UDim2.new(0,540,0,370)}):Play()
        task.delay(0.2,function() SB.Visible=true; CA2.Visible=true; Div.Visible=true; Foot.Visible=true end)
    end
end)

local isMax=false; local normPos=MF.Position
TopBtns["Maximize"].MouseButton1Click:Connect(function()
    isMax=not isMax
    if isMax then normPos=MF.Position
        TS:Create(MF,TweenInfo.new(0.3),{Size=UDim2.new(0,760,0,500),Position=UDim2.new(0.5,-380,0.5,-250)}):Play()
    else TS:Create(MF,TweenInfo.new(0.3),{Size=UDim2.new(0,540,0,370),Position=normPos}):Play() end
end)

TopBtns["Close"].MouseButton1Click:Connect(function()
    TS:Create(MF,TweenInfo.new(0.2),{Size=UDim2.new(0,540,0,0)}):Play()
    task.delay(0.22,function()
        MF.Visible=false; MF.Size=UDim2.new(0,540,0,370)
        SB.Visible=true; CA2.Visible=true; Div.Visible=true; Foot.Visible=true; showFB()
    end)
end)

-- ══════════════════════════════════════════════════════
--  BOOST POPUP
-- ══════════════════════════════════════════════════════
local BP=Instance.new("Frame",SGui); BP.BackgroundColor3=Color3.fromRGB(28,29,34)
BP.Size=UDim2.new(0,190,0,0); BP.Visible=false; BP.ZIndex=200; BP.ClipsDescendants=true
Instance.new("UICorner",BP).CornerRadius=UDim.new(0,10)
local BPS=Instance.new("UIStroke",BP); BPS.Color=CA; BPS.Thickness=1.2
local BPList=Instance.new("UIListLayout",BP)
BPList.Padding=UDim.new(0,5); BPList.HorizontalAlignment=Enum.HorizontalAlignment.Center
local BPPad=Instance.new("UIPadding",BP)
BPPad.PaddingTop=UDim.new(0,8); BPPad.PaddingLeft=UDim.new(0,8)
BPPad.PaddingRight=UDim.new(0,8); BPPad.PaddingBottom=UDim.new(0,8)

local popOpen=false
local function togPop()
    popOpen=not popOpen
    if popOpen then
        local pos=TopBtns["Theme"].AbsolutePosition
        BP.Position=UDim2.new(0,pos.X-160,0,pos.Y+26); BP.Size=UDim2.new(0,190,0,0); BP.Visible=true
        TS:Create(BP,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,190,0,248)}):Play()
    else
        TS:Create(BP,TweenInfo.new(0.18),{Size=UDim2.new(0,190,0,0)}):Play()
        task.delay(0.19,function() BP.Visible=false end)
    end
end
TopBtns["Theme"].MouseButton1Click:Connect(togPop)

local origMats={}; local origTexs={}
local function ultraBoost(s)
    if s then
        pcall(function() sethiddenproperty(Plr,"MaximumSimulationRadius",math.huge) end)
        for _,o in pairs(workspace:GetDescendants()) do pcall(function()
            if o:IsA("BasePart") then
                if not origMats[o] then origMats[o]={M=o.Material,C=o.Color} end
                o.Material=Enum.Material.Plastic; o.CastShadow=false
            end
            if o:IsA("Texture") or o:IsA("Decal") then
                if not origTexs[o] then origTexs[o]=o.Transparency end; o.Transparency=1
            end
        end) end
    else
        for o,d in pairs(origMats) do pcall(function() if o and o.Parent then o.Material=d.M; o.Color=d.C; o.CastShadow=true end end) end
        for o,t in pairs(origTexs) do pcall(function() if o and o.Parent then o.Transparency=t end end) end
        origMats={}; origTexs={}
    end
end

local hidEff={}
local function remEff(s)
    if s then
        for _,v in pairs(Lite:GetChildren()) do pcall(function()
            if v:IsA("PostEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                hidEff[v]=v.Enabled; v.Enabled=false
            end
        end) end
    else
        for e,w in pairs(hidEff) do pcall(function() if e and e.Parent then e.Enabled=w end end) end; hidEff={}
    end
end

local hidNPC={}
local function remNPC(s)
    if s then
        for _,v in pairs(workspace:GetChildren()) do pcall(function()
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and not Plrs:GetPlayerFromCharacter(v) then
                for _,p in pairs(v:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if not hidNPC[p] then hidNPC[p]={T=p.Transparency,CC=p.CanCollide} end
                        p.Transparency=1; p.CanCollide=false
                    end
                end
            end
        end) end
    else
        for p,d in pairs(hidNPC) do pcall(function() if p and p.Parent then p.Transparency=d.T; p.CanCollide=d.CC end end) end; hidNPC={}
    end
end

local origSet={}
local function lagClean(s)
    if s then pcall(function()
        origSet.Q=settings().Rendering.QualityLevel
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        settings().Physics.AllowSleep=true
    end) else pcall(function() if origSet.Q then settings().Rendering.QualityLevel=origSet.Q end end); origSet={} end
end

local function mkPopTgl(txt,cb)
    local row=Instance.new("Frame",BP); row.BackgroundColor3=Color3.fromRGB(38,41,48)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,32)
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lbl=Instance.new("TextLabel",row); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,8,0,0); lbl.Size=UDim2.new(1,-50,1,0); lbl.Font=Enum.Font.GothamSemibold
    lbl.Text=txt; lbl.TextColor3=Color3.fromRGB(190,195,205); lbl.TextSize=10; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=201
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(60,65,75); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-42,0.5,-10); pill.Size=UDim2.new(0,36,0,20); pill.ZIndex=201
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(200,205,215); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,2,0.5,-8); knob.Size=UDim2.new(0,16,0,16); knob.ZIndex=202
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local st=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=203
    btn.MouseButton1Click:Connect(function()
        st=not st
        TS:Create(pill,TweenInfo.new(0.2),{BackgroundColor3=st and Color3.fromRGB(87,242,135) or Color3.fromRGB(60,65,75)}):Play()
        TS:Create(knob,TweenInfo.new(0.2),{Position=st and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
        cb(st)
    end)
end
mkPopTgl("⚡ Booster Ultra",ultraBoost)
mkPopTgl("🎨 Remover Efeitos",remEff)
mkPopTgl("👻 Remover NPCs",remNPC)
mkPopTgl("🧹 Limpar Lag",lagClean)

local rejBtn=Instance.new("TextButton",BP); rejBtn.BackgroundColor3=Color3.fromRGB(200,50,55)
rejBtn.BorderSizePixel=0; rejBtn.Size=UDim2.new(1,0,0,32); rejBtn.Font=Enum.Font.GothamBold
rejBtn.Text="🔄  REJOIN SERVER"; rejBtn.TextColor3=Color3.fromRGB(255,255,255); rejBtn.TextSize=11; rejBtn.ZIndex=201
Instance.new("UICorner",rejBtn).CornerRadius=UDim.new(0,7)
rejBtn.MouseButton1Click:Connect(function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId,game.JobId,Plr)
end)

UIS.InputBegan:Connect(function(inp)
    if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    if not popOpen then return end
    local mp=UIS:GetMouseLocation(); local ap,as=BP.AbsolutePosition,BP.AbsoluteSize
    if mp.X<ap.X or mp.X>ap.X+as.X or mp.Y<ap.Y or mp.Y>ap.Y+as.Y then togPop() end
end)


-- ══════════════════════════════════════════════════════
--  SLIDER LÍQUIDO ARRASTÁVEL
-- ══════════════════════════════════════════════════════
local _drag={active=false,data=nil}

UIS.InputChanged:Connect(function(inp)
    if not _drag.active or not _drag.data then return end
    if inp.UserInputType~=Enum.UserInputType.MouseMovement and inp.UserInputType~=Enum.UserInputType.Touch then return end
    pcall(function()
        local d=_drag.data; local tP=d.track.AbsolutePosition; local tS=d.track.AbsoluteSize
        local pct=math.clamp((inp.Position.X-tP.X)/tS.X,0,1)
        local val=math.round(d.min+(d.max-d.min)*pct)
        d.fill.Size=UDim2.new(pct,0,1,0); d.thumb.Position=UDim2.new(pct,-10,0.5,-10)
        d.vl.Text=tostring(val); d.onChange(val)
    end)
end)
UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        if _drag.data then
            local pct=_drag.data.fill.Size.X.Scale
            TS:Create(_drag.data.thumb,TweenInfo.new(0.1),{Size=UDim2.new(0,20,0,20),Position=UDim2.new(pct,-10,0.5,-10)}):Play()
        end
        _drag.active=false; _drag.data=nil
    end
end)

local function mkSlider(par,mn,mx,init,cor,onChange)
    local w=Instance.new("Frame",par)
    w.BackgroundColor3=Color3.fromRGB(16,18,26); w.BackgroundTransparency=0.05; w.BorderSizePixel=0
    w.Size=UDim2.new(1,-12,0,30); w.ZIndex=par.ZIndex+1
    Instance.new("UICorner",w).CornerRadius=UDim.new(0,15)
    local track=Instance.new("Frame",w); track.BackgroundColor3=Color3.fromRGB(28,32,44); track.BorderSizePixel=0
    track.Position=UDim2.new(0,12,0.5,-6); track.Size=UDim2.new(1,-24,0,12); track.ZIndex=w.ZIndex+1; track.ClipsDescendants=true
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local ip=math.clamp((init-mn)/(mx-mn),0,1)
    local fill=Instance.new("Frame",track); fill.BackgroundColor3=cor; fill.BorderSizePixel=0
    fill.Size=UDim2.new(ip,0,1,0); fill.ZIndex=track.ZIndex+1
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local grad=Instance.new("UIGradient",fill)
    grad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),ColorSequenceKeypoint.new(0.4,Color3.fromRGB(200,210,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(120,130,200))}
    grad.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.5),NumberSequenceKeypoint.new(0.5,0.1),NumberSequenceKeypoint.new(1,0.4)}
    grad.Rotation=90
    local bub=Instance.new("Frame",fill); bub.BackgroundColor3=Color3.fromRGB(255,255,255); bub.BackgroundTransparency=0.55
    bub.BorderSizePixel=0; bub.Size=UDim2.new(0,12,0,8); bub.Position=UDim2.new(0.1,0,0.5,-4); bub.ZIndex=fill.ZIndex+1
    Instance.new("UICorner",bub).CornerRadius=UDim.new(1,0)
    local function animB()
        if not bub or not bub.Parent then return end
        TS:Create(bub,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Position=UDim2.new(0.75,-6,0.5,-4)}):Play()
        task.delay(1.85,function()
            if not bub or not bub.Parent then return end
            TS:Create(bub,TweenInfo.new(1.8,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Position=UDim2.new(0.1,0,0.5,-4)}):Play()
            task.delay(1.85,animB)
        end)
    end; task.spawn(animB)
    local thumb=Instance.new("Frame",track); thumb.BackgroundColor3=Color3.fromRGB(230,235,255); thumb.BorderSizePixel=0
    thumb.Position=UDim2.new(ip,-10,0.5,-10); thumb.Size=UDim2.new(0,20,0,20); thumb.ZIndex=track.ZIndex+3
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local tS=Instance.new("UIStroke",thumb); tS.Color=cor; tS.Thickness=2.5; tS.Transparency=0.2
    local vl=Instance.new("TextLabel",w); vl.BackgroundTransparency=1
    vl.Position=UDim2.new(0.5,-18,0,0); vl.Size=UDim2.new(0,36,1,0); vl.Font=Enum.Font.GothamBlack
    vl.Text=tostring(init); vl.TextColor3=Color3.fromRGB(230,240,255); vl.TextSize=11; vl.ZIndex=w.ZIndex+5
    local vs=Instance.new("UIStroke",vl); vs.Color=Color3.new(0,0,0); vs.Thickness=1.2; vs.Transparency=0.4
    local dBtn=Instance.new("TextButton",track); dBtn.BackgroundTransparency=1
    dBtn.Size=UDim2.new(1,0,1,0); dBtn.Text=""; dBtn.ZIndex=track.ZIndex+4
    local sd={track=track,fill=fill,thumb=thumb,vl=vl,min=mn,max=mx,cor=cor,onChange=onChange}
    dBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end
        _drag.active=true; _drag.data=sd
        local tP=track.AbsolutePosition; local tSz=track.AbsoluteSize
        local pct=math.clamp((inp.Position.X-tP.X)/tSz.X,0,1)
        local val=math.round(mn+(mx-mn)*pct)
        fill.Size=UDim2.new(pct,0,1,0); thumb.Position=UDim2.new(pct,-10,0.5,-10)
        vl.Text=tostring(val); onChange(val)
        TS:Create(thumb,TweenInfo.new(0.1),{Size=UDim2.new(0,24,0,24),Position=UDim2.new(pct,-12,0.5,-12)}):Play()
    end)
    dBtn.MouseEnter:Connect(function() TS:Create(tS,TweenInfo.new(0.15),{Thickness=3.5,Transparency=0}):Play() end)
    dBtn.MouseLeave:Connect(function() TS:Create(tS,TweenInfo.new(0.15),{Thickness=2.5,Transparency=0.2}):Play() end)
    return w
end


-- ══════════════════════════════════════════════════════
--  FUNÇÕES PLAYER
-- ══════════════════════════════════════════════════════
local plrSpd=30; local plrJmp=80; local flySpd=40
local flyOn=false; local fbv,fbg,flyConn
local noclipOn=false; local noclipC
local tpClickOn=false; local tpcC
local bauOn=false; local bauC

-- Novas funções v4.1
local infZoomOn=false; local origMinZ,origMaxZ
local camLivreOn=false; local camLivreC; local camMod={}
local fbOn=false; local origFB={}; local fbParts={}
local infJumpOn=false; local ijC
local slopeOn=false; local slopeC
local godOn=false; local godC,godHC

local function applySpd(v) pcall(function()
    local c=Plr.Character; if not c then return end
    local h=c:FindFirstChildWhichIsA("Humanoid"); if h then h.WalkSpeed=v end
end) end
local function applyJmp(v) pcall(function()
    local c=Plr.Character; if not c then return end
    local h=c:FindFirstChildWhichIsA("Humanoid"); if h then h.UseJumpPower=true; h.JumpPower=v end
end) end

Plr.CharacterAdded:Connect(function()
    task.wait(1); applySpd(plrSpd); applyJmp(plrJmp)
    if flyOn then
        task.wait(0.5)
        local c=Plr.Character; if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if fbv then pcall(function() fbv:Destroy() end) end
        if fbg then pcall(function() fbg:Destroy() end) end
        fbv=Instance.new("BodyVelocity",hrp); fbv.MaxForce=Vector3.new(1e6,1e6,1e6); fbv.Velocity=Vector3.zero
        fbg=Instance.new("BodyGyro",hrp); fbg.MaxTorque=Vector3.new(1e6,1e6,1e6); fbg.CFrame=hrp.CFrame
    end
end)

-- FLY
local function setFly(s)
    flyOn=s
    if s then
        local c=Plr.Character; if not c then return end
        local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if fbv then pcall(function() fbv:Destroy() end) end
        if fbg then pcall(function() fbg:Destroy() end) end
        fbv=Instance.new("BodyVelocity",hrp); fbv.MaxForce=Vector3.new(1e6,1e6,1e6); fbv.Velocity=Vector3.zero
        fbg=Instance.new("BodyGyro",hrp); fbg.MaxTorque=Vector3.new(1e6,1e6,1e6); fbg.CFrame=hrp.CFrame
        if flyConn then flyConn:Disconnect() end
        flyConn=RS.Heartbeat:Connect(function()
            if not flyOn then return end
            local c2=Plr.Character; if not c2 then return end
            local h2=c2:FindFirstChild("HumanoidRootPart"); if not h2 then return end
            if not fbv or not fbv.Parent then return end
            local cf=workspace.CurrentCamera.CFrame; local dir=Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir=dir-Vector3.new(0,1,0) end
            if dir.Magnitude>0 then fbv.Velocity=dir.Unit*flySpd else fbv.Velocity=Vector3.zero end
            fbg.CFrame=cf
        end)
    else
        if flyConn then flyConn:Disconnect(); flyConn=nil end
        pcall(function() if fbv then fbv:Destroy(); fbv=nil end end)
        pcall(function() if fbg then fbg:Destroy(); fbg=nil end end)
    end
end

-- NOCLIP
local function setNoclip(s)
    noclipOn=s
    if s then
        if noclipC then noclipC:Disconnect() end
        noclipC=RS.Stepped:Connect(function()
            if not noclipOn then return end
            local c=Plr.Character; if not c then return end
            local hrp=c:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y<-120 then hrp.CFrame=CFrame.new(hrp.Position.X,-100,hrp.Position.Z); hrp.Velocity=Vector3.zero end
            for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
        end)
    else
        if noclipC then noclipC:Disconnect(); noclipC=nil end
        pcall(function()
            local c=Plr.Character; if not c then return end
            for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=true end end
        end)
    end
end

-- TP CLICK
local function setTpClick(s)
    tpClickOn=s
    if s then
        if tpcC then tpcC:Disconnect() end
        tpcC=UIS.InputBegan:Connect(function(inp,gpe)
            if not tpClickOn or gpe then return end
            if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
            local c=Plr.Character; if not c then return end
            local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
            local mp=UIS:GetMouseLocation()
            local ray=workspace:Raycast(Cam.CFrame.Position,Cam:ScreenPointToRay(mp.X,mp.Y).Direction*2000)
            if ray then hrp.CFrame=CFrame.new(ray.Position.X,math.max(ray.Position.Y+3,-100),ray.Position.Z) end
        end)
    else if tpcC then tpcC:Disconnect(); tpcC=nil end end
end

-- BAÚ ANC
local function setBau(s)
    bauOn=s
    if s then
        if bauC then bauC:Disconnect() end
        bauC=workspace.DescendantAdded:Connect(function(o)
            if not bauOn then return end
            task.defer(function()
                if o:IsA("Animator") then
                    for _,t in ipairs(o:GetPlayingAnimationTracks()) do pcall(function() t:AdjustSpeed(9999) end) end
                end
            end)
        end)
        for _,o in ipairs(workspace:GetDescendants()) do pcall(function()
            if o:IsA("Animator") then
                for _,t in ipairs(o:GetPlayingAnimationTracks()) do t:AdjustSpeed(9999) end
            end
        end) end
    else if bauC then bauC:Disconnect(); bauC=nil end end
end

-- INF ZOOM
local function setInfZoom(s)
    infZoomOn=s
    if s then
        pcall(function() origMinZ=Plr.CameraMinZoomDistance; origMaxZ=Plr.CameraMaxZoomDistance end)
        Plr.CameraMinZoomDistance=0.1; Plr.CameraMaxZoomDistance=3000
    else
        pcall(function() Plr.CameraMinZoomDistance=origMinZ or 0.5; Plr.CameraMaxZoomDistance=origMaxZ or 400 end)
    end
end

-- CÂMERA LIVRE
local function setCamLivre(s)
    camLivreOn=s
    if s then
        if camLivreC then camLivreC:Disconnect() end
        camLivreC=RS.RenderStepped:Connect(function()
            if not camLivreOn then return end
            local camPos=Cam.CFrame.Position; local ch=Plr.Character
            for _,part in ipairs(workspace:GetDescendants()) do pcall(function()
                if not part:IsA("BasePart") then return end
                if ch and part:IsDescendantOf(ch) then return end
                if (part.Position-camPos).Magnitude<8 then
                    if not camMod[part] then camMod[part]=part.LocalTransparencyModifier end
                    part.LocalTransparencyModifier=math.max(part.LocalTransparencyModifier,0.94)
                elseif camMod[part] then
                    part.LocalTransparencyModifier=camMod[part]; camMod[part]=nil
                end
            end) end
        end)
    else
        if camLivreC then camLivreC:Disconnect(); camLivreC=nil end
        for obj,v in pairs(camMod) do pcall(function() if obj and obj.Parent then obj.LocalTransparencyModifier=v end end) end
        camMod={}
    end
end

-- FULLBRIGHT
local function setFB(s)
    fbOn=s; local L=Lite
    if s then
        origFB={Ambient=L.Ambient,OutdoorAmbient=L.OutdoorAmbient,Brightness=L.Brightness,
            GlobalShadows=L.GlobalShadows,FogEnd=L.FogEnd,ClockTime=L.ClockTime}
        L.Ambient=Color3.fromRGB(255,255,255); L.OutdoorAmbient=Color3.fromRGB(255,255,255)
        L.Brightness=12; L.GlobalShadows=false; L.FogEnd=200000; L.ClockTime=14
        for _,v in pairs(L:GetChildren()) do pcall(function()
            if v:IsA("Atmosphere") then v.Density=0; v.Haze=0; v.Glare=0 end
        end) end
        local wkw={"rain","fog","mist","cloud","snow","storm","drizzle","weather","neblina","chuva","neve"}
        for _,o in ipairs(workspace:GetDescendants()) do pcall(function()
            if o:IsA("ParticleEmitter") or o:IsA("Smoke") then
                local n=o.Name:lower(); local isW=false
                for _,kw in ipairs(wkw) do if n:find(kw) then isW=true; break end end
                if isW then if fbParts[o]==nil then fbParts[o]=o.Enabled end; o.Enabled=false end
            end
        end) end
        task.spawn(function()
            while fbOn do task.wait(8); pcall(function()
                if not fbOn then return end
                if L.ClockTime<10 or L.ClockTime>18 then L.ClockTime=14 end
                L.Ambient=Color3.fromRGB(255,255,255); L.OutdoorAmbient=Color3.fromRGB(255,255,255)
                L.Brightness=12; L.GlobalShadows=false
            end) end
        end)
    else
        for k,v in pairs(origFB) do pcall(function() L[k]=v end) end; origFB={}
        for o,v in pairs(fbParts) do pcall(function() if o and o.Parent then o.Enabled=v end end) end; fbParts={}
    end
end

-- INFINITE JUMP
local function setInfJump(s)
    infJumpOn=s
    if s then
        if ijC then ijC:Disconnect() end
        ijC=UIS.JumpRequest:Connect(function()
            if not infJumpOn then return end
            pcall(function()
                local c=Plr.Character; if not c then return end
                local h=c:FindFirstChildWhichIsA("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end)
    else if ijC then ijC:Disconnect(); ijC=nil end end
end

-- SLOPE BOOST
local function setSlope(s)
    slopeOn=s
    if s then
        if slopeC then slopeC:Disconnect() end
        slopeC=RS.Heartbeat:Connect(function()
            if not slopeOn then return end
            pcall(function()
                local c=Plr.Character; if not c then return end
                local h=c:FindFirstChildWhichIsA("Humanoid"); if h and h.WalkSpeed<plrSpd-0.5 then h.WalkSpeed=plrSpd end
            end)
        end)
    else if slopeC then slopeC:Disconnect(); slopeC=nil end end
end

-- GOD MODE
local PKWS={"bullet","projectile","fireball","spell","magic","arrow","bolt","orb","shard","blast","ray"}
local function setGod(s)
    godOn=s
    if s then
        if godC then godC:Disconnect() end
        godC=RS.Heartbeat:Connect(function()
            if not godOn then return end
            pcall(function()
                local c=Plr.Character; if not c then return end
                local h=c:FindFirstChildWhichIsA("Humanoid"); if not h then return end
                local hrp=c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
                if h.Health<h.MaxHealth then h.Health=h.MaxHealth end
                local myP=hrp.Position
                for _,obj in pairs(workspace:GetDescendants()) do pcall(function()
                    if not obj:IsA("BasePart") or obj:IsDescendantOf(c) then return end
                    local vel=obj.AssemblyLinearVelocity.Magnitude; if vel<8 then return end
                    if (obj.Position-myP).Magnitude>18 then return end
                    local n=obj.Name:lower(); local isProj=false
                    for _,kw in ipairs(PKWS) do if n:find(kw) then isProj=true; break end end
                    if not isProj and not obj.Anchored and vel>15 then
                        local sz=obj.Size; if sz.X<3 and sz.Y<3 and sz.Z<3 then isProj=true end
                    end
                    if isProj then
                        local away=(obj.Position-myP).Unit
                        obj.AssemblyLinearVelocity=(away+Vector3.new(0,1.5,0)).Unit*60
                        task.delay(0.1,function() pcall(function() if obj and obj.Parent then obj:Destroy() end end) end)
                    end
                end) end
            end)
        end)
        local function hookC(c)
            if not c then return end; task.wait(0.5)
            local h=c:FindFirstChildWhichIsA("Humanoid"); if not h then return end
            if godHC then godHC:Disconnect() end
            godHC=h.HealthChanged:Connect(function(hp)
                if godOn and h and h.Parent and hp<h.MaxHealth then h.Health=h.MaxHealth end
            end)
        end
        hookC(Plr.Character); Plr.CharacterAdded:Connect(hookC)
    else
        if godC then godC:Disconnect(); godC=nil end
        if godHC then godHC:Disconnect(); godHC=nil end
    end
end


-- ══════════════════════════════════════════════════════
--  UI ABA PLAYER v4.1
-- ══════════════════════════════════════════════════════
local plLO=0
local function plo() plLO+=1; return plLO end

local function plSec(txt,cor)
    local h=Instance.new("Frame",Pages["Player"])
    h.BackgroundColor3=Color3.fromRGB(20,22,30); h.BackgroundTransparency=0.3
    h.BorderSizePixel=0; h.Size=UDim2.new(1,0,0,22); h.LayoutOrder=plo(); h.ZIndex=4
    Instance.new("UICorner",h).CornerRadius=UDim.new(0,6)
    local b=Instance.new("Frame",h); b.BackgroundColor3=cor; b.BorderSizePixel=0
    b.Position=UDim2.new(0,0,0,0); b.Size=UDim2.new(0,3,1,0); b.ZIndex=5
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel",h); l.BackgroundTransparency=1
    l.Position=UDim2.new(0,10,0,0); l.Size=UDim2.new(1,-14,1,0); l.Font=Enum.Font.GothamBlack
    l.Text=txt; l.TextColor3=cor; l.TextSize=9; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
end

local function mkPlrIcon(par,key,cor)
    local cont=Instance.new("Frame",par); cont.BackgroundTransparency=1; cont.BorderSizePixel=0
    cont.Size=UDim2.new(0,28,0,28); cont.ZIndex=par.ZIndex+2
    local function r(x,y,w,h,radius)
        local f=Instance.new("Frame",cont); f.BackgroundColor3=cor; f.BorderSizePixel=0
        f.Position=UDim2.new(0,x,0,y); f.Size=UDim2.new(0,w,0,h); f.ZIndex=cont.ZIndex+1
        if radius then Instance.new("UICorner",f).CornerRadius=UDim.new(0,radius) end; return f
    end
    local function c(cx,cy,rad) return r(cx-rad,cy-rad,rad*2,rad*2,rad*2) end
    local function dk(f) f.BackgroundColor3=Color3.fromRGB(20,22,28); return f end
    if key=="Speed" then r(16,0,10,14,2); r(8,10,12,2,1); r(2,12,12,16,2)
    elseif key=="JumpPower" then c(14,5,4); r(11,10,6,8,2); r(8,14,4,8,1); r(16,14,4,8,1); r(12,0,4,7,1)
    elseif key=="Fly" then r(0,10,10,6,3); r(18,10,10,6,3); c(14,10,4)
    elseif key=="Noclip" then r(0,4,10,20,2); c(18,8,6); r(12,8,12,14,1); r(12,20,4,4,2); r(18,20,4,4,2)
    elseif key=="TpClick" then r(2,0,4,20,1); r(2,0,18,4,1); r(2,8,10,2,1)
        local t=r(16,0,10,14,2); t.BackgroundColor3=Color3.fromRGB(255,230,50); dk(r(18,2,6,10,2))
    elseif key=="BauANC" then r(2,10,24,14,3); r(2,6,24,6,2)
        local lock=r(10,14,8,6,2); lock.BackgroundColor3=Color3.fromRGB(255,200,50); dk(r(12,10,4,3,1))
    elseif key=="InfZoom" then c(10,10,8); dk(c(10,10,5)); r(16,16,10,4,2); r(22,12,4,4,2)
    elseif key=="CamLivre" then r(2,8,18,14,3); r(20,10,6,4,1); r(20,18,6,4,1); c(11,15,4); dk(c(11,15,2))
    elseif key=="FullBright" then
        c(14,14,7); dk(c(14,14,4))
        for _,deg in ipairs({0,45,90,135,180,225,270,315}) do
            local rad2=math.rad(deg); r(14+math.cos(rad2)*10-1,14+math.sin(rad2)*10-1,2,2,1)
        end
    elseif key=="InfJump" then c(14,6,4); r(11,10,6,6,2); r(9,13,3,5,1); r(15,13,3,5,1)
        r(2,2,8,4,2); r(10,2,8,4,2); c(6,4,3); c(18,4,3)
    elseif key=="SlopeBoost" then c(14,5,8); r(6,10,16,12,2); r(10,18,8,6,2)
        dk(c(14,10,5)); local s2=r(12,7,4,10,1); s2.BackgroundColor3=Color3.fromRGB(255,200,60)
    elseif key=="GodMode" then
        c(14,9,7); dk(c(14,9,4)); r(9,14,4,5,1); r(15,14,4,5,1); r(12,18,4,3,1)
        dk(r(11,7,3,3,1)); dk(r(16,7,3,3,1)); c(14,3,5); dk(c(14,3,3))
    end
    return cont
end

-- Row com Slider
local function plSliderRow(iconKey,cor,lbl,desc,mn,mx,init,onChange)
    local row=Instance.new("Frame",Pages["Player"])
    row.BackgroundColor3=Color3.fromRGB(28,30,38); row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,80); row.LayoutOrder=plo(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local rS=Instance.new("UIStroke",row); rS.Color=Color3.fromRGB(42,46,58); rS.Thickness=1
    local gb=Instance.new("Frame",row); gb.BackgroundColor3=cor; gb.BackgroundTransparency=0.88
    gb.BorderSizePixel=0; gb.Size=UDim2.new(1,0,1,0); gb.ZIndex=5
    Instance.new("UICorner",gb).CornerRadius=UDim.new(0,9)
    local bl=Instance.new("Frame",row); bl.BackgroundColor3=cor; bl.BorderSizePixel=0
    bl.Position=UDim2.new(0,0,0.15,0); bl.Size=UDim2.new(0,3,0.7,0); bl.ZIndex=8
    Instance.new("UICorner",bl).CornerRadius=UDim.new(0,2)
    local ib=Instance.new("Frame",row); ib.BackgroundColor3=cor; ib.BackgroundTransparency=0.78
    ib.BorderSizePixel=0; ib.Position=UDim2.new(0,8,0.5,-20); ib.Size=UDim2.new(0,40,0,40); ib.ZIndex=7
    Instance.new("UICorner",ib).CornerRadius=UDim.new(0,10)
    local ic=mkPlrIcon(ib,iconKey,cor); ic.Position=UDim2.new(0,6,0,6); ic.Size=UDim2.new(0,28,0,28)
    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,58,0,7); tl.Size=UDim2.new(1,-62,0,16)
    tl.Font=Enum.Font.GothamBold; tl.Text=lbl; tl.TextColor3=Color3.fromRGB(225,230,250)
    tl.TextSize=11; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local td=Instance.new("TextLabel",row); td.BackgroundTransparency=1
    td.Position=UDim2.new(0,58,0,24); td.Size=UDim2.new(1,-62,0,14)
    td.Font=Enum.Font.Gotham; td.Text=desc; td.TextColor3=Color3.fromRGB(90,100,120)
    td.TextSize=8; td.TextXAlignment=Enum.TextXAlignment.Left; td.ZIndex=7
    local sc=Instance.new("Frame",row); sc.BackgroundTransparency=1; sc.BorderSizePixel=0
    sc.Position=UDim2.new(0,8,0,45); sc.Size=UDim2.new(1,-16,0,30); sc.ZIndex=8
    local sw=mkSlider(sc,mn,mx,init,cor,function(v)
        onChange(v)
        TS:Create(rS,TweenInfo.new(0.15),{Color=cor}):Play()
        task.delay(1.2,function() TS:Create(rS,TweenInfo.new(0.5),{Color=Color3.fromRGB(42,46,58)}):Play() end)
    end); sw.Position=UDim2.new(0,0,0,0)
    row.MouseEnter:Connect(function() TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(33,36,46)}):Play() end)
    row.MouseLeave:Connect(function() TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,30,38)}):Play() end)
end

-- Row Toggle
local function plTogRow(iconKey,cor,lbl,desc,onTgl,flyS)
    local hasS=flyS~=nil; local H=hasS and 88 or 62
    local row=Instance.new("Frame",Pages["Player"])
    row.BackgroundColor3=Color3.fromRGB(28,30,38); row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,H); row.LayoutOrder=plo(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local rS=Instance.new("UIStroke",row); rS.Color=Color3.fromRGB(42,46,58); rS.Thickness=1
    local gb=Instance.new("Frame",row); gb.BackgroundColor3=cor; gb.BackgroundTransparency=0.88
    gb.BorderSizePixel=0; gb.Size=UDim2.new(1,0,1,0); gb.ZIndex=5
    Instance.new("UICorner",gb).CornerRadius=UDim.new(0,9)
    local bl=Instance.new("Frame",row); bl.BackgroundColor3=cor; bl.BorderSizePixel=0
    bl.Position=UDim2.new(0,0,0.1,0); bl.Size=UDim2.new(0,3,0.8,0); bl.ZIndex=8
    Instance.new("UICorner",bl).CornerRadius=UDim.new(0,2)
    local ib=Instance.new("Frame",row); ib.BackgroundColor3=cor; ib.BackgroundTransparency=0.78
    ib.BorderSizePixel=0; ib.Position=UDim2.new(0,8,0,10); ib.Size=UDim2.new(0,40,0,40); ib.ZIndex=7
    Instance.new("UICorner",ib).CornerRadius=UDim.new(0,10)
    local ic=mkPlrIcon(ib,iconKey,cor); ic.Position=UDim2.new(0,6,0,6); ic.Size=UDim2.new(0,28,0,28)
    local tl=Instance.new("TextLabel",row); tl.BackgroundTransparency=1
    tl.Position=UDim2.new(0,58,0,8); tl.Size=UDim2.new(1,-120,0,16)
    tl.Font=Enum.Font.GothamBold; tl.Text=lbl; tl.TextColor3=Color3.fromRGB(225,230,250)
    tl.TextSize=11; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=7
    local td=Instance.new("TextLabel",row); td.BackgroundTransparency=1
    td.Position=UDim2.new(0,58,0,26); td.Size=UDim2.new(1,-120,0,hasS and 16 or 28)
    td.Font=Enum.Font.Gotham; td.Text=desc; td.TextColor3=Color3.fromRGB(90,100,120)
    td.TextSize=9; td.TextXAlignment=Enum.TextXAlignment.Left; td.TextWrapped=true; td.ZIndex=7
    if hasS then
        local sc2=Instance.new("Frame",row); sc2.BackgroundTransparency=1; sc2.BorderSizePixel=0
        sc2.Position=UDim2.new(0,8,0,52); sc2.Size=UDim2.new(1,-16,0,30); sc2.ZIndex=8
        local sw2=mkSlider(sc2,flyS.min,flyS.max,flyS.init,cor,function(v) flySpd=v end)
        sw2.Position=UDim2.new(0,0,0,0)
    end
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(45,50,62)
    pill.BorderSizePixel=0; pill.Position=UDim2.new(1,-58,0,10); pill.Size=UDim2.new(0,50,0,24); pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(160,170,185)
    knob.BorderSizePixel=0; knob.Position=UDim2.new(0,2,0.5,-10); knob.Size=UDim2.new(0,20,0,20); knob.ZIndex=10
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local dot=Instance.new("Frame",row); dot.BackgroundColor3=Color3.fromRGB(60,65,80)
    dot.BorderSizePixel=0; dot.Position=UDim2.new(1,-60,0,40); dot.Size=UDim2.new(0,8,0,8); dot.ZIndex=9
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local est=false
    local pb=Instance.new("TextButton",row); pb.BackgroundTransparency=1
    pb.Position=UDim2.new(1,-62,0,6); pb.Size=UDim2.new(0,56,0,32); pb.Text=""; pb.ZIndex=11
    pb.MouseButton1Click:Connect(function()
        est=not est
        TS:Create(pill,TweenInfo.new(0.22),{BackgroundColor3=est and cor or Color3.fromRGB(45,50,62)}):Play()
        TS:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=est and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,2,0.5,-10),
            BackgroundColor3=est and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185),
        }):Play()
        TS:Create(rS,TweenInfo.new(0.2),{Color=est and cor or Color3.fromRGB(42,46,58)}):Play()
        TS:Create(dot,TweenInfo.new(0.2),{BackgroundColor3=est and Color3.fromRGB(87,242,135) or Color3.fromRGB(60,65,80)}):Play()
        onTgl(est)
    end)
    row.MouseEnter:Connect(function() TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(33,36,46)}):Play() end)
    row.MouseLeave:Connect(function() TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,30,38)}):Play() end)
end

-- Construir aba Player
plSec("⚡ VELOCIDADE & PULO",Color3.fromRGB(255,200,50))
plSliderRow("Speed",Color3.fromRGB(255,175,30),"⚡ Speed","Velocidade de corrida  |  1→200  |  padrão: 16",1,200,30,function(v) plrSpd=v; applySpd(v) end)
plSliderRow("JumpPower",Color3.fromRGB(100,220,255),"🦘 Jump Power","Força do pulo  |  10→500  |  padrão: 50",10,500,80,function(v) plrJmp=v; applyJmp(v) end)
plSec("✈️ VOO & MOVIMENTO",Color3.fromRGB(100,200,255))
plTogRow("Fly",Color3.fromRGB(80,180,255),"✈️ Fly","W/A/S/D mover  •  Espaço subir  •  Ctrl/Shift descer",function(s) setFly(s) end,{min=5,max=300,init=40})
plTogRow("Noclip",Color3.fromRGB(140,255,140),"👻 Noclip","Atravessa paredes  |  Anti-void ativo",function(s) setNoclip(s) end)
plTogRow("TpClick",Color3.fromRGB(255,220,60),"⚡ TP Click","Clique no chão para teleportar",function(s) setTpClick(s) end)
plTogRow("BauANC",Color3.fromRGB(210,160,80),"📦 Baú ANC","Baús abrem instantaneamente",function(s) setBau(s) end)
plSec("🌟 NOVIDADES v4.1",Color3.fromRGB(220,160,255))
plTogRow("InfZoom",Color3.fromRGB(180,100,255),"🔍 InfinitoZoom","Zoom de 0 a 3000 studs sem limite",function(s) setInfZoom(s) end)
plTogRow("CamLivre",Color3.fromRGB(60,200,255),"🎥 Câmera Livre","Câmera atravessa paredes",function(s) setCamLivre(s) end)
plTogRow("FullBright",Color3.fromRGB(255,230,60),"☀️ FullBright","Noite vira dia  |  Remove chuva e neblina",function(s) setFB(s) end)
plTogRow("InfJump",Color3.fromRGB(100,255,200),"♾️ Infinite Jump","Pule infinitas vezes no ar",function(s) setInfJump(s) end)
plTogRow("SlopeBoost",Color3.fromRGB(255,140,30),"🛡️ Slope Boost","Velocidade sempre mantida contra armadilhas",function(s) setSlope(s) end)
plTogRow("GodMode",Color3.fromRGB(255,60,60),"☠️ God Mode","HP máximo + deflect de projéteis de mobs",function(s) setGod(s) end)


-- ══════════════════════════════════════════════════════
--  ESP — 20 categorias (lógica + UI)
-- ══════════════════════════════════════════════════════
local EspCanvas=Instance.new("Frame",SGui); EspCanvas.BackgroundTransparency=1; EspCanvas.Size=UDim2.new(1,0,1,0); EspCanvas.ZIndex=1

local ESP_CATS={
    {k="Players",cor=Color3.fromRGB(255,80,80),tipo="player",alcance=math.huge,label="👤 Players",desc="Todos os players"},
    {k="Kids",cor=Color3.fromRGB(100,220,255),tipo="entity",alcance=math.huge,label="👶 Crianças Perdidas",desc="DinoKid, KrakanKid, SquidKid, KoalaKid",
     nomes={"Dino Kid","Kraken Kid","Squid Kid","Koala Kid","DinoKid","KrakenKid","SquidKid","KoalaKid","Kid","Child","MissingChild"}},
    {k="AnimPassivo",cor=Color3.fromRGB(130,255,170),tipo="entity",alcance=500,label="🐰 Animais Passivos",desc="Bunny, Horse, Kiwi, Turkey",
     nomes={"Bunny","Horse","Kiwi","Turkey"}},
    {k="AnimAgressivo",cor=Color3.fromRGB(255,175,30),tipo="entity",alcance=600,label="🐺 Animais Agressivos",desc="Wolf, Bear, PolarBear, Frog, Scorpion…",
     nomes={"Wolf","Alpha Wolf","AlphaWolf","Bear","Polar Bear","PolarBear","Arctic Fox","ArcticFox","Frog","Blue Frog","Purple Frog","Green Frog","BlueFrog","PurpleFrog","GreenFrog","Scorpion","Hellephant","Meteor Crab","MeteorCrab","Mammoth"}},
    {k="Monstros",cor=Color3.fromRGB(255,50,50),tipo="entity",alcance=math.huge,label="💀 Monstros",desc="The Deer, The Owl, The Ram",
     nomes={"The Deer","TheDeer","Deer","The Owl","TheOwl","Owl","The Ram","TheRam","Ram"}},
    {k="Cultistas",cor=Color3.fromRGB(195,60,200),tipo="entity",alcance=math.huge,label="⚔️ Cultistas",desc="Cultist, Juggernaut, Cultist King…",
     nomes={"Cultist","Melee Cultist","MeleeCultist","Crossbow Cultist","CrossbowCultist","Juggernaut Cultist","JuggernautCultist","Juggernaut","Cultist King","CultistKing","Mega Cultist","MegaCultist"}},
    {k="Aliens",cor=Color3.fromRGB(60,255,200),tipo="entity",alcance=700,label="👽 Aliens",desc="Alien, Elite Alien",
     nomes={"Alien","Elite Alien","EliteAlien","NormalAlien"}},
    {k="EspLog",cor=Color3.fromRGB(190,130,60),tipo="item",alcance=400,label="🪵 Log",desc="Log",nomes={"Log"}},
    {k="EspCombust",cor=Color3.fromRGB(255,120,30),tipo="item",alcance=400,label="🔥 Combustível",desc="Coal, Biofuel, Fuel Canister…",
     nomes={"Coal","Biofuel","Oil Barrel","OilBarrel","Fuel Canister","FuelCanister","Purple Fur Tuft","PurpleFurTuft","Chair"}},
    {k="EspCarcacas",cor=Color3.fromRGB(180,100,50),tipo="item",alcance=350,label="🦴 Carcaças",desc="Wolf/Bear/Mammoth Corpse…",
     nomes={"Wolf Corpse","WolfCorpse","Alpha Wolf Corpse","AlphaWolfCorpse","Bear Corpse","BearCorpse","Polar Bear Corpse","PolarBearCorpse","Arctic Fox Corpse","ArcticFoxCorpse","Mammoth Corpse","MammothCorpse","Hellephant Corpse","HellephantCorpse","Frog Corpse","FrogCorpse","Cultist Corpse","CultistCorpse","Crossbow Cultist Corpse","CrossbowCultistCorpse","Juggernaut Cultist Corpse","JuggernautCultistCorpse","Cultist King Corpse","CultistKingCorpse","Alien Corpse","AlienCorpse","Elite Alien Corpse","EliteAlienCorpse"}},
    {k="EspSucata",cor=Color3.fromRGB(155,210,255),tipo="item",alcance=400,label="🔩 Sucata",desc="Bolt, Sheet Metal, UFO Junk…",
     nomes={"Bolt","Sheet Metal","SheetMetal","UFO Junk","UFOJunk","UFO Component","UFOComponent","UFO Scrap","UFOScrap","Broken Fan","BrokenFan","Old Radio","OldRadio","Broken Radio","BrokenRadio","Broken Microwave","BrokenMicrowave","Tyre","Metal Chair","MetalChair","Old Car Engine","OldCarEngine","Washing Machine","WashingMachine","Cultist Experiment","CultistExperiment","Cultist Prototype","CultistPrototype"}},
    {k="EspMateriais",cor=Color3.fromRGB(220,175,255),tipo="item",alcance=400,label="💎 Materiais",desc="Cultist Gem, Forest Gem, Mossy Coin…",
     nomes={"Cultist Gem","CultistGem","Forest Gem","ForestGem","Forest Gem Fragment","ForestGemFragment","Mossy Coin","MossyCoin","Flower","Sapling","Sacrifice Totem","SacrificeTotem","Meteor Shard","MeteorShard","Gold Shard","GoldShard","Raw Obsidiron Ore","RawObsidironOre","Obsidiron Ingot","ObsidironIngot","Scalding Obsidiron Ingot"}},
    {k="EspComidas",cor=Color3.fromRGB(255,115,165),tipo="item",alcance=350,label="🍖 Comidas",desc="Carrot, Corn, Steak, Ribs, Stew…",
     nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake","Morsel","Cooked Morsel","CookedMorsel","Steak","Cooked Steak","CookedSteak","Ribs","Cooked Ribs","CookedRibs","Stew","Hearty Stew","HeartyStew","Seafood Chowder","Steak Dinner","Pumpkin Soup","BBQ Ribs","Carrot Cake","Turkey Leg","Cooked Turkey Leg","Stuffing","Sweet Potato","Berry Juice","Casserole","Corn on the Cob","Roast Turkey","Stuffed Peppers","Sweet Potato Pie","Spicy Swordfish"}},
    {k="EspPeixes",cor=Color3.fromRGB(80,180,255),tipo="item",alcance=400,label="🐟 Peixes",desc="Mackerel, Salmon, Clownfish, Shark…",
     nomes={"Mackerel","Cooked Mackerel","CookedMackerel","Salmon","Cooked Salmon","CookedSalmon","Clownfish","Cooked Clownfish","CookedClownfish","Jellyfish","Char","Cooked Char","CookedChar","Eel","Cooked Eel","CookedEel","Swordfish","Cooked Swordfish","CookedSwordfish","Shark","Cooked Shark","CookedShark","Lava Eel","LavaEel","Cooked Lava Eel","CookedLavaEel","Lionfish","Cooked Lionfish","CookedLionfish"}},
    {k="EspSementes",cor=Color3.fromRGB(135,245,115),tipo="item",alcance=350,label="🌱 Sementes",desc="Chili, Berry, Flower, Dripleaf…",
     nomes={"Chili Seeds","ChiliSeeds","Flower Seeds","FlowerSeeds","Berry Seeds","BerrySeeds","Firefly Seeds","FireflySeeds","Dripleaf Seeds","DripleafSeeds","Moonflower Seeds","MoonflowerSeeds","Stareweed Seeds","StareweedSeeds","Cavevine Seeds","CavevineSeeds","Mandrake Seeds","MandrakeSeeds"}},
    {k="EspFerr",cor=Color3.fromRGB(255,200,55),tipo="item",alcance=500,label="🪓 Ferramentas",desc="Axes, Sacks, Rods, Flutes, Armaduras…",
     nomes={"Old Sack","OldSack","Good Sack","GoodSack","Infernal Sack","InfernalSack","Giant Sack","GiantSack","Old Axe","OldAxe","Good Axe","GoodAxe","Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw","Old Rod","OldRod","Good Rod","GoodRod","Strong Rod","StrongRod","Old Taming Flute","OldFlute","Good Taming Flute","GoodFlute","Strong Taming Flute","StrongFlute","Old Flashlight","OldFlashlight","Strong Flashlight","StrongFlashlight","Hammer","Paint Brush","PaintBrush","Watering Can","WateringCan","Cultist Staff","CultistStaff","Leather Body","LeatherBody","Alien Armour","AlienArmour","Frog Boots","FrogBoots","Poison Armour","PoisonArmour"}},
    {k="EspArmas",cor=Color3.fromRGB(255,70,70),tipo="item",alcance=500,label="⚔️ Armas",desc="Spear, Ice Sword, Crossbow, Revolver…",
     nomes={"Spear","Morningstar","Katana","Laser Sword","LaserSword","Ice Sword","IceSword","Trident","Poison Spear","PoisonSpear","Infernal Sword","InfernalSword","Obsidiron Hammer","ObsidironHammer","Scythe","Crossbow","Infernal Crossbow","InfernalCrossbow","Bouncing Blade","BouncingBlade","Vampire Scythe","VampireScythe","Revolver","Rifle","Tactical Shotgun","TacticalShotgun","Ray Gun","RayGun","Laser Cannon","LaserCannon","Flamethrower","Snowball","Frozen Shuriken","FrozenShuriken","Kunai","Witch Potion","WitchPotion","Wildfire","Blowpipe","Air Rifle","AirRifle"}},
    {k="EspAmmo",cor=Color3.fromRGB(255,155,60),tipo="item",alcance=400,label="🔫 Munição",desc="Revolver, Rifle, Shotgun Ammo",
     nomes={"Revolver Ammo","RevolverAmmo","Rifle Ammo","RifleAmmo","Shotgun Ammo","ShotgunAmmo"}},
    {k="EspCura",cor=Color3.fromRGB(120,255,200),tipo="item",alcance=450,label="💊 Cura & Pelts",desc="Bandage, Medkit, Wolf/Bear Pelt…",
     nomes={"Bandage","Medkit","Bunny Foot","BunnyFoot","Wolf Pelt","WolfPelt","Alpha Wolf Pelt","AlphaWolfPelt","Bear Pelt","BearPelt","Arctic Fox Pelt","ArcticFoxPelt","Polar Bear Pelt","PolarBearPelt","Mammoth Tusk","MammothTusk","Scorpion Shell","ScorpionShell","Cultist King Antler","CultistKingAntler"}},
    {k="EspChaves",cor=Color3.fromRGB(255,230,80),tipo="item",alcance=math.huge,label="🗝️ Chaves",desc="Red, Blue, Yellow, Grey, Frog Key",
     nomes={"Red Key","RedKey","Blue Key","BlueKey","Yellow Key","YellowKey","Grey Key","GreyKey","Frog Key","FrogKey"}},
}

local espAtivo={}; for _,c in ipairs(ESP_CATS) do espAtivo[c.k]=false end
local espLkp={}
for _,c in ipairs(ESP_CATS) do
    if c.nomes then local s={}; for _,n in ipairs(c.nomes) do s[n:lower()]=true end; espLkp[c.k]=s end
end

local POOL=80; local lblPool={}; local actLbl={}
local function newLbl()
    local f=Instance.new("Frame",EspCanvas); f.BackgroundTransparency=1; f.BorderSizePixel=0
    f.Size=UDim2.new(0,200,0,28); f.Visible=false; f.ZIndex=10
    local bg=Instance.new("Frame",f); bg.BackgroundColor3=Color3.fromRGB(6,8,14); bg.BackgroundTransparency=0.3
    bg.BorderSizePixel=0; bg.Size=UDim2.new(1,0,1,0); bg.ZIndex=10
    Instance.new("UICorner",bg).CornerRadius=UDim.new(0,5)
    local nl=Instance.new("TextLabel",f); nl.Name="NL"; nl.BackgroundTransparency=1
    nl.Position=UDim2.new(0,6,0,2); nl.Size=UDim2.new(1,-8,0,14); nl.Font=Enum.Font.GothamBold
    nl.TextSize=11; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.TextStrokeTransparency=0.1
    nl.TextStrokeColor3=Color3.new(0,0,0); nl.TextTruncate=Enum.TextTruncate.AtEnd; nl.ZIndex=12
    local dl=Instance.new("TextLabel",f); dl.Name="DL"; dl.BackgroundTransparency=1
    dl.Position=UDim2.new(0,6,0,14); dl.Size=UDim2.new(1,-8,0,11); dl.Font=Enum.Font.Gotham
    dl.TextSize=9; dl.TextColor3=Color3.fromRGB(170,185,210); dl.TextXAlignment=Enum.TextXAlignment.Left
    dl.TextStrokeTransparency=0.2; dl.TextStrokeColor3=Color3.new(0,0,0); dl.ZIndex=12
    return f
end
for i=1,POOL do table.insert(lblPool,newLbl()) end

local function showLbl(cor,nome,dist,sx,sy)
    local f=table.remove(lblPool); if not f then return end
    f.Position=UDim2.new(0,sx-100,0,sy-14); f.Visible=true
    local nl=f:FindFirstChild("NL"); local dl=f:FindFirstChild("DL")
    if nl then nl.Text=nome; nl.TextColor3=cor end
    if dl then dl.Text=string.format("%.0fm",dist) end
    table.insert(actLbl,f)
end
local function relAll()
    for _,f in ipairs(actLbl) do f.Visible=false; table.insert(lblPool,f) end; actLbl={}
end

local entCache={}; local itmCache={}; local lastCache=0; local cacheBusy=false; local CACHE_I=5
local function isAlive(m)
    local h=m:FindFirstChildWhichIsA("Humanoid"); if not h or h.Health<=0 then return false end
    local hrp=m:FindFirstChild("HumanoidRootPart") or m:FindFirstChildWhichIsA("BasePart"); if not hrp then return false end
    return hrp.Position.Y>-400 and hrp.Position.Magnitude<6000
end
local function anyEsp(tipo)
    for _,c in ipairs(ESP_CATS) do if espAtivo[c.k] and c.tipo==tipo then return true end end; return false
end
local function buildCache()
    if cacheBusy then return end; local now=tick(); if now-lastCache<CACHE_I then return end
    lastCache=now; cacheBusy=true
    task.spawn(function()
        local ne={}; local ni={}
        local doE=anyEsp("entity"); local doI=anyEsp("item")
        if not doE and not doI then entCache=ne; itmCache=ni; cacheBusy=false; return end
        local ok,descs=pcall(function() return workspace:GetDescendants() end)
        if not ok then cacheBusy=false; return end
        local pchars={}; for _,pl in ipairs(Plrs:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end
        for i,obj in ipairs(descs) do
            if i%100==0 then task.wait() end
            if not obj or not obj.Parent then continue end
            local nl2=obj.Name:lower()
            if doE and obj:IsA("Model") and not pchars[obj] and isAlive(obj) then
                for _,c in ipairs(ESP_CATS) do
                    if espAtivo[c.k] and c.tipo=="entity" then
                        local lk=espLkp[c.k]; if lk and lk[nl2] then
                            local hrp2=obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
                            if hrp2 then table.insert(ne,{k=c.k,cor=c.cor,nome=obj.Name,alcance=c.alcance,obj=obj,hrp=hrp2}); break end
                        end
                    end
                end
            elseif doI and obj:IsA("BasePart") and not obj.Anchored and not pchars[obj] then
                for _,c in ipairs(ESP_CATS) do
                    if espAtivo[c.k] and c.tipo=="item" then
                        local lk=espLkp[c.k]; if lk and lk[nl2] then table.insert(ni,{k=c.k,cor=c.cor,nome=obj.Name,alcance=c.alcance,obj=obj}); break end
                    end
                end
            end
        end
        entCache=ne; itmCache=ni; cacheBusy=false
    end)
end

local dtA=0
RS.Heartbeat:Connect(function(dt)
    dtA+=dt; if dtA<0.05 then return end; dtA=0
    relAll()
    local any=false; for _,c in ipairs(ESP_CATS) do if espAtivo[c.k] then any=true; break end end
    if not any then return end
    pcall(buildCache)
    local myP=Vector3.zero
    pcall(function() local c=Plr.Character; if c and c:FindFirstChild("HumanoidRootPart") then myP=c.HumanoidRootPart.Position end end)
    local vp=Cam.ViewportSize; local seen={}
    if espAtivo["Players"] then
        for _,pl in ipairs(Plrs:GetPlayers()) do
            if pl~=Plr and pl.Character then pcall(function()
                local hrp2=pl.Character:FindFirstChild("HumanoidRootPart"); if not hrp2 then return end
                local h2=pl.Character:FindFirstChildWhichIsA("Humanoid"); if not h2 or h2.Health<=0 then return end
                local d=(hrp2.Position-myP).Magnitude
                local sp,vis=Cam:WorldToViewportPoint(hrp2.Position+Vector3.new(0,3,0))
                if not vis or sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
                local cel=math.floor(sp.X/12)..","..math.floor(sp.Y/12)
                if seen[cel] then return end; seen[cel]=true
                showLbl(Color3.fromRGB(255,80,80),pl.DisplayName,d,sp.X,sp.Y)
            end) end
        end
    end
    for _,e in ipairs(entCache) do pcall(function()
        if not espAtivo[e.k] or not e.obj or not e.obj.Parent then return end
        local h2=e.obj:FindFirstChildWhichIsA("Humanoid"); if not h2 or h2.Health<=0 then return end
        local pos=e.hrp.Position; local d=(pos-myP).Magnitude; if d>e.alcance then return end
        local sp,vis=Cam:WorldToViewportPoint(pos+Vector3.new(0,2.5,0))
        if not vis or sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
        local cel=math.floor(sp.X/12)..","..math.floor(sp.Y/12); if seen[cel] then return end; seen[cel]=true
        showLbl(e.cor,e.nome,d,sp.X,sp.Y)
    end) end
    for _,e in ipairs(itmCache) do pcall(function()
        if not espAtivo[e.k] or not e.obj or not e.obj.Parent or e.obj.Anchored then return end
        local pos=e.obj.Position; local d=(pos-myP).Magnitude; if d>e.alcance then return end
        local sp,vis=Cam:WorldToViewportPoint(pos+Vector3.new(0,0.8,0))
        if not vis or sp.X<-60 or sp.X>vp.X+60 or sp.Y<-40 or sp.Y>vp.Y+40 then return end
        local cel=math.floor(sp.X/10)..","..math.floor(sp.Y/10); if seen[cel] then return end; seen[cel]=true
        showLbl(e.cor,e.nome,d,sp.X,sp.Y)
    end) end
end)

-- UI ESP simples (toggle por categoria)
local eTabLO=0
local function eLO() eTabLO+=1; return eTabLO end
local function espSecUI(txt,cor)
    local h=Instance.new("Frame",Pages["Esp"]); h.BackgroundColor3=Color3.fromRGB(20,22,30); h.BackgroundTransparency=0.3
    h.BorderSizePixel=0; h.Size=UDim2.new(1,0,0,22); h.LayoutOrder=eLO(); h.ZIndex=4
    Instance.new("UICorner",h).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",h); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Position=UDim2.new(0,0,0,0); bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=5
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel",h); l.BackgroundTransparency=1; l.Position=UDim2.new(0,10,0,0)
    l.Size=UDim2.new(1,-14,1,0); l.Font=Enum.Font.GothamBlack; l.Text=txt; l.TextColor3=cor; l.TextSize=9; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
end
local function espRowUI(cat)
    local row=Instance.new("Frame",Pages["Esp"]); row.BackgroundColor3=Color3.fromRGB(30,32,38)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,52); row.LayoutOrder=eLO(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local rS=Instance.new("UIStroke",row); rS.Color=Color3.fromRGB(45,48,58); rS.Thickness=1
    local nl2=Instance.new("TextLabel",row); nl2.BackgroundTransparency=1
    nl2.Position=UDim2.new(0,12,0,8); nl2.Size=UDim2.new(1,-70,0,18); nl2.Font=Enum.Font.GothamBold
    nl2.Text=cat.label; nl2.TextColor3=Color3.fromRGB(220,225,240); nl2.TextSize=11; nl2.TextXAlignment=Enum.TextXAlignment.Left; nl2.ZIndex=6
    local dl2=Instance.new("TextLabel",row); dl2.BackgroundTransparency=1
    dl2.Position=UDim2.new(0,12,0,26); dl2.Size=UDim2.new(1,-70,0,20); dl2.Font=Enum.Font.Gotham
    dl2.Text=cat.desc or ""; dl2.TextColor3=Color3.fromRGB(80,95,115); dl2.TextSize=9
    dl2.TextXAlignment=Enum.TextXAlignment.Left; dl2.TextWrapped=true; dl2.ZIndex=6
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(45,50,62); pill.BorderSizePixel=0
    pill.Position=UDim2.new(1,-52,0.5,-11); pill.Size=UDim2.new(0,42,0,22); pill.ZIndex=7
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(160,170,185); knob.BorderSizePixel=0
    knob.Position=UDim2.new(0,2,0.5,-9); knob.Size=UDim2.new(0,18,0,18); knob.ZIndex=8
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local est=false
    local btn=Instance.new("TextButton",row); btn.BackgroundTransparency=1; btn.Size=UDim2.new(1,0,1,0); btn.Text=""; btn.ZIndex=9
    btn.MouseEnter:Connect(function() TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(34,37,45)}):Play() end)
    btn.MouseLeave:Connect(function() TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(30,32,38)}):Play() end)
    btn.MouseButton1Click:Connect(function()
        est=not est; espAtivo[cat.k]=est; lastCache=0
        TS:Create(pill,TweenInfo.new(0.22),{BackgroundColor3=est and cat.cor or Color3.fromRGB(45,50,62)}):Play()
        TS:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=est and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9),
            BackgroundColor3=est and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185),
        }):Play()
        TS:Create(rS,TweenInfo.new(0.2),{Color=est and cat.cor or Color3.fromRGB(45,48,58)}):Play()
    end)
end

local espGrps={
    {"ESP — Entidades",Color3.fromRGB(88,101,242),{"Players","Kids","AnimPassivo","AnimAgressivo","Monstros","Cultistas","Aliens"}},
    {"ESP — Recursos",Color3.fromRGB(255,130,40),{"EspLog","EspCombust","EspCarcacas","EspSucata","EspMateriais"}},
    {"ESP — Comida & Natureza",Color3.fromRGB(255,120,170),{"EspComidas","EspPeixes","EspSementes"}},
    {"ESP — Equipamentos",Color3.fromRGB(255,200,55),{"EspFerr","EspArmas","EspAmmo","EspCura","EspChaves"}},
}
local ecm={}; for _,c in ipairs(ESP_CATS) do ecm[c.k]=c end
for _,g in ipairs(espGrps) do
    espSecUI(g[1],g[2])
    for _,k in ipairs(g[3]) do if ecm[k] then espRowUI(ecm[k]) end end
end


-- ══════════════════════════════════════════════════════
--  BRING — 17 categorias
-- ══════════════════════════════════════════════════════
local BRING_CATS={
    {k="BLog",cor=Color3.fromRGB(190,130,60),label="🪵 Bring Log",desc="Log",nomes={"Log"}},
    {k="BCombust",cor=Color3.fromRGB(255,120,30),label="🔥 Bring Combustível",desc="Coal, Biofuel, Fuel Canister…",nomes={"Coal","Biofuel","Oil Barrel","OilBarrel","Fuel Canister","FuelCanister","Purple Fur Tuft","PurpleFurTuft","Chair"}},
    {k="BCarcacas",cor=Color3.fromRGB(180,100,50),label="🦴 Bring Carcaças",desc="Wolf/Bear/Mammoth Corpse…",nomes={"Wolf Corpse","WolfCorpse","Alpha Wolf Corpse","AlphaWolfCorpse","Bear Corpse","BearCorpse","Polar Bear Corpse","PolarBearCorpse","Arctic Fox Corpse","ArcticFoxCorpse","Mammoth Corpse","MammothCorpse","Hellephant Corpse","HellephantCorpse","Frog Corpse","FrogCorpse","Cultist Corpse","CultistCorpse","Crossbow Cultist Corpse","CrossbowCultistCorpse","Juggernaut Cultist Corpse","JuggernautCultistCorpse","Cultist King Corpse","CultistKingCorpse","Alien Corpse","AlienCorpse","Elite Alien Corpse","EliteAlienCorpse"}},
    {k="BSucata",cor=Color3.fromRGB(155,210,255),label="🔩 Bring Sucata",desc="Bolt, Sheet Metal, UFO Junk…",nomes={"Bolt","Sheet Metal","SheetMetal","UFO Junk","UFOJunk","UFO Component","UFOComponent","UFO Scrap","UFOScrap","Broken Fan","BrokenFan","Old Radio","OldRadio","Broken Radio","BrokenRadio","Broken Microwave","BrokenMicrowave","Tyre","Metal Chair","MetalChair","Old Car Engine","OldCarEngine","Washing Machine","WashingMachine","Cultist Experiment","CultistExperiment","Cultist Prototype","CultistPrototype"}},
    {k="BMateriais",cor=Color3.fromRGB(220,175,255),label="💎 Bring Materiais",desc="Cultist Gem, Forest Gem, Mossy Coin…",nomes={"Cultist Gem","CultistGem","Forest Gem","ForestGem","Forest Gem Fragment","ForestGemFragment","Mossy Coin","MossyCoin","Flower","Sapling","Sacrifice Totem","SacrificeTotem","Meteor Shard","MeteorShard","Gold Shard","GoldShard","Raw Obsidiron Ore","RawObsidironOre","Obsidiron Ingot","ObsidironIngot","Scalding Obsidiron Ingot"}},
    {k="BComidas",cor=Color3.fromRGB(255,115,165),label="🍖 Bring Comidas",desc="Carrot, Corn, Steak, Ribs, Stew…",nomes={"Carrot","Corn","Pumpkin","Berry","Apple","Chili","Cake","Morsel","Cooked Morsel","CookedMorsel","Steak","Cooked Steak","CookedSteak","Ribs","Cooked Ribs","CookedRibs","Stew","Hearty Stew","HeartyStew","Seafood Chowder","Steak Dinner","Pumpkin Soup","BBQ Ribs","Carrot Cake","Turkey Leg","Cooked Turkey Leg","Stuffing","Sweet Potato","Berry Juice","Casserole","Corn on the Cob","Roast Turkey","Stuffed Peppers","Sweet Potato Pie","Spicy Swordfish"}},
    {k="BPeixes",cor=Color3.fromRGB(80,180,255),label="🐟 Bring Peixes",desc="Mackerel, Salmon, Clownfish, Shark…",nomes={"Mackerel","Cooked Mackerel","CookedMackerel","Salmon","Cooked Salmon","CookedSalmon","Clownfish","Cooked Clownfish","CookedClownfish","Jellyfish","Char","Cooked Char","CookedChar","Eel","Cooked Eel","CookedEel","Swordfish","Cooked Swordfish","CookedSwordfish","Shark","Cooked Shark","CookedShark","Lava Eel","LavaEel","Cooked Lava Eel","CookedLavaEel","Lionfish","Cooked Lionfish","CookedLionfish"}},
    {k="BSementes",cor=Color3.fromRGB(135,245,115),label="🌱 Bring Sementes",desc="Chili, Berry, Flower, Dripleaf…",nomes={"Chili Seeds","ChiliSeeds","Flower Seeds","FlowerSeeds","Berry Seeds","BerrySeeds","Firefly Seeds","FireflySeeds","Dripleaf Seeds","DripleafSeeds","Moonflower Seeds","MoonflowerSeeds","Stareweed Seeds","StareweedSeeds","Cavevine Seeds","CavevineSeeds","Mandrake Seeds","MandrakeSeeds"}},
    {k="BFerr",cor=Color3.fromRGB(255,200,55),label="🪓 Bring Ferramentas",desc="Sacks, Axes, Rods, Flutes, Armaduras…",nomes={"Old Sack","OldSack","Good Sack","GoodSack","Infernal Sack","InfernalSack","Giant Sack","GiantSack","Old Axe","OldAxe","Good Axe","GoodAxe","Ice Axe","IceAxe","Strong Axe","StrongAxe","Chainsaw","Old Rod","OldRod","Good Rod","GoodRod","Strong Rod","StrongRod","Old Taming Flute","OldFlute","Good Taming Flute","GoodFlute","Strong Taming Flute","StrongFlute","Old Flashlight","OldFlashlight","Strong Flashlight","StrongFlashlight","Hammer","Paint Brush","PaintBrush","Watering Can","WateringCan","Leather Body","LeatherBody","Alien Armour","AlienArmour","Frog Boots","FrogBoots","Poison Armour","PoisonArmour"}},
    {k="BArmas",cor=Color3.fromRGB(255,70,70),label="⚔️ Bring Armas",desc="Spear, Ice Sword, Crossbow, Revolver…",nomes={"Spear","Morningstar","Katana","Laser Sword","LaserSword","Ice Sword","IceSword","Trident","Poison Spear","PoisonSpear","Infernal Sword","InfernalSword","Obsidiron Hammer","ObsidironHammer","Scythe","Crossbow","Infernal Crossbow","InfernalCrossbow","Bouncing Blade","BouncingBlade","Vampire Scythe","VampireScythe","Revolver","Rifle","Tactical Shotgun","TacticalShotgun","Ray Gun","RayGun","Laser Cannon","LaserCannon","Flamethrower","Snowball","Frozen Shuriken","FrozenShuriken","Kunai","Witch Potion","WitchPotion","Wildfire","Blowpipe","Air Rifle","AirRifle"}},
    {k="BAmmo",cor=Color3.fromRGB(255,155,60),label="🔫 Bring Munição",desc="Revolver, Rifle, Shotgun Ammo",nomes={"Revolver Ammo","RevolverAmmo","Rifle Ammo","RifleAmmo","Shotgun Ammo","ShotgunAmmo"}},
    {k="BCura",cor=Color3.fromRGB(100,255,180),label="💊 Bring Cura",desc="Bandage, Medkit",nomes={"Bandage","Medkit"}},
    {k="BPelts",cor=Color3.fromRGB(210,170,120),label="🦺 Bring Pelts",desc="Bunny Foot, Wolf/Bear/Arctic Pelt…",nomes={"Bunny Foot","BunnyFoot","Wolf Pelt","WolfPelt","Alpha Wolf Pelt","AlphaWolfPelt","Bear Pelt","BearPelt","Arctic Fox Pelt","ArcticFoxPelt","Polar Bear Pelt","PolarBearPelt","Mammoth Tusk","MammothTusk","Scorpion Shell","ScorpionShell","Cultist King Antler","CultistKingAntler"}},
    {k="BChaves",cor=Color3.fromRGB(255,230,80),label="🗝️ Bring Chaves",desc="Red, Blue, Yellow, Grey, Frog Key",nomes={"Red Key","RedKey","Blue Key","BlueKey","Yellow Key","YellowKey","Grey Key","GreyKey","Frog Key","FrogKey"}},
    {k="BBigorna",cor=Color3.fromRGB(200,160,255),label="⚙️ Bring Bigorna",desc="Anvil Front/Back/Base + Meteor Anvil",nomes={"Anvil Front","AnvilFront","Anvil Back","AnvilBack","Anvil Base","AnvilBase","Meteor Anvil Front","MeteorAnvilFront","Meteor Anvil Back","MeteorAnvilBack","Meteor Anvil Base","MeteorAnvilBase"}},
    {k="BPocoes",cor=Color3.fromRGB(195,100,255),label="🧪 Bring Poções",desc="Dripleaf, Moonflower Bulb, Mandrake…",nomes={"Dripleaf","Moonflower Bulb","MoonflowerBulb","Stareweed Petal","StareweedPetal","Cave Vine Flower","CaveVineFlower","Mandrake"}},
    {k="BBlueprint",cor=Color3.fromRGB(130,190,255),label="📋 Bring Blueprints",desc="Crafting, Defense, Furniture, Obsidiron…",nomes={"Crafting Blueprint","CraftingBlueprint","Defense Blueprint","DefenseBlueprint","Furniture Blueprint","FurnitureBlueprint","Obsidiron Chest Blueprint","ObsidironChestBlueprint","Halloween Blueprint","HalloweenBlueprint"}},
}

local bLkp={}
for _,c in ipairs(BRING_CATS) do local s={}; for _,n in ipairs(c.nomes) do s[n:lower()]=true end; bLkp[c.k]=s end

local function execBring(key)
    local ch=Plr.Character; if not ch then return 0 end
    local hrp2=ch:FindFirstChild("HumanoidRootPart"); if not hrp2 then return 0 end
    local lk=bLkp[key]; if not lk then return 0 end
    local cf=hrp2.CFrame; local cnt=0; local pchars={}
    for _,pl in ipairs(Plrs:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end
    local ok,descs=pcall(function() return workspace:GetDescendants() end); if not ok then return 0 end
    for i,obj in ipairs(descs) do
        if i%100==0 then task.wait(); ch=Plr.Character; if not ch then break end; hrp2=ch:FindFirstChild("HumanoidRootPart"); if not hrp2 then break end; cf=hrp2.CFrame end
        pcall(function()
            if not obj or not obj.Parent or not obj:IsA("BasePart") or obj.Anchored then return end
            for pc in pairs(pchars) do if pc==obj or pc:IsAncestorOf(obj) then return end end
            local p2=obj.Parent
            for _=1,3 do if p2 and p2:IsA("Model") and p2:FindFirstChildWhichIsA("Humanoid") then return end; p2=p2 and p2.Parent end
            if not lk[obj.Name:lower()] then return end
            local sz=obj.Size; if sz.X>14 or sz.Y>14 or sz.Z>14 then return end
            local spread=Vector3.new(math.random(-4,4),0.5,math.random(-4,4))
            local target=cf.Position+spread
            for _,sc in ipairs(obj:GetChildren()) do if sc:IsA("Script") or sc:IsA("LocalScript") then pcall(function() sc.Disabled=true end) end end
            obj.CFrame=CFrame.new(target); obj.Velocity=Vector3.zero; cnt+=1
        end)
    end
    return cnt
end

-- UI Bring
local bTabLO=0
local function bLO() bTabLO+=1; return bTabLO end
local function bSecUI(txt,cor)
    local h=Instance.new("Frame",Pages["Bring"]); h.BackgroundColor3=Color3.fromRGB(20,22,30); h.BackgroundTransparency=0.3
    h.BorderSizePixel=0; h.Size=UDim2.new(1,0,0,22); h.LayoutOrder=bLO(); h.ZIndex=4
    Instance.new("UICorner",h).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",h); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Position=UDim2.new(0,0,0,0); bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=5
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel",h); l.BackgroundTransparency=1; l.Position=UDim2.new(0,10,0,0)
    l.Size=UDim2.new(1,-14,1,0); l.Font=Enum.Font.GothamBlack; l.Text=txt; l.TextColor3=cor; l.TextSize=9; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
end
local function bRowUI(bc)
    local row=Instance.new("Frame",Pages["Bring"]); row.BackgroundColor3=Color3.fromRGB(28,30,36)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,58); row.LayoutOrder=bLO(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local rS=Instance.new("UIStroke",row); rS.Color=Color3.fromRGB(42,46,56); rS.Thickness=1
    local gb2=Instance.new("Frame",row); gb2.BackgroundColor3=bc.cor; gb2.BackgroundTransparency=0.9
    gb2.BorderSizePixel=0; gb2.Size=UDim2.new(1,0,1,0); gb2.ZIndex=5
    Instance.new("UICorner",gb2).CornerRadius=UDim.new(0,9)
    local bl2=Instance.new("Frame",row); bl2.BackgroundColor3=bc.cor; bl2.BorderSizePixel=0
    bl2.Position=UDim2.new(0,0,0.15,0); bl2.Size=UDim2.new(0,3,0.7,0); bl2.ZIndex=8
    Instance.new("UICorner",bl2).CornerRadius=UDim.new(0,2)
    local nl2=Instance.new("TextLabel",row); nl2.BackgroundTransparency=1
    nl2.Position=UDim2.new(0,14,0,8); nl2.Size=UDim2.new(1,-100,0,18); nl2.Font=Enum.Font.GothamBold
    nl2.Text=bc.label; nl2.TextColor3=Color3.fromRGB(225,230,245); nl2.TextSize=11; nl2.TextXAlignment=Enum.TextXAlignment.Left; nl2.ZIndex=7
    local dl2=Instance.new("TextLabel",row); dl2.BackgroundTransparency=1
    dl2.Position=UDim2.new(0,14,0,26); dl2.Size=UDim2.new(1,-100,0,24); dl2.Font=Enum.Font.Gotham
    dl2.Text=bc.desc or ""; dl2.TextColor3=Color3.fromRGB(80,95,115); dl2.TextSize=9; dl2.TextXAlignment=Enum.TextXAlignment.Left; dl2.TextWrapped=true; dl2.ZIndex=7
    local feedL=Instance.new("TextLabel",row); feedL.BackgroundTransparency=1
    feedL.Position=UDim2.new(1,-82,0.5,14); feedL.Size=UDim2.new(0,74,0,12); feedL.Font=Enum.Font.Gotham
    feedL.Text=""; feedL.TextColor3=bc.cor; feedL.TextSize=8; feedL.TextXAlignment=Enum.TextXAlignment.Center; feedL.ZIndex=8
    local bBtn=Instance.new("TextButton",row); bBtn.BackgroundColor3=bc.cor; bBtn.BackgroundTransparency=0.15
    bBtn.BorderSizePixel=0; bBtn.Position=UDim2.new(1,-82,0.5,-14); bBtn.Size=UDim2.new(0,74,0,28)
    bBtn.Font=Enum.Font.GothamBold; bBtn.Text="▼ BRING"; bBtn.TextColor3=Color3.fromRGB(255,255,255); bBtn.TextSize=10; bBtn.ZIndex=9
    Instance.new("UICorner",bBtn).CornerRadius=UDim.new(0,7)
    bBtn.MouseEnter:Connect(function() TS:Create(bBtn,TweenInfo.new(0.12),{BackgroundTransparency=0}):Play() end)
    bBtn.MouseLeave:Connect(function() TS:Create(bBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.15}):Play() end)
    local running=false
    bBtn.MouseButton1Click:Connect(function()
        if running then return end; running=true; bBtn.Text="⏳..."
        task.spawn(function()
            local cnt=execBring(bc.k) or 0; task.wait(0.3)
            bBtn.Text="▼ BRING"
            if cnt>0 then
                feedL.Text="✓ "..cnt.." item(s)"; feedL.TextColor3=bc.cor; feedL.TextTransparency=0
                task.delay(3,function() TS:Create(feedL,TweenInfo.new(0.5),{TextTransparency=1}):Play(); task.wait(0.6); feedL.Text=""; feedL.TextTransparency=0 end)
            else
                feedL.Text="✗ Nenhum item"; feedL.TextColor3=Color3.fromRGB(200,80,80); feedL.TextTransparency=0
                task.delay(2.5,function() TS:Create(feedL,TweenInfo.new(0.4),{TextTransparency=1}):Play(); task.wait(0.5); feedL.Text=""; feedL.TextTransparency=0; feedL.TextColor3=bc.cor end)
            end
            task.wait(1); running=false
        end)
    end)
    row.MouseEnter:Connect(function() TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(33,36,44)}):Play() end)
    row.MouseLeave:Connect(function() TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,30,36)}):Play() end)
end
local bGrps={
    {"BRING — Combustível & Recursos",Color3.fromRGB(255,130,40),{"BLog","BCombust","BCarcacas","BSucata","BMateriais"}},
    {"BRING — Comida & Natureza",Color3.fromRGB(255,120,170),{"BComidas","BPeixes","BSementes","BPocoes"}},
    {"BRING — Equipamentos",Color3.fromRGB(255,200,55),{"BFerr","BArmas","BAmmo","BCura","BPelts"}},
    {"BRING — Especiais",Color3.fromRGB(255,230,80),{"BChaves","BBigorna","BBlueprint"}},
}
local bcm={}; for _,c in ipairs(BRING_CATS) do bcm[c.k]=c end
for _,g in ipairs(bGrps) do
    bSecUI(g[1],g[2])
    for _,k in ipairs(g[3]) do if bcm[k] then bRowUI(bcm[k]) end end
end


-- ══════════════════════════════════════════════════════
--  AIMBOT
-- ══════════════════════════════════════════════════════
local ANS={}
for _,n in ipairs({"wolf","alpha wolf","alphawolf","bear","polar bear","polarbear","arctic fox","arcticfox","frog","blue frog","purple frog","green frog","scorpion","hellephant","meteor crab","meteorcrab","mammoth","bunny","horse","kiwi","turkey","alien","elite alien","elitealien"}) do ANS[n]=true end

local function findAnim()
    local ch=Plr.Character; if not ch then return nil end
    local hrp2=ch:FindFirstChild("HumanoidRootPart"); if not hrp2 then return nil end
    local myP=hrp2.Position; local best,bd=nil,math.huge
    local pchars={}; for _,pl in ipairs(Plrs:GetPlayers()) do if pl.Character then pchars[pl.Character]=true end end
    for _,obj in ipairs(workspace:GetDescendants()) do pcall(function()
        if not obj:IsA("Model") or pchars[obj] then return end
        local h2=obj:FindFirstChildWhichIsA("Humanoid"); if not h2 or h2.Health<=0 then return end
        if not ANS[obj.Name:lower()] then return end
        local ah=obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart"); if not ah then return end
        local d=(ah.Position-myP).Magnitude; if d<bd then bd=d; best=ah end
    end) end
    return best
end

local aimOn=false
workspace.DescendantAdded:Connect(function(obj)
    if not aimOn then return end
    task.defer(function()
        if not obj or not obj.Parent or not obj:IsA("BasePart") then return end
        local spd=obj.AssemblyLinearVelocity.Magnitude; if spd<8 then return end
        local par=obj.Parent
        for _=1,3 do
            if par and par:IsA("Model") then
                local h2=par:FindFirstChildWhichIsA("Humanoid")
                if h2 then
                    local isPlr=false; for _,pl in ipairs(Plrs:GetPlayers()) do if pl.Character==par then isPlr=true; break end end
                    if not isPlr then return end
                end
            end
            par=par and par.Parent
        end
        local tgt=findAnim(); if not tgt then return end
        local steps=0
        local conn; conn=RS.Heartbeat:Connect(function()
            steps+=1; if not aimOn or not obj or not obj.Parent or steps>150 then conn:Disconnect(); return end
            if not tgt or not tgt.Parent then tgt=findAnim(); if not tgt then conn:Disconnect(); return end end
            local dir2=tgt.Position-obj.Position; if dir2.Magnitude<2 then conn:Disconnect(); return end
            obj.AssemblyLinearVelocity=dir2.Unit*math.max(spd,80)
        end)
    end)
end)

local aimAutoOn=false; local aimAutoRun=false
local RANGED_SET2={}
for _,n in ipairs({"revolver","rifle","tactical shotgun","tacticalshotgun","ray gun","raygun","laser cannon","lasercannon","flamethrower","crossbow","infernal crossbow","infernalcrossbow","blowpipe","air rifle","airrifle","snowball","bouncing blade","bouncingblade","witch potion","witchpotion","wildfire","frozen shuriken","frozenshuriken","kunai"}) do RANGED_SET2[n]=true end

local function getEquip()
    local ch=Plr.Character; if not ch then return nil end
    for _,o in ipairs(ch:GetChildren()) do if o:IsA("Tool") and RANGED_SET2[o.Name:lower()] then return o end end
end
local function startAimAuto()
    if aimAutoRun then return end; aimAutoRun=true
    task.spawn(function()
        while aimAutoOn do
            task.wait(0.12); pcall(function()
                local tool=getEquip(); if not tool then return end
                local tgt=findAnim(); if not tgt then return end
                local ch=Plr.Character; if not ch then return end
                local hrp2=ch:FindFirstChild("HumanoidRootPart"); if not hrp2 then return end
                local tPos=tgt.Position+Vector3.new(0,1,0)
                local sp,onS=Cam:WorldToScreenPoint(tPos); if not onS then return end
                local dir2=(tgt.Position-hrp2.Position); local flat=Vector3.new(dir2.X,0,dir2.Z).Unit
                local yaw=math.atan2(flat.X,flat.Z)
                hrp2.CFrame=CFrame.new(hrp2.Position)*CFrame.Angles(0,yaw+math.pi,0)
                local fired=false
                for _,child in ipairs(tool:GetChildren()) do
                    if child:IsA("RemoteEvent") then pcall(function() child:FireServer(tPos) end); fired=true; break end
                end
                if not fired then pcall(function()
                    local vim=game:GetService("VirtualInputManager")
                    vim:SendMouseButtonEvent(math.floor(sp.X),math.floor(sp.Y),0,true,game,0)
                    task.wait(0.03); vim:SendMouseButtonEvent(math.floor(sp.X),math.floor(sp.Y),0,false,game,0)
                end) end
            end)
        end
        aimAutoRun=false
    end)
end

-- UI Avançado Funções
local afLO=0; local function aflo() afLO+=1; return afLO end
local function afSec(txt,cor)
    local h=Instance.new("Frame",Pages["AvFunc"]); h.BackgroundColor3=Color3.fromRGB(20,22,30); h.BackgroundTransparency=0.3
    h.BorderSizePixel=0; h.Size=UDim2.new(1,0,0,22); h.LayoutOrder=aflo(); h.ZIndex=4
    Instance.new("UICorner",h).CornerRadius=UDim.new(0,6)
    local bar=Instance.new("Frame",h); bar.BackgroundColor3=cor; bar.BorderSizePixel=0
    bar.Position=UDim2.new(0,0,0,0); bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=5
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel",h); l.BackgroundTransparency=1; l.Position=UDim2.new(0,10,0,0)
    l.Size=UDim2.new(1,-14,1,0); l.Font=Enum.Font.GothamBlack; l.Text=txt; l.TextColor3=cor; l.TextSize=9; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
end
local function afRow(lbl,desc,cor,onTgl)
    local row=Instance.new("Frame",Pages["AvFunc"]); row.BackgroundColor3=Color3.fromRGB(28,30,38)
    row.BorderSizePixel=0; row.Size=UDim2.new(1,0,0,76); row.LayoutOrder=aflo(); row.ZIndex=5
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local rS=Instance.new("UIStroke",row); rS.Color=Color3.fromRGB(42,46,58); rS.Thickness=1
    local gb2=Instance.new("Frame",row); gb2.BackgroundColor3=cor; gb2.BackgroundTransparency=0.88
    gb2.BorderSizePixel=0; gb2.Size=UDim2.new(1,0,1,0); gb2.ZIndex=5
    Instance.new("UICorner",gb2).CornerRadius=UDim.new(0,9)
    local nl2=Instance.new("TextLabel",row); nl2.BackgroundTransparency=1
    nl2.Position=UDim2.new(0,14,0,8); nl2.Size=UDim2.new(1,-80,0,18); nl2.Font=Enum.Font.GothamBlack
    nl2.Text=lbl; nl2.TextColor3=Color3.fromRGB(230,235,255); nl2.TextSize=12; nl2.TextXAlignment=Enum.TextXAlignment.Left; nl2.ZIndex=7
    local dl2=Instance.new("TextLabel",row); dl2.BackgroundTransparency=1
    dl2.Position=UDim2.new(0,14,0,28); dl2.Size=UDim2.new(1,-80,0,40); dl2.Font=Enum.Font.Gotham
    dl2.Text=desc; dl2.TextColor3=Color3.fromRGB(90,105,128); dl2.TextSize=9; dl2.TextXAlignment=Enum.TextXAlignment.Left; dl2.TextWrapped=true; dl2.ZIndex=7
    local pill=Instance.new("Frame",row); pill.BackgroundColor3=Color3.fromRGB(45,50,62)
    pill.BorderSizePixel=0; pill.Position=UDim2.new(1,-58,0.5,-13); pill.Size=UDim2.new(0,50,0,26); pill.ZIndex=9
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",pill); knob.BackgroundColor3=Color3.fromRGB(160,170,185)
    knob.BorderSizePixel=0; knob.Position=UDim2.new(0,2,0.5,-11); knob.Size=UDim2.new(0,22,0,22); knob.ZIndex=10
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local est=false
    local pb=Instance.new("TextButton",row); pb.BackgroundTransparency=1
    pb.Position=UDim2.new(1,-62,0.5,-17); pb.Size=UDim2.new(0,56,0,34); pb.Text=""; pb.ZIndex=11
    pb.MouseButton1Click:Connect(function()
        est=not est
        TS:Create(pill,TweenInfo.new(0.22),{BackgroundColor3=est and cor or Color3.fromRGB(45,50,62)}):Play()
        TS:Create(knob,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
            Position=est and UDim2.new(1,-24,0.5,-11) or UDim2.new(0,2,0.5,-11),
            BackgroundColor3=est and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,170,185)
        }):Play()
        TS:Create(rS,TweenInfo.new(0.2),{Color=est and cor or Color3.fromRGB(42,46,58)}):Play()
        onTgl(est)
    end)
    row.MouseEnter:Connect(function() TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(33,36,48)}):Play() end)
    row.MouseLeave:Connect(function() TS:Create(row,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(28,30,38)}):Play() end)
end

afSec("🎯 AIMBOT — COMBATE AUTOMÁTICO",Color3.fromRGB(255,60,80))
afRow("🎯 Aimbot Teleguiado","Projéteis de TODAS as armas são teleguiados para o animal mais próximo. Funciona enquanto o projétil existe no workspace. 100% de acerto garantido.",Color3.fromRGB(255,60,80),function(s) aimOn=s end)
afRow("🤖 Aimbot AUTO","Com arma ranged equipada, dispara sozinho nos animais mais próximos. Usa VirtualInputManager invisível. Detecta Revolver, Rifle, Shotgun, Ray Gun, Crossbow e mais.",Color3.fromRGB(255,140,30),function(s) aimAutoOn=s; if s then startAimAuto() end end)


-- ══════════════════════════════════════════════════════
--  ABA TP — Teleporte dinâmico por bioma
-- ══════════════════════════════════════════════════════
local BIOMAS={
    {e="🌲",n="Floresta",     s={"forest","forestzone","mainforest","woodzone","treezone","floresta","wooded"}},
    {e="❄️",n="Neve",         s={"snow","snowzone","arctic","tundra","icezone","winter","blizzard","snowbiome","frostzone"}},
    {e="🌋",n="Vulcão",       s={"volcano","volcanozone","lava","lavazone","volcanic","magma","firezone","molten"}},
    {e="🏜️",n="Deserto",      s={"desert","desertzone","sand","sandzone","dune","arid","scorched"}},
    {e="🌿",n="Pântano",      s={"swamp","swampzone","marsh","bog","bayou","wetland","pantano"}},
    {e="🌊",n="Oceano",       s={"ocean","sea","oceanzone","beach","shore","coast","seazone"}},
    {e="🕳️",n="Caverna",      s={"cave","cavezone","underground","dungeon","cavern","grotto","underworld"}},
    {e="🌾",n="Pradaria",     s={"meadow","plains","grassland","prairie","field","pasture"}},
    {e="🌴",n="Selva",        s={"jungle","junglezone","rainforest","tropics","tropiczone"}},
    {e="🏛️",n="Ruínas",       s={"ruins","ancient","temple","monument","ruin","remnants"}},
    {e="⛰️",n="Montanha",     s={"mountain","mountains","highlands","peak","summit","hill","cliff"}},
    {e="🏕️",n="Base/Spawn",   s={"base","camp","spawn","playerbase","homebase","start","hub","village"}},
    {e="🔥",n="Inferno",      s={"hell","inferno","firezone","burning","hellzone"}},
    {e="🌙",n="Zona Noturna", s={"night","dark","nightzone","darkzone","shadow","shadowzone"}},
    {e="🌌",n="Astral",       s={"astral","space","cosmic","sky","cloud","void","aether"}},
}

local function findBioma(b)
    local best=nil; local bp=0
    for _,obj in ipairs(workspace:GetDescendants()) do pcall(function()
        local n=obj.Name:lower()
        for pri,kw in ipairs(b.s) do
            local kl=kw:lower()
            if n==kl or n==kl.."zone" or n==kl.."area" or n==kl.."biome" then
                local pos
                if obj:IsA("BasePart") then pos=obj.Position
                elseif obj:IsA("Model") then local pp=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"); if pp then pos=pp.Position end end
                if pos and pos.Y>-100 and pos.Magnitude<10000 then
                    local myp=(pri==1) and 100 or (50-pri)
                    if myp>bp then bp=myp; best=pos end
                end
            elseif n:find(kl) and pri<=3 then
                local pos
                if obj:IsA("BasePart") then pos=obj.Position
                elseif obj:IsA("Model") then local pp=obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"); if pp then pos=pp.Position end end
                if pos and pos.Y>-100 and pos.Magnitude<10000 then
                    local myp=10-pri; if myp>bp then bp=myp; best=pos end
                end
            end
        end
    end) end
    return best
end

local function tpBioma(pos,nome,feedLbl)
    if not pos then
        if feedLbl then feedLbl.Text="✗ "..nome.." não encontrado"; feedLbl.TextColor3=Color3.fromRGB(255,80,80)
            task.delay(3,function() feedLbl.Text="" end) end; return
    end
    local ch=Plr.Character; if not ch then return end
    local hrp2=ch:FindFirstChild("HumanoidRootPart"); if not hrp2 then return end
    hrp2.CFrame=CFrame.new(pos.X,math.max(pos.Y+5,-50),pos.Z)
    if feedLbl then feedLbl.Text="✓ Teleportado → "..nome; feedLbl.TextColor3=Color3.fromRGB(87,242,135)
        task.delay(3.5,function() feedLbl.Text="" end) end
end

-- UI da aba Tp
local selBioma=nil; local tpPopOpen=false

-- Header info
local tpInfo=Instance.new("Frame",Pages["Tp"])
tpInfo.BackgroundColor3=Color3.fromRGB(20,22,32); tpInfo.BackgroundTransparency=0.3
tpInfo.BorderSizePixel=0; tpInfo.Size=UDim2.new(1,0,0,42); tpInfo.LayoutOrder=1; tpInfo.ZIndex=4
Instance.new("UICorner",tpInfo).CornerRadius=UDim.new(0,8)
local tpInfoS=Instance.new("UIStroke",tpInfo); tpInfoS.Color=CA; tpInfoS.Thickness=1
local tpIL=Instance.new("TextLabel",tpInfo); tpIL.BackgroundTransparency=1
tpIL.Position=UDim2.new(0,10,0,4); tpIL.Size=UDim2.new(1,-20,1,-8); tpIL.Font=Enum.Font.Gotham; tpIL.TextWrapped=true; tpIL.ZIndex=5
tpIL.Text="🗺️  Teleporte para qualquer bioma  |  Detecção dinâmica — funciona mesmo que as posições mudem entre partidas"
tpIL.TextColor3=Color3.fromRGB(150,165,255); tpIL.TextSize=9; tpIL.TextXAlignment=Enum.TextXAlignment.Left; tpIL.TextYAlignment=Enum.TextYAlignment.Center

-- Seção
local tpSec2=Instance.new("Frame",Pages["Tp"])
tpSec2.BackgroundColor3=Color3.fromRGB(20,22,30); tpSec2.BackgroundTransparency=0.3
tpSec2.BorderSizePixel=0; tpSec2.Size=UDim2.new(1,0,0,22); tpSec2.LayoutOrder=2; tpSec2.ZIndex=4
Instance.new("UICorner",tpSec2).CornerRadius=UDim.new(0,6)
do local b=Instance.new("Frame",tpSec2); b.BackgroundColor3=CA; b.BorderSizePixel=0
    b.Position=UDim2.new(0,0,0,0); b.Size=UDim2.new(0,3,1,0); b.ZIndex=5
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel",tpSec2); l.BackgroundTransparency=1
    l.Position=UDim2.new(0,10,0,0); l.Size=UDim2.new(1,-14,1,0); l.Font=Enum.Font.GothamBlack
    l.Text="🌍 TP BIOMAS — 99 Nights in the Forest"; l.TextColor3=CA; l.TextSize=9; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
end

-- Painel seletor
local tpPanel=Instance.new("Frame",Pages["Tp"])
tpPanel.BackgroundColor3=Color3.fromRGB(24,26,34); tpPanel.BackgroundTransparency=0.25
tpPanel.BorderSizePixel=0; tpPanel.Size=UDim2.new(1,0,0,52); tpPanel.LayoutOrder=3; tpPanel.ZIndex=5
Instance.new("UICorner",tpPanel).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",tpPanel).Color=Color3.fromRGB(55,60,80)

local selBtn=Instance.new("TextButton",tpPanel)
selBtn.BackgroundColor3=Color3.fromRGB(32,35,50); selBtn.BackgroundTransparency=0.1
selBtn.BorderSizePixel=0; selBtn.Position=UDim2.new(0,8,0.5,-18); selBtn.Size=UDim2.new(0.62,-12,0,36)
selBtn.Font=Enum.Font.GothamSemibold; selBtn.Text="🌍  Selecionar Bioma ▾"
selBtn.TextColor3=Color3.fromRGB(160,170,200); selBtn.TextSize=10; selBtn.ZIndex=6
Instance.new("UICorner",selBtn).CornerRadius=UDim.new(0,8)
local selS2=Instance.new("UIStroke",selBtn); selS2.Color=CA; selS2.Thickness=1.2; selS2.Transparency=0.5

local tpBtn=Instance.new("TextButton",tpPanel)
tpBtn.BackgroundColor3=CA; tpBtn.BackgroundTransparency=0.15
tpBtn.BorderSizePixel=0; tpBtn.Position=UDim2.new(0.62,4,0.5,-18); tpBtn.Size=UDim2.new(0.38,-12,0,36)
tpBtn.Font=Enum.Font.GothamBold; tpBtn.Text="⚡ Teleportar"
tpBtn.TextColor3=Color3.fromRGB(255,255,255); tpBtn.TextSize=10; tpBtn.ZIndex=6
Instance.new("UICorner",tpBtn).CornerRadius=UDim.new(0,8)

-- Feedback
local feedPanel=Instance.new("Frame",Pages["Tp"])
feedPanel.BackgroundTransparency=1; feedPanel.BorderSizePixel=0
feedPanel.Size=UDim2.new(1,0,0,28); feedPanel.LayoutOrder=4; feedPanel.ZIndex=4
local feedL2=Instance.new("TextLabel",feedPanel); feedL2.BackgroundTransparency=1
feedL2.Size=UDim2.new(1,0,1,0); feedL2.Font=Enum.Font.GothamSemibold; feedL2.Text=""
feedL2.TextColor3=Color3.fromRGB(200,200,255); feedL2.TextSize=10; feedL2.ZIndex=5

-- Grid de biomas 3 colunas
local gridSec=Instance.new("Frame",Pages["Tp"])
gridSec.BackgroundColor3=Color3.fromRGB(20,22,30); gridSec.BackgroundTransparency=0.3
gridSec.BorderSizePixel=0; gridSec.Size=UDim2.new(1,0,0,22); gridSec.LayoutOrder=5; gridSec.ZIndex=4
Instance.new("UICorner",gridSec).CornerRadius=UDim.new(0,6)
do local b=Instance.new("Frame",gridSec); b.BackgroundColor3=CA; b.BorderSizePixel=0
    b.Position=UDim2.new(0,0,0,0); b.Size=UDim2.new(0,3,1,0); b.ZIndex=5
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    local l=Instance.new("TextLabel",gridSec); l.BackgroundTransparency=1
    l.Position=UDim2.new(0,10,0,0); l.Size=UDim2.new(1,-14,1,0); l.Font=Enum.Font.GothamBlack
    l.Text="⚡ Acesso Rápido — Clique para TP direto"; l.TextColor3=CA; l.TextSize=9; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=5
end

local gridFrame=Instance.new("Frame",Pages["Tp"])
gridFrame.BackgroundTransparency=1; gridFrame.BorderSizePixel=0; gridFrame.LayoutOrder=6; gridFrame.ZIndex=4
gridFrame.Size=UDim2.new(1,0,0,0); gridFrame.AutomaticSize=Enum.AutomaticSize.Y
local gridLayout=Instance.new("UIGridLayout",gridFrame)
gridLayout.CellSize=UDim2.new(0.333,-4,0,48); gridLayout.CellPaddingSize=UDim2.new(0,4,0,4)
gridLayout.SortOrder=Enum.SortOrder.LayoutOrder; gridLayout.FillDirection=Enum.FillDirection.Horizontal

for _,bioma in ipairs(BIOMAS) do
    local card=Instance.new("TextButton",gridFrame); card.BackgroundColor3=Color3.fromRGB(26,28,40)
    card.BackgroundTransparency=0.15; card.BorderSizePixel=0; card.Text=""
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,8)
    local cS=Instance.new("UIStroke",card); cS.Color=Color3.fromRGB(45,50,72); cS.Thickness=1
    local em=Instance.new("TextLabel",card); em.BackgroundTransparency=1; em.Size=UDim2.new(1,0,0,22)
    em.Position=UDim2.new(0,0,0,4); em.Font=Enum.Font.GothamBold; em.Text=bioma.e; em.TextSize=16; em.ZIndex=5
    local nm=Instance.new("TextLabel",card); nm.BackgroundTransparency=1; nm.Size=UDim2.new(1,-4,0,14)
    nm.Position=UDim2.new(0,2,0,26); nm.Font=Enum.Font.Gotham; nm.Text=bioma.n
    nm.TextColor3=Color3.fromRGB(180,190,215); nm.TextSize=8; nm.TextTruncate=Enum.TextTruncate.AtEnd; nm.ZIndex=5
    card.MouseEnter:Connect(function()
        TS:Create(card,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(38,42,65),BackgroundTransparency=0}):Play()
        TS:Create(cS,TweenInfo.new(0.12),{Color=CA}):Play()
    end)
    card.MouseLeave:Connect(function()
        TS:Create(card,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(26,28,40),BackgroundTransparency=0.15}):Play()
        TS:Create(cS,TweenInfo.new(0.12),{Color=Color3.fromRGB(45,50,72)}):Play()
    end)
    local capB=bioma
    card.MouseButton1Click:Connect(function()
        selBioma=capB; selBtn.Text=capB.e.."  "..capB.n.." ▾"; selBtn.TextColor3=Color3.fromRGB(220,230,255)
        tpBtn.Text="⚡ TP "..capB.n
        TS:Create(card,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(45,50,80)}):Play()
        task.delay(0.3,function() TS:Create(card,TweenInfo.new(0.3),{BackgroundColor3=Color3.fromRGB(26,28,40),BackgroundTransparency=0.15}):Play() end)
        feedL2.Text="⏳ Procurando "..capB.n.."..."; feedL2.TextColor3=Color3.fromRGB(200,200,255)
        task.spawn(function()
            local pos=findBioma(capB); tpBioma(pos,capB.n,feedL2)
        end)
    end)
end

-- Popup dropdown (no ScreenGui para ficar na frente)
local tpPopup=Instance.new("Frame",SGui)
tpPopup.BackgroundColor3=Color3.fromRGB(22,24,34); tpPopup.BackgroundTransparency=0.06
tpPopup.BorderSizePixel=0; tpPopup.Size=UDim2.new(0,220,0,0); tpPopup.Visible=false; tpPopup.ZIndex=300; tpPopup.ClipsDescendants=true
Instance.new("UICorner",tpPopup).CornerRadius=UDim.new(0,10)
local tpPopS=Instance.new("UIStroke",tpPopup); tpPopS.Color=CA; tpPopS.Thickness=1.5

local tpPopScr=Instance.new("ScrollingFrame",tpPopup)
tpPopScr.BackgroundTransparency=1; tpPopScr.BorderSizePixel=0; tpPopScr.Size=UDim2.new(1,0,1,0)
tpPopScr.ScrollBarThickness=2; tpPopScr.ScrollBarImageColor3=CA
tpPopScr.AutomaticCanvasSize=Enum.AutomaticSize.Y; tpPopScr.CanvasSize=UDim2.new(0,0,0,0); tpPopScr.ZIndex=301
local tpPopList=Instance.new("UIListLayout",tpPopScr)
tpPopList.Padding=UDim.new(0,2); tpPopList.HorizontalAlignment=Enum.HorizontalAlignment.Center
local tpPopPad=Instance.new("UIPadding",tpPopScr)
tpPopPad.PaddingTop=UDim.new(0,6); tpPopPad.PaddingLeft=UDim.new(0,6); tpPopPad.PaddingRight=UDim.new(0,6); tpPopPad.PaddingBottom=UDim.new(0,6)

for _,bioma in ipairs(BIOMAS) do
    local item=Instance.new("TextButton",tpPopScr)
    item.BackgroundColor3=Color3.fromRGB(30,33,46); item.BackgroundTransparency=0.1
    item.BorderSizePixel=0; item.Size=UDim2.new(1,0,0,30); item.ZIndex=302
    item.Font=Enum.Font.GothamSemibold; item.Text=bioma.e.."  "..bioma.n
    item.TextColor3=Color3.fromRGB(190,200,225); item.TextSize=10; item.TextXAlignment=Enum.TextXAlignment.Left
    Instance.new("UICorner",item).CornerRadius=UDim.new(0,7)
    local tpad=Instance.new("UIPadding",item); tpad.PaddingLeft=UDim.new(0,10)
    item.MouseEnter:Connect(function() TS:Create(item,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(40,44,62),BackgroundTransparency=0}):Play() end)
    item.MouseLeave:Connect(function() TS:Create(item,TweenInfo.new(0.12),{BackgroundColor3=Color3.fromRGB(30,33,46),BackgroundTransparency=0.1}):Play() end)
    local capB2=bioma
    item.MouseButton1Click:Connect(function()
        selBioma=capB2; selBtn.Text=capB2.e.."  "..capB2.n.." ▾"; selBtn.TextColor3=Color3.fromRGB(220,230,255)
        tpBtn.Text="⚡ TP "..capB2.n; tpPopOpen=false
        TS:Create(tpPopup,TweenInfo.new(0.18),{Size=UDim2.new(0,220,0,0)}):Play()
        task.delay(0.19,function() tpPopup.Visible=false end)
    end)
end

-- Abre popup ao clicar no seletor
selBtn.MouseButton1Click:Connect(function()
    tpPopOpen=not tpPopOpen
    if tpPopOpen then
        local pos=selBtn.AbsolutePosition; local sz=selBtn.AbsoluteSize
        tpPopup.Position=UDim2.new(0,pos.X,0,pos.Y+sz.Y+4)
        tpPopup.Size=UDim2.new(0,220,0,0); tpPopup.Visible=true
        TS:Create(tpPopup,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,220,0,264)}):Play()
    else
        TS:Create(tpPopup,TweenInfo.new(0.18),{Size=UDim2.new(0,220,0,0)}):Play()
        task.delay(0.19,function() tpPopup.Visible=false end)
    end
end)

-- Fechar popup ao clicar fora
UIS.InputBegan:Connect(function(inp)
    if inp.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    if not tpPopOpen then return end
    local mp=UIS:GetMouseLocation(); local ap=tpPopup.AbsolutePosition; local as=tpPopup.AbsoluteSize
    if mp.X<ap.X or mp.X>ap.X+as.X or mp.Y<ap.Y or mp.Y>ap.Y+as.Y then
        tpPopOpen=false
        TS:Create(tpPopup,TweenInfo.new(0.18),{Size=UDim2.new(0,220,0,0)}):Play()
        task.delay(0.19,function() tpPopup.Visible=false end)
    end
end)

-- Botão TP principal
tpBtn.MouseButton1Click:Connect(function()
    if not selBioma then feedL2.Text="⚠️ Selecione um bioma primeiro"; feedL2.TextColor3=Color3.fromRGB(255,200,60); task.delay(2,function() feedL2.Text="" end); return end
    feedL2.Text="⏳ Procurando "..selBioma.n.."..."; feedL2.TextColor3=Color3.fromRGB(200,200,255)
    tpBtn.Text="⏳..."; tpBtn.BackgroundTransparency=0.4
    task.spawn(function()
        local pos=findBioma(selBioma); tpBioma(pos,selBioma.n,feedL2)
        tpBtn.Text="⚡ TP "..selBioma.n; tpBtn.BackgroundTransparency=0.15
    end)
end)
tpBtn.MouseEnter:Connect(function() TS:Create(tpBtn,TweenInfo.new(0.12),{BackgroundTransparency=0}):Play() end)
tpBtn.MouseLeave:Connect(function() TS:Create(tpBtn,TweenInfo.new(0.12),{BackgroundTransparency=0.15}):Play() end)


-- ══════════════════════════════════════════════════════
--  ABA INFO
-- ══════════════════════════════════════════════════════
local infoCard=Instance.new("Frame",Pages["Info"])
infoCard.BackgroundColor3=Color3.fromRGB(30,31,34); infoCard.BorderSizePixel=0
infoCard.Size=UDim2.new(1,0,0,132); infoCard.LayoutOrder=0; infoCard.ZIndex=5
Instance.new("UICorner",infoCard).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",infoCard).Color=Color3.fromRGB(55,58,66)
-- Banner
local banner=Instance.new("Frame",infoCard); banner.BackgroundColor3=Color3.fromRGB(72,87,210); banner.BorderSizePixel=0
banner.Size=UDim2.new(1,0,0,50); banner.ZIndex=5
Instance.new("UICorner",banner).CornerRadius=UDim.new(0,10)
local banFix=Instance.new("Frame",banner); banFix.BackgroundColor3=Color3.fromRGB(72,87,210)
banFix.BorderSizePixel=0; banFix.Position=UDim2.new(0,0,0.5,0); banFix.Size=UDim2.new(1,0,0.5,0); banFix.ZIndex=5
local banL=Instance.new("TextLabel",banner); banL.BackgroundTransparency=1
banL.Position=UDim2.new(0,14,0,0); banL.Size=UDim2.new(1,-18,1,0); banL.Font=Enum.Font.GothamBlack
banL.Text="🌲  PudimHub v4.1  —  99 Nights in the Forest"; banL.TextColor3=Color3.fromRGB(255,255,255)
banL.TextSize=12; banL.TextXAlignment=Enum.TextXAlignment.Left; banL.ZIndex=7
-- Avatar
local avRing=Instance.new("Frame",infoCard); avRing.BackgroundColor3=Color3.fromRGB(30,31,34); avRing.BorderSizePixel=0
avRing.Position=UDim2.new(0,8,0,28); avRing.Size=UDim2.new(0,48,0,48); avRing.ZIndex=7
Instance.new("UICorner",avRing).CornerRadius=UDim.new(1,0)
local avImg2=Instance.new("ImageLabel",avRing); avImg2.BackgroundTransparency=1
avImg2.Position=UDim2.new(0,2,0,2); avImg2.Size=UDim2.new(1,-4,1,-4)
avImg2.Image="https://www.roblox.com/headshot-thumbnail/image?userId="..Plr.UserId.."&width=150&height=150&format=png"; avImg2.ZIndex=8
Instance.new("UICorner",avImg2).CornerRadius=UDim.new(1,0)
-- Nome
local inN=Instance.new("TextLabel",infoCard); inN.BackgroundTransparency=1; inN.Position=UDim2.new(0,64,0,52)
inN.Size=UDim2.new(1,-72,0,18); inN.Font=Enum.Font.GothamBold; inN.Text=Plr.DisplayName
inN.TextColor3=Color3.fromRGB(255,255,255); inN.TextSize=13; inN.TextXAlignment=Enum.TextXAlignment.Left; inN.ZIndex=7
local inT=Instance.new("TextLabel",infoCard); inT.BackgroundTransparency=1; inT.Position=UDim2.new(0,64,0,70)
inT.Size=UDim2.new(1,-72,0,12); inT.Font=Enum.Font.Gotham; inT.Text="@"..Plr.Name
inT.TextColor3=Color3.fromRGB(130,145,165); inT.TextSize=10; inT.TextXAlignment=Enum.TextXAlignment.Left; inT.ZIndex=7
-- Status
local inSt=Instance.new("Frame",infoCard); inSt.BackgroundColor3=Color3.fromRGB(40,42,48); inSt.BorderSizePixel=0
inSt.Position=UDim2.new(0,8,0,88); inSt.Size=UDim2.new(1,-16,0,36); inSt.ZIndex=6
Instance.new("UICorner",inSt).CornerRadius=UDim.new(0,7)
local inStL=Instance.new("TextLabel",inSt); inStL.BackgroundTransparency=1; inStL.Position=UDim2.new(0,8,0,4)
inStL.Size=UDim2.new(1,-16,0,14); inStL.Font=Enum.Font.GothamBold
inStL.Text="🎮  Jogando 99 Nights in the Forest"; inStL.TextColor3=Color3.fromRGB(87,242,135)
inStL.TextSize=10; inStL.TextXAlignment=Enum.TextXAlignment.Left; inStL.ZIndex=7
local inStS=Instance.new("TextLabel",inSt); inStS.BackgroundTransparency=1; inStS.Position=UDim2.new(0,8,0,20)
inStS.Size=UDim2.new(1,-16,0,12); inStS.Font=Enum.Font.Gotham
inStS.Text="ID: "..tostring(game.PlaceId).."  •  PudimHub v4.1  •  2026"
inStS.TextColor3=Color3.fromRGB(110,125,145); inStS.TextSize=9; inStS.TextXAlignment=Enum.TextXAlignment.Left; inStS.ZIndex=7

-- Texto de dados
local dadosTxt=Instance.new("Frame",Pages["Info"]); dadosTxt.BackgroundColor3=Color3.fromRGB(22,24,32)
dadosTxt.BackgroundTransparency=0.3; dadosTxt.BorderSizePixel=0; dadosTxt.Size=UDim2.new(1,0,0,80)
dadosTxt.LayoutOrder=1; dadosTxt.ZIndex=4
Instance.new("UICorner",dadosTxt).CornerRadius=UDim.new(0,8)
Instance.new("UIStroke",dadosTxt).Color=Color3.fromRGB(45,48,58)
local dadosL=Instance.new("TextLabel",dadosTxt); dadosL.BackgroundTransparency=1
dadosL.Position=UDim2.new(0,10,0,8); dadosL.Size=UDim2.new(1,-20,1,-16)
dadosL.Font=Enum.Font.Gotham; dadosL.TextWrapped=true; dadosL.ZIndex=5
dadosL.Text="ℹ️  Script desenvolvido por apenas 1 pessoa.\n✓  ESP 20 categorias | Bring 17 | Player 10 funções | Aimbot | TP 15 biomas\n🔄  Atualizado 2026  •  Versão final integrada"
dadosL.TextColor3=Color3.fromRGB(150,165,190); dadosL.TextSize=9
dadosL.TextXAlignment=Enum.TextXAlignment.Left; dadosL.TextYAlignment=Enum.TextYAlignment.Top

-- ══════════════════════════════════════════════════════
--  ABA STATUS
-- ══════════════════════════════════════════════════════
local function statRow(pg,lbl,fn)
    local row=Instance.new("Frame",pg); row.BackgroundColor3=Color3.fromRGB(26,28,36); row.BorderSizePixel=0
    row.Size=UDim2.new(1,0,0,40); row.ZIndex=4
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
    local k=Instance.new("TextLabel",row); k.BackgroundTransparency=1
    k.Position=UDim2.new(0,10,0,0); k.Size=UDim2.new(0.55,0,1,0); k.Font=Enum.Font.GothamSemibold
    k.Text=lbl; k.TextColor3=Color3.fromRGB(170,180,200); k.TextSize=10; k.TextXAlignment=Enum.TextXAlignment.Left; k.ZIndex=5
    local v=Instance.new("TextLabel",row); v.BackgroundTransparency=1; v.Name="Val"
    v.Position=UDim2.new(0.55,0,0,0); v.Size=UDim2.new(0.45,-10,1,0); v.Font=Enum.Font.GothamBold
    v.Text="--"; v.TextColor3=CA; v.TextSize=10; v.TextXAlignment=Enum.TextXAlignment.Right; v.ZIndex=5
    RS.Heartbeat:Connect(function() pcall(function() v.Text=fn() end) end)
end
statRow(Pages["Status"],"🏃 WalkSpeed",function()
    local c=Plr.Character; if not c then return "--" end; local h=c:FindFirstChildWhichIsA("Humanoid"); return h and string.format("%.0f",h.WalkSpeed) or "--"
end)
statRow(Pages["Status"],"🦘 JumpPower",function()
    local c=Plr.Character; if not c then return "--" end; local h=c:FindFirstChildWhichIsA("Humanoid"); return h and string.format("%.0f",h.JumpPower) or "--"
end)
statRow(Pages["Status"],"❤️ Health",function()
    local c=Plr.Character; if not c then return "--" end; local h=c:FindFirstChildWhichIsA("Humanoid"); return h and string.format("%.0f / %.0f",h.Health,h.MaxHealth) or "--"
end)
statRow(Pages["Status"],"🌐 Server",function() return tostring(game.JobId):sub(1,12).."…" end)
statRow(Pages["Status"],"📍 PlaceId",function() return tostring(game.PlaceId) end)
statRow(Pages["Status"],"🧍 Players",function() return tostring(#Plrs:GetPlayers()) end)
statRow(Pages["Status"],"📡 Ping",function() return string.format("%.0fms",Plr:GetNetworkPing()*1000) end)

-- ══════════════════════════════════════════════════════
--  TABS PLACEHOLDER (Farm, AvFarm, Config)
-- ══════════════════════════════════════════════════════
local function mkPlaceholder(pg,txt)
    local f=Instance.new("Frame",pg); f.BackgroundColor3=Color3.fromRGB(20,22,30); f.BackgroundTransparency=0.3
    f.BorderSizePixel=0; f.Size=UDim2.new(1,0,0,60); f.ZIndex=4
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
    Instance.new("UIStroke",f).Color=Color3.fromRGB(55,60,80)
    local l=Instance.new("TextLabel",f); l.BackgroundTransparency=1; l.Size=UDim2.new(1,0,1,0)
    l.Font=Enum.Font.GothamSemibold; l.Text=txt; l.TextColor3=Color3.fromRGB(100,110,140)
    l.TextSize=11; l.ZIndex=5
end
mkPlaceholder(Pages["Farm"],"🌾 Farm — Em desenvolvimento")
mkPlaceholder(Pages["AvFarm"],"⚙️ Avançado Farm — Em desenvolvimento")
mkPlaceholder(Pages["Config"],"⚙️ Configurações — Em desenvolvimento")

-- ══════════════════════════════════════════════════════
--  INICIALIZAR
-- ══════════════════════════════════════════════════════
selTab("Info")

task.wait(0.05)
print("✅  PudimHub v4.1 carregado — ESP 20 cats | Bring 17 cats | Player 10 funções | Aimbot | TP 15 biomas")

