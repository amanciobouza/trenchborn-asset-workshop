import json,matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle,Circle,Patch
from pathlib import Path
root=Path(__file__).resolve().parents[1];data=json.loads((root/'docs/mega-city/plans/00-glacier-layout.json').read_text())
colors={'Transit Nexus':'#40a6d1','Neon Quarter':'#ca4aae','Stack District':'#d99f46','Reactor Works':'#ce6931','Research Enclave':'#6cbb72','Corporate Heights':'#7479dc'}
fig,ax=plt.subplots(figsize=(12,15),facecolor='#0c1928');ax.set_facecolor('#0c1928')
for side in [-1,1]:
 ax.add_patch(Rectangle((side*1320-1080,0),2160,8150,facecolor='#aec5d0'))
 ax.add_patch(Rectangle((side*2530-130,-50),260,8300,facecolor='#80c4df'))
 ax.add_patch(Rectangle((side*360-90,0),180,6750,facecolor='#26384d'))
ax.add_patch(Rectangle((-240,0),480,1650,facecolor='#175781'))
ax.add_patch(Rectangle((-240,1650),480,5000,facecolor='#050912'))
ax.add_patch(Rectangle((-550,6650),1100,1500,facecolor='#aec5d0'))
ax.add_patch(Rectangle((-450,6700),900,800,facecolor='#697697'))
for z in [1700,5700]:ax.add_patch(Rectangle((-450,z-110),900,220,facecolor='#438398'))
for z in [1700,3300,5700,6750]:
 for side in [-1,1]:ax.add_patch(Rectangle((side*1190-770,z-90),1540,180,facecolor='#34485c'))
ax.plot([-360,-360,360,360,-360],[1500,6150,6150,1500,1500],color='#ed52cf',lw=2,ls='--')
for p in data['pillars']:
 ax.add_patch(Circle((p['x'],p['z']),200,facecolor='#8ddced',edgecolor='#e6faff',lw=2));ax.text(p['x'],p['z'],'EIS',ha='center',va='center',fontsize=8,color='#144a68')
for b in data['buildings']:
 x,_,z=b['center'];w,_,d=b['size'];ax.add_patch(Rectangle((x-w/2,z-d/2),w,d,facecolor=colors[b['district']],edgecolor='#173447',lw=.7));ax.text(x,z,str(b['asset']).zfill(2),ha='center',va='center',fontsize=6.5,color='white',weight='bold')
for txt,x,z in [('TRANSIT NEXUS',-1350,250),('NEON QUARTER',-1400,1800),('STACK DISTRICT',-1400,3420),('REACTOR WORKS',1400,400),('RESEARCH ENCLAVE',1400,3490),('CORPORATE HEIGHTS',-1400,6740),('GUARDIAN-PLATZ',0,7100),('MEGA TOWER',0,7980)]:ax.text(x,z,txt,ha='center',va='center',fontsize=10,color='#102638',weight='bold')
ax.annotate('KANAGAWA / MEERESZUGANG',xy=(0,100),xytext=(0,-600),ha='center',color='white',arrowprops={'arrowstyle':'->','color':'#62d8fa','lw':3},fontsize=10)
ax.text(0,3950,'TIEFER RISS',rotation=90,ha='center',va='center',color='#acc4d8',fontsize=10)
ax.text(0,700,'FJORD',rotation=90,ha='center',color='white',fontsize=9)
ax.set_xlim(-2800,2800);ax.set_ylim(-800,8450);ax.set_aspect('equal');ax.set_xticks([]);ax.set_yticks([])
ax.set_title('MEGA CITY · GLETSCHER-BLOCKOUT\n85 Bauplätze · 6 Eissäulen · 2 Strassenbrücken',color='white',fontsize=17,pad=18)
fig.text(.5,.055,'Draufsicht ohne Eisdecke · Zahlen = MC-Gebäudetyp · Magenta gestrichelt = Hochbahntrasse\nRäumlicher Entwurf; Massstab, Kaiju-Freiraum und Kamera noch nicht in Studio abgenommen.',ha='center',color='#c4d5e3',fontsize=9)
ax.legend(handles=[Patch(color=c,label=d) for d,c in colors.items()],loc='upper left',bbox_to_anchor=(0,-.035),ncol=3,fontsize=8,frameon=False,labelcolor='white')
fig.subplots_adjust(bottom=.14,top=.93)
fig.savefig(root/'docs/mega-city/plans/00-glacier-layout.svg',facecolor=fig.get_facecolor())
fig.savefig(root/'tmp/mega-city/glacier-layout.png',dpi=130,facecolor=fig.get_facecolor())
