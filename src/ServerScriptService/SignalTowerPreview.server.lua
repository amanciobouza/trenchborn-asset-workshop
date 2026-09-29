local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityTropicalSignalTowerInstaller",10)
if not source then warn("Signal Tower installer missing. Check branch and Rojo sync, then start Play again.");return end
for _,name in ipairs({"LargeCity_TropicalSignalTower_P4","LargeCity_TropicalSignalTower_P5","LargeCity_TropicalSignalTower_L3"}) do
 if workspace:FindFirstChild(name) then warn("Existing Signal Tower preserved; use a fresh Play session.");return end
end
require(source).Install(workspace)
print("Tropical Signal Tower P6: 64000 HP, Electric, whole-building group. External gameplay / Gate C pending.")
