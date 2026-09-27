local modules = game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop")
local Builder = require(modules:WaitForChild("LargeCityEmberlineGoldenMaster"))
local Dressing = require(modules:WaitForChild("LargeCityEmberlineDressing"))
local model = workspace:FindFirstChild("LargeCity_EmberlineResponseHQ_P5")
 or workspace:FindFirstChild("LargeCity_EmberlineResponseHQ_P4")
if not model then
 model = Builder.Build(workspace, {GroundCFrame = CFrame.new(0, 0, 0)})
end
Dressing.Apply(model)
print("Emberline P5 ready: materials, 3 badges, 12 lights, roof equipment, bollards and planters. Gameplay pending.")
