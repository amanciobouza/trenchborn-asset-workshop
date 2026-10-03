"""Deterministic Roblox Parts-only MC-19 model and matching Rojo module/export.
Run from repository root: python tools/build_financial_spire.py
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

# MC-19 staggered glass volumes and an off-centre vertical service blade.
part('Foundation',(160,4,142),(0,2,0),'concrete','Concrete')
part('Podium',(150,8,130),(0,8,0),'edge');snow('PodiumSnow',150,130,0,12.3,0)
def glass_volume(name,cx,cz,w,d,bottom,top):
    part(name+'Floor',(w,3,d),(cx,bottom+1.5,cz),'edge')
    for x in [cx-w/2+2,cx+w/2-2]:
        for z in [cz-d/2+2,cz+d/2-2]:
            part(name+'Corner',(4,top-bottom,4),(x,(top+bottom)/2,z),'metal')
    y=bottom+3;row=0
    while y<top-3:
        h=min(13,top-3-y)
        part(name+'Slab',(w-4,1,d-4),(cx,y,cz),'edge')
        for front in [-1,1]:
            z=cz+front*d/2
            part(name+'Glass',(w-8,h-.5,.6),(cx,y+h/2,z),'glass','Glass',alpha=.35)
            part(name+'Transom',(w-4,1,1),(cx,y,z+front*.65),'edge')
            for j in range(1,4):
                part(name+'Mullion',(1,h,1),(cx-w/2+j*w/4,y+h/2,z+front*.65),'edge')
            if row%4==1:trim(name+'WarmStrip',(max(2,w-14),.8,1),(cx,y+h-2,z-front*3),'warm')
        for side in [-1,1]:
            x=cx+side*w/2
            part(name+'SideGlass',(.6,h-.5,d-8),(x,y+h/2,cz),'glass','Glass',alpha=.35)
            part(name+'SideTransom',(1,1,d-4),(x+side*.65,y,cz),'edge')
            for j in range(1,4):
                part(name+'SideMullion',(1,h,1),(x+side*.65,y+h/2,cz-d/2+j*d/4),'edge')
            if row%4==1:trim(name+'SideWarm',(1,.8,max(2,d-14)),(x-side*3,y+h-2,cz),'warm')
        row+=1;y+=13
    part(name+'Roof',(w+2,3,d+2),(cx,top-1.5,cz),'edge')
    snow(name+'Snow',w+2,d+2,cx,top+.3,cz)
# Glazed low lobby with two stepped side wings.
glass_volume('Lobby',0,0,132,104,12,61)
# Volumes narrow and retreat as the tower rises.
for args in [('Lower',-8,0,90,82,61,177),('Middle',-4,4,74,70,177,279),('Upper',1,8,57,57,279,351),('Peak',16,15,26,35,351,388)]:
    glass_volume(*args)
# Ticker bands project ahead of glazing, wrapping all four sides.
for cx,cz,w,d,y,texts in [(-8,0,90,82,76,['^ 320.7   v 311.2   ^ 228.9','^ 104.2   ^ 87.5']),(-8,0,90,82,174,['^ 207.1   v 198.6   ^ 215.4','v 98.6   ^ 215.4']),(-4,4,74,70,276,['^ 172.6   v 98.4   ^ 124.3','^ 124.3   ^ 83.7'])]:
    for face in [-1,1]:
        z=cz+face*(d/2+1.7)
        sign('MarketTicker',texts[0],(w+3,7,1),(cx,y,z),'cyan',(0,180 if face==1 else 0,0))
        for dy in [-4.3,4.3]:trim('TickerEdge',(w+4,.7,1),(cx,y+dy,z),'cyan')
    for side in [-1,1]:
        x=cx+side*(w/2+1.7)
        sign('SideTicker',texts[1],(d,7,1),(x,y,cz),'cyan',(0,-90*side,0))
        for dy in [-4.3,4.3]:trim('TickerSideEdge',(1,.7,d+3),(x,y+dy,cz),'cyan')
# Tall asymmetric blade behind/right of the stepped glass; no opaque backing in office volumes.
part('ServiceBlade',(16,337,34),(47,229.5,23),'metal')
part('BladeFace',(12,337,6),(47,229.5,3),'metal')
part('BladeFront',(5,346,5),(39,234,-1),'edge')
part('BladeOuter',(5,346,5),(55,234,-1),'edge')
trim('BladeCyan',(1,333,1),(38,231,-4),'cyan')
beam('BladeCrown',(39,407,23),(55,392,23),7,'edge')
beam('BladeCrownSnow',(39,411,23),(55,396,23),1.2,'snow')
# Shorter rear service fin with louvres.
part('RearSpine',(18,294,20),(24,208,47),'metal')
for y in [99,151,203,255,307,337]:
    part('RearVent',(12,23,1),(24,y,57.8),'dark')
    for j in range(6):part('VentSlat',(11,1,1),(24,y-9+j*3.5,58.6),'edge')
snow('RearSpineSnow',18,20,24,355.3,47)
# Narrow accent tower visible along the right of the main blade.
glass_volume('SideShaft',61,27,12,29,61,220)
# Emblem and tower number on the outward face, clear of facade trim.
for x,h in [(43,19),(47,26),(51,19)]:trim('MagentaMark',(2,h,1),(x,359,-1),'pink')
sign('TowerNumber','19',(12,9,1),(47,332,-1),'snow')
pipe('MainAntenna',(41,405,23),(41,439,23),.8)
p=pipe('AntennaTip',(41,439,23),(41,451,23),.55);p['material']='Neon';p['color']=list(PALETTE['cyan']);p['solid']=False
pipe('AuxAntenna',(51,396,25),(51,421,25),.4)
vent(-24,64,26,12)
# Warm lobby, large framed name plate and central number below it.
for x in [-57,-43,43,57]:
    part('LobbyPier',(5,49,8),(x,36.5,-52),'edge')
    trim('LobbyVerticalLight',(1,40,1),(x,35,-57),'warm')
part('EntryHeader',(87,13,9),(0,60,-57),'edge');snow('EntryHeaderSnow',87,9,0,66.8,-57)
sign('SpireName','FINANCIAL SPIRE',(80,10,1),(0,60,-62.5),'snow')
part('NumberShield',(22,12,8),(0,48,-57),'edge')
sign('EntryNumber','19',(17,9,1),(0,48,-62),'snow')
for side in [-1,1]:beam('PortalShoulder',(side*11,43,-59),(side*19,53.5,-59),3,'edge')
for x in [-29,29]:part('DoorFrame',(3,39,5),(x,31.5,-55),'metal')
for x in [-21,-7,7,21]:
    trim('LobbyCeilingLamp',(7,.6,12),(x,54,-36),'warm')
for i in range(6):part('EntranceStep',(64,2,3),(0,11-i*2,-66-i*3),'concrete','Concrete')
for side in [-1,1]:
    for z in [-54,0,48]:
        part('SnowPlanter',(14,7,14),(side*69,15.5,z),'concrete','Concrete')
        snow('PlanterSnow',14,14,side*69,19.3,z)
        trim('PlanterLamp',(3,2,1),(side*69,15,z-7.7),'warm')
# Rear service door sits fully outside the lobby glazing.
part('RearPortal',(31,29,8),(24,26.5,57),'edge')
part('RearDoor',(22,23,1),(24,25,61.8),'dark')
for y in range(16,36,3):part('DoorSlat',(20,.7,1),(24,y,62.5),'metal')
trim('RearDoorLight',(18,1,1),(24,39,62),'warm')
snow('RearPortalSnow',31,8,24,41.3,57)

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

spec=dict(SchemaVersion=1,AssetId='MC-19',AssetName='Financial Spire',AssetClass='Building',City='MegaCity',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityFinancialSpire')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-19','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
    e,p=item(model,'Script','FinancialRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/19-financial-spire.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityFinancialSpireSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityFinancialSpireGeometry.lua').write_text('-- Generated from tools/build_financial_spire.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/financial-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
