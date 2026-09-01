local Debris = game:GetService("Debris")

local SoundController = {}

local ASSETS = {
	IdleHum = 9112823813,
	Servo = 9118358110,
	Footstep = 9118240078,
	MetalImpact = 9116684884,
	SystemFailure = 9118996235,
	ElectricArc = 9116279561,
	Pulse = 9116231442,
	Charge = 146785518,
}

local DEFINITIONS = {
	IdleHum = {asset = "IdleHum", volume = 0.075, speed = 0.84, looped = true, min = 8, max = 58, emitter = "UpperTorso"},
	Servo = {asset = "Servo", volume = 0.23, speed = 1.02, min = 7, max = 48, emitter = "UpperTorso"},
	FootstepWalk = {asset = "Footstep", volume = 0.4, speed = 0.94, min = 10, max = 88, emitter = "LeftFoot"},
	FootstepRun = {asset = "Footstep", volume = 0.52, speed = 1.03, min = 12, max = 108, emitter = "LeftFoot"},
	Land = {asset = "Footstep", volume = 0.6, speed = 0.82, min = 14, max = 120, emitter = "LeftFoot"},
	Damage = {asset = "MetalImpact", volume = 0.4, speed = 1.0, min = 8, max = 82, emitter = "UpperTorso"},
	Stagger = {asset = "Servo", volume = 0.5, speed = 0.72, min = 10, max = 95, emitter = "UpperTorso"},
	Defeat = {asset = "SystemFailure", volume = 0.5, speed = 0.82, min = 12, max = 105, emitter = "UpperTorso"},
	BatonWindup = {asset = "Servo", volume = 0.34, speed = 1.16, min = 8, max = 70, emitter = "StrikeHead"},
	BatonShock = {asset = "ElectricArc", volume = 0.58, speed = 1.05, min = 12, max = 115, emitter = "StrikeHead"},
	BatonImpact = {asset = "MetalImpact", volume = 0.45, speed = 1.08, min = 10, max = 100, emitter = "StrikeHead"},
	PulseCharge = {asset = "Charge", volume = 0.32, speed = 0.72, min = 8, max = 72, emitter = "ShieldAngleLeft"},
	WarningPulse = {asset = "Pulse", volume = 0.54, speed = 0.7, min = 16, max = 140, emitter = "ShieldAngleLeft"},
	ElectricArc = {asset = "ElectricArc", volume = 0.2, speed = 1.08, min = 7, max = 52, emitter = "UpperTorso"},
}

local function emitter(model, name)
	local part = model:FindFirstChild(name, true)
	if part and part:IsA("BasePart") then return part end
	return model:FindFirstChild("UpperTorso") or model.PrimaryPart
end

local function createSound(parent, name, definition)
	local item = Instance.new("Sound")
	item.Name = "WardenSFX_" .. name
	item.SoundId = "rbxassetid://" .. ASSETS[definition.asset]
	item.Volume = definition.volume
	item.PlaybackSpeed = definition.speed
	item.Looped = definition.looped == true
	item.RollOffMode = Enum.RollOffMode.InverseTapered
	item.RollOffMinDistance = definition.min
	item.RollOffMaxDistance = definition.max
	item.EmitterSize = math.max(3, definition.min * 0.5)
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
		templates[name] = createSound(emitter(model, definition.emitter), name, definition)
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

	local idleHum = templates.IdleHum
	idleHum:Play()
	local gameplay = model:FindFirstChild("Gameplay")
	if gameplay then
		local healthChanged = gameplay:FindFirstChild("HealthChanged")
		local staggered = gameplay:FindFirstChild("Staggered")
		local defeated = gameplay:FindFirstChild("Defeated")
		local baton = gameplay:FindFirstChild("BatonStrikeRequested")
		local pulse = gameplay:FindFirstChild("WarningPulseRequested")

		if healthChanged then
			healthChanged.Event:Connect(function(currentHealth, _, source)
				if source == "Reset" then
					if not idleHum.IsPlaying then idleHum:Play() end
				elseif currentHealth > 0 then
					play("Damage", 0.95 + math.random() * 0.1)
				end
			end)
		end
		if staggered then staggered.Event:Connect(function() play("Stagger") end) end
		if defeated then
			defeated.Event:Connect(function()
				idleHum:Stop()
				play("Defeat")
				task.delay(1.4, function()
					if model:GetAttribute("GuardianState") == "Defeated" then play("ElectricArc", 0.92, 0.7) end
				end)
			end)
		end
		-- The workshop harness requests ability sounds directly so cooldowns cannot mute previews.
		-- Production installations remain driven by gameplay events.
		if not model:GetAttribute("AnimationPrototype") then
			if baton then
				baton.Event:Connect(function()
					play("BatonWindup")
					task.delay(0.56, function()
						play("BatonShock")
						play("BatonImpact")
					end)
				end)
			end
			if pulse then
				pulse.Event:Connect(function(_, config)
					play("PulseCharge")
					task.delay(config.TelegraphDuration or 1.1, function()
						if model:GetAttribute("GuardianState") ~= "Defeated" then play("WarningPulse") end
					end)
				end)
			end
		end
	end

	model:SetAttribute("WardenSoundPassVersion", "1.0")
	model:SetAttribute("WardenSoundAssetSource", "RobloxCreatorStore")
	model:SetAttribute("WardenSoundSpatialized", true)
	return request
end

return SoundController
