"""Deterministic Roblox Parts-only MC-13 model and matching Rojo module/export.
Run from repository root: python tools/build_grid_substation.py
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

# MC-14: radial containment shell, segmented dome and two laboratory wings.
PALETTE['radiation']=(123,255,47)
part('Foundation',(274,5,198),(0,2.5,6),'concrete','Concrete')
part('Plinth',(266,8,190),(0,9,6),'edge')
snow('GroundSnow',266,190,0,13.3,6)
pipe('ContainmentBase',(0,13,14),(0,39,14),73)
# Tangential panels form a tapered containment wall with open green viewing slots.
for i in range(16):
    a=2*math.pi*i/16;rot=(0,-math.degrees(a),0)
    x,z=65*math.sin(a),65*math.cos(a)+14
    part('ContainmentPanel',(20,71,7),(x,73,z),'concrete','Concrete',rotation=(12, -math.degrees(a),0))
    # Narrow luminous slots between the broad armour panels, backed by reactor tubes.
    aa=a+math.pi/16;xx,zz=64*math.sin(aa),64*math.cos(aa)+14
    part('WindowRecess',(4.7,52,3),(xx,75,zz),'dark',rotation=(12,-math.degrees(aa),0))
    part('GreenViewingSlot',(3.1,46,1),(xx+2*math.sin(aa),75,zz+2*math.cos(aa)),'radiation','Neon',rotation=(12,-math.degrees(aa),0),solid=False)
    beam('ArmourRib',(73*math.sin(a),36,73*math.cos(a)+14),(58*math.sin(a),110,58*math.cos(a)+14),3,'edge')
    trim('ContainmentBeacon',(2,3,2),(58*math.sin(a),112,58*math.cos(a)+14),'warm')
# Dome is built from concentric tapered bands; no opaque cylinder behind viewing slots.
for band,(r0,y0,r1,y1) in enumerate([(59,108,54,119),(54,119,42,131),(42,131,24,140),(24,140,3,144)]):
    for i in range(24):
        a=2*math.pi*(i+.5)/24;rad=(r0+r1)/2
        slope=math.degrees(math.atan2(r0-r1,y1-y0))
        length=math.hypot(r0-r1,y1-y0)
        part('DomeSegment',(2*rad*math.tan(math.pi/24)+.3,length+1,3),(rad*math.sin(a),(y0+y1)/2,14+rad*math.cos(a)),'metal',rotation=(slope,-math.degrees(a),0))
        if i%3!=0:
            part('DomeSnow',(2*rad*math.tan(math.pi/24)-1,length*.72,.5),((rad+1.8)*math.sin(a),(y0+y1)/2+1,14+(rad+1.8)*math.cos(a)),'snow','SmoothPlastic',rotation=(slope,-math.degrees(a),0),solid=False)
pipe('DomeCap',(0,142,14),(0,146,14),8)
# Lab wings: real hollow observation floors and two-sided glass.
for side in [-1,1]:
    cx=side*98
    for y in [16,39,63]:
        part('LabFloor',(63,4,115),(cx,y,0),'edge')
    part('LabRearWall',(63,47,3),(cx,39,56),'metal')
    for z in [-57,20,55]:
        for x in [cx-30,cx+30]:part('LabColumn',(4,47,4),(x,39,z),'concrete','Concrete')
    for y in [27.5,51]:
        part('FrontGlass',(56,18,.7),(cx,y,-57),'glass','Glass',alpha=.4)
        part('SideGlass',(.7,18,107),(cx+side*31,y,-1),'glass','Glass',alpha=.4)
        for dx in [-20,-10,0,10,20]:part('WindowMullion',(1,19,1),(cx+dx,y,-57.6),'edge')
        for z in [-43,-23,-3,17,37]:
            part('SideMullion',(1,19,1),(cx+side*31.6,y,z),'edge')
            part('LabConsole',(11,4,7),(cx+side*20,y-6,z),'edge')
            trim('ConsoleScreen',(7,2,.4),(cx+side*20,y-2,z-3.8),'cyan')
        trim('WindowLight',(52,.7,1),(cx,y+8,-58),'cyan')
    part('LabRoof',(69,4,121),(cx,66,0),'edge');snow('LabRoofSnow',69,121,cx,68.3,0)
    for z in [-32,24]:vent(cx,71.5,z,19)
    for z in [-47,45]:
        beam('WingButtress',(cx-side*29,15,z),(cx-side*19,66,z),8,'edge')
    pipe('Antenna',(cx,69,45),(cx,91,45),.6)
    trim('AntennaTip',(1.4,2,1.4),(cx,92,45),'warm')
# Broad armoured entrance with fitted SciFi typography.
part('EntranceBlock',(111,40,28),(0,33,-66),'concrete','Concrete')
part('DoorRecess',(53,29,2),(0,29,-81),'dark')
for x in [-13,13]:
    part('BlastDoor',(25,27,2),(x,29,-82.5),'edge')
    for y in [22,34]:part('DoorPanel',(21,9,1),(x,y,-84),'metal')
for x in [-30,30]:
    beam('EntryArmour',(x*1.18,14,-83),(x,49,-83),6,'edge')
    trim('DoorLamp',(2,7,1),(x,32,-86),'warm')
sign('FacilityName','NUCLEAR RESEARCH',(74,8,1),(0,48,-88),'snow')
sign('FacilityNumber','14',(16,21,1),(44,31,-81),'snow')
sign('ReactorNumber','14',(17,19,1),(0,77,-58),'snow')
# Radiation trefoil, made from native Parts on its own front plaque.
part('WarningPlaque',(19,18,1),(0,98,-59),'dark')
pipe('SymbolHub',(0,98,-60),(0,98,-60.6),1.7);parts[-1]['color']=list(PALETTE['radiation'])
for angle in [90,210,330]:
    for j in range(5):
        a=math.radians(angle-24+j*12)
        p=beam('RadiationLobe',(4*math.cos(a),98+4*math.sin(a),-60.5),(7*math.cos(a),98+7*math.sin(a),-60.5),1.8,'radiation');p['material']='Neon';p['solid']=False
for i in range(6):part('EntryStep',(66,2,3),(0,12-i*2,-83-i*3),'concrete','Concrete')
# Rear coolant feeds connect containment to broad exchanger housings.
for x in [-23,23]:
    points=[(x,79,73),(x,79,82),(x,72,92),(x,38,92)]
    for a,b in zip(points,points[1:]):pipe('CoolantMain',a,b,6)
    pipe('CoolantGreenBand',(x,60,92),(x,64,92),6.4);parts[-1]['color']=list(PALETTE['radiation']);parts[-1]['material']='Neon'
    part('HeatExchanger',(34,31,24),(x,29,89),'metal')
    for dx in [-12,-8,-4,0,4,8,12]:part('ExchangerFin',(1.5,25,2),(x+dx,29,102),'edge')
    snow('ExchangerSnow',34,24,x,44.8,89)
for x in [-72,72]:
    part('RearServiceCabinet',(29,39,17),(x,32,82),'edge')
    for y in range(19,48,3):part('RearLouvre',(22,1,1),(x,y,91),'dark')
    snow('CabinetSnow',29,17,x,51.8,82)
for side in [-1,1]:
    for z in [-71,-36,0,36,74]:
        part('PerimeterArmour',(5,12,28),(side*134,17,z),'concrete','Concrete')
        trim('PerimeterLamp',(2,2,2),(side*134,24,z),'warm')

def matrix(p):
    if p['name'] in ['ContainmentPanel','WindowRecess','GreenViewingSlot','DomeSegment','DomeSnow']:
        tilt=math.radians(p['rotation'][0]);a=math.radians(-p['rotation'][1])
        sa,ca,st,ct=math.sin(a),math.cos(a),math.sin(tilt),math.cos(tilt)
        return [ca,-sa*st,sa*ct,0,ct,st,-sa,-ca*st,ca*ct]
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

spec=dict(SchemaVersion=1,AssetId='MC-14',AssetName='Nuclear Research Facility',AssetClass='Building',City='MegaCity',
    EnergyType='Radiation',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
    PerformanceBudget=dict(MaxVisibleParts=1400,MaxGameplayHitboxes=1,PermanentLights=0,PermanentParticleEmitters=0,PerPartScripts=0))
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityNuclearResearchFacility')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-14','EnergyType':'Radiation','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
        if 'lightningSegment' in p:prop(pr,'BinaryString','AttributesSerialize',attrs({'LightningSegment':p['lightningSegment']}))
    runtime=(OUT/'MegaCityBuildingRuntime.lua').read_text()
    e,p=item(model,'Script','NuclearRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/14-nuclear-research-facility.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityNuclearResearchFacilitySpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityNuclearResearchFacilityGeometry.lua').write_text('-- Generated from tools/build_nuclear_research.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/nuclear-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
