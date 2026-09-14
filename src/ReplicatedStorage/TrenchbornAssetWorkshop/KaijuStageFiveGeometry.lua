-- Phase 4 geometry helpers. All generated parts are nonphysical review geometry.
local Geometry={}
function Geometry.Part(parent,name,size,cf,color,class)
 local p=Instance.new(class or "Part")
 p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
 p.Material=Enum.Material.Slate;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 p.Parent=parent;return p
end
-- Split a triangle on its longest side. Native wedge cross-section vertices
-- are (-Y,-Z), (-Y,+Z), (+Y,+Z); both halves have their right angle at the foot.
function Geometry.Triangle(parent,name,a,b,c,color,thickness)
 local ab,bc,ca=(b-a).Magnitude,(c-b).Magnitude,(a-c).Magnitude
 if ab>bc and ab>=ca then a,b,c=c,a,b elseif ca>bc and ca>=ab then a,b,c=b,c,a end
 local length=(c-b).Magnitude
 if length<1e-5 then return {} end
 local along=(c-b).Unit
 local distance=math.clamp((a-b):Dot(along),0,length)
 local foot=b+along*distance
 local height=(a-foot).Magnitude
 if height<1e-5 then return {} end
 local up=(a-foot).Unit
 local result={}
 for index,entry in ipairs({{distance,along},{length-distance,-along}}) do
  local width,back=entry[1],entry[2]
  if width>1e-5 then
   local cf=CFrame.fromMatrix(foot+up*(height/2)-back*(width/2),up:Cross(back),up,back)
   local p=Geometry.Part(parent,name.."_"..index,Vector3.new(thickness or 0.06,height,width),cf,color,"WedgePart")
   table.insert(result,p)
  end
 end
 return result
end
function Geometry.Quad(parent,name,a,b,c,d,color,thickness)
 local parts=Geometry.Triangle(parent,name.."A",a,b,c,color,thickness)
 for _,p in ipairs(Geometry.Triangle(parent,name.."B",a,c,d,color,thickness)) do table.insert(parts,p) end
 return parts
end
return Geometry
