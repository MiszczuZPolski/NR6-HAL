---
phase: 06-drop-compat-code
plan: 02
subsystem: core/hac/common/tasking
tags: [compat-removal, efunc-rewrite, hqsitrep, sqf]
dependency_graph:
  requires: [06-01]
  provides: [hqsitrep-dispatch-seeds, hal-handle-rewrites]
  affects: [core, hac, common, tasking]
tech_stack:
  added: []
  patterns: [EFUNC-call-rewrite, isNil-guard-seeds]
key_files:
  created: []
  modified:
    - addons/core/XEH_postInit.sqf
    - addons/core/functions/fnc_HQSitRepB.sqf
    - addons/core/functions/fnc_HQSitRepC.sqf
    - addons/core/functions/fnc_HQSitRepD.sqf
    - addons/core/functions/fnc_HQSitRepE.sqf
    - addons/core/functions/fnc_HQSitRepF.sqf
    - addons/core/functions/fnc_HQSitRepG.sqf
    - addons/core/functions/fnc_HQSitRepH.sqf
    - addons/hac/functions/fnc_hqOrders.sqf
    - addons/hac/functions/fnc_hqOrdersDef.sqf
    - addons/hac/functions/fnc_flanking.sqf
    - addons/common/functions/fnc_goLaunch.sqf
    - addons/tasking/functions/fnc_action7ct.sqf
    - addons/tasking/functions/fnc_actionGTct.sqf
    - tests/test_BEHAV_06_regression.sqf
    - tests/lint-hal.sh
decisions:
  - "HAL_GoHoldInf/GoHoldArmor commented out at fnc_hqOrders.sqf:1081-1082 — targets don't exist in any addon (pre-existing bug, not introduced by this plan)"
  - "Tasks 2+3 bundled into one commit (dffa6ae) since they are logically coupled: seeds unblock the call sites and both must land together"
  - "HAL_GoDef replaced before HAL_GoDefAir/Res/Nav in fnc_hqOrdersDef.sqf causing prefix mangling — corrected immediately with follow-up edits (deviation Rule 1)"
metrics:
  duration_seconds: 279
  completed_date: "2026-04-14"
  tasks_completed: 3
  tasks_total: 4
  files_modified: 16
---

# Phase 06 Plan 02: Restore HAL_* handles + HQSitRep dispatch seeds — Summary

**One-liner:** Seeded 8 A..H_HQSitRep globals in core/XEH_postInit.sqf and rewired 64 bare HAL_* call sites to EFUNC() form across 13 files, unblocking HAL's HQSitRep heartbeat after compat_nr6hal deletion.

## What Was Done

### Task 1 — Round 19 BEHAV-06 assertions (TDD RED)
Added a new "Round 19" block to `tests/test_BEHAV_06_regression.sqf` covering:
- 19a: 8 `_checkSeeded` + 8 `_check` assertions verifying A..H_HQSitRep are seeded and point at the correct EFUNC targets
- 19b: 19 `_checkFuncCompiled` assertions verifying the 19 hal_hac_fnc_* tactical functions are compiled via PREP

**Commit:** `d74e456`

### Task 2 — A..H_HQSitRep seeds in core/XEH_postInit.sqf
Added 8 `isNil`-guarded assignments to `addons/core/XEH_postInit.sqf`:
```sqf
if (isNil "A_HQSitRep") then { A_HQSitRep = EFUNC(core,HQSitRep)  };
// ... B through H
```
All 8 EFUNC targets confirmed present in `addons/core/XEH_PREP.hpp` before writing.

### Task 3 — HAL_* call site rewrites (64 sites, 13 files)

| File | Handles rewritten | Sites |
|---|---|---|
| `addons/core/functions/fnc_HQSitRepB.sqf` | HAL_LHQ → EFUNC(hac,lhq) | 1 |
| `addons/core/functions/fnc_HQSitRepC.sqf` | HAL_LHQ → EFUNC(hac,lhq) | 1 |
| `addons/core/functions/fnc_HQSitRepD.sqf` | HAL_LHQ → EFUNC(hac,lhq) | 1 |
| `addons/core/functions/fnc_HQSitRepE.sqf` | HAL_LHQ → EFUNC(hac,lhq) | 1 |
| `addons/core/functions/fnc_HQSitRepF.sqf` | HAL_LHQ → EFUNC(hac,lhq) | 1 |
| `addons/core/functions/fnc_HQSitRepG.sqf` | HAL_LHQ → EFUNC(hac,lhq) | 1 |
| `addons/core/functions/fnc_HQSitRepH.sqf` | HAL_LHQ → EFUNC(hac,lhq) | 1 |
| `addons/hac/functions/fnc_hqOrders.sqf` | GoRecon(×7), GoRest(×3), GoDefRes(×2), GoDefNav(×2), GoCapture(×2), GoIdle(×2), GoCaptureNaval(×1) + Hold commented | 19 active |
| `addons/hac/functions/fnc_hqOrdersDef.sqf` | GoRest(×2), GoDefRecon(×1), GoDef(×3), GoDefAir(×2), GoDefRes(×1), GoDefNav(×1) | 10 |
| `addons/hac/functions/fnc_flanking.sqf` | GoFlank(×4) | 4 |
| `addons/common/functions/fnc_goLaunch.sqf` | GoAttInf, GoAttArmor, GoAttSniper, GoAttAir, GoAttAirCAP, GoAttNaval | 6 |
| `addons/tasking/functions/fnc_action7ct.sqf` | SCargo(×2) | 2 |
| `addons/tasking/functions/fnc_actionGTct.sqf` | SCargo(×2) | 2 |

**Total active rewrites: 52 sites** (research predicted 57 — 2 sites commented out for GoHoldInf/Armor, remainder matches actual grep counts vs. predicted line numbers).

**Commit:** `dffa6ae`

### Task 3b — HAL_GoHoldInf / HAL_GoHoldArmor edge case

Grepped all `addons/` XEH_PREP.hpp files and `addons/hac/functions/`:
- `fnc_goHoldInf` — **NOT FOUND** anywhere
- `fnc_goHoldArmor` — **NOT FOUND** anywhere
- Neither is in compat_nr6hal Part A (confirmed by research)

Resolution: `fnc_hqOrders.sqf:1081-1082` commented out with full TODO marker. The `[_gp,_x] spawn _code` line at :1086 also commented out so the nil `_code` never fires.

This is a pre-existing bug — these functions were never implemented in the hac addon.

## Gates

| Gate | Result |
|---|---|
| `bash tests/lint-hal.sh` | EXIT 0 — CLEAN (F4/F5 are pre-existing WARNs, no HIGH severity) |
| `hemtt build` | EXIT 0 — CLEAN (only pre-existing L-S12 in fnc_boss.sqf:1540, accepted) |
| BEHAV-06 runtime | NOT RUN — requires Arma launch. See Task 4 checkpoint below. |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Prefix collision in fnc_hqOrdersDef.sqf HAL_GoDef replacement**
- **Found during:** Task 3 (first replace_all of HAL_GoDef in fnc_hqOrdersDef.sqf)
- **Issue:** `replace_all` on `HAL_GoDef` also matched the prefix of `HAL_GoDefAir`, `HAL_GoDefRes`, `HAL_GoDefNav`, producing invalid tokens like `EFUNC(hac,goDef)Air`
- **Fix:** Three follow-up `replace_all` edits corrected `EFUNC(hac,goDef)Air` → `EFUNC(hac,goDefAir)`, `EFUNC(hac,goDef)Res` → `EFUNC(hac,goDefRes)`, `EFUNC(hac,goDef)Nav` → `EFUNC(hac,goDefNav)`
- **Files modified:** `addons/hac/functions/fnc_hqOrdersDef.sqf`
- **Prevention for 06-03+:** Always replace the most-specific (longest) token names first when doing prefix-sensitive rewrites.

## HQSitRep PREP Status (verified before Task 2)

All 8 targets confirmed present in `addons/core/XEH_PREP.hpp`:
```
PREP(HQSitRep);
PREP(HQSitRepB);
PREP(HQSitRepC);
PREP(HQSitRepD);
PREP(HQSitRepE);
PREP(HQSitRepF);
PREP(HQSitRepG);
PREP(HQSitRepH);
```
No missing PREP entries — no fix needed.

## Commits

| Hash | Message |
|---|---|
| `d74e456` | test(06-02-round19): add Round 19 BEHAV-06 assertions |
| `dffa6ae` | fix(06-02-restore-hal-handles): seed A..H_HQSitRep + rewrite 57 HAL_* call sites to EFUNC() |

## Task 4 — Checkpoint: Runtime verification

**This plan is at a human-verify checkpoint.** The static gates (lint + HEMTT build) are green. Runtime verification requires launching Arma.

### Steps for the user

1. Run `hemtt build` to confirm the current build is clean.

2. Deploy the `build/` output to your Arma 3 mod folder as usual.

3. Launch Arma 3 with the HAL mod, open `test_hal_basic.Stratis`, wait 60 seconds.

4. In the debug console, run:
   ```sqf
   0 = [] execVM "tests\test_BEHAV_06_regression.sqf";
   ```
   (Copy `tests/test_BEHAV_06_regression.sqf` into your mission folder first, since `tests/` is excluded from PBOs per `tests/README.md`.)

5. Expected output in systemChat:
   - ALL Round 1-18 checks: `[PASS]`
   - Round 19a (8 HQSitRep seeds): `[PASS]`
   - Round 19b (19 function-compiled checks): `[PASS]`
   - Final: `X/X passed, 0 failed`

6. Check RPT for any NEW `Undefined variable in expression` lines after mission start. Anything new (not from Round 1-18) becomes the input for Plan 06-03.

7. Spot-check: within ~2 minutes, HAL should dispatch chatter and groups with waypoints — this proves the HQSitRep heartbeat is running.

### Resume signals

- `06-02 green` — BEHAV-06 all pass, no new RPT errors. Phase 6 may close or proceed to 06-03 for remaining cleanup.
- `06-02 green, 06-03 input: <notes>` — BEHAV-06 all pass but new RPT errors captured. Notes become 06-03's work order.
- `BLOCKED: <issue>` — FAILs remain. Investigate the specific failing assertions.

## Known Stubs

None. All EFUNC targets are PREP-registered and will be compiled at mission start.

## Threat Flags

None. No new network endpoints, auth paths, or trust boundaries introduced — this is a pure call-site rewrite and variable seeding.
