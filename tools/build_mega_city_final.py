"""Assemble native, editable Mega City. Requires shapely>=2.1 (pip install shapely).
No runtime installer: every placed building is exported with its original scripts.
"""
from pathlib import Path
import copy, json, math, random, runpy, heapq, collections
import xml.etree.ElementTree as E
from shapely.geometry import Point, Polygon, LineString, box
from shapely.ops import unary_union, nearest_points
from shapely import constrained_delaunay_triangles
ROOT=Path(__file__).resolve().parents[1]
base=runpy.run_path(str(ROOT/'tools/build_glacier_city_blockout.py'))
warp=base['warp']; bounds=base['bounds']; raw=base['buildings']; pillars=base['pillars']
OUT=ROOT/'packages/mega-city-final';OUT.mkdir(exist_ok=True)
DOC=ROOT/'docs/mega-city/plans';TMP=ROOT/'tmp/mega-city'
rng=random.Random(73109)
def ground(z):
 if z<=1600:return 20
 if z<1800:return 20+(z-1600)/10
 if z<=3200:return 40
 if z<3400:return 40+(z-3200)/10
 if z<=5600:return 60
 if z<5800:return 60+(z-5600)/10
 return 80
def polygon(b,margin=0):
 w,_,d=b['size'];x,_,z=b['center'];a=b['yaw'];c,s=math.cos(a),math.sin(a)
 return Polygon([(x+c*px+s*pz,z-s*px+c*pz) for px,pz in [(-w/2,-d/2),(w/2,-d/2),(w/2,d/2),(-w/2,d/2)]]).buffer(margin,join_style=2)
def shape_for(slot,asset):
 b=copy.deepcopy(slot);b['asset']=asset;b['size']=bounds[asset]['size'];return polygon(b)
slots=copy.deepcopy(raw)
# Keep the sea gate on the arrival apron and the landmark behind the plaza.
slots[0]['center'][0]=-650;slots[0]['center'][2]=-105
# Soft neighbourhood affinities; these are not district fences.
affinities={1:(-1,-105,400),2:(-1,900,1050),3:(-1,1700,1450),4:(-1,2200,1250),5:(-1,2700,1450),6:(-1,2700,1100),7:(-1,2000,1450),8:(-1,4350,1900),9:(-1,4600,1850),10:(0,3550,2500),11:(1,1200,1200),12:(1,1800,1500),13:(1,2600,1700),14:(1,4050,1100),15:(0,4300,1950),16:(1,4600,1250),17:(1,4850,1000),18:(0,6000,1650),19:(0,6300,1600),20:(0,6000,1400),21:(0,7700,100)}
fixed={0,84};assets=[b['asset'] for b in slots]
neighbours=set()
for i,a in enumerate(slots):
 if i in fixed:continue
 near=sorted((math.dist((a['center'][0],a['center'][2]),(b['center'][0],b['center'][2])),j) for j,b in enumerate(slots) if j!=i and j not in fixed)
 for distance,j in near[:4]:
  if distance<1100:neighbours.add(tuple(sorted((i,j))))
def affinity(i,a):
 side,zc,spread=affinities[a];x,_,z=slots[i]['center']
 return 5*((z-zc)/spread)**2+(12 if side and x*side<0 else 0)
def cost(ids):return sum(affinity(i,a) for i,a in enumerate(ids))+sum(28 for i,j in neighbours if ids[i]==ids[j])
# Deterministic simulated annealing retains exact type totals while dispersing repeats.
best=assets[:];bestcost=score=cost(assets);indices=[i for i in range(85) if i not in fixed]
for step in range(36000):
 i,j=rng.sample(indices,2)
 if assets[i]==assets[j]:continue
 old=affinity(i,assets[i])+affinity(j,assets[j]);edges=[(a,b) for a,b in neighbours if i in (a,b) or j in (a,b)]
 old+=sum(28 for a,b in edges if assets[a]==assets[b])
 assets[i],assets[j]=assets[j],assets[i]
 new=affinity(i,assets[i])+affinity(j,assets[j])+sum(28 for a,b in edges if assets[a]==assets[b]);delta=new-old
 temp=3.5*(1-step/36000)+.08
 if delta<=0 or rng.random()<math.exp(-delta/temp):
  score+=delta
  if score<bestcost:bestcost=score;best=assets[:]
 else:assets[i],assets[j]=assets[j],assets[i]
assets=best;buildings=[];counts=collections.Counter()
for slot,asset in zip(slots,assets):
 counts[asset]+=1;b=copy.deepcopy(slot);b.update(asset=asset,id=f'MC-{asset:02d}-{counts[asset]:02d}',source=bounds[asset],size=bounds[asset]['size'])
 b['center'][1]=b['ground']+b['size'][1]/2;b['homeDistrict']=next(q['district'] for q in raw if q['asset']==asset)
 buildings.append(b)
main_clear=unary_union([LineString([(warp(side*360,0,z)[0],z) for z in range(0,6751,75)]).buffer(104) for side in [-1,1]])
for b in buildings:
 if b['asset'] in [1,21]:continue
 for attempt in range(30):
  if not polygon(b).intersects(main_clear):break
  b['center'][0]+=12*(1 if b['center'][0]>0 else -1)
 else:raise AssertionError(('Main-road setback',b['id']))
polys=[polygon(b) for b in buildings]
for i,p in enumerate(polys):
 for j,q in enumerate(polys[:i]):assert not p.intersects(q),(buildings[i]['id'],buildings[j]['id'])
 for col in pillars:assert p.distance(Point(col['x'],col['z']))>col['radius']+12
# Native building copies: transform only world-space BasePart CFrames, not local attachments.
cached={a:E.parse(ROOT/bounds[a]['package']).getroot() for a in counts}
for b in buildings:
 root=copy.deepcopy(cached[b['asset']]);model=root.find('Item');model.find("Properties/string[@name='Name']").text=b['id']
 a=b['yaw'];c,s=math.cos(a),math.sin(a);R=[[c,0,s],[0,1,0],[-s,0,c]]
 src=b['source'];mid=[(src['min'][k]+src['max'][k])/2 for k in range(3)]
 trans=[b['center'][r]-sum(R[r][k]*mid[k] for k in range(3)) for r in range(3)]
 b['translation']=trans
 for item in root.iter('Item'):
  if item.attrib['class'] not in ['Part','WedgePart','CornerWedgePart','MeshPart','UnionOperation']:continue
  cf=item.find("Properties/CoordinateFrame[@name='CFrame']")
  if cf is None:continue
  pos=[float(cf.find(k).text) for k in 'XYZ'];mat=[[float(cf.find(f'R{r}{k}').text) for k in range(3)] for r in range(3)]
  for r,k in enumerate('XYZ'):cf.find(k).text=f'{trans[r]+sum(R[r][j]*pos[j] for j in range(3)):.8f}'
  for r in range(3):
   for k in range(3):cf.find(f'R{r}{k}').text=f'{sum(R[r][j]*mat[j][k] for j in range(3)):.10f}'
 # Strip only indentation; never modify script or label content.
 for el in root.iter():
  if el.text and not el.text.strip():el.text=None
  el.tail=None
 path=OUT/(b['id']+'.rbxmx');E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
 b['placedPackage']=str(path.relative_to(ROOT))
print('85 native building copies placed; district transitions blended.',flush=True)
# Walkable land boundary used by routing. Terrain is supplied as a separate removable proxy.
zs=sorted(set(range(0,6751,90))|{6750})
lands=[]
for side in [-1,1]:
 inner=[(warp(side*260,0,z)[0],z) for z in zs];outer=[(warp(side*2380,0,z)[0],z) for z in reversed(zs)]
 lands.append(Polygon(inner+outer))
land=unary_union(lands+[box(-1080,-320,-220,100),box(-2100,6640,2100,6850),box(-540,6640,540,8120)])
# Major roads and both existing bridge crossings form the initial connected graph.
roads=[]
def road(points,width,kind):
 line=LineString(points)
 if line.length>.1:roads.append({'kind':kind,'width':width,'points':[list(p) for p in points]})
for side in [-1,1]:road([(warp(side*360,0,z)[0],z) for z in range(0,6751,75)],180,'Main road')
for z in [1700,5700]:road([(warp(x,0,z)[0],z) for x in range(-450,451,90)],220,'Bridge')
road([(-2050,6750),(2050,6750)],160,'Rear boulevard')
road([(0,6750),(0,7550)],180,'Plaza approach')
# Routing grid uses buffered real footprints and column feet, not point-only obstacles.
clearance=44
obstacles=unary_union([p.buffer(clearance,join_style=2) for p in polys]+[Point(p['x'],p['z']).buffer(p['radius']+clearance+25) for p in pillars])
allowed=land.buffer(-36)
STEP=40;nodes={}
for iz in range(-7,171):
 z=iz*STEP
 for ix in range(-75,76):
  x=ix*STEP;pt=Point(x,z)
  if allowed.contains(pt) and not obstacles.contains(pt):nodes[(ix,iz)]=(x,z)
# Map to the closest clear grid point with a collision-free lead-in.
def segment_ok(a,b):return allowed.covers(LineString([a,b])) and not obstacles.intersects(LineString([a,b]))
def nearest_node(p):
 for _,key in sorted((math.dist(p,v),k) for k,v in nodes.items()):
  if segment_ok(p,nodes[key]):return key
 raise AssertionError(('No road access',p))
network=set()
def seed_network(line):
 for key,p in nodes.items():
  if line.distance(Point(p))<42:network.add(key)
for r in roads:seed_network(LineString(r['points']))
def route(start,targets):
 # Multi-goal A*, with Euclidean lower bound to the network bounding box.
 goals=[nodes[k] for k in targets];minx=min(p[0] for p in goals);maxx=max(p[0] for p in goals);minz=min(p[1] for p in goals);maxz=max(p[1] for p in goals)
 def heuristic(k):
  x,z=nodes[k];return math.hypot(max(minx-x,0,x-maxx),max(minz-z,0,z-maxz))
 todo=[(0,start)];dist={start:0};parent={};end=None
 while todo:
  _,current=heapq.heappop(todo)
  if current in targets:end=current;break
  x,z=current
  for dx,dz in [(1,0),(-1,0),(0,1),(0,-1),(1,1),(1,-1),(-1,1),(-1,-1)]:
   nxt=(x+dx,z+dz)
   if nxt not in nodes:continue
   if not segment_ok(nodes[current],nodes[nxt]):continue
   val=dist[current]+STEP*math.hypot(dx,dz)
   if val<dist.get(nxt,1e20):dist[nxt]=val;parent[nxt]=current;heapq.heappush(todo,(val+heuristic(nxt),nxt))
 assert end is not None,('Disconnected access',start)
 path=[end]
 while path[-1]!=start:path.append(parent[path[-1]])
 path.reverse();return path
# Outer collectors form loops with the waterfront roads; bend around the ice columns.
for side in [-1,1]:
 keys=[min(nodes,key=lambda k:math.dist(nodes[k],(warp(side*1950,0,z)[0],z))) for z in [300,1450,2500,3500,4650,5700,6520]]
 first=route(keys[0],network);network.update(first);road([nodes[k] for k in first],64,'Collector')
 for ka,kb in zip(keys,keys[1:]):
  path=route(ka,{kb});network.update(path);road([nodes[k] for k in path],64,'Collector')
 path=route(keys[-1],{k for k in network if nodes[k][1]>=6720})
 network.update(path);road([nodes[k] for k in path],64,'Collector')
# Buildings receive individual front access; nearest existing street accumulates shared lanes.
for b,p in sorted(zip(buildings,polys),key=lambda t:t[0]['center'][2]):
 if b['asset']==21:continue
 x,_,z=b['center'];a=b['yaw'];d=b['size'][2]
 front=(x-math.sin(a)*(d/2+58),z-math.cos(a)*(d/2+58))
 # If a neighbouring envelope blocks the nominal front, use another clear frontage.
 options=[front]
 for sign in [-1,1]:options.append((x+sign*math.cos(a)*(b['size'][0]/2+58),z-sign*math.sin(a)*(b['size'][0]/2+58)))
 front=next((q for q in options if allowed.contains(Point(q)) and not obstacles.contains(Point(q))),None)
 assert front is not None,('Blocked frontage',b['id'])
 key=nearest_node(front);path=route(key,network);network.update(path)
 points=[front]+[nodes[k] for k in path]
 # End on actual road centreline, not merely on a nearby grid seed.
 end=Point(points[-1]);nearest=min(roads,key=lambda r:LineString(r['points']).distance(end));line=LineString(nearest['points']);q=line.interpolate(line.project(end));points.append((q.x,q.y))
 road(points,64,'Access lane');b['roadAccess']=list(front)
# Smooth grid polylines while retaining a clear 44-stud obstacle margin.
def smooth(points):
 if len(points)<3:return points
 # Shorten grid paths through clear space, then round corners. Junctions are
 # reconnected geometrically below after this final centreline adjustment.
 reduced=[points[0]];i=0
 while i<len(points)-1:
  j=len(points)-1
  while j>i+1 and not segment_ok(points[i],points[j]):j-=1
  reduced.append(points[j]);i=j
 out=[reduced[0]]
 for i in range(1,len(reduced)-1):
  a,b,c=reduced[i-1:i+2];d1=math.dist(a,b);d2=math.dist(b,c);cut=min(65,d1*.28,d2*.28)
  if min(d1,d2)<.01:continue
  u=[b[k]+(a[k]-b[k])*cut/d1 for k in range(2)];v=[b[k]+(c[k]-b[k])*cut/d2 for k in range(2)]
  curve=[[(1-t)**2*u[k]+2*t*(1-t)*b[k]+t*t*v[k] for k in range(2)] for t in [0,.2,.4,.6,.8,1]]
  if all(segment_ok(curve[j],curve[j+1]) for j in range(5)):out.extend(curve)
  else:out.append(b)
 out.append(reduced[-1]);return out
for r in roads:
 if r['kind'] in ['Collector','Access lane']:r['points']=smooth(r['points'])
road_area=unary_union([LineString(r['points']).buffer(r['width']/2,cap_style=2,join_style=1,quad_segs=3) for r in roads]).buffer(0)
# Reconnect branch ends displaced by centreline smoothing. New links are checked
# against inflated building/column obstacles before they join the pavement union.
for attempt in range(20):
 if road_area.geom_type=='Polygon':break
 largest=max(road_area.geoms,key=lambda p:p.area)
 inside=[];outside=[]
 for r in roads:
  line=LineString(r['points']);mid=line.interpolate(.5,normalized=True)
  (inside if largest.buffer(.01).covers(mid) else outside).append(line)
 candidates=[]
 for a in inside:
  for b in outside:
   p,q=nearest_points(a,b);candidates.append((p.distance(q),(p.x,p.y),(q.x,q.y)))
 candidates.sort()
 chosen=next(((a,b) for d,a,b in candidates if d>1e-5 and segment_ok(a,b)),None)
 assert chosen is not None,'No clear inter-street junction'
 road(list(chosen),64,'Junction link')
 road_area=unary_union([road_area,LineString(chosen).buffer(32,cap_style=2,join_style=1)])
else:raise AssertionError('Disconnected road topology')
# Reduce sub-stud boundary vertices before triangulation, retaining intersection checks.
road_area=road_area.simplify(.65,preserve_topology=True)
# Include the guardian plaza in the same surface so intersections cannot z-fight.
footprints=unary_union(polys)
forecourts=[]
for b,p in zip(buildings,polys):
 if 'roadAccess' not in b:continue
 a=Point(b['roadAccess']);q=nearest_points(a,p)[1]
 forecourts.append(LineString([a,q]).buffer(22,cap_style=2).difference(footprints.buffer(.05)))
road_area=unary_union([road_area,box(-450,6700,450,7500),box(-80,7490,80,7574.9)]+forecourts)
for b,p in zip(buildings,polys):
 assert not road_area.intersects(p),(b['id'],'Road intersects building',[(r['kind'],r['points'][:2]) for r in roads if LineString(r['points']).buffer(r['width']/2).intersects(p)])
assert road_area.geom_type=='Polygon',('Road network disconnected',[(round(q.area,2),list(q.bounds)) for q in road_area.geoms])
for b in buildings:
 if 'roadAccess' in b:assert road_area.buffer(1e-6).covers(Point(b['roadAccess']))
print(f'{len(roads)} connected street routes; all footprints clear.',flush=True)
# Native scene helpers reuse the tested triangular prism writer.
records=base['records'];records.clear();block=base['block'];write=base['write_model'];prop=base['prop']
def triangle(name,a,b,c,thick,color,roof=False,solid=True,alpha=0):
 # Roblox BaseParts may not exceed 2048 studs on an axis.
 a,b,c=max([(a,b,c),(b,c,a),(c,a,b)],key=lambda t:math.dist(t[0],t[2]))
 if math.dist(a,c)>1500:
  mid=[(a[k]+c[k])/2 for k in range(3)]
  triangle(name,a,b,mid,thick,color,roof,solid,alpha);triangle(name,mid,b,c,thick,color,roof,solid,alpha)
 else:base['triangle'](name,a,b,c,thick,color,roof,solid,alpha)
def save(name,group):
 path=OUT/(name+'.rbxmx');write(path,name,records);E.parse(path);group[:]=copy.deepcopy(records);records.clear();return path
scene={}
def surface(area,name,color,thick=2,lift=1.15):
 for za,zb in [(-1000,1600),(1600,1800),(1800,3200),(3200,3400),(3400,5600),(5600,5800),(5800,8500)]:
  clipped=area.intersection(box(-5000,za,5000,zb))
  for tri in constrained_delaunay_triangles(clipped).geoms:
   verts=list(tri.exterior.coords)[:3]
   if tri.area<.05:continue
   triangle(name,*[[x,ground(z)+lift,z] for x,z in verts],thick,color)
def beam(name,a,b,width,color,solid=False):
 vec=[b[k]-a[k] for k in range(3)];length=math.sqrt(sum(v*v for v in vec))
 if length<.01:return
 ez=[v/length for v in vec];ex=[ez[2],0,-ez[0]];n=math.sqrt(sum(v*v for v in ex))
 if n<1e-6:ex=[1,0,0]
 else:ex=[v/n for v in ex]
 ey=[ez[1]*ex[2]-ez[2]*ex[1],ez[2]*ex[0]-ez[0]*ex[2],ez[0]*ex[1]-ez[1]*ex[0]]
 block(name,[width,width,length],[(a[k]+b[k])/2 for k in range(3)],color,solid=solid)
 records[-1]['matrix']=[ex[0],ey[0],ez[0],ex[1],ey[1],ez[1],ex[2],ey[2],ez[2]]
 records[-1]['material']=288
surface(road_area,'RoadSurface',[33,47,61])
sidewalk=road_area.buffer(7,join_style=1,quad_segs=2).difference(road_area)
surface(sidewalk,'RoadShoulder',[91,120,134],thick=2,lift=1.12)
# Sparse reflective lane dashes, excluding junctions and plaza.
for r in roads:
 if r['kind']!='Main road':continue
 line=LineString(r['points'])
 for distance in range(40,int(line.length)-20,75):
  a=line.interpolate(distance);b=line.interpolate(distance+24)
  if any(LineString(q['points']).distance(a)<q['width']/2+24 for q in roads if q is not r):continue
  beam('LaneDash',[a.x,ground(a.y)+1.3,a.y],[b.x,ground(b.y)+1.3,b.y],1.1,[176,213,221])
scene['roads']=[];save('RoadNetwork',scene['roads'])
# Reuse only temporary landscape solids, without old roads, proxies, water or rail guides.
old=json.loads((TMP/'glacier-blockout-scene.json').read_text())
keep={'RockTerrace','SnowShelf','TerraceRamp','ArrivalApron','GuardianLand','GlacierWall','RearGlacierWall','IceColumnFacet','RoadBridge'}
seen=set()
for p in old:
 if p['name'] not in keep:continue
 if 'polygon' in p:
  key=(p['name'],tuple(tuple(v) for v in p['polygon']))
  if key in seen:continue
  seen.add(key);triangle(p['name'],*p['polygon'],p['size'][0],p['color'],alpha=p['alpha'])
 elif max(p['size'])>1500:
  axis=max(range(3),key=lambda k:p['size'][k]);count=math.ceil(p['size'][axis]/1500)
  for i in range(count):
   part=copy.deepcopy(p);part['size'][axis]/=count;part['pos'][axis]+=(-p['size'][axis]/2)+(i+.5)*part['size'][axis];records.append(part)
 else:records.append(p)
# Bridge underdecks sit below the continuous road surface.
scene['terrainProxy']=[];save('TerrainProxy',scene['terrainProxy'])
# Separate guide polylines make the manual terrain workflow explicit and removable.
guides=[]
def guide(name,points,color,width=3):
 guides.append({'name':name,'points':points,'color':color})
 for a,b in zip(points,points[1:]):beam(name,a,b,width,color)
for side in [-1,1]:
 points=[warp(side*240,ground(z)+5,z) for z in range(0,6651,50)]
 guide('RIFT_EDGE_CYAN',points,[44,224,255])
# Coastline wraps the mouth; original coast is gently scalloped rather than a straight cut.
for side in [-1,1]:
 points=[]
 for x in range(240,2451,45):
  z=-35+55*math.sin(x/330)+28*math.sin(x/115)
  points.append(warp(side*x,25,z))
 guide('COASTLINE_GREEN',points,[88,255,148])
for z in [2300,3500,4700,6100]:
 a=warp(0,ground(z)+5,z);b=warp(0,-880,z)
 guide('RIFT_DEPTH_GUIDE', [a,b],[237,175,63],2)
 block('DepthLabel',[110,1,90],[a[0],a[1]+1,z],[45,57,65],solid=False,text='RISS / -900')
scene['guides']=[];save('TerrainGuides',scene['guides'])
# Atmosphere and physical dressing in the chasm. No terrain voxels are written.
for z in range(1820,2460,95):
 for side in [-1,1]:
  x,y,zz=warp(side*rng.uniform(115,205),rng.uniform(-8,6),z+rng.uniform(-25,25))
  block('FracturedFjordIce',[rng.uniform(42,95),rng.uniform(14,30),rng.uniform(45,100)],[x,y,zz],[152,216,230],rotation=rng.uniform(-.18,.18))
  records[-1]['yaw']=rng.uniform(-.7,.7)
for z in range(2450,6520,235):
 for side in [-1,1]:
  x,_,zz=warp(side*rng.uniform(165,220),0,z+rng.uniform(-55,55));depth=rng.uniform(-340,-95)
  block('RiftRockLedge',[rng.uniform(50,100),rng.uniform(45,95),rng.uniform(75,150)],[x,depth,zz],[33,46,55],rotation=rng.uniform(-.25,.25))
  records[-1]['yaw']=rng.uniform(-.5,.5)
  if rng.random()<.5:block('HangingIceShard',[rng.uniform(14,28),rng.uniform(100,180),rng.uniform(25,55)],[x,depth+35,zz],[110,187,212],alpha=.12)
for z in [2870,3850,4980,5940]:
 center=warp(rng.uniform(-80,80),-670,z)
 for j in range(5):
  a=[center[0]+rng.uniform(-50,50),-670+rng.uniform(-12,12),z+j*32];b=[center[0]+rng.uniform(-50,50),-665+rng.uniform(-12,12),z+(j+1)*32]
  beam('DeepThermalGlow',a,b,5,[255,123,34]);records[-1]['light']=True
for z in range(2050,6510,220):
 x,_,zz=warp(65*math.sin(z/180),0,z)
 block('RiftMistEmitter',[1,1,1],[x,-115,zz],[100,150,165],alpha=1,solid=False);records[-1]['smoke']={'size':95,'opacity':.16,'rise':2,'color':[.36,.48,.53]}
for z in [2860,3830,4970,5920]:
 x,_,zz=warp(70*math.sin(z/350),0,z)
 block('ThermalSteamEmitter',[1,1,1],[x,-250,zz],[150,180,185],alpha=1,solid=False);records[-1]['smoke']={'size':55,'opacity':.28,'rise':12,'color':[.65,.73,.74]}
# A dark visual floor suggests further depth, to be replaced/covered by sculpted terrain.
for z in range(2100,6550,150):
 block('RiftDarkness',[440,8,150],warp(0,-910,z),[5,9,16],solid=False)
scene['rift']=[];riftpath=save('RiftDetails',scene['rift'])
# Apply optional materials, yaw, lights and native Smoke omitted by the blockout writer.
for name,key in [('RoadNetwork','roads'),('TerrainGuides','guides'),('RiftDetails','rift')]:
 path=OUT/(name+'.rbxmx');tree=E.parse(path);parts=tree.findall('./Item/Item')
 for i,(item,p) in enumerate(zip(parts,scene[key])):
  pr=item.find('Properties');pr.find("token[@name='Material']").text=str(p.get('material',272))
  prop(pr,'bool','CanQuery','false' if not p['solid'] else 'true')
  if p.get('yaw'):
   a=p['yaw'];c,s=math.cos(a),math.sin(a);cf=pr.find("CoordinateFrame[@name='CFrame']");oldm=[[float(cf.find(f'R{r}{k}').text) for k in range(3)] for r in range(3)];rot=[[c,0,s],[0,1,0],[-s,0,c]]
   for r in range(3):
    for k in range(3):cf.find(f'R{r}{k}').text=str(sum(rot[r][j]*oldm[j][k] for j in range(3)))
  if p.get('smoke'):
   smoke=E.SubElement(item,'Item',{'class':'Smoke','referent':f'Smoke{i}'});sp=E.SubElement(smoke,'Properties');prop(sp,'string','Name',p['name']);prop(sp,'bool','Enabled','true');data=p['smoke']
   for tag,value in [('Size',data['size']),('Opacity',data['opacity']),('RiseVelocity',data['rise'])]:prop(sp,'float',tag,value)
   col=E.SubElement(sp,'Color3',name='Color')
   for tag,value in zip('RGB',data['color']):E.SubElement(col,tag).text=str(value)
  if p.get('light'):
   li=E.SubElement(item,'Item',{'class':'PointLight','referent':f'Light{i}'});lp=E.SubElement(li,'Properties');prop(lp,'float','Brightness',.8);prop(lp,'float','Range',42);col=E.SubElement(lp,'Color3',name='Color')
   for tag,value in zip('RGB',[1,.28,.06]):E.SubElement(col,tag).text=str(value)
 E.indent(tree);tree.write(path,encoding='utf-8',xml_declaration=True)
# All real buildings remain independently selectable/destructible.
workspace={'$className':'Workspace','$ignoreUnknownInstances':True,'MegaCityBlockout':{'$className':'Model','$ignoreUnknownInstances':False},'MegaCityIceCeiling':{'$className':'Model','$ignoreUnknownInstances':False},'MegaCity':{'$className':'Folder','Buildings':{'$className':'Folder',**{b['id']:{'$path':b['placedPackage']} for b in buildings}},**{name:{'$path':f'packages/mega-city-final/{name}.rbxmx'} for name in ['RoadNetwork','RiftDetails','TerrainGuides','TerrainProxy']}}}
project={'name':'MegaCityFinalAssembly','servePort':34873,'tree':{'$className':'DataModel','Workspace':workspace}}
(ROOT/'mega-city-final.project.json').write_text(json.dumps(project,indent=2)+'\n')
# Standard entry point now opens the assembled city; individual review projects remain usable.
default=copy.deepcopy(project);default['servePort']=34872
(ROOT/'default.project.json').write_text(json.dumps(default,indent=2)+'\n')
final={'status':'Native city assembly; terrain sculpt and Studio playtest pending','buildings':buildings,'roads':roads,'guides':guides,'pillars':pillars,'typeCounts':dict(sorted(counts.items())),'equalTypeNeighbourEdges':sum(assets[i]==assets[j] for i,j in neighbours),'sourcePlan':'00-glacier-layout.json','roadWidth':{'main':180,'bridge':220,'local':64},'terrainInstructions':'Cyan=rim; green=coast; amber=depth. Preserve native Terrain. Remove TerrainProxy after sculpting.'}
(DOC/'00-mega-city-final-layout.json').write_text(json.dumps(final,indent=2)+'\n')
(TMP/'mega-city-final-scene.json').write_text(json.dumps(scene))
print(json.dumps({'buildings':85,'nativeParts':sum(len(t.findall('.//Item[@class="Part"]'))*counts[a] for a,t in cached.items()),'roads':len(roads),'sameTypeNeighbourPairs':final['equalTypeNeighbourEdges'],'streetSurfaceConnected':True,'outputFiles':len(list(OUT.glob('*.rbxmx'))),'studioTest':False}),flush=True)
