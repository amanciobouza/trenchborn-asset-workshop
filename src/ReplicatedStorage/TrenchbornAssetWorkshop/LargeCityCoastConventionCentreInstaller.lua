-- Phase 6 adapter to the existing KaijuHouse / shared-main-game contract.
-- No independent health loop, reward payout, damage remote or collapse system.
local CollectionService = game:GetService("CollectionService")
local Installer = {}
Installer.ModelName = "LargeCity_CoastConventionCentre_L3"
Installer.MaxHealth = 64000
Installer.EnergyType = "Electric"
Installer.RequiredTag = "KaijuHouse"
Installer.PackageVersion = 1
Installer.QualityGateC = "Pending"

local GROUPS = { "D1_Foyer", "D2_MainHall", "D3_SecondHall" }

local FOYER_SOURCES={Foyer=true,Gallery=true,Link=true,Entrance=true,Site=true}
local FOYER_DRESSING={"CanopyLamp","FoyerLamp","GalleryUnderLamp","RearGalleryRail","SideGalleryRail","BenchSeat","BenchBack","BenchLeg","LampBase","LampPost","ForecourtLamp","Soil","Shrub","PalmTrunk","PalmLeaf","FoyerPlanter","FoyerPlant"}
local function classify(part)
 local source,name=part.Parent.Name,part.Name
 if FOYER_SOURCES[source] then return GROUPS[1] end
 if source=="HallA" then return GROUPS[2] end
 if source=="HallB" then return GROUPS[3] end
 if source=="RoofFrames" or source=="RoofSegments" or source=="Delivery" then
  if string.sub(name,1,5)=="HallA" then return GROUPS[2] end
  if string.sub(name,1,5)=="HallB" then return GROUPS[3] end
  if source=="Delivery" and (name=="Yard" or name=="YardConnection" or name=="SideDrive") then return GROUPS[1] end
 end
 if source=="ConventionDressing" then
  local hall=string.match(name,"^HallBracket([12])%d+$") or string.match(name,"^HallLamp([12])%d+$")
  if hall then return GROUPS[tonumber(hall)+1] end
  local gate=string.match(name,"^DeliveryBracket([123])$") or string.match(name,"^DeliveryLamp([123])$")
  if gate then return tonumber(gate)<=2 and GROUPS[2] or GROUPS[3] end
  for _,prefix in ipairs(FOYER_DRESSING) do
   if string.match(name,"^"..prefix.."%d*$") then return GROUPS[1] end
  end
 end
 return nil
end

local function validateGroups(model)
 local root = model:FindFirstChild("DestructionGroups")
 assert(root and root:IsA("Folder"), "CoastConventionCentre: DestructionGroups missing")
 assert(#root:GetChildren() == 3, "CoastConventionCentre: requires three building sections")
 local valid = {}
 for _,name in ipairs(GROUPS) do
  local group = root:FindFirstChild(name)
  assert(group and group:IsA("Folder"), "CoastConventionCentre: missing group " .. name)
  assert(#group:GetChildren() > 0, "CoastConventionCentre: empty group " .. name)
  valid[group] = true
 end
 for _,obj in ipairs(model:GetDescendants()) do
  if obj:IsA("BasePart") and obj ~= model.PrimaryPart then
   assert(valid[obj.Parent], "CoastConventionCentre: unassigned part " .. obj:GetFullName())
  elseif obj:IsA("Light") or obj:IsA("SurfaceGui") then
   local owner = obj:FindFirstAncestorWhichIsA("BasePart")
   assert(owner and valid[owner.Parent], "CoastConventionCentre: unowned light/sign " .. obj:GetFullName())
  end
 end
 assert(model.PrimaryPart and model.PrimaryPart.Name == "GroundPivot", "CoastConventionCentre: ground pivot missing")
 return root
end

function Installer.Validate(model)
 assert(model and model:IsA("Model"), "CoastConventionCentre.Validate requires a Model")
 validateGroups(model)
 assert(model:GetAttribute("MaxHealth") == Installer.MaxHealth, "CoastConventionCentre: MaxHealth must be 64000")
 assert(model:GetAttribute("EnergyType") == Installer.EnergyType, "CoastConventionCentre: EnergyType must be Electric")
 assert(CollectionService:HasTag(model, Installer.RequiredTag), "CoastConventionCentre: KaijuHouse tag missing")
 return true
end

function Installer.Attach(model)
 assert(model and model:IsA("Model"), "CoastConventionCentre.Attach requires a Model")
 if model:GetAttribute("CoastConventionCentreIntegrationVersion") == Installer.PackageVersion then
  Installer.Validate(model)
  return model -- Never reset live health or reapply dressing to integrated geometry.
 end
 assert(not model:FindFirstChild("DestructionGroups"), "CoastConventionCentre: unexpected existing destruction layout")
 assert(model.PrimaryPart and model.PrimaryPart.Name == "GroundPivot", "CoastConventionCentre: requires original ground pivot")
 assert(model:FindFirstChild("ConventionDressing"), "CoastConventionCentre: apply P5 dressing before integration")

 -- Resolve every part before changing any hierarchy; unknown additions fail explicitly.
 local assignments, sources, counts, names = {}, {}, {}, {}
 for _,obj in ipairs(model:GetDescendants()) do
  if obj:IsA("BasePart") and obj ~= model.PrimaryPart then
   local source = obj.Parent
   local group = classify(obj)
   assert(group, "CoastConventionCentre: no destruction owner for " .. source.Name .. "/" .. obj.Name)
   local newName = source.Name .. "__" .. obj.Name
   local key = group .. "/" .. newName
   assert(not names[key], "CoastConventionCentre: duplicate part " .. key)
   names[key] = true; sources[source] = true
   counts[group] = (counts[group] or 0) + 1
   table.insert(assignments, {part=obj, group=group, name=newName})
  end
 end
 for _,name in ipairs(GROUPS) do assert(counts[name], "CoastConventionCentre: empty planned group " .. name) end
 local root = Instance.new("Folder"); root.Name = "DestructionGroups"; root.Parent = model
 local folders = {}
 for _,name in ipairs(GROUPS) do
  local f = Instance.new("Folder"); f.Name = name; f.Parent = root; folders[name] = f
 end
 for _,a in ipairs(assignments) do
  -- Keep SurfaceGuis and Lights under their existing owning Part.
  a.part.Name = a.name; a.part.Parent = folders[a.group]
  a.part:SetAttribute("DestructionGroup", a.group)
 end
 for source in pairs(sources) do
  if #source:GetChildren() == 0 then source:Destroy() end
 end
 local emptyDressing = model:FindFirstChild("ConventionDressing")
 if emptyDressing and #emptyDressing:GetChildren() == 0 then emptyDressing:Destroy() end
 model.Name = Installer.ModelName
 local attributes = {
  AssetId=Installer.ModelName, DisplayName="Coast Convention Centre", LayoutId="LC-08",
  City="LargeCity", CityTier=4, BuildingType="Convention Centre", 
  MaxHealth=Installer.MaxHealth, EnergyType=Installer.EnergyType,
  Phase=6, AssetPhase=6, PipelinePhase=6,
  QualityGateA="Approved", QualityGateB="Approved", DressingStatus="Approved",
  DressingReview="ApprovedByUser", QualityGateC="Pending",
  Phase6Status="ExternalGameTestPending", BuildRevision="CoastConventionCentre-P6-v1",
  IntegrationPackageVersion=1, CoastConventionCentreIntegrationVersion=1,
  PackageId="LargeCityCoastConventionCentrePackage", IntegrationPackageReady=true,
  InstallerReady=true, FinalInstallerReady=false, WorkshopOnly=false, HasInterior=true,
  DestructionMode="ThreeSections", DestructionGroupCount=#GROUPS, ExternalCollapseIntegration=true, UsesSharedMainGameDestruction=true,
 }
 for name,value in pairs(attributes) do model:SetAttribute(name,value) end
 local status = model:FindFirstChild("ReviewStatus")
 if status then
  local values = {Phase="6", GateB="User approved", DressingReview="User approved", Revision="CoastConventionCentre-P6-v1"}
  for name,value in pairs(values) do
   local field = status:FindFirstChild(name)
   if field and field:IsA("StringValue") then field.Value = value end
  end
 end
 validateGroups(model)
 -- Tag only after all metadata and owners exist, so the shared engine sees a complete asset.
 CollectionService:AddTag(model, Installer.RequiredTag)
 Installer.Validate(model)
 return model
end

function Installer.Install(parent, options)
 assert(typeof(parent) == "Instance", "CoastConventionCentre.Install requires a parent Instance")
 options = options or {}
 local target = options.GroundCFrame or CFrame.new()
 assert(typeof(target) == "CFrame", "CoastConventionCentre GroundCFrame must be a CFrame")
 assert(not parent:FindFirstChild(Installer.ModelName), "CoastConventionCentre already exists; remove it explicitly before installing again")
 local builder = require(script.Parent.LargeCityCoastConventionCentreGoldenMaster)
 local dressing = require(script.Parent.LargeCityCoastConventionCentreDressing)
 local model = builder.Build(nil, {GroundCFrame=target})
 dressing.Apply(model)
 -- Geometry is complete before it enters the live parent; tag is applied last by Attach.
 model.Parent = parent
 return Installer.Attach(model)
end

-- Structural cleanup test only; this is NOT a test of the external combat/collapse engine.
function Installer.TestGroupCleanup(model)
 Installer.Validate(model)
 local originalCount = #model:GetDescendants()
 local passed = 0
 for _,name in ipairs(GROUPS) do
  local copy = model:Clone()
  CollectionService:RemoveTag(copy, Installer.RequiredTag)
  local target = copy.DestructionGroups:FindFirstChild(name)
  local before = #copy:GetDescendants()
  local removed = #target:GetDescendants() + 1
  local owners = target:GetDescendants()
  target:Destroy()
  assert(#copy:GetDescendants() == before-removed, "CoastConventionCentre: cleanup count mismatch " .. name)
  for _,obj in ipairs(owners) do
   assert(not obj:IsDescendantOf(copy), "CoastConventionCentre: leftover object " .. name)
  end
  copy:Destroy(); passed = passed + 1
 end
 assert(#model:GetDescendants() == originalCount, "CoastConventionCentre: cleanup test changed original")
 print("[CoastConventionCentre] " .. passed .. "/3 group cleanup checks passed on detached copies. External gameplay test still required.")
 return true
end

return Installer
