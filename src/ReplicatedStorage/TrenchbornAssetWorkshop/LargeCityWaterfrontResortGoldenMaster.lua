local specification = require(script.Parent:WaitForChild("LargeCityWaterfrontResortSpecification"))

local Builder = {}
local COLORS = specification.Palette

local function folder(parent, name)
	local item = Instance.new("Folder")
	item.Name = name
	item.Parent = parent
	return item
end

local function part(parent, name, size, cf, color, material, transparency)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cf
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.Transparency = transparency or 0
	item.Anchored = true
	item.CanCollide = true
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function block(parent, name, size, position, color, material, rotation)
	local cf = CFrame.new(position)
	if rotation then
		cf *= CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
	end
	return part(parent, name, size, cf, color, material)
end

local function glass(parent, name, size, position, rotation, transparency)
	local item = block(parent, name, size, position, COLORS.Glass, Enum.Material.Glass, rotation)
	item.Transparency = transparency or 0.22
	item.Reflectance = 0.04
	return item
end

local function localToWorld(center, yawDegrees, localPosition)
	local cf = CFrame.new(center) * CFrame.Angles(0, math.rad(yawDegrees), 0) * CFrame.new(localPosition)
	return cf.Position
end

local function addBalconyRow(parent, prefix, center, y, localFrontZ, width, count, yawDegrees, depth)
	local spacing = width / count
	local balconyDepth = depth or 3.2
	for index = 1, count do
		local localX = -width / 2 + spacing * (index - 0.5)
		local slabPosition = localToWorld(Vector3.new(center.X, y, center.Z), yawDegrees or 0, Vector3.new(localX, 0, localFrontZ))
		local slab = block(
			parent,
			prefix .. "BalconySlab" .. index,
			Vector3.new(spacing * 0.90, 0.5, balconyDepth),
			slabPosition,
			COLORS.Concrete,
			Enum.Material.Concrete,
			Vector3.new(0, yawDegrees or 0, 0)
		)
		local railPosition = localToWorld(Vector3.new(center.X, y + 1.0, center.Z), yawDegrees or 0, Vector3.new(localX, 0, localFrontZ - balconyDepth / 2 + 0.1))
		local rail = glass(
			parent,
			prefix .. "BalconyRail" .. index,
			Vector3.new(spacing * 0.78, 1.5, 0.18),
			railPosition,
			Vector3.new(0, yawDegrees or 0, 0),
			0.16
		)
		rail.CanCollide = false
		slab.CanCollide = true
	end
end

local function addFacadeRibs(parent, prefix, xMin, xMax, yMin, yMax, z, count)
	for index = 0, count do
		local alpha = index / count
		local x = xMin + (xMax - xMin) * alpha
		local rib = block(
			parent,
			prefix .. "Rib" .. index,
			Vector3.new(0.38, yMax - yMin, 0.6),
			Vector3.new(x, (yMin + yMax) / 2, z),
			COLORS.Metal,
			Enum.Material.Metal
		)
		rib.CanCollide = false
	end
end

local function addTower(groupLower, groupUpper)
	-- Lower tower: broad base with recessed central glazing and projecting side shoulders.
	block(groupLower, "TowerLowerCore", Vector3.new(42, 24, 28), Vector3.new(0, 24, 5), COLORS.Concrete, Enum.Material.Concrete)
	block(groupLower, "TowerLowerLeftShoulder", Vector3.new(9, 22, 31), Vector3.new(-16.5, 25, 4), COLORS.Limestone, Enum.Material.Concrete)
	block(groupLower, "TowerLowerRightShoulder", Vector3.new(9, 22, 31), Vector3.new(16.5, 25, 4), COLORS.Limestone, Enum.Material.Concrete)
	glass(groupLower, "TowerLowerGlass", Vector3.new(20, 20, 0.5), Vector3.new(0, 25, -9.25))
	addFacadeRibs(groupLower, "Lower", -10, 10, 15, 35, -9.65, 6)

	-- Upper tower: stepped inward and slightly aft so the silhouette becomes resort-like rather than office-block-like.
	block(groupUpper, "TowerUpperCore", Vector3.new(34, 27, 25), Vector3.new(0, 49, 6.5), COLORS.Concrete, Enum.Material.Concrete)
	block(groupUpper, "UpperCrownSetback", Vector3.new(27, 5, 22), Vector3.new(0, 64, 7.5), COLORS.Limestone, Enum.Material.Concrete)
	glass(groupUpper, "TowerUpperGlass", Vector3.new(18, 23, 0.5), Vector3.new(0, 49, -6.25))
	addFacadeRibs(groupUpper, "Upper", -9, 9, 37, 60.5, -6.65, 6)

	for floorIndex = 1, 5 do
		local y = 17 + (floorIndex - 1) * 4.4
		addBalconyRow(groupLower, "LowerF" .. floorIndex .. "_", Vector3.new(0, y, 0), y, -10.2, 34, 7, 0, 3.4)
	end
	for floorIndex = 1, 6 do
		local y = 38 + (floorIndex - 1) * 3.8
		addBalconyRow(groupUpper, "UpperF" .. floorIndex .. "_", Vector3.new(0, y, 0), y, -7.3, 28, 6, 0, 3.0)
	end

	-- Strong vertical side fins make the tower read from long Kaiju distances.
	for _, x in ipairs({-17.5, 17.5}) do
		block(groupUpper, "VerticalFin_" .. tostring(x), Vector3.new(1.1, 51, 3.2), Vector3.new(x, 39.5, -5.2), COLORS.Limestone, Enum.Material.Concrete)
	end
end

local function addGuestWing(group, side)
	local sign = side == "Left" and -1 or 1
	local x = sign * 29
	local yaw = sign * -12
	local center = Vector3.new(x, 0, 8)

	-- Two stepped masses instead of one box make each wing taper toward the tower.
	block(group, side .. "WingLowerMass", Vector3.new(34, 22, 24), Vector3.new(x, 15, 8), COLORS.Concrete, Enum.Material.Concrete, Vector3.new(0, yaw, 0))
	block(group, side .. "WingUpperMass", Vector3.new(29, 12, 21), Vector3.new(x - sign * 1.5, 32, 9), COLORS.Limestone, Enum.Material.Concrete, Vector3.new(0, yaw, 0))

	-- Full-height side glazing helps the wings read as a premium coastal hotel.
	local outerGlassPos = localToWorld(Vector3.new(x, 23, 8), yaw, Vector3.new(sign * -15.8, 0, 0))
	glass(group, side .. "OuterGlassSpine", Vector3.new(0.5, 27, 15), outerGlassPos, Vector3.new(0, yaw, 0), 0.20)

	for floorIndex = 1, 7 do
		local y = 9.5 + (floorIndex - 1) * 4.0
		local frontZ = floorIndex >= 6 and -3.8 or -4.8
		local rowWidth = floorIndex >= 6 and 26 or 31
		addBalconyRow(group, side .. "F" .. floorIndex .. "_", center, y, frontZ, rowWidth, 6, yaw, 3.1)
	end

	block(group, side .. "RoofBand", Vector3.new(30, 1.5, 22), Vector3.new(x - sign * 1.5, 38.4, 9), COLORS.Limestone, Enum.Material.Concrete, Vector3.new(0, yaw, 0))

	-- Architectural bridge ties each wing visually into the central podium without closing the courtyard.
	block(group, side .. "PodiumConnector", Vector3.new(13, 6, 16), Vector3.new(sign * 20.5, 9.5, 8), COLORS.Limestone, Enum.Material.Concrete, Vector3.new(0, sign * -5, 0))
	glass(group, side .. "ConnectorGlass", Vector3.new(9, 4.2, 0.4), Vector3.new(sign * 20.5, 9.8, -0.15), Vector3.new(0, sign * -5, 0), 0.18)
end

local function addPodium(group)
	block(group, "MainPodium", Vector3.new(70, 10, 38), Vector3.new(0, 7, 9), COLORS.Limestone, Enum.Material.Concrete)
	block(group, "PodiumUpperTerrace", Vector3.new(58, 1.0, 34), Vector3.new(0, 12.4, 10), COLORS.Concrete, Enum.Material.Concrete)
	glass(group, "LobbyGlassFront", Vector3.new(38, 6.5, 0.5), Vector3.new(0, 8.2, -10.25), nil, 0.16)
	block(group, "LobbyRoofBand", Vector3.new(48, 1.1, 5), Vector3.new(0, 12.1, -8.5), COLORS.Concrete, Enum.Material.Concrete)

	-- Recessed entry bay gives the front facade depth even before Phase 5 dressing.
	block(group, "LobbyRecess", Vector3.new(24, 7, 3), Vector3.new(0, 7.2, -11.4), COLORS.Metal, Enum.Material.Metal)
	glass(group, "LobbyRecessGlass", Vector3.new(20, 5.5, 0.35), Vector3.new(0, 7.2, -13.0), nil, 0.14)

	for x = -28, 28, 8 do
		block(group, "PodiumColumn_" .. tostring(x), Vector3.new(1.1, 9, 1.1), Vector3.new(x, 5.5, -9.5), COLORS.Concrete, Enum.Material.Concrete)
	end
end

local function addEntrance(group)
	-- Layered porte-cochere with a lifted central blade instead of a flat slab.
	block(group, "ArrivalCanopyMain", Vector3.new(36, 1.1, 14), Vector3.new(0, 7.6, -23), COLORS.Concrete, Enum.Material.Concrete)
	block(group, "ArrivalCanopyBlade", Vector3.new(24, 1.0, 18), Vector3.new(0, 9.0, -21.5), COLORS.Limestone, Enum.Material.Concrete)
	for x = -13, 13, 6.5 do
		block(group, "ArrivalColumn_" .. tostring(x), Vector3.new(1.0, 7.2, 1.0), Vector3.new(x, 3.6, -23), COLORS.Limestone, Enum.Material.Concrete)
	end
	block(group, "ArrivalDeck", Vector3.new(48, 0.8, 20), Vector3.new(0, 0.4, -23), COLORS.Limestone, Enum.Material.Concrete)
	block(group, "ArrivalMedian", Vector3.new(13, 0.65, 4), Vector3.new(0, 0.75, -31), COLORS.Concrete, Enum.Material.Concrete)
end

local function addSkyBar(group)
	block(group, "SkyBarBase", Vector3.new(25, 1.0, 18), Vector3.new(0, 67.0, 7.5), COLORS.Limestone, Enum.Material.Concrete)
	glass(group, "SkyBarGlass", Vector3.new(19, 4.8, 12), Vector3.new(0, 69.8, 7.5), nil, 0.15)
	block(group, "SkyBarRoof", Vector3.new(30, 0.9, 21), Vector3.new(0, 72.7, 7.5), COLORS.Concrete, Enum.Material.Concrete)
	block(group, "SkyBarFloatingBlade", Vector3.new(18, 0.7, 24), Vector3.new(0, 74.0, 8.5), COLORS.Limestone, Enum.Material.Concrete, Vector3.new(0, 0, 2))
	for x = -10, 10, 5 do
		block(group, "SkyBarColumn_" .. tostring(x), Vector3.new(0.75, 5.0, 0.75), Vector3.new(x, 69.8, 1.5), COLORS.Metal, Enum.Material.Metal)
	end
end

local function addPoolTerrace(group)
	-- Three terraces visually connect the resort mass to the waterfront instead of placing a pool on a flat plate.
	block(group, "UpperPoolTerrace", Vector3.new(72, 0.9, 12), Vector3.new(0, 2.2, 27), COLORS.Limestone, Enum.Material.Concrete)
	block(group, "MainPoolDeck", Vector3.new(78, 0.8, 24), Vector3.new(0, 1.1, 38), COLORS.Limestone, Enum.Material.Concrete)
	block(group, "LowerSunDeck", Vector3.new(82, 0.65, 8), Vector3.new(0, 0.55, 52), COLORS.Concrete, Enum.Material.Concrete)

	local pool = block(group, "InfinityPool", Vector3.new(49, 0.55, 13), Vector3.new(0, 1.48, 39), COLORS.Pool, Enum.Material.Glass)
	pool.Transparency = 0.16
	pool.CanCollide = false
	block(group, "PoolEdgeFront", Vector3.new(53, 1.3, 1.0), Vector3.new(0, 1.05, 46), COLORS.Concrete, Enum.Material.Concrete)
	block(group, "PoolEdgeLeft", Vector3.new(1.0, 1.3, 15), Vector3.new(-26, 1.05, 39), COLORS.Concrete, Enum.Material.Concrete)
	block(group, "PoolEdgeRight", Vector3.new(1.0, 1.3, 15), Vector3.new(26, 1.05, 39), COLORS.Concrete, Enum.Material.Concrete)

	-- Architectural water stairs are geometry; decorative furniture remains Phase 5.
	for step = 1, 3 do
		block(group, "TerraceStep" .. step, Vector3.new(18 + step * 5, 0.55, 2.4), Vector3.new(0, 2.0 - step * 0.45, 27.5 + step * 2.0), COLORS.Limestone, Enum.Material.Concrete)
	end
end

local function addPromenade(group)
	block(group, "WaterfrontPromenade", Vector3.new(86, 0.8, 8), Vector3.new(0, 0.4, 58), COLORS.Limestone, Enum.Material.Concrete)
	block(group, "PromenadeSeaWall", Vector3.new(88, 2.2, 1.2), Vector3.new(0, -0.15, 62), COLORS.Concrete, Enum.Material.Concrete)
	for x = -38, 38, 6 do
		local rail = block(group, "PromenadeRail_" .. tostring(x), Vector3.new(4.8, 1.6, 0.18), Vector3.new(x, 1.4, 61.2), COLORS.Metal, Enum.Material.Metal)
		rail.CanCollide = false
	end
end

local function addLandscapeMassing(parent)
	local landscape = folder(parent, "LandscapeReferences")
	for index, x in ipairs({-37, -31, 31, 37}) do
		block(landscape, "PalmPlaceholder" .. index, Vector3.new(1.2, 8, 1.2), Vector3.new(x, 4, 29), COLORS.Landscape, Enum.Material.SmoothPlastic)
	end
	landscape:SetAttribute("Phase5ReplaceWithDressedPalms", true)
end

local function countGeometry(model)
	local visible = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			visible += 1
		end
	end
	model:SetAttribute("VisiblePartCount", visible)
	model:SetAttribute("VisiblePartBudget", specification.GoldenMaster.MaxVisibleParts)
	model:SetAttribute("VisiblePartBudgetPassed", visible <= specification.GoldenMaster.MaxVisibleParts)
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("LargeCity_LuxuryWaterfrontResort_L3_GoldenMaster")
	if existing then
		existing:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = "LargeCity_LuxuryWaterfrontResort_L3_GoldenMaster"
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("AssetPhase", 4)
	model:SetAttribute("QualityGate", "B")
	model:SetAttribute("GeometryRevision", "ResortArchitecture-v2")
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("Style", specification.Style)
	model.Parent = parent

	local groups = folder(model, "DestructionGroups")
	local d1 = folder(groups, "D1_EntranceCanopy")
	local d2 = folder(groups, "D2_PodiumLobby")
	local d3 = folder(groups, "D3_LeftGuestWing")
	local d4 = folder(groups, "D4_RightGuestWing")
	local d5 = folder(groups, "D5_CentralTowerLower")
	local d6 = folder(groups, "D6_CentralTowerUpper")
	local d7 = folder(groups, "D7_RooftopSkyBar")
	local terrace = folder(model, "PoolTerrace")
	local promenade = folder(model, "Promenade")

	addEntrance(d1)
	addPodium(d2)
	addGuestWing(d3, "Left")
	addGuestWing(d4, "Right")
	addTower(d5, d6)
	addSkyBar(d7)
	addPoolTerrace(terrace)
	addPromenade(promenade)
	addLandscapeMassing(model)

	local pivot = part(model, "GroundPivot", Vector3.new(1, 1, 1), CFrame.new(0, 0.5, 0), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, 1)
	pivot.CanCollide = false
	pivot.CanQuery = false
	pivot.CastShadow = false
	model.PrimaryPart = pivot
	model:PivotTo(CFrame.new(0, 0, 0))

	countGeometry(model)
	return model
end

return Builder
