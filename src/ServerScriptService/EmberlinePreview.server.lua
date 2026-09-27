local modules = game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop")
local Builder = require(modules:WaitForChild("LargeCityEmberlineGoldenMaster"))
local name = "LargeCity_EmberlineResponseHQ_P4"
if not workspace:FindFirstChild(name) then
 Builder.Build(workspace, {GroundCFrame = CFrame.new(0, 0, 0)})
end
print("Emberline P4 preview: Gate B pending; no gameplay integration attached.")
