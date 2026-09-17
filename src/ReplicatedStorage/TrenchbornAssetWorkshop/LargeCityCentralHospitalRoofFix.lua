local RoofFix = {}

function RoofFix.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityCentralHospitalRoofFix.Apply expects a Model")

	local groups = model:FindFirstChild("DestructionGroups")
	local roof = groups and groups:FindFirstChild("D7_HelipadRoofPlant")
	if not roof then return model end

	-- Keep Phase 4 focused on clean architectural geometry. The individual HVAC
	-- boxes, vent stacks, access block and perimeter bars read as unsupported or
	-- floating from gameplay distance, even when their numeric bottoms touched a
	-- roof plane. Remove all freestanding roof equipment for the Golden Master.
	-- Roof/service detail can return later as integrated Dressing geometry.
	local removeNames = {
		"HelipadAccessCore",
		"HelipadRailX-12.5",
		"HelipadRailX16.5",
		"HelipadRailZ-6",
		"HelipadRailZ23",
	}

	for _, name in ipairs(removeNames) do
		local item = roof:FindFirstChild(name)
		if item then item:Destroy() end
	end

	for index = 1, 5 do
		for _, prefix in ipairs({"HVACUnit", "HVACCap"}) do
			local item = roof:FindFirstChild(prefix .. index)
			if item then item:Destroy() end
		end
	end

	for index = 1, 4 do
		local vent = roof:FindFirstChild("VentStack" .. index)
		if vent then vent:Destroy() end
	end

	-- Only the two supported helipad slabs remain in D7 during geometry review.
	model:SetAttribute("GeometryRevision", "CentralHospital-v3-CleanRoof")
	model:SetAttribute("RoofPlantDeferredToDressing", true)
	model:SetAttribute("FreestandingRoofGeometryRemoved", true)
	return model
end

return RoofFix
