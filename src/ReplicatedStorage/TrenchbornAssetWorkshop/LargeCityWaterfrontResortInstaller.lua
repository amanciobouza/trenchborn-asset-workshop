local CollectionService = game:GetService("CollectionService")

local packageFolder = script.Parent

local specification = require(packageFolder:WaitForChild("LargeCityWaterfrontResortSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityWaterfrontResortGoldenMaster"))
local poolFacade = require(packageFolder:WaitForChild("LargeCityWaterfrontResortPoolFacade"))
local dressing = require(packageFolder:WaitForChild("LargeCityWaterfrontResortDressing"))
local signDressing = require(packageFolder:WaitForChild("LargeCityWaterfrontResortSignDressing"))
local dressingRefinement = require(packageFolder:WaitForChild("LargeCityWaterfrontResortDressingRefinement"))

local Installer = {}

local MODEL_NAME = specification.Installer.ModelName
local GOLDEN_MASTER_NAME = "LargeCity_LuxuryWaterfrontResort_L3_GoldenMaster"
local PACKAGE_VERSION = specification.Installer.IntegrationPackageVersion
local MAX_HEALTH = specification.Installer.MaxHealth
local ENERGY_TYPE = specification.Installer.EnergyType
local HOUSE_TAG = specification.Installer.RequiredTag

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
	assert(groups and groups:IsA("Folder"), "Waterfront Resort installer requires a DestructionGroups folder")
	for _, groupName in ipairs(specification.DestructionGroups) do
		local group = groups:FindFirstChild(groupName)
		assert(group and group:IsA("Folder"), "Waterfront Resort is missing destruction group: " .. groupName)
	end
	return groups
end

local function lowestVisibleY(model)
	local minimumY = math.huge
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			local halfSize = item.Size * 0.5
			local verticalExtent =
				math.abs(item.CFrame.XVector.Y) * halfSize.X
				+ math.abs(item.CFrame.YVector.Y) * halfSize.Y
				+ math.abs(item.CFrame.ZVector.Y) * halfSize.Z
			minimumY = math.min(minimumY, item.Position.Y - verticalExtent)
		end
	end
	return minimumY
end

local function placeModel(model, options)
	if options.CFrame then
		assert(typeof(options.CFrame) == "CFrame", "Waterfront Resort options.CFrame must be a CFrame")
		model:PivotTo(options.CFrame)
		return
	end

	local groundCFrame = options.GroundCFrame or CFrame.new()
	assert(typeof(groundCFrame) == "CFrame", "Waterfront Resort options.GroundCFrame must be a CFrame")
	model:PivotTo(groundCFrame)

	if options.AlignToGround == false then
		return
	end

	local minimumY = lowestVisibleY(model)
	if minimumY < math.huge then
		local correction = groundCFrame.Position.Y - minimumY
		model:PivotTo(model:GetPivot() + Vector3.new(0, correction, 0))
		model:SetAttribute("GroundContactCorrection", correction)
		model:SetAttribute("GroundContactY", groundCFrame.Position.Y)
	end
end

local function applyIntegrationMetadata(model)
	model.Name = MODEL_NAME
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("City", specification.City)
	model:SetAttribute("BuildingType", specification.Installer.BuildingType)
	model:SetAttribute("CityTier", specification.Installer.CityTier)
	model:SetAttribute("MaxHealth", MAX_HEALTH)
	model:SetAttribute("EnergyType", ENERGY_TYPE)
	model:SetAttribute("AssetPhase", 6)
	model:SetAttribute("PipelinePhase", 6)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("QualityGateC", "Pending")
	model:SetAttribute("Phase6Status", "ExternalGameTestPending")
	model:SetAttribute("PackageId", "LargeCityWaterfrontResortPackage")
	model:SetAttribute("IntegrationPackageVersion", PACKAGE_VERSION)
	model:SetAttribute("IntegrationPackageReady", true)
	model:SetAttribute("InstallerReady", true)
	model:SetAttribute("FinalInstallerReady", false)
	model:SetAttribute("WorkshopOnly", false)
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("DestructionGroupCount", #specification.DestructionGroups)
	model:SetAttribute("ExternalCollapseIntegration", true)
	model:SetAttribute("UsesSharedMainGameDestruction", true)

	if not CollectionService:HasTag(model, HOUSE_TAG) then
		CollectionService:AddTag(model, HOUSE_TAG)
	end
end

function Installer.Validate(model)
	assert(model and model:IsA("Model"), "LargeCityWaterfrontResortInstaller.Validate requires a Model")
	validateDestructionGroups(model)
	assert(model:GetAttribute("MaxHealth") == MAX_HEALTH, "Waterfront Resort MaxHealth metadata is invalid")
	assert(model:GetAttribute("EnergyType") == ENERGY_TYPE, "Waterfront Resort EnergyType metadata is invalid")
	assert(CollectionService:HasTag(model, HOUSE_TAG), "Waterfront Resort is missing tag: " .. HOUSE_TAG)
	return true
end

function Installer.Install(parent, options)
	assert(typeof(parent) == "Instance", "LargeCityWaterfrontResortInstaller.Install requires a parent Instance")
	options = options or {}
	assert(typeof(options) == "table", "LargeCityWaterfrontResortInstaller.Install options must be a table")

	local existing = parent:FindFirstChild(MODEL_NAME)
	if existing then
		existing:Destroy()
	end
	local oldGoldenMaster = parent:FindFirstChild(GOLDEN_MASTER_NAME)
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
	applyIntegrationMetadata(model)
	placeModel(model, options)
	Installer.Validate(model)

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
Installer.PackageVersion = PACKAGE_VERSION
Installer.MaxHealth = MAX_HEALTH
Installer.EnergyType = ENERGY_TYPE
Installer.RequiredTag = HOUSE_TAG
Installer.QualityGateC = "Pending"

return Installer
