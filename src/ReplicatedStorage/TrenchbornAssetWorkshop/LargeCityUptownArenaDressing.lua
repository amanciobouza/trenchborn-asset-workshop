local Dressing = {}

local COLORS = {
	White = Color3.fromRGB(244, 247, 247),
	Dark = Color3.fromRGB(39, 47, 54),
	DarkGlass = Color3.fromRGB(36, 70, 82),
	Teal = Color3.fromRGB(50, 158, 166),
	Cyan = Color3.fromRGB(95, 205, 214),
	Warm = Color3.fromRGB(236, 176, 92),
	Metal = Color3.fromRGB(154, 164, 167),
	Concrete = Color3.fromRGB(211, 214, 210),
	Leaf = Color3.fromRGB(55, 126, 74),
	Wood = Color3.fromRGB(123, 91, 61),
	Soil = Color3.fromRGB(74, 59, 44),
}

local function folder(parent, name)
	local existing = parent:FindFirstChild(name)
	if existing then existing:Destroy() end
	local item = Instance.new("Folder")
	item.Name = name
	item.Parent = parent
	return item
end

local function part(parent, name, size, cf, color, material, transparency, shape)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cf
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.Transparency = transparency or 0
	item.Shape = shape or Enum.PartType.Block
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function block(parent, name, size, position, color, material, transparency)
	return part(parent, name, size, CFrame.new(position), color, material, transparency)
end

local function cylinder(parent, name, size, position, color, material, rotation)
	return part(
		parent,
		name,
		size,
		CFrame.new(position) * CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z)),
		color,
		material,
		0,
		Enum.PartType.Cylinder
	)
end

local function addSurfaceText(parent, adornee, text, face, color, font)
	local gui = Instance.new("SurfaceGui")
	gui.Name = adornee.Name .. "Surface"
	gui.Adornee = adornee
	gui.Face = face or Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0.2
	gui.PixelsPerStud = 42
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or COLORS.White
	label.TextStrokeTransparency = 0.82
	label.Font = font or Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
end

local function addPalm(parent, name, position, height, yaw)
	local palm = folder(parent, name)
	local h = height or 10
	cylinder(
		palm,
		"Trunk",
		Vector3.new(h, 0.85, 0.85),
		position + Vector3.new(0, h * 0.5, 0),
		COLORS.Wood,
		Enum.Material.Wood,
		Vector3.new(0, 0, 90)
	)
	local crown = position + Vector3.new(0, h, 0)
	for index = 1, 7 do
		local angle = math.rad((index - 1) * (360 / 7) + (yaw or 0))
		local dx = math.cos(angle)
		local dz = math.sin(angle)
		block(
			palm,
			"Leaf" .. index,
			Vector3.new(0.7, 0.25, 4.8),
			crown + Vector3.new(dx * 1.6, 0.2, dz * 1.6),
			COLORS.Leaf,
			Enum.Material.Grass
		).CFrame *= CFrame.Angles(math.rad(-14), math.rad(math.deg(angle)), 0)
	end
end

local function addPlanter(parent, name, position, size)
	local planter = folder(parent, name)
	block(planter, "Box", size, position, COLORS.Concrete, Enum.Material.Concrete)
	block(planter, "Soil", size - Vector3.new(0.5, 0.65, 0.5), position + Vector3.new(0, 0.55, 0), COLORS.Soil, Enum.Material.Ground)
	for x = -1, 1 do
		part(
			planter,
			"Shrub" .. x,
			Vector3.new(1.5, 1.5, 1.5),
			CFrame.new(position + Vector3.new(x * 1.8, 1.45, 0)),
			COLORS.Leaf,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
	end
end

local function addEntranceDressing(root)
	local area = folder(root, "EntranceDressing")

	local wordmark = block(
		area,
		"ArenaWordmark",
		Vector3.new(48, 4.0, 0.55),
		Vector3.new(0, 23.8, -58.85),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, wordmark, "UPTOWN ARENA", Enum.NormalId.Front, COLORS.White)

	local eventStrip = block(
		area,
		"EventStrip",
		Vector3.new(54, 2.6, 0.38),
		Vector3.new(0, 20.6, -58.95),
		COLORS.Teal,
		Enum.Material.Neon
	)
	addSurfaceText(area, eventStrip, "SPORTS   •   CONCERTS   •   EVENTS", Enum.NormalId.Front, COLORS.White)

	local gates = {
		-- Portal piers sit at -27, -17, -6, 6, 17 and 27.
		-- Center each gate sign in a real bay between adjacent piers.
		{label = "A", x = -22.0},
		{label = "B", x = -11.5},
		{label = "C", x = 11.5},
		{label = "D", x = 22.0},
	}
	for _, gate in ipairs(gates) do
		local sign = block(
			area,
			"Gate" .. gate.label,
			Vector3.new(5.5, 2.4, 0.35),
			Vector3.new(gate.x, 8.0, -57.75),
			COLORS.DarkGlass,
			Enum.Material.Glass
		)
		addSurfaceText(area, sign, "GATE " .. gate.label, Enum.NormalId.Front, COLORS.White)
	end

	for _, x in ipairs({-32, -24, -16, 16, 24, 32}) do
		cylinder(
			area,
			"QueueBollard" .. tostring(x),
			Vector3.new(2.2, 0.35, 0.35),
			Vector3.new(x, 1.1, -67.5),
			COLORS.Metal,
			Enum.Material.Metal,
			Vector3.new(0, 0, 90)
		)
	end

	addPlanter(area, "PlanterLeft", Vector3.new(-41, 0.85, -69), Vector3.new(10, 1.3, 3.2))
	addPlanter(area, "PlanterRight", Vector3.new(41, 0.85, -69), Vector3.new(10, 1.3, 3.2))
	addPalm(area, "PalmLeft", Vector3.new(-51, 0, -70), 11, 12)
	addPalm(area, "PalmRight", Vector3.new(51, 0, -70), 11, -12)
end

local function addMediaRibbonDressing(root)
	local area = folder(root, "MediaRibbonDressing")
	local panels = {
		{theta = math.rad(28), text = "TONIGHT 20:00", color = COLORS.Cyan},
		{theta = math.rad(72), text = "LIVE", color = COLORS.Warm},
		{theta = math.rad(108), text = "UPTOWN", color = COLORS.Cyan},
		{theta = math.rad(152), text = "ARENA", color = COLORS.Warm},
		{theta = math.rad(208), text = "EVENTS", color = COLORS.Cyan},
		{theta = math.rad(252), text = "CITY LIVE", color = COLORS.Warm},
		{theta = math.rad(288), text = "SPORT", color = COLORS.Cyan},
		{theta = math.rad(332), text = "MUSIC", color = COLORS.Warm},
	}
	local a, b = 68.2, 49.2

	for index, panel in ipairs(panels) do
		local theta = panel.theta
		local position = Vector3.new(a * math.cos(theta), 29.0, b * math.sin(theta))
		local tangent = Vector3.new(-a * math.sin(theta), 0, b * math.cos(theta)).Unit
		local up = Vector3.yAxis
		local back = tangent:Cross(up).Unit
		local cf = CFrame.fromMatrix(position, tangent, up, back)

		local frame = part(
			area,
			"RibbonFrame" .. index,
			Vector3.new(12.5, 5.1, 0.55),
			cf,
			COLORS.Dark,
			Enum.Material.Metal
		)
		local display = part(
			area,
			"RibbonDisplay" .. index,
			Vector3.new(11.5, 4.2, 0.26),
			cf * CFrame.new(0, 0, -0.42),
			panel.color,
			Enum.Material.Neon
		)
		frame.CastShadow = true
		display.CastShadow = false
		addSurfaceText(area, display, panel.text, Enum.NormalId.Front, COLORS.White)
	end
end

local function addFacadeVariation(root)
	local area = folder(root, "FacadeVariation")

	-- Break up the long concrete oval with larger dark-glass event bays.
	-- These are deliberately sparse so the arena stays elegant rather than noisy.
	local bays = {
		{theta = math.rad(42), accent = COLORS.Cyan},
		{theta = math.rad(72), accent = COLORS.Warm},
		{theta = math.rad(108), accent = COLORS.Cyan},
		{theta = math.rad(138), accent = COLORS.Warm},
		{theta = math.rad(222), accent = COLORS.Cyan},
		{theta = math.rad(252), accent = COLORS.Warm},
		{theta = math.rad(288), accent = COLORS.Cyan},
		{theta = math.rad(318), accent = COLORS.Warm},
	}
	local a, b = 68.3, 49.3

	for index, bay in ipairs(bays) do
		local theta = bay.theta
		local position = Vector3.new(a * math.cos(theta), 17.5, b * math.sin(theta))
		local tangent = Vector3.new(-a * math.sin(theta), 0, b * math.cos(theta)).Unit
		local up = Vector3.yAxis
		local back = tangent:Cross(up).Unit
		local cf = CFrame.fromMatrix(position, tangent, up, back)

		local frame = part(
			area,
			"FeatureBayFrame" .. index,
			Vector3.new(10.5, 18.0, 0.8),
			cf,
			COLORS.Dark,
			Enum.Material.Metal
		)
		local glass = part(
			area,
			"FeatureBayGlass" .. index,
			Vector3.new(8.9, 15.8, 0.35),
			cf * CFrame.new(0, 0, -0.58),
			COLORS.DarkGlass,
			Enum.Material.Glass,
			0.08
		)
		local accent = part(
			area,
			"FeatureBayAccent" .. index,
			Vector3.new(9.2, 0.65, 0.30),
			cf * CFrame.new(0, 7.4, -0.78),
			bay.accent,
			Enum.Material.Neon
		)
		frame.CastShadow = true
		glass.CastShadow = false
		accent.CastShadow = false
	end
end

local function addFacadeLighting(root)
	local area = folder(root, "FacadeLighting")
	local count = 18
	for index = 0, count - 1 do
		local theta = (index / count) * math.pi * 2
		local x = 66.7 * math.cos(theta)
		local z = 47.7 * math.sin(theta)
		local lamp = part(
			area,
			"FacadeLight" .. string.format("%02d", index + 1),
			Vector3.new(0.7, 1.8, 0.45),
			CFrame.new(x, 36.5, z),
			index % 2 == 0 and COLORS.Cyan or COLORS.White,
			Enum.Material.Neon
		)
		lamp.CastShadow = false
	end
end

local function addRearDressing(root)
	local area = folder(root, "RearDressing")

	-- Rear is local +Z; keep all signage and dock dressing outside the rear wall.
	local sign = block(
		area,
		"ServiceSign",
		Vector3.new(30, 3.0, 0.35),
		Vector3.new(0, 15.0, 55.95),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, sign, "EVENT LOADING", Enum.NormalId.Back, COLORS.White)

	local crewSign = block(
		area,
		"CrewEntranceSign",
		Vector3.new(14, 2.2, 0.30),
		Vector3.new(28, 11.0, 55.98),
		COLORS.Teal,
		Enum.Material.Neon
	)
	addSurfaceText(area, crewSign, "CREW", Enum.NormalId.Back, COLORS.White)

	for index, x in ipairs({-27, -9, 9, 27}) do
		local dock = block(
			area,
			"DockNumber" .. index,
			Vector3.new(4.6, 2.0, 0.28),
			Vector3.new(x, 10.2, 56.02),
			COLORS.DarkGlass,
			Enum.Material.Glass
		)
		addSurfaceText(area, dock, string.format("%02d", index), Enum.NormalId.Back, COLORS.White)
	end

	-- Vehicle guidance makes the rear read as a real service entrance from distance.
	for _, x in ipairs({-27, -9, 9, 27}) do
		block(
			area,
			"LoadingLane" .. tostring(x),
			Vector3.new(8, 0.10, 14),
			Vector3.new(x, 0.55, 64),
			COLORS.White,
			Enum.Material.SmoothPlastic
		)
	end
end

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityUptownArenaDressing.Apply expects a Model")

	local existing = model:FindFirstChild("Dressing")
	if existing then existing:Destroy() end
	local root = folder(model, "Dressing")

	addEntranceDressing(root)
	addMediaRibbonDressing(root)
	addFacadeVariation(root)
	addFacadeLighting(root)
	addRearDressing(root)

	model:SetAttribute("AssetPhase", 5)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("DressingRevision", "LargeCityUptownArena-Dressing-v4-RecessedGates")
	model:SetAttribute("DressingStatus", "Review")
	model:SetAttribute("TextScaledRule", true)
	model:SetAttribute("FacadeFeatureBays", 8)
	model:SetAttribute("RearServiceDressingVisible", true)
	model:SetAttribute("GateSignsCenteredBetweenPiers", true)
	model:SetAttribute("GateSignsBehindPierFace", true)
	return model
end

return Dressing
