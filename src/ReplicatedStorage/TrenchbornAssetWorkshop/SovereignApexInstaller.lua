local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = script.Parent
local builder = require(packageFolder:WaitForChild("SovereignApexGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("SovereignApexDressing"))
local defaultGameplayConfig = require(packageFolder:WaitForChild("SovereignApexGameplayConfig"))
local gameplay = require(packageFolder:WaitForChild("SovereignApexGameplay"))
local fleetRig = require(packageFolder:WaitForChild("GuardianFleetRig"))
local sounds = require(packageFolder:WaitForChild("SovereignApexSoundController"))
local runtimeController = require(packageFolder:WaitForChild("SovereignApexRuntimeController"))
local droneVFX = require(packageFolder:WaitForChild("SovereignHunterDronePreview"))

local Installer = {}
local installations = setmetatable({}, {__mode = "k"})

local function groundOffset(model)
	local minimumY = math.huge
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 and not item:FindFirstAncestor("Hitboxes") then
			minimumY = math.min(minimumY, item.Position.Y - item.Size.Y * 0.5)
		end
	end
	return minimumY < math.huge and model:GetPivot().Position.Y - minimumY or 0
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
	assert(typeof(parent) == "Instance", "SovereignApexInstaller.Install requires a parent Instance")
	options = options or {}

	local model = builder.Build(parent)
	dressing.Apply(model)
	local offset = groundOffset(model)
	model:PivotTo((options.GroundCFrame or CFrame.new()) * CFrame.new(0, offset, 0))

	fleetRig.Apply(model, {AnchorRoot = options.AnchorRoot ~= false})
	local gameplayApi = gameplay.Attach(model, options.GameplayConfig or defaultGameplayConfig)
	local soundApi = sounds.Attach(model)
	local runtimeApi = runtimeController.Attach(model, gameplayApi)
	installations[model] = runtimeApi

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
	model:SetAttribute("HunterDronePass", "Approved")
	model:SetAttribute("SovereignLockPass", "Approved")
	model:SetAttribute("WingInertiaPass", "Approved")

	local api = {
		Gameplay = gameplayApi,
		Runtime = runtimeApi,
		SoundRequested = soundApi,
		RequestAbility = gameplayApi:WaitForChild("RequestAbility"),
		ApplyDamage = gameplayApi:WaitForChild("ApplyDamage"),
		ApplyLockDamage = gameplayApi:WaitForChild("ApplyLockDamage"),
		IsTargetLocked = gameplayApi:WaitForChild("IsTargetLocked"),
		Reset = gameplayApi:WaitForChild("Reset"),
		AnimationRequested = runtimeApi.AnimationRequested,
	}
	return model, api
end

function Installer.Uninstall(parent)
	assert(typeof(parent) == "Instance", "SovereignApexInstaller.Uninstall requires a parent Instance")
	local existing = parent:FindFirstChild("Sovereign_V_Apex_GoldenMaster")
	if not existing then return false end
	droneVFX.Reset(existing)
	local runtimeApi = installations[existing]
	if runtimeApi then
		runtimeApi.Destroy()
		installations[existing] = nil
	else
		removeRemoteAndClients(existing:GetAttribute("SovereignRuntimeRemoteName"))
	end
	existing:Destroy()
	return true
end

return Installer
