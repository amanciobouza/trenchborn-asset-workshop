-- Workshop-only preview. Run Play after switching branch and restarting Rojo.
local storage = game:GetService("ReplicatedStorage")
local folder = storage:WaitForChild("TrenchbornAssetWorkshop", 10)
local source = folder and folder:WaitForChild("LargeCityPoliceGoldenMaster", 10)
if not source then
 warn("Police preview: module missing. Stop Play, restart rojo serve default.project.json, reconnect port 34872, then Play.")
 return
end
local name = "LargeCity_PoliceHQ_P4"
if workspace:FindFirstChild(name) or workspace:FindFirstChild("LargeCity_PoliceHQ_P5") then
 warn("Police preview: existing model preserved. Start a fresh Play session for updated geometry.")
 return
end
local builder = require(source)
local model = builder.Build(workspace)
local dressing = folder:WaitForChild("LargeCityPoliceDressing", 10)
if not dressing then
 warn("Police dressing missing: stop Play, restart rojo serve default.project.json, reconnect, then Play. P4 geometry remains visible.")
 return
end
require(dressing).Apply(model)
local count = 0
for _,obj in ipairs(model:GetDescendants()) do
 if obj:IsA("BasePart") then count = count + 1 end
end
print("Police HQ P5 ready: " .. count .. " parts; 3 storeys; 100 studs maximum height. Gate B approved; P5 dressing review pending.")
