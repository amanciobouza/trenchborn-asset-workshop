local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local blockout = require(packageFolder:WaitForChild("KaijuEvolutionBlockout"))

local PREVIEW_NAME = "Kaiju_Evolution_Primitive_Blockout"

local function removeLegacyPreview(instance: Instance)
	if instance.Name ~= PREVIEW_NAME then
		instance:Destroy()
	end
end

-- This branch is dedicated to the five-stage Kaiju review. Keep the workshop
-- clear even if an older bootstrap script tries to recreate a Guardian or an
-- obsolete Kaiju after this script has started.
for _, instance in ipairs(workshop:GetChildren()) do
	removeLegacyPreview(instance)
end
workshop.ChildAdded:Connect(function(instance)
	if instance.Name ~= PREVIEW_NAME then
		task.defer(removeLegacyPreview, instance)
	end
end)

local preview = blockout.BuildStage(workshop, 1, CFrame.new(0, 0, 145))
workshop:SetAttribute("CurrentAsset", "Kaiju Stage 1 - Primal Beast")
workshop:SetAttribute("CurrentPhase", 4)
workshop:SetAttribute("QualityStatus", "Phase4_Stage1ProportionReview")
workshop:SetAttribute("GoldenMasterReviewTarget", preview.Name)

print("[Kaiju Evolution] Stage 1 Primal Beast blockout built | Awaiting proportion review")
