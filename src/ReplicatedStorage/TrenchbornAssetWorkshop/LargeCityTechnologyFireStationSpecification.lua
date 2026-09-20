-- Technology Fire Station specification.
-- Standalone building branch: no dependency on other Large City building branches.

local Specification = {
	AssetId = "LargeCity_TechnologyFireStation_L3",
	DisplayName = "Technology Fire Station",
	LayoutId = "LC-45",
	City = "LargeCity",
	District = "MedicalTech",
	BuildingType = "Fire Station HQ",
	Phase = 1,
	QualityGate = "A-Pending",
	Branch = "largecity-technology-fire-station-l3",

	StandaloneImport = {
		Required = true,
		Rule = "This branch must remain independently importable into another project without depending on Hospital, Meridian Pharma, Power Utility, Research Offices, or any other building branch.",
	},

	LayoutReference = {
		Position = Vector3.new(475, 20, 350),
		Footprint = Vector2.new(88, 68),
		Height = 34,
		Yaw = 0,
	},

	Style = "Singapore emergency-response architecture x premium tropical civic technology",
	Role = "MedicalTech district emergency-response headquarters: compact, highly readable, modern and operational rather than monumental",

	Concept = {
		Name = "Emberline Response HQ",
		Read = "A modern urban fire-and-rescue headquarters with a wide apparatus hall, glazed command wing, compact training tower, visible hose/decon infrastructure and a strong emergency-response apron.",
		DoNotReadAs = {
			"generic warehouse",
			"police station",
			"hospital annex",
			"industrial factory",
			"airport hangar",
			"cyberpunk station",
		},
	},

	Massing = {
		ApparatusHall = {
			Footprint = Vector2.new(56, 42),
			Height = 20,
			Offset = Vector3.new(-8, 0, -6),
			Rule = "The dominant front mass is a wide vehicle hall with three large apparatus bays and a clearly readable response apron.",
		},
		CommandWing = {
			Footprint = Vector2.new(30, 34),
			Height = 26,
			Offset = Vector3.new(28, 0, -8),
			Rule = "A taller glazed command/admin wing anchors one side of the apparatus hall and provides the MedicalTech identity.",
		},
		TrainingTower = {
			Footprint = Vector2.new(16, 18),
			Height = 34,
			Offset = Vector3.new(27, 0, 20),
			Rule = "A compact training/hose tower creates the recognizable vertical fire-station silhouette without becoming a skyscraper.",
		},
		ServiceYard = {
			Face = "+Z",
			Rule = "Rear service/decon yard remains visually distinct from the public apparatus apron and stays clear enough for player traversal.",
		},
	},

	SignatureFeatures = {
		{
			Name = "ThreeApparatusBays",
			Face = "-Z",
			Description = "Three oversized red-trimmed vehicle portals create the immediate fire-station read and must stay fully unobstructed.",
		},
		{
			Name = "ResponseApron",
			Face = "-Z",
			Description = "A broad clean apron projects in front of the bays, reinforcing the station's operational emergency-response function.",
		},
		{
			Name = "CommandGlass",
			Description = "Blue-green command glazing and a restrained red emergency stripe distinguish the command wing from the apparatus hall.",
		},
		{
			Name = "TrainingTower",
			Description = "A 34-stud training/hose tower with external drill balconies and rescue anchor points provides vertical identity.",
		},
		{
			Name = "DeconCanopy",
			Face = "+Z",
			Description = "A compact rear decontamination/service canopy with hose racks and equipment lockers adds believable rescue infrastructure.",
		},
		{
			Name = "EmergencyBeacon",
			Description = "A small rooftop mast and red beacon identify the facility at gameplay distance without turning the building into neon.",
		},
	},

	Facade = {
		Primary = "Pale concrete / composite civic panels",
		Secondary = "Dark graphite vehicle-bay frames",
		Glass = "Blue-green command glazing",
		Accent = "Fire-service red with restrained amber safety markers",
		Rule = "The front must read operational and civic: large clean bay portals, command glazing and crisp red identity. Avoid excessive neon or industrial clutter.",
	},

	Landscape = {
		Phase = 5,
		Includes = {
			"small formal palms / trees at the public command entrance",
			"low planters away from apparatus routes",
			"response-lane markings",
			"rear decon/service bollards",
			"hose-training markings",
		},
	},

	ProposedGameplayMetadata = {
		TargetMaxHealth = 32000,
		EnergyType = "Thermal",
		InstallerTag = "KaijuHouse",
		ExternalCollapseIntegration = true,
	},

	PlannedDestructionGroups = {
		"D1_ResponseApronAndBayDoors",
		"D2_ApparatusHall",
		"D3_CommandWing",
		"D4_TrainingTower",
		"D5_RearDeconAndService",
		"D6_RooftopEmergencySystems",
		"D7_ExternalDrillStructures",
	},

	Phase1Status = {
		Status = "ConceptReview",
		QualityGateA = "Pending",
		ReviewFocus = {
			"immediate fire-station readability from the three apparatus bays",
			"command wing and apparatus hall are visually distinct but coherent",
			"training tower gives a strong fire-rescue silhouette without dominating the district",
			"front response apron remains open and unobstructed",
			"rear decon/service functions stay separate from the public front",
			"red emergency identity is strong but not neon-heavy",
			"building remains clearly different from hospital and police/civic architecture",
			"footprint and height remain compatible with LC-45",
		},
	},

	VisualTarget = {
		Status = "Pending",
		NextPhase = 2,
		Brief = {
			"premium tropical urban fire-and-rescue headquarters in the MedicalTech district",
			"88x68 footprint and 34-stud height",
			"three large front apparatus bays with red structural frames",
			"broad response apron",
			"glazed command/admin wing",
			"compact 34-stud training and hose tower",
			"rear decon/service canopy and hose-training equipment",
			"organized rooftop emergency systems and small beacon mast",
			"pale civic concrete, graphite metal, blue-green glass and controlled fire-service red",
			"formal landscaping only at public command entrance, never in vehicle routes",
			"daylight architectural concept board with front, three-quarter, rear, side and training-tower detail views",
			"not warehouse, not police station, not hospital annex, not industrial factory",
		},
	},

	Phase1Acceptance = {
		"Building reads immediately as a large-city fire-and-rescue headquarters.",
		"Three apparatus bays dominate the front facade and remain fully unobstructed.",
		"Command wing, apparatus hall and training tower create three clear functional masses.",
		"Training tower is recognizable but remains within the 34-stud plot target.",
		"Rear service/decon functions do not interfere with the response apron.",
		"Thermal identity is expressed through fire-service context and restrained red/amber accents rather than decorative flames.",
		"Seven destruction groups map to coherent architectural and emergency-response systems.",
		"Footprint and height remain compatible with LC-45.",
	},
}

return Specification
