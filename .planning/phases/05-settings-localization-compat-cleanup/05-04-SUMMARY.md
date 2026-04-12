---
phase: 05-settings-localization-compat-cleanup
plan: 04
subsystem: extraction
tags: [extraction, compat-04, supply-scripts, squad-tasking, nr6_hal-deletion]
wave: 4
requires:
  - 05-03 (Extraction Wave 3 — 20 tactical scripts)
provides:
  - 8 supply/support scripts PREP'd in hal_hac (goAmmoSupp/goFuelSupp/goMedSupp/goRepSupp + suppAmmo/suppFuel/suppMed/suppRep)
  - fnc_squadTasking in hal_tasking — the squad action-menu registration main loop
  - COMPLETE removal of nr6_hal/ directory tree (375 files, 29200 lines)
  - COMPAT-04 closed
affects:
  - addons/hal_hac/functions/fnc_statusQuo.sqf (HAL_SuppMed/Fuel/Rep/Ammo resolved)
  - addons/hal_tasking/functions/fnc_action8ct-13ct.sqf (HAL_GoAmmoSupp/GoFuelSupp/GoMedSupp/GoRepSupp resolved)
  - addons/core/functions/fnc_init.sqf (execVM SquadTaskingNR6 replaced with EFUNC spawn, GVAR(path) removed)
tech-stack:
  added: []
  patterns:
    - "phase4-rename owner-override pinning pattern (reused from 05-02/05-03)"
    - "post-pass bulk rewrite of function-handle mis-rewrites — this wave hit a NEW variant where phase4-rename's filename-fallback owner inference produced EGVAR(fnc_<filename>.sqf, <symbol>) for function handles. Resolution: extend the 05-03 rewriter pattern to recognize and rewrite both fnc_goAmmoSupp.sqf and fnc_suppAmmo.sqf as inferred-owner filename buckets."
key-files:
  created:
    - addons/hal_hac/functions/fnc_goAmmoSupp.sqf
    - addons/hal_hac/functions/fnc_goFuelSupp.sqf
    - addons/hal_hac/functions/fnc_goMedSupp.sqf
    - addons/hal_hac/functions/fnc_goRepSupp.sqf
    - addons/hal_hac/functions/fnc_suppAmmo.sqf
    - addons/hal_hac/functions/fnc_suppFuel.sqf
    - addons/hal_hac/functions/fnc_suppMed.sqf
    - addons/hal_hac/functions/fnc_suppRep.sqf
    - addons/hal_tasking/functions/fnc_squadTasking.sqf
  modified:
    - addons/hal_hac/XEH_PREP.hpp
    - addons/hal_hac/functions/fnc_statusQuo.sqf
    - addons/hal_tasking/XEH_PREP.hpp
    - addons/hal_tasking/functions/fnc_action8ct.sqf
    - addons/hal_tasking/functions/fnc_action9ct.sqf
    - addons/hal_tasking/functions/fnc_action10ct.sqf
    - addons/hal_tasking/functions/fnc_action11ct.sqf
    - addons/hal_tasking/functions/fnc_action12ct.sqf
    - addons/hal_tasking/functions/fnc_action13ct.sqf
    - addons/core/functions/fnc_init.sqf
  deleted:
    - nr6_hal/ (entire tree, 375 files, 29200 lines)
decisions:
  - "phase4-rename's filename-fallback owner inference produces EGVAR(fnc_<filename>.sqf,<symbol>) when legacy RYD_* function handles lack a rename-map.json entry AND the file being processed happens to live at that filename. This is a new variant of the 05-03 function-handle issue and required extending the post-pass rewriter to recognize two inferred-filename buckets (fnc_goAmmoSupp.sqf and fnc_suppAmmo.sqf) across the 8 new files."
  - "Function-handle mapping: spawn/wait/WPadd/addTask/mark/AIChatter/orderPause -> EFUNC(common,*); closeEnemy -> EFUNC(common,closeEnemy); gPauseActive -> EGVAR(common,gPauseActive); aIC_OrdFinal/aIC_OrdEnd/aIC_SuppReq/aIC_SuppAss/aIC_SuppDen -> GVAR(*) since the new files are in hal_hac (owner). reqLogistics(_Delete)_Actions -> runtime remoteExec literal \"hal_common_fnc_reqLogistics(Delete)Actions\"."
  - "HAL_Requested per-unit setVariable key in fnc_goAmmoSupp.sqf preserved verbatim (same self-contained pattern as HAL_ReqTra* / HAL_Task*Added — writers and readers live in the same scope, rewriting the key string would be a behavior change)."
  - "HAL_Task*Added/HAL_TaskMenuAdded/HAL_PlayerUnit per-unit setVariable keys in fnc_squadTasking.sqf preserved verbatim for the same reason — all 65+ occurrences are paired writer/reader pairs within the main action-menu registration loop."
  - "Replaced `nul = [] execVM (GVAR(path) + \"SquadTaskingNR6.sqf\")` in fnc_init.sqf with `[[], EFUNC(hal_tasking,squadTasking)] call EFUNC(common,spawn)` — spawn preserves the async-infinite-loop semantics of the original while routing through the common addon's wrapped spawn for handle tracking."
  - "Removed GVAR(path) assignment from fnc_init.sqf line 99 — it was the last reader of the legacy NR6_HAL path and pointed to a directory about to be deleted. Mitigates T-05-08."
  - "Verified all 59 .sqf files previously physically present in nr6_hal/ had corresponding addons/*/functions/fnc_*.sqf equivalents before deletion (including lowercase-first-letter normalization for TimeM/DisOP -> timeDisOP, etc.). Mitigates T-05-09."
metrics:
  duration_minutes: 24
  tasks_completed: 2
  files_created: 9
  files_modified: 10
  files_deleted: 375
  completed: 2026-04-11
---

# Phase 5 Plan 04: Extraction Wave 4 (8 supply scripts + SquadTasking) + nr6_hal/ DELETION Summary

Completed the final extraction wave by PREP'ing the 8 supply/support behavior scripts and the SquadTaskingNR6 action-menu main loop into addons/, then deleted the entire nr6_hal/ directory tree. With this plan, **the legacy nr6_hal/ mod tree no longer exists** and the entire NR6-HAL runtime lives in addons/, closing COMPAT-04.

## Objective Achieved

- 8 supply behavior scripts PREP'd in hal_hac: goAmmoSupp/goFuelSupp/goMedSupp/goRepSupp (outbound transport behavior) + suppAmmo/suppFuel/suppMed/suppRep (dispatch/assignment logic).
- fnc_squadTasking PREP'd in hal_tasking (508 lines, infinite loop, action-menu and radio-task registration per player).
- fnc_init.sqf rewired: legacy `execVM "SquadTaskingNR6.sqf"` replaced with `[[], EFUNC(hal_tasking,squadTasking)] call EFUNC(common,spawn)`. GVAR(path) assignment removed (unused after rewire).
- fnc_statusQuo.sqf: 4 `HAL_Supp*` bare global call sites resolved to `FUNC(supp*)`.
- fnc_action8-13ct.sqf: 6 `HAL_Go*Supp` bare globals in spawn array-literals resolved to `EFUNC(hal_hac,go*Supp)`.
- **nr6_hal/ directory tree deleted in full** — 375 files (59 .sqf + 313 .ogg + 2 .cpp + 1 other).
- hemtt build: EXIT=0, 0 errors, 0 L-S29 undefined-function warnings.

## Commits

| # | Hash    | Subject |
|---|---------|---------|
| 1 | cb81c51 | feat(05-04): extract 8 supply scripts and rewire call sites |
| 2 | 58f77e9 | feat(05-04): extract SquadTaskingNR6 to hal_tasking and rewire fnc_init |
| 3 | 8d6f58e | feat(05-04): delete nr6_hal/ directory — extraction complete (COMPAT-04) |

## Verification Results

- `hemtt build`: EXIT=0, 9 PBOs built, 299 sqf files compiled.
- `L-S29` undefined-function warnings: **0** (all forward-refs resolved).
- L-S warning histogram after final commit: L-S25=32, L-S13=14, L-S18=12, L-S12=10, L-S03=4, L-S27=3, L-S24=3. Delta vs. 05-03 baseline: +2 L-S18 and +3 L-S12 from the 8 new supply scripts (inherited behavior-preserving patterns from nr6_hal/HAL/ source, preserved verbatim under the #1 no-behavior-change invariant).
- BBW1 accepted per CLAUDE.md environment notice.
- `test ! -d nr6_hal`: PASS (directory removed).
- `grep -rn "nr6_hal" addons/ --include='*.sqf' --include='*.hpp' --include='*.cpp'` returns 9 hits — all are `//` comments (TODOs, Originally-from attributions, or compat-addon inventory headers). Zero active code references.
- `grep -rn "\bcall HAL_\|\bspawn HAL_" addons/` returns only:
  - `HAL_fnc_getType` / `HAL_fnc_getSize` in fnc_EBFT/fnc_FBFTLOOP — pre-existing BIS A3 MARTA wrappers assigned in fnc_init.sqf, pre-existing pattern, out of scope.
  - Dead code in `//`-commented lines in fnc_flanking.sqf and fnc_hqOrders.sqf (HAL_GoFlank, HAL_GoRecon — commented-out diagnostic spawn examples, not live calls).
- `grep -rn "\bcall Boss\b\|\bcall Desperado\b" addons/` returns zero hits.
- `grep -c 'PREP(supp\|PREP(go.*Supp' addons/hal_hac/XEH_PREP.hpp` returns 8 (goAmmoSupp, goFuelSupp, goMedSupp, goRepSupp, suppAmmo, suppFuel, suppMed, suppRep all present).
- `grep -c 'PREP(squadTasking' addons/hal_tasking/XEH_PREP.hpp` returns 1.
- `find nr6_hal/ -name "*.sqf"` returns nothing (directory does not exist).

## Extraction Details

### Task 1a — 8 supply scripts (commit cb81c51)

| Source                      | Destination             | Lines |
|-----------------------------|-------------------------|-------|
| nr6_hal/HAL/GoAmmoSupp.sqf  | fnc_goAmmoSupp.sqf      | 607   |
| nr6_hal/HAL/GoFuelSupp.sqf  | fnc_goFuelSupp.sqf      | 237   |
| nr6_hal/HAL/GoMedSupp.sqf   | fnc_goMedSupp.sqf       | 226   |
| nr6_hal/HAL/GoRepSupp.sqf   | fnc_goRepSupp.sqf       | 228   |
| nr6_hal/HAL/SuppAmmo.sqf    | fnc_suppAmmo.sqf        | 321   |
| nr6_hal/HAL/SuppFuel.sqf    | fnc_suppFuel.sqf        | 274   |
| nr6_hal/HAL/SuppMed.sqf     | fnc_suppMed.sqf         | 302   |
| nr6_hal/HAL/SuppRep.sqf     | fnc_suppRep.sqf         | 265   |

Per-file steps (same procedure as 05-02/05-03):

1. Copy source with `#include "..\script_component.hpp"` header and `// Originally from nr6_hal/HAL/<name>.sqf` origin comment.
2. Register `PREP(goAmmoSupp);` etc. in addons/hal_hac/XEH_PREP.hpp.
3. Run phase4-rename per prefix with owner-override pins (RydHQ_, RydxHQ_, RYD_, RHQ_). Snapshots of fnc_AIChatter.sqf and fnc_desperation.sqf taken before each pass, reverted after to protect runtime-dispatch constructions.
4. Post-pass Python bulk rewrite (`.tmp/rewrite-05-04.py`, 122 replacements) to fix the 2 classes of mis-rewrite:
    - `EGVAR(fnc_goAmmoSupp.sqf, X)` / `QEGVAR(fnc_goAmmoSupp.sqf, X)` → correct macro form (94 replacements). phase4-rename fell back to filename inference when processing the 7 other supp*/goSupp* files, because function handles (RYD_Spawn, RYD_Wait etc.) aren't in rename-map.json and the tool doesn't recognize them as handles.
    - `EGVAR(fnc_suppAmmo.sqf, X)` / `QEGVAR(fnc_suppAmmo.sqf, X)` → same issue when processing the other 3 supp* files (28 replacements for closeEnemy + aIC_SuppReq/SuppAss/SuppDen).

Call-site rewrites (same commit):
- fnc_statusQuo.sqf: `call HAL_SuppMed` → `call FUNC(suppMed)` and 3 siblings.
- fnc_action8-13ct.sqf: `HAL_GoAmmoSupp` (array element passed to spawn) → `EFUNC(hal_hac,goAmmoSupp)` and 5 siblings.

### Task 1b — SquadTaskingNR6 (commit 58f77e9)

| Source                          | Destination                   | Lines |
|---------------------------------|-------------------------------|-------|
| nr6_hal/SquadTaskingNR6.sqf     | fnc_squadTasking.sqf          | 511   |

Same extraction procedure, but routed to hal_tasking addon:
- Header + origin comment added.
- PREP registered in hal_tasking/XEH_PREP.hpp.
- phase4-rename run on addons/hal_tasking/functions (all 4 prefixes), AIChatter/desperation revert applied.
- No post-pass bulk rewrite needed — squadTasking doesn't reference any function handles that phase4-rename would mis-infer. It uses `remoteExecCall` with literal string function names (already in `hal_tasking_fnc_*` form).

fnc_init.sqf rewires:
- `nul = [] execVM  (GVAR(path) + "SquadTaskingNR6.sqf");` → `[[], EFUNC(hal_tasking,squadTasking)] call EFUNC(common,spawn);`
- `GVAR(path) = "\NR6_HAL\";` → commented out (no readers remaining).

### Task 2 — nr6_hal/ deletion (commit 8d6f58e)

Pre-deletion verification:
- Loop every `.sqf` file under `nr6_hal/` and confirm a corresponding `addons/*/functions/fnc_*.sqf` exists (with lowercase-first-letter normalization, e.g., `TimeM/DisOP.sqf` → `fnc_timeDisOP.sqf`). All files accounted for.
- Grep `nr6_hal` / `NR6_HAL` in addons/ (sqf/hpp/cpp) — only comment references remain.
- Grep `GVAR(path)` in addons/ — only the (commented-out) assignment line in fnc_init.sqf.

Deletion: `git rm -r nr6_hal/` removed 375 files totaling 29,200 lines of legacy code and ~52 MB of .ogg assets. All .ogg sound assets were already copied to `addons/hal_data/Sound/` in Plan 05-01. CfgRadio from `nr6_hal/config.cpp` was already extracted to `addons/hal_data/CfgRadio.hpp` in Plan 05-01.

Final hemtt build gate: EXIT=0, 0 errors, 0 L-S29, same inherited warning set as post-Task 1b. **The codebase now builds without the nr6_hal/ mod tree.**

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] phase4-rename filename-fallback owner inference produced EGVAR(fnc_<filename>.sqf, X)**
- **Found during:** Task 1a (initial post-rename grep for residual raw names)
- **Issue:** 122 total occurrences across the 8 new files of the form `EGVAR(fnc_goAmmoSupp.sqf, spawn)`, `QEGVAR(fnc_suppAmmo.sqf, reqLogistics_Actions)` etc. phase4-rename, when it encounters a legacy RYD_* name that is NOT in rename-map.json AND does NOT match an owner-override, falls back to inferring owner from the filename of the file being processed. For function handles (RYD_Spawn, RYD_Wait, RYD_WPadd, RYD_CloseEnemy, etc.) which are not data variables, this produces nonsense macro calls.
- **Fix:** `.tmp/rewrite-05-04.py` — a Python post-pass that scans the 8 new files and rewrites both `EGVAR(fnc_goAmmoSupp.sqf, X)` and `EGVAR(fnc_suppAmmo.sqf, X)` (plus their QEGVAR siblings) to the correct canonical forms:
  - `EFUNC(common,spawn)`, `EFUNC(common,wait)`, `EFUNC(common,WPadd)`, `EFUNC(common,addTask)`, `EFUNC(common,mark)`, `EFUNC(common,AIChatter)`, `EFUNC(common,orderPause)`, `EFUNC(common,closeEnemy)`
  - `EGVAR(common,gPauseActive)` (data var)
  - `GVAR(aIC_OrdFinal)`, `GVAR(aIC_OrdEnd)`, `GVAR(aIC_SuppReq)`, `GVAR(aIC_SuppAss)`, `GVAR(aIC_SuppDen)` — hal_hac-local data vars (the new files live in hal_hac, so GVAR refers to hal_hac)
  - `"hal_common_fnc_reqLogisticsActions"` / `"hal_common_fnc_reqLogisticsDeleteActions"` — remoteExec runtime literal strings
- **Also fixes:** Bare `HAL_GoAmmoSupp`/`HAL_GoFuelSupp`/`HAL_GoMedSupp`/`HAL_GoRepSupp` same-addon function-handle references left behind by phase4-rename (which only touches RYD/RHQ/Rydx/RydHQ prefixes, not HAL_). Rewritten to `FUNC(goAmmoSupp)` etc.
- **Files modified:** all 8 fnc_*supp*.sqf in addons/hal_hac/functions/
- **Commit:** cb81c51

**2. [Rule 3 - Blocking] phase4-rename re-touched fnc_AIChatter.sqf and fnc_desperation.sqf (recurring)**
- **Found during:** Task 1a and Task 1b (same pattern as 05-01 Dev #1, 05-02 Dev #2, 05-03 Dev #1)
- **Issue:** phase4-rename with `RydxHQ_` prefix rewrites runtime-constructed `RydxHQ_AIC_SILENTM_` / `RydxHQ_AIC_40KImp_` dispatch strings in fnc_AIChatter.sqf. RydHQ_ prefix rewrites the `RydHQ_Recklessness_Init` literal in fnc_desperation.sqf.
- **Fix:** Snapshot before each rename pass, `cp` revert after. Applied once for Task 1a (8 files × 4 prefixes) and once for Task 1b (hal_tasking × 4 prefixes).
- **Files modified:** none (reverts)
- **Commits:** cb81c51, 58f77e9

**3. [Rule 2 - Missing critical functionality] Removed GVAR(path) unused assignment (T-05-08 mitigation)**
- **Found during:** Task 1b (immediately before commit)
- **Issue:** After replacing the `execVM (GVAR(path) + "SquadTaskingNR6.sqf")` loader, a `grep -rn "GVAR(path)"` showed the assignment line in fnc_init.sqf was the only remaining reference. Since nr6_hal/ is about to be deleted, leaving a literal `GVAR(path) = "\NR6_HAL\"` assignment pointing at a non-existent directory would be a latent denial-of-service hazard (any future code that reads GVAR(path) would receive a broken path).
- **Fix:** Commented out the assignment in fnc_init.sqf with an explanatory note referencing Plan 05-04. This is explicitly called out in the plan's threat register as T-05-08.
- **Files modified:** addons/core/functions/fnc_init.sqf
- **Commit:** 58f77e9

### Scope Boundary Decisions

**HAL_Requested preserved verbatim.** `_mtr setVariable ["HAL_Requested", true]` (and 4 sibling read/clear sites) in fnc_goAmmoSupp.sqf — per-unit setVariable key with both writer and reader living in the same file. Same pattern as HAL_ReqTra* in fnc_sCargo and HAL_TaskMenuAdded/HAL_Task*Added in fnc_squadTasking.

**HAL_Task1Added..HAL_Task13Added, HAL_TaskMenuAdded, HAL_PlayerUnit preserved verbatim.** 73 occurrences total in fnc_squadTasking.sqf. All are per-player setVariable state keys, writer and reader paired within the same main loop. Rewriting to QGVAR would change the runtime key string and break state continuity with any existing save files or cross-addon reads.

**HAL_fnc_getType / HAL_fnc_getSize unchanged.** Pre-existing BIS A3 MARTA wrapper assignments in fnc_init.sqf lines 105-106, called from hal_boss/fnc_EBFT.sqf and fnc_FBFTLOOP.sqf. Out of 05-04 scope (documented in 05-03 Dev #2).

**Dead code in commented-out spawn lines.** fnc_flanking.sqf and fnc_hqOrders.sqf have `//` commented diagnostic spawn examples referencing HAL_GoFlank and HAL_GoRecon. These are documentation, not live code — grep for `call HAL_|spawn HAL_` picks them up as false positives but they pose no runtime risk. Preserved verbatim.

**L-S warnings (all codes).** 78 total inherited L-S warnings across the HAL/*.sqf source files (preserved verbatim by extraction). Fix-in-place would change behavior and violate the #1 no-behavior-change invariant. Deferred to future cleanup plans if authorized (05-05 dead-var audit may surface some of these, 05-09 cleanup plan may address stylistic ones).

## Authentication Gates

None.

## Known Stubs

None introduced by this plan.

## Deferred Issues

- **78 inherited L-S warnings** (L-S25/L-S13/L-S18/L-S12/L-S03/L-S27/L-S24) — behavior-preserving patterns from the extracted nr6_hal/HAL/ source files. Fix-in-place is out of scope under the #1 no-behavior-change invariant. Deferred to future cleanup plans if authorized.
- **HAL_fnc_getType / HAL_fnc_getSize** — pre-existing BIS MARTA wrappers, out of scope.
- **HAL_Requested / HAL_Task*Added / HAL_TaskMenuAdded / HAL_PlayerUnit** per-unit setVariable keys — self-contained, preserve-verbatim per the #1 invariant.
- **Commented-out dead spawn lines** in fnc_flanking.sqf and fnc_hqOrders.sqf — not runtime.

## Threat Register Mitigations Applied

- **T-05-08 (Denial — GVAR(path) pointing to deleted directory):** Mitigated in commit 58f77e9. The assignment `GVAR(path) = "\NR6_HAL\"` was removed (commented out with explanatory reference to Plan 05-04) from addons/core/functions/fnc_init.sqf. Verified via `grep -rn "GVAR(path)" addons/` that only the commented line remains.
- **T-05-09 (Denial — Missed file in nr6_hal/):** Mitigated in commit 8d6f58e. Before `git rm -r nr6_hal/`, iterated every .sqf file under nr6_hal/ and confirmed an addons/*/functions/fnc_*.sqf equivalent exists (including lowercase-first-letter normalization). All 59 .sqf files accounted for, including TimeM/DisOP→timeDisOP, TimeM/EnOP→timeEnOP, LF/LF→LF_Loop, etc.

## Threat Flags

None found. No new trust boundaries introduced. The 8 supply scripts are pure behavior extractions (no new network/file/auth paths), and fnc_squadTasking's remoteExecCall surface (hal_tasking_fnc_action*fnc) was already part of Phase 3 Plan 05's hal_tasking addon inventory.

## Self-Check

- addons/hal_hac/functions/fnc_goAmmoSupp.sqf -> FOUND
- addons/hal_hac/functions/fnc_goFuelSupp.sqf -> FOUND
- addons/hal_hac/functions/fnc_goMedSupp.sqf -> FOUND
- addons/hal_hac/functions/fnc_goRepSupp.sqf -> FOUND
- addons/hal_hac/functions/fnc_suppAmmo.sqf -> FOUND
- addons/hal_hac/functions/fnc_suppFuel.sqf -> FOUND
- addons/hal_hac/functions/fnc_suppMed.sqf -> FOUND
- addons/hal_hac/functions/fnc_suppRep.sqf -> FOUND
- addons/hal_tasking/functions/fnc_squadTasking.sqf -> FOUND
- nr6_hal/ -> NOT PRESENT (directory successfully deleted)
- commit cb81c51 -> FOUND in git log
- commit 58f77e9 -> FOUND in git log
- commit 8d6f58e -> FOUND in git log

## Self-Check: PASSED
