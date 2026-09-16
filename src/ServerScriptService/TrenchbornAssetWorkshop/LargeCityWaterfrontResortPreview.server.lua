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

-- Place the hotel directly in the central review area near the player spawn.
-- Its entrance is on local -Z; offsetting the pivot +45 studs leaves the entrance
-- only a short walk from SpawnLocation while keeping the spawn itself unobstructed.
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

model:PivotTo(CFrame.new(spawnGround + Vector3.new(0, 0, 45)))

workshop:SetAttribute("CurrentAsset", specification.AssetName or specification.AssetId)
workshop:SetAttribute("CurrentPhase", 5)
workshop:SetAttribute("QualityStatus", "Phase5_DressingReview")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("ReviewScene", "HotelAtSpawn_GuardiansBehind_NoKaiju")

print("[Trenchborn Asset Workshop] Built dressed Large City Waterfront Resort at spawn review area:", model:GetFullName())
