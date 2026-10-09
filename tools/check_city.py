"""Run actual source modules in a numerical Lua hierarchy test double, not Roblox."""
from pathlib import Path
import re,json
r=Path(__file__).resolve().parents[1]
out=r/'tests/generated_city_test.lua'
def transpile(t):
 # Translate only augmented assignments for Lua 5.4 execution of the Luau source.
 t=t.replace('\t\tblock(\n\t\t\tpalm,\n\t\t\t"Leaf"', '\t\tlocal testLeaf=block(\n\t\t\tpalm,\n\t\t\t"Leaf"')
 t=t.replace(').CFrame *=', ')\n        testLeaf.CFrame *=')
 return re.sub(r'(\b[\w.]+)\s*([+*/-])=\s*([^\n]+)',lambda m:f'{m[1]} = {m[1]} {m[2]} ({m[3]})',t)

s=(r/'tests/roblox_math.lua').read_text()+'\nlocal CS=(function()\n'+(r/'tests/roblox_mock.lua').read_text()+'\nend)()\n'
s+='local modules=Instance.new("Folder");modules.Name="Modules"\nlocal sources={}\n'
for p in sorted((r/'src/ReplicatedStorage/TrenchbornAssetWorkshop').glob('*.lua')):
 s+=f'do local m=Instance.new("ModuleScript");m.Name={json.dumps(p.stem)};m.Parent=modules;sources[m]=[====[\n{transpile(p.read_text())}\n]====] end\n'
s+='''
local cache={}
require=function(module)
 assert(module and sources[module],"Unresolved module dependency")
 if cache[module] then return cache[module] end
 local env=setmetatable({script=module},{__index=_G})
 local chunk=assert(load(sources[module],module.Name,"t",env))
 local result=chunk();cache[module]=result;return result
end
'''
s+=(r/'tests/city_checks.lua').read_text()
out.write_text(s);print(out)
