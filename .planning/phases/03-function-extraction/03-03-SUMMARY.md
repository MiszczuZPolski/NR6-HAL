---
phase: "03"
plan: "03"
subsystem: "hal_hac / hal_boss / hal_data"
tags: ["extraction", "decomposition", "statusQuo", "BFT", "RHQ"]
dependency_graph:
  requires: ["03-01", "03-02"]
  provides: ["hal_hac/statusQuo", "hal_boss/FBFTLOOP", "hal_boss/EBFT", "hal_boss/SecTasks", "hal_data/presentRHQ"]
  affects: ["addons/core/fnc_HQSitRep", "addons/core/fnc_init", "nr6_hal/LF/LF.sqf"]
tech_stack:
  added: []
  patterns: ["D-03 decomposition (sub-functions < 250 lines)", "proposal-a explicit params", "setMarker*Local network optimization"]
key_files:
  created:
    - addons/hal_hac/functions/fnc_statusQuo.sqf
    - addons/hal_hac/functions/fnc_statusQuo_init.sqf
    - addons/hal_hac/functions/fnc_statusQuo_scanFriends.sqf
    - addons/hal_hac/functions/fnc_statusQuo_classifyFriends.sqf
    - addons/hal_hac/functions/fnc_statusQuo_classifyEnemies.sqf
    - addons/hal_hac/functions/fnc_statusQuo_artyPublish.sqf
    - addons/hal_hac/functions/fnc_statusQuo_morale.sqf
    - addons/hal_hac/functions/fnc_statusQuo_doctrine.sqf
    - addons/hal_hac/functions/fnc_statusQuo_objective.sqf
    - addons/hal_hac/functions/fnc_statusQuo_attackDispatch.sqf
    - addons/hal_hac/functions/fnc_statusQuo_hqReloc.sqf
    - addons/hal_hac/functions/fnc_LF_Loop.sqf
    - addons/hal_boss/functions/fnc_FBFTLOOP.sqf
    - addons/hal_boss/functions/fnc_EBFT.sqf
    - addons/hal_boss/functions/fnc_SecTasks.sqf
    - addons/hal_data/functions/fnc_presentRHQ.sqf
    - addons/hal_data/functions/fnc_presentRHQLoop.sqf
  modified:
    - addons/hal_hac/XEH_PREP.hpp
    - addons/hal_boss/XEH_PREP.hpp
    - addons/hal_data/XEH_PREP.hpp
    - addons/common/XEH_PREP.hpp
    - addons/core/functions/fnc_HQSitRep.sqf
    - addons/core/functions/fnc_init.sqf
    - nr6_hal/LF/LF.sqf
  deleted:
    - nr6_hal/HAC_fnc2.sqf
    - nr6_hal/RHQLibrary.sqf
decisions:
  - "D-03 applied: S3 split into classifyFriends + classifyEnemies (combined block was ~385 lines)"
  - "D-07 applied: RYD_LF_Loop reclassified active (caller found at nr6_hal/LF/LF.sqf:6), extracted not deleted"
  - "proposal-a: explicit params on each sub-function, results returned as arrays destructured with params"
  - "setMarker*Local used for intermediate BFT marker updates (L-S24 fix + genuine network optimization)"
  - "fnc_rhqCheck registered in common XEH_PREP.hpp (was missing, caused L-S29)"
metrics:
  duration_minutes: 120
  completed_date: "2026-04-10"
  tasks_completed: 6
  files_changed: 26
---

# Phase 03 Plan 03: HAC_fnc2.sqf Extraction Summary

**One-liner:** Decomposed 1779-line RYD_StatusQuo into 10 sub-functions + trunk and extracted all active HAC_fnc2.sqf functions to hal_hac/hal_boss/hal_data with full PREP registration and zero build warnings.

## What Was Built

The 3389-line `nr6_hal/HAC_fnc2.sqf` and 1739-line `nr6_hal/RHQLibrary.sqf` have been fully migrated:

### Decomposition Log (RYD_StatusQuo — D-03/FUNC-08)

| Sub-function | Role | Lines |
|---|---|---|
| `fnc_statusQuo_init` (S1) | Cycle gate, on-demand reset spawn, state var reset | ~40 |
| `fnc_statusQuo_scanFriends` (S2) | allGroups scan, subordination sync, radio channel, known-enemy tracking | ~200 |
| `fnc_statusQuo_classifyFriends` (S3a) | Classify friendlies into typed unit/group arrays | ~180 |
| `fnc_statusQuo_classifyEnemies` (S3b) | Classify known-enemy units into typed arrays | ~100 |
| `fnc_statusQuo_artyPublish` (S4) | Publish ArtyFriendsA-H, ArtyArtA-H via publicVariable | ~60 |
| `fnc_statusQuo_morale` (S5) | Loss tracking, weighted morale delta, debug output | ~70 |
| `fnc_statusQuo_doctrine` (S6) | Panic/flee resolution, personality roll, arty prep dispatch | ~140 |
| `fnc_statusQuo_objective` (S7) | SimpleMode taken-objective tracking, BIS respawn point management | ~80 |
| `fnc_statusQuo_attackDispatch` (S8) | Attack/defend dispatch, SF attack, delay computation | ~200 |
| `fnc_statusQuo_hqReloc` (S9) | HQ self-relocation logic | ~60 |
| `fnc_statusQuo` (trunk) | Orchestrator — calls S1-S9, per-cycle wait loop | 227 |

Trunk is 227 lines — satisfies < 250 requirement without waiver.

### Other Extracted Functions

| Old name | New location | Target addon |
|---|---|---|
| `HAL_FBFTLOOP` | `fnc_FBFTLOOP.sqf` | hal_boss |
| `HAL_EBFT` | `fnc_EBFT.sqf` | hal_boss |
| `HAL_SecTasks` | `fnc_SecTasks.sqf` | hal_boss |
| `RYD_PresentRHQ` | `fnc_presentRHQ.sqf` | hal_data |
| `RYD_PresentRHQLoop` | `fnc_presentRHQLoop.sqf` | hal_data |
| `RYD_LF_Loop` | `fnc_LF_Loop.sqf` | hal_hac |

### Call Site Updates

| File | Old call | New call |
|---|---|---|
| `fnc_init.sqf:109` | `[] call RYD_RHQCheck` | `[] call EFUNC(common,rhqCheck)` |
| `fnc_init.sqf:189` | `[[_gp], HAL_FBFTLOOP] call RYD_Spawn` | `[[_gp], EFUNC(hal_boss,FBFTLOOP)] call EFUNC(common,spawn)` |
| `fnc_init.sqf:190` | `[[_gp], HAL_SecTasks] call RYD_Spawn` | `[[_gp], EFUNC(hal_boss,SecTasks)] call EFUNC(common,spawn)` |
| `fnc_HQSitRep.sqf:113` | `[] call RYD_PresentRHQ` | `[] call EFUNC(hal_data,presentRHQ)` |
| `fnc_HQSitRep.sqf:686` | `call RYD_StatusQuo` | `[_HQ, _cycleC, _lastReset, [], _civF] call EFUNC(hal_hac,statusQuo)` |
| `nr6_hal/LF/LF.sqf:6` | `_this spawn RYD_LF_Loop` | `_this spawn hal_hac_fnc_LF_Loop` |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Missing PREP registration for fnc_rhqCheck**
- **Found during:** Task 5 (hemtt build gate)
- **Issue:** `EFUNC(common,rhqCheck)` produced L-S29 undefined-function warning — `rhqCheck` was never added to `addons/common/XEH_PREP.hpp`
- **Fix:** Added `PREP(rhqCheck);` in alphabetical order between `reqTransportActions` and `resetAI`
- **Files modified:** `addons/common/XEH_PREP.hpp`
- **Commit:** 3dabd2c

**2. [Rule 1 - Bug] L-S24 global marker update warnings in BFT loops**
- **Found during:** Task 5 (hemtt build gate)
- **Issue:** FBFTLOOP, EBFT, and statusQuo_doctrine used `setMarkerType/Color/Size` (global) before final `setMarkerPos`. HEMTT L-S24 fires on intermediate global updates.
- **Fix:** Changed intermediate calls to `setMarkerTypeLocal`, `setMarkerColorLocal`, `setMarkerSizeLocal`. Final `setMarkerPos` remains global (correctly broadcasts position to all clients). This is also a genuine network optimization.
- **Files modified:** `fnc_FBFTLOOP.sqf`, `fnc_EBFT.sqf`, `fnc_statusQuo_doctrine.sqf`
- **Commit:** 3dabd2c

**3. [Rule 2 - Missing call site] fnc_HQSitRep.sqf call sites not in original plan scope**
- **Found during:** Task 5 (build gate + caller analysis)
- **Issue:** `fnc_HQSitRep.sqf` still called `RYD_PresentRHQ` (line 113) and `RYD_StatusQuo` (line 686) — without updating these the extracted functions would never be invoked
- **Fix:** Updated both call sites to `EFUNC` forms. StatusQuo call now passes explicit params `[_HQ, _cycleC, _lastReset, [], _civF]`
- **Files modified:** `addons/core/functions/fnc_HQSitRep.sqf`
- **Commit:** 3dabd2c

**4. [D-07 Reclassification] RYD_LF_Loop: "dead?" resolved as active**
- **Pre-decided in checkpoint:** verified active caller at `nr6_hal/LF/LF.sqf:6` (`_this spawn RYD_LF_Loop`)
- **Action:** Extracted to `addons/hal_hac/functions/fnc_LF_Loop.sqf`, updated LF.sqf to `_this spawn hal_hac_fnc_LF_Loop`

**5. [D-03 Split] S3 split into classifyFriends + classifyEnemies**
- **Pre-decided in checkpoint:** combined block was ~385 lines, over the 250-line sub-function limit
- **Action:** Created two separate files, both called sequentially from trunk

## Known Stubs

None. All extracted functions have their logic wired. The following globals remain as bare references (Phase 4 scope — not stubs, not this plan's responsibility):

- `HAL_Rev`, `HAL_SuppMed`, `HAL_SuppFuel`, `HAL_SuppRep`, `HAL_SuppAmmo`, `HAL_SFIdleOrd`, `HAL_Reloc`, `HAL_LPos`, `Desperado`, `HAL_Garrison` — called inside the `statusQuo` per-cycle wait loop timer blocks
- `HAL_HQOrders`, `HAL_HQOrdersDef` — referenced in `fnc_statusQuo_attackDispatch.sqf`
- `HAL_LHQ` — referenced in `fnc_HQSitRep.sqf` line 36

## Threat Flags

None. No new network endpoints, auth paths, or trust boundary changes introduced.

## Build Gate Result

```
hemtt build: zero errors, zero L-S*/L-C* warnings
Commit: 3dabd2c
Files changed: 26 (17 created, 7 modified, 2 deleted)
```

## Self-Check: PASSED

- `addons/hal_hac/functions/fnc_statusQuo.sqf` — FOUND
- `addons/hal_boss/functions/fnc_FBFTLOOP.sqf` — FOUND
- `addons/hal_data/functions/fnc_presentRHQ.sqf` — FOUND
- `addons/hal_hac/XEH_PREP.hpp` (13 PREP entries) — FOUND
- `addons/hal_boss/XEH_PREP.hpp` (3 PREP entries) — FOUND
- `addons/hal_data/XEH_PREP.hpp` (3 PREP entries) — FOUND
- `nr6_hal/HAC_fnc2.sqf` — DELETED (confirmed)
- `nr6_hal/RHQLibrary.sqf` — DELETED (confirmed)
- Commit `3dabd2c` — FOUND
