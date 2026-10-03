"""Deterministic Roblox Parts-only MC-06 model and matching Rojo module/export.
Run from repository root: python tools/build_holo_entertainment.py
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

# MC-06: native Parts, three circular projecting levels and segmented curved screen.
part('Foundation',(164,4,136),(0,2,0),'concrete','Concrete')
part('LobbyFloor',(144,2,110),(0,5,0),'edge')
for x in [-70,70]:part('LobbySide',(3,33,105),(x,22,0),'metal')
part('LobbyRear',(142,33,3),(0,22,51),'metal')
for x in [-61,-45,-29,29,45,61]:
    part('LobbyGlass',(14,27,.6),(x,21,-52),'glass','Glass',alpha=.5)
    part('LobbyFrame',(1.2,30,2),(x-8,21,-52),'edge')
    trim('LobbyWarm',(11,.6,.8),(x,33,-50),'warm')
for x in [-19,19]:part('EntrancePost',(3,32,4),(x,22,-54),'edge')
part('PodiumRoof',(150,3,117),(0,40,0),'metal')
snow('PodiumSnow',150,117,0,41.8,0)
part('EntranceHeader',(49,15,7),(0,40,-55),'edge')
sign('HoloName','HOLO',(43,12,1),(0,41,-59.2),'cyan')
sign('EntertainmentName','ENTERTAINMENT TOWER',(52,5,1),(0,30,-59.2),'pink')
part('EntryCanopy',(52,2,19),(0,24,-58),'edge')
trim('EntryMagenta',(50,.8,.7),(0,24,-68),'pink')
for x,label,col in [(-47,'ARCADE','cyan'),(47,'LIVE','pink')]:
    sign('VenueName',label,(32,8,1),(x,28,-55),col)
    part('VenueHeader',(37,11,3),(x,28,-53),'metal')
for i in range(5):part('EntryStep',(48,1,2),(0,5-i,-57-i*2),'concrete','Concrete')
# Decorative arcade cabinets with glowing displays, not playable minigames.
for x in [-53,-39,-25,25,39,53]:
    part('ArcadeCabinet',(7,12,6),(x,12,-21),'metal')
    trim('ArcadeDisplay',(5,5,.5),(x,14,-24.4),'cyan' if x<0 else 'pink')
    part('ArcadeConsole',(7,1,3),(x,10,-25),'edge')
    trim('ArcadeButton',(1,.3,1),(x+2,10.7,-25),'warm')
# Central shaft, smaller than the galleries so the glazing remains visible.
part('TowerCore',(70,167,70),(0,124,5),'metal',shape='CylinderY')
for x in [-31,31]:
    part('CoreSpine',(6,169,9),(x,125,-24),'edge')
    trim('SpineWarm',(.7,144,.7),(x,129,-29),'warm')
# Ring floors and roofs are actual cylinders, with faceted glass perimeter.
levels=[(64,78,0),(122,55,20),(190,74,0)]
for level,(y,r,zc) in enumerate(levels):
    part('RingDeck',(2*r,4,2*r),(0,y,zc),'edge',shape='CylinderY')
    part('RingRoof',(2*r+3,3,2*r+3),(0,y+23,zc),'metal',shape='CylinderY')
    part('RingRoofSnow',(2*r+3,.5,2*r+3),(0,y+24.8,zc),'snow','SmoothPlastic',shape='CylinderY',solid=False)
    n=16
    for j in range(n):
        theta=2*math.pi*j/n;half=math.pi/n
        # Chord at apothem; panes join at polygon vertices.
        rr=r*math.cos(half);w=2*r*math.sin(half)-.8
        x,z=rr*math.sin(theta),zc-rr*math.cos(theta)
        yaw=-math.degrees(theta)
        part('RingWindow',(w,16,.6),(x,y+12,z),'glass','Glass',rotation=(0,yaw,0),alpha=.48)
        # Columns at polygon vertices, no full opaque window backing.
        vx,vz=r*math.sin(theta+half),zc-r*math.cos(theta+half)
        part('RingColumn',(2.5,20,2.5),(vx,y+12,vz),'metal')
        trim('RingCyan',(w+.4,.65,.7),(x,y+22,z),'cyan',(0,yaw,0))
        trim('RingMagenta',(w+.4,.8,.7),(x,y-1.1,z),'pink',(0,yaw,0))
        # Interior light and seating stay behind the glazing.
        ri=rr-5
        trim('RingWarm',(w-3,.5,1),(ri*math.sin(theta),y+19,zc-ri*math.cos(theta)),'warm',(0,yaw,0))
        if j%2==0:
            beam('CantileverBrace',(28*math.sin(theta),y-16,zc-28*math.cos(theta)),((r-5)*math.sin(theta),y-2,zc-(r-5)*math.cos(theta)),4)
            part('GalleryBench',(9,2,4),((rr-7)*math.sin(theta),y+4,zc-(rr-7)*math.cos(theta)),'edge',rotation=(0,yaw,0))
# Curved display is an arc of seven outward-facing tangent panels.
# Each shows its slice of one continuous native-UI planet graphic.
segments=7;step=math.radians(120/segments);radius=49
for i in range(segments):
    theta=math.radians(-60)+(i+.5)*step
    w=2*radius*math.tan(step/2)
    x,z=radius*math.sin(theta),-radius*math.cos(theta)
    yaw=-math.degrees(theta)
    part('ScreenBacking',(w+.15,87,3),(x,137,z),'metal',rotation=(0,yaw,0))
    rr=radius+1.8
    panel=part('HoloDisplayPanel',(2*rr*math.tan(step/2),82,.5),(rr*math.sin(theta),137,-rr*math.cos(theta)),'dark','SmoothPlastic',rotation=(0,yaw,0),solid=False)
    panel['screenIndex']=i
    for yy,col in [(94.5,'cyan'),(179.5,'pink')]:
        trim('ScreenBorder',(w+.1,.8,.6),(rr*math.sin(theta),yy,-rr*math.cos(theta)),col,(0,yaw,0))
    if i in [0,6]:
        for yy in [102,172]:beam('DisplayMount',(x*.7,yy,z*.7),(x,yy,z),2,'edge')
# Rooftop penthouse and machinery sit on the upper ring's roof.
part('RoofPenthouse',(65,13,48),(0,221,8),'metal')
for x in [-24,-8,8,24]:
    part('PenthouseWindow',(14,9,.6),(x,221,-16.5),'glass','Glass',alpha=.45)
    trim('PenthouseWarm',(12,.6,.7),(x,218,-17),'warm')
part('PenthouseRoof',(70,2,53),(0,228.5,8),'edge')
snow('PenthouseSnow',70,53,0,229.8,8)
for x in [-45,45]:
    part('SignalMast',(8,31,10),(x,231,12),'edge')
    trim('MastMagenta',(.8,24,.7),(x,232,6.5),'pink')
    part('Antenna',(.6,15,.6),(x,254,12),'edge')
    trim('Beacon',(1.2,1.2,1.2),(x,262,12),'pink')
for x in [-20,20]:vent(x,232.5,17,12)
# Rear technical spine and service access.
part('RearServiceSpine',(17,181,12),(0,131,69),'metal')
for y in range(54,216,12):
    part('SpineLouvre',(13,4,1),(0,y,75.6),'edge')
for x in [-7,7]:trim('RearCyan',(.7,167,.7),(x,130,76),'cyan')
part('RearServiceDoor',(16,21,1),(0,16,53),'edge')
sign('RearVenueName','HOLO',(34,10,1),(0,31,53.8),'cyan',(0,180,0))
for x in [-60,60]:pipe('PodiumPipe',(x,38,44),(x,7,44),1.4)

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

spec=dict(SchemaVersion=1,AssetId='MC-06',AssetName='Holo Entertainment Tower',AssetClass='Building',City='MegaCity',
    EnergyType='Electric',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
    PerformanceBudget=dict(MaxVisibleParts=850,MaxGameplayHitboxes=1,PermanentLights=0,PermanentParticleEmitters=0,PerPartScripts=0))
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

def add_screen(parent,index):
    # One continuous 1400x800 artwork, clipped into seven 200px-wide curved panels.
    gui,g=item(parent,'SurfaceGui','PlanetDisplay')
    prop(g,'token','Face',5);prop(g,'token','SizingMode',0)
    canvas=ET.SubElement(g,'Vector2',name='CanvasSize')
    ET.SubElement(canvas,'X').text='200';ET.SubElement(canvas,'Y').text='800'
    prop(g,'float','LightInfluence',0);prop(g,'float','MaxDistance',1200)
    holder,h=item(gui,'Frame','Viewport')
    prop(h,'float','BackgroundTransparency',1);prop(h,'bool','ClipsDescendants','true')
    sz=ET.SubElement(h,'UDim2',name='Size')
    for key,val in [('XS',1),('XO',0),('YS',1),('YO',0)]:ET.SubElement(sz,key).text=str(val)
    left=index*200
    def rect(name,x,y,w,hgt,col,rotation=0,layer=1):
        # Conservative clip culling for rotated primitives.
        rad=math.hypot(w,hgt)/2
        if x+rad<left or x-rad>left+200:return
        _,pr=item(holder,'Frame',name)
        prop(pr,'int','BorderSizePixel',0);prop(pr,'float','Rotation',rotation);prop(pr,'int','ZIndex',layer)
        anchor=ET.SubElement(pr,'Vector2',name='AnchorPoint')
        ET.SubElement(anchor,'X').text='.5';ET.SubElement(anchor,'Y').text='.5'
        for field,xx,yy in [('Position',x-left,y),('Size',w,hgt)]:
            u=ET.SubElement(pr,'UDim2',name=field)
            for key,val in [('XS',0),('XO',xx),('YS',0),('YO',yy)]:ET.SubElement(u,key).text=str(val)
        c=ET.SubElement(pr,'Color3',name='BackgroundColor3')
        for key,val in zip('RGB',col):ET.SubElement(c,key).text=str(val/255)
    def line(name,a,b,width,col,layer=1):
        dx,dy=b[0]-a[0],b[1]-a[1]
        rect(name,(a[0]+b[0])/2,(a[1]+b[1])/2,math.hypot(dx,dy),width,col,math.degrees(math.atan2(dy,dx)),layer)
    def ellipse(name,cx,cy,rx,ry,tilt,width,col,layer,n=64):
        points=[];c,s=math.cos(tilt),math.sin(tilt)
        for i in range(n+1):
            a=2*math.pi*i/n;x=rx*math.cos(a);y=ry*math.sin(a)
            points.append((cx+x*c-y*s,cy+x*s+y*c))
        for a,b in zip(points,points[1:]):line(name,a,b,width,col,layer)
    # Stylized cyber-city backdrop, star field and scan grid.
    for i in range(20):
        hh=90+(i*113)%380
        rect('CityPixels',i*75,800-hh/2,40,hh,(15,35+(i%3)*14,85+(i%4)*15))
    for i in range(32):rect('Star',(i*137+41)%1400,(i*97+23)%770,3,3,(70,180,235),layer=2)
    for x in range(0,1401,100):line('ScanGrid',(x,0),(x,800),1,(19,45,70))
    for y in range(0,801,100):line('ScanGrid',(0,y),(1400,y),1,(19,45,70))
    # Filled globe is built from horizontal strips, no uploaded texture needed.
    for yy in range(-255,256,10):
        half=math.sqrt(max(0,265**2-yy**2))
        rect('PlanetFill',700,400+yy,2*half,10.2,(12,65+int((255-yy)*.15),145+int((255-yy)*.1)),layer=3)
    ellipse('PlanetRim',700,400,267,267,0,5,(40,225,255),4)
    for ratio in [.38,.72]:ellipse('Longitude',700,400,267*ratio,267,0,2,(55,190,240),4,48)
    for yy in [-135,0,135]:
        rx=math.sqrt(265**2-yy**2)
        ellipse('Latitude',700,400+yy,rx,36,0,2,(55,190,240),4,48)
    ellipse('OrbitGlow',700,400,535,119,-.35,18,(113,32,132),5,80)
    ellipse('OrbitPink',700,400,535,119,-.35,7,(251,66,218),6,80)
    ellipse('OrbitFine',700,400,566,142,-.35,2,(255,159,239),6,80)
    # Corner graphic marks echo the entertainment venue identity.
    for x in [58,1342]:
        line('Corner',(x,50),(x,145),5,(44,215,255),6)
        line('Corner',(x,50),(x+(70 if x<700 else -70),50),5,(44,215,255),6)

def export():
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityHoloEntertainmentTower')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-06','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':850}))
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
        if 'screenIndex' in p:add_screen(e,p['screenIndex'])
    runtime=(OUT/'MegaCityBuildingRuntime.lua').read_text()
    e,p=item(model,'Script','HoloRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/06-holo-entertainment-tower.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityHoloEntertainmentSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityHoloEntertainmentGeometry.lua').write_text('-- Generated from tools/build_holo_entertainment.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/holo-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
