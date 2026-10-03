"""Deterministic Roblox Parts-only MC-12 model and matching Rojo module/export.
Run from repository root: python tools/build_cooling_plant.py
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

# MC-12: open cooling tower shells, common pump hall and twin steam outlets.
PALETTE['insulation']=(104,125,142)
PALETTE['radiation']=(123,255,47)
part('Foundation',(246,4,150),(0,2,0),'concrete','Concrete')
part('PumpFloor',(180,2,111),(0,5,-6.5),'edge')
part('PumpRear',(180,42,4),(0,27,51),'metal')
for x in [-92,92]:part('PumpSide',(4,42,111),(x,27,-6.5),'concrete','Concrete')
part('PumpFront',(180,42,4),(0,27,-60),'metal')
part('HallRoof',(195,4,124),(0,50,-5),'edge')
snow('HallRoofSnow',195,124,0,52.3,-5)
# Front heat exchangers and identification above them.
sign('PlantName','COOLING PLANT',(106,10,1),(0,41,-63),'snow')
sign('PlantNumber','12',(14,10,1),(76,41,-63),'snow')
for x in [-60,0,60]:
    part('ExchangerHousing',(44,26,9),(x,20,-66),'dark')
    for dx in [-22,22]:part('ExchangerPillar',(3,27,12),(x+dx,20.5,-67),'edge')
    part('ExchangerCap',(49,3,14),(x,35.5,-67),'edge')
    snow('ExchangerSnow',49,14,x,37.3,-67)
    for y in [10,14,18,22,26,30]:
        trim('HeatFin',(39,1.4,.8),(x,y,-71.2),'warm')
        part('HeatGuard',(39,.6,.8),(x,y+1.4,-72),'edge')
    for dx in [-14,0,14]:part('GuardBar',(1,23,1),(x+dx,20,-72.8),'metal')
    part('ExchangerBase',(49,3,14),(x,6.5,-67),'concrete','Concrete')
for x in [-87,87]:
    part('FrontArmour',(7,44,6),(x,28,-63),'concrete','Concrete')
    trim('HallLamp',(1.5,9,1),(x,35,-66.6),'warm')
# Two tapered, hollow tower shells. Profiles establish the narrow throat.
for tower,(cx,height) in enumerate([(-48,85),(48,100)]):
    base=53
    profile=[(0,36),(20,33),(40,29),(60,26),(80,25),(100,25.5),(120,27),(140,29)]
    profile=[(base+y*height/140,rad*1.1) for y,rad in profile]
    for level,((ya,ra),(yb,rb)) in enumerate(zip(profile,profile[1:])):
        for i in range(24):
            t=2*math.pi*i/24
            length=math.hypot(yb-ya,rb-ra);dy=(yb-ya)/length;dr=(rb-ra)/length
            # Tangent X, sloped Y, inward Z; maintains a right-handed orthonormal frame.
            xx=(-math.sin(t),0,math.cos(t));yy=(dr*math.cos(t),dy,dr*math.sin(t));zz=(-dy*math.cos(t),dr,-dy*math.sin(t))
            p=part('TowerShell',(2*max(ra,rb)*math.tan(math.pi/24)+.15,length+.15,2.6),(cx+(ra+rb)/2*math.cos(t),(ya+yb)/2,(ra+rb)/2*math.sin(t)),'concrete','Concrete')
            p['basis']=[xx[0],yy[0],zz[0],xx[1],yy[1],zz[1],xx[2],yy[2],zz[2]]
        # External structural ribs track the changing silhouette.
        for i in range(8):
            t=2*math.pi*i/8
            beam('TowerRib',(cx+(ra+2)*math.cos(t),ya,(ra+2)*math.sin(t)),(cx+(rb+2)*math.cos(t),yb,(rb+2)*math.sin(t)),2.2,'edge')
    top=base+height
    def ring(name,y,rad,width,color,neon=False):
        for i in range(32):
            a=2*math.pi*i/32;b=2*math.pi*(i+1)/32
            p=beam(name,(cx+rad*math.cos(a),y,rad*math.sin(a)),(cx+rad*math.cos(b),y,rad*math.sin(b)),width,color)
            if neon:p['material']='Neon';p['solid']=False
    ring('TowerFootRing',base+4,40.2,3,'edge')
    ring('TowerRim',top,32.5,3.5,'edge')
    ring('RimSnow',top+2,32.5,.7,'snow')
    ring('RadiationRing',top-7,33,1.7,'radiation',True)
    ring('InnerReactorGlow',top-12,28,2,'radiation',True)
    # No cap across the mouth: one emitter marker sits in each actual opening.
    p=part('SteamMarker',(1,1,1),(cx,top+1,0),'snow','SmoothPlastic',solid=False,alpha=1)
    p['steamOutlet']=True
    for i in range(8):
        t=2*math.pi*i/8
        part('RimBracket',(3,10,4),(cx+33*math.cos(t),top-3,33*math.sin(t)),'metal',rotation=(0,-math.degrees(t),0))
    for z in [-35,35]:
        part('TowerAccess',(18,13,5),(cx,60,z),'edge')
        for dx in [-5,0,5]:trim('AccessLight',(1,8,.7),(cx+dx,60,z+(-3 if z<0 else 3)),'radiation')
# Paired heavy external water mains, with segmented rounded elbows.
def arc(cx,cy,z,r,a0,a1):
    return [(cx+r*math.cos(math.radians(a0+(a1-a0)*i/10)),cy+r*math.sin(math.radians(a0+(a1-a0)*i/10)),z) for i in range(11)]
for side in [-1,1]:
    for z in [-24,23]:
        points=[(side*80,49,z),(side*99,49,z)]
        curve=arc(99,37,z,12,90,0)
        points += [(side*x,y,zz) for x,y,zz in curve[1:]]
        points += [(side*111,11,z)]
        for aa,bb in zip(points,points[1:]):pipe('CoolingMain',aa,bb,6)
        for x in [86,96]:
            pipe('MainCollar',(side*(x-1),49,z),(side*(x+1),49,z),6.7)
            parts[-1]['color']=list(PALETTE['radiation']);parts[-1]['material']='Neon'
        pipe('MainFootCollar',(side*111,10,z),(side*111,14,z),6.7)
        part('PipePlinth',(18,6,19),(side*111,7,z),'concrete','Concrete')
        for y in [22,34]:beam('PipeSupport',(side*93,y,z),(side*106,y,z),2.5)
    # Maintenance platform and outer access ladder.
    part('ServiceDeck',(17,2,38),(side*100,34,1),'edge')
    for z in [-17,0,19]:part('DeckPost',(1,7,1),(side*107,38.5,z),'warm')
    part('DeckRail',(1.3,1,38),(side*107,42.5,1),'warm')
    for z in [-17,19]:beam('DeckBrace',(side*94,19,z),(side*106,33,z),2)
    for z in [-5,5]:part('LadderRail',(1,30,1),(side*110,19,z),'edge')
    for y in range(5,34,4):part('LadderRung',(.8,.8,9),(side*110,y,0),'warm')
# Rear pump control doors, warmer glazing and independent roof ventilation.
for x in [-65,65]:
    part('PumpDoor',(22,26,1),(x,19,54),'edge')
    sign('PumpId','PUMP A' if x<0 else 'PUMP B',(29,7,1),(x,37,54),'radiation',(0,180,0))
for x in [-22,22]:
    part('ControlCabinet',(22,20,9),(x,16,58),'metal')
    for dx in [-6,6]:
        part('ControlPanel',(8,13,.6),(x+dx,18,63),'dark')
        trim('PanelLight',(5,1,.7),(x+dx,21,63.7),'radiation')
for x in [-64,0,64]:vent(x,55,44,16)
# Roof service route at the front, clear of both tower shells.
part('RoofWalkway',(162,1,11),(0,53.5,-49),'metal')
for x in range(-80,81,20):part('RoofRailPost',(1,7,1),(x,57.5,-54),'warm')
part('RoofRail',(162,1,1.3),(0,61.5,-54),'warm')
for x in [-24,24]:
    part('RoofPump',(18,8,12),(x,57,-43),'edge')
    for dx in [-6,-3,0,3,6]:part('PumpLouvre',(1,5,.6),(x+dx,57,-49.5),'dark')
    snow('PumpSnow',18,12,x,61.3,-43)
# Native geometry trefoil avoids relying on font support for warning symbols.
part('RadiationPlaque',(21,21,1),(-73,40,-63.3),'dark')
pipe('RadiationCentre',(-73,40,-64),(-73,40,-64.6),1.8)
parts[-1]['color']=list(PALETTE['radiation']);parts[-1]['material']='Neon';parts[-1]['solid']=False
for lobe in range(3):
    for segment in range(6):
        angle=math.radians(30+lobe*120+segment*10)
        trim('RadiationTrefoil',(1.55,5.2,.6),(-73+6.2*math.cos(angle),40+6.2*math.sin(angle),-64.3),'radiation',(0,0,math.degrees(angle)-90))
# Green coolant inspection strips on the large downpipes.
for side in [-1,1]:
    for z in [-24,23]:
        trim('CoolantWindow',(1.8,17,.8),(side*111,27,z-6.3),'radiation')

def matrix(p):
    if "basis" in p:return p["basis"]
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

spec=dict(SchemaVersion=1,AssetId='MC-12',AssetName='Cooling Plant',AssetClass='Building',City='MegaCity',
    EnergyType='Thermal',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
    PerformanceBudget=dict(MaxVisibleParts=1400,MaxGameplayHitboxes=1,PermanentLights=0,PermanentParticleEmitters=2,PerPartScripts=0))
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityCoolingPlant')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-12','EnergyType':'Thermal','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
        if p.get('steamOutlet'):
            attachment,ap=item(e,'Attachment','SteamOutlet')
            cf(ap,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1])
    runtime=(OUT/'MegaCityBuildingRuntime.lua').read_text()
    # Larger continuous plumes for the two large cooling-tower mouths only.
    runtime=runtime.replace('e.Rate = 8','e.Rate = 18').replace('NumberRange.new(8, 12)','NumberRange.new(12, 18)').replace('NumberSequenceKeypoint.new(0, 12)','NumberSequenceKeypoint.new(0, 28)').replace('NumberSequenceKeypoint.new(0.5, 28)','NumberSequenceKeypoint.new(0.5, 46)').replace('NumberSequenceKeypoint.new(1, 44)','NumberSequenceKeypoint.new(1, 66)')
    e,p=item(model,'Script','CoolingRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/12-cooling-plant.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityCoolingPlantSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityCoolingPlantGeometry.lua').write_text('-- Generated from tools/build_cooling_plant.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/cooling-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
