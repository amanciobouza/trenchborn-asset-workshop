-- Large City Power Utility specification.
-- Standalone building branch: no dependency on other Large City building branches.

local Specification = {
	AssetId = "LargeCity_PowerUtility_L3",
	DisplayName = "Large City Power Utility",
	LayoutId = "LC-44",
	City = "LargeCity",
	District = "MedicalTech",
	BuildingType = "Power Utility",
	Phase = 4,
	QualityGate = "B-Pending",
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
			Description = "Four large transformer units anchor a much broader high-voltage yard with cooling fins, ceramic bushings, capacitor banks and shunt reactors."
		},
		{
			Name = "CapacitorBanks",
			Description = "Three rear-yard capacitor banks use repeated metallic cans, ceramic insulators and rigid live busbars to make reactive-power equipment visible at gameplay distance.",
		},
		{
			Name = "ShuntReactors",
			Description = "Two tall cylindrical shunt reactors occupy the right-side electrical yard, adding another recognizable grid component beyond transformers.",
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
		"D7_RooftopAndReactivePower",
	},

	Phase1Status = {
		Status = "Approved",
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
		Status = "Approved",
		Revision = "LargeCityPowerUtility-VisualTarget-v1",
		NextPhase = 3,
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


	Phase2Status = {
		Status = "Approved",
		TargetRevision = "LargeCityPowerUtility-VisualTarget-v1",
		QualityGateA = "Approved",
		ReviewFocus = {
			"power utility is immediately recognizable from silhouette and equipment",
			"switchgear hall and taller converter hall have clear hierarchy",
			"four transformers remain large and visually dominant in the rear process court",
			"busbar gantries read as electrical infrastructure rather than generic pipes",
			"control spine provides a clean MedicalTech signature",
			"rooftop cooling and ventilation remains organized and below the 56-stud target",
			"cyan and amber accents are restrained and physically attached to plausible electrical equipment",
			"overall architecture feels premium tropical infrastructure rather than dirty heavy industry",
		},
	},


	QualityGateA = {
		Status = "Approved",
		ApprovedTarget = "LargeCityPowerUtility-VisualTarget-v1",
		Notes = "Approved Aureline Gridworks visual target with two-hall utility massing, glazed control spine, rear transformer court, elevated busbar gantries and restrained MedicalTech electrical accents.",
		NextPhase = 3,
	},

	TechnicalBreakdown = {
		CoordinateSystem = {
			Pivot = "ground center",
			Front = "local -Z",
			Rear = "local +Z",
			LayoutYaw = -4,
		},
		Overall = {
			TargetFootprint = Vector2.new(152, 106),
			TargetHeight = 56,
			GroundLevel = 0,
		},
		SwitchgearHall = {
			Footprint = Vector2.new(68, 72),
			Center = Vector3.new(-38, 16, -5),
			Height = 32,
			FacadeBayCountFront = 8,
			VerticalFinDepth = 2.2,
			Rule = "Use deep vertical switchgear fins and dark lower service panels; avoid generic warehouse rhythm.",
		},
		ConverterHall = {
			Footprint = Vector2.new(62, 70),
			Center = Vector3.new(34, 20, -3),
			Height = 40,
			FacadeBayCountFront = 7,
			CornerPylonCount = 2,
			Rule = "Taller hall must clearly step above the switchgear hall and carry the stronger power-conversion identity.",
		},
		ControlSpine = {
			Center = Vector3.new(-2, 27, -36),
			Size = Vector3.new(18, 20, 12),
			Glazing = true,
			EntryBelow = true,
			Rule = "The glazed control spine sits between the two halls and projects to the front facade plane so it remains a visible bridge/control volume rather than buried interior geometry."
		},
		TransformerCourt = {
			Face = "+Z",
			CourtCenter = Vector3.new(22, 0, 43),
			TransformerCount = 4,
			TransformerBodySize = Vector3.new(16, 18, 12),
			TransformerSpacing = 20,
			CoolingFinDepth = 2.0,
			BushingHeight = 8,
			MaintenanceClearance = 5,
			Rule = "Four large transformers remain fully visible, evenly spaced and unobstructed; no loading doors or unrelated clutter may sit behind them.",
		},
		ReactivePowerYard = {
			PadSize = Vector2.new(148, 36),
			CapacitorBankCount = 3,
			CapacitorCansPerBank = 8,
			ShuntReactorCount = 2,
			Rule = "Reactive-power equipment fills a deep, nearly full-width switchyard with deliberate maintenance corridors so the installation reads at campus scale rather than as a building with attached equipment."
		},
		BusbarGantries = {
			GantryCount = 3,
			PrimaryHeight = 34,
			SecondaryHeight = 29,
			TertiaryHeight = 24,
			Span = 136,
			BusbarDiameter = 1.5,
			SwitchBayCount = 6,
			InsulatorHeight = 3.4,
			Rule = "Busbars must read as rigid electrical conductors carried on insulators, not as plumbing or refinery pipework.",
		},
		RooftopSystems = {
			BaseY = 32,
			MaximumY = 56,
			CoolingModuleCount = 4,
			VentStackCount = 3,
			Rule = "Rooftop equipment is grouped into deliberate cooling and ventilation zones with clear maintenance spacing and no random clutter.",
		},
		Facade = {
			PanelDepth = 0.7,
			GlassStandOff = 0.45,
			FinStandOff = 0.8,
			ElectricalAccentStandOff = 0.25,
			Rule = "All fins, glazing and accent bars sit clearly outside the base wall surfaces to avoid clipping and Z-fighting.",
		},
		Entrance = {
			PortalWidth = 30,
			PortalHeight = 22,
			CanopyWidth = 34,
			CanopyDepth = 8,
			PlazaDepth = 12,
			Rule = "Main control entrance sits on local -Z, centered beneath the glazed spine and remains clearly separate from the rear transformer court.",
		},
		PartBudget = {
			TargetVisibleParts = 780,
			MaximumVisibleParts = 1000,
		},
	},

	Phase3Status = {
		Status = "TechnicalBreakdownApproved",
		QualityGateA = "Approved",
		NextPhase = 4,
	},


	Phase4Status = {
		Status = "GoldenMasterReview",
		GeometryRevision = "LargeCityPowerUtility-v3-BroadSwitchyard",
		QualityGateB = "Pending",
		ReviewFocus = {
			"power utility is immediately recognizable from silhouette and equipment",
			"switchgear hall and converter hall have a clear stepped hierarchy",
			"control spine visibly projects at the public facade instead of being buried inside the halls",
			"four large transformers remain unobstructed in the true rear +Z court",
			"three capacitor banks and two shunt reactors occupy dedicated zones inside a deep full-width switchyard",
			"transformer cooling fins and ceramic bushings read clearly at gameplay distance",
			"busbar gantries read as rigid electrical conductors carried by insulators, not as pipes",
			"three full-width portal rows establish a large switchyard silhouette",
			"six large disconnector bays add visible switching infrastructure beneath the incoming portal row",
			"thin cyan live indicators stay physically attached to busbars and reactive-power equipment",
			"rooftop cooling modules and three vent stacks are grounded on visible plinths and stay below 56 studs",
			"cyan and amber accents remain restrained and physically attached to plausible electrical elements",
			"no loading stations or unrelated service clutter block the transformer court",
			"no facade, gantry, transformer or rooftop Z-fighting",
			"visible part count stays below 1000",
		},
	},

	Phase3Acceptance = {
		"All primary masses use deterministic dimensions tied to LC-44.",
		"Switchgear hall, converter hall and control spine remain visually distinct but form one coherent utility campus.",
		"Four transformers remain large, unobstructed and evenly spaced in the true rear +Z process court.",
		"Busbar gantries read as electrical infrastructure through rigid conductors and insulators.",
		"Rooftop cooling and ventilation stay below the 56-stud plot target.",
		"Public control entrance remains clearly separated from rear high-voltage equipment.",
		"Seven destruction groups map to coherent architectural and electrical systems.",
		"Golden Master target remains below 1000 visible parts.",
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
