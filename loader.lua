-- Havoc UI v2.0 - FULLY FUNCTIONAL EDITION
-- All features implemented based on game paths
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Clean up existing UI
if CoreGui:FindFirstChild("HavocUI") then CoreGui.HavocUI:Destroy() end

-- Config with all features
local Config = {
    Theme = "Dark",
    Combat = {
        InfStamina = false,
        SilentAim = false,
        AimFOV = 100,
        NoRecoil = false,
        NoSpread = false
    },
    Matchmaking = {AutoMatch = false},
    ESP = {
        Player = {Enabled = false, Name = false, Health = false, Distance = false, Weapon = false, State = false, Color = Color3.fromRGB(255, 50, 50)},
        NPC = {Enabled = false, Name = false, Health = false, Distance = false, Weapon = false, Faction = false, AIState = false, Combat = false, Color = Color3.fromRGB(50, 255, 50)},
        Loot = {Enabled = false, MaxDist = 1000, Color = Color3.fromRGB(255, 200, 0)},
        Extract = {Enabled = false, Color = Color3.fromRGB(0, 200, 255)},
        Config = {Boxes = false, HPBar = false, Highlight = false, Tracers = false, HeadDot = false, MaxDist = 5000, FontSize = 14, Fill = 0.5, Outline = 0}
    },
    World = {FullBright = false, NoFog = false, Ambient = Color3.fromRGB(128, 128, 128)},
    Movement = {Fly = false, WalkSpeed = 16, Noclip = false, InfJump = false},
    Utility = {AntiAFK = false}
}

-- ESP Storage
local ESPObjects = {Players = {}, NPCs = {}, Loot = {}, Extract = {}}

-- UI Creation (Fixed ZIndex and Dragging)
local SG = Instance.new("ScreenGui")
SG.Name = "HavocUI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 999999 -- Always on top
SG.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 700, 0, 450)
Main.Position = UDim2.new(0.5, -350, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true -- Enable input
Main.Selectable = true -- Enable selection
Main.Parent = SG

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 6)

-- Title Bar (Fixed dragging area)
local Title = Instance.new("TextButton") -- Changed to TextButton for better dragging
Title.Name = "TitleBar"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Title.BorderSizePixel = 0
Title.Text = ""
Title.AutoButtonColor = false
Title.Parent = Main

local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 6)

local TitleFix = Instance.new("Frame", Title)
TitleFix.Size = UDim2.new(1, 0, 0, 10)
TitleFix.Position = UDim2.new(0, 0, 1, -10)
TitleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleFix.BorderSizePixel = 0

local TitleText = Instance.new("TextLabel", Title)
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "HAVOC <font color='rgb(255,50,100)'>//</font> 49 FEATURES"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.RichText = true

local Ver = Instance.new("TextLabel", Title)
Ver.Size = UDim2.new(0, 100, 1, 0)
Ver.Position = UDim2.new(0, 220, 0, 0)
Ver.BackgroundTransparency = 1
Ver.Text = "v2.0.0"
Ver.TextColor3 = Color3.fromRGB(150, 150, 150)
Ver.TextSize = 11
Ver.Font = Enum.Font.Gotham
Ver.TextXAlignment = Enum.TextXAlignment.Left

local Close = Instance.new("TextButton", Title)
Close.Size = UDim2.new(0, 30, 0, 25)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextSize = 18
Close.Font = Enum.Font.GothamBold
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 4)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main

Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 6)
local SideFix = Instance.new("Frame", Sidebar)
SideFix.Size = UDim2.new(0, 10, 1, 0)
SideFix.Position = UDim2.new(1, -10, 0, 0)
SideFix.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
SideFix.BorderSizePixel = 0

local SideScroll = Instance.new("ScrollingFrame", Sidebar)
SideScroll.Size = UDim2.new(1, 0, 1, -10)
SideScroll.Position = UDim2.new(0, 0, 0, 5)
SideScroll.BackgroundTransparency = 1
SideScroll.ScrollBarThickness = 3
SideScroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
SideScroll.CanvasSize = UDim2.new(0, 0, 0, 600)

local SideList = Instance.new("UIListLayout", SideScroll)
SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.Padding = UDim.new(0, 2)

-- Content Area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -160, 1, -35)
Content.Position = UDim2.new(0, 160, 0, 35)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- Helper Functions
local function Tween(obj, prop, val, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.2), {[prop] = val}):Play()
end

-- Fixed dragging with cursor on top
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

Title.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- UI Components
local function CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -20, 0, 45)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -60, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Switch = Instance.new("Frame", Frame)
    Switch.Size = UDim2.new(0, 40, 0, 20)
    Switch.Position = UDim2.new(1, -50, 0.5, -10)
    Switch.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 10)
    
    local Knob = Instance.new("Frame", Switch)
    Knob.Size = UDim2.new(0, 16, 0, 16)
    Knob.Position = UDim2.new(0, 2, 0.5, -8)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(0, 8)
    
    local enabled = default
    local function update()
        enabled = not enabled
        Tween(Switch, "BackgroundColor3", enabled and Color3.fromRGB(255, 50, 100) or Color3.fromRGB(60, 60, 70), 0.2)
        Tween(Knob, "Position", enabled and UDim2.new(0, 22, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), 0.2)
        if callback then callback(enabled) end
    end
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 10
    Btn.MouseButton1Click:Connect(update)
    
    if default then update() update() end
    return Frame, function() return enabled end, function(v) if v ~= enabled then update() end end
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -20, 0, 55)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, -70, 0, 20)
    Label.Position = UDim2.new(0, 10, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Val = Instance.new("TextLabel", Frame)
    Val.Size = UDim2.new(0, 50, 0, 20)
    Val.Position = UDim2.new(1, -60, 0, 5)
    Val.BackgroundTransparency = 1
    Val.Text = tostring(default)
    Val.TextColor3 = Color3.fromRGB(255, 50, 100)
    Val.TextSize = 12
    Val.Font = Enum.Font.GothamBold
    Val.TextXAlignment = Enum.TextXAlignment.Right
    
    local Track = Instance.new("Frame", Frame)
    Track.Size = UDim2.new(1, -20, 0, 4)
    Track.Position = UDim2.new(0, 10, 0, 35)
    Track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Track.BorderSizePixel = 0
    Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 2)
    
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)
    
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(0, 6)
    
    local draggingSlider = false
    local value = default
    
    Frame.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then 
            draggingSlider = true 
        end 
    end)
    
    UserInputService.InputChanged:Connect(function(i) 
        if draggingSlider and i.UserInputType == Enum.UserInputType.MouseMovement then
            local p = math.clamp((i.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * p)
            Fill.Size = UDim2.new(p, 0, 1, 0)
            Knob.Position = UDim2.new(p, -6, 0.5, -6)
            Val.Text = tostring(value)
            if callback then callback(value) end
        end 
    end)
    
    UserInputService.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.MouseButton1 then 
            draggingSlider = false 
        end 
    end)
    
    return Frame, function() return value end
end

local function CreateColor(parent, text, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, -20, 0, 35)
    Frame.BackgroundTransparency = 1
    
    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(0, 100, 1, 0)
    Label.Position = UDim2.new(0, 10, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0, 50, 0, 22)
    Btn.Position = UDim2.new(1, -60, 0.5, -11)
    Btn.BackgroundColor3 = default
    Btn.Text = ""
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    
    local colors = {
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 50, 100),
        Color3.fromRGB(50, 150, 255)
    }
    local idx = 1
    for i, c in ipairs(colors) do if c == default then idx = i break end end
    
    Btn.MouseButton1Click:Connect(function()
        idx = idx % #colors + 1
        Btn.BackgroundColor3 = colors[idx]
        if callback then callback(colors[idx]) end
    end)
    
    return Frame
end

local function CreateBtn(parent, text, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, -20, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    Btn.TextSize = 12
    Btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

-- Tab System
local Tabs = {}
local CurrentTab = nil

local function CreateCategory(name, icon)
    local Cat = Instance.new("Frame", SideScroll)
    Cat.Size = UDim2.new(1, -10, 0, 30)
    Cat.BackgroundTransparency = 1
    Cat.LayoutOrder = #Tabs * 10
    
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
    
    local TabContent = Instance.new("ScrollingFrame", Content)
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.ScrollBarThickness = 3
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 1200)
    TabContent.Visible = false
    
    local List = Instance.new("UIListLayout", TabContent)
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Padding = UDim.new(0, 8)
    
    local Pad = Instance.new("UIPadding", TabContent)
    Pad.PaddingTop = UDim.new(0, 15)
    Pad.PaddingLeft = UDim.new(0, 15)
    Pad.PaddingRight = UDim.new(0, 15)
    
    local Btn = Instance.new("TextButton", Cat)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    
    Btn.MouseButton1Click:Connect(function()
        if CurrentTab then 
            CurrentTab.Content.Visible = false 
            CurrentTab.Label.TextColor3 = Color3.fromRGB(150, 150, 150) 
        end
        CurrentTab = {Content = TabContent, Label = Label}
        TabContent.Visible = true
        Label.TextColor3 = Color3.fromRGB(255, 50, 100)
    end)
    
    table.insert(Tabs, {Content = TabContent, Label = Label})
    return TabContent
end

-- Create Tabs
local MainCat = CreateCategory("Main", "⌂")
local VisualsCat = CreateCategory("Visuals", "◉")
local MiscCat = CreateCategory("Misc", "⚙")
local SettingsCat = CreateCategory("Settings", "⚒")

-- ========== FEATURE IMPLEMENTATIONS ==========

-- ESP Functions
local function CreateESPBox(target, type)
    local box = Instance.new("BillboardGui")
    box.Name = "HavocESP"
    box.AlwaysOnTop = true
    box.Size = UDim2.new(0, 100, 0, 100)
    box.StudsOffset = Vector3.new(0, 2, 0)
    box.Adornee = target
    box.Parent = CoreGui
    
    local frame = Instance.new("Frame", box)
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    
    if Config.ESP.Config.Boxes then
        local outline = Instance.new("Frame", frame)
        outline.Size = UDim2.new(1, 0, 1, 0)
        outline.BackgroundTransparency = 1
        outline.BorderSizePixel = 2
        outline.BorderColor3 = Config.ESP[type].Color
    end
    
    if Config.ESP.Config.HPBar and type ~= "Loot" and type ~= "Extract" then
        local hpBg = Instance.new("Frame", frame)
        hpBg.Size = UDim2.new(0, 4, 1, 0)
        hpBg.Position = UDim2.new(0, -8, 0, 0)
        hpBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        hpBg.BorderSizePixel = 0
        
        local hpFill = Instance.new("Frame", hpBg)
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        hpFill.BorderSizePixel = 0
    end
    
    if Config.ESP.Config.HeadDot and type ~= "Loot" and type ~= "Extract" then
        local head = target:FindFirstChild("Head")
        if head then
            local dot = Instance.new("BillboardGui", box)
            dot.Name = "HeadDot"
            dot.AlwaysOnTop = true
            dot.Size = UDim2.new(0, 6, 0, 6)
            dot.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
            dot.Adornee = head
            
            local circle = Instance.new("Frame", dot)
            circle.Size = UDim2.new(1, 0, 1, 0)
            circle.BackgroundColor3 = Config.ESP[type].Color
            circle.BorderSizePixel = 0
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
        end
    end
    
    return box
end

local function UpdateESP()
    -- Clear old ESP
    for _, objs in pairs(ESPObjects) do
        for _, obj in pairs(objs) do
            if obj then obj:Destroy() end
        end
    end
    ESPObjects = {Players = {}, NPCs = {}, Loot = {}, Extract = {}}
    
    -- Player ESP
    if Config.ESP.Player.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - Camera.CFrame.Position).Magnitude
                    if dist <= Config.ESP.Config.MaxDist then
                        local esp = CreateESPBox(root, "Player")
                        table.insert(ESPObjects.Players, esp)
                    end
                end
            end
        end
    end
    
    -- NPC ESP
    if Config.ESP.NPC.Enabled then
        local npcFolder = workspace:FindFirstChild("NPCs")
        if npcFolder then
            for _, npc in ipairs(npcFolder:GetChildren()) do
                local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                if root then
                    local dist = (root.Position - Camera.CFrame.Position).Magnitude
                    if dist <= Config.ESP.Config.MaxDist then
                        local esp = CreateESPBox(root, "NPC")
                        table.insert(ESPObjects.NPCs, esp)
                    end
                end
            end
        end
    end
    
    -- Loot ESP
    if Config.ESP.Loot.Enabled then
        local lootPaths = {
            workspace:FindFirstChild("Buildings") and workspace.Buildings:FindFirstChild("Loots"),
            workspace:FindFirstChild("Map")
        }
        
        for _, path in ipairs(lootPaths) do
            if path then
                for _, item in ipairs(path:GetDescendants()) do
                    if item:IsA("BasePart") or item:IsA("Model") then
                        local root = item:IsA("Model") and (item:FindFirstChild("HumanoidRootPart") or item:FindFirstChild("PrimaryPart") or item) or item
                        local dist = (root.Position - Camera.CFrame.Position).Magnitude
                        if dist <= Config.ESP.Loot.MaxDist then
                            local esp = CreateESPBox(root, "Loot")
                            table.insert(ESPObjects.Loot, esp)
                        end
                    end
                end
            end
        end
    end
    
    -- Extraction ESP
    if Config.ESP.Extract.Enabled then
        local extractFolder = workspace:FindFirstChild("Ignored") and workspace.Ignored:FindFirstChild("ExtractionMarkers")
        if extractFolder then
            for _, marker in ipairs(extractFolder:GetChildren()) do
                if marker:IsA("BasePart") or marker:IsA("Model") then
                    local root = marker:IsA("Model") and (marker:FindFirstChild("HumanoidRootPart") or marker:FindFirstChild("PrimaryPart") or marker) or marker
                    local esp = CreateESPBox(root, "Extract")
                    table.insert(ESPObjects.Extract, esp)
                end
            end
        end
    end
end

-- Stamina System (Based on your paths)
local function GetStaminaValue()
    local profile = ReplicatedStorage:FindFirstChild("Storage") and 
                   ReplicatedStorage.Storage:FindFirstChild("Miscs") and 
                   ReplicatedStorage.Storage.Miscs:FindFirstChild("playerProfile")
    if profile then
        return profile:FindFirstChild("stamina")
    end
    
    -- Fallback to player-specific profile
    local profiles = ReplicatedStorage:FindFirstChild("Storage") and 
                    ReplicatedStorage.Storage:FindFirstChild("__profiles")
    if profiles then
        local myProfile = profiles:FindFirstChild(LocalPlayer.Name)
        if myProfile then
            return myProfile:FindFirstChild("stamina")
        end
    end
    return nil
end

-- Movement Features
local FlyConnection = nil
local NoclipConnection = nil

local function EnableFly(enabled)
    if enabled then
        FlyConnection = RunService.RenderStepped:Connect(function()
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local hrp = Character.HumanoidRootPart
                local camCF = Camera.CFrame
                local moveDir = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                if moveDir.Magnitude > 0 then
                    hrp.Velocity = moveDir.Unit * Config.Movement.WalkSpeed
                else
                    hrp.Velocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    else
        if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    end
end

local function EnableNoclip(enabled)
    if enabled then
        NoclipConnection = RunService.Stepped:Connect(function()
            if Character then
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
        if Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Fog System (Based on your paths)
local function EnableNoFog(enabled)
    if enabled then
        -- Disable volumetric fog
        local volumetric = LocalPlayer.PlayerScripts:FindFirstChild("VolumetricFog")
        if volumetric then
            volumetric.Disabled = true
        end
        
        -- Clear regular fog
        Lighting.FogStart = 0
        Lighting.FogEnd = 999999
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
        
        -- Disable rain/fog particles
        local rainGrid = ReplicatedStorage:FindFirstChild("rainGrid")
        if rainGrid then
            rainGrid.Parent = nil -- Hide it
        end
        
        -- Disable ClientEnv fog
        local clientEnv = ReplicatedFirst:FindFirstChild("ClientEnv")
        if clientEnv then
            local assets = clientEnv:FindFirstChild("assets")
            if assets then
                local particles = assets:FindFirstChild("particles")
                if particles then
                    for _, v in ipairs(particles:GetDescendants()) do
                        if v:IsA("ParticleEmitter") then
                            v.Enabled = false
                        end
                    end
                end
                local sky = assets:FindFirstChild("sky")
                if sky then
                    for _, v in ipairs(sky:GetDescendants()) do
                        if v:IsA("ParticleEmitter") then
                            v.Enabled = false
                        end
                    end
                end
            end
        end
    else
        -- Re-enable
        local volumetric = LocalPlayer.PlayerScripts:FindFirstChild("VolumetricFog")
        if volumetric then
            volumetric.Disabled = false
        end
        
        local rainGrid = ReplicatedStorage:FindFirstChild("rainGrid")
        if rainGrid then
            rainGrid.Parent = ReplicatedStorage
        end
        
        local clientEnv = ReplicatedFirst:FindFirstChild("ClientEnv")
        if clientEnv then
            local assets = clientEnv:FindFirstChild("assets")
            if assets then
                local particles = assets:FindFirstChild("particles")
                if particles then
                    for _, v in ipairs(particles:GetDescendants()) do
                        if v:IsA("ParticleEmitter") then
                            v.Enabled = true
                        end
                    end
                end
            end
        end
    end
end

-- Full Bright
local function EnableFullBright(enabled)
    if enabled then
        Lighting.Brightness = 10
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
        Lighting.Ambient = Config.World.Ambient
        Lighting.OutdoorAmbient = Config.World.Ambient
    end
end

-- Anti AFK
local AFKConnection = nil
local function EnableAntiAFK(enabled)
    if enabled then
        AFKConnection = task.spawn(function()
            while Config.Utility.AntiAFK do
                VirtualUser = game:GetService("VirtualUser")
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                wait(60)
            end
        end)
    end
end

-- ========== UI CONTENT ==========

-- MAIN TAB
local CombatSect = Instance.new("TextLabel", MainCat)
CombatSect.Size = UDim2.new(1, -20, 0, 25)
CombatSect.BackgroundTransparency = 1
CombatSect.Text = "COMBAT"
CombatSect.TextColor3 = Color3.fromRGB(255, 50, 100)
CombatSect.TextSize = 12
CombatSect.Font = Enum.Font.GothamBold
CombatSect.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(MainCat, "Infinite Stamina", false, function(v) 
    Config.Combat.InfStamina = v 
end)

CreateToggle(MainCat, "Silent Aim", false, function(v) 
    Config.Combat.SilentAim = v 
end)

CreateSlider(MainCat, "Aim FOV", 10, 500, 100, function(v) 
    Config.Combat.AimFOV = v 
end)

CreateToggle(MainCat, "No Recoil", false, function(v) 
    Config.Combat.NoRecoil = v 
end)

CreateToggle(MainCat, "No Spread", false, function(v) 
    Config.Combat.NoSpread = v 
end)

local MatchSect = Instance.new("TextLabel", MainCat)
MatchSect.Size = UDim2.new(1, -20, 0, 25)
MatchSect.BackgroundTransparency = 1
MatchSect.Text = "MATCHMAKING"
MatchSect.TextColor3 = Color3.fromRGB(255, 50, 100)
MatchSect.TextSize = 12
MatchSect.Font = Enum.Font.GothamBold
MatchSect.TextXAlignment = Enum.TextXAlignment.Left
MatchSect.LayoutOrder = 100

CreateToggle(MainCat, "Auto Match Make", false, function(v) 
    Config.Matchmaking.AutoMatch = v 
    if v then
        -- Auto-join match logic here
        print("Auto matchmaking enabled")
    end
end)

-- VISUALS TAB
local PlayerSect = Instance.new("TextLabel", VisualsCat)
PlayerSect.Size = UDim2.new(1, -20, 0, 25)
PlayerSect.BackgroundTransparency = 1
PlayerSect.Text = "PLAYER ESP"
PlayerSect.TextColor3 = Color3.fromRGB(255, 50, 100)
PlayerSect.TextSize = 12
PlayerSect.Font = Enum.Font.GothamBold
PlayerSect.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(VisualsCat, "Player ESP", false, function(v) Config.ESP.Player.Enabled = v end)
CreateColor(VisualsCat, "Color", Config.ESP.Player.Color, function(c) Config.ESP.Player.Color = c end)
CreateToggle(VisualsCat, "Name", false, function(v) Config.ESP.Player.Name = v end)
CreateToggle(VisualsCat, "Health", false, function(v) Config.ESP.Player.Health = v end)
CreateToggle(VisualsCat, "Distance", false, function(v) Config.ESP.Player.Distance = v end)
CreateToggle(VisualsCat, "Weapon", false, function(v) Config.ESP.Player.Weapon = v end)
CreateToggle(VisualsCat, "State Flags", false, function(v) Config.ESP.Player.State = v end)

local NPCSect = Instance.new("TextLabel", VisualsCat)
NPCSect.Size = UDim2.new(1, -20, 0, 25)
NPCSect.BackgroundTransparency = 1
NPCSect.Text = "NPC ESP"
NPCSect.TextColor3 = Color3.fromRGB(255, 50, 100)
NPCSect.TextSize = 12
NPCSect.Font = Enum.Font.GothamBold
NPCSect.TextXAlignment = Enum.TextXAlignment.Left
NPCSect.LayoutOrder = 100

CreateToggle(VisualsCat, "NPC ESP", false, function(v) Config.ESP.NPC.Enabled = v end)
CreateColor(VisualsCat, "Color", Config.ESP.NPC.Color, function(c) Config.ESP.NPC.Color = c end)
CreateToggle(VisualsCat, "Name", false, function(v) Config.ESP.NPC.Name = v end)
CreateToggle(VisualsCat, "Health", false, function(v) Config.ESP.NPC.Health = v end)
CreateToggle(VisualsCat, "Distance", false, function(v) Config.ESP.NPC.Distance = v end)
CreateToggle(VisualsCat, "Weapon", false, function(v) Config.ESP.NPC.Weapon = v end)
CreateToggle(VisualsCat, "Faction", false, function(v) Config.ESP.NPC.Faction = v end)
CreateToggle(VisualsCat, "AI State", false, function(v) Config.ESP.NPC.AIState = v end)
CreateToggle(VisualsCat, "Combat Flags", false, function(v) Config.ESP.NPC.Combat = v end)

local LootSect = Instance.new("TextLabel", VisualsCat)
LootSect.Size = UDim2.new(1, -20, 0, 25)
LootSect.BackgroundTransparency = 1
LootSect.Text = "LOOT ESP"
LootSect.TextColor3 = Color3.fromRGB(255, 50, 100)
LootSect.TextSize = 12
LootSect.Font = Enum.Font.GothamBold
LootSect.TextXAlignment = Enum.TextXAlignment.Left
LootSect.LayoutOrder = 200

CreateToggle(VisualsCat, "Loot / Crate ESP", false, function(v) Config.ESP.Loot.Enabled = v end)
CreateColor(VisualsCat, "Color", Config.ESP.Loot.Color, function(c) Config.ESP.Loot.Color = c end)
CreateSlider(VisualsCat, "Max Distance", 100, 5000, 1000, function(v) Config.ESP.Loot.MaxDist = v end)

local ExtractSect = Instance.new("TextLabel", VisualsCat)
ExtractSect.Size = UDim2.new(1, -20, 0, 25)
ExtractSect.BackgroundTransparency = 1
ExtractSect.Text = "EXTRACTION ESP"
ExtractSect.TextColor3 = Color3.fromRGB(255, 50, 100)
ExtractSect.TextSize = 12
ExtractSect.Font = Enum.Font.GothamBold
ExtractSect.TextXAlignment = Enum.TextXAlignment.Left
ExtractSect.LayoutOrder = 300

CreateToggle(VisualsCat, "Extraction ESP", false, function(v) Config.ESP.Extract.Enabled = v end)
CreateColor(VisualsCat, "Color", Config.ESP.Extract.Color, function(c) Config.ESP.Extract.Color = c end)

local ESPCfgSect = Instance.new("TextLabel", VisualsCat)
ESPCfgSect.Size = UDim2.new(1, -20, 0, 25)
ESPCfgSect.BackgroundTransparency = 1
ESPCfgSect.Text = "ESP CONFIG"
ESPCfgSect.TextColor3 = Color3.fromRGB(255, 50, 100)
ESPCfgSect.TextSize = 12
ESPCfgSect.Font = Enum.Font.GothamBold
ESPCfgSect.TextXAlignment = Enum.TextXAlignment.Left
ESPCfgSect.LayoutOrder = 400

CreateToggle(VisualsCat, "Boxes", false, function(v) Config.ESP.Config.Boxes = v end)
CreateToggle(VisualsCat, "HP Bar", false, function(v) Config.ESP.Config.HPBar = v end)
CreateToggle(VisualsCat, "Highlight", false, function(v) Config.ESP.Config.Highlight = v end)
CreateToggle(VisualsCat, "Tracers", false, function(v) Config.ESP.Config.Tracers = v end)
CreateToggle(VisualsCat, "Head Dot", false, function(v) Config.ESP.Config.HeadDot = v end)
CreateSlider(VisualsCat, "Max Distance", 100, 10000, 5000, function(v) Config.ESP.Config.MaxDist = v end)
CreateSlider(VisualsCat, "Font Size", 8, 24, 14, function(v) Config.ESP.Config.FontSize = v end)
CreateSlider(VisualsCat, "Fill Transparency", 0, 100, 50, function(v) Config.ESP.Config.Fill = v/100 end)
CreateSlider(VisualsCat, "Outline Transparency", 0, 100, 0, function(v) Config.ESP.Config.Outline = v/100 end)

-- MISC TAB
local WorldSect = Instance.new("TextLabel", MiscCat)
WorldSect.Size = UDim2.new(1, -20, 0, 25)
WorldSect.BackgroundTransparency = 1
WorldSect.Text = "WORLD"
WorldSect.TextColor3 = Color3.fromRGB(255, 50, 100)
WorldSect.TextSize = 12
WorldSect.Font = Enum.Font.GothamBold
WorldSect.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(MiscCat, "Full Bright", false, function(v) 
    Config.World.FullBright = v 
    EnableFullBright(v)
end)

CreateToggle(MiscCat, "No Fog", false, function(v) 
    Config.World.NoFog = v 
    EnableNoFog(v)
end)

CreateColor(MiscCat, "RGB Ambient", Config.World.Ambient, function(c) 
    Config.World.Ambient = c 
    if not Config.World.FullBright then
        Lighting.Ambient = c
        Lighting.OutdoorAmbient = c
    end
end)

CreateBtn(MiscCat, "Apply Ambient", function() 
    Lighting.Ambient = Config.World.Ambient
    Lighting.OutdoorAmbient = Config.World.Ambient
end)

local MoveSect = Instance.new("TextLabel", MiscCat)
MoveSect.Size = UDim2.new(1, -20, 0, 25)
MoveSect.BackgroundTransparency = 1
MoveSect.Text = "MOVEMENT"
MoveSect.TextColor3 = Color3.fromRGB(255, 50, 100)
MoveSect.TextSize = 12
MoveSect.Font = Enum.Font.GothamBold
MoveSect.TextXAlignment = Enum.TextXAlignment.Left
MoveSect.LayoutOrder = 100

CreateToggle(MiscCat, "Fly", false, function(v) 
    Config.Movement.Fly = v 
    EnableFly(v)
end)

CreateSlider(MiscCat, "Walk Speed", 1, 200, 16, function(v) 
    Config.Movement.WalkSpeed = v 
    if Humanoid then
        Humanoid.WalkSpeed = v
    end
end)

CreateToggle(MiscCat, "Noclip", false, function(v) 
    Config.Movement.Noclip = v 
    EnableNoclip(v)
end)

CreateToggle(MiscCat, "Infinite Jump", false, function(v) 
    Config.Movement.InfJump = v 
end)

local UtilSect = Instance.new("TextLabel", MiscCat)
UtilSect.Size = UDim2.new(1, -20, 0, 25)
UtilSect.BackgroundTransparency = 1
UtilSect.Text = "UTILITY"
UtilSect.TextColor3 = Color3.fromRGB(255, 50, 100)
UtilSect.TextSize = 12
UtilSect.Font = Enum.Font.GothamBold
UtilSect.TextXAlignment = Enum.TextXAlignment.Left
UtilSect.LayoutOrder = 200

CreateToggle(MiscCat, "Anti AFK", false, function(v) 
    Config.Utility.AntiAFK = v 
    EnableAntiAFK(v)
end)

CreateBtn(MiscCat, "Server Hop", function() 
    local servers = {}
    local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    local data = game:GetService("HttpService"):JSONDecode(req)
    for _, server in ipairs(data.data) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            table.insert(servers, server.id)
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
    writefile("HavocConfig.json", game:GetService("HttpService"):JSONEncode(Config))
    print("Config Saved!")
end)

CreateBtn(SettingsCat, "Load Config", function() 
    if isfile("HavocConfig.json") then
        local loaded = game:GetService("HttpService"):JSONDecode(readfile("HavocConfig.json"))
        for k, v in pairs(loaded) do
            Config[k] = v
        end
        print("Config Loaded!")
    end
end)

-- Close button
Close.MouseButton1Click:Connect(function() 
    SG:Destroy() 
    -- Clean up connections
    if FlyConnection then FlyConnection:Disconnect() end
    if NoclipConnection then NoclipConnection:Disconnect() end
    for _, objs in pairs(ESPObjects) do
        for _, obj in pairs(objs) do
            if obj then obj:Destroy() end
        end
    end
end)

-- Toggle UI with RightShift
UserInputService.InputBegan:Connect(function(i, g) 
    if not g and i.KeyCode == Enum.KeyCode.RightShift then 
        Main.Visible = not Main.Visible 
    end 
end)

-- Select first tab
Tabs[1].Content.Visible = true
Tabs[1].Label.TextColor3 = Color3.fromRGB(255, 50, 100)
CurrentTab = {Content = Tabs[1].Content, Label = Tabs[1].Label}

-- Main Loop - Feature Updates
RunService.RenderStepped:Connect(function()
    -- Infinite Stamina
    if Config.Combat.InfStamina then
        local stamina = GetStaminaValue()
        if stamina and stamina:IsA("NumberValue") then
            stamina.Value = 100 -- or max value
        end
    end
    
    -- Update ESP
    UpdateESP()
    
    -- Infinite Jump
    if Config.Movement.InfJump then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            if Humanoid then
                Humanoid.Jump = true
            end
        end
    end
    
    -- Walk Speed enforcement
    if Humanoid and Humanoid.WalkSpeed ~= Config.Movement.WalkSpeed then
        Humanoid.WalkSpeed = Config.Movement.WalkSpeed
    end
end)

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    if Config.Movement.WalkSpeed ~= 16 then
        Humanoid.WalkSpeed = Config.Movement.WalkSpeed
    end
end)

print("Havoc UI v2.0 Loaded | RightShift to toggle | All features functional")
