# MC-10 — Utility Block: Studio review

Approved concept: ../images/10-utility-block.png. Task #24.

Compact workshop and thermal service complex. Two large six-blade front fans with polygonal rims and guards, two insulated side storage tanks, heavy curved supply main, rear distribution manifold, orange heat exchangers and maintenance walkways. Two open workshop bays include benches, tool boards and crates. Glazed upper control room has consoles and no opaque backing. Six maximum-fit SciFi signs. All components belong to one destruction model.

## Provisional technical breakdown

- Foundation 190 x 130 studs; roof fan bank reaches approximately 115 studs. Dimensions, footprint and MaxHealth 1,000,000 remain provisional pending city-plan balancing.
- 557 visible native Parts; budget 1,400. Six SurfaceGui signs, one embedded server runtime, no external meshes, textures or particle emitters. Fans are static architectural elements.
- Thermal, KaijuHouse; shared damage, collapse, reset and energy notification runtime. Game absorption integration and Studio gameplay/performance testing remain pending.
- Geometry review covers front, front-side and rear. The offline painter renderer can occlude near-coplanar fan elements in oblique views; orthogonal front view verifies both fans. Studio remains authoritative for glass, text and lighting.

## Direct Rojo preview

On feat/mega-city-harbor-gate: git pull --ff-only; stop previous Rojo server; rojo serve mega-city-utility.project.json. Connect Studio on port 34873. Workspace.MegaCityUtilityBlock appears directly in Edit mode, with no installer or Command Bar. Default project also previews MC-10 on port 34872. Previous dedicated previews remain available.

## Validation and gates

XML parse, unique references, PrimaryPart, 558 anchored Parts including Origin, positive dimensions, orthonormal transforms, integer UDim offsets, six signs, metadata round-trip and Lua syntax passed off-engine. Roof vents rest on the roof and tank walkways have braces. Gate B visually accepted by user on 2026-10-03 after the wall flicker correction. Gate C awaits gameplay testing. MC-11 authorized as the next building.

## Wall flicker correction

Rebuilt rear/side wall corners and floor junctions as butt joints, removing coincident concrete/metal faces. Separated window-sill/header faces and brought UTILITY 10 forward of the sill. Heat-exchanger frame and ladder joints also no longer overlap with coplanar faces. Export validation passed; Studio visual confirmation received on 2026-10-03.
