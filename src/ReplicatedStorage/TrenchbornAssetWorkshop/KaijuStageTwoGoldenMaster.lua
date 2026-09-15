-- Phase 4 Storm Hunter geometry. Stage 1 is built in isolation and never edited in-place.
local StageOne=require(script.Parent:WaitForChild("KaijuEvolutionBlockout"))
local Builder={}
local NAME="Stage_2_Storm_Hunter"
local function newPart(model,class,name,size,cf)
 local p=Instance.new(class);p.Name=name;p.Size=size;p.CFrame=cf
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 p.Material=Enum.Material.Basalt;p.Color=Color3.fromRGB(68,67,64)
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=model
 return p
end
local function isHead(name)
 if name=="Cranium" or name=="SnoutBridge" or name=="FrontalBridge" or name=="LowerJawRear" then return true end
 if name:match("^UpperMuzzle") or name:match("^LowerJawFront") then return true end
 for _,feature in ipairs({"CheekMass","OrbitalSupport","BrowRidge","EyeSocket","Eye","Pupil","EyeHighlight","Nostril"}) do
  if name=="Left"..feature or name=="Right"..feature then return true end
 end
 return false
end
local function soles(model)
 local y=math.huge
 for _,side in ipairs({"Left","Right"}) do
  local p=assert(model:FindFirstChild(side.."ForefootCoreY"),"Missing sole")
  y=math.min(y,p.CFrame:PointToWorldSpace(Vector3.new(0,-p.Size.Y/2,0)).Y)
 end
 return y
end
function Builder.Build(parent,ground,options)
 local buildScale=StageOne.ResolveBuildScale(options)
 ground=ground or CFrame.identity
 assert(not parent:FindFirstChild(NAME),"Storm Hunter already exists in this parent")
 local staging=Instance.new("Folder");staging.Name="StormHunterBuild";staging.Parent=parent
 local model
 local ok,err=pcall(function()
  local collection=StageOne.BuildStage(staging,1,CFrame.identity)
  model=assert(collection:FindFirstChild("Stage_1_Primal_Beast"),"Missing lineage source")
  local sourceHeight=model.Cranium.Position.Y+model.Cranium.Size.Y/2-soles(model)
  model:ScaleTo(1)
  model:PivotTo(model:GetPivot()+Vector3.new(0,-soles(model),0))
  model.Name=NAME
  local hipY=model.PelvisCenter.Position.Y
  local headAnchor=model.Neck.Position
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") then
    if p.Name:match("^DorsalEnergy_") then p:Destroy()
    else
     local pos=p.Position
     local stretchY=pos.Y<hipY and 1.10 or 1.02
     local y=pos.Y<hipY and pos.Y*1.10 or hipY*1.10+(pos.Y-hipY)*1.02
     local waist=math.max(0,1-math.abs(pos.Y-(hipY+3))/5)
     local sx=1.07-0.17*waist
     local sz=1-0.08*waist
     local mapped=Vector3.new(pos.X*sx,y,pos.Z*sz-math.max(0,pos.Y-hipY)*0.07)
     if isHead(p.Name) then
      -- Transform the complete face together so eyes and rounded-box pieces stay attached.
      mapped=Vector3.new(headAnchor.X,hipY*1.10+(headAnchor.Y-hipY)*1.02,headAnchor.Z-1.05)+(pos-headAnchor)*1.06
      p.Size=p.Size*1.06
     else
      local function length(axis)
       return Vector3.new(axis.X*sx,axis.Y*stretchY,axis.Z*sz).Magnitude
      end
      p.Size=Vector3.new(p.Size.X*length(p.CFrame.RightVector),p.Size.Y*length(p.CFrame.UpVector),p.Size.Z*length(p.CFrame.LookVector))
     end
     p.CFrame=CFrame.new(mapped)*p.CFrame.Rotation
    end
   end
  end
  -- Longer visible cylinder tail. Scale segment lengths with their center spacing.
  local tailRoot=model.TailRootMass.Position
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") and (p.Name:match("^TailSegment_") or p.Name=="TailTip") then
    local pos=tailRoot+(p.Position-tailRoot)*1.12
    p.CFrame=CFrame.new(pos)*p.CFrame.Rotation
    if p.Name=="TailTip" then p.Size=p.Size*1.12 else p.Size=Vector3.new(p.Size.X*1.15,p.Size.Y,p.Size.Z) end
   end
  end
  -- Retain the proven wedge orientation and move each tail plate with its segment.
  for i=1,11 do
   local plate=model:FindFirstChild(string.format("DorsalShield_%02d",i))
   if plate then
    if i>=4 then
     plate.CFrame=CFrame.new(tailRoot+(plate.Position-tailRoot)*1.12)*plate.CFrame.Rotation
    end
    local variation=({1.08,1.16,0.94,1.12,0.95,1.06,0.92,1.02,0.9,1.0,0.9})[i]
    plate.Size=Vector3.new(plate.Size.X,plate.Size.Y*variation,plate.Size.Z*1.06)
    local h,d,w=plate.Size.Y,plate.Size.Z,plate.Size.X
    -- Small bilateral yellow inset: basalt dominates, with no floating glow layer.
    local inset=0.30
    for _,sign in ipairs({-1,1}) do
     local glow=newPart(model,"WedgePart",string.format("DorsalEnergy_%02d_%s",i,sign<0 and "Left" or "Right"),
      Vector3.new(0.045,h*inset,d*inset),plate.CFrame*CFrame.new(sign*(w/2+0.024),-(1-inset)*h/6,(1-inset)*d/6))
     glow.Material=Enum.Material.Neon;glow.Color=Color3.fromRGB(224,187,39)
    end
   end
  end
  for _,sign in ipairs({-1,1}) do
   local side=sign<0 and "Left" or "Right"
   local shoulder=model:FindFirstChild(side.."Deltoid")
   local forearm=model:FindFirstChild(side.."ForearmMass")
   -- Broad, uneven basalt facets form a football-pad silhouette above the deltoid.
   -- Local Y is plate thickness; broad X/Z faces overlap along the shoulder arc.
   local rx,ry=shoulder.Size.X/2,shoulder.Size.Y/2
   for layer,angle in ipairs({12,43,76}) do
    local theta=math.rad(angle)
    local normal=Vector3.new(sign*math.sin(theta)/rx,math.cos(theta)/ry,0).Unit
    local tangent=Vector3.new(normal.Y,-normal.X,0)
    local center=Vector3.new(sign*rx*math.sin(theta),ry*math.cos(theta),({-0.15,-0.5,0.35})[layer])
    local cf=shoulder.CFrame*CFrame.fromMatrix(center,tangent,normal,Vector3.zAxis)
    local width=({3.3,3.6,2.6})[layer]
    local depth=({2.8,3.5,2.4})[layer]
    local thickness,bevel=({0.75,0.95,0.7})[layer],({0.85,1.0,0.7})[layer]
    local name=side.."ShoulderArmor_"..layer
    -- The mineral root stays beneath its cap and enters the shoulder directly.
    -- No skin-coloured solids or rounded flesh appear between armor facets.
    newPart(model,"Part",name.."Root",Vector3.new(width*0.9,1.15,depth*0.9),
     cf*CFrame.new(0,-0.65,0))
    newPart(model,"Part",name.."Core",Vector3.new(width,thickness,depth),cf)
    -- Longer corner bevels replace the full-width square front/back ends.
    newPart(model,"CornerWedgePart",name.."FrontBevel",Vector3.new(width,bevel,thickness),
     cf*CFrame.new(0,0,-(depth+bevel)/2+0.12)*CFrame.Angles(-math.pi/2,0,0))
    newPart(model,"CornerWedgePart",name.."BackBevel",Vector3.new(width,bevel,thickness),
     cf*CFrame.new(0,0,(depth+bevel)/2-0.12)*CFrame.Angles(math.pi/2,0,0))
    for _,edge in ipairs({-1,1}) do
     newPart(model,"WedgePart",name.."SideBevel"..edge,Vector3.new(depth,thickness,0.24),
      cf*CFrame.new(edge*(width+0.24)/2,0,0)*CFrame.Angles(0,-edge*math.pi/2,0))
    end
   end
   -- Corner-wedge apexes run laterally out from buried, broad shoulder roots.
   -- Y is tip length before rotation; the final +Y axis points outward.
   local pointRotation=CFrame.Angles(0,-sign*math.pi/2,0)*CFrame.Angles(-math.pi/2,0,0)
   -- Correct the left corner's fore/aft sweep without reversing its outward apex.
   -- Local Y is the longitudinal tip axis; rolling around it preserves the root.
   if sign<0 then pointRotation=pointRotation*CFrame.Angles(0,math.pi,0) end
   local wing=shoulder.CFrame*CFrame.new(sign*(rx+0.45),ry*0.56,-0.1)
    *pointRotation
   newPart(model,"CornerWedgePart",side.."ShoulderArmorLateralPoint",
    Vector3.new(4.5,3.5,1.35),wing)
   newPart(model,"CornerWedgePart",side.."ShoulderArmorRearFacet",
    Vector3.new(2.0,2.8,0.85),
    shoulder.CFrame*CFrame.new(sign*(rx+0.2),ry*0.56+0.45,1.45)
     *pointRotation)
   -- The armor follows wrist -> elbow and continues beyond it along the same axis.
   local elbow=model:FindFirstChild(side.."ElbowJoint").Position
   local wrist=model:FindFirstChild(side.."WristJoint").Position
   local delta=elbow-wrist
   local axis=delta.Unit
   local outward=forearm.CFrame.RightVector*sign
   outward=(outward-axis*outward:Dot(axis)).Unit
   local surfaceOffset=outward*(forearm.Size.X*0.43)
   local start=wrist+axis*(delta.Magnitude*0.15)+surfaceOffset
   local finish=elbow+axis*0.25+surfaceOffset
   local length=(finish-start).Magnitude
   local guard=CFrame.lookAt((start+finish)/2,(start+finish)/2+axis,outward)
   -- Local Z is longitudinal, local Y is armor thickness on the outside of the arm.
   newPart(model,"Part",side.."ForearmArmorRoot",Vector3.new(2.0,1.6,length*0.94),
    guard*CFrame.new(0,-0.6,0))
   newPart(model,"Part",side.."ForearmArmorCore",Vector3.new(2.15,1.5,length),guard)
   -- Flat triangular side facets widen toward the elbow, narrow toward the wrist.
   -- Local X becomes thickness, Y becomes lateral width, +Z faces the elbow.
   for _,edge in ipairs({-1,1}) do
    local flankLength=length*(edge<0 and 0.94 or 0.82)
    newPart(model,"WedgePart",side.."ForearmArmorSideFacet"..edge,
     Vector3.new(1.35,0.8,flankLength),
     guard*CFrame.new(edge*1.45,-0.075,-(length-flankLength)/2)
      *CFrame.Angles(0,math.pi,0)*CFrame.Angles(0,0,edge*math.pi/2))
   end
   -- Broad elbow bridge joins the three existing tips without widening the wrist.
   newPart(model,"Part",side.."ForearmArmorElbowBridge",
    Vector3.new(3.55,1.4,length*0.20),
    guard*CFrame.new(0,-0.05,-length*0.40))
   newPart(model,"WedgePart",side.."ForearmArmorWristTaper",Vector3.new(2.15,1.5,1.2),
    guard*CFrame.new(0,0,(length+1.2)/2-0.12)*CFrame.Angles(0,math.pi,0))
   -- Corner wedges taper across both the width and length of each basalt tip.
   -- Unequal lengths and thicknesses break the rectangular side silhouette.
   -- Keep their bases overlapping the core and their long axes beyond the elbow.
   local tips={
    {X=-1.10,Width=1.50,Length=2.20,Thickness=1.35},
    {X=0,Width=1.50,Length=3.20,Thickness=1.85},
    {X=1.10,Width=1.50,Length=2.65,Thickness=1.50},
   }
   for i,tip in ipairs(tips) do
    newPart(model,"CornerWedgePart",side.."ForearmArmorElbowExtension_"..i,
     -- Local +Y (the apex) points along guard -Z, from wrist past elbow.
     -- Swap height/depth to preserve the longitudinal length after rotation.
     Vector3.new(tip.Width,tip.Length,tip.Thickness),
     guard*CFrame.new(tip.X,(tip.Thickness-1.5)/2,-(length+tip.Length)/2+0.25)
      *CFrame.Angles(-math.pi/2,0,0))
   end
  end
  -- Phase 5 dressing: preserve every approved solid and its transform.
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") and p.Name:find("Armor",1,true) then
    p.Material=Enum.Material.Basalt
    p.Reflectance=0
    if p.Name:find("Root",1,true) then
     p.Color=Color3.fromRGB(38,42,47)
    elseif p.Name:find("Bevel",1,true) or p.Name:find("Facet",1,true) then
     p.Color=Color3.fromRGB(76,78,77)
    elseif p.Name:find("Point",1,true) or p.Name:find("Extension",1,true) then
     p.Color=Color3.fromRGB(63,67,70)
    else
     p.Color=Color3.fromRGB(53,58,62)
    end
   end
  end
  -- Branching mineral fissures: dark edges frame a narrow luminous core.
  -- Ends dip into existing stone, interrupting the glow between armor layers.
  local function seam(surface,name,points,width)
   for i=1,#points-1 do
    local a=surface.CFrame:PointToWorldSpace(points[i])
    local b=surface.CFrame:PointToWorldSpace(points[i+1])
    local cf=CFrame.lookAt((a+b)/2,b,surface.CFrame.UpVector)
    local span=(b-a).Magnitude+0.025
    local rim=newPart(model,"Part",name.."Edge_"..i,Vector3.new(width+0.10,0.025,span),cf)
    rim.Color=Color3.fromRGB(29,32,35)
    local p=newPart(model,"Part",name.."Core_"..i,Vector3.new(width,0.028,span),
     cf+surface.CFrame.UpVector*0.018)
    p.Material=Enum.Material.Neon
    p.Color=Color3.fromRGB(220,175,32)
    p.Transparency=0.12
    p.CastShadow=false
    p:SetAttribute("KaijuArmorEnergy",true)
   end
  end
  for _,side in ipairs({"Left","Right"}) do
   local sign=side=="Left" and -1 or 1
   for layer=1,3 do
    local shoulder=model:FindFirstChild(side.."ShoulderArmor_"..layer.."Core")
    local y=shoulder.Size.Y/2+0.012
    local w,d=shoulder.Size.X,shoulder.Size.Z
    local prefix=side.."ShoulderArmorEnergy_"..layer.."_"
    seam(shoulder,prefix.."Main_",{
     Vector3.new(-sign*w*0.42,y-0.08,-d*0.34),
     Vector3.new(-sign*w*0.16,y,-d*0.18),
     Vector3.new(sign*w*0.03,y,d*0.02),
     Vector3.new(sign*w*0.23,y,d*0.15),
     Vector3.new(sign*w*0.43,y-0.08,d*0.32)},0.18)
    seam(shoulder,prefix.."Branch_",{
     Vector3.new(sign*w*0.03,y,d*0.02),
     Vector3.new(-sign*w*0.02,y,d*0.24),
     Vector3.new(sign*w*0.12,y-0.07,d*0.44)},0.095)
   end
   local arm=model:FindFirstChild(side.."ForearmArmorCore")
   local y=arm.Size.Y/2+0.012
   local length=arm.Size.Z
   local prefix=side.."ForearmArmorEnergy_"
   seam(arm,prefix.."Main_",{
    Vector3.new(sign*0.30,y-0.09,-length*0.46),
    Vector3.new(sign*0.14,y,-length*0.29),
    Vector3.new(sign*0.48,y,-length*0.10),
    Vector3.new(sign*0.12,y,length*0.08),
    Vector3.new(sign*0.30,y,length*0.24),
    Vector3.new(sign*0.08,y-0.08,length*0.43)},0.22)
   seam(arm,prefix.."UpperBranch_",{
    Vector3.new(sign*0.48,y,-length*0.10),
    Vector3.new(sign*0.77,y,-length*0.17),
    Vector3.new(sign*1.00,y-0.08,-length*0.26)},0.11)
   seam(arm,prefix.."LowerBranch_",{
    Vector3.new(sign*0.12,y,length*0.08),
    Vector3.new(-sign*0.34,y,length*0.15),
    Vector3.new(-sign*0.85,y-0.08,length*0.10)},0.095)
  end
  local currentHeight=model.Cranium.Position.Y+model.Cranium.Size.Y/2-soles(model)
  model:ScaleTo(model:GetScale()*sourceHeight*1.12/currentHeight)
  -- Lower the complete face after sizing the body so the torso does not grow.
  local headDrop=1.25*model:GetScale()
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") then
    if isHead(p.Name) then
     p.CFrame=p.CFrame+Vector3.new(0,-headDrop,0)
    elseif p.Name=="Neck" or p.Name=="ThroatShield" then
     -- Shorten from the top; preserve the existing overlap with the chest.
     local reduction=math.min(headDrop,p.Size.Y*0.30)
     p.Size=Vector3.new(p.Size.X,p.Size.Y-reduction,p.Size.Z)
     p.CFrame=p.CFrame+Vector3.new(0,-reduction/2,0)
    end
   end
  end
  model:PivotTo(model:GetPivot()+Vector3.new(0,-soles(model),0))
  -- Apply the optional build multiplier before rigging; keep the soles on ground.
  model:ScaleTo(model:GetScale()*buildScale)
  model:PivotTo(model:GetPivot()+Vector3.new(0,-soles(model),0))
  model:SetAttribute("BuildScale",buildScale)
  model:PivotTo(ground*model:GetPivot())
  -- Replace inherited Stage 1 metadata with the approved Stage 2 geometry baseline.
  for _,name in ipairs({"ApprovedGeometryCommit","DressingRevision","DressingReview","GeometryAmendmentReview"}) do model:SetAttribute(name,nil) end
  model:SetAttribute("EvolutionStage",2)
  model:SetAttribute("PipelinePhase",5)
  model:SetAttribute("QualityGateA","ApprovedByUser")
  model:SetAttribute("QualityGateB","ApprovedByUser")
  model:SetAttribute("ApprovedGeometryCommit","26ad62cf8b663b1dd5c1900a09f5e2b93dc58cd2")
  model:SetAttribute("DressingRevision","S2_BranchingEnergyVeins_02")
  model:SetAttribute("DressingReview","Pending")
  model:SetAttribute("QualityGateC","Pending")
  model:SetAttribute("GeometryRevision","S2_StormHunter_TaperedArmorContours_14")
  model:SetAttribute("VisualTarget","Storm Hunter concept approved in conversation")
  model:SetAttribute("HeightRatioToStageOne",(currentHeight*model:GetScale()-headDrop*buildScale)/sourceHeight)
  model:SetAttribute("Purpose","Stage 2 dressing review; geometry approved")
  model.Parent=parent
 end)
 staging:Destroy()
 if not ok then if model then model:Destroy() end;error(err,0) end
 return model
end
return Builder
