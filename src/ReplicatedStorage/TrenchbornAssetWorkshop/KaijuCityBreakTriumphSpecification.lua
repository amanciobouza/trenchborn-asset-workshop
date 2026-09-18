-- City Broken victory animation contract shared by all five Kaiju stages.
-- The actual pose is rendered procedurally by KaijuPresentation.lua.
local Specification = {
	Name = "CityBreakTriumph",
	DisplayName = "City Break Triumph",
	Version = 1,
	AppliesToEvolutionStages = {1, 2, 3, 4, 5},

	Intent = {
		"Make City Broken feel like a boss victory, not a generic emote.",
		"Kaiju rises to full height, opens the chest, roars upward and holds a dominant final silhouette.",
		"Movement remains bestial and weighty; never read as a human superhero or wrestler pose.",
	},

	Duration = 5.1,
	ControlLock = true,
	Trigger = {
		Production = "CityBroken",
		WorkshopPreview = "V key in Studio",
		ServerAPI = "controller.RequestVictory()",
	},

	Beats = {
		{
			Name = "ClaimGround",
			From = 0.00,
			To = 0.40,
			Description = "Heavy settling beat: weight drops slightly, feet stay planted, head remains low.",
		},
		{
			Name = "Rise",
			From = 0.35,
			To = 1.20,
			Description = "Chest opens, spine rises, shoulders spread and arms move away from the torso.",
		},
		{
			Name = "PreRoarTension",
			From = 1.10,
			To = 1.65,
			Description = "Head draws back, claws tense, dorsal energy builds and body tremor begins.",
		},
		{
			Name = "VictoryRoar",
			From = 1.65,
			To = 3.10,
			Description = "Jaw opens fully, head angles upward, torso expands and the arms form a broad dominant silhouette.",
		},
		{
			Name = "DominionHold",
			From = 3.10,
			To = 4.55,
			Description = "Roar ends into a poster-like victory stance with chest open and asymmetric arms.",
		},
		{
			Name = "Return",
			From = 4.55,
			To = 5.10,
			Description = "Jaw closes and energy settles while preserving the proud silhouette before returning to locomotion.",
		},
	},

	PoseTargetsDegrees = {
		-- Representative peak targets. KaijuPresentation blends these across the beats.
		Torso = {Pitch = 8, Yaw = 0, Roll = 0},
		Head = {Pitch = -24, Yaw = 5, Roll = -2},
		Jaw = {Pitch = -42, Yaw = 0, Roll = 0},
		LeftUpperArm = {Pitch = -24, Yaw = -12, Roll = 42},
		RightUpperArm = {Pitch = -18, Yaw = 10, Roll = -48},
		LeftForearm = {Pitch = -22, Yaw = 0, Roll = -6},
		RightForearm = {Pitch = -14, Yaw = 0, Roll = 8},
		LeftHand = {Pitch = -12, Yaw = -8, Roll = 0},
		RightHand = {Pitch = -8, Yaw = 8, Roll = 0},
		TailBase = {Pitch = 5, Yaw = 0, Roll = 0},
	},

	Presentation = {
		RoarAudio = "Layered low-pitched existing Kaiju impact/finisher assets for workshop preview; replaceable by final bespoke roar asset.",
		RoarShockwaveAt = 1.82,
		DorsalEnergyPeakFrom = 1.55,
		DorsalEnergyPeakTo = 3.15,
		GroundDustAt = 1.82,
		Camera = "No camera ownership in portable presentation. Main game may add City Broken camera treatment separately.",
	},

	Acceptance = {
		"Silhouette grows taller from beat 1 to beat 4.",
		"Chest is clearly more open than idle/walk.",
		"Head and jaw make the roar unmistakable from medium distance.",
		"Arms are broad and asymmetric, never a symmetric human victory pose.",
		"Feet remain planted; no sliding or locomotion during the sequence.",
		"Tail counterbalances the upper body and never whips like a dog tail.",
		"Animation ends cleanly back into the normal presentation state.",
	},
}

return Specification
