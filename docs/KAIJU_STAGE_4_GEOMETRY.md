# Stage 4: technical breakdown and geometry candidate

Design approved by Amancio: three broad basalt chest rows per side, narrow energy gaps, a larger irregular rocky dorsal ridge, reinforced shoulder/forearm/hip/shin regions. Central exposed reactor and large skull crown are reserved for Stage 5. No new stage name has been approved; the runtime uses Stage_4_Geometry_Review.

## Phase 3: technical breakdown

Build on KaijuStageThreeGoldenMaster at normalized scale. Retain anatomy, face, cheek plates, digitigrade limb topology, segmented tail and established mirrored bevel construction. Grow shoulder groups by 12/8/12 percent in local X/Y/Z and other limb armor groups by 10/6/10 percent, transforming attached fissures with them. Grow the first three dorsal clusters by 18/22/16 percent and the remaining clusters by 10/12/8 percent. Each cluster keeps its existing articulated region index. Overall authored scale is 10 percent above Stage 3; the caller's Scale multiplier applies once.

Replace the two small lateral rib plate groups per side with three broad double-layer bevel plates. Width is capped to preserve the center opening in the armor; the underlying chest remains solid. Rows have distinct physical gaps. New chest energy is Phase 5 work after geometry approval. Inherited Stage 3 lighting is retained to keep comparisons readable.

Rig mapping: RibArmor prefixes attach to Torso, HipArmor to Thigh, ShinArmor to Shin, ShoulderArmor to UpperArm, ForearmArmor to Forearm. DorsalShield/Energy/Rock retain their numbered mappings to Torso or tail bones. No new joints or animation contract changes.

## Phase 4: review

The workshop now equips Stage 4. Stages 1–3 remain as comparisons. Stage4Scale on the preview script controls its build scale. Quality Gate A is approved; B and C remain pending. Attaching the existing runtime enables pose review without claiming completed dressing or gameplay approval. There is no portable Stage 4 installer yet.

Inspect front, side and rear: chest segments should sit outside the organic chest with a continuous exposed central strip and clear row gaps; shoulders/forearms must retain hand and jaw clearance; knee/hip armor must remain fitted; the dorsal ridge must have a heavier silhouette. Check clipping during attacks and defeat before approving geometry.

Validation: Lua syntax, module/selection wiring and existing five-stage simulated runtime tests. Roblox rendering, geometric fit, collisions and target fidelity still require Studio review.

## Revision 02: heavier armor, lateral spines and heel protection

User requested larger chest/shoulders, additional arm and leg coverage, especially behind the heels, and spines beside the dorsal ridge. Chest foundations increase from 0.68 to 1.05 normalized studs deep, with 0.58-deep overlap layers, wider rows and greater stand-off. Shoulder growth is now 32/20/30 percent over Stage 3; other existing limb groups grow 18/12/18 percent. Additional double-layer shells cover rear shoulders, upper arms, rear/front forearms, rear thighs/calves and rear/outer heels. Three rooted wedge rock spines per side flank the dorsal ridge. All additions use existing articulated prefixes; HeelArmor belongs to Foot, rear calves to Shin, and lateral spines to Torso. No new joints.

Syntax checked and source part names/region mappings inspected. Fit and ground clearance of heel shells, spike silhouette, and arm/chest overlap still require Studio review. Geometry gate remains pending.

## Revision 03: outward spines through the tail root

The wedge's thin -Z edge now points along the outward direction; its broad +Z base is embedded 0.18 normalized studs into the shell. Removed the previous 90-degree axis rotation and assigned length to local Z. Each side now has five spines, tapering from 3.0 to 1.35 studs. The two additional pairs sit on SacralMass and TailRootMass. PelvisArmor maps to Pelvis and TailBaseArmor to TailBase, so no rigid spine crosses the torso/pelvis/tail joint.

Syntax and the broad-base/thin-tip projections checked; final silhouette and motion still need Studio review.
