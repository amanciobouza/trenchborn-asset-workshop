local CollectionService = game:GetService("CollectionService")

local packageFolder = script.Parent

local specification = require(packageFolder:WaitForChild("LargeCityUptownResidencesSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityUptownResidencesGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("LargeCityUptownResidencesDressing"))

local Installer = {}

local MODEL_NAME = specification.AssetId
local GOLDEN_MASTER_NAME = "LargeCity_UptownResidences_L3_GoldenMaster"
local PACKAGE_VERSION = specification.ProposedGameplayMetadata.IntegrationPackageVersion
local MAX_HEALTH = specification.ProposedGameplayMetadata.TargetMaxHealth
local ENERGY_TYPE = specification.ProposedGameplayMetadata.EnergyType
local BUILDING_TAG = specification.ProposedGameplayMetadata.InstallerTag

local function validateDestructionGroups(model)
	local groups = model:FindFirstChild("DestructionGroups")
	assert(groups and groups:IsA("Folder"), "Large City Uptown Residences installer requires a DestructionGroups folder")

	for _, groupName in ipairs(specification.PlannedDestructionGroups) do
		local group = groups:FindFirstChild(groupName)
		assert(group and group:IsA("Folder"), "Large City Uptown Residences is missing destruction group: " .. groupName)
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
		assert(typeof(options.CFrame) == "CFrame", "Large City Uptown Residences options.CFrame must be a CFrame")
		model:PivotTo(options.CFrame)
		return
	end

	local groundCFrame = options.GroundCFrame or CFrame.new()
	assert(typeof(groundCFrame) == "CFrame", "Large City Uptown Residences options.GroundCFrame must be a CFrame")
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
	model:SetAttribute("BuildingType", specification.BuildingType)
	model:SetAttribute("CityTier", 4)
	model:SetAttribute("MaxHealth", MAX_HEALTH)
	model:SetAttribute("EnergyType", ENERGY_TYPE)
	model:SetAttribute("AssetPhase", 6)
	model:SetAttribute("PipelinePhase", 6)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("QualityGateC", "Pending")
	model:SetAttribute("Phase6Status", "ExternalGameTestPending")
	model:SetAttribute("DressingStatus", "Approved")
	model:SetAttribute("PackageId", "LargeCityUptownResidencesPackage")
	model:SetAttribute("IntegrationPackageVersion", PACKAGE_VERSION)
	model:SetAttribute("IntegrationPackageReady", true)
	model:SetAttribute("InstallerReady", true)
	model:SetAttribute("FinalInstallerReady", false)
	model:SetAttribute("WorkshopOnly", false)
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("DestructionGroupCount", #specification.PlannedDestructionGroups)
	model:SetAttribute("ExternalCollapseIntegration", true)
	model:SetAttribute("UsesSharedMainGameDestruction", true)

	if not CollectionService:HasTag(model, BUILDING_TAG) then
		CollectionService:AddTag(model, BUILDING_TAG)
	end
end

function Installer.Validate(model)
	assert(model and model:IsA("Model"), "LargeCityUptownResidencesInstaller.Validate requires a Model")
	validateDestructionGroups(model)
	assert(model:GetAttribute("MaxHealth") == MAX_HEALTH, "Large City Uptown Residences MaxHealth metadata is invalid")
	assert(model:GetAttribute("EnergyType") == ENERGY_TYPE, "Large City Uptown Residences EnergyType metadata is invalid")
	assert(CollectionService:HasTag(model, BUILDING_TAG), "Large City Uptown Residences is missing tag: " .. BUILDING_TAG)
	return true
end

function Installer.Install(parent, options)
	assert(typeof(parent) == "Instance", "LargeCityUptownResidencesInstaller.Install requires a parent Instance")
	options = options or {}
	assert(typeof(options) == "table", "LargeCityUptownResidencesInstaller.Install options must be a table")

	local existing = parent:FindFirstChild(MODEL_NAME)
	if existing then
		existing:Destroy()
	end

	local oldGoldenMaster = parent:FindFirstChild(GOLDEN_MASTER_NAME)
	if oldGoldenMaster then
		oldGoldenMaster:Destroy()
	end

	local model = goldenMaster.Build(parent)
	dressing.Apply(model)
	validateDestructionGroups(model)
	applyIntegrationMetadata(model)
	placeModel(model, options)
	Installer.Validate(model)

	return model
end

function Installer.Uninstall(parent)
	assert(typeof(parent) == "Instance", "LargeCityUptownResidencesInstaller.Uninstall requires a parent Instance")
	local model = parent:FindFirstChild(MODEL_NAME)
	if not model then
		return false
	end
	model:Destroy()
	return true
end

Installer.ModelName = MODEL_NAME
Installer.PackageVersion = PACKAGE_VERSION
Installer.MaxHealth = MAX_HEALTH
Installer.EnergyType = ENERGY_TYPE
Installer.RequiredTag = BUILDING_TAG
Installer.QualityGateC = "Pending"

return Installer
