local Dressing={}
function Dressing.Apply(model)
 assert(model and model.PrimaryPart,"Convention ground pivot required")
 assert(not model:FindFirstChild("DestructionGroups"),"Apply dressing before integration")
 local old=model:FindFirstChild("ConventionDressing");if old then old:Destroy() end
 local entrance=model:FindFirstChild("Entrance")
 local fascia=entrance and entrance:FindFirstChild("FrontFascia")
 assert(fascia,"Convention canopy fascia required")
 local oldSign=fascia:FindFirstChild("ConventionTitle");if oldSign then oldSign:Destroy() end
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA("BasePart") and p~=model.PrimaryPart then
   local name,source=p.Name,p.Parent.Name
   p.Material=Enum.Material.Concrete;p.Transparency=0;p.Reflectance=0
   if string.find(name,"Glass") or string.find(name,"Clerestory") or string.find(name,"Slope") or string.find(name,"Guard") then
    p.Material=Enum.Material.Glass;p.Color=Color3.fromRGB(126,178,186);p.Transparency=.5;p.Reflectance=.04
   elseif source=="RoofSegments" or name=="Canopy" then
    p.Material=Enum.Material.Metal;p.Color=Color3.fromRGB(213,223,226)
   elseif source=="RoofFrames" or string.find(name,"Post") or string.find(name,"Mullion") or string.find(name,"Gate") or string.find(name,"Fascia") or (source=="Entrance" and string.sub(name,1,1)=="V") or (source=="Foyer" and string.find(name,"Front")) then
    p.Material=Enum.Material.Metal
   end
  end
 end
 local group=Instance.new("Model");group.Name="ConventionDressing";group.Parent=model
 local origin=model:GetPivot()
 local stone=Color3.fromRGB(234,228,213)
 local metal=Color3.fromRGB(61,73,78)
 local wood=Color3.fromRGB(142,104,68)
 local green=Color3.fromRGB(73,122,73)
 local warm=Color3.fromRGB(255,230,192)
 local function part(n,w,h,d,x,y,z,c,m,ry)
  local p=Instance.new("Part");p.Name=n;p.Size=Vector3.new(w,h,d)
  p.CFrame=origin*CFrame.new(x,y,z)*CFrame.Angles(0,ry or 0,0)
  p.Color=c;p.Material=m or Enum.Material.Concrete;p.Anchored=true;p.CanCollide=false;p.CanTouch=false
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=group;return p
 end
 local function light(p,range,brightness)
  local l=Instance.new("PointLight");l.Name="WarmLight";l.Color=warm;l.Range=range;l.Brightness=brightness;l.Shadows=false;l.Parent=p
 end
 -- Sign directly belongs to the existing canopy fascia; no coplanar extra sign board.
 local gui=Instance.new("SurfaceGui");gui.Name="ConventionTitle";gui.Face=Enum.NormalId.Front
 gui.CanvasSize=Vector2.new(2240,80);gui.LightInfluence=.15;gui.AlwaysOnTop=false;gui.Parent=fascia
 local text=Instance.new("TextLabel");text.Name="Title";text.Size=UDim2.fromScale(.94,.82);text.Position=UDim2.fromScale(.03,.09)
 text.BackgroundTransparency=1;text.Text="COAST CONVENTION CENTRE";text.TextColor3=Color3.fromRGB(250,246,231)
 text.TextScaled=true;text.Font=Enum.Font.GothamMedium;text.Parent=gui
 -- Flush fixtures touch the supporting roof/slab undersides.
 for i,x in ipairs({-36,-12,12,36}) do
  light(part("CanopyLamp"..i,3,.3,2,x,27.85,-72,warm,Enum.Material.Neon),23,.65)
 end
 for i,x in ipairs({-48,-16,16,48}) do
  light(part("FoyerLamp"..i,4,.4,2,x,33.8,-52,warm,Enum.Material.Neon),29,.65)
 end
 for i,x in ipairs({-50,50}) do
  light(part("GalleryUnderLamp"..i,3,.3,2,x,17.85,-36,warm,Enum.Material.Neon),22,.5)
 end
 -- Hall light brackets attach to the inner face of each outer wall.
 for hall,x in ipairs({-85.4,85.4}) do
  local sign=x<0 and 1 or -1
  for i,z in ipairs(hall==1 and {0,48} or {8,56}) do
   part("HallBracket"..hall..i,1.2,.4,2,x,24,z,metal,Enum.Material.Metal)
   light(part("HallLamp"..hall..i,.4,1.4,1.6,x+sign*.8,23.5,z,warm,Enum.Material.Neon),38,.75)
  end
 end
 for i,x in ipairs({-44,-12,44}) do
  part("DeliveryBracket"..i,2,.5,.8,x,22,80.4,metal,Enum.Material.Metal)
  light(part("DeliveryLamp"..i,1.7,.6,.6,x,21.7,80.5,warm,Enum.Material.Neon),18,.5)
 end
 -- Handrails cap the approved glass guards; no new glazing overlaps.
 part("RearGalleryRail",140,.35,.5,0,22.15,-40,metal,Enum.Material.Metal)
 for i,x in ipairs({-70,70}) do part("SideGalleryRail"..i,.5,.35,22,x,22.15,-51,metal,Enum.Material.Metal) end
 -- Two benches in front of the planters, backs towards the building, seats towards -Z.
 for i,x in ipairs({-70,70}) do
  for j=0,2 do part("BenchSeat"..i..j,12,.4,.7,x,2.1,-101+j*.8,wood,Enum.Material.Wood) end
  part("BenchBack"..i,12,2,.4,x,3.2,-98.9,wood,Enum.Material.Wood)
  for j,dx in ipairs({-4.5,4.5}) do part("BenchLeg"..i..j,.65,1.8,2.6,x+dx,1,-100.2,metal,Enum.Material.Metal) end
 end
 -- Four grounded forecourt lamps, all outside the central entrance and right delivery lane.
 for i,v in ipairs({{-40,-100},{40,-100},{-85,-82},{85,-82}}) do
  local x,z=v[1],v[2]
  part("LampBase"..i,1.8,.6,1.8,x,.4,z,stone)
  part("LampPost"..i,.55,8.5,.55,x,4.95,z,metal,Enum.Material.Metal)
  light(part("ForecourtLamp"..i,.9,1.4,.9,x,9.4,z,warm,Enum.Material.Neon),20,.55)
 end
 -- Planting only inside the three approved islands. Leaves stay clear of the delivery lane.
 for i,v in ipairs({{-70,-91,24,10},{70,-91,24,10},{-99,-60,12,32}}) do
  local x,z,w,d=v[1],v[2],v[3],v[4]
  part("Soil"..i,w-2.2,.5,d-2.2,x,.8,z,Color3.fromRGB(85,72,50),Enum.Material.Ground)
  for j,dx in ipairs({-3,3}) do part("Shrub"..i..j,3.5,2.5,3.5,x+dx,2.1,z,green,Enum.Material.Grass) end
  part("PalmTrunk"..i,1.3,14,1.3,x,8,z,wood,Enum.Material.Wood)
  for j=0,7 do
   local a=j*math.pi/4
   part("PalmLeaf"..i..j,1.4,.3,5,x+math.sin(a)*2.2,15,z+math.cos(a)*2.2,green,Enum.Material.Grass,a)
  end
 end
 -- A few foyer planters leave both the staircase and entrance axes open.
 for i,x in ipairs({-56,56}) do
  part("FoyerPlanter"..i,4,1.8,4,x,1.4,-55,stone)
  part("FoyerPlant"..i,3,3,3,x,3.8,-55,green,Enum.Material.Grass)
 end
 model.Name="LargeCity_CoastConventionCentre_P5";model:SetAttribute("Phase",5)
 model:SetAttribute("QualityGateB","Approved");model:SetAttribute("DressingReview","Pending")
 model:SetAttribute("BuildRevision","CoastConventionCentre-P5-v1")
 return model
end
return Dressing
