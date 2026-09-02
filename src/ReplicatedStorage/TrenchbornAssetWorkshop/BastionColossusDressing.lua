local specification = require(script.Parent:WaitForChild("BastionColossusSpecification"))

local Dressing = {}
local COLORS = specification.Palette

local function contains(name, fragments)
	for _, fragment in ipairs(fragments) do
		if string.find(name, fragment, 1, true) then return true end
	end
	return false
end

local function dressPart(item)
	if item.Transparency >= 1 then return end
	local name = item.Name

	if contains(name, {
		"VisorSensor", "EmblemSpine", "EmblemLeftWing", "EmblemRightWing",
		"ShieldNode", "Projector", "RailCoreChannel", "RailMuzzleCore",
	}) then
		item.Color = contains(name, {"RailMuzzleCore"}) and COLORS.ChargeHot or COLORS.Accent
		item.Material = Enum.Material.Neon
		item.Reflectance = 0
		return
	end

	if contains(name, {
		"HeadBrow", "Armor", "Plate", "Crown", "RailBarrelUpper",
		"RailBarrelLower", "KnucklePlate", "Toe", "FootMain", "KneeGuard",
	}) then
		item.Color = COLORS.Armor
		item.Material = Enum.Material.Sandstone
		item.Reflectance = 0
		return
	end

	if contains(name, {
		"Bearing", "Gimbal", "Hydraulic", "Axle", "Joint", "Brace",
		"MuzzleFrame", "FistCage", "WristRam", "Pylon", "Recoil",
	}) then
		item.Color = COLORS.DarkMetal
		item.Material = Enum.Material.Metal
		item.Reflectance = 0.02
		return
	end

	if contains(name, {
		"TowerBody", "RailBreech", "Housing", "UpperArm", "Forearm",
		"Thigh", "Shin", "Pelvis", "Torso",
	}) then
		item.Color = COLORS.Body
		item.Material = Enum.Material.Metal
		item.Reflectance = 0.025
		return
	end

	if contains(name, {"SiegeKnuckle", "EmblemFrame", "Cradle"}) then
		item.Color = COLORS.Chassis
		item.Material = Enum.Material.DiamondPlate
		item.Reflectance = 0.01
		return
	end

	item.Material = Enum.Material.Metal
	item.Reflectance = math.min(item.Reflectance, 0.02)
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

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "BastionColossusDressing.Apply expects a Model")
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then dressPart(item) end
	end
	enforceRuntimeBudget(model)
	model:SetAttribute("PipelinePhase", 5)
	model:SetAttribute("DressingApplied", true)
	model:SetAttribute("DressingUsesAdditionalParts", false)
	model:SetAttribute("PermanentLights", 0)
	model:SetAttribute("PermanentParticleEmitters", 0)
	model:SetAttribute("ArmorMaterial", "Sandstone")
	model:SetAttribute("TextLabelsScaled", true)
	return model
end

return Dressing
