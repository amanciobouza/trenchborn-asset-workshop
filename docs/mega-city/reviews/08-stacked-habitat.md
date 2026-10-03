# MC-08 — Stacked Habitat: Studio review

Concept: ../images/08-stacked-habitat.png. Task: #22.

Seven offset apartment blocks around a tall structural service core, deep snowy roof terraces, glass railings and heavy cantilever braces. Warm window bands, cyan slab edges and eight maximal-fit SciFi signs. Shops and open residential entrance in the podium. Two large rear thermal mains branch into the blocks; clamps, mounts, heating plant and AC units provide service detail.

## Provisional technical breakdown

- Foundation 160 x 132 studs; main residential blocks roughly 60 x 56 x 39 studs; highest small block roof at 287; overall height approximately 308 studs. Dimensions and HP await city-plan approval.
- 923 visible Parts, budget 1,100; eight SurfaceGui signs; one embedded server runtime. Larger part count reflects glazing, terraces and the separate stacked volumes; in-engine performance remains untested.
- Residential volumes have floor plates and glazing; the structural core is opaque. Apartments are architectural shells, not fully furnished navigable units; no operating elevator.
- Thermal, KaijuHouse, provisional MaxHealth 1,000,000. Whole complex, podium, braces and services collapse as one unit. Shared damage/reset and energy events require game-side absorption integration.

## Direct Rojo preview

On feat/mega-city-harbor-gate: git pull --ff-only; stop the previous server; rojo serve mega-city-stacked.project.json. Connect Studio to port 34873. Workspace.MegaCityStackedHabitat appears complete in Edit mode without an installer. Default project previews MC-08; prior dedicated projects remain available.

## Checks and acceptance

924 anchored Parts including Origin, unique references and PrimaryPart, finite positive dimensions, orthonormal transforms, Thermal metadata round-trip, integer UDim offsets and Lua syntax verified. Eight SciFi signs checked. Three off-engine geometry views inspected; final glass, text, pipe shading and neon require Studio review.

Gate B awaits user visual acceptance. Gate C awaits Studio damage/reset and performance testing. Do not start MC-09 before acceptance.
