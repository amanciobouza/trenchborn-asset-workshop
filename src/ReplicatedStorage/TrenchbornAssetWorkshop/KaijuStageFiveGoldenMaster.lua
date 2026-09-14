-- Phase 4 candidate: approved Stage 5 visual target; geometry approval pending.
-- Static sail topology is also consumed by the animated two-anchor renderer.
local StageFour=require(script.Parent:WaitForChild("KaijuStageFourGoldenMaster"))
local Base=require(script.Parent:WaitForChild("KaijuEvolutionBlockout"))
local G=require(script.Parent:WaitForChild("KaijuStageFiveGeometry"))
local Builder={}
local NAME="Stage_5_Geometry_Review"
local ROCK=Color3.fromRGB(54,59,65)
local EDGE=Color3.fromRGB(78,82,89)
local DARK=Color3.fromRGB(21,25,32)
local FIELD=Color3.fromRGB(236,192,65)
local function region(parts,bone)
 for _,p in ipairs(parts) do p:SetAttribute("RigRegion",bone) end
end
local function front(part)
 local cf,size=part.CFrame,part.Size
 return cf.Position.Z-(math.abs(cf.RightVector.Z)*size.X+math.abs(cf.UpVector.Z)*size.Y+math.abs(cf.ZVector.Z)*size.Z)/2
end
local function stretch(model,prefix,frame,factors)
 for _,p in ipairs(model:GetChildren()) do
  if p:IsA("BasePart") and p.Name:sub(1,#prefix)==prefix then
   local cf=frame:ToObjectSpace(p.CFrame)
   local function v(a)return Vector3.new(a.X*factors.X,a.Y*factors.Y,a.Z*factors.Z) end
   p.Size=Vector3.new(p.Size.X*v(cf.RightVector).Magnitude,p.Size.Y*v(cf.UpVector).Magnitude,p.Size.Z*v(cf.ZVector).Magnitude)
   p.CFrame=frame*CFrame.new(v(cf.Position))*cf.Rotation
  end
 end
end
function Builder.Build(parent,ground,options)
 local scale=Base.ResolveBuildScale(options)
 ground=ground or CFrame.identity
 assert(not parent:FindFirstChild(NAME),"Stage 5 already exists")
 local staging=Instance.new("Folder");staging.Name="StageFiveBuild";staging.Parent=parent
 local model
 local ok,err=pcall(function()
  model=StageFour.Build(staging,CFrame.identity)
  local authoredScale=model:GetScale()
  model:ScaleTo(1);model.Name=NAME
  -- Clear inherited emissive dressing; geometry is readable without final FX.
  for _,p in ipairs(model:GetDescendants()) do
   if p:IsA("BasePart") and p.Material==Enum.Material.Neon then p.Material=Enum.Material.SmoothPlastic end
   if p:IsA("Light") or p:IsA("ParticleEmitter") then p.Enabled=false end
  end
  for _,p in ipairs(model:GetChildren()) do
   if p.Name:match("^LeftRibArmorStage4Row") or p.Name:match("^RightRibArmorStage4Row") then p:Destroy() end
  end
  local shoulderSpan=math.abs(model.RightShoulderJoint.Position.X-model.LeftShoulderJoint.Position.X)
  local width=shoulderSpan*0.94
  local chestY=(model.LeftPectoral.Position.Y+model.RightPectoral.Position.Y)/2
  local skinFront=math.huge
  for _,name in ipairs({"LeftPectoral","RightPectoral","UpperRibcage","LowerRibcage","BellyShield"}) do
   local p=model:FindFirstChild(name);if p then skinFront=math.min(skinFront,front(p)) end
  end
  -- Entire cavity is forward of the old skin: its core cannot be swallowed.
  local depth=width*0.095
  local backZ=skinFront-width*0.015
  local lipZ=backZ-depth
  local apertureX,apertureY=width*0.175,width*0.23
  local outerX,outerY=width*0.50,width*0.40
  local backing=G.Part(model,"Stage5ChestBacking",Vector3.new(width*0.78,width*0.77,width*0.08),
   CFrame.new(0,chestY,backZ+width*0.03),DARK)
  backing.Shape=Enum.PartType.Ball;backing:SetAttribute("RigRegion","Torso")
  local core=G.Part(model,"Stage5ChestCore",Vector3.new(apertureX*1.12,apertureY*1.10,width*0.07),
   CFrame.new(0,chestY,backZ-width*0.035),FIELD)
  core.Shape=Enum.PartType.Ball;core:SetAttribute("RigRegion","Torso")
  core:SetAttribute("Stage5EnergyRole","Core")
  local inner,outer={},{}
  for i=1,12 do
   local angle=(i-1)*math.pi/6
   local uneven=1+0.075*math.sin(i*2.7)
   inner[i]=Vector3.new(math.cos(angle)*apertureX*uneven,chestY+math.sin(angle)*apertureY,lipZ+width*0.018*math.sin(i*1.9))
   outer[i]=Vector3.new(math.cos(angle)*outerX*(1+0.05*math.cos(i*2.1)),chestY+math.sin(angle)*outerY,backZ-width*(0.06+0.035*math.sin(i*1.7)))
  end
  for i=1,12 do
   local j=i%12+1
   local name=string.format("Stage5ChestCrater_%02d",i)
   region(G.Quad(model,name,inner[i],outer[i],outer[j],inner[j],i%3==0 and EDGE or ROCK,width*0.038),"Torso")
   local deepA=Vector3.new(inner[i].X*0.86,chestY+(inner[i].Y-chestY)*0.86,backZ)
   local deepB=Vector3.new(inner[j].X*0.86,chestY+(inner[j].Y-chestY)*0.86,backZ)
   region(G.Quad(model,name.."InnerWall",inner[i],inner[j],deepB,deepA,DARK,width*0.022),"Torso")
  end
  for row=1,3 do
   local w=width*(0.68-row*0.09)
   local y=chestY-outerY-width*(row-1)*0.10
   local z=backZ-width*0.045
   for _,sign in ipairs({-1,1}) do
    region(G.Triangle(model,"Stage5ChestAbdomen"..row.."_"..sign,
     Vector3.new(sign*w/2,y,z),Vector3.new(sign*0.06,y+width*0.09,z-width*0.03),
     Vector3.new(sign*0.06,y-width*0.12,z-width*0.08),ROCK,width*0.055),"Torso")
   end
  end
  model:SetAttribute("NormalizedChestRecessDepth",depth)
  -- Grow existing articulated shells; do not bridge joints with new armor.
  for _,side in ipairs({"Left","Right"}) do
   for _,entry in ipairs({{"ShoulderArmor","ShoulderJoint",1.15},{"ForearmArmor","ElbowJoint",1.09},
    {"HipArmor","HipJoint",1.08},{"ShinArmor","KneeJoint",1.08}}) do
    stretch(model,side..entry[1],model[side..entry[2]].CFrame,Vector3.new(entry[3],1.06,entry[3]))
   end
  end
  -- A faceted upper-back cuirass spans the shoulder roots. All pieces follow
  -- Torso; arm shells remain independently articulated at the shoulder joints.
  local rib=model.UpperRibcage
  local backMasses={}
  for _,name in ipairs({"UpperRibcage","LowerRibcage","DorsalLumbarMass","NapeFlow","LeftShoulderJoint","RightShoulderJoint"}) do
   local p=model:FindFirstChild(name);if p then table.insert(backMasses,p) end
  end
  -- Sample the outer skin at each vertex instead of using the deepest point
  -- of the entire torso as a flat offset for both armor rows.
  local function rearSurface(x,y,fallback)
   local rear=-math.huge
   for _,p in ipairs(backMasses) do
    local o=p.CFrame:PointToObjectSpace(Vector3.new(x,y,0))
    local d=p.CFrame:VectorToObjectSpace(Vector3.zAxis)
    local h=p.Size/2
    local a=(d.X/h.X)^2+(d.Y/h.Y)^2+(d.Z/h.Z)^2
    local b=2*(o.X*d.X/h.X^2+o.Y*d.Y/h.Y^2+o.Z*d.Z/h.Z^2)
    local c=(o.X/h.X)^2+(o.Y/h.Y)^2+(o.Z/h.Z)^2-1
    local discriminant=b*b-4*a*c
    if discriminant>=0 then rear=math.max(rear,(-b+math.sqrt(discriminant))/(2*a)) end
   end
   return rear>-math.huge and rear or fallback
  end
  for row=1,2 do
   local yTop=rib.Position.Y+rib.Size.Y*(0.47-(row-1)*0.30)
   local yBottom=yTop-rib.Size.Y*0.34
   for _,sign in ipairs({-1,1}) do
    local shoulder=model[sign<0 and "LeftShoulderJoint" or "RightShoulderJoint"]
    local edgeZ=shoulder.Position.Z+shoulder.Size.Z/2
    local function point(t,y)
     local x,py=sign*shoulderSpan*0.52*t,y-rib.Size.Y*0.12*t
     local fallback=(rib.Position.Z+rib.Size.Z/2)*(1-t)+edgeZ*t
     return Vector3.new(x,py,rearSurface(x,py,fallback)+width*(0.010+(row-1)*0.008))
    end
    for col=1,3 do
     local a,b=(col-1)/3,col/3
     region(G.Quad(model,"Stage5UpperBackArmor_"..row.."_"..sign.."_"..col,
      point(a,yTop),point(b,yTop),point(b,yBottom),point(a,yBottom),
      col==2 and EDGE or ROCK,width*0.045),"Torso")
    end
   end
  end
  for _,sign in ipairs({-1,1}) do
   local side=sign<0 and "Left" or "Right"
   local foot=model[side.."ForefootCoreY"]
   local footFrame=foot.CFrame
   -- Widen the whole foot, including toes, claws and existing heel armor.
   -- Keep the sole height and ankle pivot unchanged.
   for _,prefix in ipairs({"Forefoot","Heel","Toe","FrontClaw","RearClaw","InstepFlow"}) do
    stretch(model,side..prefix,footFrame,Vector3.new(1.24,1,1.18))
   end
   for row=1,3 do
    local w=foot.Size.X*(0.96-(row-1)*0.08)
    local z=foot.Size.Z*(0.30-(row-1)*0.28)
    local y=foot.Size.Y*(0.50+(4-row)*0.12)
    local function point(x,dy,dz)return foot.CFrame:PointToWorldSpace(Vector3.new(x,y+dy,z+dz)) end
    region(G.Quad(model,side.."ForefootArmorStage5_"..row,
     point(-w/2,0,foot.Size.Z*0.18),point(w/2,0,foot.Size.Z*0.18),
     point(w/2,-foot.Size.Y*0.20,-foot.Size.Z*0.18),point(-w/2,-foot.Size.Y*0.20,-foot.Size.Z*0.18),
     row==2 and EDGE or ROCK,foot.Size.Y*0.24),side.."Foot")
   end
   local shoulder=model[side.."ShoulderJoint"]
   for layer=1,3 do
    local size=shoulder.Size
    local z=size.Z*(0.35-(layer-1)*0.32)
    local function point(x,y,dz)return shoulder.CFrame:PointToWorldSpace(Vector3.new(sign*x,y,z+dz)) end
    region(G.Triangle(model,side.."ShoulderArmorStage5Raised_"..layer,
     point(size.X*0.12,size.Y*0.24,-size.Z*0.34),
     point(size.X*0.30,size.Y*0.08,size.Z*0.35),
     point(size.X*(0.92+layer*0.07),size.Y*(1.18-layer*0.08),size.Z*0.04),
     layer==2 and EDGE or ROCK,size.X*0.26),side.."UpperArm")
   end
  end
  local skull=model.Cranium
  -- Three staggered rows of broad-rooted, sharp scales sweep back and up.
  -- The tip is explicit, avoiding native wedge rotation ambiguity.
  for row=1,3 do
   for column=-1,1 do
    local x=column*skull.Size.X*(0.29-row*0.015)
    local z=skull.Size.Z*(-0.22+(row-1)*0.23)
    local y=skull.Size.Y*(0.43-0.10*math.abs(column))
    local length=skull.Size.Z*(0.36+row*0.035)
    local height=skull.Size.Y*(0.28+row*0.055+(column==0 and 0.06 or 0))
    local function point(dx,dy,dz)return skull.CFrame:PointToWorldSpace(Vector3.new(x+dx,y+dy,z+dz)) end
    region(G.Triangle(model,"Stage5Crown_"..((row-1)*3+column+2),
     point(0,-skull.Size.Y*0.09,-length*0.30),
     point(0,-skull.Size.Y*0.14,length*0.35),
     point(column*skull.Size.X*0.055,height,length),
     row==2 and EDGE or ROCK,skull.Size.X*(column==0 and 0.24 or 0.21)),"Head")
   end
  end
  local anchors={}
  for i=1,11 do
   local stem=string.format("%02d",i)
   local plate=assert(model:FindFirstChild("DorsalShield_"..stem),"Missing dorsal spar")
   local f=i<=3 and 1.38 or 1.12+(11-i)*0.025
   for _,prefix in ipairs({"DorsalShield_","DorsalRock_","DorsalEnergy_"}) do
    stretch(model,prefix..stem,plate.CFrame,Vector3.new(1.02,f,1.20))
   end
   -- Use the outward direction, not distance from a body centre: distance
   -- can pick an along-back corner and fold a bay into the next plate.
   local outward=i<=3 and Vector3.zAxis or Vector3.yAxis
   local points={Vector3.new(0,-plate.Size.Y/2,-plate.Size.Z/2),Vector3.new(0,-plate.Size.Y/2,plate.Size.Z/2),Vector3.new(0,plate.Size.Y/2,plate.Size.Z/2)}
   table.sort(points,function(a,b)return plate.CFrame:VectorToWorldSpace(a):Dot(outward)<plate.CFrame:VectorToWorldSpace(b):Dot(outward) end)
   local lift=plate.CFrame:VectorToObjectSpace(outward)*0.06
   local lower=Instance.new("Attachment");lower.Name="Stage5SailLower";lower.Position=points[1]:Lerp(points[3],0.24)+lift;lower.Parent=plate
   local upper=Instance.new("Attachment");upper.Name="Stage5SailUpper";upper.Position=points[3]+lift;upper.Parent=plate
   anchors[i]={Lower=lower,Upper=upper}
  end
  local sails=Instance.new("Folder");sails.Name="Stage5SailGeometry";sails.Parent=model
  for i=1,10 do
   local bay=Instance.new("Folder");bay.Name=string.format("SailBay_%02d",i);bay.Parent=sails
   for _,entry in ipairs({{"FromLower",anchors[i].Lower},{"FromUpper",anchors[i].Upper},{"ToLower",anchors[i+1].Lower},{"ToUpper",anchors[i+1].Upper}}) do
    local ref=Instance.new("ObjectValue");ref.Name=entry[1];ref.Value=entry[2];ref.Parent=bay
   end
   local a,b=anchors[i].Lower.WorldPosition,anchors[i+1].Lower.WorldPosition
   local topA,topB=anchors[i].Upper.WorldPosition,anchors[i+1].Upper.WorldPosition
   local function top(t)
    local lower=a:Lerp(b,t);local line=topA:Lerp(topB,t)
    return line:Lerp(lower,0.06*math.sin(t*math.pi))
   end
   for strip=1,3 do
    local t0,t1=(strip-1)/3,strip/3
    for _,p in ipairs(G.Quad(bay,"Field"..strip,a:Lerp(b,t0),a:Lerp(b,t1),top(t1),top(t0),FIELD,0.035)) do
     p.Transparency=0.42;p.CastShadow=false;p:SetAttribute("GeometryProxy",true)
    end
   end
  end
  model:ScaleTo(authoredScale*1.08*scale)
  model:SetAttribute("ChestRecessDepth",depth*model:GetScale())
  local bottom=math.huge
  for _,side in ipairs({"Left","Right"}) do
   local foot=model[side.."ForefootCoreY"]
   bottom=math.min(bottom,foot.CFrame:PointToWorldSpace(Vector3.new(0,-foot.Size.Y/2,0)).Y)
  end
  model:PivotTo(model:GetPivot()+Vector3.new(0,-bottom,0));model:PivotTo(ground*model:GetPivot())
  for _,key in ipairs({"ApprovedGeometryCommit","ApprovedRevision","DressingRevision","DressingReview","ApprovedDressingCommit","FinalInstallerVersion","RuntimeReview","IntegrationReview","GeometryAmendmentReview"}) do model:SetAttribute(key,nil) end
  model:SetAttribute("EvolutionStage",5);model:SetAttribute("BuildScale",scale)
  model:SetAttribute("PipelinePhase",4);model:SetAttribute("QualityGateA","ApprovedByUser")
  model:SetAttribute("QualityGateB","Pending_UserGeometryReview");model:SetAttribute("QualityGateC","Pending")
  model:SetAttribute("DressingReview","Pending_Phase5");model:SetAttribute("SailBayCount",10)
  model:SetAttribute("SailPresentation","StaticGeometryProxy")
  model:SetAttribute("GeometryRevision","S5_ArmoredFeet_RisingShoulders_SweptHeadScales_04")
  model:SetAttribute("Purpose","Stage 5 static geometry review; not a playable/final asset")
  model.Parent=parent
 end)
 staging:Destroy()
 if not ok then if model then model:Destroy() end;error(err,0) end
 return model
end
return Builder
