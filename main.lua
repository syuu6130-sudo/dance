--// 完全Executer対応フリーダンススクリプト //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local Humanoid = char:WaitForChild("Humanoid")
local HumanoidRootPart = char:WaitForChild("HumanoidRootPart")

-- 関節取得
local function getMotor(part, jointName)
    return part:FindFirstChild(jointName) or Instance.new("Motor6D")
end

local RightShoulder = getMotor(char:WaitForChild("RightUpperArm"), "RightShoulder")
local LeftShoulder = getMotor(char:WaitForChild("LeftUpperArm"), "LeftShoulder")
local RootJoint = getMotor(HumanoidRootPart, "RootJoint")
local Neck = getMotor(char:WaitForChild("Head"), "Neck")
local RightHip = getMotor(char:WaitForChild("RightUpperLeg"), "RightHip")
local LeftHip = getMotor(char:WaitForChild("LeftUpperLeg"), "LeftHip")

-- 簡易設定
local cf, v3, euler, sin, cos, abs = CFrame.new, Vector3.new, CFrame.fromEulerAnglesXYZ, math.sin, math.cos, math.abs
local sine = 0
local mode = "idle" -- 初期モード

-- アニメーション用ループ
RunService.RenderStepped:Connect(function(delta)
    if not char.Parent then return end
    sine += delta * 2 -- アニメーション速度調整

    local vel = HumanoidRootPart.Velocity.Magnitude
    if vel < 1 then
        mode = "idle"
    elseif vel < 10 then
        mode = "walk"
    else
        mode = "run"
    end

    if mode == "idle" then
        RightShoulder.C0 = RightShoulder.C0:Lerp(cf(1,0.5,0)*euler(0,0,0.2*sin(sine)), 0.2)
        LeftShoulder.C0 = LeftShoulder.C0:Lerp(cf(-1,0.5,0)*euler(0,0,-0.2*sin(sine)), 0.2)
        RightHip.C0 = RightHip.C0:Lerp(cf(0.5,-1,0)*euler(0,0,0), 0.2)
        LeftHip.C0 = LeftHip.C0:Lerp(cf(-0.5,-1,0)*euler(0,0,0), 0.2)
    elseif mode == "walk" then
        RightShoulder.C0 = RightShoulder.C0:Lerp(cf(1,0.5,0)*euler(0.3*sin(sine),0,0.3*sin(sine)), 0.2)
        LeftShoulder.C0 = LeftShoulder.C0:Lerp(cf(-1,0.5,0)*euler(-0.3*sin(sine),0,-0.3*sin(sine)), 0.2)
        RightHip.C0 = RightHip.C0:Lerp(cf(0.5,-1,0)*euler(-0.3*sin(sine),0,0), 0.2)
        LeftHip.C0 = LeftHip.C0:Lerp(cf(-0.5,-1,0)*euler(0.3*sin(sine),0,0), 0.2)
    elseif mode == "run" then
        RightShoulder.C0 = RightShoulder.C0:Lerp(cf(1,0.5,0)*euler(0.6*sin(sine),0,0.6*sin(sine)), 0.2)
        LeftShoulder.C0 = LeftShoulder.C0:Lerp(cf(-1,0.5,0)*euler(-0.6*sin(sine),0,-0.6*sin(sine)), 0.2)
        RightHip.C0 = RightHip.C0:Lerp(cf(0.5,-1,0)*euler(-0.6*sin(sine),0,0), 0.2)
        LeftHip.C0 = LeftHip.C0:Lerp(cf(-0.5,-1,0)*euler(0.6*sin(sine),0,0), 0.2)
    end
end)
