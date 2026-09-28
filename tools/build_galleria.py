"""Issue10 Ocean Galleria P4: native Roblox Parts and WedgePart, deterministic exports.
python3 tools/build_galleria.py [--preview]. No remote assets or Blender.
"""
from pathlib import Path
import math,json,sys,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/galleria';DEST=ROOT/'dist';MOD=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
for p in (DOC,DEST,MOD):p.mkdir(parents=True,exist_ok=True)
PALETTE={'stone':(230,222,204),'metal':(67,75,77),'glass':(57,83,94),'silver':(242,233,212),'roof':(181,163,133),'teal':(36,139,149),'ground':(178,178,167)}
parts=[]
def part(g,n,size,pos,color='metal',collide=True,rz=0,rx=0,ry=0,shape='Block'):
    assert all(v>0 for v in size)
    parts.append(dict(group=g,name=n,size=size,pos=pos,color=color,collide=collide,rz=rz,rx=rx,ry=ry,shape=shape))
def beam(g,n,x1,x2,y1,y2,z1,z2,color='metal',collide=True):
    part(g,n,(x2-x1,y2-y1,z2-z1),((x1+x2)/2,(y1+y2)/2,(z1+z2)/2),color,collide)
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



beam('Site','Plot',-112,112,-1,0,-80,80,'ground')
for side,x1,x2 in [('Left',-96,-32),('Right',32,96)]:
 for i in range(3):
    g=f'{side}Wing{i+1:02}';y=i*18
    beam(g,'Floor',x1,x2,y,y+1,-48,48,'stone')
    beam(g,'TopBand',x1,x2,y+16,y+18,-48,48,'silver')
    # 15-high facade so stone stops exactly at the upper band.
    wall(g,'Front',x1,x2,-47,y,17,4,glazed=True)
    wall(g,'Outer',-46,46,x1+1 if side=='Left' else x2-1,y,17,6,side=True,glazed=True)
    if i==0:
        # Each wing has one loading gate near the central service yard.
        gate=-44 if side=='Left' else 44
        beam(g,'RearL',x1,gate-8,1,16,46,48,'stone')
        beam(g,'RearR',gate+8,x2,1,16,46,48,'stone')
        beam(g,'RearHeader',gate-8,gate+8,14,16,46,48,'stone')
        beam('Delivery',side+'Gate',gate-8,gate+8,0,14,47,47.5,'metal')
    else:wall(g,'Rear',x1,x2,47,y,17,4,glazed=True)
    # Accent strip within the band, visibly proud by .15, no coplanar face.
    beam(g,'TealFrontBand',x1,x2,y+16.4,y+17.4,-48.2,-48.05,'teal',False)
    xx=x1 if side=='Left' else x2
    beam(g,'TealOuterBand',xx-.15,xx+.15,y+16.4,y+17.4,-47.9,47.9,'teal',False)
beam('Atrium','Floor',-32,32,0,1,-48,48,'stone')
# Gallery rings on levels18 and36, leaving a large central void.
for i,y in enumerate([18,36]):
 g=f'Gallery{i+2}'
 beam(g,'Left',-32,-22,y,y+1,-48,48,'stone')
 beam(g,'Right',22,32,y,y+1,-48,48,'stone')
 beam(g,'Front',-22,22,y,y+1,-48,-38,'stone')
 beam(g,'Rear',-22,22,y,y+1,38,48,'stone')
 for tag,x in [('L',-21.8),('R',21.8)]:beam(g,'Guard'+tag,x-.15,x+.15,y+1,y+4,-38,38,'metal',False)
 for tag,z in [('F',-37.8),('B',37.8)]:beam(g,'Guard'+tag,-22,22,y+1,y+4,z-.15,z+.15,'metal',False)
# Three central glazed bays, with an unobstructed 20-wide central entry at ground level.
for i in range(3):
 y=i*18;g=f'AtriumFront{i+1}'
 if i==0:
    wall(g,'Left',-32,-10,-47,y,17,1,glazed=True)
    wall(g,'Right',10,32,-47,y,17,1,glazed=True)
    beam(g,'PortalLintel',-10,10,15,18,-48,-46,'teal')
 else:wall(g,'GlassWall',-32,32,-47,y,17,4,glazed=True)
 beam(g,'Band',-32,32,y+16,y+18,-48,-46,'teal')
 wall(f'AtriumRear{i+1}','GlassWall',-32,32,47,y,17,4,glazed=True)
 beam(f'AtriumRear{i+1}','Band',-32,32,y+16,y+18,46,48,'stone')
# Atrium pillars sit in boundary slots, connecting to wing edges.
for side,x in [('L',-31),('R',31)]:
 beam('Atrium','FrontPier'+side,x-1,x+1,1,54,-48.4,-48.25,'teal',False)
beam('Entrance','Canopy',-40,40,16,20,-64,-48,'teal')
# Roof outer arch points define the72Stud limit exactly; thickness goes inward.
for j,x in enumerate([-31.5,31.5]):beam('RoofFrames',f'Spring{j}',x-.5,x+.5,54,55,-48,48,'metal')
for bay in range(7):
 z=-47+bay*(94/6)
 for j in range(12):
    a=math.pi-j*math.pi/12;b=math.pi-(j+1)*math.pi/12
    x1,y1=32*math.cos(a),55+17*math.sin(a)
    x2,y2=32*math.cos(b),55+17*math.sin(b)
    length=math.hypot(x2-x1,y2-y1);angle=math.atan2(y2-y1,x2-x1)
    nx,ny=-math.sin(angle),math.cos(angle)
    part('RoofFrames',f'Arch{bay}_{j}',(length,1,2),((x1+x2)/2-nx*.5,(y1+y2)/2-ny*.5,z),'metal',True,rz=angle)
    if bay<6:
        part('GlassRoof',f'Panel{bay}_{j}',(length-.15,.3,94/6-2),((x1+x2)/2-nx*.7,(y1+y2)/2-ny*.7,z+94/12),'glass',True,rz=angle)
# Trapezoidal fanlight panes follow each arch segment; wedges close the sloped tops.
for side,z in [('Front',-47),('Rear',47)]:
 for j in range(12):
    a=math.pi-j*math.pi/12;b=math.pi-(j+1)*math.pi/12
    x1,x2=32*math.cos(a),32*math.cos(b)
    y1,y2=54.5+17*math.sin(a),54.5+17*math.sin(b)
    low=min(y1,y2);h=abs(y2-y1)
    beam('Fanlight',f'{side}{j}Base',x1,x2,54,low,z-.2,z+.2,'glass')
    if h>1e-6:part('Fanlight',f'{side}{j}Slope',(.4,h,x2-x1),((x1+x2)/2,low+h/2,z),'glass',True,ry=math.pi/2 if y2>y1 else -math.pi/2,shape='Wedge')
# Two compact roof units, max24x16x8; side roofs atY54.
for side,x in [('L',-64),('R',64)]:beam('RoofPlant','Unit'+side,x-12,x+12,54,62,12,28,'metal')
# 64x24 central service yard. Two short apron wings connect the rear gates.
beam('Delivery','Yard',-32,32,.02,.1,48,72,'roof')
for side,a,b in [('L',-56,-32),('R',32,56)]:beam('Delivery','Apron'+side,a,b,.02,.1,48,60,'roof')
for j,(x,z,w,d) in enumerate([(-68,-68,32,10),(68,-68,32,10)]):
 beam('Site',f'Planter{j}Base',x-w/2,x+w/2,0,1,z-d/2,z+d/2,'stone')
 for tag,xx in [('L',x-w/2),('R',x+w/2-1)]:beam('Site',f'Planter{j}{tag}',xx,xx+1,1,2,z-d/2,z+d/2,'silver')
 for tag,zz in [('F',z-d/2),('B',z+d/2-1)]:beam('Site',f'Planter{j}{tag}',x-w/2+1,x+w/2-1,1,2,zz,zz+1,'silver')
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
 assert b[0][0]>=-112-1e-6 and b[0][1]<=112+1e-6 and b[2][0]>=-80-1e-6 and b[2][1]<=80+1e-6 and b[1][1]<=72+1e-6,p
assert abs(max(bounds(p)[1][1] for p in parts)-72)<1e-6
for side in ('Left','Right'):
 floors=[p for p in parts if p['group'].startswith(side+'Wing') and p['name']=='Floor']
 assert len(floors)==3 and all(p['size']==(64,1,96) for p in floors)
assert len([p for p in parts if p['group']=='Delivery' and p['name'].endswith('Gate')])==2
assert len([p for p in parts if p['group']=='RoofPlant'])==2
for p in parts:
 if p['group']=='Site' or (p['group']=='Atrium' and p['name']=='Floor'):continue
 b=bounds(p)
 assert not (b[0][0]<9.9 and b[0][1]>-9.9 and b[1][0]<14.9 and b[1][1]>1 and b[2][0]<-46 and b[2][1]>-64),('entry blocked',p)
rows=['-- Generated by tools/build_galleria.py; Phase4 GateB pending.','local Builder = {}','local Parts = {']
for p in parts:rows.append(' {'+', '.join(json.dumps(v) for v in [p['group'],p['name'],*p['size'],*p['pos'],*PALETTE[p['color']],p['collide'],p['rz'],p['rx'],p['ry'],p['shape']])+'},')
rows+=['}', '''function Builder.Build(parent,options)
 options=options or {}
 local model=Instance.new("Model");model.Name="LargeCity_OceanGalleria_P4"
 model:SetAttribute("LayoutId","LC-07");model:SetAttribute("Phase",4)
 model:SetAttribute("QualityGateA","Approved");model:SetAttribute("QualityGateB","Pending")
 model:SetAttribute("BuildRevision","OceanGalleria-P4-v1")
 local pivot=Instance.new("Part");pivot.Name="GroundPivot";pivot.Size=Vector3.new(.1,.1,.1)
 pivot.Anchored=true;pivot.Transparency=1;pivot.CanCollide=false;pivot.CanQuery=false;pivot.CanTouch=false
 pivot.Parent=model;model.PrimaryPart=pivot
 local groups={}
 for _,d in ipairs(Parts) do
  if not groups[d[1]] then local g=Instance.new("Model");g.Name=d[1];g.Parent=model;groups[d[1]]=g end
  local p=Instance.new(d[16]=="Wedge" and "WedgePart" or "Part");p.Name=d[2];p.Size=Vector3.new(d[3],d[4],d[5])
  local section="D2_Atrium"
  if string.sub(d[1],1,8)=="LeftWing" then section="D1_LeftWing"
  elseif string.sub(d[1],1,9)=="RightWing" then section="D3_RightWing"
  elseif d[1]=="Site" or d[1]=="Delivery" or d[1]=="RoofPlant" then
   if d[6]<-32 then section="D1_LeftWing" elseif d[6]>32 then section="D3_RightWing" end
  end
  p:SetAttribute("PlannedDestructionGroup",section)
  p.CFrame=CFrame.new(d[6],d[7],d[8])*CFrame.Angles(0,0,d[13])*CFrame.Angles(d[14],0,0)*CFrame.Angles(0,d[15],0)
  if d[16]=="Cylinder" then p.Shape=Enum.PartType.Cylinder end
  p.Color=Color3.fromRGB(d[9],d[10],d[11]);p.Anchored=true;p.CanCollide=d[12]
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=groups[d[1]]
 end
 model.Parent=parent;model:PivotTo(options.GroundCFrame or CFrame.new());return model
end
return Builder
''']
(MOD/'LargeCityOceanGalleriaGoldenMaster.lua').write_text('\n'.join(rows))
root=E.Element('roblox',version='4');counter=0
def val(pr,t,n,v):E.SubElement(pr,t,name=n).text=str(v).lower() if isinstance(v,bool) else str(v)
def item(parent,cls,name,ref=None):
    global counter
    counter+=1;it=E.SubElement(parent,'Item',{'class':cls,'referent':ref or f'RBX{counter}'})
    pr=E.SubElement(it,'Properties');val(pr,'string','Name',name);return it,pr
def vec(pr,n,v):
    c=E.SubElement(pr,'Vector3',name=n)
    for a,b in zip('XYZ',v):E.SubElement(c,a).text=str(b)
model,mp=item(root,'Model','LargeCity_OceanGalleria_P4');val(mp,'Ref','PrimaryPart','RBXPivot');groups={}
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
for n,v in [('Phase','4'),('GateB','Pending'),('LayoutId','LC-07'),('Revision','OceanGalleria-P4-v1')]:
    _,pr=item(meta,'StringValue',n);val(pr,'string','Value',v)
path=DEST/'LargeCityOceanGalleria_P4.rbxmx';E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
t=E.parse(path);assert len(t.findall('.//Item[@class="Part"]'))+len(t.findall('.//Item[@class="WedgePart"]'))==len(parts)+1
assert not t.findall('.//Item[@class="Script"]')
report=dict(revision='OceanGalleria-P4-v1',parts=len(parts)+1,storeys=3,wing=[64,96,54],atrium=[64,96,72],canopy=[80,16,4],roof_spring=54,max_height=72,delivery_yard=[64,24],delivery_gates=2,plot=[224,160],gate_b='Pending',studio_test='Pending',checks=['plot bounds','height72','two three-storey wings','two loading gates','free entrance','XML part count'])
(DOC/'geometry-checks.json').write_text(json.dumps(report,indent=2)+'\n')
if '--preview' in sys.argv:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont
    board=Image.new('RGB',(1800,1080),'#f4f3ed'); draw=ImageDraw.Draw(board)
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
    draw.text((900,30),'OCEAN GALLERIA | Phase 4',font=ImageFont.truetype(bold,28),fill='#183b42',anchor='mt')
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
    draw.text((900,1010),'3 Geschosse / 192 Studs Gebäudebreite / Atrium 72 Studs / Gate B offen',font=ImageFont.truetype(font,20),fill='#43585d',anchor='mt')
    draw.text((900,1043),'Technische Vorschau ausserhalb Studio. Symbole, Schrift, Materialtexturen und Lichtwirkung erst in Studio sichtbar.',font=ImageFont.truetype(font,16),fill='#43585d',anchor='mt')
    board.save(DOC/'geometry-review.png')
print(json.dumps(report))
