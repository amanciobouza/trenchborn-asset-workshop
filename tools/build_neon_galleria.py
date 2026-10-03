"""Deterministic Roblox Parts-only MC-04 model and matching Rojo module/export.
Run from repository root: python tools/build_neon_galleria.py
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

# MC-04: front -Z; central atrium remains hollow through all three storeys.
part('Foundation',(236,4,122),(0,2,0),'concrete','Concrete')
part('GroundFloor',(218,2,106),(0,5,0),'edge')
for y,h in [(22,32),(56,16),(80,12)]:part('RearWallBand',(218,h,3),(0,y,52),'metal')
for x in [-104.5+i*19 for i in range(12)]:part('RearPier',(5,48,3),(x,62,52),'metal')
# Offset wings with open retail fronts and roof terraces.
for side in [-1,1]:
    x=side*70
    for level in range(3):
        y=6+level*25
        front=(-49 if side<0 else -54) + (0 if level==0 else (5 if level==1 else 10))
        w=82 if level!=1 else 76
        d=52-front
        part('WingFloor',(w,2,d),(x,y,(front+52)/2),'edge')
        part('WingOuterWall',(2,23,d),(x+side*w/2,y+12.5,(front+52)/2),'metal')
        part('WingFrontSill',(w,2,2),(x,y+2,front),'edge')
        part('WingHeader',(w,3,2),(x,y+24,front),'metal')
        for dx in [-30,-10,10,30]:
            part('ShopGlass',(18,19,.6),(x+dx,y+13,front),'glass','Glass',alpha=.45)
            part('ShopMullion',(1,22,1.2),(x+dx-10,y+12,front),'edge')
            trim('ShopWarm',(14,.6,1),(x+dx,y+22,front+2),'warm')
            part('DisplayPlinth',(10,2,5),(x+dx,y+2.5,front+8),'edge')
            part('DisplayObject',(3,5,3),(x+dx,y+6,front+8),'cyan' if level==1 else 'warm',solid=False)
        # Wide attached canopy/terrace; stripe and snow sit on different faces.
        cy=y+25
        part('TerraceRim',(w+5,3,10),(x,cy,front-3),'edge')
        snow('TerraceSnow',w+5,9,x,cy+1.8,front-3)
        trim('TerraceNeon',(w+4,.8,.7),(x,cy,front-8.4),'pink' if level!=1 else 'cyan')
        for dx in [-w/2+2,w/2-2]:part('WingColumn',(3,24,4),(x+dx,y+12,front),'metal')
    # Full flat roof and mechanical plant seated on top.
    part('WingRoof',(87,3,98),(x,83,3),'metal')
    snow('WingRoofSnow',87,98,x,84.8,3)
    vent(x-18,87.5,20,14)
    vent(x+18,87.5,32,14)
    for z in [6,40]:pipe('RoofPipe',(x-32,87,z),(x+32,87,z),1.4)
# Central glazed atrium, no opaque backing mass.
part('AtriumFloor',(54,2,104),(0,6,0),'edge')
part('AtriumRoof',(57,3,106),(0,92,1),'metal')
snow('AtriumRoofSnow',57,106,0,93.8,1)
for x in [-27,27]:
    part('AtriumCorner',(3,85,3),(x,49,-50),'edge')
    trim('AtriumVertical',(.7,80,.6),(x,49,-51.8),'cyan')
for y,h in [(34,23),(58.5,24),(81,19)]:
    for x in [-20,-10,0,10,20]:
        part('AtriumGlass',(9,h,.6),(x,y,-50),'glass','Glass',alpha=.55)
    part('AtriumTransom',(51,1,1.2),(0,y+h/2+.5,-50),'edge')
for x in [-25,-15,-5,5,15,25]:part('AtriumMullion',(.7,70,1),(x,57,-50),'edge')
# Ground-level entrance: open centre and glass sidelights.
for x in [-20,20]:part('EntranceGlass',(10,15,.6),(x,14,-50),'glass','Glass',alpha=.5)
for x in [-14,14]:part('EntranceFrame',(1.5,17,2),(x,14,-50),'edge')
part('EntranceCanopy',(61,3,14),(0,23,-53),'edge')
trim('CanopyCyan',(59,.7,.6),(0,23,-60.4))
snow('CanopySnow',61,14,0,24.8,-53)
sign('GalleriaName','NEON GALLERIA',(56,7,1),(0,28,-57),'pink')
# Atrium galleries flank the stairwell and connect to each retail floor.
for y in [31,56,81]:
    for x in [-22,22]:
        part('GalleryWalkway',(9,2,93),(x,y,0),'edge')
        for z,d in [(-20,34),(24,18)]:part('GalleryGlassRail',(.5,4,d),(x+ (4 if x<0 else -4),y+3,z),'glass','Glass',alpha=.5)
    part('RearGallery',(35,2,15),(0,y,37),'edge')
    trim('GalleryGlow',(34,.5,1),(0,y+1.3,29),'warm')
# Zig-zag staircase visible through the main facade; static architectural stairs.
for level in range(3):
    start=7+25*level
    direction=1 if level%2==0 else -1
    for i in range(20):
        x=direction*(-16.625+i*1.75)
        part('AtriumStair',(1.75,1.25,12),(x,start+i*1.25,6),'edge')
    for z in [-.5,12.5]:
        beam('StairStringer',(-direction*17.5,start-1,z),(direction*17.5,start+24,z),1.5)
        beam('StairHandrail',(-direction*17.5,start+3,z),(direction*17.5,start+28,z),.6)
        for i in [0,5,10,15,19]:
            part('StairBaluster',(.5,3,.5),(direction*(-16.625+i*1.75),start+i*1.25+1.6,z),'edge')
for y in [20,45,70]:
    for x in [-21,21]:trim('AtriumLight',(2,.8,24),(x,y+2,20),'warm')
# Broad entry steps reach the six-stud floor. No external plaza included.
for i in range(6):part('EntryStep',(54,1,2),(0,6-i,-55-i*2),'concrete','Concrete')
for x in [-29,29]:
    beam('EntryRail',(x,10,-52),(x,4,-66),.7)
    part('EntryBollard',(3,4,3),(x,3,-64),'edge')
    trim('EntryLamp',(2,1,2),(x,5.2,-64),'warm')
# Large advertisements on solid facade frames, with native geometry emblems.
def billboard(name,label,x,y,z,w,h,color):
    part(name+'Backing',(w+3,h+3,2),(x,y,z),'metal')
    sign(name,label,(w,h,.6),(x,y,z-1.5),color)
    for sy in [-1,1]:trim(name+'Border',(w+2,.6,.5),(x,y+sy*(h/2+1),z-1.5),color)
    for sx in [-1,1]:trim(name+'Border',(.6,h+2,.5),(x+sx*(w/2+1),y,z-1.5),color)
billboard('WestCampaign','A BRIGHTER\nTOMORROW',-70,65,-51,68,25,'pink')
billboard('EastCampaign','MORE PEOPLE\nBRIGHTER DAYS',70,61,-57,67,28,'pink')
billboard('WestLowerCampaign','HIGHER  /  FURTHER',-70,38,-56,66,12,'cyan')
# Structural mounts join the offset billboards to their wing facades.
for x,y,front,back in [(-70,65,-50,-39),(70,61,-56,-44),(-70,38,-55,-44)]:
    for dx in [-27,27]:
        part('BillboardMount',(3,4,back-front),(x+dx,y,(front+back)/2),'edge')
# Ground storefront banners use the same maximum-size SciFi standard.
for x,label,color in [(-99,'FOOD','pink'),(-66,'TECH','cyan'),(-35,'STYLE','pink'),(38,'PLAY','cyan'),(70,'CAFE','pink'),(102,'ART','cyan')]:
    sign('ShopBanner',label,(12,6,.7),(x,19,-57 if x<0 else -62),color)
# Tall attached pylon forms one destruction unit with the galleria.
part('PylonFoot',(18,8,21),(116,8,-25),'concrete','Concrete')
part('PylonMast',(14,103,14),(116,59.5,-25),'metal')
part('PylonCap',(19,3,19),(116,112,-25),'edge')
snow('PylonSnow',19,19,116,113.8,-25)
sign('PylonMessage','N\nE\nO\nN',(11,42,1),(116,68,-33),'pink')
sign('PylonBaseName','GALLERIA',(13,6,1),(116,37,-33),'cyan')
# Diamond logo made of four beams on the front and rear of pylon.
for z in [-33.8,-16.2]:
    for a,b in [((116,106,z),(121,98,z)),((121,98,z),(116,90,z)),((116,90,z),(111,98,z)),((111,98,z),(116,106,z))]:
        pp=beam('DiamondLogo',a,b,.7,'cyan');pp['material']='Neon';pp['solid']=False
for x in [108.3,123.7]:trim('PylonBorder',(.7,99,.7),(x,61,-33),'pink')
sign('PylonRear','N\nE\nO\nN',(11,42,1),(116,68,-17),'cyan',(0,180,0))
# Rear service facade: roof equipment, shutter bays and lit windows.
for x in [-90,-60,60,90]:
    part('ServiceShutter',(20,16,1),(x,14,54),'edge')
    for y in range(8,22,3):part('ShutterSlat',(19,.5,.6),(x,y,54.8),'dark',solid=False)
    trim('ServiceLight',(10,.7,.6),(x,23,54.8),'warm')
for x in range(-95,96,19):
    for y in [43,69]:
        for dy in [-4.5,4.5]:part('RearFrame',(14,1,1),(x,y+dy,54),'edge')
        part('RearWindow',(12,7,.6),(x,y,54.8),'glass','Glass',alpha=.2)
        trim('RearWarm',(10,.7,.7),(x,y-2.5,55.3),'warm')
for x in [-105,105]:pipe('Downpipe',(x,85,49),(x,7,49),1.4)
sign('RearName','NEON GALLERIA',(54,10,1),(0,18,54.5),'cyan',(0,180,0))

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

spec=dict(SchemaVersion=1,AssetId='MC-04',AssetName='Neon Galleria',AssetClass='Building',City='MegaCity',
    EnergyType='Electric',MaxHealth=1000000,PipelinePhase=4,QualityGateA='Approved',QualityGateB='Pending',QualityGateC='Pending',
    PerformanceBudget=dict(MaxVisibleParts=750,MaxGameplayHitboxes=1,PermanentLights=0,PermanentParticleEmitters=0,PerPartScripts=0))
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
    root=ET.Element('roblox',version='4');model,mp=item(root,'Model','MegaCityNeonGalleria')
    rootpart,rp=item(model,'Part','Origin');originref=rootpart.attrib['referent']
    prop(rp,'bool','Anchored','true');prop(rp,'bool','CanCollide','false');prop(rp,'bool','CanQuery','false');prop(rp,'bool','CanTouch','false');prop(rp,'float','Transparency',1)
    vec(rp,'size',[1,1,1]);cf(rp,'CFrame',[0,0,0],[1,0,0,0,1,0,0,0,1]);prop(mp,'Ref','PrimaryPart',originref)
    prop(mp,'BinaryString','Tags',base64.b64encode(b'KaijuHouse').decode())
    prop(mp,'BinaryString','AttributesSerialize',attrs({'AssetId':'MC-04','EnergyType':'Electric','MaxHealth':1000000,'Health':1000000,'Destroyed':False,'QualityGateB':'Pending','QualityGateC':'Pending','VisiblePartCount':len(parts),'VisiblePartBudget':750}))
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
    e,p=item(model,'Script','GalleriaRuntime');prop(p,'ProtectedString','Source','local function runtimeModule()\n'+runtime+'\nend\nlocal Runtime = runtimeModule()\nRuntime.Attach(script.Parent, '+lua(spec)+')\n')
    target=ROOT/'packages/mega-city/04-neon-galleria.rbxmx';target.parent.mkdir(parents=True,exist_ok=True)
    ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
    return target

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'MegaCityNeonGalleriaSpecification.lua').write_text('return '+lua(spec)+'\n')
    (OUT/'MegaCityNeonGalleriaGeometry.lua').write_text('-- Generated from tools/build_neon_galleria.py; do not hand-edit.\nreturn '+lua(parts)+'\n')
    (ROOT/'tmp/mega-city').mkdir(parents=True,exist_ok=True)
    (ROOT/'tmp/mega-city/galleria-scene.json').write_text(json.dumps(parts))
    target=export()
    print(json.dumps({'parts':len(parts),'package':str(target),'bytes':target.stat().st_size}))
