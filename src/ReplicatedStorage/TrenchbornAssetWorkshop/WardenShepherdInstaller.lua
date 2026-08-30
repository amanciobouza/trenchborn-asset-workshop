local packageFolder = script.Parent

local builder = require(packageFolder:WaitForChild("WardenShepherdGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("WardenShepherdDressing"))
local defaultGameplayConfig = require(packageFolder:WaitForChild("WardenShepherdGameplayConfig"))
local gameplay = require(packageFolder:WaitForChild("WardenShepherdGameplay"))
local reactions = require(packageFolder:WaitForChild("WardenShepherdReactions"))

local Installer = {}

local ROOT_HEIGHT_ABOVE_GROUND = 21

function Installer.Install(parent, options)
	assert(typeof(parent) == "Instance", "WardenShepherdInstaller.Install requires a parent Instance")
	options = options or {}

	local model = builder.Build(parent)

	local groundCFrame = options.GroundCFrame or CFrame.new()
	model:PivotTo(groundCFrame * CFrame.new(0, ROOT_HEIGHT_ABOVE_GROUND, 0))

	dressing.Apply(model)
	local gameplayConfig = options.GameplayConfig or defaultGameplayConfig
	local gameplayApi = gameplay.Attach(model, gameplayConfig)

	if options.EnableVisualReactions ~= false then
		reactions.Attach(model)
	end

	model:SetAttribute("PipelinePhase", 7)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("QualityGateC", "Approved")
	model:SetAttribute("FinalInstallerVersion", 1)
	model:SetAttribute("WorkshopOnly", false)
	model:SetAttribute("GroundPlacementOffset", ROOT_HEIGHT_ABOVE_GROUND)

	return model, gameplayApi
end

function Installer.Uninstall(parent)
	assert(typeof(parent) == "Instance", "WardenShepherdInstaller.Uninstall requires a parent Instance")
	local existing = parent:FindFirstChild("Warden_I_Shepherd_GoldenMaster")
	if existing then
		existing:Destroy()
		return true
	end
	return false
end

return Installer
