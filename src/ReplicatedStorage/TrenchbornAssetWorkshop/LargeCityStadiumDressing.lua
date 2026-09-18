local Dressing = {}

local COLORS = {
	White = Color3.fromRGB(242, 245, 245),
	Concrete = Color3.fromRGB(205, 209, 207),
	Dark = Color3.fromRGB(42, 50, 56),
	DarkGlass = Color3.fromRGB(43, 79, 92),
	Teal = Color3.fromRGB(54, 154, 157),
	Cyan = Color3.fromRGB(91, 199, 210),
	Metal = Color3.fromRGB(151, 162, 165),
	Leaf = Color3.fromRGB(55, 128, 75),
	Wood = Color3.fromRGB(122, 89, 59),
	Soil = Color3.fromRGB(76, 61, 45),
	Light = Color3.fromRGB(229, 246, 255),
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

local function addSurfaceText(parent, adornee, text, face, color, font)
	local gui = Instance.new("SurfaceGui")
	gui.Name = adornee.Name .. "Surface"
	gui.Adornee = adornee
	gui.Face = face or Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.LightInfluence = 0.2
	gui.PixelsPerStud = 42
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or COLORS.White
	label.TextStrokeTransparency = 0.8
	label.Font = font or Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Parent = gui
end

local function addPalm(parent, name, position, height, yaw)
	local palm = folder(parent, name)
	local h = height or 11
	cylinder(
		palm,
		"Trunk",
		Vector3.new(h, 0.9, 0.9),
		position + Vector3.new(0, h * 0.5, 0),
		COLORS.Wood,
		Enum.Material.Wood,
		Vector3.new(0, 0, 90)
	)
	local crown = position + Vector3.new(0, h, 0)
	for index = 1, 7 do
		local angle = math.rad((index - 1) * (360 / 7) + (yaw or 0))
		local dx = math.cos(angle)
		local dz = math.sin(angle)
		block(
			palm,
			"Leaf" .. index,
			Vector3.new(0.75, 0.28, 5.4),
			crown + Vector3.new(dx * 1.8, 0.2, dz * 1.8),
			COLORS.Leaf,
			Enum.Material.Grass,
			Vector3.new(-14, math.deg(angle), 0)
		)
	end
end

local function addPlanter(parent, name, position, size)
	local planter = folder(parent, name)
	block(planter, "Box", size, position, COLORS.Concrete, Enum.Material.Concrete)
	block(planter, "Soil", size - Vector3.new(0.6, 0.65, 0.6), position + Vector3.new(0, 0.55, 0), COLORS.Soil, Enum.Material.Ground)
	for x = -1, 1 do
		part(
			planter,
			"Shrub" .. x,
			Vector3.new(1.7, 1.7, 1.7),
			CFrame.new(position + Vector3.new(x * 2.0, 1.5, 0)),
			COLORS.Leaf,
			Enum.Material.Grass,
			0,
			Enum.PartType.Ball
		)
	end
end

local function addEntranceDressing(root)
	local area = folder(root, "EntranceDressing")

	local sign = block(
		area,
		"StadiumWordmark",
		Vector3.new(60, 4.2, 0.6),
		Vector3.new(0, 24.0, -81.20),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, sign, "LARGE CITY STADIUM", Enum.NormalId.Front, COLORS.White)

	-- Thin cyan header reads as one continuous civic entrance identity across all gates.
	block(area, "EntranceAccent", Vector3.new(69, 0.8, 0.35), Vector3.new(0, 22.0, -80.75), COLORS.Cyan, Enum.Material.Neon)

	local gates = {
		-- Centers are aligned to the four actual entrance bays between the structural piers.
		{label = "A", x = -24.5},
		{label = "B", x = -12.0},
		{label = "C", x = 12.0},
		{label = "D", x = 24.5},
	}
	for _, gate in ipairs(gates) do
		local plaque = block(
			area,
			"Gate" .. gate.label,
			Vector3.new(6.5, 3.2, 0.42),
			Vector3.new(gate.x, 8.5, -81.00),
			COLORS.Teal,
			Enum.Material.SmoothPlastic
		)
		addSurfaceText(area, plaque, "GATE " .. gate.label, Enum.NormalId.Front, COLORS.White)
	end

	for _, x in ipairs({-38, -28, 28, 38}) do
		cylinder(
			area,
			"EntranceBollard" .. tostring(x),
			Vector3.new(2.6, 0.42, 0.42),
			Vector3.new(x, 1.3, -89.0),
			COLORS.Metal,
			Enum.Material.Metal,
			Vector3.new(0, 0, 90)
		)
	end

	addPlanter(area, "EntrancePlanterLeft", Vector3.new(-45, 0.85, -91), Vector3.new(11, 1.3, 3.4))
	addPlanter(area, "EntrancePlanterRight", Vector3.new(45, 0.85, -91), Vector3.new(11, 1.3, 3.4))
	addPalm(area, "EntrancePalmLeft", Vector3.new(-54, 0, -93), 12, 10)
	addPalm(area, "EntrancePalmRight", Vector3.new(54, 0, -93), 12, -10)
end

local function addFacadeDressing(root)
	local area = folder(root, "FacadeDressing")
	local screenAngles = {
		math.rad(36), math.rad(68), math.rad(112), math.rad(144),
		math.rad(216), math.rad(248), math.rad(292), math.rad(324),
	}
	local a, b = 113.2, 73.2

	for index, theta in ipairs(screenAngles) do
		local x = a * math.cos(theta)
		local z = b * math.sin(theta)
		local tangent = Vector3.new(-a * math.sin(theta), 0, b * math.cos(theta)).Unit
		local up = Vector3.yAxis
		local back = tangent:Cross(up).Unit
		local cf = CFrame.fromMatrix(Vector3.new(x, 31, z), tangent, up, back)
		local frame = part(
			area,
			"FacadeScreenFrame" .. index,
			Vector3.new(13.0, 8.8, 0.8),
			cf,
			COLORS.Dark,
			Enum.Material.Metal
		)
		local screen = part(
			area,
			"FacadeScreen" .. index,
			Vector3.new(11.7, 7.4, 0.35),
			cf * CFrame.new(0, 0, -0.58),
			index % 2 == 0 and COLORS.Cyan or COLORS.DarkGlass,
			Enum.Material.Glass,
			0.04
		)
		frame.CastShadow = true
		screen.CastShadow = false
	end

	-- A continuous lower cyan line visually ties the exterior screen modules together.
	for index = 0, 31 do
		local theta = (index / 32) * math.pi * 2
		local x = 111.8 * math.cos(theta)
		local z = 71.8 * math.sin(theta)
		local nextTheta = ((index + 1) / 32) * math.pi * 2
		local nx = 111.8 * math.cos(nextTheta)
		local nz = 71.8 * math.sin(nextTheta)
		local p1 = Vector3.new(x, 23.0, z)
		local p2 = Vector3.new(nx, 23.0, nz)
		local delta = p2 - p1
		local mid = p1:Lerp(p2, 0.5)
		part(
			area,
			"FacadeAccent" .. string.format("%02d", index + 1),
			Vector3.new(0.35, 0.65, delta.Magnitude * 1.04),
			CFrame.lookAt(mid, p2),
			COLORS.Teal,
			Enum.Material.Neon
		)
	end
end

local function addFloodlights(root)
	local area = folder(root, "Floodlights")
	local fieldTarget = Vector3.new(0, 3, 4)
	local mounts = {
		Vector3.new(-77, 74, -49),
		Vector3.new(77, 74, -49),
		Vector3.new(-77, 74, 49),
		Vector3.new(77, 74, 49),
	}

	for mountIndex, mount in ipairs(mounts) do
		local bank = folder(area, "FloodlightBank" .. mountIndex)
		local bankCF = CFrame.lookAt(mount, fieldTarget)

		-- Large visible stadium rig: dark backing frame, twin supports and a
		-- 6 x 3 lamp matrix aimed directly at the pitch.
		local backing = part(
			bank,
			"FloodlightFrame",
			Vector3.new(16.5, 10.0, 0.8),
			bankCF,
			COLORS.Dark,
			Enum.Material.Metal
		)
		backing.CastShadow = true

		part(
			bank,
			"UpperCrossbar",
			Vector3.new(17.5, 0.7, 1.2),
			bankCF * CFrame.new(0, 4.8, 0.45),
			COLORS.Metal,
			Enum.Material.Metal
		)
		part(
			bank,
			"LowerCrossbar",
			Vector3.new(17.5, 0.7, 1.2),
			bankCF * CFrame.new(0, -4.8, 0.45),
			COLORS.Metal,
			Enum.Material.Metal
		)

		-- Connect the floodlight frame directly to the inner side of the large
		-- stadium pylon. Using endpoint-to-endpoint beams keeps the braces touching
		-- the light frame and prevents them from protruding outside the pylon.
		local signX = mount.X < 0 and -1 or 1
		local signZ = mount.Z < 0 and -1 or 1
		local pylonInnerAnchor = Vector3.new(signX * 80.0, 59.0, signZ * 52.0)

		for _, supportX in ipairs({-3.1, 3.1}) do
			local upper = bankCF:PointToWorldSpace(Vector3.new(supportX, -4.55, 0.55))
			local lower = pylonInnerAnchor + bankCF.RightVector * (supportX * 0.72)
			local delta = upper - lower
			local middle = lower:Lerp(upper, 0.5)
			part(
				bank,
				"RearSupport" .. tostring(supportX),
				Vector3.new(0.95, 0.95, delta.Magnitude),
				CFrame.lookAt(middle, upper),
				COLORS.Metal,
				Enum.Material.Metal
			)
		end

		local centerLamp
		for row = 1, 3 do
			for column = 1, 6 do
				local x = (column - 3.5) * 2.45
				local y = (2 - row) * 2.65
				local lamp = part(
					bank,
					string.format("Lamp_R%d_C%d", row, column),
					Vector3.new(2.05, 1.95, 0.55),
					bankCF * CFrame.new(x, y, -0.72),
					COLORS.Light,
					Enum.Material.Neon
				)
				lamp.CastShadow = false

				local rim = part(
					bank,
					string.format("LampRim_R%d_C%d", row, column),
					Vector3.new(2.42, 2.30, 0.24),
					bankCF * CFrame.new(x, y, -0.48),
					COLORS.Metal,
					Enum.Material.Metal
				)
				rim.CastShadow = false

				if row == 2 and column == 3 then
					centerLamp = lamp
				end
			end
		end

		-- One strong spotlight per bank provides the actual night field illumination;
		-- the visible lamp matrix supplies the stadium-scale visual read.
		if centerLamp then
			local light = Instance.new("SpotLight")
			light.Name = "PitchFloodlight"
			light.Face = Enum.NormalId.Front
			light.Brightness = 5.0
			light.Range = 60
			light.Angle = 72
			light.Color = COLORS.Light
			light.Shadows = true
			light.Parent = centerLamp
		end
	end

	-- Roblox light range is limited, while the visual floodlight banks sit high
	-- on the stadium structure. Four invisible spill proxies over the pitch
	-- provide the broad night illumination that visually belongs to those banks.
	local spillPositions = {
		Vector3.new(-24, 38, -12),
		Vector3.new(24, 38, -12),
		Vector3.new(-24, 38, 20),
		Vector3.new(24, 38, 20),
	}
	for index, position in ipairs(spillPositions) do
		local target = Vector3.new(position.X * 0.35, 0.8, 4 + (position.Z - 4) * 0.25)
		local proxy = part(
			area,
			"FieldSpillProxy" .. index,
			Vector3.new(0.5, 0.5, 0.5),
			CFrame.lookAt(position, target),
			COLORS.Light,
			Enum.Material.SmoothPlastic,
			1
		)
		proxy.CastShadow = false

		local spill = Instance.new("SpotLight")
		spill.Name = "FieldSpill"
		spill.Face = Enum.NormalId.Front
		spill.Brightness = 2.4
		spill.Range = 60
		spill.Angle = 95
		spill.Color = COLORS.Light
		spill.Shadows = true
		spill.Parent = proxy
	end
end

local function addRearServiceDressing(root)
	local area = folder(root, "RearServiceDressing")

	local header = block(
		area,
		"RearServiceHeader",
		Vector3.new(44, 3.2, 0.45),
		Vector3.new(0, 14.2, 79.65),
		COLORS.Dark,
		Enum.Material.Metal
	)
	addSurfaceText(area, header, "TEAM  •  SERVICE  •  DELIVERIES", Enum.NormalId.Back, COLORS.White)

	for index, x in ipairs({-30, -15, 0, 15, 30}) do
		block(
			area,
			"RearBayFrame" .. index,
			Vector3.new(11.2, 8.2, 0.55),
			Vector3.new(x, 7, 79.55),
			COLORS.Dark,
			Enum.Material.Metal
		)

		local bayNumber = block(
			area,
			"RearBayNumber" .. index,
			Vector3.new(4.8, 2.0, 0.30),
			Vector3.new(x, 12.0, 79.88),
			index == 3 and COLORS.Cyan or COLORS.Teal,
			Enum.Material.Neon
		)
		addSurfaceText(area, bayNumber, string.format("%02d", index), Enum.NormalId.Back, COLORS.White)
	end

	local crew = block(
		area,
		"CrewEntranceLabel",
		Vector3.new(8.5, 1.8, 0.28),
		Vector3.new(0, 3.0, 79.9),
		COLORS.Cyan,
		Enum.Material.Neon
	)
	addSurfaceText(area, crew, "CREW", Enum.NormalId.Back, COLORS.White)

	for _, x in ipairs({-30, -15, 0, 15, 30}) do
		block(
			area,
			"LoadingGuide" .. tostring(x),
			Vector3.new(7.0, 0.10, 12.0),
			Vector3.new(x, 0.56, 88),
			COLORS.White,
			Enum.Material.SmoothPlastic
		)
	end

	for _, x in ipairs({-40, 40}) do
		cylinder(
			area,
			"RearBollard" .. tostring(x),
			Vector3.new(2.6, 0.42, 0.42),
			Vector3.new(x, 1.3, 83.5),
			COLORS.Metal,
			Enum.Material.Metal,
			Vector3.new(0, 0, 90)
		)
	end
end

local function addPitchDressing(root)
	local area = folder(root, "PitchDressing")
	local y = 0.82

	-- Minimal football markings remain subtle because Pong is the intentional Easter egg.
	block(area, "MidLine", Vector3.new(0.22, 0.08, 58), Vector3.new(0, y, 4), COLORS.White, Enum.Material.SmoothPlastic)
	block(area, "TopTouchline", Vector3.new(102, 0.08, 0.22), Vector3.new(0, y, -25), COLORS.White, Enum.Material.SmoothPlastic)
	block(area, "BottomTouchline", Vector3.new(102, 0.08, 0.22), Vector3.new(0, y, 33), COLORS.White, Enum.Material.SmoothPlastic)
	block(area, "LeftGoalLine", Vector3.new(0.22, 0.08, 58), Vector3.new(-51, y, 4), COLORS.White, Enum.Material.SmoothPlastic)
	block(area, "RightGoalLine", Vector3.new(0.22, 0.08, 58), Vector3.new(51, y, 4), COLORS.White, Enum.Material.SmoothPlastic)

	local centerRing = cylinder(
		area,
		"CenterCircle",
		Vector3.new(0.08, 18, 18),
		Vector3.new(0, y + 0.04, 4),
		COLORS.White,
		Enum.Material.SmoothPlastic,
		Vector3.new(0, 0, 90)
	)
	centerRing.Transparency = 0.35
end

function Dressing.Apply(model)
	assert(model and model:IsA("Model"), "LargeCityStadiumDressing.Apply expects a Model")

	local existing = model:FindFirstChild("Dressing")
	if existing then existing:Destroy() end
	local root = folder(model, "Dressing")

	-- The Golden Master still contains the earlier unframed exterior screen set.
	-- Phase 5 replaces those with the approved black-framed display modules, so
	-- remove the lower duplicate set only while dressing is applied.
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Name:match("^ExteriorScreen%d+") then
			item:Destroy()
		end
	end

	addEntranceDressing(root)
	addFacadeDressing(root)
	addFloodlights(root)
	addRearServiceDressing(root)
	addPitchDressing(root)

	model:SetAttribute("AssetPhase", 5)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Approved")
	model:SetAttribute("DressingRevision", "LargeCityStadium-Dressing-v6-RearServiceVisible")
	model:SetAttribute("DressingStatus", "Approved")
	model:SetAttribute("TextScaledRule", true)
	model:SetAttribute("LargeStadiumFloodlights", true)
	model:SetAttribute("FloodlightBankCount", 4)
	model:SetAttribute("FloodlightLampCount", 72)
	model:SetAttribute("FloodlightsMovedInward", true)
	model:SetAttribute("FloodlightSupportsAligned", true)
	model:SetAttribute("FloodlightsRaised", true)
	model:SetAttribute("FloodlightSupportsInnerAnchored", true)
	model:SetAttribute("RearServiceDressingVisible", true)
	model:SetAttribute("RearServiceBayCount", 5)
	return model
end

return Dressing
