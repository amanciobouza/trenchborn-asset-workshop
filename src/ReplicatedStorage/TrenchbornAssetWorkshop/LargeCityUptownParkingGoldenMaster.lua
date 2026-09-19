local specification = require(script.Parent:WaitForChild("LargeCityUptownParkingSpecification"))

local Builder = {}

local COLORS = {
	Concrete = Color3.fromRGB(216, 216, 207),
	ConcreteDark = Color3.fromRGB(165, 169, 165),
	Dark = Color3.fromRGB(39, 46, 49),
	DarkOpen = Color3.fromRGB(31, 39, 42),
	Metal = Color3.fromRGB(175, 179, 177),
	Bronze = Color3.fromRGB(154, 113, 72),
	Glass = Color3.fromRGB(58, 101, 112),
	Teal = Color3.fromRGB(57, 173, 178),
	PlantBed = Color3.fromRGB(68, 84, 63),
	Solar = Color3.fromRGB(42, 62, 70),
}

local LEVELS = {10.5, 16.0, 21.5, 27.0, 32.5, 38.0, 43.5}

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
	item.CanCollide = true
	item.CanTouch = true
	item.CanQuery = true
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function block(parent, name, size, position, color, material, transparency)
	return part(parent, name, size, CFrame.new(position), color, material, transparency)
end

local function cylinder(parent, name, height, diameter, position, color, material)
	return part(
		parent,
		name,
		Vector3.new(height, diameter, diameter),
		CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90)),
		color,
		material,
		0,
		Enum.PartType.Cylinder
	)
end

local function addBase(group)
	-- Open mobility base: strong enough to read at Kaiju scale, but not a sealed box.
	block(group, "BaseSlab", Vector3.new(68, 1.0, 58), Vector3.new(0, 0.5, 0), COLORS.Concrete, Enum.Material.Concrete)
	block(group, "BaseRoof", Vector3.new(68, 1.0, 58), Vector3.new(0, 9.5, 0), COLORS.Concrete, Enum.Material.Concrete)

	for _, x in ipairs({-31, -18, 18, 31}) do
		block(group, "FrontColumn_" .. x, Vector3.new(1.4, 9, 1.4), Vector3.new(x, 5, -26.5), COLORS.ConcreteDark, Enum.Material.Concrete)
		block(group, "RearColumn_" .. x, Vector3.new(1.4, 9, 1.4), Vector3.new(x, 5, 26.5), COLORS.ConcreteDark, Enum.Material.Concrete)
	end

	-- Vehicle portal and EV bay canopy on front.
	block(group, "VehiclePortalBeam", Vector3.new(30, 2.0, 2.0), Vector3.new(7, 8.0, -29.2), COLORS.Dark, Enum.Material.Metal)
	block(group, "EVCanopy", Vector3.new(28, 1.0, 8), Vector3.new(7, 8.8, -33.0), COLORS.Metal, Enum.Material.Metal)
	for _, x in ipairs({-5, 19}) do
		block(group, "EVCanopyPost_" .. x, Vector3.new(0.9, 8.0, 0.9), Vector3.new(x, 4.0, -36.3), COLORS.Metal, Enum.Material.Metal)
	end

	-- Pedestrian entry is separated from cars and tied to the glass core.
	block(group, "PedestrianPortal", Vector3.new(11, 8, 2.4), Vector3.new(-27, 4.5, -29.0), COLORS.Dark, Enum.Material.Metal)
	block(group, "PedestrianGlass", Vector3.new(8.5, 6.5, 0.6), Vector3.new(-27, 4.2, -30.6), COLORS.Glass, Enum.Material.Glass, 0.08)
end

local function addDeckStructure(group)
	-- Seven slabs bound six ventilated parking levels.
	for index, y in ipairs(LEVELS) do
		block(group, "ParkingSlab_" .. index, Vector3.new(66, 0.9, 56), Vector3.new(0, y, 0), COLORS.Concrete, Enum.Material.Concrete)
	end

	-- Long horizontal edge beams make the open parking gaps explicit.
	for level = 1, 6 do
		local y = 12.9 + (level - 1) * 5.5
		block(group, "FrontEdgeBeam_" .. level, Vector3.new(62, 0.75, 1.1), Vector3.new(0, y, -27.4), COLORS.ConcreteDark, Enum.Material.Concrete)
		block(group, "RearEdgeBeam_" .. level, Vector3.new(62, 0.75, 1.1), Vector3.new(0, y, 27.4), COLORS.ConcreteDark, Enum.Material.Concrete)
	end

	-- Full-height columns give the garage a believable structural grid.
	for _, x in ipairs({-29, -15, 0, 15, 29}) do
		for _, z in ipairs({-24, 0, 24}) do
			block(group, "StructuralColumn_" .. x .. "_" .. z, Vector3.new(1.2, 34, 1.2), Vector3.new(x, 27, z), COLORS.ConcreteDark, Enum.Material.Concrete)
		end
	end
end

local function addScreenVeil(group)
	-- Front screen: leave the left-central green breathing cut open.
	local frontZ = -29.2
	local frontIndex = 0
	for x = -31, 31, 2.8 do
		local inGreenCut = x >= -21 and x <= -3
		local inVehicleEntry = x >= -7 and x <= 20
		if not inGreenCut and not inVehicleEntry then
			frontIndex += 1
			local color = frontIndex % 5 == 0 and COLORS.Bronze or COLORS.Metal
			block(group, "FrontFin_" .. frontIndex, Vector3.new(0.65, 34, 1.1), Vector3.new(x, 27, frontZ), color, Enum.Material.Metal)
		end
	end

	-- Rear screen: leave the upper-right breathing cut visually open.
	local rearZ = 29.2
	local rearIndex = 0
	for x = -31, 31, 2.8 do
		local inGreenCut = x >= 6 and x <= 22
		if not inGreenCut then
			rearIndex += 1
			local color = rearIndex % 5 == 0 and COLORS.Bronze or COLORS.Metal
			block(group, "RearFin_" .. rearIndex, Vector3.new(0.65, 34, 1.1), Vector3.new(x, 27, rearZ), color, Enum.Material.Metal)
		end
	end

	-- Side fins preserve the layered/ventilated read without sealing the building.
	for sideName, x in pairs({Left = -34.0, Right = 34.0}) do
		local index = 0
		for z = -24, 24, 3.3 do
			index += 1
			local color = index % 5 == 0 and COLORS.Bronze or COLORS.Metal
			block(group, sideName .. "Fin_" .. index, Vector3.new(1.1, 34, 0.65), Vector3.new(x, 27, z), color, Enum.Material.Metal)
		end
	end
end

local function addGreenCuts(group)
	-- Front planted breathing cut.
	for index, y in ipairs({19.2, 25.0, 30.8}) do
		block(group, "FrontGreenTerrace_" .. index, Vector3.new(18, 0.9, 6), Vector3.new(-12, y, -30.5), COLORS.Concrete, Enum.Material.Concrete)
		block(group, "FrontGreenBed_" .. index, Vector3.new(15, 0.75, 3.2), Vector3.new(-12, y + 0.8, -32.0), COLORS.PlantBed, Enum.Material.Ground)
		block(group, "FrontGreenRail_" .. index, Vector3.new(16.5, 1.3, 0.25), Vector3.new(-12, y + 1.5, -33.45), COLORS.Glass, Enum.Material.Glass, 0.18)
	end

	-- Rear-right planted breathing cut.
	for index, y in ipairs({31.0, 36.5, 42.0}) do
		block(group, "RearGreenTerrace_" .. index, Vector3.new(16, 0.9, 6), Vector3.new(14, y, 30.5), COLORS.Concrete, Enum.Material.Concrete)
		block(group, "RearGreenBed_" .. index, Vector3.new(13, 0.75, 3.2), Vector3.new(14, y + 0.8, 32.0), COLORS.PlantBed, Enum.Material.Ground)
		block(group, "RearGreenRail_" .. index, Vector3.new(14.5, 1.3, 0.25), Vector3.new(14, y + 1.5, 33.45), COLORS.Glass, Enum.Material.Glass, 0.18)
	end
end

local function addExpressedRamp(group)
	-- Six parallel sloped ramp plates at the front-right corner make circulation obvious.
	local x = 24
	local run = 18
	local rise = 4.7
	local angle = math.atan(rise / run)
	local rampLength = math.sqrt(run * run + rise * rise)

	for level = 1, 6 do
		local baseY = 10.5 + (level - 1) * 5.5
		local centerY = baseY + rise / 2
		local centerZ = -17.0
		part(
			group,
			"Ramp_" .. level,
			Vector3.new(10, 0.75, rampLength),
			CFrame.new(x, centerY, centerZ) * CFrame.Angles(-angle, 0, 0),
			COLORS.ConcreteDark,
			Enum.Material.Concrete
		)
		block(group, "RampEdgeOuter_" .. level, Vector3.new(0.7, 1.1, rampLength), Vector3.new(29.65, centerY, centerZ), COLORS.Bronze, Enum.Material.Metal)
	end

	-- Open corner frame keeps the ramps visually distinct from the screen veil.
	for _, xPos in ipairs({18.5, 29.5}) do
		block(group, "RampCornerColumn_" .. xPos, Vector3.new(1.0, 34, 1.0), Vector3.new(xPos, 27, -25.5), COLORS.Dark, Enum.Material.Metal)
	end
end

local function addPedestrianCore(group)
	-- Core projects beyond the facade screen and remains readable from the street.
	block(group, "CoreMass", Vector3.new(10, 50, 12), Vector3.new(-29, 25, -18), COLORS.Dark, Enum.Material.Metal)
	block(group, "CoreGlassFront", Vector3.new(8.5, 47, 0.65), Vector3.new(-29, 25, -24.35), COLORS.Glass, Enum.Material.Glass, 0.07)
	block(group, "CoreGlassSide", Vector3.new(0.65, 47, 10), Vector3.new(-34.35, 25, -18), COLORS.Glass, Enum.Material.Glass, 0.07)
	for y = 6, 46, 6.5 do
		block(group, "CoreHorizontal_" .. tostring(y), Vector3.new(9, 0.45, 0.8), Vector3.new(-29, y, -24.7), COLORS.Metal, Enum.Material.Metal)
	end
	block(group, "CoreTop", Vector3.new(11, 1.0, 13), Vector3.new(-29, 50.5, -18), COLORS.Metal, Enum.Material.Metal)
end

local function addRooftopMobilityDeck(group)
	block(group, "RoofDeck", Vector3.new(62, 1.0, 52), Vector3.new(0, 44.5, 0), COLORS.Concrete, Enum.Material.Concrete)

	-- Light solar/pergola canopy.
	for _, x in ipairs({-21, 21}) do
		for _, z in ipairs({-12, 12}) do
			block(group, "CanopyPost_" .. x .. "_" .. z, Vector3.new(0.8, 5.5, 0.8), Vector3.new(x, 47.5, z), COLORS.Metal, Enum.Material.Metal)
		end
	end

	for index = 0, 7 do
		local x = -20 + index * (40 / 7)
		block(group, "SolarFin_" .. index, Vector3.new(4.4, 0.45, 28), Vector3.new(x, 50.1, 0), COLORS.Solar, Enum.Material.Metal)
	end

	-- Roof planting stays on the edge, leaving the mobility deck open.
	block(group, "RoofPlantBedLeft", Vector3.new(5, 0.8, 38), Vector3.new(-27, 45.4, 2), COLORS.PlantBed, Enum.Material.Ground)
	block(group, "RoofPlantBedRear", Vector3.new(36, 0.8, 5), Vector3.new(6, 45.4, 23), COLORS.PlantBed, Enum.Material.Ground)
	block(group, "RoofTealEdge", Vector3.new(40, 0.45, 0.5), Vector3.new(0, 50.45, -14.2), COLORS.Teal, Enum.Material.Neon)
end

local function addRearService(group)
	block(group, "RearServiceHeader", Vector3.new(20, 3.0, 1.0), Vector3.new(-16, 8.0, 29.8), COLORS.Dark, Enum.Material.Metal)
	for index, x in ipairs({-20, -12}) do
		block(group, "RearServiceDoor_" .. index, Vector3.new(7, 6.5, 0.6), Vector3.new(x, 4.0, 30.4), COLORS.DarkOpen, Enum.Material.Metal)
	end
	block(group, "RearServiceCanopy", Vector3.new(22, 1.0, 7), Vector3.new(-16, 10.0, 33.0), COLORS.Metal, Enum.Material.Metal)
	block(group, "RearServiceApron", Vector3.new(28, 0.45, 12), Vector3.new(-16, 0.23, 36.0), COLORS.ConcreteDark, Enum.Material.Concrete)
end

local function countVisibleParts(model)
	local count = 0
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			count += 1
		end
	end
	model:SetAttribute("VisiblePartCount", count)
	model:SetAttribute("VisiblePartBudget", 780)
	model:SetAttribute("VisiblePartBudgetPassed", count <= 780)
end

function Builder.Build(parent)
	local existing = parent:FindFirstChild("LargeCity_UptownParking_L3_GoldenMaster")
	if existing then existing:Destroy() end

	local model = Instance.new("Model")
	model.Name = "LargeCity_UptownParking_L3_GoldenMaster"
	model:SetAttribute("AssetId", specification.AssetId)
	model:SetAttribute("DisplayName", specification.DisplayName)
	model:SetAttribute("AssetPhase", 4)
	model:SetAttribute("QualityGateA", "Approved")
	model:SetAttribute("QualityGateB", "Pending")
	model:SetAttribute("GeometryRevision", "LargeCityUptownParking-v1-VerdantMobilityDeck")
	model:SetAttribute("MaxHealth", specification.ProposedGameplayMetadata.TargetMaxHealth)
	model:SetAttribute("EnergyType", specification.ProposedGameplayMetadata.EnergyType)
	model:SetAttribute("InstallerTag", specification.ProposedGameplayMetadata.InstallerTag)
	model:SetAttribute("StandaloneImport", true)
	model:SetAttribute("HasInterior", false)
	model:SetAttribute("ParkingLevelCount", 6)
	model:SetAttribute("VentilatedFacade", true)
	model:SetAttribute("ExpressedRampVisible", true)
	model:SetAttribute("GreenBreathingCuts", 2)
	model:SetAttribute("RooftopSolarCanopy", true)
	model:SetAttribute("RearServiceVisible", true)
	model.Parent = parent

	local groups = folder(model, "DestructionGroups")
	local d1 = folder(groups, "D1_VehicleEntryAndEVHub")
	local d2 = folder(groups, "D2_LowerParkingDecks")
	local d3 = folder(groups, "D3_UpperParkingDecks")
	local d4 = folder(groups, "D4_ExpressedRamp")
	local d5 = folder(groups, "D5_ScreenVeilAndGreenCuts")
	local d6 = folder(groups, "D6_RooftopMobilityDeck")
	local d7 = folder(groups, "D7_PedestrianCoreAndService")

	addBase(d1)
	addDeckStructure(d2)
	-- Upper decks are still physically part of the same structure but grouped for destruction.
	for _, y in ipairs({32.5, 38.0, 43.5}) do
		block(d3, "UpperDeckReinforcement_" .. tostring(y), Vector3.new(62, 0.35, 52), Vector3.new(0, y + 0.62, 0), COLORS.ConcreteDark, Enum.Material.Concrete)
	end
	addExpressedRamp(d4)
	addScreenVeil(d5)
	addGreenCuts(d5)
	addRooftopMobilityDeck(d6)
	addPedestrianCore(d7)
	addRearService(d7)

	local pivot = part(model, "GroundPivot", Vector3.new(1, 1, 1), CFrame.new(0, 0.5, 0), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, 1)
	pivot.CanCollide = false
	pivot.CanTouch = false
	pivot.CanQuery = false
	pivot.CastShadow = false
	model.PrimaryPart = pivot
	model:PivotTo(CFrame.new())

	countVisibleParts(model)
	return model
end

return Builder
