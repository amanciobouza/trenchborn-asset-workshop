-- City Hotel P5: approved geometry, warm stone/bronze, tropical forecourt.
local Dressing = {}
function Dressing.Apply(model)
 assert(model and model.PrimaryPart, "City Hotel ground pivot required")
 assert(not model:FindFirstChild("DestructionGroups"), "Apply dressing before gameplay integration")
 local old=model:FindFirstChild("HotelDressing")
 if old then old:Destroy() end
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA("BasePart") and p.Name~="GroundPivot" then
   p.Material=Enum.Material.Concrete;p.Reflectance=0;p.Transparency=0
   if string.find(p.Name,"Glass") then
    p.Material=Enum.Material.Glass;p.Reflectance=.08
    if string.match(p.Parent.Name,"^Podium") then
     p.Transparency=.55;p.Color=Color3.fromRGB(158,181,182)
    end
   elseif string.find(p.Name,"Frame") or string.find(p.Name,"Mullion") or string.find(p.Name,"Flute") or string.find(p.Name,"Handle") then
    p.Material=Enum.Material.Metal
   elseif p.Name=="Drive" then
    p.Material=Enum.Material.Asphalt;p.Color=Color3.fromRGB(103,106,102)
   end
  end
 end
 local group=Instance.new("Model");group.Name="HotelDressing";group.Parent=model
 local origin=model:GetPivot()
 local cream=Color3.fromRGB(238,229,209)
 local bronze=Color3.fromRGB(149,114,68)
 local warm=Color3.fromRGB(255,221,160)
 local wood=Color3.fromRGB(129,91,57)
 local function part(name,size,cf,color,material)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=origin*cf
  p.Color=color;p.Material=material or Enum.Material.Concrete
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  p.Parent=group;return p
 end
 local function block(name,w,h,d,x,y,z,color,material)
  return part(name,Vector3.new(w,h,d),CFrame.new(x,y,z),color,material)
 end
 local function light(p,range,brightness)
  local l=Instance.new("PointLight");l.Name="WarmLight";l.Color=warm
  l.Range=range;l.Brightness=brightness;l.Shadows=false;l.Parent=p
 end
 -- Individual backing panels own the letters. Front face is local -Z.
 for i,letter in ipairs({"H","O","T","E","L"}) do
  local p=block("HotelLetter"..i,14,19,.4,0,188-i*24,-29.4,bronze,Enum.Material.Metal)
  local gui=Instance.new("SurfaceGui");gui.Name="Letter";gui.Face=Enum.NormalId.Front
  gui.CanvasSize=Vector2.new(280,380);gui.AlwaysOnTop=false;gui.LightInfluence=0;gui.Parent=p
  local text=Instance.new("TextLabel");text.Name="Glyph";text.Size=UDim2.fromScale(1,1)
  text.BackgroundTransparency=1;text.Text=letter;text.TextColor3=warm
  text.TextScaled=true;text.Font=Enum.Font.Garamond;text.Parent=gui
 end
 -- Cornice strips and canopy edge are outside the approved solid geometry.
 for i,v in ipairs({{128,.65,.25,0,201,-28.2},{128,.65,.25,0,201,52.2},{.25,.65,80,-64.2,201,12},{.25,.65,80,64.2,201,12}}) do
  block("CorniceLightStrip"..i,v[1],v[2],v[3],v[4],v[5],v[6],warm,Enum.Material.Neon)
 end
 block("CanopyEdge",72,.6,.25,0,23,-56.2,bronze,Enum.Material.Metal)
 -- Fixtures mounted on the front edge, wholly above Y20: no loss of clearance.
 for i,x in ipairs({-24,0,24}) do
  local p=block("CanopyLight"..i,2,.4,.3,x,20.4,-56.2,warm,Enum.Material.Neon);light(p,23,.8)
 end
 -- Simple room-like interior scenes behind podium glazing, on both levels.
 for floor=0,1 do
  local y=floor*18+1
  block("InteriorBackdrop"..floor,124,15,1,0,y+7.5,6,cream)
  block("Reception"..floor,22,4,4,-12,y+2,-16,wood,Enum.Material.Wood)
  block("ReceptionTop"..floor,23,.5,4.5,-12,y+4.25,-16,cream)
  block("SofaSeat"..floor,12,2,5,-44,y+1,-15,bronze,Enum.Material.Fabric)
  block("SofaBack"..floor,12,4,1,-44,y+2,-12.5,bronze,Enum.Material.Fabric)
  for j,x in ipairs({31,49}) do
   block("Table"..floor..j,9,.6,7,x,y+4,-15,wood,Enum.Material.Wood)
   block("TableLeg"..floor..j,1,3.7,1,x,y+1.85,-15,bronze,Enum.Material.Metal)
   for k,z in ipairs({-21,-9}) do
    block("Chair"..floor..j..k,4,2,3,x,y+1,z,bronze,Enum.Material.Fabric)
   end
  end
  for j,x in ipairs({-24,34}) do
   local p=block("InteriorLamp"..floor..j,5,.5,5,x,y+13,-14,warm,Enum.Material.Neon);light(p,28,.8)
  end
 end
 local function palm(id,x,z,h)
  block(id.."Trunk",1.4,h,1.4,x,2+h/2,z,wood,Enum.Material.Wood)
  for k=0,7 do
   local cf=CFrame.new(x,2+h,z)*CFrame.Angles(0,k*math.pi/4,0)
   part(id.."Leaf"..k,Vector3.new(1.7,.3,4),cf*CFrame.new(0,.4,-1.8)*CFrame.Angles(.2,0,0),Color3.fromRGB(65,113,66),Enum.Material.Grass)
   part(id.."Tip"..k,Vector3.new(.9,.25,3),cf*CFrame.new(0,0,-5)*CFrame.Angles(-.45,0,0),Color3.fromRGB(81,132,70),Enum.Material.Grass)
  end
 end
 for i,v in ipairs({{-55,-65,24},{55,-65,27},{-78,22,24},{78,38,26}}) do palm("Palm"..i,v[1],v[2],v[3]) end
 for i,v in ipairs({{-55,-65,32,8},{55,-65,32,8},{-78,20,6,34},{78,38,6,22}}) do
  block("Soil"..i,v[3],.5,v[4],v[1],1.3,v[2],Color3.fromRGB(75,64,45),Enum.Material.Ground)
  for j=-1,1 do
   local x,z=v[1],v[2]
   if i<=2 then x=x+j*10 else z=z+j*7 end
   block("Shrub"..i..j,4,2.4,3,x,2.5,z,Color3.fromRGB(84,123,65),Enum.Material.Grass)
  end
  local p=block("PlanterLamp"..i,1,.5,1,v[1]+2,2.1,v[2]+2,warm,Enum.Material.Neon);light(p,13,.45)
 end
 local p=block("DeliveryLamp",.3,1,3,-65.6,14,30,warm,Enum.Material.Neon);light(p,15,.5)
 model.Name="LargeCity_CityHotel_P5"
 model:SetAttribute("Phase",5);model:SetAttribute("QualityGateB","Approved")
 model:SetAttribute("DressingReview","Pending");model:SetAttribute("BuildRevision","CityHotel-P5-v1")
 return model
end
return Dressing
