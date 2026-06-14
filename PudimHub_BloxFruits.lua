-- PudimHub v3 Premium 🍮 — Blox Fruits | Estilo iOS

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "PudimHubIOS"
ScreenGui.Parent         = game.CoreGui
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local TweenService = game:GetService("TweenService")

-- ══════════════════════════════════════════
--  PALETA iOS
-- ══════════════════════════════════════════
local C = {
	BG           = Color3.fromRGB(242, 242, 247),
	SURFACE      = Color3.fromRGB(255, 255, 255),
	TOPBAR       = Color3.fromRGB(249, 249, 249),
	DIVIDER      = Color3.fromRGB(198, 198, 200),
	ACCENT       = Color3.fromRGB(0,   122, 255),
	ACCENT2      = Color3.fromRGB(52,  199,  89),
	TEXT_PRIMARY = Color3.fromRGB(28,   28,  30),
	TEXT_SEC     = Color3.fromRGB(142, 142, 147),
	CLOSE        = Color3.fromRGB(255,  59,  48),
	MIN          = Color3.fromRGB(255, 204,   0),
	TAB_DEFAULT  = Color3.fromRGB(255, 255, 255),
	TAB_HOVER    = Color3.fromRGB(235, 235, 240),
	TAB_ACTIVE   = Color3.fromRGB(0,   122, 255),
	TAB_TXT_DEF  = Color3.fromRGB(28,   28,  30),
	TAB_TXT_ACT  = Color3.fromRGB(255, 255, 255),
	ON_GREEN     = Color3.fromRGB(52,  199,  89),
	OFF_GRAY     = Color3.fromRGB(198, 198, 200),
	PANEL_BG     = Color3.fromRGB(248, 248, 252),
	DROPDOWN_BG  = Color3.fromRGB(255, 255, 255),
}

-- ══════════════════════════════════════════
--  SOMBRA
-- ══════════════════════════════════════════
local Shadow = Instance.new("Frame", ScreenGui)
Shadow.Size                   = UDim2.new(0, 650, 0, 450)
Shadow.Position               = UDim2.new(0.5, -325, 0.5, -221)
Shadow.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.82
Shadow.ZIndex                 = 0
Shadow.BorderSizePixel        = 0
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 20)

-- ══════════════════════════════════════════
--  JANELA PRINCIPAL
-- ══════════════════════════════════════════
local MainFrame = Instance.new("Frame")
MainFrame.Parent           = ScreenGui
MainFrame.Size             = UDim2.new(0, 640, 0, 440)
MainFrame.Position         = UDim2.new(0.5, -320, 0.5, -220)
MainFrame.BackgroundColor3 = C.BG
MainFrame.Active           = true
MainFrame.Draggable        = true
MainFrame.ClipsDescendants = true
MainFrame.ZIndex           = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 18)

-- ══════════════════════════════════════════
--  TOPBAR
-- ══════════════════════════════════════════
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size             = UDim2.new(1, 0, 0, 52)
TopBar.Position         = UDim2.new(0, 0, 0, 0)
TopBar.BackgroundColor3 = C.TOPBAR
TopBar.BorderSizePixel  = 0
TopBar.ZIndex           = 2

local TopDivider = Instance.new("Frame", MainFrame)
TopDivider.Size             = UDim2.new(1, 0, 0, 1)
TopDivider.Position         = UDim2.new(0, 0, 0, 52)
TopDivider.BackgroundColor3 = C.DIVIDER
TopDivider.BorderSizePixel  = 0
TopDivider.ZIndex           = 2

local Title = Instance.new("TextLabel", TopBar)
Title.BackgroundTransparency = 1
Title.Size                   = UDim2.new(1, -160, 0, 22)
Title.Position               = UDim2.new(0, 80, 0, 8)
Title.Font                   = Enum.Font.GothamBold
Title.Text                   = "🍮 PudimHub"
Title.TextColor3             = C.TEXT_PRIMARY
Title.TextSize               = 17
Title.TextXAlignment         = Enum.TextXAlignment.Center
Title.ZIndex                 = 3

local SubTitle = Instance.new("TextLabel", TopBar)
SubTitle.BackgroundTransparency = 1
SubTitle.Size                   = UDim2.new(1, -160, 0, 14)
SubTitle.Position               = UDim2.new(0, 80, 0, 30)
SubTitle.Font                   = Enum.Font.Gotham
SubTitle.Text                   = "Premium"
SubTitle.TextColor3             = C.TEXT_SEC
SubTitle.TextSize               = 11
SubTitle.TextXAlignment         = Enum.TextXAlignment.Center
SubTitle.ZIndex                 = 3

local function MakeCircleBtn(pos, color, hoverColor)
	local b = Instance.new("TextButton", TopBar)
	b.Size             = UDim2.new(0, 14, 0, 14)
	b.Position         = pos
	b.Text             = ""
	b.BackgroundColor3 = color
	b.AutoButtonColor  = false
	b.BorderSizePixel  = 0
	b.ZIndex           = 4
	Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = hoverColor }):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.1), { BackgroundColor3 = color }):Play()
	end)
	return b
end

local BtnClose = MakeCircleBtn(UDim2.new(0, 14, 0.5, -7), C.CLOSE, Color3.fromRGB(200, 40, 30))
local BtnMin   = MakeCircleBtn(UDim2.new(0, 36, 0.5, -7), C.MIN,   Color3.fromRGB(200, 160, 0))

-- ══════════════════════════════════════════
--  SIDEBAR
-- ══════════════════════════════════════════
local Sidebar = Instance.new("ScrollingFrame", MainFrame)
Sidebar.Position            = UDim2.new(0, 8, 0, 60)
Sidebar.Size                = UDim2.new(0, 162, 1, -68)
Sidebar.BackgroundColor3    = C.BG
Sidebar.ScrollBarThickness  = 0
Sidebar.CanvasSize          = UDim2.new(0, 0, 0, 0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.BorderSizePixel     = 0
Sidebar.ZIndex              = 2

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding             = UDim.new(0, 0)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop    = UDim.new(0, 4)
SidebarPad.PaddingBottom = UDim.new(0, 8)

-- ══════════════════════════════════════════
--  CONTEÚDO PRINCIPAL (ScrollingFrame para suportar painéis longos)
-- ══════════════════════════════════════════
local ContentScroll = Instance.new("ScrollingFrame", MainFrame)
ContentScroll.Position            = UDim2.new(0, 178, 0, 60)
ContentScroll.Size                = UDim2.new(1, -186, 1, -68)
ContentScroll.BackgroundColor3    = C.SURFACE
ContentScroll.BorderSizePixel     = 0
ContentScroll.ZIndex              = 2
ContentScroll.ScrollBarThickness  = 3
ContentScroll.ScrollBarImageColor3 = C.DIVIDER
ContentScroll.CanvasSize          = UDim2.new(0, 0, 0, 0)
ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", ContentScroll).CornerRadius = UDim.new(0, 13)

local ContentStroke = Instance.new("UIStroke", ContentScroll)
ContentStroke.Color     = C.DIVIDER
ContentStroke.Thickness = 0.8

-- layout interno do conteúdo
local ContentLayout = Instance.new("UIListLayout", ContentScroll)
ContentLayout.Padding             = UDim.new(0, 0)
ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ContentLayout.SortOrder           = Enum.SortOrder.LayoutOrder

local ContentPad = Instance.new("UIPadding", ContentScroll)
ContentPad.PaddingTop    = UDim.new(0, 12)
ContentPad.PaddingBottom = UDim.new(0, 16)
ContentPad.PaddingLeft   = UDim.new(0, 12)
ContentPad.PaddingRight  = UDim.new(0, 12)

-- ══════════════════════════════════════════
--  HEADER DA ABA ATIVA (sempre visível no topo do conteúdo)
-- ══════════════════════════════════════════
local WelcomeHeader = Instance.new("Frame", ContentScroll)
WelcomeHeader.Size             = UDim2.new(1, 0, 0, 38)
WelcomeHeader.BackgroundTransparency = 1
WelcomeHeader.BorderSizePixel  = 0
WelcomeHeader.LayoutOrder      = 0
WelcomeHeader.ZIndex           = 3

local Welcome = Instance.new("TextLabel", WelcomeHeader)
Welcome.BackgroundTransparency = 1
Welcome.Size                   = UDim2.new(1, 0, 1, 0)
Welcome.Font                   = Enum.Font.GothamBold
Welcome.Text                   = "🏠  Home"
Welcome.TextColor3             = C.TEXT_PRIMARY
Welcome.TextSize               = 17
Welcome.TextXAlignment         = Enum.TextXAlignment.Left
Welcome.TextTruncate           = Enum.TextTruncate.AtEnd
Welcome.ZIndex                 = 3

local WelcomeDivider = Instance.new("Frame", ContentScroll)
WelcomeDivider.Size             = UDim2.new(1, 0, 0, 1)
WelcomeDivider.BackgroundColor3 = C.DIVIDER
WelcomeDivider.BorderSizePixel  = 0
WelcomeDivider.LayoutOrder      = 1
WelcomeDivider.ZIndex           = 3

-- ══════════════════════════════════════════
--  TODAS AS ABAS (frames de conteúdo por aba)
-- ══════════════════════════════════════════
-- Cada aba tem um frame filho do ContentScroll, com LayoutOrder >= 2
-- Apenas o frame da aba ativa fica visível

local TabFrames = {} -- ["nome da aba"] = Frame

local function MakeTabFrame(name)
	local f = Instance.new("Frame", ContentScroll)
	f.Size             = UDim2.new(1, 0, 0, 0)
	f.AutomaticSize    = Enum.AutomaticSize.Y
	f.BackgroundTransparency = 1
	f.BorderSizePixel  = 0
	f.Visible          = false
	f.LayoutOrder      = 2

	local fl = Instance.new("UIListLayout", f)
	fl.Padding             = UDim.new(0, 10)
	fl.HorizontalAlignment = Enum.HorizontalAlignment.Center
	fl.SortOrder           = Enum.SortOrder.LayoutOrder

	TabFrames[name] = f
	return f
end

-- ══════════════════════════════════════════
--  HELPERS DE UI PARA PAINÉIS
-- ══════════════════════════════════════════

-- Painel card com título
local function MakePanel(parent, titleText, order)
	local panel = Instance.new("Frame", parent)
	panel.Size             = UDim2.new(1, 0, 0, 0)
	panel.AutomaticSize    = Enum.AutomaticSize.Y
	panel.BackgroundColor3 = C.SURFACE
	panel.BorderSizePixel  = 0
	panel.LayoutOrder      = order or 1
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", panel)
	stroke.Color     = C.DIVIDER
	stroke.Thickness = 0.8

	local panelLayout = Instance.new("UIListLayout", panel)
	panelLayout.Padding             = UDim.new(0, 0)
	panelLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- título do painel
	local header = Instance.new("Frame", panel)
	header.Size             = UDim2.new(1, 0, 0, 36)
	header.BackgroundColor3 = C.PANEL_BG
	header.BorderSizePixel  = 0
	header.LayoutOrder      = 0

	local headerLabel = Instance.new("TextLabel", header)
	headerLabel.BackgroundTransparency = 1
	headerLabel.Size                   = UDim2.new(1, -16, 1, 0)
	headerLabel.Position               = UDim2.new(0, 12, 0, 0)
	headerLabel.Font                   = Enum.Font.GothamBold
	headerLabel.Text                   = titleText
	headerLabel.TextColor3             = C.TEXT_SEC
	headerLabel.TextSize               = 11
	headerLabel.TextXAlignment         = Enum.TextXAlignment.Left

	local headerDiv = Instance.new("Frame", panel)
	headerDiv.Size             = UDim2.new(1, 0, 0, 1)
	headerDiv.BackgroundColor3 = C.DIVIDER
	headerDiv.BorderSizePixel  = 0
	headerDiv.LayoutOrder      = 1

	return panel, panelLayout
end

-- Linha de item dentro de painel (label à esquerda, widget à direita)
local function MakePanelRow(parent, labelText, order)
	local row = Instance.new("Frame", parent)
	row.Size             = UDim2.new(1, 0, 0, 44)
	row.BackgroundTransparency = 1
	row.BorderSizePixel  = 0
	row.LayoutOrder      = order or 10

	local lbl = Instance.new("TextLabel", row)
	lbl.BackgroundTransparency = 1
	lbl.Size                   = UDim2.new(0.55, 0, 1, 0)
	lbl.Position               = UDim2.new(0, 14, 0, 0)
	lbl.Font                   = Enum.Font.Gotham
	lbl.Text                   = labelText
	lbl.TextColor3             = C.TEXT_PRIMARY
	lbl.TextSize               = 14
	lbl.TextXAlignment         = Enum.TextXAlignment.Left

	return row, lbl
end

-- Toggle iOS (pill verde/cinza)
local function MakeToggle(parent, posX, posY)
	local track = Instance.new("Frame", parent)
	track.Size             = UDim2.new(0, 44, 0, 26)
	track.Position         = UDim2.new(1, -58, 0.5, -13)
	track.BackgroundColor3 = C.OFF_GRAY
	track.BorderSizePixel  = 0
	Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame", track)
	knob.Size             = UDim2.new(0, 22, 0, 22)
	knob.Position         = UDim2.new(0, 2, 0.5, -11)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel  = 0
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	local btn = Instance.new("TextButton", track)
	btn.Size                   = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text                   = ""
	btn.AutoButtonColor        = false

	local isOn = false
	btn.MouseButton1Click:Connect(function()
		isOn = not isOn
		if isOn then
			TweenService:Create(track, TweenInfo.new(0.2), { BackgroundColor3 = C.ON_GREEN }):Play()
			TweenService:Create(knob,  TweenInfo.new(0.2), { Position = UDim2.new(0, 20, 0.5, -11) }):Play()
		else
			TweenService:Create(track, TweenInfo.new(0.2), { BackgroundColor3 = C.OFF_GRAY }):Play()
			TweenService:Create(knob,  TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, -11) }):Play()
		end
	end)

	return track
end

-- Separador entre linhas de painel
local function MakePanelSep(parent, order)
	local sep = Instance.new("Frame", parent)
	sep.Size             = UDim2.new(1, -14, 0, 1)
	sep.BackgroundColor3 = C.DIVIDER
	sep.BorderSizePixel  = 0
	sep.LayoutOrder      = order or 99
	return sep
end

-- ══════════════════════════════════════════
--  DROPDOWN GENÉRICO
--  parent     = frame pai onde o dropdown vai aparecer
--  btnRef     = TextButton que dispara o dropdown
--  valueLabel = TextLabel que mostra o valor atual
--  options    = lista de strings
--  onSelect   = function(value) callback
-- ══════════════════════════════════════════
local function MakeDropdown(contentParent, btnRef, valueLabel, options, onSelect)
	-- o dropdown flutua sobre o ContentScroll, pai = MainFrame
	local dropFrame = Instance.new("Frame", MainFrame)
	dropFrame.Size             = UDim2.new(0, 160, 0, 0)
	dropFrame.BackgroundColor3 = C.DROPDOWN_BG
	dropFrame.BorderSizePixel  = 0
	dropFrame.Visible          = false
	dropFrame.ZIndex           = 20
	dropFrame.ClipsDescendants = true
	Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0, 10)
	local dropStroke = Instance.new("UIStroke", dropFrame)
	dropStroke.Color     = C.DIVIDER
	dropStroke.Thickness = 0.8

	local dropLayout = Instance.new("UIListLayout", dropFrame)
	dropLayout.Padding             = UDim.new(0, 0)
	dropLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local ITEM_H  = 36
	local TOTAL_H = #options * ITEM_H

	for i, opt in ipairs(options) do
		local item = Instance.new("TextButton", dropFrame)
		item.Size             = UDim2.new(1, 0, 0, ITEM_H)
		item.BackgroundColor3 = C.DROPDOWN_BG
		item.AutoButtonColor  = false
		item.BorderSizePixel  = 0
		item.Text             = ""
		item.ZIndex           = 21

		local itemLbl = Instance.new("TextLabel", item)
		itemLbl.BackgroundTransparency = 1
		itemLbl.Size                   = UDim2.new(1, -16, 1, 0)
		itemLbl.Position               = UDim2.new(0, 14, 0, 0)
		itemLbl.Font                   = Enum.Font.Gotham
		itemLbl.Text                   = opt
		itemLbl.TextColor3             = C.TEXT_PRIMARY
		itemLbl.TextSize               = 13
		itemLbl.TextXAlignment         = Enum.TextXAlignment.Left
		itemLbl.ZIndex                 = 22

		if i < #options then
			local sep = Instance.new("Frame", item)
			sep.Size             = UDim2.new(1, -14, 0, 1)
			sep.Position         = UDim2.new(0, 14, 1, -1)
			sep.BackgroundColor3 = C.DIVIDER
			sep.BorderSizePixel  = 0
			sep.ZIndex           = 22
		end

		item.MouseEnter:Connect(function()
			item.BackgroundColor3 = C.TAB_HOVER
		end)
		item.MouseLeave:Connect(function()
			item.BackgroundColor3 = C.DROPDOWN_BG
		end)

		item.MouseButton1Click:Connect(function()
			-- fecha dropdown
			TweenService:Create(dropFrame, TweenInfo.new(0.15), { Size = UDim2.new(0, 160, 0, 0) }):Play()
			task.delay(0.15, function() dropFrame.Visible = false end)
			-- atualiza label do botão
			valueLabel.Text = opt
			if onSelect then onSelect(opt) end
		end)
	end

	-- posicionamento ao abrir: alinha ao btn dentro do ContentScroll
	local isOpen = false
	btnRef.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		if isOpen then
			-- calcula posição absoluta do btnRef e converte para MainFrame
			local btnAbs = btnRef.AbsolutePosition
			local mfAbs  = MainFrame.AbsolutePosition
			local relX   = btnAbs.X - mfAbs.X
			local relY   = btnAbs.Y - mfAbs.Y + btnRef.AbsoluteSize.Y + 4

			dropFrame.Position = UDim2.new(0, relX, 0, relY)
			dropFrame.Size     = UDim2.new(0, btnRef.AbsoluteSize.X, 0, 0)
			dropFrame.Visible  = true
			TweenService:Create(dropFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad),
				{ Size = UDim2.new(0, btnRef.AbsoluteSize.X, 0, TOTAL_H) }):Play()
		else
			TweenService:Create(dropFrame, TweenInfo.new(0.15), { Size = UDim2.new(0, btnRef.AbsoluteSize.X, 0, 0) }):Play()
			task.delay(0.15, function() dropFrame.Visible = false end)
		end
	end)
end

-- ══════════════════════════════════════════
--  BOTÃO DROPDOWN (aparência)
--  Retorna: rowFrame, btn (TextButton), valueLabel (TextLabel)
-- ══════════════════════════════════════════
local function MakeDropdownRow(parent, labelText, defaultValue, order)
	local row, _ = MakePanelRow(parent, labelText, order)

	local btn = Instance.new("TextButton", row)
	btn.Size             = UDim2.new(0, 120, 0, 28)
	btn.Position         = UDim2.new(1, -130, 0.5, -14)
	btn.BackgroundColor3 = C.BG
	btn.AutoButtonColor  = false
	btn.BorderSizePixel  = 0
	btn.Text             = ""
	btn.ZIndex           = 3
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
	local btnStroke = Instance.new("UIStroke", btn)
	btnStroke.Color     = C.DIVIDER
	btnStroke.Thickness = 0.8

	local valueLabel = Instance.new("TextLabel", btn)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Size                   = UDim2.new(1, -24, 1, 0)
	valueLabel.Position               = UDim2.new(0, 8, 0, 0)
	valueLabel.Font                   = Enum.Font.Gotham
	valueLabel.Text                   = defaultValue
	valueLabel.TextColor3             = C.TEXT_PRIMARY
	valueLabel.TextSize               = 13
	valueLabel.TextXAlignment         = Enum.TextXAlignment.Left
	valueLabel.ZIndex                 = 4

	-- chevron ˅
	local chev = Instance.new("TextLabel", btn)
	chev.BackgroundTransparency = 1
	chev.Size                   = UDim2.new(0, 18, 1, 0)
	chev.Position               = UDim2.new(1, -20, 0, 0)
	chev.Font                   = Enum.Font.GothamBold
	chev.Text                   = "⌄"
	chev.TextColor3             = C.TEXT_SEC
	chev.TextSize               = 14
	chev.TextXAlignment         = Enum.TextXAlignment.Center
	chev.ZIndex                 = 4

	return row, btn, valueLabel
end

-- ══════════════════════════════════════════
--  ABA: HOME
-- ══════════════════════════════════════════
local homeFrame = MakeTabFrame("🏠 Home")

local autoPanel, _ = MakePanel(homeFrame, "AUTO FARM", 1)

-- linha: Auto Near Mobs
local autoRow, _ = MakePanelRow(autoPanel, "🎯 Auto Near Mobs", 2)

local autoTrack = Instance.new("Frame", autoRow)
autoTrack.Size             = UDim2.new(0, 44, 0, 26)
autoTrack.Position         = UDim2.new(1, -58, 0.5, -13)
autoTrack.BackgroundColor3 = C.OFF_GRAY
autoTrack.BorderSizePixel  = 0
Instance.new("UICorner", autoTrack).CornerRadius = UDim.new(1, 0)

local autoKnob = Instance.new("Frame", autoTrack)
autoKnob.Size             = UDim2.new(0, 22, 0, 22)
autoKnob.Position         = UDim2.new(0, 2, 0.5, -11)
autoKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
autoKnob.BorderSizePixel  = 0
Instance.new("UICorner", autoKnob).CornerRadius = UDim.new(1, 0)

local autoBtn = Instance.new("TextButton", autoTrack)
autoBtn.Size                   = UDim2.new(1, 0, 1, 0)
autoBtn.BackgroundTransparency = 1
autoBtn.Text                   = ""
autoBtn.AutoButtonColor        = false
autoBtn.MouseButton1Click:Connect(function()
	_G.AutoNearMobs = not _G.AutoNearMobs
	if _G.AutoNearMobs then
		TweenService:Create(autoTrack, TweenInfo.new(0.2), { BackgroundColor3 = C.ON_GREEN }):Play()
		TweenService:Create(autoKnob,  TweenInfo.new(0.2), { Position = UDim2.new(0, 20, 0.5, -11) }):Play()
	else
		TweenService:Create(autoTrack, TweenInfo.new(0.2), { BackgroundColor3 = C.OFF_GRAY }):Play()
		TweenService:Create(autoKnob,  TweenInfo.new(0.2), { Position = UDim2.new(0, 2, 0.5, -11) }):Play()
	end
end)

-- descrição abaixo do toggle
local autoDesc = Instance.new("Frame", autoPanel)
autoDesc.Size             = UDim2.new(1, 0, 0, 36)
autoDesc.BackgroundTransparency = 1
autoDesc.BorderSizePixel  = 0
autoDesc.LayoutOrder      = 3

local autoDescLbl = Instance.new("TextLabel", autoDesc)
autoDescLbl.BackgroundTransparency = 1
autoDescLbl.Size                   = UDim2.new(1, -24, 1, 0)
autoDescLbl.Position               = UDim2.new(0, 14, 0, 0)
autoDescLbl.Font                   = Enum.Font.Gotham
autoDescLbl.Text                   = "Voa até o mob mais próximo automaticamente"
autoDescLbl.TextColor3             = C.TEXT_SEC
autoDescLbl.TextSize               = 11
autoDescLbl.TextXAlignment         = Enum.TextXAlignment.Left
autoDescLbl.TextWrapped            = true

-- espaçador
local homeSpacer = Instance.new("Frame", homeFrame)
homeSpacer.Size                   = UDim2.new(1, 0, 0, 8)
homeSpacer.BackgroundTransparency = 1
homeSpacer.BorderSizePixel        = 0
homeSpacer.LayoutOrder            = 99

-- ══════════════════════════════════════════
--  ABA: CONFIGURAÇÃO
--  Lógica portada do script pudimmeloteos
-- ══════════════════════════════════════════
local cfgFrame = MakeTabFrame("⚙️ Configuração")

-- ── variáveis globais da aba ──
SelectWeaponFarm   = "Melee"
AutoFarmType       = "Above"
DisFarm            = 30
FastAttack         = false
FastShot           = false
AttackToPlayersNow = false
FastAttackSelected = "0.175 (Default)"
FastAttackDelay    = 0.175
bringfrec          = 250
BringMobs          = false
ByPassTP           = false
AutoSetSpawn       = false
_G.SkillZ          = false
_G.SkillX          = false
_G.SkillC          = false
_G.SkillV          = false
_G.SkillF          = false
BusoHaki           = false
KenHaki            = false
DeleteAudioEffect  = false
HideNotification   = false

-- ── PAINEL: Main Setting ─────────────────
local mainSetPanel, _ = MakePanel(cfgFrame, "MAIN SETTING", 1)

-- Select Weapon
local weaponRow, weaponBtn, weaponValue = MakeDropdownRow(mainSetPanel, "Select Weapon", "Melee", 2)
weaponRow.LayoutOrder = 2
local weaponOptions = {"Melee", "Blox Fruit", "Sword", "Gun"}
MakeDropdown(cfgFrame, weaponBtn, weaponValue, weaponOptions, function(val)
	SelectWeaponFarm = val
end)
task.spawn(function()
	while task.wait() do
		pcall(function()
			for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
				if v.ToolTip == SelectWeaponFarm then
					if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
						SelectWeapon = v.Name
					end
				end
			end
		end)
	end
end)

MakePanelSep(mainSetPanel, 3)

-- Select Farm Type
local farmTypeRow, farmTypeBtn, farmTypeValue = MakeDropdownRow(mainSetPanel, "Select Farm Type", "Above", 4)
farmTypeRow.LayoutOrder = 4
local farmTypeOptions = {"Above", "Beside"}
MakeDropdown(cfgFrame, farmTypeBtn, farmTypeValue, farmTypeOptions, function(val)
	AutoFarmType = val
end)
task.spawn(function()
	while task.wait() do
		if AutoFarmType == "Above" then
			Farm_Mode = CFrame.new(0, DisFarm, 0) * CFrame.Angles(math.rad(-90), 0, 0)
		elseif AutoFarmType == "Beside" then
			Farm_Mode = CFrame.new(0, 2, DisFarm) * CFrame.Angles(math.rad(0), 0, 0)
		end
	end
end)

MakePanelSep(mainSetPanel, 5)

-- Distance Farm
local disFarmRow, _ = MakePanelRow(mainSetPanel, "Distance Farm", 6)
local disFarmInput = Instance.new("TextBox", disFarmRow)
disFarmInput.Size             = UDim2.new(0, 80, 0, 28)
disFarmInput.Position         = UDim2.new(1, -92, 0.5, -14)
disFarmInput.BackgroundColor3 = C.BG
disFarmInput.BorderSizePixel  = 0
disFarmInput.Font             = Enum.Font.Gotham
disFarmInput.TextSize         = 13
disFarmInput.Text             = "30"
disFarmInput.TextColor3       = C.TEXT_PRIMARY
disFarmInput.PlaceholderText  = "30"
disFarmInput.ClearTextOnFocus = false
Instance.new("UICorner", disFarmInput).CornerRadius = UDim.new(0, 7)
local dis = Instance.new("UIStroke", disFarmInput)
dis.Color = C.DIVIDER; dis.Thickness = 0.8
disFarmInput.FocusLost:Connect(function()
	DisFarm = tonumber(disFarmInput.Text) or 30
end)

MakePanelSep(mainSetPanel, 7)

-- Fast Attack Delay dropdown
local delayRow, delayBtn, delayValue = MakeDropdownRow(mainSetPanel, "Fast Attack Delay", "0.175 (Default)", 8)
delayRow.LayoutOrder = 8
local delayOptions = {"0.100 (Risk)", "0.165", "0.175 (Default)", "0.185", "0.200", "0.300", "0.500", "0.700 (Slow)"}
MakeDropdown(cfgFrame, delayBtn, delayValue, delayOptions, function(val)
	FastAttackSelected = val
	if val == "0.100 (Risk)" then FastAttackDelay = 0.1
	elseif val == "0.165" then FastAttackDelay = 0.165
	elseif val == "0.175 (Default)" then FastAttackDelay = 0.175
	elseif val == "0.185" then FastAttackDelay = 0.185
	elseif val == "0.200" then FastAttackDelay = 0.2
	elseif val == "0.300" then FastAttackDelay = 0.3
	elseif val == "0.500" then FastAttackDelay = 0.5
	elseif val == "0.700 (Slow)" then FastAttackDelay = 0.7
	end
end)

MakePanelSep(mainSetPanel, 9)

-- Fast Attack (Melee and Sword) toggle
local faRow2, _ = MakePanelRow(mainSetPanel, "Fast Attack (Melee/Sword)", 10)
local faTrack2 = Instance.new("Frame", faRow2)
faTrack2.Size = UDim2.new(0,44,0,26); faTrack2.Position = UDim2.new(1,-58,0.5,-13)
faTrack2.BackgroundColor3 = C.OFF_GRAY; faTrack2.BorderSizePixel = 0
Instance.new("UICorner", faTrack2).CornerRadius = UDim.new(1,0)
local faKnob2 = Instance.new("Frame", faTrack2)
faKnob2.Size = UDim2.new(0,22,0,22); faKnob2.Position = UDim2.new(0,2,0.5,-11)
faKnob2.BackgroundColor3 = Color3.fromRGB(255,255,255); faKnob2.BorderSizePixel = 0
Instance.new("UICorner", faKnob2).CornerRadius = UDim.new(1,0)
local faBtn2 = Instance.new("TextButton", faTrack2)
faBtn2.Size = UDim2.new(1,0,1,0); faBtn2.BackgroundTransparency = 1
faBtn2.Text = ""; faBtn2.AutoButtonColor = false
faBtn2.MouseButton1Click:Connect(function()
	FastAttack = not FastAttack
	TweenService:Create(faTrack2, TweenInfo.new(0.2), { BackgroundColor3 = FastAttack and C.ON_GREEN or C.OFF_GRAY }):Play()
	TweenService:Create(faKnob2, TweenInfo.new(0.2), { Position = FastAttack and UDim2.new(0,20,0.5,-11) or UDim2.new(0,2,0.5,-11) }):Play()
end)

-- lógica Fast Attack Melee/Sword
local function getHead()
	local returntable = {}
	local plr = game:GetService("Players").LocalPlayer
	pcall(function()
		for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
			if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
				if (v.Head.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 70 then
					table.insert(returntable, v.HumanoidRootPart)
				end
			end
		end
	end)
	return returntable
end

local function FastAttacked()
	local plr = game:GetService("Players").LocalPlayer
	local heads = getHead()
	pcall(function()
		local RegisterAttack = game:GetService("ReplicatedStorage").Modules.Net["RE/RegisterAttack"]
		local RegisterHit    = game:GetService("ReplicatedStorage").Modules.Net["RE/RegisterHit"]
		for i = 1, #heads do
			if #heads > 0 then
				pcall(function()
					local tool = plr.Character:FindFirstChildOfClass("Tool")
					if tool and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword") then
						RegisterAttack:FireServer(0.0000001)
						RegisterHit:FireServer(heads[i], {})
						sethiddenproperty(plr, "SimulationRadius", math.huge)
					end
				end)
			end
		end
	end)
end

task.spawn(function()
	while task.wait() do
		if FastAttack then
			pcall(function()
				local CameraShakerR = require(game.ReplicatedStorage.Util.CameraShaker)
				repeat task.wait(FastAttackDelay)
					FastAttacked()
					CameraShakerR:Stop()
				until not FastAttack
			end)
		end
	end
end)

MakePanelSep(mainSetPanel, 11)

-- Fast Attack (Gun) toggle
local faGunRow, _ = MakePanelRow(mainSetPanel, "Fast Attack (Gun)", 12)
local faGunTrack = Instance.new("Frame", faGunRow)
faGunTrack.Size = UDim2.new(0,44,0,26); faGunTrack.Position = UDim2.new(1,-58,0.5,-13)
faGunTrack.BackgroundColor3 = C.OFF_GRAY; faGunTrack.BorderSizePixel = 0
Instance.new("UICorner", faGunTrack).CornerRadius = UDim.new(1,0)
local faGunKnob = Instance.new("Frame", faGunTrack)
faGunKnob.Size = UDim2.new(0,22,0,22); faGunKnob.Position = UDim2.new(0,2,0.5,-11)
faGunKnob.BackgroundColor3 = Color3.fromRGB(255,255,255); faGunKnob.BorderSizePixel = 0
Instance.new("UICorner", faGunKnob).CornerRadius = UDim.new(1,0)
local faGunBtn = Instance.new("TextButton", faGunTrack)
faGunBtn.Size = UDim2.new(1,0,1,0); faGunBtn.BackgroundTransparency = 1
faGunBtn.Text = ""; faGunBtn.AutoButtonColor = false
faGunBtn.MouseButton1Click:Connect(function()
	FastShot = not FastShot
	TweenService:Create(faGunTrack, TweenInfo.new(0.2), { BackgroundColor3 = FastShot and C.ON_GREEN or C.OFF_GRAY }):Play()
	TweenService:Create(faGunKnob, TweenInfo.new(0.2), { Position = FastShot and UDim2.new(0,20,0.5,-11) or UDim2.new(0,2,0.5,-11) }):Play()
end)

local function FastShooted()
	local plr = game:GetService("Players").LocalPlayer
	pcall(function()
		local ShootGunEvent = game:GetService("ReplicatedStorage").Modules.Net["RE/ShootGunEvent"]
		for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
			if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
				local tool = plr.Character:FindFirstChildOfClass("Tool")
				if tool and tool.ToolTip == "Gun" then
					if (v.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 50 then
						ShootGunEvent:FireServer(v.HumanoidRootPart.Position, {[1] = v.HumanoidRootPart})
					end
				end
			end
		end
	end)
end

task.spawn(function()
	while task.wait() do
		if FastShot then
			pcall(function()
				local CameraShakerR = require(game.ReplicatedStorage.Util.CameraShaker)
				repeat task.wait(FastAttackDelay)
					FastShooted()
					CameraShakerR:Stop()
				until not FastShot
			end)
		end
	end
end)

MakePanelSep(mainSetPanel, 13)

-- Attack Melee Player toggle
local atkPlrRow, _ = MakePanelRow(mainSetPanel, "Attack Melee Player", 14)
local atkPlrTrack = Instance.new("Frame", atkPlrRow)
atkPlrTrack.Size = UDim2.new(0,44,0,26); atkPlrTrack.Position = UDim2.new(1,-58,0.5,-13)
atkPlrTrack.BackgroundColor3 = C.OFF_GRAY; atkPlrTrack.BorderSizePixel = 0
Instance.new("UICorner", atkPlrTrack).CornerRadius = UDim.new(1,0)
local atkPlrKnob = Instance.new("Frame", atkPlrTrack)
atkPlrKnob.Size = UDim2.new(0,22,0,22); atkPlrKnob.Position = UDim2.new(0,2,0.5,-11)
atkPlrKnob.BackgroundColor3 = Color3.fromRGB(255,255,255); atkPlrKnob.BorderSizePixel = 0
Instance.new("UICorner", atkPlrKnob).CornerRadius = UDim.new(1,0)
local atkPlrBtn = Instance.new("TextButton", atkPlrTrack)
atkPlrBtn.Size = UDim2.new(1,0,1,0); atkPlrBtn.BackgroundTransparency = 1
atkPlrBtn.Text = ""; atkPlrBtn.AutoButtonColor = false
atkPlrBtn.MouseButton1Click:Connect(function()
	AttackToPlayersNow = not AttackToPlayersNow
	TweenService:Create(atkPlrTrack, TweenInfo.new(0.2), { BackgroundColor3 = AttackToPlayersNow and C.ON_GREEN or C.OFF_GRAY }):Play()
	TweenService:Create(atkPlrKnob, TweenInfo.new(0.2), { Position = AttackToPlayersNow and UDim2.new(0,20,0.5,-11) or UDim2.new(0,2,0.5,-11) }):Play()
end)
task.spawn(function()
	while task.wait() do
		if AttackToPlayersNow then
			pcall(function()
				local plr = game:GetService("Players").LocalPlayer
				local RegisterAttack = game:GetService("ReplicatedStorage").Modules.Net["RE/RegisterAttack"]
				local RegisterHit    = game:GetService("ReplicatedStorage").Modules.Net["RE/RegisterHit"]
				repeat task.wait()
					for _, v in pairs(game.Players:GetChildren()) do
						pcall(function()
							if v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
								if (v.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 50 then
									local tool = plr.Character:FindFirstChildOfClass("Tool")
									if tool and (tool.ToolTip == "Melee" or tool.ToolTip == "Sword") then
										RegisterAttack:FireServer(0.1)
										RegisterHit:FireServer(v.Character.Head, {})
									end
								end
							end
						end)
					end
				until not AttackToPlayersNow
			end)
		end
	end
end)

MakePanelSep(mainSetPanel, 15)

-- Bring Mobs Distance textbox
local bringDistRow, _ = MakePanelRow(mainSetPanel, "Bring Mobs Distance", 16)
local bringDistInput = Instance.new("TextBox", bringDistRow)
bringDistInput.Size = UDim2.new(0,80,0,28); bringDistInput.Position = UDim2.new(1,-92,0.5,-14)
bringDistInput.BackgroundColor3 = C.BG; bringDistInput.BorderSizePixel = 0
bringDistInput.Font = Enum.Font.Gotham; bringDistInput.TextSize = 13
bringDistInput.Text = "250"; bringDistInput.TextColor3 = C.TEXT_PRIMARY
bringDistInput.ClearTextOnFocus = false
Instance.new("UICorner", bringDistInput).CornerRadius = UDim.new(0,7)
local bdis = Instance.new("UIStroke", bringDistInput)
bdis.Color = C.DIVIDER; bdis.Thickness = 0.8
bringDistInput.FocusLost:Connect(function()
	bringfrec = tonumber(bringDistInput.Text) or 250
end)

MakePanelSep(mainSetPanel, 17)

-- Bring Mob toggle
local bringRow2, _ = MakePanelRow(mainSetPanel, "Bring Mob", 18)
local bmTrack2 = Instance.new("Frame", bringRow2)
bmTrack2.Size = UDim2.new(0,44,0,26); bmTrack2.Position = UDim2.new(1,-58,0.5,-13)
bmTrack2.BackgroundColor3 = C.OFF_GRAY; bmTrack2.BorderSizePixel = 0
Instance.new("UICorner", bmTrack2).CornerRadius = UDim.new(1,0)
local bmKnob2 = Instance.new("Frame", bmTrack2)
bmKnob2.Size = UDim2.new(0,22,0,22); bmKnob2.Position = UDim2.new(0,2,0.5,-11)
bmKnob2.BackgroundColor3 = Color3.fromRGB(255,255,255); bmKnob2.BorderSizePixel = 0
Instance.new("UICorner", bmKnob2).CornerRadius = UDim.new(1,0)
local bmBtn2 = Instance.new("TextButton", bmTrack2)
bmBtn2.Size = UDim2.new(1,0,1,0); bmBtn2.BackgroundTransparency = 1
bmBtn2.Text = ""; bmBtn2.AutoButtonColor = false
bmBtn2.MouseButton1Click:Connect(function()
	BringMobs = not BringMobs
	TweenService:Create(bmTrack2, TweenInfo.new(0.2), { BackgroundColor3 = BringMobs and C.ON_GREEN or C.OFF_GRAY }):Play()
	TweenService:Create(bmKnob2, TweenInfo.new(0.2), { Position = BringMobs and UDim2.new(0,20,0.5,-11) or UDim2.new(0,2,0.5,-11) }):Play()
end)

-- lógica Bring Mob (usa workspace.Enemies como o script original)
function BringMonster(TargetName, TargetCFrame)
	pcall(function()
		for _, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
			if v.Name == TargetName then
				if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
					if (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < tonumber(bringfrec) then
						v.HumanoidRootPart.CFrame    = TargetCFrame
						v.HumanoidRootPart.CanCollide = false
						v.HumanoidRootPart.Size       = Vector3.new(60, 60, 60)
						v.HumanoidRootPart.Transparency = 1
						v.Humanoid:ChangeState(11)
						v.Humanoid:ChangeState(14)
						if v.Humanoid:FindFirstChild("Animator") then
							v.Humanoid.Animator:Destroy()
						end
						pcall(sethiddenproperty, game.Players.LocalPlayer, "SimulationRadius", math.huge)
					end
				end
			end
		end
	end)
end

MakePanelSep(mainSetPanel, 19)

-- Bypass Teleport toggle
local bypassRow, _ = MakePanelRow(mainSetPanel, "Bypass Teleport", 20)
local bypassTrack = Instance.new("Frame", bypassRow)
bypassTrack.Size = UDim2.new(0,44,0,26); bypassTrack.Position = UDim2.new(1,-58,0.5,-13)
bypassTrack.BackgroundColor3 = C.OFF_GRAY; bypassTrack.BorderSizePixel = 0
Instance.new("UICorner", bypassTrack).CornerRadius = UDim.new(1,0)
local bypassKnob = Instance.new("Frame", bypassTrack)
bypassKnob.Size = UDim2.new(0,22,0,22); bypassKnob.Position = UDim2.new(0,2,0.5,-11)
bypassKnob.BackgroundColor3 = Color3.fromRGB(255,255,255); bypassKnob.BorderSizePixel = 0
Instance.new("UICorner", bypassKnob).CornerRadius = UDim.new(1,0)
local bypassBtn = Instance.new("TextButton", bypassTrack)
bypassBtn.Size = UDim2.new(1,0,1,0); bypassBtn.BackgroundTransparency = 1
bypassBtn.Text = ""; bypassBtn.AutoButtonColor = false
bypassBtn.MouseButton1Click:Connect(function()
	ByPassTP = not ByPassTP
	TweenService:Create(bypassTrack, TweenInfo.new(0.2), { BackgroundColor3 = ByPassTP and C.ON_GREEN or C.OFF_GRAY }):Play()
	TweenService:Create(bypassKnob, TweenInfo.new(0.2), { Position = ByPassTP and UDim2.new(0,20,0.5,-11) or UDim2.new(0,2,0.5,-11) }):Play()
end)

MakePanelSep(mainSetPanel, 21)

-- Set Spawn Point toggle
local spawnRow, _ = MakePanelRow(mainSetPanel, "Set Spawn Point", 22)
local spawnTrack = Instance.new("Frame", spawnRow)
spawnTrack.Size = UDim2.new(0,44,0,26); spawnTrack.Position = UDim2.new(1,-58,0.5,-13)
spawnTrack.BackgroundColor3 = C.OFF_GRAY; spawnTrack.BorderSizePixel = 0
Instance.new("UICorner", spawnTrack).CornerRadius = UDim.new(1,0)
local spawnKnob = Instance.new("Frame", spawnTrack)
spawnKnob.Size = UDim2.new(0,22,0,22); spawnKnob.Position = UDim2.new(0,2,0.5,-11)
spawnKnob.BackgroundColor3 = Color3.fromRGB(255,255,255); spawnKnob.BorderSizePixel = 0
Instance.new("UICorner", spawnKnob).CornerRadius = UDim.new(1,0)
local spawnBtn = Instance.new("TextButton", spawnTrack)
spawnBtn.Size = UDim2.new(1,0,1,0); spawnBtn.BackgroundTransparency = 1
spawnBtn.Text = ""; spawnBtn.AutoButtonColor = false
spawnBtn.MouseButton1Click:Connect(function()
	AutoSetSpawn = not AutoSetSpawn
	TweenService:Create(spawnTrack, TweenInfo.new(0.2), { BackgroundColor3 = AutoSetSpawn and C.ON_GREEN or C.OFF_GRAY }):Play()
	TweenService:Create(spawnKnob, TweenInfo.new(0.2), { Position = AutoSetSpawn and UDim2.new(0,20,0.5,-11) or UDim2.new(0,2,0.5,-11) }):Play()
end)
task.spawn(function()
	while task.wait(5) do
		if AutoSetSpawn then
			pcall(function()
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint")
			end)
		end
	end
end)

MakePanelSep(mainSetPanel, 23)

-- Reset Character button
local resetRow = Instance.new("Frame", mainSetPanel)
resetRow.Size = UDim2.new(1,0,0,44); resetRow.BackgroundTransparency = 1
resetRow.BorderSizePixel = 0; resetRow.LayoutOrder = 24
local resetBtn = Instance.new("TextButton", resetRow)
resetBtn.Size = UDim2.new(0,120,0,28); resetBtn.Position = UDim2.new(0.5,-60,0.5,-14)
resetBtn.Text = "Reset Character"; resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 12; resetBtn.TextColor3 = Color3.fromRGB(255,255,255)
resetBtn.BackgroundColor3 = C.CLOSE; resetBtn.AutoButtonColor = false
resetBtn.BorderSizePixel = 0
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0,7)
resetBtn.MouseButton1Click:Connect(function()
	pcall(function()
		for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
			if v:IsA("BasePart") then v:Destroy() end
		end
	end)
end)

-- ── PAINEL: Skill Mastery ────────────────
local skillPanel, _ = MakePanel(cfgFrame, "SKILL MASTERY", 2)
local skillList = {
	{ label = "Use Skill Z", key = "SkillZ" },
	{ label = "Use Skill X", key = "SkillX" },
	{ label = "Use Skill C", key = "SkillC" },
	{ label = "Use Skill V", key = "SkillV" },
	{ label = "Use Skill F", key = "SkillF" },
}
for i, skill in ipairs(skillList) do
	local sRow, _ = MakePanelRow(skillPanel, skill.label, i * 2)
	local sTrack = Instance.new("Frame", sRow)
	sTrack.Size = UDim2.new(0,44,0,26); sTrack.Position = UDim2.new(1,-58,0.5,-13)
	sTrack.BackgroundColor3 = C.OFF_GRAY; sTrack.BorderSizePixel = 0
	Instance.new("UICorner", sTrack).CornerRadius = UDim.new(1,0)
	local sKnob = Instance.new("Frame", sTrack)
	sKnob.Size = UDim2.new(0,22,0,22); sKnob.Position = UDim2.new(0,2,0.5,-11)
	sKnob.BackgroundColor3 = Color3.fromRGB(255,255,255); sKnob.BorderSizePixel = 0
	Instance.new("UICorner", sKnob).CornerRadius = UDim.new(1,0)
	local sBtn = Instance.new("TextButton", sTrack)
	sBtn.Size = UDim2.new(1,0,1,0); sBtn.BackgroundTransparency = 1
	sBtn.Text = ""; sBtn.AutoButtonColor = false
	local k = skill.key
	sBtn.MouseButton1Click:Connect(function()
		_G[k] = not _G[k]
		TweenService:Create(sTrack, TweenInfo.new(0.2), { BackgroundColor3 = _G[k] and C.ON_GREEN or C.OFF_GRAY }):Play()
		TweenService:Create(sKnob, TweenInfo.new(0.2), { Position = _G[k] and UDim2.new(0,20,0.5,-11) or UDim2.new(0,2,0.5,-11) }):Play()
	end)
	if i < #skillList then MakePanelSep(skillPanel, i*2+1) end
end

-- ── PAINEL: Ability Settings ─────────────
local abilityPanel, _ = MakePanel(cfgFrame, "ABILITY SETTINGS", 3)

-- Buso Haki
local busoRow, _ = MakePanelRow(abilityPanel, "Buso Haki", 2)
local busoTrack = Instance.new("Frame", busoRow)
busoTrack.Size = UDim2.new(0,44,0,26); busoTrack.Position = UDim2.new(1,-58,0.5,-13)
busoTrack.BackgroundColor3 = C.OFF_GRAY; busoTrack.BorderSizePixel = 0
Instance.new("UICorner", busoTrack).CornerRadius = UDim.new(1,0)
local busoKnob = Instance.new("Frame", busoTrack)
busoKnob.Size = UDim2.new(0,22,0,22); busoKnob.Position = UDim2.new(0,2,0.5,-11)
busoKnob.BackgroundColor3 = Color3.fromRGB(255,255,255); busoKnob.BorderSizePixel = 0
Instance.new("UICorner", busoKnob).CornerRadius = UDim.new(1,0)
local busoBtn = Instance.new("TextButton", busoTrack)
busoBtn.Size = UDim2.new(1,0,1,0); busoBtn.BackgroundTransparency = 1
busoBtn.Text = ""; busoBtn.AutoButtonColor = false
busoBtn.MouseButton1Click:Connect(function()
	BusoHaki = not BusoHaki
	TweenService:Create(busoTrack, TweenInfo.new(0.2), { BackgroundColor3 = BusoHaki and C.ON_GREEN or C.OFF_GRAY }):Play()
	TweenService:Create(busoKnob, TweenInfo.new(0.2), { Position = BusoHaki and UDim2.new(0,20,0.5,-11) or UDim2.new(0,2,0.5,-11) }):Play()
end)
task.spawn(function()
	while task.wait() do
		if BusoHaki then
			pcall(function()
				if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
					game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
				end
			end)
		end
	end
end)

MakePanelSep(abilityPanel, 3)

-- Ken Haki
local kenRow, _ = MakePanelRow(abilityPanel, "Ken Haki", 4)
local kenTrack = Instance.new("Frame", kenRow)
kenTrack.Size = UDim2.new(0,44,0,26); kenTrack.Position = UDim2.new(1,-58,0.5,-13)
kenTrack.BackgroundColor3 = C.OFF_GRAY; kenTrack.BorderSizePixel = 0
Instance.new("UICorner", kenTrack).CornerRadius = UDim.new(1,0)
local kenKnob = Instance.new("Frame", kenTrack)
kenKnob.Size = UDim2.new(0,22,0,22); kenKnob.Position = UDim2.new(0,2,0.5,-11)
kenKnob.BackgroundColor3 = Color3.fromRGB(255,255,255); kenKnob.BorderSizePixel = 0
Instance.new("UICorner", kenKnob).CornerRadius = UDim.new(1,0)
local kenBtn = Instance.new("TextButton", kenTrack)
kenBtn.Size = UDim2.new(1,0,1,0); kenBtn.BackgroundTransparency = 1
kenBtn.Text = ""; kenBtn.AutoButtonColor = false
kenBtn.MouseButton1Click:Connect(function()
	KenHaki = not KenHaki
	TweenService:Create(kenTrack, TweenInfo.new(0.2), { BackgroundColor3 = KenHaki and C.ON_GREEN or C.OFF_GRAY }):Play()
	TweenService:Create(kenKnob, TweenInfo.new(0.2), { Position = KenHaki and UDim2.new(0,20,0.5,-11) or UDim2.new(0,2,0.5,-11) }):Play()
end)
task.spawn(function()
	while task.wait() do
		if KenHaki then
			pcall(function()
				if not game.Players.LocalPlayer.Character:FindFirstChild("Highlight") then
					game:service("VirtualInputManager"):SendKeyEvent(true,  "K", false, game)
					task.wait(0.1)
					game:service("VirtualInputManager"):SendKeyEvent(false, "K", false, game)
				end
			end)
		end
	end
end)

-- ── PAINEL: Misc Setting ─────────────────
local miscSetPanel, _ = MakePanel(cfgFrame, "MISC SETTING", 4)

-- Disable Audio Effect
local audioRow, _ = MakePanelRow(miscSetPanel, "Disable Audio Effect", 2)
local audioTrack = Instance.new("Frame", audioRow)
audioTrack.Size = UDim2.new(0,44,0,26); audioTrack.Position = UDim2.new(1,-58,0.5,-13)
audioTrack.BackgroundColor3 = C.OFF_GRAY; audioTrack.BorderSizePixel = 0
Instance.new("UICorner", audioTrack).CornerRadius = UDim.new(1,0)
local audioKnob = Instance.new("Frame", audioTrack)
audioKnob.Size = UDim2.new(0,22,0,22); audioKnob.Position = UDim2.new(0,2,0.5,-11)
audioKnob.BackgroundColor3 = Color3.fromRGB(255,255,255); audioKnob.BorderSizePixel = 0
Instance.new("UICorner", audioKnob).CornerRadius = UDim.new(1,0)
local audioBtn = Instance.new("TextButton", audioTrack)
audioBtn.Size = UDim2.new(1,0,1,0); audioBtn.BackgroundTransparency = 1
audioBtn.Text = ""; audioBtn.AutoButtonColor = false
audioBtn.MouseButton1Click:Connect(function()
	DeleteAudioEffect = not DeleteAudioEffect
	TweenService:Create(audioTrack, TweenInfo.new(0.2), { BackgroundColor3 = DeleteAudioEffect and C.ON_GREEN or C.OFF_GRAY }):Play()
	TweenService:Create(audioKnob, TweenInfo.new(0.2), { Position = DeleteAudioEffect and UDim2.new(0,20,0.5,-11) or UDim2.new(0,2,0.5,-11) }):Play()
end)
task.spawn(function()
	while task.wait() do
		if DeleteAudioEffect then
			pcall(function()
				for _, v in pairs(game:GetService("Workspace")["_WorldOrigin"]:GetChildren()) do
					if v.Name == "Sounds" then
						for _, v2 in pairs(v:GetChildren()) do
							if v2:IsA("Part") then v2:Destroy() end
						end
					end
					if v.Name == "CurvedRing" or v.Name == "SlashHit" or v.Name == "SwordSlash" or v.Name == "SlashTail" then
						v:Destroy()
					end
				end
			end)
		end
	end
end)

MakePanelSep(miscSetPanel, 3)

-- Destroy Effect Animation button
local destroyEffRow = Instance.new("Frame", miscSetPanel)
destroyEffRow.Size = UDim2.new(1,0,0,44); destroyEffRow.BackgroundTransparency = 1
destroyEffRow.BorderSizePixel = 0; destroyEffRow.LayoutOrder = 4
local destroyEffBtn = Instance.new("TextButton", destroyEffRow)
destroyEffBtn.Size = UDim2.new(0,160,0,28); destroyEffBtn.Position = UDim2.new(0.5,-80,0.5,-14)
destroyEffBtn.Text = "Destroy Effect Animation"; destroyEffBtn.Font = Enum.Font.Gotham
destroyEffBtn.TextSize = 11; destroyEffBtn.TextColor3 = Color3.fromRGB(255,255,255)
destroyEffBtn.BackgroundColor3 = C.ACCENT; destroyEffBtn.AutoButtonColor = false
destroyEffBtn.BorderSizePixel = 0
Instance.new("UICorner", destroyEffBtn).CornerRadius = UDim.new(0,7)
destroyEffBtn.MouseButton1Click:Connect(function()
	pcall(function()
		for _, v in pairs(game:GetService("Workspace")["_WorldOrigin"]:GetChildren()) do
			if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Explosion") or
				v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
				v:Destroy()
			end
		end
	end)
end)

-- espaçador final da aba cfg
local cfgSpacer = Instance.new("Frame", cfgFrame)
cfgSpacer.Size = UDim2.new(1,0,0,8); cfgSpacer.BackgroundTransparency = 1
cfgSpacer.BorderSizePixel = 0; cfgSpacer.LayoutOrder = 99

local delayOptions = {} -- mantido para não quebrar referências abaixo

-- ══════════════════════════════════════════
--  LÓGICA: FAST ATTACK + BRING MOB + HIT POSITION
--
--  FastAttack: expande o hitbox do HumanoidRootPart do player
--  para um tamanho seguro (60 studs) via getrawmetatable,
--  depois ativa a tool em loop com o delay configurado.
--  O hitbox é restaurado ao desligar para evitar ban.
--
--  Bring Mob: move o HumanoidRootPart do mob para perto
--  do player usando os offsets de Hit Position/Height.
-- ══════════════════════════════════════════
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp         = Players.LocalPlayer

_G.FastAttackActive = false
_G.FastAttackDelay  = 0.15
_G.BringMobActive   = false
_G.BringMobCount    = 1
_G.HitHeight        = 15
_G.HitOffsetX       = 0
_G.HitOffsetY       = 15
_G.HitOffsetZ       = -3

-- tamanho do hitbox expandido (60 = alcance bom e seguro)
-- valores muito altos (>150) aumentam risco de detecção
local HITBOX_SIZE    = Vector3.new(60, 60, 60)
local HITBOX_DEFAULT = Vector3.new(2, 2, 1) -- tamanho original do HRP

local function parseDelay(txt)
	return tonumber(txt:match("[%d%.]+")) or 0.15
end

-- expande ou restaura o hitbox do HumanoidRootPart
local function setHitbox(hrp, expanded)
	-- usa getrawmetatable para bypassar o __newindex protegido
	local ok = pcall(function()
		local mt = getrawmetatable(game)
		setreadonly(mt, false)
		local oldNI = mt.__newindex
		mt.__newindex = rawset
		setreadonly(mt, true)

		hrp.Size = expanded and HITBOX_SIZE or HITBOX_DEFAULT

		setreadonly(mt, false)
		mt.__newindex = oldNI
		setreadonly(mt, true)
	end)
	-- fallback caso o executor não suporte getrawmetatable
	if not ok then
		pcall(function()
			hrp.Size = expanded and HITBOX_SIZE or HITBOX_DEFAULT
		end)
	end
end

-- nomes de NPCs amigáveis/vendedores para ignorar
local FRIENDLY_NPCS = {
	["Blox Fruit Dealer"] = true,
	["Blox Fruit Dealer Cousin"] = true,
	["Sword Dealer"] = true,
	["Sword Dealer Of The East"] = true,
	["Ability Teacher"] = true,
	["Master Sword Dealer"] = true,
	["Arowe"] = true,
	["Bartilo"] = true,
	["Mysterious Scientist"] = true,
	["Tort"] = true,
	["Hungry Man"] = true,
	["Sick Man"] = true,
	["Living NPCs"] = true,
	["Advanced Blade Dealer"] = true,
	["Ship Dealer"] = true,
	["Terraform"] = true,
	["Dragon Talon Sage"] = true,
	["Bon Bons"] = true,
	["Sabi"] = true,
	["Phoeyu, The Reformed"] = true,
	["Blacksmith"] = true,
	["Enchantment Specialist"] = true,
	["NPC"] = true,
}

-- retorna os N mobs mais próximos, filtrando players e NPCs amigáveis
local function getNearestMobs(count)
	local char = lp.Character
	if not char then return {} end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return {} end

	-- monta lista de nomes de players para ignorar
	local playerNames = {}
	for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
		playerNames[p.Name] = true
		-- personagem do player também
		if p.Character then
			playerNames[p.Character.Name] = true
		end
	end

	local mobs = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model") and obj ~= char then
			-- ignora outros jogadores
			if playerNames[obj.Name] then continue end
			-- ignora NPCs amigáveis/vendedores
			if FRIENDLY_NPCS[obj.Name] then continue end

			local hum    = obj:FindFirstChildOfClass("Humanoid")
			local mobHrp = obj:FindFirstChild("HumanoidRootPart")

			if hum and hum.Health > 0 and mobHrp then
				local dist = (mobHrp.Position - hrp.Position).Magnitude
				-- só considera mobs dentro do raio de farm
				if dist <= _G.FLY_RANGE then
					table.insert(mobs, { model = obj, hrp = mobHrp, dist = dist })
				end
			end
		end
	end

	table.sort(mobs, function(a, b) return a.dist < b.dist end)

	local result = {}
	for i = 1, math.min(count, #mobs) do
		result[i] = mobs[i]
	end
	return result
end

-- ao renascer: restaura hitbox mas MANTÉM os toggles como estavam
lp.CharacterAdded:Connect(function(char)
	-- mantém toggles ao renascer
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if hrp then setHitbox(hrp, false) end
end)

-- ── loop do Bring Mob (separado, intervalo maior)
-- 0.35s entre cada pull: o mob tem tempo de deslizar
-- naturalmente entre um pull e outro, sem ficar travado
task.spawn(function()
	while true do
		task.wait(0.35)

		if not _G.BringMobActive then continue end

		local char = lp.Character
		if not char then continue end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then continue end

		local mobs = getNearestMobs(_G.BringMobCount)
		for _, mob in ipairs(mobs) do
			pcall(function()
				mob.hrp.CFrame = hrp.CFrame
					* CFrame.new(_G.HitOffsetX, _G.HitOffsetY, _G.HitOffsetZ)
			end)
		end
	end
end)

-- ── loop do FastAttack (rápido, independente do Bring Mob)
task.spawn(function()
	while true do
		task.wait(0.05)

		local char = lp.Character
		if not char then continue end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum or hum.Health <= 0 then
			if hrp then setHitbox(hrp, false) end
			continue
		end

		if _G.FastAttackActive then
			setHitbox(hrp, true)
			pcall(function()
				local tool = char:FindFirstChildOfClass("Tool")
				if tool then tool:Activate() end
			end)
			task.wait(_G.FastAttackDelay)
		else
			setHitbox(hrp, false)
		end
	end
end)


local flySpeedOptions = {
	"100", "150", "200", "250", "300",
	"350", "400", "450", "500"
}

MakeDropdown(cfgFrame, flySpeedBtn, flySpeedValue, flySpeedOptions, function(val)
	_G.FlySpeed = tonumber(val) or 200
end)

-- ══════════════════════════════════════════
--  LÓGICA: VOO CONDICIONAL + AUTO NEAR MOBS
--
--  Voo OFF por padrão — personagem anda normal.
--  Liga automaticamente quando AutoNearMobs (ou outra
--  função futura) for ativada. Desliga e restaura o
--  personagem ao normal quando tudo for desativado.
-- ══════════════════════════════════════════
_G.FlySpeed     = 200
_G.AutoNearMobs = false
_G.FLY_RANGE    = 100

-- verifica se alguma função que precisa de voo está ativa
local function flyNeeded()
	return _G.AutoNearMobs -- futuramente: or _G.OutraFuncao etc
end

local DEFAULT_WALKSPEED = 16
local DEFAULT_JUMPPOWER = 50

local function cleanFly(char)
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		for _, name in ipairs({"PudimFlyBP", "PudimFlyBV", "PudimFlyBG"}) do
			local obj = hrp:FindFirstChild(name)
			if obj then obj:Destroy() end
		end
	end
	-- restaura movimento normal
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = DEFAULT_WALKSPEED
		hum.JumpPower = DEFAULT_JUMPPOWER
	end
end

local function setupFly(char)
	cleanFly(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end

	local bp = Instance.new("BodyPosition", hrp)
	bp.Name     = "PudimFlyBP"
	bp.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	bp.P        = 10000
	bp.D        = 600
	bp.Position = hrp.Position

	local bv = Instance.new("BodyVelocity", hrp)
	bv.Name     = "PudimFlyBV"
	bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
	bv.Velocity = Vector3.zero

	local bg = Instance.new("BodyGyro", hrp)
	bg.Name      = "PudimFlyBG"
	bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
	bg.P         = 10000
	bg.D         = 600
	bg.CFrame    = hrp.CFrame

	-- zera movimento pra não conflitar com voo
	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.WalkSpeed = 0
		hum.JumpPower = 0
	end

	return bp, bv, bg
end

-- estado anterior do voo pra detectar mudança
local wasFlying = false

-- respawn: NÃO reseta toggles — mantém FastAttack, AutoNearMobs etc
-- só reseta wasFlying pra forçar o voo recriar as instâncias no novo char
lp.CharacterAdded:Connect(function(newChar)
	wasFlying = false  -- força reinicialização das instâncias de voo
	task.wait(1)       -- espera o personagem carregar completamente
	-- se AutoNearMobs estava ON, o loop vai detectar wasFlying=false
	-- e recriar setupFly automaticamente no novo personagem
end)

-- ── loop principal ──────────────────────────
task.spawn(function()
	local UIS = game:GetService("UserInputService")

	while true do
		task.wait(0.1)

		local c = lp.Character
		if not c then continue end
		local hrp = c:FindFirstChild("HumanoidRootPart")
		local hum = c:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then continue end

		-- morreu: limpa voo e reseta flags
		if hum.Health <= 0 then
			if wasFlying then
				cleanFly(c)
				wasFlying = false
			end
			continue
		end

		local needFly = flyNeeded()

		-- ── voo acabou de ser desativado ──
		if wasFlying and not needFly then
			cleanFly(c)
			wasFlying = false
			continue
		end

		-- ── voo acabou de ser ativado ──
		if needFly and not wasFlying then
			setupFly(c)
			wasFlying = true
		end

		-- ── voo não necessário: personagem normal ──
		if not needFly then continue end

		-- pega instâncias (recria se sumiram — proteção anti-bug)
		local bp = hrp:FindFirstChild("PudimFlyBP")
		local bv = hrp:FindFirstChild("PudimFlyBV")
		local bg = hrp:FindFirstChild("PudimFlyBG")
		if not bp or not bv or not bg then
			setupFly(c)
			bp = hrp:FindFirstChild("PudimFlyBP")
			bv = hrp:FindFirstChild("PudimFlyBV")
			bg = hrp:FindFirstChild("PudimFlyBG")
			if not bp or not bv or not bg then continue end
		end

		-- ── Auto Near Mobs ─────────────────────
		if _G.AutoNearMobs then
			local mobs = getNearestMobs(1)
			if #mobs > 0 then
				local target    = mobs[1]
				local targetPos = target.hrp.Position
					+ Vector3.new(_G.HitOffsetX, _G.HitOffsetY, _G.HitOffsetZ)
				local dist = (hrp.Position - targetPos).Magnitude

				if dist > 5 then
					-- voa em direção ao mob
					local dir   = (targetPos - hrp.Position).Unit
					bv.Velocity = dir * _G.FlySpeed
					bp.Position = hrp.Position
				else
					-- chegou: trava exatamente na posição
					bv.Velocity = Vector3.zero
					bp.Position = targetPos
				end

				bg.CFrame = CFrame.lookAt(hrp.Position,
					Vector3.new(target.hrp.Position.X, hrp.Position.Y, target.hrp.Position.Z))
			else
				-- sem mobs: fica parado no ar onde está
				bv.Velocity = Vector3.zero
				bp.Position = hrp.Position
				bg.CFrame   = hrp.CFrame
			end
		end
	end
end)

-- ══════════════════════════════════════════
--  LABEL DE GRUPO (sidebar)
-- ══════════════════════════════════════════
local function MakeGroupLabel(text)
	local holder = Instance.new("Frame", Sidebar)
	holder.Size                   = UDim2.new(1, 0, 0, 26)
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel        = 0

	local lbl = Instance.new("TextLabel", holder)
	lbl.BackgroundTransparency = 1
	lbl.Size                   = UDim2.new(1, -16, 1, 0)
	lbl.Position               = UDim2.new(0, 12, 0, 0)
	lbl.Font                   = Enum.Font.GothamBold
	lbl.Text                   = text
	lbl.TextColor3             = C.TEXT_SEC
	lbl.TextSize               = 11
	lbl.TextXAlignment         = Enum.TextXAlignment.Left
end

local function MakeGroupCard()
	local card = Instance.new("Frame", Sidebar)
	card.Size               = UDim2.new(1, -16, 0, 0)
	card.AutomaticSize      = Enum.AutomaticSize.Y
	card.BackgroundColor3   = C.SURFACE
	card.BorderSizePixel    = 0
	card.ClipsDescendants   = true
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

	local stroke = Instance.new("UIStroke", card)
	stroke.Color     = C.DIVIDER
	stroke.Thickness = 0.8

	local layout = Instance.new("UIListLayout", card)
	layout.Padding             = UDim.new(0, 0)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	return card
end

-- ══════════════════════════════════════════
--  TABS DA SIDEBAR
-- ══════════════════════════════════════════
local TabList = {
	{ group = "GERAL",  items = { "🏠 Home", "⚙️ Configuração", "👁️ ESP" } },
	{ group = "MUNDO",  items = { "🏝️ Ilhas", "🌊 Sea Events", "🚀 Teleport" } },
	{ group = "EXTRAS", items = { "🛠️ Misc", "📜 Servidor", "🐲 Raça V4" } },
	{ group = "FARM BF",   items = { "⚔️ Farm Raid", "🌊 Farm Sea Beast", "👊 Farm Boss" } },
}

local activeTab    = nil
local activeTabRef = nil

local function applyActive(ref)
	ref.tab.BackgroundColor3 = C.TAB_ACTIVE
	ref.label.TextColor3     = C.TAB_TXT_ACT
	ref.chevron.TextColor3   = C.TAB_TXT_ACT
	Welcome.Text             = ref.name
	-- mostra frame da aba ativa, esconde os outros
	for name, f in pairs(TabFrames) do
		f.Visible = (name == ref.name)
	end
end

local function clearRef(ref)
	ref.tab.BackgroundColor3 = C.TAB_DEFAULT
	ref.label.TextColor3     = C.TAB_TXT_DEF
	ref.chevron.TextColor3   = C.TEXT_SEC
end

for _, group in ipairs(TabList) do
	local sp = Instance.new("Frame", Sidebar)
	sp.Size                   = UDim2.new(1, 0, 0, 4)
	sp.BackgroundTransparency = 1
	sp.BorderSizePixel        = 0

	MakeGroupLabel(group.group)

	local card = MakeGroupCard()

	for idx, v in ipairs(group.items) do
		-- cria o frame da aba se não existir ainda
		if not TabFrames[v] then
			MakeTabFrame(v)
		end

		local Tab = Instance.new("Frame", card)
		Tab.Size             = UDim2.new(1, 0, 0, 40)
		Tab.BackgroundColor3 = C.TAB_DEFAULT
		Tab.BorderSizePixel  = 0
		Tab.ZIndex           = 2

		local TabBtn = Instance.new("TextButton", Tab)
		TabBtn.Size                   = UDim2.new(1, 0, 1, 0)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text                   = ""
		TabBtn.ZIndex                 = 5
		TabBtn.AutoButtonColor        = false

		local Label = Instance.new("TextLabel", Tab)
		Label.BackgroundTransparency = 1
		Label.Size                   = UDim2.new(1, -36, 1, 0)
		Label.Position               = UDim2.new(0, 12, 0, 0)
		Label.Font                   = Enum.Font.Gotham
		Label.Text                   = v
		Label.TextColor3             = C.TAB_TXT_DEF
		Label.TextSize               = 13
		Label.TextXAlignment         = Enum.TextXAlignment.Left
		Label.ZIndex                 = 3

		local Chevron = Instance.new("TextLabel", Tab)
		Chevron.BackgroundTransparency = 1
		Chevron.Size                   = UDim2.new(0, 22, 1, 0)
		Chevron.Position               = UDim2.new(1, -24, 0, 0)
		Chevron.Font                   = Enum.Font.GothamBold
		Chevron.Text                   = "›"
		Chevron.TextColor3             = C.TEXT_SEC
		Chevron.TextSize               = 18
		Chevron.TextXAlignment         = Enum.TextXAlignment.Center
		Chevron.ZIndex                 = 3

		if idx < #group.items then
			local sep = Instance.new("Frame", Tab)
			sep.Size             = UDim2.new(1, -12, 0, 1)
			sep.Position         = UDim2.new(0, 12, 1, -1)
			sep.BackgroundColor3 = C.DIVIDER
			sep.BorderSizePixel  = 0
			sep.ZIndex           = 4
		end

		local ref = { tab = Tab, label = Label, chevron = Chevron, name = v }

		TabBtn.MouseEnter:Connect(function()
			if Tab ~= activeTab then
				Tab.BackgroundColor3 = C.TAB_HOVER
				Label.TextColor3     = C.TEXT_SEC
			end
		end)
		TabBtn.MouseLeave:Connect(function()
			if Tab ~= activeTab then
				Tab.BackgroundColor3 = C.TAB_DEFAULT
				Label.TextColor3     = C.TAB_TXT_DEF
			end
		end)
		TabBtn.MouseButton1Click:Connect(function()
			if activeTabRef and activeTabRef.tab ~= Tab then
				clearRef(activeTabRef)
			end
			activeTab    = Tab
			activeTabRef = ref
			applyActive(ref)
		end)
	end

	local sp2 = Instance.new("Frame", Sidebar)
	sp2.Size                   = UDim2.new(1, 0, 0, 4)
	sp2.BackgroundTransparency = 1
	sp2.BorderSizePixel        = 0
end

-- ══════════════════════════════════════════
--  TRAY
-- ══════════════════════════════════════════
local Tray = Instance.new("Frame", ScreenGui)
Tray.Size             = UDim2.new(0, 36, 0, 120)
Tray.Position         = UDim2.new(0, 0, 0.5, -60)
Tray.BackgroundColor3 = C.SURFACE
Tray.Visible          = false
Tray.Active           = true
Tray.Draggable        = true
Tray.BorderSizePixel  = 0
Tray.ZIndex           = 10
Instance.new("UICorner", Tray).CornerRadius = UDim.new(0, 12)
local TrayStroke = Instance.new("UIStroke", Tray)
TrayStroke.Color     = C.DIVIDER
TrayStroke.Thickness = 1

local TrayEmoji = Instance.new("TextLabel", Tray)
TrayEmoji.BackgroundTransparency = 1
TrayEmoji.Size                   = UDim2.new(1, 0, 0, 30)
TrayEmoji.Position               = UDim2.new(0, 0, 0, 6)
TrayEmoji.Text                   = "🍮"
TrayEmoji.TextSize               = 18
TrayEmoji.Font                   = Enum.Font.Gotham
TrayEmoji.TextXAlignment         = Enum.TextXAlignment.Center
TrayEmoji.ZIndex                 = 11

local TrayLabel = Instance.new("TextLabel", Tray)
TrayLabel.BackgroundTransparency = 1
TrayLabel.Size                   = UDim2.new(0, 80, 0, 18)
TrayLabel.Position               = UDim2.new(0.5, -40, 0.5, -9)
TrayLabel.Rotation               = 90
TrayLabel.Font                   = Enum.Font.GothamBold
TrayLabel.Text                   = "PudimHub"
TrayLabel.TextColor3             = C.TEXT_PRIMARY
TrayLabel.TextSize               = 11
TrayLabel.TextXAlignment         = Enum.TextXAlignment.Center
TrayLabel.ZIndex                 = 11

local TrayBtn = Instance.new("TextButton", Tray)
TrayBtn.Size                   = UDim2.new(1, 0, 1, 0)
TrayBtn.BackgroundTransparency = 1
TrayBtn.Text                   = ""
TrayBtn.ZIndex                 = 12
TrayBtn.AutoButtonColor        = false

-- ══════════════════════════════════════════
--  ABRIR / FECHAR / MINIMIZAR
-- ══════════════════════════════════════════
local minimized = false

local function showMain()
	Shadow.Visible        = true
	MainFrame.Visible     = true
	Tray.Visible          = false
	MainFrame.Position    = UDim2.new(0.5, -320, 0.5, -240)
	TweenService:Create(MainFrame,
		TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0.5, -320, 0.5, -220) }
	):Play()
	if not minimized then
		Sidebar.Visible       = true
		ContentScroll.Visible = true
	end
	if activeTabRef then applyActive(activeTabRef) end
end

local function hideMain()
	local t = TweenService:Create(MainFrame,
		TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{ Position = UDim2.new(0.5, -320, 0.5, -205) }
	)
	t:Play()
	t.Completed:Once(function()
		MainFrame.Visible = false
		Shadow.Visible    = false
	end)
	Tray.Visible = true
end

BtnClose.MouseButton1Click:Connect(hideMain)

BtnMin.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		Sidebar.Visible       = false
		ContentScroll.Visible = false
		TweenService:Create(MainFrame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 640, 0, 52) }
		):Play()
	else
		TweenService:Create(MainFrame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 640, 0, 440) }
		):Play()
		task.delay(0.2, function()
			Sidebar.Visible       = true
			ContentScroll.Visible = true
		end)
	end
end)

TrayBtn.MouseButton1Click:Connect(showMain)

print("PudimHub Premium — Blox Fruits carregado!")