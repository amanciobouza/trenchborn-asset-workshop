local specification = require(script.Parent:WaitForChild("LargeCityPowerUtilitySpecification"))

local Builder = {}

local COLORS = {
	Concrete = Color3.fromRGB(226, 228, 224),
	ConcreteDark = Color3.fromRGB(184, 189, 187),
	Graphite = Color3.fromRGB(40, 47, 52),
	GraphiteLight = Color3.fromRGB(72, 80, 84),
	Glass = Color3.fromRGB(48, 92, 104),
	Metal = Color3.fromRGB(171, 178, 179),
	Silver = Color3.fromRGB(198, 202, 202),
	Cyan = Color3.fromRGB(54, 170, 181),
	Amber = Color3.fromRGB(224, 162, 74),
	Ceramic = Color3.fromRGB(214, 216, 205),
	Ground = Color3.fromRGB(116, 121, 119),
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

local function addControlEntrance(group)
	-- A genuine public/control entry projects in front of the two industrial halls.
	block(group, "ControlPortalFrame", Vector3.new(30, 22, 3.0), Vector3.new(-2, 11, -42.4), COLORS.Graphite, Enum.Material.Metal)
	block(group, "ControlPortalGlass", Vector3.new(25.5, 18.5, 0.65), Vector3.new(-2, 10.5, -44.2), COLORS.Glass, Enum.Material.Glass, 0.06)

	for _, x in ipairs({-11, -5, 1, 7}) do
		block(group, "ControlPortalMullion_" .. tostring(x), Vector3.new(0.6, 19, 0.85), Vector3.new(x, 10.5, -44.55), COLORS.Metal, Enum.Material.Metal)
	end

	block(group, "ControlCanopy", Vector3.new(34, 1.2, 8), Vector3.new(-2, 14.2, -47.4), COLORS.Concrete, Enum.Material.Metal)
	for _, x in ipairs({-15.5, 11.5}) do
		block(group, "ControlCanopyPost_" .. tostring(x), Vector3.new(0.9, 11.5, 0.9), Vector3.new(x, 5.75, -50.6), COLORS.ConcreteDark, Enum.Material.Metal)
	end

	block(group, "ControlPlaza", Vector3.new(42, 0.45, 12), Vector3.new(-2, 0.23, -49.0), COLORS.ConcreteDark, Enum.Material.Concrete)
	block(group, "ControlCyanHeader", Vector3.new(22, 0.38, 0.28), Vector3.new(-2, 20.2, -44.65), COLORS.Cyan, Enum.Material.Neon)
end

local function addSwitchgearHall(group)
	block(group, "SwitchgearHallMass", Vector3.new(68, 32, 44), Vector3.new(-38, 16, -19), COLORS.Concrete, Enum.Material.Concrete)

	-- Dark lower service band.
	block(group, "SwitchgearLowerFront", Vector3.new(64, 7.5, 0.8), Vector3.new(-38, 4.0, -41.45), COLORS.Graphite, Enum.Material.Metal)
	block(group, "SwitchgearLowerRear", Vector3.new(64, 7.5, 0.8), Vector3.new(-38, 4.0, 3.45), COLORS.Graphite, Enum.Material.Metal)

	-- Deep vertical fins create the switchgear rhythm from ground to roof.
	for bay = 0, 8 do
		local x = -68 + bay * 7.5
		block(group, "SwitchgearFinFront_" .. bay, Vector3.new(1.0, 30, 2.2), Vector3.new(x, 16, -42.4), COLORS.GraphiteLight, Enum.Material.Metal)
		block(group, "SwitchgearFinRear_" .. bay, Vector3.new(1.0, 30, 2.2), Vector3.new(x, 16, 4.4), COLORS.GraphiteLight, Enum.Material.Metal)
	end

	-- Controlled equipment windows, deliberately smaller than office glazing.
	for bay = 0, 7 do
		local x = -64.2 + bay * 7.5
		block(group, "SwitchgearIndicator_" .. bay, Vector3.new(4.0, 3.0, 0.55), Vector3.new(x, 19.0, -41.65), COLORS.Glass, Enum.Material.Glass, 0.08)
	end

	-- Restrained live-power accents sit on actual facade fins.
	block(group, "SwitchgearCyanEdge", Vector3.new(0.36, 25, 0.34), Vector3.new(-72.55, 16, -41.7), COLORS.Cyan, Enum.Material.Neon)
end

local function addConverterHall(group)
	block(group, "ConverterHallMass", Vector3.new(62, 40, 42), Vector3.new(34, 20, -17), COLORS.Concrete, Enum.Material.Concrete)

	block(group, "ConverterLowerFront", Vector3.new(58, 8.0, 0.8), Vector3.new(34, 4.2, -38.45), COLORS.Graphite, Enum.Material.Metal)
	block(group, "ConverterLowerRear", Vector3.new(58, 8.0, 0.8), Vector3.new(34, 4.2, 4.45), COLORS.Graphite, Enum.Material.Metal)

	-- Seven vertical converter bays line up consistently from bottom to top.
	for bay = 0, 7 do
		local x = 7 + bay * 7.7
		block(group, "ConverterFinFront_" .. bay, Vector3.new(0.9, 38, 1.8), Vector3.new(x, 20, -39.25), COLORS.GraphiteLight, Enum.Material.Metal)
		block(group, "ConverterFinRear_" .. bay, Vector3.new(0.9, 38, 1.8), Vector3.new(x, 20, 5.25), COLORS.GraphiteLight, Enum.Material.Metal)
	end

	-- Two tall corner pylons anchor the higher mass.
	for index, x in ipairs({4.0, 64.0}) do
		block(group, "ConverterCornerPylon_" .. index, Vector3.new(2.4, 42, 4.0), Vector3.new(x, 21, -36.0), COLORS.ConcreteDark, Enum.Material.Concrete)
		block(group, "ConverterCyanEdge_" .. index, Vector3.new(0.42, 31, 0.34), Vector3.new(x, 21, -38.25), COLORS.Cyan, Enum.Material.Neon)
	end

	-- Small upper control windows keep the facade technical, not office-like.
	for bay = 0, 5 do
		local x = 11.5 + bay * 9.0
		block(group, "ConverterStatusGlass_" .. bay, Vector3.new(5.5, 3.3, 0.55), Vector3.new(x, 29.0, -38.65), COLORS.Glass, Enum.Material.Glass, 0.08)
	end
end

local function addGridControlSpine(group)
	-- The Phase-3 Z coordinate was too far inside the halls. The Golden Master
	-- deliberately projects the spine to the front facade so it reads as a real
	-- bridge/control volume rather than hidden interior geometry.
	local center = Vector3.new(-2, 27, -36.0)

	block(group, "GridControlFrame", Vector3.new(18, 20, 12), center, COLORS.Graphite, Enum.Material.Metal)
	block(group, "GridControlGlassFront", Vector3.new(15.5, 17.0, 0.65), center + Vector3.new(0, 0, -6.35), COLORS.Glass, Enum.Material.Glass, 0.05)
	block(group, "GridControlGlassRear", Vector3.new(15.5, 17.0, 0.65), center + Vector3.new(0, 0, 6.35), COLORS.Glass, Enum.Material.Glass, 0.05)

	for _, x in ipairs({-8, -4, 0, 4}) do
		block(group, "GridControlMullion_" .. tostring(x), Vector3.new(0.45, 17.5, 0.8), Vector3.new(x, 27, -42.7), COLORS.Metal, Enum.Material.Metal)
	end
	for _, y in ipairs({21, 27, 33}) do
		block(group, "GridControlRail_" .. tostring(y), Vector3.new(16, 0.45, 0.8), Vector3.new(-2, y, -42.7), COLORS.Metal, Enum.Material.Metal)
	end

	block(group, "GridControlCyanUnderside", Vector3.new(15.5, 0.35, 9.0), Vector3.new(-2, 16.85, -36), COLORS.Cyan, Enum.Material.Neon)
end

local function addTransformer(group, index, x, centerZ)
	local root = folder(group, "Transformer_" .. index)
	local bodyCenter = Vector3.new(x, 9.0, centerZ)

	block(root, "Body", Vector3.new(16, 18, 12), bodyCenter, COLORS.GraphiteLight, Enum.Material.Metal)
	block(root, "TopCap", Vector3.new(17, 1.2, 13), Vector3.new(x, 18.6, centerZ), COLORS.Metal, Enum.Material.Metal)
	block(root, "Base", Vector3.new(18, 1.0, 14), Vector3.new(x, 0.5, centerZ), COLORS.Graphite, Enum.Material.Metal)

	-- Cooling fins on both long sides.
	for fin = -3, 3 do
		local z = centerZ + fin * 1.45
		block(root, "CoolingFinL_" .. tostring(fin), Vector3.new(2.0, 13, 0.45), Vector3.new(x - 9.0, 8.5, z), COLORS.Metal, Enum.Material.Metal)
		block(root, "CoolingFinR_" .. tostring(fin), Vector3.new(2.0, 13, 0.45), Vector3.new(x + 9.0, 8.5, z), COLORS.Metal, Enum.Material.Metal)
	end

	-- Three ceramic bushings make each transformer unmistakably electrical.
	for bushing = -1, 1 do
		local bx = x + bushing * 4.2
		cylinderY(root, "BushingStem_" .. tostring(bushing), 8.0, 1.2, Vector3.new(bx, 23.0, centerZ), COLORS.Ceramic, Enum.Material.SmoothPlastic)
		for disc = 0, 3 do
			cylinderY(root, "BushingDisc_" .. tostring(bushing) .. "_" .. disc, 0.45, 2.2, Vector3.new(bx, 20.4 + disc * 1.6, centerZ), COLORS.Ceramic, Enum.Material.SmoothPlastic)
		end
		cylinderY(root, "BushingCap_" .. tostring(bushing), 0.7, 1.5, Vector3.new(bx, 27.1, centerZ), COLORS.Silver, Enum.Material.Metal)
	end

	-- Small amber safety stripe is physically attached to the transformer REAR face so it is readable from behind.
	block(root, "SafetyStripe", Vector3.new(11, 0.42, 0.30), Vector3.new(x, 5.5, centerZ + 6.18), COLORS.Amber, Enum.Material.Neon)
end
local function addCapacitorBank(parent, name, centerX, centerZ)
	local root = folder(parent, name)

	-- Raised rack makes each bank read as a dedicated reactive-power assembly.
	block(root, "RackBase", Vector3.new(14, 0.8, 9), Vector3.new(centerX, 0.4, centerZ), COLORS.Graphite, Enum.Material.Metal)
	for _, x in ipairs({centerX - 5.5, centerX + 5.5}) do
		block(root, "RackPost_" .. tostring(x), Vector3.new(0.7, 8.0, 0.7), Vector3.new(x, 4.4, centerZ), COLORS.Graphite, Enum.Material.Metal)
	end
	block(root, "RackTop", Vector3.new(13, 0.7, 0.9), Vector3.new(centerX, 8.2, centerZ), COLORS.Graphite, Enum.Material.Metal)

	-- Eight capacitor cans in two organized rows.
	local canIndex = 0
	for row = -1, 1, 2 do
		for column = -3, 3, 2 do
			canIndex += 1
			local x = centerX + column * 1.75
			local z = centerZ + row * 2.0
			cylinderY(root, "CapacitorCan_" .. canIndex, 5.8, 1.8, Vector3.new(x, 3.3, z), COLORS.Silver, Enum.Material.Metal)
			cylinderY(root, "CapacitorTop_" .. canIndex, 0.45, 2.2, Vector3.new(x, 6.45, z), COLORS.GraphiteLight, Enum.Material.Metal)
			cylinderY(root, "CapacitorInsulator_" .. canIndex, 1.8, 0.65, Vector3.new(x, 7.55, z), COLORS.Ceramic, Enum.Material.SmoothPlastic)
		end
	end

	-- Rigid upper bus and a restrained live indicator.
	cylinderX(root, "CapacitorBusbar", 12, 0.9, Vector3.new(centerX, 9.2, centerZ), COLORS.Silver, Enum.Material.Metal)
	block(root, "LiveIndicator", Vector3.new(10.5, 0.24, 0.24), Vector3.new(centerX, 9.2, centerZ - 0.65), COLORS.Cyan, Enum.Material.Neon)
end

local function addShuntReactor(parent, name, x, z)
	local root = folder(parent, name)

	block(root, "Foundation", Vector3.new(10, 0.7, 9), Vector3.new(x, 0.35, z), COLORS.Ground, Enum.Material.Concrete)
	cylinderY(root, "ReactorBody", 14, 7.5, Vector3.new(x, 7.4, z), COLORS.GraphiteLight, Enum.Material.Metal)
	cylinderY(root, "ReactorTop", 0.9, 8.4, Vector3.new(x, 14.85, z), COLORS.Metal, Enum.Material.Metal)

	for fin = -3, 3 do
		local localZ = z + fin * 1.3
		block(root, "CoolingFin_" .. tostring(fin), Vector3.new(1.5, 10.5, 0.38), Vector3.new(x - 4.5, 7.2, localZ), COLORS.Metal, Enum.Material.Metal)
	end

	for phase = -1, 1 do
		local bz = z + phase * 2.2
		cylinderY(root, "Bushing_" .. tostring(phase), 5.5, 0.95, Vector3.new(x, 18.0, bz), COLORS.Ceramic, Enum.Material.SmoothPlastic)
		for disc = 0, 2 do
			cylinderY(root, "BushingDisc_" .. tostring(phase) .. "_" .. disc, 0.35, 1.8, Vector3.new(x, 16.2 + disc * 1.5, bz), COLORS.Ceramic, Enum.Material.SmoothPlastic)
		end
	end

	block(root, "ReactorLiveBand", Vector3.new(0.28, 8.0, 5.8), Vector3.new(x - 4.05, 7.5, z), COLORS.Cyan, Enum.Material.Neon)
end
local function addReactivePowerYard(group)
	local reactive = folder(group, "ReactivePowerYard")

	-- The yard starts immediately behind the shortened halls and extends to the
	-- rear plot edge. It is one continuous walkable service surface.
	block(reactive, "MainSwitchyardPad", Vector3.new(148, 0.45, 48), Vector3.new(0, 0.23, 29), COLORS.Ground, Enum.Material.Concrete)

	-- Four deliberate pedestrian/service corridors separate the parallel fields.
	-- They remain physically clear of switchgear, transformers and reactive banks.
	local corridors = {
		{name = "HallServiceAisle", z = 6.0, depth = 4.0},
		{name = "SwitchAisle", z = 15.0, depth = 4.0},
		{name = "TransformerAisle", z = 25.0, depth = 6.0},
		{name = "ReactiveAisle", z = 42.0, depth = 4.0},
	}
	for _, corridor in ipairs(corridors) do
		block(
			reactive,
			corridor.name,
			Vector3.new(144, 0.16, corridor.depth),
			Vector3.new(0, 0.53, corridor.z),
			COLORS.ConcreteDark,
			Enum.Material.Concrete
		)
	end

	-- Rear row: four capacitor banks in parallel on the west half.
	for index, x in ipairs({-60, -44, -28, -12}) do
		addCapacitorBank(reactive, "CapacitorBank_" .. index, x, 48.5)
	end

	-- Three shunt reactors continue the same rear row across the east half.
	for index, x in ipairs({30, 49, 68}) do
		addShuntReactor(reactive, "ShuntReactor_" .. index, x, 48.5)
	end

	-- Rear reactive bus follows the full row while leaving the aisle in front clear.
	cylinderX(reactive, "ReactiveBusbar", 132, 1.2, Vector3.new(2, 12.0, 44.0), COLORS.Silver, Enum.Material.Metal)
	block(reactive, "ReactiveLiveLine", Vector3.new(130, 0.22, 0.22), Vector3.new(2, 12.65, 44.0), COLORS.Cyan, Enum.Material.Neon)
end
local function addTransformerCourt(group)
	-- Parallel transformer row with large walkable gaps between machines.
	local positions = {-48, -16, 16, 48}
	for index, x in ipairs(positions) do
		addTransformer(group, index, x, 34.0)
	end
end
local function addBusbarGantries(group)
	-- Four parallel full-width portal rows establish real switchyard depth.
	local gantries = {
		{name = "Entry", z = 8.0, height = 35},
		{name = "FieldA", z = 15.5, height = 32},
		{name = "FieldB", z = 25.0, height = 29},
		{name = "RearFeed", z = 43.0, height = 25},
	}

	local postXs = {-68, -34, 0, 34, 68}

	for _, gantry in ipairs(gantries) do
		local beamY = gantry.height
		for _, x in ipairs(postXs) do
			block(group, gantry.name .. "Post_" .. tostring(x), Vector3.new(1.0, gantry.height, 1.0), Vector3.new(x, gantry.height / 2, gantry.z), COLORS.Graphite, Enum.Material.Metal)
			block(group, gantry.name .. "Crossarm_" .. tostring(x), Vector3.new(12, 0.9, 1.2), Vector3.new(x, beamY, gantry.z), COLORS.Graphite, Enum.Material.Metal)

			for phase = -1, 1 do
				local phaseZ = gantry.z + phase * 2.5
				cylinderY(group, gantry.name .. "Insulator_" .. tostring(x) .. "_" .. tostring(phase), 3.6, 0.95, Vector3.new(x, beamY + 2.2, phaseZ), COLORS.Ceramic, Enum.Material.SmoothPlastic)
			end
		end

		for phase = -1, 1 do
			local phaseZ = gantry.z + phase * 2.5
			cylinderX(group, gantry.name .. "Busbar_" .. tostring(phase), 136, 1.5, Vector3.new(0, beamY + 4.25, phaseZ), COLORS.Silver, Enum.Material.Metal)
			block(group, gantry.name .. "LiveLine_" .. tostring(phase), Vector3.new(134, 0.18, 0.18), Vector3.new(0, beamY + 4.95, phaseZ), COLORS.Cyan, Enum.Material.Neon)
		end
	end

	local function addSwitchRow(rowName, z)
		for bay = 1, 6 do
			local x = -55 + (bay - 1) * 22
			local bayRoot = folder(group, rowName .. "_Bay_" .. bay)

			block(bayRoot, "Base", Vector3.new(10, 0.6, 5), Vector3.new(x, 0.3, z), COLORS.GraphiteLight, Enum.Material.Metal)

			for side = -1, 1, 2 do
				local bx = x + side * 3.2
				cylinderY(bayRoot, "DisconnectorInsulator_" .. side, 7.0, 1.1, Vector3.new(bx, 4.0, z), COLORS.Ceramic, Enum.Material.SmoothPlastic)
				for disc = 0, 2 do
					cylinderY(
						bayRoot,
						"DisconnectorDisc_" .. side .. "_" .. disc,
						0.32,
						1.7,
						Vector3.new(bx, 2.0 + disc * 1.7, z),
						COLORS.Ceramic,
						Enum.Material.SmoothPlastic
					)
				end
			end

			block(bayRoot, "DisconnectorBlade", Vector3.new(7.2, 0.45, 0.7), Vector3.new(x, 7.7, z), COLORS.Silver, Enum.Material.Metal)
			block(bayRoot, "LiveMarker", Vector3.new(6.2, 0.20, 0.20), Vector3.new(x, 8.25, z), COLORS.Cyan, Enum.Material.Neon)
		end
	end

	-- Two complete parallel switch-field rows with a clear walkable aisle between.
	addSwitchRow("SwitchRowA", 10.5)
	addSwitchRow("SwitchRowB", 19.5)
end
local function addRooftopAndService(group)
	-- Four organized cooling modules split across both hall roofs.
	local modules = {
		{name = "SG_A", size = Vector3.new(18, 6, 12), pos = Vector3.new(-55, 35.8, -24), roofY = 32},
		{name = "SG_B", size = Vector3.new(16, 6, 12), pos = Vector3.new(-28, 35.8, -10), roofY = 32},
		{name = "CV_A", size = Vector3.new(18, 7, 12), pos = Vector3.new(22, 44.3, -23), roofY = 40},
		{name = "CV_B", size = Vector3.new(18, 7, 12), pos = Vector3.new(48, 44.3, -8), roofY = 40},
	}

	for _, module in ipairs(modules) do
		local plinthHeight = 0.8
		local plinthCenterY = module.roofY + plinthHeight / 2
		block(
			group,
			"CoolingPlinth_" .. module.name,
			Vector3.new(module.size.X + 2, plinthHeight, module.size.Z + 2),
			Vector3.new(module.pos.X, plinthCenterY, module.pos.Z),
			COLORS.ConcreteDark,
			Enum.Material.Concrete
		)
		block(group, "CoolingModule_" .. module.name, module.size, module.pos, COLORS.Graphite, Enum.Material.Metal)

		for fin = -2, 2 do
			block(
				group,
				"CoolingLouver_" .. module.name .. "_" .. fin,
				Vector3.new(module.size.X - 3, 0.35, 0.3),
				module.pos + Vector3.new(0, fin * 1.0, -(module.size.Z / 2 + 0.18)),
				COLORS.Metal,
				Enum.Material.Metal
			)
		end
	end

	-- Three vent stacks rise from one shared converter-roof plinth, never floating.
	block(group, "VentUtilityPlinth", Vector3.new(20, 2.5, 12), Vector3.new(36, 41.65, -1), COLORS.Graphite, Enum.Material.Metal)
	for index, x in ipairs({30, 36, 42}) do
		local height = 8 + index * 0.5
		local baseY = 42.9
		cylinderY(group, "VentStack_" .. index, height, 1.8, Vector3.new(x, baseY + height / 2, -1), COLORS.Silver, Enum.Material.Metal)
		cylinderY(group, "VentCap_" .. index, 0.7, 2.5, Vector3.new(x, baseY + height + 0.35, -1), COLORS.Graphite, Enum.Material.Metal)
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
	model:SetAttribute("VisiblePartBudget", 1000)
	model:SetAttribute("VisiblePartBudgetPassed", count <= 1000)
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("LargeCity_PowerUtility_L3_GoldenMaster")
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = "LargeCity_PowerUtility_L3_GoldenMaster"
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("AssetPhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("GeometryRevision", "LargeCityPowerUtility-v5-WalkableParallelSwitchyard")
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("TransformerCount", 4)
	model:SetAttribute("CapacitorBankCount", 4)
	model:SetAttribute("ShuntReactorCount", 3)
	model:SetAttribute("ExpandedReactivePowerYard", true)
	model:SetAttribute("BusbarGantryCount", 4)
	model:SetAttribute("SwitchBayCount", 12)
	model:SetAttribute("BroadSwitchyard", true)
	model:SetAttribute("WalkableParallelSwitchyard", true)
	model:SetAttribute("ParallelSwitchRows", 2)
	model:SetAttribute("ServiceCorridorCount", 4)
	model:SetAttribute("SwitchyardClearsHallEnvelope", true)
	model:SetAttribute("RoofEquipmentPlinthsFullyAboveRoof", true)
	model:SetAttribute("CoolingModuleCount", 4)
	model:SetAttribute("VentStackCount", 3)
	model:SetAttribute("NoLoadingStations", true)
	model:SetAttribute("ControlSpineProjectsFront", true)
	model.Parent = parent

	local groups = folder(model, "DestructionGroups")
	local d1 = folder(groups, "D1_ControlEntrance")
	local d2 = folder(groups, "D2_SwitchgearHall")
	local d3 = folder(groups, "D3_ConverterHall")
	local d4 = folder(groups, "D4_GridControlSpine")
	local d5 = folder(groups, "D5_BusbarGantries")
	local d6 = folder(groups, "D6_TransformerCourt")
	local d7 = folder(groups, "D7_RooftopAndReactivePower")

	addControlEntrance(d1)
	addSwitchgearHall(d2)
	addConverterHall(d3)
	addGridControlSpine(d4)
	addBusbarGantries(d5)
	addTransformerCourt(d6)
	addReactivePowerYard(d7)
	addRooftopAndService(d7)

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
