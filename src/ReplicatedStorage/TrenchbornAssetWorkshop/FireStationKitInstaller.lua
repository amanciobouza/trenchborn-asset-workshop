local Builder = require(script.Parent:WaitForChild("FireStationKitBuilder"))
local Specification = require(script.Parent:WaitForChild("FireStationKitSpecification"))

local Installer = {}

local MODEL_NAME = "TBK_FS_FireStationKit_v1"

local REQUIRED = {
	Core = {
		"TBK_FS_Core_Bay_A",
		"TBK_FS_Core_Office_A",
		"TBK_FS_Core_Stair_A",
		"TBK_FS_Core_TrainingTower_A",
	},
	Facades = {
		"TBK_FS_Facade_Garage_A",
		"TBK_FS_Facade_Window_A",
		"TBK_FS_Facade_Solid_A",
	},
	Entrances = {
		"TBK_FS_Entrance_Main_A",
	},
	Roof = {
		"TBK_FS_Roof_Flat_A",
		"TBK_FS_Roof_Parapet_A",
	},
	Examples = {
		"TBK_FS_Example_Small",
		"TBK_FS_Example_Standard",
		"TBK_FS_Example_Large",
	},
}

function Installer.Validate(kit)
	assert(kit and kit:IsA("Model"), "FireStationKitInstaller.Validate requires a Model")
	assert(kit.Name == MODEL_NAME, "Unexpected Fire Station Kit model name")
	assert(kit:GetAttribute("KitId") == Specification.KitId, "Fire Station KitId mismatch")
	assert(kit:GetAttribute("GridSize") == 16, "Fire Station Kit must use 16-stud grid")

	for categoryName, names in pairs(REQUIRED) do
		local category = kit:FindFirstChild(categoryName)
		assert(category, "Fire Station Kit missing category: " .. categoryName)
		for _, name in ipairs(names) do
			assert(category:FindFirstChild(name), "Fire Station Kit missing module: " .. name)
		end
	end

	for _, categoryName in ipairs({"Core", "Facades", "Entrances", "Roof", "Props", "Signage", "Exterior"}) do
		local category = kit:FindFirstChild(categoryName)
		for _, module in ipairs(category:GetChildren()) do
			assert(module:IsA("Model"), module.Name .. " must be a Model")
			assert(module.PrimaryPart and module.PrimaryPart.Name == "GroundPivot", module.Name .. " has invalid pivot")
			assert(module:GetAttribute("GridSize") == 16, module.Name .. " has invalid grid metadata")
		end
	end

	return true
end

function Installer.Install(parent)
	assert(typeof(parent) == "Instance", "FireStationKitInstaller.Install requires a parent Instance")
	local existing = parent:FindFirstChild(MODEL_NAME)
	if existing then
		existing:Destroy()
	end
	local kit = Builder.Build(parent)
	kit:SetAttribute("ImportReady", true)
	kit:SetAttribute("PackageId", "FireStationKit")
	kit:SetAttribute("PackageVersion", Specification.Version)
	kit:SetAttribute("Standalone", true)
	Installer.Validate(kit)
	return kit
end

function Installer.CloneModule(kit, categoryName, moduleName, parent, targetCFrame)
	return Builder.CloneModule(kit, categoryName, moduleName, parent, targetCFrame)
end

function Installer.Uninstall(parent)
	local existing = parent:FindFirstChild(MODEL_NAME)
	if not existing then
		return false
	end
	existing:Destroy()
	return true
end

Installer.ModelName = MODEL_NAME
Installer.KitId = Specification.KitId
Installer.Version = Specification.Version
Installer.GridSize = Specification.GridSize

return Installer
