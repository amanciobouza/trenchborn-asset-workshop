local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = script.Parent
local builder = require(packageFolder:WaitForChild("AegisInterceptorGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("AegisInterceptorDressing"))
local defaultGameplayConfig = require(packageFolder:WaitForChild("AegisInterceptorGameplayConfig"))
local gameplay = require(packageFolder:WaitForChild("AegisInterceptorGameplay"))
local fleetRig = require(packageFolder:WaitForChild("GuardianFleetRig"))
local reactions = require(packageFolder:WaitForChild("AegisInterceptorReactions"))
local sounds = require(packageFolder:WaitForChild("AegisInterceptorSoundController"))
local runtimeController = require(packageFolder:WaitForChild("AegisInterceptorRuntimeController"))

local Installer = {}

local function groundOffset(model)
	local pivot = model:GetPivot()
	local boundsCFrame, boundsSize = model:GetBoundingBox()
	return pivot.Position.Y - (boundsCFrame.Position.Y - boundsSize.Y * 0.5)
end

local function removeRemoteAndClients(name)
	if not name then return end
	local remote = ReplicatedStorage:FindFirstChild(name)
	if remote then remote:Destroy() end
	for _, player in ipairs(Players:GetPlayers()) do
		local gui = player:FindFirstChild("PlayerGui")
		local client = gui and gui:FindFirstChild(name)
		if client then client:Destroy() end
	end
end

function Installer.Install(parent, options)
	assert(typeof(parent) == "Instance", "AegisInterceptorInstaller.Install requires a parent Instance")
	options = options or {}

	local model = builder.Build(parent)
	dressing.Apply(model)
	local offset = groundOffset(model)
	model:PivotTo((options.GroundCFrame or CFrame.new()) * CFrame.new(0, offset, 0))

	fleetRig.Apply(model, {AnchorRoot = options.AnchorRoot ~= false})
	local gameplayApi = gameplay.Attach(model, options.GameplayConfig or defaultGameplayConfig)
	reactions.Attach(model)
	local soundApi = sounds.Attach(model)
	local runtimeApi = runtimeController.Attach(model, gameplayApi)

	model:SetAttribute("PipelinePhase", 7)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("QualityGateC", "Approved")
	model:SetAttribute("FinalInstallerVersion", 1)
	model:SetAttribute("WorkshopOnly", false)
	model:SetAttribute("GroundPlacementOffset", offset)
	model:SetAttribute("AnimationPass", "Approved")
	model:SetAttribute("SoundPass", "Approved")
	model:SetAttribute("CombatVFXPass", "Approved")
	model:SetAttribute("DirectionalAegisPass", "Approved")
	model:SetAttribute("TwinIonSoundId", "137510557013265")

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
	assert(typeof(parent) == "Instance", "AegisInterceptorInstaller.Uninstall requires a parent Instance")
	local existing = parent:FindFirstChild("Aegis_III_Interceptor_GoldenMaster")
	if not existing then return false end
	removeRemoteAndClients(existing:GetAttribute("AegisRuntimeRemoteName"))
	removeRemoteAndClients(existing:GetAttribute("AegisWarningRemoteName"))
	existing:Destroy()
	return true
end

return Installer
