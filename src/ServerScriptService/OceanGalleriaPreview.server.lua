local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityOceanGalleriaGoldenMaster",10)
if not source then warn("Galleria source missing. Check branch and Rojo sync, then start Play again.");return end
if workspace:FindFirstChild("LargeCity_OceanGalleria_P4") then warn("Existing Galleria preserved; use a fresh Play session.");return end
require(source).Build(workspace)
print("Ocean Galleria P4 ready: three storeys, width192, atrium72; two rear delivery gates. Gate B pending.")
