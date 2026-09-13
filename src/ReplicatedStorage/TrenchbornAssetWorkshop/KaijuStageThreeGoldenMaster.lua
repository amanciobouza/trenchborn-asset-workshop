-- Stage 3 geometry candidate; Gate A approved, Gate B pending.
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
local function facePlate(model,name,width,height,depth,cf)
 -- Preserve the full core and the world-space bounds of both edge facets.
 stone(model,name.."Core",Vector3.new(width*0.72,height*0.78,depth),cf,"Part")
 -- Native corner apex is (+X,+Y,-Z), above a rectangular -Y base.
 -- Keep Y along the plate: the triangular silhouette tapers toward the top.
 -- Put the apex at the INNER/BACK corner, so the sloping faces face outward
 -- and the full-height flat side overlaps the core instead of forming a wing.
 local size=Vector3.new(width*0.32,height,depth)
 local right=CFrame.fromMatrix(Vector3.new(width*0.34,-height*0.06,0),
  -Vector3.xAxis,Vector3.yAxis,-Vector3.zAxis)
 stone(model,name.."Facet1",size,cf*right)
 local function mirror(v) return Vector3.new(-v.X,v.Y,v.Z) end
 -- A reflection alone is not a rotation. The native shape's symmetry swaps
 -- X with NEGATIVE Z (not positive Z); this preserves its (+,+,-) apex.
 local left=CFrame.fromMatrix(mirror(right.Position),
  -mirror(right.ZVector),mirror(right.UpVector),-mirror(right.RightVector))
 stone(model,name.."Facet-1",Vector3.new(size.Z,size.Y,size.X),cf*left)
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
local function shinPlate(model,name,cf)
 facePlate(model,name,3.0,3.4,0.8,cf)
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
   local x=cheek.Position.X+sign*cheek.Size.X*0.18
   local y=cheek.Position.Y+0.15
   local z=frontSurface({cheek,model.Cranium},x,y)
   facePlate(model,side.."HeadArmorCheek",1.15,1.95,0.5,
    CFrame.new(x,y,z-0.13)*CFrame.Angles(0,sign*math.rad(-12),0))
   -- Follow the OUTSIDE of the pale pectoral/flank envelope, not the hidden rib core.
   local pec=model:FindFirstChild(side.."Pectoral")
   local flank=model:FindFirstChild(side.."Flank")
   local ribs=model:FindFirstChild("LowerRibcage")
   local belly=model:FindFirstChild("BellyShield")
   for i=1,2 do
    x=pec.Position.X+sign*pec.Size.X*(i==1 and 0.29 or 0.24)
    y=pec.Position.Y-pec.Size.Y*(i==1 and 0.23 or 0.38)
    local ribFrame=surfaceFrame({pec,flank,ribs,belly},x,y,0.08)
    bevelPlate(model,side.."RibArmor_"..i,1.85*1.15,0.90*1.15,0.58,
     ribFrame*CFrame.Angles(0,0,sign*math.rad(6)))
   end
   local thigh=model:FindFirstChild(side.."ThighMass")
   local quad=model:FindFirstChild(side.."OuterQuadriceps")
   local hip=model:FindFirstChild(side.."HipJoint")
   x=thigh.Position.X+sign*thigh.Size.X*0.28
   y=thigh.Position.Y+thigh.Size.Y*0.27
   local hipFrame=surfaceFrame({thigh,quad,hip},x,y,0.09)
   bevelPlate(model,side.."HipArmor",2.05,2.5,0.70,hipFrame)
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
   shinPlate(model,side.."ShinArmor",shin)
  end
  -- Relative authored size: 12% above Stage 2, then the user-controlled multiplier.
  model:ScaleTo(stageTwoScale*1.12*multiplier)
  model:PivotTo(model:GetPivot()+Vector3.new(0,-soleY(model),0))
  model:PivotTo(ground*model:GetPivot())
  for _,key in ipairs({"ApprovedGeometryCommit","ApprovedRevision","DressingRevision","DressingReview",
   "FinalInstallerVersion","RuntimeReview","IntegrationReview","HeightRatioToStageOne"}) do model:SetAttribute(key,nil) end
  model:SetAttribute("EvolutionStage",3)
  model:SetAttribute("BuildScale",multiplier)
  model:SetAttribute("PipelinePhase",4)
  model:SetAttribute("QualityGateA","ApprovedByUser")
  model:SetAttribute("QualityGateB","Pending")
  model:SetAttribute("QualityGateC","Pending")
  model:SetAttribute("GeometryRevision","S3_ChestSizeAndJoinedHipBevels_10")
  model:SetAttribute("VisualTarget","Approved Stage 3 front/side/back concept; lateral rib armor amendment")
  model:SetAttribute("Purpose","Stage 3 geometry review; anchored candidate")
  model.Parent=parent
 end)
 staging:Destroy()
 if not ok then if model then model:Destroy() end;error(err,0) end
 return model
end
return Builder
