-- Phase 3 technical breakdown for the approved Bastion-IV Colossus visual target.
local Color3 = Color3 or {
	fromRGB = function(r, g, b)
		return {R = r / 255, G = g / 255, B = b / 255}
	end,
}

return {
	SchemaVersion = 1,
	AssetName = "Bastion-IV Colossus",
	AssetId = "Bastion_IV_Colossus",
	AssetClass = "Guardian District-Defense Siege Platform",
	Tier = 4,
	City = "Large City",
	PipelinePhase = 3,
	Status = "TechnicalBreakdown",
	QualityGateA = "Approved",
	QualityGateB = "Pending",
	QualityGateC = "Pending",

	Role = {
		Primary = "DistrictDefenseAndSiegeSuppression",
		FleetBaseChassis = "Aegis-III Interceptor",
		CombatRead = "MobileCityFortress",
		MaxHealth = 8000000,
		ShieldPoints = 2400000,
		ArmorReduction = 0.38,
		StaggerResistance = 0.70,
		WalkSpeed = 14,
		DetectionRange = 220,
		AttackRange = 145,
	},

	Scale = {
		HeightStuds = 62,
		ShoulderWidthStuds = 38,
		StanceWidthStuds = 17,
		TorsoWidthStuds = 24,
		RailCannonLengthStuds = 31,
		RailCannonBoreStuds = 3.2,
		SiegeFistWidthStuds = 7,
		ShieldTowerEnvelopeStuds = {X = 7, Y = 14, Z = 7},
		ChestEmblemWidthStuds = 10,
	},

	Palette = {
		Chassis = Color3.fromRGB(31, 25, 24),
		Body = Color3.fromRGB(67, 58, 55),
		Armor = Color3.fromRGB(181, 153, 116),
		Accent = Color3.fromRGB(255, 151, 45),
		ChargeHot = Color3.fromRGB(255, 220, 139),
		DarkMetal = Color3.fromRGB(25, 23, 23),
	},

	RequiredAssemblies = {
		"Rig",
		"Armor",
		"Systems",
		"Equipment",
		"Hitboxes",
		"Metadata",
		"OffsetHead",
		"HeavyRailCannon",
		"SiegeFists",
		"DistrictShield",
	},

	Identity = {
		HeadCount = 1,
		HeadPlacement = "OffsetLeftOfCenter",
		VisorCount = 1,
		ChestEmblem = "LargeCentralOrangeChevron",
		ChestEmblemMustRemainUnobstructed = true,
		DerivedFromAegis = true,
		ReadableFleetJointDiscs = true,
	},

	Equipment = {
		HeavyRailCannon = {
			Count = 1,
			Mount = "RightShoulder",
			ReplacesArm = false,
			PrimarySupports = {"RightShoulderCradle", "UpperTorsoRecoilRail", "RearTorsoBrace"},
			IndependentYaw = true,
			LimitedElevation = true,
			VisibleChargeRails = 2,
			RecoilTravelStuds = 2.4,
			MuzzleMustClearHead = true,
		},
		SiegeFists = {
			Count = 2,
			Mount = "Hands",
			BothArmsRemainUsable = true,
			GroundSlamCapable = true,
			KnuckleSegmentsPerFist = 4,
		},
		DistrictShield = {
			PhysicalProjectors = 6,
			Mounts = {"LeftShoulderTower", "RightShoulderTower", "Chest", "LeftHip", "RightHip", "RearTorso"},
			RuntimeField = "DistrictDomeOrForwardSector",
			ShieldPoints = 2400000,
			PermanentFieldVisible = false,
			ProtectsNearbyStructures = true,
		},
	},

	Rig = {
		Standard = "GuardianFleetRigV1",
		ForwardAxis = "-Z",
		RequiredControlParts = 16,
		RequiredBaseMotors = 15,
		AsymmetricHeadMountAllowed = true,
		EquipmentMounts = {
			"HeavyRailCannonMount",
			"LeftSiegeFistMount",
			"RightSiegeFistMount",
			"LeftShieldTowerMount",
			"RightShieldTowerMount",
			"DistrictProjectorMount",
		},
	},

	Hitboxes = {
		"Head",
		"Torso",
		"LeftArm",
		"RightArm",
		"LeftLeg",
		"RightLeg",
		"HeavyRailCannon",
		"LeftShieldTower",
		"RightShieldTower",
		"DistrictProjector",
	},

	GeometryRules = {
		NoCoplanarOverlappingFaces = true,
		MinimumSurfaceOffsetStuds = 0.04,
		NoZFighting = true,
		UseLargeBeveledArmorPlates = true,
		AvoidTinyGreebles = true,
		ReadableJointDiscs = true,
		BuildFromPreviousFleetChassis = true,
		ExactlyOneOffsetHead = true,
		NoFloatingEquipment = true,
		BothSiegeFistsMustRemainVisible = true,
		RailCannonMustNotObstructChestEmblem = true,
	},

	PerformanceBudget = {
		MaxVisibleParts = 165,
		MaxGameplayHitboxes = 10,
		PermanentParticleEmitters = 0,
		PermanentLights = 0,
		PerPartScripts = 0,
		MaxTransientShieldPanels = 12,
		MaxSimultaneousRailProjectiles = 1,
		MaxGroundSlamDebris = 16,
	},

	AnimationRequirements = {
		ReuseFleetLocomotion = true,
		HeavyLocomotionVariant = true,
		RailAimChargeFireRecoil = true,
		SiegePunch = true,
		SiegeGroundSlam = true,
		DistrictShieldDeployAndBrace = true,
		DamageStaggerDefeatReset = true,
	},

	VisualTarget = {
		Version = 4,
		Approved = true,
		Description = "A monumental Aegis-derived mobile fortress with one offset visor head, a shoulder-mounted Heavy Rail Cannon, two free Siege Fists, tall district-shield towers, and a large unobstructed orange chest emblem.",
	},
}
