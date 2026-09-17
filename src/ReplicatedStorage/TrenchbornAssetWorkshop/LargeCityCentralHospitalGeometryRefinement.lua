local Refinement = {}

local function requirePart(model, name)
	local item = model:FindFirstChild(name, true)
	assert(item and item:IsA("BasePart"), "Missing hospital geometry part: " .. name)
	return item
end

local function moveZ(part, z)
	local position = part.Position
	part.CFrame = CFrame.new(position.X, position.Y, z) * (part.CFrame - part.CFrame.Position)
end

function Refinement.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityCentralHospitalGeometryRefinement.Apply expects a Model")

	-- The two lower-tower side caps originally shared the exact outer X planes
	-- with TowerLowerMass. At grazing angles Roblox alternated between both faces.
	-- Turn them into deliberate external fins with a small stand-off instead of
	-- overlapping wall volumes.
	local leftCap = requirePart(model, "TowerLowerLeftCap")
	leftCap.Size = Vector3.new(1.2, 33, 35.0)
	leftCap.CFrame = CFrame.new(-23.55, 27, 7)

	local rightCap = requirePart(model, "TowerLowerRightCap")
	rightCap.Size = Vector3.new(1.2, 33, 35.0)
	rightCap.CFrame = CFrame.new(23.55, 27, 7)

	-- The tower cross was intersecting the projecting limestone spine. Move both
	-- cross bars fully in front of the most-forward structural face.
	moveZ(requirePart(model, "TowerCrossVertical"), -8.05)
	moveZ(requirePart(model, "TowerCrossHorizontal"), -8.08)

	-- Give the emergency cross the same explicit stand-off from its facade.
	moveZ(requirePart(model, "EmergencyCrossVertical"), -18.95)
	moveZ(requirePart(model, "EmergencyCrossHorizontal"), -18.98)

	model:SetAttribute("GeometryRevision", "CentralHospital-v2-ZFightClean")
	model:SetAttribute("FacadeStandOffPass", true)
	return model
end

return Refinement
