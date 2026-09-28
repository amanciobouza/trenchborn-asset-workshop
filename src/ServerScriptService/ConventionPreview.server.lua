local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityCoastConventionCentreInstaller",10)
if not source then warn("Convention installer missing. Check branch and Rojo sync; start a new Play session.");return end
for _,name in ipairs({"LargeCity_CoastConventionCentre_P4","LargeCity_CoastConventionCentre_P5","LargeCity_CoastConventionCentre_L3"}) do
 if workspace:FindFirstChild(name) then warn("Existing convention centre preserved; use a fresh Play session.");return end
end
require(source).Install(workspace)
print("Coast Convention Centre P6: 64000 HP, Electric, three sections. External gameplay / Gate C pending.")
