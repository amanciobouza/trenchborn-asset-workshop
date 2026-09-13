-- Build immutable rest joints once. Runtime animation belongs to clients.
local Skeleton={}
local CYCLE_SECONDS=1.9
function Skeleton.Build(model,movementRoot)
	local stage=model:GetAttribute("EvolutionStage")
	assert(type(stage)=="number" and stage%1==0 and stage>=1 and stage<=5,"Unsupported Kaiju stage")
	assert(not model:FindFirstChild("Articulation"), "Rig already attached")
	local function get(name)
		local p = model:FindFirstChild(name)
		assert(p and p:IsA("BasePart"), "Missing rig source: " .. name)
		return p
	end
	local visuals = {}

	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") then table.insert(visuals, p) end
	end
	local basis = get("PelvisCenter").CFrame.Rotation
	local rootRestFrame=get("PelvisCenter").CFrame
	local folder = Instance.new("Folder")
	folder.Name = "Articulation"
	folder.Parent = model
	local bones, motors, rest = {}, {}, {}
	local function bone(name, position, parentName)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = Vector3.new(0.2, 0.2, 0.2)
		p.CFrame = CFrame.new(position) * basis
		p.Transparency = 1
		p.CanCollide, p.CanTouch, p.CanQuery = false, false, false
		p.CastShadow = false
		p.Massless = true
		p.Anchored = parentName == nil
		p.Parent = folder
		bones[name] = p
		p:SetAttribute("RigRestFrame",rootRestFrame:ToObjectSpace(p.CFrame))
		if parentName then
			local m = Instance.new("Motor6D")
			m.Name = name .. "Joint"
			m.Part0, m.Part1 = bones[parentName], p
			m.C0 = m.Part0.CFrame:ToObjectSpace(p.CFrame)
			m.C1 = CFrame.identity
			m.Parent = m.Part0
			motors[name], rest[name] = m, m.C0
		end
	end
	bone("Pelvis", get("PelvisCenter").Position)
	bone("Torso", get("LowerAbdomen").Position, "Pelvis")
	bone("Head", get("Neck").Position, "Torso")
	bone("Jaw", get("LowerJawRear").Position, "Head")
	for _, side in ipairs({"Left", "Right"}) do
		bone(side .. "UpperArm", get(side .. "ShoulderJoint").Position, "Torso")
		bone(side .. "Forearm", get(side .. "ElbowJoint").Position, side .. "UpperArm")
		bone(side .. "Hand", get(side .. "WristJoint").Position, side .. "Forearm")
		bone(side .. "Thigh", get(side .. "HipJoint").Position, "Pelvis")
		bone(side .. "Shin", get(side .. "KneeJoint").Position, side .. "Thigh")
		bone(side .. "Hock", get(side .. "HockJoint").Position, side .. "Shin")
		bone(side .. "Foot", get(side .. "AnkleJoint").Position, side .. "Hock")
	end
	local tailCount = 0
	while model:FindFirstChild(string.format("TailSegment_%02d", tailCount + 1)) do
		tailCount = tailCount + 1
	end
	assert(tailCount >= 7, "Incomplete tail")
	bone("TailBase",get("SacralMass").Position,"Pelvis")
	for i = 1, tailCount do
		local segment = get(string.format("TailSegment_%02d", i))
		bone("Tail" .. i, segment.Position - segment.CFrame.RightVector * segment.Size.X/2,
			i == 1 and "TailBase" or "Tail" .. (i-1))
	end
	local headNames = {Cranium=true, SnoutBridge=true, FrontalBridge=true}
	local headFeatures = {CheekMass=true, OrbitalSupport=true, BrowRidge=true, EyeSocket=true,
		Eye=true, Pupil=true, EyeHighlight=true, Nostril=true}
	local armUpper = {ShoulderJoint=true, Deltoid=true, UpperArm=true, BicepsMass=true}
	local armLower = {ElbowJoint=true, Forearm=true, ForearmMass=true, ForearmFlexor=true, ForearmTaper=true}
	local thighs = {HipJoint=true, ThighMass=true, OuterQuadriceps=true, UpperLeg=true}
	local shins = {KneeJoint=true, CalfMass=true, LowerLeg=true}
	local pelvisNames = {PelvisCenter=true, SacralMass=true, TailRootMass=true}
	local function starts(name, prefix) return string.sub(name, 1, #prefix) == prefix end
	local function region(name)
		if name == "TailRootMass" then return "TailBase" end
		if name == "TailTip" then return "Tail" .. tailCount end
		if starts(name, "LowerJaw") then return "Jaw" end
		if headNames[name] or starts(name, "UpperMuzzle") then return "Head" end
		local tail = string.match(name, "^TailSegment_(%d+)$")
		if tail then return "Tail" .. tonumber(tail) end
		local plate = tonumber(string.match(name, "^DorsalShield_(%d+)") or string.match(name, "^DorsalEnergy_(%d+)") or string.match(name, "^DorsalRock_(%d+)"))
		if plate then return plate <= 3 and "Torso" or "Tail" .. (plate-2) end
		if pelvisNames[name] then return "Pelvis" end
		for _, side in ipairs({"Left", "Right"}) do
			if starts(name, side) then
				local suffix = string.sub(name, #side+1)
				if headFeatures[suffix] or starts(suffix,"HeadArmor") then return "Head" end
				if starts(suffix,"RibArmor") then return "Torso" end
				if armUpper[suffix] or starts(suffix,"ShoulderArmor") then return side .. "UpperArm" end
				if armLower[suffix] or starts(suffix,"ForearmArmor") then return side .. "Forearm" end
				if suffix == "WristJoint" or starts(suffix, "Palm") or starts(suffix, "Finger")
					or starts(suffix, "Knuckle") or starts(suffix, "Hand") or starts(suffix, "Thumb") then return side .. "Hand" end
				if thighs[suffix] or starts(suffix,"HipArmor") then return side .. "Thigh" end
				if shins[suffix] or starts(suffix,"ShinArmor") then return side .. "Shin" end
				if suffix == "HockJoint" or suffix == "Metatarsal" then return side .. "Hock" end
				if suffix == "AnkleJoint" or suffix == "InstepFlow" or starts(suffix, "Heel") or starts(suffix, "Forefoot")
					or starts(suffix, "Toe") or starts(suffix, "FrontClaw") or suffix == "RearClaw" then return side .. "Foot" end
				if suffix == "HipMass" then return "Pelvis" end
			end
		end
		return "Torso"
	end
	for _, p in ipairs(visuals) do
		local name = region(p.Name)
		assert(bones[name], "Unknown region: " .. name)
		local weld = Instance.new("WeldConstraint")
		weld.Name = "RigWeld"
		weld.Part0, weld.Part1 = bones[name], p
		weld.Parent = p
		p:SetAttribute("RigRegion", name)
		p:SetAttribute("RigLocalFrame",bones[name].CFrame:ToObjectSpace(p.CFrame))
		p.Massless = true
		p.Anchored = false
	end
	model.PrimaryPart = bones.Pelvis
	model:SetAttribute("RigType", "CustomMotor6D_Stage"..stage)
	model:SetAttribute("FocusRigRevision", "MouthDiagnostic_01")
	model:SetAttribute("RigJointCount", 19 + tailCount)
	model:SetAttribute("PipelinePhase", 6)
	model:SetAttribute("QualityGateC", "Pending")
	model:SetAttribute("AttackReach", "LowBuildings")
	model:SetAttribute("IdleEnabled", true)
	model:SetAttribute("AnimationMode", "Walk")
	model:SetAttribute("WalkCycleSeconds", CYCLE_SECONDS)
	model:SetAttribute("AnimationPreview", "WalkInPlace_01")
	local rootRest = bones.Pelvis.CFrame
	model:SetAttribute("RigRestRotation",rootRest.Rotation)
	local rootJoint, rootOffset
	if movementRoot then
		rootOffset = movementRoot.CFrame:ToObjectSpace(rootRest)
		rootJoint = Instance.new("Motor6D")
		rootJoint.Name = "KaijuLocomotionRoot"
		rootJoint.Part0, rootJoint.Part1 = movementRoot, bones.Pelvis
		rootJoint.C0 = rootOffset
		rootJoint.Parent = folder
		bones.Pelvis.Anchored = false
		model:SetAttribute("AnimationMode", "Automatic")
	end

 model:SetAttribute("KaijuRigTailCount",tailCount)
 model:SetAttribute("KaijuRigVisualCount",#visuals)
 model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 for _,m in pairs(motors) do m:SetAttribute("ClientPresentation",true) end
 if rootJoint then rootJoint:SetAttribute("ClientPresentation",true) end
 return {Bones=bones,Motors=motors,Rest=rest,Root=rootJoint,Offset=rootOffset,RestFrame=rootRest,Folder=folder,Visuals=visuals}
end
return Skeleton
