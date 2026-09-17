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

-- This workshop intentionally stops before the production building-collapse logic.
-- Destruction integration is validated in the main game project, where the shared
-- house/component collapse controller already exists.
model:PivotTo(CFrame.new(spawnGround + Vector3.new(0, 0, 45)))

local oldControls = workshop:FindFirstChild("LargeCityResortReviewControls")
if oldControls then oldControls:Destroy() end

workshop:SetAttribute("CurrentAsset", specification.AssetName or specification.AssetId)
workshop:SetAttribute("CurrentPhase", 5)
workshop:SetAttribute("QualityStatus", "Phase5_Approved_Phase6ExternalIntegration")
workshop:SetAttribute("QualityGateB", "Approved")
workshop:SetAttribute("QualityGateC", "ExternalGameTestPending")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("ReviewScene", "HotelAtSpawn_GuardiansBehind_NoKaiju")
workshop:SetAttribute("Phase6ReviewDamageKey", nil)
workshop:SetAttribute("Phase6ReviewResetKey", nil)
workshop:SetAttribute("Phase6ReviewDamageStep", nil)

print("[Trenchborn Asset Workshop] Built approved dressed Large City Waterfront Resort:", model:GetFullName())
print("[Trenchborn Asset Workshop] Phase 6 collapse/destruction integration deferred to the main game project")
