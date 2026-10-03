"""MC-00 spatial draft: measured building envelopes, no gameplay/destruction scripts."""
from pathlib import Path
import math,json,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'packages/mega-city';records=[];buildings=[]
COLORS={'Transit Nexus':(64,166,209),'Neon Quarter':(202,74,174),'Stack District':(217,159,70),'Reactor Works':(206,105,49),'Research Enclave':(108,187,114),'Corporate Heights':(116,121,220)}
bounds={}
for p in sorted(OUT.glob('*.rbxmx')):
 if not p.name[:2].isdigit() or p.name.startswith('00-') or 'rail-straight' in p.name:continue
 lo=[1e9]*3;hi=[-1e9]*3
 for it in E.parse(p).findall('.//Item[@class="Part"]'):
  pr=it.find('Properties')
  if pr.find("string[@name='Name']").text=='Origin':continue
  sz=pr.find("Vector3[@name='size']");cf=pr.find("CoordinateFrame[@name='CFrame']")
  if sz is None or cf is None:continue
  size=[float(sz.find(k).text) for k in 'XYZ'];pos=[float(cf.find(k).text) for k in 'XYZ']
  ext=[sum(abs(float(cf.find('R'+str(i)+str(j)).text))*size[j]/2 for j in range(3)) for i in range(3)]
  for i in range(3):lo[i]=min(lo[i],pos[i]-ext[i]);hi[i]=max(hi[i],pos[i]+ext[i])
 bounds[int(p.name[:2])]={'package':str(p.relative_to(ROOT)),'min':lo,'max':hi,'size':[hi[i]-lo[i] for i in range(3)]}
def block(name,size,pos,color,alpha=0,rotation=0,roof=False,text=None,solid=True):
 records.append(dict(name=name,size=size,pos=pos,color=color,alpha=alpha,rotation=rotation,roof=roof,text=text,solid=solid))
def add_building(asset,district,x,z,ground):
 n=sum(b['asset']==asset for b in buildings)+1;w,h,d=bounds[asset]['size'];name=f'MC-{asset:02d}-{n:02d}'
 buildings.append(dict(id=name,asset=asset,district=district,center=[x,ground+h/2,z],ground=ground,size=[w,h,d],source=bounds[asset]))
 block(name,[w,h,d],[x,ground+h/2,z],COLORS[district],text=name)
 block(name+' Plot',[w+20,1,d+20],[x,ground+.55,z],COLORS[district])
def place(district,counts,side,xs,zs,ground):
 ids=[a for a,n in counts for _ in range(n)];slots=[(side*x,z) for z in zs for x in xs]
 assert len(slots)>=len(ids)
 for a,(x,z) in zip(ids,slots):add_building(a,district,x,z,ground if ground is not None else (20 if z<1600 else 40 if z<3200 else 60 if z<5600 else 80))
# Positive Z points inland. Map orientation relative to world north is deliberately unspecified.
place('Transit Nexus',[(1,1),(2,5),(3,3)],-1,[600,1040,1480],[500,940,1380],20)
place('Neon Quarter',[(4,4),(5,6),(6,2),(7,5)],-1,[600,1000,1400,1800],[1920,2250,2580,2910,3100],40)
place('Stack District',[(8,14),(9,7),(10,4)],-1,[600,1000,1400,1800],[3540,3870,4200,4530,4860,5190,5500],60)
place('Reactor Works',[(11,2),(12,4),(13,6)],1,[650,1200,1750],[650,1180,2300,2850],None)
place('Research Enclave',[(14,1),(15,5),(16,3),(17,1)],1,[650,1200,1750],[3650,4300,4950,5470],60)
place('Corporate Heights',[(18,3),(19,3)],-1,[650,1150,1650],[6100,6480],80)
place('Corporate Heights',[(19,2),(20,3)],1,[650,1150,1650],[6100,6480],80)
add_building(21,'Corporate Heights',0,7700,80)
# Continuous land shelves with explicit rises and broad ramps at both sides of the rift.
segments=[(0,1600,20),(1800,3200,40),(3400,5600,60),(5800,8150,80)]
for side in [-1,1]:
 for start,end,y in segments:
  block('RockTerrace',[2160,220,end-start],[side*1320,y-110,(start+end)/2],[66,86,100])
  block('SnowShelf',[2160,2,end-start],[side*1320,y-1,(start+end)/2],[188,217,230])
  block('MainRoad',[180,1,end-start],[side*360,y+.5,(start+end)/2],[32,48,66])
 for za,zb,ya,yb in [(1600,1800,20,40),(3200,3400,40,60),(5600,5800,60,80)]:
  length=math.hypot(zb-za,yb-ya);angle=-math.atan2(yb-ya,zb-za)
  block('TerraceRamp',[2160,12,length],[side*1320,(ya+yb)/2-6,(za+zb)/2],[116,145,161],rotation=angle)
  block('MainRoadRamp',[180,1,length],[side*360,(ya+yb)/2+.5,(za+zb)/2],[32,48,66],rotation=angle)
# Cross streets between neighbourhoods, and two broad rift crossings.
for z,y in [(1700,30),(3300,50),(5700,70),(6750,80)]:
 for side in [-1,1]:block('CrossStreet',[1540,1,180],[side*1190,y+1,z],[38,54,70])
for z,y in [(1700,30),(5700,70)]:
 block('RoadBridge',[900,12,220],[0,y-6,z],[67,99,119])
 for dz in [-105,105]:block('BridgeEdge',[900,3,3],[0,y+1.5,z+dz],[70,220,241])
# Open arrival apron and a land connection before the guardian arena.
block('ArrivalApron',[800,30,330],[-650,5,-165],[72,100,118],text='KANAGAWA / ARRIVAL')
block('GuardianLand',[1100,220,1500],[0,-30,7400],[69,88,101])
block('GuardianPlaza',[900,2,800],[0,80,7100],[105,118,151],text='GUARDIAN PLAZA')
block('FinalApproach',[4200,1,180],[0,81,6750],[38,54,70])
# Sea access is open; inland the water ends at broken ice and a deeper visual chasm.
block('OpenSea',[4700,8,1250],[0,-8,-625],[20,86,121],alpha=.22,solid=False)
block('Fjord',[480,8,1650],[0,-8,825],[18,94,132],alpha=.22,solid=False)
block('DeepRift',[470,8,4900],[0,-900,4150],[7,12,24],solid=False)
for z in [1800,2050,2300]:
 for side in [-1,1]:block('BrokenIce',[95,18,120],[side*195,0,z],[133,207,228])
# Six colossal support columns, outside all building envelopes and roads.
pillars=[]
for side in [-1,1]:
 for z in [1550,3350,5700]:
  x=side*2190;ground=20 if z==1550 else 50 if z==3350 else 70
  pillars.append({'x':x,'z':z,'radius':200,'ground':ground})
  block('IceColumnFoot',[400,120,400],[x,ground+60,z],[137,205,230],alpha=.1)
  block('IceColumn',[290,790,290],[x,ground+515,z],[111,186,219],alpha=.13)
  block('IceColumnCapital',[540,150,540],[x,ground+985,z],[157,217,235],alpha=.1)
# Outer glacier enclosure and removable ceiling; central sky opening is preserved.
for side in [-1,1]:
 block('GlacierWall',[260,1100,8200],[side*2530,350,4050],[139,200,225])
 for start,end,y in segments:
  block('GlacierCeiling',[1950,150,end-start],[side*1425,1050+y,(start+end)/2],[164,218,237],roof=True)
block('RearGlacierWall',[5320,1100,200],[0,350,8250],[143,205,229])
# Elevated railway alignment only: centreline guide, not final rails or station connections.
for side in [-1,1]:block('RailRouteGuide',[10,8,4650],[side*360,260,3825],[237,82,207],solid=False)
for z in [1500,6150]:block('RailRouteGuide',[720,8,10],[0,260,z],[237,82,207],solid=False)
# Warp the draft into a glacier-carved plan; triangles keep joined surfaces coplanar
# without overlapping faces (avoids texture flicker along the curved shelves).
def warp(x,y,z):
 fade=max(0,min(1,(7200-z)/900))
 bend=300*math.sin(z/1100)*math.sin(math.pi*max(0,z)/8150)*fade
 scale=1+.10*math.sin(z/740+.5)*fade
 edge=.065*(x/2400)**3*2400*math.sin(z/390+.7)*fade
 return [x*scale+bend+edge,y,z]
def sub(a,b):return [x-y for x,y in zip(a,b)]
def add(a,b):return [x+y for x,y in zip(a,b)]
def mul(a,t):return [x*t for x in a]
def dot(a,b):return sum(x*y for x,y in zip(a,b))
def cross(a,b):return [a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]]
def norm(a):return math.sqrt(dot(a,a))
def triangle(name,a,b,c,thick,color,roof=False,solid=True,alpha=0):
 # Longest side is the base so the perpendicular foot lies inside it.
 a,b,c=max([(a,b,c),(b,c,a),(c,a,b)],key=lambda t:norm(sub(t[2],t[0])))
 u=mul(sub(c,a),1/norm(sub(c,a)));foot=add(a,mul(u,dot(sub(b,a),u)))
 height=norm(sub(b,foot))
 if height<1e-6:return
 ey=mul(sub(b,foot),1/height)
 for end in [a,c]:
  length=norm(sub(foot,end))
  if length<1e-6:continue
  ez=mul(sub(foot,end),1/length);ex=cross(ey,ez)
  # Offset towards the lower side of a horizontal surface.
  normal=ex if ex[1]>=0 else mul(ex,-1)
  center=sub(mul(add(end,b),.5),mul(normal,thick/2))
  block(name,[thick,height,length],center,color,alpha=alpha,roof=roof,solid=solid)
  records[-1].update(kind='WedgePart',matrix=[ex[0],ey[0],ez[0],ex[1],ey[1],ez[1],ex[2],ey[2],ez[2]],polygon=[a,b,c])
def ribbon(p):
 x,y,z=p['pos'];w,h,d=p['size'];angle=p['rotation']
 # Existing X-axis ramps rise towards positive Z.
 count=max(1,math.ceil(d/180))
 for i in range(count):
  za=z-d/2+d*i/count;zb=z-d/2+d*(i+1)/count
  ya=y+h/2-math.sin(angle)*(za-z);yb=y+h/2-math.sin(angle)*(zb-z)
  corners=[warp(x-w/2,ya,za),warp(x+w/2,ya,za),warp(x+w/2,yb,zb),warp(x-w/2,yb,zb)]
  triangle(p['name'],*corners[:3],h,p['color'],p['roof'],p['solid'],p['alpha'])
  triangle(p['name'],corners[0],corners[2],corners[3],h,p['color'],p['roof'],p['solid'],p['alpha'])
original=records;records=[]
# Jitter plots independently, then follow the glacier's large-scale curve.
for i,b in enumerate(buildings):
 if b['asset']==21:b['yaw']=0;continue
 x,y,z=b['center'];x+=60*math.sin(i*2.399);z+=45*math.cos(i*1.73)
 b['center']=warp(x,y,z);b['yaw']=.16*math.sin(i*1.37)
for p in original:
 if p['name'].startswith('MC-'):
  key=p['name'].split(' ')[0];b=next(b for b in buildings if b['id']==key)
  p['pos'][0]=b['center'][0];p['pos'][2]=b['center'][2]
  c=math.cos(b['yaw']);s=math.sin(b['yaw']);p['matrix']=[c,0,s,0,1,0,-s,0,c];records.append(p)
 elif p['name'].startswith('IceColumn'):continue
 elif p['name'] in ['GuardianLand','GuardianPlaza','FinalApproach','RearGlacierWall','OpenSea']:
  records.append(p)
 else:ribbon(p)
# Faceted, asymmetric ice pillars with tapered shafts and spreading capitals.
for index,p in enumerate(pillars):
 oldx,z=p['x'],p['z'];p['x'],_,p['z']=warp(oldx,0,z)
 x,z=p['x'],p['z'];g=p['ground'];p['radius']=220
 rings=[]
 for level,(y,radius) in enumerate([(g,220),(g+130,155),(g+560,125),(g+900,175),(g+1060,310)]):
  ring=[]
  for k in range(9):
   angle=2*math.pi*k/9;rr=radius*(1+.12*math.sin(k*2.3+index))
   ring.append([x+rr*math.cos(angle)+level*9*math.sin(index),y,z+rr*math.sin(angle)+level*7*math.cos(index)])
  rings.append(ring)
 for low,high in zip(rings,rings[1:]):
  for k in range(9):
   j=(k+1)%9;col=[119+((k+index)%3)*13,190+((k+index)%3)*10,222+((k+index)%3)*6]
   triangle('IceColumnFacet',low[k],low[j],high[j],12,col)
   triangle('IceColumnFacet',low[k],high[j],high[k],12,col)
 p['footprint']=[[v[0],v[2]] for v in rings[0]]
def footprint(b):
 w,h,d=b['size'];c=abs(math.cos(b['yaw']));s=abs(math.sin(b['yaw']));return [w*c+d*s,h,d*c+w*s]
# Bounds and clearance verification for this coarse layout.
assert len(buildings)==85
for i,a in enumerate(buildings):
 for b in buildings[i+1:]:
  overlap=all(abs(a['center'][j]-b['center'][j])<(footprint(a)[j]+footprint(b)[j])/2 for j in [0,2])
  assert not overlap,(a['id'],b['id'])
 for p in pillars:
  dx=max(abs(a['center'][0]-p['x'])-footprint(a)[0]/2,0);dz=max(abs(a['center'][2]-p['z'])-footprint(a)[2]/2,0)
  assert math.hypot(dx,dz)>p['radius'],a['id']
 assert a['ground']+a['size'][1]<1050,'Roof clearance'
# Native rbxmx writer. Proxies are explicitly not KaijuHouse buildings.
def prop(pr,tag,name,value):E.SubElement(pr,tag,name=name).text=str(value)
def write_model(path,name,subset):
 root=E.Element('roblox',version='4');model=E.SubElement(root,'Item',{'class':'Model','referent':'M'});mp=E.SubElement(model,'Properties');prop(mp,'string','Name',name)
 for i,p in enumerate(subset):
  it=E.SubElement(model,'Item',{'class':p.get('kind','Part'),'referent':f'P{i}'});pr=E.SubElement(it,'Properties');prop(pr,'string','Name',p['name']);prop(pr,'bool','Anchored','true');prop(pr,'bool','CanCollide',str(p['solid']).lower());prop(pr,'bool','CanTouch','false');prop(pr,'float','Transparency',p['alpha']);prop(pr,'token','Material',272)
  r,g,b=p['color'];prop(pr,'Color3uint8','Color3uint8',(255<<24)|(r<<16)|(g<<8)|b)
  v=E.SubElement(pr,'Vector3',name='size')
  for k,n in zip('XYZ',p['size']):E.SubElement(v,k).text=str(n)
  c,s=math.cos(p['rotation']),math.sin(p['rotation']);cf=E.SubElement(pr,'CoordinateFrame',name='CFrame')
  for k,n in zip(['X','Y','Z']+['R'+str(a)+str(b) for a in range(3) for b in range(3)],p['pos']+p.get('matrix',[1,0,0,0,c,-s,0,s,c])):E.SubElement(cf,k).text=str(n)
  if p['text']:
   gui=E.SubElement(it,'Item',{'class':'SurfaceGui','referent':f'G{i}'});gp=E.SubElement(gui,'Properties');prop(gp,'string','Name','BlockoutLabel');prop(gp,'token','Face',1);prop(gp,'token','SizingMode',0);prop(gp,'bool','AlwaysOnTop','false')
   cv=E.SubElement(gp,'Vector2',name='CanvasSize');E.SubElement(cv,'X').text='600';E.SubElement(cv,'Y').text='200'
   lab=E.SubElement(gui,'Item',{'class':'TextLabel','referent':f'T{i}'});lp=E.SubElement(lab,'Properties');prop(lp,'string','Text',p['text']);prop(lp,'bool','TextScaled','true');prop(lp,'token','Font',12);prop(lp,'float','BackgroundTransparency',1)
   col=E.SubElement(lp,'Color3',name='TextColor3')
   for k in 'RGB':E.SubElement(col,k).text='1'
   ud=E.SubElement(lp,'UDim2',name='Size')
   for k,n in [('XS',1),('XO',0),('YS',1),('YO',0)]:E.SubElement(ud,k).text=str(n)
 E.indent(root);E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
write_model(OUT/'00-glacier-city-blockout.rbxmx','MegaCityBlockout',[p for p in records if not p['roof']])
write_model(OUT/'00-glacier-ceiling-blockout.rbxmx','MegaCityIceCeiling',[p for p in records if p['roof']])
doc=ROOT/'docs/mega-city';(doc/'plans').mkdir(exist_ok=True)
(doc/'plans/00-glacier-layout.json').write_text(json.dumps({'status':'Draft; Studio traversal and camera untested','axis':'positive Z inland; compass orientation unspecified','buildings':buildings,'pillars':pillars,'districtCounts':{d:sum(b['district']==d for b in buildings) for d in COLORS}},indent=2)+'\n')
(ROOT/'tmp/mega-city/glacier-blockout-scene.json').write_text(json.dumps(records))
print(json.dumps({'buildings':len(buildings),'environmentAndProxyParts':len(records),'pillars':len(pillars),'overlappingBuildings':0,'studioTest':False}))
