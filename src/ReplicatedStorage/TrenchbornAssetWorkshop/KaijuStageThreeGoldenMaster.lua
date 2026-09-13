-- Stage 3: geometry and movement approved; Phase 5 dressing review.
local StageTwo=require(script.Parent:WaitForChild("KaijuStageTwoGoldenMaster"))
local Base=require(script.Parent:WaitForChild("KaijuEvolutionBlockout"))
local Builder={}
local NAME="Stage_3_Rift_Stalker"
local function soleY(model)
 local bottom=math.huge
 for _,side in ipairs({"Left","Right"}) do
  local p=assert(model:FindFirstChild(side.."ForefootCoreY"),"Missing sole")
  bottom=math.min(bottom,p.Position.Y-p.Size.Y/2)
 end
 return bottom
end
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
-- Keep the full armor foundation, then grow overlapping basalt layers and
-- unequal splinters from it, matching the shoulder/forearm construction.
local function wildPlate(model,name,width,height,depth,cf,sign)
 bevelPlate(model,name,width,height,depth,cf)
 for layer=1,2 do
  local offset=layer==1 and 0.20 or -0.22
  local roll=layer==1 and -9 or 7
  bevelPlate(model,name.."RockLayer"..layer,width*(layer==1 and 0.96 or 0.82),
   height*0.60,depth*0.64,
   cf*CFrame.new(sign*width*(layer==1 and 0.03 or -0.06),height*offset,-depth*0.46)
    *CFrame.Angles(0,0,math.rad(sign*roll)))
 end
 -- Canonical right-side roots are embedded in the foundation. Local +Y
 -- runs along each splinter; -Z remains the visible stone surface.
 local tips={
  {X=0.23,Y=0.25,DX=0.85,DY=0.40,Length=width*0.40,Width=height*0.38},
  {X=0.25,Y=-0.08,DX=0.95,DY=-0.32,Length=width*0.55,Width=height*0.44},
  {X=-0.08,Y=-0.35,DX=0.30,DY=-1.0,Length=height*0.34,Width=width*0.42},
 }
 for i,tip in ipairs(tips) do
  local axis=Vector3.new(tip.DX,tip.DY,0).Unit
  local across=axis:Cross(Vector3.zAxis)
  local root=Vector3.new(width*tip.X,height*tip.Y,-depth*0.08)
  local size=Vector3.new(tip.Width,tip.Length,depth*0.90)
  local localCF=CFrame.fromMatrix(root+axis*(tip.Length*0.30),
   across,axis,Vector3.zAxis)
  if sign<0 then
   local function mirror(v) return Vector3.new(-v.X,v.Y,v.Z) end
   localCF=CFrame.fromMatrix(mirror(localCF.Position),
    -mirror(localCF.ZVector),mirror(localCF.UpVector),-mirror(localCF.RightVector))
   size=Vector3.new(size.Z,size.Y,size.X)
  end
  local p=stone(model,name.."RockPoint"..i,size,cf*localCF)
  p.Color=Color3.fromRGB(63,67,70)
 end
end
function Builder.Build(parent,ground,options)
 local multiplier=Base.ResolveBuildScale(options)
 ground=ground or CFrame.identity
 assert(not parent:FindFirstChild(NAME),"Stage 3 already exists")
 local staging=Instance.new("Folder");staging.Name="StageThreeBuild";staging.Parent=parent
 local model
 local ok,err=pcall(function()
  model=StageTwo.Build(staging,CFrame.identity)
  local stageTwoScale=model:GetScale()
  model:ScaleTo(1)
  model.Name=NAME
  -- Broader/deeper anatomy with all attached armor and face pieces transformed together.
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") then
    local pos=p.Position
    local function stretch(v) return Vector3.new(v.X*1.06,v.Y,v.Z*1.10) end
    p.Size=Vector3.new(p.Size.X*stretch(p.CFrame.RightVector).Magnitude,
     p.Size.Y*stretch(p.CFrame.UpVector).Magnitude,
     p.Size.Z*stretch(p.CFrame.LookVector).Magnitude)
    p.CFrame=CFrame.new(stretch(pos))*p.CFrame.Rotation
   end
  end
  for _,name in ipairs({"UpperRibcage","LowerRibcage","DorsalLumbarMass","SacralMass","Neck"}) do
   local p=model:FindFirstChild(name)
   if p then p.Size=Vector3.new(p.Size.X*1.08,p.Size.Y,p.Size.Z*1.10) end
  end
  -- Broaden dorsal silhouettes; rebuild insets so their borders remain attached.
  for _,p in ipairs(model:GetChildren()) do
   if p.Name:match("^DorsalEnergy_") then p:Destroy() end
  end
  for i=1,11 do
   local plate=model:FindFirstChild(string.format("DorsalShield_%02d",i))
   if plate then
    local major=i<=3
    plate.Size=Vector3.new(plate.Size.X*(major and 1.55 or 1.2),
     plate.Size.Y*(major and 1.12 or 1.05),plate.Size.Z*(major and 1.13 or 1.06))
    local w,h,d=plate.Size.X,plate.Size.Y,plate.Size.Z
    for _,sign in ipairs({-1,1}) do
     local inset=0.30
     local energy=stone(model,string.format("DorsalEnergy_%02d_%s",i,sign<0 and "Left" or "Right"),
      Vector3.new(0.045,h*inset,d*inset),
      plate.CFrame*CFrame.new(sign*(w/2+0.024),-(1-inset)*h/6,(1-inset)*d/6),"WedgePart")
     energy.Material=Enum.Material.Neon;energy.Color=Color3.fromRGB(224,187,39)
     if i<=5 then
      -- Two staggered rock splinters form a wider, irregular dorsal cluster.
      for shard=1,(major and 2 or 1) do
       local width=(major and 0.85 or 0.55)*(shard==1 and 1 or 0.7)
       local chip=stone(model,string.format("DorsalRock_%02d_%s_%d",i,sign,shard),
        Vector3.new(width,h*(shard==1 and 0.65 or 0.42),d*(shard==1 and 0.68 or 0.44)),
        plate.CFrame*CFrame.new(sign*(w/2+width*0.20),-h*0.20,d*(shard==1 and 0.13 or -0.10))
         *CFrame.Angles(0,math.rad(sign*(shard==1 and 16 or 28)),0))
       chip.Color=Color3.fromRGB(68+shard*4,71+shard*3,73+shard*2)
      end
     end
    end
   end
  end
  for _,sign in ipairs({-1,1}) do
   local side=sign<0 and "Left" or "Right"
   local brow=model:FindFirstChild(side.."BrowRidge")
   -- Cap the actual brow top; use one common basis instead of inheriting mirrored roll.
   local browCF=CFrame.new(brow.Position+Vector3.new(0,brow.Size.Y/2+0.10,-0.08))
   stone(model,side.."HeadArmorBrowCore",Vector3.new(1.65,0.40,1.55),browCF,"Part")
   stone(model,side.."HeadArmorBrowBevel",Vector3.new(1.65,0.40,0.65),
    browCF*CFrame.new(0,0,-1.02),"WedgePart")
   local cheek=model:FindFirstChild(side.."CheekMass")
   -- Follow the SIDE of the cheek ellipsoid, not its front face next to the mouth.
   -- Broad, low scales overlap from beneath the eye toward the rear jaw.
   local half=cheek.Size/2
   for layer=1,2 do
    local ly=cheek.Size.Y*(layer==1 and 0.13 or 0.08)
    local lz=cheek.Size.Z*(layer==1 and -0.13 or 0.25)
    local lx=sign*half.X*math.sqrt(1-(ly/half.Y)^2-(lz/half.Z)^2)
    local point=cheek.CFrame:PointToWorldSpace(Vector3.new(lx,ly,lz))
    local normal=cheek.CFrame:VectorToWorldSpace(
     Vector3.new(lx/half.X^2,ly/half.Y^2,lz/half.Z^2)).Unit
    local up=Vector3.yAxis-normal*normal:Dot(Vector3.yAxis)
    up=up.Unit
    local right=normal:Cross(up).Unit
    local depth=cheek.Size.X*0.28
    local cf=CFrame.fromMatrix(point+normal*(depth*0.12),right,up,-normal)
    bevelPlate(model,side.."HeadArmorCheek_"..layer,
     cheek.Size.Z*(layer==1 and 0.60 or 0.42),
     cheek.Size.Y*(layer==1 and 0.40 or 0.28),depth,cf)
   end
   local x,y,z
   -- Follow the OUTSIDE of the pale pectoral/flank envelope, not the hidden rib core.
   local pec=model:FindFirstChild(side.."Pectoral")
   local flank=model:FindFirstChild(side.."Flank")
   local ribs=model:FindFirstChild("LowerRibcage")
   local belly=model:FindFirstChild("BellyShield")
   for i=1,2 do
    x=pec.Position.X+sign*pec.Size.X*(i==1 and 0.29 or 0.24)
    y=pec.Position.Y-pec.Size.Y*(i==1 and 0.23 or 0.38)
    local ribFrame=surfaceFrame({pec,flank,ribs,belly},x,y,0.08)
    wildPlate(model,side.."RibArmor_"..i,1.85*1.15,0.90*1.15,0.58,
     ribFrame*CFrame.Angles(0,0,sign*math.rad(6)),sign)
   end
   local thigh=model:FindFirstChild(side.."ThighMass")
   local quad=model:FindFirstChild(side.."OuterQuadriceps")
   local hip=model:FindFirstChild(side.."HipJoint")
   x=thigh.Position.X+sign*thigh.Size.X*0.28
   y=thigh.Position.Y+thigh.Size.Y*0.27
   local hipFrame=surfaceFrame({thigh,quad,hip},x,y,0.09)
   wildPlate(model,side.."HipArmor",2.05,2.5,0.70,hipFrame,sign)
   local knee=model:FindFirstChild(side.."KneeJoint")
   local hock=model:FindFirstChild(side.."HockJoint")
   local calf=model:FindFirstChild(side.."CalfMass")
   local center=knee.Position:Lerp(hock.Position,0.35)
   z=frontSurface({knee,calf},center.X,center.Y)
   -- Build an explicit forward-facing basis: local -Z follows projected body front.
   local up=(knee.Position-hock.Position).Unit
   local forward=Vector3.new(0,0,-1)
   forward=(forward-up*forward:Dot(up)).Unit
   local right=forward:Cross(up).Unit
   local shin=CFrame.fromMatrix(Vector3.new(center.X,center.Y,z-0.22),right,up,-forward)
   wildPlate(model,side.."ShinArmor",3.0,3.4,0.8,shin,sign)
  end
  -- Phase 5: dress the approved solids without changing their size or pose.
  local armorParts={}
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") and (p.Name:match("^[LR]%a+HeadArmor")
    or p.Name:match("^[LR]%a+RibArmor") or p.Name:match("^[LR]%a+HipArmor")
    or p.Name:match("^[LR]%a+ShinArmor") or p.Name:match("^DorsalRock_")) then
    table.insert(armorParts,p)
    p.Material=Enum.Material.Basalt;p.Reflectance=0
    if p.Name:find("Edge",1,true) or p.Name:find("Bevel",1,true) then
     p.Color=Color3.fromRGB(76,78,77)
    elseif p.Name:find("Point",1,true) then
     p.Color=Color3.fromRGB(63,67,70)
    elseif p.Name:find("RockLayer",1,true) or p.Name:match("^DorsalRock_") then
     p.Color=Color3.fromRGB(62,67,71)
    else
     p.Color=Color3.fromRGB(45,51,57)
    end
   end
  end
  -- Short recessed-looking fissures on lateral armor only; no chest-center core.
  -- Keep the existing region prefix so every seam follows its own animated bone.
  for _,p in ipairs(armorParts) do
   if p.Name:match("RockLayer1Core$") then
    local w,h,d=p.Size.X,p.Size.Y,p.Size.Z
    local sign=p.Name:sub(1,4)=="Left" and -1 or 1
    local z=-d/2-0.018
    local points={
     Vector3.new(-sign*w*0.39,h*0.21,z+0.055),
     Vector3.new(-sign*w*0.08,h*0.04,z),
     Vector3.new(sign*w*0.32,-h*0.18,z+0.055),
     Vector3.new(sign*w*0.02,-h*0.32,z+0.045),
    }
    for segment,ends in ipairs({{1,2},{2,3},{2,4}}) do
     local a=p.CFrame:PointToWorldSpace(points[ends[1]])
     local b=p.CFrame:PointToWorldSpace(points[ends[2]])
     local normal=p.CFrame.LookVector
     local cf=CFrame.lookAt((a+b)/2,b,normal)
     local length=(b-a).Magnitude+0.02
     local width=segment==3 and 0.045 or 0.065
     local prefix=p.Name.."Fissure"..segment
     local rim=stone(model,prefix.."Rim",Vector3.new(width+0.07,0.024,length),cf,"Part")
     rim.Color=Color3.fromRGB(26,30,35)
     local glow=stone(model,prefix.."Energy",Vector3.new(width,0.028,length),
      cf+normal*0.015,"Part")
     glow.Material=Enum.Material.Neon;glow.Color=Color3.fromRGB(220,175,32)
     glow.Transparency=0.18;glow.CastShadow=false
     glow:SetAttribute("KaijuArmorEnergy",true)
    end
   end
  end
  -- Connected growth remains articulated: every route keeps a region prefix.
  -- Project each sample onto the outer envelope of masses belonging to ONE bone.
  local function skinPoint(origin,direction,masses)
   local ray=direction.Unit
   local distance=-math.huge
   local normal
   for _,mass in ipairs(masses) do
    local o=mass.CFrame:PointToObjectSpace(origin)
    local v=mass.CFrame:VectorToObjectSpace(ray)
    local h=mass.Size/2
    local a=(v.X/h.X)^2+(v.Y/h.Y)^2+(v.Z/h.Z)^2
    local b=2*(o.X*v.X/h.X^2+o.Y*v.Y/h.Y^2+o.Z*v.Z/h.Z^2)
    local c=(o.X/h.X)^2+(o.Y/h.Y)^2+(o.Z/h.Z)^2-1
    local discriminant=b*b-4*a*c
    if discriminant>=0 then
     local t=(-b+math.sqrt(discriminant))/(2*a)
     if t>0 and t>distance then
      distance=t
      local hit=o+v*t
      normal=mass.CFrame:VectorToWorldSpace(Vector3.new(hit.X/h.X^2,hit.Y/h.Y^2,hit.Z/h.Z^2)).Unit
     end
    end
   end
   assert(normal,"Growth route missed body envelope")
   return origin+ray*distance,normal
  end
  local function vein(name,a,b,normal,width)
   local delta=b-a
   if delta.Magnitude<0.01 then return end
   local up=normal-delta.Unit*normal:Dot(delta.Unit)
   if up.Magnitude<0.001 then return end
   local cf=CFrame.lookAt((a+b)/2,b,up.Unit)
   local rim=stone(model,name.."Rim",Vector3.new(width+0.07,0.028,delta.Magnitude+0.025),cf,"Part")
   rim.Color=Color3.fromRGB(29,32,35)
   local glow=stone(model,name.."Energy",Vector3.new(width,0.032,delta.Magnitude+0.025),
    cf+up.Unit*0.019,"Part")
   glow.Material=Enum.Material.Neon;glow.Color=Color3.fromRGB(220,175,32)
   glow.Transparency=0.18;glow.CastShadow=false;glow:SetAttribute("KaijuArmorEnergy",true)
  end
  local function route(name,masses,directions,grow)
   local points,normals={},{}
   for i=1,#directions-1 do
    for j=0,3 do
     if i==1 or j>0 then
      local point,normal=skinPoint(masses[1].Position,directions[i]:Lerp(directions[i+1],j/3),masses)
      table.insert(points,point+normal*0.025);table.insert(normals,normal)
     end
    end
   end
   for i=1,#points-1 do
    vein(name.."Path"..i,points[i],points[i+1],normals[i]+normals[i+1],0.085)
   end
   if grow then
    -- Buried broad roots and overlapping caps connect the shoulder to the elbow.
    for layer,index in ipairs({2,4,6}) do
     local normal=normals[index]
     local up=(points[index-1]-points[index+1]).Unit
     up=(up-normal*up:Dot(normal)).Unit
     local cf=CFrame.fromMatrix(points[index]-normal*0.04,normal:Cross(up).Unit,up,-normal)
     local height=(points[index-1]-points[index+1]).Magnitude*1.12
     local width=layer==2 and 1.65 or 1.40
     bevelPlate(model,name.."RockLayer"..layer,width,height,0.55,cf)
     local a=cf:PointToWorldSpace(Vector3.new(-0.18,height*0.30,-0.31))
     local b=cf:PointToWorldSpace(Vector3.new(0.12,-height*0.32,-0.31))
     vein(name.."RockVein"..layer,a,b,normal,0.085)
    end
   end
  end
  for _,sign in ipairs({-1,1}) do
   local side=sign<0 and "Left" or "Right"
   local outward=Vector3.new(sign,0,0)
   local shoulder=model[side.."ShoulderJoint"].Position
   local elbow=model[side.."ElbowJoint"].Position
   local wrist=model[side.."WristJoint"].Position
   local upperAxis=(elbow-shoulder).Unit
   local lowerAxis=(wrist-elbow).Unit
   route(side.."ShoulderArmorGrowth",{model[side.."BicepsMass"],model[side.."Deltoid"]},
    {outward-upperAxis*2.2,outward, outward+upperAxis*2.5},true)
   route(side.."ForearmArmorGrowth",{model[side.."ForearmMass"],model[side.."ElbowJoint"]},
    {outward-lowerAxis*2.5,outward, outward+lowerAxis*0.8},false)
   route(side.."RibArmorGrowth",{model.UpperRibcage,model.LowerRibcage,model[side.."Flank"],model[side.."Pectoral"]},
    {Vector3.new(sign*0.15,0.3,1),Vector3.new(sign*0.8,0.25,0.6),
     Vector3.new(sign,0.05,0),Vector3.new(sign*0.9,-0.15,-0.65),Vector3.new(sign*0.65,-0.35,-1)},false)
   route(side.."HipArmorGrowth",{model[side.."ThighMass"],model[side.."OuterQuadriceps"],model[side.."HipJoint"]},
    {Vector3.new(sign*0.8,1,-0.5),Vector3.new(sign*0.7,0,-1),Vector3.new(sign*0.35,-2,-0.8)},false)
   route(side.."ShinArmorGrowth",{model[side.."CalfMass"],model[side.."KneeJoint"]},
    {Vector3.new(sign*0.35,2,-0.8),Vector3.new(sign*0.5,0.4,-1),Vector3.new(sign*0.2,-0.7,-1)},false)
  end
  -- Relative authored size: 12% above Stage 2, then the user-controlled multiplier.
  model:ScaleTo(stageTwoScale*1.12*multiplier)
  model:PivotTo(model:GetPivot()+Vector3.new(0,-soleY(model),0))
  model:PivotTo(ground*model:GetPivot())
  for _,key in ipairs({"ApprovedGeometryCommit","ApprovedRevision","DressingRevision","DressingReview",
   "FinalInstallerVersion","RuntimeReview","IntegrationReview","HeightRatioToStageOne"}) do model:SetAttribute(key,nil) end
  model:SetAttribute("EvolutionStage",3)
  model:SetAttribute("BuildScale",multiplier)
  model:SetAttribute("PipelinePhase",5)
  model:SetAttribute("QualityGateA","ApprovedByUser")
  model:SetAttribute("QualityGateB","Pending_GrowthTransitions")
  model:SetAttribute("QualityGateC","Pending_GrowthTransitions")
  model:SetAttribute("GeometryRevision","S3_ArticulatedArmorGrowth_13")
  model:SetAttribute("VisualTarget","Approved Stage 3 front/side/back concept; lateral rib armor amendment")
  model:SetAttribute("RuntimeReview","Pending_GrowthTransitions")
  model:SetAttribute("DressingRevision","S3_ConnectedFissures_02")
  model:SetAttribute("DressingReview","Pending")
  model:SetAttribute("Purpose","Stage 3 material and energy dressing review")
  model.Parent=parent
 end)
 staging:Destroy()
 if not ok then if model then model:Destroy() end;error(err,0) end
 return model
end
return Builder
