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

-- Hospital review stays isolated from the Large City blockout. Phase 5 is approved;
-- Phase 6 destruction is intentionally deferred to the main game's shared collapse system.
local oldLayout = workshop:FindFirstChild("LargeCity_Layout_Blockout")
if oldLayout then oldLayout:Destroy() end

local spawnGround = getSpawnGroundPosition()
local model = goldenMaster.Build(workshop)
roofFix.Apply(model)
geometryRefinement.Apply(model)
dressing.Apply(model)
model:PivotTo(CFrame.new(spawnGround + Vector3.new(180, 0, 0)) * CFrame.Angles(0, math.rad(90), 0))

model:SetAttribute("AssetPhase", 6)
model:SetAttribute("Phase5DressingApproved", true)
model:SetAttribute("Phase6Status", "ExternalGameTestPending")
model:SetAttribute("QualityGateC", "Pending")
model:SetAttribute("ExternalCollapseIntegration", true)
model:SetAttribute("MaxHealth", specification.GameplayMetadata.TargetMaxHealth)
model:SetAttribute("EnergyType", specification.GameplayMetadata.EnergyType)
model:SetAttribute("InstallerTag", specification.GameplayMetadata.InstallerTag)

workshop:SetAttribute("CurrentAsset", specification.AssetId)
workshop:SetAttribute("CurrentPhase", 6)
workshop:SetAttribute("QualityStatus", "Phase6_ExternalGameplayTestPending")
workshop:SetAttribute("QualityGateA", "Approved")
workshop:SetAttribute("QualityGateB", "Approved")
workshop:SetAttribute("QualityGateC", "Pending")
workshop:SetAttribute("GoldenMasterReviewTarget", model.Name)
workshop:SetAttribute("ReviewScene", "CentralHospital_Isolated_Phase6_IntegrationPending")

print("[Trenchborn Asset Workshop] Central Hospital Phase 5 approved; Phase 6 shared collapse integration pending:", model:GetFullName())
