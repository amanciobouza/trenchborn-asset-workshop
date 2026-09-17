local Specification = {
	AssetId = "LargeCity_CentralHospital_L3",
	DisplayName = "Central Hospital",
	City = "LargeCity",
	Phase = 1,
	QualityGate = "A-Pending",
	Style = "Singapore x Miami tropical metropolitan healthcare landmark",

	AssetBrief = {
		Purpose = "Major Large City civic landmark and high-value destruction target.",
		Role = "Central hospital complex for the tropical coastal metropolis; clearly distinct from hotel, office and mall silhouettes.",
		Scale = "Large L3 civic complex with one dominant clinical tower, lower diagnostic/emergency wings and rooftop medical infrastructure.",
		GameplayRead = "Readable from kaiju distance: hospital cross/medical identity, emergency entrance, helipad and stepped tower massing.",
		NoInterior = true,
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

	Phase1Acceptance = {
		"Must read immediately as a hospital from distance.",
		"Must preserve the tropical Large City identity established by the waterfront resort.",
		"Must have a civic/medical silhouette, not another hotel or office tower.",
		"Emergency entrance and helipad are mandatory visual anchors.",
		"Geometry should support later segmentation into seven destruction groups.",
	},
}

return Specification
