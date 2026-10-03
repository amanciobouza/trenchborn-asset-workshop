# MC-21 Mega Tower review

Approved reference: docs/mega-city/images/21-mega-tower.png, blob 6821eff595f4b23fb27b3f832e9c2cf7e4604d1b. Full reference inspected before modelling.

## Technical breakdown
- Four progressively narrower octagonal glass tower tiers with projecting collars, vertical cyan energy channels, warm office strips and magenta clamp accents.
- Luminous cyan cylindrical crown, four hoops, eight tall armoured fins and antenna. Stepped monumental podium, four diagonal structural wings and closed base service core.
- Tall warm glazed front lobby with maximum fitted SciFi MEGA TOWER / 21 labels; rear louvres and three delivery doors, snow caps and planters. No Guardian character or plaza included. Intended city placement remains the main-axis terminus behind the Guardian plaza.
- Working footprint approximately 290 × 250 studs, height 626; highest built Mega City landmark so far. Provisional 1,000,000 HP and Electric energy, final city-plan dimensions/HP pending approval.
- 1,309 visible Parts plus Origin; budget 1,400. Three signs and one embedded shared runtime. Entire tower, crown and base are one collapse/reset unit with KaijuHouse and health/energy metadata.

## Validation
Export XML, positive dimensions, unique referents, anchored Parts, orthonormal geometry matrices, integer GUI offsets, attribute round-trip and Lua syntax passed (49 sources including embedded runtime). Front/oblique/rear offline geometry views inspected. Closed base core added after inspection to complete rear enclosure.

Offline renderer does not reproduce Studio glass, Neon, lighting or labels. Gate B awaits user visual acceptance. Gate C damage, energy release, collapse and reset require Studio Play testing.

Preview: `rojo serve mega-city-mega-tower.project.json`, port 34873. Native import: `packages/mega-city/21-mega-tower.rbxmx`. Default project also points to MC-21 on port 34872.
