local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityCoastConventionCentreGoldenMaster",10)
local dressing=folder and folder:WaitForChild("LargeCityCoastConventionCentreDressing",10)
if not source or not dressing then warn("Convention source missing. Check branch and Rojo sync; start a new Play session.");return end
for _,name in ipairs({"LargeCity_CoastConventionCentre_P4","LargeCity_CoastConventionCentre_P5"}) do
 if workspace:FindFirstChild(name) then warn("Existing convention centre preserved; use a fresh Play session.");return end
end
local model=require(source).Build(workspace)
require(dressing).Apply(model)
print("Coast Convention Centre P5 ready: Gate B approved; dressing review pending.")
