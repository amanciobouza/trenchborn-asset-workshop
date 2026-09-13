# Stage 1 Primal Beast — 1.0.0

Phase 7 installer for the Stage 1 model and runtime accepted by Amancio in this conversation. Quality Gate C: **Approved by user**. Approved gameplay revision: `e2e669b53806f19f62b76d68c8b4ac6065f71015`.

## Installation

Use `kaiju-stage1.project.json` to build a standalone module package:

```sh
rojo build kaiju-stage1.project.json -o KaijuStageOne.rbxm
```

Insert the result into `ReplicatedStorage`. The package is named `TrenchbornKaijuStageOne`. For the existing workshop Rojo sync, the installer also lives in `ReplicatedStorage.TrenchbornAssetWorkshop`.

Call from a server script after the player's character appearance has loaded and scaling has finished:

```lua
local Installer = require(game.ReplicatedStorage.TrenchbornKaijuStageOne.KaijuStageOneInstaller)
local model, api = Installer.Install(player.Character, {
    CombatFactory = function(kaiju, root, humanoid, rootHeight)
        return YourBuildingCombatService.Attach(kaiju, root, humanoid, rootHeight)
    end,
})

api.SetRunning(true)
api.RequestJump(Vector3.zero) -- Neutral jump. Otherwise pass a flat movement vector.
api.RequestAttack()
-- Later, before switching skins/controllers:
api.Destroy()
```

`YourBuildingCombatService` is an integration point, not a supplied module. The installer requires this adapter rather than silently shipping practice-only damage into the game. Install once per character; call again for each respawn. Duplicate installation is rejected. Uninstall with `api.Destroy()` or `Installer.Uninstall(character)`. Avatar visibility and modified movement settings are restored. No camera properties, default camera script, HUD, key bindings, test buttons, practice targets or auto-respawn listener are installed.

For a workshop-only smoke test, `KaijuStageOneCombat` is included. Explicitly call its `BuildRange(player, ground, character)` and supply its `Attach` as `CombatFactory`; remove the range with `RemoveRange(player)` afterwards. This adapter damages only registered practice buildings. Stop the existing workshop preview before equipping through the installer; both must not control the same character.

## Game input integration

Server API (dot calls): `RequestAttack()`, `RequestJump(direction?)`, `SetAirDirection(direction)`, `SetRunning(boolean)`, `RequestFocus()`, `RequestArea()`, `Destroy()`.

For player characters, owner-checked and rate-limited remotes are created under the model: `RequestAttack`, `RequestJump`, `SteerJump`, `SetRunning`, `RequestFocus`, `RequestArea`. Existing game input/HUD can call them. Send steering only in Windup/Air (about every 0.08 seconds). Clear running when the key is released, focus is lost, or the character changes. Set `EnableRemotes=false` to use only the server API. Do not expose unrestricted server API access to other players.

The rig provides `JumpPhase`, `Running`, `FocusPhase`, `AreaPhase`, `ComboStep`, `FinisherAvailable` attributes and the `KaijuFeedback` event. The main game's HUD/camera may consume these; the workshop client script is deliberately excluded.

## Building adapter contract

All functions use dot calls. Target handles may be game-specific objects.

| Function | Contract |
| --- | --- |
| `Handle(kind, index, targetOrDeadline?, origin?)` | Server-side hit/damage processing. Kinds: Hit, Grab, Land, Focus. Return `true` only for a confirmed hit to trigger arm resistance. Update kaiju `LastAttackResult` to Hit/Miss for audio/feedback. For Hit step 3, the third argument is the finisher deadline; Focus uses the target handle and mouth origin. |
| `Cancel()` | Release reservations/lifted buildings; safe to repeat. |
| `PrepareFinisher()` | Reserve a reachable building only when the finisher will destroy it; return boolean. |
| `SelectFocusTarget(origin)` | Return an eligible target handle or nil. |
| `FocusAim(target, origin)` | Return world hit position and visibility boolean. |
| `AreaImpact(origin)` | Apply the area attack and world impact VFX once; radius and damage belong to the game adapter. |
| `Destroy()` (optional) | Disconnect any adapter-owned listeners and free resources. |

The supplied workshop adapter illustrates building reservations, lifting, splitting, melee target selection and effect timing. Game balance and registration of production buildings remain the game's responsibility.

## Release validation

The user approved the geometry, movement, attacks, audio and latest melee feedback. Installer validation covers source syntax, dependency completeness and packaging boundaries. This environment has no live Studio connection: the new installer still needs an integration smoke test (equip, run, jump, combo/focus/area, defeat, uninstall, respawn) with the game's adapter. The previously approved workshop controller remains available unchanged.
