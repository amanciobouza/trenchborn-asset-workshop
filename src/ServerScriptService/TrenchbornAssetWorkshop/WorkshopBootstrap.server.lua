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
local aegisSpecification = require(packageFolder:WaitForChild("AegisInterceptorSpecification"))
local aegisGoldenMaster = require(packageFolder:WaitForChild("AegisInterceptorGoldenMaster"))
local aegisDressing = require(packageFolder:WaitForChild("AegisInterceptorDressing"))
local aegisGameplayConfig = require(packageFolder:WaitForChild("AegisInterceptorGameplayConfig"))
local aegisGameplay = require(packageFolder:WaitForChild("AegisInterceptorGameplay"))
local aegisReactions = require(packageFolder:WaitForChild("AegisInterceptorReactions"))
local aegisSoundController = require(packageFolder:WaitForChild("AegisInterceptorSoundController"))
local bastionSpecification = require(packageFolder:WaitForChild("BastionColossusSpecification"))
local bastionGoldenMaster = require(packageFolder:WaitForChild("BastionColossusGoldenMaster"))
local bastionDressing = require(packageFolder:WaitForChild("BastionColossusDressing"))

workshop:SetAttribute("CurrentAsset", specification.AssetName)
workshop:SetAttribute("CurrentPhase", specification.PipelinePhase)
local model = goldenMaster.Build(workshop)
dressing.Apply(model)
model:PivotTo(model:GetPivot() + Vector3.new(-15, 0, 0))

local rigPrototype = model:Clone()
rigPrototype.Name = "Marshal_II_Roadblock_FleetRigPrototype"
rigPrototype:SetAttribute("AnimationPrototype", true)
rigPrototype.Parent = workshop
rigPrototype:PivotTo(model:GetPivot() + Vector3.new(50, 0, 0))
fleetRig.Apply(rigPrototype, {AnchorRoot = true})
gameplay.Attach(rigPrototype, gameplayConfig)
guardianSoundController.Attach(rigPrototype)

gameplay.Attach(model, gameplayConfig)
testHarness.Attach(workshop, model, gameplayConfig)

local comparisonWarden = wardenGoldenMaster.Build(workshop)
comparisonWarden.Name = "Warden_I_Shepherd_AnimationPrototype"
comparisonWarden:SetAttribute("AnimationPrototype", true)
comparisonWarden:PivotTo(comparisonWarden:GetPivot() + Vector3.new(16, 0, 50))
wardenDressing.Apply(comparisonWarden)
fleetRig.Apply(comparisonWarden, {AnchorRoot = true})
wardenGameplay.Attach(comparisonWarden, wardenGameplayConfig)
wardenSoundController.Attach(comparisonWarden)
fleetRigTestHarness.Attach(comparisonWarden)

workshop:SetAttribute("AnimationTestTarget", "Warden-I Shepherd")

local bastionModel = bastionGoldenMaster.Build(workshop)
bastionDressing.Apply(bastionModel)
local minimumVisibleY = math.huge
for _, item in ipairs(bastionModel:GetDescendants()) do
	if item:IsA("BasePart") and item.Transparency < 1 and not item:FindFirstAncestor("Hitboxes") then
		minimumVisibleY = math.min(minimumVisibleY, item.Position.Y - item.Size.Y * 0.5)
	end
end
local groundCorrection = minimumVisibleY < math.huge and -minimumVisibleY or 0
bastionModel:PivotTo(bastionModel:GetPivot() + Vector3.new(-55, groundCorrection, 85))
workshop:SetAttribute("CurrentAsset", bastionSpecification.AssetName)
workshop:SetAttribute("CurrentPhase", 5)
workshop:SetAttribute("QualityStatus", "Phase5_DressingReview")
workshop:SetAttribute("GoldenMasterReviewTarget", bastionModel.Name)
