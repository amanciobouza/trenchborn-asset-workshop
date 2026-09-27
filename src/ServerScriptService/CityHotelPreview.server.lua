local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityHotelGoldenMaster",10)
if not source then
 warn("City Hotel source missing. Check branch and Rojo sync, then start Play again.")
 return
end
if workspace:FindFirstChild("LargeCity_CityHotel_P4") then
 warn("Existing City Hotel preserved; use a fresh Play session to rebuild.")
 return
end
require(source).Build(workspace)
print("City Hotel P4 ready: 12 storeys, roof 204 / centre 208 studs, canopy clearance 20. Gate B pending.")
