---
phase: 05-settings-localization-compat-cleanup
plan: 08
subsystem: testing
tags: [sqf, arma3, smoke-tests, behavior-verification, hal, cba]

requires:
  - phase: 05-settings-localization-compat-cleanup
    provides: refactored HAL machinery (addons/core, addons/common, compat addon, CBA settings)
provides:
  - 5 SQF smoke tests covering BEHAV-01..05
  - tests/ directory at repo root (not packed in PBOs)
  - tests/README.md with execution instructions, prerequisites, limitations
affects: [05-09-cleanup, post-v1.0 regression baselining]

tech-stack:
  added: [in-game SQF smoke testing harness]
  patterns:
    - "systemChat-driven PASS/FAIL output (no external test runner)"
    - "Mission-namespace globals (NR6HAL_TEST_*) for cross-block state inside scripts"
    - "Observational checks against hal_core_*/hal_common_* runtime variables"

key-files:
  created:
    - tests/test_BEHAV_01_init.sqf
    - tests/test_BEHAV_02_groups.sqf
    - tests/test_BEHAV_03_scan.sqf
    - tests/test_BEHAV_04_arty.sqf
    - tests/test_BEHAV_05_chatter.sqf
    - tests/README.md
  modified: []

key-decisions:
  - "Tests check observable runtime variables (allHQ, friends, eS, batteryBusy, aIChatDensity), not tactical outcomes"
  - "Pass/fail counters use mission-namespace globals (NR6HAL_TEST_pass/fail/total) because SQF code blocks cannot mutate caller-scope private vars"
  - "tests/ lives at repo root, outside addons/, so HEMTT does not pack or compile it"
  - "BEHAV-04 verifies artillery wiring (function compiled, battery present in friends, batteryBusy touched) rather than asserting a fire mission actually fired"
  - "BEHAV-05 verifies AIChatter is compiled and gating settings are populated; sideChat output is documented as a manual visual check"

patterns-established:
  - "Smoke test layout: banner -> wait -> private _check helper -> assertions -> summary line"
  - "Variable name convention in tests: use the fully namespaced runtime name (hal_<addon>_<var>) so tests are independent of CBA macro expansion"

requirements-completed: [BEHAV-01, BEHAV-02, BEHAV-03, BEHAV-04, BEHAV-05]

duration: 12min
completed: 2026-04-12
---

# Phase 5 Plan 08: BEHAV-01..05 SQF Smoke Tests Summary

**Five in-game SQF smoke tests verifying refactored HAL machinery (HQ init, group management, enemy scan, artillery wiring, AI chatter) via systemChat PASS/FAIL output.**

## Performance

- **Duration:** ~12 min
- **Started:** 2026-04-12T21:33:00Z
- **Completed:** 2026-04-12T21:45:54Z
- **Tasks:** 2
- **Files modified:** 6 (all created)

## Accomplishments

- Five self-contained SQF smoke tests, one per BEHAV-01..05 requirement, runnable via `execVM` in the Arma 3 debug console.
- Each test prints a banner, runs assertions with PASS/FAIL lines, and emits a final summary line.
- README documents prerequisites, exact debug-console commands, per-test wait times, what each test verifies, and the limitations (machinery vs. tactical outcomes, timing dependence).
- HEMTT build remains clean (0 errors, 0 warnings, 9 PBOs built) — `tests/` is outside `addons/` so it is not packed.

## Task Commits

1. **Task 1: BEHAV-01 + BEHAV-02 tests** — `dda9e15` (test)
2. **Task 2: BEHAV-03/04/05 + README** — `0f92a63` (test)

## Files Created

- `tests/test_BEHAV_01_init.sqf` — verifies `hal_core_allHQ`, codeSign, 6 personality traits, `personality` string, `hal_core_allLeaders`, and `cyclecount` after a 20s wait.
- `tests/test_BEHAV_02_groups.sqf` — verifies HQ `friends` list non-empty, subordinate waypoints assigned, `lastFriends` snapshot exists, side match (30s wait).
- `tests/test_BEHAV_03_scan.sqf` — verifies `hal_core_fnc_EnemyScan` compiled, `eS` flag set on HQ, at least one enemy group tagged with `markerES`, and `cyclecount > 0` (60s wait).
- `tests/test_BEHAV_04_arty.sqf` — verifies `hal_common_fnc_artyMission` compiled, an artillery-capable group is in HQ friends, `batteryBusy` touched, HQ `fineness` initialised (90s wait).
- `tests/test_BEHAV_05_chatter.sqf` — verifies `hal_common_fnc_AIChatter` compiled, `hal_core_aIChatDensity` set, `hal_core_hQChat` boolean set, allHQ available for chat binding, plus a fault-tolerant smoke spawn (30s wait).
- `tests/README.md` — prerequisites, debug-console commands, per-test descriptions table, limitations (stochastic AI, timing-dependent), acceptance criteria, troubleshooting pointers.

## Decisions Made

- **Mission-namespace counters over closure capture.** SQF code blocks executed via `call` cannot reliably mutate `private` vars in the caller scope. Used `NR6HAL_TEST_pass/fail/total` mission-namespace globals scoped per script run instead.
- **Literal variable names instead of macros.** Tests use the expanded names (`hal_core_allHQ`, `hal_common_batteryBusy`) so they are independent of CBA macro definitions and can be pasted directly into the debug console without `#include`.
- **Conservative wait times.** 20s/30s/60s/90s/30s rather than tighter bounds — README notes these may need to be lengthened on stressed servers.
- **BEHAV-04 verifies wiring, not firing.** A fire mission depends on enemy presence, ROE, ammo, and stochastic `fineness` rolls. Asserting an actual fire mission would be flaky; the test instead asserts the artillery group is recognised and its `batteryBusy` slot is reachable.
- **BEHAV-05 cannot capture sideChat.** The test verifies AIChatter is compiled and the gating settings are populated; visual confirmation in the chat HUD is documented as the manual verification step.

## Deviations from Plan

None — plan executed as written.

The plan provided sketch SQF in the task body. The delivered scripts implement the same intent with one structural change: counters use mission-namespace globals instead of `private` vars (necessary because SQF `call`-blocks do not capture private state from the caller scope). All requested files exist; all requested checks are present; all use `systemChat`.

## Issues Encountered

None. HEMTT build clean before and after.

## Build Verification

`hemtt build` after Task 2 commit:
- 0 errors
- 0 warnings (the L-S25/L-S27 entries in the log are `help` level, not warnings, and pre-exist this plan)
- 9 PBOs built successfully
- BBW1 still emitted (accepted environment notice — Arma 3 Tools not installed; documented in CLAUDE.md)

## Self-Check: PASSED

- `tests/test_BEHAV_01_init.sqf` — exists
- `tests/test_BEHAV_02_groups.sqf` — exists
- `tests/test_BEHAV_03_scan.sqf` — exists
- `tests/test_BEHAV_04_arty.sqf` — exists
- `tests/test_BEHAV_05_chatter.sqf` — exists
- `tests/README.md` — exists
- Commit `dda9e15` — present in `git log`
- Commit `0f92a63` — present in `git log`

## Next Phase Readiness

- BEHAV-01..05 requirements satisfied (verifiable in-game by running the five tests against a HAL test mission).
- Plan 05-09 (final cleanup) is the only remaining Phase 5 plan; no blockers identified.
- Tests can serve as a regression baseline for any post-v1.0 refactor work.

---
*Phase: 05-settings-localization-compat-cleanup*
*Completed: 2026-04-12*
