local RoofFix = {}

local function movePart(folder, name, position)
	local item = folder:FindFirstChild(name)
	if item and item:IsA("BasePart") then
		item.Position = position
	end
	return item
end

function RoofFix.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityCentralHospitalRoofFix.Apply expects a Model")

	local groups = model:FindFirstChild("DestructionGroups")
	local roof = groups and groups:FindFirstChild("D7_HelipadRoofPlant")
	if not roof then return model end

	-- The first Golden Master placed roof-plant equipment outside the supporting
	-- roof footprint. Keep the helipad clean and relocate all plant onto the
	-- Secondary Wing roof, where every unit visibly sits on structural geometry.
	local hvacPositions = {
		Vector3.new(34, 26.1, 13),
		Vector3.new(45, 26.1, 13),
		Vector3.new(56, 26.1, 13),
		Vector3.new(39.5, 26.1, 20),
		Vector3.new(51.5, 26.1, 20),
	}
	for index, position in ipairs(hvacPositions) do
		local unit = movePart(roof, "HVACUnit" .. index, position)
		local cap = movePart(roof, "HVACCap" .. index, position + Vector3.new(0, 1.35, 0))
		if unit then unit:SetAttribute("RoofSupport", "SecondaryWingRoof") end
		if cap then cap:SetAttribute("RoofSupport", "SecondaryWingRoof") end
	end

	local ventPositions = {
		Vector3.new(30, 27.2, 20),
		Vector3.new(35, 27.2, 20),
		Vector3.new(61, 27.2, 20),
		Vector3.new(66, 27.2, 20),
	}
	for index, position in ipairs(ventPositions) do
		local vent = roof:FindFirstChild("VentStack" .. index)
		if vent and vent:IsA("BasePart") then
			vent.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
			vent:SetAttribute("RoofSupport", "SecondaryWingRoof")
		end
	end

	-- Keep the helipad access core entirely on the main tower roof instead of
	-- hanging beyond its west edge.
	local access = movePart(roof, "HelipadAccessCore", Vector3.new(-14.5, 76.5, 13))
	if access then access:SetAttribute("RoofSupport", "MainTowerRoof") end

	model:SetAttribute("GeometryRevision", "CentralHospital-v2-RoofPlantSupported")
	model:SetAttribute("RoofPlantSupportFix", true)
	return model
end

return RoofFix
