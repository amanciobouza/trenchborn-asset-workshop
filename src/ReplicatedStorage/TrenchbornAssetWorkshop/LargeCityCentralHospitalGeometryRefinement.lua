local Refinement = {}

local function requirePart(model, name)
	local item = model:FindFirstChild(name, true)
	assert(item and item:IsA("BasePart"), "Missing hospital geometry part: " .. name)
	return item
end

local function movePart(part, position)
	local rotation = part.CFrame - part.CFrame.Position
	part.CFrame = CFrame.new(position) * rotation
end

local function setDepth(part, depth)
	part.Size = Vector3.new(part.Size.X, part.Size.Y, depth)
end

local function ensureMullion(parent, name, position, height, z, template)
	local item = parent:FindFirstChild(name)
	if not item then
		item = template:Clone()
		item.Name = name
		item.Parent = parent
	end
	item.Size = Vector3.new(0.32, height, 0.30)
	movePart(item, Vector3.new(position, item.Position.Y, z))
	return item
end

function Refinement.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityCentralHospitalGeometryRefinement.Apply expects a Model")

	-- The main tower already has complete structural side walls. Remove the old
	-- decorative caps so there is never a second almost-coplanar wall surface.
	for _, name in ipairs({"TowerLowerLeftCap", "TowerLowerRightCap"}) do
		local cap = model:FindFirstChild(name, true)
		if cap then cap:Destroy() end
	end

	-- Centre the atrium on the tower masses and place the glass fully OUTSIDE the
	-- structural facade. The lower central spine reaches to about Z=-10.70 and the
	-- upper spine to about Z=-7.60. The glass rear faces now clear those planes by
	-- a few hundredths of a stud instead of being buried inside the building.
	local lowerAtrium = requirePart(model, "LowerVerticalAtrium")
	setDepth(lowerAtrium, 0.42)
	movePart(lowerAtrium, Vector3.new(0, lowerAtrium.Position.Y, -10.95))

	local lowerLeft = requirePart(model, "LowerAtriumMullion-3")
	local lowerRight = requirePart(model, "LowerAtriumMullion1")
	setDepth(lowerLeft, 0.30)
	setDepth(lowerRight, 0.30)
	-- Mullions sit just in front of the glass rather than penetrating it.
	movePart(lowerLeft, Vector3.new(-2.6, 27, -11.31))
	movePart(lowerRight, Vector3.new(2.6, 27, -11.31))

	local upperAtrium = requirePart(model, "UpperVerticalAtrium")
	setDepth(upperAtrium, 0.42)
	movePart(upperAtrium, Vector3.new(2, upperAtrium.Position.Y, -7.88))

	local upperGroup = upperAtrium.Parent
	local upperLeft = ensureMullion(upperGroup, "UpperAtriumMullionLeft", -0.4, 26, -8.24, lowerLeft)
	movePart(upperLeft, Vector3.new(-0.4, 59, -8.24))
	local upperRight = ensureMullion(upperGroup, "UpperAtriumMullionRight", 4.4, 26, -8.24, lowerRight)
	movePart(upperRight, Vector3.new(4.4, 59, -8.24))

	-- The medical cross sits on top of the upper atrium glazing. Move it forward
	-- together with the glass so it remains facade-mounted instead of becoming
	-- embedded between glass and concrete.
	local towerVertical = requirePart(model, "TowerCrossVertical")
	setDepth(towerVertical, 0.32)
	movePart(towerVertical, Vector3.new(2, 61, -8.28))
	towerVertical.CanCollide = false

	local towerHorizontal = requirePart(model, "TowerCrossHorizontal")
	setDepth(towerHorizontal, 0.24)
	movePart(towerHorizontal, Vector3.new(2, 61, -8.34))
	towerHorizontal.CanCollide = false

	-- The Emergency cross stays above the canopy and close to the facade.
	local emergencyVertical = requirePart(model, "EmergencyCrossVertical")
	setDepth(emergencyVertical, 0.30)
	movePart(emergencyVertical, Vector3.new(-57, 10.95, -18.75))
	emergencyVertical.CanCollide = false

	local emergencyHorizontal = requirePart(model, "EmergencyCrossHorizontal")
	setDepth(emergencyHorizontal, 0.24)
	movePart(emergencyHorizontal, Vector3.new(-57, 10.95, -18.83))
	emergencyHorizontal.CanCollide = false

	model:SetAttribute("GeometryRevision", "CentralHospital-v9-AtriumFacadeStandOff")
	model:SetAttribute("FacadeStandOffPass", true)
	model:SetAttribute("LowerTowerSideCapsRemoved", true)
	model:SetAttribute("AtriumCenteredOnTower", true)
	model:SetAttribute("AtriumMullionsSymmetric", true)
	model:SetAttribute("AtriumGlassOutsideStructure", true)
	model:SetAttribute("TowerCrossFreestanding", false)
	model:SetAttribute("TowerCrossFacadeMounted", true)
	model:SetAttribute("EmergencyCrossClearOfCanopy", true)
	model:SetAttribute("EmergencyCrossFacadeMounted", true)
	return model
end

return Refinement
