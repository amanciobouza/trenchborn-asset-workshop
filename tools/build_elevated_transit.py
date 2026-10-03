"""Deterministic Roblox Parts-only MC-03 model and matching Rojo module/export.
Run from repository root: python tools/build_elevated_transit.py
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

# MC-03: railway along X; front glazing toward -Z. No external road or viaduct.
# Three pairs of splayed piers carry the elevated station.
for x in [-84,0,84]:
    for z in [-18,18]:
        part('PierFoot',(23,4,18),(x,2,z),'concrete','Concrete')
        beam('SplayedPier',(x-4,4,z),(x+4,38,z),11,'concrete')
        part('PierCapital',(32,6,18),(x+4,38,z),'edge')
        trim('SupportLamp',(7,1,1),(x+4,34,z+(-6 if z<0 else 6)),'warm')
        snow('FootSnow',23,3,x,4.3,z-6)
part('StationDeck',(232,5,64),(0,43,0),'concrete','Concrete')
for z in [-30,30]:
    part('DeckFascia',(234,5,3),(0,44,z),'edge')
    trim('PlatformCyan',(232,.8,.7),(0,47,z+(-1.9 if z<0 else 1.9)))
    pipe('UnderDeckMain',(-112,37,z),(112,37,z),1.5)
    for x in [-100,-70,-30,30,70,100]:
        pipe('ServiceRiser',(x,37,z),(x,42,z),1.2)
        part('PipeBracket',(2,6,5),(x,38,z),'edge')
# Track trench with two platforms: the rail ends stop at the station boundary.
for z in [-20,20]:
    part('PlatformFloor',(228,2,20),(0,46.5,z),'edge')
    trim('BoardingLine',(226,.16,.7),(0,47.6,z+ (9 if z<0 else -9)),'cyan')
part('TrackBed',(232,1,18),(0,46,0),'dark')
for z in [-5,5]:part('Rail',(232,1,1),(0,47,z),'edge')
for x in range(-110,111,10):part('Sleeper',(2,.5,15),(x,46.6,0),'metal')
# Repeating glazed bays; both sides are hollow with no opaque filler block.
for x in range(-108,109,12):
    for z in [-29.5,29.5]:
        part('StationWindow',(10.8,18,.6),(x,57,z),'glass','Glass',alpha=.45)
        part('WindowMullion',(.8,19,1.2),(x-5.7,57,z),'edge')
        trim('WindowWarm',(8,.5,.8),(x,65,z+(.8 if z<0 else -.8)),'warm')
for z in [-29.5,29.5]:
    part('WindowSill',(231,1,2),(0,47.8,z),'edge')
    part('WindowHeader',(231,2,2),(0,67,z),'edge')
# Large external ribs and corner chamfers.
for x in [-115,-38,38,115]:
    for z in [-31,31]:
        part('StructuralRib',(3,24,3),(x,56,z),'metal')
        beam('RoofShoulder',(x,67,z),(x,75,z*.55),3,'edge')
        beam('DeckKnee',(x,40,z),(x,34,z*.6),3,'edge')
# Three pitched sections with raised clerestories give the stepped silhouette.
for x in [-77,0,77]:
    for z,angle in [(-16,-12),(16,12)]:
        part('RoofBlade',(76,3,33),(x,72,z),'metal',rotation=(angle,0,0))
        # Offset snow along the local roof normal, avoiding coplanar faces.
        dy=1.8*math.cos(math.radians(angle));dz=1.8*math.sin(math.radians(angle))
        snow('RoofSnow',76,33,x,72+dy,z+dz,(angle,0,0))
    part('ClerestoryBase',(49,2,13),(x,77,0),'edge')
    for z in [-6,6]:
        part('ClerestoryGlass',(46,5,.6),(x,80,z),'glass','Glass',alpha=.4)
        trim('ClerestoryWarm',(43,.5,.6),(x,78,z),'warm')
        for dx in [-22,0,22]:part('ClerestoryFrame',(.8,6,1),(x+dx,80,z),'edge')
    for sx in [x-24,x+24]:part('ClerestoryEnd',(2,6,12),(sx,80,0),'metal')
    part('ClerestoryCap',(52,2,16),(x,84,0),'edge')
    snow('ClerestorySnow',52,16,x,85.3,0)
    # Mount the complete vent assembly flush on the rear roof plane.
    first = len(parts)
    vent(0,0,0,11)
    angle = math.radians(12)
    for v in parts[first:]:
        vx,vy,vz = v['pos']
        # Turn louvres outward (+Z), then align with the pitched roof.
        ly,lz = vy + 4.5, -vz + 4
        v['pos'] = [x-vx, 72+ly*math.cos(angle)-lz*math.sin(angle),
                    16+ly*math.sin(angle)+lz*math.cos(angle)]
        v['rotation'] = [12,180,0]
# Open rail mouths at both ends. Headers sit above train clearance.
for x in [-116,116]:
    for z in [-20,20]:part('EndPanel',(2,19,16),(x,57,z),'glass','Glass',alpha=.45)
    part('RailPortalHeader',(3,8,58),(x,68,0),'metal')
    sign('StationNumber','03',(17,9,.7),(x,68,0),'cyan',(0,90 if x<0 else -90,0))
# Visible benches, ticket machines and overhead lighting, clear of tracks.
for x in [-88,-48,0,48,88]:
    for z in [-22,22]:
        part('BenchSeat',(14,1.2,4),(x,50,z),'edge')
        part('BenchBack',(14,4,1),(x,52,z+(-2 if z<0 else 2)),'metal')
        for dx in [-5,5]:part('BenchLeg',(1,2,2),(x+dx,48.5,z),'edge')
        trim('CeilingStrip',(17,.6,2),(x,66,z),'warm')
for x in [-94,86]:
    part('TicketMachine',(4,8,3),(x,51.5,-25),'metal')
    trim('TicketScreen',(3,3,.3),(x,53,-26.7),'cyan')
sign('DepartureBoard','DEPARTURES\n01  ARCTIC LOOP   2 MIN\n02  CENTRAL      5 MIN\n03  HARBOR       8 MIN',(51,16,1),(68,57,-31.5),'warm')
sign('RearStationName','ELEVATED TRANSIT',(88,8,1),(0,57,31.5),'cyan',(0,180,0))
# Hollow glazed lift/access tower at the east end. Lift is static architectural dressing.
part('TowerFoundation',(35,4,51),(133,2,1),'concrete','Concrete')
for x in [118,148]:
    for z in [-22,24]:part('TowerColumn',(4,89,4),(x,48.5,z),'metal')
for y in [6,25,45.5,68,91]:
    part('TowerFloor',(32,2,48),(133,y,1),'edge')
# West platform door remains open at platform height, other faces glazed.
for y in [15.5,35.5,57,79.5]:
    for z in [-22,24]:
        part('TowerGlass',(25,17,.6),(133,y,z),'glass','Glass',alpha=.45)
        part('TowerMullion',(1,18,1),(133,y,z),'edge')
    part('TowerEastGlass',(.6,17,40),(148,y,1),'glass','Glass',alpha=.45)
    if y!=57:part('TowerWestGlass',(.6,17,40),(118,y,1),'glass','Glass',alpha=.45)
for y in [23,43,66,89]:trim('TowerWarm',(22,.6,1),(133,y,-20),'warm')
# Inboard rails and empty lift cabin at ground level, not a solid room block.
for z in [-12,14]:part('LiftGuide',(1,82,1),(143,48,z),'edge')
part('LiftCabinFloor',(18,1,22),(134,8,1),'edge')
part('LiftCabinRoof',(18,1,22),(134,20,1),'edge')
part('TowerRoof',(39,3,55),(133,94,1),'metal')
snow('TowerRoofSnow',39,55,133,95.8,1)
part('SignPylon',(12,67,3),(146,55,-25),'metal')
sign('TransitVertical','T\nR\nA\nN\nS\nI\nT',(10,63,1),(146,55,-27),'pink')
for x in [140,152]:trim('SignBorder',(.6,64,.6),(x,55,-27.7),'pink')
for x,h in [(125,13),(141,9)]:
    part('Antenna',(.6,h,.6),(x,96+h/2,7),'edge')
    trim('Beacon',(1.2,1.2,1.2),(x,96+h,7),'pink')
# Exterior stair ascends westward into a platform-height entrance terrace.
# Consistent 1.2-stud risers, no floating stair treads.
part('StairFoot',(18,2,21),(181,1,-43),'concrete','Concrete')
for i in range(38):
    y=2.1+i*1.2;x=179-i*2
    part('StairTread',(2,1.2,17),(x,y,-43),'concrete','Concrete')
    trim('StairEdge',(.18,.1,15),(x+.8,y+.65,-43),'warm')
for z in [-52,-34]:
    beam('StairStringer',(180,1.2,z),(104,46.8,z),2.5,'edge')
    beam('StairHandrail',(180,5.7,z),(104,51.3,z),.7,'edge')
    for i in range(0,38,5):
        x=179-i*2;y=2.1+i*1.2
        part('RailPost',(.7,4,.7),(x,y+2,z),'edge')
part('EntryTerrace',(28,2,33),(108,46.5,-37),'edge')
# Side opening in existing front glazing at the entrance terrace.
parts[:]=[p for p in parts if not (p['name'] in ['StationWindow','WindowMullion'] and p['pos'][0]>=96 and p['pos'][2]<0)]
for x in [95,121]:
    part('EntryPost',(2,18,2),(x,56,-51),'edge')
part('EntryCanopy',(30,2,35),(108,66,-38),'metal')
snow('EntryCanopySnow',30,35,108,67.3,-38)
sign('EntranceName','TRANSIT 03',(27,6,1),(108,62,-56),'cyan')
# Two attached utility cabinets beneath access tower, no city furniture.
for x in [126,140]:
    part('ServiceCabinet',(9,10,9),(x,9,18),'edge')
    for y in [7,9,11]:part('CabinetLouvre',(7,.5,.6),(x,y,12.9),'dark',solid=False)

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

spec=dict(SchemaVersion=1,AssetId='MC-03',AssetName='Elevated Transit Station',AssetClass='Building',City='MegaCity',
    EnergyType='Electric',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
    PerformanceBudget=dict(MaxVisibleParts=750,MaxGameplayHitboxes=1,PermanentLights=0,PermanentParticleEmitters=0,PerPartScripts=0))
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityElevatedTransitStation')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-03','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':750}))
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
    e,p=item(model,'Script','TransitRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/03-elevated-transit-station.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityElevatedTransitSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityElevatedTransitGeometry.lua').write_text('-- Generated from tools/build_elevated_transit.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/transit-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
