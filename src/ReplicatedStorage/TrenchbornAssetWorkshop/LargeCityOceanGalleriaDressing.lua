local Dressing={}
function Dressing.Apply(model)
 assert(model and model.PrimaryPart,"Galleria ground pivot required")
 assert(not model:FindFirstChild("DestructionGroups"),"Apply dressing before integration")
 local old=model:FindFirstChild("GalleriaDressing");if old then old:Destroy() end
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA("BasePart") and p.Name~="GroundPivot" then
   p.Material=Enum.Material.Concrete;p.Transparency=0;p.Reflectance=0
   if string.find(p.Name,"Glass") or p.Parent.Name=="GlassRoof" or p.Parent.Name=="Fanlight" then
    p.Material=Enum.Material.Glass;p.Color=Color3.fromRGB(135,177,187);p.Transparency=.5;p.Reflectance=.06
   elseif string.find(p.Name,"Guard") then
    p.Material=Enum.Material.Glass;p.Color=Color3.fromRGB(153,190,195);p.Transparency=.45
   elseif p.Parent.Name=="RoofFrames" or p.Parent.Name=="RoofPlant" or string.find(p.Name,"Frame") or string.find(p.Name,"Mullion") or string.find(p.Name,"Gate") then
    p.Material=Enum.Material.Metal
   elseif string.find(p.Name,"Teal") or p.Name=="Canopy" then p.Material=Enum.Material.SmoothPlastic end
  end
 end
 local group=Instance.new("Model");group.Name="GalleriaDressing";group.Parent=model
 local origin=model:GetPivot()
 local teal=Color3.fromRGB(36,139,149)
 local stone=Color3.fromRGB(231,223,205)
 local metal=Color3.fromRGB(62,73,77)
 local wood=Color3.fromRGB(132,94,59)
 local warm=Color3.fromRGB(255,229,181)
 local function part(n,w,h,d,x,y,z,c,m,ry)
  local p=Instance.new("Part");p.Name=n;p.Size=Vector3.new(w,h,d)
  p.CFrame=origin*CFrame.new(x,y,z)*CFrame.Angles(0,ry or 0,0)
  p.Color=c;p.Material=m or Enum.Material.Concrete;p.Anchored=true;p.CanCollide=false;p.CanTouch=false
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=group;return p
 end
 local function light(p,range,brightness)
  local l=Instance.new("PointLight");l.Name="WarmLight";l.Color=warm;l.Range=range;l.Brightness=brightness;l.Shadows=false;l.Parent=p
 end
 local sign=part("GalleriaSign",62,6,.35,0,23,-49,teal,Enum.Material.Metal)
 -- Sign supported above the canopy rather than floating in front of the facade.
 for i,x in ipairs({-28,28}) do part("SignSupport"..i,1,6,1,x,23,-48.5,teal,Enum.Material.Metal) end
 local gui=Instance.new("SurfaceGui");gui.Name="Sign";gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(1240,120);gui.LightInfluence=0;gui.AlwaysOnTop=false;gui.Parent=sign
 local text=Instance.new("TextLabel");text.Name="Title";text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1
 text.Text="OCEAN GALLERIA";text.TextColor3=Color3.fromRGB(245,245,231);text.TextScaled=true;text.Font=Enum.Font.GothamMedium;text.Parent=gui
 -- Three levels of reduced storefront scenes behind the front glazing.
 for floor=0,2 do
  local y=floor*18+1
  for i,x in ipairs({-80,-48,48,80}) do
   local id=floor.."_"..i
   part("ShopBackdrop"..id,28,13,.6,x,y+6.5,-32,stone)
   part("ShopCounter"..id,12,3,3,x,y+1.5,-40,wood,Enum.Material.Wood)
   for j,dx in ipairs({-4,4}) do
    part("DisplayPlinth"..id..j,3,3.5,3,x+dx,y+1.75,-36,teal)
    part("DisplayObject"..id..j,1.8,2,1.8,x+dx,y+4.5,-36,Color3.fromRGB(201,162,108),Enum.Material.SmoothPlastic)
   end
   part("ShopHeader"..id,22,1,.3,x,y+11,-44,teal)
  end
  -- Warm fixtures at the rear of the shopfront scenes.
  for i,x in ipairs({-64,64}) do
   light(part("ShopLamp"..floor..i,4,.3,2,x,y+13,-37,warm,Enum.Material.Neon),28,.65)
  end
 end
 -- Gallery rails cap the existing glass panels on the two upper floors.
 for floor,y in ipairs({22,40}) do
  for i,x in ipairs({-21.8,21.8}) do part("GalleryRail"..floor..i,.4,.35,76,x,y,-0,metal,Enum.Material.Metal) end
  for i,z in ipairs({-37.8,37.8}) do part("GalleryCrossRail"..floor..i,44,.35,.4,0,y,z,metal,Enum.Material.Metal) end
 end
 for i,z in ipairs({-20,20}) do
  part("PendantRod"..i,.25,11.4,.25,0,65.6,z,metal,Enum.Material.Metal)
  light(part("Pendant"..i,8,.8,8,0,59.5,z,warm,Enum.Material.Neon),35,.8)
 end
 for i,x in ipairs({-24,24}) do
  light(part("CanopyLamp"..i,3,.25,2,x,15.85,-56,warm,Enum.Material.Neon),22,.7)
 end
 for i,x in ipairs({-44,44}) do
  part("DeliveryBracket"..i,2,.4,1,x,15,48.4,metal,Enum.Material.Metal)
  light(part("DeliveryLamp"..i,1.5,.5,.7,x,14.7,48.5,warm,Enum.Material.Neon),14,.5)
 end
 -- Two benches face the forecourt; backrests are nearest the building.
 for i,x in ipairs({-48,48}) do
  for j=0,2 do part("BenchSlat"..i..j,11,.4,.7,x,2.2,-75+j*.8,wood,Enum.Material.Wood) end
  part("BenchBack"..i,11,2,.4,x,3.5,-72.9,wood,Enum.Material.Wood)
  for j,dx in ipairs({-4,4}) do part("BenchLeg"..i..j,.6,2,2.6,x+dx,1,-74.2,metal,Enum.Material.Metal) end
 end
 for i,x in ipairs({-92,92}) do
  part("LampBase"..i,2,1,2,x,.5,-68,stone)
  part("LampPost"..i,.6,9,.6,x,5.5,-68,metal,Enum.Material.Metal)
  light(part("ForecourtLamp"..i,1,1.6,1,x,10,-68,warm,Enum.Material.Neon),20,.6)
 end
 for i,x in ipairs({-68,68}) do
  part("Soil"..i,30,.4,8,x,1.3,-68,Color3.fromRGB(76,66,46),Enum.Material.Ground)
  for j=-1,1 do part("Shrub"..i..j,4,2.4,4,x+j*10,2.6,-68,Color3.fromRGB(81,124,67),Enum.Material.Grass) end
  part("PalmTrunk"..i,1.2,17,1.2,x,10,-68,wood,Enum.Material.Wood)
  for j=0,7 do
   local a=j*math.pi/4
   part("PalmLeaf"..i..j,1.5,.3,6,x+math.sin(a)*2.5,18.6,-68+math.cos(a)*2.5,Color3.fromRGB(62,112,64),Enum.Material.Grass,a)
  end
 end
 -- Small interior planters stay outside the main portal and central walkway.
 for floor=0,2 do
  for i,x in ipairs({-27,27}) do
   part("InsidePlanter"..floor..i,4,2,4,x,floor*18+2,-30,stone)
   part("InsidePlant"..floor..i,3,4,3,x,floor*18+5,-30,Color3.fromRGB(69,117,66),Enum.Material.Grass)
  end
 end
 -- Simple louvres on the two rooftop units, safely separated from the housing face.
 for i,x in ipairs({-64,64}) do
  for j=0,4 do part("VentSlat"..i..j,20,.35,.2,x,55+j*1.3,11.85,metal,Enum.Material.Metal) end
 end
 model.Name="LargeCity_OceanGalleria_P5";model:SetAttribute("Phase",5)
 model:SetAttribute("QualityGateB","Approved");model:SetAttribute("DressingReview","Pending")
 model:SetAttribute("BuildRevision","OceanGalleria-P5-v1")
 return model
end
return Dressing
