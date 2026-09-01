local packageFolder = script.Parent

local builder = require(packageFolder:WaitForChild("MarshalRoadblockGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("MarshalRoadblockDressing"))
local defaultGameplayConfig = require(packageFolder:WaitForChild("MarshalRoadblockGameplayConfig"))
local gameplay = require(packageFolder:WaitForChild("MarshalRoadblockGameplay"))
local fleetRig = require(packageFolder:WaitForChild("GuardianFleetRig"))
local sounds = require(packageFolder:WaitForChild("GuardianSoundController"))
local runtimeController = require(packageFolder:WaitForChild("GuardianRuntimeController"))

local Installer = {}

local function groundOffset(model)
	local pivot = model:GetPivot()
	local boundsCFrame, boundsSize = model:GetBoundingBox()
	local bottomY = boundsCFrame.Position.Y - boundsSize.Y * 0.5
	return pivot.Position.Y - bottomY
end

function Installer.Install(parent, options)
	assert(typeof(parent) == "Instance", "MarshalRoadblockInstaller.Install requires a parent Instance")
	options = options or {}

	local model = builder.Build(parent)
	dressing.Apply(model)

	local offset = groundOffset(model)
	local groundCFrame = options.GroundCFrame or CFrame.new()
	model:PivotTo(groundCFrame * CFrame.new(0, offset, 0))

	fleetRig.Apply(model, {AnchorRoot = options.AnchorRoot ~= false})
	local gameplayConfig = options.GameplayConfig or defaultGameplayConfig
	local gameplayApi = gameplay.Attach(model, gameplayConfig)
	local soundApi = sounds.Attach(model)
	local runtimeApi = runtimeController.Attach(model, gameplayApi)

	model:SetAttribute("PipelinePhase", 7)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("QualityGateC", "Approved")
	model:SetAttribute("FinalInstallerVersion", 1)
	model:SetAttribute("WorkshopOnly", false)
	model:SetAttribute("GroundPlacementOffset", offset)
	model:SetAttribute("SoundPass", "Approved")
	model:SetAttribute("AnimationPass", "Approved")
	model:SetAttribute("CombatVFXPass", "Approved")

	local api = {
		Gameplay = gameplayApi,
		Runtime = runtimeApi,
		SoundRequested = soundApi,
		RequestAbility = gameplayApi:WaitForChild("RequestAbility"),
		ApplyDamage = gameplayApi:WaitForChild("ApplyDamage"),
		Reset = gameplayApi:WaitForChild("Reset"),
		AnimationRequested = runtimeApi.AnimationRequested,
	}

	return model, api
end

function Installer.Uninstall(parent)
	assert(typeof(parent) == "Instance", "MarshalRoadblockInstaller.Uninstall requires a parent Instance")
	local existing = parent:FindFirstChild("Marshal_II_Roadblock_GoldenMaster")
	if not existing then return false end

	local runtime = existing:FindFirstChild("GuardianRuntime")
	local remoteName
	if runtime then
		local animationRequested = runtime:FindFirstChild("AnimationRequested")
		if animationRequested then
			local runtimeApi = nil
			-- Runtime cleanup is normally performed through api.Runtime.Destroy().
			-- Model destruction remains a safe fallback for callers that did not retain the API.
		end
	end
	existing:Destroy()
	return true
end

return Installer
