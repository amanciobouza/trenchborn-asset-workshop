local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Harness = {}

local function motor(model, name)
	local item = model:FindFirstChild(name, true)
	assert(item and item:IsA("Motor6D"), "Missing fleet rig motor: " .. name)
	return item
end

function Harness.Attach(model)
	local oldConsole = workspace:FindFirstChild("GuardianFleetRigTestConsole")
	if oldConsole then oldConsole:Destroy() end

	local oldRemote = ReplicatedStorage:FindFirstChild("GuardianFleetRigTestRemote")
	if oldRemote then oldRemote:Destroy() end
	local remote = Instance.new("RemoteEvent")
	remote.Name = "GuardianFleetRigTestRemote"
	remote.Parent = ReplicatedStorage

	local hudTemplate = script.Parent:WaitForChild("GuardianFleetRigTestHUD")
	local function installHud(player)
		local playerGui = player:WaitForChild("PlayerGui")
		local oldClient = playerGui:FindFirstChild("GuardianFleetRigTestHUDClient")
		if oldClient then oldClient:Destroy() end
		local client = hudTemplate:Clone()
		client.Name = "GuardianFleetRigTestHUDClient"
		client.Parent = playerGui
	end
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(installHud, player)
	end
	Players.PlayerAdded:Connect(installHud)

	local joints = {
		LeftShoulder = motor(model, "LeftShoulder"),
		LeftElbow = motor(model, "LeftElbow"),
		LeftWrist = motor(model, "LeftWrist"),
		RightShoulder = motor(model, "RightShoulder"),
		RightElbow = motor(model, "RightElbow"),
		LeftHip = motor(model, "LeftHip"),
		LeftKnee = motor(model, "LeftKnee"),
		RightHip = motor(model, "RightHip"),
		RightKnee = motor(model, "RightKnee"),
	}

	local neutralC0 = {}
	for name, joint in pairs(joints) do
		neutralC0[name] = joint.C0
	end

	local animator = model:FindFirstChildWhichIsA("Animator", true)
	assert(animator, "Missing Guardian Fleet Rig Animator")
	local root = model:FindFirstChild("HumanoidRootPart")
	assert(root and root:IsA("BasePart"), "Missing Guardian HumanoidRootPart")
	local lastRequest = {}
	local controllerPlayer
	local controlDirection = Vector3.zero
	local controlUpdatedAt = 0
	local controlSpeed = 12
	local runSpeed = 20
	local walkStepDuration = 1
	local runStepDuration = 0.6
	local controlRunning = false
	local controlBackward = false
	local backwardStepDuration = 1.1
	local movementStartedAt = 0
	local wasControlMoving = false
	local maxTurnRate = math.rad(110)

	local function stepSpeed(now)
		local duration = controlRunning and runStepDuration or (controlBackward and backwardStepDuration or walkStepDuration)
		local phase = ((now - movementStartedAt) % duration) / duration
		if controlRunning then
			if phase < 0.10 then return 6 end
			if phase < 0.52 then return 34 end
			if phase < 0.78 then return 15 end
			return 7
		end
		if phase < 0.12 then return 3 end
		if phase < 0.52 then return 21 end
		if phase < 0.78 then return 9 end
		return 4
	end

	RunService.Heartbeat:Connect(function(deltaTime)
		if not controllerPlayer then return end
		local now = os.clock()
		local direction = now - controlUpdatedAt <= 0.3 and controlDirection or Vector3.zero
		if direction.Magnitude < 0.01 then
			wasControlMoving = false
			return
		end
		if not wasControlMoving then
			wasControlMoving = true
			movementStartedAt = now
		end
		direction = Vector3.new(direction.X, 0, direction.Z).Unit
		local desiredFacing = controlBackward and -direction or direction
		local facing = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z).Unit
		local angle = math.acos(math.clamp(facing:Dot(desiredFacing), -1, 1))
		local target = CFrame.lookAt(root.Position, root.Position + desiredFacing)
		local alpha = angle > 0.001 and math.min(1, maxTurnRate * deltaTime / angle) or 1
		local turned = root.CFrame:Lerp(target, alpha)
		local facingDirection = Vector3.new(turned.LookVector.X, 0, turned.LookVector.Z).Unit
		local travelDirection = controlBackward and -facingDirection or facingDirection
		local speedScale = controlBackward and 0.67 or 1
		local nextPosition = root.Position + travelDirection * stepSpeed(now) * speedScale * deltaTime
		root.CFrame = CFrame.lookAt(nextPosition, nextPosition + facingDirection)
	end)

	Players.PlayerRemoving:Connect(function(player)
		if player == controllerPlayer then
			controllerPlayer = nil
			controlDirection = Vector3.zero
			wasControlMoving = false
		end
		lastRequest[player] = nil
	end)

	local function pose(targets, duration)
		for name, joint in pairs(joints) do
			local offset = targets[name] or CFrame.identity
			TweenService:Create(
				joint,
				TweenInfo.new(duration or 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{C0 = neutralC0[name] * offset}
			):Play()
		end
	end

	local actions = {
		LeftShoulder = function()
			pose({LeftShoulder = CFrame.Angles(math.rad(28), math.rad(-12), math.rad(-30))}, 0.45)
		end,
		LeftElbow = function()
			pose({
				LeftShoulder = CFrame.Angles(math.rad(18), math.rad(-8), math.rad(-18)),
				LeftElbow = CFrame.Angles(math.rad(62), 0, 0),
				LeftWrist = CFrame.Angles(0, math.rad(12), 0),
			}, 0.45)
		end,
		RightArm = function()
			pose({
				RightShoulder = CFrame.Angles(math.rad(42), 0, math.rad(22)),
				RightElbow = CFrame.Angles(math.rad(38), 0, 0),
			}, 0.45)
		end,
		KneeLoad = function()
			pose({
				LeftHip = CFrame.Angles(math.rad(10), 0, 0),
				RightHip = CFrame.Angles(math.rad(10), 0, 0),
				LeftKnee = CFrame.Angles(math.rad(-24), 0, 0),
				RightKnee = CFrame.Angles(math.rad(-24), 0, 0),
			}, 0.45)
		end,
		IdleLoop = function() end,
		AlertIdle = function() end,
		Walk = function() end,
		Run = function() end,
		TurnLeft = function() end,
		TurnRight = function() end,
		Fall = function() end,
		Land = function() end,
		WalkBackward = function() end,
		DamageReact = function() end,
		Stagger = function() end,
		ControlGuardian = function() end,
		Neutral = function()
			pose({}, 0.35)
		end,
	}

	remote.OnServerEvent:Connect(function(player, actionName, payload, option, backwardOption)
		if type(actionName) ~= "string" then return end
		if actionName == "ControlMove" then
			if player == controllerPlayer and typeof(payload) == "Vector3" then
				local flat = Vector3.new(payload.X, 0, payload.Z)
				controlDirection = flat.Magnitude > 1 and flat.Unit or flat
				local nextRunning = option == true
				local nextBackward = backwardOption == true
				if nextRunning ~= controlRunning or nextBackward ~= controlBackward then
					controlRunning = nextRunning
					controlBackward = nextBackward
					movementStartedAt = os.clock()
				end
				controlUpdatedAt = os.clock()
			end
			return
		end
		if not actions[actionName] then return end
		local now = os.clock()
		if lastRequest[player] and now - lastRequest[player] < 0.12 then return end
		lastRequest[player] = now
		if actionName == "ControlGuardian" then
			if controllerPlayer == player then
				controllerPlayer = nil
				controlDirection = Vector3.zero
				wasControlMoving = false
				remote:FireClient(player, "ControlDisabled")
			else
				if controllerPlayer then remote:FireClient(controllerPlayer, "ControlDisabled") end
				controllerPlayer = player
				controlDirection = Vector3.zero
				wasControlMoving = false
				controlUpdatedAt = os.clock()
				remote:FireClient(player, "ControlEnabled", model)
			end
		elseif actionName == "IdleLoop" then
			remote:FireClient(player, "PlayIdle", model)
		elseif actionName == "AlertIdle" then
			remote:FireClient(player, "PlayAlertIdle", model)
		elseif actionName == "Walk" then
			remote:FireClient(player, "PlayWalk", model)
		elseif actionName == "Run" then
			remote:FireClient(player, "PlayRun", model)
		elseif actionName == "TurnLeft" then
			remote:FireClient(player, "PlayTurnLeft", model)
		elseif actionName == "TurnRight" then
			remote:FireClient(player, "PlayTurnRight", model)
		elseif actionName == "Fall" then
			remote:FireClient(player, "PlayFall", model)
		elseif actionName == "Land" then
			remote:FireClient(player, "PlayLand", model)
		elseif actionName == "WalkBackward" then
			remote:FireClient(player, "PlayWalkBackward", model)
		elseif actionName == "DamageReact" then
			remote:FireClient(player, "PlayDamageReact", model)
		elseif actionName == "Stagger" then
			remote:FireClient(player, "PlayStagger", model)
		else
			actions[actionName]()
		end
		remote:FireClient(player, "Completed", actionName)
	end)

	model:SetAttribute("FleetRigMotionTestReady", true)
	model:SetAttribute("FleetRigMotionDriver", "Motor6D.C0")
	model:SetAttribute("GuardianIdlePreviewReady", true)
	model:SetAttribute("GuardianAlertIdlePreviewReady", true)
	model:SetAttribute("GuardianWalkPreviewReady", true)
	model:SetAttribute("GuardianRunPreviewReady", true)
	model:SetAttribute("GuardianTurnPreviewReady", true)
	model:SetAttribute("GuardianAirStatePreviewReady", true)
	model:SetAttribute("GuardianWalkBackwardPreviewReady", true)
	model:SetAttribute("GuardianDamageReactPreviewReady", true)
	model:SetAttribute("GuardianStaggerPreviewReady", true)
	model:SetAttribute("FleetRigTestInterface", "HUD")
	model:SetAttribute("GuardianPossessionTestReady", true)
	model:SetAttribute("GuardianControlSpeed", controlSpeed)
	model:SetAttribute("GuardianRunSpeed", runSpeed)
	model:SetAttribute("GuardianLocomotionMode", "StepDriven")
	model:SetAttribute("GuardianStepDuration", walkStepDuration)
	model:SetAttribute("GuardianRunStepDuration", runStepDuration)
	return remote
end

return Harness
