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

function Refinement.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityCentralHospitalGeometryRefinement.Apply expects a Model")

	-- The main tower already has complete structural side walls. Remove the old
	-- decorative caps so there is never a second almost-coplanar wall surface.
	for _, name in ipairs({"TowerLowerLeftCap", "TowerLowerRightCap"}) do
		local cap = model:FindFirstChild(name, true)
		if cap then cap:Destroy() end
	end

	-- Keep the tower cross mounted very close to the facade: enough stand-off to
	-- avoid Z-fighting, but not enough to read as a floating sign. The most-forward
	-- structural face is around local Z=-7.6. With these depths the rear surfaces
	-- sit only about 0.08-0.16 studs away from the wall.
	local towerVertical = requirePart(model, "TowerCrossVertical")
	setDepth(towerVertical, 0.32)
	movePart(towerVertical, Vector3.new(2, 61, -7.84))
	towerVertical.CanCollide = false

	local towerHorizontal = requirePart(model, "TowerCrossHorizontal")
	setDepth(towerHorizontal, 0.24)
	movePart(towerHorizontal, Vector3.new(2, 61, -7.92))
	towerHorizontal.CanCollide = false

	-- The Emergency cross stays above the canopy, but is also mounted close to
	-- the emergency-wing facade instead of being pulled far into the foreground.
	-- Its bottom edge clears the canopy by a small visible margin.
	local emergencyVertical = requirePart(model, "EmergencyCrossVertical")
	setDepth(emergencyVertical, 0.30)
	movePart(emergencyVertical, Vector3.new(-57, 10.95, -18.75))
	emergencyVertical.CanCollide = false

	local emergencyHorizontal = requirePart(model, "EmergencyCrossHorizontal")
	setDepth(emergencyHorizontal, 0.24)
	movePart(emergencyHorizontal, Vector3.new(-57, 10.95, -18.83))
	emergencyHorizontal.CanCollide = false

	model:SetAttribute("GeometryRevision", "CentralHospital-v6-CrossesFacadeMounted")
	model:SetAttribute("FacadeStandOffPass", true)
	model:SetAttribute("LowerTowerSideCapsRemoved", true)
	model:SetAttribute("TowerCrossFreestanding", false)
	model:SetAttribute("TowerCrossFacadeMounted", true)
	model:SetAttribute("EmergencyCrossClearOfCanopy", true)
	model:SetAttribute("EmergencyCrossFacadeMounted", true)
	return model
end

return Refinement
