local aegisBuilder = require(script.Parent:WaitForChild("AegisInterceptorGoldenMaster"))
local specification = require(script.Parent:WaitForChild("SovereignApexSpecification"))

local Builder = {}
local COLORS = specification.Palette

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

local function block(parent, name, size, cf, color)
	return part(parent, name, size, cf, color)
end

local function cylinder(parent, name, size, cf, color)
	return part(parent, name, size, cf, color, Enum.Material.Metal, Enum.PartType.Cylinder)
end

local function folder(parent, name)
	local item = Instance.new("Folder")
	item.Name = name
	item.Parent = parent
	return item
end

local function modelFolder(parent, name)
	local item = Instance.new("Model")
	item.Name = name
	item.Parent = parent
	return item
end

local function removeAegisEquipment(model)
	for _, name in ipairs({
		"LeftIonCannon",
		"RightIonCannon",
		"LeftShoulderMissilePod",
		"RightShoulderMissilePod",
		"DirectionalAegis",
		"ChestPulseCore",
	}) do
		local item = model:FindFirstChild(name, true)
		if item then item:Destroy() end
	end
	for _, name in ipairs({
		"LeftMissilePodHitbox",
		"RightMissilePodHitbox",
		"AegisProjectorHitbox",
	}) do
		local item = model:FindFirstChild(name, true)
		if item then item:Destroy() end
	end
end

local function recolorFleet(model)
	local aegis = {
		{Color3.fromRGB(22, 28, 34), COLORS.Chassis},
		{Color3.fromRGB(43, 66, 112), COLORS.Body},
		{Color3.fromRGB(174, 185, 196), COLORS.Armor},
		{Color3.fromRGB(62, 218, 255), COLORS.Accent},
		{Color3.fromRGB(29, 35, 42), COLORS.DarkMetal},
		{Color3.fromRGB(235, 144, 48), COLORS.ChargeHot},
	}
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			for _, mapping in ipairs(aegis) do
				local source = mapping[1]
				local delta = Vector3.new(item.Color.R - source.R, item.Color.G - source.G, item.Color.B - source.B)
				if delta.Magnitude < 0.04 then
					item.Color = mapping[2]
					break
				end
			end
		end
	end
end

local function rebuildFleetHead(model, armor, systems)
	local head = model:FindFirstChild("SensorHead", true)
	local brow = model:FindFirstChild("HeadBrow", true)
	local visor = model:FindFirstChild("VisorSensor", true)
	assert(head and brow and visor, "Missing Aegis fleet head geometry")

	local headCf = head.CFrame
	local headEnvelope = specification.Scale.HeadEnvelopeStuds
	head.Size = Vector3.new(headEnvelope.X, headEnvelope.Y, headEnvelope.Z)
	brow.Size = Vector3.new(8.0, 0.65, 5.9)
	brow.CFrame = headCf * CFrame.new(0, 2.25, 0.15) * CFrame.Angles(math.rad(-3), 0, 0)
	visor.Size = Vector3.new(6.2, 0.62, 0.3)
	visor.CFrame = headCf * CFrame.new(0, 0.15, -(head.Size.Z * 0.5 + 0.18))

	block(armor, "LeftHeadCheekGuard", Vector3.new(1.35, 2.8, 4.9), headCf * CFrame.new(-3.65, -0.55, -0.15) * CFrame.Angles(0, 0, math.rad(-6)), COLORS.Body)
	block(armor, "RightHeadCheekGuard", Vector3.new(1.35, 2.8, 4.9), headCf * CFrame.new(3.65, -0.55, -0.15) * CFrame.Angles(0, 0, math.rad(6)), COLORS.Body)
	local crown = block(armor, "HeadCrownPlate", Vector3.new(5.8, 0.65, 4.8), headCf * CFrame.new(0, 2.0, 0.15), COLORS.Armor)
	crown:SetAttribute("FleetIdentityPart", true)
	visor:SetAttribute("FleetIdentityPart", true)
	visor.Material = Enum.Material.Neon
	systems:SetAttribute("SovereignVisor", true)
end

local function rebuildFleetFeet(model)
	for _, side in ipairs({"Left", "Right"}) do
		local ankle = model:FindFirstChild(side .. "Ankle", true)
		local heel = model:FindFirstChild(side .. "FootHeel", true)
		local foot = model:FindFirstChild(side .. "FootMain", true)
		local toeOuter = model:FindFirstChild(side .. "ToeOuter", true)
		local toeInner = model:FindFirstChild(side .. "ToeInner", true)
		assert(ankle and heel and foot and toeOuter and toeInner, "Missing " .. side .. " fleet foot geometry")

		local sign = side == "Left" and -1 or 1
		local base = ankle.CFrame
		foot.Size = Vector3.new(7.6, 2.7, 7.0)
		foot.CFrame = CFrame.new(base.Position + Vector3.new(0, -2.7, -1.0)) * CFrame.Angles(0, math.rad(-sign * 2), 0)
		heel.Size = Vector3.new(7.2, 2.8, 4.1)
		heel.CFrame = CFrame.new(base.Position + Vector3.new(0, -2.75, 3.0))
		toeOuter.Size = Vector3.new(3.25, 2.15, 4.0)
		toeOuter.CFrame = CFrame.new(base.Position + Vector3.new(sign * 1.85, -3.0, -5.1))
		toeInner.Size = Vector3.new(3.25, 2.15, 4.0)
		toeInner.CFrame = CFrame.new(base.Position + Vector3.new(-sign * 1.85, -3.0, -5.1))
		for _, item in ipairs({heel, foot, toeOuter, toeInner}) do
			item:SetAttribute("FleetIdentityPart", true)
		end
	end
end

local function barBetween(parent, name, pointA, pointB, width, color)
	local midpoint = (pointA + pointB) * 0.5
	local length = (pointB - pointA).Magnitude
	local cf = CFrame.lookAt(midpoint, pointB)
	return block(parent, name, Vector3.new(width, width, length), cf, color)
end

local function addChestCore(systems, model)
	local core = modelFolder(systems, "SovereignCore")
	core:SetAttribute("System", "SovereignLockEnergySource")
	local torso = model:FindFirstChild("TorsoUpper", true)
	local chestPlate = model:FindFirstChild("ChestCore", true)
	assert(torso and torso:IsA("BasePart") and chestPlate and chestPlate:IsA("BasePart"), "Missing chest anchors for Sovereign core")
	-- The fleet chest armor sits farther forward than TorsoUpper. Anchor the V to
	-- that outer armor surface so no inherited Aegis plate can cover it.
	local front = chestPlate.CFrame * CFrame.new(0, 0, -(chestPlate.Size.Z * 0.5 + 0.3))
	local leftFrame = block(core, "ChestVFrameLeft", Vector3.new(1.8, 8.2, 0.55), front * CFrame.new(-2.15, 0.6, 0) * CFrame.Angles(0, 0, math.rad(29)), COLORS.DarkMetal)
	block(core, "ChestVFrameRight", Vector3.new(1.8, 8.2, 0.55), front * CFrame.new(2.15, 0.6, 0) * CFrame.Angles(0, 0, math.rad(-29)), COLORS.DarkMetal)
	local left = block(core, "ChestVLeft", Vector3.new(1.05, 7.5, 0.45), front * CFrame.new(-2.15, 0.6, -0.52) * CFrame.Angles(0, 0, math.rad(29)), COLORS.Accent)
	local right = block(core, "ChestVRight", Vector3.new(1.05, 7.5, 0.45), front * CFrame.new(2.15, 0.6, -0.52) * CFrame.Angles(0, 0, math.rad(-29)), COLORS.Accent)
	left.Material = Enum.Material.Neon
	right.Material = Enum.Material.Neon
	-- The lock source is a sharp energy jewel seated in the V point. Its name is
	-- stable for later gameplay code, but it must not read as a round button.
	local apex = block(core, "SovereignLockCore", Vector3.new(1.65, 1.65, 0.45), front * CFrame.new(0, -3.15, -0.7) * CFrame.Angles(0, 0, math.rad(45)), COLORS.ChargeHot)
	apex.Material = Enum.Material.Neon
	core.PrimaryPart = leftFrame
	return apex
end

local function addApexLance(equipment, model)
	local lance = modelFolder(equipment, "ApexLance")
	lance:SetAttribute("EquipmentType", "ApexLance")
	lance:SetAttribute("RigMount", "LeftLowerArm")
	lance:SetAttribute("EnergyBladeRuntimeVisible", true)

	local forearm = model:FindFirstChild("LeftForearm", true)
	assert(forearm and forearm:IsA("BasePart"), "Missing LeftForearm for Apex Lance")
	local cf = forearm.CFrame
	block(lance, "LanceForearmCradle", Vector3.new(5.8, 8.8, 5.4), cf * CFrame.new(-0.25, -0.6, -0.4), COLORS.Body)
	block(lance, "LanceOuterArmor", Vector3.new(1.25, 8.0, 5.8), cf * CFrame.new(-3.0, -0.4, -0.35), COLORS.Armor)
	block(lance, "LanceSpine", Vector3.new(2.2, 13.5, 2.5), cf * CFrame.new(-1.35, -5.0, -0.5), COLORS.Chassis)
	cylinder(lance, "LanceEmitterRing", Vector3.new(1.2, 4.4, 4.4), cf * CFrame.new(-1.35, -11.4, -0.5) * CFrame.Angles(0, 0, math.rad(90)), COLORS.DarkMetal)
	local emitter = cylinder(lance, "LanceEmitterCore", Vector3.new(0.65, 2.6, 2.6), cf * CFrame.new(-1.35, -12.1, -0.5) * CFrame.Angles(0, 0, math.rad(90)), COLORS.ChargeHot)
	emitter.Material = Enum.Material.Neon
	local blade = block(lance, "ApexEnergyBlade", Vector3.new(1.5, specification.Scale.ApexLanceEnergyBladeLengthStuds, 1.1), cf * CFrame.new(-1.35, -20.2, -0.5), COLORS.Accent)
	blade.Material = Enum.Material.Neon
	blade.Transparency = 0.12
	block(lance, "BladeEdgeLeft", Vector3.new(0.38, 14.5, 1.45), cf * CFrame.new(-2.1, -20.0, -0.5) * CFrame.Angles(0, 0, math.rad(-2)), COLORS.ChargeHot).Material = Enum.Material.Neon
	block(lance, "BladeEdgeRight", Vector3.new(0.38, 14.5, 1.45), cf * CFrame.new(-0.6, -20.0, -0.5) * CFrame.Angles(0, 0, math.rad(2)), COLORS.ChargeHot).Material = Enum.Material.Neon
	lance.PrimaryPart = lance:FindFirstChild("LanceForearmCradle")
	return lance
end

local function addDrone(parent, name, cf)
	local drone = modelFolder(parent, name)
	drone:SetAttribute("EquipmentType", "HunterDrone")
	drone:SetAttribute("DockName", name)
	drone:SetAttribute("Docked", true)
	local body = block(drone, "DroneBody", Vector3.new(5.4, 2.8, 5.8), cf, COLORS.Body)
	block(drone, "DroneCrown", Vector3.new(4.8, 1.0, 4.5), cf * CFrame.new(0, 1.65, 0.35) * CFrame.Angles(math.rad(-7), 0, 0), COLORS.Armor)
	block(drone, "DroneLeftTemple", Vector3.new(1.2, 2.5, 4.7), cf * CFrame.new(-2.55, -0.15, 0.1) * CFrame.Angles(0, 0, math.rad(-11)), COLORS.DarkMetal)
	block(drone, "DroneRightTemple", Vector3.new(1.2, 2.5, 4.7), cf * CFrame.new(2.55, -0.15, 0.1) * CFrame.Angles(0, 0, math.rad(11)), COLORS.DarkMetal)
	block(drone, "SensorRecess", Vector3.new(3.8, 1.45, 0.5), cf * CFrame.new(0, 0.15, -3.12), COLORS.Chassis)
	local leftSensor = block(drone, "LeftPredatorSensor", Vector3.new(1.7, 0.38, 0.24), cf * CFrame.new(-0.9, 0.12, -3.42) * CFrame.Angles(0, 0, math.rad(-17)), COLORS.Accent)
	local rightSensor = block(drone, "RightPredatorSensor", Vector3.new(1.7, 0.38, 0.24), cf * CFrame.new(0.9, 0.12, -3.42) * CFrame.Angles(0, 0, math.rad(17)), COLORS.Accent)
	leftSensor.Material = Enum.Material.Neon
	rightSensor.Material = Enum.Material.Neon
	block(drone, "LeftMandible", Vector3.new(0.75, 1.0, 3.4), cf * CFrame.new(-1.65, -1.15, -3.7) * CFrame.Angles(math.rad(-10), math.rad(-13), math.rad(-8)), COLORS.DarkMetal)
	block(drone, "RightMandible", Vector3.new(0.75, 1.0, 3.4), cf * CFrame.new(1.65, -1.15, -3.7) * CFrame.Angles(math.rad(-10), math.rad(13), math.rad(8)), COLORS.DarkMetal)
	drone.PrimaryPart = body
	return drone
end

local function addDroneWing(wings, torso, side, sign)
	local wing = modelFolder(wings, side .. "DroneWing")
	wing:SetAttribute("EquipmentType", "HunterDroneWing")
	wing:SetAttribute("DroneCount", 3)
	wing:SetAttribute("Formation", "RaisedMechanicalBatClaw")

	-- Keep the heavy carrier spars low and wide. Only the slim inner fingers
	-- return toward the centre axis, so the horn silhouette is formed by the
	-- two inner drones instead of by the entire support structure.
	local root = torso.CFrame:PointToWorldSpace(Vector3.new(sign * 7.0, 0.5, 4.4))
	local spineShoulder = torso.CFrame:PointToWorldSpace(Vector3.new(sign * 9.0, 3.0, 4.6))
	local hub = torso.CFrame:PointToWorldSpace(Vector3.new(sign * 11.0, 6.0, 4.9))
	-- The horn first opens outward into a broad fork, rises almost vertically,
	-- and only then hooks back toward the head.
	local innerKnuckle = torso.CFrame:PointToWorldSpace(Vector3.new(sign * 15.0, 10.5, 5.0))
	local innerCrown = torso.CFrame:PointToWorldSpace(Vector3.new(sign * 15.0, 15.5, 5.05))
	local outerKnuckle = torso.CFrame:PointToWorldSpace(Vector3.new(sign * 17.5, 9.5, 5.2))
	local lowerKnuckle = torso.CFrame:PointToWorldSpace(Vector3.new(sign * 18.5, 6.0, 5.3))
	-- Three descending tiers form one bat wing per side: horn, middle claw and
	-- an almost shoulder-level outer claw.
	local inner = torso.CFrame:PointToWorldSpace(Vector3.new(sign * 11.5, 17.5, 5.1))
	local outer = torso.CFrame:PointToWorldSpace(Vector3.new(sign * 26.0, 11.5, 5.6))
	local lower = torso.CFrame:PointToWorldSpace(Vector3.new(sign * 34.0, 4.5, 5.9))

	local rootBlock = block(wing, side .. "WingRoot", Vector3.new(4.2, 6.0, 4.2), CFrame.new(root), COLORS.Chassis)
	cylinder(wing, side .. "WingRootBearing", Vector3.new(1.3, 3.8, 3.8), CFrame.new(root) * CFrame.Angles(0, math.rad(90), 0), COLORS.DarkMetal)
	barBetween(wing, side .. "VerticalRootSpar", root, spineShoulder, 1.75, COLORS.Chassis)
	cylinder(wing, side .. "SpineShoulder", Vector3.new(1.2, 3.6, 3.6), CFrame.new(spineShoulder) * CFrame.Angles(0, math.rad(90), 0), COLORS.DarkMetal)
	barBetween(wing, side .. "RaisedMainSpar", spineShoulder, hub, 1.45, COLORS.Chassis)
	cylinder(wing, side .. "ClawHub", Vector3.new(1.35, 4.1, 4.1), CFrame.new(hub) * CFrame.Angles(0, math.rad(90), 0), COLORS.DarkMetal)

	-- The inner finger uses an additional crown joint: a wide opening, vertical
	-- rise and short inward hook form the open bull-horn silhouette.
	barBetween(wing, side .. "InnerClawBase", hub, innerKnuckle, 1.05, COLORS.DarkMetal)
	cylinder(wing, side .. "InnerClawKnuckle", Vector3.new(0.95, 2.8, 2.8), CFrame.new(innerKnuckle) * CFrame.Angles(0, math.rad(90), 0), COLORS.Body)
	barBetween(wing, side .. "InnerClawRise", innerKnuckle, innerCrown, 0.78, COLORS.Chassis)
	cylinder(wing, side .. "InnerCrownJoint", Vector3.new(0.78, 2.25, 2.25), CFrame.new(innerCrown) * CFrame.Angles(0, math.rad(90), 0), COLORS.DarkMetal)
	barBetween(wing, side .. "InnerClawTip", innerCrown, inner, 0.72, COLORS.Chassis)

	-- The remaining fingers descend and widen toward the shoulder line. There
	-- are deliberately no triangular braces or closed panels between them.
	for _, finger in ipairs({
		{"Outer", outerKnuckle, outer},
		{"Lower", lowerKnuckle, lower},
	}) do
		barBetween(wing, side .. finger[1] .. "ClawBase", hub, finger[2], 1.05, COLORS.DarkMetal)
		cylinder(wing, side .. finger[1] .. "ClawKnuckle", Vector3.new(0.95, 2.8, 2.8), CFrame.new(finger[2]) * CFrame.Angles(0, math.rad(90), 0), COLORS.Body)
		barBetween(wing, side .. finger[1] .. "ClawTip", finger[2], finger[3], 0.72, COLORS.Chassis)
	end

	addDrone(wing, side .. "DroneInner", CFrame.new(inner) * CFrame.Angles(math.rad(-8), math.rad(-sign * 5), 0))
	addDrone(wing, side .. "DroneOuter", CFrame.new(outer) * CFrame.Angles(math.rad(-11), math.rad(-sign * 12), 0))
	addDrone(wing, side .. "DroneLower", CFrame.new(lower) * CFrame.Angles(math.rad(-14), math.rad(-sign * 16), 0))
	wing.PrimaryPart = rootBlock
	return {
		Inner = inner,
		Outer = outer,
		Lower = lower,
	}
end

local function addDroneWings(systems, model)
	local wings = modelFolder(systems, "HunterDroneWings")
	wings:SetAttribute("EquipmentType", "HunterDroneWings")
	wings:SetAttribute("DroneCount", 6)
	wings:SetAttribute("DronesPerSide", 3)
	wings:SetAttribute("Formation", "RaisedMechanicalBatClaws")
	local torso = model:FindFirstChild("TorsoUpper", true)
	assert(torso and torso:IsA("BasePart"), "Missing TorsoUpper for Hunter Drone wings")
	local left = addDroneWing(wings, torso, "Left", -1)
	local right = addDroneWing(wings, torso, "Right", 1)
	wings.PrimaryPart = wings:FindFirstChild("LeftWingRoot", true)
	return {Left = left, Right = right}
end

local function invisibleHitbox(parent, name, size, cf)
	local item = block(parent, name, size, cf, Color3.new(1, 0, 0))
	item.Transparency = 1
	item.CanQuery = false
	return item
end

local function addEquipmentHitboxes(model, dronePositions, lockCore)
	local hitboxes = model:FindFirstChild("Hitboxes") or folder(model, "Hitboxes")
	local lance = model:FindFirstChild("ApexLance", true)
	assert(lance and lance:IsA("Model"), "Missing ApexLance for hitbox")
	invisibleHitbox(hitboxes, "ApexLanceHitbox", Vector3.new(7, 31, 7), lance:GetPivot() * CFrame.new(-1.2, -10.0, 0))
	for side, positions in pairs(dronePositions) do
		for key, position in pairs(positions) do
			invisibleHitbox(hitboxes, side .. "Drone" .. key .. "Hitbox", Vector3.new(6, 5, 8.5), CFrame.new(position))
		end
	end
	invisibleHitbox(hitboxes, "SovereignLockCoreHitbox", Vector3.new(4, 4, 3), lockCore.CFrame)
end

local function countGeometry(model)
	local visible, hitboxes = 0, 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			if item:FindFirstAncestor("Hitboxes") then
				hitboxes += 1
			elseif item.Transparency < 1 then
				visible += 1
			end
		end
	end
	local budget = specification.PerformanceBudget
	model:SetAttribute("VisiblePartCount", visible)
	model:SetAttribute("VisiblePartBudget", budget.MaxVisibleParts)
	model:SetAttribute("GameplayHitboxCount", hitboxes)
	model:SetAttribute("GameplayHitboxBudget", budget.MaxGameplayHitboxes)
	model:SetAttribute("VisiblePartBudgetPassed", visible <= budget.MaxVisibleParts)
	model:SetAttribute("HitboxBudgetPassed", hitboxes <= budget.MaxGameplayHitboxes)
	model:SetAttribute("GeometryBudgetPassed", visible <= budget.MaxVisibleParts and hitboxes <= budget.MaxGameplayHitboxes)
end

local function validateDroneWings(model, dronePositions)
	local droneCount = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("Model") and item:GetAttribute("EquipmentType") == "HunterDrone" then
			droneCount += 1
		end
	end
	local symmetric = true
	for _, key in ipairs({"Inner", "Outer", "Lower"}) do
		local left = dronePositions.Left[key]
		local right = dronePositions.Right[key]
		if math.abs(left.X + right.X) > 0.05
			or math.abs(left.Y - right.Y) > 0.05
			or math.abs(left.Z - right.Z) > 0.05
		then
			symmetric = false
		end
	end
	model:SetAttribute("HunterDroneCount", droneCount)
	model:SetAttribute("HunterDroneCountPassed", droneCount == specification.Equipment.HunterDroneWings.DroneCount)
	model:SetAttribute("DroneWingSymmetryPassed", symmetric)
	model:SetAttribute("DroneWingGeometryPassed", droneCount == 6 and symmetric)
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("Sovereign_V_Apex_GoldenMaster")
	if existing then existing:Destroy() end

	local model = aegisBuilder.Build(parent)
	model.Name = "Sovereign_V_Apex_GoldenMaster"
	removeAegisEquipment(model)
	model:ScaleTo(specification.Scale.HeightStuds / 50)
	recolorFleet(model)

	model:SetAttribute("AssetName", specification.AssetName)
	model:SetAttribute("AssetClass", specification.AssetClass)
	model:SetAttribute("GuardianGeneration", 5)
	model:SetAttribute("BuiltFromGuardian", "Aegis-III Interceptor")
	model:SetAttribute("PipelinePhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("QualityGateC", "Pending")
	model:SetAttribute("GeometryOnly", true)
	model:SetAttribute("MinimumSurfaceOffsetStuds", specification.GeometryRules.MinimumSurfaceOffsetStuds)

	local armor = model:FindFirstChild("Armor") or folder(model, "Armor")
	local systems = model:FindFirstChild("Systems") or folder(model, "Systems")
	local equipment = model:FindFirstChild("Equipment") or folder(model, "Equipment")
	rebuildFleetHead(model, armor, systems)
	rebuildFleetFeet(model)
	local lockCore = addChestCore(systems, model)
	addApexLance(equipment, model)
	local dronePositions = addDroneWings(systems, model)
	addEquipmentHitboxes(model, dronePositions, lockCore)
	countGeometry(model)
	validateDroneWings(model, dronePositions)

	local metadata = model:FindFirstChild("Metadata") or folder(model, "Metadata")
	metadata:SetAttribute("TargetHeightStuds", specification.Scale.HeightStuds)
	metadata:SetAttribute("TargetShoulderWidthStuds", specification.Scale.ShoulderWidthStuds)
	metadata:SetAttribute("FleetBaseChassis", "Aegis-III Interceptor")
	metadata:SetAttribute("VisualTargetVersion", specification.VisualTarget.Version)
	metadata:SetAttribute("DroneCount", 6)
	metadata:SetAttribute("DronesPerSide", 3)
	metadata:SetAttribute("DroneWingFormation", "RaisedMechanicalBatClaws")
	return model
end

return Builder
