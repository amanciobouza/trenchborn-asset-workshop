"""Phase 5 decoration from the approved P4 geometry. No remote assets.
Run python3 tools/build_police_dressing.py [--preview].
"""
from pathlib import Path
import runpy,sys,json,math,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
preview='--preview' in sys.argv
saved=sys.argv;sys.argv=[sys.argv[0]]
b=runpy.run_path(str(ROOT/'tools/build_police.py'));sys.argv=saved
parts=b['parts'];base=list(parts);palette=b['PALETTE'];part=b['part'];beam=b['beam'];DOC=b['DOC'];MOD=b['MOD'];DEST=b['DEST']
palette.update(warm=(255,226,169),beacon=(54,159,245),leaf=(69,111,66),leaflight=(99,137,75),soil=(78,67,48),white=(242,242,224),red=(185,40,41))
lights=[]
def add(g,n,size,pos,col='metal',collide=False,rz=0,shape='Block'):
    part(g,n,size,pos,col,collide,rz);parts[-1]['shape']=shape
# Badge is hosted by a single plaque. SurfaceGui uses original geometric shield + star.
add('Portal','BadgePlaque',(15,17,.55),(-12,47,-24.4),'blue')
# Wall fixtures entirely outside their supporting wall planes; lights are modest/no shadows.
for i,(x,y,z) in enumerate([(-74,11,-16.5),(-30,11,-16.5),(6,11,-16.5),(50,11,-16.5),(-25.5,34,-24.5),(1.5,34,-24.5),(53.5,12,-16.5),(82.5,12,-16.5)]):
    add('Lighting',f'WallBase{i}',(.9,4,.6),(x,y,z),'roof')
    add('Lighting',f'WallLens{i}',(.6,3,.2),(x,y,z-.45),'warm')
    lights.append(('Lighting',f'WallLens{i}',.65,14,(255,226,169)))
for i,x in enumerate([-26,-12,2]):
    add('Lighting',f'CanopyLens{i}',(1.6,.2,1.6),(x,24.85,-32),'warm')
# Four fixed blue beacons, no flashing/behavior implied.
for i,(x,y,z) in enumerate([(-74,60,-15),(50,60,-15),(-25.5,68,-20),(1.5,68,-20)]):
    add('Lighting',f'BeaconBase{i}',(1.8,.4,1.8),(x,y+.2,z),'roof')
    add('Lighting',f'BeaconLens{i}',(1,1.2,1),(x,y+1,z),'beacon')
    lights.append(('Lighting',f'BeaconLens{i}',.5,10,(54,159,245)))
# Four compact rooftop HVACs and antenna panels. Avoid the radio room footprint.
for i,(x,z) in enumerate([(-60,36),(-43,36),(39,37),(-48,5)]):
    add('RoofEquipment',f'HVAC{i}',(10,6,9),(x,63,z),'roof')
    for j in range(5):add('RoofEquipment',f'HVAC{i}Slat{j}',(8,.25,.25),(x,61+j,z-4.7),'metal')
for i,(x,y) in enumerate([(17,90),(6,88)]):
    add('Radio',f'AntennaPanel{i}',(2.5,7,1),(x+1.6,y,30),'roof')
# Shallow ellipsoid reflector, contrasting rim and feed assembly facing front -Z.
add('Radio','DishStand',(.65,4,.65),(23,78,23),'metal')
add('Radio','DishRim',(8,8,1.2),(23,82,22),'metal',shape='Ball')
add('Radio','DishFace',(7,7,.55),(23,82,21.35),'roof',shape='Ball')
add('Radio','DishFeedArm',(.3,.3,2.8),(23,82,19.8),'metal')
add('Radio','DishFeed',(.9,.9,1),(23,82,18.7),'metal',shape='Ball')
# Radio roof rail within the existing room footprint.
for x in [-3,27]:
    for z in [19,30,41]:add('Radio',f'RailPost{x}_{z}',(.25,3,.25),(x,77.5,z))
    add('Radio',f'SideRail{x}',(.25,.25,22),(x,79,30))
for z in [19,41]:add('Radio',f'CrossRail{z}',(30,.25,.25),(12,79,z))
# Static barrier. At z=-24 beyond the garage opening, no pedestrian entry obstruction.
for x in [55,81]:add('VehicleAccess',f'BarrierPost{x}',(1.4,6,1.4),(x,3,-24),'yellow',True)
add('VehicleAccess','BarrierArm',(26,.7,.7),(68,5.2,-24),'white',True)
for i in range(6):add('VehicleAccess',f'BarrierStripe{i}',(2,.5,.12),(57+i*4.3,5.2,-24.42),'red')
for i,(x,z) in enumerate([(52,-29),(84,-29),(52,-18),(84,-18)]):
    # Keep the 176-wide plot: outer bollards centred at83 instead of84.
    x=min(x,83)
    add('VehicleAccess',f'Bollard{i}',(.9,5,.9),(x,2.5,z),'yellow',True)
    for j in range(2):add('VehicleAccess',f'BollardStripe{i}_{j}',(.94,.65,.94),(x,1.6+j*1.5,z),'roof')
# Driveway arrow, yellow chevrons (thin, above existing paving, no coincident faces).
add('Markings','ArrowShaft',(.8,.04,6),(68,.18,-45),'yellow')
for side in [-1,1]:
    # Arrowhead as stepped widening bars, grounded at the same marked surface.
    for j in range(4):add('Markings',f'ArrowHead{side}_{j}',(.8,.04,1),(68+side*j*.65,.18,-42-j*.55),'yellow')
for i in range(8):add('Markings',f'EntryHatch{i}',(.4,.04,3),(56+i*3.4,.18,-20),'yellow')
# Side service fence along plot edge, outside vehicle travel lane.
for z in [0,16,32,48,60]:add('VehicleAccess',f'FencePost{z}',(.35,6,.35),(86,3,z),'roof',True)
for y in [1.5,5.5]:add('VehicleAccess',f'FenceRail{y}',(.25,.25,60),(86,y,30),'metal')
for z in range(2,60,2):add('VehicleAccess',f'FenceBar{z}',(.15,5,.15),(86,3,z),'metal')
# Grounded broad leaf clusters within the approved planter openings.
for j,(x,z,w,d) in enumerate([(-55,-29,28,10),(-50,-48,22,8),(23,-43,28,8)]):
    add('Landscape',f'Soil{j}',(w-2,.3,d-2),(x,2.2,z),'soil')
    for i in range(5):
        add('Landscape',f'Shrub{j}_{i}',(4.5,3+(i%2),d-3),(x-(w-6)/2+i*(w-6)/4,3.4+(i%2)*.5,z),'leaf' if i%2 else 'leaflight',shape='Ball')
extra=parts[len(base):]
materials={'concrete':('Concrete',816),'ground':('Concrete',816),'glass':('Glass',1568),'roof':('Metal',1088),'metal':('Metal',1088),'blue':('SmoothPlastic',272),'yellow':('SmoothPlastic',272),'warm':('Neon',288),'beacon':('Neon',288),'leaf':('Grass',1280),'leaflight':('Grass',1280),'soil':('Ground',1360)}
# Horizontal spans make an original shield with gold rim, not a remote image/decal.
frames=[]
for i in range(28):
    y=.1+i*.027
    width=.76 if i<13 else .76*(1-(i-12)/17)
    frames.append((f'Gold{i}',.5,y,width,.03,(235,190,61)))
    if 1<i<26:frames.append((f'Blue{i}',.5,y,max(.02,width-.12),.03,(26,76,139)))
# Lua dressing is repeatable, preserving approved structural geometry and original pivot.
def lua(x):
    if isinstance(x,(list,tuple)):return '{'+','.join(lua(v) for v in x)+'}'
    return json.dumps(x)
rows=['-- Generated by tools/build_police_dressing.py. Gate B user-approved, P5 review pending.','local Dressing = {}','local Parts = {']
for p in extra:rows.append(lua([p['group'],p['name'],*p['size'],*p['pos'],*palette[p['color']],p['collide'],p['rz'],p['shape'],materials.get(p['color'],('SmoothPlastic',272))[0]])+',')
rows+=['}','local BaseMaterials = {']
for p in base:rows.append(lua([p['group'],p['name'],materials.get(p['color'],('SmoothPlastic',272))[0]])+',')
rows+=['}','local Lights = '+lua(lights),'local Frames = '+lua(frames),'''
function Dressing.Apply(model)
 assert(model.PrimaryPart, "Police dressing requires the original ground pivot")
 local old = model:FindFirstChild("PoliceDressing")
 if old then old:Destroy() end
 local root = Instance.new("Folder"); root.Name = "PoliceDressing"; root.Parent = model
 local origin = model:GetPivot(); local groups = {}
 for _,d in ipairs(BaseMaterials) do
  local g = model:FindFirstChild(d[1]); local p = g and g:FindFirstChild(d[2])
  if p then p.Material = Enum.Material[d[3]] end
 end
 for _,d in ipairs(Parts) do
  if not groups[d[1]] then local g = Instance.new("Model"); g.Name = d[1]; g.Parent = root; groups[d[1]] = g end
  local p = Instance.new("Part"); p.Name = d[2]; p.Size = Vector3.new(d[3],d[4],d[5])
  p.CFrame = origin * CFrame.new(d[6],d[7],d[8]) * CFrame.Angles(0,0,d[13])
  p.Color = Color3.fromRGB(d[9],d[10],d[11]); p.CanCollide = d[12]; p.Anchored = true
  p.Shape = Enum.PartType[d[14]]; p.Material = Enum.Material[d[15]]
  p.TopSurface = Enum.SurfaceType.Smooth; p.BottomSurface = Enum.SurfaceType.Smooth
  p.Parent = groups[d[1]]
 end
 for _,d in ipairs(Lights) do
  local l = Instance.new("PointLight"); l.Name = "FixtureLight"; l.Brightness = d[3]; l.Range = d[4]
  l.Color = Color3.fromRGB(d[5][1],d[5][2],d[5][3]); l.Shadows = false; l.Parent = groups[d[1]][d[2]]
 end
 local gui = Instance.new("SurfaceGui"); gui.Name = "PoliceBadge"; gui.Face = Enum.NormalId.Front
 gui.CanvasSize = Vector2.new(400,450); gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
 gui.Parent = groups.Portal.BadgePlaque
 for _,f in ipairs(Frames) do
  local o = Instance.new("Frame"); o.Name = f[1]; o.AnchorPoint = Vector2.new(.5,.5)
  o.Position = UDim2.fromScale(f[2],f[3]); o.Size = UDim2.fromScale(f[4],f[5])
  o.BackgroundColor3 = Color3.fromRGB(f[6][1],f[6][2],f[6][3]); o.BorderSizePixel = 0
  o.ZIndex = f[1]:sub(1,4) == "Gold" and 1 or 2; o.Parent = gui
 end
 local star = Instance.new("TextLabel"); star.Name = "Star"; star.BackgroundTransparency = 1
 star.Position = UDim2.fromScale(.15,.17); star.Size = UDim2.fromScale(.7,.55)
 star.Text = "★"; star.Font = Enum.Font.ArialBold; star.TextScaled = true
 star.TextColor3 = Color3.fromRGB(242,242,224); star.ZIndex = 3; star.Parent = gui
 model.Name = "LargeCity_PoliceHQ_P5"; model:SetAttribute("Phase",5)
 model:SetAttribute("QualityGateB","ApprovedByUser"); model:SetAttribute("DressingReview","Pending")
 model:SetAttribute("BuildRevision","Police-P5-v1")
 return model
end
return Dressing
''']
(MOD/'LargeCityPoliceDressing.lua').write_text('\n'.join(rows))
# Extend the static P4 XML, using exactly the same definitions as the Lua dressing.
root=b['root'];model=b['model'];item=b['item'];val=b['val'];vec=b['vec']
model.find("Properties/string[@name='Name']").text='LargeCity_PoliceHQ_P5'
lookup={(p['group'],p['name']):p for p in base}
for group in model.findall('Item'):
    for it in group.findall('Item'):
        gn=group.find("Properties/string[@name='Name']").text;n=it.find("Properties/string[@name='Name']").text
        if (gn,n) in lookup:it.find("Properties/token[@name='Material']").text=str(materials.get(lookup[(gn,n)]['color'],('SmoothPlastic',272))[1])
dr,_=item(model,'Folder','PoliceDressing');groups={};owners={}
for p in extra:
    if p['group'] not in groups:groups[p['group']]=item(dr,'Model',p['group'])[0]
    it,pr=item(groups[p['group']],'Part',p['name']);owners[p['group'],p['name']]=it
    vec(pr,'size',p['size']);c=E.SubElement(pr,'CoordinateFrame',name='CFrame')
    for axis,n in zip('XYZ',p['pos']):E.SubElement(c,axis).text=str(n)
    a=p['rz'];rot=((math.cos(a),-math.sin(a),0),(math.sin(a),math.cos(a),0),(0,0,1))
    for i in range(3):
        for j in range(3):E.SubElement(c,f'R{i}{j}').text=str(rot[i][j])
    col=palette[p['color']];val(pr,'Color3uint8','Color3uint8',(255<<24)|(col[0]<<16)|(col[1]<<8)|col[2])
    for k,v in [('Anchored',True),('CanCollide',p['collide'])]:val(pr,'bool',k,v)
    for k,v in [('Material',materials.get(p['color'],('SmoothPlastic',272))[1]),('TopSurface',0),('BottomSurface',0),('shape',0 if p['shape']=='Ball' else 1)]:val(pr,'token',k,v)
def rgb(pr,name,col):
    c=E.SubElement(pr,'Color3',name=name)
    for axis,v in zip('RGB',col):E.SubElement(c,axis).text=str(v/255)
def u2(pr,name,x,y):
    c=E.SubElement(pr,'UDim2',name=name)
    for k,v in [('XS',x),('XO',0),('YS',y),('YO',0)]:E.SubElement(c,k).text=str(v)
for g,n,bright,ran,col in lights:
    _,pr=item(owners[g,n],'PointLight','FixtureLight')
    val(pr,'float','Brightness',bright);val(pr,'float','Range',ran);val(pr,'bool','Shadows',False);rgb(pr,'Color',col)
gui,pr=item(owners['Portal','BadgePlaque'],'SurfaceGui','PoliceBadge');val(pr,'token','Face',5);val(pr,'token','ZIndexBehavior',1)
c=E.SubElement(pr,'Vector2',name='CanvasSize');E.SubElement(c,'X').text='400';E.SubElement(c,'Y').text='450'
for n,x,y,w,h,col in frames:
    _,pr=item(gui,'Frame',n);u2(pr,'Position',x,y);u2(pr,'Size',w,h);rgb(pr,'BackgroundColor3',col)
    c=E.SubElement(pr,'Vector2',name='AnchorPoint');E.SubElement(c,'X').text='.5';E.SubElement(c,'Y').text='.5'
    val(pr,'int','BorderSizePixel',0);val(pr,'int','ZIndex',1 if n.startswith('Gold') else 2)
_,pr=item(gui,'TextLabel','Star');u2(pr,'Position',.15,.17);u2(pr,'Size',.7,.55);rgb(pr,'TextColor3',(242,242,224))
for t,k,v in [('string','Text','★'),('float','BackgroundTransparency',1),('bool','TextScaled',True),('token','Font',2),('int','ZIndex',3)]:val(pr,t,k,v)
for it in model.findall("Item[@class='Folder']/Item[@class='StringValue']"):
    n=it.find("Properties/string[@name='Name']").text
    if n in {'Phase','GateB','Revision'}:it.find("Properties/string[@name='Value']").text={'Phase':'5','GateB':'ApprovedByUser 2026-09-27','Revision':'Police-P5-v1'}[n]
path=DEST/'LargeCityPoliceHQ_P5.rbxmx';E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)
# Export and bounds tests, plus protection of the approved facade spacing.
for p in extra:
    bb=b['bounds'](p);assert bb[0][0]>=-88 and bb[0][1]<=88 and bb[2][0]>=-64 and bb[2][1]<=64 and bb[1][1]<=100,p
assert len({(p['group'],p['name']) for p in extra})==len(extra)
t=E.parse(path);assert len(t.findall('.//Item[@class="Part"]'))==len(parts)+1
assert len(t.findall('.//Item[@class="PointLight"]'))==12
assert len(t.findall('.//Item[@class="SurfaceGui"]'))==2
assert not t.findall('.//Item[@class="Script"]')
report=dict(revision='Police-P5-v1',base_parts=len(base)+1,dressing_parts=len(extra),total_parts=len(parts)+1,point_lights=12,shadow_lights=0,gate_b='ApprovedByUser 2026-09-27',p5_review='Pending',studio_import='Pending',barrier='Static; no animation',checks=['P4 facade checks rerun','plot and 100-stud height respected','XML count','12 lights / 2 signs','no scripts or remote assets'])
(DOC/'dressing-checks.json').write_text(json.dumps(report,indent=2)+'\n')
if preview:
    # Reuse the existing technical projection. Rounded parts show their bounding volumes.
    s=(ROOT/'tools/build_police.py').read_text();s=s[s.index("if '--preview'"):s.rindex('print(json.dumps(report))')]
    s=s.replace('POLICE HQ | Phase 4','POLICE HQ | Phase 5').replace('Gate B offen','Dressing zur Abnahme').replace('geometry-review.png','dressing-review.png')
    s=s.replace('Symbole, Schrift, Materialtexturen und Lichtwirkung erst in Studio sichtbar.','Rundungen als Huellkoerper; Wappen, Schrift und Lichtwirkung erst in Studio sichtbar.')
    env=dict(b);env.update(parts=parts,PALETTE=palette,report=report,sys=sys);exec(s,env)
print(json.dumps(report))
