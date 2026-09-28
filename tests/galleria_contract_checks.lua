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
assert(parts==1537 and lights==14, "Unexpected source counts: "..parts.." / "..lights)
Dressing.Apply(m)
local again=0
for _,p in ipairs(m:GetDescendants()) do if p:IsA("BasePart") then again=again+1 end end
assert(again==parts,"Dressing duplicated geometry")
Installer.Attach(m)
assert(Installer.Validate(m))
assert(#m.DestructionGroups:GetChildren()==3)
local total=0
for _,g in ipairs(m.DestructionGroups:GetChildren()) do
 print(g.Name..": "..#g:GetChildren().." parts")
 total=total+#g:GetChildren()
 for _,p in ipairs(g:GetChildren()) do assert(p:GetAttribute("PlannedDestructionGroup")==g.Name) end
end
assert(total==parts-1)
assert(m.DestructionGroups.D2_Atrium:FindFirstChild("Entrance__Canopy"))
assert(m.DestructionGroups.D2_Atrium:FindFirstChild("GalleriaDressing__GalleriaSign"))
local ownedLights=0
for _,p in ipairs(m.DestructionGroups:GetDescendants()) do if p:IsA("Light") then ownedLights=ownedLights+1 end end
assert(ownedLights==14)
m:SetAttribute("Health",123)
Installer.Attach(m)
assert(m:GetAttribute("Health")==123)
Installer.TestGroupCleanup(m)
local bad=fixture()
Instance.new("Part").Parent=bad
assert(not pcall(Installer.Attach,bad))
assert(not bad:FindFirstChild("DestructionGroups"))
assert(not CollectionService:HasTag(bad,"KaijuHouse"))
print("PASS: "..parts.." parts, 14 owned lights, three destruction groups, repeat attach preserves Health, unknown part rejected before mutation.")
-- Exercise the public Install path and resolve its actual sibling module names.
local oldTypeof=typeof
typeof=function(v) if getmetatable(v)==getmetatable(CFrame.new()) then return "CFrame" end;return oldTypeof(v) end
script={Parent={LargeCityOceanGalleriaGoldenMaster=GoldenMaster,LargeCityOceanGalleriaDressing=Dressing}}
require=function(module) assert(module==GoldenMaster or module==Dressing,"Unknown module dependency");return module end
local parent=Instance.new("Folder")
local installed=Installer.Install(parent,{GroundCFrame=CFrame.new(100,12,-50)})
assert(installed.Parent==parent and Installer.Validate(installed))
assert(not pcall(Installer.Install,parent),"Duplicate install should fail")
print("PASS: public Install resolves both modules; duplicate install rejected. Transform/render/physics not simulated.")
