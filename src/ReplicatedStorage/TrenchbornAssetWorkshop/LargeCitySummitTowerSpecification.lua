-- Phase 1 concept/specification for LC-52 Summit Tower.
-- Standalone building branch: no dependency on other Large City building branches.

local Specification = {
	AssetId = "LargeCity_SummitTower_L3",
	DisplayName = "Summit Tower",
	LayoutId = "LC-52",
	City = "LargeCity",
	District = "Uptown",
	BuildingType = "High-Rise",
	Phase = 1,
	QualityGate = "ConceptReview",
	Branch = "largecity-summit-tower-l3",

	StandaloneImport = {
		Required = true,
		Rule = "This branch must remain independently importable into another project without depending on Stadium, Arena, Hospital, Resort, or any other building branch.",
	},

	LayoutReference = {
		Position = Vector3.new(220, 24, 500),
		Footprint = Vector2.new(70, 64),
		Height = 126,
		Yaw = 4,
	},

	Style = "Singapore x Miami tropical luxury metropolis",
	Role = "Uptown skyline landmark beside the stadium and arena",

	Concept = {
		Name = "Tropical Summit Spire",
		Read = "Elegant premium high-rise with a flowing vertical silhouette, offset glass volumes, sky-garden cuts and a distinctive luminous crown.",
		DoNotReadAs = {
			"generic rectangular office slab",
			"cyberpunk tower",
			"needle skyscraper",
			"stadium annex",
		},
	},

	Massing = {
		Podium = {
			Footprint = Vector2.new(64, 58),
			Height = 18,
			Rule = "Broad civic/luxury podium anchors the tower at street level and creates a readable Kaiju-scale base.",
		},
		LowerTower = {
			Footprint = Vector2.new(52, 46),
			FromY = 18,
			ToY = 58,
			Rule = "Rounded/softened rectangular tower shaft with strong vertical fins and glass bands.",
		},
		MidTower = {
			Footprint = Vector2.new(46, 42),
			FromY = 58,
			ToY = 92,
			Offset = Vector3.new(-3, 0, 2),
			Rule = "First setback shifts the mass slightly to avoid a single extruded box.",
		},
		UpperTower = {
			Footprint = Vector2.new(39, 36),
			FromY = 92,
			ToY = 116,
			Offset = Vector3.new(3, 0, -1),
			Rule = "Second setback creates a slimmer crown approach and a clear skyline progression.",
		},
	},

	SignatureFeatures = {
		{
			Name = "SkyGardenOne",
			Y = 55,
			Description = "Deep planted terrace/notch wrapping one corner of the tower; visible from medium distance.",
		},
		{
			Name = "SkyGardenTwo",
			Y = 89,
			Description = "Smaller upper sky terrace with palms/greenery and a stronger teal accent band.",
		},
		{
			Name = "VerticalFins",
			Description = "Tall pale-metal fins run across selected facade bays and visually connect podium, shaft and crown.",
		},
		{
			Name = "SummitCrown",
			Y = 116,
			Height = 10,
			Description = "Asymmetric stepped crown with a luminous teal ring/line; iconic but still metropolitan rather than futuristic.",
		},
		{
			Name = "MainLobby",
			Face = "-Z",
			Description = "Tall recessed glass lobby under a projecting canopy, clearly readable as the main entrance.",
		},
	},

	Facade = {
		Primary = "Blue-green dark glass",
		Secondary = "Warm pale concrete / stone",
		Accent = "Teal/cyan",
		Rule = "Alternate glass fields, pale structural frames, fins and sky-garden recesses so the facade never reads as one monotonous curtain wall.",
	},

	RoofAndCrown = {
		Rule = "No flat anonymous roof. Upper shaft steps into an asymmetric crown with a shallow illuminated perimeter feature.",
	},

	Landscape = {
		Phase = 5,
		Includes = {
			"entrance palms",
			"raised planters",
			"drop-off canopy",
			"small plaza bollards",
			"sky-garden greenery",
		},
	},

	ProposedGameplayMetadata = {
		TargetMaxHealth = 256000,
		EnergyType = "Electric",
		InstallerTag = "KaijuHouse",
		ExternalCollapseIntegration = true,
	},

	PlannedDestructionGroups = {
		"D1_EntryPodium",
		"D2_LowerTower",
		"D3_MidTower",
		"D4_UpperTower",
		"D5_SkyGardens",
		"D6_SummitCrown",
		"D7_ServiceCore",
	},

	Phase1Acceptance = {
		"Silhouette is noticeably more vertical than Stadium and Arena.",
		"Tower is not a plain rectangular extrusion.",
		"Two setbacks and two sky-garden cuts are readable at Kaiju gameplay distance.",
		"Main entrance is clearly identifiable from the front.",
		"Crown gives Summit Tower a unique skyline identity without becoming sci-fi.",
		"Footprint and overall height remain compatible with LC-52.",
	},
}

return Specification
