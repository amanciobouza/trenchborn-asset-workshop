local Gameplay = {}

local function createBindableFunction(parent, name)
	local value = Instance.new("BindableFunction")
	value.Name = name
	value.Parent = parent
	return value
end

local function createBindableEvent(parent, name)
	local value = Instance.new("BindableEvent")
	value.Name = name
	value.Parent = parent
	return value
end

local function sanitizeDamage(amount)
	if typeof(amount) ~= "number" then
		return 0
	end
	if amount ~= amount or amount == math.huge or amount == -math.huge then
		return 0
	end
	return math.max(0, amount)
end

function Gameplay.Attach(model, config)
	local existing = model:FindFirstChild("Gameplay")
	if existing then
		existing:Destroy()
	end

	local api = Instance.new("Folder")
	api.Name = "Gameplay"
	api.Parent = model

	local protectedBuilding = Instance.new("ObjectValue")
	protectedBuilding.Name = "ProtectedBuilding"
	protectedBuilding.Parent = api

	local healthChanged = createBindableEvent(api, "HealthChanged")
	local staggered = createBindableEvent(api, "Staggered")
	local defeated = createBindableEvent(api, "Defeated")
	local batonStrikeRequested = createBindableEvent(api, "BatonStrikeRequested")
	local warningPulseRequested = createBindableEvent(api, "WarningPulseRequested")

	local applyDamage = createBindableFunction(api, "ApplyDamage")
	local requestAbility = createBindableFunction(api, "RequestAbility")
	local isProtectingBuilding = createBindableFunction(api, "IsProtectingBuilding")
	local resetGuardian = createBindableFunction(api, "ResetGuardian")

	local currentHealth = config.Guardian.MaxHealth
	local accumulatedStaggerDamage = 0
	local defeatedState = false
	local nextUseTime = {
		ShockBaton = 0,
		WarningPulse = 0,
	}

	model:SetAttribute("MaxHealth", config.Guardian.MaxHealth)
	model:SetAttribute("Health", currentHealth)
	model:SetAttribute("Shield", config.Guardian.Shield)
	model:SetAttribute("GuardianState", "Idle")
	model:SetAttribute("TuningStatus", config.TuningStatus)
	model:SetAttribute("ProtectionRadius", config.Protection.Radius)
	model:SetAttribute("DetectionRadius", config.Detection.SearchlightRadius)
	model:SetAttribute("GameplayUsesHeartbeatLoop", false)
	model:SetAttribute("GameplayUsesAdditionalBaseParts", false)

	applyDamage.OnInvoke = function(amount, source)
		if defeatedState then
			return currentHealth, "Defeated"
		end

		local acceptedDamage = sanitizeDamage(amount)
		if acceptedDamage <= 0 then
			return currentHealth, "Ignored"
		end

		currentHealth = math.max(0, currentHealth - acceptedDamage)
		accumulatedStaggerDamage += acceptedDamage
		model:SetAttribute("Health", currentHealth)
		healthChanged:Fire(currentHealth, config.Guardian.MaxHealth, source)

		if currentHealth <= 0 then
			defeatedState = true
			model:SetAttribute("GuardianState", "Defeated")
			defeated:Fire(source, config.Guardian.DefeatDelay)
			return currentHealth, "Defeated"
		end

		if accumulatedStaggerDamage >= config.Guardian.StaggerThreshold then
			accumulatedStaggerDamage = 0
			model:SetAttribute("GuardianState", "Staggered")
			staggered:Fire(config.Guardian.StaggerDuration, source)
			task.delay(config.Guardian.StaggerDuration, function()
				if not defeatedState and model:GetAttribute("GuardianState") == "Staggered" then
					model:SetAttribute("GuardianState", "Idle")
				end
			end)
			return currentHealth, "Staggered"
		end

		return currentHealth, "Damaged"
	end

	requestAbility.OnInvoke = function(abilityName, target)
		if defeatedState then
			return false, "Defeated"
		end

		local now = os.clock()
		if abilityName == "ShockBaton" then
			if now < nextUseTime.ShockBaton then
				return false, "Cooldown"
			end
			nextUseTime.ShockBaton = now + config.ShockBaton.Cooldown
			batonStrikeRequested:Fire(target, config.ShockBaton)
			return true, "Requested"
		end

		if abilityName == "WarningPulse" then
			if now < nextUseTime.WarningPulse then
				return false, "Cooldown"
			end
			nextUseTime.WarningPulse = now + config.WarningPulse.Cooldown
			warningPulseRequested:Fire(target, config.WarningPulse)
			return true, "Requested"
		end

		return false, "UnknownAbility"
	end

	isProtectingBuilding.OnInvoke = function(building)
		return not defeatedState
			and building ~= nil
			and protectedBuilding.Value == building
			and config.Protection.BlocksBuildingDamage
	end

	resetGuardian.OnInvoke = function()
		currentHealth = config.Guardian.MaxHealth
		accumulatedStaggerDamage = 0
		defeatedState = false
		nextUseTime.ShockBaton = 0
		nextUseTime.WarningPulse = 0
		protectedBuilding.Value = nil
		model:SetAttribute("Health", currentHealth)
		model:SetAttribute("GuardianState", "Idle")
		healthChanged:Fire(currentHealth, config.Guardian.MaxHealth, "Reset")
		return true
	end

	model:SetAttribute("PipelinePhase", 6)
	return api
end

return Gameplay
