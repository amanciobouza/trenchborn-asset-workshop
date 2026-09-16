local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
workshop:SetAttribute("Pipeline", "Trenchborn-7-Phase")
workshop:SetAttribute("QualityStatus", "Phase6_GameplaySimulation")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local specification = require(packageFolder:WaitForChild("MarshalRoadblockSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("MarshalRoadblockGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("MarshalRoadblockDressing"))
local gameplayConfig = require(packageFolder:WaitForChild("MarshalRoadblockGameplayConfig"))
local gameplay = require(packageFolder:WaitForChild("MarshalRoadblockGameplay"))
local testHarness = require(packageFolder:WaitForChild("MarshalRoadblockTestHarness"))
local fleetRig = require(packageFolder:WaitForChild("GuardianFleetRig"))
local fleetRigTestHarness = require(packageFolder:WaitForChild("GuardianFleetRigTestHarness"))
local guardianSoundController = require(packageFolder:WaitForChild("GuardianSoundController"))
local wardenGoldenMaster = require(packageFolder:WaitForChild("WardenShepherdGoldenMaster"))
local wardenDressing = require(packageFolder:WaitForChild("WardenShepherdDressing"))
local wardenGameplayConfig = require(packageFolder:WaitForChild("WardenShepherdGameplayConfig"))
local wardenGameplay = require(packageFolder:WaitForChild("WardenShepherdGameplay"))
local wardenSoundController = require(packageFolder:WaitForChild("WardenShepherdSoundController"))
local bastionSpecification = require(packageFolder:WaitForChild("BastionColossusSpecification"))
local bastionGoldenMaster = require(packageFolder:WaitForChild("BastionColossusGoldenMaster"))
local bastionDressing = require(packageFolder:WaitForChild("BastionColossusDressing"))
local bastionGameplayConfig = require(packageFolder:WaitForChild("BastionColossusGameplayConfig"))
local bastionGameplay = require(packageFolder:WaitForChild("BastionColossusGameplay"))
local bastionSoundController = require(packageFolder:WaitForChild("BastionColossusSoundController"))
local sovereignSpecification = require(packageFolder:WaitForChild("SovereignApexSpecification"))
local sovereignGoldenMaster = require(packageFolder:WaitForChild("SovereignApexGoldenMaster"))
local sovereignDressing = require(packageFolder:WaitForChild("SovereignApexDressing"))
local sovereignGameplayConfig = require(packageFolder:WaitForChild("SovereignApexGameplayConfig"))
local sovereignGameplay = require(packageFolder:WaitForChild("SovereignApexGameplay"))
local sovereignSoundController = require(packageFolder:WaitForChild("SovereignApexSoundController"))
local sovereignRuntimeController = require(packageFolder:WaitForChild("SovereignApexRuntimeController"))

local function getSpawnGroundPosition()
	local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawn then
		return Vector3.new(
			spawn.Position.X,
			spawn.Position.Y + spawn.Size.Y * 0.5,
			spawn.Position.Z
		)
	end
	return Vector3.new(0, 0, 0)
end

local function groundCorrectionFor(model)
	local minimumVisibleY = math.huge
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 and not item:FindFirstAncestor("Hitboxes") then
			minimumVisibleY = math.min(minimumVisibleY, item.Position.Y - item.Size.Y * 0.5)
		end
	end
	return minimumVisibleY < math.huge and -minimumVisibleY or 0
end

local function faceCFrame(position, target)
	local flatTarget = Vector3.new(target.X, position.Y, target.Z)
	return CFrame.lookAt(position, flatTarget)
end

local spawnGround = getSpawnGroundPosition()
local hotelCenter = spawnGround + Vector3.new(0, 0, 45)
local guardianFocus = hotelCenter

-- This branch is now a building review scene. Kaiju preview models are intentionally
-- removed; the user reviews the current environment asset first, with Guardians staged behind it.
for _, child in ipairs(workshop:GetChildren()) do
	if child.Name:match("^Kaiju_") then
		child:Destroy()
	end
end
workshop:SetAttribute("KaijuBuildRevision", nil)
workshop:SetAttribute("KaijuPreviewDisabled", true)

workshop:SetAttribute("CurrentAsset", specification.AssetName)
workshop:SetAttribute("CurrentPhase", specification.PipelinePhase)
local model = goldenMaster.Build(workshop)
dressing.Apply(model)
model:PivotTo(faceCFrame(spawnGround + Vector3.new(-62, 0, 165), guardianFocus))

local rigPrototype = model:Clone()
rigPrototype.Name = "Marshal_II_Roadblock_FleetRigPrototype"
rigPrototype:SetAttribute("AnimationPrototype", true)
rigPrototype.Parent = workshop
rigPrototype:PivotTo(faceCFrame(spawnGround + Vector3.new(62, 0, 215), guardianFocus))
fleetRig.Apply(rigPrototype, {AnchorRoot = true})
gameplay.Attach(rigPrototype, gameplayConfig)
guardianSoundController.Attach(rigPrototype)

gameplay.Attach(model, gameplayConfig)
testHarness.Attach(workshop, model, gameplayConfig)

local comparisonWarden = wardenGoldenMaster.Build(workshop)
comparisonWarden.Name = "Warden_I_Shepherd_AnimationPrototype"
comparisonWarden:SetAttribute("AnimationPrototype", true)
comparisonWarden:PivotTo(faceCFrame(spawnGround + Vector3.new(-20, 0, 165), guardianFocus))
wardenDressing.Apply(comparisonWarden)
fleetRig.Apply(comparisonWarden, {AnchorRoot = true})
wardenGameplay.Attach(comparisonWarden, wardenGameplayConfig)
wardenSoundController.Attach(comparisonWarden)
fleetRigTestHarness.Attach(comparisonWarden)
workshop:SetAttribute("AnimationTestTarget", "Warden-I Shepherd")

local bastionModel = bastionGoldenMaster.Build(workshop)
bastionDressing.Apply(bastionModel)
local bastionGroundCorrection = groundCorrectionFor(bastionModel)
local bastionPosition = spawnGround + Vector3.new(25, bastionGroundCorrection, 180)
bastionModel:PivotTo(faceCFrame(bastionPosition, guardianFocus))
fleetRig.Apply(bastionModel, {AnchorRoot = true})
bastionGameplay.Attach(bastionModel, bastionGameplayConfig)
bastionSoundController.Attach(bastionModel)
fleetRigTestHarness.Attach(bastionModel)
workshop:SetAttribute("CurrentAsset", bastionSpecification.AssetName)
workshop:SetAttribute("CurrentPhase", 6)
workshop:SetAttribute("QualityStatus", "Phase6_StandardAnimationReview")
workshop:SetAttribute("GoldenMasterReviewTarget", bastionModel.Name)

local sovereignModel = sovereignGoldenMaster.Build(workshop)
sovereignDressing.Apply(sovereignModel)
local sovereignGroundCorrection = groundCorrectionFor(sovereignModel)
local sovereignPosition = spawnGround + Vector3.new(72, sovereignGroundCorrection, 180)
sovereignModel:PivotTo(faceCFrame(sovereignPosition, guardianFocus))
fleetRig.Apply(sovereignModel, {AnchorRoot = true})
sovereignGameplay.Attach(sovereignModel, sovereignGameplayConfig)
sovereignSoundController.Attach(sovereignModel)
sovereignRuntimeController.Attach(sovereignModel, sovereignModel:WaitForChild("Gameplay"))
fleetRigTestHarness.Attach(sovereignModel)
task.delay(2.0, function()
	if sovereignModel.Parent then
		sovereignDressing.PreviewEnergy(sovereignModel)
	end
end)
workshop:SetAttribute("CurrentAsset", sovereignSpecification.AssetName)
workshop:SetAttribute("CurrentPhase", 6)
workshop:SetAttribute("QualityStatus", "Phase6_StandardAnimationReview")
workshop:SetAttribute("GoldenMasterReviewTarget", sovereignModel.Name)
workshop:SetAttribute("AnimationTestTarget", sovereignSpecification.AssetName)
