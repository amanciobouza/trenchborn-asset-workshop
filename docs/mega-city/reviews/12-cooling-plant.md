# MC-12 — Cooling Plant: Studio review

Task #26; reference ../images/12-cooling-plant.png. The archived PNG is truncated: its upper portion shows the approved tower silhouette; the lower views are unavailable. Implementation uses that visible portion and the approved textual brief. No replacement concept was invented or substituted.

Two wide tapered hollow cooling towers on a common pump hall. Orange front heat exchangers, four thick elbowed cooling mains, rear pump controls, maintenance platforms, roof ventilation, green radiation rim bands and snow. Four maximum-fit SciFi signs. Entire complex is one destruction unit.

## Provisional technical breakdown

- Foundation 246 x 150 studs. Tower shell heights 85 and 100 studs above Y=53; upper rims approximately 138 and 153 studs. Footprint, height and MaxHealth 1,000,000 are provisional pending city-plan balancing.
- 1069 native Parts including two invisible steam markers, plus Origin. Budget 1,400. Four SurfaceGui signs and one embedded runtime. Two runtime ParticleEmitters, no permanent lights or external mesh assets.
- Each actual open mouth has one SteamOutlet Attachment. Shared runtime emits white smoke continuously in Play at rate 18 per second per tower, upward speed 12–18, lifetime 5–8 seconds, growing sizes 28/46/66 studs and wind acceleration (2,4,1). Uses Roblox built-in smoke texture. Steam disables on destruction, clears after collapse and resumes on reset.
- Thermal, KaijuHouse, shared damage/collapse/reset and energy notifications. Game absorption integration remains separate.

## Direct preview

On feat/mega-city-harbor-gate: git pull --ff-only; stop previous Rojo server; rojo serve mega-city-cooling.project.json. Connect Studio port 34873. Workspace.MegaCityCoolingPlant appears in Edit mode. Press Play to see both steam plumes. No installer or Command Bar. Default project also previews MC-12 on port 34872.

## Verification and gates

XML parse, unique referents, PrimaryPart, positive dimensions, orthonormal shell transforms, integer UDim offsets, metadata round-trip and Lua syntax passed. Two exported SteamOutlet Attachments verified. Geometry inspected from front, side and rear; offline rendering does not reproduce steam, transparency, neon or text. Gate B awaits Studio visual acceptance, especially both continuous white wind-shifted plumes. Gate C awaits in-engine damage/reset and performance checks. MC-13 has not started.

## Radioactive visual treatment

User requested a more radioactive appearance. Added vivid green outer/inner tower rings, glowing coolant couplings and inspection strips, green access indicators and a native-Part trefoil plaque. White steam retained. Gameplay EnergyType remains Thermal as specified; this change is visual. Studio visual acceptance pending.
