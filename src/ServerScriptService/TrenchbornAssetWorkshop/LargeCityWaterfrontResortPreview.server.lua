local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")

local specification = require(packageFolder:WaitForChild("LargeCityWaterfrontResortSpecification"))
local installer = require(packageFolder:WaitForChild("LargeCityWaterfrontResortInstaller"))

local layout = workshop:WaitForChild("LargeCity_Layout_Blockout")
local resortAnchor = layout:WaitForChild("Markers"):WaitForChild("ResortAnchor")

-- Preview the exact Phase 7 package that will later be installed in the main game.
-- The main game's shared KaijuHouse destruction/collapse logic is intentionally not
-- duplicated in this workshop; Quality Gate C stays pending until the city is tested there.
local model = installer.Install(workshop, {
	CFrame = resortAnchor.CFrame,
})

local reservedPlot = layout:WaitForChild("BuildingPlots"):FindFirstChild("LC-01_ReservedForApprovedResort")
if reservedPlot then
	reservedPlot.Transparency = 1
	reservedPlot.CanCollide = false
end

local oldControls = workshop:FindFirstChild("LargeCityResortReviewControls")
if oldControls then oldControls:Destroy() end

workshop:SetAttribute("CurrentAsset", specification.AssetId)
workshop:SetAttribute("CurrentPhase", 7)
workshop:SetAttribute("QualityStatus", "FinalInstallerReady_ExternalGameTestPending")
workshop:SetAttribute("QualityGateA", "Approved")
workshop:SetAttribute("QualityGateB", "Approved")
workshop:SetAttribute("QualityGateC", "ExternalGameTestPending")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("ReviewScene", "LargeCityLayout_ResortOnWaterfrontPlot_NoKaiju")
workshop:SetAttribute("FinalInstallerModule", "LargeCityWaterfrontResortInstaller")

print("[Trenchborn Asset Workshop] Built Phase 7 Waterfront Resort through final installer:", model:GetFullName())
print("[Trenchborn Asset Workshop] Quality Gate C will be validated later in the main game with shared KaijuHouse collapse logic")
