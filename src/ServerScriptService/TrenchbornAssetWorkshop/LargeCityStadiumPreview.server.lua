-- Compatibility shim for branch switching in Studio/Rojo.
-- A previous Large City preview can remain live in Studio after the source file
-- disappears on another branch. Keeping this path on the Kaiju branch forces
-- Rojo to replace that stale preview with a no-op script.
local workshop = workspace:FindFirstChild("TrenchbornAssetWorkshop")
if workshop then
	workshop:SetAttribute("LargeCityPreviewDisabledForKaiju", true)
end
