-- LocalScript (StarterGui に配置してください)
-- 概要: Free Dance 系アニメを使う 10 種類スロット + 100 ボタンUI（縦/横切替・最小化・閉じる確認）
-- 注意: 下の freeDanceIDs に有効な "rbxassetid://<数値>" を入れてください

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ↓ここに実際の Free Dance 系のアニメIDを入れてください（例: "rbxassetid://12345678"）
-- 例スロット（空欄 or ダミーIDのままだと再生されません）
local freeDanceIDs = {
    "rbxassetid://PUT_FREE_DANCE_ID_1",
    "rbxassetid://PUT_FREE_DANCE_ID_2",
    "rbxassetid://PUT_FREE_DANCE_ID_3",
    "rbxassetid://PUT_FREE_DANCE_ID_4",
    "rbxassetid://PUT_FREE_DANCE_ID_5",
    "rbxassetid://PUT_FREE_DANCE_ID_6",
    "rbxassetid://PUT_FREE_DANCE_ID_7",
    "rbxassetid://PUT_FREE_DANCE_ID_8",
    "rbxassetid://PUT_FREE_DANCE_ID_9",
    "rbxassetid://PUT_FREE_DANCE_ID_10"
}
-- ここまで

-- Helper: 100ボタン分に割り当て（freeDanceIDs をループして埋める）
local danceAnimations = {}
for i = 1, 100 do
    local idx = ((i - 1) % #freeDanceIDs) + 1
    danceAnimations["Dance"..i] = freeDanceIDs[idx]
end

-- UI 定数
local MAIN_WIDTH, MAIN_HEIGHT = 720, 420
local CONTROL_HEIGHT = 46
local ICON_SIZE = 64
local ICON_PADDING = 8

-- 再生管理
local currentTrack = nil
local currentName = nil
local isVertical = true
local isMinimized = false

-- Humanoid / Animator 確保（CharacterAdded に対応）
local humanoid, animator
local function ensureCharacterRefs(chr)
    humanoid = nil
    animator = nil
    if not chr then return end
    humanoid = chr:FindFirstChildOfClass("Humanoid") or chr:WaitForChild("Humanoid", 5)
    if humanoid then
        animator = humanoid:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = humanoid
        end
    end
end

if player.Character then
    ensureCharacterRefs(player.Character)
end
player.CharacterAdded:Connect(function(chr)
    ensureCharacterRefs(chr)
    -- リスポーン時は再生停止
    if currentTrack then
        pcall(function() currentTrack:Stop() end)
        currentTrack = nil
        currentName = nil
    end
end)

-- PlayerGui と ScreenGui
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FreeDancePanel"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, MAIN_WIDTH, 0, MAIN_HEIGHT)
mainFrame.Position = UDim2.new(0, 40, 0, 60)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- コントロールバー
local controlBar = Instance.new("Frame")
controlBar.Name = "ControlBar"
controlBar.Size = UDim2.new(1, 0, 0, CONTROL_HEIGHT)
controlBar.BackgroundTransparency = 1
controlBar.Parent = mainFrame

local function makeButton(text, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 44, 0, CONTROL_HEIGHT - 6)
    b.Position = UDim2.new(0, x, 0, 3)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(55,55,60)
    b.TextColor3 = Color3.fromRGB(235,235,235)
    b.AutoButtonColor = true
    b.Parent = controlBar
    return b
end

local btnToggle = makeButton("[]", 6)  -- 縦/横切替
local btnMin = makeButton("_", 56)     -- 最小化/展開
local btnClose = makeButton("✕", 106)  -- 閉じる確認

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 240, 1, 0)
title.Position = UDim2.new(0, 160, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Free Dance Panel"
title.TextColor3 = Color3.fromRGB(220,220,220)
title.TextScaled = true
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = controlBar

-- スクロールフレーム（ボタン領域）
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "ScrollArea"
scroll.Size = UDim2.new(1, 0, 1, -CONTROL_HEIGHT)
scroll.Position = UDim2.new(0, 0, 0, CONTROL_HEIGHT)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 10
scroll.Parent = mainFrame

-- パディング & レイアウト
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, ICON_PADDING)
padding.PaddingBottom = UDim.new(0, ICON_PADDING)
padding.PaddingLeft = UDim.new(0, ICON_PADDING)
padding.PaddingRight = UDim.new(0, ICON_PADDING)
padding.Parent = scroll

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
grid.CellPadding = UDim2.new(0, ICON_PADDING, 0, ICON_PADDING)
grid.SortOrder = Enum.SortOrder.LayoutOrder
grid.FillDirection = Enum.FillDirection.Vertical
grid.Parent = scroll

-- Canvas 更新
local function updateCanvas()
    if isVertical then
        scroll.CanvasSize = UDim2.new(0, 0, 0, grid.AbsoluteContentSize.Y + ICON_PADDING)
        scroll.CanvasPosition = Vector2.new(0, 0)
    else
        scroll.CanvasSize = UDim2.new(0, grid.AbsoluteContentSize.X + ICON_PADDING, 0, 0)
        scroll.CanvasPosition = Vector2.new(0, 0)
    end
end
grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

-- アニメ再生の安全関数（Animator 使用）
local function safePlayAnimation(animId)
    if not humanoid or not animator then
        return nil, "Humanoid/Animator not ready"
    end
    local ok, res = pcall(function()
        local a = Instance.new("Animation")
        a.AnimationId = animId
        local t = animator:LoadAnimation(a)
        t.Looped = true
        t:Play()
        return t
    end)
    if not ok then
        return nil, res
    end
    return res, nil
end

local function toggleDance(name)
    local animId = danceAnimations[name]
    if not animId or animId:find("PUT_FREE_DANCE_ID") then
        -- 無効なIDの場合は警告（ユーザに置換を促す）
        warn("Animation ID for "..name.." is not set. Replace freeDanceIDs with valid rbxassetid:// IDs.")
        return
    end

    if currentName == name then
        if currentTrack then pcall(function() currentTrack:Stop() end) end
        currentTrack = nil
        currentName = nil
        return
    end

    if currentTrack then pcall(function() currentTrack:Stop() end) end
    currentTrack = nil
    currentName = nil

    local track, err = safePlayAnimation(animId)
    if track then
        currentTrack = track
        currentName = name
    else
        warn("Failed to play animation:", err)
    end
end

-- 100ボタンを生成
for i = 1, 100 do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)
    btn.Text = tostring(i)
    btn.TextScaled = true
    btn.Parent = scroll
    -- 色分けして見やすく
    if i % 2 == 0 then
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    else
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
    btn.TextColor3 = Color3.fromRGB(240,240,240)

    btn.MouseButton1Click:Connect(function()
        toggleDance("Dance"..i)
    end)

    -- マウスホバーで少し拡大（見た目向上）
    btn.MouseEnter:Connect(function()
        pcall(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {Size = UDim2.new(0, ICON_SIZE+6, 0, ICON_SIZE+6)}):Play()
        end)
    end)
    btn.MouseLeave:Connect(function()
        pcall(function()
            TweenService:Create(btn, TweenInfo.new(0.12), {Size = UDim2.new(0, ICON_SIZE, 0, ICON_SIZE)}):Play()
        end)
    end)
end

-- 最初の Canvas 更新（遅延して呼ぶ）
task.defer(updateCanvas)

-- []: 縦/横切替
btnToggle.MouseButton1Click:Connect(function()
    isVertical = not isVertical
    grid.FillDirection = isVertical and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
    updateCanvas()
end)

-- _: 最小化/展開（消えない）
btnMin.MouseButton1Click:Connect(function()
    if isMinimized then
        mainFrame.Size = UDim2.new(0, MAIN_WIDTH, 0, MAIN_HEIGHT)
        isMinimized = false
    else
        mainFrame.Size = UDim2.new(0, MAIN_WIDTH, 0, CONTROL_HEIGHT)
        isMinimized = true
    end
end)

-- ✕: 閉じる確認ダイアログ
btnClose.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    local confirm = Instance.new("Frame")
    confirm.Size = UDim2.new(0, 360, 0, 150)
    confirm.Position = UDim2.new(0.5, -180, 0.5, -75)
    confirm.BackgroundColor3 = Color3.fromRGB(45,45,45)
    confirm.Parent = screenGui

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 60)
    lbl.Position = UDim2.new(0, 10, 0, 10)
    lbl.BackgroundTransparency = 1
    lbl.Text = "本当に閉じますか？"
    lbl.TextScaled = true
    lbl.TextColor3 = Color3.fromRGB(240,240,240)
    lb
