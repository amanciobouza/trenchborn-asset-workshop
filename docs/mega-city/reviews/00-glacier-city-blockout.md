# MC-00 glacier city blockout — first spatial draft

85 building envelopes measured from the 21 native packages at their current scale. District totals: Transit 9, Neon 17, Stack 25, Reactor 12, Research 10, Corporate 12. Each proxy is named MC-type-copy and labelled on top. These are planning bodies, without KaijuHouse tags, damage or destruction scripts.

Positive Z leads inland; this does not assign compass north. Approximate enclosure width 5,320 studs and inland length 8,250. Shelves rise from 20 to 40 to 60 to 80 studs via 200-stud ramps. Main roads are 180 studs wide; two bridge decks 220 studs wide, at Z=1700 and 5700. Six 400-stud-wide column feet stand near the outer shelves. Cross streets stop before the feet. A 900 × 800 guardian plaza is on solid ground beyond the rift; Mega Tower follows behind it.

Open sea and fjord are simplified Parts, not Terrain water. The inland chasm has a dark bottom at -900; final rock shapes, fog and VFX are pending. Magenta elevated lines indicate railway alignment only, with no final tracks or station connections. Ceiling is a separate optional package, approximately 1,000 studs above shelves, leaving a central sky opening. Ceiling and glacier walls are simple blockout slabs, not final terrain.

Verified: 85 unique building proxies, measured source dimensions, no overlapping building footprints, no building overlap with pillar feet, all building tops below ceiling elevation, valid native XML and positive Part sizes. 258 Parts in the open blockout, eight optional ceiling Parts. Top-down plan inspected. Largest Kaiju and camera have not been measured in this environment; roads, bridge headroom, traversal, performance and landscape composition still need Studio review. This is not a finished city or a final approved layout.

Use an empty Studio place to review. `rojo serve mega-city-blockout.project.json` provides the cutaway overview. `rojo serve mega-city-blockout-cave.project.json` includes the ceiling. Both use port 34873; stop the prior server first. The existing default project remains the Mega Tower preview. Focus Workspace.MegaCityBlockout with F for the overview. In Play, there is no dedicated spawn/travel control in this draft.

Plan: ../plans/00-glacier-layout.svg. Placement data and source bounds: ../plans/00-glacier-layout.json. Rebuild with `python tools/build_glacier_city_blockout.py`; render the plan with `python tools/render_glacier_city_plan.py` (Matplotlib required for rendering only).
