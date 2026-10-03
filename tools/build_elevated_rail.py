"""Build an independent 80-stud repeatable viaduct segment at MC-03's west portal.
Run from repository root: python tools/build_elevated_rail.py
The station generator provides serialization helpers; no station export is triggered.
"""
import json
import xml.etree.ElementTree as ET
import build_elevated_transit as g

g.parts.clear()
p,t,b,s=g.part,g.trim,g.beam,g.snow
# Local segment X spans -40..40; world placement -156 joins station X=-116.
p('ViaductDeck',(80,5,24),(0,43,0),'concrete','Concrete')
p('TrackBed',(80,1,18),(0,46,0),'dark')
for z in [-5,5]:p('Rail',(80,1,1),(0,47,z),'edge')
for x in range(-35,40,10):p('Sleeper',(2,.5,15),(x,46.6,0),'metal')
for z in [-11,11]:
    p('SafetyKerb',(80,2,2),(0,47,z),'edge')
    t('RouteLight',(80,.7,.5),(0,48,z+(-1.3 if z<0 else 1.3)))
    s('KerbSnow',80,1.5,0,48.3,z)
    p('CableConduit',(80,2,2),(0,39,z),'metal')
# One centre pier per segment, leaving the joints unobstructed.
p('PierFoot',(22,4,26),(0,2,0),'concrete','Concrete')
p('PierShaft',(10,32,12),(0,20,0),'concrete','Concrete')
p('PierCapital',(22,5,25),(0,38,0),'edge')
for z in [-10,10]:
    b('PierBrace',(0,27,0),(0,37,z),4,'edge')
    t('PierMarker',(4,1,.6),(0,8,z*.65),'warm')
root=ET.Element('roblox',version='4')
model,mp=g.item(root,'Model','MegaCityElevatedRailStraight80')
origin,op=g.item(model,'Part','Origin')
for name,value in [('Anchored','true'),('CanCollide','false'),('CanTouch','false'),('CanQuery','false')]:g.prop(op,'bool',name,value)
g.prop(op,'float','Transparency',1);g.vec(op,'size',[1,1,1]);g.cf(op,'CFrame',[-156,0,0],[1,0,0,0,1,0,0,0,1])
g.prop(mp,'Ref','PrimaryPart',origin.attrib['referent'])
g.prop(mp,'BinaryString','AttributesSerialize',g.attrs({'SegmentLength':80,'TrackAxis':'X','RailTopY':47.5,'AssetId':'MC-03-RAIL-STRAIGHT','StandaloneEnvironment':True}))
for name,x in [('SnapStart',-40),('SnapEnd',40)]:
    _,ap=g.item(origin,'Attachment',name)
    g.cf(ap,'CFrame',[x,47.5,0],[1,0,0,0,1,0,0,0,1])
for d in g.parts:
    _,pr=g.item(model,'Part',d['name'])
    for name,value in [('Anchored','true'),('CanCollide',str(d['solid']).lower()),('CanQuery',str(d['solid']).lower()),('CanTouch','false')]:g.prop(pr,'bool',name,value)
    g.prop(pr,'float','Transparency',d['alpha'])
    g.prop(pr,'token','Material',{'Metal':1088,'Concrete':816,'Neon':288,'SmoothPlastic':272}[d['material']])
    g.prop(pr,'token','TopSurface',0);g.prop(pr,'token','BottomSurface',0);g.prop(pr,'token','shape',1)
    r,gg,bb=d['color'];g.prop(pr,'Color3uint8','Color3uint8',(255<<24)|(r<<16)|(gg<<8)|bb)
    g.vec(pr,'size',d['size']);g.cf(pr,'CFrame',[d['pos'][0]-156,d['pos'][1],d['pos'][2]],g.matrix(d))
target=g.ROOT/'packages/mega-city/03-elevated-rail-straight-80.rbxmx'
ET.indent(root);ET.ElementTree(root).write(target,encoding='utf-8',xml_declaration=True)
print(json.dumps({'visibleParts':len(g.parts),'segmentLength':80,'railTopY':47.5,'package':str(target)}))
