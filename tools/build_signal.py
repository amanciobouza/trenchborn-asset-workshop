"""Issue12 Tropical Signal Tower P4: native Roblox Parts and WedgePart, deterministic exports.
python3 tools/build_signal.py [--preview]. No remote assets or Blender.
"""
from pathlib import Path
import math,json,sys,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/signal';DEST=ROOT/'dist';MOD=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
for p in (DOC,DEST,MOD):p.mkdir(parents=True,exist_ok=True)
PALETTE={'stone':(230,222,204),'metal':(67,75,77),'glass':(57,83,94),'silver':(242,233,212),'roof':(181,163,133),'teal':(36,139,149),'ground':(178,178,167)}
parts=[]
def part(g,n,size,pos,color='metal',collide=True,rz=0,rx=0,ry=0,shape='Block'):
    assert all(v>0 for v in size)
    parts.append(dict(group=g,name=n,size=size,pos=pos,color=color,collide=collide,rz=rz,rx=rx,ry=ry,shape=shape))
def beam(g,n,x1,x2,y1,y2,z1,z2,color='metal',collide=True):
    part(g,n,(x2-x1,y2-y1,z2-z1),((x1+x2)/2,(y1+y2)/2,(z1+z2)/2),color,collide)

# Thin exact trapezoid surfaces made from right triangular Roblox WedgeParts.
# The two wedges of a triangle share an edge, never overlapping a visible face.
import numpy as np
def triangle(g,n,aa,bb,cc,color='stone',thick=.35):
    vs=[np.array(v,dtype=float) for v in (aa,bb,cc)]
    lengths=[np.linalg.norm(vs[(i+1)%3]-vs[(i+2)%3]) for i in range(3)]
    i=int(np.argmax(lengths));a,b,c=vs[i],vs[(i+1)%3],vs[(i+2)%3]
    direction=(c-b)/np.linalg.norm(c-b);d=b+direction*np.dot(a-b,direction)
    h=np.linalg.norm(a-d);up=(a-d)/h
    norm=np.cross(b-a,c-a);norm/=np.linalg.norm(norm)
    center=(a+b+c)/3
    if np.dot(norm,np.array([center[0],0,center[2]]))<0:norm=-norm
    for tag,edge in [('L',b),('R',c)]:
        length=np.linalg.norm(d-edge)
        if length<1e-7:continue
        zaxis=(d-edge)/length;xaxis=np.cross(up,zaxis)
        rot=np.stack([xaxis,up,zaxis],axis=1)
        rx=math.asin(max(-1,min(1,rot[2,1])))
        rz=math.atan2(-rot[0,1],rot[1,1]);ry=math.atan2(-rot[2,0],rot[2,2])
        pos=(edge+d)/2+up*h/2-norm*thick/2
        part(g,n+tag,(thick,h,length),tuple(pos),color,True,rz=rz,rx=rx,ry=ry,shape='Wedge')
def frustum(g,n,r0,r1,y0,y1,sides=16,color='stone'):
    for i in range(sides):
        a=2*math.pi*i/sides;b=2*math.pi*(i+1)/sides
        p=(r0*math.cos(a),y0,r0*math.sin(a));q=(r0*math.cos(b),y0,r0*math.sin(b))
        r=(r1*math.cos(b),y1,r1*math.sin(b));s=(r1*math.cos(a),y1,r1*math.sin(a))
        triangle(g,n+f'{i}a',p,q,r,color);triangle(g,n+f'{i}b',p,r,s,color)
def disc(g,n,r,y0,y1,color='stone'):
    part(g,n,(y1-y0,r*2,r*2),(0,(y0+y1)/2,0),color,rz=math.pi/2,shape='Cylinder')
def ring(g,n,r,y,h,depth,color='metal',sides=32):
    # Inscribed rectangular tangents: outer corners stay within the given diameter.
    theta=math.pi/sides;rad=(r-depth/2)*math.cos(theta)
    width=2*(r-depth)*math.sin(theta)
    for i in range(sides):
        a=2*math.pi*i/sides
        part(g,n+str(i),(width,h,depth),(rad*math.cos(a),y,rad*math.sin(a)),color,ry=-a-math.pi/2)
beam('Site','Plot',-56,56,-.5,0,-56,56,'ground')
# Round two-storey base, within80x80x32. Cylindrical floor edges have no stacked coplanar surfaces.
for name,y0,y1 in [('Floor',0,1),('GalleryFloor',16,17),('Roof',30,32)]:disc('Podium',name,40,y0,y1,'silver')
disc('Podium','Core',12,1,30,'stone')
for floor,y0,y1 in [(0,1,16),(1,17,30)]:
    for i in range(24):
        a=-math.pi/2+i*2*math.pi/24
        rad=39;w=2*rad*math.tan(math.pi/24)-1.2
        # A front opening through three bays; no glass crossing the approach.
        if not (floor==0 and i in (0,1,23)):
            part('Podium',f'Glass{floor}_{i}',(w,y1-y0-.8,.35),(rad*math.cos(a),(y0+y1)/2,rad*math.sin(a)),'glass',ry=-a-math.pi/2)
        b=a+math.pi/24
        part('Podium',f'Pier{floor}_{i}',(1,y1-y0,1.2),(39*math.cos(b),(y0+y1)/2,39*math.sin(b)),'stone',ry=-b-math.pi/2)
ring('Podium','TopBand',39.8,29.65,.6,.65,'metal')
beam('Entrance','Canopy',-16,16,14,16,-49,-37,'silver')
for i,x in enumerate([-14,14]):beam('Entrance',f'Column{i}',x-1,x+1,0,14,-45,-43,'metal')
# User revision2026-09-29: broad flared foot and a stronger upper shaft.
# Exact shared endpoints keep the eight sections connected.
shaft_radii=[24,19,16.5,15,14,13,12,11.5,11]
for j in range(8):
    y0=32+38*j;y1=y0+38;r0,r1=shaft_radii[j:j+2]
    frustum('Shaft'+str(j+1),'Facet',r0,r1,y0,y1)
    length=math.hypot(38,r0-r1)
    part('ShaftDetail',f'FrontStrip{j}',(3.5,length,.8),(0,(y0+y1)/2,-(r0+r1)/2-.1),'metal',rx=math.atan2(r0-r1,38))
# Solid inner core remains fully inside every tapered section.
disc('ShaftCore','Core',8.3,32,336,'stone')
# The under-shell starts at the widened shaft tip without a neck or gap.
frustum('Cabin','UnderShell',11,35.7,336,343,32,'silver')
disc('Cabin','Floor',36,343,344,'silver')
ring('Cabin','LightRing',35.8,342.35,.7,.7,'teal')
# Panorama level and its top slab. One glass layer, not two enclosed storeys.
for i in range(32):
    a=2*math.pi*i/32
    r=35.2;w=2*r*math.tan(math.pi/32)-.65
    part('Cabin',f'Glass{i}',(w,14.8,.3),(r*math.cos(a),351.5,r*math.sin(a)),'glass',ry=-a-math.pi/2)
    b=a+math.pi/32
    part('Cabin',f'Mullion{i}',(.55,15,.65),(r*math.cos(b),351.5,r*math.sin(b)),'metal',ry=-b-math.pi/2)
disc('Cabin','Roof',36,359,360,'silver')
# Open platform: 2-Stud floor finish and a6-Stud rail volume, no second roof.
disc('Platform','Floor',36,360,362,'silver')
for i in range(32):
    a=2*math.pi*i/32
    part('Platform',f'Post{i}',(.5,5.8,.5),(35.1*math.cos(a),364.9,35.1*math.sin(a)),'metal')
for k,y in enumerate([363.1,365.4,367.7]):ring('Platform','Rail'+str(k)+'_',35.9,y,.6,.45,'metal')
# Central signal equipment begins at the platform and stays within400 total.
disc('Signal','Pedestal',5.5,362,374,'stone')
disc('Signal','Housing',3.8,374,382,'silver')
disc('Signal','Mast',1.2,382,398,'metal')
disc('Signal','Tip',1.3,398,400,'teal')
for i in range(4):
    a=i*math.pi/2
    part('Signal',f'Fin{i}',(1,16,1),(4.8*math.cos(a),370,4.8*math.sin(a)),'metal')
# Paved approach and planters leave the 26-Stud main approach clear.
beam('Site','Approach',-16,16,.01,.1,-56,-39,'roof')
for i,(x,z,w,d) in enumerate([(-33,-42,16,10),(33,-42,16,10),(-47,-15,10,16),(47,-15,10,16)]):
    beam('Site',f'PlanterBase{i}',x-w/2,x+w/2,0,.8,z-d/2,z+d/2,'stone')
    for tag,xx in [('L',x-w/2),('R',x+w/2-1)]:beam('Site',f'Planter{i}{tag}',xx,xx+1,.8,2.5,z-d/2,z+d/2,'silver')
    for tag,zz in [('F',z-d/2),('B',z+d/2-1)]:beam('Site',f'Planter{i}{tag}',x-w/2+1,x+w/2-1,.8,2.5,zz,zz+1,'silver')
def rotation(p):
    a,b,c=p['rz'],p['rx'],p['ry'];ca,sa,cb,sb,cc,sc=math.cos(a),math.sin(a),math.cos(b),math.sin(b),math.cos(c),math.sin(c)
    # Rz * Rx * Ry
    return ((ca*cc-sa*sb*sc,-sa*cb,ca*sc+sa*sb*cc),(sa*cc+ca*sb*sc,ca*cb,sa*sc-ca*sb*cc),(-cb*sc,sb,cb*cc))

def bounds(p):
    w,h,d=p['size'];x,y,z=p['pos']
    if p['shape']=='Wedge':
        v=np.array([[-w/2,-h/2,-d/2],[w/2,-h/2,-d/2],[w/2,-h/2,d/2],[-w/2,-h/2,d/2],[-w/2,h/2,d/2],[w/2,h/2,d/2]])
    else:v=np.array([[a*w/2,b*h/2,c*d/2] for a in [-1,1] for b in [-1,1] for c in [-1,1]])
    v=v@np.array(rotation(p)).T+np.array([x,y,z])
    return [(float(v[:,i].min()),float(v[:,i].max())) for i in range(3)]
assert len({(p['group'],p['name']) for p in parts})==len(parts)
for p in parts:
    b=bounds(p)
    assert b[0][0]>=-56-1e-6 and b[0][1]<=56+1e-6 and b[2][0]>=-56-1e-6 and b[2][1]<=56+1e-6 and b[1][1]<=400+1e-6,p
assert abs(max(bounds(p)[1][1] for p in parts)-400)<1e-6
assert len({p['group'] for p in parts if p['group'].startswith('Shaft') and p['group'][5:].isdigit()})==8
for g,y0,y1 in [('Podium',0,32),('Cabin',336,360),('Platform',360,368),('Signal',362,400)]:
    selected=[p for p in parts if p['group']==g]
    assert min(bounds(p)[1][0] for p in selected)>=y0-.5 and max(bounds(p)[1][1] for p in selected)<=y1+1e-6,g
rows=['-- Generated by tools/build_signal.py; Phase4 GateB pending.','local Builder = {}','local Parts = {']
for p in parts:rows.append(' {'+', '.join(json.dumps(v) for v in [p['group'],p['name'],*p['size'],*p['pos'],*PALETTE[p['color']],p['collide'],p['rz'],p['rx'],p['ry'],p['shape']])+'},')
rows+=['}', '''function Builder.Build(parent,options)
 options=options or {}
 local model=Instance.new("Model");model.Name="LargeCity_TropicalSignalTower_P4"
 model:SetAttribute("LayoutId","LC-41");model:SetAttribute("Phase",4)
 model:SetAttribute("QualityGateA","Approved");model:SetAttribute("QualityGateB","Pending")
 model:SetAttribute("BuildRevision","TropicalSignalTower-P4-v2")
 local pivot=Instance.new("Part");pivot.Name="GroundPivot";pivot.Size=Vector3.new(.1,.1,.1)
 pivot.Anchored=true;pivot.Transparency=1;pivot.CanCollide=false;pivot.CanQuery=false;pivot.CanTouch=false
 pivot.Parent=model;model.PrimaryPart=pivot
 local groups={}
 for _,d in ipairs(Parts) do
  if not groups[d[1]] then local g=Instance.new("Model");g.Name=d[1];g.Parent=model;groups[d[1]]=g end
  local p=Instance.new(d[16]=="Wedge" and "WedgePart" or "Part");p.Name=d[2];p.Size=Vector3.new(d[3],d[4],d[5])
  p.CFrame=CFrame.new(d[6],d[7],d[8])*CFrame.Angles(0,0,d[13])*CFrame.Angles(d[14],0,0)*CFrame.Angles(0,d[15],0)
  if d[16]=="Cylinder" then p.Shape=Enum.PartType.Cylinder end
  p.Color=Color3.fromRGB(d[9],d[10],d[11]);p.Anchored=true;p.CanCollide=d[12]
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=groups[d[1]]
 end
 model.Parent=parent;model:PivotTo(options.GroundCFrame or CFrame.new());return model
end
return Builder
''']
(MOD/'LargeCityTropicalSignalTowerGoldenMaster.lua').write_text('\n'.join(rows))
root=E.Element('roblox',version='4');counter=0
def val(pr,t,n,v):E.SubElement(pr,t,name=n).text=str(v).lower() if isinstance(v,bool) else str(v)
def item(parent,cls,name,ref=None):
    global counter
    counter+=1;it=E.SubElement(parent,'Item',{'class':cls,'referent':ref or f'RBX{counter}'})
    pr=E.SubElement(it,'Properties');val(pr,'string','Name',name);return it,pr
def vec(pr,n,v):
    c=E.SubElement(pr,'Vector3',name=n)
    for a,b in zip('XYZ',v):E.SubElement(c,a).text=str(b)
model,mp=item(root,'Model','LargeCity_TropicalSignalTower_P4');val(mp,'Ref','PrimaryPart','RBXPivot');groups={}
pivot=dict(group='',name='GroundPivot',size=(.1,.1,.1),pos=(0,0,0),color='ground',collide=False,rx=0,ry=0,rz=0,shape='Block')
for p in [pivot]+parts:
    if p['group'] and p['group'] not in groups:groups[p['group']]=item(model,'Model',p['group'])[0]
    cls='WedgePart' if p['shape']=='Wedge' else 'Part'
    it,pr=item(groups.get(p['group'],model),cls,p['name'],'RBXPivot' if p is pivot else None)
    vec(pr,'size',p['size']);cf=E.SubElement(pr,'CoordinateFrame',name='CFrame')
    for a,b in zip('XYZ',p['pos']):E.SubElement(cf,a).text=str(b)
    rot=rotation(p)
    for i in range(3):
        for j in range(3):E.SubElement(cf,f'R{i}{j}').text=str(rot[i][j])
    col=PALETTE[p['color']];val(pr,'Color3uint8','Color3uint8',(255<<24)|(col[0]<<16)|(col[1]<<8)|col[2])
    for n,v in [('Anchored',True),('CanCollide',p['collide']),('CanQuery',p is not pivot),('CanTouch',p is not pivot)]:val(pr,'bool',n,v)
    for n,v in [('Material',272),('TopSurface',0),('BottomSurface',0)]:val(pr,'token',n,v)
    if cls=='Part':val(pr,'token','shape',2 if p['shape']=='Cylinder' else 1)
    if p is pivot:val(pr,'float','Transparency',1)
meta,_=item(model,'Folder','ReviewStatus')
for n,v in [('Phase','4'),('GateB','Pending'),('LayoutId','LC-41'),('Revision','TropicalSignalTower-P4-v2')]:
    _,pr=item(meta,'StringValue',n);val(pr,'string','Value',v)
path=DEST/'LargeCityTropicalSignalTower_P4.rbxmx';E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
t=E.parse(path);assert len(t.findall('.//Item[@class="Part"]'))+len(t.findall('.//Item[@class="WedgePart"]'))==len(parts)+1
assert not t.findall('.//Item[@class="Script"]')
report=dict(revision='TropicalSignalTower-P4-v2',parts=len(parts)+1,podium=[80,80,32],shaft_height=304,shaft_diameter=[48,22],shaft_profile_diameters=[2*r for r in shaft_radii],cabin=[72,24],platform=[72,8],signal_budget=32,max_height=400,height_marks=[32,336,360,368,400],plot=[112,112],office_height_comparison=328,gate_b='Pending',studio_test='Pending',checks=['plot bounds','height400','eight tapered shaft sections','height budgets','XML part count'])
(DOC/'geometry-checks.json').write_text(json.dumps(report,indent=2)+'\n')
if '--preview' in sys.argv:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont
    board=Image.new('RGB',(1800,1080),'#f4f3ed'); draw=ImageDraw.Draw(board)
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
    draw.text((900,30),'TROPICAL SIGNAL TOWER | Phase 4',font=ImageFont.truetype(bold,28),fill='#183b42',anchor='mt')
    views=[('Front / erhöht',18,-70),('Front',0,-90),('Rückseite',10,90),('Linke Seite',8,180),('Kanzel / Plattform',20,-60),('Sockel / Eingang',22,-65)]
    for k,(title,el,az) in enumerate(views):
        elev,azim=math.radians(el),math.radians(az)
        forward=np.array([math.cos(azim)*math.cos(elev),math.sin(azim)*math.cos(elev),math.sin(elev)])
        right=np.array([-math.sin(azim),math.cos(azim),0])
        up=np.cross(forward,right)
        verts=[]; cols=[]
        selected=parts if k<4 else [p for p in parts if p['group'] in (('Cabin','Platform','Signal') if k==4 else ('Podium','Entrance','Site'))]
        for p in selected:
            x,y,z=p['pos'];w,h,d=p['size']
            if p['shape']=='Cylinder':
                # Roblox cylinders run along local X; sixteen-sided review mesh.
                ring=[(math.cos(j*math.pi/8)*h/2,math.sin(j*math.pi/8)*d/2) for j in range(16)]
                local=np.array([[xx,yy,zz] for xx in [-w/2,w/2] for yy,zz in ring]+[[-w/2,0,0],[w/2,0,0]])
                faces=[];shades=[]
                for j in range(16):
                    nxt=(j+1)%16
                    faces.extend([[j,nxt,nxt+16,j+16],[32,j,nxt,nxt],[33,j+16,nxt+16,nxt+16]])
                    shades.extend([.72+.2*math.cos(j*math.pi/8),.7,.9])
            elif p['shape']=='Wedge':
                local=np.array([[-w/2,-h/2,-d/2],[w/2,-h/2,-d/2],[w/2,-h/2,d/2],[-w/2,-h/2,d/2],[-w/2,h/2,d/2],[w/2,h/2,d/2]])
                faces=[[0,1,2,3],[0,1,5,4],[3,2,5,4],[0,3,4,4],[1,2,5,5]]
                shades=[.5,1,.7,.64,.68]
            else:
                local=np.array([[sx*w/2,sy*h/2,sz*d/2] for sx,sz,sy in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]])
                faces=[[0,1,2,3],[4,5,6,7],[0,1,5,4],[1,2,6,5],[2,3,7,6],[3,0,4,7]]
                shades=[.5,1,.8,.68,.7,.64]
            world=local@np.array(rotation(p)).T+np.array([x,y,z]);v=world[:,[0,2,1]]
            for inds,shade in zip(faces,shades):
                verts.append(v[inds]);cols.append(np.array(PALETTE[p['color']])*shade)
        verts=np.array(verts)
        projected=np.stack([verts@right,verts@up,verts@forward],axis=-1)
        low=projected[:,:,:2].min(axis=(0,1));high=projected[:,:,:2].max(axis=(0,1))
        sc=min(550/(high[0]-low[0]),350/(high[1]-low[1]))
        projected[:,:,0]=(projected[:,:,0]-(high[0]+low[0])/2)*sc+290
        projected[:,:,1]=195-(projected[:,:,1]-(high[1]+low[1])/2)*sc
        pixels=np.full((390,580,3),250,dtype=np.uint8); depth=np.full((390,580),-np.inf)
        for quad,color in zip(projected,cols):
            for inds in [(0,1,2),(0,2,3)]:
                t=quad[list(inds)]
                xa=max(0,int(np.floor(t[:,0].min())));xb=min(579,int(np.ceil(t[:,0].max())))
                ya=max(0,int(np.floor(t[:,1].min())));yb=min(389,int(np.ceil(t[:,1].max())))
                if xa>xb or ya>yb:continue
                xx,yy=np.meshgrid(np.arange(xa,xb+1)+.5,np.arange(ya,yb+1)+.5)
                den=(t[1,1]-t[2,1])*(t[0,0]-t[2,0])+(t[2,0]-t[1,0])*(t[0,1]-t[2,1])
                if abs(den)<1e-9:continue
                a=((t[1,1]-t[2,1])*(xx-t[2,0])+(t[2,0]-t[1,0])*(yy-t[2,1]))/den
                b=((t[2,1]-t[0,1])*(xx-t[2,0])+(t[0,0]-t[2,0])*(yy-t[2,1]))/den
                cc=1-a-b;zz=a*t[0,2]+b*t[1,2]+cc*t[2,2]
                dep=depth[ya:yb+1,xa:xb+1]; mask=(a>=-1e-6)&(b>=-1e-6)&(cc>=-1e-6)&(zz>dep)
                dep[mask]=zz[mask];pixels[ya:yb+1,xa:xb+1][mask]=color.astype(np.uint8)
        x0=10+(k%3)*600;y0=115+(k//3)*440
        board.paste(Image.fromarray(pixels),(x0,y0))
        draw.text((x0+290,y0-30),title,font=ImageFont.truetype(bold,19),fill='#183b42',anchor='mt')
    draw.text((900,1010),'400 Studs / Kanzel ab336 / offene Plattform / Gate B offen',font=ImageFont.truetype(font,20),fill='#43585d',anchor='mt')
    draw.text((900,1043),'Technische Vorschau ausserhalb Studio. Symbole, Schrift, Materialtexturen und Lichtwirkung erst in Studio sichtbar.',font=ImageFont.truetype(font,16),fill='#43585d',anchor='mt')
    board.save(DOC/'geometry-review.png')
print(json.dumps(report))
