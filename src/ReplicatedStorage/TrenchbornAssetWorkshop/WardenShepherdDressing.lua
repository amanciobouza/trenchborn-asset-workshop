local Dressing = {}

local COLORS = {
	Chassis = Color3.fromRGB(28, 35, 32),
	Body = Color3.fromRGB(91, 103, 92),
	Armor = Color3.fromRGB(171, 178, 151),
	Accent = Color3.fromRGB(92, 231, 151),
	Hazard = Color3.fromRGB(207, 177, 74),
	Ink = Color3.fromRGB(25, 31, 29),
	OffWhite = Color3.fromRGB(224, 226, 211),
}

local function find(model, name)
	return model:FindFirstChild(name, true)
end

local function prepareSurface(part, name, face)
	local existing = part:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end

	local surface = Instance.new("SurfaceGui")
	surface.Name = name
	surface.Face = face or Enum.NormalId.Front
	surface.AlwaysOnTop = false
	surface.LightInfluence = 0.25
	surface.PixelsPerStud = 40
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.Parent = part
	return surface
end

local function addSerialMark(part, text, face)
	local surface = prepareSurface(part, "GuardianSerialDressing", face)

	local backing = Instance.new("Frame")
	backing.Name = "Backing"
	backing.AnchorPoint = Vector2.new(0.5, 0.5)
	backing.Position = UDim2.fromScale(0.5, 0.72)
	backing.Size = UDim2.fromScale(0.68, 0.18)
	backing.BackgroundColor3 = COLORS.Ink
	backing.BackgroundTransparency = 0.12
	backing.BorderSizePixel = 0
	backing.Parent = surface

	local label = Instance.new("TextLabel")
	label.Name = "Serial"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = COLORS.OffWhite
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Parent = backing
end

local function addHazardBand(part, name, face)
	local surface = prepareSurface(part, name, face)
	local clipping = Instance.new("Frame")
	clipping.Name = "Band"
	clipping.AnchorPoint = Vector2.new(0.5, 0.5)
	clipping.Position = UDim2.fromScale(0.5, 0.16)
	clipping.Size = UDim2.fromScale(0.78, 0.16)
	clipping.BackgroundColor3 = COLORS.Ink
	clipping.BorderSizePixel = 0
	clipping.ClipsDescendants = true
	clipping.Parent = surface

	for index = -1, 5 do
		local stripe = Instance.new("Frame")
		stripe.Name = "Stripe" .. index
		stripe.AnchorPoint = Vector2.new(0.5, 0.5)
		stripe.Position = UDim2.fromScale(index * 0.22, 0.5)
		stripe.Size = UDim2.fromScale(0.13, 2.2)
		stripe.Rotation = 28
		stripe.BackgroundColor3 = COLORS.Hazard
		stripe.BorderSizePixel = 0
		stripe.Parent = clipping
	end
end

local function addLensTreatment(part)
	part.Color = Color3.fromRGB(190, 218, 213)
	part.Material = Enum.Material.Glass
	part.Transparency = 0.16
	part.Reflectance = 0.08
end

local function applyMaterialLanguage(model)
	local rig = model:FindFirstChild("Rig")
	local armor = model:FindFirstChild("Armor")
	local systems = model:FindFirstChild("Systems")
	local equipment = model:FindFirstChild("Equipment")

	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Reflectance = 0
			if rig and descendant:IsDescendantOf(rig) then
				descendant.Material = Enum.Material.Metal
			elseif armor and descendant:IsDescendantOf(armor) then
				descendant.Material = Enum.Material.SmoothPlastic
			elseif systems and descendant:IsDescendantOf(systems) and descendant.Material ~= Enum.Material.Neon then
				descendant.Material = Enum.Material.Metal
			elseif equipment and descendant:IsDescendantOf(equipment) and descendant.Material ~= Enum.Material.Neon then
				descendant.Material = Enum.Material.Metal
			end
		end
	end
end

function Dressing.Apply(model)
	applyMaterialLanguage(model)

	local leftShoulder = find(model, "LeftShoulderCap")
	local rightShoulder = find(model, "RightShoulderCap")
	local leftForearm = find(model, "LeftForearmPlate")
	local rightForearm = find(model, "RightForearmPlate")
	local lens = find(model, "Lens")

	if leftShoulder then
		addSerialMark(leftShoulder, "WARDEN-I", Enum.NormalId.Front)
	end
	if rightShoulder then
		addSerialMark(rightShoulder, "01", Enum.NormalId.Front)
	end
	if leftForearm then
		addHazardBand(leftForearm, "LeftHazardDressing", Enum.NormalId.Front)
	end
	if rightForearm then
		addHazardBand(rightForearm, "RightHazardDressing", Enum.NormalId.Front)
	end
	if lens then
		addLensTreatment(lens)
	end

	local visor = find(model, "VisorSensor")
	local pulseCore = model:FindFirstChild("ChestPulseCore", true)
	if visor then
		visor:SetAttribute("LightState", "Idle")
		visor:SetAttribute("IdleColor", COLORS.Accent)
	end
	if pulseCore then
		pulseCore:SetAttribute("LightState", "Idle")
		pulseCore:SetAttribute("IdleColor", COLORS.Accent)
	end

	model:SetAttribute("DressingVersion", 1)
	model:SetAttribute("DressingUsesAdditionalBaseParts", false)
	model:SetAttribute("PermanentLightCount", 0)
	model:SetAttribute("PermanentParticleEmitterCount", 0)
	model:SetAttribute("PipelinePhase", 5)

	return model
end

return Dressing
