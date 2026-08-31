local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local animationLibrary = require(script.Parent:WaitForChild("GuardianAnimationLibrary"))

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
	local idleTrack
	local lastRequest = {}

	local function stopAnimation()
		if idleTrack and idleTrack.IsPlaying then
			idleTrack:Stop(0.2)
		end
	end

	local function playIdle()
		stopAnimation()
		for name, joint in pairs(joints) do
			joint.C0 = neutralC0[name]
		end
		local sequence = animationLibrary.BuildIdle()
		local temporaryId = KeyframeSequenceProvider:RegisterKeyframeSequence(sequence)
		local animation = Instance.new("Animation")
		animation.Name = "GuardianIdlePreview"
		animation.AnimationId = temporaryId
		idleTrack = animator:LoadAnimation(animation)
		idleTrack.Looped = true
		idleTrack.Priority = Enum.AnimationPriority.Idle
		idleTrack:Play(0.35)
	end

	local function pose(targets, duration)
		stopAnimation()
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
		IdleLoop = playIdle,
		Neutral = function()
			pose({}, 0.35)
		end,
	}

	remote.OnServerEvent:Connect(function(player, actionName)
		if type(actionName) ~= "string" or not actions[actionName] then return end
		local now = os.clock()
		if lastRequest[player] and now - lastRequest[player] < 0.12 then return end
		lastRequest[player] = now
		actions[actionName]()
		remote:FireClient(player, "Completed", actionName)
	end)

	model:SetAttribute("FleetRigMotionTestReady", true)
	model:SetAttribute("FleetRigMotionDriver", "Motor6D.C0")
	model:SetAttribute("GuardianIdlePreviewReady", true)
	model:SetAttribute("FleetRigTestInterface", "HUD")
	return remote
end

return Harness
