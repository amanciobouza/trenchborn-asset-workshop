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


function Library.BuildAlertIdle()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianAlertIdle"
	sequence.Loop = true
	sequence.Priority = Enum.AnimationPriority.Idle

	local function alertPose(headYaw, torsoRoll, armPulse)
		return {
			LowerTorso = CFrame.new(0, -0.18, 0) * CFrame.Angles(math.rad(2), 0, 0),
			UpperTorso = CFrame.Angles(math.rad(5), math.rad(headYaw * 0.2), math.rad(torsoRoll)),
			Head = CFrame.Angles(math.rad(-2), math.rad(headYaw), 0),
			LeftUpperArm = CFrame.Angles(math.rad(18 + armPulse), math.rad(-8), math.rad(-16)),
			LeftLowerArm = CFrame.Angles(math.rad(26 + armPulse), 0, 0),
			RightUpperArm = CFrame.Angles(math.rad(20 + armPulse), math.rad(5), math.rad(10)),
			RightLowerArm = CFrame.Angles(math.rad(22 + armPulse), 0, 0),
			LeftUpperLeg = CFrame.Angles(math.rad(4), 0, math.rad(-1)),
			LeftLowerLeg = CFrame.Angles(math.rad(-9), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(4), 0, math.rad(1)),
			RightLowerLeg = CFrame.Angles(math.rad(-9), 0, 0),
		}
	end

	keyframe(sequence, 0, alertPose(-8, -1.5, 0))
	keyframe(sequence, 0.6, alertPose(0, 0.5, 2))
	keyframe(sequence, 1.2, alertPose(8, 1.5, 0))
	keyframe(sequence, 1.8, alertPose(0, -0.5, 3))
	keyframe(sequence, 2.4, alertPose(-8, -1.5, 0))

	sequence:SetAttribute("GuardianAnimation", "AlertIdle")
	sequence:SetAttribute("DurationSeconds", 2.4)
	sequence:SetAttribute("SpecificationVersion", "1.0")
	return sequence
end


function Library.BuildWalk()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianWalk"
	sequence.Loop = true
	sequence.Priority = Enum.AnimationPriority.Movement

	local function walkPose(leftHip, leftKnee, leftFoot, rightHip, rightKnee, rightFoot, height, roll)
		return {
			LowerTorso = CFrame.new(0, height, 0) * CFrame.Angles(math.rad(3), 0, math.rad(roll)),
			UpperTorso = CFrame.Angles(math.rad(3), math.rad(-roll * 0.6), math.rad(-roll * 0.7)),
			Head = CFrame.Angles(math.rad(-2), math.rad(roll * 0.8), math.rad(roll * 0.25)),
			LeftUpperArm = CFrame.Angles(math.rad(10 - leftHip * 0.22), math.rad(-5), math.rad(-8)),
			LeftLowerArm = CFrame.Angles(math.rad(20), 0, 0),
			RightUpperArm = CFrame.Angles(math.rad(12 - rightHip * 0.28), math.rad(4), math.rad(7)),
			RightLowerArm = CFrame.Angles(math.rad(17), 0, 0),
			LeftUpperLeg = CFrame.Angles(math.rad(leftHip), 0, math.rad(-1)),
			LeftLowerLeg = CFrame.Angles(math.rad(leftKnee), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(leftFoot), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(rightHip), 0, math.rad(1)),
			RightLowerLeg = CFrame.Angles(math.rad(rightKnee), 0, 0),
			RightFoot = CFrame.Angles(math.rad(rightFoot), 0, 0),
		}
	end

	-- Left contact, right leg trailing.
	keyframe(sequence, 0, walkPose(18, -7, -9, -16, -13, 8, 0, -1.5))
	-- Left leg takes the weight while the right leg passes.
	keyframe(sequence, 0.5, walkPose(7, -12, 2, 4, -28, -5, -0.32, 2))
	-- Right contact, left leg trailing.
	keyframe(sequence, 1.0, walkPose(-16, -13, 8, 18, -7, -9, 0, 1.5))
	-- Right leg takes the weight while the left leg passes.
	keyframe(sequence, 1.5, walkPose(4, -28, -5, 7, -12, 2, -0.32, -2))
	keyframe(sequence, 2.0, walkPose(18, -7, -9, -16, -13, 8, 0, -1.5))

	sequence:SetAttribute("GuardianAnimation", "Walk")
	sequence:SetAttribute("DurationSeconds", 2)
	sequence:SetAttribute("SpecificationVersion", "1.0")
	sequence:SetAttribute("RootMotion", false)
	return sequence
end

return Library
