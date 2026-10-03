"""Deterministic Roblox Parts-only MC-20 model and matching Rojo module/export.
Run from repository root: python tools/build_skybridge_towers.py
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

# MC-20 twin towers joined by an occupied upper bridge and a common podium.
part('Foundation',(264,4,146),(0,2,0),'concrete','Concrete')
part('Podium',(254,8,134),(0,8,0),'edge');snow('PodiumSnow',254,134,0,12.3,0)
def glass_volume(name,cx,cz,w,d,bottom,top):
    part(name+'Floor',(w,3,d),(cx,bottom+1.5,cz),'edge')
    for x in [cx-w/2+2,cx+w/2-2]:
        for z in [cz-d/2+2,cz+d/2-2]:
            part(name+'Corner',(4,top-bottom,4),(x,(top+bottom)/2,z),'metal')
    y=bottom+3;row=0
    while y<top-3:
        h=min(18,top-3-y)
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
        row+=1;y+=18
    part(name+'Roof',(w+2,3,d+2),(cx,top-1.5,cz),'edge')
    snow(name+'Snow',w+2,d+2,cx,top+.3,cz)

glass_volume('PodiumHall',0,0,236,108,12,60)
# Continuous tower frames with windows, floor plates and independent roof equipment.
for side in [-1,1]:
    cx=side*86
    glass_volume('Tower',cx,0,54,70,60,338)
    for dx in [-22,22]:
        part('FrontArmour',(7,266,7),(cx+dx,197,-37),'edge')
        trim('TowerCyan',(1.2,239,1),(cx+dx,196,-41.3),'cyan')
        part('RearArmour',(7,266,7),(cx+dx,197,37),'edge')
    for y in [69,165,266,324]:
        for dx in [-22,22]:
            part('ArmourClamp',(10,8,9),(cx+dx,y,-37),'concrete','Concrete')
    part('RoofCrown',(42,12,56),(cx,344,0),'metal');snow('CrownSnow',42,56,cx,350.3,0)
    vent(cx,353,7,14)
    pipe('Aerial',(cx+side*16,350,14),(cx+side*16,371,14),.65)
    trim('AerialBeacon',(1,7,1),(cx+side*16,374,14),'pink')
    for y in [90,180,288,324]:
        part('RearVent',(15,21,1),(cx,y,36.5),'dark')
        for j in range(6):part('RearVentSlat',(13,1,1),(cx,y-8+j*3.2,37.3),'edge')
    trim('MagentaAccent',(1.4,36,1),(cx-side*20,92,-42),'pink')
# Bridge spans into both towers. Glass front/back, solid floor and snow-topped roof.
part('BridgeFloor',(130,5,44),(0,233,0),'edge')
part('BridgeRoof',(132,4,46),(0,262,0),'edge');snow('BridgeRoofSnow',132,46,0,264.3,0)
for front in [-1,1]:
    z=front*22
    part('BridgeGlass',(128,24,.6),(0,248,z),'glass','Glass',alpha=.4)
    for x in range(-60,61,15):part('BridgeMullion',(1.6,25,1),(x,248,z+front*.7),'metal')
    trim('BridgeEdgeLight',(131,1.4,1),(0,232,z+front*1.4),'cyan')
    part('BridgeUpperFrame',(131,2,1.5),(0,259,z+front*.8),'metal')
# Exposed truss below the occupied volume: alternating diagonals on both faces.
for z in [-18,18]:
    beam('LowerChord',(-61,219,z),(61,219,z),3,'edge')
    for i in range(6):
        x=-60+i*20
        aa=(x,219 if i%2==0 else 230,z);bb=(x+20,230 if i%2==0 else 219,z)
        beam('BridgeDiagonal',aa,bb,3.4,'metal')
        face=z+(-2 if z<0 else 2)
        beam('TrussNeon',(aa[0],aa[1],face),(bb[0],bb[1],face),.8,'cyan');parts[-1]['material']='Neon';parts[-1]['solid']=False
    for side in [-1,1]:beam('BridgeCorbel',(side*70,207,z),(side*51,231,z),7,'edge')
for x in [-40,0,40]:beam('TrussCrossMember',(x,219,-18),(x,219,18),2,'edge')
# Three warm ring chandeliers, benches and tables visible through the skybridge glass.
for cx in [-40,0,40]:
    for j in range(20):
        a=2*math.pi*j/20;b=2*math.pi*(j+1)/20
        p=beam('BridgeChandelier',(cx+8*math.cos(a),256,8*math.sin(a)),(cx+8*math.cos(b),256,8*math.sin(b)),.6,'warm');p['material']='Neon';p['solid']=False
    part('BridgeTable',(10,1,7),(cx,240,0),'edge')
    part('TablePedestal',(2,4,2),(cx,237.5,0),'metal')
    for z in [-9,9]:part('BridgeBench',(12,2,3),(cx,237,z),'metal')
# Front lobby portal stays clear of structural trim.
for x in [-50,50]:
    part('EntryPier',(10,51,10),(x,37.5,-56),'edge')
    trim('EntryMagenta',(1,34,1),(x,34,-61.8),'pink')
part('EntryHeader',(108,13,10),(0,61,-56),'edge');snow('HeaderSnow',108,10,0,67.8,-56)
sign('SkybridgeName','SKYBRIDGE',(96,10,1),(0,61,-62),'snow')
sign('EntryNumber','20',(18,10,1),(0,48,-57),'snow')
for x in [-31,31]:part('DoorFrame',(3,38,4),(x,31,-56),'metal')
for x in [-23,-8,8,23]:trim('LobbyDownlight',(6,.7,12),(x,55,-36),'warm')
for i in range(6):part('EntryStep',(72,2,3),(0,11-i*2,-67-i*3),'concrete','Concrete')
# Podium fins, snow terraces and smaller side pavilions.
for side in [-1,1]:
    for dx in [73,101]:
        part('PodiumPier',(6,48,7),(side*dx,36,-55),'concrete','Concrete')
    part('SideTerrace',(30,21,36),(side*108,22.5,-41),'metal');snow('TerraceSnow',30,36,side*108,33.3,-41)
    part('Planter',(34,8,20),(side*69,16,-64),'concrete','Concrete');snow('PlanterSnow',34,20,side*69,20.3,-64)
    trim('PlanterLamp',(4,2,1),(side*69,16,-74.8),'warm')
# Four rear service bays below the common hall; no roads within the footprint.
for x in [-84,-28,28,84]:
    part('ServicePortal',(42,27,8),(x,25.5,57),'edge')
    part('ServiceDoor',(30,21,1),(x,24,61.8),'dark')
    for y in range(16,34,3):part('DoorSlat',(28,.7,1),(x,y,62.6),'metal')
    trim('ServiceLamp',(20,1,1),(x,37,62),'warm')
    snow('ServiceSnow',42,8,x,39.3,57)
sign('RearNumber','20',(14,10,1),(0,49,55.5),'snow',(0,180,0))

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

spec=dict(SchemaVersion=1,AssetId='MC-20',AssetName='Skybridge Towers',AssetClass='Building',City='MegaCity',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCitySkybridgeTowers')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-20','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
    e,p=item(model,'Script','SkybridgeRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/20-skybridge-towers.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCitySkybridgeTowersSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCitySkybridgeTowersGeometry.lua').write_text('-- Generated from tools/build_skybridge_towers.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/skybridge-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
