-- Phase 6: articulated Stage 1 with a restless, powerful idle preview.
-- A movement root drives gameplay; without one this remains an anchored preview.
local RunService = game:GetService("RunService")
local Combo = require(script.Parent:WaitForChild("KaijuStageOneCombo"))
local Jump = require(script.Parent:WaitForChild("KaijuStageOneJump"))
local Rig = {}
local STRIDE = 10.0
local STANCE = 0.70 -- Both feet support the body during 40% of the cycle.
local CYCLE_SECONDS = 1.9

function Rig.Attach(model, movementRoot, humanoid, combat)
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
	model:SetAttribute("FocusRigRevision", "MouthDiagnostic_01")
	model:SetAttribute("RigJointCount", 17 + tailCount)
	model:SetAttribute("PipelinePhase", 6)
	model:SetAttribute("QualityGateC", "Pending")
	model:SetAttribute("AttackReach", "LowBuildings")
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
		-- During the first frames of a long step the pelvis is still lowering.
		-- Limit horizontal reach until it settles, keeping the foot on the floor
		-- and a small bend in the knee instead of stretching the leg straight.
		local reach = leg.upper + leg.lower - 0.12*scale
		local horizontalReach = math.sqrt(math.max(0, reach*reach-y*y))
		z = math.clamp(z, -horizontalReach, horizontalReach)
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
	local combo = Combo.new(combat and combat.PrepareFinisher)
	local jump = Jump.new()
	local focus,focusReadyAt=nil,0
	local focusColor=Color3.fromRGB(65,225,255)
	local function endFocus()
		if not focus then return end
		for part,color in pairs(focus.Colors) do if part.Parent then part.Color=color end end
		focus.Mouth:Destroy()
		focus.Effects:Destroy()
		humanoid.WalkSpeed=focus.Speed
		humanoid.AutoRotate=focus.Rotate
		focus=nil
		focusReadyAt=os.clock()+1
		model:SetAttribute("FocusPhase","Idle")
	end
	local upperLip=get("UpperMuzzleCoreY")
	local lowerLip=get("LowerJawFrontCoreY")
	local lowerLipLocal=bones.Jaw.CFrame:PointToObjectSpace(lowerLip.CFrame:PointToWorldSpace(
		Vector3.new(0,lowerLip.Size.Y/2,-get("LowerJawFrontCoreZ").Size.Z/2+0.2*scale)))
	local palateOffset=CFrame.new(0,-upperLip.Size.Y/2-0.2*scale,get("UpperMuzzleCoreZ").Size.Z*0.25)
	local function mouthFrame()
		-- Charge grows from the rear palate, fixed to the underside of the upper jaw.
		return upperLip,palateOffset
	end
	local function mouthPosition()
		local upper,offset=mouthFrame()
		return (upper.CFrame*offset).Position
	end
	local function requestFocus()
		if stopped or focus or not combat or not combat.SelectFocusTarget or not humanoid
			or humanoid.Health<=0 or not movementRoot or jump.Phase~="Idle"
			or humanoid.FloorMaterial==Enum.Material.Air or os.clock()<focusReadyAt
			or model:GetAttribute("IdleEnabled")==false or (model:GetAttribute("ComboStep") or 0)~=0 then return false end
		local target=combat.SelectFocusTarget(mouthPosition())
		if not target then model:SetAttribute("FocusPhase","No target");return false end
		combo:Cancel();combat.Cancel()
		local effects=Instance.new("Folder")
		effects.Name="FocusEffects";effects.Parent=model
		local function effect(name,shape,color)
			local p=Instance.new("Part")
			p.Name=name;p.Shape=shape;p.Color=color;p.Material=Enum.Material.Neon
			p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.CastShadow=false
			p.Transparency=1;p.Size=Vector3.new(0.1,0.1,0.1);p.Parent=effects
			return p
		end
		focus={Started=os.clock(),Ticks=0,Target=target,Speed=humanoid.WalkSpeed,Rotate=humanoid.AutoRotate,
			Effects=effects,Colors={},Orb=effect("Charge",Enum.PartType.Ball,focusColor),
			Impact=effect("Impact",Enum.PartType.Ball,focusColor)}
		local upper,offset=mouthFrame()
		local mouth=Instance.new("Attachment")
		mouth.Name="FocusMouth";mouth.CFrame=offset;mouth.Parent=upper
		focus.Mouth=mouth
		focus.Orb.CFrame=upper.CFrame*offset
		focus.Orb.Anchored=false;focus.Orb.Massless=true
		local weld=Instance.new("Weld")
		weld.Name="MouthChargeWeld";weld.Part0=upper;weld.Part1=focus.Orb
		weld.C0=offset;weld.C1=CFrame.identity;weld.Parent=focus.Orb
		focus.OrbWeld=weld
		local endpoint=Instance.new("Attachment")
		endpoint.Parent=focus.Impact
		local function beam(name,color)
			local b=Instance.new("Beam")
			b.Name=name;b.Attachment0=mouth;b.Attachment1=endpoint
			b.FaceCamera=true;b.LightEmission=1;b.LightInfluence=0
			b.Color=ColorSequence.new(color);b.Enabled=false;b.Parent=effects
			return b
		end
		focus.Beam=beam("Beam",focusColor)
		focus.Core=beam("Core",Color3.fromRGB(220,255,255))
		for _,p in ipairs(visuals) do
			if string.match(p.Name,"^DorsalEnergy_") then focus.Colors[p]=p.Color end
		end
		humanoid.WalkSpeed=0;humanoid.AutoRotate=false;humanoid:Move(Vector3.zero,false)
		model:SetAttribute("FocusPhase","Charging")
		return true
	end
	local savedSpeed, savedOwner, savedAutoRotate, airDirection
	local AIR_SPEED=18 -- Moderate air travel, below the original speed of 30.
	local JUMP_HEIGHT=14
	local ownsPhysics=false
	local function restoreJump()
		if humanoid and savedSpeed then humanoid.WalkSpeed=savedSpeed end
		savedSpeed=nil
		if humanoid and savedAutoRotate~=nil then humanoid.AutoRotate=savedAutoRotate end
		savedAutoRotate=nil
		if ownsPhysics and movementRoot and movementRoot:IsDescendantOf(workspace) then
			if savedOwner and savedOwner.Parent then movementRoot:SetNetworkOwner(savedOwner)
			else movementRoot:SetNetworkOwnershipAuto() end
		end
		ownsPhysics=false
	end
	local function setAirDirection(direction)
		if jump.Phase~="Air" and jump.Phase~="Windup" then return end
		local flat=Vector3.new(direction.X,0,direction.Z)
		airDirection=flat.Magnitude>0.05 and flat.Unit or Vector3.zero
	end
	local function requestJump(direction)
		if stopped or focus or not humanoid or humanoid.Health<=0 or not movementRoot
			or model:GetAttribute("IdleEnabled")==false then return false end
		if not jump:Request(os.clock(),humanoid.FloorMaterial~=Enum.Material.Air) then return false end
		combo:Cancel()
		if combat then combat.Cancel() end
		savedSpeed=humanoid.WalkSpeed
		airDirection=Vector3.zero
		if direction then setAirDirection(direction) end
		humanoid.WalkSpeed=0
		return true
	end
	local function requestAttack()
		if stopped or focus or jump.Phase~="Idle" or not humanoid or humanoid.Health <= 0
			or humanoid.FloorMaterial == Enum.Material.Air
			or model:GetAttribute("IdleEnabled") == false then return false end
		return combo:Request(os.clock())
	end
	local function reset()
		endFocus()
		jump:Cancel()
		restoreJump()
		combo:Cancel()
		if combat then combat.Cancel() end
		model:SetAttribute("ComboStep", 0)
		model:SetAttribute("AttackName", "")
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
		if focus and (humanoid.Health<=0 or humanoid.FloorMaterial==Enum.Material.Air
			or os.clock()-focus.Started>=4.85) then endFocus() end
		local focusTime=focus and os.clock()-focus.Started
		if humanoid and humanoid.Health<=0 then jump:Cancel();restoreJump() end
		local jumpPose,jumpEvent
		if movementRoot and humanoid then
			jumpPose,jumpEvent=jump:Update(os.clock(),humanoid.FloorMaterial~=Enum.Material.Air,movementRoot.AssemblyLinearVelocity.Y)
			if jumpEvent=="Takeoff" then
				-- Direction comes only from movement input; neutral jumps are vertical.
				-- Steering changes travel, while the body keeps its takeoff heading.
				savedAutoRotate=humanoid.AutoRotate
				humanoid.AutoRotate=false
				savedOwner=movementRoot:GetNetworkOwner()
				movementRoot:SetNetworkOwner(nil)
				ownsPhysics=true
				humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
				local velocity=movementRoot.AssemblyLinearVelocity
				local rise=math.sqrt(2*workspace.Gravity*JUMP_HEIGHT*scale)
				local horizontal=airDirection*AIR_SPEED
				movementRoot:ApplyImpulse((horizontal+Vector3.new(0,rise,0)-velocity)*movementRoot.AssemblyMass)
			elseif jumpEvent=="Land" then
				if combat then combat.Handle("Land",0) end
			elseif jumpEvent=="Restore" then restoreJump() end
			if jump.Phase=="Air" then
				-- Let the humanoid steer; a zero-speed Move command fights air travel.
				humanoid.WalkSpeed=AIR_SPEED
				humanoid:Move(airDirection,false)
				if airDirection.Magnitude==0 then
					-- Neutral input brakes only horizontal drift, preserving the fall.
					local velocity=movementRoot.AssemblyLinearVelocity
					movementRoot:ApplyImpulse(Vector3.new(-velocity.X,0,-velocity.Z)*movementRoot.AssemblyMass)
				end
			elseif jump.Phase=="Landing" then
				humanoid.WalkSpeed=0
				humanoid:Move(Vector3.zero,false)
				-- Absorb contact rebound and sliding, but allow falling if the roof breaks.
				if humanoid.FloorMaterial~=Enum.Material.Air then
					local velocity=movementRoot.AssemblyLinearVelocity
					movementRoot:ApplyImpulse(Vector3.new(-velocity.X,-math.max(0,velocity.Y),-velocity.Z)*movementRoot.AssemblyMass)
				end
			end
		end
		model:SetAttribute("JumpPhase",jump.Phase)
		local speed = 0
		if movementRoot then
			local velocity = movementRoot.AssemblyLinearVelocity
			speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
			walking = speed > 0.5 and humanoid.Health > 0
				and humanoid.FloorMaterial ~= Enum.Material.Air
		end
		if jumpPose then walking=false end
		if focus then walking=false;humanoid:Move(Vector3.zero,false) end
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
		if humanoid and humanoid.Health <= 0 then
			combo:Cancel()
			if combat then combat.Cancel() end
		end
		local attackPose, attackWeight, attackName, attackIndex, attackCrouch = combo:Sample(os.clock())
		for _, event in ipairs(combo:DrainEvents()) do
			if combat then combat.Handle(event.Kind, event.Index, event.FinisherUntil) end
		end
		local bob = walking and -(1.05 + 0.38*compression)*scale*fade or 0
		-- Lower the pelvis as well as the torso; IK bends the legs while the
		-- planted feet retain their floor height. Recovery uses the same smoothing.
		bob = bob - (attackCrouch or 0)*scale
		if jumpPose then bob=-jumpPose.Crouch*scale end
		if focus then bob=-0.35*scale*math.min(focusTime/0.4,1)*math.clamp((4.85-focusTime)/0.35,0,1) end
		local blend = 1-math.exp(-poseDt/0.10)
		smoothedBob = smoothedBob + (bob-smoothedBob)*blend
		if rootJoint then
			rootJoint.C0 = rootOffset * CFrame.new(0, smoothedBob, 0)
		else
			bones.Pelvis.CFrame = rootRest * CFrame.new(0, smoothedBob, 0)
		end
		local actualBob = smoothedBob
		if walking then
			model:SetAttribute("AnimationPreview", "HeavyWalk_03_ForwardLean")
			local weightShift = math.sin(gaitPhase - 0.35)*fade
			-- Forward is local -Z: negative X pitch brings the upper body forward.
			pose("Torso", (-11.0 - compression*1.6)*fade, weightShift*2.5, weightShift*3.2)
			-- The neck partly counters the lean to keep the gaze ahead. Head motion
			-- follows the weight transfer with a delay instead of locking to the torso.
			local headFollow = math.sin(gaitPhase - 0.80)*fade
			local headNod = math.sin(gaitPhase*2 - 0.65)*2.2*fade
			pose("Head", 6.0*fade + headNod - compression*0.8*fade,
				-headFollow*3.5, -headFollow*1.8)
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
					-- Clear the ground visibly while the other foot bears the weight.
					lift = 2.2*math.sin(math.pi*swing)^2
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
		model:SetAttribute("ComboStep", attackIndex or 0)
		model:SetAttribute("AttackName", attackName or "")
		if attackPose then
			for name, angles in pairs(attackPose) do
				local target = rest[name] * CFrame.Angles(math.rad(angles[1]),math.rad(angles[2]),math.rad(angles[3]))
				motors[name].C0 = motors[name].C0:Lerp(target, attackWeight)
			end
		end
		if jumpPose then
			local asymmetry=jumpPose.Asymmetry or 0
			local leadSign=jump.Lead=="Left" and -1 or 1
			pose("Torso",jumpPose.Pitch,leadSign*3*asymmetry,leadSign*4*asymmetry)
			pose("Head",jumpPose.Head,0,0)
			pose("Jaw",0,0,0)
			for _,side in ipairs({"Left","Right"}) do
				local lead=side==jump.Lead
				local lift=lead and jumpPose.LeadLift or jumpPose.TrailLift
				local forward=lead and jumpPose.LeadForward or jumpPose.TrailForward
				solveLeg(side,(forward or 0)*scale,(lift or jumpPose.Tuck)*scale,actualBob)
				-- The arm opposite the raised knee swings forward for balance.
				pose(side.."UpperArm",jumpPose.Arm+(lead and -32 or 32)*asymmetry,0,0)
				pose(side.."Forearm",jumpPose.Elbow+(lead and 0 or 14)*asymmetry,0,0)
				pose(side.."Hand",-jumpPose.Pulse*8,0,0)
			end
			for i=1,tailCount do
				pose("Tail"..i,math.sin(elapsed*8-i*0.45)*jumpPose.Pulse*1.5,0,0)
			end
		end
		if focus then
			local t=focusTime
			local charge=math.clamp(t/2,0,1)
			local firing=t>=2 and t<4.5
			local fadeOut=math.clamp((4.85-t)/0.35,0,1)
			local from=mouthPosition()
			local point,visible=combat.FocusAim(focus.Target,from)
			if point then focus.Point=point end
			point=point or focus.Point or from+movementRoot.CFrame.LookVector*30
			local delta=point-from
			local horizontal=math.sqrt(delta.X*delta.X+delta.Z*delta.Z)
			local aimPitch=math.deg(math.atan2(delta.Y,math.max(horizontal,0.01)))
			-- Aim the beam at low targets without folding the jaw into the chest.
			local pitch=math.clamp(aimPitch,-24,15)
			local lowAim=math.clamp((-pitch-8)/16,0,1)
			lowAim=lowAim*lowAim*(3-2*lowAim)
			local localAim=movementRoot.CFrame:VectorToObjectSpace(delta)
			local yaw=math.clamp(math.deg(math.atan2(-localAim.X,-localAim.Z)),-45,45)
			local recoil=firing and math.sin(t*35)*1.2 or 0
			pose("Torso",(-8+recoil)*charge*fadeOut,0,0)
			local reach=lowAim*charge*fadeOut
			motors.Head.C0=rest.Head*CFrame.new(0,0.5*scale*reach,-1.2*scale*reach)
				*CFrame.Angles(math.rad((pitch+8-recoil)*charge*fadeOut),math.rad(yaw*charge*fadeOut),0)
			-- Forward is -Z: negative X lowers the jaw. Open before the beam starts.
			local opening=math.clamp((t-1.5)/0.3,0,1)
			pose("Jaw",-(36-10*lowAim)*opening*fadeOut,0,0)
			for _,side in ipairs({"Left","Right"}) do
				local sign=side=="Left" and -1 or 1
				pose(side.."UpperArm",12*charge*fadeOut,0,-sign*12*charge*fadeOut)
				pose(side.."Forearm",-24*charge*fadeOut,0,0)
			end
			for p,color in pairs(focus.Colors) do
				local index=tonumber(string.match(p.Name,"^DorsalEnergy_(%d+)")) or 1
				local onset=math.clamp((tailCount-index)/(tailCount-1),0,1)*1.5
				p.Color=color:Lerp(focusColor,math.clamp((t-onset)/0.3,0,1)*fadeOut)
			end
			local orbSize=(0.15+charge*0.7)*scale*fadeOut
			focus.Orb.Size=Vector3.new(orbSize,orbSize,orbSize)
			focus.Orb.Transparency=0.15
			for _,beam in ipairs({focus.Beam,focus.Core}) do
				beam.Enabled=t>=2 and delta.Magnitude>0.01
				beam.Transparency=NumberSequence.new(0.12+0.88*(1-fadeOut))
				if t>=2 and delta.Magnitude>0.01 then
					local width=math.max(0.05,(beam==focus.Core and 0.45 or 1.15)*scale*fadeOut)
					beam.Width0=width;beam.Width1=width
				end
			end
			focus.Impact.Transparency=firing and visible and 0.25 or 1
			focus.Impact.Size=Vector3.new(2,2,2)*scale*(1+0.12*math.sin(t*40))
			focus.Impact.CFrame=CFrame.new(point)
			-- Ten scheduled ticks; do not turn a delayed frame into an extra hit.
			local due=math.clamp(math.floor((t-2)/0.25),0,10)
			while focus.Ticks<due do
				focus.Ticks=focus.Ticks+1
				combat.Handle("Focus",0,focus.Target,from)
			end
			model:SetAttribute("FocusPhase",t<2 and "Charging" or t<4.5 and "Firing" or "Recovery")
		end
		-- Blend mode changes and step accents rather than snapping joint poses.
		for name, m in pairs(motors) do m.C0 = previous[name]:Lerp(m.C0, blend) end
		if focus then
			-- Beam and charge share the same fixed palate attachment.
			local _,offset=mouthFrame()
			focus.Mouth.CFrame=offset
			focus.OrbWeld.C0=offset
			if focusTime>=2.3 and not focus.Diagnosed then
				focus.Diagnosed=true
				local intended=rest.Jaw:ToObjectSpace(motors.Jaw.C0)
				local actual=rest.Jaw:ToObjectSpace(bones.Head.CFrame:ToObjectSpace(bones.Jaw.CFrame))
				local requestedX=intended:ToOrientation()
				local actualX=actual:ToOrientation()
				local upperPoint=upperLip.CFrame:PointToWorldSpace(Vector3.new(0,-upperLip.Size.Y/2,
					-get("UpperMuzzleCoreZ").Size.Z/2+0.2*scale))
				local lowerPoint=lowerLip.CFrame:PointToWorldSpace(Vector3.new(0,lowerLip.Size.Y/2,
					-get("LowerJawFrontCoreZ").Size.Z/2+0.2*scale))
				local expected=(upperLip.CFrame*palateOffset).Position
				local visualJawPoint=bones.Jaw.CFrame:PointToWorldSpace(lowerLipLocal)
				local jawParts,anchoredParts=0,0
				for _,p in ipairs(visuals) do
					if string.sub(p.Name,1,8)=="LowerJaw" then
						jawParts=jawParts+1
						if p.Anchored then anchoredParts=anchoredParts+1 end
					end
				end
				local report={revision="MouthDiagnostic_01",requestedJawDegrees=math.deg(requestedX),
					actualJawDegrees=math.deg(actualX),jawParts=jawParts,anchoredJawParts=anchoredParts,
					jawVisualError=(visualJawPoint-lowerPoint).Magnitude,
					mouthError=(focus.Mouth.WorldPosition-expected).Magnitude,
					orbError=(focus.Orb.Position-expected).Magnitude,
					lipGap=(upperPoint-lowerPoint).Magnitude,scale=scale}
				local json=game:GetService("HttpService"):JSONEncode(report)
				model:SetAttribute("FocusRigDiagnostic",json)
				print("[Kaiju Focus Rig] "..json)
			end
		end
	end)
	destroying = model.Destroying:Connect(stop)
	print(string.format("[Kaiju Rig] %d parts | %d joints | Walk preview | AnimationMode: Walk / Idle | IdleEnabled=false pauses both", #visuals, 17 + tailCount))
	return {Stop = stop, Motors = motors, RequestAttack = requestAttack, RequestJump = requestJump, SetAirDirection=setAirDirection,RequestFocus=requestFocus}
end

return Rig
