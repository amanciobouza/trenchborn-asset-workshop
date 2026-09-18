local Specification = {
	AssetId = "LargeCity_UptownArena_L3",
	DisplayName = "Uptown Arena",
	City = "LargeCity",
	Phase = 1,
	QualityGate = "Pre-A",
	Style = "Singapore x Miami tropical metropolitan indoor arena",

	AssetBrief = {
		Purpose = "Secondary Sports + Uptown landmark that complements the open stadium without competing with it.",
		Role = "Large enclosed multi-purpose arena for indoor sports, concerts and civic events; must read immediately as an arena rather than a stadium, mall or convention centre.",
		Scale = "Large L3 landmark sized to LC-51: approximately 150 x 112 studs with a silhouette height around 58 studs.",
		GameplayRead = "Compact enclosed bowl, continuous roof volume, strong entrance portals and a luminous media ribbon must remain readable from kaiju distance.",
		NoInterior = true,
	},

	Location = {
		LayoutId = "LC-51",
		District = "Sports + Uptown",
		PlotCenter = Vector3.new(-220, 24, 530),
		PlotFootprint = Vector2.new(150, 112),
		PlotYaw = -4,
		ApprovedBlockoutHeight = 58,
	},

	DesignIntent = {
		Silhouette = "Low, broad enclosed oval arena with a gently domed segmented roof and a stronger horizontal profile than the stadium.",
		Front = "Large recessed main entrance with broad glazed portal, civic stairs and a prominent arena wordmark.",
		Sides = "Smooth layered facade bands with a continuous digital/media ribbon and repeated vertical fins.",
		Roof = "Fully enclosed shallow roof, visually segmented and supported by a clean perimeter ring; clearly different from the stadium's open canopy.",
		Rear = "Back-of-house loading/service mass integrated into the main volume without becoming a separate box.",
		Landscape = "Urban event plaza, palms, planters, queue bollards and drop-off edges; denser and more metropolitan than the stadium forecourt.",
	},

	VisualLanguage = {
		PrimaryMaterials = {"light concrete", "white metal", "dark glass", "brushed aluminium"},
		Accent = "teal/cyan media ribbon with limited warm event lighting",
		Avoid = {
			"open stadium bowl",
			"large exposed seating terraces",
			"fully futuristic sci-fi dome",
			"generic shopping mall",
			"boxy convention centre",
		},
		IdentityAnchors = {
			"enclosed oval arena",
			"shallow segmented roof",
			"continuous media ribbon",
			"large recessed glazed entrance",
			"vertical facade fins",
			"urban event plaza",
		},
	},

	ProposedGameplayMetadata = {
		TargetMaxHealth = 64000,
		EnergyType = "Electric",
		InstallerTag = "KaijuHouse",
		ExternalCollapseIntegration = true,
		Rationale = "The arena is a major Large City civic venue but materially smaller than the 256k stadium; Electric matches lighting, scoreboards and event infrastructure.",
	},

	PlannedDestructionGroups = {
		"D1_MainEntrance",
		"D2_LowerFacade",
		"D3_UpperFacade",
		"D4_RoofWest",
		"D5_RoofEast",
		"D6_MediaRibbonAndSignage",
		"D7_ServiceAndLoading",
	},

	Phase1Acceptance = {
		"Silhouette reads immediately as a compact enclosed arena from gameplay distance.",
		"Asset fits within the LC-51 150 x 112 stud plot.",
		"Design is clearly distinct from the adjacent Large City Stadium.",
		"Roof is fully enclosed but remains metropolitan rather than Mega City sci-fi.",
		"No playable interior rooms are required.",
		"Seven destruction groups can map to coherent physical masses.",
		"Asset remains buildable entirely in Roblox Studio with modular geometry.",
	},

	VisualTarget = {
		Status = "Pending",
		NextPhase = 2,
	},
}

return Specification
