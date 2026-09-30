local specification = require(script.Parent:WaitForChild("LargeCityWaterfrontResortSpecification"))

local Dressing = {}
local COLORS = specification.Palette

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

local function addSurfaceSign(parent, adornee, text)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignSurface"
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0.3
	gui.PixelsPerStud = 40
	gui.Adornee = adornee
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(244, 239, 224)
	label.TextStrokeTransparency = 0.8
	label.Font = Enum.Font.GothamMedium
	label.TextScaled = true
	label.Parent = gui
end

local function addPalm(parent, name, position, height, yaw)
	local palm = folder(parent, name)
	local trunkColor = Color3.fromRGB(118, 88, 58)
	local leafColor = Color3.fromRGB(56, 118, 69)
	local h = height or 10

	cylinder(
		palm,
		"Trunk",
		Vector3.new(h, 0.9, 0.9),
		position + Vector3.new(0, h * 0.5, 0),
		trunkColor,
		Enum.Material.Wood,
		Vector3.new(0, 0, 90)
	)

	local crown = position + Vector3.new(0, h, 0)
	for index = 1, 7 do
		local angle = math.rad((index - 1) * (360 / 7) + (yaw or 0))
		local dx = math.cos(angle)
		local dz = math.sin(angle)
		local leaf = block(
			palm,
			"Leaf" .. index,
			Vector3.new(0.8, 0.28, 5.8),
			crown + Vector3.new(dx * 1.9, 0.15 + (index % 2) * 0.18, dz * 1.9),
			leafColor,
			Enum.Material.Grass,
			Vector3.new(-12 - (index % 3) * 4, math.deg(angle), 0)
		)
		leaf.CanCollide = false
	end

	return palm
end

local function addPlanter(parent, name, position, size)
	local planter = folder(parent, name)
	block(planter, "Box", size or Vector3.new(6, 1.2, 2.5), position, COLORS.Limestone, Enum.Material.Concrete)
	local soilSize = (size or Vector3.new(6, 1.2, 2.5)) - Vector3.new(0.5, 0.6, 0.5)
	block(planter, "Soil", soilSize, position + Vector3.new(0, 0.65, 0), Color3.fromRGB(74, 61, 44), Enum.Material.Ground)
	for offset = -2, 2, 2 do
		local shrub = part(
			planter,
			"Shrub_" .. tostring(offset),
			Vector3.new(1.6, 1.6, 1.6),
			CFrame.new(position + Vector3.new(offset, 1.65, 0)),
			Color3.fromRGB(61, 126, 73),
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
		shrub.CastShadow = true
	end
end

local function addLounger(parent, name, position, yaw)
	local lounge = folder(parent, name)
	local r = Vector3.new(0, yaw or 0, 0)
	block(lounge, "Base", Vector3.new(2.4, 0.35, 5.2), position + Vector3.new(0, 0.45, 0), COLORS.Concrete, Enum.Material.SmoothPlastic, r)
	block(lounge, "Cushion", Vector3.new(2.1, 0.28, 3.5), position + Vector3.new(0, 0.72, 0.55), Color3.fromRGB(232, 239, 237), Enum.Material.Fabric, r)
	block(lounge, "Back", Vector3.new(2.1, 0.28, 2.4), position + Vector3.new(0, 1.4, -1.55), Color3.fromRGB(232, 239, 237), Enum.Material.Fabric, Vector3.new(28, yaw or 0, 0))
end

local function addUmbrella(parent, name, position)
	local umbrella = folder(parent, name)
	cylinder(umbrella, "Pole", Vector3.new(4.7, 0.22, 0.22), position + Vector3.new(0, 2.35, 0), COLORS.Metal, Enum.Material.Metal, Vector3.new(0, 0, 90))
	cylinder(umbrella, "Canopy", Vector3.new(0.35, 5.8, 5.8), position + Vector3.new(0, 4.75, 0), Color3.fromRGB(239, 232, 211), Enum.Material.Fabric, Vector3.new(0, 0, 90))
end

local function addCabana(parent, name, position, yaw)
	local cabana = folder(parent, name)
	local y = yaw or 0
	for _, dx in ipairs({-3.2, 3.2}) do
		for _, dz in ipairs({-2.0, 2.0}) do
			local p = CFrame.new(position) * CFrame.Angles(0, math.rad(y), 0) * CFrame.new(dx, 2.6, dz)
			part(cabana, "Post_" .. dx .. "_" .. dz, Vector3.new(0.35, 5.2, 0.35), p, COLORS.Wood, Enum.Material.Wood)
		end
	end
	block(cabana, "Roof", Vector3.new(7.4, 0.45, 5.0), position + Vector3.new(0, 5.3, 0), Color3.fromRGB(225, 216, 195), Enum.Material.Fabric, Vector3.new(0, y, 0))
	block(cabana, "Daybed", Vector3.new(5.6, 0.55, 3.6), position + Vector3.new(0, 0.7, 0), Color3.fromRGB(224, 235, 232), Enum.Material.Fabric, Vector3.new(0, y, 0))
end

local function addBench(parent, name, position, yaw)
	local bench = folder(parent, name)
	local r = Vector3.new(0, yaw or 0, 0)
	block(bench, "Seat", Vector3.new(4.6, 0.35, 1.5), position + Vector3.new(0, 1.25, 0), COLORS.Wood, Enum.Material.Wood, r)
	block(bench, "Back", Vector3.new(4.6, 1.5, 0.3), position + Vector3.new(0, 2.0, 0.6), COLORS.Wood, Enum.Material.Wood, r)
	for _, x in ipairs({-1.8, 1.8}) do
		block(bench, "Leg" .. x, Vector3.new(0.3, 1.3, 0.8), position + Vector3.new(x, 0.65, 0), COLORS.Metal, Enum.Material.Metal, r)
	end
end

local function addFacadeDressing(root)
	local facade = folder(root, "Facade")

	-- Pool-facing central tower glazing. These are thin external layers with a
	-- deliberate stand-off from the approved Golden Master geometry.
	local rearGlass = {
		{"RearLowerGlass", Vector3.new(20, 18, 0.35), Vector3.new(0, 25, 19.25)},
		{"RearUpperGlass", Vector3.new(17, 21, 0.35), Vector3.new(0, 49, 19.35)},
	}
	for _, def in ipairs(rearGlass) do
		block(facade, def[1], def[2], def[3], COLORS.DarkGlass, Enum.Material.Glass, nil, 0.18)
	end

	for _, x in ipairs({-8, -4, 0, 4, 8}) do
		block(facade, "RearLowerMullion_" .. x, Vector3.new(0.28, 18, 0.5), Vector3.new(x, 25, 19.48), COLORS.Metal, Enum.Material.Metal)
	end
	for _, x in ipairs({-7.2, -3.6, 0, 3.6, 7.2}) do
		block(facade, "RearUpperMullion_" .. x, Vector3.new(0.28, 21, 0.5), Vector3.new(x, 49, 19.28), COLORS.Metal, Enum.Material.Metal)
	end

	-- Rear window bands on both guest wings. Rotation follows each wing.
	for _, side in ipairs({-1, 1}) do
		local x = side * 29
		local yaw = side * -12
		for floorIndex = 1, 5 do
			local y = 10 + (floorIndex - 1) * 4
			local cf = CFrame.new(x, y, 8) * CFrame.Angles(0, math.rad(yaw), 0) * CFrame.new(0, 0, 12.35)
			part(facade, (side < 0 and "Left" or "Right") .. "RearWindowBand" .. floorIndex, Vector3.new(27, 2.0, 0.35), cf, COLORS.DarkGlass, Enum.Material.Glass, 0.18)
		end
		for floorIndex = 6, 7 do
			local y = 10 + (floorIndex - 1) * 4
			local upperX = x - side * 1.5
			local cf = CFrame.new(upperX, y, 9) * CFrame.Angles(0, math.rad(yaw), 0) * CFrame.new(0, 0, 10.85)
			part(facade, (side < 0 and "Left" or "Right") .. "RearUpperWindowBand" .. floorIndex, Vector3.new(23, 2.0, 0.35), cf, COLORS.DarkGlass, Enum.Material.Glass, 0.18)
		end
	end

	-- Warm interior illusion behind the pool-facing lobby glazing.
	block(facade, "PoolLobbyWarmPanel", Vector3.new(34, 4.8, 0.22), Vector3.new(0, 7.6, 28.35), Color3.fromRGB(239, 185, 108), Enum.Material.Neon, nil, 0.45)
end

local function addEntranceDressing(root)
	local entrance = folder(root, "Entrance")
	addPlanter(entrance, "LeftArrivalPlanter", Vector3.new(-18, 0.9, -30), Vector3.new(8, 1.2, 3))
	addPlanter(entrance, "RightArrivalPlanter", Vector3.new(18, 0.9, -30), Vector3.new(8, 1.2, 3))
	addPalm(entrance, "ArrivalPalmLeft", Vector3.new(-21, 0, -17), 10, 15)
	addPalm(entrance, "ArrivalPalmRight", Vector3.new(21, 0, -17), 10, -15)

	local sign = block(entrance, "ResortNameSign", Vector3.new(18, 2.2, 0.45), Vector3.new(0, 10.3, -25.6), COLORS.DarkGlass, Enum.Material.Glass)
	addSurfaceSign(entrance, sign, "TRENCHBORN BAY RESORT")

	for _, x in ipairs({-5.2, 0, 5.2}) do
		block(entrance, "LobbyDoor_" .. x, Vector3.new(4.2, 5.8, 0.3), Vector3.new(x, 6.0, -13.45), COLORS.DarkGlass, Enum.Material.Glass, nil, 0.12)
	end
end

local function addPoolDressing(root)
	local pool = folder(root, "PoolDeck")

	for index, x in ipairs({-19, -13, -7, 7, 13, 19}) do
		addLounger(pool, "Lounger" .. index, Vector3.new(x, 1.6, 50.2), 180)
	end
	for index, x in ipairs({-16, -10, 10, 16}) do
		addUmbrella(pool, "Umbrella" .. index, Vector3.new(x, 1.45, 54.0))
	end

	addCabana(pool, "CabanaLeft", Vector3.new(-36, 1.4, 49), 0)
	addCabana(pool, "CabanaRight", Vector3.new(36, 1.4, 49), 0)

	-- Pool bar details layered onto the Phase 4 pavilion.
	block(pool, "PoolBarCounter", Vector3.new(8, 1.0, 1.4), Vector3.new(-32, 3.2, 29.3), COLORS.Wood, Enum.Material.Wood)
	for index, x in ipairs({-35, -32, -29}) do
		cylinder(pool, "PoolBarStoolStem" .. index, Vector3.new(1.5, 0.2, 0.2), Vector3.new(x, 2.35, 27.8), COLORS.Metal, Enum.Material.Metal, Vector3.new(0, 0, 90))
		cylinder(pool, "PoolBarStoolSeat" .. index, Vector3.new(0.25, 1.2, 1.2), Vector3.new(x, 3.15, 27.8), COLORS.Wood, Enum.Material.Wood, Vector3.new(0, 0, 90))
	end

	addPlanter(pool, "PoolPlanterLeft", Vector3.new(-40, 1.65, 40), Vector3.new(4.5, 1.2, 12))
	addPlanter(pool, "PoolPlanterRight", Vector3.new(40, 1.65, 40), Vector3.new(4.5, 1.2, 12))
	addPalm(pool, "PoolPalmLeft", Vector3.new(-40, 2.3, 41), 9, 20)
	addPalm(pool, "PoolPalmRight", Vector3.new(40, 2.3, 41), 9, -20)
end

local function addPromenadeDressing(root)
	local promenade = folder(root, "Promenade")
	for index, x in ipairs({-30, -15, 0, 15, 30}) do
		addBench(promenade, "Bench" .. index, Vector3.new(x, 0.8, 58), 0)
	end
	for index, x in ipairs({-39, -26, -13, 13, 26, 39}) do
		local post = block(promenade, "Bollard" .. index, Vector3.new(0.35, 2.2, 0.35), Vector3.new(x, 1.5, 60.5), COLORS.Metal, Enum.Material.Metal)
		local cap = block(promenade, "BollardGlow" .. index, Vector3.new(0.5, 0.3, 0.5), Vector3.new(x, 2.65, 60.5), Color3.fromRGB(239, 214, 159), Enum.Material.Neon)
		post.CanCollide = false
		cap.CanCollide = false
	end
end

local function addRoofDressing(root)
	local roof = folder(root, "Roof")
	for index, x in ipairs({-9, -3, 3, 9}) do
		block(roof, "HVAC" .. index, Vector3.new(4.2, 1.8, 3.2), Vector3.new(x, 67.2, 11.5), Color3.fromRGB(158, 164, 166), Enum.Material.Metal)
		block(roof, "HVACVent" .. index, Vector3.new(2.8, 0.35, 0.18), Vector3.new(x, 67.6, 9.85), COLORS.DarkGlass, Enum.Material.Metal)
	end
	cylinder(roof, "ServiceAntenna", Vector3.new(5.0, 0.18, 0.18), Vector3.new(12.5, 70.2, 10), COLORS.Metal, Enum.Material.Metal, Vector3.new(0, 0, 90))
end

local function countDressingParts(root)
	local count = 0
	for _, item in ipairs(root:GetDescendants()) do
		if item:IsA("BasePart") then
			count += 1
		elseif item:IsA("TextLabel") then
			item.TextScaled = true
		end
	end
	return count
end

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityWaterfrontResortDressing.Apply expects a Model")

	local existing = model:FindFirstChild("Dressing")
	if existing then existing:Destroy() end

	local root = folder(model, "Dressing")
	addFacadeDressing(root)
	addEntranceDressing(root)
	addPoolDressing(root)
	addPromenadeDressing(root)
	addRoofDressing(root)

	local count = countDressingParts(root)
	model:SetAttribute("PipelinePhase", 5)
	model:SetAttribute("DressingApplied", true)
	model:SetAttribute("DressingRevision", "WaterfrontResort-v1")
	model:SetAttribute("DressingPartCount", count)
	model:SetAttribute("DressingPermanentLights", 0)
	model:SetAttribute("DressingPermanentEmitters", 0)
	model:SetAttribute("TextLabelsScaled", true)
	return model
end

return Dressing
