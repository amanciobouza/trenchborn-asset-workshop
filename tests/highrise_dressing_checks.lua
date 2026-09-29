local m=GoldenMaster.Build(nil)
local function check()
 local parts,lights,trunks,hedges,cyan,warm=0,0,0,0,0,0
 for _,o in ipairs(m:GetDescendants()) do
  if o:IsA("BasePart") then
   parts=parts+1
   if string.match(o.Name,"Trunk$") then trunks=trunks+1 end
   if string.match(o.Name,"Hedge$") then hedges=hedges+1 end
  elseif o:IsA("Light") then
   lights=lights+1
   assert(o.Color._robloxType=="Color3" and o.Color==o.Parent.Color)
   assert(type(o.Range)=="number" and type(o.Brightness)=="number")
   if string.match(o.Parent.Name,"^CrownLight") then cyan=cyan+1;assert(o.Range==16 and o.Brightness==.45)
   else warm=warm+1 end
  end
 end
 assert(parts==2353 and lights==24 and trunks==12 and hedges==18)
 assert(cyan==4 and warm==20)
 print("PASS: "..parts.." parts, "..trunks.." palms, "..hedges.." planted troughs, four cyan and twenty warm lights with valid Color3/range/brightness")
end
Dressing.Apply(m);check()
Dressing.Apply(m);check()
