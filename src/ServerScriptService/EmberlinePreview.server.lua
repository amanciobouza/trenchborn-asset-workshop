local syncHelp = "Play stoppen; Rojo-Server im Terminal mit Ctrl+C beenden; git pull --ff-only; rojo serve default.project.json; Studio-Rojo auf Port 34872 neu verbinden, synchronisieren und Play starten."
local modules = game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop", 10)
if not modules then
 warn("[Emberline] Workshop-Ordner fehlt. " .. syncHelp)
 return
end
local function loadModule(name)
 local source = modules:WaitForChild(name, 10)
 if not source then
  warn("[Emberline] Modul " .. name .. " fehlt in ReplicatedStorage.TrenchbornAssetWorkshop. " .. syncHelp)
  return nil
 end
 if not source:IsA("ModuleScript") then
  warn("[Emberline] " .. name .. " muss ein ModuleScript sein. " .. syncHelp)
  return nil
 end
 return require(source)
end
local Builder = loadModule("LargeCityEmberlineGoldenMaster")
if not Builder then return end
local model = workspace:FindFirstChild("LargeCity_EmberlineResponseHQ_L3")
 or workspace:FindFirstChild("LargeCity_EmberlineResponseHQ_P5")
 or workspace:FindFirstChild("LargeCity_EmberlineResponseHQ_P4")
if not model then
 model = Builder.Build(workspace, {GroundCFrame = CFrame.new(0, 0, 0)})
end
local Dressing = loadModule("LargeCityEmberlineDressing")
if not Dressing then
 warn("[Emberline] P5 wurde nicht angewendet. Der vorhandene Modellstand bleibt sichtbar.")
 return
end
if not model:GetAttribute("EmberlineIntegrationVersion") then Dressing.Apply(model) end
local Installer = loadModule("LargeCityEmberlineInstaller")
if not Installer then
 warn("[Emberline] P6-Integration fehlt; sichtbarer Modellstand bleibt erhalten.")
 return
end
Installer.Attach(model)
Installer.TestGroupCleanup(model)
print("Emberline P6 ready: 32000 HP, Thermal, KaijuHouse, one whole-building destruction group. External gameplay test / Gate C pending.")
