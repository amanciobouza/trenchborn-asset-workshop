local Dressing = {}

local COLORS = {
	White = Color3.fromRGB(244, 247, 246),
	Dark = Color3.fromRGB(38, 45, 49),
	Stone = Color3.fromRGB(219, 222, 218),
	StoneDark = Color3.fromRGB(168, 174, 172),
	Metal = Color3.fromRGB(176, 182, 181),
	Cyan = Color3.fromRGB(54, 170, 181),
	Amber = Color3.fromRGB(224, 162, 74),
	Green = Color3.fromRGB(67, 121, 76),
	GreenDark = Color3.fromRGB(49, 88, 58),
	Soil = Color3.fromRGB(78, 66, 52),
	Graphite = Color3.fromRGB(48, 55, 60),
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

local function cylinder(parent, name, height, diameter, position, color, material)
	return part(
		parent,
		name,
		Vector3.new(height, diameter, diameter),
		CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)),
		color,
		material,
		0,
		Enum.PartType.Cylinder
	)
end

local function addSurfaceText(parent, adornee, text, face, color)
	local gui = Instance.new("SurfaceGui")
	gui.Name = adornee.Name .. "Surface"
	gui.Adornee = adornee
	gui.Face = face or Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0.15
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
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
end

local function addPlanter(parent, name, position, size)
	local planter = folder(parent, name)
	block(planter, "Box", size, position, COLORS.Stone, Enum.Material.Concrete)
	block(
		planter,
		"Soil",
		size - Vector3.new(0.5, 0.55, 0.5),
		position + Vector3.new(0, 0.45, 0),
		COLORS.Soil,
		Enum.Material.Ground
	)

	for index, xOffset in ipairs({-2.2, 0, 2.2}) do
		part(
			planter,
			"Shrub_" .. index,
			Vector3.new(1.55, 1.25, 1.55),
			CFrame.new(position + Vector3.new(xOffset, 1.10, 0)),
			index == 2 and COLORS.GreenDark or COLORS.Green,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
	end
end

local function addPalm(parent, name, position, height, yaw)
	local palm = folder(parent, name)
	local h = height or 8.5
	cylinder(palm, "Trunk", h, 0.72, position + Vector3.new(0, h * 0.5, 0), Color3.fromRGB(115, 88, 60), Enum.Material.Wood)

	local crown = position + Vector3.new(0, h, 0)
	for index = 1, 7 do
		local angle = math.rad((index - 1) * (360 / 7) + (yaw or 0))
		local leaf = block(
			palm,
			"Leaf_" .. index,
			Vector3.new(0.55, 0.22, 4.1),
			crown + Vector3.new(math.cos(angle) * 1.25, 0.15, math.sin(angle) * 1.25),
			COLORS.Green,
			Enum.Material.Grass
		)
		leaf.CFrame *= CFrame.Angles(math.rad(-12), angle, 0)
	end
end

local function addControlEntranceDressing(root)
	local area = folder(root, "ControlEntranceDressing")

	-- Facility identity is mounted on its own stand-off blade above the control portal.
	-- This keeps the lettering clear of portal mullions and the cyan header.
	for _, x in ipairs({-13, 9}) do
		block(
			area,
			"WordmarkBracket_" .. tostring(x),
			Vector3.new(0.35, 0.35, 1.25),
			Vector3.new(x, 23.2, -44.9),
			COLORS.Metal,
			Enum.Material.Metal
		)
	end

	local wordmark = block(
		area,
		"AurelineWordmark",
		Vector3.new(27, 2.4, 0.32),
		Vector3.new(-2, 23.2, -45.55),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, wordmark, "AURELINE GRIDWORKS", Enum.NormalId.Front, COLORS.White)

	local submark = block(
		area,
		"ControlSubmark",
		Vector3.new(19, 1.1, 0.28),
		Vector3.new(-2, 21.0, -45.52),
		COLORS.Cyan,
		Enum.Material.Metal
	)
	addSurfaceText(area, submark, "GRID CONTROL  •  HIGH VOLTAGE", Enum.NormalId.Front, COLORS.Dark)

	addPlanter(area, "EntryPlanterLeft", Vector3.new(-20.0, 0.60, -51.0), Vector3.new(9, 1.2, 3.4))
	addPlanter(area, "EntryPlanterRight", Vector3.new(16.0, 0.60, -51.0), Vector3.new(9, 1.2, 3.4))
	addPalm(area, "EntryPalmLeft", Vector3.new(-24.0, 0.45, -50.3), 8.5, 10)
	addPalm(area, "EntryPalmRight", Vector3.new(20.0, 0.45, -50.3), 8.5, -10)

	for index, x in ipairs({-12, -7, 3, 8}) do
		cylinder(area, "ControlBollard_" .. index, 1.8, 0.30, Vector3.new(x, 0.9, -52.0), COLORS.StoneDark, Enum.Material.Metal)
	end
end

local function addHallDressing(root)
	local area = folder(root, "HallDressing")

	-- Signs sit on stand-off brackets so facade fins never cross the text.
	local switchSign = block(
		area,
		"SwitchgearHallSign",
		Vector3.new(22, 1.8, 0.32),
		Vector3.new(-43, 25.0, -43.55),
		COLORS.Graphite,
		Enum.Material.Metal
	)
	addSurfaceText(area, switchSign, "SWITCHGEAR HALL", Enum.NormalId.Front, COLORS.White)

	for _, x in ipairs({-52, -34}) do
		block(
			area,
			"SwitchgearSignBracket_" .. tostring(x),
			Vector3.new(0.35, 0.35, 1.35),
			Vector3.new(x, 25.0, -42.9),
			COLORS.Metal,
			Enum.Material.Metal
		)
	end

	local converterSign = block(
		area,
		"ConverterHallSign",
		Vector3.new(21, 1.8, 0.32),
		Vector3.new(37, 32.5, -40.35),
		COLORS.Graphite,
		Enum.Material.Metal
	)
	addSurfaceText(area, converterSign, "CONVERTER HALL", Enum.NormalId.Front, COLORS.White)

	for _, x in ipairs({29, 45}) do
		block(
			area,
			"ConverterSignBracket_" .. tostring(x),
			Vector3.new(0.35, 0.35, 1.25),
			Vector3.new(x, 32.5, -39.75),
			COLORS.Metal,
			Enum.Material.Metal
		)
	end
end

local function addSwitchyardDressing(root)
	local area = folder(root, "SwitchyardDressing")

	-- Row identifiers are placed at the WEST EDGE of each field, outside the central
	-- walking corridors. They mark the parallel rows without creating obstacles.
	local rows = {
		{name = "A", z = 10.5, text = "SWITCH FIELD A"},
		{name = "B", z = 19.5, text = "SWITCH FIELD B"},
	}
	for _, row in ipairs(rows) do
		local sign = block(
			area,
			"SwitchFieldSign_" .. row.name,
			Vector3.new(13, 1.5, 0.28),
			Vector3.new(-68.6, 3.0, row.z),
			COLORS.Dark,
			Enum.Material.Metal
		)
		addSurfaceText(area, sign, row.text, Enum.NormalId.Left, COLORS.White)
	end


	-- Ground-edge safety dashes visually define the HV rows while preserving the
	-- full walking width of every service corridor.
	for index, x in ipairs({-64, -48, -32, -16, 0, 16, 32, 48, 64}) do
		block(
			area,
			"HVEdgeDash_" .. index,
			Vector3.new(7.5, 0.10, 0.55),
			Vector3.new(x, 0.56, 28.1),
			index % 2 == 0 and COLORS.Amber or COLORS.Cyan,
			Enum.Material.Neon
		)
	end
end

local function addTransformerDressing(root)
	local area = folder(root, "TransformerDressing")

	for index, x in ipairs({-48, -16, 16, 48}) do
		-- Transformer IDs are mounted on the REAR side of the transformer row.
		-- This matches the amber safety stripe and keeps both readable when the
		-- player approaches the installation from the rear.
		local plate = block(
			area,
			"TransformerId_" .. index,
			Vector3.new(9.0, 1.8, 0.28),
			Vector3.new(x, 12.5, 40.45),
			COLORS.Dark,
			Enum.Material.Metal
		)
		addSurfaceText(area, plate, string.format("TX-%02d", index), Enum.NormalId.Back, COLORS.White)
	end
end

local function addReactivePowerDressing(root)
	local area = folder(root, "ReactivePowerDressing")

	-- Rear-facing zone signs are mounted directly behind the equipment they name.
	-- This makes the relationship obvious when the player walks the rear service edge.
	local capacitorSign = block(
		area,
		"CapacitorZoneSign",
		Vector3.new(22, 1.8, 0.30),
		Vector3.new(-36, 12.5, 53.2),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, capacitorSign, "HV  •  CAPACITOR BANKS", Enum.NormalId.Back, COLORS.White)

	local reactorSign = block(
		area,
		"ReactorZoneSign",
		Vector3.new(21, 1.8, 0.30),
		Vector3.new(49, 19.5, 53.2),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, reactorSign, "HV  •  SHUNT REACTORS", Enum.NormalId.Back, COLORS.White)

	-- Amber rear-edge safety bars sit directly behind each reactive-power zone.
	block(
		area,
		"CapacitorRearSafetyBar",
		Vector3.new(54, 0.28, 0.28),
		Vector3.new(-36, 2.2, 53.55),
		COLORS.Amber,
		Enum.Material.Neon
	)
	block(
		area,
		"ReactorRearSafetyBar",
		Vector3.new(46, 0.28, 0.28),
		Vector3.new(49, 2.2, 53.55),
		COLORS.Amber,
		Enum.Material.Neon
	)
end
local function addRooftopDressing(root)
	local area = folder(root, "RooftopDressing")

	-- Cooling A-D text was intentionally removed. The rooftop equipment should
	-- read through its form rather than through repeated labels.
	local vent = block(
		area,
		"VentUtilityLabel",
		Vector3.new(12, 1.2, 0.28),
		Vector3.new(36, 42.1, -7.3),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, vent, "VENT ARRAY", Enum.NormalId.Front, COLORS.White)
end
function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityPowerUtilityDressing.Apply expects a Model")

	local existing = model:FindFirstChild("Dressing")
	if existing then existing:Destroy() end
	local root = folder(model, "Dressing")

	addControlEntranceDressing(root)
	addHallDressing(root)
	addSwitchyardDressing(root)
	addTransformerDressing(root)
	addReactivePowerDressing(root)
	addRooftopDressing(root)

	model:SetAttribute("AssetPhase", 5)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("QualityGateC", "Pending")
	model:SetAttribute("DressingRevision", "LargeCityPowerUtility-Dressing-v2-RearReadable")
	model:SetAttribute("DressingStatus", "Approved")
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("AurelineGridworksSignage", true)
	model:SetAttribute("SwitchyardZoneLabels", true)
	model:SetAttribute("WalkableAislesUnobstructedByDressing", true)
	model:SetAttribute("TransformerIdentifiers", true)
	model:SetAttribute("ReactivePowerIdentifiers", true)
	model:SetAttribute("RooftopCoolingTextRemoved", true)
	model:SetAttribute("RearEquipmentLabelsReadable", true)
	model:SetAttribute("BayNumberLabelsRemoved", true)
	model:SetAttribute("NoGoldenMasterMassingChanges", true)
	return model
end

return Dressing
