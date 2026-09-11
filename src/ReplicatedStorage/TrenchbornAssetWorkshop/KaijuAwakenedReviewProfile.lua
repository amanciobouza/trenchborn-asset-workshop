--!strict
-- Quality Gate B review profile for Kaiju-I Primal Beast, evolution Stage 1.
return {
	ProfileId = "KAIJU-01-PRIMAL-BEAST-QGB",
	ModelName = "Kaiju_I_Primal_Beast_GoldenMaster",
	ExpectedAssetId = "KAIJU-01-PRIMAL-BEAST",
	ExpectedPipelinePhase = 4,
	GroundToleranceStuds = 0.15,
	MinimumHandGroundClearanceStuds = 7.5,
	MinimumHeightToDepthRatio = 1.25,
	MinimumClawDirectionDot = 0.68,
	MaximumArmTorsoPenetrationStuds = 0.7,
	RequiredRootParts = {
		"HumanoidRootPart", "LowerTorso", "UpperTorso", "Head", "Jaw",
		"LeftUpperArm", "LeftLowerArm", "LeftHand",
		"RightUpperArm", "RightLowerArm", "RightHand",
		"LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
		"RightUpperLeg", "RightLowerLeg", "RightFoot",
	},
	VisualReviewCriteria = {
		{
			Id = "visual.target-image-lineage",
			Prompt = "Compare Stage 1 with the approved five-stage volcanic titan target. It must clearly establish the shared lineage anchors without showing later-stage shoulder armor, evolved head armor, Caldera chest, or catastrophe crown.",
		},
		{
			Id = "visual.upright-s1",
			Prompt = "The creature reads as an upright dominant biped with an open massive chest. It is not permanently hunched and its arms never support the body.",
		},
		{
			Id = "visual.massive-proportions",
			Prompt = "The silhouette has a barrel torso, broad shoulders, long powerful arms to mid-thigh, extremely thick load-bearing digitigrade legs, broad feet, and no thin joints.",
		},
		{
			Id = "visual.predator-head",
			Prompt = "The head is an original bestial predator with a moderately extended blunt muzzle, broad cheeks, low yellow eyes, heavy brows, and a deep clearly separate lower jaw. Reject pig-like, cute, humanoid, pure dinosaur, or direct Godzilla heads.",
		},
		{
			Id = "visual.predator-paws",
			Prompt = "Hands read as broad animal paws with three primary digits plus one short side digit; all claws curve downward rather than projecting like ballerina toes.",
		},
		{
			Id = "visual.digitigrade-feet",
			Prompt = "Each foot shows three forward claws and one unobscured rear claw. Knees point forward and the high rear hock is clearly readable.",
		},
		{
			Id = "visual.segmented-tail",
			Prompt = "The heavy counterbalance tail is visibly constructed from overlapping tapered cylinder segments and remains above the ground.",
		},
		{
			Id = "visual.dorsal-count-and-shape",
			Prompt = "Exactly five distinct primary volcanic slab assemblies and exactly four distinct tail plates are visible with clear gaps. Every root sits outside the body surface and every plate projects away from the spine, pointing diagonally upward-backward rather than vertically along the back. Tail plates project outside their cylinder surfaces and follow the tail arc. The main rhythm rises to plates 3 and 4 and then falls. Reject stacked or interpenetrating plates, mushrooms, shells, crystals, wings, leaves, and crowded spikes.",
		},
		{
			Id = "visual.stage-one-restraint",
			Prompt = "Stage 1 remains mostly organic charcoal animal hide with only a small sternum hardening and minor limb hardening. Yellow eyes and faint yellow fissures are present, but complete energy sails and later-stage armor are absent.",
		},
		{
			Id = "visual.originality",
			Prompt = "Godzilla influence is limited to monumental presence and dorsal rhythm. Reject direct copying, full reptile scales, feline traits, mechanical Jaeger armor, metal, or blue/red/orange energy.",
		},
	},
}
