# Stage 5 — Phase 3 technical breakdown

## Approval and scope

Quality Gate A is approved by the user (“yesss!”) for the three-view concept with translucent yellow energy-field sails between the dorsal plates. The preceding concept without the membranes is superseded. The marked crater chest and recessed energy core are equally important silhouette anchors. This document defines the proposed implementation, not completed geometry. Quality Gate B and C remain pending. Stage 4 slope and multiplayer tests remain open independently.

Use the approved three-view image in the conversation as the visual target. No new stage name is selected here. Preserve the established blue-black upright reptilian lineage, broad muzzle, thick neck, massive digitigrade legs, clawed feet and articulated tail. No wings, organic sail skin or opaque stone filling the sail gaps.

## Construction sequence

1. Build Stage 4 geometry in an isolated staging model at normalized scale. Do not modify Stage 4 builder or its approved model.
2. Replace the central chest plate arrangement with the crater assembly. Remove or reshape only the forward torso surfaces that would conceal the recess; keep a closed backing surface.
3. Grow and reshape the existing dorsal spars, then define one sail bay for each adjacent pair. Keep their existing articulation indices.
4. Add the compact rocky head crown, neck transition and larger shoulder/limb plates with explicit joint ownership.
5. Review geometry and membrane boundaries in neutral front, side and rear views, then in the existing poses. Apply the caller's build scale once and position by sole ground contact.
6. After Quality Gate B, implement final translucent energy materials, luminous borders, branching filaments and synchronized color transitions in Phase 5.

## Crater chest

The front must read as a sculptural crater even with all emission disabled. Build three layers: broad outer armor reaching towards the shoulder plates, irregular raised inner rock lips, and a recessed core behind those lips. Keep the chest cavity closed and dark behind the core; it must not become a hole through the model.

Initial geometry targets, to adjust against the approved image:

| Element | Starting relationship |
| --- | --- |
| Overall chest armor | Approximately 90–95% of the shoulder span in the neutral pose, leaving independent shoulder articulation |
| Crater aperture | Approximately 30–35% of chest armor width; irregular vertical opening |
| Visible recess depth | Approximately 12–18% of chest armor width from the outer lip to the core front |
| Core | Occupies approximately 55–65% of aperture width; surrounding recess remains visible |
| Lower armor | Three or four offset overlapping rows tapering towards the abdomen |

Do not model a flat illuminated disk, a metal reactor ring or a perfectly circular opening. Keep the chest mass balanced but vary rock contours and fissures across sides. Build the recess forward from the existing torso envelope where possible; do not hollow out or thin the locomotion rig. Move, segment or replace the obscuring outer body surfaces where necessary rather than hiding the core inside them.

## Dorsal energy sails

The current skeleton maps dorsal plates 1–3 to Torso and plate i>3 to Tail(i−2). There are eleven plate positions in Stage 4. Retain these positions as the starting topology: ten sail bays connecting plates 1–2 through 10–11. Shape is driven by the approved image, so the height of the spars and membranes may change without changing their indices.

Each bay has local anchor coordinates on BOTH supporting plates: upper and lower anchors at each side. The upper boundary has a shallow inward curve; the field reaches between the spars instead of merely sitting on a rock face. The bays decrease in area towards the tail. Keep membranes on the central dorsal plane, distinct from lateral spikes.

For the geometry review, use visible neutral/translucent proxy surfaces and explicit anchors. No final glow is needed to establish the sail silhouette. Proposed runtime representation: a small fixed tessellation of triangular field panels with curved-edge samples, transformed from the two animated anchor frames. Start with four to six triangles per bay; measure actual part count and rendering cost before fixing the budget. Preallocate panels; do not create geometry per frame.

A field spanning two moving bones must not be rigidly welded to only one of them. Store anchor positions relative to each supporting plate's assigned bone. In the client presentation pass, resolve both endpoints from the rendered pose and update the intervening surface. Keep the underlying rock spars rigid on their own bones. Collapse or hide degenerate panels rather than normalizing zero-length edges. Geometry fallback must still draw an actual translucent surface, not just beams around an empty gap.

## Rig ownership

| Component | Ownership |
| --- | --- |
| Crater lips, chest backing, core and abdomen plates | Torso |
| Crown, brows and rear-skull wedges | Head |
| Lower jaw armor | Jaw |
| Neck base / upper back transition | Torso, with clearance to Head |
| Shoulder / upper arm armor | LeftUpperArm / RightUpperArm |
| Forearm armor | LeftForearm / RightForearm |
| Hip and thigh armor | LeftThigh / RightThigh |
| Knee / shin armor | LeftShin / RightShin |
| Heel armor | Matching Foot or Hock based on actual placement |
| Dorsal spar i | Existing dorsal index mapping |
| Sail bay i | Two anchor frames: spar i and spar i+1; client surface interpolation |

Extend KaijuSkeleton with explicit Stage 5 prefix mappings for core/crown parts; do not rely on an incidental fallback region. Put client-generated sail surfaces outside generic rigid-part assignment and keep them out of physical collision, touch events and gameplay targeting.

## Dressing and animation plan

Basalt stays dark charcoal with worn lighter edges, organic masses blue-black. Core, chest fissures, membrane borders and filaments use yellow in the normal state. All switch to cyan for Focus and Area, then restore yellow. Preserve the same attack timings and damage ownership.

KaijuPresentation currently collects tagged BaseParts and GuiObjects for special energy colors. Sail surfaces and border renderers must participate in that same lifecycle, including those created by the sail presentation component. Reset colors on cancel, death, respawn and renderer teardown. Keep membrane centers translucent and borders brighter; bloom must not erase rock contours or fill the cavity visually.

During tail bends, vary the sail span through endpoint movement rather than stretching the supporting rock. The defeat pose must not produce elongated triangles through the floor. Recreate only client presentation state after streaming/respawn; never transmit per-frame panel transforms from the server.

## Gameplay integration reserved for Phase 6

Extend shared building traversal to accept Stage 5 only when its geometry is available and reviewed. Derive knee/torso probes from the actual Stage 5 model. Sail fields, core and decorative armor do not become extra physical colliders. Maintain free facing and translation-only building blocking.

Re-evaluate chest-height finisher clearance against the new crater lips, forearms and jaw. The current chest-height finisher explicitly covers Stages 2–4; Stage 5 needs deliberate inclusion after pose verification. Do not alter damage, attack cooldowns or target selection as a side effect of the visual evolution.

## Planned files and gate evidence

- KaijuStageFiveGoldenMaster.lua: isolated geometry build and sail anchor definitions.
- KaijuStageFiveDressing.lua: approved surfaces and color tags, added after geometry approval.
- KaijuEnergySailPresentation.lua: preallocated client field surfaces following adjacent bones.
- Explicit Stage 5 mapping/wiring changes in shared skeleton and presentation modules.
- Geometry review views: front, side, rear, plus chest close-up and bent-tail sail close-up.

Before Gate B: confirm the frontal crater silhouette, actual visible recess, ten filled sail gaps, endpoint alignment under tail bending, open limb joints, crown/neck clearance, grounded feet and no accidental duplicate Stage 4 chest faces. Automated topology/anchor checks support these views but do not replace the user's visual approval.

Next phase: build the Stage 5 geometry candidate. Final dressing, gameplay approval and final installer follow their respective gates.


## Phase 4 candidate 01 implementation

KaijuStageFiveGoldenMaster now builds an isolated copy of Stage 4 with twelve irregular crater sectors, dark inner walls/backing, a visible recessed core, tapering abdomen plates, five crown shards and enlarged articulated shoulder/limb shells. The cavity is built forward of the inherited torso front envelope, so the old body cannot hide the core. Its depth attribute is world-scaled; NormalizedChestRecessDepth records the authored value.

Eleven dorsal spars support ten filled static sail proxies. Each bay uses three tessellated strips (six triangles; up to twelve wedge pieces) and four ObjectValue links to upper/lower attachments on adjacent plates. Warm yellow translucent review surfaces show field coverage; these are not final emissive dressing.

The existing workshop still equips Stage 4. A stationary Stage 5 candidate appears at origin offset X=-155 with a STAGE 5 · GEOMETRY REVIEW label. Its failure is reported without aborting Stage 4 setup. Stage5Scale is a build-time script attribute, like the earlier stage scale controls. No animation rig is attached to this static candidate: assigning a sail to only one bone would give a misleading movement preview. Two-anchor animated sail presentation remains the next geometry task.

`python tools/test-stage5-geometry.py` checks triangle area/vertices and right-handed frames, degenerate input, ten filled bays and forty anchor references, cleanup, scale/ground placement and pending approval attributes. Build orchestration uses a synthetic Stage 4 fixture, not the full Roblox geometry. Actual full-model generation, visual proportions, overlaps and dynamic sail clearance are unverified until Studio review. Quality Gate B remains pending.

### Steuerbare Geometrievorschau

Die Workshop-Vorschau rüstet jetzt Stufe 5 aus; Stufe 4 bleibt als Vergleich stehen. Bewegung, Sprung, Angriffe, Brusthöhen-Finisher und Gebäudekollision verwenden die gemeinsamen Systeme. Zehn Segelfelder werden clientseitig aus beiden animierten Plattenrahmen aktualisiert, mit wiederverwendeten Dreiecksteilen und vollständigem Aufräumen beim Respawn. Die Geometrievorschau bleibt Phase 4; Gate B und C sind offen. Bewegung, Segelanschlüsse und Gebäudeverhalten müssen in Studio geprüft werden.

### Oberer Rücken und durchgehende Segel

Zwei überlappende, facettierte Panzerreihen decken den oberen Rücken von Schulteransatz zu Schulteransatz ab und folgen dem Torso. Alle zehn Segelfelder verbinden weiterhin die elf Hauptplatten. Ihre Anschlüsse richten sich nach aussen (Rücken: hinten, Schwanz: oben), statt die entfernteste Ecke vom Körperzentrum zu wählen. Die untere Kante ist nach aussen versetzt, der Durchhang auf sechs Prozent reduziert. Die beiden vom Benutzer gemeldeten sichtbaren Lücken sind ohne Studio-Aufnahme nicht lokalisiert; die Korrektur muss dort visuell bestätigt werden.

### Körpernahe Panzerung und flachere Krone

Brust: Abstand zur Haut reduziert und Kratertiefe von 15 auf 9,5 Prozent der Brustbreite verringert; der Kern bleibt vor der ursprünglichen Körperoberfläche. Rücken: Panzerpunkte folgen der jeweils äussersten Körperoberfläche statt einer gemeinsamen hinteren Begrenzung. Dünnere, leicht überlappende Reihen erhalten die Schulterbreite. Krone: fünf kürzere, breitere, im Schädel eingebettete Felszacken mit nach hinten versetzten Seiten. Die visuelle Freigabe bleibt offen.

### Füsse, aufsteigende Schultern und Kopfschuppen

Stufe 5 erhält um 24 Prozent breitere und 18 Prozent längere Füsse, einschliesslich Zehen, Klauen und Fersenpanzer. Drei überlappende Panzerplatten pro Fuss folgen dem Fussgelenk. Drei seitlich nach oben gezogene Schulterplatten pro Seite folgen dem Oberarm. Die Krone wird durch neun breite, scharfe Panzerzacken in drei gestaffelten Reihen ersetzt; ihre Spitzen zeigen ausdrücklich nach hinten oben. Die körpernahe Brust- und Rückenpanzerung bleibt erhalten. Studio-Sichtprüfung und Gelenkfreiheit sind offen.
