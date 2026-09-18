local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")

local specification = require(packageFolder:WaitForChild("LargeCityUptownArenaSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityUptownArenaGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("LargeCityUptownArenaDressing"))

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

for _, name in ipairs({
	"LargeCity_Layout_Blockout",
	"LargeCity_CentralHospital_L3_GoldenMaster",
	"LargeCity_Stadium_L3_GoldenMaster",
	"LargeCity_UptownArena_L3_GoldenMaster",
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

local minY = minimumVisibleY(model)
if minY < math.huge then
	local contactOffset = groundY - minY + 0.02
	model:PivotTo(model:GetPivot() + Vector3.new(0, contactOffset, 0))
	model:SetAttribute("GroundContactCorrection", contactOffset)
end
model:SetAttribute("GroundContactY", groundY)

workshop:SetAttribute("CurrentAsset", specification.AssetId)
workshop:SetAttribute("CurrentPhase", 6)
workshop:SetAttribute("QualityStatus", "Phase6_ExternalGameplayTestPending")
workshop:SetAttribute("QualityGateA", "Approved")
workshop:SetAttribute("QualityGateB", "Approved")
workshop:SetAttribute("QualityGateC", "Pending")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("ReviewScene", "LargeCityUptownArena_Isolated_Phase6_IntegrationPending")

model:SetAttribute("Phase5DressingApproved", true)
model:SetAttribute("Phase6Status", "ExternalGameTestPending")
model:SetAttribute("QualityGateC", "Pending")
model:SetAttribute("ExternalCollapseIntegration", true)

print("[Trenchborn Asset Workshop] Uptown Arena Phase 5 approved; Phase 6 shared collapse integration pending:", model:GetFullName())
print("[Trenchborn Asset Workshop] Arena ground contact Y/correction:", groundY, model:GetAttribute("GroundContactCorrection"))
