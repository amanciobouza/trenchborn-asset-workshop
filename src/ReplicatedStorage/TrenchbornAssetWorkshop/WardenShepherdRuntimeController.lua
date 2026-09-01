local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local packageFolder = script.Parent
local vfx = require(packageFolder:WaitForChild("WardenShepherdCombatVFX"))

local Controller = {}

function Controller.Attach(model, gameplay)
	local runtime = Instance.new("Folder")
	runtime.Name = "WardenRuntime"
	runtime.Parent = model
	local requested = Instance.new("BindableEvent")
	requested.Name = "AnimationRequested"
	requested.Parent = runtime

	local remoteName = "WardenRuntimeAnimation_" .. HttpService:GenerateGUID(false)
	local remote = Instance.new("RemoteEvent")
	remote.Name = remoteName
	remote.Parent = ReplicatedStorage
	model:SetAttribute("WardenRuntimeRemoteName", remoteName)

	local clientTemplate = packageFolder:WaitForChild("GuardianRuntimeAnimation")
	local function install(player)
		local playerGui = player:WaitForChild("PlayerGui")
		if playerGui:FindFirstChild(remoteName) then return end
		local client = clientTemplate:Clone()
		client.Name = remoteName
		client:SetAttribute("RemoteName", remoteName)
		client.Parent = playerGui
		task.delay(0.6, function()
			if player.Parent and model.Parent and remote.Parent then remote:FireClient(player, "Idle", model) end
		end)
	end
	for _, player in ipairs(Players:GetPlayers()) do task.spawn(install, player) end
	local playerConnection = Players.PlayerAdded:Connect(install)
	local connections = {}
	local function connect(signal, callback)
		local connection = signal:Connect(callback)
		table.insert(connections, connection)
	end
	local function play(name)
		if model.Parent and remote.Parent then
			model:SetAttribute("GuardianAnimationState", name)
			remote:FireAllClients(name, model)
		end
	end
	connect(requested.Event, play)

	connect(gameplay:WaitForChild("HealthChanged").Event, function(health, _, source)
		if source == "Reset" then play("Idle")
		elseif health > 0 then play("DamageReact") end
	end)
	connect(gameplay:WaitForChild("Staggered").Event, function(duration)
		play("Stagger")
		task.delay(duration, function()
			if model.Parent and model:GetAttribute("GuardianState") ~= "Defeated" then play("Idle") end
		end)
	end)
	connect(gameplay:WaitForChild("Defeated").Event, function()
		play("Defeat")
	end)
	connect(gameplay:WaitForChild("BatonStrikeRequested").Event, function()
		play("ShockBaton")
		vfx.ShockBaton(model)
		task.delay(1.05, function()
			if model.Parent and model:GetAttribute("GuardianState") ~= "Defeated" then play("Idle") end
		end)
	end)
	connect(gameplay:WaitForChild("WarningPulseRequested").Event, function(_, config)
		play("WarningPulse")
		vfx.WarningPulse(model, config)
		task.delay(1.62, function()
			if model.Parent and model:GetAttribute("GuardianState") ~= "Defeated" then play("Idle") end
		end)
	end)

	model:SetAttribute("WardenRuntimeControllerVersion", "1.0")
	play("Idle")
	local destroyed = false
	local api = {}
	function api.PlayAnimation(name)
		if not destroyed and requested.Parent then requested:Fire(name) end
	end
	function api.Destroy()
		if destroyed then return end
		destroyed = true
		playerConnection:Disconnect()
		for _, connection in ipairs(connections) do connection:Disconnect() end
		for _, player in ipairs(Players:GetPlayers()) do
			local gui = player:FindFirstChild("PlayerGui")
			local client = gui and gui:FindFirstChild(remoteName)
			if client then client:Destroy() end
		end
		if remote.Parent then remote:Destroy() end
		if runtime.Parent then runtime:Destroy() end
		if model.Parent then model:SetAttribute("WardenRuntimeRemoteName", nil) end
	end
	api.AnimationRequested = requested
	api.Remote = remote
	return api
end

return Controller
