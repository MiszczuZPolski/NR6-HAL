---
phase: 04-variable-namespacing
plan: 01
subsystem: variable-namespacing
tags: [rename, prefix-batch, RYD_, GVAR, tool-shakedown, wave-1]
requires:
  - 04-00 (phase4-rename.py tool)
  - 04-CONTEXT.md D-01..D-06
  - 04-RESEARCH.md Q6 (tool), Q8 (pre-commit gate), Q10 (JSON schema)
provides:
  - .planning/phases/04-variable-namespacing/rename-map-ryd.json
  - .planning/phases/04-variable-namespacing/manual-sites-ryd.md
  - .planning/phases/04-variable-namespacing/stale-comments-ryd.md
  - baseline companion-prefix counts for plans 04-02..04-05
affects:
  - addons/common/ (6 files rewritten)
  - addons/core/ (2 files rewritten)
  - addons/hal_data/ (2 files rewritten)
  - addons/hal_hac/ (2 files rewritten)
  - addons/hal_tasking/ (5 files rewritten)
tech-stack:
  added: []
  patterns: [GVAR, EGVAR, QGVAR, QEGVAR]
key-files:
  created:
    - .planning/phases/04-variable-namespacing/rename-map-ryd.json
    - .planning/phases/04-variable-namespacing/manual-sites-ryd.md
    - .planning/phases/04-variable-namespacing/stale-comments-ryd.md
  modified:
    - .planning/phases/04-variable-namespacing/scripts/phase4-rename.py
    - addons/common/functions/fnc_TimeMachine.sqf
    - addons/common/functions/fnc_WPSync.sqf
    - addons/common/functions/fnc_cff_ffe.sqf
    - addons/common/functions/fnc_groupMarkerLoop.sqf
    - addons/common/functions/fnc_liveFeed.sqf
    - addons/common/functions/fnc_rhqCheck.sqf
    - addons/core/functions/fnc_HQSitRep.sqf
    - addons/core/functions/fnc_init.sqf
    - addons/hal_data/functions/fnc_initWeaponClasses.sqf
    - addons/hal_data/functions/fnc_presentRHQ.sqf
    - addons/hal_hac/functions/fnc_statusQuo_classifyEnemies.sqf
    - addons/hal_hac/functions/fnc_statusQuo_classifyFriends.sqf
    - addons/hal_tasking/functions/fnc_action10ct.sqf
    - addons/hal_tasking/functions/fnc_action11ct.sqf
    - addons/hal_tasking/functions/fnc_action12ct.sqf
    - addons/hal_tasking/functions/fnc_action13ct.sqf
    - addons/hal_tasking/functions/fnc_action9ct.sqf
decisions:
  - "Tool bugs fixed in-flight and landed in the same atomic commit as the rename batch (D-03 granularity preserved — rewrite is still one commit)"
  - "Comment-only RYD_ references in JSDoc and credit-blocks left alone (D-05/D-06 posture); only non-comment code lines must be zero"
  - "RYD_WS_NCrewInf_class (read-only in addons/, never assigned) retained as GVAR(wS_NCrewInf_class) owned by hal_hac — runtime value depends on legacy nr6_hal/ assignment, pre-existing condition, no behavior change"
metrics:
  duration: ~900s
  completed: 2026-04-11
  unique_legacy_names: 36
  files_modified_in_addons: 17
  rename_map_entries: 36
  dispatch_sites_whitelisted: 0
  tool_bugs_fixed: 3
  commits: 1
requirements: [VAR-01, VAR-02, VAR-03, VAR-04]
---

# Phase 04 Plan 01: Wave-1 RYD_ prefix rename Summary

One-liner: Atomically rewrote all 36 unique `RYD_*` legacy identifiers under `addons/` to CBA `GVAR`/`EGVAR`/`QGVAR`/`QEGVAR` macro forms in 17 files, emitting `rename-map-ryd.json` for Phase 5, and surfaced-and-fixed 3 latent bugs in `phase4-rename.py` during its first real run.

## What shipped

- **17 addon source files rewritten.** Every non-comment `RYD_*` code reference is now a CBA macro. Zero residual `RYD_[A-Za-z]` lines remain in code (comment-only historical mentions are preserved per D-05/D-06 posture).
- **`rename-map-ryd.json`** — 36 entries, schema-valid (`phase-4-rename-map-v1`), `prefix_batch: RYD_`, every entry `stripped: false` per D-06. Ready for Phase 5 compat alias generation.
- **`manual-sites-ryd.md`** — 0 dispatch sites, 1 stale-comment-substring flag in `fnc_initWeaponClasses.sqf` JSDoc (comment-only, acceptable).
- **`stale-comments-ryd.md`** — same single JSDoc flag.
- **Phase4-rename.py tool hardened** by three bug fixes (see Deviations).
- **Single atomic commit `07d4475`** — 21 files changed, 1809 insertions, 183 deletions. Addons/ rewrites, rename-map, reports, and the tool fixes all landed together per D-03.

## Rename breakdown (by owner)

| Owner | Count | Notes |
|---|---|---|
| hal_data | 31 | The `RYD_WS_*` weapon-classification arrays (the bulk of the batch). All assigned in `fnc_initWeaponClasses.sqf` and read widely. Rendered as `EGVAR(hal_data,wS_<name>)` from external addons. |
| core | 2 | `RYD_Path` (base-mod path string) and `RYD_WS_ArtyMarks` (boolean flag). `fnc_init.sqf` owns both top-level assignments. |
| common | 2 | `RYD_Attacks` and `RYD_ItsMyMark` — object-scope `setVariable` keys with no mission-namespace assignment anywhere. Fallback-inferred owner = first referring file's addon (`common`). Rendered as `QGVAR(attacks)` / `QGVAR(itsMyMark)` string literals per D-01. |
| hal_hac | 1 | `RYD_WS_NCrewInf_class` — read-only in `addons/`, never assigned. Rendered as `GVAR(wS_NCrewInf_class)` owned by hal_hac via fallback inference. Runtime value depends on legacy `nr6_hal/` assignment (pre-existing condition, no behavior change). |
| **Total** | **36** | |

## Companion-prefix baseline counts (for 04-02..04-05 regression gates)

Captured post-commit via `grep -rE '\b<prefix>' addons/ --include='*.sqf' | wc -l`:

| Prefix | Occurrences | Wave | Plan |
|---|---|---|---|
| `RYD_` | **0** (code) / 100 (incl. comments) | 1 | 04-01 (this plan) |
| `RHQ_` | 114 | 2 | 04-02 |
| `RydBB_` | 33 | 3 | 04-03 |
| `RydHQ_` | 1124 | 4 | 04-04 (biggest, multi-HQ) |
| `RydxHQ_` | 157 | 5 | 04-05 |

Subsequent plans must check their own baselines against these before committing and verify no unintended cross-prefix touches.

## Build gate

- `hemtt build`: exit 0
- L-S/L-C warnings: 0
- BBW1: present (accepted environment notice)
- Post-commit residual scan: `grep -rnE '\bRYD_[A-Za-z]' addons/ | grep -v comments` → 0 lines

## Deviations from Plan

### [Rule 1 - Bug] Tool: `detect_dispatch_files` false-positives

- **Found during:** Task 1 first dry-run
- **Issue:** The dispatch-site detector flagged 35 files under `addons/missionmodules/functions/` because it matched `call compile (RYD_Path + "foo.sqf")` as runtime variable-name dispatch. Those are actually `call compile preprocessFile (_path + "file")` style file-content loaders where `RYD_Path` is a *data string global* (the base-mod path). The detector's regex also trips on `_prefix + ...` for any batch, but that runtime-prefix pattern only ever constructs multi-HQ `RydHQ[B-H]_Name` identifiers — not relevant to the RYD_ batch.
- **Fix:** Rewrote `detect_dispatch_files` to (a) exclude `call compile preprocessFile[LineNumbers]` entirely (file-content loaders, not identifier eval), (b) require a direct `"<prefix>..."` string literal inside the `call compile (...)` parens for non-RydHQ_ batches, and (c) only enable the `_prefix +` pattern for the `RydHQ_` batch per D-02.
- **Files modified:** `.planning/phases/04-variable-namespacing/scripts/phase4-rename.py` (function `detect_dispatch_files`)
- **Commit:** 07d4475

### [Rule 1 - Bug] Tool: `rewrite_text` KeyError on missing macro fields

- **Found during:** Task 1 first dry-run (second attempt, after the dispatch-site fix)
- **Issue:** `rewrite_text` reads `entry["new_macro_owner_form"]` / `new_macro_extern_form` / `new_q_macro_*` directly from the in-memory `rename_map`, but `scan_map` returns entries WITHOUT those fields — they're only materialized inside `materialize_map_json()` at JSON-emission time, AFTER the rewrite pass. Result: `KeyError: 'new_macro_owner_form'` on the first identifier found in a code span.
- **Fix:** In `main()`, after `scan_map` returns and before the rewrite pass, iterate every entry and `entry.update(canonical_macros(...))`. This populates all six macro-form fields on each in-memory entry. `materialize_map_json` continues to work because those same keys are what it reads.
- **Files modified:** `.planning/phases/04-variable-namespacing/scripts/phase4-rename.py` (`main` function)
- **Commit:** 07d4475

### [Rule 1 - Bug] Tool: `classify_scope` line-global vs position-relative

- **Found during:** Task 1 first successful dry-run (map review)
- **Issue:** The line `RYD_WS_ArtyMarks = missionNamespace getVariable ["RYD_WS_ArtyMarks",false];` contains the name twice — once as a LHS assignment, once as a getVariable key-string. `classify_scope` used line-global `re.search` to detect scopes, so BOTH matches were classified as `getVariable_key`. The LHS `global_assignment` scope was missed, and owner inference fell through to the fallback path, picking `common` (first referring file) instead of `core` (where the actual top-level assignment lives). Downstream: the rewrite emitted `EGVAR(common,wS_ArtyMarks)` in `core/functions/fnc_init.sqf` — an `EGVAR` pointing at the wrong addon — which would have compiled but referenced a variable nobody assigns.
- **Fix:** Rewrote `classify_scope` to use the position-relative `before` substring (chars on the same line up to the match start) instead of line-global searches. The `setVariable[ "…`, `getVariable[ "…`, `publicVariable "…`, `isNil "…` wrappers are detected only when they appear IMMEDIATELY before the match. `global_assignment` is detected by checking that `before` is whitespace-only AND the chars AFTER the match match `\s*=(?!=)`.
- **Result:** `RYD_WS_ArtyMarks` now correctly owned by `core`. All four scopes (`global_assignment`, `global_read`, `getVariable_key`, `publicVariable_string`) are captured. The `fnc_init.sqf` rewrite now emits `GVAR(wS_ArtyMarks) = ... getVariable [QGVAR(wS_ArtyMarks), false]; publicVariable QGVAR(wS_ArtyMarks)`.
- **Files modified:** `.planning/phases/04-variable-namespacing/scripts/phase4-rename.py` (`classify_scope` function)
- **Commit:** 07d4475

### [design] Report filename case vs plan spec

- **Plan expected:** `manual-sites-RYD_.md` / `stale-comments-RYD_.md`
- **Tool emits:** `manual-sites-ryd.md` / `stale-comments-ryd.md` (lowercased, trailing underscore stripped)
- **Why:** The tool normalizes the filename for cross-platform safety. Cosmetic mismatch only, no content impact.
- **Action:** Committed under the tool's emitted name; subsequent plans should reference `manual-sites-<lowercased-prefix>.md` in their plan text.

### [design] Tool fixes landed in same commit as the rename batch

- **Tension:** D-03 says "one atomic commit per prefix". The tool fixes technically could have been a separate chore commit.
- **Decision:** Kept them in the same commit. Without the fixes, the rewrite pass would not have produced correct output, so the fixes are an intrinsic part of making this batch work. Separating would have inflated the history without improving reviewability — the commit message calls out the tool fixes explicitly in a dedicated section.

## Known stubs / deferred items

- **JSDoc and credit-comment mentions of `RYD_*` names** (100 comment-only occurrences) are preserved in the source tree. These are historical references ("Originally from HAC_fnc.sqf (RYD_Wait)" style) and one JSDoc parameter description in `fnc_initWeaponClasses.sqf`. Per D-05/D-06, comment-only references are acceptable — they don't affect behavior or the build. A future cleanup pass may modernize the JSDoc if desired.
- **`RYD_WS_NCrewInf_class`** is read in addons/ but never assigned in addons/. Runtime value depends on whichever legacy `nr6_hal/` file assigns it, if any. Phase 4 preserves the pre-existing condition; Phase 5 compat addon will either alias it or the runtime will tolerate a nil (since `in` checks and list concatenations handle nil/empty gracefully in SQF).

## Verification

- [x] Pre-commit dry-run reviewed and approved (36 unique names, 17 files, 790-line unified diff)
- [x] Zero residual `RYD_[A-Za-z]` in code after apply (`wc -l` = 0)
- [x] Companion-prefix counts recorded in commit message as baseline
- [x] `hemtt build` clean (exit 0, 0 L-S/L-C warnings, BBW1 accepted)
- [x] `rename-map-ryd.json` committed, schema-valid, all entries `stripped:false`
- [x] `manual-sites-ryd.md` and `stale-comments-ryd.md` committed
- [x] Self-test still 14/14 passing after all three tool fixes
- [x] Atomic single commit per D-03

## Threat surface scan

No new network endpoints, auth surface, schema changes, or file access patterns introduced. Pure identifier rewrite.

## Self-Check: PASSED

- `.planning/phases/04-variable-namespacing/rename-map-ryd.json` — FOUND
- `.planning/phases/04-variable-namespacing/manual-sites-ryd.md` — FOUND
- `.planning/phases/04-variable-namespacing/stale-comments-ryd.md` — FOUND
- Commit `07d4475` — FOUND (`git log --oneline -2` confirms HEAD)
- `hemtt build` — exit 0, 0 L-S/L-C warnings
- Residual `RYD_` in code — 0 (verified via grep post-commit)
- Tool `--self-test` — 14/14 pass after fixes
