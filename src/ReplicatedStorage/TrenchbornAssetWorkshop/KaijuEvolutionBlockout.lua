--!strict
-- Phase 4 artistic blockout for the five-stage Primal Beast evolution.
-- Deliberately restricted to Roblox primitive volumes.

local Builder = {}

local BODY = Color3.fromRGB(43, 45, 39)
local BODY_DARK = Color3.fromRGB(27, 29, 26)
local BELLY = Color3.fromRGB(73, 70, 52)
local ARMOR = Color3.fromRGB(35, 37, 33)
local ENERGY = Color3.fromRGB(224, 188, 30)
local ENERGY_HIGH = Color3.fromRGB(173, 226, 45)
local CLAW = Color3.fromRGB(139, 126, 96)

type Stage = {
	name: string,
	height: number,
	shoulders: number,
	volume: number,
	armor: number,
	energy: number,
}

local STAGES: {Stage} = {
	{name = "Stage_1_Primal_Beast", height = 1.00, shoulders = 1.00, volume = 1.00, armor = 0, energy = 0.15},
	{name = "Stage_2_Storm_Hunter", height = 1.12, shoulders = 1.25, volume = 1.35, armor = 1, energy = 0.32},
	{name = "Stage_3_Rift_Stalker", height = 1.26, shoulders = 1.38, volume = 1.80, armor = 2, energy = 0.52},
	{name = "Stage_4_Caldera_Tyrant", height = 1.43, shoulders = 1.58, volume = 2.50, armor = 3, energy = 0.74},
	{name = "Stage_5_Cataclysm_Titan", height = 1.62, shoulders = 1.85, volume = 3.60, armor = 4, energy = 1.00},
}

local function defaults(p: BasePart)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = true
	p.Material = Enum.Material.Slate
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
end

local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Shape = shape or Enum.PartType.Block
	defaults(p)
	p.Parent = parent
	return p
end

local function sphere(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): Part
	local p = part(parent, name, size, cf, color, Enum.PartType.Ball)
	p:SetAttribute("PrimitiveVolume", "Ellipsoid")
	local mesh = Instance.new("SpecialMesh")
	mesh.Name = "EllipsoidMesh"
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local function tryUnion(parent: Instance, name: string, solids: {BasePart}): BasePart?
	local primary = solids[1]
	local others = {}
	for index = 2, #solids do
		table.insert(others, solids[index])
	end
	local ok, result = pcall(function()
		return primary:UnionAsync(others)
	end)
	if not ok or not result then
		warn(string.format("[Kaiju Evolution] CSG union fallback for %s", name))
		return nil
	end
	result.Name = name
	result.Color = primary.Color
	defaults(result)
	result.Parent = parent
	for _, solid in ipairs(solids) do
		if solid.Parent then solid:Destroy() end
	end
	return result
end

local function trySubtract(parent: Instance, name: string, solid: BasePart, cutters: {BasePart}): BasePart?
	local ok, result = pcall(function()
		return solid:SubtractAsync(cutters)
	end)
	for _, cutter in ipairs(cutters) do
		if cutter.Parent then cutter:Destroy() end
	end
	if not ok or not result then
		warn(string.format("[Kaiju Evolution] CSG subtraction fallback for %s", name))
		return nil
	end
	result.Name = name
	result.Color = solid.Color
	defaults(result)
	result.Parent = parent
	if solid.Parent then solid:Destroy() end
	return result
end

local function wedge(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): WedgePart
	local p = Instance.new("WedgePart")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	defaults(p)
	p.Parent = parent
	return p
end

local function corner(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): CornerWedgePart
	local p = Instance.new("CornerWedgePart")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	defaults(p)
	p.Parent = parent
	return p
end

local function scaled(v: Vector3, sx: number, sy: number, sz: number): Vector3
	return Vector3.new(v.X * sx, v.Y * sy, v.Z * sz)
end

local function frame(origin: CFrame, p: Vector3, sx: number, sy: number, sz: number): CFrame
	return origin * CFrame.new(scaled(p, sx, sy, sz))
end

local function cylinderBetween(parent: Instance, name: string, a: Vector3, b: Vector3, diameter: number, origin: CFrame, sx: number, sy: number, sz: number, color: Color3): Part
	local wa = frame(origin, a, sx, sy, sz).Position
	local wb = frame(origin, b, sx, sy, sz).Position
	local delta = wb - wa
	local mid = (wa + wb) * 0.5
	return part(parent, name, Vector3.new(delta.Magnitude, diameter * sx, diameter * sz), CFrame.lookAt(mid, wb) * CFrame.Angles(0, math.rad(90), 0), color, Enum.PartType.Cylinder)
end

local function claw(parent: Instance, name: string, pos: Vector3, yaw: number, origin: CFrame, sx: number, sy: number, sz: number, pitch: number?, length: number?)
	wedge(parent, name, scaled(Vector3.new(0.72, 0.68, length or 1.65), sx, sy, sz), frame(origin, pos, sx, sy, sz) * CFrame.Angles(math.rad(pitch or -8), math.rad(yaw), 0), CLAW)
end

local function buildFoot(parent: Instance, side: string, sign: number, origin: CFrame, sx: number, sy: number, sz: number)
	local x = sign * 3.25
	sphere(parent, side .. "HeelMass", scaled(Vector3.new(3.6, 1.7, 3.6), sx, sy, sz), frame(origin, Vector3.new(x, 1.35, 0.15), sx, sy, sz), BODY_DARK)
	sphere(parent, side .. "ForefootMass", scaled(Vector3.new(3.9, 1.35, 3.2), sx, sy, sz), frame(origin, Vector3.new(x, 1.05, -1.35), sx, sy, sz), BODY_DARK)
	for i, lateral in ipairs({-1.05, 0, 1.05}) do
		local toeX = x + lateral
		cylinderBetween(parent, side .. "Toe_" .. i, Vector3.new(toeX, 0.9, -1.3), Vector3.new(toeX, 0.72, -3.0), 0.78, origin, sx, sy, sz, BODY_DARK)
		claw(parent, side .. "FrontClaw_" .. i, Vector3.new(toeX, 0.72, -3.75), 0, origin, sx, sy, sz)
	end
	claw(parent, side .. "RearClaw", Vector3.new(x, 1.0, 1.95), 180, origin, sx, sy, sz)
end

local function buildArm(parent: Instance, side: string, sign: number, origin: CFrame, sx: number, sy: number, sz: number, armorLevel: number)
	local shoulder = Vector3.new(sign * 4.7, 22.0, -0.1)
	local elbow = Vector3.new(sign * 5.55, 16.9, -0.35)
	local wrist = Vector3.new(sign * 5.15, 12.7, -0.9)
	sphere(parent, side .. "ShoulderJoint", scaled(Vector3.new(4.3, 4.3, 4.0), sx, sy, sz), frame(origin, shoulder, sx, sy, sz), BODY)
	cylinderBetween(parent, side .. "UpperArm", shoulder, elbow, 2.8, origin, sx, sy, sz, BODY)
	sphere(parent, side .. "ElbowJoint", scaled(Vector3.new(3.05, 3.05, 3.0), sx, sy, sz), frame(origin, elbow, sx, sy, sz), BODY_DARK)
	cylinderBetween(parent, side .. "Forearm", elbow, wrist, 3.15, origin, sx, sy, sz, BODY)
	sphere(parent, side .. "WristJoint", scaled(Vector3.new(3.0, 2.8, 2.9), sx, sy, sz), frame(origin, wrist, sx, sy, sz), BODY_DARK)
	sphere(parent, side .. "PalmMass", scaled(Vector3.new(3.9, 3.25, 3.55), sx, sy, sz), frame(origin, wrist + Vector3.new(0, -1.0, -0.2), sx, sy, sz), BODY_DARK)
	for i = 1, 3 do
		local fingerX = wrist.X + (i - 2) * 0.9
		local fingerBase = Vector3.new(fingerX, 11.45, -1.0)
		local fingerTip = Vector3.new(fingerX, 10.7, -1.05)
		cylinderBetween(parent, side .. "Finger_" .. i, fingerBase, fingerTip, 0.86, origin, sx, sy, sz, BODY_DARK)
		sphere(parent, side .. "Knuckle_" .. i, scaled(Vector3.new(1.05, 1.0, 1.05), sx, sy, sz), frame(origin, fingerBase, sx, sy, sz), BODY_DARK)
		sphere(parent, side .. "FingerPad_" .. i, scaled(Vector3.new(0.95, 0.95, 1.0), sx, sy, sz), frame(origin, fingerTip, sx, sy, sz), BODY_DARK)
		claw(parent, side .. "HandClaw_" .. i, Vector3.new(fingerX, 9.95, -1.05), 0, origin, sx, sy, sz, -90, 1.35)
	end
	if armorLevel >= 1 then
		wedge(parent, side .. "ForearmShield", scaled(Vector3.new(2.5 + armorLevel * 0.25, 4.0, 1.5), sx, sy, sz), frame(origin, Vector3.new(sign * 5.6, 15.0, -1.5), sx, sy, sz) * CFrame.Angles(0, sign * math.rad(90), 0), ARMOR)
	end
	if armorLevel >= 2 then
		corner(parent, side .. "ShoulderArmor", scaled(Vector3.new(3.8 + armorLevel * 0.35, 2.5, 3.8), sx, sy, sz), frame(origin, Vector3.new(sign * 5.1, 23.2, 0.0), sx, sy, sz) * CFrame.Angles(0, sign > 0 and math.rad(180) or 0, 0), ARMOR)
	end
end

local function buildHead(parent: Instance, origin: CFrame, sx: number, sy: number, sz: number, armorLevel: number)
	part(parent, "Neck", scaled(Vector3.new(5.0, 4.8, 4.7), sx, sy, sz), frame(origin, Vector3.new(0, 24.65, 0.35), sx, sy, sz), BODY_DARK, Enum.PartType.Cylinder).Orientation = Vector3.new(0, 0, 90)
	local skullSolids = {
		sphere(parent, "OccipitalMass", scaled(Vector3.new(5.5, 4.0, 4.8), sx, sy, sz), frame(origin, Vector3.new(0, 26.9, 0.45), sx, sy, sz), BODY),
		sphere(parent, "Cranium", scaled(Vector3.new(5.9, 3.55, 5.7), sx, sy, sz), frame(origin, Vector3.new(0, 27.1, -1.0), sx, sy, sz) * CFrame.Angles(math.rad(-5), 0, 0), BODY),
		sphere(parent, "LowCrown", scaled(Vector3.new(4.9, 1.05, 3.9), sx, sy, sz), frame(origin, Vector3.new(0, 28.35, -1.15), sx, sy, sz) * CFrame.Angles(math.rad(-10), 0, 0), BODY),
		sphere(parent, "SnoutBridge", scaled(Vector3.new(4.45, 1.35, 4.45), sx, sy, sz), frame(origin, Vector3.new(0, 26.95, -3.45), sx, sy, sz) * CFrame.Angles(math.rad(-9), 0, 0), BODY),
		sphere(parent, "UpperMuzzle", scaled(Vector3.new(4.0, 1.35, 3.3), sx, sy, sz), frame(origin, Vector3.new(0, 26.45, -4.85), sx, sy, sz), BODY_DARK),
	}
	local skull = tryUnion(parent, "SkullUnion", skullSolids)
	if skull then
		local cutters = {
			part(parent, "LeftEyeSocketCutter", scaled(Vector3.new(1.4, 1.1, 1.15), sx, sy, sz), frame(origin, Vector3.new(-2.45, 27.25, -3.0), sx, sy, sz), BODY_DARK, Enum.PartType.Ball),
			part(parent, "RightEyeSocketCutter", scaled(Vector3.new(1.4, 1.1, 1.15), sx, sy, sz), frame(origin, Vector3.new(2.45, 27.25, -3.0), sx, sy, sz), BODY_DARK, Enum.PartType.Ball),
		}
		skull = trySubtract(parent, "SkullWithEyeSockets", skull, cutters) or skull
	end
	for _, sign in ipairs({-1, 1}) do
		sphere(parent, sign < 0 and "LeftJawHinge" or "RightJawHinge", scaled(Vector3.new(2.35, 2.65, 2.7), sx, sy, sz), frame(origin, Vector3.new(sign * 1.75, 25.75, -1.55), sx, sy, sz), BODY_DARK)
		sphere(parent, sign < 0 and "LeftCheekMass" or "RightCheekMass", scaled(Vector3.new(2.35, 2.1, 2.85), sx, sy, sz), frame(origin, Vector3.new(sign * 1.75, 26.45, -2.15), sx, sy, sz), BODY)
		local brow = wedge(parent, sign < 0 and "LeftBrowRidge" or "RightBrowRidge", scaled(Vector3.new(2.35, 0.65, 2.35), sx, sy, sz), frame(origin, Vector3.new(sign * 1.4, 27.65, -2.85), sx, sy, sz) * CFrame.Angles(math.rad(-11), sign * math.rad(7), sign < 0 and math.rad(180) or 0), ARMOR)
		brow:SetAttribute("ContourPart", true)
		sphere(parent, sign < 0 and "LeftEyeSocket" or "RightEyeSocket", scaled(Vector3.new(1.05, 0.72, 0.5), sx, sy, sz), frame(origin, Vector3.new(sign * 2.28, 27.22, -3.0), sx, sy, sz), BODY_DARK)
		local eye = sphere(parent, sign < 0 and "LeftEye" or "RightEye", scaled(Vector3.new(0.24, 0.18, 0.14), sx, sy, sz), frame(origin, Vector3.new(sign * 2.48, 27.22, -3.16), sx, sy, sz), ENERGY)
		eye.Material = Enum.Material.Neon
	end
	sphere(parent, "NoseTip", scaled(Vector3.new(3.55, 0.9, 1.35), sx, sy, sz), frame(origin, Vector3.new(0, 26.45, -5.85), sx, sy, sz), ARMOR)
	local jawSolids = {
		sphere(parent, "LowerJawRear", scaled(Vector3.new(4.65, 1.8, 3.5), sx, sy, sz), frame(origin, Vector3.new(0, 25.2, -2.65), sx, sy, sz), BODY_DARK),
		sphere(parent, "LowerJawFront", scaled(Vector3.new(4.2, 1.45, 4.0), sx, sy, sz), frame(origin, Vector3.new(0, 25.05, -4.25), sx, sy, sz), BODY_DARK),
		sphere(parent, "ChinMass", scaled(Vector3.new(3.8, 0.85, 3.2), sx, sy, sz), frame(origin, Vector3.new(0, 24.62, -4.3), sx, sy, sz), BODY_DARK),
	}
	tryUnion(parent, "LowerJawUnion", jawSolids)
	part(parent, "MouthSeam", scaled(Vector3.new(3.75, 0.08, 2.85), sx, sy, sz), frame(origin, Vector3.new(0, 25.68, -4.5), sx, sy, sz), Color3.fromRGB(12, 13, 12))
	if armorLevel >= 2 then
		for _, sign in ipairs({-1, 1}) do
			corner(parent, sign < 0 and "LeftCrown" or "RightCrown", scaled(Vector3.new(2.5, 1.7 + armorLevel * 0.3, 2.4), sx, sy, sz), frame(origin, Vector3.new(sign * 2.45, 28.7, -0.1), sx, sy, sz) * CFrame.Angles(0, sign > 0 and math.rad(180) or 0, 0), ARMOR)
		end
	end
end

local function buildDorsals(parent: Instance, origin: CFrame, sx: number, sy: number, sz: number, armorLevel: number, energyAmount: number)
	local locations = {
		{position = Vector3.new(0, 27.8, 1.3), scale = 0.75, lift = 0.0},
		{position = Vector3.new(0, 25.0, 2.8), scale = 1.02, lift = 0.0},
		{position = Vector3.new(0, 22.0, 3.5), scale = 1.22, lift = 0.0},
		{position = Vector3.new(0, 18.8, 3.7), scale = 1.30, lift = 0.0},
		{position = Vector3.new(0, 15.5, 3.5), scale = 1.20, lift = 0.0},
		{position = Vector3.new(0, 12.8, 4.5), scale = 1.00, lift = 0.0},
		{position = Vector3.new(0, 11.8, 5.8), scale = 1.05, lift = 2.9},
		{position = Vector3.new(0, 10.5, 7.8), scale = 0.95, lift = 2.9},
		{position = Vector3.new(0, 9.1, 10.3), scale = 0.78, lift = 2.65},
		{position = Vector3.new(0, 7.8, 12.9), scale = 0.62, lift = 2.3},
		{position = Vector3.new(0, 6.8, 15.2), scale = 0.48, lift = 1.95},
		{position = Vector3.new(0, 6.0, 17.2), scale = 0.36, lift = 1.6},
		{position = Vector3.new(0, 5.4, 18.8), scale = 0.26, lift = 1.3},
	}
	for i, location in ipairs(locations) do
		local pos = location.position
		local centerScale = location.scale * (1 + armorLevel * 0.1)
		local rootHeight = 2.55 * centerScale
		local projection = 4.35 * centerScale
		local plateCenter = pos + Vector3.new(0, location.lift + 0.25 * centerScale, projection * 0.38)
		local sideVariation = (i % 2 == 0) and 4 or -4
		local plateFrame = frame(origin, plateCenter, sx, sy, sz)
			* CFrame.Angles(math.rad(-28), math.rad(180), math.rad(180 + sideVariation))
		wedge(parent, string.format("DorsalShield_%02d", i), scaled(Vector3.new(1.5, rootHeight, projection), sx, sy, sz), plateFrame, ARMOR)
		for _, side in ipairs({-1, 1}) do
			local surfaceOffset = side * (0.75 * sx + 0.035)
			local seam = wedge(parent, string.format("DorsalEnergy_%02d_%s", i, side < 0 and "Left" or "Right"), scaled(Vector3.new(0.08, rootHeight * 0.72, projection * 0.78), sx, sy, sz), plateFrame * CFrame.new(surfaceOffset, 0, -0.08), energyAmount > 0.75 and ENERGY_HIGH or ENERGY)
			seam.Material = Enum.Material.Neon
			seam.Transparency = 0.35 - energyAmount * 0.25
		end
	end
end

local function buildStage(parent: Instance, stage: Stage, index: number, origin: CFrame): Model
	local model = Instance.new("Model")
	model.Name = stage.name
	model:SetAttribute("EvolutionStage", index)
	model:SetAttribute("TargetHeightStuds", 30 * stage.height)
	model:SetAttribute("HeightPercent", math.round(stage.height * 100))
	model:SetAttribute("ShoulderWidthPercent", math.round(stage.shoulders * 100))
	model:SetAttribute("VolumePercent", math.round(stage.volume * 100))
	model:SetAttribute("PrimitiveArtDirection", true)
	model.Parent = parent

	local sx = stage.shoulders
	local sy = stage.height
	local sz = stage.volume / (stage.height * stage.shoulders)

	-- Organic body regions are sculpted from overlapping rounded masses. Each
	-- volume has a clear anatomical job instead of acting as one torso block.
	sphere(model, "PelvisCenter", scaled(Vector3.new(6.2, 4.4, 5.4), sx, sy, sz), frame(origin, Vector3.new(0, 15.7, 0.45), sx, sy, sz), BODY_DARK)
	sphere(model, "LowerAbdomen", scaled(Vector3.new(5.6, 3.8, 4.7), sx, sy, sz), frame(origin, Vector3.new(0, 18.0, 0.0), sx, sy, sz), BODY_DARK)
	sphere(model, "UpperAbdomen", scaled(Vector3.new(6.4, 4.2, 5.0), sx, sy, sz), frame(origin, Vector3.new(0, 20.25, -0.1), sx, sy, sz), BODY)
	sphere(model, "LowerRibcage", scaled(Vector3.new(8.8, 5.6, 6.1), sx, sy, sz), frame(origin, Vector3.new(0, 21.7, 0.0), sx, sy, sz), BODY)
	sphere(model, "UpperRibcage", scaled(Vector3.new(10.7, 6.2, 6.6), sx, sy, sz), frame(origin, Vector3.new(0, 23.1, 0.15), sx, sy, sz), BODY)
	sphere(model, "SternumMass", scaled(Vector3.new(4.2, 5.7, 2.7), sx, sy, sz), frame(origin, Vector3.new(0, 22.25, -3.0), sx, sy, sz), BELLY)
	cylinderBetween(model, "ClavicleMass", Vector3.new(-4.65, 23.8, -0.6), Vector3.new(4.65, 23.8, -0.6), 2.5, origin, sx, sy, sz, BODY)
	for _, sign in ipairs({-1, 1}) do
		sphere(model, sign < 0 and "LeftRibMass" or "RightRibMass", scaled(Vector3.new(5.0, 5.8, 5.6), sx, sy, sz), frame(origin, Vector3.new(sign * 2.8, 22.2, 0.1), sx, sy, sz), BODY)
		sphere(model, sign < 0 and "LeftPectoral" or "RightPectoral", scaled(Vector3.new(5.4, 4.1, 2.8), sx, sy, sz), frame(origin, Vector3.new(sign * 2.45, 22.85, -2.75), sx, sy, sz), BELLY)
		sphere(model, sign < 0 and "LeftFlank" or "RightFlank", scaled(Vector3.new(3.5, 4.0, 4.1), sx, sy, sz), frame(origin, Vector3.new(sign * 2.2, 19.4, 0.2), sx, sy, sz), BODY_DARK)
		sphere(model, sign < 0 and "LeftHipMass" or "RightHipMass", scaled(Vector3.new(4.4, 4.6, 4.7), sx, sy, sz), frame(origin, Vector3.new(sign * 2.45, 15.1, 0.2), sx, sy, sz), BODY)
	end
	for band = 1, 4 do
		local y = 21.15 - band * 1.0
		local halfWidth = 2.45 - band * 0.1
		cylinderBetween(model, "BellyBand_" .. band, Vector3.new(-halfWidth, y, -2.45), Vector3.new(halfWidth, y, -2.45), 0.62, origin, sx, sy, sz, BELLY)
	end

	-- Godzilla-like dorsal mass: the torso, pelvis, and tail root form one
	-- continuous heavy volume instead of a feline S-curve.
	sphere(model, "DorsalLumbarMass", scaled(Vector3.new(6.8, 7.2, 6.4), sx, sy, sz), frame(origin, Vector3.new(0, 18.0, 2.15), sx, sy, sz), BODY_DARK)
	sphere(model, "SacralMass", scaled(Vector3.new(7.4, 6.3, 7.2), sx, sy, sz), frame(origin, Vector3.new(0, 15.0, 3.15), sx, sy, sz), BODY_DARK)
	sphere(model, "TailRootMass", scaled(Vector3.new(6.4, 5.6, 8.0), sx, sy, sz), frame(origin, Vector3.new(0, 13.1, 5.1), sx, sy, sz) * CFrame.Angles(math.rad(-15), 0, 0), BODY_DARK)

	buildHead(model, origin, sx, sy, sz, stage.armor)
	buildArm(model, "Left", -1, origin, sx, sy, sz, stage.armor)
	buildArm(model, "Right", 1, origin, sx, sy, sz, stage.armor)

	for _, data in ipairs({{"Left", -1}, {"Right", 1}}) do
		local side = data[1] :: string
		local sign = data[2] :: number
		local x = sign * 3.15
		local hip = Vector3.new(x, 15.4, 0.3)
		local knee = Vector3.new(x, 10.2, -1.55)
		local hock = Vector3.new(x, 5.55, 1.35)
		local ankle = Vector3.new(x, 2.35, 0.2)
		sphere(model, side .. "HipJoint", scaled(Vector3.new(4.45, 4.3, 4.35), sx, sy, sz), frame(origin, hip, sx, sy, sz), BODY)
		sphere(model, side .. "ThighMass", scaled(Vector3.new(5.0, 5.6, 4.7), sx, sy, sz), frame(origin, (hip + knee) * 0.5, sx, sy, sz), BODY)
		cylinderBetween(model, side .. "UpperLeg", hip, knee, 4.2, origin, sx, sy, sz, BODY)
		sphere(model, side .. "KneeJoint", scaled(Vector3.new(4.35, 4.0, 4.25), sx, sy, sz), frame(origin, knee, sx, sy, sz), BODY_DARK)
		sphere(model, side .. "CalfMass", scaled(Vector3.new(4.25, 4.5, 4.0), sx, sy, sz), frame(origin, (knee + hock) * 0.5, sx, sy, sz), BODY)
		cylinderBetween(model, side .. "LowerLeg", knee, hock, 3.65, origin, sx, sy, sz, BODY_DARK)
		sphere(model, side .. "HockJoint", scaled(Vector3.new(3.3, 3.15, 3.25), sx, sy, sz), frame(origin, hock, sx, sy, sz), BODY_DARK)
		cylinderBetween(model, side .. "Metatarsal", hock, ankle, 2.8, origin, sx, sy, sz, BODY_DARK)
		sphere(model, side .. "AnkleJoint", scaled(Vector3.new(2.9, 2.7, 2.9), sx, sy, sz), frame(origin, ankle, sx, sy, sz), BODY_DARK)
		buildFoot(model, side, sign, origin, sx, sy, sz)
	end

	local tailPoints = {
		Vector3.new(0, 14.5, 2.4), Vector3.new(0, 13.2, 5.5), Vector3.new(0, 11.5, 8.6),
		Vector3.new(0, 9.5, 11.6), Vector3.new(0, 7.8, 14.2), Vector3.new(0, 6.4, 16.4),
		Vector3.new(0, 5.5, 18.2), Vector3.new(0, 5.0, 19.7),
	}
	for i = 1, #tailPoints - 1 do
		cylinderBetween(model, string.format("TailSegment_%02d", i), tailPoints[i], tailPoints[i + 1], 6.1 - i * 0.55, origin, sx, sy, sz, BODY_DARK)
	end
	buildDorsals(model, origin, sx, sy, sz, stage.armor, stage.energy)

	if stage.armor >= 3 then
		for rib = 1, 5 do
			for _, sign in ipairs({-1, 1}) do
				wedge(model, string.format("CalderaRib_%d_%d", rib, sign), scaled(Vector3.new(3.2, 0.8, 1.1), sx, sy, sz), frame(origin, Vector3.new(sign * 1.8, 24.0 - rib * 1.05, -3.35), sx, sy, sz) * CFrame.Angles(0, sign * math.rad(18), sign * math.rad(10)), ARMOR)
			end
		end
	end

	-- Normalize every stage to the agreed target height. This preserves the
	-- primitive proportions while making the 30-stud Stage 1 baseline exact.
	local _, unscaledSize = model:GetBoundingBox()
	local targetHeight = 30 * stage.height
	model:ScaleTo(model:GetScale() * (targetHeight / unscaledSize.Y))
	local scaledCFrame, scaledSize = model:GetBoundingBox()
	local bottomY = scaledCFrame.Position.Y - scaledSize.Y / 2
	model:PivotTo(model:GetPivot() + Vector3.new(0, origin.Position.Y - bottomY, 0))
	return model
end

local function createCollection(target: Instance, purpose: string): Model
	local existing = target:FindFirstChild("Kaiju_Evolution_Primitive_Blockout")
	if existing then existing:Destroy() end
	local collection = Instance.new("Model")
	collection.Name = "Kaiju_Evolution_Primitive_Blockout"
	collection:SetAttribute("PipelinePhase", 4)
	collection:SetAttribute("QualityGateB", "Pending")
	collection:SetAttribute("Purpose", purpose)
	collection.Parent = target
	return collection
end

function Builder.BuildStage(target: Instance, stageIndex: number, ground: CFrame?): Model
	local stage = STAGES[stageIndex]
	assert(stage, string.format("Unknown Kaiju evolution stage: %d", stageIndex))
	local collection = createCollection(target, string.format("Stage %d silhouette and proportion review", stageIndex))
	collection:SetAttribute("VisibleStage", stageIndex)
	buildStage(collection, stage, stageIndex, ground or CFrame.new(0, 0, 145))
	return collection
end

function Builder.Build(target: Instance, ground: CFrame?): Model
	local collection = createCollection(target, "Five-stage silhouette and proportion review")
	local base = ground or CFrame.new(0, 0, 145)
	local offsets = {-68, -36, 0, 42, 96}
	for index, stage in ipairs(STAGES) do
		buildStage(collection, stage, index, base * CFrame.new(offsets[index], 0, 0))
	end
	return collection
end

return Builder
