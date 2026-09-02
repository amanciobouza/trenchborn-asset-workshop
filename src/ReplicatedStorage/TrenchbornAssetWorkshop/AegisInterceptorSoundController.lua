local Debris = game:GetService("Debris")

local SoundController = {}

local ASSETS = {
	IdleHum = 9112823813,
	Servo = 9118358110,
	Footstep = 9118240078,
	MetalImpact = 9116684884,
	SystemFailure = 9118996235,
	ElectricArc = 9116279561,
	IonShot = 9116231442,
	TargetLock = 146785518,
}

local DEFINITIONS = {
	IdleHum = {asset = "IdleHum", volume = 0.1, speed = 0.93, looped = true, min = 10, max = 78, emitter = "UpperTorso"},
	Servo = {asset = "Servo", volume = 0.27, speed = 1.04, min = 8, max = 62, emitter = "UpperTorso"},
	FootstepWalk = {asset = "Footstep", volume = 0.5, speed = 0.9, min = 12, max = 110, emitter = "LeftFoot"},
	FootstepRun = {asset = "Footstep", volume = 0.62, speed = 1.0, min = 14, max = 130, emitter = "LeftFoot"},
	Land = {asset = "Footstep", volume = 0.74, speed = 0.78, min = 16, max = 145, emitter = "LeftFoot"},
	Damage = {asset = "MetalImpact", volume = 0.48, speed = 0.96, min = 10, max = 105, emitter = "UpperTorso"},
	Stagger = {asset = "Servo", volume = 0.58, speed = 0.7, min = 12, max = 115, emitter = "UpperTorso"},
	Defeat = {asset = "SystemFailure", volume = 0.58, speed = 0.78, min = 14, max = 130, emitter = "UpperTorso"},
	IonCharge = {asset = "TargetLock", volume = 0.28, speed = 1.12, min = 10, max = 88, emitter = "AegisCore"},
	LeftIonShot = {asset = "IonShot", volume = 0.68, speed = 0.96, min = 18, max = 170, emitter = "LeftIonCannon"},
	RightIonShot = {asset = "IonShot", volume = 0.68, speed = 1.02, min = 18, max = 170, emitter = "RightIonCannon"},
	MissileLock = {asset = "TargetLock", volume = 0.44, speed = 0.9, min = 10, max = 95, emitter = "LeftShoulderMissilePod"},
	MissileLaunchLeft = {asset = "Servo", volume = 0.5, speed = 1.18, min = 14, max = 125, emitter = "LeftShoulderMissilePod"},
	MissileLaunchRight = {asset = "Servo", volume = 0.5, speed = 1.22, min = 14, max = 125, emitter = "RightShoulderMissilePod"},
	AegisDeploy = {asset = "ElectricArc", volume = 0.62, speed = 0.76, min = 16, max = 145, emitter = "AegisCore"},
	AegisHum = {asset = "IdleHum", volume = 0.19, speed = 1.25, looped = true, min = 12, max = 105, emitter = "AegisCore"},
	AegisImpact = {asset = "ElectricArc", volume = 0.42, speed = 0.9, min = 12, max = 120, emitter = "AegisCore"},
}

local function emitter(model, name)
	local item = model:FindFirstChild(name, true)
	if item and item:IsA("BasePart") then return item end
	if item and item:IsA("Model") then return item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart", true) end
	return model:FindFirstChild("UpperTorso") or model.PrimaryPart
end

local function makeSound(parent, name, definition)
	local item = Instance.new("Sound")
	item.Name = "AegisSFX_" .. name
	item.SoundId = "rbxassetid://" .. ASSETS[definition.asset]
	item.Volume = definition.volume
	item.PlaybackSpeed = definition.speed
	item.Looped = definition.looped == true
	item.RollOffMode = Enum.RollOffMode.InverseTapered
	item.RollOffMinDistance = definition.min
	item.RollOffMaxDistance = definition.max
	item.EmitterSize = math.max(4, definition.min * 0.55)
	item.Parent = parent
	return item
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
	for name, definition in pairs(DEFINITIONS) do
		templates[name] = makeSound(emitter(model, definition.emitter), name, definition)
	end
	local function play(name, speedScale, volumeScale)
		local template = templates[name]
		if not template then return nil end
		if template.Looped then
			if not template.IsPlaying then template:Play() end
			return template
		end
		local item = template:Clone()
		item.Name = template.Name .. "_OneShot"
		item.PlaybackSpeed *= speedScale or 1
		item.Volume *= volumeScale or 1
		item.Parent = template.Parent
		item:Play()
		Debris:AddItem(item, math.max(3, item.TimeLength + 1))
		return item
	end
	request.Event:Connect(play)

	local idle = templates.IdleHum
	local aegisHum = templates.AegisHum
	idle:Play()
	local gameplay = model:WaitForChild("Gameplay")
	gameplay:WaitForChild("AbilityRequested").Event:Connect(function(name, _, config)
		if name == "TwinIonCannons" then
			play("IonCharge")
			task.delay(config.TelegraphDuration or 0.55, function()
				if model:GetAttribute("GuardianState") ~= "Defeated" then play("LeftIonShot") end
			end)
			task.delay((config.TelegraphDuration or 0.55) + 0.2, function()
				if model:GetAttribute("GuardianState") ~= "Defeated" then play("RightIonShot") end
			end)
		elseif name == "ShoulderMissiles" then
			play("MissileLock")
			task.delay(config.LockDuration or 2, function()
				if model:GetAttribute("GuardianState") == "Defeated" then return end
				for index = 1, 4 do
					task.delay((index - 1) * 0.11, function() play("MissileLaunchLeft", 0.98 + index * 0.015) end)
				end
				task.delay(0.62, function()
					for index = 1, 4 do
						task.delay((index - 1) * 0.11, function() play("MissileLaunchRight", 0.98 + index * 0.015) end)
					end
				end)
			end)
		elseif name == "DirectionalAegis" then
			play("AegisDeploy")
			aegisHum:Play()
			task.delay(config.Duration, function()
				if model:GetAttribute("GuardianState") ~= "DirectionalAegis" then aegisHum:Stop() end
			end)
		end
	end)

	gameplay:WaitForChild("DamageTaken").Event:Connect(function(healthDamage, blocked)
		if blocked and blocked > 0 then play("AegisImpact") end
		if healthDamage and healthDamage > 0 then play("Damage", 0.94 + math.random() * 0.12) end
	end)
	gameplay:WaitForChild("StateChanged").Event:Connect(function(state)
		if state ~= "DirectionalAegis" then aegisHum:Stop() end
		if state == "Staggered" then play("Stagger")
		elseif state == "Defeated" then
			idle:Stop()
			aegisHum:Stop()
			play("Defeat")
		elseif state == "Idle" and not idle.IsPlaying then idle:Play() end
	end)

	model:SetAttribute("AegisSoundPassVersion", "1.0")
	model:SetAttribute("AegisSoundSpatialized", true)
	model:SetAttribute("AegisSoundAssetSource", "RobloxCreatorStore")
	return request
end

return SoundController
