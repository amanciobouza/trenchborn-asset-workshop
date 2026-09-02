-- Phase 3 technical breakdown for the approved Aegis-III Interceptor visual target.
local Color3 = Color3 or {
	fromRGB = function(r, g, b)
		return {R = r / 255, G = g / 255, B = b / 255}
	end,
}

return {
	SchemaVersion = 1,
	AssetName = "Aegis-III Interceptor",
	AssetId = "Aegis_III_Interceptor",
	AssetClass = "Guardian Interceptor Platform",
	Tier = 3,
	City = "City",
	PipelinePhase = 3,
	Status = "GoldenMasterApproved",
	QualityGateA = "Approved",
	QualityGateB = "Approved",
	QualityGateC = "Pending",

	Role = {
		Primary = "InterceptAndCounterattack",
		FleetBaseChassis = "Marshal-II Roadblock",
		CombatRead = "FastHeavyInterceptor",
		ShieldPoints = 150000,
	},

	Scale = {
		HeightStuds = 50,
		ShoulderWidthStuds = 30,
		StanceWidthStuds = 13,
		ForearmCannonLengthStuds = 12,
		MissilePodEnvelopeStuds = {X = 7, Y = 7, Z = 7},
		AegisChestWidthStuds = 15,
	},

	Palette = {
		Chassis = Color3.fromRGB(22, 28, 34),
		Body = Color3.fromRGB(43, 66, 112),
		Armor = Color3.fromRGB(174, 185, 196),
		Accent = Color3.fromRGB(62, 218, 255),
		Warning = Color3.fromRGB(235, 144, 48),
		DarkMetal = Color3.fromRGB(29, 35, 42),
	},

	RequiredAssemblies = {
		"Rig",
		"Armor",
		"Systems",
		"Equipment",
		"Hitboxes",
		"Metadata",
		"TwinIonCannons",
		"ShoulderMissiles",
		"DirectionalAegis",
	},

	Equipment = {
		TwinIonCannons = {
			Count = 2,
			Mount = "Forearms",
			IndependentTurretRotation = false,
			RecoilThroughArm = true,
		},
		ShoulderMissiles = {
			PodCount = 2,
			CellsPerPod = 8,
			Mount = "UpperTorsoShoulders",
			PodsRemainBelowMaximumHeight = false,
		},
		DirectionalAegis = {
			PhysicalEmitter = "CrystallineChestArray",
			RuntimeField = "ForwardDirectionalProjection",
			PhysicalPanels = 7,
			PermanentFieldVisible = false,
			ShieldPoints = 150000,
		},
	},

	Rig = {
		Standard = "GuardianFleetRigV1",
		ForwardAxis = "-Z",
		RequiredControlParts = 16,
		RequiredBaseMotors = 15,
		EquipmentMounts = {
			"LeftIonCannonMount",
			"RightIonCannonMount",
			"LeftMissilePodMount",
			"RightMissilePodMount",
			"AegisProjectorMount",
		},
	},

	Hitboxes = {
		"Head",
		"Torso",
		"LeftArm",
		"RightArm",
		"LeftLeg",
		"RightLeg",
		"LeftMissilePod",
		"RightMissilePod",
		"AegisProjector",
	},

	GeometryRules = {
		NoCoplanarOverlappingFaces = true,
		MinimumSurfaceOffsetStuds = 0.03,
		NoZFighting = true,
		UseLargeBeveledArmorPlates = true,
		AvoidTinyGreebles = true,
		ReadableJointDiscs = true,
		BuildFromPreviousFleetChassis = true,
		CrystallineAegisIsPhysicalChestIdentity = true,
	},

	PerformanceBudget = {
		MaxVisibleParts = 135,
		MaxGameplayHitboxes = 9,
		PermanentParticleEmitters = 0,
		PermanentLights = 0,
		PerPartScripts = 0,
		MaxSimultaneousMissiles = 8,
		MaxTransientAegisPanels = 3,
	},

	AnimationRequirements = {
		ReuseFleetLocomotion = true,
		TwinIonAimAndRecoil = true,
		ShoulderMissileLaunch = true,
		DirectionalAegisDeploy = true,
		DamageStaggerDefeatReset = true,
	},

	VisualTarget = {
		Version = 3,
		Approved = true,
		Description = "Powerful high-shouldered interceptor with large missile pods, twin forearm ion cannons, and a crystalline cyan Aegis chest array.",
	},
}
