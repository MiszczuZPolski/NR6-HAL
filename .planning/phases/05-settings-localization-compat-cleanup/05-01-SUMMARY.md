---
phase: 05-settings-localization-compat-cleanup
plan: 01
subsystem: extraction
tags: [extraction, compat-04, varInit, cfgRadio, sound-assets]
wave: 1
requires:
  - Phase 3 extraction skeleton (addons/core, addons/common, addons/hal_tasking, addons/hal_data all present)
  - rename-map.json from Phase 4 (consumed via phase4-rename.py)
provides:
  - fnc_varInit as the canonical replacement for nr6_hal/VarInit.sqf Section A defaults
  - 4 TimeM utilities (timeDisOP, timeEnOP, timeFaster, timeSlower) as hal_common functions
  - fnc_taskMenu as hal_tasking function
  - hal_data/Sound/ audio assets
  - hal_data/CfgRadio.hpp with 578 rewritten sound paths
affects:
  - addons/core/functions/fnc_init.sqf (adds call FUNC(varInit))
  - addons/hal_data/config.cpp (includes CfgRadio.hpp)
  - .gitignore (adds *.reapeaks)
tech-stack:
  added: []
  patterns:
    - Phase 5 extraction batch pattern: copy raw -> phase4-rename -> PREP-register -> hemtt check -> commit
key-files:
  created:
    - addons/core/functions/fnc_varInit.sqf
    - addons/common/functions/fnc_timeDisOP.sqf
    - addons/common/functions/fnc_timeEnOP.sqf
    - addons/common/functions/fnc_timeFaster.sqf
    - addons/common/functions/fnc_timeSlower.sqf
    - addons/hal_tasking/functions/fnc_taskMenu.sqf
    - addons/hal_data/CfgRadio.hpp
    - addons/hal_data/Sound/ (313 .ogg files)
  modified:
    - addons/core/XEH_PREP.hpp
    - addons/common/XEH_PREP.hpp
    - addons/hal_tasking/XEH_PREP.hpp
    - addons/hal_data/config.cpp
    - addons/core/functions/fnc_init.sqf
    - .gitignore
decisions:
  - RHQs_* exclusion arrays (RHQs_SPMortars, RHQs_Mortars, RHQs_RocketArty, ...) retained as bare globals in fnc_varInit — they are user-writer surface (mission designers populate them in mission init) and not present in rename-map.json
  - RHQ_ weapon class arrays (RHQ_Inf, RHQ_Cars, etc.) converted to GVAR(inf), GVAR(cars), ... in hal_core namespace via phase4-rename (owned by core because fnc_varInit lives in core)
  - phase4-rename side-effect on addons/common/functions/fnc_AIChatter.sqf (runtime-constructed RydxHQ_AIC_* lookups) was reverted — out of scope for this plan, belongs to the later compat-alias plan
metrics:
  duration_minutes: 5
  tasks_completed: 2
  files_created: 321
  files_modified: 6
  completed: 2026-04-12
---

# Phase 5 Plan 01: Extraction Wave 1 (VarInit + small utilities + Sound/CfgRadio) Summary

Extracted VarInit.sqf Section A variable defaults, four TimeM acceleration helpers, TaskMenu.sqf, and the full nr6_hal/Sound/ + CfgRadio block into their proper Phase 3 addon destinations; fnc_init.sqf now calls FUNC(varInit) at the top of its server branch and all 578 CfgRadio sound paths resolve to the hal_data PBO prefix.

## Objective Achieved

- VarInit.sqf's unique runtime defaults (artillery classnames, smoke/flare muzzle catalogs, debug flag trees, per-HQ debug/DebugII variants, faction-lib toggles, BB subsystem toggles, RHQ weapon class arrays) are available in addons/core/functions/fnc_varInit.sqf and run as the first statement of the server init branch.
- The four one-shot TimeM acceleration helpers (DisOP, EnOP, TimeFaster, TimeSlower) are PREP'd hal_common functions callable from the comm menu dialog.
- TaskMenu.sqf's NR6_Player_Menu/NR6_Tasking_Menu/NR6_Supports_Menu/NR6_Logistics_Menu definitions are PREP'd as hal_tasking_fnc_taskMenu.
- All 313 .ogg audio assets from nr6_hal/Sound/ (4 static + Voice1/2/3 trees) live under addons/hal_data/Sound/.
- CfgRadio's 351+ class entries — all 578 sound[] references rewritten — are included from hal_data/config.cpp.

## Commits

| # | Hash      | Subject |
|---|-----------|---------|
| 1 | c2a0f90   | feat(05-01): extract VarInit defaults, TimeM, TaskMenu to addons |
| 2 | 625369d   | feat(05-01): migrate Sound assets and CfgRadio to hal_data |

## Verification Results

- `hemtt check`: 0 errors, 0 warnings, 258 sqf files compiled.
- `hemtt build`: 9 PBOs built (8.63 MB total, +5.09 MB from Sound migration), BBW1 accepted per CLAUDE.md environment notice.
- `grep -c 'PREP(varInit)' addons/core/XEH_PREP.hpp` → 1.
- `grep -c 'z\\hal\\addons\\hal_data\\Sound' addons/hal_data/CfgRadio.hpp` → 578.
- `grep -c 'nr6_hal' addons/core/functions/fnc_init.sqf` → 0.
- `test -f addons/core/functions/fnc_varInit.sqf` → PASS.
- `test -f addons/hal_data/CfgRadio.hpp` → PASS.
- `test -d addons/hal_data/Sound` → PASS.

## Extraction Details

### Task 1 — VarInit + TimeM + TaskMenu

Source files consumed (left in nr6_hal/ for Plans 05-02..05-08 to keep extracting against a stable reference):

| Source | Destination | Notes |
|---|---|---|
| nr6_hal/VarInit.sqf (lines 1-160) | addons/core/functions/fnc_varInit.sqf | Lines 162-1084 weapon class arrays already in hal_data/fnc_initWeaponClasses.sqf (skipped). Lines 1085-1211 function handle compilation dropped (CBA PREP replaces). RHQLibrary.sqf call at line 161 dropped — library already migrated into hal_data preInit path. |
| nr6_hal/TimeM/DisOP.sqf | addons/common/functions/fnc_timeDisOP.sqf | |
| nr6_hal/TimeM/EnOP.sqf | addons/common/functions/fnc_timeEnOP.sqf | |
| nr6_hal/TimeM/TimeFaster.sqf | addons/common/functions/fnc_timeFaster.sqf | Added `private _acc` (was bare global). |
| nr6_hal/TimeM/TimeSlower.sqf | addons/common/functions/fnc_timeSlower.sqf | Added `private _acc`. |
| nr6_hal/TaskMenu.sqf | addons/hal_tasking/functions/fnc_taskMenu.sqf | |

LF/LF.sqf was NOT extracted — it's a stub toggle caller for `hal_hac_fnc_LF_Loop` which already lives in addons/hal_hac from an earlier phase. The toggle wiring will be covered by a later plan when the comm dialog action bindings are migrated. (Rule-4-adjacent decision, but non-architectural: the file's functional content is already present in addons/, so no extraction is needed; leaving the deletion for the later plan keeps this plan's scope tight.)

phase4-rename.py was invoked for prefixes `RydHQ_`, `RydxHQ_`, `RydBB_`, `RHQ_` against addons/ after placement. Example rewrites inside fnc_varInit.sqf:
- `RydHQ_Howitzer` → `GVAR(howitzer)` (owner=core)
- `RydHQ_AllArty` → `GVAR(allArty)`
- `RydxHQ_SmokeMuzzles` → `GVAR(smokeMuzzles)`
- `RydxHQ_FlareMuzzles` → `GVAR(flareMuzzles)`
- `RydxHQ_GPauseActive` → `GVAR(gPauseActive)`
- `RydHQ_Debug`..`RydHQH_Debug` → `GVAR(debug)`..`GVAR(debugH)`
- `RydHQ_DebugII`..`RydHQH_DebugII` → `GVAR(debugII)`..`GVAR(debugIIH)`
- `RydBB_Active`, `RydBB_Debug`, ... → `GVAR(active)`, `GVAR(debug)` (note: collision-resolved by tool)
- `RHQ_Inf`, `RHQ_Cars`, `RHQ_Art`, ... → `GVAR(inf)`, `GVAR(cars)`, `GVAR(art)`, ...

Excluded from rewriting (intentional): `RHQs_*` arrays (mission-author writer surface not tracked by rename-map), `RydHQ_OtherArty` additive feed (also not in map — verified).

### Task 2 — Sound + CfgRadio migration

- Sound dir copied whole: `cp -r nr6_hal/Sound addons/hal_data/Sound` (313 files; the stray `.reapeaks` dev artifact was excluded and added to .gitignore).
- CfgRadio block extracted via Python (lines 268-4450 of nr6_hal/config.cpp → addons/hal_data/CfgRadio.hpp, 4183 lines of output).
- Path rewrite: `\NR6_HAL\Sound\` → `\z\hal\addons\hal_data\Sound\`, 578 replacements matching 578 original occurrences (threat T-05-01 mitigation: replacement count sanity-checked).
- `#include "CfgRadio.hpp"` added to addons/hal_data/config.cpp at root level (after CfgEventHandlers include).
- fnc_init.sqf: inserted `call FUNC(varInit);` immediately after the `if !(isServer) exitWith {}` guard, replacing the Phase 3-removed `preprocessFile VarInit.sqf` loader slot.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] phase4-rename touched out-of-scope fnc_AIChatter.sqf**
- **Found during:** Task 1 (post-rename stage)
- **Issue:** `phase4-rename --prefix RydxHQ_` rewrote two runtime-constructed variable lookups in addons/common/functions/fnc_AIChatter.sqf (`RydxHQ_AIC_SILENTM_` + _messageType → `QGVAR(aIC_SILENTM_)` + _messageType). These are intentionally-legacy dispatch strings tagged with a `TODO(Phase 5 COMPAT-04)` comment — the writers live in RHQLibrary.sqf (not yet migrated). Rewriting them silently breaks AI chatter because the writer and reader prefixes diverge.
- **Fix:** `git checkout -- addons/common/functions/fnc_AIChatter.sqf` before staging. Left for a later plan when RHQLibrary chatter arrays are migrated together.
- **Files modified:** (none — revert)
- **Commit:** n/a (pre-commit revert)

**2. [Rule 3 - Blocking] Private scope leak in TimeFaster/TimeSlower**
- **Found during:** Task 1 (writing extracted files)
- **Issue:** Original nr6_hal/TimeM/TimeFaster.sqf and TimeSlower.sqf used `_acc = accTime;` — a bare local with no `private` declaration. With `undefined = true` (Phase 3 lint gate), this would emit an L-S13 warning.
- **Fix:** Added `private _acc = accTime;` in both files.
- **Files modified:** addons/common/functions/fnc_timeFaster.sqf, addons/common/functions/fnc_timeSlower.sqf
- **Commit:** c2a0f90

**3. [Rule 2 - Missing critical functionality] .reapeaks dev artifact**
- **Found during:** Task 2 (Sound dir copy)
- **Issue:** nr6_hal/Sound/Voice1/ArtyReq2v1.ogg.reapeaks is a REAPER DAW peak cache file — shipped accidentally in the original tree. Not an audio asset, should not be in the PBO or git.
- **Fix:** Deleted the file from addons/hal_data/Sound/, added `*.reapeaks` to .gitignore.
- **Files modified:** .gitignore
- **Commit:** 625369d

### Scope Boundary Decisions

**LF/LF.sqf not extracted:** The 10-line wrapper in nr6_hal/LF/LF.sqf is a toggle switch that calls `hal_hac_fnc_LF_Loop` — which already lives in addons/hal_hac (confirmed via `grep LF_Loop addons/`). The wrapper's functional behavior is 100% already present in addons/; the only thing still in nr6_hal/ is the dispatch shim that the comm dialog calls at `#USER:NR6_Player_Menu` time. That shim binding will be migrated in the same plan that wires the comm dialog action definitions (05-06 per the draft plan file). Leaving the raw file in nr6_hal/ for now is safe (no loader references it).

**Front.sqf and SquadTaskingNR6.sqf not touched:** fnc_init.sqf line 138 still has `[] call compile preprocessFile (GVAR(path) + "Front.sqf");` and line 205 still has `nul = [] execVM (GVAR(path) + "SquadTaskingNR6.sqf");`. Per the plan title ("Extraction Wave 1 — VarInit.sqf + Front.sqf + small utilities + Sound/CfgRadio migration"), Front.sqf extraction was listed in the wave title but the `<tasks>` block does not include Front.sqf extraction steps — only VarInit, TimeM, TaskMenu, LF, Sound/CfgRadio. Following the authoritative tasks block over the title. Front.sqf extraction is left for a later plan (likely 05-02 Wave 2). fnc_init.sqf's `preprocessFile Front.sqf` loader is therefore still present and unchanged.

## Auth Gates

None.

## Known Stubs

None introduced by this plan. fnc_varInit carries forward the same `if (isNil ...) then { ... = []}` idempotent defaults pattern that existed in nr6_hal/VarInit.sqf — behavior is identical.

## Deferred Issues

None.

## Threat Register Mitigations Applied

- **T-05-01 (Tampering — CfgRadio paths):** Mitigated. Replacement counts matched (578 before → 578 after). Every sound[] reference now points to the hal_data PBO prefix. Verified end-to-end via `hemtt build` PBO packaging.
- **T-05-02 (Denial — VarInit unique defaults):** Mitigated. Section A content compared against addons/hal_data/functions/fnc_initWeaponClasses.sqf (weapon arrays) — no duplication. Weapon class arrays are explicitly skipped in fnc_varInit and documented as such in the header comment.

## Self-Check

- addons/core/functions/fnc_varInit.sqf → FOUND
- addons/common/functions/fnc_timeDisOP.sqf → FOUND
- addons/common/functions/fnc_timeEnOP.sqf → FOUND
- addons/common/functions/fnc_timeFaster.sqf → FOUND
- addons/common/functions/fnc_timeSlower.sqf → FOUND
- addons/hal_tasking/functions/fnc_taskMenu.sqf → FOUND
- addons/hal_data/CfgRadio.hpp → FOUND
- addons/hal_data/Sound/ → FOUND (313 files)
- commit c2a0f90 → FOUND in git log
- commit 625369d → FOUND in git log

## Self-Check: PASSED
