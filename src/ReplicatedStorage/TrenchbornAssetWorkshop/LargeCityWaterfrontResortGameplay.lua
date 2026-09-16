local CollectionService = game:GetService("CollectionService")

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

local function visibleParts(root)
	local result = {}
	for _, item in ipairs(root:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			table.insert(result, item)
		end
	end
	return result
end

local function darker(color)
	return Color3.new(color.R * 0.38, color.G * 0.38, color.B * 0.38)
end

function Gameplay.Attach(model, config)
	assert(model and model:IsA("Model"), "LargeCityWaterfrontResortGameplay.Attach expects a Model")

	local old = model:FindFirstChild("Gameplay")
	if old then old:Destroy() end
	local oldRuin = model:FindFirstChild(config.RuinFolderName)
	if oldRuin then oldRuin:Destroy() end

	local groupsFolder = model:FindFirstChild("DestructionGroups")
	assert(groupsFolder, "DestructionGroups missing from resort model")

	local api = Instance.new("Folder")
	api.Name = "Gameplay"
	api.Parent = model

	local applyDamage = bindFunction(api, "ApplyDamage")
	local reset = bindFunction(api, "Reset")
	local damageTaken = bindEvent(api, "DamageTaken")
	local groupDestroyed = bindEvent(api, "GroupDestroyed")
	local buildingDestroyed = bindEvent(api, "BuildingDestroyed")
	local stateChanged = bindEvent(api, "StateChanged")

	local ruinRoot = Instance.new("Folder")
	ruinRoot.Name = config.RuinFolderName
	ruinRoot.Parent = model

	local groups = {}
	local snapshots = {}
	local buildingIsDestroyed = false
	local currentState = "Intact"

	for orderIndex, groupName in ipairs(config.DestructionOrder) do
		local group = groupsFolder:FindFirstChild(groupName)
		local def = config.Groups[groupName]
		assert(group and def, "Missing destruction group/config: " .. groupName)
		local parts = visibleParts(group)
		groups[groupName] = {
			Folder = group,
			Parts = parts,
			Health = def.MaxHealth,
			MaxHealth = def.MaxHealth,
			Broken = false,
		}
		group:SetAttribute("DestructionIndex", orderIndex)
		group:SetAttribute("Health", def.MaxHealth)
		group:SetAttribute("MaxHealth", def.MaxHealth)
		group:SetAttribute("Destroyed", false)
		for _, part in ipairs(parts) do
			snapshots[part] = {
				Transparency = part.Transparency,
				CanCollide = part.CanCollide,
				Color = part.Color,
				Material = part.Material,
				CFrame = part.CFrame,
			}
		end
	end

	local function healthTotal()
		local total = 0
		for _, state in pairs(groups) do total += state.Health end
		return total
	end

	local function setState()
		local health = healthTotal()
		local ratio = health / config.MaxHealth
		local nextState = "Intact"
		if health <= 0 then
			nextState = "Destroyed"
		elseif ratio <= config.DamageStateThresholds.Critical then
			nextState = "Critical"
		elseif ratio <= config.DamageStateThresholds.Heavy then
			nextState = "Heavy"
		elseif ratio <= config.DamageStateThresholds.Light then
			nextState = "Light"
		end
		model:SetAttribute("Health", health)
		model:SetAttribute("DamageState", nextState)
		if currentState ~= nextState then
			currentState = nextState
			stateChanged:Fire(nextState, health)
		end
	end

	local function breakVisual(groupName)
		local state = groups[groupName]
		if not state or state.Broken then return end
		state.Broken = true
		state.Health = 0
		state.Folder:SetAttribute("Health", 0)
		state.Folder:SetAttribute("Destroyed", true)

		local anchorPosition = nil
		for index, part in ipairs(state.Parts) do
			anchorPosition = anchorPosition or part.Position
			if part.Material == Enum.Material.Glass or index % 4 == 0 then
				part.Transparency = 1
				part.CanCollide = false
			else
				part.Color = darker(part.Color)
				part.Material = Enum.Material.Concrete
				part.CFrame = part.CFrame * CFrame.Angles(0, 0, math.rad((index % 5 - 2) * 2))
			end
		end

		if anchorPosition then
			local groupRuin = Instance.new("Folder")
			groupRuin.Name = groupName
			groupRuin.Parent = ruinRoot
			local fx = Instance.new("Part")
			fx.Name = "DamageFX"
			fx.Size = Vector3.new(1, 1, 1)
			fx.Position = anchorPosition
			fx.Transparency = 1
			fx.Anchored = true
			fx.CanCollide = false
			fx.CanQuery = false
			fx.Parent = groupRuin
			local smoke = Instance.new("Smoke")
			smoke.Color = Color3.fromRGB(70, 70, 70)
			smoke.Opacity = 0.3
			smoke.RiseVelocity = 4
			smoke.Size = 5
			smoke.Parent = fx
			local flame = Instance.new("Fire")
			flame.Color = Color3.fromRGB(255, 137, 45)
			flame.SecondaryColor = Color3.fromRGB(255, 73, 24)
			flame.Heat = 4
			flame.Size = 2.2
			flame.Parent = fx
		end
		groupDestroyed:Fire(groupName, healthTotal())
	end

	local function hitGroup(groupName, amount)
		local state = groups[groupName]
		if not state or state.Broken then return 0, amount end
		local applied = math.min(state.Health, amount)
		state.Health -= applied
		state.Folder:SetAttribute("Health", state.Health)
		if state.Health <= 0 then breakVisual(groupName) end
		return applied, amount - applied
	end

	applyDamage.OnInvoke = function(amount, preferredGroup)
		amount = math.max(0, tonumber(amount) or 0)
		if buildingIsDestroyed or amount == 0 then
			return healthTotal(), preferredGroup, currentState
		end
		local remaining = amount
		local appliedTotal = 0
		local lastGroup = preferredGroup
		if preferredGroup and groups[preferredGroup] then
			local applied
			applied, remaining = hitGroup(preferredGroup, remaining)
			appliedTotal += applied
		else
			for _, groupName in ipairs(config.DestructionOrder) do
				if remaining <= 0 then break end
				local applied
				applied, remaining = hitGroup(groupName, remaining)
				if applied > 0 then
					appliedTotal += applied
					lastGroup = groupName
				end
			end
		end
		setState()
		local health = healthTotal()
		damageTaken:Fire(appliedTotal, lastGroup, health)
		if health <= 0 and not buildingIsDestroyed then
			buildingIsDestroyed = true
			model:SetAttribute("Destroyed", true)
			buildingDestroyed:Fire(config.DestructionReward)
		end
		return health, lastGroup, currentState
	end

	reset.OnInvoke = function()
		buildingIsDestroyed = false
		currentState = "Intact"
		model:SetAttribute("Destroyed", false)
		for _, state in pairs(groups) do
			state.Health = state.MaxHealth
			state.Broken = false
			state.Folder:SetAttribute("Health", state.MaxHealth)
			state.Folder:SetAttribute("Destroyed", false)
			for _, part in ipairs(state.Parts) do
				local snapshot = snapshots[part]
				if snapshot then
					part.Transparency = snapshot.Transparency
					part.CanCollide = snapshot.CanCollide
					part.Color = snapshot.Color
					part.Material = snapshot.Material
					part.CFrame = snapshot.CFrame
				end
			end
		end
		ruinRoot:ClearAllChildren()
		setState()
		return true
	end

	model:SetAttribute("Health", config.MaxHealth)
	model:SetAttribute("MaxHealth", config.MaxHealth)
	model:SetAttribute("EnergyType", config.EnergyType)
	model:SetAttribute("CityTier", config.CityTier)
	model:SetAttribute("BuildingType", config.BuildingType)
	model:SetAttribute("DestructionReward", config.DestructionReward)
	model:SetAttribute("RuinFolderName", config.RuinFolderName)
	model:SetAttribute("DamageState", "Intact")
	model:SetAttribute("Destroyed", false)
	model:SetAttribute("PipelinePhase", 6)
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("QualityGateC", "Pending")
	model:SetAttribute("DamageAdapterContract", "ApplyDamage(amount, optionalGroupName)")
	model:SetAttribute("GameplayUsesHeartbeatLoop", false)

	if not CollectionService:HasTag(model, "DestructibleBuilding") then
		CollectionService:AddTag(model, "DestructibleBuilding")
	end
	return api
end

return Gameplay
