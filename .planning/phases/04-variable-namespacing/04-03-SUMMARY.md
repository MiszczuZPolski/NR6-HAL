---
phase: 04-variable-namespacing
plan: 03
subsystem: variable-namespacing
tags: [rename, prefix-batch, RydBB_, GVAR, EGVAR, wave-3, missionmodules, dispatch-rewrite]
requires:
  - 04-00 (phase4-rename.py tool)
  - 04-01 (wave-1 RYD_ batch + tool hardening)
  - 04-02 (wave-2 RHQ_ batch, baselines carry-forward)
  - 04-CONTEXT.md D-01..D-06
provides:
  - .planning/phases/04-variable-namespacing/rename-map-rydbb.json
  - .planning/phases/04-variable-namespacing/owner-overrides-rydbb.json
  - .planning/phases/04-variable-namespacing/manual-sites-rydbb.md
  - .planning/phases/04-variable-namespacing/stale-comments-rydbb.md
  - unchanged companion-prefix baselines for 04-04 and 04-05
affects:
  - addons/common/ (1 file)
  - addons/core/ (1 file)
  - addons/hal_boss/ (7 files)
  - addons/hal_hac/ (1 file)
  - addons/missionmodules/ (4 files, owner)
tech-stack:
  added: []
  patterns: [GVAR, EGVAR, QGVAR, QEGVAR, dispatch-site-rewrite]
key-files:
  created:
    - .planning/phases/04-variable-namespacing/rename-map-rydbb.json
    - .planning/phases/04-variable-namespacing/owner-overrides-rydbb.json
    - .planning/phases/04-variable-namespacing/manual-sites-rydbb.md
    - .planning/phases/04-variable-namespacing/stale-comments-rydbb.md
  modified:
    - addons/common/functions/fnc_DbgMon.sqf
    - addons/core/functions/fnc_init.sqf
    - addons/hal_boss/functions/fnc_BBSimpleD.sqf
    - addons/hal_boss/functions/fnc_executeObj.sqf
    - addons/hal_boss/functions/fnc_executePath.sqf
    - addons/hal_boss/functions/fnc_isOnMap.sqf
    - addons/hal_boss/functions/fnc_objMark.sqf
    - addons/hal_boss/functions/fnc_objectivesMon.sqf
    - addons/hal_boss/functions/fnc_reserveExecuting.sqf
    - addons/hal_hac/functions/fnc_statusQuo_doctrine.sqf
    - addons/missionmodules/CfgVehicles.hpp
    - addons/missionmodules/functions/fnc_bbLeader.sqf
    - addons/missionmodules/functions/fnc_bbSettings.sqf
    - addons/missionmodules/functions/fnc_bbZone.sqf
decisions:
  - "bbZone dispatch site rewritten to `GVAR(mC) = _trig;` (direct assignment, not trigger-scoped setVariable). Verified by inspecting the sole reader (`isNil \"RydBB_MC\"` in hal_boss/fnc_isOnMap.sqf) — it treats RydBB_MC as a mission global, not a trigger attribute."
  - "Owner-override file required for 7 of 11 names. Default inference fell through to hal_boss (the readers) and common (fnc_DbgMon reader of RydBB_mapReady). Plan design pins all 11 to missionmodules as canonical owner (the Big Boss module family). Override file landed atomically with the rename commit."
  - "Added `#include \"..\\script_component.hpp\"` to 3 missionmodules functions (bbZone, bbLeader, bbSettings) that had no prior macro usage. Rule 3 blocking-issue fix — without the include the GVAR/QGVAR expansions were treated as SQF function calls and failed to parse."
  - "Pre-existing reserveExecuting.sqf:31 variable-name bug (`_alive` vs `_aliveHQ` in a RydBB_Active case arm) preserved verbatim. Rewrite was strictly mechanical: `RydBB_Active` → `EGVAR(missionmodules,active)`. Same bug, new macro. Flagged for a future plan."
metrics:
  duration: ~800s
  completed: 2026-04-11
  unique_legacy_names: 11
  files_modified_in_addons: 14
  rename_map_entries: 11
  dispatch_sites_whitelisted: 1
  tool_bugs_fixed: 0
  commits: 1
requirements: [VAR-01, VAR-02, VAR-03, VAR-04]
---

# Phase 04 Plan 03: Wave-3 RydBB_ prefix rename Summary

One-liner: Atomically rewrote all 11 unique `RydBB_*` legacy identifiers (Big Boss high-commander module state) under `addons/` to `GVAR(...)` inside `missionmodules` and `EGVAR(missionmodules,...)` in cross-addon readers across 14 files, including one hand-rewritten `call compile` dispatch site in `fnc_bbZone.sqf` and a curated owner-override file pinning all 11 names to `missionmodules`.

## What shipped

- **14 addon source files rewritten** — every non-comment `RydBB_*` code reference is now a CBA macro. Zero code-line residuals.
- **1 hand-rewritten dispatch site** — `addons/missionmodules/functions/fnc_bbZone.sqf` line 10: the string-composed `_trig call compile ("RydBB_MC" + " = _this")` became `GVAR(mC) = _trig;` with an added `#include "..\script_component.hpp"`. Chosen form validated by grep of all readers.
- **`rename-map-rydbb.json`** — 11 entries, schema-valid (`phase-4-rename-map-v1`), `prefix_batch: RydBB_`, every entry `addon_owner: missionmodules` and `stripped: false`. Ready for Phase 5 compat alias generation.
- **`owner-overrides-rydbb.json`** — 7-entry override file pinning the reader-only RydBB_ names to `missionmodules`. Committed alongside the rename.
- **`manual-sites-rydbb.md`** / **`stale-comments-rydbb.md`** — emitted by the tool (0 unresolved manual-review entries after the bbZone hand-edit; 0 stale-comment flags).
- **Single atomic commit `4d8bc9b`** — 18 files changed, 63 insertions, 33 deletions. Addons/ rewrites, CfgVehicles.hpp class-name updates, the bbZone hand-edit, include additions, rename-map, override file, and report files all landed together per D-03.

## Rename breakdown

| Legacy name | New macro | Owner | Resolution |
|---|---|---|---|
| RydBB_Active | GVAR(active) | missionmodules | native (fnc_bbLeader.sqf has top-level assignment) |
| RydBB_CustomObjOnly | GVAR(customObjOnly) | missionmodules | native (fnc_bbSettings.sqf) |
| RydBB_LRelocating | GVAR(lRelocating) | missionmodules | native (fnc_bbSettings.sqf) |
| RydBB_MainInterval | GVAR(mainInterval) | missionmodules | native (fnc_bbSettings.sqf) |
| RydBB_Debug | GVAR(debug) | missionmodules | override (reader-only in addons/, writer in nr6_hal/) |
| RydBB_MC | GVAR(mC) | missionmodules | override (reader-only after bbZone hand-edit's direct write) |
| RydBB_MapXMax | GVAR(mapXMax) | missionmodules | override (reader-only) |
| RydBB_MapXMin | GVAR(mapXMin) | missionmodules | override (reader-only) |
| RydBB_MapYMax | GVAR(mapYMax) | missionmodules | override (reader-only) |
| RydBB_MapYMin | GVAR(mapYMin) | missionmodules | override (reader-only) |
| RydBB_mapReady | GVAR(mapReady) | missionmodules | override (reader-only) |

## Tool behaviour this batch

- **No new bugs surfaced.** Phase4-rename.py ran cleanly on first dry-run attempt. Self-test 14/14 unchanged.
- **Dispatch-site whitelist worked as designed.** The `--allow-dispatch-file` flag accepted the hand-rewritten bbZone.sqf path; after the hand-edit removed the last `RydBB_*` token from that file, the tool passed it through with no further mutations.
- **Owner-override required for 7 of 11 names.** These names are only READ in `addons/`; their writers live in legacy `nr6_hal/Boss.sqf` (and in the case of `RydBB_MC`, are now assigned in `addons/missionmodules/functions/fnc_bbZone.sqf` via the hand-edit, which the tool's top-level-assignment scanner did not recognize because it is wrapped in a conditional control-flow path). Default inference fell through to `hal_boss` (first referring addon for 6 names) and `common` (for RydBB_mapReady). The override file pins all 7 to `missionmodules` per the plan's `key_links` design.
- **Double-hal_ expansion accepted.** `GVAR(active)` inside missionmodules expands to `hal_missionmodules_active` — external readers emit the same string via `EGVAR(missionmodules, active)`. Cosmetic only.

## Companion-prefix baseline verification (unchanged from 04-02)

Verified using the 04-02 measurement method (`grep -rE '\b<prefix>' addons/ --include='*.sqf' | wc -l`):

| Prefix | Baseline (from 04-02 commit) | After 04-03 | Delta |
|---|---|---|---|
| `RYD_` | 100 (raw, comment-only) | 100 | 0 |
| `RHQ_` | 2 (raw, comment-only) | 2 | 0 |
| `RydBB_` | 33 | **3 (raw, comment-only)** | -30 (target for this batch) |
| `RydHQ_` | 1124 | 1124 | 0 |
| `RydxHQ_` | 157 | 157 | 0 |

The 3 comment-only `RydBB_` residuals:

1. `addons/hal_boss/functions/fnc_objectivesMon.sqf:9` — JSDoc `* @return` prose referring to "while RydBB_Active"
2. `addons/hal_boss/functions/fnc_objMark.sqf:7` — JSDoc `* @return` prose referring to "RydBB_Active and RydBB_Debug"
3. `addons/missionmodules/functions/fnc_bbSettings.sqf:10` — `//RydBB_BBOnMap = (_logic getVariable "RydBB_BBOnMap");` (commented-out dead assignment matching the commented-out config class below)

Plus one raw `.hpp` residual not caught by the sqf-only grep:

4. `addons/missionmodules/CfgVehicles.hpp:2708` — `class RydBB_BBOnMap` inside a `/* ... */` block comment (dead config class, matches the commented-out reader on line 10 of fnc_bbSettings.sqf)

All 4 residuals are comment-only, acceptable per D-05/D-06 (consistent with 04-02's handling of the 2 RHQ_ JSDoc residuals). `RydBB_BBOnMap` itself is a dead name — still assigned in `nr6_hal/VarInit.sqf:57` and read in `nr6_hal/Boss.sqf:1998`, but both of its `addons/` references are commented out, so it never surfaces in this rename batch. Phase 5 compat-addon work will handle the legacy writes.

These counts become the new baseline for 04-04 and 04-05 to regression-check against.

## Build gate

- `hemtt build`: exit 0
- L-S/L-C warnings: 0
- `error[SPE2]` errors: 0 (initial build raised SPE2 on bbSettings.sqf and bbLeader.sqf because both files had no `script_component.hpp` include — fixed inline under Rule 3)
- BBW1: present (accepted environment notice per CLAUDE.md)
- Post-commit residual scan: `grep -rnE '\bRydBB_[A-Za-z]' addons/` → 4 lines, all in comments (2 JSDoc, 1 SQF line comment, 1 HPP block comment)

## Deviations from Plan

### [Rule 3 — Blocking issue] Missing script_component.hpp includes in 3 missionmodules functions

- **Found during:** first `hemtt build` after tool apply
- **Issue:** `fnc_bbSettings.sqf`, `fnc_bbLeader.sqf`, and `fnc_bbZone.sqf` had no `#include "..\script_component.hpp"` directive because their pre-rename code contained no macros — they were pure legacy-global SQF. After the tool rewrote `RydBB_X` to `GVAR(x)`, the SQF preprocessor saw an undefined `GVAR` identifier and parsed `GVAR(active) = true` as a function call rather than a macro expansion, which is not valid SQF (emits `SPE2: SQF Syntax could not be parsed`).
- **Fix:** Added `#include "..\script_component.hpp"` at the top of each of the 3 files (inserted above the existing `private [...]` declaration). This pulls in the COMPONENT-aware GVAR/QGVAR macros via the standard CBA `script_macros.hpp` include chain.
- **Files modified:** `addons/missionmodules/functions/fnc_bbZone.sqf`, `fnc_bbLeader.sqf`, `fnc_bbSettings.sqf`
- **Commit:** 4d8bc9b (same atomic commit as the rename — fix landed before the commit was written)
- **Note:** Pre-existing condition — the missionmodules addon has many functions that do have the include (e.g., fnc_addLeader, fnc_front, fnc_garrison per head-of-file grep), but these 3 functions slipped through because their author never used macros. 04-01 and 04-02 did not hit this because every file they modified already had the include. This is likely to recur in 04-04 / 04-05; worth a pre-scan check in those plans.

### [design] Owner-override file required for 7 of 11 names

- **Plan expectation:** All RydBB_ names should be `addon_owner: missionmodules`.
- **Tool default inference:** Fell through to `hal_boss` for 6 names (RydBB_Debug, RydBB_MC, RydBB_MapXMax, RydBB_MapXMin, RydBB_MapYMax, RydBB_MapYMin) and `common` for 1 (RydBB_mapReady) — because these names have no top-level `NAME =` assignment anywhere in `addons/` (their writers live in `nr6_hal/Boss.sqf`, and `RydBB_MC`'s new writer in bbZone is inside a conditional scope that the tool's top-level scanner doesn't enter).
- **Fix:** Created `owner-overrides-rydbb.json` with 7 entries pinning each to `missionmodules`. Re-ran the tool with `--owner-override`; Task 1 automated gate now passes (`all e.addon_owner == missionmodules`).
- **Design note:** Same pattern as 04-02's 28-name override. The root cause is the `addons/` tree being read-mostly for names that `nr6_hal/` assigns. Expected to recur in 04-04 / 04-05 for names whose writers live in `nr6_hal/`.

### [design] bbZone dispatch site rewritten to direct mission-global assignment

- **Plan text:** Offered two candidate rewrites: `GVAR(mC) = _this;` (mission global) vs `_trig setVariable [QGVAR(mC), _this];` (trigger-scoped). Research Q7 favored the former.
- **Executed form:** `GVAR(mC) = _trig;` (direct mission-global assignment of the trigger object).
- **Why `_trig` and not `_this`:** Inside the original `_trig call compile ("RydBB_MC" + " = _this")`, the compiled code's `_this` is the receiver of `call compile`, which is `_trig`. Removing the `call compile` wrapper shifts back to file scope where `_this` is the original params array `[_logic]` — so a literal replacement would silently change semantics. The correct transliteration is `GVAR(mC) = _trig;`.
- **Why mission global (not trigger setVariable):** The sole reader in `addons/hal_boss/functions/fnc_isOnMap.sqf:18` uses `if !(isNil "RydBB_MC")` — a mission-namespace isNil check, which only works on a mission global, not on a trigger-scoped variable. Trigger setVariable would break this reader.

## Known stubs / deferred items

- **JSDoc RydBB_Active / RydBB_Debug mentions** (2 lines) in hal_boss fnc_objectivesMon.sqf and fnc_objMark.sqf — descriptive prose, preserved per D-05/D-06. A future cleanup pass may modernize these docstrings.
- **Commented-out RydBB_BBOnMap config class and reader** in CfgVehicles.hpp (line 2708, inside `/* */`) and fnc_bbSettings.sqf line 10 (`//RydBB_BBOnMap...`). The legacy `nr6_hal/VarInit.sqf:57` still assigns `RydBB_BBOnMap = false`, and `nr6_hal/Boss.sqf:1998` reads it. Phase 5 compat addon planning needs to either delete the legacy writes (if the feature is truly dead) or restore the addons/ class + reader. Not this plan's concern.
- **Runtime assignment of 7 RydBB_ names still lives in `nr6_hal/`** — same situation as 04-01's `RYD_WS_NCrewInf_class` and 04-02's 28 RHQ_ names. Phase 5 compat addon will either alias them or rewire the legacy writers to the new `hal_missionmodules_*` mission-namespace names.
- **Three missionmodules .sqf files without `#include "..\script_component.hpp"`** were the cause of the Rule 3 blocker. There may be other macro-less functions in other addons that will hit the same snag during 04-04 / 04-05. Consider pre-scanning for missing includes in those plans.

## Verification

- [x] Pre-commit dry-run reviewed and approved (11 unique names, 13+1 files, 260-line diff)
- [x] bbZone dispatch site hand-rewritten; tool passed through the whitelisted file unchanged
- [x] Task 1 automated gate: `rename-map-rydbb.json` exists, 11 entries, all `addon_owner: missionmodules`, all `stripped: false` — PASS
- [x] Zero residual `RydBB_[A-Za-z]` in non-comment code after apply (4 comment-only residuals preserved)
- [x] Zero residual `RYD_[A-Za-z]` in non-comment code (04-01 territory unchanged)
- [x] Zero residual `RHQ_[A-Za-z]` in non-comment code (04-02 territory unchanged)
- [x] `RydHQ_` = 1124 (unchanged from 04-02 baseline)
- [x] `RydxHQ_` = 157 (unchanged from 04-02 baseline)
- [x] `hemtt build` clean (exit 0, 0 L-S/L-C warnings, BBW1 accepted)
- [x] `rename-map-rydbb.json` committed, schema-valid, all 11 entries `addon_owner: missionmodules`, all `stripped: false`
- [x] `owner-overrides-rydbb.json` committed (7 entries, all → missionmodules)
- [x] `manual-sites-rydbb.md` and `stale-comments-rydbb.md` committed
- [x] Atomic single commit per D-03 (4d8bc9b, 18 files, 63/-33 lines)
- [x] Pre-existing reserveExecuting.sqf:31 bug preserved verbatim

## Confirmed baselines for 04-04 and 04-05

| Prefix | Count (04-02 method: `grep -rE '\b<P>' addons/ --include='*.sqf' \| wc -l`) |
|---|---|
| `RYD_` | 100 (raw, comment-only) |
| `RHQ_` | 2 (raw, comment-only) |
| `RydBB_` | **3** (raw, comment-only — closed) |
| `RydHQ_` | **1124** (04-04 target — must reach 0) |
| `RydxHQ_` | **157** (04-05 target — must reach 0) |

## Threat surface scan

No new network endpoints, auth surface, schema changes, or file access patterns introduced. Pure identifier rewrite plus one mechanical dispatch-site reconstruction (same semantics, eliminates a `call compile` hotspot).

## Self-Check: PASSED

- `.planning/phases/04-variable-namespacing/rename-map-rydbb.json` — FOUND
- `.planning/phases/04-variable-namespacing/owner-overrides-rydbb.json` — FOUND
- `.planning/phases/04-variable-namespacing/manual-sites-rydbb.md` — FOUND
- `.planning/phases/04-variable-namespacing/stale-comments-rydbb.md` — FOUND
- Commit `4d8bc9b` — FOUND (git log HEAD confirms)
- `hemtt build` — exit 0, 0 L-S/L-C warnings
- Residual `RydBB_[A-Za-z]` in code — 0 (4 comment-only preserved, all enumerated above)
- Companion prefixes — unchanged (RYD_=100, RHQ_=2, RydHQ_=1124, RydxHQ_=157)
