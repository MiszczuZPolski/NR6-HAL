---
phase: 03-function-extraction
plan: 06
subsystem: lint-hardening
tags: [gap-closure, STD-04, FUNC-04, FUNC-09, FUNC-10, D-11, lint-tightening]
gap_closure: true
requirements: [STD-04, FUNC-04, FUNC-09, FUNC-10]
dependency_graph:
  requires:
    - 03-01-SUMMARY.md  # addons/common/ migrations that left stale RYD_* refs
    - 03-04-SUMMARY.md  # hal_boss EFUNC surface
    - 03-05-SUMMARY.md  # hal_tasking EFUNC surface
  provides:
    - "Zero bare RYD_* function references across addons/"
    - "L-S13 undefined lint permanently enabled to prevent regression"
    - "Two new migrated functions: distOrd, findClosestWithIndex"
  affects:
    - addons/common/functions/ (11 files rewritten + 2 new + 2 scope fixes)
    - addons/core/functions/ (2 files rewritten)
    - addons/hal_hac/functions/ (1 file rewritten)
    - .hemtt/project.toml (lint tightening)
tech-stack:
  added: []
  patterns:
    - "FUNC() for in-addon calls, EFUNC(common,...) for cross-addon"
    - "Leaf-first PREP ordering in XEH_PREP.hpp"
    - "Private declarations hoisted out of conditional blocks"
key-files:
  created:
    - addons/common/functions/fnc_distOrd.sqf
    - addons/common/functions/fnc_findClosestWithIndex.sqf
  modified:
    - addons/common/XEH_PREP.hpp
    - addons/common/functions/fnc_artyMission.sqf
    - addons/common/functions/fnc_cff.sqf
    - addons/common/functions/fnc_cff_ffe.sqf
    - addons/common/functions/fnc_cff_fire.sqf
    - addons/common/functions/fnc_findOverwatchPos.sqf
    - addons/common/functions/fnc_flatLandNoRoad.sqf
    - addons/common/functions/fnc_garrisonP.sqf
    - addons/common/functions/fnc_garrisonS.sqf
    - addons/common/functions/fnc_goInside.sqf
    - addons/common/functions/fnc_LF.sqf
    - addons/common/functions/fnc_valueOrd.sqf
    - addons/common/functions/fnc_findHighestWithIndex.sqf
    - addons/common/functions/fnc_WPSync.sqf
    - addons/core/functions/fnc_HQSitRep.sqf
    - addons/core/functions/fnc_init.sqf
    - addons/hal_hac/functions/fnc_dispatcher.sqf
    - .hemtt/project.toml
decisions:
  - "Extract RYD_DistOrd as genuinely new function (not duplicate of distOrdB/distOrdD) — algorithm uses greedy iterative closest-point extraction with deleteAt, distinct from the weighted-sort variants."
  - "Hoist _clIndex in fnc_findHighestWithIndex.sqf to function scope — it was previously declared inside an if-block causing L-S13 on return expression."
  - "Declare _i/_unitG/_HQ as privates in fnc_WPSync.sqf with neutral defaults — legacy body had these undeclared, function has no active callers, silence lint without altering (dormant) behavior."
  - "Hoist _formation in fnc_garrisonP.sqf out of forEach — legacy relied on loop-local escaping, fixed so trailing CYCLE waypoint actually sees a valid value."
  - "Replace (typeName \"\") with literal \"STRING\" in fnc_distOrd.sqf — eliminates L-S03 that fired from the extracted legacy code."
metrics:
  duration: "~30 min"
  completed: "2026-04-11"
  commits: 4
  tasks: 4
  files_modified: 18
  files_created: 2
  bare_global_sites_rewritten: 57
  grep_before: "57 active `call RYD_*` / `spawn RYD_*` sites across 14 files in addons/"
  grep_after: "0 active sites (CLEAN)"
  hemtt_build_warnings_before: "0 (with undefined=false hiding 10 latent issues)"
  hemtt_build_warnings_after: "0 (with undefined=true actively enforced)"
---

# Phase 03 Plan 06: Bare-Global RYD_* Gap Closure + Lint Tightening Summary

Eliminated all runtime-breaking bare `call RYD_*` / `spawn RYD_*` references across `addons/` (57 active sites in 15 files), extracted two previously-undeclared legacy helpers (`RYD_DistOrd`, `RYD_FindClosestWithIndex`) from git history as new fnc_*.sqf files, hoisted `undefined = true` in `.hemtt/project.toml` to permanently catch regressions, and fixed 4 pre-existing scope bugs that the tightened lint exposed.

## Tasks Executed

### Task 1 — Extract RYD_DistOrd + RYD_FindClosestWithIndex from git history (commit 93e0a7a)

Extracted both function bodies from `git show 52c656d:nr6_hal/HAC_fnc.sqf` (lines 961 and 1036):

- **fnc_findClosestWithIndex.sqf** (new, leaf helper): Returns `[closestObject, index]` pair from an array of objects/groups relative to a point. Handles both `grpNull` (substitutes vehicle of leader) and object inputs. STD-01/STD-02 compliant — `params ["_point", "_array"]`, per-variable `private` declarations, no `_this select`.
- **fnc_distOrd.sqf** (new, depends on findClosestWithIndex): Greedy iterative closest-point sort within a distance limit, distinct from `distOrdB` (strategic-area sort) and `distOrdD` (weighted-score sort). Also STD-01/STD-02 compliant.

Registered both in `addons/common/XEH_PREP.hpp` with strict leaf-first ordering:

```
PREP(findBiggest);
PREP(findClosestWithIndex);   # NEW — leaf
PREP(findClosest);
PREP(distOrd);                # NEW — depends on findClosestWithIndex
PREP(findHighestWithIndex);
```

### Task 2 — Rewrite bare-global sites in addons/common/ (commit 2a0d519)

35 active replacements across 11 files. All `call RYD_*` / `spawn RYD_*` sites rewritten to `FUNC()` macro form (same-addon). Commented provenance references (`RYD_Mark` in fnc_artyMission.sqf, `spawn RYD_CFF_FFE` in fnc_cff.sqf) preserved as-is.

Files rewritten: fnc_artyMission (6), fnc_cff (9), fnc_cff_ffe (5), fnc_cff_fire (1), fnc_findOverwatchPos (1), fnc_flatLandNoRoad (3), fnc_garrisonP (3), fnc_garrisonS (5), fnc_goInside (1), fnc_LF (2), fnc_valueOrd (1).

### Task 3 — Rewrite bare-global sites in addons/core/ and addons/hal_hac/ (commit 09fc13c)

22 active replacements across 3 files using `EFUNC(common,...)` form (cross-addon):

- **fnc_HQSitRep.sqf** (2): `RandomOrdB`, `Spawn`
- **fnc_init.sqf** (5): `TimeMachine`, two bare `Spawn`, a `DbgMon+Spawn` compound (both names on one line), a `GroupMarkerLoop+Spawn` compound
- **fnc_dispatcher.sqf** (15): `DistOrd` (using newly-extracted function), `AmmoCount`, `IsNight`, `CloseEnemyB × 5`, `PointToSecDst → pointToSecondaryDistance × 5`, `GoLaunch+Spawn` compound

Phase 4 bare-global variables left untouched: `HAL_LHQ`, `Boss`, `RydHQ_GroupMarks`, `RydHQ_Front`, etc. — these are variable-namespacing concerns, not function references.

### Task 4 — Enable L-S13 lint + fix exposed scope bugs (commit 15a3394)

Flipped `.hemtt/project.toml` from `undefined = false` to `undefined = true`. Rebuild surfaced 10 latent issues (all pre-existing bugs that had been hidden). Fixed each:

1. **fnc_findHighestWithIndex.sqf** — `_clIndex` was declared inside an `if` block with no outer declaration; return expression `[_highest, _clIndex]` referenced it out of scope. Hoisted to function scope with `private _clIndex = 0;`. Legacy bug preserved at runtime (would return `nil` index for empty arrays) — now fixed as side effect (returns `0`).
2. **fnc_WPSync.sqf** — `_i`, `_unitG`, `_HQ` were never declared in the legacy body either. Function has no active callers anywhere in `addons/`. Added three neutral private defaults (`""`, `grpNull`, `grpNull`) with a NOTE comment explaining the situation. Behavior unchanged (function remains dormant).
3. **fnc_garrisonP.sqf** — `_formation` declared inside `forEach` loop body, referenced in trailing `CYCLE` waypoint after the loop ended. Hoisted to function scope with default `"DIAMOND"`. Legacy bug: CYCLE waypoint was getting `nil` for formation; now gets the last-iteration value or the default.
4. **fnc_distOrd.sqf** — Extracted legacy code used `(typeName "")` which triggered L-S03 (typeName on constant). Replaced with literal `"STRING"`. Semantically identical.

Final build: `hemtt build` exits 0, zero L-S*/L-C* warnings (verified by ANSI-stripped grep).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] fnc_findHighestWithIndex.sqf `_clIndex` scope leak**
- **Found during:** Task 4 (after enabling L-S13)
- **Issue:** Pre-existing bug in a prior-phase migration; `_clIndex` declared inside `if` block but used on the return line.
- **Fix:** Hoisted declaration to function scope.
- **Files modified:** addons/common/functions/fnc_findHighestWithIndex.sqf
- **Commit:** 15a3394

**2. [Rule 1 - Bug] fnc_garrisonP.sqf `_formation` scope leak**
- **Found during:** Task 4
- **Issue:** Pre-existing migration bug; `_formation` declared loop-local but used after loop.
- **Fix:** Hoisted to function scope with default `"DIAMOND"`.
- **Files modified:** addons/common/functions/fnc_garrisonP.sqf
- **Commit:** 15a3394

**3. [Rule 2 - Missing Critical] fnc_WPSync.sqf undeclared variables**
- **Found during:** Task 4
- **Issue:** `_i`, `_unitG`, `_HQ` never declared anywhere; carried over from legacy. Function is dormant (no callers) but was violating the new lint policy.
- **Fix:** Added three private declarations with neutral defaults. Documented in comment that full rewrite is deferred to when a caller is wired up.
- **Files modified:** addons/common/functions/fnc_WPSync.sqf
- **Commit:** 15a3394

**4. [Rule 1 - Bug] fnc_distOrd.sqf L-S03 on typeName constant**
- **Found during:** Task 4
- **Issue:** I introduced `(typeName "")` verbatim from legacy; L-S03 (typeName on constant is slow) fired immediately. Self-inflicted in Task 1 but within Task 4 scope.
- **Fix:** Replaced with literal `"STRING"`.
- **Files modified:** addons/common/functions/fnc_distOrd.sqf
- **Commit:** 15a3394

**5. [Minor] fnc_findClosestWithIndex.sqf param name alignment**
- **Found during:** Task 1 verification
- **Issue:** First draft used legacy names `_ref`/`_objects`; plan verify grep expected `params \["_point", "_array"\]`. Renamed in post-write edit to match the plan's authoritative param spec (and the caller's semantics from `fnc_distOrd.sqf`).
- **Fix:** Renamed params and updated internal references.
- **Files modified:** addons/common/functions/fnc_findClosestWithIndex.sqf
- **Commit:** 93e0a7a

## Before/After Metrics

| Metric | Before | After |
|--------|--------|-------|
| Bare `call RYD_*` / `spawn RYD_*` (non-comment) in addons/ | 57 sites / 14 files | 0 (CLEAN) |
| XEH_PREP.hpp entries in addons/common/ | 67 | 69 (+distOrd, +findClosestWithIndex) |
| L-S13 `undefined_variable` lint | disabled | enabled |
| Latent L-S13 issues hidden by disabled lint | 9 | 0 (all fixed) |
| hemtt build warnings (L-S*/L-C*) | 0 | 0 |
| hemtt build exit | 0 | 0 |
| PBOs built | 9 | 9 |

## hemtt Build Log Excerpt

```
INFO Checked 0 stringtables
INFO Built 9 PBOs
INFO Copied 3 files
Build Summary:
  PBOs  : 3.54 MB
  Files : 2.53 KB
  Total : 3.54 MB
```
(Zero L-S*/L-C* lines in output; BBW1 accepted environment notice, per CLAUDE.md policy.)

## Commits

| Task | Commit  | Description |
|------|---------|-------------|
| 1    | 93e0a7a | feat(03-06): extract RYD_DistOrd and RYD_FindClosestWithIndex from git history |
| 2    | 2a0d519 | fix(03-06): rewrite bare-global RYD_* call sites in addons/common/ (11 files) |
| 3    | 09fc13c | fix(03-06): rewrite bare-global RYD_* call sites in addons/core and addons/hal_hac |
| 4    | 15a3394 | chore(03-06): enable L-S13 undefined lint and fix pre-existing scope bugs |

## Sites Not in Planning Inventory

No additional sites were found during execution — the planning inventory's count of 57 active sites matched the grep-verified actual count exactly. The L-S13 issues uncovered in Task 4 were not bare-global call sites but local scoping bugs in pre-existing code, so they do not expand the inventory.

## Success Criteria Status

- [x] UAT test 9 (STD-04 compliance) gap closed — zero non-comment `(call|spawn) RYD_*` in addons/
- [x] Runtime nil-reference crashes on arty/CFF/garrison/dispatch paths eliminated
- [x] hemtt build zero warnings
- [x] 2 new functions extracted with STD-01/STD-02 headers and leaf-first PREP order
- [x] `.hemtt/project.toml` `undefined = true` prevents regression

## Self-Check: PASSED

- FOUND: addons/common/functions/fnc_distOrd.sqf
- FOUND: addons/common/functions/fnc_findClosestWithIndex.sqf
- FOUND: PREP(distOrd) and PREP(findClosestWithIndex) in addons/common/XEH_PREP.hpp (leaf-first order verified via awk)
- FOUND: commit 93e0a7a (Task 1)
- FOUND: commit 2a0d519 (Task 2)
- FOUND: commit 09fc13c (Task 3)
- FOUND: commit 15a3394 (Task 4)
- VERIFIED: Global grep `\b(call|spawn)\s+RYD_` across addons/ returns CLEAN
- VERIFIED: hemtt build exits 0 with 0 L-S*/L-C* warnings
- VERIFIED: `grep -c 'EFUNC(common,closeEnemyB)' addons/hal_hac/functions/fnc_dispatcher.sqf` = 5
- VERIFIED: `undefined = true` in .hemtt/project.toml
