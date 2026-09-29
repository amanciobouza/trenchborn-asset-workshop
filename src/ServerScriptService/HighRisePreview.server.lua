local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityTropicalHighRiseGoldenMaster",10)
if not source then warn("High-Rise source missing. Check branch and Rojo sync, then start a new Play session.");return end
if workspace:FindFirstChild("LargeCity_TropicalHighRise_P4") then warn("Existing High-Rise preserved; use a fresh Play session.");return end
require(source).Build(workspace)
print("Tropical High-Rise P4: 22 storeys, height380, two8Stud setbacks, open crown. Gate B pending.")
