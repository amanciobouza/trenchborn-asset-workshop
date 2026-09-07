-- Quality Gate B review profile for Kaiju-I Bound Chimera.
-- Hard rules are evaluated by AssetValidator. Visual-only rules are exported
-- as review prompts for the image-based agent and never auto-approve the gate.
return {
	ProfileId = "KAIJU-01-BOUND-CHIMERA-QGB",
	ModelName = "Kaiju_I_Bound_Chimera_GoldenMaster",
	ExpectedAssetId = "KAIJU-01-BOUND-CHIMERA",
	ExpectedPipelinePhase = 4,
	GroundToleranceStuds = 0.12,
	MinimumHandGroundClearanceStuds = 8,
	MinimumHeightToDepthRatio = 1.35,
	MinimumClawDirectionDot = 0.7,
	MaximumArmTorsoPenetrationStuds = 0.65,
	RequiredRootParts = {
		"HumanoidRootPart", "LowerTorso", "UpperTorso", "Head",
		"LeftUpperArm", "LeftLowerArm", "LeftHand",
		"RightUpperArm", "RightLowerArm", "RightHand",
		"LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
		"RightUpperLeg", "RightLowerLeg", "RightFoot",
	},
	VisualReviewCriteria = {
		{
			Id = "visual.target-image-match",
			Prompt = "Compare against the supplied approved target image. The anatomy, posture, facial construction, proportions, and defining silhouette must clearly match; stylistic resemblance alone is insufficient.",
		},
		{
			Id = "visual.face-part-orientation",
			Prompt = "Using the face close-ups, verify that crown, muzzle, jaw, vents, and eyes are correctly oriented, symmetric where intended, and form a coherent non-deformed face.",
		},
		{
			Id = "visual.arms-clear-of-torso",
			Prompt = "Using both arm close-ups, verify that the arms attach at the shoulders but do not disappear into or pass through the torso volume.",
		},
		{
			Id = "visual.claw-orientation",
			Prompt = "Using both foot close-ups, verify that all three front claws point forward and the rear claw points backward; reject sideways, reversed, buried, or blunt cap-like claws.",
		},
		{
			Id = "visual.upright-not-hunched",
			Prompt = "The creature reads as upright and dominant, not hunched or supported by its arms.",
		},
		{
			Id = "visual.original-chimera-silhouette",
			Prompt = "The silhouette reads as an original chimera and preserves its established lineage anchors.",
		},
		{
			Id = "visual.shattered-storm-shields",
			Prompt = "The seven dorsal forms read as angular shattered storm shields, never mushrooms, shells, crystals, or simple spikes.",
		},
		{
			Id = "visual.massive-digitigrade-legs",
			Prompt = "The digitigrade legs look massive, load-bearing, and visually stronger than the short free-hanging arms.",
		},
	},
}
