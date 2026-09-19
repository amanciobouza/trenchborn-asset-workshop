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
	block(group, "ResearchHeadhouseMass", Vector3.new(42, 32, 72), Vector3.new(-39, 16, -4), COLORS.Sterile, Enum.Material.Concrete)

	-- Tall recessed sterile-glass atrium on local -Z.
	block(group, "AtriumPortal", Vector3.new(32, 26, 3.2), Vector3.new(-39, 13, -39.1), COLORS.Dark, Enum.Material.Metal)
	block(group, "AtriumGlass", Vector3.new(28, 23, 0.65), Vector3.new(-39, 12.5, -41.1), COLORS.Glass, Enum.Material.Glass, 0.06)
	for _, x in ipairs({-51, -45, -39, -33, -27}) do
		block(group, "AtriumMullion_" .. tostring(x), Vector3.new(0.75, 24, 0.9), Vector3.new(x, 12.5, -41.45), COLORS.Metal, Enum.Material.Metal)
	end
	for _, y in ipairs({6.5, 13.0, 19.5}) do
		block(group, "AtriumHorizontal_" .. tostring(y), Vector3.new(29, 0.55, 0.9), Vector3.new(-39, y, -41.45), COLORS.Metal, Enum.Material.Metal)
	end

	block(group, "VisitorCanopy", Vector3.new(34, 1.2, 9), Vector3.new(-39, 12.8, -45.3), COLORS.Sterile, Enum.Material.Metal)
	for _, x in ipairs({-53.5, -24.5}) do
		block(group, "VisitorCanopyPost_" .. tostring(x), Vector3.new(1.1, 11.5, 1.1), Vector3.new(x, 5.75, -48.7), COLORS.SterileDark, Enum.Material.Metal)
	end
	block(group, "VisitorPlaza", Vector3.new(46, 0.45, 14), Vector3.new(-39, 0.23, -47.0), COLORS.SterileDark, Enum.Material.Concrete)

	-- Public facade side glazing keeps the headhouse distinctly research-oriented.
	block(group, "HeadhouseSideGlass", Vector3.new(0.65, 25, 44), Vector3.new(-60.4, 16, -6), COLORS.Glass, Enum.Material.Glass, 0.07)
	for _, z in ipairs({-24, -12, 0, 12}) do
		block(group, "HeadhouseSideMullion_" .. tostring(z), Vector3.new(0.85, 26, 0.7), Vector3.new(-60.75, 16, z), COLORS.Metal, Enum.Material.Metal)
	end
end

local function addResearchHeadhouse(group)
	-- Long research observation bands on the rear and upper front edges.
	block(group, "ResearchBandFront", Vector3.new(36, 4.4, 0.65), Vector3.new(-39, 25.0, -40.35), COLORS.Glass, Enum.Material.Glass, 0.07)
	block(group, "ResearchBandRear", Vector3.new(36, 4.4, 0.65), Vector3.new(-39, 19.0, 32.35), COLORS.Glass, Enum.Material.Glass, 0.07)

	for _, x in ipairs({-54, -48, -42, -36, -30, -24}) do
		block(group, "ResearchFrontFrame_" .. tostring(x), Vector3.new(0.55, 4.8, 0.8), Vector3.new(x, 25.0, -40.7), COLORS.Metal, Enum.Material.Metal)
	end

	-- Vertical sterile spine visually separates research and process zones.
	block(group, "ResearchSpine", Vector3.new(4.0, 30, 8), Vector3.new(-19.5, 15.0, -8), COLORS.SterileDark, Enum.Material.Concrete)
	block(group, "ResearchSpineTeal", Vector3.new(0.45, 25, 6), Vector3.new(-21.75, 15.0, -8), COLORS.Teal, Enum.Material.Neon)
end

local function addCleanroomHall(group)
	block(group, "CleanroomHallMass", Vector3.new(76, 28, 74), Vector3.new(20, 14, 2), COLORS.Sterile, Enum.Material.Concrete)

	-- Two cleanroom observation bands front and rear. They stand clearly outside the wall.
	for bandIndex, y in ipairs({9.0, 19.0}) do
		block(group, "CleanroomFrontBand_" .. bandIndex, Vector3.new(66, 4.4, 0.65), Vector3.new(20, y, -35.4), COLORS.Glass, Enum.Material.Glass, 0.07)
		block(group, "CleanroomRearBand_" .. bandIndex, Vector3.new(66, 4.4, 0.65), Vector3.new(20, y, 39.4), COLORS.Glass, Enum.Material.Glass, 0.07)

		for bay = 0, 9 do
			local x = -13 + (66 / 9) * bay
			block(group, "FrontBandMullion_" .. bandIndex .. "_" .. bay, Vector3.new(0.48, 4.8, 0.82), Vector3.new(x, y, -35.75), COLORS.Metal, Enum.Material.Metal)
			block(group, "RearBandMullion_" .. bandIndex .. "_" .. bay, Vector3.new(0.48, 4.8, 0.82), Vector3.new(x, y, 39.75), COLORS.Metal, Enum.Material.Metal)
		end
	end

	-- Sterile facade seams keep the hall modular and engineered.
	for bay = 0, 9 do
		local x = -18 + (76 / 9) * bay
		block(group, "CleanroomPanelJointFront_" .. bay, Vector3.new(0.32, 27, 0.45), Vector3.new(x, 14, -35.55), COLORS.SterileDark, Enum.Material.Metal)
		block(group, "CleanroomPanelJointRear_" .. bay, Vector3.new(0.32, 27, 0.45), Vector3.new(x, 14, 39.55), COLORS.SterileDark, Enum.Material.Metal)
	end

	-- Restrained chemical safety accents on process-facing corners only.
	block(group, "ChemicalSafetyFront", Vector3.new(0.5, 18, 0.5), Vector3.new(58.4, 14, -34.8), COLORS.Chemical, Enum.Material.Neon)
	block(group, "ChemicalSafetyRear", Vector3.new(0.5, 18, 0.5), Vector3.new(58.4, 14, 38.8), COLORS.Chemical, Enum.Material.Neon)
end

local function addProcessBridge(group)
	-- Bridge crosses the seam between headhouse and production hall and remains visibly external.
	block(group, "BridgeFrame", Vector3.new(18, 7, 8), Vector3.new(-16, 24, -19), COLORS.Dark, Enum.Material.Metal)
	block(group, "BridgeGlassFront", Vector3.new(16.5, 5.5, 0.55), Vector3.new(-16, 24, -23.25), COLORS.Glass, Enum.Material.Glass, 0.06)
	block(group, "BridgeGlassRear", Vector3.new(16.5, 5.5, 0.55), Vector3.new(-16, 24, -14.75), COLORS.Glass, Enum.Material.Glass, 0.06)
	for _, x in ipairs({-23, -19.5, -16, -12.5, -9}) do
		block(group, "BridgeMullion_" .. tostring(x), Vector3.new(0.4, 5.8, 0.75), Vector3.new(x, 24, -23.55), COLORS.Metal, Enum.Material.Metal)
	end
	block(group, "BridgeTealUnderside", Vector3.new(16, 0.4, 6.6), Vector3.new(-16, 20.35, -19), COLORS.Teal, Enum.Material.Neon)
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
	-- Keep the four large vessel housings, but move them out of the loading-door
	-- approach. The process court now runs along the cleanroom hall's right side,
	-- while the rear face remains a clear logistics zone.
	local vessels = {
		{z = -20, height = 24},
		{z = -7, height = 28},
		{z = 6, height = 26},
		{z = 19, height = 22},
	}
	local vesselX = 62.0

	for index, vessel in ipairs(vessels) do
		local centerY = vessel.height / 2
		cylinderY(group, "Bioreactor_" .. index, vessel.height, 8, Vector3.new(vesselX, centerY, vessel.z), COLORS.Silver, Enum.Material.Metal)
		cylinderY(group, "BioreactorTop_" .. index, 1.0, 8.5, Vector3.new(vesselX, vessel.height + 0.5, vessel.z), COLORS.Metal, Enum.Material.Metal)
		block(
			group,
			"BioreactorSafetyStripe_" .. index,
			Vector3.new(0.35, 0.5, 8.4),
			Vector3.new(57.8, vessel.height * 0.62, vessel.z),
			index % 2 == 0 and COLORS.Chemical or COLORS.Teal,
			Enum.Material.Neon
		)
	end

	-- Long side gantry ties the vessels together as one organized pharma process
	-- court without blocking any rear loading bay.
	block(group, "BioreactorGantry", Vector3.new(4, 1.0, 50), Vector3.new(57.5, 21.0, 0), COLORS.Dark, Enum.Material.Metal)
	for _, z in ipairs({-22, -10, 2, 14, 26}) do
		block(group, "GantryPost_" .. tostring(z), Vector3.new(0.7, 21, 0.7), Vector3.new(57.5, 10.5, z), COLORS.Metal, Enum.Material.Metal)
	end
	block(group, "GantryTealLine", Vector3.new(0.35, 0.35, 48), Vector3.new(55.5, 21.7, 0), COLORS.Teal, Enum.Material.Neon)

	-- A clean feed manifold connects the process court back toward the hall.
	cylinderZ(group, "BioreactorFeedMain", 42, 1.4, Vector3.new(56.0, 18.5, 0), COLORS.Silver, Enum.Material.Metal)
	cylinderX(group, "BioreactorFeedLink", 12, 1.4, Vector3.new(50.0, 18.5, 0), COLORS.Silver, Enum.Material.Metal)
end
local function addServiceLoading(group)
	-- Rear face is now dedicated to logistics. All four loading doors sit in one
	-- unobstructed left/central service zone with a continuous canopy and apron.
	for index, x in ipairs({-10, 4, 18, 32}) do
		block(group, "LoadingDoor_" .. index, Vector3.new(8, 7.5, 0.6), Vector3.new(x, 4.2, 39.75), COLORS.DarkGlass, Enum.Material.Metal)
		block(group, "LoadingFrameTop_" .. index, Vector3.new(9, 0.55, 0.4), Vector3.new(x, 8.25, 40.1), COLORS.Metal, Enum.Material.Metal)
		block(group, "LoadingFrameLeft_" .. index, Vector3.new(0.55, 7.7, 0.4), Vector3.new(x - 4.25, 4.2, 40.1), COLORS.Metal, Enum.Material.Metal)
		block(group, "LoadingFrameRight_" .. index, Vector3.new(0.55, 7.7, 0.4), Vector3.new(x + 4.25, 4.2, 40.1), COLORS.Metal, Enum.Material.Metal)
	end

	block(group, "LoadingCanopy", Vector3.new(58, 1.1, 8), Vector3.new(11, 10.5, 44.0), COLORS.SterileDark, Enum.Material.Metal)
	block(group, "LoadingApron", Vector3.new(62, 0.45, 16), Vector3.new(11, 0.23, 49.0), COLORS.SterileDark, Enum.Material.Concrete)

	-- A narrow process-yard divider marks the transition to the side bioreactor
	-- court without obscuring the vessels or blocking vehicle access.
	block(group, "ProcessCourtDivider", Vector3.new(1.0, 8, 18), Vector3.new(52.0, 4.0, 30), COLORS.Dark, Enum.Material.Metal)
	block(group, "ChemicalZoneMarker", Vector3.new(0.28, 6.5, 15), Vector3.new(51.4, 4.0, 30), COLORS.Chemical, Enum.Material.Neon)
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
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("GeometryRevision", "LargeCityMeridianPharma-v3-SeparatedProcessAndLoading")
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("ResearchHeadhouseDistinct", true)
	model:SetAttribute("CleanroomObservationBands", true)
	model:SetAttribute("ProcessBridgeExternal", true)
	model:SetAttribute("BioreactorCount", 4)
	model:SetAttribute("RooftopProcessModuleCount", 3)
	model:SetAttribute("RooftopProcessModulesOnPlinths", true)
	model:SetAttribute("ExhaustStacksOnUtilityPlinth", true)
	model:SetAttribute("ExhaustClusterDuctConnected", true)
	model:SetAttribute("RearLoadingVisible", true)
	model:SetAttribute("BioreactorCourtSideSeparated", true)
	model:SetAttribute("LoadingDoorsUnobstructed", true)
	model.Parent = parent

	local groups = folder(model, "DestructionGroups")
	local d1 = folder(groups, "D1_ResearchEntrance")
	local d2 = folder(groups, "D2_ResearchHeadhouse")
	local d3 = folder(groups, "D3_CleanroomHall")
	local d4 = folder(groups, "D4_ProcessBridge")
	local d5 = folder(groups, "D5_RooftopProcessModules")
	local d6 = folder(groups, "D6_BioreactorCourt")
	local d7 = folder(groups, "D7_ServiceAndLoading")

	addResearchEntrance(d1)
	addResearchHeadhouse(d2)
	addCleanroomHall(d3)
	addProcessBridge(d4)
	addRooftopProcess(d5)
	addBioreactorCourt(d6)
	addServiceLoading(d7)

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
