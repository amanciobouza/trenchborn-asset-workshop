# Regression checks for server-authorized workshop footfalls.
import ctypes,ctypes.util
from pathlib import Path
wd=Path(__file__).resolve().parents[1]
s=(wd/'src/ReplicatedStorage/TrenchbornAssetWorkshop/KaijuStageFourTraversal.lua').read_text()
finite=s[s.index(' local function finite(v)'):s.index(' local report=')]
report=s[s.index(' local report='):s.index(' local heartbeat=')]
code=r'''
local vector={}
vector.__index=function(v,k) if k=='Magnitude' then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end end
vector.__sub=function(a,b) return setmetatable({X=a.X-b.X,Y=a.Y-b.Y,Z=a.Z-b.Z},vector) end
Vector3={new=function(x,y,z) return setmetatable({X=x,Y=y,Z=z},vector) end}
local frame={};frame.__index=frame
frame.__mul=function(a,b) return CFrame.new(a.Position.X+b.Position.X,a.Position.Y+b.Position.Y,a.Position.Z+b.Position.Z) end
function frame:PointToObjectSpace(p) return p-self.Position end
CFrame={new=function(x,y,z) return setmetatable({Position=Vector3.new(x,y,z)},frame) end}
function typeof(v) return getmetatable(v)==vector and 'Vector3' or type(v) end
Enum={Material={Air='Air'}}
local time=10;os.clock=function() return time end
local character={};local player={Character=character};local scale=1;local rootHeight=0;local kneeHeight=10
local root={Position=Vector3.new(0,0,-5),CFrame=CFrame.new(0,0,-5),AssemblyLinearVelocity=Vector3.new(0,0,-10),Anchored=false}
local humanoid={Health=100,FloorMaterial='Ground'}
local attrs={JumpPhase='Idle',ComboStep=0}
local model={GetAttribute=function(_,key)return attrs[key] end}
local feet={Left={X=-3,Z=0,Size=Vector3.new(3,1,4)},Right={X=3,Z=0,Size=Vector3.new(3,1,4)}}
local lastAny=-math.huge;local lastStep={Left=-math.huge,Right=-math.huge}
local lastPosition={Left=Vector3.new(0,0,0),Right=Vector3.new(0,0,0)}
local calls=0
local combat={StepImpact=function(cf,size,height) calls=calls+1;assert(height==10 and size.X==3) end}
local handler
local remote={OnServerEvent={Connect=function(_,fn) handler=fn;return {} end}}
'''+finite+report+r'''
handler({},'Left',Vector3.new(-3,0,-5));assert(calls==0)
handler(player,'Left',Vector3.new(3,0,-5));assert(calls==0)
handler(player,'Left',Vector3.new(0/0,0,-5));assert(calls==0)
humanoid.FloorMaterial='Air';handler(player,'Left',Vector3.new(-3,0,-5));assert(calls==0)
humanoid.FloorMaterial='Ground';attrs.SpecialAttackLocked='Focus';handler(player,'Left',Vector3.new(-3,0,-5));assert(calls==0)
attrs.SpecialAttackLocked=nil
handler(player,'Left',Vector3.new(-3,0,-5));assert(calls==1)
handler(player,'Left',Vector3.new(-3,0,-5));assert(calls==1)
time=12;handler(player,'Left',Vector3.new(-3,0,-5));assert(calls==1)
root.Position=Vector3.new(0,0,-10);root.CFrame=CFrame.new(0,0,-10)
handler(player,'Right',Vector3.new(3,0,-10));assert(calls==2)
'''
c=(wd/'src/ReplicatedStorage/TrenchbornAssetWorkshop/KaijuStageOneCombat.lua').read_text()
step=c[c.index('\tlocal function stepImpact('):c.index('\tkaiju.Destroying:Once(cancel)')]
code+=r'''
local targets={
 {Model='left house',Parts={{X=-3}},Height=7},
 {Model='gap house',Parts={{X=0}},Height=7},
 {Model='medium house',Parts={{X=-3}},Height=14}}
local function traversalTargets() return targets end
local hits={}
local function handle(kind,_,target) assert(kind=='Step');hits[target]=true;return true end
OverlapParams={new=function()return {} end};Enum.RaycastFilterType={Include=1}
workspace={GetPartBoundsInBox=function(_,cf,size,params)
 local p=params.FilterDescendantsInstances[1]
 return math.abs(p.X-cf.Position.X)<size.X/2 and {p} or {}
end}
local kaiju={SetAttribute=function()end}
'''+step+r'''
assert(stepImpact(CFrame.new(-3,0,-10),Vector3.new(3,1,4),10)==1)
assert(hits['left house'] and not hits['gap house'] and not hits['medium house'])
'''
# Exercise the actual traversal heartbeat with deterministic collision queries.
heartbeat=s[s.index(' local heartbeat='):s.index(' local function stop()')]
code+=r'''
vector.__add=function(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
vector.__mul=function(a,b) return Vector3.new(a.X*b,a.Y*b,a.Z*b) end
vector.__index=function(v,k)
 if k=='Magnitude' then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end
 if k=='Unit' then return v*(1/v.Magnitude) end
 if k=='Dot' then return function(a,b)return a.X*b.X+a.Y*b.Y+a.Z*b.Z end end
end
CFrame.new=function(x,y,z)
 return setmetatable({Position=type(x)=='table' and x or Vector3.new(x or 0,y or 0,z or 0),Yaw=0},frame)
end
frame.__index=function(f,k)
 if k=='Rotation' then local r=CFrame.new();r.Yaw=f.Yaw;return r end
 return frame[k]
end
frame.__mul=function(a,b)
 local r=CFrame.new(a.Position+b.Position);r.Yaw=a.Yaw+b.Yaw;return r
end
local obstacle={}
local scenario='turn'
workspace.GetPartBoundsInBox=function(_,cf)
 if scenario=='turn' then return cf.Yaw>0.5 and cf.Position.Z<3 and {obstacle} or {} end
 if scenario=='wall' then return cf.Position.X>=2 and {obstacle} or {} end
 if scenario=='escape' then return cf.Position.Z<0 and {obstacle} or {} end
 return {}
end
workspace.Blockcast=function(_,cf,_,delta)
 if scenario=='wall' and delta.X>0 then return {Distance=2,Normal=Vector3.new(-1,0,0)} end
end
RaycastParams={new=function()return {} end}
local mediumParts={obstacle};local probes={{Offset=CFrame.new(),Size=Vector3.new(1,1,1)}}
local stopped=false;local refreshAt=math.huge;local function refresh() end
local previous=CFrame.new();root.Parent=character;root.Anchored=false
model.SetAttribute=function(_,key,value) attrs[key]=value end
local update
local RunService={Heartbeat={Connect=function(_,fn) update=fn;return {} end}}
'''+heartbeat+r'''
local function move(x,z,yaw,vx,vz)
 root.CFrame=CFrame.new(x,0,z);root.CFrame.Yaw=yaw
 root.AssemblyLinearVelocity=Vector3.new(vx or 0,4,vz or 10)
 update()
end
move(0,1,1)
assert(root.CFrame.Position.Z==1 and root.CFrame.Yaw==0,'Blocked turn must preserve retreat')
assert(root.AssemblyLinearVelocity.Z==10 and attrs.TraversalTurnBlocked)
move(0,4,1)
assert(root.CFrame.Position.Z==4 and root.CFrame.Yaw==1 and not attrs.TraversalBlocked,'Turn once clear')
scenario='wall';previous=CFrame.new()
move(3,0,0,10,0)
assert(root.CFrame.Position.X<2 and root.AssemblyLinearVelocity.X==0,'Still block travel into buildings')
assert(root.AssemblyLinearVelocity.Y==4,'Preserve vertical motion')
scenario='escape';previous=CFrame.new(0,0,-2)
move(0,-1,0)
assert(root.CFrame.Position.Z==-1,'Allow movement out of existing overlap')
move(0,1,0)
assert(root.CFrame.Position.Z==1 and not attrs.TraversalBlocked)
scenario='turn';previous=CFrame.new()
move(0,0,1)
assert(root.CFrame.Yaw==0 and attrs.TraversalTurnBlocked,'Pure turn still blocked')
'''
runtime=ctypes.util.find_library('lua5.4') or ctypes.util.find_library('lua5.3')
if not runtime: raise RuntimeError('This test requires the Lua 5.3 or 5.4 shared library')
lib=ctypes.CDLL(runtime);lib.luaL_newstate.restype=ctypes.c_void_p
L=lib.luaL_newstate();lib.luaL_openlibs.argtypes=[ctypes.c_void_p];lib.luaL_openlibs(L)
lib.luaL_loadstring.argtypes=[ctypes.c_void_p,ctypes.c_char_p];lib.luaL_loadstring.restype=ctypes.c_int
lib.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p];lib.lua_pcallk.restype=ctypes.c_int
status=lib.luaL_loadstring(L,code.encode()) or lib.lua_pcallk(L,0,0,0,0,None)
if status:
 lib.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p];lib.lua_tolstring.restype=ctypes.c_char_p
 raise RuntimeError(lib.lua_tolstring(L,-1,None).decode())
lib.lua_close.argtypes=[ctypes.c_void_p];lib.lua_close(L)
print('Passed: valid left/right steps; wrong owner, opposite foot, NaN, airborne, special, repeated and stationary steps rejected; only small footprint-overlapping house receives damage.')

print('Passed: retreat during blocked AutoRotate, turning after clearance, wall entry, overlap escape and pure-turn blocking.')
