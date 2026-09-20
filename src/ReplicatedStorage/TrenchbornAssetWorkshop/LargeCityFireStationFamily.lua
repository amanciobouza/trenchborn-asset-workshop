-- Reusable Large City fire-station family definition.
-- Each concrete fire-station branch copies this family locally so final packages remain standalone.

local Family = {
	FamilyId = "LargeCity_FireStation_Kit_v1",
	BaseReference = "LC-45 Technology Fire Station",
	ReuseStrategy = "Shared procedural building family with per-plot parameters and district dressing variants.",

	SharedArchitecture = {
		"apparatus hall with configurable bay count",
		"command/admin wing",
		"compact training/hose tower",
		"front response apron",
		"rear decon/service yard",
		"rooftop emergency systems",
	},

	VariantParameters = {
		"BayCount",
		"OverallWidth",
		"OverallDepth",
		"TowerSide",
		"TowerHeight",
		"CommandWingSide",
		"FacadeStyle",
		"AccentStyle",
		"LandscapeStyle",
		"DistrictSignage",
	},

	Variants = {
		TechnologyFireStation = {
			LayoutId = "LC-45",
			Footprint = Vector2.new(88, 68),
			Height = 34,
			BayCount = 3,
			TowerSide = "Right",
			CommandWingSide = "Right",
			FacadeStyle = "MedicalTech",
			AccentStyle = "FireRed",
			LandscapeStyle = "TropicalMedicalTech",
		},
		LargeCityFireHQ = {
			LayoutId = "LC-17",
			Footprint = Vector2.new(92, 68),
			Height = 34,
			BayCount = 3,
			TowerSide = "Left",
			CommandWingSide = "Left",
			FacadeStyle = "GatewayCivic",
			AccentStyle = "FireRed",
			LandscapeStyle = "GatewayBoulevard",
		},
	},

	Rules = {
		"Reuse core geometry and systems, but vary mass offsets, tower side, facade treatment and dressing so repeated stations do not read as exact copies.",
		"Gameplay metadata and destruction groups use the same semantic structure across family members.",
		"Each concrete building branch remains independently importable and must include its own local copy of the family module.",
		"Landmark buildings do not use this family approach unless explicitly assigned.",
	},
}

return Family
