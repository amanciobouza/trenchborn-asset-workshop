"""Deterministic Roblox Parts-only MC-07 model and matching Rojo module/export.
Run from repository root: python tools/build_waterfront_market.py
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

# MC-07: low waterfront food hall. Front -Z, promenade excluded.
part('Foundation',(236,4,132),(0,2,0),'concrete','Concrete')
part('HallFloor',(225,2,120),(0,5,0),'edge')
part('RearWall',(225,36,3),(0,24,55),'metal')
for x in [-111,111]:part('EndWall',(3,36,105),(x,24,4),'metal')
part('HallRoof',(230,3,99),(0,43,8),'edge')
snow('HallRoofSnow',230,99,0,44.8,8)
# Raised central roof lantern: genuinely glazed, not an opaque solid.
part('LanternFloor',(173,2,39),(0,44,13),'edge')
for z in [-6,32]:
    for x in range(-78,79,13):
        part('LanternGlass',(11.8,8,.6),(x,49,z),'glass','Glass',alpha=.45)
        part('LanternMullion',(.8,10,1),(x-6.4,49,z),'edge')
        trim('LanternWarm',(10,.5,.7),(x,46,z+(.7 if z<0 else -.7)),'warm')
for x in [-86,86]:part('LanternEnd',(2,10,39),(x,49,13),'metal')
part('LanternRoof',(178,3,45),(0,55,13),'metal')
snow('LanternSnow',178,45,0,56.8,13)
# Front shops are open service bays with small window panels at the sides.
shops=[(-94,'NOODLES','pink'),(-66,'BAO','warm'),(-38,'FISH','cyan'),(38,'RAMEN','pink'),(66,'TEA','warm'),(94,'TECH','cyan')]
for i,(x,label,col) in enumerate(shops):
    roofy=27+[0,3,1,2,0,2][i]
    part('ShopFloor',(27,2,38),(x,6,-43),'edge')
    for sx in [x-13,x+13]:part('ShopPost',(1.5,roofy-7,3),(sx,(roofy+7)/2,-59),'edge')
    # Counter opening remains clear; furnishings visible through it.
    part('ServiceCounter',(21,4,6),(x,9,-55),'edge')
    part('CounterTop',(23,1,7),(x,11.5,-55),'metal')
    trim('CounterGlow',(20,.6,.6),(x,10,-59),'warm')
    part('ShopShelf',(23,1,5),(x,17,-36),'edge')
    for dx in [-7,0,7]:
        part('DisplayTray',(5,.5,4),(x+dx,12.25,-55),'dark')
        part('Goods',(3,1.5,2),(x+dx,13.2,-55),col,solid=False)
        part('ShelfGoods',(3,4,3),(x+dx,19.5,-36),'warm' if label!='TECH' else 'cyan',solid=False)
    for sx in [x-10,x+10]:
        part('ShopSidelight',(3,11,.6),(sx,18,-59),'glass','Glass',alpha=.4)
    part('ShopCanopy',(28,2,26),(x,roofy,-51),'edge')
    snow('ShopCanopySnow',28,26,x,roofy+1.3,-51)
    trim('CanopyCyan',(26,.7,.7),(x,roofy,-64.5),'cyan')
    sign('ShopName',label,(24,6,.8),(x,roofy-5,-60.7),col)
    # Sloped fabric-like awning projects above the service counter.
    part('Awning',(23,1,9),(x,roofy-9,-63),'metal',rotation=(-10,0,0))
    for dx in [-8,-4,0,4,8]:
        part('AwningStripe',(.9,.12,8.5),(x+dx,roofy-8.42,-63),col,'SmoothPlastic',rotation=(-10,0,0),solid=False)
    for dx in [-8,8]:trim('HangingLamp',(1.5,2,1.5),(x+dx,roofy-11,-59),'warm')
# Clear, tall central entry surrounded by two large magenta sign pylons.
for x in [-21,21]:
    part('EntrancePier',(6,36,9),(x,22,-49),'metal')
    part('PylonBoot',(9,7,12),(x,7.5,-50),'concrete','Concrete')
    sign('EntryPylon','F\nO\nO\nD' if x<0 else 'M\nA\nR\nK\nE\nT',(5,26,1),(x,25,-54),'pink')
part('EntryLintel',(50,10,10),(0,40,-49),'edge')
part('EntryRoof',(54,3,19),(0,47,-48),'metal')
snow('EntrySnow',54,19,0,48.8,-48)
sign('MarketName','MARKET HALL',(47,8,1),(0,40,-54.7),'warm')
trim('EntranceWarm',(35,.8,2),(0,34,-48),'warm')
for i in range(5):part('EntryStep',(34,1,2),(0,5-i,-59-i*2),'concrete','Concrete')
# Hall interior: stalls run along the sides, central route stays open.
for x in [-66,-34,34,66]:
    for z in [-10,22]:
        part('MarketTable',(20,1.5,10),(x,10,z),'edge')
        for dx in [-7,7]:part('TableLeg',(1.5,4,6),(x+dx,7.5,z),'metal')
        for dx in [-6,0,6]:
            part('MarketCrate',(5,3,7),(x+dx,12.3,z),'metal')
            trim('CrateMarker',(3,.5,.6),(x+dx,13,z-3.9),'warm')
for x in [-88,-44,0,44,88]:
    part('InteriorColumn',(2.5,36,2.5),(x,24,40),'edge')
    for z in [-14,23]:trim('HallCeilingLamp',(18,.6,2),(x,40,z),'warm')
# Low flanking corner kiosks carry lateral signs.
for side in [-1,1]:
    x=side*111
    part('CornerKiosk',(12,22,24),(x,17,-40),'metal')
    sign('SideShop','HOT FOOD' if side<0 else 'FRESH',(20,7,.8),(x+side*6.5,23,-40),'cyan',(0,90 if side<0 else -90,0))
    part('KioskRoof',(17,2,28),(x,29,-40),'edge')
    snow('KioskSnow',17,28,x,30.3,-40)
# Three kitchen exhaust housings seated on raised roof; warm heat louvers.
for x in [-62,0,62]:
    part('ExhaustHousing',(15,12,14),(x,62.5,16),'metal')
    for y in [58,60,62,64,66]:trim('HeatLouvre',(11,.7,.7),(x,y,8.5),'warm')
    part('ExhaustCap',(18,2,17),(x,69.5,16),'edge')
    snow('ExhaustSnow',18,17,x,70.8,16)
    # Outlet slot remains visibly open below cap.
    part('ExhaustOutlet',(12,1,11),(x,68.2,16),'dark')
    pipe('KitchenDuct',(x,57,27),(x,57,42),1.6)
    pipe('DuctDrop',(x,57,42),(x,46,42),1.6)
    pipe('ServiceDuct',(x,46,42),(x,46,53),1.6)
for x in [-96,96]:vent(x,47.5,30,13)
# Rear doors, refrigeration units and insulated service pipes.
for x in [-85,-42,42,85]:
    part('ServiceDoor',(17,21,1),(x,16,57),'edge')
    for y in range(8,25,4):part('DoorSlat',(15,.6,.7),(x,y,57.8),'dark',solid=False)
    trim('RearDoorLamp',(10,.8,.7),(x,28,57.9),'warm')
    part('RefrigerationUnit',(12,10,9),(x,9,64),'edge')
    for dx in [-3,3]:
        part('CoolerFan',(4,4,.8),(x+dx,10,69),'dark')
        for dy in [-1,1]:part('FanSlat',(3,.4,1),(x+dx,10+dy,69.5),'metal',solid=False)
    snow('CoolerSnow',12,9,x,14.3,64)
for x in [-104,104]:
    pipe('RearHeatingPipe',(x,39,54),(x,7,54),1.5)
    trim('HeatIndicator',(.8,6,.7),(x,16,56),'warm')
sign('RearName','WATERFRONT MARKET',(60,8,1),(0,27,57.5),'warm',(0,180,0))

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

spec=dict(SchemaVersion=1,AssetId='MC-07',AssetName='Waterfront Market Hall',AssetClass='Building',City='MegaCity',
    EnergyType='Thermal',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityWaterfrontMarketHall')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-07','EnergyType':'Thermal','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':750}))
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
    e,p=item(model,'Script','MarketRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/07-waterfront-market-hall.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityWaterfrontMarketSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityWaterfrontMarketGeometry.lua').write_text('-- Generated from tools/build_waterfront_market.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/market-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
