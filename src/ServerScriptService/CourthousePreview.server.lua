local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCourthouseInstaller",10)
if not source then
 warn("Courthouse installer missing. Check branch and Rojo sync, then start Play again.")
 return
end
for _,name in ipairs({"LargeCity_Courthouse_P4","LargeCity_Courthouse_P5","LargeCity_Courthouse_L3"}) do
 if workspace:FindFirstChild(name) then
  warn("Existing Courthouse preserved; use a fresh Play session to rebuild.")
  return
 end
end
local installer=require(source)
local model=installer.Install(workspace)
installer.Validate(model)
print("Courthouse P6 ready: 32000 HP / Electric / one whole-building group. Main-game tests (Gate C) pending.")
