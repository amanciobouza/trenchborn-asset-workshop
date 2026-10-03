# MC-11 — Major Power Station: Studio review

Approved reference: ../images/11-major-power-station.png. Task #25.

Two heavy turbine halls flank a cyan energy tower with four armoured pylons, ring cage, animated lightning paths, cross braces and a crown. Four visible horizontal turbine generators occupy the open front bays; six finned transformers with insulator bushings occupy the rear. Three sagging cable connections run to each hall. Snow caps, warm bay lighting and eight maximum-fit SciFi signs complete the native-Part model. Tower, halls and transformers collapse together.

## Provisional technical breakdown

- Foundation 278 x 156 studs, tower beacon height approximately 193 studs. Footprint, height and MaxHealth 1,000,000 are provisional until city-plan balancing.
- 739 visible Parts; budget 1,400. Eight SurfaceGui signs; one embedded server runtime. No external meshes or textures. No permanent particle emitters or lights. Turbines are static. Four two-layer lightning paths animate at approximately 8 updates/second in Play using a fixed pool of 64 Parts.
- Electric, KaijuHouse. Existing shared runtime handles damage, collapse, reset and energy notifications; absorption requires separate game integration.
- Hall corners and front piers use butt joints to avoid coplanar concrete/metal overlap. Terminal blocks are separated; entry signage sits forward of portal faces. Roof equipment has seated bases.

## Direct Rojo preview

On feat/mega-city-harbor-gate: git pull --ff-only; stop previous Rojo server; rojo serve mega-city-power.project.json. Studio port 34873. Workspace.MegaCityMajorPowerStation is present in Edit mode without installer or Command Bar. Default project also shows MC-11, on port 34872. Previous dedicated previews remain available.

## Verification

XML parse, unique references, PrimaryPart, 740 anchored Parts including Origin, positive dimensions, orthonormal matrices, integer UDim offsets, metadata round-trip and Lua syntax passed. Front, oblique and rear geometry views inspected. The offline renderer does not reproduce Studio glass, text or neon appearance and can incorrectly occlude details in oblique views.

Gate B awaits user visual acceptance in Studio. Gate C awaits in-engine gameplay and performance checks. MC-12 has not been started.

## Visible lightning update

Four large zigzag discharges on the front and rear of the core replace the thin spiral paths. Cyan translucent halos surround bright white-cyan cores. Native Parts are visible in Edit mode; the embedded runtime varies paths and brightness in Play, follows model transforms, hides them immediately on destruction and resumes after reset. No new Parts are allocated per update. Exported segment IDs/pairs and Lua syntax validated; Studio effect and performance checks pending.
