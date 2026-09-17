local Specification = {
	AssetId = "LargeCity_Stadium_L3",
	DisplayName = "Large City Stadium",
	City = "LargeCity",
	Phase = 2,
	QualityGate = "A-Pending",
	Style = "Singapore x Miami tropical metropolitan sports landmark",

	AssetBrief = {
		Purpose = "Major Large City landmark, high-value destruction target and visual anchor for the Sports + Uptown district.",
		Role = "Primary stadium of the metropolis; must be instantly readable as a stadium from kaiju distance and clearly distinct from an arena, mall or convention center.",
		Scale = "Very large L3 landmark sized to the approved LC-50 plot: approximately 250 x 170 studs with a silhouette height around 72 studs.",
		GameplayRead = "Open-bowl massing, roof ring/canopy, visible seating tiers, entrance gates and stadium-scale signage must survive distance compression.",
		NoInterior = true,
	},

	Location = {
		LayoutId = "LC-50",
		District = "Sports + Uptown",
		PlotCenter = Vector3.new(0, 24, 555),
		PlotFootprint = Vector2.new(250, 170),
		PlotYaw = 0,
		ApprovedBlockoutHeight = 72,
	},

	DesignIntent = {
		Silhouette = "Broad oval / rounded-rectangular stadium bowl with a strong elevated roof ring and four unmistakable structural corner or end pylons.",
		Front = "Grand civic arrival facade with broad stair/ramp language, multiple gate bays and a central stadium wordmark/scoreboard element.",
		Sides = "Tiered bowl geometry with repeated structural ribs rather than flat walls.",
		Roof = "Partial open roof canopy framing the pitch opening; not a fully sealed dome.",
		Rear = "Service/loading side with simplified but credible stadium infrastructure.",
		Landscape = "Palm-lined plazas, broad pedestrian hardscape and transit-friendly arrival zones; civic/sports character rather than resort landscaping.",
	},

	VisualLanguage = {
		PrimaryMaterials = {"light concrete", "white structural steel", "dark glass", "brushed metal"},
		Accent = "restrained teal/cyan with limited warm sports signage accents",
		Avoid = {"sealed futuristic dome", "generic rectangular box", "small-town football field", "resort aesthetic", "Mega City sci-fi language"},
		IdentityAnchors = {"open stadium bowl", "partial roof canopy", "visible seating tiers", "repeated structural ribs", "large civic entrance", "scoreboard / stadium signage"},
	},

	ProposedGameplayMetadata = {
		TargetMaxHealth = 256000,
		EnergyType = "Electric",
		InstallerTag = "KaijuHouse",
		ExternalCollapseIntegration = true,
		Rationale = "Stadium is one of the largest Large City landmarks; Electric fits floodlights, scoreboards and stadium infrastructure.",
	},

	PlannedDestructionGroups = {"D1_MainEntrance", "D2_LowerBowl", "D3_UpperBowl", "D4_RoofCanopyWest", "D5_RoofCanopyEast", "D6_ScoreboardAndPylons", "D7_ServiceAndConcourse"},

	Phase1Acceptance = {
		"Silhouette reads immediately as a stadium from gameplay distance.",
		"Asset fits inside the LC-50 250 x 170 stud plot without crowding Uptown Loop.",
		"Open-bowl and partial-roof language is visually distinct from the Uptown Arena.",
		"No modeled interior rooms are required; seating and concourse depth are exterior/structural illusions only.",
		"Seven destruction groups can later map to large coherent physical masses.",
		"Design remains buildable entirely in Roblox Studio with modular geometry.",
	},

	VisualTarget = {
		Status = "InReview",
		Revision = "LargeCityStadium-VisualTarget-v1",
		TargetRead = "A tropical metropolitan open-bowl stadium with a sculptural partial roof, visible seating terraces, strong structural ribs, four landmark pylons, monumental entrance gates and palm-lined civic plazas.",
		Camera = "Three-quarter aerial exterior view high enough to read the open bowl and roof opening, but low enough to judge facade rhythm and entrance scale.",
		Lighting = "Bright sunny Large City daylight, warm tropical atmosphere, clean blue sky.",
		NextGate = "Quality Gate A",
	},
}

return Specification
