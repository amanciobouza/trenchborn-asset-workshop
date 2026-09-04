local Gameplay = {}

local ABILITIES = {
	ApexLanceThrust = true, ApexLanceCut = true, ApexLanceBeam = true,
	HunterDrones = true, SovereignLock = true,
}

local function bind(parent, className, name)
	local item = Instance.new(className)
	item.Name = name
	item.Parent = parent
	return item
end

local function finite(value)
	value = tonumber(value)
	if not value or value ~= value or value == math.huge or value == -math.huge then return 0 end
	return math.max(0, value)
end

function Gameplay.Attach(model, config)
	local old = model:FindFirstChild("Gameplay")
	if old then old:Destroy() end
	local api = Instance.new("Folder")
	api.Name = "Gameplay"
	api.Parent = model

	local requestAbility = bind(api, "BindableFunction", "RequestAbility")
	local applyDamage = bind(api, "BindableFunction", "ApplyDamage")
	local applyLockDamage = bind(api, "BindableFunction", "ApplyLockDamage")
	local isTargetLocked = bind(api, "BindableFunction", "IsTargetLocked")
	local reset = bind(api, "BindableFunction", "Reset")
	local abilityRequested = bind(api, "BindableEvent", "AbilityRequested")
	local abilityImpact = bind(api, "BindableEvent", "AbilityImpact")
	local damageTaken = bind(api, "BindableEvent", "DamageTaken")
	local stateChanged = bind(api, "BindableEvent", "StateChanged")
	local lockChanged = bind(api, "BindableEvent", "SovereignLockChanged")

	local health = config.Guardian.MaxHealth
	local defeated = false
	local staggerDamage = 0
	local readyAt = {}
	local actionToken = 0
	local lockTarget
	local lockBarrier = config.SovereignLock.BarrierPoints
	local lockActive = false
	for name in pairs(ABILITIES) do readyAt[name] = 0 end

	local function expose()
		model:SetAttribute("Health", health)
		model:SetAttribute("MaxHealth", config.Guardian.MaxHealth)
		model:SetAttribute("ArmorReduction", config.Guardian.ArmorReduction)
		model:SetAttribute("StaggerThreshold", config.Guardian.StaggerThreshold)
		model:SetAttribute("SovereignLockActive", lockActive)
		model:SetAttribute("SovereignLockBarrier", lockBarrier)
		model:SetAttribute("MaxSovereignLockBarrier", config.SovereignLock.BarrierPoints)
		model:SetAttribute("SovereignLockMovementMultiplier", config.SovereignLock.MovementMultiplier)
	end

	local function state(name)
		model:SetAttribute("GuardianState", name)
		stateChanged:Fire(name)
	end

	local function releaseLock(reason)
		if not lockActive and not lockTarget then return end
		local previousTarget = lockTarget
		lockActive = false
		lockTarget = nil
		expose()
		lockChanged:Fire(false, previousTarget, lockBarrier, reason)
	end

	requestAbility.OnInvoke = function(name, target)
		if defeated then return false, "Defeated" end
		if not ABILITIES[name] or not config[name] then return false, "UnknownAbility" end
		if os.clock() < readyAt[name] then return false, "Cooldown" end
		readyAt[name] = os.clock() + config[name].Cooldown
		actionToken += 1
		local token = actionToken
		state(name .. "Telegraph")
		abilityRequested:Fire(name, target, config[name])
		if name == "SovereignLock" then
			lockBarrier = config.SovereignLock.BarrierPoints
			lockTarget = target
			task.delay(config.SovereignLock.ActivationDelay, function()
				if token ~= actionToken or defeated or not model.Parent then return end
				lockActive = true
				expose()
				state("SovereignLock")
				lockChanged:Fire(true, lockTarget, lockBarrier, "Activated")
			end)
			task.delay(config.SovereignLock.ActivationDelay + config.SovereignLock.ActiveDuration, function()
				if token ~= actionToken or defeated or not model.Parent then return end
				releaseLock("Expired")
			end)
		end
		task.delay(config[name].RuntimeDuration, function()
			if token == actionToken and not defeated and model.Parent then
				if name == "SovereignLock" then releaseLock("Completed") end
				state("Idle")
			end
		end)
		return true, "Requested"
	end

	applyLockDamage.OnInvoke = function(amount, target)
		if not lockActive or (target and target ~= lockTarget) then
			return 0, lockBarrier, "NotLocked"
		end
		local applied = math.min(lockBarrier, finite(amount))
		lockBarrier -= applied
		if lockBarrier <= 0 then releaseLock("Broken") else expose() end
		return applied, lockBarrier, lockActive and "Damaged" or "Broken"
	end

	isTargetLocked.OnInvoke = function(target)
		local locked = lockActive and (target == nil or target == lockTarget)
		return locked, locked and config.SovereignLock.MovementMultiplier or 1, lockBarrier
	end

	applyDamage.OnInvoke = function(amount, source)
		if defeated then return health, 0, "Defeated" end
		if source == "TestForceDefeat" then amount = health / math.max(0.01, 1 - config.Guardian.ArmorReduction) end
		amount = finite(amount)
		local blocked = amount * config.Guardian.ArmorReduction
		local healthDamage = amount - blocked
		health = math.max(0, health - healthDamage)
		staggerDamage += source == "TestStagger" and config.Guardian.StaggerThreshold or healthDamage
		expose()
		damageTaken:Fire(healthDamage, blocked, source)
		if health <= 0 then
			defeated = true
			actionToken += 1
			releaseLock("Defeated")
			state("Defeated")
			return health, blocked, "Defeated"
		end
		if staggerDamage >= config.Guardian.StaggerThreshold then
			staggerDamage = 0
			actionToken += 1
			releaseLock("Interrupted")
			state("Staggered")
			local token = actionToken
			task.delay(config.Guardian.StaggerDuration, function()
				if token == actionToken and not defeated and model.Parent then state("Idle") end
			end)
			return health, blocked, "Staggered"
		end
		return health, blocked, "Damaged"
	end

	reset.OnInvoke = function()
		health = config.Guardian.MaxHealth
		defeated = false
		staggerDamage = 0
		actionToken += 1
		lockActive = false
		lockTarget = nil
		lockBarrier = config.SovereignLock.BarrierPoints
		for name in pairs(readyAt) do readyAt[name] = 0 end
		expose()
		lockChanged:Fire(false, nil, lockBarrier, "Reset")
		state("Idle")
		return true
	end

	expose()
	state("Idle")
	model:SetAttribute("PipelinePhase", 6)
	model:SetAttribute("TuningStatus", config.TuningStatus)
	model:SetAttribute("GameplayUsesHeartbeatLoop", false)
	model:SetAttribute("GameplayUsesAdditionalBaseParts", false)
	model:SetAttribute("AbilityImpactContract", abilityImpact.Name)
	return api
end

return Gameplay
