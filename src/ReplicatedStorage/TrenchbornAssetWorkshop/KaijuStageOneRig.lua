-- Phase 6: articulated Stage 1 with a restless, powerful idle preview.
-- A movement root drives gameplay; without one this remains an anchored preview.
local RunService = game:GetService("RunService")
local Rig = {}
local STRIDE = 7.0
local STANCE = 0.70 -- Both feet support the body during 40% of the cycle.
local CYCLE_SECONDS = 1.9

function Rig.Attach(model, movementRoot, humanoid)
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
	model:SetAttribute("AnimationMode", "Walk")
	model:SetAttribute("WalkCycleSeconds", CYCLE_SECONDS)
	model:SetAttribute("AnimationPreview", "WalkInPlace_01")
	local rootRest = bones.Pelvis.CFrame
	local rootJoint, rootOffset
	if movementRoot then
		rootOffset = movementRoot.CFrame:ToObjectSpace(rootRest)
		rootJoint = Instance.new("Motor6D")
		rootJoint.Name = "KaijuLocomotionRoot"
		rootJoint.Part0, rootJoint.Part1 = movementRoot, bones.Pelvis
		rootJoint.C0 = rootOffset
		rootJoint.Parent = folder
		bones.Pelvis.Anchored = false
		model:SetAttribute("AnimationMode", "Automatic")
	end
	local scale = model:GetScale()
	local legs = {}
	for _, side in ipairs({"Left", "Right"}) do
		local hip = rootRest:PointToObjectSpace(bones[side .. "Thigh"].Position)
		local knee = rootRest:PointToObjectSpace(bones[side .. "Shin"].Position)
		local hock = rootRest:PointToObjectSpace(bones[side .. "Hock"].Position)
		local a, b = knee - hip, hock - knee
		legs[side] = {offset = hock - hip, upper = math.sqrt(a.Y*a.Y + a.Z*a.Z),
			lower = math.sqrt(b.Y*b.Y + b.Z*b.Z), upperAngle = math.atan2(-a.Z, -a.Y),
			lowerAngle = math.atan2(-b.Z, -b.Y)}
	end
	local function solveLeg(side, forwardOffset, lift, bob)
		local leg = legs[side]
		local y, z = leg.offset.Y + lift - bob, leg.offset.Z + forwardOffset
		local distance = math.sqrt(y*y + z*z)
		distance = math.clamp(distance, math.abs(leg.upper-leg.lower)+0.001, leg.upper+leg.lower-0.001)
		local angle = math.atan2(-z, -y)
		local spread = math.acos(math.clamp((leg.upper^2 + distance^2 - leg.lower^2)/(2*leg.upper*distance), -1, 1))
		local upper = angle + spread
		local kneeY, kneeZ = -leg.upper*math.cos(upper), -leg.upper*math.sin(upper)
		local lower = math.atan2(-(z-kneeZ), -(y-kneeY))
		local upperDelta, lowerDelta = upper-leg.upperAngle, lower-leg.lowerAngle
		motors[side .. "Thigh"].C0 = rest[side .. "Thigh"] * CFrame.Angles(upperDelta, 0, 0)
		motors[side .. "Shin"].C0 = rest[side .. "Shin"] * CFrame.Angles(lowerDelta-upperDelta, 0, 0)
		-- Counter-rotate the hock to keep the heavy foot level throughout the step.
		motors[side .. "Hock"].C0 = rest[side .. "Hock"] * CFrame.Angles(-lowerDelta, 0, 0)
		motors[side .. "Foot"].C0 = rest[side .. "Foot"]
	end
	local elapsed, accumulator, stopped = 0, 0, false
	local walkCycle, smoothedBob = 0, 0
	local heartbeat, destroying
	local function reset()
		for name, m in pairs(motors) do m.C0 = rest[name] end
		if rootJoint then rootJoint.C0 = rootOffset else bones.Pelvis.CFrame = rootRest end
		smoothedBob, walkCycle = 0, 0
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
		local poseDt = accumulator
		accumulator = accumulator % (1/30)
		local previous = {}
		for name, m in pairs(motors) do previous[name] = m.C0 end
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
		local walking = model:GetAttribute("AnimationMode") == "Walk"
		local speed = 0
		if movementRoot then
			local velocity = movementRoot.AssemblyLinearVelocity
			speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
			walking = speed > 0.5 and humanoid.Health > 0
				and humanoid.FloorMaterial ~= Enum.Material.Air
		end
		local duration = model:GetAttribute("WalkCycleSeconds")
		if type(duration) ~= "number" or duration ~= duration then duration = CYCLE_SECONDS end
		duration = math.clamp(duration, 1.5, 3.0)
		if walking then
			-- Match the stance distance to actual travel, including slow starts.
			local rate = movementRoot and math.min(speed, 20)/((STRIDE/STANCE)*scale) or 1/duration
			walkCycle = walkCycle + poseDt*rate
		end
		local cycle = walkCycle
		local phase = cycle * math.pi * 2
		local gaitPhase = (cycle + STANCE/2) * math.pi * 2
		-- A short, smooth compression after each landing, followed by recovery.
		-- Keep the stance foot on the floor through the leg solver below.
		local sinceLanding = ((cycle + STANCE/2)*2)%1
		local compression = math.sin(math.pi*math.min(sinceLanding/0.32, 1))^2
		local bob = walking and -(0.12 + 0.38*compression)*scale*fade or 0
		local blend = 1-math.exp(-poseDt/0.10)
		smoothedBob = smoothedBob + (bob-smoothedBob)*blend
		if rootJoint then
			rootJoint.C0 = rootOffset * CFrame.new(0, smoothedBob, 0)
		else
			bones.Pelvis.CFrame = rootRest * CFrame.new(0, smoothedBob, 0)
		end
		local actualBob = smoothedBob
		if walking then
			model:SetAttribute("AnimationPreview", "HeavyWalk_02")
			local weightShift = math.sin(gaitPhase - 0.35)*fade
			pose("Torso", (3.8 + compression*1.2)*fade, weightShift*2.5, weightShift*3.2)
			pose("Head", (-2.4 - compression*0.5)*fade, -weightShift*1.8, -weightShift*1.4)
			pose("Jaw", 0, 0, 0)
			for _, side in ipairs({"Left", "Right"}) do
				local offset = side == "Left" and 0 or 0.5
				local t = (cycle+offset+STANCE/2)%1
				local travel, lift
				if t < STANCE then
					-- The planted foot moves back at the body's actual travel speed.
					travel, lift = -STRIDE/2 + STRIDE*t/STANCE, 0
				else
					local swing = (t-STANCE)/(1-STANCE)
					local smooth = swing*swing*(3-2*swing)
					travel = STRIDE/2-STRIDE*smooth
					lift = 0.85*math.sin(math.pi*swing)^2
				end
				solveLeg(side, travel*scale*fade, lift*scale*fade, actualBob)
				local swing = math.sin((cycle+offset+STANCE/2)*math.pi*2-0.25)*fade
				pose(side .. "UpperArm", -swing*7, 0, 0)
				pose(side .. "Forearm", -5*fade + swing*2, 0, 0)
				pose(side .. "Hand", -swing, 0, 0)
			end
			for i = 1, tailCount do
				pose("Tail" .. i, 0, -math.sin(phase-i*0.32)*(0.5+i*0.10)*fade, 0)
			end
		else
			model:SetAttribute("AnimationPreview", "PowerIdle_02")
			for _, side in ipairs({"Left", "Right"}) do solveLeg(side, 0, 0, actualBob) end
		end
		-- Blend mode changes and step accents rather than snapping joint poses.
		for name, m in pairs(motors) do m.C0 = previous[name]:Lerp(m.C0, blend) end
	end)
	destroying = model.Destroying:Connect(stop)
	print(string.format("[Kaiju Rig] %d parts | %d joints | Walk preview | AnimationMode: Walk / Idle | IdleEnabled=false pauses both", #visuals, 17 + tailCount))
	return {Stop = stop, Motors = motors}
end

return Rig
