-- Phase 6 workshop traversal. Registered buildings only; damage stays in
-- the combat adapter. No physical animated-leg colliders or touch damage.
local RunService=game:GetService("RunService")
local Traversal={}
function Traversal.Attach(model,root,humanoid,rootHeight,collider,combat,player)
 assert(model:GetAttribute("EvolutionStage")==4,"Stage 4 required")
 local scale=model:GetScale()
 local character=model.Parent
 local ground=root.CFrame*CFrame.new(0,-rootHeight,0)
 local kneeHeight=ground:PointToObjectSpace(model.LeftKneeJoint.Position).Y
 local hipHeight=ground:PointToObjectSpace(model.LeftHipJoint.Position).Y
 local rib=model.LowerRibcage
 local ribPosition=ground:PointToObjectSpace(rib.Position)
 local bodySize=Vector3.new(rib.Size.X*0.60,rib.Size.Y*0.80,rib.Size.Z*0.65)
 local bodyY=math.max(ribPosition.Y,math.max(kneeHeight+scale,14*scale)+bodySize.Y/2)
 -- Raise the central solid entirely above the knee corridor.
 collider.Size=bodySize
 local weld=collider:FindFirstChildOfClass("WeldConstraint")
 if weld then weld:Destroy() end
 collider.CFrame=ground*CFrame.new(0,bodyY,ribPosition.Z)
 weld=Instance.new("WeldConstraint");weld.Part0=root;weld.Part1=collider;weld.Parent=collider
 local folder=Instance.new("Folder");folder.Name="Stage4Traversal";folder.Parent=character
 local remote=Instance.new("RemoteEvent");remote.Name="ReportFootfall";remote.Parent=model
 local feet,probes={},{}
 for _,side in ipairs({"Left","Right"}) do
  local sole=model[side.."ForefootCoreY"]
  local pos=ground:PointToObjectSpace(sole.Position)
  feet[side]={X=pos.X,Z=pos.Z,Size=Vector3.new(sole.Size.X*0.88,sole.Size.Y,sole.Size.Z*0.88)}
  model:SetAttribute("Traversal"..side.."FootX",pos.X)
  model:SetAttribute("Traversal"..side.."FootZ",pos.Z)
  local height=hipHeight-scale
  probes[side]={Offset=CFrame.new(pos.X,height/2+scale,pos.Z*0.35),
   Size=Vector3.new(sole.Size.X*0.74,height,sole.Size.Z*0.60)}
 end
 local pairsByAvatar={}
 local mediumParts={}
 local function refresh()
  mediumParts={}
  local records=combat.TraversalTargets()
  for _,entry in ipairs(records) do
   for _,buildingPart in ipairs(entry.Parts) do
    if entry.Height>=kneeHeight then table.insert(mediumParts,buildingPart) end
    -- The tiny hidden Roblox avatar must not block houses in the leg gap.
    -- It retains normal ground/world collision; our torso and probes own buildings.
    for _,avatar in ipairs(character:GetDescendants()) do
     if avatar:IsA("BasePart") and avatar~=collider and not avatar:IsDescendantOf(model) then
      local linked=pairsByAvatar[avatar] or {};pairsByAvatar[avatar]=linked
      if not linked[buildingPart] then
       local joint=Instance.new("NoCollisionConstraint")
       joint.Part0=avatar;joint.Part1=buildingPart;joint.Parent=folder
       linked[buildingPart]=joint
      end
     end
    end
   end
  end
 end
 refresh()
 local previous=root.CFrame
 local refreshAt=0
 local stopped=false
 local lastAny=-math.huge
 local lastStep={Left=-math.huge,Right=-math.huge}
 local lastPosition={Left=root.Position,Right=root.Position}
 local function finite(v)
  return typeof(v)=="Vector3" and v.X==v.X and v.Y==v.Y and v.Z==v.Z
   and math.abs(v.X)<1e7 and math.abs(v.Y)<1e7 and math.abs(v.Z)<1e7
 end
 local report=remote.OnServerEvent:Connect(function(sender,side,point)
  if sender~=player or player.Character~=character or not feet[side] or not finite(point) then return end
  if humanoid.Health<=0 or humanoid.FloorMaterial==Enum.Material.Air or root.Anchored
   or model:GetAttribute("SpecialAttackLocked") or (model:GetAttribute("ComboStep") or 0)>0
   or (model:GetAttribute("JumpPhase") and model:GetAttribute("JumpPhase")~="Idle") then return end
  local now=os.clock()
  if now-lastAny<0.18*scale or now-lastStep[side]<0.60*scale then return end
  local distance=root.Position-lastPosition[side]
  if Vector3.new(distance.X,0,distance.Z).Magnitude<2.5*scale then return end
  local velocity=root.AssemblyLinearVelocity
  if Vector3.new(velocity.X,0,velocity.Z).Magnitude<0.5 then return end
  local foot=feet[side]
  local currentGround=root.CFrame*CFrame.new(0,-rootHeight,0)
  local localPoint=currentGround:PointToObjectSpace(point)
  if math.abs(localPoint.X-foot.X)>foot.Size.X*0.65 or math.abs(localPoint.Y)>2*scale
   or math.abs(localPoint.Z-foot.Z)>8*scale then return end
  -- Client chooses neither a target nor damage. Clamp height to server ground.
  local cf=currentGround*CFrame.new(localPoint.X,0,localPoint.Z)
  lastAny=now;lastStep[side]=now;lastPosition[side]=root.Position
  combat.StepImpact(cf,foot.Size,kneeHeight)
 end)
 local heartbeat=RunService.Heartbeat:Connect(function()
  if stopped or not root.Parent then return end
  if os.clock()>=refreshAt then refresh();refreshAt=os.clock()+0.4 end
  local current=root.CFrame
  if humanoid.Health<=0 or root.Anchored then previous=current;return end
  local delta=current.Position-previous.Position
  local horizontal=Vector3.new(delta.X,0,delta.Z)
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include
  params.FilterDescendantsInstances=mediumParts;params.RespectCanCollide=true
  local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include
  overlap.FilterDescendantsInstances=mediumParts;overlap.RespectCanCollide=true
  local nearest,normal=horizontal.Magnitude,nil
  local turnBlocked=false
  if #mediumParts>0 then
   for _,probe in pairs(probes) do
    local before=previous*CFrame.new(0,-rootHeight,0)*probe.Offset
    local after=current*CFrame.new(0,-rootHeight,0)*probe.Offset
    if horizontal.Magnitude>0.001 then
     local hit=workspace:Blockcast(before,probe.Size,horizontal,params)
     if hit and hit.Distance<=nearest then nearest=math.max(0,hit.Distance-0.08*scale);normal=hit.Normal end
    end
    -- Blockcast ignores initial overlaps: also catch rotation into a building.
    if #workspace:GetPartBoundsInBox(after,probe.Size,overlap)>0
     and #workspace:GetPartBoundsInBox(before,probe.Size,overlap)==0 then turnBlocked=true end
   end
  end
  if normal or turnBlocked then
   local position=previous.Position+Vector3.new(0,delta.Y,0)
   if normal and not turnBlocked and horizontal.Magnitude>0 then position=position+horizontal.Unit*nearest end
   root.CFrame=CFrame.new(position)*(turnBlocked and previous.Rotation or current.Rotation)
   local velocity=root.AssemblyLinearVelocity
   if normal then
    local into=math.min(0,velocity:Dot(normal));root.AssemblyLinearVelocity=velocity-normal*into
   else root.AssemblyLinearVelocity=Vector3.new(0,velocity.Y,0) end
   model:SetAttribute("TraversalBlocked",true)
  else model:SetAttribute("TraversalBlocked",false) end
  previous=root.CFrame
 end)
 local function stop()
  if stopped then return end;stopped=true
  report:Disconnect();heartbeat:Disconnect();folder:Destroy();remote:Destroy()
 end
 model.Destroying:Once(stop)
 model:SetAttribute("TraversalRevision","S4_ClearLegGap_ServerFootsteps_01")
 model:SetAttribute("StepOverHeight",kneeHeight)
 model:SetAttribute("TraversalRootHeight",rootHeight)
 return {Destroy=stop}
end
return Traversal
