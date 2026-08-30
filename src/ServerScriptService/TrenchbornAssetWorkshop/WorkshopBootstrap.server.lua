local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
workshop:SetAttribute("Pipeline", "Trenchborn-7-Phase")
workshop:SetAttribute("QualityStatus", "Phase4_GoldenMaster")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local specification = require(packageFolder:WaitForChild("MarshalRoadblockSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("MarshalRoadblockGoldenMaster"))

workshop:SetAttribute("CurrentAsset", specification.AssetName)
workshop:SetAttribute("CurrentPhase", specification.PipelinePhase)
local model = goldenMaster.Build(workshop)
