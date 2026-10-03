# MC-05 — Prism Hotel: Studio review

Concept: ../images/05-prism-hotel.png. Task: #19.

Octagonal glass tower with twelve window levels and bevelled corners, narrow cyan edge lighting, tall magenta PRISM/HOTEL sign spine, projecting glazed sky lounge and four asymmetric crown fins around a cyan-magenta prism. Wide podium with glazed furnished lobby, open entrance, pitched canopy and snow-covered side terraces. Five maximized SciFi signs. The crown is built from native Parts, glass planes and neon edges; no external meshes or textures.

## Provisional technical breakdown

- Podium foundation 136 x 114 studs; tower 64 x 64 studs; sky lounge 82 x 68 studs; overall height approximately 320 studs. These are provisional review dimensions pending city-plan approval.
- 508 visible Parts, budget 850; five SurfaceGui signs; one embedded server runtime. No per-part scripts.
- Lobby and lounge have no solid glazing backing blocks. Hotel floors are architectural shells with small interior service cores, not fully furnished rooms. No working elevator or interior navigation system.
- Electric, KaijuHouse; provisional MaxHealth 1,000,000. Tower, crown and podium collapse together; public street/plaza not included.
- Shared MegaCityAPI damage/reset and energy notifications; game-side absorption integration remains separate.

## Direct Rojo review

On feat/mega-city-harbor-gate: git pull --ff-only; stop the previous server; rojo serve mega-city-prism.project.json. Connect Studio to port 34873. Workspace.MegaCityPrismHotel appears fully built in Edit mode without an installer or Command Bar. Default project previews MC-05; previous dedicated projects remain available.

## Verification and gates

XML export, 509 anchored Parts including Origin, unique references and PrimaryPart, finite positive sizes, orthonormal rotations, metadata round-trip and Lua syntax checked. All five signs use SciFi. Three off-engine geometry views inspected; text/glass/lighting appearance requires Studio.

Gate B awaits user visual approval of crown, silhouette, glazing and signage. Gate C awaits Studio damage/reset testing. Do not start MC-06 until MC-05 is accepted.
