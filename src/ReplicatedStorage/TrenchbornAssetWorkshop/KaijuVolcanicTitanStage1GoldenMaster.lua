--!strict
-- Kaiju-I Primal Beast | Phase 4 geometry-only Golden Master
local Builder = {}
local Specification = require(script.Parent:WaitForChild("KaijuVolcanicTitanSpecification"))
local AssetService = game:GetService("AssetService")

local HIDE = Color3.fromRGB(48, 52, 43)
local HIDE_DARK = Color3.fromRGB(29, 33, 29)
local HIDE_LIGHT = Color3.fromRGB(64, 68, 54)
local VOLCANIC = Color3.fromRGB(35, 38, 34)
local BONE = Color3.fromRGB(137, 128, 96)
local ENERGY = Color3.fromRGB(214, 205, 46)
local EYE = Color3.fromRGB(255, 225, 38)

type BuildConfig = { GroundCFrame: CFrame? }

local function defaults(p: BasePart)
	p.Anchored = false
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.CastShadow = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
end

local function block(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	defaults(p)
	p.Parent = parent
	return p
end

local editableMeshAvailable = true
local organicVariant = 0

local function draftOrganicMesh(size: Vector3): MeshPart?
	if not editableMeshAvailable then return nil end
	local ok, result = pcall(function()
		local mesh = AssetService:CreateEditableMesh()
		local rings = 5
		local sides = 10
		local vertices = {}
		local bottom = mesh:AddVertex(Vector3.new(0, -size.Y * 0.5, 0))
		for ring = 1, rings do
			local latitude = -math.pi * 0.5 + math.pi * ring / (rings + 1)
			vertices[ring] = {}
			for side = 1, sides do
				local longitude = math.pi * 2 * (side - 1) / sides
				local stagger = ((ring * 7 + side * 3 + organicVariant) % 5 - 2) * 0.025
				local radius = math.cos(latitude) * (1 + stagger)
				vertices[ring][side] = mesh:AddVertex(Vector3.new(
					math.cos(longitude) * radius * size.X * 0.5,
					math.sin(latitude) * size.Y * 0.5,
					math.sin(longitude) * radius * size.Z * 0.5
				))
			end
		end
		local top = mesh:AddVertex(Vector3.new(0, size.Y * 0.5, 0))
		for side = 1, sides do
			local nextSide = side % sides + 1
			mesh:AddTriangle(bottom, vertices[1][nextSide], vertices[1][side])
			for ring = 1, rings - 1 do
				local a = vertices[ring][side]
				local b = vertices[ring][nextSide]
				local c = vertices[ring + 1][side]
				local d = vertices[ring + 1][nextSide]
				mesh:AddTriangle(a, b, c)
				mesh:AddTriangle(b, d, c)
			end
			mesh:AddTriangle(vertices[rings][side], vertices[rings][nextSide], top)
		end
		local part = AssetService:CreateMeshPartAsync(Content.fromObject(mesh), {
			CollisionFidelity = Enum.CollisionFidelity.Hull,
		})
		mesh:Destroy()
		return part
	end)
	if not ok then
		editableMeshAvailable = false
		warn("[Primal Beast] EditableMesh unavailable; using organic Part fallback: " .. tostring(result))
		return nil
	end
	return result :: MeshPart
end

local function ellipsoid(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): BasePart
	organicVariant += 1
	local p = draftOrganicMesh(size)
	if p then
		p.Name = name
		p.Size = size
		p.CFrame = cf
		p.Color = color
		p.Material = Enum.Material.Slate
		defaults(p)
		p:SetAttribute("DraftGeometry", "FacetedEditableMesh")
		p.Parent = parent
		return p
	end
	local fallback = block(parent, name, size, cf, color, Enum.Material.Slate)
	local mesh = Instance.new("SpecialMesh")
	mesh.Name = "DraftOrganicMeshFallback"
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = fallback
	return fallback
end

local function wedge(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?): WedgePart
	local p = Instance.new("WedgePart")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.Slate
	defaults(p)
	p.Parent = parent
	return p
end

local function weld(host: BasePart, child: BasePart)
	local joint = Instance.new("WeldConstraint")
	joint.Name = child.Name .. "Weld"
	joint.Part0 = host
	joint.Part1 = child
	joint.Parent = child
end

local function motor(parent: Instance, name: string, a: BasePart, b: BasePart, world: CFrame)
	local joint = Instance.new("Motor6D")
	joint.Name = name
	joint.Part0 = a
	joint.Part1 = b
	joint.C0 = a.CFrame:ToObjectSpace(world)
	joint.C1 = b.CFrame:ToObjectSpace(world)
	joint.Parent = parent
end

local function segment(parent: Instance, name: string, a: Vector3, b: Vector3, width: number, depth: number, ground: CFrame, color: Color3): Part
	local worldA = ground:PointToWorldSpace(a)
	local worldB = ground:PointToWorldSpace(b)
	local delta = worldB - worldA
	local center = (worldA + worldB) * 0.5
	return ellipsoid(parent, name, Vector3.new(width, depth, delta.Magnitude), CFrame.lookAt(center, center + delta), color)
end

local function cylinderBetween(parent: Instance, name: string, a: Vector3, b: Vector3, diameter: number, ground: CFrame): Part
	local worldA = ground:PointToWorldSpace(a)
	local worldB = ground:PointToWorldSpace(b)
	local delta = worldB - worldA
	local center = (worldA + worldB) * 0.5
	local p = block(parent, name, Vector3.new(delta.Magnitude, diameter, diameter), CFrame.lookAt(center, center + delta) * CFrame.Angles(0, math.rad(90), 0), HIDE, Enum.Material.Slate)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function addClaw(parent: Instance, host: BasePart, name: string, position: Vector3, rotation: CFrame, size: Vector3, ground: CFrame)
	local claw = wedge(parent, name, size, ground * CFrame.new(position) * rotation, BONE, Enum.Material.SmoothPlastic)
	weld(host, claw)
	return claw
end

local function buildFoot(model: Model, geometry: Folder, side: string, sign: number, lowerLeg: BasePart, ground: CFrame): BasePart
	local x = sign * 3.5
	local hock = Vector3.new(x, 5.3, 1.45)
	local toeBase = Vector3.new(x, 1.45, -1.05)
	local foot = segment(model, side .. "Foot", hock, toeBase, 4.7, 4.0, ground, HIDE)
	motor(lowerLeg, side .. "Ankle", lowerLeg, foot, ground * CFrame.new(hock))

	local folder = Instance.new("Folder")
	folder.Name = side .. "FootGeometry"
	folder.Parent = geometry

	local bridge = ellipsoid(folder, "BroadFootBridge", Vector3.new(5.1, 2.3, 5.0), ground * CFrame.new(x, 1.45, -1.35) * CFrame.Angles(math.rad(-8), 0, 0), HIDE_DARK)
	weld(foot, bridge)

	for index, offset in ipairs({-1.45, 0, 1.45}) do
		local toe = ellipsoid(folder, "ForwardToe_" .. index, Vector3.new(1.45, 1.15, 3.5), ground * CFrame.new(x + offset, 0.82, -2.65), HIDE_DARK)
		weld(foot, toe)
		addClaw(folder, toe, "ForwardClaw_" .. index, Vector3.new(x + offset, 0.45, -4.65), CFrame.Angles(math.rad(-18), 0, 0), Vector3.new(0.72, 0.85, 1.75), ground)
	end

	local rearX = x + sign * 1.7
	local rearToe = ellipsoid(folder, "RearToe", Vector3.new(1.15, 1.0, 1.8), ground * CFrame.new(rearX, 1.72, 1.55) * CFrame.Angles(math.rad(15), 0, 0), HIDE_DARK)
	weld(foot, rearToe)
	addClaw(folder, rearToe, "RearClaw", Vector3.new(rearX, 1.65, 2.95), CFrame.Angles(math.rad(18), math.rad(180), 0), Vector3.new(0.65, 0.78, 1.55), ground)
	return foot
end

local function buildHand(model: Model, geometry: Folder, side: string, sign: number, lowerArm: BasePart, wrist: Vector3, ground: CFrame): BasePart
	local hand = ellipsoid(model, side .. "Hand", Vector3.new(3.7, 2.9, 3.3), ground * CFrame.new(wrist + Vector3.new(0, -0.7, -0.15)), HIDE_DARK)
	motor(lowerArm, side .. "Wrist", lowerArm, hand, ground * CFrame.new(wrist))
	local folder = Instance.new("Folder")
	folder.Name = side .. "HandGeometry"
	folder.Parent = geometry

	for index, offset in ipairs({-0.95, 0, 0.95}) do
		local digit = ellipsoid(folder, "PrimaryDigit_" .. index, Vector3.new(0.9, 1.5, 1.25), ground * CFrame.new(wrist.X + offset, wrist.Y - 1.7, wrist.Z - 0.45), HIDE_DARK)
		weld(hand, digit)
		addClaw(folder, digit, "HandClaw_" .. index, Vector3.new(wrist.X + offset, wrist.Y - 2.85, wrist.Z - 0.48), CFrame.Angles(math.rad(-90), 0, 0), Vector3.new(0.62, 0.7, 1.45), ground)
	end

	local sideDigitX = wrist.X + sign * 1.65
	local sideDigit = ellipsoid(folder, "SideGripDigit", Vector3.new(0.85, 1.2, 1.1), ground * CFrame.new(sideDigitX, wrist.Y - 1.25, wrist.Z - 0.2) * CFrame.Angles(0, 0, sign * math.rad(25)), HIDE_DARK)
	weld(hand, sideDigit)
	addClaw(folder, sideDigit, "SideGripClaw", Vector3.new(sideDigitX + sign * 0.25, wrist.Y - 2.1, wrist.Z - 0.25), CFrame.Angles(math.rad(-90), 0, sign * math.rad(18)), Vector3.new(0.5, 0.58, 1.05), ground)
	return hand
end

local function buildArm(model: Model, geometry: Folder, torso: BasePart, side: string, sign: number, ground: CFrame)
	local shoulder = Vector3.new(sign * 6.65, 21.9, -0.05)
	local elbow = Vector3.new(sign * 7.75, 17.6, -0.35)
	local wrist = Vector3.new(sign * 7.9, 13.55, -0.7)
	local upper = segment(model, side .. "UpperArm", shoulder, elbow, 3.2, 3.0, ground, HIDE)
	motor(torso, side .. "Shoulder", torso, upper, ground * CFrame.new(shoulder))
	local lower = segment(model, side .. "LowerArm", elbow, wrist, 3.1, 2.8, ground, HIDE)
	motor(upper, side .. "Elbow", upper, lower, ground * CFrame.new(elbow))

	local deltoid = ellipsoid(geometry, side .. "DeltoidMass", Vector3.new(4.0, 4.2, 3.7), ground * CFrame.new(shoulder + Vector3.new(0, -0.6, 0)), HIDE)
	weld(upper, deltoid)
	local forearm = ellipsoid(geometry, side .. "ForearmMass", Vector3.new(3.6, 4.2, 3.3), ground * CFrame.new((elbow + wrist) * 0.5), HIDE)
	weld(lower, forearm)

	local elbowPlane = wedge(geometry, side .. "ElbowDefinition", Vector3.new(1.0, 0.75, 1.15), ground * CFrame.new(elbow + Vector3.new(0, 0.05, -0.55)) * CFrame.Angles(0, math.rad(180), 0), VOLCANIC)
	weld(lower, elbowPlane)
	buildHand(model, geometry, side, sign, lower, wrist, ground)
end

local function buildHead(model: Model, geometry: Folder, torso: BasePart, ground: CFrame): BasePart
	local head = ellipsoid(model, "Head", Vector3.new(6.9, 4.4, 6.5), ground * CFrame.new(0, 26.25, -1.35) * CFrame.Angles(math.rad(-3), 0, 0), HIDE)
	motor(torso, "Neck", torso, head, ground * CFrame.new(0, 24.0, 0.15))
	local folder = Instance.new("Folder")
	folder.Name = "HeadGeometry"
	folder.Parent = geometry

	local neck = ellipsoid(folder, "ThickNeckMantle", Vector3.new(7.5, 5.4, 5.9), ground * CFrame.new(0, 24.0, 0.45) * CFrame.Angles(math.rad(-8), 0, 0), HIDE)
	weld(head, neck)

	local upperMuzzle = block(folder, "UpperMuzzle", Vector3.new(5.7, 1.5, 4.25), ground * CFrame.new(0, 25.85, -4.95) * CFrame.Angles(math.rad(-3), 0, 0), HIDE_DARK, Enum.Material.Slate)
	weld(head, upperMuzzle)
	local muzzleBridge = ellipsoid(folder, "MuzzleBridge", Vector3.new(5.0, 1.45, 3.45), ground * CFrame.new(0, 26.45, -4.1), HIDE)
	weld(head, muzzleBridge)

	local jaw = block(model, "Jaw", Vector3.new(5.6, 1.75, 4.7), ground * CFrame.new(0, 24.25, -5.15) * CFrame.Angles(math.rad(7), 0, 0), HIDE_DARK, Enum.Material.Slate)
	motor(head, "JawJoint", head, jaw, ground * CFrame.new(0, 25.45, -2.95))

	for _, sign in ipairs({-1, 1}) do
		local cheek = ellipsoid(folder, sign < 0 and "LeftCheekMass" or "RightCheekMass", Vector3.new(1.7, 2.1, 3.3), ground * CFrame.new(sign * 2.65, 25.75, -3.0), HIDE)
		weld(head, cheek)
		local brow = wedge(folder, sign < 0 and "LeftHeavyBrow" or "RightHeavyBrow", Vector3.new(2.0, 0.7, 1.6), ground * CFrame.new(sign * 1.55, 27.0, -4.45) * CFrame.Angles(math.rad(-5), math.rad(180), sign * math.rad(10)), VOLCANIC)
		weld(head, brow)
		local eye = ellipsoid(folder, sign < 0 and "LeftEye" or "RightEye", Vector3.new(0.72, 0.52, 0.4), ground * CFrame.new(sign * 1.6, 26.75, -4.95), EYE)
		weld(head, eye)
	end

	for index, x in ipairs({-1.55, -0.5, 0.5, 1.55}) do
		local tooth = wedge(folder, "UpperTooth_" .. index, Vector3.new(0.42, 0.65, 0.55), ground * CFrame.new(x, 25.3, -6.1) * CFrame.Angles(math.rad(-90), 0, 0), BONE, Enum.Material.SmoothPlastic)
		weld(head, tooth)
	end
	return head
end

local function buildTail(model: Model, geometry: Folder, pelvis: BasePart, ground: CFrame): {BasePart}
	local points = {
		Vector3.new(0, 15.0, 2.2), Vector3.new(0.25, 13.9, 5.2), Vector3.new(-0.3, 12.5, 8.0),
		Vector3.new(0.35, 10.8, 10.6), Vector3.new(-0.25, 8.9, 12.8), Vector3.new(0.2, 7.2, 14.7),
		Vector3.new(-0.15, 5.9, 16.2), Vector3.new(0.1, 5.0, 17.4), Vector3.new(0, 4.4, 18.35),
	}
	local widths = {5.4, 5.0, 4.5, 3.95, 3.35, 2.75, 2.15, 1.55}
	local segments = {}
	local host = pelvis
	for index = 1, #points - 1 do
		local segmentPart = cylinderBetween(model, string.format("TailCylinder_%02d", index), points[index], points[index + 1], widths[index], ground)
		motor(host, string.format("TailJoint_%02d", index), host, segmentPart, ground * CFrame.new(points[index]))
		table.insert(segments, segmentPart)
		host = segmentPart
	end

	local armor = Instance.new("Folder")
	armor.Name = "TailDorsalPlates"
	armor.Parent = geometry
	for index = 1, 4 do
		local midpoint = (points[index + 1] + points[index + 2]) * 0.5
		local lift = widths[index + 1] * 0.62 + 1.2
		local plate = wedge(armor, "TailPlate_" .. index, Vector3.new(1.2, 2.4 - index * 0.22, 2.2), ground * CFrame.new(midpoint + Vector3.new(0, lift, 0.25)) * CFrame.Angles(math.rad(24), 0, math.rad(index % 2 == 0 and 5 or -5)), VOLCANIC)
		weld(segments[index + 1], plate)
	end
	return segments
end

local function buildPrimaryDorsals(geometry: Folder, head: BasePart, torso: BasePart, pelvis: BasePart, tail: {BasePart}, ground: CFrame)
	local folder = Instance.new("Folder")
	folder.Name = "DorsalPlates"
	folder.Parent = geometry
	local specs = {
		{head, Vector3.new(0, 28.3, 1.8), Vector3.new(2.5, 3.1, 1.25), -4},
		{torso, Vector3.new(0, 25.0, 3.1), Vector3.new(3.2, 4.1, 1.5), 5},
		{torso, Vector3.new(0, 21.0, 3.75), Vector3.new(3.7, 5.0, 1.7), -5},
		{pelvis, Vector3.new(0, 17.0, 3.5), Vector3.new(3.5, 4.6, 1.65), 5},
		{tail[1], Vector3.new(0, 13.5, 5.5), Vector3.new(2.8, 3.5, 1.4), -4},
	}
	for index, spec in ipairs(specs) do
		local assembly = Instance.new("Model")
		assembly.Name = string.format("PrimaryPlate_%02d", index)
		assembly.Parent = folder
		local host = spec[1] :: BasePart
		local position = spec[2] :: Vector3
		local size = spec[3] :: Vector3
		local roll = spec[4] :: number
		local base = wedge(assembly, "VolcanicSlab", size, ground * CFrame.new(position) * CFrame.Angles(math.rad(18), math.rad(180), math.rad(roll)), VOLCANIC)
		weld(host, base)
		local brokenTip = wedge(assembly, "BrokenTip", Vector3.new(size.X * 0.55, size.Y * 0.42, size.Z * 0.9), ground * CFrame.new(position + Vector3.new((index % 2 == 0 and -0.45 or 0.45), size.Y * 0.48, 0.05)) * CFrame.Angles(math.rad(18), math.rad(180), math.rad(-roll * 1.8)), HIDE_DARK)
		weld(host, brokenTip)
		local fissure = wedge(assembly, "FaintEnergyFissure", Vector3.new(0.18, size.Y * 0.55, 0.2), ground * CFrame.new(position + Vector3.new(0, -0.1, -size.Z * 0.48)) * CFrame.Angles(math.rad(18), 0, math.rad(roll)), ENERGY, Enum.Material.SmoothPlastic)
		weld(host, fissure)
		assembly.PrimaryPart = base
	end
end

local function build(target: Instance, ground: CFrame): Model
	local model = Instance.new("Model")
	model.Name = Specification.ModelName
	model.Parent = target
	model:SetAttribute("AssetName", Specification.AssetName)
	model:SetAttribute("AssetId", Specification.AssetId)
	model:SetAttribute("PipelinePhase", 4)
	model:SetAttribute("PipelineStatus", "AWAITING_GEOMETRY_APPROVAL")
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("GeometryOnly", true)
	model:SetAttribute("EvolutionStage", 1)
	model:SetAttribute("EvolutionName", "Primal Beast")
	model:SetAttribute("DesignVersion", "3.1.0")
	model:SetAttribute("TargetHeightStuds", 30)
	model:SetAttribute("DorsalPlateCount", 5)
	model:SetAttribute("TailDorsalPlateCount", 4)
	model:SetAttribute("DraftMeshStrategy", "FacetedEditableMeshWithPartFallback")
	model:SetAttribute("FinalTexturesDeferredToPhase", 5)

	local geometry = Instance.new("Folder")
	geometry.Name = "BodyGeometry"
	geometry.Parent = model

	local root = block(model, "HumanoidRootPart", Vector3.new(3, 3, 2), ground * CFrame.new(0, 14.8, 0), Color3.new(1, 1, 1))
	root.Transparency = 1
	root.Anchored = true
	root.Massless = false
	model.PrimaryPart = root

	local pelvis = ellipsoid(model, "LowerTorso", Vector3.new(9.2, 6.4, 6.5), ground * CFrame.new(0, 16.0, 0.35), HIDE)
	motor(root, "Root", root, pelvis, ground * CFrame.new(0, 14.8, 0))

	local torso = ellipsoid(model, "UpperTorso", Vector3.new(11.4, 8.8, 7.7), ground * CFrame.new(0, 21.1, -0.05), HIDE)
	motor(pelvis, "Waist", pelvis, torso, ground * CFrame.new(0, 18.0, 0.1))

	for _, data in ipairs({
		{"LeftPectoral", Vector3.new(-2.8, 22.1, -2.2), Vector3.new(5.7, 5.0, 3.8)},
		{"RightPectoral", Vector3.new(2.8, 22.1, -2.2), Vector3.new(5.7, 5.0, 3.8)},
		{"UpperBackMass", Vector3.new(0, 22.6, 1.6), Vector3.new(9.0, 4.8, 4.6)},
		{"AbdomenMass", Vector3.new(0, 18.0, -1.0), Vector3.new(7.6, 4.6, 4.8)},
	}) do
		local mass = ellipsoid(geometry, data[1] :: string, data[3] :: Vector3, ground * CFrame.new(data[2] :: Vector3), data[1] == "AbdomenMass" and HIDE_LIGHT or HIDE)
		weld(data[1] == "AbdomenMass" and pelvis or torso, mass)
	end

	local sternum = wedge(geometry, "SmallVolcanicSternum", Vector3.new(1.7, 2.5, 0.6), ground * CFrame.new(0, 21.3, -4.0) * CFrame.Angles(0, math.rad(180), 0), VOLCANIC)
	weld(torso, sternum)
	local sternumFissure = wedge(geometry, "SternumFaintFissure", Vector3.new(0.16, 1.6, 0.16), ground * CFrame.new(0, 21.25, -4.32), ENERGY, Enum.Material.SmoothPlastic)
	weld(torso, sternumFissure)

	local head = buildHead(model, geometry, torso, ground)
	buildArm(model, geometry, torso, "Left", -1, ground)
	buildArm(model, geometry, torso, "Right", 1, ground)

	for _, data in ipairs({{"Left", -1}, {"Right", 1}}) do
		local side = data[1] :: string
		local sign = data[2] :: number
		local x = sign * 3.5
		local hip = Vector3.new(x, 15.8, 0.2)
		local knee = Vector3.new(x, 10.3, -1.65)
		local hock = Vector3.new(x, 5.3, 1.45)
		local upper = segment(model, side .. "UpperLeg", hip, knee, 5.8, 5.4, ground, HIDE)
		motor(pelvis, side .. "Hip", pelvis, upper, ground * CFrame.new(hip))
		local lower = segment(model, side .. "LowerLeg", knee, hock, 5.1, 4.7, ground, HIDE)
		motor(upper, side .. "Knee", upper, lower, ground * CFrame.new(knee))
		local thigh = ellipsoid(geometry, side .. "ThighMass", Vector3.new(6.2, 6.4, 5.6), ground * CFrame.new((hip + knee) * 0.5 + Vector3.new(0, 0.25, 0.1)), HIDE)
		weld(upper, thigh)
		local calf = ellipsoid(geometry, side .. "CalfMass", Vector3.new(5.5, 5.7, 5.0), ground * CFrame.new((knee + hock) * 0.5), HIDE)
		weld(lower, calf)
		local hockMass = ellipsoid(geometry, side .. "HockMass", Vector3.new(4.9, 3.8, 4.5), ground * CFrame.new(hock), HIDE)
		weld(lower, hockMass)
		local kneePlate = wedge(geometry, side .. "MinorKneeHardening", Vector3.new(1.9, 1.0, 1.25), ground * CFrame.new(knee + Vector3.new(0, 0.05, -0.9)) * CFrame.Angles(math.rad(-8), math.rad(180), 0), VOLCANIC)
		weld(lower, kneePlate)
		buildFoot(model, geometry, side, sign, lower, ground)
	end

	local tail = buildTail(model, geometry, pelvis, ground)
	buildPrimaryDorsals(geometry, head, torso, pelvis, tail, ground)

	local hitboxes = Instance.new("Folder")
	hitboxes.Name = "Hitboxes_GeometryReviewOnly"
	hitboxes.Parent = model
	local bodyHitbox = block(hitboxes, "BodyHitbox", Vector3.new(11, 15, 8), ground * CFrame.new(0, 17.5, 0), Color3.fromRGB(255, 0, 255))
	bodyHitbox.Transparency = 1
	weld(root, bodyHitbox)
	local tailHitbox = block(hitboxes, "TailHitbox", Vector3.new(6, 7, 17), ground * CFrame.new(0, 9.5, 9.5) * CFrame.Angles(math.rad(-28), 0, 0), Color3.fromRGB(255, 0, 255))
	tailHitbox.Transparency = 1
	weld(root, tailHitbox)

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.AutoRotate = false
	humanoid.BreakJointsOnDeath = false
	humanoid.HipHeight = 4.2
	humanoid.Parent = model
	Instance.new("Animator", humanoid)

	local review = Instance.new("Configuration")
	review.Name = "GeometryReviewContract"
	review:SetAttribute("CheckTargetHeight30Studs", true)
	review:SetAttribute("CheckUprightS1", true)
	review:SetAttribute("CheckK2PredatorHead", true)
	review:SetAttribute("CheckLongPowerfulArms", true)
	review:SetAttribute("CheckMassiveDigitigradeLegs", true)
	review:SetAttribute("CheckThreeForwardOneRearClaw", true)
	review:SetAttribute("CheckFivePrimaryDorsals", true)
	review:SetAttribute("CheckFourTailDorsals", true)
	review:SetAttribute("CheckSegmentedCylinderTail", true)
	review.Parent = model
	return model
end

function Builder.Validate(model: Model): (boolean, {string})
	local issues = {}
	local function check(ok: boolean, message: string)
		if not ok then table.insert(issues, message) end
	end
	check(model:GetAttribute("EvolutionStage") == 1, "EvolutionStage must be 1")
	check(model:GetAttribute("PipelinePhase") == 4, "PipelinePhase must be 4")
	for _, name in ipairs({
		"HumanoidRootPart", "LowerTorso", "UpperTorso", "Head", "Jaw",
		"LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand",
		"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot",
	}) do
		check(model:FindFirstChild(name) ~= nil, name .. " missing")
	end
	local geometry = model:FindFirstChild("BodyGeometry")
	check(geometry ~= nil, "BodyGeometry missing")
	if geometry then
		local dorsals = geometry:FindFirstChild("DorsalPlates")
		local tailDorsals = geometry:FindFirstChild("TailDorsalPlates")
		check(dorsals ~= nil and #dorsals:GetChildren() == 5, "Exactly 5 primary dorsal assemblies required")
		check(tailDorsals ~= nil and #tailDorsals:GetChildren() == 4, "Exactly 4 tail dorsal assemblies required")
		for _, side in ipairs({"Left", "Right"}) do
			local foot = geometry:FindFirstChild(side .. "FootGeometry")
			check(foot ~= nil, side .. "FootGeometry missing")
			if foot then
				for index = 1, 3 do
					check(foot:FindFirstChild("ForwardClaw_" .. index) ~= nil, side .. " forward claw " .. index .. " missing")
				end
				check(foot:FindFirstChild("RearClaw") ~= nil, side .. " rear claw missing")
			end
		end
	end
	local visibleParts = 0
	local hitboxParts = 0
	for _, descendant in ipairs(model:GetDescendants()) do
		check(not descendant:IsA("Light"), "Lights are deferred to Phase 5")
		check(not descendant:IsA("ParticleEmitter"), "Particles are deferred to Phase 5")
		if descendant:IsA("BasePart") then
			if descendant.Transparency < 1 then visibleParts += 1 end
			if descendant:FindFirstAncestor("Hitboxes_GeometryReviewOnly") then hitboxParts += 1 end
		end
	end
	model:SetAttribute("VisiblePartCount", visibleParts)
	model:SetAttribute("GameplayHitboxCount", hitboxParts)
	check(visibleParts <= Specification.PerformanceBudget.MaxVisibleParts, "Visible part budget exceeded")
	check(hitboxParts <= Specification.PerformanceBudget.MaxGameplayHitboxes, "Hitbox budget exceeded")
	return #issues == 0, issues
end

function Builder.Build(target: Instance, config: BuildConfig?): Model
	local existing = target:FindFirstChild(Specification.ModelName)
	if existing then existing:Destroy() end
	local requestedGround = (config and config.GroundCFrame) or CFrame.identity\n\tlocal model = build(target, requestedGround * CFrame.new(0, 0.3, 0))
	local valid, issues = Builder.Validate(model)
	if not valid then
		for _, issue in ipairs(issues) do warn("[Primal Beast] " .. issue) end
		error("Primal Beast failed geometry validation")
	end
	print("[Primal Beast] Phase 4 Golden Master built | Awaiting Quality Gate B")
	return model
end

return Builder
