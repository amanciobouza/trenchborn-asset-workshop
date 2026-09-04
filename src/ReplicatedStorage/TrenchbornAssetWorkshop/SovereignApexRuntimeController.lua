local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = script.Parent
local lanceVFX = require(packageFolder:WaitForChild("SovereignApexLancePreview"))
local droneVFX = require(packageFolder:WaitForChild("SovereignHunterDronePreview"))
local Controller = {}

function Controller.Attach(model, gameplayApi)
	local previous = model:FindFirstChild("SovereignRuntime")
	if previous then previous:Destroy() end
	local runtime = Instance.new("Folder")
	runtime.Name = "SovereignRuntime"
	runtime.Parent = model
	local animationRequested = Instance.new("BindableEvent")
	animationRequested.Name = "AnimationRequested"
	animationRequested.Parent = runtime

	local remoteName = "SovereignRuntimeAnimation_" .. HttpService:GenerateGUID(false)
	local remote = Instance.new("RemoteEvent")
	remote.Name = remoteName
	remote.Parent = ReplicatedStorage
	model:SetAttribute("SovereignRuntimeRemoteName", remoteName)

	local clientTemplate = packageFolder:WaitForChild("GuardianRuntimeAnimation")
	local function install(player)
		local gui = player:WaitForChild("PlayerGui")
		if gui:FindFirstChild(remoteName) then return end
		local client = clientTemplate:Clone()
		client.Name = remoteName
		client:SetAttribute("RemoteName", remoteName)
		client.Parent = gui
		task.delay(0.6, function()
			if player.Parent and model.Parent and remote.Parent then remote:FireClient(player, "Idle", model) end
		end)
	end
	for _, player in ipairs(Players:GetPlayers()) do task.spawn(install, player) end
	local playerConnection = Players.PlayerAdded:Connect(install)
	local connections = {}
	local generation = 0
	local destroyed = false

	local function connect(signal, callback)
		local connection = signal:Connect(callback)
		table.insert(connections, connection)
	end
	local function play(name, target)
		if destroyed or not model.Parent or not remote.Parent then return end
		model:SetAttribute("GuardianAnimationState", name)
		remote:FireAllClients(name, model, target)
	end
	local function sound(name, speedScale, volumeScale)
		local soundscape = model:FindFirstChild("GuardianSoundscape")
		local request = soundscape and soundscape:FindFirstChild("SoundRequested")
		if request and request:IsA("BindableEvent") then request:Fire(name, speedScale, volumeScale) end
	end
	local function impact(name, target, ability, hitIndex)
		local event = gameplayApi:FindFirstChild("AbilityImpact")
		if event and event:IsA("BindableEvent") then event:Fire(name, target, ability, hitIndex) end
	end
	local function beginAction()
		generation += 1
		return generation
	end
	local function alive(token)
		return not destroyed and token == generation and model.Parent
			and model:GetAttribute("GuardianState") ~= "Defeated"
	end
	local function later(token, delaySeconds, callback)
		task.delay(delaySeconds, function()
			if alive(token) then callback() end
		end)
	end

	connect(animationRequested.Event, play)
	connect(gameplayApi:WaitForChild("AbilityRequested").Event, function(name, target, ability)
		local token = beginAction()
		model:SetAttribute("SovereignWingInertiaSuspended", true)
		play(name, target)
		if name == "ApexLanceThrust" then
			lanceVFX.Thrust(model)
			sound("LanceWindup"); sound("LanceHumStart")
			later(token, 0.48, function() sound("LanceWhoosh", 0.94) end)
			later(token, ability.ImpactDelay, function()
				sound("LanceImpact"); sound("LanceImpactBass"); impact(name, target, ability)
			end)
			later(token, 0.8, function() sound("LanceReturnWhoosh") end)
			later(token, 1.05, function() sound("LanceHumStop") end)
		elseif name == "ApexLanceCut" then
			lanceVFX.Cut(model)
			sound("LanceWindup", 0.92); sound("LanceHumStart")
			later(token, 0.44, function() sound("LanceWhoosh", 0.78, 1.18) end)
			later(token, ability.ImpactDelay, function()
				sound("LanceImpact", 1.08, 1.06); sound("LanceImpactBass", 0.92)
				sound("LanceCutTail"); impact(name, target, ability)
			end)
			later(token, 0.9, function() sound("LanceReturnWhoosh", 0.9, 1.08) end)
			later(token, 1.16, function() sound("LanceHumStop") end)
		elseif name == "ApexLanceBeam" then
			lanceVFX.Beam(model, target)
			sound("BeamCharge")
			later(token, ability.TelegraphDuration, function()
				sound("BeamFire"); sound("BeamBass"); impact(name, target, ability)
			end)
		elseif name == "HunterDrones" then
			droneVFX.Play(model, target)
			for pair = 0, 2 do later(token, pair * 0.32, function() sound("DroneLaunch", 0.96 + pair * 0.04) end) end
			for chirp = 0, 5 do later(token, 1.6 + chirp * 0.14, function()
				sound("DroneChirp", 0.88 + (chirp % 3) * 0.12, 0.72)
			end) end
			for confirm = 0, 2 do later(token, 2.55 + confirm * 0.11, function()
				sound("DroneChirp", 1.08 + confirm * 0.14)
			end) end
			for wave = 1, ability.WaveCount do
				later(token, ability.FirstImpactDelay + (wave - 1) * ability.WaveInterval, function()
					sound("DroneStrike", 0.98 + (wave - 1) * 0.035)
					impact(name, target, ability, wave)
				end)
			end
		elseif name == "SovereignLock" then
			droneVFX.PlayLock(model, target)
			sound("LockCharge")
			for pair = 0, 2 do later(token, pair * 0.32, function()
				sound("DroneLaunch", 0.82 + pair * 0.035, 0.86)
			end) end
			later(token, ability.ActivationDelay, function()
				sound("LockEngage"); impact(name, target, ability)
			end)
			later(token, ability.ActivationDelay + ability.ActiveDuration, function() sound("LockRelease") end)
		end
	end)

	connect(gameplayApi:WaitForChild("DamageTaken").Event, function(healthDamage, _, source)
		if healthDamage > 0 and source ~= "TestForceDefeat"
			and model:GetAttribute("GuardianState") ~= "Defeated" then
			sound("Damage")
			play("DamageReact")
		end
	end)
	connect(gameplayApi:WaitForChild("StateChanged").Event, function(state)
		if state == "Idle" then
			generation += 1
			model:SetAttribute("SovereignWingDefeated", false)
			model:SetAttribute("SovereignWingInertiaSuspended", false)
			sound("Reset")
			play("Idle")
		elseif state == "Staggered" then
			generation += 1
			droneVFX.Reset(model)
			sound("LanceHumStop"); sound("LockRelease"); sound("Stagger")
			play("Stagger")
		elseif state == "Defeated" then
			generation += 1
			droneVFX.Reset(model)
			model:SetAttribute("SovereignWingDefeated", true)
			model:SetAttribute("SovereignWingInertiaSuspended", true)
			sound("Defeat")
			play("Defeat")
		end
	end)

	model:SetAttribute("SovereignRuntimeControllerVersion", "1.0")
	play("Idle")
	local api = {AnimationRequested = animationRequested, Remote = remote}
	function api.PlayAnimation(name, target)
		if not destroyed and animationRequested.Parent then animationRequested:Fire(name, target) end
	end
	function api.Destroy()
		if destroyed then return end
		destroyed = true
		generation += 1
		droneVFX.Reset(model)
		playerConnection:Disconnect()
		for _, connection in ipairs(connections) do connection:Disconnect() end
		for _, player in ipairs(Players:GetPlayers()) do
			local gui = player:FindFirstChild("PlayerGui")
			local client = gui and gui:FindFirstChild(remoteName)
			if client then client:Destroy() end
		end
		if remote.Parent then remote:Destroy() end
		if runtime.Parent then runtime:Destroy() end
		if model.Parent then model:SetAttribute("SovereignRuntimeRemoteName", nil) end
	end
	return api
end

return Controller
