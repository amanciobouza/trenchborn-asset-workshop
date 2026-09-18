-- Rojo compatibility shim for switching from the Kaiju workshop branch.
-- Summit Tower is the only active review on this branch.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packageFolder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop")
if packageFolder:FindFirstChild("LargeCitySummitTowerSpecification") then
	return
end
