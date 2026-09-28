local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityCentralStationGoldenMaster",10)
local dressing=folder and folder:WaitForChild("LargeCityCentralStationDressing",10)
if not source or not dressing then
 warn("Central Station source missing. Check branch and Rojo sync, then start Play again.")
 return
end
if workspace:FindFirstChild("LargeCity_CentralStation_P4") or workspace:FindFirstChild("LargeCity_CentralStation_P5") then
 warn("Existing Central Station preserved; use a fresh Play session to rebuild.")
 return
end
local model=require(source).Build(workspace)
require(dressing).Apply(model)
print("Central Station P5 ready: three portals, two tracks, two side platforms, hall crown64. Gate B approved; dressing review pending.")
