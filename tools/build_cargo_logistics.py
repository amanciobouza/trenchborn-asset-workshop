"""Deterministic Roblox Parts-only MC-02 model and matching Rojo module/export.
Run from repository root: python tools/build_cargo_logistics.py
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

# MC-02: front loading face -Z. All geometry belongs to one building.
part('Foundation',(244,4,108),(-4,2,0),'concrete','Concrete')
part('HallFloor',(166,2,90),(-14,5,0),'edge')
part('RearWall',(166,48,3),(-14,29,44),'metal')
for x in [-96,68]:part('EndWall',(3,48,90),(x,29,0),'metal')
# Three real openings with recessed cargo interiors.
for i,x in enumerate([-64,-12,40],1):
    y=57-(i-1)*3
    part('BayRoof',(53,3,96),(x,y,0),'edge')
    snow('BayRoofSnow',53,96,x,y+1.8,0)
    part('BayHeader',(50,15,5),(x,46,-44),'metal')
    part('InnerBayCeiling',(44,2,72),(x,38,3),'dark')
    sign('BayNumber',f'{i:02}',(9,10,.6),(x-16,48,-47),'cyan')
    sign('CargoStatus',f'{i:02}  '+['CARGO READY  >>>','LOADING  >>>','DISPATCH  >>>'][i-1],(32,5,.6),(x+5,43,-47),'warm')
    for side in [-1,1]:
        sx=x+side*22
        part('DoorJamb',(3,29,5),(sx,20,-45),'edge')
        beam('DoorChamfer',(sx,34,-45),(sx-side*5,39,-45),3)
        trim('DoorWarmGuide',(.6,25,.8),(sx-side*2,19,-48),'warm')
        for j in range(5):
            part('HazardStripe',(2,.7,.6),(sx,8+j*2,-48),'warm',rotation=(0,0,side*35),solid=False)
    part('DoorLintel',(34,3,5),(x,39,-45),'edge')
    trim('DoorCeilingLamp',(30,.6,1),(x,36,-42),'warm')
    for z in [-24,0,25]:
        trim('InteriorCeilingLamp',(25,.5,2),(x,36,z),'warm')
        for side in [-1,1]:
            cx=x+side*14
            part('CargoCrate',(10,10,16),(cx,11,z),'edge')
            for k in [-3,0,3]:part('CrateRib',(.5,9,16.4),(cx+k,11,z),'metal',solid=False)
            trim('CrateID',(4,1,.5),(cx,13,z-8.4),'warm')
    for sx in [x-17,x+17]:trim('LoadingLane',(.5,.15,26),(sx,6.1,-30),'warm')
    vent(x-8,y+5,5,18)
    vent(x+13,y+5,22,12)
    for z in [-30,33]:pipe('RoofDuct',(x-20,y+3,z),(x+20,y+3,z),1.5)
# Heavy slanted front buttresses framing the bays.
for x in [-91,-38,14,67]:
    part('FrontPier',(5,43,7),(x,28,-45),'edge')
    beam('LowerButtress',(x,6,-54),(x,22,-45),6)
    beam('UpperButtress',(x,43,-46),(x,55,-36),5)
    trim('PierRouting',(.8,27,.7),(x,29,-49),'cyan')
    part('PierFoot',(9,5,13),(x,6.5,-49),'concrete','Concrete')
    trim('FootLamp',(3,1,.7),(x,8,-56),'warm')
# Service wing and tall vertical brand panel.
part('ServiceWing',(24,40,86),(-111,24,0),'metal')
part('ServiceBase',(26,12,89),(-111,10,0),'concrete','Concrete')
part('ServiceRoof',(29,3,94),(-111,45,0),'edge')
snow('ServiceSnow',29,94,-111,46.8,0)
sign('LogisticsPylon','L\nO\nG\nI\nS\nT\nI\nC\nS',(9,48,2),(-112,33,-47),'pink')
for x in [-118,-106]:trim('SignBorder',(.6,49,.7),(x,33,-48),'pink')
# Rear/side armor panels, utility blocks, access door.
for x in range(-86,65,15):
    part('RearArmor',(12,29,2),(x,32,46),'edge')
    part('RearConcrete',(14,12,3),(x,11,47),'concrete','Concrete')
    trim('RearLight',(4,1,.7),(x,17,48.7),'warm')
for z in range(-30,40,14):
    part('SideArmor',(2,29,11),(70,32,z),'edge')
    trim('SideRouting',(.7,9,.7),(71.5,26,z),'cyan')
part('RearServiceDoor',(12,12,1),(-64,11,49),'dark')
sign('RearBrand','TRN\nLOGISTICS',(24,17,.6),(-110,29,45),'cyan',(0,180,0))
# Elevated control room, overhanging windows on all four sides.
part('ControlTower',(27,24,26),(29,65,24),'metal')
for x in [14,44]:part('TowerRib',(3,25,28),(x,65,24),'edge')
part('ControlDeck',(48,3,36),(29,78,24),'edge')
# Hollow cabin: no opaque solid behind the glazing.
for z in [8.5,39.5]:
    part('ControlSill',(48,1,1),(29,80,z),'edge')
    part('ControlHeader',(48,1,1),(29,90,z),'edge')
for x in [7.5,50.5]:
    part('SideSill',(1,1,30),(x,80,24),'edge')
    part('SideHeader',(1,1,30),(x,90,24),'edge')
for x in [19,39]:
    part('ControlConsole',(9,2,5),(x,80.5,16),'edge')
    trim('ConsoleScreen',(7,.2,3),(x,81.6,16),'cyan')
for z in [8.5,39.5]:
    for x in [10,18,26,34,42,50]:
        part('ControlWindow',(7,9,.6),(x,85,z),'glass','Glass',alpha=.45)
        trim('ControlWarm',(6,.6,.7),(x,81,z),'warm')
        part('WindowMullion',(.7,11,1),(x-4,85,z),'edge')
for x in [7.5,50.5]:
    part('SideControlGlass',(.6,9,28),(x,85,24),'glass','Glass',alpha=.45)
    for z in [13,24,35]:part('SideMullion',(1,11,.7),(x,85,z),'edge')
part('ControlRoof',(50,3,38),(29,92,24),'metal')
snow('ControlSnow',50,38,29,93.8,24)
sign('TowerBrand','TRN\nLOGISTICS',(19,12,.6),(29,67,10.5),'cyan')
for x,h in [(15,12),(38,17),(46,10)]:
    part('Antenna',(.7,h,.7),(x,94+h/2,24),'edge')
    trim('Beacon',(1.2,1.2,1.2),(x,94+h,24),'pink')
vent(23,98,26,12)
# Side loading platform and attached gantry crane, no external quay.
part('SideLoadingDeck',(46,5,98),(94,4.5,0),'concrete','Concrete')
for z in [-39,38]:
    for x in [77,112]:
        part('CraneFoot',(9,5,11),(x,9,z),'edge')
        part('CraneColumn',(5,48,6),(x,35,z),'metal')
        trim('CraneWarning',(1,9,.7),(x,20,z-3.5),'warm')
        beam('CraneKnee',(x,45,z),(x+(8 if x==77 else -8),58,z),3)
    part('CraneCrossbeam',(45,7,8),(94.5,61,z),'edge')
    trim('GantryRouting',(34,.7,.7),(94.5,61,z-4.4),'cyan')
    snow('GantrySnow',45,8,94.5,64.8,z)
    for x in [77,112]:trim('CraneBeacon',(1.5,1.5,1.5),(x,66,z),'pink')
for x in [78,111]:part('CraneLongRail',(4,4,84),(x,61,0),'edge')
part('MovingGantry',(40,5,7),(94.5,59,0),'metal')
part('Trolley',(12,5,12),(94.5,55,0),'edge')
for x in [90,99]:pipe('HoistCable',(x,54,0),(x,36,0),.25)
part('ContainerSpreader',(22,3,10),(94.5,35,0),'warm')
for x in [85,104]:part('SpreaderJaw',(2,5,8),(x,32,0),'edge') # inset faces avoid z-fighting at the joint
for z in [-27,27]:
    part('SideContainer',(26,12,16),(94,13,z),'metal')
    for x in range(83,107,4):part('ContainerRib',(.6,11,16.4),(x,13,z),'edge',solid=False)
    snow('ContainerSnow',26,16,94,19.3,z)
# Roof utility routes with vertical downpipes.
for x in [-80,58]:
    pipe('RoofMain',(x,59,-25),(x,59,37),2)
    pipe('Downpipe',(x,59,37),(x,7,37),2)

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

spec=dict(SchemaVersion=1,AssetId='MC-02',AssetName='Cargo Logistics Hub',AssetClass='Building',City='MegaCity',
    EnergyType='Electric',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
    PerformanceBudget=dict(MaxVisibleParts=650,MaxGameplayHitboxes=1,PermanentLights=0,PermanentParticleEmitters=0,PerPartScripts=0))
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
    gui,g=item(parent,'SurfaceGui','Sign');prop(g,'token','Face',5);prop(g,'float','PixelsPerStud',30);prop(g,'token','SizingMode',1)
    prop(g,'bool','AlwaysOnTop','false');prop(g,'float','LightInfluence',0);prop(g,'float','MaxDistance',600)
    lab,l=item(gui,'TextLabel','Text');prop(l,'string','Text',p['text']);prop(l,'float','BackgroundTransparency',1)
    size=ET.SubElement(l,'UDim2',name='Size')
    for tag,n in [('XS',1),('XO',0),('YS',1),('YO',0)]:ET.SubElement(size,tag).text=str(n)
    prop(l,'bool','TextScaled','true');prop(l,'token','Font',4)
    col=ET.SubElement(l,'Color3',name='TextColor3')
    for k,v in zip('RGB',p['textColor']):ET.SubElement(col,k).text=str(v/255)

def export():
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityCargoLogisticsHub')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-02','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':650}))
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
    e,p=item(model,'Script','CargoRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/02-cargo-logistics-hub.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityCargoLogisticsSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityCargoLogisticsGeometry.lua').write_text('-- Generated from tools/build_cargo_logistics.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/cargo-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
