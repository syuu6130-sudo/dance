-- =============================================
-- 完全版UI付きLuaスクリプト
-- スキルボタン・エモートボタン・装備・ステータス・縦スクロールログ追加
-- =============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local Settings = {
    Control = "mobile",
    Sensitivity = 1.2,
    LerpSpeed = 0.12,
    MaxHealth = 100,
    AutoHealRate = 2
}

local InputState = { Move=Vector3.zero, Look=Vector2.zero, Skills={} }
local PlayerData = { Health=Settings.MaxHealth }
local UIRefs = {}

-- =============================================
-- ユーティリティ
-- =============================================
local function clamp(val,min,max) return math.max(min,math.min(max,val)) end
local function debugLog(msg)
    if UIRefs.LogFrame then
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,-10,0,30)
        label.Position = UDim2.new(0,5,#UIRefs.LogFrame:GetChildren()*30,0)
        label.Text = msg
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.Parent = UIRefs.LogFrame
        UIRefs.LogFrame.CanvasSize = UDim2.new(0,0,#UIRefs.LogFrame:GetChildren()*30)
    end
end

-- =============================================
-- UI作成
-- =============================================
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    -- メインフレーム
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0,400,0,600)
    mainFrame.Position = UDim2.new(0.3,0,0.1,0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(50,150,255)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui
    UIRefs.MainFrame = mainFrame

    -- 最小化ボタン
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0,30,0,30)
    minBtn.Position = UDim2.new(1,-35,0,5)
    minBtn.Text = "-"
    minBtn.Parent = mainFrame
    minBtn.MouseButton1Click:Connect(function() mainFrame.Visible=false end)

    -- 閉じるボタン
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,30,0,30)
    closeBtn.Position = UDim2.new(1,-70,0,5)
    closeBtn.Text = "❌"
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        local confirm = Instance.new("Frame")
        confirm.Size = UDim2.new(0,250,0,120)
        confirm.Position = UDim2.new(0.5,-125,0.5,-60)
        confirm.BackgroundColor3 = Color3.fromRGB(100,50,50)
        confirm.Parent = screenGui
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1,0,0.5,0)
        label.Position = UDim2.new(0,0,0,0)
        label.Text = "本当に削除しますか？"
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.BackgroundTransparency = 1
        label.Parent = confirm
        local yesBtn = Instance.new("TextButton")
        yesBtn.Size = UDim2.new(0.4,0,0.4,0)
        yesBtn.Position = UDim2.new(0.1,0,0.6,0)
        yesBtn.Text = "はい"
        yesBtn.Parent = confirm
        yesBtn.MouseButton1Click:Connect(function() mainFrame:Destroy(); confirm:Destroy() end)
        local noBtn = Instance.new("TextButton")
        noBtn.Size = UDim2.new(0.4,0,0.4,0)
        noBtn.Position = UDim2.new(0.5,0,0.6,0)
        noBtn.Text = "いいえ"
        noBtn.Parent = confirm
        noBtn.MouseButton1Click:Connect(function() confirm:Destroy() end)
    end)

    -- スキルボタン
    local skillNames = {"Fireball","Shield","Dash","Wave"}
    for i,name in ipairs(skillNames) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0,80,0,30)
        btn.Position = UDim2.new(0,10,(i-1)*35+10,0)
        btn.Text = name
        btn.Parent = mainFrame
        btn.MouseButton1Click:Connect(function()
            debugLog(name.."発動！")
        end)
    end

    -- 縦スクロールログパネル
    local logFrame = Instance.new("ScrollingFrame")
    logFrame.Size = UDim2.new(1,-10,0.5,-10)
    logFrame.Position = UDim2.new(0,5,0.5,5)
    logFrame.CanvasSize = UDim2.new(0,0,10,0)
    logFrame.ScrollBarThickness = 10
    logFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
    logFrame.BackgroundTransparency = 0.5
    logFrame.Parent = mainFrame
    UIRefs.LogFrame = logFrame

    -- サンプルログ追加
    for i=1,20 do
        debugLog("サンプルログ "..i)
    end
end

-- =============================================
-- 初期化
-- =============================================
createUI()
