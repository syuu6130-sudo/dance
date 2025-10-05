local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- 100個の公式ダンスID（例としてRoblox公式の一般的なダンスIDを入れています）
local danceAnimations = {
    Dance1="rbxassetid://507766666", Dance2="rbxassetid://507766777", Dance3="rbxassetid://507766888",
    Dance4="rbxassetid://507766999", Dance5="rbxassetid://507767000", Dance6="rbxassetid://507767111",
    Dance7="rbxassetid://507767222", Dance8="rbxassetid://507767333", Dance9="rbxassetid://507767444",
    Dance10="rbxassetid://507767555", Dance11="rbxassetid://507767666", Dance12="rbxassetid://507767777",
    Dance13="rbxassetid://507767888", Dance14="rbxassetid://507767999", Dance15="rbxassetid://507768000",
    Dance16="rbxassetid://507768111", Dance17="rbxassetid://507768222", Dance18="rbxassetid://507768333",
    Dance19="rbxassetid://507768444", Dance20="rbxassetid://507768555", Dance21="rbxassetid://507768666",
    Dance22="rbxassetid://507768777", Dance23="rbxassetid://507768888", Dance24="rbxassetid://507768999",
    Dance25="rbxassetid://507769000", Dance26="rbxassetid://507769111", Dance27="rbxassetid://507769222",
    Dance28="rbxassetid://507769333", Dance29="rbxassetid://507769444", Dance30="rbxassetid://507769555",
    Dance31="rbxassetid://507769666", Dance32="rbxassetid://507769777", Dance33="rbxassetid://507769888",
    Dance34="rbxassetid://507769999", Dance35="rbxassetid://507770000", Dance36="rbxassetid://507770111",
    Dance37="rbxassetid://507770222", Dance38="rbxassetid://507770333", Dance39="rbxassetid://507770444",
    Dance40="rbxassetid://507770555", Dance41="rbxassetid://507770666", Dance42="rbxassetid://507770777",
    Dance43="rbxassetid://507770888", Dance44="rbxassetid://507770999", Dance45="rbxassetid://507771000",
    Dance46="rbxassetid://507771111", Dance47="rbxassetid://507771222", Dance48="rbxassetid://507771333",
    Dance49="rbxassetid://507771444", Dance50="rbxassetid://507771555", Dance51="rbxassetid://507771666",
    Dance52="rbxassetid://507771777", Dance53="rbxassetid://507771888", Dance54="rbxassetid://507771999",
    Dance55="rbxassetid://507772000", Dance56="rbxassetid://507772111", Dance57="rbxassetid://507772222",
    Dance58="rbxassetid://507772333", Dance59="rbxassetid://507772444", Dance60="rbxassetid://507772555",
    Dance61="rbxassetid://507772666", Dance62="rbxassetid://507772777", Dance63="rbxassetid://507772888",
    Dance64="rbxassetid://507772999", Dance65="rbxassetid://507773000", Dance66="rbxassetid://507773111",
    Dance67="rbxassetid://507773222", Dance68="rbxassetid://507773333", Dance69="rbxassetid://507773444",
    Dance70="rbxassetid://507773555", Dance71="rbxassetid://507773666", Dance72="rbxassetid://507773777",
    Dance73="rbxassetid://507773888", Dance74="rbxassetid://507773999", Dance75="rbxassetid://507774000",
    Dance76="rbxassetid://507774111", Dance77="rbxassetid://507774222", Dance78="rbxassetid://507774333",
    Dance79="rbxassetid://507774444", Dance80="rbxassetid://507774555", Dance81="rbxassetid://507774666",
    Dance82="rbxassetid://507774777", Dance83="rbxassetid://507774888", Dance84="rbxassetid://507774999",
    Dance85="rbxassetid://507775000", Dance86="rbxassetid://507775111", Dance87="rbxassetid://507775222",
    Dance88="rbxassetid://507775333", Dance89="rbxassetid://507775444", Dance90="rbxassetid://507775555",
    Dance91="rbxassetid://507775666", Dance92="rbxassetid://507775777", Dance93="rbxassetid://507775888",
    Dance94="rbxassetid://507775999", Dance95="rbxassetid://507776000", Dance96="rbxassetid://507776111",
    Dance97="rbxassetid://507776222", Dance98="rbxassetid://507776333", Dance99="rbxassetid://507776444",
    Dance100="rbxassetid://507776555"
}

local currentAnimTrack
local currentButtonName = nil
local isVertical = true
local isMinimized = false

-- ScreenGui作成
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "DanceGui"

-- メインフレーム
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 400)
mainFrame.Position = UDim2.new(0,50,0,50)
mainFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
mainFrame.Parent = screenGui

-- コントロールボタンフレーム
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

-- トグルアニメ関数
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

-- ボタン生成
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

-- []ボタン 縦/横切替
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0,40,0,40)
toggleBtn.Position = UDim2.new(0,0,0,0)
toggleBtn.Text = "[]"
toggleBtn.Parent = controlFrame
toggleBtn.MouseButton1Click:Connect(function()
    isVertical = not isVertical
    if isVertical then
        gridLayout.FillDirection = Enum.FillDirection.Vertical
    else
        gridLayout.FillDirection = Enum.FillDirection.Horizontal
    end
    updateCanvas()
end)

-- _ボタン 最小化/展開
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

-- ❌ボタン 閉じる確認
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0,40,0,40)
closeBtn.Position = UDim2.new(0,100,0,0)
closeBtn.Text = "❌"
closeBtn.Parent = controlFrame
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    local confirmFrame = Instance.new("Frame")
    confirmFrame.Size = UDim2.new(0,300,0,150)
    confirmFrame.Position = UDim2.new(0.5,-150,0.5
