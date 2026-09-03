local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

local Preview = {}

local function folder()
	local effects = workspace:FindFirstChild("BastionRuntimeEffects") or Instance.new("Folder")
	effects.Name = "BastionRuntimeEffects"
	effects.Parent = workspace
	return effects
end

local function effectPart(name, cframe, size, shape, material, color, lifetime)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CFrame = cframe
	part.Size = size
	part.Shape = shape
	part.Material = material
	part.Color = color
	part.Parent = folder()
	Debris:AddItem(part, lifetime)
	return part
end

function Preview.FistImpact(model, side)
	local fist = model:FindFirstChild(side .. "SiegeFist", true) or model:FindFirstChild(side .. "Hand", true)
	if not fist or not fist:IsA("BasePart") then return end
	local flash = effectPart("SiegeFistImpact", fist.CFrame, Vector3.new(4, 4, 4), Enum.PartType.Ball,
		Enum.Material.Neon, Color3.fromRGB(255, 166, 58), 0.35)
	flash.Transparency = 0.12
	TweenService:Create(flash, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(11, 11, 11), Transparency = 1,
	}):Play()
end

function Preview.GroundSlam(model)
	local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
	if not root then return end
	local origin = root.Position + root.CFrame.LookVector * 7 - Vector3.new(0, root.Size.Y * 0.5, 0)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {model, folder()}
	local ground = workspace:Raycast(origin + Vector3.new(0, 8, 0), Vector3.new(0, -40, 0), raycastParams)
	if ground then origin = ground.Position end
	local debrisColor = Color3.fromRGB(91, 83, 72)
	if ground and ground.Instance:IsA("BasePart") then debrisColor = ground.Instance.Color end

	local ring = effectPart("GroundSlamShockwave", CFrame.new(origin) * CFrame.Angles(0, 0, math.rad(90)),
		Vector3.new(1, 7, 7), Enum.PartType.Cylinder, Enum.Material.Neon, Color3.fromRGB(255, 151, 45), 0.65)
	ring.Transparency = 0.2
	TweenService:Create(ring, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.18, 54, 54), Transparency = 1,
	}):Play()

	for index = 1, 12 do
		local angle = (index / 12) * math.pi * 2
		local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local chunk = effectPart("GroundSlamDebris", CFrame.new(origin + direction * (4 + index % 3)),
			Vector3.new(1.5, 1.5, 1.5), Enum.PartType.Block, Enum.Material.Rock,
			debrisColor, 1.25)
		local destination = chunk.Position + direction * (8 + index % 4) + Vector3.new(0, 3 + index % 3, 0)
		TweenService:Create(chunk, TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = destination, Orientation = Vector3.new(index * 31, index * 47, index * 19),
		}):Play()
		TweenService:Create(chunk, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 0.48), {
			Position = destination - Vector3.new(0, 5, 0), Transparency = 1,
		}):Play()
	end
end

return Preview
