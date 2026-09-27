-- P5 dressing; all positions relative to the approved plot pivot.
local Dressing={}
function Dressing.Apply(model)
 assert(model and model.PrimaryPart,"Courthouse ground pivot required")
 assert(not model:FindFirstChild("DestructionGroups"),"Apply dressing before integration")
 local old=model:FindFirstChild("CourthouseDressing");if old then old:Destroy() end
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA("BasePart") and p.Name~="GroundPivot" then
   p.Material=Enum.Material.Concrete;p.Reflectance=0
   if string.find(p.Name,"Glass") then p.Material=Enum.Material.Glass;p.Reflectance=.08
   elseif string.find(p.Name,"Frame") or string.find(p.Name,"Mullion") or string.find(p.Name,"Handle") then p.Material=Enum.Material.Metal end
  end
 end
 local group=Instance.new("Model");group.Name="CourthouseDressing";group.Parent=model
 local origin=model:GetPivot()
 local stone=Color3.fromRGB(230,222,204)
 local metal=Color3.fromRGB(57,65,66)
 local wood=Color3.fromRGB(132,95,60)
 local warm=Color3.fromRGB(255,224,174)
 local function part(name,w,h,d,x,y,z,color,material,rz,ry)
  local p=Instance.new("Part");p.Name=name;p.Size=Vector3.new(w,h,d)
  p.CFrame=origin*CFrame.new(x,y,z)*CFrame.Angles(0,ry or 0,rz or 0)
  p.Color=color;p.Material=material or Enum.Material.Concrete
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=group;return p
 end
 local function lamp(name,x,y,z,range,brightness)
  part(name.."Housing",1.6,3,1.6,x,y,z,metal,Enum.Material.Metal)
  local p=part(name.."Glow",1.7,1.9,1.7,x,y,z,warm,Enum.Material.Neon)
  local l=Instance.new("PointLight");l.Name="WarmLight";l.Color=warm;l.Range=range;l.Brightness=brightness;l.Shadows=false;l.Parent=p
 end
 -- Lettering sits just in front of the entablature, never through walls.
 local sign=part("CourthouseSign",59,6,.25,0,52,-44.2,stone)
 local gui=Instance.new("SurfaceGui");gui.Name="Sign";gui.Face=Enum.NormalId.Front
 gui.CanvasSize=Vector2.new(1475,150);gui.AlwaysOnTop=false;gui.LightInfluence=.4;gui.Parent=sign
 local text=Instance.new("TextLabel");text.Name="Title";text.Size=UDim2.fromScale(1,1)
 text.BackgroundTransparency=1;text.Text="COURTHOUSE";text.TextColor3=metal;text.TextScaled=true;text.Font=Enum.Font.Garamond;text.Parent=gui
 -- Geometry-based balance symbol: mast, crossbar, suspension chains and two pans.
 part("ScalesBase",8,1,.8,0,59,-24.65,metal,Enum.Material.Metal)
 part("ScalesMast",1,15,.8,0,67,-24.65,metal,Enum.Material.Metal)
 part("ScalesBeam",22,.8,.8,0,72,-24.65,metal,Enum.Material.Metal)
 for i,x in ipairs({-9,9}) do
  for j,dx in ipairs({-2.6,2.6}) do
   part("Chain"..i..j,.3,8,.4,x+dx/2,68.2,-24.65,metal,Enum.Material.Metal,-math.atan(dx/7.6))
  end
  part("Pan"..i,7,.7,1.3,x,64,-24.65,metal,Enum.Material.Metal)
  part("PanRim"..i.."L",.4,1.2,1.3,x-3.3,64.5,-24.65,metal,Enum.Material.Metal)
  part("PanRim"..i.."R",.4,1.2,1.3,x+3.3,64.5,-24.65,metal,Enum.Material.Metal)
 end
 -- Ramp rails lie OUTSIDE Z=-38..-30, maintaining eight studs clear width.
 local slope=-math.atan(8/48)
 for side,z in ipairs({-38.3,-29.7}) do
  for j=0,6 do
   local x=36+j*8;local y=(84-x)/6
   part("RampPost"..side..j,.4,3,.4,x,y+1.5,z,metal,Enum.Material.Metal)
  end
  for j,h in ipairs({1.4,3}) do
   part("RampRail"..side..j,math.sqrt(48*48+8*8),.35,.35,60,4+h,z,metal,Enum.Material.Metal,slope)
   part("LandingRail"..side..j,4,.35,.35,34,8+h,z,metal,Enum.Material.Metal)
  end
 end
 -- Stair handrails follow the stepped rise, leaving the wide centre clear.
 for side,x in ipairs({-24,24}) do
  for j=0,4 do
   local z=-67.25+j*6;local y=math.min(8,.5+j*2)
   part("StairPost"..side..j,.4,3,.4,x,y+1.5,z,metal,Enum.Material.Metal)
  end
  -- A bar along local X is turned into the stair's Z direction.
  local p=part("StairRail"..side,math.sqrt(24*24+8*8),.35,.35,x,7.25,-55.25,metal,Enum.Material.Metal)
  -- Explicit pitch about local Z aligns the long local X axis to the slope.
  p.CFrame=origin*CFrame.new(x,7.25,-55.25)*CFrame.Angles(0,-math.pi/2,0)*CFrame.Angles(0,0,math.atan(8/24))
 end
 for i,x in ipairs({-21.6,0,21.6}) do lamp("EntranceLamp"..i,x,18,-24.9,20,.7) end
 for i,x in ipairs({-39,39}) do lamp("StairLamp"..i,x,10,-43,15,.6) end
 -- Four blue flags placed outside stairs and ramp.
 for i,v in ipairs({{-82,-48},{82,-48},{-82,-66},{82,-66}}) do
  part("FlagBase"..i,3,1,3,v[1],.5,v[2],stone)
  part("FlagPole"..i,.45,23,.45,v[1],12.5,v[2],metal,Enum.Material.Metal)
  part("BlueFlag"..i,6,4,.18,v[1]+3,21,v[2],Color3.fromRGB(48,103,153),Enum.Material.Fabric)
 end
 -- Benches face the open forecourt (-Z), with backrests toward the building.
 for i,x in ipairs({-58,58}) do
  for j=0,2 do part("BenchSeat"..i..j,13,.45,.7,x,2.3,-52+j*.8,wood,Enum.Material.Wood) end
  part("BenchBack"..i,13,2,.4,x,3.6,-50,wood,Enum.Material.Wood)
  for j,dx in ipairs({-5,5}) do part("BenchLeg"..i..j,.6,2.1,2.6,x+dx,1.05,-51.2,metal,Enum.Material.Metal) end
 end
 for i,v in ipairs({{-59,-31,32,8},{-62,-61,32,8},{62,-61,32,8},{88,22,6,38},{-88,22,6,38}}) do
  part("Soil"..i,v[3],.4,v[4],v[1],1.3,v[2],Color3.fromRGB(77,67,47),Enum.Material.Ground)
  for j=-1,1 do
   local x,z=v[1],v[2];if i<=3 then x=x+j*10 else z=z+j*11 end
   part("Shrub"..i..j,4,2.5,4,x,2.6,z,Color3.fromRGB(83,122,65),Enum.Material.Grass)
  end
 end
 -- Two compact fan palms in the front planters, clear of the access routes.
 for i,x in ipairs({-62,62}) do
  part("PalmTrunk"..i,1,13,1,x,8,-61,wood,Enum.Material.Wood)
  for j=0,7 do
   local a=j*math.pi/4
   part("PalmLeaf"..i..j,1.5,.35,6,x+math.sin(a)*2.5,14.7,-61+math.cos(a)*2.5,Color3.fromRGB(66,111,62),Enum.Material.Grass,0,a)
  end
 end
 model.Name="LargeCity_Courthouse_P5";model:SetAttribute("Phase",5)
 model:SetAttribute("QualityGateB","Approved");model:SetAttribute("DressingReview","Pending")
 model:SetAttribute("BuildRevision","Courthouse-P5-v1")
 return model
end
return Dressing
