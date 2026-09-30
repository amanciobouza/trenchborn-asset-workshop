-- Numerical rigid transforms for placement/bounds tests; no Roblox physics/render simulation.
local vm={};vm.__index=function(v,k)
 if k=='Magnitude' then return math.sqrt(v.X*v.X+v.Y*v.Y+v.Z*v.Z) end
 if k=='Unit' then return v/v.Magnitude end
 return vm[k]
end
Vector3={new=function(x,y,z)return setmetatable({X=x or 0,Y=y or 0,Z=z or 0,_robloxType='Vector3'},vm)end}
vm.__add=function(a,b)return Vector3.new(a.X+b.X,a.Y+b.Y,a.Z+b.Z)end
vm.__sub=function(a,b)return Vector3.new(a.X-b.X,a.Y-b.Y,a.Z-b.Z)end
vm.__unm=function(a)return Vector3.new(-a.X,-a.Y,-a.Z)end
vm.__mul=function(a,b)if type(a)=='number' then a,b=b,a end;return Vector3.new(a.X*b,a.Y*b,a.Z*b)end
vm.__div=function(a,b)return a*(1/b)end
function vm:Lerp(b,t)return self+(b-self)*t end
function vm:Dot(b)return self.X*b.X+self.Y*b.Y+self.Z*b.Z end
function vm:Cross(b)return Vector3.new(self.Y*b.Z-self.Z*b.Y,self.Z*b.X-self.X*b.Z,self.X*b.Y-self.Y*b.X)end
Vector3.zero=Vector3.new();Vector3.xAxis=Vector3.new(1,0,0);Vector3.yAxis=Vector3.new(0,1,0);Vector3.zAxis=Vector3.new(0,0,1)
local cm={};cm.__index=function(c,k)
 if k=='Position' or k=='p' then return c.pos end
 if k=='XVector' or k=='RightVector' then return Vector3.new(c.r[1],c.r[4],c.r[7]) end
 if k=='YVector' or k=='UpVector' then return Vector3.new(c.r[2],c.r[5],c.r[8]) end
 if k=='ZVector' then return Vector3.new(c.r[3],c.r[6],c.r[9]) end
 if k=='LookVector' then return -c.ZVector end
 return cm[k]
end
local function cf(p,r)return setmetatable({pos=p,r=r or {1,0,0,0,1,0,0,0,1},_robloxType='CFrame'},cm)end
CFrame={}
function CFrame.new(x,y,z)
 if type(x)=='table' then return cf(x)end
 return cf(Vector3.new(x,y,z))
end
function cm:VectorToWorldSpace(v)local r=self.r;return Vector3.new(r[1]*v.X+r[2]*v.Y+r[3]*v.Z,r[4]*v.X+r[5]*v.Y+r[6]*v.Z,r[7]*v.X+r[8]*v.Y+r[9]*v.Z)end
cm.__mul=function(a,b)
 if getmetatable(b)==vm then return a.pos+a:VectorToWorldSpace(b) end
 local r={};for i=0,2 do for j=0,2 do local x=0;for k=0,2 do x=x+a.r[i*3+k+1]*b.r[k*3+j+1] end;r[i*3+j+1]=x end end
 return cf(a*b.pos,r)
end
cm.__add=function(a,b)return cf(a.pos+b,a.r)end
cm.__sub=function(a,b)return cf(a.pos-b,a.r)end
function cm:Inverse()
 local r=self.r;local t=cf(Vector3.zero,{r[1],r[4],r[7],r[2],r[5],r[8],r[3],r[6],r[9]});t.pos=t:VectorToWorldSpace(-self.pos);return t
end
function cm:ToObjectSpace(b)return self:Inverse()*b end
function cm:PointToObjectSpace(b)return self:Inverse()*b end
function cm:PointToWorldSpace(b)return self*b end
function CFrame.Angles(x,y,z)
 local cx,sx,cy,sy,cz,sz=math.cos(x),math.sin(x),math.cos(y),math.sin(y),math.cos(z),math.sin(z)
 return cf(Vector3.zero,{1,0,0,0,cx,-sx,0,sx,cx})*cf(Vector3.zero,{cy,0,sy,0,1,0,-sy,0,cy})*cf(Vector3.zero,{cz,-sz,0,sz,cz,0,0,0,1})
end
function CFrame.fromMatrix(p,x,y,z)z=z or x:Cross(y);return cf(p,{x.X,y.X,z.X,x.Y,y.Y,z.Y,x.Z,y.Z,z.Z})end
function CFrame.lookAt(a,b,up)
 local back=(a-b).Unit;local right=(up or Vector3.yAxis):Cross(back).Unit
 return CFrame.fromMatrix(a,right,back:Cross(right),back)
end
