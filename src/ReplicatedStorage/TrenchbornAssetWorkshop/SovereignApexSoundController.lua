local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local SoundController = {}

local ASSETS = {
	IdleHum = 9112823813,
	Servo = 9118358110,
	Footstep = 9118240078,
	MetalImpact = 9116684884,
	SystemFailure = 9118996235,
	ElectricArc = 9116279561,
	IonPulse = 137510557013265,
	LaserLanceWhoosh = 82467115405633,
	LaserLanceImpact = 76479464051898,
	SovereignLockBeam = 102065163712158,
	ApexBeamCharge = 127373754810578,
	DroneAlignment = 137012860130376,
}

local DEFINITIONS = {
	IdleHum = {asset = "IdleHum", volume = 0.09, speed = 1.02, looped = true, min = 12, max = 105, emitter = "SovereignLockCore"},
	FootstepWalk = {asset = "Footstep", volume = 0.58, speed = 0.94, min = 14, max = 130, emitter = "LeftFoot"},
	FootstepRun = {asset = "Footstep", volume = 0.68, speed = 1.06, min = 16, max = 145, emitter = "LeftFoot"},
	Land = {asset = "Footstep", volume = 0.76, speed = 0.84, min = 18, max = 155, emitter = "LeftFoot"},
	LanceWindup = {asset = "Servo", volume = 0.4, speed = 1.14, min = 12, max = 115, emitter = "LanceEmitterCore"},
	LanceHum = {asset = "IdleHum", volume = 0.22, speed = 0.78, looped = true, min = 16, max = 155, emitter = "ApexEnergyBlade"},
	LanceWhoosh = {asset = "LaserLanceWhoosh", volume = 0.76, speed = 1.04, min = 20, max = 190, emitter = "ApexEnergyBlade"},
	LanceReturnWhoosh = {asset = "LaserLanceWhoosh", volume = 0.5, speed = 0.84, min = 18, max = 170, emitter = "ApexEnergyBlade"},
	LanceImpact = {asset = "MetalImpact", volume = 0.74, speed = 0.86, min = 20, max = 175, emitter = "ApexEnergyBlade"},
	LanceImpactBass = {asset = "MetalImpact", volume = 0.58, speed = 0.44, min = 26, max = 220, emitter = "LeftLowerArm"},
	LanceCutTail = {asset = "LaserLanceImpact", volume = 0.22, speed = 1.12, min = 16, max = 145, emitter = "ApexEnergyBlade"},
	BeamCharge = {asset = "ApexBeamCharge", volume = 0.24, speed = 0.86, min = 16, max = 165, emitter = "LanceEmitterCore"},
	BeamFire = {asset = "IonPulse", volume = 1, speed = 0.88, min = 26, max = 230, emitter = "ApexEnergyBlade"},
	BeamBass = {asset = "MetalImpact", volume = 0.5, speed = 0.64, min = 22, max = 195, emitter = "LeftLowerArm"},
	DroneLaunch = {asset = "Servo", volume = 0.48, speed = 1.26, min = 12, max = 125, emitter = "UpperTorso"},
	DroneChirp = {asset = "DroneAlignment", volume = 0.2, speed = 1, min = 12, max = 125, emitter = "SovereignLockCore"},
	DroneStrike = {asset = "IonPulse", volume = 0.58, speed = 1.18, min = 18, max = 175, emitter = "UpperTorso"},
	LockCharge = {asset = "Servo", volume = 0.44, speed = 0.62, min = 18, max = 165, emitter = "SovereignLockCore"},
	LockEngage = {asset = "MetalImpact", volume = 0.48, speed = 0.48, min = 24, max = 210, emitter = "SovereignLockCore"},
	LockBeam = {asset = "SovereignLockBeam", volume = 0.82, speed = 0.94, min = 24, max = 225, emitter = "SovereignLockCore"},
	LockHum = {asset = "IdleHum", volume = 0.34, speed = 0.56, looped = true, min = 22, max = 210, emitter = "SovereignLockCore"},
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
	local beamCharge = templates.BeamCharge
	local lanceHum = templates.LanceHum
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

	local function playLanceSweep(name, speedScale, volumeScale)
		local source = templates[name]
		local sound = play(name, speedScale, volumeScale)
		if not source or not sound then return end
		local targetSpeed = source.PlaybackSpeed * (speedScale or 1)
		local targetVolume = source.Volume * (volumeScale or 1)
		sound.PlaybackSpeed = targetSpeed * 0.76
		sound.Volume = targetVolume * 0.32
		local rise = TweenService:Create(sound, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			PlaybackSpeed = targetSpeed * 1.12,
			Volume = targetVolume,
		})
		rise:Play()
		rise.Completed:Once(function()
			if not sound.Parent then return end
			TweenService:Create(sound, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				PlaybackSpeed = targetSpeed * 0.9,
				Volume = targetVolume * 0.2,
			}):Play()
		end)
	end

	local function playCutTail(speedScale, volumeScale)
		local sound = play("LanceCutTail", speedScale, volumeScale)
		if not sound then return end
		task.delay(0.42, function()
			if not sound.Parent then return end
			local fade = TweenService:Create(sound, TweenInfo.new(0.12), {Volume = 0})
			fade:Play()
			fade.Completed:Once(function() sound:Stop() end)
		end)
	end

	request.Event:Connect(function(name, speedScale, volumeScale)
		if name == "Defeat" then
			idle:Stop()
			lockHum:Stop()
			beamCharge:Stop()
			lanceHum:Stop()
			play("Defeat", speedScale, volumeScale)
			return
		elseif name == "Reset" then
			lockHum:Stop()
			beamCharge:Stop()
			lanceHum:Stop()
			if not idle.IsPlaying then idle:Play() end
			return
		elseif name == "LockRelease" then
			lockHum:Stop()
			return
		elseif name == "LanceHumStart" then
			lanceHum:Stop()
			lanceHum.Volume = 0.18
			lanceHum.PlaybackSpeed = 0.74
			lanceHum:Play()
			TweenService:Create(lanceHum, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0.3,
				PlaybackSpeed = 0.88,
			}):Play()
			return
		elseif name == "LanceHumStop" then
			local fade = TweenService:Create(lanceHum, TweenInfo.new(0.2), {Volume = 0})
			fade:Play()
			fade.Completed:Once(function() lanceHum:Stop() end)
			return
		elseif name == "LanceWhoosh" or name == "LanceReturnWhoosh" then
			playLanceSweep(name, speedScale, volumeScale)
			return
		elseif name == "LanceCutTail" then
			playCutTail(speedScale, volumeScale)
			return
		elseif name == "LockEngage" then
			play("LockEngage", speedScale, volumeScale)
			play("LockBeam")
			play("LockHum")
			return
		elseif name == "BeamCharge" then
			beamCharge:Stop()
			beamCharge.Volume = 0.2
			beamCharge.PlaybackSpeed = 0.82
			beamCharge:Play()
			TweenService:Create(beamCharge, TweenInfo.new(1.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Volume = 0.5,
				PlaybackSpeed = 1.16,
			}):Play()
			return
		elseif name == "BeamFire" then
			beamCharge:Stop()
			play("BeamFire", speedScale, volumeScale)
			return
		end
		play(name, speedScale, volumeScale)
	end)

	model:SetAttribute("SovereignSoundPassVersion", "1.8")
	model:SetAttribute("SovereignSoundSpatialized", true)
	model:SetAttribute("SovereignSoundAssetSource", "RobloxCreatorStore")
	return request
end

return SoundController
