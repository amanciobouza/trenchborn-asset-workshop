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

local function glass(parent, name, size, position, rotation)
	local item = block(parent, name, size, position, COLORS.Glass, Enum.Material.Glass, rotation)
	item.Transparency = 0.22
	item.Reflectance = 0.04
	return item
end

local function addBalconyRow(parent, prefix, xCenter, y, zFront, width, count, rotationY)
	local spacing = width / count
	for index = 1, count do
		local localX = -width / 2 + spacing * (index - 0.5)
		local x = xCenter + localX
		local slab = block(
			parent,
			prefix .. "BalconySlab" .. index,
			Vector3.new(spacing * 0.88, 0.55, 3.2),
			Vector3.new(x, y, zFront),
			COLORS.Concrete,
			Enum.Material.Concrete,
			rotationY and Vector3.new(0, rotationY, 0) or nil
		)
		local rail = glass(
			parent,
			prefix .. "BalconyRail" .. index,
			Vector3.new(spacing * 0.76, 1.5, 0.18),
			Vector3.new(x, y + 1.0, zFront - 1.53),
			rotationY and Vector3.new(0, rotationY, 0) or nil
		)
		rail.CanCollide = false
		slab.CanCollide = true
	end
end

local function addFacadeRibs(parent, prefix, xMin, xMax, yMin, yMax, z, count)
	for index = 0, count do
		local alpha = index / count
		local x = xMin + (xMax - xMin) * alpha
		block(
			parent,
			prefix .. "Rib" .. index,
			Vector3.new(0.42, yMax - yMin, 0.65),
			Vector3.new(x, (yMin + yMax) / 2, z),
			COLORS.Metal,
			Enum.Material.Metal
		).CanCollide = false
	end
end

local function addTower(groupLower, groupUpper)
	-- Lower mass and podium-facing lobby volume.
	block(groupLower, "TowerLowerCore", Vector3.new(42, 24, 30), Vector3.new(0, 24, 4), COLORS.Concrete, Enum.Material.Concrete)
	glass(groupLower, "TowerLowerGlass", Vector3.new(21, 20, 0.5), Vector3.new(0, 25, -11.25))
	addFacadeRibs(groupLower, "Lower", -10.5, 10.5, 15, 35, -11.65, 7)

	-- Upper tower is narrower and slightly set back to avoid a monolithic box silhouette.
	block(groupUpper, "TowerUpperCore", Vector3.new(34, 28, 27), Vector3.new(0, 49, 6), COLORS.Concrete, Enum.Material.Concrete)
	glass(groupUpper, "TowerUpperGlass", Vector3.new(18, 24, 0.5), Vector3.new(0, 49, -7.75))
	addFacadeRibs(groupUpper, "Upper", -9, 9, 37, 61, -8.15, 6)

	for floorIndex = 1, 5 do
		local y = 17 + (floorIndex - 1) * 4.4
		addBalconyRow(groupLower, "LowerF" .. floorIndex .. "_", 0, y, -12.3, 34, 7)
	end
	for floorIndex = 1, 6 do
		local y = 38 + (floorIndex - 1) * 3.8
		addBalconyRow(groupUpper, "UpperF" .. floorIndex .. "_", 0, y, -8.8, 28, 6)
	end
end

local function addGuestWing(group, side)
	local sign = side == "Left" and -1 or 1
	local x = sign * 29
	local yaw = sign * -10

	block(
		group,
		side .. "WingCore",
		Vector3.new(34, 32, 24),
		Vector3.new(x, 22, 8),
		COLORS.Concrete,
		Enum.Material.Concrete,
		Vector3.new(0, yaw, 0)
	)

	for floorIndex = 1, 7 do
		local y = 9.5 + (floorIndex - 1) * 4.0
		addBalconyRow(group, side .. "F" .. floorIndex .. "_", x, y, -4.8, 31, 6, yaw)
	end

	block(
		group,
		side .. "RoofBand",
		Vector3.new(34.5, 1.5, 24.5),
		Vector3.new(x, 38.4, 8),
		COLORS.Limestone,
		Enum.Material.Concrete,
		Vector3.new(0, yaw, 0)
	)
end

local function addPodium(group)
	block(group, "MainPodium", Vector3.new(70, 10, 40), Vector3.new(0, 7, 9), COLORS.Limestone, Enum.Material.Concrete)
	glass(group, "LobbyGlassFront", Vector3.new(38, 6.5, 0.5), Vector3.new(0, 8.2, -11.25))
	block(group, "LobbyRoofBand", Vector3.new(48, 1.1, 5), Vector3.new(0, 12.1, -9.5), COLORS.Concrete, Enum.Material.Concrete)

	for x = -28, 28, 8 do
		block(group, "PodiumColumn_" .. tostring(x), Vector3.new(1.1, 9, 1.1), Vector3.new(x, 5.5, -10), COLORS.Concrete, Enum.Material.Concrete)
	end
end

local function addEntrance(group)
	block(group, "ArrivalCanopy", Vector3.new(34, 1.2, 14), Vector3.new(0, 7.6, -23), COLORS.Concrete, Enum.Material.Concrete)
	for x = -13, 13, 6.5 do
		block(group, "ArrivalColumn_" .. tostring(x), Vector3.new(1.1, 7.2, 1.1), Vector3.new(x, 3.6, -23), COLORS.Limestone, Enum.Material.Concrete)
	end
	block(group, "ArrivalDeck", Vector3.new(44, 0.8, 18), Vector3.new(0, 0.4, -23), COLORS.Limestone, Enum.Material.Concrete)
end

local function addSkyBar(group)
	block(group, "SkyBarBase", Vector3.new(24, 1.0, 18), Vector3.new(0, 63.5, 6), COLORS.Limestone, Enum.Material.Concrete)
	glass(group, "SkyBarGlass", Vector3.new(18, 4.5, 12), Vector3.new(0, 66.0, 6))
	block(group, "SkyBarRoof", Vector3.new(27, 0.9, 20), Vector3.new(0, 69.0, 6), COLORS.Concrete, Enum.Material.Concrete)
	for x = -10, 10, 5 do
		block(group, "SkyBarColumn_" .. tostring(x), Vector3.new(0.8, 5, 0.8), Vector3.new(x, 66, 0.5), COLORS.Metal, Enum.Material.Metal)
	end
end

local function addPoolTerrace(group)
	block(group, "PoolDeck", Vector3.new(76, 0.8, 25), Vector3.new(0, 0.4, 34), COLORS.Limestone, Enum.Material.Concrete)
	local pool = block(group, "InfinityPool", Vector3.new(48, 0.55, 13), Vector3.new(0, 0.78, 37), COLORS.Pool, Enum.Material.Glass)
	pool.Transparency = 0.18
	pool.CanCollide = false
	block(group, "PoolEdgeFront", Vector3.new(52, 1.2, 1.2), Vector3.new(0, 0.6, 44), COLORS.Concrete, Enum.Material.Concrete)
	block(group, "PoolEdgeLeft", Vector3.new(1.2, 1.2, 15), Vector3.new(-25.5, 0.6, 37), COLORS.Concrete, Enum.Material.Concrete)
	block(group, "PoolEdgeRight", Vector3.new(1.2, 1.2, 15), Vector3.new(25.5, 0.6, 37), COLORS.Concrete, Enum.Material.Concrete)
end

local function addPromenade(group)
	block(group, "WaterfrontPromenade", Vector3.new(84, 0.8, 8), Vector3.new(0, 0.4, 51), COLORS.Limestone, Enum.Material.Concrete)
	for x = -38, 38, 6 do
		local rail = block(group, "PromenadeRail_" .. tostring(x), Vector3.new(4.8, 1.6, 0.18), Vector3.new(x, 1.4, 54.8), COLORS.Metal, Enum.Material.Metal)
		rail.CanCollide = false
	end
end

local function addLandscapeMassing(parent)
	local landscape = folder(parent, "LandscapeReferences")
	for index, x in ipairs({-36, -30, 30, 36}) do
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
