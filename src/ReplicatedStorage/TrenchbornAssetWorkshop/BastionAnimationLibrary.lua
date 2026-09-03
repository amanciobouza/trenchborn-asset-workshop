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

local function siegeSequence(name, frames, duration)
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = name
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action
	for _, frame in ipairs(frames) do
		bastionKeyframe(sequence, frame[1], frame[2])
	end
	sequence:SetAttribute("GuardianAnimation", name)
	sequence:SetAttribute("DurationSeconds", duration)
	sequence:SetAttribute("SpecificationVersion", "Bastion-Siege-1.0")
	return sequence
end

local function fistPose(side, strike)
	local sign = side == "Right" and 1 or -1
	local pose = {
		LowerTorso = CFrame.new(0, -0.24, -0.12) * CFrame.Angles(math.rad(-5), math.rad((strike and 7 or -8) * sign), 0),
		UpperTorso = CFrame.Angles(math.rad(-4), math.rad((strike and 20 or -18) * sign), math.rad((strike and 2 or -3) * sign)),
		Head = CFrame.Angles(0, math.rad((strike and -14 or 10) * sign), 0),
		LeftUpperLeg = CFrame.Angles(math.rad(6), 0, math.rad(-2)),
		RightUpperLeg = CFrame.Angles(math.rad(6), 0, math.rad(2)),
	}
	pose[side .. "UpperArm"] = strike
		and CFrame.Angles(math.rad(82), math.rad(-24 * sign), math.rad(-34 * sign))
		or CFrame.Angles(math.rad(-34), math.rad(20 * sign), math.rad(25 * sign))
	pose[side .. "LowerArm"] = strike
		and CFrame.Angles(math.rad(-8), 0, 0)
		or CFrame.Angles(math.rad(58), 0, 0)
	return pose
end

function Library.BuildRightSiegeFist()
	return siegeSequence("BastionRightSiegeFist", {
		{0, {}}, {0.34, fistPose("Right", false)}, {0.58, fistPose("Right", true)},
		{0.78, fistPose("Right", true)}, {1.18, {}},
	}, 1.18)
end

function Library.BuildLeftSiegeFist()
	return siegeSequence("BastionLeftSiegeFist", {
		{0, {}}, {0.34, fistPose("Left", false)}, {0.58, fistPose("Left", true)},
		{0.78, fistPose("Left", true)}, {1.18, {}},
	}, 1.18)
end

function Library.BuildSiegeFistCombo()
	return siegeSequence("BastionSiegeFistCombo", {
		{0, {}}, {0.28, fistPose("Right", false)}, {0.5, fistPose("Right", true)},
		{0.7, fistPose("Left", false)}, {0.94, fistPose("Left", true)}, {1.42, {}},
	}, 1.42)
end

function Library.BuildGroundSlam()
	local raised = {
		LowerTorso = CFrame.new(0, -0.28, 0.1) * CFrame.Angles(math.rad(5), 0, 0),
		UpperTorso = CFrame.Angles(math.rad(8), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(-142), 0, math.rad(-12)),
		RightUpperArm = CFrame.Angles(math.rad(-142), 0, math.rad(12)),
		LeftLowerArm = CFrame.Angles(math.rad(18), 0, 0),
		RightLowerArm = CFrame.Angles(math.rad(18), 0, 0),
	}
	local impact = {
		LowerTorso = CFrame.new(0, -6.5, -1.15) * CFrame.Angles(math.rad(-29), 0, 0),
		UpperTorso = CFrame.Angles(math.rad(-42), 0, 0),
		Head = CFrame.Angles(math.rad(25), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(110), 0, math.rad(-10)),
		RightUpperArm = CFrame.Angles(math.rad(110), 0, math.rad(10)),
		LeftLowerArm = CFrame.Angles(math.rad(-12), 0, 0),
		RightLowerArm = CFrame.Angles(math.rad(-12), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(42), 0, math.rad(-6)),
		RightUpperLeg = CFrame.Angles(math.rad(42), 0, math.rad(6)),
		LeftLowerLeg = CFrame.Angles(math.rad(-88), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-88), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(28), 0, 0),
		RightFoot = CFrame.Angles(math.rad(28), 0, 0),
	}
	local sequence = siegeSequence("BastionGroundSlam", {
		{0, {}}, {0.48, raised}, {0.82, raised}, {1.02, impact}, {1.5, impact}, {2.28, {}},
	}, 2.28)
	sequence:SetAttribute("ImpactTime", 1.02)
	return sequence
end

function Library.BuildDistrictShield()
	local brace = {
		LowerTorso = CFrame.new(0, -1.2, 0.25) * CFrame.Angles(math.rad(5), 0, 0),
		UpperTorso = CFrame.Angles(math.rad(4), 0, 0),
		Head = CFrame.Angles(math.rad(-4), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(24), math.rad(-8), math.rad(-28)),
		RightUpperArm = CFrame.Angles(math.rad(24), math.rad(8), math.rad(28)),
		LeftLowerArm = CFrame.Angles(math.rad(38), 0, 0),
		RightLowerArm = CFrame.Angles(math.rad(38), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(15), 0, math.rad(-7)),
		RightUpperLeg = CFrame.Angles(math.rad(15), 0, math.rad(7)),
		LeftLowerLeg = CFrame.Angles(math.rad(-34), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-34), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(10), math.rad(-7), 0),
		RightFoot = CFrame.Angles(math.rad(10), math.rad(7), 0),
	}
	local locked = table.clone(brace)
	locked.LowerTorso = CFrame.new(0, -1.55, 0.4) * CFrame.Angles(math.rad(7), 0, 0)
	locked.UpperTorso = CFrame.Angles(math.rad(7), 0, 0)
	local sequence = siegeSequence("BastionDistrictShield", {
		{0, {}}, {0.48, brace}, {1.05, locked}, {1.65, locked},
		{4.8, locked}, {5.35, brace}, {5.8, {}},
	}, 5.8)
	sequence:SetAttribute("FieldDeployTime", 1.65)
	sequence:SetAttribute("FieldDuration", 3.15)
	return sequence
end

return Library
