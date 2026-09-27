"""Generate a plain-Lua test harness from the actual P5 XML fixture.
Run: python3 tools/check_residential_contract.py > /tmp/residential-test.lua
Then: lua /tmp/residential-test.lua (Lua 5.4). Does not simulate Roblox physics.
"""
from pathlib import Path
import json,xml.etree.ElementTree as E
r=Path(__file__).resolve().parents[1]
q=json.dumps
print('local CollectionService = (function()\n'+(r/'tests/residential_contract_mock.lua').read_text()+'\nend)()')
print('local Installer = (function()\n'+(r/'src/ReplicatedStorage/TrenchbornAssetWorkshop/LargeCityResidentialInstaller.lua').read_text()+'\nend)()')
tree=E.parse(r/'dist/LargeCityResidentialTower_P5.rbxmx')
print('local function fixture()')
items=list(tree.iter('Item'));ids={id(e):i for i,e in enumerate(items)}
print('local n={}')
for e in items:
 i=ids[id(e)];name=e.find("Properties/string[@name='Name']").text
 print(f'n[{i}]=Instance.new({q(e.attrib["class"])});n[{i}].Name={q(name)}')
for e in items:
 for ch in e.findall('Item'):print(f'n[{ids[id(ch)]}].Parent=n[{ids[id(e)]}]')
pivot=next(i for i,e in enumerate(items) if e.attrib.get('referent')=='RBXPivot')
print(f'n[0].PrimaryPart=n[{pivot}];return n[0]\nend')
print('''
local model=fixture()
local beforeParts=0
for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then beforeParts=beforeParts+1 end end
assert(beforeParts==1222)
assert(Installer.Attach(model)==model)
assert(Installer.Validate(model))
assert(model:GetAttribute("MaxHealth")==64000 and model:GetAttribute("EnergyType")=="Electric")
local counts={};local total=0
for _,group in ipairs(model.DestructionGroups:GetChildren()) do
 counts[group.Name]=#group:GetChildren();total=total+#group:GetChildren()
end
assert(#model.DestructionGroups:GetChildren()==1 and total==1221)
assert(counts.D1_WholeBuilding==1221)
-- Lights and signs follow their host rather than a detached decoration bucket.
local fixtures={D1_WholeBuilding={8,0}}
for group,expected in pairs(fixtures) do
 local lights,signs=0,0
 for _,p in ipairs(model.DestructionGroups[group]:GetDescendants()) do
  if p:IsA("Light") then lights=lights+1 end
  if p:IsA("SurfaceGui") then signs=signs+1 end
 end
 assert(lights==expected[1] and signs==expected[2],group.." fixture ownership")
end
local count=#model:GetDescendants()
model:SetAttribute("Health",123)
assert(Installer.Attach(model)==model and #model:GetDescendants()==count)
assert(model:GetAttribute("Health")==123)
assert(Installer.TestGroupCleanup(model))
local bad=fixture()
local unknown=Instance.new("Part");unknown.Name="Unmapped";unknown.Parent=bad
assert(not pcall(Installer.Attach,bad))
assert(not bad:FindFirstChild("DestructionGroups"))
assert(not CollectionService:HasTag(bad,"KaijuHouse"))
assert(bad:GetAttribute("MaxHealth")==nil)
print("PASS: 1222 parts preserved; one whole-building owner; eight lights attached to hosts; idempotence preserves health; unknown geometry rejected before mutation.")
''')
