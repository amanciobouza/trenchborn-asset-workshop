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
  -- Retain existing energy glow for the requested illuminated preview.
  for _,p in ipairs(model:GetDescendants()) do
   if p:IsA("Light") or p:IsA("ParticleEmitter") then p.Enabled=false end
  end
  for _,p in ipairs(model:GetChildren()) do
   if p.Name:match("^LeftRibArmorStage4Row") or p.Name:match("^RightRibArmorStage4Row") then p:Destroy() end
  end
  -- Inherited skin-route strokes bridge the gaps between the larger leg
  -- shells. Remove the whole free-standing routes, including their rims;
  -- retain fissures authored directly on individual hip and shin plates.
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") then
    for _,side in ipairs({"Left","Right"}) do
     if p.Name:match("^"..side.."HipArmorGrowthPath")
      or p.Name:match("^"..side.."ShinArmorGrowthPath") then p:Destroy();break end
    end
   end
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
  local apertureX,apertureY=width*0.175,width*0.21
  local outerX,outerY=width*0.50,width*0.30
  -- Chest height must follow the jaw clearance, not shoulder width alone.
  -- Use the central mouth underside, not low lateral jaw armor.
  local jawBottom=math.huge
  local jawSources={}
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") and p.Name:match("^LowerJawFront") then table.insert(jawSources,p) end
  end
  if #jawSources==0 then table.insert(jawSources,assert(model:FindFirstChild("LowerJawRear"),"Missing jaw")) end
  for _,p in ipairs(jawSources) do
   if p:IsA("BasePart") then
    local cf,h=p.CFrame,p.Size/2
    jawBottom=math.min(jawBottom,p.Position.Y-math.abs(cf.RightVector.Y)*h.X
     -math.abs(cf.UpVector.Y)*h.Y-math.abs(cf.ZVector.Y)*h.Z)
   end
  end
  assert(jawBottom<math.huge,"Missing lower jaw for chest clearance")
  local clearance=width*0.003
  chestY=jawBottom-clearance-outerY-width*0.02
  model:SetAttribute("NormalizedChestJawClearance",clearance)
  model:SetAttribute("ChestHeightReference","FrontJawUnderside")
  local backing=G.Part(model,"Stage5ChestBacking",Vector3.new(width*0.78,width*0.57,width*0.08),
   CFrame.new(0,chestY,backZ+width*0.03),DARK)
  backing.Shape=Enum.PartType.Ball;backing:SetAttribute("RigRegion","Torso")
  local core=G.Part(model,"Stage5ChestCore",Vector3.new(apertureX*1.12,apertureY*1.10,width*0.07),
   CFrame.new(0,chestY,backZ-width*0.035),FIELD)
  core.Shape=Enum.PartType.Ball;core:SetAttribute("RigRegion","Torso")
  core:SetAttribute("Stage5EnergyRole","Core")
  core.Material=Enum.Material.Neon;core:SetAttribute("KaijuArmorEnergy",true)
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
  local function energyRift(name,a,b,thickness)
   local length=(b-a).Magnitude
   if length<0.001 then return end
   local p=G.Part(model,name,Vector3.new(thickness,thickness,length),
    CFrame.lookAt((a+b)/2,b),FIELD)
   p.Material=Enum.Material.Neon;p:SetAttribute("RigRegion","Torso")
   p:SetAttribute("KaijuArmorEnergy",true)
  end
  local riftOffset=Vector3.new(0,0,-width*0.026)
  -- Different upper-side sectors and branch lengths avoid mirrored fissures.
  for route,i in ipairs({2,3,5,6}) do
   local j=i%12+1
   local bend=inner[i]:Lerp(outer[i],0.48+route*0.055)
   local start=Vector3.new(inner[i].X*0.86,chestY+(inner[i].Y-chestY)*0.86,backZ)
   energyRift("Stage5EnergyRift_"..route.."Core",start+riftOffset,inner[i]+riftOffset,width*0.009)
   energyRift("Stage5EnergyRift_"..route.."Main",inner[i]+riftOffset,outer[i]+riftOffset,width*(route%2==0 and 0.010 or 0.008))
   -- Branch stays on the inner[i], outer[i], outer[j] triangle.
   local tip=inner[i]*0.18+outer[i]*(0.65-route*0.04)+outer[j]*(0.17+route*0.04)
   energyRift("Stage5EnergyRift_"..route.."Branch",bend+riftOffset,tip+riftOffset,width*0.004)
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
  -- Raised lateral collar: climb outside the jaw, then wrap behind each
  -- shoulder root into the back cuirass. These plates belong to the torso.
  local jawHalfWidth=0
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") and p.Name:match("^LowerJaw") then
    local cf,h=p.CFrame,p.Size/2
    jawHalfWidth=math.max(jawHalfWidth,math.abs(p.Position.X)+math.abs(cf.RightVector.X)*h.X
     +math.abs(cf.UpVector.X)*h.Y+math.abs(cf.ZVector.X)*h.Z)
   end
  end
  for _,sign in ipairs({-1,1}) do
   local shoulder=model[sign<0 and "LeftShoulderJoint" or "RightShoulderJoint"]
   local x=math.max(jawHalfWidth+width*0.065,shoulderSpan*0.34)
   local topY=math.max(chestY+outerY,shoulder.Position.Y+shoulder.Size.Y*0.45)
   local rearZ=rearSurface(sign*x,rib.Position.Y,rib.Position.Z+rib.Size.Z/2)
   local nodes={
    Vector3.new(sign*outerX*0.73,chestY+outerY*0.64,backZ-width*0.08),
    Vector3.new(sign*x,topY,backZ+width*0.04),
    Vector3.new(sign*(x+width*0.045),topY,shoulder.Position.Z),
    Vector3.new(sign*x,rib.Position.Y+rib.Size.Y*0.32,rearZ+width*0.04)}
   local routeEdge=outer[sign==1 and 2 or 6]+riftOffset
   energyRift("Stage5EnergyRift_Shoulder_"..sign,routeEdge,nodes[1]+Vector3.new(sign*width*0.043,-width*0.055,0),width*0.008)
   for i=1,3 do
    local a,b=nodes[i],nodes[i+1]
    local drop=Vector3.new(0,-width*0.15,0)
    local parts=G.Quad(model,"Stage5CollarLink_"..sign.."_"..i,a,b,b+drop,a+drop,
     i==2 and EDGE or ROCK,width*0.075)
    region(parts,"Torso")
    -- Fine luminous seam along each link; shares the special-attack palette.
    local offset=Vector3.new(sign*width*0.043,0,0)
    local seams=G.Quad(model,"Stage5CollarEnergy_"..sign.."_"..i,
     a+drop*0.35+offset,b+drop*0.35+offset,b+drop*0.41+offset,a+drop*0.41+offset,FIELD,width*0.012)
    region(seams,"Torso")
    for _,p in ipairs(seams) do p.Material=Enum.Material.Neon;p:SetAttribute("KaijuArmorEnergy",true) end
   end
  end
  -- Staggered cover plates bridge the seams of the shoulder-spanning back armor.
  for _,sign in ipairs({-1,1}) do
   for row=1,3 do
    for col=1,2 do
     local cx=sign*shoulderSpan*(0.12+(col-1)*0.18)
     local cy=rib.Position.Y+rib.Size.Y*(0.31-(row-1)*0.23)
     local hw,hh=shoulderSpan*0.105,rib.Size.Y*0.17
     local function point(dx,dy)
      local x,y=cx+dx,cy+dy
      return Vector3.new(x,y,rearSurface(x,y,rib.Position.Z+rib.Size.Z/2)+width*0.045)
     end
     region(G.Quad(model,"Stage5BackSeamArmor_"..sign.."_"..row.."_"..col,
      point(-hw,hh),point(hw,hh),point(hw*0.86,-hh),point(-hw*0.86,-hh),
      row==2 and EDGE or ROCK,width*0.055),"Torso")
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
    stretch(model,side..prefix,footFrame,Vector3.new(1.42,1,1.34))
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
   -- Thick sidewalls and a toe cap turn the top plates into an armored boot.
   -- Every lower edge stays above the existing sole plane.
   local fw,fh,fl=foot.Size.X,foot.Size.Y,foot.Size.Z
   for _,edge in ipairs({-1,1}) do
    local wall=G.Part(model,side.."ForefootArmorStage5Side_"..edge,
     Vector3.new(fw*0.16,fh*1.05,fl*0.98),
     foot.CFrame*CFrame.new(edge*fw*0.49,fh*0.15,-fl*0.04),ROCK)
    wall:SetAttribute("RigRegion",side.."Foot")
   end
   local cap=G.Part(model,side.."ForefootArmorStage5ToeCap",
    Vector3.new(fw*1.08,fh*0.86,fl*0.18),
    foot.CFrame*CFrame.new(0,fh*0.10,-fl*0.52),EDGE)
   cap:SetAttribute("RigRegion",side.."Foot")
   local instep=assert(model:FindFirstChild(side.."InstepFlow"),"Missing instep")
   local h=instep.Size/2
   for row=1,3 do
    local z0=-0.76+(row-1)*0.46
    local z1=z0+0.55
    local function point(x,z)
     local y=h.Y*math.sqrt(math.max(0,1-x*x-z*z))+h.Y*0.07
     return instep.CFrame:PointToWorldSpace(Vector3.new(x*h.X,y,z*h.Z))
    end
    for _,edge in ipairs({-1,1}) do
     region(G.Quad(model,side.."InstepArmorStage5_"..row.."_"..edge,
      point(0,z0),point(edge*0.68,z0),point(edge*0.68,z1),point(0,z1),
      row==2 and EDGE or ROCK,h.Y*0.20),side.."Foot")
    end
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
  -- Move complete leg assemblies, so rig pivots, footfall probes and armor
  -- share the wider stance. Ensure actual armored feet have a visible gap.
  local inner={Left=-math.huge,Right=math.huge}
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") then
    for _,side in ipairs({"Left","Right"}) do
     local suffix=p.Name:sub(#side+1)
     if p.Name:sub(1,#side)==side and (suffix:match("^Forefoot") or suffix:match("^Toe") or suffix:match("^Heel") or suffix:match("^FrontClaw")) then
      local cf,h=p.CFrame,p.Size/2
      local extent=math.abs(cf.RightVector.X)*h.X+math.abs(cf.UpVector.X)*h.Y+math.abs(cf.ZVector.X)*h.Z
      if side=="Left" then inner.Left=math.max(inner.Left,p.Position.X+extent)
      else inner.Right=math.min(inner.Right,p.Position.X-extent) end
     end
    end
   end
  end
  local stanceShift=math.max(width*0.045,(width*0.10-(inner.Right-inner.Left))/2)
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") then
    for _,side in ipairs({"Left","Right"}) do
     if p.Name:sub(1,#side)==side then
      local suffix=p.Name:sub(#side+1)
      for _,prefix in ipairs({"Hip","Thigh","OuterQuadriceps","UpperLeg","Knee","Calf","LowerLeg","Hock","Metatarsal","Ankle","Instep","Heel","Forefoot","Toe","FrontClaw","RearClaw","Shin"}) do
       if suffix:sub(1,#prefix)==prefix then
        p.CFrame=p.CFrame+Vector3.new((side=="Left" and -1 or 1)*stanceShift,0,0);break
       end
      end
     end
    end
   end
  end
  model:SetAttribute("NormalizedStanceShift",stanceShift)
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
  -- Start the swept scale rows on the actual brow ridges, above the eyes.
  for _,sign in ipairs({-1,1}) do
   local side=sign<0 and "Left" or "Right"
   local brow=assert(model:FindFirstChild(side.."BrowRidge"),"Missing brow ridge")
   for row=1,2 do
    local root=brow.CFrame:PointToWorldSpace(Vector3.new(0,brow.Size.Y*0.46,
     brow.Size.Z*(-0.24+(row-1)*0.42)))
    local function point(x,y,z)return root+skull.CFrame:VectorToWorldSpace(Vector3.new(x,y,z)) end
    region(G.Triangle(model,"Stage5BrowScale_"..side.."_"..row,
     point(0,0,-skull.Size.Z*0.07),point(0,0,skull.Size.Z*0.19),
     point(sign*skull.Size.X*0.025,skull.Size.Y*(0.18+row*0.045),skull.Size.Z*(0.28+row*0.025)),
     row==1 and EDGE or ROCK,brow.Size.X*0.65),"Head")
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
   -- Both faces of every dorsal plate carry an inset armor layer. The
   -- DorsalRock index preserves the same torso/tail articulation as its spar.
   for _,sign in ipairs({-1,1}) do
    local h,d=plate.Size.Y,plate.Size.Z
    local function point(y,z)
     return plate.CFrame:PointToWorldSpace(Vector3.new(sign*plate.Size.X*0.56,y,z))
    end
    local parts=G.Triangle(model,"DorsalRock_"..stem.."_Stage5Flank_"..sign,
     point(-h*0.44,-d*0.40),point(-h*0.44,d*0.43),point(h*0.39,d*0.43),
     ROCK,plate.Size.X*0.20)
    for _,p in ipairs(parts) do p:SetAttribute("Stage5ArmorRole","DorsalFlank") end
    -- Visible energy inset sits outside the new flank armor, not underneath.
    local function glowPoint(y,z)
     return plate.CFrame:PointToWorldSpace(Vector3.new(sign*plate.Size.X*0.70,
      -h/6+(y+h/6)*0.48,d/6+(z-d/6)*0.48))
    end
    local glow=G.Triangle(model,"DorsalEnergy_"..stem.."_Stage5Core_"..sign,
     glowPoint(-h/2,-d/2),glowPoint(-h/2,d/2),glowPoint(h/2,d/2),FIELD,plate.Size.X*0.025)
    for _,p in ipairs(glow) do p.Material=Enum.Material.Neon;p:SetAttribute("KaijuArmorEnergy",true) end
   end
   -- Use the outward direction, not distance from a body centre: distance
   -- can pick an along-back corner and fold a bay into the next plate.
   local outward=i<=3 and Vector3.zAxis or Vector3.yAxis
   local points={Vector3.new(0,-plate.Size.Y/2,-plate.Size.Z/2),Vector3.new(0,-plate.Size.Y/2,plate.Size.Z/2),Vector3.new(0,plate.Size.Y/2,plate.Size.Z/2)}
   table.sort(points,function(a,b)return plate.CFrame:VectorToWorldSpace(a):Dot(outward)<plate.CFrame:VectorToWorldSpace(b):Dot(outward) end)
   local lift=plate.CFrame:VectorToObjectSpace(outward)*0.06
   local lower=Instance.new("Attachment");lower.Name="Stage5SailLower";lower.Position=points[1]:Lerp(points[3],0.20)+lift;lower.Parent=plate
   local upper=Instance.new("Attachment");upper.Name="Stage5SailUpper";upper.Position=points[1]:Lerp(points[3],0.90)+lift;upper.Parent=plate
   anchors[i]={Lower=lower,Upper=upper}
  end
  -- The lowest torso-side pair sits on the sacral/tail-root surface. Its
  -- inherited DorsalRock_03 name otherwise binds it to the pitching torso,
  -- lifting the pair off its host during sprint. Move the complete clusters.
  for _,p in ipairs(model:GetChildren()) do
   if p:IsA("BasePart") and p.Name:match("^DorsalRock_03_SideSpine_") then
    p:SetAttribute("RigRegion","TailBase")
   end
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
    return line:Lerp(lower,0.30*math.sin(t*math.pi))
   end
   for strip=1,6 do
    local t0,t1=(strip-1)/6,strip/6
    for _,p in ipairs(G.Quad(bay,"Field"..strip,a:Lerp(b,t0),a:Lerp(b,t1),top(t1),top(t0),FIELD,0.035)) do
     p.Transparency=0.82;p.Material=Enum.Material.Neon;p.CastShadow=false;p:SetAttribute("GeometryProxy",true)
    end
   end
  end
  -- Short fissures stay inside a single real plate face. Never connect
  -- separate bones with free-standing strokes across the joint gaps.
  local veinCount=0
  for _,plate in ipairs(model:GetChildren()) do
   if plate:IsA("BasePart") and not plate:GetAttribute("KaijuArmorEnergy") then
    local name=plate.Name
    local head=name:match("^Stage5Crown_") or name:match("^Stage5BrowScale_")
    local chest=false -- Keep only the four larger authored chest routes.
    local arm=(name:find("ShoulderArmor",1,true) or name:find("ForearmArmor",1,true))
     and (name:match("OverlapCore$") or name:match("RockLayer1Core$"))
    local leg=(name:find("HipArmor",1,true) or name:find("ShinArmor",1,true))
     and (name:match("RaisedFaceCore$") or name:match("RockLayer1Core$") or name:match("OverlapCore$"))
    local facePlate=arm or leg or (name:find("HeadArmor",1,true) and name:match("Core$"))
    if ((head or chest) and plate:IsA("WedgePart")) or (facePlate and plate:IsA("Part")) then
     local seed=0
     for i=1,#name do seed=(seed*33+name:byte(i))%997 end
     local variant=(seed%11)/100
     -- A continuous, elongated crack; no multi-branch central junction.
     local points={{0.13+variant,0.07},{0.20+variant,0.22},{0.12+variant,0.37},
      {0.17-variant*0.5,0.53},{0.08,0.76}}
     if arm or leg then
      points={{0.09+variant,0.02},{0.23+variant,0.22},{0.18+variant,0.40},
       {0.40-variant,0.58},{0.48+variant*0.4,0.78}}
     end
     local sides=head and {-1,1} or {chest and (plate.CFrame.RightVector.Z<=0 and 1 or -1) or 1}
     for _,side in ipairs(sides) do
      local normal=plate:IsA("WedgePart") and plate.CFrame.RightVector*side or plate.CFrame.LookVector
      local function point(uv)
       local u,v=uv[1],uv[2]
       local h=plate.Size/2
       local localPoint
       if plate:IsA("WedgePart") then
        localPoint=Vector3.new(side*h.X,-h.Y+2*h.Y*v,-h.Z+2*h.Z*(u+v))
       else
        localPoint=Vector3.new((u-0.33)*plate.Size.X,(v-0.36)*plate.Size.Y,-h.Z)
       end
       return plate.CFrame:PointToWorldSpace(localPoint)+normal*0.018
      end
      for index,edge in ipairs({{1,2},{2,3},{3,4},{4,5}}) do
       local a,b=point(points[edge[1]]),point(points[edge[2]])
       local length=(b-a).Magnitude
       if length>0.025 then
        local faceSize=(arm or leg) and math.min(plate.Size.X,plate.Size.Y) or math.min(plate.Size.Y,plate.Size.Z)
        local thickness=math.clamp(faceSize*((arm or leg) and 0.025 or 0.014),0.022,(arm or leg) and 0.11 or 0.065)*(index==4 and 0.65 or 0.85)
        local glow=G.Part(model,name.."Stage5SurfaceVein_"..side.."_"..index,
         Vector3.new(thickness,0.018,length),CFrame.lookAt((a+b)/2,b,normal),FIELD)
        glow.Material=Enum.Material.Neon;glow.CastShadow=false
        glow:SetAttribute("KaijuArmorEnergy",true)
        glow:SetAttribute("Stage5VeinHost",name)
        if plate:GetAttribute("RigRegion") then glow:SetAttribute("RigRegion",plate:GetAttribute("RigRegion")) end
        veinCount=veinCount+1
       end
      end
     end
    end
   end
  end
  model:SetAttribute("Stage5FrontVeinCount",veinCount)
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
  model:SetAttribute("GeometryRevision","S5_ChestBelowJaw_06")
  model:SetAttribute("Purpose","Stage 5 static geometry review; not a playable/final asset")
  model.Parent=parent
 end)
 staging:Destroy()
 if not ok then if model then model:Destroy() end;error(err,0) end
 return model
end
return Builder
