--!strict
-- Kaiju-I Bound Chimera | Phase 4 geometry-only Golden Master
-- Target-lineage revision: upright barrel torso, long free arms, massive digitigrade legs,
-- predator wedge head, primitive shattered storm shields, no later-stage armor.
local Builder = {}
local Specification = require(script.Parent:WaitForChild("KaijuAwakenedSpecification"))

local BODY = Color3.fromRGB(43, 47, 39)
local BODY_DARK = Color3.fromRGB(28, 31, 27)
local RIDGE = Color3.fromRGB(36, 39, 34)
local BELLY = Color3.fromRGB(72, 73, 53)
local ENERGY = Color3.fromRGB(162, 176, 50)
local EYE = Color3.fromRGB(246, 220, 42)
local CLAW = Color3.fromRGB(132, 124, 94)

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

local function part(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, shape: Enum.PartType?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Shape = shape or Enum.PartType.Block
	defaults(p)
	p.Parent = parent
	return p
end

local function ellipsoid(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): Part
	local p = part(parent, name, size, cf, color)
	local mesh = Instance.new("SpecialMesh")
	mesh.Name = "FormMesh"
	mesh.MeshType = Enum.MeshType.Sphere
	mesh.Parent = p
	return p
end

local function wedge(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): WedgePart
	local p = Instance.new("WedgePart")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.Slate
	defaults(p)
	p.Parent = parent
	return p
end

local function weld(host: BasePart, child: BasePart)
	local w = Instance.new("WeldConstraint")
	w.Name = child.Name .. "Weld"
	w.Part0 = host
	w.Part1 = child
	w.Parent = child
end

local function motor(parent: Instance, name: string, a: BasePart, b: BasePart, world: CFrame)
	local m = Instance.new("Motor6D")
	m.Name = name
	m.Part0 = a
	m.Part1 = b
	m.C0 = a.CFrame:ToObjectSpace(world)
	m.C1 = b.CFrame:ToObjectSpace(world)
	m.Parent = parent
end

local function segment(parent: Instance, name: string, a: Vector3, b: Vector3, width: number, depth: number, ground: CFrame, color: Color3): Part
	local wa = ground:PointToWorldSpace(a)
	local wb = ground:PointToWorldSpace(b)
	local delta = wb - wa
	local middle = (wa + wb) * 0.5
	return ellipsoid(parent, name, Vector3.new(width, depth, delta.Magnitude), CFrame.lookAt(middle, middle + delta), color)
end

local function cylinderBetween(parent: Instance, name: string, a: Vector3, b: Vector3, diameter: number, ground: CFrame, color: Color3): Part
	local wa = ground:PointToWorldSpace(a)
	local wb = ground:PointToWorldSpace(b)
	local delta = wb - wa
	local middle = (wa + wb) * 0.5
	local p = part(parent, name, Vector3.new(delta.Magnitude, diameter, diameter), CFrame.lookAt(middle, middle + delta) * CFrame.Angles(0, math.rad(90), 0), color, Enum.PartType.Cylinder)
	p.Material = Enum.Material.Slate
	return p
end

local function folder(parent: Instance, name: string): Folder
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

local function buildFoot(model: Model, geometry: Folder, side: string, sign: number, lowerLeg: BasePart, ground: CFrame): BasePart
	local x = sign * 3.45
	local hock = Vector3.new(x, 5.7, 1.3)
	local toeBase = Vector3.new(x, 1.25, -0.8)
	local foot = segment(model, side .. "Foot", hock, toeBase, 3.7, 3.1, ground, BODY_DARK)
	motor(lowerLeg, side .. "Ankle", lowerLeg, foot, ground * CFrame.new(hock))

	local g = folder(geometry, side .. "FootGeometry")
	for i, lateral in ipairs({-1.2, 0, 1.2}) do
		local toe = ellipsoid(g, "ForwardToe_" .. i, Vector3.new(1.05, 0.9, 3.25), ground * CFrame.new(x + lateral, 0.72, -2.1), BODY_DARK)
		weld(foot, toe)
		local claw = wedge(g, "ForwardClaw_" .. i, Vector3.new(0.78, 0.68, 1.35), ground * CFrame.new(x + lateral, 0.62, -3.75) * CFrame.Angles(math.rad(-8), math.rad(180), 0), CLAW)
		weld(toe, claw)
	end
	local rearToe = ellipsoid(g, "RearToe", Vector3.new(0.9, 0.8, 1.55), ground * CFrame.new(x, 1.35, 1.0) * CFrame.Angles(math.rad(18), 0, 0), BODY_DARK)
	weld(foot, rearToe)
	local rearClaw = wedge(g, "RearClaw", Vector3.new(0.65, 0.6, 1.05), ground * CFrame.new(x, 1.25, 1.9) * CFrame.Angles(math.rad(18), 0, 0), CLAW)
	weld(rearToe, rearClaw)
	return foot
end

local function buildArm(model: Model, geometry: Folder, side: string, sign: number, torso: BasePart, ground: CFrame)
	local shoulder = Vector3.new(sign * 4.85, 21.7, -0.1)
	local elbow = Vector3.new(sign * 5.7, 17.0, -0.45)
	local wrist = Vector3.new(sign * 5.35, 12.8, -0.9)

	local upper = segment(model, side .. "UpperArm", shoulder, elbow, 3.2, 2.85, ground, BODY)
	motor(torso, side .. "Shoulder", torso, upper, ground * CFrame.new(shoulder))
	local lower = segment(model, side .. "LowerArm", elbow, wrist, 2.8, 2.5, ground, BODY)
	motor(upper, side .. "Elbow", upper, lower, ground * CFrame.new(elbow))

	local deltoid = ellipsoid(geometry, side .. "DeltoidMass", Vector3.new(3.7, 4.0, 3.5), ground * CFrame.new(shoulder + Vector3.new(0, -0.8, 0)), BODY)
	weld(upper, deltoid)
	local forearm = ellipsoid(geometry, side .. "ForearmMass", Vector3.new(3.15, 4.0, 2.9), ground * CFrame.new((elbow + wrist) * 0.5), BODY)
	weld(lower, forearm)

	local elbowRidge = wedge(geometry, side .. "ElbowRidge", Vector3.new(1.6, 1.15, 1.8), ground * CFrame.new(elbow + Vector3.new(0, 0.1, 0.55)) * CFrame.Angles(0, sign * math.rad(90), 0), RIDGE)
	weld(lower, elbowRidge)

	local hand = ellipsoid(model, side .. "Hand", Vector3.new(2.8, 1.9, 2.45), ground * CFrame.new(wrist + Vector3.new(0, -0.7, -0.35)) * CFrame.Angles(math.rad(-12), 0, 0), BODY_DARK)
	motor(lower, side .. "Wrist", lower, hand, ground * CFrame.new(wrist))
	local handGeo = folder(geometry, side .. "HandGeometry")
	for i = 1, 3 do
		local x = wrist.X + (i - 2) * 0.72
		local finger = ellipsoid(handGeo, "Finger_" .. i, Vector3.new(0.58, 0.62, 1.35), ground * CFrame.new(x, wrist.Y - 1.35, wrist.Z - 1.0) * CFrame.Angles(math.rad(-18), 0, 0), BODY_DARK)
		weld(hand, finger)
	end
end

local function buildHead(model: Model, geometry: Folder, torso: BasePart, ground: CFrame): BasePart
	local head = ellipsoid(model, "Head", Vector3.new(6.25, 4.2, 4.9), ground * CFrame.new(0, 26.35, -1.1) * CFrame.Angles(math.rad(-4), 0, 0), BODY)
	motor(torso, "Neck", torso, head, ground * CFrame.new(0, 23.8, -0.25))
	local g = folder(geometry, "HeadGeometry")

	local brow = wedge(g, "PredatorBrowWedge", Vector3.new(6.0, 1.45, 3.4), ground * CFrame.new(0, 27.2, -1.35), RIDGE)
	weld(head, brow)
	local muzzle = wedge(g, "PredatorMuzzle", Vector3.new(4.8, 1.8, 3.05), ground * CFrame.new(0, 25.45, -3.15) * CFrame.Angles(0, math.rad(180), 0), BODY_DARK)
	weld(head, muzzle)
	local jaw = ellipsoid(model, "Jaw", Vector3.new(4.8, 1.35, 3.15), ground * CFrame.new(0, 24.65, -3.0), BODY_DARK)
	motor(head, "JawJoint", head, jaw, ground * CFrame.new(0, 25.05, -1.8))

	for _, sign in ipairs({-1, 1}) do
		local eye = ellipsoid(g, sign < 0 and "LeftEye_GeometryOnly" or "RightEye_GeometryOnly", Vector3.new(0.68, 0.52, 0.38), ground * CFrame.new(sign * 2.35, 26.45, -3.2), EYE)
		weld(head, eye)
		local a = Instance.new("Attachment")
		a.Name = "EyeEnergy"
		a.Parent = eye
		local cheek = wedge(g, sign < 0 and "LeftCheekRidge" or "RightCheekRidge", Vector3.new(0.7, 1.2, 1.8), ground * CFrame.new(sign * 2.75, 25.5, -1.85) * CFrame.Angles(0, sign * math.rad(90), 0), RIDGE)
		weld(head, cheek)
	end
	return head
end

local function addTorsoMass(geometry: Folder, torso: BasePart, pelvis: BasePart, ground: CFrame)
	local g = folder(geometry, "LayeredBodyVolumes")
	for _, spec in ipairs({
		{"LeftChestMass", Vector3.new(-2.7, 22.0, -1.15), Vector3.new(5.0, 6.2, 4.8), torso},
		{"RightChestMass", Vector3.new(2.7, 22.0, -1.15), Vector3.new(5.0, 6.2, 4.8), torso},
		{"UpperChestBridge", Vector3.new(0, 23.4, -0.65), Vector3.new(7.0, 3.8, 5.0), torso},
		{"AbdomenMass", Vector3.new(0, 17.9, -0.55), Vector3.new(6.8, 4.7, 4.7), pelvis},
		{"LeftHipMass", Vector3.new(-2.8, 15.6, 0.0), Vector3.new(4.8, 4.8, 5.0), pelvis},
		{"RightHipMass", Vector3.new(2.8, 15.6, 0.0), Vector3.new(4.8, 4.8, 5.0), pelvis},
	}) do
		local p = ellipsoid(g, spec[1] :: string, spec[3] :: Vector3, ground * CFrame.new(spec[2] :: Vector3), BODY)
		weld(spec[4] :: BasePart, p)
	end

	for index = 1, 5 do
		local y = 22.0 - index * 1.05
		local band = ellipsoid(g, "BellyBand_" .. index, Vector3.new(6.0 - index * 0.2, 0.8, 1.1), ground * CFrame.new(0, y, -3.15), BELLY)
		weld(index <= 3 and torso or pelvis, band)
	end

	for _, sign in ipairs({-1, 1}) do
		local chestRidge = wedge(g, sign < 0 and "LeftChestRidge" or "RightChestRidge", Vector3.new(1.1, 3.6, 1.2), ground * CFrame.new(sign * 3.55, 21.0, -3.25) * CFrame.Angles(0, sign * math.rad(90), 0), RIDGE)
		weld(torso, chestRidge)
		local hipRidge = wedge(g, sign < 0 and "LeftHipRidge" or "RightHipRidge", Vector3.new(2.2, 1.55, 2.0), ground * CFrame.new(sign * 4.2, 15.7, 0.1) * CFrame.Angles(0, sign * math.rad(90), 0), RIDGE)
		weld(pelvis, hipRidge)
	end
end

local function buildTail(model: Model, geometry: Folder, pelvis: BasePart, ground: CFrame): {BasePart}
	local points = {
		Vector3.new(0, 15.4, 2.5), Vector3.new(0, 14.3, 5.5), Vector3.new(0, 12.9, 8.4),
		Vector3.new(0, 11.1, 11.2), Vector3.new(0, 9.1, 13.8), Vector3.new(0, 7.3, 16.0),
		Vector3.new(0, 5.9, 17.9), Vector3.new(0, 5.0, 19.4),
	}
	local widths = {5.2, 4.75, 4.2, 3.65, 3.05, 2.45, 1.85}
	local segments = {}
	local host = pelvis
	for i = 1, #points - 1 do
		local s = cylinderBetween(model, string.format("TailCylinder_%02d", i), points[i], points[i + 1], widths[i], ground, BODY)
		motor(host, string.format("TailJoint_%02d", i), host, s, ground * CFrame.new(points[i]))
		table.insert(segments, s)
		host = s
	end
	local g = folder(geometry, "CounterbalanceRidges")
	for i, hostPart in ipairs(segments) do
		if i <= 4 then
			local p = wedge(g, "TailRidge_" .. i, Vector3.new(0.9, 1.5 + (#segments - i) * 0.16, 1.7), hostPart.CFrame * CFrame.new(0, 0.9, 0), RIDGE)
			weld(hostPart, p)
		end
	end
	return segments
end

local function shatteredShield(parent: Folder, host: BasePart, index: number, pos: Vector3, scale: number, ground: CFrame)
	local assembly = Instance.new("Model")
	assembly.Name = string.format("StormShield_%02d", index)
	assembly.Parent = parent
	local baseCF = ground * CFrame.new(pos) * CFrame.Angles(math.rad(-10), 0, math.rad(-5 + (index % 3) * 5))
	local center = wedge(assembly, "CenterLobe", Vector3.new(1.15 * scale, 3.1 * scale, 2.35 * scale), baseCF, RIDGE)
	weld(host, center)
	for lobe = 1, 2 do
		local sign = lobe == 1 and -1 or 1
		local side = wedge(assembly, "FracturedLobe_" .. lobe, Vector3.new(0.72 * scale, 2.2 * scale, 1.45 * scale), baseCF * CFrame.new(sign * 0.64 * scale, -0.18 * scale, 0.12 * scale) * CFrame.Angles(0, sign * math.rad(8), sign * math.rad(10)), RIDGE)
		weld(host, side)
	end
	local seam = wedge(assembly, "EnergySeam_GeometryOnly", Vector3.new(0.14 * scale, 1.8 * scale, 1.05 * scale), baseCF * CFrame.new(0, 0, -0.12 * scale), ENERGY)
	weld(host, seam)
	local a = Instance.new("Attachment")
	a.Name = string.format("DorsalEnergy_%02d", index)
	a.Parent = center
	assembly.PrimaryPart = center
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
	model:SetAttribute("EvolutionName", "Bound Chimera")
	model:SetAttribute("DesignVersion", "4.0.0-target-lineage")
	model:SetAttribute("UprightDominant", true)
	model:SetAttribute("OpenBarrelChest", true)
	model:SetAttribute("LongPowerArms", true)
	model:SetAttribute("DigitigradeLegs", true)
	model:SetAttribute("DorsalShieldCount", 7)
	model:SetAttribute("ForbiddenLaterStageArmor", true)

	local geometry = folder(model, "BodyGeometry")
	local root = part(model, "HumanoidRootPart", Vector3.new(3, 3, 2), ground * CFrame.new(0, 15.0, 0), Color3.new(1, 1, 1))
	root.Transparency = 1
	root.Anchored = true
	root.Massless = false
	model.PrimaryPart = root

	local pelvis = ellipsoid(model, "LowerTorso", Vector3.new(8.2, 5.8, 5.6), ground * CFrame.new(0, 16.2, 0.35), BODY)
	motor(root, "Root", root, pelvis, ground * CFrame.new(0, 15.0, 0))
	local torso = ellipsoid(model, "UpperTorso", Vector3.new(9.3, 7.4, 6.0), ground * CFrame.new(0, 21.5, -0.05), BODY)
	motor(pelvis, "Waist", pelvis, torso, ground * CFrame.new(0, 18.8, 0.1))

	addTorsoMass(geometry, torso, pelvis, ground)
	buildHead(model, geometry, torso, ground)
	buildArm(model, geometry, "Left", -1, torso, ground)
	buildArm(model, geometry, "Right", 1, torso, ground)

	for _, data in ipairs({{"Left", -1}, {"Right", 1}}) do
		local side = data[1] :: string
		local sign = data[2] :: number
		local x = sign * 3.45
		local hip = Vector3.new(x, 15.8, 0.35)
		local knee = Vector3.new(x, 10.4, -1.55)
		local hock = Vector3.new(x, 5.7, 1.3)
		local upper = segment(model, side .. "UpperLeg", hip, knee, 5.35, 4.8, ground, BODY)
		motor(pelvis, side .. "Hip", pelvis, upper, ground * CFrame.new(hip))
		local lower = segment(model, side .. "LowerLeg", knee, hock, 4.45, 4.05, ground, BODY)
		motor(upper, side .. "Knee", upper, lower, ground * CFrame.new(knee))
		local thigh = ellipsoid(geometry, side .. "ThighMass", Vector3.new(5.7, 5.8, 5.05), ground * CFrame.new((hip + knee) * 0.5 + Vector3.new(0, 0.35, 0.1)), BODY)
		weld(upper, thigh)
		local calf = ellipsoid(geometry, side .. "CalfMass", Vector3.new(4.8, 4.75, 4.2), ground * CFrame.new((knee + hock) * 0.5 + Vector3.new(0, -0.1, 0.25)), BODY)
		weld(lower, calf)
		local kneeRidge = wedge(geometry, side .. "KneeRidge", Vector3.new(2.9, 1.5, 2.1), ground * CFrame.new(knee + Vector3.new(0, 0, -1.35)) * CFrame.Angles(0, math.rad(180), 0), RIDGE)
		weld(lower, kneeRidge)
		buildFoot(model, geometry, side, sign, lower, ground)
	end

	local tail = buildTail(model, geometry, pelvis, ground)
	local dorsals = folder(geometry, "DorsalPlates")
	local dorsalSpecs = {
		{model.Head, Vector3.new(0, 27.3, 0.7), 0.48},
		{torso, Vector3.new(0, 24.8, 2.45), 0.72},
		{torso, Vector3.new(0, 22.4, 3.05), 0.94},
		{torso, Vector3.new(0, 19.9, 3.1), 1.05},
		{pelvis, Vector3.new(0, 17.2, 3.0), 0.9},
		{pelvis, Vector3.new(0, 14.9, 3.15), 0.68},
		{tail[1], Vector3.new(0, 13.6, 5.9), 0.5},
	}
	for i, d in ipairs(dorsalSpecs) do
		shatteredShield(dorsals, d[1] :: BasePart, i, d[2] :: Vector3, d[3] :: number, ground)
	end

	local hitboxes = folder(model, "Hitboxes_GeometryReviewOnly")
	local bodyHit = part(hitboxes, "BodyHitbox", Vector3.new(10, 15, 8), ground * CFrame.new(0, 17.5, 0), Color3.fromRGB(255, 0, 255))
	bodyHit.Transparency = 1
	weld(root, bodyHit)
	local rearHit = part(hitboxes, "CounterbalanceHitbox", Vector3.new(6, 6, 15), ground * CFrame.new(0, 9, 9.4) * CFrame.Angles(math.rad(-30), 0, 0), Color3.fromRGB(255, 0, 255))
	rearHit.Transparency = 1
	weld(root, rearHit)

	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.AutoRotate = false
	humanoid.BreakJointsOnDeath = false
	humanoid.Parent = model
	local animator = Instance.new("Animator")
	animator.Parent = humanoid

	local review = Instance.new("Configuration")
	review.Name = "GeometryReviewContract"
	review.Parent = model
	review:SetAttribute("CheckTargetImageLineage", true)
	review:SetAttribute("CheckUprightNotHunched", true)
	review:SetAttribute("CheckOpenMassiveChest", true)
	review:SetAttribute("CheckLongArmsToMidThigh", true)
	review:SetAttribute("CheckMassiveDigitigradeLegs", true)
	review:SetAttribute("CheckBroadFeet", true)
	review:SetAttribute("CheckPredatorHead", true)
	review:SetAttribute("CheckShatteredStormShields", true)
	review:SetAttribute("RejectLaterStageShoulderArmor", true)
	review:SetAttribute("RejectEvolvedHeadArmor", true)
	review:SetAttribute("RejectCalderaChest", true)
	review:SetAttribute("RejectCatastropheCrown", true)
	review:SetAttribute("RejectMushroomShellDorsals", true)
	review:SetAttribute("CheckThreeForwardOneRearClaw", true)
	return model
end

function Builder.Validate(model: Model): (boolean, {string})
	local issues = {}
	local function check(ok: boolean, message: string)
		if not ok then
			table.insert(issues, message)
		end
	end

	check(model:GetAttribute("PipelinePhase") == 4, "PipelinePhase must be 4")
	check(model:GetAttribute("UprightDominant") == true, "Stage 1 must be upright dominant")
	check(model:GetAttribute("LongPowerArms") == true, "Stage 1 requires long free-hanging power arms")
	check(model:GetAttribute("ForbiddenLaterStageArmor") == true, "Later-stage armor guard missing")

	for _, name in ipairs({
		"HumanoidRootPart", "LowerTorso", "UpperTorso", "Head",
		"LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand",
		"LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot",
	}) do
		check(model:FindFirstChild(name) ~= nil, name .. " missing")
	end

	local geometry = model:FindFirstChild("BodyGeometry")
	check(geometry ~= nil, "BodyGeometry missing")
	if geometry then
		local dorsal = geometry:FindFirstChild("DorsalPlates")
		check(dorsal ~= nil and #dorsal:GetChildren() == 7, "Exactly 7 storm shields required")
		for _, side in ipairs({"Left", "Right"}) do
			local foot = geometry:FindFirstChild(side .. "FootGeometry")
			check(foot ~= nil, side .. "FootGeometry missing")
			if foot then
				for i = 1, 3 do
					check(foot:FindFirstChild("ForwardClaw_" .. i) ~= nil, side .. " forward claw missing")
				end
				check(foot:FindFirstChild("RearClaw") ~= nil, side .. " rear claw missing")
			end
		end
	end

	local visible = 0
	local hitbox = 0
	for _, d in ipairs(model:GetDescendants()) do
		check(not (d:IsA("ParticleEmitter") or d:IsA("Light") or d:IsA("Sound")), d.ClassName .. " deferred to later phase")
		if d:IsA("BasePart") then
			if d.Transparency < 1 then visible += 1 end
			if d:FindFirstAncestor("Hitboxes_GeometryReviewOnly") then hitbox += 1 end
		end
	end
	model:SetAttribute("VisiblePartCount", visible)
	model:SetAttribute("GameplayHitboxCount", hitbox)
	check(visible <= Specification.PerformanceBudget.MaxVisibleParts, "Visible part budget exceeded")
	check(hitbox <= Specification.PerformanceBudget.MaxGameplayHitboxes, "Hitbox budget exceeded")
	return #issues == 0, issues
end

function Builder.Build(target: Instance, config: BuildConfig?): Model
	local existing = target:FindFirstChild(Specification.ModelName)
	if existing then existing:Destroy() end
	local model = build(target, (config and config.GroundCFrame) or CFrame.identity)
	local valid, issues = Builder.Validate(model)
	if not valid then
		for _, issue in ipairs(issues) do warn("[Bound Chimera] " .. issue) end
		error("Bound Chimera failed validation")
	end
	print("[Bound Chimera] Target-lineage Phase 4 Golden Master built | Awaiting Quality Gate B")
	return model
end

return Builder
