local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityHotelInstaller",10)
if not source then
 warn("City Hotel installer missing. Check branch and Rojo sync, then start Play again.")
 return
end
for _,name in ipairs({"LargeCity_CityHotel_P4","LargeCity_CityHotel_P5","LargeCity_CityHotel_L3"}) do
 if workspace:FindFirstChild(name) then
  warn("Existing City Hotel preserved; use a fresh Play session to rebuild.")
  return
 end
end
local installer=require(source)
local model=installer.Install(workspace)
installer.Validate(model)
print("City Hotel P6 ready: 64000 HP / Electric / one whole-building group. Main-game tests (Gate C) pending.")
