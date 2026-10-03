# MC-18 Corporate Headquarters review

Approved reference: docs/mega-city/images/18-corporate-headquarters.png, blob febb73d203d0994c41a6720506d4e9ce403b072d. Full reference inspected before implementation.

## Technical breakdown
- Broad paired hollow office wings with blue glass, mullions, floors and warm internal strips; central service spine, deep front recess, projecting V armour and magenta emblem.
- Sloping crown outlines, cyan facade accents, roof vents and aerials; stepped snowy terraces, continuous tower plinths, monumental glazed lobby, canopy and entrance steps. Rear service portal and louvres.
- Native Parts only. Three maximum fitted SciFi labels. No Guardian characters.
- Working footprint approximately 232 × 180 studs including steps; height 337. Provisional 1,000,000 HP, Electric energy. Dimensions and HP remain subject to city-plan approval.
- 1,040 visible Parts plus invisible Origin, one embedded shared runtime. Budget 1,400 Parts. Tower, emblem and podium form one collapse/reset unit, tagged KaijuHouse.

## Validation
XML, unique referents, anchored Parts, positive sizes, orthonormal matrices, integer GUI offsets, gameplay attribute round-trip and Lua syntax passed (43 sources including embedded runtime). Offline front, oblique and rear geometry views inspected. Added continuous plinths after first inspection; corrected upper window/roof intersection and separated the entrance text plates.

Offline renderer does not reproduce Studio transparency, Neon, text or lighting. Gate B remains pending user visual acceptance; Gate C damage, energy payout, collapse and reset require Studio Play testing.

Preview: `rojo serve mega-city-headquarters.project.json` on port 34873. Native import: `packages/mega-city/18-corporate-headquarters.rbxmx`. Default project also points at MC-18, on port 34872.
