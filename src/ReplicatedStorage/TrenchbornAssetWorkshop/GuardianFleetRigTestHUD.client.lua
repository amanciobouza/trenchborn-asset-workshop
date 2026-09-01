local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("GuardianFleetRigTestRemote")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local animationLibrary = require(packageFolder:WaitForChild("GuardianAnimationLibrary"))
local idleTrack

local function stopIdle()
	if idleTrack and idleTrack.IsPlaying then
		idleTrack:Stop(0.2)
	end
end

local function playSequence(model, builderName, previewName)
	stopIdle()
	local animator = model and model:FindFirstChildWhichIsA("Animator", true)
	assert(animator, "Guardian Animator not found")
	local builder = animationLibrary[builderName]
	assert(type(builder) == "function", "Animation builder not found: " .. builderName)
	local sequence = builder()
	local temporaryId = KeyframeSequenceProvider:RegisterKeyframeSequence(sequence)
	local animation = Instance.new("Animation")
	animation.Name = previewName
	animation.AnimationId = temporaryId
	idleTrack = animator:LoadAnimation(animation)
	idleTrack.Looped = true
	idleTrack.Priority = Enum.AnimationPriority.Idle
	idleTrack:Play(0.35)
end

local old = player.PlayerGui:FindFirstChild("GuardianFleetRigTestHUD")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "GuardianFleetRigTestHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 50
gui.Parent = player.PlayerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0.5)
panel.Position = UDim2.new(1, -18, 0.5, 0)
panel.Size = UDim2.fromOffset(310, 410)
panel.BackgroundColor3 = Color3.fromRGB(20, 27, 31)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(245, 285)
sizeConstraint.MaxSize = Vector2.new(340, 440)
sizeConstraint.Parent = panel

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(73, 151, 173)
stroke.Thickness = 2
stroke.Transparency = 0.25
stroke.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 14)
padding.PaddingBottom = UDim.new(0, 14)
padding.PaddingLeft = UDim.new(0, 14)
padding.PaddingRight = UDim.new(0, 14)
padding.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 38)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "GUARDIAN ANIMATION TEST"
title.TextColor3 = Color3.fromRGB(226, 241, 244)
title.TextScaled = true
title.Parent = panel

local grid = Instance.new("Frame")
grid.Name = "Buttons"
grid.Position = UDim2.fromOffset(0, 50)
grid.Size = UDim2.new(1, 0, 1, -86)
grid.BackgroundTransparency = 1
grid.Parent = panel

local layout = Instance.new("UIGridLayout")
layout.CellPadding = UDim2.fromOffset(8, 8)
layout.CellSize = UDim2.new(0.5, -4, 0, 66)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = grid

local status = Instance.new("TextLabel")
status.Name = "Status"
status.AnchorPoint = Vector2.new(0, 1)
status.Position = UDim2.new(0, 0, 1, 0)
status.Size = UDim2.new(1, 0, 0, 28)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamMedium
status.Text = "READY"
status.TextColor3 = Color3.fromRGB(116, 220, 169)
status.TextScaled = true
status.Parent = panel

local definitions = {
	{"LEFT SHOULDER", "LeftShoulder", Color3.fromRGB(48, 128, 158)},
	{"LEFT ELBOW", "LeftElbow", Color3.fromRGB(48, 128, 158)},
	{"RIGHT ARM", "RightArm", Color3.fromRGB(48, 128, 158)},
	{"KNEE LOAD", "KneeLoad", Color3.fromRGB(48, 145, 104)},
	{"IDLE LOOP", "IdleLoop", Color3.fromRGB(48, 145, 104)},
	{"ALERT IDLE", "AlertIdle", Color3.fromRGB(188, 112, 45)},
	{"NEUTRAL", "Neutral", Color3.fromRGB(96, 102, 110)},
}

local buttons = {}
for order, definition in ipairs(definitions) do
	local button = Instance.new("TextButton")
	button.Name = definition[2]
	button.LayoutOrder = order
	button.BackgroundColor3 = definition[3]
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Font = Enum.Font.GothamBold
	button.Text = definition[1]
	button.TextColor3 = Color3.fromRGB(238, 247, 249)
	button.TextScaled = true
	button.TextWrapped = true
	button.Parent = grid
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = button
	button.Activated:Connect(function()
		if definition[2] ~= "IdleLoop" and definition[2] ~= "AlertIdle" then stopIdle() end
		status.Text = "RUNNING: " .. definition[1]
		status.TextColor3 = Color3.fromRGB(235, 178, 55)
		remote:FireServer(definition[2])
	end)
	buttons[definition[2]] = button
end

remote.OnClientEvent:Connect(function(message, payload)
	if message == "PlayIdle" or message == "PlayAlertIdle" then
		local builderName = message == "PlayIdle" and "BuildIdle" or "BuildAlertIdle"
		local previewName = message == "PlayIdle" and "GuardianIdlePreview" or "GuardianAlertIdlePreview"
		local success, err = pcall(playSequence, payload, builderName, previewName)
		if not success then
			status.Text = "ANIMATION ERROR"
			status.TextColor3 = Color3.fromRGB(235, 92, 82)
			warn("Guardian animation preview failed:", err)
		end
		return
	end
	if message ~= "Completed" then return end
	local button = buttons[payload]
	status.Text = button and ("ACTIVE: " .. button.Text) or "READY"
	status.TextColor3 = Color3.fromRGB(116, 220, 169)
end)
