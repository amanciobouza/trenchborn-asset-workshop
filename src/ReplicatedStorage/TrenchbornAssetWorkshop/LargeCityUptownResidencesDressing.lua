local Dressing = {}

local COLORS = {
	White = Color3.fromRGB(245, 247, 244),
	Dark = Color3.fromRGB(42, 47, 49),
	Stone = Color3.fromRGB(226, 222, 211),
	StoneDark = Color3.fromRGB(181, 181, 174),
	Glass = Color3.fromRGB(54, 96, 108),
	Teal = Color3.fromRGB(62, 166, 170),
	Warm = Color3.fromRGB(222, 171, 101),
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
		"ResidencesWordmark",
		Vector3.new(28, 2.6, 0.35),
		Vector3.new(0, 10.8, -32.15),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, wordmark, "UPTOWN RESIDENCES", Enum.NormalId.Front, COLORS.White)

	block(area, "LobbyWarmLine", Vector3.new(31, 0.42, 0.32), Vector3.new(0, 12.15, -32.1), COLORS.Warm, Enum.Material.Neon)

	addPlanter(area, "ArrivalPlanterLeft", Vector3.new(-24, 0.72, -41.0), Vector3.new(9, 1.2, 3.2))
	addPlanter(area, "ArrivalPlanterRight", Vector3.new(24, 0.72, -41.0), Vector3.new(9, 1.2, 3.2))
	addPalm(area, "ArrivalPalmLeft", Vector3.new(-31, 0, -42), 9, 10)
	addPalm(area, "ArrivalPalmRight", Vector3.new(31, 0, -42), 9, -10)

	for _, x in ipairs({-12, -6, 6, 12}) do
		cylinder(area, "ArrivalBollard" .. tostring(x), 2.0, 0.32, Vector3.new(x, 1, -44), COLORS.StoneDark, Enum.Material.Metal)
	end
end

local function addGardenSlotDressing(root)
	local area = folder(root, "GardenSlotDressing")
	for index, y in ipairs({58.2, 65.7, 73.2, 80.7}) do
		for _, x in ipairs({-2.2, 0, 2.2}) do
			part(
				area,
				"GardenShrub_" .. index .. "_" .. tostring(x),
				Vector3.new(1.35, 1.35, 1.35),
				CFrame.new(x, y, -5.2),
				COLORS.Green,
				Enum.Material.Grass,
				0,
				Enum.PartType.Ball
			)
		end
	end
end

local function addSkyTerraceDressing(root)
	local area = folder(root, "SkyTerraceDressing")

	for _, x in ipairs({-24, -12, 0, 12, 24}) do
		part(
			area,
			"TransferShrub_" .. tostring(x),
			Vector3.new(1.8, 1.8, 1.8),
			CFrame.new(x, 52.7, -25.8),
			COLORS.Green,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
	end
	addPalm(area, "TransferPalmLeft", Vector3.new(-27, 52.2, -24.8), 5.5, 15)
	addPalm(area, "TransferPalmRight", Vector3.new(27, 52.2, -24.8), 5.5, -15)

	for _, x in ipairs({10.5, 17.5, 24.5}) do
		part(
			area,
			"UpperTerraceShrub_" .. tostring(x),
			Vector3.new(1.5, 1.5, 1.5),
			CFrame.new(x, 72.7, -28.2),
			COLORS.Green,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
	end
	addPalm(area, "UpperTerracePalm", Vector3.new(24.5, 72.2, -28.0), 4.8, -10)
end

local function addRooftopDressing(root)
	local area = folder(root, "RooftopDressing")
	for _, z in ipairs({-8, 0, 8}) do
		part(
			area,
			"RoofShrubLeft_" .. tostring(z),
			Vector3.new(1.6, 1.6, 1.6),
			CFrame.new(-18, 86.3, z),
			COLORS.Green,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
		part(
			area,
			"RoofShrubRight_" .. tostring(z),
			Vector3.new(1.6, 1.6, 1.6),
			CFrame.new(18, 86.3, z),
			COLORS.Green,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
	end
end

local function addRearDressing(root)
	local area = folder(root, "RearDressing")
	local sign = block(
		area,
		"ServiceSign",
		Vector3.new(26, 1.8, 0.35),
		Vector3.new(0, 13.8, 37.85),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, sign, "RESIDENT SERVICE", Enum.NormalId.Back, COLORS.White)

	for index, x in ipairs({-11, 0, 11}) do
		local bay = block(
			area,
			"ServiceBayNumber" .. index,
			Vector3.new(3.5, 1.6, 0.28),
			Vector3.new(x, 8.9, 31.15),
			COLORS.Teal,
			Enum.Material.Neon
		)
		addSurfaceText(area, bay, string.format("%02d", index), Enum.NormalId.Back, COLORS.Dark)
	end
end

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityUptownResidencesDressing.Apply expects a Model")

	local existing = model:FindFirstChild("Dressing")
	if existing then existing:Destroy() end
	local root = folder(model, "Dressing")

	addEntranceDressing(root)
	addGardenSlotDressing(root)
	addSkyTerraceDressing(root)
	addRooftopDressing(root)
	addRearDressing(root)

	model:SetAttribute("AssetPhase", 5)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("DressingRevision", "LargeCityUptownResidences-Dressing-v1")
	model:SetAttribute("DressingStatus", "Approved")
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("GardenSlotVegetation", true)
	model:SetAttribute("SkyTerraceVegetation", true)
	model:SetAttribute("RooftopVegetation", true)
	return model
end

return Dressing
