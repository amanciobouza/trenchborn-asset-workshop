local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityCentralStationInstaller",10)
if not source then warn("Station installer missing: check branch and Rojo sync, then restart Play.");return end
for _,name in ipairs({"LargeCity_CentralStation_P4","LargeCity_CentralStation_P5","LargeCity_CentralStation_L3"}) do
 if workspace:FindFirstChild(name) then warn("Existing station preserved; use a fresh Play session.");return end
end
local installer=require(source)
local model=installer.Install(workspace)
installer.Validate(model)
print("Station P6 ready: 64000 HP / Electric; D1 MainBuilding then D2 TrackHall. Main-game sequencing and Gate C pending.")
