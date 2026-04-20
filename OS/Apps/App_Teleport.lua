local WindowManager = _G.SWILL_OS.modules.windowManager
local player = game.Players.LocalPlayer

local win = WindowManager.createWindow("Телепорт", 300, 400, 150, 150)

local list = Instance.new("ScrollingFrame")
list.Parent = win
list.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
list.Size = UDim2.new(1, -20, 1, -50)
list.Position = UDim2.new(0, 10, 0, 10)

local function updateList()
    for _, child in pairs(list:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local y = 5
    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player then
            local btn = Instance.new("TextButton")
            btn.Parent = list
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            btn.Size = UDim2.new(0.95, 0, 0, 40)
            btn.Position = UDim2.new(0.025, 0, 0, y)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextScaled = true
            
            btn.MouseButton1Click:Connect(function()
                local char = player.Character
                local target = plr.Character
                if char and target and target:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame
                end
            end)
            
            y = y + 50
        end
    end
    list.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

updateList()

local refresh = Instance.new("TextButton")
refresh.Parent = win
refresh.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
refresh.Size = UDim2.new(0.9, 0, 0, 35)
refresh.Position = UDim2.new(0.05, 0, 1, -45)
refresh.Text = "Обновить"
refresh.TextColor3 = Color3.fromRGB(255, 255, 255)
refresh.Font = Enum.Font.GothamBold
refresh.TextScaled = true
refresh.MouseButton1Click:Connect(updateList)
