-- Phase 6 adapter to the existing KaijuHouse / shared-main-game contract.
-- No independent health loop, reward payout, damage remote or collapse system.
local CollectionService = game:GetService("CollectionService")
local Installer = {}
Installer.ModelName = "LargeCity_EmberlineResponseHQ_L3"
Installer.MaxHealth = 32000
Installer.EnergyType = "Thermal"
Installer.RequiredTag = "KaijuHouse"
Installer.PackageVersion = 1
Installer.QualityGateC = "Pending"

local GROUPS = {
 "D1_VehicleBayDoors", "D2_VehicleHall", "D3_Administration",
 "D4_TrainingTower", "D5_Forecourt", "D6_ServiceAndLandscape",
}

local function classify(source, name)
 if source:match("^BayDoor_%d+$") then return GROUPS[1] end
 if source == "VehicleHall" or source == "Signage" then return GROUPS[2] end
 if source == "Administration" then return GROUPS[3] end
 if source == "TrainingTower" or source:match("^TowerLevel_%d+$") then return GROUPS[4] end
 if source == "Site" or source == "Bollards" then return GROUPS[5] end
 if source == "Service" or source == "Planters" then return GROUPS[6] end
 if source == "RoofEquipment" then
  local unit = tonumber(name:match("^HVAC(%d+)_"))
  if unit then return unit <= 2 and GROUPS[2] or GROUPS[3] end
  if name:match("^AdminAntenna%d+$") then return GROUPS[3] end
 elseif source == "FacadeDetails" then
  if name == "HallSideBand" then return GROUPS[2] end
  if name == "AdminRearBand" then return GROUPS[3] end
 elseif source == "Emblems" then
  if name == "HallPlaque" then return GROUPS[2] end
  if name == "AdminPlaque" then return GROUPS[3] end
  if name == "TowerPlaque" then return GROUPS[4] end
 elseif source == "Lighting" then
  local wall = tonumber(name:match("^WallLight(%d+)_"))
  if wall then
   if wall <= 4 then return GROUPS[2] end
   if wall <= 6 then return GROUPS[3] end
   return GROUPS[4]
  end
  local beacon = tonumber(name:match("^Beacon(%d+)_"))
  if beacon then return beacon <= 2 and GROUPS[4] or GROUPS[2] end
 end
 return nil
end

local function validateGroups(model)
 local root = model:FindFirstChild("DestructionGroups")
 assert(root and root:IsA("Folder"), "Emberline: DestructionGroups missing")
 local valid = {}
 for _,name in ipairs(GROUPS) do
  local group = root:FindFirstChild(name)
  assert(group and group:IsA("Folder"), "Emberline: missing group " .. name)
  assert(#group:GetChildren() > 0, "Emberline: empty group " .. name)
  valid[group] = true
 end
 for _,obj in ipairs(model:GetDescendants()) do
  if obj:IsA("BasePart") and obj ~= model.PrimaryPart then
   assert(valid[obj.Parent], "Emberline: unassigned part " .. obj:GetFullName())
  elseif obj:IsA("Light") or obj:IsA("SurfaceGui") then
   local owner = obj:FindFirstAncestorWhichIsA("BasePart")
   assert(owner and valid[owner.Parent], "Emberline: unowned light/sign " .. obj:GetFullName())
  end
 end
 assert(model.PrimaryPart and model.PrimaryPart.Name == "GroundPivot", "Emberline: ground pivot missing")
 return root
end

function Installer.Validate(model)
 assert(model and model:IsA("Model"), "Emberline.Validate requires a Model")
 validateGroups(model)
 assert(model:GetAttribute("MaxHealth") == Installer.MaxHealth, "Emberline: MaxHealth must be 32000")
 assert(model:GetAttribute("EnergyType") == Installer.EnergyType, "Emberline: EnergyType must be Thermal")
 assert(CollectionService:HasTag(model, Installer.RequiredTag), "Emberline: KaijuHouse tag missing")
 return true
end

function Installer.Attach(model)
 assert(model and model:IsA("Model"), "Emberline.Attach requires a Model")
 if model:GetAttribute("EmberlineIntegrationVersion") == Installer.PackageVersion then
  Installer.Validate(model)
  return model -- Never reset live health or reapply dressing to integrated geometry.
 end
 assert(not model:FindFirstChild("DestructionGroups"), "Emberline: unexpected existing destruction layout")
 assert(model.PrimaryPart and model.PrimaryPart.Name == "GroundPivot", "Emberline: requires original ground pivot")
 assert(model:FindFirstChild("EmberlineDressing"), "Emberline: apply P5 dressing before integration")

 -- Resolve every part before changing any hierarchy; unknown additions fail explicitly.
 local assignments, sources, counts, names = {}, {}, {}, {}
 for _,obj in ipairs(model:GetDescendants()) do
  if obj:IsA("BasePart") and obj ~= model.PrimaryPart then
   local source = obj.Parent
   local group = classify(source.Name, obj.Name)
   assert(group, "Emberline: no destruction owner for " .. source.Name .. "/" .. obj.Name)
   local newName = source.Name .. "__" .. obj.Name
   local key = group .. "/" .. newName
   assert(not names[key], "Emberline: duplicate part " .. key)
   names[key] = true; sources[source] = true
   counts[group] = (counts[group] or 0) + 1
   table.insert(assignments, {part=obj, group=group, name=newName})
  end
 end
 for _,name in ipairs(GROUPS) do assert(counts[name], "Emberline: empty planned group " .. name) end
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
 local emptyDressing = model:FindFirstChild("EmberlineDressing")
 if emptyDressing and #emptyDressing:GetChildren() == 0 then emptyDressing:Destroy() end
 model.Name = Installer.ModelName
 local attributes = {
  AssetId=Installer.ModelName, DisplayName="Emberline Response HQ", LayoutId="LC-45",
  City="LargeCity", CityTier=4, BuildingType="Fire Station HQ",
  MaxHealth=Installer.MaxHealth, EnergyType=Installer.EnergyType,
  Phase=6, AssetPhase=6, PipelinePhase=6,
  QualityGateA="Approved", QualityGateB="Approved", DressingStatus="Approved",
  DressingReview="ApprovedByUser", QualityGateC="Pending",
  Phase6Status="ExternalGameTestPending", BuildRevision="Emberline-P6-v1",
  IntegrationPackageVersion=1, EmberlineIntegrationVersion=1,
  PackageId="LargeCityEmberlinePackage", IntegrationPackageReady=true,
  InstallerReady=true, FinalInstallerReady=false, WorkshopOnly=false, HasInterior=false,
  DestructionGroupCount=#GROUPS, ExternalCollapseIntegration=true, UsesSharedMainGameDestruction=true,
 }
 for name,value in pairs(attributes) do model:SetAttribute(name,value) end
 local status = model:FindFirstChild("ReviewStatus")
 if status then
  local values = {Phase="6", GateB="User approved", DressingReview="User approved", Revision="Emberline-P6-v1"}
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
 assert(typeof(parent) == "Instance", "Emberline.Install requires a parent Instance")
 options = options or {}
 local target = options.GroundCFrame or CFrame.new()
 assert(typeof(target) == "CFrame", "Emberline GroundCFrame must be a CFrame")
 assert(not parent:FindFirstChild(Installer.ModelName), "Emberline already exists; remove it explicitly before installing again")
 local builder = require(script.Parent.LargeCityEmberlineGoldenMaster)
 local dressing = require(script.Parent.LargeCityEmberlineDressing)
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
  assert(#copy:GetDescendants() == before-removed, "Emberline: cleanup count mismatch " .. name)
  for _,obj in ipairs(owners) do
   assert(not obj:IsDescendantOf(copy), "Emberline: leftover object " .. name)
  end
  copy:Destroy(); passed = passed + 1
 end
 assert(#model:GetDescendants() == originalCount, "Emberline: cleanup test changed original")
 print("[Emberline] " .. passed .. "/6 group cleanup checks passed on detached copies. External gameplay test still required.")
 return true
end

return Installer
