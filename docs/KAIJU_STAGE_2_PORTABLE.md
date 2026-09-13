# Storm Hunter — portable package 1.0.1

Stage 2 geometry, dressing and workshop gameplay were approved by Amancio. The approved runtime baseline is `803c8ae4789f87b1a20ba6fa5433ecfda5e49675`. Import integration in a different project remains to be tested.

## Import

1. Stop Play and download `dist/KaijuStageTwo.rbxmx`.
2. Insert into ReplicatedStorage as `TrenchbornKaijuStageTwo`.
3. For a first installation, copy `examples/KaijuStageTwo.server.lua` into ServerScriptService.
4. Set `Scale=1` (normal), `0.5` (half) or `2` (double) in the Install options.
5. Restart Play.

The example uses PreviewOnly=true: movement and untargeted animation preview, no building damage and no focus target. Supply the target game's CombatFactory for actual combat.

To switch from Stage 1, disable its equip bootstrap and uninstall its active character using its owning installer before installing Stage 2. Do not run both equip scripts together. Both package folders can coexist, but only one Kaiju should be equipped. For upgrades, replace the entire Stage 2 package folder while Play is stopped.

## Server API

```lua
local Installer=require(game.ReplicatedStorage.TrenchbornKaijuStageTwo.KaijuStageTwoInstaller)
local model,api=Installer.Install(character,{
 Scale=1,
 InstallInput=true,
 CombatFactory=function(model,root,humanoid,rootHeight)
  return YourBuildingCombatService.Attach(model,root,humanoid,rootHeight)
 end,
})
-- api.Destroy() or Installer.Uninstall(character) restores the avatar.
```

Install after avatar appearance/scaling is complete. The model is placed by its soles; the body collider and rig are built at the selected scale. Scale must be finite and positive. Change scale by reinstalling, not by scaling an attached rig. Native avatar dimensions, movement speeds, cooldowns and game-owned damage values do not multiply with Scale.

API methods: RequestAttack, RequestJump(direction?), SetAirDirection(direction), SetRunning(boolean), RequestFocus, RequestArea, Destroy. Calls use dot syntax. SetAirDirection is retained for compatibility; native Roblox movement controls horizontal air motion.

## Combat adapter

Same contract as Stage 1. All methods use dot syntax.

| Method | Responsibility |
| --- | --- |
| Handle(kind,index,targetOrDeadline,origin) | Hit, Grab, Land and Focus. Return true only on a confirmed hit. Set LastAttackResult to Hit/Miss for feedback. |
| Cancel() | Release pending or held buildings; safe to repeat. |
| PrepareFinisher() | Reserve a reachable building only when the rip-apart blow will destroy it. Return boolean. |
| SelectFocusTarget(origin) | Return a valid building target or nil. |
| FocusAim(target,origin) | Return target position and visibility. |
| AreaImpact(origin) | Apply area damage and game-owned explosion effects once. |
| Destroy() | Optional adapter cleanup. |

Building health, destruction, rewards and target selection belong to the target game. No workshop range, practice buildings, HUD or camera controller is included.

## Input and lifecycle

InstallInput=true installs keyboard, controller and touch actions: movement uses native Roblox controls; Shift/L3 toggles run, Space/A jumps, F/R2 or primary mouse attacks, E/L2 focuses, R/Y discharges. Hold jump while swimming to rise. Touch labels use TextScaled.

Omit InstallInput when the game supplies its own input. The jump motor client is always installed for players, even with InstallInput=false. EnableRemotes=false disables input request remotes; it cannot be combined with InstallInput=true. Server-authorized jump impulses still use the motor.

Request remotes validate owner, payload and rate. Do not route unvalidated external requests into the server API. Destroy/uninstall disconnects the rig, removes package-owned input, motor, collider and model, and restores saved avatar properties.

## Included runtime

Eight embedded scripts: Stage 2 installer and geometry builder, shared base geometry, rig, combo and jump modules, Stage 2 input, and shared jump motor. Shared module names containing StageOne are intentional; the installed figure is Stage_2_Storm_Hunter.

Includes basalt armor, branching yellow energy veins, synchronized cyan attack energy, walk/run, jump, Terrain swimming, punch combo, conditional rip-apart finisher, focus, area charge, hit reactions, corrected defeat arm settling and flickering lights with eyes last. Sound assets still require access in the receiving experience.

## Build and validation

Run `python tools/build-kaiju-stage2.py`, or optionally `rojo build kaiju-stage2.project.json -o KaijuStageTwo.rbxm`.

The Python export checks eight scripts, local package dependencies and exact XML source round-trip. The manifest records SHA-256 for each source and the artifact. These checks do not run Roblox physics or render the model.

Target-project checks: import, scale, equip, slopes, jump/landing, swimming, real damage/finisher adapter, focus and area effects, defeat, respawn and uninstall. Keep your game's existing camera and HUD integration.

## Release 1.0.1: procedural pose ownership

The rig now exclusively owns the tagged Kaiju Motor6D joints. Server and client clear additive Animator Transform values in PreSimulation while preserving the authored C0/C1 poses. This addresses the integration failure path where avatar animation is added to the Kaiju shoulders and wrists. Disabling Animate alone does not provide this isolation. No additional wrist-angle compensation was added.

KaijuStageOneJumpMotor is the always-installed pose-and-jump runtime, including with InstallInput=false and EnableRemotes=false. Its pose guard starts independently of jump remote discovery, covers replicated Kaijus, and handles late joint arrival/removal. Only TrenchbornProceduralJoint-tagged joints are affected. The rig removes its tags on Stop; the client disconnects on destruction.

Replace the complete package folder and restart Play. Source/package checks passed; Stage 1 and Stage 2 still require a target-project playtest at Scale=1, InstallInput=false: idle, walk, run, attacks, respawn and unequip/re-equip. The target game must not directly overwrite Kaiju joint C0/C1. PoseOwnershipRevision=ProceduralC0_01 identifies the updated runtime.
