-- Phase 5 surface dressing of the user-approved Stage 4 geometry.
-- SurfaceGuis add emissive fissures without changing any solid or rig region.
local Dressing={}
local REVISION="S4_IndependentArmorVeins_02"
-- Authored independently for each side and tier: no reflection or repeated
-- chest stamp. Fixed coordinates keep the result stable across rebuilds.
local patterns={
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
 local row=name:match("RibArmorStage4Row(%d)")
 if row then return patterns["Chest"..side..row] end
 row=name:match("HipArmorStage4Lame(%d)")
 if row then return patterns["Hip"..side..row] end
 if name:find("Kneecap",1,true) then return patterns["Knee"..side] end
 return patterns["Other"..side]
end
local function fissures(part)
 local gui=Instance.new("SurfaceGui")
 gui.Name="Stage4EnergyFissures";gui.Face=Enum.NormalId.Front
 gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.Brightness=2
 gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
 gui.CanvasSize=Vector2.new(512,512);gui.Parent=part
 local pattern=patternFor(part.Name)
 local points=pattern.P
 for _,edge in ipairs(pattern.E) do
  local a,b=points[edge[1]],points[edge[2]]
  local ax=a[1]*512
  local bx=b[1]*512
  local ay,by=a[2]*512,b[2]*512
  local delta=Vector2.new(bx-ax,by-ay)
  -- A dark lip keeps the thin yellow seam legible against the basalt.
  for layer=1,2 do
   local line=Instance.new("Frame")
   line.Name=layer==1 and "FissureLip" or "Energy"
   line.AnchorPoint=Vector2.new(0.5,0.5)
   line.Position=UDim2.fromOffset((ax+bx)/2,(ay+by)/2)
   line.Size=UDim2.fromOffset(delta.Magnitude,layer==1 and 11 or 5)
   line.Rotation=math.deg(math.atan2(delta.Y,delta.X))
   line.BorderSizePixel=0;line.ZIndex=layer
   line.BackgroundColor3=layer==1 and Color3.fromRGB(24,29,34) or Color3.fromRGB(244,207,39)
   line.Parent=gui
  end
 end
end
function Dressing.Apply(model)
 assert(model:GetAttribute("EvolutionStage")==4,"Stage 4 model required")
 assert(model:GetAttribute("QualityGateB")=="ApprovedByUser","Stage 4 geometry must be approved")
 -- Reapplying is safe and does not accumulate surface layers.
 for _,item in ipairs(model:GetDescendants()) do
  if item:IsA("SurfaceGui") and item.Name=="Stage4EnergyFissures" then item:Destroy() end
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
   if chest or raised or nape then
    fissures(part);count=count+1
   end
  end
 end
 model:SetAttribute("PipelinePhase",5)
 model:SetAttribute("DressingRevision",REVISION)
 model:SetAttribute("DressingReview","Pending_UserVisualReview")
 model:SetAttribute("Stage4EnergySurfaceCount",count)
 model:SetAttribute("Purpose","Stage 4 surface dressing review; geometry approved")
 return model
end
return Dressing
