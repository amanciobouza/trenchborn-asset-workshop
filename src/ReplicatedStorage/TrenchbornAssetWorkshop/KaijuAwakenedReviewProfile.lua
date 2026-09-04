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
	RequiredRootParts = {
		"HumanoidRootPart", "LowerTorso", "UpperTorso", "Head",
		"LeftUpperArm", "LeftLowerArm", "LeftHand",
		"RightUpperArm", "RightLowerArm", "RightHand",
		"LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
		"RightUpperLeg", "RightLowerLeg", "RightFoot",
	},
	VisualReviewCriteria = {
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
