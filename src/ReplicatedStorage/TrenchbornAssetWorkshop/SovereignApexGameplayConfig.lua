return {
	SchemaVersion = 1,
	TuningStatus = "Provisional",
	Guardian = {
		MaxHealth = 32000000,
		ArmorReduction = 0.28,
		StaggerThreshold = 2600000,
		StaggerDuration = 1.15,
	},
	ApexLanceThrust = {
		Range = 34, Damage = 145000, KnockbackStuds = 20,
		ImpactDelay = 0.56, RuntimeDuration = 1.28, Cooldown = 3.4,
	},
	ApexLanceCut = {
		Range = 42, ArcDegrees = 125, Damage = 195000, KnockbackStuds = 28,
		ImpactDelay = 0.61, RuntimeDuration = 1.42, Cooldown = 5.2,
	},
	ApexLanceBeam = {
		Range = 230, Damage = 420000, KnockbackStuds = 34,
		TelegraphDuration = 1.18, RuntimeDuration = 2.25, Cooldown = 12,
	},
	HunterDrones = {
		Range = 210, DamagePerWave = 110000, WaveCount = 3,
		FirstImpactDelay = 3.85, WaveInterval = 1.12, RuntimeDuration = 9.4, Cooldown = 18,
	},
	SovereignLock = {
		Range = 170, BarrierPoints = 8000000, MovementMultiplier = 0.58,
		ActivationDelay = 2.1, ActiveDuration = 4.35, RuntimeDuration = 9.2, Cooldown = 28,
	},
}
