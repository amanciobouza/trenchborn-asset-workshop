"""Numerical triangle checks and Stage 5 orchestration using a synthetic Stage 4 fixture."""
import runpy
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
base=runpy.run_path(str(ROOT/'tools/test-kaiju-replication.py'))
run,mock=base['run'],base['mock']
SRC=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
for name in ['KaijuStageFiveGeometry','KaijuStageFiveGoldenMaster']:
    run((SRC/(name+'.lua')).read_text(),False)
code=mock+r'''
-- Real orthonormal frame transforms for triangle reconstruction.
CFrame.fromMatrix=function(pos,x,y,z)
 local f=CFrame.new(pos);f.X=x;f.Y=y;f.Z=z or x:Cross(y);return f
end
C.__index=function(c,k)
 if k=='RightVector' then return c.X or Vector3.xAxis end
 if k=='UpVector' then return c.Y or Vector3.yAxis end
 if k=='ZVector' then return c.Z or Vector3.zAxis end
 if k=='LookVector' then return -(c.Z or Vector3.zAxis) end
 if k=='Rotation' then return CFrame.fromMatrix(Vector3.zero,c.RightVector,c.UpVector,c.ZVector) end
 return C[k]
end
function C:VectorToWorldSpace(v) return self.RightVector*v.X+self.UpVector*v.Y+self.ZVector*v.Z end
function C:PointToWorldSpace(v) return self.Position+self:VectorToWorldSpace(v) end
function C:VectorToObjectSpace(v) return Vector3.new(v:Dot(self.RightVector),v:Dot(self.UpVector),v:Dot(self.ZVector)) end
function C:PointToObjectSpace(v) return self:VectorToObjectSpace(v-self.Position) end
function C:ToObjectSpace(b) return CFrame.fromMatrix(self:PointToObjectSpace(b.Position),self:VectorToObjectSpace(b.RightVector),self:VectorToObjectSpace(b.UpVector),self:VectorToObjectSpace(b.ZVector)) end
C.__mul=function(a,b)
 if getmetatable(b)==V then return a:PointToWorldSpace(b) end
 return CFrame.fromMatrix(a:PointToWorldSpace(b.Position),a:VectorToWorldSpace(b.RightVector),a:VectorToWorldSpace(b.UpVector),a:VectorToWorldSpace(b.ZVector))
end
function methods:IsA(kind) return self.ClassName==kind or kind=='BasePart' and (self.ClassName=='Part' or self.ClassName=='WedgePart' or self.ClassName=='CornerWedgePart') end
local previousIndex=I.__index
I.__index=function(p,k)
 if k=='WorldPosition' and p.ClassName=='Attachment' then return p.Parent.CFrame:PointToWorldSpace(rawget(p,'Position')) end
 return previousIndex(p,k)
end
function methods:GetPivot() return self.Pivot or CFrame.identity end
function methods:PivotTo(frame)
 local delta=frame*self:GetPivot():Inverse()
 for _,p in ipairs(self:GetDescendants()) do if p:IsA('BasePart') then p.CFrame=delta*p.CFrame end end
 self.Pivot=frame
end
function methods:ScaleTo(value)
 local factor=value/self:GetScale();local pivot=self:GetPivot()
 for _,p in ipairs(self:GetDescendants()) do
  if p:IsA('BasePart') then
   p.Size=p.Size*factor;p.CFrame=CFrame.new(pivot.Position+(p.Position-pivot.Position)*factor)*p.CFrame.Rotation
  elseif p:IsA('Attachment') then p.Position=p.Position*factor end
 end
 self.Scale=value
end
'''
code+='local G=(function()\n'+(SRC/'KaijuStageFiveGeometry.lua').read_text()+'\nend)()\n'
code+=r'''
local parent=Instance.new('Folder')
for _,vertices in ipairs({
 {Vector3.new(0,0,0),Vector3.new(3,0,0),Vector3.new(1,2,0)},
 {Vector3.new(2,1,4),Vector3.new(-1,4,3),Vector3.new(2,8,-2)},
 {Vector3.new(0,0,0),Vector3.new(4,0,0),Vector3.new(0,3,0)},
}) do
 for turn=1,3 do
  local a,b,c=vertices[turn],vertices[turn%3+1],vertices[(turn+1)%3+1]
  local parts=G.Triangle(parent,'Test',a,b,c,{},0.03)
  local area=0;local seen={}
  for _,p in ipairs(parts) do
   area=area+p.Size.Y*p.Size.Z/2
   assert(p.CFrame.RightVector:Cross(p.CFrame.UpVector):Dot(p.CFrame.ZVector)>0.999)
   for _,v in ipairs({Vector3.new(0,-p.Size.Y/2,-p.Size.Z/2),Vector3.new(0,-p.Size.Y/2,p.Size.Z/2),Vector3.new(0,p.Size.Y/2,p.Size.Z/2)}) do
    local point=p.CFrame:PointToWorldSpace(v)
    for i,want in ipairs({a,b,c}) do if (point-want).Magnitude<1e-6 then seen[i]=true end end
   end
  end
  assert(math.abs(area-(b-a):Cross(c-a).Magnitude/2)<1e-6 and seen[1] and seen[2] and seen[3],'Wedge triangles must reproduce area and all vertices')
 end
end
assert(#G.Triangle(parent,'Flat',Vector3.zero,Vector3.xAxis,Vector3.xAxis*2,{},0.03)==0)
addModule('KaijuStageFiveGeometry',G)
addModule('KaijuEvolutionBlockout',{ResolveBuildScale=function(o)return o and o.Scale or 1 end})
addModule('KaijuStageFourGoldenMaster',{Build=function(parent)
 local m=Instance.new('Model');m.Name='Stage_4_Geometry_Review';m.Parent=parent
 local function part(name,x,y,z,sx,sy,sz,class)
  local p=G.Part(m,name,Vector3.new(sx,sy,sz),CFrame.new(x,y,z),{},class)
  m[name]=p;return p
 end
 part('UpperRibcage',0,22,0,10,8,6)
 part('LowerRibcage',0,19,0,9,7,6)
 part('BellyShield',0,18,-2,6,8,2)
 part('Cranium',0,31,-3,6,5,6)
 part('LowerJawRear',0,27,-5,6,3,5)
 for _,sign in ipairs({-1,1}) do
  local side=sign<0 and 'Left' or 'Right'
  part(side..'Pectoral',sign*3,23,-3,5,4,2)
  for _,joint in ipairs({'ShoulderJoint','ElbowJoint','HipJoint','KneeJoint'}) do part(side..joint,sign*7,20,0,3,3,3) end
  part(side..'ForefootCoreY',sign*4,1,-1,4,2,6)
  part(side..'RibArmorStage4Row1Core',sign*3,23,-4,4,3,1)
 end
 for i=1,11 do
  part(string.format('DorsalShield_%02d',i),0,28-i*1.5,3+i*2,1,5,4,'WedgePart')
  if i>3 then part(string.format('TailSegment_%02d',i-2),0,24-i*1.5,3+i*2,3,3,3) end
 end
 for _,side in ipairs({'Left','Right'}) do
  part('DorsalRock_03_SideSpine_'..side..'Shard',0,16,6,1,1,3)
 end
 m:SetAttribute('ApprovedGeometryCommit','stage4');m:SetAttribute('FinalInstallerVersion','old')
 return m
end})
'''
code+='local Builder=(function()\n'+(SRC/'KaijuStageFiveGoldenMaster.lua').read_text()+'\nend)()\n'
code+=r'''
for _,scale in ipairs({0.5,1,2}) do
 local folder=Instance.new('Folder')
 local m=Builder.Build(folder,CFrame.new(10,0,20),{Scale=scale})
 assert(m:GetAttribute('EvolutionStage')==5 and m:GetAttribute('PipelinePhase')==4)
 assert(m:GetAttribute('QualityGateB')=='Pending_UserGeometryReview' and m:GetAttribute('ApprovedGeometryCommit')==nil)
 assert(m:GetAttribute('FinalInstallerVersion')==nil)
 for _,side in ipairs({'Left','Right'}) do
  assert(m:FindFirstChild('DorsalRock_03_SideSpine_'..side..'Shard'):GetAttribute('RigRegion')=='TailBase','Sacral spikes must not inherit sprint torso pitch')
 end
 local sails=m:FindFirstChild('Stage5SailGeometry');assert(sails and #sails:GetChildren()==10)
 local geometry=0
 for index,bay in ipairs(sails:GetChildren()) do
  assert(bay:FindFirstChild('FromUpper').Value.Parent.Name==string.format('DorsalShield_%02d',index))
  assert(bay:FindFirstChild('ToUpper').Value.Parent.Name==string.format('DorsalShield_%02d',index+1))
  local fields,refs=0,0
  for _,p in ipairs(bay:GetChildren()) do
   if p:IsA('ObjectValue') then assert(p.Value and p.Value.Parent);refs=refs+1 end
   if p:IsA('BasePart') then assert(p.Size.Y>0 and p.Size.Z>0 and not p.CanCollide and p.Transparency==0.42);fields=fields+1 end
  end
  assert(refs==4 and fields>=6);geometry=geometry+fields
 end
 local armorCount,minX,maxX=0,math.huge,-math.huge
 for _,p in ipairs(m:GetChildren()) do
  if p.Name:match('^Stage5UpperBackArmor_') then
   armorCount=armorCount+1
   assert(p:GetAttribute('RigRegion')=='Torso' and not p.CanCollide)
   for _,v in ipairs({Vector3.new(0,-p.Size.Y/2,-p.Size.Z/2),Vector3.new(0,-p.Size.Y/2,p.Size.Z/2),Vector3.new(0,p.Size.Y/2,p.Size.Z/2)}) do
    local x=p.CFrame:PointToWorldSpace(v).X;minX=math.min(minX,x);maxX=math.max(maxX,x)
   end
  end
 end
 assert(armorCount>=24 and minX<m.LeftShoulderJoint.Position.X and maxX>m.RightShoulderJoint.Position.X,'Upper back armor must span both shoulder roots')
 assert(not m:FindFirstChild('LeftRibArmorStage4Row1Core'))
 local jaw=m:FindFirstChild('LowerJawRear')
 local limit=jaw.Position.Y-jaw.Size.Y/2-m:GetAttribute('NormalizedChestJawClearance')*m:GetScale()
 for _,p in ipairs(m:GetChildren()) do
  if p.Name:match('^Stage5Chest') then
   local cf,h=p.CFrame,p.Size/2
   local top=p.Position.Y+math.abs(cf.RightVector.Y)*h.X+math.abs(cf.UpVector.Y)*h.Y+math.abs(cf.ZVector.Y)*h.Z
   if p:IsA('WedgePart') then
    top=-math.huge
    for _,x in ipairs({-h.X,h.X}) do
     for _,v in ipairs({Vector3.new(x,-h.Y,-h.Z),Vector3.new(x,-h.Y,h.Z),Vector3.new(x,h.Y,h.Z)}) do
      top=math.max(top,cf:PointToWorldSpace(v).Y)
     end
    end
   end
   assert(top<=limit+1e-6,'Chest armor must stay below jaw clearance')
  end
 end
 assert(m:FindFirstChild('Stage5ChestCore') and m:FindFirstChild('Stage5Crown_5_1'))
 assert(math.abs(m.LeftForefootCoreY.Position.Y-m.LeftForefootCoreY.Size.Y/2)<1e-6)
 assert(not folder:FindFirstChild('StageFiveBuild'))
 assert(not pcall(Builder.Build,folder,CFrame.identity,{Scale=scale}),'No duplicate candidate')
 folder:Destroy()
end
print('PASS: Stage 5 triangle area/vertices/winding, degenerate handling, build orchestration, 10 filled bays, 40 anchor links, scaling, ground contact and pending gates (synthetic Stage 4 fixture)')
'''
code+='local Renderer=(function()\n'+(SRC/'KaijuEnergySailPresentation.lua').read_text()+'\nend)()\n'
code+=r'''
local parent=Instance.new('Folder')
local m=Builder.Build(parent,CFrame.identity,{Scale=1})
local source=m:FindFirstChild('Stage5SailGeometry')
for _,p in ipairs(source:GetDescendants()) do if p:IsA('BasePart') then p.LocalTransparencyModifier=0 end end
local offset=Vector3.zero
local collapsed=false
local view=Renderer.Attach(m,parent,function(ref)return CFrame.new(collapsed and offset or ref.WorldPosition+offset) end)
local moving=parent:FindFirstChild('MovingEnergySails')
assert(#moving:GetChildren()==120)
view.Update()
local first
for _,p in ipairs(moving:GetChildren()) do if p.Transparency<1 then first=p;break end end
assert(first)
local start=first.Position
offset=Vector3.new(7,3,-2);view.Update()
assert((first.Position-start-offset).Magnitude<1e-6)
assert(#moving:GetChildren()==120)
collapsed=true;view.Update()
for _,p in ipairs(moving:GetChildren()) do assert(p.Transparency==1) end
view.Destroy();view.Destroy();view.Update()
assert(not moving.Parent)
for _,p in ipairs(source:GetDescendants()) do if p:IsA('BasePart') then assert(p.LocalTransparencyModifier==0) end end
print('PASS: moving sail anchors, fixed part count, degenerate hiding and idempotent cleanup')
'''
run(code)
