"""Deterministic Roblox Parts-only MC-10 model and matching Rojo module/export.
Run from repository root: python tools/build_utility_block.py
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

# MC-10: integrated workshop, twin fan bank and insulated thermal stores.
PALETTE['insulation']=(103,117,131)
part('Foundation',(190,4,130),(0,2,0),'concrete','Concrete')
# Hollow workshop shell with butt-jointed walls: no coplanar overlapping corners.
# Two open bays face negative Z.
part('WorkshopFloor',(116,2,107),(-25,5,-2.5),'edge')
part('WorkshopRear',(116,56,4),(-25,34,53),'metal')
for x in [-85,35]:part('WorkshopSide',(4,56,105),(x,34,-1.5),'concrete','Concrete')
for x in [-85,-45,-5,35]:
    part('FrontPier',(6,63,9),(x,36,-52),'edge')
    beam('Buttress',(x,6,-65),(x,65,-51),5,'concrete')
    part('PierFoot',(11,9,17),(x,8.5,-59),'concrete','Concrete')
    snow('PierSnow',11,17,x,13.3,-59)
# Bay headers, roller shutters raised at the lintel, furnished workshop interiors.
for x,label in [(-65,'01'),(-25,'02')]:
    sign('BayNumber',label,(29,7,1),(x,37,-57),'snow')
    part('BayHeader',(34,10,7),(x,36,-52),'metal')
    for y in [29,30.5,32]:part('ShutterSlat',(32,1,2),(x,y,-52),'edge')
    trim('BayLight',(27,1,1),(x,27,-49),'warm')
    for dx in [-17,17]:
        part('BayJamb',(2,25,3),(x+dx,18,-53),'metal')
        for y in range(9,28,5):part('SafetyStripe',(2.2,2.5,.5),(x+dx,y,-54.8),'warm',rotation=(0,0,-25),solid=False)
    for dx in [-12,12]:
        part('Bollard',(2,9,2),(x+dx,8.5,-62),'warm')
        part('BollardBand',(2.1,2,2.1),(x+dx,10,-62),'dark')
    part('WorkBench',(27,2,8),(x,12,-12),'edge')
    for dx in [-10,10]:part('BenchLeg',(2,6,6),(x+dx,8,-12),'metal')
    part('ToolBoard',(27,13,2),(x,21,-7),'dark')
    for dx in range(-10,11,5):part('Tool',(1,6,1),(x+dx,21,-8.8),'edge')
    for dx in [-9,4]:
        part('WorkshopCrate',(8,7,8),(x+dx,8.5,10),'edge')
        trim('CrateIndicator',(4,.6,.5),(x+dx,10,5.7),'warm')
    for z in [12,32]:trim('WorkshopCeiling',(26,.6,1),(x,29,z),'warm')
# Service entrance occupies third front bay.
part('EntryWall',(32,34,3),(15,22,-51),'metal')
part('ServiceDoor',(15,24,1),(15,18,-53),'edge')
part('DoorInset',(10,15,.5),(15,20,-53.8),'dark')
trim('DoorLamp',(11,1.5,1),(15,31,-55),'warm')
sign('UtilityName','UTILITY 10',(31,7,1),(15,39,-58.8),'snow')
for i in range(4):part('EntryStep',(20,1,3),(15,4.5-i,-57-i*3),'concrete','Concrete')
# Upper control room glazing has real empty volume behind it.
part('ControlFloor',(116,2,102),(-25,42,0),'edge')
for x in range(-75,30,15):
    part('ControlWindow',(13.5,14,.6),(x,51,-51.5),'glass','Glass',alpha=.45)
    part('ControlMullion',(1,16,1),(x-7,51,-52),'edge')
    trim('ControlWarm',(11,.6,.6),(x,57,-50),'warm')
    part('Console',(9,4,5),(x,45,-42),'metal')
    trim('ConsoleScreen',(6,2,.5),(x,48,-44.8),'cyan')
part('WindowSill',(122,3,9.6),(-25,42,-53),'edge')
snow('SillSnow',122,3,-25,43.8,-57)
part('MainRoof',(131,4,118),(-25,64,0),'edge')
snow('MainRoofSnow',131,118,-25,66.3,0)
for x in [-65,-20,20]:trim('FacadeCyan',(17,.8,.8),(x,61,-59.5),'cyan')
# Elevated twin fan bank: circular rims made from polygonal native Parts.
part('FanHousing',(109,45,28),(-25,89,-5),'metal')
part('FanFace',(102,39,1),(-25,89,-19.8),'dark')
part('FanRoof',(113,3,32),(-25,113,-5),'edge')
snow('FanRoofSnow',113,32,-25,114.8,-5)
for x in [-49,-1]:
    for i in range(40):
        a=2*math.pi*i/40;b=2*math.pi*(i+1)/40
        for rad,z,w,col in [(18,-21,1.5,'edge'),(17,-22,.55,'warm')]:
            beam('FanRim',(x+rad*math.cos(a),89+rad*math.sin(a),z),(x+rad*math.cos(b),89+rad*math.sin(b),z),w,col)
    pipe('FanHub',(x,89,-21),(x,89,-25),3.8)
    for i in range(6):
        a=i*60
        # Broad pitched blades contained within the circular frame.
        ar=math.radians(a)
        part('FanBlade',(6,12,1.4),(x-10*math.sin(ar),89+10*math.cos(ar),-21.5),'insulation',rotation=(0,0,a-16))
    for y in [-12,-6,0,6,12]:
        width=2*math.sqrt(18*18-y*y)
        part('FanGuard',(width,.55,.6),(x,89+y,-25.5),'edge',solid=False)
for x in [-76,26]:
    part('FanHeatInset',(4,29,1),(x,89,-20.5),'dark')
    for y in range(77,104,4):trim('FanHeatFin',(3,1.4,.6),(x,y,-21.2),'warm')
# Side service block provides plinth and access for the two thermal tanks.
part('ThermalPlinth',(49,4,107),(62,6,6),'concrete','Concrete')
part('ServiceBlock',(42,39,99),(62,27,6),'metal')
part('ServiceBlockRoof',(48,3,105),(62,48,6),'edge')
snow('ServiceRoofSnow',48,105,62,49.8,6)
sign('ServiceLabel','SERVICE',(24,6,1),(61,32,-44.2),'pink')
part('ServicePanel',(22,19,2),(62,19,-44),'edge')
for x in [56,66]:
    part('PanelInset',(7,10,.5),(x,20,-45.3),'dark')
    trim('PanelIndicator',(4,.8,.6),(x,23,-45.7),'cyan')
# Insulated cylindrical stores, each integrated with ring walkway and mains.
for z in [-15,32]:
    pipe('ThermalTank',(65,50,z),(65,101,z),18)
    parts[-1]['color']=list(PALETTE['insulation'])
    for y in [52,67,84,100]:pipe('TankBand',(65,y-1,z),(65,y+1,z),18.6)
    pipe('TankCap',(65,101,z),(65,104,z),19)
    pipe('TankSnow',(65,104,z),(65,104.6,z),18.7)
    parts[-1]['color']=list(PALETTE['snow']);parts[-1]['material']='SmoothPlastic'
    # Front-facing thermal status bars, with no overlapping coplanar surfaces.
    part('TankGauge',(5,25,1),(65,86,z-18.5),'dark')
    for y in range(76,98,3):trim('TankGaugeBar',(3.5,1.4,.7),(65,y,z-19.3),'warm')
    for x in [47,83]:
        part('TankFoot',(4,7,9),(x,51,z),'edge')
    part('TankWalkway',(13,2,40),(87,65,z),'edge')
    for zz in [z-19,z,z+19]:part('WalkwayPost',(1,7,1),(92,69.5,zz),'warm')
    part('WalkwayRail',(1,1,40),(92,73,z),'warm')
    for zz in [z-19,z+19]:part('EndRail',(12,1,1),(87,73,zz),'warm')
    for zz in [z-14,z+14]:beam('WalkwayBrace',(83,54,zz),(92,64,zz),1.5)
# Large insulated supply line with segmented, continuous rounded elbows.
def curved_pipe(name,points,r):
    for a,b in zip(points,points[1:]):pipe(name,a,b,r)
def arc(cx,cy,z,r,a0,a1):
    return [(cx+r*math.cos(math.radians(a)),cy+r*math.sin(math.radians(a)),z) for a in [a0+(a1-a0)*i/8 for i in range(9)]]
route=[(29,96,-36),(39,96,-36)]+arc(39,86,-36,10,90,0)[1:]+[(49,77,-36)]+arc(59,77,-36,10,180,270)[1:]+[(69,67,-36)]+arc(69,57,-36,10,90,0)[1:]+[(79,10,-36)]
curved_pipe('InsulatedMain',route,5)
for y in [18,36,52]:
    pipe('MainCoupling',(79,y-1.3,-36),(79,y+1.3,-36),5.6)
    parts[-1]['color']=list(PALETTE['warm'])
    beam('MainSupport',(79,y,-30),(79,y,-36),2)
# Rear manifold and tank connections.
for z in [-15,32]:pipe('TankFeed',(47,74,z),(30,74,z),3)
pipe('RearManifold',(-68,29,60),(67,29,60),4)
for x in [-68,-20,28,67]:
    pipe('ManifoldDrop',(x,10,60),(x,29,60),3)
    part('PipeBracket',(9,3,9),(x,27,56),'edge')
for x in [-60,-10]:
    part('RearDoor',(18,27,1),(x,19,55.5),'edge')
    sign('RearWarning','THERMAL',(25,5,1),(x,39,56),'warm',(0,180,0))
# Orange heat exchanger banks on the right exterior, framed and supported.
for z in [-29,4,38]:
    part('HeatExchanger',(9,30,24),(89,21,z),'dark')
    for zz in [z-12,z+12]:part('ExchangerFrame',(12,32.5,2),(89,20.75,zz),'edge')
    for y in range(8,35,3):trim('ThermalFin',(.8,1,20),(94, y,z),'warm')
    part('ExchangerTop',(12,2,26),(89,38,z),'edge')
    snow('ExchangerSnow',12,26,89,39.3,z)
    for zz in [z-8,z+8]:part('ExchangerFoot',(10,3,3),(89,5.5,zz),'edge')
# Roof plant firmly seated, vents and stacks behind fan housing.
for x in [-66,-30,8]:vent(x,69,36,15)
for x in [-70,13]:
    part('ExhaustStack',(8,21,8),(x,76.5,46),'metal')
    part('StackCap',(11,2,11),(x,88,46),'edge')
    snow('StackSnow',11,11,x,89.3,46)
    for y in [79,82,85]:part('StackLouvre',(7,1,.6),(x,y,41.6),'dark')
# Ladder on outer rear wall.
for x in [75,82]:part('LadderRail',(1,57,1),(x,33,60),'warm')
for y in range(6,62,4):part('LadderRung',(6,.8,.8),(78.5,y,60),'edge')

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

spec=dict(SchemaVersion=1,AssetId='MC-10',AssetName='Utility Block',AssetClass='Building',City='MegaCity',
    EnergyType='Thermal',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityUtilityBlock')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-10','EnergyType':'Thermal','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
    e,p=item(model,'Script','UtilityRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/10-utility-block.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityUtilityBlockSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityUtilityBlockGeometry.lua').write_text('-- Generated from tools/build_utility_block.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/utility-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
