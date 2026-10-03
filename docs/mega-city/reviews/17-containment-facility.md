# MC-17 Containment Facility review

Approved reference: docs/mega-city/images/17-containment-facility.png, blob 58882b8e981cd7973e0a901f9f17555e61469be3. Full concept inspected before building.

## Technical breakdown
- Central hollow reinforced vessel with 24 transparent green glass panes, eight mullions and three structural hoops. Bright static core, twin green energy helices and four luminous inner rings.
- Four massive inward-leaning pylons with upper/lower clamps, capped vessel, low glazed control wings and entrance, rear cooling modules and paired pipes.
- Native Parts, Metal/Concrete/Glass/Neon, snow and fitted maximum SciFi labels. No Guardian or creature included.
- Working footprint about 264 × 221 studs, height 189.5; provisional 1,000,000 HP. City-plan dimensions and HP remain pending approval.
- Radiation energy, KaijuHouse tag; vessel, pylons, rooms and cooling equipment form one collapse/reset unit through the embedded shared runtime.
- 688 visible Parts plus Origin, three signs, one embedded runtime. Budget 1,400 Parts.

## Validation
XML, orthonormal geometry matrices, metadata round-trip, integer GUI offsets and Lua syntax passed. Offline front/oblique/rear geometry inspection completed. Vessel panes were hidden only in the inspection renderer to examine the inner core; the exported asset retains all glass. Studio transparency, lighting and signs require visual acceptance.

Gate B: pending Studio visual acceptance. Gate C: damage, energy payout, collapse and reset require Studio playtest.

Preview: `rojo serve mega-city-containment.project.json`, port 34873. Native import: `packages/mega-city/17-containment-facility.rbxmx`.
