local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local blockout = require(packageFolder:WaitForChild("KaijuEvolutionBlockout"))

local preview = blockout.Build(workshop, CFrame.new(0, 0, 145))
workshop:SetAttribute("CurrentAsset", "Kaiju Evolution Primitive Blockout")
workshop:SetAttribute("CurrentPhase", 4)
workshop:SetAttribute("QualityStatus", "Phase4_FiveStageProportionReview")
workshop:SetAttribute("GoldenMasterReviewTarget", preview.Name)

print("[Kaiju Evolution] Five-stage primitive blockout built | Awaiting proportion review")
