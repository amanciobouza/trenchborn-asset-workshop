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

# MC-15: compact armoured server block with deep cooling fins.
PALETTE['violet']=(51,44,69)
part('Foundation',(240,4,168),(0,2,6),'concrete','Concrete')
part('Plinth',(226,15,147),(0,11.5,4),'concrete','Concrete')
part('BuildingFloor',(218,4,130),(0,21,0),'edge')
# Service volume is hollow; front slots expose individual server banks.
part('RearWall',(210,87,4),(0,66.5,63),'metal')
for x in [-107,107]:part('SideWall',(4,87,126),(x,66.5,-2),'violet')
part('Roof',(224,4,138),(0,112,0),'edge')
snow('RoofSnow',224,138,0,114.3,0)
for x in [-113,113]:
    for z in [-51,-25,1,27,53]:part('SidePlinthArmour',(4,18,23),(x,12,z),'edge',rotation=(0,0,-18 if x<0 else 18))
for x in [-96,-70,-44,44,70,96]:part('FrontPlinthArmour',(23,18,4),(x,12,-72),'edge',rotation=(18,0,0))
for x in [-96,-70,-44,-18,8,34,60,86]:part('RearPlinthArmour',(23,18,4),(x,12,80),'edge',rotation=(-18,0,0))
# Two recessed radiator faces with broad proud fins.
for cx in [-55,55]:
    part('RadiatorBacking',(73,80,4),(cx,68,-64),'dark')
    for dx in range(-32,33,4):
        part('CoolingFin',(2,77,9),(cx+dx,68,-69),'edge')
        snow('FinSnow',2,9,cx+dx,106.8,-69)
    part('RadiatorSill',(77,4,12),(cx,27,-69),'metal')
    snow('SillSnow',77,12,cx,29.3,-69)
    trim('RadiatorLamp',(65,1,1),(cx,25,-75.6),'cyan')
# Armoured front columns, clear of narrow server windows.
for cx in [-103,-15,15,103]:
    part('FrontPier',(9,88,12),(cx,68,-66),'concrete','Concrete')
    snow('PierSnow',9,12,cx,112.3,-66)
    trim('PierMarker',(1.2,3,1),(cx,28,-72.7),'warm')
for cx,w in [(0,18),(-94,5),(94,5)]:
    bottom=46 if cx==0 else 33
    height=59 if cx==0 else 65
    y=bottom+height/2
    part('SlotBack',(w,height,1),(cx,y,-58),'dark')
    for yy in range(bottom+3,int(bottom+height)-2,5):
        part('ServerTray',(w-1,3,3),(cx,yy,-61),'edge')
        trim('ServerStatus',(w-2,.65,.4),(cx,yy,-62.8),'cyan')
        trim('ServerLED',(.5,.5,.4),(cx+w/2-1,yy+1,-62.8),'warm')
    part('SlotGlass',(w,height,.5),(cx,y,-64),'glass','Glass',alpha=.55)
    part('SlotHeader',(w+1,5,5),(cx,bottom+height+2.5,-63),'metal')
# Entrance canopy and sealed double doors.
part('EntryFrame',(29,27,12),(0,34.5,-67),'edge')
part('DoorRecess',(22,23,1),(0,33,-73.6),'dark')
for x in [-5.4,5.4]:
    part('DoorLeaf',(10.3,21,1),(x,33,-74.4),'metal')
    part('DoorInset',(7,15,.6),(x,34,-75.2),'edge')
    trim('DoorHandle',(.5,4,.6),(x*.25,32,-75.8),'warm')
part('Canopy',(36,4,18),(0,49,-70),'edge');snow('CanopySnow',36,18,0,51.3,-70)
trim('EntryLamp',(19,1,1),(0,46.3,-77),'warm')
for i in range(10):part('EntryStep',(31,2,2),(0,20-i*2,-75-i*2),'concrete','Concrete')
# Side armour rows, readable large side signage outside all framing.
for side in [-1,1]:
    x=side*110
    for z in [-46,-9,28]:
        for y in [46,88]:part('SideArmour',(3,37,33),(x,y,z),'violet')
        trim('SideDataLine',(1,1.1,24),(x+side*2,35,z),'cyan')
    for z in [-64,10,63]:
        part('SideSpine',(6,88,5),(x,68,z),'edge')
        for y in [27,107]:trim('SideBeacon',(1.2,2,2),(x+side*3.6,y,z),'warm')
    sign('DataTitle','DATA\nCENTER',(30,19,1),(side*115,94,-44),'pink',(0,-90*side,0))
    sign('DataNumber','15',(24,29,1),(side*115,66,-44),'snow',(0,-90*side,0))
sign('FrontNumber','15',(14,12,1),(0,106,-68),'snow')
# Three roof cooling boxes with successively higher plinths, never floating.
for index,cx in enumerate([-73,0,73]):
    step=index*7
    if step:part('RoofVentPedestal',(66,step,86),(cx,114+step/2,8),'metal')
    part('RoofCoolingBox',(66,19,86),(cx,123.5+step,8),'edge')
    for z in [-35.6,51.6]:
        part('RoofVentRecess',(58,14,1),(cx,123.5+step,z),'dark')
        for dy in [-5,-2,1,4]:part('RoofLouvre',(57,1,1.3),(cx,123.5+step+dy,z+(-.9 if z<0 else .9)),'metal')
    snow('RoofUnitSnow',66,86,cx,133.3+step,8)
    for dx in [-30,30]:trim('RoofBeacon',(1.4,2,1.4),(cx+dx,134.5+step,-33),'warm')
# Three rear modules, each with two large native-Part fan grilles.
for cx in [-73,0,73]:
    part('RearCoolingUnit',(54,82,15),(cx,66,73),'edge')
    part('RearFanPanel',(46,74,1),(cx,66,81),'dark')
    snow('CoolingUnitSnow',54,15,cx,107.3,73)
    for cy in [47,85]:
        # Cylinder axis faces rear; rim and hub in front of recessed blades.
        pipe('FanDisc',(cx,cy,82),(cx,cy,83),16);parts[-1]['color']=list(PALETTE['dark'])
        for j in range(24):
            a=2*math.pi*j/24;b=2*math.pi*(j+1)/24
            beam('FanRim',(cx+16*math.cos(a),cy+16*math.sin(a),84),(cx+16*math.cos(b),cy+16*math.sin(b),84),1.3,'edge')
        for j in range(8):
            a=2*math.pi*j/8
            beam('FanBlade',(cx+4*math.cos(a),cy+4*math.sin(a),83.6),(cx+14*math.cos(a+.25),cy+14*math.sin(a+.25),83.6),2.5,'metal')
        for j in range(12):
            a=2*math.pi*j/12
            beam('FanGuard',(cx+3*math.cos(a),cy+3*math.sin(a),85),(cx+15*math.cos(a),cy+15*math.sin(a),85),.45,'edge')
        pipe('FanHub',(cx,cy,83),(cx,cy,86),3.2)
    trim('RearUnitStatus',(12,1,1),(cx,28,81.7),'cyan')
# Paired return pipes in the gaps between rear cooling modules.
for cx in [-36.5,36.5]:
    for dx in [-4,4]:
        x=cx+dx
        points=[(x,53,65),(x,53,82),(x,47,91),(x,19,91)]
        for a,b in zip(points,points[1:]):pipe('CoolantPipe',a,b,3)
        pipe('PipeCollar',(x,28,91),(x,31,91),3.5)
for x in [-112,-55,55,112]:
    part('Bollard',(3,6,3),(x,7,-80),'edge')
    trim('BollardLamp',(3.2,2,3.2),(x,10,-80),'warm')

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

spec=dict(SchemaVersion=1,AssetId='MC-15',AssetName='Data Center',AssetClass='Building',City='MegaCity',
    EnergyType='Electric',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityDataCenter')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-15','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
    e,p=item(model,'Script','DataRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/15-data-center.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityDataCenterSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityDataCenterGeometry.lua').write_text('-- Generated from tools/build_data_center.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/data-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
