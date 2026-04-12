# HAL Behavior Verification Tests

Smoke tests for **BEHAV-01 through BEHAV-05** (Phase 5 plan 05-08, decision D-04).

These scripts verify that the refactored HAL machinery produces the expected
runtime state inside Arma 3. They are **observational** — they check that
variables are set, loops have run, and functions are compiled. They do **not**
assert specific tactical decisions, because HAL's AI is stochastic.

The `tests/` directory lives at the repository root and is **not** packed into
any PBO. It is excluded from the HEMTT build (HEMTT only compiles `addons/*`).

---

## Prerequisites

1. NR6-HAL mod loaded in Arma 3 (with CBA_A3 dependency).
2. A test mission with at least:
   - One **HAL Core** module placed and synced to a group leader.
   - One **HAL Include** module with synced subordinate AI groups.
   - For BEHAV-03: hostile units within ~1000 m of the friendly groups.
   - For BEHAV-04: at least one artillery-capable group (mortar / howitzer)
     synced via the Include module, plus enemies in range.

## Running the tests

1. Launch the mission via the editor (singleplayer or multiplayer preview).
2. Wait until mission start (HAL needs `hal_core_postInit` to fire).
3. Open the debug console (`Esc` -> Debug Console).
4. Paste **one** of the following lines and press *Local Exec*:

   ```sqf
   0 = [] execVM "tests\test_BEHAV_01_init.sqf";
   0 = [] execVM "tests\test_BEHAV_02_groups.sqf";
   0 = [] execVM "tests\test_BEHAV_03_scan.sqf";
   0 = [] execVM "tests\test_BEHAV_04_arty.sqf";
   0 = [] execVM "tests\test_BEHAV_05_chatter.sqf";
   ```

5. Watch the on-screen `systemChat` log. Each test prints:
   - A `=== <test name> ===` banner.
   - One `[PASS]` or `[FAIL]` line per assertion.
   - A final summary `=== <test name>: X/Y passed, Z failed ===`.

> The mission must have access to the `tests/` directory. The simplest way is
> to copy the `tests/` folder into the mission folder so the relative path
> `tests\test_BEHAV_*.sqf` resolves. Alternatively, paste the script body
> directly into the debug console.

## What each test verifies

| Test     | Wait | Verifies                                                       |
|----------|------|----------------------------------------------------------------|
| BEHAV-01 | 20 s | `hal_core_allHQ` populated; codeSign + 6 personality traits + `personality` string set on HQ; `hal_core_allLeaders` non-empty |
| BEHAV-02 | 30 s | HQ `friends` list non-empty; subordinate groups have waypoints; `lastFriends` snapshot exists; side match |
| BEHAV-03 | 60 s | `hal_core_fnc_EnemyScan` compiled; `eS` flag set on HQ; at least one enemy group tagged with `markerES`; `cyclecount` advanced |
| BEHAV-04 | 90 s | `hal_common_fnc_artyMission` compiled; artillery-capable group present in friends; `batteryBusy` variable touched; HQ `fineness` initialised |
| BEHAV-05 | 30 s | `hal_common_fnc_AIChatter` compiled; `aIChatDensity` setting in valid range; `hQChat` boolean set; at least one HQ for binding |

## Limitations

- **Tests verify machinery, not outcomes.** They check that the refactored
  call sites populate the same observable variables as the legacy `nr6_hal/`
  loader. They cannot assert that the AI made the *same* tactical choice as
  before — that is inherently non-deterministic.
- **Timing-dependent.** Wait values are conservative for an idle dedicated
  server. On a stressed machine you may need to extend the `sleep` calls in
  the script (search for `Waiting Ns`).
- **BEHAV-04 is the loosest test.** Whether a fire mission actually runs
  depends on enemy presence, ROE, ammo state and `fineness` rolls. The test
  passes if the artillery wiring is in place and the battery exists.
- **BEHAV-05 cannot capture sideChat directly.** It validates the chatter
  function is compiled and the gating settings are populated; visual
  confirmation in the chat HUD is the manual verification step.

## Acceptance criteria

A test PASSES the BEHAV requirement if all assertions print `[PASS]`. A FAIL
indicates that the refactored machinery is missing a variable or function
that the legacy `nr6_hal/` build provided. Investigate by:

1. Checking the failing variable name in `addons/core/functions/` or
   `addons/common/functions/`.
2. Confirming the relevant `XEH_postInit.sqf` ran (`diag_log` entries).
3. Comparing against the pre-refactor baseline behaviour documented in
   `.planning/phases/05-settings-localization-compat-cleanup/05-RESEARCH.md`
   Block 6 (Observable States).

## Files

- `test_BEHAV_01_init.sqf` — HQ initialisation.
- `test_BEHAV_02_groups.sqf` — Group management & friends list.
- `test_BEHAV_03_scan.sqf` — Enemy scan loop.
- `test_BEHAV_04_arty.sqf` — Artillery / CFF wiring.
- `test_BEHAV_05_chatter.sqf` — AI chatter machinery.
