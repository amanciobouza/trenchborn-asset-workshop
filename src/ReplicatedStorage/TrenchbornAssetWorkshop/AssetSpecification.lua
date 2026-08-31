-- Rückfall für Umgebungen ohne Roblox-API: der kopflose Spec-Prüfer (luau) lädt diese
-- Datei ebenfalls, kennt Color3 aber nicht. In Studio greift der echte Global, ausserhalb
-- diese Ersatzfassung -- die Zahlen bleiben in beiden Fällen dieselben.
local Color3 = Color3 or {
	fromRGB = function(r, g, b)
		return { R = r / 255, G = g / 255, B = b / 255 }
	end,
}

return {
	SchemaVersion = 1,
	AssetName = "Warden-I Shepherd",
	AssetId = "Warden_I_Shepherd",
	AssetClass = "Guardian Defense Platform",
	Tier = 1,
	City = "Village",
	PipelinePhase = 7,
	Status = "FinalInstaller",
	QualityGateA = "Approved",
	QualityGateB = "Approved",
	QualityGateC = "Approved",
	Scale = {
		HeightStuds = 42,
		ShoulderWidthStuds = 18,
		BatonLengthStuds = 15,
	},
	Palette = {
		Chassis = Color3.fromRGB(28, 35, 32),
		Body = Color3.fromRGB(91, 103, 92),
		Armor = Color3.fromRGB(171, 178, 151),
		Accent = Color3.fromRGB(92, 231, 151),
	},
	RequiredAssemblies = {
		"Rig",
		"Armor",
		"Systems",
		"Equipment",
		"Hitboxes",
		"Metadata",
	},
	GeometryRules = {
		NoCoplanarOverlappingFaces = true,
		MinimumSurfaceOffsetStuds = 0.03,
		NoZFighting = true,
		AvoidOrthogonalBoxSilhouette = true,
		UseTiltOrStepOnMajorArmor = true,
	},
	PerformanceBudget = {
		MaxVisibleParts = 110,
		MaxGameplayHitboxes = 6,
		PermanentParticleEmitters = 0,
		PermanentLights = 0,
		PerPartScripts = 0,
	},
	DressingRules = {
		UsesAdditionalBaseParts = false,
		TextLabelsScaled = true,
		PermanentLights = 0,
		PermanentParticles = 0,
	},
	ExcludedFromPhase = {},
}
