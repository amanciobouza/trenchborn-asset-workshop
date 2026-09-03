local Debris = game:GetService("Debris")

local SoundController = {}

local ASSETS = {
	IdleHum = 9112823813,
	Servo = 9118358110,
	Footstep = 9118240078,
	MetalImpact = 9116684884,
	SystemFailure = 9118996235,
	ElectricArc = 9116279561,
	RailPulse = 137510557013265,
}

local DEFINITIONS = {
	IdleHum = {asset = "IdleHum", volume = 0.13, speed = 0.52, looped = true, min = 14, max = 120, emitter = "UpperTorso"},
	FootstepWalk = {asset = "Footstep", volume = 0.7, speed = 0.64, min = 18, max = 155, emitter = "LeftFoot"},
	FootstepRun = {asset = "Footstep", volume = 0.82, speed = 0.72, min = 20, max = 170, emitter = "LeftFoot"},
	Land = {asset = "Footstep", volume = 0.92, speed = 0.55, min = 22, max = 185, emitter = "LeftFoot"},
	RailCharge = {asset = "ElectricArc", volume = 0.48, speed = 0.58, min = 18, max = 150, emitter = "RailMuzzleCore"},
	RailFire = {asset = "RailPulse", volume = 1.0, speed = 0.68, min = 28, max = 240, emitter = "RailMuzzleCore"},
	RailBass = {asset = "MetalImpact", volume = 0.72, speed = 0.5, min = 25, max = 215, emitter = "RailMuzzleCore"},
	SiegeWindup = {asset = "Servo", volume = 0.55, speed = 0.66, min = 14, max = 125, emitter = "UpperTorso"},
	RightSiegeImpact = {asset = "MetalImpact", volume = 0.82, speed = 0.68, min = 18, max = 165, emitter = "RightSiegeFist"},
	LeftSiegeImpact = {asset = "MetalImpact", volume = 0.82, speed = 0.65, min = 18, max = 165, emitter = "LeftSiegeFist"},
	SlamRise = {asset = "Servo", volume = 0.68, speed = 0.54, min = 16, max = 145, emitter = "UpperTorso"},
	GroundSlam = {asset = "Footstep", volume = 1.0, speed = 0.48, min = 28, max = 230, emitter = "HumanoidRootPart"},
	GroundSlamBass = {asset = "MetalImpact", volume = 0.9, speed = 0.44, min = 28, max = 230, emitter = "HumanoidRootPart"},
	ShieldCharge = {asset = "ElectricArc", volume = 0.48, speed = 0.7, min = 18, max = 155, emitter = "EmblemSpine"},
	ShieldDeploy = {asset = "IdleHum", volume = 0.65, speed = 1.28, min = 25, max = 220, emitter = "EmblemSpine"},
	Damage = {asset = "MetalImpact", volume = 0.7, speed = 0.68, min = 16, max = 145, emitter = "UpperTorso"},
	Stagger = {asset = "Servo", volume = 0.76, speed = 0.48, min = 18, max = 165, emitter = "UpperTorso"},
	Defeat = {asset = "SystemFailure", volume = 0.82, speed = 0.58, min = 20, max = 185, emitter = "UpperTorso"},
}

local function emitter(model, name)
	local item = model:FindFirstChild(name, true)
	if item and item:IsA("BasePart") then return item end
	if item and item:IsA("Model") then return item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true) end
	return model:FindFirstChild("UpperTorso") or model.PrimaryPart
end

local function template(model, name, definition)
	local sound = Instance.new("Sound")
	sound.Name = "BastionSFX_" .. name
	sound.SoundId = "rbxassetid://" .. ASSETS[definition.asset]
	sound.Volume = definition.volume
	sound.PlaybackSpeed = definition.speed
	sound.Looped = definition.looped == true
	sound.RollOffMode = Enum.RollOffMode.InverseTapered
	sound.RollOffMinDistance = definition.min
	sound.RollOffMaxDistance = definition.max
	sound.EmitterSize = math.max(6, definition.min * 0.55)
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
	idle:Play()
	request.Event:Connect(function(name, speedScale, volumeScale)
		if name == "Defeat" then idle:Stop() end
		if name == "Reset" then
			if not idle.IsPlaying then idle:Play() end
			return
		end
		local source = templates[name]
		if not source then return end
		if source.Looped then
			if not source.IsPlaying then source:Play() end
			return
		end
		local sound = source:Clone()
		sound.Name = source.Name .. "_OneShot"
		sound.PlaybackSpeed *= speedScale or 1
		sound.Volume *= volumeScale or 1
		sound.Parent = source.Parent
		sound:Play()
		Debris:AddItem(sound, math.max(3, sound.TimeLength + 1))
	end)
	local gameplay = model:FindFirstChild("Gameplay")
	local damageTaken = gameplay and gameplay:FindFirstChild("DamageTaken")
	local stateChanged = gameplay and gameplay:FindFirstChild("StateChanged")
	if damageTaken and damageTaken:IsA("BindableEvent") then
		damageTaken.Event:Connect(function(healthDamage)
			if healthDamage and healthDamage > 0 then request:Fire("Damage") end
		end)
	end
	if stateChanged and stateChanged:IsA("BindableEvent") then
		stateChanged.Event:Connect(function(state)
			if state == "Staggered" then request:Fire("Stagger")
			elseif state == "Defeated" then request:Fire("Defeat")
			elseif state == "Idle" then request:Fire("Reset") end
		end)
	end
	local abilityRequested = gameplay and gameplay:FindFirstChild("AbilityRequested")
	if abilityRequested and abilityRequested:IsA("BindableEvent") then
		abilityRequested.Event:Connect(function(name, _, ability)
			if name == "HeavyRailCannon" then
				request:Fire("RailCharge")
				task.delay(ability.TelegraphDuration or 1.55, function() request:Fire("RailFire"); request:Fire("RailBass") end)
			elseif name == "RightSiegeFist" or name == "LeftSiegeFist" then
				request:Fire("SiegeWindup")
				task.delay(0.58, function() request:Fire(name == "RightSiegeFist" and "RightSiegeImpact" or "LeftSiegeImpact") end)
			elseif name == "SiegeFistCombo" then
				request:Fire("SiegeWindup")
				task.delay(0.5, function() request:Fire("RightSiegeImpact") end)
				task.delay(0.94, function() request:Fire("LeftSiegeImpact") end)
			elseif name == "GroundSlam" then
				request:Fire("SlamRise")
				task.delay(ability.ImpactDelay or 1.02, function() request:Fire("GroundSlam"); request:Fire("GroundSlamBass") end)
			elseif name == "DistrictShield" then
				request:Fire("ShieldCharge")
				task.delay(1.55, function() request:Fire("ShieldDeploy") end)
			end
		end)
	end
	model:SetAttribute("BastionSoundPassVersion", "1.0")
	model:SetAttribute("BastionSoundSpatialized", true)
	model:SetAttribute("BastionSoundAssetSource", "RobloxCreatorStore")
	return request
end

return SoundController
