# Stage 4 — Phase 6 integration test package 0.1.1-test

This package enables target-game integration testing with approved Stage 4 geometry and dressing. It is not a Phase 7 final installer. Quality Gate C remains pending for slopes and multiplayer. Finisher, hip-high tower escape, reaction/defeat and respawn/jump were confirmed by the user in the workshop.

## Import

1. Stop Play and disable the existing workshop preview or other character equip script in this test place.
2. Insert `dist/KaijuStageFourTest.rbxmx` into ReplicatedStorage. The resulting folder is `TrenchbornKaijuStageFourTest`.
3. Copy `examples/KaijuStageFourTest.server.lua` into ServerScriptService for a complete Studio practice session. The example equips once after appearance loading and again on respawn.
4. Start Play. The example creates three houses and two taller targets sized from Stage 4 knee/torso height. Building traversal and the workshop combat adapter are active. Use F for combo, Space for jump, E for focus, R for area and Shift for running.
5. Respawning restores the practice range; leaving or removing the bootstrap cleans it up. The practice bootstrap runs only in Studio.

Do not mix scripts from older packages. The test package includes 17 scripts, including Stage 4 geometry/dressing, inherited geometry dependencies, shared presentation, traversal, server rig, input and owner jump motor. The package includes the workshop combat module. The example creates practice targets at runtime; no prebuilt map, workshop menus or camera overrides are included.

## Target-game integration

```lua
local package = game.ReplicatedStorage.TrenchbornKaijuStageFourTest
local Installer = require(package.KaijuStageFourTestInstaller)
local model, api = Installer.Install(character, {
    Scale = 1,
    InstallInput = false, -- The game supplies input; true adds sample bindings.
    EnableTraversal = true,
    CombatFactory = function(model, root, humanoid, rootHeight)
        return YourBuildingCombatService.Attach(model, root, humanoid, rootHeight)
    end,
})
-- Unequip before switching models:
api.Destroy()
-- Alternatively: Installer.Uninstall(character)
```

YourBuildingCombatService is a placeholder for the game's server adapter. The supplied example instead uses KaijuStageOneCombat for practice; its provisional damage and health values are not the game balance. The adapter supplies Handle, Cancel, PrepareFinisher, SelectFocusTarget, FocusAim and AreaImpact. EnableTraversal=true additionally requires TraversalTargets and StepImpact; see [building traversal contract](KAIJU_BUILDING_TRAVERSAL.md). Combat damage and resources remain game-owned. InstallInput=false does not remove presentation or the jump motor.

The equipped model retains the existing `Stage_4_Geometry_Review` name for compatibility with the workshop model. EvolutionStage=4 identifies the stage. PipelinePhase=6, TestOnly=true and TestPackageVersion=0.1.1-test explicitly identify its status; FinalInstallerVersion is absent.

## Build and tests

`python tools/build-kaiju-stage4-test.py` builds the XML model and SHA-256 manifest and verifies source round-trips and complete sibling dependencies. Alternatively use `rojo build kaiju-stage4-test.project.json -o KaijuStageFourTest.rbxm`.

`python tools/test-kaiju-replication.py` now exercises the test installer against stubbed geometry and runtime dependencies: dressing-before-rig order, traversal wiring, duplicate equip rejection, attribute gates, state restoration, repeated destroy, reinstall and rollback after dressing/adapter failure. `python tools/test-stage4-traversal.py` covers shared collision and footfall rules. These checks do not instantiate actual Roblox geometry or replace import, physics and visual tests in Studio.

## Remaining review

Verify import, scale, game adapter integration and unequip/respawn in the receiving game. Strong slopes and multiplayer are still open. This package does not mark those tests as passed or create final approval.
