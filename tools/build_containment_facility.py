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

# MC-17 reinforced glass vessel, four independent structural pylons.
PALETTE['radiation']=(123,255,47)
PALETTE['core']=(214,255,139)
PALETTE['greenGlass']=(56,132,72)
def ring(name,r,y,width,color='edge',z=10):
    for i in range(32):
        a=2*math.pi*i/32;b=2*math.pi*(i+1)/32
        p=beam(name,(r*math.sin(a),y,z+r*math.cos(a)),(r*math.sin(b),y,z+r*math.cos(b)),width,color)
        if color in ['radiation','core']:p['material']='Neon';p['solid']=False
part('Foundation',(264,4,220),(0,2,3),'concrete','Concrete')
part('Deck',(254,6,208),(0,7,3),'edge');snow('DeckSnow',254,208,0,10.3,3)
pipe('VesselPlinth',(0,10,10),(0,38,10),58)
pipe('LowerCollar',(0,38,10),(0,52,10),52)
ring('LowerCollarSnow',52,52.3,1.2,'snow')
ring('BaseEnergyRing',49,53,1.5,'radiation')
# Individual flat panes form a hollow faceted vessel; no solid cylinder masks the core.
for i in range(24):
    a=2*math.pi*(i+.5)/24
    p=part('ContainmentGlass',(2*47*math.tan(math.pi/24)-.25,103,.6),(47*math.sin(a),105.5,10+47*math.cos(a)),'greenGlass','Glass',rotation=(0,math.degrees(a),0),alpha=.67,solid=True)
for y in [54,106,157]:ring('GlassReinforcement',48,y,1.7)
for i in range(8):
    a=2*math.pi*i/8
    x,z=48*math.sin(a),10+48*math.cos(a)
    part('VesselMullion',(2.2,104,2.2),(x,105.5,z),'edge')
    for y in [55,106,157]:part('PaneClamp',(5,4,4),(x,y,z),'metal',rotation=(0,math.degrees(a),0))
pipe('UpperCollar',(0,158,10),(0,177,10),52)
pipe('VesselLid',(0,177,10),(0,184,10),49)
pipe('LidSnow',(0,184,10),(0,184.6,10),48);parts[-1]['color']=list(PALETTE['snow']);parts[-1]['material']='SmoothPlastic'
ring('TopEnergyRing',47,157,1.5,'radiation')
# Bright spine and two twisting energy strands visible from every side.
pipe('EnergySpine',(0,57,10),(0,155,10),4);parts[-1]['color']=list(PALETTE['core']);parts[-1]['material']='Neon';parts[-1]['solid']=False
for strand in range(2):
    for j in range(48):
        points=[]
        for k in [j,j+1]:
            t=k/48;a=t*math.pi*5+strand*math.pi;rad=12+3*math.sin(t*math.pi*4)
            points.append((rad*math.cos(a),57+98*t,10+rad*math.sin(a)))
        p=beam('EnergyHelix',*points,2.4,'radiation');p['material']='Neon';p['solid']=False
for y in [66,98,130,150]:ring('CoreHalo',23,y,.7,'radiation')
# Four pylons lean inward and grip both collars.
for sx in [-1,1]:
    for sz in [-1,1]:
        x,z=sx*62,10+sz*62
        part('PylonFoot',(29,21,29),(x,20.5,z),'concrete','Concrete')
        beam('PylonShaft',(x,27,z),(sx*49,184,10+sz*49),16,'edge')
        beam('PylonArmour',(x+sx*3,33,z+sz*3),(sx*50,175,10+sz*50),11,'concrete')
        beam('PylonGreenInset',(sx*59,81,10+sz*59-9),(sx*54,128,10+sz*54-9),2.5,'radiation');parts[-1]['material']='Neon';parts[-1]['solid']=False
        for y,rp in [(48,60),(168,50)]:
            beam('VesselClamp',(sx*rp,y,10+sz*rp),(sx*34,y,10+sz*34),10,'metal')
        snow('PylonSnow',20,20,sx*49,186,10+sz*49)
        trim('PylonBeacon',(2,3,2),(sx*49,188,10+sz*49),'warm')
# Low front control wings frame a central entry.
for side in [-1,1]:
    cx=side*84
    part('ControlBase',(68,16,60),(cx,18,-63),'metal')
    part('ControlFloor',(70,3,62),(cx,27.5,-63),'edge')
    part('ControlBack',(68,22,3),(cx,40,-34.5),'metal')
    for dx in [-33,33]:part('ControlCorner',(3,22,59),(cx+dx,40,-64.5),'edge')
    part('ControlGlass',(62,19,.6),(cx,40,-93.3),'glass','Glass',alpha=.4)
    for dx in [-30,-15,0,15,30]:part('WindowMullion',(1.2,22,1),(cx+dx,40,-94),'edge')
    for dx in [-23,-8,8,23]:
        part('ControlConsole',(10,4,6),(cx+dx,33,-85),'edge')
        trim('ConsoleScreen',(8,3,.5),(cx+dx,37,-88.5),'cyan')
    part('ControlRoof',(75,3,66),(cx,52.5,-63),'edge');snow('ControlSnow',75,66,cx,54.3,-63)
    vent(cx,57.5,-53,19)
    part('LowerWindow',(25,8,.7),(cx,19,-93.5),'glass','Glass',alpha=.4)
    trim('LowerWindowLight',(22,.7,.8),(cx,22,-94),'cyan')
part('EntranceBlock',(92,36,37),(0,28,-78),'concrete','Concrete')
part('DoorRecess',(43,23,1),(0,22,-97),'dark')
for x in [-10.5,10.5]:
    part('EntryDoor',(20,21,1),(x,22,-98),'edge')
    part('DoorInset',(15,15,.7),(x,23,-98.9),'metal')
for x in [-25,25]:trim('EntryLamp',(1.5,7,1),(x,25,-99),'warm')
sign('ContainmentName','CONTAINMENT',(70,9,1),(-9,40,-98),'snow')
sign('ContainmentNumber','17',(14,11,1),(37,40,-98),'snow')
snow('EntrySnow',92,37,0,46.3,-78)
for i in range(5):part('EntryStep',(55,2,2.6),(0,9-i*2,-98-i*2.6),'concrete','Concrete')
# Rear heat exchangers and double feeds.
for side in [-1,1]:
    cx=side*86
    part('CoolingModule',(42,43,47),(cx,31.5,66),'edge')
    part('RadiatorBack',(34,34,1),(cx,31.5,90),'dark')
    for y in range(17,48,3):part('RadiatorLouvre',(32,1,1),(cx,y,91),'metal')
    snow('CoolingSnow',42,47,cx,53.3,66)
    for dx in [-5,5]:
        x=side*36+dx
        points=[(x,42,48),(x,42,65),(x,32,78),(x,17,83)]
        for a,b in zip(points,points[1:]):pipe('CoolantFeed',a,b,3.7)
        p=pipe('CoolantGreenCollar',(x,24,80.7),(x,27,79.7),4.2);p['color']=list(PALETTE['radiation']);p['material']='Neon'
    part('RearPump',(28,18,23),(side*36,19,82),'metal');snow('PumpSnow',28,23,side*36,28.3,82)
sign('RearNumber','17',(17,16,1),(0,29,69),'snow',(0,180,0))
# Radiation warning plaques at the base of the vessel, front and rear.
for z in [-44,64]:
    part('WarningPlaque',(19,16,1),(0,43,z),'dark')
    face=z+(-1 if z<0 else 1)
    p=pipe('WarningHub',(0,43,face),(0,43,face+(.5 if z>0 else -.5)),1.3);p['color']=list(PALETTE['warm'])
    for angle in [90,210,330]:
        for j in range(5):
            a=math.radians(angle-24+j*12)
            beam('WarningLobe',(3*math.cos(a),43+3*math.sin(a),face),(6*math.cos(a),43+6*math.sin(a),face),1.5,'warm')
for x in [-119,-45,45,119]:
    for z in [-101,98]:
        part('Bollard',(3,5,3),(x,12.5,z),'edge');trim('BollardLamp',(3.2,2,3.2),(x,16,z),'warm')

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

spec=dict(SchemaVersion=1,AssetId='MC-17',AssetName='Containment Facility',AssetClass='Building',City='MegaCity',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityContainmentFacility')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-17','EnergyType':'Radiation','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
    e,p=item(model,'Script','ContainmentRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    motion=(OUT/'MegaCityContainmentMotion.lua').read_text()
    source=p.find("ProtectedString[@name='Source']")
    source.text += '\nlocal function motionModule()\n'+motion+'\nend\nmotionModule().Attach(script.Parent)\n'
    target=ROOT/'packages/mega-city/17-containment-facility.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityContainmentFacilitySpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityContainmentFacilityGeometry.lua').write_text('-- Generated from tools/build_containment_facility.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/containment-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
