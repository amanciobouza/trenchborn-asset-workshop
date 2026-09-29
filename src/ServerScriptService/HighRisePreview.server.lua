local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityTropicalHighRiseGoldenMaster",10)
local dressing=folder and folder:WaitForChild("LargeCityTropicalHighRiseDressing",10)
if not source or not dressing then warn("High-Rise source missing. Check branch and Rojo sync, then start a new Play session.");return end
for _,name in ipairs({"LargeCity_TropicalHighRise_P4","LargeCity_TropicalHighRise_P5"}) do
 if workspace:FindFirstChild(name) then warn("Existing High-Rise preserved; use a fresh Play session.");return end
end
local model=require(source).Build(workspace)
require(dressing).Apply(model)
print("Tropical High-Rise P5 ready: Gate B approved, dressing review pending.")
