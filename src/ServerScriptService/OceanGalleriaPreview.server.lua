local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityOceanGalleriaGoldenMaster",10)
local dressing=folder and folder:WaitForChild("LargeCityOceanGalleriaDressing",10)
if not source or not dressing then warn("Galleria source missing. Check branch and Rojo sync, then start Play again.");return end
if workspace:FindFirstChild("LargeCity_OceanGalleria_P4") or workspace:FindFirstChild("LargeCity_OceanGalleria_P5") then warn("Existing Galleria preserved; use a fresh Play session.");return end
local model=require(source).Build(workspace)
require(dressing).Apply(model)
print("Ocean Galleria P5 ready: three storeys, width192, atrium72; two rear delivery gates. Gate B approved; dressing review pending.")
