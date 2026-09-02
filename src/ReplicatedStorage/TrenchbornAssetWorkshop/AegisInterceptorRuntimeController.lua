local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = script.Parent
local Controller = {}

function Controller.Attach(model, gameplayApi)
	local previous = model:FindFirstChild("AegisRuntime")
	if previous then previous:Destroy() end

	local runtime = Instance.new("Folder")
	runtime.Name = "AegisRuntime"
	runtime.Parent = model

	local requested = Instance.new("BindableEvent")
	requested.Name = "AnimationRequested"
	requested.Parent = runtime

	local remoteName = "AegisRuntimeAnimation_" .. HttpService:GenerateGUID(false)
	local remote = Instance.new("RemoteEvent")
	remote.Name = remoteName
	remote.Parent = ReplicatedStorage
	model:SetAttribute("AegisRuntimeRemoteName", remoteName)

	local clientTemplate = packageFolder:WaitForChild("GuardianRuntimeAnimation")
	local function install(player)
		local gui = player:WaitForChild("PlayerGui")
		if gui:FindFirstChild(remoteName) then return end
		local client = clientTemplate:Clone()
		client.Name = remoteName
		client:SetAttribute("RemoteName", remoteName)
		client.Parent = gui
		task.delay(0.6, function()
			if player.Parent and model.Parent and remote.Parent then
				remote:FireClient(player, "Idle", model)
			end
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

	local function play(name)
		if destroyed or not model.Parent or not remote.Parent then return end
		model:SetAttribute("GuardianAnimationState", name)
		remote:FireAllClients(name, model)
	end

	local function returnToIdle(delaySeconds)
		generation += 1
		local token = generation
		task.delay(delaySeconds, function()
			if token == generation and model.Parent and model:GetAttribute("GuardianState") ~= "Defeated" then
				play("Idle")
			end
		end)
	end

	connect(requested.Event, play)
	connect(gameplayApi:WaitForChild("AbilityRequested").Event, function(name, target, ability)
		if name == "TwinIonCannons" then
			play("TwinIonCannons")
			returnToIdle(math.max(1.15, (ability.TelegraphDuration or 0.55) + 0.72))
		elseif name == "ShoulderMissiles" then
			play("ShoulderMissileSalvo")
			returnToIdle(math.max(3.62, (ability.LockDuration or 2) + 1.45))
		elseif name == "DirectionalAegis" then
			-- StateChanged owns the deploy animation so it starts exactly once.
		end
	end)

	connect(gameplayApi:WaitForChild("DamageTaken").Event, function(healthDamage)
		if healthDamage > 0 and model:GetAttribute("GuardianState") ~= "Defeated" then
			play("DamageReact")
		end
	end)

	connect(gameplayApi:WaitForChild("StateChanged").Event, function(state)
		if state == "Idle" then
			generation += 1
			play("Idle")
		elseif state == "Staggered" then
			generation += 1
			play("Stagger")
		elseif state == "Defeated" then
			generation += 1
			play("Defeat")
		elseif state == "DirectionalAegis" then
			play("DirectionalAegis")
		end
	end)

	model:SetAttribute("AegisRuntimeControllerVersion", "1.0")
	play("Idle")

	local api = {AnimationRequested = requested, Remote = remote}
	function api.PlayAnimation(name)
		if not destroyed and requested.Parent then requested:Fire(name) end
	end
	function api.Destroy()
		if destroyed then return end
		destroyed = true
		generation += 1
		playerConnection:Disconnect()
		for _, connection in ipairs(connections) do connection:Disconnect() end
		for _, player in ipairs(Players:GetPlayers()) do
			local gui = player:FindFirstChild("PlayerGui")
			local client = gui and gui:FindFirstChild(remoteName)
			if client then client:Destroy() end
		end
		if remote.Parent then remote:Destroy() end
		if runtime.Parent then runtime:Destroy() end
		if model.Parent then model:SetAttribute("AegisRuntimeRemoteName", nil) end
	end
	return api
end

return Controller
