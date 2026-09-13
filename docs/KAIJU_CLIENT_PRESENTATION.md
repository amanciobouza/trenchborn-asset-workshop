# Kaiju client presentation

The shared runtime supports the five evolution stage numbers. The three existing portable installers ship the same runtime: Primal Beast 1.3.1, Storm Hunter 1.1.1 and Rift Stalker 1.1.1. Stages 4–5 still have no standalone installer in this workshop.

## Responsibility split

| Server | Each client |
| --- | --- |
| Builds static skeleton, rest joints and collision geometry once | Computes the existing procedural poses |
| Validates attack requests, cooldowns, targets, hits and death | Writes `Motor6D.Transform` after Animator in PreSimulation |
| Authorizes jump impulses; locks accepted specials through recovery | Runs native owner jump motor; renders jump pose without changing controls |
| Publishes state transitions with GetServerTimeNow timestamps | Samples attacks at the shared time, including when joining late |
| Owns building health, reservations, lift and destruction | Renders local Kaiju sounds, mouth beam, charge, sparks, veins and defeat flicker |

The server no longer writes every joint's C0 each frame. C0/C1 remain immutable after construction. Presentation states are published only when they change; moving focus aim is capped at 10 Hz and small changes are suppressed. Native root/humanoid movement replication remains. This reduces animation replication; it does not remove character physics, initial model streaming or game-owned building replication.

The rig's `PoseOwnershipRevision` is `ClientTransform_StateSync_01`. The previous JumpMotor identity-Transform guard has been removed. Do not keep old package modules or run a separate script that resets these transforms.

## Installation and streaming

Replace each complete package folder in ReplicatedStorage while Play is stopped, then restart Play. `InstallInput=false` and `EnableRemotes=false` still install the presentation observer and authorized jump runtime. Input bindings remain optional.

One `TrenchbornKaijuPresentation` ScreenGui hosts the observer per player. It persists across respawns and also exists for spectators who never equip a Kaiju. Each tagged model points to its own renderer module, so the portable packages can coexist. Unequip removes the model's renderer and connections; the shared observer remains available for other players.

The model uses Atomic streaming. The observer binds on tag arrival, restores current state, and releases its renderer on removal. It waits for movement/humanoid references before attaching an equipped character.

The local character updates at 30 Hz. Other Kaijus update at 30 Hz within 100 scale-adjusted studs, 15 Hz within 250 and 5 Hz farther away. Distant footsteps/dust and optional area bursts are suppressed. Timed attacks continue to use server time at every quality level. The camera is only read to estimate distance; no camera settings or controls change.

## Combat adapter migration

The existing CombatFactory signature and attack API remain. Damage, cooldowns and finisher reservations stay on the server. The third-hit finisher deadline remains in the existing server `os.clock()` domain for adapter compatibility; presentation start times use GetServerTimeNow.

**Server limb Parts now stay in their rest pose.** Adapters that read `Articulation.LeftHand.Position` or `RightHand.Position` must use the combat pose query instead. The workshop adapter has been updated, including its per-frame building lift:

```lua
-- After installation, from trusted server gameplay code:
local handFrame = api.GetCombatFrame("LeftHand")

-- Inside an adapter closure, once the rig has attached:
local provider = require(model.KaijuPoseProvider.Value)
local handFrame = provider.GetCombatFrame(model, "LeftHand")
```

This computes a server-authoritative attack frame without moving or replicating joints. It is the gameplay pose, not a pixel-exact copy of the client's smoothed idle/locomotion pose. The server computes the focus mouth origin for damage; the visible beam stays attached to the animated palate on each client.

An accepted special remains locked despite movement input, residual velocity, transient FloorMaterial=Air and nonlethal damage. Death/uninstall still stop it. Adapters must not reject an already-authorized Focus/Area solely because FloorMaterial briefly becomes Air. The workshop adapter allows that case while SpecialAttackLocked is set.

Building destruction effects remain owned by the target game. The workshop's dorsal pressure spheres and ground debris now render locally at the discharge marker. An external adapter can opt into those shared visuals by setting `model:SetAttribute("KaijuAreaVisualRadius", radiusInWorldStuds)` and removing its duplicate server burst. Without that attribute, its existing game-specific explosion implementation stays responsible for the burst.

## Validation and performance review

`python tools/test-kaiju-replication.py` runs syntax and mocked API/lifecycle checks using liblua5.4. It exercises all five stage numbers, no idle snapshot spam, immutable C0, moving-to-special locks, nonlethal hits, focus tick counts, area impact count, combo/finisher, jumps, death, late death state and cleanup. The translation-only mock does not validate actual pose geometry, engine networking or rendering.

The three Python package builders verify embedded sources and artifact hashes. Roblox Studio playtests and performance measurements remain pending; no frame-rate or bandwidth improvement is claimed as measured.

Compare the previous and new builds in a two-client session, including a spectator and InstallInput=false. Check streaming out/in during charge, shared attack timing, mouth source, tearing grip, death flicker, respawn and uninstall. On the weaker PC, compare MicroProfiler frame spikes, server script time, network receive and initial model load separately. Rig replication was a candidate cause of the reported hitching, not a confirmed diagnosis.

## Partial replication startup fix

The observer now waits for every required bone, rest-frame attribute, joint endpoint, movement-root connection and visual part before attaching. Receiving the tag or Articulation folder alone is insufficient. It continues waiting after 30 seconds, with a throttled diagnostic naming the missing dependency, until the rig arrives or is removed. This prevents the reported missing LeftThigh startup error without starting a partially initialized renderer. Replace the complete package, including KaijuSkeleton and KaijuPresentationClient. Mocked delayed-bone, delayed-attribute and delayed-joint-reference regressions pass for all five stage numbers; target-project visual verification remains pending, including the reported model offset.
