# MC-04 — Neon Galleria: Studio review

Concept: ../images/04-neon-galleria.png. Task: #18.

Three offset retail levels, broad neon terrace bands, central tall glazed atrium with visible zig-zag stairs and galleries, storefront displays, rooftop machinery, rear service shutters and attached tall advertising pylon. Billboards use large fictional campaign text and geometric diamond logos rather than embedded raster advertisements. All 14 signs use maximum-fit SciFi typography, following accepted MC-01. No external image dependencies.

## Provisional technical breakdown

- Foundation 236 x 122 studs; wing roof centre Y=83, atrium roof Y=92, pylon top about 114 studs. Dimensions and HP pending city-plan balancing.
- 576 visible Parts, budget 750; 14 SurfaceGui signs; one embedded runtime; no external meshes or per-part scripts.
- Hollow atrium with open entrance and real glazing; retail floors and visible stairs are architectural geometry. Neon strips supply colour; in-engine lighting appearance requires Studio review.
- Electric, KaijuHouse, provisional MaxHealth 1,000,000. Whole complex and pylon collapse as one unit. No road or separate plaza included.
- Shared MegaCityAPI supplies damage/reset and energy events in Play; game absorption is a separate integration.

## Rojo

On feat/mega-city-harbor-gate, git pull --ff-only, stop the old Rojo server, then rojo serve mega-city-galleria.project.json. Connect to port 34873. Full model is present in Edit mode without an installer or Command Bar. Default project now previews MC-04; prior dedicated projects remain available.

## Verification and acceptance

XML export, anchored Parts, unique references, valid PrimaryPart, finite positive sizes, orthonormal rotations, attribute round-trip and Lua syntax checked. All 14 labels verified to use SciFi. Three off-engine geometry views reviewed; preview renderer does not reproduce Studio text, transparency or lighting faithfully.

Gate B remains pending user visual acceptance. Gate C remains pending damage/reset and traversal checks in Studio. MC-05 must wait for MC-04 acceptance.
