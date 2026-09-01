local Library = {}

local HIERARCHY = {
	HumanoidRootPart = {
		LowerTorso = {
			UpperTorso = {
				Head = {},
				LeftUpperArm = {
					LeftLowerArm = {LeftHand = {}},
				},
				RightUpperArm = {
					RightLowerArm = {RightHand = {}},
				},
			},
			LeftUpperLeg = {
				LeftLowerLeg = {LeftFoot = {}},
			},
			RightUpperLeg = {
				RightLowerLeg = {RightFoot = {}},
			},
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

local function keyframe(sequence, time, transforms)
	local frame = Instance.new("Keyframe")
	frame.Name = string.format("Idle_%03d", math.floor(time * 100))
	frame.Time = time
	for rootName, children in pairs(HIERARCHY) do
		poseTree(rootName, children, transforms).Parent = frame
	end
	frame.Parent = sequence
end

function Library.BuildIdle()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianIdle"
	sequence.Loop = true
	sequence.Priority = Enum.AnimationPriority.Idle

	local guarded = {
		LeftShoulder = CFrame.Angles(math.rad(9), 0, math.rad(-4)),
		LeftElbow = CFrame.Angles(math.rad(14), 0, 0),
		RightShoulder = CFrame.Angles(math.rad(7), 0, math.rad(4)),
		RightElbow = CFrame.Angles(math.rad(11), 0, 0),
	}

	keyframe(sequence, 0, {
		UpperTorso = CFrame.Angles(math.rad(2), 0, math.rad(-2)),
		Head = CFrame.Angles(0, math.rad(-12), 0),
		LeftUpperArm = guarded.LeftShoulder,
		LeftLowerArm = guarded.LeftElbow,
		RightUpperArm = guarded.RightShoulder,
		RightLowerArm = guarded.RightElbow,
	})
	keyframe(sequence, 1, {
		UpperTorso = CFrame.new(0, 0.28, 0) * CFrame.Angles(math.rad(1), 0, math.rad(2)),
		Head = CFrame.Angles(math.rad(-3), 0, 0),
		LeftUpperArm = guarded.LeftShoulder * CFrame.Angles(math.rad(4), 0, 0),
		LeftLowerArm = guarded.LeftElbow,
		RightUpperArm = guarded.RightShoulder,
		RightLowerArm = guarded.RightElbow * CFrame.Angles(math.rad(4), 0, 0),
	})
	keyframe(sequence, 2, {
		UpperTorso = CFrame.Angles(math.rad(2), 0, math.rad(2)),
		Head = CFrame.Angles(0, math.rad(12), 0),
		LeftUpperArm = guarded.LeftShoulder,
		LeftLowerArm = guarded.LeftElbow,
		RightUpperArm = guarded.RightShoulder,
		RightLowerArm = guarded.RightElbow,
	})
	keyframe(sequence, 3, {
		UpperTorso = CFrame.new(0, -0.22, 0) * CFrame.Angles(math.rad(3), 0, math.rad(-1.5)),
		Head = CFrame.Angles(math.rad(2), 0, 0),
		LeftUpperArm = guarded.LeftShoulder,
		LeftLowerArm = guarded.LeftElbow * CFrame.Angles(math.rad(4), 0, 0),
		RightUpperArm = guarded.RightShoulder * CFrame.Angles(math.rad(4), 0, 0),
		RightLowerArm = guarded.RightElbow,
	})
	keyframe(sequence, 4, {
		UpperTorso = CFrame.Angles(math.rad(2), 0, math.rad(-2)),
		Head = CFrame.Angles(0, math.rad(-12), 0),
		LeftUpperArm = guarded.LeftShoulder,
		LeftLowerArm = guarded.LeftElbow,
		RightUpperArm = guarded.RightShoulder,
		RightLowerArm = guarded.RightElbow,
	})

	sequence:SetAttribute("GuardianAnimation", "Idle")
	sequence:SetAttribute("DurationSeconds", 4)
	sequence:SetAttribute("SpecificationVersion", "1.1-DiagnosticVisible")
	return sequence
end

return Library
