local specification = require(script.Parent:WaitForChild("LargeCityStadiumSpecification"))

local Builder = {}

local COLORS = {
	Concrete = Color3.fromRGB(224, 226, 221),
	ConcreteDark = Color3.fromRGB(178, 184, 183),
	Metal = Color3.fromRGB(166, 176, 179),
	Roof = Color3.fromRGB(205, 211, 211),
	Glass = Color3.fromRGB(58, 104, 118),
	Seat = Color3.fromRGB(45, 73, 93),
	Pitch = Color3.fromRGB(76, 132, 74),
	Teal = Color3.fromRGB(54, 154, 157),
	Dark = Color3.fromRGB(47, 55, 60),
}

local BOWL_SEGMENTS = 64
local RIB_COUNT = 32
local ROOF_SEGMENTS = 64

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

local function tangentFrame(a, b, theta, y)
	local halfStep = math.pi / BOWL_SEGMENTS
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

local function addSmoothRing(parent, prefix, a, b, y, height, depth, count, color, material, overlap)
	local step = math.pi * 2 / count
	local halfStep = step * 0.5
	for index = 0, count - 1 do
		local theta = index * step
		local before = ellipsePoint(a, b, theta - halfStep)
		local after = ellipsePoint(a, b, theta + halfStep)
		local tangent = (after - before).Unit
		local up = Vector3.yAxis
		local back = tangent:Cross(up).Unit
		local position = ellipsePoint(a, b, theta) + Vector3.new(0, y, 0)
		part(
			parent,
			prefix .. string.format("_%02d", index + 1),
			Vector3.new((after - before).Magnitude * (overlap or 1.10), height, depth),
			CFrame.fromMatrix(position, tangent, up, back),
			color,
			material
		)
	end
end

local function addBandRing(parent, prefix, innerA, innerB, outerA, outerB, y, height, count, color, material)
	local step = math.pi * 2 / count
	for index = 0, count - 1 do
		local theta = index * step
		local cf, chord, radialDepth = radialBandFrame(innerA, innerB, outerA, outerB, theta, y, count)
		part(
			parent,
			prefix .. string.format("_%02d", index + 1),
			Vector3.new(chord * 1.13, height, radialDepth + 1.2),
			cf,
			color,
			material
		)
	end
end

local function addSplitCanopy(westParent, eastParent)
	local innerA, innerB = 65, 39
	local outerA, outerB = 108, 70
	local step = math.pi * 2 / ROOF_SEGMENTS

	for index = 0, ROOF_SEGMENTS - 1 do
		local theta = index * step
		local cf, chord, radialDepth = radialBandFrame(innerA, innerB, outerA, outerB, theta, 50, ROOF_SEGMENTS)
		local center = cf.Position
		local parent = center.X < 0 and westParent or eastParent

		part(
			parent,
			"RoofCanopySegment" .. string.format("_%02d", index + 1),
			Vector3.new(chord * 1.14, 2.4, radialDepth + 1.6),
			cf,
			COLORS.Roof,
			Enum.Material.Metal
		)
	end

	-- Thin edge fascias hide the polygon joints and make both roof edges read
	-- as one continuous architectural ring instead of individual roof blocks.
	for index = 0, ROOF_SEGMENTS - 1 do
		local theta = index * step
		local x = math.cos(theta)
		local outerX = outerA * x
		local parent = outerX < 0 and westParent or eastParent

		local outerCf, outerChord = tangentFrame(outerA, outerB, theta, 48.6)
		part(
			parent,
			"RoofOuterFascia" .. string.format("_%02d", index + 1),
			Vector3.new(outerChord * 1.12, 3.0, 1.8),
			outerCf,
			COLORS.Metal,
			Enum.Material.Metal
		)

		local innerCf, innerChord = tangentFrame(innerA, innerB, theta, 48.8)
		part(
			parent,
			"RoofInnerFascia" .. string.format("_%02d", index + 1),
			Vector3.new(innerChord * 1.12, 2.6, 1.6),
			innerCf,
			COLORS.Metal,
			Enum.Material.Metal
		)
	end
end

local function beamBetween(parent, name, a, b, thickness, color)
	local delta = b - a
	local length = delta.Magnitude
	local middle = a:Lerp(b, 0.5)
	return part(
		parent,
		name,
		Vector3.new(thickness, thickness, length),
		CFrame.lookAt(middle, b),
		color or COLORS.Metal,
		Enum.Material.Metal
	)
end

local function addMainEntrance(group)
	block(group, "EntranceHallMass", Vector3.new(70, 28, 14), Vector3.new(0, 14, -73), COLORS.Concrete, Enum.Material.Concrete)
	block(group, "EntranceGlass", Vector3.new(68, 18, 0.5), Vector3.new(0, 13.5, -80.25), COLORS.Glass, Enum.Material.Glass, 0.12)
	for _, x in ipairs({-31, -18, -6, 6, 18, 31}) do
		block(group, "EntrancePier" .. tostring(x), Vector3.new(3.2, 30, 4), Vector3.new(x, 15, -79), COLORS.ConcreteDark, Enum.Material.Concrete)
	end
	block(group, "EntranceCanopy", Vector3.new(76, 2.0, 12), Vector3.new(0, 28.5, -78), COLORS.Roof, Enum.Material.Metal)
	for step = 1, 4 do
		block(
			group,
			"ArrivalStep" .. step,
			Vector3.new(88 - step * 4, 0.8, 5),
			Vector3.new(0, 0.4 + (step - 1) * 0.7, -86 + step * 3.8),
			COLORS.Concrete,
			Enum.Material.Concrete
		)
	end
end

local function addExteriorScreens(parent)
	local count = 16
	local a, b = 112.5, 72.5
	local step = math.pi * 2 / count

	for index = 0, count - 1 do
		local theta = index * step
		-- Keep the ceremonial front entrance visually clean; screens wrap the
		-- sides and rear facade and sit clearly outside the closed bowl shell.
		local frontDistance = math.abs(math.atan2(math.sin(theta + math.pi * 0.5), math.cos(theta + math.pi * 0.5)))
		if frontDistance > math.rad(28) then
			local cf, chord = tangentFrame(a, b, theta, 28)
			local screen = part(
				parent,
				"ExteriorScreen" .. string.format("_%02d", index + 1),
				Vector3.new(math.max(10.5, chord * 0.72), 7.5, 0.75),
				cf,
				COLORS.Glass,
				Enum.Material.Glass,
				0.04
			)
			screen:SetAttribute("FacadeStandOff", true)
		end
	end
end

local function addSeatingTier(parent, prefix, a, b, y, depth)
	addSmoothRing(parent, prefix, a, b, y, 3.6, depth, BOWL_SEGMENTS, COLORS.Seat, Enum.Material.SmoothPlastic, 1.11)
end

local function addBowl(lowerGroup, upperGroup, serviceGroup)
	-- Filled overlapping bands create a continuous oval shell. The previous
	-- version used isolated blocks around an ellipse, which left large visible gaps.
	addBandRing(lowerGroup, "LowerBowl", 84, 48, 110, 70, 12.5, 21, BOWL_SEGMENTS, COLORS.Concrete, Enum.Material.Concrete)
	addBandRing(upperGroup, "UpperBowl", 76, 43, 106, 68, 34, 21, BOWL_SEGMENTS, COLORS.ConcreteDark, Enum.Material.Concrete)

	-- Four stepped seating bands produce a readable two-tier interior without
	-- modeling individual seats or creating a playable interior.
	addSeatingTier(lowerGroup, "LowerSeatOuter", 79, 44, 19, 8.5)
	addSeatingTier(lowerGroup, "LowerSeatInner", 73, 38, 23, 8.0)
	addSeatingTier(upperGroup, "UpperSeatOuter", 77, 43, 36, 7.5)
	addSeatingTier(upperGroup, "UpperSeatInner", 70, 36, 41, 7.0)

	-- Continuous concourse glazing sits outside the concrete bowl.
	addSmoothRing(serviceGroup, "ConcourseGlass", 108, 69, 19, 7, 1.25, BOWL_SEGMENTS, COLORS.Glass, Enum.Material.Glass, 1.12)\n\taddExteriorScreens(serviceGroup)

	-- Structural ribs are now accents over a closed facade, not the only thing
	-- bridging large gaps between bowl blocks.
	local step = math.pi * 2 / RIB_COUNT
	for index = 0, RIB_COUNT - 1 do
		local theta = index * step
		local before = ellipsePoint(110, 71, theta - step * 0.5)
		local after = ellipsePoint(110, 71, theta + step * 0.5)
		local tangent = (after - before).Unit
		local up = Vector3.yAxis
		local back = tangent:Cross(up).Unit
		local position = ellipsePoint(110, 71, theta) + Vector3.new(0, 25.5, 0)
		part(
			upperGroup,
			"StructuralRib" .. string.format("_%02d", index + 1),
			Vector3.new(2.4, 43, 3.0),
			CFrame.fromMatrix(position, tangent, up, back),
			COLORS.Metal,
			Enum.Material.Metal
		)
	end
end

local function addPylons(group)
	local positions = {
		Vector3.new(-88, 0, -58),
		Vector3.new(88, 0, -58),
		Vector3.new(-88, 0, 58),
		Vector3.new(88, 0, 58),
	}

	for pylonIndex, base in ipairs(positions) do
		local sx = base.X < 0 and 1 or -1
		local sz = base.Z < 0 and 1 or -1
		for segment = 1, 3 do
			local y = 12 + (segment - 1) * 24
			local shrink = segment - 1
			local x = base.X + sx * shrink * 2.4
			local z = base.Z + sz * shrink * 1.6
			block(
				group,
				"Pylon" .. pylonIndex .. "Segment" .. segment,
				Vector3.new(10 - shrink * 2.2, 24, 12 - shrink * 2.5),
				Vector3.new(x, y, z),
				COLORS.ConcreteDark,
				Enum.Material.Concrete
			)
		end

		local top = Vector3.new(base.X + sx * 5, 72, base.Z + sz * 3.5)
		local roofAnchor = Vector3.new(base.X * 0.80, 51, base.Z * 0.80)
		beamBetween(group, "PylonRoofBrace" .. pylonIndex .. "A", top - Vector3.new(0, 14, 0), roofAnchor, 1.4, COLORS.Metal)
		beamBetween(group, "PylonRoofBrace" .. pylonIndex .. "B", top - Vector3.new(0, 6, 0), roofAnchor + Vector3.new(-sx * 7, 0, -sz * 4), 1.1, COLORS.Metal)
	end
end

local function addScoreboard(group)
	block(group, "ScoreboardFrame", Vector3.new(52, 19, 3.0), Vector3.new(0, 39, 50), COLORS.Dark, Enum.Material.Metal)
	block(group, "ScoreboardScreen", Vector3.new(47, 14, 0.5), Vector3.new(0, 39, 48.2), COLORS.Glass, Enum.Material.Glass, 0.05)
	for _, x in ipairs({-24, 24}) do
		block(group, "ScoreboardSupport" .. x, Vector3.new(2.2, 21, 2.2), Vector3.new(x, 29, 50), COLORS.Metal, Enum.Material.Metal)
	end
end

local function addRearService(group)
	block(group, "RearServiceMass", Vector3.new(82, 18, 14), Vector3.new(0, 9, 72), COLORS.ConcreteDark, Enum.Material.Concrete)
	for _, x in ipairs({-30, -15, 0, 15, 30}) do
		block(group, "RearServiceOpening" .. x, Vector3.new(10, 7, 0.5), Vector3.new(x, 7, 64.7), COLORS.Glass, Enum.Material.Glass, 0.14)
	end
end

local function addPitch(group)
	block(group, "PitchPerimeter", Vector3.new(118, 0.35, 72), Vector3.new(0, 0.18, 4), COLORS.ConcreteDark, Enum.Material.Concrete)
	block(group, "PitchSurface", Vector3.new(104, 0.45, 60), Vector3.new(0, 0.55, 4), COLORS.Pitch, Enum.Material.Grass)
end

local function countVisibleParts(model)
	local count = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			count += 1
		end
	end
	model:SetAttribute("VisiblePartCount", count)
	model:SetAttribute("VisiblePartBudget", 900)
	model:SetAttribute("VisiblePartBudgetPassed", count <= 900)
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("LargeCity_Stadium_L3_GoldenMaster")
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = "LargeCity_Stadium_L3_GoldenMaster"
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("AssetPhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("GeometryRevision", "LargeCityStadium-v3-FacadeScreens")
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("Style", specification.Style)
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
	model:SetAttribute("BowlSegmentCount", BOWL_SEGMENTS)
	model:SetAttribute("RoofSegmentCount", ROOF_SEGMENTS)
	model:SetAttribute("BowlClosedShell", true)
	model:SetAttribute("RoofContinuousRing", true)\n\tmodel:SetAttribute("ExteriorScreensRestored", true)\n\tmodel:SetAttribute("EntranceGlazingFullSpan", true)
	model.Parent = parent

	local groups = folder(model, "DestructionGroups")
	local d1 = folder(groups, "D1_MainEntrance")
	local d2 = folder(groups, "D2_LowerBowl")
	local d3 = folder(groups, "D3_UpperBowl")
	local d4 = folder(groups, "D4_RoofCanopyWest")
	local d5 = folder(groups, "D5_RoofCanopyEast")
	local d6 = folder(groups, "D6_ScoreboardAndPylons")
	local d7 = folder(groups, "D7_ServiceAndConcourse")

	addMainEntrance(d1)
	addBowl(d2, d3, d7)
	addSplitCanopy(d4, d5)
	addPylons(d6)
	addScoreboard(d6)
	addRearService(d7)
	addPitch(d7)

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
