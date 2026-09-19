-- Phase 1 concept/specification for LC-43 Meridian Pharma.
-- Standalone building branch: no dependency on other Large City building branches.

local Specification = {
	AssetId = "LargeCity_MeridianPharma_L3",
	DisplayName = "Meridian Pharma",
	LayoutId = "LC-43",
	City = "LargeCity",
	District = "MedicalTech",
	BuildingType = "Pharma Plant",
	Phase = 2,
	QualityGate = "A-Pending",
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
			Offset = Vector3.new(-38, 0, -4),
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
			Description = "Rear-side process court with several tall cylindrical vessel housings, service gantry and guarded loading area.",
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
		"D7_ServiceAndLoading",
	},

	VisualTarget = {
		Status = "InReview",
		Revision = "LargeCityMeridianPharma-VisualTarget-v1",
		Brief = {
			"premium pharmaceutical production campus in MedicalTech district",
			"132x92 footprint and 48-stud height",
			"glazed research headhouse beside broad cleanroom production hall",
			"cleanroom observation bands and sterile panel facade",
			"elevated enclosed process bridge between major masses",
			"rear bioreactor/service court with cylindrical vessel housings",
			"organized rooftop process modules and ducts",
			"teal medical-tech accents with restrained chemical-magenta safety details",
			"clear main visitor entrance and separate service/loading side",
			"daylight architectural concept board with front, three-quarter, side, rear and process-detail cues",
			"not refinery, not warehouse, not hospital annex",
		},
	},


	Phase2Status = {
		Status = "VisualTargetReview",
		TargetRevision = "LargeCityMeridianPharma-VisualTarget-v1",
		QualityGateA = "Pending",
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
