-- Phase 6: articulated Stage 1 with a restless, powerful idle preview.
-- The anchored root is intentional; locomotion/gameplay are a later integration.
local RunService = game:GetService("RunService")
local Rig = {}

function Rig.Attach(model)
	assert(model:GetAttribute("EvolutionStage") == 1, "Stage 1 rig only")
	assert(not model:FindFirstChild("Articulation"), "Rig already attached")
	local function get(name)
		local p = model:FindFirstChild(name)
		assert(p and p:IsA("BasePart"), "Missing rig source: " .. name)
		return p
	end
	local visuals = {}
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") then table.insert(visuals, p) end
	end
	local basis = get("PelvisCenter").CFrame.Rotation
	local folder = Instance.new("Folder")
	folder.Name = "Articulation"
	folder.Parent = model
	local bones, motors, rest = {}, {}, {}
	local function bone(name, position, parentName)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = Vector3.new(0.2, 0.2, 0.2)
		p.CFrame = CFrame.new(position) * basis
		p.Transparency = 1
		p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
		p.CastShadow = false
		p.Massless = true
		p.Anchored = parentName == nil
		p.Parent = folder
		bones[name] = p
		if parentName then
			local m = Instance.new("Motor6D")
			m.Name = name .. "Joint"
			m.Part0, m.Part1 = bones[parentName], p
			m.C0 = m.Part0.CFrame:ToObjectSpace(p.CFrame)
			m.C1 = CFrame.identity
			m.Parent = m.Part0
			motors[name], rest[name] = m, m.C0
		end
	end
	bone("Pelvis", get("PelvisCenter").Position)
	bone("Torso", get("LowerAbdomen").Position, "Pelvis")
	bone("Head", get("Neck").Position, "Torso")
	bone("Jaw", get("LowerJawRear").Position, "Head")
	for _, side in ipairs({"Left", "Right"}) do
		bone(side .. "UpperArm", get(side .. "ShoulderJoint").Position, "Torso")
		bone(side .. "Forearm", get(side .. "ElbowJoint").Position, side .. "UpperArm")
		bone(side .. "Hand", get(side .. "WristJoint").Position, side .. "Forearm")
		bone(side .. "Thigh", get(side .. "HipJoint").Position, "Pelvis")
		bone(side .. "Shin", get(side .. "KneeJoint").Position, side .. "Thigh")
		bone(side .. "Hock", get(side .. "HockJoint").Position, side .. "Shin")
		bone(side .. "Foot", get(side .. "AnkleJoint").Position, side .. "Hock")
	end
	local tailCount = 0
	while model:FindFirstChild(string.format("TailSegment_%02d", tailCount + 1)) do
		tailCount = tailCount + 1
	end
	assert(tailCount >= 7, "Incomplete tail")
	for i = 1, tailCount do
		local segment = get(string.format("TailSegment_%02d", i))
		bone("Tail" .. i, segment.Position - segment.CFrame.RightVector * segment.Size.X/2,
			i == 1 and "Pelvis" or "Tail" .. (i-1))
	end
	local headNames = {Cranium=true, SnoutBridge=true, FrontalBridge=true}
	local headFeatures = {CheekMass=true, OrbitalSupport=true, BrowRidge=true, EyeSocket=true,
		Eye=true, Pupil=true, EyeHighlight=true, Nostril=true}
	local armUpper = {ShoulderJoint=true, Deltoid=true, UpperArm=true, BicepsMass=true}
	local armLower = {ElbowJoint=true, Forearm=true, ForearmMass=true, ForearmFlexor=true, ForearmTaper=true}
	local thighs = {HipJoint=true, ThighMass=true, OuterQuadriceps=true, UpperLeg=true}
	local shins = {KneeJoint=true, CalfMass=true, LowerLeg=true}
	local pelvisNames = {PelvisCenter=true, SacralMass=true, TailRootMass=true}
	local function starts(name, prefix) return string.sub(name, 1, #prefix) == prefix end
	local function region(name)
		if name == "TailTip" then return "Tail" .. tailCount end
		if starts(name, "LowerJaw") then return "Jaw" end
		if headNames[name] or starts(name, "UpperMuzzle") then return "Head" end
		local tail = string.match(name, "^TailSegment_(%d+)$")
		if tail then return "Tail" .. tonumber(tail) end
		local plate = tonumber(string.match(name, "^DorsalShield_(%d+)") or string.match(name, "^DorsalEnergy_(%d+)"))
		if plate then return plate <= 3 and "Torso" or "Tail" .. (plate-2) end
		if pelvisNames[name] then return "Pelvis" end
		for _, side in ipairs({"Left", "Right"}) do
			if starts(name, side) then
				local suffix = string.sub(name, #side+1)
				if headFeatures[suffix] then return "Head" end
				if armUpper[suffix] then return side .. "UpperArm" end
				if armLower[suffix] then return side .. "Forearm" end
				if suffix == "WristJoint" or starts(suffix, "Palm") or starts(suffix, "Finger")
					or starts(suffix, "Knuckle") or starts(suffix, "Hand") or starts(suffix, "Thumb") then return side .. "Hand" end
				if thighs[suffix] then return side .. "Thigh" end
				if shins[suffix] then return side .. "Shin" end
				if suffix == "HockJoint" or suffix == "Metatarsal" then return side .. "Hock" end
				if suffix == "AnkleJoint" or suffix == "InstepFlow" or starts(suffix, "Heel") or starts(suffix, "Forefoot")
					or starts(suffix, "Toe") or starts(suffix, "FrontClaw") or suffix == "RearClaw" then return side .. "Foot" end
				if suffix == "HipMass" then return "Pelvis" end
			end
		end
		return "Torso"
	end
	for _, p in ipairs(visuals) do
		local name = region(p.Name)
		assert(bones[name], "Unknown region: " .. name)
		local weld = Instance.new("WeldConstraint")
		weld.Name = "RigWeld"
		weld.Part0, weld.Part1 = bones[name], p
		weld.Parent = p
		p:SetAttribute("RigRegion", name)
		p.Massless = true
		p.Anchored = false
	end
	model.PrimaryPart = bones.Pelvis
	model:SetAttribute("RigType", "CustomMotor6D_Stage1")
	model:SetAttribute("RigJointCount", 17 + tailCount)
	model:SetAttribute("PipelinePhase", 6)
	model:SetAttribute("QualityGateC", "Pending")
	model:SetAttribute("IdleEnabled", true)
	model:SetAttribute("AnimationPreview", "PowerIdle_02")
	local elapsed, accumulator, stopped = 0, 0, false
	local heartbeat, destroying
	local function reset()
		for name, m in pairs(motors) do m.C0 = rest[name] end
	end
	local function stop()
		if stopped then return end
		stopped = true
		if heartbeat then heartbeat:Disconnect() end
		if destroying then destroying:Disconnect() end
		reset()
	end
	local wasEnabled = true
	heartbeat = RunService.Heartbeat:Connect(function(dt)
		if not model:IsDescendantOf(workspace) then stop(); return end
		if model:GetAttribute("IdleEnabled") == false then
			if wasEnabled then reset() end
			wasEnabled = false
			elapsed, accumulator = 0, 0
			return
		end
		wasEnabled = true
		elapsed, accumulator = elapsed + dt, accumulator + dt
		if accumulator < 1/30 then return end
		accumulator = accumulator % (1/30)
		local fade = math.min(elapsed/1.5, 1)
		local breath = math.sin(elapsed * math.pi/1.4) * fade
		local sway = math.sin(elapsed * math.pi/2.7) * fade
		-- Smooth short accents: alternating shoulder tension and alert head turns.
		local leftAccent = math.max(0, math.sin(elapsed * 0.95))^8 * fade
		local rightAccent = math.max(0, math.sin(elapsed * 0.95 + 2.1))^8 * fade
		local alert = math.sin(elapsed * 1.7) * math.max(0, math.sin(elapsed * 0.63))^4 * fade
		local function pose(name, x, y, z)
			-- C0 is used for this server preview so clients see the same pose.
			motors[name].C0 = rest[name] * CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
		end
		pose("Torso", 1.2 * fade + breath * 1.8, sway * 1.8, sway * 1.0)
		pose("Head", -breath * 1.1, -sway * 2.3 + alert * 4.5, -sway * 0.6)
		pose("Jaw", math.max(0, breath) * 1.8, 0, 0)
		for _, side in ipairs({"Left", "Right"}) do
			local sign = side == "Left" and -1 or 1
			local accent = side == "Left" and leftAccent or rightAccent
			pose(side .. "UpperArm", breath * 1.2 - accent * 2.5, sign * accent * 1.5, -sign * (breath * 1.2 + accent * 2.0))
			pose(side .. "Forearm", -3.0 * fade - breath * 1.8 - accent * 4.0, 0, 0)
			pose(side .. "Hand", -accent * 2.0, sign * accent * 1.5, 0)
		end
		for i = 1, tailCount do
			pose("Tail" .. i, 0, (math.sin(elapsed * 1.35 - i * 0.48) * (0.55 + i*0.14)
				+ alert * 0.45) * fade, 0)
		end
	end)
	destroying = model.Destroying:Connect(stop)
	print(string.format("[Kaiju Rig] %d visible parts bound | %d joints | Power idle running | Set IdleEnabled=false to pause", #visuals, 17 + tailCount))
	return {Stop = stop, Motors = motors}
end

return Rig
