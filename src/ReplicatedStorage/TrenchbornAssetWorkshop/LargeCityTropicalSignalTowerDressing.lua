local Dressing={}
function Dressing.Apply(model)
 assert(model and model.PrimaryPart,"Signal Tower ground pivot required")
 assert(not model:FindFirstChild("DestructionGroups"),"Apply dressing before integration")
 local old=model:FindFirstChild("SignalTowerDressing");if old then old:Destroy() end
 local cyan=Color3.fromRGB(52,228,232)
 local warm=Color3.fromRGB(255,230,193)
 local function light(p,color,range,brightness)
  local l=Instance.new("PointLight");l.Name="SignalDressingLight";l.Color=color;l.Range=range;l.Brightness=brightness;l.Shadows=false;l.Parent=p
 end
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA("BasePart") and p~=model.PrimaryPart then
   local oldLight=p:FindFirstChild("SignalDressingLight");if oldLight then oldLight:Destroy() end
   local source,name=p.Parent.Name,p.Name
   p.Material=Enum.Material.Concrete;p.Transparency=0;p.Reflectance=0
   if string.find(name,"Glass") then
    p.Material=Enum.Material.Glass;p.Color=Color3.fromRGB(128,184,190);p.Transparency=.5;p.Reflectance=.04
   elseif source=="Cabin" and string.match(name,"^LightRing%d+$") then
    p.Material=Enum.Material.Neon;p.Color=cyan
    if tonumber(string.match(name,"%d+$"))%8==0 then light(p,cyan,16,.45) end
   elseif source=="Signal" and name=="Tip" then
    p.Material=Enum.Material.Neon;p.Color=cyan;light(p,cyan,15,.65)
   elseif source=="ShaftDetail" or string.find(name,"Mullion") or string.find(name,"TopBand") or (source=="Platform" and name~="Floor") or (source=="Signal" and (name=="Mast" or string.find(name,"Fin"))) or (source=="Entrance" and string.find(name,"Column")) then
    p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(62,74,78)
   elseif source~="Site" then p.Color=Color3.fromRGB(232,226,211) end
  end
 end
 local group=Instance.new("Model");group.Name="SignalTowerDressing";group.Parent=model
 local origin=model:GetPivot()
 local stone=Color3.fromRGB(234,228,214)
 local metal=Color3.fromRGB(62,74,78)
 local wood=Color3.fromRGB(140,102,67)
 local green=Color3.fromRGB(68,121,71)
 local function part(n,w,h,d,x,y,z,c,m,ry)
  local p=Instance.new("Part");p.Name=n;p.Size=Vector3.new(w,h,d)
  p.CFrame=origin*CFrame.new(x,y,z)*CFrame.Angles(0,ry or 0,0)
  p.Color=c;p.Material=m or Enum.Material.Concrete;p.Anchored=true;p.CanCollide=false;p.CanTouch=false
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=group;return p
 end
 -- Ceiling fixtures meet the existing slab undersides.
 for i,x in ipairs({-8,8}) do light(part("CanopyLamp"..i,2,.3,1,x,13.85,-44,warm,Enum.Material.Neon),18,.6) end
 for i=0,3 do
  local a=i*math.pi/2+math.pi/4
  light(part("PodiumLamp"..i,3,.3,2,25*math.cos(a),15.85,25*math.sin(a),warm,Enum.Material.Neon,-a),25,.55)
  light(part("CabinLamp"..i,3,.3,2,24*math.cos(a),358.85,24*math.sin(a),warm,Enum.Material.Neon,-a),24,.5)
 end
 -- Three restrained markers attach to the revised dark shaft strip.
 for i,v in ipairs({{51,21.5},{165,14.5},{279,11.75}}) do
  local y,r=v[1],v[2]
  part("ShaftBracket"..i,1.6,1.5,1,0,y,-r-.3,metal,Enum.Material.Metal)
  light(part("ShaftLamp"..i,1.2,.65,.2,0,y,-r-.8,warm,Enum.Material.Neon),10,.3)
 end
 -- Bench backs face the planters/building; seats face the forecourt (-Z).
 for i,x in ipairs({-32,32}) do
  for j=0,2 do part("BenchSeat"..i..j,10,.4,.6,x,2,-52+j*.7,wood,Enum.Material.Wood) end
  part("BenchBack"..i,10,2,.4,x,3.1,-50.15,wood,Enum.Material.Wood)
  for j,dx in ipairs({-3.7,3.7}) do part("BenchLeg"..i..j,.6,1.8,2.4,x+dx,.9,-51.2,metal,Enum.Material.Metal) end
 end
 for i,v in ipairs({{-49,-45},{49,-45},{-22,-52},{22,-52}}) do
  local x,z=v[1],v[2]
  part("ForecourtBase"..i,1.6,.6,1.6,x,.3,z,stone)
  part("ForecourtPost"..i,.5,7,.5,x,4.1,z,metal,Enum.Material.Metal)
  light(part("ForecourtLamp"..i,.85,1.2,.85,x,7.8,z,warm,Enum.Material.Neon),18,.5)
 end
 for i,v in ipairs({{-33,-42,16,10},{33,-42,16,10},{-47,-15,10,16},{47,-15,10,16}}) do
  local x,z,w,d=v[1],v[2],v[3],v[4]
  part("Soil"..i,w-2.2,.6,d-2.2,x,1.2,z,Color3.fromRGB(83,72,50),Enum.Material.Ground)
  for j,dz in ipairs({-2.5,2.5}) do part("Shrub"..i..j,3,2.4,3,x,2.6,z+dz,green,Enum.Material.Grass) end
  local h=i<=2 and 17 or 14
  part("PalmTrunk"..i,1.2,h,1.2,x,1.5+h/2,z,wood,Enum.Material.Wood)
  for j=0,7 do
   local a=j*math.pi/4
   part("PalmLeaf"..i..j,1.4,.3,5,x+math.sin(a)*2.2,1.5+h,z+math.cos(a)*2.2,green,Enum.Material.Grass,a)
  end
 end
 model.Name="LargeCity_TropicalSignalTower_P5";model:SetAttribute("Phase",5)
 model:SetAttribute("QualityGateB","Approved");model:SetAttribute("DressingReview","Pending")
 model:SetAttribute("BuildRevision","TropicalSignalTower-P5-v1")
 return model
end
return Dressing
