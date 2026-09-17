local RoofFix = {}

local COLORS = {
	Concrete = Color3.fromRGB(211, 212, 202),
	Metal = Color3.fromRGB(164, 174, 177),
	DarkMetal = Color3.fromRGB(84, 96, 101),
}

local function requireRoof(model)
	local groups = model:FindFirstChild("DestructionGroups")
	return groups and groups:FindFirstChild("D7_HelipadRoofPlant")
end

local function createBlock(parent, name, size, position, color, material)
	local existing = parent:FindFirstChild(name)
	if existing then existing:Destroy() end
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.Position = position
	item.Color = color
	item.Material = material or Enum.Material.Concrete
	item.Anchored = true
	item.CanCollide = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function requirePart(parent, name)
	local item = parent:FindFirstChild(name)
	return item and item:IsA("BasePart") and item or nil
end

function RoofFix.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityCentralHospitalRoofFix.Apply expects a Model")

	local roof = requireRoof(model)
	if not roof then return model end

	-- Main upper-tower roof: X roughly -19..23, Z roughly -7.75..24.75,
	-- roof top around Y=74.8. Keep every mechanical object INSIDE this footprint.

	-- Move and slightly shrink the helipad to the left, creating a real service
	-- strip on the right side of the SAME roof rather than hanging equipment off a
	-- lower wing or over the building edge.
	local helipadDeck = requirePart(roof, "HelipadDeck")
	if helipadDeck then
		hel ipadDeck = helipadDeck
		hel ipadDeck.Size = Vector3.new(27, 1.0, 27)
		hel ipadDeck.Position = Vector3.new(-3, 75.2, 8.5)
	end

	local raisedPad = requirePart(roof, "HelipadRaisedPad")
	if raisedPad then
		raisedPad.Size = Vector3.new(21, 0.45, 21)
		raisedPad.Position = Vector3.new(-3, 75.95, 8.5)
	end

	-- Supported mechanical-service plinth on the right-hand side of the main roof.
	local plinth = createBlock(
		roof,
		"RoofPlantServicePlinth",
		Vector3.new(10, 0.6, 26),
		Vector3.new(17, 75.1, 8.5),
		COLORS.Concrete,
		Enum.Material.Concrete
	)
	plinth:SetAttribute("RoofSupport", "MainTowerUpperRoof")

	-- Five compact HVAC units, all completely inside the service plinth footprint.
	local hvacPositions = {
		Vector3.new(14.5, 76.6, 0),
		Vector3.new(19.5, 76.6, 0),
		Vector3.new(14.5, 76.6, 8),
		Vector3.new(19.5, 76.6, 8),
		Vector3.new(17, 76.6, 16),
	}
	for index, position in ipairs(hvacPositions) do
		local unit = requirePart(roof, "HVACUnit" .. index)
		local cap = requirePart(roof, "HVACCap" .. index)
		if unit then
			unit.Size = Vector3.new(4, 2.4, 3.5)
			unit.Position = position
			unit:SetAttribute("RoofSupport", "RoofPlantServicePlinth")
		end
		if cap then
			cap.Size = Vector3.new(3.2, 0.3, 2.7)
			cap.Position = position + Vector3.new(0, 1.35, 0)
			cap:SetAttribute("RoofSupport", "HVACUnit" .. index)
		end
	end

	-- Vent stacks now sit between the HVAC units and use the plinth as their base.
	local ventPositions = {
		Vector3.new(14, 77.65, -3),
		Vector3.new(20, 77.65, -3),
		Vector3.new(14, 77.65, 19),
		Vector3.new(20, 77.65, 19),
	}
	for index, position in ipairs(ventPositions) do
		local vent = requirePart(roof, "VentStack" .. index)
		if vent then
			vent.Size = Vector3.new(4.5, 0.7, 0.7)
			vent.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
			vent:SetAttribute("RoofSupport", "RoofPlantServicePlinth")
		end
	end

	-- Compact access/service core at the rear of the same roof strip.
	local access = requirePart(roof, "RooftopServiceCore") or requirePart(roof, "HelipadAccessCore")
	if access then
		access.Name = "RooftopServiceCore"
		access.Size = Vector3.new(5, 4.5, 5)
		access.Position = Vector3.new(17, 77.55, 20)
		access:SetAttribute("RoofSupport", "RoofPlantServicePlinth")
	end

	-- Rebuild the helipad perimeter bars to match the shifted/shrunk deck and
	-- ensure their bottoms touch the deck top rather than hovering.
	local railSpecs = {
		["HelipadRailX-12.5"] = {Size = Vector3.new(0.35, 1.2, 27), Position = Vector3.new(-16.5, 76.3, 8.5)},
		["HelipadRailX16.5"] = {Size = Vector3.new(0.35, 1.2, 27), Position = Vector3.new(10.5, 76.3, 8.5)},
		["HelipadRailZ-6"] = {Size = Vector3.new(27, 1.2, 0.35), Position = Vector3.new(-3, 76.3, -5)},
		["HelipadRailZ23"] = {Size = Vector3.new(27, 1.2, 0.35), Position = Vector3.new(-3, 76.3, 22)},
	}
	for name, spec in pairs(railSpecs) do
		local rail = requirePart(roof, name)
		if rail then
			rail.Size = spec.Size
			rail.Position = spec.Position
			rail:SetAttribute("RoofSupport", "HelipadDeck")
		end
	end

	model:SetAttribute("GeometryRevision", "CentralHospital-v5-RoofPlantOnMainRoof")
	model:SetAttribute("RoofPlantIntegrated", true)
	model:SetAttribute("RoofPlantInsideMainRoofFootprint", true)
	model:SetAttribute("FreestandingRoofGeometryRemoved", false)
	return model
end

return RoofFix
