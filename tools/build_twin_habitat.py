"""Deterministic Roblox Parts-only MC-09 model and matching Rojo module/export.
Run from repository root: python tools/build_twin_habitat.py
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

# MC-09: two unequal residential towers on one podium, explicitly no skybridge.
PALETTE['plant']=(55,103,79)
part('Foundation',(180,4,118),(0,2,0),'concrete','Concrete')
part('PodiumFloor',(170,2,106),(0,5,0),'edge')
part('PodiumRear',(168,39,3),(0,26,50),'metal')
for x in [-83,83]:part('PodiumSide',(3,39,103),(x,26,0),'concrete','Concrete')
for x in [-72,-54,-18,0,18,54,72]:
    part('ShopGlass',(16,22,.6),(x,18,-50),'glass','Glass',alpha=.45)
    part('ShopMullion',(1.2,25,2),(x-8.5,18,-50),'edge')
    part('ShopCounter',(12,4,6),(x,8,-35),'edge')
    trim('ShopWarm',(13,.6,.7),(x,28,-49),'warm')
for x,label in [(-63,'MARKT'),(-7,'SUPPLY'),(15,'FOOD'),(64,'REPAIR')]:
    sign('ShopName',label,(22,5,1),(x,29,-52),'cyan')
for x,label in [(-36,'A'),(36,'B')]:
    for dx in [-8,8]:part('EntryPost',(3,28,6),(x+dx,20,-53),'concrete','Concrete')
    part('EntryHeader',(19,8,7),(x,31,-53),'edge')
    sign('EntranceLetter',label,(12,8,1),(x,32,-57),'warm')
    for i in range(5):part('EntryStep',(13,1,2),(x,5-i,-55-i*2),'concrete','Concrete')
part('PodiumUpperFloor',(172,2,108),(0,34,0),'edge')
for x in [-66,-44,-22,0,22,44,66]:
    part('PodiumUpperGlass',(20,10,.6),(x,40,-51),'glass','Glass',alpha=.45)
    trim('UpperShopWarm',(15,.5,.7),(x,37,-50),'warm')
part('PodiumRoof',(177,3,112),(0,47,0),'edge')
snow('PodiumSnow',177,112,0,48.8,0)
sign('HabitatName','09  HABITAT',(77,10,1),(0,40,-53),'cyan')
# Apartment towers: deep wraparound balconies with hollow window bays.
for tower,(x,count,garden) in enumerate([(-43,16,7),(43,12,5)]):
    bottom=50;top=bottom+count*14
    # Small service core instead of solid backing behind facade glass.
    part('ServiceCore',(14,top-bottom,15),(x,(bottom+top)/2,10),'metal')
    for dx in [-26,26]:
        for z in [-24,24]:part('TowerPier',(4,top-bottom+3,5),(x+dx,(bottom+top)/2,z),'concrete','Concrete')
    for level in range(count):
        y=bottom+level*14
        winter=level in [garden,garden+1]
        if level!=garden+1:
            part('ApartmentFloor',(49,1.5,47),(x,y,0),'edge')
        # Full side/rear balconies. The garden omits its dividing front slab.
        for dx in [-29,29]:
            part('SideBalcony',(8,2,63),(x+dx,y,-3),'edge')
            part('SideRailing',(.5,4,60),(x+dx+(3 if dx>0 else -3),y+3,-3),'glass','Glass',alpha=.5)
        part('RearBalcony',(50,2,8),(x,y,27),'edge')
        part('RearRailing',(49,4,.5),(x,y+3,30.5),'glass','Glass',alpha=.5)
        if not winter:
            if level!=garden+2:part('FrontBalcony',(51,2,12),(x,y,-29),'edge')
            part('FrontRailing',(48,4,.5),(x,y+3,-34.5),'glass','Glass',alpha=.5)
            part('BalconyHandrail',(50,.6,1),(x,y+5.3,-34.5),'edge')
            if level%3==0:trim('BalconyCyan',(50,.65,.7),(x,y,-35.5),'cyan')
            # Snow only on a narrow exposed lip, leaving balcony route clear.
            if level!=garden+2:snow('BalconySnow',51,2,x,y+1.3,-34)
            for dx in [-16,0,16]:
                part('FrontWindow',(14,10,.6),(x+dx,y+7,-22.5),'glass','Glass',alpha=.45)
                part('FrontMullion',(.8,12,1),(x+dx-7.5,y+7,-22.5),'edge')
                trim('RoomWarm',(11,.5,.7),(x+dx,y+11,-21.5),'warm')
        for side in [-1,1]:
            xx=x+side*24
            part('SideWindow',(.6,10,40),(xx,y+7,0),'glass','Glass',alpha=.45)
            part('SideMullion',(1,12,.8),(xx,y+7,0),'edge')
            if level%2==0:trim('SideWarm',(.7,.5,35),(xx-side*.8,y+11,0),'warm')
        for dx in [-15,15]:
            part('RearWindow',(12,10,.6),(x+dx,y+7,23),'glass','Glass',alpha=.45)
            trim('RearWarm',(10,.5,.7),(x+dx,y+11,22),'warm')
    # Prominent two-storey glazed conservatory projecting over the balcony line.
    gy=bottom+garden*14
    part('WintergardenFloor',(52,2,23),(x,gy,-24),'edge')
    part('WintergardenRoof',(54,2,25),(x,gy+28,-24),'edge')
    snow('WintergardenSnow',54,25,x,gy+29.3,-24)
    for dx in [-19,-6.3,6.3,19]:
        part('WintergardenGlass',(12,25,.6),(x+dx,gy+14,-36),'glass','Glass',alpha=.55)
        part('WintergardenMullion',(.7,27,1),(x+dx-6.3,gy+14,-36),'edge')
    for side in [-1,1]:part('GardenSideGlass',(.6,25,22),(x+side*25.5,gy+14,-24),'glass','Glass',alpha=.5)
    part('GardenTransom',(52,.8,1),(x,gy+20,-36),'edge')
    trim('WintergardenLight',(48,.7,1),(x,gy+26,-33),'warm')
    for dx in [-16,16]:
        part('Planter',(7,3,7),(x+dx,gy+2.5,-25),'concrete','Concrete')
        part('PlantTrunk',(1.2,9,1.2),(x+dx,gy+8,-25),'edge')
        for yy,w in [(10,7),(14,5),(17,3)]:part('PlantLeaves',(w,3,w),(x+dx,gy+yy,-25),'plant','SmoothPlastic',solid=False)
    part('GardenBench',(15,2,4),(x,gy+3,-19),'metal')
    # Roof plant seated on structural roof, above penthouse glazing.
    part('TowerRoof',(69,3,69),(x,top+1,-2),'edge')
    snow('TowerRoofSnow',69,69,x,top+2.8,-2)
    part('RoofServiceRoom',(32,13,30),(x,top+9,1),'metal')
    part('ServiceRoomCap',(36,2,34),(x,top+16.5,1),'edge')
    snow('ServiceSnow',36,34,x,top+17.8,1)
    vent(x,top+20.5,5,12)
    for dx in [-24,24]:
        part('RoofPylon',(6,18,8),(x+dx,top+10,12),'edge')
        trim('PylonLight',(.7,11,.7),(x+dx,top+12,7.5),'warm')
    part('Antenna',(.6,17,.6),(x+8,top+26,8),'edge')
    trim('Beacon',(1.2,1.2,1.2),(x+8,top+34.5,8),'pink')
    # Separate heat mains at the rear of each tower, supported by clamps.
    for dx in [-8,8]:
        pipe('HeatRiser',(x+dx,8,40),(x+dx,top+11,40),2.3)
        pipe('RoofHeatElbow',(x+dx,top+11,40),(x+dx,top+11,15),2.3)
        for y in range(55,int(top),28):
            part('HeatClamp',(6,2,2),(x+dx,y,42.7),'edge')
            beam('HeatSupport',(x+dx,y,23),(x+dx,y,38),1.2,'edge')
    for y in [bottom+28,bottom+count*7]:
        pipe('HeatingBridge',(x-8,y,40),(x+8,y,40),1.7)
# Long sign attached to the taller tower's left front pier.
part('SignSpine',(12,145,5),(-69,168,-41),'metal')
sign('HabitatVertical','H\nA\nB\nI\nT\nA\nT',(10,88,1),(-69,180,-44),'pink')
sign('TowerNumber','09',(10,12,1),(-69,126,-44),'pink')
for x in [-75.5,-62.5]:trim('SignBorder',(.6,144,.7),(x,168,-44),'pink')
# Attach the sign in front of all balcony and conservatory edges.
for y in [116,228]:part('SignMount',(4,3,14),(-69,y,-31.5),'edge')
# Podium rooftop heating units and rear service doors.
for x in [-66,66]:vent(x,51.5,33,12)
for x in [-43,43]:
    part('HeatExchanger',(24,22,13),(x,16,55),'edge')
    for y in [9,13,17,21,25]:trim('ThermalLouvre',(19,.7,.7),(x,y,62),'warm')
    part('ServiceDoor',(14,23,1),(x+(-23 if x<0 else 23),17,52),'edge')
sign('RearName','HABITAT 09',(40,8,1),(0,30,52.5),'cyan',(0,180,0))

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

spec=dict(SchemaVersion=1,AssetId='MC-09',AssetName='Twin Habitat Towers',AssetClass='Building',City='MegaCity',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityTwinHabitatTowers')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-09','EnergyType':'Thermal','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
    e,p=item(model,'Script','TwinRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/09-twin-habitat-towers.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityTwinHabitatSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityTwinHabitatGeometry.lua').write_text('-- Generated from tools/build_twin_habitat.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/twin-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
