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
				item.CFrame = CFrame.Angles(math.rad(options.ForwardLean or 0), 0, 0)
					* CFrame.identity:Lerp(item.CFrame, options.TorsoScale or 1)
			elseif item.Name == "LowerTorso" and options.BodySink then
				item.CFrame = CFrame.new(0, -options.BodySink, 0) * item.CFrame
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
		HeadScale = 0.58, TorsoScale = 0.72, ForwardLean = 1,
	})
end

function Library.BuildAlertIdle()
	return adapt("BuildAlertIdle", {
		TimeScale = 0.82, LanceArmScale = 0.48, FreeArmScale = 0.72,
		HeadScale = 0.72, TorsoScale = 1.05, ForwardLean = 2, BodySink = 0.08,
	})
end

function Library.BuildWalk()
	return adapt("BuildWalk", {
		TimeScale = 0.82, LanceArmScale = 0.3, FreeArmScale = 0.68,
		LegScale = 1.05, HeadScale = 0.62, TorsoScale = 1.02,
		ForwardLean = 2, BodySink = 0.06,
	})
end

function Library.BuildRun()
	return adapt("BuildRun", {
		TimeScale = 0.8, LanceArmScale = 0.34, FreeArmScale = 0.76,
		LegScale = 1.08, HeadScale = 0.58, TorsoScale = 1.05,
		ForwardLean = 3, BodySink = 0.1,
	})
end

function Library.BuildWalkBackward()
	return adapt("BuildWalkBackward", {
		TimeScale = 0.85, LanceArmScale = 0.34, FreeArmScale = 0.66,
		LegScale = 1.02, HeadScale = 0.64, TorsoScale = 0.96,
		ForwardLean = 1, BodySink = 0.08,
	})
end

function Library.BuildTurnLeft()
	return adapt("BuildTurnLeft", {
		TimeScale = 0.78, LanceArmScale = 0.38, FreeArmScale = 0.76,
		LegScale = 1.06, HeadScale = 0.78, TorsoScale = 1.12,
		ForwardLean = 2, BodySink = 0.06,
	})
end

function Library.BuildTurnRight()
	return adapt("BuildTurnRight", {
		TimeScale = 0.78, LanceArmScale = 0.38, FreeArmScale = 0.76,
		LegScale = 1.06, HeadScale = 0.78, TorsoScale = 1.12,
		ForwardLean = 2, BodySink = 0.06,
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
		ForwardLean = 3, BodySink = 0.12,
	})
end

return Library
