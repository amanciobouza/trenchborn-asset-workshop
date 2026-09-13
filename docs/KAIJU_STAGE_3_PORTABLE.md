# Rift Stalker — portable package 1.0.0

Stage 3 geometry, dressing and workshop gameplay were approved by Amancio. The approved runtime baseline is `8a88c8ab7fe9e36ce6b7c6ea3f9c911942513456`. Import integration in a different project remains to be tested.

## Import

1. Stop Play and download `dist/KaijuStageThree.rbxmx`.
2. Insert into ReplicatedStorage as `TrenchbornKaijuStageThree`.
3. For a first installation, copy `examples/KaijuStageThree.server.lua` into ServerScriptService.
4. Set `Scale=1` (normal), `0.5` (half) or `2` (double) in the Install options.
5. Restart Play.

The example uses PreviewOnly=true: movement and untargeted animation preview, no building damage and no focus target. Supply the target game's CombatFactory for actual combat.

To switch from Stage 1 or Stage 2, disable its equip bootstrap and uninstall its active character using its owning installer before installing Stage 3. Package folders can coexist, but only one equip bootstrap and one Kaiju should be active per character. For upgrades, replace the entire Stage 3 package folder while Play is stopped.

## Server API

```lua
local Installer=require(game.ReplicatedStorage.TrenchbornKaijuStageThree.KaijuStageThreeInstaller)
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

Nine embedded scripts: Stage 3 installer, Stage 3 and Stage 2 geometry builders, shared base geometry, rig, combo and jump modules, Stage 3 input, and shared pose/jump motor. Shared module names containing StageOne are intentional; the installed figure is Stage_3_Rift_Stalker.

Includes basalt armor, branching yellow energy veins, synchronized cyan attack energy, walk/run, jump, Terrain swimming, punch combo, conditional rip-apart finisher, focus, area charge, hit reactions, corrected defeat arm settling and flickering lights with eyes last. Sound assets still require access in the receiving experience.

## Build and validation

Run `python tools/build-kaiju-stage3.py`, or optionally `rojo build kaiju-stage3.project.json -o KaijuStageThree.rbxm`.

The Python export checks nine scripts, local package dependencies and exact XML source round-trip. The manifest records SHA-256 for each source and the artifact. These checks do not run Roblox physics or render the model.

Target-project checks: import, scale, equip, slopes, jump/landing, swimming, real damage/finisher adapter, focus and area effects, defeat, respawn and uninstall. Keep your game's existing camera and HUD integration.

## Stage 3 release contents

Includes the approved cheek armor, layered chest/hip/knee basalt, growing upper-arm armor, asymmetric energy fissures, broken back fissures and the strengthened focus beam. Energy follows its assigned body region and uses the existing attack/defeat effects. The chest center remains closed.

The always-installed client clears additive Animator transforms on tagged Kaiju joints, including when InstallInput=false or EnableRemotes=false. This preserves the authored pose in a target character with an existing animation controller. Import the complete folder, including KaijuStageOneJumpMotor. The target game's scripts must not overwrite Kaiju C0/C1 directly.

The package stamps the approved workshop gates after attaching the shared rig. IntegrationReview remains PendingInTargetProject: import/equip, Scale=1 and InstallInput=false, combat adapter, respawn and uninstall still need testing in the receiving game. Package verification does not run Roblox physics or rendering.
