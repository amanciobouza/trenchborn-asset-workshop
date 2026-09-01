local ReplicatedStorage = game:GetService("ReplicatedStorage")
local KeyframeSequenceProvider = game:GetService("KeyframeSequenceProvider")
local TweenService = game:GetService("TweenService")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local library = require(packageFolder:WaitForChild("GuardianAnimationLibrary"))
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
	ShieldBlock = "BuildShieldBlock",
	PulseCannonFire = "BuildPulseCannonFire",
	ContainmentNetLaunch = "BuildContainmentNetLaunch",
}

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
	local sequence = library[builderName]()
	local temporaryId = KeyframeSequenceProvider:RegisterKeyframeSequence(sequence)
	local animation = Instance.new("Animation")
	animation.AnimationId = temporaryId
	local track = animator:LoadAnimation(animation)
	track.Looped = sequence.Loop
	track.Priority = priorityOverride or sequence.Priority
	return track
end

local function playMain(model, name)
	stopMain()
	activeModel = model
	if name ~= "Defeat" then
		defeated = false
		restorePower()
	end
	local builder = builders[name]
	if not builder then return end
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
		task.delay(1.3, function()
			if token == generation and defeated and mainTrack == track and track.IsPlaying then track:AdjustSpeed(0) end
		end)
	end
end

local function playReaction(model)
	if reactionTrack and reactionTrack.IsPlaying then reactionTrack:Stop(0.04) end
	reactionTrack = load(model, "BuildDamageReact", Enum.AnimationPriority.Action2)
	if reactionTrack then reactionTrack:Play(0.04) end
end

remote.OnClientEvent:Connect(function(name, model)
	if not model or not model.Parent then return end
	if name == "DamageReact" then playReaction(model) else playMain(model, name) end
end)
