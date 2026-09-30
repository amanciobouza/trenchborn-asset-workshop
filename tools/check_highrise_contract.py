from pathlib import Path
r=Path(__file__).resolve().parents[1]
print('local CollectionService=(function()\n'+(r/'tests/highrise_contract_mock.lua').read_text()+'\nend)()')
for name in ['GoldenMaster','Dressing','Installer']:
 print('local '+name+'=(function()\n'+(r/('src/ReplicatedStorage/TrenchbornAssetWorkshop/LargeCityTropicalHighRise'+name+'.lua')).read_text()+'\nend)()')
print((r/'tests/highrise_contract_checks.lua').read_text())
