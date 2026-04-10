---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: executing
last_updated: "2026-04-10T00:00:00.000Z"
progress:
  total_phases: 5
  completed_phases: 2
  total_plans: 15
  completed_plans: 11
  percent: 73
---

# Project State: NR6-HAL ACE3 Refactor

**Project:** NR6-HAL — Migrate nr6_hal to ACE3/CBA-compliant addon structure
**Core Value:** Existing HAL AI behavior must continue working identically after refactoring
**Last updated:** 2026-04-09

---

## Project Reference

**Core Value:** Structure changes, not behavior changes. HAL AI behavior must be identical after refactoring.

**Current Focus:** Phase 01 — addon-skeleton-build-foundation

---

## Current Position

Phase: 03 (function-extraction) — EXECUTING
Plan: 3 of 5 complete
**Phase:** 3 — Function Extraction
**Plan:** 03-03 complete (HAC_fnc2.sqf + RHQLibrary.sqf extracted)
**Status:** Executing — plans 04 and 05 remain in phase 03

**Progress:**

```
[Phase 1] Addon Skeleton & Build Foundation   [x] Complete
[Phase 2] Dependency Mapping                  [x] Complete
[Phase 3] Function Extraction                 [~] In progress (3/5 plans done)
[Phase 4] Variable Namespacing                [ ] Not started
[Phase 5] Settings, Localization, Compat      [ ] Not started
```

Overall: 2/5 phases complete (phase 3 in progress)

---

## Performance Metrics

- Plans executed: 0
- Plans succeeded first try: 0
- Phases completed: 0
- Requirements satisfied: 0/37

---

## Accumulated Context

### Key Decisions Logged

| Decision | Rationale |
|----------|-----------|
| 5 coarse phases (not 8) | Granularity=coarse; skeleton+mapping are gates, all extraction is one large phase, namespacing isolated, settings+compat combined at end |
| Namespacing isolated in Phase 4 | Most dangerous operation — partial renames with coexisting layers cause non-deterministic state; must follow complete extraction |
| All 5 monolithic files in one extraction phase | Natural delivery boundary: all extraction must be complete before namespacing can begin |
| BEHAV requirements in Phase 5 | Behavior verification only meaningful after full migration and cleanup are complete |
| D-03: S3 split into classifyFriends + classifyEnemies | Combined block ~385 lines exceeded 250-line sub-function limit |
| D-07: RYD_LF_Loop extracted not deleted | Active caller confirmed at nr6_hal/LF/LF.sqf:6 |
| proposal-a: explicit params on StatusQuo sub-functions | Clean interfaces, no closure dependency, testable in isolation |
| setMarker*Local for intermediate BFT updates | Fixes L-S24 warnings and reduces network traffic (genuine optimization) |

### Critical Pitfalls (from research)

1. Functions called before PREP compiles them — silent nil returns, AI never starts
2. Global variable collision during incremental migration — non-deterministic AI behavior; never run both layers simultaneously
3. `publicVariable` string literals not updated after GVAR rename — multiplayer-only silent failure
4. VarInit compilation sequence lost when splitting files — must map dependency graph first (Phase 2 gate)
5. Missing `#include "script_component.hpp"` — mass HEMTT warnings hiding real issues

### Architecture Notes

- Macro chain: `MAINPREFIX=z`, `PREFIX=hal`, `COMPONENT=<folder>` — established in `addons/main/`
- `HAC_fnc.sqf` (5645 lines) is mostly dead code — only ~10 active functions remain
- `Boss_fnc.sqf` strategic functions land in `addons/core/functions/`
- `RHQLibrary.sqf` is data (weapon class arrays) → `fnc_initWeaponClasses.sqf`
- CBA PREP order: leaf functions must be declared before callers

### Active Todos

- (none yet — project just initialized)

### Active Blockers

- (none)

---

## Session Continuity

**Stopped at:** Completed 03-03-PLAN.md (HAC_fnc2.sqf + RHQLibrary.sqf extraction)

**Context for next session:**

- Phase 03 plans 01-03 complete; plans 04 and 05 remain
- HAC_fnc2.sqf and RHQLibrary.sqf deleted; all functions extracted to hal_hac/hal_boss/hal_data
- Bare globals still in statusQuo trunk: HAL_Rev, HAL_SuppMed, HAL_SuppFuel, HAL_SuppRep, HAL_SuppAmmo, HAL_SFIdleOrd, HAL_Reloc, HAL_LPos, Desperado, HAL_Garrison, HAL_HQOrders, HAL_HQOrdersDef, HAL_LHQ — Phase 4 scope
- fnc_HQSitRep.sqf line 36 still calls `[[_HQ],HAL_LHQ] call RYD_Spawn` — Phase 4 scope
- hemtt build: zero warnings, zero errors as of commit 3dabd2c

---
*State initialized: 2026-04-09*
*Last updated: 2026-04-10 after 03-03 completion*
