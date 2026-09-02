local aegisBuilder = require(script.Parent:WaitForChild("AegisInterceptorGoldenMaster"))
local specification = require(script.Parent:WaitForChild("BastionColossusSpecification"))

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
	if rotation then cf *= CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z)) end
	return part(parent, name, size, cf, color or COLORS.Body)
end

local function cylinder(parent, name, size, position, color, rotation)
	local r = rotation or Vector3.zero
	return part(parent, name, size, CFrame.new(position) * CFrame.Angles(math.rad(r.X), math.rad(r.Y), math.rad(r.Z)), color, Enum.Material.Metal, Enum.PartType.Cylinder)
end

local function folder(parent, name)
	local item = Instance.new("Folder")
	item.Name = name
	item.Parent = parent
	return item
end

local function removeAegisEquipment(model)
	for _, name in ipairs({
		"LeftIonCannon", "RightIonCannon", "LeftShoulderMissilePod",
		"RightShoulderMissilePod", "DirectionalAegis",
	}) do
		local item = model:FindFirstChild(name, true)
		if item then item:Destroy() end
	end
	for _, name in ipairs({"LeftMissilePodHitbox", "RightMissilePodHitbox", "AegisProjectorHitbox"}) do
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
	}
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			for _, mapping in ipairs(aegis) do
				local source = mapping[1]
				if Vector3.new(item.Color.R - source.R, item.Color.G - source.G, item.Color.B - source.B).Magnitude < 0.04 then
					item.Color = mapping[2]
					break
				end
			end
		end
	end
end

local function offsetHead(model)
	local shift = Vector3.new(-3.4, 0, 0)
	for _, name in ipairs({"SensorHead", "HeadBrow", "VisorSensor", "HeadHitbox"}) do
		local item = model:FindFirstChild(name, true)
		if item and item:IsA("BasePart") then item.CFrame += shift end
	end
	model:SetAttribute("HeadOffsetStuds", -3.4)
end

local function addSiegeFist(equipment, model, side)
	local palm = model:FindFirstChild(side .. "Hand", true)
	palm = palm and palm:FindFirstChild("Palm", true)
	assert(palm and palm:IsA("BasePart"), "Missing " .. side .. " Palm for Siege Fist")
	local fist = Instance.new("Model")
	fist.Name = side .. "SiegeFist"
	fist:SetAttribute("EquipmentType", "SiegeFist")
	fist:SetAttribute("RigMount", side .. "Hand")
	fist.Parent = equipment
	local cf = palm.CFrame
	part(fist, "FistCage", Vector3.new(6.6, 5.8, 6.2), cf * CFrame.new(0, -0.8, -0.25), COLORS.Body)
	part(fist, "KnucklePlate", Vector3.new(6.9, 2.1, 2.2), cf * CFrame.new(0, -1.1, -3.15), COLORS.Armor, Enum.Material.Metal)
	for index = 1, 4 do
		local x = (index - 2.5) * 1.45
		part(fist, "SiegeKnuckle" .. index, Vector3.new(1.15, 1.5, 1.35), cf * CFrame.new(x, -1.0, -4.0), COLORS.DarkMetal)
	end
	part(fist, "WristRam", Vector3.new(4.2, 2.2, 4.4), cf * CFrame.new(0, 2.4, 0.15), COLORS.Chassis)
	fist.PrimaryPart = fist:FindFirstChild("FistCage")
end

local function addRailCannon(equipment, model)
	local cannon = Instance.new("Model")
	cannon.Name = "HeavyRailCannon"
	cannon:SetAttribute("EquipmentType", "HeavyRailCannon")
	cannon:SetAttribute("RigMount", "UpperTorso")
	cannon:SetAttribute("RecoilTravelStuds", specification.Equipment.HeavyRailCannon.RecoilTravelStuds)
	cannon.Parent = equipment

	block(cannon, "RightShoulderCradle", Vector3.new(8.2, 3.4, 9.0), Vector3.new(6.8, 47.0, 0.8), COLORS.Chassis)
	cylinder(cannon, "RailTraverseBearing", Vector3.new(3.2, 7.0, 7.0), Vector3.new(6.8, 49.1, -1.0), COLORS.DarkMetal, Vector3.new(0, 90, 0))
	block(cannon, "RailBreech", Vector3.new(7.4, 7.0, 10.5), Vector3.new(6.8, 49.5, -4.5), COLORS.Body)
	block(cannon, "UpperTorsoRecoilRail", Vector3.new(1.2, 1.0, 24.0), Vector3.new(4.5, 51.1, -13.0), COLORS.Accent)
	block(cannon, "LowerTorsoRecoilRail", Vector3.new(1.2, 1.0, 24.0), Vector3.new(9.1, 47.9, -13.0), COLORS.Accent)
	block(cannon, "RailBarrelUpper", Vector3.new(6.2, 1.8, 25.0), Vector3.new(6.8, 51.3, -16.2), COLORS.Armor)
	block(cannon, "RailBarrelLower", Vector3.new(6.2, 1.8, 25.0), Vector3.new(6.8, 47.8, -16.2), COLORS.Armor)
	block(cannon, "RailCoreChannel", Vector3.new(3.2, 2.0, 25.6), Vector3.new(6.8, 49.55, -16.5), COLORS.Accent).Material = Enum.Material.Neon
	block(cannon, "RailMuzzleFrame", Vector3.new(7.4, 6.5, 2.0), Vector3.new(6.8, 49.55, -29.2), COLORS.DarkMetal)
	cylinder(cannon, "RailMuzzleCore", Vector3.new(1.0, 3.2, 3.2), Vector3.new(6.8, 49.55, -30.3), COLORS.ChargeHot, Vector3.new(0, 90, 0)).Material = Enum.Material.Neon
	block(cannon, "RearTorsoBrace", Vector3.new(6.0, 8.5, 4.0), Vector3.new(6.8, 46.5, 4.8), COLORS.DarkMetal, Vector3.new(-8, 0, 0))
	cannon.PrimaryPart = cannon:FindFirstChild("RailBreech")
	local head = model:FindFirstChild("SensorHead", true)
	assert(head and head:IsA("BasePart"), "Missing SensorHead for Heavy Rail Cannon mount")
	-- Resolve the complete cannon from the actual scaled head/shoulder position.
	cannon:PivotTo(CFrame.new(head.Position.X + 6.2, head.Position.Y + 2.0, head.Position.Z - 3.2))
end

local function addShieldTower(systems, model, side, sign)
	local tower = Instance.new("Model")
	tower.Name = side .. "DistrictShieldTower"
	tower:SetAttribute("EquipmentType", "DistrictShieldTower")
	tower:SetAttribute("RigMount", "UpperTorso")
	tower.Parent = systems
	local x = sign * 14.8
	block(tower, "TowerPylon", Vector3.new(5.5, 5.5, 5.5), Vector3.new(sign * 11.5, 43.0, 1.8), COLORS.Chassis, Vector3.new(0, 0, sign * 8))
	block(tower, "TowerBody", Vector3.new(7.0, 13.5, 6.5), Vector3.new(x, 48.0, 1.2), COLORS.Body, Vector3.new(0, sign * 3, 0))
	block(tower, "TowerCrown", Vector3.new(7.5, 2.0, 7.0), Vector3.new(x, 54.8, 1.2), COLORS.Armor)
	for index = 1, 2 do
		local node = cylinder(tower, "ShieldNode" .. index, Vector3.new(0.65, 2.6, 2.6), Vector3.new(x, 50.7 - index * 4.2, -2.35), COLORS.Accent, Vector3.new(0, 90, 0))
		node.Material = Enum.Material.Neon
	end
	tower.PrimaryPart = tower:FindFirstChild("TowerBody")
	local head = model:FindFirstChild("SensorHead", true)
	local torso = model:FindFirstChild("TorsoUpper", true)
	assert(head and torso, "Missing body anchors for District Shield Tower")
	-- Towers overlap the shoulder mass instead of hovering above it.
	tower:PivotTo(CFrame.new(torso.Position.X + sign * 12.0, head.Position.Y + 1.5, torso.Position.Z + 1.3))
end

local function addDistrictProjectors(systems, model)
	local projectors = Instance.new("Model")
	projectors.Name = "DistrictShieldProjectors"
	projectors:SetAttribute("EquipmentType", "DistrictShield")
	projectors:SetAttribute("ShieldPoints", specification.Equipment.DistrictShield.ShieldPoints)
	projectors:SetAttribute("RuntimeFieldVisible", false)
	projectors.Parent = systems

	-- Resolve the emblem from the scaled torso so it remains on the chest.
	local torso = model:FindFirstChild("TorsoUpper", true)
	assert(torso and torso:IsA("BasePart"), "Missing TorsoUpper for Bastion chest emblem")
	local chest = torso.Position + Vector3.new(0, -0.8, -(torso.Size.Z * 0.5 + 0.55))
	block(projectors, "EmblemFrame", Vector3.new(9.0, 8.2, 0.65), chest, COLORS.DarkMetal)
	block(projectors, "EmblemSpine", Vector3.new(1.45, 5.7, 0.4), chest + Vector3.new(0, -0.25, -0.55), COLORS.Accent).Material = Enum.Material.Neon
	block(projectors, "EmblemLeftWing", Vector3.new(1.4, 4.8, 0.4), chest + Vector3.new(-2.0, 0.55, -0.54), COLORS.Accent, Vector3.new(0, 0, -31)).Material = Enum.Material.Neon
	block(projectors, "EmblemRightWing", Vector3.new(1.4, 4.8, 0.4), chest + Vector3.new(2.0, 0.55, -0.54), COLORS.Accent, Vector3.new(0, 0, 31)).Material = Enum.Material.Neon
	for _, data in ipairs({
		{"ChestProjector", Vector3.new(0, 34.5, -7.8)},
		{"LeftHipProjector", Vector3.new(-7.0, 27.5, -4.5)},
		{"RightHipProjector", Vector3.new(7.0, 27.5, -4.5)},
		{"RearProjector", Vector3.new(0, 39.0, 6.2)},
	}) do
		local node = cylinder(projectors, data[1], Vector3.new(0.75, 2.4, 2.4), data[2], COLORS.Accent, Vector3.new(0, 90, 0))
		node.Material = Enum.Material.Neon
	end
	projectors.PrimaryPart = projectors:FindFirstChild("EmblemFrame")
end

local function invisibleHitbox(parent, name, size, position)
	local item = block(parent, name, size, position, Color3.new(1, 0, 0))
	item.Transparency = 1
	item.CanQuery = false
	return item
end

local function addEquipmentHitboxes(model)
	local hitboxes = model:FindFirstChild("Hitboxes") or folder(model, "Hitboxes")
	invisibleHitbox(hitboxes, "HeavyRailCannonHitbox", Vector3.new(8, 8, 32), Vector3.new(6.8, 49.5, -14.5))
	invisibleHitbox(hitboxes, "LeftShieldTowerHitbox", Vector3.new(7.5, 14, 7), Vector3.new(-14.8, 48, 1.2))
	invisibleHitbox(hitboxes, "RightShieldTowerHitbox", Vector3.new(7.5, 14, 7), Vector3.new(14.8, 48, 1.2))
	invisibleHitbox(hitboxes, "DistrictProjectorHitbox", Vector3.new(12, 11.5, 2), Vector3.new(0, 38, -7))
end

local function countGeometry(model)
	local visible, hitboxes = 0, 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			if item:FindFirstAncestor("Hitboxes") then hitboxes += 1
			elseif item.Transparency < 1 then visible += 1 end
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
	local existing = parent:FindFirstChild("Bastion_IV_Colossus_GoldenMaster")
	if existing then existing:Destroy() end

	local model = aegisBuilder.Build(parent)
	model.Name = "Bastion_IV_Colossus_GoldenMaster"
	removeAegisEquipment(model)
	model:ScaleTo(specification.Scale.HeightStuds / 50)
	recolorFleet(model)
	offsetHead(model)

	model:SetAttribute("AssetName", specification.AssetName)
	model:SetAttribute("AssetClass", specification.AssetClass)
	model:SetAttribute("GuardianGeneration", 4)
	model:SetAttribute("BuiltFromGuardian", "Aegis-III Interceptor")
	model:SetAttribute("PipelinePhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("QualityGateC", "Pending")
	model:SetAttribute("GeometryOnly", true)
	model:SetAttribute("MinimumSurfaceOffsetStuds", specification.GeometryRules.MinimumSurfaceOffsetStuds)

	local equipment = model:FindFirstChild("Equipment") or folder(model, "Equipment")
	local systems = model:FindFirstChild("Systems") or folder(model, "Systems")
	addSiegeFist(equipment, model, "Left")
	addSiegeFist(equipment, model, "Right")
	addRailCannon(equipment, model)
	addShieldTower(systems, model, "Left", -1)
	addShieldTower(systems, model, "Right", 1)
	addDistrictProjectors(systems, model)
	addEquipmentHitboxes(model)
	countGeometry(model)

	local metadata = model:FindFirstChild("Metadata") or folder(model, "Metadata")
	metadata:SetAttribute("TargetHeightStuds", specification.Scale.HeightStuds)
	metadata:SetAttribute("TargetShoulderWidthStuds", specification.Scale.ShoulderWidthStuds)
	metadata:SetAttribute("FleetBaseChassis", "Aegis-III Interceptor")
	metadata:SetAttribute("VisualTargetVersion", specification.VisualTarget.Version)
	return model
end

return Builder
