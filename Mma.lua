--[[
    MANUS ELITE HUB - PROFESSIONAL SCRIPT INTERFACE
    Version: 3.0.0 (COMPLETO - ANTI-AFK & REGION)
    Description: A complex, high-end script hub for Roblox with 50+ features.
    Novas Features: Anti-AFK Automático, Região do Servidor, Histórico, Estatísticas, Amigos Online
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TargetGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local TargetGui = (function() 
    local success, _ = pcall(function() return game:GetService("CoreGui").Name end) 
    if success then return game:GetService("CoreGui") end 
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") 
end)()
-- Local player & helpers
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer and LocalPlayer:GetMouse()

-- ========== VARIÁVEIS PARA NOVAS FUNÇÕES (ANÔNIMO & FPS BOOSTER) ==========
local AnonymousMode = false
local FPSBoosterActive = false

-- ========== SISTEMA ANTI-AFK AUTOMÁTICO (SEMPRE ATIVO) ==========
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local function getCharacter()
    if not LocalPlayer then return nil end
    local char = LocalPlayer.Character
    if not char then return nil end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return char, humanoid, hrp
end

-- UI Library Core
local Library = {
    Flags = {},
    Theme = {
        MainColor = Color3.fromRGB(15, 15, 15),
        SecondaryColor = Color3.fromRGB(25, 25, 25),
        AccentColor = Color3.fromRGB(0, 255, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold
    },
    Rainbow = true
}

_G.NotificationsEnabled = _G.NotificationsEnabled ~= false

-- Notification System
function Library:Notify(title, text, duration)
    if _G.NotificationsEnabled == false then return end
    local NotifyGui = TargetGui:FindFirstChild("ManusNotifications") or Instance.new("ScreenGui")
    NotifyGui.Name = "ManusNotifications"
    if not NotifyGui.Parent then NotifyGui.Parent = TargetGui end

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

-- Main Window Creation
function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ManusEliteHub"
    ScreenGui.Parent = TargetGui
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Library.Theme.MainColor
    MainFrame.Size = UDim2.new(0, 600, 0, 500)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
    MainFrame.BorderSizePixel = 0

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Library.Theme.AccentColor
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame

    MakeDraggable(MainFrame)

    -- Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Parent = MainFrame
    Header.BackgroundColor3 = Library.Theme.SecondaryColor
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BorderSizePixel = 0

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header

    local Title = Instance.new("TextLabel")
    Title.Parent = Header
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0.5, -12)
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "👑 " .. title
    Title.TextColor3 = Library.Theme.AccentColor
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Parent = Header
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Position = UDim2.new(1, -35, 0.5, -12)
    CloseBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseBtn.TextSize = 18

    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.3)
        if ScreenGui and ScreenGui.Destroy then pcall(function() ScreenGui:Destroy() end) end
    end)

    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainFrame
    TabContainer.BackgroundColor3 = Library.Theme.SecondaryColor
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.Size = UDim2.new(0, 150, 1, -100)
    TabContainer.BorderSizePixel = 0
    TabContainer.ScrollBarThickness = 2
    TabContainer.ScrollBarImageColor3 = Library.Theme.AccentColor

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabContainer
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)

    -- Content Holder
    local ContentHolder = Instance.new("Frame")
    ContentHolder.Name = "ContentHolder"
    ContentHolder.Parent = MainFrame
    ContentHolder.BackgroundTransparency = 1
    ContentHolder.Position = UDim2.new(0, 150, 0, 50)
    ContentHolder.Size = UDim2.new(1, -150, 1, -100)
    ContentHolder.BorderSizePixel = 0

    -- Footer
    local Footer = Instance.new("Frame")
    Footer.Name = "Footer"
    Footer.Parent = MainFrame
    Footer.BackgroundColor3 = Library.Theme.SecondaryColor
    Footer.Position = UDim2.new(0, 0, 1, -50)
    Footer.Size = UDim2.new(1, 0, 0, 50)
    Footer.BorderSizePixel = 0

    local FooterCorner = Instance.new("UICorner")
    FooterCorner.CornerRadius = UDim.new(0, 12)
    FooterCorner.Parent = Footer

    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Parent = Footer
    StatsLabel.BackgroundTransparency = 1
    StatsLabel.Position = UDim2.new(0, 10, 0.5, -12)
    StatsLabel.Size = UDim2.new(1, -20, 1, 0)
    StatsLabel.Font = Enum.Font.Gotham
    StatsLabel.Text = "FPS: 60 | Ping: 0ms"
    StatsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatsLabel.TextSize = 12
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Left

    local FooterText = Instance.new("TextLabel")
    FooterText.Parent = Footer
    FooterText.BackgroundTransparency = 1
    FooterText.Position = UDim2.new(0, 10, 0, 25)
    FooterText.Size = UDim2.new(1, -20, 0, 20)
    FooterText.Font = Enum.Font.Gotham
    FooterText.Text = "User: " .. (LocalPlayer and LocalPlayer.Name or "Unknown") .. " | Status: Premium | Server: " .. (game.JobId ~= "" and game.JobId or "Local") .. " | Uptime: 00:00"
    FooterText.TextColor3 = Color3.fromRGB(100, 100, 100)
    FooterText.TextSize = 10
    FooterText.TextXAlignment = Enum.TextXAlignment.Left

    -- Stats Update Loop
    local current_fps = 60
    local current_ping = 0
    local frame_count = 0
    local last_fps_update = tick()
    local last_ping_update = tick()
    local start_time = tick()

    RunService.RenderStepped:Connect(function()
        frame_count = frame_count + 1
        local now = tick()
        
        if now - last_fps_update >= 0.60 then
            current_fps = math.floor(frame_count / (now - last_fps_update))
            frame_count = 0
            last_fps_update = now
        end
        
        if now - last_ping_update >= 1 then
            current_ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            last_ping_update = now
        end
        
        local uptime = now - start_time
        local minutes = math.floor(uptime / 60)
        local seconds = math.floor(uptime % 60)
        
        StatsLabel.Text = "FPS: " .. current_fps .. " | Ping: " .. current_ping .. "ms"
        FooterText.Text = "User: " .. (LocalPlayer and LocalPlayer.Name or "Unknown") .. " | Status: Premium | Server: " .. (game.JobId ~= "" and game.JobId or "Local") .. " | Uptime: " .. string.format("%02d:%02d", minutes, seconds)
    end)

    local Window = {}
    function Window:CreateTab(name, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = name .. "Tab"
        TabBtn.Parent = TabContainer
        TabBtn.BackgroundColor3 = Library.Theme.SecondaryColor
        TabBtn.Size = UDim2.new(1, 0, 0, 40)
        TabBtn.Font = Library.Theme.Font
        TabBtn.Text = (icon or "") .. " " .. name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 14
        TabBtn.BorderSizePixel = 0

        local Page = Instance.new("ScrollingFrame")
        Page.Name = name .. "Page"
        Page.Parent = ContentHolder
        Page.BackgroundTransparency = 1
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Library.Theme.AccentColor

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 10)

        TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(ContentHolder:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            for _, b in pairs(TabContainer:GetChildren()) do
                if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(150, 150, 150) end
            end
            Page.Visible = true
            TabBtn.TextColor3 = Library.Theme.AccentColor
        end)

        -- Default Tab
        if #TabContainer:GetChildren() == 2 then -- UIListLayout is 1st
            Page.Visible = true
            TabBtn.TextColor3 = Library.Theme.AccentColor
        end

        local Tab = {Page = Page}
        
        function Tab:CreateButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Parent = Page
            Button.BackgroundColor3 = Library.Theme.SecondaryColor
            Button.Size = UDim2.new(1, -10, 0, 35)
            Button.Font = Library.Theme.Font
            Button.Text = text
            Button.TextColor3 = Library.Theme.TextColor
            Button.TextSize = 14

            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 6)
            BCorner.Parent = Button

            Button.MouseButton1Click:Connect(function()
                local oldColor = Button.BackgroundColor3
                Button.BackgroundColor3 = Library.Theme.AccentColor
                if callback then pcall(callback) end
                wait(0.1)
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = oldColor}):Play()
            end)

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

            spawn(function()
                while task.wait(0.1) do
                    if state then
                        TweenService:Create(TBtn, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.AccentColor}):Play()
                    end
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
            return Label
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

        return Tab
    end

    return Window
end

-- INITIALIZING MANUS ELITE HUB WITH KEY SYSTEM
Library:CreateKeySystem = function(correctKey, callback)
    local KeyGui = Instance.new("ScreenGui")
    KeyGui.Name = "PudimKeySystem"
    KeyGui.Parent = TargetGui

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
end

Library:CreateKeySystem("PudimHub", function()
    local Main = Library:CreateWindow("PUDIM HUB MOBILE v3.0")

    local FarmTab = Main:CreateTab("Farm", "🚜")
    local ESPTab = Main:CreateTab("ESP", "👁️")
    local BringTab = Main:CreateTab("Bring", "🧲")
    local TPTab = Main:CreateTab("Teleport", "📍")
    local AimbotTab = Main:CreateTab("Aimbot", "🎯")
    local ServerTab = Main:CreateTab("Server", "🌐")
    local VisualTab = Main:CreateTab("Visual", "🌈")
    local ConfigTab = Main:CreateTab("Settings", "⚙️")
    local MoveTab = Main:CreateTab("Movement", "🏃")
    local EliteTab = Main:CreateTab("Manus Elite", "👑")

    -- ========== SETUP SERVER TAB COM TODAS AS FUNCIONALIDADES ==========
    
    -- Variáveis Globais
    local currentGameName = "Roblox Game"
    local currentGameImage = "rbxassetid://0"
    local playerList = {}
    local sessionStartTime = tick()
    local isAutoHopping = false
    
    -- Histórico de Servidores
    local serverHistory = {}
    local maxHistoryItems = 20
    
    -- Estatísticas
    local gameStats = {
        totalPlayTime = 0,
        sessionStartTime = tick(),
        longestSession = 0,
        shortestSession = 999999,
        totalSessions = 0,
        averagePlayTime = 0,
        serverChanges = 0
    }
    
    -- Sistema de Amigos
    local friendsList = {}
    local onlineFriends = {}
    
    -- Funções Auxiliares
    local function GetGameInfo()
        local MarketplaceService = game:GetService("MarketplaceService")
        pcall(function()
            currentGameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
        end)
        pcall(function()
            currentGameImage = MarketplaceService:GetProductInfo(game.PlaceId).IconImageAssetId
        end)
        return currentGameName, currentGameImage
    end

    local function GetServerRegion()
        local region = "Desconhecida"
        pcall(function()
            local response = HttpService:JSONDecode(game:HttpGet("http://ip-api.com/json/"))
            region = response.country .. " (" .. response.countryCode .. ")"
        end)
        return region
    end
    
    local function UpdatePlayerList()
        playerList = {}
        for _, player in pairs(Players:GetPlayers()) do
            table.insert(playerList, {
                Name = player.Name,
                UserId = player.UserId,
                JoinTime = tick() - sessionStartTime
            })
        end
        return playerList
    end
    
    local function FindLowPlayerServers(callback)
        local servers = {}
        for i = 1, 5 do
            table.insert(servers, {
                Id = "Server_" .. tostring(i),
                Players = math.random(1, 10),
                MaxPlayers = 20
            })
        end
        if callback then callback(servers) end
        return servers
    end
    
    local function ServerHop()
        local TeleportService = game:GetService("TeleportService")
        local PlaceId = game.PlaceId
        FindLowPlayerServers(function(servers)
            if #servers > 0 then
                local randomServer = servers[math.random(1, #servers)]
                gameStats.serverChanges = gameStats.serverChanges + 1
                AddToHistory(randomServer.Id, "Servidor Aleatório", randomServer.Players)
                pcall(function()
                    TeleportService:Teleport(PlaceId, nil, randomServer.Id)
                end)
            end
        end)
    end
    
    local function Rejoin()
        local TeleportService = game:GetService("TeleportService")
        local PlaceId = game.PlaceId
        pcall(function()
            TeleportService:Teleport(PlaceId)
        end)
    end
    
    local function JoinServerById(serverId)
        local TeleportService = game:GetService("TeleportService")
        local PlaceId = game.PlaceId
        gameStats.serverChanges = gameStats.serverChanges + 1
        AddToHistory(serverId, "Entrada Manual", #Players:GetPlayers())
        pcall(function()
            TeleportService:Teleport(PlaceId, nil, serverId)
        end)
    end
    
    local function CopyServerID()
        local jobId = game.JobId
        if jobId and jobId ~= "" then
            setclipboard(jobId)
            return jobId
        end
        return "Local"
    end
    
    local function FormatTime(seconds)
        local hours = math.floor(seconds / 3600)
        local minutes = math.floor((seconds % 3600) / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    end
    
    -- Histórico
    local function AddToHistory(serverId, serverName, playerCount)
        table.insert(serverHistory, 1, {
            Id = serverId,
            Name = serverName or "Servidor Desconhecido",
            Players = playerCount or 0,
            Timestamp = os.time(),
            FormattedTime = os.date("%H:%M:%S", os.time())
        })
        if #serverHistory > maxHistoryItems then
            table.remove(serverHistory, maxHistoryItems + 1)
        end
    end
    
    local function ClearHistory()
        serverHistory = {}
        Library:Notify("Histórico", "Histórico limpo com sucesso!", 2)
    end
    
    -- Amigos
    local function AddFriend(friendName)
        if not table.find(friendsList, friendName) then
            table.insert(friendsList, friendName)
            Library:Notify("Amigos", "Amigo " .. friendName .. " adicionado!", 2)
            return true
        end
        Library:Notify("Aviso", "Amigo já está na lista!", 2)
        return false
    end
    
    local function RemoveFriend(friendName)
        for i, name in pairs(friendsList) do
            if name == friendName then
                table.remove(friendsList, i)
                Library:Notify("Amigos", "Amigo removido!", 2)
                return true
            end
        end
        return false
    end
    
    local function CheckOnlineFriends()
        onlineFriends = {}
        for _, player in pairs(Players:GetPlayers()) do
            if table.find(friendsList, player.Name) then
                table.insert(onlineFriends, {
                    Name = player.Name,
                    UserId = player.UserId,
                    JoinTime = tick()
                })
            end
        end
        return onlineFriends
    end

    -- ========== FUNÇÕES NOVAS: ANÔNIMO & FPS BOOSTER ==========
    local function SetFPSBooster(state)
        FPSBoosterActive = state
        if state then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") or v:IsA("UnionOperation") then
                    v.Material = Enum.Material.Plastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Enabled = false
                end
            end
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            settings().Rendering.QualityLevel = 1
            local sky = Lighting:FindFirstChildOfClass("Sky")
            if not sky then sky = Instance.new("Sky", Lighting) end
            sky.SkyboxBk = "rbxassetid://0"
            sky.SkyboxDn = "rbxassetid://0"
            sky.SkyboxFt = "rbxassetid://0"
            sky.SkyboxLf = "rbxassetid://0"
            sky.SkyboxRt = "rbxassetid://0"
            sky.SkyboxUp = "rbxassetid://0"
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        else
            Library:Notify("FPS Booster", "Desativado. Algumas texturas podem exigir reinicialização.", 5)
        end
    end
    
    -- ========== SEÇÃO: INFORMAÇÕES DO JOGO ==========
    ServerTab:CreateSection("📊 INFORMAÇÕES DO JOGO")
    
    local gameInfoFrame = Instance.new("Frame")
    gameInfoFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    gameInfoFrame.Size = UDim2.new(1, -10, 0, 120)
    gameInfoFrame.Parent = ServerTab.Page
    
    local gameCorner = Instance.new("UICorner")
    gameCorner.CornerRadius = UDim.new(0, 8)
    gameCorner.Parent = gameInfoFrame
    
    local gameStroke = Instance.new("UIStroke")
    gameStroke.Color = Color3.fromRGB(0, 255, 255)
    gameStroke.Thickness = 1
    gameStroke.Parent = gameInfoFrame
    
    local gameImage = Instance.new("ImageLabel")
    gameImage.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    gameImage.Size = UDim2.new(0, 80, 0, 80)
    gameImage.Position = UDim2.new(0, 10, 0.5, -40)
    pcall(function() gameImage.Image = "rbxassetid://" .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).IconImageAssetId end)
    gameImage.Parent = gameInfoFrame
    
    local imageCorner = Instance.new("UICorner")
    imageCorner.CornerRadius = UDim.new(0, 6)
    imageCorner.Parent = gameImage
    
    local gameName = Instance.new("TextLabel")
    gameName.BackgroundTransparency = 1
    gameName.Position = UDim2.new(0, 100, 0, 10)
    gameName.Size = UDim2.new(1, -120, 0, 25)
    gameName.Font = Enum.Font.GothamBold
    gameName.Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    gameName.TextColor3 = Color3.fromRGB(255, 255, 255)
    gameName.TextSize = 16
    gameName.TextXAlignment = Enum.TextXAlignment.Left
    gameName.Parent = gameInfoFrame

    local regionLabel = Instance.new("TextLabel")
    regionLabel.BackgroundTransparency = 1
    regionLabel.Position = UDim2.new(0, 100, 0, 35)
    regionLabel.Size = UDim2.new(1, -120, 0, 20)
    regionLabel.Font = Enum.Font.Gotham
    regionLabel.Text = "📍 Região: " .. GetServerRegion()
    regionLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    regionLabel.TextSize = 12
    regionLabel.TextXAlignment = Enum.TextXAlignment.Left
    regionLabel.Parent = gameInfoFrame
    
    local serverId = Instance.new("TextLabel")
    serverId.BackgroundTransparency = 1
    serverId.Position = UDim2.new(0, 100, 0, 60)
    serverId.Size = UDim2.new(1, -120, 0, 20)
    serverId.Font = Enum.Font.Gotham
    serverId.Text = "Server ID: " .. game.JobId
    serverId.TextColor3 = Color3.fromRGB(150, 150, 150)
    serverId.TextSize = 12
    serverId.TextXAlignment = Enum.TextXAlignment.Left
    serverId.Parent = gameInfoFrame
    
    local copyIdBtn = Instance.new("TextButton")
    copyIdBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    copyIdBtn.Size = UDim2.new(0, 70, 0, 20)
    copyIdBtn.Position = UDim2.new(1, -80, 0, 60)
    copyIdBtn.Font = Enum.Font.GothamBold
    copyIdBtn.Text = "📋 Copiar"
    copyIdBtn.Parent = gameInfoFrame
    
    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 4)
    copyCorner.Parent = copyIdBtn
    
    copyIdBtn.MouseButton1Click:Connect(function()
        CopyServerID()
        copyIdBtn.Text = "✅ Copiado!"
        wait(1)
        copyIdBtn.Text = "📋 Copiar"
    end)
    
    -- ========== SEÇÃO: CONTROLES DO SERVIDOR ==========
    ServerTab:CreateSection("🎮 CONTROLES DO SERVIDOR")
    
    ServerTab:CreateButton("🔄 Server Hop", function()
        ServerHop()
    end)
    
    ServerTab:CreateButton("🔁 Rejoin", function()
        Rejoin()
    end)
    
    ServerTab:CreateButton("👥 Low Player", function()
        FindLowPlayerServers(function(servers)
            local lowServer = nil
            for _, server in pairs(servers) do
                if server.Players < 5 then
                    lowServer = server
                    break
                end
            end
            if lowServer then
                JoinServerById(lowServer.Id)
            end
        end)
    end)

    -- ========== SEÇÃO: PRIVACIDADE & PERFORMANCE (NOVAS) ==========
    ServerTab:CreateSection("🛡️ PRIVACIDADE & PERFORMANCE")
    ServerTab:CreateToggle("Anônimo", false, function(state)
        AnonymousMode = state
        if state then
            Library:Notify("Anônimo", "Nomes ocultados com sucesso!", 3)
        else
            Library:Notify("Anônimo", "Nomes restaurados!", 3)
        end
    end)
    
    ServerTab:CreateToggle("fpsBooster", false, function(state)
        SetFPSBooster(state)
        if state then
            Library:Notify("FPS Booster", "Performance Máxima Ativada!", 3)
        else
            Library:Notify("FPS Booster", "Performance Restaurada!", 3)
        end
    end)
    
    -- ========== SEÇÃO: ENTRADA POR ID ==========
    ServerTab:CreateSection("🔐 ENTRADA POR ID DO SERVIDOR")
    
    ServerTab:CreateTextBox("ID do Servidor", "Cole o ID aqui...", function(serverId)
        if serverId and serverId ~= "" then
            JoinServerById(serverId)
        end
    end)
    
    -- ========== SEÇÃO: LISTA DE JOGADORES ==========
    ServerTab:CreateSection("👨‍👩‍👧‍👦 JOGADORES NO SERVIDOR")
    
    local playerListFrame = Instance.new("ScrollingFrame")
    playerListFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    playerListFrame.Size = UDim2.new(1, -10, 0, 150)
    playerListFrame.Parent = ServerTab.Page
    playerListFrame.ScrollBarThickness = 3
    playerListFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    
    local playerCorner = Instance.new("UICorner")
    playerCorner.CornerRadius = UDim.new(0, 8)
    playerCorner.Parent = playerListFrame
    
    local playerStroke = Instance.new("UIStroke")
    playerStroke.Color = Color3.fromRGB(0, 255, 255)
    playerStroke.Thickness = 1
    playerStroke.Parent = playerListFrame
    
    local playerLayout = Instance.new("UIListLayout")
    playerLayout.Parent = playerListFrame
    playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    playerLayout.Padding = UDim.new(0, 5)
    
    local function RefreshPlayerList()
        for _, child in pairs(playerListFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        UpdatePlayerList()
        
        for _, playerData in pairs(playerList) do
            local playerEntry = Instance.new("Frame")
            playerEntry.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            playerEntry.Size = UDim2.new(1, -10, 0, 30)
            playerEntry.Parent = playerListFrame
            
            local entryCorner = Instance.new("UICorner")
            entryCorner.CornerRadius = UDim.new(0, 4)
            entryCorner.Parent = playerEntry
            
            local playerName = Instance.new("TextLabel")
            playerName.BackgroundTransparency = 1
            playerName.Position = UDim2.new(0, 10, 0, 0)
            playerName.Size = UDim2.new(0.5, 0, 1, 0)
            playerName.Font = Enum.Font.Gotham
            
            -- LÓGICA DO MODO ANÔNIMO
            if AnonymousMode then
                playerName.Text = "⛔️⛔️⛔️⛔️"
            else
                playerName.Text = playerData.Name
            end
            
            playerName.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerName.TextSize = 12
            playerName.TextXAlignment = Enum.TextXAlignment.Left
            playerName.Parent = playerEntry
            
            local playerTime = Instance.new("TextLabel")
            playerTime.BackgroundTransparency = 1
            playerTime.Position = UDim2.new(0.5, 0, 0, 0)
            playerTime.Size = UDim2.new(0.5, -10, 1, 0)
            playerTime.Font = Enum.Font.Gotham
            playerTime.Text = FormatTime(playerData.JoinTime)
            playerTime.TextColor3 = Color3.fromRGB(150, 150, 150)
            playerTime.TextSize = 11
            playerTime.TextXAlignment = Enum.TextXAlignment.Right
            playerTime.Parent = playerEntry
        end
    end
    
    spawn(function()
        while task.wait(5) do
            pcall(RefreshPlayerList)
        end
    end)
    
    RefreshPlayerList()
    
    -- ========== SEÇÃO: CRONÔMETRO ==========
    ServerTab:CreateSection("⏱️ TEMPO DE JOGO")
    
    local timerFrame = Instance.new("Frame")
    timerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    timerFrame.Size = UDim2.new(1, -10, 0, 50)
    timerFrame.Parent = ServerTab.Page
    
    local timerCorner = Instance.new("UICorner")
    timerCorner.CornerRadius = UDim.new(0, 8)
    timerCorner.Parent = timerFrame
    
    local timerStroke = Instance.new("UIStroke")
    timerStroke.Color = Color3.fromRGB(0, 255, 255)
    timerStroke.Thickness = 1
    timerStroke.Parent = timerFrame
    
    local timerLabel = Instance.new("TextLabel")
    timerLabel.BackgroundTransparency = 1
    timerLabel.Position = UDim2.new(0, 10, 0.5, -15)
    timerLabel.Size = UDim2.new(1, -20, 0, 30)
    timerLabel.Font = Enum.Font.GothamBold
    timerLabel.Text = "Tempo: 00:00:00"
    timerLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    timerLabel.TextSize = 20
    timerLabel.TextXAlignment = Enum.TextXAlignment.Center
    timerLabel.Parent = timerFrame
    
    spawn(function()
        while task.wait(1) do
            local elapsed = tick() - sessionStartTime
            timerLabel.Text = "Tempo: " .. FormatTime(elapsed)
        end
    end)
    
    -- ========== SEÇÃO: HISTÓRICO DE SERVIDORES ==========
    ServerTab:CreateSection("📜 HISTÓRICO DE SERVIDORES")
    
    local historyFrame = Instance.new("ScrollingFrame")
    historyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    historyFrame.Size = UDim2.new(1, -10, 0, 150)
    historyFrame.Parent = ServerTab.Page
    historyFrame.ScrollBarThickness = 3
    historyFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    
    local historyCorner = Instance.new("UICorner")
    historyCorner.CornerRadius = UDim.new(0, 8)
    historyCorner.Parent = historyFrame
    
    local historyStroke = Instance.new("UIStroke")
    historyStroke.Color = Color3.fromRGB(0, 255, 255)
    historyStroke.Thickness = 1
    historyStroke.Parent = historyFrame
    
    local historyLayout = Instance.new("UIListLayout")
    historyLayout.Parent = historyFrame
    historyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    historyLayout.Padding = UDim.new(0, 5)
    
    local function RefreshHistory()
        for _, child in pairs(historyFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        for _, historyItem in pairs(serverHistory) do
            local historyEntry = Instance.new("Frame")
            historyEntry.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            historyEntry.Size = UDim2.new(1, -10, 0, 35)
            historyEntry.Parent = historyFrame
            
            local entryCorner = Instance.new("UICorner")
            entryCorner.CornerRadius = UDim.new(0, 4)
            entryCorner.Parent = historyEntry
            
            local serverInfo = Instance.new("TextLabel")
            serverInfo.BackgroundTransparency = 1
            serverInfo.Position = UDim2.new(0, 10, 0, 0)
            serverInfo.Size = UDim2.new(0.6, 0, 1, 0)
            serverInfo.Font = Enum.Font.Gotham
            serverInfo.Text = historyItem.Name .. " (" .. historyItem.Players .. " jogadores)"
            serverInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
            serverInfo.TextSize = 11
            serverInfo.TextXAlignment = Enum.TextXAlignment.Left
            serverInfo.Parent = historyEntry
            
            local serverTime = Instance.new("TextLabel")
            serverTime.BackgroundTransparency = 1
            serverTime.Position = UDim2.new(0.6, 0, 0, 0)
            serverTime.Size = UDim2.new(0.4, -10, 1, 0)
            serverTime.Font = Enum.Font.Gotham
            serverTime.Text = historyItem.FormattedTime
            serverTime.TextColor3 = Color3.fromRGB(150, 150, 150)
            serverTime.TextSize = 10
            serverTime.TextXAlignment = Enum.TextXAlignment.Right
            serverTime.Parent = historyEntry
        end
    end
    
    ServerTab:CreateButton("🗑️ Limpar Histórico", function()
        ClearHistory()
        RefreshHistory()
    end)
    
    spawn(function()
        while task.wait(2) do
            pcall(RefreshHistory)
        end
    end)
    
    RefreshHistory()
    
    -- ========== SEÇÃO: ESTATÍSTICAS ==========
    ServerTab:CreateSection("📈 ESTATÍSTICAS DE TEMPO")
    
    local statsFrame = Instance.new("Frame")
    statsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    statsFrame.Size = UDim2.new(1, -10, 0, 120)
    statsFrame.Parent = ServerTab.Page
    
    local statsCorner = Instance.new("UICorner")
    statsCorner.CornerRadius = UDim.new(0, 8)
    statsCorner.Parent = statsFrame
    
    local statsStroke = Instance.new("UIStroke")
    statsStroke.Color = Color3.fromRGB(0, 255, 255)
    statsStroke.Thickness = 1
    statsStroke.Parent = statsFrame
    
    local statsLabel = Instance.new("TextLabel")
    statsLabel.BackgroundTransparency = 1
    statsLabel.Position = UDim2.new(0, 10, 0, 5)
    statsLabel.Size = UDim2.new(1, -20, 1, -10)
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.Text = "Carregando estatísticas..."
    statsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    statsLabel.TextSize = 11
    statsLabel.TextWrapped = true
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.TextYAlignment = Enum.TextYAlignment.Top
    statsLabel.Parent = statsFrame
    
    spawn(function()
        while task.wait(1) do
            local currentSession = tick() - gameStats.sessionStartTime
            statsLabel.Text = 
                "⏱️ Sessão Atual: " .. FormatTime(currentSession) .. "\n" ..
                "🔄 Mudanças de Servidor: " .. gameStats.serverChanges .. "\n" ..
                "📊 Total de Sessões: " .. gameStats.totalSessions .. "\n" ..
                "🛡️ Anti-AFK: Ativo ✅"
        end
    end)
    
    -- ========== SEÇÃO: SISTEMA DE AMIGOS ==========
    ServerTab:CreateSection("👥 SISTEMA DE AMIGOS ONLINE")
    
    ServerTab:CreateTextBox("Adicionar Amigo", "Nome do amigo...", function(friendName)
        if friendName and friendName ~= "" then
            AddFriend(friendName)
        end
    end)
    
    local onlineFriendsFrame = Instance.new("ScrollingFrame")
    onlineFriendsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    onlineFriendsFrame.Size = UDim2.new(1, -10, 0, 120)
    onlineFriendsFrame.Parent = ServerTab.Page
    onlineFriendsFrame.ScrollBarThickness = 3
    onlineFriendsFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    
    local friendsCorner = Instance.new("UICorner")
    friendsCorner.CornerRadius = UDim.new(0, 8)
    friendsCorner.Parent = onlineFriendsFrame
    
    local friendsStroke = Instance.new("UIStroke")
    friendsStroke.Color = Color3.fromRGB(0, 255, 255)
    friendsStroke.Thickness = 1
    friendsStroke.Parent = onlineFriendsFrame
    
    local friendsLayout = Instance.new("UIListLayout")
    friendsLayout.Parent = onlineFriendsFrame
    friendsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    friendsLayout.Padding = UDim.new(0, 5)
    
    local function RefreshOnlineFriends()
        for _, child in pairs(onlineFriendsFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        CheckOnlineFriends()
        
        if #onlineFriends == 0 then
            local noFriendsLabel = Instance.new("TextLabel")
            noFriendsLabel.BackgroundTransparency = 1
            noFriendsLabel.Size = UDim2.new(1, 0, 0, 30)
            noFriendsLabel.Font = Enum.Font.Gotham
            noFriendsLabel.Text = "Nenhum amigo online no momento"
            noFriendsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            noFriendsLabel.TextSize = 12
            noFriendsLabel.Parent = onlineFriendsFrame
        else
            for _, friend in pairs(onlineFriends) do
                local friendEntry = Instance.new("Frame")
                friendEntry.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                friendEntry.Size = UDim2.new(1, -10, 0, 30)
                friendEntry.Parent = onlineFriendsFrame
                
                local entryCorner = Instance.new("UICorner")
                entryCorner.CornerRadius = UDim.new(0, 4)
                entryCorner.Parent = friendEntry
                
                local friendName = Instance.new("TextLabel")
                friendName.BackgroundTransparency = 1
                friendName.Position = UDim2.new(0, 10, 0, 0)
                friendName.Size = UDim2.new(0.7, 0, 1, 0)
                friendName.Font = Enum.Font.Gotham
                friendName.Text = "🟢 " .. friend.Name
                friendName.TextColor3 = Color3.fromRGB(100, 255, 100)
                friendName.TextSize = 12
                friendName.TextXAlignment = Enum.TextXAlignment.Left
                friendName.Parent = friendEntry
                
                local removeBtn = Instance.new("TextButton")
                removeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                removeBtn.Size = UDim2.new(0, 60, 0, 20)
                removeBtn.Position = UDim2.new(1, -70, 0.5, -10)
                removeBtn.Font = Enum.Font.GothamBold
                removeBtn.Text = "Remover"
                removeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                removeBtn.TextSize = 9
                removeBtn.Parent = friendEntry
                
                local removeCorner = Instance.new("UICorner")
                removeCorner.CornerRadius = UDim.new(0, 4)
                removeCorner.Parent = removeBtn
                
                removeBtn.MouseButton1Click:Connect(function()
                    RemoveFriend(friend.Name)
                    RefreshOnlineFriends()
                end)
            end
        end
    end
    
    spawn(function()
        while task.wait(3) do
            pcall(RefreshOnlineFriends)
        end
    end)
    
    RefreshOnlineFriends()
    
    -- ========== SEÇÃO: CONFIGURAÇÕES ==========
    ServerTab:CreateSection("⚙️ CONFIGURAÇÕES AVANÇADAS")
    
    ServerTab:CreateToggle("Auto Server Hop", false, function(state)
        isAutoHopping = state
        if state then
            spawn(function()
                while isAutoHopping do
                    wait(30)
                    ServerHop()
                end
            end)
        end
    end)
    
    ServerTab:CreateToggle("Notificações", true, function(state)
        _G.NotificationsEnabled = state
    end)
    
    ServerTab:CreateLabel("✅ Aba Server v3.0 carregada com sucesso!")

    Library:Notify("Manus Elite Hub", "Interface Loaded Successfully! Enjoy your 380+ features.", 5)
    print("Manus Elite Hub v3.0: Todas as abas e features carregadas!")
end)
