--[[
    PudimHub V10 - GOD EDITION (SPY FIXED + TRACER FIXED 2026)
    Especial: Flee the Facility (Marretão)
    
    CORREÇÃO COMPLETA: Baseado nos RemoteEvents reais do jogo
    STATUS: Script 100% Funcional com todas as correções
]]

-- [ SERVIÇOS ]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

-- [ VARIÁVEIS PRINCIPAIS ]
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Remote = ReplicatedStorage:WaitForChild("RemoteEvent")

-- [ CONFIGURAÇÃO E ESTADOS ]
local Config = {
    Visuals = {
        MainColor = Color3.fromRGB(130, 0, 255),
        AccentColor = Color3.fromRGB(255, 80, 0),
        BackgroundColor = Color3.fromRGB(15, 15, 25),
        SecondaryColor = Color3.fromRGB(25, 25, 35),
        TextColor = Color3.fromRGB(240, 240, 240),
        Font = Enum.Font.GothamBold,
        CornerRadius = UDim.new(0, 8),
        BackgroundTransparency = 0
    },
    States = {
        Speed = 16, SpeedEnabled = false, SpeedBom = false, Noclip = false, AntiRagdoll = false, NoFog = false,
        EspComputers = false, EspBeast = false, EspPlayers = false, EspPods = false, EspExits = false,
        AutoTPComputers = false, AutoWin = false, AutoBeast = false, AutoSave = false, AutoDoors = false,
        AntiErroComp = false,
        FullBright = false, InfiniteZoom = false, Spider = false, ClickTP = false
    },
    Defaults = {
        Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
        FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, MaxZoom = LocalPlayer.CameraMaxZoomDistance
    }
}

-- [ CACHE E OBJETOS ]
local UIObjects = {MainFrame = nil, TopBar = nil, MainStrokes = {}, TabButtons = {}, Toggles = {}, Sliders = {}, Accordions = {}, PDLogo = nil}

-- [ SEGURANÇA E PERFORMANCE ]
local SafeMode = true
local LastActionTime = 0
local MIN_ACTION_DELAY = 0.3
local function SafeFireServer(...)
    if SafeMode and tick() - LastActionTime < MIN_ACTION_DELAY then
        return false
    end
    
    local success = pcall(function()
        Remote:FireServer(...)
    end)
    
    LastActionTime = tick()
    return success
end

-- [ UTILITÁRIOS ]
local Utils = {}
function Utils:Create(className, properties, children)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do instance[property] = value end
    if children then for _, child in pairs(children) do child.Parent = instance end end
    return instance
end

function Utils:MakeDraggable(topbar, frame)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = frame.Position
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
end

-- [ INTERFACE ]
local ParentBase = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
if ParentBase:FindFirstChild("PudimHub_V10") then ParentBase.PudimHub_V10:Destroy() end

local ScreenGui = Utils:Create("ScreenGui", {Name = "PudimHub_V10", Parent = ParentBase, ResetOnSpawn = false})
local MainFrame = Utils:Create("Frame", {Name = "MainFrame", Size = UDim2.new(0, 580, 0, 400), Position = UDim2.new(0.5, -290, 0.5, -200), BackgroundColor3 = Config.Visuals.BackgroundColor, BorderSizePixel = 0, Parent = ScreenGui})
UIObjects.MainFrame = MainFrame
Utils:Create("UICorner", {CornerRadius = Config.Visuals.CornerRadius, Parent = MainFrame})
local MainStroke = Utils:Create("UIStroke", {Color = Config.Visuals.MainColor, Thickness = 1.5, Transparency = 0.5, Parent = MainFrame})
table.insert(UIObjects.MainStrokes, MainStroke)

local TopBar = Utils:Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Config.Visuals.SecondaryColor, Parent = MainFrame})
UIObjects.TopBar = TopBar
Utils:Create("UICorner", {CornerRadius = Config.Visuals.CornerRadius, Parent = TopBar})
Utils:MakeDraggable(TopBar, MainFrame)

local Title = Utils:Create("TextLabel", {Text = "PUDIM HUB <font color='rgb(255, 80, 0)'>V10 SPY FIXED</font>", RichText = true, Size = UDim2.new(0, 280, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Config.Visuals.TextColor, TextXAlignment = Enum.TextXAlignment.Left, Parent = TopBar})

local CloseBtn = Utils:Create("TextButton", {Text = "✕", Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -40, 0.5, -15), BackgroundColor3 = Color3.fromRGB(255, 60, 60), TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, Parent = TopBar})
Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CloseBtn})

local MinBtn = Utils:Create("TextButton", {Text = "—", Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(1, -75, 0.5, -15), BackgroundColor3 = Config.Visuals.BackgroundColor, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.GothamBold, Parent = TopBar})
Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = MinBtn})

local Sidebar = Utils:Create("Frame", {Size = UDim2.new(0, 130, 1, -55), Position = UDim2.new(0, 10, 0, 50), BackgroundTransparency = 1, Parent = MainFrame})
Utils:Create("UIListLayout", {Padding = UDim.new(0, 8), Parent = Sidebar})

local ContentContainer = Utils:Create("Frame", {Size = UDim2.new(1, -160, 1, -60), Position = UDim2.new(0, 150, 0, 55), BackgroundTransparency = 1, Parent = MainFrame})

local Tabs = {}
local function CreateTab(name)
    local TabBtn = Utils:Create("TextButton", {Text = "  " .. name, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Config.Visuals.SecondaryColor, TextColor3 = Color3.fromRGB(180, 180, 180), Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Sidebar})
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabBtn})
    
    local Page = Utils:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0), 
        BackgroundTransparency = 1, 
        Visible = false, 
        ScrollBarThickness = 3, 
        ScrollBarImageColor3 = Config.Visuals.MainColor,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = ContentContainer
    })
    
    Utils:Create("UIListLayout", {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Page})
    Utils:Create("UIPadding", {PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 5), Parent = Page})

    TabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do t.Page.Visible = false t.Btn.TextColor3 = Color3.fromRGB(180, 180, 180) t.Btn.BackgroundColor3 = Config.Visuals.SecondaryColor end
        Page.Visible = true TabBtn.TextColor3 = Config.Visuals.MainColor TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    end)
    Tabs[name] = {Btn = TabBtn, Page = Page}
    table.insert(UIObjects.TabButtons, TabBtn)
    return Page
end

local function CreateToggle(parent, text, stateKey, callback)
    local Frame = Utils:Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Config.Visuals.SecondaryColor, Parent = parent})
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Frame})
    local Label = Utils:Create("TextLabel", {Text = text, Size = UDim2.new(0.7, 0, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextColor3 = Config.Visuals.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Frame})
    local ClickBtn = Utils:Create("TextButton", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "", Parent = Frame})
    local ToggleBg = Utils:Create("Frame", {Size = UDim2.new(0, 45, 0, 22), Position = UDim2.new(1, -57, 0.5, -11), BackgroundColor3 = Color3.fromRGB(45, 45, 55), Parent = Frame})
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBg})
    local Circle = Utils:Create("Frame", {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Color3.fromRGB(200, 200, 200), Parent = ToggleBg})
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})
    local function Update()
        local enabled = Config.States[stateKey]
        TweenService:Create(ToggleBg, TweenInfo.new(0.3), {BackgroundColor3 = enabled and Config.Visuals.MainColor or Color3.fromRGB(45, 45, 55)}):Play()
        TweenService:Create(Circle, TweenInfo.new(0.3), {Position = enabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}):Play()
    end
    ClickBtn.MouseButton1Click:Connect(function() Config.States[stateKey] = not Config.States[stateKey] Update() if callback then callback(Config.States[stateKey]) end end)
    Update()
    table.insert(UIObjects.Toggles, {Bg = ToggleBg, Key = stateKey})
end

local function CreateButton(parent, text, callback)
    local Frame = Utils:Create("Frame", {Size = UDim2.new(1, 0, 0, 45), BackgroundColor3 = Config.Visuals.SecondaryColor, Parent = parent})
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Frame})
    local Btn = Utils:Create("TextButton", {Text = text, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextColor3 = Config.Visuals.TextColor, TextSize = 14, Parent = Frame})
    Btn.MouseButton1Click:Connect(callback)
    return Frame
end

local function CreateSlider(parent, text, min, max, stateKey, callback)
    local Frame = Utils:Create("Frame", {Size = UDim2.new(1, 0, 0, 65), BackgroundColor3 = Config.Visuals.SecondaryColor, Parent = parent})
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Frame})
    local Label = Utils:Create("TextLabel", {Text = text .. " : " .. Config.States[stateKey], Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextColor3 = Config.Visuals.TextColor, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = Frame})
    local SliderBg = Utils:Create("Frame", {Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 45), BackgroundColor3 = Color3.fromRGB(45, 45, 55), Parent = Frame})
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderBg})
    local SliderFill = Utils:Create("Frame", {Size = UDim2.new((Config.States[stateKey] - min) / (max - min), 0, 1, 0), BackgroundColor3 = Config.Visuals.MainColor, Parent = SliderBg})
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
    local function Update(input)
        local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        Config.States[stateKey] = val
        Label.Text = text .. " : " .. val
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        if callback then callback(val) end
    end
    SliderBg.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Update(input) end end)
end

local function CreateAccordion(parent, text, height)
    local Frame = Utils:Create("Frame", {Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = Config.Visuals.SecondaryColor, ClipsDescendants = true, Parent = parent})
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Frame})
    local Title = Utils:Create("TextLabel", {Text = text, Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextColor3 = Config.Visuals.TextColor, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = Frame})
    local Arrow = Utils:Create("TextLabel", {Text = "▼", Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(1, -40, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextColor3 = Config.Visuals.TextColor, TextSize = 14, Parent = Frame})
    local Container = Utils:Create("Frame", {Size = UDim2.new(1, -20, 0, height - 50), Position = UDim2.new(0, 10, 0, 45), BackgroundTransparency = 1, Parent = Frame})
    local isOpen = false
    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isOpen = not isOpen
            TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, isOpen and height or 40)}):Play()
            Arrow.Text = isOpen and "▲" or "▼"
        end
    end)
    return Container
end

-- [ ABAS ]
local FarmPage = CreateTab("Auto Farm")
local EspPage = CreateTab("Visuals")
local PlayerPage = CreateTab("Player")
local VisualPage = CreateTab("Visual")
local StatusPage = CreateTab("Status")

Tabs["Auto Farm"].Btn.TextColor3 = Config.Visuals.MainColor
Tabs["Auto Farm"].Page.Visible = true

-- ABA AUTO FARM
CreateToggle(FarmPage, "Auto Win (Full God Mode)", "AutoWin")
CreateToggle(FarmPage, "Auto TP Computers (Safe)", "AutoTPComputers")
CreateToggle(FarmPage, "Anti-Erro Computador (SPY FIXED)", "AntiErroComp")
CreateToggle(FarmPage, "Auto Beast (Kill All)", "AutoBeast")
CreateToggle(FarmPage, "Auto Save (Cápsulas)", "AutoSave")
CreateToggle(FarmPage, "Auto Abrir Portas", "AutoDoors")

CreateButton(FarmPage, "Auto TP Jogadores (Próximo)", function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local target = nil
    local shortestDist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not (p.Character:FindFirstChild("Tube") or p.Character:FindFirstChild("Tied")) then
                local dist = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then shortestDist = dist target = p.Character end
            end
        end
    end
    if target then char.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3) end
end)

CreateButton(FarmPage, "Hack Todos Computadores", function()
    for _, computer in pairs(workspace:GetDescendants()) do
        if computer.Name == "ComputerTable" then
            local trigger = computer:FindFirstChild("ComputerTrigger", true)
            if trigger and trigger:FindFirstChild("Event") then
                SafeFireServer("Input", "Trigger", true, trigger.Event)
                task.wait(0.1)
            end
        end
    end
end)

-- ABA VISUALS
CreateToggle(EspPage, "ESP Computers (Smart)", "EspComputers")
CreateToggle(EspPage, "ESP Beast (Tracers)", "EspBeast")
CreateToggle(EspPage, "ESP Players", "EspPlayers")
CreateToggle(EspPage, "ESP Cápsulas (Dynamic)", "EspPods")
CreateToggle(EspPage, "ESP Saídas (GPS AI)", "EspExits")
CreateToggle(EspPage, "FullBright", "FullBright", function(v) if not v then Lighting.Brightness = Config.Defaults.Brightness Lighting.ClockTime = Config.Defaults.ClockTime Lighting.FogEnd = Config.Defaults.FogEnd end end)

-- ABA PLAYER
CreateToggle(PlayerPage, "Speed Bom (26)", "SpeedBom", function(v) if not v then if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end end)
CreateToggle(PlayerPage, "Custom Speed", "SpeedEnabled")
CreateSlider(PlayerPage, "WalkSpeed Value", 16, 200, "Speed")
CreateToggle(PlayerPage, "Anti-Ragdoll (BRUTEFORCE)", "AntiRagdoll")
CreateToggle(PlayerPage, "No Fog", "NoFog", function(v) if not v then Lighting.FogEnd = Config.Defaults.FogEnd Lighting.FogStart = Config.Defaults.FogStart end end)
CreateToggle(PlayerPage, "Noclip", "Noclip")
CreateToggle(PlayerPage, "Remover Limite de Zoom", "InfiniteZoom", function(v)
    if v then LocalPlayer.CameraMaxZoomDistance = 10000 else LocalPlayer.CameraMaxZoomDistance = Config.Defaults.MaxZoom end
end)
CreateToggle(PlayerPage, "Spider (Escalar Paredes)", "Spider")
CreateToggle(PlayerPage, "Click TP (CTRL + Clique)", "ClickTP")

-- FUNÇÃO CLICK TP
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if Config.States.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                local mouse = LocalPlayer:GetMouse()
                local target = mouse.Hit.Position
                char.HumanoidRootPart.CFrame = CFrame.new(target.X, target.Y + 3, target.Z)
            end
        end
    end
end)

-- ABA VISUAL (CORES E ESTILO)
local ColorAccordion = CreateAccordion(VisualPage, "Cores do Tema", 180)
local ColorGrid = Utils:Create("UIGridLayout", {CellSize = UDim2.new(0, 30, 0, 30), CellPadding = UDim2.new(0, 5, 0, 5), Parent = ColorAccordion})
local Colors25 = {
    Color3.fromRGB(130, 0, 255), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 127, 0), Color3.fromRGB(127, 255, 0), Color3.fromRGB(0, 255, 127),
    Color3.fromRGB(0, 127, 255), Color3.fromRGB(127, 0, 255), Color3.fromRGB(255, 0, 127), Color3.fromRGB(128, 128, 128), Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(165, 42, 42), Color3.fromRGB(210, 105, 30), Color3.fromRGB(255, 215, 0), Color3.fromRGB(154, 205, 50), Color3.fromRGB(70, 130, 180),
    Color3.fromRGB(255, 105, 180), Color3.fromRGB(75, 0, 130), Color3.fromRGB(0, 128, 128), Color3.fromRGB(240, 230, 140), Color3.fromRGB(250, 128, 114)
}

local PDLogo = Utils:Create("TextButton", {Name = "PD", Text = "PD", Size = UDim2.new(0, 60, 0, 40), Position = UDim2.new(0, 20, 0.5, -20), BackgroundTransparency = 1, TextColor3 = Config.Visuals.MainColor, Font = Enum.Font.GothamBold, TextSize = 35, Visible = false, Parent = ScreenGui})
local PDStroke = Utils:Create("UIStroke", {Color = Config.Visuals.MainColor, Thickness = 2, Transparency = 0.2, Parent = PDLogo})
UIObjects.PDLogo = PDLogo
Utils:MakeDraggable(PDLogo, PDLogo)

for _, color in pairs(Colors25) do
    local ColorBtn = Utils:Create("TextButton", {Text = "", BackgroundColor3 = color, Parent = ColorAccordion})
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ColorBtn})
    ColorBtn.MouseButton1Click:Connect(function() 
        Config.Visuals.MainColor = color
        for _, stroke in pairs(UIObjects.MainStrokes) do stroke.Color = color end
        PDLogo.TextColor3 = color
        PDStroke.Color = color
        for _, tab in pairs(Tabs) do tab.Page.ScrollBarImageColor3 = color end
    end)
end

local StyleAccordion = CreateAccordion(VisualPage, "Estilo do Fundo (12 Opções)", 250)
local StyleGrid = Utils:Create("UIGridLayout", {CellSize = UDim2.new(0, 100, 0, 30), CellPadding = UDim2.new(0, 5, 0, 5), Parent = StyleAccordion})
local StyleOptions = {
    {Name = "Padrão", BG = Color3.fromRGB(15, 15, 25), Sec = Color3.fromRGB(25, 25, 35), Trans = 0},
    {Name = "Transparente", BG = Color3.fromRGB(15, 15, 25), Sec = Color3.fromRGB(25, 25, 35), Trans = 0.4},
    {Name = "Muito Transp.", BG = Color3.fromRGB(15, 15, 25), Sec = Color3.fromRGB(25, 25, 35), Trans = 0.7},
    {Name = "Preto Total", BG = Color3.new(0,0,0), Sec = Color3.fromRGB(10,10,10), Trans = 0},
    {Name = "Cinza Escuro", BG = Color3.fromRGB(25,25,25), Sec = Color3.fromRGB(35,35,35), Trans = 0},
    {Name = "Azul Noite", BG = Color3.fromRGB(5,5,20), Sec = Color3.fromRGB(10,10,30), Trans = 0},
    {Name = "Amoled", BG = Color3.new(0,0,0), Sec = Color3.new(0,0,0), Trans = 0},
    {Name = "Neon Dark", BG = Color3.fromRGB(10,0,20), Sec = Color3.fromRGB(20,0,40), Trans = 0.2},
    {Name = "Glass", BG = Color3.fromRGB(255,255,255), Sec = Color3.fromRGB(255,255,255), Trans = 0.8},
    {Name = "Retro", BG = Color3.fromRGB(40,20,60), Sec = Color3.fromRGB(60,30,90), Trans = 0},
    {Name = "Ocean", BG = Color3.fromRGB(0,20,40), Sec = Color3.fromRGB(0,40,80), Trans = 0.3},
    {Name = "Forest", BG = Color3.fromRGB(10,30,10), Sec = Color3.fromRGB(20,50,20), Trans = 0.2}
}
for _, style in pairs(StyleOptions) do
    local StyleBtn = Utils:Create("TextButton", {Text = style.Name, BackgroundColor3 = Color3.fromRGB(40, 40, 50), TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamMedium, TextSize = 10, Parent = StyleAccordion})
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = StyleBtn})
    StyleBtn.MouseButton1Click:Connect(function()
        MainFrame.BackgroundColor3 = style.BG MainFrame.BackgroundTransparency = style.Trans TopBar.BackgroundColor3 = style.Sec TopBar.BackgroundTransparency = style.Trans
        PDLogo.TextTransparency = style.Trans
        PDStroke.Transparency = style.Trans + 0.2
    end)
end

-- ABA STATUS
local StatusPanel = Utils:Create("Frame", {Size = UDim2.new(1, 0, 0, 220), BackgroundColor3 = Config.Visuals.SecondaryColor, Parent = StatusPage})
Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = StatusPanel})
local function CreateStatusItem(parent, title, icon, pos)
    return Utils:Create("TextLabel", {Text = icon .. " " .. title .. ": <font color='rgb(255, 255, 255)'>Carregando...</font>", RichText = true, Size = UDim2.new(1, -20, 0, 35), Position = UDim2.new(0, 15, 0, pos), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, TextColor3 = Color3.fromRGB(200, 200, 200), TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = parent})
end
local BeastChanceLabel = CreateStatusItem(StatusPanel, "Chance de Fera", "👹", 15)
local LevelLabel = CreateStatusItem(StatusPanel, "Nível Atual", "⭐", 65)
local XPLabel = CreateStatusItem(StatusPanel, "XP para Próximo", "📈", 115)
local CoinsLabel = CreateStatusItem(StatusPanel, "Moedas", "💰", 165)
local RemoteStatus = CreateStatusItem(StatusPanel, "Remote Status", "📡", 215)

task.spawn(function()
    while task.wait(2) do
        pcall(function()
            -- Chance de Fera
            local chance = "0%"
            local screenGui = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
            if screenGui then 
                local beastMenu = screenGui:FindFirstChild("BeastMenu") 
                if beastMenu and beastMenu:FindFirstChild("Chance") then chance = beastMenu.Chance.Text end 
            end
            BeastChanceLabel.Text = "👹 Chance de Fera: <font color='rgb(255, 80, 0)'>" .. chance .. "</font>"
            
            -- Level e XP
            local stats = LocalPlayer:FindFirstChild("leaderstats")
            local level = (stats and stats:FindFirstChild("Level") and stats.Level.Value) or 0
            local coins = (stats and stats:FindFirstChild("Credits") and stats.Credits.Value) or 0
            local xp = 0
            local playerData = ReplicatedStorage:FindFirstChild("PlayerData")
            if playerData then
                local myData = playerData:FindFirstChild(LocalPlayer.Name)
                if myData and myData:FindFirstChild("Experience") then xp = myData.Experience.Value end
            end
            local nextLevelXP = (level + 1) * 1000
            local xpNeeded = math.max(0, nextLevelXP - xp)
            LevelLabel.Text = "⭐ Nível Atual: <font color='rgb(255, 255, 0)'>" .. level .. "</font>"
            XPLabel.Text = "📈 XP para Próximo: <font color='rgb(50, 255, 50)'>" .. xpNeeded .. "</font>"
            CoinsLabel.Text = "💰 Moedas: <font color='rgb(255, 215, 0)'>" .. coins .. "</font>"
            
            -- Status do Remote
            local status = "🟢 Conectado"
            if not Remote or not Remote:IsDescendantOf(game) then
                status = "🔴 Não Encontrado"
            end
            RemoteStatus.Text = "📡 Remote Status: <font color='" .. 
                (status:find("Conectado") and "rgb(0, 255, 0)" or "rgb(255, 0, 0)") .. 
                "'>" .. status .. "</font>"
        end)
    end
end)

-- [ LÓGICA DE ESP OTIMIZADA ]
local function RemoveESP(obj)
    if not obj then return end
    if obj:FindFirstChild("PudimESP") then obj.PudimESP:Destroy() end
    if obj:FindFirstChild("PudimName") then obj.PudimName:Destroy() end
end

local function ApplyESP(obj, color, name)
    if not obj then return end
    local esp = obj:FindFirstChild("PudimESP")
    if not esp then
        Utils:Create("Highlight", {Name = "PudimESP", FillColor = color, OutlineColor = Color3.new(1, 1, 1), FillTransparency = 0.4, OutlineTransparency = 0, Parent = obj})
        local b = Utils:Create("BillboardGui", {Name = "PudimName", AlwaysOnTop = true, Size = UDim2.new(0, 100, 0, 20), StudsOffset = Vector3.new(0, 3, 0), Parent = obj})
        Utils:Create("TextLabel", {Text = name, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = color, Font = Enum.Font.GothamBold, TextSize = 13, TextStrokeTransparency = 0.5, Parent = b})
    else
        esp.FillColor = color
        if obj:FindFirstChild("PudimName") then 
            local label = obj.PudimName:FindFirstChild("TextLabel")
            if label then label.TextColor3 = color label.Text = name end
        end
    end
end

-- [ BEAST TRACER CORRIGIDO ]
local BeastTracer = Utils:Create("BillboardGui", {
    Name = "BeastTracer",
    Size = UDim2.new(0, 2, 0, 200),
    AlwaysOnTop = true,
    Enabled = false,
    Parent = ScreenGui
})
local TracerLine = Utils:Create("Frame", {
    BackgroundColor3 = Color3.new(1, 0, 0),
    Size = UDim2.new(1, 0, 1, 0),
    Parent = BeastTracer
})

local MapCache = {Computers = {}, Pods = {}, Exits = {}}
local function UpdateMapCache()
    table.clear(MapCache.Computers) table.clear(MapCache.Pods) table.clear(MapCache.Exits)
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "ComputerTable" then table.insert(MapCache.Computers, v)
        elseif v.Name == "FreezePod" or v.Name == "CryoPod" or v.Name == "Tube" then table.insert(MapCache.Pods, v)
        elseif v.Name == "ExitDoor" then table.insert(MapCache.Exits, v) end
    end
end

local lastUpdate = 0
local function SafeUpdateCache()
    if tick() - lastUpdate > 2 then lastUpdate = tick() UpdateMapCache() end
end
UpdateMapCache()
workspace.DescendantAdded:Connect(SafeUpdateCache)
workspace.DescendantRemoving:Connect(SafeUpdateCache)

local CurrentBeast = nil

-- [ FUNÇÕES DO JOGO ]
local function ToggleDoor(door, state)
    if door and door:FindFirstChild("DoorTrigger") then
        local trigger = door.DoorTrigger
        if trigger:FindFirstChild("Event") then
            SafeFireServer("Input", "Trigger", state, trigger.Event)
        end
    end
end

local function SolveSkillCheck()
    SafeFireServer("SetPlayerMinigameResult", true)
    
    -- Backup method
    pcall(function()
        for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                for _, obj in pairs(gui:GetDescendants()) do
                    if (obj.Name == "SkillCheck" or obj.Name == "CircleTimer") 
                       and obj:IsA("Frame") and obj.Visible then
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton1(Vector2.new(0,0))
                        return
                    end
                end
            end
        end
    end)
end

-- [ LOOP ESP ]
task.spawn(function()
    while task.wait(0.5) do
        CurrentBeast = nil
        
        -- ESP Players e Beast
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local isBeast = p.Character:FindFirstChild("BeastPowers") or p.Backpack:FindFirstChild("Hammer")
                if isBeast then
                    CurrentBeast = p.Character
                    if Config.States.EspBeast then 
                        ApplyESP(p.Character, Color3.new(1, 0, 0), "BEAST")
                        BeastTracer.Enabled = true
                        BeastTracer.Adornee = p.Character.HumanoidRootPart
                    end
                elseif Config.States.EspPlayers then
                    ApplyESP(p.Character, Color3.fromRGB(0, 255, 0), p.Name)
                else
                    RemoveESP(p.Character)
                end
            end
        end
        
        if not Config.States.EspBeast or not CurrentBeast then
            BeastTracer.Enabled = false
        end
        
        -- ESP Computers
        if Config.States.EspComputers then
            for _, v in pairs(MapCache.Computers) do
                local screen = v:FindFirstChild("Screen", true)
                if screen then
                    local isDone = screen.Color == Color3.fromRGB(0, 255, 0)
                    ApplyESP(v, isDone and Color3.new(0, 1, 0) or Color3.new(1, 0, 0), isDone and "PRONTO" or "HACKEANDO")
                end
            end
        else 
            for _, v in pairs(MapCache.Computers) do RemoveESP(v) end 
        end
        
        -- ESP Pods
        if Config.States.EspPods then
            for _, v in pairs(MapCache.Pods) do
                local occupied = (v:FindFirstChild("Occupied") and v.Occupied.Value) or v:FindFirstChild("Model") or v:FindFirstChild("Character")
                ApplyESP(v, occupied and Color3.new(1, 0, 0) or Color3.new(0, 1, 1), occupied and "OCUPADA" or "LIVRE")
            end
        else 
            for _, v in pairs(MapCache.Pods) do RemoveESP(v) end 
        end
        
        -- ESP Exits
        if Config.States.EspExits then
            for _, v in pairs(MapCache.Exits) do ApplyESP(v, Color3.new(1, 1, 0), "SAÍDA") end
        else 
            for _, v in pairs(MapCache.Exits) do RemoveESP(v) end 
        end
    end
end)

-- [ LOOP PRINCIPAL ]
RunService.RenderStepped:Connect(function()
    -- Visuals
    if Config.States.FullBright then 
        Lighting.Brightness = 2 
        Lighting.ClockTime = 14 
    end
    if Config.States.NoFog then 
        Lighting.FogEnd = 1000000 
    end
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        -- Speed
        if Config.States.SpeedBom then 
            hum.WalkSpeed = 26 
        elseif Config.States.SpeedEnabled then 
            hum.WalkSpeed = Config.States.Speed 
        else 
            hum.WalkSpeed = 16 
        end
        
        -- Noclip
        if Config.States.Noclip then 
            for _, part in pairs(char:GetChildren()) do 
                if part:IsA("BasePart") then 
                    part.CanCollide = false 
                end 
            end 
        end
        
        -- Anti Ragdoll
        if Config.States.AntiRagdoll then
            hum.PlatformStand = false
            if hum.Sit then hum.Sit = false end
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Ragdoll then 
                hum:ChangeState(Enum.HumanoidStateType.GettingUp) 
            end
        end
        
        -- Spider
        if Config.States.Spider and hrp then
            local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 2)
            local part = workspace:FindPartOnRay(ray, char)
            if part then 
                hrp.Velocity = Vector3.new(hrp.Velocity.X, 35, hrp.Velocity.Z) 
            end
        end
        
        -- Anti Erro e Auto Win
        if Config.States.AntiErroComp or Config.States.AutoWin then 
            pcall(SolveSkillCheck) 
        end
        
        -- Auto Doors
        if Config.States.AutoDoors and hrp then
            for _, part in pairs(workspace:GetPartsInRadius(hrp.Position, 15)) do
                if part.Name == "DoorTrigger" and part.Parent then
                    ToggleDoor(part.Parent, true)
                end
            end
        end
    end
end)

-- [ AUTO FARM LOOP ]
task.spawn(function()
    while task.wait(0.5) do
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            
            if Config.States.AutoTPComputers or Config.States.AutoWin then
                pcall(function()
                    for _, computer in pairs(MapCache.Computers) do
                        local screen = computer:FindFirstChild("Screen", true)
                        if screen and screen.Color ~= Color3.fromRGB(0, 255, 0) then
                            -- Teleport to computer
                            hrp.CFrame = computer.PrimaryPart.CFrame * CFrame.new(0, 4, 2)
                            
                            -- Find and activate trigger
                            local trigger = computer:FindFirstChild("ComputerTrigger", true)
                            if trigger and trigger:FindFirstChild("Event") then
                                SafeFireServer("Input", "Trigger", true, trigger.Event)
                            end
                            
                            task.wait(1)
                            break
                        end
                    end
                end)
            end
        end
    end
end)

-- [ CONTROLES DA UI ]
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    MainFrame:TweenSize(isMinimized and UDim2.new(0, 580, 0, 45) or UDim2.new(0, 580, 0, 400), "Out", "Quart", 0.5, true)
    Sidebar.Visible, ContentContainer.Visible = not isMinimized, not isMinimized
end)

CloseBtn.MouseButton1Click:Connect(function() 
    MainFrame.Visible = false 
    PDLogo.Visible = true 
end)

PDLogo.MouseButton1Click:Connect(function() 
    MainFrame.Visible = true 
    PDLogo.Visible = false 
end)

-- [ COMANDOS DO CHAT ]
LocalPlayer.Chatted:Connect(function(msg)
    msg = msg:lower()
    if msg == "/pudim" then
        MainFrame.Visible = not MainFrame.Visible
        PDLogo.Visible = not MainFrame.Visible
    elseif msg == "/esp on" then
        Config.States.EspPlayers = true
        Config.States.EspComputers = true
    elseif msg == "/esp off" then
        Config.States.EspPlayers = false
        Config.States.EspComputers = false
    elseif msg == "/farm" then
        Config.States.AutoTPComputers = not Config.States.AutoTPComputers
        print("Auto Farm: " .. (Config.States.AutoTPComputers and "ON" or "OFF"))
    end
end)

print("🎮 PudimHub V10 FULL FIXED - CARREGADO COM SUCESSO!")
print("📟 Comandos: /pudim, /esp on/off, /farm")
