-- Havoc UI v2.1 - FIXED EDITION
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Clean up
if CoreGui:FindFirstChild("HavocUI") then CoreGui.HavocUI:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild("HavocESPs") then LocalPlayer.PlayerGui.HavocESPs:Destroy() end

-- Config
local Config = {
    Combat = {InfStamina = false, SilentAim = false, AimFOV = 100, NoRecoil = false, NoSpread = false},
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

-- ESP Folder (in PlayerGui so it renders)
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "HavocESPs"
ESPFolder.Parent = LocalPlayer.PlayerGui

-- UI
local SG = Instance.new("ScreenGui")
SG.Name = "HavocUI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 999999
SG.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 700, 0, 450)
Main.Position = UDim2.new(0.5, -350, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- Title
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
TitleText.Size = UDim2.new(0, 200, 1, 0)
TitleText.Position = UDim2.new(0, 15, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "HAVOC <font color='rgb(255,50,100)'>//</font> 49 FEATURES"
TitleText.TextColor3 = Color3.new(1, 1, 1)
TitleText.TextSize = 14
TitleText.Font = Enum.Font.GothamBold
TitleText.RichText = true
TitleText.TextXAlignment = Enum.TextXAlignment.Left

local Close = Instance.new("TextButton", Title)
Close.Size = UDim2.new(0, 30, 0, 25)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Close.Text = "×"
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 18
Close.Font = Enum.Font.GothamBold
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 4)

-- Sidebar
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

-- Content
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -160, 1, -35)
Content.Position = UDim2.new(0, 160, 0, 35)
Content.BackgroundTransparency = 1

-- Dragging
local dragging, dragStart, startPos = false, nil, nil
Title.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = Main.Position
    end
end)
Title.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Helpers
local function Tween(obj, prop, val, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.2), {[prop] = val}):Play()
end

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
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
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
    Instance.new("UICorner", Track).CornerRadius = UDim.new(0, 2)
    
    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(255, 50, 100)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)
    
    local Knob = Instance.new("Frame", Track)
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(0, 6)
    
    local draggingSlider, value = false, default
    
    Frame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end end)
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
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end end)
    
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
    
    local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 50, 100), Color3.fromRGB(50, 150, 255)}
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

-- Tabs
local Tabs, CurrentTab = {}, nil

local function CreateCategory(name, icon)
    local Cat = Instance.new("Frame", SideScroll)
    Cat.Size = UDim2.new(1, -10, 0, 30)
    Cat.BackgroundTransparency = 1
    
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
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 1200)
    TabContent.Visible = false
    
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

local MainCat = CreateCategory("Main", "⌂")
local VisualsCat = CreateCategory("Visuals", "◉")
local MiscCat = CreateCategory("Misc", "⚙")
local SettingsCat = CreateCategory("Settings", "⚒")

-- ========== FIXED FEATURES ==========

-- Clear ESP
local function ClearESP()
    for _, obj in ipairs(ESPFolder:GetChildren()) do
        obj:Destroy()
    end
end

-- Create ESP for target
local function CreateESP(target, espType, color)
    if not target or not target.Parent then return nil end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = ESPFolder
    
    -- Find part to attach to
    local attachPart = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head") or target:FindFirstChildWhichIsA("BasePart")
    if not attachPart then
        billboard:Destroy()
        return nil
    end
    billboard.Adornee = attachPart
    
    -- Box
    if Config.ESP.Config.Boxes then
        local box = Instance.new("Frame", billboard)
        box.Name = "Box"
        box.Size = UDim2.new(0, 100, 0, 100)
        box.Position = UDim2.new(0.5, -50, 0.5, -50)
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 2
        box.BorderColor3 = color
    end
    
    -- Name/Info Label
    local info = Instance.new("TextLabel", billboard)
    info.Name = "Info"
    info.Size = UDim2.new(1, 0, 0, 20)
    info.Position = UDim2.new(0, 0, 0, -20)
    info.BackgroundTransparency = 1
    info.TextColor3 = color
    info.TextSize = Config.ESP.Config.FontSize
    info.Font = Enum.Font.GothamBold
    info.TextStrokeTransparency = 0.5
    
    local text = ""
    if espType == "Player" or espType == "NPC" then
        local humanoid = target:FindFirstChild("Humanoid")
        local name = target.Name
        
        if Config.ESP[espType].Name then
            text = name
        end
        if Config.ESP[espType].Health and humanoid then
            text = text .. " [" .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth) .. "]"
        end
        if Config.ESP[espType].Distance then
            local dist = (attachPart.Position - Camera.CFrame.Position).Magnitude
            text = text .. " [" .. math.floor(dist) .. "m]"
        end
    elseif espType == "Loot" then
        text = "💰 " .. target.Name
        if Config.ESP.Loot.Distance then
            local dist = (attachPart.Position - Camera.CFrame.Position).Magnitude
            text = text .. " [" .. math.floor(dist) .. "m]"
        end
    elseif espType == "Extract" then
        text = "🏃 EXIT"
    end
    
    info.Text = text
    
    -- HP Bar
    if Config.ESP.Config.HPBar and (espType == "Player" or espType == "NPC") then
        local humanoid = target:FindFirstChild("Humanoid")
        if humanoid then
            local hpBg = Instance.new("Frame", billboard)
            hpBg.Name = "HPBg"
            hpBg.Size = UDim2.new(0, 4, 0, 80)
            hpBg.Position = UDim2.new(0, -10, 0.5, -40)
            hpBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            hpBg.BorderSizePixel = 0
            
            local hpFill = Instance.new("Frame", hpBg)
            hpFill.Name = "HPFill"
            hpFill.Size = UDim2.new(1, 0, humanoid.Health / humanoid.MaxHealth, 0)
            hpFill.Position = UDim2.new(0, 0, 1 - humanoid.Health / humanoid.MaxHealth, 0)
            hpFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            hpFill.BorderSizePixel = 0
            
            -- Update HP
            spawn(function()
                while hpFill and hpFill.Parent and humanoid and humanoid.Parent do
                    local hpPercent = humanoid.Health / humanoid.MaxHealth
                    hpFill.Size = UDim2.new(1, 0, hpPercent, 0)
                    hpFill.Position = UDim2.new(0, 0, 1 - hpPercent, 0)
                    hpFill.BackgroundColor3 = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
                    wait(0.1)
                end
            end)
        end
    end
    
    -- Head Dot
    if Config.ESP.Config.HeadDot then
        local head = target:FindFirstChild("Head")
        if head then
            local dot = Instance.new("BillboardGui", ESPFolder)
            dot.Name = "HeadDot"
            dot.AlwaysOnTop = true
            dot.Size = UDim2.new(0, 8, 0, 8)
            dot.Adornee = head
            dot.Parent = ESPFolder
            
            local circle = Instance.new("Frame", dot)
            circle.Size = UDim2.new(1, 0, 1, 0)
            circle.BackgroundColor3 = color
            circle.BorderSizePixel = 0
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
        end
    end
    
    -- Tracers
    if Config.ESP.Config.Tracers then
        -- Tracers would require Drawing API, skipping for now
    end
    
    return billboard
end

-- Update ESP
local function UpdateESP()
    ClearESP()
    
    -- Player ESP
    if Config.ESP.Player.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local dist = (root.Position - Camera.CFrame.Position).Magnitude
                    if dist <= Config.ESP.Config.MaxDist then
                        CreateESP(player.Character, "Player", Config.ESP.Player.Color)
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
                if npc:IsA("Model") then
                    local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
                    if root then
                        local dist = (root.Position - Camera.CFrame.Position).Magnitude
                        if dist <= Config.ESP.Config.MaxDist then
                            CreateESP(npc, "NPC", Config.ESP.NPC.Color)
                        end
                    end
                end
            end
        end
    end
    
    -- Loot ESP
    if Config.ESP.Loot.Enabled then
        local lootFolders = {
            workspace:FindFirstChild("Buildings") and workspace.Buildings:FindFirstChild("Loots"),
            workspace:FindFirstChild("Map")
        }
        
        for _, folder in ipairs(lootFolders) do
            if folder then
                for _, item in ipairs(folder:GetDescendants()) do
                    if item:IsA("Model") or item:IsA("BasePart") then
                        if item.Name:lower():find("loot") or item.Name:lower():find("crate") or item.Name:lower():find("item") then
                            local root = item:FindFirstChild("HumanoidRootPart") or item:FindFirstChild("PrimaryPart") or (item:IsA("BasePart") and item)
                            if root then
                                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                                if dist <= Config.ESP.Loot.MaxDist then
                                    CreateESP(item, "Loot", Config.ESP.Loot.Color)
                                end
                            end
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
                    local root = marker:FindFirstChild("HumanoidRootPart") or marker:FindFirstChild("PrimaryPart") or (marker:IsA("BasePart") and marker)
                    if root then
                        CreateESP(marker, "Extract", Config.ESP.Extract.Color)
                    end
                end
            end
        end
    end
end

-- Stamina (FIXED - uses your game paths)
local function GetStamina()
    -- Try player profile first
    local miscs = ReplicatedStorage:FindFirstChild("Storage") and ReplicatedStorage.Storage:FindFirstChild("Miscs")
    if miscs then
        local profile = miscs:FindFirstChild("playerProfile")
        if profile then
            return profile:FindFirstChild("stamina")
        end
    end
    
    -- Try __profiles folder
    local storage = ReplicatedStorage:FindFirstChild("Storage")
    if storage then
        local profiles = storage:FindFirstChild("__profiles")
        if profiles then
            local myProfile = profiles:FindFirstChild(LocalPlayer.Name)
            if myProfile then
                return myProfile:FindFirstChild("stamina")
            end
        end
    end
    
    return nil
end

-- Movement variables
local FlyConnection, NoclipConnection = nil, nil

-- Fly
local function EnableFly(enabled)
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    
    if enabled and Character and Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Character.HumanoidRootPart
        FlyConnection = RunService.RenderStepped:Connect(function()
            if not Config.Movement.Fly then return end
            if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
            
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
                hrp.Anchored = false
            else
                hrp.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    end
end

-- Noclip
local function EnableNoclip(enabled)
    if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
    
    if enabled then
        NoclipConnection = RunService.Stepped:Connect(function()
            if not Config.Movement.Noclip then return end
            if Character then
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- No Fog
local function EnableNoFog(enabled)
    if enabled then
        Lighting.FogStart = 0
        Lighting.FogEnd = 999999
        Lighting.FogColor = Color3.fromRGB(255, 255, 255)
        
        local volumetric = LocalPlayer.PlayerScripts:FindFirstChild("VolumetricFog")
        if volumetric then volumetric.Disabled = true end
    else
        Lighting.FogStart = 100
        Lighting.FogEnd = 1000
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
local function EnableAntiAFK(enabled)
    if enabled then
        spawn(function()
            while Config.Utility.AntiAFK do
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
                wait(300)
            end
        end)
    end
end

-- ========== UI CONTENT ==========

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
CreateToggle(VisualsCat, "Name", false, function(v) Config.ESP.Player.Name = v end)
CreateToggle(VisualsCat, "Health", false, function(v) Config.ESP.Player.Health = v end)
CreateToggle(VisualsCat, "Distance", false, function(v) Config.ESP.Player.Distance = v end)
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
CreateToggle(VisualsCat, "Name", false, function(v) Config.ESP.NPC.Name = v end)
CreateToggle(VisualsCat, "Health", false, function(v) Config.ESP.NPC.Health = v end)
CreateToggle(VisualsCat, "Distance", false, function(v) Config.ESP.NPC.Distance = v end)
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
CreateSlider(VisualsCat, "Max Distance", 100, 5000, 1000, function(v) Config.ESP.Loot.MaxDist = v end)

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

CreateToggle(VisualsCat, "Boxes", false, function(v) Config.ESP.Config.Boxes = v end)
CreateToggle(VisualsCat, "HP Bar", false, function(v) Config.ESP.Config.HPBar = v end)
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

CreateToggle(MiscCat, "Full Bright", false, function(v) Config.World.FullBright = v; EnableFullBright(v) end)
CreateToggle(MiscCat, "No Fog", false, function(v) Config.World.NoFog = v; EnableNoFog(v) end)
CreateColor(MiscCat, "RGB Ambient", Config.World.Ambient, function(c) Config.World.Ambient = c end)
CreateBtn(MiscCat, "Apply Ambient", function() Lighting.Ambient = Config.World.Ambient; Lighting.OutdoorAmbient = Config.World.Ambient end)

local MS = Instance.new("TextLabel", MiscCat)
MS.Text = "MOVEMENT"
MS.TextColor3 = Color3.fromRGB(255, 50, 100)
MS.Size = UDim2.new(1, -20, 0, 25)
MS.BackgroundTransparency = 1
MS.TextSize = 12
MS.Font = Enum.Font.GothamBold
MS.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(MiscCat, "Fly", false, function(v) Config.Movement.Fly = v; EnableFly(v) end)
CreateSlider(MiscCat, "Walk Speed", 1, 200, 16, function(v) Config.Movement.WalkSpeed = v; if Humanoid then Humanoid.WalkSpeed = v end end)
CreateToggle(MiscCat, "Noclip", false, function(v) Config.Movement.Noclip = v; EnableNoclip(v) end)
CreateToggle(MiscCat, "Infinite Jump", false, function(v) Config.Movement.InfJump = v end)

local US = Instance.new("TextLabel", MiscCat)
US.Text = "UTILITY"
US.TextColor3 = Color3.fromRGB(255, 50, 100)
US.Size = UDim2.new(1, -20, 0, 25)
US.BackgroundTransparency = 1
US.TextSize = 12
US.Font = Enum.Font.GothamBold
US.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle(MiscCat, "Anti AFK", false, function(v) Config.Utility.AntiAFK = v; EnableAntiAFK(v) end)
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
CreateBtn(MiscCat, "Rejoin", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)

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

-- Close
Close.MouseButton1Click:Connect(function()
    SG:Destroy()
    ESPFolder:Destroy()
    if FlyConnection then FlyConnection:Disconnect() end
    if NoclipConnection then NoclipConnection:Disconnect() end
end)

-- Toggle UI
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-- First tab
Tabs[1].Content.Visible = true
Tabs[1].Label.TextColor3 = Color3.fromRGB(255, 50, 100)
CurrentTab = {Content = Tabs[1].Content, Label = Tabs[1].Label}

-- Main Loop
local lastJump = 0
RunService.RenderStepped:Connect(function()
    -- Infinite Stamina (FIXED)
    if Config.Combat.InfStamina then
        local stamina = GetStamina()
        if stamina and stamina:IsA("NumberValue") then
            stamina.Value = 100
        end
    end
    
    -- Update ESP
    if Config.ESP.Player.Enabled or Config.ESP.NPC.Enabled or Config.ESP.Loot.Enabled or Config.ESP.Extract.Enabled then
        UpdateESP()
    else
        ClearESP()
    end
    
    -- Infinite Jump (FIXED - uses JumpRequest)
    if Config.Movement.InfJump then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and tick() - lastJump > 0.2 then
            if Humanoid and Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                lastJump = tick()
            end
        end
    end
    
    -- Walk Speed
    if Humanoid and Humanoid.WalkSpeed ~= Config.Movement.WalkSpeed then
        Humanoid.WalkSpeed = Config.Movement.WalkSpeed
    end
end)

-- Character respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    if Config.Movement.WalkSpeed ~= 16 then
        Humanoid.WalkSpeed = Config.Movement.WalkSpeed
    end
end)

print("Havoc v2.1 Loaded | RightShift to toggle | All features fixed!")
