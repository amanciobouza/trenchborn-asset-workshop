local folder = game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop", 10)
local source = folder and folder:WaitForChild("LargeCityOfficeInstaller", 10)
if not source then
 warn("Office installer missing: check branch and Rojo sync, then start Play again.")
 return
end
for _, name in ipairs({"LargeCity_OfficeTower_P4", "LargeCity_OfficeTower_P5", "LargeCity_OfficeTower_L3"}) do
 if workspace:FindFirstChild(name) then
  warn("Existing Office model preserved. Use a fresh Play session to rebuild.")
  return
 end
end
local installer = require(source)
local model = installer.Install(workspace)
installer.Validate(model)
print("Office P6 ready: 64000 HP / Electric / one whole-building group. Main-game tests (Gate C) pending.")
