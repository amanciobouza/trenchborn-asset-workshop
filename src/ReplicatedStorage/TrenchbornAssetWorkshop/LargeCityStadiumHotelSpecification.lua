-- Phase 1 concept/specification for LC-54 Stadium Hotel.
-- Standalone building branch: no dependency on other Large City building branches.

local Specification = {
	AssetId = "LargeCity_StadiumHotel_L3",
	DisplayName = "Stadium Hotel",
	LayoutId = "LC-54",
	City = "LargeCity",
	District = "Uptown",
	BuildingType = "Hotel",
	Phase = 1,
	QualityGate = "A-Pending",
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
		Status = "Draft",
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
