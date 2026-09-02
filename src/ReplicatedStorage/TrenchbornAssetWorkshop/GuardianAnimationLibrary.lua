local Library = {}

local HIERARCHY = {
	HumanoidRootPart = {
		LowerTorso = {
			UpperTorso = {
				Head = {},
				NetLauncherControl = {},
				LeftUpperArm = {
					LeftLowerArm = {LeftHand = {}, RiotShieldControl = {}},
				},
				RightUpperArm = {
					RightLowerArm = {RightHand = {}, PulseCannonControl = {}},
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
			LeftUpperLeg = CFrame.Angles(math.rad(leftHip), 0, 0),
			LeftLowerLeg = CFrame.Angles(math.rad(leftKnee), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(leftFoot), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(rightHip), 0, 0),
			RightLowerLeg = CFrame.Angles(math.rad(rightKnee), 0, 0),
			RightFoot = CFrame.Angles(math.rad(rightFoot), 0, 0),
		}
	end

	-- Left contact, right leg trailing.
	keyframe(sequence, 0, walkPose(18, -7, -14, -16, -13, 12, 0, -1.5))
	-- Left leg takes the weight while the right leg passes.
	keyframe(sequence, 0.5, walkPose(7, -12, 6, 4, -28, -12, -0.32, 2))
	-- Right contact, left leg trailing.
	keyframe(sequence, 1.0, walkPose(-16, -13, 12, 18, -7, -14, 0, 1.5))
	-- Right leg takes the weight while the left leg passes.
	keyframe(sequence, 1.5, walkPose(4, -28, -12, 7, -12, 6, -0.32, -2))
	keyframe(sequence, 2.0, walkPose(18, -7, -14, -16, -13, 12, 0, -1.5))

	sequence:SetAttribute("GuardianAnimation", "Walk")
	sequence:SetAttribute("DurationSeconds", 2)
	sequence:SetAttribute("SpecificationVersion", "1.1-FootLockReady")
	sequence:SetAttribute("RootMotion", false)
	return sequence
end


function Library.BuildRun()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianRun"
	sequence.Loop = true
	sequence.Priority = Enum.AnimationPriority.Movement

	local function runPose(leftHip, leftKnee, leftFoot, rightHip, rightKnee, rightFoot, height, roll)
		return {
			LowerTorso = CFrame.new(0, height, 0) * CFrame.Angles(math.rad(8), 0, math.rad(roll)),
			UpperTorso = CFrame.Angles(math.rad(7), math.rad(-roll * 0.5), math.rad(-roll * 0.6)),
			Head = CFrame.Angles(math.rad(-5), math.rad(roll * 0.5), 0),
			LeftUpperArm = CFrame.Angles(math.rad(16 - leftHip * 0.18), math.rad(-7), math.rad(-11)),
			LeftLowerArm = CFrame.Angles(math.rad(27), 0, 0),
			RightUpperArm = CFrame.Angles(math.rad(18 - rightHip * 0.22), math.rad(5), math.rad(9)),
			RightLowerArm = CFrame.Angles(math.rad(24), 0, 0),
			LeftUpperLeg = CFrame.Angles(math.rad(leftHip), 0, 0),
			LeftLowerLeg = CFrame.Angles(math.rad(leftKnee), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(leftFoot), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(rightHip), 0, 0),
			RightLowerLeg = CFrame.Angles(math.rad(rightKnee), 0, 0),
			RightFoot = CFrame.Angles(math.rad(rightFoot), 0, 0),
		}
	end

	keyframe(sequence, 0, runPose(28, -10, -18, -24, -18, 15, 0, -2.5))
	keyframe(sequence, 0.3, runPose(8, -16, 8, 8, -40, -16, -0.48, 3.5))
	keyframe(sequence, 0.6, runPose(-24, -18, 15, 28, -10, -18, 0, 2.5))
	keyframe(sequence, 0.9, runPose(8, -40, -16, 8, -16, 8, -0.48, -3.5))
	keyframe(sequence, 1.2, runPose(28, -10, -18, -24, -18, 15, 0, -2.5))

	sequence:SetAttribute("GuardianAnimation", "Run")
	sequence:SetAttribute("DurationSeconds", 1.2)
	sequence:SetAttribute("SpecificationVersion", "1.0")
	sequence:SetAttribute("RootMotion", false)
	return sequence
end


local function buildTurn(name, direction)
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "Guardian" .. name
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Movement

	local function turnPose(yaw, load, settle)
		return {
			LowerTorso = CFrame.new(0, -load, 0) * CFrame.Angles(math.rad(3 + load * 5), math.rad(yaw * direction), math.rad(-2 * direction)),
			UpperTorso = CFrame.Angles(math.rad(4), math.rad(yaw * 0.7 * direction), math.rad(2 * direction)),
			Head = CFrame.Angles(math.rad(-2), math.rad((yaw + 5) * direction), 0),
			LeftUpperArm = CFrame.Angles(math.rad(14 + settle), math.rad(-5), math.rad(-10)),
			LeftLowerArm = CFrame.Angles(math.rad(24), 0, 0),
			RightUpperArm = CFrame.Angles(math.rad(16 + settle), math.rad(4), math.rad(9)),
			RightLowerArm = CFrame.Angles(math.rad(21), 0, 0),
			LeftUpperLeg = CFrame.Angles(math.rad(5 + load * 12), 0, 0),
			LeftLowerLeg = CFrame.Angles(math.rad(-10 - load * 18), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(4), math.rad(5 * direction), 0),
			RightUpperLeg = CFrame.Angles(math.rad(5 + load * 12), 0, 0),
			RightLowerLeg = CFrame.Angles(math.rad(-10 - load * 18), 0, 0),
			RightFoot = CFrame.Angles(math.rad(4), math.rad(5 * direction), 0),
		}
	end

	keyframe(sequence, 0, turnPose(0, 0, 0))
	keyframe(sequence, 0.2, turnPose(4, 0.18, 3))
	keyframe(sequence, 0.5, turnPose(10, 0.28, 5))
	keyframe(sequence, 0.75, turnPose(2, 0.05, 1))

	sequence:SetAttribute("GuardianAnimation", name)
	sequence:SetAttribute("DurationSeconds", 0.75)
	sequence:SetAttribute("SpecificationVersion", "1.0")
	return sequence
end

function Library.BuildTurnLeft()
	return buildTurn("TurnLeft", 1)
end

function Library.BuildTurnRight()
	return buildTurn("TurnRight", -1)
end


function Library.BuildFall()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianFall"
	sequence.Loop = true
	sequence.Priority = Enum.AnimationPriority.Action

	local function fallPose(pulse)
		return {
			LowerTorso = CFrame.Angles(math.rad(-3 + pulse), 0, 0),
			UpperTorso = CFrame.Angles(math.rad(7 - pulse), 0, 0),
			Head = CFrame.Angles(math.rad(-6), 0, 0),
			LeftUpperArm = CFrame.Angles(math.rad(26 + pulse), math.rad(-8), math.rad(-20)),
			LeftLowerArm = CFrame.Angles(math.rad(34), 0, 0),
			RightUpperArm = CFrame.Angles(math.rad(25 + pulse), math.rad(6), math.rad(15)),
			RightLowerArm = CFrame.Angles(math.rad(31), 0, 0),
			LeftUpperLeg = CFrame.Angles(math.rad(9), 0, 0),
			LeftLowerLeg = CFrame.Angles(math.rad(-22 - pulse), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(18), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(5), 0, 0),
			RightLowerLeg = CFrame.Angles(math.rad(-18 + pulse), 0, 0),
			RightFoot = CFrame.Angles(math.rad(16), 0, 0),
		}
	end

	keyframe(sequence, 0, fallPose(0))
	keyframe(sequence, 0.45, fallPose(3))
	keyframe(sequence, 0.9, fallPose(0))
	sequence:SetAttribute("GuardianAnimation", "Fall")
	sequence:SetAttribute("DurationSeconds", 0.9)
	sequence:SetAttribute("SpecificationVersion", "1.0")
	return sequence
end

function Library.BuildLand()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianLand"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action

	keyframe(sequence, 0, {
		UpperTorso = CFrame.Angles(math.rad(7), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(8), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-20), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(8), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-20), 0, 0),
	})
	keyframe(sequence, 0.12, {
		LowerTorso = CFrame.new(0, -0.65, 0) * CFrame.Angles(math.rad(7), 0, 0),
		UpperTorso = CFrame.Angles(math.rad(12), 0, 0),
		Head = CFrame.Angles(math.rad(-9), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(32), math.rad(-8), math.rad(-22)),
		LeftLowerArm = CFrame.Angles(math.rad(42), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(30), math.rad(5), math.rad(17)),
		RightLowerArm = CFrame.Angles(math.rad(38), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(16), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-42), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(11), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(16), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-42), 0, 0),
		RightFoot = CFrame.Angles(math.rad(11), 0, 0),
	})
	keyframe(sequence, 0.46, {
		LowerTorso = CFrame.new(0, -0.2, 0) * CFrame.Angles(math.rad(3), 0, 0),
		UpperTorso = CFrame.Angles(math.rad(5), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(18), math.rad(-7), math.rad(-14)),
		LeftLowerArm = CFrame.Angles(math.rad(27), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(19), math.rad(5), math.rad(11)),
		RightLowerArm = CFrame.Angles(math.rad(24), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(6), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-14), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(6), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-14), 0, 0),
	})
	keyframe(sequence, 0.8, {
		UpperTorso = CFrame.Angles(math.rad(3), 0, 0),
		Head = CFrame.Angles(math.rad(-2), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(12), 0, math.rad(-7)),
		LeftLowerArm = CFrame.Angles(math.rad(18), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(11), 0, math.rad(7)),
		RightLowerArm = CFrame.Angles(math.rad(16), 0, 0),
	})
	sequence:SetAttribute("GuardianAnimation", "Land")
	sequence:SetAttribute("DurationSeconds", 0.8)
	sequence:SetAttribute("SpecificationVersion", "1.0")
	return sequence
end


function Library.BuildWalkBackward()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianWalkBackward"
	sequence.Loop = true
	sequence.Priority = Enum.AnimationPriority.Movement

	local function backwardPose(leftHip, leftKnee, leftFoot, rightHip, rightKnee, rightFoot, height, roll)
		return {
			LowerTorso = CFrame.new(0, height, 0) * CFrame.Angles(math.rad(5), 0, math.rad(roll)),
			UpperTorso = CFrame.Angles(math.rad(6), math.rad(-roll * 0.4), math.rad(-roll * 0.5)),
			Head = CFrame.Angles(math.rad(-3), 0, 0),
			LeftUpperArm = CFrame.Angles(math.rad(19), math.rad(-8), math.rad(-16)),
			LeftLowerArm = CFrame.Angles(math.rad(28), 0, 0),
			RightUpperArm = CFrame.Angles(math.rad(20), math.rad(5), math.rad(11)),
			RightLowerArm = CFrame.Angles(math.rad(24), 0, 0),
			LeftUpperLeg = CFrame.Angles(math.rad(leftHip), 0, 0),
			LeftLowerLeg = CFrame.Angles(math.rad(leftKnee), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(leftFoot), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(rightHip), 0, 0),
			RightLowerLeg = CFrame.Angles(math.rad(rightKnee), 0, 0),
			RightFoot = CFrame.Angles(math.rad(rightFoot), 0, 0),
		}
	end

	keyframe(sequence, 0, backwardPose(-11, -12, 10, 12, -8, -12, 0, -1))
	keyframe(sequence, 0.55, backwardPose(3, -24, -9, 5, -13, 5, -0.25, 1.5))
	keyframe(sequence, 1.1, backwardPose(12, -8, -12, -11, -12, 10, 0, 1))
	keyframe(sequence, 1.65, backwardPose(5, -13, 5, 3, -24, -9, -0.25, -1.5))
	keyframe(sequence, 2.2, backwardPose(-11, -12, 10, 12, -8, -12, 0, -1))

	sequence:SetAttribute("GuardianAnimation", "WalkBackward")
	sequence:SetAttribute("DurationSeconds", 2.2)
	sequence:SetAttribute("SpecificationVersion", "1.0")
	sequence:SetAttribute("RootMotion", false)
	return sequence
end


function Library.BuildDamageReact()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianDamageReact"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action2

	keyframe(sequence, 0, {})
	keyframe(sequence, 0.07, {
		LowerTorso = CFrame.new(0, -0.12, 0) * CFrame.Angles(math.rad(-4), 0, math.rad(-2)),
		UpperTorso = CFrame.Angles(math.rad(-13), math.rad(-5), math.rad(4)),
		Head = CFrame.Angles(math.rad(10), math.rad(4), math.rad(-3)),
		LeftUpperArm = CFrame.Angles(math.rad(25), math.rad(-10), math.rad(-19)),
		LeftLowerArm = CFrame.Angles(math.rad(38), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(28), math.rad(7), math.rad(17)),
		RightLowerArm = CFrame.Angles(math.rad(34), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(8), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-25), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(3), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-13), 0, 0),
	})
	keyframe(sequence, 0.2, {
		LowerTorso = CFrame.new(0, -0.05, 0) * CFrame.Angles(math.rad(3), 0, math.rad(1)),
		UpperTorso = CFrame.Angles(math.rad(7), math.rad(2), math.rad(-2)),
		Head = CFrame.Angles(math.rad(-5), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(18), math.rad(-7), math.rad(-14)),
		LeftLowerArm = CFrame.Angles(math.rad(29), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(20), math.rad(5), math.rad(12)),
		RightLowerArm = CFrame.Angles(math.rad(27), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(5), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-17), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(5), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-17), 0, 0),
	})
	keyframe(sequence, 0.42, {
		UpperTorso = CFrame.Angles(math.rad(3), 0, 0),
		Head = CFrame.Angles(math.rad(-2), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(12), 0, math.rad(-7)),
		LeftLowerArm = CFrame.Angles(math.rad(18), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(11), 0, math.rad(7)),
		RightLowerArm = CFrame.Angles(math.rad(16), 0, 0),
	})
	sequence:SetAttribute("GuardianAnimation", "DamageReact")
	sequence:SetAttribute("DurationSeconds", 0.42)
	sequence:SetAttribute("SpecificationVersion", "1.0")
	return sequence
end


function Library.BuildStagger()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianStagger"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action3

	-- A heavy frontal impact drives the upper body back and forces a wide,
	-- asymmetric recovery step. The feet remain mechanically aligned.
	keyframe(sequence, 0, {})
	keyframe(sequence, 0.1, {
		LowerTorso = CFrame.new(0, -0.18, 0) * CFrame.Angles(math.rad(-7), math.rad(-3), math.rad(5)),
		UpperTorso = CFrame.Angles(math.rad(-19), math.rad(-8), math.rad(-7)),
		Head = CFrame.Angles(math.rad(15), math.rad(7), math.rad(5)),
		LeftUpperArm = CFrame.Angles(math.rad(34), math.rad(-12), math.rad(-25)),
		LeftLowerArm = CFrame.Angles(math.rad(47), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(38), math.rad(9), math.rad(23)),
		RightLowerArm = CFrame.Angles(math.rad(43), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(13), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-34), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(10), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(-8), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-15), 0, 0),
		RightFoot = CFrame.Angles(math.rad(13), 0, 0),
	})
	keyframe(sequence, 0.34, {
		LowerTorso = CFrame.new(0, -0.48, 0) * CFrame.Angles(math.rad(8), math.rad(4), math.rad(-7)),
		UpperTorso = CFrame.Angles(math.rad(14), math.rad(9), math.rad(9)),
		Head = CFrame.Angles(math.rad(-10), math.rad(-6), math.rad(-5)),
		LeftUpperArm = CFrame.Angles(math.rad(29), math.rad(-9), math.rad(-21)),
		LeftLowerArm = CFrame.Angles(math.rad(40), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(32), math.rad(7), math.rad(19)),
		RightLowerArm = CFrame.Angles(math.rad(37), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(-5), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-17), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(8), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(17), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-37), 0, 0),
		RightFoot = CFrame.Angles(math.rad(12), 0, 0),
	})
	keyframe(sequence, 0.68, {
		LowerTorso = CFrame.new(0, -0.26, 0) * CFrame.Angles(math.rad(5), 0, math.rad(-2)),
		UpperTorso = CFrame.Angles(math.rad(8), math.rad(2), math.rad(2)),
		Head = CFrame.Angles(math.rad(-4), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(21), math.rad(-7), math.rad(-16)),
		LeftLowerArm = CFrame.Angles(math.rad(31), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(23), math.rad(5), math.rad(14)),
		RightLowerArm = CFrame.Angles(math.rad(29), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(7), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-21), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(9), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-24), 0, 0),
	})
	keyframe(sequence, 1.05, {
		UpperTorso = CFrame.Angles(math.rad(3), 0, 0),
		Head = CFrame.Angles(math.rad(-2), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(12), 0, math.rad(-7)),
		LeftLowerArm = CFrame.Angles(math.rad(18), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(11), 0, math.rad(7)),
		RightLowerArm = CFrame.Angles(math.rad(16), 0, 0),
	})
	sequence:SetAttribute("GuardianAnimation", "Stagger")
	sequence:SetAttribute("DurationSeconds", 1.05)
	sequence:SetAttribute("SpecificationVersion", "1.0")
	return sequence
end


function Library.BuildDefeat()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianDefeat"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action4

	keyframe(sequence, 0, {})
	-- Systems fail: the torso pitches forward while the right leg loses load.
	keyframe(sequence, 0.18, {
		LowerTorso = CFrame.new(0, -0.35, 0) * CFrame.Angles(math.rad(11), 0, math.rad(4)),
		UpperTorso = CFrame.Angles(math.rad(17), math.rad(-4), math.rad(-5)),
		Head = CFrame.Angles(math.rad(8), math.rad(3), math.rad(3)),
		LeftUpperArm = CFrame.Angles(math.rad(28), math.rad(-7), math.rad(-17)),
		LeftLowerArm = CFrame.Angles(math.rad(35), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(23), math.rad(5), math.rad(15)),
		RightLowerArm = CFrame.Angles(math.rad(30), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(11), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-29), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(18), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-44), 0, 0),
		RightFoot = CFrame.Angles(math.rad(13), 0, 0),
	})
	-- One-knee impact keeps the silhouette readable and avoids a weightless ragdoll.
	keyframe(sequence, 0.58, {
		LowerTorso = CFrame.new(0, -6.4, 0.15) * CFrame.Angles(math.rad(-2), math.rad(1), math.rad(2)),
		UpperTorso = CFrame.Angles(math.rad(-20), math.rad(-3), math.rad(-4)),
		Head = CFrame.Angles(math.rad(-7), math.rad(2), math.rad(2)),
		LeftUpperArm = CFrame.Angles(math.rad(38), math.rad(-10), math.rad(-27)),
		LeftLowerArm = CFrame.Angles(math.rad(54), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(31), math.rad(8), math.rad(22)),
		RightLowerArm = CFrame.Angles(math.rad(48), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(-8), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-18), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(10), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(4), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-98), 0, 0),
		RightFoot = CFrame.Angles(math.rad(92), 0, 0),
	})
	-- Final powered-down pose; the preview freezes on this keyframe.
	keyframe(sequence, 1.18, {
		LowerTorso = CFrame.new(0, -8.2, 0.2) * CFrame.Angles(math.rad(-4), math.rad(1), math.rad(2)),
		UpperTorso = CFrame.Angles(math.rad(-28), math.rad(-3), math.rad(-5)),
		Head = CFrame.Angles(math.rad(-12), math.rad(2), math.rad(2)),
		LeftUpperArm = CFrame.Angles(math.rad(0), 0, math.rad(-4)),
		LeftLowerArm = CFrame.Angles(math.rad(2), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(0), 0, math.rad(4)),
		RightLowerArm = CFrame.Angles(math.rad(2), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(100), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-112), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(12), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(2), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-106), 0, 0),
		RightFoot = CFrame.Angles(math.rad(76), 0, 0),
	})
	keyframe(sequence, 1.4, {
		LowerTorso = CFrame.new(0, -8.2, 0.2) * CFrame.Angles(math.rad(-4), math.rad(1), math.rad(2)),
		UpperTorso = CFrame.Angles(math.rad(-28), math.rad(-3), math.rad(-5)),
		Head = CFrame.Angles(math.rad(-12), math.rad(2), math.rad(2)),
		LeftUpperArm = CFrame.Angles(math.rad(0), 0, math.rad(-4)),
		LeftLowerArm = CFrame.Angles(math.rad(2), 0, 0),
		RightUpperArm = CFrame.Angles(math.rad(0), 0, math.rad(4)),
		RightLowerArm = CFrame.Angles(math.rad(2), 0, 0),
		LeftUpperLeg = CFrame.Angles(math.rad(100), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-112), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(12), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(2), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-106), 0, 0),
		RightFoot = CFrame.Angles(math.rad(76), 0, 0),
	})
	sequence:SetAttribute("GuardianAnimation", "Defeat")
	sequence:SetAttribute("DurationSeconds", 1.4)
	sequence:SetAttribute("HoldFinalPose", true)
	sequence:SetAttribute("SpecificationVersion", "1.7-SupportFootClearance")
	return sequence
end


function Library.BuildShieldBlock()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianShieldBlock"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action3

	local function blockPose(load)
		local leftUpper = CFrame.Angles(math.rad(80 + load * 6), math.rad(-3), math.rad(38))
		local leftLower = CFrame.Angles(math.rad(-22), math.rad(-3), math.rad(12))
		return {
			LowerTorso = CFrame.new(0, -0.2 - load, 0) * CFrame.Angles(math.rad(3), math.rad(-3), math.rad(-2)),
			UpperTorso = CFrame.Angles(math.rad(-4), math.rad(-7), math.rad(3)),
			Head = CFrame.Angles(math.rad(-2), math.rad(5), math.rad(-2)),
			-- The shield is welded to LeftLowerArm, so both arm joints carry it.
			LeftUpperArm = leftUpper,
			LeftLowerArm = leftLower,
			-- Counter-rotate the mount so the shield remains vertical in world space.
			RiotShieldControl = CFrame.new(0, -4.0, -0.85) * (leftUpper * leftLower):Inverse(),
			-- Cannon arm remains tucked behind the shield line.
			RightUpperArm = CFrame.Angles(math.rad(25), math.rad(7), math.rad(13)),
			RightLowerArm = CFrame.Angles(math.rad(38), 0, 0),
			LeftUpperLeg = CFrame.Angles(math.rad(9 + load * 7), 0, 0),
			LeftLowerLeg = CFrame.Angles(math.rad(-24 - load * 9), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(15), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(6 + load * 4), 0, 0),
			RightLowerLeg = CFrame.Angles(math.rad(-18 - load * 6), 0, 0),
			RightFoot = CFrame.Angles(math.rad(12), 0, 0),
		}
	end

	keyframe(sequence, 0, {})
	keyframe(sequence, 0.16, {
		LowerTorso = CFrame.new(0, -0.08, 0) * CFrame.Angles(math.rad(2), 0, 0),
		UpperTorso = CFrame.Angles(math.rad(-2), math.rad(-3), math.rad(1)),
		LeftUpperArm = CFrame.Angles(math.rad(36), math.rad(-2), math.rad(18)),
		LeftLowerArm = CFrame.Angles(math.rad(-10), math.rad(-1), math.rad(6)),
		RiotShieldControl = CFrame.new(0, -2.0, -0.4) * (CFrame.Angles(math.rad(36), math.rad(-2), math.rad(18))
			* CFrame.Angles(math.rad(-10), math.rad(-1), math.rad(6))):Inverse(),
	})
	keyframe(sequence, 0.48, blockPose(0.08))
	keyframe(sequence, 0.82, blockPose(0))

	sequence:SetAttribute("GuardianAnimation", "ShieldBlock")
	sequence:SetAttribute("DurationSeconds", 0.82)
	sequence:SetAttribute("HeldState", true)
	sequence:SetAttribute("SpecificationVersion", "1.5-SightlineClearance")
	return sequence
end


function Library.BuildPulseCannonFire()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianPulseCannonFire"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action3

	local function aimedPose(recoil)
		return {
			LowerTorso = CFrame.new(0, -0.28 - recoil * 0.18, 0)
				* CFrame.Angles(math.rad(2 + recoil * 3), math.rad(3), math.rad(1)),
			UpperTorso = CFrame.Angles(math.rad(-3 + recoil * 14), math.rad(7), math.rad(-2)),
			Head = CFrame.Angles(math.rad(-2 + recoil * 5), math.rad(-5), math.rad(1)),
			LeftUpperArm = CFrame.Angles(math.rad(28), math.rad(-5), math.rad(-13)),
			LeftLowerArm = CFrame.Angles(math.rad(36), 0, 0),
			RightUpperArm = CFrame.Angles(math.rad(82 - recoil * 25), math.rad(2), math.rad(-7)),
			RightLowerArm = CFrame.Angles(math.rad(-20 + recoil * 16), 0, math.rad(-2)),
			LeftUpperLeg = CFrame.Angles(math.rad(14 + recoil * 5), 0, 0),
			LeftLowerLeg = CFrame.Angles(math.rad(-34 - recoil * 5), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(18), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(8 + recoil * 4), 0, 0),
			RightLowerLeg = CFrame.Angles(math.rad(-23 - recoil * 6), 0, 0),
			RightFoot = CFrame.Angles(math.rad(14), 0, 0),
		}
	end

	keyframe(sequence, 0, {})
	keyframe(sequence, 0.52, aimedPose(0))
	-- Discharge: the cannon arm and upper body recoil as one mechanical mass.
	keyframe(sequence, 0.82, aimedPose(0))
	keyframe(sequence, 0.9, aimedPose(1))
	keyframe(sequence, 1.08, aimedPose(0.35))
	keyframe(sequence, 1.3, aimedPose(0))
	keyframe(sequence, 1.62, {})

	sequence:SetAttribute("GuardianAnimation", "PulseCannonFire")
	sequence:SetAttribute("DurationSeconds", 1.62)
	sequence:SetAttribute("AimCompleteTimeSeconds", 0.52)
	sequence:SetAttribute("DischargeTimeSeconds", 0.9)
	sequence:SetAttribute("SpecificationVersion", "1.2-AimHoldRecoil")
	return sequence
end


function Library.BuildContainmentNetLaunch()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "GuardianContainmentNetLaunch"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action3

	local function lockPose(recoil)
		return {
			LowerTorso = CFrame.new(0, -0.32 - recoil * 0.2, 0)
				* CFrame.Angles(math.rad(4 + recoil * 3), 0, 0),
			UpperTorso = CFrame.Angles(math.rad(-6 + recoil * 15), 0, 0),
			Head = CFrame.Angles(math.rad(-5 + recoil * 7), 0, 0),
			NetLauncherControl = CFrame.Angles(math.rad(-18 + recoil * 12), 0, 0),
			LeftUpperArm = CFrame.Angles(math.rad(24), math.rad(-5), math.rad(-12)),
			LeftLowerArm = CFrame.Angles(math.rad(34), 0, 0),
			RightUpperArm = CFrame.Angles(math.rad(27), math.rad(5), math.rad(12)),
			RightLowerArm = CFrame.Angles(math.rad(36), 0, 0),
			LeftUpperLeg = CFrame.Angles(math.rad(14 + recoil * 4), 0, 0),
			LeftLowerLeg = CFrame.Angles(math.rad(-35 - recoil * 5), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(19), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(11 + recoil * 4), 0, 0),
			RightLowerLeg = CFrame.Angles(math.rad(-29 - recoil * 5), 0, 0),
			RightFoot = CFrame.Angles(math.rad(17), 0, 0),
		}
	end

	keyframe(sequence, 0, {})
	keyframe(sequence, 0.35, lockPose(0))
	keyframe(sequence, 1.2, lockPose(0))
	keyframe(sequence, 1.35, lockPose(1))
	keyframe(sequence, 1.55, lockPose(0.3))
	keyframe(sequence, 1.82, lockPose(0))
	keyframe(sequence, 2.1, {})

	sequence:SetAttribute("GuardianAnimation", "ContainmentNetLaunch")
	sequence:SetAttribute("DurationSeconds", 2.1)
	sequence:SetAttribute("TelegraphSeconds", 1.35)
	sequence:SetAttribute("LaunchTimeSeconds", 1.35)
	sequence:SetAttribute("SpecificationVersion", "1.1-ReactionWindow")
	return sequence
end


function Library.BuildShockBaton()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "WardenShockBaton"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action3

	keyframe(sequence, 0, {})
	-- Mechanical wind-up: the torso counter-rotates while the baton arm loads behind the shoulder.
	keyframe(sequence, 0.2, {
		LowerTorso = CFrame.new(0, -0.18, 0) * CFrame.Angles(math.rad(3), math.rad(8), math.rad(-2)),
		UpperTorso = CFrame.Angles(math.rad(-3), math.rad(14), math.rad(-4)),
		Head = CFrame.Angles(math.rad(-1), math.rad(-10), math.rad(2)),
		LeftUpperArm = CFrame.Angles(math.rad(-34), math.rad(-8), math.rad(-28)),
		LeftLowerArm = CFrame.Angles(math.rad(-48), math.rad(2), math.rad(-8)),
		LeftUpperLeg = CFrame.Angles(math.rad(8), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-20), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(5), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-15), 0, 0),
	})
	-- Fast diagonal strike; the complete chassis commits its mass into the baton.
	keyframe(sequence, 0.46, {
		LowerTorso = CFrame.new(0, -0.42, -0.15) * CFrame.Angles(math.rad(-5), math.rad(-12), math.rad(3)),
		UpperTorso = CFrame.Angles(math.rad(-11), math.rad(-20), math.rad(7)),
		Head = CFrame.Angles(math.rad(5), math.rad(13), math.rad(-3)),
		LeftUpperArm = CFrame.Angles(math.rad(66), math.rad(8), math.rad(24)),
		LeftLowerArm = CFrame.Angles(math.rad(18), math.rad(-3), math.rad(8)),
		LeftUpperLeg = CFrame.Angles(math.rad(15), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-33), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(17), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(8), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-21), 0, 0),
		RightFoot = CFrame.Angles(math.rad(12), 0, 0),
	})
	-- Short impact hold makes the contact readable at Kaiju scale.
	keyframe(sequence, 0.56, {
		LowerTorso = CFrame.new(0, -0.48, -0.22) * CFrame.Angles(math.rad(-7), math.rad(-15), math.rad(4)),
		UpperTorso = CFrame.Angles(math.rad(-13), math.rad(-23), math.rad(8)),
		Head = CFrame.Angles(math.rad(6), math.rad(15), math.rad(-3)),
		LeftUpperArm = CFrame.Angles(math.rad(78), math.rad(10), math.rad(28)),
		LeftLowerArm = CFrame.Angles(math.rad(24), math.rad(-4), math.rad(10)),
		LeftUpperLeg = CFrame.Angles(math.rad(17), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-36), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(18), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(9), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-23), 0, 0),
		RightFoot = CFrame.Angles(math.rad(13), 0, 0),
	})
	keyframe(sequence, 0.78, {
		LowerTorso = CFrame.new(0, -0.2, 0) * CFrame.Angles(math.rad(-2), math.rad(-5), math.rad(1)),
		UpperTorso = CFrame.Angles(math.rad(-5), math.rad(-8), math.rad(3)),
		LeftUpperArm = CFrame.Angles(math.rad(34), math.rad(3), math.rad(12)),
		LeftLowerArm = CFrame.Angles(math.rad(20), 0, math.rad(4)),
	})
	keyframe(sequence, 1.05, {})

	sequence:SetAttribute("GuardianAnimation", "ShockBaton")
	sequence:SetAttribute("DurationSeconds", 1.05)
	sequence:SetAttribute("ImpactTimeSeconds", 0.56)
	sequence:SetAttribute("SpecificationVersion", "1.0-MechanicalDiagonalStrike")
	return sequence
end


function Library.BuildWarningPulse()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "WardenWarningPulse"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action3

	local function chargePose(load)
		return {
			LowerTorso = CFrame.new(0, -0.28 - load * 0.28, 0)
				* CFrame.Angles(math.rad(3 + load * 3), 0, 0),
			UpperTorso = CFrame.Angles(math.rad(-4 - load * 4), 0, 0),
			Head = CFrame.Angles(math.rad(2 + load * 2), 0, 0),
			LeftUpperArm = CFrame.Angles(math.rad(16 + load * 8), math.rad(-7), math.rad(-22 - load * 5)),
			LeftLowerArm = CFrame.Angles(math.rad(28 + load * 8), 0, math.rad(-4)),
			RightUpperArm = CFrame.Angles(math.rad(16 + load * 8), math.rad(7), math.rad(22 + load * 5)),
			RightLowerArm = CFrame.Angles(math.rad(28 + load * 8), 0, math.rad(4)),
			LeftUpperLeg = CFrame.Angles(math.rad(13 + load * 4), 0, 0),
			LeftLowerLeg = CFrame.Angles(math.rad(-31 - load * 6), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(17), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(13 + load * 4), 0, 0),
			RightLowerLeg = CFrame.Angles(math.rad(-31 - load * 6), 0, 0),
			RightFoot = CFrame.Angles(math.rad(17), 0, 0),
		}
	end

	keyframe(sequence, 0, {})
	keyframe(sequence, 0.28, chargePose(0))
	keyframe(sequence, 0.82, chargePose(0.65))
	keyframe(sequence, 1.06, chargePose(1))
	-- Discharge recoil travels through the complete chassis while both feet remain planted.
	keyframe(sequence, 1.12, {
		LowerTorso = CFrame.new(0, -0.68, 0.28) * CFrame.Angles(math.rad(10), 0, 0),
		UpperTorso = CFrame.Angles(math.rad(7), 0, 0),
		Head = CFrame.Angles(math.rad(-5), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(34), math.rad(-8), math.rad(-34)),
		LeftLowerArm = CFrame.Angles(math.rad(42), 0, math.rad(-6)),
		RightUpperArm = CFrame.Angles(math.rad(34), math.rad(8), math.rad(34)),
		RightLowerArm = CFrame.Angles(math.rad(42), 0, math.rad(6)),
		LeftUpperLeg = CFrame.Angles(math.rad(19), 0, 0),
		LeftLowerLeg = CFrame.Angles(math.rad(-42), 0, 0),
		LeftFoot = CFrame.Angles(math.rad(20), 0, 0),
		RightUpperLeg = CFrame.Angles(math.rad(19), 0, 0),
		RightLowerLeg = CFrame.Angles(math.rad(-42), 0, 0),
		RightFoot = CFrame.Angles(math.rad(20), 0, 0),
	})
	keyframe(sequence, 1.32, chargePose(0.25))
	keyframe(sequence, 1.62, {})

	sequence:SetAttribute("GuardianAnimation", "WarningPulse")
	sequence:SetAttribute("DurationSeconds", 1.62)
	sequence:SetAttribute("TelegraphSeconds", 1.1)
	sequence:SetAttribute("DischargeTimeSeconds", 1.1)
	sequence:SetAttribute("SpecificationVersion", "1.0-BracedRadialDischarge")
	return sequence
end


function Library.BuildShoulderMissileSalvo()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "AegisShoulderMissileSalvo"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action3

	local function brace(recoil)
		return {
			LowerTorso = CFrame.new(0, -0.65 - recoil * 0.18, 0.2 + recoil * 0.18)
				* CFrame.Angles(math.rad(7 + recoil * 4), 0, 0),
			UpperTorso = CFrame.Angles(math.rad(4 + recoil * 7), 0, 0),
			Head = CFrame.Angles(math.rad(-5 - recoil * 2), 0, 0),
			LeftUpperArm = CFrame.Angles(math.rad(18), math.rad(-6), math.rad(-20)),
			LeftLowerArm = CFrame.Angles(math.rad(30), 0, math.rad(-5)),
			RightUpperArm = CFrame.Angles(math.rad(18), math.rad(6), math.rad(20)),
			RightLowerArm = CFrame.Angles(math.rad(30), 0, math.rad(5)),
			LeftUpperLeg = CFrame.Angles(math.rad(19 + recoil * 3), 0, math.rad(-2)),
			LeftLowerLeg = CFrame.Angles(math.rad(-43 - recoil * 4), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(21), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(19 + recoil * 3), 0, math.rad(2)),
			RightLowerLeg = CFrame.Angles(math.rad(-43 - recoil * 4), 0, 0),
			RightFoot = CFrame.Angles(math.rad(21), 0, 0),
		}
	end

	keyframe(sequence, 0, {})
	keyframe(sequence, 0.45, brace(0.2))
	keyframe(sequence, 0.82, brace(0))
	-- Hold the stabilized firing position throughout the target lock.
	keyframe(sequence, 1.75, brace(0))
	keyframe(sequence, 1.98, brace(0.25))
	-- Alternating chassis impulses make the eight launches readable as a salvo.
	keyframe(sequence, 2.05, brace(1))
	keyframe(sequence, 2.14, brace(0.25))
	keyframe(sequence, 2.23, brace(0.85))
	keyframe(sequence, 2.32, brace(0.2))
	keyframe(sequence, 2.41, brace(0.7))
	keyframe(sequence, 2.55, brace(0.1))
	keyframe(sequence, 2.78, brace(0))
	keyframe(sequence, 3.15, {})

	sequence:SetAttribute("GuardianAnimation", "ShoulderMissileSalvo")
	sequence:SetAttribute("DurationSeconds", 3.15)
	sequence:SetAttribute("LockDurationSeconds", 2.0)
	sequence:SetAttribute("FirstLaunchTimeSeconds", 2.0)
	sequence:SetAttribute("SpecificationVersion", "1.0-BraceLockSalvo")
	return sequence
end


function Library.BuildTwinIonCannons()
	local sequence = Instance.new("KeyframeSequence")
	sequence.Name = "AegisTwinIonCannons"
	sequence.Loop = false
	sequence.Priority = Enum.AnimationPriority.Action3

	local function aim(recoil, sideImpulse)
		return {
			LowerTorso = CFrame.new(sideImpulse * 0.08, -0.42 - recoil * 0.18, recoil * 0.16)
				* CFrame.Angles(math.rad(4 + recoil * 4), math.rad(sideImpulse * 2), 0),
			UpperTorso = CFrame.Angles(math.rad(-5 + recoil * 10), math.rad(sideImpulse * 3), 0),
			Head = CFrame.Angles(math.rad(-3 + recoil * 3), math.rad(-sideImpulse * 2), 0),
			LeftUpperArm = CFrame.Angles(math.rad(78 - recoil * 18), math.rad(-3), math.rad(-7)),
			LeftLowerArm = CFrame.Angles(math.rad(-17 + recoil * 11), 0, math.rad(-2)),
			RightUpperArm = CFrame.Angles(math.rad(78 - recoil * 18), math.rad(3), math.rad(7)),
			RightLowerArm = CFrame.Angles(math.rad(-17 + recoil * 11), 0, math.rad(2)),
			LeftUpperLeg = CFrame.Angles(math.rad(15 + recoil * 3), 0, 0),
			LeftLowerLeg = CFrame.Angles(math.rad(-35 - recoil * 4), 0, 0),
			LeftFoot = CFrame.Angles(math.rad(18), 0, 0),
			RightUpperLeg = CFrame.Angles(math.rad(15 + recoil * 3), 0, 0),
			RightLowerLeg = CFrame.Angles(math.rad(-35 - recoil * 4), 0, 0),
			RightFoot = CFrame.Angles(math.rad(18), 0, 0),
		}
	end

	keyframe(sequence, 0, {})
	keyframe(sequence, 0.18, {
		LowerTorso = CFrame.new(0, -0.16, 0) * CFrame.Angles(math.rad(2), 0, 0),
		LeftUpperArm = CFrame.Angles(math.rad(34), math.rad(-2), math.rad(-4)),
		RightUpperArm = CFrame.Angles(math.rad(34), math.rad(2), math.rad(4)),
	})
	keyframe(sequence, 0.48, aim(0, 0))
	keyframe(sequence, 0.55, aim(0, 0))
	-- Left and right cannon discharge in rapid sequence.
	keyframe(sequence, 0.62, aim(1, -1))
	keyframe(sequence, 0.74, aim(0.2, 0))
	keyframe(sequence, 0.82, aim(1, 1))
	keyframe(sequence, 0.98, aim(0.25, 0))
	keyframe(sequence, 1.18, aim(0, 0))
	keyframe(sequence, 1.52, {})

	sequence:SetAttribute("GuardianAnimation", "TwinIonCannons")
	sequence:SetAttribute("DurationSeconds", 1.52)
	sequence:SetAttribute("AimCompleteTimeSeconds", 0.48)
	sequence:SetAttribute("FirstDischargeTimeSeconds", 0.55)
	sequence:SetAttribute("SecondDischargeTimeSeconds", 0.75)
	sequence:SetAttribute("SpecificationVersion", "1.0-DualArmAimRecoil")
	return sequence
end

return Library
