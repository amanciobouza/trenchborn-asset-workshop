local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityCentralStationGoldenMaster",10)
if not source then
 warn("Central Station source missing. Check branch and Rojo sync, then start Play again.")
 return
end
if workspace:FindFirstChild("LargeCity_CentralStation_P4") then
 warn("Existing Central Station preserved; use a fresh Play session to rebuild.")
 return
end
require(source).Build(workspace)
print("Central Station P4 ready: three portals, two tracks, two side platforms, hall crown64. Gate B pending.")
