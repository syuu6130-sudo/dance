-- =====================================================
-- 世界一長い実用Luaスクリプト骨格（機能満載版）
-- =====================================================
-- 概要:
-- 1万行規模を想定したLuaスクリプト骨格
-- プレイヤー制御、UI、スキル、アイテム、同期、デバッグ、スマホ対応などを統合
-- =====================================================

-- =============================================
-- SETTINGS / CONFIG
-- =============================================
local Settings = {
    Control = "pc", -- "pc" or "mobile"
    Sensitivity = 1.2,
    LerpSpeed = 0.12,
    DashSpeed = 100,
    JumpPower = 50,
    MaxHealth = 100,
    AutoHealRate = 2,
    SkillCooldowns = {
        Fireball = 5,
        Shield = 10,
        Dash = 2
    },
    UITheme = {
        PrimaryColor = Color3.fromRGB(50, 150, 255),
        SecondaryColor = Color3.fromRGB(200, 200, 200),
        Transparency = 0.3
    }
}

-- =============================================
-- SERVICES
-- =============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- =============================================
-- GLOBAL VARIABLES
-- =============================================
local InputState = {
    Move = Vector3.zero,
    Look = Vector2.zero,
    Skills = {},
    DashActive = false
}

local PlayerData = {
    Health = Settings.MaxHealth,
    Buffs = {},
    Debuffs = {},
    Inventory = {},
    Equipped = {},
    Stats = { Strength = 10, Agility = 10, Intelligence = 10 }
}

local UIRefs = {}
local DebugLogs = {}

-- =============================================
-- UTILITY FUNCTIONS
-- =============================================
local function clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function tableMerge(t1, t2)
    for k,v in pairs(t2) do t1[k]=v end
    return t1
end

local function debugLog(msg)
    table.insert(DebugLogs, msg)
    if #DebugLogs > 1000 then table.remove(DebugLogs,1) end
    print("[DEBUG]", msg)
end

-- =============================================
-- ARM CONTROL MODULE
-- =============================================
local ArmJoints = {}
do
    local function getArmJoints(char, side)
        local upper = char:FindFirstChild(side.."UpperArm")
        local lower = char:FindFirstChild(side.."LowerArm")
        local hand = char:FindFirstChild(side.."Hand")
        if upper and lower and hand then
            return {
                Upper = upper:FindFirstChildOfClass("Motor6D"),
                Lower = lower:FindFirstChildOfClass("Motor6D"),
                Hand = hand:FindFirstChildOfClass("Motor6D")
            }
        end
    end
    ArmJoints.Right = getArmJoints(character,"Right")
    ArmJoints.Left = getArmJoints(character,"Left")
end

-- =============================================
-- UI MODULE
-- =============================================
local function createUI()
    local playerGui = player:WaitForChild("PlayerGui",5)
    if not playerGui then debugLog("PlayerGui取得失敗") return end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false

    -- ステータスバー
    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(0.3,0,0.03,0)
    healthBar.Position = UDim2.new(0.35,0,0.95,0)
    healthBar.BackgroundColor3 = Settings.UITheme.PrimaryColor
    healthBar.Parent = screenGui
    UIRefs.HealthBar = healthBar

    -- ミニマップ (仮)
    local miniMap = Instance.new("Frame")
    miniMap.Size = UDim2.new(0.2,0,0.2,0)
    miniMap.Position = UDim2.new(0.8,0,0,0)
    miniMap.BackgroundColor3 = Settings.UITheme.SecondaryColor
    miniMap.BackgroundTransparency = 0.5
    miniMap.Parent = screenGui
    UIRefs.MiniMap = miniMap

    debugLog("UI生成完了")
end

-- =============================================
-- INPUT MODULE
-- =============================================
local function setupInput()
    if Settings.Control == "pc" then
        local lastPos = UserInputService:GetMouseLocation()
        RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            local delta = (mousePos - lastPos) * 0.005
            InputState.Look = Vector2.new(delta.X, delta.Y)
            lastPos = mousePos
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Space then
                    humanoid.Jump = true
                end
            end
        end)
    else
        -- モバイル仮想スティック (後で展開)
    end
end

-- =============================================
-- SKILL MODULE
-- =============================================
local Skills = {}
do
    Skills.Fireball = function()
        debugLog("Fireball発射")
        -- 弾作成・飛ばす処理仮
    end

    Skills.Shield = function()
        debugLog("Shield発動")
        -- バリア処理
    end

    Skills.Dash = function()
        debugLog("Dash開始")
        InputState.DashActive = true
        delay(Settings.SkillCooldowns.Dash, function() InputState.DashActive = false end)
    end
end

-- =============================================
-- PLAYER LOOP
-- =============================================
RunService.RenderStepped:Connect(function(delta)
    -- 移動制御
    local moveVector = Vector3.zero
    if InputState.DashActive then
        moveVector = humanoid.MoveDirection * Settings.DashSpeed
    else
        moveVector = humanoid.MoveDirection
    end
    humanoid:Move(moveVector, true)

    -- 腕制御 (VR風)
    local function updateArm(joints, input)
        if not joints then return end
        local pitch = -input.Y * Settings.Sensitivity
        local yaw = input.X * Settings.Sensitivity
        if joints.Upper then joints.Upper.C0 = joints.Upper.C0:Lerp(CFrame.Angles(pitch,yaw,0),0.12) end
        if joints.Lower then joints.Lower.C0 = joints.Lower.C0:Lerp(CFrame.Angles(pitch/2,yaw/2,0),0.12) end
        if joints.Hand then joints.Hand.C0 = joints.Hand.C0:Lerp(CFrame.Angles(pitch/3,yaw/3,0),0.12) end
    end
    updateArm(ArmJoints.Right, InputState.Look)
    updateArm(ArmJoints.Left, InputState.Look)

    -- 自動回復
    PlayerData.Health = clamp(PlayerData.Health + Settings.AutoHealRate*delta, 0, Settings.MaxHealth)
    if UIRefs.HealthBar then
        UIRefs.HealthBar.Size = UDim2.new(PlayerData.Health/Settings.MaxHealth*0.3,0,0.03,0)
    end
end)

-- =============================================
-- INITIALIZATION
-- =============================================
createUI()
setupInput()

-- =============================================
-- CHARACTER ADDED HANDLER
-- =============================================
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    ArmJoints.Right = character:FindFirstChild("RightUpperArm") and character.RightUpperArm:FindFirstChildOfClass("Motor6D") or nil
    ArmJoints.Left = character:FindFirstChild("LeftUpperArm") and character.LeftUpperArm:FindFirstChildOfClass("Motor6D") or nil
    debugLog("Characterリスポーン完了")
end)

-- =============================================
-- DEBUG MODULE
-- =============================================
local function showDebugInfo()
    print("Health:", PlayerData.Health)
    print("Buffs:", #PlayerData.Buffs, "Debuffs:", #PlayerData.Debuffs)
    print("Inventory:", #PlayerData.Inventory)
    print("Skills:", table.concat({"Fireball","Shield","Dash"},","))
end
