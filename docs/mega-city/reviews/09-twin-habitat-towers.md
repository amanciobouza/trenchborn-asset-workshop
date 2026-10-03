# MC-09 — Twin Habitat Towers: Studio review

Concept: ../images/09-twin-habitat-towers.png. Task: #23.

Two unequal residential towers on one shared retail podium, without a skybridge. Tall tower has 16 apartment levels, short tower 12. Deep wraparound balcony bands, warm glazing, cyan accents, a double-height furnished winter garden in each tower, rear heat risers and roof service rooms. Ten maximum-fit SciFi signs identify the residence, entrances A/B and shops.

## Provisional technical breakdown

- Foundation 180 x 118 studs. Tower centres X=-43 and +43; floor spacing 14 studs from Y=50. Main tower roofs at Y=275 and 219; tallest beacon approximately 309 studs. Dimensions and HP await city-plan balancing.
- 1,038 visible Parts, budget 1,400; ten SurfaceGui signs; one embedded server runtime. In-engine performance remains untested.
- Winter gardens omit the intermediate floor; glass front and sides surround native-Part plants and benches. Hotel-like floors are architectural shells, not furnished navigable apartment interiors. No working elevators.
- Thermal, KaijuHouse, provisional MaxHealth 1,000,000. Both towers, podium and services collapse together. Shared damage/reset and energy notification API; absorption requires separate game integration.

## Direct Rojo preview

On feat/mega-city-harbor-gate: git pull --ff-only; stop the previous server; rojo serve mega-city-twin.project.json. Connect Studio to port 34873. Workspace.MegaCityTwinHabitatTowers is present in Edit mode without installer or Command Bar. Default project previews MC-09; previous dedicated projects remain available.

## Checks and gates

1,039 anchored Parts including Origin; XML references and PrimaryPart; finite sizes, orthonormal transforms; Thermal metadata, integer UDim offsets and Lua syntax passed. Ten SciFi signs checked. Three geometry views inspected; final text, glass, lighting and pipe appearance require Studio.

Gate B awaits user visual acceptance of silhouettes, balcony bands, winter gardens and heating lines. Gate C awaits in-engine damage/reset and performance tests. MC-10 waits for approval.

## Sign clearance correction

HABITAT/09 signage, carrier and neon frame moved 13 studs forward as one assembly. Carrier rear face at Z=-38.5 clears the deepest conservatory roof edge (Z=-36.5) by 2 studs. Two brackets connect the carrier to the front pier between balcony levels. Studio visual confirmation pending.
