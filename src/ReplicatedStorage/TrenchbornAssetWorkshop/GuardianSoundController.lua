local Debris = game:GetService("Debris")

local SoundController = {}

local ASSETS = {
	IdleHum = 9112823813,
	Servo = 9118358110,
	Footstep = 9118240078,
	MetalImpact = 9116684884,
	SystemFailure = 9118996235,
	ElectricArc = 9116279561,
	PulseCannon = 9116231442,
	TargetLock = 146785518,
}

local DEFINITIONS = {
	IdleHum = {asset = "IdleHum", volume = 0.11, speed = 0.72, looped = true, min = 10, max = 72},
	Servo = {asset = "Servo", volume = 0.28, speed = 0.88, min = 8, max = 58},
	FootstepWalk = {asset = "Footstep", volume = 0.48, speed = 0.82, min = 12, max = 105},
	FootstepRun = {asset = "Footstep", volume = 0.6, speed = 0.94, min = 14, max = 125},
	Land = {asset = "Footstep", volume = 0.72, speed = 0.7, min = 16, max = 145},
	Damage = {asset = "MetalImpact", volume = 0.48, speed = 0.88, min = 10, max = 100},
	ShieldImpact = {asset = "MetalImpact", volume = 0.62, speed = 0.72, min = 14, max = 135},
	Stagger = {asset = "Servo", volume = 0.55, speed = 0.64, min = 12, max = 115},
	Defeat = {asset = "SystemFailure", volume = 0.58, speed = 0.72, min = 14, max = 125},
	ElectricArc = {asset = "ElectricArc", volume = 0.25, speed = 0.9, min = 8, max = 68},
	PulseCannon = {asset = "PulseCannon", volume = 0.68, speed = 0.82, min = 18, max = 165},
	PulseImpact = {asset = "ElectricArc", volume = 0.5, speed = 0.72, min = 14, max = 150},
	TargetLock = {asset = "TargetLock", volume = 0.42, speed = 0.92, min = 8, max = 75},
	NetLaunch = {asset = "Servo", volume = 0.46, speed = 1.08, min = 12, max = 110},
	NetActive = {asset = "ElectricArc", volume = 0.18, speed = 1.15, min = 8, max = 72},
}

local function emitter(model, preference)
	local item = model:FindFirstChild(preference, true)
	if item and item:IsA("BasePart") then return item end
	return model:FindFirstChild("UpperTorso") or model.PrimaryPart
end

local function sound(parent, name, definition)
	local item = Instance.new("Sound")
	item.Name = name
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

	local rootEmitter = emitter(model, "UpperTorso")
	local footEmitter = emitter(model, "LeftFoot")
	local shieldEmitter = emitter(model, "RiotShieldControl")
	local cannonEmitter = emitter(model, "MuzzleCore")
	local netEmitter = emitter(model, "LaunchMouth")

	local templates = {}
	for name, definition in pairs(DEFINITIONS) do
		local parent = rootEmitter
		if string.find(name, "Footstep", 1, true) or name == "Land" then parent = footEmitter end
		if name == "ShieldImpact" then parent = shieldEmitter end
		if name == "PulseCannon" or name == "PulseImpact" then parent = cannonEmitter end
		if name == "NetLaunch" or name == "NetActive" or name == "TargetLock" then parent = netEmitter end
		templates[name] = sound(parent, "GuardianSFX_" .. name, definition)
	end

	local idleHum = templates.IdleHum
	idleHum:Play()
	local defeatedToken = 0

	local function play(name, speedScale, volumeScale)
		local template = templates[name]
		if not template then return end
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

	local gameplay = model:FindFirstChild("Gameplay")
	local abilityRequested = gameplay and gameplay:FindFirstChild("AbilityRequested")
	local damageTaken = gameplay and gameplay:FindFirstChild("DamageTaken")
	local stateChanged = gameplay and gameplay:FindFirstChild("StateChanged")

	if abilityRequested and abilityRequested:IsA("BindableEvent") then
		abilityRequested.Event:Connect(function(name, _, ability)
			if name == "RiotShield" then
				play("Servo", 0.78, 1.1)
			elseif name == "PulseCannon" then
				play("PulseCannon")
			elseif name == "ContainmentNet" then
				play("TargetLock")
				task.delay(ability.TelegraphDuration or 1.35, function()
					if model:GetAttribute("GuardianState") ~= "Defeated" then play("NetLaunch") end
				end)
			end
		end)
	end

	if damageTaken and damageTaken:IsA("BindableEvent") then
		damageTaken.Event:Connect(function(healthDamage, blocked)
			if blocked and blocked > 0 then play("ShieldImpact") end
			if healthDamage and healthDamage > 0 then play("Damage", 0.9 + math.random() * 0.12) end
		end)
	end

	if stateChanged and stateChanged:IsA("BindableEvent") then
		stateChanged.Event:Connect(function(newState)
			if newState == "Staggered" then
				play("Stagger")
			elseif newState == "Defeated" then
				defeatedToken += 1
				local token = defeatedToken
				idleHum:Stop()
				play("Defeat")
				task.spawn(function()
					while token == defeatedToken and model:GetAttribute("GuardianState") == "Defeated" do
						task.wait(math.random(80, 240) / 100)
						if token == defeatedToken and model:GetAttribute("GuardianState") == "Defeated" then
							play("ElectricArc", 0.88 + math.random() * 0.18, 0.75)
						end
					end
				end)
			elseif newState == "Idle" then
				defeatedToken += 1
				if not idleHum.IsPlaying then idleHum:Play() end
			end
		end)
	end

	model:SetAttribute("GuardianSoundPassVersion", "1.0")
	model:SetAttribute("GuardianSoundAssetSource", "RobloxCreatorStore")
	model:SetAttribute("GuardianSoundSpatialized", true)
	return request
end

return SoundController
