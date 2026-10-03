"""Deterministic Roblox Parts-only MC-01 model and matching Rojo module/export.
Run from repository root: python tools/build_harbor_gate.py
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

# Ground-plane origin. Sea front faces -Z; city entrance faces +Z.
part('Foundation',(168,4,94),(0,2,0),'concrete','Concrete')
part('HallFloor',(140,2,66),(-8,5,0),'edge')
part('RearWall',(140,25,3),(-8,18.5,31),'metal')
for x in [-77,61]:part('HallEndWall',(3,25,66),(x,18.5,0),'metal')
part('UpperFloor',(126,2,35),(-12,28,14),'edge')
part('UpperRearWall',(126,18,2),(-12,38,30),'metal')
for x in [-74,50]:part('UpperEndWall',(2,18,35),(x,38,14),'metal')
part('UpperRoof',(132,3,40),(-12,48,14),'edge')
snow('UpperRoofSnow',132,40,-12,49.8,14)
# Recessed warm interior, pillars, counters visible behind sea glazing.
for x in range(-65,55,20):
    part('LobbyColumn',(2,23,2),(x,17.5,-10),'edge')
    part('TicketCounter',(11,4,4),(x,8,-13),'edge')
    trim('CounterLight',(10,.5,.4),(x,9,-15.1),'warm')
    trim('LobbyCeilingLight',(12,.5,2),(x,26,-13),'warm')
for x in range(-66,55,12):
    part('SeaGlass',(10.8,22,1),(x,17,-33),'glass','Glass',(12,0,0),alpha=.25)
    part('SeaMullion',(1.1,23,1.8),(x-6,17,-33),'edge',rotation=(12,0,0))
    part('UpperGlass',(10,12,.6),(x,38,-4),'glass','Glass',alpha=.2)
    part('UpperMullion',(.8,14,1),(x-5.5,38,-4.2),'edge')
    trim('UpperWarmBand',(8,.65,.5),(x,33,-3.7),'warm')
trim('SeaFacadeCyan',(139,.7,1.2),(-8,28,-30.6))
part('SeaFacadeSill',(141,2,3),(-8,5.5,-35.3),'edge')
snow('SillSnow',141,3,-8,6.8,-35.3)
# Two asymmetric cantilevered roof blades, snow and continuous cyan edges.
for x,y,w,d in [(-45,34,70,66),(18,43,66,64)]:
    part('CantileverRoof',(w,3,d),(x,y,-12),'metal',rotation=(8,0,0))
    snow('BladeSnow',w,d,x,y+1.8,-12,(8,0,0))
    z=-12-d/2; yy=y+math.sin(math.radians(8))*d/2
    trim('RoofCyanEdge',(w,.8,.7),(x,yy,z))
    for sx in [x-w/2+5,x+w/2-5]:beam('RoofBrace',(sx,24,-6),(sx,y,-34),1.6)
    part('RoofFascia',(w,2.4,.8),(x,yy-.5,z),'edge')
    trim('RoofEdgeInset',(w-3,.55,.85),(x,yy+.4,z-.2))
# Control tower: offset at right, concrete boot, opaque mast and glazed control room.
part('TowerBoot',(28,12,34),(65,10,17),'concrete','Concrete')
part('TowerMast',(22,57,27),(65,44,17),'metal')
for x in [53,77]:part('TowerRib',(2,62,30),(x,43,17),'edge')
part('ControlRoomFloor',(34,3,36),(65,73,17),'edge')
part('ControlRoom',(29,13,31),(65,81,17),'dark')
for x in [51,58,65,72,79]:
    part('ControlGlass',(5.8,9,.6),(x,81,1),'glass','Glass',alpha=.2)
    trim('ControlWarm',(4.8,.7,.7),(x,77,1.5),'warm')
    part('ControlFrame',(.7,11,1),(x-3.2,81,.8),'edge')
part('ControlRoof',(38,3,40),(65,89,17),'metal')
snow('ControlRoofSnow',38,40,65,90.8,17)
trim('ControlRoofEdge',(36,.6,.7),(65,89, -3.3))
sign('HarborVertical','H\nA\nR\nB\nO\nR\n\nG\nA\nT\nE',(10,48,.8),(65,44,2.8),'pink')
for x,h in [(57,12),(72,18)]:
    part('Antenna',(0.6,h,.6),(x,91+h/2,17),'edge')
    trim('AntennaBeacon',(1.2,1.2,1.2),(x,91+h,17),'pink')
# City side entrance faces +Z. Broad entry steps belong to building, not quay.
part('CityEntryWing',(70,17,14),(-8,13,35),'metal')
for x in [-33,-19,-5,9]:
    part('CityLobbyGlass',(11,12,.7),(x,12,42.3),'glass','Glass',alpha=.15)
    trim('LobbyWarm',(9,.7,.8),(x,7,42),'warm')
part('EntryCanopy',(80,2.5,20),(-8,23,39),'edge')
snow('CanopySnow',80,20,-8,24.6,39)
trim('EntryCanopyCyan',(79,.7,.7),(-8,23,49.3))
sign('CityName','HARBOR GATE',(64,5,.8),(-8,26.8,42),'cyan',(0,180,0))
sign('DepartureBoard','DEPARTURES\n01  NEON QUARTER    2 MIN\n02  CORPORATE HEIGHTS    5 MIN\n03  RESEARCH ENCLAVE    8 MIN',(64,13,.8),(-8,37,32),'cyan',(0,180,0))
for i in range(6):
    part('EntryStep',(62,1,2),(-8,6-i*.8,46+i*2),'concrete','Concrete')
for x in [-41,25]:beam('StairRail',(x,10,44),(x,5.5,58),.6)
# Rear industrial details and side facade panelling.
for x in [-55,-35,-15,5,25]:vent(x,53,20)
for x in [34,40]:
    pipe('RooftopPipe',(x,50,12),(x,50,28))
    pipe('DownPipe',(x,50,28),(x,8,28))
for z in [-22,-6,10,25]:
    part('SideArmor',(2,19,12),(-79,16,z),'edge')
    trim('SideMarker',(.5,3,1),(-80.2,13,z),'warm')
for x in [-68,-50,40]:
    part('RearServiceDoor',(10,12,.8),(x,11,33),'edge')
    trim('RearDoorLight',(7,.7,.8),(x,18,33.6),'warm')
sign('SeaNumber','01',(9,10,.7),(45,19,-34),'cyan')
# Snow only on attached ledges; no terrain or coastal path is included.
for x in [-67,-30,9,45]:snow('FoundationSnow',25,3,x,4.3,-44)

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

spec=dict(SchemaVersion=1,AssetId='MC-01',AssetName='Harbor Gate Terminal',AssetClass='Building',City='MegaCity',
    EnergyType='Electric',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
    PerformanceBudget=dict(MaxVisibleParts=450,MaxGameplayHitboxes=1,PermanentLights=0,PermanentParticleEmitters=0,PerPartScripts=0))
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
    gui,g=item(parent,'SurfaceGui','Sign');prop(g,'token','Face',5);prop(g,'float','PixelsPerStud',30);prop(g,'token','SizingMode',1)
    prop(g,'bool','AlwaysOnTop','false');prop(g,'float','LightInfluence',0);prop(g,'float','MaxDistance',600)
    lab,l=item(gui,'TextLabel','Text');prop(l,'string','Text',p['text']);prop(l,'float','BackgroundTransparency',1)
    size=ET.SubElement(l,'UDim2',name='Size')
    for tag,n in [('XS',1),('XO',0),('YS',1),('YO',0)]:ET.SubElement(size,tag).text=str(n)
    prop(l,'bool','TextScaled','true');prop(l,'token','Font',12) # Enum.Font.SciFi
    col=ET.SubElement(l,'Color3',name='TextColor3')
    for k,v in zip('RGB',p['textColor']):ET.SubElement(col,k).text=str(v/255)

def export():
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityHarborGateTerminal')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-01','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':450}))
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
    e,p=item(model,'Script','HarborRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/01-harbor-gate-terminal.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityHarborGateSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityHarborGateGeometry.lua').write_text('-- Generated from tools/build_harbor_gate.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/harbor-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
