local Specification = {
	AssetId = "LargeCity_UptownArena_L3",
	DisplayName = "Uptown Arena",
	City = "LargeCity",
	Phase = 2,
	QualityGate = "A-Pending",
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
		Status = "InReview",
		Revision = "LargeCityUptownArena-VisualTarget-v1",
		TargetRead = "Elegant enclosed tropical metropolitan arena with a broad oval body, shallow segmented roof, continuous teal media ribbon, strong vertical fins and a recessed glazed civic entrance.",
		Front = "Large centered recessed glass portal beneath the media ribbon, broad stairs, arena wordmark and event-plaza arrival.",
		Sides = "Layered horizontal facade bands with repeated vertical fins; smooth enclosed bowl rather than exposed stadium seating.",
		Roof = "Low fully enclosed segmented roof with a soft crown, clean perimeter edge and no open pitch hole.",
		Rear = "Integrated service/loading elevation with reduced glazing and a quieter architectural treatment.",
		Landscape = "Palm-lined urban plaza with planters, queue bollards and drop-off edges; dense civic event atmosphere rather than resort landscaping.",
		Camera = "Three-quarter aerial exterior view high enough to read the oval roof and footprint, but low enough to judge entrance scale and media ribbon continuity.",
		Lighting = "Bright tropical Large City daylight with clean blue sky and strong material contrast.",
		NextGate = "Quality Gate A",
	},
}

return Specification
