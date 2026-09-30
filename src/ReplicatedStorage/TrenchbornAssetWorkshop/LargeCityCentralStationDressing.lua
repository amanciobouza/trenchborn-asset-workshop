-- P5 dressing. Clock is a static analog display; no timetable or train runtime.
local Dressing={}
function Dressing.Apply(model)
 assert(model and model.PrimaryPart,"Station ground pivot required")
 assert(not model:FindFirstChild("DestructionGroups"),"Apply dressing before integration")
 local old=model:FindFirstChild("StationDressing");if old then old:Destroy() end
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA("BasePart") and p.Name~="GroundPivot" then
   p.Material=Enum.Material.Concrete;p.Transparency=0;p.Reflectance=0
   if string.find(p.Name,"Glass") or p.Parent.Name=="HallRoof" or (p.Parent.Name=="ConcourseCover" and p.Name=="Roof") then
    p.Material=Enum.Material.Glass;p.Color=Color3.fromRGB(135,168,180);p.Transparency=.45;p.Reflectance=.07
   elseif p.Parent.Name=="HallFrames" or string.find(p.Name,"Frame") or string.find(p.Name,"Mullion") or string.find(p.Name,"Rail") or string.find(p.Name,"Buffer") then
    p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(63,72,78)
   elseif string.find(p.Name,"Sleeper") then p.Material=Enum.Material.Wood end
  end
 end
 local group=Instance.new("Model");group.Name="StationDressing";group.Parent=model
 local origin=model:GetPivot()
 local metal=Color3.fromRGB(61,70,74)
 local stone=Color3.fromRGB(231,223,205)
 local wood=Color3.fromRGB(133,96,59)
 local warm=Color3.fromRGB(255,227,175)
 local function part(name,size,cf,color,material)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=origin*cf
  p.Color=color;p.Material=material or Enum.Material.Concrete
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=group
  return p
 end
 local function block(n,w,h,d,x,y,z,c,m) return part(n,Vector3.new(w,h,d),CFrame.new(x,y,z),c,m) end
 -- Clock face already has diameter12. Markers/hands are offset beyond its front face.
 for i=0,11 do
  local a=i*math.pi/6
  part("ClockTick"..i,Vector3.new(i%3==0 and .32 or .2,i%3==0 and 1.1 or .7,.12),CFrame.new(5*math.sin(a),42+5*math.cos(a),-97.32)*CFrame.Angles(0,0,-a),metal,Enum.Material.Metal)
 end
 local function hand(name,length,angle,width,z)
  local a=math.rad(angle)
  part(name,Vector3.new(width,length,.15),CFrame.new(-math.sin(a)*length/2,42+math.cos(a)*length/2,z)*CFrame.Angles(0,0,a),metal,Enum.Material.Metal)
 end
 hand("ClockHour",3,60,.4,-97.5);hand("ClockMinute",4.4,-60,.25,-97.7)
 block("ClockHub",.7,.7,.2,0,42,-97.9,metal,Enum.Material.Metal)
 local sign=block("StationSign",74,5,.2,0,27,-96.2,stone)
 local gui=Instance.new("SurfaceGui");gui.Name="Sign";gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(1480,100);gui.AlwaysOnTop=false;gui.LightInfluence=.4;gui.Parent=sign
 local text=Instance.new("TextLabel");text.Name="Title";text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1
 text.Text="CENTRAL STATION";text.TextColor3=metal;text.TextScaled=true;text.Font=Enum.Font.Garamond;text.Parent=gui
 -- Edge markings on top of platforms, outside both track clearance envelopes.
 for i,x in ipairs({-24.7,24.7}) do
  block("PlatformEdge"..i,1,.06,143,x,3.04,40,Color3.fromRGB(240,196,74))
 end
 local function bench(name,x,z,y,yaw)
  local cf=CFrame.new(x,y,z)*CFrame.Angles(0,yaw,0)
  for j=0,2 do part(name.."Slat"..j,Vector3.new(10,.4,.65),cf*CFrame.new(0,2.2,-.7+j*.75),wood,Enum.Material.Wood) end
  part(name.."Back",Vector3.new(10,2,.4),cf*CFrame.new(0,3.4,1.1),wood,Enum.Material.Wood)
  for j,dx in ipairs({-3.8,3.8}) do part(name.."Leg"..j,Vector3.new(.5,2,2.5),cf*CFrame.new(dx,1,0),metal,Enum.Material.Metal) end
 end
 for side,x in ipairs({-37,37}) do
  for j,z in ipairs({-8,44,96}) do bench("PlatformBench"..side..j,x,z,3,side==1 and -math.pi/2 or math.pi/2) end
 end
 bench("FrontBench1",-48,-120,0,0);bench("FrontBench2",48,-120,0,0)
 local function light(name,x,y,z,range,brightness)
  local p=block(name,1,1.6,1,x,y,z,warm,Enum.Material.Neon)
  local l=Instance.new("PointLight");l.Name="WarmLight";l.Color=warm;l.Range=range;l.Brightness=brightness;l.Shadows=false;l.Parent=p
 end
 for side,x in ipairs({-42,42}) do
  for j,z in ipairs({-18,34,86}) do
   block("PlatformPost"..side..j,.6,8,.6,x,7,z,metal,Enum.Material.Metal)
   light("PlatformLamp"..side..j,x,11,z,22,.6)
  end
 end
 -- Mount to the stone portal piers, not to glass or open doorways.
 for i,x in ipairs({-36,-12,12,36}) do
  block("EntranceBracket"..i,1.4,3,.35,x,17,-96.2,metal,Enum.Material.Metal)
  light("EntranceLamp"..i,x,17,-96.7,17,.6)
 end
 for i,v in ipairs({{-88,-122},{88,-122},{-97,-103},{97,-103}}) do
  block("ForecourtBase"..i,2,1,2,v[1],.5,v[2],stone)
  block("ForecourtPost"..i,.6,9,.6,v[1],5.5,v[2],metal,Enum.Material.Metal)
  light("ForecourtLamp"..i,v[1],10,v[2],20,.6)
 end
 for i,v in ipairs({{-68,-122,26,8},{68,-122,26,8},{-96,-67,6,34},{96,-67,6,34}}) do
  block("Soil"..i,v[3],.4,v[4],v[1],1.3,v[2],Color3.fromRGB(76,66,48),Enum.Material.Ground)
  for j=-1,1 do
   local x,z=v[1],v[2];if i<=2 then x=x+j*8 else z=z+j*10 end
   block("Shrub"..i..j,3.5,2.2,3.5,x,2.5,z,Color3.fromRGB(86,126,66),Enum.Material.Grass)
  end
 end
 -- Two fan palms mark the forecourt without blocking any of the three portals.
 for i,x in ipairs({-68,68}) do
  block("PalmTrunk"..i,1.2,16,1.2,x,9.5,-122,wood,Enum.Material.Wood)
  for j=0,7 do
   local a=j*math.pi/4
   part("PalmLeaf"..i..j,Vector3.new(1.5,.3,6),CFrame.new(x+math.sin(a)*2.5,17.6,-122+math.cos(a)*2.5)*CFrame.Angles(0,a,0),Color3.fromRGB(65,113,64),Enum.Material.Grass)
  end
 end
 model.Name="LargeCity_CentralStation_P5";model:SetAttribute("Phase",5)
 model:SetAttribute("QualityGateB","Approved");model:SetAttribute("DressingReview","Pending")
 model:SetAttribute("BuildRevision","CentralStation-P5-v1")
 return model
end
return Dressing
