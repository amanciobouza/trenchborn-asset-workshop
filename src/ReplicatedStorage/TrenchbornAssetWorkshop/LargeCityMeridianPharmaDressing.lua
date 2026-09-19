local Dressing = {}

local COLORS = {
	White = Color3.fromRGB(244, 247, 246),
	Dark = Color3.fromRGB(38, 45, 49),
	Stone = Color3.fromRGB(220, 222, 217),
	StoneDark = Color3.fromRGB(172, 177, 174),
	Teal = Color3.fromRGB(55, 166, 173),
	Chemical = Color3.fromRGB(170, 64, 132),
	Green = Color3.fromRGB(67, 121, 76),
	GreenDark = Color3.fromRGB(48, 86, 57),
	Soil = Color3.fromRGB(78, 66, 52),
	Metal = Color3.fromRGB(176, 182, 181),
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
			Vector3.new(1.65, 1.35, 1.65),
			CFrame.new(position + Vector3.new(xOffset, 1.15, 0)),
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

local function addResearchEntranceDressing(root)
	local area = folder(root, "ResearchEntranceDressing")

	-- Main identity is mounted above the atrium, outside the facade volume.
	local wordmark = block(
		area,
		"MeridianWordmark",
		Vector3.new(29, 2.5, 0.34),
		Vector3.new(-43, 29.0, -40.38),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, wordmark, "MERIDIAN BIOWORKS", Enum.NormalId.Front, COLORS.White)

	local submark = block(
		area,
		"ResearchSubmark",
		Vector3.new(20, 1.15, 0.26),
		Vector3.new(-43, 26.95, -40.42),
		COLORS.Teal,
		Enum.Material.Metal
	)
	addSurfaceText(area, submark, "RESEARCH  •  BIOPROCESS", Enum.NormalId.Front, COLORS.Dark)

	-- Symmetric landscape keeps the public entrance formal and sterile.
	addPlanter(area, "EntryPlanterLeft", Vector3.new(-59.0, 0.60, -51.0), Vector3.new(10, 1.2, 3.5))
	addPlanter(area, "EntryPlanterRight", Vector3.new(-27.0, 0.60, -51.0), Vector3.new(10, 1.2, 3.5))
	addPalm(area, "EntryPalmLeft", Vector3.new(-62.0, 0.45, -50.5), 8.8, 10)
	addPalm(area, "EntryPalmRight", Vector3.new(-24.0, 0.45, -50.5), 8.8, -10)

	for index, x in ipairs({-53, -47, -39, -33}) do
		cylinder(area, "VisitorBollard_" .. index, 1.8, 0.30, Vector3.new(x, 0.9, -53.0), COLORS.StoneDark, Enum.Material.Metal)
	end
end

local function addProcessCourtDressing(root)
	local area = folder(root, "ProcessCourtDressing")

	-- Tank identifiers use dark plaques with high-contrast text; no extra neon
	-- is added to the tank faces beyond the approved safety bands.
	for index, x in ipairs({4, 15, 26, 37}) do
		local plate = block(
			area,
			"BioreactorId_" .. index,
			Vector3.new(5.8, 1.8, 0.28),
			Vector3.new(x, 5.0, 47.42),
			COLORS.Dark,
			Enum.Material.Metal
		)
		addSurfaceText(area, plate, string.format("BIO-%02d", index), Enum.NormalId.Back, COLORS.White)
	end

	-- A restrained bioswale softens the industrial court without hiding the tanks.
	local bioswale = folder(area, "Bioswale")
	block(bioswale, "Bed", Vector3.new(34, 0.7, 3.4), Vector3.new(-17.0, 0.35, 43.2), COLORS.Soil, Enum.Material.Ground)
	for index, x in ipairs({-31, -26, -21, -16, -11, -6, -1}) do
		part(
			bioswale,
			"Plant_" .. index,
			Vector3.new(1.5, 1.4, 1.5),
			CFrame.new(x, 1.0, 43.2),
			index % 3 == 0 and COLORS.GreenDark or COLORS.Green,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
	end

	-- Minimal chemical-zone graphics at the outer process edge.
	for index, x in ipairs({-1, 9, 19, 29, 39}) do
		block(
			area,
			"SafetyDash_" .. index,
			Vector3.new(5.5, 0.12, 0.8),
			Vector3.new(x, 0.53, 48.3),
			index % 2 == 0 and COLORS.Chemical or COLORS.Teal,
			Enum.Material.Neon
		)
	end
end

local function addRooftopDressing(root)
	local area = folder(root, "RooftopDressing")

	local modules = {
		{name = "A", x = 5, y = 32.0, z = -20.25, width = 12},
		{name = "B", x = 31, y = 32.5, z = -17.25, width = 11},
		{name = "C", x = 43, y = 31.5, z = 6.25, width = 10},
	}

	for _, module in ipairs(modules) do
		local plaque = block(
			area,
			"ProcessLabel_" .. module.name,
			Vector3.new(module.width, 1.15, 0.28),
			Vector3.new(module.x, module.y, module.z),
			COLORS.Dark,
			Enum.Material.Metal
		)
		addSurfaceText(area, plaque, "PROCESS " .. module.name, Enum.NormalId.Front, COLORS.White)
	end

	-- Small utility identifier on the stack plinth clarifies the exhaust cluster.
	local utility = block(
		area,
		"ExhaustUtilityLabel",
		Vector3.new(12, 1.1, 0.28),
		Vector3.new(20, 30.0, 8.45),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, utility, "AIR HANDLING", Enum.NormalId.Front, COLORS.White)
end

local function addFacadeDressing(root)
	local area = folder(root, "FacadeDressing")

	-- Small, non-neon facility marker on the cleanroom hall avoids competing with
	-- the main visitor wordmark while strengthening the biotech read.
	local hallMarker = block(
		area,
		"CleanroomHallMarker",
		Vector3.new(21, 1.7, 0.3),
		Vector3.new(31, 24.2, -35.82),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, hallMarker, "CLEANROOM PRODUCTION", Enum.NormalId.Front, COLORS.White)
end

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityMeridianPharmaDressing.Apply expects a Model")

	local existing = model:FindFirstChild("Dressing")
	if existing then existing:Destroy() end
	local root = folder(model, "Dressing")

	addResearchEntranceDressing(root)
	addFacadeDressing(root)
	addRooftopDressing(root)
	addProcessCourtDressing(root)

	model:SetAttribute("AssetPhase", 5)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("DressingRevision", "LargeCityMeridianPharma-Dressing-v1")
	model:SetAttribute("DressingStatus", "ReviewPending")
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("MeridianBioWorksSignage", true)
	model:SetAttribute("VisitorLandscapeDressed", true)
	model:SetAttribute("ProcessCourtDressed", true)
	model:SetAttribute("RooftopProcessLabels", true)
	model:SetAttribute("NoLoadingBayDressing", true)
	model:SetAttribute("NoGoldenMasterMassingChanges", true)
	return model
end

return Dressing
