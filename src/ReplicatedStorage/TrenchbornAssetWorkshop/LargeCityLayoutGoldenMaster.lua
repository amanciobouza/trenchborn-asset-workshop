local specification = require(script.Parent:WaitForChild("LargeCityLayoutSpecification"))

local Builder = {}

local COLORS = {
	Ground = Color3.fromRGB(91, 123, 76),
	GroundDark = Color3.fromRGB(66, 94, 61),
	Beach = Color3.fromRGB(214, 193, 145),
	Water = Color3.fromRGB(36, 119, 157),
	Road = Color3.fromRGB(45, 50, 55),
	RoadEdge = Color3.fromRGB(202, 205, 199),
	Plaza = Color3.fromRGB(163, 169, 166),
	Rock = Color3.fromRGB(83, 88, 84),
	Contour = Color3.fromRGB(235, 177, 65),
	Reserved = Color3.fromRGB(55, 214, 226),
}

local function folder(parent, name)
	local result = Instance.new("Folder")
	result.Name = name
	result.Parent = parent
	return result
end

local function part(parent, name, size, cf, color, material, transparency)
	local result = Instance.new("Part")
	result.Name = name
	result.Size = size
	result.CFrame = cf
	result.Color = color
	result.Material = material or Enum.Material.SmoothPlastic
	result.Transparency = transparency or 0
	result.Anchored = true
	result.CanCollide = true
	result.CastShadow = true
	result.TopSurface = Enum.SurfaceType.Smooth
	result.BottomSurface = Enum.SurfaceType.Smooth
	result.Parent = parent
	return result
end

local function addBillboard(parent, adornee, text, color, size, offset)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Adornee = adornee
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.MaxDistance = 900
	gui.Size = size or UDim2.fromOffset(220, 48)
	gui.StudsOffsetWorldSpace = offset or Vector3.new(0, 6, 0)
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(13, 19, 24)
	label.BackgroundTransparency = 0.12
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBold
	label.Text = text
	label.TextColor3 = color
	label.TextScaled = true
	label.TextStrokeTransparency = 0.55
	label.Parent = gui
	return gui
end

local function addRectOutline(parent, name, center, size, y, color)
	local thickness = 2
	part(parent, name .. "North", Vector3.new(size.X, 0.4, thickness), CFrame.new(center.X, y, center.Z - size.Y * 0.5), color, Enum.Material.Neon)
	part(parent, name .. "South", Vector3.new(size.X, 0.4, thickness), CFrame.new(center.X, y, center.Z + size.Y * 0.5), color, Enum.Material.Neon)
	part(parent, name .. "West", Vector3.new(thickness, 0.4, size.Y), CFrame.new(center.X - size.X * 0.5, y, center.Z), color, Enum.Material.Neon)
	part(parent, name .. "East", Vector3.new(thickness, 0.4, size.Y), CFrame.new(center.X + size.X * 0.5, y, center.Z), color, Enum.Material.Neon)
end

local function addRoadSegment(parent, name, from, to, width, index)
	local midpoint = (from + to) * 0.5 + Vector3.new(0, 0.65, 0)
	local length = (to - from).Magnitude
	local road = part(
		parent,
		string.format("%s_%02d", name:gsub("%s+", ""), index),
		Vector3.new(width, 1.1, length),
		CFrame.lookAt(midpoint, to + Vector3.new(0, 0.65, 0)),
		COLORS.Road,
		Enum.Material.Asphalt
	)
	road:SetAttribute("RoadName", name)
	road:SetAttribute("RoadWidth", width)
	return road
end

local function addRoad(parent, definition)
	for index = 1, #definition.Points - 1 do
		addRoadSegment(parent, definition.Name, definition.Points[index], definition.Points[index + 1], definition.Width, index)
	end
	if definition.Closed then
		addRoadSegment(parent, definition.Name, definition.Points[#definition.Points], definition.Points[1], definition.Width, #definition.Points)
	end
end

local function addTerrain(terrain, contours)
	part(terrain, "Ocean", Vector3.new(350, 5, 1640), CFrame.new(-825, -6.5, 0), COLORS.Water, Enum.Material.Glass, 0.1)
	part(terrain, "Beach", Vector3.new(120, 6, 1540), CFrame.new(-590, -1, 0), COLORS.Beach, Enum.Material.Sand)
	part(terrain, "CityBasin", Vector3.new(1440, 8, 1460), CFrame.new(80, 0, 0), COLORS.Ground, Enum.Material.Grass)

	part(terrain, "ResortPlateau", Vector3.new(470, 4, 1120), CFrame.new(-405, 4, 20), COLORS.Ground, Enum.Material.Grass)
	part(terrain, "SouthGatewayPlateau", Vector3.new(690, 8, 390), CFrame.new(0, 4, -520), COLORS.GroundDark, Enum.Material.Ground)
	part(terrain, "DowntownPlateau", Vector3.new(650, 16, 760), CFrame.new(0, 4, 0), COLORS.GroundDark, Enum.Material.Ground)
	part(terrain, "CivicPlateau", Vector3.new(420, 20, 630), CFrame.new(390, 6, -35), COLORS.Ground, Enum.Material.Grass)
	part(terrain, "MedicalTechnologyPlateau", Vector3.new(400, 24, 810), CFrame.new(600, 8, 120), COLORS.GroundDark, Enum.Material.Ground)
	part(terrain, "UptownPlateau", Vector3.new(800, 28, 390), CFrame.new(15, 10, 540), COLORS.Ground, Enum.Material.Grass)

	addRectOutline(contours, "Contour_006_", Vector3.new(-405, 0, 20), Vector2.new(470, 1120), 6.25, COLORS.Contour)
	addRectOutline(contours, "Contour_008_", Vector3.new(0, 0, -520), Vector2.new(690, 390), 8.25, COLORS.Contour)
	addRectOutline(contours, "Contour_012_", Vector3.new(0, 0, 0), Vector2.new(650, 760), 12.25, COLORS.Contour)
	addRectOutline(contours, "Contour_016_", Vector3.new(390, 0, -35), Vector2.new(420, 630), 16.25, COLORS.Contour)
	addRectOutline(contours, "Contour_020_", Vector3.new(600, 0, 120), Vector2.new(400, 810), 20.25, COLORS.Contour)
	addRectOutline(contours, "Contour_024_", Vector3.new(15, 0, 540), Vector2.new(800, 390), 24.25, COLORS.Contour)

	-- Large, readable mountain masses form the natural north/east map boundary.
	local mountainData = {
		{-690, 760, 170, 250, 130}, {-430, 790, 230, 280, 170}, {-130, 805, 250, 300, 220},
		{190, 810, 220, 285, 180}, {430, 800, 230, 270, 155}, {720, 755, 210, 240, 135},
		{850, 535, 210, 250, 150}, {865, 255, 190, 230, 130}, {870, -30, 180, 220, 120},
		{855, -315, 195, 245, 145}, {820, -610, 230, 270, 165},
	}
	for index, data in ipairs(mountainData) do
		local x, z, width, depth, height = table.unpack(data)
		local mountain = Instance.new("WedgePart")
		mountain.Name = string.format("MountainMass_%02d", index)
		mountain.Size = Vector3.new(width, height, depth)
		mountain.CFrame = CFrame.new(x, height * 0.5, z) * CFrame.Angles(0, math.rad(index % 2 == 0 and 180 or 0), 0)
		mountain.Color = index % 2 == 0 and COLORS.Rock or Color3.fromRGB(96, 104, 92)
		mountain.Material = Enum.Material.Rock
		mountain.Anchored = true
		mountain.CanCollide = true
		mountain.Parent = terrain
	end

	-- Tunnel portal at the north-east continuation to Mega City.
	part(terrain, "MegaCityTunnelVoid", Vector3.new(78, 52, 9), CFrame.new(650, 48, 710), Color3.fromRGB(13, 16, 18), Enum.Material.SmoothPlastic)
	part(terrain, "MegaCityTunnelLeft", Vector3.new(22, 70, 18), CFrame.new(600, 44, 707), COLORS.Rock, Enum.Material.Rock)
	part(terrain, "MegaCityTunnelRight", Vector3.new(22, 70, 18), CFrame.new(700, 44, 707), COLORS.Rock, Enum.Material.Rock)
	part(terrain, "MegaCityTunnelHeader", Vector3.new(122, 25, 18), CFrame.new(650, 85, 707), COLORS.Rock, Enum.Material.Rock)
end

local function addCentralHub(landmarks, markers)
	local plaza = part(
		landmarks,
		"CentralHub_GuardianArena",
		Vector3.new(1.2, specification.Dimensions.CentralHubDiameter, specification.Dimensions.CentralHubDiameter),
		CFrame.new(0, 12.85, 0) * CFrame.Angles(0, 0, math.rad(90)),
		COLORS.Plaza,
		Enum.Material.Concrete
	)
	plaza.Shape = Enum.PartType.Cylinder
	plaza:SetAttribute("GameplayPurpose", "Bastion-IV Colossus arena and Central Hub")

	for index = 1, 12 do
		local angle = (index / 12) * math.pi * 2
		local radius = 107
		part(
			landmarks,
			"HubBollard_" .. index,
			Vector3.new(3, 4, 3),
			CFrame.new(math.cos(angle) * radius, 15, math.sin(angle) * radius),
			Color3.fromRGB(75, 93, 103),
			Enum.Material.Metal
		)
	end

	local marker = part(markers, "CentralHub", Vector3.new(2, 2, 2), CFrame.new(0, 13, 0), COLORS.Reserved, Enum.Material.Neon, 1)
	marker.CanCollide = false
	addBillboard(landmarks, plaza, "CENTRAL HUB / BASTION ARENA", Color3.fromRGB(242, 221, 135), UDim2.fromOffset(320, 54), Vector3.new(0, 14, 0))
end

local function addDistrictMarkers(parent, districtById)
	for _, district in ipairs(specification.Districts) do
		districtById[district.Id] = district
		local post = part(parent, district.Id .. "DistrictMarker", Vector3.new(2, 7, 2), CFrame.new(district.Center + Vector3.new(0, 3.5, 0)), district.Color, Enum.Material.Neon)
		post.CanCollide = false
		addBillboard(parent, post, district.DisplayName, district.Color, UDim2.fromOffset(260, 46), Vector3.new(0, 7, 0))
	end
end

local function addBuilding(parent, plots, markers, definition, district)
	local plot = part(
		plots,
		definition.Id .. "_Plot",
		Vector3.new(definition.Footprint.X + 8, 0.8, definition.Footprint.Y + 8),
		CFrame.new(definition.Position + Vector3.new(0, 0.4, 0)) * CFrame.Angles(0, math.rad(definition.Yaw), 0),
		district.Color,
		Enum.Material.Concrete,
		0.18
	)
	plot:SetAttribute("BuildingId", definition.Id)
	plot:SetAttribute("DisplayName", definition.DisplayName)
	plot:SetAttribute("BuildingType", definition.BuildingType)
	plot:SetAttribute("District", definition.District)
	plot:SetAttribute("TerrainElevation", definition.Position.Y)

	if definition.Id == "LC-01" then
		plot.Name = definition.Id .. "_ReservedForApprovedResort"
		plot.Color = COLORS.Reserved
		plot.Material = Enum.Material.Neon
		plot.Transparency = 0.42

		local resortAnchor = part(
			markers,
			"ResortAnchor",
			Vector3.new(2, 2, 2),
			CFrame.new(definition.Position) * CFrame.Angles(0, math.rad(definition.Yaw), 0),
			COLORS.Reserved,
			Enum.Material.Neon,
			1
		)
		resortAnchor.CanCollide = false
		addBillboard(parent, plot, definition.Id .. "  " .. definition.DisplayName .. " (APPROVED MODEL)", COLORS.Reserved, UDim2.fromOffset(330, 46), Vector3.new(0, 7, 0))
		return
	end

	local mass = part(
		parent,
		definition.Id .. "_" .. definition.BuildingType:gsub("%s+", ""),
		Vector3.new(definition.Footprint.X, definition.Height, definition.Footprint.Y),
		CFrame.new(definition.Position + Vector3.new(0, definition.Height * 0.5 + 0.8, 0)) * CFrame.Angles(0, math.rad(definition.Yaw), 0),
		district.Color,
		Enum.Material.SmoothPlastic,
		0.12
	)
	mass:SetAttribute("BuildingId", definition.Id)
	mass:SetAttribute("DisplayName", definition.DisplayName)
	mass:SetAttribute("BuildingType", definition.BuildingType)
	mass:SetAttribute("District", definition.District)
	mass:SetAttribute("BlockoutOnly", true)

	local isLandmark = definition.Height >= 140
		or definition.BuildingType == "Stadium"
		or definition.BuildingType == "Arena"
		or definition.BuildingType == "Central Hospital"
		or definition.BuildingType == "Power Utility"
		or definition.BuildingType == "Pharma Plant"
		or definition.BuildingType == "Central Train Station"
		or definition.BuildingType == "Courthouse"
	if isLandmark then
		addBillboard(parent, mass, definition.Id .. "  " .. definition.DisplayName, Color3.fromRGB(245, 245, 235), UDim2.fromOffset(280, 44), Vector3.new(0, definition.Height * 0.5 + 5, 0))
	end
end

function Builder.Build(parent, options)
	options = options or {}
	local existing = parent:FindFirstChild(specification.AssetId)
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = specification.AssetId
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("City", specification.City)
	model:SetAttribute("PipelinePhase", specification.Phase)
	model:SetAttribute("QualityGate", specification.QualityGate)
	model:SetAttribute("BuildingPlotCount", #specification.Buildings)
	model:SetAttribute("LayoutStyle", specification.Style)
	model.Parent = parent

	local terrain = folder(model, "TerrainMesh")
	local contours = folder(model, "HeightContours")
	local roads = folder(model, "RoadNetwork")
	local plots = folder(model, "BuildingPlots")
	local buildings = folder(model, "BuildingMasses")
	local landmarks = folder(model, "Landmarks")
	local markers = folder(model, "Markers")

	local pivot = part(markers, "LayoutPivot", Vector3.new(2, 2, 2), CFrame.new(0, 0, 0), COLORS.Reserved, Enum.Material.Neon, 1)
	pivot.CanCollide = false
	model.PrimaryPart = pivot

	addTerrain(terrain, contours)
	for _, definition in ipairs(specification.Roads) do addRoad(roads, definition) end
	addCentralHub(landmarks, markers)

	local districtById = {}
	addDistrictMarkers(landmarks, districtById)
	for _, definition in ipairs(specification.Buildings) do
		addBuilding(buildings, plots, markers, definition, assert(districtById[definition.District]))
	end

	local guardianAnchor = part(markers, "GuardianReviewAnchor", Vector3.new(2, 2, 2), CFrame.new(-470, 6, 180), COLORS.Reserved, Enum.Material.Neon, 1)
	guardianAnchor.CanCollide = false
	local gateway = part(markers, "CityGateway", Vector3.new(2, 2, 2), CFrame.new(0, 9, -700), COLORS.Reserved, Enum.Material.Neon, 1)
	gateway.CanCollide = false
	local tunnel = part(markers, "MegaCityTunnel", Vector3.new(2, 2, 2), CFrame.new(650, 31, 665), COLORS.Reserved, Enum.Material.Neon, 1)
	tunnel.CanCollide = false

	model:PivotTo(options.OriginCFrame or CFrame.new())
	return model
end

return Builder
