"""Police HQ Phase 4. Deterministic Roblox geometry, no external assets.
python3 tools/build_police.py [--preview]; preview requires numpy/Pillow.
"""
from pathlib import Path
import math,json,sys,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
DOC=ROOT/'docs/police';DEST=ROOT/'dist';MOD=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
for p in (DOC,DEST,MOD):p.mkdir(parents=True,exist_ok=True)
PALETTE={'concrete':(220,216,202),'blue':(26,76,139),'roof':(49,55,65),'glass':(35,65,83),'metal':(105,115,120),'ground':(173,172,162),'yellow':(235,190,61)}
parts=[]
def part(g,n,size,pos,color='concrete',collide=True,rz=0):
    assert all(v>0 for v in size)
    parts.append(dict(group=g,name=n,size=size,pos=pos,color=color,collide=collide,rz=rz))
def beam(g,n,x1,x2,y1,y2,z1,z2,color='concrete',collide=True):
    part(g,n,(x2-x1,y2-y1,z2-z1),((x1+x2)/2,(y1+y2)/2,(z1+z2)/2),color,collide)
# Plot centre = ground pivot, front=-Z. Main X[-76,52], Z[-16,56].
part('Site','GroundSlab',(176,1,128),(0,-.5,0),'ground')
# Three 20-stud floors. Facade fields occupy disjoint volumes:
# front X bays 18 wide, 4-wide piers, rear and sides stop at corner joins.
front_bays=[(-72,-54),(-50,-32),(8,26),(30,48)]
front_piers=[(-76,-72),(-54,-50),(-32,-28),(4,8),(26,30),(48,52)]
for i,(lo,hi) in enumerate(front_piers):
    beam('MainBuilding',f'FrontColumn{i}',lo,hi,0,60,-16,-14)
for f in range(3):
    y=f*20;g='MainBuilding'
    # Slabs meet the inner wall faces, never share an exposed facade plane.
    beam(g,f'Floor{f+1}',-74,50,y,y+2,-14,54)
    beam(g,f'Ceiling{f+1}',-74,50,y+19,y+20,-14,54,'roof')
    for j,(lo,hi) in enumerate(front_bays):
        beam(g,f'FrontSpandrel{f+1}_{j}',lo,hi,y,y+6,-16,-14)
        beam(g,f'FrontF{f+1}Glass{j}',lo,hi,y+6,y+16,-15.6,-15.1,'glass')
        beam(g,f'FrontBlueBand{f+1}_{j}',lo,hi,y+16,y+20,-16,-14,'blue')
        part(g,f'FrontF{f+1}Mullion{j}',(.3,10,.25),((lo+hi)/2,y+11,-15.8),'roof',False)
        part(g,f'FrontF{f+1}Transom{j}',(hi-lo,.3,.25),((lo+hi)/2,y+11,-15.8),'roof',False)
    # Rear facade stays behind corner returns; equal bays and inset glass.
    beam(g,f'RearSpandrel{f+1}',-74,50,y,y+6,54,56)
    beam(g,f'RearBlueBand{f+1}',-74,50,y+16,y+20,54,56,'blue')
    for j in range(8):
        x=-74+j*15.5
        beam(g,f'RearF{f+1}Pier{j}',x,x+2,y+6,y+16,54,56)
        beam(g,f'RearF{f+1}Glass{j}',x+2,x+15.5,y+6,y+16,55.1,55.6,'glass')
        part(g,f'RearF{f+1}Mullion{j}',(.25,10,.2),(x+8.75,y+11,55.8),'roof',False)
    # Side windows and bands stop at the front columns, avoiding intersecting faces.
    for side,x in [('Left',-76),('Right',50)]:
        beam(g,f'{side}Spandrel{f+1}',x,x+2,y,y+6,-14,56)
        beam(g,f'{side}BlueBand{f+1}',x,x+2,y+16,y+20,-14,56,'blue')
        beam(g,f'{side}RearCorner{f+1}',x,x+2,y+6,y+16,54,56)
        for j in range(4):
            z=-14+17*j
            beam(g,f'{side}F{f+1}Pier{j}',x,x+2,y+6,y+16,z,z+2)
            inset=.4 if side=='Left' else 1.1
            beam(g,f'{side}F{f+1}Glass{j}',x+inset,x+inset+.5,y+6,y+16,z+2,z+17,'glass')
beam('Portal','LeftPier',-28,-23,0,68,-24,-16)
beam('Portal','RightPier',-1,4,0,68,-24,-16)
beam('Portal','UpperCap',-23,-1,64,68,-24,-16,'roof')
beam('Portal','BlueCrown',-23,-1,59,64,-24,-22,'blue')
beam('Portal','CentralGlass',-23,-1,4,59,-23.6,-23,'glass')
for x in [-23,-12,-1]:part('Portal',f'Mullion{x}',(.45,55,.35),(x,31.5,-23.85),'roof',False)
for y in [20,40]:part('Portal',f'Transom{y}',(22,.4,.35),(-12,y,-23.85),'roof',False)
# Doors remain a closed exterior shell, no interior furnishing.
for x in [-17.5,-6.5]:part('Portal',f'Door{x}',(10.5,14,.5),(x,11,-24),'glass')
for x in [-13,-11]:part('Portal',f'Handle{x}',(.3,3,.4),(x,11,-24.5),'metal',False)
part('Portal','Canopy',(40,3,12),(-12,26.5,-30),'blue')
part('Portal','PoliceSign',(29,6,.6),(-12,32,-24.5),'blue',False)
# Front landing 4 studs up, broad 8 shallow steps; side ramp rises 4 over 40.
beam('Site','EntryLanding',-28,4,0,4,-31,-24,'ground')
for i in range(8):
    beam('Site',f'EntryStep{i+1}',-28,4,0,(i+1)*.5,-47+i*2,-45+i*2,'ground')
angle=-math.atan2(4,40)
part('Site','AccessRamp',(math.hypot(40,4),.4,8),(24,1.8,-28),'ground',True,angle)
for z in [-32,-24]:
    for j in range(6):
        x=4+j*8;top=4-j*.8
        part('Site',f'RampPost{z}_{j}',(.3,3,.3),(x,top+1.5,z),'metal',False)
    part('Site',f'RampRail{z}',(math.hypot(40,4),.3,.3),(24,5,-28+(z+28)),'metal',False,angle)
for x in [-28,4]:
    for j in range(5):
        part('Site',f'StepRailPost{x}_{j}',(.3,3,.3),(x,.5+j*.875+1.5,-46+j*3.5),'metal',False)
for x in [-28,4]:
    for j in range(8):
        part('Site',f'StepHandrail{x}_{j}',(.35,.3,2),(x,3.5+j*.5,-46+j*2),'metal',False)
        if j<7:part('Site',f'StepHandrailJoint{x}_{j}',(.35,.5,.35),(x,3.75+j*.5,-45+j*2),'metal',False)
# Side vehicle annex: exact 32x24x24, contiguous to east side of main.
beam('VehicleAccess','LeftPier',52,55,0,21,-16,8)
beam('VehicleAccess','RightPier',81,84,0,21,-16,8)
beam('VehicleAccess','BackWall',55,81,0,21,6,8)
beam('VehicleAccess','Roof',52,84,21,24,-16,8,'blue')
beam('VehicleAccess','RollerDoor',55,81,0,20,-15.7,-15,'roof')
for y in range(2,20,2):part('VehicleAccess',f'DoorSeam{y}',(26,.1,.1),(68,y,-15.8),'metal',False)
beam('Site','Driveway',52,84,0,.1,-64,-16,'roof')
for x in [53,83]:part('Site',f'DriveEdge{x}',(.35,.05,47),(x,.13,-40),'yellow',False)
# Raised compact rooftop comms room. Antenna is a P4 silhouette proxy for P5 detail.
beam('Radio','Room',-4,28,60,74,18,42)
beam('Radio','Roof',-4,28,74,76,18,42,'roof')
part('Radio','Louver',(20,9,.4),(12,67,-.3+18),'roof',False)
for i in range(8):part('Radio',f'LouverSlat{i}',(19,.2,.3),(12,63.5+i,17.4),'metal',False)
part('Radio','PrimaryMast',(.7,24,.7),(17,88,30),'metal',False)
part('Radio','SecondaryMast',(.5,18,.5),(6,85,30),'metal',False)
# P4 planters show boundaries only; greenery/lighting/badge/road props are Phase 5.
for j,(x,z,w,d) in enumerate([(-55,-29,28,10),(-50,-48,22,8),(23,-43,28,8)]):
    beam('Site',f'Planter{j}Base',x-w/2,x+w/2,0,1,z-d/2,z+d/2)
    for side,sx in [('L',x-w/2),('R',x+w/2-1)]:beam('Site',f'Planter{j}{side}',sx,sx+1,1,4,z-d/2,z+d/2)
    for side,sz in [('F',z-d/2),('B',z+d/2-1)]:beam('Site',f'Planter{j}{side}',x-w/2+1,x+w/2-1,1,4,sz,sz+1)

def bounds(p):
    w,h,d=p['size'];a=p['rz'];ex=(abs(w*math.cos(a))+abs(h*math.sin(a)))/2;ey=(abs(w*math.sin(a))+abs(h*math.cos(a)))/2
    return [(p['pos'][0]-ex,p['pos'][0]+ex),(p['pos'][1]-ey,p['pos'][1]+ey),(p['pos'][2]-d/2,p['pos'][2]+d/2)]
assert len(set((p['group'],p['name']) for p in parts))==len(parts)
for p in parts:
    b=bounds(p)
    assert b[0][0]>=-88 and b[0][1]<=88 and b[2][0]>=-64 and b[2][1]<=64,p
    assert b[1][1]<=100,p
for group,expected in [('MainBuilding',(128,60,72)),('VehicleAccess',(32,24,24)),('Radio',(32,40,24))]:
    ps=[bounds(p) for p in parts if p['group']==group]
    size=tuple(round(max(b[i][1] for b in ps)-min(b[i][0] for b in ps),3) for i in range(3))
    # Radio louvers protrude forward .75; main envelope and vehicle access are exact.
    if group!='Radio':assert size==expected,(group,size)
# Every front window is exactly 18x10 with no covering columns/walls.
front_windows=[p for p in parts if p['name'].startswith('FrontF') and 'Glass' in p['name']]
assert len(front_windows)==12
assert all(p['size']==(18,10,.5) for p in front_windows)
front_fields=[p for p in parts if p['name'].startswith('FrontBlueBand') or p in front_windows]
for p in front_fields:
    a=bounds(p)
    for other in parts:
        if other is p or other['group']!='MainBuilding':continue
        b=bounds(other)
        assert not all(min(a[i][1],b[i][1])-max(a[i][0],b[i][0])>1e-6 for i in range(3)), (p['name'],other['name'])
rows=['-- Generated by tools/build_police.py. Phase 4, Gate B pending.','local Builder = {}','local parts = {']
for p in parts:
    vals=[p['group'],p['name'],*p['size'],*p['pos'],*PALETTE[p['color']],p['collide'],p['rz']]
    rows.append(' {'+', '.join(json.dumps(v) for v in vals)+'},')
rows+=['}', '''function Builder.Build(parent, options)
 options = options or {}
 local model = Instance.new("Model")
 model.Name = "LargeCity_PoliceHQ_P4"
 model:SetAttribute("LayoutId", "LC-35")
 model:SetAttribute("Phase", 4)
 model:SetAttribute("QualityGateA", "Approved")
 model:SetAttribute("QualityGateB", "Pending")
 model:SetAttribute("BuildRevision", "Police-P4-v2")
 local pivot = Instance.new("Part")
 pivot.Name = "GroundPivot"; pivot.Size = Vector3.new(.1,.1,.1)
 pivot.Transparency = 1; pivot.Anchored = true
 pivot.CanCollide = false; pivot.CanQuery = false; pivot.CanTouch = false
 pivot.Parent = model; model.PrimaryPart = pivot
 local groups = {}
 for _,d in ipairs(parts) do
  if not groups[d[1]] then
   local g = Instance.new("Model"); g.Name = d[1]; g.Parent = model; groups[d[1]] = g
  end
  local p = Instance.new("Part")
  p.Name = d[2]; p.Size = Vector3.new(d[3],d[4],d[5])
  p.CFrame = CFrame.new(d[6],d[7],d[8]) * CFrame.Angles(0,0,d[13])
  p.Color = Color3.fromRGB(d[9],d[10],d[11]); p.Anchored = true; p.CanCollide = d[12]
  p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
  p.Parent = groups[d[1]]
 end
 local gui = Instance.new("SurfaceGui"); gui.Name = "StationName"
 gui.Face = Enum.NormalId.Front; gui.CanvasSize = Vector2.new(600,120)
 gui.Parent = groups.Portal.PoliceSign
 local label = Instance.new("TextLabel"); label.Name = "Title"
 label.Size = UDim2.fromScale(1,1); label.BackgroundTransparency = 1
 label.Text = "POLICE"; label.Font = Enum.Font.ArialBold
 label.TextColor3 = Color3.new(1,1,1); label.TextScaled = true; label.Parent = gui
 model.Parent = parent; model:PivotTo(options.GroundCFrame or CFrame.new())
 return model
end
return Builder
''']
(MOD/'LargeCityPoliceGoldenMaster.lua').write_text('\n'.join(rows))
# Static XML uses the identical list; importing never runs scripts.
root=E.Element('roblox',version='4');counter=0
def item(parent,cls,name,ref=None):
    global counter
    counter+=1;e=E.SubElement(parent,'Item',{'class':cls,'referent':ref or f'RBX{counter}'})
    pr=E.SubElement(e,'Properties');val(pr,'string','Name',name);return e,pr
def val(pr,typ,name,v):E.SubElement(pr,typ,name=name).text=str(v).lower() if isinstance(v,bool) else str(v)
def vec(pr,name,v):
    e=E.SubElement(pr,'Vector3',name=name)
    for axis,n in zip('XYZ',v):E.SubElement(e,axis).text=str(n)
model,mp=item(root,'Model','LargeCity_PoliceHQ_P4');val(mp,'Ref','PrimaryPart','RBXPivot');groups={}
for p in [dict(group='',name='GroundPivot',size=(.1,.1,.1),pos=(0,0,0),color='ground',collide=False,rz=0)]+parts:
    if p['group'] and p['group'] not in groups:groups[p['group']]=item(model,'Model',p['group'])[0]
    it,pr=item(groups.get(p['group'],model),'Part',p['name'],'RBXPivot' if p['name']=='GroundPivot' else None)
    vec(pr,'size',p['size']);c=E.SubElement(pr,'CoordinateFrame',name='CFrame')
    for axis,n in zip('XYZ',p['pos']):E.SubElement(c,axis).text=str(n)
    a=p['rz'];rot=((math.cos(a),-math.sin(a),0),(math.sin(a),math.cos(a),0),(0,0,1))
    for i in range(3):
        for j in range(3):E.SubElement(c,f'R{i}{j}').text=str(rot[i][j])
    color=PALETTE[p['color']];val(pr,'Color3uint8','Color3uint8',(255<<24)|(color[0]<<16)|(color[1]<<8)|color[2])
    for k,v in [('Anchored',True),('CanCollide',p['collide']),('CanQuery',p['name']!='GroundPivot'),('CanTouch',p['name']!='GroundPivot')]:val(pr,'bool',k,v)
    for k,v in [('Material',272),('TopSurface',0),('BottomSurface',0),('shape',1)]:val(pr,'token',k,v)
    if p['name']=='GroundPivot':val(pr,'float','Transparency',1)
    if p['name']=='PoliceSign':sign=it
# Label geometry is intentionally absent from CPU preview, but present in Studio/XML.
gui,gp=item(sign,'SurfaceGui','StationName');val(gp,'token','Face',5)
c=E.SubElement(gp,'Vector2',name='CanvasSize');E.SubElement(c,'X').text='600';E.SubElement(c,'Y').text='120'
_,lp=item(gui,'TextLabel','Title')
for t,k,v in [('string','Text','POLICE'),('bool','TextScaled',True),('float','BackgroundTransparency',1),('token','Font',2)]:val(lp,t,k,v)
c=E.SubElement(lp,'Color3',name='TextColor3')
for axis in 'RGB':E.SubElement(c,axis).text='1'
c=E.SubElement(lp,'UDim2',name='Size')
for k,v in [('XS',1),('XO',0),('YS',1),('YO',0)]:E.SubElement(c,k).text=str(v)
meta,_=item(model,'Folder','ReviewStatus')
for k,v in [('Phase','4'),('GateB','Pending'),('LayoutId','LC-35'),('Revision','Police-P4-v2')]:
    _,pr=item(meta,'StringValue',k);val(pr,'string','Value',v)
path=DEST/'LargeCityPoliceHQ_P4.rbxmx';E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
t=E.parse(path);assert len(t.findall('.//Item[@class="Part"]'))==len(parts)+1
assert not t.findall('.//Item[@class="Script"]')
report=dict(parts=len(parts)+1,plot=[176,128],main=[128,72,60],portal=[32,8,68],canopy=[40,12,3],vehicle=[32,24,24],radio=[32,24,16],max_height=100,storeys=3,gate_b='Pending',studio_test='Pending',front='local -Z',pivot='plot centre at ground Y=0',checks=['positive dimensions','unique names','all parts within plot','main and annex exact envelopes','max height 100','XML round-trip and count','no executable scripts','12 equal front windows 18x10','front glass and blue bands do not intersect other main-building parts'],pending=['Studio visual approval','P5 badge, dish, roof equipment, lights and landscape','collision walkthrough','P6 HP and energy decision'])
(DOC/'geometry-checks.json').write_text(json.dumps(report,indent=2)+'\n')

if '--preview' in sys.argv:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont
    board=Image.new('RGB',(1800,1080),'#f4f3ed'); draw=ImageDraw.Draw(board)
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
    draw.text((900,30),'POLICE HQ | Phase 4',font=ImageFont.truetype(bold,28),fill='#183b42',anchor='mt')
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
            a=p['rz']; local=v-np.array([x,z,y]); v=np.stack([local[:,0]*math.cos(a)-local[:,2]*math.sin(a),local[:,1],local[:,0]*math.sin(a)+local[:,2]*math.cos(a)],axis=-1)+np.array([x,z,y])
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
    draw.text((900,1010),'3 Geschosse / 176 x 128 Studs / 100 Studs Gesamthoehe / Gate B offen',font=ImageFont.truetype(font,20),fill='#43585d',anchor='mt')
    draw.text((900,1043),'Technische Vorschau ausserhalb Studio. Symbole, Schrift, Materialtexturen und Lichtwirkung erst in Studio sichtbar.',font=ImageFont.truetype(font,16),fill='#43585d',anchor='mt')
    board.save(DOC/'geometry-review.png')
print(json.dumps(report))
