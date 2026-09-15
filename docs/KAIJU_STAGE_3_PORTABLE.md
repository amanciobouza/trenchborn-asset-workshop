# Rift Stalker — portable package 1.1.5

This release moves procedural animation and Kaiju effects to client presentation. Geometry and the accepted animation definitions are retained. The earlier ApprovedRevision remains a baseline; the new runtime and target-project integration are pending playtest.

## Import or upgrade

1. Stop Play and download `dist/KaijuStageThree.rbxmx`.
2. Replace the complete `ReplicatedStorage.TrenchbornKaijuStageThree` folder. Do not mix old rig, jump motor and new presentation modules.
3. For a first installation, copy `examples/KaijuStageThree.server.lua` into ServerScriptService.
4. Restart Play. The example uses PreviewOnly=true until the target game's combat adapter is supplied.

Only one stage may be equipped per character. Uninstall through its owning installer before switching stages; disable competing equip bootstraps. Package folders can coexist.

## Server API

```lua
local Installer = require(game.ReplicatedStorage.TrenchbornKaijuStageThree.KaijuStageThreeInstaller)
local model, api = Installer.Install(character, {
    Scale = 1,
    InstallInput = false,
    CombatFactory = function(model, root, humanoid, rootHeight)
        return YourBuildingCombatService.Attach(model, root, humanoid, rootHeight)
    end,
})
-- api.Destroy() or Installer.Uninstall(character) restores the avatar.
```

Install after avatar appearance/scaling completes. Scale is a finite positive build-time multiplier: 0.5 halves the figure, 2 doubles it. Geometry, collider dimensions and cached rig dimensions follow that scale. Native avatar size, movement speeds, cooldowns and game-owned damage values do not multiply. Reinstall to change scale; do not ScaleTo an attached rig.

Methods use dot calls: RequestAttack, RequestJump(direction?), SetAirDirection(direction), SetRunning(boolean), RequestFocus, RequestArea, GetCombatFrame(boneName), Destroy. SetAirDirection remains a compatibility no-op; native movement controls horizontal motion in air. Jump authorization changes vertical velocity without stopping movement.

An accepted focus or area attack stops and locks the movement root through charge, discharge and recovery. Movement input and nonlethal hit reactions cannot interrupt it. Death and uninstall still terminate it. Damage is not disabled during specials.

## Input and presentation

InstallInput=true adds optional keyboard, controller and touch bindings: native movement, Shift/L3 run, Space/A jump, F/R2 or primary mouse attack, E/L2 focus, R/Y discharge. Hold jump while swimming to rise. Touch text uses TextScaled.

InstallInput=false keeps the game's own controls. EnableRemotes=false suppresses input-request remotes and cannot be combined with InstallInput=true. Owner/payload/rate validation remains on enabled request remotes.

**Presentation and the authorized jump motor are installed independently of InstallInput and EnableRemotes.** Every player, including spectators, receives one shared presentation observer. The observer survives respawns and renders all streamed Kaijus. Unequip removes that Kaiju's rendering and restores the original character; the observer remains for other players.

No camera controller, workshop HUD, Guardian controls or practice targets are imported. KaijuFeedback retains server combat/landing cues; footsteps and their sounds are now local presentation. Existing integrations that used server footstep cues must source those cues locally. No camera settings change.

## Combat adapter

| Method | Responsibility |
| --- | --- |
| Handle(kind,index,targetOrDeadline,origin) | Handle Hit, Grab, Land and Focus; return true for confirmed hits and set LastAttackResult to Hit/Miss. |
| Cancel() | Release held/reserved buildings; safe to repeat. |
| PrepareFinisher() | Reserve a reachable target only if the optional rip-apart move destroys it. |
| SelectFocusTarget(origin) | Return a target handle or nil. |
| FocusAim(target,origin) | Return target point and visibility. |
| AreaImpact(origin) | Apply game-owned area damage once. |
| Destroy() | Optional adapter cleanup. |

The third-hit finisher deadline keeps the existing server os.clock domain. Building registration, health, rewards, destruction and persistence remain the target game's responsibility. The workshop-only KaijuStageOneCombat adapter is not embedded.

**Adapters reading animated server hand Parts must migrate to GetCombatFrame.** Server joints now remain at rest. Use `api.GetCombatFrame("LeftHand")` or, inside the adapter after rig attachment, `require(model.KaijuPoseProvider.Value).GetCombatFrame(model, "LeftHand")`. This supplies an authoritative attack frame for hit probes and building grips. The workshop adapter has been migrated.

Keep already-authorized Focus/Area attacks valid during transient FloorMaterial=Air while SpecialAttackLocked is set. To use the shared local area spheres/debris, set KaijuAreaVisualRadius to the radius in world studs and remove duplicate server burst effects. Otherwise retain the game's own explosion visuals.

## Included runtime and validation

13 embedded scripts include geometry, installer, shared server controller, immutable skeleton builder, client presentation, shared observer/bootstrap, combo/jump timing, optional stage input and owner jump motor. Names containing StageOne are shared dependencies; the equipped figure remains Rift Stalker.

Run `python tools/build-kaiju-stage3.py` or `rojo build kaiju-stage3.project.json -o KaijuStageThree.rbxm`. The Python builder checks exact embedded source round-trips; the manifest records source and artifact hashes. `python tools/test-kaiju-replication.py` exercises mocked runtime contracts across all five stage numbers.

See [client presentation architecture and adapter migration](KAIJU_CLIENT_PRESENTATION.md) for synchronization, distance quality levels, streaming and test scope. No Roblox Studio rendering or measured multiplayer performance result is claimed. Test import, Scale=1/InstallInput=false, spectators, slopes, jump, swimming, combat grip, specials, streaming, defeat, respawn and uninstall in the receiving experience. Sound assets need permission in that experience.

## Shared building traversal

See [building traversal and adapter integration](KAIJU_BUILDING_TRAVERSAL.md) for the shared Stage 1–4 collision and validated footfall behaviour. Replace the entire package on upgrade.
