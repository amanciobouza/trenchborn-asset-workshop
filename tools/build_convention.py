"""Issue11 Coast Convention Centre P4: native Roblox Parts and WedgePart, deterministic exports.
python3 tools/build_convention.py [--preview]. No remote assets or Blender.
"""
from pathlib import Path
import math,json,sys,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/convention';DEST=ROOT/'dist';MOD=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
for p in (DOC,DEST,MOD):p.mkdir(parents=True,exist_ok=True)
PALETTE={'stone':(230,222,204),'metal':(67,75,77),'glass':(57,83,94),'silver':(242,233,212),'roof':(181,163,133),'teal':(36,139,149),'ground':(178,178,167)}
PALETTE['roofmetal']=(207,216,219)
parts=[]
def part(g,n,size,pos,color='metal',collide=True,rz=0,rx=0,ry=0,shape='Block'):
    assert all(v>0 for v in size)
    parts.append(dict(group=g,name=n,size=size,pos=pos,color=color,collide=collide,rz=rz,rx=rx,ry=ry,shape=shape))
def beam(g,n,x1,x2,y1,y2,z1,z2,color='metal',collide=True):
    part(g,n,(x2-x1,y2-y1,z2-z1),((x1+x2)/2,(y1+y2)/2,(z1+z2)/2),color,collide)

def bar(g,n,x1,y1,x2,y2,z,thickness=2,depth=2):
    dx,dy=x2-x1,y2-y1
    part(g,n,(math.hypot(dx,dy),thickness,depth),((x1+x2)/2,(y1+y2)/2,z),'metal',rz=math.atan2(dy,dx))
def glasswall(g,prefix,a,b,z,y0,y1,bays,doors=()):
    for i in range(bays):
        l=a+(b-a)*i/bays;r=a+(b-a)*(i+1)/bays
        if i not in doors:beam(g,prefix+str(i)+'Glass',l+.6,r-.6,y0+.6,y1-.6,z-.2,z+.2,'glass')
        beam(g,prefix+str(i)+'Post',l,l+1.2,y0,y1,z-.6,z+.6,'metal')
    beam(g,prefix+'End',b-1.2,b,y0,y1,z-.6,z+.6,'metal')
    beam(g,prefix+'Top',a,b,y1-1,y1,z-.6,z+.6,'metal')
    if not doors:beam(g,prefix+'Bottom',a,b,y0,y0+.6,z-.6,z+.6,'metal')
# All floors have a low 0.5 Stud threshold; no high podium or floating entrances.
beam('Site','Plot',-112,112,-1,0,-112,112,'ground')
beam('Foyer','Floor',-80,80,0,.5,-64,-32,'stone')
beam('Foyer','Roof',-80,80,34,36,-64,-32,'silver')
# Four equal open portals, no glass or wall crossing the entrances.
glasswall('Foyer','FrontLower',-79,79,-63.3,.5,18,10,(3,4,5,6))
glasswall('Foyer','FrontUpper',-79,79,-63.3,18,34,10)
for side,x in [('Left',-79),('Right',79)]:
    for j in range(4):
        z=-64+j*8
        beam('Foyer',side+f'Post{j}',x-.6,x+.6,.5,34,z,z+1,'metal')
        beam('Foyer',side+f'Glass{j}',x-.2,x+.2,.5,34,z+1,z+8,'glass')
# Bright monumental facade fins outside the glazing plane, never across window centres.
for i,x in enumerate([-78.4,-62.6,63.8,78.4]):
    beam('Foyer',f'Pier{i}',x-1.2,x+1.2,0,36,-64,-61,'stone')
# Rear edge gallery 8 Studs wide, sides 8, clear double-height central front void.
beam('Gallery','RearSlab',-78,78,18,19,-40,-32,'silver')
for side,a,b in [('L',-78,-70),('R',70,78)]:
    beam('Gallery','Side'+side,a,b,18,19,-62,-40,'silver')
    x=b if side=='L' else a
    beam('Gallery','SideGuard'+side,x-.2,x+.2,19,22,-62,-40,'glass',False)
beam('Gallery','RearGuard',-70,70,19,22,-40.2,-39.8,'glass',False)
# Clear gallery stairs at the left rear; corridor below rear slab connects both halls.
for j in range(24):
    beam('Gallery',f'Stair{j}',-68+j*1.5,-66.5+j*1.5,.5,.5+(j+1)*18.5/24,-48,-40,'stone')
# A short enclosed link resolves the approved right-hall setback.
beam('Link','Floor',8,80,0,.5,-32,-16,'stone')
beam('Link','Roof',8,80,34,36,-32,-16,'silver')
beam('Link','OuterGlass',79,80,.5,34,-32,-16,'glass')
for j in range(3):beam('Link',f'OuterPost{j}',78.6,80,.5,34,-32+j*7.5,-31+j*7.5,'metal')
# V-column canopy: exactly112 x16 x4, underside28.
beam('Entrance','Canopy',-56,56,28,32,-79.4,-64,'roofmetal')
beam('Entrance','FrontFascia',-56,56,28,32,-80,-79.4,'metal')
for side,x in [('L',-48),('R',48)]:
    beam('Entrance','Foot'+side,x-2,x+2,0,1,-77,-73,'stone')
    bar('Entrance','V'+side+'L',x,1,x-6,28,-75,2,2)
    bar('Entrance','V'+side+'R',x,1,x+6,28,-75,2,2)
# Roof curves: eight broad sloped panels; solid metal, not a third glass hall.
halls=[('HallA',-88,8,-32,80,[42,41,42,45,49,53,55,56,55]),
       ('HallB',8,88,-16,80,[38,37,38,40,43,46,47.5,48,47])]
for name,xmin,xmax,zmin,zmax,heights in halls:
    beam(name,'Floor',xmin,xmax,0,.5,zmin,zmax,'stone')
    # Side walls reach roof spring; shared wall assigned only to HallA.
    if name=='HallA':
        beam(name,'OuterWall',xmin+.25,xmin+2,.5,heights[0]-1,zmin,zmax,'stone')
        beam(name,'SharedWall',xmax-1,xmax+1,.5,heights[-1]-1,zmin,zmax,'stone')
    else:beam(name,'OuterWall',xmax-2,xmax-.25,.5,heights[-1]-1,zmin,zmax,'stone')
    outer=xmin if name=='HallA' else xmax
    for k in range(6):
        zz=zmin+2+(zmax-zmin-4)*k/5
        if name=='HallA':beam(name,f'OuterPier{k}',outer,outer+2.5,.5,heights[0]-1,zz-1,zz+1,'silver')
        else:beam(name,f'OuterPier{k}',outer-2.5,outer,.5,heights[-1]-1,zz-1,zz+1,'silver')
    # Front clerestory above the open corridor. Large passage belowY18.
    if name=='HallA':
        beam(name,'FrontLeftPier',xmin,xmin+10,.5,34,zmin,zmin+2,'stone')
    else:beam(name,'FrontRightPier',xmax-8,xmax,.5,34,zmin,zmin+2,'stone')
    beam(name,'FrontHeader',xmin,xmax,18,20,zmin,zmin+2,'stone')
    # Rear elevation: three total 16x18 loading gates, two in HallA, one in HallB.
    centres=[-44,-12] if name=='HallA' else [44]
    spans=[xmin]+[v for c in centres for v in (c-8,c+8)]+[xmax]
    for j in range(0,len(spans)-1,2):beam(name,f'RearWall{j}',spans[j],spans[j+1],.5,28,78,80,'stone')
    for j,c in enumerate(centres):
        beam('Delivery',name+f'Gate{j}',c-8,c+8,.5,18.5,79.1,79.6,'metal')
        beam(name,f'GateHeader{j}',c-8,c+8,18.5,28,78,80,'stone')
        for k in range(6):beam('Delivery',name+f'GateRib{j}_{k}',c-7.8,c+7.8,2+k*2.7,2.2+k*2.7,79.7,79.85,'silver')
    xs=[xmin+1+(xmax-xmin-2)*j/8 for j in range(9)]
    for j in range(8):
        x1,x2=xs[j:j+2];y1,y2=heights[j:j+2]
        angle=math.atan2(y2-y1,x2-x1);length=math.hypot(x2-x1,y2-y1)
        nx,ny=-math.sin(angle),math.cos(angle)
        # Top edge exactly follows the specified curve; section thickness stays below it.
        part('RoofSegments',name+f'Panel{j}',(length,1,zmax-zmin-.2),((x1+x2)/2-nx*.5,(y1+y2)/2-ny*.5,(zmin+zmax)/2),'roofmetal',rz=angle)
        for k in range(5):
            z=zmin+1+(zmax-zmin-2)*k/4
            part('RoofFrames',name+f'Rib{k}_{j}',(length,2.5,2),((x1+x2)/2-nx*2.25,(y1+y2)/2-ny*2.25,z),'metal',rz=angle)
        # Front/back glazing shaped up to roof; no white stair-step openings.
        low=min(y1,y2)-1;high=max(y1,y2)-1;h=high-low
        for side,z,base in [('Front',zmin+1,20),('Rear',zmax-1,28)]:
            beam(name,side+f'Clerestory{j}',x1,x2,base,low,z-.2,z+.2,'glass')
            if h>1e-6:part(name,side+f'Slope{j}',(.4,h,x2-x1),((x1+x2)/2,low+h/2,z),'glass',ry=math.pi/2 if y2>y1 else -math.pi/2,shape='Wedge')
            beam(name,side+f'Mullion{j}',x1,x1+.6,base,y1-1,z-.5,z+.5,'metal')
        # Roof edge fascia has same upper profile, darker beneath the roof surface.
        for side,z in [('Front',zmin+.65),('Rear',zmax-.65)]:
            part('RoofFrames',name+side+f'Edge{j}',(length,2,1.3),((x1+x2)/2-nx*1.05,(y1+y2)/2-ny*1.05,z),'metal',rz=angle)
    # Distinct strong V braces behind each clerestory.
    for i in range(4):
        ix=2*i+1;x=xs[ix];top=heights[ix]-3
        bar('RoofFrames',name+f'BraceL{i}',x,20,x-6,top,zmin+2.2,1.4,1.4)
        bar('RoofFrames',name+f'BraceR{i}',x,20,x+6,top,zmin+2.2,1.4,1.4)
# Slight raised paving, not overlapping the plot top surface.
beam('Site','Forecourt',-88,88,.01,.1,-108,-80,'roof')
beam('Delivery','Yard',-56,56,.01,.1,80,104,'roof')
beam('Delivery','YardConnection',56,112,.01,.1,88,104,'roof')
beam('Delivery','SideDrive',88,112,.01,.1,-112,88,'roof')
for i,(x,z,w,d) in enumerate([(-70,-91,24,10),(70,-91,24,10),(-99,-60,12,32)]):
    beam('Site',f'PlanterBase{i}',x-w/2,x+w/2,0,.5,z-d/2,z+d/2,'stone')
    for tag,xx in [('L',x-w/2),('R',x+w/2-1)]:beam('Site',f'Planter{i}{tag}',xx,xx+1,.5,2,z-d/2,z+d/2,'silver')
    for tag,zz in [('F',z-d/2),('B',z+d/2-1)]:beam('Site',f'Planter{i}{tag}',x-w/2+1,x+w/2-1,.5,2,zz,zz+1,'silver')
def rotation(p):
    a,b,c=p['rz'],p['rx'],p['ry'];ca,sa,cb,sb,cc,sc=math.cos(a),math.sin(a),math.cos(b),math.sin(b),math.cos(c),math.sin(c)
    # Rz * Rx * Ry
    return ((ca*cc-sa*sb*sc,-sa*cb,ca*sc+sa*sb*cc),(sa*cc+ca*sb*sc,ca*cb,sa*sc-ca*sb*cc),(-cb*sc,sb,cb*cc))
def bounds(p):
    rot=rotation(p);ext=[sum(abs(rot[i][j])*p['size'][j]/2 for j in range(3)) for i in range(3)]
    return [(p['pos'][i]-ext[i],p['pos'][i]+ext[i]) for i in range(3)]

assert len({(p['group'],p['name']) for p in parts})==len(parts)
for p in parts:
    b=bounds(p)
    assert b[0][0]>=-112-1e-6 and b[0][1]<=112+1e-6 and b[2][0]>=-112-1e-6 and b[2][1]<=112+1e-6 and b[1][1]<=56+1e-6,p
for name,w,d,h in [('HallA',96,112,56),('HallB',80,96,48)]:
    floor=next(p for p in parts if p['group']==name and p['name']=='Floor')
    assert floor['size']==(w,.5,d)
    roof=[p for p in parts if p['group']=='RoofSegments' and p['name'].startswith(name)]
    assert len(roof)==8 and abs(max(bounds(p)[1][1] for p in roof)-h)<1e-6
assert halls[1][3]-halls[0][3]==16 and halls[0][4]==halls[1][4]==80
assert len([p for p in parts if p['group']=='Delivery' and 'Gate' in p['name'] and 'Rib' not in p['name']])==3
for p in parts:
    if p['group'] in ('Site','Delivery') or p['name']=='Floor':continue
    b=bounds(p)
    for x in [-23.7,-7.9,7.9,23.7]:
        assert not (b[0][0]<x+6 and b[0][1]>x-6 and b[1][0]<15 and b[1][1]>.5 and b[2][0]<-62 and b[2][1]>-80),('entry blocked',p)
rows=['-- Generated by tools/build_convention.py; Phase4 GateB pending.','local Builder = {}','local Parts = {']
for p in parts:rows.append(' {'+', '.join(json.dumps(v) for v in [p['group'],p['name'],*p['size'],*p['pos'],*PALETTE[p['color']],p['collide'],p['rz'],p['rx'],p['ry'],p['shape']])+'},')
rows+=['}', '''function Builder.Build(parent,options)
 options=options or {}
 local model=Instance.new("Model");model.Name="LargeCity_CoastConventionCentre_P4"
 model:SetAttribute("LayoutId","LC-08");model:SetAttribute("Phase",4)
 model:SetAttribute("QualityGateA","Approved");model:SetAttribute("QualityGateB","Pending")
 model:SetAttribute("BuildRevision","CoastConventionCentre-P4-v1")
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
(MOD/'LargeCityCoastConventionCentreGoldenMaster.lua').write_text('\n'.join(rows))
root=E.Element('roblox',version='4');counter=0
def val(pr,t,n,v):E.SubElement(pr,t,name=n).text=str(v).lower() if isinstance(v,bool) else str(v)
def item(parent,cls,name,ref=None):
    global counter
    counter+=1;it=E.SubElement(parent,'Item',{'class':cls,'referent':ref or f'RBX{counter}'})
    pr=E.SubElement(it,'Properties');val(pr,'string','Name',name);return it,pr
def vec(pr,n,v):
    c=E.SubElement(pr,'Vector3',name=n)
    for a,b in zip('XYZ',v):E.SubElement(c,a).text=str(b)
model,mp=item(root,'Model','LargeCity_CoastConventionCentre_P4');val(mp,'Ref','PrimaryPart','RBXPivot');groups={}
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
for n,v in [('Phase','4'),('GateB','Pending'),('LayoutId','LC-08'),('Revision','CoastConventionCentre-P4-v1')]:
    _,pr=item(meta,'StringValue',n);val(pr,'string','Value',v)
path=DEST/'LargeCityCoastConventionCentre_P4.rbxmx';E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
t=E.parse(path);assert len(t.findall('.//Item[@class="Part"]'))+len(t.findall('.//Item[@class="WedgePart"]'))==len(parts)+1
assert not t.findall('.//Item[@class="Script"]')
report=dict(revision='CoastConventionCentre-P4-v1',parts=len(parts)+1,foyer=[160,32,36],hall_a=[96,112,56],hall_b=[80,96,48],hall_b_setback=16,rear_z=80,roof_segments=16,canopy=[112,16,4],delivery_yard=[112,24],delivery_gates=3,plot=[224,224],gate_b='Pending',studio_test='Pending',checks=['plot bounds','roof heights56/48','two halls','setback16/rear alignment','three gates','clear entry','XML part count'])
(DOC/'geometry-checks.json').write_text(json.dumps(report,indent=2)+'\n')
if '--preview' in sys.argv:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont
    board=Image.new('RGB',(1800,1080),'#f4f3ed'); draw=ImageDraw.Draw(board)
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
    draw.text((900,30),'COAST CONVENTION CENTRE | Phase 4',font=ImageFont.truetype(bold,28),fill='#183b42',anchor='mt')
    views=[('Front / erhöht',18,-70),('Front',0,-90),('Rückseite',10,90),('Linke Seite',8,180),('Rechte Seite',8,0),('Draufsicht',90,-90)]
    render_parts=parts
    if '--cutaway' in sys.argv:
        render_parts=[p for p in parts if p['group'] not in ('RoofSegments','RoofFrames') and p['name']!='Roof' and not p['name'].startswith('FrontUpper')]
        views=[('Foyer / Hallen ohne Dach',40,-65)]
    for k,(title,el,az) in enumerate(views):
        elev,azim=math.radians(el),math.radians(az)
        forward=np.array([math.cos(azim)*math.cos(elev),math.sin(azim)*math.cos(elev),math.sin(elev)])
        right=np.array([-math.sin(azim),math.cos(azim),0])
        up=np.cross(forward,right)
        verts=[]; cols=[]
        for p in render_parts:
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
    draw.text((900,1010),'Zwei Hallen / Dachhöhen 56 und 48 / rechter Versatz 16 / Gate B offen',font=ImageFont.truetype(font,20),fill='#43585d',anchor='mt')
    draw.text((900,1043),'Technische Vorschau ausserhalb Studio. Symbole, Schrift, Materialtexturen und Lichtwirkung erst in Studio sichtbar.',font=ImageFont.truetype(font,16),fill='#43585d',anchor='mt')
    if '--cutaway' in sys.argv:board.crop((10,70,590,510)).save(DOC/'geometry-cutaway.png')
    else:board.save(DOC/'geometry-review.png')
print(json.dumps(report))
