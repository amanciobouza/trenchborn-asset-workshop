local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityCoastConventionCentreGoldenMaster",10)
if not source then warn("Convention source missing. Check branch and Rojo sync; start a new Play session.");return end
if workspace:FindFirstChild("LargeCity_CoastConventionCentre_P4") then warn("Existing convention centre preserved; use a fresh Play session.");return end
require(source).Build(workspace)
print("Coast Convention Centre P4: two halls, heights56/48, setback16, three loading gates. Gate B pending.")
