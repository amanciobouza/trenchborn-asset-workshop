"""Validate measured model bounds against plots, roads and other buildings."""
from pathlib import Path
import json,itertools
r=Path(__file__).resolve().parents[1];data=json.loads((r/'docs/city/city-plan.json').read_text())
rows=[]
for line in (r/'docs/city/placement-test.txt').read_text().splitlines():
 if line.startswith('BOUNDS '):
  _,plot,model,*v=line.split();rows.append(dict(plot=plot,model=model,min=list(map(float,v[:3])),max=list(map(float,v[3:6])),parts=int(v[6]),lights=int(v[7])))
assert len(rows)==54
plots={p['place_id']:p for p in data['plots']}
def overlap(a,b):return min(a[2],b[2])-max(a[0],b[0])>.01 and min(a[3],b[3])-max(a[1],b[1])>.01
def rect(row):return [row['min'][0],row['min'][2],row['max'][0],row['max'][2]]
for a,b in itertools.combinations(rows,2):assert not overlap(rect(a),rect(b)),(a['plot'],b['plot'])
roads=[]
for name,x1,z1,x2,z2,w in data['roads']:
 roads.append((name,[min(x1,x2)-(w/2 if x1==x2 else 0),-max(z1,z2)-(w/2 if z1==z2 else 0),max(x1,x2)+(w/2 if x1==x2 else 0),-min(z1,z2)+(w/2 if z1==z2 else 0)]))
for row in rows:
 p=plots[row['plot']];a=rect(row);q=[p['x']-p['world_width']/2,-p['z']-p['world_depth']/2,p['x']+p['world_width']/2,-p['z']+p['world_depth']/2]
 assert a[0]>=q[0]-.01 and a[1]>=q[1]-.01 and a[2]<=q[2]+.01 and a[3]<=q[3]+.01,row['plot']
 for name,road in roads:assert not overlap(a,road),(row['plot'],name)
report=dict(preview_ground_y=12,buildings=len(rows),masters=len(set(x['model'] for x in rows)),copies=33,reserve='LC-17',visible_parts=sum(x['parts'] for x in rows),lights=sum(x['lights'] for x in rows),building_overlaps=0,main_road_overlaps=0,plot_overflows=0,scope='Numerical source execution and AABBs; no Roblox rendering/physics/performance validation',placements=rows)
(r/'docs/city/placement-report.json').write_text(json.dumps(report,indent=2)+'\n')
print({k:v for k,v in report.items() if k!='placements'})
