"""Deterministic Roblox Parts-only MC-11 model and matching Rojo module/export.
Run from repository root: python tools/build_major_power.py
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

# MC-11: twin turbine halls and central electric core in one destruction unit.
PALETTE['insulation']=(105,126,145)
part('Foundation',(278,4,156),(0,2,0),'concrete','Concrete')
# Halls have open front bays and butt-jointed rear/side walls.
for side in [-1,1]:
    x=side*88
    part('HallFloor',(86,2,105),(x,5,-8.5),'edge')
    part('HallRear',(86,50,4),(x,31,46),'metal')
    for dx in [-45,45]:part('HallSide',(4,50,97),(x+dx,31,-4.5),'concrete','Concrete')
    part('HallRoof',(99,4,119),(x,58,-8),'edge')
    snow('HallSnow',99,119,x,60.3,-8)
    part('HallFrontHeader',(86,12,6),(x,50,-57),'metal')
    sign('HallName','POWER STATION' if side==-1 else 'ENERGY DIVISION',(76,9,1),(x,50,-61),'snow')
    for dx in [-44,0,44]:
        part('HallPier',(6,45,8),(x+dx,28.5,-57),'edge')
        beam('HallButtress',(x+dx,8,-71),(x+dx,52,-60),6,'concrete')
        part('ButtressFoot',(10,8,15),(x+dx,8,-66),'concrete','Concrete')
        snow('FootSnow',10,15,x+dx,12.3,-66)
        trim('PierLamp',(1.2,6,1),(x+dx,39,-62),'warm')
    # Four horizontal turbine barrels with nested non-coplanar shells.
    for dx in [-22,22]:
        tx=x+dx
        part('TurbineBed',(32,6,45),(tx,9,-30),'concrete','Concrete')
        for z in [-45,-16]:
            part('TurbineSaddle',(28,7,5),(tx,15,-0+z),'edge')
        pipe('TurbineBody',(tx-13,25,-31),(tx+13,25,-31),11)
        for dxx in [-14,-8,8,14]:
            pipe('TurbineBand',(tx+dxx-1,25,-31),(tx+dxx+1,25,-31),11.7)
        for dxx in [-12,12]:
            pipe('TurbineGlow',(tx+dxx-.45,25,-31),(tx+dxx+.45,25,-31),11.9)
            parts[-1]['color']=list(PALETTE['warm']);parts[-1]['material']='Neon'
        pipe('TurbineAxle',(tx-18,25,-31),(tx+18,25,-31),3.5)
        for yy in [19,25,31]:
            part('TurbineFrontRib',(19,.8,1),(tx,yy,-42.2),'edge')
        trim('BayCeilingLight',(32,1,1),(tx,42,-43),'warm')
        pipe('GeneratorFeed',(tx,25,-17),(tx,25,12),2.5)
        pipe('GeneratorRiser',(tx,25,12),(tx,54,12),2.5)
        # Safety barrier is low enough to leave turbines visible.
        for dd in [-16,16]:part('BayRailPost',(1,6,1),(tx+dd,10,-64),'warm')
        part('BayRail',(33,.8,1),(tx,13,-64),'edge')
    # Side service windows with openings between wall sections avoided by placing
    # windows in raised roof clerestories, not on an opaque wall.
    part('ClerestoryBase',(73,2,47),(x,62,3),'edge')
    for z in [-19,25]:
        part('ClerestoryGlass',(68,9,.6),(x,67.5,z),'glass','Glass',alpha=.45)
        for dx in [-34,-17,0,17,34]:part('ClerestoryMullion',(1,9,1),(x+dx,67.5,z),'edge')
    for dx in [-35,35]:part('ClerestoryEnd',(2,9,44),(x+dx,67.5,3),'metal')
    part('ClerestoryCap',(76,2,50),(x,73,3),'edge')
    snow('ClerestorySnow',76,50,x,74.3,3)
    for dx in [-23,23]:
        part('RoofExhaust',(10,12,10),(x+dx,80,9),'metal')
        part('ExhaustCap',(14,2,14),(x+dx,87,9),'edge')
        snow('ExhaustSnow',14,14,x+dx,88.3,9)
        for y in [78,81,84]:part('ExhaustLouvre',(8,.8,.6),(x+dx,y,3.6),'dark')
    vent(x,63,-41,16)
    # Rear transformer bank seated behind each hall.
    part('TransformerPad',(78,3,26),(x,5.5,62),'concrete','Concrete')
    for dx in [-24,0,24]:
        xx=x+dx
        part('Transformer',(20,26,18),(xx,20,62),'metal')
        for dd in [-8,-4,0,4,8]:
            part('CoolingFin',(1.4,24,4),(xx+dd,20,73),'insulation')
        part('TransformerCap',(22,2,21),(xx,34,62),'edge')
        snow('TransformerSnow',22,21,xx,35.3,62)
        for dz in [-5,5]:
            pipe('Bushing',(xx,35,62+dz),(xx,45,62+dz),1.4)
            for yy in [37,39,41,43]:pipe('InsulatorDisc',(xx,yy-.4,62+dz),(xx,yy+.4,62+dz),2.8)
            trim('BushingTip',(2,1,2),(xx,46,62+dz),'cyan')
        pipe('TransformerLink',(xx,27,49),(xx,27,54),1.5)
    pipe('RearBusbar',(x-32,47,62),(x+32,47,62),1.2)
    sign('TransformerWarning','HIGH VOLTAGE',(57,6,1),(x,53,49),'cyan',(0,180,0))
# Central pedestal and strong corner pylons leave the luminous core unobstructed.
part('TowerBase',(64,5,83),(0,6.5,0),'concrete','Concrete')
part('TowerPedestal',(53,23,67),(0,20.5,0),'metal')
part('TowerDeck',(65,4,80),(0,34,0),'edge')
snow('TowerDeckSnow',65,80,0,36.3,0)
for x in [-25,25]:
    for z in [-27,27]:
        part('TowerPylon',(9,129,10),(x,100.5,z),'concrete','Concrete')
        part('PylonArmour',(11,31,12),(x,53,z),'edge')
        # Offset trim outside the concrete front/rear faces.
        trim('PylonWarm',(1.4,12,1),(x,52,z+(-6.8 if z<0 else 6.8)),'warm')
        trim('PylonCyan',(1,84,1),(x,111,z+(-5.8 if z<0 else 5.8)),'cyan')
        part('CrownBlock',(17,17,18),(x,170,z),'metal')
        part('CrownCap',(19,2,20),(x,179.5,z),'edge')
        snow('CrownSnow',19,20,x,180.8,z)
        trim('CrownLamp',(9,1.5,1),(x,166,z+(-9.8 if z<0 else 9.8)),'warm')
        part('LightningRod',(.7,12,.7),(x,186.5,z),'edge')
        trim('Beacon',(1.2,1.2,1.2),(x,192.5,z),'warm')
        beam('TowerFootBrace',(x*1.4,9,z*1.5),(x,51,z),6,'concrete')
# Core is a bright spine surrounded by separated cage rings; glass is optional
# side shielding with open front and rear for unambiguous energy readability.
pipe('CoreSpine',(0,38,0),(0,160,0),4)
parts[-1]['color']=list(PALETTE['cyan']);parts[-1]['material']='Neon'
for y in [40,63,87,111,135,158]:
    for i in range(24):
        a=2*math.pi*i/24;b=2*math.pi*(i+1)/24
        p=beam('CoreRing',(13*math.cos(a),y,13*math.sin(a)),(13*math.cos(b),y,13*math.sin(b)),.9,'cyan');p['material']='Neon';p['solid']=False
for x in [-17,17]:part('CoreShield',(.6,119,37),(x,99,0),'glass','Glass',alpha=.65)
# Prominent angular discharges, visible in Edit mode and animated in Play.
PALETTE['arcwhite']=(220,253,255)
for bolt in range(4):
    z=-20 if bolt<2 else 20
    side=-1 if bolt%2==0 else 1
    points=[(side*(3 if i%2==0 else 13),41+i*14.4,z) for i in range(9)]
    for node,(aa,bb) in enumerate(zip(points,points[1:]),1):
        for name,width,col,alpha in [('LightningHalo',1.5,'cyan',.35),('LightningCore',.55,'arcwhite',0)]:
            p=beam(name,aa,bb,width,col);p['material']='Neon';p['solid']=False;p['alpha']=alpha
            p['lightningSegment']=bolt*8+node
for y in [76,125]:
    for z in [-27,27]:
        part('TowerCrossbar',(43,4,5),(0,y,z),'edge')
        beam('TowerDiagonal',(-20,y+3,z),(20,y+26,z),1.6,'edge')
        beam('TowerDiagonal',(20,y+3,z),(-20,y+26,z),1.6,'edge')
part('TowerCrown',(43,13,59),(0,171,0),'metal')
part('CrownRoof',(47,2,63),(0,178.5,0),'edge')
snow('CrownRoofSnow',47,63,0,179.8,0)
sign('TowerNumber','11',(13,17,1),(-25,107,-33),'snow')
sign('TowerLabel','POWER',(19,6,1),(0,30,-44.5),'cyan')
sign('CrownMark','V',(20,14,1),(0,171,-30.5),'pink')
# Entry with a clear face, door panels and approach steps.
part('EntryPortal',(25,26,7),(0,17,-39.5),'edge')
part('EntryDoor',(17,20,1),(0,15,-44),'metal')
for x in [-10,10]:trim('EntryWarm',(1,18,.8),(x,17,-44.5),'warm')
part('DoorSplit',(.6,19,.6),(0,15,-44.8),'dark')
for i in range(4):part('EntryStep',(25,1,3),(0,4.5-i,-44-i*3),'concrete','Concrete')
# Three heavy sagging electric connections on each side of the tower.
for side in [-1,1]:
    xx=side*51
    part('CablePedestal',(12,4,15),(xx,62,-3),'edge')
    pipe('CableInsulator',(xx,64,-3),(xx,96,-3),2.2)
    for y in range(65,96,3):pipe('CableInsulatorDisc',(xx,y-.5,-3),(xx,y+.5,-3),4)
    part('HallTerminal',(10,16,16),(xx,102,-3),'metal')
    part('TowerTerminal',(10,19,17),(side*32,117,-3),'edge')
    for z in [-9,-3,3]:
        # Curve goes outward to a hall roof terminal farther from the core.
        endx=side*76
        part('OuterTerminal',(7,14,5),(endx,81.5,z),'metal')
        trim('TerminalLight',(1,3,3),(endx-side*4,85,z),'cyan')
        points=[]
        for i in range(13):
            t=i/12;points.append((side*(37+39*t),117-31*t-8*math.sin(math.pi*t),z))
        for aa,bb in zip(points,points[1:]):pipe('PowerCable',aa,bb,1.1)
    for y in [111,117,123]:trim('TowerTerminalLight',(1,1.5,10),(side*37.6,y,-3),'cyan')
# Rear access control, with the same electric identification.
part('RearServiceDoor',(22,22,1),(0,19,34.5),'edge')
sign('RearName','POWER 11',(38,7,1),(0,31,41),'cyan',(0,180,0))

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

spec=dict(SchemaVersion=1,AssetId='MC-11',AssetName='Major Power Station',AssetClass='Building',City='MegaCity',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityMajorPowerStation')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-11','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
    e,p=item(model,'Script','PowerRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    lightning=(OUT/'MegaCityPowerLightning.lua').read_text()
    source=p.find("ProtectedString[@name='Source']")
    source.text += '\nlocal function lightningModule()\n'+lightning+'\nend\nlightningModule().Attach(script.Parent)\n'
    target=ROOT/'packages/mega-city/11-major-power-station.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityMajorPowerStationSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityMajorPowerStationGeometry.lua').write_text('-- Generated from tools/build_major_power.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/power-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
