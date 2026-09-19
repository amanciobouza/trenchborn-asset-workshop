local Specification = {
	AssetId = "LargeCity_UptownArena_L3",
	DisplayName = "Uptown Arena",
	City = "LargeCity",
	Phase = 6,
	QualityGate = "B-Approved",
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
		Status = "Approved",
		Revision = "LargeCityUptownArena-VisualTarget-v1",
		Approved = true,
		ApprovedRead = "Elegant enclosed tropical metropolitan arena with a broad oval body, shallow segmented roof, continuous teal media ribbon, strong vertical fins and a recessed glazed civic entrance.",
		Front = "Large centered recessed glass portal beneath the media ribbon, broad stairs, arena wordmark and event-plaza arrival.",
		Sides = "Layered horizontal facade bands with repeated vertical fins; smooth enclosed bowl rather than exposed stadium seating.",
		Roof = "Low fully enclosed segmented roof with a soft crown, clean perimeter edge and no open pitch hole.",
		Rear = "Integrated service/loading elevation with reduced glazing and a quieter architectural treatment.",
		Landscape = "Palm-lined urban plaza with planters, queue bollards and drop-off edges; dense civic event atmosphere rather than resort landscaping.",
		Camera = "Three-quarter aerial exterior view high enough to read the oval roof and footprint, but low enough to judge entrance scale and media ribbon continuity.",
		Lighting = "Bright tropical Large City daylight with clean blue sky and strong material contrast.",
		NextGate = "Quality Gate B",
	},

	QualityGateA = {
		Status = "Approved",
		ApprovedTarget = "LargeCityUptownArena-VisualTarget-v1",
	},

	TechnicalBreakdown = {
		CoordinateSystem = {
			Pivot = "Ground center of arena footprint",
			Front = "Local -Z faces main event plaza",
			Rear = "Local +Z faces service/loading side",
			GroundY = 0,
		},
		Massing = {
			OuterArena = {Footprint = Vector2.new(136, 98), LowerHeight = 24, UpperHeight = 43},
			MainEntrance = {Footprint = Vector2.new(64, 16), Center = Vector3.new(0, 13, -49), Height = 27},
			RearService = {Footprint = Vector2.new(74, 16), Center = Vector3.new(0, 9, 48), Height = 18},
		},
		Facade = {
			SegmentCount = 72,
			LowerBandY = 14,
			UpperBandY = 32,
			MediaRibbonY = 28,
			MediaRibbonHeight = 5.5,
			VerticalFinCount = 24,
			Rule = "Arena body uses shallow overlapping tangent-shell segments so the exterior reads as one flowing enclosed oval; vertical fins remain sparse surface rhythm rather than emphasizing facets.",
		},
		Roof = {
			SegmentCount = 72,
			OuterFootprint = Vector2.new(132, 94),
			CrownY = 56,
			PerimeterY = 44,
			Thickness = 2.2,
			Rule = "Fully enclosed shallow crown uses three broad sloped annular bands plus a small oval cap and continuous perimeter ring; avoid horizontal roof terraces, visible stepping and futuristic dome language.",
		},
		Entrance = {
			GlazingSpan = 56,
			GlazingHeight = 18,
			RecessDepth = 4.5,
			PortalPierCount = 6,
			WordmarkStandOff = 0.45,
			Rule = "Main portal remains broad, centered and visually recessed beneath the media ribbon.",
		},
		MediaRibbon = {
			OuterA = 69,
			OuterB = 50,
			Y = 29,
			Height = 5.5,
			SegmentCount = 48,
			FacadeStandOff = 0.45,
			Rule = "Ribbon stays visibly outside the facade shell to avoid clipping or Z-fighting.",
		},
		Service = {
			LoadingDoorCount = 4,
			RearGlazingReduced = true,
			Rule = "Back-of-house mass is integrated into the arena silhouette and never reads as a detached warehouse.",
		},
		LandscapeReferences = {
			PalmCount = 8,
			PlanterCount = 6,
			QueueBollardCount = 10,
			Phase = 5,
		},
		PartBudget = {
			TargetVisibleParts = 520,
			MaximumVisibleParts = 700,
		},
	},

	Phase4Status = {
		Status = "Approved",
		GeometryRevision = "LargeCityUptownArena-v2-SmoothShellRoof",
		QualityGateB = "Approved",
	},

	QualityGateB = {
		Status = "Approved",
		ApprovedGeometry = "LargeCityUptownArena-v2-SmoothShellRoof",
		Notes = "Flowing 72-segment oval shell and three-band sloped enclosed roof accepted.",
		NextPhase = 5,
	},

	Phase5Status = {
		Status = "InReview",
		Revision = "LargeCityUptownArena-Dressing-v5-ProjectedFacade",
		Includes = {
			"Uptown Arena wordmark",
			"Sports / Concerts / Events entrance strip",
			"Gate A-D entrance signage",
			"eight framed media-ribbon event displays",
			"facade accent lighting",
			"event plaza palms, planters and queue bollards",
			"rear event-loading signage",
		},
		QualityGateC = "Pending",
		NextPhase = "ExternalGameTestPending",
	},


	FacadeVisibilityFix = {
		Status = "InReview",
		GeometryRevision = "LargeCityUptownArena-v5-ProjectedFacadeDetails",
		DressingRevision = "LargeCityUptownArena-Dressing-v5-ProjectedFacade",
		Notes = "Continuous cyan media ribbon, framed event screens, feature bays, sparse facade lights and vertical fins were moved outward so they sit visibly on the exterior skin instead of being buried in the shell.",
	},

	Phase6Status = {
		Status = "ExternalGameTestPending",
		ExternalCollapseIntegration = true,
		QualityGateC = "Pending",
		Notes = "External collapse test remains pending. Facade visibility correction is currently under visual review.",
	},

	Phase3Acceptance = {
		"Continuous enclosed oval facade has deterministic dimensions and no large segment gaps.",
		"Fully enclosed shallow roof is clearly distinct from the adjacent open stadium.",
		"Media ribbon and entrance glazing stand clear of structural surfaces.",
		"Seven destruction groups map to coherent architectural masses.",
		"Golden Master remains below 700 visible parts.",
		"No modeled interior rooms are required.",
	},
}

return Specification
