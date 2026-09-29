local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityTropicalSignalTowerGoldenMaster",10)
local dressing=folder and folder:WaitForChild("LargeCityTropicalSignalTowerDressing",10)
if not source or not dressing then warn("Signal Tower source missing. Check branch and Rojo sync, then start Play again.");return end
for _,name in ipairs({"LargeCity_TropicalSignalTower_P4","LargeCity_TropicalSignalTower_P5"}) do
 if workspace:FindFirstChild(name) then warn("Existing Signal Tower preserved; use a fresh Play session.");return end
end
local model=require(source).Build(workspace)
require(dressing).Apply(model)
print("Tropical Signal Tower P5: Gate B approved, dressing review pending.")
