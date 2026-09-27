"""Phase-5 additions. No external images or runtime animation dependencies."""
PALETTE={'warm':(255,216,165),'beacon':(240,45,35),'soil':(70,58,43),
 'leaf':(65,113,63),'leaflight':(93,137,72),'white':(245,240,224)}
MATERIALS={'concrete':('Concrete',816),'ground':('Concrete',816),
 'red':('Metal',1088),'roof':('Metal',1088),'metal':('Metal',1088),
 'glass':('Glass',1568),'yellow':('SmoothPlastic',272),
 'warm':('Neon',288),'beacon':('Neon',288)}

def additions(part):
    lights=[];symbols=[]
    # Roof equipment sits on the approved roofs; total tower height stays at 96.
    for i,(x,z,w,d) in enumerate([(-60,20,12,9),(-28,36,10,8),(29,32,10,8),(48,40,8,7)],1):
        g='RoofEquipment'
        part(g,f'HVAC{i}_Plinth',(w+1,.5,d+1),(x,40.25,z),'roof',False)
        part(g,f'HVAC{i}_Body',(w,3,d),(x,42,z),'metal',False)
        part(g,f'HVAC{i}_Cap',(w+.5,.35,d+.5),(x,43.675,z),'concrete',False)
        for j in range(5):part(g,f'HVAC{i}_Louvre{j}',(w-.8,.18,.18),(x,41+j*.45,z-d/2-.15),'roof',False)
    for i,x in enumerate([53,55]):
        part('RoofEquipment',f'AdminAntenna{i}',(.22,5-i,.22),(x,42.5-i/2,45),'metal',False)
    part('FacadeDetails','HallSideBand',(.25,2,61),(-84.15,36,19),'red',False)
    part('FacadeDetails','AdminRearBand',(48,2,.25),(36,21,52.15),'red',False)
    # Posts are aligned with concrete piers, outside all four drive-through widths.
    for i,x in enumerate([-81.6,-58.8,-36,-13.2,9.6,29,45],1):
        z=-16 if i<=5 else -26
        part('Bollards',f'Post{i}_Body',(1,5,1),(x,2.5,z),'yellow')
        part('Bollards',f'Post{i}_Foot',(1.5,.3,1.5),(x,.15,z),'roof')
        for j,y in enumerate([1.4,3.4]):part('Bollards',f'Post{i}_Stripe{j}',(1.04,.65,1.04),(x,y,z),'roof',False)
    for i,x in enumerate([22,52],1):
        part('Planters',f'Planter{i}_Base',(8,.5,5),(x,.25,-26),'concrete')
        for side in [-1,1]:
            part('Planters',f'Planter{i}_Long{side}',(8,2,.5),(x,1.5,-26+side*2.25),'concrete')
            part('Planters',f'Planter{i}_End{side}',(.5,2,4),(x+side*3.75,1.5,-26),'concrete')
        part('Planters',f'Planter{i}_Soil',(7,1,4),(x,1.5,-26),'soil',False)
        for j,off in enumerate([-2.4,0,2.4]):
            part('Planters',f'Planter{i}_Bush{j}',(2,2.4,2.5),(x+off,3.2,-26),'leaf',False)
            part('Planters',f'Planter{i}_Shoot{j}',(.65,3.4,.65),(x+off,3.7,-26),'leaflight',False)
    # 12 short-range lights, no dynamic shadows, no flashing or Heartbeat loops.
    fixtures=[(x,31,-12.85) for x in [-70.2,-47.4,-24.6,-1.8]]
    fixtures += [(29,17,-20),(45,17,-20),(64.5,26,-12.7),(79.5,68,-12.7)]
    for i,(x,y,z) in enumerate(fixtures,1):
        part('Lighting',f'WallLight{i}_Housing',(1.8,.9,.7),(x,y,z),'roof',False)
        name=f'WallLight{i}_Lens'
        part('Lighting',name,(1.3,.4,.15),(x,y-.08,z-.43),'warm',False)
        lights.append(('Lighting',name,.8,14,(255,216,165)))
    for i,(x,y,z) in enumerate([(62,93,-10),(82,93,18),(-82,40,49),(10,40,-10)],1):
        part('Lighting',f'Beacon{i}_Base',(.8,.3,.8),(x,y+.15,z),'roof',False)
        name=f'Beacon{i}_Lens'
        part('Lighting',name,(.55,.9,.55),(x,y+.75,z),'beacon',False)
        lights.append(('Lighting',name,.4,9,(255,55,40)))
    # Image-free vector badges in SurfaceGuis, with explicit layer ordering.
    part('Emblems','AdminPlaque',(14,15,.4),(37,29.5,-12.7),'concrete',False)
    part('Emblems','TowerPlaque',(.35,12,9),(84.25,77,4),'concrete',False)
    part('Emblems','HallPlaque',(.35,12,9),(-84.25,22,8),'concrete',False)
    symbols=[('Emblems','AdminPlaque','Front',5),('Emblems','TowerPlaque','Right',0),('Emblems','HallPlaque','Left',3)]
    return lights,symbols

# name, centre X/Y, width/height, rotation, color RGB, layer, rounded
FRAMES=[
 ('WhiteTop',.5,.33,.8,.56,0,(245,240,224),1,False),
 ('WhitePoint',.5,.60,.566,.566,45,(245,240,224),1,False),
 ('RedTop',.5,.35,.70,.50,0,(177,31,40),2,False),
 ('RedPoint',.5,.60,.495,.495,45,(177,31,40),2,False),
 ('FlameBody',.5,.56,.32,.37,0,(245,240,224),3,True),
 ('FlameTip',.54,.36,.16,.32,28,(245,240,224),3,False),
 ('FlameNotch',.65,.35,.20,.25,-18,(177,31,40),4,True),
 ('InnerFlame',.51,.70,.13,.28,8,(177,31,40),4,True),
]
