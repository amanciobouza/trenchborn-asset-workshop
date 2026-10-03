"""Deterministic Roblox Parts-only MC-21 model and matching Rojo module/export.
Run from repository root: python tools/build_mega_tower.py
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

# MC-21 monumental faceted tower, four tiers and a luminous crown.
part('Foundation',(290,5,250),(0,2.5,0),'concrete','Concrete')
part('Podium',(278,9,236),(0,9.5,0),'edge');snow('PodiumSnow',278,236,0,14.3,0)
def oct_band(name,r,y,h,color='edge'):
    for i in range(8):
        a=i*math.pi/4
        part(name,(2*r*math.tan(math.pi/8),h,5),(r*math.sin(a),y,r*math.cos(a)),color,rotation=(0,math.degrees(a),0))
def oct_snow(name,r,y):oct_band(name,r,y,.6,'snow')
# Low stepped base blocks; entry kept free in the front centre.
for side in [-1,1]:
    for k in range(3):
        cx=side*(114-k*29);top=45+k*25
        part('BaseWing',(29,top-14,180-k*12),(cx,(top+14)/2,4),'metal')
        snow('WingSnow',29,180-k*12,cx,top+.3,4)
        for z in [-54,0,54]:
            part('WingRib',(5,top-14,7),(cx,(top+14)/2,z),'edge')
        for y in range(24,top-5,18):
            trim('BaseWindow',(19,4,1),(cx,y,-87+k*6),'warm')
part('BaseServiceCore',(90,81,100),(0,54.5,20),'metal')
# Four progressively narrower hollow octagonal sections.
for tier,(bottom,top,r) in enumerate([(95,210,68),(210,330,58),(330,442,49),(442,536,41)]):
    oct_band('TierLowerCollar',r+1,bottom+5,10)
    oct_band('TierUpperCollar',r+1,top-5,10)
    oct_snow('CollarSnow',r+1,top+.3)
    # Floors are octagonal fans of native blocks approximated by overlapping internal slabs.
    for y in range(bottom+12,top-10,19):
        part('Floor',(r*1.4,1.5,r*1.4),(0,y,0),'edge')
    for i in range(8):
        a=i*math.pi/4;w=2*r*math.tan(math.pi/8)-4
        for row,y in enumerate(range(bottom+11,top-10,19)):
            h=min(18,top-10-y)
            part('TowerGlass',(w,h,.7),(r*math.sin(a),y+h/2,r*math.cos(a)),'glass','Glass',rotation=(0,math.degrees(a),0),alpha=.32)
            part('Transom',(w,1,1),((r+.8)*math.sin(a),y,(r+.8)*math.cos(a)),'edge',rotation=(0,math.degrees(a),0))
            for offset in [-w/4,w/4]:
                part('PaneMullion',(1,h,1),((r+.8)*math.sin(a)+offset*math.cos(a),y+h/2,(r+.8)*math.cos(a)-offset*math.sin(a)),'edge',rotation=(0,math.degrees(a),0))
            if row%2==0:trim('WarmOffice',(w-5,1,1),((r-2)*math.sin(a),y+h-3,(r-2)*math.cos(a)),'warm',(0,math.degrees(a),0))
        va=a+math.pi/8;rad=r/math.cos(math.pi/8)
        x,z=rad*math.sin(va),rad*math.cos(va)
        part('VerticalArmour',(7,top-bottom,7),(x,(top+bottom)/2,z),'metal',rotation=(0,math.degrees(va),0))
        trim('EnergyChannel',(2,top-bottom-24,1),((rad+4)*math.sin(va),(top+bottom)/2,(rad+4)*math.cos(va)),'cyan',(0,math.degrees(va),0))
        part('CollarClamp',(12,12,12),(x,top-3,z),'edge',rotation=(0,math.degrees(va),0))
        trim('ClampMagenta',(7,2,1),((rad+6.7)*math.sin(va),top-3,(rad+6.7)*math.cos(va)),'pink',(0,math.degrees(va),0))
# Massive inclined support wings radiate out from lower tower corners.
for sx in [-1,1]:
    for sz in [-1,1]:
        aa=(sx*124,17,sz*96);bb=(sx*63,126,sz*49)
        beam('MainButtress',aa,bb,23,'concrete')
        beam('ButtressArmour',(sx*119,21,sz*91),(sx*62,123,sz*46),14,'edge')
        beam('SupportCyan',(sx*116,28,sz*103),(sx*62,118,sz*60),2,'cyan');parts[-1]['material']='Neon';parts[-1]['solid']=False
        part('ButtressCap',(29,12,29),(sx*63,129,sz*49),'edge');snow('ButtressSnow',29,29,sx*63,135.3,sz*49)
# Crown: cyan energy cylinder surrounded by eight tall fins and hoop frames.
def crown_ring(name,r,y,width,color):
    for j in range(24):
        a=j*math.pi/12;b=(j+1)*math.pi/12
        p=beam(name,(r*math.sin(a),y,r*math.cos(a)),(r*math.sin(b),y,r*math.cos(b)),width,color)
        if color=='cyan':p['material']='Neon';p['solid']=False
pipe('CrownPlinth',(0,536,0),(0,545,0),37)
p=pipe('CrownEnergy',(0,547,0),(0,595,0),21);p['material']='Neon';p['color']=list(PALETTE['cyan']);p['solid']=False
for y in [547,563,579,595]:crown_ring('CrownHoop',24,y,3,'edge')
for j in range(8):
    a=j*math.pi/4
    x,z=36*math.sin(a),36*math.cos(a)
    part('CrownFin',(7,69,8),(x,577.5,z),'edge',rotation=(0,math.degrees(a),0))
    trim('CrownMagenta',(2,24,1),(40.5*math.sin(a),575,40.5*math.cos(a)),'pink',(0,math.degrees(a),0))
    snow('FinSnow',7,8,x,612.3,z,(0,math.degrees(a),0))
pipe('CrownCap',(0,597,0),(0,608,0),26);snow('CapSnow',35,35,0,608.4,0)
crown_ring('CapLight',25,597,1,'cyan')
pipe('Antenna',(0,608,0),(0,626,0),.8)
# Monumental front entry and high warm glass lobby.
part('LobbyFloor',(82,3,53),(0,15.5,-65),'edge')
part('LobbyBack',(82,77,3),(0,54.5,-40),'metal')
for x in [-39,39]:part('LobbySide',(4,77,50),(x,54.5,-65),'edge')
part('LobbyGlass',(74,73,.7),(0,53,-91),'glass','Glass',alpha=.38)
for x in [-30,-15,0,15,30]:part('LobbyMullion',(1.5,73,1),(x,53,-92),'edge')
for y in [34,53,72]:part('LobbyTransom',(74,1.5,1),(0,y,-92),'edge')
for x in [-30,-15,0,15,30]:trim('LobbyWarmColumn',(1,63,1),(x,50,-86),'warm')
for x in [-46,46]:
    part('EntryPier',(11,85,15),(x,56.5,-86),'edge')
    trim('EntryCyan',(2,66,1),(x,50,-94.3),'cyan')
part('EntryHeader',(104,13,16),(0,99,-86),'edge');snow('HeaderSnow',104,16,0,105.8,-86)
sign('MegaTowerName','MEGA TOWER',(93,10,1),(0,99,-95),'warm')
sign('EntryNumber','21',(20,12,1),(0,84,-93),'snow')
part('LobbyRoof',(82,3,53),(0,94,-65),'metal');snow('LobbySnow',82,53,0,95.8,-65)
for i in range(7):part('EntryStep',(77,2,3.5),(0,13-i*2,-96-i*3.5),'concrete','Concrete')
# Rear service spine details and three delivery doors.
for y,r in [(150,68),(270,58),(385,49),(488,41)]:
    part('RearVent',(16,34,2),(0,y,r+2),'dark')
    for j in range(9):part('RearLouvre',(14,1.4,1),(0,y-13+j*3.2,r+3.6),'edge')
for x in [-39,0,39]:
    part('RearPortal',(34,35,12),(x,31.5,96),'edge')
    part('RearDoor',(25,25,1),(x,28,102.8),'dark')
    for y in range(18,40,4):part('DoorSlat',(23,.8,1),(x,y,103.6),'metal')
    trim('DoorLamp',(20,1,1),(x,46,103),'warm');snow('PortalSnow',34,12,x,49.3,96)
sign('RearNumber','21',(17,12,1),(0,61,79),'snow',(0,180,0))
for side in [-1,1]:
    for x in [67,104]:
        part('Planter',(28,9,21),(side*x,18.5,-104),'concrete','Concrete');snow('PlanterSnow',28,21,side*x,23.3,-104)
        trim('PlanterLamp',(4,2,1),(side*x,18,-115),'warm')

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

spec=dict(SchemaVersion=1,AssetId='MC-21',AssetName='Mega Tower',AssetClass='Building',City='MegaCity',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityMegaTower')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-21','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
    e,p=item(model,'Script','MegaTowerRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/21-mega-tower.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityMegaTowerSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityMegaTowerGeometry.lua').write_text('-- Generated from tools/build_mega_tower.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/mega-tower-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
