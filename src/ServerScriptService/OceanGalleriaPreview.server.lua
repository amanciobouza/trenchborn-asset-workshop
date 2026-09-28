local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityOceanGalleriaInstaller",10)
if not source then warn("Galleria installer missing. Check branch and Rojo sync, then start Play again.");return end
for _,name in ipairs({"LargeCity_OceanGalleria_P4","LargeCity_OceanGalleria_P5","LargeCity_OceanGalleria_L3"}) do
 if workspace:FindFirstChild(name) then warn("Existing Galleria preserved; use a fresh Play session.");return end
end
require(source).Install(workspace)
print("Ocean Galleria P6: 64000 HP, Electric, three sections. External gameplay / Gate C pending.")
