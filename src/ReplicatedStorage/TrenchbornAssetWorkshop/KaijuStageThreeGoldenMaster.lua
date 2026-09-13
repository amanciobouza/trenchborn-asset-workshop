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
   stone(model,side.."HeadArmorBrow",Vector3.new(1.7,0.65,1.9),
    brow.CFrame*CFrame.new(0,0.30,0.05))
   local cheek=model:FindFirstChild(side.."CheekMass")
   stone(model,side.."HeadArmorCheek",Vector3.new(0.65,1.9,2.1),
    cheek.CFrame*CFrame.new(sign*cheek.Size.X*0.37,0.10,0.20)
     *CFrame.Angles(0,sign*math.rad(12),0))
   -- Small lateral rib plates introduce the chest progression without covering its center.
   local ribs=model:FindFirstChild("LowerRibcage")
   for i=1,2 do
    stone(model,side.."RibArmor_"..i,Vector3.new(1.65,0.8,2.8-i*0.25),
     ribs.CFrame*CFrame.new(sign*ribs.Size.X*0.40,0.7-(i-1)*1.15,-ribs.Size.Z*0.24)
      *CFrame.Angles(math.rad(10),sign*math.rad(25),sign*math.rad(12)),"WedgePart")
   end
   local hip=model:FindFirstChild(side.."HipJoint")
   stone(model,side.."HipArmor",Vector3.new(1.0,2.65,2.6),
    hip.CFrame*CFrame.new(sign*hip.Size.X*0.43,0.4,-0.2)
     *CFrame.Angles(0,sign*math.rad(10),0))
   local knee=model:FindFirstChild(side.."KneeJoint")
   local hock=model:FindFirstChild(side.."HockJoint")
   local shin=CFrame.lookAt(knee.Position:Lerp(hock.Position,0.35),hock.Position)*CFrame.Angles(math.pi/2,0,0)
   stone(model,side.."ShinArmorCore",Vector3.new(2.8,2.8,0.85),
    shin*CFrame.new(0,0,-knee.Size.Z*0.40),"Part")
   for _,edge in ipairs({-1,1}) do
    stone(model,side.."ShinArmorFacet"..edge,Vector3.new(1.25,3.2,1.1),
     shin*CFrame.new(edge*0.95,-0.2,-knee.Size.Z*0.38)
      *CFrame.Angles(0,edge*math.rad(15),0))
   end
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
  model:SetAttribute("GeometryRevision","S3_RockyDorsalLineage_01")
  model:SetAttribute("VisualTarget","Approved Stage 3 front/side/back concept; lateral rib armor amendment")
  model:SetAttribute("Purpose","Stage 3 geometry review; anchored candidate")
  model.Parent=parent
 end)
 staging:Destroy()
 if not ok then if model then model:Destroy() end;error(err,0) end
 return model
end
return Builder
