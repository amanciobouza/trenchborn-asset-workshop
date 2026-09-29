"""Standalone source package for Studio: import, then explicitly run Installer.Install."""
from pathlib import Path
import xml.etree.ElementTree as E
r=Path(__file__).resolve().parents[1]
root=E.Element('roblox',{'version':'4'})
folder=E.SubElement(root,'Item',{'class':'Folder','referent':'RBXPackage'})
props=E.SubElement(folder,'Properties');E.SubElement(props,'string',{'name':'Name'}).text='LargeCityTropicalSignalTowerPackage'
names=['LargeCityTropicalSignalTowerSpecification','LargeCityTropicalSignalTowerGoldenMaster','LargeCityTropicalSignalTowerDressing','LargeCityTropicalSignalTowerInstaller']
for i,name in enumerate(names):
 item=E.SubElement(folder,'Item',{'class':'ModuleScript','referent':f'RBXModule{i}'})
 pr=E.SubElement(item,'Properties');E.SubElement(pr,'string',{'name':'Name'}).text=name
 E.SubElement(pr,'ProtectedString',{'name':'Source'}).text=(r/'src/ReplicatedStorage/TrenchbornAssetWorkshop'/f'{name}.lua').read_text()
out=r/'dist/LargeCityTropicalSignalTowerPackage.rbxmx'
E.ElementTree(root).write(out,encoding='utf-8',xml_declaration=True)
tree=E.parse(out)
assert len(tree.findall('.//Item[@class="ModuleScript"]'))==4
assert not tree.findall('.//Item[@class="Script"]')
for module,name in zip(tree.findall('.//Item[@class="ModuleScript"]'),names):
 assert module.find("Properties/ProtectedString[@name='Source']").text==(r/'src/ReplicatedStorage/TrenchbornAssetWorkshop'/f'{name}.lua').read_text()
print('PASS: four complete modules, no auto-running scripts; '+str(out))
