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

local function radialCF(x, y, z)
	local position = Vector3.new(x, y, z)
	return CFrame.lookAt(position, Vector3.new(0, y, 0))
end

local function ellipsePoint(a, b, theta)
	return a * math.cos(theta), b * math.sin(theta)
end

local function ellipsePerimeterApprox(a, b)
	return math.pi * (3 * (a + b) - math.sqrt((3 * a + b) * (a + 3 * b)))
end

local function addSegmentRing(parent, prefix, a, b, y, height, depth, count, color, material, widthScale)
	local perimeter = ellipsePerimeterApprox(a, b)
	local width = (perimeter / count) * (widthScale or 0.94)
	for index = 0, count - 1 do
		local theta = (index / count) * math.pi * 2
		local x, z = ellipsePoint(a, b, theta)
		part(
			parent,
			prefix .. string.format("_%02d", index + 1),
			Vector3.new(width, height, depth),
			radialCF(x, y, z),
			color,
			material
		)
	end
end

local function addSplitCanopy(westParent, eastParent)
	local count = 28
	local a, b = 88, 54
	local width = (ellipsePerimeterApprox(a, b) / count) * 0.98
	for index = 0, count - 1 do
		local theta = (index / count) * math.pi * 2
		local x, z = ellipsePoint(a, b, theta)
		local parent = x < 0 and westParent or eastParent
		part(
			parent,
			"RoofCanopySegment" .. string.format("_%02d", index + 1),
			Vector3.new(width, 2.4, 38),
			radialCF(x, 50, z),
			COLORS.Roof,
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
	block(group, "EntranceGlass", Vector3.new(48, 18, 0.5), Vector3.new(0, 13.5, -80.25), COLORS.Glass, Enum.Material.Glass, 0.12)
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

local function addBowl(lowerGroup, upperGroup, serviceGroup)
	addSegmentRing(lowerGroup, "LowerBowl", 96, 59, 13, 20, 22, 28, COLORS.Concrete, Enum.Material.Concrete, 0.96)
	addSegmentRing(upperGroup, "UpperBowl", 98, 61, 34, 20, 18, 28, COLORS.ConcreteDark, Enum.Material.Concrete, 0.95)

	-- Visible seating bands just inside the structural bowl.
	addSegmentRing(lowerGroup, "LowerSeatBand", 79, 44, 22, 5, 9, 28, COLORS.Seat, Enum.Material.SmoothPlastic, 0.94)
	addSegmentRing(upperGroup, "UpperSeatBand", 76, 42, 42, 5, 8, 28, COLORS.Seat, Enum.Material.SmoothPlastic, 0.94)

	-- Exterior concourse glazing and repeated ribs are what keep the stadium from
	-- reading as a smooth cylinder or generic box.
	addSegmentRing(serviceGroup, "ConcourseGlass", 107, 68, 19, 7, 1.2, 28, COLORS.Glass, Enum.Material.Glass, 0.90)
	for index = 0, 27 do
		local theta = (index / 28) * math.pi * 2
		local x, z = ellipsePoint(109, 70, theta)
		part(
			upperGroup,
			"StructuralRib" .. string.format("_%02d", index + 1),
			Vector3.new(2.4, 43, 3.2),
			radialCF(x, 25.5, z),
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
	block(group, "Pitch", Vector3.new(104, 0.7, 60), Vector3.new(0, 0.4, 4), COLORS.Pitch, Enum.Material.Grass)
	block(group, "PitchPerimeter", Vector3.new(118, 0.35, 72), Vector3.new(0, 0.18, 4), COLORS.ConcreteDark, Enum.Material.Concrete)
	-- Re-place pitch above the perimeter slab so the green surface remains visible.
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
	model:SetAttribute("GeometryRevision", "LargeCityStadium-v1")
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("Style", specification.Style)
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
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
