"""Issue6 Office Tower P4: native Roblox Parts and WedgePart, deterministic exports.
python3 tools/build_office.py [--preview]. No remote assets or Blender.
"""
from pathlib import Path
import math,json,sys,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/office';DEST=ROOT/'dist';MOD=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
for p in (DOC,DEST,MOD):p.mkdir(parents=True,exist_ok=True)
PALETTE={'stone':(66,70,72),'metal':(58,70,79),'glass':(54,97,125),'silver':(217,221,217),'roof':(49,57,62),'ground':(178,178,167)}
parts=[]
def part(g,n,size,pos,color='metal',collide=True,rz=0,rx=0,ry=0,shape='Block'):
    assert all(v>0 for v in size)
    parts.append(dict(group=g,name=n,size=size,pos=pos,color=color,collide=collide,rz=rz,rx=rx,ry=ry,shape=shape))
def beam(g,n,x1,x2,y1,y2,z1,z2,color='metal',collide=True):
    part(g,n,(x2-x1,y2-y1,z2-z1),((x1+x2)/2,(y1+y2)/2,(z1+z2)/2),color,collide)
# Ground pivot plot centre, front=-Z. Exact 144x128 plot.
beam('Site','Plot',-72,72,-1,0,-64,64,'ground')
# Front/rear curtain-wall fields: mullions own separate slots, glass inset .4 studs.
def frontwall(g,n,x1,x2,z,y,h,bays,col='metal',rear=False):
    pw=1.2;gap=(x2-x1-pw*(bays+1))/bays
    for j in range(bays+1):
        x=x1+j*(gap+pw);beam(g,f'{n}Pier{j}',x,x+pw,y,y+h,z,z+1.2,col)
    for j in range(bays):
        x=x1+pw+j*(gap+pw);gz=z+.4 if not rear else z+.55
        beam(g,f'{n}Glass{j}',x,x+gap,y,y+h,gz,gz+.25,'glass')
        mz=z+.2 if not rear else z+1
        part(g,f'{n}Mullion{j}',(.18,h,.15),(x+gap/2,y+h/2,mz),'metal',False)
def sidewall(g,n,x,z1,z2,y,h,bays,col='metal',right=False):
    pw=1.2;gap=(z2-z1-pw*(bays+1))/bays
    for j in range(bays+1):
        z=z1+j*(gap+pw);beam(g,f'{n}Pier{j}',x,x+1.2,y,y+h,z,z+pw,col)
    for j in range(bays):
        z=z1+pw+j*(gap+pw);gx=x+.4 if not right else x+.55
        beam(g,f'{n}Glass{j}',gx,gx+.25,y,y+h,z,z+gap,'glass')
        mx=x+.2 if not right else x+1
        part(g,f'{n}Mullion{j}',(.15,h,.18),(mx,y+h/2,z+gap/2),'metal',False)
# Podium two floors, 104x88x36. Actual central lobby recess 44wide x12deep.
for i in range(2):
    y=i*18;g=f'Podium{i+1:02}'
    beam(g,'Floor',-52,52,y,y+1.5,-44,44,'stone')
    # Roof band follows the recess; no solid front plate in front of lobby glazing.
    beam(g,'RearRoofBand',-52,52,y+16.5,y+18,-32,44,'stone')
    beam(g,'LeftRoofBand',-52,-22,y+16.5,y+18,-44,-32,'stone')
    beam(g,'RightRoofBand',22,52,y+16.5,y+18,-44,-32,'stone')
    frontwall(g,'FrontL',-52,-22,-44,y+1.5,15,2,'stone')
    frontwall(g,'FrontR',22,52,-44,y+1.5,15,2,'stone')
    frontwall(g,'Lobby',-22,22,-32,y+1.5,15,3)
    frontwall(g,'Rear',-50.8,50.8,42.8,y+1.5,15,5,'stone',True)
    sidewall(g,'Left',-52,-42.8,44,y+1.5,15,4,'stone')
    sidewall(g,'Right',50.8,-42.8,44,y+1.5,15,4,'stone',True)
    beam(g,'RecessLeftReturn',-23.2,-22,y+1.5,y+16.5,-42.8,-32,'stone')
    beam(g,'RecessRightReturn',22,23.2,y+1.5,y+16.5,-42.8,-32,'stone')
# Tower floors: 16 x16 studs; exact 72x64 envelope, no balcony.
for i in range(16):
    y=36+i*16;g=f'Office{i+1:02}'
    beam(g,'Floor',-36,36,y,y+1,-32,32)
    beam(g,'RoofBand',-36,36,y+14.5,y+16,-32,32)
    frontwall(g,'Front',-36,36,-32,y+1,13.5,4)
    frontwall(g,'Rear',-36,36,30.8,y+1,13.5,4,rear=True)
    sidewall(g,'Left',-36,-30.8,30.8,y+1,13.5,3)
    sidewall(g,'Right',34.8,-30.8,30.8,y+1,13.5,3,right=True)
# Two 4wide, 3projecting ribs, segmented per floor and crown. No strip overlaid on glass plane.
levels=[(0,18),(18,36)]+[(36+i*16,52+i*16) for i in range(16)]+[(292,324),(324,328)]
for i,(lo,hi) in enumerate(levels):
    for side,x in [('Left',-18),('Right',14)]:beam('FacadeRibs',f'{side}{i+1:02}',x,x+4,lo,hi,-35,-32,'silver')
part('Entrance','Canopy',(40,3,12),(0,19.5,-38),'silver')
# Door at recessed lobby face. Closed exterior-only entrance.
for i,x in enumerate([-5.1,5.1]):part('Entrance',f'Door{i}',(9.8,13,.3),(x,8,-32.2),'glass')
for i,x in enumerate([-1,1]):part('Entrance',f'Handle{i}',(.25,2.5,.4),(x,8,-32.7),'silver',False)
beam('Entrance','Threshold',-12,12,0,1.5,-44,-32,'ground')
# Side delivery bay on +X, away from main entry; exterior frame and closed door.
beam('Delivery','FrameBack',52,52.8,0,16,15,29,'stone')
beam('Delivery','Door',52.8,53.2,0,13,17,27,'roof')
part('Delivery','Canopy',(8,1.5,18),(56,16.75,22),'metal')
beam('Delivery','Apron',52,66,0,.1,12,32,'ground')
# Crown starts292. Technical units stay below the closed architectural crown.
beam('Crown','Base',-36,36,292,299,-32,32,'roof')
# Roblox WedgePart rises on +Z; rotation Y=pi puts the high end on the front (-Z).
part('Crown','SlopingBody',(71.6,24,64),(0,311,0),'roof',ry=math.pi,shape='Wedge')
# Cap inset is calculated to keep its full rotated bounding box within72x64, maxY324.
angle=math.atan2(24,64);thickness=1.5
length=(64-thickness*math.sin(angle))/math.cos(angle)
ey=(length*math.sin(angle)+thickness*math.cos(angle))/2
part('Crown','SilverSlopingCap',(72,thickness,length),(0,324-ey,0),'silver',rx=angle)
# Roof plant hidden in the base of the crown. It does not create extra rooftop masses.
part('Crown','HiddenPlant',(24,4,16),(0,294,8),'metal')
# Front louver placeholder separated from the crown face (detail slats in P5).
part('Crown','FrontScreen',(26,19,.35),(0,310.5,-32.2),'metal',False)
# Low planter boundaries leave both lobby and delivery paths clear.
for j,(x,z,w,d) in enumerate([(-41,-53,30,8),(41,-53,30,8),(-62,0,8,46),(61,48,18,8)]):
    beam('Site',f'Planter{j}Base',x-w/2,x+w/2,0,1,z-d/2,z+d/2,'silver')
    for side,xx in [('L',x-w/2),('R',x+w/2-1)]:beam('Site',f'Planter{j}{side}',xx,xx+1,1,3,z-d/2,z+d/2,'silver')
    for side,zz in [('F',z-d/2),('B',z+d/2-1)]:beam('Site',f'Planter{j}{side}',x-w/2+1,x+w/2-1,1,3,zz,zz+1,'silver')

def rotation(p):
    a,b,c=p['rz'],p['rx'],p['ry'];ca,sa,cb,sb,cc,sc=math.cos(a),math.sin(a),math.cos(b),math.sin(b),math.cos(c),math.sin(c)
    # Rz * Rx * Ry
    return ((ca*cc-sa*sb*sc,-sa*cb,ca*sc+sa*sb*cc),(sa*cc+ca*sb*sc,ca*cb,sa*sc-ca*sb*cc),(-cb*sc,sb,cb*cc))
def bounds(p):
    rot=rotation(p);ext=[sum(abs(rot[i][j])*p['size'][j]/2 for j in range(3)) for i in range(3)]
    return [(p['pos'][i]-ext[i],p['pos'][i]+ext[i]) for i in range(3)]
assert len({(p['group'],p['name']) for p in parts})==len(parts)
for p in parts:
    bb=bounds(p);assert bb[0][0]>=-72-1e-6 and bb[0][1]<=72+1e-6 and bb[2][0]>=-64-1e-6 and bb[2][1]<=64+1e-6 and bb[1][1]<=328+1e-6,p
for i in range(16):
    group=f'Office{i+1:02}';floor=next(p for p in parts if p['group']==group and p['name']=='Floor')
    assert floor['size']==(72,1,64) and floor['pos'][1]-.5==36+i*16
    for glass in [p for p in parts if p['group']==group and 'Glass' in p['name']]:
        a=bounds(glass)
        for other in [p for p in parts if p['group']==group and 'Glass' not in p['name']]:
            b=bounds(other);assert not all(min(a[k][1],b[k][1])-max(a[k][0],b[k][0])>1e-6 for k in range(3)),(glass['name'],other['name'])
ribs=[p for p in parts if p['group']=='FacadeRibs'];assert len(ribs)==40 and all(p['size'][0]==4 and p['size'][2]==3 for p in ribs)
assert abs(max(bounds(p)[1][1] for p in parts if p['group']=='Crown')-324)<1e-6
assert abs(max(bounds(p)[1][1] for p in parts)-328)<1e-6
rows=['-- Generated by tools/build_office.py; Phase4 GateB pending.','local Builder = {}','local Parts = {']
for p in parts:rows.append(' {'+', '.join(json.dumps(v) for v in [p['group'],p['name'],*p['size'],*p['pos'],*PALETTE[p['color']],p['collide'],p['rz'],p['rx'],p['ry'],p['shape']])+'},')
rows+=['}', '''function Builder.Build(parent,options)
 options=options or {}
 local model=Instance.new("Model");model.Name="LargeCity_OfficeTower_P4"
 model:SetAttribute("LayoutId","LC-19");model:SetAttribute("Phase",4)
 model:SetAttribute("QualityGateA","Approved");model:SetAttribute("QualityGateB","Pending")
 model:SetAttribute("BuildRevision","Office-P4-v1")
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
(MOD/'LargeCityOfficeGoldenMaster.lua').write_text('\n'.join(rows))
root=E.Element('roblox',version='4');counter=0
def val(pr,t,n,v):E.SubElement(pr,t,name=n).text=str(v).lower() if isinstance(v,bool) else str(v)
def item(parent,cls,name,ref=None):
    global counter
    counter+=1;it=E.SubElement(parent,'Item',{'class':cls,'referent':ref or f'RBX{counter}'})
    pr=E.SubElement(it,'Properties');val(pr,'string','Name',name);return it,pr
def vec(pr,n,v):
    c=E.SubElement(pr,'Vector3',name=n)
    for a,b in zip('XYZ',v):E.SubElement(c,a).text=str(b)
model,mp=item(root,'Model','LargeCity_OfficeTower_P4');val(mp,'Ref','PrimaryPart','RBXPivot');groups={}
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
for n,v in [('Phase','4'),('GateB','Pending'),('LayoutId','LC-19'),('Revision','Office-P4-v1')]:
    _,pr=item(meta,'StringValue',n);val(pr,'string','Value',v)
path=DEST/'LargeCityOfficeTower_P4.rbxmx';E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
t=E.parse(path);assert len(t.findall('.//Item[@class="Part"]'))+len(t.findall('.//Item[@class="WedgePart"]'))==len(parts)+1
assert not t.findall('.//Item[@class="Script"]')
report=dict(revision='Office-P4-v1',parts=len(parts)+1,storeys=18,office_storeys=16,podium=[104,88,36],tower=[72,64,256],crown=[72,64,32],roof_max=324,max_height=328,ribs=2,rib_segments=len(ribs),rib_width=4,rib_projection=3,canopy=[40,12,3],plot=[144,128],gate_b='Pending',studio_test='Pending',checks=['16 office floor envelopes','18 storeys','40 rib segments','separated office glass and frame volumes','rotated geometry plot bounds','roof324 and ribs328','XML roundtrip / part count','no autorun scripts'])
(DOC/'geometry-checks.json').write_text(json.dumps(report,indent=2)+'\n')

if '--preview' in sys.argv:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont
    board=Image.new('RGB',(1800,1080),'#f4f3ed'); draw=ImageDraw.Draw(board)
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
    draw.text((900,30),'OFFICE TOWER | Phase 4',font=ImageFont.truetype(bold,28),fill='#183b42',anchor='mt')
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
    draw.text((900,1010),'18 Geschosse / Dachkante 324 / Rippen 328 Studs / Gate B offen',font=ImageFont.truetype(font,20),fill='#43585d',anchor='mt')
    draw.text((900,1043),'Technische Vorschau ausserhalb Studio. Symbole, Schrift, Materialtexturen und Lichtwirkung erst in Studio sichtbar.',font=ImageFont.truetype(font,16),fill='#43585d',anchor='mt')
    board.save(DOC/'geometry-review.png')
print(json.dumps(report))
