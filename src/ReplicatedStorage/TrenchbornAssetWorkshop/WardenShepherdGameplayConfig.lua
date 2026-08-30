return {
	SchemaVersion = 1,
	TuningStatus = "Provisional",
	Guardian = {
		MaxHealth = 2500,
		Shield = 0,
		StaggerThreshold = 300,
		StaggerDuration = 1.2,
		DefeatDelay = 3.0,
	},
	Protection = {
		Radius = 30,
		RequiresLineOfSight = true,
		BlocksBuildingDamage = true,
	},
	Detection = {
		SearchlightRadius = 120,
		FieldOfViewDegrees = 80,
		ScanInterval = 0.5,
	},
	ShockBaton = {
		Range = 13,
		ArcDegrees = 75,
		Damage = 120,
		Cooldown = 2.4,
		Knockback = 38,
	},
	WarningPulse = {
		Radius = 28,
		Damage = 0,
		Cooldown = 18,
		Knockback = 65,
		TelegraphDuration = 1.1,
	},
}
