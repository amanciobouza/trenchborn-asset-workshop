--!strict
-- Phase 3 technical specification
-- Quality Gate A approved: volcanic titan evolution line
-- This specification supersedes the former Bound Chimera design direction.
return {
	SchemaVersion = 1,
	SpecificationId = "KAIJU-VOLCANIC-TITAN-PHASE-3",
	AssetClass = "Playable Kaiju Evolution Line",
	StageCount = 5,
	CurrentPipelinePhase = 3,
	QualityGateA = "Approved",
	QualityGateB = "Pending",
	QualityGateC = "Pending",

	Identity = {
		Theme = "An embodied primal catastrophe: volcanic pressure, storm force, and radioactive energy in animal form",
		GodzillaInfluence = "Light resemblance through monumental presence and upright dorsal-plate rhythm only",
		Differentiation = {
			Jaeger = "No technology, metal armor, perfect symmetry, or blue energy",
			TigerRonin = "No feline anatomy, agile silhouette, or red-orange energy",
		},
		ImmutableAnchors = {
			"UprightDominantBiped",
			"MassiveBarrelTorso",
			"BestialPredatorHead",
			"LongPowerfulFreeHangingArms",
			"MassiveDigitigradeLegs",
			"PredatorPaws",
			"SegmentedCylinderTail",
			"FivePrimaryDorsalAssemblies",
			"FourTailDorsalAssemblies",
			"YellowEyes",
			"YellowGreenPressureEnergy",
		},
	},

	Scale = {
		BaseHeightStuds = 30.0,
		StageHeightsStuds = {30.0, 33.6, 37.8, 42.9, 48.6},
		StageHeightMultipliers = {1.00, 1.12, 1.26, 1.43, 1.62},
		StageShoulderWidthMultipliers = {1.00, 1.25, 1.38, 1.58, 1.85},
		StageVolumeTargets = {1.00, 1.35, 1.80, 2.50, 3.60},
		Rule = "Every adjacent stage must read as clearly larger; width and mass grow faster than height",
		RuntimeRequirements = {
			"Stage-specific Motor6D offsets and HipHeight",
			"Camera distance and focus point scale with stage",
			"Independent gameplay hitboxes scale conservatively",
			"Attack origins and reach follow the evolved limb proportions",
			"Shared animation language uses stage-specific rig proportions",
		},
	},

	Anatomy = {
		Stance = "S1 upright neutral; temporary S2 forward attack posture",
		Arms = "Long, extremely powerful, free hanging to mid-thigh, never ground support",
		Hands = "Broad predator paws; three primary fingers plus one short side gripping digit; claws curve downward",
		Legs = "Extremely thick load-bearing digitigrade legs with forward knees and high rear hocks",
		Feet = "Three forward claws and one clearly visible rear claw per foot",
		Head = "K2 bestial predator; blunt extended muzzle, broad cheeks, low yellow eyes, deep separate lower jaw",
		Tail = "Heavy counterbalance built from visibly overlapping tapered cylinder parts and held above ground",
	},

	DorsalSystem = {
		PrimaryAssemblyCount = 5,
		TailAssemblyCount = 4,
		PrimaryRhythm = "Clear rise and fall; assemblies 3 and 4 form the tallest crown",
		GeometryRule = "Each later assembly may contain multiple broken layers but remains one anatomically distinct plate with visible gaps",
		ForbiddenShapes = {"Mushroom", "Shell", "Crystal", "Wing", "Leaf", "ThinTechnicalBlade"},
		EnergySails = {
			Definition = "Translucent yellow-to-radioactive-yellow-green pressure membranes suspended between adjacent dorsal assemblies",
			MainGapCount = 4,
			TailGapCount = 3,
			Rule = "Energy, never flesh, fabric, wing, or technological force field",
		},
	},

	SurfaceLanguage = {
		Body = "Thick matte charcoal leathery animal hide with a subtle desaturated olive undertone",
		Armor = "Asymmetrical porous broken volcanic stone growing naturally from the body",
		ClawsAndTeeth = "Matte worn bone",
		EnergySpectrum = "Yellow through radioactive yellow-green only",
		Eyes = "Constant saturated yellow",
		Forbidden = {"FullBodyScales", "Metal", "MechanicalArmor", "PerfectSymmetry"},
	},

	EvolutionStages = {
		{
			Stage = 1,
			Name = "Primal Beast",
			FeatureReveal = "Base animal",
			Geometry = "Restrained organic body, tiny sternum hardening, minimal forearm and knee hardening, simple dorsal slabs",
			Energy = "Yellow eyes and faint fissures; no complete energy sails",
		},
		{
			Stage = 2,
			Name = "Breaker",
			FeatureReveal = "Arms and shoulders",
			Geometry = "Huge volcanic shoulder plates, layered forearm breaker armor, broader paws, natural knuckle ridges",
			Energy = "New fissures concentrated in shoulders and forearms; short unstable arcs between dorsal gaps",
		},
		{
			Stage = 3,
			Name = "Maelstrom",
			FeatureReveal = "Head and jaw",
			Geometry = "Layered cheek plates, jaw-hinge growths, deeper lower jaw, split chin, heavy brow, temporal ridges, broad neck mantle",
			Energy = "New pressure fissures at jaw hinges and throat; small torn sail fragments between central plates",
		},
		{
			Stage = 4,
			Name = "Caldera",
			FeatureReveal = "Chest",
			Geometry = "Split sternum, deep vertical Caldera fissure, sweeping asymmetrical mineral ribs; earlier regions persist",
			Energy = "Bright internal chest pressure; four incomplete perforated main energy sails and first tail links",
		},
		{
			Stage = 5,
			Name = "Cataclysm Crown",
			FeatureReveal = "Dorsal crown and complete energy system",
			Geometry = "Five multilayer crown assemblies; 3 and 4 enormous; four evolved tail crowns; selective seismic lower-body reinforcement",
			Energy = "Four complete main sails, three tail sails, and a linked yellow-green pressure network across the entire anatomy",
		},
	},

	GeometryStrategy = {
		StandardParts = {
			"Invisible rig controls",
			"Motor6D joints",
			"Tail cylinders",
			"Attachments",
			"Simple independent gameplay hitboxes",
			"Early blockout volumes",
		},
		DraftMeshes = {
			"Torso and major muscle volumes",
			"Head and separate lower jaw",
			"Hands and feet",
			"Curved claws and teeth",
			"Volcanic armor modules",
			"Dorsal plate assemblies",
			"Energy-sail surfaces",
		},
		Modularity = {
			"Base head for stages 1 and 2",
			"Evolved head from stage 3",
			"Base torso through stage 3",
			"Caldera torso from stage 4",
			"Shoulder and forearm modules from stage 2",
			"Stage-specific dorsal modules",
		},
		PivotRules = {
			"Stable origin, scale, forward axis, and attachment names across revisions",
			"Jaw pivot at anatomical rear hinge",
			"Dorsal pivots at plate roots",
			"Armor pivots follow host limb joints",
			"Tail plate pivots follow their cylinder hosts",
		},
	},

	AssetIterationPolicy = {
		Phase4 = "Use Roblox materials, colors, Parts, and draft meshes; do not finalize UVs or PBR textures",
		MeshCheckpoints = {"Silhouette", "Anatomy", "EvolutionModules", "NearGateB", "ApprovedGeometry"},
		ReimportRule = "Reimport only controlled revisions of the same module with stable pivot and UV contract",
		NewAssetRule = "Create a new asset identity for fundamental topology, pivot, UV, or rig changes",
		SourceRule = "Version mesh source files in repository; Roblox IDs live in one central asset configuration",
		FallbackRule = "Missing mesh IDs produce reviewable blockout geometry and an explicit warning",
	},

	Phase5DressingPlan = {
		TextureSets = {
			TitanHide = "Leathery pores, broad folds, matte charcoal and olive variation",
			VolcanicArmor = "Porous broken stone, deep cracks, rough nonmetal surface",
			BoneAndClaw = "Matte irregular bone with worn tips",
			EnergySails = "Transparent ragged edges, yellow anchors, yellow-green interior, branching pressure veins",
		},
		EnergyConstruction = "Inset Neon geometry for readable fissures; transparent double-sided sail meshes for membranes",
		DeferredUntilGateB = true,
	},

	ReviewContract = {
		StageSilhouettes = {
			"Stage 1 reads as the base beast",
			"Stage 2 reads through arms and shoulders",
			"Stage 3 reads through head and jaw",
			"Stage 4 reads through the Caldera chest",
			"Stage 5 reads through the catastrophe crown",
		},
		HardChecks = {
			"Exactly five primary dorsal assemblies",
			"Exactly four tail dorsal assemblies",
			"Three forward and one visible rear claw per foot",
			"Hands remain above ground",
			"Upright neutral stance",
			"No permanent lights or particles in Phase 4",
			"Gameplay hitboxes remain separate from visible geometry",
		},
	},

	PerformanceBudget = {
		MaxVisiblePartsPerStage = 190,
		MaxGameplayHitboxesPerStage = 3,
		MaxPermanentLightsPhase4 = 0,
		MaxPermanentParticlesPhase4 = 0,
	},
}
