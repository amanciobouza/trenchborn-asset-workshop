local function fixture()
 local m=GoldenMaster.Build(nil)
 Dressing.Apply(m)
 return m
end
local m=fixture()
local parts,lights=0,0
for _,p in ipairs(m:GetDescendants()) do
 if p:IsA("BasePart") then parts=parts+1 end
 if p:IsA("Light") then lights=lights+1 end
end
assert(parts==1164 and lights==5, "Unexpected source counts: "..parts.." / "..lights)
Dressing.Apply(m)
local again=0
for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then again=again+1 end end
assert(again==parts,"Dressing duplicated geometry")
Installer.Attach(m)
assert(Installer.Validate(m))
assert(#m.DestructionGroups:GetChildren()==1)
assert(#m.DestructionGroups.D1_WholeBuilding:GetChildren()==parts-1)
local ownedLights=0
for _,p in ipairs(m.DestructionGroups:GetDescendants()) do if p:IsA("Light") then ownedLights=ownedLights+1 end end
assert(ownedLights==5)
local signs=0
for _,obj in ipairs(m.DestructionGroups:GetDescendants()) do
 if obj:IsA("SurfaceGui") then signs=signs+1 end
end
assert(signs==1)
assert(m.DestructionGroups.D1_WholeBuilding.CourthouseDressing__CourthouseSign.Sign.Title.Text=="COURTHOUSE")
m:SetAttribute("Health",123)
Installer.Attach(m)
assert(m:GetAttribute("Health")==123)
Installer.TestGroupCleanup(m)
local bad=fixture()
Instance.new("Part").Parent=bad
assert(not pcall(Installer.Attach,bad))
assert(not bad:FindFirstChild("DestructionGroups"))
assert(not CollectionService:HasTag(bad,"KaijuHouse"))
print("PASS: "..parts.." parts, five owned lights and one sign, one destruction group, repeat attach preserves Health, unknown part rejected before mutation.")
