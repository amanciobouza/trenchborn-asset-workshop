local specification = require(script.Parent:WaitForChild("LargeCityStadiumHotelSpecification"))

local Builder = {}

local COLORS = {
	Stone = Color3.fromRGB(224, 219, 207),
	StoneDark = Color3.fromRGB(181, 178, 169),
	Glass = Color3.fromRGB(48, 89, 103),
	DarkGlass = Color3.fromRGB(31, 58, 68),
	Metal = Color3.fromRGB(169, 173, 171),
	Dark = Color3.fromRGB(42, 47, 50),
	Teal = Color3.fromRGB(58, 158, 164),
	Warm = Color3.fromRGB(230, 174, 96),
	Pool = Color3.fromRGB(54, 155, 181),
	PlantBed = Color3.fromRGB(68, 83, 63),
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

local function bowOffset(x, halfWidth, depth)
	local t = math.clamp(x / halfWidth, -1, 1)
	return depth * (1 - t * t)
end

local function bowTangentYaw(x, halfWidth, depth, front)
	-- Convert the facade slope dz/dx into Roblox yaw. A Part's local +X axis
	-- gains -Z when yaw is positive, so the visual yaw is the negative of the
	-- geometric slope angle. v1 omitted this sign inversion and made the
	-- convex facade windows read as if they curved inward.
	local derivative = -2 * depth * x / (halfWidth * halfWidth)
	if front then
		derivative = -derivative
	end
	return -math.atan(derivative)
end

local function addCurvedGuestFacade(parent, prefix, center, width, depth, height, bays, floors)
	local halfWidth = width / 2 - 3
	local bayWidth = (width - 6) / bays
	local frontBaseZ = center.Z - depth / 2 - 0.45
	local rearBaseZ = center.Z + depth / 2 + 0.45
	local floorHeight = height / floors
	local bowDepth = 2.8

	for floor = 1, floors do
		local y = center.Y - height / 2 + floorHeight * (floor - 0.5)
		for bay = 1, bays do
			local x = center.X - (width - 6) / 2 + bayWidth * (bay - 0.5)
			local localX = x - center.X
			local bow = bowOffset(localX, halfWidth, bowDepth)

			local frontZ = frontBaseZ - bow
			local rearZ = rearBaseZ + bow * 0.45
			local frontYaw = bowTangentYaw(localX, halfWidth, bowDepth, true)
			local rearYaw = bowTangentYaw(localX, halfWidth, bowDepth * 0.45, false)

			part(
				parent,
				prefix .. string.format("_FrontWindow_%02d_%02d", floor, bay),
				Vector3.new(bayWidth - 0.65, floorHeight - 1.2, 0.55),
				CFrame.new(x, y, frontZ) * CFrame.Angles(0, frontYaw, 0),
				COLORS.Glass,
				Enum.Material.Glass,
				0.08
			)
			part(
				parent,
				prefix .. string.format("_RearWindow_%02d_%02d", floor, bay),
				Vector3.new(bayWidth - 0.65, floorHeight - 1.2, 0.55),
				CFrame.new(x, y, rearZ) * CFrame.Angles(0, rearYaw, 0),
				COLORS.Glass,
				Enum.Material.Glass,
				0.08
			)
		end
	end
end

local function addCurvedBalconyBand(parent, prefix, center, width, depth, y, bays, projection)
	local halfWidth = width / 2 - 2
	local bayWidth = (width - 4) / bays
	local bowDepth = 3.0
	local frontBaseZ = center.Z - depth / 2 - 0.7
	local rearBaseZ = center.Z + depth / 2 + 0.7

	for bay = 1, bays do
		local x = center.X - (width - 4) / 2 + bayWidth * (bay - 0.5)
		local localX = x - center.X
		local bow = bowOffset(localX, halfWidth, bowDepth)

		local frontYaw = bowTangentYaw(localX, halfWidth, bowDepth, true)
		local rearYaw = bowTangentYaw(localX, halfWidth, bowDepth * 0.45, false)
		local frontZ = frontBaseZ - bow - projection / 2
		local rearZ = rearBaseZ + bow * 0.45 + projection / 2

		local frontCf = CFrame.new(x, y, frontZ) * CFrame.Angles(0, frontYaw, 0)
		local rearCf = CFrame.new(x, y, rearZ) * CFrame.Angles(0, rearYaw, 0)

		part(parent, prefix .. "_FrontSlab_" .. bay, Vector3.new(bayWidth + 0.18, 0.65, projection), frontCf, COLORS.Stone, Enum.Material.Concrete)
		part(parent, prefix .. "_RearSlab_" .. bay, Vector3.new(bayWidth + 0.18, 0.65, projection), rearCf, COLORS.Stone, Enum.Material.Concrete)

		part(
			parent,
			prefix .. "_FrontRail_" .. bay,
			Vector3.new(bayWidth - 0.18, 1.35, 0.23),
			frontCf * CFrame.new(0, 0.98, -(projection / 2 - 0.13)),
			COLORS.Glass,
			Enum.Material.Glass,
			0.17
		)
		part(
			parent,
			prefix .. "_RearRail_" .. bay,
			Vector3.new(bayWidth - 0.18, 1.35, 0.23),
			rearCf * CFrame.new(0, 0.98, projection / 2 - 0.13),
			COLORS.Glass,
			Enum.Material.Glass,
			0.17
		)
	end
end

local function addSideGuestWindows(parent, prefix, center, width, depth, height, bays, floors)
	local floorHeight = height / floors
	local bayDepth = (depth - 6) / bays
	local leftX = center.X - width / 2 - 0.45
	local rightX = center.X + width / 2 + 0.45

	for floor = 1, floors do
		local y = center.Y - height / 2 + floorHeight * (floor - 0.5)
		for bay = 1, bays do
			local z = center.Z - (depth - 6) / 2 + bayDepth * (bay - 0.5)
			block(parent, prefix .. string.format("_LeftWindow_%02d_%02d", floor, bay), Vector3.new(0.55, floorHeight - 1.2, bayDepth - 0.7), Vector3.new(leftX, y, z), COLORS.Glass, Enum.Material.Glass, 0.08)
			block(parent, prefix .. string.format("_RightWindow_%02d_%02d", floor, bay), Vector3.new(0.55, floorHeight - 1.2, bayDepth - 0.7), Vector3.new(rightX, y, z), COLORS.Glass, Enum.Material.Glass, 0.08)
		end
	end
end

local function addPodium(group)
	addRoundedMass(group, "Podium", Vector3.new(0, 8, 0), 74, 60, 16, 5, COLORS.Stone, Enum.Material.Concrete)

	-- Strong hotel arrival: lobby is recessed, canopy and supports project outward.
	block(group, "LobbyPortal", Vector3.new(40, 13.0, 3.2), Vector3.new(0, 6.7, -29.0), COLORS.Dark, Enum.Material.Metal)
	block(group, "LobbyGlass", Vector3.new(32, 12.0, 0.65), Vector3.new(0, 6.2, -31.0), COLORS.Glass, Enum.Material.Glass, 0.06)
	for _, x in ipairs({-15.5, -7.75, 0, 7.75, 15.5}) do
		block(group, "LobbyPier_" .. tostring(x), Vector3.new(0.95, 13.0, 1.1), Vector3.new(x, 6.5, -31.45), COLORS.Metal, Enum.Material.Metal)
	end

	block(group, "PorteCochereRoof", Vector3.new(42, 1.2, 12), Vector3.new(0, 14.1, -36.0), COLORS.Stone, Enum.Material.Metal)
	for _, x in ipairs({-18.5, 18.5}) do
		block(group, "PorteCochereColumn_" .. tostring(x), Vector3.new(1.6, 13.5, 1.6), Vector3.new(x, 6.75, -41.0), COLORS.StoneDark, Enum.Material.Concrete)
	end
	block(group, "ArrivalPlinth", Vector3.new(54, 0.55, 16), Vector3.new(0, 0.28, -39.0), COLORS.StoneDark, Enum.Material.Concrete)

	-- Restaurant/lounge glazing at podium flanks.
	block(group, "PodiumGlassLeft", Vector3.new(15, 9.0, 0.55), Vector3.new(-27, 5.2, -30.3), COLORS.Glass, Enum.Material.Glass, 0.08)
	block(group, "PodiumGlassRight", Vector3.new(15, 9.0, 0.55), Vector3.new(27, 5.2, -30.3), COLORS.Glass, Enum.Material.Glass, 0.08)
end

local function addGuestRoomBar(lowerGroup, upperGroup)
	local center = Vector3.new(0, 37, 0)
	addRoundedMass(lowerGroup, "GuestRoomMass", center, 66, 50, 42, 4.5, COLORS.DarkGlass, Enum.Material.SmoothPlastic)

	addCurvedGuestFacade(lowerGroup, "GuestRooms", center, 66, 50, 42, 10, 7)
	addSideGuestWindows(lowerGroup, "GuestRooms", center, 66, 50, 42, 6, 7)

	for index, y in ipairs({19.5, 25.4, 31.3, 37.2, 43.1, 49.0, 54.9}) do
		local targetGroup = index <= 4 and lowerGroup or upperGroup
		addCurvedBalconyBand(targetGroup, "GuestBalcony_" .. index, center, 66, 50, y, 10, 2.5)
	end

	-- Slim warm vertical end accents keep the long bar refined without reading as office fins.
	block(upperGroup, "EndAccentLeft", Vector3.new(0.55, 34, 0.55), Vector3.new(-32.8, 37, -22.5), COLORS.Warm, Enum.Material.Neon)
	block(upperGroup, "EndAccentRight", Vector3.new(0.55, 34, 0.55), Vector3.new(32.8, 37, -22.5), COLORS.Warm, Enum.Material.Neon)
end

local function addSkyLounge(group)
	local center = Vector3.new(3, 64, -1)
	addRoundedMass(group, "SkyLoungeMass", center, 54, 44, 12, 3.5, COLORS.DarkGlass, Enum.Material.SmoothPlastic)

	block(group, "SkyLoungeGlassFront", Vector3.new(49, 9.5, 0.62), Vector3.new(3, 64, -23.35), COLORS.Glass, Enum.Material.Glass, 0.06)
	block(group, "SkyLoungeGlassRear", Vector3.new(49, 9.5, 0.62), Vector3.new(3, 64, 21.35), COLORS.Glass, Enum.Material.Glass, 0.06)

	-- Terrace fully outside the lounge facade.
	block(group, "SkyLoungeTerrace", Vector3.new(48, 1.0, 8.5), Vector3.new(3, 59.2, -26.6), COLORS.Stone, Enum.Material.Concrete)
	block(group, "SkyLoungeRail", Vector3.new(47, 1.4, 0.24), Vector3.new(3, 60.2, -30.7), COLORS.Glass, Enum.Material.Glass, 0.17)
	block(group, "SkyLoungePlantBed", Vector3.new(28, 0.75, 3.0), Vector3.new(3, 60.15, -27.7), COLORS.PlantBed, Enum.Material.Ground)
	block(group, "SkyLoungeAccent", Vector3.new(42, 0.42, 0.5), Vector3.new(3, 60.55, -30.95), COLORS.Teal, Enum.Material.Neon)
end

local function addRooftopPoolDeck(group)
	-- Open rooftop deck rather than a solid crown.
	block(group, "RoofDeck", Vector3.new(58, 1.1, 46), Vector3.new(0, 70.6, 0), COLORS.Stone, Enum.Material.Concrete)

	-- Raised shallow pool and water plane.
	block(group, "PoolBasin", Vector3.new(36, 1.0, 11), Vector3.new(-4, 71.4, -7), COLORS.StoneDark, Enum.Material.Concrete)
	block(group, "PoolWater", Vector3.new(34, 0.35, 9), Vector3.new(-4, 72.0, -7), COLORS.Pool, Enum.Material.Glass, 0.18)

	-- Lounge deck and planted edge.
	block(group, "PoolLoungeDeck", Vector3.new(18, 0.65, 34), Vector3.new(20, 71.0, 3), COLORS.Stone, Enum.Material.Concrete)
	block(group, "PoolPlantBed", Vector3.new(6, 0.75, 30), Vector3.new(25, 71.7, 3), COLORS.PlantBed, Enum.Material.Ground)

	-- Pergola and canopy, kept light and open.
	for index = 0, 7 do
		local x = -17.5 + index * 5
		block(group, "PergolaFin_" .. index, Vector3.new(0.45, 0.45, 20), Vector3.new(x, 78.3, 10), COLORS.Metal, Enum.Material.Metal)
	end
	for _, x in ipairs({-19, 19}) do
		for _, z in ipairs({1, 19}) do
			block(group, "PergolaPost_" .. x .. "_" .. z, Vector3.new(0.8, 6.5, 0.8), Vector3.new(x, 75.0, z), COLORS.Metal, Enum.Material.Metal)
		end
	end
	block(group, "PergolaCanopy", Vector3.new(40, 0.7, 20), Vector3.new(0, 78.7, 10), COLORS.Stone, Enum.Material.Metal)

	-- Asymmetric event-hotel roof blade is lifted above the planted edge on two
	-- slim portal frames. The supports sit outside the planter footprint so the
	-- greenery remains visible underneath instead of being covered by the blade.
	block(group, "RoofBlade", Vector3.new(4.0, 8.0, 17), Vector3.new(24, 79.0, -8), COLORS.Stone, Enum.Material.Metal)
	block(group, "RoofBladeWarmLine", Vector3.new(0.5, 6.0, 14), Vector3.new(21.8, 79.0, -8), COLORS.Warm, Enum.Material.Neon)

	for frameIndex, z in ipairs({-14, -2}) do
		for _, x in ipairs({21, 29}) do
			block(
				group,
				"RoofBladeStilt_" .. frameIndex .. "_" .. tostring(x),
				Vector3.new(0.55, 3.18, 0.55),
				Vector3.new(x, 72.91, z),
				COLORS.Metal,
				Enum.Material.Metal
			)
		end
		block(
			group,
			"RoofBladeCrossbeam_" .. frameIndex,
			Vector3.new(8.55, 0.5, 0.6),
			Vector3.new(25, 74.75, z),
			COLORS.Metal,
			Enum.Material.Metal
		)
	end

	block(group, "RoofFrontRail", Vector3.new(56, 1.4, 0.24), Vector3.new(0, 71.6, -23.0), COLORS.Glass, Enum.Material.Glass, 0.17)
	block(group, "RoofRearRail", Vector3.new(56, 1.4, 0.24), Vector3.new(0, 71.6, 23.0), COLORS.Glass, Enum.Material.Glass, 0.17)
end

local function addRearService(group)
	block(group, "RearServiceMass", Vector3.new(54, 10, 6), Vector3.new(0, 5, 29.5), COLORS.StoneDark, Enum.Material.Concrete)

	for index, x in ipairs({-21, -7, 7, 21}) do
		block(group, "RearServiceDoor_" .. index, Vector3.new(7, 7.0, 0.6), Vector3.new(x, 4.0, 32.75), COLORS.DarkGlass, Enum.Material.Metal)
		block(group, "RearServiceFrameTop_" .. index, Vector3.new(8.0, 0.55, 0.42), Vector3.new(x, 7.75, 33.1), COLORS.Metal, Enum.Material.Metal)
		block(group, "RearServiceFrameLeft_" .. index, Vector3.new(0.55, 7.2, 0.42), Vector3.new(x - 3.75, 4.0, 33.1), COLORS.Metal, Enum.Material.Metal)
		block(group, "RearServiceFrameRight_" .. index, Vector3.new(0.55, 7.2, 0.42), Vector3.new(x + 3.75, 4.0, 33.1), COLORS.Metal, Enum.Material.Metal)
	end

	block(group, "RearServiceCanopy", Vector3.new(62, 1.0, 8), Vector3.new(0, 12.0, 36.0), COLORS.Metal, Enum.Material.Metal)
	block(group, "RearServiceApron", Vector3.new(68, 0.45, 16), Vector3.new(0, 0.23, 40.0), COLORS.StoneDark, Enum.Material.Concrete)

	-- Vertical screens visually integrate the back-of-house with hotel architecture.
	for _, x in ipairs({-29, 29}) do
		for index = 0, 4 do
			block(group, "ServiceScreen_" .. x .. "_" .. index, Vector3.new(0.45, 11, 0.7), Vector3.new(x + (x < 0 and index * 1.5 or -index * 1.5), 6.0, 31.5), COLORS.Stone, Enum.Material.Metal)
		end
	end
end

local function countVisibleParts(model)
	local count = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			count += 1
		end
	end
	model:SetAttribute("VisiblePartCount", count)
	model:SetAttribute("VisiblePartBudget", 800)
	model:SetAttribute("VisiblePartBudgetPassed", count <= 800)
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("LargeCity_StadiumHotel_L3_GoldenMaster")
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = "LargeCity_StadiumHotel_L3_GoldenMaster"
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("AssetPhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("GeometryRevision", "LargeCityStadiumHotel-v4-StiltedRoofBlade")
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("CurvedGuestRoomFacade", true)
	model:SetAttribute("ConvexFacadeYawCorrected", true)
	model:SetAttribute("RoofBladeAnchoredToDeck", true)
	model:SetAttribute("RoofBladeStiltedAbovePlanter", true)
	model:SetAttribute("RooftopPoolVisible", true)
	model:SetAttribute("SkyLoungeTerraceProjected", true)
	model:SetAttribute("RearServiceVisible", true)
	model.Parent = parent

	local groups = folder(model, "DestructionGroups")
	local d1 = folder(groups, "D1_ArrivalPodium")
	local d2 = folder(groups, "D2_LowerGuestRooms")
	local d3 = folder(groups, "D3_UpperGuestRooms")
	local d4 = folder(groups, "D4_SkyLounge")
	local d5 = folder(groups, "D5_RooftopPoolDeck")
	local d6 = folder(groups, "D6_EventMarqueeAndCanopies")
	local d7 = folder(groups, "D7_ServiceCore")

	addPodium(d1)
	addGuestRoomBar(d2, d3)
	addSkyLounge(d4)
	addRooftopPoolDeck(d5)

	-- Keep canopy/event identity in a coherent destruction group.
	block(d6, "ArrivalWarmEdge", Vector3.new(38, 0.45, 0.45), Vector3.new(0, 13.45, -42.05), COLORS.Warm, Enum.Material.Neon)
	block(d6, "EventMarqueeFrame", Vector3.new(24, 2.2, 0.45), Vector3.new(0, 11.4, -42.15), COLORS.Dark, Enum.Material.Metal)

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
