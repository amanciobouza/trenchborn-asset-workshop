local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Preview = {}

local function effectsFolder()
	local folder = workspace:FindFirstChild("BastionRuntimeEffects")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "BastionRuntimeEffects"
		folder.Parent = workspace
	end
	return folder
end

local function destination(model, target)
	if target and target:IsA("BasePart") then return target.Position end
	if target and target:IsA("Model") then return target:GetPivot().Position end
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	return root.Position + root.CFrame.LookVector * 145
end

local function sphere(name, position, size, color, lifetime)
	local item = Instance.new("Part")
	item.Name = name
	item.Shape = Enum.PartType.Ball
	item.Size = Vector3.new(size, size, size)
	item.Position = position
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.Material = Enum.Material.Neon
	item.Color = color
	item.Parent = effectsFolder()
	Debris:AddItem(item, lifetime)
	return item
end

function Preview.Play(model, target)
	local muzzle = model:FindFirstChild("RailMuzzleCore", true)
	if not muzzle or not muzzle:IsA("BasePart") then
		warn("Bastion RailMuzzleCore not found")
		return
	end
	local hot = Color3.fromRGB(255, 220, 139)
	local orange = Color3.fromRGB(255, 151, 45)

	local charge = sphere("RailCharge", muzzle.Position, 1.2, orange, 1.8)
	charge.Anchored = false
	charge.Massless = true
	charge.CFrame = muzzle.CFrame
	local chargeWeld = Instance.new("WeldConstraint")
	chargeWeld.Name = "RailChargeMuzzleWeld"
	chargeWeld.Part0 = muzzle
	chargeWeld.Part1 = charge
	chargeWeld.Parent = charge
	charge.Transparency = 0.2
	local light = Instance.new("PointLight")
	light.Color = orange
	light.Brightness = 1
	light.Range = 14
	light.Shadows = false
	light.Parent = charge
	TweenService:Create(charge, TweenInfo.new(1.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = Vector3.new(5.2, 5.2, 5.2),
		Color = hot,
		Transparency = 0.02,
	}):Play()
	TweenService:Create(light, TweenInfo.new(1.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Brightness = 9,
		Range = 38,
	}):Play()

	task.delay(1.55, function()
		if not model.Parent or not muzzle.Parent then return end
		local start = muzzle.Position
		local finish = destination(model, target)
		local delta = finish - start
		local length = delta.Magnitude
		if length < 1 then return end
		if charge.Parent then charge:Destroy() end

		local pulse = Instance.new("Part")
		pulse.Name = "HeavyRailPulse"
		pulse.Size = Vector3.new(1.8, 1.8, length)
		pulse.CFrame = CFrame.lookAt((start + finish) * 0.5, finish)
		pulse.Anchored = true
		pulse.CanCollide = false
		pulse.CanTouch = false
		pulse.CanQuery = false
		pulse.Material = Enum.Material.Neon
		pulse.Color = hot
		pulse.Transparency = 0.03
		pulse.Parent = effectsFolder()
		Debris:AddItem(pulse, 0.32)
		TweenService:Create(pulse, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.2, 0.2, length),
			Transparency = 1,
		}):Play()

		local muzzleWave = sphere("RailMuzzlePressure", start, 4, orange, 0.5)
		muzzleWave.Material = Enum.Material.ForceField
		muzzleWave.Transparency = 0.22
		TweenService:Create(muzzleWave, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(22, 22, 22),
			Transparency = 1,
		}):Play()

		local hit = sphere("RailImpact", finish, 5, hot, 0.7)
		hit.Material = Enum.Material.ForceField
		TweenService:Create(hit, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(28, 28, 28),
			Transparency = 1,
		}):Play()
	end)
end

return Preview
