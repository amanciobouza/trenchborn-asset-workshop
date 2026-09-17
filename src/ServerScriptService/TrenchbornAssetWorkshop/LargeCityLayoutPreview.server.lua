local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
local specification = require(packageFolder:WaitForChild("LargeCityLayoutSpecification"))
local goldenMaster = require(packageFolder:WaitForChild("LargeCityLayoutGoldenMaster"))

local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
local origin = CFrame.new(spawn and Vector3.new(spawn.Position.X, 0, spawn.Position.Z) or Vector3.zero)
local layout = goldenMaster.Build(workshop, {OriginCFrame = origin})

local centralHub = layout:WaitForChild("Markers"):WaitForChild("CentralHub")
if spawn then
	spawn.CFrame = CFrame.new(centralHub.Position + Vector3.new(0, spawn.Size.Y * 0.5 + 2, 0))
end

workshop:SetAttribute("CurrentAsset", specification.DisplayName)
workshop:SetAttribute("CurrentPhase", specification.Phase)
workshop:SetAttribute("QualityStatus", "Phase3_LayoutReview")
workshop:SetAttribute("LargeCityBuildingPlotCount", #specification.Buildings)
workshop:SetAttribute("LargeCityLayoutReviewTarget", layout.Name)

print("[Trenchborn Asset Workshop] Built Large City layout blockout with", #specification.Buildings, "building plots")
