# Building traversal for Stages 1–4

Stages 1–3 installers now use the same KaijuBuildingTraversal module as the Stage 4 workshop. Dimensions come from the equipped model and its build scale. Existing geometry/dressing approvals are unchanged; building traversal still requires a Studio playtest for each newly enabled stage.

## Behaviour

- Buildings below the model knee height can occupy the space between the legs. A validated moving footfall can call the game-owned damage adapter.
- Larger registered buildings block translation through leg and torso query volumes.
- Facing remains controlled by the Humanoid. Collision correction never restores an old facing direction. Tight turns may briefly overlap visible armor with buildings.
- Existing overlaps permit escape. The physical avatar and torso are exempt only from registered building parts, preventing competing collision responses. Other world geometry retains physical collision.

## Adapter integration

Traversal activates automatically when CombatFactory returns both methods below. Use dot-call functions, matching the existing adapter API.

| Method | Contract |
| --- | --- |
| TraversalTargets() | Return an array of live building records: `{Model=buildingModel, Parts={collidablePart, ...}, Height=heightInWorldStuds}`. Exclude destroyed buildings. Do not register terrain or general ground. |
| StepImpact(footFrame, footSize, kneeHeight) | Server-authorized footfall. Select overlapping buildings shorter than kneeHeight and apply game-owned damage. Never use a client-supplied target or damage amount. Dimensions are world studs. |

Set `EnableTraversal=true` in Installer.Install options to require these methods and fail installation if absent. Set false to explicitly disable. Existing adapters without the methods and PreviewOnly installations retain their previous collision behaviour, with `BuildingTraversalEnabled=false` and `BuildingTraversalDisabledReason` explaining why. The workshop KaijuStageOneCombat adapter already implements both methods.

The owner footfall remote is independent of InstallInput and EnableRemotes; it is created only while traversal is active and validates owner, movement, cadence, foot position and attack state. Uninstall removes its listener, collision exemptions and movement checks.

## Import and validation

Replace complete exported package folders; all three now contain KaijuBuildingTraversal. Versions: Stage 1 1.3.4; Stage 2 1.1.5; Stage 3 1.1.5. Stage 4 retains its old module name as a compatibility wrapper around the shared module.

Headless checks cover setup/cleanup for Stages 1–4 at scales 0.5, 1 and 2; free facing while escaping, wall blocking, existing-overlap escape and footfall validation. Studio still needs to verify each stage against small houses and hip/high towers, including rotation and retreat. Slope and multiplayer checks remain open.
