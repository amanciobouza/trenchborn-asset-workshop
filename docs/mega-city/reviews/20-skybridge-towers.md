# MC-20 Skybridge Towers review

Approved reference: docs/mega-city/images/20-skybridge-towers.png, blob 1860da77ab41e0349d7c735a0f7534bb2f55d6da. Full reference inspected before building.

## Technical breakdown
- Two slender hollow blue-glass office towers with floors, warm interior strips, projecting armour, cyan vertical lines and magenta antenna beacons.
- Glazed upper bridge at approximately two-thirds tower height, with massive floor/roof, exposed diagonal truss and cyan accents. Three warm ring chandeliers, tables and benches inside.
- Common glazed podium, large entrance with maximum fitted SciFi SKYBRIDGE / 20 labels, snow terraces and four rear service bays. No Guardian characters or combat roads included.
- Working footprint about 264 × 155 studs; height 377.5. Provisional 1,000,000 HP, Electric energy. City-plan dimensions and HP await approval.
- 1,110 visible Parts plus Origin, three signs, one embedded runtime; budget 1,400 Parts. Both towers, bridge and podium form one collapse/reset unit, with KaijuHouse and health/energy metadata.

## Validation
XML export, unique referents, positive dimensions, orthonormal matrices, anchored Parts, integer GUI offsets, attribute round-trip and Lua syntax passed (47 sources including embedded runtime). Front, oblique and rear geometry views inspected offline.

Renderer does not reproduce Studio glass, Neon, lighting or labels. Painter sorting can show interior lights over larger roof polygons; actual chandeliers are at y=256 below the roof underside at y=260. Gate B awaits visual acceptance. Gate C damage, energy payout, collapse and reset require Studio Play testing.

Preview: `rojo serve mega-city-skybridge.project.json`, port 34873. Native import: `packages/mega-city/20-skybridge-towers.rbxmx`. Default project also points to MC-20 on port 34872.
