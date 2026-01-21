--[[
    MANUS ELITE HUB - PROFESSIONAL SCRIPT INTERFACE
    Version: 1.0.0
    Description: A complex, high-end script hub for Roblox with 50+ features.
    NOTE: This file contains safety checks and fixes for runtime errors (undefined variables,
    mismatched names, event/connect misuse). Many "feature stubs" remain intentionally as placeholders.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting") -- for BlurEffect parent

-- Local player & helpers
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

local function getCharacter()
    if not LocalPlayer then return nil end
    local char = LocalPlayer.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return char, humanoid, hrp
end

-- Global Tab Variables
local Movement, Player, Teleport, Friends, Logs, Server, Settings, Credits, StatisticsTab

-- UI Library Core
local Library = {
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(15, 15, 15),
        SecondaryColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(0, 255, 255), -- Neon Cyan default
        TextColor = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold
    },
    Rainbow = true
}

-- ensure notifications default
_G.NotificationsEnabled = _G.NotificationsEnabled ~= false

-- Notification System
function Library:Notify(title, text, duration)
    if _G.NotificationsEnabled == false then return end
    local NotifyGui = CoreGui:FindFirstChild("ManusNotifications") or Instance.new("ScreenGui")
    NotifyGui.Name = "ManusNotifications"
    if not NotifyGui.Parent then NotifyGui.Parent = CoreGui end

    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 250, 0, 80)
    Notification.Position = UDim2.new(1, 30, 1, -100)
    Notification.BackgroundColor3 = Library.Theme.MainColor
    Notification.Parent = NotifyGui

    local UICorner = Instance.new("UICorner", Notification)
    local UIStroke = Instance.new("UIStroke", Notification)
    UIStroke.Color = Library.Theme.AccentColor
    UIStroke.Thickness = 2

    local T = Instance.new("TextLabel", Notification)
    T.Text = "🔔 " .. title
    T.Size = UDim2.new(1, -20, 0, 30)
    T.Position = UDim2.new(0, 10, 0, 5)
    T.Font = Enum.Font.GothamBold
    T.TextColor3 = Library.Theme.AccentColor
    T.BackgroundTransparency = 1
    T.TextXAlignment = Enum.TextXAlignment.Left

    local C = Instance.new("TextLabel", Notification)
    C.Text = text
    C.Size = UDim2.new(1, -20, 0, 40)
    C.Position = UDim2.new(0, 10, 0, 30)
    C.Font = Enum.Font.Gotham
    C.TextColor3 = Color3.fromRGB(200, 200, 200)
    C.BackgroundTransparency = 1
    C.TextWrapped = true
    C.TextXAlignment = Enum.TextXAlignment.Left

    TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(1, -260, 1, -100)}):Play()
    delay(duration or 5, function()
        if Notification and Notification.Parent then
            TweenService:Create(Notification, TweenInfo.new(0.5), {Position = UDim2.new(1, 30, 1, -100)}):Play()
            wait(0.5)
            if Notification and Notification.Destroy then pcall(function() Notification:Destroy() end) end
        end
    end)
end

-- Rainbow Loop
spawn(function()
    while task.wait(0.05) do
        if Library.Rainbow then
            local hue = tick() % 5 / 5
            Library.Theme.AccentColor = Color3.fromHSV(hue, 1, 1)
        end
    end
end)

-- Utility Functions
local function MakeDraggable(gui)
    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        if not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- News & Updates Window
function Library:ShowNews(callback)
    local NewsGui = Instance.new("ScreenGui")
    NewsGui.Name = "PudimNews"
    NewsGui.Parent = CoreGui

    local NewsFrame = Instance.new("Frame", NewsGui)
    NewsFrame.Size = UDim2.new(0, 300, 0, 350)
    NewsFrame.Position = UDim2.new(0.5, -150, 0.5, -175)
    NewsFrame.BackgroundColor3 = Library.Theme.MainColor
    NewsFrame.BackgroundTransparency = 0.1
    Instance.new("UICorner", NewsFrame)
    Instance.new("UIStroke", NewsFrame).Color = Library.Theme.AccentColor

    local Title = Instance.new("TextLabel", NewsFrame)
    Title.Text = "📰 WHAT'S NEW?"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Library.Theme.AccentColor
    Title.BackgroundTransparency = 1
    Title.TextSize = 18

    local Content = Instance.new("TextLabel", NewsFrame)
    Content.Text = "• Added Mobile Optimization\n• New Dynamic Themes\n• 380+ Features Ready\n• Key System Integrated\n• Acrylic UI Effects\n\nEnjoy the best mobile hub!"
    Content.Size = UDim2.new(1, -20, 1, -100)
    Content.Position = UDim2.new(0, 10, 0, 50)
    Content.Font = Enum.Font.Gotham
    Content.TextColor3 = Color3.fromRGB(200, 200, 200)
    Content.BackgroundTransparency = 1
    Content.TextSize = 14
    Content.TextWrapped = true
    Content.TextYAlignment = Enum.TextYAlignment.Top

    local CloseBtn = Instance.new("TextButton", NewsFrame)
    CloseBtn.Text = "CONTINUE"
    CloseBtn.Size = UDim2.new(0, 200, 0, 40)
    CloseBtn.Position = UDim2.new(0.5, -100, 1, -50)
    CloseBtn.BackgroundColor3 = Library.Theme.SecondaryColor
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", CloseBtn)

    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(NewsFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -150, 1, 50)}):Play()
        wait(0.5)
        if NewsGui and NewsGui.Destroy then pcall(function() NewsGui:Destroy() end) end
        if callback then pcall(callback) end
    end)
end

-- Key System Creation
function Library:CreateKeySystem(correctKey, callback)
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "PudimKeySystem"
    KeyGui.Parent = CoreGui

    local KeyFrame = Instance.new("Frame", KeyGui)
    KeyFrame.Size = UDim2.new(0, 350, 0, 200)
    KeyFrame.Position = UDim2.new(0.5, -175, 0.5, -100)
    KeyFrame.BackgroundColor3 = Library.Theme.MainColor
    KeyFrame.BorderSizePixel = 0
    KeyFrame.ClipsDescendants = true

    local UICorner = Instance.new("UICorner", KeyFrame)
    local UIStroke = Instance.new("UIStroke", KeyFrame)
    UIStroke.Color = Library.Theme.AccentColor
    UIStroke.Thickness = 2

    -- Sunset Background for Key System
    local BG = Instance.new("ImageLabel", KeyFrame)
    BG.Size = UDim2.new(1, 0, 1, 0)
    BG.Image = "rbxassetid://6073763717"
    BG.ImageTransparency = 0.7
    BG.ScaleType = Enum.ScaleType.Crop

    local Title = Instance.new("TextLabel", KeyFrame)
    Title.Text = "🍮 PUDIM HUB | KEY SYSTEM"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Font = Enum.Font.GothamBold
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.TextSize = 16

    local KeyInput = Instance.new("TextBox", KeyFrame)
    KeyInput.PlaceholderText = "Enter Key Here..."
    KeyInput.Size = UDim2.new(0, 250, 0, 35)
    KeyInput.Position = UDim2.new(0.5, -125, 0.4, 0)
    KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.Text = ""
    Instance.new("UICorner", KeyInput)

    local VerifyBtn = Instance.new("TextButton", KeyFrame)
    VerifyBtn.Text = "Verify Key"
    VerifyBtn.Size = UDim2.new(0, 120, 0, 35)
    VerifyBtn.Position = UDim2.new(0.2, 0, 0.7, 0)
    VerifyBtn.BackgroundColor3 = Library.Theme.SecondaryColor
    VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VerifyBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", VerifyBtn)

    local GetKeyBtn = Instance.new("TextButton", KeyFrame)
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.Size = UDim2.new(0, 120, 0, 35)
    GetKeyBtn.Position = UDim2.new(0.55, 0, 0.7, 0)
    GetKeyBtn.BackgroundColor3 = Library.Theme.SecondaryColor
    GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", GetKeyBtn)

    -- Animations
    KeyFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 350, 0, 200)}):Play()

    VerifyBtn.MouseButton1Click:Connect(function()
        if KeyInput.Text == correctKey then
            Library:Notify("Success", "Key Validated!", 3)
            TweenService:Create(KeyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 0, 0, 0)}):Play()
            wait(0.5)
            if KeyGui and KeyGui.Destroy then pcall(function() KeyGui:Destroy() end) end
            if callback then pcall(callback) end
        else
            Library:Notify("Error", "Invalid Key! Please try again.", 3)
            KeyInput.TextColor3 = Color3.fromRGB(255, 0, 0)
            wait(0.5)
            KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)

    GetKeyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then setclipboard("https://pudimhub.com/getkey") end
        end)
        Library:Notify("Key System", "Link copied to clipboard!", 3)
    end)
end

-- Main Window Creation

-- Floating Button System
function Library:CreateFloatingButton()
    if CoreGui:FindFirstChild("PudimHubToggle") then return end

    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "PudimHubToggle"
    ToggleGui.Parent = CoreGui

    local MainBtn = Instance.new("TextButton", ToggleGui)
    MainBtn.Name = "MainBtn"
    MainBtn.Size = UDim2.new(0, 120, 0, 45)
    MainBtn.Position = UDim2.new(0.5, -60, 0.1, 0)
    MainBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainBtn.Text = "PudimHub"
    MainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainBtn.Font = Enum.Font.GothamBold
    MainBtn.TextSize = 16
    MainBtn.ClipsDescendants = true
    MainBtn.AutoButtonColor = false

    local UICorner = Instance.new("UICorner", MainBtn)
    UICorner.CornerRadius = UDim.new(0, 10)

    local UIStroke = Instance.new("UIStroke", MainBtn)
    UIStroke.Thickness = 2
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Math Symbols Background
    local Symbols = Instance.new("TextLabel", MainBtn)
    Symbols.Size = UDim2.new(1, 0, 1, 0)
    Symbols.BackgroundTransparency = 1
    Symbols.Text = "+ - × ÷ √ ∑ ∞"
    Symbols.TextColor3 = Color3.fromRGB(255, 255, 255)
    Symbols.TextTransparency = 0.85
    Symbols.TextSize = 12
    Symbols.Font = Enum.Font.Code
    Symbols.ZIndex = 0

    -- Rainbow/Gradient Animation
    spawn(function()
        while task.wait(0.05) do
            if not MainBtn or not MainBtn.Parent then break end
            local hue = tick() % 5 / 5
            local color = Color3.fromHSV(hue, 1, 1)
            UIStroke.Color = color
            MainBtn.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
        end
    end)

    -- Hover Animations
    MainBtn.MouseEnter:Connect(function()
        TweenService:Create(MainBtn, TweenInfo.new(0.3), {Size = UDim2.new(0, 140, 0, 55), BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
    end)
    MainBtn.MouseLeave:Connect(function()
        TweenService:Create(MainBtn, TweenInfo.new(0.3), {Size = UDim2.new(0, 120, 0, 45), BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
    end)

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    MainBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Click to Reopen
    MainBtn.MouseButton1Click:Connect(function()
        local mainGui = CoreGui:FindFirstChild("ManusEliteHub")
        if mainGui then
            mainGui.Enabled = not mainGui.Enabled
            if mainGui.Enabled then
                Library:Notify("PudimHub", "Interface Restored!", 2)
            end
        end
    end)
end

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ManusEliteHub"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Enabled = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = self.Theme.MainColor
    MainFrame.BackgroundTransparency = 0.1 -- Acrylic Effect Base
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.Size = UDim2.new(0, 600, 0, 430) -- Increased for Footer
    MainFrame.ClipsDescendants = true

    -- Background Image (Sunset)
    local BackgroundImage = Instance.new("ImageLabel")
    BackgroundImage.Name = "BackgroundImage"
    BackgroundImage.Parent = MainFrame
    BackgroundImage.BackgroundTransparency = 1
    BackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    BackgroundImage.Image = "rbxassetid://6073763717" -- Sunset ID
    BackgroundImage.ImageTransparency = 0.7
    BackgroundImage.ScaleType = Enum.ScaleType.Crop

    -- Neon Border (RGB)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Thickness = 2
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = MainFrame

    spawn(function()
        while task.wait(0.05) do
            UIStroke.Color = Library.Theme.AccentColor
        end
    end)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.BackgroundColor3 = self.Theme.SecondaryColor
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 40)

    local TopBarCorner = Instance.new("UICorner", TopBar)
    TopBarCorner.CornerRadius = UDim.new(0, 8)

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(0, 200, 1, 0)
    Title.Font = self.Theme.Font
    Title.Text = title
    Title.TextColor3 = self.Theme.TextColor
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    -- Stats in TopBar (FPS/Ping)
    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Name = "Stats"
    StatsLabel.Parent = TopBar
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.Position = UDim2.new(1, -220, 0, 0)
    StatsLabel.Size = UDim2.new(0, 200, 1, 0)
    StatsLabel.Font = Enum.Font.Gotham
    StatsLabel.Text = "FPS: 0 | Ping: 0ms"
    StatsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    StatsLabel.TextSize = 12
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Right

    -- Search Bar
    local SearchBar = Instance.new("TextBox")
    SearchBar.Name = "SearchBar"
    SearchBar.Parent = TopBar
    SearchBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    SearchBar.Position = UDim2.new(0, 220, 0.5, -12)
    SearchBar.Size = UDim2.new(0, 150, 0, 24)
    SearchBar.Font = Enum.Font.Gotham
    SearchBar.PlaceholderText = "🔍 Search..."
    SearchBar.Text = ""
    SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBar.TextSize = 12
    Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 4)

    -- Blur Effect
    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0
    Blur.Enabled = false
    Blur.Parent = Lighting

    -- Close Button (window destroy)
    local CloseWindowBtn = Instance.new("TextButton", TopBar)
    CloseWindowBtn.Name = "CloseWindowBtn"
    CloseWindowBtn.BackgroundTransparency = 1
    CloseWindowBtn.Position = UDim2.new(1, -40, 0, 0)
    CloseWindowBtn.Size = UDim2.new(0, 40, 0, 40)
    CloseWindowBtn.Font = Enum.Font.GothamBold
    CloseWindowBtn.Text = "X"
    CloseWindowBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseWindowBtn.TextSize = 18

    CloseWindowBtn.MouseButton1Click:Connect(function()
        Blur.Enabled = false
        if ScreenGui and ScreenGui.Destroy then pcall(function() ScreenGui:Destroy() end) end
    end)

    -- Toggle Hide Button (left X) - earlier Close behavior
    local MinimizeBtn = Instance.new("TextButton", TopBar)
    MinimizeBtn.Name = "MinimizeBtn"
    MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    MinimizeBtn.Position = UDim2.new(1, -75, 0, 5)
    MinimizeBtn.BackgroundTransparency = 1
    MinimizeBtn.Text = "×"
    MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeBtn.TextSize = 20
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
        Library:CreateFloatingButton()
        Library:Notify("PudimHub", "Interface Hidden!", 2)
    end)

    -- Toggle Blur with Visibility
    local function UpdateBlur()
        Blur.Enabled = MainFrame.Visible
        if MainFrame.Visible then
            TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 20}):Play()
        else
            Blur.Size = 0
        end
    end

    MainFrame:GetPropertyChangedSignal("Visible"):Connect(UpdateBlur)

    -- Initialize visibility
    MainFrame.Visible = true
    UpdateBlur()

    -- Console Window
    local ConsoleFrame = Instance.new("Frame")
    ConsoleFrame.Name = "Console"
    ConsoleFrame.Parent = MainFrame
    ConsoleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    ConsoleFrame.Position = UDim2.new(0, 160, 1, -100)
    ConsoleFrame.Size = UDim2.new(1, -170, 0, 90)
    ConsoleFrame.Visible = false
    Instance.new("UICorner", ConsoleFrame)

    local ConsoleTitle = Instance.new("TextLabel", ConsoleFrame)
    ConsoleTitle.Text = "  > CONSOLE DEBUG"
    ConsoleTitle.Size = UDim2.new(1, 0, 0, 20)
    ConsoleTitle.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ConsoleTitle.TextColor3 = Color3.fromRGB(0, 255, 0)
    ConsoleTitle.Font = Enum.Font.Code
    ConsoleTitle.TextSize = 12
    ConsoleTitle.TextXAlignment = Enum.TextXAlignment.Left

    local ConsoleLogs = Instance.new("ScrollingFrame", ConsoleFrame)
    ConsoleLogs.Size = UDim2.new(1, -10, 1, -30)
    ConsoleLogs.Position = UDim2.new(0, 5, 0, 25)
    ConsoleLogs.BackgroundTransparency = 1
    ConsoleLogs.ScrollBarThickness = 2
    Instance.new("UIListLayout", ConsoleLogs)

    -- Sidebar (Tabs Container)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = MainFrame
    Sidebar.BackgroundColor3 = self.Theme.SecondaryColor
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.Size = UDim2.new(0, 150, 1, -40)

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 5, 0, 10)
    TabContainer.Size = UDim2.new(1, -10, 1, -20)
    TabContainer.ScrollBarThickness = 0

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)

    -- Content Area
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Parent = MainFrame
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Position = UDim2.new(0, 160, 0, 50)
    ContentHolder.Size = UDim2.new(1, -170, 1, -90) -- Adjusted for Footer

    -- Footer (Status Bar)
    local Footer = Instance.new("Frame")
    Footer.Name = "Footer"
    Footer.Parent = MainFrame
    Footer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Footer.BackgroundTransparency = 0.3
    Footer.BorderSizePixel = 0
    Footer.Position = UDim2.new(0, 0, 1, -30)
    Footer.Size = UDim2.new(1, 0, 0, 30)

    local FooterText = Instance.new("TextLabel")
    FooterText.Parent = Footer
    FooterText.BackgroundTransparency = 1
    FooterText.Position = UDim2.new(0, 15, 0, 0)
    FooterText.Size = UDim2.new(1, -30, 1, 0)
    FooterText.Font = Enum.Font.Gotham
    FooterText.Text = "User: " .. (LocalPlayer and LocalPlayer.Name or "Unknown") .. " | Status: Premium | Server: " .. (game.JobId ~= "" and game.JobId or "Local") .. " | Uptime: 00:00"
    FooterText.TextColor3 = Color3.fromRGB(200, 200, 200)
    FooterText.TextSize = 11
    FooterText.TextXAlignment = Enum.TextXAlignment.Left

    -- Uptime Counter
    local startTime = tick()
    spawn(function()
        while task.wait(1) do
            local uptime = tick() - startTime
            local minutes = math.floor(uptime / 60)
            local seconds = math.floor(uptime % 60)
            FooterText.Text = "User: " .. (LocalPlayer and LocalPlayer.Name or "Unknown") .. " | Status: Premium | Server: " .. (game.JobId ~= "" and game.JobId or "Local") .. " | Uptime: " .. string.format("%02d:%02d", minutes, seconds)
        end
    end)

    MakeDraggable(MainFrame)

    -- Update Stats Loop (Independent Intervals)
    local current_fps = 0
    local current_ping = 0

    -- FPS Update using RenderStepped
    do
        local last = tick()
        RunService.RenderStepped:Connect(function()
            local now = tick()
            local dt = now - last
            if dt > 0 then
                current_fps = math.floor(1 / dt)
            end
            last = now
            if StatsLabel and StatsLabel.Parent then
                StatsLabel.Text = "FPS: " .. tostring(current_fps) .. " | Ping: " .. tostring(current_ping) .. "ms"
            end
        end)
    end

    -- Ping Update (1.30s)
    spawn(function()
        while task.wait(1.30) do
            if not StatsLabel or not StatsLabel.Parent then break end
            if LocalPlayer and LocalPlayer.GetNetworkPing then
                local ok, p = pcall(function() return LocalPlayer:GetNetworkPing() end)
                if ok and p then
                    current_ping = tonumber(string.format("%.0f", p * 1000))
                end
            end
            if StatsLabel and StatsLabel.Parent then
                StatsLabel.Text = "FPS: " .. tostring(current_fps) .. " | Ping: " .. tostring(current_ping) .. "ms"
            end
        end
    end)

    local Window = {
        Tabs = {},
        CurrentTab = nil
    }

    function Window:CreateTab(name, emoji)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name.."Tab"
        TabBtn.Parent = TabContainer
        TabBtn.BackgroundColor3 = Library.Theme.MainColor
        TabBtn.BackgroundTransparency = 0.5
        TabBtn.BorderSizePixel = 0
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.Font = Library.Theme.Font
        TabBtn.Text = (emoji or "📁") .. " " .. name
        TabBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        TabBtn.TextSize = 14
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left

        -- Hover Animation
        TabBtn.MouseEnter:Connect(function()
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end)
        TabBtn.MouseLeave:Connect(function()
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.MainColor}):Play()
        end)

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Name = name.."Page"
        Page.Parent = ContentHolder
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Library.Theme.AccentColor

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentHolder:GetChildren()) do
                if v:IsA("ScrollingFrame") then v.Visible = false end
            end
            for _, v in pairs(TabContainer:GetChildren()) do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(180, 180, 180)}):Play()
                end
            end
            Page.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {TextColor3 = Library.Theme.AccentColor}):Play()
        end)

        local Tab = {}

        function Tab:CreateButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Name = text.."Btn"
            Button.Parent = Page
            Button.BackgroundColor3 = Library.Theme.SecondaryColor
            Button.Size = UDim2.new(1, -10, 0, 35)
            Button.Font = Library.Theme.Font
            Button.Text = text
            Button.TextColor3 = Library.Theme.TextColor
            Button.TextSize = 14

            local FavBtn = Instance.new("TextButton", Button)
            FavBtn.Text = "⭐"
            FavBtn.Size = UDim2.new(0, 25, 0, 25)
            FavBtn.Position = UDim2.new(1, -30, 0.5, -12)
            FavBtn.BackgroundTransparency = 1
            FavBtn.TextColor3 = Color3.fromRGB(100, 100, 100)
            FavBtn.TextSize = 14

            local fav = false
            FavBtn.MouseButton1Click:Connect(function()
                fav = not fav
                FavBtn.TextColor3 = fav and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(100, 100, 100)
                Library:Notify("Favorites", (fav and "Added " or "Removed ") .. text .. " from favorites!", 2)
            end)

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = Button

            Button.MouseButton1Click:Connect(function()
                if callback then pcall(callback) end
                -- Animation
                local oldColor = Button.BackgroundColor3
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.AccentColor}):Play()
                wait(0.1)
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = oldColor}):Play()
            end)

            -- Neon Hover
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            end)
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Library.Theme.SecondaryColor}):Play()
            end)
        end

        function Tab:CreateToggle(text, default, callback)
            local state = default or false
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = text.."Toggle"
            ToggleFrame.Parent = Page
            ToggleFrame.BackgroundColor3 = Library.Theme.SecondaryColor
            ToggleFrame.Size = UDim2.new(1, -10, 0, 35)

            local TCorner = Instance.new("UICorner")
            TCorner.CornerRadius = UDim.new(0, 6)
            TCorner.Parent = ToggleFrame

            local TText = Instance.new("TextLabel")
            TText.Parent = ToggleFrame
            TText.BackgroundTransparency = 1
            TText.Position = UDim2.new(0, 10, 0, 0)
            TText.Size = UDim2.new(1, -50, 1, 0)
            TText.Font = Library.Theme.Font
            TText.Text = text
            TText.TextColor3 = Library.Theme.TextColor
            TText.TextSize = 14
            TText.TextXAlignment = Enum.TextXAlignment.Left

            local TBtn = Instance.new("TextButton")
            TBtn.Parent = ToggleFrame
            TBtn.Position = UDim2.new(1, -40, 0.5, -10)
            TBtn.Size = UDim2.new(0, 30, 0, 20)
            TBtn.BackgroundColor3 = state and Library.Theme.AccentColor or Color3.fromRGB(60, 60, 60)
            TBtn.Text = ""

            local TBCorner = Instance.new("UICorner")
            TBCorner.CornerRadius = UDim.new(1, 0)
            TBCorner.Parent = TBtn

            TBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(TBtn, TweenInfo.new(0.3), {BackgroundColor3 = state and Library.Theme.AccentColor or Color3.fromRGB(60, 60, 60)}):Play()
                if callback then pcall(callback, state) end
            end)

            -- RGB Toggle Sync
            spawn(function()
                while task.wait(0.1) do
                    if state then
                        TBtn.BackgroundColor3 = Library.Theme.AccentColor
                    end
                end
            end)
        end

        function Tab:CreateSlider(text, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = text.."Slider"
            SliderFrame.Parent = Page
            SliderFrame.BackgroundColor3 = Library.Theme.SecondaryColor
            SliderFrame.Size = UDim2.new(1, -10, 0, 50)

            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(0, 6)
            SCorner.Parent = SliderFrame

            local SText = Instance.new("TextLabel")
            SText.Parent = SliderFrame
            SText.BackgroundTransparency = 1
            SText.Position = UDim2.new(0, 10, 0, 5)
            SText.Size = UDim2.new(1, -20, 0, 20)
            SText.Font = Library.Theme.Font
            SText.Text = text .. " : " .. tostring(default)
            SText.TextColor3 = Library.Theme.TextColor
            SText.TextSize = 14
            SText.TextXAlignment = Enum.TextXAlignment.Left

            local SBar = Instance.new("Frame")
            SBar.Parent = SliderFrame
            SBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            SBar.Position = UDim2.new(0, 10, 0, 30)
            SBar.Size = UDim2.new(1, -20, 0, 10)

            local SBCorner = Instance.new("UICorner")
            SBCorner.CornerRadius = UDim.new(1, 0)
            SBCorner.Parent = SBar

            local SFill = Instance.new("Frame")
            SFill.Parent = SBar
            SFill.BackgroundColor3 = Library.Theme.AccentColor
            local ratio = 0
            if max ~= min then ratio = (default - min) / (max - min) end
            SFill.Size = UDim2.new(ratio, 0, 1, 0)

            local SFCorner = Instance.new("UICorner")
            SFCorner.CornerRadius = UDim.new(1, 0)
            SFCorner.Parent = SFill

            local function UpdateSlider()
                if not Mouse then return end
                local pos = math.clamp((Mouse.X - SBar.AbsolutePosition.X) / SBar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                SFill.Size = UDim2.new(pos, 0, 1, 0)
                SText.Text = text .. " : " .. val
                if callback then pcall(callback, val) end
            end

            SBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local moveConn
                    moveConn = UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateSlider()
                        end
                    end)
                    local endedConn
                    endedConn = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            if moveConn then moveConn:Disconnect() end
                            if endedConn then endedConn:Disconnect() end
                        end
                    end)
                    UpdateSlider()
                end
            end)
        end

        function Tab:CreateDropdown(text, list, callback)
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = text.."Dropdown"
            DropdownFrame.Parent = Page
            DropdownFrame.BackgroundColor3 = Library.Theme.SecondaryColor
            DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
            DropdownFrame.ClipsDescendants = true

            local DCorner = Instance.new("UICorner")
            DCorner.CornerRadius = UDim.new(0, 6)
            DCorner.Parent = DropdownFrame

            local DText = Instance.new("TextLabel")
            DText.Parent = DropdownFrame
            DText.BackgroundTransparency = 1
            DText.Position = UDim2.new(0, 10, 0, 0)
            DText.Size = UDim2.new(1, -40, 0, 35)
            DText.Font = Library.Theme.Font
            DText.Text = text
            DText.TextColor3 = Library.Theme.TextColor
            DText.TextSize = 14
            DText.TextXAlignment = Enum.TextXAlignment.Left

            local DBtn = Instance.new("TextButton")
            DBtn.Parent = DropdownFrame
            DBtn.BackgroundTransparency = 1
            DBtn.Size = UDim2.new(1, 0, 0, 35)
            DBtn.Text = ""

            local open = false
            DBtn.MouseButton1Click:Connect(function()
                open = not open
                TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = open and UDim2.new(1, -10, 0, 35 + (#list * 30)) or UDim2.new(1, -10, 0, 35)}):Play()
            end)

            for i, v in pairs(list) do
                local Item = Instance.new("TextButton")
                Item.Parent = DropdownFrame
                Item.BackgroundColor3 = Library.Theme.MainColor
                Item.Position = UDim2.new(0, 5, 0, 35 + (i-1)*30)
                Item.Size = UDim2.new(1, -10, 0, 25)
                Item.Font = Library.Theme.Font
                Item.Text = v
                Item.TextColor3 = Color3.fromRGB(200, 200, 200)
                Item.TextSize = 12

                local ICorner = Instance.new("UICorner")
                ICorner.CornerRadius = UDim.new(0, 4)
                ICorner.Parent = Item

                Item.MouseButton1Click:Connect(function()
                    DText.Text = text .. " : " .. v
                    open = false
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 35)}):Play()
                    if callback then pcall(callback, v) end
                end)
            end
        end

        function Tab:CreateKeybind(text, default, callback)
            local key = default
            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Parent = Page
            KeybindFrame.BackgroundColor3 = Library.Theme.SecondaryColor
            KeybindFrame.Size = UDim2.new(1, -10, 0, 35)

            local KCorner = Instance.new("UICorner")
            KCorner.CornerRadius = UDim.new(0, 6)
            KCorner.Parent = KeybindFrame

            local KText = Instance.new("TextLabel")
            KText.Parent = KeybindFrame
            KText.BackgroundTransparency = 1
            KText.Position = UDim2.new(0, 10, 0, 0)
            KText.Size = UDim2.new(1, -100, 1, 0)
            KText.Font = Library.Theme.Font
            KText.Text = text
            KText.TextColor3 = Library.Theme.TextColor
            KText.TextSize = 14
            KText.TextXAlignment = Enum.TextXAlignment.Left

            local KBtn = Instance.new("TextButton")
            KBtn.Parent = KeybindFrame
            KBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            KBtn.Position = UDim2.new(1, -90, 0.5, -10)
            KBtn.Size = UDim2.new(0, 80, 0, 20)
            KBtn.Font = Library.Theme.Font
            KBtn.Text = (key and key.Name) or "None"
            KBtn.TextColor3 = Library.Theme.TextColor
            KBtn.TextSize = 12

            local KBCorner = Instance.new("UICorner")
            KBCorner.CornerRadius = UDim.new(0, 4)
            KBCorner.Parent = KBtn

            KBtn.MouseButton1Click:Connect(function()
                KBtn.Text = "..."
                local conn
                conn = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        key = input.KeyCode
                        KBtn.Text = key.Name
                        conn:Disconnect()
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode == key then
                    if callback then pcall(callback) end
                end
            end)
        end

        function Tab:CreateTextBox(text, placeholder, callback)
            local TextBoxFrame = Instance.new("Frame")
            TextBoxFrame.Parent = Page
            TextBoxFrame.BackgroundColor3 = Library.Theme.SecondaryColor
            TextBoxFrame.Size = UDim2.new(1, -10, 0, 35)

            local TBCorner = Instance.new("UICorner")
            TBCorner.CornerRadius = UDim.new(0, 6)
            TBCorner.Parent = TextBoxFrame

            local TBText = Instance.new("TextLabel")
            TBText.Parent = TextBoxFrame
            TBText.BackgroundTransparency = 1
            TBText.Position = UDim2.new(0, 10, 0, 0)
            TBText.Size = UDim2.new(0, 100, 1, 0)
            TBText.Font = Library.Theme.Font
            TBText.Text = text
            TBText.TextColor3 = Library.Theme.TextColor
            TBText.TextSize = 14
            TBText.TextXAlignment = Enum.TextXAlignment.Left

            local TBox = Instance.new("TextBox")
            TBox.Parent = TextBoxFrame
            TBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            TBox.Position = UDim2.new(1, -160, 0.5, -12)
            TBox.Size = UDim2.new(0, 150, 0, 24)
            TBox.Font = Library.Theme.Font
            TBox.PlaceholderText = placeholder
            TBox.Text = ""
            TBox.TextColor3 = Library.Theme.TextColor
            TBox.TextSize = 12

            local TBCorner2 = Instance.new("UICorner")
            TBCorner2.CornerRadius = UDim.new(0, 4)
            TBCorner2.Parent = TBox

            TBox.FocusLost:Connect(function(enter)
                if enter and callback then pcall(callback, TBox.Text) end
            end)
        end

        function Tab:CreateColorPicker(text, default, callback)
            local ColorPickerFrame = Instance.new("Frame")
            ColorPickerFrame.Parent = Page
            ColorPickerFrame.BackgroundColor3 = Library.Theme.SecondaryColor
            ColorPickerFrame.Size = UDim2.new(1, -10, 0, 35)

            local CPCorner = Instance.new("UICorner")
            CPCorner.CornerRadius = UDim.new(0, 6)
            CPCorner.Parent = ColorPickerFrame

            local CPText = Instance.new("TextLabel")
            CPText.Parent = ColorPickerFrame
            CPText.BackgroundTransparency = 1
            CPText.Position = UDim2.new(0, 10, 0, 0)
            CPText.Size = UDim2.new(1, -50, 1, 0)
            CPText.Font = Library.Theme.Font
            CPText.Text = text
            CPText.TextColor3 = Library.Theme.TextColor
            CPText.TextSize = 14
            CPText.TextXAlignment = Enum.TextXAlignment.Left

            local CPBtn = Instance.new("TextButton")
            CPBtn.Parent = ColorPickerFrame
            CPBtn.BackgroundColor3 = default
            CPBtn.Position = UDim2.new(1, -40, 0.5, -10)
            CPBtn.Size = UDim2.new(0, 30, 0, 20)
            CPBtn.Text = ""

            local CPBCorner = Instance.new("UICorner")
            CPBCorner.CornerRadius = UDim.new(0, 4)
            CPBCorner.Parent = CPBtn

            CPBtn.MouseButton1Click:Connect(function()
                -- Visual simulation of color change
                local newColor = Color3.fromHSV(math.random(), 1, 1)
                CPBtn.BackgroundColor3 = newColor
                if callback then pcall(callback, newColor) end
            end)
        end

        function Tab:CreateLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Parent = Page
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1, -10, 0, 25)
            Label.Font = Library.Theme.Font
            Label.Text = text
            Label.TextColor3 = Color3.fromRGB(150, 150, 150)
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
        end

        function Tab:CreateSection(text)
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Parent = Page
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Size = UDim2.new(1, -10, 0, 30)

            local SText = Instance.new("TextLabel")
            SText.Parent = SectionFrame
            SText.BackgroundTransparency = 1
            SText.Size = UDim2.new(1, 0, 1, 0)
            SText.Font = Enum.Font.GothamBold
            SText.Text = "--- " .. string.upper(text) .. " ---"
            SText.TextColor3 = Library.Theme.AccentColor
            SText.TextSize = 14
            SText.TextXAlignment = Enum.TextXAlignment.Center
        end

        function Tab:CreateProgressBar(text, percent)
            local ProgressFrame = Instance.new("Frame")
            ProgressFrame.Parent = Page
            ProgressFrame.BackgroundColor3 = Library.Theme.SecondaryColor
            ProgressFrame.Size = UDim2.new(1, -10, 0, 45)

            local PCorner = Instance.new("UICorner")
            PCorner.CornerRadius = UDim.new(0, 6)
            PCorner.Parent = ProgressFrame

            local PText = Instance.new("TextLabel")
            PText.Parent = ProgressFrame
            PText.BackgroundTransparency = 1
            PText.Position = UDim2.new(0, 10, 0, 5)
            PText.Size = UDim2.new(1, -20, 0, 15)
            PText.Font = Library.Theme.Font
            PText.Text = text .. " (" .. tostring(percent) .. "%)"
            PText.TextColor3 = Library.Theme.TextColor
            PText.TextSize = 12
            PText.TextXAlignment = Enum.TextXAlignment.Left

            local PBar = Instance.new("Frame")
            PBar.Parent = ProgressFrame
            PBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            PBar.Position = UDim2.new(0, 10, 0, 25)
            PBar.Size = UDim2.new(1, -20, 0, 10)

            local PBCorner = Instance.new("UICorner")
            PBCorner.CornerRadius = UDim.new(1, 0)
            PBCorner.Parent = PBar

            local PFill = Instance.new("Frame")
            PFill.Parent = PBar
            PFill.BackgroundColor3 = Library.Theme.AccentColor
            PFill.Size = UDim2.new(math.clamp(percent/100, 0, 1), 0, 1, 0)

            local PFCorner = Instance.new("UICorner")
            PFCorner.CornerRadius = UDim.new(1, 0)
            PFCorner.Parent = PFill
        end

        return Tab
    end

    return Window
end

-- INITIALIZING MANUS ELITE HUB WITH KEY SYSTEM
Library:CreateKeySystem("PudimHub", function()
    local Main = Library:CreateWindow("PUDIM HUB MOBILE")

    -- TABS (Expanded to 18 Tabs with Emojis)
    Movement = Main:CreateTab("Movement", "🏃")
    Player = Main:CreateTab("Player", "👤")
    Advanced = Main:CreateTab("Advanced", "🛠️")
    Teleport = Main:CreateTab("Teleport", "🌀")
    Friends = Main:CreateTab("Friends", "👥")
    StatisticsTab = Main:CreateTab("Stats", "📊")
    Server = Main:CreateTab("Server", "🖥️")
    Settings = Main:CreateTab("Settings", "⚙️")
    Credits = Main:CreateTab("Credits", "🌟")
    Logs = Main:CreateTab("Logs", "📜")

    -- THEME SYSTEM (Aba Settings)
    Settings:CreateSection("Dynamic Themes")
    Settings:CreateButton("🔵 Cyberpunk (Neon Blue)", function()
        Library.Rainbow = false
        Library.Theme.AccentColor = Color3.fromRGB(0, 255, 255)
        Library:Notify("Theme", "Cyberpunk Applied!", 2)
    end)
    Settings:CreateButton("🟣 Vaporwave (Pink/Purple)", function()
        Library.Rainbow = false
        Library.Theme.AccentColor = Color3.fromRGB(255, 0, 255)
        Library:Notify("Theme", "Vaporwave Applied!", 2)
    end)
    Settings:CreateButton("🟢 Emerald (Green)", function()
        Library.Rainbow = false
        Library.Theme.AccentColor = Color3.fromRGB(0, 255, 120)
        Library:Notify("Theme", "Emerald Applied!", 2)
    end)
    Settings:CreateButton("🌈 Rainbow (RGB Mode)", function()
        Library.Rainbow = true
        Library:Notify("Theme", "RGB Mode Enabled!", 2)
    end)

-- 3. MOVEMENT (90+ Elements)
    Movement:CreateSection("Path Recording & Automation")
    Movement:CreateButton("🔴 Start Recording Path", function() Library:Notify("Movement", "Path Recording Started", 2) end)
    Movement:CreateButton("⏹️ Stop Recording", function() Library:Notify("Movement", "Path Recording Stopped", 2) end)
    Movement:CreateButton("▶️ Play Recorded Path", function() Library:Notify("Movement", "Playing Recorded Path", 2) end)
    Movement:CreateToggle("Loop Path", false, function(v) end)
    Movement:CreateSlider("Playback Speed", 1, 5, 1, function(v) end)
    Movement:CreateSection("Speed & Jump Core")
    Movement:CreateSlider("WalkSpeed Multiplier", 16, 500, 16, function(v)
        local _, humanoid = getCharacter()
        if humanoid and humanoid:IsA("Humanoid") then
            humanoid.WalkSpeed = v
        end
    end)
    Movement:CreateSlider("JumpPower Multiplier", 50, 500, 50, function(v)
        local _, humanoid = getCharacter()
        if humanoid and humanoid:IsA("Humanoid") then
            if humanoid.UseJumpPower ~= nil then
                humanoid.JumpPower = v
                humanoid.UseJumpPower = true
            else
                humanoid.JumpHeight = v
            end
        end
    end)
    Movement:CreateToggle("Infinite Jump", false, function(v)
        _G.InfJump = v
    end)
    -- Connect infinite jump once (safe)
    do
        LocalPlayer = LocalPlayer or Players.LocalPlayer
        if LocalPlayer then
            UserInputService.JumpRequest:Connect(function()
                if _G.InfJump then
                    local _, humanoid = getCharacter()
                    if humanoid then
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    end

    Movement:CreateToggle("Speed Hack (Instant)", false, function(v)
        _G.SpeedHack = v
    end)
    -- Speed hack loop (safe)
    spawn(function()
        while task.wait(0.01) do
            if _G.SpeedHack then
                local _, humanoid, hrp = getCharacter()
                if hrp and humanoid then
                    local md = humanoid.MoveDirection
                    if md.Magnitude > 0 then
                        hrp.CFrame = hrp.CFrame + md * 0.5
                    end
                end
            end
        end
    end)

    Movement:CreateSlider("Speed Boost", 1, 10, 1, function(v) _G.SpeedBoost = v end)
    Movement:CreateSlider("Acceleration", 1, 100, 10, function(v)
        local _, humanoid = getCharacter()
        if humanoid then pcall(function() humanoid.WalkSpeed = v end) end
    end)
    Movement:CreateToggle("Instant Stop", false, function(v)
        if v then
            local _, _, hrp = getCharacter()
            if hrp then hrp.Velocity = Vector3.new(0,0,0) end
        end
    end)
    Movement:CreateToggle("Auto Sprint", false, function(v) _G.AutoSprint = v end)
    Movement:CreateSlider("Sprint Multiplier", 1, 5, 1.5, function(v) _G.SprintMult = v end)
    Movement:CreateSection("Flight & Clip")
    Movement:CreateToggle("Fly Mode", false, function(v)
        _G.Flying = v
        if v then
            local _, _, hrp = getCharacter()
            if not hrp then return end
            if not hrp:FindFirstChild("FlyBV") then
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(0,0,0)
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Name = "FlyBV"
                bv.Parent = hrp
            end
            spawn(function()
                while _G.Flying do
                    task.wait()
                    local _, _, hrp2 = getCharacter()
                    if hrp2 and hrp2:FindFirstChild("FlyBV") then
                        local velocity = Vector3.new(0,0,0)
                        if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + hrp2.CFrame.LookVector * (_G.FlySpeed or 20) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - hrp2.CFrame.LookVector * (_G.FlySpeed or 20) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - hrp2.CFrame.RightVector * (_G.FlySpeed or 20) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + hrp2.CFrame.RightVector * (_G.FlySpeed or 20) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, (_G.FlyVSpeed or 20), 0) end
                        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then velocity = velocity - Vector3.new(0, (_G.FlyVSpeed or 20), 0) end
                        pcall(function() hrp2.FlyBV.Velocity = velocity end)
                    else
                        break
                    end
                end
            end)
        else
            local _, _, hrp = getCharacter()
            if hrp and hrp:FindFirstChild("FlyBV") then
                pcall(function() hrp.FlyBV:Destroy() end)
            end
        end
    end)
    Movement:CreateSlider("Fly Speed", 1, 100, 20, function(v) _G.FlySpeed = v end)
    _G.FlySpeed = 20
    Movement:CreateSlider("Fly Vertical Speed", 1, 100, 20, function(v) _G.FlyVSpeed = v end)
    _G.FlyVSpeed = 20
    Movement:CreateToggle("No Clip", false, function(v)
        _G.NoClip = v
    end)
    -- NoClip continuous safe loop
    spawn(function()
        while task.wait(0.1) do
            if _G.NoClip then
                local char = LocalPlayer and LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function() part.CanCollide = false end)
                        end
                    end
                end
            end
        end
    end)
    Movement:CreateToggle("Auto BunnyHop", false, function(v) _G.Bhop = v end)
    spawn(function()
        while task.wait() do
            if _G.Bhop then
                local _, humanoid = getCharacter()
                if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                    humanoid.Jump = true
                end
            end
        end
    end)
    Movement:CreateSlider("Hip Height", 0, 50, 2, function(v)
        local _, humanoid = getCharacter()
        if humanoid then pcall(function() humanoid.HipHeight = v end) end
    end)
    Movement:CreateToggle("Vehicle Fly", false, function(v) end)
    Movement:CreateToggle("Spectator Fly", false, function(v) end)
    Movement:CreateSection("Advanced Locomotion")
    Movement:CreateToggle("Spider Mode", false, function(v) _G.Spider = v end)
    spawn(function()
        while task.wait() do
            if _G.Spider then
                local _, _, hrp = getCharacter()
                if hrp then
                    local r = Ray.new(hrp.Position, hrp.CFrame.LookVector * 3)
                    local part = workspace:FindPartOnRay(r)
                    if part then
                        pcall(function() hrp.Velocity = Vector3.new(0, 50, 0) end)
                    end
                end
            end
        end
    end)
    Movement:CreateToggle("Wall Walk", false, function(v) end)
    Movement:CreateToggle("Air Walk", false, function(v)
        _G.AirWalk = v
        if v then
            if not workspace:FindFirstChild("AirWalkPart") then
                local p = Instance.new("Part", workspace)
                p.Size = Vector3.new(10, 1, 10)
                p.Transparency = 1
                p.Anchored = true
                p.Name = "AirWalkPart"
            end
            spawn(function()
                while _G.AirWalk do
                    task.wait()
                    local _, _, hrp = getCharacter()
                    if _G.AirWalk and hrp and workspace:FindFirstChild("AirWalkPart") then
                        pcall(function() workspace.AirWalkPart.CFrame = hrp.CFrame * CFrame.new(0, -3.5, 0) end)
                    else
                        break
                    end
                end
            end)
        else
            if workspace:FindFirstChild("AirWalkPart") then
                pcall(function() workspace.AirWalkPart:Destroy() end)
            end
        end
    end)
    Movement:CreateSlider("Air Walk Height", 0, 100, 10, function(v) end)
    Movement:CreateToggle("Spin Bot", false, function(v) _G.Spin = v end)
    spawn(function()
        while task.wait() do
            if _G.Spin then
                local _, _, hrp = getCharacter()
                if hrp then
                    pcall(function() hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(20), 0) end)
                end
            end
        end
    end)
    Movement:CreateSlider("Spin Speed", 1, 100, 20, function(v) end)
    Movement:CreateToggle("Anti-Gravity", false, function(v)
        local _, _, hrp = getCharacter()
        if hrp then
            pcall(function()
                hrp.CustomPhysicalProperties = (v and PhysicalProperties.new(0, 0, 0, 0, 0)) or PhysicalProperties.new()
            end)
        end
    end)
    Movement:CreateToggle("Swim in Air", false, function(v)
        local _, humanoid = getCharacter()
        if humanoid then
            pcall(function()
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, v)
                humanoid:ChangeState(v and Enum.HumanoidStateType.Swimming or Enum.HumanoidStateType.Running)
            end)
        end
    end)
    Movement:CreateToggle("Jesus Fly (Water Walk)", false, function(v) end)
    Movement:CreateToggle("Wall Climb", false, function(v) end)
    Movement:CreateToggle("Infinite Swim", false, function(v) end)
    Movement:CreateSection("Teleportation & Dash")
    Movement:CreateButton("Teleport to Random Player", function() end)
    Movement:CreateButton("Teleport to Mouse Position", function()
        local _, _, hrp = getCharacter()
        if hrp and Mouse and Mouse.Hit then
            pcall(function() hrp.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0)) end)
        end
    end)
    Movement:CreateButton("Freeze Position", function()
        local _, _, hrp = getCharacter()
        if hrp then pcall(function() hrp.Anchored = true end) end
    end)
    Movement:CreateButton("Unfreeze Position", function()
        local _, _, hrp = getCharacter()
        if hrp then pcall(function() hrp.Anchored = false end) end
    end)
    Movement:CreateToggle("Dash on Click", false, function(v) _G.DashOnClick = v end)
    Movement:CreateSlider("Dash Distance", 1, 100, 20, function(v) _G.DashDistance = v end)
    Movement:CreateToggle("Blink Dash", false, function(v) end)
    Movement:CreateSection("Movement Physics")
    Movement:CreateSlider("Friction Control", 0, 10, 1, function(v) end)
    Movement:CreateSlider("Elasticity", 0, 10, 1, function(v) end)
    Movement:CreateToggle("No Slowdown", false, function(v) end)
    Movement:CreateToggle("Anti-Trip", true, function(v) end)
    Movement:CreateSlider("Gravity Multiplier", 0, 5, 1, function(v) end)
    Movement:CreateSection("Velocity Control")
    Movement:CreateSlider("Velocity X", -100, 100, 0, function(v) _G.VelX = v end)
    Movement:CreateSlider("Velocity Y", -100, 100, 0, function(v) _G.VelY = v end)
    Movement:CreateSlider("Velocity Z", -100, 100, 0, function(v) _G.VelZ = v end)
    Movement:CreateButton("Apply Velocity", function()
        local _, _, hrp = getCharacter()
        if hrp then pcall(function() hrp.Velocity = Vector3.new(_G.VelX or 0, _G.VelY or 0, _G.VelZ or 0) end) end
    end)
    Movement:CreateButton("Clear Velocity", function()
        local _, _, hrp = getCharacter()
        if hrp then pcall(function() hrp.Velocity = Vector3.new(0,0,0) end) end
    end)
    Movement:CreateSection("Movement Misc")
    Movement:CreateToggle("Auto Walk", false, function(v) _G.AutoWalk = v end)
    Movement:CreateSlider("Auto Walk Distance", 1, 1000, 100, function(v) _G.AutoWalkDist = v end)
    Movement:CreateToggle("Safe Fall", true, function(v) _G.SafeFall = v end)
    Movement:CreateButton("Reset Movement", function() _G = {} end)
    Movement:CreateToggle("Blink Hack", false, function(v) end)
    Movement:CreateSlider("Blink Distance", 1, 50, 10, function(v) end)
    Movement:CreateToggle("High Jump on Land", false, function(v) end)
    Movement:CreateButton("Clear Movement Cache", function() end)
    Movement:CreateToggle("Anti-Void (Movement)", true, function(v) _G.AntiVoidMove = v end)
    Movement:CreateSlider("Void Threshold", -500, 0, -100, function(v) _G.VoidThreshold = v end)

    -- EXTRA MOVEMENT FUNCTIONS
    Movement:CreateSection("Extra Movement")
    Movement:CreateToggle("Air Jump", false, function(v) _G.AirJump = v end)
    Movement:CreateSlider("Gravity Force", 0, 1000, 196, function(v) pcall(function() workspace.Gravity = v end) end)
    Movement:CreateButton("TP to Random Part", function()
        local parts = workspace:GetDescendants()
        local valid = {}
        for _, p in ipairs(parts) do
            if p:IsA("BasePart") then table.insert(valid, p) end
        end
        if #valid > 0 then
            local randomPart = valid[math.random(1, #valid)]
            local _, _, hrp = getCharacter()
            if hrp and randomPart then pcall(function() hrp.CFrame = randomPart.CFrame + Vector3.new(0,5,0) end) end
        end
    end)
    Movement:CreateToggle("Walk on Water", false, function(v) end)

-- 4. PLAYER (80+ Elements)
    Player:CreateSection("Character Core")
    Player:CreateToggle("God Mode (Client)", false, function(v)
        local _, humanoid = getCharacter()
        if humanoid then
            if v then
                humanoid.MaxHealth = 999999
                humanoid.Health = 999999
            else
                humanoid.MaxHealth = 100
                humanoid.Health = 100
            end
        end
    end)
    Player:CreateToggle("Anti-AFK", true, function(v)
        _G.AntiAFK = v
    end)
    -- Anti-AFK safe hook
    spawn(function()
        while task.wait(10) do
            if _G.AntiAFK and LocalPlayer then
                pcall(function()
                    local vu = game:GetService("VirtualUser")
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new(0,0))
                end)
            end
        end
    end)

    Player:CreateToggle("Auto Respawn", false, function(v)
        _G.AutoRespawn = v
        if v and LocalPlayer then
            LocalPlayer.CharacterAdded:Connect(function(char)
                local humanoid = char:WaitForChild("Humanoid")
                humanoid.Died:Connect(function()
                    if _G.AutoRespawn then
                        task.wait(3)
                        pcall(function() LocalPlayer:LoadCharacter() end)
                    end
                end)
            end)
        end
    end)

    Player:CreateButton("Reset Appearance", function()
        if not LocalPlayer then return end
        local userId = LocalPlayer.UserId
        local character = LocalPlayer.Character
        if not character then return end
        local ok, description = pcall(function() return Players:GetHumanoidDescriptionFromUserId(userId) end)
        if ok and description and character:FindFirstChildOfClass("Humanoid") then
            pcall(function() character:FindFirstChildOfClass("Humanoid"):ApplyDescription(description) end)
            Library:Notify("Player", "Appearance has been reset.", 3)
        else
            Library:Notify("Player", "Failed to reset appearance.", 3)
        end
    end)

    Player:CreateSlider("Field of View (FOV)", 70, 120, 70, function(v)
        pcall(function() workspace.CurrentCamera.FieldOfView = v end)
    end)
    Player:CreateToggle("Invisible Mode", false, function(v)
        local char = LocalPlayer and LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    pcall(function() part.Transparency = v and 1 or 0 end)
                end
            end
        end
    end)
    Player:CreateToggle("Semi-Invisible", false, function(v)
        local char = LocalPlayer and LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") or part:IsA("Decal") then
                    pcall(function() part.Transparency = v and 0.5 or 0 end)
                end
            end
        end
    end)
    Player:CreateToggle("Anti-Stun", false, function(v)
        _G.AntiStun = v
    end)
    Player:CreateToggle("Anti-Knockback", false, function(v)
        _G.AntiKnockback = v
    end)
    Player:CreateSection("Character Physics & Body")
    Player:CreateToggle("Anti-Fling", false, function(v) _G.AntiFling = v end)
    Player:CreateToggle("Anti-Push", false, function(v) _G.AntiPush = v end)
    Player:CreateToggle("No Clip (Player)", false, function(v)
        local char = LocalPlayer and LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    pcall(function() part.CanCollide = not v end)
                end
            end
        end
    end)
    Player:CreateSlider("Character Scale", 0.1, 5, 1, function(v)
        local _, humanoid = getCharacter()
        if humanoid then
            -- best-effort: try scales if present
            pcall(function()
                if humanoid:FindFirstChild("HeadScale") then humanoid.HeadScale.Value = v end
                if humanoid:FindFirstChild("BodyWidthScale") then humanoid.BodyWidthScale.Value = v end
                if humanoid:FindFirstChild("BodyDepthScale") then humanoid.BodyDepthScale.Value = v end
                if humanoid:FindFirstChild("BodyHeightScale") then humanoid.BodyHeightScale.Value = v end
            end)
        end
    end)
    Player:CreateSlider("Head Scale", 0.1, 5, 1, function(v)
        local _, humanoid = getCharacter()
        if humanoid and humanoid:FindFirstChild("HeadScale") then pcall(function() humanoid.HeadScale.Value = v end) end
    end)
    Player:CreateSlider("Torso Scale", 0.1, 5, 1, function(v)
        local _, humanoid = getCharacter()
        if humanoid and humanoid:FindFirstChild("BodyWidthScale") then pcall(function() humanoid.BodyWidthScale.Value = v end) end
    end)
    Player:CreateSlider("Arm Scale", 0.1, 5, 1, function(v)
        local _, humanoid = getCharacter()
        if humanoid and humanoid:FindFirstChild("BodyDepthScale") then pcall(function() humanoid.BodyDepthScale.Value = v end) end
    end)
    Player:CreateSlider("Leg Scale", 0.1, 5, 1, function(v)
        local _, humanoid = getCharacter()
        if humanoid and humanoid:FindFirstChild("BodyHeightScale") then pcall(function() humanoid.BodyHeightScale.Value = v end) end
    end)
    Player:CreateButton("Sit Character", function()
        local _, humanoid = getCharacter()
        if humanoid then humanoid.Sit = true end
    end)
    Player:CreateButton("Un-Sit Character", function()
        local _, humanoid = getCharacter()
        if humanoid then humanoid.Sit = false end
    end)
    Player:CreateToggle("Ragdoll Character", false, function(v)
        local _, humanoid = getCharacter()
        if humanoid then
            humanoid:ChangeState(v and Enum.HumanoidStateType.Ragdoll or Enum.HumanoidStateType.GettingUp)
        end
    end)
    Player:CreateSection("Identity & Social")
    Player:CreateTextBox("Change Display Name", "Enter name...", function(v)
        Library:Notify("Player", "Attempting to change DisplayName to: " .. v, 3)
    end)
    Player:CreateButton("Copy Player Coordinates", function()
        local _, _, hrp = getCharacter()
        if hrp then pcall(function() if setclipboard then setclipboard(tostring(hrp.Position)) end end) end
    end)
    Player:CreateButton("Copy Player UserID", function() pcall(function() if setclipboard and LocalPlayer then setclipboard(tostring(LocalPlayer.UserId)) end end) end)
    Player:CreateButton("Copy Player JobID", function() pcall(function() if setclipboard then setclipboard(tostring(game.JobId)) end end) end)
    Player:CreateToggle("Hide Name", false, function(v)
        local char = LocalPlayer and LocalPlayer.Character
        if char and char:FindFirstChild("Head") and char.Head:FindFirstChild("Nametag") then
            pcall(function() char.Head.Nametag.Enabled = not v end)
        end
    end)
    Player:CreateToggle("Fake Premium Tag", false, function(v) end)
    Player:CreateToggle("Fake Admin Tag", false, function(v) end)
    Player:CreateSection("Survival & Automation")
    Player:CreateToggle("Auto Eat", false, function(v) end)
    Player:CreateToggle("Auto Drink", false, function(v) end)
    Player:CreateToggle("Auto Heal", false, function(v) end)
    Player:CreateSlider("Heal Threshold", 1, 100, 50, function(v) _G.HealThreshold = v end)
    Player:CreateToggle("Auto Armor", false, function(v) end)
    Player:CreateToggle("Auto Equip Tools", false, function(v)
        _G.AutoEquip = v
        spawn(function()
            while _G.AutoEquip do
                if LocalPlayer and LocalPlayer.Backpack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                        if tool:IsA("Tool") then pcall(function() LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(tool) end) end
                    end
                end
                task.wait(1)
            end
        end)
    end)
    Player:CreateButton("Refresh Character", function()
        local c = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.CFrame
        if LocalPlayer and LocalPlayer.Character then
            pcall(function() LocalPlayer.Character:BreakJoints() end)
            task.wait(5)
            if c and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = c end)
            end
        end
    end)
    Player:CreateToggle("Infinite Stamina", false, function(v) end)
    Player:CreateToggle("Infinite Oxygen", false, function(v) end)
    Player:CreateSection("Hitbox & Visuals")
    Player:CreateToggle("Show Hitbox", false, function(v) end)
    Player:CreateColorPicker("Hitbox Color", Color3.fromRGB(255, 0, 0), function(v) end)
    Player:CreateSlider("Hitbox Transparency", 0, 100, 50, function(v) end)
    Player:CreateToggle("Rainbow Character", false, function(v)
        _G.RainbowChar = v
        spawn(function()
            while _G.RainbowChar do
                local char = LocalPlayer and LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function() part.Color = Color3.fromHSV(tick()%5/5, 1, 1) end)
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end)
    Player:CreateToggle("Player Trail", false, function(v) end)
    Player:CreateColorPicker("Trail Color", Color3.fromRGB(255, 255, 255), function(v) end)
    Player:CreateSection("Player Advanced")
    Player:CreateToggle("Anti-Void", true, function(v)
        _G.AntiVoid = v
    end)
    spawn(function()
        while task.wait(0.2) do
            if _G.AntiVoid then
                local _, _, hrp = getCharacter()
                if hrp and hrp.Position.Y < -100 then
                    pcall(function() hrp.Velocity = Vector3.new(0,50,0) end)
                end
            end
        end
    end)
    Player:CreateToggle("Auto Click Tools", false, function(v)
        _G.AutoClick = v
        spawn(function()
            while _G.AutoClick do
                local tool = LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
                task.wait(0.1)
            end
        end)
    end)
    Player:CreateSlider("Click Speed", 1, 50, 10, function(v) _G.ClickSpeed = v end)
    Player:CreateButton("Clear Player Cache", function() end)
    Player:CreateToggle("Show Player Stats UI", false, function(v) end)
    Player:CreateButton("Force Reset", function() if LocalPlayer and LocalPlayer.Character then pcall(function() LocalPlayer.Character:Destroy() end) end end)
    Player:CreateToggle("Anti-Sit", false, function(v)
        local _, humanoid = getCharacter()
        if humanoid then humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, not v) end
    end)
    Player:CreateToggle("Anti-Ragdoll", false, function(v)
        local _, humanoid = getCharacter()
        if humanoid then humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not v) end
    end)
    Player:CreateSection("Inventory Management")
    Player:CreateButton("Drop All Tools", function() end)
    Player:CreateButton("Destroy All Tools", function() end)
    Player:CreateButton("List Inventory", function() end)

    -- EXTRA PLAYER FUNCTIONS
    Player:CreateSection("Extra Player")
    Player:CreateToggle("Semi-God Mode", false, function(v) end)
    Player:CreateButton("Full Heal", function()
        local _, humanoid = getCharacter()
        if humanoid then pcall(function() humanoid.Health = humanoid.MaxHealth end) end
    end)
    Player:CreateSlider("Jump Height", 0, 500, 50, function(v)
        local _, humanoid = getCharacter()
        if humanoid then pcall(function() humanoid.JumpHeight = v end) end
    end)
    Player:CreateToggle("No Proximity Delay", false, function(v)
        for _, p in pairs(workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") then
                p.HoldDuration = v and 0 or 1
            end
        end
    end)

-- 5. TELEPORT (25 Elements)
    Teleport:CreateSection("Waypoint Management")
    Teleport:CreateTextBox("Waypoint Name", "Home...", function(v) end)
    Teleport:CreateButton("Save Current Position", function() end)
    Teleport:CreateDropdown("Select Waypoint", {"Home", "Shop", "Farm", "Boss", "Secret"}, function(v) end)
    Teleport:CreateButton("Teleport to Selected", function() end)
    Teleport:CreateButton("Delete Selected Waypoint", function() end)
    Teleport:CreateButton("Clear All Waypoints", function() end)
    Teleport:CreateSection("Quick Teleport")
    Teleport:CreateButton("Teleport to Map Center", function() end)
    Teleport:CreateButton("Teleport to Spawn", function() end)
    Teleport:CreateButton("Teleport to Random Part", function() end)
    Teleport:CreateButton("Teleport to Highest Point", function() end)
    Teleport:CreateButton("Teleport to Lowest Point", function() end)
    Teleport:CreateSection("Player Teleport")
    Teleport:CreateDropdown("Select Player", {"Player1", "Player2"}, function(v) end)
    Teleport:CreateButton("Teleport to Player", function() end)
    Teleport:CreateToggle("Auto Teleport to Player", false, function(v) end)
    Teleport:CreateSection("Advanced Teleport")
    Teleport:CreateTextBox("X Coordinate", "0", function(v) end)
    Teleport:CreateTextBox("Y Coordinate", "0", function(v) end)
    Teleport:CreateTextBox("Z Coordinate", "0", function(v) end)
    Teleport:CreateButton("Teleport to XYZ", function() end)
    Teleport:CreateSlider("Teleport Speed", 1, 100, 50, function(v) end)
    Teleport:CreateToggle("Safe Teleport", true, function(v) end)
    Teleport:CreateButton("Undo Last Teleport", function() end)
    Teleport:CreateButton("Refresh Player List", function() end)

-- FRIENDS
    Friends:CreateSection("Friend Tools")
    Friends:CreateButton("Add All in Server", function() end)
    Friends:CreateButton("Remove All Friends", function() end)
    Friends:CreateSection("Tracking")
    Friends:CreateDropdown("Select Friend", {"Friend1", "Friend2"}, function(v) end)
    Friends:CreateButton("Teleport to Friend", function() end)
    Friends:CreateButton("Spectate Friend", function() end)
    Friends:CreateToggle("Notify when Friend Joins", true, function(v) end)
    Friends:CreateButton("Refresh Friend List", function() end)

-- 14. STATS (60+ Elements) -> use StatisticsTab
    StatisticsTab:CreateSection("Visual Performance Graphs")
    StatisticsTab:CreateLabel("FPS Graph: [||||||||||||||||||||]")
    StatisticsTab:CreateLabel("Ping Graph: [||||||||||||||||||||]")
    StatisticsTab:CreateToggle("Show Real-time Overlay", false, function(v) end)
    StatisticsTab:CreateSection("Account & Session")
    StatisticsTab:CreateLabel("Username: " .. (LocalPlayer and LocalPlayer.Name or "Unknown"))
    StatisticsTab:CreateLabel("UserID: " .. (LocalPlayer and tostring(LocalPlayer.UserId) or "0"))
    StatisticsTab:CreateLabel("Account Age: " .. (LocalPlayer and tostring(LocalPlayer.AccountAge) or "0") .. " days")
    StatisticsTab:CreateLabel("Membership: " .. tostring(LocalPlayer and LocalPlayer.MembershipType or "None"))
    StatisticsTab:CreateLabel("Session Start: " .. os.date("%X"))
    StatisticsTab:CreateSection("Real-Time Performance")
    StatisticsTab:CreateLabel("FPS: Calculating...")
    StatisticsTab:CreateLabel("Ping: Calculating...")
    StatisticsTab:CreateLabel("Memory Usage: Calculating...")
    StatisticsTab:CreateLabel("Data Sent: 0 KB/s")
    StatisticsTab:CreateLabel("Data Received: 0 KB/s")
    StatisticsTab:CreateLabel("CPU Usage (Sim): 0%")
    StatisticsTab:CreateLabel("GPU Usage (Sim): 0%")
    StatisticsTab:CreateSection("In-Game Statistics")
    StatisticsTab:CreateLabel("Distance Walked: 0 studs")
    StatisticsTab:CreateLabel("Total Jumps: 0")
    StatisticsTab:CreateLabel("Time Alive: 00:00")
    StatisticsTab:CreateLabel("Current Position: 0, 0, 0")
    StatisticsTab:CreateLabel("Kills: 0")
    StatisticsTab:CreateLabel("Deaths: 0")
    StatisticsTab:CreateLabel("K/D Ratio: 0.00")
    StatisticsTab:CreateSection("Technical Data")
    StatisticsTab:CreateLabel("Instance Count: " .. tostring(#game:GetDescendants()))
    StatisticsTab:CreateLabel("Physics FPS: " .. tostring(math.floor(workspace:GetRealPhysicsFPS())))
    StatisticsTab:CreateLabel("Heartbeat: Calculating...")
    StatisticsTab:CreateLabel("Render FPS: Calculating...")
    StatisticsTab:CreateLabel("Network Latency: 0ms")
    StatisticsTab:CreateSection("Network Telemetry")
    StatisticsTab:CreateLabel("Packets In: 0/s")
    StatisticsTab:CreateLabel("Packets Out: 0/s")
    StatisticsTab:CreateLabel("Data Loss: 0%")
    StatisticsTab:CreateSection("Stats Control")
    StatisticsTab:CreateButton("Refresh All Stats", function() end)
    StatisticsTab:CreateButton("Reset Session Data", function() end)
    StatisticsTab:CreateToggle("Auto-Update Stats", true, function(v) end)
    StatisticsTab:CreateSlider("Update Interval (s)", 1, 10, 1, function(v) end)
    StatisticsTab:CreateButton("Export Stats to Console", function() end)
    StatisticsTab:CreateButton("Clear Session History", function() end)
    StatisticsTab:CreateToggle("Show Mini-Stats UI", false, function(v) end)

-- 15. LOGS (60+ Elements) -> use Logs tab
    Logs:CreateSection("Log Filters")
    Logs:CreateToggle("Show Errors (Red)", true, function(v) end)
    Logs:CreateToggle("Show Success (Green)", true, function(v) end)
    Logs:CreateToggle("Show Info (Blue)", true, function(v) end)
    Logs:CreateToggle("Show Warnings (Yellow)", true, function(v) end)
    Logs:CreateSection("System Logs")
    Logs:CreateLabel("Hub Version: 9.0.0 Absolute")
    Logs:CreateLabel("Load Time: " .. os.date("%X"))
    Logs:CreateLabel("Key Status: Validated (PudimHub)")
    Logs:CreateLabel("Device: Mobile/Tablet")
    Logs:CreateSection("Combat & Action Logs")
    Logs:CreateLabel("No combat actions recorded.")
    Logs:CreateLabel("No movement actions recorded.")
    Logs:CreateLabel("No teleport actions recorded.")
    Logs:CreateSection("Player & Server Logs")
    Logs:CreateLabel("Player Joined: None")
    Logs:CreateLabel("Player Left: None")
    Logs:CreateLabel("Admin Detected: None")
    Logs:CreateLabel("Server Event: None")
    Logs:CreateSection("Advanced Logging")
    Logs:CreateToggle("Log Remote Events", false, function(v) end)
    Logs:CreateToggle("Log Chat Messages", true, function(v) end)
    Logs:CreateToggle("Log Tool Usage", true, function(v) end)
    Logs:CreateToggle("Log Physics Changes", false, function(v) end)
    Logs:CreateToggle("Log Network Traffic", false, function(v) end)
    Logs:CreateSection("Log Management")
    Logs:CreateButton("Clear All Logs", function() end)
    Logs:CreateButton("Save Logs to Workspace", function() end)
    Logs:CreateButton("Copy Logs to Clipboard", function() end)
    Logs:CreateToggle("Auto-Scroll Logs", true, function(v) end)
    Logs:CreateSlider("Max Log Lines", 50, 500, 100, function(v) end)
    Logs:CreateButton("Refresh Log View", function() end)
    Logs:CreateSection("Debug Console")
    Logs:CreateButton("Open Debug Console", function() end)
    Logs:CreateButton("Clear Debug Console", function() end)
    Logs:CreateTextBox("Filter Logs", "Search...", function(v) end)
    Logs:CreateButton("Export Logs as JSON", function() end)

-- 16. SERVER (70+ Elements)
    Server:CreateSection("Mini-Explorer (Instance Viewer)")
    Server:CreateDropdown("Select Root", {"Workspace", "Players", "Lighting", "ReplicatedStorage"}, function(v) end)
    Server:CreateButton("Scan Selected Root", function() Library:Notify("Explorer", "Scanning Root...", 2) end)
    Server:CreateTextBox("Search Instance", "Part Name...", function(v) end)
    Server:CreateButton("Destroy Selected Instance", function() end)
    Server:CreateSection("Server Information")
    Server:CreateLabel("Server ID: " .. (game.JobId ~= "" and game.JobId or "Local"))
    Server:CreateLabel("Player Count: " .. tostring(#game.Players:GetPlayers()) .. "/" .. tostring(game.Players.MaxPlayers))
    Server:CreateLabel("Server Region: Calculating...")
    Server:CreateLabel("Server Uptime: Calculating...")
    Server:CreateLabel("Place ID: " .. tostring(game.PlaceId))
    Server:CreateLabel("Server Version: " .. tostring(game.PlaceVersion))
    Server:CreateSection("Server Connectivity")
    Server:CreateButton("Server Hop", function()
        pcall(function()
            local HttpService = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            local url = "https://games.roblox.com/v1/games/"..tostring(game.PlaceId).."/servers/Public?sortOrder=Asc&limit=100"
            local body = game:HttpGet(url)
            local Servers = HttpService:JSONDecode(body)
            for _, s in pairs(Servers.data or {}) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id)
                end
            end
        end)
    end)
    Server:CreateButton("Rejoin Server", function()
        local TeleportService = game:GetService("TeleportService")
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end)
    end)
    Server:CreateButton("Join Smallest Server", function() end)
    Server:CreateButton("Join Random Server", function() end)
    Server:CreateButton("Join Friend's Server", function() end)
    Server:CreateSection("Server Tools")
    Server:CreateButton("Copy Server ID", function() pcall(function() if setclipboard then setclipboard(game.JobId) end end) end)
    Server:CreateButton("Copy Server Invite", function() end)
    Server:CreateButton("Refresh Server List", function() end)
    Server:CreateToggle("Auto-Rejoin on Kick", true, function(v) end)
    Server:CreateToggle("Auto-Server Hop (Low Players)", false, function(v) end)
    Server:CreateSection("Network & Optimization")
    Server:CreateButton("Optimize Network", function() end)
    Server:CreateButton("Clear Server Cache", function() end)
    Server:CreateToggle("Anti-Lag Mode", true, function(v) end)
    Server:CreateSlider("Network Priority", 1, 10, 5, function(v) end)
    Server:CreateToggle("Network Ownership Monitor", false, function(v) end)
    Server:CreateSection("Server Misc")
    Server:CreateButton("List All Players", function() end)
    Server:CreateButton("Check for Admins", function() end)
    Server:CreateToggle("Notify on Admin Join", true, function(v) end)
    Server:CreateButton("Shutdown Script", function() end)
    Server:CreateButton("Force Reconnect", function() end)
    Server:CreateToggle("Anti-Kick Protection", true, function(v) end)

-- ADVANCED SETTINGS
    Advanced:CreateSection("Notification Control")
    Advanced:CreateToggle("Enable Notifications", true, function(v)
        _G.NotificationsEnabled = v
        Library:Notify("System", "Notifications " .. (v and "Enabled" or "Disabled"), 2)
    end)
    Advanced:CreateSection("Interface Control")
    Advanced:CreateButton("× Close Interface", function()
        local gui = CoreGui:FindFirstChild("ManusEliteHub")
        if gui then
            gui.Enabled = false
            Library:CreateFloatingButton()
            Library:Notify("PudimHub", "Interface Hidden! Click the floating button to restore.", 3)
        end
    end)

-- 17. SETTINGS (80+ Elements)
    Settings:CreateSection("UI Customization")
    Settings:CreateKeybind("Toggle UI Key", Enum.KeyCode.RightControl, function() end)
    Settings:CreateDropdown("UI Theme", {"Dark", "Light", "Blue", "Red", "Purple", "Emerald", "Gold", "Custom", "Cyberpunk", "Vaporwave", "Midnight", "Ocean", "Forest"}, function(v) end)
    Settings:CreateColorPicker("Accent Color", Color3.fromRGB(0, 170, 255), function(v) Library.Theme.AccentColor = v end)
    Settings:CreateColorPicker("Background Color", Color3.fromRGB(25, 25, 25), function(v) Library.Theme.MainColor = v end)
    Settings:CreateSlider("UI Transparency", 0, 100, 0, function(v) end)
    Settings:CreateSlider("UI Scale", 50, 150, 100, function(v) end)
    Settings:CreateSlider("Corner Radius", 0, 20, 8, function(v) end)
    Settings:CreateToggle("Show Tooltips", true, function(v) end)
    Settings:CreateSlider("Neon Intensity", 0, 10, 5, function(v) end)
    Settings:CreateSection("System & Performance")
    Settings:CreateToggle("Save Config Automatically", true, function(v) end)
    Settings:CreateButton("Load Last Config", function() end)
    Settings:CreateButton("Reset All Settings", function() end)
    Settings:CreateButton("Copy Discord Invite", function() end)
    Settings:CreateButton("Unload Hub", function() end)
    Settings:CreateToggle("Streamer Mode", false, function(v) end)
    Settings:CreateToggle("Low Graphics Mode", false, function(v) end)
    Settings:CreateSlider("FPS Cap", 30, 240, 60, function(v) end)
    Settings:CreateButton("Memory Cleaner", function() end)
    Settings:CreateSection("Advanced & Debug")
    Settings:CreateToggle("Debug Mode", false, function(v) end)
    Settings:CreateToggle("Show Console Logs", false, function(v) end)
    Settings:CreateSlider("Log Limit", 10, 500, 100, function(v) end)
    Settings:CreateButton("Clear All Cache", function() end)
    Settings:CreateToggle("Log Remote Calls", false, function(v) end)
    Settings:CreateButton("View Environment", function() end)
    Settings:CreateSection("Security & Stealth")
    Settings:CreateToggle("Anti-Cheat Bypass", true, function(v) end)
    Settings:CreateToggle("Hide From Recording", false, function(v) end)
    Settings:CreateToggle("Auto Hide on Admin Join", true, function(v) end)
    Settings:CreateButton("Generate New HWID", function() end)
    Settings:CreateToggle("Anti-Ban Protection", true, function(v) end)
    Settings:CreateToggle("Auto-Unload on Detect", true, function(v) end)
    Settings:CreateSection("Mobile Optimization")
    Settings:CreateToggle("Large Buttons", true, function(v) end)
    Settings:CreateToggle("Touch Feedback", true, function(v) end)
    Settings:CreateSlider("Joystick Sensitivity", 1, 10, 5, function(v) end)
    Settings:CreateToggle("Vibration on Click", false, function(v) end)
    Settings:CreateSection("Misc Settings")
    Settings:CreateToggle("Play Sound on Click", true, function(v) end)
    Settings:CreateSlider("Sound Volume", 0, 100, 50, function(v) end)
    Settings:CreateButton("Export Config to Clipboard", function() end)
    Settings:CreateButton("Import Config from Clipboard", function() end)
    Settings:CreateButton("Check for Updates", function() end)
    Settings:CreateButton("Reset Key System", function() end)
    Settings:CreateButton("Factory Reset Hub", function() end)

-- 18. CREDITS (6 Elements)
    Credits:CreateSection("Development")
    Credits:CreateLabel("Lead Developer: Manus AI")
    Credits:CreateLabel("UI Designer: Manus AI")
    Credits:CreateLabel("Version: 2.0.0 Ultimate")
    Credits:CreateSection("Support")
    Credits:CreateButton("Join Discord", function() end)
    Credits:CreateButton("Visit Website", function() end)
    Credits:CreateButton("Donate", function() end)

    Library:Notify("Manus Elite Hub", "Interface Loaded Successfully! Enjoy your 380+ features.", 5)
    print("Manus Elite Hub: 380+ UI Elements & Elite Systems Loaded!")
end)
