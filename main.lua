local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ダンス100個のアニメーションID（自分のIDに置き換える）
local danceAnimations = {}
for i = 1, 100 do
    danceAnimations["Dance"..i] = "rbxassetid://PUT_YOUR_ANIMATION_ID_"..i
end

local currentAnimTrack
local currentButtonName = nil

-- トグル再生
local function toggleDance(buttonName)
    local animId = danceAnimations[buttonName]

    if currentButtonName == buttonName then
        if currentAnimTrack then
            currentAnimTrack:Stop()
            currentAnimTrack = nil
        end
        currentButtonName = nil
        return
    end

    if currentAnimTrack then
        currentAnimTrack:Stop()
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = animId
    currentAnimTrack = humanoid:LoadAnimation(animation)
    currentAnimTrack.Looped = true
    currentAnimTrack:Play()

    currentButtonName = buttonName
end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DanceHorizontalGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 150)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
mainFrame.Parent = screenGui

-- 操作ボタンフレーム
local controlFrame = Instance.new("Frame")
controlFrame.Size = UDim2.new(1, 0, 0, 40)
controlFrame.Position = UDim2.new(0, 0, 0, 0)
controlFrame.BackgroundTransparency = 1
controlFrame.Parent = mainFrame

local function createControlButton(text, posX, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = UDim2.new(0, posX, 0, 0)
    btn.Text = text
    btn.Parent = controlFrame
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- []：UI展開/折りたたみ
createControlButton("[]", 0, function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- 最小化
createControlButton("—", 50, function()
    mainFrame.Size = UDim2.new(0, mainFrame.Size.X.Offset, 0, 40)
end)

-- ❌：UI非表示
createControlButton("❌", 100, function()
    screenGui.Enabled = false
end)

-- 横スクロールフレーム
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -40) -- 上部40pxは操作ボタン用
scrollFrame.Position = UDim2.new(0, 0, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 10
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(200,200,200)
scrollFrame.Parent = mainFrame
scrollFrame.HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar

-- UIGridLayout横並び
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(0, 60, 0, 60)
gridLayout.FillDirection = Enum.FillDirection.Horizontal
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = scrollFrame

-- ボタン生成
for i = 1, 100 do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 60, 0, 60)
    button.Text = "D"..i
    button.Parent = scrollFrame

    button.MouseButton1Click:Connect(function()
        toggleDance("Dance"..i)
    end)
end

-- CanvasSize自動調整
local function updateCanvasSize()
    scrollFrame.CanvasSize = UDim2.new(0, gridLayout.AbsoluteContentSize.X, 0, 0)
end
gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
updateCanvasSize()
