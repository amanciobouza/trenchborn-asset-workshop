local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("GuardianFleetRigTestRemote")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local animationLibrary = require(packageFolder:WaitForChild("GuardianAnimationLibrary"))
local idleTrack
local reactionTrack
local lastAnimatedModel
local playbackGeneration = 0
local controlEnabled = false
local controlledModel
local previousCameraSubject
local keyState = {}
local lastMoveSent = 0
local wasMoving = false
local wasRunning = false
local wasBackward = false
local locomotionStepDuration = 1
local currentTurn
local walkStartedAt = 0
local plantedSide
local footLocks = {}
local staggering = false
local defeated = false
local defeatedVisualState = {}
local defeatPowerCycle = 0
local restoreGuardianPower

local function stopIdle()
	playbackGeneration += 1
	local animator = lastAnimatedModel and lastAnimatedModel:FindFirstChildWhichIsA("Animator", true)
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			track:AdjustSpeed(1)
			track:Stop(0.12)
		end
	elseif idleTrack and idleTrack.IsPlaying then
		idleTrack:AdjustSpeed(1)
		idleTrack:Stop(0.12)
	end
	idleTrack = nil
	reactionTrack = nil
end

local function playSequence(model, builderName, previewName)
	stopIdle()
	lastAnimatedModel = model
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
	idleTrack.Looped = sequence.Loop
	idleTrack.Priority = sequence.Priority
	idleTrack:Play(0.2)
	return idleTrack, playbackGeneration
end


local function playReaction(model, builderName, previewName)
	if reactionTrack and reactionTrack.IsPlaying then reactionTrack:Stop(0.05) end
	local animator = model and model:FindFirstChildWhichIsA("Animator", true)
	assert(animator, "Guardian Animator not found")
	local sequence = animationLibrary[builderName]()
	local temporaryId = KeyframeSequenceProvider:RegisterKeyframeSequence(sequence)
	local animation = Instance.new("Animation")
	animation.Name = previewName
	animation.AnimationId = temporaryId
	reactionTrack = animator:LoadAnimation(animation)
	reactionTrack.Looped = false
	reactionTrack.Priority = sequence.Priority
	reactionTrack:Play(0.04)
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
panel.Size = UDim2.fromOffset(280, 430)
panel.BackgroundColor3 = Color3.fromRGB(20, 27, 31)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui

local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(220, 260)
sizeConstraint.MaxSize = Vector2.new(300, 460)
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
grid.Position = UDim2.fromOffset(0, 42)
grid.Size = UDim2.new(1, 0, 1, -72)
grid.BackgroundTransparency = 1
grid.Parent = panel

local layout = Instance.new("UIGridLayout")
layout.CellPadding = UDim2.fromOffset(5, 5)
layout.CellSize = UDim2.new(0.25, -4, 0, 44)
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
	{"WALK BACK", "WalkBackward", Color3.fromRGB(79, 116, 151)},
	{"RUN", "Run", Color3.fromRGB(151, 77, 75)},
	{"TURN LEFT", "TurnLeft", Color3.fromRGB(106, 92, 163)},
	{"TURN RIGHT", "TurnRight", Color3.fromRGB(106, 92, 163)},
	{"FALL", "Fall", Color3.fromRGB(72, 108, 139)},
	{"LAND", "Land", Color3.fromRGB(170, 98, 48)},
	{"DAMAGE", "DamageReact", Color3.fromRGB(184, 61, 61)},
	{"STAGGER", "Stagger", Color3.fromRGB(153, 48, 48)},
	{"DEFEAT", "Defeat", Color3.fromRGB(91, 43, 48)},
	{"TWIN ION", "TwinIonCannons", Color3.fromRGB(38, 124, 175)},
	{"MISSILE SALVO", "ShoulderMissiles", Color3.fromRGB(181, 102, 35)},
	{"DIRECTIONAL AEGIS", "DirectionalAegis", Color3.fromRGB(38, 164, 190)},
	{"SHOCK BATON", "ShockBaton", Color3.fromRGB(74, 145, 86)},
	{"WARNING PULSE", "WarningPulse", Color3.fromRGB(53, 129, 87)},
	{"SHIELD BLOCK", "ShieldBlock", Color3.fromRGB(42, 104, 135)},
	{"PULSE FIRE", "PulseCannonFire", Color3.fromRGB(33, 137, 161)},
	{"NET LAUNCH", "ContainmentNetLaunch", Color3.fromRGB(38, 151, 142)},
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
		if definition[2] ~= "Defeat" then
			defeated = false
			restoreGuardianPower()
		end
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
		control.ChainRoot = knee
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
	local fullCycle = locomotionStepDuration * 2
	local cyclePhase = (os.clock() - walkStartedAt) % fullCycle
	local nextSide = cyclePhase < locomotionStepDuration and "Left" or "Right"
	if nextSide ~= plantedSide then
		plantedSide = nextSide
		for side, lock in pairs(footLocks) do
			if side == plantedSide then
				lock.target.CFrame = lock.foot.CFrame
				-- Running uses a soft lock: full IK over-constrains the short,
				-- powerful stride and twists the mechanical knee sideways.
				lock.control.Weight = wasRunning and 0.35 or 1
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
			Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right,
			Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift
		)
		setupFootLocks(model)
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
		buttons.ControlGuardian.Text = "CONTROL GUARDIAN"
		status.Text = "GUARDIAN RELEASED"
		status.TextColor3 = Color3.fromRGB(116, 220, 169)
		stopIdle()
	end
end


RunService.RenderStepped:Connect(function()
	if not controlEnabled or not controlledModel then return end
	if staggering or defeated then return end
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
	local backward = moving and z > 0 and x == 0
	if backward then
		local root = controlledModel:FindFirstChild("HumanoidRootPart")
		local facing = root and Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
		if facing and facing.Magnitude > 0 then direction = -facing.Unit end
	end
	local desiredTurn
	if moving and not backward then
		local root = controlledModel:FindFirstChild("HumanoidRootPart")
		local facing = root and Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
		if facing and facing.Magnitude > 0 then
			local dot = math.clamp(facing.Unit:Dot(direction.Unit), -1, 1)
			local angle = math.acos(dot)
			if angle > math.rad(12) then
				desiredTurn = facing.Unit:Cross(direction.Unit).Y > 0 and "Left" or "Right"
			end
		end
	end
	local running = moving and not backward and (keyState[Enum.KeyCode.LeftShift] or keyState[Enum.KeyCode.RightShift]) == true
	if moving ~= wasMoving or (moving and (running ~= wasRunning or backward ~= wasBackward)) then
		wasMoving = moving
		wasRunning = running
		wasBackward = backward
		if moving then
			walkStartedAt = os.clock()
			locomotionStepDuration = running and 0.6 or (backward and 1.1 or 1)
			plantedSide = nil
			if running then
				playSequence(controlledModel, "BuildRun", "GuardianControlledRun")
			elseif backward then
				playSequence(controlledModel, "BuildWalkBackward", "GuardianControlledWalkBackward")
			else
				playSequence(controlledModel, "BuildWalk", "GuardianControlledWalk")
			end
		else
			playSequence(controlledModel, "BuildIdle", "GuardianControlledIdle")
		end
	end
	-- Curved locomotion must keep the active Walk/Run cycle. A full-body
	-- turn clip would replace the leg cycle and make both feet appear planted.
	currentTurn = desiredTurn
	updateFootLock(moving and not currentTurn, backward and -direction or direction)
	if os.clock() - lastMoveSent >= 0.07 then
		lastMoveSent = os.clock()
		remote:FireServer("ControlMove", direction, running, backward)
	end
end)



restoreGuardianPower = function()
	defeatPowerCycle += 1
	for instance, state in pairs(defeatedVisualState) do
		if instance and instance.Parent then
			if instance:IsA("BasePart") then
				instance.Color = state.Color
				instance.Material = state.Material
			elseif instance:IsA("Light") or instance:IsA("ParticleEmitter")
				or instance:IsA("Beam") or instance:IsA("Trail") then
				instance.Enabled = state.Enabled
			end
		end
	end
	defeatedVisualState = {}
end

local function powerDownGuardian(model)
	restoreGuardianPower()
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") and instance.Material == Enum.Material.Neon then
			defeatedVisualState[instance] = {
				Color = instance.Color,
				Material = instance.Material,
			}
			TweenService:Create(instance, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(8, 17, 20),
			}):Play()
			task.delay(0.42, function()
				if defeated and instance.Parent then
					instance.Material = Enum.Material.SmoothPlastic
				end
			end)
		elseif instance:IsA("Light") or instance:IsA("ParticleEmitter")
			or instance:IsA("Beam") or instance:IsA("Trail") then
			defeatedVisualState[instance] = {Enabled = instance.Enabled}
			instance.Enabled = false
		end
	end
end


local function startDefeatPowerFlicker()
	defeatPowerCycle += 1
	local cycle = defeatPowerCycle
	task.spawn(function()
		while defeated and cycle == defeatPowerCycle do
			task.wait(math.random(70, 230) / 100)
			if not defeated or cycle ~= defeatPowerCycle then break end

			local candidates = {}
			for instance, state in pairs(defeatedVisualState) do
				if instance:IsA("BasePart") and instance.Parent and state.Material == Enum.Material.Neon then
					table.insert(candidates, {instance = instance, state = state})
				end
			end
			if #candidates > 0 then
				-- Only a few circuits receive residual power on each pulse.
				local pulseCount = math.random(1, math.max(1, math.ceil(#candidates * 0.22)))
				for index = #candidates, 2, -1 do
					local swap = math.random(1, index)
					candidates[index], candidates[swap] = candidates[swap], candidates[index]
				end
				for index = 1, pulseCount do
					local candidate = candidates[index]
					candidate.instance.Material = Enum.Material.Neon
					TweenService:Create(candidate.instance, TweenInfo.new(0.045), {
						Color = candidate.state.Color,
					}):Play()
				end
				task.wait(math.random(5, 13) / 100)
				for index = 1, pulseCount do
					local candidate = candidates[index]
					if candidate.instance.Parent then
						TweenService:Create(candidate.instance, TweenInfo.new(0.12), {
							Color = Color3.fromRGB(8, 17, 20),
						}):Play()
					end
				end
				task.wait(0.13)
				if defeated and cycle == defeatPowerCycle then
					for index = 1, pulseCount do
						local instance = candidates[index].instance
						if instance.Parent then instance.Material = Enum.Material.SmoothPlastic end
					end
				end
			end
		end
	end)
end

local function flashDamage(model)
	local highlight = Instance.new("Highlight")
	highlight.Name = "GuardianDamageFlash"
	highlight.Adornee = model
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = Color3.fromRGB(255, 38, 38)
	highlight.OutlineColor = Color3.fromRGB(255, 150, 120)
	highlight.FillTransparency = 0.2
	highlight.OutlineTransparency = 0.05
	highlight.Parent = model
	task.spawn(function()
		for pulse = 1, 2 do
			highlight.Enabled = true
			task.wait(0.07)
			highlight.Enabled = false
			task.wait(0.045)
		end
		highlight:Destroy()
	end)
end

remote.OnClientEvent:Connect(function(message, payload)
	if message == "ControlEnabled" then
		setControl(true, payload)
		return
	elseif message == "ControlDisabled" then
		setControl(false)
		return
	end
	if message == "PlayShieldBlock" then
		local success, err = pcall(function()
			local heldTrack, generation = playSequence(payload, "BuildShieldBlock", "GuardianShieldBlockPreview")
			task.delay(0.72, function()
				if generation == playbackGeneration and idleTrack == heldTrack and heldTrack.IsPlaying then
					heldTrack:AdjustSpeed(0)
					status.Text = "SHIELD BLOCK HELD — NEUTRAL TO RESET"
					status.TextColor3 = Color3.fromRGB(92, 188, 220)
				end
			end)
		end)
		if not success then
			status.Text = "SHIELD BLOCK ERROR"
			status.TextColor3 = Color3.fromRGB(235, 92, 82)
			warn("Guardian shield block failed:", err)
		end
		return
	end
	if message == "PlayDefeat" then
		local success, err = pcall(function()
			staggering = false
			defeated = true
			remote:FireServer("ControlMove", Vector3.zero)
			clearFootLocks()
			flashDamage(payload)
			local defeatTrack, generation = playSequence(payload, "BuildDefeat", "GuardianDefeatPreview")
			task.delay(0.22, function()
				if defeated then
					powerDownGuardian(payload)
					startDefeatPowerFlicker()
				end
			end)
			task.delay(1.3, function()
				if defeated and generation == playbackGeneration and idleTrack == defeatTrack and defeatTrack.IsPlaying then
					defeatTrack:AdjustSpeed(0)
					status.Text = "DEFEATED — NEUTRAL TO RESET"
					status.TextColor3 = Color3.fromRGB(190, 92, 92)
				end
			end)
		end)
		if not success then
			defeated = false
			warn("Guardian defeat failed:", err)
		end
		return
	end
	if message == "PlayStagger" then
		local success, err = pcall(function()
			flashDamage(payload)
			staggering = true
			remote:FireServer("ControlMove", Vector3.zero)
			clearFootLocks()
			playSequence(payload, "BuildStagger", "GuardianStaggerPreview")
			task.delay(1.08, function()
				staggering = false
				if controlEnabled and controlledModel == payload then
					setupFootLocks(payload)
					walkStartedAt = os.clock()
					plantedSide = nil
					if wasMoving then
						if wasRunning then
							playSequence(payload, "BuildRun", "GuardianControlledRun")
						elseif wasBackward then
							playSequence(payload, "BuildWalkBackward", "GuardianControlledWalkBackward")
						else
							playSequence(payload, "BuildWalk", "GuardianControlledWalk")
						end
					else
						playSequence(payload, "BuildIdle", "GuardianControlledIdle")
					end
				else
					playSequence(payload, "BuildIdle", "GuardianIdlePreview")
				end
			end)
		end)
		if not success then
			staggering = false
			warn("Guardian stagger failed:", err)
		end
		return
	end
	if message == "PlayDamageReact" then
		local success, err = pcall(function()
			flashDamage(payload)
			playReaction(payload, "BuildDamageReact", "GuardianDamageReactPreview")
		end)
		if not success then warn("Guardian damage reaction failed:", err) end
		return
	end
	if message == "PlayIdle" or message == "PlayAlertIdle" or message == "PlayWalk" or message == "PlayRun" or message == "PlayTurnLeft" or message == "PlayTurnRight" or message == "PlayFall" or message == "PlayLand" or message == "PlayWalkBackward" or message == "PlayShockBaton" or message == "PlayWarningPulse" or message == "PlayShoulderMissileSalvo" or message == "PlayTwinIonCannons" or message == "PlayPulseCannonFire" or message == "PlayContainmentNetLaunch" then
		local builders = {
			PlayIdle = {"BuildIdle", "GuardianIdlePreview"},
			PlayAlertIdle = {"BuildAlertIdle", "GuardianAlertIdlePreview"},
			PlayWalk = {"BuildWalk", "GuardianWalkPreview"},
			PlayRun = {"BuildRun", "GuardianRunPreview"},
			PlayTurnLeft = {"BuildTurnLeft", "GuardianTurnLeftPreview"},
			PlayTurnRight = {"BuildTurnRight", "GuardianTurnRightPreview"},
			PlayFall = {"BuildFall", "GuardianFallPreview"},
			PlayLand = {"BuildLand", "GuardianLandPreview"},
			PlayWalkBackward = {"BuildWalkBackward", "GuardianWalkBackwardPreview"},
			PlayShockBaton = {"BuildShockBaton", "WardenShockBatonPreview"},
			PlayWarningPulse = {"BuildWarningPulse", "WardenWarningPulsePreview"},
			PlayShoulderMissileSalvo = {"BuildShoulderMissileSalvo", "AegisShoulderMissileSalvoPreview"},
			PlayTwinIonCannons = {"BuildTwinIonCannons", "AegisTwinIonCannonsPreview"},
			PlayPulseCannonFire = {"BuildPulseCannonFire", "GuardianPulseCannonFirePreview"},
			PlayContainmentNetLaunch = {"BuildContainmentNetLaunch", "GuardianContainmentNetLaunchPreview"},
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
