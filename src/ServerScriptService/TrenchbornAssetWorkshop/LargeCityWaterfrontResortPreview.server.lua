local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")

local specification = require(packageFolder:WaitForChild("LargeCityWaterfrontResortSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityWaterfrontResortGoldenMaster"))
local poolFacade = require(packageFolder:WaitForChild("LargeCityWaterfrontResortPoolFacade"))
local dressing = require(packageFolder:WaitForChild("LargeCityWaterfrontResortDressing"))
local signDressing = require(packageFolder:WaitForChild("LargeCityWaterfrontResortSignDressing"))
local dressingRefinement = require(packageFolder:WaitForChild("LargeCityWaterfrontResortDressingRefinement"))
local gameplayConfig = require(packageFolder:WaitForChild("LargeCityWaterfrontResortGameplayConfig"))
local gameplay = require(packageFolder:WaitForChild("LargeCityWaterfrontResortGameplay"))
local reviewControls = require(packageFolder:WaitForChild("LargeCityWaterfrontResortReviewControls"))

local function getSpawnGroundPosition()
	local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawn then
		return Vector3.new(
			spawn.Position.X,
			spawn.Position.Y + spawn.Size.Y * 0.5,
			spawn.Position.Z
		)
	end
	return Vector3.new(0, 0, 0)
end

local spawnGround = getSpawnGroundPosition()
local model = goldenMaster.Build(workshop)
poolFacade.Apply(model)
dressing.Apply(model)
signDressing.Apply(model)
dressingRefinement.Apply(model)

-- PoolsideFacade is the approved pool-facing facade layer from late Phase 4.
-- The initial dressing module also contains an experimental facade pass; discard
-- that duplicate so there is only one glazing layer and therefore no Z-fighting.
local dressingFolder = model:FindFirstChild("Dressing")
if dressingFolder then
	local duplicateFacade = dressingFolder:FindFirstChild("Facade")
	if duplicateFacade then duplicateFacade:Destroy() end
end

-- Place first, then snapshot the geometry in gameplay so Reset restores the
-- correct world-space CFrames for this review scene.
model:PivotTo(CFrame.new(spawnGround + Vector3.new(0, 0, 45)))
local gameplayApi = gameplay.Attach(model, gameplayConfig)
reviewControls.Attach(
	workshop,
	gameplayApi,
	spawnGround + Vector3.new(-9, 0.4, 7),
	gameplayConfig.ReviewDamageStep
)

workshop:SetAttribute("CurrentAsset", specification.AssetName or specification.AssetId)
workshop:SetAttribute("CurrentPhase", 6)
workshop:SetAttribute("QualityStatus", "Phase6_GameplayDestructionReview")
workshop:SetAttribute("QualityGateB", "Approved")
workshop:SetAttribute("QualityGateC", "Pending")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("ReviewScene", "HotelAtSpawn_GuardiansBehind_NoKaiju")

print("[Trenchborn Asset Workshop] Built Phase 6 Large City Waterfront Resort review:", model:GetFullName())
print("[Trenchborn Asset Workshop] Review controls: E = damage, R = reset at the pedestal near spawn")
