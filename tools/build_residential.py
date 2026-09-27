"""Issue 5 Residential Tower: P4, deterministic native Roblox Parts and XML.
python3 tools/build_residential.py [--preview]. No Blender or remote assets.
"""
from pathlib import Path
import math,json,sys,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/residential';DEST=ROOT/'dist';MOD=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
for p in (DOC,DEST,MOD):p.mkdir(parents=True,exist_ok=True)
PALETTE={'concrete':(226,221,206),'sand':(198,183,160),'roof':(49,56,62),'glass':(42,64,72),'metal':(85,100,105),'ground':(176,174,163),'yellow':(230,185,62)}
parts=[]
def part(g,n,size,pos,color='concrete',collide=True,rz=0,rx=0):
    assert all(v>0 for v in size)
    parts.append(dict(group=g,name=n,size=size,pos=pos,color=color,collide=collide,rz=rz,rx=rx))
def beam(g,n,x1,x2,y1,y2,z1,z2,color='concrete',collide=True):
    part(g,n,(x2-x1,y2-y1,z2-z1),((x1+x2)/2,(y1+y2)/2,(z1+z2)/2),color,collide)
# Plot centre ground pivot; front=-Z. Intentionally open garage cut on the right.
beam('Site','GroundWest',-64,44,-1,0,-56,56,'ground')
beam('Site','GroundEast',62,64,-1,0,-56,56,'ground')
beam('Site','GroundFront',44,62,-1,0,-56,-48,'ground')
beam('Site','GroundRear',44,62,-1,0,16,56,'ground')
# Podium 96x80x32: X[-54,42], Z[-32,48]. Tower centre (-6,4).
def level(g,w,d,y,h,bays=3):
    left=-6-w/2;right=-6+w/2;front=4-d/2;back=4+d/2
    beam(g,'Floor',left,right,y,y+1.5,front,back)
    beam(g,'RoofBand',left,right,y+h-1.5,y+h,front,back)
    gap=(w-4*(bays+1))/bays
    for side,z in [('Front',front),('Rear',back-2)]:
        for j in range(bays+1):
            x=left+j*(gap+4)
            beam(g,f'{side}Pier{j}',x,x+4,y+1.5,y+h-1.5,z,z+2,'sand' if j in [1,2] else 'concrete')
        for j in range(bays):
            x=left+4+j*(gap+4)
            glassz=z+.4 if side=='Front' else z+1.1
            beam(g,f'{side}Glass{j}',x,x+gap,y+1.5,y+h-1.5,glassz,glassz+.5,'glass')
            # Mullions remain ahead of glass, inside their own window opening.
            facez=z+.18 if side=='Front' else z+1.82
            part(g,f'{side}Mullion{j}',(.25,h-3,.18),(x+gap/2,y+h/2,facez),'metal',False)
    # Side panels exclude front/rear corner volumes completely.
    gapz=(d-4-6)/2
    for side,x in [('Left',left),('Right',right-2)]:
        for j in range(3):
            z=front+2+j*(gapz+2)
            beam(g,f'{side}Pier{j}',x,x+2,y+1.5,y+h-1.5,z,z+2)
        for j in range(2):
            z=front+4+j*(gapz+2);glassx=x+.4 if side=='Left' else x+1.1
            beam(g,f'{side}Glass{j}',glassx,glassx+.5,y+1.5,y+h-1.5,z,z+gapz,'glass')
    return left,right,front,back
level('Podium01',96,80,0,16)
level('Podium02',96,80,16,16)
# Readable double-height entry bay, closed exterior shell with recessed door panes.
beam('Entrance','Landing',-22,10,0,2,-38,-32,'ground')
for i in range(4):beam('Entrance',f'Step{i}',-22,10,0,(i+1)*.5,-46+i*2,-44+i*2,'ground')
part('Entrance','Canopy',(36,1.5,10),(-6,15.25,-37),'roof')
for x in [-13.25,1.25]:part('Entrance',f'Door{x}',(14,12,.45),(x,8,-32.1),'glass')
for x in [-7,-5]:part('Entrance',f'Handle{x}',(.25,2,.4),(x,8,-32.55),'metal',False)
# Each regular floor has 6-stud projecting front/rear balconies and alternating corner returns.
def balcony(g,n,x1,x2,z1,z2,y,edge):
    beam(g,n+'Slab',x1,x2,y,y+2.2,z1,z2)
    # P4 railing skeleton: robust top rail and three uprights, infill is P5.
    if edge in ['front','rear']:
        zz=z1+.2 if edge=='front' else z2-.2
        part(g,n+'Rail',(x2-x1,.25,.25),((x1+x2)/2,y+5.2,zz),'metal',False)
        for j,x in enumerate([x1+.2,(x1+x2)/2,x2-.2]):part(g,n+f'Post{j}',(.25,3,.25),(x,y+3.7,zz),'metal',False)
        for label,x in [('L',x1+.2),('R',x2-.2)]:part(g,n+label+'Return',(.25,.25,z2-z1),(x,y+5.2,(z1+z2)/2),'metal',False)
    else:
        xx=x1+.2 if edge=='left' else x2-.2
        part(g,n+'Rail',(.25,.25,z2-z1),(xx,y+5.2,(z1+z2)/2),'metal',False)
        for j,z in enumerate([z1+.2,(z1+z2)/2,z2-.2]):part(g,n+f'Post{j}',(.25,3,.25),(xx,y+3.7,z),'metal',False)
for i in range(10):
    y=32+16*i;g=f'Residence{i+1:02}'
    l,r,f,b=level(g,64,56,y,16)
    for side,a,c in [('L',l,l+22),('R',r-22,r)]:
        balcony(g,'Front'+side,a,c,f-6,f,y,'front')
        balcony(g,'Rear'+side,a,c,b,b+6,y,'rear')
    # Alternation is ordered: front-left/rear-right, then rear-left/front-right.
    zlo,zhi=(f,f+20) if i%2==0 else (b-20,b)
    balcony(g,'LeftCorner',l-6,l,zlo,zhi,y,'left')
    zlo,zhi=(b-20,b) if i%2==0 else (f,f+20)
    balcony(g,'RightCorner',r,r+6,zlo,zhi,y,'right')
# Roof terrace rings sit above the lower roof, with no overlapping hidden full plate.
def terrace(g,n,outerw,outerd,innerw,innerd,y):
    l=-6-outerw/2;r=-6+outerw/2;f=4-outerd/2;b=4+outerd/2
    il=-6-innerw/2;ir=-6+innerw/2;inf=4-innerd/2;inb=4+innerd/2
    beam(g,n+'FrontDeck',l,r,y,y+.3,f,inf,'ground')
    beam(g,n+'RearDeck',l,r,y,y+.3,inb,b,'ground')
    beam(g,n+'LeftDeck',l,il,y,y+.3,inf,inb,'ground')
    beam(g,n+'RightDeck',ir,r,y,y+.3,inf,inb,'ground')
    for label,z in [('Front',f+.3),('Rear',b-.3)]:
        part(g,n+label+'Rail',(outerw-.6,.25,.25),(-6,y+3.3,z),'metal',False)
        for j,x in enumerate([l+.3,-6,r-.3]):part(g,n+label+f'Post{j}',(.25,3,.25),(x,y+1.8,z),'metal',False)
    for label,x in [('Left',l+.3),('Right',r-.3)]:
        part(g,n+label+'Rail',(.25,.25,outerd-.6),(x,y+3.3,4),'metal',False)
        part(g,n+label+'Post',(.25,3,.25),(x,y+1.8,4),'metal',False)
terrace('PodiumTerrace','Podium',96,80,64,56,32)
level('Setback01',56,48,192,16)
terrace('Setback01','Terrace',64,56,56,48,192)
level('Setback02',48,40,208,16)
terrace('Setback02','Terrace',56,48,48,40,208)
# Compact rooftop block only, no antenna/crown. Exact top Y=232.
beam('RoofEquipment','PlantRoom',-18,6,224,231,-4,12,'roof')
beam('RoofEquipment','PlantRoomCap',-18,6,231,232,-4,12,'roof')
# Ramp centreline z=-48,y=0 to z=0,y=-8 (1:6). Closed by gate beyond bottom landing.
# Local X rotation slopes down as Z increases: sin(rx)>0 sends Z toward -Y.
rx=math.atan2(8,48)
part('Garage','Ramp',(18,.5,math.hypot(48,8)),(53,-4-.25*math.cos(rx),-24-.25*math.sin(rx)),'roof',True,rx=rx)
beam('Garage','BottomLanding',44,62,-8.5,-8,0,16,'roof')
beam('Garage','InnerRetainingWall',42,44,-9,1,-48,16,'concrete')
beam('Garage','OuterRetainingWall',62,64,-9,1,-48,16,'concrete')
beam('Garage','Gate',44,62,-8,2,15,16,'roof')
beam('Garage','GateLintel',44,62,2,4,13,16)
# Planter trough outlines; planting and accent lighting are Phase 5.
for i,(x,z,w,d) in enumerate([(-40,-43,28,10),(27,-43,24,10),(-58,5,8,48)]):
    beam('Site',f'Planter{i}Base',x-w/2,x+w/2,0,1,z-d/2,z+d/2)
    for side,xx in [('L',x-w/2),('R',x+w/2-1)]:beam('Site',f'Planter{i}{side}',xx,xx+1,1,3,z-d/2,z+d/2)
    for side,zz in [('F',z-d/2),('B',z+d/2-1)]:beam('Site',f'Planter{i}{side}',x-w/2+1,x+w/2-1,1,3,zz,zz+1)

def rotation(p):
    a=p['rz'];b=p['rx'];ca,sa,cb,sb=math.cos(a),math.sin(a),math.cos(b),math.sin(b)
    return ((ca,-sa*cb,sa*sb),(sa,ca*cb,-ca*sb),(0,sb,cb))
def bounds(p):
    rot=rotation(p);ext=[sum(abs(rot[i][j])*p['size'][j]/2 for j in range(3)) for i in range(3)]
    return [(p['pos'][i]-ext[i],p['pos'][i]+ext[i]) for i in range(3)]
assert len(set((p['group'],p['name']) for p in parts))==len(parts)
for p in parts:
    bb=bounds(p)
    assert bb[0][0]>=-64-1e-6 and bb[0][1]<=64+1e-6 and bb[2][0]>=-56 and bb[2][1]<=56,p
    assert bb[1][1]<=232,p
# Validate the approved dimensions, excluding exterior balcony/terrace add-ons.
for group,w,d,y,h in [('Podium01',96,80,0,16),('Podium02',96,80,16,16)]+[(f'Residence{i+1:02}',64,56,32+i*16,16) for i in range(10)]+[('Setback01',56,48,192,16),('Setback02',48,40,208,16)]:
    floor=next(p for p in parts if p['group']==group and p['name']=='Floor');assert floor['size']==(w,1.5,d)
    cap=next(p for p in parts if p['group']==group and p['name']=='RoofBand');assert cap['pos'][1]+.75==y+h
    # Window sheets have no volume overlap with structural facade piers.
    for glass in [p for p in parts if p['group']==group and 'Glass' in p['name']]:
        a=bounds(glass)
        for pier in [p for p in parts if p['group']==group and 'Pier' in p['name']]:
            b=bounds(pier);assert not all(min(a[i][1],b[i][1])-max(a[i][0],b[i][0])>1e-6 for i in range(3)),(glass,pier)
assert len([p for p in parts if p['group'].startswith('Residence') and p['name']=='Floor'])==10
assert len([p for p in parts if p['name'].startswith(('Front','Rear')) and p['name'].endswith('Slab')])==40
assert all(p['size'][2]==6 for p in parts if p['name'].startswith(('Front','Rear')) and p['name'].endswith('Slab'))
assert all(p['size'][0]==6 for p in parts if p['name'] in ['LeftCornerSlab','RightCornerSlab'])
# Lua builder and native XML share the exact parts list, including full rotations.
rows=['-- Generated by tools/build_residential.py; Phase 4 / Gate B user-approved 2026-09-27.','local Builder = {}','local Parts = {']
for p in parts:rows.append(' {'+', '.join(json.dumps(v) for v in [p['group'],p['name'],*p['size'],*p['pos'],*PALETTE[p['color']],p['collide'],p['rz'],p['rx']])+'},')
rows+=['}', '''function Builder.Build(parent, options)
 options = options or {}
 local model = Instance.new("Model"); model.Name = "LargeCity_ResidentialTower_P4"
 model:SetAttribute("LayoutId","LC-14"); model:SetAttribute("Phase",4)
 model:SetAttribute("QualityGateA","Approved"); model:SetAttribute("QualityGateB","ApprovedByUser")
 model:SetAttribute("BuildRevision","Residential-P4-v1")
 model:SetAttribute("GarageRequiresTerrainCut",true)
 local pivot=Instance.new("Part"); pivot.Name="GroundPivot"; pivot.Size=Vector3.new(.1,.1,.1)
 pivot.Transparency=1; pivot.Anchored=true; pivot.CanCollide=false; pivot.CanQuery=false; pivot.CanTouch=false
 pivot.Parent=model; model.PrimaryPart=pivot
 local groups={}
 for _,d in ipairs(Parts) do
  if not groups[d[1]] then local g=Instance.new("Model"); g.Name=d[1]; g.Parent=model; groups[d[1]]=g end
  local p=Instance.new("Part"); p.Name=d[2]; p.Size=Vector3.new(d[3],d[4],d[5])
  p.CFrame=CFrame.new(d[6],d[7],d[8])*CFrame.Angles(0,0,d[13])*CFrame.Angles(d[14],0,0)
  p.Color=Color3.fromRGB(d[9],d[10],d[11]); p.Anchored=true; p.CanCollide=d[12]
  p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=groups[d[1]]
 end
 model.Parent=parent; model:PivotTo(options.GroundCFrame or CFrame.new()); return model
end
return Builder
''']
(MOD/'LargeCityResidentialGoldenMaster.lua').write_text('\n'.join(rows))
root=E.Element('roblox',version='4');counter=0
def val(pr,t,n,v):E.SubElement(pr,t,name=n).text=str(v).lower() if isinstance(v,bool) else str(v)
def item(parent,cls,name,ref=None):
    global counter
    counter+=1;it=E.SubElement(parent,'Item',{'class':cls,'referent':ref or f'RBX{counter}'})
    pr=E.SubElement(it,'Properties');val(pr,'string','Name',name);return it,pr
def vec(pr,n,v):
    c=E.SubElement(pr,'Vector3',name=n)
    for a,b in zip('XYZ',v):E.SubElement(c,a).text=str(b)
model,mp=item(root,'Model','LargeCity_ResidentialTower_P4');val(mp,'Ref','PrimaryPart','RBXPivot');groups={}
pivot=dict(group='',name='GroundPivot',size=(.1,.1,.1),pos=(0,0,0),color='ground',collide=False,rx=0,rz=0)
for p in [pivot]+parts:
    if p['group'] and p['group'] not in groups:groups[p['group']]=item(model,'Model',p['group'])[0]
    it,pr=item(groups.get(p['group'],model),'Part',p['name'],'RBXPivot' if p is pivot else None)
    vec(pr,'size',p['size']);cf=E.SubElement(pr,'CoordinateFrame',name='CFrame')
    for a,b in zip('XYZ',p['pos']):E.SubElement(cf,a).text=str(b)
    rot=rotation(p)
    for i in range(3):
        for j in range(3):E.SubElement(cf,f'R{i}{j}').text=str(rot[i][j])
    col=PALETTE[p['color']];val(pr,'Color3uint8','Color3uint8',(255<<24)|(col[0]<<16)|(col[1]<<8)|col[2])
    for n,v in [('Anchored',True),('CanCollide',p['collide']),('CanQuery',p is not pivot),('CanTouch',p is not pivot)]:val(pr,'bool',n,v)
    for n,v in [('Material',272),('TopSurface',0),('BottomSurface',0),('shape',1)]:val(pr,'token',n,v)
    if p is pivot:val(pr,'float','Transparency',1)
meta,_=item(model,'Folder','ReviewStatus')
for n,v in [('Phase','4'),('GateB','ApprovedByUser 2026-09-27'),('LayoutId','LC-14'),('Revision','Residential-P4-v1'),('GarageTerrainCut','Required: local X44..62 Z-48..16 Y-9..0')]:
    _,pr=item(meta,'StringValue',n);val(pr,'string','Value',v)
path=DEST/'LargeCityResidentialTower_P4.rbxmx';E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
t=E.parse(path);assert len(t.findall('.//Item[@class="Part"]'))==len(parts)+1
assert not t.findall('.//Item[@class="Script"]')
report=dict(revision='Residential-P4-v1',parts=len(parts)+1,storeys=14,regular_residential=10,setbacks=2,podium=[96,80,32],tower=[64,56,160],setback_1=[56,48,16],setback_2=[48,40,16],roof=[24,16,8],balcony_projection=6,height=232,plot=[128,112],gate_b='ApprovedByUser 2026-09-27',studio_test='P4 confirmed by user',garage_floor_y=-8,terrain_cut={'x':[44,62],'z':[-48,16],'y':[-9,0]},checks=['14 exact floor envelopes','all front/rear balconies 6 studs','windows do not intersect piers','plot and height bounds including rotated ramp','XML count','no autorun scripts'])
(DOC/'geometry-checks.json').write_text(json.dumps(report,indent=2)+'\n')

if '--preview' in sys.argv:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont
    board=Image.new('RGB',(1800,1080),'#f4f3ed'); draw=ImageDraw.Draw(board)
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
    draw.text((900,30),'RESIDENTIAL TOWER | Phase 4',font=ImageFont.truetype(bold,28),fill='#183b42',anchor='mt')
    views=[('Front / erhöht',18,-70),('Front',0,-90),('Rückseite',10,90),('Linke Seite',8,180),('Rechte Seite',8,0),('Draufsicht',90,-90)]
    for k,(title,el,az) in enumerate(views):
        elev,azim=math.radians(el),math.radians(az)
        forward=np.array([math.cos(azim)*math.cos(elev),math.sin(azim)*math.cos(elev),math.sin(elev)])
        right=np.array([-math.sin(azim),math.cos(azim),0])
        up=np.cross(forward,right)
        verts=[]; cols=[]
        for p in parts:
            x,y,z=p['pos'];w,h,d=p['size']
            v=np.array([[x+sx*w/2,z+sz*d/2,y+sy*h/2] for sx,sz,sy in [(-1,-1,-1),(1,-1,-1),(1,1,-1),(-1,1,-1),(-1,-1,1),(1,-1,1),(1,1,1),(-1,1,1)]])
            a=p['rz']; local=v-np.array([x,z,y]); rx=p['rx']; ly=local[:,2].copy(); lz=local[:,1].copy(); local[:,2]=ly*math.cos(rx)-lz*math.sin(rx); local[:,1]=ly*math.sin(rx)+lz*math.cos(rx); v=np.stack([local[:,0]*math.cos(a)-local[:,2]*math.sin(a),local[:,1],local[:,0]*math.sin(a)+local[:,2]*math.cos(a)],axis=-1)+np.array([x,z,y])
            for inds,shade in zip([[0,1,2,3],[4,5,6,7],[0,1,5,4],[1,2,6,5],[2,3,7,6],[3,0,4,7]],[.5,1,.8,.68,.7,.64]):
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
    draw.text((900,1010),'14 Geschosse / 128 x 112 Studs / 232 Studs Gesamthoehe / Gate B freigegeben',font=ImageFont.truetype(font,20),fill='#43585d',anchor='mt')
    draw.text((900,1043),'Technische Vorschau ausserhalb Studio. Symbole, Schrift, Materialtexturen und Lichtwirkung erst in Studio sichtbar.',font=ImageFont.truetype(font,16),fill='#43585d',anchor='mt')
    board.save(DOC/'geometry-review.png')
print(json.dumps(report))
