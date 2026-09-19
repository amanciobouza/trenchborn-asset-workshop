-- Phase 1 concept/specification for LC-54 Stadium Hotel.
-- Standalone building branch: no dependency on other Large City building branches.

local Specification = {
	AssetId = "LargeCity_StadiumHotel_L3",
	DisplayName = "Stadium Hotel",
	LayoutId = "LC-54",
	City = "LargeCity",
	District = "Uptown",
	BuildingType = "Hotel",
	Phase = 5,
	QualityGate = "B-Pending",
	Branch = "largecity-stadium-hotel-l3",

	StandaloneImport = {
		Required = true,
		Rule = "This branch must remain independently importable into another project without depending on Stadium, Arena, Hospital, Resort, Summit Tower, Uptown Residences, or any other building branch.",
	},

	LayoutReference = {
		Position = Vector3.new(215, 24, 650),
		Footprint = Vector2.new(78, 64),
		Height = 82,
		Yaw = 0,
	},

	Style = "Miami resort hotel x Singapore event district",
	Role = "Premium event hotel beside the Stadium and Arena, acting as a hospitality bridge between Uptown sports venues and residential towers",

	Concept = {
		Name = "Grandstand Hotel",
		Read = "A broad premium hotel with a strong arrival podium, a gently curved room tower, stacked sky lounges and a rooftop pool deck oriented toward the event district.",
		DoNotReadAs = {
			"office tower",
			"generic apartment block",
			"stadium annex",
			"casino resort",
			"cyberpunk hotel",
			"plain rectangular slab",
		},
	},

	Massing = {
		Podium = {
			Footprint = Vector2.new(74, 60),
			Height = 16,
			Rule = "Grand hospitality podium with porte-cochere, lobby, restaurant glazing and a strong front arrival sequence.",
		},
		HotelBar = {
			Footprint = Vector2.new(66, 50),
			FromY = 16,
			ToY = 58,
			Rule = "Main room bar uses a shallow bow/curve and stepped edges so the long hotel mass does not read as a flat box.",
		},
		SkyLounge = {
			Footprint = Vector2.new(54, 44),
			FromY = 58,
			ToY = 70,
			Offset = Vector3.new(3, 0, -1),
			Rule = "Set-back upper lounge level with panoramic glazing and terraces facing the event district.",
		},
		RooftopDeck = {
			Footprint = Vector2.new(58, 46),
			FromY = 70,
			ToY = 82,
			Rule = "Open-feeling rooftop hospitality deck with pool, pergola and sculptural canopy rather than a solid crown.",
		},
	},

	SignatureFeatures = {
		{
			Name = "ArrivalPorteCochere",
			Face = "-Z",
			Description = "Deep hotel drop-off canopy with two strong supports, tall lobby glazing and a clearly readable upscale entrance.",
		},
		{
			Name = "GuestRoomBalconyRhythm",
			Description = "Alternating room-window and shallow balcony bands create a fine-grained hotel facade distinct from Uptown Residences' deeper apartment terraces.",
		},
		{
			Name = "StadiumViewSkyLounge",
			Y = 60,
			Description = "A panoramic lounge terrace with broad glazing and an outward-facing hospitality deck toward Stadium/Arena.",
		},
		{
			Name = "RooftopPoolDeck",
			Y = 72,
			Description = "Visible rooftop pool strip, deck edge, palms and pergola create a resort-hotel identity without duplicating Waterfront Resort.",
		},
		{
			Name = "EventMarquee",
			Description = "Subtle illuminated hotel/event marquee near the entrance for match-day and concert-night identity.",
		},
		{
			Name = "RearServiceCourt",
			Face = "+Z",
			Description = "Discreet but visible hotel logistics/service entrance with delivery bays and screened back-of-house mass.",
		},
	},

	Facade = {
		Primary = "Warm limestone / pale concrete",
		Secondary = "Blue-green hotel glazing",
		RoomRhythm = "Regular narrow vertical room bays with shallow balcony ledges",
		Accent = "Warm amber and restrained teal",
		Rule = "The facade must read as hospitality: repeated room bays, warm lobby glazing, terraces and rooftop amenity spaces. Avoid office-style full-height curtain walls.",
	},

	Roof = {
		Rule = "Rooftop pool deck and pergola are visibly open and layered. No anonymous flat roof and no spire.",
	},

	Landscape = {
		Phase = 5,
		Includes = {
			"arrival palms",
			"porte-cochere planters",
			"hotel drop-off bollards",
			"sky-lounge planters",
			"rooftop pool planting",
			"rear service screening",
		},
	},

	ProposedGameplayMetadata = {
		TargetMaxHealth = 128000,
		EnergyType = "Thermal",
		InstallerTag = "KaijuHouse",
		ExternalCollapseIntegration = true,
	},

	PlannedDestructionGroups = {
		"D1_ArrivalPodium",
		"D2_LowerGuestRooms",
		"D3_UpperGuestRooms",
		"D4_SkyLounge",
		"D5_RooftopPoolDeck",
		"D6_EventMarqueeAndCanopies",
		"D7_ServiceCore",
	},

	VisualTarget = {
		Status = "Approved",
		Revision = "LargeCityStadiumHotel-VisualTarget-v1",
		Brief = {
			"premium Miami/Singapore event hotel beside stadium and arena",
			"78x64 footprint and 82-stud height",
			"broad hospitality podium with strong porte-cochere",
			"gently bowed main guest-room bar, not a flat rectangular slab",
			"regular hotel room windows with shallow balcony rhythm",
			"set-back panoramic sky lounge facing event district",
			"visible rooftop pool strip with palms and pergola",
			"warm limestone, blue-green glass, amber lobby light and restrained teal accents",
			"clear rear service/loading court",
			"daylight architectural concept board with front, three-quarter, side and rear cues",
			"not cyberpunk, not office, not apartment residential",
		},
	},



	QualityGateA = {
		Status = "Approved",
		ApprovedTarget = "LargeCityStadiumHotel-VisualTarget-v1",
		Notes = "Approved premium event-hotel concept with curved guest-room massing, strong porte-cochere arrival, sky lounge and rooftop pool deck.",
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
			TargetFootprint = Vector2.new(78, 64),
			TargetHeight = 82,
			GroundLevel = 0,
		},
		Podium = {
			Footprint = Vector2.new(74, 60),
			Center = Vector3.new(0, 8, 0),
			Height = 16,
			CornerRadiusApprox = 5,
			ArrivalCutWidth = 38,
			ArrivalCutDepth = 8,
		},
		GuestRoomBar = {
			Footprint = Vector2.new(66, 50),
			Center = Vector3.new(0, 37, 0),
			Height = 42,
			CurveDepth = 3.5,
			LongFaceRoomBayCount = 10,
			ShortFaceRoomBayCount = 6,
			BalconyBandCount = 7,
			BalconyProjection = 2.4,
		},
		SkyLounge = {
			Footprint = Vector2.new(54, 44),
			Center = Vector3.new(3, 64, -1),
			Height = 12,
			TerraceProjection = 4.5,
			PanoramicGlazing = true,
		},
		RooftopPoolDeck = {
			BaseY = 70,
			TopY = 82,
			DeckFootprint = Vector2.new(58, 46),
			PoolFootprint = Vector2.new(34, 9),
			PergolaHeight = 5.0,
			PergolaFinCount = 8,
			CanopyFootprint = Vector2.new(40, 20),
		},
		Facade = {
			GlassDepth = 0.6,
			RoomFrameDepth = 0.8,
			BalconySlabThickness = 0.65,
			BalustradeHeight = 1.35,
			BalustradeDepth = 0.24,
			Rule = "Repeated room bays and shallow balcony ledges sit visibly outside the facade; avoid full-height office curtain wall treatment.",
		},
		Entrance = {
			LobbyWidth = 32,
			LobbyHeight = 12,
			RecessDepth = 4.5,
			PorteCochereWidth = 42,
			PorteCochereDepth = 12,
			CanopyY = 14.0,
		},
		RearService = {
			DoorCount = 4,
			DoorWidth = 7,
			ServiceCanopy = true,
			Screening = true,
			Rule = "Rear hotel service/loading access must sit on the true +Z exterior and remain visible beyond any canopy.",
		},
		PartBudget = {
			TargetVisibleParts = 620,
			MaximumVisibleParts = 800,
		},
	},

	Phase2Status = {
		Status = "Approved",
		TargetRevision = "LargeCityStadiumHotel-VisualTarget-v1",
		QualityGateA = "Approved",
		ReviewFocus = {
			"premium event-hotel read",
			"gently bowed guest-room bar",
			"strong porte-cochere and lobby arrival",
			"regular room-bay rhythm with shallow balconies",
			"set-back panoramic sky lounge",
			"visible rooftop pool deck and pergola",
			"clear distinction from Uptown Residences and Waterfront Resort",
			"rear hotel service court integrated into massing",
		},
	},


	Phase4Status = {
		Status = "GoldenMasterReview",
		GeometryRevision = "LargeCityStadiumHotel-v3-AnchoredRoofBlade",
		QualityGateB = "Pending",
		ReviewFocus = {
			"overall premium event-hotel silhouette",
			"gently bowed guest-room facade",
			"regular room-window and shallow balcony rhythm",
			"clear porte-cochere and recessed lobby",
			"sky-lounge terrace visibly projected outside the facade",
			"rooftop pool deck reads clearly from street and elevated views",
			"rooftop pergola remains light and open",
			"rear service court is visibly on true +Z exterior",
			"no balcony, pool-deck or roof Z-fighting",
			"large roof blade with warm neon is grounded on the rooftop lounge deck",
		},
	},


	QualityGateB = {
		Status = "Pending",
		ApprovedGeometry = "LargeCityStadiumHotel-v3-AnchoredRoofBlade",
		Notes = "Convex guest-room facade yaw corrected after review found the window/balcony tangents visually bending inward. Recheck front and rear curvature before re-approval.",
		NextPhase = 5,
	},


	FacadeCurveOrientationFix = {
		Status = "InReview",
		GeometryRevision = "LargeCityStadiumHotel-v3-AnchoredRoofBlade",
		Notes = "Window, balcony slab and balustrade yaw now follow the outward/convex guest-room bow instead of visually suggesting a concave facade.",
	},

	Phase5Status = {
		Status = "InReview",
		Revision = "LargeCityStadiumHotel-Dressing-v5-RestoredPergolaSign",
		Includes = {
			"Stadium Hotel wordmark on visible porte-cochere fascia",
			"warm arrival accent, palms, planters and bollards",
			"sky-lounge terrace planting",
			"rooftop pool planting and loungers",
			"high-contrast rooftop pool signage",
			"rear hotel-service signage and bay numbers",
			"landscaping and pool-deck dressing sit directly on their supporting surfaces",
			"sky-lounge and rooftop vegetation is embedded into its planter soil rather than floating above it",
			"small rooftop pool sign uses the original light pergola bracket mounting; the large warm-lit roof blade is anchored directly to the rooftop lounge deck",
		},
		QualityGateC = "Pending",
	},

	Phase3Acceptance = {
		"Podium, guest-room bar, sky lounge and rooftop pool deck use deterministic dimensions tied to LC-54.",
		"Guest-room bay rhythm and shallow balconies clearly read as hotel architecture.",
		"Main room bar uses visible curvature/stepping and avoids a plain rectangular slab silhouette.",
		"Porte-cochere and lobby are clearly readable from the front.",
		"Sky lounge and rooftop pool deck remain visibly projected and distinct from the facade.",
		"Rear service court stays on the true +Z exterior.",
		"Seven destruction groups map to coherent architectural masses.",
		"Golden Master target remains below 800 visible parts.",
	},

	Phase1Acceptance = {
		"Building reads immediately as a premium hotel rather than office or apartment architecture.",
		"Main room block avoids a featureless rectangular slab through curvature, shallow stepping and room-bay rhythm.",
		"Arrival porte-cochere and lobby are unmistakable from the front.",
		"Sky lounge and rooftop pool create two clear hospitality amenity moments at Kaiju gameplay distance.",
		"Hotel remains visually distinct from Waterfront Resort and Uptown Residences.",
		"Rear service access is integrated into the architecture but clearly visible.",
		"Footprint and height remain compatible with LC-54.",
	},
}

return Specification
