from pathlib import Path
r=Path(__file__).resolve().parents[1]
print('local CS=(function()\n'+(r/'tests/highrise_dressing_mock.lua').read_text()+'\nend)()')
for name in ['GoldenMaster','Dressing']:
 print('local '+name+'=(function()\n'+(r/('src/ReplicatedStorage/TrenchbornAssetWorkshop/LargeCityTropicalHighRise'+name+'.lua')).read_text()+'\nend)()')
print((r/'tests/highrise_dressing_checks.lua').read_text())
