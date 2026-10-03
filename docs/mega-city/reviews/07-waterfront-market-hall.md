# MC-07 — Waterfront Market Hall: Studio review

Concept: ../images/07-waterfront-market-hall.png. Task: #21.

Low, broad food hall with six open front service bays (NOODLES, RÖSTI, FISH, RAMEN, RACLETTE, CERVELAT), staggered snowy canopies, striped awnings, warm lamps, counters and goods. Open central entrance with MARKET HALL header and two vertical signs. Interior market tables flank a clear centre route. Raised glazed roof lantern, three large kitchen exhaust housings with orange louvers, flat-roof vents and rear refrigeration/service equipment. Promenade, sea and city furniture are excluded.

## Technical breakdown (provisional)

- Foundation 236 x 132 studs; roof height 43, raised lantern roof 55, exhaust tops about 71 studs. Dimensions and HP await city-plan balancing.
- 496 visible Parts, budget 750; twelve maximum-fit SciFi signs; one embedded server runtime. No external images/meshes or per-part scripts. Exhaust housings are static; no smoke animation is included in this version.
- EnergyType Thermal, KaijuHouse, provisional MaxHealth 1,000,000. Hall, shops, counters and rooftop equipment form one destruction unit.
- Shared MegaCityAPI provides damage/reset and energy notification events in Play; absorption requires game integration.

## Direct Rojo preview

On feat/mega-city-harbor-gate: git pull --ff-only; stop the previous server; rojo serve mega-city-market.project.json. Connect Studio to port 34873. Workspace.MegaCityWaterfrontMarketHall appears in Edit mode without an installer or Command Bar. Default project previews MC-07; previous dedicated projects remain available.

## Verification and acceptance

Export checked: 497 anchored Parts including Origin, unique references and PrimaryPart, finite positive sizes, orthonormal transforms, Thermal metadata round-trip, Lua syntax and integer UDim offsets. Twelve SciFi fonts verified. Three off-engine geometry views inspected; final glass, neon and text appearance requires Studio review.

Gate B awaits user visual acceptance, especially shop fronts, entry, roof levels and exhaust placement. Gate C awaits Studio damage/reset and traversal testing. MC-08 must wait for acceptance.
