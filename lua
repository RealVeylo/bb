if getgenv().Sense_Hub_BladeBall then warn("Sense Hub Blade Ball is already executed") return end
getgenv().Sense_Hub_BladeBall = true

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local Mouse = LocalPlayer:GetMouse()
local TweenService = game:GetService("TweenService")

-- AC_BYPASS Implementation
local IS_PRACTICE = game.PlaceId == 8206123457
local AC_BYPASS = true -- Set to true for bypass

-- Anti-cheat bypass hooks
local Handshake = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CharacterSoundEvent", 10)
local Hooks = {}
local HandshakeInts = {}

if not LPH_OBFUSCATED then
    getfenv().LPH_NO_VIRTUALIZE = function(f) return f end
end

-- Bypass anti-cheat detection
LPH_NO_VIRTUALIZE(function()
    for i, v in getgc() do
        if typeof(v) == "function" and islclosure(v) then
            if (#getprotos(v) == 1) and table.find(getconstants(getproto(v, 1)), 4000001) then
                hookfunction(v, function() end)
            end
        end
    end
end)()

if Handshake then
    Hooks.__namecall = hookmetamethod(game, "__namecall", LPH_NO_VIRTUALIZE(function(self, ...)
        local Method = getnamecallmethod()
        local Args = {...}

        if not checkcaller() and (self == Handshake) and (Method == "fireServer") and (string.find(Args[1], "AC")) then
            if (#HandshakeInts == 0) then
                HandshakeInts = {table.unpack(Args[2], 2, 18)}
            else
                for i, v in HandshakeInts do
                    Args[2][i + 1] = v
                end
            end
        end

        return Hooks.__namecall(self, ...)
    end))
end

-- Create folders
task.wait(1)
if not isfolder("Sense Hub") then
    makefolder("Sense Hub")
end

-- Load Fluent UI
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create Window with specified sizing
local Window = Fluent:CreateWindow({
    Title = "Sense Hub",
    SubTitle = "by Veylo",
    TabWidth = 160,
    Size = UDim2.fromOffset(595, 355),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
    CanResize = true,
    ScrollSpeed = 30,
    ScrollingEnabled = true
})

-- Create Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "sword", ScrollingEnabled = true }),
    Universal = Window:AddTab({ Title = "Player", Icon = "user", ScrollingEnabled = true }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye", ScrollingEnabled = true }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings", ScrollingEnabled = true })
}

local Options = Fluent.Options

-- Create Mobile Toggle Button
task.spawn(function()
    if not getgenv().LoadedMobileUI == true then
        getgenv().LoadedMobileUI = true

        local OpenUI = Instance.new("ScreenGui")
        local ImageButton = Instance.new("ImageButton")
        local UICorner = Instance.new("UICorner")

        OpenUI.Name = "SenseHubToggle"
        OpenUI.Parent = (gethui and gethui()) or CoreGui
        OpenUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        ImageButton.Parent = OpenUI
        ImageButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        ImageButton.BackgroundTransparency = 0.2
        ImageButton.Position = UDim2.new(0, 10, 0, 10)
        ImageButton.Size = UDim2.new(0, 50, 0, 50)
        ImageButton.Image = "rbxassetid://129937299302497"
        ImageButton.ImageTransparency = 0.1
        ImageButton.Draggable = true
        ImageButton.BorderSizePixel = 2
        ImageButton.BorderColor3 = Color3.fromRGB(0, 255, 255)

        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = ImageButton

        -- Toggle function using Fluent's MinimizeKey
        ImageButton.MouseButton1Click:Connect(function()
            game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        end)
    end
end)

-- Variables
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 9e9)
local Balls = Workspace:WaitForChild("Balls", 9e9)

local DefaultWalkSpeed = Humanoid.WalkSpeed
local DefaultJumpPower = Humanoid.JumpPower

-- Functions
local function sendNotification(message)
    Fluent:Notify({
        Title = "Sense Hub",
        Content = message,
        Duration = 5
    })
end

function VerifyBall(Ball)
    if typeof(Ball) == "Instance" and Ball:IsA("BasePart") and Ball:IsDescendantOf(Balls) and Ball:GetAttribute("realBall") == true then
        return true
    end
end

function IsTarget()
    return (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Highlight"))
end

function Parry()
    Remotes:WaitForChild("ParryButtonPress"):Fire()
end

-- Main Tab Features
local AutoParryToggle = Tabs.Main:AddToggle("AutoParry", {
    Title = "Auto Parry",
    Default = false,
    Description = "Automatically parry incoming balls"
})

local AutoParryDistance = Tabs.Main:AddSlider("AutoParryDistance", {
    Title = "Parry Distance",
    Description = "Distance to auto parry",
    Default = 15,
    Min = 5,
    Max = 30,
    Rounding = 1
})

local SpamParryToggle = Tabs.Main:AddToggle("SpamParry", {
    Title = "Spam Parry",
    Default = false,
    Description = "Continuously spam parry button"
})

local LookAtBallToggle = Tabs.Main:AddToggle("LookAtBall", {
    Title = "Look at Ball",
    Default = false,
    Description = "Automatically look at the ball"
})

local AutoEquipAbility = Tabs.Main:AddDropdown("AutoEquipAbility", {
    Title = "Auto Equip Ability",
    Values = {"Dash", "Super Jump", "Platform", "Invisibility", "Thunder Dash", "Shadow Step", "Wind Cloak", "Freeze", "Forcefield", "Swap", "Raging Deflection", "Reaper", "Telekinesis", "Pull", "Phase Bypass", "Rapture", "Waypoint", "Infinity"},
    Default = "Dash",
    Description = "Automatically equip selected ability"
})

-- Universal Tab Features
local WalkSpeedToggle = Tabs.Player:AddToggle("WalkSpeed", {
    Title = "Walk Speed",
    Default = false,
    Description = "Modify walk speed"
})

local WalkSpeedSlider = Tabs.Player:AddSlider("WalkSpeedValue", {
    Title = "Speed Value",
    Description = "Walk speed multiplier",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 1
})

local JumpPowerToggle = Tabs.Player:AddToggle("JumpPower", {
    Title = "Jump Power",
    Default = false,
    Description = "Modify jump power"
})

local JumpPowerSlider = Tabs.Player:AddSlider("JumpPowerValue", {
    Title = "Jump Value",
    Description = "Jump power multiplier",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 1
})

local FlyToggle = Tabs.Player:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Description = "Enable flight mode"
})

local FlySpeedSlider = Tabs.Player:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Flight speed",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 1
})

local NoclipToggle = Tabs.Player:AddToggle("Noclip", {
    Title = "Noclip",
    Default = false,
    Description = "Walk through walls"
})

-- Visuals Tab Features
local ESPToggle = Tabs.Visuals:AddToggle("ESP", {
    Title = "Player ESP",
    Default = false,
    Description = "See players through walls"
})

local BallESPToggle = Tabs.Visuals:AddToggle("BallESP", {
    Title = "Ball ESP",
    Default = false,
    Description = "Highlight balls"
})

local FullbrightToggle = Tabs.Visuals:AddToggle("Fullbright", {
    Title = "Fullbright",
    Default = false,
    Description = "Remove darkness"
})

-- Settings Tab
local AntiAFKToggle = Tabs.Settings:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Default = true,
    Description = "Prevent being kicked for inactivity"
})

-- Auto Parry Implementation
local AutoParryConnection
Balls.ChildAdded:Connect(function(Ball)
    if not AutoParryToggle.Value then return end
    if not VerifyBall(Ball) then return end

    print(`Ball Spawned: {Ball}`)

    local OldPosition = Ball.Position
    local OldTick = tick()

    Ball:GetPropertyChangedSignal("Position"):Connect(function()
        if IsTarget() then
            local Distance = (Ball.Position - workspace.CurrentCamera.Focus.Position).Magnitude
            local Velocity = (OldPosition - Ball.Position).Magnitude

            print(`Distance: {Distance}\nVelocity: {Velocity}\nTime: {Distance / Velocity}`)

            if (Distance / Velocity) <= AutoParryDistance.Value then
                Parry()
            end
        end

        if (tick() - OldTick >= 1/60) then
            OldTick = tick()
            OldPosition = Ball.Position
        end
    end)
end)

-- Spam Parry Implementation
local SpamParryConnection
SpamParryToggle:OnChanged(function()
    if SpamParryConnection then
        SpamParryConnection:Disconnect()
    end

    if SpamParryToggle.Value then
        SpamParryConnection = RunService.Heartbeat:Connect(function()
            Parry()
        end)
    end
end)

-- Look At Ball Implementation
local LookAtBallConnection
LookAtBallToggle:OnChanged(function()
    if LookAtBallConnection then
        LookAtBallConnection:Disconnect()
    end

    if LookAtBallToggle.Value then
        LookAtBallConnection = RunService.Heartbeat:Connect(function()
            for _,v in next, Balls:GetChildren() do
                if v then
                    if Character and HumanoidRootPart then
                        HumanoidRootPart.CFrame = CFrame.new(HumanoidRootPart.Position, v.Position)
                    end
                end
            end
        end)
    end
end)

-- Walk Speed Implementation
local WalkSpeedFunction = function()
    while WalkSpeedToggle.Value and task.wait() do
        if WalkSpeedToggle.Value then
            Humanoid.WalkSpeed = WalkSpeedSlider.Value
        else
            Humanoid.WalkSpeed = DefaultWalkSpeed
        end
    end
end

WalkSpeedToggle:OnChanged(function()
    if WalkSpeedToggle.Value then
        task.spawn(WalkSpeedFunction)
    else
        Humanoid.WalkSpeed = DefaultWalkSpeed
    end
end)

-- Jump Power Implementation
local JumpPowerFunction = function()
    while JumpPowerToggle.Value and task.wait() do
        if JumpPowerToggle.Value then
            Humanoid.JumpPower = JumpPowerSlider.Value
        else
            Humanoid.JumpPower = DefaultJumpPower
        end
    end
end

JumpPowerToggle:OnChanged(function()
    if JumpPowerToggle.Value then
        task.spawn(JumpPowerFunction)
    else
        Humanoid.JumpPower = DefaultJumpPower
    end
end)

-- Fly Implementation
local flying = false
local buttons = {W = false, S = false, A = false, D = false, Moving = false}

function startFly()
    local FlyInputBegan = UserInputService.InputBegan:connect(function (input, GPE)
        if GPE then return end
        for i, e in pairs(buttons) do
            if i ~= "Moving" and input.KeyCode == Enum.KeyCode[i] then
                buttons[i] = true
                buttons.Moving = true
            end
        end
    end)

    local FlyInputEnded = UserInputService.InputEnded:connect(function (input, GPE)
        if GPE then return end
        local a = false
        for i, e in pairs(buttons) do
            if i ~= "Moving" then
                if input.KeyCode == Enum.KeyCode[i] then
                    buttons[i] = false
                end
                if buttons[i] then a = true end
            end
        end
        buttons.Moving = a
    end)

    local FlyHeartbeat = RunService.Heartbeat:connect(function (step)
        if flying and Character and Character.PrimaryPart then
            local p = Character.PrimaryPart.Position
            local cf = workspace.CurrentCamera.CFrame
            local ax, ay, az = cf:toEulerAnglesXYZ()
            Character:SetPrimaryPartCFrame(CFrame.new(p.x, p.y, p.z) * CFrame.Angles(ax, ay, az))
            if buttons.Moving then
                local t = Vector3.new()
                if buttons.W then t = t + (setVec(cf.lookVector)) end
                if buttons.S then t = t - (setVec(cf.lookVector)) end
                if buttons.A then t = t - (setVec(cf.rightVector)) end
                if buttons.D then t = t + (setVec(cf.rightVector)) end
                Character:TranslateBy(t * step)
            end
        end
    end)

    if not Character or not Character.Head or flying then return end
    Humanoid.PlatformStand = true
    local cam = workspace:WaitForChild('Camera')
    local bv = Instance.new("BodyVelocity")
    local bav = Instance.new("BodyAngularVelocity")
    bv.Velocity, bv.MaxForce, bv.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
    bav.AngularVelocity, bav.MaxTorque, bav.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
    bv.Parent = Character.Head
    bav.Parent = Character.Head
    flying = true
end

function endFly()
    if not Character or not flying then return end
    Humanoid.PlatformStand = false
    for _, v in pairs(Character.Head:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") then
            v:Destroy()
        end
    end
    flying = false
end

function setVec(vec)
    return vec * (FlySpeedSlider.Value / vec.Magnitude)
end

FlyToggle:OnChanged(function()
    if FlyToggle.Value then
        startFly()
    else
        endFly()
    end
end)

-- Noclip Implementation
local NoclipConnection
NoclipToggle:OnChanged(function()
    if NoclipConnection then
        NoclipConnection:Disconnect()
    end

    if NoclipToggle.Value then
        NoclipConnection = RunService.Heartbeat:Connect(function()
            for a, b in pairs(Workspace:GetChildren()) do
                if b.Name == LocalPlayer.Name then
                    for i, v in pairs(Workspace[LocalPlayer.Name]:GetChildren()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end
        end)
    end
end)

-- ESP Implementation
local ESPObjects = {}

local function createESP(player)
    if player == LocalPlayer then return end

    local function addESP(character)
        if ESPObjects[player] then
            for _, obj in pairs(ESPObjects[player]) do
                obj:Destroy()
            end
        end

        ESPObjects[player] = {}

        local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not humanoidRootPart then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Parent = humanoidRootPart
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = billboard
        nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextScaled = true
        nameLabel.Font = Enum.Font.SourceSansBold

        table.insert(ESPObjects[player], billboard)
    end

    if player.Character then
        addESP(player.Character)
    end

    player.CharacterAdded:Connect(addESP)
end

ESPToggle:OnChanged(function()
    if ESPToggle.Value then
        for _, player in pairs(Players:GetPlayers()) do
            createESP(player)
        end

        Players.PlayerAdded:Connect(createESP)
    else
        for player, objects in pairs(ESPObjects) do
            for _, obj in pairs(objects) do
                obj:Destroy()
            end
        end
        ESPObjects = {}
    end
end)

-- Fullbright Implementation
local originalBrightness = Lighting.Brightness
local originalAmbient = Lighting.Ambient

FullbrightToggle:OnChanged(function()
    if FullbrightToggle.Value then
        Lighting.Brightness = 10
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = originalBrightness
        Lighting.Ambient = originalAmbient
    end
end)

-- Anti AFK Implementation
LocalPlayer.Idled:connect(function()
    if AntiAFKToggle.Value then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Character respawn handling
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

    -- Restore settings after respawn
    task.wait(1)
    if WalkSpeedToggle.Value then
        Humanoid.WalkSpeed = WalkSpeedSlider.Value
    end
    if JumpPowerToggle.Value then
        Humanoid.JumpPower = JumpPowerSlider.Value
    end
end)

-- Anti-kick system
local AntiKick = coroutine.create(function()
    if ReplicatedStorage:FindFirstChild("Security") then
        ReplicatedStorage.Security:Destroy()
    end
    if LocalPlayer.PlayerScripts:FindFirstChild("Client") then
        local client = LocalPlayer.PlayerScripts.Client
        if client:FindFirstChild("DeviceChecker") then
            client.DeviceChecker:Destroy()
        end
    end
    sendNotification("Anti-Kick System Enabled")
end)

coroutine.resume(AntiKick)

-- Save Manager Setup
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("Sense Hub")
SaveManager:SetFolder("Sense Hub/BladeBall")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
