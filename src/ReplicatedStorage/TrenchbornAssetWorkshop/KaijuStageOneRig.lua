-- Phase 6: articulated Stage 1 with a restless, powerful idle preview.
-- A movement root drives gameplay; without one this remains an anchored preview.
local RunService = game:GetService("RunService")
local Combo = require(script.Parent:WaitForChild("KaijuStageOneCombo"))
local Jump = require(script.Parent:WaitForChild("KaijuStageOneJump"))
local Rig = {}
local STRIDE = 10.0
local STANCE = 0.65 -- Longer swing; both feet still support the body during 30% of the cycle.
local RUN_SPEED = 16
local WALK_SPEED = 10
local RUN_STRIDE, RUN_STANCE = 11, 0.48
local CYCLE_SECONDS = 1.9
local AREA_TIMING={Curl=2.2,Discharge=2.8,Recovery=3.2,Finish=4.6}

function Rig.Attach(model, movementRoot, humanoid, combat)
	assert(model:GetAttribute("EvolutionStage") == 1, "Stage 1 rig only")
	assert(not model:FindFirstChild("Articulation"), "Rig already attached")
	local function get(name)
		local p = model:FindFirstChild(name)
		assert(p and p:IsA("BasePart"), "Missing rig source: " .. name)
		return p
	end
	local visuals = {}
	local corpseGeometry={}
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
	bone("TailBase",get("SacralMass").Position,"Pelvis")
	for i = 1, tailCount do
		local segment = get(string.format("TailSegment_%02d", i))
		bone("Tail" .. i, segment.Position - segment.CFrame.RightVector * segment.Size.X/2,
			i == 1 and "TailBase" or "Tail" .. (i-1))
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
		if name == "TailRootMass" then return "TailBase" end
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
		table.insert(corpseGeometry,{Part=p,Bone=name,Local=bones[name].CFrame:ToObjectSpace(p.CFrame)})
		p.Massless = true
		p.Anchored = false
	end
	model.PrimaryPart = bones.Pelvis
	model:SetAttribute("RigType", "CustomMotor6D_Stage1")
	model:SetAttribute("FocusRigRevision", "MouthDiagnostic_01")
	model:SetAttribute("RigJointCount", 18 + tailCount)
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
	local function rotateBetween(a,b)
		local x,y=a.Unit,b.Unit
		local dot=math.clamp(x:Dot(y),-1,1)
		local axis=x:Cross(y)
		if axis.Magnitude<0.0001 then
			if dot>0 then return CFrame.identity end
			axis=x:Cross(math.abs(x.Y)<0.9 and Vector3.yAxis or Vector3.xAxis)
		end
		return CFrame.fromAxisAngle(axis.Unit,math.acos(dot))
	end
	local pelvisTurn=CFrame.identity
	local hipYaw,hipRoll=0,0
	local legs = {}
	local footPivots={}
	for _, side in ipairs({"Left", "Right"}) do
		local hip = rootRest:PointToObjectSpace(bones[side .. "Thigh"].Position)
		local knee = rootRest:PointToObjectSpace(bones[side .. "Shin"].Position)
		local hock = rootRest:PointToObjectSpace(bones[side .. "Hock"].Position)
		local a, b = knee - hip, hock - knee
		local footFrame=bones[side.."Foot"].CFrame
		local sole=get(side.."ForefootCoreY")
		local solePoint=footFrame:PointToObjectSpace(sole.CFrame:PointToWorldSpace(Vector3.new(0,-sole.Size.Y/2,0)))
		local front,back=math.huge,-math.huge
		for _,part in ipairs(visuals) do
			if part:GetAttribute("RigRegion")==side.."Foot" then
				for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
					local point=footFrame:PointToObjectSpace(part.CFrame:PointToWorldSpace(Vector3.new(x*part.Size.X/2,y*part.Size.Y/2,z*part.Size.Z/2)))
					front=math.min(front,point.Z);back=math.max(back,point.Z)
				end end end
			end
		end
		footPivots[side]={Toe=Vector3.new(solePoint.X,solePoint.Y,front),Heel=Vector3.new(solePoint.X,solePoint.Y,back)}
		legs[side] = {hip=hip,offset = hock - hip, upper = math.sqrt(a.Y*a.Y + a.Z*a.Z),
			lower = math.sqrt(b.Y*b.Y + b.Z*b.Z), upperAngle = math.atan2(-a.Z, -a.Y),
			lowerAngle = math.atan2(-b.Z, -b.Y)}
	end
	local function solveLeg(side, forwardOffset, lift, bob, footPitch)
		local leg = legs[side]
		local footRotation=CFrame.Angles(math.rad(footPitch or 0),0,0)
		if footPitch and math.abs(footPitch)>0.001 then
			local pivot=footPitch<0 and footPivots[side].Toe or footPivots[side].Heel
			-- Move the ankle with the rolling foot so its planted edge stays at ground height.
			local ankleShift=pivot-footRotation:VectorToWorldSpace(pivot)
			forwardOffset=forwardOffset+ankleShift.Z;lift=lift+ankleShift.Y
		end
		if math.abs(hipYaw)+math.abs(hipRoll)>0.0001 then
			-- Foot targets stay in the unturned ground frame while the pelvis moves above them.
			local hip=pelvisTurn*rest[side.."Thigh"]
			local target=leg.hip+leg.offset+Vector3.new(0,lift-bob,forwardOffset)
			local delta=target-hip.Position
			local a,b=rest[side.."Shin"].Position,rest[side.."Hock"].Position
			local lengthA,lengthB=a.Magnitude,b.Magnitude
			local reach=lengthA+lengthB-0.12*scale
			local horizontal=Vector3.new(delta.X,0,delta.Z)
			local horizontalReach=math.sqrt(math.max(0,reach*reach-delta.Y*delta.Y))
			if horizontal.Magnitude>horizontalReach then
				delta=horizontal.Unit*horizontalReach+Vector3.new(0,delta.Y,0)
			end
			local distance=math.clamp(delta.Magnitude,math.abs(lengthA-lengthB)+0.001,lengthA+lengthB-0.001)
			local direction=delta.Unit
			local hint=-Vector3.zAxis
			local bend=hint-direction*hint:Dot(direction)
			if bend.Magnitude<0.001 then bend=Vector3.yAxis-direction*direction.Y end
			local along=(lengthA^2+distance^2-lengthB^2)/(2*distance)
			local knee=direction*along+bend.Unit*math.sqrt(math.max(0,lengthA^2-along^2))
			local thighRotation=rotateBetween(a,hip:VectorToObjectSpace(knee))
			local kneeFrame=hip*thighRotation*rest[side.."Shin"]
			local shinRotation=rotateBetween(b,kneeFrame:VectorToObjectSpace(direction*distance-knee))
			local hockFrame=kneeFrame*shinRotation*rest[side.."Hock"]
			motors[side.."Thigh"].C0=rest[side.."Thigh"]*thighRotation
			motors[side.."Shin"].C0=rest[side.."Shin"]*shinRotation
			motors[side.."Hock"].C0=rest[side.."Hock"]*hockFrame.Rotation:Inverse()
			motors[side.."Foot"].C0=rest[side.."Foot"]*footRotation
			return
		end
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
		motors[side .. "Foot"].C0 = rest[side .. "Foot"]*footRotation
	end
	local elapsed, accumulator, stopped = 0, 0, false
	local walkCycle, smoothedBob = 0, 0
	local wasWalking,stopAge=false,nil
	local walkFeet,lastWalkUpper={},{}
	local previousMode,transitionLeft="Idle",0
	local runRequested,runBlend=false,0
	local runContacts={}
	local soundContacts={}
	local feedbackRemote
	local owner=movementRoot and game:GetService("Players"):GetPlayerFromCharacter(model.Parent)
	if owner then
		feedbackRemote=Instance.new("RemoteEvent");feedbackRemote.Name="KaijuFeedback";feedbackRemote.Parent=model
	end
	-- Reuse the workshop's existing Guardian/Sovereign audio assets, with heavier tuning.
	local audioPresets={
		Step={113663232024295,0.38,0.95},RunStep={113663232024295,0.52,1.0},
		Land={113663232024295,0.7,0.8},Punch={140192907374090,0.5,1.0},Slam={97522871949213,0.65,1.0},
		Finisher={71814605717939,0.7,1.0},Hit={9116684884,0.3,0.7},HeavyHit={9116684884,0.55,0.52},
		Discharge={1040136448,0.8,1.0},
		Defeat={9116684884,0.75,0.42},
	}
	local audioRandom=Random.new()
	local activeSounds={}
	local function makeSound(asset,source,volume,speed,looped)
		if not owner then return nil end
		local sound=Instance.new("Sound");sound.Name="KaijuAudio";sound.SoundId="rbxassetid://"..asset
		sound.Volume=volume;sound.PlaybackSpeed=speed;sound.Looped=looped==true
		sound.RollOffMinDistance=12*scale;sound.RollOffMaxDistance=160*scale
		sound.Parent=source or bones.Torso;activeSounds[sound]=true
		sound.Destroying:Once(function() activeSounds[sound]=nil end)
		sound:Play()
		if not looped then game:GetService("Debris"):AddItem(sound,5) end
		return sound
	end
	local function feedback(kind,source,soundOnly)
		local definition=audioPresets[kind]
		if not owner or not definition then return end
		local sound=makeSound(definition[1],source,definition[2],definition[3]*audioRandom:NextNumber(0.96,1.04),false)
		if sound and kind~="FocusFire" and kind~="Discharge" and kind~="Punch" and kind~="Slam" and kind~="Finisher" then
			local eq=Instance.new("EqualizerSoundEffect");eq.LowGain=3;eq.MidGain=-3;eq.HighGain=-12;eq.Parent=sound
			game:GetService("Debris"):AddItem(sound,(kind=="Step" or kind=="RunStep") and 1.2 or 2.4)
		end
		if not soundOnly then feedbackRemote:FireClient(owner,kind=="Slam" and "Punch" or kind) end
	end
	model:SetAttribute("RunRequested",false)
	model:SetAttribute("Running",false)
	local function setRunning(enabled)
		if type(enabled)~="boolean" or stopped or not humanoid or humanoid.Health<=0 then return false end
		runRequested=enabled;model:SetAttribute("RunRequested",enabled)
		return true
	end
	local function runFootfall(side)
		local foot=bones[side.."Foot"]
		local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances={model.Parent}
		local hit=workspace:Raycast(foot.Position+Vector3.new(0,3*scale,0),Vector3.new(0,-12*scale,0),params)
		if not hit then return end
		for i=1,5 do
			local dust=Instance.new("Part");dust.Name="RunDust";dust.Shape=Enum.PartType.Ball
			dust.Anchored=true;dust.CanCollide=false;dust.CanTouch=false;dust.CanQuery=false;dust.CastShadow=false
			dust.Material=Enum.Material.SmoothPlastic
			dust.Color=hit.Instance:IsA("BasePart") and hit.Instance.Color or Color3.fromRGB(105,100,90)
			dust.Size=Vector3.new(1,0.5,1)*scale;dust.Transparency=0.5
			dust.Position=hit.Position+Vector3.new(0,0.2*scale,0);dust.Parent=folder
			local spread=Vector3.new(math.cos(i*2.4)*2,0.7,math.sin(i*2.4)*2)*scale
			game:GetService("TweenService"):Create(dust,TweenInfo.new(0.35),
				{Position=dust.Position+spread,Size=Vector3.new(2,1.2,2)*scale,Transparency=1}):Play()
			game:GetService("Debris"):AddItem(dust,0.4)
		end
	end
	local heartbeat, destroying, healthConnection
	local combo = Combo.new(combat and combat.PrepareFinisher)
	local jump = Jump.new()
	local hitReaction,defeat=nil,nil
	local hitSide=1
	local damageFlash=Instance.new("Highlight")
	damageFlash.Name="DamageFeedback";damageFlash.Adornee=model;damageFlash.FillColor=Color3.fromRGB(255,65,45)
	damageFlash.FillTransparency=1;damageFlash.OutlineTransparency=1;damageFlash.Parent=model
	local function isStaggered()
		return hitReaction and hitReaction.Heavy and os.clock()-hitReaction.Started<0.65
	end
	local focus,focusReadyAt=nil,0
	local area,areaReadyAt=nil,0
	local focusColor=Color3.fromRGB(65,225,255)
	local palmRest={}
	for _,side in ipairs({"Left","Right"}) do
		local palm=get(side.."PalmCoreZ")
		palmRest[side]={Local=bones[side.."Hand"].CFrame:ToObjectSpace(palm.CFrame),Thickness=palm.Size.Z}
	end
	local supportPalmNormal=bones.LeftHand.CFrame:VectorToObjectSpace(get("LeftPalmCoreZ").CFrame.LookVector)
	local function braceLeftHand(ground,bob,weight)
		local pelvis=movementRoot.CFrame*rootOffset*CFrame.new(0,bob,0)*pelvisTurn
		local torso=motors.Torso.C0
		local counterTorso=CFrame.new(torso.Position)*pelvisTurn:Inverse()*torso.Rotation
		local shoulder=pelvis*counterTorso*rest.LeftUpperArm
		local target=ground:PointToWorldSpace(Vector3.new(-6,2.2,-7)*scale)
		local delta=target-shoulder.Position
		local a,b=rest.LeftForearm.Position,rest.LeftHand.Position
		local lengthA,lengthB=a.Magnitude,b.Magnitude
		local distance=math.clamp(delta.Magnitude,math.abs(lengthA-lengthB)+0.01,lengthA+lengthB-0.01)
		local direction=delta.Unit
		local hint=-shoulder.RightVector-shoulder.LookVector*0.3
		local bend=hint-direction*hint:Dot(direction)
		if bend.Magnitude<0.001 then bend=shoulder.UpVector-direction*shoulder.UpVector:Dot(direction) end
		local along=(lengthA^2+distance^2-lengthB^2)/(2*distance)
		local elbow=direction*along+bend.Unit*math.sqrt(math.max(0,lengthA^2-along^2))
		local upperRotation=rotateBetween(a,shoulder:VectorToObjectSpace(elbow))
		local elbowFrame=shoulder*upperRotation*rest.LeftForearm
		local foreRotation=rotateBetween(b,elbowFrame:VectorToObjectSpace(direction*distance-elbow))
		local wristFrame=elbowFrame*foreRotation*rest.LeftHand
		local handRotation=rotateBetween(supportPalmNormal,wristFrame:VectorToObjectSpace(-ground.UpVector))
		motors.LeftUpperArm.C0=motors.LeftUpperArm.C0:Lerp(rest.LeftUpperArm*upperRotation,weight)
		motors.LeftForearm.C0=motors.LeftForearm.C0:Lerp(rest.LeftForearm*foreRotation,weight)
		motors.LeftHand.C0=motors.LeftHand.C0:Lerp(rest.LeftHand*handRotation,weight)
	end
	local function endArea()
		if not area then return end
		if area.ChargeSound then area.ChargeSound:Destroy() end
		for p,color in pairs(area.Colors) do if p.Parent then p.Color=color end end
		for _,a in ipairs(area.Attachments) do a:Destroy() end
		area.Effects:Destroy()
		humanoid.WalkSpeed=area.Speed;humanoid.AutoRotate=area.Rotate
		area=nil;model:SetAttribute("AreaPhase","Idle")
	end
	local function requestArea()
		if stopped or isStaggered() or area or focus or not combat or not combat.AreaImpact or not humanoid or not movementRoot
			or humanoid.Health<=0 or humanoid.FloorMaterial==Enum.Material.Air or jump.Phase~="Idle"
			or os.clock()<areaReadyAt or model:GetAttribute("IdleEnabled")==false
			or (model:GetAttribute("ComboStep") or 0)~=0 then return false end
		local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances={model.Parent}
		local ahead=movementRoot.Position
		local hit=workspace:Raycast(ahead+Vector3.new(0,30*scale,0),Vector3.new(0,-70*scale,0),params)
		if not hit or hit.Normal.Y<0.7 or (hit.Position-movementRoot.Position).Magnitude>20*scale then return false end
		combo:Cancel();combat.Cancel()
		area={Started=os.clock(),Hit=false,Point=hit.Position,StartRoot=movementRoot.Position,
			Ground=CFrame.new(hit.Position)*movementRoot.CFrame.Rotation,
			Speed=humanoid.WalkSpeed,Rotate=humanoid.AutoRotate,Colors={},Attachments={},Nodes={},Arcs={}}
		area.ChargeSound=makeSound(122502397357855,bones.Torso,0.12,0.72,false)
		if area.ChargeSound then game:GetService("TweenService"):Create(area.ChargeSound,TweenInfo.new(2.6),{Volume=0.5,PlaybackSpeed=1.05}):Play() end
		area.Effects=Instance.new("Folder");area.Effects.Name="DorsalCharge";area.Effects.Parent=model
		local function node(source,offset)
			local a=Instance.new("Attachment");a.Name="DischargeNode";a.CFrame=offset;a.Parent=source
			table.insert(area.Attachments,a)
			local orb=Instance.new("Part")
			orb.Name="PlateCharge";orb.Shape=Enum.PartType.Ball;orb.Material=Enum.Material.Neon;orb.Color=focusColor
			orb.Size=Vector3.new(0.1,0.1,0.1);orb.CFrame=source.CFrame*offset
			orb.Massless=true;orb.CanCollide=false;orb.CanQuery=false;orb.CanTouch=false;orb.CastShadow=false
			orb.Transparency=1;orb.Parent=area.Effects
			local weld=Instance.new("Weld");weld.Part0=source;weld.Part1=orb;weld.C0=offset;weld.Parent=orb
			local light=Instance.new("PointLight");light.Color=focusColor;light.Range=7*scale;light.Brightness=0;light.Parent=orb
			table.insert(area.Nodes,{Attachment=a,Orb=orb,Light=light})
		end
		for i=1,9 do
			local plate=model:FindFirstChild(string.format("DorsalShield_%02d",i))
			if plate then node(plate,CFrame.new(0,0,-plate.Size.Z*0.35)) end
		end
		node(get("TailTip"),CFrame.identity)
		local function arc(first,last)
			local record={First=first.Attachment,Last=last.Attachment,Points={},Beams={}}
			local chain={record.First}
			for i=1,2 do
				local p=Instance.new("Part");p.Name="ArcBend";p.Size=Vector3.new(0.1,0.1,0.1)
				p.Anchored=true;p.Transparency=1;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Parent=area.Effects
				local a=Instance.new("Attachment");a.Parent=p
				table.insert(record.Points,p);table.insert(chain,a)
			end
			table.insert(chain,record.Last)
			for i=1,3 do
				local beam=Instance.new("Beam");beam.Attachment0=chain[i];beam.Attachment1=chain[i+1]
				beam.Color=ColorSequence.new(focusColor);beam.LightEmission=1;beam.LightInfluence=0
				beam.FaceCamera=true;beam.Enabled=false;beam.Parent=area.Effects
				table.insert(record.Beams,beam)
			end
			table.insert(area.Arcs,record)
		end
		for i=1,#area.Nodes-1 do arc(area.Nodes[i],area.Nodes[i+1]) end
		if #area.Nodes>2 then arc(area.Nodes[#area.Nodes],area.Nodes[2]) end
		for _,p in ipairs(visuals) do
			if string.match(p.Name,"^DorsalEnergy_") then area.Colors[p]=p.Color end
		end
		areaReadyAt=os.clock()+4 -- Provisional workshop cooldown, starting at activation.
		humanoid.WalkSpeed=0;humanoid.AutoRotate=false;humanoid:Move(Vector3.zero,false)
		model:SetAttribute("AreaPhase","Charging")
		return true
	end
	local function endFocus()
		if not focus then return end
		if focus.ChargeSound then focus.ChargeSound:Destroy() end
		if focus.BeamSound then focus.BeamSound:Destroy() end
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
		if stopped or isStaggered() or focus or area or not combat or not combat.SelectFocusTarget or not humanoid
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
		focus.ChargeSound=makeSound(1336756135,mouth,0.12,0.82,false)
		if focus.ChargeSound then game:GetService("TweenService"):Create(focus.ChargeSound,TweenInfo.new(1.8),{Volume=0.42,PlaybackSpeed=1.1}):Play() end
		focus.Orb.CFrame=upper.CFrame*offset
		focus.Orb.Anchored=false;focus.Orb.Massless=true
		local weld=Instance.new("Weld")
		weld.Name="MouthChargeWeld";weld.Part0=upper;weld.Part1=focus.Orb
		weld.C0=offset;weld.C1=CFrame.identity;weld.Parent=focus.Orb
		focus.OrbWeld=weld
		focus.Motes={};focus.LastPulse=-1;focus.Rubble={}
		for i=1,12 do table.insert(focus.Motes,effect("IntakeSpark",Enum.PartType.Ball,focusColor)) end
		-- Each pulse has a one-way lifetime; never interpolate a reused part back to the mouth.
		focus.EmitPulse=function(from,to)
			if (to-from).Magnitude<0.01 then return end
			local pulse=effect("BeamPulse",Enum.PartType.Ball,Color3.fromRGB(230,255,255))
			pulse.CFrame=CFrame.lookAt(from,to);pulse.Size=Vector3.new(1,1,1)*1.65*scale
			pulse.Transparency=0.15
			local left=Instance.new("Attachment");left.Position=Vector3.new(-0.65*scale,0,0);left.Parent=pulse
			local right=Instance.new("Attachment");right.Position=Vector3.new(0.65*scale,0,0);right.Parent=pulse
			local trail=Instance.new("Trail");trail.Name="OutwardEnergyWake"
			trail.Attachment0=left;trail.Attachment1=right;trail.FaceCamera=true
			trail.Lifetime=0.2;trail.MinLength=0.01;trail.LightEmission=1
			trail.Color=ColorSequence.new(focusColor)
			trail.Transparency=NumberSequence.new(0.2,1)
			trail.WidthScale=NumberSequence.new(1,0);trail.Parent=pulse
			-- A bright leading head stays visible all the way to the target.
			-- Its tapered wake records only positions behind it, towards the mouth.
			local travel=game:GetService("TweenService"):Create(pulse,TweenInfo.new(0.7,Enum.EasingStyle.Linear),{Position=to})
			travel.Completed:Once(function()
				if pulse.Parent then pulse.Transparency=1;trail.Enabled=false end
			end)
			travel:Play()
			game:GetService("Debris"):AddItem(pulse,0.92)
		end
		local groundParams=RaycastParams.new();groundParams.FilterType=Enum.RaycastFilterType.Exclude
		groundParams.FilterDescendantsInstances={model.Parent}
		for _,side in ipairs({"Left","Right"}) do
			local foot=bones[side.."Foot"].Position
			local hit=workspace:Raycast(foot+Vector3.new(0,5*scale,0),Vector3.new(0,-15*scale,0),groundParams)
			if hit then
				for i=1,8 do
					local rock=effect("FocusGroundChip",Enum.PartType.Block,hit.Instance:IsA("BasePart") and hit.Instance.Color or Color3.fromRGB(90,90,85))
					rock.Material=Enum.Material.Slate
					local direction=movementRoot.CFrame:VectorToWorldSpace(Vector3.new(math.cos(i*2.4),0,1+math.sin(i*2.4)*0.4))
					table.insert(focus.Rubble,{Part=rock,Origin=hit.Position+movementRoot.CFrame:VectorToWorldSpace(Vector3.new(0,0,side=="Right" and 2.6*scale or 0)),Direction=direction,Index=i})
				end
			end
		end
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
		if stopped or isStaggered() or focus or area or not humanoid or humanoid.Health<=0 or not movementRoot
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
		if stopped or isStaggered() or focus or area or jump.Phase~="Idle" or not humanoid or humanoid.Health <= 0
			or humanoid.FloorMaterial == Enum.Material.Air
			or model:GetAttribute("IdleEnabled") == false then return false end
		return combo:Request(os.clock())
	end
	local function reset()
		hitReaction=nil;damageFlash.FillTransparency=1
		for sound in pairs(activeSounds) do sound:Destroy() end
		soundContacts={}
		endArea()
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
		hipYaw,hipRoll=0,0;pelvisTurn=CFrame.identity
		wasWalking,stopAge=false,nil;walkFeet,lastWalkUpper={},{}
		previousMode,transitionLeft="Idle",0
		runRequested,runBlend=false,0;runContacts={}
		model:SetAttribute("RunRequested",false);model:SetAttribute("Running",false)
		if humanoid then humanoid.WalkSpeed=WALK_SPEED end
	end
	local function stop()
		if stopped then return end
		stopped = true
		if heartbeat then heartbeat:Disconnect() end
		if destroying then destroying:Disconnect() end
		if healthConnection then healthConnection:Disconnect() end
		reset()
		damageFlash:Destroy()
	end
	local function smooth(value)
		local t=math.clamp(value,0,1);return t*t*(3-2*t)
	end
	local function updateDefeat(dt)
		local t=os.clock()-defeat.Started
		local kneel=smooth(t/0.45)
		local fall=smooth((t-0.25)/1.55)
		local settle=smooth((t-1.8)/0.8)
		local function fallen(name,x,y,z)
			local target=rest[name]*CFrame.Angles(math.rad(x),math.rad(y),math.rad(z))
			motors[name].C0=motors[name].C0:Lerp(target,1-math.exp(-dt/0.09))
		end
		-- Lose support and pitch forward; the legs remain long instead of folding up.
		fallen("Torso",-8*kneel*(1-fall),0,0)
		fallen("Head",65*fall,18*fall,0)
		fallen("Jaw",-10*kneel,0,0)
		for _,side in ipairs({"Left","Right"}) do
			local sign=side=="Left" and -1 or 1
			fallen(side.."Thigh",8*kneel*(1-fall),0,sign*7*fall)
			fallen(side.."Shin",-14*kneel*(1-fall),0,0)
			fallen(side.."Hock",6*kneel*(1-fall),0,0)
			fallen(side.."Foot",-8*fall,0,0)
			fallen(side.."UpperArm",185*fall,0,sign*30*fall)
			fallen(side.."Forearm",0,0,0)
			fallen(side.."Hand",0,0,0)
		end
		-- Counter the body's forward rotation so the long tail trails along the ground.
		fallen("TailBase",80*fall,0,0)
		for i=1,tailCount do fallen("Tail"..i,i==1 and -14*fall or 0,(i==1 and 3 or 0.3)*fall,0) end
		local rootPose=defeat.Root*CFrame.new(0,-1.2*kneel*scale,-4*fall*scale)*CFrame.Angles(math.rad(-88*fall),0,0)
		-- Only the corpse uses geometry-to-floor settling; live locomotion stays unchanged.
		local frames={Pelvis=rootPose}
		local function worldBone(name)
			if frames[name] then return frames[name] end
			local motor=motors[name]
			frames[name]=worldBone(motor.Part0.Name)*motor.C0
			return frames[name]
		end
		local lowest=math.huge
		for _,item in ipairs(corpseGeometry) do
			local part=item.Part
			local cf=worldBone(item.Bone)*item.Local
			local h=part.Size/2
			local x,y,z=cf.RightVector.Y*h.X,cf.UpVector.Y*h.Y,cf.LookVector.Y*h.Z
			local extent=math.abs(x)+math.abs(y)+math.abs(z)
			if part:IsA("Part") and part.Shape==Enum.PartType.Ball then extent=math.sqrt(x*x+y*y+z*z)
			elseif part:IsA("Part") and part.Shape==Enum.PartType.Cylinder then extent=math.abs(x)+math.sqrt(y*y+z*z) end
			-- Rest the chest/head on the floor; a hand or tail must not prop up the whole corpse.
			if item.Bone=="Torso" or item.Bone=="Head" or item.Bone=="Pelvis" then
				lowest=math.min(lowest,cf.Position.Y-extent)
			end
		end
		local correction=defeat.Ground-lowest
		rootPose=rootPose+Vector3.new(0,correction<0 and correction*fall or correction,0)
		-- Settling can lower the body, never lift it back into a push-up.
		local height=math.min(rootPose.Position.Y,defeat.LastHeight or defeat.Root.Position.Y)
		rootPose=rootPose+Vector3.new(0,height-rootPose.Position.Y,0)
		defeat.LastHeight=height
		rootJoint.C0=movementRoot.CFrame:ToObjectSpace(rootPose)
		-- Settle the tapered forearms and flat palms beside and ahead of the face.
		-- Solve from the shoulder; do not lift the chest to accommodate the hands.
		for _,side in ipairs({"Left","Right"}) do
			local sign=side=="Left" and -1 or 1
			local shoulder=rootPose*motors.Torso.C0*rest[side.."UpperArm"]
			local direction=(movementRoot.CFrame.LookVector+movementRoot.CFrame.RightVector*sign*0.65).Unit
			local palm=palmRest[side]
			local wristRotation=CFrame.lookAt(Vector3.zero,-Vector3.yAxis,-direction)*palm.Local.Rotation:Inverse()
			local wristHeight=defeat.Ground+palm.Thickness/2-wristRotation:VectorToWorldSpace(palm.Local.Position).Y
			local a,b=rest[side.."Forearm"].Position,rest[side.."Hand"].Position
			local upperLength,lowerLength=a.Magnitude,b.Magnitude
			local elbowHeight=math.clamp(defeat.Ground+2.5*scale,
				shoulder.Position.Y-upperLength+0.05*scale,shoulder.Position.Y+upperLength-0.05*scale)
			local upperDrop=elbowHeight-shoulder.Position.Y
			local elbow=shoulder.Position+direction*math.sqrt(math.max(0,upperLength^2-upperDrop^2))+Vector3.new(0,upperDrop,0)
			local lowerDrop=math.clamp(wristHeight-elbowHeight,-lowerLength+0.01*scale,lowerLength-0.01*scale)
			local wrist=elbow+direction*math.sqrt(math.max(0,lowerLength^2-lowerDrop^2))+Vector3.new(0,lowerDrop,0)
			local upperRotation=rotateBetween(a,shoulder:VectorToObjectSpace(elbow-shoulder.Position))
			local elbowFrame=shoulder*upperRotation*rest[side.."Forearm"]
			local foreRotation=rotateBetween(b,elbowFrame:VectorToObjectSpace(wrist-elbow))
			local wristFrame=elbowFrame*foreRotation*rest[side.."Hand"]
			motors[side.."UpperArm"].C0=motors[side.."UpperArm"].C0:Lerp(rest[side.."UpperArm"]*upperRotation,settle)
			motors[side.."Forearm"].C0=motors[side.."Forearm"].C0:Lerp(rest[side.."Forearm"]*foreRotation,settle)
			motors[side.."Hand"].C0=motors[side.."Hand"].C0:Lerp(rest[side.."Hand"]*wristFrame.Rotation:Inverse()*wristRotation,settle)
		end
		if t>=1.8 and not defeat.Impact then
			defeat.Impact=true
			feedback("Defeat",bones.Torso)
			for i=1,10 do
				local dust=Instance.new("Part");dust.Name="DefeatDust";dust.Shape=Enum.PartType.Ball
				dust.Anchored=true;dust.CanCollide=false;dust.CanTouch=false;dust.CanQuery=false;dust.CastShadow=false
				dust.Material=Enum.Material.SmoothPlastic;dust.Color=Color3.fromRGB(100,100,95)
				dust.Size=Vector3.new(2,0.6,2)*scale;dust.Transparency=0.45
				dust.Position=Vector3.new(rootPose.Position.X,defeat.Ground+0.3*scale,rootPose.Position.Z)
				dust.Parent=folder
				local outward=Vector3.new(math.cos(i*2.4)*8,1.3,math.sin(i*2.4)*8)*scale
				game:GetService("TweenService"):Create(dust,TweenInfo.new(0.7),
					{Position=dust.Position+outward,Size=Vector3.new(5,2,5)*scale,Transparency=1}):Play()
				game:GetService("Debris"):AddItem(dust,0.75)
			end
		end
		local dark=smooth(t/1.15)
		local eyesDark=smooth((t-2.0)/0.8)
		for _,glow in ipairs(defeat.Glow) do
			local fade=glow.Eye and eyesDark or dark
			glow.Part.Color=glow.Color:Lerp(Color3.fromRGB(25,32,40),fade)
			if fade>=1 then glow.Part.Material=Enum.Material.SmoothPlastic end
		end
		for _,light in ipairs(defeat.Lights) do
			light.Part.Brightness=light.Brightness*(1-(light.Eye and eyesDark or dark))
		end
		damageFlash.FillTransparency=1-0.6*math.max(0,1-t/0.4)
		model:SetAttribute("ReactionState",t<0.7 and "Buckling" or t<2.9 and "Falling" or "Defeated")
		if t>=2.9 then defeat.Settled=true end
	end
	if humanoid and movementRoot then
		humanoid.BreakJointsOnDeath=false
		local previousHealth=humanoid.Health
		healthConnection=humanoid.HealthChanged:Connect(function(health)
			local damage=previousHealth-health;previousHealth=health
			if stopped or defeat or damage<=0 then return end
			if health<=0 then
				endArea();endFocus();jump:Cancel();restoreJump();combo:Cancel()
				if combat then combat.Cancel() end
				runRequested=false;humanoid.WalkSpeed=0;humanoid.AutoRotate=false
				humanoid:Move(Vector3.zero,false)
				movementRoot.Anchored=true
				local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances={model.Parent}
				local ground=workspace:Raycast(movementRoot.Position+Vector3.new(0,30*scale,0),Vector3.new(0,-150*scale,0),params)
				defeat={Started=os.clock(),Root=movementRoot.CFrame*rootJoint.C0,
					Ground=ground and ground.Position.Y or (movementRoot.CFrame*rootOffset).Position.Y-15.7*scale}
				defeat.Glow={};defeat.Lights={}
				for _,part in ipairs(model:GetDescendants()) do
					if part:IsA("BasePart") and part.Material==Enum.Material.Neon then
						table.insert(defeat.Glow,{Part=part,Color=part.Color,Eye=string.find(part.Name,"Eye")~=nil})
					elseif part:IsA("PointLight") or part:IsA("SpotLight") or part:IsA("SurfaceLight") then
						table.insert(defeat.Lights,{Part=part,Brightness=part.Brightness,Eye=string.find(part.Parent.Name,"Eye")~=nil})
					end
				end
				model:SetAttribute("Running",false);model:SetAttribute("RunRequested",false)
				model:SetAttribute("ComboStep",0);model:SetAttribute("AttackName","")
			else
				hitSide=-hitSide
				local heavy=damage>=humanoid.MaxHealth*0.18
				hitReaction={Started=os.clock(),Heavy=heavy,Side=hitSide}
				if heavy then
					endArea();endFocus();combo:Cancel();if combat then combat.Cancel() end
				end
				model:SetAttribute("ReactionState",heavy and "Stagger" or "Hit")
				feedback(heavy and "HeavyHit" or "Hit",bones.Torso)
			end
		end)
	end
	local wasEnabled = true
	heartbeat = RunService.Heartbeat:Connect(function(dt)
		if not model:IsDescendantOf(workspace) then stop(); return end
		if defeat then
			accumulator=accumulator+dt
			if not defeat.Settled and accumulator>=1/30 then
				local defeatDt=accumulator;accumulator=0;updateDefeat(defeatDt)
			end
			return
		end
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
		if area and (humanoid.Health<=0 or humanoid.FloorMaterial==Enum.Material.Air
			or (movementRoot.Position-area.StartRoot).Magnitude>3*scale or os.clock()-area.Started>=AREA_TIMING.Finish) then endArea() end
		local areaTime=area and os.clock()-area.Started
		local areaCharge,areaRecover=0,0
		if area then
			areaCharge=math.clamp(areaTime/AREA_TIMING.Curl,0,1)
			areaCharge=areaCharge*areaCharge*(3-2*areaCharge)
			areaRecover=math.clamp((areaTime-AREA_TIMING.Recovery)/(AREA_TIMING.Finish-AREA_TIMING.Recovery),0,1)
			areaRecover=areaRecover*areaRecover*(3-2*areaRecover)
		end
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
				feedback("Land",bones.Pelvis)
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
		if jumpPose or isStaggered() then walking=false end
		if focus then walking=false;humanoid:Move(Vector3.zero,false) end
		if area then walking=false;humanoid:Move(Vector3.zero,false) end
		local runAllowed=not isStaggered() and not focus and not area and jump.Phase=="Idle"
			and humanoid and humanoid.Health>0 and (model:GetAttribute("ComboStep") or 0)==0
		if humanoid and not focus and not area and jump.Phase=="Idle" and humanoid.Health>0 then
			humanoid.WalkSpeed=isStaggered() and 0 or runRequested and runAllowed and RUN_SPEED or WALK_SPEED
		end
		local running=walking and runRequested and runAllowed
		runBlend=runBlend+((running and 1 or 0)-runBlend)*(1-math.exp(-poseDt/0.22))
		model:SetAttribute("Running",running==true)
		local stride=STRIDE+(RUN_STRIDE-STRIDE)*runBlend
		local stance=STANCE+(RUN_STANCE-STANCE)*runBlend
		local duration = model:GetAttribute("WalkCycleSeconds")
		if type(duration) ~= "number" or duration ~= duration then duration = CYCLE_SECONDS end
		duration = math.clamp(duration, 1.5, 3.0)
		if walking then
			-- Match the stance distance to actual travel, including slow starts.
			local rate = movementRoot and math.min(speed, 20)/((stride/stance)*scale) or 1/duration
			walkCycle = walkCycle + poseDt*rate
		end
		local cycle = walkCycle
		local phase = cycle * math.pi * 2
		local gaitPhase = (cycle + stance/2) * math.pi * 2
		-- A short, smooth compression after each landing, followed by recovery.
		-- Keep the stance foot on the floor through the leg solver below.
		local sinceLanding = ((cycle + stance/2)*2)%1
		local compression = math.sin(math.pi*math.min(sinceLanding/0.32, 1))^2
		if humanoid and humanoid.Health <= 0 then
			combo:Cancel()
			if combat then combat.Cancel() end
		end
		local attackPose, attackWeight, attackName, attackIndex, attackCrouch = combo:Sample(os.clock())
		for _, event in ipairs(combo:DrainEvents()) do
			if combat then
				combat.Handle(event.Kind, event.Index, event.FinisherUntil)
				if event.Kind=="Hit" and model:GetAttribute("LastAttackResult")=="Hit" then
					local soundKind=event.Index==4 and "Finisher" or event.Index==3 and "Slam" or "Punch"
					local source=event.Index==1 and bones.LeftHand or event.Index==2 and bones.RightHand or bones.Torso
					feedback(soundKind,source)
				end
			end
		end
		local special=jumpPose or focus or area or attackPose or isStaggered()
		local mode=area and "Area" or focus and "Focus" or jumpPose and "Jump" or attackPose and "Attack" or running and "Run" or walking and "Walk" or "Idle"
		if mode~=previousMode then transitionLeft=0.22;previousMode=mode end
		transitionLeft=math.max(0,transitionLeft-poseDt)
		if special or walking or (humanoid and (humanoid.Health<=0 or humanoid.FloorMaterial==Enum.Material.Air)) then stopAge=nil
		elseif wasWalking then stopAge=0 end
		wasWalking=walking
		local stopWeight,stopLoad=0,0
		if stopAge then
			stopAge=stopAge+poseDt
			local t=math.clamp(stopAge/0.55,0,1)
			stopWeight=1-t*t*(3-2*t)
			stopLoad=math.sin(math.pi*t)^2
			if t>=1 then stopAge=nil end
		end
		local bob = walking and -(1.05 - 0.25*runBlend + (0.38+0.1*runBlend)*compression)*scale*fade or -(1.05*stopWeight+0.55*stopLoad)*scale
		-- Lower the pelvis as well as the torso; IK bends the legs while the
		-- planted feet retain their floor height. Recovery uses the same smoothing.
		bob = bob - (attackCrouch or 0)*scale
		if jumpPose then bob=-jumpPose.Crouch*scale end
		if focus then
			local kick=focusTime>=2 and math.exp(-(focusTime-2)*9) or 0
			bob=-(1.7*math.min(focusTime/0.65,1)+0.65*kick)*scale*math.clamp((4.85-focusTime)/0.35,0,1)
		end
		if area then bob=-7.2*areaCharge*(1-areaRecover)*scale end
		if isStaggered() then
			bob=bob-0.9*math.sin(math.pi*math.clamp((os.clock()-hitReaction.Started)/0.65,0,1))*scale
			humanoid:Move(Vector3.zero,false)
		end
		local blend = 1-math.exp(-poseDt/0.10)
		smoothedBob = smoothedBob + (bob-smoothedBob)*blend
		local hipWeight=not special and (walking and 1 or stopWeight) or 0
		-- The pelvis leads the stride; the ribcage counters above it.
		local targetYaw=-math.sin(gaitPhase-0.15)*(6+3*runBlend)*fade*hipWeight
		local targetRoll=math.sin(gaitPhase-0.45)*(2.5+1.0*runBlend)*fade*hipWeight
		hipYaw=hipYaw+(targetYaw-hipYaw)*blend
		hipRoll=hipRoll+(targetRoll-hipRoll)*blend
		pelvisTurn=CFrame.Angles(0,math.rad(hipYaw),math.rad(hipRoll))
		if rootJoint then
			rootJoint.C0 = rootOffset * CFrame.new(0, smoothedBob, 0)*pelvisTurn
		else
			bones.Pelvis.CFrame = rootRest * CFrame.new(0, smoothedBob, 0)*pelvisTurn
		end
		local actualBob = smoothedBob
		if walking then
			model:SetAttribute("AnimationPreview", running and "HeavyRun_01" or "HeavyWalk_04_ShoulderFollowThrough")
			local weightShift = math.sin(gaitPhase - 0.35)*fade
			-- Forward is local -Z: negative X pitch brings the upper body forward.
			pose("Torso", (-11.0-23*runBlend - compression*(1.6+runBlend))*fade, weightShift*(5.5+2*runBlend), weightShift*3.8)
			-- The neck partly counters the lean to keep the gaze ahead. Head motion
			-- follows the weight transfer with a delay instead of locking to the torso.
			local headFollow = math.sin(gaitPhase - 0.80)*fade
			local headNod = math.sin(gaitPhase*2 - 0.65)*2.2*fade
			pose("Head", (6.0+16*runBlend)*fade + headNod - compression*0.8*fade,
				-headFollow*4.5, -headFollow*2.2)
			pose("Jaw", 0, 0, 0)
			for _, side in ipairs({"Left", "Right"}) do
				local offset = side == "Left" and 0 or 0.5
				local t = (cycle+offset+stance/2)%1
				local travel, lift
				if t < stance then
					-- The planted foot moves back at the body's actual travel speed.
					travel, lift = -stride/2 + stride*t/stance, 0
				else
					local swing = (t-stance)/(1-stance)
					local smooth = swing*swing*(3-2*swing)
					travel = stride/2-stride*smooth
					-- Spend more of the swing lifting the heavy leg, then settle firmly.
					-- Both ends and the apex have zero vertical velocity.
					local liftPhase=swing<0.6 and swing/0.6 or (1-swing)/0.4
					lift = (2.2+0.6*runBlend)*liftPhase*liftPhase*(3-2*liftPhase)
					-- After toe-off, finish the push behind the hips before recovering forward.
					local rearKick=math.sin(math.pi*math.min(swing/0.36,1))^2*runBlend
					travel=travel+2.4*rearKick
					lift=lift+1.5*rearKick
				end
				-- Shift the running step slightly behind the body, keeping stance speed unchanged.
				travel=travel+0.6*runBlend
				local contact=math.floor(cycle+offset+stance/2)
				if not special and soundContacts[side] and contact>soundContacts[side] then
					feedback(running and "RunStep" or "Step",bones[side.."Foot"])
				end
				soundContacts[side]=contact
				if running and runBlend>0.8 then
					if runContacts[side] and contact>runContacts[side] then runFootfall(side) end
					runContacts[side]=contact
				else runContacts[side]=nil end
				local landingPitch=10+4*runBlend
				local pushPitch=-(18+10*runBlend)
				local footPitch
				if t<stance then
					local planted=t/stance
					if planted<0.18 then
						local q=planted/0.18;footPitch=landingPitch*(1-q*q*(3-2*q))
					elseif planted>0.72 then
						local q=(planted-0.72)/0.28;footPitch=pushPitch*q*q*(3-2*q)
					else footPitch=0 end
				else
					local q=(t-stance)/(1-stance)
					footPitch=pushPitch+(landingPitch-pushPitch)*q*q*(3-2*q)
				end
				footPitch=footPitch*fade
				walkFeet[side]={Travel=travel*scale*fade,Lift=lift*scale*fade,Pitch=footPitch}
				solveLeg(side, travel*scale*fade, lift*scale*fade, actualBob,footPitch)
				local sign=side=="Left" and -1 or 1
				local armPhase=(cycle+offset+stance/2)*math.pi*2
				local swing=math.sin(armPhase-0.3)*fade
				local elbowFollow=math.sin(armPhase-0.85)*fade
				local wristFollow=math.sin(armPhase-1.25)*fade
				local shoulderRoll=math.cos(armPhase-0.3)*fade
				-- Shoulder leads; the bent elbow and heavy hand follow with separate delays.
				-- A small outward arc keeps the hands clear of the thighs.
				pose(side .. "UpperArm",(8+20*runBlend)*fade-swing*(17+25*runBlend),sign*shoulderRoll*4,
					-sign*(5*fade+3*shoulderRoll))
				-- Flex behind the forward shoulder swing, then open as the arm returns.
				pose(side .. "Forearm",(26+12*runBlend)*fade-elbowFollow*(20+5*runBlend),0,sign*elbowFollow*3)
				pose(side .. "Hand",-6*fade+wristFollow*6,sign*wristFollow*3,0)
			end
			for i = 1, tailCount do
				-- Lift mainly at the base; a delayed counter-swing travels down the tail.
				local lift=i==1 and 12 or math.max(1.5,4.5-(i-2)*0.25)
				local walkYaw=-math.sin(phase-i*0.32)*(0.5+i*0.10)
				local balanceYaw=-math.sin(gaitPhase-0.35-i*0.18)*(2.3+i*0.32)
				pose("Tail" .. i,-lift*runBlend,
					(walkYaw*(1-runBlend)+balanceYaw*runBlend)*fade,0)
			end
		else
			soundContacts={}
			model:SetAttribute("AnimationPreview", "PowerIdle_02")
			for _, side in ipairs({"Left", "Right"}) do
				local foot=walkFeet[side]
				solveLeg(side,foot and foot.Travel*stopWeight or 0,foot and foot.Lift*stopWeight or 0,actualBob,foot and foot.Pitch*stopWeight or 0)
			end
		end
		local upperNames={"Torso","Head","LeftUpperArm","RightUpperArm","LeftForearm","RightForearm","LeftHand","RightHand"}
		if walking and not special then
			for _,name in ipairs(upperNames) do lastWalkUpper[name]=motors[name].C0 end
		elseif stopWeight>0 then
			for _,name in ipairs(upperNames) do
				if lastWalkUpper[name] then motors[name].C0=motors[name].C0:Lerp(lastWalkUpper[name],stopWeight) end
			end
			-- Absorb forward momentum; the hands carry on a little as the chest settles.
			motors.Torso.C0=motors.Torso.C0*CFrame.Angles(math.rad(-3*stopLoad),0,0)
			for _,side in ipairs({"Left","Right"}) do
				motors[side.."Forearm"].C0=motors[side.."Forearm"].C0*CFrame.Angles(math.rad(7*stopLoad),0,0)
			end
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
			if firing and not focus.SoundFired then
				focus.SoundFired=true
				if focus.ChargeSound then focus.ChargeSound:Destroy() end
				focus.BeamSound=makeSound(139620337204036,focus.Mouth,0.4,1.0,true)
				if feedbackRemote then feedbackRemote:FireClient(owner,"FocusFire") end
			elseif t>=4.5 and focus.BeamSound then
				focus.BeamSound:Destroy();focus.BeamSound=nil
			end
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
			local kick=firing and math.exp(-(t-2)*9) or 0
			local tremor=(firing and math.sin(t*32)*0.8 or t<1.8 and math.sin(t*42)*charge^4*0.9 or 0)
			local build=math.min(t/1.5,1)
			local torsoPitch=(-14*build+13*kick+tremor)*fadeOut
			pose("Torso",torsoPitch,0,0)
			local step=math.clamp(t/0.65,0,1);step=step*step*(3-2*step)
			solveLeg("Left",0,0,actualBob)
			solveLeg("Right",2.6*step*fadeOut*scale,t<0.65 and math.sin(math.pi*t/0.65)^2*1.2*scale or 0,actualBob)
			local reach=lowAim*charge*fadeOut
			motors.Head.C0=rest.Head*CFrame.new(0,0.5*scale*reach,(-1.2*reach+0.5*build*fadeOut+0.7*kick)*scale)
				*CFrame.Angles(math.rad(pitch*charge*fadeOut-torsoPitch),math.rad(yaw*charge*fadeOut),0)
			-- Forward is -Z: negative X lowers the jaw. Open before the beam starts.
			local opening=math.clamp((t-1.5)/0.3,0,1)
			pose("Jaw",-(36-10*lowAim)*opening*fadeOut,0,0)
			for _,side in ipairs({"Left","Right"}) do
				local sign=side=="Left" and -1 or 1
				pose(side.."UpperArm",(27*build-10*kick)*fadeOut,sign*8*build*fadeOut,-sign*24*build*fadeOut)
				pose(side.."Forearm",(35*build-8*kick+tremor)*fadeOut,0,0)
				pose(side.."Hand",-15*build*fadeOut,sign*12*build*fadeOut,0)
			end
			for p,color in pairs(focus.Colors) do
				local index=tonumber(string.match(p.Name,"^DorsalEnergy_(%d+)")) or 1
				local onset=math.clamp((tailCount-index)/(tailCount-1),0,1)*1.5
				p.Color=color:Lerp(focusColor,math.clamp((t-onset)/0.3,0,1)*fadeOut)
			end
			local orbSize=(0.15+charge*0.85)*(1+0.08*math.sin(t*28)*charge)*scale*fadeOut
			focus.Orb.Size=Vector3.new(orbSize,orbSize,orbSize)
			focus.Orb.Transparency=0.15
			for _,beam in ipairs({focus.Beam,focus.Core}) do
				beam.Enabled=t>=2 and delta.Magnitude>0.01
				beam.Transparency=NumberSequence.new(0.12+0.88*(1-fadeOut))
				if t>=2 and delta.Magnitude>0.01 then
					local width=math.max(0.05,(beam==focus.Core and 0.45 or 1.15)*(1+0.25*kick+0.08*math.sin(t*25))*scale*fadeOut)
					beam.Width0=width;beam.Width1=width
				end
			end
			focus.Impact.Transparency=firing and visible and 0.25 or 1
			focus.Impact.Size=Vector3.new(2,2,2)*scale*(1+0.12*math.sin(t*40))
			focus.Impact.CFrame=CFrame.new(point)
			-- Intake and travelling pulses follow the moving palate, never a cached world point.
			local mouthCF=upperLip.CFrame*palateOffset
			for i,mote in ipairs(focus.Motes) do
				local progress=(t*1.4+i/12)%1
				local angle=i*2.39996+t*2
				local radius=(1-progress)*2.2*scale
				mote.Position=mouthCF:PointToWorldSpace(Vector3.new(math.cos(angle)*radius,math.sin(angle)*radius,-(1-progress)*3*scale))
				mote.Size=Vector3.new(1,1,1)*0.16*scale
				mote.Transparency=t<1.8 and 1-charge*math.sin(progress*math.pi) or 1
			end
			if firing and t<=3.8 then
				-- Separate pulses so repeated bright spots cannot read as reverse motion.
				local pulseIndex=math.floor((t-2)/0.85)
				if pulseIndex>focus.LastPulse then
					focus.LastPulse=pulseIndex
					focus.EmitPulse(from,point)
				end
			end
			for _,chip in ipairs(focus.Rubble) do
				local age=t-2
				local flight=math.clamp(age/0.65,0,1)
				local offset=chip.Direction*flight*(3+chip.Index%3)*scale+Vector3.new(0,math.sin(flight*math.pi)*(1+chip.Index%3)*scale,0)
				chip.Part.CFrame=CFrame.new(chip.Origin+offset)*CFrame.Angles(flight*4,chip.Index,flight*3)
				chip.Part.Size=Vector3.new(0.5,0.35,0.65)*scale
				chip.Part.Transparency=age>=0 and age<0.65 and flight or 1
			end
			-- Ten scheduled ticks; do not turn a delayed frame into an extra hit.
			local due=math.clamp(math.floor((t-2)/0.25),0,10)
			while focus.Ticks<due do
				focus.Ticks=focus.Ticks+1
				combat.Handle("Focus",0,focus.Target,from)
			end
			model:SetAttribute("FocusPhase",t<2 and "Charging" or t<4.5 and "Firing" or "Recovery")
		end
		if area then
			if areaTime>=math.max(0,AREA_TIMING.Discharge-0.5) and not area.ImpulseSoundStarted then
				area.ImpulseSoundStarted=true
				feedback("Discharge",bones.Torso,true)
			end
			local hold=1-areaRecover
			local tension=areaCharge*hold
			local tremor=math.sin(areaTime*38)*0.55*areaCharge^4*hold
			local release=areaTime>=AREA_TIMING.Discharge and math.max(0,1-(areaTime-AREA_TIMING.Discharge)/0.22) or 0
			-- Curl inward and contain the energy; the arms never swing overhead.
			pose("Torso",-58*tension+tremor+4*release,0,tremor*0.4)
			pose("Head",-10*tension-2*release,0,0)
			pose("Jaw",0,0,0)
			for _,side in ipairs({"Left","Right"}) do
				local sign=side=="Left" and -1 or 1
				-- Counter the forward torso curl: positive arm pitch brings the fists forward.
				pose(side.."UpperArm",80*tension,sign*10*tension,-sign*18*tension)
				pose(side.."Forearm",60*tension+tremor,0,0)
				pose(side.."Hand",-12*tension,sign*8*tension,0)
			end
			-- Right foot forward; left leg trails with a low knee and left hand supporting.
			solveLeg("Right",-3.5*tension*scale,0,actualBob)
			solveLeg("Left",4.0*tension*scale,0,actualBob)
			braceLeftHand(area.Ground,actualBob,tension)
			for i=1,tailCount do
				local curl=(i==1 and 15 or 20)*tension
				pose("Tail"..i,-curl,0,0)
			end
			for p,color in pairs(area.Colors) do
				local charged=focusColor:Lerp(Color3.fromRGB(220,255,255),release*0.7)
				p.Color=color:Lerp(charged,tension)
			end
			model:SetAttribute("AreaPhase",areaTime<AREA_TIMING.Discharge and "Charging" or areaTime<AREA_TIMING.Recovery and "Discharge" or "Recovery")
			if areaTime>=AREA_TIMING.Discharge and not area.Hit then
				area.Hit=true
				if area.ChargeSound then area.ChargeSound:Destroy() end
				if feedbackRemote then feedbackRemote:FireClient(owner,"Discharge") end
				combat.AreaImpact(area.Point)
			end
		end
		if hitReaction then
			local age=os.clock()-hitReaction.Started
			local duration=hitReaction.Heavy and 0.85 or 0.32
			local weight=math.sin(math.pi*math.clamp(age/duration,0,1))*(1-age/duration)
			if age>=duration then
				hitReaction=nil;damageFlash.FillTransparency=1;model:SetAttribute("ReactionState","Idle")
			else
				damageFlash.FillTransparency=1-0.65*math.max(0,1-age/0.22)
				local strength=hitReaction.Heavy and 20 or 7
				motors.Torso.C0=motors.Torso.C0*CFrame.Angles(math.rad(strength*weight),0,math.rad(hitReaction.Side*strength*0.35*weight))
				motors.Head.C0=motors.Head.C0*CFrame.Angles(math.rad(-strength*0.6*weight),0,0)
				if hitReaction.Heavy then
					if jump.Phase=="Idle" and humanoid.FloorMaterial~=Enum.Material.Air then
						local step=smooth(age/0.22)*(1-smooth((age-0.4)/0.25))
						local lift=age<0.22 and math.sin(math.pi*age/0.22)^2*0.9 or 0
						local catchSide=hitReaction.Side>0 and "Right" or "Left"
						solveLeg(catchSide,2.8*step*scale,lift*scale,actualBob)
					end
					for _,side in ipairs({"Left","Right"}) do
						motors[side.."UpperArm"].C0=motors[side.."UpperArm"].C0*CFrame.Angles(math.rad(55*weight),0,0)
						motors[side.."Forearm"].C0=motors[side.."Forearm"].C0*CFrame.Angles(math.rad(35*weight),0,0)
					end
				end
			end
		end
		-- Preserve the intended chest/head aim while the hips turn underneath.
		local torso=motors.Torso.C0
		motors.Torso.C0=CFrame.new(torso.Position)*pelvisTurn:Inverse()*torso.Rotation
		-- Blend mode changes and step accents rather than snapping joint poses.
		local enteringMotion=transitionLeft>0 and (mode=="Walk" or mode=="Run" or mode=="Attack")
		local motionBlend=enteringMotion and 1-math.exp(-poseDt/0.14) or blend
		for name, m in pairs(motors) do m.C0 = previous[name]:Lerp(m.C0, motionBlend) end
		if area then
			local intensity=areaCharge*(1-areaRecover)
			local discharge=areaTime>=AREA_TIMING.Discharge
			local envelope=discharge and math.max(0,1-(areaTime-AREA_TIMING.Discharge)/0.25) or intensity
			for i,node in ipairs(area.Nodes) do
				local pulse=1+0.12*math.sin(areaTime*(12+intensity*22)+i)
				local size=(0.15+1.4*intensity*intensity)*scale*pulse
				node.Orb.Size=Vector3.new(size,size,size)
				node.Orb.Transparency=1-0.85*envelope
				node.Light.Brightness=2.5*envelope
			end
			for i,arc in ipairs(area.Arcs) do
				local first,last=arc.First.WorldPosition,arc.Last.WorldPosition
				local flicker=math.sin(areaTime*(22+intensity*35)+i*2.3)
				local active=envelope>0.15 and flicker>0.6-intensity*1.2 and (last-first).Magnitude<14*scale
				for j,p in ipairs(arc.Points) do
					local jitter=Vector3.new(math.sin(areaTime*71+i+j),math.cos(areaTime*57+i-j),math.sin(areaTime*49+j))*0.55*scale*intensity
					p.CFrame=CFrame.new(first:Lerp(last,j/3)+jitter)
				end
				for _,beam in ipairs(arc.Beams) do
					beam.Enabled=active;beam.Width0=(0.04+0.14*intensity)*scale;beam.Width1=beam.Width0
				end
			end
		end
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
	print(string.format("[Kaiju Rig] %d parts | %d joints | Walk preview | AnimationMode: Walk / Idle | IdleEnabled=false pauses both", #visuals, 18 + tailCount))
	return {Stop = stop, Motors = motors, RequestAttack = requestAttack, RequestJump = requestJump, SetAirDirection=setAirDirection,RequestFocus=requestFocus,RequestArea=requestArea,SetRunning=setRunning}
end

return Rig
