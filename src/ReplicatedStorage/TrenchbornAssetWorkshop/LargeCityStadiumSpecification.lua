local Specification = {
	AssetId = "LargeCity_Stadium_L3",
	DisplayName = "Large City Stadium",
	City = "LargeCity",
	Phase = 3,
	QualityGate = "A-Approved",
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

	VisualTarget = {
		Approved = true,
		Status = "Approved",
		Revision = "LargeCityStadium-VisualTarget-v1",
		ApprovedRead = "Grand tropical metropolitan open-bowl stadium with layered seating, a light partial roof ring, four tall structural pylons, a monumental glazed entrance and a large internal scoreboard.",
		Front = "Symmetrical civic arrival facade with broad glazed gate hall, stadium wordmark, strong vertical entrance piers and palm-lined plaza.",
		Sides = "Oval bowl with repeated concrete/steel ribs, exposed concourse glazing and visible stepped seating mass.",
		Rear = "Functional bowl elevation with repeated ribs and service/concourse openings; no second ceremonial entrance.",
		Roof = "Open center with a thin segmented canopy/ring around the bowl; white/light-metal structure, not a sealed dome.",
		Pylons = "Four tall tapered pylons at the main quadrant positions, clearly above the roof line and readable at kaiju distance.",
		InteriorRead = "Pitch opening, two-tier seating and one dominant scoreboard are visible from above; no modeled rooms or playable interior required.",
	},

	DesignIntent = {
		Silhouette = "Broad oval stadium bowl with a strong elevated roof ring and four unmistakable structural pylons.",
		Front = "Grand civic arrival facade with broad stair/ramp language, multiple gate bays and a central stadium wordmark.",
		Sides = "Tiered bowl geometry with repeated structural ribs rather than flat walls.",
		Roof = "Partial open roof canopy framing the pitch opening; not a fully sealed dome.",
		Rear = "Service/loading side with simplified but credible stadium infrastructure.",
		Landscape = "Palm-lined plazas, broad pedestrian hardscape and transit-friendly arrival zones.",
	},

	VisualLanguage = {
		PrimaryMaterials = {"light concrete", "white structural steel", "dark glass", "brushed metal"},
		Accent = "restrained teal/cyan with limited warm sports signage accents",
		Avoid = {"sealed futuristic dome", "generic rectangular box", "small-town football field", "resort aesthetic", "Mega City sci-fi language"},
		IdentityAnchors = {"open stadium bowl", "partial roof canopy", "visible seating tiers", "repeated structural ribs", "large civic entrance", "scoreboard / stadium signage", "four tall pylons"},
	},

	TechnicalBreakdown = {
		CoordinateSystem = {
			Pivot = "Ground center of stadium footprint",
			Front = "Local -Z faces main civic arrival plaza",
			Rear = "Local +Z faces service side",
			GroundY = 0,
		},
		Massing = {
			OuterBowl = {Footprint = Vector2.new(222, 146), LowerHeight = 26, UpperHeight = 47},
			PitchOpening = {Footprint = Vector2.new(108, 64), Center = Vector3.new(0, 0, 4)},
			MainEntrance = {Footprint = Vector2.new(70, 18), Center = Vector3.new(0, 14, -72), Height = 30},
			RearService = {Footprint = Vector2.new(82, 15), Center = Vector3.new(0, 9, 72), Height = 18},
		},
		Bowl = {
			SegmentCount = 64,
			LowerTierTopY = 24,
			UpperTierTopY = 43,
			ConcourseBandY = 18,
			StructuralRibCount = 32,
			Rule = "Use overlapping high-resolution shell segments so the bowl reads as one continuous oval; structural ribs remain a facade accent rather than bridging open gaps.",
		},
		Roof = {
			CanopyOuterFootprint = Vector2.new(218, 142),
			CanopyInnerOpening = Vector2.new(128, 78),
			CanopyY = 50,
			CanopyThickness = 2.4,
			SegmentCount = 64,
			Rule = "Roof remains visibly open over the pitch, uses overlapping high-resolution segments with continuous inner/outer fascias, and is split into coherent destroyable canopy masses.",
		},
		Pylons = {
			Height = 72,
			BaseSize = Vector3.new(9, 12, 12),
			TopSize = Vector3.new(4, 4, 5),
			Positions = {
				Vector3.new(-88, 36, -58), Vector3.new(88, 36, -58),
				Vector3.new(-88, 36, 58), Vector3.new(88, 36, 58),
			},
			Rule = "Pylons taper subtly inward and connect visually to the roof canopy.",
		},
		Scoreboard = {Size = Vector3.new(48, 16, 2.2), Center = Vector3.new(0, 38, 50)},
		FacadeModules = {
			EntranceGlazingSpan = 48,
			EntranceGlazingHeight = 18,
			RibWidth = 2.4,
			ConcourseGlassHeight = 7,
			FacadeStandOff = 0.3,
			Rule = "Glass and decorative overlays must stand clear of structural faces to avoid Z-fighting.",
		},
		LandscapeReferences = {PalmCount = 14, MainPlaza = Vector3.new(110, 0, 28), SidePlazaDepth = 16, Phase = 5},
		PartBudget = {TargetVisibleParts = 760, MaximumVisibleParts = 900},
	},

	PlannedPhase5 = {
		Facade = {
			ExteriorScreens = "Restore rectangular exterior window/screen panels as visible overlays outside the continuous bowl shell.",
			EntranceGlazing = "Widen the main entrance glass so the glazed facade spans the complete gate sector rather than only the central bays.",
		},
		PongEasterEgg = {
			Status = "ApprovedForPhase5",
			Purpose = "Small decorative stadium gag running on the football pitch; no gameplay reward or player interaction.",
			Presentation = "Minimal classic Pong projected/placed flat just above the pitch surface.",
			LeftPaddle = {Shape = "thin white bar", Size = Vector3.new(1.2, 0.25, 12)},
			RightPaddle = {Shape = "thin white bar", Size = Vector3.new(1.2, 0.25, 12)},
			Ball = {Shape = "small white square", Size = Vector3.new(2.2, 0.25, 2.2)},
			Motion = {
				Loop = true,
				Deterministic = true,
				HorizontalTravel = "Ball travels continuously between left and right paddles.",
				VerticalTravel = "Small changing Z component creates classic diagonal Pong motion and top/bottom bounces.",
				Paddles = "Paddles track the ball with deliberately simple smooth motion so the rally continues indefinitely.",
			},
			Audio = {
				Enabled = true,
				Style = "short simple retro Pong beep",
				Events = {"paddle bounce", "top/bottom boundary bounce"},
				Spatial = true,
				MaxDistance = 95,
				Volume = 0.18,
				Rule = "Keep the beep subtle enough that it reads as a nearby stadium Easter egg rather than global ambience.",
			},
			Runtime = {
				DecorativeOnly = true,
				ServerAuthoritative = false,
				PreferredExecution = "lightweight client/local visual animation when practical",
				DisableAttribute = "PongEnabled",
				DefaultEnabled = true,
				CleanupWithAsset = true,
			},
		},
	},

	ProposedGameplayMetadata = {
		TargetMaxHealth = 256000,
		EnergyType = "Electric",
		InstallerTag = "KaijuHouse",
		ExternalCollapseIntegration = true,
	},

	PlannedDestructionGroups = {
		"D1_MainEntrance", "D2_LowerBowl", "D3_UpperBowl", "D4_RoofCanopyWest",
		"D5_RoofCanopyEast", "D6_ScoreboardAndPylons", "D7_ServiceAndConcourse",
	},

	QualityGateA = {
		Status = "Approved",
		ApprovedTarget = "LargeCityStadium-VisualTarget-v1",
	},

	Phase3Acceptance = {
		"Outer bowl, pitch opening, roof ring, pylons, entrance and rear service mass have deterministic dimensions.",
		"Continuous overlapping oval shell, stepped seating tiers and structural ribs replace the previous gapped blockout read.",
		"Seven destruction groups map cleanly to large coherent physical masses.",
		"Golden Master target remains below 900 visible parts.",
		"No modeled interior rooms are required.",
	},
}

return Specification
