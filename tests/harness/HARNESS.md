# HAL Test Harness

Semi-automated smoke testing for the NR6-HAL v1.0 refactor. Spawns a canned
scenario around the player, runs all 5 BEHAV tests sequentially, and prints
an aggregate pass/fail report — all from a single debug-console command.

## Contents

| File | Purpose |
|------|---------|
| `setup-scenario.sqf` | Spawns 3 friendly infantry + 1 mortar team + 2 enemy squads around the player and registers the friendlies with HAL's HQ. |
| `run-all.sqf` | Runs `tests/test_BEHAV_01..05.sqf` in sequence and aggregates PASS/FAIL counts. |
| `inject-and-run.sqf` | One-shot: setup + 60s settle + run-all. The "just push the button" script. |
| `mission.VR/` | Minimal text-format VR map mission (player + HAL Core + HAL Include module). Launches with the harness auto-running after 30s. |

## Option A: Paste into your existing mission (fastest)

If you already have a HAL-enabled mission loaded, you can skip the mission
setup entirely. Arma loads harness scripts from the mission folder's path.

1. Copy `tests/` (the whole folder from the repo root) into your mission
   folder so the relative paths `tests\harness\*.sqf` and
   `tests\test_BEHAV_*.sqf` resolve from inside the mission.

2. Launch your mission with NR6-HAL loaded.

3. Open the debug console (`Esc` → Debug Console).

4. Paste **one** of these:

   ```sqf
   // One-shot: setup scenario + wait + run all 5 tests. Total ~5 min.
   0 = [] execVM "tests\harness\inject-and-run.sqf";
   ```

   ```sqf
   // Just set up the test scenario (don't run tests):
   0 = [] execVM "tests\harness\setup-scenario.sqf";
   ```

   ```sqf
   // Just run the 5 tests (assumes scenario is already set up):
   0 = [] execVM "tests\harness\run-all.sqf";
   ```

5. Watch `systemChat` for progress. Final report is printed to chat AND
   shown as a `hint` box so you can't miss it.

Expected runtime:
- `setup-scenario.sqf`: ~5 seconds.
- `run-all.sqf`: ~4-5 minutes (dominated by BEHAV-04's 90s artillery wait).
- `inject-and-run.sqf`: ~5-6 minutes total.

## Option B: Use the bundled VR test mission

The harness includes a minimal mission for the VR (digital sandbox) map
that auto-runs the tests 30 seconds after mission start. No debug console
needed.

### Setup (one-time)

1. Copy the whole contents of `tests/harness/mission.VR/` and the harness
   scripts to your Arma 3 missions folder:

   ```
   %USERPROFILE%\Documents\Arma 3\missions\mission.VR\
     mission.sqm
     description.ext
     init.sqf
     harness\
       setup-scenario.sqf
       run-all.sqf
       inject-and-run.sqf
     tests\
       test_BEHAV_01_init.sqf
       test_BEHAV_02_groups.sqf
       test_BEHAV_03_scan.sqf
       test_BEHAV_04_arty.sqf
       test_BEHAV_05_chatter.sqf
   ```

   (On Windows you can batch-copy with `robocopy tests tests-copy /e`
   against the repo root and then move the relevant folders.)

2. Launch Arma 3 with NR6-HAL and CBA_A3 enabled.

3. From the main menu: **SINGLEPLAYER → Scenarios** or **Editor → Open**
   → select "HAL Test Harness" / VR map. Click **Play**.

4. Wait ~30 seconds after spawn. The auto-harness will print `[HARNESS]`
   progress lines to systemChat and eventually show a `hint` box with the
   final pass/fail summary.

### What the bundled mission contains

The `mission.sqm` is deliberately minimal:
- One player unit (BLUFOR rifleman) at roughly `[5000, 5000, 0.5]` on VR.
- One `hal_missionmodules_Core_Module` placed 5 m away.
- One `hal_missionmodules_Leader_Include_Module` placed 8 m away.

No pre-placed subordinate groups or enemies — `setup-scenario.sqf` spawns
those at runtime from the init.sqf hook.

### Caveat: text-format mission.sqm

This SQM is written in non-binarized text form. Arma 3 accepts both binary
and text SQMs, but **if Eden saves this mission, it may rewrite the file in
binary form** and diffs become unreadable. If the mission fails to load or
behaves oddly, the safest recovery is to build the equivalent mission
yourself in Eden in ~2 minutes:

1. Open Eden editor, pick VR map.
2. Place a player unit (BLUFOR → Men → Rifleman).
3. Place HAL Core module (Systems → Modules → HAL - Modules → HAL Core).
4. Place HAL Include module (Systems → Modules → HAL - Modules → HAL Include).
5. Save as "HAL Test Harness".
6. Copy the `harness/` and `tests/` folders into the saved mission folder.
7. Paste the contents of `init.sqf` into an **Init Code** on a Game Logic,
   OR run `inject-and-run.sqf` from the debug console manually.

## What the tests actually verify

Same as the base BEHAV smoke tests — this is structure/machinery coverage,
not gameplay quality. See `tests/README.md` for the per-test assertion list.

Specifically NOT covered by the harness:
- AI tactical decision quality (stochastic — can't be asserted)
- Editor module UX (CBA settings menu, module arguments)
- Multi-HQ routing (tests use one HQ slot)
- Compat addon aliasing (legacy missions — test separately)
- Radio chatter audio playback

## Troubleshooting

**"no HAL HQ found after 60s"** — The HAL Core module isn't placed or isn't
firing its postInit. Check the mission has the module, and that
`nr6_hal` mod + `cba_a3` are loaded (not just present).

**"Setup did not complete"** — Check the preceding systemChat lines. Most
likely cause: trying to run on a client in multiplayer. The harness is
server-side; preview in SP or run from the host.

**Tests can't find scripts** — The relative path `tests\test_BEHAV_*.sqf`
resolves from the mission folder, not the mod PBO. Confirm the `tests/`
folder is present alongside `mission.sqm`.

**False failures on BEHAV-04 (artillery)** — The artillery test relies on
HAL dispatching a fire mission. On VR map with nothing to shoot at, the
`batteryBusy` variable may never be touched. `setup-scenario.sqf` spawns
enemies specifically to avoid this, but if the enemies are killed before
the 90s window elapses, the fire mission may never trigger. Rerun.
