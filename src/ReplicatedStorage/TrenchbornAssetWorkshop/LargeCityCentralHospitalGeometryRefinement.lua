local Refinement = {}

local function requirePart(model, name)
	local item = model:FindFirstChild(name, true)
	assert(item and item:IsA("BasePart"), "Missing hospital geometry part: " .. name)
	return item
end

local function moveZ(part, z)
	local rotation = part.CFrame - part.CFrame.Position
	local position = part.Position
	part.CFrame = CFrame.new(position.X, position.Y, z) * rotation
end

local function setDepth(part, depth)
	part.Size = Vector3.new(part.Size.X, part.Size.Y, depth)
end

function Refinement.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityCentralHospitalGeometryRefinement.Apply expects a Model")

	-- Remove the decorative lower-tower side caps entirely. They were originally
	-- embedded into the main tower volume and later moved outward as fins, but the
	-- junction still produced an unpleasant overlapping-wall read at grazing angles.
	-- The main tower mass already has a complete structural side wall, so keeping a
	-- second wall layer is unnecessary.
	for _, name in ipairs({"TowerLowerLeftCap", "TowerLowerRightCap"}) do
		local cap = model:FindFirstChild(name, true)
		if cap then cap:Destroy() end
	end

	-- The limestone tower spine is the most-forward structural layer at about
	-- local Z = -7.6. Keep the medical cross almost a full stud farther forward,
	-- and make the two bars thin in depth so neither the wall nor the two cross
	-- pieces can visually fight each other.
	local towerVertical = requirePart(model, "TowerCrossVertical")
	setDepth(towerVertical, 0.28)
	moveZ(towerVertical, -8.72)
	towerVertical.CanCollide = false

	local towerHorizontal = requirePart(model, "TowerCrossHorizontal")
	setDepth(towerHorizontal, 0.28)
	moveZ(towerHorizontal, -8.80)
	towerHorizontal.CanCollide = false

	-- Apply the same generous facade stand-off to the emergency cross.
	local emergencyVertical = requirePart(model, "EmergencyCrossVertical")
	setDepth(emergencyVertical, 0.26)
	moveZ(emergencyVertical, -19.35)
	emergencyVertical.CanCollide = false

	local emergencyHorizontal = requirePart(model, "EmergencyCrossHorizontal")
	setDepth(emergencyHorizontal, 0.26)
	moveZ(emergencyHorizontal, -19.42)
	emergencyHorizontal.CanCollide = false

	model:SetAttribute("GeometryRevision", "CentralHospital-v3-NoFacadeOverlap")
	model:SetAttribute("FacadeStandOffPass", true)
	model:SetAttribute("LowerTowerSideCapsRemoved", true)
	return model
end

return Refinement
