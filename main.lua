-- Executor用 LocalPlayer + CoreGui
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ダンス100個ID（例）
local danceAnimations = {}
for i=1,100 do
    danceAnimations["Dance"..i] = "rbxassetid://"..(507766665+i)
end

local currentAnimTrack
local currentButtonName = nil
local isVertical = true
local isMinimized = false

-- GUI作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DanceGui"
screenGui.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0,600,0,400)
mainFrame.Position = UDim2.new(0,50,0,50)
mainFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
mainFrame.Parent = screenGui

-- コントロールフレーム
local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(1,0,0,40)
controlFrame.BackgroundTransparency = 1
controlFrame.Parent = mainFrame

-- ScrollingFrame
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,0,1,-40)
scrollFrame.Position = UDim2.new(0,0,0,40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 10
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar
scrollFrame.Parent = mainFrame

-- UIGridLayout
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0,60,0,60)
gridLayout.FillDirection = Enum.FillDirection.Vertical
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = scrollFrame

-- ダンス切替関数
local function toggleDance(name)
    local animId = danceAnimations[name]
    if not animId then return end
    if currentButtonName == name then
        if currentAnimTrack then currentAnimTrack:Stop() end
        currentAnimTrack = nil
        currentButtonName = nil
        return
    end
    if currentAnimTrack then currentAnimTrack:Stop() end
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    currentAnimTrack = humanoid:LoadAnimation(anim)
    currentAnimTrack.Looped = true
    currentAnimTrack:Play()
    currentButtonName = name
end

-- ダンスボタン生成
for i=1,100 do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,60,0,60)
    btn.Text = "D"..i
    btn.Parent = scrollFrame
    btn.MouseButton1Click:Connect(function()
        toggleDance("Dance"..i)
    end)
end

-- CanvasSize自動調整
local function updateCanvas()
    if isVertical then
        scrollFrame.CanvasSize = UDim2.new(0,0,0,gridLayout.AbsoluteContentSize.Y)
    else
        scrollFrame.CanvasSize = UDim2.new(0,gridLayout.AbsoluteContentSize.X,0,0)
    end
end
gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
updateCanvas()

-- [] ボタン 縦横切替
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,40,0,40)
toggleBtn.Position = UDim2.new(0,0,0,0)
toggleBtn.Text = "[]"
toggleBtn.Parent = controlFrame
toggleBtn.MouseButton1Click:Connect(function()
    isVertical = not isVertical
    gridLayout.FillDirection = isVertical and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
    updateCanvas()
end)

-- _ ボタン 最小化/展開
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0,40,0,40)
minBtn.Position = UDim2.new(0,50,0,0)
minBtn.Text = "_"
minBtn.Parent = controlFrame
minBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        mainFrame.Size = UDim2.new(0,600,0,400)
        isMinimized = false
    else
        mainFrame.Size = UDim2.new(0,600,0,40)
        isMinimized = true
    end
end)

-- ❌ ボタン 閉じる確認
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,40,0,40)
closeBtn.Position = UDim2.new(0,100,0,0)
closeBtn.Text = "❌"
closeBtn.Parent = controlFrame
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    local confirmFrame = Instance.new("Frame")
    confirmFrame.Size = UDim2.new(0,300,0,150)
    confirmFrame.Position = UDim2.new(0.5,-150,0.5,-75)
    confirmFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
    confirmFrame.Parent = screenGui

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1,0,0.5,0)
    txt.Text = "本当に閉じますか？"
    txt.TextScaled = true
    txt.BackgroundTransparency = 1
    txt.Parent = confirmFrame

    local yesBtn = Instance.new("TextButton")
    yesBtn.Size = UDim2.new(0.4,0,0.3,0)
    yesBtn.Position = UDim2.new(0.05,0,0.6,0)
    yesBtn.Text = "はい"
    yesBtn.Parent = confirmFrame
    yesBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0.4,0,0.3,0)
    backBtn.Position = UDim2.new(0.55,0,0.6,0)
    backBtn.Text = "戻る"
    backBtn.Parent = confirmFrame
    backBtn.MouseButton1Click:Connect(function()
        confirmFrame:Destroy()
        mainFrame.Visible = true
    end)
end)
