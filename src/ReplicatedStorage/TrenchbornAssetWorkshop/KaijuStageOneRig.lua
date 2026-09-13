-- Shared server authority. Immutable joints; clients render poses and Kaiju FX.
local RunService=game:GetService("RunService")
local CollectionService=game:GetService("CollectionService")
local HttpService=game:GetService("HttpService")
local Players=game:GetService("Players")
local Skeleton=require(script.Parent:WaitForChild("KaijuSkeleton"))
local Bootstrap=require(script.Parent:WaitForChild("KaijuPresentationBootstrap"))
local Combo=require(script.Parent:WaitForChild("KaijuStageOneCombo"))
local Jump=require(script.Parent:WaitForChild("KaijuStageOneJump"))
local Rig={}
local registry=setmetatable({}, {__mode="k"})
local TAG="TrenchbornKaijuPresentation"
local function now() return workspace:GetServerTimeNow() end
local function vec(v) return {v.X,v.Y,v.Z} end
function Rig.GetCombatFrame(model,name)
 local api=registry[model];return api and api.GetCombatFrame(name)
end
function Rig.Attach(model,root,humanoid,combat)
 assert(RunService:IsServer(),"Rig.Attach is server-only")
 local rig=Skeleton.Build(model,root)
 local scale=model:GetScale()
 local owner=root and Players:GetPlayerFromCharacter(model.Parent)
 local feedback=Instance.new("RemoteEvent");feedback.Name="KaijuFeedback";feedback.Parent=model
 local impulse=Instance.new("RemoteEvent");impulse.Name="KaijuJumpImpulse";impulse.Parent=model
 for name,value in pairs({KaijuPoseProvider=script,KaijuRenderer=script.Parent:WaitForChild("KaijuPresentation")}) do
  local ref=Instance.new("ObjectValue");ref.Name=name;ref.Value=value;ref.Parent=model
 end
 local rootRef=Instance.new("ObjectValue");rootRef.Name="KaijuMovementRoot";rootRef.Value=root;rootRef.Parent=model
 local humanRef=Instance.new("ObjectValue");humanRef.Name="KaijuHumanoid";humanRef.Value=humanoid;humanRef.Parent=model
 local combo=Combo.new(combat and combat.PrepareFinisher)
 local jump=Jump.new()
 local stopped,runRequested=false,false
 local focus,area,lock,reaction,defeat
 local focusReady,areaReady,buffered=0,0,0
 local sequence,hitSequence,landingSequence=0,0,0
 local hitRecord,lastSnapshot,lastAim,landingAt
 local connections={}
 local swim=Enum.HumanoidStateType.Swimming
 local swimEnabled=humanoid and humanoid:GetStateEnabled(swim)
 if humanoid then humanoid:SetStateEnabled(swim,true);humanoid.BreakJointsOnDeath=false end
 local function attr(name,value) if model:GetAttribute(name)~=value then model:SetAttribute(name,value) end end
 local function send(kind) if owner then feedback:FireClient(owner,kind) end end
 local function cancelCombat() if combat and combat.Cancel then combat.Cancel() end end
 local function staggered() return reaction and reaction.Heavy and now()-reaction.Started<0.65 end
 local function publish()
  local key=table.concat({tostring(runRequested),tostring(combo.Active),combo.Index,combo.Started,
   jump.Phase,jump.Started,jump.Lead,tostring(jump.LeftGround),tostring(focus),tostring(area),
   tostring(reaction),tostring(defeat),tostring(hitRecord),landingSequence},":")
  if key==lastSnapshot then return end
  lastSnapshot=key
  local state={Version=1,Run=runRequested,Combo=combo.Active and combo.Index or 0,ComboStarted=combo.Started,
   Jump=jump.Phase,JumpStarted=jump.Started,JumpLead=jump.Lead,JumpLeftGround=jump.LeftGround,
   FocusStarted=focus and focus.Started,AreaStarted=area and area.Started,AreaPoint=area and vec(area.Point),
   AreaRotation=area and {area.Ground.Rotation:GetComponents()},Reaction=reaction,Defeat=defeat,
   Hit=hitRecord,LandingSequence=landingSequence,LandingAt=landingAt}
  sequence=sequence+1;state.Sequence=sequence
  model:SetAttribute("KaijuPresentationState",HttpService:JSONEncode(state))
 end
 local function hold()
  if not lock then return end
  humanoid.WalkSpeed=0;humanoid.AutoRotate=false;humanoid.Jump=false;humanoid:Move(Vector3.zero,false)
  if not root.Anchored then root.Anchored=true end
  if root.CFrame~=lock.Frame then root.CFrame=lock.Frame end
  if root.AssemblyLinearVelocity.Magnitude>0 then root.AssemblyLinearVelocity=Vector3.zero end
  if root.AssemblyAngularVelocity.Magnitude>0 then root.AssemblyAngularVelocity=Vector3.zero end
 end
 local function release()
  if not lock then return end
  local saved=lock;lock=nil
  if root.Parent then root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero;root.Anchored=saved.Anchored end
  if humanoid.Parent then
   humanoid.WalkSpeed=saved.Speed;humanoid.AutoRotate=saved.Rotate;humanoid.Jump=false
   humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,saved.JumpEnabled)
  end
  attr("SpecialAttackLocked",nil)
 end
 local function begin(kind)
  lock={Frame=root.CFrame,Anchored=root.Anchored,Speed=humanoid.WalkSpeed,Rotate=humanoid.AutoRotate,
   JumpEnabled=humanoid:GetStateEnabled(Enum.HumanoidStateType.Jumping)}
  humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
  reaction=nil;combo:Cancel();cancelCombat();attr("ComboStep",0)
  attr("Running",false);attr("ReactionState","Idle");attr("SpecialAttackLocked",kind);hold()
 end
 local function endSpecial()
  if focus then focus=nil;focusReady=now()+1;attr("FocusPhase","Idle") end
  if area then area=nil;attr("AreaPhase","Idle") end
  release()
 end
 local function alive()
  return not stopped and root and humanoid and humanoid.Health>0 and not defeat and model:GetAttribute("IdleEnabled")~=false
 end
 local function readySpecial()
  return alive() and not staggered() and not lock and jump.Phase=="Idle" and not combo.Active
   and humanoid.FloorMaterial~=Enum.Material.Air
 end
 local query=RaycastParams.new();query.FilterType=Enum.RaycastFilterType.Exclude
 query.FilterDescendantsInstances={root and root.Parent or model};query.RespectCanCollide=true
 -- Compute only queried combat frames. Never write animated joint properties.
 local function combatFrame(name)
  local poses,weight,crouch
  if combo.Active then
   local sample=Combo.new();sample.Index=combo.Index;sample.Started=combo.Started;sample.Active=true
   local ignoredName,ignoredIndex
   poses,weight,ignoredName,ignoredIndex,crouch=sample:Sample(now())
  end
  local base=root and root.CFrame*rig.Offset or rig.RestFrame
  base=base*CFrame.new(0,-(crouch or 0)*scale,0)
  local overrides={}
  if focus then
   local t=now()-focus.Started;local charge=math.clamp(t/2,0,1);local fade=math.clamp((4.85-t)/0.35,0,1)
   local from=(base*rig.Rest.Torso*rig.Rest.Head).Position
   local delta=(focus.Point or from+root.CFrame.LookVector*30)-from
   local pitch=math.clamp(math.deg(math.atan2(delta.Y,math.max(Vector3.new(delta.X,0,delta.Z).Magnitude,0.01))),-24,15)
   local localAim=root.CFrame:VectorToObjectSpace(delta)
   local yaw=math.clamp(math.deg(math.atan2(-localAim.X,-localAim.Z)),-45,45)
   local kick=t>=2 and t<4.5 and math.exp(-(t-2)*9) or 0
   local build=math.min(t/1.5,1);local torso=(-14*build+13*kick)*fade
   local low=math.clamp((-pitch-8)/16,0,1);local reach=low*low*(3-2*low)*charge*fade
   base=base*CFrame.new(0,-(1.7*math.min(t/0.65,1)+0.65*kick)*scale*fade,0)
   overrides.Torso=rig.Rest.Torso*CFrame.Angles(math.rad(torso),0,0)
   overrides.Head=rig.Rest.Head*CFrame.new(0,0.5*scale*reach,(-1.2*reach+0.5*build*fade+0.7*kick)*scale)
    *CFrame.Angles(math.rad(pitch*charge*fade-torso),math.rad(yaw*charge*fade),0)
  end
  local cache={Pelvis=base}
  local function world(bone)
   if cache[bone] then return cache[bone] end
   local m=rig.Motors[bone];if not m then return nil end
   local offset=overrides[bone] or rig.Rest[bone];local angles=poses and poses[bone]
   if angles then offset=offset:Lerp(rig.Rest[bone]*CFrame.Angles(math.rad(angles[1]),math.rad(angles[2]),math.rad(angles[3])),weight) end
   cache[bone]=world(m.Part0.Name)*offset;return cache[bone]
  end
  return world(name)
 end
 local upper=model:FindFirstChild("UpperMuzzleCoreY")
 local upperLocal=upper and upper:GetAttribute("RigLocalFrame")
 local function mouth()
  if not upper then return root.Position end
  return (combatFrame("Head")*upperLocal*CFrame.new(0,-upper.Size.Y/2-0.2*scale,model:FindFirstChild("UpperMuzzleCoreZ").Size.Z*0.25)).Position
 end
 local function requestFocus()
  if not readySpecial() or now()<focusReady or not combat or not combat.SelectFocusTarget or not combat.FocusAim then return false end
  local target=combat.SelectFocusTarget(mouth())
  if not target then attr("FocusPhase","No target");return false end
  begin("Focus");focus={Started=now(),Target=target,Ticks=0,AimAt=0}
  focus.Point,focus.Visible=combat.FocusAim(target,mouth())
  attr("KaijuFocusPoint",focus.Point);attr("KaijuFocusVisible",focus.Visible==true)
  attr("FocusPhase","Charging");publish();return true
 end
 local function requestArea()
  local function reject(reason)
   attr("AreaRejectReason",reason)
   return false,reason
  end
  if not readySpecial() then return reject("Not ready") end
  if now()<areaReady then return reject("Cooldown") end
  if not combat or not combat.AreaImpact then return reject("No adapter") end
  local hit=workspace:Raycast(root.Position+Vector3.new(0,30*scale,0),Vector3.new(0,-70*scale,0),query)
  if not hit then attr("AreaPhase","No ground");return reject("No ground") end
  if hit.Normal.Y<0.4 then attr("AreaPhase","No ground");return reject("Too steep") end
  -- The ray ends 40 scaled studs below the root (30 above minus 70 down).
  if (hit.Position-root.Position).Magnitude>40*scale then
   attr("AreaPhase","No ground");return reject("Ground too far")
  end
  local normal=hit.Normal.Unit
  local forward=root.CFrame.LookVector-normal*root.CFrame.LookVector:Dot(normal)
  if forward.Magnitude<0.001 then forward=normal:Cross(root.CFrame.RightVector) end
  local ground=CFrame.lookAt(hit.Position,hit.Position+forward.Unit,normal)
  attr("AreaRejectReason",nil)
  begin("Area");area={Started=now(),Point=hit.Position,Ground=ground}
  areaReady=now()+4;attr("AreaPhase","Charging");publish();return true
 end
 local function requestJump()
  if not alive() or staggered() or lock or humanoid:GetState()==swim then return false end
  if jump.Phase=="Air" then buffered=now()+0.22;return true end
  if not jump:Request(now(),humanoid.FloorMaterial~=Enum.Material.Air) then return false end
  buffered=0;combo:Cancel();cancelCombat();publish();return true
 end
 local function requestAttack()
  if not alive() or staggered() or lock or (jump.Phase~="Idle" and jump.Phase~="Landing") or humanoid:GetState()==swim then return false end
  local accepted=combo:Request(now());if accepted then publish() end;return accepted
 end
 local function setRunning(enabled)
  if type(enabled)~="boolean" or not alive() then return false end
  runRequested=enabled;attr("RunRequested",enabled);publish();return true
 end
 local function stop()
  if stopped then return end
  stopped=true;endSpecial();combo:Cancel();jump:Cancel();cancelCombat()
  for _,c in ipairs(connections) do c:Disconnect() end
  if humanoid and humanoid.Parent then humanoid:SetStateEnabled(swim,swimEnabled) end
  CollectionService:RemoveTag(model,TAG);registry[model]=nil
 end
 if humanoid and root then
  local previous=humanoid.Health
  table.insert(connections,humanoid.HealthChanged:Connect(function(health)
   local damage=previous-health;previous=health
   if stopped or defeat or damage<=0 then return end
   if health<=0 then
    endSpecial();combo:Cancel();jump:Cancel();cancelCombat();runRequested=false
    humanoid.WalkSpeed=0;humanoid.AutoRotate=false;humanoid:Move(Vector3.zero,false);root.Anchored=true
    local hit=workspace:Raycast(root.Position+Vector3.new(0,30*scale,0),Vector3.new(0,-150*scale,0),query)
    defeat={Started=now(),Root={ (root.CFrame*rig.Offset):GetComponents() },Ground=hit and hit.Position.Y or (root.CFrame*rig.Offset).Position.Y-15.7*scale}
    reaction=nil;attr("ReactionState","Falling");attr("ComboStep",0);attr("Running",false);attr("RunRequested",false)
   elseif not lock then
    local heavy=damage>=humanoid.MaxHealth*0.18
    reaction={Started=now(),Heavy=heavy,Side=reaction and -reaction.Side or -1}
    if heavy then combo:Cancel();cancelCombat() end
    attr("ReactionState",heavy and "Stagger" or "Hit");send(heavy and "HeavyHit" or "Hit")
   end
   publish()
  end))
 end
	local lastRoofAssist=-math.huge
	local function assistRoofLanding(dt)
		if not root or not humanoid or humanoid.Health<=0 or focus or area or staggered()
			or jump.Phase=="Windup" or humanoid.FloorMaterial~=Enum.Material.Air then return end
		local velocity=root.AssemblyLinearVelocity
		if velocity.Y>=-1 or now()-lastRoofAssist<0.35 then return end
		local height=humanoid.HipHeight+root.Size.Y/2
		if humanoid.RigType==Enum.HumanoidRigType.R6 then
			local leg=model.Parent:FindFirstChild("Left Leg")
			if leg then height=height+leg.Size.Y end
		end
		local foot=root.Position-Vector3.new(0,height,0)
		local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances={model.Parent};params.RespectCanCollide=true
		local down=Vector3.new(0,-(0.35*scale+math.min(-velocity.Y*dt,0.6*scale)),0)
		local origin=foot+Vector3.new(0,0.15*scale,0)
		if workspace:Raycast(origin,down,params) then return end -- Already above support.
		local horizontal=Vector3.new(velocity.X,0,velocity.Z)
		if horizontal.Magnitude<0.5 then return end
		local forward=horizontal.Unit
		local right=Vector3.new(-forward.Z,0,forward.X)
		for _,direction in ipairs({forward,(forward+right).Unit,(forward-right).Unit,right,-right}) do
			local offset=direction*(1.0*scale)
			local hit=workspace:Raycast(origin+offset,down,params)
			if hit and hit.Normal.Y>0.95 and hit.Position.Y<=foot.Y+0.05*scale then
				-- Require room along the small horizontal correction at feet and torso.
				local blocked=false
				for _,y in ipairs({0.3,3,10,20}) do
					if workspace:Raycast(foot+Vector3.new(0,y*scale,0),offset,params) then blocked=true;break end
				end
				if not blocked then
					root.CFrame=root.CFrame+offset
					lastRoofAssist=now()
					return
				end
			end
		end
	end

 table.insert(connections,RunService.PreSimulation:Connect(hold))
 local accumulator=0
 table.insert(connections,RunService.Heartbeat:Connect(function(dt)
  if not model:IsDescendantOf(workspace) then stop();return end
  accumulator=accumulator+dt;if accumulator<1/30 then return end
  local step=accumulator;accumulator=0
  if defeat then if now()-defeat.Started>=4.8 then attr("ReactionState","Defeated") end;return end
  if not alive() then return end
  local t=now()
  if reaction and t-reaction.Started>=(reaction.Heavy and 0.85 or 0.32) then reaction=nil;attr("ReactionState","Idle") end
  local swimming=not lock and humanoid:GetState()==swim;attr("Swimming",swimming)
  if swimming then jump:Cancel();combo:Cancel();buffered=0;cancelCombat()
  elseif not lock then
   assistRoofLanding(step)
   local _,event=jump:Update(t,humanoid.FloorMaterial~=Enum.Material.Air,root.AssemblyLinearVelocity.Y)
   if event=="Takeoff" then
    local rise=math.sqrt(2*workspace.Gravity*14*scale)
    if owner then impulse:FireClient(owner,rise)
    else humanoid:ChangeState(Enum.HumanoidStateType.Freefall);root:ApplyImpulse(Vector3.new(0,rise-root.AssemblyLinearVelocity.Y,0)*root.AssemblyMass) end
   elseif event=="Land" then
    root:ApplyImpulse(Vector3.new(0,-math.max(0,root.AssemblyLinearVelocity.Y),0)*root.AssemblyMass)
    landingSequence=landingSequence+1;landingAt=t;send("Land")
    if combat then combat.Handle("Land",0) end
   end
   if jump.Phase=="Landing" and buffered>=t then requestJump() end
  end
  attr("JumpPhase",jump.Phase)
  if not lock then humanoid.WalkSpeed=swimming and 12 or staggered() and 0 or runRequested and 16 or 10 end
  local velocity=root.AssemblyLinearVelocity
  attr("Running",not lock and not swimming and runRequested and not staggered() and Vector3.new(velocity.X,0,velocity.Z).Magnitude>0.5)
  local _,_,attackName,index=combo:Sample(t)
  attr("ComboStep",index or 0);attr("AttackName",attackName or "")
  for _,event in ipairs(combo:DrainEvents()) do
   if event.Kind~="Whoosh" and event.Kind~="TearSound" and combat then
    local confirmed=combat.Handle(event.Kind,event.Index,event.FinisherUntil and os.clock()+(event.FinisherUntil-t) or nil)
    if event.Kind=="Hit" and (confirmed or model:GetAttribute("LastAttackResult")=="Hit") then
     hitSequence=hitSequence+1;hitRecord={Sequence=hitSequence,At=t,Index=event.Index};send(event.Index==4 and "Finisher" or "Punch")
    end
   end
  end
  if focus then
   local age=t-focus.Started
   if t-focus.AimAt>=0.1 then
    focus.AimAt=t;local point,visible=combat.FocusAim(focus.Target,mouth())
    if point then focus.Point=point end;focus.Visible=visible==true
    if point and (not lastAim or (point-lastAim).Magnitude>=0.15*scale) then lastAim=point;attr("KaijuFocusPoint",point) end
    attr("KaijuFocusVisible",focus.Visible)
   end
   local due=math.clamp(math.floor((age-2)/0.25),0,10)
   while focus.Ticks<due do focus.Ticks=focus.Ticks+1;combat.Handle("Focus",0,focus.Target,mouth()) end
   if age>=2 and not focus.Fired then focus.Fired=true;send("FocusFire") end
   attr("FocusPhase",age<2 and "Charging" or age<4.5 and "Firing" or "Recovery")
   if age>=4.85 then endSpecial() end
  elseif area then
   local age=t-area.Started
   if age>=2.8 and not area.Hit then area.Hit=true;combat.AreaImpact(area.Point);send("Discharge") end
   attr("AreaPhase",age<2.8 and "Charging" or age<3.2 and "Discharge" or "Recovery")
   if age>=4.6 then endSpecial() end
  end
  publish()
 end))
 table.insert(connections,model.Destroying:Connect(stop))
 local api={Stop=stop,Motors=rig.Motors,RequestAttack=requestAttack,RequestJump=requestJump,
  SetAirDirection=function() end,RequestFocus=requestFocus,RequestArea=requestArea,SetRunning=setRunning,GetCombatFrame=combatFrame}
 registry[model]=api
 model:SetAttribute("PoseOwnershipRevision","ClientTransform_StateSync_01")
 model:SetAttribute("KaijuPresentationVersion",1)
 model:SetAttribute("KaijuHasMovementRoot",root~=nil)
 model:SetAttribute("KaijuHasHumanoid",humanoid~=nil)
 publish();Bootstrap.Ensure();CollectionService:AddTag(model,TAG)
 return api
end
return Rig
