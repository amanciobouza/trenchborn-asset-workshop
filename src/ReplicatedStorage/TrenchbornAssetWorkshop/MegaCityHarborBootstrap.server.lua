-- Template remains inactive in ReplicatedStorage. Installer clones it into the model.
local folder = game:GetService("ReplicatedStorage"):WaitForChild("TrenchbornAssetWorkshop")
local runtime = require(folder:WaitForChild("MegaCityBuildingRuntime"))
local spec = require(folder:WaitForChild("MegaCityHarborGateSpecification"))
runtime.Attach(script.Parent, spec, {
    Effects = script:GetAttribute("Effects"),
    MaxHealth = script:GetAttribute("MaxHealth"),
})
