---
phase: 05-settings-localization-compat-cleanup
plan: 03
subsystem: extraction
tags: [extraction, compat-04, tactical-behavior, go-scripts, garrison, sCargo]
wave: 3
requires:
  - 05-02 (Boss + HQ command extraction)
provides:
  - 20 tactical behavior scripts as PREP'd hal_hac functions
  - fnc_goAttInf/Air/AirCAP/Armor/Naval/Sniper (6 attack behaviors)
  - fnc_goCapture, fnc_goCaptureNaval
  - fnc_goFlank, fnc_goSFAttack
  - fnc_goDef/DefAir/DefNav/DefRecon/DefRes (5 defense behaviors)
  - fnc_goIdle, fnc_goRecon, fnc_goRest
  - fnc_sCargo (cargo lift transport, 845 lines)
  - fnc_garrison (garrison behavior)
affects:
  - addons/hal_hac/functions/fnc_statusQuo.sqf (HAL_EnemyScan, HAL_Garrison resolved)
  - addons/hal_hac/functions/fnc_statusQuo_attackDispatch.sqf (HAL_GoSFAttack resolved)
tech-stack:
  added: []
  patterns:
    - "phase4-rename owner-override pinning pattern (reused from 05-02)"
    - "post-pass bulk rewrite of function-handle mis-rewrites (GVAR(spawn) -> EFUNC(common,spawn))"
    - "generated owner-overrides-{prefix}.yml files from rename-map.json canonical owners"
key-files:
  created:
    - addons/hal_hac/functions/fnc_goAttInf.sqf
    - addons/hal_hac/functions/fnc_goAttAir.sqf
    - addons/hal_hac/functions/fnc_goAttAirCAP.sqf
    - addons/hal_hac/functions/fnc_goAttArmor.sqf
    - addons/hal_hac/functions/fnc_goAttNaval.sqf
    - addons/hal_hac/functions/fnc_goAttSniper.sqf
    - addons/hal_hac/functions/fnc_goCapture.sqf
    - addons/hal_hac/functions/fnc_goCaptureNaval.sqf
    - addons/hal_hac/functions/fnc_goFlank.sqf
    - addons/hal_hac/functions/fnc_goSFAttack.sqf
    - addons/hal_hac/functions/fnc_goDef.sqf
    - addons/hal_hac/functions/fnc_goDefAir.sqf
    - addons/hal_hac/functions/fnc_goDefNav.sqf
    - addons/hal_hac/functions/fnc_goDefRecon.sqf
    - addons/hal_hac/functions/fnc_goDefRes.sqf
    - addons/hal_hac/functions/fnc_goIdle.sqf
    - addons/hal_hac/functions/fnc_goRecon.sqf
    - addons/hal_hac/functions/fnc_goRest.sqf
    - addons/hal_hac/functions/fnc_sCargo.sqf
    - addons/hal_hac/functions/fnc_garrison.sqf
    - .planning/phases/05-settings-localization-compat-cleanup/owner-overrides-rydhq.yml
    - .planning/phases/05-settings-localization-compat-cleanup/owner-overrides-rydxhq.yml
    - .planning/phases/05-settings-localization-compat-cleanup/owner-overrides-ryd.yml
    - .planning/phases/05-settings-localization-compat-cleanup/owner-overrides-rhq.yml
  modified:
    - addons/hal_hac/XEH_PREP.hpp
    - addons/hal_hac/functions/fnc_statusQuo.sqf
    - addons/hal_hac/functions/fnc_statusQuo_attackDispatch.sqf
decisions:
  - "Generated comprehensive owner-override YAML files programmatically from rename-map.json (372 RydHQ_ + 50 RydxHQ_ + 36 RYD_ + 34 RHQ_ entries) — prevents phase4-rename default-inference flipping owners on freshly-dropped files."
  - "phase4-rename scan correctly skipped a 3200-char block comment in GoAttInf.sqf containing dead RydHQ_* references (the tool's tokenizer recognizes /* */ blocks). Only 11 live RydHQ_ references exist in fnc_goAttInf.sqf vs 57 in the raw source."
  - "Function handles (RYD_Spawn, RYD_Wait, HAL_GoRest etc.) are not in rename-map.json (they're compiled function names, not data variables). Post-pass bulk rewrite translates them to EFUNC(common,*) / FUNC(*) per canonical PREP location."
  - "HAL_ReqTraActs, HAL_ReqTraVActs, HAL_ReqTraOn string literals in fnc_sCargo.sqf preserved verbatim. These are per-unit setVariable keys with both writer and reader in the same file — self-contained, no cross-addon leakage. Rewriting to QGVAR would change key strings and potentially break concurrent caller state."
  - "HAL_SuppMed/Fuel/Rep/Ammo in fnc_statusQuo.sqf left as bare global calls — Plan 05-04 targets."
  - "HAL_fnc_getType / HAL_fnc_getSize in EBFT/FBFTLOOP left as bare — they wrap A3\\modules_f\\marta BIS scripts, assigned in fnc_init.sqf, pre-existing pattern outside 05-03 scope."
metrics:
  duration_minutes: 18
  tasks_completed: 2
  files_created: 20
  files_modified: 3
  completed: 2026-04-12
---

# Phase 5 Plan 03: Extraction Wave 3 (20 tactical behavior scripts) Summary

Extracted the entire tactical behavior layer — 20 Go*/Garrison/SCargo scripts (9058 total lines) — from nr6_hal/HAL/ into addons/hal_hac/functions/ as PREP'd CBA functions. Combined with 05-02's command layer, the entire HAL AI decision pipeline now runs from addons/ without any preprocessFile loads from the legacy tree, and the statusQuo trunk's forward-reference HAL_* call sites for Plan 05-03 targets are fully resolved.

## Objective Achieved

- 20 tactical scripts PREP'd in hal_hac: goAttInf, goAttAir, goAttAirCAP, goAttArmor, goAttNaval, goAttSniper, goCapture, goCaptureNaval, goFlank, goSFAttack, goDef, goDefAir, goDefNav, goDefRecon, goDefRes, goIdle, goRecon, goRest, sCargo, garrison.
- All legacy RydHQ_/RydxHQ_/RYD_ variable names in the new files converted to GVAR/EGVAR macros via phase4-rename with pinned owner overrides.
- All legacy function-handle calls (call HAL_*, call RYD_*, spawn HAL_*) in the new files and in statusQuo rewritten to FUNC()/EFUNC() macros.
- fnc_statusQuo.sqf: HAL_EnemyScan -> EFUNC(core,enemyScan), HAL_Garrison -> FUNC(garrison).
- fnc_statusQuo_attackDispatch.sqf: HAL_GoSFAttack -> FUNC(goSFAttack).
- HAL_SuppMed/Fuel/Rep/Ammo remain bare globals (Plan 05-04 targets).

## Commits

| # | Hash      | Subject |
|---|-----------|---------|
| 1 | 5db73b8   | feat(05-03): extract 10 Go* attack/capture/SF tactical scripts |
| 2 | 150ee12   | feat(05-03): extract 10 defense/recon/idle/rest/cargo/garrison scripts |

## Verification Results

- `hemtt build`: EXIT=0, 9 PBOs built.
- L-S29 undefined-function warnings: **0** (all forward-refs resolved after Task 2).
- L-S warning histogram after Task 2: 4x L-S03, 7x L-S12, 10x L-S18, 3x L-S24 = 24 inherited behavior-preserving patterns from nr6_hal/HAL/ source. Not regressions — these are the exact same idioms that appeared in the raw source files and are preserved verbatim under the #1 no-behavior-change invariant.
- BBW1 accepted per CLAUDE.md environment notice.
- `grep -rn '\\bcall HAL_\\|\\bspawn HAL_' addons/ | grep -v compat | grep -v '^\\s*//'` returns only:
  - HAL_SuppMed/SuppFuel/SuppRep/SuppAmmo (4 lines in fnc_statusQuo.sqf — Plan 05-04 targets, intentional)
  - HAL_fnc_getType/getSize (4 lines in EBFT/FBFTLOOP — pre-existing A3 MARTA wrappers, out of 05-03 scope)
- `grep -c 'PREP(goAttInf' addons/hal_hac/XEH_PREP.hpp` -> 1.
- `grep -c 'PREP(garrison' addons/hal_hac/XEH_PREP.hpp` -> 1.
- `grep -c 'PREP(sCargo' addons/hal_hac/XEH_PREP.hpp` -> 1.

## Extraction Details

### Task 1 — 10 attack/capture/SF scripts (commit 5db73b8)

| Source | Destination | Lines |
|---|---|---|
| nr6_hal/HAL/GoAttInf.sqf | fnc_goAttInf.sqf | 793 |
| nr6_hal/HAL/GoAttAir.sqf | fnc_goAttAir.sqf | 332 |
| nr6_hal/HAL/GoAttAirCAP.sqf | fnc_goAttAirCAP.sqf | 154 |
| nr6_hal/HAL/GoAttArmor.sqf | fnc_goAttArmor.sqf | 237 |
| nr6_hal/HAL/GoAttNaval.sqf | fnc_goAttNaval.sqf | 192 |
| nr6_hal/HAL/GoAttSniper.sqf | fnc_goAttSniper.sqf | 378 |
| nr6_hal/HAL/GoCapture.sqf | fnc_goCapture.sqf | 1004 |
| nr6_hal/HAL/GoCaptureNaval.sqf | fnc_goCaptureNaval.sqf | 306 |
| nr6_hal/HAL/GoFlank.sqf | fnc_goFlank.sqf | 588 |
| nr6_hal/HAL/GoSFAttack.sqf | fnc_goSFAttack.sqf | 844 |

Per-file steps:
1. Copy source with `#include "..\\script_component.hpp"` header and origin comment.
2. Register `PREP(goAtt*);` / `PREP(goCapture*);` / `PREP(goFlank);` / `PREP(goSFAttack);` in addons/hal_hac/XEH_PREP.hpp.
3. Run phase4-rename with owner-override per prefix (RydHQ_, RydxHQ_, RYD_, RHQ_). RHQ_ pass found 0 live names.
4. Post-pass bulk rewrite of function handles (see Dev #2 below).
5. Revert phase4-rename side-effects on fnc_AIChatter.sqf and fnc_desperation.sqf.

### Task 2 — 10 defense/recon/idle/rest/cargo/garrison scripts (commit 150ee12)

| Source | Destination | Lines |
|---|---|---|
| nr6_hal/HAL/GoDef.sqf | fnc_goDef.sqf | 264 |
| nr6_hal/HAL/GoDefAir.sqf | fnc_goDefAir.sqf | 200 |
| nr6_hal/HAL/GoDefNav.sqf | fnc_goDefNav.sqf | 162 |
| nr6_hal/HAL/GoDefRecon.sqf | fnc_goDefRecon.sqf | 266 |
| nr6_hal/HAL/GoDefRes.sqf | fnc_goDefRes.sqf | 273 |
| nr6_hal/HAL/GoIdle.sqf | fnc_goIdle.sqf | 295 |
| nr6_hal/HAL/GoRecon.sqf | fnc_goRecon.sqf | 922 |
| nr6_hal/HAL/GoRest.sqf | fnc_goRest.sqf | 717 |
| nr6_hal/HAL/SCargo.sqf | fnc_sCargo.sqf | 845 |
| nr6_hal/HAL/Garrison.sqf | fnc_garrison.sqf | 286 |

Same procedure as Task 1. Additional post-pass: `RYD_AngTowards -> EFUNC(common,angleTowards)`, `RYD_PosTowards2D -> EFUNC(common,positionTowards2D)`.

statusQuo cleanup (05-02 deferred items resolved):
- fnc_statusQuo.sqf: `call HAL_EnemyScan` -> `call EFUNC(core,enemyScan)`
- fnc_statusQuo.sqf: `spawn HAL_Garrison` -> `spawn FUNC(garrison)`
- fnc_statusQuo_attackDispatch.sqf: `HAL_GoSFAttack` (array element) -> `FUNC(goSFAttack)`

## Owner-Override File Generation

Pre-Task 1, generated comprehensive per-prefix YAML overrides from rename-map.json:

```python
# .tmp script (not committed)
import json
m = json.load(open('.planning/phases/04-variable-namespacing/rename-map.json'))
for entry in m['entries']:
    # write legacy_name: addon_owner to appropriate prefix file
```

Output:
- owner-overrides-rydhq.yml: 372 entries
- owner-overrides-rydxhq.yml: 50 entries
- owner-overrides-ryd.yml: 36 entries
- owner-overrides-rhq.yml: 34 entries
- RydBB_ has 0 entries in rename-map (handled by addons/missionmodules via its own namespace)

These YAML files live under `.planning/phases/05-settings-localization-compat-cleanup/` and are shareable between 05-03 and future extraction waves (05-04).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] phase4-rename re-touched fnc_AIChatter.sqf and fnc_desperation.sqf**
- **Found during:** Task 1 and Task 2 (after every rename pass)
- **Issue:** phase4-rename with `RydxHQ_` and `RydHQ_` prefixes rewrites the runtime-constructed `RydxHQ_AIC_SILENTM_` / `RydxHQ_AIC_40KImp_` dispatch strings in fnc_AIChatter.sqf, and re-rewrites the `RydHQ_Recklessness_Init` literal in fnc_desperation.sqf — same bugs as 05-01 Dev #1 and 05-02 Dev #2 recurring because the tool has no per-file skip mechanism.
- **Fix:** `git checkout -- addons/common/functions/fnc_AIChatter.sqf addons/hal_hac/functions/fnc_desperation.sqf` after every phase4-rename run. Done before Task 1 commit and before Task 2 commit.
- **Files modified:** (none — reverts)
- **Commits:** 5db73b8 (Task 1), 150ee12 (Task 2)

**2. [Rule 1 - Bug] phase4-rename converted bare function handles to GVAR() data-var form**
- **Found during:** Task 1 (initial build inspection)
- **Issue:** The RYD_ pass rewrote `call RYD_Spawn`, `call RYD_Wait`, `call RYD_AddTask`, `call RYD_AIChatter`, etc. to `call GVAR(spawn)`, `call GVAR(wait)`, `call GVAR(addTask)`, `call GVAR(aIChatter)`, etc. — but these are COMPILED FUNCTION HANDLES, not data variables. Similarly, `call HAL_GoRest`, `spawn HAL_SCargo`, etc. were left bare.
- **Fix:** Post-pass Python bulk rewrite script (`.tmp/rewrite-05-03-task1.py`) translates all wrong GVAR() forms and bare RYD_/HAL_ handles to their correct macro forms:
  - Common-addon functions: `GVAR(spawn)` -> `EFUNC(common,spawn)` (plus 17 more)
  - Bare RYD_* function handles: `RYD_Wait` -> `EFUNC(common,wait)` (plus 19 more)
  - Bare HAL_* function handles: `HAL_GoRest` -> `FUNC(goRest)` (same addon, plus 32 more)
- **Files modified:** All 20 extracted files in addons/hal_hac/functions/
- **Commits:** 5db73b8, 150ee12

**3. [Rule 1 - Bug] Task 2 extras: RYD_AngTowards / RYD_PosTowards2D not in Task 1 handle map**
- **Found during:** Task 2 (post-rename grep for residual RYD_*)
- **Issue:** fnc_goDefNav.sqf line 99, fnc_goDefRes.sqf line 193, and fnc_sCargo.sqf lines 325/326/336 contain `RYD_AngTowards` and `RYD_PosTowards2D` function-handle calls. These weren't in Task 1's bulk rewrite map because they didn't appear in the 10 attack/capture files.
- **Fix:** Added to post-pass extras script — `RYD_AngTowards` -> `EFUNC(common,angleTowards)` and `RYD_PosTowards2D` -> `EFUNC(common,positionTowards2D)`. Verified PREP entries exist in addons/common/XEH_PREP.hpp.
- **Files modified:** fnc_goDefNav.sqf, fnc_goDefRes.sqf, fnc_sCargo.sqf
- **Commit:** 150ee12

**4. [Rule 2 - Missing critical functionality] statusQuo HAL_* cleanup (05-02 deferred items)**
- **Found during:** Task 2 (after all 20 files PREP'd)
- **Issue:** fnc_statusQuo.sqf had 3 bare HAL_* call sites that 05-02 intentionally deferred to 05-03 because the callees hadn't been PREP'd yet. Now they are: HAL_EnemyScan (PREP'd as EFUNC(core,enemyScan) since 05-01), HAL_Garrison (Task 2), HAL_GoSFAttack (Task 1).
- **Fix:** Rewrote all 3 call sites. fnc_statusQuo_attackDispatch.sqf's `[...,HAL_GoSFAttack] call EFUNC(common,spawn)` also updated — `HAL_GoSFAttack` is the array element passed to spawn, so replacing with `FUNC(goSFAttack)` is correct.
- **Files modified:** addons/hal_hac/functions/fnc_statusQuo.sqf, fnc_statusQuo_attackDispatch.sqf
- **Commit:** 150ee12

### Scope Boundary Decisions

**HAL_SuppMed/Fuel/Rep/Ammo kept as bare globals.** These 4 bare HAL_* call sites in fnc_statusQuo.sqf are Plan 05-04 targets (the supply scripts SuppMed.sqf, SuppFuel.sqf, SuppRep.sqf, SuppAmmo.sqf haven't been extracted yet). Matching 05-02's intermediate-state pattern: leave bare until extraction commit lands.

**HAL_fnc_getType / HAL_fnc_getSize out of scope.** These are assigned in addons/core/functions/fnc_init.sqf lines 105-106 as wrappers for BIS A3 MARTA data scripts (`A3\modules_f\marta\data\scripts\fnc_getType.sqf`). They're used in addons/hal_boss/functions/fnc_EBFT.sqf and fnc_FBFTLOOP.sqf. The assignment/reader pairs are consistent, pre-existing, and the name `HAL_fnc_*` matches BIS naming convention. Out of 05-03 scope.

**HAL_ReqTraActs / HAL_ReqTraVActs / HAL_ReqTraOn string literals in fnc_sCargo.sqf preserved verbatim.** These are `_unit setVariable ["HAL_ReqTra...", value]` keys, per-unit state tracking within the sCargo cargo lift flow. Both writers and readers live in the same file (fnc_sCargo.sqf). Rewriting to QGVAR would change the runtime key string and could disrupt any cross-call state if these units are read from another script path. Under the #1 no-behavior-change invariant, preserve verbatim.

**Dead code in /* */ block comments.** phase4-rename's tokenizer correctly skips block comments. The source GoAttInf.sqf has a 3228-character block comment at lines ~150 containing dead legacy code with 46 RydHQ_ references — the live code has only 11 RydHQ_ occurrences. The tool (correctly) left both the active and dead code intact; the dead code doesn't affect runtime.

## Auth Gates

None.

## Known Stubs

None introduced by this plan.

## Deferred Issues

- **HAL_SuppMed/Fuel/Rep/Ammo in fnc_statusQuo.sqf** — 4 bare globals. Plan 05-04 extracts the callees (nr6_hal/HAL/SuppMed.sqf, SuppFuel.sqf, SuppRep.sqf, SuppAmmo.sqf) and will rewrite these sites to `FUNC(*)`.
- **HAL_ReqTra* string literals** in fnc_sCargo.sqf — self-contained per-unit setVariable keys, preserved verbatim.
- **HAL_fnc_getType / getSize** — BIS MARTA wrappers, out of scope.
- **24 inherited L-S warnings** (L-S03/L-S12/L-S18/L-S24) — behavior-preserving patterns from nr6_hal/HAL/ source. Fix-in-place would be a behavior change and is not authorized under 05-03 scope. Deferred to future cleanup plans if authorized.

## Threat Register Mitigations Applied

- **T-05-06 (Denial — Missing FUNC/EFUNC for cross-calls within HAL scripts):** Mitigated. All bare HAL_*/RYD_* function-handle references in the 20 new files rewritten to FUNC/EFUNC macros. 0 L-S29 undefined-function warnings remaining. Verified by grep for `\\bcall HAL_\\|\\bspawn HAL_\\|\\bcall RYD_\\|\\bspawn RYD_` in non-comment positions returning only Plan 05-04 / BIS-wrapper out-of-scope items.
- **T-05-07 (Tampering — Variable rename coverage):** Mitigated. phase4-rename applied per-prefix with owner-override pins matching rename-map.json canonical owners. 0 live raw RydHQ_/RydxHQ_/RYD_/RHQ_ references in the 20 new files. Raw legacy names that remain are inside /* */ block comments (dead code) and are behavior-neutral.

## Self-Check

- addons/hal_hac/functions/fnc_goAttInf.sqf -> FOUND
- addons/hal_hac/functions/fnc_goAttAir.sqf -> FOUND
- addons/hal_hac/functions/fnc_goAttAirCAP.sqf -> FOUND
- addons/hal_hac/functions/fnc_goAttArmor.sqf -> FOUND
- addons/hal_hac/functions/fnc_goAttNaval.sqf -> FOUND
- addons/hal_hac/functions/fnc_goAttSniper.sqf -> FOUND
- addons/hal_hac/functions/fnc_goCapture.sqf -> FOUND
- addons/hal_hac/functions/fnc_goCaptureNaval.sqf -> FOUND
- addons/hal_hac/functions/fnc_goFlank.sqf -> FOUND
- addons/hal_hac/functions/fnc_goSFAttack.sqf -> FOUND
- addons/hal_hac/functions/fnc_goDef.sqf -> FOUND
- addons/hal_hac/functions/fnc_goDefAir.sqf -> FOUND
- addons/hal_hac/functions/fnc_goDefNav.sqf -> FOUND
- addons/hal_hac/functions/fnc_goDefRecon.sqf -> FOUND
- addons/hal_hac/functions/fnc_goDefRes.sqf -> FOUND
- addons/hal_hac/functions/fnc_goIdle.sqf -> FOUND
- addons/hal_hac/functions/fnc_goRecon.sqf -> FOUND
- addons/hal_hac/functions/fnc_goRest.sqf -> FOUND
- addons/hal_hac/functions/fnc_sCargo.sqf -> FOUND
- addons/hal_hac/functions/fnc_garrison.sqf -> FOUND
- commit 5db73b8 -> FOUND in git log
- commit 150ee12 -> FOUND in git log

## Self-Check: PASSED
