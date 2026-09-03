local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = script.Parent
local railVFX = require(packageFolder:WaitForChild("BastionRailCannonPreview"))
local siegeVFX = require(packageFolder:WaitForChild("BastionSiegePreview"))
local shieldVFX = require(packageFolder:WaitForChild("BastionDistrictShieldPreview"))
local Controller = {}

function Controller.Attach(model, gameplayApi)
	local previous = model:FindFirstChild("BastionRuntime")
	if previous then previous:Destroy() end
	local runtime = Instance.new("Folder")
	runtime.Name = "BastionRuntime"
	runtime.Parent = model
	local animationRequested = Instance.new("BindableEvent")
	animationRequested.Name = "AnimationRequested"
	animationRequested.Parent = runtime

	local remoteName = "BastionRuntimeAnimation_" .. HttpService:GenerateGUID(false)
	local remote = Instance.new("RemoteEvent")
	remote.Name = remoteName
	remote.Parent = ReplicatedStorage
	model:SetAttribute("BastionRuntimeRemoteName", remoteName)

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
	local function returnToIdle(delaySeconds)
		generation += 1
		local token = generation
		task.delay(delaySeconds, function()
			if token == generation and model.Parent and model:GetAttribute("GuardianState") ~= "Defeated" then play("Idle") end
		end)
	end
	local function impact(name, target, ability, hitIndex)
		local event = gameplayApi:FindFirstChild("AbilityImpact")
		if event and event:IsA("BindableEvent") then event:Fire(name, target, ability, hitIndex) end
	end

	connect(animationRequested.Event, play)
	connect(gameplayApi:WaitForChild("AbilityRequested").Event, function(name, target, ability)
		if name == "HeavyRailCannon" then
			play(name, target)
			railVFX.Play(model, target)
			task.delay(ability.TelegraphDuration or 1.55, function() impact(name, target, ability) end)
			returnToIdle(2.85)
		elseif name == "RightSiegeFist" or name == "LeftSiegeFist" then
			play(name, target)
			local side = name == "RightSiegeFist" and "Right" or "Left"
			task.delay(0.58, function()
				siegeVFX.FistImpact(model, side)
				impact(name, target, ability)
			end)
			returnToIdle(1.18)
		elseif name == "SiegeFistCombo" then
			play(name, target)
			task.delay(0.5, function() siegeVFX.FistImpact(model, "Right"); impact(name, target, ability, 1) end)
			task.delay(0.94, function() siegeVFX.FistImpact(model, "Left"); impact(name, target, ability, 2) end)
			returnToIdle(1.42)
		elseif name == "GroundSlam" then
			play(name, target)
			task.delay(ability.ImpactDelay or 1.02, function()
				siegeVFX.GroundSlam(model)
				impact(name, target, ability)
			end)
			returnToIdle(2.28)
		elseif name == "DistrictShield" then
			play(name)
			shieldVFX.Play(model)
			returnToIdle(5.8)
		end
	end)
	connect(gameplayApi:WaitForChild("DamageTaken").Event, function(healthDamage)
		if healthDamage > 0 and model:GetAttribute("GuardianState") ~= "Defeated" then play("DamageReact") end
	end)
	connect(gameplayApi:WaitForChild("StateChanged").Event, function(state)
		if state == "Idle" then generation += 1; play("Idle")
		elseif state == "Staggered" then generation += 1; play("Stagger")
		elseif state == "Defeated" then generation += 1; play("Defeat") end
	end)

	model:SetAttribute("BastionRuntimeControllerVersion", "1.0")
	play("Idle")
	local api = {AnimationRequested = animationRequested, Remote = remote}
	function api.PlayAnimation(name, target)
		if not destroyed and animationRequested.Parent then animationRequested:Fire(name, target) end
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
		if model.Parent then model:SetAttribute("BastionRuntimeRemoteName", nil) end
	end
	return api
end

return Controller
