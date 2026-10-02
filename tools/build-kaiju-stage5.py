"""Build the Stage 5 final package and verify its embedded sources."""
import hashlib
import json
import re
from pathlib import Path
import xml.etree.ElementTree as ET
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop'
FILES=['KaijuStageFiveGoldenMaster.lua','KaijuStageFiveGeometry.lua','KaijuEnergySailPresentation.lua','KaijuStageOneCombat.lua','KaijuStageFourGoldenMaster.lua','KaijuStageFourDressing.lua','KaijuBuildingTraversal.lua','KaijuPresentation.lua','KaijuPresentationClient.client.lua','KaijuPresentationBootstrap.lua','KaijuSkeleton.lua','KaijuStageFiveInstaller.lua','KaijuStageThreeGoldenMaster.lua','KaijuStageTwoGoldenMaster.lua','KaijuEvolutionBlockout.lua',
       'KaijuStageOneRig.lua','KaijuStageOneCombo.lua','KaijuStageOneJump.lua',
       'KaijuStageFiveInput.client.lua','KaijuStageOneJumpMotor.client.lua']
def build():
    xml=ET.Element('roblox',version='4')
    folder=ET.SubElement(xml,'Item',{'class':'Folder','referent':'RBX0'})
    props=ET.SubElement(folder,'Properties')
    ET.SubElement(props,'string',name='Name').text='TrenchbornKaijuStageFive'
    installer=(SOURCE/'KaijuStageFiveInstaller.lua').read_text(encoding='utf-8')
    version=re.search(r'Version="([^"]+)"',installer).group(1)
    revision=re.search(r'ApprovedRevision="([^"]+)"',installer).group(1)
    manifest={'package':'TrenchbornKaijuStageFive','version':version,
              'approvedGeometryRevision':revision,'phase':7,'testOnly':False,'qualityGateC':'ApprovedByUser','files':{}}
    names={f.removesuffix('.client.lua') if f.endswith('.client.lua') else f.removesuffix('.lua') for f in FILES}
    for index,filename in enumerate(FILES,1):
        source=(SOURCE/filename).read_text(encoding='utf-8')
        client=filename.endswith('.client.lua')
        name=filename.removesuffix('.client.lua') if client else filename.removesuffix('.lua')
        for dependency in re.findall(r'script.Parent:WaitForChild\("([^"]+)"\)',source):
            assert dependency in names, f'Missing package dependency: {dependency}'
        item=ET.SubElement(folder,'Item',{'class':'LocalScript' if client else 'ModuleScript','referent':f'RBX{index}'})
        props=ET.SubElement(item,'Properties')
        ET.SubElement(props,'string',name='Name').text=name
        ET.SubElement(props,'ProtectedString',name='Source').text=source
        manifest['files'][filename]=hashlib.sha256(source.encode()).hexdigest()
    out=ROOT/'dist';out.mkdir(exist_ok=True)
    data=ET.tostring(xml,encoding='utf-8',xml_declaration=True)
    target=out/'KaijuStageFive.rbxmx';target.write_bytes(data)
    manifest['artifactSha256']=hashlib.sha256(data).hexdigest()
    (out/'KaijuStageFive.manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    items=ET.fromstring(data).findall('Item/Item')
    assert len(items)==len(FILES)
    for item,filename in zip(items,FILES):
        assert item.find("Properties/ProtectedString[@name='Source']").text==(SOURCE/filename).read_text(encoding='utf-8')
    print(f'Built and verified {target} ({len(data)} bytes, {len(items)} scripts)')
if __name__=='__main__': build()
