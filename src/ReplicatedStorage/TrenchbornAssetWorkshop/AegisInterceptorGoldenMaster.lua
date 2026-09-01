local marshalBuilder = require(script.Parent:WaitForChild("MarshalRoadblockGoldenMaster"))
local specification = require(script.Parent:WaitForChild("AegisInterceptorSpecification"))

local Builder = {}

local COLORS = specification.Palette

local function part(parent, name, size, cf, color, material, shape)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cf
	item.Color = color
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
	return part(parent, name, size, cf, color or COLORS.Body)
end

local function cylinder(parent, name, size, position, color, rotation)
	local r = rotation or Vector3.zero
	return part(
		parent,
		name,
		size,
		CFrame.new(position) * CFrame.Angles(math.rad(r.X), math.rad(r.Y), math.rad(r.Z)),
		color,
		Enum.Material.Metal,
		Enum.PartType.Cylinder
	)
end

local function folder(parent, name)
	local item = Instance.new("Folder")
	item.Name = name
	item.Parent = parent
	return item
end

local function removeMarshalEquipment(model)
	for _, name in ipairs({"RiotShield", "PulseCannon", "ContainmentNetLauncher"}) do
		local item = model:FindFirstChild(name, true)
		if item then item:Destroy() end
	end
	for _, name in ipairs({"ShieldCoverageReference", "NetTargetingReference"}) do
		local item = model:FindFirstChild(name, true)
		if item then item:Destroy() end
	end
end

local function recolorFleet(model)
	local marshal = {
		{Color3.fromRGB(22, 29, 36), COLORS.Chassis},
		{Color3.fromRGB(54, 68, 80), COLORS.Body},
		{Color3.fromRGB(176, 190, 199), COLORS.Armor},
		{Color3.fromRGB(63, 199, 255), COLORS.Accent},
		{Color3.fromRGB(32, 40, 48), COLORS.DarkMetal},
	}
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			for _, mapping in ipairs(marshal) do
				local source = mapping[1]
				local delta = Vector3.new(item.Color.R - source.R, item.Color.G - source.G, item.Color.B - source.B)
				if delta.Magnitude < 0.035 then
					item.Color = mapping[2]
					break
				end
			end
		end
	end
end

local function addIonCannon(equipment, side, sign)
	local cannon = Instance.new("Model")
	cannon.Name = side .. "IonCannon"
	cannon:SetAttribute("EquipmentType", "IonCannon")
	cannon:SetAttribute("RigMount", side .. "LowerArm")
	cannon.Parent = equipment

	local x = sign * 12.6
	block(cannon, "ForearmHousing", Vector3.new(5.0, 8.8, 5.2), Vector3.new(x, 23.1, -0.8), COLORS.Body, Vector3.new(-2, sign * 3, sign * 4))
	block(cannon, "OuterArmor", Vector3.new(5.3, 5.7, 5.5), Vector3.new(x, 24.6, -1.0), COLORS.Armor, Vector3.new(-3, sign * 3, sign * 4))
	block(cannon, "CobaltSidePlate", Vector3.new(1.0, 6.4, 5.7), Vector3.new(x + sign * 2.85, 23.5, -0.65), COLORS.Body, Vector3.new(-2, sign * 3, sign * 4))
	cylinder(cannon, "RecoilSleeve", Vector3.new(5.8, 3.4, 3.4), Vector3.new(x, 19.5, -0.9), COLORS.DarkMetal, Vector3.new(0, 0, 90))
	cylinder(cannon, "IonBarrel", Vector3.new(4.8, 2.3, 2.3), Vector3.new(x, 17.1, -0.9), COLORS.Chassis, Vector3.new(0, 0, 90))
	cylinder(cannon, "MuzzleRing", Vector3.new(0.9, 3.5, 3.5), Vector3.new(x, 14.8, -0.9), COLORS.DarkMetal, Vector3.new(0, 0, 90))
	local core = cylinder(cannon, "IonMuzzleCore", Vector3.new(0.35, 2.3, 2.3), Vector3.new(x, 14.25, -0.9), COLORS.Accent, Vector3.new(0, 0, 90))
	core.Material = Enum.Material.Neon
	block(cannon, "IonChannel", Vector3.new(0.32, 4.8, 0.35), Vector3.new(x, 20.5, -3.55), COLORS.Accent).Material = Enum.Material.Neon
	cannon.PrimaryPart = cannon:FindFirstChild("ForearmHousing")
	return cannon
end

local function addMissilePod(systems, side, sign)
	local pod = Instance.new("Model")
	pod.Name = side .. "ShoulderMissilePod"
	pod:SetAttribute("EquipmentType", "ShoulderMissiles")
	pod:SetAttribute("MissileCellCount", specification.Equipment.ShoulderMissiles.CellsPerPod)
	pod:SetAttribute("RigMount", "UpperTorso")
	pod.Parent = systems

	local x = sign * 11.7
	-- The pylon visibly transfers the pod load into the upper torso; the bearing
	-- remains readable as the future elevation pivot.
	block(pod, "ShoulderPylon", Vector3.new(5.4, 3.4, 4.8), Vector3.new(sign * 8.9, 38.5, 0.2), COLORS.Chassis, Vector3.new(-2, sign * 3, sign * 5))
	cylinder(pod, "PodElevationBearing", Vector3.new(3.2, 4.5, 4.5), Vector3.new(sign * 10.0, 39.7, 0.15), COLORS.DarkMetal)
	cylinder(pod, "PodElevationHub", Vector3.new(3.45, 2.8, 2.8), Vector3.new(sign * 10.0, 39.7, 0.15), COLORS.Body)
	block(pod, "PodHousing", Vector3.new(6.6, 7.2, 7.0), Vector3.new(x, 40.2, 0.1), COLORS.DarkMetal, Vector3.new(-2, sign * 2, 0))
	block(pod, "PodArmorTop", Vector3.new(6.9, 1.2, 7.3), Vector3.new(x, 43.7, 0.15), COLORS.Armor, Vector3.new(-2, sign * 2, 0))
	block(pod, "PodArmorSide", Vector3.new(1.0, 6.3, 7.25), Vector3.new(x + sign * 3.55, 40.2, 0.15), COLORS.Body, Vector3.new(-2, sign * 2, 0))
	block(pod, "LauncherFace", Vector3.new(5.6, 6.2, 0.7), Vector3.new(x, 40.2, -3.58), COLORS.Chassis, Vector3.new(-2, sign * 2, 0))

	local index = 0
	for row = 1, 3 do
		for column = 1, 3 do
			if not (row == 2 and column == 2) then
				index += 1
				local cellX = x + sign * ((column - 2) * 1.55)
				local cellY = 40.2 + (2 - row) * 1.65
				local cell = cylinder(
					pod,
					"MissileCell" .. index,
					Vector3.new(0.38, 1.05, 1.05),
					Vector3.new(cellX, cellY, -4.18),
					COLORS.Warning,
					Vector3.new(0, 90, 0)
				)
				cell.Material = Enum.Material.Neon
			end
		end
	end
	block(pod, "WarningStrip", Vector3.new(3.6, 0.28, 0.2), Vector3.new(x, 36.8, -4.0), COLORS.Warning).Material = Enum.Material.Neon
	pod.PrimaryPart = pod:FindFirstChild("PodHousing")
	return pod
end

local function addAegisArray(systems)
	local aegis = Instance.new("Model")
	aegis.Name = "DirectionalAegis"
	aegis:SetAttribute("EquipmentType", "DirectionalShieldProjector")
	aegis:SetAttribute("ShieldPoints", specification.Equipment.DirectionalAegis.ShieldPoints)
	aegis:SetAttribute("RuntimeFieldVisible", false)
	aegis.Parent = systems

	local panels = {
		{"CoreCrown", Vector3.new(5.0, 2.4, 0.55), Vector3.new(0, 34.8, -4.95), Vector3.new(0, 0, 0)},
		{"LeftUpper", Vector3.new(4.6, 4.0, 0.62), Vector3.new(-3.5, 33.5, -4.85), Vector3.new(0, -5, 25)},
		{"RightUpper", Vector3.new(4.6, 4.0, 0.62), Vector3.new(3.5, 33.5, -4.85), Vector3.new(0, 5, -25)},
		{"LeftOuter", Vector3.new(3.5, 5.2, 0.7), Vector3.new(-6.0, 31.8, -4.35), Vector3.new(0, -8, 34)},
		{"RightOuter", Vector3.new(3.5, 5.2, 0.7), Vector3.new(6.0, 31.8, -4.35), Vector3.new(0, 8, -34)},
		{"LeftLower", Vector3.new(4.0, 3.1, 0.66), Vector3.new(-2.6, 29.8, -5.0), Vector3.new(0, -4, -18)},
		{"RightLower", Vector3.new(4.0, 3.1, 0.66), Vector3.new(2.6, 29.8, -5.0), Vector3.new(0, 4, 18)},
	}
	for _, definition in ipairs(panels) do
		local panel = block(aegis, definition[1], definition[2], definition[3], COLORS.Accent, definition[4])
		panel.Material = Enum.Material.Glass
		panel.Transparency = 0.16
		panel.Reflectance = 0.08
	end
	local core = cylinder(aegis, "AegisCore", Vector3.new(0.55, 3.0, 3.0), Vector3.new(0, 32.1, -5.45), COLORS.Accent, Vector3.new(0, 90, 0))
	core.Material = Enum.Material.Neon
	aegis.PrimaryPart = core
	return aegis
end

local function invisibleHitbox(parent, name, size, position)
	local item = block(parent, name, size, position, Color3.new(1, 0, 0))
	item.Transparency = 1
	item.CanQuery = false
	return item
end

local function addEquipmentHitboxes(model)
	local hitboxes = model:FindFirstChild("Hitboxes") or folder(model, "Hitboxes")
	invisibleHitbox(hitboxes, "LeftMissilePodHitbox", Vector3.new(7.5, 8, 8), Vector3.new(-11.7, 40.2, 0))
	invisibleHitbox(hitboxes, "RightMissilePodHitbox", Vector3.new(7.5, 8, 8), Vector3.new(11.7, 40.2, 0))
	invisibleHitbox(hitboxes, "AegisProjectorHitbox", Vector3.new(15, 9, 2), Vector3.new(0, 32.5, -4.6))
end

local function countGeometry(model)
	local visible = 0
	local hitboxes = 0
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

function Builder.Build(parent)
	local existing = parent:FindFirstChild("Aegis_III_Interceptor_GoldenMaster")
	if existing then existing:Destroy() end

	local model = marshalBuilder.Build(parent)
	model.Name = "Aegis_III_Interceptor_GoldenMaster"
	removeMarshalEquipment(model)
	model:ScaleTo(specification.Scale.HeightStuds / 46)
	recolorFleet(model)

	model:SetAttribute("AssetName", specification.AssetName)
	model:SetAttribute("AssetClass", specification.AssetClass)
	model:SetAttribute("GuardianGeneration", 3)
	model:SetAttribute("BuiltFromGuardian", "Marshal-II Roadblock")
	model:SetAttribute("PipelinePhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("QualityGateC", "Pending")
	model:SetAttribute("GeometryOnly", true)
	model:SetAttribute("MinimumSurfaceOffsetStuds", specification.GeometryRules.MinimumSurfaceOffsetStuds)

	local equipment = model:FindFirstChild("Equipment") or folder(model, "Equipment")
	local systems = model:FindFirstChild("Systems") or folder(model, "Systems")
	addIonCannon(equipment, "Left", -1)
	addIonCannon(equipment, "Right", 1)
	addMissilePod(systems, "Left", -1)
	addMissilePod(systems, "Right", 1)
	addAegisArray(systems)
	addEquipmentHitboxes(model)
	countGeometry(model)

	local metadata = model:FindFirstChild("Metadata") or folder(model, "Metadata")
	metadata:SetAttribute("TargetHeightStuds", specification.Scale.HeightStuds)
	metadata:SetAttribute("TargetShoulderWidthStuds", specification.Scale.ShoulderWidthStuds)
	metadata:SetAttribute("FleetBaseChassis", "Marshal-II Roadblock")
	metadata:SetAttribute("VisualTargetVersion", specification.VisualTarget.Version)
	return model
end

return Builder
