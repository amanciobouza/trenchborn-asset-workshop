local base = require(script.Parent:WaitForChild("GuardianAnimationLibrary"))

local Library = setmetatable({}, {__index = base})

local LEFT_ARM = {LeftUpperArm = true, LeftLowerArm = true, LeftHand = true}
local RIGHT_ARM = {RightUpperArm = true, RightLowerArm = true, RightHand = true}
local LEGS = {
	LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
	RightUpperLeg = true, RightLowerLeg = true, RightFoot = true,
}

local function adapt(builderName, options)
	local sequence = base[builderName]()
	options = options or {}
	for _, item in ipairs(sequence:GetDescendants()) do
		if item:IsA("Keyframe") then
			item.Time *= options.TimeScale or 1
		elseif item:IsA("Pose") then
			if LEFT_ARM[item.Name] then
				item.CFrame = CFrame.identity:Lerp(item.CFrame, options.LanceArmScale or 0.42)
			elseif RIGHT_ARM[item.Name] then
				item.CFrame = CFrame.identity:Lerp(item.CFrame, options.FreeArmScale or 0.72)
			elseif LEGS[item.Name] then
				item.CFrame = CFrame.identity:Lerp(item.CFrame, options.LegScale or 1.05)
			elseif item.Name == "Head" then
				item.CFrame = CFrame.identity:Lerp(item.CFrame, options.HeadScale or 0.68)
			elseif item.Name == "UpperTorso" then
				item.CFrame = CFrame.Angles(math.rad(options.UpperLean or 0), 0, 0)
					* CFrame.identity:Lerp(item.CFrame, options.TorsoScale or 1)
			elseif item.Name == "LowerTorso" then
				item.CFrame = CFrame.Angles(math.rad(options.PelvisLean or 0), 0, 0) * item.CFrame
				if options.BodySink then item.CFrame = CFrame.new(0, -options.BodySink, 0) * item.CFrame end
			end
		end
	end
	local duration = sequence:GetAttribute("DurationSeconds")
	if duration then sequence:SetAttribute("DurationSeconds", duration * (options.TimeScale or 1)) end
	sequence.Name = "Sovereign" .. sequence.Name
	sequence:SetAttribute("SovereignHunterVariant", true)
	sequence:SetAttribute("SpecificationVersion", "Sovereign-Hunter-1.0")
	return sequence
end

function Library.BuildIdle()
	return adapt("BuildIdle", {
		TimeScale = 0.9, LanceArmScale = 0.32, FreeArmScale = 0.58,
		HeadScale = 0.58, TorsoScale = 0.72, UpperLean = -2,
	})
end

function Library.BuildAlertIdle()
	return adapt("BuildAlertIdle", {
		TimeScale = 0.82, LanceArmScale = 0.48, FreeArmScale = 0.72,
		HeadScale = 0.72, TorsoScale = 1.05, UpperLean = -6, PelvisLean = -4, BodySink = 0.08,
	})
end

function Library.BuildWalk()
	return adapt("BuildWalk", {
		TimeScale = 0.82, LanceArmScale = 0.3, FreeArmScale = 0.68,
		LegScale = 1.05, HeadScale = 0.62, TorsoScale = 1.02,
		UpperLean = -5, PelvisLean = -5, BodySink = 0.06,
	})
end

function Library.BuildRun()
	return adapt("BuildRun", {
		TimeScale = 0.8, LanceArmScale = 0.34, FreeArmScale = 0.76,
		LegScale = 1.08, HeadScale = 0.58, TorsoScale = 1.05,
		UpperLean = -9, PelvisLean = -10, BodySink = 0.1,
	})
end

function Library.BuildWalkBackward()
	return adapt("BuildWalkBackward", {
		TimeScale = 0.85, LanceArmScale = 0.34, FreeArmScale = 0.66,
		LegScale = 1.02, HeadScale = 0.64, TorsoScale = 0.96,
		UpperLean = -4, PelvisLean = -3, BodySink = 0.08,
	})
end

function Library.BuildTurnLeft()
	return adapt("BuildTurnLeft", {
		TimeScale = 0.78, LanceArmScale = 0.38, FreeArmScale = 0.76,
		LegScale = 1.06, HeadScale = 0.78, TorsoScale = 1.12,
		UpperLean = -6, PelvisLean = -5, BodySink = 0.06,
	})
end

function Library.BuildTurnRight()
	return adapt("BuildTurnRight", {
		TimeScale = 0.78, LanceArmScale = 0.38, FreeArmScale = 0.76,
		LegScale = 1.06, HeadScale = 0.78, TorsoScale = 1.12,
		UpperLean = -6, PelvisLean = -5, BodySink = 0.06,
	})
end

function Library.BuildFall()
	return adapt("BuildFall", {
		TimeScale = 0.85, LanceArmScale = 0.5, FreeArmScale = 0.78,
		LegScale = 1.02, HeadScale = 0.68, TorsoScale = 1.02,
	})
end

function Library.BuildLand()
	return adapt("BuildLand", {
		TimeScale = 0.82, LanceArmScale = 0.5, FreeArmScale = 0.82,
		LegScale = 1.08, HeadScale = 0.66, TorsoScale = 1.08,
		UpperLean = -8, PelvisLean = -8, BodySink = 0.12,
	})
end

local SOVEREIGN_HIERARCHY = {
	HumanoidRootPart = {
		LowerTorso = {
			UpperTorso = {
				Head = {},
				LeftUpperArm = {LeftLowerArm = {LeftHand = {}, ApexLanceControl = {}}},
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

local function sovereignKeyframe(sequence, time, transforms)
	local frame = Instance.new("Keyframe")
	frame.Name = string.format("SovereignLance_%03d", math.floor(time * 100))
	frame.Time = time
	for rootName, children in pairs(SOVEREIGN_HIERARCHY) do
		poseTree(rootName, children, transforms).Parent = frame
	end
	frame.Parent = sequence
end

local function lanceSequence(name, duration, frames)
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = name
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action
	for _, frame in ipairs(frames) do
		sovereignKeyframe(sequence, frame[1], frame[2])
	end
	sequence:SetAttribute("GuardianAnimation", name)
	sequence:SetAttribute("DurationSeconds", duration)
	sequence:SetAttribute("SovereignApexLanceVariant", true)
	sequence:SetAttribute("SpecificationVersion", "Sovereign-Lance-1.0")
	return sequence
end

local function hunterStance(torsoYaw)
	return {
		LowerTorso = CFrame.new(0, -0.65, -0.18) * CFrame.Angles(math.rad(-7), math.rad(torsoYaw * 0.35), 0),
		UpperTorso = CFrame.Angles(math.rad(-8), math.rad(torsoYaw), math.rad(-2)),
		Head = CFrame.Angles(math.rad(3), math.rad(-torsoYaw * 0.72), 0),
		RightUpperArm = CFrame.Angles(math.rad(22), math.rad(5), math.rad(18)),
		RightLowerArm = CFrame.Angles(math.rad(34), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(13), math.rad(-5), math.rad(-3)),
		LeftLowerLeg = CFrame.Angles(math.rad(-28), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(10), math.rad(-7), 0),
		RightUpperLeg = CFrame.Angles(math.rad(10), math.rad(5), math.rad(3)),
		RightLowerLeg = CFrame.Angles(math.rad(-23), 0, 0),
		RightFoot = CFrame.Angles(math.rad(8), math.rad(7), 0),
	}
end

function Library.BuildApexLanceThrust()
	local windup = hunterStance(20)
	windup.LeftUpperArm = CFrame.Angles(math.rad(-24), math.rad(-22), math.rad(-30))
	windup.LeftLowerArm = CFrame.Angles(math.rad(56), math.rad(-5), 0)
	windup.ApexLanceControl = CFrame.Angles(math.rad(7), 0, math.rad(-5))

	local strike = hunterStance(-18)
	strike.LowerTorso = CFrame.new(0, -0.38, -0.72) * CFrame.Angles(math.rad(-12), math.rad(-7), 0)
	strike.UpperTorso = CFrame.new(0, 0, -0.42) * CFrame.Angles(math.rad(-12), math.rad(-18), math.rad(2))
	strike.LeftUpperArm = CFrame.Angles(math.rad(84), math.rad(12), math.rad(-18))
	strike.LeftLowerArm = CFrame.Angles(math.rad(-9), 0, 0)
	strike.ApexLanceControl = CFrame.Angles(math.rad(-8), 0, 0)

	return lanceSequence("SovereignApexLanceThrust", 1.28, {
		{0, {}}, {0.34, windup}, {0.62, strike}, {0.78, strike}, {1.28, {}},
	})
end

function Library.BuildApexLanceCut()
	local windup = hunterStance(30)
	windup.LeftUpperArm = CFrame.Angles(math.rad(24), math.rad(-38), math.rad(-48))
	windup.LeftLowerArm = CFrame.Angles(math.rad(46), 0, math.rad(-6))
	windup.ApexLanceControl = CFrame.Angles(0, math.rad(-22), math.rad(-10))

	local cut = hunterStance(-36)
	cut.LowerTorso = CFrame.new(0, -0.48, -0.35) * CFrame.Angles(math.rad(-8), math.rad(-14), math.rad(2))
	cut.UpperTorso = CFrame.Angles(math.rad(-9), math.rad(-36), math.rad(6))
	cut.Head = CFrame.Angles(math.rad(2), math.rad(24), math.rad(-2))
	cut.LeftUpperArm = CFrame.Angles(math.rad(72), math.rad(34), math.rad(20))
	cut.LeftLowerArm = CFrame.Angles(math.rad(7), 0, math.rad(4))
	cut.ApexLanceControl = CFrame.Angles(math.rad(-4), math.rad(28), math.rad(8))

	return lanceSequence("SovereignApexLanceCut", 1.42, {
		{0, {}}, {0.42, windup}, {0.68, cut}, {0.88, cut}, {1.42, {}},
	})
end

function Library.BuildApexLanceBeam()
	local aim = hunterStance(-8)
	aim.LowerTorso = CFrame.new(0, -0.82, 0.05) * CFrame.Angles(math.rad(-5), math.rad(-3), 0)
	aim.UpperTorso = CFrame.Angles(math.rad(-7), math.rad(-8), math.rad(1))
	aim.Head = CFrame.Angles(math.rad(2), math.rad(7), 0)
	aim.LeftUpperArm = CFrame.Angles(math.rad(70), math.rad(7), math.rad(-21))
	aim.LeftLowerArm = CFrame.Angles(math.rad(-5), 0, 0)
	aim.ApexLanceControl = CFrame.Angles(math.rad(-13), 0, 0)

	local recoil = table.clone(aim)
	recoil.LowerTorso = CFrame.new(0, -0.94, 0.35) * CFrame.Angles(math.rad(2), math.rad(-3), 0)
	recoil.UpperTorso = CFrame.Angles(math.rad(3), math.rad(-7), math.rad(-2))
	recoil.LeftUpperArm = CFrame.Angles(math.rad(64), math.rad(7), math.rad(-21))
	recoil.ApexLanceControl = CFrame.new(0, 0.18, 0.35) * CFrame.Angles(math.rad(-10), 0, 0)

	return lanceSequence("SovereignApexLanceBeam", 2.25, {
		{0, {}}, {0.42, aim}, {1.1, aim}, {1.18, recoil}, {1.48, aim}, {1.82, aim}, {2.25, {}},
	})
end

function Library.BuildHunterDroneCommand()
	local command = hunterStance(0)
	command.LowerTorso = CFrame.new(0, -0.52, -0.12) * CFrame.Angles(math.rad(-6), 0, 0)
	command.UpperTorso = CFrame.Angles(math.rad(-5), math.rad(4), 0)
	command.Head = CFrame.Angles(math.rad(-5), math.rad(-6), 0)
	command.LeftUpperArm = CFrame.Angles(math.rad(18), math.rad(-8), math.rad(-16))
	command.LeftLowerArm = CFrame.Angles(math.rad(28), 0, 0)
	command.RightUpperArm = CFrame.Angles(math.rad(62), math.rad(-14), math.rad(34))
	command.RightLowerArm = CFrame.Angles(math.rad(48), 0, math.rad(-8))

	local release = table.clone(command)
	release.UpperTorso = CFrame.Angles(math.rad(-7), math.rad(-8), math.rad(-2))
	release.Head = CFrame.Angles(math.rad(-2), math.rad(10), 0)
	release.RightUpperArm = CFrame.Angles(math.rad(78), math.rad(12), math.rad(20))
	release.RightLowerArm = CFrame.Angles(math.rad(12), 0, 0)

	return lanceSequence("SovereignHunterDroneCommand", 9.4, {
		{0, {}}, {0.38, command}, {0.72, release}, {1.2, command},
		{8.3, command}, {8.8, release}, {9.4, {}},
	})
end

function Library.BuildSovereignLock()
	local anchor = hunterStance(0)
	anchor.LowerTorso = CFrame.new(0, -0.88, 0.08) * CFrame.Angles(math.rad(-4), 0, 0)
	anchor.UpperTorso = CFrame.Angles(math.rad(-3), 0, 0)
	anchor.Head = CFrame.Angles(math.rad(-6), 0, 0)
	anchor.LeftUpperArm = CFrame.Angles(math.rad(42), math.rad(-18), math.rad(-34))
	anchor.LeftLowerArm = CFrame.Angles(math.rad(26), 0, 0)
	anchor.RightUpperArm = CFrame.Angles(math.rad(42), math.rad(18), math.rad(34))
	anchor.RightLowerArm = CFrame.Angles(math.rad(26), 0, 0)

	local lock = table.clone(anchor)
	lock.LowerTorso = CFrame.new(0, -1.08, 0.18) * CFrame.Angles(math.rad(-2), 0, 0)
	lock.UpperTorso = CFrame.Angles(math.rad(-6), 0, 0)
	lock.Head = CFrame.Angles(math.rad(3), 0, 0)
	lock.LeftUpperArm = CFrame.Angles(math.rad(66), math.rad(-12), math.rad(-42))
	lock.LeftLowerArm = CFrame.Angles(math.rad(12), 0, 0)
	lock.RightUpperArm = CFrame.Angles(math.rad(66), math.rad(12), math.rad(42))
	lock.RightLowerArm = CFrame.Angles(math.rad(12), 0, 0)

	return lanceSequence("SovereignLock", 9.2, {
		{0, {}}, {0.48, anchor}, {1.05, lock}, {2.1, lock},
		{6.5, lock}, {7.4, anchor}, {8.65, anchor}, {9.2, {}},
	})
end

return Library
