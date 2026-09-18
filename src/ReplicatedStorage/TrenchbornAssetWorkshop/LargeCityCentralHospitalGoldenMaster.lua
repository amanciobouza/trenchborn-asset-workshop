local specification = require(script.Parent:WaitForChild("LargeCityCentralHospitalSpecification"))

local Builder = {}

local COLORS = {
	Concrete = Color3.fromRGB(229, 231, 226),
	Limestone = Color3.fromRGB(211, 212, 202),
	Glass = Color3.fromRGB(83, 151, 168),
	DarkGlass = Color3.fromRGB(43, 78, 89),
	Metal = Color3.fromRGB(164, 174, 177),
	MedicalRed = Color3.fromRGB(195, 52, 55),
	Teal = Color3.fromRGB(54, 154, 157),
	Roof = Color3.fromRGB(190, 195, 191),
	Landscape = Color3.fromRGB(69, 126, 78),
}

local function folder(parent, name)
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
	item.CanCollide = true
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function block(parent, name, size, position, color, material, rotation, transparency)
	local cf = CFrame.new(position)
	if rotation then
		cf *= CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
	end
	return part(parent, name, size, cf, color, material, transparency)
end

local function glass(parent, name, size, position, rotation, transparency)
	local item = block(parent, name, size, position, COLORS.Glass, Enum.Material.Glass, rotation, transparency or 0.18)
	item.Reflectance = 0.025
	return item
end

local function addMedicalCross(parent, prefix, position, scale, depth)
	local s = scale or 1
	local d = depth or 0.5
	block(parent, prefix .. "CrossVertical", Vector3.new(2.3 * s, 7.2 * s, d), position, COLORS.MedicalRed, Enum.Material.SmoothPlastic)
	block(parent, prefix .. "CrossHorizontal", Vector3.new(7.2 * s, 2.3 * s, d + 0.02), position - Vector3.new(0, 0, 0.02), COLORS.MedicalRed, Enum.Material.SmoothPlastic)
end

local function addWindowRow(parent, prefix, y, z, xCenters, width, rear)
	for index, x in ipairs(xCenters) do
		local window = glass(
			parent,
			prefix .. "Window" .. index,
			Vector3.new(width, 2.15, 0.36),
			Vector3.new(x, y, z),
			nil,
			0.16
		)
		window.CanCollide = false
	end

	local spanMin = xCenters[1] - width * 0.5
	local spanMax = xCenters[#xCenters] + width * 0.5
	block(
		parent,
		prefix .. "FacadeLedge",
		Vector3.new(spanMax - spanMin + 1.2, 0.28, 0.72),
		Vector3.new((spanMin + spanMax) * 0.5, y - 1.45, z + (rear and -0.12 or 0.12)),
		COLORS.Limestone,
		Enum.Material.Concrete
	)
end

local function addTowerFacade(groupLower, groupUpper)
	-- Lower tower: broad patient-room rhythm with a central solid medical spine.
	for floorIndex = 1, 8 do
		local y = 14.5 + (floorIndex - 1) * 4.0
		addWindowRow(groupLower, "LowerFrontF" .. floorIndex .. "_", y, -10.22, {-15.2, -9.8, 8.8, 14.2}, 4.4, false)
		addWindowRow(groupLower, "LowerRearF" .. floorIndex .. "_", y, 24.22, {-15.2, -9.8, 8.8, 14.2}, 4.4, true)
	end

	-- Strong glazed vertical circulation slot keeps the hospital silhouette distinct.
	glass(groupLower, "LowerVerticalAtrium", Vector3.new(5.2, 30.0, 0.42), Vector3.new(-1.0, 27.0, -10.28), nil, 0.13)
	for _, x in ipairs({-3.0, 1.0}) do
		block(groupLower, "LowerAtriumMullion" .. tostring(x), Vector3.new(0.32, 30, 0.65), Vector3.new(x, 27, -10.52), COLORS.Metal, Enum.Material.Metal)
	end

	-- Upper tower steps back slightly but preserves the same clinical rhythm.
	for floorIndex = 1, 7 do
		local y = 45.5 + (floorIndex - 1) * 4.0
		addWindowRow(groupUpper, "UpperFrontF" .. floorIndex .. "_", y, -7.22, {-12.8, -7.8, 8.8, 13.8}, 4.0, false)
		addWindowRow(groupUpper, "UpperRearF" .. floorIndex .. "_", y, 24.22, {-12.8, -7.8, 8.8, 13.8}, 4.0, true)
	end
	glass(groupUpper, "UpperVerticalAtrium", Vector3.new(4.8, 26, 0.42), Vector3.new(0, 59, -7.28), nil, 0.13)
end

local function addMainTower(groupLower, groupUpper)
	block(groupLower, "TowerLowerMass", Vector3.new(46, 34, 34), Vector3.new(0, 27, 7), COLORS.Concrete, Enum.Material.Concrete)
	block(groupLower, "TowerLowerSpine", Vector3.new(8.5, 35.5, 35.4), Vector3.new(1.5, 27.5, 7), COLORS.Limestone, Enum.Material.Concrete)
	block(groupLower, "TowerLowerLeftCap", Vector3.new(4.0, 33, 35.0), Vector3.new(-21, 27, 7), COLORS.Limestone, Enum.Material.Concrete)
	block(groupLower, "TowerLowerRightCap", Vector3.new(4.0, 33, 35.0), Vector3.new(21, 27, 7), COLORS.Limestone, Enum.Material.Concrete)

	block(groupUpper, "TowerUpperMass", Vector3.new(40, 30, 31), Vector3.new(2, 59, 8.5), COLORS.Concrete, Enum.Material.Concrete)
	block(groupUpper, "TowerUpperSpine", Vector3.new(8.0, 31.5, 32.2), Vector3.new(2, 59.5, 8.5), COLORS.Limestone, Enum.Material.Concrete)
	block(groupUpper, "TowerUpperRoofBand", Vector3.new(42, 1.2, 32.5), Vector3.new(2, 74.2, 8.5), COLORS.Roof, Enum.Material.Concrete)

	addTowerFacade(groupLower, groupUpper)
	addMedicalCross(groupUpper, "Tower", Vector3.new(2, 61, -7.35), 0.92, 0.5)
end

local function addDiagnosticPodium(group)
	block(group, "DiagnosticPodiumMass", Vector3.new(78, 14, 42), Vector3.new(5, 8, 8), COLORS.Limestone, Enum.Material.Concrete)
	block(group, "PodiumRoofSlab", Vector3.new(80, 0.9, 44), Vector3.new(5, 15.15, 8), COLORS.Roof, Enum.Material.Concrete)

	glass(group, "MainLobbyGlass", Vector3.new(32, 6.2, 0.42), Vector3.new(5, 7.2, -13.22), nil, 0.12)
	for _, x in ipairs({-9, -4.5, 0, 4.5, 9, 13.5, 18}) do
		block(group, "LobbyMullion" .. tostring(x), Vector3.new(0.32, 6.2, 0.62), Vector3.new(x, 7.2, -13.48), COLORS.Metal, Enum.Material.Metal)
	end

	-- Horizontal clinical glazing on both sides of the entrance.
	for floorIndex = 1, 2 do
		local y = 5.0 + (floorIndex - 1) * 4.1
		glass(group, "PodiumLeftGlass" .. floorIndex, Vector3.new(18, 2.2, 0.38), Vector3.new(-24, y, -13.24), nil, 0.17)
		glass(group, "PodiumRightGlass" .. floorIndex, Vector3.new(18, 2.2, 0.38), Vector3.new(34, y, -13.24), nil, 0.17)
	end

	block(group, "MainEntranceCanopy", Vector3.new(29, 0.8, 9), Vector3.new(5, 7.0, -18.0), COLORS.Concrete, Enum.Material.Concrete)
	for _, x in ipairs({-6, 16}) do
		block(group, "MainEntranceColumn" .. tostring(x), Vector3.new(0.8, 6.3, 0.8), Vector3.new(x, 3.3, -18.0), COLORS.Metal, Enum.Material.Metal)
	end

	block(group, "MainForecourt", Vector3.new(61, 0.55, 13), Vector3.new(5, 0.35, -25), COLORS.Limestone, Enum.Material.Concrete)
end

local function addEmergencyWing(group, canopyGroup)
	block(group, "EmergencyWingMass", Vector3.new(38, 13, 29), Vector3.new(-43, 7.5, -4), COLORS.Concrete, Enum.Material.Concrete)
	block(group, "EmergencyRoofBand", Vector3.new(40, 0.9, 31), Vector3.new(-43, 14.45, -4), COLORS.Roof, Enum.Material.Concrete)

	for floorIndex = 1, 2 do
		local y = 5.1 + (floorIndex - 1) * 4.1
		glass(group, "EmergencyFrontGlass" .. floorIndex, Vector3.new(24, 2.2, 0.38), Vector3.new(-43, y, -18.72), nil, 0.16)
	end
	addMedicalCross(group, "Emergency", Vector3.new(-57, 8.0, -18.76), 0.58, 0.46)

	block(canopyGroup, "EmergencyCanopy", Vector3.new(34, 1.0, 16), Vector3.new(-43, 7.8, -27), COLORS.Concrete, Enum.Material.Concrete)
	block(canopyGroup, "EmergencyCanopyAccent", Vector3.new(27, 0.45, 2.0), Vector3.new(-43, 8.55, -34.1), COLORS.MedicalRed, Enum.Material.SmoothPlastic)
	for _, x in ipairs({-56, -47.5, -38.5, -30}) do
		block(canopyGroup, "EmergencyColumn" .. tostring(x), Vector3.new(0.75, 6.9, 0.75), Vector3.new(x, 3.45, -26.5), COLORS.Metal, Enum.Material.Metal)
	end
	block(canopyGroup, "AmbulanceApron", Vector3.new(39, 0.5, 20), Vector3.new(-43, 0.3, -31), Color3.fromRGB(116, 122, 123), Enum.Material.Concrete)
end

local function addSecondaryWing(group)
	block(group, "SecondaryWingMass", Vector3.new(42, 23, 31), Vector3.new(47, 12.5, 9), COLORS.Concrete, Enum.Material.Concrete)
	block(group, "SecondaryWingRoofBand", Vector3.new(44, 0.9, 33), Vector3.new(47, 24.45, 9), COLORS.Roof, Enum.Material.Concrete)

	for floorIndex = 1, 5 do
		local y = 4.8 + (floorIndex - 1) * 4.1
		glass(group, "SecondaryFrontGlass" .. floorIndex, Vector3.new(31, 2.15, 0.38), Vector3.new(47, y, -6.72), nil, 0.16)
		block(group, "SecondaryFrontLedge" .. floorIndex, Vector3.new(33, 0.28, 0.7), Vector3.new(47, y - 1.45, -6.45), COLORS.Limestone, Enum.Material.Concrete)
	end

	glass(group, "SecondaryCornerGlass", Vector3.new(0.38, 17.5, 15), Vector3.new(68.22, 12.5, 4), nil, 0.17)
end

local function addHelipadAndPlant(group)
	block(group, "HelipadDeck", Vector3.new(31, 1.0, 31), Vector3.new(2, 75.2, 8.5), COLORS.Roof, Enum.Material.Concrete)
	block(group, "HelipadRaisedPad", Vector3.new(25, 0.45, 25), Vector3.new(2, 75.95, 8.5), Color3.fromRGB(145, 151, 150), Enum.Material.Concrete)

	-- Perimeter rails are physical silhouette geometry; painted H/ring waits for Dressing.
	for _, x in ipairs({-12.5, 16.5}) do
		block(group, "HelipadRailX" .. tostring(x), Vector3.new(0.35, 1.2, 29), Vector3.new(x, 76.6, 8.5), COLORS.Metal, Enum.Material.Metal)
	end
	for _, z in ipairs({-6, 23}) do
		block(group, "HelipadRailZ" .. tostring(z), Vector3.new(29, 1.2, 0.35), Vector3.new(2, 76.6, z), COLORS.Metal, Enum.Material.Metal)
	end

	block(group, "HelipadAccessCore", Vector3.new(8, 5, 7), Vector3.new(-17, 76.5, 13), COLORS.Concrete, Enum.Material.Concrete)

	local plantData = {
		{-22, 75.8, 1}, {-22, 75.8, 8}, {24, 75.8, 4}, {24, 75.8, 12}, {19, 75.8, 20},
	}
	for index, data in ipairs(plantData) do
		local x, y, z = table.unpack(data)
		block(group, "HVACUnit" .. index, Vector3.new(6, 2.4, 5), Vector3.new(x, y, z), COLORS.Metal, Enum.Material.Metal)
		block(group, "HVACCap" .. index, Vector3.new(4.5, 0.35, 3.5), Vector3.new(x, y + 1.35, z), COLORS.DarkGlass, Enum.Material.Metal)
	end

	for index, x in ipairs({-25, -20, 22, 27}) do
		local vent = part(
			group,
			"VentStack" .. index,
			Vector3.new(4.5, 0.75, 0.75),
			CFrame.new(x, 78.2, 19) * CFrame.Angles(0, 0, math.rad(90)),
			COLORS.Metal,
			Enum.Material.Metal,
			0,
			Enum.PartType.Cylinder
		)
		vent.CanCollide = false
	end
end

local function addLandscapeReferences(model)
	local landscape = folder(model, "LandscapeReferences")
	for index, position in ipairs({
		Vector3.new(-48, 4, -42), Vector3.new(-31, 4, -43), Vector3.new(-8, 4, -37), Vector3.new(22, 4, -37),
		Vector3.new(45, 4, -34), Vector3.new(57, 4, -25), Vector3.new(-55, 4, 21), Vector3.new(60, 4, 27),
	}) do
		block(landscape, "PalmPlaceholder" .. index, Vector3.new(1.0, 8, 1.0), position, COLORS.Landscape, Enum.Material.SmoothPlastic)
	end
	landscape:SetAttribute("Phase5ReplaceWithDressedPalms", true)
end

local function countVisibleParts(model)
	local count = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			count += 1
		end
	end
	model:SetAttribute("VisiblePartCount", count)
	model:SetAttribute("VisiblePartBudget", 750)
	model:SetAttribute("VisiblePartBudgetPassed", count <= 750)
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("LargeCity_CentralHospital_L3_GoldenMaster")
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = "LargeCity_CentralHospital_L3_GoldenMaster"
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("AssetPhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("GeometryRevision", "CentralHospital-v1")
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("Style", specification.Style)
	model.Parent = parent

	local groups = folder(model, "DestructionGroups")
	local d1 = folder(groups, "D1_EmergencyCanopy")
	local d2 = folder(groups, "D2_DiagnosticPodium")
	local d3 = folder(groups, "D3_EmergencyWing")
	local d4 = folder(groups, "D4_SecondaryWing")
	local d5 = folder(groups, "D5_MainTowerLower")
	local d6 = folder(groups, "D6_MainTowerUpper")
	local d7 = folder(groups, "D7_HelipadRoofPlant")

	addDiagnosticPodium(d2)
	addEmergencyWing(d3, d1)
	addSecondaryWing(d4)
	addMainTower(d5, d6)
	addHelipadAndPlant(d7)
	addLandscapeReferences(model)

	local pivot = part(model, "GroundPivot", Vector3.new(1, 1, 1), CFrame.new(0, 0.5, 0), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, 1)
	pivot.CanCollide = false
	pivot.CanQuery = false
	pivot.CastShadow = false
	model.PrimaryPart = pivot
	model:PivotTo(CFrame.new())

	countVisibleParts(model)
	return model
end

return Builder
