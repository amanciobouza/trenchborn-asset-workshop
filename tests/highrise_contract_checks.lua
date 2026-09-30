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
assert(parts==2353 and lights==24, "Unexpected source counts: "..parts.." / "..lights)
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
assert(ownedLights==24)
m:SetAttribute("Health",123)
Installer.Attach(m)
assert(m:GetAttribute("Health")==123)
Installer.TestGroupCleanup(m)
local bad=fixture()
Instance.new("Part").Parent=bad
assert(not pcall(Installer.Attach,bad))
assert(not bad:FindFirstChild("DestructionGroups"))
assert(not CollectionService:HasTag(bad,"KaijuHouse"))
print("PASS: "..parts.." parts, 24 owned lights, one destruction group, repeat attach preserves Health, unknown part rejected before mutation.")

local oldTypeof=typeof
typeof=function(v) if getmetatable(v)==getmetatable(CFrame.new()) then return "CFrame" end;return oldTypeof(v) end
script={Parent={LargeCityTropicalHighRiseGoldenMaster=GoldenMaster,LargeCityTropicalHighRiseDressing=Dressing}}
require=function(module) assert(module==GoldenMaster or module==Dressing,"Unknown module dependency");return module end
local parent=Instance.new("Folder")
local installed=Installer.Install(parent,{GroundCFrame=CFrame.new(100,12,-50)})
assert(installed.Parent==parent and Installer.Validate(installed))
assert(not pcall(Installer.Install,parent),"Duplicate install should fail")
local group=installed.DestructionGroups.D1_WholeBuilding
assert(group:FindFirstChild("Crown__Column00"))
assert(group:FindFirstChild("Podium01__Floor"))
assert(group:FindFirstChild("Upper05__Floor"))
local copy=installed:Clone()
copy.DestructionGroups.D1_WholeBuilding:Destroy()
for _,o in ipairs(copy:GetDescendants()) do
 if o:IsA("BasePart") then assert(o==copy.PrimaryPart) end
 assert(not o:IsA("Light"))
end
print("PASS: public Install resolves modules, duplicate install refused, entire tower cleanup leaves only pivot")
