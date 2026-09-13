"""Build the portable Studio model using only Python's standard library."""
import hashlib
import json
from pathlib import Path
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
FILES=['KaijuStageOneInstaller.lua','KaijuEvolutionBlockout.lua','KaijuStageOneRig.lua',
       'KaijuStageOneCombo.lua','KaijuStageOneJump.lua','KaijuStageOneInput.client.lua','KaijuStageOneJumpMotor.client.lua']
def build():
    xml=ET.Element('roblox',version='4')
    folder=ET.SubElement(xml,'Item',{'class':'Folder','referent':'RBX0'})
    properties=ET.SubElement(folder,'Properties')
    ET.SubElement(properties,'string',name='Name').text='TrenchbornKaijuStageOne'
    manifest={'package':'TrenchbornKaijuStageOne','version':'1.1.2','files':{}}
    for index,filename in enumerate(FILES,1):
        source=(SOURCE/filename).read_text(encoding='utf-8')
        client=filename.endswith('.client.lua')
        name=filename.removesuffix('.client.lua') if client else filename.removesuffix('.lua')
        item=ET.SubElement(folder,'Item',{'class':'LocalScript' if client else 'ModuleScript','referent':f'RBX{index}'})
        props=ET.SubElement(item,'Properties')
        ET.SubElement(props,'string',name='Name').text=name
        ET.SubElement(props,'ProtectedString',name='Source').text=source
        manifest['files'][filename]=hashlib.sha256(source.encode()).hexdigest()
    out=ROOT/'dist';out.mkdir(exist_ok=True)
    data=ET.tostring(xml,encoding='utf-8',xml_declaration=True)
    target=out/'KaijuStageOne.rbxmx';target.write_bytes(data)
    manifest['artifactSha256']=hashlib.sha256(data).hexdigest()
    (out/'KaijuStageOne.manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    # Round-trip all embedded source; do not silently truncate or reinterpret Lua/XML.
    items=ET.fromstring(data).findall('Item/Item')
    assert len(items)==len(FILES)
    for item,filename in zip(items,FILES):
        assert item.find("Properties/ProtectedString[@name='Source']").text==(SOURCE/filename).read_text(encoding='utf-8')
    print(f'Built and verified {target} ({len(data)} bytes)')
if __name__=='__main__': build()
