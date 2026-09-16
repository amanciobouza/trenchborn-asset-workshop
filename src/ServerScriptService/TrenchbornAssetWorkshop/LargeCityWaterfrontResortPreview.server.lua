local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")

local specification = require(packageFolder:WaitForChild("LargeCityWaterfrontResortSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityWaterfrontResortGoldenMaster"))
local poolFacade = require(packageFolder:WaitForChild("LargeCityWaterfrontResortPoolFacade"))

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
model:PivotTo(CFrame.new(spawnGround + Vector3.new(0, 0, 45)))

workshop:SetAttribute("CurrentAsset", specification.AssetName or specification.AssetId)
workshop:SetAttribute("CurrentPhase", 4)
workshop:SetAttribute("QualityStatus", "Phase4_GeometryReview")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("ReviewScene", "HotelAtSpawn_GuardiansBehind_NoKaiju")

print("[Trenchborn Asset Workshop] Built Large City Waterfront Resort at spawn review area:", model:GetFullName())
