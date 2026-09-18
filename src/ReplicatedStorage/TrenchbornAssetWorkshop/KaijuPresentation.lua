-- Shared client presentation. Preserves the approved procedural poses and Kaiju FX.
-- Receives server states and writes only local transforms/cosmetics.
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local POSE_TAG = "TrenchbornProceduralJoint"
local Combo = require(script.Parent:WaitForChild("KaijuStageOneCombo"))
local Jump = require(script.Parent:WaitForChild("KaijuStageOneJump"))
local Triumph = require(script.Parent:WaitForChild("KaijuCityBreakTriumph"))
local Rig = {}
local STRIDE = 12.0
local STANCE = 0.62 -- Longer swing; both feet still support the body during 24% of the cycle.
local RUN_SPEED = 16
local WALK_SPEED = 10
local RUN_STRIDE, RUN_STANCE = 11, 0.48
local CYCLE_SECONDS = 1.9
local AREA_TIMING={Curl=2.2,Discharge=2.8,Recovery=3.2,Finish=4.6}

-- Replication can deliver the model/tag before its skeleton descendants.
-- Check without creating effects or connections, so incomplete arrivals are retryable.
function Rig.IsReady(model, movementRoot)
 local folder=model:FindFirstChild("Articulation")
 local tailCount=model:GetAttribute("KaijuRigTailCount")
 local visualCount=model:GetAttribute("KaijuRigVisualCount")
 if not folder or not tailCount or not visualCount then return false,"rig metadata" end
 local names={"Pelvis","Torso","Head","Jaw","TailBase"}
 for _,side in ipairs({"Left","Right"}) do
  for _,region in ipairs({"UpperArm","Forearm","Hand","Thigh","Shin","Hock","Foot"}) do
   table.insert(names,side..region)
  end
 end
 for i=1,tailCount do table.insert(names,"Tail"..i) end
 for _,name in ipairs(names) do
  local bone=folder:FindFirstChild(name)
  if not bone or not bone:IsA("BasePart") or not bone:GetAttribute("RigRestFrame") then return false,name end
  if name~="Pelvis" then
   local joint=folder:FindFirstChild(name.."Joint",true)
   if not joint or not joint.Part0 or joint.Part1~=bone then return false,name.."Joint" end
  end
 end
 if model:GetAttribute("KaijuHasMovementRoot") then
  local joint=folder:FindFirstChild("KaijuLocomotionRoot")
  if not movementRoot or not joint or joint.Part0~=movementRoot or joint.Part1~=folder:FindFirstChild("Pelvis") then
   return false,"KaijuLocomotionRoot"
  end
 end
 local count=0
 for _,part in ipairs(model:GetChildren()) do
  if part:IsA("BasePart") then
   if not part:GetAttribute("RigRegion") or not part:GetAttribute("RigLocalFrame") then return false,part.Name end
   count=count+1
  end
 end
 if count<visualCount then return false,"visual parts" end
 return true
end

function Rig.Attach(model, movementRoot, humanoid, options)
 assert(RunService:IsClient(),"Presentation is client-only")
 local ready,missing=Rig.IsReady(model,movementRoot)
 assert(ready,"Incomplete replicated rig: "..tostring(missing))
 options=options or {}
 -- Status attributes belong to the server; retained pose annotations stay local.
 local function presentationAttribute() end
 local state={};local interval=1/30;local fxEnabled=true
 local clock=function() return workspace:GetServerTimeNow() end
 -- The renderer can observe controls but can never mutate gameplay physics.
 local function readOnly(instance)
  if not instance then return nil end
  local noOp=function() end
  local blocked={Move=true,ChangeState=true,SetStateEnabled=true,ApplyImpulse=true}
  return setmetatable({}, {__index=function(_,key)
   if blocked[key] then return noOp end
   local value=instance[key]
   if type(value)=="function" then return function(_,...) return value(instance,...) end end
   return value
  end,__newindex=function() end})
 end
 movementRoot=readOnly(movementRoot);humanoid=readOnly(humanoid)
 local combat={Cancel=function() end,Handle=function() return false end,AreaImpact=function() end,
  SelectFocusTarget=function() return true end,
  FocusAim=function() return model:GetAttribute("KaijuFocusPoint"),model:GetAttribute("KaijuFocusVisible")==true end}
 local stage=model:GetAttribute("EvolutionStage")
 local folder=assert(model:FindFirstChild("Articulation"),"Missing static skeleton")
 local effectsFolder=Instance.new("Folder");effectsFolder.Name="LocalKaijuEffects";effectsFolder.Parent=model
 local function get(name) return assert(model:FindFirstChild(name),"Missing rig source: "..name) end
 local visuals,corpseGeometry={},{}
 local bones,motors,rest={},{},{}
 local ownedJoints={}
 local function poseJoint(joint)
  local proxy={Real=joint,C0=joint.C0,Part0=joint.Part0,Part1=joint.Part1,Inverse=joint.C0:Inverse()}
  table.insert(ownedJoints,proxy);return proxy
 end
 for _,bone in ipairs(folder:GetChildren()) do
  if bone:IsA("BasePart") then bones[bone.Name]=bone end
 end
 for name,bone in pairs(bones) do
  if name~="Pelvis" then
   local joint=assert(folder:FindFirstChild(name.."Joint",true),"Missing joint "..name)
   motors[name]=poseJoint(joint);rest[name]=joint.C0
  end
 end
 local rootMotor=folder:FindFirstChild("KaijuLocomotionRoot")
 local rootJoint=rootMotor and poseJoint(rootMotor)
 local rootOffset=rootJoint and rootJoint.C0
 local rootRest=movementRoot and movementRoot.CFrame*rootOffset or bones.Pelvis.CFrame
 local sailView
 local sailRef=model:FindFirstChild("KaijuSailRenderer")
 if sailRef and sailRef.Value then
  local function anchorFrame(attachment)
   return attachment.WorldCFrame
  end
  sailView=require(sailRef.Value).Attach(model,effectsFolder,anchorFrame)
 end
 local tailCount=0
 while bones["Tail"..(tailCount+1)] do tailCount=tailCount+1 end
 for _,part in ipairs(model:GetChildren()) do
  if part:IsA("BasePart") then
   table.insert(visuals,part)
   table.insert(corpseGeometry,{Part=part,Bone=part:GetAttribute("RigRegion"),Local=part:GetAttribute("RigLocalFrame")})
  end
 end
	local armorEnergy={}
	for _,p in ipairs(visuals) do
		if p:GetAttribute("KaijuArmorEnergy") then table.insert(armorEnergy,p) end
	end
	-- Special attacks share one palette across neon parts and surface veins.
	-- Only emissive GUI strokes are tagged; the dark fissure lips stay dark.
	local specialEnergy={}
	for _,p in ipairs(visuals) do
		if string.match(p.Name,"^DorsalEnergy_") or p:GetAttribute("KaijuArmorEnergy") then
			table.insert(specialEnergy,p)
		end
	end
	for _,p in ipairs(model:GetDescendants()) do
		if p:IsA("GuiObject") and p:GetAttribute("KaijuArmorEnergy") then
			table.insert(specialEnergy,p)
		end
	end
	local function energyColor(p)
		return p:IsA("GuiObject") and p.BackgroundColor3 or p.Color
	end
	local function setEnergyColor(p,color)
		if not p.Parent then return end
		if p:IsA("GuiObject") then p.BackgroundColor3=color else p.Color=color end
	end
	local scale = model:GetScale()
	-- Shared focus visual mass; gameplay reach/damage and pulse travel stay unchanged.
	local focusCoreWidth = 1.30
	local focusOuterWidth = 3.10
	local focusPulseScale = 1.90
	local focusImpactScale = 1.80
	local focusChargeScale = 1.25
	-- Supplemental support is animation-only: never snap or propel the character.
	local supportParams=RaycastParams.new()
	supportParams.FilterType=Enum.RaycastFilterType.Exclude
	supportParams.FilterDescendantsInstances={movementRoot and movementRoot.Parent or model}
	supportParams.RespectCanCollide=true
	local function hasWalkSupport()
		if not movementRoot or not humanoid then return false end
		local state=humanoid:GetState()
		if state==Enum.HumanoidStateType.Swimming or state==Enum.HumanoidStateType.Climbing
			or state==Enum.HumanoidStateType.Jumping then return false end
		if humanoid.FloorMaterial~=Enum.Material.Air then return true end
		local reach=humanoid.HipHeight+movementRoot.Size.Y/2+0.65
		local hit=workspace:Raycast(movementRoot.Position,Vector3.new(0,-reach,0),supportParams)
		return hit~=nil and hit.Normal.Y>=math.cos(math.rad(math.min(humanoid.MaxSlopeAngle,60)))
	end
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
	local stepClearance={}
	local footPivots={}
	for _, side in ipairs({"Left", "Right"}) do
		local hip = bones[side.."Thigh"]:GetAttribute("RigRestFrame").Position
		local knee = bones[side.."Shin"]:GetAttribute("RigRestFrame").Position
		local hock = bones[side.."Hock"]:GetAttribute("RigRestFrame").Position
		local a, b = knee - hip, hock - knee
		local footFrame=rootRest*bones[side.."Foot"]:GetAttribute("RigRestFrame")
		local sole=get(side.."ForefootCoreY")
		local solePoint=footFrame:PointToObjectSpace((footFrame*sole:GetAttribute("RigLocalFrame")):PointToWorldSpace(Vector3.new(0,-sole.Size.Y/2,0)))
		local front,back=math.huge,-math.huge
		for _,part in ipairs(visuals) do
			if part:GetAttribute("RigRegion")==side.."Foot" then
				for _,x in ipairs({-1,1}) do for _,y in ipairs({-1,1}) do for _,z in ipairs({-1,1}) do
					local point=footFrame:PointToObjectSpace((footFrame*part:GetAttribute("RigLocalFrame")):PointToWorldSpace(Vector3.new(x*part.Size.X/2,y*part.Size.Y/2,z*part.Size.Z/2)))
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

	-- Reuse the workshop's existing Guardian/Sovereign audio assets, with heavier tuning.
	local audioPresets={
		Step={113663232024295,0.6,0.62},RunStep={113663232024295,0.7,0.69},
		Land={113663232024295,1.0,0.68},Whoosh={140192907374090,0.9,1.0},JumpWhoosh={140192907374090,0.28,1.2},Punch={97522871949213,0.5,1.15},Slam={97522871949213,0.65,1.0},
		Finisher={71814605717939,0.7,1.0},Hit={9116684884,0.3,0.7},HeavyHit={9116684884,0.55,0.52},
		Discharge={1040136448,2.0,1.0},
		Defeat={9116684884,0.75,0.42},
		VictoryRoar={71814605717939,1.15,0.46},
	}
	local audioRandom=Random.new()
	local activeSounds={}
	local function makeSound(asset,source,volume,speed,looped,startAt)
		if not fxEnabled then return nil end
		local sound=Instance.new("Sound");sound.Name="KaijuAudio";sound.SoundId="rbxassetid://"..asset
		sound.Volume=volume;sound.PlaybackSpeed=speed;sound.Looped=looped==true
		sound.RollOffMinDistance=12*scale;sound.RollOffMaxDistance=160*scale
		sound.Parent=source or bones.Torso;activeSounds[sound]=true
		sound.Destroying:Once(function() activeSounds[sound]=nil end)
		sound.TimePosition=startAt or 0
		sound:Play()
		if not looped then game:GetService("Debris"):AddItem(sound,5) end
		return sound
	end
	local function feedback(kind,source,soundOnly)
		local definition=audioPresets[kind]
		if not definition then return end
		local sound=makeSound(definition[1],source,definition[2],definition[3]*audioRandom:NextNumber(0.96,1.04),false,kind=="Punch" and 0.12 or 0)
		if sound and (kind=="Whoosh" or kind=="Punch" or kind=="Slam" or kind=="Finisher") then
			sound.RollOffMinDistance=45*scale
		end
		if sound and kind=="Discharge" then
			local bass=Instance.new("EqualizerSoundEffect")
			bass.LowGain=8;bass.MidGain=1;bass.HighGain=-1;bass.Parent=sound
			sound.RollOffMinDistance=45*scale
		end
		if sound and kind=="VictoryRoar" then
			local eq=Instance.new("EqualizerSoundEffect")
			eq.LowGain=10;eq.MidGain=-2;eq.HighGain=-14;eq.Parent=sound
			local distortion=Instance.new("DistortionSoundEffect")
			distortion.Level=0.18;distortion.Parent=sound
			sound.RollOffMinDistance=65*scale;sound.RollOffMaxDistance=280*scale
		end
		if sound and kind~="FocusFire" and kind~="Discharge" and kind~="JumpWhoosh" and kind~="Whoosh" and kind~="Punch" and kind~="Slam" and kind~="Finisher" and kind~="VictoryRoar" then
			local eq=Instance.new("EqualizerSoundEffect");local step=kind=="Step" or kind=="RunStep"
			eq.LowGain=step and 9 or kind=="Land" and 6 or 3;eq.MidGain=step and -10 or -3;eq.HighGain=step and -22 or -12;eq.Parent=sound
			if step then
				local volume=sound.Volume;sound.Volume=0
				game:GetService("TweenService"):Create(sound,TweenInfo.new(0.06),{Volume=volume}):Play()
			end
			game:GetService("Debris"):AddItem(sound,(kind=="Step" or kind=="RunStep") and 1.6 or 2.4)
		end
		-- Owner feedback is emitted separately by the authoritative controller.
	end
	presentationAttribute("RunRequested",false)
	presentationAttribute("Running",false)
	local function setRunning(enabled)
		if type(enabled)~="boolean" or stopped or not humanoid or humanoid.Health<=0 then return false end
		runRequested=enabled;presentationAttribute("RunRequested",enabled)
		return true
	end
	local function runFootfall(side,force)
		if not fxEnabled then return end
		local impact=force or 1
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
			dust.Size=Vector3.new(1,0.5,1)*scale*impact;dust.Transparency=0.5
			dust.Position=hit.Position+Vector3.new(0,0.2*scale,0);dust.Parent=effectsFolder
			local spread=Vector3.new(math.cos(i*2.4)*2,0.7,math.sin(i*2.4)*2)*scale*impact
			game:GetService("TweenService"):Create(dust,TweenInfo.new(0.35),
				{Position=dust.Position+spread,Size=Vector3.new(2,1.2,2)*scale*impact,Transparency=1}):Play()
			game:GetService("Debris"):AddItem(dust,0.4)
		end
	end
	local heartbeat, destroying, healthConnection, poseConnection, sailConnection
	-- ownedJoints initialized with immutable rest-frame proxies above.
	local combo = Combo.new(combat and combat.PrepareFinisher,stage)
	local jump = Jump.new()
	local swimState=Enum.HumanoidStateType.Swimming
	local swimEnabled=humanoid and humanoid:GetStateEnabled(swimState)
	if humanoid then humanoid:SetStateEnabled(swimState,true) end
	local hitReaction,defeat,victory=nil,nil,nil
	local strikeResistance=nil
	local hitSide=1
	local damageFlash=Instance.new("Highlight")
	damageFlash.Name="DamageFeedback";damageFlash.Adornee=model;damageFlash.FillColor=Color3.fromRGB(255,65,45)
	damageFlash.FillTransparency=1;damageFlash.OutlineTransparency=1;damageFlash.Parent=model
	local function isStaggered()
		return hitReaction and hitReaction.Heavy and clock()-hitReaction.Started<0.65
	end
	local focus,focusReadyAt=nil,0
	local area,areaReadyAt=nil,0
	local specialLock
 local function holdSpecial() end
 local function beginSpecial(kind)
  specialLock=kind;hitReaction=nil;strikeResistance=nil
  wasWalking=false;stopAge=nil;runBlend=0;walkFeet={};lastWalkUpper={}
 end
 local function releaseSpecial() specialLock=nil end
	local focusColor=Color3.fromRGB(65,225,255)
 local function stageFiveCharge(p,base,time,fade)
  local index=tonumber(p.Name:match("^DorsalEnergy_(%d+)"))
  local onset
  if index then onset=(11-index)/10*1.15
  elseif p:GetAttribute("RigRegion")=="Head" or p.Name:find("Brow",1,true) then onset=1.65
  elseif p.Name=="Stage5ChestCore" then onset=1.48
  else onset=1.30 end
  local progress=math.clamp((time-onset)/0.28,0,1)
  local crest=math.max(0,1-math.abs((time-onset-0.20)/0.20))*0.55
  local charged=focusColor:Lerp(Color3.fromRGB(220,255,255),crest)
  return base:Lerp(charged,progress*fade)
 end
	local palmRest={}
	for _,side in ipairs({"Left","Right"}) do
		local palm=get(side.."PalmCoreZ")
		palmRest[side]={Local=palm:GetAttribute("RigLocalFrame"),Thickness=palm.Size.Z}
	end
	local supportPalmNormal=get("LeftPalmCoreZ"):GetAttribute("RigLocalFrame").LookVector
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
	local function emitArea(origin)
  if not fxEnabled or type(model:GetAttribute("KaijuAreaVisualRadius"))~="number" then return end
  local TweenService=game:GetService("TweenService")
  local Debris=game:GetService("Debris")
  local function part(parent,name,size,cf,color)
   local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
   p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent;return p
  end
		local cyan=Color3.fromRGB(65,225,255)
		local radius=model:GetAttribute("KaijuAreaVisualRadius")
		local diameter=radius*2
		-- The discharge starts visibly at the large dorsal plates, then hits the ground.
		for i=1,3 do
			local plate=model:FindFirstChild(string.format("DorsalShield_%02d",i))
			if plate and plate:IsA("BasePart") then
				local spark=part(effectsFolder,"DorsalDischarge",Vector3.new(1,1,1)*(radius*0.08),CFrame.new(plate.Position),cyan)
				spark.Shape=Enum.PartType.Ball;spark.Material=Enum.Material.Neon
				spark.Transparency=0.3
				spark.CanCollide=false;spark.CanTouch=false;spark.CanQuery=false;spark.CastShadow=false
				local light=Instance.new("PointLight")
				light.Color=cyan;light.Brightness=4;light.Range=math.min(60,radius*1.25);light.Parent=spark
				-- Each pressure sphere reaches the attack's full diameter. Center the
				-- expanded volume over the impact so its horizontal reach matches damage.
				local expansion=0.45+i*0.04
				TweenService:Create(spark,TweenInfo.new(expansion,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
					{Size=Vector3.new(diameter,diameter,diameter),
						CFrame=CFrame.new(origin+Vector3.new(0,radius*0.2,0)),Transparency=0.65}):Play()
				task.delay(expansion,function()
					if not spark.Parent then return end
					TweenService:Create(spark,TweenInfo.new(0.25),{Transparency=1}):Play()
				end)
				TweenService:Create(light,TweenInfo.new(expansion+0.25),{Brightness=0}):Play()
				Debris:AddItem(spark,expansion+0.3)
			end
		end
		local burst=part(effectsFolder,"AreaGroundFlash",Vector3.new(3,0.25,3)*scale,CFrame.new(origin),cyan)
		burst.Shape=Enum.PartType.Ball;burst.Material=Enum.Material.Neon
		burst.CanCollide=false;burst.CanTouch=false;burst.CanQuery=false;burst.CastShadow=false
		TweenService:Create(burst,TweenInfo.new(0.35),{Size=Vector3.new(diameter,0.3*scale,diameter),Transparency=1}):Play()
		Debris:AddItem(burst,0.4)
		for i=1,28 do
			local angle=i*2.39996
			local direction=Vector3.new(math.cos(angle),0,math.sin(angle))
			local start=origin+direction*(4+i%6)*scale
			local rock=part(effectsFolder,"AreaDebris",Vector3.new(1.8+i%3*0.8,1.5+i%2*0.6,2.4)*scale,CFrame.new(start),Color3.fromRGB(90,95,102))
			rock.CanCollide=false;rock.CanTouch=false;rock.CanQuery=false
			local peak=start+(direction*(5+i%6)+Vector3.new(0,7+i%5,0))*scale
			TweenService:Create(rock,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
				{CFrame=CFrame.new(peak)*CFrame.Angles(i,0,i*0.4)}):Play()
			task.delay(0.3,function()
				if not rock.Parent then return end
				TweenService:Create(rock,TweenInfo.new(0.6,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
					{CFrame=CFrame.new(peak+direction*4*scale-Vector3.new(0,11,0)*scale),Transparency=1}):Play()
			end)
			Debris:AddItem(rock,1)
		end
	end
	local function endArea()
		if not area then return end
		if area.ChargeSound then area.ChargeSound:Destroy() end
		for p,color in pairs(area.Colors) do setEnergyColor(p,color) end
		for _,a in ipairs(area.Attachments) do a:Destroy() end
		area.Effects:Destroy()
		releaseSpecial()
		area=nil;presentationAttribute("AreaPhase","Idle")
	end
	local function requestArea()
  if area or not state.AreaPoint then return false end
  local hit={Position=Vector3.new(table.unpack(state.AreaPoint))}
		combo:Cancel();combat.Cancel()
		area={Started=clock(),Hit=false,Point=hit.Position,StartRoot=movementRoot.Position,
			Ground=CFrame.new(hit.Position)*CFrame.new(table.unpack(state.AreaRotation)),
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
		for _,p in ipairs(specialEnergy) do
			if p.Parent then area.Colors[p]=energyColor(p) end
		end
		areaReadyAt=clock()+4 -- Provisional workshop cooldown, starting at activation.
		beginSpecial("Area")
		presentationAttribute("AreaPhase","Charging")
		return true
	end
	local function endFocus()
		if not focus then return end
		if focus.ChargeSound then focus.ChargeSound:Destroy() end
		if focus.BeamSound then focus.BeamSound:Destroy() end
		for part,color in pairs(focus.Colors) do setEnergyColor(part,color) end
		focus.Mouth:Destroy()
		focus.Effects:Destroy()
		releaseSpecial()
		focus=nil
		focusReadyAt=clock()+1
		presentationAttribute("FocusPhase","Idle")
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
  if focus then return false end
  local target=true
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
		focus={Started=clock(),Ticks=0,Target=target,Speed=humanoid.WalkSpeed,Rotate=humanoid.AutoRotate,
			Effects=effects,Colors={},Orb=effect("Charge",Enum.PartType.Ball,focusColor),
			Impact=effect("Impact",Enum.PartType.Ball,focusColor)}
		local upper,offset=mouthFrame()
		local mouth=Instance.new("Attachment")
		mouth.Name="FocusMouth";mouth.CFrame=offset;mouth.Parent=upper
		focus.Mouth=mouth
		focus.ChargeSound=makeSound(1336756135,mouth,0.28,0.82,false)
		if focus.ChargeSound then focus.ChargeSound.RollOffMinDistance=40*scale end
		if focus.ChargeSound then game:GetService("TweenService"):Create(focus.ChargeSound,TweenInfo.new(1.8),{Volume=0.85,PlaybackSpeed=1.1}):Play() end
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
			pulse.CFrame=CFrame.lookAt(from,to);pulse.Size=Vector3.new(1,1,1)*1.65*scale*focusPulseScale
			pulse.Transparency=0.15
			local left=Instance.new("Attachment");left.Position=Vector3.new(-0.65*scale*focusPulseScale,0,0);left.Parent=pulse
			local right=Instance.new("Attachment");right.Position=Vector3.new(0.65*scale*focusPulseScale,0,0);right.Parent=pulse
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
		for _,p in ipairs(specialEnergy) do
			if p.Parent then focus.Colors[p]=energyColor(p) end
		end
		beginSpecial("Focus")
		presentationAttribute("FocusPhase","Charging")
		return true
	end
 local landingBlend=1
 local bufferedJumpUntil=0
 local function restoreJump() end

	local function emitVictoryShockwave()
		if not fxEnabled or not movementRoot then return end
		local TweenService=game:GetService("TweenService")
		local Debris=game:GetService("Debris")
		local origin=movementRoot.Position-Vector3.new(0,math.max(0,humanoid and humanoid.HipHeight or 0),0)

		for ringIndex=1,2 do
			local ring=Instance.new("Part")
			ring.Name="VictoryRoarShockwave"
			ring.Shape=Enum.PartType.Cylinder
			ring.Size=Vector3.new(0.22*scale,4*scale,4*scale)
			ring.CFrame=CFrame.new(origin+Vector3.new(0,0.28*scale,0))*CFrame.Angles(0,0,math.rad(90))
			ring.Color=Color3.fromRGB(220,245,205)
			ring.Material=Enum.Material.Neon
			ring.Transparency=0.62
			ring.Anchored=true;ring.CanCollide=false;ring.CanTouch=false;ring.CanQuery=false;ring.CastShadow=false
			ring.Parent=effectsFolder
			local delay=(ringIndex-1)*0.08
			task.delay(delay,function()
				if not ring.Parent then return end
				TweenService:Create(ring,TweenInfo.new(0.68,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
					Size=Vector3.new(0.10*scale,(34+ringIndex*10)*scale,(34+ringIndex*10)*scale),
					Transparency=1,
				}):Play()
			end)
			Debris:AddItem(ring,0.9)
		end

		for i=1,12 do
			local dust=Instance.new("Part")
			dust.Name="VictoryRoarDust";dust.Shape=Enum.PartType.Ball
			dust.Size=Vector3.new(1.4,0.55,1.4)*scale
			dust.Position=origin+Vector3.new(0,0.35*scale,0)
			dust.Color=Color3.fromRGB(105,100,88);dust.Material=Enum.Material.SmoothPlastic
			dust.Transparency=0.45;dust.Anchored=true;dust.CanCollide=false;dust.CanTouch=false;dust.CanQuery=false;dust.CastShadow=false
			dust.Parent=effectsFolder
			local angle=(i/12)*math.pi*2
			local outward=Vector3.new(math.cos(angle)*(7+i%3),0.7+0.15*(i%2),math.sin(angle)*(7+i%3))*scale
			TweenService:Create(dust,TweenInfo.new(0.72,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
				Position=dust.Position+outward,
				Size=Vector3.new(3.2,1.3,3.2)*scale,
				Transparency=1,
			}):Play()
			Debris:AddItem(dust,0.8)
		end
	end

	local function endVictoryView()
		if not victory then return end
		for p,color in pairs(victory.Colors or {}) do
			if p.Parent then setEnergyColor(p,color) end
		end
		victory=nil
		releaseSpecial()
		presentationAttribute("VictoryState","Idle")
	end

	local function startVictory(started)
		endArea();endFocus();jump:Cancel();combo:Cancel();hitReaction=nil;strikeResistance=nil
		if victory then endVictoryView() end
		victory={Started=started,Colors={},RoarPlayed=false,ShockwavePlayed=false}
		for _,p in ipairs(specialEnergy) do
			if p.Parent then victory.Colors[p]=energyColor(p) end
		end
		beginSpecial("Victory")
		presentationAttribute("VictoryState","Playing")
		presentationAttribute("AnimationPreview","CityBreakTriumph")
	end

	local function reset()
		strikeResistance=nil
		endVictoryView()
		hitReaction=nil;damageFlash.FillTransparency=1
		for sound in pairs(activeSounds) do sound:Destroy() end
		soundContacts={}
		endArea()
		endFocus()
		jump:Cancel()
		restoreJump()
		combo:Cancel()
		if combat then combat.Cancel() end
		presentationAttribute("ComboStep", 0)
		presentationAttribute("AttackName", "")
		for name, m in pairs(motors) do m.C0 = rest[name] end
		if rootJoint then rootJoint.C0 = rootOffset else bones.Pelvis.CFrame = rootRest end
		smoothedBob, walkCycle = 0, 0
		hipYaw,hipRoll=0,0;pelvisTurn=CFrame.identity
		wasWalking,stopAge=false,nil;walkFeet,lastWalkUpper={},{}
		previousMode,transitionLeft="Idle",0
		runRequested,runBlend=false,0;runContacts={}
		presentationAttribute("RunRequested",false);presentationAttribute("Running",false)
		if humanoid then humanoid.WalkSpeed=WALK_SPEED end
	end
	local function stop()
		if stopped then return end
		stopped = true
		if heartbeat then heartbeat:Disconnect() end
		if destroying then destroying:Disconnect() end
		if healthConnection then healthConnection:Disconnect() end
		if poseConnection then poseConnection:Disconnect() end
  if sailConnection then sailConnection:Disconnect() end
  if sailView then sailView.Destroy() end
		for _, joint in ipairs(ownedJoints) do
			if joint.Real.Parent then joint.Real.Transform=CFrame.identity end
		end
		reset()
  if defeat then
   for _,glow in ipairs(defeat.Glow) do if glow.Part.Parent then glow.Part.Color=glow.Color;glow.Part.Material=Enum.Material.Neon end end
   for _,light in ipairs(defeat.Lights) do if light.Part.Parent then light.Part.Brightness=light.Brightness end end
  end
		if humanoid then humanoid:SetStateEnabled(swimState,swimEnabled) end
		damageFlash:Destroy()
		effectsFolder:Destroy()
	end
	local function smooth(value)
		local t=math.clamp(value,0,1);return t*t*(3-2*t)
	end
	local function updateDefeat(dt)
		local t=clock()-defeat.Started
		local catchUp=defeat.CatchUp;defeat.CatchUp=false
		local kneel=smooth(t/0.45)
		local fall=smooth((t-0.25)/1.55)
		local settle=smooth((t-1.8)/0.8)
		local function fallen(name,x,y,z)
			local target=rest[name]*CFrame.Angles(math.rad(x),math.rad(y),math.rad(z))
			motors[name].C0=motors[name].C0:Lerp(target,catchUp and 1 or 1-math.exp(-dt/0.09))
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
			-- Preserve the approved forward fall arc.
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
			-- Transport the falling arm's orientation into the ground-contact pose.
			-- Solving directly from the rest vector loses axial roll near 180 degrees
			-- and makes the armor corkscrew inward even when joint positions are right.
			local upperReference=CFrame.Angles(math.rad(185*fall),0,math.rad(sign*30*fall))
			local upperTarget=shoulder:VectorToObjectSpace(elbow-shoulder.Position)
			local upperRotation=rotateBetween(upperReference:VectorToWorldSpace(a),upperTarget)*upperReference
			local elbowFrame=shoulder*upperRotation*rest[side.."Forearm"]
			local foreReference=rest[side.."Forearm"]:ToObjectSpace(motors[side.."Forearm"].C0).Rotation
			local foreTarget=elbowFrame:VectorToObjectSpace(wrist-elbow)
			local foreRotation=rotateBetween(foreReference:VectorToWorldSpace(b),foreTarget)*foreReference
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
				dust.Parent=effectsFolder
				local outward=Vector3.new(math.cos(i*2.4)*8,1.3,math.sin(i*2.4)*8)*scale
				game:GetService("TweenService"):Create(dust,TweenInfo.new(0.7),
					{Position=dust.Position+outward,Size=Vector3.new(5,2,5)*scale,Transparency=1}):Play()
				game:GetService("Debris"):AddItem(dust,0.75)
			end
		end
		-- Ground impact is at 1.8s, settling completes at 2.6s.
		-- Keep failing energy visible on the ground; eyes are the last to extinguish.
		local function remainingEnergy(isEye)
			local start=isEye and 4.0 or 3.0
			local envelope=1-smooth((t-start)/0.8)
			local phase=isEye and 0.85 or 0
			local signal=0.5+0.27*math.sin(t*19+phase)
				+0.15*math.sin(t*37+phase)+0.08*math.sin(t*11)
			local flicker=0.16+0.84*smooth(signal)
			local onset=smooth(t/0.3)
			return envelope*(1-onset+onset*flicker),envelope<=0
		end
		local bodyEnergy,bodyOff=remainingEnergy(false)
		local eyeEnergy,eyesOff=remainingEnergy(true)
		for _,glow in ipairs(defeat.Glow) do
			local energy=glow.Eye and eyeEnergy or bodyEnergy
			glow.Part.Color=Color3.fromRGB(25,32,40):Lerp(glow.Color,energy)
			if (glow.Eye and eyesOff) or (not glow.Eye and bodyOff) then
				glow.Part.Material=Enum.Material.SmoothPlastic
			end
		end
		for _,light in ipairs(defeat.Lights) do
			light.Part.Brightness=light.Brightness*(light.Eye and eyeEnergy or bodyEnergy)
		end
		damageFlash.FillTransparency=1-0.6*math.max(0,1-t/0.4)
		presentationAttribute("ReactionState",t<0.7 and "Buckling" or t<2.9 and "Falling" or "Defeated")
		-- Continue updates until the final eye flicker has fully faded.
		if t>=4.8 then defeat.Settled=true end
	end
 local function startDefeat(snapshot)
  endArea();endFocus();jump:Cancel();combo:Cancel();hitReaction=nil
  defeat={Started=snapshot.Started,Root=CFrame.new(table.unpack(snapshot.Root)),Ground=snapshot.Ground,CatchUp=clock()-snapshot.Started>0.25}
				defeat.Glow={};defeat.Lights={}
				for _,part in ipairs(model:GetDescendants()) do
					if part:IsA("BasePart") and part.Material==Enum.Material.Neon then
						table.insert(defeat.Glow,{Part=part,Color=part.Color,Eye=string.find(part.Name,"Eye")~=nil})
					elseif part:IsA("PointLight") or part:IsA("SpotLight") or part:IsA("SurfaceLight") then
						table.insert(defeat.Lights,{Part=part,Brightness=part.Brightness,Eye=string.find(part.Parent.Name,"Eye")~=nil})
					end
				end

 end
 -- Read the displayed attachment frames after physics has moved the root
 -- and applied Motor6D transforms; do not predict them before simulation.
 if sailView then
  sailConnection=RunService.PreRender:Connect(function() sailView.Update() end)
 end
 -- Apply after Animator, using the non-replicated animation layer.
 poseConnection=RunService.PreSimulation:Connect(function()
  for _,joint in ipairs(ownedJoints) do
   if joint.Real.Parent then joint.Real.Transform=joint.Inverse*joint.C0 end
  end
 end)
	local wasEnabled = true
	heartbeat = RunService.Heartbeat:Connect(function(dt)
		if not model:IsDescendantOf(workspace) then stop(); return end
		if defeat then
			accumulator=accumulator+dt
			if not defeat.Settled and accumulator>=interval then
				local defeatDt=accumulator;accumulator=0;updateDefeat(defeatDt)
			end
			return
		end
		if model:GetAttribute("IdleEnabled") == false and not specialLock then
			if wasEnabled then reset() end
			wasEnabled = false
			elapsed, accumulator = 0, 0
			return
		end
		wasEnabled = true
		elapsed, accumulator = elapsed + dt, accumulator + dt
		if accumulator < interval then return end
		local poseDt = accumulator
		accumulator = accumulator % interval
		local previous = {}
		for name, m in pairs(motors) do previous[name] = m.C0 end
		local fade = math.min(elapsed/1.5, 1)
		-- Only Stage 2 tagged veins pulse; attack color and defeat fading retain control.
		if not humanoid or humanoid.Health>0 then
			local pulse=0.5+0.5*math.sin(elapsed*math.pi/1.8)
			for _,p in ipairs(armorEnergy) do
				if p.Parent then p.Transparency=(focus or area) and 0.06 or 0.10+0.18*(1-pulse) end
			end
		end
		local breath = math.sin(elapsed * math.pi/1.4) * fade
		local sway = math.sin(elapsed * math.pi/2.7) * fade
		-- Smooth short accents: alternating shoulder tension and alert head turns.
		local leftAccent = math.max(0, math.sin(elapsed * 0.95))^8 * fade
		local rightAccent = math.max(0, math.sin(elapsed * 0.95 + 2.1))^8 * fade
		local alert = math.sin(elapsed * 1.7) * math.max(0, math.sin(elapsed * 0.63))^4 * fade
		local function pose(name, x, y, z)
			-- Desired local pose; flushed to Motor6D.Transform in PreSimulation.
			motors[name].C0 = rest[name] * CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
		end
		pose("Torso", 1.2 * fade + breath * 1.8, sway * 1.8, sway * 1.0)
		pose("Head", -breath * 1.1, -sway * 2.3 + alert * 4.5, -sway * 0.6)
		pose("Jaw", math.max(0, breath) * 1.8, 0, 0)
		for _, side in ipairs({"Left", "Right"}) do
			local sign = side == "Left" and -1 or 1
			local accent = side == "Left" and leftAccent or rightAccent
			pose(side .. "UpperArm", breath * 0.8 - accent, 0, -sign * (8 * fade - breath * 0.6))
			pose(side .. "Forearm", -breath * 0.7, 0, 0)
			-- Reduce the baked-in paw twist around the actual elbow-to-wrist axis.
			motors[side.."Hand"].C0=rest[side.."Hand"]
				*CFrame.fromAxisAngle(rest[side.."Hand"].Position.Unit,math.rad(sign*20*fade))
		end
		for i = 1, tailCount do
			pose("Tail" .. i, 0, (math.sin(elapsed * 1.35 - i * 0.48) * (0.55 + i*0.14)
				+ alert * 0.45) * fade, 0)
		end
		local walking = model:GetAttribute("AnimationMode") == "Walk"
		if focus and (humanoid.Health<=0 or clock()-focus.Started>=4.85) then endFocus() end
		local focusTime=focus and clock()-focus.Started
		if area and (humanoid.Health<=0 or clock()-area.Started>=AREA_TIMING.Finish) then endArea() end
		local areaTime=area and clock()-area.Started
		local victoryTime=victory and clock()-victory.Started
		local victorySample=victory and Triumph.Sample(victoryTime)
		local areaCharge,areaRecover=0,0
		if area then
			areaCharge=math.clamp(areaTime/AREA_TIMING.Curl,0,1)
			areaCharge=areaCharge*areaCharge*(3-2*areaCharge)
			areaRecover=math.clamp((areaTime-AREA_TIMING.Recovery)/(AREA_TIMING.Finish-AREA_TIMING.Recovery),0,1)
			areaRecover=areaRecover*areaRecover*(3-2*areaRecover)
		end
		if humanoid and humanoid.Health<=0 then jump:Cancel();restoreJump() end
		local swimming=not specialLock and humanoid and humanoid.Health>0 and humanoid:GetState()==swimState
		presentationAttribute("Swimming",swimming==true)
		if swimming then
			if jump.Phase~="Idle" then jump:Cancel();restoreJump() end
			if focus then endFocus() end
			if area then endArea() end
			combo:Cancel();strikeResistance=nil;bufferedJumpUntil=0
			if combat then combat.Cancel() end
			humanoid.WalkSpeed=12
		end
		local jumpPose,jumpEvent
		if movementRoot and humanoid and not swimming and not specialLock then
   jumpPose=jump:Update(clock(),humanoid.FloorMaterial~=Enum.Material.Air,movementRoot.AssemblyLinearVelocity.Y)

		end
		presentationAttribute("JumpPhase",jump.Phase)
		local speed = 0
		if movementRoot then
			local velocity = movementRoot.AssemblyLinearVelocity
			speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
			walking = speed > 0.5 and humanoid.Health > 0
				and hasWalkSupport()
		end
		local landing=jump.Phase=="Landing"
		local landingWeight=1
		if landing and humanoid.MoveDirection.Magnitude>0.05 then
			landingBlend=math.min(landingBlend,1-math.clamp((clock()-jump.Started)/0.24,0,1))
		end
		if landing then landingWeight=landingBlend end
		if swimming or (jumpPose and not landing) or isStaggered() or victory then walking=false end
		if focus then walking=false;humanoid:Move(Vector3.zero,false) end
		if area then walking=false;humanoid:Move(Vector3.zero,false) end
		if victory then walking=false;humanoid:Move(Vector3.zero,false) end
		local groundControl=not swimming and (jump.Phase=="Idle" or jump.Phase=="Landing" or jump.Phase=="Windup" or jump.Phase=="Air")
		local runAllowed=not isStaggered() and not focus and not area and not victory and groundControl
			and humanoid and humanoid.Health>0
		if humanoid and not focus and not area and groundControl and humanoid.Health>0 then
			humanoid.WalkSpeed=isStaggered() and 0 or runRequested and runAllowed and RUN_SPEED or WALK_SPEED
		end
		local running=walking and runRequested and runAllowed
		runBlend=runBlend+((running and 1 or 0)-runBlend)*(1-math.exp(-poseDt/0.22))
		presentationAttribute("Running",running==true)
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
		local attackPose, attackWeight, attackName, attackIndex, attackCrouch = combo:Sample(clock())
  for _,event in ipairs(combo:DrainEvents()) do
   if event.Kind=="Whoosh" then feedback("Whoosh",event.Index==1 and bones.LeftHand or bones.RightHand,true)
   elseif event.Kind=="TearSound" and clock()-combo.Started<0.4 then feedback("Finisher",bones.Torso,true) end
  end
		local special=victory or swimming or jumpPose or focus or area or attackPose or isStaggered()
		local mode=victory and "Victory" or area and "Area" or focus and "Focus" or jumpPose and "Jump" or attackPose and "Attack" or running and "Run" or walking and "Walk" or "Idle"
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
		if swimming then bob=0 end
		if jumpPose then bob=bob*(1-landingWeight)-jumpPose.Crouch*scale*landingWeight end
		if focus then
			local kick=focusTime>=2 and math.exp(-(focusTime-2)*9) or 0
			bob=-(1.7*math.min(focusTime/0.65,1)+0.65*kick)*scale*math.clamp((4.85-focusTime)/0.35,0,1)
		end
		if area then bob=-7.2*areaCharge*(1-areaRecover)*scale end
		if victorySample then bob=victorySample.Bob*scale end
		if isStaggered() then
			bob=bob-0.9*math.sin(math.pi*math.clamp((clock()-hitReaction.Started)/0.65,0,1))*scale
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
			presentationAttribute("AnimationPreview", running and "HeavyRun_01" or "HeavyWalk_05_LongWeightedStride")
			local weightShift = math.sin(gaitPhase - 0.35)*fade
			-- Forward is local -Z: negative X pitch brings the upper body forward.
			pose("Torso", (-16.0-18*runBlend - compression*(1.6+runBlend))*fade, weightShift*(5.5+2*runBlend), weightShift*4.8)
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
					-- Stage 4 lifts over small registered buildings instead of swinging
					-- through their roofs. Cache clearance for this swing, not per frame.
					local stepHeight=model:GetAttribute("StepOverHeight")
					local traversalHeight=model:GetAttribute("TraversalRootHeight")
					local footX=model:GetAttribute("Traversal"..side.."FootX")
					local footZ=model:GetAttribute("Traversal"..side.."FootZ")
					local turn=math.floor(cycle+offset+stance/2)
					if stepHeight and traversalHeight and footX and footZ and movementRoot and (not stepClearance[side] or stepClearance[side].Turn~=turn) then
						local clearance=0
						local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
						params.FilterDescendantsInstances={model.Parent,effectsFolder}
						local groundFrame=movementRoot.CFrame*CFrame.new(0,-traversalHeight,0)
						for _,ahead in ipairs({-stride/2,0,stride/2}) do
							local origin=groundFrame:PointToWorldSpace(Vector3.new(footX,
							 stepHeight+scale,footZ+ahead*scale))
							local hit=workspace:Raycast(origin,Vector3.new(0,-stepHeight-scale,0),params)
							local building=hit and hit.Instance:FindFirstAncestorOfClass("Model")
							if building and building:GetAttribute("MaxHealth") and not building:GetAttribute("Destroyed") then
								local _,size=building:GetBoundingBox()
								if size.Y<stepHeight then clearance=math.max(clearance,hit.Position.Y-groundFrame.Position.Y+scale) end
								end
						end
						stepClearance[side]={Turn=turn,Height=clearance/scale}
					end
					local smooth = swing*swing*(3-2*swing)
					travel = stride/2-stride*smooth
					-- Spend more of the swing lifting the heavy leg, then settle firmly.
					-- Both ends and the apex have zero vertical velocity.
					local liftPhase=swing<0.52 and swing/0.52 or (1-swing)/0.48
					lift = math.max(2.6+0.2*runBlend,stepHeight and stepClearance[side] and stepClearance[side].Height or 0)
					 *liftPhase*liftPhase*(3-2*liftPhase)
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
					-- Report the rendered sole contact only from its owning client.
					-- Server traversal validates timing/foot envelope and chooses targets.
					local remote=model:FindFirstChild("ReportFootfall")
					if remote and owner==game:GetService("Players").LocalPlayer then
						local sole=model:FindFirstChild(side.."ForefootCoreY")
						if sole then remote:FireServer(side,sole.CFrame:PointToWorldSpace(Vector3.new(0,-sole.Size.Y/2,0))) end
					end
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
				-- Use the opposite foot's actual travel, including its long planted phase.
				local opposite=(t+0.5)%1
				local forward
				if opposite<stance then
					forward=1-opposite/stance
				else
					local u=(opposite-stance)/(1-stance)
					forward=u*u*(3-2*u)
				end
				-- Positive shoulder pitch carries the hanging arm forward.
				-- Extend smoothly toward the forward endpoint, flex again on return.
				local extension=forward*forward*(3-2*forward)
				local armSwing=(2*forward-1)*fade
				pose(side.."UpperArm",(-12+52*forward)*(1+0.35*runBlend)*fade,
					sign*armSwing*3,-sign*6*fade)
				pose(side.."Forearm",((50+10*runBlend)-(42+8*runBlend)*extension)*fade,
					0,-sign*armSwing*2)
				pose(side.."Hand",(-4+4*extension)*fade,sign*armSwing*2,0)
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
			presentationAttribute("AnimationPreview", "PowerIdle_02")
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
		presentationAttribute("ComboStep", attackIndex or 0)
		presentationAttribute("AttackName", attackName or "")
		if attackPose then
			for name, angles in pairs(attackPose) do
				local target = rest[name] * CFrame.Angles(math.rad(angles[1]),math.rad(angles[2]),math.rad(angles[3]))
				motors[name].C0 = motors[name].C0:Lerp(target, attackWeight)
			end
		end
		if jumpPose then
			local locomotionPose={}
			if landing then
				for name,motor in pairs(motors) do locomotionPose[name]=motor.C0 end
			end
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
			for name,original in pairs(locomotionPose) do
				motors[name].C0=original:Lerp(motors[name].C0,landingWeight)
			end
		end
		if focus then
			local t=focusTime
			local charge=math.clamp(t/2,0,1)
			local firing=t>=2 and t<4.5
			if firing and not focus.SoundFired then
				focus.SoundFired=true
				if focus.ChargeSound then focus.ChargeSound:Destroy() end
				focus.BeamSound=makeSound(139620337204036,focus.Mouth,0.85,1.0,true)
				if focus.BeamSound then focus.BeamSound.RollOffMinDistance=45*scale end
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
				setEnergyColor(p,stage==5 and stageFiveCharge(p,color,t,fadeOut) or color:Lerp(focusColor,math.clamp((t-onset)/0.3,0,1)*fadeOut))
			end
			local orbSize=(0.15+charge*0.85)*(1+0.08*math.sin(t*28)*charge)*scale*fadeOut*focusChargeScale
			focus.Orb.Size=Vector3.new(orbSize,orbSize,orbSize)
			focus.Orb.Transparency=0.15
			for _,beam in ipairs({focus.Beam,focus.Core}) do
				beam.Enabled=t>=2 and delta.Magnitude>0.01
				beam.Transparency=NumberSequence.new(0.12+0.88*(1-fadeOut))
				if t>=2 and delta.Magnitude>0.01 then
					local width=math.max(0.05,(beam==focus.Core and focusCoreWidth or focusOuterWidth)*(1+0.25*kick+0.08*math.sin(t*25))*scale*fadeOut)
					beam.Width0=width;beam.Width1=width
				end
			end
			focus.Impact.Transparency=firing and visible and 0.25 or 1
			focus.Impact.Size=Vector3.new(2,2,2)*scale*focusImpactScale*(1+0.12*math.sin(t*40))
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
				-- Visual timing only; server owns focus damage.
			end
			presentationAttribute("FocusPhase",t<2 and "Charging" or t<4.5 and "Firing" or "Recovery")
		end
		if area then
			if areaTime>=math.max(0,AREA_TIMING.Discharge-0.2) and not area.ImpulseSoundStarted then
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
				setEnergyColor(p,stage==5 and stageFiveCharge(p,color,areaTime,tension) or color:Lerp(charged,tension))
			end
			presentationAttribute("AreaPhase",areaTime<AREA_TIMING.Discharge and "Charging" or areaTime<AREA_TIMING.Recovery and "Discharge" or "Recovery")
			if areaTime>=AREA_TIMING.Discharge and not area.Hit then
				area.Hit=true
				if area.ChargeSound then area.ChargeSound:Destroy() end
				if areaTime-AREA_TIMING.Discharge<0.5 then emitArea(area.Point) end
			end
		end
		if victory and victorySample then
			for name,angles in pairs(victorySample.Poses) do
				if motors[name] then pose(name,angles[1],angles[2],angles[3]) end
			end

			-- Keep both feet planted while the pelvis settles and rises.
			solveLeg("Left",0,0,actualBob)
			solveLeg("Right",0,0,actualBob)

			for i=1,tailCount do
				local yaw=math.sin(victoryTime*1.85-i*0.42)*(0.7+i*0.12)*victorySample.TailMotion
				local pitch=i==1 and victorySample.Poses.TailBase[1] or 0
				pose("Tail"..i,pitch,yaw,0)
			end

			for p,color in pairs(victory.Colors) do
				if p.Parent then
					setEnergyColor(p,color:Lerp(Color3.new(1,1,1),0.58*victorySample.Energy))
				end
			end

			if victoryTime>=Triumph.RoarAt and not victory.RoarPlayed then
				victory.RoarPlayed=true
				feedback("VictoryRoar",bones.Head,true)
			end
			if victoryTime>=Triumph.ShockwaveAt and not victory.ShockwavePlayed then
				victory.ShockwavePlayed=true
				emitVictoryShockwave()
			end
			presentationAttribute("VictoryState",victoryTime<Triumph.RoarAt and "Rising"
				or victoryTime<3.10 and "Roaring"
				or victoryTime<4.55 and "DominionHold"
				or "Recovery")
			presentationAttribute("AnimationPreview","CityBreakTriumph")
		end

		if hitReaction then
			local age=clock()-hitReaction.Started
			local duration=hitReaction.Heavy and 0.85 or 0.32
			local weight=math.sin(math.pi*math.clamp(age/duration,0,1))*(1-age/duration)
			if age>=duration then
				hitReaction=nil;damageFlash.FillTransparency=1;presentationAttribute("ReactionState","Idle")
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
		if swimming then
			presentationAttribute("AnimationPreview","Swim_01")
			local stroke=elapsed*2.4
			local moving=humanoid.MoveDirection.Magnitude>0.05 and 1 or 0.35
			pose("Torso",-52,0,math.sin(stroke)*3*moving)
			pose("Head",38,math.sin(stroke-0.4)*2,0)
			for _,side in ipairs({"Left","Right"}) do
				local sign=side=="Left" and -1 or 1
				local wave=math.sin(stroke+(sign<0 and 0 or math.pi))*moving
				pose(side.."UpperArm",60+wave*24,sign*12,-sign*16)
				pose(side.."Forearm",28-wave*14,0,0)
				pose(side.."Hand",-8,0,0)
				pose(side.."Thigh",-18+wave*12,0,0)
				pose(side.."Shin",24-wave*8,0,0)
				pose(side.."Hock",-8,0,0);pose(side.."Foot",-16,0,0)
			end
			for i=1,tailCount do pose("Tail"..i,i==1 and -18 or 0,math.sin(stroke-i*0.4)*(2+i*0.12)*moving,0) end
		end

		local torso=motors.Torso.C0
		motors.Torso.C0=CFrame.new(torso.Position)*pelvisTurn:Inverse()*torso.Rotation
		-- Blend mode changes and step accents rather than snapping joint poses.
		local enteringMotion=transitionLeft>0 and (mode=="Walk" or mode=="Run" or mode=="Attack")
		local motionBlend=enteringMotion and 1-math.exp(-poseDt/0.14) or blend
		for name, m in pairs(motors) do m.C0 = previous[name]:Lerp(m.C0, motionBlend) end
		-- Arm-only contact resistance: never pause the combo clock or movement root.
		if strikeResistance then
			local age=clock()-strikeResistance.Started
			if age>=0.24 or attackIndex~=strikeResistance.Index or jumpPose or focus or area or hitReaction then
				strikeResistance=nil
			else
				local release=math.clamp((age-0.06)/0.18,0,1)
				local blend=release*release*(3-2*release)
				local recoil=math.sin(math.pi*release)
				for name,heldPose in pairs(strikeResistance.Pose) do
					local degrees=string.find(name,"Forearm",1,true) and 10 or string.find(name,"UpperArm",1,true) and 6 or 3
					motors[name].C0=heldPose:Lerp(motors[name].C0,blend)*CFrame.Angles(math.rad(degrees*recoil),0,0)
				end
			end
		end
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

		end
	end)
	destroying = model.Destroying:Connect(stop)
 local lastSequence=0
 local function apply(snapshot)
  if stopped or snapshot.Version~=1 or snapshot.Sequence<=lastSequence then return end
  local previous=state;state=snapshot;lastSequence=snapshot.Sequence
  local time=clock()
  runRequested=snapshot.Run==true
  if snapshot.Defeat and not defeat then startDefeat(snapshot.Defeat) end
  if defeat then return end
  if snapshot.VictoryStarted then
   if not victory or victory.Started~=snapshot.VictoryStarted then startVictory(snapshot.VictoryStarted) end
  elseif victory then
   endVictoryView()
  end
  if victory then return end
  if not snapshot.FocusStarted then endFocus()
  elseif not focus and time-snapshot.FocusStarted<4.85 then
   requestFocus();focus.Started=snapshot.FocusStarted
   if time-focus.Started>2 and focus.ChargeSound then focus.ChargeSound:Destroy();focus.ChargeSound=nil end
  end
  if not snapshot.AreaStarted then endArea()
  elseif not area and time-snapshot.AreaStarted<AREA_TIMING.Finish then
   requestArea();area.Started=snapshot.AreaStarted
   if time-area.Started>2.8 and area.ChargeSound then area.ChargeSound:Destroy();area.ChargeSound=nil end
  end
  if snapshot.Combo~=previous.Combo or snapshot.ComboStarted~=previous.ComboStarted then
   combo:Cancel()
   if snapshot.Combo>0 then
    combo.Index=snapshot.Combo;combo.Started=snapshot.ComboStarted;combo.Active=true
    combo.HitSent=false;combo.GrabSent=false;combo.TearSoundSent=false
    if combo.Index<=2 and time-combo.Started<0.35 then feedback("Whoosh",combo.Index==1 and bones.LeftHand or bones.RightHand,true) end
   end
  end
  if snapshot.Jump~=previous.Jump or snapshot.JumpStarted~=previous.JumpStarted then
   jump.Phase=snapshot.Jump;jump.Started=snapshot.JumpStarted;jump.Lead=snapshot.JumpLead
   jump.LeftGround=snapshot.JumpLeftGround==true
   if snapshot.Jump=="Air" and time-snapshot.JumpStarted<0.35 then feedback("JumpWhoosh",bones.Pelvis,true) end
  end
  if snapshot.LandingSequence~=(previous.LandingSequence or 0) and snapshot.LandingAt and time-snapshot.LandingAt<0.5 then
   landingBlend=0;smoothedBob=0;feedback("Land",bones.Pelvis,true)
   runFootfall("Left",2.2);runFootfall("Right",2.2)
  end
  if snapshot.Reaction and (not previous.Reaction or snapshot.Reaction.Started~=previous.Reaction.Started) then
   if time-snapshot.Reaction.Started<(snapshot.Reaction.Heavy and 0.85 or 0.32) then
    hitReaction=snapshot.Reaction
    feedback(hitReaction.Heavy and "HeavyHit" or "Hit",bones.Torso,true)
   end
  elseif not snapshot.Reaction then hitReaction=nil end
  if snapshot.Hit and (not previous.Hit or snapshot.Hit.Sequence~=previous.Hit.Sequence) and time-snapshot.Hit.At<0.4 then
   local index=snapshot.Hit.Index
   if index<4 then
    feedback(index==3 and "Slam" or "Punch",index==1 and bones.LeftHand or index==2 and bones.RightHand or bones.Torso,true)
    local held={}
    for _,side in ipairs(index==1 and {"Left"} or index==2 and {"Right"} or {"Left","Right"}) do
     for _,joint in ipairs({"UpperArm","Forearm","Hand"}) do local name=side..joint;held[name]=motors[name].C0 end
    end
    strikeResistance={Started=snapshot.Hit.At,Index=index,Pose=held}
   end
  end
 end
 return {Stop=stop,Apply=apply,SetQuality=function(rate,enableFX)
  interval=1/math.clamp(rate,2,60);fxEnabled=enableFX
 end}
end
return Rig
