local specification = require(script.Parent:WaitForChild("AegisInterceptorSpecification"))

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

	if contains(name, {"AegisCore", "IonMuzzleCore", "IonChannel", "VisorSensor", "StatusChannel"}) then
		item.Color = COLORS.Accent
		item.Material = Enum.Material.Neon
		item.Reflectance = 0
		return
	end

	if item:FindFirstAncestor("DirectionalAegis") and name ~= "AegisCore" then
		item.Color = COLORS.Accent
		item.Material = Enum.Material.Glass
		item.Transparency = 0.28
		item.Reflectance = 0.06
		return
	end

	if contains(name, {"MissileCell", "WarningStrip"}) then
		item.Color = COLORS.Warning
		item.Material = Enum.Material.Neon
		item.Reflectance = 0
		return
	end

	if contains(name, {
		"Bearing", "Hub", "Axle", "Hydraulic", "Brace", "RecoilSleeve", "MuzzleRing",
		"LowerKeel", "LauncherFace", "PodHousing", "IonBarrel",
	}) then
		item.Color = COLORS.DarkMetal
		item.Material = Enum.Material.Metal
		item.Reflectance = 0.015
		return
	end

	if contains(name, {
		"Plate", "Crown", "Rail", "Brow", "FootMain", "KneeGuard", "OuterArmor",
		"PodArmorTop", "PodElevation",
	}) then
		item.Color = COLORS.Armor
		item.Material = Enum.Material.Metal
		item.Reflectance = 0.055
		return
	end

	if contains(name, {
		"Cobalt", "Wing", "Housing", "UpperArm", "Forearm", "Thigh", "Shin",
		"PodArmorSide",
	}) then
		item.Color = COLORS.Body
		item.Material = Enum.Material.Metal
		item.Reflectance = 0.025
		return
	end

	item.Material = Enum.Material.Metal
	item.Reflectance = math.min(item.Reflectance, 0.025)
end

local function enforceRuntimeBudget(model)
	local removedLights = 0
	local removedEmitters = 0
	local scaledLabels = 0
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
	assert(model and model:IsA("Model"), "AegisInterceptorDressing.Apply expects a Model")
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then dressPart(item) end
	end
	enforceRuntimeBudget(model)
	model:SetAttribute("PipelinePhase", 5)
	model:SetAttribute("DressingApplied", true)
	model:SetAttribute("DressingUsesAdditionalParts", false)
	model:SetAttribute("PermanentLights", 0)
	model:SetAttribute("PermanentParticleEmitters", 0)
	model:SetAttribute("AegisCrystalTransparency", 0.28)
	model:SetAttribute("TextLabelsScaled", true)
	return model
end

return Dressing
