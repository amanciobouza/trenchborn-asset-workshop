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
	return angular(parent, name, Vector3.new(width, depth, delta.Magnitude), CFrame.lookAt(middle, middle + delta), color)
end

local function detailFolder(model: Model): Folder
	local f = Instance.new("Folder"); f.Name = "BodyGeometry"; f.Parent = model; return f
end

local function buildFoot(model: Model, geometry: Folder, side: string, sign: number, lowerLeg: BasePart, ground: CFrame): BasePart
	local x = sign * 3.25
	local hock, toeBase = Vector3.new(x, 5.6, 1.35), Vector3.new(x, 1.25, -0.7)
	local foot = segment(model, side .. "Foot", hock, toeBase, 3.15, 2.65, ground, BODY)
	motor(lowerLeg, side .. "Ankle", lowerLeg, foot, ground * CFrame.new(hock))
	local folder = Instance.new("Folder"); folder.Name = side .. "FootGeometry"; folder.Parent = geometry
	for i, lateral in ipairs({-1.05, 0, 1.05}) do
		local toe = angular(folder, "ForwardToe_" .. i, Vector3.new(0.9, 0.78, 2.9), ground * CFrame.new(x + lateral, 0.7, -2.05) * CFrame.Angles(math.rad(-5), 0, 0), DARK); weld(foot, toe)
		local c = wedge(folder, "ForwardClaw_" .. i, Vector3.new(0.7, 0.62, 1.18), ground * CFrame.new(x + lateral, 0.58, -3.55) * CFrame.Angles(math.rad(-8), math.rad(180), 0), CLAW); weld(toe, c)
	end
	local rearToe = angular(folder, "RearToe", Vector3.new(0.75, 0.7, 1.35), ground * CFrame.new(x, 1.35, 0.9) * CFrame.Angles(math.rad(20), 0, 0), DARK); weld(foot, rearToe)
	local rearClaw = wedge(folder, "RearClaw", Vector3.new(0.56, 0.55, 0.95), ground * CFrame.new(x, 1.25, 1.7) * CFrame.Angles(math.rad(18), 0, 0), CLAW); weld(rearToe, rearClaw)
	return foot
end

local function buildArm(model: Model, geometry: Folder, side: string, sign: number, torso: BasePart, ground: CFrame)
	local shoulder = Vector3.new(sign * 4.1, 20.7, -0.05)
	local elbow = Vector3.new(sign * 5.1, 17.25, -0.45)
	local wrist = Vector3.new(sign * 4.85, 14.55, -0.9)
	local upper = segment(model, side .. "UpperArm", shoulder, elbow, 2.45, 2.25, ground, BODY); motor(torso, side .. "Shoulder", torso, upper, ground * CFrame.new(shoulder))
	local lower = segment(model, side .. "LowerArm", elbow, wrist, 2.1, 1.9, ground, BODY); motor(upper, side .. "Elbow", upper, lower, ground * CFrame.new(elbow))
	local hand = angular(model, side .. "Hand", Vector3.new(2.15, 1.45, 2.0), ground * CFrame.new(wrist + Vector3.new(0, -0.55, -0.35)) * CFrame.Angles(math.rad(-12), 0, 0), DARK); motor(lower, side .. "Wrist", lower, hand, ground * CFrame.new(wrist))
	local f = Instance.new("Folder"); f.Name = side .. "HandGeometry"; f.Parent = geometry
	for i = 1, 3 do
		local x = wrist.X + (i - 2) * 0.6
		local finger = angular(f, "Finger_" .. i, Vector3.new(0.48, 0.5, 1.15), ground * CFrame.new(x, wrist.Y - 1.05, wrist.Z - 1) * CFrame.Angles(math.rad(-18), 0, 0), DARK); weld(hand, finger)
	end
end

local function buildHead(model: Model, geometry: Folder, torso: BasePart, ground: CFrame): BasePart
	local head = angular(model, "Head", Vector3.new(5.4, 3.4, 4.1), ground * CFrame.new(0, 25.35, -1.0) * CFrame.Angles(math.rad(-5), 0, 0), BODY)
	motor(torso, "Neck", torso, head, ground * CFrame.new(0, 23.0, -0.25))
	local f = Instance.new("Folder"); f.Name = "HeadGeometry"; f.Parent = geometry
	-- Wedge slope runs from low front (-Z) to high rear (+Z).
	local crown = wedge(f, "WedgeCrown", Vector3.new(5.7, 1.6, 3.7), ground * CFrame.new(0, 26.15, -1.15), ARMOR); weld(head, crown)
	local muzzle = wedge(f, "BluntMuzzle", Vector3.new(4.4, 1.7, 2.8), ground * CFrame.new(0, 24.65, -2.95) * CFrame.Angles(0, math.rad(180), 0), DARK); weld(head, muzzle)
	local jaw = angular(model, "Jaw", Vector3.new(4.35, 1.25, 3.0), ground * CFrame.new(0, 23.9, -2.85) * CFrame.Angles(math.rad(4), 0, 0), DARK); motor(head, "JawJoint", head, jaw, ground * CFrame.new(0, 24.35, -1.75))
	for _, sign in ipairs({-1, 1}) do
		local eye = ellipsoid(f, sign < 0 and "LeftEye_GeometryOnly" or "RightEye_GeometryOnly", Vector3.new(0.6, 0.48, 0.34), ground * CFrame.new(sign * 2.12, 25.45, -2.95), EYE); weld(head, eye)
		local a = Instance.new("Attachment"); a.Name = "EyeEnergy"; a.Parent = eye
		local vent = wedge(f, sign < 0 and "LeftBreathingVent" or "RightBreathingVent", Vector3.new(0.35, 1.0, 1.45), ground * CFrame.new(sign * 2.65, 24.55, -1.7) * CFrame.Angles(0, sign * math.rad(90), 0), DARK); weld(head, vent)
	end
	return head
end

local function buildCounterbalance(model: Model, geometry: Folder, pelvis: BasePart, ground: CFrame): {BasePart}
	local points = {Vector3.new(0, 15.2, 2.2), Vector3.new(0, 13.6, 6.0), Vector3.new(0, 11.3, 9.4), Vector3.new(0, 8.5, 12.2), Vector3.new(0, 6.1, 14.2), Vector3.new(0, 4.5, 15.5)}
	local widths = {5.0, 4.5, 3.85, 3.15, 2.35}; local segments = {}; local host = pelvis
	for i = 1, #points - 1 do
		local s = segment(model, "RudderSegment_" .. i, points[i], points[i + 1], widths[i], widths[i] * 0.72, ground, BODY)
		motor(host, "RudderJoint_" .. i, host, s, ground * CFrame.new(points[i])); table.insert(segments, s); host = s
	end
	local armor = Instance.new("Folder"); armor.Name = "CounterbalanceArmor"; armor.Parent = geometry
	for i, hostPart in ipairs(segments) do
		local p = wedge(armor, "RudderKeel_" .. i, Vector3.new(1.2, 1.2 + (#segments - i) * 0.3, 2.2), ground * CFrame.new(0, 14.5 - i * 2.15, 3.6 + i * 2.6) * CFrame.Angles(math.rad(-24), 0, 0), ARMOR); weld(hostPart, p)
	end
	return segments
end

local function shatteredShield(folder: Folder, host: BasePart, index: number, pos: Vector3, scale: number, yaw: number, ground: CFrame)
	local assembly = Instance.new("Model"); assembly.Name = string.format("StormShield_%02d", index); assembly.Parent = folder
	-- Dorsal wedges stay vertical in the sagittal plane and lean backward only.
	local baseCF = ground * CFrame.new(pos) * CFrame.Angles(math.rad(-12), 0, math.rad(-4 + index % 3 * 4))
	local center = wedge(assembly, "CenterLobe", Vector3.new(1.15 * scale, 3.3 * scale, 2.5 * scale), baseCF, ARMOR); weld(host, center)
	for lobe = 1, 2 do
		local sign = lobe == 1 and -1 or 1
		local side = wedge(assembly, "FracturedLobe_" .. lobe, Vector3.new(0.75 * scale, 2.45 * scale, 1.55 * scale), baseCF * CFrame.new(sign * 0.68 * scale, -0.2 * scale, 0.15 * scale) * CFrame.Angles(0, sign * math.rad(8), sign * math.rad(9)), ARMOR); weld(host, side)
	end
	local seam = wedge(assembly, "EnergySeam_GeometryOnly", Vector3.new(0.16 * scale, 2.0 * scale, 1.2 * scale), baseCF * CFrame.new(0, 0, -0.12 * scale), ENERGY_REVIEW); weld(host, seam)
	local a = Instance.new("Attachment"); a.Name = string.format("DorsalEnergy_%02d", index); a.Parent = center; assembly.PrimaryPart = center
end

local function build(target: Instance, ground: CFrame): Model
	local model = Instance.new("Model"); model.Name = Specification.ModelName; model.Parent = target
	model:SetAttribute("AssetName", Specification.AssetName); model:SetAttribute("AssetId", Specification.AssetId)
	model:SetAttribute("PipelinePhase", 4); model:SetAttribute("PipelineStatus", "AWAITING_GEOMETRY_APPROVAL")
	model:SetAttribute("QualityGateA", "Approved"); model:SetAttribute("QualityGateB", "Pending"); model:SetAttribute("GeometryOnly", true)
	model:SetAttribute("EvolutionStage", 1); model:SetAttribute("EvolutionName", "Bound Chimera"); model:SetAttribute("DesignVersion", "2.0.0")
	model:SetAttribute("UprightDominant", true); model:SetAttribute("DigitigradeLegs", true); model:SetAttribute("DorsalShieldCount", 7)
	model:SetAttribute("ForwardClawsPerFoot", 3); model:SetAttribute("RearClawsPerFoot", 1); model:SetAttribute("DressingDeferredToPhase", 5)
	local geometry = detailFolder(model)
	local root = part(model, "HumanoidRootPart", Vector3.new(3, 3, 2), ground * CFrame.new(0, 14.8, 0), Color3.new(1,1,1)); root.Transparency = 1; root.Anchored = true; root.Massless = false; model.PrimaryPart = root
	local pelvis = angular(model, "LowerTorso", Vector3.new(8.2, 5.8, 5.5), ground * CFrame.new(0, 16.1, 0.35) * CFrame.Angles(math.rad(2), 0, 0), BODY); motor(root, "Root", root, pelvis, ground * CFrame.new(0, 14.9, 0))
	local torso = angular(model, "UpperTorso", Vector3.new(9.0, 7.2, 5.7), ground * CFrame.new(0, 21.0, -0.05) * CFrame.Angles(math.rad(-3), 0, 0), BODY); motor(pelvis, "Waist", pelvis, torso, ground * CFrame.new(0, 18.6, 0.1))
	local chest = wedge(geometry, "BarrelChestArmor", Vector3.new(7.2, 5.8, 1.15), ground * CFrame.new(0, 21.1, -3.0) * CFrame.Angles(0, math.rad(180), 0), BELLY); weld(torso, chest)
	for _, sign in ipairs({-1, 1}) do
		local shoulderArmor = wedge(geometry, sign < 0 and "LeftShoulderArmor" or "RightShoulderArmor", Vector3.new(3.0, 3.5, 2.2), ground * CFrame.new(sign * 4.45, 21.65, 0) * CFrame.Angles(0, sign * math.rad(90), 0), ARMOR)
		weld(torso, shoulderArmor)
		local hipArmor = wedge(geometry, sign < 0 and "LeftHipArmor" or "RightHipArmor", Vector3.new(2.8, 3.4, 2.35), ground * CFrame.new(sign * 4.25, 16.2, 0.25) * CFrame.Angles(0, sign * math.rad(90), 0), ARMOR)
		weld(pelvis, hipArmor)
	end
	local head = buildHead(model, geometry, torso, ground)
	buildArm(model, geometry, "Left", -1, torso, ground); buildArm(model, geometry, "Right", 1, torso, ground)
	for _, data in ipairs({{"Left", -1}, {"Right", 1}}) do
		local side, sign = data[1] :: string, data[2] :: number; local x = sign * 3.25
		local hip, knee, hock = Vector3.new(x, 15.8, 0.35), Vector3.new(x, 10.5, -1.45), Vector3.new(x, 5.6, 1.35)
		local upper = segment(model, side .. "UpperLeg", hip, knee, 4.8, 4.35, ground, BODY); motor(pelvis, side .. "Hip", pelvis, upper, ground * CFrame.new(hip))
		local lower = segment(model, side .. "LowerLeg", knee, hock, 4.0, 3.65, ground, BODY); motor(upper, side .. "Knee", upper, lower, ground * CFrame.new(knee))
		buildFoot(model, geometry, side, sign, lower, ground)
	end
	local rudder = buildCounterbalance(model, geometry, pelvis, ground)
	local dorsals = Instance.new("Folder"); dorsals.Name = "DorsalPlates"; dorsals.Parent = geometry
	local specs = {
		{head, Vector3.new(0, 26.3, 0.6), 0.55, -5}, {torso, Vector3.new(0, 24.0, 2.25), 0.78, 5},
		{torso, Vector3.new(0, 21.9, 2.8), 1.0, -6}, {torso, Vector3.new(0, 19.6, 2.9), 1.12, 7},
		{pelvis, Vector3.new(0, 17.1, 2.85), 0.95, -5}, {pelvis, Vector3.new(0, 14.9, 3.0), 0.73, 6},
		{rudder[1], Vector3.new(0, 13.5, 5.8), 0.52, -4},
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
