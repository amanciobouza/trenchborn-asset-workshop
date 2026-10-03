"""Render the exact native assembly footprint and connected road surfaces."""
from pathlib import Path
import json,math,matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Polygon,Rectangle,Patch
ROOT=Path(__file__).resolve().parents[1]
data=json.loads((ROOT/'docs/mega-city/plans/00-mega-city-final-layout.json').read_text())
scene=json.loads((ROOT/'tmp/mega-city/mega-city-final-scene.json').read_text())
colors={'Transit Nexus':'#40a6d1','Neon Quarter':'#ca4aae','Stack District':'#d99f46','Reactor Works':'#ce6931','Research Enclave':'#6cbb72','Corporate Heights':'#7479dc'}
fig,ax=plt.subplots(figsize=(14,17),facecolor='#0c1928');ax.set_facecolor('#0c1928')
for key in ['terrainProxy','roads']:
 for p in scene[key]:
  if key=='terrainProxy' and p['name'] not in ['SnowShelf','TerraceRamp','GlacierWall','RearGlacierWall','GuardianLand','ArrivalApron']:continue
  color=[v/255 for v in p['color']]
  if 'polygon' in p:ax.add_patch(Polygon([(v[0],v[2]) for v in p['polygon']],facecolor=color,edgecolor='none'))
  else:
   x,_,z=p['pos'];w,_,d=p['size'];ax.add_patch(Rectangle((x-w/2,z-d/2),w,d,facecolor=color))
for p in data['pillars']:ax.add_patch(Polygon(p['footprint'],facecolor='#8ddced',edgecolor='#daf5fc',lw=1.4))
for b in data['buildings']:
 x,_,z=b['center'];w,_,d=b['size'];a=b['yaw'];c,s=math.cos(a),math.sin(a)
 pts=[(x+c*px+s*pz,z-s*px+c*pz) for px,pz in [(-w/2,-d/2),(w/2,-d/2),(w/2,d/2),(-w/2,d/2)]]
 ax.add_patch(Polygon(pts,facecolor=colors[b['homeDistrict']],edgecolor='#16283a',lw=.7))
 ax.text(x,z,str(b['asset']).zfill(2),ha='center',va='center',fontsize=6.5,color='white',weight='bold')
for g in data['guides']:
 if g['name']=='RIFT_DEPTH_GUIDE':continue
 pts=g['points'];ax.plot([p[0] for p in pts],[p[2] for p in pts],color=[v/255 for v in g['color']],lw=1.3)
for p in scene['rift']:
 if p['name'] not in ['DeepThermalGlow','FracturedFjordIce']:continue
 x,_,z=p['pos'];ax.scatter([x],[z],s=9 if p['name']=='DeepThermalGlow' else 18,c='#ff942e' if p['name']=='DeepThermalGlow' else '#c5ebf3',marker='s',linewidths=0)
for text,x,z in [('TRANSIT / NEON',-1400,150),('NEON / WOHNEN',-1550,2950),('WOHNEN / CORPORATE',-1500,5670),('ENERGIE / FORSCHUNG',1400,3250),('CORPORATE HEIGHTS',-1250,6850),('GUARDIAN-PLATZ',0,7130),('MEGA TOWER',0,7980)]:ax.text(x,z,text,ha='center',va='center',fontsize=8.5,color='#172d40',weight='bold',bbox=dict(facecolor='#c6dce5',edgecolor='none',alpha=.8,pad=2))
ax.annotate('KANAGAWA / MEERESZUGANG',xy=(-650,-105),xytext=(0,-670),ha='center',color='white',arrowprops={'arrowstyle':'->','color':'#62d8fa','lw':2},fontsize=10)
ax.text(0,3950,'RISS · NEBEL · DAMPF · TIEFE GLUT',rotation=90,ha='center',va='center',color='#c5d9e5',fontsize=9)
ax.set_xlim(-2900,2900);ax.set_ylim(-850,8450);ax.set_aspect('equal');ax.set_xticks([]);ax.set_yticks([])
ax.set_title('MEGA CITY · ZUSAMMENGESETZTE STADT\n85 echte Gebäude · durchmischte Quartiere · verbundenes Strassennetz',color='white',fontsize=17,pad=18)
ax.legend(handles=[Patch(color=c,label=d) for d,c in colors.items()],loc='upper left',bbox_to_anchor=(0,-.02),ncol=3,fontsize=8,frameon=False,labelcolor='white')
fig.text(.5,.047,'Cyan: Risskante · Grün: Küstenlinie · Orange: Glut in der Tiefe\nFarben bezeichnen Gebäudefamilien, keine District-Grenzen. Gelände und Studio-Spieltest stehen noch aus.',ha='center',color='#c4d5e3',fontsize=9)
fig.subplots_adjust(bottom=.12,top=.93)
fig.savefig(ROOT/'docs/mega-city/plans/00-mega-city-final-layout.svg',facecolor=fig.get_facecolor())
fig.savefig(ROOT/'tmp/mega-city/mega-city-final-layout.png',dpi=130,facecolor=fig.get_facecolor())
