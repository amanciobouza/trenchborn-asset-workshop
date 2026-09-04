local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local library = require(packageFolder:WaitForChild("GuardianAnimationLibrary"))
local bastionLibrary = require(packageFolder:WaitForChild("BastionAnimationLibrary"))
local sovereignLibrary = require(packageFolder:WaitForChild("SovereignAnimationLibrary"))
local weaponInertia = require(packageFolder:WaitForChild("GuardianWeaponInertia"))
local remote = ReplicatedStorage:WaitForChild(script:GetAttribute("RemoteName"))

local mainTrack
local reactionTrack
local activeModel
local generation = 0
local defeated = false
local visualState = {}

local builders = {
	Idle = "BuildIdle",
	AlertIdle = "BuildAlertIdle",
	Walk = "BuildWalk",
	Run = "BuildRun",
	WalkBackward = "BuildWalkBackward",
	TurnLeft = "BuildTurnLeft",
	TurnRight = "BuildTurnRight",
	Fall = "BuildFall",
	Land = "BuildLand",
	Stagger = "BuildStagger",
	Defeat = "BuildDefeat",
	ShockBaton = "BuildShockBaton",
	WarningPulse = "BuildWarningPulse",
	ShieldBlock = "BuildShieldBlock",
	PulseCannonFire = "BuildPulseCannonFire",
	ContainmentNetLaunch = "BuildContainmentNetLaunch",
	TwinIonCannons = "BuildTwinIonCannons",
	ShoulderMissileSalvo = "BuildShoulderMissileSalvo",
	DirectionalAegis = "BuildAlertIdle",
	HeavyRailCannon = "BuildHeavyRailCannon",
	RightSiegeFist = "BuildRightSiegeFist",
	LeftSiegeFist = "BuildLeftSiegeFist",
	SiegeFistCombo = "BuildSiegeFistCombo",
	GroundSlam = "BuildGroundSlam",
	DistrictShield = "BuildDistrictShield",
	ApexLanceThrust = "BuildApexLanceThrust",
	ApexLanceCut = "BuildApexLanceCut",
	ApexLanceBeam = "BuildApexLanceBeam",
	HunterDrones = "BuildHunterDroneCommand",
	SovereignLock = "BuildSovereignLock",
}

local railAimNeutral = setmetatable({}, {__mode = "k"})
local railAimGeneration = 0

local function targetPosition(target)
	if typeof(target) ~= "Instance" then return nil end
	if target:IsA("BasePart") then return target.Position end
	if target:IsA("Model") then
		for _, name in ipairs({"UpperTorso", "Torso", "HumanoidRootPart"}) do
			local part = target:FindFirstChild(name, true)
			if part and part:IsA("BasePart") then return part.Position end
		end
		local boxCFrame, boxSize = target:GetBoundingBox()
		return boxCFrame.Position + Vector3.new(0, boxSize.Y * 0.05, 0)
	end
	return nil
end

local function trackRailAim(model, target)
	local joint = model:FindFirstChild("HeavyRailCannonMount", true)
	local muzzle = model:FindFirstChild("RailMuzzleCore", true)
	if not joint or not joint:IsA("Motor6D") or not muzzle or not joint.Part0 then return end
	if not railAimNeutral[joint] then railAimNeutral[joint] = joint.C0 end
	local neutral = railAimNeutral[joint]
	railAimGeneration += 1
	local token = railAimGeneration
	local started = os.clock()
	local connection
	connection = RunService.RenderStepped:Connect(function(deltaTime)
		if token ~= railAimGeneration or not model.Parent or not joint.Parent or os.clock() - started >= 1.55 then
			connection:Disconnect()
			task.delay(1.05, function()
				if token == railAimGeneration and joint.Parent then
					TweenService:Create(joint, TweenInfo.new(0.28), {C0 = neutral}):Play()
				end
			end)
			return
		end
		local point = targetPosition(target)
		if not point then return end
		local direction = point - muzzle.Position
		if direction.Magnitude < 1 then return end
		local localDirection = joint.Part0.CFrame:VectorToObjectSpace(direction.Unit)
		local pitch = math.clamp(math.asin(math.clamp(localDirection.Y, -1, 1)), math.rad(-28), math.rad(32))
		local yaw = math.clamp(math.atan2(-localDirection.X, -localDirection.Z), math.rad(-48), math.rad(48))
		local desired = neutral * CFrame.Angles(pitch, yaw, 0)
		joint.C0 = joint.C0:Lerp(desired, 1 - math.exp(-deltaTime / 0.12))
	end)
end

local function restorePower()
	for instance, state in pairs(visualState) do
		if instance.Parent then
			if instance:IsA("BasePart") then
				instance.Color = state.Color
				instance.Material = state.Material
			elseif instance:IsA("Light") or instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
				instance.Enabled = state.Enabled
			end
		end
	end
	visualState = {}
end

local function powerDown(model)
	restorePower()
	for _, instance in ipairs(model:GetDescendants()) do
		if instance:IsA("BasePart") and instance.Material == Enum.Material.Neon then
			visualState[instance] = {Color = instance.Color, Material = instance.Material}
			TweenService:Create(instance, TweenInfo.new(0.42), {Color = Color3.fromRGB(8, 17, 20)}):Play()
			task.delay(0.43, function()
				if defeated and instance.Parent then instance.Material = Enum.Material.SmoothPlastic end
			end)
		elseif instance:IsA("Light") or instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") then
			visualState[instance] = {Enabled = instance.Enabled}
			instance.Enabled = false
		end
	end
end

local function stopMain()
	generation += 1
	if mainTrack then
		mainTrack:AdjustSpeed(1)
		mainTrack:Stop(0.12)
		mainTrack = nil
	end
end

local function load(model, builderName, priorityOverride)
	local animator = model:FindFirstChildWhichIsA("Animator", true)
	if not animator then return nil end
	local isBastion = model:GetAttribute("AssetName") == "Bastion-IV Colossus"
		or model.Name == "Bastion_IV_Colossus_GoldenMaster"
		or model:FindFirstChild("HeavyRailCannonMount", true) ~= nil
	local isSovereign = model:GetAttribute("AssetName") == "Sovereign-V Apex"
		or model.Name == "Sovereign_V_Apex_GoldenMaster"
		or model:FindFirstChild("SovereignLockCore", true) ~= nil
	local selectedLibrary = isBastion and bastionLibrary or (isSovereign and sovereignLibrary or library)
	local sequence = selectedLibrary[builderName]()
	local temporaryId = KeyframeSequenceProvider:RegisterKeyframeSequence(sequence)
	local animation = Instance.new("Animation")
	animation.AnimationId = temporaryId
	local track = animator:LoadAnimation(animation)
	track.Looped = sequence.Loop
	track.Priority = priorityOverride or sequence.Priority
	return track
end

local function playMain(model, name, target)
	weaponInertia.Ensure(model)
	stopMain()
	activeModel = model
	if name ~= "Defeat" then
		defeated = false
		restorePower()
	end
	local builder = builders[name]
	if not builder then return end
	if name == "HeavyRailCannon" then trackRailAim(model, target) end
	mainTrack = load(model, builder)
	if not mainTrack then return end
	local track = mainTrack
	local token = generation
	track:Play(0.2)
	if name == "ShieldBlock" then
		task.delay(0.72, function()
			if token == generation and mainTrack == track and track.IsPlaying then track:AdjustSpeed(0) end
		end)
	elseif name == "Defeat" then
		defeated = true
		task.delay(0.22, function() if defeated then powerDown(model) end end)
		local holdDelay = model:GetAttribute("AssetName") == "Sovereign-V Apex" and 2.05 or 1.3
		task.delay(holdDelay, function()
			if token == generation and defeated and mainTrack == track and track.IsPlaying then track:AdjustSpeed(0) end
		end)
	end
end

local function playReaction(model)
	if reactionTrack and reactionTrack.IsPlaying then reactionTrack:Stop(0.04) end
	reactionTrack = load(model, "BuildDamageReact", Enum.AnimationPriority.Action2)
	if reactionTrack then reactionTrack:Play(0.04) end
end

remote.OnClientEvent:Connect(function(name, model, target)
	if not model or not model.Parent then return end
	if name == "DamageReact" then playReaction(model) else playMain(model, name, target) end
end)
