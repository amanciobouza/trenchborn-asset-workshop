-- Phase 5 surface dressing of the user-approved Stage 4 geometry.
-- SurfaceGuis add emissive fissures without changing any solid or rig region.
local Dressing={}
local REVISION="S4_BasaltAndYellowFissures_01"
local function fissures(part,mirror)
 local gui=Instance.new("SurfaceGui")
 gui.Name="Stage4EnergyFissures";gui.Face=Enum.NormalId.Front
 gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.Brightness=2
 gui.SizingMode=Enum.SurfaceGuiSizingMode.FixedSize
 gui.CanvasSize=Vector2.new(512,512);gui.Parent=part
 local points={{0.16,0.32},{0.40,0.46},{0.62,0.36},{0.83,0.66},{0.49,0.76}}
 for _,edge in ipairs({{1,2},{2,3},{3,4},{2,5}}) do
  local a,b=points[edge[1]],points[edge[2]]
  local ax=(mirror and 1-a[1] or a[1])*512
  local bx=(mirror and 1-b[1] or b[1])*512
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
    fissures(part,part.Name:find("Right",1,true)~=nil);count=count+1
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
