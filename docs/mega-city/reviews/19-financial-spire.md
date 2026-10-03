# MC-19 Financial Spire review

Approved reference: docs/mega-city/images/19-financial-spire.png, blob 8cb2af63eb05a75a8c085bfb43f2c94a1741e62a. Full reference inspected before building.

## Technical breakdown
- Four staggered hollow blue-glass volumes with floors, mullions and warm internal lighting strips. Off-centre service blade, magenta emblem, asymmetric crown and cyan-tipped antenna.
- Three cyan-framed static fictional market bands wrap all four facades. Fifteen fitted maximum SciFi labels including building name and two numbers.
- Glazed lobby, snowy podium, entrance steps, planters, roof ventilation and rear service entrance. No Guardian character.
- Working footprint about 160 × 154 studs including steps; height 451. Provisional 1,000,000 HP, Electric energy. Final city-plan dimensions and HP remain pending approval.
- 1,128 visible Parts plus Origin, one shared embedded runtime, budget 1,400 Parts. Tower, antenna and entrance collapse/reset together; KaijuHouse tag and health/energy attributes included.

## Validation
Export XML, unique referents, positive geometry sizes, orthonormal matrices, anchored Parts, integer GUI offsets, gameplay attribute round-trip and Lua syntax passed (45 sources including embedded runtime). Front/oblique/rear offline geometry views inspected. Narrow shaft lighting dimensions corrected after validation; solid face added behind upper emblem/number.

Offline rendering does not reproduce Studio glass, lights, Neon or text. Gate B visually accepted by Amancio on 2026-10-03. Gate C damage, energy release, collapse and reset require Studio Play testing.

Preview: `rojo serve mega-city-financial.project.json`, port 34873. Native import: `packages/mega-city/19-financial-spire.rbxmx`. Default project also points to MC-19, port 34872.
