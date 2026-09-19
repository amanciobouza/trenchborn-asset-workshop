local specification = require(script.Parent:WaitForChild("LargeCityUptownResidencesSpecification"))

local Builder = {}

local COLORS = {
	Stone = Color3.fromRGB(226, 222, 211),
	StoneDark = Color3.fromRGB(181, 181, 174),
	Glass = Color3.fromRGB(54, 96, 108),
	DarkGlass = Color3.fromRGB(32, 61, 72),
	Metal = Color3.fromRGB(176, 180, 177),
	Dark = Color3.fromRGB(42, 47, 49),
	Teal = Color3.fromRGB(62, 166, 170),
	Warm = Color3.fromRGB(222, 171, 101),
	PlantBed = Color3.fromRGB(67, 83, 62),
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

local function addRoundedMass(parent, prefix, center, width, depth, height, radius, color, material)
	local r = math.min(radius, width * 0.18, depth * 0.18)

	-- Non-overlapping rounded rectangle construction prevents roof/floor Z-fighting.
	block(parent, prefix .. "_Center", Vector3.new(width - 2 * r, height, depth - 2 * r), center, color, material)
	block(parent, prefix .. "_Front", Vector3.new(width - 2 * r, height, r), center + Vector3.new(0, 0, -(depth / 2 - r / 2)), color, material)
	block(parent, prefix .. "_Rear", Vector3.new(width - 2 * r, height, r), center + Vector3.new(0, 0, depth / 2 - r / 2), color, material)
	block(parent, prefix .. "_Left", Vector3.new(r, height, depth - 2 * r), center + Vector3.new(-(width / 2 - r / 2), 0, 0), color, material)
	block(parent, prefix .. "_Right", Vector3.new(r, height, depth - 2 * r), center + Vector3.new(width / 2 - r / 2, 0, 0), color, material)

	for _, sx in ipairs({-1, 1}) do
		for _, sz in ipairs({-1, 1}) do
			cylinder(
				parent,
				prefix .. string.format("_Corner_%d_%d", sx, sz),
				height,
				r * 2,
				center + Vector3.new(sx * (width / 2 - r), 0, sz * (depth / 2 - r)),
				color,
				material
			)
		end
	end
end

local function addFrontRearGlass(parent, prefix, center, width, depth, height, bays)
	local glassDepth = 0.6
	local glassWidth = width - 4
	local frontZ = center.Z - depth / 2 - glassDepth / 2 - 0.05
	local rearZ = center.Z + depth / 2 + glassDepth / 2 + 0.05

	block(parent, prefix .. "_GlassFront", Vector3.new(glassWidth, height - 2, glassDepth), Vector3.new(center.X, center.Y, frontZ), COLORS.Glass, Enum.Material.Glass, 0.08)
	block(parent, prefix .. "_GlassRear", Vector3.new(glassWidth, height - 2, glassDepth), Vector3.new(center.X, center.Y, rearZ), COLORS.Glass, Enum.Material.Glass, 0.08)

	for i = 0, bays do
		local x = center.X - glassWidth / 2 + glassWidth * i / bays
		block(parent, prefix .. "_MullionFront_" .. i, Vector3.new(0.55, height - 1.2, 0.82), Vector3.new(x, center.Y, frontZ - 0.15), COLORS.Metal, Enum.Material.Metal)
		block(parent, prefix .. "_MullionRear_" .. i, Vector3.new(0.55, height - 1.2, 0.82), Vector3.new(x, center.Y, rearZ + 0.15), COLORS.Metal, Enum.Material.Metal)
	end
end

local function addSideGlass(parent, prefix, center, width, depth, height, bays)
	local glassDepth = 0.6
	local glassLength = depth - 4
	local leftX = center.X - width / 2 - glassDepth / 2 - 0.05
	local rightX = center.X + width / 2 + glassDepth / 2 + 0.05

	block(parent, prefix .. "_GlassLeft", Vector3.new(glassDepth, height - 2, glassLength), Vector3.new(leftX, center.Y, center.Z), COLORS.Glass, Enum.Material.Glass, 0.08)
	block(parent, prefix .. "_GlassRight", Vector3.new(glassDepth, height - 2, glassLength), Vector3.new(rightX, center.Y, center.Z), COLORS.Glass, Enum.Material.Glass, 0.08)

	for i = 0, bays do
		local z = center.Z - glassLength / 2 + glassLength * i / bays
		block(parent, prefix .. "_MullionLeft_" .. i, Vector3.new(0.82, height - 1.2, 0.55), Vector3.new(leftX - 0.15, center.Y, z), COLORS.Metal, Enum.Material.Metal)
		block(parent, prefix .. "_MullionRight_" .. i, Vector3.new(0.82, height - 1.2, 0.55), Vector3.new(rightX + 0.15, center.Y, z), COLORS.Metal, Enum.Material.Metal)
	end
end

local function addResidentialBalconyLevel(parent, prefix, centerX, centerZ, width, depth, y, wrapSides)
	local projection = 4.4
	local slabDepth = projection
	local frontFace = centerZ - depth / 2
	local rearFace = centerZ + depth / 2
	local frontZ = frontFace - slabDepth / 2
	local rearZ = rearFace + slabDepth / 2
	local slabWidth = width + (wrapSides and 2.2 or 0)

	block(parent, prefix .. "_FrontSlab", Vector3.new(slabWidth, 0.72, slabDepth), Vector3.new(centerX, y, frontZ), COLORS.Stone, Enum.Material.Concrete)
	block(parent, prefix .. "_RearSlab", Vector3.new(slabWidth, 0.72, slabDepth), Vector3.new(centerX, y, rearZ), COLORS.Stone, Enum.Material.Concrete)

	block(parent, prefix .. "_FrontGlass", Vector3.new(slabWidth - 0.8, 1.35, 0.24), Vector3.new(centerX, y + 0.98, frontFace - projection + 0.18), COLORS.Glass, Enum.Material.Glass, 0.18)
	block(parent, prefix .. "_RearGlass", Vector3.new(slabWidth - 0.8, 1.35, 0.24), Vector3.new(centerX, y + 0.98, rearFace + projection - 0.18), COLORS.Glass, Enum.Material.Glass, 0.18)

	if wrapSides then
		local sideDepth = depth
		local sideProjection = 2.7
		local leftX = centerX - width / 2 - sideProjection / 2
		local rightX = centerX + width / 2 + sideProjection / 2

		block(parent, prefix .. "_LeftSlab", Vector3.new(sideProjection, 0.72, sideDepth - 4.5), Vector3.new(leftX, y, centerZ), COLORS.Stone, Enum.Material.Concrete)
		block(parent, prefix .. "_RightSlab", Vector3.new(sideProjection, 0.72, sideDepth - 4.5), Vector3.new(rightX, y, centerZ), COLORS.Stone, Enum.Material.Concrete)
		block(parent, prefix .. "_LeftGlass", Vector3.new(0.24, 1.35, sideDepth - 5.1), Vector3.new(centerX - width / 2 - sideProjection + 0.18, y + 0.98, centerZ), COLORS.Glass, Enum.Material.Glass, 0.18)
		block(parent, prefix .. "_RightGlass", Vector3.new(0.24, 1.35, sideDepth - 5.1), Vector3.new(centerX + width / 2 + sideProjection - 0.18, y + 0.98, centerZ), COLORS.Glass, Enum.Material.Glass, 0.18)
	end
end

local function addPodium(group)
	addRoundedMass(group, "Podium", Vector3.new(0, 7, 0), 72, 60, 14, 5, COLORS.Stone, Enum.Material.Concrete)

	-- Tall recessed residential lobby.
	block(group, "LobbyPortal", Vector3.new(36, 12.5, 3.0), Vector3.new(0, 6.4, -29.2), COLORS.Dark, Enum.Material.Metal)
	block(group, "LobbyGlass", Vector3.new(30, 11.0, 0.65), Vector3.new(0, 5.9, -31.1), COLORS.Glass, Enum.Material.Glass, 0.06)
	for _, x in ipairs({-15, -7.5, 0, 7.5, 15}) do
		block(group, "LobbyPier_" .. tostring(x), Vector3.new(0.95, 12.2, 1.2), Vector3.new(x, 6.1, -31.55), COLORS.Metal, Enum.Material.Metal)
	end

	-- Porte-cochere projects fully beyond the podium shell.
	block(group, "PorteCochereRoof", Vector3.new(38, 1.1, 11), Vector3.new(0, 12.7, -35.2), COLORS.Stone, Enum.Material.Metal)
	for _, x in ipairs({-16.5, 16.5}) do
		block(group, "PorteCochereColumn_" .. tostring(x), Vector3.new(1.5, 12.2, 1.5), Vector3.new(x, 6.1, -39.7), COLORS.StoneDark, Enum.Material.Concrete)
	end
	block(group, "ArrivalPlinth", Vector3.new(52, 0.55, 15), Vector3.new(0, 0.28, -37.0), COLORS.StoneDark, Enum.Material.Concrete)
end

local function addLowerResidence(group)
	local center = Vector3.new(0, 32, 0)
	addRoundedMass(group, "LowerResidenceMass", center, 64, 54, 36, 4.5, COLORS.DarkGlass, Enum.Material.SmoothPlastic)
	addFrontRearGlass(group, "LowerResidence", center, 64, 54, 36, 8)
	addSideGlass(group, "LowerResidence", center, 64, 54, 36, 6)

	for index, y in ipairs({18.5, 24.0, 29.5, 35.0, 40.5, 46.0}) do
		addResidentialBalconyLevel(group, "LowerBalcony_" .. index, 0, 0, 64, 54, y, index % 2 == 1)
	end
end

local function addTransferTerrace(group)
	-- The transfer terrace projects beyond the lower residence and stays clear of glazing.
	block(group, "TransferTerraceSlab", Vector3.new(70, 1.35, 58), Vector3.new(0, 50.7, 0), COLORS.Stone, Enum.Material.Concrete)
	block(group, "TransferTerraceFrontRail", Vector3.new(68, 1.45, 0.28), Vector3.new(0, 51.75, -29.0), COLORS.Glass, Enum.Material.Glass, 0.18)
	block(group, "TransferTerraceRearRail", Vector3.new(68, 1.45, 0.28), Vector3.new(0, 51.75, 29.0), COLORS.Glass, Enum.Material.Glass, 0.18)
	block(group, "TransferPlantBedFront", Vector3.new(52, 0.8, 4.0), Vector3.new(0, 51.8, -25.8), COLORS.PlantBed, Enum.Material.Ground)
	block(group, "TransferPlantBedRear", Vector3.new(42, 0.8, 4.0), Vector3.new(0, 51.8, 25.8), COLORS.PlantBed, Enum.Material.Ground)
	block(group, "TransferAccentFront", Vector3.new(62, 0.45, 0.55), Vector3.new(0, 52.25, -29.35), COLORS.Teal, Enum.Material.Neon)
end

local function addUpperWing(group, prefix, center)
	local width, depth, height = 27, 45, 32
	addRoundedMass(group, prefix .. "Mass", center, width, depth, height, 3.5, COLORS.DarkGlass, Enum.Material.SmoothPlastic)
	addFrontRearGlass(group, prefix, center, width, depth, height, 4)
	addSideGlass(group, prefix, center, width, depth, height, 5)

	for index, y in ipairs({54.5, 59.8, 65.1, 70.4, 75.7, 81.0}) do
		addResidentialBalconyLevel(group, prefix .. "_Balcony_" .. index, center.X, center.Z, width, depth, y, index % 2 == 0)
	end
end

local function addVerticalGardenSlot(group)
	-- Recessed back wall and planted ledges preserve a true open slot between wings.
	block(group, "GardenSlotBack", Vector3.new(7.0, 31.0, 0.65), Vector3.new(0, 67, 12.5), COLORS.Dark, Enum.Material.Metal)
	block(group, "GardenSlotGlass", Vector3.new(6.2, 29.0, 0.45), Vector3.new(0, 67, 12.05), COLORS.DarkGlass, Enum.Material.Glass, 0.06)

	for index, y in ipairs({57.0, 64.5, 72.0, 79.5}) do
		block(group, "GardenLedge_" .. index, Vector3.new(7.0, 0.65, 21.0), Vector3.new(0, y, 1.5), COLORS.Stone, Enum.Material.Concrete)
		block(group, "GardenBed_" .. index, Vector3.new(5.8, 0.7, 6.5), Vector3.new(0, y + 0.7, -5.2), COLORS.PlantBed, Enum.Material.Ground)
		block(group, "GardenGlow_" .. index, Vector3.new(5.8, 0.28, 0.35), Vector3.new(0, y + 1.1, -8.5), COLORS.Warm, Enum.Material.Neon)
	end
end

local function addUpperSkyTerrace(group)
	-- Asymmetric front terrace anchored to the right wing and fully projected.
	block(group, "UpperSkyTerraceSlab", Vector3.new(24, 1.0, 10), Vector3.new(17.5, 70.8, -26.8), COLORS.Stone, Enum.Material.Concrete)
	block(group, "UpperSkyTerraceRail", Vector3.new(23, 1.4, 0.24), Vector3.new(17.5, 71.8, -31.7), COLORS.Glass, Enum.Material.Glass, 0.18)
	block(group, "UpperSkyTerraceBed", Vector3.new(18, 0.7, 3.3), Vector3.new(17.5, 71.7, -28.2), COLORS.PlantBed, Enum.Material.Ground)
	block(group, "UpperSkyTerraceAccent", Vector3.new(21, 0.4, 0.45), Vector3.new(17.5, 72.1, -31.95), COLORS.Teal, Enum.Material.Neon)
end

local function addRooftopClub(group)
	-- Light rooftop deck and pavilion; not a solid tower crown.
	block(group, "RoofDeck", Vector3.new(46, 1.2, 38), Vector3.new(0, 84.6, 0), COLORS.Stone, Enum.Material.Concrete)
	block(group, "RoofDeckFrontRail", Vector3.new(44, 1.4, 0.24), Vector3.new(0, 85.6, -19.0), COLORS.Glass, Enum.Material.Glass, 0.18)
	block(group, "RoofDeckRearRail", Vector3.new(44, 1.4, 0.24), Vector3.new(0, 85.6, 19.0), COLORS.Glass, Enum.Material.Glass, 0.18)
	block(group, "RoofPavilionGlass", Vector3.new(31, 5.0, 23), Vector3.new(0, 87.6, 1.5), COLORS.Glass, Enum.Material.Glass, 0.08)

	for _, x in ipairs({-16, 16}) do
		for _, z in ipairs({-12, 12}) do
			block(group, "RoofPost_" .. x .. "_" .. z, Vector3.new(0.9, 6.2, 0.9), Vector3.new(x, 88.1, z), COLORS.Metal, Enum.Material.Metal)
		end
	end

	block(group, "RoofCanopy", Vector3.new(40, 0.8, 31), Vector3.new(0, 91.35, 0), COLORS.Stone, Enum.Material.Metal)
	for index = 0, 8 do
		local x = -18 + index * 4.5
		block(group, "PergolaFin_" .. index, Vector3.new(0.45, 0.45, 34), Vector3.new(x, 91.85, 0), COLORS.Metal, Enum.Material.Metal)
	end
	block(group, "RoofPlantBedLeft", Vector3.new(8, 0.8, 24), Vector3.new(-18.0, 85.5, 0), COLORS.PlantBed, Enum.Material.Ground)
	block(group, "RoofPlantBedRight", Vector3.new(8, 0.8, 24), Vector3.new(18.0, 85.5, 0), COLORS.PlantBed, Enum.Material.Ground)
	block(group, "RoofTealEdge", Vector3.new(38, 0.45, 0.5), Vector3.new(0, 91.0, -15.65), COLORS.Teal, Enum.Material.Neon)
end

local function addRearService(group)
	-- Rear service is truly exterior (+Z) and remains visible below its canopy.
	block(group, "RearServiceHeader", Vector3.new(34, 3.2, 1.0), Vector3.new(0, 12.0, 30.55), COLORS.Dark, Enum.Material.Metal)
	for index, x in ipairs({-11, 0, 11}) do
		block(group, "RearServiceDoor_" .. index, Vector3.new(7, 7.5, 0.6), Vector3.new(x, 4.2, 30.65), COLORS.DarkGlass, Enum.Material.Metal)
		block(group, "RearServiceFrameTop_" .. index, Vector3.new(8.0, 0.55, 0.42), Vector3.new(x, 8.25, 31.0), COLORS.Metal, Enum.Material.Metal)
		block(group, "RearServiceFrameLeft_" .. index, Vector3.new(0.55, 7.8, 0.42), Vector3.new(x - 3.75, 4.2, 31.0), COLORS.Metal, Enum.Material.Metal)
		block(group, "RearServiceFrameRight_" .. index, Vector3.new(0.55, 7.8, 0.42), Vector3.new(x + 3.75, 4.2, 31.0), COLORS.Metal, Enum.Material.Metal)
	end
	block(group, "RearServiceCanopy", Vector3.new(40, 1.0, 7.5), Vector3.new(0, 13.8, 34.0), COLORS.StoneDark, Enum.Material.Metal)
	block(group, "RearServiceApron", Vector3.new(48, 0.45, 14), Vector3.new(0, 0.23, 38.0), COLORS.StoneDark, Enum.Material.Concrete)
end

local function countVisibleParts(model)
	local count = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			count += 1
		end
	end
	model:SetAttribute("VisiblePartCount", count)
	model:SetAttribute("VisiblePartBudget", 820)
	model:SetAttribute("VisiblePartBudgetPassed", count <= 820)
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("LargeCity_UptownResidences_L3_GoldenMaster")
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = "LargeCity_UptownResidences_L3_GoldenMaster"
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("AssetPhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("GeometryRevision", "LargeCityUptownResidences-v1-VerdantCascade")
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("UpperWingCount", 2)
	model:SetAttribute("CentralGardenSlotOpen", true)
	model:SetAttribute("BalconiesProjectedOutsideFacade", true)
	model:SetAttribute("SkyTerracesProjectedOutsideFacade", true)
	model.Parent = parent

	local groups = folder(model, "DestructionGroups")
	local d1 = folder(groups, "D1_ArrivalPodium")
	local d2 = folder(groups, "D2_LowerResidence")
	local d3 = folder(groups, "D3_LeftResidentialWing")
	local d4 = folder(groups, "D4_RightResidentialWing")
	local d5 = folder(groups, "D5_BalconiesAndSkyTerraces")
	local d6 = folder(groups, "D6_RooftopResidentsDeck")
	local d7 = folder(groups, "D7_ServiceCore")

	addPodium(d1)
	addLowerResidence(d2)
	addUpperWing(d3, "LeftWing", Vector3.new(-17.5, 67, 1))
	addUpperWing(d4, "RightWing", Vector3.new(17.5, 67, -2))
	addTransferTerrace(d5)
	addVerticalGardenSlot(d5)
	addUpperSkyTerrace(d5)
	addRooftopClub(d6)
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
