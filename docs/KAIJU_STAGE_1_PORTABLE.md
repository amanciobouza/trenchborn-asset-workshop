# Primal Beast — portable package 1.1.4

## Import into another Roblox project

1. Download `dist/KaijuStageOne.rbxmx` from this repository (GitHub **Raw / Download raw file**).
2. Open the target place in Studio. Insert the model file into **ReplicatedStorage**, preserving folder name **TrenchbornKaijuStageOne**.
3. Copy `examples/KaijuStageOne.server.lua` into a Script under **ServerScriptService**.
4. Play. The example equips Stage 1 on join/respawn, in explicit movement-only preview mode.

The package contains the current geometry, articulated rig, gait, jump, native Terrain-water swimming, attacks and sounds. It contains no Stage 2 preview, Guardian controller, workshop HUD/test targets or camera code. Seven scripts are embedded; there are no HTTP loaders or numeric `require(assetId)` dependencies. Roblox sound asset IDs still require permission to play in the target experience.

## Input

`InstallInput=true` installs the optional client input script, including touch buttons. WASD/default Roblox movement; Shift run (L3/touch toggle); Space/A jump, held while swimming to rise; F/R2 or primary mouse attack; E/L2 focus; R/Y discharge. Input is removed on uninstall. All touch labels use TextScaled. Do not enable this option if the game's controller already binds these actions.

The installer preserves the target project's camera settings. Configure your game's camera for this large character separately. The old workshop camera offsets are deliberately not imported.

## Enable real building damage

The example uses `PreviewOnly=true`: punches animate but do not damage buildings; focus has no target; area has its charging animation but no game-specific explosion/damage implementation. To enable gameplay, remove PreviewOnly and supply `CombatFactory(model, root, humanoid, rootHeight)` returning your game's adapter. No practice-building registration is installed automatically.

Adapter methods use dot calls:

| Method | Required behavior |
| --- | --- |
| Handle(kind,index,targetOrDeadline,origin) | Handle Hit, Grab, Land and Focus. Return true only on a confirmed hit; set model LastAttackResult to Hit/Miss for audio. Hit step 3 receives finisher deadline; Focus receives target and mouth origin. |
| Cancel() | Release any held/reserved buildings; safe to repeat. |
| PrepareFinisher() | Reserve a reachable building only if the rip-apart blow will destroy it; return boolean. |
| SelectFocusTarget(origin) | Return a target handle or nil. |
| FocusAim(target,origin) | Return hit position and visibility boolean. |
| AreaImpact(origin) | Apply the area attack and its world explosion effects once. |
| Destroy() | Optional cleanup of adapter-owned resources. |

The existing `KaijuStageOneCombat.lua` in the workshop repository demonstrates the adapter implementation but is not embedded in the portable package: it only damages workshop-registered targets. Building registration, damage values, rewards and persistence remain owned by the target game.

## Server and custom client integration

`local model, api = Installer.Install(character, options)` after appearance/scaling finishes. Server methods: RequestAttack, RequestJump(direction?), SetAirDirection(direction), SetRunning(boolean), RequestFocus, RequestArea, Destroy. Destroy or Installer.Uninstall(character) restores avatar visibility and modified movement properties. Reinstall for each new character; a duplicate active installation is rejected.

For player characters, remotes under the installed model validate owner, payload and rate: RequestAttack, RequestJump, SteerJump, SetRunning, RequestFocus, RequestArea. Set EnableRemotes=false when only a trusted server controller drives the API (incompatible with InstallInput=true). Never forward unvalidated client requests to the server API yourself.

Custom input should send flat MoveDirection on jump, release running on focus loss, and leave normal Roblox movement enabled in the air. SteerJump remains accepted for compatibility but no longer overrides native movement. Swimming ascent is native client Humanoid:Move with an upward component while Jump is held. State attributes include Swimming, JumpPhase, Running, ComboStep, FocusPhase, AreaPhase and FinisherAvailable. KaijuFeedback emits camera/UI cues, but the package does not consume them or change your camera.

## Rebuild and validation

`python tools/build-kaiju-stage1.py` rebuilds the XML model and SHA-256 manifest using Python standard library only. Alternatively use `rojo build kaiju-stage1.project.json -o KaijuStageOne.rbxm`. XML source round-trips and package dependency isolation are checked; the artifact is not a rendered model or a Studio test result.

The original Stage 1 visual/gameplay approval is recorded as a baseline. The package and its input integration still need testing in the receiving experience: import, equip, run, jump, water entry/ascent/exit, real combat adapter, defeat, respawn and uninstall. Sound permissions and the game camera must also be checked there.

## Jump motor in 1.1.1

The installer always installs KaijuStageOneJumpMotor for player characters, including when InstallInput=false. It receives server-authorized vertical impulses through KaijuJumpImpulse, preserves horizontal velocity, and does not bind keys or control the camera. Import the complete updated package; replacing the rig alone omits this required client. No jump windup delay or server network-ownership takeover remains. Turning and walk/run speed remain controlled by the native character controller in air. Updated movement still needs a target-project playtest.

## Accepted release 1.1.4

Amancio approved the jump/landing correction at source revision `e835a34d4d65a8a73a895da704d2f960190e047e`. This release packages that accepted runtime unchanged: native movement in air, no landing crouch/rebound pose, short suppression of upward physical contact rebound, terrain swimming and latest sounds. The installer records this approval as its current ApprovedRevision. Target-project integration remains separately testable.

To upgrade an existing import: Stop Play, uninstall an active installation if needed, then replace the entire ReplicatedStorage.TrenchbornKaijuStageOne folder with dist/KaijuStageOne.rbxmx. Do not retain old modules or omit KaijuStageOneJumpMotor. Keep the target game's bootstrap, CombatFactory, camera and HUD. Restart Play so require caches are fresh. For a first import, use examples/KaijuStageOne.server.lua; its PreviewOnly=true is deliberately movement-only until the game's damage adapter is supplied.
