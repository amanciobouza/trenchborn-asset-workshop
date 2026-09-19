local Dressing = {}

local COLORS = {
	White = Color3.fromRGB(245, 247, 244),
	Dark = Color3.fromRGB(42, 47, 50),
	Stone = Color3.fromRGB(224, 219, 207),
	StoneDark = Color3.fromRGB(181, 178, 169),
	Glass = Color3.fromRGB(48, 89, 103),
	Teal = Color3.fromRGB(58, 158, 164),
	Warm = Color3.fromRGB(230, 174, 96),
	Green = Color3.fromRGB(63, 125, 73),
	Wood = Color3.fromRGB(118, 88, 59),
	Soil = Color3.fromRGB(76, 61, 45),
	PoolDeck = Color3.fromRGB(210, 204, 192),
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

	-- Put the hotel identity on the outer marquee fascia so the porte-cochere never hides it.
	local wordmark = block(
		area,
		"HotelWordmark",
		Vector3.new(26, 2.2, 0.35),
		Vector3.new(0, 11.45, -42.42),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, wordmark, "STADIUM HOTEL", Enum.NormalId.Front, COLORS.White)

	block(area, "ArrivalWarmLine", Vector3.new(38, 0.38, 0.28), Vector3.new(0, 13.5, -42.38), COLORS.Warm, Enum.Material.Neon)

	addPlanter(area, "ArrivalPlanterLeft", Vector3.new(-27, 0.72, -45.5), Vector3.new(9, 1.2, 3.2))
	addPlanter(area, "ArrivalPlanterRight", Vector3.new(27, 0.72, -45.5), Vector3.new(9, 1.2, 3.2))
	addPalm(area, "ArrivalPalmLeft", Vector3.new(-34, 0, -46), 9.5, 10)
	addPalm(area, "ArrivalPalmRight", Vector3.new(34, 0, -46), 9.5, -10)

	for _, x in ipairs({-12, -6, 6, 12}) do
		cylinder(area, "ArrivalBollard" .. tostring(x), 2.0, 0.32, Vector3.new(x, 1, -47), COLORS.StoneDark, Enum.Material.Metal)
	end
end

local function addSkyLoungeDressing(root)
	local area = folder(root, "SkyLoungeDressing")

	for _, x in ipairs({-15, -7.5, 0, 7.5, 15}) do
		part(
			area,
			"SkyLoungeShrub_" .. tostring(x),
			Vector3.new(1.6, 1.6, 1.6),
			CFrame.new(x + 3, 61.1, -27.7),
			COLORS.Green,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
	end

	addPalm(area, "SkyLoungePalmLeft", Vector3.new(-17, 60.6, -27.0), 5.2, 12)
	addPalm(area, "SkyLoungePalmRight", Vector3.new(23, 60.6, -27.0), 5.2, -12)
end

local function addRooftopDressing(root)
	local area = folder(root, "RooftopDressing")

	-- Planting and poolside furniture stay clear of the water plane.
	for _, z in ipairs({-8, 1, 10}) do
		part(
			area,
			"RoofShrub_" .. tostring(z),
			Vector3.new(1.7, 1.7, 1.7),
			CFrame.new(25, 72.8, z),
			COLORS.Green,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
	end
	addPalm(area, "RoofPalm", Vector3.new(25, 72.2, 12), 5.8, 5)

	for index, x in ipairs({-15, -7, 1, 9}) do
		local lounger = block(
			area,
			"PoolLounger_" .. index,
			Vector3.new(5.0, 0.35, 1.7),
			Vector3.new(x, 72.35, 1.0),
			COLORS.PoolDeck,
			Enum.Material.SmoothPlastic
		)
		lounger.CFrame *= CFrame.Angles(0, math.rad(-8), math.rad(-7))
	end

	local poolSign = block(
		area,
		"PoolDeckSign",
		Vector3.new(14, 1.8, 0.28),
		Vector3.new(-4, 73.0, -12.75),
		COLORS.Teal,
		Enum.Material.Neon
	)
	addSurfaceText(area, poolSign, "ROOFTOP POOL", Enum.NormalId.Front, COLORS.Dark)
end

local function addRearDressing(root)
	local area = folder(root, "RearDressing")

	-- The identity sits on the outer canopy fascia, not on the wall behind it.
	local serviceSign = block(
		area,
		"ServiceSign",
		Vector3.new(32, 1.8, 0.35),
		Vector3.new(0, 12.0, 40.18),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, serviceSign, "HOTEL SERVICE  •  DELIVERIES", Enum.NormalId.Back, COLORS.White)

	for index, x in ipairs({-21, -7, 7, 21}) do
		local bay = block(
			area,
			"ServiceBayNumber" .. index,
			Vector3.new(3.6, 1.7, 0.28),
			Vector3.new(x, 8.4, 33.28),
			COLORS.Teal,
			Enum.Material.Neon
		)
		addSurfaceText(area, bay, string.format("%02d", index), Enum.NormalId.Back, COLORS.Dark)
	end
end

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityStadiumHotelDressing.Apply expects a Model")

	local existing = model:FindFirstChild("Dressing")
	if existing then existing:Destroy() end
	local root = folder(model, "Dressing")

	addEntranceDressing(root)
	addSkyLoungeDressing(root)
	addRooftopDressing(root)
	addRearDressing(root)

	model:SetAttribute("AssetPhase", 5)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("DressingRevision", "LargeCityStadiumHotel-Dressing-v1")
	model:SetAttribute("DressingStatus", "Review")
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("SkyLoungeVegetation", true)
	model:SetAttribute("RooftopPoolDressing", true)
	model:SetAttribute("RearServiceDressingVisible", true)
	model:SetAttribute("HighContrastNeonText", true)
	return model
end

return Dressing
