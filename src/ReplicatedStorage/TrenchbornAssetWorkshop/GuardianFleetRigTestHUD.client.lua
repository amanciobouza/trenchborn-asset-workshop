local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("GuardianFleetRigTestRemote")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local animationLibrary = require(packageFolder:WaitForChild("GuardianAnimationLibrary"))
local idleTrack
local controlEnabled = false
local controlledModel
local previousCameraSubject
local keyState = {}
local lastMoveSent = 0
local wasMoving = false
local walkStartedAt = 0
local plantedSide
local footLocks = {}
local hipJoints = {}

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
	idleTrack.Priority = sequence.Priority
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
panel.Size = UDim2.fromOffset(310, 480)
panel.BackgroundColor3 = Color3.fromRGB(20, 27, 31)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(245, 285)
sizeConstraint.MaxSize = Vector2.new(340, 510)
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
	{"WALK", "Walk", Color3.fromRGB(94, 116, 184)},
	{"CONTROL GUARDIAN", "ControlGuardian", Color3.fromRGB(132, 78, 176)},
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
		if definition[2] ~= "IdleLoop" and definition[2] ~= "AlertIdle" and definition[2] ~= "ControlGuardian" then stopIdle() end
		status.Text = "RUNNING: " .. definition[1]
		status.TextColor3 = Color3.fromRGB(235, 178, 55)
		remote:FireServer(definition[2])
	end)
	buttons[definition[2]] = button
end



local function clearFootLocks()
	for _, lock in pairs(footLocks) do
		if lock.control then lock.control:Destroy() end
		if lock.target then lock.target:Destroy() end
		if lock.pole then lock.pole:Destroy() end
	end
	footLocks = {}
	plantedSide = nil
end

local function setupFootLocks(model)
	clearFootLocks()
	local humanoid = model:FindFirstChildWhichIsA("Humanoid")
	assert(humanoid, "Guardian Humanoid not found for foot lock")
	for _, side in ipairs({"Left", "Right"}) do
		local upperLeg = model:FindFirstChild(side .. "UpperLeg")
		local knee = model:FindFirstChild(side .. "LowerLeg")
		local foot = model:FindFirstChild(side .. "Foot")
		local root = model:FindFirstChild("HumanoidRootPart")
		assert(upperLeg and knee and foot and root, side .. " Guardian leg controls not found")

		local target = Instance.new("Part")
		target.Name = side .. "FootLockTarget"
		target.Size = Vector3.new(0.4, 0.4, 0.4)
		target.Transparency = 1
		target.Anchored = true
		target.CanCollide = false
		target.CanTouch = false
		target.CanQuery = false
		target.CFrame = foot.CFrame
		target.Parent = workspace

		local sideSign = side == "Left" and -1 or 1
		local pole = Instance.new("Part")
		pole.Name = side .. "KneePoleTarget"
		pole.Size = Vector3.new(0.4, 0.4, 0.4)
		pole.Transparency = 1
		pole.Anchored = true
		pole.CanCollide = false
		pole.CanTouch = false
		pole.CanQuery = false
		pole.Position = root.Position
			+ root.CFrame.RightVector * sideSign * 4.5
			+ root.CFrame.LookVector * 12
			- root.CFrame.UpVector * 10
		pole.Parent = workspace

		local control = Instance.new("IKControl")
		control.Name = side .. "FootLock"
		control.Type = Enum.IKControlType.Position
		control.ChainRoot = upperLeg
		control.EndEffector = foot
		control.Target = target
		control.Pole = pole
		control.SmoothTime = 0.06
		control.Weight = 0
		control.Priority = 20
		control.Parent = humanoid

		footLocks[side] = {
			control = control,
			target = target,
			pole = pole,
			foot = foot,
			knee = knee,
			root = root,
			sideSign = sideSign,
		}
	end
end

local function updateFootLock(moving, moveDirection)
	for _, lock in pairs(footLocks) do
		lock.pole.Position = lock.root.Position
			+ lock.root.CFrame.RightVector * lock.sideSign * 4.5
			+ lock.root.CFrame.LookVector * 12
			- lock.root.CFrame.UpVector * 10
	end
	if not moving then
		for _, lock in pairs(footLocks) do lock.control.Weight = 0 end
		plantedSide = nil
		return
	end
	local root = controlledModel and controlledModel:FindFirstChild("HumanoidRootPart")
	local flatFacing = root and Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
	local aligned = flatFacing and flatFacing.Magnitude > 0
		and moveDirection.Magnitude > 0
		and flatFacing.Unit:Dot(moveDirection.Unit) > 0.985
	if not aligned or os.clock() - walkStartedAt < 0.15 then
		for _, lock in pairs(footLocks) do lock.control.Weight = 0 end
		plantedSide = nil
		return
	end
	local cyclePhase = (os.clock() - walkStartedAt) % 2
	local nextSide = cyclePhase < 1 and "Left" or "Right"
	if nextSide ~= plantedSide then
		plantedSide = nextSide
		for side, lock in pairs(footLocks) do
			if side == plantedSide then
				lock.target.CFrame = lock.foot.CFrame
				lock.control.Weight = 1
			else
				lock.control.Weight = 0
			end
		end
	end
end

local function controlInput(_, inputState, inputObject)
	local active = inputState ~= Enum.UserInputState.End and inputState ~= Enum.UserInputState.Cancel
	keyState[inputObject.KeyCode] = active
	return Enum.ContextActionResult.Sink
end

local function setControl(enabled, model)
	controlEnabled = enabled
	controlledModel = enabled and model or nil
	keyState = {}
	wasMoving = false
	local camera = workspace.CurrentCamera
	if enabled then
		previousCameraSubject = camera.CameraSubject
		local subject = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("Humanoid")
		camera.CameraSubject = subject
		ContextActionService:BindActionAtPriority(
			"GuardianWorkshopControl",
			controlInput,
			false,
			Enum.ContextActionPriority.High.Value + 100,
			Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
			Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right
		)
		setupFootLocks(model)
		hipJoints = {
			model:FindFirstChild("LeftHip", true),
			model:FindFirstChild("RightHip", true),
		}
		buttons.ControlGuardian.Text = "RELEASE GUARDIAN"
		status.Text = "GUARDIAN CONTROL: WASD"
		status.TextColor3 = Color3.fromRGB(194, 146, 235)
		playSequence(model, "BuildIdle", "GuardianControlledIdle")
	else
		ContextActionService:UnbindAction("GuardianWorkshopControl")
		remote:FireServer("ControlMove", Vector3.zero)
		local humanoid = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid")
		camera.CameraSubject = previousCameraSubject or humanoid
		clearFootLocks()
		hipJoints = {}
		buttons.ControlGuardian.Text = "CONTROL GUARDIAN"
		status.Text = "GUARDIAN RELEASED"
		status.TextColor3 = Color3.fromRGB(116, 220, 169)
		stopIdle()
	end
end


RunService.PreSimulation:Connect(function()
	if not controlEnabled then return end
	for _, joint in ipairs(hipJoints) do
		if joint and joint:IsA("Motor6D") then
			local transform = joint.Transform
			local flexion = select(1, transform:ToOrientation())
			joint.Transform = CFrame.new(transform.Position) * CFrame.Angles(flexion, 0, 0)
		end
	end
end)

RunService.RenderStepped:Connect(function()
	if not controlEnabled or not controlledModel then return end
	local x = ((keyState[Enum.KeyCode.D] or keyState[Enum.KeyCode.Right]) and 1 or 0)
		- ((keyState[Enum.KeyCode.A] or keyState[Enum.KeyCode.Left]) and 1 or 0)
	local z = ((keyState[Enum.KeyCode.S] or keyState[Enum.KeyCode.Down]) and 1 or 0)
		- ((keyState[Enum.KeyCode.W] or keyState[Enum.KeyCode.Up]) and 1 or 0)

	local camera = workspace.CurrentCamera
	local forward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
	local right = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
	if forward.Magnitude > 0 then forward = forward.Unit end
	if right.Magnitude > 0 then right = right.Unit end
	local direction = right * x + forward * -z
	if direction.Magnitude > 1 then direction = direction.Unit end
	local moving = direction.Magnitude > 0.05
	if moving ~= wasMoving then
		wasMoving = moving
		if moving then
			walkStartedAt = os.clock()
			plantedSide = nil
			playSequence(controlledModel, "BuildWalk", "GuardianControlledWalk")
		else
			playSequence(controlledModel, "BuildIdle", "GuardianControlledIdle")
		end
	end
	updateFootLock(moving, direction)
	if os.clock() - lastMoveSent >= 0.07 then
		lastMoveSent = os.clock()
		remote:FireServer("ControlMove", direction)
	end
end)

remote.OnClientEvent:Connect(function(message, payload)
	if message == "ControlEnabled" then
		setControl(true, payload)
		return
	elseif message == "ControlDisabled" then
		setControl(false)
		return
	end
	if message == "PlayIdle" or message == "PlayAlertIdle" or message == "PlayWalk" then
		local builders = {
			PlayIdle = {"BuildIdle", "GuardianIdlePreview"},
			PlayAlertIdle = {"BuildAlertIdle", "GuardianAlertIdlePreview"},
			PlayWalk = {"BuildWalk", "GuardianWalkPreview"},
		}
		local selection = builders[message]
		local builderName = selection[1]
		local previewName = selection[2]
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
