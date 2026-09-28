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
assert(parts==608 and lights==21, "Unexpected source counts: "..parts.." / "..lights)
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
 for _,p in ipairs(g:GetChildren()) do assert(p:GetAttribute("DestructionGroup")==g.Name) end
end
assert(total==parts-1)
assert(m.DestructionGroups.D1_Foyer:FindFirstChild("Entrance__Canopy"))
assert(m.DestructionGroups.D1_Foyer:FindFirstChild("Entrance__FrontFascia"))
local ownedLights=0
for _,p in ipairs(m.DestructionGroups:GetDescendants()) do if p:IsA("Light") then ownedLights=ownedLights+1 end end
assert(ownedLights==21)
m:SetAttribute("Health",123)
Installer.Attach(m)
assert(m:GetAttribute("Health")==123)
Installer.TestGroupCleanup(m)
local bad=fixture()
Instance.new("Part").Parent=bad
assert(not pcall(Installer.Attach,bad))
assert(not bad:FindFirstChild("DestructionGroups"))
assert(not CollectionService:HasTag(bad,"KaijuHouse"))
print("PASS: "..parts.." parts, 21 owned lights, three destruction groups, repeat attach preserves Health, unknown part rejected before mutation.")
-- Exercise the public Install path and resolve its actual sibling module names.
local oldTypeof=typeof
typeof=function(v) if getmetatable(v)==getmetatable(CFrame.new()) then return "CFrame" end;return oldTypeof(v) end
script={Parent={LargeCityCoastConventionCentreGoldenMaster=GoldenMaster,LargeCityCoastConventionCentreDressing=Dressing}}
require=function(module) assert(module==GoldenMaster or module==Dressing,"Unknown module dependency");return module end
local parent=Instance.new("Folder")
local installed=Installer.Install(parent,{GroundCFrame=CFrame.new(100,12,-50)})
assert(installed.Parent==parent and Installer.Validate(installed))
assert(not pcall(Installer.Install,parent),"Duplicate install should fail")
print("PASS: public Install resolves both modules; duplicate install rejected. Transform/render/physics not simulated.")

local root=installed.DestructionGroups
assert(root.D1_Foyer:FindFirstChild("Link__Roof"))
assert(root.D1_Foyer:FindFirstChild("Gallery__RearSlab"))
assert(root.D2_MainHall:FindFirstChild("RoofSegments__HallAPanel0"))
assert(root.D3_SecondHall:FindFirstChild("RoofSegments__HallBPanel7"))
assert(root.D2_MainHall:FindFirstChild("ConventionDressing__DeliveryLamp2"))
assert(root.D3_SecondHall:FindFirstChild("ConventionDressing__DeliveryLamp3"))
local lightCounts={}
local signs=0
for _,group in ipairs(root:GetChildren()) do
 local count=0
 for _,o in ipairs(group:GetDescendants()) do
  if o:IsA("Light") then count=count+1 end
  if o:IsA("SurfaceGui") then signs=signs+1;assert(group.Name=="D1_Foyer") end
 end
 lightCounts[group.Name]=count
end
assert(signs==1 and lightCounts.D1_Foyer==14 and lightCounts.D2_MainHall==4 and lightCounts.D3_SecondHall==3)
-- Test removing every section leaves only the non-visible pivot, not loose decoration.
local clean=installed:Clone()
for _,group in ipairs(clean.DestructionGroups:GetChildren()) do group:Destroy() end
for _,o in ipairs(clean:GetDescendants()) do
 if o:IsA("BasePart") then assert(o==clean.PrimaryPart) end
 assert(not o:IsA("Light") and not o:IsA("SurfaceGui"))
end
print("PASS: both roofs, hall lights and loading lights follow their hall; all-section cleanup leaves only pivot")
