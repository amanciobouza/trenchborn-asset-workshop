local specification = require(script.Parent:WaitForChild("FireStationKitSpecification"))

local Builder = {}

local COLORS = {
	Concrete = Color3.fromRGB(205, 210, 210),
	ConcreteDark = Color3.fromRGB(125, 132, 136),
	Graphite = Color3.fromRGB(48, 54, 58),
	Red = Color3.fromRGB(184, 34, 36),
	RedDark = Color3.fromRGB(118, 26, 29),
	Glass = Color3.fromRGB(80, 150, 165),
	Metal = Color3.fromRGB(100, 107, 112),
	White = Color3.fromRGB(235, 238, 237),
	Yellow = Color3.fromRGB(235, 184, 55),
	Asphalt = Color3.fromRGB(72, 75, 77),
}

local function folder(parent, name)
	local item = Instance.new("Folder")
	item.Name = name
	item.Parent = parent
	return item
end

local function part(parent, name, size, position, color, material, transparency)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = CFrame.new(position)
	item.Color = color or COLORS.Concrete
	item.Material = material or Enum.Material.SmoothPlastic
	item.Transparency = transparency or 0
	item.Anchored = true
	item.CanCollide = true
	item.CastShadow = true
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.Parent = parent
	return item
end

local function glass(parent, name, size, position)
	local item = part(parent, name, size, position, COLORS.Glass, Enum.Material.Glass, 0.2)
	item.Reflectance = 0.04
	return item
end

local function newModule(parent, name, category, size)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("KitId", specification.KitId)
	model:SetAttribute("KitVersion", specification.Version)
	model:SetAttribute("Category", category)
	model:SetAttribute("GridSize", specification.GridSize)
	model:SetAttribute("NominalWidth", size.X)
	model:SetAttribute("NominalHeight", size.Y)
	model:SetAttribute("NominalDepth", size.Z)
	model.Parent = parent

	local pivot = part(model, "GroundPivot", Vector3.new(0.2, 0.2, 0.2), Vector3.new(0, 0, 0), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, 1)
	pivot.CanCollide = false
	pivot.CanQuery = false
	pivot.CastShadow = false
	model.PrimaryPart = pivot
	return model
end

local function shellCore(parent, name, width, depth, height)
	local model = newModule(parent, name, "Core", Vector3.new(width, height, depth))
	part(model, "Floor", Vector3.new(width, 1, depth), Vector3.new(width / 2, 0.5, depth / 2), COLORS.ConcreteDark, Enum.Material.Concrete)
	part(model, "LeftFrame", Vector3.new(1, height, depth), Vector3.new(0.5, height / 2, depth / 2), COLORS.Graphite, Enum.Material.Metal)
	part(model, "RightFrame", Vector3.new(1, height, depth), Vector3.new(width - 0.5, height / 2, depth / 2), COLORS.Graphite, Enum.Material.Metal)
	part(model, "RearWall", Vector3.new(width, height, 1), Vector3.new(width / 2, height / 2, depth - 0.5), COLORS.Concrete, Enum.Material.Concrete)
	part(model, "RoofSlab", Vector3.new(width, 1, depth), Vector3.new(width / 2, height - 0.5, depth / 2), COLORS.Concrete, Enum.Material.Concrete)
	return model
end

local function buildCore(category)
	shellCore(category, "TBK_FS_Core_Bay_A", 16, 32, 16)
	shellCore(category, "TBK_FS_Core_BayDouble_A", 32, 32, 16)

	local office = shellCore(category, "TBK_FS_Core_Office_A", 16, 32, 16)
	part(office, "MidBeam", Vector3.new(16, 1, 1), Vector3.new(8, 8, 0.5), COLORS.Graphite, Enum.Material.Metal)

	local stair = shellCore(category, "TBK_FS_Core_Stair_A", 16, 16, 16)
	part(stair, "VerticalCore", Vector3.new(7, 14, 7), Vector3.new(8, 7, 8), COLORS.ConcreteDark, Enum.Material.Concrete)

	local tower = newModule(category, "TBK_FS_Core_TrainingTower_A", "Core", Vector3.new(16, 32, 16))
	part(tower, "TowerMass", Vector3.new(14, 32, 14), Vector3.new(8, 16, 8), COLORS.Concrete, Enum.Material.Concrete)
	for y = 6, 26, 8 do
		part(tower, "DrillBalcony_" .. y, Vector3.new(16, 0.7, 4), Vector3.new(8, y, -1), COLORS.Graphite, Enum.Material.Metal)
	end
end

local function facadeFrame(parent, name, accent)
	local model = newModule(parent, name, "Facades", Vector3.new(16, 12, 1))
	part(model, "FrameTop", Vector3.new(16, 1, 1), Vector3.new(8, 11.5, 0.5), accent, Enum.Material.Metal)
	part(model, "FrameLeft", Vector3.new(1, 12, 1), Vector3.new(0.5, 6, 0.5), accent, Enum.Material.Metal)
	part(model, "FrameRight", Vector3.new(1, 12, 1), Vector3.new(15.5, 6, 0.5), accent, Enum.Material.Metal)
	return model
end

local function buildFacades(category)
	local garageA = facadeFrame(category, "TBK_FS_Facade_Garage_A", COLORS.Red)
	part(garageA, "Door", Vector3.new(13.5, 10, 0.5), Vector3.new(8, 5.5, 0.7), COLORS.Graphite, Enum.Material.Metal)
	for x = 3, 13, 2 do
		part(garageA, "DoorRib_" .. x, Vector3.new(0.15, 9, 0.2), Vector3.new(x, 5.5, 0.42), COLORS.Metal, Enum.Material.Metal)
	end

	local garageB = facadeFrame(category, "TBK_FS_Facade_Garage_B", COLORS.RedDark)
	part(garageB, "Door", Vector3.new(13.5, 10, 0.5), Vector3.new(8, 5.5, 0.7), COLORS.ConcreteDark, Enum.Material.Metal)
	glass(garageB, "DoorWindowBand", Vector3.new(11.5, 2.2, 0.25), Vector3.new(8, 6.5, 0.35))

	local windowA = newModule(category, "TBK_FS_Facade_Window_A", "Facades", Vector3.new(16, 12, 1))
	part(windowA, "Wall", Vector3.new(16, 12, 0.5), Vector3.new(8, 6, 0.5), COLORS.Concrete, Enum.Material.Concrete)
	glass(windowA, "Window", Vector3.new(11, 6, 0.4), Vector3.new(8, 6.2, 0.2))
	part(windowA, "RedBand", Vector3.new(16, 0.8, 0.7), Vector3.new(8, 10.6, 0.1), COLORS.Red, Enum.Material.Metal)

	local windowB = newModule(category, "TBK_FS_Facade_Window_B", "Facades", Vector3.new(16, 12, 1))
	part(windowB, "Wall", Vector3.new(16, 12, 0.5), Vector3.new(8, 6, 0.5), COLORS.Concrete, Enum.Material.Concrete)
	for index = 0, 2 do
		glass(windowB, "Window_" .. index, Vector3.new(3.3, 6.8, 0.4), Vector3.new(4 + index * 4, 6.2, 0.2))
	end

	local windowC = newModule(category, "TBK_FS_Facade_Window_C", "Facades", Vector3.new(16, 12, 1))
	part(windowC, "Wall", Vector3.new(16, 12, 0.5), Vector3.new(8, 6, 0.5), COLORS.Graphite, Enum.Material.Metal)
	glass(windowC, "CurtainGlass", Vector3.new(14, 9.5, 0.4), Vector3.new(8, 6, 0.2))
	for x = 3, 13, 2.5 do
		part(windowC, "Mullion_" .. tostring(x), Vector3.new(0.25, 9.5, 0.3), Vector3.new(x, 6, 0.05), COLORS.Metal, Enum.Material.Metal)
	end

	local solidA = newModule(category, "TBK_FS_Facade_Solid_A", "Facades", Vector3.new(16, 12, 1))
	part(solidA, "Wall", Vector3.new(16, 12, 1), Vector3.new(8, 6, 0.5), COLORS.Concrete, Enum.Material.Concrete)
	part(solidA, "RedStripe", Vector3.new(16, 1, 1.1), Vector3.new(8, 9.5, 0.45), COLORS.Red, Enum.Material.Metal)

	local solidB = newModule(category, "TBK_FS_Facade_Solid_B", "Facades", Vector3.new(16, 12, 1))
	part(solidB, "Wall", Vector3.new(16, 12, 1), Vector3.new(8, 6, 0.5), COLORS.ConcreteDark, Enum.Material.Concrete)
	for x = 2, 14, 3 do
		part(solidB, "VerticalRib_" .. x, Vector3.new(0.35, 10, 0.3), Vector3.new(x, 6, -0.15), COLORS.Graphite, Enum.Material.Metal)
	end
end

local function buildEntrances(category)
	local main = newModule(category, "TBK_FS_Entrance_Main_A", "Entrances", Vector3.new(16, 12, 8))
	part(main, "Portal", Vector3.new(16, 12, 2), Vector3.new(8, 6, 1), COLORS.Concrete, Enum.Material.Concrete)
	glass(main, "DoorLeft", Vector3.new(5, 8, 0.4), Vector3.new(5.2, 4.5, -0.15))
	glass(main, "DoorRight", Vector3.new(5, 8, 0.4), Vector3.new(10.8, 4.5, -0.15))
	part(main, "Canopy", Vector3.new(14, 0.7, 6), Vector3.new(8, 10.2, -2), COLORS.Red, Enum.Material.Metal)

	local service = newModule(category, "TBK_FS_Entrance_Service_A", "Entrances", Vector3.new(16, 12, 4))
	part(service, "Wall", Vector3.new(16, 12, 1), Vector3.new(8, 6, 0.5), COLORS.ConcreteDark, Enum.Material.Concrete)
	part(service, "Door", Vector3.new(4, 8, 0.5), Vector3.new(8, 4, -0.05), COLORS.Graphite, Enum.Material.Metal)

	local canopy = newModule(category, "TBK_FS_Entrance_Canopy_A", "Entrances", Vector3.new(16, 4, 8))
	part(canopy, "Blade", Vector3.new(16, 0.8, 8), Vector3.new(8, 3.6, 4), COLORS.Red, Enum.Material.Metal)
	for x = 2, 14, 12 do
		part(canopy, "Column_" .. x, Vector3.new(0.7, 3.5, 0.7), Vector3.new(x, 1.75, 4), COLORS.Graphite, Enum.Material.Metal)
	end
end

local function buildRoof(category)
	local flat = newModule(category, "TBK_FS_Roof_Flat_A", "Roof", Vector3.new(16, 1, 16))
	part(flat, "Slab", Vector3.new(16, 1, 16), Vector3.new(8, 0.5, 8), COLORS.Concrete, Enum.Material.Concrete)

	local parapet = newModule(category, "TBK_FS_Roof_Parapet_A", "Roof", Vector3.new(16, 2, 1))
	part(parapet, "Parapet", Vector3.new(16, 2, 1), Vector3.new(8, 1, 0.5), COLORS.Concrete, Enum.Material.Concrete)

	local corner = newModule(category, "TBK_FS_Roof_Corner_A", "Roof", Vector3.new(1, 2, 1))
	part(corner, "Corner", Vector3.new(1, 2, 1), Vector3.new(0.5, 1, 0.5), COLORS.Concrete, Enum.Material.Concrete)

	local hvac = newModule(category, "TBK_FS_Roof_HVAC_A", "Roof", Vector3.new(8, 4, 8))
	part(hvac, "Base", Vector3.new(8, 3, 8), Vector3.new(4, 1.5, 4), COLORS.Metal, Enum.Material.Metal)
	for z = 1.5, 6.5, 1.25 do
		part(hvac, "Vent_" .. tostring(z), Vector3.new(7, 0.2, 0.4), Vector3.new(4, 2, z), COLORS.Graphite, Enum.Material.Metal)
	end
end

local function buildProps(category)
	local bollard = newModule(category, "TBK_FS_Prop_Bollard_A", "Props", Vector3.new(1, 4, 1))
	part(bollard, "Bollard", Vector3.new(1, 4, 1), Vector3.new(0.5, 2, 0.5), COLORS.Red, Enum.Material.Metal)

	local hose = newModule(category, "TBK_FS_Prop_HoseRack_A", "Props", Vector3.new(6, 5, 2))
	part(hose, "Frame", Vector3.new(6, 5, 1), Vector3.new(3, 2.5, 0.5), COLORS.Graphite, Enum.Material.Metal)
	for y = 1, 4, 1.5 do
		part(hose, "Hose_" .. tostring(y), Vector3.new(5, 0.45, 1.2), Vector3.new(3, y, 1.2), COLORS.Yellow, Enum.Material.SmoothPlastic)
	end

	local box = newModule(category, "TBK_FS_Prop_EquipmentBox_A", "Props", Vector3.new(4, 5, 2))
	part(box, "Cabinet", Vector3.new(4, 5, 2), Vector3.new(2, 2.5, 1), COLORS.RedDark, Enum.Material.Metal)

	local light = newModule(category, "TBK_FS_Prop_WallLight_A", "Props", Vector3.new(2, 1, 1))
	part(light, "Housing", Vector3.new(2, 1, 1), Vector3.new(1, 0.5, 0.5), COLORS.Graphite, Enum.Material.Metal)
	local lens = part(light, "Lens", Vector3.new(1.4, 0.5, 0.15), Vector3.new(1, 0.5, -0.08), COLORS.White, Enum.Material.Neon)
	lens.CanCollide = false

	local antenna = newModule(category, "TBK_FS_Prop_RoofAntenna_A", "Props", Vector3.new(2, 8, 2))
	part(antenna, "Mast", Vector3.new(0.4, 8, 0.4), Vector3.new(1, 4, 1), COLORS.Metal, Enum.Material.Metal)
	part(antenna, "Crossbar", Vector3.new(2, 0.3, 0.3), Vector3.new(1, 6, 1), COLORS.Metal, Enum.Material.Metal)

	local vent = newModule(category, "TBK_FS_Prop_Vent_A", "Props", Vector3.new(4, 3, 4))
	part(vent, "Vent", Vector3.new(4, 3, 4), Vector3.new(2, 1.5, 2), COLORS.Metal, Enum.Material.Metal)

	local alarm = newModule(category, "TBK_FS_Prop_AlarmLight_A", "Props", Vector3.new(1, 1, 1))
	local beacon = part(alarm, "Beacon", Vector3.new(1, 1, 1), Vector3.new(0.5, 0.5, 0.5), COLORS.Red, Enum.Material.Neon)
	beacon.Shape = Enum.PartType.Ball
	beacon.CanCollide = false
end

local function addTextSign(model, width, height, text)
	part(model, "Board", Vector3.new(width, height, 0.6), Vector3.new(width / 2, height / 2, 0.3), COLORS.Graphite, Enum.Material.Metal)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = Enum.NormalId.Front
	gui.AlwaysOnTop = false
	gui.Parent = model.Board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = COLORS.White
	label.Parent = gui
end

local function buildSignage(category)
	local fire = newModule(category, "TBK_FS_Sign_FireStation_A", "Signage", Vector3.new(16, 4, 1))
	addTextSign(fire, 16, 4, "FIRE STATION")
	local number = newModule(category, "TBK_FS_Sign_Number_A", "Signage", Vector3.new(6, 4, 1))
	addTextSign(number, 6, 4, "03")
end

local function buildExterior(category)
	local apron = newModule(category, "TBK_FS_Ext_Apron_A", "Exterior", Vector3.new(16, 1, 16))
	part(apron, "Apron", Vector3.new(16, 1, 16), Vector3.new(8, 0.5, 8), COLORS.Asphalt, Enum.Material.Asphalt)
	part(apron, "CenterMark", Vector3.new(0.4, 0.08, 10), Vector3.new(8, 1.04, 8), COLORS.Yellow, Enum.Material.Neon).CanCollide = false

	local sidewalk = newModule(category, "TBK_FS_Ext_Sidewalk_A", "Exterior", Vector3.new(16, 1, 8))
	part(sidewalk, "Sidewalk", Vector3.new(16, 1, 8), Vector3.new(8, 0.5, 4), COLORS.Concrete, Enum.Material.Concrete)

	local curb = newModule(category, "TBK_FS_Ext_Curb_A", "Exterior", Vector3.new(16, 1, 2))
	part(curb, "Curb", Vector3.new(16, 1, 2), Vector3.new(8, 0.5, 1), COLORS.Concrete, Enum.Material.Concrete)
end

local function cloneAt(parent, source, x, y, z, yaw)
	local clone = source:Clone()
	clone.Parent = parent
	clone:PivotTo(CFrame.new(x or 0, y or 0, z or 0) * CFrame.Angles(0, math.rad(yaw or 0), 0))
	return clone
end

local function exampleModel(parent, name)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("KitId", specification.KitId)
	model:SetAttribute("KitVersion", specification.Version)
	model:SetAttribute("Example", true)
	model.Parent = parent
	local pivot = part(model, "GroundPivot", Vector3.new(0.2, 0.2, 0.2), Vector3.new(0, 0, 0), Color3.new(1,1,1), Enum.Material.SmoothPlastic, 1)
	pivot.CanCollide = false
	pivot.CanQuery = false
	pivot.CastShadow = false
	model.PrimaryPart = pivot
	return model
end

local function buildExamples(root)
	local examples = root:FindFirstChild("Examples")
	local core = root:FindFirstChild("Core")
	local facades = root:FindFirstChild("Facades")
	local entrances = root:FindFirstChild("Entrances")
	local roof = root:FindFirstChild("Roof")
	local signage = root:FindFirstChild("Signage")
	local exterior = root:FindFirstChild("Exterior")

	local function addFront(example, x, facadeName)
		cloneAt(example, facades:FindFirstChild(facadeName), x, 0, -1)
		cloneAt(example, exterior:FindFirstChild("TBK_FS_Ext_Apron_A"), x, 0, -17)
	end

	local small = exampleModel(examples, specification.Examples.Small.Name)
	cloneAt(small, core.TBK_FS_Core_Office_A, 0, 0, 0)
	cloneAt(small, core.TBK_FS_Core_Bay_A, 16, 0, 0)
	cloneAt(small, entrances.TBK_FS_Entrance_Main_A, 0, 0, -1)
	addFront(small, 16, "TBK_FS_Facade_Garage_A")
	cloneAt(small, signage.TBK_FS_Sign_FireStation_A, 0, 11.5, -1.1)
	cloneAt(small, roof.TBK_FS_Roof_HVAC_A, 4, 16, 12)

	local standard = exampleModel(examples, specification.Examples.Standard.Name)
	cloneAt(standard, core.TBK_FS_Core_Office_A, 0, 0, 0)
	for index = 0, 1 do
		local x = 16 + index * 16
		cloneAt(standard, core.TBK_FS_Core_Bay_A, x, 0, 0)
		addFront(standard, x, index == 0 and "TBK_FS_Facade_Garage_A" or "TBK_FS_Facade_Garage_B")
	end
	cloneAt(standard, entrances.TBK_FS_Entrance_Main_A, 0, 0, -1)
	cloneAt(standard, signage.TBK_FS_Sign_FireStation_A, 0, 11.5, -1.1)
	cloneAt(standard, roof.TBK_FS_Roof_HVAC_A, 6, 16, 10)

	local large = exampleModel(examples, specification.Examples.Large.Name)
	cloneAt(large, core.TBK_FS_Core_Office_A, 0, 0, 0)
	for index = 0, 2 do
		local x = 16 + index * 16
		cloneAt(large, core.TBK_FS_Core_Bay_A, x, 0, 0)
		addFront(large, x, "TBK_FS_Facade_Garage_A")
	end
	cloneAt(large, entrances.TBK_FS_Entrance_Main_A, 0, 0, -1)
	cloneAt(large, signage.TBK_FS_Sign_FireStation_A, 0, 11.5, -1.1)
	cloneAt(large, core.TBK_FS_Core_TrainingTower_A, 48, 0, 32)
	cloneAt(large, roof.TBK_FS_Roof_HVAC_A, 4, 16, 12)
end

local function validateModulePivots(root)
	for _, categoryName in ipairs({"Core", "Facades", "Entrances", "Roof", "Props", "Signage", "Exterior"}) do
		local category = root:FindFirstChild(categoryName)
		for _, module in ipairs(category:GetChildren()) do
			assert(module:IsA("Model") and module.PrimaryPart, module.Name .. " must be a Model with a PrimaryPart")
			assert(module.PrimaryPart.Name == "GroundPivot", module.Name .. " must use GroundPivot")
		end
	end
end

function Builder.Build(parent)
	assert(typeof(parent) == "Instance", "FireStationKitBuilder.Build requires a parent Instance")
	local existing = parent:FindFirstChild("TBK_FS_FireStationKit_v1")
	if existing then
		existing:Destroy()
	end

	local root = Instance.new("Model")
	root.Name = "TBK_FS_FireStationKit_v1"
	root:SetAttribute("KitId", specification.KitId)
	root:SetAttribute("DisplayName", specification.DisplayName)
	root:SetAttribute("KitVersion", specification.Version)
	root:SetAttribute("GridSize", specification.GridSize)
	root:SetAttribute("SourceFamily", specification.SourceFamily)
	root:SetAttribute("ModuleNaming", "TBK_FS_<CATEGORY>_<NAME>_<VARIANT>")
	root.Parent = parent

	local rootPivot = part(root, "GroundPivot", Vector3.new(0.2, 0.2, 0.2), Vector3.new(0,0,0), Color3.new(1,1,1), Enum.Material.SmoothPlastic, 1)
	rootPivot.CanCollide = false
	rootPivot.CanQuery = false
	rootPivot.CastShadow = false
	root.PrimaryPart = rootPivot

	local core = folder(root, "Core")
	local facades = folder(root, "Facades")
	local entrances = folder(root, "Entrances")
	local roof = folder(root, "Roof")
	local props = folder(root, "Props")
	local signage = folder(root, "Signage")
	local exterior = folder(root, "Exterior")
	folder(root, "Examples")
	local metadata = folder(root, "Metadata")

	buildCore(core)
	buildFacades(facades)
	buildEntrances(entrances)
	buildRoof(roof)
	buildProps(props)
	buildSignage(signage)
	buildExterior(exterior)
	buildExamples(root)

	metadata:SetAttribute("KitName", specification.DisplayName)
	metadata:SetAttribute("KitVersion", specification.Version)
	metadata:SetAttribute("GridSize", specification.GridSize)
	metadata:SetAttribute("NormalFloorHeight", specification.NormalFloorHeight)
	metadata:SetAttribute("LargeGroundFloorHeight", specification.LargeGroundFloorHeight)
	metadata:SetAttribute("SourceReference", specification.SourceReference)

	validateModulePivots(root)
	return root
end

function Builder.CloneModule(kit, categoryName, moduleName, parent, targetCFrame)
	assert(kit and kit:IsA("Model"), "CloneModule requires a built Fire Station Kit")
	local category = kit:FindFirstChild(categoryName)
	assert(category, "Unknown Fire Station Kit category: " .. tostring(categoryName))
	local source = category:FindFirstChild(moduleName)
	assert(source and source:IsA("Model"), "Unknown Fire Station Kit module: " .. tostring(moduleName))
	local clone = source:Clone()
	clone.Parent = parent
	clone:PivotTo(targetCFrame or CFrame.new())
	return clone
end

return Builder
