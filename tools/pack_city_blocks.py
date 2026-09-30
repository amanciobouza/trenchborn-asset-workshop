"""Pack all unchanged plot envelopes into paired street-facing rows.
Replaces the sparse district road grid, as requested by the user. Standard library only.
"""
from pathlib import Path
import json,math,copy
r=Path(__file__).resolve().parents[1]
d=json.loads((r/'docs/city/city-plan-v5.json').read_text())
ordered=sorted(d['plots'],key=lambda p:(-p['depth'],p['district'],p['id']))
gap=2;street=12;avenue=16
candidates=[]
for cap in range(1000,1701,10):
 rows=[];row=[];width=0
 for p in ordered:
  w=p['width']
  if row and width+gap+w>cap:rows.append(row);row=[];width=0
  row.append(p);width+=w+(gap if len(row)>1 else 0)
 if row:rows.append(row)
 if len(rows)%2:continue
 widths=[sum(p['width'] for p in row)+gap*(len(row)-1) for row in rows]
 heights=[max(p['depth'] for p in row) for row in rows]
 W=max(widths);H=sum(heights)+len(rows)//2*(street+2)+(len(rows)//2-1)*gap
 if max(W/H,H/W)>1.65:continue
 candidates.append((W*H,W,H,rows,heights))
assert candidates
_,W,H,rows,heights=min(candidates,key=lambda q:q[0])
d['roads']=[];bottom=-H/2;street_centres=[]
for i in range(0,len(rows),2):
 southheight,northheight=heights[i:i+2]
 zroad=bottom+southheight+1+street/2
 street_centres.append(zroad)
 for j in [i,i+1]:
  south=j==i;row=sorted(rows[j],key=lambda p:(p['x'],p['id']))
  x=-W/2
  for p in row:
   p['x']=x+p['width']/2
   p['front']='N' if south else 'S'
   p['z']=zroad+(-1 if south else 1)*(street/2+1+p['depth']/2)
   p['world_width']=p['width'];p['world_depth']=p['depth']
   frontz=p['z']+(1 if south else -1)*p['depth']/2
   p['access']=[[p['x'],frontz],[p['x'],zroad]]
   x+=p['width']+gap
 d['roads'].append([f'Block Street {i//2+1}',-W/2-4,zroad,W/2+1+avenue,zroad,street])
 bottom=zroad+street/2+1+northheight+gap
# Connect short block streets along the eastern edge, leaving the centre fully built.
ax=W/2+1+avenue/2
south=-H/2-10;north=H/2+10
out_s=south-24;out_n=north+24
d['roads'] += [
 ['East City Avenue',ax,south,ax,north,avenue],
 ['North Connection',0,north,ax,north,avenue],
 ['South Connection',0,south,ax,south,avenue],
 ['City Arrival Link',0,north,0,out_n,avenue],
 ['Mega City Link',0,out_s,0,south,avenue]]
d['ground_bounds']=[math.floor(-W/2-8),math.floor(out_s-8),math.ceil(ax+avenue/2+8),math.ceil(out_n+8)]
d['connection_markers']=[['NORD · CITY',-out_n],['SÜD · MEGA CITY',-out_s]]
d['review_spawn']=[ax,-street_centres[len(street_centres)//2]]
d['version']='Large City - dense blocks preview v6'
d['note']='User requested still tighter placement. Repacked as paired rows; entrances face new 12-stud streets. 2-stud lateral plot gaps, 1-stud front verge, 16-stud eastern avenue. All original buildings, scale and plot IDs retained. City north / Mega City south. Gate C pending.'
d['packing']={'row_count':len(rows),'block_count':len(rows)//2,'building_envelope_width':W,'building_envelope_depth':H,'lateral_plot_gap':gap,'street_width':street,'avenue_width':avenue}
for info in d['models'].values():
 p=next(p for p in d['plots'] if p['id']==info['master_plot']);info['width']=p['width'];info['depth']=p['depth']
(r/'docs/city/city-plan.json').write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n')
print(d['packing']);print('Ground bounds:',d['ground_bounds'])
