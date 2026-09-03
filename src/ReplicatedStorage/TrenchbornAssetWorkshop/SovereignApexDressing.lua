local specification = require(script.Parent:WaitForChild("SovereignApexSpecification"))
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

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

local DRONE_PREVIEW_ORDER = {
	"LeftDroneInner", "RightDroneInner",
	"LeftDroneOuter", "RightDroneOuter",
	"LeftDroneLower", "RightDroneLower",
}

local function emitEnergyBurst(part, color, count, speed)
	if not part or not part:IsA("BasePart") or not part.Parent then return end
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "SovereignTransientEnergy"
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Rate = 0
	emitter.Lifetime = NumberRange.new(0.55, 1.05)
	emitter.Speed = NumberRange.new(speed * 0.65, speed)
	emitter.Drag = 3
	emitter.SpreadAngle = Vector2.new(60, 60)
	emitter.Rotation = NumberRange.new(-180, 180)
	emitter.RotSpeed = NumberRange.new(-120, 120)
	emitter.LightEmission = 0.9
	emitter.LightInfluence = 0
	emitter.LockedToPart = false
	emitter.Color = ColorSequence.new(color, COLORS.ChargeHot)
	emitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.35, 1.2),
		NumberSequenceKeypoint.new(1, 0),
	})
	emitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.7, 0.28),
		NumberSequenceKeypoint.new(1, 1),
	})
	emitter.Parent = part
	-- Give the emitter time to replicate before firing the one-shot burst.
	task.delay(0.12, function()
		if emitter.Parent then emitter:Emit(count) end
	end)
	Debris:AddItem(emitter, 1.75)
end

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
		item.Reflectance = 0.032
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
	model:SetAttribute("DressingVersion", 2)
	model:SetAttribute("DressingStyle", "ApexNightPredator")
	model:SetAttribute("DressingUsesAdditionalParts", false)
	model:SetAttribute("PermanentLights", 0)
	model:SetAttribute("PermanentParticleEmitters", 0)
	model:SetAttribute("TransientEnergyPreviewAvailable", true)
	model:SetAttribute("TextLabelsScaled", true)
	return model
end

function Dressing.PreviewEnergy(model)
	assert(model and model:IsA("Model"), "SovereignApexDressing.PreviewEnergy expects a Model")
	local lockCore = model:FindFirstChild("SovereignLockCore", true)
	local lanceEmitter = model:FindFirstChild("LanceEmitterCore", true)
	local blade = model:FindFirstChild("ApexEnergyBlade", true)
	emitEnergyBurst(lockCore, COLORS.Accent, 18, 5)

	task.delay(0.15, function()
		emitEnergyBurst(lanceEmitter, COLORS.ChargeHot, 16, 6)
		emitEnergyBurst(blade, COLORS.Accent, 18, 4)
	end)

	for delayIndex, droneName in ipairs(DRONE_PREVIEW_ORDER) do
		local drone = model:FindFirstChild(droneName, true)
		local sensor = drone and drone:FindFirstChild("SensorRecess", true)
		task.delay(0.2 + delayIndex * 0.07, function()
			emitEnergyBurst(sensor, COLORS.Accent, 9, 4.5)
		end)
	end
	model:SetAttribute("LastEnergyPreviewTime", Workspace:GetServerTimeNow())
end

return Dressing
