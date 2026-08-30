local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
workshop:SetAttribute("Pipeline", "Trenchborn-7-Phase")
workshop:SetAttribute("QualityStatus", "Phase4_GoldenMaster")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local specification = require(packageFolder:WaitForChild("MarshalRoadblockSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("MarshalRoadblockGoldenMaster"))
local wardenGoldenMaster = require(packageFolder:WaitForChild("WardenShepherdGoldenMaster"))

workshop:SetAttribute("CurrentAsset", specification.AssetName)
workshop:SetAttribute("CurrentPhase", specification.PipelinePhase)
local model = goldenMaster.Build(workshop)
model:PivotTo(model:GetPivot() + Vector3.new(-15, 0, 0))

local comparisonWarden = wardenGoldenMaster.Build(workshop)
comparisonWarden.Name = "Warden_I_Shepherd_Comparison"
comparisonWarden:SetAttribute("ComparisonReference", true)
comparisonWarden:PivotTo(comparisonWarden:GetPivot() + Vector3.new(16, 0, 0))
