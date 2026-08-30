local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
workshop:SetAttribute("Pipeline", "Trenchborn-7-Phase")
workshop:SetAttribute("QualityStatus", "Phase6_GameplayAndDestruction")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local specification = require(packageFolder:WaitForChild("AssetSpecification"))
local builder = require(packageFolder:WaitForChild("WardenShepherdGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("WardenShepherdDressing"))
local gameplayConfig = require(packageFolder:WaitForChild("WardenShepherdGameplayConfig"))
local gameplay = require(packageFolder:WaitForChild("WardenShepherdGameplay"))

workshop:SetAttribute("CurrentAsset", specification.AssetName)
workshop:SetAttribute("CurrentPhase", specification.PipelinePhase)
local model = builder.Build(workshop)
dressing.Apply(model)
gameplay.Attach(model, gameplayConfig)
