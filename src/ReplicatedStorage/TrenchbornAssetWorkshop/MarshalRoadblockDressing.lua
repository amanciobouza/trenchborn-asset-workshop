local Dressing = {}

local COLORS = {
	Chassis = Color3.fromRGB(22, 29, 36),
	Body = Color3.fromRGB(54, 68, 80),
	Armor = Color3.fromRGB(176, 190, 199),
	Accent = Color3.fromRGB(63, 199, 255),
	DarkMetal = Color3.fromRGB(32, 40, 48),
}

local function isNamed(item, fragments)
	for _, fragment in ipairs(fragments) do
		if string.find(item.Name, fragment, 1, true) then return true end
	end
	return false
end

local function dressPart(item)
	if item.Transparency >= 1 then return end

	if item.Material == Enum.Material.Neon or isNamed(item, {
		"VisorSensor", "ShieldAngle", "StatusChannel", "MuzzleCore", "Status",
	}) then
		item.Color = COLORS.Accent
		item.Material = Enum.Material.Neon
		item.Reflectance = 0
		return
	end

	if isNamed(item, {"Bearing", "Axle", "Hydraulic", "Brace", "ArmLink", "MuzzleRing", "LowerKeel"}) then
		item.Color = COLORS.DarkMetal
		item.Material = Enum.Material.Metal
		item.Reflectance = 0.02
		return
	end

	if isNamed(item, {"Plate", "Cap", "Crown", "Rail", "Brow", "FootMain", "KneeGuard"}) then
		item.Color = COLORS.Armor
		item.Material = Enum.Material.Metal
		item.Reflectance = 0.06
		return
	end

	if isNamed(item, {"Wing", "Housing", "Cartridge", "Forearm", "UpperArm"}) then
		item.Color = COLORS.Body
		item.Material = Enum.Material.Metal
		item.Reflectance = 0.025
		return
	end

	item.Material = Enum.Material.Metal
	item.Reflectance = math.min(item.Reflectance, 0.03)
end

local function enforceRuntimeBudget(model)
	local lights = 0
	local emitters = 0
	local labels = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("Light") then
			lights += 1
			item:Destroy()
		elseif item:IsA("ParticleEmitter") then
			emitters += 1
			item:Destroy()
		elseif item:IsA("TextLabel") then
			labels += 1
			item.TextScaled = true
		end
	end
	model:SetAttribute("RemovedPermanentLights", lights)
	model:SetAttribute("RemovedPermanentParticleEmitters", emitters)
	model:SetAttribute("ScaledTextLabelCount", labels)
end

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "MarshalRoadblockDressing.Apply expects a Model")
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then dressPart(item) end
	end
	enforceRuntimeBudget(model)
	model:SetAttribute("PipelinePhase", 5)
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("DressingApplied", true)
	model:SetAttribute("DressingUsesAdditionalParts", false)
	model:SetAttribute("PermanentLights", 0)
	model:SetAttribute("PermanentParticleEmitters", 0)
	return model
end

return Dressing
