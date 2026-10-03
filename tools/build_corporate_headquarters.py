"""Deterministic Roblox Parts-only MC-18 model and matching Rojo module/export.
Run from repository root: python tools/build_corporate_headquarters.py
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

# MC-18: broad twin office wings with a deep central V recess.
part('Foundation',(232,4,166),(0,2,0),'concrete','Concrete')
part('Podium',(218,10,146),(0,9,3),'metal')
snow('PodiumSnow',218,146,0,14.3,3)
# Terraces step down toward the entrance; walls meet without coplanar skins.
for side in [-1,1]:
    for k in range(3):
        x=side*(91-k*22);h=24+k*14
        part('TerraceBlock',(22,h,125-k*12),(x,14+h/2,5+k*6),'concrete','Concrete')
        snow('TerraceSnow',22,125-k*12,x,14+h+.3,5+k*6)
        for z in [-43,0,43]:
            part('TerraceRib',(3,h,4),(x,14+h/2,z),'edge')
        trim('TerraceUplight',(3,1,2),(x,15,-59+k*12),'warm')
# Two hollow office wings. Glass planes bound real rooms, with floors behind them.
for side in [-1,1]:
    cx=side*59
    part('WingPlinth',(70,51,104),(cx,39.5,5),'metal')
    for dx in [-28,-14,0,14,28]:
        part('PlinthPilaster',(5,51,4),(cx+dx,39.5,-49),'concrete','Concrete')
        trim('PlinthUplight',(2,1,1),(cx+dx,15,-52),'warm')
    part('WingFloor',(70,4,104),(cx,67,5),'edge')
    for x in [cx-34,cx+34]:
        for z in [-47,57]:part('CornerPier',(6,226,6),(x,180,z),'metal')
    for y in range(76,280,14):
        part('OfficeFloor',(64,1.5,98),(cx,y,5),'edge')
        for z in [-48,58]:
            part('BlueWindow',(62,12,.6),(cx,y+7,z),'glass','Glass',alpha=.35)
            part('FloorSpandrel',(64,1.6,1),(cx,y,z+(-.8 if z<0 else .8)),'metal')
            for dx in [-23,-8,8,23]:
                part('GlassMullion',(1,12,1),(cx+dx,y+7,z+(-.8 if z<0 else .8)),'edge')
            if int((y-76)/14)%3==0:
                trim('OfficeLight',(53,.8,.8),(cx,y+9,z+(3 if z<0 else -3)),'warm')
        for x in [cx-35,cx+35]:
            part('SideWindow',(.6,12,96),(x,y+7,5),'glass','Glass',alpha=.35)
            part('SideSpandrel',(1,1.6,98),(x+(-.8 if x<cx else .8),y,5),'metal')
            for z in [-32,-8,16,40]:part('SideMullion',(1,12,1),(x+(-.8 if x<cx else .8),y+7,z),'edge')
    # Crown slopes upward toward the outside, above the occupied floors.
    beam('CrownFront',(side*24,295,-48),(side*96,310,-48),9,'edge')
    beam('CrownSnow',(side*24,300,-48),(side*96,315,-48),1.4,'snow')
    part('WingRoof',(70,4,104),(cx,295,5),'metal');snow('RoofSnow',70,104,cx,297.3,5)
    part('OuterCrown',(6,17,104),(side*94,304,5),'edge');snow('CrownSideSnow',6,104,side*94,312.8,5)
    trim('CyanOuterLine',(1.2,217,1),(side*94,182,-51),'cyan')
    vent(cx,300,19,18)
# Rear service spine links the wings, leaving the front recess 24 studs deep.
part('ServiceCore',(44,229,68),(0,182.5,22),'metal')
part('CoreCrown',(44,12,68),(0,303,22),'edge');snow('CoreSnow',44,68,0,309.3,22)
for y in [99,153,207,261]:
    part('RearVentRecess',(26,31,1),(0,y,56.8),'dark')
    for j in range(8):part('RearLouvre',(24,1.4,1),(0,y-12+j*3.5,57.6),'edge')
# Recess glazing and central vertical windows below the emblem.
for y in range(78,177,14):
    part('AtriumWindow',(41,12,.6),(0,y+6,-13),'glass','Glass',alpha=.35)
    part('AtriumFloor',(41,1.5,24),(0,y,-1),'edge')
    trim('AtriumWarmLight',(31,.8,1),(0,y+8,-10),'warm')
    for x in [-14,0,14]:part('AtriumMullion',(1,12,1),(x,y+6,-14),'edge')
part('EmblemBacking',(43,102,2),(0,234,-14),'dark')
# The heavy V projects forward of the recessed emblem, with cyan outer edges.
for side in [-1,1]:
    beam('VArmour',(side*8,174,-43),(side*28,296,-43),9,'edge')
    beam('VLight',(side*12,178,-48),(side*32,296,-48),1.2,'cyan');parts[-1]['material']='Neon';parts[-1]['solid']=False
    beam('EmblemUpper',(side*17,272,-17),(0,247,-17),3.5,'pink');parts[-1]['material']='Neon';parts[-1]['solid']=False
    beam('EmblemLower',(side*14,253,-17),(0,225,-17),3.5,'pink');parts[-1]['material']='Neon';parts[-1]['solid']=False
trim('EmblemStem',(3,33,2),(0,222,-17),'pink')
# Monumental open portal and transparent two-storey lobby.
part('LobbyFloor',(84,3,48),(0,15.5,-42),'edge')
part('LobbyBack',(84,47,3),(0,40,-19),'metal')
for x in [-40,40]:part('LobbySide',(4,47,46),(x,40,-43),'edge')
part('LobbyGlass',(76,44,.6),(0,39,-66),'glass','Glass',alpha=.35)
for x in [-30,-15,0,15,30]:part('LobbyMullion',(1.3,44,1),(x,39,-66.9),'edge')
for y in [30,47]:part('LobbyTransom',(77,1.3,1),(0,y,-66.9),'edge')
for x in [-28,-14,0,14,28]:trim('LobbyCeilingLight',(6,.6,16),(x,61,-42),'warm')
for side in [-1,1]:
    part('PortalPier',(10,57,14),(side*44,42.5,-68),'metal')
    trim('PortalLight',(1,42,1),(side*38,37,-76),'warm')
part('PortalHeader',(98,14,14),(0,70,-68),'edge')
snow('HeaderSnow',98,14,0,77.3,-68)
sign('HeadquartersName','CORPORATE HQ',(88,10,1),(0,70,-76),'snow')
part('EntranceCanopy',(74,3,18),(0,56,-77),'edge');snow('CanopySnow',74,18,0,57.8,-77)
for x in [-27,-9,9,27]:trim('CanopyDownlight',(4,.5,5),(x,54.2,-79),'warm')
sign('HeadquartersNumber','18',(12,7,1),(0,61,-76),'snow')
for i in range(7):
    part('EntryStep',(68,2,3),(0,13-i*2,-77-i*3),'concrete','Concrete')
for side in [-1,1]:
    for k in range(3):
        x=side*(45+k*19);z=-85+k*8
        part('Planter',(17,8,15),(x,18,z),'edge');snow('PlanterSnow',17,15,x,22.3,z)
        trim('StepLamp',(3,2,1),(x,17,z-8),'warm')
# Rear loading/service entrance and roof aerials.
part('RearPortal',(52,40,10),(0,34,73),'edge')
part('ServiceDoor',(35,27,1),(0,29,78.8),'dark')
for y in range(18,43,4):part('DoorSlat',(33,.8,.6),(0,y,79.5),'metal')
trim('RearDoorLamp',(26,1,1),(0,45,79),'warm')
snow('RearPortalSnow',52,10,0,54.3,73)
sign('RearNumber','18',(12,10,1),(0,61,59),'snow',(0,180,0))
for x in [-16,16]:
    part('RoofTower',(9,16,12),(x,317,29),'edge');snow('TowerSnow',9,12,x,325.3,29)
    pipe('Aerial',(x,325,29),(x,337,29),.45)

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

spec=dict(SchemaVersion=1,AssetId='MC-18',AssetName='Corporate Headquarters',AssetClass='Building',City='MegaCity',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityCorporateHeadquarters')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-18','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
    e,p=item(model,'Script','HeadquartersRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/18-corporate-headquarters.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityCorporateHeadquartersSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityCorporateHeadquartersGeometry.lua').write_text('-- Generated from tools/build_corporate_headquarters.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/headquarters-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
