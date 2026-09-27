-- Isolated workshop preview, lifted 12 studs so a normal baseplate cannot fill the garage cut.
local storage=game:GetService("ReplicatedStorage")
local folder=storage:WaitForChild("TrenchbornAssetWorkshop",10)
local source=folder and folder:WaitForChild("LargeCityResidentialGoldenMaster",10)
if not source then
 warn("Residential preview: module missing. Stop Play, restart rojo serve default.project.json, reconnect port34872, then Play.")
 return
end
if workspace:FindFirstChild("LargeCity_ResidentialTower_P4") then
 warn("Residential preview: existing model preserved. Use a fresh Play session for updates.")
 return
end
local model=require(source).Build(workspace,{GroundCFrame=CFrame.new(0,12,0)})
local count=0
for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then count=count+1 end end
print("Residential Tower P4 ready: "..count.." parts, 14 storeys, 232 studs local height. Preview ground Y=12; garage ends 8 studs below ground. Gate B pending.")
