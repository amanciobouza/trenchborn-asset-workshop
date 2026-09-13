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
	local p = part(parent, name, size, cf, color, Enum.PartType.Block)
	p:SetAttribute("PrimitiveVolume", "Ellipsoid")
	local mesh = Instance.new("SpecialMesh")
	mesh.Name = "EllipsoidMesh"
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local function tryUnion(parent: Instance, name: string, solids: {BasePart}): BasePart?
	-- SpecialMesh is a visual deformation, not the solid used by CSG.
	-- Preserve these ellipsoids instead of replacing them with carrier geometry.
	for _, solid in ipairs(solids) do
		if solid:FindFirstChildWhichIsA("SpecialMesh") then
			parent:SetAttribute("HeadGeometryMode", "VisualEllipsoids_CSGDeferred")
			return nil
		end
	end
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
		local brow = sphere(parent, sign < 0 and "LeftBrowRidge" or "RightBrowRidge", scaled(Vector3.new(1.65, 0.7, 2.25), sx, sy, sz), frame(origin, Vector3.new(sign * 1.95, 27.65, -2.85), sx, sy, sz) * CFrame.Angles(math.rad(-11), sign * math.rad(7), 0), ARMOR)
		brow:SetAttribute("ContourPart", true)
		sphere(parent, sign < 0 and "LeftEyeSocket" or "RightEyeSocket", scaled(Vector3.new(0.7, 0.48, 0.36), sx, sy, sz), frame(origin, Vector3.new(sign * 2.28, 27.22, -3.0), sx, sy, sz), BODY_DARK)
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
	sphere(parent, "MouthSeam", scaled(Vector3.new(3.65, 0.10, 2.65), sx, sy, sz), frame(origin, Vector3.new(0, 25.68, -4.5), sx, sy, sz), Color3.fromRGB(12, 13, 12))
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

-- Approved animated-feature concept: large readable masses and embedded features.
-- Stage 1 only; keep the other evolution stages unchanged until reviewed.
local function roundedBox(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, radius: number)
	-- Exact rounded-box envelope: flat cores, tangent cylindrical edges,
	-- spherical corners. No ellipsoid bulges through the flat faces.
	local a, b, c = size.X / 2 - radius, size.Y / 2 - radius, size.Z / 2 - radius
	assert(math.min(a, b, c) > 0, "Rounded box radius exceeds half-size")
	part(parent, name .. "CoreX", Vector3.new(size.X, 2*b, 2*c), cf, color)
	part(parent, name .. "CoreY", Vector3.new(2*a, size.Y, 2*c), cf, color)
	part(parent, name .. "CoreZ", Vector3.new(2*a, 2*b, size.Z), cf, color)
	for _, s in ipairs({-1, 1}) do
		for _, t in ipairs({-1, 1}) do
			local suffix = tostring(s) .. "_" .. tostring(t)
			part(parent, name .. "EdgeX" .. suffix, Vector3.new(2*a, 2*radius, 2*radius), cf * CFrame.new(0, s*b, t*c), color, Enum.PartType.Cylinder)
			part(parent, name .. "EdgeY" .. suffix, Vector3.new(2*b, 2*radius, 2*radius), cf * CFrame.new(s*a, 0, t*c) * CFrame.Angles(0, 0, math.pi/2), color, Enum.PartType.Cylinder)
			part(parent, name .. "EdgeZ" .. suffix, Vector3.new(2*c, 2*radius, 2*radius), cf * CFrame.new(s*a, t*b, 0) * CFrame.Angles(0, math.pi/2, 0), color, Enum.PartType.Cylinder)
			for _, u in ipairs({-1, 1}) do
				part(parent, name .. "Corner" .. suffix .. "_" .. tostring(u), Vector3.new(2*radius, 2*radius, 2*radius), cf * CFrame.new(s*a, t*b, u*c), color, Enum.PartType.Ball)
			end
		end
	end
end

local function buildStylizedHead(model: Model, origin: CFrame)
	local function mass(name: string, size: Vector3, pos: Vector3, color: Color3): Part
		return sphere(model, name, size, origin * CFrame.new(pos), color)
	end
	mass("Neck", Vector3.new(5.0, 5.0, 4.6), Vector3.new(0, 25.0, 0.1), BODY_DARK)
	-- Low elongated skull: the crown meets the brow line instead of bulging above it.
	local cranium = mass("Cranium", Vector3.new(4.8, 2.6, 4.8), Vector3.new(0, 27.05, -1.05), BODY)
	cranium.CFrame *= CFrame.Angles(math.rad(-6), 0, 0)
	mass("SnoutBridge", Vector3.new(3.5, 1.7, 4.2), Vector3.new(0, 27.0, -2.65), BODY)
	roundedBox(model, "UpperMuzzle", Vector3.new(4.05, 1.2, 3.6), origin * CFrame.new(0, 26.55, -4.2), BODY, 0.28)
	mass("LowerJawRear", Vector3.new(4.7, 2.4, 3.6), Vector3.new(0, 25.4, -1.8), BODY_DARK)
	roundedBox(model, "LowerJawFront", Vector3.new(3.9, 1.15, 4.25), origin * CFrame.new(0, 25.3, -3.65), BODY_DARK, 0.25)
	for _, sign in ipairs({-1, 1}) do
		local side = sign < 0 and "Left" or "Right"
		mass(side .. "CheekMass", Vector3.new(2.2, 2.4, 2.7), Vector3.new(sign * 1.85, 26.3, -1.8), BODY)
		-- One shared eye frame keeps the socket, iris and pupil aligned.
		-- Move the eyes above the muzzle rather than onto its outer cheeks.
		-- A small outward cant retains depth while both eyes read from the front.
		local eyeFrame = origin * CFrame.new(sign * 1.50, 27.55, -3.95)
			* CFrame.Angles(0, -sign * math.rad(10), 0)
		sphere(model, side .. "EyeSocket", Vector3.new(1.1, 0.85, 0.5), eyeFrame, BODY_DARK)
		local eye = sphere(model, side .. "Eye", Vector3.new(0.64, 0.52, 0.18), eyeFrame * CFrame.new(0, 0, -0.24), ENERGY)
		eye.Material = Enum.Material.Neon
		sphere(model, side .. "Pupil", Vector3.new(0.17, 0.37, 0.08), eyeFrame * CFrame.new(0, 0, -0.34), Color3.fromRGB(12, 15, 10))
		sphere(model, side .. "EyeHighlight", Vector3.new(0.10, 0.10, 0.06), eyeFrame * CFrame.new(-0.10, 0.14, -0.39), Color3.fromRGB(255, 242, 185))
		local brow = mass(side .. "BrowRidge", Vector3.new(1.5, 0.65, 2.0), Vector3.new(sign * 1.95, 27.95, -3.2), BODY_DARK)
		brow.CFrame *= CFrame.Angles(math.rad(-7), sign * math.rad(5), 0)
		mass(side .. "Nostril", Vector3.new(0.26, 0.18, 0.12), Vector3.new(sign * 1.25, 26.7, -6.0), BODY_DARK)
	end
end

local function applyStylizedMasses(model: Model, origin: CFrame)
	-- Remove the ladder-like belly and small pectoral beads from this generated model.
	for _, name in ipairs({"SternumMass", "ClavicleMass", "LeftPectoral", "RightPectoral", "BellyBand_1", "BellyBand_2", "BellyBand_3", "BellyBand_4"}) do
		local old = model:FindFirstChild(name)
		if old then old:Destroy() end
	end
	sphere(model, "BellyShield", Vector3.new(6.2, 6.8, 2.5), origin * CFrame.new(0, 19.1, -2.25), BELLY)
	for _, sign in ipairs({-1, 1}) do
		local side = sign < 0 and "Left" or "Right"
		sphere(model, side .. "Pectoral", Vector3.new(5.65, 5.1, 3.0), origin * CFrame.new(sign * 2.35, 22.65, -2.55), BELLY)
		sphere(model, side .. "Deltoid", Vector3.new(4.8, 4.8, 4.5), origin * CFrame.new(sign * 4.7, 22.0, -0.1), BODY)
		sphere(model, side .. "BicepsMass", Vector3.new(3.6, 5.0, 3.7), origin * CFrame.new(sign * 5.15, 19.35, -0.25), BODY)
		sphere(model, side .. "ForearmMass", Vector3.new(5.1, 5.3, 4.9), origin * CFrame.new(sign * 5.6, 15.0, -0.75), BODY)
		sphere(model, side .. "ForearmFlexor", Vector3.new(3.6, 4.3, 3.3), origin * CFrame.new(sign * 5.5, 14.6, -1.65), BODY)
		local thigh = model:FindFirstChild(side .. "ThighMass") :: BasePart
		thigh.Size = Vector3.new(6.1, 6.5, 5.8)
		thigh.CFrame = origin * CFrame.new(sign * 3.5, 12.8, -0.65)
		sphere(model, side .. "OuterQuadriceps", Vector3.new(3.5, 5.2, 4.2), origin * CFrame.new(sign * 4.2, 12.9, -1.25), BODY)
		local palm = model:FindFirstChild(side .. "PalmMass") :: BasePart
		palm.Size = Vector3.new(4.3, 3.5, 3.8)
	end
	-- Broad stance comes from abducted upper arms, not horizontal shoulder spacers.
	for _, sign in ipairs({-1, 1}) do
		local side = sign < 0 and "Left" or "Right"
		local shoulder = Vector3.new(sign * 5.7, 22.5, -0.1)
		local elbow = Vector3.new(sign * 9.2, 18.0, 1.0)
		local wrist = Vector3.new(sign * 9.6, 13.3, -1.7)
		local function place(name: string, size: Vector3, pos: Vector3, rotation: CFrame?)
			local item = model:FindFirstChild(side .. name)
			assert(item and item:IsA("BasePart"), "Missing arm part: " .. side .. name)
			item.Size = size
			item.CFrame = origin * CFrame.new(pos) * (rotation or CFrame.identity)
		end
		place("ShoulderJoint", Vector3.new(5.6, 5.6, 5.4), shoulder)
		place("Deltoid", Vector3.new(6.4, 6.1, 5.9), shoulder)
		place("ElbowJoint", Vector3.new(3.7, 3.7, 3.6), elbow)
		local upperDirection = CFrame.lookAt(Vector3.zero, elbow - shoulder) * CFrame.Angles(math.pi/2, 0, 0)
		local lowerDirection = CFrame.lookAt(Vector3.zero, wrist - elbow) * CFrame.Angles(math.pi/2, 0, 0)
		place("BicepsMass", Vector3.new(4.4, 6.0, 4.2), (shoulder + elbow)/2, upperDirection)
		-- Elongated muscle belly near the elbow, with a slimmer distal forearm.
		-- Both volumes follow the elbow-to-wrist axis instead of forming a ball.
		place("ForearmMass", Vector3.new(4.2, 6.4, 3.6), elbow:Lerp(wrist, 0.40), lowerDirection)
		place("ForearmFlexor", Vector3.new(3.0, 5.4, 2.5), elbow:Lerp(wrist, 0.43) + Vector3.new(0, 0, -0.45), lowerDirection)
		sphere(model, side .. "ForearmTaper", Vector3.new(2.95, 3.5, 2.7),
			origin * CFrame.new(elbow:Lerp(wrist, 0.78)) * lowerDirection, BODY)
		for _, name in ipairs({"UpperArm", "Forearm"}) do
			local old = model:FindFirstChild(side .. name)
			if old then old:Destroy() end
		end
		cylinderBetween(model, side .. "UpperArm", shoulder, elbow, 3.8, origin, 1, 1, 1, BODY)
		cylinderBetween(model, side .. "Forearm", elbow, wrist, 2.7, origin, 1, 1, 1, BODY)
		local offset = origin:VectorToWorldSpace(wrist - Vector3.new(sign * 5.15, 12.7, -0.9))
		local function move(name: string)
			local item = model:FindFirstChild(side .. name)
			assert(item and item:IsA("BasePart"), "Missing hand part: " .. side .. name)
			item.CFrame += offset
		end
		move("WristJoint")
		move("PalmMass")
		for i = 1, 3 do
			for _, prefix in ipairs({"Finger_", "Knuckle_", "FingerPad_", "HandClaw_"}) do move(prefix .. i) end
		end
		sphere(model, side .. "ShoulderBridge", Vector3.new(3.3, 3.5, 4.0), origin * CFrame.new(sign * 3.9, 23.1, 0), BODY)

		-- Broad shallow palm, short digits: a paw rather than a spherical fist.
		local oldPalm = model:FindFirstChild(side .. "PalmMass")
		if oldPalm then oldPalm:Destroy() end
		roundedBox(model, side .. "Palm", Vector3.new(4.3, 2.6, 2.4), origin * CFrame.new(wrist + Vector3.new(0, -1.1, -0.2)), BODY_DARK, 0.48)
		place("WristJoint", Vector3.new(3.25, 3.1, 2.75), wrist)
		for i = 1, 3 do
			local x = wrist.X + (i - 2) * 1.15
			local base = Vector3.new(x, wrist.Y - 2.05, wrist.Z - 0.25)
			local tip = base + Vector3.new(0, -0.75, -0.5)
			local oldFinger = model:FindFirstChild(side .. "Finger_" .. i)
			if oldFinger then oldFinger:Destroy() end
			cylinderBetween(model, side .. "Finger_" .. i, base, tip, 0.95, origin, 1, 1, 1, BODY_DARK)
			place("Knuckle_" .. i, Vector3.new(1.05, 0.85, 0.95), base)
			place("FingerPad_" .. i, Vector3.new(0.95, 0.8, 0.95), tip)
			place("HandClaw_" .. i, Vector3.new(0.86, 0.82, 0.95), tip + Vector3.new(0, -0.6, 0), CFrame.Angles(-math.pi/2, 0, 0))
		end

		-- Distinct back-of-hand volume and short opposed thumb; both are created
		-- in the same local hand frame as the fingers before the complete twist.
		sphere(model, side .. "HandBack", Vector3.new(3.65, 2.25, 0.85),
			origin * CFrame.new(wrist + Vector3.new(0, -1.15, 0.82)), BODY)
		local thumbBase = wrist + Vector3.new(sign * 1.8, -0.65, -0.1)
		local thumbJoint = wrist + Vector3.new(sign * 2.35, -1.25, -0.45)
		local thumbTip = wrist + Vector3.new(sign * 2.1, -1.95, -0.8)
		sphere(model, side .. "ThumbRoot", Vector3.new(1.5, 1.65, 1.5), origin * CFrame.new(thumbBase), BODY)
		cylinderBetween(model, side .. "ThumbUpper", thumbBase, thumbJoint, 1.1, origin, 1, 1, 1, BODY)
		sphere(model, side .. "ThumbJoint", Vector3.new(1.2, 1.2, 1.2), origin * CFrame.new(thumbJoint), BODY)
		cylinderBetween(model, side .. "ThumbLower", thumbJoint, thumbTip, 0.95, origin, 1, 1, 1, BODY)
		sphere(model, side .. "ThumbTip", Vector3.new(1.0, 1.05, 1.05), origin * CFrame.new(thumbTip), BODY)
		claw(model, side .. "ThumbClaw", thumbTip + Vector3.new(0, -0.42, -0.12), 0, origin, 1, 1, 1, -90, 0.72)
		local thumbNail = model:FindFirstChild(side .. "ThumbClaw") :: BasePart
		thumbNail.Size = Vector3.new(0.8, 0.78, 0.72)
		-- Roll each claw around its own long local Z axis, mirrored per hand.
		-- Post-multiplication preserves the center and longitudinal direction.
		for _, name in ipairs({"HandClaw_1", "HandClaw_2", "HandClaw_3", "ThumbClaw"}) do
			local nail = model:FindFirstChild(side .. name) :: BasePart
			nail.CFrame *= CFrame.Angles(0, 0, sign * math.pi)
		end

		-- Keep the complete paw aligned with the forearm in side view.
		-- Positive X pitch sends a downward finger toward local -Z (forward).
		local handPitch = math.atan2(elbow.Z - wrist.Z, elbow.Y - wrist.Y)
		local wristFrame = origin * CFrame.new(wrist)
		-- Local +Z is the hand back. At +/-125 degrees it faces forward/outward;
		-- the palm (-Z) faces backward/inward instead of presenting to the viewer.
		local handTransform = wristFrame * CFrame.Angles(handPitch, 0, 0)
			* CFrame.Angles(0, sign * math.rad(125), 0) * wristFrame:Inverse()
		for _, item in ipairs(model:GetChildren()) do
			if item:IsA("BasePart") then
				for _, prefix in ipairs({"Palm", "WristJoint", "Finger_", "Knuckle_", "FingerPad_", "HandClaw_", "HandBack", "Thumb"}) do
					if string.sub(item.Name, 1, #side + #prefix) == side .. prefix then
						item.CFrame = handTransform * item.CFrame
						break
					end
				end
			end
		end

		-- Wider planted foot with a thick forefoot and substantial toe pads.
		local footX = sign * 3.25
		place("HeelMass", Vector3.new(4.4, 2.3, 4.3), Vector3.new(footX, 1.5, 0.15))
		local oldForefoot = model:FindFirstChild(side .. "ForefootMass")
		if oldForefoot then oldForefoot:Destroy() end
		roundedBox(model, side .. "Forefoot", Vector3.new(4.9, 1.9, 4.0), origin * CFrame.new(footX, 1.15, -1.5), BODY_DARK, 0.5)
		for i = 1, 3 do
			local toeX = footX + (i - 2) * 1.4
			local toe = model:FindFirstChild(side .. "Toe_" .. i)
			if toe then toe:Destroy() end
			cylinderBetween(model, side .. "Toe_" .. i, Vector3.new(toeX, 1.0, -2.3), Vector3.new(toeX, 0.95, -3.6), 1.2, origin, 1, 1, 1, BODY_DARK)
			sphere(model, side .. "ToePad_" .. i, Vector3.new(1.25, 1.05, 1.5), origin * CFrame.new(toeX, 0.95, -3.35), BODY_DARK)
			place("FrontClaw_" .. i, Vector3.new(1.05, 0.95, 1.15), Vector3.new(toeX, 0.7, -4.15), CFrame.Angles(math.rad(-8), 0, 0))
		end
		place("RearClaw", Vector3.new(0.95, 0.9, 1.15), Vector3.new(footX, 1.0, 2.05), CFrame.Angles(math.rad(-8), math.pi, 0))
	end
	local upperChest = model:FindFirstChild("UpperRibcage") :: BasePart
	upperChest.Size = Vector3.new(11.3, 6.2, 6.6)
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Material ~= Enum.Material.Neon then
			item.Material = Enum.Material.SmoothPlastic
		end
	end
	model:SetAttribute("ArtDirection", "PixarInspired_PrimitiveMaquette")
	model:SetAttribute("HeadGeometryMode", "VisualEllipsoids_NoCSG")
end

-- Roblox-only refinement of the approved two-stage maquette, Stage 1.
-- All ellipsoids remain visual SpecialMeshes: never feed them to CSG.
local function refineStageOne(model: Model, origin: CFrame)
	local skin = Color3.fromRGB(61, 69, 82)
	local underside = Color3.fromRGB(119, 117, 88)
	local plateColor = Color3.fromRGB(43, 49, 60)
	local function remove(name: string)
		local item = model:FindFirstChild(name)
		if item then item:Destroy() end
	end
	local function mass(name: string, size: Vector3, pos: Vector3, color: Color3, rotation: CFrame?)
		remove(name)
		return sphere(model, name, size, origin * CFrame.new(pos) * (rotation or CFrame.identity), color)
	end
	-- One skin tone hides artificial joint bands. Keep pupils and nostrils dark.
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			if item.Color == BODY or item.Color == BODY_DARK then
				if not string.find(item.Name, "EyeSocket") and not string.find(item.Name, "Nostril") then
					item.Color = skin
				end
			elseif item.Color == BELLY then item.Color = underside
			elseif item.Color == CLAW then item.Color = Color3.fromRGB(202, 193, 157)
			end
			item.Reflectance = 0
		end
	end
	-- Broad continuous abdominal and back envelopes, with shallow chest relief.
	mass("LowerAbdomen", Vector3.new(7.3, 7.2, 6.1), Vector3.new(0, 17.7, 0.35), skin)
	mass("UpperAbdomen", Vector3.new(8.4, 7.1, 6.3), Vector3.new(0, 20.1, 0), skin)
	mass("BellyShield", Vector3.new(6.8, 9.0, 1.9), Vector3.new(0, 18.95, -2.65), underside)
	mass("DorsalLumbarMass", Vector3.new(8.0, 9.3, 7.0), Vector3.new(0, 18.2, 2.0), skin)
	mass("SacralMass", Vector3.new(8.1, 7.0, 7.5), Vector3.new(0, 14.7, 3.0), skin)
	mass("TailRootMass", Vector3.new(6.9, 6.1, 8.6), Vector3.new(0, 12.8, 5.1), skin, CFrame.Angles(math.rad(-20), 0, 0))
	mass("Neck", Vector3.new(5.0, 6.7, 4.8), Vector3.new(0, 25.15, -0.1), skin)
	mass("NapeFlow", Vector3.new(5.3, 5.0, 4.8), Vector3.new(0, 23.95, 1.05), skin, CFrame.Angles(math.rad(-18), 0, 0))
	mass("ThroatShield", Vector3.new(3.5, 5.1, 1.5), Vector3.new(0, 24.4, -2.15), underside)
	mass("UpperRibcage", Vector3.new(11.3, 5.7, 6.6), Vector3.new(0, 22.65, 0.15), skin)
	-- Low frontal bridge reaches from the skull into the brow roots.
	mass("FrontalBridge", Vector3.new(4.0, 1.3, 3.9), Vector3.new(0, 27.65, -2.2), skin)
	for _, sign in ipairs({-1, 1}) do
		local side = sign < 0 and "Left" or "Right"
		mass(side .. "Pectoral", Vector3.new(5.7, 3.8, 1.35), Vector3.new(sign * 2.18, 22.45, -2.95), underside)
		mass(side .. "Deltoid", Vector3.new(6.4, 5.5, 5.9), Vector3.new(sign * 5.7, 22.1, -0.1), skin)
		mass(side .. "ShoulderJoint", Vector3.new(5.6, 5.3, 5.4), Vector3.new(sign * 5.7, 22.1, -0.1), skin)
		mass(side .. "ShoulderBridge", Vector3.new(3.3, 3.1, 4.0), Vector3.new(sign * 3.9, 22.65, 0), skin)
		mass(side .. "CheekMass", Vector3.new(1.5, 2.25, 2.8), Vector3.new(sign * 1.65, 26.25, -1.95), skin)
		-- Fill behind each eye, leaving its forward luminous surface exposed.
		mass(side .. "OrbitalSupport", Vector3.new(1.65, 1.55, 2.0), Vector3.new(sign * 1.45, 27.45, -3.05), skin)
		mass(side .. "BrowRidge", Vector3.new(1.55, 0.62, 1.7), Vector3.new(sign * 1.45, 27.99, -3.6), skin,
			CFrame.Angles(0, -sign * math.rad(8), sign * math.rad(8)))
		mass(side .. "Flank", Vector3.new(4.1, 6.5, 5.0), Vector3.new(sign * 2.35, 18.65, 0.4), skin)
		-- Long calf/instep envelopes bury flat cylinder ends and connect the foot.
		mass(side .. "CalfMass", Vector3.new(4.8, 6.3, 4.65), Vector3.new(sign * 3.15, 7.8, 0.0), skin,
			CFrame.Angles(math.rad(-27), 0, 0))
		mass(side .. "AnkleJoint", Vector3.new(3.5, 3.2, 3.45), Vector3.new(sign * 3.25, 2.45, 0.0), skin)
		mass(side .. "InstepFlow", Vector3.new(4.0, 4.8, 4.5), Vector3.new(sign * 3.25, 2.65, -0.6), skin,
			CFrame.Angles(math.rad(12), 0, 0))
	end
	-- Lift the complete face as one assembly, including all rounded-box pieces.
	-- Neck and throat were resized separately to retain overlap with the skull.
	local headNames: {[string]: boolean} = {Cranium = true, SnoutBridge = true, LowerJawRear = true, FrontalBridge = true}
	local headPrefixes = {"UpperMuzzle", "LowerJawFront"}
	for _, side in ipairs({"Left", "Right"}) do
		for _, feature in ipairs({"CheekMass", "OrbitalSupport", "BrowRidge", "EyeSocket", "Eye", "Pupil", "EyeHighlight", "Nostril"}) do
			headNames[side .. feature] = true
		end
	end
	local headLift = origin:VectorToWorldSpace(Vector3.new(0, 0.8, 0))
	for _, item in ipairs(model:GetChildren()) do
		if item:IsA("BasePart") then
			local isHead = headNames[item.Name] == true
			for _, prefix in ipairs(headPrefixes) do
				if string.sub(item.Name, 1, #prefix) == prefix then isHead = true end
			end
			if isHead then item.CFrame += headLift end
		end
	end
	-- Preserve the original seven cylinder segments and their stepped silhouette.
	for _, item in ipairs(model:GetChildren()) do
		if string.match(item.Name, "^DorsalShield_") or string.match(item.Name, "^DorsalEnergy_") then
			item:Destroy()
		end
	end
	-- Extend the original stepped cylinder tail with progressively smaller ends.
	local extension = {
		Vector3.new(0, 5.0, 19.7), Vector3.new(0, 4.55, 22.0),
		Vector3.new(0, 4.25, 24.0), Vector3.new(0, 4.1, 25.5),
	}
	for i, diameter in ipairs({1.65, 1.0, 0.45}) do
		cylinderBetween(model, string.format("TailSegment_%02d", i + 7), extension[i], extension[i+1], diameter, origin, 1, 1, 1, skin)
	end
	local tipDirection = (extension[4] - extension[3]).Unit
	mass("TailTip", Vector3.new(0.45, 0.45, 1.2), extension[4], skin, CFrame.lookAt(Vector3.zero, tipDirection))
	model:SetAttribute("GeometryAmendmentReview", "Pending_ExtendedTail")
	local function plate(i: number, root: Vector3, height: number, projection: number, pitch: number, inset: number, thickness: number?)
		local width = thickness or 1.15
		local cf = origin * CFrame.new(root + Vector3.new(0, 0.2, projection * 0.35))
			* CFrame.Angles(math.rad(pitch), math.pi, math.pi)
		wedge(model, string.format("DorsalShield_%02d", i), Vector3.new(width, height, projection), cf, plateColor)
		for _, sign in ipairs({-1, 1}) do
			-- Homothetic inset about the triangular face centroid keeps a dark border
			-- on all three edges. Wedge cross-section centroid is (-h/6,d/6).
			local glow = wedge(model, string.format("DorsalEnergy_%02d_%s", i, sign < 0 and "Left" or "Right"),
				Vector3.new(0.06, height * inset, projection * inset),
				cf * CFrame.new(sign * (width/2 + 0.035), -(1-inset)*height/6, (1-inset)*projection/6), ENERGY)
			glow.Material = Enum.Material.Neon
			glow.Transparency = 0.12
		end
	end
	-- Three dominant plates, then subordinate plates along the tail surface.
	plate(1, Vector3.new(0, 26.3, 2.65), 3.1, 4.4, -23, 0.55)
	plate(2, Vector3.new(0, 22.1, 4.5), 3.9, 5.5, -32, 0.57)
	plate(3, Vector3.new(0, 17.3, 5.15), 3.25, 4.6, -26, 0.52)
	for segmentIndex = 2, 7 do
		local segment = model:FindFirstChild(string.format("TailSegment_%02d", segmentIndex)) :: BasePart
		local localFrame = origin:ToObjectSpace(segment.CFrame)
		local axis = localFrame.RightVector
		-- Project world-up onto the cylinder cross-section to locate its top.
		local topDirection = (Vector3.yAxis - axis * axis.Y).Unit
		local root = localFrame.Position + topDirection * (segment.Size.Y * 0.43)
		local scale = (8 - segmentIndex) / 7
		plate(segmentIndex + 2, root, 0.5 + 1.8*scale, 0.6 + 2.65*scale, -38, 0.40)
	end
	plate(10, Vector3.new(0, 5.4, 20.85), 0.65, 0.95, -38, 0.35, 0.55)
	plate(11, Vector3.new(0, 4.8, 23.0), 0.38, 0.6, -38, 0.30, 0.32)
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Material ~= Enum.Material.Neon then
			item.Material = Enum.Material.SmoothPlastic
		end
	end
	model:SetAttribute("GeometryRevision", "S1_ExtendedTaperedCylinderTail_13")
	model:SetAttribute("VisualTarget", "Approved simplified Stage 1 and Stage 2 maquette")
	model:SetAttribute("GeometryMethod", "Roblox primitives and visual ellipsoids; no external assets")
end

-- Phase 5 is deliberately appearance-only: no transforms, sizes or new solids.
local function dressStageOne(model: Model)
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") then
			local name = item.Name
			item.Reflectance = 0
			if name == "LeftEye" or name == "RightEye" then
				item.Material = Enum.Material.Neon
				item.Color = Color3.fromRGB(240, 204, 42)
				item.Transparency = 0
			elseif string.match(name, "^DorsalEnergy_") then
				local index = tonumber(string.match(name, "^DorsalEnergy_(%d+)")) or 1
				item.Material = Enum.Material.Neon
				item.Color = index <= 3 and Color3.fromRGB(176, 140, 28) or Color3.fromRGB(130, 107, 29)
				item.Transparency = 0
			elseif string.match(name, "^DorsalShield_") or string.find(name, "Armor") or name == "LeftForearmShield" or name == "RightForearmShield" then
				item.Material = Enum.Material.Basalt
				item.Color = Color3.fromRGB(39, 45, 56)
			elseif string.find(name, "Claw") then
				item.Material = Enum.Material.SmoothPlastic
				item.Color = Color3.fromRGB(190, 180, 147)
			elseif string.find(name, "Eye") or string.find(name, "Pupil") or string.find(name, "Nostril") then
				-- Preserve the dark sockets and pupils and the small eye catchlights.
				item.Material = Enum.Material.SmoothPlastic
			elseif name == "BellyShield" or name == "ThroatShield" or string.find(name, "Pectoral") then
				item.Material = Enum.Material.Rubber
				item.Color = Color3.fromRGB(113, 111, 86)
			else
				item.Material = Enum.Material.Rubber
				item.Color = Color3.fromRGB(61, 69, 82)
			end
		end
	end
	model:SetAttribute("PipelinePhase", 5)
	model:SetAttribute("QualityGateB", "ApprovedByUser")
	model:SetAttribute("ApprovedGeometryCommit", "9aedccac1428207b5fbba954de9d941033989441")
	model:SetAttribute("DressingRevision", "S1_MatteSkin_BasaltArmor_02")
	model:SetAttribute("DressingReview", "ApprovedByUser")
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

	if index == 1 then
		buildStylizedHead(model, origin)
	else
		buildHead(model, origin, sx, sy, sz, stage.armor)
	end
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

	if index == 1 then
		applyStylizedMasses(model, origin)
		refineStageOne(model, origin)
		dressStageOne(model)
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
	if stageIndex == 1 then
		collection:SetAttribute("PipelinePhase", 5)
		collection:SetAttribute("QualityGateB", "ApprovedByUser")
		collection:SetAttribute("Purpose", "Stage 1 material and energy review")
	end
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
