-- Flat architectural preview. Gameplay integration remains a separate Gate C task.
local CollectionService = game:GetService("CollectionService")
local modules = script.Parent
local Plan = require(modules.LargeCityPlan)
local Assembly = {}
Assembly.ModelName = "LargeCity_AssembledPreview"
local YAW = {N=0,E=-90,S=180,W=90}

function Assembly.Placement(plot, groundY)
 assert(YAW[plot.front], "Unknown plot facing")
 return CFrame.new(plot.x,groundY or 0,-plot.z)*CFrame.Angles(0,math.rad(YAW[plot.front]),0)
end

local function part(parent,name,size,cf,color)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf
 p.Anchored=true;p.Color=color;p.Material=Enum.Material.SmoothPlastic
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent;return p
end
local function label(p,text)
 local gui=Instance.new("BillboardGui");gui.Name="PlanLabel";gui.Size=UDim2.fromOffset(260,50)
 gui.StudsOffset=Vector3.new(0,6,0);gui.AlwaysOnTop=false;gui.MaxDistance=650;gui.Parent=p
 local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=.25
 t.BackgroundColor3=Color3.fromRGB(24,38,44);t.TextColor3=Color3.fromRGB(255,255,255)
 t.TextSize=17;t.TextWrapped=true;t.Font=Enum.Font.GothamMedium;t.Text=text;t.Parent=gui
end
local function folder(parent,name)
 local f=Instance.new("Folder");f.Name=name;f.Parent=parent;return f
end
local function road(parent,name,x1,z1,x2,z2,width,y,color)
 assert(x1==x2 or z1==z2,"Plan roads must be axis aligned")
 return part(parent,name,Vector3.new(math.max(math.abs(x2-x1),width),1,math.max(math.abs(z2-z1),width)),
  CFrame.new((x1+x2)/2,y-.5,-(z1+z2)/2),color)
end
local function bounds(model)
 local lo,hi=Vector3.new(math.huge,math.huge,math.huge),Vector3.new(-math.huge,-math.huge,-math.huge)
 local count,lights=0,0
 for _,p in ipairs(model:GetDescendants()) do
  if p:IsA("BasePart") and p~=model.PrimaryPart and p.Transparency<1 then
   local h=p.Size*.5;local c=p.CFrame
   local extent=Vector3.new(
    math.abs(c.XVector.X)*h.X+math.abs(c.YVector.X)*h.Y+math.abs(c.ZVector.X)*h.Z,
    math.abs(c.XVector.Y)*h.X+math.abs(c.YVector.Y)*h.Y+math.abs(c.ZVector.Y)*h.Z,
    math.abs(c.XVector.Z)*h.X+math.abs(c.YVector.Z)*h.Y+math.abs(c.ZVector.Z)*h.Z)
   local a,b=p.Position-extent,p.Position+extent
   lo=Vector3.new(math.min(lo.X,a.X),math.min(lo.Y,a.Y),math.min(lo.Z,a.Z))
   hi=Vector3.new(math.max(hi.X,b.X),math.max(hi.Y,b.Y),math.max(hi.Z,b.Z));count=count+1
  elseif p:IsA("Light") then lights=lights+1 end
 end
 return lo,hi,count,lights
end
Assembly.Bounds=bounds
local function template(info,holder)
 local installer=modules:FindFirstChild(info.prefix.."Installer")
 local model
 if installer then
  model=require(installer).Install(holder,{GroundCFrame=CFrame.new(),EnablePong=false})
 else
  assert(info.prefix=="LargeCityPowerUtility","Missing installer: "..info.prefix)
  model=require(modules.LargeCityPowerUtilityGoldenMaster).Build(holder)
  require(modules.LargeCityPowerUtilityDressing).Apply(model)
  model:SetAttribute("StandaloneInstallerMissing",true)
 end
 -- Layout preview must not enlist in the main game's damage/reward system.
 for _,obj in ipairs(model:GetDescendants()) do CollectionService:RemoveTag(obj,"KaijuHouse") end
 CollectionService:RemoveTag(model,"KaijuHouse")
 model:SetAttribute("CityLayoutPreview",true);model:SetAttribute("QualityGateC","Pending")
 model:SetAttribute("SourceBranch",info.branch);model:SetAttribute("SourceCommit",info.commit)
 return model
end

function Assembly.Build(parent, options)
 options=options or {}
 assert(not parent:FindFirstChild(Assembly.ModelName),"City preview already exists; use a fresh Play session")
 local y=options.GroundY or 0
 local city=Instance.new("Model");city.Name=Assembly.ModelName
 local staging=Instance.new("Folder");staging.Name="CityBuildStaging"
 local ok,err=xpcall(function()
  local buildings=folder(city,"Buildings");local roads=folder(city,"Roads")
  local markers=folder(city,"PlanMarkers");local cache={}
  local ground=folder(city,"Ground")
  for i,q in ipairs(Plan.ground_surfaces) do
   part(ground,"Ground"..i,Vector3.new(q[3]-q[1],1,q[4]-q[2]),CFrame.new((q[1]+q[3])/2,y-.6,-(q[2]+q[4])/2),Color3.fromRGB(185,190,169))
  end
  for i,q in ipairs(Plan.road_surfaces) do
   part(roads,"Road"..i,Vector3.new(q[3]-q[1],1,q[4]-q[2]),CFrame.new((q[1]+q[3])/2,y-.5,-(q[2]+q[4])/2),Color3.fromRGB(72,79,79))
  end
  local placed=0
  for _,plot in ipairs(Plan.plots) do
   if plot.model~="-" then
    local info=Plan.models[plot.model]
    if plot.model:sub(1,1)=="B" then
     part(ground,plot.place_id.."_Apron",Vector3.new(plot.world_width,1,plot.world_depth),CFrame.new(plot.x,y-.55,-plot.z),Color3.fromRGB(197,195,178))
    end
    if not cache[plot.model] then cache[plot.model]=template(info,folder(staging,plot.model)) end
    local source=cache[plot.model];local m=source:Clone()
    -- Preserve the old installers' ground correction, while moving all geometry/dressing together.
    m:PivotTo(Assembly.Placement(plot,y)*source:GetPivot())
    m.Name=plot.place_id.."_"..info.prefix
    m:SetAttribute("LayoutId",plot.place_id);m:SetAttribute("PlotName",plot.name)
    m:SetAttribute("MasterId",plot.model);m:SetAttribute("MasterPlot",info.master_plot)
    m:SetAttribute("IsMasterPlot",plot.id==info.master_plot);m:SetAttribute("PlanFront",plot.front)
    m:SetAttribute("PlanX",plot.x);m:SetAttribute("PlanZ",plot.z)
    m.Parent=buildings;placed=placed+1
    local lo,hi,count,lights=bounds(m)
    m:SetAttribute("PreviewVisibleParts",count);m:SetAttribute("PreviewLights",lights)
    m:SetAttribute("ActualBoundsMin",lo);m:SetAttribute("ActualBoundsMax",hi)
    local overflow=lo.X<plot.x-plot.world_width/2-.1 or hi.X>plot.x+plot.world_width/2+.1
      or lo.Z< -plot.z-plot.world_depth/2-.1 or hi.Z> -plot.z+plot.world_depth/2+.1
    m:SetAttribute("PlotEnvelopeExceeded",overflow)
    if overflow then warn("[LargeCity] Check plot envelope: "..plot.place_id.." "..info.name) end
   else
    part(markers,plot.place_id.."_GreenReserve",Vector3.new(plot.world_width,1,plot.world_depth),
     CFrame.new(plot.x,y-.5,-plot.z),Color3.fromRGB(106,142,95))
   end
   local a,b=plot.access[1],plot.access[2]
   road(roads,plot.place_id.."_Access",a[1],a[2],b[1],b[2],16,y-.05,Color3.fromRGB(158,159,145))
   local p=part(markers,plot.place_id,Vector3.new(1,1,1),CFrame.new(b[1],y+1,-b[2]),Color3.fromRGB(237,207,120))
   p.CanCollide=false;label(p,plot.place_id.." · "..plot.name)
   if options.YieldBetweenPlots then task.wait() end
  end
  assert(placed==54,"Expected all 54 planned buildings")
  for _,entry in ipairs({{"NORD · CITY",-1430},{"SÜD · MEGA CITY",1430}}) do
   local p=part(markers,entry[1],Vector3.new(8,2,8),CFrame.new(0,y+1,entry[2]),Color3.fromRGB(57,173,179));label(p,entry[1])
  end
  local spawn=Instance.new("SpawnLocation");spawn.Name="CityReviewSpawn";spawn.Size=Vector3.new(20,1,20)
  spawn.CFrame=CFrame.new(0,y+1,0);spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0
  spawn.Color=Color3.fromRGB(220,213,190);spawn.Parent=city
  city:SetAttribute("BuildingCount",placed);city:SetAttribute("MasterCount",21)
  city:SetAttribute("CityToNorth",true);city:SetAttribute("MegaCityToSouth",true)
  city:SetAttribute("FlatPreviewGroundY",y);city:SetAttribute("GameplayIntegration","Pending")
 end,debug.traceback)
 staging:Destroy()
 if not ok then city:Destroy();error("Large City assembly failed: "..tostring(err)) end
 city.Parent=parent
 return city
end
return Assembly
