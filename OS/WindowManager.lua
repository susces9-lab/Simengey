-- SWILL OS WINDOW MANAGER
local WindowManager = {}
_G.SWILL_OS.modules.windowManager = WindowManager

local player = game.Players.LocalPlayer
local screenGui = nil
local windows = {}

function WindowManager.createScreen()
    if screenGui then screenGui:Destroy() end
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SwillOS"
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    return screenGui
end

function WindowManager.createWindow(title, width, height, x, y)
    WindowManager.createScreen()
    
    local frame = Instance.new("Frame")
    frame.Parent = screenGui
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.1
    frame.Size = UDim2.new(0, width or 400, 0, height or 300)
    frame.Position = UDim2.new(0, x or 100, 0, y or 100)
    frame.Active = true
    frame.Draggable = true
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame
    
    -- Заголовок
    local titleBar = Instance.new("Frame")
    titleBar.Parent = frame
    titleBar.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.Text = title or "Окно"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = titleBar
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12.5)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextScaled = true
    closeBtn.MouseButton1Click:Connect(function()
        frame:Destroy()
    end)
    
    table.insert(windows, frame)
    return frame
end

function WindowManager.createDesktop()
    local desktop = WindowManager.createWindow("SWILL OS", 500, 400, 100, 50)
    
    local bg = Instance.new("Frame")
    bg.Parent = desktop
    bg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    bg.Size = UDim2.new(1, 0, 1, -35)
    bg.Position = UDim2.new(0, 0, 0, 35)
    
    desktop.bg = bg
    return desktop
end

print("✅ WindowManager готов")
