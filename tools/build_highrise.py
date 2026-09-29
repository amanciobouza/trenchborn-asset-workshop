"""Issue13 Tropical High-Rise P4: native Roblox Parts and WedgePart, deterministic exports.
python3 tools/build_highrise.py [--preview]. No remote assets or Blender.
"""
from pathlib import Path
import math,json,sys,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/highrise';DEST=ROOT/'dist';MOD=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
for p in (DOC,DEST,MOD):p.mkdir(parents=True,exist_ok=True)
PALETTE={'stone':(230,222,204),'metal':(67,75,77),'glass':(57,83,94),'silver':(242,233,212),'roof':(181,163,133),'teal':(36,139,149),'ground':(178,178,167)}
parts=[]
def part(g,n,size,pos,color='metal',collide=True,rz=0,rx=0,ry=0,shape='Block'):
    assert all(v>0 for v in size)
    parts.append(dict(group=g,name=n,size=size,pos=pos,color=color,collide=collide,rz=rz,rx=rx,ry=ry,shape=shape))
def beam(g,n,x1,x2,y1,y2,z1,z2,color='metal',collide=True):
    part(g,n,(x2-x1,y2-y1,z2-z1),((x1+x2)/2,(y1+y2)/2,(z1+z2)/2),color,collide)

PALETTE['glass']=(102,159,171)
PALETTE['bronze']=(128,104,76)
def facade(g,label,a,b,fixed,y0,y1,bays,side=False,entry=False):
    pw=5.5;gap=(b-a-pw*(bays+1))/bays
    def box(n,u,v,lo,hi,depth,color,offset=0):
        if side:beam(g,label+n,fixed-depth/2+offset,fixed+depth/2+offset,lo,hi,u,v,color)
        else:beam(g,label+n,u,v,lo,hi,fixed-depth/2+offset,fixed+depth/2+offset,color)
    for i in range(bays+1):
        u=a+i*(gap+pw);box(f'Pier{i}',u,u+pw,y0,y1,2,'stone')
    for i in range(bays):
        u=a+pw+i*(gap+pw);v=u+gap
        if entry and i==bays//2:
            box('EntryHeader',u,v,y0+14,y1,1,'metal')
            continue
        # Thin frames own their strips; no frame face coincides with the pane face.
        box(f'FrameL{i}',u,u+.35,y0,y1,.65,'metal')
        box(f'FrameR{i}',v-.35,v,y0,y1,.65,'metal')
        box(f'FrameTop{i}',u+.35,v-.35,y1-.35,y1,.65,'metal')
        box(f'FrameBottom{i}',u+.35,v-.35,y0,y0+.35,.65,'metal')
        mid=(u+v)/2
        box(f'GlassL{i}',u+.35,mid-.15,y0+.35,y1-.35,.25,'glass')
        box(f'GlassR{i}',mid+.15,v-.35,y0+.35,y1-.35,.25,'glass')
        box(f'Mullion{i}',mid-.15,mid+.15,y0+.35,y1-.35,.6,'metal')
def storey(g,w,d,y,h,bays):
    beam(g,'Floor',-w/2,w/2,y,y+1,-d/2,d/2,'silver')
    beam(g,'TopBand',-w/2,w/2,y+h-.6,y+h,-d/2,d/2,'silver')
    # Corner columns belong to front/rear elevations; side fields stop before them.
    facade(g,'Front',-w/2,w/2,-d/2+1,y+1,y+h-.6,bays,entry=(g=='Podium01'))
    facade(g,'Rear',-w/2,w/2,d/2-1,y+1,y+h-.6,bays)
    facade(g,'Left',-d/2+2,d/2-2,-w/2+1,y+1,y+h-.6,max(2,bays-1),True)
    facade(g,'Right',-d/2+2,d/2-2,w/2-1,y+1,y+h-.6,max(2,bays-1),True)
beam('Site','Plot',-72,72,-.5,0,-64,64,'ground')
for i in range(2):storey(f'Podium{i+1:02}',112,96,i*18,18,5)
for label,w,d,start,count in [('Lower',88,72,36,8),('Middle',72,56,164,7),('Upper',56,40,276,5)]:
    for i in range(count):storey(label+f'{i+1:02}',w,d,start+i*16,16,3)
# Deep canopy stays on the plot and leaves a wide open entrance beneath.
beam('Entrance','Canopy',-24,24,16,19,-64,-48,'silver')
beam('Entrance','FrontTrim',-24,24,16,17,-64,-63.5,'bronze')
# Front trim uses a separate plane outside the slab's front face to avoid overlap.
# Cut the canopy front back to meet the trim instead of covering it.
for p in parts:
    if p['group']=='Entrance' and p['name']=='Canopy':p['size']=(48,3,15.5);p['pos']=(0,17.5,-55.75)
for i,x in enumerate([-21,21]):beam('Entrance',f'Column{i}',x-1,x+1,0,16,-60,-58,'stone')
beam('Entrance','Approach',-10,10,.01,.15,-64,-46,'roof')
# Simplified lobby core stops behind the entrance; no complete office interiors.
beam('Podium01','LobbyCore',-8,8,1,17.4,8,24,'stone')
beam('Podium02','LobbyCore',-8,8,19,35.4,8,24,'stone')
def planter(g,n,x,z,w,d,y):
    beam(g,n+'Base',x-w/2,x+w/2,y,y+.5,z-d/2,z+d/2,'stone')
    for tag,xx in [('L',x-w/2),('R',x+w/2-.5)]:beam(g,n+tag,xx,xx+.5,y+.5,y+2.4,z-d/2,z+d/2,'silver')
    for tag,zz in [('F',z-d/2),('B',z+d/2-.5)]:beam(g,n+tag,x-w/2+.5,x+w/2-.5,y+.5,y+2.4,zz,zz+.5,'silver')
for name,w,d,iw,id,y in [('TerraceLower',88,72,72,56,164),('TerraceMiddle',72,56,56,40,276),('PodiumTerrace',112,96,88,72,36)]:
    # Long planters sit on the outer edge; inner circulation strips remain free.
    for j,sign in enumerate([-1,1]):
        for i,x in enumerate([-w/4,w/4]):planter(name,f'Planter{j}{i}',x,sign*(d/2-2.5),w/4,3,y)
    for j,sign in enumerate([-1,1]):
        x=sign*(w/2-.5)
        beam(name,f'SideGuard{j}',x-.2,x+.2,y,y+3.5,-d/2+.6,d/2-.6,'glass')
        beam(name,f'SideRail{j}',x-.3,x+.3,y+3.5,y+3.8,-d/2+.6,d/2-.6,'metal')
        z=sign*(d/2-.5)
        beam(name,f'FrontGuard{j}',-w/2+.8,w/2-.8,y,y+3.5,z-.2,z+.2,'glass')
        beam(name,f'FrontRail{j}',-w/2+.8,w/2-.8,y+3.5,y+3.8,z-.3,z+.3,'metal')
# Open geometric crown: four warm concrete columns and a sparse metal top frame.
for i,x in enumerate([-22.5,22.5]):
    for j,z in enumerate([-14.5,14.5]):beam('Crown',f'Column{i}{j}',x-1.5,x+1.5,356,378,z-1.5,z+1.5,'stone')
for j,z in enumerate([-14.5,14.5]):beam('Crown',f'CrossBeam{j}',-24,24,378,380,z-1.5,z+1.5,'bronze')
for i,x in enumerate([-22.5,22.5]):beam('Crown',f'SideBeam{i}',x-1.5,x+1.5,378,380,-13,13,'bronze')
# A smaller inset open frame adds depth without a solid roof or antenna.
for i,x in enumerate([-18.5,18.5]):
    for j,z in enumerate([-10.5,10.5]):beam('Crown',f'InnerPost{i}{j}',x-.5,x+.5,356,375,z-.5,z+.5,'metal')
for j,z in enumerate([-10.5,10.5]):beam('Crown',f'InnerCross{j}',-19,19,375,376,z-.5,z+.5,'metal')
for i,x in enumerate([-18.5,18.5]):beam('Crown',f'InnerSide{i}',x-.5,x+.5,375,376,-10,10,'metal')
for i,x in enumerate([-23,23]):planter('RoofGarden',f'Trough{i}',x,0,3,18,356)
for i,(x,z,w,d) in enumerate([(-43,-56,22,8),(43,-56,22,8),(-64,-20,8,20),(64,-20,8,20)]):planter('Site',f'Planter{i}',x,z,w,d,0)
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
    assert b[0][0]>=-72-1e-6 and b[0][1]<=72+1e-6 and b[2][0]>=-64-1e-6 and b[2][1]<=64+1e-6 and b[1][1]<=380+1e-6,p
assert abs(max(bounds(p)[1][1] for p in parts)-380)<1e-6
for label,count,w,d,start,h in [('Podium',2,112,96,0,18),('Lower',8,88,72,36,16),('Middle',7,72,56,164,16),('Upper',5,56,40,276,16)]:
    floors=[p for p in parts if p['group'].startswith(label) and p['name']=='Floor']
    assert len(floors)==count
    for i,p in enumerate(floors):assert p['size']==(w,1,d) and p['pos']==(0,start+i*h+.5,0)
assert (88-72)/2==(72-56)/2==(56-40)/2==8
assert not any(p for p in parts if p['group']=='Crown' and p['name']=='Roof')
# Open central entrance through the ground-floor front face.
for p in parts:
    if p['group']=='Site' or p['name'] in ('Floor','Approach'):continue
    b=bounds(p)
    assert not (b[0][0]<7 and b[0][1]>-7 and b[1][0]<14 and b[1][1]>1 and b[2][0]<-46 and b[2][1]>-64),('entry blocked',p)
rows=['-- Generated by tools/build_highrise.py; Phase4 GateB pending.','local Builder = {}','local Parts = {']
for p in parts:rows.append(' {'+', '.join(json.dumps(v) for v in [p['group'],p['name'],*p['size'],*p['pos'],*PALETTE[p['color']],p['collide'],p['rz'],p['rx'],p['ry'],p['shape']])+'},')
rows+=['}', '''function Builder.Build(parent,options)
 options=options or {}
 local model=Instance.new("Model");model.Name="LargeCity_TropicalHighRise_P4"
 model:SetAttribute("LayoutId","LC-21");model:SetAttribute("Phase",4)
 model:SetAttribute("QualityGateA","Approved");model:SetAttribute("QualityGateB","Pending")
 model:SetAttribute("BuildRevision","TropicalHighRise-P4-v1")
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
(MOD/'LargeCityTropicalHighRiseGoldenMaster.lua').write_text('\n'.join(rows))
root=E.Element('roblox',version='4');counter=0
def val(pr,t,n,v):E.SubElement(pr,t,name=n).text=str(v).lower() if isinstance(v,bool) else str(v)
def item(parent,cls,name,ref=None):
    global counter
    counter+=1;it=E.SubElement(parent,'Item',{'class':cls,'referent':ref or f'RBX{counter}'})
    pr=E.SubElement(it,'Properties');val(pr,'string','Name',name);return it,pr
def vec(pr,n,v):
    c=E.SubElement(pr,'Vector3',name=n)
    for a,b in zip('XYZ',v):E.SubElement(c,a).text=str(b)
model,mp=item(root,'Model','LargeCity_TropicalHighRise_P4');val(mp,'Ref','PrimaryPart','RBXPivot');groups={}
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
for n,v in [('Phase','4'),('GateB','Pending'),('LayoutId','LC-21'),('Revision','TropicalHighRise-P4-v1')]:
    _,pr=item(meta,'StringValue',n);val(pr,'string','Value',v)
path=DEST/'LargeCityTropicalHighRise_P4.rbxmx';E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
t=E.parse(path);assert len(t.findall('.//Item[@class="Part"]'))+len(t.findall('.//Item[@class="WedgePart"]'))==len(parts)+1
assert not t.findall('.//Item[@class="Script"]')
report=dict(revision='TropicalHighRise-P4-v1',parts=len(parts)+1,storeys=22,storey_distribution=[2,8,7,5],podium=[112,96,36],lower=[88,72,128],middle=[72,56,112],upper=[56,40,80],crown=[48,32,24],height_marks=[36,164,276,356,380],max_height=380,terrace_width=8,plot=[144,128],gate_b='Pending',studio_test='Pending',checks=['plot bounds','height380','22storeys','centred sections','eightStud setbacks','open crown','clear entry','XML count'])
(DOC/'geometry-checks.json').write_text(json.dumps(report,indent=2)+'\n')
if '--preview' in sys.argv:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont
    board=Image.new('RGB',(1800,1080),'#f4f3ed'); draw=ImageDraw.Draw(board)
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
    draw.text((900,30),'TROPICAL HIGH-RISE | Phase 4',font=ImageFont.truetype(bold,28),fill='#183b42',anchor='mt')
    views=[('Front / erhöht',18,-70),('Front',0,-90),('Rückseite',10,90),('Linke Seite',8,180),('Terrasse / Krone',24,-60),('Sockel / Eingang',20,-60)]
    for k,(title,el,az) in enumerate(views):
        elev,azim=math.radians(el),math.radians(az)
        forward=np.array([math.cos(azim)*math.cos(elev),math.sin(azim)*math.cos(elev),math.sin(elev)])
        right=np.array([-math.sin(azim),math.cos(azim),0])
        up=np.cross(forward,right)
        verts=[]; cols=[]
        selected=parts if k<4 else [p for p in parts if (p['group'].startswith(('Upper','Crown','RoofGarden','TerraceMiddle')) if k==4 else p['group'].startswith(('Podium','Entrance','Site')))]
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
    draw.text((900,1010),'22 Geschosse / 380 Studs / drei Turmabschnitte / Gate B offen',font=ImageFont.truetype(font,20),fill='#43585d',anchor='mt')
    draw.text((900,1043),'Technische Vorschau ausserhalb Studio. Symbole, Schrift, Materialtexturen und Lichtwirkung erst in Studio sichtbar.',font=ImageFont.truetype(font,16),fill='#43585d',anchor='mt')
    board.save(DOC/'geometry-review.png')
print(json.dumps(report))
