# MC-02 — Cargo Logistics Hub: Studio review

Concept: ../images/02-cargo-logistics-hub.png. Task: #16.

Built from the approved target: three open loading bays, stepped roofs, raised glazed control room, attached side gantry with suspended spreader, magenta vertical LOGISTICS sign, amber bay displays, cyan routing, roof ducts and snow. Quay and external forecourt are excluded.

## Technical breakdown

- Parts-only, no meshes or external dependencies. 427 visible parts, budget 650; 9 SurfaceGui signs; one embedded server runtime.
- Provisional foundation 244 x 108 studs; top approximately 112 studs. Origin at ground level; loading face toward -Z. Dimensions await city-plan approval.
- Electric; KaijuHouse tag. Provisional MaxHealth 1,000,000, pending city-plan balancing.
- Hall, tower, crane and attached loading deck form one model and collapse together.
- Embedded runtime exposes MegaCityAPI.ApplyDamage, Reset and EnergyReleased during Play. Reward notifications require integration by the game; no automatic absorption is claimed.

## Direct Rojo preview

On feat/mega-city-harbor-gate, run `git pull --ff-only`, stop the old server and run `rojo serve mega-city-cargo.project.json`. Connect Studio to port 34873. The complete model is visible in Edit mode; no installer or Command Bar required. The default project now also previews MC-02. The explicit harbor project remains available for MC-01.

## Verification and acceptance

- Export parsed: 428 anchored Parts including Origin; valid unique references and PrimaryPart.
- Dimensions finite and positive; orientation matrices orthonormal; attributes round-trip verified.
- Embedded runtime and source Lua syntax checked off-engine.
- Three geometry views inspected; these previews do not render Roblox text, glass or lighting faithfully.
- Gate B remains pending user visual acceptance in Studio. Gate C remains pending Studio damage/reset playtest.
- MC-03 is not started until the user accepts MC-02.
