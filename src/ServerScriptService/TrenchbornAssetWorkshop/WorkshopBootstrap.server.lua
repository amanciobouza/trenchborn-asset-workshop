local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
workshop:SetAttribute("Pipeline", "Trenchborn-7-Phase")
workshop:SetAttribute("QualityStatus", "Phase7_FinalInstaller")

local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local specification = require(packageFolder:WaitForChild("AssetSpecification"))
local installer = require(packageFolder:WaitForChild("WardenShepherdInstaller"))
local testHarness = require(packageFolder:WaitForChild("WardenShepherdTestHarness"))

workshop:SetAttribute("CurrentAsset", specification.AssetName)
workshop:SetAttribute("CurrentPhase", specification.PipelinePhase)
local model = installer.Install(workshop, {
	GroundCFrame = CFrame.new(0, 0, 0),
})
testHarness.Attach(workshop, model)
