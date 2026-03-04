-- =====================================================
-- 99 NIGHTS IN THE FOREST - SCRIPT COMPLETO
-- Script by lohjc | Discord: discord.gg/ZNTHTWx7KE
-- =====================================================

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/iiivyne/robloxlua/refs/heads/main/lib.lua"))()
local int = lib:CreateInterface("99 Nights in the Forest","script made by lohjc","https://discord.gg/ZNTHTWx7KE","bottom left","royal")

-- =====================================================
-- SISTEMA DE FECHAR / MINIMIZAR
-- =====================================================
task.spawn(function()
    task.wait(0.8) -- espera a lib criar a GUI

    local Players_ = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local LocalPlayer_ = Players_.LocalPlayer
    local PlayerGui_ = LocalPlayer_:WaitForChild("PlayerGui")

    -- Encontra o ScreenGui principal criado pela lib
    local mainScreenGui = nil
    for _, gui in ipairs(PlayerGui_:GetChildren()) do
        if gui:IsA("ScreenGui") and gui ~= PlayerGui_:FindFirstChild("FloatButton99Nights") then
            mainScreenGui = gui
            break
        end
    end
    if not mainScreenGui then return end

    -- Encontra o Frame principal
    local mainFrame = nil
    for _, child in ipairs(mainScreenGui:GetChildren()) do
        if child:IsA("Frame") then mainFrame = child break end
    end
    if not mainFrame then return end

    -- Encontra a TopBar (primeiro filho Frame do mainFrame)
    local topBar = nil
    for _, sub in ipairs(mainFrame:GetChildren()) do
        if sub:IsA("Frame") then topBar = sub break end
    end

    -- ── Botão MINIMIZAR ──────────────────────────────
    local btnMinimize = Instance.new("TextButton")
    btnMinimize.Size = UDim2.new(0, 26, 0, 26)
    btnMinimize.Position = UDim2.new(1, -58, 0, 4)
    btnMinimize.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    btnMinimize.Text = "─"
    btnMinimize.TextColor3 = Color3.fromRGB(30, 30, 30)
    btnMinimize.TextSize = 14
    btnMinimize.Font = Enum.Font.GothamBold
    btnMinimize.BorderSizePixel = 0
    btnMinimize.ZIndex = 999
    btnMinimize.Parent = mainFrame
    Instance.new("UICorner", btnMinimize).CornerRadius = UDim.new(0, 6)

    -- ── Botão FECHAR ─────────────────────────────────
    local btnClose = Instance.new("TextButton")
    btnClose.Size = UDim2.new(0, 26, 0, 26)
    btnClose.Position = UDim2.new(1, -28, 0, 4)
    btnClose.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    btnClose.Text = "✕"
    btnClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnClose.TextSize = 14
    btnClose.Font = Enum.Font.GothamBold
    btnClose.BorderSizePixel = 0
    btnClose.ZIndex = 999
    btnClose.Parent = mainFrame
    Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0, 6)

    -- ── Botão FLUTUANTE (aparece após fechar) ─────────
    local floatGui = Instance.new("ScreenGui")
    floatGui.Name = "FloatButton99Nights"
    floatGui.ResetOnSpawn = false
    floatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    floatGui.Parent = PlayerGui_

    local floatBtn = Instance.new("TextButton")
    floatBtn.Size = UDim2.new(0, 52, 0, 52)
    floatBtn.Position = UDim2.new(0.5, -26, 0.5, -26)
    floatBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    floatBtn.Text = "99\n🌲"
    floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    floatBtn.TextSize = 11
    floatBtn.Font = Enum.Font.GothamBold
    floatBtn.BorderSizePixel = 0
    floatBtn.Visible = false
    floatBtn.ZIndex = 9999
    floatBtn.Parent = floatGui
    local fc = Instance.new("UICorner", floatBtn)
    fc.CornerRadius = UDim.new(0, 14)
    local fs = Instance.new("UIStroke", floatBtn)
    fs.Color = Color3.fromRGB(90, 90, 200)
    fs.Thickness = 2

    -- ── Arrastar botão flutuante ──────────────────────
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    floatBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = floatBtn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    floatBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local vp = workspace.CurrentCamera.ViewportSize
            local newX = math.clamp(startPos.X.Offset + delta.X, 0, vp.X - 52)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, vp.Y - 52)
            floatBtn.Position = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- ── Minimizar: esconde tudo exceto a TopBar ───────
    local isMinimized = false
    local originalSize = mainFrame.Size

    local function setMinimized(state)
        isMinimized = state
        for _, child in ipairs(mainFrame:GetChildren()) do
            if child ~= topBar and child ~= btnMinimize and child ~= btnClose then
                child.Visible = not state
            end
        end
        if state then
            local topH = topBar and (topBar.Size.Y.Offset + 10) or 38
            mainFrame.Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, topH)
            btnMinimize.Text = "□"
        else
            mainFrame.Size = originalSize
            btnMinimize.Text = "─"
        end
    end

    btnMinimize.MouseButton1Click:Connect(function()
        setMinimized(not isMinimized)
    end)

    -- ── Fechar: esconde tudo, mostra botão flutuante ──
    btnClose.MouseButton1Click:Connect(function()
        mainScreenGui.Enabled = false
        floatBtn.Visible = true
    end)

    -- ── Botão flutuante: reabre a interface ───────────
    local wasDragging = false
    floatBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            if not dragging then
                task.wait(0.05)
                if not wasDragging then
                    mainScreenGui.Enabled = true
                    floatBtn.Visible = false
                end
                wasDragging = false
            else
                wasDragging = true
            end
        end
    end)
end)
-- =====================================================
local main = int:CreateTab("Main","main functions/script utilities","default",true)
local autofarmss = int:CreateTab("Auto","auto farm utilities (OP)","op")
local itemtp = int:CreateTab("Item TP/ESP","bring items to you","item")
local gametp = int:CreateTab("Game TP","goto in-game locations","info")
local charactertp = int:CreateTab("Mob TP","bring mobs to you","npc")
local plr = int:CreateTab("Player","modify your localplayer","player")
local vis = int:CreateTab("Visuals","modify autoyour visuals","visuals")
local misc = int:CreateTab("Misc","miscellaneous","misc")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

-- === Main Configurations ===

local player = Players.LocalPlayer

-- Safe zone setup: 9 baseplates in a grid
local safezoneBaseplates = {}
local baseplateSize = Vector3.new(2048, 1, 2048)
local baseY = 100
local centerPos = Vector3.new(0, baseY, 0)

for dx = -1, 1 do
    for dz = -1, 1 do
        local pos = centerPos + Vector3.new(dx * baseplateSize.X, 0, dz * baseplateSize.Z)
        local baseplate = Instance.new("Part")
        baseplate.Name = "SafeZoneBaseplate"
        baseplate.Size = baseplateSize
        baseplate.Position = pos
        baseplate.Anchored = true
        baseplate.CanCollide = true
        baseplate.Transparency = 1
        baseplate.Color = Color3.fromRGB(255, 255, 255)
        baseplate.Parent = workspace
        table.insert(safezoneBaseplates, baseplate)
    end
end

main:CreateCheckbox("Show Safe Zone", function(enabled)
    for _, baseplate in ipairs(safezoneBaseplates) do
        baseplate.Transparency = enabled and 0.8 or 1
        baseplate.CanCollide = enabled
    end
end)

-- Utility to convert "x, y, z" string to CFrame
local function stringToCFrame(str)
    local x, y, z = str:match("([^,]+),%s*([^,]+),%s*([^,]+)")
    return CFrame.new(tonumber(x), tonumber(y), tonumber(z))
end

-- Teleport function with optional tween duration
local function teleportToTarget(cf, duration)
    local char = game.Players.LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if duration and duration > 0 then
        local ts = game:GetService("TweenService")
        local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        local goal = { CFrame = cf }
        local tween = ts:Create(hrp, info, goal)
        tween:Play()
    else
        hrp.CFrame = cf
    end
end

-- === Game TP (Story Coords) ===
local storyCoords = {
    { "[campsite] camp site", "0, 8, -0"},
    { "[safezone] safe zone", "0, 110, -0" }
}

local storyDropdown = gametp:CreateDropDown("Teleports")

for _, entry in ipairs(storyCoords) do
    local name, coord = entry[1], entry[2]
    storyDropdown:AddButton(name, function()
        teleportToTarget(stringToCFrame(coord), 0.1)
    end)
end

-- === Item ESP ===
itemtp:CreateCheckbox("Item ESP", function(state)
    local itemFolder = workspace:FindFirstChild("Items")
    if not itemFolder then
        warn("workspace.Items folder not found")
        return
    end

    local itemNames = {
        ["Revolver"] = true, ["Oil Barrel"] = true, ["Chainsaw"] = true,
        ["Giant Sack"] = true, ["Bunny Foot"] = true, ["MedKit"] = true,
        ["Alien Chest"] = true, ["Berry"] = true, ["Bolt"] = true,
        ["Broken Fan"] = true, ["Carrot"] = true, ["Coal"] = true,
        ["Coin Stack"] = true, ["Hologram Emitter"] = true, ["Item Chest"] = true,
        ["Laser Fence Blueprint"] = true, ["Log"] = true, ["Old Flashlight"] = true,
        ["Old Radio"] = true, ["Sheet Metal"] = true, ["Bandage"] = true, ["Rifle"] = true
    }

    local connections = {}

    local function createESP(model)
        if not model:IsA("Model") or not itemNames[model.Name] then return end
        if not model.PrimaryPart or model:FindFirstChild("ESP") then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP"
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.Adornee = model.PrimaryPart
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0)

        local customFont = Font.new("rbxassetid://16658246179", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.TextSize = 17
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextStrokeTransparency = 0.5
        label.TextScaled = false
        label.FontFace = customFont
        label.Text = model.Name
        label.Parent = billboard
        billboard.Parent = model
    end

    local function removeAllESP()
        for _, model in itemFolder:GetChildren() do
            local esp = model:FindFirstChild("ESP")
            if esp then esp:Destroy() end
        end
    end

    if state then
        for _, model in itemFolder:GetChildren() do
            createESP(model)
        end
        local connection = itemFolder.ChildAdded:Connect(function(model)
            if model:IsA("Model") and itemNames[model.Name] then
                model:GetPropertyChangedSignal("PrimaryPart"):Wait()
                createESP(model)
            end
        end)
        table.insert(connections, connection)
    else
        removeAllESP()
        for _, conn in connections do
            if conn.Disconnect then conn:Disconnect() end
        end
        table.clear(connections)
    end
end)

-- === TP to Item ===
local localPlayer = Players.LocalPlayer
local itemFolder = workspace:WaitForChild("Items")

local itemNames = {
    "Revolver", "Medkit", "Alien Chest", "Berry", "Bolt", "Broken Fan",
    "Carrot", "Coal", "Coin Stack", "Hologram Emitter", "Item Chest",
    "Laser Fence Blueprint", "Log", "Old Flashlight", "Old Radio",
    "Sheet Metal", "Bandage", "Rifle"
}

local function getModelPart(model)
    if model.PrimaryPart then
        return model.PrimaryPart
    end
    for _, part in pairs(model:GetChildren()) do
        if part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

local dropdown = itemtp:CreateDropDown("Teleport to Item")

for _, itemName in ipairs(itemNames) do
    dropdown:AddButton("TP to " .. itemName, function()
        local candidates = {}
        for _, model in pairs(itemFolder:GetChildren()) do
            if model:IsA("Model") and model.Name == itemName then
                local part = getModelPart(model)
                if part then
                    table.insert(candidates, part)
                end
            end
        end
        if #candidates == 0 then
            warn("No '" .. itemName .. "' found to teleport to.")
            return
        end
        local targetPart = candidates[math.random(1, #candidates)]
        local character = localPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = targetPart.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end)
end

-- === Teleport Item to You (Bulk) ===
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local itemsFolder = workspace:WaitForChild("Items")
local remoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local possibleItems = {
    "Alien Chest", "Alpha Wolf Pelt", "Anvil Front", "Anvil Back",
    "Apple", "Bandage", "Bear Corpse", "Bear Pelt", "Berry", "Biofuel",
    "Bolt", "Broken Fan", "Bunny Foot", "Carrot", "Coal", "Coin Stack",
    "Cooked Morsel", "Cooked Steak", "Chainsaw", "Cultist", "Cultist Gem",
    "Flower", "Fuel Canister", "Hologram Emitter", "Item Chest",
    "Laser Fence Blueprint", "Leather Body", "Iron Body", "Thorn Body",
    "Log", "MedKit", "Morsel", "Old Flashlight", "Old Radio",
    "Good Sack", "Good Axe", "Raygun", "Giant Sack", "Strong Axe",
    "Oil Barrel", "Old Car Engine", "Rifle", "Rifle Ammo", "Revolver",
    "Revolver Ammo", "Sapling", "Sheet Metal", "Steak", "Wolf Pelt",
    "Gem of the Forest Fragment", "Tyre", "Washing Machine", "Broken Microwave"
}

local bringitemtoyou = itemtp:CreateDropDown("Teleport Item (Bulk):")
local sources = {
    itemsFolder,
    game:GetService("ReplicatedStorage"):WaitForChild("TempStorage")
}

local function teleportItem(itemName)
    local stackOffsetY = 2
    local count = 0

    for _, source in ipairs(sources) do
        for _, item in ipairs(source:GetChildren()) do
            if item.Name == itemName then
                local targetPart = nil

                if itemName == "Berry" then
                    targetPart = item:FindFirstChild("Handle")
                    if not targetPart then
                        for _, child in ipairs(item:GetDescendants()) do
                            if child:IsA("Part") or child:IsA("UnionOperation") then
                                targetPart = child
                                break
                            end
                        end
                    end
                else
                    for _, child in ipairs(item:GetDescendants()) do
                        if child:IsA("MeshPart") or child:IsA("Part") then
                            targetPart = child
                            break
                        end
                    end
                end

                if targetPart then
                    remoteEvents.RequestStartDraggingItem:FireServer(item)
                    local offset = Vector3.new(0, count * stackOffsetY, 0)
                    targetPart.CFrame = rootPart.CFrame + offset
                    remoteEvents.StopDraggingItem:FireServer(item)
                    print("Moved", itemName, ":", item:GetFullName())
                    count = count + 1
                else
                    warn(itemName .. " found, but no MeshPart or Part inside:", item:GetFullName())
                end
            end
        end
    end
end

for _, itemName in ipairs(possibleItems) do
    bringitemtoyou:AddButton(itemName, function()
        teleportItem(itemName)
    end)
end

-- === TP Mob to You ===
local characterFolder = workspace:WaitForChild("Characters")

local possibleCharacters = {
    "Alpha Wolf", "Bear", "Lost Child", "Lost Child2",
    "Lost Child3", "Lost Child4", "Wolf", "Bunny", "Cultist", "Alien"
}

local bringCharacterToYou = charactertp:CreateDropDown("Teleport Mob:")

local function getMainPart(model)
    if model.PrimaryPart then
        return model.PrimaryPart
    end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            return part
        end
    end
    return nil
end

local function teleportCharacter(characterName)
    local stackOffsetY = 3
    local count = 0

    for _, model in ipairs(characterFolder:GetChildren()) do
        if model.Name == characterName then
            local mainPart = getMainPart(model)
            if mainPart and rootPart then
                local targetCFrame = rootPart.CFrame + Vector3.new(0, count * stackOffsetY, 0)
                if model.PrimaryPart then
                    model:SetPrimaryPartCFrame(targetCFrame)
                else
                    mainPart.CFrame = targetCFrame
                end
                count = count + 1
            else
                warn("No main part found for character:", model:GetFullName())
            end
        end
    end
end

for _, characterName in ipairs(possibleCharacters) do
    bringCharacterToYou:AddButton(characterName, function()
        teleportCharacter(characterName)
    end)
end

-- === Player Sliders ===

plr:CreateSlider("jumppower", 700, 50, function(value)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = value
    end
end)

plr:CreateSlider("walkspeed", 700, 16, function(value)
    _G.HackedWalkSpeed = value

    local function applyWalkSpeed(humanoid)
        if humanoid then
            humanoid.WalkSpeed = _G.HackedWalkSpeed
            humanoid.Changed:Connect(function(property)
                if property == "WalkSpeed" and humanoid.WalkSpeed ~= _G.HackedWalkSpeed then
                    humanoid.WalkSpeed = _G.HackedWalkSpeed
                end
            end)
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        applyWalkSpeed(LocalPlayer.Character.Humanoid)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        applyWalkSpeed(char:FindFirstChild("Humanoid"))
    end)
end)

plr:CreateCheckbox("walkspeed toggle (50)", function(toggle)
    if toggle == true then
        _G.HackedWalkSpeed = 50
    else
        _G.HackedWalkSpeed = 16
    end

    local function applyWalkSpeed(humanoid)
        if humanoid then
            humanoid.WalkSpeed = _G.HackedWalkSpeed
            humanoid.Changed:Connect(function(property)
                if property == "WalkSpeed" and humanoid.WalkSpeed ~= _G.HackedWalkSpeed then
                    humanoid.WalkSpeed = _G.HackedWalkSpeed
                end
            end)
        end
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        applyWalkSpeed(LocalPlayer.Character.Humanoid)
    end

    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid")
        applyWalkSpeed(char:FindFirstChild("Humanoid"))
    end)
end)

-- === ESP / Visuals ===

--// SERVICES
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

--// CONFIG
local espTransparency = 0.4
local teamCheck = true

--// CUSTOM FONT
local customFont = Font.new("rbxassetid://16658246179", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

--// STATE
local BillboardESPs = {}
local ChamsESPs = {}
local ESPConnections = {}
local ESPEnabled = false
local ChamsEnabled = false

--// HELPERS
local function round(num, decimals)
    return tonumber(string.format("%." .. (decimals or 0) .. "f", num))
end

local function getRoot(char)
    return char and char:FindFirstChild("HumanoidRootPart")
end

--// BILLBOARD ESP
local function createBillboardESP(plr)
    if BillboardESPs[plr] or plr == LocalPlayer then return end
    if not plr.Character or not plr.Character:FindFirstChild("Head") then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "Billboard_ESP"
    gui.Adornee = plr.Character.Head
    gui.Parent = plr.Character.Head
    gui.Size = UDim2.new(0, 100, 0, 40)
    gui.AlwaysOnTop = true
    gui.StudsOffset = Vector3.new(0, 2, 0)

    local label = Instance.new("TextLabel", gui)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.5
    label.TextScaled = true
    label.FontFace = customFont

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not plr.Character or not plr.Character:FindFirstChild("Humanoid") then
            gui:Destroy()
            if conn then conn:Disconnect() end
            BillboardESPs[plr] = nil
            ESPConnections[plr] = nil
            return
        end
        local hp = math.floor(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth * 100)
        label.Text = plr.Name .. " | " .. hp .. "%"
    end)

    BillboardESPs[plr] = gui
    ESPConnections[plr] = conn
end

--// CHAMS ESP
local function createChamsESP(plr)
    if ChamsESPs[plr] or plr == LocalPlayer then return end
    if not plr.Character or not getRoot(plr.Character) then return end

    local folder = Instance.new("Folder")
    folder.Name = "Chams_ESP"
    folder.Parent = CoreGui
    ChamsESPs[plr] = folder

    for _, part in pairs(plr.Character:GetChildren()) do
        if part:IsA("BasePart") then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "Cham_" .. plr.Name
            box.Adornee = part
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Size = part.Size
            box.Transparency = espTransparency
            box.Color = BrickColor.new(
                teamCheck and (plr.TeamColor == LocalPlayer.TeamColor and "Bright green" or "Bright red") or tostring(plr.TeamColor)
            )
            box.Parent = folder
        end
    end
end

--// CLEANUP
local function cleanupBillboardESP()
    for _, gui in pairs(BillboardESPs) do
        if gui then gui:Destroy() end
    end
    for _, conn in pairs(ESPConnections) do
        if conn then conn:Disconnect() end
    end
    BillboardESPs = {}
    ESPConnections = {}
end

local function cleanupChamsESP()
    for _, folder in pairs(ChamsESPs) do
        if folder then folder:Destroy() end
    end
    ChamsESPs = {}
end

--// INIT HANDLER
local function handlePlayerESP(plr)
    if ESPEnabled then createBillboardESP(plr) end
    if ChamsEnabled then createChamsESP(plr) end

    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if ESPEnabled then createBillboardESP(plr) end
        if ChamsEnabled then createChamsESP(plr) end
    end)
end

--// GUI TOGGLES
vis:CreateCheckbox("ESP", function(state)
    ESPEnabled = state
    if not state then
        cleanupBillboardESP()
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                createBillboardESP(plr)
            end
        end
    end
end)

vis:CreateCheckbox("Chams", function(state)
    ChamsEnabled = state
    if not state then
        cleanupChamsESP()
    else
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                createChamsESP(plr)
            end
        end
    end
end)

--// INIT ON CURRENT PLAYERS
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        handlePlayerESP(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    handlePlayerESP(plr)
end)

--// FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 1
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.ZIndex = 2

local FOVRadius = 100

RunService.RenderStepped:Connect(function()
    if FOVCircle.Visible then
        FOVCircle.Radius = FOVRadius
        FOVCircle.Position = UserInputService:GetMouseLocation()
    end
end)

vis:CreateCheckbox("FOV Circle", function(state)
    FOVCircle.Visible = state
end)

-- === Extra Scripts (Misc) ===
local civDropdown2 = misc:CreateDropDown("Extra Scripts", function() end)

civDropdown2:AddButton("infinite yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

civDropdown2:AddButton("emote gui", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dimension-sources/random-scripts-i-found/refs/heads/main/r6%20animations"))()
end)

civDropdown2:AddButton("anti afk", function()
    wait(0.5)
    local ba = Instance.new("ScreenGui")
    local ca = Instance.new("TextLabel")
    local da = Instance.new("Frame")
    local _b = Instance.new("TextLabel")
    local ab = Instance.new("TextLabel")
    ba.Parent = game.CoreGui
    ba.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ca.Parent = ba; ca.Active = true
    ca.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
    ca.Draggable = true
    ca.Position = UDim2.new(0.698610067, 0, 0.098096624, 0)
    ca.Size = UDim2.new(0, 370, 0, 52)
    ca.Font = Enum.Font.SourceSansSemibold
    ca.Text = "anti afk"
    ca.TextColor3 = Color3.new(0, 1, 1)
    ca.TextSize = 22
    da.Parent = ca
    da.BackgroundColor3 = Color3.new(0.196078, 0.196078, 0.196078)
    da.Position = UDim2.new(0, 0, 1.0192300, 0)
    da.Size = UDim2.new(0, 370, 0, 107)
    _b.Parent = da
    _b.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
    _b.Position = UDim2.new(0, 0, 0.800455689, 0)
    _b.Size = UDim2.new(0, 370, 0, 21)
    _b.Font = Enum.Font.Arial
    _b.Text = "anti afk"
    _b.TextColor3 = Color3.new(0, 1, 1)
    _b.TextSize = 20
    ab.Parent = da
    ab.BackgroundColor3 = Color3.new(0.176471, 0.176471, 0.176471)
    ab.Position = UDim2.new(0, 0, 0.158377, 0)
    ab.Size = UDim2.new(0, 370, 0, 44)
    ab.Font = Enum.Font.ArialBold
    ab.Text = "status: active"
    ab.TextColor3 = Color3.new(0, 1, 1)
    ab.TextSize = 20
    local bb = game:service("VirtualUser")
    game:service("Players").LocalPlayer.Idled:connect(function()
        bb:CaptureController()
        bb:ClickButton2(Vector2.new())
    end)
    ab.Text = "roblox tried to kick you but failed to do so!"
    wait(2)
    ab.Text = "status: active"
end)

civDropdown2:AddButton("turtle spy", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Spy/main/source.lua", true))()
end)

-- === Kill Aura ===
local Workspace = game:GetService("Workspace")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local killAuraToggle = false
local radius = 200
local infRangeKillAuraToggle = false

local toolsDamageIDs = {
    ["Old Axe"] = "1_8982038982",
    ["Good Axe"] = "112_8982038982",
    ["Strong Axe"] = "116_8982038982",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016"
}

local function getAnyToolWithDamageID()
    for toolName, damageID in pairs(toolsDamageIDs) do
        local tool = player.Inventory:FindFirstChild(toolName)
        if tool then
            return tool, damageID
        end
    end
    return nil, nil
end

local function equipTool(tool)
    if tool then
        RemoteEvents.EquipItemHandle:FireServer("FireAllClients", tool)
    end
end

local function unequipTool(tool)
    if tool then
        RemoteEvents.UnequipItemHandle:FireServer("FireAllClients", tool)
    end
end

local function killAuraLoop()
    while killAuraToggle do
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")

        if hrp then
            local tool, damageID = getAnyToolWithDamageID()
            if tool and damageID then
                equipTool(tool)

                for _, mob in ipairs(Workspace.Characters:GetChildren()) do
                    if mob:IsA("Model") then
                        local part = mob:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - hrp.Position).Magnitude <= radius then
                            pcall(function()
                                RemoteEvents.ToolDamageObject:InvokeServer(
                                    mob,
                                    tool,
                                    damageID,
                                    CFrame.new(part.Position)
                                )
                            end)
                        end
                    end
                end

                task.wait(0.1)
            else
                warn("No supported tool found in inventory")
                task.wait(1)
            end
        else
            task.wait(0.5)
        end
    end
end

local function getAllModelsInFolder(folder)
    local models = {}
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("Model") then
            table.insert(models, obj)
        end
    end
    return models
end

local function findAnyBasePart(model)
    for _, descendant in ipairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            return descendant
        end
    end
    return nil
end

main:CreateCheckbox("Kill Aura", function(state)
    killAuraToggle = state
    if state then
        task.spawn(killAuraLoop)
    else
        local tool, _ = getAnyToolWithDamageID()
        unequipTool(tool)
    end
end)

main:CreateSlider("Kill Aura Radius", 500, 20, function(value)
    radius = math.clamp(value, 20, 500)
end)

-- === Extra Item Automation (Categorized) ===
itemtp:CreateComment("remaining specific item teleports:")

local bracket = {
    weapons = {
        "Laser Sword", "Raygun", "Kunai", "Katana", "Spear"
    },
    minifoods = {
        "Apple", "Berry", "Carrot"
    },
    meat = {
        "Steak", "Cooked Steak", "Cooked Morsel", "Morsel"
    },
    armor = {
        "Leather Body", "Iron Body", "Thorn Body"
    },
    ["guns/ammo"] = {
        "Rifle", "Revolver", "Raygun", "Tactical Shotgun", "Revolver Ammo", "Rifle Ammo"
    },
    materials = {
        "Log", "Coal", "Fuel Canister", "UFO Junk", "UFO Component", "Bandage", "MedKit",
        "Old Car Engine", "Broken Fan", "Old Microwave", "Old Radio", "Sheet Metal"
    },
    pelts = {
        "Alpha Wolf Pelt", "Bear Pelt", "Wolf Pelt", "Bunny Foot"
    },
    misc_tools = {
        "Good Sack", "Old Flashlight", "Old Radio", "Giant Sack", "Strong Flashlight", "Chainsaw"
    }
}

-- =====================================================
-- PÁGINAS 17-25: AUTO FARM, ITEM AUTOMATION, STRONGHOLD
-- =====================================================

-- === Finds the first suitable BasePart to teleport ===
local function findTeleportablePart(item)
    for _, descendant in ipairs(item:GetDescendants()) do
        if descendant:IsA("BasePart") then
            return descendant
        end
        if descendant:IsA("Model") then
            for _, sub in ipairs(descendant:GetDescendants()) do
                if sub:IsA("BasePart") then
                    return sub
                end
            end
        end
    end
    return nil
end

local function teleportItem(itemName)
    local stackOffsetY = 2
    local count = 0

    for _, item in ipairs(itemsFolder:GetChildren()) do
        if item.Name == itemName then
            local targetPart = findTeleportablePart(item)
            if targetPart then
                remoteEvents.RequestStartDraggingItem:FireServer(item)
                local offset = Vector3.new(0, count * stackOffsetY, 0)
                targetPart.CFrame = rootPart.CFrame + offset
                remoteEvents.StopDraggingItem:FireServer(item)
                print("Moved", itemName, ":", item:GetFullName())
                count = count + 1
            else
                warn("Couldn't find part for:", item:GetFullName())
            end
        end
    end
end

-- Create one dropdown per bracket
for groupName, itemList in pairs(bracket) do
    local label = groupName:gsub("_", " "):gsub("/", "/")
    label = label:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
    local dropdown = itemtp:CreateDropDown(label)
    for _, itemName in ipairs(itemList) do
        dropdown:AddButton(itemName, function()
            teleportItem(itemName)
        end)
    end
end

-- === AUTO FARM SYSTEM (Pages 18-22) ===

-- === SERVICES ===
local ReplicatedStorageAuto = game:GetService("ReplicatedStorage")
local PlayersAuto = game:GetService("Players")
local WorkspaceAuto = game:GetService("Workspace")

-- === PLAYER REFERENCES ===
local playerAuto = Players.LocalPlayer
local characterAuto = playerAuto.Character or playerAuto.CharacterAdded:Wait()
local rootPartAuto = characterAuto:WaitForChild("HumanoidRootPart")
local itemReminder = WorkspaceAuto:WaitForChild("Items")
local remoteEventsAuto = ReplicatedStorageAuto:WaitForChild("RemoteEvents")
local remoteConsume = remoteEventsAuto:WaitForChild("RequestConsumeItem")

-- === POSITIONS ===
local campfireDropPos = Vector3.new(0, 19, 0)
local machineDropPos = Vector3.new(21, 16, -5)

-- === ITEM LISTS ===
local campfireFuelItems = {"Log", "Coal", "Fuel Canister", "Oil Barrel", "Biofuel"}
local autocookItems = {"Morsel", "Steak"}
local autoGrindItems = {"UFO Junk", "UFO Component", "Old Car Engine", "Broken Fan", "Old Microwave", "Bolt", "Log", "Cultist Gem", "Sheet Metal", "Old Radio", "Tyre", "Washing Machine", "Cultist Experiment", "Cultist Component", "Gem of the Forest Fragment", "Broken Microwave"}
local autoEatFoods = {"Cooked Steak", "Cooked Morsel", "Berry", "Carrot", "Apple"}
local biofuelItems = {"Carrot", "Cooked Morsel", "Morsel", "Steak", "Cooked Steak", "Log"}

-- === TOGGLES ===
local autoFuelEnabledItems = {}
local autoCookEnabledItems = {}
local autoGrindEnabledItems = {}
local autoEatEnabled = false
local autoBreakEnabled = false
local autoBiofuelEnabledItems = {}
local alwaysFeedEnabledItems = {}

-- === MOVE ITEM FUNCTION (STABLE) ===
local function moveItemToPos(item, position)
    if not item or not item:IsDescendantOf(workspace) then return end
    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
    if not part then return end

    if not item.PrimaryPart then
        pcall(function() item.PrimaryPart = part end)
    end

    pcall(function()
        remoteEventsAuto.RequestStartDraggingItem:FireServer(item)
        task.wait(0.05)
        item:SetPrimaryPartCFrame(CFrame.new(position))
        task.wait(0.05)
        remoteEventsAuto.StopDraggingItem:FireServer(item)
    end)
end

-- === UI INITIALIZATION ===
local autofarmss = autofarmss or main

local function createDropdownWithCheckboxes(title, itemList, enabledTable)
    local dropdown = autofarmss:CreateDropDown(title)
    for _, itemName in ipairs(itemList) do
        dropdown:AddCheckbox(itemName, function(checked)
            enabledTable[itemName] = checked
        end)
    end
    dropdown:AddCheckbox("Bulk (All)", function(checked)
        for _, itemName in ipairs(itemList) do
            enabledTable[itemName] = checked
        end
    end)
    return dropdown
end

createDropdownWithCheckboxes("Auto Feed Campfire (ignores HP)", campfireFuelItems, alwaysFeedEnabledItems)
createDropdownWithCheckboxes("Auto Feed Campfire (HP Based)", campfireFuelItems, autoFuelEnabledItems)
createDropdownWithCheckboxes("Auto Cook Food", autocookItems, autoCookEnabledItems)
createDropdownWithCheckboxes("Auto Machine Grind", autoGrindItems, autoGrindEnabledItems)
createDropdownWithCheckboxes("Auto Biofuel Processor", biofuelItems, autoBiofuelEnabledItems)

-- Auto Eat
local eatDropdown = autofarmss:CreateDropDown("Auto Eat (3 sec interval)")
eatDropdown:AddCheckbox("Enable Auto Eat", function(checked)
    autoEatEnabled = checked
end)

-- Auto Eat HP Based
local eatHPDropdown = autofarmss:CreateDropDown("Auto Eat (HP Bar Based)")
eatHPDropdown:AddCheckbox("Enable Auto Eat (HP Bar Based)", function(checked)
    local autoEatHPEnabled = checked
end)

-- === BACKGROUND COROUTINES ===
coroutine.wrap(function() -- Always Feed Campfire
    while true do
        for itemName, enabled in pairs(alwaysFeedEnabledItems) do
            if enabled then
                for _, item in ipairs(itemsFolder:GetChildren()) do
                    if item.Name == itemName then
                        moveItemToPos(item, campfireDropPos)
                    end
                end
            end
        end
        task.wait(2)
    end
end)()

coroutine.wrap(function() -- HP-Based Feed
    local campfire = workspace:WaitForChild("Map"):WaitForChild("Campground"):WaitForChild("MainFire")
    local fillFrame = campfire.Center.BillboardGui.Frame.Background.Fill
    while true do
        local healthPercent = fillFrame.Size.X.Scale
        if healthPercent < 0.7 then
            repeat
                for itemName, enabled in pairs(autoFuelEnabledItems) do
                    if enabled then
                        for _, item in ipairs(itemsFolder:GetChildren()) do
                            if item.Name == itemName then
                                moveItemToPos(item, campfireDropPos)
                            end
                        end
                    end
                end
                task.wait(0.5)
                healthPercent = fillFrame.Size.X.Scale
            until healthPercent >= 1
        end
        task.wait(2)
    end
end)()

coroutine.wrap(function() -- Auto Cook
    while true do
        for itemName, enabled in pairs(autoCookEnabledItems) do
            if enabled then
                for _, item in ipairs(itemsFolder:GetChildren()) do
                    if item.Name == itemName then
                        moveItemToPos(item, campfireDropPos)
                    end
                end
            end
        end
        task.wait(2.5)
    end
end)()

coroutine.wrap(function() -- Auto Grind
    while true do
        for itemName, enabled in pairs(autoGrindEnabledItems) do
            if enabled then
                for _, item in ipairs(itemsFolder:GetChildren()) do
                    if item.Name == itemName then
                        moveItemToPos(item, machineDropPos)
                    end
                end
            end
        end
        task.wait(2.5)
    end
end)()

coroutine.wrap(function() -- Auto Eat
    while true do
        if autoEatEnabled then
            local available = {}
            for _, item in ipairs(itemsFolder:GetChildren()) do
                if table.find(autoEatFoods, item.Name) then
                    table.insert(available, item)
                end
            end
            if #available > 0 then
                local food = available[math.random(1, #available)]
                pcall(function() remoteConsume:InvokeServer(food) end)
            end
        end
        task.wait(3)
    end
end)()

coroutine.wrap(function() -- Auto Eat HP Bar Based
    local playerInstance = game:GetService("Players").LocalPlayer
    local hungerBar = playerInstance:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("StatBars"):WaitForChild("HungerBar"):WaitForChild("Bar")

    while true do
        local autoEatHPEnabled = false -- controlled by checkbox above
        if autoEatHPEnabled then
            if hungerBar.Size.X.Scale <= 0.5 then
                repeat
                    local currentHunger = hungerBar.Size.X.Scale
                    local available = {}
                    for _, item in ipairs(itemsFolder:GetChildren()) do
                        if item.Name and table.find(autoEatFoods, item.Name) then
                            table.insert(available, item)
                            print("Found available food item: ", item.Name)
                        end
                    end
                    if #available > 0 then
                        local food = available[math.random(1, #available)]
                        if food then
                            pcall(function()
                                remoteConsume:InvokeServer(food)
                            end)
                        end
                    else
                        warn("No available food found in inventory.")
                        break
                    end
                    task.wait(1)
                until hungerBar.Size.X.Scale >= 0.99 or not autoEatHPEnabled
            end
        end
        task.wait(3)
    end
end)()

coroutine.wrap(function() -- Auto Biofuel
    local biofuelProcessorPos
    while true do
        if not biofuelProcessorPos then
            local processor = workspace:FindFirstChild("Structures") and
                workspace.Structures:FindFirstChild("Biofuel Processor")
            local part = processor and processor:FindFirstChild("Part")
            if part then
                biofuelProcessorPos = part.Position + Vector3.new(0, 5, 0)
            end
        end

        if biofuelProcessorPos then
            for itemName, enabled in pairs(autoBiofuelEnabledItems) do
                if enabled then
                    for _, item in ipairs(itemsFolder:GetChildren()) do
                        if item.Name == itemName then
                            moveItemToPos(item, biofuelProcessorPos)
                        end
                    end
                end
            end
        end
        task.wait(2)
    end
end)()

-- === TREE TELEPORT SYSTEM ===
local originalTreeCFrames = {}
local treesBrought = false

local function getAllSmallTrees()
    local trees = {}
    local function scan(folder)
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj.Name == "Small Tree" then
                table.insert(trees, obj)
            end
        end
    end

    local map = workspace:FindFirstChild("Map")
    if map then
        if map:FindFirstChild("Foliage") then scan(map.Foliage) end
        if map:FindFirstChild("Landmarks") then scan(map.Landmarks) end
    end
    return trees
end

local function findTrunk(tree)
    for _, part in ipairs(tree:GetDescendants()) do
        if part:IsA("BasePart") and part.Name == "Trunk" then return part end
    end
end

local function bringAllTrees()
    local target = CFrame.new(rootPart.Position + rootPart.CFrame.LookVector * 10)
    for _, tree in ipairs(getAllSmallTrees()) do
        local trunk = findTrunk(tree)
        if trunk then
            if not originalTreeCFrames[tree] then originalTreeCFrames[tree] = trunk.CFrame end
            tree.PrimaryPart = trunk
            trunk.Anchored = false
            trunk.CanCollide = false
            task.wait()
            tree:SetPrimaryPartCFrame(target + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
            trunk.Anchored = true
        end
    end
    treesBrought = true
end

local function restoreTrees()
    for tree, cframe in pairs(originalTreeCFrames) do
        local trunk = findTrunk(tree)
        if trunk then
            tree.PrimaryPart = trunk
            tree:SetPrimaryPartCFrame(cframe)
            trunk.Anchored = true
            trunk.CanCollide = true
        end
    end
    originalTreeCFrames = {}
    treesBrought = false
end

-- Tree toggle
local miscdropdown = autofarmss:CreateDropDown("Auto Misc Features")
miscdropdown:AddCheckbox("Auto Bring All Small Trees", function(checked)
    autoBreakEnabled = checked
    if checked and not treesBrought then
        bringAllTrees()
    elseif not checked and treesBrought then
        restoreTrees()
    end
end)

-- === AUTO STRONGHOLD ===
local strongholdRunning = true

local function getStrongholdTimerLabel()
    return workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Landmarks")
        and workspace.Map.Landmarks:FindFirstChild("Stronghold")
        and workspace.Map.Landmarks.Stronghold:FindFirstChild("Functional")
        and workspace.Map.Landmarks.Stronghold.Functional:FindFirstChild("Sign")
        and workspace.Map.Landmarks.Stronghold.Functional.Sign:FindFirstChild("SurfaceGui")
        and workspace.Map.Landmarks.Stronghold.Functional.Sign.SurfaceGui:FindFirstChild("Frame")
        and workspace.Map.Landmarks.Stronghold.Functional.Sign.SurfaceGui.Frame:FindFirstChild("Body")
end

local initialLabel = getStrongholdTimerLabel()
local initialText = "Stronghold Timer: " .. tostring(initialLabel and initialLabel.ContentText or "N/A")
local strongholdDropdown = main:CreateDropDown("Stronghold Clients")

local strongholdTimeChecker = main:CreateComment(initialText)

coroutine.wrap(function()
    local lastTimerText = nil
    while strongholdRunning do
        local label = getStrongholdTimerLabel()
        local timerText = "Stronghold Timer: " .. tostring(label and label.ContentText or "N/A")

        if timerText ~= lastTimerText then
            if strongholdTimeChecker.SetText then
                strongholdTimeChecker:SetText(timerText)
            else
                local commentContent = strongholdTimeChecker:FindFirstChild("commentcontent")
                if commentContent then
                    commentContent.Text = timerText
                end
            end
            lastTimerText = timerText
        end
        task.wait(0.5)
    end
end)()

strongholdDropdown:AddButton("Teleport to Stronghold", function()
    local targetPart = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Landmarks")
        and workspace.Map.Landmarks:FindFirstChild("Stronghold")
        and workspace.Map.Landmarks.Stronghold:FindFirstChild("Functional")
        and workspace.Map.Landmarks.Stronghold.Functional:FindFirstChild("EntryDoors")
        and workspace.Map.Landmarks.Stronghold.Functional.EntryDoors:FindFirstChild("DoorRight")
        and workspace.Map.Landmarks.Stronghold.Functional.EntryDoors.DoorRight:FindFirstChild("Model")

    if targetPart then
        local children = targetPart:GetChildren()
        local destination = children[5]

        if destination and destination:IsA("BasePart") then
            local hrp = game.Players.LocalPlayer.Character and
                game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = destination.CFrame + Vector3.new(0, 5, 0)
                print("Teleported to Stronghold DoorRight Model child #5.")
            else
                warn("HumanoidRootPart not found!")
            end
        else
            warn("Child #5 is missing or not a BasePart!")
        end
    else
        warn("DoorRight.Model path not found!")
    end
end)

-- Teleport to Stronghold Diamond Chest
strongholdDropdown:AddButton("Teleport to Diamond Chest", function()
    local items = workspace:FindFirstChild("Items")
    if not items then
        warn("Items folder not found!")
        return
    end

    local chest = items:FindFirstChild("Stronghold Diamond Chest")
    if not chest then
        warn("Stronghold Diamond Chest not found!")
        return
    end

    local chestLid = chest:FindFirstChild("ChestLid")
    if not chestLid then
        warn("ChestLid not found!")
        return
    end

    local diamondchest = chestLid:FindFirstChild("Meshes/diamondchest_Cube.002")
    if not diamondchest then
        warn("Diamond chest mesh not found!")
        return
    end

    local hrp = game.Players.LocalPlayer.Character and
        game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = diamondchest.CFrame + Vector3.new(0, 5, 0)
    else
        warn("HumanoidRootPart not found!")
    end
end)

-- === FIM DO SCRIPT ===
print("99 Nights Script carregado com sucesso!")
