-- Phase 5 surface dressing of the user-approved Stage 4 geometry.
-- SurfaceGuis add emissive fissures without changing any solid or rig region.
local Dressing={}
local REVISION="S4_FineBranchesFromMainVeins_04"
-- Authored independently for each side and tier: no reflection or repeated
-- chest stamp. Fixed coordinates keep the result stable across rebuilds.
local patterns={
 ShoulderLeftRear={P={{.19,.28},{.40,.40},{.58,.31},{.76,.49},{.47,.65}},E={{1,2},{2,3},{3,4},{2,5,.65}},Fine=true},
 ShoulderRightRear={P={{.35,.19},{.46,.38},{.39,.58},{.65,.73},{.71,.32}},E={{1,2},{2,3},{3,4},{2,5,.65}},Fine=true},
 ShoulderLeftUpperArm={P={{.32,.18},{.43,.39},{.34,.60},{.52,.80}},E={{1,2},{2,3},{3,4,.75}},Fine=true},
 ShoulderRightUpperArm={P={{.22,.67},{.38,.49},{.62,.55},{.77,.36},{.43,.24}},E={{1,2},{2,3},{3,4},{2,5,.65}},Fine=true},
 ForearmLeftRear={P={{.24,.21},{.39,.41},{.32,.62},{.54,.78},{.68,.44}},E={{1,2},{2,3},{3,4},{2,5,.65}},Fine=true},
 ForearmRightRear={P={{.19,.57},{.37,.45},{.59,.55},{.77,.37}},E={{1,2},{2,3},{3,4,.75}},Fine=true},
 ForearmLeftFront={P={{.28,.20},{.47,.40},{.41,.61},{.65,.77}},E={{1,2},{2,3},{3,4,.75}},Fine=true},
 ForearmRightFront={P={{.18,.35},{.39,.47},{.57,.34},{.77,.58},{.49,.73}},E={{1,2},{2,3},{3,4},{2,5,.65}},Fine=true},
 ChestLeft1={P={{.12,.30},{.36,.44},{.58,.32},{.86,.57},{.44,.73}},E={{1,2},{2,3},{3,4},{2,5}}},
 ChestRight1={P={{.30,.15},{.44,.37},{.37,.60},{.67,.79},{.76,.30},{.61,.44}},E={{1,2},{2,3},{3,4},{2,6},{6,5}}},
 ChestLeft2={P={{.18,.72},{.40,.52},{.61,.59},{.80,.39}},E={{1,2},{2,3},{3,4}}},
 ChestRight2={P={{.12,.36},{.39,.28},{.52,.51},{.86,.62},{.59,.78}},E={{1,2},{2,3},{3,4},{3,5}}},
 ChestLeft3={P={{.25,.14},{.39,.37},{.30,.60},{.56,.84},{.65,.39},{.85,.49}},E={{1,2},{2,3},{3,4},{2,5},{5,6}}},
 ChestRight3={P={{.16,.63},{.40,.54},{.53,.33},{.78,.19}},E={{1,2},{2,3},{3,4}}},
 ChestLeft4={P={{.14,.39},{.43,.53},{.65,.40},{.79,.66},{.35,.77}},E={{1,2},{2,3},{3,4},{2,5}}},
 ChestRight4={P={{.32,.13},{.46,.39},{.66,.53},{.59,.82}},E={{1,2},{2,3},{3,4}}},
 HipLeft1={P={{.23,.16},{.40,.40},{.31,.64},{.58,.84},{.75,.30}},E={{1,2},{2,3},{3,4},{2,5}}},
 HipRight1={P={{.15,.68},{.36,.50},{.62,.57},{.81,.35}},E={{1,2},{2,3},{3,4}}},
 HipLeft2={P={{.14,.32},{.36,.49},{.63,.39},{.78,.64}},E={{1,2},{2,3},{3,4}}},
 HipRight2={P={{.39,.15},{.31,.37},{.53,.56},{.48,.82},{.81,.45}},E={{1,2},{2,3},{3,4},{3,5}}},
 KneeLeft={P={{.26,.14},{.41,.39},{.34,.63},{.60,.83},{.69,.31}},E={{1,2},{2,3},{3,4},{2,5}}},
 KneeRight={P={{.13,.57},{.37,.49},{.55,.64},{.81,.40}},E={{1,2},{2,3},{3,4}}},
 OtherLeft={P={{.17,.27},{.38,.49},{.65,.37},{.79,.70}},E={{1,2},{2,3},{3,4}}},
 OtherRight={P={{.33,.15},{.47,.38},{.38,.66},{.70,.81},{.78,.29}},E={{1,2},{2,3},{3,4},{2,5}}},
}
local function patternFor(name)
 local side=name:find("Right",1,true) and "Right" or "Left"
 local area=name:match("ShoulderArmorStage4(%a+)OverlapCore$")
 if area then return patterns["Shoulder"..side..area] end
 area=name:match("ForearmArmorStage4(%a+)OverlapCore$")
 if area then return patterns["Forearm"..side..area] end
 local row=name:match("RibArmorStage4Row(%d)")
 if row then return patterns["Chest"..side..row] end
 row=name:match("HipArmorStage4Lame(%d)")
 if row then return patterns["Hip"..side..row] end
 if name:find("Kneecap",1,true) then return patterns["Knee"..side] end
 return patterns["Other"..side]
end
local function seedFor(name)
 local value=17
 for i=1,#name do value=(value*31+name:byte(i))%65521 end
 return value
end
local function drawLine(gui,a,b,thickness)
 local delta=b-a
 if delta.Magnitude<0.01 then return end
 for layer=1,2 do
  local line=Instance.new("Frame")
  line.Name=layer==1 and "FissureLip" or "Energy"
  line.AnchorPoint=Vector2.new(0.5,0.5)
  line.Position=UDim2.fromOffset((a.X+b.X)/2,(a.Y+b.Y)/2)
  line.Size=UDim2.fromOffset(delta.Magnitude,layer==1 and thickness*2.0 or thickness)
  line.Rotation=math.deg(math.atan2(delta.Y,delta.X))
  line.BorderSizePixel=0;line.ZIndex=layer
  line.BackgroundColor3=layer==1 and Color3.fromRGB(24,29,34) or Color3.fromRGB(244,207,39)
  line.Parent=gui
 end
end
local function fissures(part)
 local gui=Instance.new("SurfaceGui")
 gui.Name="Stage4EnergyFissures";gui.Face=Enum.NormalId.Front
 gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.Brightness=2
 gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
 gui.CanvasSize=Vector2.new(512,512);gui.Parent=part
 local pattern=patternFor(part.Name)
 local points=pattern.P
 local seed=seedFor(part.Name)
 for index,edge in ipairs(pattern.E) do
  local pa,pb=points[edge[1]],points[edge[2]]
  local a,b=Vector2.new(pa[1],pa[2])*512,Vector2.new(pb[1],pb[2])*512
  local delta=b-a
  local thickness=(pattern.Fine and 4 or 6)*(edge[3] or 1)
  drawLine(gui,a,b,thickness)
  -- Two short bent twigs leave the thicker network on selected segments.
  -- Roots lie on the parent line; each terminal stroke tapers further.
  if not pattern.Fine and (index==1 or index==3) then
   local variation=(seed+index*97)%101
   local root=a:Lerp(b,0.30+variation/250)
   local tangent=delta.Unit
   local sign=variation%2==0 and -1 or 1
   local normal=Vector2.new(-tangent.Y,tangent.X)*sign
   local length=24+variation*0.20
   local function inside(v) return Vector2.new(math.clamp(v.X,30,482),math.clamp(v.Y,30,482)) end
   local bend=inside(root+normal*length*0.62+tangent*length*0.30)
   local tip=inside(bend+normal*length*0.44-tangent*length*0.18)
   drawLine(gui,root,bend,thickness*0.42)
   drawLine(gui,bend,tip,thickness*0.22)
  end
 end
end
local function physicalTwigs(model)
 -- Existing 3-D veins use local Y as their surface normal and Z along the
 -- main vein. Short lateral strokes retain the parent's articulated prefix.
 for _,main in ipairs(model:GetChildren()) do
  if main:IsA("BasePart") and main:GetAttribute("KaijuArmorEnergy")==true
   and not main:GetAttribute("Stage4VeinTwig") then
   local seed=seedFor(main.Name)
   if seed%3==0 then
    local sign=seed%2==0 and -1 or 1
    local length=math.min(main.Size.Z*0.22,main.Size.X*5)
    if length>main.Size.X then
     local root=Vector3.new(0,0,main.Size.Z*((seed%41)/100-0.20))
     local bend=root+Vector3.new(sign*length*0.62,0,length*0.30)
     local tip=bend+Vector3.new(sign*length*0.44,0,-length*0.18)
     for index,ends in ipairs({{root,bend},{bend,tip}}) do
      local a=main.CFrame:PointToWorldSpace(ends[1])
      local b=main.CFrame:PointToWorldSpace(ends[2])
      local width=main.Size.X*(index==1 and 0.42 or 0.22)
      for layer=1,2 do
       local part=Instance.new("Part")
       part.Name=main.Name.."FineTwig"..index..(layer==1 and "Rim" or "Energy")
       part.Size=Vector3.new(width*(layer==1 and 2 or 1),main.Size.Y*0.75,(b-a).Magnitude+width*0.2)
       part.CFrame=CFrame.lookAt((a+b)/2,b,main.CFrame.UpVector)
        +main.CFrame.UpVector*(layer==1 and -main.Size.Y*0.25 or 0)
       part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.CastShadow=false
       part.Material=layer==1 and Enum.Material.Basalt or Enum.Material.Neon
       part.Color=layer==1 and Color3.fromRGB(29,32,35) or main.Color
       part.Transparency=layer==1 and 0 or main.Transparency
       part:SetAttribute("Stage4VeinTwig",true)
       if layer==2 then part:SetAttribute("KaijuArmorEnergy",true) end
       part.Parent=model
      end
     end
    end
   end
  end
 end
end
function Dressing.Apply(model)
 assert(model:GetAttribute("EvolutionStage")==4,"Stage 4 model required")
 assert(model:GetAttribute("QualityGateB")=="ApprovedByUser","Stage 4 geometry must be approved")
 -- Reapplying is safe and does not accumulate surface layers.
 for _,item in ipairs(model:GetDescendants()) do
  if (item:IsA("SurfaceGui") and item.Name=="Stage4EnergyFissures")
   or item:GetAttribute("Stage4VeinTwig") then item:Destroy() end
 end
 -- Strengthen inherited physical fissures only in this Stage 4 instance.
 -- Track the applied ratio so repeated dressing cannot inflate the veins.
 for _,part in ipairs(model:GetChildren()) do
  if part:IsA("BasePart") and part:GetAttribute("KaijuArmorEnergy")==true then
   local ratio=1.20/(part:GetAttribute("Stage4VeinWidthFactor") or 1)
   part.Size=Vector3.new(part.Size.X*ratio,part.Size.Y,part.Size.Z)
   part:SetAttribute("Stage4VeinWidthFactor",1.20)
   local rimName=part.Name:gsub("Energy$","Rim")
   local rim=model:FindFirstChild(rimName)
   if rim and rim:IsA("BasePart") then
    local rimRatio=1.12/(rim:GetAttribute("Stage4VeinWidthFactor") or 1)
    rim.Size=Vector3.new(rim.Size.X*rimRatio,rim.Size.Y,rim.Size.Z)
    rim:SetAttribute("Stage4VeinWidthFactor",1.12)
   end
  end
 end
 local count=0
 for _,part in ipairs(model:GetChildren()) do
  if part:IsA("BasePart") and (part.Name:find("Stage4",1,true) or part.Name:find("SideSpine",1,true)) then
   part.Material=Enum.Material.Basalt;part.Reflectance=0
   if part.Name:find("Edge",1,true) or part.Name:find("Bevel",1,true) then
    part.Color=Color3.fromRGB(76,78,77)
   elseif part.Name:find("RaisedFace",1,true) or part.Name:find("RockLayer",1,true)
    or part.Name:find("Shard",1,true) or part.Name:find("Overlap",1,true) then
    part.Color=Color3.fromRGB(62,67,71)
   else
    part.Color=Color3.fromRGB(45,51,57)
   end
   -- Dress only the outer face of selected armor plates, not buried foundations.
   local chest=part.Name:match("RibArmorStage4Row%dRockLayerCore$")
   local raised=part.Name:match("RaisedFaceCore$")
   local nape=part.Name:match("RibArmorStage4Nape%dCore$")
   local arm=part.Name:match("ShoulderArmorStage4%a+OverlapCore$")
    or part.Name:match("ForearmArmorStage4%a+OverlapCore$")
   if chest or raised or nape or arm then
    fissures(part);count=count+1
   end
  end
 end
 physicalTwigs(model)
 model:SetAttribute("PipelinePhase",5)
 model:SetAttribute("DressingRevision",REVISION)
 model:SetAttribute("DressingReview","Pending_UserVisualReview")
 model:SetAttribute("Stage4EnergySurfaceCount",count)
 model:SetAttribute("Purpose","Stage 4 surface dressing review; geometry approved")
 return model
end
return Dressing
