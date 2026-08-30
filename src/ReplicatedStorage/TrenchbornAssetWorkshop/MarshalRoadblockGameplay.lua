local Gameplay = {}

local function bindFunction(parent, name)
	local item = Instance.new("BindableFunction")
	item.Name = name
	item.Parent = parent
	return item
end

local function bindEvent(parent, name)
	local item = Instance.new("BindableEvent")
	item.Name = name
	item.Parent = parent
	return item
end

function Gameplay.Attach(model, config)
	local old = model:FindFirstChild("Gameplay")
	if old then old:Destroy() end
	local api = Instance.new("Folder")
	api.Name = "Gameplay"
	api.Parent = model

	local abilityRequested = bindEvent(api, "AbilityRequested")
	local stateChanged = bindEvent(api, "StateChanged")
	local requestAbility = bindFunction(api, "RequestAbility")
	local applyDamage = bindFunction(api, "ApplyDamage")
	local reset = bindFunction(api, "Reset")
	local nowReady = {RiotShield = 0, PulseCannon = 0, ContainmentNet = 0}
	local health = config.Guardian.MaxHealth
	local shield = config.Guardian.MaxShield
	local shieldBlocking = false

	local function state(name)
		model:SetAttribute("GuardianState", name)
		stateChanged:Fire(name)
	end

	local function expose()
		model:SetAttribute("Health", health)
		model:SetAttribute("Shield", shield)
		model:SetAttribute("MaxHealth", config.Guardian.MaxHealth)
		model:SetAttribute("MaxShield", config.Guardian.MaxShield)
		model:SetAttribute("ShieldBlocking", shieldBlocking)
	end

	requestAbility.OnInvoke = function(name, target)
		local ability = config[name]
		if not ability then return false, "UnknownAbility" end
		if os.clock() < nowReady[name] then return false, "Cooldown" end
		if name == "RiotShield" and shield <= 0 then return false, "ShieldDepleted" end
		nowReady[name] = os.clock() + ability.Cooldown
		if name == "RiotShield" then
			shieldBlocking = true
			expose()
			state("ShieldBlock")
			task.delay(ability.Duration, function()
				shieldBlocking = false
				expose()
				if health > 0 then state("Idle") end
			end)
		else
			state(name .. "Telegraph")
		end
		abilityRequested:Fire(name, target, ability)
		return true, "Requested"
	end

	applyDamage.OnInvoke = function(amount, frontal)
		amount = math.max(0, tonumber(amount) or 0)
		local blocked = 0
		if frontal and shieldBlocking and shield > 0 then
			blocked = math.min(shield, amount * config.RiotShield.BlockReduction)
			shield -= blocked
		end
		health = math.max(0, health - (amount - blocked))
		expose()
		if health <= 0 then state("Defeated") end
		return health, shield, blocked
	end

	reset.OnInvoke = function()
		health = config.Guardian.MaxHealth
		shield = config.Guardian.MaxShield
		shieldBlocking = false
		for name in pairs(nowReady) do nowReady[name] = 0 end
		expose()
		state("Idle")
		return true
	end

	expose()
	state("Idle")
	model:SetAttribute("PipelinePhase", 6)
	model:SetAttribute("GameplayUsesHeartbeatLoop", false)
	return api
end

return Gameplay
