"""Rebuild approved geometry, apply P5 dressing, export native models + QA."""
import base64, copy, json, math, struct
from pathlib import Path
import xml.etree.ElementTree as E
import numpy as np
import build_geometry as G

BASE=Path(__file__).resolve().parents[1]
PALETTE={'FruitSegment':((249,157,27),256),'Leaf':((76,139,43),256),
 'Stem':((112,66,35),512),'InnerCore':((255,112,17),288),
 'RockPlate':((49,43,42),896),'EndCap':((46,58,72),1088),
 'ProtectionRail':((66,83,97),1088),'Core':((32,222,255),288),
 'ShellPanel':((234,218,181),256),'ShellBack':((234,218,181),256),
 'FangBody':((243,228,194),256)}

def name(o):return o.find("Properties/string[@name='Name']").text
def setp(o,tag,key,value):
    p=o.find('Properties');old=p.find(f"*[@name='{key}']")
    if old is not None:p.remove(old)
    return G.prop(p,tag,key,value)
def rgb(o,color,material=256):
    r,g,b=map(int,color);setp(o,'Color3uint8','Color3uint8',(255<<24)|(r<<16)|(g<<8)|b)
    setp(o,'token','Material',material)
def attributes(o,values):
    def s(x):
        b=x.encode();return struct.pack('<I',len(b))+b
    data=struct.pack('<I',len(values))
    for k,v in values.items():
        data+=s(k)
        if isinstance(v,bool):data+=b'\x03'+bytes([int(v)])
        else:data+=b'\x02'+s(v)
    setp(o,'BinaryString','AttributesSerialize',base64.b64encode(data).decode())
def color_property(p,key,color):
    el=E.SubElement(p,'Color3',{'name':key})
    for k,v in zip('RGB',color):E.SubElement(el,k).text=str(v/255)
def position(o):return np.array([float(o.find(f'Properties/CoordinateFrame/{k}').text) for k in 'XYZ'])
def move(o,pos):
    for k,v in zip('XYZ',pos):o.find(f'Properties/CoordinateFrame/{k}').text=str(v)
def bar(a,parent,n,start,end,color,width=.09):
    start,end=np.array(start),np.array(end);up=(end-start)/np.linalg.norm(end-start)
    axis=np.array([0.,0.,1.])
    if abs(np.dot(up,axis))>.95:axis=np.array([1.,0.,0.])
    right=np.cross(up,axis);right/=np.linalg.norm(right);back=np.cross(right,up)
    o=a.part(n,(start+end)/2,[width,np.linalg.norm(end-start)+width,width],np.column_stack((right,up,back)),parent=parent)
    rgb(o,color,288);setp(o,'bool','CanQuery','false');return o

for idx,a in enumerate(G.assets):
    geo=a.geo;effects=next(o for o in a.obj.findall('Item') if name(o)=='Effects')
    colors={}
    for i,o in enumerate(list(geo)):
        if o.tag!='Item':continue
        n=name(o);color,material=PALETTE[n]
        factor=1+((i//2)%5-2)*.025
        color=tuple(min(255,round(c*factor)) for c in color)
        if n=='FangBody' and position(o)[1]<1.25:color=(150,118,80);material=896
        rgb(o,color,material)
        if n in ('InnerCore','Core'):
            geo.remove(o);effects.append(o);setp(o,'bool','CanQuery','false')
    if idx==3:
        # Thin exterior patches; original cream-coloured shell remains the interior.
        for i,o in enumerate(list(geo.findall('Item'))):
            if name(o)!='ShellPanel' or (i//4)%12 not in (1,5,8):continue
            patch=copy.deepcopy(o);G.counter+=1;patch.set('referent',f'RBX{G.counter}')
            setp(patch,'string','Name','TurquoiseMarking')
            c=position(o);normal=np.array([c[0]/3.4**2,(c[1]-2.55)/2.45**2,(c[2]+1.25)/5.2**2]);normal/=np.linalg.norm(normal)
            move(patch,c+normal*.135)
            patch.find("Properties/Vector3[@name='size']/X").text='.025'
            rgb(patch,(45,143,150));geo.append(patch)
    if idx==4:
        profile=[(0,1.25,-.6,1.2),(1.1,1.5,-.7,1.25),(2.6,1.2,-.7,1),(4.2,.92,-.45,.8),(5.6,.65,.05,.6),(6.8,.36,.7,.36),(7.8,.08,1.35,.1)]
        def surface(y,dx):
            for lo,hi in zip(profile,profile[1:]):
                if lo[0]<=y<=hi[0]:
                    t=(y-lo[0])/(hi[0]-lo[0]);r,cx,rz=np.array(lo[1:])*(1-t)+np.array(hi[1:])*t
                    return [cx+dx,y+.023,-rz+abs(dx)*rz/r*(math.sqrt(2)-1)-.055]
            raise ValueError(y)
        path=[(1.05,.22),(1.75,-.16),(2.6,.17),(3.45,-.20),(4.2,.09),(5.0,-.12),(5.6,.1),(6.6,0)]
        for u,v in zip(path,path[1:]):bar(a,effects,'GoldenVein',surface(*u),surface(*v),(255,192,64),.075)
        for u,v in [((2.6,.17),(3.05,.65)),((4.2,.09),(4.7,.49)),((1.75,-.16),(2.15,-.75))]:bar(a,effects,'VeinBranch',surface(*u),surface(*v),(255,192,64),.065)
    if idx==2:
        for y in (.86,5.19):
            for j in range(8):
                t1=j*math.pi/4;t2=(j+1)*math.pi/4
                bar(a,effects,'CyanRing',[1.35*math.cos(t1),y,1.35*math.sin(t1)],[1.35*math.cos(t2),y,1.35*math.sin(t2)],(50,221,255),.10)
    accent=[(255,183,57),(255,113,29),(50,218,255),(97,193,180),(255,199,87)][idx]
    anchor=a.part('EffectsAnchor',[0,[2.6,2.1,3,2.5,4][idx],0],[.1,.1,.1],parent=effects,hidden=True)
    light,p=G.item(anchor,'PointLight','AccentLight');color_property(p,'Color',accent)
    G.prop(p,'float','Brightness',[.45,1.8,1.5,.35,.8][idx]);G.prop(p,'float','Range',[7,9,9,7,9][idx]);G.prop(p,'bool','Shadows','false');G.prop(p,'bool','Enabled','true')
    if idx in (0,1,4):
        em,p=G.item(anchor,'ParticleEmitter','DiscoveryParticles')
        G.prop(p,'bool','Enabled','true');G.prop(p,'float','Rate',[2,4,0,0,1][idx])
        G.prop(p,'NumberRange','Lifetime','0.8 1.6');G.prop(p,'NumberRange','Speed','0.35 0.8')
        G.prop(p,'NumberSequence','Size','0 0.08 0 0.5 0.14 0 1 0 0 ')
        G.prop(p,'NumberSequence','Transparency','0 0.25 0 0.75 0.35 0 1 1 0 ')
        r,g,b=[v/255 for v in accent];G.prop(p,'ColorSequence','Color',f'0 {r} {g} {b} 0 1 {r} {g} {b} 0 ')
        G.prop(p,'float','LightEmission',.8);G.prop(p,'bool','LockedToPart','false')
        texture=E.SubElement(p,'Content',{'name':'Texture'});E.SubElement(texture,'url').text='rbxasset://textures/particles/sparkles_main.dds'
        spread=E.SubElement(p,'Vector2',{'name':'SpreadAngle'});E.SubElement(spread,'X').text='35';E.SubElement(spread,'Y').text='35'
    attributes(a.obj,{'ItemId':a.name,'CityId':['Village','SmallTown','City','LargeCity','MegaCity'][idx],
        'Need':['Food','Warmth','Energy','Shelter','Strength'][idx],'BuildStage':'P5_Dressing',
        'GeometryApproved':True,'EffectsEnabled':True,'Version':'1.1.0'})
    G.write(a.doc,BASE/'models'/(a.name+'.rbxmx'))

scene=G.doc();group,_=G.item(scene,'Model','Trenchborn_Collectibles_GateB')
for i,a in enumerate(G.assets):
    clone=copy.deepcopy(a.obj)
    for o in clone.iter('Item'):
        if o.get('class') in ('Part','WedgePart'):move(o,position(o)+np.array([(i-2)*11,0,0]))
    group.append(clone)
G.write(scene,BASE/'preview/Trenchborn_Collectibles_GateB.rbxmx')

# Render the actual serialized wedge surfaces, including exterior markings.
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
fig=plt.figure(figsize=(18,6),facecolor='#202733')
report=[]
for i,a in enumerate(G.assets):
    faces=[];colors=[];count=0
    for o in a.obj.iter('Item'):
        if o.get('class') not in ('Part','WedgePart'):continue
        p=o.find('Properties')
        if float(p.find("float[@name='Transparency']").text)==1:continue
        count+=1;size=np.array([float(p.find(f"Vector3[@name='size']/{k}").text) for k in 'XYZ'])
        c=p.find('CoordinateFrame');R=np.array([[float(c.find(f'R{x}{y}').text) for y in range(3)] for x in range(3)])
        if o.get('class')=='WedgePart':
            v=np.array([[x,y,z] for x in [-.5,.5] for y,z in [(-.5,-.5),(-.5,.5),(.5,.5)]])*size
            indices=[(0,1,2),(3,5,4),(0,3,4,1),(1,4,5,2),(0,2,5,3)]
        else:
            v=np.array([[x,y,z] for x in [-.5,.5] for y in [-.5,.5] for z in [-.5,.5]])*size
            indices=[(0,1,3,2),(4,6,7,5),(0,4,5,1),(2,3,7,6),(0,2,6,4),(1,5,7,3)]
        v=(v@R.T+position(o))[:,[0,2,1]]
        packed=int(p.find("Color3uint8[@name='Color3uint8']").text);color=np.array([(packed>>16)&255,(packed>>8)&255,packed&255])/255
        for indices1 in indices:
            f=v[list(indices1)];normal=np.cross(f[1]-f[0],f[2]-f[0]);normal/=max(np.linalg.norm(normal),1e-9)
            shade=.65+.32*abs(normal@np.array([-.4,-.5,.76]))
            if p.find("token[@name='Material']").text=='288':shade=1
            faces.append(f);colors.append(color*shade)
    ax=fig.add_subplot(1,5,i+1,projection='3d',facecolor='#202733')
    ax.add_collection3d(Poly3DCollection(faces,facecolors=colors,edgecolors='none'))
    ax.set(xlim=(-4,4),ylim=(-4,4),zlim=(0,9));ax.set_box_aspect((1,1,1.12));ax.view_init(19,-65);ax.set_axis_off()
    ax.set_title(['FOOD','WARMTH','ENERGY','SHELTER','STRENGTH'][i],color='white',fontsize=13,pad=-18)
    report.append({'model':a.name,'visible_parts':count,'stage':'P5_Dressing'})
fig.suptitle('TRENCHBORN / P5 — COLOUR & MATERIAL REVIEW',color='white',fontsize=19,y=.92)
fig.text(.5,.1,'Native model geometry and colours • Lights and particles require Studio review',ha='center',color='#c4cbd6',fontsize=12)
fig.subplots_adjust(left=.01,right=.99,wspace=0,top=.85,bottom=.13)
fig.savefig(BASE/'docs/Dressing_Preview.png',dpi=150,facecolor=fig.get_facecolor());plt.close(fig)
(BASE/'docs/dressing_report.json').write_text(json.dumps(report,indent=2)+'\n')
print('P5 dressing exported:',report)
