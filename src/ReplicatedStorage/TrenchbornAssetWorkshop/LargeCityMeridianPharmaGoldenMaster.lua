local specification = require(script.Parent:WaitForChild("LargeCityMeridianPharmaSpecification"))

local Builder = {}

local COLORS = {
	Sterile = Color3.fromRGB(229, 228, 222),
	SterileDark = Color3.fromRGB(186, 190, 188),
	Glass = Color3.fromRGB(46, 93, 105),
	DarkGlass = Color3.fromRGB(29, 55, 64),
	Dark = Color3.fromRGB(39, 46, 50),
	Metal = Color3.fromRGB(173, 178, 177),
	Silver = Color3.fromRGB(194, 199, 197),
	Teal = Color3.fromRGB(55, 166, 173),
	Chemical = Color3.fromRGB(170, 64, 132),
	PlantBed = Color3.fromRGB(69, 83, 64),
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

local function cylinderY(parent, name, height, diameter, position, color, material, transparency)
	return part(
		parent,
		name,
		Vector3.new(height, diameter, diameter),
		CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)),
		color,
		material,
		transparency or 0,
		Enum.PartType.Cylinder
	)
end

local function cylinderX(parent, name, length, diameter, position, color, material)
	return part(
		parent,
		name,
		Vector3.new(length, diameter, diameter),
		CFrame.new(position),
		color,
		material,
		0,
		Enum.PartType.Cylinder
	)
end

local function cylinderZ(parent, name, length, diameter, position, color, material)
	return part(
		parent,
		name,
		Vector3.new(length, diameter, diameter),
		CFrame.new(position) * CFrame.Angles(0, math.rad(90), 0),
		color,
		material,
		0,
		Enum.PartType.Cylinder
	)
end

local function addResearchEntrance(group)
	-- Research headhouse is the public-facing, highly glazed part of the complex.
	block(group, "ResearchHeadhouseMass", Vector3.new(42, 32, 72), Vector3.new(-43, 16, -4), COLORS.Sterile, Enum.Material.Concrete)

	-- Tall recessed sterile-glass atrium on local -Z.
	block(group, "AtriumPortal", Vector3.new(32, 26, 3.2), Vector3.new(-43, 13, -39.1), COLORS.Dark, Enum.Material.Metal)
	block(group, "AtriumGlass", Vector3.new(28, 23, 0.65), Vector3.new(-43, 12.5, -41.1), COLORS.Glass, Enum.Material.Glass, 0.06)
	for _, x in ipairs({-55, -49, -43, -37, -31}) do
		block(group, "AtriumMullion_" .. tostring(x), Vector3.new(0.75, 24, 0.9), Vector3.new(x, 12.5, -41.45), COLORS.Metal, Enum.Material.Metal)
	end
	for _, y in ipairs({6.5, 13.0, 19.5}) do
		block(group, "AtriumHorizontal_" .. tostring(y), Vector3.new(29, 0.55, 0.9), Vector3.new(-43, y, -41.45), COLORS.Metal, Enum.Material.Metal)
	end

	block(group, "VisitorCanopy", Vector3.new(34, 1.2, 9), Vector3.new(-43, 12.8, -45.3), COLORS.Sterile, Enum.Material.Metal)
	for _, x in ipairs({-57.5, -28.5}) do
		block(group, "VisitorCanopyPost_" .. tostring(x), Vector3.new(1.1, 11.5, 1.1), Vector3.new(x, 5.75, -48.7), COLORS.SterileDark, Enum.Material.Metal)
	end
	block(group, "VisitorPlaza", Vector3.new(46, 0.45, 14), Vector3.new(-43, 0.23, -47.0), COLORS.SterileDark, Enum.Material.Concrete)

	-- Public facade side glazing keeps the headhouse distinctly research-oriented.
	block(group, "HeadhouseSideGlass", Vector3.new(0.65, 25, 44), Vector3.new(-64.4, 16, -6), COLORS.Glass, Enum.Material.Glass, 0.07)
	for _, z in ipairs({-24, -12, 0, 12}) do
		block(group, "HeadhouseSideMullion_" .. tostring(z), Vector3.new(0.85, 26, 0.7), Vector3.new(-64.75, 16, z), COLORS.Metal, Enum.Material.Metal)
	end
end

local function addResearchHeadhouse(group)
	-- Long research observation bands on the rear and upper front edges.
	block(group, "ResearchBandFront", Vector3.new(36, 4.4, 0.65), Vector3.new(-43, 25.0, -40.35), COLORS.Glass, Enum.Material.Glass, 0.07)
	block(group, "ResearchBandRear", Vector3.new(36, 4.4, 0.65), Vector3.new(-43, 19.0, 32.35), COLORS.Glass, Enum.Material.Glass, 0.07)

	for _, x in ipairs({-58, -52, -46, -40, -34, -28}) do
		block(group, "ResearchFrontFrame_" .. tostring(x), Vector3.new(0.55, 4.8, 0.8), Vector3.new(x, 25.0, -40.7), COLORS.Metal, Enum.Material.Metal)
	end

	-- Visible seam pylon sits in the open gap between research and production.
	-- It no longer intersects either building mass; the teal strip is mounted on
	-- the pylon's front face so the feature reads intentionally from the street.
	block(group, "ResearchSpine", Vector3.new(2.0, 30, 5.0), Vector3.new(-20.0, 15.0, -33.5), COLORS.SterileDark, Enum.Material.Concrete)
	block(group, "ResearchSpineTeal", Vector3.new(1.2, 25, 0.35), Vector3.new(-20.0, 15.0, -36.2), COLORS.Teal, Enum.Material.Neon)
end

local function addCleanroomHall(group)
	block(group, "CleanroomHallMass", Vector3.new(76, 28, 74), Vector3.new(20, 14, 2), COLORS.Sterile, Enum.Material.Concrete)

	-- One shared facade grid controls BOTH observation bands and the full-height
	-- vertical framing. This prevents the upper/lower windows and long vertical
	-- struts from using different X positions.
	local facadeGrid = {}
	for bay = 0, 9 do
		facadeGrid[#facadeGrid + 1] = -13 + (66 / 9) * bay
	end

	-- Two cleanroom observation bands front and rear.
	for bandIndex, y in ipairs({9.0, 19.0}) do
		block(group, "CleanroomFrontBand_" .. bandIndex, Vector3.new(66, 4.4, 0.65), Vector3.new(20, y, -35.4), COLORS.Glass, Enum.Material.Glass, 0.07)
		block(group, "CleanroomRearBand_" .. bandIndex, Vector3.new(66, 4.4, 0.65), Vector3.new(20, y, 39.4), COLORS.Glass, Enum.Material.Glass, 0.07)
	end

	-- Continuous vertical facade frames now run from bottom to top on exactly
	-- the same grid as both window bands.
	for index, x in ipairs(facadeGrid) do
		block(group, "CleanroomVerticalFrameFront_" .. index, Vector3.new(0.55, 27, 0.82), Vector3.new(x, 14, -35.75), COLORS.Metal, Enum.Material.Metal)
		block(group, "CleanroomVerticalFrameRear_" .. index, Vector3.new(0.55, 27, 0.82), Vector3.new(x, 14, 39.75), COLORS.Metal, Enum.Material.Metal)
	end

	-- Horizontal caps make the two observation levels read as intentional bands
	-- while preserving the same vertical rhythm all the way through the facade.
	for bandIndex, y in ipairs({6.8, 11.2, 16.8, 21.2}) do
		block(group, "CleanroomBandRailFront_" .. bandIndex, Vector3.new(66, 0.42, 0.78), Vector3.new(20, y, -35.72), COLORS.Metal, Enum.Material.Metal)
		block(group, "CleanroomBandRailRear_" .. bandIndex, Vector3.new(66, 0.42, 0.78), Vector3.new(20, y, 39.72), COLORS.Metal, Enum.Material.Metal)
	end

	-- Restrained chemical safety accents on process-facing corners only.
	block(group, "ChemicalSafetyFront", Vector3.new(0.5, 18, 0.5), Vector3.new(58.4, 14, -34.8), COLORS.Chemical, Enum.Material.Neon)
	block(group, "ChemicalSafetyRear", Vector3.new(0.5, 18, 0.5), Vector3.new(58.4, 14, 38.8), COLORS.Chemical, Enum.Material.Neon)
end
local function addProcessBridge(group)
	-- Short elevated bridge spans the real open seam between the research
	-- headhouse (right edge X=-22) and cleanroom hall (left edge X=-18).
	-- It overlaps each facade only slightly for a believable structural tie-in.
	local center = Vector3.new(-20, 24, -19)
	block(group, "BridgeFrame", Vector3.new(8, 7, 8), center, COLORS.Dark, Enum.Material.Metal)
	block(group, "BridgeGlassFront", Vector3.new(6.8, 5.5, 0.55), center + Vector3.new(0, 0, -4.25), COLORS.Glass, Enum.Material.Glass, 0.06)
	block(group, "BridgeGlassRear", Vector3.new(6.8, 5.5, 0.55), center + Vector3.new(0, 0, 4.25), COLORS.Glass, Enum.Material.Glass, 0.06)
	for _, x in ipairs({-23, -21.5, -20, -18.5, -17}) do
		block(group, "BridgeMullion_" .. tostring(x), Vector3.new(0.35, 5.8, 0.75), Vector3.new(x, 24, -23.55), COLORS.Metal, Enum.Material.Metal)
	end
	block(group, "BridgeTealUnderside", Vector3.new(6.5, 0.4, 6.6), Vector3.new(-20, 20.35, -19), COLORS.Teal, Enum.Material.Neon)
end
local function addRooftopProcess(group)
	-- Three deliberate process modules sit visibly ON the cleanroom roof.
	-- Each gets a shallow equipment plinth so no technical box appears buried
	-- inside the production hall.
	local modules = {
		{name = "A", size = Vector3.new(20, 7, 14), pos = Vector3.new(5, 32.0, -13)},
		{name = "B", size = Vector3.new(18, 8, 12), pos = Vector3.new(31, 32.5, -11)},
		{name = "C", size = Vector3.new(16, 6, 11), pos = Vector3.new(43, 31.5, 12)},
	}
	for _, module in ipairs(modules) do
		block(
			group,
			"ProcessModulePlinth_" .. module.name,
			Vector3.new(module.size.X + 1.5, 0.5, module.size.Z + 1.5),
			Vector3.new(module.pos.X, 28.25, module.pos.Z),
			COLORS.SterileDark,
			Enum.Material.Concrete
		)
		block(group, "ProcessModule_" .. module.name, module.size, module.pos, COLORS.Dark, Enum.Material.Metal)
		block(
			group,
			"ProcessModuleScreen_" .. module.name,
			Vector3.new(module.size.X - 2, module.size.Y - 1.5, 0.45),
			module.pos + Vector3.new(0, 0, -(module.size.Z / 2 + 0.25)),
			COLORS.Metal,
			Enum.Material.Metal
		)
		-- Cyan/teal elements belong to these rooftop process modules as restrained
		-- service-status accents, not inside the building mass.
		block(
			group,
			"ProcessModuleTeal_" .. module.name,
			Vector3.new(module.size.X - 4, 0.45, 0.28),
			module.pos + Vector3.new(0, -module.size.Y / 2 + 1.1, -(module.size.Z / 2 + 0.48)),
			COLORS.Teal,
			Enum.Material.Neon
		)
	end

	-- Clean silver duct network linking the rooftop process modules.
	cylinderX(group, "MainDuct_X", 46, 1.4, Vector3.new(22, 36.0, 1), COLORS.Silver, Enum.Material.Metal)
	cylinderZ(group, "DuctToModuleA", 15, 1.4, Vector3.new(5, 36.0, -6.5), COLORS.Silver, Enum.Material.Metal)
	cylinderZ(group, "DuctToModuleB", 13, 1.4, Vector3.new(31, 36.0, -5.5), COLORS.Silver, Enum.Material.Metal)
	cylinderZ(group, "DuctToModuleC", 11, 1.4, Vector3.new(43, 36.0, 6.5), COLORS.Silver, Enum.Material.Metal)

	-- The three exhaust stacks now form one coherent rooftop utility cluster:
	-- a shared technical plinth sits directly on the cleanroom roof and the
	-- stacks rise from it, with a visible manifold duct tying them back to the
	-- process network. Nothing floats.
	block(
		group,
		"ExhaustUtilityPlinth",
		Vector3.new(20, 3.0, 14),
		Vector3.new(20, 29.5, 16),
		COLORS.Dark,
		Enum.Material.Metal
	)
	block(
		group,
		"ExhaustUtilityScreen",
		Vector3.new(18, 2.0, 0.45),
		Vector3.new(20, 29.7, 8.75),
		COLORS.Metal,
		Enum.Material.Metal
	)
	block(
		group,
		"ExhaustUtilityTeal",
		Vector3.new(14, 0.4, 0.28),
		Vector3.new(20, 30.3, 8.48),
		COLORS.Teal,
		Enum.Material.Neon
	)

	local stackHeights = {10.0, 11.0, 12.0}
	for index, x in ipairs({14, 20, 26}) do
		local height = stackHeights[index]
		local baseY = 31.0
		local centerY = baseY + height / 2
		cylinderY(group, "ExhaustStack_" .. index, height, 1.8, Vector3.new(x, centerY, 16), COLORS.Silver, Enum.Material.Metal)
		cylinderY(group, "ExhaustCap_" .. index, 0.8, 2.5, Vector3.new(x, baseY + height + 0.4, 16), COLORS.Dark, Enum.Material.Metal)
	end

	-- Manifold visibly connects the exhaust cluster to the rooftop process zone.
	cylinderX(group, "ExhaustManifold_X", 16, 1.4, Vector3.new(20, 33.0, 11), COLORS.Silver, Enum.Material.Metal)
	cylinderZ(group, "ExhaustManifold_Z", 10, 1.4, Vector3.new(20, 33.0, 6), COLORS.Silver, Enum.Material.Metal)
end
local function addBioreactorCourt(group)
	-- Four large vessel housings stay in the original rear process court.
	-- The former loading bays are removed entirely, so the tanks can remain
	-- prominent without blocking any doors or vehicle approach.
	local vessels = {
		{x = 4, height = 24},
		{x = 15, height = 28},
		{x = 26, height = 26},
		{x = 37, height = 22},
	}

	-- A simple process pad grounds the vessel group and makes the court read as
	-- intentional infrastructure rather than loose objects behind the building.
	block(group, "BioreactorProcessPad", Vector3.new(50, 0.45, 10), Vector3.new(20.5, 0.23, 44), COLORS.SterileDark, Enum.Material.Concrete)

	for index, vessel in ipairs(vessels) do
		local centerY = vessel.height / 2
		cylinderY(group, "Bioreactor_" .. index, vessel.height, 8, Vector3.new(vessel.x, centerY, 43), COLORS.Silver, Enum.Material.Metal)
		cylinderY(group, "BioreactorTop_" .. index, 1.0, 8.5, Vector3.new(vessel.x, vessel.height + 0.5, 43), COLORS.Metal, Enum.Material.Metal)
		block(group, "BioreactorSafetyStripe_" .. index, Vector3.new(8.4, 0.5, 0.35), Vector3.new(vessel.x, vessel.height * 0.62, 47.2), index % 2 == 0 and COLORS.Chemical or COLORS.Teal, Enum.Material.Neon)
	end

	-- Service gantry now runs on the OUTER side of the tanks. In the previous revision
	-- the gantry posts and teal line sat inside the cleanroom rear wall and looked like
	-- floating cyan/pink bars behind columns.
	block(group, "BioreactorGantry", Vector3.new(46, 1.0, 2.0), Vector3.new(20.5, 21.0, 48.0), COLORS.Dark, Enum.Material.Metal)
	for _, x in ipairs({0, 11, 22, 33, 44}) do
		block(group, "GantryPost_" .. tostring(x), Vector3.new(0.7, 21, 0.7), Vector3.new(x, 10.5, 48.0), COLORS.Metal, Enum.Material.Metal)
	end
	block(group, "GantryTealLine", Vector3.new(44, 0.35, 0.35), Vector3.new(20.5, 21.7, 49.2), COLORS.Teal, Enum.Material.Neon)
end
local function addProcessServiceInfrastructure(group)
	-- No loading stations on this asset. Keep only a small chemical safety
	-- marker at the process-court edge so D7 remains a meaningful service group.
	block(group, "ProcessSafetyPost", Vector3.new(0.6, 5.5, 0.6), Vector3.new(49.5, 2.75, 42.5), COLORS.Dark, Enum.Material.Metal)
	block(group, "ProcessSafetyMarker", Vector3.new(0.28, 4.5, 0.28), Vector3.new(49.15, 2.75, 42.5), COLORS.Chemical, Enum.Material.Neon)
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
	local existing = parent:FindFirstChild("LargeCity_MeridianPharma_L3_GoldenMaster")
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = "LargeCity_MeridianPharma_L3_GoldenMaster"
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("AssetPhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("GeometryRevision", "LargeCityMeridianPharma-v7-AlignedCleanroomFacadeGrid")
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("ResearchHeadhouseDistinct", true)
	model:SetAttribute("CleanroomObservationBands", true)
	model:SetAttribute("CleanroomFacadeGridAligned", true)
	model:SetAttribute("ProcessBridgeExternal", true)
	model:SetAttribute("ResearchProductionGapVisible", true)
	model:SetAttribute("ResearchSpineExternal", true)
	model:SetAttribute("BioreactorCount", 4)
	model:SetAttribute("RooftopProcessModuleCount", 3)
	model:SetAttribute("RooftopProcessModulesOnPlinths", true)
	model:SetAttribute("ExhaustStacksOnUtilityPlinth", true)
	model:SetAttribute("ExhaustClusterDuctConnected", true)
	model:SetAttribute("RearLoadingVisible", false)
	model:SetAttribute("LoadingBayCount", 0)
	model:SetAttribute("BioreactorCourtRear", true)
	model:SetAttribute("BioreactorSafetyBandsExternal", true)
	model:SetAttribute("BioreactorGantryOutsideHall", true)
	model.Parent = parent

	local groups = folder(model, "DestructionGroups")
	local d1 = folder(groups, "D1_ResearchEntrance")
	local d2 = folder(groups, "D2_ResearchHeadhouse")
	local d3 = folder(groups, "D3_CleanroomHall")
	local d4 = folder(groups, "D4_ProcessBridge")
	local d5 = folder(groups, "D5_RooftopProcessModules")
	local d6 = folder(groups, "D6_BioreactorCourt")
	local d7 = folder(groups, "D7_ProcessServiceInfrastructure")

	addResearchEntrance(d1)
	addResearchHeadhouse(d2)
	addCleanroomHall(d3)
	addProcessBridge(d4)
	addRooftopProcess(d5)
	addBioreactorCourt(d6)
	addProcessServiceInfrastructure(d7)

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
