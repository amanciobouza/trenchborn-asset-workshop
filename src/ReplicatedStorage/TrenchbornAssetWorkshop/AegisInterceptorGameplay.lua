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

local function finiteDamage(amount)
	amount = tonumber(amount)
	if not amount or amount ~= amount or amount == math.huge or amount == -math.huge then return 0 end
	return math.max(0, amount)
end

function Gameplay.Attach(model, config)
	local old = model:FindFirstChild("Gameplay")
	if old then old:Destroy() end
	local api = Instance.new("Folder")
	api.Name = "Gameplay"
	api.Parent = model

	local abilityRequested = bindEvent(api, "AbilityRequested")
	local damageTaken = bindEvent(api, "DamageTaken")
	local stateChanged = bindEvent(api, "StateChanged")
	local requestAbility = bindFunction(api, "RequestAbility")
	local applyDamage = bindFunction(api, "ApplyDamage")
	local reset = bindFunction(api, "Reset")

	local health = config.Guardian.MaxHealth
	local shield = config.Guardian.MaxShield
	local aegisActive = false
	local staggerDamage = 0
	local defeated = false
	local readyAt = {TwinIonCannons = 0, ShoulderMissiles = 0, DirectionalAegis = 0}
	local aegisToken = 0

	local function state(name)
		model:SetAttribute("GuardianState", name)
		stateChanged:Fire(name)
	end

	local function expose()
		model:SetAttribute("Health", health)
		model:SetAttribute("MaxHealth", config.Guardian.MaxHealth)
		model:SetAttribute("Shield", shield)
		model:SetAttribute("MaxShield", config.Guardian.MaxShield)
		model:SetAttribute("AegisActive", aegisActive)
		model:SetAttribute("StaggerThreshold", config.Guardian.StaggerThreshold)
	end

	local function isFrontal(source)
		if typeof(source) ~= "Instance" then return false end
		local sourcePosition
		if source:IsA("BasePart") then sourcePosition = source.Position
		elseif source:IsA("Model") then sourcePosition = source:GetPivot().Position end
		if not sourcePosition or not model.PrimaryPart then return false end
		local delta = sourcePosition - model.PrimaryPart.Position
		local planar = Vector3.new(delta.X, 0, delta.Z)
		if planar.Magnitude < 0.01 then return true end
		local forward = Vector3.new(model.PrimaryPart.CFrame.LookVector.X, 0, model.PrimaryPart.CFrame.LookVector.Z)
		if forward.Magnitude < 0.01 then return false end
		local threshold = math.cos(math.rad(config.DirectionalAegis.FrontArcDegrees * 0.5))
		return forward.Unit:Dot(planar.Unit) >= threshold
	end

	requestAbility.OnInvoke = function(name, target)
		if defeated then return false, "Defeated" end
		local ability = config[name]
		if not ability then return false, "UnknownAbility" end
		if os.clock() < readyAt[name] then return false, "Cooldown" end
		if name == "DirectionalAegis" and shield <= 0 then return false, "ShieldDepleted" end
		readyAt[name] = os.clock() + ability.Cooldown
		if name == "DirectionalAegis" then
			aegisToken += 1
			local token = aegisToken
			aegisActive = true
			expose()
			state("DirectionalAegis")
			task.delay(ability.Duration, function()
				if token == aegisToken and not defeated then
					aegisActive = false
					expose()
					state("Idle")
				end
			end)
		else
			state(name .. "Telegraph")
		end
		abilityRequested:Fire(name, target, ability)
		return true, "Requested"
	end

	applyDamage.OnInvoke = function(amount, source)
		if defeated then return health, shield, 0, "Defeated" end
		amount = finiteDamage(amount)
		local blocked = 0
		local frontal = isFrontal(source)
		if aegisActive and frontal and shield > 0 then
			blocked = math.min(shield, amount * config.DirectionalAegis.DamageReduction)
			shield -= blocked
			if shield <= 0 then
				aegisToken += 1
				aegisActive = false
				state("Idle")
			end
		end
		local healthDamage = amount - blocked
		health = math.max(0, health - healthDamage)
		staggerDamage += healthDamage
		expose()
		damageTaken:Fire(healthDamage, blocked, frontal, source)

		if health <= 0 then
			defeated = true
			aegisToken += 1
			aegisActive = false
			expose()
			state("Defeated")
			return health, shield, blocked, "Defeated"
		end
		if staggerDamage >= config.Guardian.StaggerThreshold then
			staggerDamage = 0
			state("Staggered")
			task.delay(config.Guardian.StaggerDuration, function()
				if not defeated and model:GetAttribute("GuardianState") == "Staggered" then state("Idle") end
			end)
			return health, shield, blocked, "Staggered"
		end
		return health, shield, blocked, blocked > 0 and "Blocked" or "Damaged"
	end

	reset.OnInvoke = function()
		health = config.Guardian.MaxHealth
		shield = config.Guardian.MaxShield
		aegisToken += 1
		aegisActive = false
		staggerDamage = 0
		defeated = false
		for name in pairs(readyAt) do readyAt[name] = 0 end
		expose()
		state("Idle")
		return true
	end

	expose()
	state("Idle")
	model:SetAttribute("PipelinePhase", 6)
	model:SetAttribute("TuningStatus", config.TuningStatus)
	model:SetAttribute("GameplayUsesHeartbeatLoop", false)
	model:SetAttribute("GameplayUsesAdditionalBaseParts", false)
	return api
end

return Gameplay
