local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")

local specification = require(packageFolder:WaitForChild("LargeCityCentralHospitalSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityCentralHospitalGoldenMaster"))
local roofFix = require(packageFolder:WaitForChild("LargeCityCentralHospitalRoofFix"))
local geometryRefinement = require(packageFolder:WaitForChild("LargeCityCentralHospitalGeometryRefinement"))
local dressing = require(packageFolder:WaitForChild("LargeCityCentralHospitalDressing"))

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

-- Hospital review stays isolated from the Large City blockout.
local oldLayout = workshop:FindFirstChild("LargeCity_Layout_Blockout")
if oldLayout then oldLayout:Destroy() end

local spawnGround = getSpawnGroundPosition()
local model = goldenMaster.Build(workshop)
roofFix.Apply(model)
geometryRefinement.Apply(model)
dressing.Apply(model)
model:PivotTo(CFrame.new(spawnGround + Vector3.new(180, 0, 0)) * CFrame.Angles(0, math.rad(90), 0))

workshop:SetAttribute("CurrentAsset", specification.AssetId)
workshop:SetAttribute("CurrentPhase", 5)
workshop:SetAttribute("QualityStatus", "Phase5_DressingReview")
workshop:SetAttribute("QualityGateA", "Approved")
workshop:SetAttribute("QualityGateB", "Approved")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("ReviewScene", "CentralHospital_Isolated_Phase5")

print("[Trenchborn Asset Workshop] Built dressed Central Hospital for Phase 5 review:", model:GetFullName())
