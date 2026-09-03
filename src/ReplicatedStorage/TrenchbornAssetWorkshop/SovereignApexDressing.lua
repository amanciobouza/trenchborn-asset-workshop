local specification = require(script.Parent:WaitForChild("SovereignApexSpecification"))

local Dressing = {}
local COLORS = specification.Palette

local ENERGY_ACCENT = {
	VisorSensor = true,
	ChestVLeft = true,
	ChestVRight = true,
	ApexEnergyBlade = true,
	LeftPredatorSensor = true,
	RightPredatorSensor = true,
}

local ENERGY_HOT = {
	SovereignLockCore = true,
	LanceEmitterCore = true,
	BladeEdgeLeft = true,
	BladeEdgeRight = true,
}

local DRONE_REFERENCE_IDS = {
	LeftDroneInner = "L1",
	RightDroneInner = "R1",
	LeftDroneOuter = "L2",
	RightDroneOuter = "R2",
	LeftDroneLower = "L3",
	RightDroneLower = "R3",
}

local function contains(name, fragments)
	for _, fragment in ipairs(fragments) do
		if string.find(name, fragment, 1, true) then return true end
	end
	return false
end

local function markEnergyPart(item, color, role)
	item.Color = color
	item.Material = Enum.Material.Neon
	item.Reflectance = 0
	item:SetAttribute("EnergyChannel", "SovereignViolet")
	item:SetAttribute("EnergyRole", role)
	item:SetAttribute("LightState", "Idle")
	item:SetAttribute("IdleColor", color)
end

local function dressPart(item)
	if item.Transparency >= 1 then return end
	local name = item.Name

	if ENERGY_HOT[name] then
		markEnergyPart(item, COLORS.ChargeHot, "ChargeFocus")
		return
	end
	if ENERGY_ACCENT[name] then
		markEnergyPart(item, COLORS.Accent, "PrimaryChannel")
		return
	end

	if contains(name, {
		"Bearing", "Joint", "Hub", "Axle", "Spine", "Mandible", "Recess",
		"ClawBase", "EmitterRing", "Dark", "Hydraulic",
	}) then
		item.Color = COLORS.DarkMetal
		item.Material = Enum.Material.Metal
		item.Reflectance = 0.012
		return
	end

	if contains(name, {
		"Plate", "Crown", "Brow", "CheekGuard", "OuterArmor", "ShoulderCap",
		"FootMain", "Toe", "Heel",
	}) then
		item.Color = COLORS.Armor
		item.Material = Enum.Material.Metal
		item.Reflectance = 0.045
		return
	end

	item.Material = Enum.Material.Metal
	item.Reflectance = math.min(item.Reflectance, 0.022)
end

local function enforceRuntimeBudget(model)
	local removedLights, removedEmitters, scaledLabels = 0, 0, 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("Light") then
			removedLights += 1
			item:Destroy()
		elseif item:IsA("ParticleEmitter") then
			removedEmitters += 1
			item:Destroy()
		elseif item:IsA("TextLabel") then
			item.TextScaled = true
			scaledLabels += 1
		end
	end
	model:SetAttribute("RemovedPermanentLights", removedLights)
	model:SetAttribute("RemovedPermanentParticleEmitters", removedEmitters)
	model:SetAttribute("ScaledTextLabelCount", scaledLabels)
end

local function assignDroneReferences(model)
	local assigned = 0
	for droneName, referenceId in pairs(DRONE_REFERENCE_IDS) do
		local drone = model:FindFirstChild(droneName, true)
		assert(drone and drone:IsA("Model"), "Missing Sovereign drone " .. droneName)
		drone:SetAttribute("ReferenceId", referenceId)
		drone:SetAttribute("DressingStyle", "ArmoredPredatorWedge")
		assigned += 1
	end
	model:SetAttribute("DroneReferenceCount", assigned)
end

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "SovereignApexDressing.Apply expects a Model")
	assert(model:GetAttribute("QualityGateB") == "Approved", "Sovereign geometry must pass Quality Gate B before dressing")

	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then dressPart(item) end
	end
	assignDroneReferences(model)
	enforceRuntimeBudget(model)

	model:SetAttribute("PipelinePhase", 5)
	model:SetAttribute("DressingApplied", true)
	model:SetAttribute("DressingVersion", 1)
	model:SetAttribute("DressingStyle", "ApexPredatorViolet")
	model:SetAttribute("DressingUsesAdditionalParts", false)
	model:SetAttribute("PermanentLights", 0)
	model:SetAttribute("PermanentParticleEmitters", 0)
	model:SetAttribute("TextLabelsScaled", true)
	return model
end

return Dressing
