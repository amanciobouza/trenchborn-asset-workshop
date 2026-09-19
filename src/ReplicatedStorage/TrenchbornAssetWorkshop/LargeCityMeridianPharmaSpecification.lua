-- Phase 1 concept/specification for LC-43 Meridian Pharma.
-- Standalone building branch: no dependency on other Large City building branches.

local Specification = {
	AssetId = "LargeCity_MeridianPharma_L3",
	DisplayName = "Meridian Pharma",
	LayoutId = "LC-43",
	City = "LargeCity",
	District = "MedicalTech",
	BuildingType = "Pharma Plant",
	Phase = 4,
	QualityGate = "B-Pending",
	Branch = "largecity-meridian-pharma-l3",

	StandaloneImport = {
		Required = true,
		Rule = "This branch must remain independently importable into another project without depending on Hospital, Power Utility, Stadium, Arena, or any other building branch.",
	},

	LayoutReference = {
		Position = Vector3.new(650, 20, 40),
		Footprint = Vector2.new(132, 92),
		Height = 48,
		Yaw = 4,
	},

	Style = "Singapore med-tech campus x high-end pharmaceutical production",
	Role = "Large MedicalTech production anchor beside Central Hospital, clearly industrial but clean, premium and research-driven",

	Concept = {
		Name = "Meridian BioWorks",
		Read = "A broad pharmaceutical production complex with a glazed research headhouse, cleanroom production halls, visible utility bridges, rooftop process modules and a distinctive bioreactor/service court.",
		DoNotReadAs = {
			"generic warehouse",
			"oil refinery",
			"hospital annex",
			"office campus",
			"cyberpunk factory",
			"heavy dirty industry",
		},
	},

	Massing = {
		ResearchHeadhouse = {
			Footprint = Vector2.new(42, 72),
			Height = 32,
			Offset = Vector3.new(-42, 0, -4),
			Rule = "A glazed research/admin headhouse gives Meridian a high-tech medical identity and establishes the public-facing entrance.",
		},
		CleanroomHall = {
			Footprint = Vector2.new(78, 74),
			Height = 28,
			Offset = Vector3.new(22, 0, 2),
			Rule = "Main clean production hall is broad and horizontal with controlled facade rhythm, service panels and clear cleanroom identity.",
		},
		ProcessRoof = {
			FromY = 28,
			ToY = 48,
			Rule = "Rooftop process modules, ducts and screened equipment create a technical silhouette without becoming refinery clutter.",
		},
	},

	SignatureFeatures = {
		{
			Name = "SterileGlassAtrium",
			Face = "-Z",
			Description = "Tall recessed glazed atrium and Meridian wordmark clearly identify the main visitor/research entrance.",
		},
		{
			Name = "CleanroomWindowBands",
			Description = "Long horizontal blue-green observation bands punctuate pale sterile wall panels, reading as controlled production rather than offices.",
		},
		{
			Name = "ProcessBridge",
			Description = "An elevated enclosed bridge links research headhouse and production hall, with visible teal lighting and service conduits.",
		},
		{
			Name = "BioreactorCourt",
			Face = "+Z",
			Description = "Rear process court with four large cylindrical vessel housings and service gantry; no loading stations compete with the process zone.",
		},
		{
			Name = "RooftopProcessModules",
			Description = "Three screened rooftop technical boxes plus clean duct runs provide a strong pharma silhouette at Kaiju distance.",
		},
		{
			Name = "ChemicalSafetyBand",
			Description = "Muted magenta/violet safety accent marks selected process zones, linking visually to Chemical energy without turning the plant neon.",
		},
	},

	Facade = {
		Primary = "Sterile pale concrete / composite panels",
		Secondary = "Blue-green cleanroom glazing",
		Process = "Dark metallic service panels and silver ducts",
		Accent = "Muted teal plus restrained chemical-magenta safety marks",
		Rule = "Public/research face is polished and glazed; production face is modular and technical. Avoid warehouse monotony and refinery clutter.",
	},

	Roof = {
		Rule = "Roofline is layered with screened process modules, ducts and one small exhaust stack cluster. Equipment must read organized and engineered, not random.",
	},

	Landscape = {
		Phase = 5,
		Includes = {
			"formal entry trees/palms",
			"sterile plaza planters",
			"bioswale near process court",
			"loading bollards",
			"chemical-zone safety striping",
			"service fencing/screening",
		},
	},

	ProposedGameplayMetadata = {
		TargetMaxHealth = 48000,
		EnergyType = "Chemical",
		InstallerTag = "KaijuHouse",
		ExternalCollapseIntegration = true,
	},

	PlannedDestructionGroups = {
		"D1_ResearchEntrance",
		"D2_ResearchHeadhouse",
		"D3_CleanroomHall",
		"D4_ProcessBridge",
		"D5_RooftopProcessModules",
		"D6_BioreactorCourt",
		"D7_ProcessServiceInfrastructure",
	},

	VisualTarget = {
		Status = "Approved",
		Revision = "LargeCityMeridianPharma-VisualTarget-v1",
		Brief = {
			"premium pharmaceutical production campus in MedicalTech district",
			"132x92 footprint and 48-stud height",
			"glazed research headhouse beside broad cleanroom production hall",
			"cleanroom observation bands and sterile panel facade",
			"elevated enclosed process bridge between major masses",
			"rear bioreactor/process court with cylindrical vessel housings",
			"organized rooftop process modules and ducts",
			"teal medical-tech accents with restrained chemical-magenta safety details",
			"clear main visitor entrance and dedicated rear process court",
			"daylight architectural concept board with front, three-quarter, side, rear and process-detail cues",
			"not refinery, not warehouse, not hospital annex",
		},
	},



	QualityGateA = {
		Status = "Approved",
		ApprovedTarget = "LargeCityMeridianPharma-VisualTarget-v1",
		Notes = "Approved Meridian BioWorks concept with glazed research headhouse, cleanroom production hall, enclosed process bridge, organized rooftop modules and rear bioreactor court.",
		NextPhase = 3,
	},

	TechnicalBreakdown = {
		CoordinateSystem = {
			Pivot = "ground center",
			Front = "local -Z",
			Rear = "local +Z",
			LayoutYaw = 4,
		},
		Overall = {
			TargetFootprint = Vector2.new(132, 92),
			TargetHeight = 48,
			GroundLevel = 0,
		},
		ResearchHeadhouse = {
			Footprint = Vector2.new(42, 72),
			Center = Vector3.new(-43, 16, -4),
			Height = 32,
			CornerRadiusApprox = 3.5,
			FrontAtriumWidth = 28,
			FrontAtriumHeight = 23,
			FacadeBayCount = 6,
		},
		CleanroomHall = {
			Footprint = Vector2.new(76, 74),
			Center = Vector3.new(20, 14, 2),
			Height = 28,
			ObservationBandHeight = 4.5,
			PanelBayCountLongFace = 9,
			PanelBayCountShortFace = 6,
			Rule = "Use long clean horizontal observation bands separated by sterile wall panels; avoid office-style full-height curtain wall.",
		},
		ProcessBridge = {
			Center = Vector3.new(-20, 24, -19),
			Size = Vector3.new(8, 7, 8),
			Glazing = true,
			TealUndersideAccent = true,
			Rule = "A real 4-stud open seam separates headhouse and production hall; the short bridge spans that seam and only overlaps each facade slightly."
		},
		BioreactorCourt = {
			Face = "+Z",
			CourtCenter = Vector3.new(20.5, 0, 43),
			VesselCount = 4,
			VesselDiameter = 8,
			VesselHeights = {24, 28, 26, 22},
			GantryHeight = 21,
			ServiceClearance = 4,
			Rule = "Cylindrical vessel housings remain grouped and organized in the rear process court; no loading doors are modeled behind them, and they must not read as an oil-refinery tank farm.",
		},
		RooftopProcess = {
			BaseY = 28,
			MaximumY = 48,
			ModuleCount = 3,
			ModuleFootprints = {
				Vector2.new(20, 14),
				Vector2.new(18, 12),
				Vector2.new(16, 11),
			},
			DuctDiameter = 1.4,
			ExhaustStackCount = 3,
			ScreenHeight = 6,
			Rule = "Equipment groups are deliberately spaced and connected by clean duct runs; no random rooftop clutter.",
		},
		Facade = {
		PanelDepth = 0.7,
		GlassDepth = 0.65,
		FrameDepth = 0.85,
		ObservationBandStandOff = 0.25,
		SafetyAccentDepth = 0.28,
		Rule = "All glazing, safety bands and process screens sit visibly outside their base wall surfaces to avoid clipping or Z-fighting.",
		},
		Entrance = {
		AtriumWidth = 28,
		AtriumHeight = 23,
		RecessDepth = 4.0,
		CanopyWidth = 34,
		CanopyDepth = 9,
		CanopyY = 12.5,
		PlazaDepth = 12,
		Rule = "Research entrance must read as a high-tech visitor/research entry, not a loading bay.",
		},
		RearService = {
			LoadingDoorCount = 0,
			LoadingCanopyWidth = 0,
			ServiceApronDepth = 0,
			SafetyBollards = false,
			Rule = "No loading stations are modeled on Meridian Pharma. The rear +Z side is dedicated to the bioreactor/process court.",
		},
		PartBudget = {
			TargetVisibleParts = 620,
			MaximumVisibleParts = 820,
		},
	},

	Phase2Status = {
		Status = "Approved",
		TargetRevision = "LargeCityMeridianPharma-VisualTarget-v1",
		QualityGateA = "Approved",
		ReviewFocus = {
			"immediate pharma / biotech production read",
			"clear research headhouse versus cleanroom hall hierarchy",
			"sterile glazed visitor/research entrance",
			"elevated enclosed process bridge",
			"rear bioreactor/service court",
			"organized rooftop process modules and ducts",
			"restrained chemical-magenta safety accents",
			"clear distinction from hospital, warehouse and refinery architecture",
		},
	},


	Phase4Status = {
		Status = "GoldenMasterReview",
		GeometryRevision = "LargeCityMeridianPharma-v5-VisibleResearchSeamBridge",
		QualityGateB = "Pending",
		ReviewFocus = {
			"immediate pharmaceutical / biotech production readability",
			"clear research headhouse versus cleanroom hall hierarchy",
			"visitor atrium and canopy read clearly from the front",
			"cleanroom observation bands remain horizontal and production-like",
			"process bridge is visibly external and elevated",
			"research spine sits visibly in the open seam instead of intersecting either building mass",
			"rear bioreactor court is organized and not refinery-like",
			"no loading stations compete visually or physically with the four tanks",
			"rooftop process modules and ducts form a deliberate technical silhouette",
			"rooftop process modules sit on visible equipment plinths rather than intersecting the hall mass",
			"three exhaust stacks rise from one shared rooftop utility plinth and visibly connect to the process duct network",
			"chemical-magenta accents remain restrained",
			"rear +Z process court remains clearly readable with no loading-bay conflict",
			"no facade, roof or process-equipment Z-fighting",
		},
	},

	Phase3Acceptance = {
		"Research headhouse, cleanroom hall, process bridge, bioreactor court and rooftop process modules use deterministic dimensions tied to LC-43.",
		"Public research frontage and production/service frontage remain visually distinct but clearly belong to one facility.",
		"Cleanroom observation bands read as controlled production rather than office curtain wall.",
		"Process bridge is visibly elevated and external to both primary masses.",
		"Bioreactor court uses a small organized vessel group rather than refinery-like clutter.",
		"Rooftop modules and ducts form a deliberate technical silhouette below the 48-stud target height.",
		"Rear process court remains clearly separated from the front visitor entrance.",
		"Seven destruction groups map to coherent architectural/process masses.",
		"Golden Master target remains below 820 visible parts.",
	},

	Phase1Acceptance = {
		"Building reads immediately as pharmaceutical / biotech production rather than warehouse or hospital.",
		"Research headhouse and production hall are visually distinct but clearly one complex.",
		"Process bridge and bioreactor court create memorable MedicalTech identity at Kaiju gameplay distance.",
		"Rooftop equipment is organized and readable without excessive industrial clutter.",
		"Main visitor entrance and rear process/service functions are clearly separated.",
		"Chemical energy identity is present through restrained safety accents rather than dominant neon.",
		"Footprint and height remain compatible with LC-43.",
	},
}

return Specification
