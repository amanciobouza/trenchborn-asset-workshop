"""Reproducible Phase-4 geometry and Phase-5 dressing, Roblox XML and Luau builder. No Blender.
Run from repo root: python3 tools/build_emberline.py [--preview]
Python standard library suffices for exports; preview additionally uses numpy and Pillow.
"""
from pathlib import Path
import json, sys, math, xml.etree.ElementTree as E

ROOT=Path(__file__).resolve().parents[1]
DEST=ROOT/'dist'; DEST.mkdir(exist_ok=True)
MOD=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'; MOD.mkdir(parents=True,exist_ok=True)
DOC=ROOT/'docs/emberline'; DOC.mkdir(parents=True,exist_ok=True)
NAME='LargeCity_EmberlineResponseHQ_P5'
PALETTE={'concrete':(225,222,209),'red':(177,31,40),'roof':(57,62,65),
 'glass':(39,65,71),'yellow':(234,186,51),'ground':(162,162,153),'metal':(98,107,109)}
parts=[]
def part(group,name,size,pos,color='concrete',collide=True):
    assert all(v>0 for v in size)
    parts.append(dict(group=group,name=name,size=size,pos=pos,color=color,collide=collide))
def beam(g,n,x1,x2,y1,y2,z1,z2,color='concrete',collide=True):
    part(g,n,(x2-x1,y2-y1,z2-z1),((x1+x2)/2,(y1+y2)/2,(z1+z2)/2),color,collide)

# Ground pivot: (0,0,0). Front: local -Z. All structural heights start at Y=0.
part('Site','GroundSlab',(176,1,112),(0,-.5,0),'ground')
part('Site','ResponseApron',(176,.08,40),(0,.04,-36),'ground')
hall='VehicleHall'; admin='Administration'; tower='TrainingTower'
# Exact hall envelope: X[-84,12], Z[-12,52], Y[0,40].
beam(hall,'RearWall',-84,12,0,38,50,52)
beam(hall,'LeftWall',-84,-82,0,38,-12,50)
beam(hall,'RightWall',10,12,0,38,-12,50)
beam(hall,'Floor',-82,10,0,1,-12,50)
beam(hall,'Roof',-84,12,38,40,-12,52,'roof')
beam(hall,'FrontLintel',-84,12,30,38,-12,-10)
centers=[]
for i in range(5):
    x=-84+i*22.8
    beam(hall,f'Pier_{i+1:02}',x,x+4.8,0,30,-12,-9)
for i in range(4):
    x=-70.2+22.8*i;centers.append(x)
    # Four independent closed roller-door assemblies, with real separate glazing band.
    g=f'BayDoor_{i+1:02}'
    beam(g,'LowerPanel',x-9,x+9,0,8,-11.9,-11,'red')
    beam(g,'WindowBand',x-9,x+9,8,11,-11.7,-11.1,'glass')
    beam(g,'UpperPanel',x-9,x+9,11,30,-11.9,-11,'red')
    for j in range(1,5):
        part(g,f'WindowMullion_{j}',(.2,3,.12),(x-9+3.6*j,9.5,-11.81),'metal',False)
    for j,y in enumerate([4,15,19,23,27]):
        part(g,f'RollerSeam_{j}',(18,.1,.08),(x,y,-11.98),'roof',False)
    # Four marked exit zones, each clear of posts and planters.
    for side in [-1,1]:
        part('Site',f'Exit_{i+1}_Edge_{side}',(.35,.05,35),(x+side*9.4,.105,-34.5),'yellow',False)
    part('Site',f'Exit_{i+1}_End',(19.15,.05,.35),(x,.105,-52),'yellow',False)
part('Signage','HallSign',(91,5.8,.5),(-36,34.1,-12.3),'red',False)
# Two-storey administration: X[12,60], Z[-12,52], Y[0,40].
for label,y1,y2 in [('Base',0,3),('MidSpandrel',16,23),('UpperSpandrel',35,38)]:
    beam(admin,label,12,60,y1,y2,-12,52)
beam(admin,'Roof',12,60,38,40,-12,52,'roof')
for floor,(lo,hi) in enumerate([(3,16),(23,35)],1):
    for side,z in [('Front',-12),('Rear',51)]:
        for j in range(4):
            x=12+12*j
            beam(admin,f'{side}F{floor}Pier{j}',x,x+1,lo,hi,z,z+1)
            # Glazing is a separate sheet between piers, not a coplanar wall overlay.
            beam(admin,f'{side}F{floor}Glass{j}',x+1,x+12,lo,hi,z+.12,z+.5,'glass')
    for side,x in [('Left',12),('Right',59)]:
        for j in range(4):
            z=-11+j*15.5
            beam(admin,f'{side}F{floor}Pier{j}',x,x+1,lo,hi,z,z+1)
            beam(admin,f'{side}F{floor}Glass{j}',x+.15,x+.65,lo,hi,z+1,z+15.5,'glass')
# Distinct front portal overlays the ground-level band; closed exterior-only entrance.
beam(admin,'EntryLeft',28,31,0,18,-13,-11)
beam(admin,'EntryRight',43,46,0,18,-13,-11)
beam(admin,'EntryDoor',31,43,0,14,-12.8,-12.4,'glass')
part(admin,'EntryDoorMullion',(.25,14,.3),(37,7,-12.95),'metal')
for x in [35.7,38.3]:part(admin,f'EntryHandle_{x}',(.2,3,.35),(x,7,-13.15),'metal',False)
part(admin,'EntryCanopy',(30,1.5,12),(37,18.5,-18),'red')
part(admin,'CanopyCap',(30,.35,12),(37,19.425,-18),'roof',False)
for x in [24,50]:part(admin,f'CanopyColumn_{x}',(1.2,17.75,1.2),(x,8.875,-21))
part(admin,'FrontRedBand',(48,2,.3),(36,21,-12.15),'red',False)
part(admin,'UpperRedBand',(48,2,.3),(36,36.5,-12.15),'red',False)
# Training tower: genuine six open drill bays, not black rectangles on a solid box.
# X[60,84], Z[-12,20], roof cap ends at 93; antenna tip ends at 96.
beam(tower,'BackWall',60,84,0,85,18,20)
beam(tower,'LeftWall',60,62,0,85,-12,18)
beam(tower,'RightWall',82,84,0,85,-12,18)
beam(tower,'FrontLeftPier',62,67,0,85,-12,-10)
beam(tower,'FrontRightPier',77,82,0,85,-12,-10)
for level in range(6):
    y=level*14
    g=f'TowerLevel_{level+1:02}'
    beam(g,'Floor',62,82,y,y+1,-12,18)
    beam(g,'FrontSill',67,77,y+1,y+3,-12,-10)
    beam(g,'FrontLintel',67,77,y+13,y+14,-12,-10)
    # Rails end exactly at the piers and sit within the structural footprint.
    part(g,'SafetyTopRail',(10,.3,.3),(72,y+6,-11.5),'yellow')
    part(g,'SafetyMidRail',(10,.2,.25),(72,y+4.6,-11.5),'yellow')
    for j,x in enumerate([67.3,69.65,72,74.35,76.7]):
        part(g,f'SafetyUpright_{j}',(.22,3,.22),(x,y+4.5,-11.5),'yellow')
beam(tower,'CrownBase',60,84,84,86,-12,20)
beam(tower,'RedCrown',60,84,86,91,-12,20,'red')
beam(tower,'RoofCap',60,84,91,93,-12,20,'roof')
part(tower,'Antenna',(.3,3,.3),(72,94.5,4),'metal',False)
# Narrow left technical strip, constrained by the approved 176-stud plot width.
part('Service','Cabinet',(3,7,12),(-86,3.5,27),'roof')
for z in [19,35]:
    part('Service',f'FencePost_{z}',(.25,8,.25),(-87.7,4,z),'metal')
part('Service','FenceTop',(.25,.25,16),(-87.7,7.9,27),'metal')
for z in range(20,35,2):part('Service',f'FenceBar_{z}',(.12,7.5,.12),(-87.7,3.75,z),'metal',False)

base_parts=list(parts)
from emberline_dressing import PALETTE as EXTRA_PALETTE, MATERIALS, additions, FRAMES
PALETTE.update(EXTRA_PALETTE)
lights,symbols=additions(part)
dressing_parts=parts[len(base_parts):]

# Geometry acceptance checks independent of the output serializer.
assert len([p for p in parts if p['group'].startswith('BayDoor_') and p['name']=='LowerPanel'])==4
assert len([p for p in parts if p['group'].startswith('TowerLevel_') and p['name']=='Floor'])==6
assert len({(p['group'],p['name']) for p in parts})==len(parts)
for p in parts:
    x,y,z=p['pos'];w,h,d=p['size']
    assert x-w/2>=-88-1e-6 and x+w/2<=88+1e-6,p
    assert z-d/2>=-56-1e-6 and z+d/2<=56+1e-6,p
    assert y+h/2<=96+1e-6,p
def envelope(groups):
    ps=[p for p in parts if p['group'] in groups]
    return [[min(p['pos'][i]-p['size'][i]/2 for p in ps),max(p['pos'][i]+p['size'][i]/2 for p in ps)] for i in range(3)]
assert all(abs(a-b)<1e-6 for pair,expected in zip(envelope([hall]),[[-84,12],[0,40],[-12,52]]) for a,b in zip(pair,expected))
assert envelope([tower]+[f'TowerLevel_{i:02}' for i in range(1,7)])==[[60,84],[0,96],[-12,20]]

# One geometry list feeds both deliverables. Source remains human-readable and deterministic.
def luastr(x): return json.dumps(x,ensure_ascii=False)
rows=['-- Generated by tools/build_emberline.py; edit the generator, not this file.',
 '-- Phase 4 only. No gameplay tag, HP, energy or live destruction hooks.',
 'local Builder = {}','local Parts = {']
for p in base_parts:
    vals=[p['group'],p['name'],*p['size'],*p['pos'],*PALETTE[p['color']],p['collide']]
    rows.append(' {'+', '.join(luastr(x) if isinstance(x,str) else str(x).lower() for x in vals)+'},')
rows+=['}', '''function Builder.Build(parent, options)
 options = options or {}
 local model = Instance.new("Model")
 model.Name = "LargeCity_EmberlineResponseHQ_P4"
 model:SetAttribute("LayoutId", "LC-45")
 model:SetAttribute("Phase", 4)
 model:SetAttribute("QualityGateB", "ApprovedByUser")
 model:SetAttribute("BuildRevision", "Emberline-P4-v1")
 local pivot = Instance.new("Part")
 pivot.Name = "GroundPivot"
 pivot.Size = Vector3.new(0.1, 0.1, 0.1)
 pivot.CFrame = CFrame.new()
 pivot.Transparency = 1
 pivot.Anchored = true
 pivot.CanCollide = false
 pivot.CanTouch = false
 pivot.CanQuery = false
 pivot.Parent = model
 model.PrimaryPart = pivot
 local groups = {}
 for _, d in ipairs(Parts) do
  if not groups[d[1]] then
   local group = Instance.new("Model")
   group.Name = d[1]
   group.Parent = model
   groups[d[1]] = group
  end
  local p = Instance.new("Part")
  p.Name = d[2]
  p.Size = Vector3.new(d[3], d[4], d[5])
  p.CFrame = CFrame.new(d[6], d[7], d[8])
  p.Color = Color3.fromRGB(d[9], d[10], d[11])
  p.Material = Enum.Material.SmoothPlastic
  p.Anchored = true
  p.CanCollide = d[12]
  p.TopSurface = Enum.SurfaceType.Smooth
  p.BottomSurface = Enum.SurfaceType.Smooth
  p.Parent = groups[d[1]]
 end
 local gui = Instance.new("SurfaceGui")
 gui.Name = "StationName"
 gui.Face = Enum.NormalId.Front
 gui.CanvasSize = Vector2.new(1400, 100)
 gui.Parent = groups.Signage.HallSign
 local label = Instance.new("TextLabel")
 label.Name = "Title"
 label.Size = UDim2.fromScale(1, 1)
 label.BackgroundTransparency = 1
 label.Text = "EMBERLINE RESPONSE HQ"
 label.TextColor3 = Color3.new(1,1,1)
 label.Font = Enum.Font.ArialBold
 label.TextScaled = true
 label.Parent = gui
 model.Parent = parent
 model:PivotTo(options.GroundCFrame or CFrame.new())
 return model
end
return Builder
''']
(MOD/'LargeCityEmberlineGoldenMaster.lua').write_text('\n'.join(rows))

def lua(v):
    if isinstance(v,(list,tuple)):return '{'+','.join(lua(x) for x in v)+'}'
    if isinstance(v,str):return json.dumps(v)
    return str(v).lower()
ds=['-- Generated from tools/build_emberline.py and tools/emberline_dressing.py.',
    'local Dressing = {}','local Parts = {']
for p in dressing_parts:
    ds.append(lua([p['group'],p['name'],*p['size'],*p['pos'],*PALETTE[p['color']],p['collide'],MATERIALS.get(p['color'],('SmoothPlastic',272))[0]])+',')
ds+=['}','local BaseMaterials = {']
for p in base_parts:
    ds.append(lua([p['group'],p['name'],MATERIALS.get(p['color'],('SmoothPlastic',272))[0]])+',')
ds+=['}','local Lights = '+lua(lights),'local Symbols = '+lua(symbols),'local Frames = '+lua(FRAMES),'''
function Dressing.Apply(model)
 local old = model:FindFirstChild("EmberlineDressing")
 if old then old:Destroy() end
 local root = Instance.new("Folder")
 root.Name = "EmberlineDressing"
 root.Parent = model
 local origin = model:GetPivot()
 local groups = {}
 for _,d in ipairs(BaseMaterials) do
  local group = model:FindFirstChild(d[1])
  local p = group and group:FindFirstChild(d[2])
  if p and p:IsA("BasePart") then p.Material = Enum.Material[d[3]] end
 end
 for _,d in ipairs(Parts) do
  if not groups[d[1]] then
   local group = Instance.new("Model")
   group.Name = d[1]; group.Parent = root; groups[d[1]] = group
  end
  local p = Instance.new("Part")
  p.Name = d[2]; p.Size = Vector3.new(d[3],d[4],d[5])
  p.CFrame = origin * CFrame.new(d[6],d[7],d[8])
  p.Color = Color3.fromRGB(d[9],d[10],d[11]); p.Material = Enum.Material[d[13]]
  p.Anchored = true; p.CanCollide = d[12]
  p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
  p.Parent = groups[d[1]]
 end
 for _,d in ipairs(Lights) do
  local light = Instance.new("PointLight")
  light.Name = "FixtureLight"; light.Brightness = d[3]; light.Range = d[4]
  light.Color = Color3.fromRGB(d[5][1],d[5][2],d[5][3]); light.Shadows = false
  light.Parent = groups[d[1]][d[2]]
 end
 for _,d in ipairs(Symbols) do
  local gui = Instance.new("SurfaceGui")
  gui.Name = "FireServiceBadge"; gui.Face = Enum.NormalId[d[3]]
  gui.CanvasSize = Vector2.new(400,400); gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  gui.Parent = groups[d[1]][d[2]]
  for _,f in ipairs(Frames) do
   local frame = Instance.new("Frame")
   frame.Name = f[1]; frame.AnchorPoint = Vector2.new(.5,.5)
   frame.Position = UDim2.fromScale(f[2],f[3]); frame.Size = UDim2.fromScale(f[4],f[5])
   frame.Rotation = f[6]; frame.BackgroundColor3 = Color3.fromRGB(f[7][1],f[7][2],f[7][3])
   frame.BorderSizePixel = 0; frame.ZIndex = f[8]; frame.Parent = gui
   if f[9] then
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(.5,0); corner.Parent = frame
   end
  end
 end
 local status = model:FindFirstChild("ReviewStatus")
 if status then
  for name,value in pairs({Phase="5",GateB="User approved P4 on 2026-09-27",Revision="Emberline-P5-v1"}) do
   local field = status:FindFirstChild(name)
   if field and field:IsA("StringValue") then field.Value = value end
  end
 end
 model.Name = "LargeCity_EmberlineResponseHQ_P5"
 model:SetAttribute("Phase",5); model:SetAttribute("QualityGateB","ApprovedByUser")
 model:SetAttribute("DressingReview","Pending"); model:SetAttribute("BuildRevision","Emberline-P5-v1")
 return model
end
return Dressing
''']
(MOD/'LargeCityEmberlineDressing.lua').write_text('\n'.join(ds))

# Static XML has no executable scripts, remote asset dependencies or installer side effects.
root=E.Element('roblox',{'version':'4'}); refcounter=0
def item(parent,cls,name,ref=None):
    global refcounter
    refcounter+=1
    e=E.SubElement(parent,'Item',{'class':cls,'referent':ref or f'RBX{refcounter}'})
    props=E.SubElement(e,'Properties');E.SubElement(props,'string',{'name':'Name'}).text=name
    return e,props
def val(props,typ,name,value):E.SubElement(props,typ,{'name':name}).text=str(value).lower() if isinstance(value,bool) else str(value)
def vec(props,name,v):
    e=E.SubElement(props,'Vector3',{'name':name})
    for a,b in zip('XYZ',v):E.SubElement(e,a).text=str(b)
def cf(props,pos):
    e=E.SubElement(props,'CoordinateFrame',{'name':'CFrame'})
    for a,b in zip('XYZ',pos):E.SubElement(e,a).text=str(b)
    for i in range(3):
        for j in range(3):E.SubElement(e,f'R{i}{j}').text='1' if i==j else '0'
model,mp=item(root,'Model',NAME);val(mp,'Ref','PrimaryPart','RBXPivot')
def xmlpart(parent,p,ref=None,transparent=False):
    it,pr=item(parent,'Part',p['name'],ref)
    vec(pr,'size',p['size']);cf(pr,p['pos'])
    color=PALETTE[p['color']];val(pr,'Color3uint8','Color3uint8',(255<<24)|(color[0]<<16)|(color[1]<<8)|color[2])
    for k,v in [('Anchored',True),('CanCollide',p['collide']),('CanTouch',not transparent),('CanQuery',not transparent)]:val(pr,'bool',k,v)
    val(pr,'token','Material',MATERIALS.get(p['color'],('SmoothPlastic',272))[1]);val(pr,'token','TopSurface',0);val(pr,'token','BottomSurface',0)
    val(pr,'token','shape',1)
    if transparent:val(pr,'float','Transparency',1)
    return it
xmlpart(model,dict(name='GroundPivot',size=(.1,.1,.1),pos=(0,0,0),color='ground',collide=False),'RBXPivot',True)
groups={};sign=None; xml_parts={}
dressing_root,_=item(model,'Folder','EmberlineDressing')
for p in parts:
    if p['group'] not in groups:groups[p['group']]=item(dressing_root if p in dressing_parts else model,'Model',p['group'])[0]
    it=xmlpart(groups[p['group']],p)
    xml_parts[(p['group'],p['name'])]=it
    if p['name']=='HallSign':sign=it
gui,gp=item(sign,'SurfaceGui','StationName');val(gp,'token','Face',5)
cv=E.SubElement(gp,'Vector2',{'name':'CanvasSize'});E.SubElement(cv,'X').text='1400';E.SubElement(cv,'Y').text='100'
label,lp=item(gui,'TextLabel','Title');val(lp,'string','Text','EMBERLINE RESPONSE HQ');val(lp,'bool','TextScaled',True);val(lp,'float','BackgroundTransparency',1);val(lp,'token','Font',2)
col=E.SubElement(lp,'Color3',{'name':'TextColor3'})
for axis in 'RGB':E.SubElement(col,axis).text='1'
sz=E.SubElement(lp,'UDim2',{'name':'Size'})
for k,v in [('XS',1),('XO',0),('YS',1),('YO',0)]:E.SubElement(sz,k).text=str(v)
# Lights and badges are parented to their own parts for later destruction ownership.
def rgb(props,name,color):
    c=E.SubElement(props,'Color3',{'name':name})
    for axis,v in zip('RGB',color):E.SubElement(c,axis).text=str(v/255)
def u2(props,name,x,y):
    e=E.SubElement(props,'UDim2',{'name':name})
    for k,v in [('XS',x),('XO',0),('YS',y),('YO',0)]:E.SubElement(e,k).text=str(v)
for group,name,brightness,ran,color in lights:
    _,pr=item(xml_parts[(group,name)],'PointLight','FixtureLight')
    val(pr,'float','Brightness',brightness);val(pr,'float','Range',ran);val(pr,'bool','Shadows',False);rgb(pr,'Color',color)
for group,name,face,face_id in symbols:
    gui,pr=item(xml_parts[(group,name)],'SurfaceGui','FireServiceBadge')
    val(pr,'token','Face',face_id);val(pr,'token','ZIndexBehavior',1)
    cv=E.SubElement(pr,'Vector2',{'name':'CanvasSize'})
    E.SubElement(cv,'X').text='400';E.SubElement(cv,'Y').text='400'
    for n,x,y,w,h,rot,col,layer,rounded in FRAMES:
        fr,fp=item(gui,'Frame',n);u2(fp,'Position',x,y);u2(fp,'Size',w,h)
        av=E.SubElement(fp,'Vector2',{'name':'AnchorPoint'});E.SubElement(av,'X').text='.5';E.SubElement(av,'Y').text='.5'
        val(fp,'float','Rotation',rot);val(fp,'int','BorderSizePixel',0);val(fp,'int','ZIndex',layer);rgb(fp,'BackgroundColor3',col)
        if rounded:
            _,cp=item(fr,'UICorner','Round')
            cr=E.SubElement(cp,'UDim',{'name':'CornerRadius'});E.SubElement(cr,'S').text='.5';E.SubElement(cr,'O').text='0'

meta,_=item(model,'Folder','ReviewStatus')
for k,v in [('Phase','5'),('GateB','User approved P4 on 2026-09-27'),('DressingReview','Pending'),('LayoutId','LC-45'),('Revision','Emberline-P5-v1')]:
    _,p=item(meta,'StringValue',k);val(p,'string','Value',v)
path=DEST/'LargeCityEmberlineResponseHQ_P5.rbxmx'
E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
parsed=E.parse(path)
assert len(parsed.findall('.//Item[@class="Part"]'))==len(parts)+1
assert not parsed.findall('.//Item[@class="Script"]')
assert not parsed.findall('.//Item[@class="LocalScript"]')
assert len(parsed.findall('.//Item[@class="PointLight"]'))==12
assert len(parsed.findall('.//Item[@class="SurfaceGui"]'))==4
assert all(n.find("Properties/bool[@name='Shadows']").text=='false' for n in parsed.findall('.//Item[@class="PointLight"]'))
report=dict(revision='Emberline-P5-v1',base_parts=len(base_parts)+1,dressing_parts=len(dressing_parts),lights=len(lights),symbol_badges=len(symbols),parts=len(parts)+1,door_bays=4,training_levels=6,
 plot=[176,112],hall=[96,64,40],admin_main_body=[48,64,40],tower=[24,32,96],
 ground_y=0,base_bottom_y=-1,gate_b='User approved P4 2026-09-27',studio_import_test='P4 confirmed by user; P5 not yet tested',
 checks=['unique group/part names','positive sizes','parts inside approved plot','maximum Y=96','hall and tower envelopes','four doors','six real open drill bays','XML parse and part count','no runtime scripts'],
 intentional_joins=['facade corners and structural slab/wall seams','entry portal over closed glazing','thin apron above base slab'],
 pending=['P5 Roblox Studio review','mobile readability and light/performance check','collision walkthrough','P6 balancing and destruction'])
(DOC/'dressing-checks.json').write_text(json.dumps(report,indent=2)+'\n')

if '--preview' in sys.argv:
    import numpy as np
    from PIL import Image, ImageDraw, ImageFont
    board=Image.new('RGB',(1800,1080),'#f4f3ed'); draw=ImageDraw.Draw(board)
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    bold='/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'
    draw.text((900,30),'EMBERLINE RESPONSE HQ | Phase 5',font=ImageFont.truetype(bold,28),fill='#183b42',anchor='mt')
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
    draw.text((900,1010),'Exportgeometrie: 4 Tore / 6 Turmebenen / 96 Studs Turmhöhe / Dressing zur Ansicht',font=ImageFont.truetype(font,20),fill='#43585d',anchor='mt')
    draw.text((900,1043),'Technische Vorschau ausserhalb Studio. Symbole, Schrift, Materialtexturen und Lichtwirkung erst in Studio sichtbar.',font=ImageFont.truetype(font,16),fill='#43585d',anchor='mt')
    board.save(DOC/'dressing-review.png')
print(json.dumps(report))
