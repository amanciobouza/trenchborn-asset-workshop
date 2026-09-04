--!strict
--[[
	Kaiju 01 "The Awakened" - Phase 4 Golden Master

	Geometry and rig review artifact only.
	No final materials, VFX, sounds, gameplay, or destruction logic are installed here.

	Workshop usage:

	local builder = require(path.To.KaijuAwakenedGoldenMaster)
	local kaiju = builder.Build(workspace, {
		GroundCFrame = CFrame.new(0, 0, 0),
	})
]]

local Builder = {}
local Specification = require(script.Parent:WaitForChild("KaijuAwakenedSpecification"))

local MODEL_NAME = Specification.ModelName
local BODY_COLOR = Color3.fromRGB(73, 81, 48)
local DARK_COLOR = Color3.fromRGB(38, 43, 29)
local BELLY_COLOR = Color3.fromRGB(101, 103, 73)
local PLATE_COLOR = Color3.fromRGB(48, 55, 35)
local CORE_REVIEW_COLOR = Color3.fromRGB(126, 142, 67)
local CLAW_COLOR = Color3.fromRGB(151, 139, 102)
local EYE_REVIEW_COLOR = Color3.fromRGB(212, 191, 55)
local TOOTH_COLOR = Color3.fromRGB(204, 196, 166)

local REQUIRED_R15_PARTS = {
	"HumanoidRootPart",
	"LowerTorso",
	"UpperTorso",
	"Head",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
}

type BuildConfig = {
	GroundCFrame: CFrame?,
}

local function setPhysicalDefaults(part: BasePart)
	part.Anchored = false
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = true
	part.Massless = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
end

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	setPhysicalDefaults(part)
	part.Parent = parent
	return part
end

local function makeEllipsoid(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3
): Part
	local part = makePart(parent, name, size, cframe, color, Enum.Material.SmoothPlastic)
	local mesh = Instance.new("SpecialMesh")
	mesh.Name = "FormMesh"
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Scale = Vector3.new(1, 1, 1)
	mesh.Parent = part
	return part
end

local function makeWedge(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3
): WedgePart
	local part = Instance.new("WedgePart")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	setPhysicalDefaults(part)
	part.Parent = parent
	return part
end

local function weld(part0: BasePart, part1: BasePart, name: string?)
	local constraint = Instance.new("WeldConstraint")
	constraint.Name = name or (part1.Name .. "Weld")
	constraint.Part0 = part0
	constraint.Part1 = part1
	constraint.Parent = part1
end

local function motor(
	parent: Instance,
	name: string,
	part0: BasePart,
	part1: BasePart,
	jointWorldCFrame: CFrame
): Motor6D
	local joint = Instance.new("Motor6D")
	joint.Name = name
	joint.Part0 = part0
	joint.Part1 = part1
	joint.C0 = part0.CFrame:ToObjectSpace(jointWorldCFrame)
	joint.C1 = part1.CFrame:ToObjectSpace(jointWorldCFrame)
	joint.Parent = parent
	return joint
end

local function segmentBetween(
	parent: Instance,
	name: string,
	a: Vector3,
	b: Vector3,
	width: number,
	depth: number,
	ground: CFrame,
	color: Color3
): Part
	local delta = b - a
	local midpoint = (a + b) * 0.5
	local cf = ground * CFrame.lookAt(midpoint, midpoint + delta)
	return makeEllipsoid(parent, name, Vector3.new(width, depth, delta.Magnitude), cf, color)
end

local function localPoint(ground: CFrame, point: Vector3): Vector3
	return ground:PointToWorldSpace(point)
end

local function addClaw(
	parent: Instance,
	host: BasePart,
	name: string,
	localOffset: Vector3,
	size: Vector3,
	angleX: number,
	ground: CFrame
): BasePart
	local claw = makeWedge(
		parent,
		name,
		size,
		ground * CFrame.new(localOffset) * CFrame.Angles(math.rad(angleX), math.rad(180), 0),
		CLAW_COLOR
	)
	weld(host, claw)
	return claw
end

local function addDorsalPlate(
	parent: Instance,
	host: BasePart,
	index: number,
	localOffset: Vector3,
	size: Vector3,
	ground: CFrame
)
	local assembly = Instance.new("Model")
	assembly.Name = string.format("DorsalPlate_%02d", index)
	assembly.Parent = parent

	local shell = makeWedge(
		assembly,
		"Shell",
		size,
		ground * CFrame.new(localOffset) * CFrame.Angles(0, 0, math.rad(-90)),
		PLATE_COLOR
	)
	weld(host, shell, "HostWeld")

	local coreSize = Vector3.new(size.X * 0.18, size.Y * 0.58, size.Z * 0.62)
	local core = makeWedge(
		assembly,
		"EnergyCore_GeometryOnly",
		coreSize,
		shell.CFrame * CFrame.new(0, 0, -size.Z * 0.08),
		CORE_REVIEW_COLOR
	)
	core.Material = Enum.Material.SmoothPlastic
	weld(shell, core, "CoreWeld")

	local attachment = Instance.new("Attachment")
	attachment.Name = string.format("DorsalEnergy_%02d", index)
	attachment.Parent = core
	assembly.PrimaryPart = shell
end

local function buildFoot(
	geometry: Instance,
	rig: Instance,
	sideName: string,
	x: number,
	ground: CFrame,
	lowerLeg: BasePart
): BasePart
	-- Long raised metatarsal: the heel/hock stays high and behind the toes.
	local hock = Vector3.new(x, 5.4, 1.45)
	local toeBase = Vector3.new(x, 1.25, -0.75)
	local foot = segmentBetween(
		rig,
		sideName .. "Foot",
		localPoint(ground, hock),
		localPoint(ground, toeBase),
		2.75,
		2.35,
		CFrame.identity,
		BODY_COLOR
	)
	motor(lowerLeg, sideName .. "Ankle", lowerLeg, foot, ground * CFrame.new(hock))

	local footDetail = Instance.new("Folder")
	footDetail.Name = sideName .. "FootGeometry"
	footDetail.Parent = geometry

	local spread = {-0.92, 0, 0.92}
	for toeIndex, xOffset in ipairs(spread) do
		local toe = makeEllipsoid(
			footDetail,
			string.format("ForwardToe_%d", toeIndex),
			Vector3.new(0.78, 0.72, 2.75),
			ground * CFrame.new(x + xOffset, 0.64, -2.05) * CFrame.Angles(math.rad(-4), 0, 0),
			DARK_COLOR
		)
		weld(foot, toe)
		addClaw(
			footDetail,
			toe,
			string.format("ForwardClaw_%d", toeIndex),
			Vector3.new(x + xOffset, 0.56, -3.48),
			Vector3.new(0.6, 0.55, 1.05),
			-8,
			ground
		)
	end

	local rearToe = makeEllipsoid(
		footDetail,
		"RearToe",
		Vector3.new(0.62, 0.62, 1.3),
		ground * CFrame.new(x, 1.2, 0.72) * CFrame.Angles(math.rad(18), 0, 0),
		DARK_COLOR
	)
	weld(foot, rearToe)
	local rearClaw = makeWedge(
		footDetail,
		"RearClaw",
		Vector3.new(0.48, 0.52, 0.86),
		ground * CFrame.new(x, 1.1, 1.52) * CFrame.Angles(math.rad(20), 0, 0),
		CLAW_COLOR
	)
	weld(rearToe, rearClaw)

	return foot
end

local function buildArm(
	geometry: Instance,
	rig: Instance,
	sideName: string,
	sign: number,
	ground: CFrame,
	upperTorso: BasePart
)
	local shoulder = Vector3.new(sign * 3.6, 19.4, -0.15)
	local elbow = Vector3.new(sign * 5.05, 15.8, -0.72)
	local wrist = Vector3.new(sign * 4.75, 12.95, -1.28)

	local upperArm = segmentBetween(
		rig,
		sideName .. "UpperArm",
		localPoint(ground, shoulder),
		localPoint(ground, elbow),
		2.25,
		2.05,
		CFrame.identity,
		BODY_COLOR
	)
	motor(upperTorso, sideName .. "Shoulder", upperTorso, upperArm, ground * CFrame.new(shoulder))

	local lowerArm = segmentBetween(
		rig,
		sideName .. "LowerArm",
		localPoint(ground, elbow),
		localPoint(ground, wrist),
		1.9,
		1.72,
		CFrame.identity,
		BODY_COLOR
	)
	motor(upperArm, sideName .. "Elbow", upperArm, lowerArm, ground * CFrame.new(elbow))

	local hand = makeEllipsoid(
		rig,
		sideName .. "Hand",
		Vector3.new(2.0, 1.25, 2.05),
		ground * CFrame.new(wrist + Vector3.new(0, -0.55, -0.42)),
		DARK_COLOR
	)
	motor(lowerArm, sideName .. "Wrist", lowerArm, hand, ground * CFrame.new(wrist))

	local handGeometry = Instance.new("Folder")
	handGeometry.Name = sideName .. "HandGeometry"
	handGeometry.Parent = geometry
	for fingerIndex = 1, 3 do
		local lateral = (fingerIndex - 2) * 0.58
		local finger = makeEllipsoid(
			handGeometry,
			string.format("Finger_%d", fingerIndex),
			Vector3.new(0.48, 0.48, 1.22),
			ground * CFrame.new(
				wrist.X + lateral,
				wrist.Y - 1.1,
				wrist.Z - 1.1
			) * CFrame.Angles(math.rad(-25), 0, 0),
			DARK_COLOR
		)
		weld(hand, finger)
		local claw = makeWedge(
			handGeometry,
			string.format("HandClaw_%d", fingerIndex),
			Vector3.new(0.38, 0.38, 0.72),
			ground * CFrame.new(
				wrist.X + lateral,
				wrist.Y - 1.47,
				wrist.Z - 1.68
			) * CFrame.Angles(math.rad(-20), math.rad(180), 0),
			CLAW_COLOR
		)
		weld(finger, claw)
	end
end

local function buildTail(
	rig: Instance,
	geometry: Instance,
	ground: CFrame,
	lowerTorso: BasePart
): {BasePart}
	local points = {
		Vector3.new(0, 14.9, 1.8),
		Vector3.new(0, 13.8, 5.0),
		Vector3.new(0, 12.2, 8.4),
		Vector3.new(0, 10.4, 11.8),
		Vector3.new(0, 8.5, 15.1),
		Vector3.new(0, 6.8, 18.1),
		Vector3.new(0, 5.1, 20.8),
		Vector3.new(0, 3.7, 23.2),
		Vector3.new(0, 2.6, 25.2),
		Vector3.new(0, 1.8, 26.8),
	}
	local widths = {5.0, 4.7, 4.3, 3.85, 3.35, 2.9, 2.45, 2.0, 1.55}
	local segments = {}
	local previous: BasePart = lowerTorso
	for index = 1, #points - 1 do
		local segment = segmentBetween(
			rig,
			string.format("TailSegment_%02d", index),
			localPoint(ground, points[index]),
			localPoint(ground, points[index + 1]),
			widths[index],
			widths[index] * 0.78,
			CFrame.identity,
			BODY_COLOR
		)
		motor(previous, string.format("TailJoint_%02d", index), previous, segment, ground * CFrame.new(points[index]))
		table.insert(segments, segment)
		previous = segment
	end

	local tailGeometry = Instance.new("Folder")
	tailGeometry.Name = "TailArmorGeometry"
	tailGeometry.Parent = geometry
	for index, segment in ipairs(segments) do
		if index <= 7 then
			local armor = makeEllipsoid(
				tailGeometry,
				string.format("TailArmor_%02d", index),
				segment.Size * Vector3.new(1.04, 0.36, 0.84),
				segment.CFrame * CFrame.new(0, segment.Size.Y * 0.44, 0),
				DARK_COLOR
			)
			weld(segment, armor)
		end
	end
	return segments
end

local function buildHead(
	model: Model,
	geometry: Instance,
	rig: Instance,
	ground: CFrame,
	upperTorso: BasePart
): BasePart
	local head = makeEllipsoid(
		rig,
		"Head",
		Vector3.new(5.6, 4.15, 5.2),
		ground * CFrame.new(0, 24.0, -1.15),
		BODY_COLOR
	)
	motor(upperTorso, "Neck", upperTorso, head, ground * CFrame.new(0, 21.9, -0.35))

	local headGeometry = Instance.new("Folder")
	headGeometry.Name = "HeadGeometry"
	headGeometry.Parent = geometry

	local brow = makeEllipsoid(
		headGeometry,
		"Brow",
		Vector3.new(5.4, 1.45, 3.7),
		ground * CFrame.new(0, 24.75, -2.65),
		DARK_COLOR
	)
	weld(head, brow)

	local snout = makeEllipsoid(
		headGeometry,
		"Snout",
		Vector3.new(4.5, 2.0, 4.15),
		ground * CFrame.new(0, 23.55, -3.55),
		BODY_COLOR
	)
	weld(head, snout)

	local jaw = makeEllipsoid(
		rig,
		"Jaw",
		Vector3.new(4.45, 1.45, 4.0),
		ground * CFrame.new(0, 22.55, -3.45),
		DARK_COLOR
	)
	motor(head, "JawJoint", head, jaw, ground * CFrame.new(0, 23.0, -1.85))

	for _, sign in ipairs({-1, 1}) do
		local eye = makeEllipsoid(
			headGeometry,
			sign < 0 and "LeftEye_GeometryOnly" or "RightEye_GeometryOnly",
			Vector3.new(0.62, 0.72, 0.38),
			ground * CFrame.new(sign * 2.18, 24.55, -3.32),
			EYE_REVIEW_COLOR
		)
		eye.Material = Enum.Material.SmoothPlastic
		weld(head, eye)
		local pupil = makePart(
			headGeometry,
			sign < 0 and "LeftSlitPupil" or "RightSlitPupil",
			Vector3.new(0.10, 0.5, 0.12),
			eye.CFrame * CFrame.new(0, 0, -0.2),
			Color3.fromRGB(12, 13, 8),
			Enum.Material.SmoothPlastic
		)
		weld(eye, pupil)
		local eyeAttachment = Instance.new("Attachment")
		eyeAttachment.Name = "EyeEnergy"
		eyeAttachment.Parent = eye
	end

	local teeth = Instance.new("Folder")
	teeth.Name = "TeethGeometry"
	teeth.Parent = headGeometry
	for sideIndex, sign in ipairs({-1, 1}) do
		for toothIndex = 1, 5 do
			local x = sign * (0.55 + (toothIndex - 1) * 0.34)
			local z = -4.2 + math.abs(x) * 0.25
			local tooth = makeWedge(
				teeth,
				string.format("UpperTooth_%d_%d", sideIndex, toothIndex),
				Vector3.new(0.24, 0.58, 0.28),
				ground * CFrame.new(x, 22.95, z),
				TOOTH_COLOR
			)
			weld(head, tooth)
		end
	end

	local mouthAttachment = Instance.new("Attachment")
	mouthAttachment.Name = "MouthEnergy"
	mouthAttachment.Position = Vector3.new(0, 0, -2.25)
	mouthAttachment.Parent = head

	model:SetAttribute("JawMotorPath", "Head.JawJoint")
	return head
end

local function addBellyPlates(geometry: Instance, upperTorso: BasePart, lowerTorso: BasePart, ground: CFrame)
	local folder = Instance.new("Folder")
	folder.Name = "BellyArmor"
	folder.Parent = geometry
	for index = 1, 7 do
		local y = 19.85 - (index - 1) * 1.08
		local width = 4.75 - math.abs(index - 3.5) * 0.28
		local plate = makeEllipsoid(
			folder,
			string.format("BellyPlate_%02d", index),
			Vector3.new(width, 0.78, 0.72),
			ground * CFrame.new(0, y, -2.5 + math.abs(index - 3.5) * 0.08),
			BELLY_COLOR
		)
		weld(index <= 4 and upperTorso or lowerTorso, plate)
	end
end

local function addBackPlates(
	geometry: Instance,
	upperTorso: BasePart,
	lowerTorso: BasePart,
	head: BasePart,
	tailSegments: {BasePart},
	ground: CFrame
)
	local folder = Instance.new("Folder")
	folder.Name = "DorsalPlates"
	folder.Parent = geometry
	local specs = {
		{host = head, p = Vector3.new(0, 25.0, 0.8), s = Vector3.new(0.75, 1.6, 1.25)},
		{host = upperTorso, p = Vector3.new(0, 22.1, 1.85), s = Vector3.new(0.9, 2.1, 1.55)},
		{host = upperTorso, p = Vector3.new(0, 20.2, 2.35), s = Vector3.new(1.0, 2.45, 1.85)},
		{host = upperTorso, p = Vector3.new(0, 18.2, 2.5), s = Vector3.new(1.05, 2.7, 2.0)},
		{host = lowerTorso, p = Vector3.new(0, 16.1, 2.35), s = Vector3.new(1.0, 2.45, 1.85)},
		{host = lowerTorso, p = Vector3.new(0, 14.2, 2.6), s = Vector3.new(0.9, 2.05, 1.55)},
		{host = tailSegments[1], p = Vector3.new(0, 13.4, 5.15), s = Vector3.new(0.78, 1.65, 1.28)},
		{host = tailSegments[2], p = Vector3.new(0, 11.7, 8.45), s = Vector3.new(0.68, 1.35, 1.08)},
		{host = tailSegments[3], p = Vector3.new(0, 9.9, 11.75), s = Vector3.new(0.58, 1.1, 0.9)},
	}
	for index, spec in ipairs(specs) do
		addDorsalPlate(folder, spec.host, index, spec.p, spec.s, ground)
	end
end

local function addReviewHitboxes(model: Model, ground: CFrame)
	local hitboxes = Instance.new("Folder")
	hitboxes.Name = "Hitboxes_GeometryReviewOnly"
	hitboxes.Parent = model
	local body = makePart(
		hitboxes,
		"BodyHitbox",
		Vector3.new(8.2, 12.5, 6.4),
		ground * CFrame.new(0, 16.5, 0.2),
		Color3.fromRGB(255, 0, 255),
		Enum.Material.ForceField
	)
	body.Transparency = 1
	weld(model.PrimaryPart :: BasePart, body)
	local tail = makePart(
		hitboxes,
		"TailHitbox",
		Vector3.new(5.5, 5.5, 21),
		ground * CFrame.new(0, 8.0, 13.3) * CFrame.Angles(math.rad(-27), 0, 0),
		Color3.fromRGB(255, 0, 255),
		Enum.Material.ForceField
	)
	tail.Transparency = 1
	weld(model.PrimaryPart :: BasePart, tail)
end

local function build(target: Instance, ground: CFrame): Model
	local model = Instance.new("Model")
	model.Name = MODEL_NAME
	model:SetAttribute("AssetName", Specification.AssetName)
	model:SetAttribute("AssetClass", Specification.AssetClass)
	model:SetAttribute("PipelinePhase", Specification.PipelinePhase)
	model:SetAttribute("PipelineStatus", "AWAITING_GEOMETRY_APPROVAL")
	model:SetAttribute("AssetId", Specification.AssetId)
	model:SetAttribute("QualityGateA", Specification.QualityGateA)
	model:SetAttribute("QualityGateB", Specification.QualityGateB)
	model:SetAttribute("QualityGateC", Specification.QualityGateC)
	model:SetAttribute("GeometryOnly", true)
	model:SetAttribute("DesignVersion", "1.0.0")
	model:SetAttribute("RigStandard", "R15-compatible custom silhouette")
	model:SetAttribute("DigitigradeLegs", true)
	model:SetAttribute("ForwardClawsPerFoot", 3)
	model:SetAttribute("RearClawsPerFoot", 1)
	model:SetAttribute("DorsalPlateCount", 9)
	model:SetAttribute("DressingDeferredToPhase", 5)
	model.Parent = target

	-- R15 body parts must remain direct children of the character Model so that
	-- Humanoid/Animator can resolve the standard part and Motor6D names.
	local rig: Instance = model
	local rigMetadata = Instance.new("Configuration")
	rigMetadata.Name = "RigMetadata"
	rigMetadata:SetAttribute("BodyPartsAreDirectModelChildren", true)
	rigMetadata:SetAttribute("TailUsesAdditionalMotor6Ds", true)
	rigMetadata.Parent = model
	local geometry = Instance.new("Folder")
	geometry.Name = "BodyGeometry"
	geometry.Parent = model

	local root = makePart(
		rig,
		"HumanoidRootPart",
		Vector3.new(3, 3, 2),
		ground * CFrame.new(0, 14.1, 0),
		Color3.fromRGB(255, 255, 255),
		Enum.Material.SmoothPlastic
	)
	root.Transparency = 1
	root.Anchored = true
	root.Massless = false
	model.PrimaryPart = root

	local lowerTorso = makeEllipsoid(
		rig,
		"LowerTorso",
		Vector3.new(7.3, 6.2, 5.5),
		ground * CFrame.new(0, 15.0, 0.35),
		BODY_COLOR
	)
	motor(root, "Root", root, lowerTorso, ground * CFrame.new(0, 14.2, 0))

	local upperTorso = makeEllipsoid(
		rig,
		"UpperTorso",
		Vector3.new(8.1, 7.0, 5.7),
		ground * CFrame.new(0, 19.0, -0.05),
		BODY_COLOR
	)
	motor(lowerTorso, "Waist", lowerTorso, upperTorso, ground * CFrame.new(0, 17.0, 0.1))

	local head = buildHead(model, geometry, rig, ground, upperTorso)
	addBellyPlates(geometry, upperTorso, lowerTorso, ground)
	buildArm(geometry, rig, "Left", -1, ground, upperTorso)
	buildArm(geometry, rig, "Right", 1, ground, upperTorso)

	for _, side in ipairs({{name = "Left", sign = -1}, {name = "Right", sign = 1}}) do
		local x = side.sign * 3.0
		local hip = Vector3.new(x, 14.5, 0.45)
		local knee = Vector3.new(x, 9.65, -1.25)
		local hock = Vector3.new(x, 5.4, 1.45)
		local upperLeg = segmentBetween(
			rig,
			side.name .. "UpperLeg",
			localPoint(ground, hip),
			localPoint(ground, knee),
			4.15,
			3.75,
			CFrame.identity,
			BODY_COLOR
		)
		motor(lowerTorso, side.name .. "Hip", lowerTorso, upperLeg, ground * CFrame.new(hip))
		local lowerLeg = segmentBetween(
			rig,
			side.name .. "LowerLeg",
			localPoint(ground, knee),
			localPoint(ground, hock),
			3.55,
			3.25,
			CFrame.identity,
			BODY_COLOR
		)
		motor(upperLeg, side.name .. "Knee", upperLeg, lowerLeg, ground * CFrame.new(knee))
		buildFoot(geometry, rig, side.name, x, ground, lowerLeg)
	end

	local tailSegments = buildTail(rig, geometry, ground, lowerTorso)
	addBackPlates(geometry, upperTorso, lowerTorso, head, tailSegments, ground)
	addReviewHitboxes(model, ground)

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.BreakJointsOnDeath = false
	humanoid.AutoRotate = false
	humanoid.HipHeight = 0
	humanoid.Parent = model

	local animator = Instance.new("Animator")
	animator.Parent = humanoid

	local review = Instance.new("Configuration")
	review.Name = "GeometryReviewContract"
	review:SetAttribute("CheckSilhouette", true)
	review:SetAttribute("CheckDigitigradeLegs", true)
	review:SetAttribute("CheckThreeForwardOneRearClaw", true)
	review:SetAttribute("CheckDorsalGrowthPotential", true)
	review:SetAttribute("CheckTailBalance", true)
	review:SetAttribute("CheckNoPartIntersections", true)
	review.Parent = model

	return model
end

function Builder.Validate(model: Model): (boolean, {string})
	local issues = {}
	local function check(condition: boolean, message: string)
		if not condition then
			table.insert(issues, message)
		end
	end

	check(model.Name == MODEL_NAME, "Unexpected model name")
	check(model:GetAttribute("PipelinePhase") == 4, "PipelinePhase must be 4")
	check(model.PrimaryPart ~= nil, "PrimaryPart is missing")
	check(model:FindFirstChildOfClass("Humanoid") ~= nil, "Humanoid is missing")

	for _, partName in ipairs(REQUIRED_R15_PARTS) do
		local part = model:FindFirstChild(partName)
		check(part ~= nil and part:IsA("BasePart"), partName .. " must be a direct BasePart child")
	end

	local geometry = model:FindFirstChild("BodyGeometry")
	check(geometry ~= nil, "BodyGeometry folder is missing")
	if geometry then
		local dorsal = geometry:FindFirstChild("DorsalPlates")
		check(dorsal ~= nil, "DorsalPlates folder is missing")
		if dorsal then
			local plateCount = 0
			for _, child in ipairs(dorsal:GetChildren()) do
				if child:IsA("Model") and string.match(child.Name, "^DorsalPlate_%d%d$") then
					plateCount = plateCount + 1
				end
			end
			check(plateCount == 9, string.format("Expected 9 dorsal plates, found %d", plateCount))
		end

		for _, sideName in ipairs({"Left", "Right"}) do
			local footGeometry = geometry:FindFirstChild(sideName .. "FootGeometry")
			check(footGeometry ~= nil, sideName .. "FootGeometry is missing")
			if footGeometry then
				local forwardToes = 0
				local forwardClaws = 0
				for _, child in ipairs(footGeometry:GetChildren()) do
					if string.match(child.Name, "^ForwardToe_%d$") then
						forwardToes = forwardToes + 1
					elseif string.match(child.Name, "^ForwardClaw_%d$") then
						forwardClaws = forwardClaws + 1
					end
				end
				check(forwardToes == 3, string.format("%s foot needs 3 forward toes", sideName))
				check(forwardClaws == 3, string.format("%s foot needs 3 forward claws", sideName))
				check(footGeometry:FindFirstChild("RearToe") ~= nil, sideName .. " rear toe is missing")
				check(footGeometry:FindFirstChild("RearClaw") ~= nil, sideName .. " rear claw is missing")
			end
		end
	end

	for _, descendant in ipairs(model:GetDescendants()) do
		local deferredDressing = descendant:IsA("ParticleEmitter")
			or descendant:IsA("Light")
			or descendant:IsA("Sound")
		check(not deferredDressing, descendant.ClassName .. " belongs in Phase 5 or 6")
	end

	local visiblePartCount = 0
	local gameplayHitboxCount = 0
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			if descendant.Transparency < 1 then
				visiblePartCount += 1
			end
			if descendant:FindFirstAncestor("Hitboxes_GeometryReviewOnly") then
				gameplayHitboxCount += 1
			end
		end
	end
	local budget = Specification.PerformanceBudget
	model:SetAttribute("VisiblePartCount", visiblePartCount)
	model:SetAttribute("VisiblePartBudget", budget.MaxVisibleParts)
	model:SetAttribute("GameplayHitboxCount", gameplayHitboxCount)
	model:SetAttribute("GameplayHitboxBudget", budget.MaxGameplayHitboxes)
	model:SetAttribute(
		"GeometryBudgetPassed",
		visiblePartCount <= budget.MaxVisibleParts and gameplayHitboxCount <= budget.MaxGameplayHitboxes
	)
	check(visiblePartCount <= budget.MaxVisibleParts, "Visible part budget exceeded")
	check(gameplayHitboxCount <= budget.MaxGameplayHitboxes, "Gameplay hitbox budget exceeded")

	return #issues == 0, issues
end

function Builder.Build(target: Instance, config: BuildConfig?): Model
	local options = config or {}
	local existing = target:FindFirstChild(MODEL_NAME)
	if existing then
		existing:Destroy()
	end

	local model = build(target, options.GroundCFrame or CFrame.new(0, 0, 0))
	local valid, issues = Builder.Validate(model)
	if not valid then
		for _, issue in ipairs(issues) do
			warn("[Kaiju01 Golden Master] " .. issue)
		end
		error("Kaiju01 Golden Master failed its structural validation")
	end
	print(string.format(
		"[Kaiju01 Golden Master] Built %s | Phase 4 | Awaiting Quality Gate B",
		model:GetFullName()
	))
	return model
end

return Builder
