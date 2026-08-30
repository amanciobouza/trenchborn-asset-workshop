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
local wardenGoldenMaster = require(packageFolder:WaitForChild("WardenShepherdGoldenMaster"))

workshop:SetAttribute("CurrentAsset", specification.AssetName)
workshop:SetAttribute("CurrentPhase", specification.PipelinePhase)
local model = goldenMaster.Build(workshop)
dressing.Apply(model)
model:PivotTo(model:GetPivot() + Vector3.new(-15, 0, 0))
gameplay.Attach(model, gameplayConfig)
testHarness.Attach(workshop, model, gameplayConfig)

local comparisonWarden = wardenGoldenMaster.Build(workshop)
comparisonWarden.Name = "Warden_I_Shepherd_Comparison"
comparisonWarden:SetAttribute("ComparisonReference", true)
comparisonWarden:PivotTo(comparisonWarden:GetPivot() + Vector3.new(16, 0, 0))
