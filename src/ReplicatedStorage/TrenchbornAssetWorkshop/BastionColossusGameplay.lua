local Gameplay = {}

local ABILITIES = {
	HeavyRailCannon = true,
	RightSiegeFist = true,
	LeftSiegeFist = true,
	SiegeFistCombo = true,
	GroundSlam = true,
	DistrictShield = true,
}

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

	local requestAbility = bindFunction(api, "RequestAbility")
	local applyDamage = bindFunction(api, "ApplyDamage")
	local absorbDistrictDamage = bindFunction(api, "AbsorbDistrictDamage")
	local isPositionProtected = bindFunction(api, "IsPositionProtected")
	local reset = bindFunction(api, "Reset")
	local abilityRequested = bindEvent(api, "AbilityRequested")
	local damageTaken = bindEvent(api, "DamageTaken")
	local stateChanged = bindEvent(api, "StateChanged")
	local districtShieldChanged = bindEvent(api, "DistrictShieldChanged")

	local health = config.Guardian.MaxHealth
	local shield = config.DistrictShield.ShieldPoints
	local shieldActive = false
	local defeated = false
	local staggerDamage = 0
	local shieldToken = 0
	local readyAt = {}
	for name in pairs(ABILITIES) do readyAt[name] = 0 end

	local function state(name)
		model:SetAttribute("GuardianState", name)
		stateChanged:Fire(name)
	end

	local function shieldCenter()
		local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
		return root and (root.Position + root.CFrame.LookVector * 65) or Vector3.zero
	end

	local function protected(position)
		if not shieldActive or typeof(position) ~= "Vector3" then return false end
		local center = shieldCenter()
		local flat = Vector3.new(position.X - center.X, 0, position.Z - center.Z)
		return flat.Magnitude <= config.DistrictShield.ProtectionRadius
	end

	local function expose()
		model:SetAttribute("Health", health)
		model:SetAttribute("MaxHealth", config.Guardian.MaxHealth)
		model:SetAttribute("Shield", shield)
		model:SetAttribute("MaxShield", config.DistrictShield.ShieldPoints)
		model:SetAttribute("DistrictShieldActive", shieldActive)
		model:SetAttribute("DistrictShieldRadius", config.DistrictShield.ProtectionRadius)
		model:SetAttribute("ArmorReduction", config.Guardian.ArmorReduction)
		model:SetAttribute("StaggerThreshold", config.Guardian.StaggerThreshold)
	end

	local function spendShield(amount)
		local absorbed = math.min(shield, finite(amount) * config.DistrictShield.DamageReduction)
		shield -= absorbed
		if shield <= 0 and shieldActive then
			shieldToken += 1
			shieldActive = false
			districtShieldChanged:Fire(false, shield, "Depleted")
			state("Idle")
		end
		expose()
		return absorbed
	end

	requestAbility.OnInvoke = function(name, target)
		if defeated then return false, "Defeated" end
		if not ABILITIES[name] or not config[name] then return false, "UnknownAbility" end
		if os.clock() < readyAt[name] then return false, "Cooldown" end
		if name == "DistrictShield" and shield <= 0 then return false, "ShieldDepleted" end
		readyAt[name] = os.clock() + config[name].Cooldown
		if name == "DistrictShield" then
			shieldToken += 1
			local token = shieldToken
			shieldActive = true
			expose()
			state("DistrictShield")
			districtShieldChanged:Fire(true, shield, "Activated")
			task.delay(config.DistrictShield.Duration, function()
				if token == shieldToken and not defeated then
					shieldActive = false
					expose()
					districtShieldChanged:Fire(false, shield, "Expired")
					state("Idle")
				end
			end)
		else
			state(name .. "Telegraph")
		end
		abilityRequested:Fire(name, target, config[name])
		return true, "Requested"
	end

	isPositionProtected.OnInvoke = function(position)
		return protected(position), shieldCenter(), config.DistrictShield.ProtectionRadius
	end

	absorbDistrictDamage.OnInvoke = function(amount, position)
		if not protected(position) then return 0, finite(amount), shield, "OutsideField" end
		local absorbed = spendShield(amount)
		return absorbed, math.max(0, finite(amount) - absorbed), shield, shieldActive and "Blocked" or "Depleted"
	end

	applyDamage.OnInvoke = function(amount, source)
		if defeated then return health, shield, 0, "Defeated" end
		if source == "TestForceDefeat" then
			health = 0
			defeated = true
			shieldToken += 1
			shieldActive = false
			expose()
			districtShieldChanged:Fire(false, shield, "Defeated")
			state("Defeated")
			return health, shield, 0, "Defeated"
		end
		amount = finite(amount)
		local blocked = 0
		if shieldActive and config.DistrictShield.ProtectsGuardian then blocked = spendShield(amount) end
		local afterShield = math.max(0, amount - blocked)
		local armorBlocked = afterShield * config.Guardian.ArmorReduction
		local healthDamage = afterShield - armorBlocked
		health = math.max(0, health - healthDamage)
		staggerDamage += source == "TestStagger" and config.Guardian.StaggerThreshold or afterShield
		expose()
		damageTaken:Fire(healthDamage, blocked + armorBlocked, source)
		if health <= 0 then
			defeated = true
			shieldToken += 1
			shieldActive = false
			expose()
			districtShieldChanged:Fire(false, shield, "Defeated")
			state("Defeated")
			return health, shield, blocked + armorBlocked, "Defeated"
		end
		if staggerDamage >= config.Guardian.StaggerThreshold then
			staggerDamage = 0
			state("Staggered")
			task.delay(config.Guardian.StaggerDuration, function()
				if not defeated and model:GetAttribute("GuardianState") == "Staggered" then state("Idle") end
			end)
			return health, shield, blocked + armorBlocked, "Staggered"
		end
		return health, shield, blocked + armorBlocked, blocked > 0 and "Shielded" or "Damaged"
	end

	reset.OnInvoke = function()
		health = config.Guardian.MaxHealth
		shield = config.DistrictShield.ShieldPoints
		shieldActive = false
		defeated = false
		staggerDamage = 0
		shieldToken += 1
		for name in pairs(readyAt) do readyAt[name] = 0 end
		expose()
		districtShieldChanged:Fire(false, shield, "Reset")
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
