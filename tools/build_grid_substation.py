"""Deterministic Roblox Parts-only MC-13 model and matching Rojo module/export.
Run from repository root: python tools/build_grid_substation.py
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

# MC-13: three stepped transformer banks and two rear reactor coils.
PALETTE['insulator']=(160,177,191)
part('Foundation',(244,4,157),(0,2,0),'concrete','Concrete')
part('HeavyPlinth',(227,15,139),(0,11.5,0),'concrete','Concrete')
part('Deck',(233,3,145),(0,20.5,0),'edge')
snow('DeckSnow',233,145,0,22.3,0)
# Sloped armour panels along front and rear, spaced to avoid coincident faces.
for z in [-71,71]:
    for x in [-102,-76,-50,-24,2,28,54,80,106]:
        part('PlinthArmour',(23,17,3),(x,11,z),'edge',rotation=(20 if z<0 else -20,0,0))
        if x in [-76,2,80]:
            part('PlinthVent',(16,10,1),(x,11,z+(-4 if z<0 else 4)),'dark')
            for y in [8,10,12,14]:part('VentLouvre',(14,.5,.6),(x,y,z+(-4.8 if z<0 else 4.8)),'edge')
for x in [-116,116]:part('SideArmour',(3,16,132),(x,11,0),'edge')
for x in [-99,-47,5,57,109]:trim('DeckLamp',(5,1,1),(x,18,-73.5),'warm')
# Transformer plinths rise toward the control building.
for n,(x,step) in enumerate([(-75,0),(-20,5),(35,10)],1):
    floor=23+step
    part('TransformerPedestal',(48,4+step,51),(x,23+step/2,-31),'concrete','Concrete')
    part('TransformerFeet',(43,4,39),(x,floor+4,-31),'edge')
    part('TransformerTank',(42,28,35),(x,floor+20,-31),'metal')
    for dx in [-20,20]:part('TankCorner',(3,29,38),(x+dx,floor+20,-31),'edge')
    for dx in range(-16,17,4):
        part('RadiatorFin',(1.5,25,5),(x+dx,floor+20,-50),'insulator')
        part('RearRadiatorFin',(1.5,25,5),(x+dx,floor+20,-12),'edge')
    part('TransformerLid',(45,3,40),(x,floor+35.5,-31),'edge')
    snow('TransformerSnow',45,40,x,floor+37.3,-31)
    for dx in [-13,0,13]:
        pipe('BushingCore',(x+dx,floor+37,-31),(x+dx,floor+58,-31),1.8)
        for yy in range(40,57,3):
            pipe('CeramicDisc',(x+dx,floor+yy-.6,-31),(x+dx,floor+yy+.6,-31),3.4)
            parts[-1]['color']=list(PALETTE['insulator'])
        trim('BushingBeacon',(2.6,2,2.6),(x+dx,floor+59,-31),'warm')
    sign('TransformerId',str(n).zfill(2),(12,7,1),(x+13,floor+26,-54),'warm')
    # Individual overhead feed gantry at the same stepped height.
    for dx in [-23,23]:part('GantryPost',(3,64,4),(x+dx,floor+32,-19),'edge')
    part('GantryHeader',(49,5,6),(x,floor+65,-19),'metal')
    trim('BusbarFace',(43,1.4,1),(x,floor+65,-22.7),'cyan')
    for dx in [-13,0,13]:pipe('BushingLead',(x+dx,floor+58,-31),(x+dx,floor+63,-19),.9)
    for dx in [-20,20]:trim('GantryMarker',(1.2,3,1),(x+dx,floor+65,-23),'warm')
    pipe('TransformerConduit',(x+20,floor+12,-23),(x+28,floor+12,14),1.6)
# Rear raised service block supports both large cylindrical coils.
part('CoilPodium',(151,24,66),(-31,34,32),'concrete','Concrete')
part('CoilDeck',(155,3,70),(-31,47.5,32),'edge')
snow('CoilDeckSnow',155,70,-31,49.3,32)
for cx in [-72,8]:
    pipe('CoilFoot',(cx,49,32),(cx,54,32),24)
    pipe('CoilBody',(cx,54,32),(cx,99,32),22)
    for y in [57,66,76,86,96]:
        pipe('CoilMetalBand',(cx,y-1,32),(cx,y+1,32),23.5)
    for y in [62,82,93]:
        pipe('ElectricRing',(cx,y-.65,32),(cx,y+.65,32),23.8)
        parts[-1]['color']=list(PALETTE['cyan']);parts[-1]['material']='Neon';parts[-1]['solid']=False
    pipe('CoilTop',(cx,99,32),(cx,103,32),24)
    pipe('CoilSnow',(cx,103,32),(cx,103.6,32),23.8)
    parts[-1]['color']=list(PALETTE['snow']);parts[-1]['material']='SmoothPlastic'
    for side in [-1,1]:
        for z in [12,52]:
            part('CoilFramePost',(4,55,5),(cx+side*27,77,z),'edge')
            beam('CoilFrameShoulder',(cx+side*27,104,z),(cx+side*17,115,z),4,'edge')
        part('CoilUpperRail',(4,4,44),(cx+side*17,115,32),'edge')
        trim('CoilTopLamp',(1.5,4,1),(cx+side*17,115,9),'warm')
    for z in [12,52]:
        part('CoilBridge',(38,4,5),(cx,116,z),'metal')
        trim('CoilBridgeLight',(31,1.2,.8),(cx,116,z-3),'cyan')
    for xx in [cx-8,cx+8]:
        pipe('CoilTopBushing',(xx,104,32),(xx,111,32),2)
        for y in [105,108]:pipe('CoilTopDisc',(xx,y-.5,32),(xx,y+.5,32),3.5)
    pipe('ReturnMain',(cx+23,60,47),(cx+23,60,62),2.5)
    pipe('ReturnDrop',(cx+23,26,62),(cx+23,60,62),2.5)
# Cyan trunk between the coils and three forward transformer branches.
part('MainBusbar',(80,5,6),(-32,109,32),'metal')
trim('MainBusLight',(74,1.8,.8),(-32,109,28.5),'cyan')
for x,step in [(-75,0),(-20,5),(35,10)]:
    y=88+step
    target=-72 if x < -40 else 8
    beam('FeedBus',(x,y,-19),(target,94,9),4,'metal')
    p=beam('FeedLight',(x,y,-21.5),(target,94,6.5),1.2,'cyan');p['material']='Neon';p['solid']=False
# Four discharges with fixed terminals: transformer bushings and coil top terminals.
PALETTE['arcwhite']=(220,253,255)
arc_ends=[((x-13,82+step,-31),(x+13,82+step,-31),10)
          for x,step in [(-75,0),(-20,5),(35,10)]]
arc_ends.append(((-64,111,32),(0,111,32),20))
for bolt,(a,b,rise) in enumerate(arc_ends):
    points=[]
    for node in range(9):
        t=node/8
        points.append((a[0]+(b[0]-a[0])*t,
                       a[1]+(b[1]-a[1])*t+rise*math.sin(math.pi*t),
                       a[2]+(b[2]-a[2])*t+(1.8*(-1)**node if 0<node<8 else 0)))
    for node,(aa,bb) in enumerate(zip(points,points[1:]),1):
        for name,width,col,alpha in [('LightningHalo',1.5,'cyan',.35),('LightningCore',.55,'arcwhite',0)]:
            p=beam(name,aa,bb,width,col);p['material']='Neon';p['solid']=False;p['alpha']=alpha
            p['lightningSegment']=bolt*8+node

# Hollow control room at right; transparent upper window band.
part('ControlFloor',(52,2,114),(83,24,6),'edge')
part('ControlLower',(52,31,114),(83,40.5,6),'metal')
part('ControlUpperFloor',(54,2,116),(83,57,6),'edge')
for x in [58,108]:part('ControlSidePier',(2,17,109),(x,66.5,6),'concrete','Concrete')
for z in [-50,62]:
    for x in [67,83,99]:
        part('ControlWindow',(14,15,.6),(x,66.5,z),'glass','Glass',alpha=.45)
        part('WindowMullion',(1,17,1),(x-7.5,66.5,z),'edge')
        trim('WindowWarm',(12,.6,.7),(x,72,z+(1 if z<0 else -1)),'warm')
part('ControlRoof',(60,3,123),(83,76.5,6),'edge')
snow('ControlSnow',60,123,83,78.3,6)
for z in [-25,15,47]:vent(83,81,z,18)
sign('GridName','GRID',(32,9,1),(83,48,-52),'pink')
sign('GridNumber','13',(21,16,1),(83,35,-52),'snow')
# Side/rear service doors and cabinet row.
part('ControlRearDoor',(18,24,1),(83,38,64),'edge')
sign('RearLabel','GRID 13',(31,7,1),(83,52,64),'cyan',(0,180,0))
for x in [-92,-67,-42,-17,8,33]:
    part('SwitchCabinet',(21,19,5),(x,33,67),'edge')
    part('SwitchPanel',(16,14,.6),(x,34,70),'dark')
    trim('SwitchStatus',(7,.8,.6),(x,38,70.7),'warm')
    part('CabinetHandle',(.6,4,.7),(x+5,32,70.7),'insulator')
# Front guardrail and staircase aligned with control block.
for x in [-108,-81,-54,-27,0,27,50]:part('RailPost',(1,6,1),(x,25.5,-67),'edge')
part('FrontRail',(159,.8,1.3),(-29,29,-67),'edge')
for i in range(11):part('EntryStep',(29,2,3),(83,21-i*2,-69-i*3),'concrete','Concrete')
for side in [-1,1]:
    beam('StairRail',(83+side*16,29,-68),(83+side*16,7,-99),1.2,'edge')
    for i in [0,5,10]:part('StairPost',(1,7,1),(83+side*16,25-i*2,-69-i*3),'edge')

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

spec=dict(SchemaVersion=1,AssetId='MC-13',AssetName='Grid Substation',AssetClass='Building',City='MegaCity',
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityGridSubstation')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-13','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':1400}))
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
    e,p=item(model,'Script','GridRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    lightning=(OUT/'MegaCityGridLightning.lua').read_text()
    source=p.find("ProtectedString[@name='Source']")
    source.text += '\nlocal function lightningModule()\n'+lightning+'\nend\nlightningModule().Attach(script.Parent)\n'
    target=ROOT/'packages/mega-city/13-grid-substation.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityGridSubstationSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityGridSubstationGeometry.lua').write_text('-- Generated from tools/build_grid_substation.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/grid-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
