local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = script.Parent
local combatVFX = require(packageFolder:WaitForChild("GuardianCombatVFX"))

local Controller = {}

function Controller.Attach(model, gameplayApi)
	local runtime = Instance.new("Folder")
	runtime.Name = "GuardianRuntime"
	runtime.Parent = model
	local requested = Instance.new("BindableEvent")
	requested.Name = "AnimationRequested"
	requested.Parent = runtime

	local remoteName = "GuardianRuntimeAnimation_" .. HttpService:GenerateGUID(false)
	local remote = Instance.new("RemoteEvent")
	remote.Name = remoteName
	remote.Parent = ReplicatedStorage

	local clientTemplate = packageFolder:WaitForChild("GuardianRuntimeAnimationClient")
	local function install(player)
		local playerGui = player:WaitForChild("PlayerGui")
		local client = clientTemplate:Clone()
		client.Name = remoteName
		client:SetAttribute("RemoteName", remoteName)
		client.Parent = playerGui
		task.delay(0.6, function()
			if player.Parent and model.Parent then remote:FireClient(player, "Idle", model) end
		end)
	end
	for _, player in ipairs(Players:GetPlayers()) do task.spawn(install, player) end
	local playerConnection = Players.PlayerAdded:Connect(install)

	local function play(name)
		model:SetAttribute("GuardianAnimationState", name)
		remote:FireAllClients(name, model)
	end
	requested.Event:Connect(play)

	local abilityRequested = gameplayApi:WaitForChild("AbilityRequested")
	local damageTaken = gameplayApi:WaitForChild("DamageTaken")
	local stateChanged = gameplayApi:WaitForChild("StateChanged")

	abilityRequested.Event:Connect(function(name, target, ability)
		if name == "RiotShield" then
			play("ShieldBlock")
			task.delay(ability.Duration, function()
				if model:GetAttribute("GuardianState") ~= "Defeated" then play("Idle") end
			end)
		elseif name == "PulseCannon" then
			play("PulseCannonFire")
			combatVFX.Pulse(model, target, ability)
			task.delay(1.62, function()
				if model:GetAttribute("GuardianState") ~= "Defeated" then play("Idle") end
			end)
		elseif name == "ContainmentNet" then
			play("ContainmentNetLaunch")
			combatVFX.ContainmentNet(model, target, ability)
			task.delay(2.1, function()
				if model:GetAttribute("GuardianState") ~= "Defeated" then play("Idle") end
			end)
		end
	end)

	damageTaken.Event:Connect(function(healthDamage)
		if healthDamage > 0 and model:GetAttribute("GuardianState") ~= "Defeated" then play("DamageReact") end
	end)

	stateChanged.Event:Connect(function(state)
		if state == "Idle" then play("Idle")
		elseif state == "Staggered" then play("Stagger")
		elseif state == "Defeated" then play("Defeat") end
	end)

	model:SetAttribute("GuardianRuntimeControllerVersion", "1.0")
	play("Idle")

	local api = {}
	function api.PlayAnimation(name) requested:Fire(name) end
	function api.Destroy()
		playerConnection:Disconnect()
		remote:Destroy()
		runtime:Destroy()
	end
	api.AnimationRequested = requested
	api.Remote = remote
	return api
end

return Controller
