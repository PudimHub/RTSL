local TweenService = game:GetService("TweenService")
local TweenInfoDefault = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function tweenElement(element, properties, info)
    local tween = TweenService:Create(element, info or TweenInfoDefault, properties)
    tween:Play()
    return tween
end
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:GetService("PlayerGui")
local CoreGui = game:GetService("CoreGui") -- Usar CoreGui para maior persistência
local Lighting = game:GetService("Lighting")

-- Efeito de Desfoque (Blur)
local BlurEffect = Instance.new("BlurEffect")
BlurEffect.Name = "PudimHub_Blur"
BlurEffect.Size = 0
BlurEffect.Parent = Lighting

local function setBlur(size)
    tweenElement(BlurEffect, {Size = size}, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
end

-- Lista de links/chaves aleatórias para o Key System
local KEY_LINKS = {
    "PudimHub", "PudimHub.lua", "pudim", "ETCY", "RTXY", "SKYPE", 
    "FACEBOOK", "TWITTER", "YOUTUBE", "ASSIS", "APPLYSTYLE", "ALSTOM"
}

-- Cores Neon (Vermelho, Preto, Laranja, Verde)
local COLORS = {
    RedNeon = Color3.fromRGB(255, 0, 0),
    Black = Color3.fromRGB(20, 20, 20),
    OrangeNeon = Color3.fromRGB(255, 165, 0),
    GreenNeon = Color3.fromRGB(0, 255, 0),
    DarkGray = Color3.fromRGB(30, 30, 30),
    LightGray = Color3.fromRGB(50, 50, 50),
    KeySystemBG = Color3.fromRGB(40, 10, 0) -- Base escura para o neon vermelho/laranja
}
    RedNeon = Color3.fromRGB(255, 0, 0),
    Black = Color3.fromRGB(20, 20, 20),
    OrangeNeon = Color3.fromRGB(255, 165, 0),
    GreenNeon = Color3.fromRGB(0, 255, 0),
    DarkGray = Color3.fromRGB(30, 30, 30),
    LightGray = Color3.fromRGB(50, 50, 50)
}

-- Função para criar um gradiente de cor simples (para o título)
local function createNeonGradient(element)
    -- Simulação de efeito neon radiante com UIStroke e cor de destaque
    local TextStroke = Instance.new("UIStroke")
    TextStroke.Color = COLORS.RedNeon
    TextStroke.Thickness = 1.5
    TextStroke.Parent = element
    
    -- Animação de cor sutil para o efeito "radiante" (opcional, mas visualmente agradável)
    local function pulseColor()
        tweenElement(element, {TextColor3 = COLORS.OrangeNeon}, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true))
    end
    pulseColor()
end

-- Função para criar um gradiente de cor que se move (para o título da TopBar)
local function createMovingGradient(element, color1, color2)
    -- Em Luau, isso é complexo. Vamos simular com uma troca de cor mais rápida e intensa.
    local function moveColor()
        tweenElement(element, {TextColor3 = color1}, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out))
        wait(0.5)
        tweenElement(element, {TextColor3 = color2}, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out))
        wait(0.5)
        moveColor()
    end
    spawn(moveColor)
end

-- Função para criar cantos arredondados
local function createCorner(element, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = element
end

-- Função para criar um botão flutuante de reabertura
local function createReopenButton()
    local ReopenButton = Instance.new("TextButton")
    ReopenButton.Name = "PudimHub_Reopen"
    ReopenButton.Size = UDim2.new(0, 100, 0, 30)
    ReopenButton.Position = UDim2.new(0.5, -50, 0, 5) -- Topo centralizado
    ReopenButton.BackgroundColor3 = COLORS.RedNeon
    ReopenButton.Text = "PudimHub"
    ReopenButton.TextColor3 = Color3.new(1, 1, 1)
    ReopenButton.Font = Enum.Font.SourceSansBold
    ReopenButton.TextSize = 18
    ReopenButton.BorderSizePixel = 0
    ReopenButton.Visible = false -- Começa invisível
    ReopenButton.Parent = CoreGui
    
    createCorner(ReopenButton, 8)
    createNeonGradient(ReopenButton) -- Aplica o efeito neon
    
    ReopenButton.MouseButton1Click:Connect(function()
        ReopenButton.Visible = false
        HubGui.Enabled = true
        tweenElement(MainHubFrame, {BackgroundTransparency = 0, Size = UDim2.new(0, 600, 0, 400)})
    end)
    
    return ReopenButton
end

-- 2. Estrutura Principal da GUI
local HubGui = Instance.new("ScreenGui")
HubGui.Name = "PudimHub_GUI"
HubGui.Parent = CoreGui
HubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
HubGui.Enabled = false -- Começa desabilitado, KeySystem será o primeiro a aparecer

local ReopenButton = createReopenButton()

-- 3. Key System
local KeySystemFrame = Instance.new("Frame")
KeySystemFrame.Name = "KeySystem"
KeySystemFrame.Size = UDim2.new(0, 300, 0, 200)
KeySystemFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
KeySystemFrame.BackgroundColor3 = COLORS.KeySystemBG
KeySystemFrame.BorderSizePixel = 0
KeySystemFrame.Parent = HubGui
HubGui.Enabled = true -- Habilita a GUI para mostrar o KeySystem
KeySystemFrame.BackgroundTransparency = 0 -- Garante que a transparência inicial seja 0
KeySystemFrame.Size = UDim2.new(0, 300, 0, 200) -- Garante o tamanho final
KeySystemFrame.Position = UDim2.new(0.5, -150, 0.5, -100) -- Garante a posição final

-- Animação de abertura: vamos usar apenas um pequeno "pop" de escala para garantir que apareça
KeySystemFrame.Size = UDim2.new(0, 250, 0, 150) -- Tamanho inicial menor
tweenElement(KeySystemFrame, {Size = UDim2.new(0, 300, 0, 200)}, TweenInfo.new(0.2, Enum.EasingStyle.OutBack, Enum.EasingDirection.Out)) -- Tween de abertura com efeito pop
setBlur(24) -- Aplica o desfoque forte (24 é um valor comum)

createCorner(KeySystemFrame, 15)

-- Título do Key System
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundColor3 = COLORS.LightGray
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.Text = "PudimHub - Key System"
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.Parent = KeySystemFrame

-- Key Input
local KeyInput = Instance.new("TextBox")
KeyInput.Name = "KeyInput"
KeyInput.Size = UDim2.new(0.8, 0, 0, 30)
KeyInput.Position = UDim2.new(0.1, 0, 0.3, 0)
KeyInput.PlaceholderText = "Enter Key Here"
KeyInput.BackgroundColor3 = COLORS.LightGray
KeyInput.TextColor3 = Color3.new(1, 1, 1)
KeyInput.Text = ""
KeyInput.Font = Enum.Font.SourceSans
KeyInput.TextSize = 16
KeyInput.Parent = KeySystemFrame
createCorner(KeyInput, 5)

-- Get Key Button
local GetKeyButton = Instance.new("TextButton")
GetKeyButton.Name = "GetKeyButton"
GetKeyButton.Size = UDim2.new(0.4, -5, 0, 30)
GetKeyButton.Position = UDim2.new(0.1, 0, 0.55, 0)
GetKeyButton.BackgroundColor3 = COLORS.OrangeNeon
GetKeyButton.Text = "Get Key"
GetKeyButton.TextColor3 = Color3.new(1, 1, 1)
GetKeyButton.Font = Enum.Font.SourceSansBold
GetKeyButton.TextSize = 16
GetKeyButton.Parent = KeySystemFrame
createCorner(GetKeyButton, 5)

-- Check Key Button
local CheckKeyButton = Instance.new("TextButton")
CheckKeyButton.Name = "CheckKeyButton"
CheckKeyButton.Size = UDim2.new(0.4, -5, 0, 30)
CheckKeyButton.Position = UDim2.new(0.5, 5, 0.55, 0)
CheckKeyButton.BackgroundColor3 = COLORS.RedNeon
CheckKeyButton.Text = "Check Key"
CheckKeyButton.TextColor3 = Color3.new(1, 1, 1)
CheckKeyButton.Font = Enum.Font.SourceSansBold
CheckKeyButton.TextSize = 16
CheckKeyButton.Parent = KeySystemFrame
createCorner(CheckKeyButton, 5)

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.8, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.1, 0, 0.8, 0)
StatusLabel.BackgroundColor3 = COLORS.DarkGray
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Text = "Aguardando chave..."
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14
StatusLabel.Parent = KeySystemFrame

-- Lógica do Key System
-- Função para simular o efeito de digitação
local function typeText(label, text)
    label.Text = ""
    for i = 1, #text do
        label.Text = string.sub(text, 1, i)
        wait(0.02) -- Velocidade de digitação
    end
end

-- Função para simular o efeito de tremer (Shake)
local function shakeElement(element)
    local originalPos = element.Position
    local shakeInfo = TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 5, true)
    
    for i = 1, 5 do
        tweenElement(element, {Position = originalPos + UDim2.new(0, math.random(-5, 5), 0, math.random(-5, 5))}, shakeInfo)
        wait(0.05)
    end
    tweenElement(element, {Position = originalPos}, shakeInfo)
end

local function copyToClipboard(text)
    -- Em um executor de script, o comando para copiar pode variar.
    -- Esta é uma simulação, pois o Luau padrão do Roblox não tem acesso direto à área de transferência.
    -- Em um executor, o comando 'setclipboard(text)' ou similar seria usado.
    -- Aqui, vamos apenas exibir a chave no console/chat.
    warn("CHAVE COPIADA (Simulação): " .. text)
    typeText(StatusLabel, "Chave copiada! Cole no campo acima.")
    StatusLabel.TextColor3 = COLORS.OrangeNeon
end

GetKeyButton.MouseButton1Click:Connect(function()
    local randomIndex = math.random(1, #KEY_LINKS)
    local randomKey = KEY_LINKS[randomIndex]
    copyToClipboard(randomKey)
    KeyInput.Text = randomKey -- Para facilitar o teste, já preenchemos
end)

CheckKeyButton.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text
    local isValid = false
    
    -- Verifica se a chave inserida está na lista de chaves válidas
    for _, key in ipairs(KEY_LINKS) do
        if enteredKey == key then
            isValid = true
            break
        end
    end
    
    if isValid then
        -- Sucesso: Fica verde, desaparece e mostra a interface principal
        CheckKeyButton.BackgroundColor3 = COLORS.GreenNeon
        typeText(StatusLabel, "Chave Válida! Carregando Hub...")
        wait(1)
        tweenElement(KeySystemFrame, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}, TweenInfo.new(0.2, Enum.EasingStyle.InBack, Enum.EasingDirection.In)):GetPropertyChangedSignal("PlaybackState"):Wait()
        KeySystemFrame.Visible = false
        loadMainHub() -- Chama a função para carregar o Hub principal
        -- O blur permanece ativo, pois o MainHub será carregado em seguida
    else
        -- Falha
        typeText(StatusLabel, "Chave Inválida. Tente novamente.")
        StatusLabel.TextColor3 = COLORS.RedNeon
        CheckKeyButton.BackgroundColor3 = COLORS.RedNeon
        shakeElement(KeySystemFrame) -- Efeito de tremer ao errar
    end
end)

-- 4. Estrutura do Hub Principal (Função de Carregamento)
local MainHubFrame = nil -- Variável para a interface principal

local function loadMainHub()
    -- Cria o Frame Principal
    MainHubFrame = Instance.new("Frame")
    MainHubFrame.Name = "PudimHub_Main"
    MainHubFrame.Size = UDim2.new(0, 600, 0, 400)
    MainHubFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainHubFrame.BackgroundColor3 = COLORS.DarkGray
    MainHubFrame.BorderSizePixel = 0
    MainHubFrame.Parent = HubGui
    
    createCorner(MainHubFrame, 15)
    
    -- Tween de abertura do Main Hub
    MainHubFrame.BackgroundTransparency = 1
    MainHubFrame.Size = UDim2.new(0, 0, 0, 0)
    tweenElement(MainHubFrame, {BackgroundTransparency = 0, Size = UDim2.new(0, 600, 0, 400)})
    
    -- TopBar (Arrastável)
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = COLORS.Black
    TopBar.Parent = MainHubFrame
    createCorner(TopBar, 15) -- Arredondamento na TopBar
    
    -- Título Neon (PudimHub)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.5, 0, 1, 0)
    Title.Position = UDim2.new(0.02, 0, 0, 0)
    Title.BackgroundColor3 = COLORS.Black
    Title.TextColor3 = COLORS.RedNeon
    Title.Text = "PudimHub"
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    createMovingGradient(Title, COLORS.RedNeon, COLORS.Black) -- Efeito Neon Radiante e Animado
    
    -- Lógica de Arrastar (Drag)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainHubFrame.Position
            input.Handled = true
        end
    end)
    
    TopBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newX = startPos.X.Scale + delta.X / MainHubFrame.Parent.AbsoluteSize.X
            local newY = startPos.Y.Scale + delta.Y / MainHubFrame.Parent.AbsoluteSize.Y
            
            MainHubFrame.Position = UDim2.new(newX, 0, newY, 0)
        end
    end)
    
    -- Botões de Controle (Fechar, Minimizar, Estrela)
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Size = UDim2.new(0.3, 0, 1, 0)
    ButtonContainer.Position = UDim2.new(0.7, 0, 0, 0)
    ButtonContainer.BackgroundColor3 = COLORS.Black
    ButtonContainer.BorderSizePixel = 0
    ButtonContainer.Parent = TopBar
    
    local UILayout = Instance.new("UIListLayout")
    UILayout.FillDirection = Enum.FillDirection.Horizontal
    UILayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UILayout.VerticalAlignment = Enum.VerticalAlignment.Center
    UILayout.Padding = UDim.new(0, 5)
    UILayout.Parent = ButtonContainer
    
    -- Botão 1: Fechar (X)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.BackgroundColor3 = COLORS.RedNeon
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(1, 1, 1)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.TextSize = 18
    CloseButton.Parent = ButtonContainer
    createCorner(CloseButton, 5)
    
    CloseButton.MouseEnter:Connect(function() tweenElement(CloseButton, {BackgroundTransparency = 0.5}) end)
    CloseButton.MouseLeave:Connect(function() tweenElement(CloseButton, {BackgroundTransparency = 0}) end)
    CloseButton.MouseButton1Click:Connect(function()
        tweenElement(MainHubFrame, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):GetPropertyChangedSignal("PlaybackState"):Wait()
        HubGui.Enabled = false
        ReopenButton.Visible = true -- Mostra o botão flutuante
        setBlur(0) -- Remove o desfoque ao fechar completamente
    
    -- Botão 2: Minimizar (Deixa só a TopBar)
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.BackgroundColor3 = COLORS.OrangeNeon
    MinimizeButton.Text = "-"
    MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
    MinimizeButton.Font = Enum.Font.SourceSansBold
    MinimizeButton.TextSize = 18
    MinimizeButton.Parent = ButtonContainer
    createCorner(MinimizeButton, 5)
    
    local isMinimized = false
    MinimizeButton.MouseEnter:Connect(function() tweenElement(MinimizeButton, {BackgroundTransparency = 0.5}) end)
    MinimizeButton.MouseLeave:Connect(function() tweenElement(MinimizeButton, {BackgroundTransparency = 0}) end)
    MinimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            tweenElement(MainHubFrame, {Size = UDim2.new(0, 600, 0, 35)}) -- Reduz para o tamanho da TopBar
            MinimizeButton.Text = "+"
        else
            tweenElement(MainHubFrame, {Size = UDim2.new(0, 600, 0, 400)}) -- Volta ao tamanho normal
            MinimizeButton.Text = "-"
        end
    end)
    
    -- Botão 3: Estrela (Modo Lateral)
    local StarButton = Instance.new("TextButton")
    StarButton.Name = "StarButton"
    StarButton.Size = UDim2.new(0, 30, 0, 30)
    StarButton.BackgroundColor3 = COLORS.GreenNeon
    StarButton.Text = "☆"
    StarButton.TextColor3 = Color3.new(1, 1, 1)
    StarButton.Font = Enum.Font.SourceSansBold
    StarButton.TextSize = 18
    StarButton.Parent = ButtonContainer
    createCorner(StarButton, 5)
    
    -- Botão Lateral Fino (para o modo estrela)
    local SideButton = Instance.new("TextButton")
    SideButton.Name = "SideButton"
    SideButton.Size = UDim2.new(0, 5, 0.3, 0)
    SideButton.Position = UDim2.new(0, 0, 0.35, 0)
    SideButton.BackgroundColor3 = Color3.new(1, 1, 1)
    SideButton.BackgroundTransparency = 0.8
    SideButton.Text = ""
    SideButton.Parent = CoreGui
    SideButton.Visible = false
    
    SideButton.MouseButton1Click:Connect(function()
        MainHubFrame.Visible = true
        SideButton.Visible = false
    end)
    
    StarButton.MouseEnter:Connect(function() tweenElement(StarButton, {BackgroundTransparency = 0.5}) end)
    StarButton.MouseLeave:Connect(function() tweenElement(StarButton, {BackgroundTransparency = 0}) end)
    StarButton.MouseButton1Click:Connect(function()
        MainHubFrame.Visible = false
        SideButton.Visible = true
        -- O blur permanece ativo, pois a SideButton ainda indica que o Hub está em uso
    end)
    
    -- Container de Abas (Abaixo da TopBar)
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 30)
    TabContainer.Position = UDim2.new(0, 0, 0, 35)
    TabContainer.BackgroundColor3 = COLORS.LightGray
    TabContainer.Parent = MainHubFrame
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabContainer
    
    -- Painel de Conteúdo (Onde o conteúdo das abas aparece)
    local ContentPanel = Instance.new("Frame")
    ContentPanel.Name = "ContentPanel"
    ContentPanel.Size = UDim2.new(1, 0, 1, -65) -- 400 - 35 (TopBar) - 30 (TabContainer) = 335
    ContentPanel.Position = UDim2.new(0, 0, 0, 65)
    ContentPanel.BackgroundColor3 = COLORS.DarkGray
    ContentPanel.BorderSizePixel = 0
    ContentPanel.Parent = MainHubFrame
    createCorner(ContentPanel, 10)
    
    -- Tabela para gerenciar as abas
    local Tabs = {}
    local CurrentTab = nil
    
    local function createTab(name, index)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "Tab_" .. index
        TabButton.Size = UDim2.new(0, 80, 1, 0)
        TabButton.BackgroundColor3 = COLORS.DarkGray
        TabButton.Text = name
        TabButton.TextColor3 = Color3.new(1, 1, 1)
        TabButton.Font = Enum.Font.SourceSans
        TabButton.TextSize = 14
        TabButton.Parent = TabContainer
        createCorner(TabButton, 8)
        
        local TabContent = Instance.new("Frame")
        TabContent.Name = "Content_" .. index
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Position = UDim2.new(0, 0, 0, 0)
        TabContent.BackgroundColor3 = COLORS.DarkGray
        TabContent.BorderSizePixel = 0
        TabContent.Visible = false
        TabContent.Parent = ContentPanel
        
        Tabs[index] = {Button = TabButton, Content = TabContent}
        
        TabButton.MouseButton1Click:Connect(function()
            if CurrentTab then
                -- Desativa a aba anterior com tween
                tweenElement(CurrentTab.Button, {BackgroundColor3 = COLORS.DarkGray}, TweenInfo.new(0.2))
                tweenElement(CurrentTab.Content, {Position = UDim2.new(-1, 0, 0, 0)}, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)):GetPropertyChangedSignal("PlaybackState"):Wait()
                CurrentTab.Content.Visible = false
            end
            
            -- Ativa a nova aba com tween (Slide-in)
            TabContent.Position = UDim2.new(1, 0, 0, 0)
            TabContent.Visible = true
            tweenElement(TabButton, {BackgroundColor3 = COLORS.OrangeNeon}, TweenInfo.new(0.2)) -- Cor de destaque
            tweenElement(TabContent, {Position = UDim2.new(0, 0, 0, 0)}, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
            CurrentTab = Tabs[index]
        end)
        
        return TabContent
    end
    
    -- Criação das 10 Abas
    local TabNames = {
        "???", "???", "???", "???", "???", 
        "???", "???", "???", "???", "Informações"
    }
    
    for i, name in ipairs(TabNames) do
        createTab(name, i)
    end
    
    -- Ativa a primeira aba por padrão
    if Tabs[1] then
        Tabs[1].Button.BackgroundColor3 = COLORS.OrangeNeon
        Tabs[1].Content.Visible = true
        CurrentTab = Tabs[1]
    end
    
    -- 5. Implementação da Aba "Informações" (Aba 10)
    local InfoTabContent = Tabs[10].Content
    
    -- Painel de Estatísticas
    local StatsPanel = Instance.new("Frame")
    StatsPanel.Size = UDim2.new(0.4, 0, 0.5, 0)
    StatsPanel.Position = UDim2.new(0.02, 0, 0.02, 0)
    StatsPanel.BackgroundColor3 = COLORS.LightGray
    StatsPanel.Parent = InfoTabContent
    createCorner(StatsPanel, 8)
    
    local StatsTitle = Instance.new("TextLabel")
    StatsTitle.Size = UDim2.new(1, 0, 0, 20)
    StatsTitle.BackgroundColor3 = COLORS.DarkGray
    StatsTitle.TextColor3 = Color3.new(1, 1, 1)
    StatsTitle.Text = "Estatísticas do Jogo"
    StatsTitle.Font = Enum.Font.SourceSansBold
    StatsTitle.TextSize = 16
    StatsTitle.Parent = StatsPanel
    
    local StatsLayout = Instance.new("UIListLayout")
    StatsLayout.FillDirection = Enum.FillDirection.Vertical
    StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    StatsLayout.Padding = UDim.new(0, 5)
    StatsLayout.Parent = StatsPanel
    
    -- Funções para exibir estatísticas
    local function createStatLabel(name, parent)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundColor3 = COLORS.LightGray
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = name .. ": N/A"
        label.Font = Enum.Font.SourceSans
        label.TextSize = 14
        label.Parent = parent
        return label
    end
    
    local FPSLabel = createStatLabel("FPS", StatsPanel)
    local PingLabel = createStatLabel("Ping do Servidor", StatsPanel)
    local PlayersLabel = createStatLabel("Jogadores no Servidor", StatsPanel)
    local ChronoLabel = createStatLabel("Tempo no Servidor", StatsPanel)
    
    -- Lógica de Atualização de Estatísticas
    local startTime = tick()
    game:GetService("RunService").Heartbeat:Connect(function()
        -- FPS
        local fps = math.floor(1 / game:GetService("RunService").Heartbeat:Wait())
        FPSLabel.Text = "FPS: " .. fps
        
        -- Ping (Simulação, pois o ping real é complexo de obter em Luau)
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() * 1000) or "N/A"
        PingLabel.Text = "Ping do Servidor: " .. ping .. "ms"
        
        -- Jogadores
        PlayersLabel.Text = "Jogadores no Servidor: " .. #game:GetService("Players"):GetPlayers()
        
        -- Cronômetro
        local elapsed = math.floor(tick() - startTime)
        local minutes = math.floor(elapsed / 60)
        local seconds = elapsed % 60
        ChronoLabel.Text = string.format("Tempo no Servidor: %02d:%02d", minutes, seconds)
    end)
    
    -- Painel de Funções Básicas (Speed, Jump, Fly, Anti-Void)
    local BasicFuncPanel = Instance.new("Frame")
    BasicFuncPanel.Size = UDim2.new(0.5, 0, 0.9, 0)
    BasicFuncPanel.Position = UDim2.new(0.45, 0, 0.02, 0)
    BasicFuncPanel.BackgroundColor3 = COLORS.LightGray
    BasicFuncPanel.Parent = InfoTabContent
    createCorner(BasicFuncPanel, 8)
    
    local BasicFuncTitle = Instance.new("TextLabel")
    BasicFuncTitle.Size = UDim2.new(1, 0, 0, 20)
    BasicFuncTitle.BackgroundColor3 = COLORS.DarkGray
    BasicFuncTitle.TextColor3 = Color3.new(1, 1, 1)
    BasicFuncTitle.Text = "Funções Básicas"
    BasicFuncTitle.Font = Enum.Font.SourceSansBold
    BasicFuncTitle.TextSize = 16
    BasicFuncTitle.Parent = BasicFuncPanel
    
    local BasicFuncLayout = Instance.new("UIListLayout")
    BasicFuncLayout.FillDirection = Enum.FillDirection.Vertical
    BasicFuncLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    BasicFuncLayout.Padding = UDim.new(0, 5)
    BasicFuncLayout.Parent = BasicFuncPanel
    
    -- Função para criar um Toggle Button
    local function createToggle(name, parent, defaultColor, activeColor, callback)
    local TweenInfoButton = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local TweenInfoClick = TweenInfo.new(0.05, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
        ToggleFrame.BackgroundColor3 = COLORS.LightGray
        ToggleFrame.Parent = parent
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Size = UDim2.new(0.4, 0, 0.8, 0)
        ToggleButton.Position = UDim2.new(0.55, 0, 0.1, 0)
        ToggleButton.BackgroundColor3 = defaultColor
        ToggleButton.Text = name .. " (OFF)"
        ToggleButton.TextColor3 = Color3.new(1, 1, 1)
        ToggleButton.Font = Enum.Font.SourceSansBold
        ToggleButton.TextSize = 14
        ToggleButton.Parent = ToggleFrame
        createCorner(ToggleButton, 5)
        
        local isActive = false
        ToggleButton.MouseButton1Click:Connect(function()
            tweenElement(ToggleButton, {BackgroundTransparency = 0.2}, TweenInfoClick)
            wait(0.05)
            tweenElement(ToggleButton, {BackgroundTransparency = 0}, TweenInfoClick)
            
            isActive = not isActive
            if isActive then
                tweenElement(ToggleButton, {BackgroundColor3 = activeColor, TextSize = 16}, TweenInfoButton)
                ToggleButton.Text = name .. " (ON)"
            else
                tweenElement(ToggleButton, {BackgroundColor3 = defaultColor, TextSize = 14}, TweenInfoButton)
                ToggleButton.Text = name .. " (OFF)"
            end
            callback(isActive)
        end)
        
        -- Animação de Hover
        ToggleButton.MouseEnter:Connect(function()
            tweenElement(ToggleButton, {TextSize = 16}, TweenInfoButton)
        end)
        ToggleButton.MouseLeave:Connect(function()
            if not isActive then
                tweenElement(ToggleButton, {TextSize = 14}, TweenInfoButton)
            end
        end)
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 0.8, 0)
        Label.Position = UDim2.new(0.05, 0, 0.1, 0)
        Label.BackgroundColor3 = COLORS.LightGray
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.Text = name
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 14
        Label.Parent = ToggleFrame
        
        return ToggleButton
    end
    
    -- Função para criar um Slider
    local function createSlider(name, parent, minVal, maxVal, defaultVal, step, callback)
    local TweenInfoSlider = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Size = UDim2.new(1, 0, 0, 40)
        SliderFrame.BackgroundColor3 = COLORS.LightGray
        SliderFrame.Parent = parent
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 0, 20)
        Label.Position = UDim2.new(0.05, 0, 0, 0)
        Label.BackgroundColor3 = COLORS.LightGray
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Font = Enum.Font.SourceSans
        Label.TextSize = 14
        Label.Parent = SliderFrame
        
        local Slider = Instance.new("Slider")
        Slider.Size = UDim2.new(0.8, 0, 0, 15)
        Slider.Position = UDim2.new(0.1, 0, 0, 20)
        Slider.BackgroundColor3 = COLORS.DarkGray
        Slider.Parent = SliderFrame
        
        Slider.Value = (defaultVal - minVal) / (maxVal - minVal)
        
        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0.4, 0, 0, 20)
        ValueLabel.Position = UDim2.new(0.55, 0, 0, 0)
        ValueLabel.BackgroundColor3 = COLORS.LightGray
        ValueLabel.TextColor3 = COLORS.OrangeNeon
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Font = Enum.Font.SourceSansBold
        ValueLabel.TextSize = 14
        ValueLabel.Parent = SliderFrame
        
        local function updateValue(value)
            local realValue = math.floor((minVal + (maxVal - minVal) * value) / step) * step
            Label.Text = name
            ValueLabel.Text = string.format("%.1f", realValue)
            callback(realValue)
        end
        
        Slider.Changed:Connect(function(value)
            updateValue(value)
        end)
        
        updateValue(Slider.Value)
        
        return Slider
    end
    
    -- Implementação das Funções
    
    -- Speed
    local defaultWalkSpeed = Player.Character and Player.Character.Humanoid.WalkSpeed or 16
    createSlider("Speed", BasicFuncPanel, 16, 100, defaultWalkSpeed, 1, function(value)
        if Player.Character and Player.Character.Humanoid then
            Player.Character.Humanoid.WalkSpeed = value
        end
    end)
    
    -- Jump Power
    local defaultJumpPower = Player.Character and Player.Character.Humanoid.JumpPower or 50
    createSlider("Jump Power", BasicFuncPanel, 50, 200, defaultJumpPower, 5, function(value)
        if Player.Character and Player.Character.Humanoid then
            Player.Character.Humanoid.JumpPower = value
        end
    end)
    
    -- Fly (Implementação básica com BodyVelocity/BodyGyro)
    local isFlying = false
    local FlyToggle = createToggle("Fly", BasicFuncPanel, COLORS.RedNeon, COLORS.GreenNeon, function(active)
        isFlying = active
        local Humanoid = Player.Character and Player.Character.Humanoid
        local RootPart = Player.Character and Player.Character.HumanoidRootPart
        
        if Humanoid and RootPart then
            if active then
                Humanoid.PlatformStand = true
                -- Adicionar BodyVelocity e BodyGyro para voo
                local BodyVelocity = Instance.new("BodyVelocity")
                BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                BodyVelocity.Parent = RootPart
                
                local BodyGyro = Instance.new("BodyGyro")
                BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                BodyGyro.CFrame = RootPart.CFrame
                BodyGyro.Parent = RootPart
                
                -- Lógica de movimento de voo (W, A, S, D, Espaço, Shift)
                -- (Omitido para manter o código dentro do limite, mas seria implementado aqui)
            else
                Humanoid.PlatformStand = false
                if RootPart:FindFirstChild("BodyVelocity") then RootPart.BodyVelocity:Destroy() end
                if RootPart:FindFirstChild("BodyGyro") then RootPart.BodyGyro:Destroy() end
            end
        end
    end)
    
    -- Fly Speed
    createSlider("Fly Speed", BasicFuncPanel, 10, 150, 50, 5, function(value)
        -- A velocidade de voo seria aplicada à BodyVelocity no loop de voo
        -- (Omitido, mas a variável de velocidade seria atualizada aqui)
    end)
    
    -- Anti-Void
    local AntiVoidToggle = createToggle("Anti-Void", BasicFuncPanel, COLORS.RedNeon, COLORS.GreenNeon, function(active)
        if active then
            -- Lógica de Anti-Void: Checa se o jogador está abaixo de Y = -500 e teleporta
            local function checkVoid()
                if Player.Character and Player.Character.HumanoidRootPart and Player.Character.HumanoidRootPart.Position.Y < -500 then
                    Player.Character.HumanoidRootPart.CFrame = CFrame.new(Player.Character.HumanoidRootPart.Position.X, 500, Player.Character.HumanoidRootPart.Position.Z)
                end
            end
            
            local VoidConnection = game:GetService("RunService").Heartbeat:Connect(checkVoid)
            AntiVoidToggle:SetAttribute("VoidConnection", VoidConnection)
        else
            local VoidConnection = AntiVoidToggle:GetAttribute("VoidConnection")
            if VoidConnection then VoidConnection:Disconnect() end
        end
    end)
    
    -- Botão Aimbot (Abre a interface secundária)
    local AimbotButton = Instance.new("TextButton")
    AimbotButton.Name = "AimbotButton"
    AimbotButton.Size = UDim2.new(0.4, 0, 0, 30)
    AimbotButton.Position = UDim2.new(0.05, 0, 0.8, 0)
    AimbotButton.BackgroundColor3 = COLORS.RedNeon
    AimbotButton.Text = "Aimbot / ESP (Abrir)"
    AimbotButton.TextColor3 = Color3.new(1, 1, 1)
    AimbotButton.Font = Enum.Font.SourceSansBold
    AimbotButton.TextSize = 14
    AimbotButton.Parent = InfoTabContent
    createCorner(AimbotButton, 5)
    
    -- 6. Estrutura da Interface Secundária (Aimbot/ESP)
    local AimbotFrame = nil
    
    local function createAimbotFrame()
        AimbotFrame = Instance.new("Frame")
        AimbotFrame.Name = "Aimbot_ESP_Frame"
        AimbotFrame.Size = UDim2.new(0, 350, 0, 450)
        AimbotFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
        AimbotFrame.BackgroundColor3 = COLORS.DarkGray
        AimbotFrame.BorderSizePixel = 0
        AimbotFrame.Parent = CoreGui
        AimbotFrame.Visible = false
        createCorner(AimbotFrame, 10)
        
        -- TopBar Aimbot (Arrastável)
        local AimbotTopBar = Instance.new("Frame")
        AimbotTopBar.Name = "TopBar"
        AimbotTopBar.Size = UDim2.new(1, 0, 0, 30)
        AimbotTopBar.BackgroundColor3 = COLORS.Black
        AimbotTopBar.Parent = AimbotFrame
        
        local AimbotTitle = Instance.new("TextLabel")
        AimbotTitle.Size = UDim2.new(0.8, 0, 1, 0)
        AimbotTitle.BackgroundColor3 = COLORS.Black
        AimbotTitle.TextColor3 = COLORS.RedNeon
        AimbotTitle.Text = "PudimHub - Aimbot/ESP"
        AimbotTitle.Font = Enum.Font.SourceSansBold
        AimbotTitle.TextSize = 18
        AimbotTitle.TextXAlignment = Enum.TextXAlignment.Left
        AimbotTitle.Parent = AimbotTopBar
        
        -- Botão Fechar (X)
        local AimbotCloseButton = Instance.new("TextButton")
        AimbotCloseButton.Name = "CloseButton"
        AimbotCloseButton.Size = UDim2.new(0, 30, 0, 30)
        AimbotCloseButton.Position = UDim2.new(1, -30, 0, 0)
        AimbotCloseButton.BackgroundColor3 = COLORS.RedNeon
        AimbotCloseButton.Text = "X"
        AimbotCloseButton.TextColor3 = Color3.new(1, 1, 1)
        AimbotCloseButton.Font = Enum.Font.SourceSansBold
        AimbotCloseButton.TextSize = 18
        AimbotCloseButton.Parent = AimbotTopBar
        createCorner(AimbotCloseButton, 5)
        
        AimbotCloseButton.MouseEnter:Connect(function() tweenElement(AimbotCloseButton, {BackgroundTransparency = 0.5}) end)
        AimbotCloseButton.MouseLeave:Connect(function() tweenElement(AimbotCloseButton, {BackgroundTransparency = 0}) end)
        AimbotCloseButton.MouseButton1Click:Connect(function()
            tweenElement(AimbotFrame, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)}):GetPropertyChangedSignal("PlaybackState"):Wait()
            AimbotFrame.Visible = false
            -- O blur permanece ativo, pois o MainHub ainda está visível/habilitado
        end)
        
        -- Lógica de Arrastar (Drag) para AimbotFrame
        -- (Omitido para brevidade, mas seria similar ao MainHubFrame)
        
        -- Painel de Conteúdo Aimbot
        local AimbotContent = Instance.new("Frame")
        AimbotContent.Size = UDim2.new(1, 0, 1, -30)
        AimbotContent.Position = UDim2.new(0, 0, 0, 30)
        AimbotContent.BackgroundColor3 = COLORS.DarkGray
        AimbotContent.Parent = AimbotFrame
        
        local AimbotLayout = Instance.new("UIListLayout")
        AimbotLayout.FillDirection = Enum.FillDirection.Vertical
        AimbotLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        AimbotLayout.Padding = UDim.new(0, 5)
        AimbotLayout.Parent = AimbotContent
        
        -- Aimbot Toggle
        createToggle("Aimbot Ativar", AimbotContent, COLORS.RedNeon, COLORS.GreenNeon, function(active)
            -- Lógica de Aimbot (Targeting, CFrame manipulation)
        end)
        
        -- FOV Circle Slider
        createSlider("FOV Circle Size", AimbotContent, 50, 500, 150, 10, function(value)
            -- Lógica para desenhar o círculo FOV na tela
        end)
        
        -- Linhas (Tracer Lines)
        createToggle("Linhas (Tracer)", AimbotContent, COLORS.RedNeon, COLORS.GreenNeon, function(active)
            -- Lógica para desenhar linhas do jogador até o alvo (Line of Sight)
        end)
        
        -- ESP (Health, Distance, Name, Outline)
        createToggle("ESP Completo", AimbotContent, COLORS.RedNeon, COLORS.GreenNeon, function(active)
            -- Lógica para desenhar caixas, texto e contornos nos jogadores
        end)
        
        -- God Mode (Aumenta Speed, Jump, Hitbox)
        createToggle("God Mode (Size 250)", AimbotContent, COLORS.RedNeon, COLORS.GreenNeon, function(active)
            if active then
                -- Aumenta Speed e Jump
                if Player.Character and Player.Character.Humanoid then
                    Player.Character.Humanoid.WalkSpeed = 85
                    Player.Character.Humanoid.JumpPower = 55
                end
                -- Aumenta Hitbox (Simulação com um cubo transparente)
                local HitboxPart = Instance.new("Part")
                HitboxPart.Size = Vector3.new(25, 25, 25) -- Simulação de size 250
                HitboxPart.Transparency = 0.8
                HitboxPart.CanCollide = false
                HitboxPart.BrickColor = BrickColor.new("Really red")
                HitboxPart.Parent = Player.Character
                
                local Weld = Instance.new("WeldConstraint")
                Weld.Part0 = Player.Character.HumanoidRootPart
                Weld.Part1 = HitboxPart
                Weld.Parent = HitboxPart
                
                AimbotFrame:SetAttribute("GodHitbox", HitboxPart)
            else
                if Player.Character and Player.Character.Humanoid then
                    Player.Character.Humanoid.WalkSpeed = defaultWalkSpeed
                    Player.Character.Humanoid.JumpPower = defaultJumpPower
                end
                local HitboxPart = AimbotFrame:GetAttribute("GodHitbox")
                if HitboxPart then HitboxPart:Destroy() end
            end
        end)
        
        -- Botão Transparente para reabrir (no topo da tela)
        local AimbotReopenButton = Instance.new("TextButton")
        AimbotReopenButton.Name = "Aimbot_Reopen"
        AimbotReopenButton.Size = UDim2.new(0, 50, 0, 50)
        AimbotReopenButton.Position = UDim2.new(0.9, 0, 0, 0)
        AimbotReopenButton.BackgroundTransparency = 1
        AimbotReopenButton.Text = ""
        AimbotReopenButton.Parent = CoreGui
        AimbotReopenButton.Visible = false
        
        AimbotCloseButton.MouseButton1Click:Connect(function()
            AimbotFrame.Visible = false
            AimbotReopenButton.Visible = true
        end)
        
        AimbotReopenButton.MouseButton1Click:Connect(function()
            AimbotFrame.Visible = true
            AimbotReopenButton.Visible = false
            tweenElement(AimbotFrame, {BackgroundTransparency = 0, Size = UDim2.new(0, 350, 0, 450)})
        end)
    end
    
    -- Cria a interface Aimbot/ESP uma vez
    createAimbotFrame()
    
    -- Conecta o botão Aimbot da aba Informações
    AimbotButton.MouseEnter:Connect(function() tweenElement(AimbotButton, {BackgroundTransparency = 0.5}) end)
    AimbotButton.MouseLeave:Connect(function() tweenElement(AimbotButton, {BackgroundTransparency = 0}) end)
    AimbotButton.MouseButton1Click:Connect(function()
        if AimbotFrame then
            AimbotFrame.Visible = true
            tweenElement(AimbotFrame, {BackgroundTransparency = 0, Size = UDim2.new(0, 350, 0, 450)})
        end
    end)
    
    -- Oculta o KeySystem e mostra o MainHub
    KeySystemFrame.Visible = false
    MainHubFrame.Visible = true
end

-- Inicia o Key System (já está visível por padrão)
-- O restante do código será executado após a validação da chave.
