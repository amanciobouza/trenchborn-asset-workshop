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

local SEGMENTS = 72
local FIN_COUNT = 24

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

local function addSmoothRing(parent, prefix, a, b, y, height, depth, count, color, material, transparency, overlap)
	local step = math.pi * 2 / count
	for index = 0, count - 1 do
		local theta = index * step
		local cf, chord = tangentFrame(a, b, theta, y, count)
		part(
			parent,
			prefix .. string.format("_%02d", index + 1),
			Vector3.new(chord * (overlap or 1.16), height, depth),
			cf,
			color,
			material,
			transparency
		)
	end
end

local function addSlopedRoofBand(parentWest, parentEast, prefix, outerA, outerB, outerY, innerA, innerB, innerY)
	local step = math.pi * 2 / SEGMENTS
	local midA = (outerA + innerA) * 0.5
	local midB = (outerB + innerB) * 0.5

	for index = 0, SEGMENTS - 1 do
		local theta = index * step
		local outer = ellipsePoint(outerA, outerB, theta) + Vector3.new(0, outerY, 0)
		local inner = ellipsePoint(innerA, innerB, theta) + Vector3.new(0, innerY, 0)
		local radial = inner - outer

		local halfStep = step * 0.5
		local before = ellipsePoint(midA, midB, theta - halfStep)
		local after = ellipsePoint(midA, midB, theta + halfStep)
		local right = (after - before).Unit

		local back = radial - right * radial:Dot(right)
		back = back.Unit
		local up = back:Cross(right).Unit

		local middle = outer:Lerp(inner, 0.5)
		local cf = CFrame.fromMatrix(middle, right, up, back)
		local chord = (after - before).Magnitude
		local parent = middle.X < 0 and parentWest or parentEast

		part(
			parent,
			prefix .. string.format("_%02d", index + 1),
			Vector3.new(chord * 1.18, 2.2, radial.Magnitude + 1.5),
			cf,
			COLORS.Roof,
			Enum.Material.Metal
		)
	end
end

local function addOvalCap(parent, name, centerY)
	return part(
		parent,
		name,
		Vector3.new(2.2, 12, 8),
		CFrame.new(0, centerY, 0) * CFrame.Angles(0, 0, math.rad(90)),
		COLORS.Roof,
		Enum.Material.Metal,
		0,
		Enum.PartType.Cylinder
	)
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
	-- v2 uses shallow tangent shells instead of deep radial blocks. With 72
	-- overlapping segments the exterior reads as one flowing oval skin.
	addSmoothRing(lowerGroup, "LowerFacade", 65.5, 46.5, 12.0, 23.0, 12.0, SEGMENTS, COLORS.Concrete, Enum.Material.Concrete, 0, 1.18)
	addSmoothRing(upperGroup, "UpperFacade", 64.0, 45.0, 33.0, 20.0, 11.0, SEGMENTS, COLORS.ConcreteDark, Enum.Material.Concrete, 0, 1.18)

	-- Continuous dark-glass concourse slot under the media ribbon.
	addSmoothRing(lowerGroup, "ConcourseGlass", 66.2, 47.2, 22.5, 6.0, 1.25, SEGMENTS, COLORS.DarkGlass, Enum.Material.Glass, 0.08, 1.18)

	-- Media ribbon remains a thin continuous layer outside the smoother shell.
	addSmoothRing(ribbonGroup, "MediaRibbon", 67.2, 48.2, 29.0, 5.5, 0.75, SEGMENTS, COLORS.Teal, Enum.Material.Neon, 0, 1.17)

	-- Vertical fins remain sparse surface rhythm instead of emphasizing every facet.
	local step = math.pi * 2 / FIN_COUNT
	for index = 0, FIN_COUNT - 1 do
		local theta = index * step
		local cf = tangentFrame(67.8, 48.8, theta, 30.0, FIN_COUNT)
		part(
			upperGroup,
			"VerticalFin" .. string.format("_%02d", index + 1),
			Vector3.new(0.85, 25.0, 1.6),
			cf,
			COLORS.Metal,
			Enum.Material.Metal
		)
	end
end

local function addRoof(westGroup, eastGroup)
	-- Three broad sloped annular bands form a continuous shallow crown.
	-- Unlike v1, there are no horizontal staircase-like roof terraces.
	addSlopedRoofBand(westGroup, eastGroup, "RoofOuter", 65.5, 46.5, 44.0, 45.0, 31.5, 47.4)
	addSlopedRoofBand(westGroup, eastGroup, "RoofMiddle", 45.6, 32.0, 47.2, 24.0, 16.5, 51.6)
	addSlopedRoofBand(westGroup, eastGroup, "RoofInner", 24.6, 17.0, 51.4, 5.5, 3.8, 54.5)

	addOvalCap(westGroup, "RoofCentralOvalCap", 54.8)

	-- Smooth perimeter ring hides the outer polygon joints and gives the roof
	-- one clean continuous edge when viewed from street level.
	addSmoothRing(westGroup, "RoofPerimeter", 65.8, 46.8, 43.7, 2.3, 1.6, SEGMENTS, COLORS.Metal, Enum.Material.Metal, 0, 1.18)
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
	model:SetAttribute("GeometryRevision", "LargeCityUptownArena-v2-SmoothShellRoof")
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("Style", specification.Style)
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
	model:SetAttribute("FacadeSegmentCount", SEGMENTS)
	model:SetAttribute("RoofSegmentCount", SEGMENTS)
	model:SetAttribute("EnclosedArenaShell", true)
	model:SetAttribute("EnclosedRoof", true)
	model:SetAttribute("SmoothFacadeShell", true)
	model:SetAttribute("SlopedContinuousRoof", true)
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
