-- =====================================================
-- 世界一長いLuaスクリプト（基盤部分）
-- 機能: UI統合・スマホ対応・ドラッグ・縦スクロール・基本操作
-- =====================================================

-- =============================================
-- SETTINGS
-- =============================================
local Settings = {
    Control = "mobile", -- "pc" or "mobile"
    Sensitivity = 1.2,
    LerpSpeed = 0.12,
    MaxHealth = 100,
    AutoHealRate = 2,
    SkillCooldowns = { Fireball=5, Shield=10, Dash=2 },
    UITheme = {
        PrimaryColor = Color3.fromRGB(50,150,255),
        SecondaryColor = Color3.fromRGB(200,200,200),
        Transparency = 0.3
    }
}

-- =============================================
-- SERVICES
-- =============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- =============================================
-- GLOBAL VARIABLES
-- =============================================
local InputState = { Move=Vector3.zero, Look=Vector2.zero, Skills={}, DashActive=false }
local PlayerData = { Health=Settings.MaxHealth, Buffs={}, Debuffs={}, Inventory={}, Equipped={}, Stats={Strength=10,Agility=10,Intelligence=10} }
local UIRefs = {}

-- =============================================
-- UTILITY FUNCTIONS
-- =============================================
local function clamp(val,min,max) return math.max(min,math.min(max,val)) end
local function lerp(a,b,t) return a + (b-a)*t end
local function debugLog(msg) print("[DEBUG]",msg) end

-- =============================================
-- UI MODULE
-- =============================================
local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false

    -- メインフレーム
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0,400,0,600)
    mainFrame.Position = UDim2.new(0.3,0,0.1,0)
    mainFrame.BackgroundColor3 = Settings.UITheme.PrimaryColor
    mainFrame.BackgroundTransparency = Settings.UITheme.Transparency
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
    minBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
    end)

    -- 閉じるボタン（❌）
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0,30,0,30)
    closeBtn.Position = UDim2.new(1,-70,0,5)
    closeBtn.Text = "❌"
    closeBtn.Parent = mainFrame
    closeBtn.MouseButton1Click:Connect(function()
        local yesNo = Instance.new("TextButton")
        yesNo.Size = UDim2.new(0,200,0,100)
        yesNo.Position = UDim2.new(0.5,-100,0.5,-50)
        yesNo.Text = "本当に削除しますか？ はい / いいえ"
        yesNo.Parent = screenGui
        yesNo.MouseButton1Click:Connect(function()
            yesNo:Destroy()
            mainFrame:Destroy()
        end)
    end)

    -- ログパネル（縦スクロール）
    local logFrame = Instance.new("ScrollingFrame")
    logFrame.Size = UDim2.new(1,-10,0.5,-10)
    logFrame.Position = UDim2.new(0,5,0.5,5)
    logFrame.CanvasSize = UDim2.new(0,0,10,0) --縦長
    logFrame.ScrollBarThickness = 10
    logFrame.BackgroundColor3 = Settings.UITheme.SecondaryColor
    logFrame.BackgroundTransparency = 0.5
    logFrame.Parent = mainFrame
    UIRefs.LogPanel = logFrame
end

-- =============================================
-- INPUT MODULE（スマホ対応）
-- =============================================
local function setupMobileSticks()
    local screenGui = player:WaitForChild("PlayerGui")
    local function createStick(side)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0,120,0,120)
        frame.AnchorPoint = Vector2.new(0.5,0.5)
        frame.BackgroundColor3 = Color3.fromRGB(50,50,50)
        frame.BackgroundTransparency = 0.3
        frame.Position = side=="left" and UDim2.new(0.25,0,0.85,0) or UDim2.new(0.75,0,0.85,0)
        frame.Parent = screenGui

        local stick = Instance.new("ImageButton")
        stick.Size = UDim2.new(0,60,0,60)
        stick.Position = UDim2.new(0.5,0,0.5,0)
        stick.AnchorPoint = Vector2.new(0.5,0.5)
        stick.BackgroundTransparency = 0.5
        stick.AutoButtonColor = false
        stick.Parent = frame
        return frame,stick
    end

    local leftF,leftS = createStick("left")
    local rightF,rightS = createStick("right")
    local function stickHandler(stick,frame,updateFunc)
        local dragging = false
        local center = stick.Position
        stick.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Touch then dragging=true end
        end)
        stick.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Touch then
                dragging=false
                stick.Position=center
                updateFunc(Vector2.zero)
            end
        end)
        stick.InputChanged:Connect(function(input)
            if dragging and input.UserInputType==Enum.UserInputType.Touch then
                local rel = frame.AbsolutePosition + frame.AbsoluteSize/2
                local offset = Vector2.new(input.Position.X-rel.X,input.Position.Y-rel.Y)
                local maxDist = frame.AbsoluteSize.X/2
                if offset.Magnitude>maxDist then offset = offset.Unit*maxDist end
                stick.Position=UDim2.new(0.5,offset.X,0.5,offset.Y)
                updateFunc(offset/maxDist)
            end
        end)
    end

    stickHandler(leftS,leftF,function(vec) InputState.Move=Vector3.new(vec.X,0,vec.Y) end)
    stickHandler(rightS,rightF,function(vec) InputState.Look=vec end)
end

-- =============================================
-- GAME LOOP
-- =============================================
RunService.RenderStepped:Connect(function(delta)
    -- 移動制御
    humanoid:Move(InputState.Move, true)

    -- 自動回復
    PlayerData.Health = clamp(PlayerData.Health + Settings.AutoHealRate*delta, 0, Settings.MaxHealth)
end)

-- =============================================
-- INITIALIZATION
-- =============================================
createUI()
if Settings.Control=="mobile" then setupMobileSticks() end
