local Dressing = {}

local COLORS = {
	White = Color3.fromRGB(245, 247, 244),
	Dark = Color3.fromRGB(39, 46, 49),
	Concrete = Color3.fromRGB(216, 216, 207),
	ConcreteDark = Color3.fromRGB(165, 169, 165),
	Glass = Color3.fromRGB(58, 101, 112),
	Teal = Color3.fromRGB(57, 173, 178),
	Bronze = Color3.fromRGB(154, 113, 72),
	Green = Color3.fromRGB(64, 126, 74),
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
	local h = height or 7
	cylinder(palm, "Trunk", h, 0.7, position + Vector3.new(0, h * 0.5, 0), COLORS.Wood, Enum.Material.Wood)

	local crown = position + Vector3.new(0, h, 0)
	for index = 1, 7 do
		local angle = math.rad((index - 1) * (360 / 7) + (yaw or 0))
		local leaf = block(
			palm,
			"Leaf" .. index,
			Vector3.new(0.55, 0.22, 3.8),
			crown + Vector3.new(math.cos(angle) * 1.25, 0.1, math.sin(angle) * 1.25),
			COLORS.Green,
			Enum.Material.Grass
		)
		leaf.CFrame *= CFrame.Angles(math.rad(-13), angle, 0)
	end
end

local function addShrub(parent, name, position, diameter)
	return part(
		parent,
		name,
		Vector3.new(diameter, diameter, diameter),
		CFrame.new(position),
		COLORS.Green,
		Enum.Material.Grass,
		0,
		Enum.PartType.Ball
	)
end

local function addEntryDressing(root)
	local area = folder(root, "EntryDressing")

	local parkingSign = block(
		area,
		"ParkingIdentity",
		Vector3.new(18, 3.2, 0.35),
		Vector3.new(-22.5, 13.0, -30.35),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, parkingSign, "UPTOWN  P", Enum.NormalId.Front, COLORS.White)

	-- Generic parking wayfinding only; no EV-charging identity.
	local entrySign = block(
		area,
		"VehicleEntrySign",
		Vector3.new(20, 2.0, 0.30),
		Vector3.new(7, 8.8, -37.15),
		COLORS.Teal,
		Enum.Material.Neon
	)
	addSurfaceText(area, entrySign, "ENTRY  •  EXIT", Enum.NormalId.Front, COLORS.Dark)

	for index, x in ipairs({-1, 5, 11, 17}) do
		local bay = block(
			area,
			"ParkingBayMarker_" .. index,
			Vector3.new(4.2, 1.7, 0.25),
			Vector3.new(x, 5.6, -37.18),
			index % 2 == 0 and COLORS.Bronze or COLORS.Teal,
			Enum.Material.Neon
		)
		addSurfaceText(area, bay, string.format("P%d", index), Enum.NormalId.Front, COLORS.Dark)
	end

	for _, x in ipairs({-29, -25, -21}) do
		cylinder(area, "PedestrianBollard_" .. tostring(x), 1.9, 0.3, Vector3.new(x, 0.95, -34.2), COLORS.ConcreteDark, Enum.Material.Metal)
	end
end

local function addGreenCutDressing(root)
	local area = folder(root, "GreenCutDressing")

	local frontBeds = {
		{y = 20.375, z = -32.0},
		{y = 26.175, z = -32.0},
		{y = 31.975, z = -32.0},
	}
	for level, bed in ipairs(frontBeds) do
		for index, x in ipairs({-18, -14, -10, -6}) do
			addShrub(area, "FrontCutShrub_" .. level .. "_" .. index, Vector3.new(x, bed.y + 0.45, bed.z), 1.35)
		end
	end
	addPalm(area, "FrontCutPalm", Vector3.new(-12, 31.85, -32.0), 4.8, 10)

	local rearBeds = {
		{y = 32.175, z = 32.0},
		{y = 37.675, z = 32.0},
		{y = 43.175, z = 32.0},
	}
	for level, bed in ipairs(rearBeds) do
		for index, x in ipairs({9, 13, 17, 20}) do
			addShrub(area, "RearCutShrub_" .. level .. "_" .. index, Vector3.new(x, bed.y + 0.45, bed.z), 1.25)
		end
	end
end

local function addRooftopDressing(root)
	local area = folder(root, "RooftopDressing")

	-- Planter tops are Y=45.8. Embed greenery slightly into them.
	for _, z in ipairs({-12, -4, 4, 12}) do
		addShrub(area, "RoofLeftShrub_" .. tostring(z), Vector3.new(-27, 46.25, z), 1.5)
	end
	addPalm(area, "RoofLeftPalm", Vector3.new(-27, 45.65, 16), 5.0, 15)

	for _, x in ipairs({-6, 2, 10, 18}) do
		addShrub(area, "RoofRearShrub_" .. tostring(x), Vector3.new(x, 46.25, 23), 1.5)
	end

	local roofSign = block(
		area,
		"MobilityDeckSign",
		Vector3.new(20, 2.0, 0.3),
		Vector3.new(0, 50.45, -14.5),
		COLORS.Teal,
		Enum.Material.Neon
	)
	addSurfaceText(area, roofSign, "MOBILITY DECK", Enum.NormalId.Front, COLORS.Dark)
end

local function addRearDressing(root)
	local area = folder(root, "RearDressing")
	local sign = block(
		area,
		"ServiceSign",
		Vector3.new(18, 1.8, 0.32),
		Vector3.new(-16, 10.0, 36.65),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, sign, "SERVICE", Enum.NormalId.Back, COLORS.White)

	for index, x in ipairs({-20, -12}) do
		local bay = block(
			area,
			"ServiceBay_" .. index,
			Vector3.new(3.5, 1.6, 0.26),
			Vector3.new(x, 7.8, 30.75),
			COLORS.Teal,
			Enum.Material.Neon
		)
		addSurfaceText(area, bay, string.format("%02d", index), Enum.NormalId.Back, COLORS.Dark)
	end
end

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityUptownParkingDressing.Apply expects a Model")

	local existing = model:FindFirstChild("Dressing")
	if existing then existing:Destroy() end
	local root = folder(model, "Dressing")

	addEntryDressing(root)
	addGreenCutDressing(root)
	addRooftopDressing(root)
	addRearDressing(root)

	model:SetAttribute("AssetPhase", 5)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("DressingRevision", "LargeCityUptownParking-Dressing-v2-NoEV")
	model:SetAttribute("DressingStatus", "Review")
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("GreenCutVegetation", true)
	model:SetAttribute("RooftopVegetation", true)
	model:SetAttribute("GenericParkingWayfinding", true)
	model:SetAttribute("HighContrastNeonText", true)
	return model
end

return Dressing
