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

return Library
