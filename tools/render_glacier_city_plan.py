import json,matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle,Circle,Patch,Polygon
from pathlib import Path
root=Path(__file__).resolve().parents[1];data=json.loads((root/'docs/mega-city/plans/00-glacier-layout.json').read_text())
colors={'Transit Nexus':'#40a6d1','Neon Quarter':'#ca4aae','Stack District':'#d99f46','Reactor Works':'#ce6931','Research Enclave':'#6cbb72','Corporate Heights':'#7479dc'}
fig,ax=plt.subplots(figsize=(12,15),facecolor='#0c1928');ax.set_facecolor('#0c1928')
scene=json.loads((root/'tmp/mega-city/glacier-blockout-scene.json').read_text())
for name in ['OpenSea','DeepRift','Fjord','RockTerrace','SnowShelf','TerraceRamp','GuardianLand','GlacierWall','RearGlacierWall','MainRoad','MainRoadRamp','CrossStreet','FinalApproach','RoadBridge','GuardianPlaza','RailRouteGuide']:
 for p in scene:
  if p['name']!=name:continue
  color=[v/255 for v in p['color']]
  if 'polygon' in p:ax.add_patch(Polygon([(v[0],v[2]) for v in p['polygon']],facecolor=color,edgecolor='none'))
  else:
   x,_,z=p['pos'];w,_,d=p['size'];ax.add_patch(Rectangle((x-w/2,z-d/2),w,d,facecolor=color))
for p in data['pillars']:
 ax.add_patch(Polygon(p['footprint'],facecolor='#8ddced',edgecolor='#e6faff',lw=2));ax.text(p['x'],p['z'],'EIS',ha='center',va='center',fontsize=8,color='#144a68')
for b in data['buildings']:
 x,_,z=b['center'];w,_,d=b['size'];ax.add_patch(Rectangle((x-w/2,z-d/2),w,d,angle=-b.get('yaw',0)*180/3.141592653589793,rotation_point='center',facecolor=colors[b['district']],edgecolor='#173447',lw=.7));ax.text(x,z,str(b['asset']).zfill(2),ha='center',va='center',fontsize=6.5,color='white',weight='bold')
for txt,x,z in [('TRANSIT NEXUS',-1350,250),('NEON QUARTER',-1400,1800),('STACK DISTRICT',-1400,3420),('REACTOR WORKS',1400,400),('RESEARCH ENCLAVE',1400,3490),('CORPORATE HEIGHTS',-1400,6740),('GUARDIAN-PLATZ',0,7100),('MEGA TOWER',0,7980)]:ax.text(x,z,txt,ha='center',va='center',fontsize=10,color='#102638',weight='bold')
ax.annotate('KANAGAWA / MEERESZUGANG',xy=(0,100),xytext=(0,-600),ha='center',color='white',arrowprops={'arrowstyle':'->','color':'#62d8fa','lw':3},fontsize=10)
ax.text(0,3950,'TIEFER RISS',rotation=90,ha='center',va='center',color='#acc4d8',fontsize=10)
ax.text(0,700,'FJORD',rotation=90,ha='center',color='white',fontsize=9)
ax.set_xlim(-2800,2800);ax.set_ylim(-800,8450);ax.set_aspect('equal');ax.set_xticks([]);ax.set_yticks([])
ax.set_title('MEGA CITY · ORGANISCHER GLETSCHER-ENTWURF\n85 Bauplätze · 6 Eissäulen · 2 Strassenbrücken',color='white',fontsize=17,pad=18)
fig.text(.5,.055,'Draufsicht ohne Eisdecke · Zahlen = MC-Gebäudetyp · Magenta = Hochbahntrasse\nRäumlicher Entwurf; Massstab, Kaiju-Freiraum und Kamera noch nicht in Studio abgenommen.',ha='center',color='#c4d5e3',fontsize=9)
ax.legend(handles=[Patch(color=c,label=d) for d,c in colors.items()],loc='upper left',bbox_to_anchor=(0,-.035),ncol=3,fontsize=8,frameon=False,labelcolor='white')
fig.subplots_adjust(bottom=.14,top=.93)
fig.savefig(root/'docs/mega-city/plans/00-glacier-layout.svg',facecolor=fig.get_facecolor())
fig.savefig(root/'tmp/mega-city/glacier-layout.png',dpi=130,facecolor=fig.get_facecolor())
