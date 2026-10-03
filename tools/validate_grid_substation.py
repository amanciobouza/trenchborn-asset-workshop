"""Validate the real exported package, geometry matrices and Lua syntax off-engine.
Does not claim a Roblox Studio playtest. Linux liblua5.4 needed for syntax pass.
"""
from pathlib import Path
import ctypes, ctypes.util, json, math, struct, base64, xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
scene=json.loads((ROOT/'tmp/mega-city/grid-scene.json').read_text())
assert 150<len(scene)<=1400
for p in scene:
    assert all(math.isfinite(x) and x>0 for x in p['size'])
    m=p['matrix']
    for i in range(3):
        for j in range(3):
            assert abs(sum(m[k*3+i]*m[k*3+j] for k in range(3))-(i==j))<1e-8
root=ET.parse(ROOT/'packages/mega-city/13-grid-substation.rbxmx').getroot()
for u in root.findall('.//UDim2'):
    for key in ['XO','YO']:
        value=u.find(key).text
        assert str(int(value)) == value
parts=root.findall('.//Item[@class="Part"]')
assert len(parts)==len(scene)+1
refs=[x.attrib['referent'] for x in root.iter('Item')]
assert len(refs)==len(set(refs))
primary=root.find('./Item/Properties/Ref[@name="PrimaryPart"]').text
assert primary in refs
for p in parts:
    assert p.find('./Properties/bool[@name="Anchored"]').text=='true'
assert len(root.findall('.//Item[@class="SurfaceGui"]'))==6
assert len(root.findall('.//Item[@class="Script"]'))==1
# Round-trip attribute values, including gameplay metadata in edit mode.
b=base64.b64decode(root.find('./Item/Properties/BinaryString[@name="AttributesSerialize"]').text)
n=struct.unpack_from('<I',b)[0];off=4;attrs={}
for _ in range(n):
    size=struct.unpack_from('<I',b,off)[0];off+=4;key=b[off:off+size].decode();off+=size;typ=b[off];off+=1
    if typ==2:
        size=struct.unpack_from('<I',b,off)[0];off+=4;value=b[off:off+size].decode();off+=size
    elif typ==3:value=bool(b[off]);off+=1
    else:assert typ==6;value=struct.unpack_from('<d',b,off)[0];off+=8
    attrs[key]=value
assert off==len(b) and attrs['EnergyType']=='Electric' and attrs['MaxHealth']==1000000 and attrs['QualityGateB']=='Pending'
lib=ctypes.CDLL(ctypes.util.find_library('lua5.4'))
lib.luaL_newstate.restype=ctypes.c_void_p
lib.luaL_loadbufferx.argtypes=[ctypes.c_void_p,ctypes.c_char_p,ctypes.c_size_t,ctypes.c_char_p,ctypes.c_char_p]
lib.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.POINTER(ctypes.c_size_t)];lib.lua_tolstring.restype=ctypes.c_char_p
lib.lua_close.argtypes=[ctypes.c_void_p]
sources={str(p.relative_to(ROOT)):p.read_text() for p in (ROOT/'src').rglob('*.lua')}
sources['exported-runtime']=root.find('.//Item[@class="Script"]/Properties/ProtectedString').text
for name,src in sources.items():
    state=lib.luaL_newstate();data=src.encode()
    result=lib.luaL_loadbufferx(state,data,len(data),name.encode(),None)
    if result:raise AssertionError(lib.lua_tolstring(state,-1,None).decode())
    lib.lua_close(state)
print(json.dumps({'visibleParts':len(scene),'xmlParts':len(parts),'signs':6,'luaSyntaxChecked':len(sources),'attributes':'round-trip OK','studioPlaytest':False}))
# Regression: plates must sit fully in front of the radiator fins.
fins=[p for p in scene if p['name']=='RadiatorFin']
for sign in [p for p in scene if p['name']=='TransformerId']:
    assert sign['pos'][2]+sign['size'][2]/2 < min(p['pos'][2]-p['size'][2]/2 for p in fins)
arcs=[p for p in scene if 'lightningSegment' in p]
assert len(arcs)==64 and set(p['lightningSegment'] for p in arcs)==set(range(1,33))
assert all(not p['solid'] and p['material']=='Neon' for p in arcs)
assert len(root.findall('.//Item[@class="Part"]/Properties/BinaryString[@name="AttributesSerialize"]'))==64
print('Number clearance and four exported lightning paths: OK')
