local Workspace = game:GetService("Workspace")

local workshop = Workspace:WaitForChild("TrenchbornAssetWorkshop")

-- Compatibility shim for Studio sessions that previously had the Stadium preview
-- synced at this path. Keeping the path on the Uptown Arena branch forces Rojo to
-- replace any stale Stadium preview script instead of leaving the old script alive.
local oldStadium = workshop:FindFirstChild("LargeCity_Stadium_L3_GoldenMaster")
if oldStadium then
	oldStadium:Destroy()
end

script:SetAttribute("CompatibilityShim", true)
script:SetAttribute("CurrentReviewAsset", "LargeCity_UptownArena_L3")

print("[Trenchborn Asset Workshop] Stadium preview compatibility shim active; Uptown Arena preview owns this branch.")
