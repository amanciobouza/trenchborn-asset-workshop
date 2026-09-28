local function fixture() local m=GoldenMaster.Build(nil);Dressing.Apply(m);return m end
local m=fixture();Installer.Attach(m);assert(Installer.Validate(m))
assert(#m.DestructionGroups:GetChildren()==2)
local order=Installer.GetCollapseOrder()
assert(order[1]=="D1_MainBuilding" and order[2]=="D2_TrackHall")
local counts={};local total=0
for i,name in ipairs(order) do
 local g=m.DestructionGroups[name];assert(g:GetAttribute("CollapseOrder")==i)
 counts[name]=#g:GetChildren();total=total+counts[name]
end
assert(total==961)
local main=m.DestructionGroups.D1_MainBuilding;local hall=m.DestructionGroups.D2_TrackHall
assert(main:FindFirstChild("StationDressing__ClockHour"))
assert(main.StationDressing__StationSign.Sign.Title.Text=="CENTRAL STATION")
assert(hall:FindFirstChild("Track1__Rail0") and hall:FindFirstChild("Track2__Rail1"))
assert(hall:FindFirstChild("Platforms__Left") and hall:FindFirstChild("HallRoof__Glass0_0"))
local function lights(g) local n=0;for _,o in ipairs(g:GetDescendants()) do if o:IsA("Light") then n=n+1 end end;return n end
assert(lights(main)==8 and lights(hall)==6)
m:SetAttribute("Health",123);Installer.Attach(m);assert(m:GetAttribute("Health")==123)
Installer.TestGroupCleanup(m)
-- Sequential structural removal on a detached copy: hall survives the first stage.
local copy=m:Clone();copy.DestructionGroups.D1_MainBuilding:Destroy()
assert(#copy.DestructionGroups.D2_TrackHall:GetChildren()==counts.D2_TrackHall)
copy.DestructionGroups.D2_TrackHall:Destroy()
for _,o in ipairs(copy:GetDescendants()) do assert(not o:IsA("BasePart") or o==copy.PrimaryPart) end
copy:Destroy()
local bad=fixture();Instance.new("Part").Parent=bad
assert(not pcall(Installer.Attach,bad));assert(not bad:FindFirstChild("DestructionGroups"))
print("PASS: main="..counts.D1_MainBuilding..", hall="..counts.D2_TrackHall.."; 14 owned lights, clock/sign, two-stage cleanup and Health preservation. Hierarchy only; game sequencing not tested.")
