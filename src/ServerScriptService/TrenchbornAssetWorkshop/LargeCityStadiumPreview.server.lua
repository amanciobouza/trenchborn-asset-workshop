local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")

local specification = require(packageFolder:WaitForChild("LargeCityStadiumSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityStadiumGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("LargeCityStadiumDressing"))
local pong = require(packageFolder:WaitForChild("LargeCityStadiumPong"))

local function getSpawnReference()
	local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawn then
		return spawn
	end
	return nil
end

local function getGroundYAt(x, z, spawn)
	local fallbackY = 0
	if spawn then
		-- SpawnLocations normally sit on top of the actual review floor.
		-- The old preview used the TOP of the spawn as ground, which lifted
		-- the entire stadium by half the spawn height.
		fallbackY = spawn.Position.Y - spawn.Size.Y * 0.5
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {workshop}

	local originY = (spawn and spawn.Position.Y or fallbackY) + 200
	local result = Workspace:Raycast(
		Vector3.new(x, originY, z),
		Vector3.new(0, -500, 0),
		params
	)

	if result then
		return result.Position.Y
	end
	return fallbackY
end

local function minimumVisibleY(model)
	local minimumY = math.huge
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			minimumY = math.min(minimumY, item.Position.Y - item.Size.Y * 0.5)
		end
	end
	return minimumY
end

-- Stadium review is isolated: remove stale blockout and any previously spawned
-- hospital model that may still exist in Studio from the preceding asset branch.
for _, name in ipairs({
	"LargeCity_Layout_Blockout",
	"LargeCity_CentralHospital_L3_GoldenMaster",
	"LargeCity_Stadium_L3_GoldenMaster",
}) do
	local old = workshop:FindFirstChild(name)
	if old then old:Destroy() end
end

local spawn = getSpawnReference()
local spawnPosition = spawn and spawn.Position or Vector3.zero
local targetX = spawnPosition.X + 180
local targetZ = spawnPosition.Z
local groundY = getGroundYAt(targetX, targetZ, spawn)

local model = goldenMaster.Build(workshop)
dressing.Apply(model)
model:PivotTo(CFrame.new(targetX, groundY, targetZ) * CFrame.Angles(0, math.rad(90), 0))

-- Final contact correction is based on the actual lowest visible stadium part,
-- so future Golden Master changes cannot re-introduce a floating gap.
local minY = minimumVisibleY(model)
if minY < math.huge then
	local contactOffset = groundY - minY + 0.02
	model:PivotTo(model:GetPivot() + Vector3.new(0, contactOffset, 0))
	model:SetAttribute("GroundContactCorrection", contactOffset)
end
model:SetAttribute("GroundContactY", groundY)

model:SetAttribute("PongEnabled", true)
pong.Attach(model)

workshop:SetAttribute("CurrentAsset", specification.AssetId)
workshop:SetAttribute("CurrentPhase", 5)
workshop:SetAttribute("QualityStatus", "Phase5_DressingReview")
workshop:SetAttribute("QualityGateA", "Approved")
workshop:SetAttribute("QualityGateB", "Approved")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("ReviewScene", "LargeCityStadium_Isolated_Phase5_DressingReview")

print("[Trenchborn Asset Workshop] Large City Stadium Phase 5 dressing ready for review:", model:GetFullName())
print("[Trenchborn Asset Workshop] Stadium ground contact Y/correction:", groundY, model:GetAttribute("GroundContactCorrection"))
