-- Stage 1 is the active workshop. Do not start retired Guardian harnesses,
-- menus, key bindings, remotes or preview models.
local workshop = workspace:WaitForChild("TrenchbornAssetWorkshop")
workshop:SetAttribute("Pipeline", "Trenchborn-7-Phase")
workshop:SetAttribute("CurrentAsset", "Kaiju Stage 1 - Primal Beast")
workshop:SetAttribute("CurrentPhase", 6)
workshop:SetAttribute("QualityStatus", "Phase6_Stage1PlayerControlReview")
