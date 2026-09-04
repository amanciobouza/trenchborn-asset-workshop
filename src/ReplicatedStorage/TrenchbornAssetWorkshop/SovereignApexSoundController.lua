local Debris = game:GetService("Debris")

local SoundController = {}

local ASSETS = {
	IdleHum = 9112823813,
	Servo = 9118358110,
	Footstep = 9118240078,
	MetalImpact = 9116684884,
	SystemFailure = 9118996235,
	ElectricArc = 9116279561,
	IonPulse = 137510557013265,
	TargetLock = 146785518,
}

local DEFINITIONS = {
	IdleHum = {asset = "IdleHum", volume = 0.09, speed = 1.02, looped = true, min = 12, max = 105, emitter = "SovereignLockCore"},
	FootstepWalk = {asset = "Footstep", volume = 0.58, speed = 0.94, min = 14, max = 130, emitter = "LeftFoot"},
	FootstepRun = {asset = "Footstep", volume = 0.68, speed = 1.06, min = 16, max = 145, emitter = "LeftFoot"},
	Land = {asset = "Footstep", volume = 0.76, speed = 0.84, min = 18, max = 155, emitter = "LeftFoot"},
	LanceWindup = {asset = "Servo", volume = 0.4, speed = 1.14, min = 12, max = 115, emitter = "LanceEmitterCore"},
	LanceThrust = {asset = "Servo", volume = 0.66, speed = 1.42, min = 16, max = 145, emitter = "LanceEmitterCore"},
	LanceCut = {asset = "Servo", volume = 0.72, speed = 1.08, min = 18, max = 155, emitter = "ApexEnergyBlade"},
	LanceImpact = {asset = "ElectricArc", volume = 0.54, speed = 1.16, min = 14, max = 135, emitter = "ApexEnergyBlade"},
	BeamCharge = {asset = "ElectricArc", volume = 0.48, speed = 0.92, min = 16, max = 145, emitter = "LanceEmitterCore"},
	BeamFire = {asset = "IonPulse", volume = 1, speed = 0.88, min = 26, max = 230, emitter = "ApexEnergyBlade"},
	BeamBass = {asset = "MetalImpact", volume = 0.5, speed = 0.64, min = 22, max = 195, emitter = "LeftLowerArm"},
	DroneCommand = {asset = "TargetLock", volume = 0.38, speed = 0.82, min = 12, max = 120, emitter = "SovereignLockCore"},
	DroneLaunch = {asset = "Servo", volume = 0.48, speed = 1.26, min = 12, max = 125, emitter = "UpperTorso"},
	DroneMark = {asset = "TargetLock", volume = 0.58, speed = 1.12, min = 18, max = 165, emitter = "SovereignLockCore"},
	DroneStrike = {asset = "IonPulse", volume = 0.58, speed = 1.18, min = 18, max = 175, emitter = "UpperTorso"},
	LockCharge = {asset = "ElectricArc", volume = 0.5, speed = 0.74, min = 18, max = 165, emitter = "SovereignLockCore"},
	LockEngage = {asset = "TargetLock", volume = 0.72, speed = 0.68, min = 24, max = 210, emitter = "SovereignLockCore"},
	LockHum = {asset = "IdleHum", volume = 0.22, speed = 1.32, looped = true, min = 20, max = 185, emitter = "SovereignLockCore"},
	Damage = {asset = "MetalImpact", volume = 0.56, speed = 1.02, min = 14, max = 125, emitter = "UpperTorso"},
	Stagger = {asset = "Servo", volume = 0.7, speed = 0.78, min = 16, max = 145, emitter = "UpperTorso"},
	Defeat = {asset = "SystemFailure", volume = 0.72, speed = 0.7, min = 18, max = 165, emitter = "UpperTorso"},
}

local function emitter(model, name)
	local item = model:FindFirstChild(name, true)
	if item and item:IsA("BasePart") then return item end
	if item and item:IsA("Model") then return item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true) end
	return model:FindFirstChild("UpperTorso") or model.PrimaryPart
end

local function template(model, name, definition)
	local sound = Instance.new("Sound")
	sound.Name = "SovereignSFX_" .. name
	sound.SoundId = "rbxassetid://" .. ASSETS[definition.asset]
	sound.Volume = definition.volume
	sound.PlaybackSpeed = definition.speed
	sound.Looped = definition.looped == true
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = definition.min
	sound.RollOffMaxDistance = definition.max
	sound.EmitterSize = math.max(5, definition.min * 0.55)
	sound.Parent = emitter(model, definition.emitter)
	return sound
end

function SoundController.Attach(model)
	local old = model:FindFirstChild("GuardianSoundscape")
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = "GuardianSoundscape"
	folder.Parent = model
	local request = Instance.new("BindableEvent")
	request.Name = "SoundRequested"
	request.Parent = folder

	local templates = {}
	for name, definition in pairs(DEFINITIONS) do templates[name] = template(model, name, definition) end
	local idle = templates.IdleHum
	local lockHum = templates.LockHum
	idle:Play()

	local function play(name, speedScale, volumeScale)
		local source = templates[name]
		if not source then return nil end
		if source.Looped then
			if not source.IsPlaying then source:Play() end
			return source
		end
		local sound = source:Clone()
		sound.Name = source.Name .. "_OneShot"
		sound.PlaybackSpeed *= speedScale or 1
		sound.Volume *= volumeScale or 1
		sound.Parent = source.Parent
		sound:Play()
		Debris:AddItem(sound, math.max(3, sound.TimeLength + 1))
		return sound
	end

	request.Event:Connect(function(name, speedScale, volumeScale)
		if name == "Defeat" then
			idle:Stop()
			lockHum:Stop()
			play("Defeat", speedScale, volumeScale)
			return
		elseif name == "Reset" then
			lockHum:Stop()
			if not idle.IsPlaying then idle:Play() end
			return
		elseif name == "LockRelease" then
			lockHum:Stop()
			return
		elseif name == "LockEngage" then
			play("LockEngage", speedScale, volumeScale)
			play("LockHum")
			return
		end
		play(name, speedScale, volumeScale)
	end)

	model:SetAttribute("SovereignSoundPassVersion", "1.0")
	model:SetAttribute("SovereignSoundSpatialized", true)
	model:SetAttribute("SovereignSoundAssetSource", "RobloxCreatorStore")
	return request
end

return SoundController
