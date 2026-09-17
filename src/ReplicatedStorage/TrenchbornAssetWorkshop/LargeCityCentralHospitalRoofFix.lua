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

local function movePart(folder, name, position)
	local item = folder:FindFirstChild(name)
	if item and item:IsA("BasePart") then
		item.Position = position
	end
	return item
end

local function createBlock(parent, name, size, position, color, material)
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

function RoofFix.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityCentralHospitalRoofFix.Apply expects a Model")

	local roof = requireRoof(model)
	if not roof then return model end

	-- Secondary-wing roof surface is Y=24.9. Add a real service plinth first so
	-- the equipment reads as deliberately roof-mounted rather than floating.
	local oldPlinth = roof:FindFirstChild("RoofPlantServicePlinth")
	if oldPlinth then oldPlinth:Destroy() end
	local plinth = createBlock(
		roof,
		"RoofPlantServicePlinth",
		Vector3.new(36, 0.6, 18),
		Vector3.new(47, 25.2, 12),
		COLORS.Concrete,
		Enum.Material.Concrete
	)
	plinth:SetAttribute("RoofSupport", "SecondaryWingRoof")

	-- Re-use the original HVAC units, but place every unit directly on the
	-- service plinth. Bottom = 25.5, exactly matching the plinth top.
	local hvacPositions = {
		Vector3.new(34, 26.7, 8),
		Vector3.new(44, 26.7, 8),
		Vector3.new(54, 26.7, 8),
		Vector3.new(39, 26.7, 16),
		Vector3.new(50, 26.7, 16),
	}
	for index, position in ipairs(hvacPositions) do
		local unit = movePart(roof, "HVACUnit" .. index, position)
		local cap = movePart(roof, "HVACCap" .. index, position + Vector3.new(0, 1.35, 0))
		if unit then unit:SetAttribute("RoofSupport", "RoofPlantServicePlinth") end
		if cap then cap:SetAttribute("RoofSupport", "HVACUnit" .. index) end
	end

	-- Vent stacks are vertical cylinders. Their 4.5-stud length is vertical after
	-- the original 90-degree Z rotation; set their bottoms exactly on the plinth.
	local ventPositions = {
		Vector3.new(31, 27.75, 19),
		Vector3.new(37, 27.75, 19),
		Vector3.new(57, 27.75, 19),
		Vector3.new(63, 27.75, 19),
	}
	for index, position in ipairs(ventPositions) do
		local vent = roof:FindFirstChild("VentStack" .. index)
		if vent and vent:IsA("BasePart") then
			vent.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
			vent:SetAttribute("RoofSupport", "RoofPlantServicePlinth")
		end
	end

	-- Restore the helipad perimeter bars, but lower them so their bottoms touch
	-- the deck top (Y=75.7) instead of hovering above it.
	for _, name in ipairs({"HelipadRailX-12.5", "HelipadRailX16.5", "HelipadRailZ-6", "HelipadRailZ23"}) do
		local rail = roof:FindFirstChild(name)
		if rail and rail:IsA("BasePart") then
			rail.Position = Vector3.new(rail.Position.X, 76.3, rail.Position.Z)
			rail:SetAttribute("RoofSupport", "HelipadDeck")
		end
	end

	-- The original access box was too large for the narrow margin around the
	-- landing pad. Turn it into a compact rooftop service core and place it on the
	-- same supported service plinth as the mechanical plant.
	local access = roof:FindFirstChild("HelipadAccessCore")
	if access and access:IsA("BasePart") then
		access.Name = "RooftopServiceCore"
		access.Size = Vector3.new(7, 4.5, 6)
		access.Position = Vector3.new(63, 27.75, 8)
		access:SetAttribute("RoofSupport", "RoofPlantServicePlinth")
	end

	model:SetAttribute("GeometryRevision", "CentralHospital-v4-RoofPlantIntegrated")
	model:SetAttribute("RoofPlantDeferredToDressing", false)
	model:SetAttribute("RoofPlantIntegrated", true)
	model:SetAttribute("FreestandingRoofGeometryRemoved", false)
	return model
end

return RoofFix
