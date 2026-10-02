# Stage 4 — Phase 6 gameplay review

Quality Gate B: approved by user. Dressing: approved by user. Quality Gate C: pending. No final Stage 4 installer is released. A [Phase 6 integration test package](KAIJU_STAGE_4_TEST_PACKAGE.md) is now available.

| Check | Evidence / status |
| --- | --- |
| Finisher below the jaw, building held at chest | User confirmed |
| Turn and walk away from hip-high tower | User confirmed |
| Light hit and return to idle | Automated controller check passed; user confirmed in Studio |
| Heavy hit, temporary attack restriction and recovery | Automated controller check passed; user confirmed in Studio |
| Healing does not trigger hit reaction | Automated controller check passed |
| Defeat cancels special attack and rejects further combat | Automated controller check passed; user confirmed in Studio |
| Respawn jump motor | User confirmed respawn/jump; simulated replacement also verifies old/new impulse isolation |
| Unequip / cleanup | Automated traversal cleanup passed for Stages 1–4 at scales 0.5, 1 and 2; Studio check pending |
| Buildings, slopes, multiplayer | Full matrix still pending; only hip-high tower escape is user-confirmed |
| Stage 1–3 shared traversal | Automated checks passed; user Studio tests pending |

## Confirmed Studio check: reaction and respawn

After pulling, restart Play with Stage 4 equipped. Use the existing Reaction test controls:

1. Hit: visible feedback, then a clean return to the normal pose.
2. Heavy Hit: a stronger reaction with armor moving with its limb, followed by normal control.
3. Start Focus or Area, then Defeat: the attack ends and the model falls into its defeat pose.
4. After respawn: Stage 4 equips once; movement and jumping work without doubled effects or impulses from the old character.

The reaction controls are Studio-only and validate the requesting owner. Heal is available only while alive; it does not revive a defeated character.

## Automated scope

Run `python tools/test-kaiju-replication.py` and `python tools/test-stage4-traversal.py`. Tests execute Lua with mocked Roblox services. They validate state, events and cleanup, not actual physics, visible armor intersections, respawn timing or multiplayer performance. No Studio test has been inferred from an acknowledgement or postponed test.
