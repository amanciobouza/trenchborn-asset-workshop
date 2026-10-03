"""Check the exported native city, including transforms against original sources."""
from pathlib import Path
import collections,json,math,xml.etree.ElementTree as E
ROOT=Path(__file__).resolve().parents[1]
data=json.loads((ROOT/'docs/mega-city/plans/00-mega-city-final-layout.json').read_text())
assert len(data['buildings'])==85
assert len({b['id'] for b in data['buildings']})==85
expected={1:1,2:5,3:3,4:4,5:6,6:2,7:5,8:14,9:7,10:4,11:2,12:4,13:6,14:1,15:5,16:3,17:1,18:3,19:5,20:3,21:1}
assert dict(collections.Counter(b['asset'] for b in data['buildings']))==expected
counts=collections.Counter();sources={}
for b in data['buildings']:
 src=sources.setdefault(b['asset'],E.parse(ROOT/b['source']['package']).getroot())
 out=E.parse(ROOT/b['placedPackage']).getroot()
 sp=src.findall('.//Item[@class="Part"]');op=out.findall('.//Item[@class="Part"]');assert len(sp)==len(op)
 assert src.find('./Item/Properties/BinaryString[@name="AttributesSerialize"]').text==out.find('./Item/Properties/BinaryString[@name="AttributesSerialize"]').text
 assert src.find('./Item/Properties/BinaryString[@name="Tags"]').text==out.find('./Item/Properties/BinaryString[@name="Tags"]').text
 assert [x.text for x in src.findall('.//ProtectedString')]==[x.text for x in out.findall('.//ProtectedString')]
 assert [x.text for x in src.findall('.//Item[@class="TextLabel"]/Properties/string[@name="Text"]')]==[x.text for x in out.findall('.//Item[@class="TextLabel"]/Properties/string[@name="Text"]')]
 a=b['yaw'];c,s=math.cos(a),math.sin(a);R=[[c,0,s],[0,1,0],[-s,0,c]]
 for original,placed in zip(sp,op):
  sc=original.find('Properties/CoordinateFrame[@name="CFrame"]');oc=placed.find('Properties/CoordinateFrame[@name="CFrame"]')
  xyz=[float(sc.find(k).text) for k in 'XYZ']
  for i,k in enumerate('XYZ'):assert abs(float(oc.find(k).text)-(b['translation'][i]+sum(R[i][j]*xyz[j] for j in range(3))))<1e-6
  for i in range(3):
   for k in range(3):assert abs(float(oc.find(f'R{i}{k}').text)-sum(R[i][j]*float(sc.find(f'R{j}{k}').text) for j in range(3)))<1e-8
 counts['buildings']+=1;counts['buildingParts']+=len(op);counts['preservedScripts']+=len(out.findall('.//Item[@class="Script"]'))
for file in (ROOT/'packages/mega-city-final').glob('*.rbxmx'):
 root=E.parse(file).getroot();items=list(root.iter('Item'));refs=[i.attrib['referent'] for i in items];assert len(refs)==len(set(refs)),file
 for ref in root.findall('.//Ref'):assert ref.text=='null' or ref.text in refs,(file,ref.text)
 for i in items:
  if i.attrib['class'] not in ['Part','WedgePart']:continue
  p=i.find('Properties');assert p.find('bool[@name="Anchored"]').text=='true'
  size=p.find('Vector3[@name="size"]');assert all(math.isfinite(float(v.text)) and 0<float(v.text)<=2048 for v in size),(file,[v.text for v in size])
  cf=p.find('CoordinateFrame[@name="CFrame"]');assert all(math.isfinite(float(v.text)) for v in cf)
  m=[[float(cf.find(f'R{a}{b}').text) for b in range(3)] for a in range(3)]
  for a in range(3):
   for b in range(3):assert abs(sum(m[k][a]*m[k][b] for k in range(3))-(a==b))<1e-7,(file,i.attrib)
  det=sum(m[0][j]*(m[1][(j+1)%3]*m[2][(j+2)%3]-m[1][(j+2)%3]*m[2][(j+1)%3]) for j in range(3));assert abs(det-1)<1e-7
  counts['totalBaseParts']+=1
 for u in root.findall('.//UDim2'):
  for k in ['XO','YO']:assert str(int(u.find(k).text))==u.find(k).text
 counts['smokeEmitters']+=len(root.findall('.//Item[@class="Smoke"]'))
for f in ['mega-city-final.project.json','default.project.json']:
 project=json.loads((ROOT/f).read_text());workspace=project['tree']['Workspace'];assert workspace['$ignoreUnknownInstances'] is True and 'Terrain' not in workspace
 def check(node):
  if isinstance(node,dict):
   if '$path' in node:assert (ROOT/node['$path']).is_file(),node
   for v in node.values():check(v)
 check(project)
assert counts['preservedScripts']==85 and counts['smokeEmitters']>20
print(json.dumps({**counts,'sameTypeNeighbourPairs':data['equalTypeNeighbourEdges'],'sourceGeometryScriptsSignsPreserved':True,'studioPlaytest':False}))
