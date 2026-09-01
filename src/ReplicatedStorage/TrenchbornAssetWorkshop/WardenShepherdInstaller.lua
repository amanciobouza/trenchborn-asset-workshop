local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = script.Parent
local builder = require(packageFolder:WaitForChild("WardenShepherdGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("WardenShepherdDressing"))
local defaultGameplayConfig = require(packageFolder:WaitForChild("WardenShepherdGameplayConfig"))
local gameplay = require(packageFolder:WaitForChild("WardenShepherdGameplay"))
local fleetRig = require(packageFolder:WaitForChild("GuardianFleetRig"))
local sounds = require(packageFolder:WaitForChild("WardenShepherdSoundController"))
local runtimeController = require(packageFolder:WaitForChild("WardenShepherdRuntimeController"))

local Installer = {}

local function groundOffset(model)
	local pivot = model:GetPivot()
	local boundsCFrame, boundsSize = model:GetBoundingBox()
	return pivot.Position.Y - (boundsCFrame.Position.Y - boundsSize.Y * 0.5)
end

function Installer.Install(parent, options)
	assert(typeof(parent) == "Instance", "WardenShepherdInstaller.Install requires a parent Instance")
	options = options or {}

	local model = builder.Build(parent)
	dressing.Apply(model)
	local offset = groundOffset(model)
	model:PivotTo((options.GroundCFrame or CFrame.new()) * CFrame.new(0, offset, 0))

	fleetRig.Apply(model, {AnchorRoot = options.AnchorRoot ~= false})
	local gameplayApi = gameplay.Attach(model, options.GameplayConfig or defaultGameplayConfig)
	local soundApi = sounds.Attach(model)
	local runtimeApi = runtimeController.Attach(model, gameplayApi)

	model:SetAttribute("PipelinePhase", 7)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("QualityGateC", "Approved")
	model:SetAttribute("FinalInstallerVersion", 2)
	model:SetAttribute("WorkshopOnly", false)
	model:SetAttribute("GroundPlacementOffset", offset)
	model:SetAttribute("AnimationPass", "Approved")
	model:SetAttribute("SoundPass", "Approved")
	model:SetAttribute("CombatVFXPass", "Approved")
	model:SetAttribute("LegacyPartTweenReactions", false)

	local api = {
		Gameplay = gameplayApi,
		Runtime = runtimeApi,
		SoundRequested = soundApi,
		RequestAbility = gameplayApi:WaitForChild("RequestAbility"),
		ApplyDamage = gameplayApi:WaitForChild("ApplyDamage"),
		Reset = gameplayApi:WaitForChild("ResetGuardian"),
		AnimationRequested = runtimeApi.AnimationRequested,
	}
	return model, api
end

function Installer.Uninstall(parent)
	assert(typeof(parent) == "Instance", "WardenShepherdInstaller.Uninstall requires a parent Instance")
	local existing = parent:FindFirstChild("Warden_I_Shepherd_GoldenMaster")
	if not existing then return false end
	local remoteName = existing:GetAttribute("WardenRuntimeRemoteName")
	if remoteName then
		local remote = ReplicatedStorage:FindFirstChild(remoteName)
		if remote then remote:Destroy() end
		for _, player in ipairs(Players:GetPlayers()) do
			local gui = player:FindFirstChild("PlayerGui")
			local client = gui and gui:FindFirstChild(remoteName)
			if client then client:Destroy() end
		end
	end
	existing:Destroy()
	return true
end

return Installer
