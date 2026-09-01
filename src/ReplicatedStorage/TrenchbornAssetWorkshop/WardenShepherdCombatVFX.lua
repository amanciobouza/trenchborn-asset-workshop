local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local VFX = {}

local function effectsFolder()
	local folder = workspace:FindFirstChild("WardenRuntimeEffects")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "WardenRuntimeEffects"
		folder.Parent = workspace
	end
	return folder
end

function VFX.ShockBaton(model)
	task.delay(0.56, function()
		if not model.Parent then return end
		local strikeHead = model:FindFirstChild("StrikeHead", true)
		if not strikeHead or not strikeHead:IsA("BasePart") then return end

		local source = Instance.new("Attachment")
		source.Position = Vector3.new(0, -1, 0)
		source.Parent = strikeHead
		local contact = Instance.new("Attachment")
		contact.Position = Vector3.new(0, 1, 0)
		contact.Parent = strikeHead
		Debris:AddItem(source, 0.32)
		Debris:AddItem(contact, 0.32)

		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(126, 255, 173)
		light.Brightness = 10
		light.Range = 22
		light.Parent = strikeHead
		Debris:AddItem(light, 0.22)

		for index = 1, 5 do
			local beam = Instance.new("Beam")
			beam.Name = "WardenBatonArc" .. index
			beam.Attachment0 = source
			beam.Attachment1 = contact
			beam.Color = ColorSequence.new(Color3.fromRGB(92, 255, 151), Color3.fromRGB(224, 255, 234))
			beam.Width0 = 0.16 + index * 0.025
			beam.Width1 = 0.08
			beam.CurveSize0 = math.random(-28, 28) / 10
			beam.CurveSize1 = math.random(-28, 28) / 10
			beam.Segments = 5
			beam.LightEmission = 1
			beam.FaceCamera = true
			beam.Parent = strikeHead
			Debris:AddItem(beam, 0.14 + index * 0.018)
		end

		local flash = Instance.new("Part")
		flash.Name = "WardenBatonContactFlash"
		flash.Shape = Enum.PartType.Ball
		flash.Size = Vector3.new(1.8, 1.8, 1.8)
		flash.CFrame = strikeHead.CFrame
		flash.Anchored = false
		flash.CanCollide = false
		flash.CanTouch = false
		flash.CanQuery = false
		flash.Massless = true
		flash.Material = Enum.Material.Neon
		flash.Color = Color3.fromRGB(176, 255, 205)
		flash.Parent = effectsFolder()
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = strikeHead
		weld.Part1 = flash
		weld.Parent = flash
		Debris:AddItem(flash, 0.25)
		TweenService:Create(flash, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(7, 7, 7),
			Transparency = 1,
		}):Play()
	end)
end

function VFX.WarningPulse(model, config)
	local core = model:FindFirstChild("ShieldAngleLeft", true)
		or model:FindFirstChild("VisorSensor", true)
		or model:FindFirstChild("UpperTorso")
	if not core or not core:IsA("BasePart") then return end

	local charge = Instance.new("PointLight")
	charge.Color = Color3.fromRGB(92, 255, 151)
	charge.Brightness = 0
	charge.Range = 35
	charge.Parent = core
	Debris:AddItem(charge, 1.5)
	TweenService:Create(charge, TweenInfo.new(config.TelegraphDuration or 1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Brightness = 9,
		Range = 48,
	}):Play()

	task.delay(config.TelegraphDuration or 1.1, function()
		if not model.Parent then return end
		if charge.Parent then charge:Destroy() end
		local origin = model:FindFirstChild("UpperTorso") or model.PrimaryPart
		if not origin then return end
		for index = 1, 3 do
			local wave = Instance.new("Part")
			wave.Name = "WardenWarningPulseWave" .. index
			wave.Shape = Enum.PartType.Ball
			wave.Size = Vector3.new(8, 8, 8)
			wave.CFrame = CFrame.new(origin.Position)
			wave.Anchored = true
			wave.CanCollide = false
			wave.CanTouch = false
			wave.CanQuery = false
			wave.Material = Enum.Material.ForceField
			wave.Color = Color3.fromRGB(104, 255, 159)
			wave.Transparency = 0.3 + index * 0.08
			wave.Parent = effectsFolder()
			Debris:AddItem(wave, 0.7)
			task.delay((index - 1) * 0.07, function()
				if wave.Parent then
					TweenService:Create(wave, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = Vector3.new((config.Radius or 28) * 2, (config.Radius or 28) * 2, (config.Radius or 28) * 2),
						Transparency = 1,
					}):Play()
				end
			end)
		end
	end)
end

return VFX
