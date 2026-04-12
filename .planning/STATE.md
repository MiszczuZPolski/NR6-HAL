---
gsd_state_version: 1.0
milestone: v1.0
milestone_name: milestone
status: executing
stopped_at: Completed 04-04-PLAN.md
last_updated: "2026-04-11T20:26:39.744Z"
progress:
  total_phases: 5
  completed_phases: 3
  total_plans: 24
  completed_plans: 23
  percent: 96
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

Phase: 04 (variable-namespacing) — EXECUTING
Plan: 0 of 5 (pre-plan tool build) complete
**Phase:** 4 — Variable Namespacing
**Plan:** 04-00 complete (phase4-rename.py tool + README + 14/14 self-test pass)
**Status:** Executing — plans 04-01..04-05 (per-prefix batches) are next, in wave order

**Progress:**

[█████████░] 88%
[Phase 1] Addon Skeleton & Build Foundation   [x] Complete
[Phase 2] Dependency Mapping                  [x] Complete
[Phase 3] Function Extraction                 [x] Complete
[Phase 4] Variable Namespacing                [~] In progress (4/5 batches complete)
[Phase 5] Settings, Localization, Compat      [ ] Not started

```

Overall: 3/5 phases complete (phase 4 in progress — pre-plan tool shipped)

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
| Phase 4 tool: Python single-file rename script | Invoked via `python` on Windows git-bash (`python3` shebang retained for POSIX); see 04-00-SUMMARY for CLI + self-test output |
| Phase 4 owner-inference fallback | When a legacy name has no top-level `NAME =` assignment, tool falls back to first referencing file's addon and records `notes: inferred owner` — prevents None leakage into emitted JSON |
| 04-04 dispatch scope 11->35 | User approved expanding dispatch-site reconstruction from 11 to 35 files at checkpoint |
| 04-04 setRoleCAP/CAS bug fix | User authorized fixing copy-paste bug (_prefix+"NoAttack" -> _prefix+"RCAP"/"RCAS") — only behavior change in Phase 4 |
| 04-04 RydxHQ_ baseline corrected | Actual count is 182, not 157 as reported in 04-03 (grep pattern difference) |
| Phase 04-variable-namespacing P01 | ~900s | 2 tasks | 17 files |
| Phase 04-variable-namespacing P02 | 600s | 2 tasks | 10 files |

### Performance Metrics

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| 04-00 | 256s | 3 | 2 |
| 04-04 | 529s | 3 | 96 |

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

**Stopped at:** Completed 04-02-PLAN.md

**Context for next session:**

- Phase 3 complete (all 7 plans landed including 03-06 gap closure + 03-07 UAT).
- Phase 4 pre-plan tool `scripts/phase4-rename.py` shipped (commit 92cca26); 14/14 self-test passing; `--help`, `--self-test`, and `--root .planning` refusal all verified.
- Plans 04-01..04-05 are the next executable units. Each invokes the tool with `--prefix <batch>` on `addons/`. Order: RYD_ → RHQ_ → RydBB_ → RydHQ_ (largest, includes multi-HQ) → RydxHQ_.
- Python executable note: on this Windows git-bash machine use `python`, not `python3`. Tool shebang is POSIX-compatible.
- Bare globals still in statusQuo trunk: HAL_Rev, HAL_SuppMed, HAL_SuppFuel, HAL_SuppRep, HAL_SuppAmmo, HAL_SFIdleOrd, HAL_Reloc, HAL_LPos, Desperado, HAL_Garrison, HAL_HQOrders, HAL_HQOrdersDef, HAL_LHQ — these are HAL_* (not the Ryd*/RHQ_ family), so they're NOT covered by Phase 4 batches. Carry-over tracking item.

---
*State initialized: 2026-04-09*
*Last updated: 2026-04-10 after 03-03 completion*
