-- Plain Lua test double. Exercises hierarchy/contract logic, not Roblox rendering or combat.
local methods = {}
local tags = setmetatable({}, {__mode="k"})
local mt = {
 __index=function(t,k)
  if k == "Position" and t:IsA("BasePart") then return t.CFrame.Position end
  if k == "Parent" then return rawget(t,"_parent") end
  if methods[k] then return methods[k] end
  for _,c in ipairs(t._children) do if c.Name==k then return c end end
 end,
 __newindex=function(t,k,v)
  if k=="Position" and t:IsA("BasePart") then rawset(t,"CFrame",CFrame.new(v)*(t.CFrame-t.CFrame.Position));return end
  if k=="Color" then assert(type(v)=="table" and v._robloxType=="Color3", "Color3 expected, got "..type(v)) end
  if k=="Range" or k=="Brightness" then assert(type(v)=="number", k.." must be numeric") end
  if k~="Parent" then rawset(t,k,v);return end
  local old=rawget(t,"_parent")
  if old then for i,c in ipairs(old._children) do if c==t then table.remove(old._children,i);break end end end
  rawset(t,"_parent",v)
  if v then table.insert(v._children,t) end
 end,
}
Instance={new=function(class) return setmetatable({_children={},_attrs={},ClassName=class,Name=class,Transparency=0,Size=Vector3.new(1,1,1),CFrame=CFrame.new()},mt) end}
function methods:IsA(class)
 return class==self.ClassName or class=="Instance" or (class=="BasePart" and (self.ClassName=="Part" or self.ClassName=="WedgePart" or self.ClassName=="SpawnLocation")) or (class=="Light" and self.ClassName=="PointLight" or self.ClassName=="SurfaceLight" or self.ClassName=="SpotLight")
end
function methods:GetChildren() local t={};for i,c in ipairs(self._children) do t[i]=c end;return t end
function methods:GetDescendants()
 local result={}
 for _,c in ipairs(self._children) do table.insert(result,c);for _,d in ipairs(c:GetDescendants()) do table.insert(result,d) end end
 return result
end
function methods:FindFirstChild(name,recursive)
 for _,c in ipairs(self._children) do if c.Name==name then return c end end
 if recursive then for _,c in ipairs(self._children) do local found=c:FindFirstChild(name,true);if found then return found end end end
end
function methods:WaitForChild(name) return assert(self:FindFirstChild(name),self.Name..": missing "..name) end
function methods:FindFirstChildWhichIsA(class,recursive) for _,c in ipairs(recursive and self:GetDescendants() or self:GetChildren()) do if c:IsA(class) then return c end end end
function methods:GetAttributes() return self._attrs end
function methods:FindFirstAncestorWhichIsA(class)
 local p=self.Parent;while p do if p:IsA(class) then return p end;p=p.Parent end
end
function methods:GetFullName() return self.Parent and self.Parent:GetFullName().."."..self.Name or self.Name end
function methods:SetAttribute(k,v) self._attrs[k]=v end
function methods:GetAttribute(k) return self._attrs[k] end
function methods:IsDescendantOf(parent) local p=self.Parent;while p do if p==parent then return true end;p=p.Parent end;return false end
function methods:Destroy() for _,c in ipairs(self:GetChildren()) do c:Destroy() end;self.Parent=nil end
function methods:Clone()
 local mapping={}
 local function cp(a)
  local b=Instance.new(a.ClassName);mapping[a]=b;b.Name=a.Name
  for k,v in pairs(a) do if k~='_children' and k~='_attrs' and k~='_parent' and k~='PrimaryPart' then b[k]=v end end
  for k,v in pairs(a._attrs) do b._attrs[k]=v end
  tags[b]=tags[a]
  for _,c in ipairs(a:GetChildren()) do cp(c).Parent=b end
  return b
 end
 local b=cp(self);b.PrimaryPart=mapping[self.PrimaryPart];return b
end
local service={}
function service:AddTag(m,t) tags[m]=t end
function service:HasTag(m,t) return tags[m]==t end
function service:RemoveTag(m,t) if tags[m]==t then tags[m]=nil end end
game={GetService=function(_,name) if name=="RunService" then return {} end;assert(name=="CollectionService");return service end}
typeof=function(v) return getmetatable(v)==mt and "Instance" or (type(v)=="table" and v._robloxType) or type(v) end

function methods:PivotTo(target)
 local delta=target*self:GetPivot():Inverse()
 for _,p in ipairs(self:GetDescendants()) do if p:IsA("BasePart") then p.CFrame=delta*p.CFrame end end
 self._pivot=target
end
function methods:GetPivot() return self.PrimaryPart and self.PrimaryPart.CFrame or self._pivot or CFrame.new() end
Color3={new=function(...) return {_robloxType="Color3",...} end,fromRGB=function(...) return {_robloxType="Color3",...} end}
Enum=setmetatable({}, {__index=function(t,k) local e=setmetatable({}, {__index=function(_,v) return v end});rawset(t,k,e);return e end})
Vector2={new=function(...) return {...} end}
UDim={new=function(...)return {...}end}
UDim2={fromOffset=function(...) return {...} end,fromScale=function(...) return {...} end}
math.clamp=function(x,a,b)return math.max(a,math.min(x,b))end
local nativeTostring=tostring
tostring=function(v) if type(v)=="number" then return string.format("%.14g",v) end;return nativeTostring(v) end
warn=print
return service
