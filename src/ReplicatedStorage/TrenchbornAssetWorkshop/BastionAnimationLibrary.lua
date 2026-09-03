local base = require(script.Parent:WaitForChild("GuardianAnimationLibrary"))

local Library = setmetatable({}, {__index = base})

local ARM_POSES = {
	LeftUpperArm = true,
	LeftLowerArm = true,
	LeftHand = true,
	RightUpperArm = true,
	RightLowerArm = true,
	RightHand = true,
}

local function adapt(builderName, options)
	local sequence = base[builderName]()
	options = options or {}
	for _, item in ipairs(sequence:GetDescendants()) do
		if item:IsA("Keyframe") then
			item.Time *= options.TimeScale or 1
		elseif item:IsA("Pose") then
			if ARM_POSES[item.Name] then
				item.CFrame = CFrame.identity:Lerp(item.CFrame, options.ArmScale or 0.62)
			elseif item.Name == "Head" then
				item.CFrame = CFrame.identity:Lerp(item.CFrame, options.HeadScale or 0.72)
			elseif item.Name == "UpperTorso" then
				item.CFrame = CFrame.identity:Lerp(item.CFrame, options.TorsoScale or 0.88)
			elseif item.Name == "LowerTorso" and options.BodySink then
				item.CFrame = CFrame.new(0, -options.BodySink, 0) * item.CFrame
			end
		end
	end
	local duration = sequence:GetAttribute("DurationSeconds")
	if duration then sequence:SetAttribute("DurationSeconds", duration * (options.TimeScale or 1)) end
	sequence.Name = "Bastion" .. sequence.Name
	sequence:SetAttribute("BastionHeavyVariant", true)
	sequence:SetAttribute("SpecificationVersion", "Bastion-Heavy-1.0")
	return sequence
end

function Library.BuildIdle()
	return adapt("BuildIdle", {TimeScale = 1.3, ArmScale = 0.48, HeadScale = 0.62, TorsoScale = 0.72})
end

function Library.BuildAlertIdle()
	return adapt("BuildAlertIdle", {TimeScale = 1.25, ArmScale = 0.58, HeadScale = 0.65, TorsoScale = 0.8, BodySink = 0.08})
end

function Library.BuildWalk()
	return adapt("BuildWalk", {TimeScale = 1.25, ArmScale = 0.48, HeadScale = 0.62, TorsoScale = 0.9, BodySink = 0.12})
end

function Library.BuildRun()
	return adapt("BuildRun", {TimeScale = 1.15, ArmScale = 0.58, HeadScale = 0.66, TorsoScale = 0.92, BodySink = 0.18})
end

function Library.BuildWalkBackward()
	return adapt("BuildWalkBackward", {TimeScale = 1.25, ArmScale = 0.5, HeadScale = 0.62, TorsoScale = 0.88, BodySink = 0.14})
end

function Library.BuildTurnLeft()
	return adapt("BuildTurnLeft", {TimeScale = 1.35, ArmScale = 0.5, HeadScale = 0.68, TorsoScale = 0.92, BodySink = 0.12})
end

function Library.BuildTurnRight()
	return adapt("BuildTurnRight", {TimeScale = 1.35, ArmScale = 0.5, HeadScale = 0.68, TorsoScale = 0.92, BodySink = 0.12})
end

function Library.BuildFall()
	return adapt("BuildFall", {TimeScale = 1.12, ArmScale = 0.64, HeadScale = 0.7, TorsoScale = 0.9})
end

function Library.BuildLand()
	return adapt("BuildLand", {TimeScale = 1.4, ArmScale = 0.7, HeadScale = 0.72, TorsoScale = 1.05, BodySink = 0.2})
end

local BASTION_HIERARCHY = {
	HumanoidRootPart = {
		LowerTorso = {
			UpperTorso = {
				Head = {},
				HeavyRailCannonInertiaControl = {HeavyRailCannonControl = {}},
				LeftUpperArm = {LeftLowerArm = {LeftHand = {}}},
				RightUpperArm = {RightLowerArm = {RightHand = {}}},
			},
			LeftUpperLeg = {LeftLowerLeg = {LeftFoot = {}}},
			RightUpperLeg = {RightLowerLeg = {RightFoot = {}}},
		},
	},
}

local function poseTree(name, children, transforms)
	local pose = Instance.new("Pose")
	pose.Name = name
	pose.Weight = 1
	pose.EasingStyle = Enum.PoseEasingStyle.CubicV2
	pose.EasingDirection = Enum.PoseEasingDirection.InOut
	pose.CFrame = transforms[name] or CFrame.identity
	for childName, grandchildren in pairs(children) do
		poseTree(childName, grandchildren, transforms).Parent = pose
	end
	return pose
end

local function bastionKeyframe(sequence, time, transforms)
	local frame = Instance.new("Keyframe")
	frame.Name = string.format("BastionRail_%03d", math.floor(time * 100))
	frame.Time = time
	for rootName, children in pairs(BASTION_HIERARCHY) do
		poseTree(rootName, children, transforms).Parent = frame
	end
	frame.Parent = sequence
end

function Library.BuildHeavyRailCannon()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "BastionHeavyRailCannon"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action

	local brace = {
		LowerTorso = CFrame.new(0, -0.42, -0.18) * CFrame.Angles(math.rad(-7), 0, 0),
		UpperTorso = CFrame.Angles(math.rad(-5), math.rad(-3), 0),
		Head = CFrame.Angles(math.rad(-3), math.rad(8), 0),
		LeftUpperArm = CFrame.Angles(math.rad(16), math.rad(-7), math.rad(-13)),
		LeftLowerArm = CFrame.Angles(math.rad(25), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(18), math.rad(5), math.rad(12)),
		RightLowerArm = CFrame.Angles(math.rad(26), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(8), 0, math.rad(-2)),
		LeftLowerLeg = CFrame.Angles(math.rad(-22), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(7), math.rad(-4), 0),
		RightUpperLeg = CFrame.Angles(math.rad(8), 0, math.rad(2)),
		RightLowerLeg = CFrame.Angles(math.rad(-22), 0, 0),
		RightFoot = CFrame.Angles(math.rad(7), math.rad(4), 0),
		HeavyRailCannonControl = CFrame.Angles(math.rad(-5), math.rad(5), 0),
	}
	bastionKeyframe(sequence, 0, {})
	bastionKeyframe(sequence, 0.38, brace)
	bastionKeyframe(sequence, 0.78, brace)
	bastionKeyframe(sequence, 1.48, brace)
	local recoil = table.clone(brace)
	recoil.LowerTorso = CFrame.new(0, -0.58, 0.38) * CFrame.Angles(math.rad(5), 0, 0)
	recoil.UpperTorso = CFrame.Angles(math.rad(4), math.rad(-2), math.rad(-2))
	recoil.Head = CFrame.Angles(math.rad(5), math.rad(5), 0)
	recoil.HeavyRailCannonControl = CFrame.new(0, 0, 2.4) * CFrame.Angles(math.rad(-3), math.rad(4), math.rad(-2))
	bastionKeyframe(sequence, 1.58, recoil)
	bastionKeyframe(sequence, 1.92, brace)
	bastionKeyframe(sequence, 2.45, brace)
	bastionKeyframe(sequence, 2.85, {})

	sequence:SetAttribute("GuardianAnimation", "HeavyRailCannon")
	sequence:SetAttribute("DurationSeconds", 2.85)
	sequence:SetAttribute("ChargeReleaseTime", 1.55)
	sequence:SetAttribute("SpecificationVersion", "Bastion-Rail-1.0")
	return sequence
end

return Library
