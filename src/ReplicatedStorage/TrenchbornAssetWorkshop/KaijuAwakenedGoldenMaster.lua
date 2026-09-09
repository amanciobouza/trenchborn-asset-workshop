--!strict
-- Kaiju-I Bound Chimera | Phase 4 geometry-only Golden Master
local Builder = {}
local Specification = require(script.Parent:WaitForChild("KaijuAwakenedSpecification"))

local BODY = Color3.fromRGB(44, 49, 39)
local DARK = Color3.fromRGB(24, 28, 24)
local ARMOR = Color3.fromRGB(31, 35, 31)
local BELLY = Color3.fromRGB(68, 72, 52)
local ENERGY_REVIEW = Color3.fromRGB(157, 170, 48)
local EYE = Color3.fromRGB(244, 218, 45)
local CLAW = Color3.fromRGB(126, 119, 91)

type BuildConfig = { GroundCFrame: CFrame? }

local function defaults(part: BasePart)
	part.Anchored = false; part.CanCollide = false; part.CanQuery = false; part.CanTouch = false
	part.Massless = true; part.CastShadow = true
	part.TopSurface = Enum.SurfaceType.Smooth; part.BottomSurface = Enum.SurfaceType.Smooth
end

local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, shape: Enum.PartType?): Part
	local p = Instance.new("Part"); p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color
	p.Material = Enum.Material.SmoothPlastic; p.Shape = shape or Enum.PartType.Block; defaults(p); p.Parent = parent
	return p
end

local function ellipsoid(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): Part
	local p = part(parent, name, size, cf, color)
	local mesh = Instance.new("SpecialMesh"); mesh.Name = "FormMesh"; mesh.MeshType = Enum.MeshType.Sphere; mesh.Parent = p
	return p
end

local function angular(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): Part
	local p = part(parent, name, size, cf, color)
	p.Material = Enum.Material.Slate
	return p
end

local function wedge(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): WedgePart
	local p = Instance.new("WedgePart"); p.Name = name; p.Size = size; p.CFrame = cf; p.Color = color
	p.Material = Enum.Material.SmoothPlastic; defaults(p); p.Parent = parent; return p
end

local function weld(host: BasePart, child: BasePart)
	local w = Instance.new("WeldConstraint"); w.Name = child.Name .. "Weld"; w.Part0 = host; w.Part1 = child; w.Parent = child
end

local function motor(parent: Instance, name: string, a: BasePart, b: BasePart, world: CFrame)
	local m = Instance.new("Motor6D"); m.Name = name; m.Part0 = a; m.Part1 = b
	m.C0 = a.CFrame:ToObjectSpace(world); m.C1 = b.CFrame:ToObjectSpace(world); m.Parent = parent
end

local function segment(parent: Instance, name: string, a: Vector3, b: Vector3, width: number, depth: number, ground: CFrame, color: Color3): Part
	local wa, wb = ground:PointToWorldSpace(a), ground:PointToWorldSpace(b)
	local delta, middle = wb - wa, (wa + wb) * 0.5
	return ellipsoid(parent, name, Vector3.new(width, depth, delta.Magnitude), CFrame.lookAt(middle, middle + delta), color)
end

local function cylinderBetween(parent: Instance, name: string, a: Vector3, b: Vector3, diameter: number, ground: CFrame, color: Color3): Part
	local wa, wb = ground:PointToWorldSpace(a), ground:PointToWorldSpace(b)
	local delta, middle = wb - wa, (wa + wb) * 0.5
	local p = part(parent, name, Vector3.new(delta.Magnitude, diameter, diameter), CFrame.lookAt(middle, middle + delta) * CFrame.Angles(0, math.rad(90), 0), color, Enum.PartType.Cylinder)
	p.Material = Enum.Material.Slate
	return p
end

local function detailFolder(model: Model): Folder
	local f = Instance.new("Folder"); f.Name = "BodyGeometry"; f.Parent = model; return f
end

local function buildFoot(model: Model, geometry: Folder, side: string, sign: number, lowerLeg: BasePart, ground: CFrame): BasePart
	local x = sign * 3.45
	local hock, toeBase = Vector3.new(x, 6.0, 1.55), Vector3.new(x, 1.5, -1.15)
	local foot = segment(model, side .. "Foot", hock, toeBase, 4.4, 3.7, ground, BODY)
	motor(lowerLeg, side .. "Ankle", lowerLeg, foot, ground * CFrame.new(hock))
	local folder = Instance.new("Folder"); folder.Name = side .. "FootGeometry"; folder.Parent = geometry
	local bridge = ellipsoid(folder, "FootBridge", Vector3.new(4.8, 2.35, 4.8), ground * CFrame.new(x, 1.55, -1.3) * CFrame.Angles(math.rad(-9), 0, 0), BODY); weld(foot, bridge)
	for i, lateral in ipairs({-1.35, 0, 1.35}) do
		local toe = ellipsoid(folder, "ForwardToe_" .. i, Vector3.new(1.25, 1.05, 3.8), ground * CFrame.new(x + lateral, 0.8, -2.75) * CFrame.Angles(math.rad(-8), 0, 0), DARK); weld(foot, toe)
		local claw = wedge(folder, "ForwardClaw_" .. i, Vector3.new(0.58, 0.78, 1.75), ground * CFrame.new(x + lateral, 0.56, -4.85) * CFrame.Angles(math.rad(-12), 0, 0), CLAW); weld(toe, claw)
		local tip = wedge(folder, "ForwardClawTip_" .. i, Vector3.new(0.26, 0.42, 1.15), ground * CFrame.new(x + lateral, 0.38, -6.0) * CFrame.Angles(math.rad(-21), 0, 0), CLAW); weld(claw, tip)
	end
	-- Offset the rear talon laterally and upward so neither heel nor ankle can occlude it.
	local rearX = x + sign * 1.65
	local rearToe = ellipsoid(folder, "RearToe", Vector3.new(1.0, 0.88, 1.7), ground * CFrame.new(rearX, 1.95, 1.5) * CFrame.Angles(math.rad(18), 0, 0), DARK); weld(foot, rearToe)
	local rearClaw = wedge(folder, "RearClaw", Vector3.new(0.5, 0.68, 1.55), ground * CFrame.new(rearX, 1.82, 2.75) * CFrame.Angles(math.rad(16), math.rad(180), 0), CLAW); weld(rearToe, rearClaw)
	local rearTip = wedge(folder, "RearClawTip", Vector3.new(0.24, 0.38, 1.0), ground * CFrame.new(rearX, 1.92, 3.78) * CFrame.Angles(math.rad(25), math.rad(180), 0), CLAW); weld(rearClaw, rearTip)
	return foot
end
local function buildArm(model: Model, geometry: Folder, side: string, sign: number, torso: BasePart, ground: CFrame)
	local shoulder = Vector3.new(sign * 6.25, 21.25, -0.05)
	local elbow = Vector3.new(sign * 7.55, 17.9, -0.55)
	local wrist = Vector3.new(sign * 7.75, 14.85, -1.0)
	local upper = segment(model, side .. "UpperArm", shoulder, elbow, 2.4, 2.2, ground, BODY); motor(torso, side .. "Shoulder", torso, upper, ground * CFrame.new(shoulder))
	local lower = segment(model, side .. "LowerArm", elbow, wrist, 2.05, 1.85, ground, BODY); motor(upper, side .. "Elbow", upper, lower, ground * CFrame.new(elbow))
	local deltoid = ellipsoid(geometry, side .. "DeltoidMass", Vector3.new(3.0, 3.1, 2.75), ground * CFrame.new(shoulder + Vector3.new(0, -0.55, 0)), BODY); weld(upper, deltoid)
	local forearmMass = ellipsoid(geometry, side .. "ForearmMass", Vector3.new(2.4, 2.75, 2.2), ground * CFrame.new((elbow + wrist) * 0.5), BODY); weld(lower, forearmMass)
	-- Keep the elbow definition embedded in the joint mass instead of floating on its tip.
	local elbowEdge = wedge(geometry, side .. "ElbowEdge", Vector3.new(0.9, 0.78, 1.0), ground * CFrame.new(elbow + Vector3.new(-sign * 0.12, 0.08, -0.38)) * CFrame.Angles(0, sign * math.rad(90), sign * math.rad(8)), ARMOR); weld(lower, elbowEdge)
	local hand = ellipsoid(model, side .. "Hand", Vector3.new(3.35, 2.45, 2.9), ground * CFrame.new(wrist + Vector3.new(0, -0.65, -0.25)) * CFrame.Angles(math.rad(-6), 0, 0), DARK); motor(lower, side .. "Wrist", lower, hand, ground * CFrame.new(wrist))
	local f = Instance.new("Folder"); f.Name = side .. "HandGeometry"; f.Parent = geometry
	for i = 1, 3 do
		local fingerX = wrist.X + (i - 2) * 0.82
		local finger = ellipsoid(f, "PawDigit_" .. i, Vector3.new(0.72, 1.25, 1.1), ground * CFrame.new(fingerX, wrist.Y - 1.55, wrist.Z - 0.7) * CFrame.Angles(math.rad(-5), 0, 0), DARK); weld(hand, finger)
		-- Local -Z is rotated onto world -Y: the talons hang down instead of pointing forward.
		local claw = wedge(f, "HandClaw_" .. i, Vector3.new(0.5, 0.62, 1.45), ground * CFrame.new(fingerX, wrist.Y - 2.55, wrist.Z - 0.72) * CFrame.Angles(math.rad(-90), 0, 0), CLAW); weld(finger, claw)
	end
end
local function buildHead(model: Model, geometry: Folder, torso: BasePart, ground: CFrame): BasePart
	local head = ellipsoid(model, "Head", Vector3.new(5.8, 4.5, 5.7), ground * CFrame.new(0, 25.35, -1.45) * CFrame.Angles(math.rad(-6), 0, 0), BODY)
	motor(torso, "Neck", torso, head, ground * CFrame.new(0, 23.0, -0.05))
	local f = Instance.new("Folder"); f.Name = "HeadGeometry"; f.Parent = geometry
	local neckMantle = ellipsoid(f, "NeckMantle", Vector3.new(6.3, 4.2, 5.0), ground * CFrame.new(0, 23.6, 0.2) * CFrame.Angles(math.rad(-10), 0, 0), BODY); weld(head, neckMantle)
	-- Three smaller crown fragments define the skull without covering the eye line.
	for _, crownSpec in ipairs({
		{"CrownCenter", 0, 2.5, 1.25, 3.4, 0},
		{"CrownLeft", -1.75, 1.65, 1.0, 2.7, -9},
		{"CrownRight", 1.75, 1.65, 1.0, 2.7, 9},
	}) do
		local crown = wedge(f, crownSpec[1] :: string, Vector3.new(crownSpec[3] :: number, crownSpec[4] :: number, crownSpec[5] :: number), ground * CFrame.new(crownSpec[2] :: number, 26.8, -1.0) * CFrame.Angles(math.rad(-8), math.rad(180), math.rad(crownSpec[6] :: number)), ARMOR); weld(head, crown)
	end
	-- Two strong blocks create a deliberate upper muzzle and lower jaw.
	local upperMuzzle = angular(f, "UpperMuzzle", Vector3.new(4.65, 1.55, 3.65), ground * CFrame.new(0, 24.75, -4.15) * CFrame.Angles(math.rad(-5), 0, 0), DARK); weld(head, upperMuzzle)
	local muzzleCap = wedge(f, "MuzzleCap", Vector3.new(4.25, 0.72, 2.6), ground * CFrame.new(0, 25.45, -4.45) * CFrame.Angles(math.rad(-7), math.rad(180), 0), ARMOR); weld(head, muzzleCap)
	local jaw = angular(model, "Jaw", Vector3.new(4.45, 1.35, 3.5), ground * CFrame.new(0, 23.75, -4.1) * CFrame.Angles(math.rad(4), 0, 0), DARK); motor(head, "JawJoint", head, jaw, ground * CFrame.new(0, 24.15, -2.55))
	for _, sign in ipairs({-1, 1}) do
		local cheek = ellipsoid(f, sign < 0 and "LeftCheekMass" or "RightCheekMass", Vector3.new(1.8, 2.0, 2.8), ground * CFrame.new(sign * 2.1, 24.7, -2.85) * CFrame.Angles(0, sign * math.rad(14), 0), BODY); weld(head, cheek)
		local brow = wedge(f, sign < 0 and "LeftBrowPlate" or "RightBrowPlate", Vector3.new(1.65, 0.55, 1.4), ground * CFrame.new(sign * 1.45, 25.72, -4.25) * CFrame.Angles(math.rad(-7), math.rad(180), sign * math.rad(8)), ARMOR); weld(head, brow)
		local eye = ellipsoid(f, sign < 0 and "LeftEye_GeometryOnly" or "RightEye_GeometryOnly", Vector3.new(0.82, 0.58, 0.44), ground * CFrame.new(sign * 1.55, 25.38, -4.82), EYE); weld(head, eye)
		local a = Instance.new("Attachment"); a.Name = "EyeEnergy"; a.Parent = eye
		local vent = wedge(f, sign < 0 and "LeftBreathingVent" or "RightBreathingVent", Vector3.new(0.45, 0.85, 1.25), ground * CFrame.new(sign * 2.62, 24.38, -3.45) * CFrame.Angles(0, sign * math.rad(90), 0), ENERGY_REVIEW); weld(head, vent)
	end
	return head
end
local function buildCounterbalance(model: Model, geometry: Folder, pelvis: BasePart, ground: CFrame): {BasePart}
	local points = {Vector3.new(0, 15.5, 2.3), Vector3.new(0.4, 14.3, 4.9), Vector3.new(-0.45, 12.8, 7.2), Vector3.new(0.55, 11.0, 9.3), Vector3.new(-0.4, 9.0, 11.1), Vector3.new(0.3, 7.2, 12.5), Vector3.new(-0.2, 5.9, 13.6), Vector3.new(0, 5.0, 14.5)}
	local widths = {5.0, 4.55, 4.05, 3.5, 2.95, 2.4, 1.85}; local segments = {}; local host = pelvis
	for i = 1, #points - 1 do
		local s = cylinderBetween(model, string.format("TailCylinder_%02d", i), points[i], points[i + 1], widths[i], ground, BODY)
		motor(host, string.format("TailJoint_%02d", i), host, s, ground * CFrame.new(points[i])); table.insert(segments, s); host = s
	end
	local armor = Instance.new("Folder"); armor.Name = "CounterbalanceArmor"; armor.Parent = geometry
	for i, hostPart in ipairs(segments) do
		if i <= 4 then
			local midpoint = (points[i] + points[i + 1]) * 0.5
			local lift = widths[i] * 0.62
			local shieldCF = ground * CFrame.new(midpoint + Vector3.new(0, lift, 0.35)) * CFrame.Angles(math.rad(22), 0, math.rad(i % 2 == 0 and 7 or -7))
			local p = wedge(armor, "TailShield_" .. i, Vector3.new(1.0, 1.5 + (#segments - i) * 0.18, 1.8), shieldCF, ARMOR); weld(hostPart, p)
		end
	end
	return segments
end

local function addLayeredBody(geometry: Folder, torso: BasePart, pelvis: BasePart, ground: CFrame)
	local folder = Instance.new("Folder"); folder.Name = "LayeredBodyVolumes"; folder.Parent = geometry
	for _, spec in ipairs({
		{"LeftChestMass", Vector3.new(-3.05, 21.65, -1.15), Vector3.new(5.25, 6.45, 5.35), torso},
		{"RightChestMass", Vector3.new(3.05, 21.65, -1.15), Vector3.new(5.25, 6.45, 5.35), torso},
		{"UpperChestMass", Vector3.new(0, 23.35, -0.65), Vector3.new(8.25, 4.25, 5.7), torso},
		{"AbdomenMass", Vector3.new(0, 18.25, -0.7), Vector3.new(7.15, 4.75, 5.15), pelvis},
		{"LeftHipMass", Vector3.new(-2.65, 15.8, -0.2), Vector3.new(4.4, 4.7, 4.8), pelvis},
		{"RightHipMass", Vector3.new(2.65, 15.8, -0.2), Vector3.new(4.4, 4.7, 4.8), pelvis},
	}) do
		local p = ellipsoid(folder, spec[1] :: string, spec[3] :: Vector3, ground * CFrame.new(spec[2] :: Vector3), BODY); weld(spec[4] :: BasePart, p)
	end
	for index = 1, 5 do
		local y = 22.4 - index * 1.05
		local plate = ellipsoid(folder, "BellyBand_" .. index, Vector3.new(5.6 - index * 0.18, 0.72, 1.05), ground * CFrame.new(0, y, -3.0), BELLY)
		weld(index <= 3 and torso or pelvis, plate)
	end
end

local function addJointDefinition(geometry: Folder, ground: CFrame, torso: BasePart, pelvis: BasePart)
	local folder = Instance.new("Folder"); folder.Name = "AngularDefinition"; folder.Parent = geometry
	for _, sign in ipairs({-1, 1}) do
		local shoulder = wedge(folder, sign < 0 and "LeftShoulderEdge" or "RightShoulderEdge", Vector3.new(2.6, 2.0, 2.4), ground * CFrame.new(sign * 4.45, 22.0, -0.2) * CFrame.Angles(0, sign * math.rad(90), 0), ARMOR); weld(torso, shoulder)
		local chestEdge = wedge(folder, sign < 0 and "LeftChestEdge" or "RightChestEdge", Vector3.new(1.2, 3.8, 1.2), ground * CFrame.new(sign * 3.35, 20.8, -3.15) * CFrame.Angles(0, sign * math.rad(90), 0), ARMOR); weld(torso, chestEdge)
		local hip = wedge(folder, sign < 0 and "LeftHipEdge" or "RightHipEdge", Vector3.new(2.4, 1.8, 2.2), ground * CFrame.new(sign * 4.0, 16.0, 0) * CFrame.Angles(0, sign * math.rad(90), 0), ARMOR); weld(pelvis, hip)
	end
end

local function shatteredShield(folder: Folder, host: BasePart, index: number, pos: Vector3, scale: number, yaw: number, ground: CFrame)
	local assembly = Instance.new("Model"); assembly.Name = string.format("StormShield_%02d", index); assembly.Parent = folder
	-- Fan each plate around the vertical axis so front, side, rear, and three-quarter views see a face rather than only its thin edge.
	local faceYaw = yaw + (index % 2 == 0 and 32 or -32)
	local outwardPosition = pos + Vector3.new(0, 0, 1.45 + 0.35 * scale)
	local baseCF = ground * CFrame.new(outwardPosition) * CFrame.Angles(math.rad(28), math.rad(faceYaw), math.rad(index % 2 == 0 and 7 or -7))
	local center = wedge(assembly, "ShieldCore", Vector3.new(3.2 * scale, 3.65 * scale, 1.25 * scale), baseCF * CFrame.Angles(0, math.rad(180), 0), ARMOR); weld(host, center)
	local left = wedge(assembly, "BrokenLeft", Vector3.new(2.25 * scale, 2.65 * scale, 1.15 * scale), baseCF * CFrame.new(-1.65 * scale, -0.4 * scale, 0.12) * CFrame.Angles(0, math.rad(158), math.rad(-18)), ARMOR); weld(host, left)
	local right = wedge(assembly, "BrokenRight", Vector3.new(2.0 * scale, 3.0 * scale, 1.1 * scale), baseCF * CFrame.new(1.55 * scale, -0.25 * scale, 0.18) * CFrame.Angles(0, math.rad(202), math.rad(16)), ARMOR); weld(host, right)
	local crown = wedge(assembly, "BrokenCrown", Vector3.new(1.35 * scale, 1.45 * scale, 1.2 * scale), baseCF * CFrame.new((index % 2 == 0 and -0.7 or 0.75) * scale, 1.65 * scale, 0.08) * CFrame.Angles(0, math.rad(180), math.rad(index % 2 == 0 and -21 or 21)), DARK); weld(host, crown)
	for seamIndex, seamX in ipairs({-0.55, 0.5}) do
		local seam = wedge(assembly, "EnergyFissure_" .. seamIndex, Vector3.new(0.22 * scale, 2.5 * scale, 0.22 * scale), baseCF * CFrame.new(seamX * scale, -0.15 * scale, 0.72 * scale) * CFrame.Angles(0, 0, math.rad(seamIndex == 1 and -16 or 14)), ENERGY_REVIEW)
		seam.Material = Enum.Material.Neon; weld(host, seam)
	end
	local a = Instance.new("Attachment"); a.Name = string.format("DorsalEnergy_%02d", index); a.Parent = center; assembly.PrimaryPart = center
end
local function build(target: Instance, ground: CFrame): Model
	local model = Instance.new("Model"); model.Name = Specification.ModelName; model.Parent = target
	model:SetAttribute("AssetName", Specification.AssetName); model:SetAttribute("AssetId", Specification.AssetId)
	model:SetAttribute("PipelinePhase", 4); model:SetAttribute("PipelineStatus", "AWAITING_GEOMETRY_APPROVAL")
	model:SetAttribute("QualityGateA", "Approved"); model:SetAttribute("QualityGateB", "Pending"); model:SetAttribute("GeometryOnly", true)
	model:SetAttribute("EvolutionStage", 1); model:SetAttribute("EvolutionName", "Bound Chimera"); model:SetAttribute("DesignVersion", "2.5.2")
	model:SetAttribute("UprightDominant", true); model:SetAttribute("DigitigradeLegs", true); model:SetAttribute("DorsalShieldCount", 7)
	model:SetAttribute("ForwardClawsPerFoot", 3); model:SetAttribute("RearClawsPerFoot", 1); model:SetAttribute("DressingDeferredToPhase", 5)
	local geometry = detailFolder(model)
	local root = part(model, "HumanoidRootPart", Vector3.new(3, 3, 2), ground * CFrame.new(0, 14.8, 0), Color3.new(1,1,1)); root.Transparency = 1; root.Anchored = true; root.Massless = false; model.PrimaryPart = root
	local pelvis = ellipsoid(model, "LowerTorso", Vector3.new(8.4, 5.9, 5.8), ground * CFrame.new(0, 16.15, 0.35) * CFrame.Angles(math.rad(2), 0, 0), BODY); motor(root, "Root", root, pelvis, ground * CFrame.new(0, 14.9, 0))
	local torso = ellipsoid(model, "UpperTorso", Vector3.new(10.1, 8.0, 6.8), ground * CFrame.new(0, 21.25, -0.05) * CFrame.Angles(math.rad(-3), 0, 0), BODY); motor(pelvis, "Waist", pelvis, torso, ground * CFrame.new(0, 18.6, 0.1))
	addLayeredBody(geometry, torso, pelvis, ground)
	addJointDefinition(geometry, ground, torso, pelvis)
	local chest = wedge(geometry, "CentralChestKeel", Vector3.new(2.6, 2.9, 0.65), ground * CFrame.new(0, 21.45, -3.45) * CFrame.Angles(0, math.rad(180), 0), ARMOR); weld(torso, chest)
	local head = buildHead(model, geometry, torso, ground)
	buildArm(model, geometry, "Left", -1, torso, ground); buildArm(model, geometry, "Right", 1, torso, ground)
	for _, data in ipairs({{"Left", -1}, {"Right", 1}}) do
		local side, sign = data[1] :: string, data[2] :: number; local x = sign * 3.45
		local hip, knee, hock = Vector3.new(x, 15.8, 0.35), Vector3.new(x, 10.65, -1.65), Vector3.new(x, 6.0, 1.55)
		local upper = segment(model, side .. "UpperLeg", hip, knee, 5.25, 4.8, ground, BODY); motor(pelvis, side .. "Hip", pelvis, upper, ground * CFrame.new(hip))
		local lower = segment(model, side .. "LowerLeg", knee, hock, 4.75, 4.3, ground, BODY); motor(upper, side .. "Knee", upper, lower, ground * CFrame.new(knee))
		local thighMass = ellipsoid(geometry, side .. "ThighMass", Vector3.new(5.75, 5.85, 5.2), ground * CFrame.new((hip + knee) * 0.5 + Vector3.new(0, 0.35, 0.1)), BODY); weld(upper, thighMass)
		local calfMass = ellipsoid(geometry, side .. "CalfMass", Vector3.new(5.1, 5.15, 4.55), ground * CFrame.new((knee + hock) * 0.5 + Vector3.new(0, -0.05, 0.2)), BODY); weld(lower, calfMass)
		local hockMass = ellipsoid(geometry, side .. "HockMass", Vector3.new(4.7, 3.6, 4.4), ground * CFrame.new(hock + Vector3.new(0, 0.15, 0.1)), BODY); weld(lower, hockMass)
		-- The kneecap is a compact inset plane following the forward bend, not a detached spike.
		local kneeEdge = wedge(geometry, side .. "KneeEdge", Vector3.new(1.85, 0.95, 1.25), ground * CFrame.new(knee + Vector3.new(0, 0.12, -0.82)) * CFrame.Angles(math.rad(-8), math.rad(180), 0), ARMOR); weld(lower, kneeEdge)
		buildFoot(model, geometry, side, sign, lower, ground)
	end
	local rudder = buildCounterbalance(model, geometry, pelvis, ground)
	local dorsals = Instance.new("Folder"); dorsals.Name = "DorsalPlates"; dorsals.Parent = geometry
	local specs = {
		{head, Vector3.new(0, 27.1, 1.0), 0.7, -34}, {torso, Vector3.new(0, 24.55, 2.55), 0.88, 30},
		{torso, Vector3.new(0, 21.8, 3.05), 1.08, -27}, {torso, Vector3.new(0, 18.9, 3.1), 1.2, 24},
		{pelvis, Vector3.new(0, 16.05, 3.15), 1.02, -22}, {pelvis, Vector3.new(0, 13.35, 3.55), 0.82, 20},
		{rudder[1], Vector3.new(0, 10.95, 6.65), 0.64, -18},
	}
	for i, d in ipairs(specs) do shatteredShield(dorsals, d[1] :: BasePart, i, d[2] :: Vector3, d[3] :: number, d[4] :: number, ground) end
	local hitboxes = Instance.new("Folder"); hitboxes.Name = "Hitboxes_GeometryReviewOnly"; hitboxes.Parent = model
	local bodyHit = part(hitboxes, "BodyHitbox", Vector3.new(9, 14, 7), ground * CFrame.new(0, 17, 0), Color3.fromRGB(255,0,255)); bodyHit.Transparency = 1; weld(root, bodyHit)
	local rearHit = part(hitboxes, "CounterbalanceHitbox", Vector3.new(6, 6, 14), ground * CFrame.new(0, 9, 8.7) * CFrame.Angles(math.rad(-30),0,0), Color3.fromRGB(255,0,255)); rearHit.Transparency = 1; weld(root, rearHit)
	local humanoid = Instance.new("Humanoid"); humanoid.Name = "Humanoid"; humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None; humanoid.AutoRotate = false; humanoid.BreakJointsOnDeath = false; humanoid.Parent = model
	local animator = Instance.new("Animator"); animator.Parent = humanoid
	local review = Instance.new("Configuration"); review.Name = "GeometryReviewContract"; review.Parent = model
	review:SetAttribute("CheckUprightNotHunched", true); review:SetAttribute("CheckOriginalChimeraSilhouette", true); review:SetAttribute("CheckShatteredStormShields", true); review:SetAttribute("RejectMushroomShellDorsals", true); review:SetAttribute("CheckThreeForwardOneRearClaw", true); review:SetAttribute("CheckMassiveDigitigradeLegs", true)
	return model
end

function Builder.Validate(model: Model): (boolean, {string})
	local issues = {}; local function check(ok: boolean, message: string) if not ok then table.insert(issues, message) end end
	check(model:GetAttribute("PipelinePhase") == 4, "PipelinePhase must be 4")
	for _, name in ipairs({"HumanoidRootPart","LowerTorso","UpperTorso","Head","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot"}) do check(model:FindFirstChild(name) ~= nil, name .. " missing") end
	local geometry = model:FindFirstChild("BodyGeometry"); check(geometry ~= nil, "BodyGeometry missing")
	if geometry then
		local dorsal = geometry:FindFirstChild("DorsalPlates"); check(dorsal ~= nil and #dorsal:GetChildren() == 7, "Exactly 7 storm shields required")
		for _, side in ipairs({"Left", "Right"}) do
			local foot = geometry:FindFirstChild(side .. "FootGeometry"); check(foot ~= nil, side .. "FootGeometry missing")
			if foot then for i = 1, 3 do check(foot:FindFirstChild("ForwardClaw_" .. i) ~= nil, side .. " forward claw missing") end; check(foot:FindFirstChild("RearClaw") ~= nil, side .. " rear claw missing") end
		end
	end
	local visible, hitbox = 0, 0
	for _, d in ipairs(model:GetDescendants()) do
		check(not (d:IsA("ParticleEmitter") or d:IsA("Light") or d:IsA("Sound")), d.ClassName .. " deferred to later phase")
		if d:IsA("BasePart") then if d.Transparency < 1 then visible += 1 end; if d:FindFirstAncestor("Hitboxes_GeometryReviewOnly") then hitbox += 1 end end
	end
	model:SetAttribute("VisiblePartCount", visible); model:SetAttribute("GameplayHitboxCount", hitbox)
	check(visible <= Specification.PerformanceBudget.MaxVisibleParts, "Visible part budget exceeded"); check(hitbox <= Specification.PerformanceBudget.MaxGameplayHitboxes, "Hitbox budget exceeded")
	return #issues == 0, issues
end

function Builder.Build(target: Instance, config: BuildConfig?): Model
	local existing = target:FindFirstChild(Specification.ModelName); if existing then existing:Destroy() end
	local model = build(target, (config and config.GroundCFrame) or CFrame.identity)
	local valid, issues = Builder.Validate(model); if not valid then for _, issue in ipairs(issues) do warn("[Bound Chimera] " .. issue) end; error("Bound Chimera failed validation") end
	print("[Bound Chimera] Phase 4 Golden Master built | Awaiting Quality Gate B"); return model
end

return Builder
