-- Phase 4 geometry candidate; Stage 4 design approved, geometry not yet approved.
local StageThree=require(script.Parent:WaitForChild("KaijuStageThreeGoldenMaster"))
local Base=require(script.Parent:WaitForChild("KaijuEvolutionBlockout"))
local Builder={}
local NAME="Stage_4_Geometry_Review"
-- Preserve the established, mirrored plate construction without altering Stage 3.
local function stone(model,name,size,cf,class)
 local p=Instance.new(class or "CornerWedgePart")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 p.Material=Enum.Material.Basalt;p.Color=Color3.fromRGB(58,63,68)
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=model;return p
end
-- Find the visible front of overlapping ellipsoid body masses at an X/Y sample.
-- Solving in each mass's local frame also handles tilted calves and cheeks.
local function frontSurface(parts,x,y)
 local front=math.huge
 local surfaceNormal
 for _,p in ipairs(parts) do
  local o=p.CFrame:PointToObjectSpace(Vector3.new(x,y,0))
  local d=p.CFrame:VectorToObjectSpace(Vector3.zAxis)
  local h=p.Size/2
  local a=(d.X/h.X)^2+(d.Y/h.Y)^2+(d.Z/h.Z)^2
  local b=2*(o.X*d.X/h.X^2+o.Y*d.Y/h.Y^2+o.Z*d.Z/h.Z^2)
  local c=(o.X/h.X)^2+(o.Y/h.Y)^2+(o.Z/h.Z)^2-1
  local disc=b*b-4*a*c
  if disc>=0 then
   local hit=(-b-math.sqrt(disc))/(2*a)
   if hit<front then
    front=hit
    local point=o+d*hit
    surfaceNormal=p.CFrame:VectorToWorldSpace(
     Vector3.new(point.X/h.X^2,point.Y/h.Y^2,point.Z/h.Z^2)).Unit
   end
  end
 end
 assert(front<math.huge,"Armor surface sample missed its body mass")
 return front,surfaceNormal
end
local function surfaceFrame(parts,x,y,inset)
 local z,normal=frontSurface(parts,x,y)
 local up=Vector3.yAxis-normal*normal:Dot(Vector3.yAxis)
 up=up.Unit
 local right=normal:Cross(up).Unit
 return CFrame.fromMatrix(Vector3.new(x,y,z)+normal*inset,right,up,-normal)
end
-- Chest and hip edges use the rectangular -Y face as their buried attachment face.
-- Two corner wedges per side meet at one outer midpoint, forming a bevel
-- instead of a horizontal shelf. The original width/height/depth envelope stays.
local function bevelPlate(model,name,width,height,depth,cf)
 local frame=cf*CFrame.new(0,-height*0.06,0)
 stone(model,name.."Core",Vector3.new(width*0.72,height,depth),frame,"Part")
 local function reflected(cf0,size,axis)
  local function reflect(v) return v-axis*(2*v:Dot(axis)) end
  -- Native apex (+X,+Y,-Z) is invariant under (X,Z) -> (-Z,-X).
  return CFrame.fromMatrix(reflect(cf0.Position),
   -reflect(cf0.ZVector),reflect(cf0.UpVector),-reflect(cf0.RightVector)),
   Vector3.new(size.Z,size.Y,size.X)
 end
 local upperSize=Vector3.new(height/2,width*0.15,depth)
 local upper=CFrame.fromMatrix(Vector3.new(width*0.425,height/4,0),
  -Vector3.yAxis,Vector3.xAxis,Vector3.zAxis)
 local lower,lowerSize=reflected(upper,upperSize,Vector3.yAxis)
 for i,entry in ipairs({{upper,upperSize},{lower,lowerSize}}) do
  stone(model,name.."EdgeRight"..i,entry[2],frame*entry[1])
  local left,leftSize=reflected(entry[1],entry[2],Vector3.xAxis)
  stone(model,name.."EdgeLeft"..i,leftSize,frame*left)
 end
end
local function enlargeGroup(model,prefix,frame,factors)
 local function stretch(v) return Vector3.new(v.X*factors.X,v.Y*factors.Y,v.Z*factors.Z) end
 for _,p in ipairs(model:GetChildren()) do
  if p:IsA("BasePart") and p.Name:sub(1,#prefix)==prefix then
   local localFrame=frame:ToObjectSpace(p.CFrame)
   p.Size=Vector3.new(p.Size.X*stretch(localFrame.RightVector).Magnitude,
    p.Size.Y*stretch(localFrame.UpVector).Magnitude,p.Size.Z*stretch(localFrame.ZVector).Magnitude)
   p.CFrame=frame*CFrame.new(stretch(localFrame.Position))*localFrame.Rotation
  end
 end
end
-- Place additional armor directly on an ellipsoid surface; local -Z faces out.
local function shellFrame(mass,direction,inset)
 local d=mass.CFrame:VectorToObjectSpace(direction.Unit)
 local h=mass.Size/2
 local radius=1/math.sqrt((d.X/h.X)^2+(d.Y/h.Y)^2+(d.Z/h.Z)^2)
 local localPoint=d*radius
 local normal=mass.CFrame:VectorToWorldSpace(Vector3.new(localPoint.X/h.X^2,localPoint.Y/h.Y^2,localPoint.Z/h.Z^2)).Unit
 local up=Vector3.yAxis-normal*normal:Dot(Vector3.yAxis)
 if up.Magnitude<0.01 then up=Vector3.zAxis-normal*normal:Dot(Vector3.zAxis) end
 up=up.Unit
 return CFrame.fromMatrix(mass.CFrame:PointToWorldSpace(localPoint)+normal*inset,normal:Cross(up).Unit,up,-normal)
end
local function layeredShell(model,name,mass,direction,width,height,depth)
 local cf=shellFrame(mass,direction,depth*0.22)
 bevelPlate(model,name,width,height,depth,cf)
 bevelPlate(model,name.."Overlap",width*0.82,height*0.70,depth*0.62,
  cf*CFrame.new(0,height*0.16,-depth*0.52))
 return cf
end
function Builder.Build(parent,ground,options)
 local multiplier=Base.ResolveBuildScale(options)
 ground=ground or CFrame.identity
 assert(not parent:FindFirstChild(NAME),"Stage 4 already exists")
 local staging=Instance.new("Folder");staging.Name="StageFourBuild";staging.Parent=parent
 local model
 local ok,err=pcall(function()
  model=StageThree.Build(staging,CFrame.identity)
  local previousScale=model:GetScale()
  model:ScaleTo(1);model.Name=NAME
  -- Enlarge existing armor together with its attached facets and energy seams.
  for _,side in ipairs({"Left","Right"}) do
   for _,entry in ipairs({
    {"ShoulderArmor",side.."ShoulderJoint",Vector3.new(1.32,1.20,1.30)},
    {"ForearmArmor",side.."ElbowJoint",Vector3.new(1.18,1.12,1.18)},
    {"HipArmor",side.."HipJoint",Vector3.new(1.18,1.12,1.18)},
    {"ShinArmor",side.."KneeJoint",Vector3.new(1.18,1.12,1.18)},
   }) do
    enlargeGroup(model,side..entry[1],model[entry[2]].CFrame,entry[3])
   end
  end
  -- Enlarge each entire dorsal cluster in its own plate basis, including insets.
  for i=1,11 do
   local stem=string.format("%02d",i)
   local plate=model:FindFirstChild("DorsalShield_"..stem)
   if plate then
    local frame=plate.CFrame
    local factors=i<=3 and Vector3.new(1.18,1.22,1.16) or Vector3.new(1.10,1.12,1.08)
    for _,kind in ipairs({"DorsalShield_","DorsalEnergy_","DorsalRock_"}) do
     enlargeGroup(model,kind..stem,frame,factors)
    end
   end
  end
  -- Replace the small lateral rib plates with three broad chest segments per side.
  -- Keep the inherited back/flank routes; no central reactor or skull crown.
  for _,p in ipairs(model:GetChildren()) do
   if p.Name:match("^LeftRibArmor_%d") or p.Name:match("^RightRibArmor_%d") then p:Destroy() end
  end
  for _,sign in ipairs({-1,1}) do
   local side=sign<0 and "Left" or "Right"
   local pec=model[side.."Pectoral"]
   local masses={pec,model[side.."Flank"],model.LowerRibcage,model.BellyShield}
   for row,vertical in ipairs({0.29,-0.02,-0.33}) do
    local width=math.min(pec.Size.X*(row==3 and 0.88 or 1.04),math.abs(pec.Position.X)*1.78)
    local height=pec.Size.Y*0.27
    local x=pec.Position.X+sign*pec.Size.X*0.015
    local y=pec.Position.Y+pec.Size.Y*vertical
    local frame=surfaceFrame(masses,x,y,0.30)*CFrame.Angles(0,0,sign*math.rad(8))
    -- Broad bevel foundations keep narrow physical gaps between rows.
    bevelPlate(model,side.."RibArmorStage4Row"..row,width,height,1.05,frame)
    bevelPlate(model,side.."RibArmorStage4Row"..row.."RockLayer",width*0.92,height*0.80,0.58,
     frame*CFrame.new(sign*width*0.025,height*0.04,-0.64)*CFrame.Angles(0,0,-sign*math.rad(4)))
   end
  end
  for _,sign in ipairs({-1,1}) do
   local side=sign<0 and "Left" or "Right"
   -- Upper arm and forearm each retain their own articulated region prefix.
   layeredShell(model,side.."ShoulderArmorStage4Rear",model[side.."Deltoid"],Vector3.new(sign,0.25,0.8),3.0,2.8,0.95)
   layeredShell(model,side.."ShoulderArmorStage4UpperArm",model[side.."BicepsMass"],Vector3.new(sign,-0.15,0.55),2.3,2.9,0.78)
   layeredShell(model,side.."ForearmArmorStage4Rear",model[side.."ForearmMass"],Vector3.new(sign,0.05,1),2.7,3.2,0.95)
   layeredShell(model,side.."ForearmArmorStage4Front",model[side.."ForearmMass"],Vector3.new(sign*0.6,0,-1),2.1,2.5,0.70)
   layeredShell(model,side.."HipArmorStage4Rear",model[side.."ThighMass"],Vector3.new(sign*0.65,0.1,1),2.7,3.1,0.82)
   layeredShell(model,side.."ShinArmorStage4Rear",model[side.."CalfMass"],Vector3.new(sign*0.4,0.1,1),2.5,2.9,0.86)
   -- Heel prefix maps to Foot; do not weld the boot across the ankle joint.
   local heel=model:FindFirstChild(side.."HeelCore") or model:FindFirstChild(side.."Heel")
   if not heel then
    for _,part in ipairs(model:GetChildren()) do
     if part:IsA("BasePart") and part.Name:sub(1,#side+4)==side.."Heel" then heel=part;break end
    end
   end
   assert(heel,"Missing heel geometry for "..side)
   layeredShell(model,side.."HeelArmorStage4Rear",heel,Vector3.new(0,0.30,1),2.5,1.8,0.85)
   layeredShell(model,side.."HeelArmorStage4Outer",heel,Vector3.new(sign,0.25,0.4),1.8,1.6,0.65)
   -- Native WedgePart tapers toward local -Z. Aim that axis away from the
   -- body, embedding the broad +Z base in the shell rather than the thin tip.
   local spineRows={
    {Mass="UpperRibcage",X=0.48,Y=0.40,Length=3.0,Region=side.."RibArmor",Width=1.8},
    {Mass="UpperRibcage",X=0.72,Y=0.05,Length=2.5,Region=side.."RibArmor",Width=1.8},
    {Mass="LowerRibcage",X=0.62,Y=-0.34,Length=1.9,Region=side.."RibArmor",Width=1.8},
    {Mass="SacralMass",X=0.70,Y=0.05,Length=1.65,Region="PelvisArmor"..side,Width=1.55},
    {Mass="TailRootMass",X=0.65,Y=0.15,Length=1.35,Region="TailBaseArmor"..side,Width=1.30},
   }
   for i,entry in ipairs(spineRows) do
    local direction=Vector3.new(sign*entry.X,entry.Y,1)
    local mass=assert(model:FindFirstChild(entry.Mass),"Missing spine root "..entry.Mass)
    local name=entry.Region.."BackSpine"..i
    local cf=layeredShell(model,name,mass,direction,entry.Width,entry.Width*1.17,0.70)
    local axis=(cf.LookVector+Vector3.new(sign*0.40,0.40,0)).Unit
    local up=(Vector3.yAxis-axis*axis.Y).Unit
    local center=cf.Position+axis*(entry.Length/2-0.18)
    local spikeFrame=CFrame.lookAt(center,center+axis,up)
    stone(model,name.."Shard",Vector3.new(1.25,1.45,entry.Length),spikeFrame,"WedgePart")
   end
  end
  model:ScaleTo(previousScale*1.10*multiplier)
  local bottom=math.huge
  for _,side in ipairs({"Left","Right"}) do
   local sole=model[side.."ForefootCoreY"]
   bottom=math.min(bottom,sole.CFrame:PointToWorldSpace(Vector3.new(0,-sole.Size.Y/2,0)).Y)
  end
  model:PivotTo(model:GetPivot()+Vector3.new(0,-bottom,0))
  model:PivotTo(ground*model:GetPivot())
  for _,key in ipairs({"ApprovedGeometryCommit","ApprovedRevision","DressingRevision","DressingReview",
   "FinalInstallerVersion","RuntimeReview","IntegrationReview","HeightRatioToStageOne"}) do model:SetAttribute(key,nil) end
  model:SetAttribute("EvolutionStage",4)
  model:SetAttribute("BuildScale",multiplier)
  model:SetAttribute("PipelinePhase",4)
  model:SetAttribute("QualityGateA","ApprovedByUser")
  model:SetAttribute("QualityGateB","Pending_UserGeometryReview")
  model:SetAttribute("QualityGateC","Pending_Stage4GameplayReview")
  model:SetAttribute("GeometryRevision","S4_OutwardSpinesToTailRoot_03")
  model:SetAttribute("VisualTarget","Approved Stage 4 front/side/back concept")
  model:SetAttribute("Purpose","Stage 4 geometry review; chest energy dressing follows Gate B")
  model.Parent=parent
 end)
 staging:Destroy()
 if not ok then if model then model:Destroy() end;error(err,0) end
 return model
end
return Builder
