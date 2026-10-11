"""Gate B native Roblox geometry. Python 3 + numpy; matplotlib for QA only."""
from pathlib import Path
import math, json, base64, struct, copy, zipfile
import xml.etree.ElementTree as E
import numpy as np

OUT = Path(__file__).resolve().parents[1] / "models"
counter = 0
def item(parent, cls, name):
    global counter
    counter += 1
    obj = E.SubElement(parent, 'Item', {'class':cls, 'referent':f'RBX{counter}'})
    p=E.SubElement(obj,'Properties'); prop(p,'string','Name',name)
    return obj,p
def prop(p,tag,name,value):
    el=E.SubElement(p,tag,{'name':name}); el.text=str(value); return el
def vec(p,tag,name,v):
    el=E.SubElement(p,tag,{'name':name})
    for k,x in zip('XYZ',v): E.SubElement(el,k).text=f'{x:.8f}'
def cf(p,name,pos,R=np.eye(3)):
    el=E.SubElement(p,'CoordinateFrame',{'name':name})
    for k,x in zip('XYZ',pos): E.SubElement(el,k).text=f'{x:.8f}'
    for i in range(3):
        for j in range(3): E.SubElement(el,f'R{i}{j}').text=f'{R[i,j]:.8f}'
def attrs(p,values):
    def s(v):
        b=v.encode(); return struct.pack('<I',len(b))+b
    b=struct.pack('<I',len(values))
    for k,v in values.items(): b+=s(k)+b'\x02'+s(v)
    prop(p,'BinaryString','AttributesSerialize',base64.b64encode(b).decode())
def doc(): return E.Element('roblox',{'version':'4'})
def write(root,path):
    E.indent(root); E.ElementTree(root).write(path,encoding='utf-8',xml_declaration=True)

class Asset:
    def __init__(self,name,city,need):
        self.doc=doc(); self.obj,self.p=item(self.doc,'Model',name)
        attrs(self.p,{'ItemId':name,'CityId':city,'Need':need,'BuildStage':'P4_Geometry_GateB','Version':'1.0.0'})
        self.geo,_=item(self.obj,'Folder','Geometry'); item(self.obj,'Folder','Effects')
        self.parts=[]; self.faces=[]; self.shades=[]
        root=self.part('Root',[0,0,0],[.1,.1,.1],parent=self.obj,hidden=True)
        prop(self.p,'Ref','PrimaryPart',root.get('referent'))
        a,p=item(root,'Attachment','PickupAttachment'); cf(p,'CFrame',[0,1,0])
        self.name=name
    def part(self,name,pos,size,R=np.eye(3),cls='Part',parent=None,hidden=False,shade=.68):
        o,p=item(self.geo if parent is None else parent,cls,name)
        vec(p,'Vector3','size',size); cf(p,'CFrame',pos,R)
        for n,val in [('Anchored',True),('CanCollide',False),('CanTouch',False),('CanQuery',not hidden)]:
            prop(p,'bool',n,str(val).lower())
        prop(p,'float','Transparency',1 if hidden else 0)
        prop(p,'token','Material',256)
        channel=round(shade*255)
        prop(p,'Color3uint8','Color3uint8',(255<<24)|(channel<<16)|(channel<<8)|channel)
        for face in ['Top','Bottom','Front','Back','Left','Right']: prop(p,'token',face+'Surface',0)
        if cls=='Part': prop(p,'token','shape',1)
        if not hidden: self.parts.append((np.array(pos),np.array(size),R,cls))
        return o
    def tri(self,name,a,b,c,thickness=.045,shade=.68):
        a,b,c=map(lambda x:np.array(x,dtype=float),(a,b,c))
        if np.linalg.norm(np.cross(b-a,c-a))<1e-7:return
        # Longest edge is base: altitude splits triangle into two right wedges.
        if np.linalg.norm(a-b)>max(np.linalg.norm(b-c),np.linalg.norm(c-a)): a,b,c=c,a,b
        elif np.linalg.norm(a-c)>np.linalg.norm(b-c): a,b,c=b,a,c
        direction=(c-b)/np.linalg.norm(c-b)
        foot=b+direction*np.dot(a-b,direction)
        height=np.linalg.norm(a-foot); up=(a-foot)/height
        for endpoint in (b,c):
            length=np.linalg.norm(foot-endpoint)
            if length<1e-6:continue
            back=(foot-endpoint)/length; right=np.cross(up,back)
            R=np.column_stack((right,up,back))
            self.part(name,(a+endpoint)/2,[thickness,height,length],R,'WedgePart',shade=shade)
            # Wedge high edge is +Z; verify generated triangle corners.
            center=(a+endpoint)/2
            expected=[center+R@np.array([0,-height/2,-length/2]),center+R@np.array([0,-height/2,length/2]),center+R@np.array([0,height/2,length/2])]
            assert np.allclose(expected,[endpoint,foot,a])
        self.faces.append([a,b,c]); self.shades.append(shade)
    def box(self,name,pos,size,R=np.eye(3),shade=.65):
        self.part(name,pos,size,R,shade=shade)
        v=np.array([[x,y,z] for x in [-.5,.5] for y in [-.5,.5] for z in [-.5,.5]])*size
        v=v@R.T+pos
        for q in [(0,1,3,2),(4,6,7,5),(0,4,5,1),(2,3,7,6),(0,2,6,4),(1,5,7,3)]:
            self.faces.append(v[list(q)]); self.shades.append(shade)
    def rings(self,name,rings,shade=.68,cap=True):
        for row in range(len(rings)-1):
            for j in range(len(rings[0])):
                k=(j+1)%len(rings[0]); a,b,c,d=rings[row][j],rings[row][k],rings[row+1][k],rings[row+1][j]
                self.tri(name,a,b,c,shade=shade);self.tri(name,a,c,d,shade=shade)
        if cap:
            for ring in (rings[0],rings[-1]):
                mid=np.mean(ring,axis=0)
                for j in range(len(ring)):self.tri(name,mid,ring[j],ring[(j+1)%len(ring)],shade=shade)
    def normalize_floor(self):
        # True bounding vertices including wedge thickness, not enclosing cuboids.
        points=[]
        for pos,size,R,cls in self.parts:
            if cls=='WedgePart':
                v=[[x,y,z] for x in [-.5,.5] for y,z in [(-.5,-.5),(-.5,.5),(.5,.5)]]
            else:v=[[x,y,z] for x in [-.5,.5] for y in [-.5,.5] for z in [-.5,.5]]
            points.extend(np.array(v)*size@R.T+pos)
        points=np.array(points); shift=-points[:,1].min()
        for part in self.geo.findall('Item'):
            y=part.find("Properties/CoordinateFrame/Y");y.text=str(float(y.text)+shift)
        for face in self.faces:
            for vertex in face:vertex[1]+=shift
        points[:,1]+=shift
        self.parts=[(pos+np.array([0,shift,0]),size,R,cls) for pos,size,R,cls in self.parts]
        self.bounds=(points.max(axis=0)-points.min(axis=0)).round(3).tolist()

def ring(y,r,n=10,cx=0,rz=None):
    return [[cx+r*math.cos(j*2*math.pi/n),y,(r if rz is None else rz)*math.sin(j*2*math.pi/n)] for j in range(n)]

assets=[]
f=Asset('01_GoldenFruit','Village','Food')
f.rings('FruitSegment',[ring(y,r,10) for y,r in [(0,.7),(.5,1.7),(1.7,2.35),(3,2.15),(4,1.4),(4.35,.45)]])
f.box('Stem',[0,4.6,0],[.42,1,.42],shade=.45)
for i in range(3):
    t=i*2*math.pi/3+.3; axis=np.array([math.cos(t),0,math.sin(t)]);side=np.array([-math.sin(t),0,math.cos(t)])
    base=np.array([0,4.7,0]);tip=base+axis*2.45+[0,.8,0];mid=base+axis*1.1
    left=mid+side*.65;right=mid-side*.65;ridge=mid+[0,.35,0]
    for a,b,c in [(base,left,ridge),(left,tip,ridge),(tip,right,ridge),(right,base,ridge)]:f.tri('Leaf',a,b,c,.08,.55)
assets.append(f)

g=Asset('02_Emberstone','SmallTown','Warmth')
# Chunk gaps expose a smaller core. Dressing will later light this core.
g.rings('InnerCore',[ring(y,r,8) for y,r in [(.25,.55),(.7,1.5),(2,1.85),(3.1,1.3),(3.65,.45)]],.52)
rs=[ring(y,r,8) for y,r in [(0,.7),(.65,2.1),(2,2.4),(3.1,1.8),(3.8,.45)]]
for row in range(4):
    for j in range(8):
        k=(j+1)%8; q=np.array([rs[row][j],rs[row][k],rs[row+1][k],rs[row+1][j]])
        mid=q.mean(axis=0);q=mid+(q-mid)*.90
        g.tri('RockPlate',q[0],q[1],q[2],.14,.65);g.tri('RockPlate',q[0],q[2],q[3],.14,.65)
assets.append(g)

e=Asset('03_EnergyCell','City','Energy')
for y in [.4,5.6]:e.rings('EndCap',[ring(y-.4,1.9,8),ring(y+.4,1.9,8)],.51)
e.rings('Core',[ring(.8,1.05,8),ring(5.2,1.05,8)],.78)
for j in range(4):
    t=math.pi/4+j*math.pi/2
    R=np.array([[math.cos(t),0,math.sin(t)],[0,1,0],[-math.sin(t),0,math.cos(t)]])
    e.box('ProtectionRail',[1.5*math.cos(t),3,-1.5*math.sin(t)],[.55,4.4,.6],R,.56)
assets.append(e)

s=Asset('04_AncientEggshell','LargeCity','Shelter')
# Axis toward front (-Z). Five rings form an open hollow dome; no interior fill.
n=12; rings=[]
for row in range(5):
    theta=.12+(1.62-.12)*row/4
    r=[]
    for j in range(n):
        phi=2*math.pi*j/n
        tt=theta+((.065 if j%2 else -.055) if row==4 else 0)
        r.append([3.4*math.sin(tt)*math.cos(phi),2.45+2.45*math.sin(tt)*math.sin(phi),5.2*math.cos(tt)-1.25])
    rings.append(r)
for row in range(4):
    for j in range(n):
        k=(j+1)%n;a,b,c,d=rings[row][j],rings[row][k],rings[row+1][k],rings[row+1][j]
        s.tri('ShellPanel',a,b,c,.24,.72);s.tri('ShellPanel',a,c,d,.24,.72)
for j in range(n):s.tri('ShellBack',[0,2.45,3.95],rings[0][j],rings[0][(j+1)%n],.24,.72)
assets.append(s)

t=Asset('05_AncestorFang','MegaCity','Strength')
t.rings('FangBody',[ring(y,r,8,cx,rz) for y,r,cx,rz in [(0,1.25,-.6,1.2),(1.1,1.5,-.7,1.25),(2.6,1.2,-.7,1),(4.2,.92,-.45,.8),(5.6,.65,.05,.6),(6.8,.36,.7,.36),(7.8,.08,1.35,.1),(8,.01,1.5,.01)]],.74)
assets.append(t)

scene=doc(); group,_=item(scene,'Model','Trenchborn_Collectibles_GateB')
report=[]
for i,a in enumerate(assets):
    a.normalize_floor();write(a.doc,OUT/(a.name+'.rbxmx'))
    clone=copy.deepcopy(a.obj)
    # Every scene referent is globally unique; original generation used a shared counter.
    for part in clone.iter('Item'):
        if part.get('class') in ('Part','WedgePart'):
            x=part.find('Properties/CoordinateFrame/X');x.text=str(float(x.text)+(i-2)*11)
    group.append(clone)
    report.append({'model':a.name,'visible_parts':len(a.parts),'bounds_studs':a.bounds})
write(scene,OUT.parent/'preview/Trenchborn_Collectibles_GateB.rbxmx')
(OUT.parent/'docs/geometry_report.json').write_text(json.dumps(report,indent=2))

# Structural validation of the actual serialized deliverables.
for path in OUT.glob('*.rbxmx'):
    root=E.parse(path).getroot(); ids=[o.get('referent') for o in root.iter('Item')]
    assert len(ids)==len(set(ids))
    for ref in root.findall('.//Ref'):assert ref.text in ids
    for o in root.iter('Item'):
        assert o.get('class') not in ['Script','LocalScript','ModuleScript','MeshPart']
        if o.get('class') in ['Part','WedgePart']:
            p=o.find('Properties');assert p.find("bool[@name='Anchored']").text=='true'
            assert p.find("bool[@name='CanCollide']").text=='false'
            size=p.find("Vector3[@name='size']");assert all(float(v.text)>0 for v in size)
            c=p.find('CoordinateFrame');R=np.array([[float(c.find(f'R{i}{j}').text) for j in range(3)] for i in range(3)])
            assert np.allclose(R.T@R,np.eye(3),atol=1e-6)
            assert abs(np.linalg.det(R)-1)<1e-6
print(json.dumps(report,indent=2));print('XML, referents, anchors, dimensions and rotation bases: PASS')

if __name__=='__main__':
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    from mpl_toolkits.mplot3d.art3d import Poly3DCollection
    fig=plt.figure(figsize=(18,5),facecolor='#202733')
    for i,a in enumerate(assets):
        ax=fig.add_subplot(1,5,i+1,projection='3d',facecolor='#202733')
        faces=[np.array(face)[:,[0,2,1]] for face in a.faces]
        colors=[]
        for face,shade in zip(faces,a.shades):
            normal=np.cross(face[1]-face[0],face[2]-face[0]);normal/=max(np.linalg.norm(normal),1e-8)
            light=.68+.25*abs(np.dot(normal,np.array([-.4,-.5,.76])))
            colors.append((shade*light,shade*light,shade*light))
        ax.add_collection3d(Poly3DCollection(faces,facecolors=colors,edgecolors=(.2,.2,.2,.2),linewidths=.15))
        ax.set(xlim=(-4.5,4.5),ylim=(-4.5,4.5),zlim=(0,9));ax.set_box_aspect((1,1,1));ax.view_init(20,-65);ax.set_axis_off()
        ax.set_title(a.name[3:],color='white',fontsize=12,pad=-10)
    fig.suptitle('TRENCHBORN / GATE B — GEOMETRY REVIEW',color='white',fontsize=19,y=.94)
    fig.text(.5,.08,'Same scale • Generated geometry preview • Roblox Studio verification pending',ha='center',color='#c4cbd6',fontsize=12)
    fig.subplots_adjust(left=.015,right=.985,wspace=0,top=.86,bottom=.13)
    fig.savefig(OUT.parent/'docs/Geometry_Preview.png',dpi=150,facecolor=fig.get_facecolor());plt.close(fig)
