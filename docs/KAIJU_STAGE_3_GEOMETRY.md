# Stage 3 — technical breakdown and geometry candidate

## Approved direction (Gate A)
The user approved the three-view Stage 3 concept, particularly its increasingly rocky, distinctive back. Add modest lateral rib plates; keep the central chest closed and organic. Large chest energy openings and a crown remain reserved for later stages.

## Phase 3 construction
- Independent StageThree builder derives fresh StageTwo geometry inside a temporary folder; neither accepted builder is edited.
- Preserve ellipsoid muscles, rounded rectangular muzzle, forward luminous eyes and segmented cylinder tail.
- Broaden/deepen anatomy consistently across attached pieces; add chest, back and neck volume.
- Enlarge the principal dorsal plates and create overlapping, staggered corner-wedge splinters on both sides. Rebuild yellow insets against the resized plates.
- Add small brow/cheek, lateral rib, hip and shin armor using Parts, Wedges and CornerWedges.
- Relative authored size is 1.12 times Stage 2 after anatomy changes. Optional Scale multiplies the entire result before sole alignment and placement.
- Planned rig regions: HeadArmor to head, RibArmor to torso, HipArmor to thigh/pelvis after deformation review, ShinArmor to shin, DorsalRock to the matching torso/tail region. These prefixes are now enabled for the user-requested early movement preview. HipArmor follows the thigh.

## Phase 4 candidate
Module: src/ReplicatedStorage/TrenchbornAssetWorkshop/KaijuStageThreeGoldenMaster.lua
API: Builder.Build(parent, groundCFrame, {Scale = 1})
Model: Stage_3_Rift_Stalker (existing technical lineage identifier).

Stage3Scale is an optional number attribute on KaijuEvolutionBlockoutPreview. On Play/respawn the user controls Stage 3 with the shared rig, input and jump motor. Stages 1 and 2 remain stationary side by side at the original display positions. This is an explicitly requested early movement preview; geometry and gameplay gates remain pending.

## Review
Gate A approved; Gate B and Gate C pending. Inspect front, side and back: connected rock masses, silhouette separation from Stage 2, eye visibility, closed chest center and attached armor. Syntax checked locally; no Studio render or physics test was performed by the assistant. Body/armor intersection and animation clearance still need visual review. The inherited Stage 2 materials provide context; Stage 3 dressing and cross-region energy detail follow geometry approval.
