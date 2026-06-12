-- PudimHub v3 Premium 2026 🍮 (Script Completo com FastAttack Funcional)
-- ============================================================
-- CONFIGURAÇÃO DE CORES
-- ============================================================
local Theme = {
	MainBg = Color3.fromRGB(240, 244, 248),
	GradientStart = Color3.fromRGB(245, 247, 250),
	GradientEnd = Color3.fromRGB(230, 236, 242),
	
	Accent = Color3.fromRGB(64, 150, 255),         -- Azul Principal
	AccentHover = Color3.fromRGB(40, 120, 225),
	AccentDark = Color3.fromRGB(20, 90, 180),
	
	TopBar = Color3.fromRGB(255, 255, 255),
	Sidebar = Color3.fromRGB(225, 232, 240),
	Content = Color3.fromRGB(255, 255, 255),
	
	TabDefault = Color3.fromRGB(210, 218, 228),
	TabHover = Color3.fromRGB(195, 205, 218),
	TextDefault = Color3.fromRGB(45, 55, 72),
	TextActive = Color3.fromRGB(255, 255, 255),
	
	CardBg = Color3.fromRGB(235, 240, 246),
	
	iOS_On = Color3.fromRGB(52, 199, 89),          -- Verde iOS
	iOS_Off = Color3.fromRGB(224, 224, 226),        -- Cinza claro iOS
	iOS_Ball = Color3.fromRGB(255, 255, 255)
}

-- CONFIGURAÇÃO DE SCRIPT (Valores padrão)
local AttackDelay = 0.15
local BringMobAmount = 6 
local FlySpeed = 100
local FarmPosition = "Em cima" 
local FarmDistance = 15        
local FastAttackAtivo = false

-- SERVICES
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- CLEANUP (Evita duplicar o menu na tela)
if game.CoreGui:FindFirstChild("PudimHubPremium") then
	game.CoreGui.PudimHubPremium:Destroy()
end

-- INITIALIZATION
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PudimHubPremium"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- ============================================================
-- LÓGICA INTERNA DO FASTATTACK (BLOOF FRUITS)
-- ============================================================
local CombatFramework
local pcallSuccess, pcallError = pcall(function()
	CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
end)

local function ExecutarAtaqueRapido()
	task.spawn(function()
		while FastAttackAtivo do
			local delayAtual = AttackDelay or 0.15 
			
			pcall(function()
				if CombatFramework and CombatFramework.activeController then
					local ac = CombatFramework.activeController
					if ac.mountedWeapon and ac.blades and ac.blades[1] then
						-- Aplica o alcance longo (Hitbox)
						ac.hitboxMagnitude = 55 
						-- Envia o sinal de ataque rápido para o servidor
						game:GetService("ReplicatedStorage").Modules.Net:FindFirstChild("RE/WeaponHitboxEvent"):FireServer(ac.blades[1], ac.mountedWeapon.name)
					end
				end
			end)
			
			task.wait(delayAtual)
		end
	end)
end

-- ============================================================
-- OUTER FRAME (Sombra e Drag)
-- ============================================================
local OuterFrame = Instance.new("Frame")
OuterFrame.Name = "OuterFrame"
OuterFrame.Parent = ScreenGui
OuterFrame.Size = UDim2.new(0, 640, 0, 440)
OuterFrame.Position = UDim2.new(0.5, -320, 0.5, -220)
OuterFrame.BackgroundTransparency = 1
OuterFrame.Active = true

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = OuterFrame
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
Shadow.Size = UDim2.new(1, 34, 1, 34)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897043"
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.82
Shadow.ZIndex = 1

-- ============================================================
-- MAINFRAME
-- ============================================================
local MainFrame = Instance.new("CanvasGroup")
MainFrame.Name = "MainFrame"
MainFrame.Parent = OuterFrame
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Theme.MainBg
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 2

local Corner = Instance.new("UICorner", MainFrame)
Corner.CornerRadius = UDim.new(0, 14)

local BgGradient = Instance.new("UIGradient", MainFrame)
BgGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Theme.GradientStart),
	ColorSequenceKeypoint.new(1, Theme.GradientEnd),
}
BgGradient.Rotation = 135

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Theme.Accent
Stroke.Thickness = 1.2
Stroke.Transparency = 0.5

-- ============================================================
-- SISTEMA DE ARRASTAR (DRAG)
-- ============================================================
local dragging, dragInput, dragStart, startPosition

local function updateDrag(input)
	local delta = input.Position - dragStart
	OuterFrame.Position = UDim2.new(
		startPosition.X.Scale, startPosition.X.Offset + delta.X, 
		startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
	)
end

OuterFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = OuterFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

OuterFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateDrag(input)
	end
end)

-- ============================================================
-- TOPBAR (Barra Superior)
-- ============================================================
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Theme.TopBar
TopBar.ZIndex = 3

local Gradient = Instance.new("UIGradient", TopBar)
Gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Theme.Accent),
	ColorSequenceKeypoint.new(0.55, Theme.AccentHover),
	ColorSequenceKeypoint.new(1, Theme.AccentDark),
}
Gradient.Rotation = 90

local TopBarDivider = Instance.new("Frame", MainFrame)
TopBarDivider.Size = UDim2.new(1, 0, 0, 1)
TopBarDivider.Position = UDim2.new(0, 0, 0, 42)
TopBarDivider.BackgroundColor3 = Theme.Accent
TopBarDivider.BackgroundTransparency = 0.5
TopBarDivider.BorderSizePixel = 0
TopBarDivider.ZIndex = 4

local Title = Instance.new("TextLabel", TopBar)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "PUDIMHUB PREMIUM"
Title.TextColor3 = Theme.TextActive
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 4

local function MakeBtn(txt, pos, colorNormal, colorHover)
	local b = Instance.new("TextButton", TopBar)
	b.Size = UDim2.new(0, 24, 0, 24)
	b.Position = pos
	b.Text = txt
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextColor3 = Color3.new(1, 1, 1)
	b.BackgroundColor3 = colorNormal
	b.AutoButtonColor = false
	b.ZIndex = 5
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { 
			BackgroundColor3 = colorHover,
			Size = UDim2.new(0, 26, 0, 26),
			Position = pos + UDim2.new(0, -1, 0, -1)
		}):Play()
	end)
	b.MouseLeave:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { 
			BackgroundColor3 = colorNormal,
			Size = UDim2.new(0, 24, 0, 24),
			Position = pos
		}):Play()
	end)
	return b
end

local Close = MakeBtn("✕", UDim2.new(1, -34, 0.5, -12), Color3.fromRGB(235, 90, 90), Color3.fromRGB(255, 60, 60))
local Min   = MakeBtn("−", UDim2.new(1, -66, 0.5, -12), Color3.fromRGB(160, 175, 195), Color3.fromRGB(130, 145, 165))

-- ============================================================
-- SIDEBAR & CONTENT (Menu Lateral e Telas)
-- ============================================================
local Sidebar = Instance.new("ScrollingFrame", MainFrame)
Sidebar.Position = UDim2.new(0, 8, 0, 50)
Sidebar.Size = UDim2.new(0, 158, 1, -58)
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.ScrollBarThickness = 3
Sidebar.ScrollBarImageColor3 = Theme.Accent
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local SidebarStroke = Instance.new("UIStroke", Sidebar)
SidebarStroke.Color = Color3.fromRGB(200, 210, 225)
SidebarStroke.Thickness = 1

local SidebarPadding = Instance.new("UIPadding", Sidebar)
SidebarPadding.PaddingTop    = UDim.new(0, 8)
SidebarPadding.PaddingBottom = UDim.new(0, 8)
SidebarPadding.PaddingLeft   = UDim.new(0, 6)
SidebarPadding.PaddingRight  = UDim.new(0, 6)

local Layout = Instance.new("UIListLayout", Sidebar)
Layout.Padding = UDim.new(0, 6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Content = Instance.new("ScrollingFrame", MainFrame)
Content.Position = UDim2.new(0, 174, 0, 50)
Content.Size = UDim2.new(1, -182, 1, -58)
Content.BackgroundColor3 = Theme.Content
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Theme.Accent
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 10)

local ContentStroke = Instance.new("UIStroke", Content)
ContentStroke.Color = Color3.fromRGB(200, 210, 225)
ContentStroke.Thickness = 1

local ContentPadding = Instance.new("UIPadding", Content)
ContentPadding.PaddingTop = UDim.new(0, 12)
ContentPadding.PaddingLeft = UDim.new(0, 14)
ContentPadding.PaddingRight = UDim.new(0, 14)

local ContentLayout = Instance.new("UIListLayout", Content)
ContentLayout.Padding = UDim.new(0, 14)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Welcome = Instance.new("TextLabel")
Welcome.Name = "WelcomeLabel"
Welcome.Parent = Content
Welcome.BackgroundTransparency = 1
Welcome.Size = UDim2.new(1, 0, 0, 25)
Welcome.Font = Enum.Font.GothamBold
Welcome.Text = "Home"
Welcome.TextColor3 = Theme.Accent
Welcome.TextSize = 16
Welcome.TextXAlignment = Enum.TextXAlignment.Left
Welcome.LayoutOrder = 1

local WelcomeLine = Instance.new("Frame")
WelcomeLine.Name = "WelcomeLine"
WelcomeLine.Parent = Content
WelcomeLine.Size = UDim2.new(1, 0, 0, 1)
WelcomeLine.BackgroundColor3 = Theme.Accent
WelcomeLine.BackgroundTransparency = 0.4
WelcomeLine.BorderSizePixel = 0
WelcomeLine.LayoutOrder = 2

local HomeView = Instance.new("Frame", Content)
HomeView.Size = UDim2.new(1, 0, 0, 100)
HomeView.BackgroundTransparency = 1
HomeView.LayoutOrder = 3

local ConfigView = Instance.new("Frame", Content)
ConfigView.Size = UDim2.new(1, 0, 0, 0)
ConfigView.AutomaticSize = Enum.AutomaticSize.Y
ConfigView.BackgroundTransparency = 1
ConfigView.Visible = false
ConfigView.LayoutOrder = 4

local ConfigLayout = Instance.new("UIListLayout", ConfigView)
ConfigLayout.Padding = UDim.new(0, 12)

local HomeTxt = Instance.new("TextLabel", HomeView)
HomeTxt.Size = UDim2.new(1, 0, 1, 0)
HomeTxt.BackgroundTransparency = 1
HomeTxt.Text = "Selecione a aba Configuração para gerenciar os painéis!"
HomeTxt.Font = Enum.Font.Gotham
HomeTxt.TextSize = 13
HomeTxt.TextColor3 = Theme.TextDefault
HomeTxt.TextWrapped = true

-- ============================================================
-- FUNÇÃO AUXILIAR: CRIAR SWITCH ESTILO IPHONE (iOS)
-- ============================================================
local function CreateiOSSwitch(parent, callback)
	local SwitchFrame = Instance.new("TextButton", parent)
	SwitchFrame.Size = UDim2.new(0, 44, 0, 24)
	SwitchFrame.BackgroundColor3 = Theme.iOS_Off
	SwitchFrame.Text = ""
	SwitchFrame.AutoButtonColor = false
	Instance.new("UICorner", SwitchFrame).CornerRadius = UDim.new(1, 0)

	local Ball = Instance.new("Frame", SwitchFrame)
	Ball.Size = UDim2.new(0, 20, 0, 20)
	Ball.Position = UDim2.new(0, 2, 0.5, -10)
	Ball.BackgroundColor3 = Theme.iOS_Ball
	Instance.new("UICorner", Ball).CornerRadius = UDim.new(1, 0)

	local isActive = false
	SwitchFrame.MouseButton1Click:Connect(function()
		isActive = not isActive
		
		local targetPos = isActive and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
		local targetColor = isActive and Theme.iOS_On or Theme.iOS_Off
		
		TweenService:Create(Ball, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
		TweenService:Create(SwitchFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
		
		if callback then callback(isActive) end
	end)
end

-- ============================================================
-- PAINÉIS DA ABA CONFIGURAÇÃO
-- ============================================================

-- 1. PAINEL DO FAST ATTACK (LÓGICA INCLUÍDA)
local FastAttackCard = Instance.new("Frame", ConfigView)
FastAttackCard.Size = UDim2.new(1, 0, 0, 155)
FastAttackCard.BackgroundColor3 = Theme.CardBg
Instance.new("UICorner", FastAttackCard).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", FastAttackCard).Color = Color3.fromRGB(215, 225, 235)

local FACardLabel = Instance.new("TextLabel", FastAttackCard)
FACardLabel.Size = UDim2.new(1, -20, 0, 25)
FACardLabel.Position = UDim2.new(0, 12, 0, 8)
FACardLabel.BackgroundTransparency = 1
FACardLabel.Text = "Selecione o Delay do Ataque (Segundos):"
FACardLabel.Font = Enum.Font.GothamBold
FACardLabel.TextSize = 11
FACardLabel.TextColor3 = Theme.TextDefault
FACardLabel.TextXAlignment = Enum.TextXAlignment.Left

local GridContainer = Instance.new("Frame", FastAttackCard)
GridContainer.Size = UDim2.new(1, -24, 0, 65)
GridContainer.Position = UDim2.new(0, 12, 0, 36)
GridContainer.BackgroundTransparency = 1

local Grid = Instance.new("UIGridLayout", GridContainer)
Grid.CellSize = UDim2.new(0, 48, 0, 26)
Grid.CellPadding = UDim2.new(0, 8, 0, 6)

local Delays = {0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.75, 0.80, 0.90, 1.0}
local DelayButtons = {}

for i, delayVal in ipairs(Delays) do
	local DBtn = Instance.new("TextButton", GridContainer)
	DBtn.Text = tostring(delayVal)
	DBtn.Font = Enum.Font.GothamBold
	DBtn.TextSize = 11
	DBtn.AutoButtonColor = false
	Instance.new("UICorner", DBtn).CornerRadius = UDim.new(0, 4)
	
	if delayVal == AttackDelay then
		DBtn.BackgroundColor3 = Theme.Accent
		DBtn.TextColor3 = Theme.TextActive
	else
		DBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		DBtn.TextColor3 = Theme.TextDefault
	end
	
	DBtn.MouseButton1Click:Connect(function()
		AttackDelay = delayVal
		for _, btn in ipairs(DelayButtons) do
			btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextColor3 = Theme.TextDefault
		end
		DBtn.BackgroundColor3 = Theme.Accent
		DBtn.TextColor3 = Theme.TextActive
	end)
	table.insert(DelayButtons, DBtn)
end

local FAToggleRow = Instance.new("Frame", FastAttackCard)
FAToggleRow.Size = UDim2.new(1, -24, 0, 34)
FAToggleRow.Position = UDim2.new(0, 12, 1, -42)
FAToggleRow.BackgroundTransparency = 1

local FAToggleLabel = Instance.new("TextLabel", FAToggleRow)
FAToggleLabel.Size = UDim2.new(1, -60, 1, 0)
FAToggleLabel.BackgroundTransparency = 1
FAToggleLabel.Text = "Ativar FastAttack (Alcance Longo)"
FAToggleLabel.Font = Enum.Font.GothamBold
FAToggleLabel.TextSize = 12
FAToggleLabel.TextColor3 = Theme.TextDefault
FAToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Liga e Desliga o Ataque Conectado à Lógica
CreateiOSSwitch(FAToggleRow, function(state)
	FastAttackAtivo = state
	if FastAttackAtivo then
		ExecutarAtaqueRapido()
	end
end)


-- 2. PAINEL DO BRING MOB
local BringMobCard = Instance.new("Frame", ConfigView)
BringMobCard.Size = UDim2.new(1, 0, 0, 95)
BringMobCard.BackgroundColor3 = Theme.CardBg
BringMobCard.ZIndex = 10
Instance.new("UICorner", BringMobCard).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", BringMobCard).Color = Color3.fromRGB(215, 225, 235)

local BMDropdownRow = Instance.new("Frame", BringMobCard)
BMDropdownRow.Size = UDim2.new(1, -24, 0, 40)
BMDropdownRow.Position = UDim2.new(0, 12, 0, 6)
BMDropdownRow.BackgroundTransparency = 1

local BMCardLabel = Instance.new("TextLabel", BMDropdownRow)
BMCardLabel.Size = UDim2.new(0, 150, 1, 0)
BMCardLabel.BackgroundTransparency = 1
BMCardLabel.Text = "Quantidade de Mobs:"
BMCardLabel.Font = Enum.Font.GothamBold
BMCardLabel.TextSize = 12
BMCardLabel.TextColor3 = Theme.TextDefault
BMCardLabel.TextXAlignment = Enum.TextXAlignment.Left

local DropdownBtn = Instance.new("TextButton", BMDropdownRow)
DropdownBtn.Size = UDim2.new(0, 110, 0, 26)
DropdownBtn.Position = UDim2.new(1, -110, 0.5, -13)
DropdownBtn.Text = "mobs: 6 ▼"
DropdownBtn.Font = Enum.Font.GothamBold
DropdownBtn.TextSize = 11
DropdownBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DropdownBtn.TextColor3 = Theme.TextDefault
Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", DropdownBtn).Color = Theme.Accent

local DropdownList = Instance.new("Frame", BringMobCard)
DropdownList.Size = UDim2.new(0, 110, 0, 155)
DropdownList.Position = UDim2.new(1, -122, 0, 38)
DropdownList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
DropdownList.Visible = false
DropdownList.ZIndex = 11
Instance.new("UICorner", DropdownList).CornerRadius = UDim.new(0, 6)
local DLStroke = Instance.new("UIStroke", DropdownList)
DLStroke.Color = Theme.Accent

local DLListLayout = Instance.new("UIListLayout", DropdownList)
DLListLayout.Padding = UDim.new(0, 2)
DLListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local DropdownPadding = Instance.new("UIPadding", DropdownList)
DropdownPadding.PaddingTop = UDim.new(0, 4)

for i = 1, 6 do
	local ChoiceBtn = Instance.new("TextButton", DropdownList)
	ChoiceBtn.Size = UDim2.new(0, 100, 0, 22)
	ChoiceBtn.Text = "mobs: " .. tostring(i)
	ChoiceBtn.Font = Enum.Font.Gotham
	ChoiceBtn.TextSize = 11
	ChoiceBtn.BackgroundColor3 = Color3.fromRGB(245, 247, 250)
	ChoiceBtn.TextColor3 = Theme.TextDefault
	ChoiceBtn.ZIndex = 12
	Instance.new("UICorner", ChoiceBtn).CornerRadius = UDim.new(0, 4)
	
	ChoiceBtn.MouseButton1Click:Connect(function()
		BringMobAmount = i
		DropdownBtn.Text = "mobs: " .. tostring(i) .. " ▼"
		DropdownList.Visible = false
	end)
end

DropdownBtn.MouseButton1Click:Connect(function()
	DropdownList.Visible = not DropdownList.Visible
end)

local BMToggleRow = Instance.new("Frame", BringMobCard)
BMToggleRow.Size = UDim2.new(1, -24, 0, 34)
BMToggleRow.Position = UDim2.new(0, 12, 1, -40)
BMToggleRow.BackgroundTransparency = 1

local BMToggleLabel = Instance.new("TextLabel", BMToggleRow)
BMToggleLabel.Size = UDim2.new(1, -60, 1, 0)
BMToggleLabel.BackgroundTransparency = 1
BMToggleLabel.Text = "Ativar Bring Mob"
BMToggleLabel.Font = Enum.Font.GothamBold
BMToggleLabel.TextSize = 12
BMToggleLabel.TextColor3 = Theme.TextDefault
BMToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

CreateiOSSwitch(BMToggleRow, function(state)
	print("Bring Mob modificado para: " .. tostring(state))
end)


-- 3. PAINEL: VELOCIDADE DE VOO
local FlyCard = Instance.new("Frame", ConfigView)
FlyCard.Size = UDim2.new(1, 0, 0, 110)
FlyCard.BackgroundColor3 = Theme.CardBg
Instance.new("UICorner", FlyCard).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", FlyCard).Color = Color3.fromRGB(215, 225, 235)

local FlyCardLabel = Instance.new("TextLabel", FlyCard)
FlyCardLabel.Size = UDim2.new(1, -20, 0, 25)
FlyCardLabel.Position = UDim2.new(0, 12, 0, 8)
FlyCardLabel.BackgroundTransparency = 1
FlyCardLabel.Text = "Velocidade de Voo (Sempre Ativo):"
FlyCardLabel.Font = Enum.Font.GothamBold
FlyCardLabel.TextSize = 11
FlyCardLabel.TextColor3 = Theme.TextDefault
FlyCardLabel.TextXAlignment = Enum.TextXAlignment.Left

local FlyGridContainer = Instance.new("Frame", FlyCard)
FlyGridContainer.Size = UDim2.new(1, -24, 0, 65)
FlyGridContainer.Position = UDim2.new(0, 12, 0, 36)
FlyGridContainer.BackgroundTransparency = 1

local FlyGrid = Instance.new("UIGridLayout", FlyGridContainer)
FlyGrid.CellSize = UDim2.new(0, 48, 0, 26)
FlyGrid.CellPadding = UDim2.new(0, 8, 0, 6)

local Speeds = {100, 150, 200, 250, 300, 350, 400, 450, 500}
local SpeedButtons = {}

for i, speedVal in ipairs(Speeds) do
	local SBtn = Instance.new("TextButton", FlyGridContainer)
	SBtn.Text = tostring(speedVal)
	SBtn.Font = Enum.Font.GothamBold
	SBtn.TextSize = 11
	SBtn.AutoButtonColor = false
	Instance.new("UICorner", SBtn).CornerRadius = UDim.new(0, 4)
	
	if speedVal == FlySpeed then
		SBtn.BackgroundColor3 = Theme.Accent
		SBtn.TextColor3 = Theme.TextActive
	else
		SBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SBtn.TextColor3 = Theme.TextDefault
	end
	
	SBtn.MouseButton1Click:Connect(function()
		FlySpeed = speedVal
		for _, btn in ipairs(SpeedButtons) do
			btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextColor3 = Theme.TextDefault
		end
		SBtn.BackgroundColor3 = Theme.Accent
		SBtn.TextColor3 = Theme.TextActive
	end)
	table.insert(SpeedButtons, SBtn)
end


-- 4. PAINEL: POSICIONAMENTO DO FARM (Posição & Altura)
local PosCard = Instance.new("Frame", ConfigView)
PosCard.Size = UDim2.new(1, 0, 0, 150) 
PosCard.BackgroundColor3 = Theme.CardBg
Instance.new("UICorner", PosCard).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", PosCard).Color = Color3.fromRGB(215, 225, 235)

local PosLabel = Instance.new("TextLabel", PosCard)
PosLabel.Size = UDim2.new(1, -20, 0, 25)
PosLabel.Position = UDim2.new(0, 12, 0, 8)
PosLabel.BackgroundTransparency = 1
PosLabel.Text = "Posição do Farm em relação ao Mob:"
PosLabel.Font = Enum.Font.GothamBold
PosLabel.TextSize = 11
PosLabel.TextColor3 = Theme.TextDefault
PosLabel.TextXAlignment = Enum.TextXAlignment.Left

local PosContainer = Instance.new("Frame", PosCard)
PosContainer.Size = UDim2.new(1, -24, 0, 28)
PosContainer.Position = UDim2.new(0, 12, 0, 34)
PosContainer.BackgroundTransparency = 1

local PosLayout = Instance.new("UIListLayout", PosContainer)
PosLayout.FillDirection = Enum.FillDirection.Horizontal
PosLayout.Padding = UDim.new(0, 8)

local Positions = {"Em cima", "Do lado", "Debaixo"}
local PosButtons = {}

for _, posType in ipairs(Positions) do
	local PBtn = Instance.new("TextButton", PosContainer)
	PBtn.Size = UDim2.new(0, 75, 1, 0)
	PBtn.Text = posType
	PBtn.Font = Enum.Font.GothamBold
	PBtn.TextSize = 11
	PBtn.AutoButtonColor = false
	Instance.new("UICorner", PBtn).CornerRadius = UDim.new(0, 5)
	
	if posType == FarmPosition then
		PBtn.BackgroundColor3 = Theme.Accent
		PBtn.TextColor3 = Theme.TextActive
	else
		PBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		PBtn.TextColor3 = Theme.TextDefault
	end
	
	PBtn.MouseButton1Click:Connect(function()
		FarmPosition = posType
		for _, btn in ipairs(PosButtons) do
			btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextColor3 = Theme.TextDefault
		end
		PBtn.BackgroundColor3 = Theme.Accent
		PBtn.TextColor3 = Theme.TextActive
		print("Posição do farm alterada para: " .. FarmPosition)
	end)
	table.insert(PosButtons, PBtn)
end

local DistLabel = Instance.new("TextLabel", PosCard)
DistLabel.Size = UDim2.new(1, -20, 0, 25)
DistLabel.Position = UDim2.new(0, 12, 0, 74)
DistLabel.BackgroundTransparency = 1
DistLabel.Text = "Distância do Personagem ao Mob (Altura em studs):"
DistLabel.Font = Enum.Font.GothamBold
DistLabel.TextSize = 11
DistLabel.TextColor3 = Theme.TextDefault
DistLabel.TextXAlignment = Enum.TextXAlignment.Left

local DistContainer = Instance.new("Frame", PosCard)
DistContainer.Size = UDim2.new(1, -24, 0, 28)
DistContainer.Position = UDim2.new(0, 12, 0, 100)
DistContainer.BackgroundTransparency = 1

local DistLayout = Instance.new("UIListLayout", DistContainer)
DistLayout.FillDirection = Enum.FillDirection.Horizontal
DistLayout.Padding = UDim.new(0, 8)

local Distances = {10, 15, 20, 25, 30}
local DistButtons = {}

for _, distVal in ipairs(Distances) do
	local DBtn = Instance.new("TextButton", DistContainer)
	DBtn.Size = UDim2.new(0, 42, 1, 0)
	DBtn.Text = tostring(distVal)
	DBtn.Font = Enum.Font.GothamBold
	DBtn.TextSize = 11
	DBtn.AutoButtonColor = false
	Instance.new("UICorner", DBtn).CornerRadius = UDim.new(0, 5)
	
	if distVal == FarmDistance then
		DBtn.BackgroundColor3 = Theme.Accent
		DBtn.TextColor3 = Theme.TextActive
	else
		DBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		DBtn.TextColor3 = Theme.TextDefault
	end
	
	DBtn.MouseButton1Click:Connect(function()
		FarmDistance = distVal
		for _, btn in ipairs(DistButtons) do
			btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			btn.TextColor3 = Theme.TextDefault
		end
		DBtn.BackgroundColor3 = Theme.Accent
		DBtn.TextColor3 = Theme.TextActive
		print("Distância do farm alterada para: " .. tostring(FarmDistance) .. " studs")
	end)
	table.insert(DistButtons, DBtn)
end


-- ============================================================
-- GERENCIADOR DE ABAS (TABS)
-- ============================================================
local TabsData = {
	{Name = "Home", Id = "rbxassetid://4483362458", View = HomeView},
	{Name = "Configuração", Id = "rbxassetid://4483364237", View = ConfigView},
	{Name = "ESP", Id = "rbxassetid://4483345998", View = nil},
	{Name = "Ilhas", Id = "rbxassetid://4483343384", View = nil},
	{Name = "Eventos do Mar", Id = "rbxassetid://4483367527", View = nil},
	{Name = "Teleporte", Id = "rbxassetid://4483355325", View = nil},
	{Name = "Misc", Id = "rbxassetid://4483362748", View = nil},
	{Name = "Servidor", Id = "rbxassetid://4483367711", View = nil},
	{Name = "Raça V4", Id = "rbxassetid://4483358045", View = nil},
	{Name = "Farm 2", Id = "rbxassetid://4483362534", View = nil},
	{Name = "Farm 3", Id = "rbxassetid://4483362534", View = nil},
	{Name = "Farm 4", Id = "rbxassetid://4483362534", View = nil}
}

local activeTab = nil

for _, data in ipairs(TabsData) do
	local Tab = Instance.new("TextButton", Sidebar)
	Tab.Size = UDim2.new(1, 0, 0, 34)
	Tab.Text = ""
	Tab.BackgroundColor3 = Theme.TabDefault
	Tab.AutoButtonColor = false
	Instance.new("UICorner", Tab).CornerRadius = UDim.new(0, 6)

	local Icon = Instance.new("ImageLabel", Tab)
	Icon.Size = UDim2.new(0, 16, 0, 16)
	Icon.Position = UDim2.new(0, 10, 0.5, -8)
	Icon.BackgroundTransparency = 1
	Icon.Image = data.Id
	Icon.ImageColor3 = Theme.TextDefault
	Icon.ZIndex = 4

	local TextLabel = Instance.new("TextLabel", Tab)
	TextLabel.Size = UDim2.new(1, -36, 1, 0)
	TextLabel.Position = UDim2.new(0, 34, 0, 0)
	TextLabel.BackgroundTransparency = 1
	TextLabel.Font = Enum.Font.Gotham
	TextLabel.Text = data.Name
	TextLabel.TextSize = 12
	TextLabel.TextColor3 = Theme.TextDefault
	TextLabel.TextXAlignment = Enum.TextXAlignment.Left
	TextLabel.ZIndex = 4

	local Pill = Instance.new("Frame", Tab)
	Pill.Size = UDim2.new(0, 3, 0.5, 0)
	Pill.Position = UDim2.new(0, 0, 0.25, 0)
	Pill.BackgroundColor3 = Theme.AccentDark
	Pill.BackgroundTransparency = 1
	Pill.BorderSizePixel = 0
	Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)

	Tab.MouseEnter:Connect(function()
		if Tab ~= activeTab then
			TweenService:Create(Tab, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundColor3 = Theme.TabHover }):Play()
		end
	end)
	
	Tab.MouseLeave:Connect(function()
		if Tab ~= activeTab then
			TweenService:Create(Tab, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { BackgroundColor3 = Theme.TabDefault }):Play()
		end
	end)

	Tab.MouseButton1Click:Connect(function()
		if activeTab and activeTab ~= Tab then
			local prevPill = activeTab:FindFirstChild("Frame")
			local prevIcon = activeTab:FindFirstChildOfClass("ImageLabel")
			local prevText = activeTab:FindFirstChildOfClass("TextLabel")
			
			TweenService:Create(activeTab, TweenInfo.new(0.18), { BackgroundColor3 = Theme.TabDefault }):Play()
			if prevPill then TweenService:Create(prevPill, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play() end
			if prevIcon then TweenService:Create(prevIcon, TweenInfo.new(0.18), { ImageColor3 = Theme.TextDefault }):Play() end
			if prevText then prevText.TextColor3 = Theme.TextDefault end
		end

		activeTab = Tab
		TweenService:Create(Tab, TweenInfo.new(0.18), { BackgroundColor3 = Theme.Accent }):Play()
		TextLabel.TextColor3 = Theme.TextActive
		Icon.ImageColor3 = Theme.TextActive
		TweenService:Create(Pill, TweenInfo.new(0.18), { BackgroundTransparency = 0 }):Play()

		Welcome.Text = data.Name
		
		HomeView.Visible = (data.View == HomeView)
		ConfigView.Visible = (data.View == ConfigView)
		
		DropdownList.Visible = false
	end)
	
	if data.Name == "Home" then
		activeTab = Tab
		Tab.BackgroundColor3 = Theme.Accent
		TextLabel.TextColor3 = Theme.TextActive
		Icon.ImageColor3 = Theme.TextActive
		Pill.BackgroundTransparency = 0
	end
end

HomeView.Visible = true
ConfigView.Visible = false

-- ============================================================
-- TRAY & ANIMAÇÕES DE MINIMIZAR
-- ============================================================
local Tray = Instance.new("TextButton", ScreenGui)
Tray.Size = UDim2.new(0, 48, 0, 48)
Tray.Position = UDim2.new(0, 25, 0.82, 0)
Tray.Text = "P"
Tray.Font = Enum.Font.GothamBold
Tray.TextSize = 18
Tray.TextColor3 = Theme.TextActive
Tray.Visible = false
Tray.BackgroundColor3 = Theme.Accent
Instance.new("UICorner", Tray).CornerRadius = UDim.new(1, 0)

Tray.MouseButton1Click:Connect(function()
	OuterFrame.Visible = true
	Tray.Visible = false
end)

Close.MouseButton1Click:Connect(function()
	OuterFrame.Visible = false
	Tray.Visible = true
end)

local minimized = false
Min.MouseButton1Click:Connect(function()
	minimized = not minimized
	Sidebar.Visible = not minimized
	Content.Visible = not minimized
	Shadow.Visible = not minimized
	OuterFrame.Size = minimized and UDim2.new(0, 640, 0, 42) or UDim2.new(0, 640, 0, 440)
end)

print("PudimHub Premium v3 - Iniciado com FastAttack funcional!")