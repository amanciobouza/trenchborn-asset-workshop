local specification = require(script.Parent:WaitForChild("LargeCityUptownArenaSpecification"))

local Builder = {}

local COLORS = {
	Concrete = Color3.fromRGB(222, 224, 221),
	ConcreteDark = Color3.fromRGB(171, 178, 179),
	Metal = Color3.fromRGB(165, 174, 177),
	Roof = Color3.fromRGB(202, 208, 209),
	Glass = Color3.fromRGB(52, 91, 105),
	DarkGlass = Color3.fromRGB(35, 60, 72),
	Teal = Color3.fromRGB(50, 158, 166),
	Dark = Color3.fromRGB(43, 50, 56),
}

local SEGMENTS = 48

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
	item.CanQuery = true
	item.CanTouch = true
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function block(parent, name, size, position, color, material, transparency)
	return part(parent, name, size, CFrame.new(position), color, material, transparency)
end

local function ellipsePoint(a, b, theta)
	return Vector3.new(a * math.cos(theta), 0, b * math.sin(theta))
end

local function tangentFrame(a, b, theta, y, segmentCount)
	local halfStep = math.pi / segmentCount
	local before = ellipsePoint(a, b, theta - halfStep)
	local after = ellipsePoint(a, b, theta + halfStep)
	local tangent = (after - before).Unit
	local up = Vector3.yAxis
	local back = tangent:Cross(up).Unit
	local position = ellipsePoint(a, b, theta) + Vector3.new(0, y, 0)
	return CFrame.fromMatrix(position, tangent, up, back), (after - before).Magnitude
end

local function radialBandFrame(innerA, innerB, outerA, outerB, theta, y, segmentCount)
	local inner = ellipsePoint(innerA, innerB, theta)
	local outer = ellipsePoint(outerA, outerB, theta)
	local mid = inner:Lerp(outer, 0.5)
	local radial = outer - inner
	local up = Vector3.yAxis
	local back = radial.Unit
	local right = up:Cross(back).Unit

	local halfStep = math.pi / segmentCount
	local midA = (innerA + outerA) * 0.5
	local midB = (innerB + outerB) * 0.5
	local before = ellipsePoint(midA, midB, theta - halfStep)
	local after = ellipsePoint(midA, midB, theta + halfStep)
	return CFrame.fromMatrix(mid + Vector3.new(0, y, 0), right, up, back), (after - before).Magnitude, radial.Magnitude
end

local function addBandRing(parent, prefix, innerA, innerB, outerA, outerB, y, height, count, color, material, overlap)
	local step = math.pi * 2 / count
	for index = 0, count - 1 do
		local theta = index * step
		local cf, chord, radialDepth = radialBandFrame(innerA, innerB, outerA, outerB, theta, y, count)
		part(
			parent,
			prefix .. string.format("_%02d", index + 1),
			Vector3.new(chord * (overlap or 1.13), height, radialDepth + 1.1),
			cf,
			color,
			material
		)
	end
end

local function addSmoothRing(parent, prefix, a, b, y, height, depth, count, color, material, transparency, overlap)
	local step = math.pi * 2 / count
	for index = 0, count - 1 do
		local theta = index * step
		local cf, chord = tangentFrame(a, b, theta, y, count)
		part(
			parent,
			prefix .. string.format("_%02d", index + 1),
			Vector3.new(chord * (overlap or 1.12), height, depth),
			cf,
			color,
			material,
			transparency
		)
	end
end

local function addMainEntrance(group)
	block(group, "EntranceMass", Vector3.new(66, 27, 15), Vector3.new(0, 13.5, -48.5), COLORS.Concrete, Enum.Material.Concrete)
	block(group, "EntranceRecess", Vector3.new(58, 20, 4.5), Vector3.new(0, 13, -56.0), COLORS.Dark, Enum.Material.Metal)
	block(group, "EntranceGlass", Vector3.new(56, 18, 0.55), Vector3.new(0, 13, -58.45), COLORS.Glass, Enum.Material.Glass, 0.10)

	for _, x in ipairs({-27, -17, -6, 6, 17, 27}) do
		block(group, "PortalPier" .. tostring(x), Vector3.new(2.4, 28, 3.2), Vector3.new(x, 14, -56.5), COLORS.Metal, Enum.Material.Metal)
	end

	block(group, "EntranceCanopy", Vector3.new(70, 1.6, 9), Vector3.new(0, 27.2, -56), COLORS.Roof, Enum.Material.Metal)
	for step = 1, 4 do
		block(
			group,
			"ArrivalStep" .. step,
			Vector3.new(76 - step * 4, 0.7, 4.5),
			Vector3.new(0, 0.35 + (step - 1) * 0.55, -66 + step * 3.2),
			COLORS.Concrete,
			Enum.Material.Concrete
		)
	end
end

local function addFacade(lowerGroup, upperGroup, ribbonGroup)
	-- Closed overlapping shells prevent the arena from reading as a ring of separated blocks.
	addBandRing(lowerGroup, "LowerFacade", 52, 36, 68, 49, 12, 23, SEGMENTS, COLORS.Concrete, Enum.Material.Concrete, 1.14)
	addBandRing(upperGroup, "UpperFacade", 47, 32, 66, 47, 33, 20, SEGMENTS, COLORS.ConcreteDark, Enum.Material.Concrete, 1.14)

	-- Continuous dark-glass concourse slot under the media ribbon.
	addSmoothRing(lowerGroup, "ConcourseGlass", 67.2, 48.2, 22.5, 6.0, 1.2, SEGMENTS, COLORS.DarkGlass, Enum.Material.Glass, 0.08, 1.14)

	-- Media ribbon is structural placement at Gate B; detailed content comes in Dressing.
	addSmoothRing(ribbonGroup, "MediaRibbon", 69.0, 50.0, 29.0, 5.5, 0.75, SEGMENTS, COLORS.Teal, Enum.Material.Neon, 0, 1.13)

	-- Repeated vertical fins sit on the facade skin, not between open gaps.
	local finCount = 24
	local step = math.pi * 2 / finCount
	for index = 0, finCount - 1 do
		local theta = index * step
		local cf = tangentFrame(69.6, 50.6, theta, 30.0, finCount)
		part(
			upperGroup,
			"VerticalFin" .. string.format("_%02d", index + 1),
			Vector3.new(1.0, 26, 2.0),
			cf,
			COLORS.Metal,
			Enum.Material.Metal
		)
	end
end

local function addRoof(westGroup, eastGroup)
	-- Four overlapping annular bands rise gently toward the center to create a
	-- shallow enclosed crown without a sci-fi dome silhouette.
	local bands = {
		{innerA = 52, innerB = 36, outerA = 66, outerB = 47, y = 45.2},
		{innerA = 38, innerB = 26, outerA = 54, outerB = 37.5, y = 49.0},
		{innerA = 23, innerB = 15.5, outerA = 40, outerB = 27.5, y = 52.3},
		{innerA = 8, innerB = 5.5, outerA = 25, outerB = 17.0, y = 54.8},
	}
	local step = math.pi * 2 / SEGMENTS

	for bandIndex, band in ipairs(bands) do
		for index = 0, SEGMENTS - 1 do
			local theta = index * step
			local cf, chord, radialDepth = radialBandFrame(
				band.innerA,
				band.innerB,
				band.outerA,
				band.outerB,
				theta,
				band.y,
				SEGMENTS
			)
			local center = cf.Position
			local parent = center.X < 0 and westGroup or eastGroup
			part(
				parent,
				string.format("RoofBand%d_%02d", bandIndex, index + 1),
				Vector3.new(chord * 1.14, 2.2, radialDepth + 1.2),
				cf,
				COLORS.Roof,
				Enum.Material.Metal
			)
		end
	end

	-- Small central crown closes the last opening.
	block(westGroup, "RoofCrownWest", Vector3.new(9.5, 2.2, 12), Vector3.new(-4.6, 56.0, 0), COLORS.Roof, Enum.Material.Metal)
	block(eastGroup, "RoofCrownEast", Vector3.new(9.5, 2.2, 12), Vector3.new(4.6, 56.0, 0), COLORS.Roof, Enum.Material.Metal)

	addSmoothRing(westGroup, "RoofPerimeterWest", 66.5, 47.5, 44.0, 2.0, 1.5, SEGMENTS / 2, COLORS.Metal, Enum.Material.Metal, 0, 1.14)
end

local function addRearService(group)
	block(group, "RearServiceMass", Vector3.new(74, 18, 15), Vector3.new(0, 9, 48), COLORS.ConcreteDark, Enum.Material.Concrete)
	for _, x in ipairs({-27, -9, 9, 27}) do
		block(group, "LoadingDoor" .. tostring(x), Vector3.new(12, 8, 0.5), Vector3.new(x, 5, 40.25), COLORS.Dark, Enum.Material.Metal)
	end
	block(group, "RearServiceCanopy", Vector3.new(78, 1.4, 8), Vector3.new(0, 17.5, 42), COLORS.Metal, Enum.Material.Metal)
end

local function countVisibleParts(model)
	local count = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			count += 1
		end
	end
	model:SetAttribute("VisiblePartCount", count)
	model:SetAttribute("VisiblePartBudget", 700)
	model:SetAttribute("VisiblePartBudgetPassed", count <= 700)
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("LargeCity_UptownArena_L3_GoldenMaster")
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = "LargeCity_UptownArena_L3_GoldenMaster"
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("AssetPhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("GeometryRevision", "LargeCityUptownArena-v1")
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("Style", specification.Style)
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
	model:SetAttribute("FacadeSegmentCount", SEGMENTS)
	model:SetAttribute("RoofSegmentCount", SEGMENTS)
	model:SetAttribute("EnclosedArenaShell", true)
	model:SetAttribute("EnclosedRoof", true)
	model.Parent = parent

	local groups = folder(model, "DestructionGroups")
	local d1 = folder(groups, "D1_MainEntrance")
	local d2 = folder(groups, "D2_LowerFacade")
	local d3 = folder(groups, "D3_UpperFacade")
	local d4 = folder(groups, "D4_RoofWest")
	local d5 = folder(groups, "D5_RoofEast")
	local d6 = folder(groups, "D6_MediaRibbonAndSignage")
	local d7 = folder(groups, "D7_ServiceAndLoading")

	addMainEntrance(d1)
	addFacade(d2, d3, d6)
	addRoof(d4, d5)
	addRearService(d7)

	local pivot = part(model, "GroundPivot", Vector3.new(1, 1, 1), CFrame.new(0, 0.5, 0), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, 1)
	pivot.CanCollide = false
	pivot.CanQuery = false
	pivot.CanTouch = false
	pivot.CastShadow = false
	model.PrimaryPart = pivot
	model:PivotTo(CFrame.new())

	countVisibleParts(model)
	return model
end

return Builder
