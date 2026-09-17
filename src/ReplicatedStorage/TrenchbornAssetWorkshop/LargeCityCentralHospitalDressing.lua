local Dressing = {}

local COLORS = {
	Teal = Color3.fromRGB(54, 154, 157),
	DarkGlass = Color3.fromRGB(43, 78, 89),
	MedicalRed = Color3.fromRGB(195, 52, 55),
	White = Color3.fromRGB(242, 244, 241),
	Metal = Color3.fromRGB(145, 154, 157),
	Concrete = Color3.fromRGB(211, 212, 202),
	Wood = Color3.fromRGB(124, 92, 62),
	Leaf = Color3.fromRGB(58, 124, 73),
	Soil = Color3.fromRGB(76, 61, 45),
}

local function folder(parent, name)
	local existing = parent:FindFirstChild(name)
	if existing then existing:Destroy() end
	local item = Instance.new("Folder")
	item.Name = name
	item.Parent = parent
	return item
end

local function part(parent, name, size, cf, color, material, transparency, shape)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cf
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.Transparency = transparency or 0
	item.Shape = shape or Enum.PartType.Block
	item.Anchored = true
	item.CanCollide = false
	item.CanTouch = false
	item.CanQuery = false
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function block(parent, name, size, position, color, material, rotation, transparency)
	local cf = CFrame.new(position)
	if rotation then
		cf *= CFrame.Angles(math.rad(rotation.X), math.rad(rotation.Y), math.rad(rotation.Z))
	end
	return part(parent, name, size, cf, color, material, transparency)
end

local function cylinder(parent, name, size, position, color, material, rotation, transparency)
	local r = rotation or Vector3.zero
	return part(
		parent,
		name,
		size,
		CFrame.new(position) * CFrame.Angles(math.rad(r.X), math.rad(r.Y), math.rad(r.Z)),
		color,
		material,
		transparency,
		Enum.PartType.Cylinder
	)
end

local function addSurfaceText(parent, adornee, text, face, color)
	local gui = Instance.new("SurfaceGui")
	gui.Name = adornee.Name .. "Surface"
	gui.Adornee = adornee
	gui.Face = face or Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0.25
	gui.PixelsPerStud = 36
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or COLORS.White
	label.TextStrokeTransparency = 0.78
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
end

local function addPalm(parent, name, position, height, yaw)
	local palm = folder(parent, name)
	local h = height or 10
	cylinder(palm, "Trunk", Vector3.new(h, 0.85, 0.85), position + Vector3.new(0, h * 0.5, 0), COLORS.Wood, Enum.Material.Wood, Vector3.new(0, 0, 90))
	local crown = position + Vector3.new(0, h, 0)
	for index = 1, 7 do
		local angle = math.rad((index - 1) * (360 / 7) + (yaw or 0))
		local dx = math.cos(angle)
		local dz = math.sin(angle)
		block(
			palm,
			"Leaf" .. index,
			Vector3.new(0.7, 0.25, 5.0),
			crown + Vector3.new(dx * 1.7, 0.2, dz * 1.7),
			COLORS.Leaf,
			Enum.Material.Grass,
			Vector3.new(-15, math.deg(angle), 0)
		)
	end
end

local function addPlanter(parent, name, position, size)
	local planter = folder(parent, name)
	block(planter, "Box", size, position, COLORS.Concrete, Enum.Material.Concrete)
	block(planter, "Soil", size - Vector3.new(0.5, 0.65, 0.5), position + Vector3.new(0, 0.55, 0), COLORS.Soil, Enum.Material.Ground)
	for x = -1, 1 do
		local shrub = part(
			planter,
			"Shrub" .. x,
			Vector3.new(1.5, 1.5, 1.5),
			CFrame.new(position + Vector3.new(x * 1.8, 1.45, 0)),
			COLORS.Leaf,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
		shrub.CastShadow = true
	end
end

local function addBench(parent, name, position, yaw)
	local bench = folder(parent, name)
	local r = Vector3.new(0, yaw or 0, 0)
	block(bench, "Seat", Vector3.new(4.5, 0.35, 1.4), position + Vector3.new(0, 1.2, 0), COLORS.Wood, Enum.Material.Wood, r)
	block(bench, "Back", Vector3.new(4.5, 1.4, 0.3), position + Vector3.new(0, 1.95, 0.55), COLORS.Wood, Enum.Material.Wood, r)
	for _, x in ipairs({-1.7, 1.7}) do
		block(bench, "Leg" .. x, Vector3.new(0.28, 1.2, 0.7), position + Vector3.new(x, 0.6, 0), COLORS.Metal, Enum.Material.Metal, r)
	end
end

local function addBollards(parent, prefix, xs, z)
	for index, x in ipairs(xs) do
		cylinder(parent, prefix .. index, Vector3.new(2.4, 0.38, 0.38), Vector3.new(x, 1.2, z), COLORS.Metal, Enum.Material.Metal, Vector3.new(0, 0, 90))
	end
end

local function addMainEntranceDressing(root)
	local area = folder(root, "MainEntranceDressing")

	local sign = block(area, "CentralHospitalSign", Vector3.new(25, 3.2, 0.45), Vector3.new(5, 11.6, -13.55), COLORS.DarkGlass, Enum.Material.Glass)
	addSurfaceText(area, sign, "CENTRAL HOSPITAL", Enum.NormalId.Front, COLORS.White)

	for _, x in ipairs({-4.5, 2.0, 8.5, 15.0}) do
		block(area, "LobbyDoor" .. tostring(x), Vector3.new(5.0, 5.6, 0.22), Vector3.new(x, 4.9, -13.47), COLORS.DarkGlass, Enum.Material.Glass, nil, 0.12)
	end

	addPlanter(area, "MainPlanterLeft", Vector3.new(-18, 0.85, -25.5), Vector3.new(8, 1.3, 3.0))
	addPlanter(area, "MainPlanterRight", Vector3.new(28, 0.85, -25.5), Vector3.new(8, 1.3, 3.0))
	addPalm(area, "MainPalmLeft", Vector3.new(-24, 0, -30), 10, 15)
	addPalm(area, "MainPalmRight", Vector3.new(34, 0, -30), 10, -15)
	addBench(area, "BenchLeft", Vector3.new(-11, 0, -28.5), 180)
	addBench(area, "BenchRight", Vector3.new(21, 0, -28.5), 180)
	addBollards(area, "MainBollard", {-8, -2, 4, 10, 16}, -31)
end

local function addEmergencyDressing(root)
	local area = folder(root, "EmergencyDressing")
	local sign = block(area, "EmergencyWordmark", Vector3.new(23, 2.3, 0.42), Vector3.new(-43, 12.3, -18.98), COLORS.MedicalRed, Enum.Material.SmoothPlastic)
	addSurfaceText(area, sign, "EMERGENCY", Enum.NormalId.Front, COLORS.White)

	for _, x in ipairs({-51, -43, -35}) do
		block(area, "AmbulanceBayStripe" .. tostring(x), Vector3.new(4.8, 0.12, 10), Vector3.new(x, 0.6, -31), COLORS.White, Enum.Material.SmoothPlastic)
	end
	block(area, "AmbulanceLane", Vector3.new(30, 0.13, 1.2), Vector3.new(-43, 0.62, -38), COLORS.MedicalRed, Enum.Material.SmoothPlastic)
	addBollards(area, "EmergencyBollard", {-57, -52, -34, -29}, -36)
end

local function addSecondaryWingDressing(root)
	local area = folder(root, "SecondaryWingDressing")
	local sign = block(area, "DiagnosticsSign", Vector3.new(22, 2.6, 0.4), Vector3.new(47, 18.0, -6.95), COLORS.Teal, Enum.Material.SmoothPlastic)
	addSurfaceText(area, sign, "DIAGNOSTICS\nOUTPATIENT", Enum.NormalId.Front, COLORS.White)

	addPlanter(area, "SecondaryPlanter", Vector3.new(57, 0.85, -12.5), Vector3.new(10, 1.3, 3.0))
	addPalm(area, "SecondaryPalmA", Vector3.new(65, 0, -18), 9, 0)
	addPalm(area, "SecondaryPalmB", Vector3.new(52, 0, -20), 8.5, 25)
end

local function addHelipadDressing(root)
	local area = folder(root, "HelipadDressing")

	-- Thin surface markings with explicit Y separation avoid Z-fighting with the pad.
	local field = cylinder(area, "HelipadRedField", Vector3.new(0.16, 19.0, 19.0), Vector3.new(-3, 76.26, 8.5), COLORS.MedicalRed, Enum.Material.SmoothPlastic, Vector3.new(0, 0, 90))
	field.CastShadow = false

	local ring = cylinder(area, "HelipadWhiteRing", Vector3.new(0.18, 15.0, 15.0), Vector3.new(-3, 76.36, 8.5), COLORS.White, Enum.Material.SmoothPlastic, Vector3.new(0, 0, 90))
	ring.CastShadow = false
	local inner = cylinder(area, "HelipadRingCutout", Vector3.new(0.20, 12.7, 12.7), Vector3.new(-3, 76.41, 8.5), COLORS.MedicalRed, Enum.Material.SmoothPlastic, Vector3.new(0, 0, 90))
	inner.CastShadow = false

	block(area, "HelipadHVertical", Vector3.new(1.8, 0.16, 8.0), Vector3.new(-3, 76.48, 8.5), COLORS.White, Enum.Material.SmoothPlastic)
	block(area, "HelipadHLeft", Vector3.new(1.7, 0.16, 6.6), Vector3.new(-6.0, 76.48, 8.5), COLORS.White, Enum.Material.SmoothPlastic)
	block(area, "HelipadHRight", Vector3.new(1.7, 0.16, 6.6), Vector3.new(0.0, 76.48, 8.5), COLORS.White, Enum.Material.SmoothPlastic)
end

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityCentralHospitalDressing.Apply expects a Model")

	local existing = model:FindFirstChild("Dressing")
	if existing then existing:Destroy() end
	local root = folder(model, "Dressing")

	local oldReferences = model:FindFirstChild("LandscapeReferences")
	if oldReferences then oldReferences:Destroy() end

	addMainEntranceDressing(root)
	addEmergencyDressing(root)
	addSecondaryWingDressing(root)
	addHelipadDressing(root)

	model:SetAttribute("AssetPhase", 5)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("DressingRevision", "CentralHospital-Dressing-v1")
	model:SetAttribute("DressingStatus", "Review")
	return model
end

return Dressing
