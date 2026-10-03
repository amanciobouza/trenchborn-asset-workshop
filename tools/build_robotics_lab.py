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

# MC-16 open assembly hall with integrated static industrial equipment.
PALETTE['industrial']=(181,125,40)
part('Foundation',(276,4,216),(0,2,6),'concrete','Concrete')
part('HallFloor',(180,4,183),(0,6,5),'edge')
# Tall hollow hall; unobstructed front opening width 106 and height 128.
for side in [-1,1]:
    part('HallSideWall',(5,142,181),(side*87.5,79,5),'metal')
    part('FrontShoulder',(31,142,6),(side*71,79,-88),'metal')
    for z in [-79,-26,27,80]:
        beam('OuterButtress',(side*100,7,z),(side*79,151,z),9,'concrete')
        beam('ButtressNeon',(side*99,28,z-5),(side*82,139,z-5),1.7,'cyan');parts[-1]['material']='Neon';parts[-1]['solid']=False
        part('ButtressFoot',(21,19,20),(side*99,13,z),'edge')
    part('CraneRunway',(5,6,168),(side*71,132,4),'industrial')
    for z in [-60,0,60]:
        part('InnerColumn',(5,121,5),(side*79,68.5,z),'edge')
        beam('RoofBrace',(side*78,145,z),(side*49,150,z),4,'edge')
part('RearWall',(170,142,5),(0,79,93),'metal')
part('FrontHeader',(180,17,9),(0,145.5,-88),'edge')
part('Roof',(188,5,194),(0,154.5,5),'edge');snow('HallRoofSnow',188,194,0,157.3,5)
# Open portal with short angled corners and cyan framing.
for side in [-1,1]:
    part('PortalUpright',(7,116,11),(side*55,70,-92),'edge')
    trim('PortalLight',(1.5,113,1),(side*55,70,-98),'cyan')
    beam('PortalCorner',(side*55,128,-92),(side*45,138,-92),7,'edge')
    beam('PortalCornerLight',(side*55,128,-98),(side*45,138,-98),1.5,'cyan');parts[-1]['material']='Neon';parts[-1]['solid']=False
part('PortalLintel',(90,7,11),(0,138,-92),'edge');trim('PortalTopLight',(89,1.5,1),(0,138,-98),'cyan')
sign('LabTitle','GUARDIAN ROBOTICS',(157,10,1),(0,149,-98),'snow')
sign('LabNumber','16',(23,29,1),(72,93,-93),'snow')
sign('LabMark','ROBOTICS',(25,6,1),(72,126,-93),'pink')
# Stylised articulated arm emblem above number.
for a,b in [((65,112,-93),(69,118,-93)),((69,118,-93),(77,114,-93)),((77,114,-93),(79,110,-93))]:beam('ArmEmblem',a,b,1.4,'snow')
# Side control rooms have hollow interiors and clear glazing.
for side in [-1,1]:
    cx=side*116
    for y in [7,22,45,68]:part('ControlFloor',(43,3,66),(cx,y,-52),'edge')
    part('ControlBase',(43,13,66),(cx,14,-52),'metal')
    part('ControlBack',(43,44,3),(cx,45,-20.5),'metal')
    for y in [33.5,56.5]:
        part('ObservationFront',(38,19,.6),(cx,y,-85.3),'glass','Glass',alpha=.42)
        part('ObservationSide',(.6,19,59),(cx+side*21.7,y,-53),'glass','Glass',alpha=.42)
        for dx in [-19,-9,1,11,19]:part('FrontMullion',(1,20,1),(cx+dx,y,-85.5),'edge')
        for z in [-78,-59,-40,-23]:part('SideMullion',(1,20,1),(cx+side*22,y,z),'edge')
        for dx in [-12,0,12]:
            part('ControlDesk',(9,3,5),(cx+dx,y-6,-79),'edge')
            trim('ControlDisplay',(7,3,.4),(cx+dx,y-3,-81.8),'cyan')
    part('ControlRoof',(48,3,71),(cx,70,-52),'edge');snow('ControlSnow',48,71,cx,71.8,-52)
    vent(cx,75,-42,17)
    part('ControlDoor',(12,12,1),(cx,14,-85.8),'dark')
    trim('ControlDoorLamp',(10,.8,1),(cx,21,-86.5),'warm')
# Roof ventilation and rear conduits.
for x in [-48,48]:
    for z in [-37,36]:
        part('RoofCooler',(28,16,31),(x,165,z),'metal')
        for y in [160,163,166,169]:trim('CoolerLouvre',(20,1,1),(x,y,z-16),'cyan')
        snow('CoolerSnow',28,31,x,173.3,z)
for side in [-1,1]:
    for j in range(3):
        x=side*(92+j*7)
        pts=[(side*84,145,67+j*5),(x,134,67+j*5),(x,36,67+j*5),(side*119,28,67+j*5)]
        for a,b in zip(pts,pts[1:]):pipe('ServicePipe',a,b,1.8)
    part('RearServiceUnit',(37,43,35),(side*116,25.5,69),'edge')
    for y in range(9,44,4):trim('RearCoolingSlot',(24,1,1),(side*116,y,87.2),'cyan')
    snow('ServiceSnow',37,35,side*116,47.3,69)
# Closed rear blast gate with visible structural bracing.
part('RearGateFrame',(113,126,5),(0,71,97),'edge')
for side in [-1,1]:
    part('RearGateLeaf',(53,117,2),(side*27,71,100.6),'metal')
    for y in [29,109]:beam('GateBrace',(side*49,y,102.5),(side*5,71,102.5),3,'edge')
sign('RearNumber','16',(26,31,1),(0,77,103),'snow',(0,180,0))
# Overhead bridge crane, hung from the two runways.
for z in [-10,2]:
    part('CraneGirder',(145,5,4),(0,127,z),'industrial')
    for x in range(-66,67,12):beam('CraneTruss',(x,125,z),(x+6,134,z),1.4,'industrial')
    part('CraneUpperBeam',(145,3,3),(0,135,z),'industrial')
part('CraneTrolley',(22,8,23),(-17,125,-4),'edge')
for x in [-23,-11]:pipe('HoistCable',(x,122,-4),(x,95,-4),.3)
part('HoistBlock',(16,6,7),(-17,94,-4),'industrial')
beam('CraneHook',(-17,91,-4),(-17,86,-4),1.4,'edge');beam('CraneHookTip',(-17,86,-4),(-13,88,-4),1.4,'edge')
# Two industrial assembly arms, clearly visible through the open gate.
for side in [-1,1]:
    x=side*38
    part('RobotBase',(22,7,22),(x,11.5,7),'edge')
    pipe('RobotTurntable',(x,15,7),(x,21,7),9)
    pts=[(x,23,7),(side*45,50,7),(side*23,70,7),(side*16,56,7)]
    for idx,(a,b) in enumerate(zip(pts,pts[1:])):
        beam('RobotArm',a,b,7-idx,'industrial')
        pipe('ArmPiston',(a[0],a[1],a[2]-4),(b[0],b[1],b[2]-4),1)
    for a in pts:
        pipe('RobotJoint',(a[0],a[1],2),(a[0],a[1],12),4.8)
        pipe('JointCap',(a[0],a[1],1),(a[0],a[1],2),2.6);parts[-1]['color']=list(PALETTE['industrial'])
    for dx in [-2.5,2.5]:beam('RobotGripper',(side*16+dx,56,7),(side*16+dx,49,7),1.5,'edge')
# Empty maintenance cradle, no Guardian character.
part('MaintenancePlatform',(49,5,34),(0,10.5,48),'edge')
for x in [-20,20]:
    for z in [43,53]:part('CradleUpright',(3,74,3),(x,50,z),'edge')
    for y in range(17,88,10):part('CradleRung',(4,2,12),(x,y,48),'industrial')
    for y in [35,69]:beam('MaintenanceClamp',(x,y,43),(x*.5,y,39),3,'edge')
part('CradleCrossbar',(43,4,10),(0,16,48),'industrial')
# Floor guides, integrated lighting, rear workshop equipment.
for x in [-29,29]:trim('FloorGuide',(1.2,.2,164),(x,8.2,0),'warm')
for z in [-62,25,71]:
    for x in [-48,48]:trim('CeilingLight',(17,1,6),(x,150,z),'warm')
for x in [-64,64]:
    part('ToolCabinet',(16,21,10),(x,18.5,76),'edge')
    for y in [12,17,22]:part('ToolDrawer',(13,3,1),(x,y,70.5),'dark')
for i in range(4):part('FrontStep',(111,2,3),(0,7-i*2,-94-i*3),'concrete','Concrete')

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

spec=dict(SchemaVersion=1,AssetId='MC-16',AssetName='Guardian Robotics Lab',AssetClass='Building',City='MegaCity',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityGuardianRoboticsLab')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-16','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
    e,p=item(model,'Script','RoboticsRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/16-guardian-robotics-lab.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityGuardianRoboticsLabSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityGuardianRoboticsLabGeometry.lua').write_text('-- Generated from tools/build_robotics_lab.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/robotics-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
