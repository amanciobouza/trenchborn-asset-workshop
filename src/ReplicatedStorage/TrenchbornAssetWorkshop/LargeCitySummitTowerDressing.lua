local Dressing = {}

local COLORS = {
	White = Color3.fromRGB(245, 247, 244),
	Dark = Color3.fromRGB(38, 45, 49),
	Stone = Color3.fromRGB(222, 220, 210),
	StoneDark = Color3.fromRGB(173, 177, 174),
	Glass = Color3.fromRGB(45, 83, 98),
	Teal = Color3.fromRGB(57, 174, 178),
	Green = Color3.fromRGB(65, 128, 78),
	Wood = Color3.fromRGB(118, 88, 59),
	Soil = Color3.fromRGB(76, 61, 45),
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
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = gui
end

local function addPalm(parent, name, position, height, yaw)
	local palm = folder(parent, name)
	local h = height or 9
	cylinder(palm, "Trunk", h, 0.75, position + Vector3.new(0, h * 0.5, 0), COLORS.Wood, Enum.Material.Wood)

	local crown = position + Vector3.new(0, h, 0)
	for index = 1, 7 do
		local angle = math.rad((index - 1) * (360 / 7) + (yaw or 0))
		local leaf = block(
			palm,
			"Leaf" .. index,
			Vector3.new(0.6, 0.22, 4.2),
			crown + Vector3.new(math.cos(angle) * 1.4, 0.15, math.sin(angle) * 1.4),
			COLORS.Green,
			Enum.Material.Grass
		)
		leaf.CFrame *= CFrame.Angles(math.rad(-13), angle, 0)
	end
end

local function addPlanter(parent, name, position, size)
	local planter = folder(parent, name)
	block(planter, "Box", size, position, COLORS.Stone, Enum.Material.Concrete)
	block(planter, "Soil", size - Vector3.new(0.5, 0.55, 0.5), position + Vector3.new(0, 0.45, 0), COLORS.Soil, Enum.Material.Ground)
	for x = -1, 1 do
		part(
			planter,
			"Shrub" .. x,
			Vector3.new(1.35, 1.35, 1.35),
			CFrame.new(position + Vector3.new(x * 1.55, 1.18, 0)),
			COLORS.Green,
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
		"SummitTowerWordmark",
		Vector3.new(24, 3.0, 0.35),
		Vector3.new(0, 15.7, -31.85),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, wordmark, "SUMMIT TOWER", Enum.NormalId.Front, COLORS.White)

	block(area, "LobbyAccent", Vector3.new(30, 0.55, 0.35), Vector3.new(0, 13.9, -32.05), COLORS.Teal, Enum.Material.Neon)

	addPlanter(area, "EntryPlanterLeft", Vector3.new(-22, 0.75, -36), Vector3.new(8, 1.2, 3))
	addPlanter(area, "EntryPlanterRight", Vector3.new(22, 0.75, -36), Vector3.new(8, 1.2, 3))
	addPalm(area, "EntryPalmLeft", Vector3.new(-29, 0, -37), 9, 10)
	addPalm(area, "EntryPalmRight", Vector3.new(29, 0, -37), 9, -10)

	for _, x in ipairs({-13, -6.5, 6.5, 13}) do
		cylinder(area, "EntryBollard" .. tostring(x), 2.0, 0.32, Vector3.new(x, 1, -38.5), COLORS.StoneDark, Enum.Material.Metal)
	end
end

local function addSkyGardenDressing(root)
	local area = folder(root, "SkyGardenDressing")

	-- Lower front-left garden.
	for index, x in ipairs({-19, -13, -7, -1}) do
		local shrub = part(
			area,
			"LowerSkyGardenShrub" .. index,
			Vector3.new(2.0, 2.0, 2.0),
			CFrame.new(x, 60.0, -29.6),
			COLORS.Green,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
		shrub.CastShadow = true
	end
	addPalm(area, "LowerSkyGardenPalm", Vector3.new(-17, 59.0, -29.6), 5.8, 20)

	-- Upper rear-right garden.
	for index, x in ipairs({1, 6, 11, 16}) do
		part(
			area,
			"UpperSkyGardenShrub" .. index,
			Vector3.new(1.7, 1.7, 1.7),
			CFrame.new(x, 94.3, 23.8),
			COLORS.Green,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
	end
	addPalm(area, "UpperSkyGardenPalm", Vector3.new(13, 93.6, 23.8), 5.0, -15)
end

local function addFacadeAccents(root)
	local area = folder(root, "FacadeAccents")

	-- Sparse teal vertical accents reinforce the premium tower identity without
	-- fighting the structural fins and window mullions.
	for _, x in ipairs({-17, 17}) do
		block(area, "LowerAccent" .. tostring(x), Vector3.new(0.45, 28, 0.45), Vector3.new(x, 38, -24.0), COLORS.Teal, Enum.Material.Neon)
	end
	for _, x in ipairs({-15, 9}) do
		block(area, "MidAccent" .. tostring(x), Vector3.new(0.42, 22, 0.42), Vector3.new(x, 75, -19.4), COLORS.Teal, Enum.Material.Neon)
	end
	block(area, "UpperAccent", Vector3.new(0.42, 15, 0.42), Vector3.new(9, 104, -19.5), COLORS.Teal, Enum.Material.Neon)
end

local function addRearDressing(root)
	local area = folder(root, "RearDressing")
	-- Put the main service identity on the outer canopy fascia. Previously the
	-- sign sat on the wall behind the canopy and was partly hidden from the rear.
	local sign = block(
		area,
		"ServiceSign",
		Vector3.new(28, 1.8, 0.35),
		Vector3.new(0, 15.0, 36.65),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, sign, "SERVICE  •  DELIVERIES", Enum.NormalId.Back, COLORS.White)

	for index, x in ipairs({-12, 0, 12}) do
		local bay = block(
			area,
			"ServiceBayNumber" .. index,
			Vector3.new(3.8, 1.8, 0.28),
			Vector3.new(x, 10.3, 30.48),
			COLORS.Teal,
			Enum.Material.Neon
		)
		addSurfaceText(area, bay, string.format("%02d", index), Enum.NormalId.Back, COLORS.White)
	end
end

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "LargeCitySummitTowerDressing.Apply expects a Model")

	local existing = model:FindFirstChild("Dressing")
	if existing then existing:Destroy() end
	local root = folder(model, "Dressing")

	addEntranceDressing(root)
	addSkyGardenDressing(root)
	addFacadeAccents(root)
	addRearDressing(root)

	model:SetAttribute("AssetPhase", 5)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("DressingRevision", "LargeCitySummitTower-Dressing-v3-ServiceCanopySign")
	model:SetAttribute("DressingStatus", "Approved")
	model:SetAttribute("SkyGardenVegetation", true)
	model:SetAttribute("StandaloneImport", true)
	return model
end

return Dressing
