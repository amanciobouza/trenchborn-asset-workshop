local Dressing={}
function Dressing.Apply(model)
 assert(model and model.PrimaryPart,"High-Rise ground pivot required")
 assert(not model:FindFirstChild("DestructionGroups"),"Apply dressing before integration")
 local old=model:FindFirstChild("HighRiseDressing");if old then old:Destroy() end
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA("BasePart") and p~=model.PrimaryPart then
   local name,source=p.Name,p.Parent.Name
   p.Material=Enum.Material.Concrete;p.Transparency=0;p.Reflectance=0
   if string.find(name,"Glass") or string.find(name,"Guard") then
    p.Material=Enum.Material.Glass;p.Color=Color3.fromRGB(129,183,188);p.Transparency=.45;p.Reflectance=.04
   elseif string.find(name,"Frame") or string.find(name,"Mullion") or string.find(name,"Rail") or string.find(name,"EntryHeader") or string.find(name,"Inner") then
    p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(62,75,78)
   elseif name=="FrontTrim" or (source=="Crown" and string.find(name,"Beam")) then
    p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(133,111,81)
   elseif source~="Site" then p.Color=Color3.fromRGB(233,226,212) end
  end
 end
 local group=Instance.new("Model");group.Name="HighRiseDressing";group.Parent=model
 local origin=model:GetPivot()
 local stone=Color3.fromRGB(235,228,213)
 local metal=Color3.fromRGB(62,75,78)
 local wood=Color3.fromRGB(142,104,68)
 local green=Color3.fromRGB(65,119,69)
 local warm=Color3.fromRGB(255,230,192)
 local cyan=Color3.fromRGB(54,220,226)
 local function part(n,w,h,d,x,y,z,c,m,ry,owner)
  local p=Instance.new("Part");p.Name=n;p.Size=Vector3.new(w,h,d)
  p.CFrame=origin*CFrame.new(x,y,z)*CFrame.Angles(0,ry or 0,0)
  p.Color=c;p.Material=m or Enum.Material.Concrete;p.Anchored=true;p.CanCollide=false;p.CanTouch=false
  p:SetAttribute("DressingOwner",owner or "Site")
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=group;return p
 end
 local function light(p,range,brightness)
  local l=Instance.new("PointLight");l.Name="DressingLight";l.Color=p.Color;l.Range=range;l.Brightness=brightness;l.Shadows=false;l.Parent=p
 end
 local function planting(n,x,z,w,d,y,owner,palm,palmHeight,leafLength)
  part(n.."Soil",w-1.2,.5,d-1.2,x,y+.8,z,Color3.fromRGB(85,73,50),Enum.Material.Ground,0,owner)
  -- Long troughs get a hedge inside the rim, not foliage across the walking strip.
  part(n.."Hedge",w-1.4,2,d-1.4,x,y+1.9,z,green,Enum.Material.Grass,0,owner)
  if palm then
   local h=palmHeight or 10
   part(n.."Trunk",.9,h,.9,x,y+1+h/2,z,wood,Enum.Material.Wood,0,owner)
   for j=0,7 do
    local a=j*math.pi/4;local len=leafLength or 3.6
    part(n.."Leaf"..j,1.1,.25,len,x+math.sin(a)*len*.4,y+1+h,z+math.cos(a)*len*.4,green,Enum.Material.Grass,a,owner)
   end
  end
 end
 -- Four cyan accents attach to the smaller open frame, inside the crown envelope.
 for i,x in ipairs({-18.5,18.5}) do
  for j,z in ipairs({-11.15,11.15}) do
   light(part("CrownLight"..i..j,.6,10,.3,x,370,z,cyan,Enum.Material.Neon,0,"Crown"),16,.45)
  end
 end
 for i,x in ipairs({-12,12}) do light(part("CanopyLamp"..i,3,.3,2,x,15.85,-55,warm,Enum.Material.Neon,0,"Entrance"),23,.6) end
 -- A few warm lobby fixtures on each of the two podium ceilings.
 for floor=0,1 do
  for i,x in ipairs({-24,24}) do
   for j,z in ipairs({-24,24}) do
    light(part("LobbyLamp"..floor..i..j,4,.3,2,x,floor*18+17.25,z,warm,Enum.Material.Neon,0,floor==0 and "Podium01" or "Podium02"),28,.5)
   end
  end
 end
 for level,v in ipairs({{"PodiumTerrace",112,96,36},{"TerraceLower",88,72,164},{"TerraceMiddle",72,56,276}}) do
  local owner,w,d,y=v[1],v[2],v[3],v[4]
  for j,sign in ipairs({-1,1}) do
   for i,x in ipairs({-w/4,w/4}) do
    planting("Terrace"..level..j..i,x,sign*(d/2-2.5),w/4,3,y,owner,i==j,level==1 and 12 or 10,3.4)
   end
  end
  for i,x in ipairs({-w/2+4,w/2-4}) do
   part("TerraceLampBase"..level..i,1,.4,1,x,y+.2,0,stone,nil,0,owner)
   part("TerraceLampPost"..level..i,.4,1.6,.4,x,y+1.2,0,metal,Enum.Material.Metal,0,owner)
   light(part("TerraceLamp"..level..i,.65,.8,.65,x,y+2.2,0,warm,Enum.Material.Neon,0,owner),14,.35)
  end
 end
 for i,x in ipairs({-23,23}) do planting("Roof"..i,x,0,3,18,356,"RoofGarden",true,9,2.6) end
 for i,v in ipairs({{-43,-56,22,8},{43,-56,22,8},{-64,-20,8,20},{64,-20,8,20}}) do
  planting("Ground"..i,v[1],v[2],v[3],v[4],0,"Site",true,13,4)
 end
 -- Bench backs face the building; seats face the front edge of the plot.
 for i,x in ipairs({-43,43}) do
  for j=0,2 do part("BenchSeat"..i..j,11,.4,.65,x,2,-63+j*.75,wood,Enum.Material.Wood) end
  part("BenchBack"..i,11,2,.4,x,3.1,-61.1,wood,Enum.Material.Wood)
  for j,dx in ipairs({-4,4}) do part("BenchLeg"..i..j,.6,1.8,2.6,x+dx,.9,-62.2,metal,Enum.Material.Metal) end
 end
 for i,v in ipairs({{-60,-54},{60,-54},{-68,20},{68,20}}) do
  local x,z=v[1],v[2]
  part("GroundLampBase"..i,1.6,.6,1.6,x,.3,z,stone)
  part("GroundLampPost"..i,.5,7,.5,x,4.1,z,metal,Enum.Material.Metal)
  light(part("GroundLamp"..i,.85,1.2,.85,x,7.8,z,warm,Enum.Material.Neon),19,.5)
 end
 model.Name="LargeCity_TropicalHighRise_P5";model:SetAttribute("Phase",5)
 model:SetAttribute("QualityGateB","Approved");model:SetAttribute("DressingReview","Pending")
 model:SetAttribute("BuildRevision","TropicalHighRise-P5-v2")
 return model
end
return Dressing
