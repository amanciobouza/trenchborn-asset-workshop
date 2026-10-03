# MC-06 — Holo Entertainment Tower: Studio review

Concept: ../images/06-holo-entertainment-tower.png. Task: #20.

Broad tower with three projecting ring galleries. Lower and upper rings dominate; the smaller middle ring is offset rearward to leave the curved display clear. Glazed galleries, cyan roof edges, magenta underside strips, cantilever braces, snowy roofs, rooftop penthouse and antennas. Podium contains an open event entrance and decorative arcade cabinets.

## Curved screen

Seven tangent display panels form a 120-degree arc. Each SurfaceGui contains its clipped slice of one 1400 x 800 planet/orbit graphic built from native GUI Frames. No uploaded image IDs or external assets. Artwork is static and already visible in Edit mode; there is no video playback or animated hologram. Arcade machines are decorative, not playable minigames.

## Provisional technical breakdown

- Podium 164 x 136 studs; ring radii 78, 55 and 74 studs; ring deck heights 64, 122 and 190; overall height about 263 studs. Dimensions and HP remain provisional pending city-plan approval.
- 453 visible Parts, budget 850; five maximal-size SciFi text signs and seven graphic SurfaceGuis; one embedded runtime. Screen primitives are culled to the panel bounds during export.
- Electric; KaijuHouse; provisional MaxHealth 1,000,000. Rings, display and podium collapse as one model. Game-side energy absorption remains separate from the shared damage/reset event API.

## Direct Rojo preview

On feat/mega-city-harbor-gate: git pull --ff-only; stop the old server; rojo serve mega-city-holo.project.json. Connect Studio to port 34873. Workspace.MegaCityHoloEntertainmentTower appears in Edit mode without an installer or Command Bar. Default project previews MC-06; prior dedicated projects remain available.

## Checks and acceptance

Export parsed; 454 anchored Parts including Origin; unique references and valid PrimaryPart; finite dimensions and orthonormal transforms; attribute round-trip and Lua syntax passed. Five SciFi signs checked. Three geometry views inspected. Seven exported GUI slices rendered together to inspect the planet graphic and panel seams.

Gate B remains pending user visual acceptance in Studio, particularly ring overhangs, curved-screen orientation, graphic continuity and glazing. Gate C remains pending damage/reset and performance checks in Studio. MC-07 waits for acceptance.
