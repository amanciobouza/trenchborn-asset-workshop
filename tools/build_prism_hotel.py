"""Deterministic Roblox Parts-only MC-05 model and matching Rojo module/export.
Run from repository root: python tools/build_prism_hotel.py
No external packages required. Studio visual acceptance remains manual.
"""
from pathlib import Path
import math, json, base64, struct, xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'src/ReplicatedStorage/TrenchbornAssetWorkshop'
PALETTE = {'metal':(29,46,57),'edge':(65,79,94),'concrete':(89,105,123),
 'glass':(35,100,142),'snow':(211,229,241),'cyan':(44,215,255),
 'pink':(241,58,193),'warm':(255,176,77),'dark':(15,23,34)}
parts=[]
def part(name,size,pos,color='metal',material='Metal',rotation=(0,0,0),shape='Block',solid=True,alpha=0,text=None):
    p=dict(name=name,size=list(size),pos=list(pos),color=list(PALETTE[color]),material=material,
        rotation=list(rotation),shape=shape,solid=solid,alpha=alpha)
    if text is not None:p['text']=text
    parts.append(p)
    return p
def trim(name,size,pos,color='cyan',rotation=(0,0,0)):
    return part(name,size,pos,color,'Neon',rotation,solid=False)
def snow(name,w,d,x,y,z,rotation=(0,0,0)):
    return part(name,(w,.5,d),(x,y,z),'snow','SmoothPlastic',rotation,solid=False)
def beam(name,a,b,width,color='edge'):
    # Supports arbitrary direction: stored as endpoints, converted by both exporters.
    length=math.dist(a,b)
    p=part(name,(width,length,width),tuple((a[i]+b[i])/2 for i in range(3)),color)
    p['beam']=[a,b]
    return p
def sign(name,label,size,pos,color='cyan',rotation=(0,0,0)):
    p=part(name,size,pos,'dark',rotation=rotation,solid=False,text=label)
    p['textColor']=list(PALETTE[color]);return p
def vent(x,y,z,w=12):
    part('RoofVent',(w,6,10),(x,y,z),'edge')
    for k in range(5):part('VentLouvre',(w-2,.45,.45),(x,y-2+k,z-5.3),'dark',solid=False)
    snow('VentSnow',w,10,x,y+3.3,z)
def pipe(name,a,b,r=1.2):
    p=beam(name,a,b,r*2,'edge');p['shape']='CylinderY';return p

# MC-05: faceted octagonal tower, hollow lobby/lounge, front faces -Z.
part('Foundation',(136,4,114),(0,2,0),'concrete','Concrete')
part('LobbyFloor',(126,2,100),(0,5,0),'edge')
# Broad podium: transparent frontage with open central entrance.
for x in [-61,61]:part('PodiumSide',(3,31,96),(x,21,0),'metal')
part('PodiumRear',(124,31,3),(0,21,47),'metal')
for x in [-53,-39,-25,25,39,53]:
    part('LobbyGlass',(12,26,.6),(x,20,-48),'glass','Glass',alpha=.5)
    part('LobbyMullion',(1.2,29,1.2),(x-7,20,-48),'edge')
    trim('LobbyWarm',(10,.6,1),(x,32,-45),'warm')
for x in [-17,17]:part('EntryPost',(2,29,3),(x,20,-48),'edge')
part('LobbyHeader',(125,5,5),(0,35,-47),'edge')
part('PodiumRoof',(132,3,106),(0,39,0),'metal')
snow('PodiumRoofSnow',132,106,0,40.8,0)
for z in [-53.5,53.5]:trim('PodiumBand',(130,.7,.7),(0,39,z),'cyan')
# Real furnishings visible from the lobby.
part('ReceptionDesk',(28,5,7),(0,8.5,24),'edge')
trim('ReceptionFace',(24,1,.6),(0,10,20),'warm')
for x in [-40,40]:
    part('LobbySofa',(14,3,7),(x,8,-10),'metal')
    part('SofaBack',(14,4,2),(x,10,-7),'edge')
    part('LobbyTable',(8,2,5),(x,7,-22),'edge')
    for z in [-26,26]:part('LobbyColumn',(3,31,3),(x,21,z),'edge')
# Entrance canopy with sloped pair of roof blades and attached snow.
for x,angle in [(-17,-8),(17,8)]:
    part('CanopyRoof',(35,2,26),(x,26,-58),'edge',rotation=(0,0,angle))
    snow('CanopySnow',35,26,x-math.sin(math.radians(angle))*1.3,26+math.cos(math.radians(angle))*1.3,-58,(0,0,angle))
for x in [-32,32]:
    part('CanopyPost',(2,23,2),(x,15,-68),'edge')
    beam('CanopyBrace',(x,18,-67),(0,27,-67),.7,'warm')
sign('EntranceName','PRISM HOTEL',(52,6,1),(0,24,-71.5),'pink')
for i in range(5):part('EntranceStep',(58,1,2),(0,5-i,-53-i*2),'concrete','Concrete')
# Setback terrace wings; deck includes only attached roof terraces.
for x in [-48,48]:
    part('TerraceWing',(24,12,64),(x,47,10),'metal')
    for z in [-23,43]:
        part('TerraceWingGlass',(19,8,.6),(x,48,z),'glass','Glass',alpha=.4)
        trim('TerraceWarm',(17,.5,.7),(x,45,z-.4),'warm')
    part('TerraceCap',(29,2,70),(x,54,10),'edge')
    snow('TerraceSnow',29,70,x,55.3,10)
    trim('TerraceNeon',(27,.6,.7),(x,54,-25.5),'pink')
# Octagonal floorplate: rectangular strips plus bevel edge spans.
poly=[(-23,-32),(23,-32),(32,-23),(32,23),(23,32),(-23,32),(-32,23),(-32,-23)]
edges=list(zip(poly,poly[1:]+poly[:1]))
def facade(name,a,b,y,height,thickness,color,material='Metal',alpha=0,inset=0):
    dx,dz=b[0]-a[0],b[1]-a[1];length=math.hypot(dx,dz)
    x,z=(a[0]+b[0])/2,(a[1]+b[1])/2
    return part(name,(length-inset,height,thickness),(x,y,z),color,material,(0,-math.degrees(math.atan2(dz,dx)),0),alpha=alpha)
# Glazed transition fills the gap from podium roof to first tower floor.
for a,b in edges:facade('TowerBaseGlass',a,b,48,14,.6,'glass','Glass',.45,inset=.8)
for x,z in poly:part('TowerBaseColumn',(2,15,2),(x,48,z),'edge')
for level in range(12):
    y=56+level*14
    part('TowerFloorCentre',(46,1.5,64),(0,y,0),'edge')
    for x in [-27.5,27.5]:part('TowerFloorSide',(9,1.5,46),(x,y,0),'edge')
    for e,(a,b) in enumerate(edges):
        facade('FloorBand',a,b,y,1.8,1,'edge')
        facade('RoomGlass',a,b,y+7,12,.6,'glass','Glass',.4,inset=.8)
        # Warmer occupied rooms are selected deterministically.
        if (level+e)%3==0:
            dx,dz=b[0]-a[0],b[1]-a[1]
            nx,nz=dz/math.hypot(dx,dz),-dx/math.hypot(dx,dz)
            aa=(a[0]-nx*.9,a[1]-nz*.9);bb=(b[0]-nx*.9,b[1]-nz*.9)
            pp=facade('RoomWarm',aa,bb,y+10,.65,.7,'warm','Neon',inset=3);pp['solid']=False
    # Small core is inside; no opaque blocks directly behind the glazing.
    part('ServiceCore',(10,13,12),(0,y+7,10),'metal')
for x,z in poly:
    part('CornerSpine',(1.7,170,1.7),(x,140,z),'metal')
    # Cyan edges sit outside the frame, with no coplanar surfaces.
    trim('TowerCyan',(.55,168,.55),(x*1.025,140,z*1.025),'cyan')
# Long slim mullions on the four broad faces.
for offset in [-12,0,12]:
    for z in [-32,32]:part('FacadeMullion',(.55,169,1),(offset,140,z),'edge')
    for x in [-32,32]:part('FacadeMullion',(1,169,.55),(x,140,offset),'edge')
# Solid asymmetric sign spine carries the vertical hotel identity.
part('SignSpine',(15,145,5),(-20,145,-35),'metal')
sign('PrismVertical','P\nR\nI\nS\nM',(12,76,1),(-20,172,-38),'pink')
sign('HotelLabel','HOTEL',(13,6,1),(-20,128,-38),'pink')
trim('SignTail',(.65,46,.7),(-20,99,-38),'pink')
for x in [-28,-12]:part('SignRib',(1.2,148,6),(x,145,-35),'edge')
part('TowerRoof',(67,3,67),(0,225,0),'metal')
snow('TowerRoofSnow',67,67,0,226.8,0)
# Projecting upper lounge with glass on all four sides and a hollow interior.
part('SkyLoungeFloor',(82,3,68),(8,229,0),'edge')
for z in [-33,33]:
    for x in [-25,-11,3,17,31,43]:
        part('LoungeWindow',(9.5 if x==43 else 12.5,15,.6),(x,239,z),'glass','Glass',alpha=.5)
        part('LoungeMullion',(1,18,1.2),(x-6.7,239,z),'edge')
        trim('LoungeWarm',(10,.6,.7),(x,246,z+(.9 if z<0 else -.9)),'warm')
for x in [-32,48]:
    part('LoungeSideGlass',(.6,15,64),(x,239,0),'glass','Glass',alpha=.5)
    for z in [-22,0,22]:part('LoungeSideMullion',(1.2,18,1),(x,239,z),'edge')
part('SkyLoungeRoof',(85,3,71),(8,250,0),'metal')
snow('SkyLoungeSnow',85,71,8,251.8,0)
for z in [-36,36]:trim('LoungeCyan',(84,.7,.7),(8,250,z),'cyan')
for x in [30,43]:beam('LoungeBrace',(24,214,22),(x,227,22),3)
for x in [-20,0,20,40]:
    part('LoungeTable',(6,2,6),(x,232,-18),'edge')
    part('LoungeSeat',(8,2,4),(x,232,-25),'metal')
sign('SkyLoungeName','SKY LOUNGE',(48,5,1),(8,229,-35),'cyan')
# Prism crown: open diamond cage with coloured crystalline layers and asymmetric fins.
part('CrownPlinth',(52,4,49),(0,254,0),'edge')
# Glowing elongated central prism, with crossed glass planes and 3D edge cage.
part('PrismCore',(10,33,10),(0,281,0),'cyan','Neon',rotation=(0,45,0),solid=False,alpha=.15)
for yaw in [0,60,120]:
    part('PrismGlass',(18,40,.7),(0,280,0),'glass','Glass',rotation=(0,yaw,0),solid=False,alpha=.4)
ring=[(0,280,-12),(12,280,0),(0,280,12),(-12,280,0)]
for i,a in enumerate(ring):
    for dest in [(0,309,0),(0,260,0),ring[(i+1)%4]]:
        pp=beam('PrismEdge',a,dest,.8,'cyan' if i%2==0 else 'pink');pp['material']='Neon';pp['solid']=False
for i,(x,z,h) in enumerate([(-23,-22,309),(23,-22,318),(23,22,302),(-23,22,297)]):
    beam('CrownFin',(x,256,z),(x*.62,h,z*.62),7,'edge')
    pp=beam('FinGlow',(x*.95,258,z*.95),(x*.6,h-2,z*.6),.7,'pink' if i%2 else 'cyan');pp['material']='Neon';pp['solid']=False
# Service detail on the rear podium roof: vents seated flush on the terrace.
for x in [-46,46]:vent(x,58,26,12)
for x in [-56,56]:pipe('PodiumDownpipe',(x,39,43),(x,7,43),1.2)
for x in [-43,43]:
    part('ServiceDoor',(16,20,1),(x,15,49),'edge')
    for y in [9,13,17,21]:part('ServiceSlat',(14,.5,.6),(x,y,49.8),'dark',solid=False)
sign('RearHotelName','PRISM HOTEL',(42,8,1),(0,25,49),'cyan',(0,180,0))

def matrix(p):
    if 'beam' in p:
        a,b=p['beam']; y=[(b[i]-a[i])/math.dist(a,b) for i in range(3)]
        ref=[0,0,1] if abs(y[2])<.9 else [1,0,0]
        x=[y[1]*ref[2]-y[2]*ref[1],y[2]*ref[0]-y[0]*ref[2],y[0]*ref[1]-y[1]*ref[0]]
        n=math.sqrt(sum(v*v for v in x));x=[v/n for v in x]
        z=[x[1]*y[2]-x[2]*y[1],x[2]*y[0]-x[0]*y[2],x[0]*y[1]-x[1]*y[0]]
        return [x[0],y[0],z[0],x[1],y[1],z[1],x[2],y[2],z[2]]
    a,b,c=[math.radians(v) for v in p['rotation']]
    cx,sx,cy,sy,cz,sz=math.cos(a),math.sin(a),math.cos(b),math.sin(b),math.cos(c),math.sin(c)
    return [cy*cz,-cy*sz,sy,cx*sz+sx*sy*cz,cx*cz-sx*sy*sz,-sx*cy,sx*sz-cx*sy*cz,sx*cz+cx*sy*sz,cx*cy]

spec=dict(SchemaVersion=1,AssetId='MC-05',AssetName='Prism Hotel',AssetClass='Building',City='MegaCity',
    EnergyType='Electric',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
    PerformanceBudget=dict(MaxVisibleParts=850,MaxGameplayHitboxes=1,PermanentLights=0,PermanentParticleEmitters=0,PerPartScripts=0))
for p in parts:p['matrix']=matrix(p)
spec['VisiblePartCount']=len(parts)

def lua(v):
    if isinstance(v,dict):return '{'+','.join('['+lua(k)+']='+lua(x) for k,x in v.items())+'}'
    if isinstance(v,(list,tuple)):return '{'+','.join(lua(x) for x in v)+'}'
    if isinstance(v,str):return json.dumps(v,ensure_ascii=False)
    if isinstance(v,bool):return 'true' if v else 'false'
    return repr(v)

def prop(parent,tag,name,value):
    e=ET.SubElement(parent,tag,name=name);e.text=str(value);return e
def item(parent,kind,name):
    e=ET.SubElement(parent,'Item',{'class':kind,'referent':'RBX'+str(item.count)});item.count+=1
    p=ET.SubElement(e,'Properties');prop(p,'string','Name',name);return e,p
item.count=1
def vec(props,name,v):
    el=ET.SubElement(props,'Vector3',name=name)
    for k,n in zip('XYZ',v):ET.SubElement(el,k).text=str(n)
def cf(props,name,pos,mat):
    el=ET.SubElement(props,'CoordinateFrame',name=name)
    for k,n in zip(['X','Y','Z']+['R'+str(i)+str(j) for i in range(3) for j in range(3)],pos+mat):ET.SubElement(el,k).text=str(n)
def attrs(d):
    b=struct.pack('<I',len(d))
    for k,v in d.items():
        kb=k.encode();b+=struct.pack('<I',len(kb))+kb
        if isinstance(v,str):s=v.encode();b+=b'\x02'+struct.pack('<I',len(s))+s
        elif isinstance(v,bool):b+=b'\x03'+bytes([int(v)])
        else:b+=b'\x06'+struct.pack('<d',v)
    return base64.b64encode(b).decode()
def add_sign(parent,p):
    gui,g=item(parent,'SurfaceGui','Sign');prop(g,'token','Face',5);prop(g,'token','SizingMode',0)
    # Keep each text row within TextScaled's font-size ceiling.
    height = 100 * (p['text'].count('\n') + 1)
    canvas = ET.SubElement(g,'Vector2',name='CanvasSize')
    ET.SubElement(canvas,'X').text = str(height * p['size'][0] / p['size'][1])
    ET.SubElement(canvas,'Y').text = str(height)
    prop(g,'bool','AlwaysOnTop','false');prop(g,'float','LightInfluence',0);prop(g,'float','MaxDistance',600)
    lab,l=item(gui,'TextLabel','Text');prop(l,'string','Text',p['text']);prop(l,'float','BackgroundTransparency',1)
    size=ET.SubElement(l,'UDim2',name='Size')
    for tag,n in [('XS',1),('XO',0),('YS',1),('YO',0)]:ET.SubElement(size,tag).text=str(n)
    prop(l,'bool','TextScaled','true');prop(l,'token','Font',12) # Enum.Font.SciFi
    col=ET.SubElement(l,'Color3',name='TextColor3')
    for k,v in zip('RGB',p['textColor']):ET.SubElement(col,k).text=str(v/255)

def export():
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityPrismHotel')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-05','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':850}))
    mats={'Metal':1088,'Concrete':816,'Glass':1568,'Neon':288,'SmoothPlastic':272}
    for p in parts:
        e,pr=item(model,'Part',p['name'])
        prop(pr,'bool','Anchored','true');prop(pr,'bool','CanCollide',str(p['solid']).lower());prop(pr,'bool','CanQuery',str(p['solid']).lower());prop(pr,'bool','CanTouch','false')
        prop(pr,'float','Transparency',p['alpha']);prop(pr,'token','Material',mats[p['material']]);prop(pr,'token','TopSurface',0);prop(pr,'token','BottomSurface',0)
        r,g,b=p['color'];prop(pr,'Color3uint8','Color3uint8',(255<<24)|(r<<16)|(g<<8)|b)
        mat=p['matrix'];size=p['size']
        if p['shape']=='CylinderY':
            # Roblox cylinder longitudinal axis is X: rotate local cylinder to scene Y.
            mat=[mat[1],-mat[0],mat[2],mat[4],-mat[3],mat[5],mat[7],-mat[6],mat[8]];size=[size[1],size[0],size[2]]
            prop(pr,'token','shape',2)
        else:prop(pr,'token','shape',1)
        vec(pr,'size',size);cf(pr,'CFrame',p['pos'],mat)
        if 'text' in p:add_sign(e,p)
    runtime=(OUT/'MegaCityBuildingRuntime.lua').read_text()
    e,p=item(model,'Script','PrismRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/05-prism-hotel.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityPrismHotelSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityPrismHotelGeometry.lua').write_text('-- Generated from tools/build_prism_hotel.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/prism-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
