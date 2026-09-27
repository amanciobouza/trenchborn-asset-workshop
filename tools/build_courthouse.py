"""Issue8 Courthouse P4: native Roblox Parts and WedgePart, deterministic exports.
python3 tools/build_courthouse.py [--preview]. No remote assets or Blender.
"""
from pathlib import Path
import math,json,sys,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/courthouse';DEST=ROOT/'dist';MOD=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
for p in (DOC,DEST,MOD):p.mkdir(parents=True,exist_ok=True)
PALETTE={'stone':(230,222,204),'metal':(67,75,77),'glass':(57,83,94),'silver':(242,233,212),'roof':(181,163,133),'ground':(178,178,167)}
parts=[]
def part(g,n,size,pos,color='metal',collide=True,rz=0,rx=0,ry=0,shape='Block'):
    assert all(v>0 for v in size)
    parts.append(dict(group=g,name=n,size=size,pos=pos,color=color,collide=collide,rz=rz,rx=rx,ry=ry,shape=shape))
def beam(g,n,x1,x2,y1,y2,z1,z2,color='metal',collide=True):
    part(g,n,(x2-x1,y2-y1,z2-z1),((x1+x2)/2,(y1+y2)/2,(z1+z2)/2),color,collide)
# Ground plot centred at origin. All structural building heights start at plateau Y8.
beam('Site','Plot',-96,96,-1,0,-72,72,'ground')
beam('Foundation','BuildingBase',-80,80,0,8,-24,56,'stone')
beam('Foundation','PorchBase',-32,32,0,8,-44,-24,'stone')
def wall(g,prefix,start,end,fixed,y,h,bays,side=False,glazed=False):
    pitch=(end-start)/bays; opening=pitch-2 if glazed else 8
    bottom=1.5 if glazed else 3; top=h-1.5 if glazed else 16
    def box(n,a,b,c,d,depth,col):
        if side:beam(g,prefix+n,fixed-depth/2,fixed+depth/2,c,d,a,b,col)
        else:beam(g,prefix+n,a,b,c,d,fixed-depth/2,fixed+depth/2,col)
    for i in range(bays):
        a=start+i*pitch;b=a+pitch;l=(a+b-opening)/2;r=l+opening
        box(f'{i}L',a,l,y+1,y+h-1,2,'stone')
        box(f'{i}R',r,b,y+1,y+h-1,2,'stone')
        if bottom>1:box(f'{i}Sill',l,r,y+1,y+bottom,2,'stone')
        if top<h-1:box(f'{i}Head',l,r,y+top,y+h-1,2,'stone')
        box(f'{i}GlassL',l+.25,(l+r)/2-.12,y+bottom+.25,y+top-.25,.25,'glass')
        box(f'{i}GlassR',(l+r)/2+.12,r-.25,y+bottom+.25,y+top-.25,.25,'glass')
        for edge,aa,bb in [('L',l,l+.25),('R',r-.25,r)]:box(f'{i}Frame'+edge,aa,bb,y+bottom,y+top,.6,'metal')
        box(f'{i}FrameB',l+.25,r-.25,y+bottom,y+bottom+.25,.6,'metal')
        box(f'{i}FrameT',l+.25,r-.25,y+top-.25,y+top,.6,'metal')
        box(f'{i}Mullion',(l+r)/2-.12,(l+r)/2+.12,y+bottom+.25,y+top-.25,.5,'metal')

for side,x1,x2 in [('Left',-80,-32),('Right',32,80)]:
 for i in range(3):
    g=f'{side}Wing{i+1:02}';y=8+i*20
    beam(g,'Floor',x1,x2,y,y+1,-16,56,'stone')
    beam(g,'TopBand',x1,x2,y+19,y+20,-16,56,'silver')
    wall(g,'Front',x1+1,x2-1,-15,y,20,3)
    wall(g,'Rear',x1+1,x2-1,55,y,20,3)
    wall(g,'Outer',-14,54,x1+1 if side=='Left' else x2-1,y,20,5,side=True)
    # Inner wings abut the middle block; no hidden duplicate interior facade.
for i in range(3):
    g=f'Centre{i+1:02}';y=8+i*24
    beam(g,'Floor',-32,32,y,y+1,-24,56,'stone')
    beam(g,'TopBand',-32,32,y+23,y+24,-24,56,'silver')
    wall(g,'Rear',-31,31,55,y,24,4)
    if i<2:wall(g,'Front',-31,31,-23,y,24,4,glazed=True)
    else:beam(g,'SymbolWall',-32,32,y+1,y+23,-24,-22,'stone')
    # Centre rises 12 studs above the wings: exposed upper side strips only.
    if i==2:
        for tag,x in [('L',-31),('R',31)]:
            beam(g,'UpperSide'+tag,x-1,x+1,68,79,-22,54,'stone')
# Enclose the eight-stud forward projection of the centre beside each wing.
for tag,x in [('L',-31),('R',31)]:
 beam('CentreSide',tag,x-1,x+1,8,68,-22,-16,'stone')
# Six truly cylindrical columns, each 6 diameter envelope x40 height including ends.
for j,x in enumerate([-27,-16.2,-5.4,5.4,16.2,27]):
 for name,y,h,d in [('Base',9.5,3,6),('Shaft',28,34,5),('Capital',46.5,3,6)]:
    part('Portico',f'Column{j+1}{name}',(h,d,d),(x,y,-40),'silver',True,rz=math.pi/2,shape='Cylinder')
beam('Portico','Entablature',-32,32,48,56,-44,-24,'stone')
# Broad stair: sixteen treads, 1.5 deep x.5 rise, total72x24x8.
for i in range(16):beam('Access',f'Step{i+1:02}',-36,36,0,(i+1)*.5,-68+i*1.5,-66.5+i*1.5,'stone')
# A standard wedge rises toward local +Z. Rotate -90deg to rise toward world -X.
part('Access','Ramp',(8,8,48),(60,4,-34),'stone',True,ry=-math.pi/2,shape='Wedge')
beam('Access','RampLanding',32,36,0,8,-38,-30,'stone')
# Low side planters avoid stairs and ramp. Plants and flags arrive in P5.
for j,(x,z,w,d) in enumerate([(-59,-31,34,10),(-62,-61,34,10),(62,-61,34,10),(88,22,8,40),(-88,22,8,40)]):
    beam('Site',f'Planter{j}Base',x-w/2,x+w/2,0,1,z-d/2,z+d/2,'stone')
    for tag,xx in [('L',x-w/2),('R',x+w/2-1)]:beam('Site',f'Planter{j}{tag}',xx,xx+1,1,2,z-d/2,z+d/2,'silver')
    for tag,zz in [('F',z-d/2),('B',z+d/2-1)]:beam('Site',f'Planter{j}{tag}',x-w/2+1,x+w/2-1,1,2,zz,zz+1,'silver')
for j,x in enumerate([-2,2]):part('Entrance',f'Handle{j}',(.4,3,.5),(x,15,-24.2),'metal',False)
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
 assert b[0][0]>=-96-1e-6 and b[0][1]<=96+1e-6 and b[2][0]>=-72-1e-6 and b[2][1]<=72+1e-6 and b[1][1]<=80+1e-6,p
assert max(bounds(p)[1][1] for p in parts)==80
columns=[p for p in parts if p['group']=='Portico' and 'Column' in p['name']]
assert len(columns)==18
for j in range(6):
 c=[p for p in columns if p['name'].startswith(f'Column{j+1}')]
 assert min(bounds(p)[1][0] for p in c)==8 and max(bounds(p)[1][1] for p in c)==48
for side in ['Left','Right']:
 assert max(bounds(p)[1][1] for p in parts if p['group'].startswith(side+'Wing'))==68
steps=[p for p in parts if p['group']=='Access' and p['name'].startswith('Step')]
assert len(steps)==16 and steps[0]['pos'][2]-.75==-68 and steps[-1]['pos'][2]+.75==-44
ramp=next(p for p in parts if p['name']=='Ramp');assert ramp['size']==(8,8,48)
assert abs(bounds(ramp)[0][0]-36)<1e-6 and abs(bounds(ramp)[0][1]-84)<1e-6
# Ramp walking surface high end touches landing (X36,Y8), low end is (X84,Y0).
for p in parts:
 if p['group']=='Access' or p['name']=='Plot':continue
 b=bounds(p)
 assert not (b[0][0]<84 and b[0][1]>36 and b[2][0]<-30 and b[2][1]>-38 and b[1][1]>0),p
rows=['-- Generated by tools/build_courthouse.py; Phase4 GateB pending.','local Builder = {}','local Parts = {']
for p in parts:rows.append(' {'+', '.join(json.dumps(v) for v in [p['group'],p['name'],*p['size'],*p['pos'],*PALETTE[p['color']],p['collide'],p['rz'],p['rx'],p['ry'],p['shape']])+'},')
rows+=['}', '''function Builder.Build(parent,options)
 options=options or {}
 local model=Instance.new("Model");model.Name="LargeCity_Courthouse_P4"
 model:SetAttribute("LayoutId","LC-34");model:SetAttribute("Phase",4)
 model:SetAttribute("QualityGateA","Approved");model:SetAttribute("QualityGateB","Pending")
 model:SetAttribute("BuildRevision","Courthouse-P4-v1")
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
(MOD/'LargeCityCourthouseGoldenMaster.lua').write_text('\n'.join(rows))
root=E.Element('roblox',version='4');counter=0
def val(pr,t,n,v):E.SubElement(pr,t,name=n).text=str(v).lower() if isinstance(v,bool) else str(v)
def item(parent,cls,name,ref=None):
    global counter
    counter+=1;it=E.SubElement(parent,'Item',{'class':cls,'referent':ref or f'RBX{counter}'})
    pr=E.SubElement(it,'Properties');val(pr,'string','Name',name);return it,pr
def vec(pr,n,v):
    c=E.SubElement(pr,'Vector3',name=n)
    for a,b in zip('XYZ',v):E.SubElement(c,a).text=str(b)
model,mp=item(root,'Model','LargeCity_Courthouse_P4');val(mp,'Ref','PrimaryPart','RBXPivot');groups={}
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
for n,v in [('Phase','4'),('GateB','Pending'),('LayoutId','LC-34'),('Revision','Courthouse-P4-v1')]:
    _,pr=item(meta,'StringValue',n);val(pr,'string','Value',v)
path=DEST/'LargeCityCourthouse_P4.rbxmx';E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
t=E.parse(path);assert len(t.findall('.//Item[@class="Part"]'))+len(t.findall('.//Item[@class="WedgePart"]'))==len(parts)+1
assert not t.findall('.//Item[@class="Script"]')
report=dict(revision='Courthouse-P4-v1',parts=len(parts)+1,storeys=3,columns=6,column_diameter=6,column_height=40,plateau=8,centre=[64,80,72],wing=[48,72,60],portico=[64,20,48],maximum_height=80,wing_top=68,portico_top=56,stairs=[72,24,8],ramp_width=8,ramp_length=48,plot=[192,144],gate_b='Pending',studio_test='Pending',checks=['plot bounds','six cylindrical columns','plateau and all height limits','sixteen steps','ramp clearance and continuous endpoint'])
(DOC/'geometry-checks.json').write_text(json.dumps(report,indent=2)+'\n')
if '--preview' in sys.argv:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont
    board=Image.new('RGB',(1800,1080),'#f4f3ed'); draw=ImageDraw.Draw(board)
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
    draw.text((900,30),'COURTHOUSE | Phase 4',font=ImageFont.truetype(bold,28),fill='#183b42',anchor='mt')
    views=[('Front / erhöht',18,-70),('Front',0,-90),('Rückseite',10,90),('Linke Seite',8,180),('Rechte Seite',8,0),('Draufsicht',90,-90)]
    for k,(title,el,az) in enumerate(views):
        elev,azim=math.radians(el),math.radians(az)
        forward=np.array([math.cos(azim)*math.cos(elev),math.sin(azim)*math.cos(elev),math.sin(elev)])
        right=np.array([-math.sin(azim),math.cos(azim),0])
        up=np.cross(forward,right)
        verts=[]; cols=[]
        for p in parts:
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
    draw.text((900,1010),'6 Säulen / Plateau +8 / Flügel 68 / Mittelbau 80 Studs / Gate B offen',font=ImageFont.truetype(font,20),fill='#43585d',anchor='mt')
    draw.text((900,1043),'Technische Vorschau ausserhalb Studio. Symbole, Schrift, Materialtexturen und Lichtwirkung erst in Studio sichtbar.',font=ImageFont.truetype(font,16),fill='#43585d',anchor='mt')
    board.save(DOC/'geometry-review.png')
print(json.dumps(report))
