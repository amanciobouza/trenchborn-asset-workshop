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
	block(group, "SwitchgearHallMass", Vector3.new(68, 32, 72), Vector3.new(-38, 16, -5), COLORS.Concrete, Enum.Material.Concrete)

	-- Dark lower service band.
	block(group, "SwitchgearLowerFront", Vector3.new(64, 7.5, 0.8), Vector3.new(-38, 4.0, -41.45), COLORS.Graphite, Enum.Material.Metal)
	block(group, "SwitchgearLowerRear", Vector3.new(64, 7.5, 0.8), Vector3.new(-38, 4.0, 31.45), COLORS.Graphite, Enum.Material.Metal)

	-- Deep vertical fins create the switchgear rhythm from ground to roof.
	for bay = 0, 8 do
		local x = -68 + bay * 7.5
		block(group, "SwitchgearFinFront_" .. bay, Vector3.new(1.0, 30, 2.2), Vector3.new(x, 16, -42.4), COLORS.GraphiteLight, Enum.Material.Metal)
		block(group, "SwitchgearFinRear_" .. bay, Vector3.new(1.0, 30, 2.2), Vector3.new(x, 16, 32.4), COLORS.GraphiteLight, Enum.Material.Metal)
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
	block(group, "ConverterHallMass", Vector3.new(62, 40, 70), Vector3.new(34, 20, -3), COLORS.Concrete, Enum.Material.Concrete)

	block(group, "ConverterLowerFront", Vector3.new(58, 8.0, 0.8), Vector3.new(34, 4.2, -38.45), COLORS.Graphite, Enum.Material.Metal)
	block(group, "ConverterLowerRear", Vector3.new(58, 8.0, 0.8), Vector3.new(34, 4.2, 32.45), COLORS.Graphite, Enum.Material.Metal)

	-- Seven vertical converter bays line up consistently from bottom to top.
	for bay = 0, 7 do
		local x = 7 + bay * 7.7
		block(group, "ConverterFinFront_" .. bay, Vector3.new(0.9, 38, 1.8), Vector3.new(x, 20, -39.25), COLORS.GraphiteLight, Enum.Material.Metal)
		block(group, "ConverterFinRear_" .. bay, Vector3.new(0.9, 38, 1.8), Vector3.new(x, 20, 33.25), COLORS.GraphiteLight, Enum.Material.Metal)
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

local function addTransformer(group, index, x)
	local root = folder(group, "Transformer_" .. index)
	local bodyCenter = Vector3.new(x, 9.0, 43)

	block(root, "Body", Vector3.new(16, 18, 12), bodyCenter, COLORS.GraphiteLight, Enum.Material.Metal)
	block(root, "TopCap", Vector3.new(17, 1.2, 13), Vector3.new(x, 18.6, 43), COLORS.Metal, Enum.Material.Metal)
	block(root, "Base", Vector3.new(18, 1.0, 14), Vector3.new(x, 0.5, 43), COLORS.Graphite, Enum.Material.Metal)

	-- Cooling fins on both long sides.
	for fin = -3, 3 do
		local z = 43 + fin * 1.45
		block(root, "CoolingFinL_" .. tostring(fin), Vector3.new(2.0, 13, 0.45), Vector3.new(x - 9.0, 8.5, z), COLORS.Metal, Enum.Material.Metal)
		block(root, "CoolingFinR_" .. tostring(fin), Vector3.new(2.0, 13, 0.45), Vector3.new(x + 9.0, 8.5, z), COLORS.Metal, Enum.Material.Metal)
	end

	-- Three ceramic bushings make each transformer unmistakably electrical.
	for bushing = -1, 1 do
		local bx = x + bushing * 4.2
		cylinderY(root, "BushingStem_" .. tostring(bushing), 8.0, 1.2, Vector3.new(bx, 23.0, 43), COLORS.Ceramic, Enum.Material.SmoothPlastic)
		for disc = 0, 3 do
			cylinderY(root, "BushingDisc_" .. tostring(bushing) .. "_" .. disc, 0.45, 2.2, Vector3.new(bx, 20.4 + disc * 1.6, 43), COLORS.Ceramic, Enum.Material.SmoothPlastic)
		end
		cylinderY(root, "BushingCap_" .. tostring(bushing), 0.7, 1.5, Vector3.new(bx, 27.1, 43), COLORS.Silver, Enum.Material.Metal)
	end

	-- Small amber safety stripe is physically attached to the transformer.
	block(root, "SafetyStripe", Vector3.new(11, 0.42, 0.30), Vector3.new(x, 5.5, 36.82), COLORS.Amber, Enum.Material.Neon)
end

local function addTransformerCourt(group)
	-- Four large units stay clear of doors and unrelated service clutter.
	block(group, "TransformerCourtPad", Vector3.new(88, 0.5, 20), Vector3.new(22, 0.25, 43), COLORS.Ground, Enum.Material.Concrete)

	local positions = {-8, 12, 32, 52}
	for index, x in ipairs(positions) do
		addTransformer(group, index, x)
	end
end

local function addBusbarGantries(group)
	local gantries = {
		{name = "Primary", z = 33.5, height = 31},
		{name = "Secondary", z = 39.0, height = 25},
	}

	for _, gantry in ipairs(gantries) do
		local beamY = gantry.height
		for _, x in ipairs({-8, 24, 56}) do
			block(group, gantry.name .. "Post_" .. tostring(x), Vector3.new(0.9, gantry.height, 0.9), Vector3.new(x, gantry.height / 2, gantry.z), COLORS.Graphite, Enum.Material.Metal)
			block(group, gantry.name .. "Crossarm_" .. tostring(x), Vector3.new(9, 0.8, 1.1), Vector3.new(x, beamY, gantry.z), COLORS.Graphite, Enum.Material.Metal)

			for phase = -1, 1 do
				local phaseZ = gantry.z + phase * 2.4
				cylinderY(group, gantry.name .. "Insulator_" .. tostring(x) .. "_" .. tostring(phase), 3.4, 0.9, Vector3.new(x, beamY + 2.1, phaseZ), COLORS.Ceramic, Enum.Material.SmoothPlastic)
			end
		end

		for phase = -1, 1 do
			local phaseZ = gantry.z + phase * 2.4
			cylinderX(group, gantry.name .. "Busbar_" .. tostring(phase), 64, 1.4, Vector3.new(24, beamY + 4.1, phaseZ), COLORS.Silver, Enum.Material.Metal)
		end
	end
end

local function addRooftopAndService(group)
	-- Four organized cooling modules split across both hall roofs.
	local modules = {
		{name = "SG_A", size = Vector3.new(18, 6, 12), pos = Vector3.new(-55, 35.0, -13)},
		{name = "SG_B", size = Vector3.new(16, 6, 12), pos = Vector3.new(-28, 35.0, 8)},
		{name = "CV_A", size = Vector3.new(18, 7, 12), pos = Vector3.new(22, 43.5, -11)},
		{name = "CV_B", size = Vector3.new(18, 7, 12), pos = Vector3.new(48, 43.5, 8)},
	}

	for _, module in ipairs(modules) do
		block(group, "CoolingPlinth_" .. module.name, Vector3.new(module.size.X + 2, 0.6, module.size.Z + 2), Vector3.new(module.pos.X, module.pos.Y - module.size.Y / 2 - 0.3, module.pos.Z), COLORS.ConcreteDark, Enum.Material.Concrete)
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
	block(group, "VentUtilityPlinth", Vector3.new(20, 2.5, 12), Vector3.new(36, 41.25, 22), COLORS.Graphite, Enum.Material.Metal)
	for index, x in ipairs({30, 36, 42}) do
		local height = 8 + index * 0.5
		local baseY = 42.5
		cylinderY(group, "VentStack_" .. index, height, 1.8, Vector3.new(x, baseY + height / 2, 22), COLORS.Silver, Enum.Material.Metal)
		cylinderY(group, "VentCap_" .. index, 0.7, 2.5, Vector3.new(x, baseY + height + 0.35, 22), COLORS.Graphite, Enum.Material.Metal)
	end

	-- Small rear electrical-service screen, not a loading station.
	block(group, "RearServiceScreen", Vector3.new(2.0, 10, 18), Vector3.new(66.0, 5, 22), COLORS.Graphite, Enum.Material.Metal)
	block(group, "RearServiceCyanEdge", Vector3.new(0.28, 7.5, 14), Vector3.new(64.85, 5, 22), COLORS.Cyan, Enum.Material.Neon)
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
	local existing = parent:FindFirstChild("LargeCity_PowerUtility_L3_GoldenMaster")
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = "LargeCity_PowerUtility_L3_GoldenMaster"
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("AssetPhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("GeometryRevision", "LargeCityPowerUtility-v1-AurelineGridworks")
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("TransformerCount", 4)
	model:SetAttribute("BusbarGantryCount", 2)
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
	local d7 = folder(groups, "D7_RooftopAndService")

	addControlEntrance(d1)
	addSwitchgearHall(d2)
	addConverterHall(d3)
	addGridControlSpine(d4)
	addBusbarGantries(d5)
	addTransformerCourt(d6)
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
