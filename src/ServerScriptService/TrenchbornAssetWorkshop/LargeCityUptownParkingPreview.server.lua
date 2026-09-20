local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")

local specification = require(packageFolder:WaitForChild("LargeCityUptownParkingSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityUptownParkingGoldenMaster"))
local dressing = require(packageFolder:WaitForChild("LargeCityUptownParkingDressing"))

local function getSpawnReference()
	return Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
end

local function getGroundYAt(x, z, spawn)
	local fallbackY = 0
	if spawn then
		fallbackY = spawn.Position.Y - spawn.Size.Y * 0.5
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {workshop}
	params.RespectCanCollide = true

	local originY = (spawn and spawn.Position.Y or fallbackY) + 250
	local hit = Workspace:Raycast(Vector3.new(x, originY, z), Vector3.new(0, -600, 0), params)
	return hit and hit.Position.Y or fallbackY
end

local function minimumVisibleY(model)
	local minimum = math.huge
	for _, item in ipairs(model:GetDescendants()) do
		if item:IsA("BasePart") and item.Transparency < 1 then
			local cf = item.CFrame
			local h = item.Size * 0.5
			local extent = math.abs(cf.RightVector.Y) * h.X
				+ math.abs(cf.UpVector.Y) * h.Y
				+ math.abs(cf.LookVector.Y) * h.Z
			minimum = math.min(minimum, cf.Position.Y - extent)
		end
	end
	return minimum
end

for _, child in ipairs(workshop:GetChildren()) do
	child:Destroy()
end

local spawn = getSpawnReference()
local spawnPosition = spawn and spawn.Position or Vector3.zero
local targetX = spawnPosition.X + 145
local targetZ = spawnPosition.Z
local groundY = getGroundYAt(targetX, targetZ, spawn)

local model = goldenMaster.Build(workshop)
dressing.Apply(model)
model:PivotTo(
	CFrame.new(targetX, groundY, targetZ)
		* CFrame.Angles(0, math.rad(specification.TechnicalBreakdown.CoordinateSystem.LayoutYaw), 0)
)

local minY = minimumVisibleY(model)
if minY < math.huge then
	local contactOffset = groundY - minY + 0.02
	model:PivotTo(model:GetPivot() + Vector3.new(0, contactOffset, 0))
	model:SetAttribute("GroundContactCorrection", contactOffset)
end

model:SetAttribute("GroundContactY", groundY)
model:SetAttribute("ReviewScene", "LargeCityUptownParking_Isolated_Phase6_ExternalGameTestPending")

workshop:SetAttribute("Pipeline", "Trenchborn-7-Phase")
workshop:SetAttribute("CurrentAsset", specification.AssetId)
workshop:SetAttribute("CurrentPhase", 6)
workshop:SetAttribute("QualityStatus", "Phase6_ExternalGameTestPending")
workshop:SetAttribute("QualityGateA", "Approved")
workshop:SetAttribute("QualityGateB", "Approved")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("StandaloneBuildingBranch", true)

print("[Trenchborn Asset Workshop] Uptown Parking visual review approved; external game test pending:", model:GetFullName())
print("[Trenchborn Asset Workshop] Uptown Parking ground contact Y/correction:", groundY, model:GetAttribute("GroundContactCorrection"))
