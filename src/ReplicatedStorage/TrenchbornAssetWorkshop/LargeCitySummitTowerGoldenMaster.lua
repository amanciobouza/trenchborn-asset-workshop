local specification = require(script.Parent:WaitForChild("LargeCitySummitTowerSpecification"))

local Builder = {}

local COLORS = {
	Stone = Color3.fromRGB(222, 220, 210),
	StoneDark = Color3.fromRGB(173, 177, 174),
	Glass = Color3.fromRGB(45, 83, 98),
	DarkGlass = Color3.fromRGB(28, 53, 65),
	Metal = Color3.fromRGB(171, 177, 176),
	Dark = Color3.fromRGB(38, 45, 49),
	Teal = Color3.fromRGB(57, 174, 178),
	PlantBed = Color3.fromRGB(67, 79, 63),
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
	item.CanTouch = true
	item.CanQuery = true
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

local function addChamferedMass(parent, prefix, center, width, depth, height, radius, bodyColor, bodyMaterial)
	local r = math.min(radius, width * 0.18, depth * 0.18)

	-- Tile the rounded rectangle with non-overlapping masses. The previous
	-- CoreX/CoreZ construction overlapped across a large area and produced
	-- coplanar top faces, which caused visible roof Z-fighting in Studio.
	block(
		parent,
		prefix .. "_Center",
		Vector3.new(width - 2 * r, height, depth - 2 * r),
		center,
		bodyColor,
		bodyMaterial
	)

	block(
		parent,
		prefix .. "_Front",
		Vector3.new(width - 2 * r, height, r),
		center + Vector3.new(0, 0, -(depth / 2 - r / 2)),
		bodyColor,
		bodyMaterial
	)
	block(
		parent,
		prefix .. "_Rear",
		Vector3.new(width - 2 * r, height, r),
		center + Vector3.new(0, 0, depth / 2 - r / 2),
		bodyColor,
		bodyMaterial
	)
	block(
		parent,
		prefix .. "_Left",
		Vector3.new(r, height, depth - 2 * r),
		center + Vector3.new(-(width / 2 - r / 2), 0, 0),
		bodyColor,
		bodyMaterial
	)
	block(
		parent,
		prefix .. "_Right",
		Vector3.new(r, height, depth - 2 * r),
		center + Vector3.new(width / 2 - r / 2, 0, 0),
		bodyColor,
		bodyMaterial
	)

	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			cylinder(
				parent,
				prefix .. string.format("_Corner_%d_%d", sx, sz),
				height,
				r * 2,
				center + Vector3.new(sx * (width / 2 - r), 0, sz * (depth / 2 - r)),
				bodyColor,
				bodyMaterial
			)
		end
	end
end

local function addFacadeFace(parent, prefix, center, width, height, depth, face, bays, floors)
	local glassDepth = 0.72
	local edge = 0.75
	local frameDepth = 0.95
	local horizontalBand = 0.42

	if face == "Front" or face == "Rear" then
		local z = center.Z + (face == "Front" and -(depth / 2 + glassDepth / 2 + 0.05) or (depth / 2 + glassDepth / 2 + 0.05))
		block(parent, prefix .. "_Glass_" .. face, Vector3.new(width - 4, height - 2.4, glassDepth), Vector3.new(center.X, center.Y, z), COLORS.Glass, Enum.Material.Glass, 0.08)
		for i = 0, bays do
			local x = center.X - (width - 4) / 2 + (width - 4) * i / bays
			block(parent, prefix .. "_V_" .. face .. "_" .. i, Vector3.new(edge, height - 1.0, frameDepth), Vector3.new(x, center.Y, z + (face == "Front" and -0.16 or 0.16)), COLORS.Metal, Enum.Material.Metal)
		end
		for i = 1, floors - 1 do
			local y = center.Y - height / 2 + height * i / floors
			block(parent, prefix .. "_H_" .. face .. "_" .. i, Vector3.new(width - 3.0, horizontalBand, frameDepth), Vector3.new(center.X, y, z + (face == "Front" and -0.18 or 0.18)), COLORS.StoneDark, Enum.Material.Metal)
		end
	else
		local x = center.X + (face == "Left" and -(width / 2 + glassDepth / 2 + 0.05) or (width / 2 + glassDepth / 2 + 0.05))
		block(parent, prefix .. "_Glass_" .. face, Vector3.new(glassDepth, height - 2.4, depth - 4), Vector3.new(x, center.Y, center.Z), COLORS.Glass, Enum.Material.Glass, 0.08)
		for i = 0, bays do
			local z = center.Z - (depth - 4) / 2 + (depth - 4) * i / bays
			block(parent, prefix .. "_V_" .. face .. "_" .. i, Vector3.new(frameDepth, height - 1.0, edge), Vector3.new(x + (face == "Left" and -0.16 or 0.16), center.Y, z), COLORS.Metal, Enum.Material.Metal)
		end
		for i = 1, floors - 1 do
			local y = center.Y - height / 2 + height * i / floors
			block(parent, prefix .. "_H_" .. face .. "_" .. i, Vector3.new(frameDepth, horizontalBand, depth - 3.0), Vector3.new(x + (face == "Left" and -0.18 or 0.18), y, center.Z), COLORS.StoneDark, Enum.Material.Metal)
		end
	end
end

local function addTowerTier(parent, prefix, center, width, depth, height, radius, longBays, shortBays, floors)
	addChamferedMass(parent, prefix .. "_Mass", center, width, depth, height, radius, COLORS.DarkGlass, Enum.Material.SmoothPlastic)
	addFacadeFace(parent, prefix, center, width, height, depth, "Front", longBays, floors)
	addFacadeFace(parent, prefix, center, width, height, depth, "Rear", longBays, floors)
	addFacadeFace(parent, prefix, center, width, height, depth, "Left", shortBays, floors)
	addFacadeFace(parent, prefix, center, width, height, depth, "Right", shortBays, floors)
end

local function addVerticalFins(parent, prefix, center, width, depth, height, longBays)
	local frontZ = center.Z - depth / 2 - 0.9
	local rearZ = center.Z + depth / 2 + 0.9
	local glassWidth = width - 4

	-- Strong facade fins must sit directly on window mullions. v1 positioned
	-- them as fractions of the tower width, so they drifted across the glazing.
	local indices
	if longBays >= 7 then
		indices = {1, 2, longBays - 2, longBays - 1}
	elseif longBays == 6 then
		indices = {1, 2, 4, 5}
	else
		indices = {1, 2, longBays - 2, longBays - 1}
	end

	for _, index in ipairs(indices) do
		local x = -glassWidth / 2 + glassWidth * index / longBays
		block(parent, prefix .. "_FrontFin_" .. index, Vector3.new(1.15, height + 3, 1.5), Vector3.new(center.X + x, center.Y, frontZ), COLORS.Stone, Enum.Material.Metal)
		block(parent, prefix .. "_RearFin_" .. index, Vector3.new(1.15, height + 3, 1.5), Vector3.new(center.X + x, center.Y, rearZ), COLORS.Stone, Enum.Material.Metal)
	end
end

local function addPodium(group)
	addChamferedMass(group, "Podium", Vector3.new(0, 9, 0), 64, 58, 18, 5, COLORS.Stone, Enum.Material.Concrete)

	-- Recessed front lobby: dark portal mass sits inside the main facade, with glass still farther back.
	block(group, "LobbyPortal", Vector3.new(34, 15, 3.2), Vector3.new(0, 8.0, -28.6), COLORS.Dark, Enum.Material.Metal)
	block(group, "LobbyGlass", Vector3.new(28, 13, 0.65), Vector3.new(0, 7.5, -30.4), COLORS.Glass, Enum.Material.Glass, 0.07)
	for _, x in ipairs({-14.5, -7.2, 0, 7.2, 14.5}) do
		block(group, "LobbyPier_" .. tostring(x), Vector3.new(1.2, 16.5, 2.0), Vector3.new(x, 8.25, -31.0), COLORS.Metal, Enum.Material.Metal)
	end
	block(group, "LobbyCanopy", Vector3.new(36, 1.4, 8), Vector3.new(0, 13.8, -33.2), COLORS.Stone, Enum.Material.Metal)
	block(group, "LobbyPlinth", Vector3.new(42, 0.6, 13), Vector3.new(0, 0.3, -33.0), COLORS.StoneDark, Enum.Material.Concrete)
end

local function addSkyGardens(group)
	-- Lower sky garden reads as a real projecting balcony. The former dark
	-- "recess" block sat directly across the curtain wall and looked like an
	-- unexplained black bar covering windows.
	block(group, "SkyGardenOneTerrace", Vector3.new(33, 1.3, 11.5), Vector3.new(-9.0, 57.8, -28.25), COLORS.Stone, Enum.Material.Concrete)
	block(group, "SkyGardenOneCanopy", Vector3.new(29, 0.9, 5.0), Vector3.new(-8.0, 61.1, -25.3), COLORS.StoneDark, Enum.Material.Metal)
	block(group, "SkyGardenOneRevealLeft", Vector3.new(0.9, 4.0, 4.5), Vector3.new(-22.0, 59.2, -25.3), COLORS.StoneDark, Enum.Material.Metal)
	block(group, "SkyGardenOneRevealRight", Vector3.new(0.9, 4.0, 4.5), Vector3.new(6.0, 59.2, -25.3), COLORS.StoneDark, Enum.Material.Metal)
	block(group, "SkyGardenOneBed", Vector3.new(27, 0.8, 4.4), Vector3.new(-9.0, 58.8, -29.6), COLORS.PlantBed, Enum.Material.Ground)
	block(group, "SkyGardenOneAccent", Vector3.new(31, 0.65, 0.7), Vector3.new(-9.0, 59.2, -34.15), COLORS.Teal, Enum.Material.Neon)

	-- Upper garden uses the same readable balcony language on the rear-right.
	block(group, "SkyGardenTwoTerrace", Vector3.new(25, 1.2, 11.5), Vector3.new(8.0, 92.4, 22.75), COLORS.Stone, Enum.Material.Concrete)
	block(group, "SkyGardenTwoCanopy", Vector3.new(21, 0.8, 4.5), Vector3.new(8.0, 95.2, 19.6), COLORS.StoneDark, Enum.Material.Metal)
	block(group, "SkyGardenTwoRevealLeft", Vector3.new(0.8, 3.4, 4.0), Vector3.new(-2.0, 93.6, 19.6), COLORS.StoneDark, Enum.Material.Metal)
	block(group, "SkyGardenTwoRevealRight", Vector3.new(0.8, 3.4, 4.0), Vector3.new(18.0, 93.6, 19.6), COLORS.StoneDark, Enum.Material.Metal)
	block(group, "SkyGardenTwoBed", Vector3.new(20, 0.75, 4.2), Vector3.new(8.0, 93.25, 23.8), COLORS.PlantBed, Enum.Material.Ground)
	block(group, "SkyGardenTwoAccent", Vector3.new(23, 0.65, 0.7), Vector3.new(8.0, 93.5, 28.35), COLORS.Teal, Enum.Material.Neon)
end

local function addCrown(group)
	-- Restore the more interesting raised rooftop volume from the earlier review,
	-- but keep all three crown blades entirely above it instead of embedding them.
	local center = Vector3.new(7, 119.5, -3)
	addChamferedMass(group, "CrownCore", center, 28, 24, 7, 2.8, COLORS.DarkGlass, Enum.Material.SmoothPlastic)

	-- Raised stepped blades. They intentionally extend slightly above the nominal
	-- plot height because they are lightweight crown features, not occupied floors.
	block(group, "CrownBladePrimary", Vector3.new(4.0, 6.0, 7.0), Vector3.new(13.0, 126.0, -5.0), COLORS.Stone, Enum.Material.Metal)
	block(group, "CrownBladeSecondary", Vector3.new(3.0, 5.0, 6.0), Vector3.new(4.0, 125.5, -8.0), COLORS.Stone, Enum.Material.Metal)
	block(group, "CrownBladeTertiary", Vector3.new(3.0, 4.0, 5.5), Vector3.new(-2.0, 125.0, 3.0), COLORS.StoneDark, Enum.Material.Metal)

	-- Light band sits on the upper edge of the raised crown core.
	block(group, "CrownLightFront", Vector3.new(28, 0.75, 0.8), Vector3.new(7, 122.8, -15.4), COLORS.Teal, Enum.Material.Neon)
	block(group, "CrownLightRear", Vector3.new(28, 0.75, 0.8), Vector3.new(7, 122.8, 9.4), COLORS.Teal, Enum.Material.Neon)
	block(group, "CrownLightLeft", Vector3.new(0.8, 0.75, 24), Vector3.new(-7.4, 122.8, -3), COLORS.Teal, Enum.Material.Neon)
	block(group, "CrownLightRight", Vector3.new(0.8, 0.75, 24), Vector3.new(21.4, 122.8, -3), COLORS.Teal, Enum.Material.Neon)
end
local function addRearService(group)
	-- Rear is true +Z and is deliberately placed outside the podium mass.
	block(group, "RearServiceHeader", Vector3.new(36, 4, 1.2), Vector3.new(0, 14.2, 29.8), COLORS.Dark, Enum.Material.Metal)
	for index, x in ipairs({-12, 0, 12}) do
		block(group, "RearServiceDoor_" .. index, Vector3.new(8, 8, 0.75), Vector3.new(x, 5.0, 29.55), COLORS.DarkGlass, Enum.Material.Metal)
		-- Four slim strips frame the opening without covering the door.
		block(group, "RearServiceFrameTop_" .. index, Vector3.new(9.4, 0.65, 0.45), Vector3.new(x, 9.35, 30.05), COLORS.Metal, Enum.Material.Metal)
		block(group, "RearServiceFrameBottom_" .. index, Vector3.new(9.4, 0.65, 0.45), Vector3.new(x, 0.65, 30.05), COLORS.Metal, Enum.Material.Metal)
		block(group, "RearServiceFrameLeft_" .. index, Vector3.new(0.65, 8.1, 0.45), Vector3.new(x - 4.35, 5.0, 30.05), COLORS.Metal, Enum.Material.Metal)
		block(group, "RearServiceFrameRight_" .. index, Vector3.new(0.65, 8.1, 0.45), Vector3.new(x + 4.35, 5.0, 30.05), COLORS.Metal, Enum.Material.Metal)
	end
	block(group, "RearServiceCanopy", Vector3.new(42, 1.2, 7.0), Vector3.new(0, 15.0, 33.0), COLORS.StoneDark, Enum.Material.Metal)
	block(group, "RearServiceApron", Vector3.new(48, 0.45, 13), Vector3.new(0, 0.23, 35.0), COLORS.StoneDark, Enum.Material.Concrete)
end

local function countVisibleParts(model)
	local count = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			count += 1
		end
	end
	model:SetAttribute("VisiblePartCount", count)
	model:SetAttribute("VisiblePartBudget", 760)
	model:SetAttribute("VisiblePartBudgetPassed", count <= 760)
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("LargeCity_SummitTower_L3_GoldenMaster")
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = "LargeCity_SummitTower_L3_GoldenMaster"
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("AssetPhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("GeometryRevision", "LargeCitySummitTower-v5-ProjectedSkyGardens")
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("SkyGardenCount", 2)
	model:SetAttribute("SetbackCount", 2)
	model:SetAttribute("RoofZFightingFix", true)
	model:SetAttribute("CrownBladesFullyExposed", true)
	model:SetAttribute("FacadeFinsAlignedToMullions", true)
	model:SetAttribute("SkyGardenBlackOverlayRemoved", true)
	model:SetAttribute("SkyGardensFullyProjected", true)
	model.Parent = parent

	local groups = folder(model, "DestructionGroups")
	local d1 = folder(groups, "D1_EntryPodium")
	local d2 = folder(groups, "D2_LowerTower")
	local d3 = folder(groups, "D3_MidTower")
	local d4 = folder(groups, "D4_UpperTower")
	local d5 = folder(groups, "D5_SkyGardens")
	local d6 = folder(groups, "D6_SummitCrown")
	local d7 = folder(groups, "D7_ServiceCore")

	addPodium(d1)

	addTowerTier(d2, "LowerTower", Vector3.new(0, 38, 0), 52, 46, 40, 4.0, 7, 6, 8)
	addVerticalFins(d2, "LowerTower", Vector3.new(0, 38, 0), 52, 46, 40, 7)

	addTowerTier(d3, "MidTower", Vector3.new(-3, 75, 2), 46, 42, 34, 4.0, 6, 5, 7)
	addVerticalFins(d3, "MidTower", Vector3.new(-3, 75, 2), 46, 42, 34, 6)

	addTowerTier(d4, "UpperTower", Vector3.new(3, 104, -1), 39, 36, 24, 3.5, 5, 5, 5)
	addVerticalFins(d4, "UpperTower", Vector3.new(3, 104, -1), 39, 36, 24, 5)

	addSkyGardens(d5)
	addCrown(d6)
	addRearService(d7)

	local pivot = part(model, "GroundPivot", Vector3.new(1, 1, 1), CFrame.new(0, 0.5, 0), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, 1)
	pivot.CanCollide = false
	pivot.CanTouch = false
	pivot.CanQuery = false
	pivot.CastShadow = false
	model.PrimaryPart = pivot
	model:PivotTo(CFrame.new())

	countVisibleParts(model)
	return model
end

return Builder
