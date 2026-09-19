-- Phase 1 concept/specification for LC-53 Uptown Residences.
-- Standalone building branch: no dependency on other Large City building branches.

local Specification = {
	AssetId = "LargeCity_UptownResidences_L3",
	DisplayName = "Uptown Residences",
	LayoutId = "LC-53",
	City = "LargeCity",
	District = "Uptown",
	BuildingType = "Luxury Apartment",
	Phase = 2,
	QualityGate = "A-Pending",
	Branch = "largecity-uptown-residences-l3",

	StandaloneImport = {
		Required = true,
		Rule = "This branch must remain independently importable into another project without depending on Stadium, Arena, Hospital, Resort, Summit Tower, or any other building branch.",
	},

	LayoutReference = {
		Position = Vector3.new(-225, 24, 665),
		Footprint = Vector2.new(78, 66),
		Height = 92,
		Yaw = 0,
	},

	Style = "Singapore x Miami tropical luxury residential",
	Role = "Premium Uptown residential landmark that softens the district skyline beside the arena and stadium",

	Concept = {
		Name = "Verdant Cascade Residences",
		Read = "A broad luxury residential tower composed of two offset apartment wings, deep planted balcony bands, a central vertical garden slot and a rooftop residents terrace.",
		DoNotReadAs = {
			"generic office tower",
			"hotel slab",
			"stack of identical floor plates",
			"cyberpunk residential tower",
			"plain rectangular apartment block",
		},
	},

	Massing = {
		Podium = {
			Footprint = Vector2.new(72, 60),
			Height = 14,
			Rule = "Low landscaped podium with a broad residential arrival court and visible resident-lobby entrance.",
		},
		LowerResidence = {
			Footprint = Vector2.new(64, 54),
			FromY = 14,
			ToY = 50,
			Rule = "Broad lower residential mass with softened corners and strong horizontal balcony rhythm.",
		},
		UpperWings = {
			FromY = 50,
			ToY = 84,
			LeftWingFootprint = Vector2.new(27, 45),
			RightWingFootprint = Vector2.new(27, 45),
			LeftWingOffset = Vector3.new(-15, 0, 1),
			RightWingOffset = Vector3.new(15, 0, -2),
			Rule = "Two slightly offset apartment wings create a vertical garden slot between them and prevent the building reading as one monolithic slab.",
		},
		RooftopClub = {
			Footprint = Vector2.new(42, 34),
			FromY = 84,
			ToY = 92,
			Rule = "Lightweight rooftop residents pavilion and pergola rather than a skyscraper crown.",
		},
	},

	SignatureFeatures = {
		{
			Name = "CascadeBalconies",
			Description = "Deep balcony bands step outward at selected levels and wrap corners, creating a highly residential horizontal silhouette.",
		},
		{
			Name = "VerticalGardenSlot",
			FromY = 48,
			ToY = 84,
			Description = "Dark recessed central slot between the two upper wings with planted terraces and warm lighting.",
		},
		{
			Name = "SkyTerraceOne",
			Y = 49,
			Description = "Full-width planted transfer terrace where the broad lower mass splits into two upper wings.",
		},
		{
			Name = "SkyTerraceTwo",
			Y = 70,
			Description = "Smaller asymmetric residents terrace bridging visually toward one wing, with palms and glass balustrade.",
		},
		{
			Name = "ResidentialArrival",
			Face = "-Z",
			Description = "Warm stone porte-cochere, tall glass lobby and landscaped drop-off court; clearly residential rather than civic.",
		},
		{
			Name = "RooftopResidentsDeck",
			Y = 84,
			Description = "Open-feeling rooftop pavilion with pergola fins, planting and a shallow illuminated edge feature.",
		},
	},

	Facade = {
		Primary = "Warm off-white stone / concrete",
		Secondary = "Blue-green residential glazing",
		Balcony = "Glass balustrades with pale slab edges",
		Accent = "Muted teal plus warm amber lobby lighting",
		Rule = "Horizontal balcony rhythm dominates. Vertical elements are used only to frame the central garden slot and entrance so the building remains visibly residential and distinct from Summit Tower.",
	},

	Roof = {
		Rule = "No anonymous flat slab. The rooftop residents pavilion, pergola, planted deck and asymmetric canopy create a light residential skyline finish.",
	},

	Landscape = {
		Phase = 5,
		Includes = {
			"arrival palms",
			"long residential planters",
			"porte-cochere",
			"balcony greenery",
			"sky-terrace planting",
			"rooftop resident deck planting",
			"rear service screening",
		},
	},

	ProposedGameplayMetadata = {
		TargetMaxHealth = 128000,
		EnergyType = "Electric",
		InstallerTag = "KaijuHouse",
		ExternalCollapseIntegration = true,
	},

	PlannedDestructionGroups = {
		"D1_ArrivalPodium",
		"D2_LowerResidence",
		"D3_LeftResidentialWing",
		"D4_RightResidentialWing",
		"D5_BalconiesAndSkyTerraces",
		"D6_RooftopResidentsDeck",
		"D7_ServiceCore",
	},

	VisualTarget = {
		Status = "InReview",
		Revision = "LargeCityUptownResidences-VisualTarget-v1",
		Brief = {
			"tropical luxury residential tower in Singapore x Miami language",
			"broad 78x66 footprint and medium-high 92-stud skyline presence",
			"two offset upper apartment wings rather than a single tower slab",
			"strong horizontal balcony bands with glass balustrades",
			"deep planted sky terrace where the lower mass splits",
			"recessed vertical garden slot between the upper wings",
			"warm stone, blue-green glass, palms and dense greenery",
			"residential porte-cochere and clearly readable main lobby",
			"light rooftop residents pavilion with pergola and planting",
			"daylight architectural concept board with front, three-quarter, side and rear cues",
			"not cyberpunk, not an office tower, not a hotel",
		},
	},


	Phase2Status = {
		Status = "VisualTargetReview",
		TargetRevision = "LargeCityUptownResidences-VisualTarget-v1",
		QualityGateA = "Pending",
		ReviewFocus = {
			"luxury residential read",
			"two offset upper wings",
			"central vertical garden slot",
			"strong horizontal balcony rhythm",
			"planted transfer terrace",
			"residential porte-cochere and lobby",
			"light rooftop residents pavilion",
			"clear distinction from Summit Tower and Stadium Hotel",
		},
	},

	Phase1Acceptance = {
		"Building reads immediately as luxury residential rather than office, hotel or civic architecture.",
		"Two upper wings and central vertical garden slot create a distinctive silhouette at Kaiju gameplay distance.",
		"Horizontal balcony rhythm is the primary facade language and remains readable from the street.",
		"At least two planted sky terraces break the mass and connect the building to Large City's tropical identity.",
		"Main residential arrival is clearly identifiable from the front.",
		"Rooftop pavilion adds interest without competing with Summit Tower's crown.",
		"Footprint and height remain compatible with LC-53.",
	},
}

return Specification
