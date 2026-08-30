local Builder = {}

local COLORS = {
	Chassis = Color3.fromRGB(28, 35, 32),
	Body = Color3.fromRGB(91, 103, 92),
	Armor = Color3.fromRGB(171, 178, 151),
	Accent = Color3.fromRGB(92, 231, 151),
	DarkMetal = Color3.fromRGB(45, 49, 47),
	Hazard = Color3.fromRGB(207, 177, 74),
}

local function part(parent, name, size, cf, color, material, shape)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cf
	item.Color = color or COLORS.Body
	item.Material = material or Enum.Material.Metal
	item.Shape = shape or Enum.PartType.Block
	item.Anchored = true
	item.CanCollide = false
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function block(parent, name, size, position, color, rotation)
	local cf = CFrame.new(position)
	if rotation then
		cf *= CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
	end
	return part(parent, name, size, cf, color)
end

local function cylinder(parent, name, size, position, color, rotation)
	return part(
		parent,
		name,
		size,
		CFrame.new(position) * CFrame.Angles(
			math.rad(rotation and rotation.X or 0),
			math.rad(rotation and rotation.Y or 0),
			math.rad(rotation and rotation.Z or 0)
		),
		color,
		Enum.Material.Metal,
		Enum.PartType.Cylinder
	)
end

local function neon(parent, name, size, cf)
	return part(parent, name, size, cf, COLORS.Accent, Enum.Material.Neon)
end

local function folder(parent, name)
	local value = Instance.new("Folder")
	value.Name = name
	value.Parent = parent
	return value
end

local function addJointDisc(parent, side, center)
	cylinder(parent, side .. "ShoulderBearingDrum", Vector3.new(3.2, 4.4, 4.4), center, COLORS.DarkMetal)
	cylinder(parent, side .. "ShoulderAxle", Vector3.new(3.5, 2.8, 2.8), center, COLORS.Chassis)
end

local function addLeg(rig, armor, side, sign)
	local hipX = sign * 3.75
	local thighX = sign * 4.05
	local kneeX = sign * 4.45
	local shinX = sign * 4.8
	local footX = sign * 5.15
	local legLean = sign * 6
	cylinder(rig, side .. "HipBearing", Vector3.new(2.4, 3.3, 3.3), Vector3.new(hipX, 19.8, 0), COLORS.Chassis)
	block(rig, side .. "UpperLeg", Vector3.new(4.2, 7.2, 4.1), Vector3.new(thighX, 16.1, 0), COLORS.Chassis, Vector3.new(0, 0, legLean))
	block(armor, side .. "ThighPlate", Vector3.new(4.55, 4.9, 4.45), Vector3.new(thighX, 16.85, -0.15), COLORS.Body, Vector3.new(0, -sign * 2, legLean))
	cylinder(rig, side .. "KneeBearing", Vector3.new(2.1, 3.7, 3.7), Vector3.new(kneeX, 11.9, 0), COLORS.DarkMetal)
	block(armor, side .. "KneeGuard", Vector3.new(4.1, 2.6, 4.7), Vector3.new(kneeX, 11.9, -0.55), COLORS.Armor, Vector3.new(0, 0, legLean))
	cylinder(armor, side .. "KneeJointCover", Vector3.new(0.7, 3.15, 3.15), Vector3.new(kneeX, 11.9, -3.2), COLORS.DarkMetal, Vector3.new(0, 90, 0))
	cylinder(armor, side .. "KneeJointHub", Vector3.new(0.5, 1.95, 1.95), Vector3.new(kneeX, 11.9, -3.72), COLORS.Body, Vector3.new(0, 90, 0))
	block(rig, side .. "LowerLeg", Vector3.new(3.5, 7.1, 3.4), Vector3.new(shinX, 7.8, 0.4), COLORS.Chassis, Vector3.new(0, 0, legLean))
	block(armor, side .. "ShinPlate", Vector3.new(4.55, 6.0, 4.3), Vector3.new(shinX, 7.65, -0.15), COLORS.Body, Vector3.new(0, -sign * 2, legLean))
	block(rig, side .. "Ankle", Vector3.new(3.3, 1.7, 3.0), Vector3.new(footX, 3.75, 0.45), COLORS.Chassis)
	block(armor, side .. "FootHeel", Vector3.new(5.1, 2.1, 3.0), Vector3.new(footX, 1.65, 1.1), COLORS.DarkMetal)
	block(armor, side .. "FootMain", Vector3.new(5.4, 2.4, 5.7), Vector3.new(footX, 1.8, -0.65), COLORS.Armor, Vector3.new(0, -sign * 4, 0))
	block(armor, side .. "ToeOuter", Vector3.new(2.35, 1.8, 2.5), Vector3.new(footX + sign * 1.35, 1.25, -3.2), COLORS.DarkMetal, Vector3.new(0, -sign * 4, 0))
	block(armor, side .. "ToeInner", Vector3.new(2.35, 1.8, 2.5), Vector3.new(footX - sign * 1.35, 1.25, -3.2), COLORS.DarkMetal, Vector3.new(0, -sign * 4, 0))
	block(rig, side .. "RearHydraulic", Vector3.new(0.7, 5.4, 0.7), Vector3.new(shinX, 8.0, 2.2), COLORS.DarkMetal, Vector3.new(-6, 0, legLean))
end

local function addHand(rig, side, sign)
	local hand = folder(rig, side .. "Hand")
	local x = sign < 0 and -10.5 or 9.2
	block(hand, "Palm", Vector3.new(2.6, 2.4, 2.8), Vector3.new(x, 17.1, 0), COLORS.Chassis)
	for index = 1, 4 do
		block(
			hand,
			"Finger" .. index,
			Vector3.new(0.48, 1.7, 0.58),
			Vector3.new(x + (index - 2.5) * 0.58, 15.45, -0.35),
			COLORS.DarkMetal
		)
	end
	block(hand, "Thumb", Vector3.new(0.65, 1.65, 0.7), Vector3.new(x - sign * 1.5, 16.4, -0.25), COLORS.DarkMetal, Vector3.new(0, 0, sign * 28))
end

local function addArm(rig, armor, side, sign)
	local x = sign * 8.0
	local armLean = sign * 5
	local shoulderTilt = -sign * 12
	addJointDisc(rig, side, Vector3.new(x, 30.4, 0))
	block(armor, side .. "ShoulderCap", Vector3.new(4.4, 3.9, 5.0), Vector3.new(sign * 10.9, 30.3, 0.25), COLORS.Armor, Vector3.new(0, -sign * 3, shoulderTilt))
	block(armor, side .. "ShoulderCrown", Vector3.new(4.8, 1.25, 4.55), Vector3.new(sign * 9.15, 32.15, 0.15), COLORS.Body, Vector3.new(0, -sign * 3, shoulderTilt))
	block(rig, side .. "ShoulderYoke", Vector3.new(3.0, 2.4, 3.15), Vector3.new(sign * 8.45, 28.55, 0), COLORS.Chassis, Vector3.new(0, 0, armLean))
	cylinder(armor, side .. "ShoulderJointCover", Vector3.new(1.3, 3.75, 3.75), Vector3.new(sign * 7.35, 30.4, -3.18), COLORS.DarkMetal, Vector3.new(0, 90, 0))
	cylinder(armor, side .. "ShoulderJointHub", Vector3.new(0.8, 2.35, 2.35), Vector3.new(sign * 7.35, 30.4, -4.18), COLORS.Body, Vector3.new(0, 90, 0))
	block(rig, side .. "UpperArm", Vector3.new(3.1, 6.2, 3.1), Vector3.new(sign * 8.65, 26.2, 0), COLORS.Chassis, Vector3.new(0, 0, armLean))
	block(armor, side .. "UpperArmPlate", Vector3.new(3.7, 4.8, 3.7), Vector3.new(sign * 8.65, 26.5, -0.15), COLORS.Body, Vector3.new(0, 0, armLean))
	cylinder(rig, side .. "ElbowBearing", Vector3.new(1.9, 3.1, 3.1), Vector3.new(sign * 9.05, 22.3, 0), COLORS.DarkMetal)
	block(rig, side .. "Forearm", Vector3.new(3.4, 6.0, 3.3), Vector3.new(sign * 9.25, 19.4, 0), COLORS.Chassis, Vector3.new(0, 0, armLean))
	block(armor, side .. "ForearmPlate", Vector3.new(4.1, 5.5, 4.0), Vector3.new(sign * 9.25, 19.8, -0.15), COLORS.Body, Vector3.new(0, 0, armLean))
	addHand(rig, side, sign)
end

local function addBaton(equipment)
	local baton = Instance.new("Model")
	baton.Name = "ShockBaton"
	baton:SetAttribute("EquipmentType", "BluntControlWeapon")
	baton.Parent = equipment

	local batonX = -12.05
	local handle = cylinder(baton, "Grip", Vector3.new(5.0, 1.1, 1.1), Vector3.new(batonX, 13.4, 0), COLORS.DarkMetal, Vector3.new(0, 0, 90))
	block(baton, "HandGuard", Vector3.new(2.5, 0.65, 1.7), Vector3.new(batonX, 15.8, 0), COLORS.Armor)
	cylinder(baton, "Shaft", Vector3.new(7.5, 1.35, 1.35), Vector3.new(batonX, 20.0, 0), COLORS.Chassis, Vector3.new(0, 0, 90))
	cylinder(baton, "StrikeHead", Vector3.new(2.5, 2.0, 2.0), Vector3.new(batonX, 24.8, 0), COLORS.DarkMetal, Vector3.new(0, 0, 90))
	for index = 1, 3 do
		local y = 23.6 + index * 0.6
		neon(baton, "Contact" .. index, Vector3.new(0.18, 2.15, 2.15), CFrame.new(batonX, y, 0) * CFrame.Angles(0, 0, math.rad(90)))
	end
	baton.PrimaryPart = handle
	return baton
end

local function addSearchlight(systems)
	local scanner = Instance.new("Model")
	scanner.Name = "SearchlightScanner"
	scanner:SetAttribute("Purpose", "DetectionOnly")
	scanner.Parent = systems

	block(scanner, "ShoulderMount", Vector3.new(2.3, 0.75, 2.4), Vector3.new(-6.5, 33.55, 0.25), COLORS.Chassis, Vector3.new(0, 0, -6))
	cylinder(scanner, "YawBase", Vector3.new(0.8, 1.8, 1.8), Vector3.new(-6.45, 34.05, 0), COLORS.DarkMetal)
	local housing = cylinder(scanner, "Housing", Vector3.new(1.8, 2.5, 2.5), Vector3.new(-6.45, 34.85, -0.25), COLORS.Body, Vector3.new(0, 90, 0))
	part(scanner, "Lens", Vector3.new(0.2, 1.95, 1.95), CFrame.new(-6.45, 34.85, -1.21) * CFrame.Angles(0, math.rad(90), 0), Color3.fromRGB(213, 224, 209), Enum.Material.Glass, Enum.PartType.Cylinder)
	block(scanner, "GuardTop", Vector3.new(2.55, 0.28, 2.75), Vector3.new(-6.45, 36.12, -0.12), COLORS.DarkMetal)
	scanner.PrimaryPart = housing
end

local function addTorso(rig, armor, systems)
	block(rig, "Pelvis", Vector3.new(7.5, 4.4, 5.2), Vector3.new(0, 21.2, 0.5), COLORS.Chassis)
	block(armor, "HipPlateLeft", Vector3.new(3.6, 3.0, 5.4), Vector3.new(-3.6, 21.4, 0.0), COLORS.Body, Vector3.new(0, 0, -5))
	block(armor, "HipPlateRight", Vector3.new(3.6, 3.0, 5.4), Vector3.new(3.6, 21.4, 0.0), COLORS.Body, Vector3.new(0, 0, 5))
	block(rig, "TorsoLower", Vector3.new(7.0, 4.4, 5.2), Vector3.new(0, 24.6, 0.35), COLORS.Chassis)
	block(rig, "TorsoUpper", Vector3.new(11.0, 8.5, 6.1), Vector3.new(0, 29.2, 0), COLORS.Chassis)
	block(armor, "ChestCore", Vector3.new(6.2, 6.65, 1.3), Vector3.new(0, 29.75, -3.72), COLORS.Body)
	block(armor, "ChestSlopeLeft", Vector3.new(3.75, 6.4, 1.35), Vector3.new(-3.55, 30.0, -3.35), COLORS.Body, Vector3.new(0, 7, 14))
	block(armor, "ChestSlopeRight", Vector3.new(3.75, 6.4, 1.35), Vector3.new(3.55, 30.0, -3.35), COLORS.Body, Vector3.new(0, -7, -14))
	block(armor, "ChestWingLeft", Vector3.new(3.85, 5.5, 1.5), Vector3.new(-5.55, 30.55, -2.72), COLORS.Armor, Vector3.new(0, 9, 13))
	block(armor, "ChestWingRight", Vector3.new(3.85, 5.5, 1.5), Vector3.new(5.55, 30.55, -2.72), COLORS.Armor, Vector3.new(0, -9, -13))
	block(armor, "WaistGuardLeft", Vector3.new(2.7, 4.2, 1.55), Vector3.new(-3.65, 25.8, -3.0), COLORS.Body, Vector3.new(0, 0, -12))
	block(armor, "WaistGuardRight", Vector3.new(2.7, 4.2, 1.55), Vector3.new(3.65, 25.8, -3.0), COLORS.Body, Vector3.new(0, 0, 12))
	block(armor, "AbdomenPlate", Vector3.new(4.5, 2.5, 1.0), Vector3.new(0, 25.45, -3.35), COLORS.DarkMetal)

	local core = folder(systems, "ChestPulseCore")
	neon(core, "ShieldAngleLeft", Vector3.new(0.5, 4.15, 0.28), CFrame.new(-0.95, 29.55, -4.78) * CFrame.Angles(0, 0, math.rad(25)))
	neon(core, "ShieldAngleRight", Vector3.new(0.5, 4.15, 0.28), CFrame.new(0.95, 29.55, -4.78) * CFrame.Angles(0, 0, math.rad(-25)))
	core:SetAttribute("System", "WarningPulse")

	block(rig, "NeckGimbal", Vector3.new(4.4, 1.1, 3.35), Vector3.new(0, 33.85, -0.05), COLORS.Chassis)
	block(rig, "SensorHead", Vector3.new(4.9, 1.85, 3.25), Vector3.new(0, 34.55, -0.65), COLORS.DarkMetal)
	block(armor, "HeadBrow", Vector3.new(5.15, 0.38, 3.45), Vector3.new(0, 35.52, -0.58), COLORS.Armor)
	part(systems, "VisorSensor", Vector3.new(3.6, 0.38, 0.22), CFrame.new(0, 34.58, -2.39), COLORS.Accent, Enum.Material.Neon)
end

local function addBackpack(systems)
	local backpack = folder(systems, "BackpackCore")
	block(backpack, "CoreBlock", Vector3.new(8.2, 6.4, 2.3), Vector3.new(0, 29.3, 4.0), COLORS.Chassis)
	for _, sign in ipairs({-1, 1}) do
		local side = sign < 0 and "Left" or "Right"
		cylinder(backpack, "CoolingFan" .. side, Vector3.new(0.55, 2.7, 2.7), Vector3.new(sign * 2.3, 30.2, 5.25), COLORS.DarkMetal, Vector3.new(0, 90, 0))
		block(backpack, "BackHardpoint" .. side, Vector3.new(1.4, 1.4, 0.7), Vector3.new(sign * 3.35, 27.15, 5.4), COLORS.Armor)
	end
end

local function addHardpoints(systems)
	for _, data in ipairs({
		{"ShoulderHardpointLeft", Vector3.new(-6.0, 33.2, 0)},
		{"ShoulderHardpointRight", Vector3.new(6.0, 33.2, 0)},
		{"ForearmHardpointLeft", Vector3.new(-10.86, 20.0, -0.2)},
		{"ForearmHardpointRight", Vector3.new(10.86, 20.0, -0.2)},
	}) do
		local item = block(systems, data[1], Vector3.new(0.55, 1.8, 2.2), data[2], COLORS.Hazard)
		item:SetAttribute("FleetUpgradeMount", true)
	end
end

local function addHitboxes(parent)
	local hitboxes = folder(parent, "Hitboxes")
	local definitions = {
		{"HeadHitbox", Vector3.new(6, 4, 5), Vector3.new(0, 35, 0)},
		{"TorsoHitbox", Vector3.new(15, 13, 8), Vector3.new(0, 28, 0)},
		{"LeftArmHitbox", Vector3.new(6, 18, 6), Vector3.new(-8.5, 24, 0)},
		{"RightArmHitbox", Vector3.new(6, 18, 6), Vector3.new(8.5, 24, 0)},
		{"LeftLegHitbox", Vector3.new(6, 20, 7), Vector3.new(-4.1, 11, 0)},
		{"RightLegHitbox", Vector3.new(6, 20, 7), Vector3.new(4.1, 11, 0)},
	}
	for _, definition in ipairs(definitions) do
		local item = block(hitboxes, definition[1], definition[2], definition[3], Color3.new(1, 0, 0))
		item.Transparency = 1
		item.CanQuery = false
	end
	return hitboxes
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("Warden_I_Shepherd_GoldenMaster")
	if existing then
		existing:Destroy()
	end

	local model = Instance.new("Model")
	model.Name = "Warden_I_Shepherd_GoldenMaster"
	model:SetAttribute("AssetName", "Warden-I Shepherd")
	model:SetAttribute("AssetClass", "Guardian Defense Platform")
	model:SetAttribute("PipelinePhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("GeometryOnly", true)
	model:SetAttribute("NoCoplanarOverlappingFaces", true)
	model:SetAttribute("AvoidOrthogonalBoxSilhouette", true)
	model:SetAttribute("GoldenMasterIteration", 13)
	model.Parent = parent

	local rig = folder(model, "Rig")
	local armor = folder(model, "Armor")
	local systems = folder(model, "Systems")
	local equipment = folder(model, "Equipment")
	local metadata = folder(model, "Metadata")
	metadata:SetAttribute("TargetHeightStuds", 42)
	metadata:SetAttribute("FleetBaseChassis", true)

	addLeg(rig, armor, "Left", -1)
	addLeg(rig, armor, "Right", 1)
	addTorso(rig, armor, systems)
	addArm(rig, armor, "Left", -1)
	addArm(rig, armor, "Right", 1)
	addBackpack(systems)
	addHardpoints(systems)
	addSearchlight(systems)
	addBaton(equipment)
	addHitboxes(model)

	local root = block(rig, "Root", Vector3.new(2, 2, 2), Vector3.new(0, 21, 0), COLORS.Chassis)
	root.Transparency = 1
	root.CanQuery = false
	model.PrimaryPart = root

	return model
end

return Builder
