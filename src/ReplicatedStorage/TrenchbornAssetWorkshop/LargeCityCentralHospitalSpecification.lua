local Specification = {
	AssetId = "LargeCity_CentralHospital_L3",
	DisplayName = "Central Hospital",
	City = "LargeCity",
	Phase = 3,
	QualityGate = "A-Approved",
	Style = "Singapore x Miami tropical metropolitan healthcare landmark",

	AssetBrief = {
		Purpose = "Major Large City civic landmark and high-value destruction target.",
		Role = "Central hospital complex for the tropical coastal metropolis; clearly distinct from hotel, office and mall silhouettes.",
		Scale = "Large L3 civic complex with one dominant clinical tower, lower diagnostic/emergency wings and rooftop medical infrastructure.",
		GameplayRead = "Readable from kaiju distance: hospital cross/medical identity, emergency entrance, helipad and stepped tower massing.",
		NoInterior = true,
	},

	VisualTarget = {
		Approved = true,
		Revision = "CentralHospital-VisualTarget-v1",
		ApprovedRead = "Modern tropical hospital campus with broad clinical tower, strong emergency canopy, asymmetric diagnostic wing, rooftop helipad and visible medical identity.",
		Front = "Main entrance centered under glazed diagnostic podium; emergency wing offset left; diagnostics/service volume offset right.",
		Roof = "Large readable helipad plus mechanical plant, parapets and service equipment.",
		Rear = "Service/loading volumes and technical access; intentionally more functional than the public front.",
		Landscape = "Palm-lined civic forecourt and planted edges; functional, clean and tropical rather than resort-like.",
	},

	Architecture = {
		MainTower = "12-16 floor clinical tower, broad and slightly stepped rather than slender office skyscraper.",
		Podium = "Wide 3-4 floor diagnostic and treatment podium with strong horizontal glazing bands.",
		EmergencyWing = "Clearly visible lower emergency wing with ambulance canopy and dedicated road-facing entrance.",
		SecondaryWing = "Lower inpatient/diagnostic wing offset from the tower to create an asymmetrical campus silhouette.",
		Helipad = "Rooftop helipad integrated into a lower roof volume; must read clearly from above and street level.",
		RoofPlant = "Mechanical plant, ventilation stacks and service volumes appropriate for a hospital.",
		Landscape = "Tropical planting, shaded pedestrian forecourt and palms; cleaner and more civic than the resort.",
	},

	VisualLanguage = {
		PrimaryMaterials = {"light concrete", "white limestone", "blue-green medical glass", "brushed metal"},
		Accent = "restrained teal/cyan healthcare accent",
		Avoid = {"luxury resort vibe", "generic office tower", "futuristic mega-city look", "box-only silhouette"},
		IdentityAnchors = {
			"large emergency canopy",
			"rooftop helipad",
			"medical cross / hospital signage",
			"layered clinical tower",
			"horizontal patient-room window rhythm",
		},
	},

	ProposedDimensions = {
		Footprint = Vector3.new(105, 0, 82),
		MainTower = Vector3.new(44, 66, 34),
		Podium = Vector3.new(88, 15, 50),
		EmergencyWing = Vector3.new(42, 14, 30),
		SecondaryWing = Vector3.new(48, 24, 32),
	},

	TechnicalBreakdown = {
		CoordinateSystem = {
			Pivot = "Ground center of complete hospital campus",
			Front = "Local -Z faces public boulevard / main entrance",
			Rear = "Local +Z faces service/loading side",
			GroundY = 0,
		},

		Massing = {
			MainTowerLower = {
				Size = Vector3.new(46, 34, 34),
				Center = Vector3.new(0, 27, 7),
				Purpose = "Lower inpatient tower and main vertical mass",
			},
			MainTowerUpper = {
				Size = Vector3.new(40, 30, 31),
				Center = Vector3.new(2, 59, 8.5),
				Purpose = "Stepped upper patient tower",
			},
			DiagnosticPodium = {
				Size = Vector3.new(78, 14, 42),
				Center = Vector3.new(5, 8, 8),
				Purpose = "Main entrance, diagnostics and treatment base",
			},
			EmergencyWing = {
				Size = Vector3.new(38, 13, 29),
				Center = Vector3.new(-43, 7.5, -4),
				Purpose = "Emergency department and ambulance arrival",
			},
			SecondaryWing = {
				Size = Vector3.new(42, 23, 31),
				Center = Vector3.new(47, 12.5, 9),
				Purpose = "Diagnostics / outpatient clinical wing",
			},
		},

		FacadeModules = {
			TowerFloorHeight = 4.0,
			TowerWindowBandHeight = 2.1,
			TowerWindowBandDepth = 0.35,
			TowerVerticalMullionWidth = 0.3,
			PodiumGlassHeight = 5.5,
			EmergencyCanopyClearHeight = 5.2,
			FacadeStandOff = 0.25,
			Rule = "All glass and facade overlays must stand clear of structural faces to avoid Z-fighting.",
		},

		EmergencyArrival = {
			CanopySize = Vector3.new(34, 1.0, 16),
			CanopyCenter = Vector3.new(-43, 7.8, -22),
			DriveThroughWidth = 26,
			Columns = 4,
			AmbulanceBays = 2,
			VisualAnchor = "EMERGENCY sign above canopy plus medical cross on wing",
		},

		MainEntrance = {
			CanopySize = Vector3.new(28, 0.8, 9),
			CanopyCenter = Vector3.new(5, 7.0, -18),
			DoorSpan = 18,
			ForecourtDepth = 13,
			VisualAnchor = "Tall glazed lobby slot and directional hospital signage",
		},

		Helipad = {
			DeckSize = Vector3.new(31, 1.0, 31),
			DeckCenter = Vector3.new(0, 75, 9),
			PadDiameter = 24,
			ParapetHeight = 1.2,
			AccessCore = Vector3.new(8, 5, 7),
			Marking = "White H in circle on strong red landing field during Dressing phase",
		},

		RoofPlant = {
			HVACUnits = 5,
			VentStacks = 4,
			ServiceCoreCount = 2,
			Rule = "Keep plant clustered away from helipad flight area and clearly subordinate to tower silhouette.",
		},

		LandscapeReferences = {
			PalmCount = 8,
			PlanterZones = 5,
			PublicForecourt = Vector3.new(62, 0, 18),
			EmergencyBuffer = Vector3.new(42, 0, 11),
			Phase = 5,
		},

		PartBudget = {
			TargetVisibleParts = 560,
			MaximumVisibleParts = 750,
			GoldenMasterOnly = "Structural massing, physical window rhythms, canopy geometry, helipad deck, roof plant massing and deterministic pivot.",
			DressingOnly = "Signs, cross symbols, helipad paint, palms, benches, bollards, small fixtures, window illumination and surface accents.",
		},
	},

	PlannedDestructionGroups = {
		"D1_EmergencyCanopy",
		"D2_DiagnosticPodium",
		"D3_EmergencyWing",
		"D4_SecondaryWing",
		"D5_MainTowerLower",
		"D6_MainTowerUpper",
		"D7_HelipadRoofPlant",
	},

	GameplayMetadata = {
		TargetMaxHealth = 64000,
		EnergyType = "Chemical",
		InstallerTag = "KaijuHouse",
		ExternalCollapseIntegration = true,
	},

	QualityGateA = {
		Status = "Approved",
		ApprovedTarget = "CentralHospital-VisualTarget-v1",
		Acceptance = {
			"Hospital identity is immediate from gameplay distance.",
			"Tower, podium, emergency wing and diagnostic wing create an asymmetric civic campus silhouette.",
			"Helipad and emergency canopy are mandatory and visually dominant anchors.",
			"Tropical Large City identity is present without reading as a resort.",
			"Design can be built entirely in Roblox Studio without modeled interior geometry.",
		},
	},

	Phase3Acceptance = {
		"All major visual-target masses have deterministic dimensions and centers.",
		"Facade modules use real geometry and explicit anti-Z-fighting stand-off.",
		"Helipad, emergency arrival and main entrance have buildable dimensions.",
		"Seven destruction groups map cleanly to physical building masses.",
		"Golden Master part budget remains below 750 visible parts.",
	},
}

return Specification
