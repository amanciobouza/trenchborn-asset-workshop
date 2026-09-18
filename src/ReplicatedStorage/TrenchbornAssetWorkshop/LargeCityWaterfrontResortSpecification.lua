local Specification = {
	AssetId = "LargeCity_LuxuryWaterfrontResort_L3",
	DisplayName = "Luxury Waterfront Resort",
	City = "LargeCity",
	Phase = 7,
	QualityGate = "C-ExternalGameTestPending",
	Style = "Singapore x Miami tropical luxury metropolis",

	Dimensions = {
		Footprint = Vector3.new(85, 0, 65),
		MainTower = Vector3.new(42, 64, 34),
		GuestWing = Vector3.new(38, 38, 26),
		Podium = Vector3.new(70, 12, 45),
	},

	Palette = {
		Concrete = Color3.fromRGB(232, 229, 220),
		Limestone = Color3.fromRGB(214, 204, 186),
		Glass = Color3.fromRGB(92, 164, 184),
		DarkGlass = Color3.fromRGB(45, 81, 93),
		Metal = Color3.fromRGB(185, 191, 194),
		Wood = Color3.fromRGB(133, 98, 67),
		Pool = Color3.fromRGB(57, 189, 211),
		Landscape = Color3.fromRGB(72, 124, 76),
	},

	GoldenMaster = {
		TargetVisibleParts = 520,
		MaxVisibleParts = 700,
		RequireRealBalconies = true,
		RequireRealFacadeRibs = true,
		RequireEntranceCanopy = true,
		RequireSkyBarCrown = true,
		RequirePoolTerrace = true,
		RequirePromenade = true,
		RequireNoInterior = true,
	},

	DestructionGroups = {
		"D1_EntranceCanopy",
		"D2_PodiumLobby",
		"D3_LeftGuestWing",
		"D4_RightGuestWing",
		"D5_CentralTowerLower",
		"D6_CentralTowerUpper",
		"D7_RooftopSkyBar",
	},

	Installer = {
		ModelName = "LargeCity_LuxuryWaterfrontResort_L3",
		RequiredTag = "KaijuHouse",
		MaxHealth = 64000,
		EnergyType = "Heat",
		BuildingType = "Hotel",
		CityTier = 4,
		FinalInstallerVersion = 1,
		QualityGateA = "Approved",
		QualityGateB = "Approved",
		QualityGateC = "ExternalGameTestPending",
		UsesSharedMainGameDestruction = true,
	},

	VisualReviewCriteria = {
		"Reads immediately as a tropical luxury waterfront resort, not an office tower.",
		"Central tower is clearly dominant and flanked by two lower guest wings.",
		"The silhouette opens toward the waterfront and feels resort-like rather than blocky.",
		"Balconies and facade ribs are physical geometry, not texture-only decoration.",
		"Entrance canopy, pool terrace and rooftop crown are visible from kaiju gameplay distance.",
		"Architecture is modern and premium but not futuristic enough to compete with Mega City.",
		"No unintended gaps, overlaps or z-fighting appear between repeated modules.",
		"Pivot is deterministic and located at ground center of the whole resort complex.",
	},
}

return Specification
