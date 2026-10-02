"""Exercise final Stage 5 installer lifecycle with mocked Roblox dependencies."""
import runpy
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
base=runpy.run_path(str(ROOT/'tools/test-kaiju-replication.py'))
setup=base['installer_setup'].replace('KaijuStageFourGoldenMaster','KaijuStageFiveGoldenMaster').replace('Stage_4_Geometry_Review','Stage_5_Geometry_Review').replace('"EvolutionStage",4','"EvolutionStage",5').replace('"EvolutionStage")==4','"EvolutionStage")==5')
setup=setup.replace(' builds=builds+1',' if failDressing then error("simulated builder failure") end\n builds=builds+1').replace(' return m\nend})',' m:SetAttribute("Dressed",true)\n return m\nend})')
setup+='\naddModule("KaijuEnergySailPresentation",{})\n'
source=(ROOT/'src/ReplicatedStorage/TrenchbornAssetWorkshop/KaijuStageFiveInstaller.lua').read_text()
base['run'](setup+'\nlocal Installer=(function()\n'+source+'\nend)()\n'+r'''
local c,r,h=character()
local m,api=Installer.Install(c,{Scale=2,CombatFactory=adapter,EnableTraversal=true})
assert(m:GetAttribute('PipelinePhase')==7 and m:GetAttribute('QualityGateC')=='ApprovedByUser')
assert(m:GetAttribute('FinalInstallerVersion')=='1.0.0' and not m:GetAttribute('TestOnly'))
assert(m:FindFirstChild('KaijuSailRenderer').Value and m:GetAttribute('BuildingTraversalEnabled'))
assert(m:GetScale()==2 and api.RequestAttack())
assert(not pcall(Installer.Install,c,{PreviewOnly=true}))
api.Destroy();api.Destroy()
assert(h.WalkSpeed==24 and r.Transparency==0 and not c:FindFirstChild('KaijuBodyCollider'))
assert(not api.RequestAttack() and rigStops==1 and traversalStops==1)
local again=Installer.Install(c,{PreviewOnly=true})
assert(Installer.Uninstall(c) and not Installer.Uninstall(c))
failDressing=true
assert(not pcall(Installer.Install,c,{PreviewOnly=true}))
failDressing=false
assert(not pcall(Installer.Install,c,{CombatFactory=function()return {} end}))
assert(not c:FindFirstChild('Stage_5_Geometry_Review') and h.WalkSpeed==24)
local final=Installer.Install(c,{PreviewOnly=true});final:Destroy()
assert(not c:FindFirstChild('KaijuBodyCollider') and r.Transparency==0)
print('PASS: Stage 5 final installer gates, sail reference, traversal, duplicate equip, uninstall, reinstall and rollback')
''')
base['run']((ROOT/'examples/KaijuStageFive.server.lua').read_text(),False)
