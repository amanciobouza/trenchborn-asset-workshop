# MC-15 Data Center review

Approved image: docs/mega-city/images/15-data-center.png, blob e22ee8ff87194626cbd42164738e01ce1837a4fd. Full reference inspected before building.

## Technical breakdown
- Compact armoured block with two deep fin banks, three narrow cyan server windows, stepped roof cooling boxes, three rear cooling modules with six fan grilles and paired coolant return pipes.
- Native Parts, dark petrol/violet armour, cyan status strips, warm markers, blue Glass and snow dressing.
- Five maximum fitted SciFi signs, side lettering outside the armour and spines.
- Preview footprint approximately 240 × 184 studs including front steps/rear feeds; height 149.5. Provisional 1,000,000 HP, pending city-plan approval.
- Electric energy; KaijuHouse tag. Building, cooling equipment and foundation collapse/reset together through the embedded shared runtime.
- 652 visible Parts plus Origin; budget 1,400. One embedded Script, no per-fan Scripts, external textures or meshes.

## Validation
XML package, matrices, metadata round-trip, integer GUI offsets and Lua syntax passed. Offline front/oblique/rear geometry inspection completed. Offline painter sorting may obscure small fan/server details; Studio materials, transparency and text are not simulated.

Gate B: pending user Studio acceptance. Gate C: damage, energy payout, whole-model collapse and reset require Studio playtest.

Preview: `rojo serve mega-city-data.project.json`, port 34873. Package: `packages/mega-city/15-data-center.rbxmx`.
