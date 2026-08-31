--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- =============================================================================
-- 👁️ SORCERER TOWER DEFENSE SCRIPT // GOJO IS THE GOAT EDITION
-- =============================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Player = Players.LocalPlayer

-- --- INSTANT HARDWARE FINGERPRINTING ---
local IsMobileDevice = UserInputService.TouchEnabled

-- --- SYSTEM STATE MANAGEMENT ---
local State = {
    IsRecording = false, 
    IsPlaying = false,
    IsLooped = true, 
    StartTime = os.clock(),
    SequenceDuration = 0,
    MacroCache = {},
    PanelOpen = true,
    CurrentSlot = 1
}

local PlaybackThreads = {}
local VisualNodes = {}
local StoragePrefix = "SorcererTD_Macro_FixedSlot_"

-- --- CLEANUP EXISTING UI ---
if Player.PlayerGui:FindFirstChild("Sorcerer_TD_Macro") then
    Player.PlayerGui.Sorcerer_TD_Macro:Destroy()
end

-- --- CORE SCREEN UI SETUP ---
local UI = Instance.new("ScreenGui")
UI.Name = "Sorcerer_TD_Macro"
UI.ResetOnSpawn = false
UI.Parent = Player:WaitForChild("PlayerGui")

local VisualFolder = Instance.new("Folder")
VisualFolder.Name = "VisualNodes"
VisualFolder.Parent = UI

-- =============================================================================
-- 👁️ GOJO UNMASKED FLOATING TOGGLE IMAGE BUTTON
-- =============================================================================
local LogoButton = Instance.new("ImageButton")
LogoButton.Name = "LogoButton"
LogoButton.Size = UDim2.new(0, 65, 0, 65)
LogoButton.Position = UDim2.new(0, 20, 0.15, 0)
LogoButton.BackgroundColor3 = Color3.fromRGB(12, 15, 28)
LogoButton.Image = "rbxassetid://7247717013" 
LogoButton.ScaleType = Enum.ScaleType.Crop
LogoButton.BorderSizePixel = 0
LogoButton.ZIndex = 15
LogoButton.Active = true
LogoButton.Draggable = true 
LogoButton.Parent = UI

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(1, 0)
LogoCorner.Parent = LogoButton

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Thickness = 2
LogoStroke.Color = Color3.fromRGB(115, 185, 255)
LogoStroke.Parent = LogoButton

-- =============================================================================
-- 🖥️ MAIN INTERFACE SYSTEM (BOUNDED FOR TEXT SAFETY)
-- =============================================================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 290)
MainFrame.Position = UDim2.new(0.5, -170, 0.4, -145)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = UI

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(31, 41, 59)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(16, 21, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 10)
HeaderFix.Position = UDim2.new(0, 0, 1, -10)
HeaderFix.BackgroundColor3 = Color3.fromRGB(16, 21, 35)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 215, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ SORCERER TD // GOJO IS THE GOAT"
Title.TextColor3 = Color3.fromRGB(200, 225, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTruncate = Enum.TextTruncate.AtEnd
Title.Parent = Header

local StatusBadge = Instance.new("TextLabel")
StatusBadge.Size = UDim2.new(0, 85, 0, 22)
StatusBadge.Position = UDim2.new(1, -97, 0.5, -11)
StatusBadge.BackgroundColor3 = Color3.fromRGB(15, 30, 50)
StatusBadge.Text = IsMobileDevice and "MOBILE IDLE" or "PC STANDBY"
StatusBadge.TextColor3 = Color3.fromRGB(140, 195, 255)
StatusBadge.Font = Enum.Font.GothamBold
StatusBadge.TextSize = 10
StatusBadge.TextTruncate = Enum.TextTruncate.AtEnd
StatusBadge.Parent = Header

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 6)
BadgeCorner.Parent = StatusBadge

local BadgeStroke = Instance.new("UIStroke")
BadgeStroke.Thickness = 1
BadgeStroke.Color = Color3.fromRGB(34, 72, 110)
BadgeStroke.Parent = StatusBadge

local ConsoleBox = Instance.new("Frame")
ConsoleBox.Size = UDim2.new(1, -24, 0, 58)
ConsoleBox.Position = UDim2.new(0, 12, 0, 52)
ConsoleBox.BackgroundColor3 = Color3.fromRGB(5, 7, 12)
ConsoleBox.Parent = MainFrame

local ConsoleCorner = Instance.new("UICorner")
ConsoleCorner.CornerRadius = UDim.new(0, 6)
ConsoleCorner.Parent = ConsoleBox

local LogLabel = Instance.new("TextLabel")
LogLabel.Size = UDim2.new(1, -20, 0, 32)
LogLabel.Position = UDim2.new(0, 10, 0, 4)
LogLabel.BackgroundTransparency = 1
LogLabel.Text = "⏸️ System Idle. Placement save pipeline re-allocated securely."
LogLabel.TextColor3 = Color3.fromRGB(120, 132, 145)
LogLabel.Font = Enum.Font.Gotham
LogLabel.TextSize = 10
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextYAlignment = Enum.TextYAlignment.Center
LogLabel.TextWrapped = true 
LogLabel.Parent = ConsoleBox

local TelemetryLabel = Instance.new("TextLabel")
TelemetryLabel.Size = UDim2.new(1, -20, 0, 18)
TelemetryLabel.Position = UDim2.new(0, 10, 1, -20)
TelemetryLabel.BackgroundTransparency = 1
TelemetryLabel.Text = "Placements: 0  |  Timeline: 0.0s  |  Status: Offline"
TelemetryLabel.TextColor3 = Color3.fromRGB(85, 93, 100)
TelemetryLabel.Font = Enum.Font.GothamMedium
TelemetryLabel.TextSize = 10
TelemetryLabel.TextXAlignment = Enum.TextXAlignment.Left
TelemetryLabel.TextTruncate = Enum.TextTruncate.AtEnd
TelemetryLabel.Parent = ConsoleBox

-- --- UI BUTTON BUILDERS ---

local function updateStatus(text, bg, stroke)
    StatusBadge.Text = text
    StatusBadge.BackgroundColor3 = bg
    BadgeStroke.Color = stroke
end

local function applyButtonEffects(btn, baseColor, hoverColor)
    local originalSize = btn.Size
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
    end)
    btn.MouseButton1Down:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.05), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset - 4, originalSize.Y.Scale, originalSize.Y.Offset - 4)}):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), {Size = originalSize}):Play()
    end)
end

local function createButton(name, text, position, size, baseColor, hoverColor)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Text = text
    btn.Position = position
    btn.Size = size
    btn.BackgroundColor3 = baseColor
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 10
    btn.TextColor3 = Color3.fromRGB(240, 248, 255)
    btn.BorderSizePixel = 0
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = baseColor:Lerp(Color3.fromRGB(255, 255, 255), 0.1)
    stroke.Parent = btn

    applyButtonEffects(btn, baseColor, hoverColor)
    return btn
end

local RecordBtn = createButton("RecordBtn", "🔴 RECORD STRAT", UDim2.new(0, 12, 0, 120), UDim2.new(0, 105, 0, 38), Color3.fromRGB(156, 32, 61), Color3.fromRGB(191, 44, 78))
local PlayBtn   = createButton("PlayBtn", "▶ AUTOPLAY", UDim2.new(0, 127, 0, 120), UDim2.new(0, 100, 0, 38), Color3.fromRGB(31, 122, 66), Color3.fromRGB(42, 161, 88))
local WipeBtn   = createButton("WipeBtn", "🗑️ CLEAR STRAT", UDim2.new(0, 237, 0, 120), UDim2.new(0, 91, 0, 38), Color3.fromRGB(48, 52, 64), Color3.fromRGB(66, 71, 87))

local LoopBtn   = createButton("LoopBtn", "🔄 LOOPING: ENABLED", UDim2.new(0, 12, 0, 164), UDim2.new(1, -24, 0, 32), Color3.fromRGB(45, 91, 128), Color3.fromRGB(60, 120, 166))

local Slot1Btn = createButton("Slot1Btn", "[ MEMORY SLOT 1 * ]", UDim2.new(0, 12, 0, 204), UDim2.new(0, 100, 0, 30), Color3.fromRGB(35, 75, 115), Color3.fromRGB(45, 100, 150))
local Slot2Btn = createButton("Slot2Btn", "[ MEMORY SLOT 2 ]", UDim2.new(0, 120, 0, 204), UDim2.new(0, 100, 0, 30), Color3.fromRGB(24, 28, 41), Color3.fromRGB(36, 42, 61))
local Slot3Btn = createButton("Slot3Btn", "[ MEMORY SLOT 3 ]", UDim2.new(0, 228, 0, 204), UDim2.new(0, 100, 0, 30), Color3.fromRGB(24, 28, 41), Color3.fromRGB(36, 42, 61))

local TrackPanel = Instance.new("Frame")
TrackPanel.Size = UDim2.new(1, -24, 0, 32)
TrackPanel.Position = UDim2.new(0, 12, 0, 244)
TrackPanel.BackgroundColor3 = Color3.fromRGB(16, 21, 35)
TrackPanel.BorderSizePixel = 0
TrackPanel.Parent = MainFrame

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(0, 6)
TrackCorner.Parent = TrackPanel

local TrackLabel = Instance.new("TextLabel")
TrackLabel.Size = UDim2.new(1, -10, 1, 0)
TrackLabel.Position = UDim2.new(0, 5, 0, 0)
TrackLabel.BackgroundTransparency = 1
TrackLabel.Text = IsMobileDevice and "📱 SYSTEM: MOBILE ENVIRONMENT SECURITY ARMED" or "🖥️ SYSTEM: PC ENVIRONMENT SECURITY ARMED"
TrackLabel.TextColor3 = Color3.fromRGB(130, 175, 210)
TrackLabel.Font = Enum.Font.GothamBold
TrackLabel.TextSize = 9
TrackLabel.TextXAlignment = Enum.TextXAlignment.Center
TrackLabel.TextTruncate = Enum.TextTruncate.AtEnd
TrackLabel.Parent = TrackPanel

-- =============================================================================
-- 💾 FIXED SERIALIZATION PIPELINE LOCAL STORAGE SYSTEM
-- =============================================================================
local refreshTelemetry;

local function getFileName(slot)
    return StoragePrefix .. tostring(slot) .. ".json"
end

local function saveMacroToDisk()
    local fileName = getFileName(State.CurrentSlot)
    
    local flatData = {}
    for _, item in ipairs(State.MacroCache) do
        table.insert(flatData, {
            Delay = item.Delay,
            RawCoords = tostring(math.floor(item.Coords.X)) .. "," .. tostring(math.floor(item.Coords.Y))
        })
    end
    
    local payload = {
        Duration = State.SequenceDuration,
        Data = flatData
    }
    
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(payload)
    end)
    
    if success and encoded then
        pcall(function()
            if writefile then
                writefile(fileName, encoded)
            end
        end)
    end
end

local function loadMacroFromDisk()
    local fileName = getFileName(State.CurrentSlot)
    local fileExists = false
    
    pcall(function()
        if isfile then fileExists = isfile(fileName) end
    end)
    
    if not fileExists then
        State.MacroCache = {}
        State.SequenceDuration = 0
        return
    end
    
    local content = nil
    pcall(function()
        if readfile then content = readfile(fileName) end
    end)
    
    if content then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        
        if success and decoded and type(decoded) == "table" then
            State.SequenceDuration = decoded.Duration or 0
            State.MacroCache = {}
            
            local trackingData = decoded.Data or {}
            for _, item in ipairs(trackingData) do
                if item.RawCoords then
                    local split = string.split(item.RawCoords, ",")
                    local posX = tonumber(split[1]) or 0
                    local posY = tonumber(split[2]) or 0
                    table.insert(State.MacroCache, {
                        Delay = item.Delay,
                        Coords = Vector2.new(posX, posY)
                    })
                end
            end
        else
            State.MacroCache = {}
            State.SequenceDuration = 0
        end
    end
end

local function updateSlotUI()
    Slot1Btn.BackgroundColor3 = (State.CurrentSlot == 1) and Color3.fromRGB(35, 75, 115) or Color3.fromRGB(24, 28, 41)
    Slot2Btn.BackgroundColor3 = (State.CurrentSlot == 2) and Color3.fromRGB(35, 75, 115) or Color3.fromRGB(24, 28, 41)
    Slot3Btn.BackgroundColor3 = (State.CurrentSlot == 3) and Color3.fromRGB(35, 75, 115) or Color3.fromRGB(24, 28, 41)
    
    Slot1Btn.Text = (State.CurrentSlot == 1) and "[ MEMORY SLOT 1 * ]" or "[ MEMORY SLOT 1 ]"
    Slot2Btn.Text = (State.CurrentSlot == 2) and "[ MEMORY SLOT 2 * ]" or "[ MEMORY SLOT 2 ]"
    Slot3Btn.Text = (State.CurrentSlot == 3) and "[ MEMORY SLOT 3 * ]" or "[ MEMORY SLOT 3 ]"
end

local function selectActiveSlot(targetIndex)
    if State.IsRecording or State.IsPlaying then return end
    
    State.CurrentSlot = targetIndex
    updateSlotUI()
    loadMacroFromDisk()
    
    LogLabel.Text = "📁 Loaded placement data from Local Slot #" .. targetIndex
    LogLabel.TextColor3 = Color3.fromRGB(120, 220, 160)
    refreshTelemetry()
end

Slot1Btn.MouseButton1Click:Connect(function() selectActiveSlot(1) end)
Slot2Btn.MouseButton1Click:Connect(function() selectActiveSlot(2) end)
Slot3Btn.MouseButton1Click:Connect(function() selectActiveSlot(3) end)

-- =============================================================================
-- 👁️ GOJO INTERFACE REVEAL MOVEMENT LOGIC
-- =============================================================================
local isTweening = false
LogoButton.MouseButton1Click:Connect(function()
    if isTweening then return end
    State.PanelOpen = not State.PanelOpen
    isTweening = true
    
    if State.PanelOpen then
        MainFrame.Visible = true
        MainFrame:TweenSizeAndPosition(
            UDim2.new(0, 340, 0, 290), 
            UDim2.new(0.5, -170, 0.4, -145), 
            Enum.EasingDirection.Out, 
            Enum.EasingStyle.Quart, 
            0.2, 
            true,
            function() isTweening = false end
        )
        TweenService:Create(LogoButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(12, 15, 28)}):Play()
        LogoStroke.Color = Color3.fromRGB(115, 185, 255)
    else
        MainFrame:TweenSizeAndPosition(
            UDim2.new(0, 340, 0, 0), 
            UDim2.new(0.5, -170, 0.4, 0), 
            Enum.EasingDirection.In, 
            Enum.EasingStyle.Quart, 
            0.15, 
            true,
            function() 
                if not State.PanelOpen then MainFrame.Visible = false end 
                isTweening = false
            end
        )
        TweenService:Create(LogoButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 35, 50)}):Play()
        LogoStroke.Color = Color3.fromRGB(60, 130, 160)
    end
end)

-- =============================================================================
-- 🛠️ VISUALIZATION & DELETE NODE DEFINITIONS
-- =============================================================================

local function clearVisualNodes()
    VisualFolder:ClearAllChildren()
    VisualNodes = {}
end

local function removeMacroStep(index)
    if State.IsPlaying then return end
    if not State.MacroCache[index] then return end
    
    table.remove(State.MacroCache, index)
    
    if #State.MacroCache > 0 then
        if State.IsRecording then
            State.SequenceDuration = os.clock() - State.StartTime
        else
            local highestDelay = 0
            for _, taskItem in pairs(State.MacroCache) do
                if taskItem.Delay > highestDelay then highestDelay = taskItem.Delay end
            end
            State.SequenceDuration = highestDelay
        end
    else
        State.SequenceDuration = 0
    end
    
    saveMacroToDisk()
    refreshTelemetry()
end

local function renderVisualNodes()
    clearVisualNodes()
    if State.IsPlaying then return end
    
    for index, taskItem in ipairs(State.MacroCache) do
        local Node = Instance.new("TextButton")
        Node.Name = "MacroNode_" .. index
        Node.Size = UDim2.new(0, 38, 0, 38)
        Node.Position = UDim2.new(0, taskItem.Coords.X - 19, 0, taskItem.Coords.Y - 19)
        Node.BackgroundColor3 = Color3.fromRGB(50, 110, 220)
        Node.Text = tostring(index)
        Node.Font = Enum.Font.GothamBold
        Node.TextSize = 14
        Node.TextColor3 = Color3.fromRGB(255, 255, 255)
        Node.ZIndex = 5
        Node.Parent = VisualFolder
        
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = Node
        
        local Stroke = Instance.new("UIStroke")
        Stroke.Thickness = 2
        Stroke.Color = Color3.fromRGB(150, 200, 255)
        Stroke.Parent = Node
        
        Node.Size = UDim2.new(0, 0, 0, 0)
        Node.Position = UDim2.new(0, taskItem.Coords.X, 0, taskItem.Coords.Y)
        TweenService:Create(Node, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 38, 0, 38),
            Position = UDim2.new(0, taskItem.Coords.X - 19, 0, taskItem.Coords.Y - 19)
        }):Play()
        
        Node.MouseEnter:Connect(function()
            TweenService:Create(Node, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 40, 40)}):Play()
            Node.Text = "X"
        end)
        
        Node.MouseLeave:Connect(function()
            TweenService:Create(Node, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 110, 220)}):Play()
            Node.Text = tostring(index)
        end)
        
        Node.MouseButton1Click:Connect(function()
            removeMacroStep(index)
        end)
        
        table.insert(VisualNodes, Node)
    end
end

function refreshTelemetry()
    if State.IsRecording then
        local liveTimeline = os.clock() - State.StartTime
        TelemetryLabel.Text = "Placements: " .. #State.MacroCache .. "  |  Timeline: " .. string.format("%.1fs", liveTimeline) .. "  |  Recording..."
    else
        if #State.MacroCache > 0 then
            TelemetryLabel.Text = "Placements: " .. #State.MacroCache .. "  |  Duration: " .. string.format("%.1fs", State.SequenceDuration) .. "  |  Ready"
        else
            TelemetryLabel.Text = "Placements: 0  |  Duration: 0.0s  |  Offline"
        end
    end
    renderVisualNodes()
end

-- =============================================================================
-- 🔄 LOGIC CORE AND INTERACTION EXECUTION ENGINE
-- =============================================================================

LoopBtn.MouseButton1Click:Connect(function()
    State.IsLooped = not State.IsLooped
    if State.IsLooped then
        LoopBtn.Text = "🔄 LOOPING: ENABLED"
        LoopBtn.BackgroundColor3 = Color3.fromRGB(45, 91, 128)
        LogLabel.Text = "🔁 Strategy Loop Enabled. Sequence will auto-restart."
    else
        LoopBtn.Text = "➡️ LOOPING: DISABLED (AFK KICK PROTECTION ON)"
        LoopBtn.BackgroundColor3 = Color3.fromRGB(50, 58, 65)
        LogLabel.Text = "🦘 Loop Disabled. Anti-AFK Mobile Jump will fire at end."
    end
    LogLabel.TextColor3 = Color3.fromRGB(180, 215, 255)
end)

local function resetToDefaultHardwareLayout()
    if IsMobileDevice then
        updateStatus("MOBILE IDLE", Co
