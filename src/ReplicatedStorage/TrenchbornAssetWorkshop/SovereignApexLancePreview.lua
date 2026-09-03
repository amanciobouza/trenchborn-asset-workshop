local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Preview = {}

local VIOLET = Color3.fromRGB(185, 52, 255)
local HOT = Color3.fromRGB(246, 186, 255)

local function effectsFolder()
	local folder = workspace:FindFirstChild("SovereignRuntimeEffects")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "SovereignRuntimeEffects"
		folder.Parent = workspace
	end
	return folder
end

local function bladeAndTip(model)
	local blade = model:FindFirstChild("ApexEnergyBlade", true)
	if not blade or not blade:IsA("BasePart") then return nil, nil end
	return blade, (blade.CFrame * CFrame.new(0, -blade.Size.Y * 0.5, 0)).Position
end

local function targetPosition(model, target)
	if target and target:IsA("BasePart") then return target.Position end
	if target and target:IsA("Model") then
		for _, name in ipairs({"UpperTorso", "Torso", "HumanoidRootPart"}) do
			local part = target:FindFirstChild(name, true)
			if part and part:IsA("BasePart") then return part.Position end
		end
		local boxCFrame, boxSize = target:GetBoundingBox()
		return boxCFrame.Position + Vector3.new(0, boxSize.Y * 0.05, 0)
	end
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	return root and root.Position + root.CFrame.LookVector * 150 or Vector3.zero
end

local function sphere(name, position, size, color, lifetime)
	local part = Instance.new("Part")
	part.Name = name
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(size, size, size)
	part.Position = position
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Material = Enum.Material.Neon
	part.Color = color
	part.Parent = effectsFolder()
	Debris:AddItem(part, lifetime)
	return part
end

local function addBladeTrail(model, lifetime)
	local blade = bladeAndTip(model)
	if not blade then return end
	local baseAttachment = Instance.new("Attachment")
	baseAttachment.Name = "ApexTrailBase"
	baseAttachment.Position = Vector3.new(0, blade.Size.Y * 0.45, 0)
	baseAttachment.Parent = blade
	local tipAttachment = Instance.new("Attachment")
	tipAttachment.Name = "ApexTrailTip"
	tipAttachment.Position = Vector3.new(0, -blade.Size.Y * 0.5, 0)
	tipAttachment.Parent = blade
	local trail = Instance.new("Trail")
	trail.Name = "ApexLanceTrail"
	trail.Attachment0 = baseAttachment
	trail.Attachment1 = tipAttachment
	trail.Color = ColorSequence.new(HOT, VIOLET)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.08),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.Lifetime = 0.2
	trail.LightEmission = 1
	trail.FaceCamera = true
	trail.Parent = blade
	Debris:AddItem(baseAttachment, lifetime)
	Debris:AddItem(tipAttachment, lifetime)
	Debris:AddItem(trail, lifetime)
end

local function impactPulse(model, delaySeconds, size)
	task.delay(delaySeconds, function()
		if not model.Parent then return end
		local _, tip = bladeAndTip(model)
		if not tip then return end
		local pulse = sphere("ApexLanceImpact", tip, 2.5, HOT, 0.42)
		pulse.Material = Enum.Material.ForceField
		pulse.Transparency = 0.12
		TweenService:Create(pulse, TweenInfo.new(0.36, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(size, size, size), Transparency = 1,
		}):Play()
	end)
end

local function beamLayer(name, start, finish, width, color, transparency, lifetime)
	local delta = finish - start
	local beam = Instance.new("Part")
	beam.Name = name
	beam.Size = Vector3.new(width, width, delta.Magnitude)
	beam.CFrame = CFrame.lookAt((start + finish) * 0.5, finish)
	beam.Anchored = true
	beam.CanCollide = false
	beam.CanTouch = false
	beam.CanQuery = false
	beam.Material = Enum.Material.Neon
	beam.Color = color
	beam.Transparency = transparency
	beam.Parent = effectsFolder()
	Debris:AddItem(beam, lifetime)
	TweenService:Create(beam, TweenInfo.new(lifetime - 0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(width * 0.18, width * 0.18, delta.Magnitude),
		Transparency = 1,
	}):Play()
	return beam
end

function Preview.Thrust(model)
	addBladeTrail(model, 0.95)
	impactPulse(model, 0.62, 10)
end

function Preview.Cut(model)
	addBladeTrail(model, 1.05)
	impactPulse(model, 0.68, 13)
end

function Preview.Beam(model, target)
	local blade, tip = bladeAndTip(model)
	if not blade or not tip then return end
	local charge = sphere("ApexBeamCharge", tip, 1.2, VIOLET, 1.35)
	charge.Anchored = false
	charge.Massless = true
	charge.CFrame = CFrame.new(tip)
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = blade
	weld.Part1 = charge
	weld.Parent = charge
	local light = Instance.new("PointLight")
	light.Color = VIOLET
	light.Brightness = 1.5
	light.Range = 12
	light.Shadows = false
	light.Parent = charge
	TweenService:Create(charge, TweenInfo.new(1.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = Vector3.new(4.5, 4.5, 4.5), Color = HOT, Transparency = 0.02,
	}):Play()
	TweenService:Create(light, TweenInfo.new(1.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Brightness = 8, Range = 34,
	}):Play()

	task.delay(1.18, function()
		if not model.Parent or not blade.Parent then return end
		local _, start = bladeAndTip(model)
		local finish = targetPosition(model, target)
		local delta = finish - start
		if delta.Magnitude < 1 then return end
		if charge.Parent then charge:Destroy() end
		-- A broad translucent sheath gives the shot its destructive scale, while
		-- the smaller white-hot core preserves a precise hunter-weapon silhouette.
		beamLayer("ApexLanceBeamSheath", start, finish, 7.2, VIOLET, 0.42, 0.52)
		beamLayer("ApexLanceBeamCore", start, finish, 3.6, HOT, 0.01, 0.46)
		impactPulse(model, 0, 12)
		local hit = sphere("ApexBeamImpact", finish, 4, VIOLET, 0.65)
		hit.Material = Enum.Material.ForceField
		TweenService:Create(hit, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(20, 20, 20), Transparency = 1,
		}):Play()
	end)
end

return Preview
