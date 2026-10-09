"""One-time constrained compaction from the archived v3 plan (requires scipy).
Keeps district/road topology and building scale; minimises distance to dense city blocks.
"""
from pathlib import Path
import json,itertools,math
import numpy as np
from scipy.optimize import linprog
r=Path(__file__).resolve().parents[1]
d=json.loads((r/'docs/city/city-plan-v3.json').read_text())
report=json.loads((r/'docs/city/placement-report-v3.json').read_text())
measured={x['plot']:x for x in report['placements']}
# Tighten provisional old-model reservations around the unchanged measured geometry.
for p in d['plots']:
 if p['model'].startswith('B'):
  b=measured[p['place_id']]
  wx=2*max(p['x']-b['min'][0],b['max'][0]-p['x'])+8
  wz=2*max(-p['z']-b['min'][2],b['max'][2]+p['z'])+8
  p['world_width']=math.ceil(wx/2)*2;p['world_depth']=math.ceil(wz/2)*2
  p['width'],p['depth']=(p['world_width'],p['world_depth']) if p['front'] in ['N','S'] else (p['world_depth'],p['world_width'])
for road in d['roads']:road[5]=24 if road[5]==64 else 16
axes=[sorted({0,*[p[k] for p in d['plots']],*[v for rd in d['roads'] for v in (rd[j],rd[j+2])]}) for k,j in [('x',1),('z',2)]]
keys=[(a,v) for a,vals in enumerate(axes) for v in vals];ix={k:i for i,k in enumerate(keys)};n=len(keys)
# A rectangle edge is (coordinate variable, constant offset).
objects=[]
for p in d['plots']:
 objects.append((p['place_id'],[(ix[(0,p['x'])],-p['world_width']/2),(ix[(1,p['z'])],-p['world_depth']/2),(ix[(0,p['x'])],p['world_width']/2),(ix[(1,p['z'])],p['world_depth']/2)],False))
for name,x1,z1,x2,z2,w in d['roads']:
 objects.append((name,[(ix[(0,min(x1,x2))],-w/2 if x1==x2 else 0),(ix[(1,min(z1,z2))],-w/2 if z1==z2 else 0),(ix[(0,max(x1,x2))],w/2 if x1==x2 else 0),(ix[(1,max(z1,z2))],w/2 if z1==z2 else 0)],True))
A=[];B=[]
def constraint(left,right,gap):
 a=np.zeros(2*n);a[left[0]]+=1;a[right[0]]-=1
 A.append(a);B.append(right[1]-left[1]-gap)
def original(edge):return keys[edge[0]][1]+edge[1]
for a,b in itertools.combinations(objects,2):
 if a[2] and b[2]:continue
 candidates=[]
 for axis in [0,1]:
  for lo,hi in [(a,b),(b,a)]:
   gap=original(hi[1][axis])-original(lo[1][axis+2])
   if gap>=0:candidates.append((gap,lo[1][axis+2],hi[1][axis]))
 assert candidates,(a[0],b[0])
 _,left,right=max(candidates,key=lambda c:c[0]);constraint(left,right,2 if a[2] or b[2] else 4)
for axis,vals in enumerate(axes):
 for a,b in zip(vals,vals[1:]):constraint((ix[(axis,a)],0),(ix[(axis,b)],0),.1)
for i,(_,v) in enumerate(keys):
 row=np.zeros(2*n);row[i]=1;row[n+i]=-1;A.append(row);B.append(v*.2)
 row=np.zeros(2*n);row[i]=-1;row[n+i]=-1;A.append(row);B.append(-v*.2)
bounds=[(0,0) if v==0 else (None,None) for _,v in keys]+[(0,None)]*n
cost=np.r_[np.zeros(n),np.ones(n)]
for axis,vals in enumerate(axes):
 cost[ix[(axis,vals[0])]]-=100
 cost[ix[(axis,vals[-1])]]+=100
res=linprog(cost,A_ub=np.array(A),b_ub=np.array(B),bounds=bounds,method='highs');assert res.success,res.message
maps=[{v:round(res.x[ix[(axis,v)]],3) for v in vals} for axis,vals in enumerate(axes)]
for p in d['plots']:
 p['x']=maps[0][p['x']];p['z']=maps[1][p['z']]
 b=p['access'][1];b=[maps[0][b[0]],maps[1][b[1]]]
 vx,vz={'N':(0,1),'S':(0,-1),'E':(1,0),'W':(-1,0)}[p['front']]
 p['access']=[[p['x']+vx*p['world_width']/2,p['z']+vz*p['world_depth']/2],b]
for rd in d['roads']:
 for j in [1,3]:rd[j]=maps[0][rd[j]]
 for j in [2,4]:rd[j]=maps[1][rd[j]]
for info in d['models'].values():
 p=next(p for p in d['plots'] if p['id']==info['master_plot']);info['width']=p['width'];info['depth']=p['depth']
d['version']='Large City - compact assembled preview v5'
d['note']='Dense layout requested by user. Unchanged building scale; reduced spacing, tighter old-model reservations, 24/16-stud roads. Flat preview; Gate C pending.'
pzmin=min(p['z']-p['world_depth']/2 for p in d['plots']);pzmax=max(p['z']+p['world_depth']/2 for p in d['plots'])
for rd in d['roads']:
 if rd[0]=='City Arrival Link':rd[4]=max(rd[4],pzmax+64)
 if rd[0]=='Mega City Link':rd[2]=min(rd[2],pzmin-64)
d['ground_bounds']=[math.floor(min(p['x']-p['world_width']/2 for p in d['plots'])-40),math.floor(min(rd[j] for rd in d['roads'] for j in [2,4])-40),math.ceil(max(p['x']+p['world_width']/2 for p in d['plots'])+40),math.ceil(max(rd[j] for rd in d['roads'] for j in [2,4])+40)]
d['connection_markers']=[['NORD · CITY',-next(rd[4] for rd in d['roads'] if rd[0]=='City Arrival Link')],['SÜD · MEGA CITY',-next(rd[2] for rd in d['roads'] if rd[0]=='Mega City Link')]]
(r/'docs/city/city-plan.json').write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
print('New ground bounds:',d['ground_bounds'])
