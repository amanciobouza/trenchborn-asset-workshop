local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Preview = {}

local ORANGE = Color3.fromRGB(255, 151, 45)
local HOT = Color3.fromRGB(255, 222, 151)

local function effectsFolder()
	local folder = workspace:FindFirstChild("BastionRuntimeEffects") or Instance.new("Folder")
	folder.Name = "BastionRuntimeEffects"
	folder.Parent = workspace
	return folder
end

local function projectorParts(model)
	local parts = {}
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and (
			string.find(item.Name, "ShieldNode", 1, true)
			or string.find(item.Name, "HipProjector", 1, true)
			or string.find(item.Name, "Emblem", 1, true)
		) then
			table.insert(parts, item)
		end
	end
	table.sort(parts, function(a, b) return a.Name < b.Name end)
	return parts
end

local function pulseProjector(part, delaySeconds)
	task.delay(delaySeconds, function()
		if not part.Parent then return end
		local originalColor = part.Color
		local originalMaterial = part.Material
		part.Material = Enum.Material.Neon
		local light = Instance.new("PointLight")
		light.Name = "DistrictShieldChargeLight"
		light.Color = ORANGE
		light.Brightness = 0
		light.Range = 18
		light.Shadows = false
		light.Parent = part
		TweenService:Create(part, TweenInfo.new(0.18), {Color = HOT}):Play()
		TweenService:Create(light, TweenInfo.new(0.18), {Brightness = 5, Range = 30}):Play()
		task.delay(4.55 - delaySeconds, function()
			if part.Parent then
				TweenService:Create(part, TweenInfo.new(0.35), {Color = originalColor}):Play()
			end
			if light.Parent then Debris:AddItem(light, 0.35); TweenService:Create(light, TweenInfo.new(0.3), {Brightness = 0}):Play() end
			task.delay(0.36, function()
				if part.Parent then part.Material = originalMaterial end
			end)
		end)
	end)
end

function Preview.Play(model)
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	if not root then return end
	local projectors = projectorParts(model)
	for index, part in ipairs(projectors) do
		pulseProjector(part, 0.18 + (index - 1) * 0.09)
	end

	task.delay(1.55, function()
		if not model.Parent or not root.Parent then return end
		local horizontalCenter = root.Position + root.CFrame.LookVector * 65
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = {model, effectsFolder()}
		local ground = workspace:Raycast(horizontalCenter + Vector3.new(0, 80, 0), Vector3.new(0, -240, 0), raycastParams)
		local groundY = ground and ground.Position.Y or horizontalCenter.Y - 28
		local center = Vector3.new(horizontalCenter.X, groundY, horizontalCenter.Z)
		local field = Instance.new("Part")
		field.Name = "DistrictShieldField"
		field.Shape = Enum.PartType.Ball
		field.Size = Vector3.new(8, 5, 8)
		field.CFrame = CFrame.new(center)
		field.Anchored = true
		field.CanCollide = false
		field.CanTouch = false
		field.CanQuery = false
		field.CastShadow = false
		field.Material = Enum.Material.ForceField
		field.Color = ORANGE
		field.Transparency = 1
		field.Parent = effectsFolder()
		Debris:AddItem(field, 4.2)

		TweenService:Create(field, TweenInfo.new(0.55, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = Vector3.new(300, 180, 300), Transparency = 0.72,
		}):Play()
		task.delay(2.75, function()
			if field.Parent then
				TweenService:Create(field, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = Vector3.new(312, 188, 312), Transparency = 1,
				}):Play()
			end
		end)
	end)
end

return Preview
