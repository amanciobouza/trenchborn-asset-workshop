-- Phase 1 concept/specification for LC-52 Summit Tower.
-- Standalone building branch: no dependency on other Large City building branches.

local Specification = {
	AssetId = "LargeCity_SummitTower_L3",
	DisplayName = "Summit Tower",
	LayoutId = "LC-52",
	City = "LargeCity",
	District = "Uptown",
	BuildingType = "High-Rise",
	Phase = 5,
	QualityGate = "B-Approved",
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

	VisualTarget = {
		Status = "Approved",
		Revision = "LargeCitySummitTower-VisualTarget-v1",
		Brief = {
			"tropical luxury high-rise in Singapore x Miami language",
			"softened rectangular shaft with two visible setbacks",
			"two planted sky-garden cuts",
			"dark blue-green glass with pale structural frames",
			"strong vertical fins",
			"recessed tall main lobby on the front",
			"asymmetric illuminated summit crown",
			"daylight architectural concept board with front, three-quarter and rear cues",
			"not cyberpunk, not a plain glass box",
		},
	},

	QualityGateA = {
		Status = "Approved",
		ApprovedTarget = "LargeCitySummitTower-VisualTarget-v1",
		Notes = "Approved tropical luxury stepped high-rise with two sky gardens, strong vertical fins, recessed lobby and asymmetric illuminated crown.",
		NextPhase = 3,
	},

	TechnicalBreakdown = {
		CoordinateSystem = {
			Pivot = "ground center",
			Front = "local -Z",
			Rear = "local +Z",
			LayoutYaw = 4,
		},
		Overall = {
			TargetFootprint = Vector2.new(70, 64),
			TargetHeight = 126,
			GroundLevel = 0,
		},
		Podium = {
			Footprint = Vector2.new(64, 58),
			Center = Vector3.new(0, 9, 0),
			Height = 18,
			CornerChamfer = 5,
			LobbyCutWidth = 30,
			LobbyCutDepth = 5,
		},
		LowerTower = {
			Footprint = Vector2.new(52, 46),
			Center = Vector3.new(0, 38, 0),
			Height = 40,
			CornerRadiusApprox = 4,
			FacadeBayCountPerLongFace = 7,
			FacadeBayCountPerShortFace = 6,
		},
		SkyGardenOne = {
			Y = 55,
			Height = 5,
			Depth = 6,
			WrapCorner = "front-left",
			VisibleGreeneryBand = true,
		},
		MidTower = {
			Footprint = Vector2.new(46, 42),
			Center = Vector3.new(-3, 75, 2),
			Height = 34,
			CornerRadiusApprox = 4,
		},
		SkyGardenTwo = {
			Y = 89,
			Height = 4.5,
			Depth = 5,
			WrapCorner = "rear-right",
			VisibleGreeneryBand = true,
		},
		UpperTower = {
			Footprint = Vector2.new(39, 36),
			Center = Vector3.new(3, 104, -1),
			Height = 24,
			CornerRadiusApprox = 3.5,
		},
		Crown = {
			BaseY = 116,
			TopY = 126,
			CoreFootprint = Vector2.new(30, 28),
			PrimaryBladeHeight = 10,
			SecondaryBladeHeight = 7,
			AsymmetryOffset = Vector3.new(4, 0, -2),
			LuminousPerimeter = true,
		},
		Facade = {
			PrimaryGlassDepth = 0.7,
			FrameDepth = 1.0,
			VerticalFinDepth = 1.5,
			VerticalFinWidth = 1.2,
			VerticalFinSpacing = 7.0,
			AccentBandHeight = 0.8,
			Rule = "Use continuous facade fields with attached fins and frames; avoid a stack of disconnected floor boxes.",
		},
		Entrance = {
			GlazingWidth = 28,
			GlazingHeight = 13,
			RecessDepth = 4.5,
			CanopyWidth = 34,
			CanopyDepth = 8,
			CanopyY = 13.5,
		},
		RearService = {
			DoorCount = 3,
			DoorWidth = 8,
			ServiceCanopy = true,
			Rule = "Rear service access must be visibly placed on the true +Z exterior face, not hidden inside the podium mass.",
		},
		PartBudget = {
			TargetVisibleParts = 620,
			MaximumVisibleParts = 760,
		},
	},

	Phase4Status = {
		Status = "Approved",
		GeometryRevision = "LargeCitySummitTower-v5-ProjectedSkyGardens",
		QualityGateB = "Approved",
		ReviewFocus = {
			"overall stepped silhouette",
			"two readable sky-garden interruptions",
			"facade verticality and fin rhythm",
			"main lobby depth",
			"asymmetric crown",
			"rear service visibility",
			"roof and crown free of coplanar surface flicker / Z-fighting",
			"all three crown blades fully exposed above the raised rooftop crown",
			"facade fins aligned to window mullions",
			"sky gardens read as balconies/canopies without an unexplained black overlay across the glazing",
			"sky-garden slabs project fully outside the facade instead of intersecting the tower mass",
		},
	},

	QualityGateB = {
		Status = "Approved",
		ApprovedGeometry = "LargeCitySummitTower-v5-ProjectedSkyGardens",
		Notes = "Raised crown, exposed crown blades, window-aligned facade fins, clarified sky-garden balconies and clean roof surfaces accepted.",
		NextPhase = 5,
	},

	Phase5Status = {
		Status = "InReview",
		Revision = "LargeCitySummitTower-Dressing-v2-ProjectedSkyGardens",
		Includes = {
			"Summit Tower entrance wordmark and teal lobby accent",
			"entry palms, planters and bollards",
			"vegetation on both sky gardens",
			"sparse teal facade accents",
			"rear service and delivery signage",
		},
		QualityGateC = "Pending",
	},

	Phase3Acceptance = {
		"Podium, three tower masses and crown use deterministic dimensions tied to the LC-52 footprint and height.",
		"Two setbacks and two sky-garden cuts remain visibly distinct in the Golden Master.",
		"Facade treatment is continuous and vertical rather than a stack of unrelated boxes.",
		"Main lobby and rear service access are both externally readable.",
		"Seven destruction groups map to coherent architectural masses.",
		"Golden Master target stays below 760 visible parts.",
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
