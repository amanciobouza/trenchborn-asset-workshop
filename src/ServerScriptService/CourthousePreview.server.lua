local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityCourthouseGoldenMaster",10)
local dressing=folder and folder:WaitForChild("LargeCityCourthouseDressing",10)
if not source or not dressing then
 warn("Courthouse source missing. Check branch and Rojo sync, then start Play again.")
 return
end
if workspace:FindFirstChild("LargeCity_Courthouse_P4") or workspace:FindFirstChild("LargeCity_Courthouse_P5") then
 warn("Existing Courthouse preserved; use a fresh Play session to rebuild.")
 return
end
local model=require(source).Build(workspace)
require(dressing).Apply(model)
print("Courthouse P5 ready: six columns, plateau +8, wings 68 / centre 80 studs. Gate B approved; dressing review pending.")
