-- Phase 4 Golden Master; Stage 4 geometry approved by the user on 2026-09-14.
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
local function frontSurface(parts,x,y,rear)
 local front=rear and -math.huge or math.huge
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
   local hit=(-b+(rear and 1 or -1)*math.sqrt(disc))/(2*a)
   if (rear and hit>front) or (not rear and hit<front) then
    front=hit
    local point=o+d*hit
    surfaceNormal=p.CFrame:VectorToWorldSpace(
     Vector3.new(point.X/h.X^2,point.Y/h.Y^2,point.Z/h.Z^2)).Unit
   end
  end
 end
 assert(math.abs(front)<math.huge,"Armor surface sample missed its body mass")
 return front,surfaceNormal
end
local function surfaceFrame(parts,x,y,inset,rear)
 local z,normal=frontSurface(parts,x,y,rear)
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
  -- Widen the complete face together so sockets, pupils, jaw and armor
  -- remain aligned. Preserve its height and the established predator profile.
  local headFrame=CFrame.new(model.Cranium.Position)
  for _,prefix in ipairs({"Cranium","SnoutBridge","FrontalBridge","UpperMuzzle","LowerJaw",
   "LeftCheekMass","RightCheekMass","LeftOrbitalSupport","RightOrbitalSupport",
   "LeftBrowRidge","RightBrowRidge","LeftEye","RightEye","LeftPupil","RightPupil",
   "LeftNostril","RightNostril","LeftHeadArmor","RightHeadArmor"}) do
   enlargeGroup(model,prefix,headFrame,Vector3.new(1.06,1,1))
  end
  local neck=model.Neck
  neck.Size=Vector3.new(neck.Size.X*1.22,neck.Size.Y,neck.Size.Z*1.20)
  local nape=model:FindFirstChild("NapeFlow")
  if nape then nape.Size=Vector3.new(nape.Size.X*1.24,nape.Size.Y*1.06,nape.Size.Z*1.20) end
  local neckMasses={neck,model.UpperRibcage,model.Cranium}
  if nape then table.insert(neckMasses,nape) end
  -- Two low overlapping nape segments bridge toward the dorsal crest.
  -- RibArmor follows Torso, while the rear-skull plates follow Head.
  for row,offset in ipairs({0.18,-0.12}) do
   local height=neck.Size.Y*0.34
   local cf=surfaceFrame(neckMasses,0,neck.Position.Y+neck.Size.Y*offset,0.22,true)
   bevelPlate(model,"LeftRibArmorStage4Nape"..row,neck.Size.X*(row==1 and 0.86 or 0.98),height,0.95,cf)
  end
  for _,sign in ipairs({-1,1}) do
   local side=sign<0 and "Left" or "Right"
   local skull=model.Cranium
   local rearFrame=surfaceFrame(neckMasses,sign*skull.Size.X*0.34,
    skull.Position.Y,0.24,true)*CFrame.Angles(0,sign*math.rad(12),0)
   bevelPlate(model,side.."HeadArmorStage4RearSkull",skull.Size.X*0.38,skull.Size.Y*0.52,0.82,rearFrame)
   local browCore=model[side.."HeadArmorBrowCore"]
   -- Grow upward from the brow's lower edge to keep the eye opening clear.
   local browBase=browCore.CFrame*CFrame.new(0,-browCore.Size.Y/2,0)
   enlargeGroup(model,side.."HeadArmorBrow",browBase,Vector3.new(1.12,1.30,1.08))
   -- The old rear-facing jaw wedge was hidden behind the cheek/neck.
   -- Move the armor forward along the lower jaw and seat it beyond the
   -- visible side envelope, while keeping the entire assembly on Jaw.
   local jaw=model.LowerJawRear
   local y=jaw.Position.Y-jaw.Size.Y*0.18
   local z=jaw.Position.Z-jaw.Size.Z*0.24
   local outer=-math.huge
   for _,mass in ipairs({jaw,model[side.."CheekMass"],neck}) do
    local o=mass.CFrame:PointToObjectSpace(Vector3.new(0,y,z))
    local d=mass.CFrame:VectorToObjectSpace(Vector3.new(sign,0,0))
    local h=mass.Size/2
    local a=(d.X/h.X)^2+(d.Y/h.Y)^2+(d.Z/h.Z)^2
    local b=2*(o.X*d.X/h.X^2+o.Y*d.Y/h.Y^2+o.Z*d.Z/h.Z^2)
    local c=(o.X/h.X)^2+(o.Y/h.Y)^2+(o.Z/h.Z)^2-1
    local disc=b*b-4*a*c
    if disc>=0 then outer=math.max(outer,(-b+math.sqrt(disc))/(2*a)) end
   end
   assert(outer>-math.huge,"Jaw armor side sample missed body")
   local normal=Vector3.new(sign,0,0)
   local cf=CFrame.fromMatrix(Vector3.new(sign*(outer+0.18),y,z),
    normal:Cross(Vector3.yAxis),Vector3.yAxis,-normal)
   local width=jaw.Size.Z*0.82
   local height=jaw.Size.Y*0.60
   local name="LowerJawStage4Angle"..side
   bevelPlate(model,name,width,height,0.88,cf)
   bevelPlate(model,name.."RaisedFace",width*0.82,height*0.72,0.56,
    cf*CFrame.new(0,-height*0.04,-0.57))
  end
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
  -- Replace the small lateral rib plates with four broad chest-to-belly segments per side.
  -- Keep the inherited back/flank routes; no central reactor or skull crown.
  for _,p in ipairs(model:GetChildren()) do
   if p.Name:match("^LeftRibArmor_%d") or p.Name:match("^RightRibArmor_%d") then p:Destroy() end
  end
  for _,sign in ipairs({-1,1}) do
   local side=sign<0 and "Left" or "Right"
   local pec=model[side.."Pectoral"]
   local masses={pec,model[side.."Flank"],model.UpperRibcage,model.LowerRibcage,model.BellyShield}
   local shoulder=model[side.."ShoulderJoint"]
   -- Broaden toward the shoulder while retaining the central seam. Four
   -- descending tiers taper onto the belly and remain in the RibArmor region.
   local innerEdge=0.18
   local outerEdge=math.abs(shoulder.Position.X)-shoulder.Size.X*0.06
   local tiers={
    {Y=0.29,Width=1.00},
    {Y=-0.08,Width=0.98},
    {Y=-0.45,Width=0.90},
    {Y=-0.82,Width=0.78},
   }
   for row,tier in ipairs(tiers) do
    local width=(outerEdge-innerEdge)*tier.Width
    local height=pec.Size.Y*0.34
    local x=sign*(innerEdge+width/2)
    local y=pec.Position.Y+pec.Size.Y*tier.Y
    local frame=surfaceFrame(masses,x,y,0.30)*CFrame.Angles(0,0,sign*math.rad(5))
    -- Keep shallow gaps between broad tiers as the armor descends to the belly.
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
   -- Broad hip lames sit on the visible thigh/hip envelope, not inside
   -- the overlapping quadriceps. Both rows follow the Thigh region.
   local thigh=model[side.."ThighMass"]
   local hip=model[side.."HipJoint"]
   local quad=model:FindFirstChild(side.."OuterQuadriceps")
   local hipMasses={thigh,hip}
   if quad then table.insert(hipMasses,quad) end
   for row,vertical in ipairs({0.24,-0.04}) do
    local width=thigh.Size.X*(row==1 and 0.80 or 0.68)
    local height=thigh.Size.Y*0.30
    local cf=surfaceFrame(hipMasses,thigh.Position.X+sign*thigh.Size.X*0.22,
     thigh.Position.Y+thigh.Size.Y*vertical,0.26)
     *CFrame.Angles(0,0,sign*math.rad(row==1 and 12 or 7))
    local name=side.."HipArmorStage4Lame"..row
    bevelPlate(model,name,width,height,1.05,cf)
    bevelPlate(model,name.."RaisedFace",width*0.78,height*0.72,0.62,
     cf*CFrame.new(0,height*0.08,-0.66))
   end
   -- A distinct angular kneecap reads above the shin armor. Keep its
   -- height within the knee mass and all parts on the Shin region.
   local knee=model[side.."KneeJoint"]
   local kneeFrame=surfaceFrame({knee,model[side.."CalfMass"],thigh},
    knee.Position.X,knee.Position.Y,0.28)
   local kneeWidth=knee.Size.X*0.94
   local kneeHeight=knee.Size.Y*0.72
   local kneeName=side.."ShinArmorStage4Kneecap"
   bevelPlate(model,kneeName,kneeWidth,kneeHeight,1.12,kneeFrame)
   bevelPlate(model,kneeName.."RaisedFace",kneeWidth*0.72,kneeHeight*0.78,0.72,
    kneeFrame*CFrame.new(0,kneeHeight*0.06,-0.76))
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
   local backMasses={}
   for _,massName in ipairs({"Neck","NapeFlow","UpperRibcage","LowerRibcage","DorsalLumbarMass",
    "SacralMass","TailRootMass","LeftFlank","RightFlank"}) do
    local body=model:FindFirstChild(massName)
    if body then table.insert(backMasses,body) end
   end
   -- One mirrored pair per dorsal plate; DorsalRock indices inherit the
   -- same Torso/Tail bone as that plate in KaijuSkeleton.
   for i=1,11 do
    local plate=assert(model:FindFirstChild(string.format("DorsalShield_%02d",i)),"Missing dorsal plate "..i)
    local width=math.clamp(plate.Size.Y*0.55,0.32,1.8)
    local length=math.clamp(plate.Size.Y*0.78,0.42,3.0)
    local depth=math.min(0.70,width*0.40)
    local cf
    if i<=3 then
     -- Place the pair just below each major plate along the back surface.
     local x=sign*(plate.Size.X/2+0.55)
     local y=plate.Position.Y-plate.Size.Y*0.38
     cf=surfaceFrame(backMasses,x,y,depth*0.22,true)
    else
     local segment=assert(model:FindFirstChild(string.format("TailSegment_%02d",i-2)),"Missing dorsal tail segment "..i)
     local along=segment.CFrame.RightVector
     local nextPart=model:FindFirstChild(string.format("TailSegment_%02d",i-1)) or model.TailTip
     if along:Dot(nextPart.Position-segment.Position)<0 then along=-along end
     local top=(Vector3.yAxis-along*along.Y).Unit
     local sideAxis=(Vector3.xAxis-along*along.X).Unit
     local normal=(top+sideAxis*sign*0.78).Unit
     -- Tail bodies are cylinders, whose length is local X. Seat at the
     -- cross-section toward the trailing end, immediately after its plate.
     local localNormal=segment.CFrame:VectorToObjectSpace(normal)
     local radius=1/math.sqrt((localNormal.Y/(segment.Size.Y/2))^2
      +(localNormal.Z/(segment.Size.Z/2))^2)
     local point=segment.Position+along*(segment.Size.X*0.28)+normal*(radius+depth*0.22)
     local up=(along-normal*normal:Dot(along)).Unit
     cf=CFrame.fromMatrix(point,normal:Cross(up).Unit,up,-normal)
    end
    local name=string.format("DorsalRock_%02d_SideSpine_%s",i,side)
    bevelPlate(model,name,width,width*1.17,depth,cf)
    bevelPlate(model,name.."Overlap",width*0.82,width*1.17*0.70,depth*0.62,
     cf*CFrame.new(0,width*1.17*0.16,-depth*0.52))
    local axis=(cf.LookVector+Vector3.new(sign*0.40,0.40,0)).Unit
    local up=(Vector3.yAxis-axis*axis.Y).Unit
    local center=cf.Position+axis*(length/2-depth*0.25)
    stone(model,name.."Shard",Vector3.new(width*0.69,width*0.81,length),
     CFrame.lookAt(center,center+axis,up),"WedgePart")
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
  model:SetAttribute("LateralSpinePairCount",11)
  model:SetAttribute("EvolutionStage",4)
  model:SetAttribute("BuildScale",multiplier)
  model:SetAttribute("PipelinePhase",4)
  model:SetAttribute("QualityGateA","ApprovedByUser")
  model:SetAttribute("QualityGateB","ApprovedByUser")
  model:SetAttribute("ApprovedGeometryCommit","6badd010b0a0650bdbe0b7f21ab90e58d23741e7")
  model:SetAttribute("ApprovedRevision","S4_VisibleLowerJawArmor_10")
  model:SetAttribute("QualityGateC","Pending_Stage4GameplayReview")
  model:SetAttribute("GeometryRevision","S4_VisibleLowerJawArmor_10")
  model:SetAttribute("VisualTarget","Approved Stage 4 front/side/back concept")
  model:SetAttribute("Purpose","Stage 4 approved geometry; ready for surface dressing")
  model.Parent=parent
 end)
 staging:Destroy()
 if not ok then if model then model:Destroy() end;error(err,0) end
 return model
end
return Builder
