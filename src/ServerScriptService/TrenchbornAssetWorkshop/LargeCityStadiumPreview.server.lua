local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")

local specification = require(packageFolder:WaitForChild("LargeCityStadiumSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityStadiumGoldenMaster"))
local pong = require(packageFolder:WaitForChild("LargeCityStadiumPong"))

local function getSpawnGroundPosition()
	local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
	if spawn then
		return Vector3.new(
			spawn.Position.X,
			spawn.Position.Y + spawn.Size.Y * 0.5,
			spawn.Position.Z
		)
	end
	return Vector3.zero
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

local spawnGround = getSpawnGroundPosition()
local model = goldenMaster.Build(workshop)
model:PivotTo(CFrame.new(spawnGround + Vector3.new(180, 0, 0)) * CFrame.Angles(0, math.rad(90), 0))
model:SetAttribute("PongEnabled", true)
pong.Attach(model)

workshop:SetAttribute("CurrentAsset", specification.AssetId)
workshop:SetAttribute("CurrentPhase", 4)
workshop:SetAttribute("QualityStatus", "Phase4_GoldenMasterReview")
workshop:SetAttribute("QualityGateA", "Approved")
workshop:SetAttribute("QualityGateB", "Pending")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("ReviewScene", "LargeCityStadium_Isolated_Phase4")

print("[Trenchborn Asset Workshop] Built isolated Large City Stadium Golden Master for Quality Gate B review:", model:GetFullName())
