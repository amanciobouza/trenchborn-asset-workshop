local WardenBuilder = require(script.Parent:WaitForChild("WardenShepherdGoldenMaster"))

local Builder = {}

local COLORS = {
	Chassis = Color3.fromRGB(22, 29, 36),
	Body = Color3.fromRGB(54, 68, 80),
	Armor = Color3.fromRGB(176, 190, 199),
	Accent = Color3.fromRGB(63, 199, 255),
	DarkMetal = Color3.fromRGB(32, 40, 48),
}

local WARDEN_COLORS = {
	{Color3.fromRGB(28, 35, 32), COLORS.Chassis},
	{Color3.fromRGB(91, 103, 92), COLORS.Body},
	{Color3.fromRGB(171, 178, 151), COLORS.Armor},
	{Color3.fromRGB(92, 231, 151), COLORS.Accent},
	{Color3.fromRGB(45, 49, 47), COLORS.DarkMetal},
}

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
	return part(parent, name, size, CFrame.new(position) * CFrame.Angles(math.rad(r.X), math.rad(r.Y), math.rad(r.Z)), color, Enum.Material.Metal, Enum.PartType.Cylinder)
end

local function folder(parent, name)
	local result = Instance.new("Folder")
	result.Name = name
	result.Parent = parent
	return result
end

local function removeWardenSystems(model)
	local equipment = model:FindFirstChild("Equipment")
	if equipment then
		local baton = equipment:FindFirstChild("ShockBaton")
		if baton then baton:Destroy() end
	end
	local systems = model:FindFirstChild("Systems")
	if systems then
		local scanner = systems:FindFirstChild("SearchlightScanner")
		if scanner then scanner:Destroy() end
	end
end

local function recolor(model)
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			for _, mapping in ipairs(WARDEN_COLORS) do
				local source = mapping[1]
				local delta = Vector3.new(item.Color.R - source.R, item.Color.G - source.G, item.Color.B - source.B)
				if delta.Magnitude < 0.01 then
					item.Color = mapping[2]
					break
				end
			end
		end
	end
end

local function addShield(equipment, hitboxes)
	local shield = Instance.new("Model")
	shield.Name = "RiotShield"
	shield:SetAttribute("EquipmentType", "PhysicalDefense")
	shield:SetAttribute("FrontCoveragePercent", 38)
	shield.Parent = equipment

	-- Shield is offset forward and outward from the left forearm. The three panels
	-- overlap in volume, never on a shared exterior plane.
	local shieldX = -11.9
	block(shield, "CenterUpperPlate", Vector3.new(7.8, 9.4, 1.25), Vector3.new(shieldX, 23.25, -5.25), COLORS.Armor)
	block(shield, "CenterLowerPlate", Vector3.new(6.4, 8.2, 1.2), Vector3.new(shieldX, 14.45, -5.22), COLORS.Armor)
	block(shield, "OuterUpperWing", Vector3.new(2.8, 8.8, 1.15), Vector3.new(shieldX - 4.9, 23.0, -4.88), COLORS.Body, Vector3.new(0, -11, 0))
	block(shield, "OuterLowerWing", Vector3.new(2.2, 7.4, 1.1), Vector3.new(shieldX - 3.95, 14.7, -4.95), COLORS.Body, Vector3.new(0, -9, 0))
	block(shield, "InnerUpperWing", Vector3.new(2.8, 8.8, 1.15), Vector3.new(shieldX + 4.9, 23.0, -4.88), COLORS.Body, Vector3.new(0, 11, 0))
	block(shield, "InnerLowerWing", Vector3.new(2.2, 7.4, 1.1), Vector3.new(shieldX + 3.95, 14.7, -4.95), COLORS.Body, Vector3.new(0, 9, 0))
	block(shield, "TopRail", Vector3.new(10.4, 1.35, 1.55), Vector3.new(shieldX, 28.25, -5.3), COLORS.Chassis)
	block(shield, "LowerKeel", Vector3.new(4.8, 3.2, 1.45), Vector3.new(shieldX, 8.55, -5.2), COLORS.DarkMetal)
	block(shield, "ForearmCradle", Vector3.new(3.8, 6.6, 2.0), Vector3.new(-10.0, 20.4, -3.55), COLORS.Chassis, Vector3.new(0, 0, -6))
	block(shield, "UpperArmLink", Vector3.new(4.8, 1.15, 1.25), Vector3.new(-9.15, 22.75, -2.45), COLORS.DarkMetal, Vector3.new(0, 18, -8))
	block(shield, "LowerArmLink", Vector3.new(4.6, 1.15, 1.25), Vector3.new(-9.15, 18.25, -2.4), COLORS.DarkMetal, Vector3.new(0, 18, 5))
	block(shield, "UpperBrace", Vector3.new(1.1, 7.2, 1.0), Vector3.new(-10.7, 24.0, -3.8), COLORS.DarkMetal, Vector3.new(-24, 0, -8))
	block(shield, "LowerBrace", Vector3.new(1.1, 6.2, 1.0), Vector3.new(-10.45, 16.6, -3.75), COLORS.DarkMetal, Vector3.new(25, 0, -5))
	block(shield, "StatusChannel", Vector3.new(0.55, 10.8, 0.22), Vector3.new(shieldX, 20.0, -5.99), COLORS.Accent).Material = Enum.Material.Neon

	local shieldHitbox = block(hitboxes, "ShieldHitbox", Vector3.new(12.5, 20.5, 2.3), Vector3.new(shieldX, 19.0, -5.0), Color3.new(1, 0, 0))
	shieldHitbox.Transparency = 1
	shieldHitbox.CanQuery = false
	shield.PrimaryPart = shield:FindFirstChild("ForearmCradle")
end

local function addPulseCannon(equipment)
	local cannon = Instance.new("Model")
	cannon.Name = "PulseCannon"
	cannon:SetAttribute("EquipmentType", "ImpulseControlWeapon")
	cannon.Parent = equipment

	block(cannon, "ForearmHousing", Vector3.new(5.2, 7.4, 5.2), Vector3.new(10.15, 20.1, -0.8), COLORS.Body, Vector3.new(0, -3, 6))
	block(cannon, "UpperBreech", Vector3.new(4.5, 2.2, 5.8), Vector3.new(10.0, 23.15, -1.15), COLORS.Armor, Vector3.new(-4, -3, 6))
	-- The cannon follows the forearm axis at rest. Gameplay raises the complete
	-- arm to aim; the barrel never pivots independently like a turret.
	cylinder(cannon, "BarrelShroud", Vector3.new(2.8, 4.5, 4.5), Vector3.new(10.25, 16.35, -1.05), COLORS.Chassis, Vector3.new(0, 0, 90))
	cylinder(cannon, "MuzzleRing", Vector3.new(0.9, 5.0, 5.0), Vector3.new(10.25, 14.55, -1.05), COLORS.DarkMetal, Vector3.new(0, 0, 90))
	cylinder(cannon, "MuzzleCore", Vector3.new(0.3, 3.0, 3.0), Vector3.new(10.25, 13.98, -1.05), COLORS.Accent, Vector3.new(0, 0, 90)).Material = Enum.Material.Neon
	block(cannon, "SideReinforcement", Vector3.new(1.2, 5.8, 5.65), Vector3.new(12.55, 19.7, -0.85), COLORS.Armor, Vector3.new(0, -3, 7))
	cannon.PrimaryPart = cannon:FindFirstChild("ForearmHousing")
end

local function addContainmentNet(systems, hitboxes)
	local launcher = Instance.new("Model")
	launcher.Name = "ContainmentNetLauncher"
	launcher:SetAttribute("EquipmentType", "ContainmentSystem")
	launcher:SetAttribute("DeployedNetPermanent", false)
	launcher.Parent = systems

	block(launcher, "LauncherSpine", Vector3.new(5.8, 7.4, 2.4), Vector3.new(0, 31.2, 5.75), COLORS.Chassis, Vector3.new(-5, 0, 0))
	for _, sign in ipairs({-1, 1}) do
		local side = sign < 0 and "Left" or "Right"
		block(launcher, side .. "Cartridge", Vector3.new(4.2, 6.3, 3.0), Vector3.new(sign * 4.15, 32.0, 5.65), COLORS.Body, Vector3.new(-8, sign * 5, sign * 7))
		block(launcher, side .. "CartridgeCap", Vector3.new(4.45, 1.0, 3.25), Vector3.new(sign * 4.2, 35.0, 5.25), COLORS.Armor, Vector3.new(-8, sign * 5, sign * 7))
		block(launcher, side .. "Status", Vector3.new(2.5, 0.35, 0.2), Vector3.new(sign * 4.15, 32.7, 4.08), COLORS.Accent, Vector3.new(0, 0, sign * 7)).Material = Enum.Material.Neon
	end
	block(launcher, "LaunchMouth", Vector3.new(4.4, 1.7, 2.0), Vector3.new(0, 35.0, 4.55), COLORS.DarkMetal, Vector3.new(-18, 0, 0))

	local netHitbox = block(hitboxes, "NetTargetingReference", Vector3.new(1, 1, 1), Vector3.new(0, 35, 3.5), Color3.new(1, 0, 0))
	netHitbox.Transparency = 1
	netHitbox.CanQuery = false
	launcher.PrimaryPart = launcher:FindFirstChild("LauncherSpine")
end

local function countGeometry(model)
	local visible = 0
	local hitboxes = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			if item:FindFirstAncestor("Hitboxes") then hitboxes += 1 elseif item.Transparency < 1 then visible += 1 end
		end
	end
	model:SetAttribute("VisiblePartCount", visible)
	model:SetAttribute("GameplayHitboxCount", hitboxes)
	model:SetAttribute("VisiblePartBudgetPassed", visible <= 120)
	model:SetAttribute("HitboxBudgetPassed", hitboxes <= 8)
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("Marshal_II_Roadblock_GoldenMaster")
	if existing then existing:Destroy() end

	local model = WardenBuilder.Build(parent)
	model.Name = "Marshal_II_Roadblock_GoldenMaster"
	model:ScaleTo(46 / 42)
	removeWardenSystems(model)
	recolor(model)

	model:SetAttribute("AssetName", "Marshal-II Roadblock")
	model:SetAttribute("AssetClass", "Guardian Defense Platform")
	model:SetAttribute("GuardianGeneration", 2)
	model:SetAttribute("BuiltFromGuardian", "Warden-I Shepherd")
	model:SetAttribute("PipelinePhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("GeometryOnly", true)
	model:SetAttribute("MinimumSurfaceOffsetStuds", 0.03)

	local equipment = model:FindFirstChild("Equipment") or folder(model, "Equipment")
	local systems = model:FindFirstChild("Systems") or folder(model, "Systems")
	local hitboxes = model:FindFirstChild("Hitboxes") or folder(model, "Hitboxes")
	local metadata = model:FindFirstChild("Metadata") or folder(model, "Metadata")
	metadata:SetAttribute("TargetHeightStuds", 46)
	metadata:SetAttribute("TargetShoulderWidthStuds", 26)
	metadata:SetAttribute("FleetBaseChassis", "Warden-I Shepherd")

	addShield(equipment, hitboxes)
	addPulseCannon(equipment)
	addContainmentNet(systems, hitboxes)
	countGeometry(model)
	return model
end

return Builder
