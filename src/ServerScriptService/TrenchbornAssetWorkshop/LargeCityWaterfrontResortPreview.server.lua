local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")

local specification = require(packageFolder:WaitForChild("LargeCityWaterfrontResortSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityWaterfrontResortGoldenMaster"))

-- Phase 4 workshop preview: build the approved Large City resort automatically
-- when the Studio play session starts, matching the existing Kaiju preview flow.
local model = goldenMaster.Build(workshop)
model:PivotTo(CFrame.new(0, 0, 235))

workshop:SetAttribute("CurrentAsset", specification.AssetName or specification.AssetId)
workshop:SetAttribute("CurrentPhase", 4)
workshop:SetAttribute("QualityStatus", "Phase4_GeometryReview")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)

print("[Trenchborn Asset Workshop] Built Large City Waterfront Resort preview:", model:GetFullName())
