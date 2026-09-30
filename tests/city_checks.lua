local Assembly=require(modules.LargeCityAssembly)
local Plan=require(modules.LargeCityPlan)
local parent=Instance.new("Folder")
local city=Assembly.Build(parent,{GroundY=12})
assert(city:GetAttribute("FlatPreviewGroundY")==12)
assert(city:GetAttribute("BuildingCount")==54 and #city.Buildings:GetChildren()==54)
assert(not pcall(Assembly.Build,parent),"Must refuse duplicate build")
local seen,counts={},{}
for _,plot in ipairs(Plan.plots) do
 if plot.model~="-" then
  local info=Plan.models[plot.model]
  local m=assert(city.Buildings:FindFirstChild(plot.place_id.."_"..info.prefix))
  assert(not seen[m]);seen[m]=true;counts[plot.model]=(counts[plot.model] or 0)+1
  assert(m:GetAttribute("LayoutId")==plot.place_id)
  assert(not CS:HasTag(m,"KaijuHouse"))
  local pivot=m:GetPivot()
  assert(math.abs(pivot.Position.X-plot.x)<.001 and math.abs(pivot.Position.Z+plot.z)<.001)
  local expected=({N=Vector3.new(0,0,-1),S=Vector3.new(0,0,1),E=Vector3.new(1,0,0),W=Vector3.new(-1,0,0)})[plot.front]
  assert((pivot.LookVector-expected).Magnitude<.001,"Incorrect facing: "..plot.place_id)
  local lo,hi,n,l=Assembly.Bounds(m)
  print(string.format("BOUNDS %s %s %.3f %.3f %.3f %.3f %.3f %.3f %d %d",plot.place_id,plot.model,lo.X,lo.Y,lo.Z,hi.X,hi.Y,hi.Z,n,l))
 end
end
local masters=0;for _ in pairs(counts) do masters=masters+1 end;assert(masters==21)
-- Copy isolation: changing or destroying one occurrence must not affect another.
local a=city.Buildings:FindFirstChild("LC-19_LargeCityOffice")
local b=city.Buildings:FindFirstChild("LC-20_LargeCityOffice")
a:SetAttribute("Health",123);assert(b:GetAttribute("Health")~=123)
local before=#b:GetDescendants();a:Destroy();assert(#b:GetDescendants()==before)
print("PASS: all 54 placements / 21 masters, directions, separate copies, no gameplay tags, duplicate build refused")

-- A failed build must not publish a partial city or remove unrelated content.
local empty=Instance.new("Folder");local unrelated=Instance.new("Part");unrelated.Parent=empty
local old=Plan.models.B01.prefix;Plan.models.B01.prefix="MissingDependency"
assert(not pcall(Assembly.Build,empty));Plan.models.B01.prefix=old
assert(#empty:GetChildren()==1 and unrelated.Parent==empty)
local raised=Assembly.Placement({x=100,z=200,front="E"},12)
assert(raised.Position.Y==12 and raised.Position.Z==-200)
print("PASS: failed build is atomic; unrelated content preserved; elevation and Plan-to-Roblox transform")
