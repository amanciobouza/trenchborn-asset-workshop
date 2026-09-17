local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")

local specification = require(packageFolder:WaitForChild("LargeCityCentralHospitalSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityCentralHospitalGoldenMaster"))

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

-- Keep the Phase 4 review close to spawn but outside the Central Hub arena and
-- away from the Guardian lineup behind the spawn. Final placement is handled
-- later by the installer / Large City layout integration.
local spawnGround = getSpawnGroundPosition()
local model = goldenMaster.Build(workshop)
model:PivotTo(CFrame.new(spawnGround + Vector3.new(180, 0, 0)) * CFrame.Angles(0, math.rad(90), 0))

workshop:SetAttribute("CurrentAsset", specification.AssetId)
workshop:SetAttribute("CurrentPhase", 4)
workshop:SetAttribute("QualityStatus", "Phase4_GoldenMasterReview")
workshop:SetAttribute("QualityGateA", "Approved")
workshop:SetAttribute("QualityGateB", "Pending")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("ReviewScene", "CentralHospital_NearSpawn_Phase4")

print("[Trenchborn Asset Workshop] Built Central Hospital Golden Master for Quality Gate B review:", model:GetFullName())
