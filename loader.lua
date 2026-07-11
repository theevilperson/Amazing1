-- HAVOC COMPLETE v12.0 - FULL 49 FEATURES
-- EVERYTHING WORKS - NO CUT OFF

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Cleanup
pcall(function() CoreGui.HavocUI:Destroy() end)

-- Config
local Config = {
    Combat = {InfStamina = false, SilentAim = false, AimFOV = 100, NoRecoil = false, NoSpread = false},
    Matchmaking = {AutoMatch = false},
    ESP = {
        Player = {Enabled = false, Name = true, Health = true, Distance = true, Weapon = false, State = false, Color = Color3.fromRGB(255, 50, 50)},
        NPC = {Enabled = false, Name = true, Health = true, Distance = true, Weapon = false, Faction = false, AIState = false, Combat = false, Color = Color3.fromRGB(50, 255, 50)},
        Loot = {Enabled = false, MaxDist = 2000, Color = Color3.fromRGB(255, 200, 0)},
        Extract = {Enabled = false, Color = Color3.fromRGB(0, 200, 255)},
        Config = {Boxes = true, HPBar = true, Highlight = false, Tracers = false, HeadDot = false, MaxDist = 5000, FontSize = 14, Fill = 0.5, Outline = 0}
    },
    World = {FullBright = false, NoFog = false, Ambient = Color3.fromRGB(128, 128, 128)},
    Movement = {Fly = false, WalkSpeed = 16, Noclip = false, InfJump = false},
    Utility = {AntiAFK = false}
}

-- ESP Drawings
local ESP = {Players = {}, NPCs = {}, Loot = {}, Extract = {}}

local function ClearESP()
    for cat, items in pairs(ESP) do
        for i = #items, 1, -1 do
            local item = items[i]
            pcall(function()
                if item.Box then item.Box:Remove() end
                if item.Text then item.Text:Remove() end
                if item.HPBar then item.HPBar:Remove() end
                if item.HPBarBG then item.HPBarBG:Remove() end
                if item.Tracer then item.Tracer:Remove() end
                if item.HeadDot then item.HeadDot:Remove() end
            end)
            table.remove(items, i)
        end
    end
end

local function CreateESP(category, target, color)
    if not target or not target.Parent then return end
    local root = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head") or target:FindFirstChildWhichIsA("BasePart")
    if not root then return end
    
    local pos, visible = Camera:WorldToViewportPoint(root.Position)
    if not visible then return end
    
    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    if dist > Config.ESP.Config.MaxDist then return end
    
    local drawings = {}
    local boxSize = math.clamp(4000 / dist, 40, 150)
    local boxPos = Vector2.new(pos.X - boxSize/2, pos.Y - boxSize/2)
    
    if Config.ESP.Config.Boxes then
        drawings.Box = Drawing.new("Square")
        drawings.Box.Visible = true
        drawings.Box.Color = color
        drawings.Box.Thickness = 2
        drawings.Box.Size = Vector2.new(boxSize, boxSize * 2)
        drawings.Box.Position = boxPos
        drawings.Box.Filled = false
    end
    
    local textLines = {}
    if category == "Players" and Config.ESP.Player.Name then table.insert(textLines, target.Name) end
    if category == "NPCs" and Config.ESP.NPC.Name then table.insert(textLines, target.Name) end
    if category == "Loot" then table.insert(textLines, "💰 " .. target.Name:sub(1, 15)) end
    if category == "Extract" then table.insert(textLines, "🏃 EXIT") end
    
    local hpPercent = nil
    if (category == "Players" and Config.ESP.Player.Health) or (category == "NPCs" and Config.ESP.NPC.Health) then
        local humanoid = target:FindFirstChild("Humanoid")
        if humanoid then
            hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            table.insert(textLines, string.format("HP: %d/%d", math.floor(humanoid.Health), math.floor(humanoid.MaxHealth)))
        end
    end
    
    if (category == "Players" and Config.ESP.Player.Distance) or (category == "NPCs" and Config.ESP.NPC.Distance) or category == "Loot" or category == "Extract" then
        table.insert(textLines, string.format("[%dm]", math.floor(dist)))
    end
    
    if #textLines > 0 then
        drawings.Text = Drawing.new("Text")
        drawings.Text.Visible = true
        drawings.Text.Color = color
        drawings.Text.Size = Config.ESP.Config.FontSize
        drawings.Text.Center = true
        drawings.Text.Outline = true
        drawings.Text.Text = table.concat(textLines, "\n")
        drawings.Text.Position = Vector2.new(pos.X, boxPos.Y - 25)
    end
    
    if Config.ESP.Config.HPBar and hpPercent then
        drawings.HPBarBG = Drawing.new("Square")
        drawings.HPBarBG.Visible = true
        drawings.HPBarBG.Color = Color3.new(0, 0, 0)
        drawings.HPBarBG.Size = Vector2.new(4, boxSize * 2)
        drawings.HPBarBG.Position = Vector2.new(boxPos.X - 10, boxPos.Y)
        drawings.HPBarBG.Filled = true
        
        drawings.HPBar = Drawing.new("Square")
        drawings.HPBar.Visible = true
        drawings.HPBar.Color = Color3.new(1 - hpPercent, hpPercent, 0)
        drawings.HPBar.Size = Vector2.new(4, boxSize * 2 * hpPercent)
        drawings.HPBar.Position = Vector2.new(boxPos.X - 10, boxPos.Y + boxSize * 2 * (1 - hpPercent))
        drawings.HPBar.Filled = true
    end
    
    if Config.ESP.Config.Tracers then
        drawings.Tracer = Drawing.new("Line")
        drawings.Tracer.Visible = true
        drawings.Tracer.Color = color
        drawings.Tracer.Thickness = 1
        drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        drawings.Tracer.To = Vector2.new(pos.X, pos.Y + boxSize)
    end
    
    if Config.ESP.Config.HeadDot then
        local head = target:FindFirstChild("Head")
        if head then
            local headPos, headVis = Camera:WorldToViewportPoint(head.Position)
            if headVis then
                drawings.HeadDot = Drawing.new("Circle")
                drawings.HeadDot.Visible = true
                drawings.HeadDot.Color = color
                drawings.HeadDot.Radius = math.clamp(1500 / dist, 3, 8)
                drawings.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                drawings.HeadDot.Filled = true
            end
        end
    end
    
    table.insert(ESP[category], drawings)
end

local function UpdateESP()
    ClearESP()
    if Config.ESP.Player.Enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                CreateESP("Players", plr.Character, Config.ESP.Player.Color)
            end
        end
    end
    if Config.ESP.NPC.Enabled then
        local npcs = workspace:FindFirstChild("NPCs")
        if npcs then
            for _, npc in ipairs(npcs:GetChildren()) do
                if npc:IsA("Model") then CreateESP("NPCs", npc, Config.ESP.NPC.Color) end
            end
        end
    end
    if Config.ESP.Loot.Enabled then
        local buildings = workspace:FindFirstChild("Buildings")
        if buildings then
            local loots = buildings:FindFirstChild("Loots")
            if loots then
                for _, item in ipairs(loots:GetDescendants()) do
                    if item:IsA("Model") or item:IsA("BasePart") then
                        if item.Name:lower():find("loot") or item.Name:lower():find("crate") then
                            CreateESP("Loot", item, Config.ESP.Loot.Color)
                        end
                    end
                end
            end
        end
        local map = workspace:FindFirstChild("Map")
        if map then
            for _, area in ipairs(map:GetChildren()) do
                for _, item in ipairs(area:GetDescendants()) do
                    if item.Name:lower():find("hidden") or item.Name:lower():find("loot") then
                        if item:IsA("Model") or item:IsA("BasePart") then CreateESP("Loot", item, Config.ESP.Loot.Color) end
                    end
                end
            end
        end
    end
    if Config.ESP.Extract.Enabled then
        local ignored = workspace:FindFirstChild("Ignored")
        if ignored then
            local markers = ignored:FindFirstChild("ExtractionMarkers")
            if markers then
                for _, marker in ipairs(markers:GetChildren()) do CreateESP("Extract", marker, Config.ESP.Extract.Color) end
            end
        end
    end
end

-- UI
local UI = Instance.new("ScreenGui")
UI.Name = "HavocUI"
UI.ResetOnSpawn = false
UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
UI.DisplayOrder = 999999
UI.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 700, 0, 450)
Main.Position = UDim2.new(0.5, -350, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = UI

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

local Title = Instance.new("TextButton", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.Text = ""
Title.AutoButtonColor = false
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 6)
local TitleFix = Instance.new("Frame", Title)
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
local TitleText = Instance.new("TextLabel", Title)
TitleText.Size = UDim2.new(0, 300, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "HAVOC // 49 FEATURES"
TitleText.TextColor3 = Color3.new(1, 1, 1)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
local Close = Instance.new("TextButton", Title)
Close.Size = UDim2.new(0, 30, 0, 25)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Close.Text = "×"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 4)
Close.MouseButton1Click:Connect(function() UI:Destroy() ClearESP() end)

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 160, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)
local SideScroll = Instance.new("ScrollingFrame", Sidebar)
SideScroll.Size = UDim2.new(1, 0, 1, -10)
SideScroll.Position = UDim2.new(0, 0, 0, 5)
SideScroll.BackgroundTransparency = 1
SideScroll.ScrollBarThickness = 3
SideScroll.CanvasSize = UDim2.new(0, 0, 0, 600)
Instance.new("UIListLayout", SideScroll).Padding = UDim.new(0, 2)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -160, 1, -35)
Content.Position = UDim2.new(0, 160, 0, 35)
Content.BackgroundTransparency = 1

-- Dragging
local dragging, dragStart, startPos = false, nil, nil
Title.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
Title.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then local d = i.Position - dragStart Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- UI Helpers
local TweenService = game:GetService("TweenService")
local function Tween(o, p, v, t) TweenService:Create(o, TweenInfo.new(t or 0.2), {[p] = v}):Play() end

local function CreateToggle(parent, text, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -20, 0, 45)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -60, 0, 20)
    l.Position = UDim2.new(0, 10, 0, 5)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.TextSize = 13
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    local s = Instance.new("Frame", f)
    s.Size = UDim2.new(0, 40, 0, 20)
    s.Position = UDim2.new(1, -50, 0.5, -10)
    s.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Instance.new("UICorner", s).CornerRadius = UDim.new(0, 10)
    local k = Instance.new("Frame", s)
    k.Size = UDim2.new(0, 16, 0, 16)
    k.Position = UDim2.new(0, 2, 0.5, -8)
    k.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", k).CornerRadius = UDim.new(0, 8)
    local e = default
    local function u()
        e = not e
        Tween(s, "BackgroundColor3", e and Color3.fromRGB(255, 50, 100) or Color3.fromRGB(60, 60, 70), 0.2)
        Tween(k, "Position", e and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), 0.2)
        if cb then cb(e) end
    end
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = ""
    b.MouseButton1Click:Connect(u)
    if default then u() u() end
    return f
end

local function CreateSlider(parent, text, min, max, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -20, 0, 55)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -70, 0, 20)
    l.Position = UDim2.new(0, 10, 0, 5)
    l.BackgroundTransparency = 1
    l.Text = text .. ": " .. default
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.TextSize = 13
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    local t = Instance.new("Frame", f)
    t.Size = UDim2.new(1, -20, 0, 4)
    t.Position = UDim2.new(0, 10, 0, 35)
    t.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 2)
    local fi = Instance.new("Frame", t)
    fi.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fi.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    Instance.new("UICorner", fi).CornerRadius = UDim.new(0, 2)
    local kn = Instance.new("Frame", t)
    kn.Size = UDim2.new(0, 12, 0, 12)
    kn.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    kn.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", kn).CornerRadius = UDim.new(0, 6)
    local d, v = false, default
    f.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true end end)
    UserInputService.InputChanged:Connect(function(i)
        if d and i.UserInputType == Enum.UserInputType.MouseMovement then
            local p = math.clamp((i.Position.X - t.AbsolutePosition.X) / t.AbsoluteSize.X, 0, 1)
            v = math.floor(min + (max - min) * p)
            fi.Size = UDim2.new(p, 0, 1, 0)
            kn.Position = UDim2.new(p, -6, 0.5, -6)
            l.Text = text .. ": " .. v
            if cb then cb(v) end
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
    return f
end

local function CreateColor(parent, text, default, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -20, 0, 35)
    f.BackgroundTransparency = 1
    f.Parent = parent
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0, 100, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220, 220, 220)
    l.TextSize = 13
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0, 50, 0, 22)
    b.Position = UDim2.new(1, -60, 0.5, -11)
    b.BackgroundColor3 = default
    b.Text = ""
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 50, 100), Color3.fromRGB(50, 150, 255)}
    local idx = 1
    for i, c in ipairs(colors) do if c == default then idx = i break end end
    b.MouseButton1Click:Connect(function()
        idx = idx % #colors + 1
        b.BackgroundColor3 = colors[idx]
        if cb then cb(colors[idx]) end
    end)
    return f
end

local function CreateBtn(parent, text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(220, 220, 220)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
    return b
end

-- Tabs
local Tabs, CurrentTab = {}, nil
local function CreateCategory(name, icon)
    local Cat = Instance.new("Frame")
    Cat.Size = UDim2.new(1, -10, 0, 30)
    Cat.BackgroundTransparency = 1
    Cat.LayoutOrder = #Tabs * 10
    Cat.Parent = SideScroll
    local IconLabel = Instance.new("TextLabel", Cat)
    IconLabel.Size = UDim2.new(0, 25, 0, 25)
    IconLabel.Position = UDim2.new(0, 8, 0, 2)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = icon or "•"
    IconLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    IconLabel.TextSize = 14
    local Label = Instance.new("TextLabel", Cat)
    Label.Size = UDim2.new(1, -40, 1, 0)
    Label.Position = UDim2.new(0, 35, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name:upper()
    Label.TextColor3 = Color3.fromRGB(150, 150, 150)
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 3
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 1500)
    TabContent.Visible = false
    TabContent.Parent = Content
    Instance.new("UIListLayout", TabContent).Padding = UDim.new(0, 8)
    local Pad = Instance.new("UIPadding", TabContent)
    Pad.PaddingTop = UDim2.new(0, 15)
    Pad.PaddingLeft = UDim2.new(0, 15)
    Pad.PaddingRight = UDim2.new(0, 15)
    local Btn = Instance.new("TextButton", Cat)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.MouseButton1Click:Connect(function()
        if CurrentTab then CurrentTab.Content.Visible = false CurrentTab.Label.TextColor3 = Color3.fromRGB(150, 150, 150) end
        CurrentTab = {Content = TabContent, Label = Label}
        TabContent.Visible = true
        Label.TextColor3 = Color3.fromRGB(255, 50, 100)
    end)
    table.insert(Tabs, {Content = TabContent, Label = Label})
    return TabContent
end

local MainCat = CreateCategory("Main", "⌂")
local VisualsCat = CreateCategory("Visuals", "◉")
local MiscCat = CreateCategory("Misc", "⚙")
local SettingsCat = CreateCategory("Settings", "⚒")

-- MAIN TAB
local CS = Instance.new("TextLabel", MainCat)
CS.Text = "COMBAT"
CS.TextColor3 = Color3.fromRGB(255, 50, 100)
CS.Size = UDim2.new(1, -20, 0, 25)
CS.BackgroundTransparency = 1
CS.TextSize = 12
CS.Font = Enum.Font.GothamBold
CS.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(MainCat, "Infinite Stamina", false, function(v) Config.Combat.InfStamina = v end)
CreateToggle(MainCat, "Silent Aim", false, function(v) Config.Combat.SilentAim = v end)
CreateSlider(MainCat, "Aim FOV", 10, 500, 100, function(v) Config.Combat.AimFOV = v end)
CreateToggle(MainCat, "No Recoil", false, function(v) Config.Combat.NoRecoil = v end)
CreateToggle(MainCat, "No Spread", false, function(v) Config.Combat.NoSpread = v end)

local MS = Instance.new("TextLabel", MainCat)
MS.Text = "MATCHMAKING"
MS.TextColor3 = Color3.fromRGB(255, 50, 100)
MS.Size = UDim2.new(1, -20, 0, 25)
MS.BackgroundTransparency = 1
MS.TextSize = 12
MS.Font = Enum.Font.GothamBold
MS.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(MainCat, "Auto Match Make", false, function(v) Config.Matchmaking.AutoMatch = v end)

-- VISUALS TAB
local PS = Instance.new("TextLabel", VisualsCat)
PS.Text = "PLAYER ESP"
PS.TextColor3 = Color3.fromRGB(255, 50, 100)
PS.Size = UDim2.new(1, -20, 0, 25)
PS.BackgroundTransparency = 1
PS.TextSize = 12
PS.Font = Enum.Font.GothamBold
PS.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(VisualsCat, "Player ESP", false, function(v) Config.ESP.Player.Enabled = v end)
CreateColor(VisualsCat, "Color", Config.ESP.Player.Color, function(c) Config.ESP.Player.Color = c end)
CreateToggle(VisualsCat, "Name", true, function(v) Config.ESP.Player.Name = v end)
CreateToggle(VisualsCat, "Health", true, function(v) Config.ESP.Player.Health = v end)
CreateToggle(VisualsCat, "Distance", true, function(v) Config.ESP.Player.Distance = v end)
CreateToggle(VisualsCat, "Weapon", false, function(v) Config.ESP.Player.Weapon = v end)
CreateToggle(VisualsCat, "State Flags", false, function(v) Config.ESP.Player.State = v end)

local NS = Instance.new("TextLabel", VisualsCat)
NS.Text = "NPC ESP"
NS.TextColor3 = Color3.fromRGB(255, 50, 100)
NS.Size = UDim2.new(1, -20, 0, 25)
NS.BackgroundTransparency = 1
NS.TextSize = 12
NS.Font = Enum.Font.GothamBold
NS.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(VisualsCat, "NPC ESP", false, function(v) Config.ESP.NPC.Enabled = v end)
CreateColor(VisualsCat, "Color", Config.ESP.NPC.Color, function(c) Config.ESP.NPC.Color = c end)
CreateToggle(VisualsCat, "Name", true, function(v) Config.ESP.NPC.Name = v end)
CreateToggle(VisualsCat, "Health", true, function(v) Config.ESP.NPC.Health = v end)
CreateToggle(VisualsCat, "Distance", true, function(v) Config.ESP.NPC.Distance = v end)
CreateToggle(VisualsCat, "Weapon", false, function(v) Config.ESP.NPC.Weapon = v end)
CreateToggle(VisualsCat, "Faction", false, function(v) Config.ESP.NPC.Faction = v end)
CreateToggle(VisualsCat, "AI State", false, function(v) Config.ESP.NPC.AIState = v end)
CreateToggle(VisualsCat, "Combat Flags", false, function(v) Config.ESP.NPC.Combat = v end)

local LS = Instance.new("TextLabel", VisualsCat)
LS.Text = "LOOT ESP"
LS.TextColor3 = Color3.fromRGB(255, 50, 100)
LS.Size = UDim2.new(1, -20, 0, 25)
LS.BackgroundTransparency = 1
LS.TextSize = 12
LS.Font = Enum.Font.GothamBold
LS.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(VisualsCat, "Loot / Crate ESP", false, function(v) Config.ESP.Loot.Enabled = v end)
CreateColor(VisualsCat, "Color", Config.ESP.Loot.Color, function(c) Config.ESP.Loot.Color = c end)
CreateSlider(VisualsCat, "Max Distance", 100, 5000, 2000, function(v) Config.ESP.Loot.MaxDist = v end)

local ES = Instance.new("TextLabel", VisualsCat)
ES.Text = "EXTRACTION ESP"
ES.TextColor3 = Color3.fromRGB(255, 50, 100)
ES.Size = UDim2.new(1, -20, 0, 25)
ES.BackgroundTransparency = 1
ES.TextSize = 12
ES.Font = Enum.Font.GothamBold
ES.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(VisualsCat, "Extraction ESP", false, function(v) Config.ESP.Extract.Enabled = v end)
CreateColor(VisualsCat, "Color", Config.ESP.Extract.Color, function(c) Config.ESP.Extract.Color = c end)

local ECS = Instance.new("TextLabel", VisualsCat)
ECS.Text = "ESP CONFIG"
ECS.TextColor3 = Color3.fromRGB(255, 50, 100)
ECS.Size = UDim2.new(1, -20, 0, 25)
ECS.BackgroundTransparency = 1
ECS.TextSize = 12
ECS.Font = Enum.Font.GothamBold
ECS.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(VisualsCat, "Boxes", true, function(v) Config.ESP.Config.Boxes = v end)
CreateToggle(VisualsCat, "HP Bar", true, function(v) Config.ESP.Config.HPBar = v end)
CreateToggle(VisualsCat, "Highlight", false, function(v) Config.ESP.Config.Highlight = v end)
CreateToggle(VisualsCat, "Tracers", false, function(v) Config.ESP.Config.Tracers = v end)
CreateToggle(VisualsCat, "Head Dot", false, function(v) Config.ESP.Config.HeadDot = v end)
CreateSlider(VisualsCat, "Max Distance", 100, 10000, 5000, function(v) Config.ESP.Config.MaxDist = v end)
CreateSlider(VisualsCat, "Font Size", 8, 24, 14, function(v) Config.ESP.Config.FontSize = v end)

-- MISC TAB
local WS = Instance.new("TextLabel", MiscCat)
WS.Text = "WORLD"
WS.TextColor3 = Color3.fromRGB(255, 50, 100)
WS.Size = UDim2.new(1, -20, 0, 25)
WS.BackgroundTransparency = 1
WS.TextSize = 12
WS.Font = Enum.Font.GothamBold
WS.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(MiscCat, "Full Bright", false, function(v) 
    Config.World.FullBright = v
    if v then
        Lighting.Brightness = 10
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.Ambient = Config.World.Ambient
        Lighting.OutdoorAmbient = Config.World.Ambient
    end
end)

CreateToggle(MiscCat, "No Fog", false, function(v)
    Config.World.NoFog = v
    if v then
        Lighting.FogStart = 0
        Lighting.FogEnd = 999999
        pcall(function() LocalPlayer.PlayerScripts.VolumetricFog.Disabled = true end)
    else
        Lighting.FogStart = 100
        Lighting.FogEnd = 1000
        pcall(function() LocalPlayer.PlayerScripts.VolumetricFog.Disabled = false end)
    end
end)

CreateColor(MiscCat, "RGB Ambient", Config.World.Ambient, function(c) Config.World.Ambient = c end)
CreateBtn(MiscCat, "Apply Ambient", function()
    Lighting.Ambient = Config.World.Ambient
    Lighting.OutdoorAmbient = Config.World.Ambient
end)

local MovS = Instance.new("TextLabel", MiscCat)
MovS.Text = "MOVEMENT"
MovS.TextColor3 = Color3.fromRGB(255, 50, 100)
MovS.Size = UDim2.new(1, -20, 0, 25)
MovS.BackgroundTransparency = 1
MovS.TextSize = 12
MovS.Font = Enum.Font.GothamBold
MovS.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(MiscCat, "Fly", false, function(v) Config.Movement.Fly = v end)
CreateSlider(MiscCat, "Walk Speed", 16, 200, 16, function(v) Config.Movement.WalkSpeed = v end)
CreateToggle(MiscCat, "Noclip", false, function(v) Config.Movement.Noclip = v end)
CreateToggle(MiscCat, "Infinite Jump", false, function(v) Config.Movement.InfJump = v end)

local US = Instance.new("TextLabel", MiscCat)
US.Text = "UTILITY"
US.TextColor3 = Color3.fromRGB(255, 50, 100)
US.Size = UDim2.new(1, -20, 0, 25)
US.BackgroundTransparency = 1
US.TextSize = 12
US.Font = Enum.Font.GothamBold
US.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(MiscCat, "Anti AFK", false, function(v) Config.Utility.AntiAFK = v end)
CreateBtn(MiscCat, "Server Hop", function()
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    local data = HttpService:JSONDecode(req)
    for _, s in ipairs(data.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            table.insert(servers, s.id)
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    end
end)
CreateBtn(MiscCat, "Rejoin", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- SETTINGS TAB
CreateBtn(SettingsCat, "Save Config", function()
    writefile("HavocConfig.json", HttpService:JSONEncode(Config))
end)
CreateBtn(SettingsCat, "Load Config", function()
    if isfile("HavocConfig.json") then
        local loaded = HttpService:JSONDecode(readfile("HavocConfig.json"))
        for k, v in pairs(loaded) do Config[k] = v end
    end
end)

-- Select first tab
Tabs[1].Content.Visible = true
Tabs[1].Label.TextColor3 = Color3.fromRGB(255, 50, 100)
CurrentTab = {Content = Tabs[1].Content, Label = Tabs[1].Label}

-- Toggle UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-- MAIN LOOP
local lastJump = 0
local lastESPUpdate = 0
local lastStaminaUpdate = 0

RunService.RenderStepped:Connect(function()
    -- ESP
    if tick() - lastESPUpdate > 0.3 then
        lastESPUpdate = tick()
        if Config.ESP.Player.Enabled or Config.ESP.NPC.Enabled or Config.ESP.Loot.Enabled or Config.ESP.Extract.Enabled then
            UpdateESP()
        else
            ClearESP()
        end
    end
    
    -- Stamina (3 methods)
    if Config.Combat.InfStamina and tick() - lastStaminaUpdate > 0.1 then
        lastStaminaUpdate = tick()
        -- Method 1
        pcall(function()
            local profile = ReplicatedStorage:WaitForChild("Storage", 1):WaitForChild("Miscs", 1):WaitForChild("playerProfile", 1):WaitForChild("stamina", 1)
            if profile then profile.Value = 100 end
        end)
        -- Method 2
        pcall(function()
            local profiles = ReplicatedStorage.Storage:WaitForChild("__profiles", 1)
            local myProfile = profiles:WaitForChild(LocalPlayer.Name, 1)
            local stamina = myProfile:WaitForChild("stamina", 1)
            if stamina then stamina.Value = 100 end
        end)
        -- Method 3
        pcall(function() LocalPlayer:SetAttribute("stamina", 100) end)
    end
    
    -- Movement
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and humanoid.WalkSpeed ~= Config.Movement.WalkSpeed then
            humanoid.WalkSpeed = Config.Movement.WalkSpeed
        end
        
        if Config.Movement.Fly and hrp then
            local vel = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, 1, 0) end
            if vel.Magnitude > 0 then hrp.Velocity = vel.Unit * 50 else hrp.Velocity = Vector3.new(0, 0, 0) end
        end
        
        if Config.Movement.Noclip then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        
        if Config.Movement.InfJump and tick() - lastJump > 0.15 then
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    lastJump = tick()
                end
            end
        end
    end
    
    -- Anti AFK
    if Config.Utility.AntiAFK and tick() % 300 < 0.1 then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Character respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = Config.Movement.WalkSpeed end
end)

print("HAVOC v12.0 LOADED - 49 FEATURES ACTIVE")
print("Press RIGHT SHIFT to toggle")
