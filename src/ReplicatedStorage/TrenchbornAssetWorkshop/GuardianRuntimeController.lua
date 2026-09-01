local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = script.Parent
local combatVFX = require(packageFolder:WaitForChild("GuardianCombatVFX"))

local Controller = {}

function Controller.Attach(model, gameplayApi)
	local previous = model:FindFirstChild("GuardianRuntime")
	if previous then previous:Destroy() end

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

	-- Rojo maps GuardianRuntimeAnimation.client.lua to GuardianRuntimeAnimation.
	local clientTemplate = packageFolder:WaitForChild("GuardianRuntimeAnimation")
	local function install(player)
		local playerGui = player:WaitForChild("PlayerGui")
		if playerGui:FindFirstChild(remoteName) then return end
		local client = clientTemplate:Clone()
		client.Name = remoteName
		client:SetAttribute("RemoteName", remoteName)
		client.Parent = playerGui
		task.delay(0.6, function()
			if player.Parent and model.Parent and remote.Parent then
				remote:FireClient(player, "Idle", model)
			end
		end)
	end
	for _, player in ipairs(Players:GetPlayers()) do task.spawn(install, player) end
	local playerConnection = Players.PlayerAdded:Connect(install)

	local connections = {}
	local function connect(signal, callback)
		local connection = signal:Connect(callback)
		table.insert(connections, connection)
		return connection
	end

	local function play(name)
		if not model.Parent or not remote.Parent then return end
		model:SetAttribute("GuardianAnimationState", name)
		remote:FireAllClients(name, model)
	end
	connect(requested.Event, play)

	local abilityRequested = gameplayApi:WaitForChild("AbilityRequested")
	local damageTaken = gameplayApi:WaitForChild("DamageTaken")
	local stateChanged = gameplayApi:WaitForChild("StateChanged")

	connect(abilityRequested.Event, function(name, target, ability)
		if name == "RiotShield" then
			play("ShieldBlock")
			task.delay(ability.Duration, function()
				if model.Parent and model:GetAttribute("GuardianState") ~= "Defeated" then play("Idle") end
			end)
		elseif name == "PulseCannon" then
			play("PulseCannonFire")
			combatVFX.Pulse(model, target, ability)
			task.delay(1.62, function()
				if model.Parent and model:GetAttribute("GuardianState") ~= "Defeated" then play("Idle") end
			end)
		elseif name == "ContainmentNet" then
			play("ContainmentNetLaunch")
			combatVFX.ContainmentNet(model, target, ability)
			task.delay(2.1, function()
				if model.Parent and model:GetAttribute("GuardianState") ~= "Defeated" then play("Idle") end
			end)
		end
	end)

	connect(damageTaken.Event, function(healthDamage)
		if healthDamage > 0 and model:GetAttribute("GuardianState") ~= "Defeated" then play("DamageReact") end
	end)

	connect(stateChanged.Event, function(state)
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
		for _, connection in ipairs(connections) do connection:Disconnect() end
		for _, player in ipairs(Players:GetPlayers()) do
			local playerGui = player:FindFirstChild("PlayerGui")
			local client = playerGui and playerGui:FindFirstChild(remoteName)
			if client then client:Destroy() end
		end
		if remote.Parent then remote:Destroy() end
		if runtime.Parent then runtime:Destroy() end
	end
	api.AnimationRequested = requested
	api.Remote = remote
	return api
end

return Controller
