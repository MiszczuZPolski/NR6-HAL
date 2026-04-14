---
phase: 06-drop-compat-code
plan: "01"
subsystem: compat
tags: [compat-removal, atomic-delete, phase6-kickoff]
dependency_graph:
  requires: []
  provides: [compat-deleted, BEHAV-06-baseline-needed]
  affects: [hal_compat_nr6hal PBO removed from build output]
tech_stack:
  added: []
  patterns: [delete-first-fix-on-break]
key_files:
  created:
    - .planning/phases/06-drop-compat-code-we-don-t-need-old-missions-to-work-with-thi/06-01-delete-compat-addon/BASELINE.md
  modified: []
  deleted:
    - addons/compat_nr6hal/$PBOPREFIX$
    - addons/compat_nr6hal/CfgEventHandlers.hpp
    - addons/compat_nr6hal/XEH_PREP.hpp
    - addons/compat_nr6hal/XEH_postInit.sqf
    - addons/compat_nr6hal/XEH_preInit.sqf
    - addons/compat_nr6hal/config.cpp
    - addons/compat_nr6hal/script_component.hpp
decisions:
  - "Delete-first approach confirmed: compat removed atomically, runtime errors drive Plan 06-02 scope"
  - "No sibling requiredAddons cleanup needed: zero references to hal_compat_nr6hal outside the addon itself"
  - "HEMTT config unchanged: compat was auto-discovered, not explicitly listed"
metrics:
  duration: ~5m
  completed: "2026-04-14"
  tasks: 2 (+ 1 human-verify checkpoint pending)
  files: 7 deleted
---

# Phase 6 Plan 1: Delete compat_nr6hal Addon Summary

**One-liner:** Deleted the 588-line postInit alias mirror (7 files, 717 lines) in one atomic, reversible commit — Phase 6 kickoff.

---

## What Was Done

### Task 1: Pre-flight baseline

All gates confirmed green before touching the repo:

| Check | Result |
|-------|--------|
| Static lint (`bash tests/lint-hal.sh`) | EXIT=0, CLEAN (F1/F2/F3 PASS, F4/F5 WARN only — no HIGH severity) |
| HEMTT build | EXIT=0, 9 PBOs, 0 errors, 1 accepted L-S12 at fnc_boss.sqf:1540 |
| Git HEAD (pre-delete) | b1e67f972c055b78b503cceb00eea5a144694a87 |
| Sibling requiredAddons audit | Zero references to `hal_compat_nr6hal` in any other addon's config.cpp |
| HEMTT config audit | No explicit compat_nr6hal listing in .hemtt/project.toml (auto-discovered) |

### Task 2: Atomic delete

**Commit:** `a3c55d578144f86de981b98cf8269ac3ef6d61e1`

**Subject:** `refactor(06-01): delete compat_nr6hal addon (lint: PASS, BEHAV-06: FAIL-EXPECTED)`

**Files deleted (7 files, 717 lines):**

| File | Lines removed |
|------|--------------|
| addons/compat_nr6hal/XEH_postInit.sqf | 588 |
| addons/compat_nr6hal/config.cpp | 89 |
| addons/compat_nr6hal/CfgEventHandlers.hpp | 12 |
| addons/compat_nr6hal/script_component.hpp | 17 |
| addons/compat_nr6hal/XEH_preInit.sqf | 9 |
| addons/compat_nr6hal/XEH_PREP.hpp | 1 |
| addons/compat_nr6hal/$PBOPREFIX$ | 1 |

**Post-delete build:** EXIT=0, 8 PBOs (down from 9), -51.77 KB. Same accepted L-S12 warning. No new errors.

**Post-delete lint:** EXIT=0, identical to pre-delete baseline.

---

## Testing Gate Exception — DOCUMENTED

Per Plan 06-01 Testing Gate section:

> "Plan 06-01 is the ONE commit in Phase 6 where BEHAV-06 is expected to FAIL after the delete."

The commit message suffix `(lint: PASS, BEHAV-06: FAIL-EXPECTED)` is the explicit exception marker. From Plan 06-02 onward, the standard `(lint: PASS, BEHAV-06: PASS)` gate is mandatory. The exception is scoped to this single commit only.

---

## Deviations from Plan

None — plan executed exactly as written. No sibling requiredAddons cleanup was needed (research finding confirmed). No HEMTT config changes were required (auto-discovery confirmed).

---

## Known Predicted Failures (Plan 06-02 Input)

Research identified the following error families that WILL fail after this delete. These are the expected BEHAV-06 and RPT failures the user should capture:

| # | Error Family | Root Cause | Plan 06-02 Fix |
|---|-------------|-----------|---------------|
| 1 | `A_HQSitRep..H_HQSitRep` globals nil | compat XEH_postInit.sqf:69-76 was the only writer | Seed in `addons/core/XEH_postInit.sqf` with isNil guards |
| 2 | `HAL_EnemyScan`, `HAL_Flanking`, `HAL_GoCapture` etc. nil (21 handles, 57 read sites) | compat aliased EFUNC() refs into bare globals; 5 consumer files in hac/common read them | Replace bare HAL_* reads with EFUNC() calls in consumer files |
| 3 | `RydHQ_DbgMon`, `RydHQ_Debug`, `RydHQ_Front` nil | compat aliases; some live code reads them | Rename readers to EGVAR(core,dbgMon) etc. |
| 4 | `RydHQ_Actions/PathFinding/SupportActions` nil | 8 CBA-setting aliases | Rename readers to EGVAR(core,X) |
| 5 | `RydHQ_Art`, `RydHQ_ArtG`, `RydHQ_ArtyMarks` nil | Artillery aliases; mix of CBA settings and bare globals | Rename per case in Plan 06-02 |

These are listed in order of likelihood of being BEHAV-06 assertion failures (highest first).

---

## Next Steps for User

### Task 3 (human action required): Capture the error storm

1. Rebuild the mod with HEMTT:
   ```bash
   hemtt build
   ```

2. Copy `@hal` (or `.hemtt/build/@hal`) to your Arma 3 mods directory if not symlinked.

3. Launch Arma 3 with `@hal` and `@CBA_A3` loaded.

4. Open `test_hal_basic.Stratis` in singleplayer preview.

5. Wait **60 seconds** after mission start for the full HAL init cycle.

6. Open the debug console (Esc → Debug Console) and run:
   ```sqf
   0 = [] execVM "tests\test_BEHAV_06_regression.sqf";
   ```

7. Watch systemChat. Note every `[FAIL]` line. Also check your RPT log at `%LOCALAPPDATA%\Arma 3\*.rpt` for `"Undefined variable in expression"` lines from the first 60 seconds.

8. Append the "Post-delete error storm" section to:
   `.planning/phases/06-drop-compat-code-we-don-t-need-old-missions-to-work-with-thi/06-01-delete-compat-addon/BASELINE.md`

   Use this format:
   ```markdown
   ## Post-delete error storm

   Captured: <date/time>
   Mission: test_hal_basic.Stratis

   ### BEHAV-06 result
   X/Y passed, Z failed

   ### BEHAV-06 failures (verbatim from systemChat)
   - [FAIL] <assertion text>
   ...

   ### RPT "Undefined variable" lines (first 60s after mission start)
   <paste RPT lines>

   ### Error families identified
   - Family A: HAL_* tactical handles (expected — research finding #2)
   - Family B: A..H_HQSitRep dispatch (expected — research finding #1)
   - Family C: <anything else surprising>
   ```

9. Type "baseline captured" or paste the FAIL list directly — Plan 06-02 will use it.

**Rollback:** If the delete caused unexpected build issues (none expected), restore with:
```bash
git revert HEAD
```
This restores all 7 compat files exactly as they were at `b1e67f972c055b78b503cceb00eea5a144694a87`.

---

## Self-Check

Files created:
- `.planning/phases/06-drop-compat-code-.../06-01-delete-compat-addon/BASELINE.md` — EXISTS
- `.planning/phases/06-drop-compat-code-.../06-01-SUMMARY.md` — this file

Commit verified:
- `a3c55d578144f86de981b98cf8269ac3ef6d61e1` — EXISTS (confirmed via git log -1)
- 7 files deleted in one atomic commit — CONFIRMED
- lint: EXIT=0 — CONFIRMED
- hemtt build: EXIT=0 — CONFIRMED

## Self-Check: PASSED
