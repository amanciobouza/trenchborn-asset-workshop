-- Phase 6 adapter to the existing KaijuHouse / shared-main-game contract.
-- No independent health loop, reward payout, damage remote or collapse system.
local CollectionService = game:GetService("CollectionService")
local Installer = {}
Installer.ModelName = "LargeCity_CityHotel_L3"
Installer.MaxHealth = 64000
Installer.EnergyType = "Electric"
Installer.RequiredTag = "KaijuHouse"
Installer.PackageVersion = 1
Installer.QualityGateC = "Pending"

local GROUPS = { "D1_WholeBuilding" }

local SOURCES = {
 Crown=true, Delivery=true, Entrance=true, HotelDressing=true, Podium01=true, Podium02=true, Rooms01=true, Rooms02=true, Rooms03=true, Rooms04=true, Rooms05=true, Rooms06=true, Rooms07=true, Rooms08=true, Rooms09=true, Rooms10=true, Site=true
}
local function classify(source)
 if SOURCES[source] then return GROUPS[1] end
 return nil
end

local function validateGroups(model)
 local root = model:FindFirstChild("DestructionGroups")
 assert(root and root:IsA("Folder"), "Hotel: DestructionGroups missing")
 assert(#root:GetChildren() == 1, "Hotel: requires one whole-building group")
 local valid = {}
 for _,name in ipairs(GROUPS) do
  local group = root:FindFirstChild(name)
  assert(group and group:IsA("Folder"), "Hotel: missing group " .. name)
  assert(#group:GetChildren() > 0, "Hotel: empty group " .. name)
  valid[group] = true
 end
 for _,obj in ipairs(model:GetDescendants()) do
  if obj:IsA("BasePart") and obj ~= model.PrimaryPart then
   assert(valid[obj.Parent], "Hotel: unassigned part " .. obj:GetFullName())
  elseif obj:IsA("Light") or obj:IsA("SurfaceGui") then
   local owner = obj:FindFirstAncestorWhichIsA("BasePart")
   assert(owner and valid[owner.Parent], "Hotel: unowned light/sign " .. obj:GetFullName())
  end
 end
 assert(model.PrimaryPart and model.PrimaryPart.Name == "GroundPivot", "Hotel: ground pivot missing")
 return root
end

function Installer.Validate(model)
 assert(model and model:IsA("Model"), "Hotel.Validate requires a Model")
 validateGroups(model)
 assert(model:GetAttribute("MaxHealth") == Installer.MaxHealth, "Hotel: MaxHealth must be 64000")
 assert(model:GetAttribute("EnergyType") == Installer.EnergyType, "Hotel: EnergyType must be Electric")
 assert(CollectionService:HasTag(model, Installer.RequiredTag), "Hotel: KaijuHouse tag missing")
 return true
end

function Installer.Attach(model)
 assert(model and model:IsA("Model"), "Hotel.Attach requires a Model")
 if model:GetAttribute("HotelIntegrationVersion") == Installer.PackageVersion then
  Installer.Validate(model)
  return model -- Never reset live health or reapply dressing to integrated geometry.
 end
 assert(not model:FindFirstChild("DestructionGroups"), "Hotel: unexpected existing destruction layout")
 assert(model.PrimaryPart and model.PrimaryPart.Name == "GroundPivot", "Hotel: requires original ground pivot")
 assert(model:FindFirstChild("HotelDressing"), "Hotel: apply P5 dressing before integration")

 -- Resolve every part before changing any hierarchy; unknown additions fail explicitly.
 local assignments, sources, counts, names = {}, {}, {}, {}
 for _,obj in ipairs(model:GetDescendants()) do
  if obj:IsA("BasePart") and obj ~= model.PrimaryPart then
   local source = obj.Parent
   local group = classify(source.Name)
   assert(group, "Hotel: no destruction owner for " .. source.Name .. "/" .. obj.Name)
   local newName = source.Name .. "__" .. obj.Name
   local key = group .. "/" .. newName
   assert(not names[key], "Hotel: duplicate part " .. key)
   names[key] = true; sources[source] = true
   counts[group] = (counts[group] or 0) + 1
   table.insert(assignments, {part=obj, group=group, name=newName})
  end
 end
 for _,name in ipairs(GROUPS) do assert(counts[name], "Hotel: empty planned group " .. name) end
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
 local emptyDressing = model:FindFirstChild("HotelDressing")
 if emptyDressing and #emptyDressing:GetChildren() == 0 then emptyDressing:Destroy() end
 model.Name = Installer.ModelName
 local attributes = {
  AssetId=Installer.ModelName, DisplayName="City Hotel", LayoutId="LC-16",
  City="LargeCity", CityTier=4, BuildingType="City Hotel", 
  MaxHealth=Installer.MaxHealth, EnergyType=Installer.EnergyType,
  Phase=6, AssetPhase=6, PipelinePhase=6,
  QualityGateA="Approved", QualityGateB="Approved", DressingStatus="Approved",
  DressingReview="ApprovedByUser", QualityGateC="Pending",
  Phase6Status="ExternalGameTestPending", BuildRevision="Hotel-P6-v1",
  IntegrationPackageVersion=1, HotelIntegrationVersion=1,
  PackageId="LargeCityHotelPackage", IntegrationPackageReady=true,
  InstallerReady=true, FinalInstallerReady=false, WorkshopOnly=false, HasInterior=true, InteriorType="SimplifiedPodium", EnterableInterior=false,
  DestructionMode="WholeBuilding", DestructionGroupCount=#GROUPS, ExternalCollapseIntegration=true, UsesSharedMainGameDestruction=true,
 }
 for name,value in pairs(attributes) do model:SetAttribute(name,value) end
 local status = model:FindFirstChild("ReviewStatus")
 if status then
  local values = {Phase="6", GateB="User approved", DressingReview="User approved", Revision="Hotel-P6-v1"}
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
 assert(typeof(parent) == "Instance", "Hotel.Install requires a parent Instance")
 options = options or {}
 local target = options.GroundCFrame or CFrame.new()
 assert(typeof(target) == "CFrame", "Hotel GroundCFrame must be a CFrame")
 assert(not parent:FindFirstChild(Installer.ModelName), "Hotel already exists; remove it explicitly before installing again")
 local builder = require(script.Parent.LargeCityHotelGoldenMaster)
 local dressing = require(script.Parent.LargeCityHotelDressing)
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
  assert(#copy:GetDescendants() == before-removed, "Hotel: cleanup count mismatch " .. name)
  for _,obj in ipairs(owners) do
   assert(not obj:IsDescendantOf(copy), "Hotel: leftover object " .. name)
  end
  copy:Destroy(); passed = passed + 1
 end
 assert(#model:GetDescendants() == originalCount, "Hotel: cleanup test changed original")
 print("[Hotel] " .. passed .. "/1 group cleanup checks passed on detached copies. External gameplay test still required.")
 return true
end

return Installer
