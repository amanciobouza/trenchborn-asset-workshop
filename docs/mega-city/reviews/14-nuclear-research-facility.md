# MC-14 Nuclear Research Facility review

Approved reference: docs/mega-city/images/14-nuclear-research-facility.png (Git blob 4c81dd7e294979175704177a000c0678d48a65f8), inspected in full.

## Technical breakdown and preview
- Armoured tapered containment, 16 green viewing slots, segmented dome, radiation trefoil, two hollow laboratory wings with blue observation windows, rear twin coolant feeds and exchangers.
- Native Parts with Metal, Concrete, Glass and Neon; snow dressing, roof vents, perimeter markers and maximum fitted SciFi signage.
- Preview footprint approximately 274 × 198 studs, height 146; provisional 1,000,000 HP. These are working dimensions, not final city-plan approval.
- Radiation energy, KaijuHouse tag; containment, wings and equipment are one destruction unit using shared damage/collapse/reset runtime.
- 505 visible Parts plus Origin, 3 signs, one embedded runtime; budget 1,400 visible Parts. No external meshes or textures.

## Validation
Export XML, orthonormal geometry matrices, metadata round-trip, integer GUI offsets and Lua syntax passed. Offline front/oblique/rear inspection completed against concept silhouette; it does not simulate Roblox materials, text or gameplay.

Gate B: pending user Studio review. Gate C: Studio damage, payout, collapse and reset verification pending.

Preview: `rojo serve mega-city-nuclear.project.json`, port 34873. Importable package: `packages/mega-city/14-nuclear-research-facility.rbxmx`.

## Sign clearance correction
Moved NUCLEAR RESEARCH plate from Z -82 to -88. Its rear surface now clears the entrance pillars (front Z -86) by 1.5 studs. Maximum fitted SciFi text retained.

## Dome alignment correction
32 evenly snow-dressed sectors per dome band align with the 16 beacon axes: every beacon sits on a seam between two equally bright panels. Removed the asymmetric every-third-panel snow omission. Dome profile retained.

## Approved 24-stripe pattern
Changed to 24 radial sectors with two white and one dark stripe repeated eight times. Omitted snow in sector i modulo 3 = 1 throughout all four dome bands. Front sectors 11 and 12 both remain white. Dome profile and 16 lamps retained. This supersedes the uniform 32-sector correction.
