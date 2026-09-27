local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityHotelGoldenMaster",10)
local dressing=folder and folder:WaitForChild("LargeCityHotelDressing",10)
if not source or not dressing then
 warn("City Hotel source missing. Check branch and Rojo sync, then start Play again.")
 return
end
if workspace:FindFirstChild("LargeCity_CityHotel_P4") or workspace:FindFirstChild("LargeCity_CityHotel_P5") then
 warn("Existing City Hotel preserved; use a fresh Play session to rebuild.")
 return
end
local model=require(source).Build(workspace)
require(dressing).Apply(model)
print("City Hotel P5 ready: 12 storeys, roof 204 / centre 208 studs, canopy clearance 20. Gate B approved; dressing review pending.")
