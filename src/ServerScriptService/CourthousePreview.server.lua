local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityCourthouseGoldenMaster",10)
if not source then
 warn("Courthouse source missing. Check branch and Rojo sync, then start Play again.")
 return
end
if workspace:FindFirstChild("LargeCity_Courthouse_P4") then
 warn("Existing Courthouse preserved; use a fresh Play session to rebuild.")
 return
end
require(source).Build(workspace)
print("Courthouse P4 ready: six columns, plateau +8, wings 68 / centre 80 studs. Gate B pending.")
