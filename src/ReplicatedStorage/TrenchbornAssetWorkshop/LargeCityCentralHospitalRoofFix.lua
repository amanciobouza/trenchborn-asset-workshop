local RoofFix = {}

local COLORS = {
	Concrete = Color3.fromRGB(211, 212, 202),
}

local function requireRoof(model)
	local groups = model:FindFirstChild("DestructionGroups")
	return groups and groups:FindFirstChild("D7_HelipadRoofPlant")
end

local function createBlock(parent, name, size, position, color, material)
	local existing = parent:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end

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

local function findPart(parent, name)
	local item = parent:FindFirstChild(name)
	return item and item:IsA("BasePart") and item or nil
end

function RoofFix.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityCentralHospitalRoofFix.Apply expects a Model")

	local roof = requireRoof(model)
	if not roof then
		return model
	end

	-- Main upper-tower roof footprint is approximately X=-19..23 and Z=-7.75..24.75.
	-- Keep every rooftop object inside that footprint so nothing appears to float
	-- beyond the building edge.

	-- Shift and slightly shrink the helipad to the left to create a supported
	-- mechanical-service strip on the right side of the same roof.
	local deck = findPart(roof, "HelipadDeck")
	if deck then
		deck.Size = Vector3.new(27, 1.0, 27)
		deck.Position = Vector3.new(-3, 75.2, 8.5)
	end

	local raisedPad = findPart(roof, "HelipadRaisedPad")
	if raisedPad then
		raisedPad.Size = Vector3.new(21, 0.45, 21)
		raisedPad.Position = Vector3.new(-3, 75.95, 8.5)
	end

	-- Dedicated service plinth fully supported by the main upper roof.
	local plinth = createBlock(
		roof,
		"RoofPlantServicePlinth",
		Vector3.new(10, 0.6, 26),
		Vector3.new(17, 75.1, 8.5),
		COLORS.Concrete,
		Enum.Material.Concrete
	)
	plinth:SetAttribute("RoofSupport", "MainTowerUpperRoof")

	-- Five compact HVAC units, all inside the plinth footprint.
	local hvacPositions = {
		Vector3.new(14.5, 76.6, 0),
		Vector3.new(19.5, 76.6, 0),
		Vector3.new(14.5, 76.6, 8),
		Vector3.new(19.5, 76.6, 8),
		Vector3.new(17, 76.6, 16),
	}
	for index, position in ipairs(hvacPositions) do
		local unit = findPart(roof, "HVACUnit" .. index)
		local cap = findPart(roof, "HVACCap" .. index)
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

	-- Vent stacks also sit on the same service plinth.
	local ventPositions = {
		Vector3.new(14, 77.65, -3),
		Vector3.new(20, 77.65, -3),
		Vector3.new(14, 77.65, 19),
		Vector3.new(20, 77.65, 19),
	}
	for index, position in ipairs(ventPositions) do
		local vent = findPart(roof, "VentStack" .. index)
		if vent then
			vent.Size = Vector3.new(4.5, 0.7, 0.7)
			vent.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
			vent:SetAttribute("RoofSupport", "RoofPlantServicePlinth")
		end
	end

	-- Compact rooftop service core on the same supported strip.
	local access = findPart(roof, "RooftopServiceCore") or findPart(roof, "HelipadAccessCore")
	if access then
		access.Name = "RooftopServiceCore"
		access.Size = Vector3.new(5, 4.5, 5)
		access.Position = Vector3.new(17, 77.55, 20)
		access:SetAttribute("RoofSupport", "RoofPlantServicePlinth")
	end

	-- Match perimeter bars to the shifted helipad and keep them touching the deck.
	local railSpecs = {
		["HelipadRailX-12.5"] = {
			Size = Vector3.new(0.35, 1.2, 27),
			Position = Vector3.new(-16.5, 76.3, 8.5),
		},
		["HelipadRailX16.5"] = {
			Size = Vector3.new(0.35, 1.2, 27),
			Position = Vector3.new(10.5, 76.3, 8.5),
		},
		["HelipadRailZ-6"] = {
			Size = Vector3.new(27, 1.2, 0.35),
			Position = Vector3.new(-3, 76.3, -5),
		},
		["HelipadRailZ23"] = {
			Size = Vector3.new(27, 1.2, 0.35),
			Position = Vector3.new(-3, 76.3, 22),
		},
	}
	for name, spec in pairs(railSpecs) do
		local rail = findPart(roof, name)
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
