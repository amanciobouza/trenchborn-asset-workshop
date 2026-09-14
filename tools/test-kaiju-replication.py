"""Headless contract tests; does not replace Roblox physics/visual playtests."""
import ctypes
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
lua=ctypes.CDLL('liblua5.4.so.0');lua.luaL_newstate.restype=ctypes.c_void_p
lua.luaL_openlibs.argtypes=[ctypes.c_void_p];lua.luaL_loadstring.argtypes=[ctypes.c_void_p,ctypes.c_char_p]
lua.lua_pcallk.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_longlong,ctypes.c_void_p]
lua.lua_tolstring.argtypes=[ctypes.c_void_p,ctypes.c_int,ctypes.c_void_p];lua.lua_tolstring.restype=ctypes.c_char_p
L=lua.luaL_newstate();lua.luaL_openlibs(L)
def run(code,execute=True):
    status=lua.luaL_loadstring(L,code.encode())
    if status==0 and execute:status=lua.lua_pcallk(L,0,0,0,0,None)
    assert status==0,lua.lua_tolstring(L,-1,None)
# Only the migrated runtime: unrelated workshop modules use native Luau syntax.
for name in ['KaijuPresentation','KaijuPresentationClient.client','KaijuPresentationBootstrap',
             'KaijuSkeleton','KaijuStageOneRig','KaijuStageOneCombo','KaijuStageOneJump',
             'KaijuStageOneJumpMotor.client','KaijuStageOneCombat','KaijuBuildingTraversal',
             'KaijuStageOneInstaller','KaijuStageTwoInstaller','KaijuStageThreeInstaller']:
    run((SRC/(name+'.lua')).read_text(),False)
mock=r'''
math.clamp=function(x,a,b) return math.max(a,math.min(x,b)) end
math.atan2=math.atan
local V={}
Vector3={new=function(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},V) end}
V.__index=function(v,k)
 if k=="Magnitude" then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end
 if k=="Unit" then return v/math.max(v.Magnitude,0.0001) end
 return V[k]
end
V.__add=function(a,b) return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
V.__sub=function(a,b) return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
V.__unm=function(a) return Vector3.new(-a.X,-a.Y,-a.Z) end
V.__mul=function(a,b) if type(a)=="number" then a,b=b,a end;return Vector3.new(a.X*b,a.Y*b,a.Z*b) end
V.__div=function(a,b) return Vector3.new(a.X/b,a.Y/b,a.Z/b) end
function V:Dot(b) return self.X*b.X+self.Y*b.Y+self.Z*b.Z end
function V:Cross(b) return Vector3.new(self.Y*b.Z-self.Z*b.Y,self.Z*b.X-self.X*b.Z,self.X*b.Y-self.Y*b.X) end
function V:Lerp(b,t) return self+(b-self)*t end
Vector3.zero=Vector3.new();Vector3.xAxis=Vector3.new(1,0,0);Vector3.yAxis=Vector3.new(0,1,0);Vector3.zAxis=Vector3.new(0,0,1)
-- Translation-only mock: sufficient for API execution, not pose visual validation.
local C={}
CFrame={new=function(x,y,z) return setmetatable({Position=type(x)=="table" and x or Vector3.new(x,y,z)},C) end}
CFrame.identity=CFrame.new()
C.__index=function(c,k)
 if k=="Rotation" then return CFrame.identity end
 if k=="RightVector" then return Vector3.xAxis end
 if k=="UpVector" then return Vector3.yAxis end
 if k=="LookVector" then return -Vector3.zAxis end
 return C[k]
end
C.__mul=function(a,b) if getmetatable(b)==V then return a.Position+b end;return CFrame.new(a.Position+b.Position) end
C.__add=function(a,b) return CFrame.new(a.Position+b) end
C.__sub=function(a,b) return CFrame.new(a.Position-b) end
CFrame.Angles=function() return CFrame.identity end
CFrame.fromAxisAngle=CFrame.Angles;CFrame.lookAt=function(a) return CFrame.new(a) end
function C:Inverse() return CFrame.new(-self.Position) end
function C:ToObjectSpace(b) return self:Inverse()*b end
function C:PointToObjectSpace(b) return b-self.Position end
function C:PointToWorldSpace(b) return b+self.Position end
function C:VectorToWorldSpace(b) return b end
C.VectorToObjectSpace=C.VectorToWorldSpace
function C:Lerp(b,t) return CFrame.new(self.Position:Lerp(b.Position,t)) end
function C:GetComponents() return self.Position.X,self.Position.Y,self.Position.Z,1,0,0,0,1,0,0,0,1 end
function C:ToOrientation() return 0,0,0 end
local function signal()
 local s={Listeners={}}
 function s:Connect(f) local c={Callback=f};function c:Disconnect() self.Callback=nil end;table.insert(self.Listeners,c);return c end
 s.Once=s.Connect
 function s:Fire(...) for _,c in ipairs(self.Listeners) do if c.Callback then c.Callback(...) end end end
 return s
end
local all={};local methods={}
function methods:IsA(c) return c==self.ClassName or c=="BasePart" and self.ClassName=="Part" end
function methods:GetChildren() local a={};for _,p in ipairs(all) do if p.Parent==self then table.insert(a,p) end end;return a end
function methods:IsDescendantOf(parent) local p=self.Parent;while p do if p==parent then return true end;p=p.Parent end;return false end
function methods:GetDescendants() local a={};for _,p in ipairs(all) do if p:IsDescendantOf(self) then table.insert(a,p) end end;return a end
function methods:FindFirstChild(n,recursive) for _,p in ipairs(recursive and self:GetDescendants() or self:GetChildren()) do if p.Name==n then return p end end end
methods.WaitForChild=methods.FindFirstChild
function methods:GetAttribute(k) return self.Attributes[k] end
function methods:SetAttribute(k,v) self.Attributes[k]=v;self.Writes[k]=(self.Writes[k] or 0)+1 end
function methods:GetScale() return self.Scale or 1 end
function methods:GetPivot() return self.PrimaryPart and self.PrimaryPart.CFrame or CFrame.identity end
function methods:Destroy() if self.Dead then return end;self.Dead=true;self.Destroying:Fire();for _,p in ipairs(self:GetChildren()) do p:Destroy() end;self.Parent=nil end
function methods:GetState() return self.State or "Running" end
function methods:GetStateEnabled(k) return self.States[k]~=false end
function methods:SetStateEnabled(k,v) self.States[k]=v end
function methods:Move() self.MoveCalls=(self.MoveCalls or 0)+1 end
function methods:ChangeState(k) self.State=k end
function methods:ApplyImpulse(v) self.AssemblyLinearVelocity=self.AssemblyLinearVelocity+v/self.AssemblyMass end
function methods:FireClient(_,value) self.Fired=(self.Fired or 0)+1;self.Last=value end
function methods:Play() self.Played=true end
function methods:Clone() local p=Instance.new(self.ClassName);p.Name=self.Name;return p end
local I={__index=function(p,k)
 if k=="Position" then return p.CFrame.Position end
 if k=="WorldPosition" then return (p.Parent.CFrame*p.CFrame).Position end
 return methods[k]
end}
Instance={new=function(c)
 local p=setmetatable({ClassName=c,Name=c,Attributes={},Writes={},States={},Destroying=signal(),HealthChanged=signal(),
 CFrame=CFrame.identity,Size=Vector3.new(2,2,2),C0=CFrame.identity,C1=CFrame.identity,Transform=CFrame.identity,
 AssemblyLinearVelocity=Vector3.zero,AssemblyAngularVelocity=Vector3.zero,AssemblyMass=10},I)
 table.insert(all,p);return p
end}
Enum=setmetatable({}, {__index=function(t,k) local v=setmetatable({}, {__index=function(_,key) return key end});rawset(t,k,v);return v end})
RaycastParams={new=function() return {} end}
Color3={fromRGB=function(r,g,b) return {R=r/255,G=g/255,B=b/255,Lerp=function(self) return self end} end}
Color3.new=Color3.fromRGB
NumberSequence={new=function() return {} end};ColorSequence=NumberSequence;NumberSequenceKeypoint=NumberSequence
TweenInfo=NumberSequence
Random={new=function() return {NextNumber=function(_,a,b) return a and (a+(b or a))/2 or 0.5 end} end}
task={spawn=function(f) f() end,delay=function(_,f) f() end}
local time=1000
workspace=Instance.new("Workspace");workspace.Gravity=196.2
function workspace:GetServerTimeNow() return time end
function workspace:Raycast() if self.NoGround then return nil end;return {Position=self.GroundPoint or Vector3.zero,Normal=self.GroundNormal or Vector3.yAxis,Instance=workspace} end
local function clone(v) if type(v)~="table" then return v end;local r={};for k,x in pairs(v) do r[k]=clone(x) end;return r end
local encoded={}
local function stringify(t)
 if type(t)~="table" then return tostring(t) end
 local keys={};for k in pairs(t) do table.insert(keys,k) end;table.sort(keys,function(a,b) return tostring(a)<tostring(b) end)
 local items={};for _,k in ipairs(keys) do table.insert(items,tostring(k)..":"..stringify(t[k])) end;return "{"..table.concat(items,",").."}"
end
local http={JSONEncode=function(_,t) local key=stringify(t);encoded[key]=clone(t);return key end,JSONDecode=function(_,s) return clone(encoded[s]) end}
local serverRun={Heartbeat=signal(),PreSimulation=signal(),IsServer=function() return true end,IsClient=function() return false end}
local clientRun={Heartbeat=signal(),PreSimulation=signal(),IsServer=function() return false end,IsClient=function() return true end}
local tags={AddTag=function(_,m,t) m.Tag=t end,RemoveTag=function(_,m) m.Tag=nil end}
local players={GetPlayerFromCharacter=function() return nil end}
local side="server"
game={GetService=function(_,n)
 if n=="RunService" then return side=="server" and serverRun or clientRun end
 if n=="HttpService" then return http end
 if n=="CollectionService" then return tags end
 if n=="Players" then return players end
 if n=="Debris" then return {AddItem=function() end} end
 if n=="TweenService" then return {Create=function(_,obj,_,props) return {Completed=signal(),Play=function() for k,v in pairs(props) do obj[k]=v end end} end} end
 error(n)
end}
local package=Instance.new("Folder")
local modules={}
require=function(m) return assert(modules[m.Name],m.Name) end
script={Parent=package}
local function addModule(name,implementation)
 local module=Instance.new("ModuleScript");module.Name=name;module.Parent=package;modules[name]=implementation;return module
end
'''
code=mock
for name in ['KaijuStageOneCombo','KaijuStageOneJump','KaijuSkeleton']:
    code+='\naddModule("'+name+'",(function()\n'+(SRC/(name+'.lua')).read_text()+'\nend)())\n'
code+='\naddModule("KaijuPresentation",{})\naddModule("KaijuPresentationBootstrap",{Ensure=function() end})\n'
code+='local Controller=(function()\n'+(SRC/'KaijuStageOneRig.lua').read_text()+'\nend)()\n'
code+='side="client"\nlocal Presentation=(function()\n'+(SRC/'KaijuPresentation.lua').read_text()+'\nend)()\nside="server"\n'
code+=r'''
local function create(stage)
 local character=Instance.new("Model");character.Parent=workspace
 local root=Instance.new("Part");root.Name="HumanoidRootPart";root.CFrame=CFrame.new(0,10,0);root.Anchored=false;root.Parent=character
 local h=Instance.new("Humanoid");h.Parent=character;h.Health=100;h.MaxHealth=100;h.WalkSpeed=10;h.AutoRotate=true;h.FloorMaterial="Ground";h.HipHeight=2;h.MaxSlopeAngle=45;h.MoveDirection=Vector3.zero
 local m=Instance.new("Model");m.Name="Stage"..stage;m.Parent=character;m:SetAttribute("EvolutionStage",stage);m:SetAttribute("KaijuAreaVisualRadius",26)
 local function part(name,x,y,z)
  local p=Instance.new("Part");p.Name=name;p.CFrame=CFrame.new(x,y,z);p.Parent=m;p.Color=Color3.fromRGB(20,30,40);p.Material="Slate";return p
 end
 part("PelvisCenter",0,15,0);part("LowerAbdomen",0,20,0);part("Neck",0,29,0);part("LowerJawRear",0,28,-2)
 part("SacralMass",0,15,2);part("TailTip",0,3,25)
 part("UpperMuzzleCoreY",0,29,-5);part("UpperMuzzleCoreZ",0,29,-6)
 part("LowerJawFrontCoreY",0,27,-5);part("LowerJawFrontCoreZ",0,27,-6)
 for _,sideName in ipairs({"Left","Right"}) do
  local x=sideName=="Left" and -7 or 7
  for name,y in pairs({ShoulderJoint=25,ElbowJoint=20,WristJoint=16,PalmCoreZ=15,HipJoint=15,KneeJoint=9,HockJoint=4,AnkleJoint=2,ForefootCoreY=1}) do part(sideName..name,x,y,0) end
 end
 for i=1,10 do part(string.format("TailSegment_%02d",i),0,15-i,i*2) end
 for i=1,9 do part(string.format("DorsalShield_%02d",i),0,28-i,i) end
 local eye=part("LeftEye",0,29,-4);eye.Material="Neon"
 return m,root,h
end
for stage=1,5 do
 local m,root,h=create(stage)
 local calls={};local target={};local api
 local adapter={Cancel=function() end,PrepareFinisher=function() return true end,
  SelectFocusTarget=function() return target end,FocusAim=function() return Vector3.new(0,0,-35),true end,
  AreaImpact=function() calls.Area=(calls.Area or 0)+1 end,
  Handle=function(kind,index,deadline)
   calls[kind]=(calls[kind] or 0)+1
   if kind=="Hit" and index==3 then assert(deadline>os.clock() and deadline-os.clock()<3,"Legacy deadline clock preserved") end
   return true
  end}
 side="server";api=Controller.Attach(m,root,h,adapter)
 local initial={};for name,motor in pairs(api.Motors) do initial[name]=motor.C0 end
 -- Reproduce the reported partial replication: thigh arrives after the model/tag.
 local articulation=m:FindFirstChild("Articulation")
 local thigh=articulation:FindFirstChild("LeftThigh")
 thigh.Parent=nil
 assert(not Presentation.IsReady(m,root),"Partial skeleton must wait")
 side="client"
 local ok=pcall(Presentation.Attach,m,root,h)
 assert(not ok and not m:FindFirstChild("LocalKaijuEffects"),"Incomplete attach must create no effects")
 thigh.Parent=articulation
 local restFrame=thigh:GetAttribute("RigRestFrame")
 thigh:SetAttribute("RigRestFrame",nil)
 assert(not Presentation.IsReady(m,root),"Wait for rest attributes")
 thigh:SetAttribute("RigRestFrame",restFrame)
 local rootJoint=articulation:FindFirstChild("KaijuLocomotionRoot")
 rootJoint.Part0=nil
 assert(not Presentation.IsReady(m,root),"Wait for joint references")
 rootJoint.Part0=root
 assert(Presentation.IsReady(m,root),"Complete rig becomes ready without a new tag")
 side="client";local view=Presentation.Attach(m,root,h)
 local function sync() view.Apply(http:JSONDecode(m:GetAttribute("KaijuPresentationState"))) end
 local function tick(dt)
  time=time+dt;side="server";serverRun.PreSimulation:Fire(dt);serverRun.Heartbeat:Fire(dt)
  side="client";sync();clientRun.Heartbeat:Fire(dt);clientRun.PreSimulation:Fire(dt)
 end
 sync();tick(0.04)
 local idleWrites=m.Writes.KaijuPresentationState
 for i=1,10 do tick(0.04) end
 assert(m.Writes.KaijuPresentationState==idleWrites,"Idle must not publish poses/state every frame")
 api.SetRunning(true);root.AssemblyLinearVelocity=Vector3.new(0,0,-16)
 for i=1,20 do tick(0.04) end
 assert(h.WalkSpeed==16)
 -- Phase 6 reaction recovery: light hit, heavy stagger and healing.
 h.Health=92;h.HealthChanged:Fire(92)
 assert(m:GetAttribute("ReactionState")=="Hit")
 tick(0.4);assert(m:GetAttribute("ReactionState")=="Idle")
 h.Health=67;h.HealthChanged:Fire(67)
 assert(m:GetAttribute("ReactionState")=="Stagger")
 assert(not api.RequestAttack() and not api.RequestJump() and not api.RequestFocus())
 tick(0.9);assert(m:GetAttribute("ReactionState")=="Idle")
 h.Health=100;h.HealthChanged:Fire(100)
 assert(m:GetAttribute("ReactionState")=="Idle","Healing is not a hit")
 -- Rejections retain the request-time ground evidence for both specials.
 h.FloorMaterial="Air"
 local ok,why=api.RequestFocus()
 assert(not ok and why=="Airborne" and m:GetAttribute("FocusRejectReason")=="Airborne")
 assert(m:GetAttribute("SpecialFloorMaterial")=="Air")
 ok,why=api.RequestArea();assert(not ok and why=="Airborne")
 h.FloorMaterial="Ground"
 -- Focus accepted while moving; movement lock survives input, slopes and hits.
 assert(api.RequestFocus());assert(root.Anchored and h.WalkSpeed==0)
 assert(m:GetAttribute("FocusRejectReason")==nil)
 assert(not api.RequestJump() and not api.RequestAttack() and not api.RequestArea())
 h.FloorMaterial="Air";h.Health=80;h.HealthChanged:Fire(80)
 for i=1,50 do tick(0.1) end
 assert(calls.Focus==10,"Exactly ten server focus ticks")
 assert(not root.Anchored and h.AutoRotate)
 h.FloorMaterial="Ground"
 workspace.NoGround=true
 local accepted,reason=api.RequestArea()
 assert(not accepted and reason=="No ground" and m:GetAttribute("AreaPhase")=="No ground")
 assert(not root.Anchored,"Rejected area must not lock movement")
 workspace.NoGround=false;workspace.GroundNormal=Vector3.new(0.95,0.3,0).Unit
 accepted,reason=api.RequestArea();assert(not accepted and reason=="Too steep")
 workspace.GroundNormal=Vector3.new(0.8,0.6,0)
 workspace.GroundPoint=root.Position-Vector3.new(0,30,0)
 assert(api.RequestArea(),"Slope with ground beyond old 20-stud limit accepted")
 assert(m:GetAttribute("AreaRejectReason")==nil)
 workspace.GroundPoint=nil;workspace.GroundNormal=nil
 for i=1,47 do tick(0.1) end
 assert(calls.Area==1 and not root.Anchored)
 root.AssemblyLinearVelocity=Vector3.zero
 -- All combo stages and the optional finisher remain server-authorized.
 for index=1,3 do
  assert(api.RequestAttack())
  local count=index==3 and 6 or 10
  for i=1,count do tick(0.1) end
 end
 assert(api.RequestAttack(),"Lethal optional finisher")
 for i=1,25 do tick(0.1) end
 assert(calls.Hit==4 and calls.Grab==1)
 -- Immediate takeoff, contact damage once, no bounce animation.
 assert(api.RequestJump());tick(0.04);h.FloorMaterial="Air"
 for i=1,4 do tick(0.1) end
 h.FloorMaterial="Ground";root.AssemblyLinearVelocity=Vector3.zero;tick(0.1);tick(0.1)
 assert(calls.Land==1)
 for name,motor in pairs(api.Motors) do assert(motor.C0==initial[name],"Server rest C0 mutated: "..name) end
 -- Death cancels an active special and later clients join the existing death clock.
 tick(2);assert(api.RequestArea());h.Health=0;h.HealthChanged:Fire(0);tick(0.1)
 assert(root.Anchored and m:GetAttribute("SpecialAttackLocked")==nil)
 assert(not api.RequestAttack() and not api.RequestJump() and not api.RequestFocus() and not api.RequestArea(),"Defeat rejects combat")
 for i=1,50 do tick(0.1) end
 local deathState=http:JSONDecode(m:GetAttribute("KaijuPresentationState"));assert(deathState.Defeat)
 view.Stop();side="client";view=Presentation.Attach(m,root,h);view.Apply(deathState);tick(0.1)
 view.Stop();api.Stop();api.Stop();assert(not m.Tag)
end
print("PASS: all stages, immutable joints, idle state suppression, movement locks, focus/area damage, combo/finisher, jump, late death and cleanup")
'''
run(code)
server=(SRC/'KaijuStageOneRig.lua').read_text()
client=(SRC/'KaijuPresentation.lua').read_text()
assert 'Instance.new("Sound")' not in server and '.Transform =' not in server
assert 'FireClient' not in client and 'combat.Handle("Focus"' not in client
assert 'joint.Real.Transform=joint.Inverse*joint.C0' in client
assert 'joint.Transform=CFrame.identity' not in (SRC/'KaijuStageOneJumpMotor.client.lua').read_text()
print('PASS: Lua syntax and client/server ownership boundaries')

# Run the actual owner motor against contact/velocity sequences.
motor_setup=mock+r'''
side="client"
os.clock=function() return time end
local character=Instance.new("Model");character.Parent=workspace
local root=Instance.new("Part");root.Name="HumanoidRootPart";root.Parent=character;root.Anchored=false
local h=Instance.new("Humanoid");h.Parent=character;h.Health=100;h.FloorMaterial="Air"
function character:FindFirstChildOfClass() return h end
local m=Instance.new("Model");m.Parent=character;m:SetAttribute("EvolutionStage",4)
local remote=Instance.new("RemoteEvent");remote.Name="KaijuJumpImpulse";remote.Parent=m;remote.OnClientEvent=signal()
players.LocalPlayer={Character=character,CharacterAdded=signal()}
script={Destroying=signal()}
'''
run(motor_setup+'\n(function()\n'+(SRC/'KaijuStageOneJumpMotor.client.lua').read_text()+'\nend)()\n'+r'''
local function tick(ground,vy,dt)
 time=time+(dt or 0.1);h.FloorMaterial=ground
 root.AssemblyLinearVelocity=Vector3.new(7,vy,9);clientRun.Heartbeat:Fire()
 assert(root.AssemblyLinearVelocity.X==7 and root.AssemblyLinearVelocity.Z==9)
 return root.AssemblyLinearVelocity.Y
end
remote.OnClientEvent:Fire(60)
assert(tick("Ground",50,0.2)==50,"Slope contact must preserve rising jump")
assert(tick("Air",10)==10)
assert(tick("Ground",5)==5,"Apex contact without observed fall must not arm")
assert(tick("Air",-8)==-8)
assert(tick("Ground",12)==0,"Landing rebound after actual fall must be removed")
remote.OnClientEvent:Fire(60)
assert(tick("Ground",55,0.02)==55,"Fresh jump clears previous landing filter")
assert(tick("Air",-8)==-8)
h.State="Swimming";tick("Ground",3)
h.State="Running"
assert(tick("Ground",20)==20,"Swimming clears pending landing")
-- A new character must detach old impulse and landing listeners.
local oldRoot=root
local nextCharacter=Instance.new("Model");nextCharacter.Parent=workspace
local nextRoot=Instance.new("Part");nextRoot.Name="HumanoidRootPart";nextRoot.Parent=nextCharacter;nextRoot.Anchored=false
local nextHuman=Instance.new("Humanoid");nextHuman.Parent=nextCharacter;nextHuman.Health=100;nextHuman.FloorMaterial="Air"
function nextCharacter:FindFirstChildOfClass() return nextHuman end
local nextModel=Instance.new("Model");nextModel.Parent=nextCharacter;nextModel:SetAttribute("EvolutionStage",4)
local nextRemote=Instance.new("RemoteEvent");nextRemote.Name="KaijuJumpImpulse";nextRemote.Parent=nextModel;nextRemote.OnClientEvent=signal()
players.LocalPlayer.Character=nextCharacter;players.LocalPlayer.CharacterAdded:Fire(nextCharacter)
oldRoot.AssemblyLinearVelocity=Vector3.zero
remote.OnClientEvent:Fire(90);assert(oldRoot.AssemblyLinearVelocity.Y==0,"Old character cannot receive impulse")
nextRemote.OnClientEvent:Fire(60);assert(nextRoot.AssemblyLinearVelocity.Y==60,"Respawn accepts its own impulse")
script.Destroying:Fire()
nextRoot.AssemblyLinearVelocity=Vector3.zero
nextRemote.OnClientEvent:Fire(60);assert(nextRoot.AssemblyLinearVelocity.Y==0,"Destroy disconnects current impulse")
print("PASS: respawn isolates old/new jump motors and destruction removes listeners")
print("PASS: owner jump motor ascent, roof contact, falling, rebound, fresh jump and swimming")
''')

# Run complete traversal setup/cleanup for every supported stage and build scale.
run(mock+'\nlocal Traversal=(function()\n'+(SRC/'KaijuBuildingTraversal.lua').read_text()+'\nend)()\n'+r'''
function methods:FindFirstChildOfClass(kind)
 for _,p in ipairs(self:GetChildren()) do if p:IsA(kind) then return p end end
end
function methods:ToObjectSpace(other) return self.CFrame:ToObjectSpace(other) end
local oldNew=Instance.new
Instance.new=function(kind)
 local p=oldNew(kind)
 if kind=="RemoteEvent" then p.OnServerEvent=signal() end
 return p
end
for stage=1,4 do for _,scale in ipairs({0.5,1,2}) do
 local character=Instance.new("Model");character.Parent=workspace
 local model=Instance.new("Model");model.Parent=character;model.Scale=scale;model:SetAttribute("EvolutionStage",stage)
 local root=Instance.new("Part");root.Parent=character
 local h=Instance.new("Humanoid");h.Parent=character
 local collider=Instance.new("Part");collider.Parent=character;collider.CanCollide=true
 local function part(name,x,y,z,sx,sy,sz)
  local p=Instance.new("Part");p.Parent=model;p.Name=name
  p.CFrame=CFrame.new(x*scale,y*scale,z*scale);p.Size=Vector3.new(sx,sy,sz)*scale
  model[name]=p;return p
 end
 part("LeftKneeJoint",-3,8+stage,0,3,3,3)
 part("LeftHipJoint",-3,15+stage,0,3,3,3)
 part("LowerRibcage",0,20+stage,0,9,6,7)
 part("LeftForefootCoreY",-3,1,0,3,2,4)
 part("RightForefootCoreY",3,1,0,3,2,4)
 local building=Instance.new("Part");building.Parent=workspace
 local adapter={TraversalTargets=function()return {{Height=30*scale,Parts={building}}} end,
  StepImpact=function()error("No footfall authorized") end}
 local runtime=Traversal.Attach(model,root,h,0,collider,adapter,nil)
 assert(model:GetAttribute("StepOverHeight")== (8+stage)*scale)
 assert(model:GetAttribute("TraversalLeftFootX")==-3*scale)
 assert(math.abs(collider.Size.X-9*0.60*scale)<0.00001)
 assert(collider.Position.Y-collider.Size.Y/2>=14*scale)
 local folder=character:FindFirstChild("KaijuBuildingTraversal");assert(folder)
 local exempt=false
 for _,p in ipairs(folder:GetChildren()) do if p.Part0==collider and p.Part1==building then exempt=true end end
 assert(exempt and collider.CanCollide,"Only building pairs are exempt; world collision remains")
 local remote=model:FindFirstChild("ReportFootfall");assert(remote)
 remote.OnServerEvent:Fire(nil,"Left",Vector3.zero)
 runtime.Destroy();runtime.Destroy()
 assert(not folder.Parent and not remote.Parent,"Uninstall removes traversal folder and footfall remote")
 character:Destroy();building:Destroy()
end end
print("PASS: shared traversal setup and cleanup, stages 1–4 at scales 0.5/1/2, torso exemptions and NPC footfall rejection")
''')
