local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
workshop:SetAttribute("Pipeline", "Trenchborn-7-Phase")
workshop:SetAttribute("QualityStatus", "Phase5_RobloxDressing")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local specification = require(packageFolder:WaitForChild("AssetSpecification"))
local builder = require(packageFolder:WaitForChild("WardenShepherdGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("WardenShepherdDressing"))

workshop:SetAttribute("CurrentAsset", specification.AssetName)
workshop:SetAttribute("CurrentPhase", specification.PipelinePhase)
local model = builder.Build(workshop)
dressing.Apply(model)
