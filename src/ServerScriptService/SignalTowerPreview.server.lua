local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityTropicalSignalTowerGoldenMaster",10)
if not source then warn("Signal Tower source missing. Check branch and Rojo sync, then start Play again.");return end
if workspace:FindFirstChild("LargeCity_TropicalSignalTower_P4") then warn("Existing Signal Tower preserved; use a fresh Play session.");return end
require(source).Build(workspace)
print("Tropical Signal Tower P4: height400, cabin starts336, open platform, no elevator. Gate B pending.")
