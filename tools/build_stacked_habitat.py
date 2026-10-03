"""Deterministic Roblox Parts-only MC-08 model and matching Rojo module/export.
Run from repository root: python tools/build_stacked_habitat.py
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

# MC-08: seven offset inhabited blocks around a load-bearing service core.
part('Foundation',(160,4,132),(0,2,0),'concrete','Concrete')
part('PodiumFloor',(150,2,120),(0,5,0),'edge')
for x in [-73,73]:part('PodiumSide',(3,29,112),(x,21,0),'concrete','Concrete')
part('PodiumRear',(148,29,3),(0,21,56),'metal')
for x in [-62,-46,-30,30,46,62]:
    part('ShopGlass',(14,23,.6),(x,19,-56),'glass','Glass',alpha=.45)
    part('ShopPost',(1.5,27,2),(x-8,20,-56),'edge')
    trim('ShopWarm',(11,.6,1),(x,29,-54),'warm')
    part('ShopCounter',(12,4,6),(x,8,-44),'edge')
for x in [-19,19]:part('EntryPier',(5,30,7),(x,21,-56),'concrete','Concrete')
part('PodiumRoof',(155,3,124),(0,37,0),'edge')
snow('PodiumSnow',155,124,0,38.8,0)
part('EntranceCanopy',(48,3,16),(0,28,-60),'metal')
snow('EntranceSnow',48,16,0,29.8,-60)
sign('HabitatName','HABITAT',(43,8,1),(0,33,-65),'warm')
sign('HabitatSubtitle','RESIDENTIAL BLOCK 08',(43,4,1),(0,25,-69),'cyan')
for i in range(5):part('EntryStep',(35,1,2),(0,5-i,-60-i*2),'concrete','Concrete')
for x,label in [(-49,'FOOD'),(49,'SUPPLY')]:sign('ShopName',label,(30,6,1),(x,29,-58),'cyan')
# Core connects all stacked volumes, with vertical slots and thermal service shafts.
part('ServiceCore',(34,241,37),(0,157,8),'metal')
for x in [-18,18]:
    part('CoreRib',(4,243,42),(x,158,8),'concrete','Concrete')
    trim('CoreWarm',(.7,226,.7),(x,153,-13.5),'warm')
for y in range(48,262,18):
    part('CoreFrontWindow',(13,11,.6),(0,y,-11),'glass','Glass',alpha=.35)
    trim('CoreWindowWarm',(10,.6,.7),(0,y-3,-11.8),'warm')
# block tuple: centre X, bottom floor Y, centre Z, width, depth
blocks=[(-40,62,-16,62,56),(40,50,18,60,54),(25,124,-30,64,58),(-28,122,30,60,54),(-42,186,-13,65,58),(35,217,12,62,56),(-4,266,9,40,39)]
for index,(x,y,z,w,d) in enumerate(blocks):
    height=39 if index<6 else 20
    floors=3 if index<6 else 1
    storey=13 if index<6 else 20
    part('BlockBase',(w+2,3,d+2),(x,y,z),'concrete','Concrete')
    for level in range(floors):
        fy=y+level*storey
        if level:part('ApartmentFloor',(w,1.5,d),(x,fy,z),'edge')
        for front in [-1,1]:
            zz=z+front*d/2
            part('WindowSill',(w,2,2),(x,fy+2,zz),'edge')
            for j in [-1,0,1]:
                wx=x+j*(w-6)/3
                part('ApartmentWindow',((w-8)/3-1,storey-4,.6),(wx,fy+storey/2+1,zz),'glass','Glass',alpha=.45)
                part('ApartmentMullion',(.7,storey-2,1),(wx-(w-8)/6,fy+storey/2+1,zz),'edge')
                trim('ApartmentWarm',((w-8)/3-3,.5,.7),(wx,fy+storey-1,zz-front*.8),'warm')
        for side in [-1,1]:
            xx=x+side*w/2
            part('SideSill',(2,2,d),(xx,fy+2,z),'edge')
            for dz in [-d/4,d/4]:
                part('SideWindow',(.6,storey-4,d/2-3),(xx,fy+storey/2+1,z+dz),'glass','Glass',alpha=.45)
                trim('SideWarm',(.7,.5,d/2-6),(xx-side*.8,fy+storey-1,z+dz),'warm')
    for dx in [-w/2,w/2]:
        for dz in [-d/2,d/2]:part('BlockCorner',(3,height+2,3),(x+dx,y+height/2,z+dz),'concrete','Concrete')
    roof=y+height+1
    part('BlockRoof',(w+5,3,d+5),(x,roof,z),'edge')
    snow('RoofSnow',w+5,d+5,x,roof+1.8,z)
    # Deep attached roof terrace along front edge, behind a transparent railing.
    for dx in [-w/2+3,w/2-3]:
        part('TerracePlanter',(6,3,10),(x+dx,roof+3.3,z-d/2+7),'concrete','Concrete')
        snow('PlanterSnow',6,10,x+dx,roof+5.1,z-d/2+7)
    part('TerraceGlass',(w-9,4,.5),(x,roof+4,z-d/2-1),'glass','Glass',alpha=.5)
    part('TerraceRail',(w-8,.6,.8),(x,roof+6.2,z-d/2-1),'edge')
    trim('BlockCyan',(w+3,.75,.7),(x,y,z-d/2-1.6),'cyan')
    for side in [-1,1]:trim('SideCyan',(.7,.75,d+3),(x+side*(w/2+1.6),y,z),'cyan')
    # Cantilever braces meet the core; bottom supports continue into the podium.
    attachY=max(38,y-22)
    for zz in [z-d/2+8,z+d/2-8]:
        beam('LoadBrace',((16 if x>=0 else -16),attachY,max(-9,min(zz,25))),(x,y-1,zz),6,'concrete')
    vent(x,roof+4.5,z+8,11)
    part('BalconyAC',(8,7,5),(x+w/2-8,y+8,z+d/2+3),'edge')
    for k in [-2,0,2]:part('ACLouvre',(6,.5,.7),(x+w/2-8,y+8+k,z+d/2+5.9),'dark',solid=False)
# Tower supports leave room for the entrance in the podium.
for x in [-38,38]:
    part('GroundLoadColumn',(8,35,10),(x,53,5),'concrete','Concrete')
# Long residence identification on the front block and upper right side.
sign('StackVertical','S\nT\nA\nC\nK',(9,35,1),(10,145,-60.5),'pink')
sign('BlockNumber','08',(24,25,1),(47,236,-17),'cyan')
sign('ResidentialLabel','RESIDENTIAL',(35,5,1),(47,219,-17),'cyan')
# Heavy heat supply runs vertically behind the building; insulated angular elbows.
for x,r in [(-8,3.2),(8,2.6)]:
    pipe('HeatMain',(x,8,68),(x,282,68),r)
    for y in [24,63,126,190,245,278]:
        part('PipeClamp',(r*2+3,2,2),(x,y,68+r),'edge')
        beam('PipeMount',(x,y,27),(x,y,65),2,'edge')
    for y,targetX,targetZ in [(66,-40,15),(132,25,1),(225,35,42)]:
        pipe('HeatBranch',(x,y,68),(targetX,y,68),r*.75)
        pipe('HeatReturn',(targetX,y,68),(targetX,y,targetZ),r*.75)
# Basement heating plant and service doors stay attached to the same model.
part('HeatingPlant',(30,20,16),(0,15,60),'edge')
for x in [-9,0,9]:
    for y in [10,14,18,22]:trim('HeatExchangeGlow',(6,.6,.7),(x,y,68.5),'warm')
for x in [-48,48]:
    part('RearDoor',(19,22,1),(x,17,58),'edge')
    trim('RearDoorLight',(11,.8,.6),(x,29,58.8),'warm')
sign('RearNumber','HABITAT 08',(36,7,1),(-46,33,59),'cyan',(0,180,0))
# Antennas seated on the upper roof.
for x,h in [(-14,12),(7,18)]:
    part('Antenna',(.6,h,.6),(x,288.5+h/2,16),'edge')
    trim('Beacon',(1.2,1.2,1.2),(x,288.5+h,16),'pink')

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

spec=dict(SchemaVersion=1,AssetId='MC-08',AssetName='Stacked Habitat',AssetClass='Building',City='MegaCity',
    EnergyType='Thermal',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
    PerformanceBudget=dict(MaxVisibleParts=1100,MaxGameplayHitboxes=1,PermanentLights=0,PermanentParticleEmitters=0,PerPartScripts=0))
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityStackedHabitat')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-08','EnergyType':'Thermal','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1100}))
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
    e,p=item(model,'Script','HabitatRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/08-stacked-habitat.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityStackedHabitatSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityStackedHabitatGeometry.lua').write_text('-- Generated from tools/build_stacked_habitat.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/stacked-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
