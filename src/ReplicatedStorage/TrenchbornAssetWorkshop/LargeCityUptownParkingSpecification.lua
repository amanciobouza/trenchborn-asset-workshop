-- Phase 1 concept/specification for LC-55 Uptown Parking.
-- Standalone building branch: no dependency on other Large City building branches.

local Specification = {
	AssetId = "LargeCity_UptownParking_L3",
	DisplayName = "Uptown Parking",
	LayoutId = "LC-55",
	City = "LargeCity",
	District = "Uptown",
	BuildingType = "Parking Tower",
	Phase = 4,
	QualityGate = "B-Pending",
	Branch = "largecity-uptown-parking-l3",

	StandaloneImport = {
		Required = true,
		Rule = "This branch must remain independently importable into another project without depending on Stadium, Arena, Hospital, Resort, Summit Tower, Uptown Residences, Stadium Hotel, or any other building branch.",
	},

	LayoutReference = {
		Position = Vector3.new(340, 24, 555),
		Footprint = Vector2.new(70, 60),
		Height = 54,
		Yaw = 0,
	},

	Style = "Singapore mobility hub x Miami event-district parking architecture",
	Role = "Premium event-district mobility hub serving Stadium, Arena and nearby Uptown towers",

	Concept = {
		Name = "Verdant Mobility Deck",
		Read = "A compact sculptural parking tower wrapped in a breathable vertical screen, with a visible corner ramp, planted facade cuts, EV-charging identity and a lightweight rooftop mobility canopy.",
		DoNotReadAs = {
			"plain concrete parking garage",
			"warehouse",
			"office building",
			"generic multi-storey car park",
			"cyberpunk structure",
			"solid featureless box",
		},
	},

	Massing = {
		Base = {
			Footprint = Vector2.new(68, 58),
			Height = 10,
			Rule = "Ground-level mobility lobby and vehicle entrance with clearly readable in/out lanes, EV signage and pedestrian access.",
		},
		MainDecks = {
			Footprint = Vector2.new(66, 56),
			FromY = 10,
			ToY = 44,
			Rule = "Six parking levels form the main mass, but the exterior is broken by screened voids, planted cuts and a visible corner ramp.",
		},
		RooftopMobilityDeck = {
			Footprint = Vector2.new(62, 52),
			FromY = 44,
			ToY = 54,
			Rule = "Open rooftop mobility deck with solar/pergola canopy and planted edge, keeping the skyline light.",
		},
	},

	SignatureFeatures = {
		{
			Name = "VerticalScreenVeil",
			Description = "Alternating pale-metal and warm-bronze vertical fins wrap the garage, hiding parked cars while keeping the structure visibly ventilated.",
		},
		{
			Name = "ExpressedCornerRamp",
			Face = "front-right",
			Description = "A diagonal/spiral-like ramp language is expressed on one corner through sloped slabs and screen breaks, making the building legible as parking.",
		},
		{
			Name = "GreenBreathingCuts",
			Description = "Two broad planted facade voids interrupt the screen and create visible tropical green pockets rather than a monotonous parking box.",
		},
		{
			Name = "EVHub",
			Face = "-Z",
			Description = "Ground-level EV charging / mobility bay with teal lighting and a clearly readable vehicle entrance.",
		},
		{
			Name = "RooftopSolarCanopy",
			Y = 46,
			Description = "A lightweight solar/pergola canopy with open edges gives the roof a distinctive but practical silhouette.",
		},
		{
			Name = "PedestrianCore",
			Face = "front-left",
			Description = "Glass stair/elevator tower creates a clear human-scale entrance and adds vertical contrast to the horizontal parking decks.",
		},
	},

	Facade = {
		Primary = "Warm pale concrete parking slabs",
		Secondary = "Pale metal vertical screen fins",
		Accent = "Warm bronze fins plus restrained teal EV lighting",
		Openings = "Dark ventilated gaps between slab edges",
		Rule = "Facade must remain visibly ventilated and layered. Fins sit outside the deck edges and align with structural bays; no decorative elements buried inside the parking mass.",
	},

	Roof = {
		Rule = "Open rooftop mobility deck with solar/pergola structure and planting. Avoid a solid enclosed crown.",
	},

	Landscape = {
		Phase = 5,
		Includes = {
			"entry palms",
			"ground-level bioswale planters",
			"planted facade cuts",
			"rooftop edge planting",
			"EV charging signage",
			"pedestrian bollards",
		},
	},

	ProposedGameplayMetadata = {
		TargetMaxHealth = 64000,
		EnergyType = "Electric",
		InstallerTag = "KaijuHouse",
		ExternalCollapseIntegration = true,
	},

	PlannedDestructionGroups = {
		"D1_VehicleEntryAndEVHub",
		"D2_LowerParkingDecks",
		"D3_UpperParkingDecks",
		"D4_ExpressedRamp",
		"D5_ScreenVeilAndGreenCuts",
		"D6_RooftopMobilityDeck",
		"D7_PedestrianCoreAndService",
	},

	VisualTarget = {
		Status = "Approved",
		Revision = "LargeCityUptownParking-VisualTarget-v1",
		Brief = {
			"premium event-district parking tower in Singapore x Miami language",
			"70x60 footprint and 54-stud height",
			"clearly readable as multi-storey parking rather than office or apartment building",
			"breathable facade with alternating vertical metal/bronze fins",
			"dark open parking gaps visible behind the screen",
			"one expressed corner ramp with sloped geometry",
			"two planted facade breathing cuts",
			"glass pedestrian stair/elevator core",
			"strong vehicle entry and EV charging identity",
			"light rooftop solar/pergola canopy with planted edge",
			"daylight architectural concept board with front, three-quarter, side and rear cues",
			"not cyberpunk, not warehouse, not plain concrete garage",
		},
	},



	QualityGateA = {
		Status = "Approved",
		ApprovedTarget = "LargeCityUptownParking-VisualTarget-v1",
		Notes = "Approved Verdant Mobility Deck concept with ventilated screen veil, expressed ramp corner, green breathing cuts, EV hub, glass pedestrian core and rooftop mobility canopy.",
		NextPhase = 3,
	},

	TechnicalBreakdown = {
		CoordinateSystem = {
			Pivot = "ground center",
			Front = "local -Z",
			Rear = "local +Z",
			LayoutYaw = 0,
		},
		Overall = {
			TargetFootprint = Vector2.new(70, 60),
			TargetHeight = 54,
			GroundLevel = 0,
		},
		Base = {
			Footprint = Vector2.new(68, 58),
			Center = Vector3.new(0, 5, 0),
			Height = 10,
			VehicleEntryWidth = 22,
			PedestrianCoreWidth = 10,
		},
		ParkingDecks = {
			Footprint = Vector2.new(66, 56),
			FromY = 10,
			ToY = 44,
			LevelCount = 6,
			SlabThickness = 0.9,
			ClearLevelHeight = 4.7,
			OpenGapHeight = 3.0,
		},
		ScreenVeil = {
			FinWidth = 0.65,
			FinDepth = 1.1,
			FinSpacing = 2.8,
			BronzeAccentEvery = 5,
			OffsetFromDeckEdge = 1.2,
			Rule = "Screen fins remain clearly outside the deck edges and preserve visible ventilation gaps.",
		},
		ExpressedRamp = {
			Corner = "front-right",
			RampWidth = 10,
			RisePerLevel = 4.7,
			RunPerLevel = 18,
			VisibleSlope = true,
			Rule = "Ramp slabs must read as sloped circulation, not decorative diagonal bands.",
		},
		GreenBreathingCutOne = {
			Face = "front",
			CenterX = -12,
			FromY = 18,
			ToY = 32,
			Width = 18,
			Depth = 5,
		},
		GreenBreathingCutTwo = {
			Face = "rear-right",
			CenterX = 14,
			FromY = 30,
			ToY = 43,
			Width = 16,
			Depth = 5,
		},
		EVHub = {
			Face = "front",
			BayCount = 4,
			CanopyWidth = 28,
			CanopyDepth = 8,
			Accent = "teal",
		},
		PedestrianCore = {
			Face = "front-left",
			Footprint = Vector2.new(10, 12),
			Height = 50,
			Glazing = true,
			Rule = "Glass core projects outside the screen veil and remains readable as stairs/lift access.",
		},
		RooftopMobilityDeck = {
			BaseY = 44,
			TopY = 54,
			DeckFootprint = Vector2.new(62, 52),
			CanopyFootprint = Vector2.new(46, 28),
			CanopyHeight = 5.5,
			SolarFinCount = 8,
			PlantingDepth = 4,
		},
		RearService = {
			DoorCount = 2,
			DoorWidth = 7,
			Rule = "Rear service access sits on true +Z exterior and stays visible behind the facade screen.",
		},
		PartBudget = {
			TargetVisibleParts = 600,
			MaximumVisibleParts = 780,
		},
	},

	Phase2Status = {
		Status = "Approved",
		TargetRevision = "LargeCityUptownParking-VisualTarget-v1",
		QualityGateA = "Approved",
		ReviewFocus = {
			"premium mobility-hub read",
			"vertical screen veil",
			"expressed corner ramp",
			"two planted breathing cuts",
			"clear EV vehicle entry",
			"glass pedestrian core",
			"light rooftop solar/pergola canopy",
			"clear distinction from office, residential and warehouse architecture",
		},
	},


	Phase4Status = {
		Status = "GoldenMasterReview",
		GeometryRevision = "LargeCityUptownParking-v2-FreestandingPedestrianCore",
		QualityGateB = "Pending",
		ReviewFocus = {
			"immediate parking / mobility-hub readability",
			"open six-level deck structure and visible ventilation gaps",
			"screen veil sits outside the deck edges",
			"front-right ramps read as real sloped circulation",
			"two green breathing cuts remain visibly open",
			"EV vehicle entry is prominent and unobstructed",
			"glass pedestrian core projects clearly outside the screen",
			"pedestrian glass core clears the concrete deck envelope with no black/concrete surface overlap or Z-fighting",
			"rooftop solar/pergola canopy remains light and open",
			"rear service remains visible on true +Z exterior",
			"no coplanar deck or facade Z-fighting",
		},
	},

	Phase3Acceptance = {
		"Base, six parking decks, ramp, screen veil, pedestrian core and rooftop deck use deterministic dimensions tied to LC-55.",
		"Parking deck ventilation remains clearly visible behind the facade screen.",
		"Expressed corner ramp is structurally readable as sloped circulation.",
		"Both planted breathing cuts interrupt the facade mass and remain open/readable.",
		"EV hub and pedestrian core are clearly identifiable from the front.",
		"Rooftop solar/pergola canopy remains light and open.",
		"Seven destruction groups map to coherent architectural masses.",
		"Golden Master target remains below 780 visible parts.",
	},

	Phase1Acceptance = {
		"Building reads immediately as premium parking / mobility infrastructure.",
		"Vertical screen veil and expressed corner ramp create a distinctive silhouette at Kaiju gameplay distance.",
		"At least two planted breathing cuts break the parking mass and connect it to Large City's tropical identity.",
		"Vehicle entry, EV hub and pedestrian core are clearly identifiable from the front.",
		"Facade remains visibly ventilated rather than reading as a sealed office curtain wall.",
		"Rooftop canopy adds interest without competing with nearby hotel and tower crowns.",
		"Footprint and height remain compatible with LC-55.",
	},
}

return Specification
