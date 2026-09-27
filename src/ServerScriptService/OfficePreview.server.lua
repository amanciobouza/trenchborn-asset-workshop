local ReplicatedStorage = game:GetService("ReplicatedStorage")
local folder = ReplicatedStorage:WaitForChild("TrenchbornAssetWorkshop", 10)
local source = folder and folder:WaitForChild("LargeCityOfficeGoldenMaster", 10)
local dressing = folder and folder:WaitForChild("LargeCityOfficeDressing", 10)
if not source or not dressing then
    warn("Office preview source missing. Check branch, git pull and Rojo sync connection, then start Play again.")
    return
end
if workspace:FindFirstChild("LargeCity_OfficeTower_P4") or workspace:FindFirstChild("LargeCity_OfficeTower_P5") then
    warn("Office preview already exists; preserved existing model. Use a fresh Play session to rebuild.")
    return
end
local model = require(source).Build(workspace, {GroundCFrame = CFrame.new()})
require(dressing).Apply(model)
local count = 0
for _, item in ipairs(model:GetDescendants()) do
    if item:IsA("BasePart") then count = count + 1 end
end
print(string.format("Office Tower P5 ready: %d parts; 18 storeys; roof 324 / ribs 328 studs; Gate B approved; dressing review pending.", count))
