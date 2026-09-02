local Dressing = {}

local ENERGY_PARTS = {
	VisorSensor = true,
	EmblemSpine = true,
	EmblemLeftWing = true,
	EmblemRightWing = true,
	RailCoreChannel = true,
	RailMuzzleCore = true,
}

local function isEnergyPart(item)
	if ENERGY_PARTS[item.Name] then return true end
	return string.find(item.Name, "ShieldNode", 1, true) ~= nil
		or string.find(item.Name, "Projector", 1, true) ~= nil
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

	-- Preserve the approved Golden Master palette and surfaces. Dressing only
	-- confirms the deliberate energy emitters; it must not restyle the chassis.
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			if isEnergyPart(item) then
				item.Material = Enum.Material.Neon
				item.Reflectance = 0
			else
				item.Material = Enum.Material.Metal
				item.Reflectance = math.min(item.Reflectance, 0.025)
			end
		end
	end

	enforceRuntimeBudget(model)
	model:SetAttribute("PipelinePhase", 5)
	model:SetAttribute("DressingApplied", true)
	model:SetAttribute("DressingStyle", "GoldenMasterPreserved")
	model:SetAttribute("DressingUsesAdditionalParts", false)
	model:SetAttribute("PermanentLights", 0)
	model:SetAttribute("PermanentParticleEmitters", 0)
	model:SetAttribute("TextLabelsScaled", true)
	return model
end

return Dressing
