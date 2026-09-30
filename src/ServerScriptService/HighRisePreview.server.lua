local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityTropicalHighRiseInstaller",10)
if not source then warn("High-Rise installer missing. Check branch and Rojo sync, then start a new Play session.");return end
local installer=require(source)
if workspace:FindFirstChild(installer.ModelName) then warn("Existing High-Rise preserved; use a fresh Play session.");return end
local model=installer.Install(workspace)
installer.TestGroupCleanup(model)
print("Tropical High-Rise P6 ready: 256000 HP, Electric, one whole-building group. External gameplay tests pending.")
