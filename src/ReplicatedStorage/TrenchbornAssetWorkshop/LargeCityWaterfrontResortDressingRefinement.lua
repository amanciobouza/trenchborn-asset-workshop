local Refinement = {}

local function folder(parent, name)
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
	local cf = CFrame.new(position)
	local r = rotation or Vector3.zero
	cf *= CFrame.Angles(math.rad(r.X), math.rad(r.Y), math.rad(r.Z))
	return part(parent, name, size, cf, color, material, transparency, Enum.PartType.Cylinder)
end

local function addCompactPalm(parent, name, position, height, yaw)
	local palm = folder(parent, name)
	local h = height or 8
	cylinder(palm, "Trunk", Vector3.new(h, 0.7, 0.7), position + Vector3.new(0, h * 0.5, 0), Color3.fromRGB(113, 82, 55), Enum.Material.Wood, Vector3.new(0, 0, 90))
	local crown = position + Vector3.new(0, h, 0)
	for index = 1, 6 do
		local angle = math.rad((index - 1) * 60 + (yaw or 0))
		block(
			palm,
			"Leaf" .. index,
			Vector3.new(0.55, 0.22, 4.4),
			crown + Vector3.new(math.cos(angle) * 1.45, 0.05, math.sin(angle) * 1.45),
			Color3.fromRGB(49, 112, 67),
			Enum.Material.Grass,
			Vector3.new(-15, math.deg(angle), 0)
		)
	end
end

local function addPoolsideLounge(parent)
	local lounge = folder(parent, "PergolaLounge")
	block(lounge, "SofaLeft", Vector3.new(5.4, 1.0, 2.2), Vector3.new(29.4, 2.0, 33.0), Color3.fromRGB(232, 235, 228), Enum.Material.Fabric)
	block(lounge, "SofaRight", Vector3.new(5.4, 1.0, 2.2), Vector3.new(34.6, 2.0, 33.0), Color3.fromRGB(232, 235, 228), Enum.Material.Fabric)
	block(lounge, "BackLeft", Vector3.new(5.4, 1.4, 0.45), Vector3.new(29.4, 2.8, 34.0), Color3.fromRGB(217, 223, 217), Enum.Material.Fabric)
	block(lounge, "BackRight", Vector3.new(5.4, 1.4, 0.45), Vector3.new(34.6, 2.8, 34.0), Color3.fromRGB(217, 223, 217), Enum.Material.Fabric)
	block(lounge, "CoffeeTable", Vector3.new(3.4, 0.35, 2.1), Vector3.new(32.0, 1.7, 30.3), Color3.fromRGB(128, 92, 63), Enum.Material.Wood)
end

local function addPoolDeckDetails(parent)
	local details = folder(parent, "PoolDeckDetails")

	-- Small side tables and folded towels make the sun deck read as an active hotel pool.
	for index, x in ipairs({-16, -10, 10, 16}) do
		cylinder(details, "SideTableStem" .. index, Vector3.new(1.0, 0.18, 0.18), Vector3.new(x, 2.0, 49.3), Color3.fromRGB(175, 181, 182), Enum.Material.Metal, Vector3.new(0, 0, 90))
		cylinder(details, "SideTableTop" .. index, Vector3.new(0.2, 1.5, 1.5), Vector3.new(x, 2.55, 49.3), Color3.fromRGB(205, 198, 181), Enum.Material.SmoothPlastic, Vector3.new(0, 0, 90))
		block(details, "FoldedTowel" .. index, Vector3.new(1.5, 0.15, 0.9), Vector3.new(x, 2.78, 49.3), Color3.fromRGB(240, 243, 238), Enum.Material.Fabric)
	end

	-- Two low planters frame the main descent from the hotel without blocking sightlines.
	for _, x in ipairs({-19.5, 19.5}) do
		block(details, "TerracePlanterBox" .. tostring(x), Vector3.new(7.5, 1.1, 2.4), Vector3.new(x, 2.75, 25.0), Color3.fromRGB(214, 204, 186), Enum.Material.Concrete)
		block(details, "TerracePlanterGreen" .. tostring(x), Vector3.new(6.8, 0.55, 1.8), Vector3.new(x, 3.55, 25.0), Color3.fromRGB(62, 124, 72), Enum.Material.Grass)
	end

	-- Discreet pool-edge markers use emissive material but no permanent Light instances.
	for index, x in ipairs({-23, -11.5, 11.5, 23}) do
		block(details, "PoolMarkerPost" .. index, Vector3.new(0.34, 1.5, 0.34), Vector3.new(x, 1.9, 46.8), Color3.fromRGB(169, 176, 178), Enum.Material.Metal)
		block(details, "PoolMarkerGlow" .. index, Vector3.new(0.46, 0.22, 0.46), Vector3.new(x, 2.7, 46.8), Color3.fromRGB(237, 210, 154), Enum.Material.Neon)
	end

	addPoolsideLounge(details)
end

local function addPoolBarDetails(parent)
	local bar = folder(parent, "PoolBarRefinement")
	block(bar, "BackBarShelf", Vector3.new(7.0, 2.2, 0.35), Vector3.new(-32, 4.6, 32.0), Color3.fromRGB(118, 86, 61), Enum.Material.Wood)
	for index, x in ipairs({-34, -32, -30}) do
		block(bar, "BottleGlow" .. index, Vector3.new(0.35, 0.9, 0.35), Vector3.new(x, 4.8, 31.75), Color3.fromRGB(104, 190, 183), Enum.Material.Glass, nil, 0.12)
	end
	block(bar, "CounterAccent", Vector3.new(8.4, 0.14, 1.55), Vector3.new(-32, 3.72, 29.3), Color3.fromRGB(232, 218, 188), Enum.Material.SmoothPlastic)
end

local function addPromenadeDetails(parent)
	local promenade = folder(parent, "PromenadeRefinement")

	-- Palm-and-planter clusters create a clear resort promenade rhythm between benches.
	for index, x in ipairs({-38, -22, 22, 38}) do
		block(promenade, "Planter" .. index, Vector3.new(5.0, 1.0, 2.8), Vector3.new(x, 1.1, 56.2), Color3.fromRGB(214, 204, 186), Enum.Material.Concrete)
		block(promenade, "PlanterGreen" .. index, Vector3.new(4.3, 0.5, 2.1), Vector3.new(x, 1.85, 56.2), Color3.fromRGB(57, 119, 70), Enum.Material.Grass)
		addCompactPalm(promenade, "PromenadePalm" .. index, Vector3.new(x, 1.6, 56.2), 7.5, index * 17)
	end

	-- Wood inlay gives the waterfront edge a warmer Miami/Singapore resort character.
	for index, x in ipairs({-30, -18, -6, 6, 18, 30}) do
		block(promenade, "WoodInlay" .. index, Vector3.new(8.0, 0.12, 2.2), Vector3.new(x, 0.86, 58.6), Color3.fromRGB(133, 98, 67), Enum.Material.Wood)
	end
end

function Refinement.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityWaterfrontResortDressingRefinement.Apply expects a Model")

	local dressing = model:FindFirstChild("Dressing")
	assert(dressing, "Dressing must exist before refinement")

	local existing = dressing:FindFirstChild("Refinement")
	if existing then existing:Destroy() end
	local root = folder(dressing, "Refinement")

	addPoolDeckDetails(root)
	addPoolBarDetails(root)
	addPromenadeDetails(root)

	model:SetAttribute("DressingRevision", "WaterfrontResort-v2-PoolPromenade")
	model:SetAttribute("PoolPromenadeRefinement", true)
	return model
end

return Refinement
