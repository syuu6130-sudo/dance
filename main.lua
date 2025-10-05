-- LocalScript（StarterGui > ScreenGui 内でも、PlayerGui に直接でもOK）

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- ダンス100個のアニメーションID（ここに自分のIDを入れる）
local danceAnimations = {}
for i = 1, 100 do
    danceAnimations["Dance"..i] = "rbxassetid://PUT_YOUR_ANIMATION_ID_"..i
end

local currentAnimTrack
local currentButtonName = nil

-- トグル再生関数
local function toggleDance(buttonName)
    local animId = danceAnimations[buttonName]

    -- 同じボタンなら停止
    if currentButtonName == buttonName then
        if currentAnimTrack then
            currentAnimTrack:Stop()
            currentAnimTrack = nil
        end
        currentButtonName = nil
        return
    end

    -- 前のアニメ停止
    if currentAnimTrack then
        currentAnimTrack:Stop()
    end

    -- 新しいアニメ再生
    local animation = Instance.new("Animation")
    animation.AnimationId = animId
    currentAnimTrack = humanoid:LoadAnimation(animation)
    currentAnimTrack.Looped = true
    currentAnimTrack:Play()

    currentButtonName = buttonName
end

-- ScreenGui作成
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DanceScrollGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- スクロールフレーム作成
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(0, 150, 0, 400) -- 必要に応じて調整
scrollFrame.Position = UDim2.new(0, 0, 0, 0)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 10
scrollFrame.Parent = screenGui

-- UIGridLayoutで縦に自動整列
local gridLayout = Instance.new("UIGridLayout")
gridLayout.CellSize = UDim2.new(1, 0, 0, 35)
gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
gridLayout.Parent = scrollFrame

-- ボタン生成
for i = 1, 100 do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 35) -- GridLayoutで自動調整
    button.Text = "Dance"..i
    button.Parent = scrollFrame

    button.MouseButton1Click:Connect(function()
        toggleDance("Dance"..i)
    end)
end

-- CanvasSizeを自動調整
local function updateCanvasSize()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, gridLayout.AbsoluteContentSize.Y)
end
gridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
updateCanvasSize()
