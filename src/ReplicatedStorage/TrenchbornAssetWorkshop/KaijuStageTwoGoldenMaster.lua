-- Phase 4 Storm Hunter geometry. Stage 1 is built in isolation and never edited in-place.
local StageOne=require(script.Parent:WaitForChild("KaijuEvolutionBlockout"))
local Builder={}
local NAME="Stage_2_Storm_Hunter"
local function newPart(model,class,name,size,cf)
 local p=Instance.new(class);p.Name=name;p.Size=size;p.CFrame=cf
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 p.Material=Enum.Material.Basalt;p.Color=Color3.fromRGB(39,43,51)
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
function Builder.Build(parent,ground)
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
   -- Three interlocking facets follow each organic shoulder instead of forming a spacer.
   local base=shoulder.CFrame*CFrame.new(sign*1.8,1.35,-0.1)*CFrame.Angles(0,0,math.rad(-sign*24))
   newPart(model,"Part",side.."ShoulderArmorCore",Vector3.new(1.4,2.8,3.4),base)
   newPart(model,"CornerWedgePart",side.."ShoulderArmorUpper",Vector3.new(2.2,1.7,3.6),base*CFrame.new(-sign*0.35,1.2,0)*CFrame.Angles(0,sign<0 and math.pi or 0,0))
   newPart(model,"WedgePart",side.."ShoulderArmorFront",Vector3.new(1.6,2.3,1.8),base*CFrame.new(0,-0.3,-1.8)*CFrame.Angles(0,math.pi,0))
   local guard=forearm.CFrame*CFrame.new(sign*1.5,0,-0.1)
   newPart(model,"Part",side.."ForearmArmorCore",Vector3.new(1.0,2.8,2.8),guard)
   newPart(model,"WedgePart",side.."ForearmArmorTaper",Vector3.new(1.1,2.0,2.8),guard*CFrame.new(0,-1.4,0)*CFrame.Angles(0,0,math.pi))
  end
  local currentHeight=model.Cranium.Position.Y+model.Cranium.Size.Y/2-soles(model)
  model:ScaleTo(model:GetScale()*sourceHeight*1.12/currentHeight)
  model:PivotTo(model:GetPivot()+Vector3.new(0,-soles(model),0))
  model:PivotTo(ground*model:GetPivot())
  -- Clear inherited Stage 1 approvals: only the new visual target has approval.
  for _,name in ipairs({"ApprovedGeometryCommit","DressingRevision","DressingReview","GeometryAmendmentReview"}) do model:SetAttribute(name,nil) end
  model:SetAttribute("EvolutionStage",2)
  model:SetAttribute("PipelinePhase",4)
  model:SetAttribute("QualityGateA","ApprovedByUser")
  model:SetAttribute("QualityGateB","Pending")
  model:SetAttribute("QualityGateC","Pending")
  model:SetAttribute("GeometryRevision","S2_StormHunter_Target_01")
  model:SetAttribute("VisualTarget","Storm Hunter concept approved in conversation")
  model:SetAttribute("HeightRatioToStageOne",1.12)
  model:SetAttribute("Purpose","Stage 2 geometry review; anchored, no gameplay rig")
  model.Parent=parent
 end)
 staging:Destroy()
 if not ok then if model then model:Destroy() end;error(err,0) end
 return model
end
return Builder
