# MC-13 — Grid Substation: Studio review

Approved reference: ../images/13-grid-substation.png. Task #27.

Three stepped finned transformers with nine tall ceramic bushings stand in front of two large cylindrical coils. Cyan bands and busbars connect the equipment. Heavy armoured plinth, right-hand control building with glazed upper room, roof vents, six rear switch cabinets, front railings and entry stair. Six maximum-fit SciFi signs. Entire facility collapses as one model.

## Provisional technical breakdown

- Foundation 244 x 157 studs. Front staircase extends to approximately Z=-101; highest gantry about Y=118. Dimensions and MaxHealth 1,000,000 are provisional pending city-plan balancing.
- 423 visible native Parts; budget 1,400. Six SurfaceGui signs and one embedded server runtime. No permanent particle emitters or lights, no external textures or meshes. Electrical hardware is static.
- Electric, KaijuHouse. Shared damage/collapse/reset and energy notifications; absorption integration remains separate.
- Control-room windows have empty volume behind them. Roof vents rest on roof. Individual feed busbars terminate at coil front surfaces; transformer cables terminate at gantries.

## Direct Rojo preview

On feat/mega-city-harbor-gate: git pull --ff-only; stop previous Rojo server; rojo serve mega-city-grid.project.json. Studio port 34873. Workspace.MegaCityGridSubstation appears directly in Edit mode, no installer or Command Bar. Default project shows MC-13 on port 34872. Older dedicated previews remain available.

## Verification and gates

XML parse, unique references, PrimaryPart, 424 anchored Parts including Origin, positive dimensions, orthonormal transforms, integer UDim offsets, metadata round-trip and Lua syntax passed. Three geometry views inspected. Offline renderer does not reproduce Studio glass, text and neon and can occlude small details incorrectly.

Gate B awaits Studio visual acceptance. Gate C awaits gameplay and performance checks. MC-14 has not started.

## Review correction: labels and electrical arcs
- Moved 01/02/03 plates forward of radiator fins, with 1 stud clearance; enlarged to 12 × 7 with fitted SciFi text.
- Added four cyan/white native-Part arcs: three transformer bushing pairs and one between the coil top terminals (64 non-colliding Parts).
- Static arcs visible in Edit mode; fixed terminals and jittering intermediate nodes in Play, following model pivot. Destroyed hides arcs; reset resumes. Reuses a fixed Part pool.
- Updated total: 487 visible Parts plus Origin. Export, Lua syntax, label clearance and arc metadata checks passed; Studio visual/Play review pending.

## User acceptance
2026-10-03: User accepted MC-13 after number visibility correction and added electrical arcs ("passt"). Visual review accepted; dedicated gameplay destruction/reset gate remains pending.
