local CollectionService = game:GetService("CollectionService")

local packageFolder = script.Parent

local specification = require(packageFolder:WaitForChild("LargeCityWaterfrontResortSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityWaterfrontResortGoldenMaster"))
local poolFacade = require(packageFolder:WaitForChild("LargeCityWaterfrontResortPoolFacade"))
local dressing = require(packageFolder:WaitForChild("LargeCityWaterfrontResortDressing"))
local signDressing = require(packageFolder:WaitForChild("LargeCityWaterfrontResortSignDressing"))
local dressingRefinement = require(packageFolder:WaitForChild("LargeCityWaterfrontResortDressingRefinement"))

local Installer = {}

local MODEL_NAME = "LargeCity_LuxuryWaterfrontResort_L3"
local MAX_HEALTH = 64000
local ENERGY_TYPE = "Heat"
local HOUSE_TAG = "KaijuHouse"

local function removeDuplicateFacade(model)
	local dressingFolder = model:FindFirstChild("Dressing")
	if not dressingFolder then return end
	local duplicateFacade = dressingFolder:FindFirstChild("Facade")
	if duplicateFacade then
		duplicateFacade:Destroy()
	end
end

local function validateDestructionGroups(model)
	local groups = model:FindFirstChild("DestructionGroups")
	assert(groups, "Waterfront Resort installer requires DestructionGroups")
	for _, groupName in ipairs(specification.DestructionGroups) do
		assert(groups:FindFirstChild(groupName), "Missing destruction group: " .. groupName)
	end
	return groups
end

local function applyProductionMetadata(model)
	model.Name = MODEL_NAME
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("City", specification.City)
	model:SetAttribute("BuildingType", "Hotel")
	model:SetAttribute("CityTier", 4)
	model:SetAttribute("MaxHealth", MAX_HEALTH)
	model:SetAttribute("EnergyType", ENERGY_TYPE)
	model:SetAttribute("PipelinePhase", 7)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("QualityGateC", "ExternalGameTestPending")
	model:SetAttribute("FinalInstallerVersion", 1)
	model:SetAttribute("WorkshopOnly", false)
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("DestructionGroupCount", #specification.DestructionGroups)
	model:SetAttribute("UsesSharedMainGameDestruction", true)
	model:SetAttribute("InstallerReady", true)

	if not CollectionService:HasTag(model, HOUSE_TAG) then
		CollectionService:AddTag(model, HOUSE_TAG)
	end
end

function Installer.Install(parent, options)
	assert(typeof(parent) == "Instance", "LargeCityWaterfrontResortInstaller.Install requires a parent Instance")
	options = options or {}

	local existing = parent:FindFirstChild(MODEL_NAME)
	if existing then
		existing:Destroy()
	end
	local oldGoldenMaster = parent:FindFirstChild("LargeCity_LuxuryWaterfrontResort_L3_GoldenMaster")
	if oldGoldenMaster then
		oldGoldenMaster:Destroy()
	end

	local model = goldenMaster.Build(parent)
	poolFacade.Apply(model)
	dressing.Apply(model)
	signDressing.Apply(model)
	dressingRefinement.Apply(model)
	removeDuplicateFacade(model)
	validateDestructionGroups(model)
	applyProductionMetadata(model)

	local targetCFrame = options.CFrame or options.GroundCFrame
	if targetCFrame then
		model:PivotTo(targetCFrame)
	end

	return model
end

function Installer.Uninstall(parent)
	assert(typeof(parent) == "Instance", "LargeCityWaterfrontResortInstaller.Uninstall requires a parent Instance")
	local model = parent:FindFirstChild(MODEL_NAME)
	if not model then return false end
	model:Destroy()
	return true
end

Installer.ModelName = MODEL_NAME
Installer.MaxHealth = MAX_HEALTH
Installer.EnergyType = ENERGY_TYPE
Installer.RequiredTag = HOUSE_TAG

return Installer
