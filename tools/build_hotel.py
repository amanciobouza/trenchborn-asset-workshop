"""Issue7 City Hotel P4: native Roblox Parts and WedgePart, deterministic exports.
python3 tools/build_hotel.py [--preview]. No remote assets or Blender.
"""
from pathlib import Path
import math,json,sys,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/hotel';DEST=ROOT/'dist';MOD=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
for p in (DOC,DEST,MOD):p.mkdir(parents=True,exist_ok=True)
PALETTE={'stone':(230,222,204),'metal':(151,122,81),'glass':(57,83,94),'silver':(242,233,212),'roof':(181,163,133),'ground':(178,178,167)}
parts=[]
def part(g,n,size,pos,color='metal',collide=True,rz=0,rx=0,ry=0,shape='Block'):
    assert all(v>0 for v in size)
    parts.append(dict(group=g,name=n,size=size,pos=pos,color=color,collide=collide,rz=rz,rx=rx,ry=ry,shape=shape))
def beam(g,n,x1,x2,y1,y2,z1,z2,color='metal',collide=True):
    part(g,n,(x2-x1,y2-y1,z2-z1),((x1+x2)/2,(y1+y2)/2,(z1+z2)/2),color,collide)
# Plot-centred ground pivot. Building centre Z=12; front=-Z.
beam('Site','Plot',-88,88,-1,-.2,-72,72,'ground')
beam('Site','FrontPaving',-88,88,-.2,0,-72,-58,'ground')
beam('Site','RearPaving',-88,88,-.2,0,-30,72,'ground')
# Drive surface flush with Y=0; 20 studs clear to canopy soffit.
beam('Site','Drive',-88,88,-.2,0,-58,-30,'roof')
# Wall bays have actual window openings, not glass laid over a wall.
def wall(g,prefix,start,end,fixed,y,h,bays,side=False,glazed=False):
    pitch=(end-start)/bays; opening=pitch-2 if glazed else 9
    bottom=1.5 if glazed else 3; top=h-1.5 if glazed else 13
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
for i in range(2):
    g=f'Podium{i+1:02}';y=i*18
    beam(g,'Floor',-64,64,y,y+1,-28,52,'stone')
    beam(g,'TopBand',-64,64,y+17,y+18,-28,52,'stone')
    wall(g,'Front',-63,63,-27,y,18,8,glazed=True)
    wall(g,'Rear',-63,63,51,y,18,8,glazed=True)
    wall(g,'Restaurant',-26,50,63,y,18,5,side=True,glazed=True)
    wall(g,'Left',-26,50,-63,y,18,5,side=True,glazed=True)
for i in range(10):
    g=f'Rooms{i+1:02}';y=36+i*16
    beam(g,'Floor',-60,60,y,y+1,-24,48,'stone')
    beam(g,'TopBand',-60,60,y+15,y+16,-24,48,'stone')
    wall(g,'FrontL',-59,-12,-23,y,16,3)
    wall(g,'FrontR',12,59,-23,y,16,3)
    wall(g,'Rear',-59,59,47,y,16,8)
    wall(g,'Left',-22,46,-59,y,16,5,side=True)
    wall(g,'Right',-22,46,59,y,16,5,side=True)
    # 24 wide and 6 projecting beyond front -24; segment belongs to its floor.
    beam(g,'CentreL',-12,-8,y,y+16,-30,-24,'stone')
    beam(g,'CentreR',8,12,y,y+16,-30,-24,'stone')
    beam(g,'CentrePanel',-8,8,y,y+16,-28.5,-24,'roof')
    for j,x in enumerate([-6,-2,2,6]):
        beam(g,f'CentreFlute{j}',x-.35,x+.35,y+.5,y+15.5,-29,-28.5,'metal')
# Eight-stud crown, open centre for hidden services.
beam('Crown','RoofDeck',-64,64,196,198,-28,52,'stone')
beam('Crown','FrontCornice',-64,64,198,204,-28,-24,'silver')
beam('Crown','BackCornice',-64,64,198,204,48,52,'silver')
beam('Crown','LeftCornice',-64,-60,198,204,-24,48,'silver')
beam('Crown','RightCornice',60,64,198,204,-24,48,'silver')
beam('Crown','CentreCap',-12,12,196,208,-30,-22,'silver')
beam('Crown','HiddenPlant',-12,12,198,202,10,26,'roof')
# Entry handles distinguish the central glazed doors beneath the canopy.
for j,x in enumerate([-2,2]):
    part('Entrance',f'DoorHandle{j}',(.4,3,.5),(x,7,-28.2),'metal',False)
beam('Entrance','Canopy',-36,36,20,26,-56,-28,'stone')
# Two column rows bound the drive lane, without obstructing it.
for j,x in enumerate([-30,30]):
    for k,z in enumerate([-54,-30]):
        beam('Entrance',f'Column{j}{k}',x-2,x+2,0,20,z-2,z+2,'stone')
# Centre portal on the fourth podium window bay (-26..50, five bays).
delivery_z=-26+(3+.5)*(76/5)
beam('Delivery','Frame',-65,-64,0,15,delivery_z-6,delivery_z+6,'metal')
beam('Delivery','Door',-65.4,-65,0,13,delivery_z-5,delivery_z+5,'roof')
beam('Delivery','Canopy',-72,-64,16,18,delivery_z-7,delivery_z+7,'stone')
for j,(x,z,w,d) in enumerate([(-55,-65,34,10),(55,-65,34,10),(-78,20,8,36),(78,38,8,24)]):
    beam('Site',f'Planter{j}Base',x-w/2,x+w/2,0,1,z-d/2,z+d/2,'stone')
    for side,xx in [('L',x-w/2),('R',x+w/2-1)]:beam('Site',f'Planter{j}{side}',xx,xx+1,1,2,z-d/2,z+d/2,'silver')
    for side,zz in [('F',z-d/2),('B',z+d/2-1)]:beam('Site',f'Planter{j}{side}',x-w/2+1,x+w/2-1,1,2,zz,zz+1,'silver')
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
    assert b[0][0]>=-88 and b[0][1]<=88 and b[2][0]>=-72 and b[2][1]<=72 and b[1][1]<=208,p
    if p['name']!='Drive' and p['name']!='Plot':
        # Whole-width clear vehicle lane under the canopy, Y0..20 and Z-52..-32.
        assert not (b[1][0]<20 and b[1][1]>0 and b[2][0]<-32 and b[2][1]>-52),p
assert max(bounds(p)[1][1] for p in parts)==208
assert max(bounds(p)[1][1] for p in parts if p['group']=='Crown' and p['name']!='CentreCap')==204
canopy=next(p for p in parts if p['name']=='Canopy' and p['group']=='Entrance')
assert canopy['size']==(72,6,28) and bounds(canopy)[1][0]==20
for i in range(10):
    g=f'Rooms{i+1:02}';floor=next(p for p in parts if p['group']==g and p['name']=='Floor')
    assert floor['size']==(120,1,72) and bounds(floor)[1][0]==36+i*16
    for a in [p for p in parts if p['group']==g and 'Glass' in p['name']]:
        ba=bounds(a)
        for b in [p for p in parts if p['group']==g and 'Glass' not in p['name']]:
            bb=bounds(b)
            assert not all(min(ba[k][1],bb[k][1])-max(ba[k][0],bb[k][0])>1e-6 for k in range(3)),(a,b)
rows=['-- Generated by tools/build_hotel.py; Phase4 GateB pending.','local Builder = {}','local Parts = {']
for p in parts:rows.append(' {'+', '.join(json.dumps(v) for v in [p['group'],p['name'],*p['size'],*p['pos'],*PALETTE[p['color']],p['collide'],p['rz'],p['rx'],p['ry'],p['shape']])+'},')
rows+=['}', '''function Builder.Build(parent,options)
 options=options or {}
 local model=Instance.new("Model");model.Name="LargeCity_CityHotel_P4"
 model:SetAttribute("LayoutId","LC-16");model:SetAttribute("Phase",4)
 model:SetAttribute("QualityGateA","Approved");model:SetAttribute("QualityGateB","Pending")
 model:SetAttribute("BuildRevision","CityHotel-P4-v1")
 local pivot=Instance.new("Part");pivot.Name="GroundPivot";pivot.Size=Vector3.new(.1,.1,.1)
 pivot.Anchored=true;pivot.Transparency=1;pivot.CanCollide=false;pivot.CanQuery=false;pivot.CanTouch=false
 pivot.Parent=model;model.PrimaryPart=pivot
 local groups={}
 for _,d in ipairs(Parts) do
  if not groups[d[1]] then local g=Instance.new("Model");g.Name=d[1];g.Parent=model;groups[d[1]]=g end
  local p=Instance.new(d[16]=="Wedge" and "WedgePart" or "Part");p.Name=d[2];p.Size=Vector3.new(d[3],d[4],d[5])
  p.CFrame=CFrame.new(d[6],d[7],d[8])*CFrame.Angles(0,0,d[13])*CFrame.Angles(d[14],0,0)*CFrame.Angles(0,d[15],0)
  p.Color=Color3.fromRGB(d[9],d[10],d[11]);p.Anchored=true;p.CanCollide=d[12]
  p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=groups[d[1]]
 end
 model.Parent=parent;model:PivotTo(options.GroundCFrame or CFrame.new());return model
end
return Builder
''']
(MOD/'LargeCityHotelGoldenMaster.lua').write_text('\n'.join(rows))
root=E.Element('roblox',version='4');counter=0
def val(pr,t,n,v):E.SubElement(pr,t,name=n).text=str(v).lower() if isinstance(v,bool) else str(v)
def item(parent,cls,name,ref=None):
    global counter
    counter+=1;it=E.SubElement(parent,'Item',{'class':cls,'referent':ref or f'RBX{counter}'})
    pr=E.SubElement(it,'Properties');val(pr,'string','Name',name);return it,pr
def vec(pr,n,v):
    c=E.SubElement(pr,'Vector3',name=n)
    for a,b in zip('XYZ',v):E.SubElement(c,a).text=str(b)
model,mp=item(root,'Model','LargeCity_CityHotel_P4');val(mp,'Ref','PrimaryPart','RBXPivot');groups={}
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
    if cls=='Part':val(pr,'token','shape',1)
    if p is pivot:val(pr,'float','Transparency',1)
meta,_=item(model,'Folder','ReviewStatus')
for n,v in [('Phase','4'),('GateB','Pending'),('LayoutId','LC-16'),('Revision','CityHotel-P4-v1')]:
    _,pr=item(meta,'StringValue',n);val(pr,'string','Value',v)
path=DEST/'LargeCityHotel_P4.rbxmx';E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
t=E.parse(path);assert len(t.findall('.//Item[@class="Part"]'))+len(t.findall('.//Item[@class="WedgePart"]'))==len(parts)+1
assert not t.findall('.//Item[@class="Script"]')
report=dict(revision='CityHotel-P4-v1',parts=len(parts)+1,storeys=12,room_storeys=10,podium=[128,80,36],rooms=[120,72,160],roof_max=204,max_height=208,canopy=[72,28,6],drive_clearance=20,plot=[176,144],gate_b='Pending',studio_test='Pending',checks=['ten room floors','twelve storeys','208 height limit','204 roof cornice','20 stud clear vehicle lane','separated window and wall volumes','plot bounds','XML roundtrip'])
(DOC/'geometry-checks.json').write_text(json.dumps(report,indent=2)+'\n')
if '--preview' in sys.argv:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont
    board=Image.new('RGB',(1800,1080),'#f4f3ed'); draw=ImageDraw.Draw(board)
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
    draw.text((900,30),'CITY HOTEL | Phase 4',font=ImageFont.truetype(bold,28),fill='#183b42',anchor='mt')
    views=[('Front / erhöht',18,-70),('Front',0,-90),('Rückseite',10,90),('Linke Seite',8,180),('Rechte Seite',8,0),('Draufsicht',90,-90)]
    for k,(title,el,az) in enumerate(views):
        elev,azim=math.radians(el),math.radians(az)
        forward=np.array([math.cos(azim)*math.cos(elev),math.sin(azim)*math.cos(elev),math.sin(elev)])
        right=np.array([-math.sin(azim),math.cos(azim),0])
        up=np.cross(forward,right)
        verts=[]; cols=[]
        for p in parts:
            x,y,z=p['pos'];w,h,d=p['size']
            if p['shape']=='Wedge':
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
    draw.text((900,1010),'12 Geschosse / Dachkante 204 / Mittelteil 208 Studs / Gate B offen',font=ImageFont.truetype(font,20),fill='#43585d',anchor='mt')
    draw.text((900,1043),'Technische Vorschau ausserhalb Studio. Symbole, Schrift, Materialtexturen und Lichtwirkung erst in Studio sichtbar.',font=ImageFont.truetype(font,16),fill='#43585d',anchor='mt')
    board.save(DOC/'geometry-review.png')
print(json.dumps(report))
