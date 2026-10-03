# MC-16 Guardian Robotics Lab review

Approved reference: docs/mega-city/images/16-guardian-robotics-lab.png, blob 9384cef2bdf902bc44584bf45b3679af4a3b0667. Full image inspected before implementation.

## Technical breakdown
- Tall hollow assembly hall with open cyan-framed portal, slanted external buttresses, two glazed control-room wings, rear blast door and service pipes.
- Two static articulated industrial robot arms, empty maintenance cradle and overhead bridge crane with hoist inside. No Guardian character included.
- Metal/concrete armour, blue Glass, cyan/magenta/amber accents, snow, roof cooling units and maximum fitted SciFi text.
- Working footprint about 280 × 216 studs, height 173.55; provisional 1,000,000 HP. City-plan size/placement and HP approval remain pending.
- Electric energy; KaijuHouse tag. Hall, control rooms and integrated machinery form one collapse/reset unit using the embedded shared runtime.
- 354 visible Parts plus Origin, four signs, one embedded Script; budget 1,400. No external meshes/textures.

## Checks and review
Export XML, metadata round-trip, integer GUI offsets, orthonormal matrices and Lua syntax passed. Offline front/oblique/rear geometry inspected against reference. Roof braces lowered inside the roof after inspection. Painter sorting can show interior geometry through large panels in offline renders; Studio text, glass and lighting need user review.

Gate B: pending Studio visual acceptance. Gate C: Studio damage, energy payout, collapse and reset checks pending.

Preview: `rojo serve mega-city-robotics.project.json` on port 34873. Native package: `packages/mega-city/16-guardian-robotics-lab.rbxmx`.
