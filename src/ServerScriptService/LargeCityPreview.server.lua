local folder=game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop",10)
local module=folder and folder:WaitForChild("LargeCityAssembly",10)
if not module then warn("Large City modules missing. Wait for Rojo sync and restart Play.");return end
print("[LargeCity] Building 21 masters and placing 54 buildings...")
local ok,result=pcall(function() return require(module).Build(workspace,{GroundY=12,YieldBetweenPlots=true}) end)
if not ok then warn(result);return end
print("[LargeCity] Ready: 54 buildings, 21 masters, 33 copies, 1 green reserve. City NORTH / Mega City SOUTH. Gameplay tests pending.")
