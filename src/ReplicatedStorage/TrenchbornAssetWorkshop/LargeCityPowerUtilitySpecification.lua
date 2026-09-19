-- Large City Power Utility specification.
-- Standalone building branch: no dependency on other Large City building branches.

local Specification = {
	AssetId = "LargeCity_PowerUtility_L3",
	DisplayName = "Large City Power Utility",
	LayoutId = "LC-44",
	City = "LargeCity",
	District = "MedicalTech",
	BuildingType = "Power Utility",
	Phase = 1,
	QualityGate = "A-Pending",
	Branch = "largecity-power-utility-l3",

	StandaloneImport = {
		Required = true,
		Rule = "This branch must remain independently importable into another project without depending on Hospital, Meridian Pharma, Fire Station, Volt Spire, or any other building branch.",
	},

	LayoutReference = {
		Position = Vector3.new(665, 20, 265),
		Footprint = Vector2.new(152, 106),
		Height = 56,
		Yaw = -4,
	},

	Style = "Singapore smart-grid infrastructure x premium tropical utility campus",
	Role = "Major electrical infrastructure anchor for the MedicalTech district, visibly powerful and technical without reading as dirty heavy industry",

	Concept = {
		Name = "Aureline Gridworks",
		Read = "A broad urban power utility with enclosed switchgear and conversion halls, an exposed transformer court, elevated busbar gantries and a precise high-tech control spine.",
		DoNotReadAs = {
			"generic warehouse",
			"oil refinery",
			"coal or gas power station",
			"cyberpunk neon factory",
			"office campus",
			"open rural substation",
		},
	},

	Massing = {
		SwitchgearHall = {
			Footprint = Vector2.new(72, 70),
			Height = 32,
			Offset = Vector3.new(-35, 0, -4),
			Rule = "Broad enclosed hall with strong modular electrical bays, vent panels and a public-facing control entrance.",
		},
		ConverterHall = {
			Footprint = Vector2.new(58, 68),
			Height = 40,
			Offset = Vector3.new(34, 0, -2),
			Rule = "Taller conversion hall gives the utility a stepped skyline and carries the strongest technical facade language.",
		},
		GridControlSpine = {
			FromY = 18,
			ToY = 48,
			Rule = "A narrow elevated glazed control spine bridges the two enclosed halls and becomes the clean high-tech identity feature.",
		},
		TransformerCourt = {
			Face = "+Z",
			Rule = "Rear court contains four large transformer blocks with visible bushings, cooling fins and safe maintenance clearance. It must read organized rather than cluttered.",
		},
		Roof = {
			FromY = 32,
			ToY = 56,
			Rule = "Vent stacks, screened cooling modules and short electrical gantries create a strong utility silhouette while staying below the 56-stud plot target.",
		},
	},

	SignatureFeatures = {
		{
			Name = "PowerPortal",
			Face = "-Z",
			Description = "Tall recessed control entrance with dark metal frame, blue-green glazing and restrained cyan electrical identity.",
		},
		{
			Name = "BusbarGantries",
			Description = "Two elevated structural gantries visibly carry large insulated busbars from the conversion hall toward the transformer court.",
		},
		{
			Name = "TransformerCourt",
			Face = "+Z",
			Description = "Four large transformer units with cooling fins and vertical ceramic bushings provide an unmistakable power-utility read at Kaiju distance.",
		},
		{
			Name = "GridControlSpine",
			Description = "A narrow glazed technical bridge/control spine links the enclosed halls above ground level and gives the facility a premium MedicalTech identity.",
		},
		{
			Name = "ElectricalSafetyBand",
			Description = "Restrained cyan and amber safety accents identify live electrical infrastructure without turning the building into neon sci-fi.",
		},
	},

	Facade = {
		Primary = "Pale concrete / composite utility panels",
		Secondary = "Dark graphite switchgear panels",
		Glass = "Blue-green control glazing",
		Process = "Silver busbars, transformer fins and ceramic insulators",
		Accent = "Restrained cyan electrical lines plus limited amber safety marks",
		Rule = "Public/control face is polished and legible; process faces are modular and technical. Avoid repetitive warehouse walls.",
	},

	Landscape = {
		Phase = 5,
		Includes = {
			"formal entry palms and low planters",
			"sterile control-entry plaza",
			"transformer safety curb and bollards",
			"low service fencing around live equipment",
			"small bioswale at outer service edge",
		},
	},

	ProposedGameplayMetadata = {
		TargetMaxHealth = 64000,
		EnergyType = "Electric",
		InstallerTag = "KaijuHouse",
		ExternalCollapseIntegration = true,
	},

	PlannedDestructionGroups = {
		"D1_ControlEntrance",
		"D2_SwitchgearHall",
		"D3_ConverterHall",
		"D4_GridControlSpine",
		"D5_BusbarGantries",
		"D6_TransformerCourt",
		"D7_RooftopAndService",
	},

	Phase1Status = {
		Status = "ConceptReview",
		QualityGateA = "Pending",
		ReviewFocus = {
			"immediate power-utility readability at Kaiju gameplay distance",
			"clear hierarchy between switchgear hall, taller converter hall and transformer court",
			"four large transformers are iconic rather than cluttered",
			"elevated busbar gantries visibly connect enclosed plant to the rear court",
			"control entrance and glazed spine keep the utility compatible with the premium MedicalTech district",
			"cyan electrical identity remains restrained",
			"building stays visibly different from Meridian Pharma and the nearby Volt Spire",
			"footprint and height remain compatible with LC-44",
		},
	},

	VisualTarget = {
		Status = "Pending",
		NextPhase = 2,
		Brief = {
			"premium tropical urban power utility in the MedicalTech district",
			"152x106 footprint and 56-stud height",
			"broad switchgear hall beside taller converter hall",
			"glazed control spine bridging the major enclosed masses",
			"rear court with four large transformers",
			"visible elevated busbar gantries and insulators",
			"organized rooftop cooling and ventilation",
			"pale concrete, graphite metal, blue-green glass and silver electrical hardware",
			"restrained cyan electric identity with small amber safety accents",
			"formal tropical landscaping at the public entrance only",
			"daylight architectural concept board with front, three-quarter, rear, side and transformer-detail views",
			"not refinery, not warehouse, not dirty heavy industry, not cyberpunk",
		},
	},

	Phase1Acceptance = {
		"Building reads immediately as a major electrical utility rather than a warehouse or generic industrial hall.",
		"Switchgear and converter halls are visually distinct but belong to one coherent facility.",
		"Transformer court and busbar gantries create the dominant electrical identity.",
		"Control spine provides a clean MedicalTech signature without hiding the industrial function.",
		"Electrical accents remain restrained and physically attached to plausible equipment.",
		"Four large transformers retain clear maintenance space and are not blocked by loading stations.",
		"Footprint, height and yaw remain compatible with LC-44.",
		"Seven destruction groups map to coherent architectural and electrical systems.",
	},
}

return Specification
