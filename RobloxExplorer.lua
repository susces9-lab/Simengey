-- Explorer GUI для Roblox
-- Показывает структуру Instance-дерева игры

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Создаём ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExplorerGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0, 10, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 6)
UICorner.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local UICornerTitle = Instance.new("UICorner")
UICornerTitle.CornerRadius = UDim.new(0, 6)
UICornerTitle.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🗂 Roblox Explorer"
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.white
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TitleBar

local UICornerClose = Instance.new("UICorner")
UICornerClose.CornerRadius = UDim.new(0, 4)
UICornerClose.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Панель навигации (путь)
local PathBar = Instance.new("Frame")
PathBar.Size = UDim2.new(1, 0, 0, 28)
PathBar.Position = UDim2.new(0, 0, 0, 35)
PathBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
PathBar.BorderSizePixel = 0
PathBar.Parent = MainFrame

local PathLabel = Instance.new("TextLabel")
PathLabel.Size = UDim2.new(1, -10, 1, 0)
PathLabel.Position = UDim2.new(0, 8, 0, 0)
PathLabel.BackgroundTransparency = 1
PathLabel.Text = "📍 game"
PathLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
PathLabel.TextSize = 11
PathLabel.Font = Enum.Font.Gotham
PathLabel.TextXAlignment = Enum.TextXAlignment.Left
PathLabel.TextTruncate = Enum.TextTruncate.AtEnd
PathLabel.Parent = PathBar

-- Поле поиска
local SearchFrame = Instance.new("Frame")
SearchFrame.Size = UDim2.new(1, -10, 0, 28)
SearchFrame.Position = UDim2.new(0, 5, 0, 68)
SearchFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SearchFrame.BorderSizePixel = 0
SearchFrame.Parent = MainFrame

local UICornerSearch = Instance.new("UICorner")
UICornerSearch.CornerRadius = UDim.new(0, 4)
UICornerSearch.Parent = SearchFrame

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -10, 1, 0)
SearchBox.Position = UDim2.new(0, 5, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.PlaceholderText = "🔍 Поиск..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(200, 200, 200)
SearchBox.TextSize = 12
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchFrame

-- ScrollingFrame для дерева
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -110)
ScrollFrame.Position = UDim2.new(0, 5, 0, 102)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local UICornerScroll = Instance.new("UICorner")
UICornerScroll.CornerRadius = UDim.new(0, 4)
UICornerScroll.Parent = ScrollFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.Name
ListLayout.Padding = UDim.new(0, 1)
ListLayout.Parent = ScrollFrame

-- Иконки для типов
local function getIcon(instance)
    local className = instance.ClassName
    local icons = {
        Folder = "📁",
        Model = "🧩",
        Part = "🟦",
        MeshPart = "🔷",
        Script = "📜",
        LocalScript = "📄",
        ModuleScript = "📦",
        RemoteEvent = "📡",
        RemoteFunction = "🔁",
        BindableEvent = "🔔",
        BindableFunction = "🔄",
        StringValue = "🔤",
        IntValue = "🔢",
        BoolValue = "✅",
        NumberValue = "💯",
        ObjectValue = "🔗",
        Sound = "🔊",
        SoundService = "🎵",
        Workspace = "🌍",
        Players = "👥",
        ReplicatedStorage = "🗄",
        ServerScriptService = "⚙️",
        StarterGui = "🖼",
        StarterPack = "🎒",
        StarterPlayer = "🚶",
        Lighting = "💡",
        Teams = "🏳",
        TextLabel = "📝",
        TextButton = "🔘",
        Frame = "🖼",
        ImageLabel = "🖼",
        ScreenGui = "💻",
        BillboardGui = "📋",
        SurfaceGui = "🪟",
        Camera = "📷",
        Humanoid = "🧍",
        HumanoidRootPart = "🦴",
        Animation = "🎬",
        Tool = "🔧",
        Decal = "🎨",
        Texture = "🖌",
        SpecialMesh = "🔩",
        WeldConstraint = "🔗",
        Motor6D = "⚙",
        Attachment = "📌",
        PointLight = "💡",
        SpotLight = "🔦",
        SurfaceLight = "🌟",
    }
    return icons[className] or "📌"
end

-- Цвет для типов
local function getColor(instance)
    local className = instance.ClassName
    if className:find("Script") then
        return Color3.fromRGB(255, 200, 100)
    elseif className:find("Value") then
        return Color3.fromRGB(150, 255, 150)
    elseif className:find("Remote") or className:find("Bindable") then
        return Color3.fromRGB(255, 150, 255)
    elseif className == "Folder" or className == "Model" then
        return Color3.fromRGB(100, 180, 255)
    elseif className:find("Part") or className:find("Mesh") then
        return Color3.fromRGB(100, 220, 255)
    elseif className:find("Gui") or className:find("Label") or className:find("Button") or className:find("Frame") then
        return Color3.fromRGB(255, 180, 100)
    else
        return Color3.fromRGB(200, 200, 200)
    end
end

-- Текущий путь навигации
local navigationStack = {game}

-- Функция обновления пути
local function updatePath()
    local path = ""
    for i, obj in ipairs(navigationStack) do
        if i == 1 then
            path = "📍 game"
        else
            path = path .. " > " .. obj.Name
        end
    end
    PathLabel.Text = path
end

-- Основная функция отрисовки дерева
local function renderTree(parent, searchQuery)
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local children = parent:GetChildren()
    local shown = 0

    table.sort(children, function(a, b)
        local aIsContainer = a:IsA("Folder") or a:IsA("Model") or #a:GetChildren() > 0
        local bIsContainer = b:IsA("Folder") or b:IsA("Model") or #b:GetChildren() > 0
        if aIsContainer ~= bIsContainer then
            return aIsContainer
        end
        return a.Name < b.Name
    end)

    for _, child in ipairs(children) do
        if searchQuery and searchQuery ~= "" then
            if not child.Name:lower():find(searchQuery:lower()) then
                continue
            end
        end

        shown = shown + 1
        local hasChildren = #child:GetChildren() > 0

        local ItemBtn = Instance.new("TextButton")
        ItemBtn.Size = UDim2.new(1, 0, 0, 26)
        ItemBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ItemBtn.BackgroundTransparency = 0.3
        ItemBtn.BorderSizePixel = 0
        ItemBtn.Text = ""
        ItemBtn.AutoButtonColor = false
        ItemBtn.LayoutOrder = shown
        ItemBtn.Parent = ScrollFrame

        ItemBtn.MouseEnter:Connect(function()
            ItemBtn.BackgroundColor3 = Color3.fromRGB(50, 80, 110)
            ItemBtn.BackgroundTransparency = 0
        end)
        ItemBtn.MouseLeave:Connect(function()
            ItemBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            ItemBtn.BackgroundTransparency = 0.3
        end)

        if hasChildren then
            local ArrowLabel = Instance.new("TextLabel")
            ArrowLabel.Size = UDim2.new(0, 14, 1, 0)
            ArrowLabel.Position = UDim2.new(0, 4, 0, 0)
            ArrowLabel.BackgroundTransparency = 1
            ArrowLabel.Text = "▶"
            ArrowLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            ArrowLabel.TextSize = 9
            ArrowLabel.Font = Enum.Font.Gotham
            ArrowLabel.Parent = ItemBtn
        end

        local IconLabel = Instance.new("TextLabel")
        IconLabel.Size = UDim2.new(0, 20, 1, 0)
        IconLabel.Position = UDim2.new(0, 20, 0, 0)
        IconLabel.BackgroundTransparency = 1
        IconLabel.Text = getIcon(child)
        IconLabel.TextSize = 13
        IconLabel.Font = Enum.Font.Gotham
        IconLabel.Parent = ItemBtn

        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0.55, 0, 1, 0)
        NameLabel.Position = UDim2.new(0, 42, 0, 0)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = child.Name
        NameLabel.TextColor3 = getColor(child)
        NameLabel.TextSize = 12
        NameLabel.Font = Enum.Font.Gotham
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        NameLabel.Parent = ItemBtn

        local ClassLabel = Instance.new("TextLabel")
        ClassLabel.Size = UDim2.new(0.35, -5, 1, 0)
        ClassLabel.Position = UDim2.new(0.65, 0, 0, 0)
        ClassLabel.BackgroundTransparency = 1
        ClassLabel.Text = child.ClassName
        ClassLabel.TextColor3 = Color3.fromRGB(120, 120, 120)
        ClassLabel.TextSize = 10
        ClassLabel.Font = Enum.Font.Gotham
        ClassLabel.TextXAlignment = Enum.TextXAlignment.Right
        ClassLabel.TextTruncate = Enum.TextTruncate.AtEnd
        ClassLabel.Parent = ItemBtn

        if hasChildren then
            local CountLabel = Instance.new("TextLabel")
            CountLabel.Size = UDim2.new(0, 30, 1, 0)
            CountLabel.Position = UDim2.new(1, -32, 0, 0)
            CountLabel.BackgroundTransparency = 1
            CountLabel.Text = "[" .. #child:GetChildren() .. "]"
            CountLabel.TextColor3 = Color3.fromRGB(80, 160, 80)
            CountLabel.TextSize = 10
            CountLabel.Font = Enum.Font.GothamBold
            CountLabel.TextXAlignment = Enum.TextXAlignment.Right
            CountLabel.Parent = ItemBtn
        end

        ItemBtn.MouseButton1Click:Connect(function()
            if hasChildren then
                table.insert(navigationStack, child)
                updatePath()
                renderTree(child, "")
                SearchBox.Text = ""
            end
        end)
    end

    if shown == 0 then
        local EmptyLabel = Instance.new("TextLabel")
        EmptyLabel.Size = UDim2.new(1, 0, 0, 40)
        EmptyLabel.BackgroundTransparency = 1
        EmptyLabel.Text = searchQuery ~= "" and "🔍 Ничего не найдено" or "📭 Пусто"
        EmptyLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
        EmptyLabel.TextSize = 13
        EmptyLabel.Font = Enum.Font.Gotham
        EmptyLabel.Parent = ScrollFrame
    end
end

-- Кнопка "Назад"
local BackBtn = Instance.new("TextButton")
BackBtn.Size = UDim2.new(0, 25, 0, 25)
BackBtn.Position = UDim2.new(1, -60, 0, 5)
BackBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BackBtn.Text = "◀"
BackBtn.TextColor3 = Color3.white
BackBtn.TextSize = 11
BackBtn.Font = Enum.Font.GothamBold
BackBtn.BorderSizePixel = 0
BackBtn.Parent = TitleBar

local UICornerBack = Instance.new("UICorner")
UICornerBack.CornerRadius = UDim.new(0, 4)
UICornerBack.Parent = BackBtn

BackBtn.MouseButton1Click:Connect(function()
    if #navigationStack > 1 then
        table.remove(navigationStack)
        updatePath()
        renderTree(navigationStack[#navigationStack], "")
        SearchBox.Text = ""
    end
end)

-- Поиск в реальном времени
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    renderTree(navigationStack[#navigationStack], SearchBox.Text)
end)

-- Перетаскивание окна
local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Первоначальный рендер
updatePath()
renderTree(game, "")
