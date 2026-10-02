-- Client-only geometry review surfaces, rebuilt from both animated plate frames.
local G=require(script.Parent:WaitForChild("KaijuStageFiveGeometry"))
local Renderer={}
function Renderer.Attach(model,parent,anchorFrame)
 local source=assert(model:FindFirstChild("Stage5SailGeometry"),"Missing sail geometry")
 local folder=Instance.new("Folder");folder.Name="MovingEnergySails";folder.Parent=parent
 local hidden,bays={},{}
 local plateCores={}
 for _,p in ipairs(model:GetChildren()) do
  local index=p.Name:match("^DorsalEnergy_(%d+)_Stage5Core_")
  if index and p:IsA("BasePart") then plateCores[tonumber(index)]=p end
 end
 for _,p in ipairs(source:GetDescendants()) do
  if p:IsA("BasePart") then hidden[p]=p.LocalTransparencyModifier;p.LocalTransparencyModifier=1 end
 end
 for _,bay in ipairs(source:GetChildren()) do
  local index=tonumber(bay.Name:match("(%d+)$"))
  local entry={Refs={},Triangles={},FromCore=plateCores[index],ToCore=plateCores[index+1]}
  for _,name in ipairs({"FromLower","FromUpper","ToLower","ToUpper"}) do
   entry.Refs[name]=assert(bay:FindFirstChild(name).Value,"Missing sail anchor")
  end
  for i=1,12 do
   local pair={}
   for j=1,2 do
    local p=G.Part(folder,bay.Name.."_"..i.."_"..j,Vector3.new(0.03,1,1),CFrame.identity,Color3.fromRGB(236,192,65),"WedgePart")
    p.Transparency=1;p.Material=Enum.Material.Neon;p.CastShadow=false;pair[j]=p
   end
   entry.Triangles[i]=pair
  end
  table.insert(bays,entry)
 end
 local stopped=false
 local function update()
  if stopped then return end
  local core=model:FindFirstChild("Stage5ChestCore")
  for _,bay in ipairs(bays) do

   local a=anchorFrame(bay.Refs.FromLower).Position
   local b=anchorFrame(bay.Refs.ToLower).Position
   local ta=anchorFrame(bay.Refs.FromUpper).Position
   local tb=anchorFrame(bay.Refs.ToUpper).Position
   local function top(t)return ta:Lerp(tb,t):Lerp(a:Lerp(b,t),0.30*math.sin(t*math.pi)) end
   for strip=1,6 do
    local t0,t1=(strip-1)/6,strip/6
    local from=bay.FromCore or core
    local to=bay.ToCore or core
    if from and to then
     local color=from.Color:Lerp(to.Color,(t0+t1)/2)
     for _,index in ipairs({strip*2-1,strip*2}) do
      for _,p in ipairs(bay.Triangles[index]) do p.Color=color end
     end
    end
    local p,q,r,s=a:Lerp(b,t0),a:Lerp(b,t1),top(t1),top(t0)
    G.Triangle(nil,nil,p,q,r,nil,0.035*model:GetScale(),bay.Triangles[strip*2-1])
    G.Triangle(nil,nil,p,r,s,nil,0.035*model:GetScale(),bay.Triangles[strip*2])
   end
  end
 end
 local function destroy()
  if stopped then return end;stopped=true;folder:Destroy()
  for p,value in pairs(hidden) do if p.Parent then p.LocalTransparencyModifier=value end end
 end
 return {Update=update,Destroy=destroy}
end
return Renderer
