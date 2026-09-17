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

	-- Mount the tower cross as a clearly freestanding facade sign. The upper
	-- tower's most-forward structural face is around local Z=-7.6; both cross
	-- bars now sit more than 1.5 studs in front of it. Their front surfaces are
	-- also deliberately staggered to prevent the two red bars fighting each other.
	local towerVertical = requirePart(model, "TowerCrossVertical")
	setDepth(towerVertical, 0.42)
	movePart(towerVertical, Vector3.new(2, 61, -9.35))
	towerVertical.CanCollide = false

	local towerHorizontal = requirePart(model, "TowerCrossHorizontal")
	setDepth(towerHorizontal, 0.34)
	movePart(towerHorizontal, Vector3.new(2, 61, -9.62))
	towerHorizontal.CanCollide = false

	-- Raise the emergency cross above the ambulance canopy and pull it forward.
	-- The canopy top is around Y=8.3, so the entire cross now reads cleanly above
	-- it instead of being hidden by the roof slab from street-level viewpoints.
	local emergencyVertical = requirePart(model, "EmergencyCrossVertical")
	setDepth(emergencyVertical, 0.34)
	movePart(emergencyVertical, Vector3.new(-57, 11.25, -20.05))
	emergencyVertical.CanCollide = false

	local emergencyHorizontal = requirePart(model, "EmergencyCrossHorizontal")
	setDepth(emergencyHorizontal, 0.28)
	movePart(emergencyHorizontal, Vector3.new(-57, 11.25, -20.28))
	emergencyHorizontal.CanCollide = false

	model:SetAttribute("GeometryRevision", "CentralHospital-v5-CrossesFreestanding")
	model:SetAttribute("FacadeStandOffPass", true)
	model:SetAttribute("LowerTowerSideCapsRemoved", true)
	model:SetAttribute("TowerCrossFreestanding", true)
	model:SetAttribute("EmergencyCrossClearOfCanopy", true)
	return model
end

return Refinement
