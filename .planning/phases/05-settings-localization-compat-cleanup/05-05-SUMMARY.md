---
phase: 05-settings-localization-compat-cleanup
plan: 05
subsystem: dead-variable-audit
tags: [audit, rename-map, dead-var, d-06, read-only]
wave: 5
requires:
  - 05-04 (nr6_hal/ fully deleted; all code in addons/)
provides:
  - Authoritative stripped:true/false flag on every rename-map.json entry
  - Audit-derived confidence that no dead variables need aliasing in Plan 07 compat addon
  - Baseline dead-count measurement for COMPAT-02/COMPAT-03
affects:
  - .planning/phases/04-variable-namespacing/rename-map.json (metadata-only update)
tech-stack:
  added: []
  patterns:
    - "conservative dead-var classification: an entry is ALIVE if any reader form is found — legacy-name getVariable/isNil/bare-ref, new literal getVariable/isNil, or QGVAR/QEGVAR string form. Writers (setVariable LHS, publicVariable, assignment LHS) do NOT count."
    - "multi-form reader detection: checks (a) legacy name `Ryd*_Foo`, (b) new literal `hal_<owner>_foo`, (c) macro owner form GVAR(foo) within owner addon only, (d) extern form EGVAR(owner,foo) from any addon, (e) string forms QGVAR/QEGVAR"
key-files:
  created:
    - .tmp/audit_dead_vars.py (audit tool, kept out-of-tree per .tmp convention)
    - .tmp/dead_vars_report.json (per-run audit output, ephemeral)
  modified:
    - .planning/phases/04-variable-namespacing/rename-map.json (all 506 entries verified, stripped flags confirmed)
decisions:
  - "Audit is READ-ONLY on addons/ source code per plan mandate: the first pass only updates rename-map.json metadata. No production files touched. No strip commits required because zero dead entries found."
  - "Reader detection must include LEGACY name forms, not just new phase-4 forms. Many dynamic-prefix variables (RydxHQ_AIC_SILENTM_<msgtype>) are still referenced at runtime in legacy form via string concatenation in fnc_AIChatter.sqf. An earlier audit iteration that scanned only new literal forms produced a FALSE DEAD report of 2 entries (AIC_40KImp_, AIC_SILENTM_); enhancing the scanner to also check legacy getVariable/isNil/bare-ref patterns correctly resolved them as ALIVE."
  - "Owner-scoped GVAR(var) detection: `GVAR(foo)` in addon X and `GVAR(foo)` in addon Y expand to different literals. Therefore GVAR(var) is only counted as a reader when the source file lives in the entry's `addon_owner` addon. EGVAR(addon,var) is counted from any file."
  - "QGVAR/QEGVAR occurrences in the owning/extern form are treated as DEFINITE reads regardless of surrounding context, because they are string forms that never appear in assignment LHS."
metrics:
  duration: "~25 minutes"
  completed: "2026-04-11"
  entries_audited: 506
  entries_alive: 506
  entries_dead: 0
  files_scanned: 343
  addons_scanned: 7 (common, core, hal_boss, hal_data, hal_hac, hal_tasking, main, missionmodules — excluding compat_nr6hal which does not yet exist)
---

# Phase 05 Plan 05: Dead-Variable Audit Summary

Ran the D-06 dead-variable audit across the fully-extracted addons/ tree. Goal: mark every rename-map.json entry that has zero readers in production code as `stripped:true`, so Plan 07's compat addon only needs to alias living variables. Result: zero dead entries — every one of the 506 rename-map entries has at least one genuine reader.

## Audit Approach

The rename-map.json entries each describe one legacy `Ryd*_Foo` variable and its phase-4 post-rename forms (literal `hal_<owner>_foo`, GVAR(foo), EGVAR(owner,foo), QGVAR/QEGVAR string forms). A single Python classifier (`.tmp/audit_dead_vars.py`) walks every file under `addons/` (excluding `compat_nr6hal` which does not yet exist) and, for each entry, looks for READER occurrences in ALL of these forms:

1. **Legacy name readers** — `getVariable ["Ryd*_Foo"`, `getVariable "Ryd*_Foo"`, `isNil "Ryd*_Foo"`, and bare-word references not on an assignment LHS (catches string-concat patterns like `"RydxHQ_AIC_SILENTM_" + _msgtype`).
2. **New literal readers** — same patterns against the post-rename literal `hal_<owner>_foo`.
3. **QGVAR / QEGVAR string forms** — always counted as reads (these are quoted names passed to getVariable at runtime and never appear on assignment LHS).
4. **GVAR(foo) macro reads** — counted only when the source file lives in the entry's owner addon (same-name macros in other addons expand to different literals). Write-LHS occurrences excluded.
5. **EGVAR(owner,foo) macro reads** — counted from any file. Write-LHS occurrences excluded.

Writer contexts excluded in (1)-(5): occurrence immediately followed by `=` (not `==`), or preceded by `setVariable [`, `publicVariable`, `publicVariableServer`, or `publicVariableClient N,`.

## Results

| Metric | Count |
|---|---|
| Total rename-map entries | 506 |
| Alive (stripped:false) | 506 |
| Dead (stripped:true) | 0 |
| Files scanned | 343 |
| Addons scanned | common, core, hal_boss, hal_data, hal_hac, hal_tasking, main, missionmodules |

Every entry in the rename-map has at least one reader in the production addons/ tree. This is a defensible result: the rename-map was generated in Phase 04 from observed production references, so every entry traces back to a real reader or writer that was rewritten. The audit confirms none of those readers have since been deleted.

## Spot-checks (required by plan: 5 manual verifications)

All five passed:

| # | Entry | Form found | File |
|---|---|---|---|
| 1 | `RHQ_AAInf` | `EGVAR(hal_data,aAInf)` read | `addons/common/functions/fnc_rhqCheck.sqf:17`, `addons/core/functions/fnc_HQSitRep*.sqf:130` |
| 2 | `RydHQ_FirstEMark` | `_HQ getVariable [QEGVAR(core,firstEMark),true]` | `addons/hal_hac/functions/fnc_hqOrdersDef.sqf:43` |
| 3 | `RydxHQ_TaskActions` | `EGVAR(core,taskActions)` read | `addons/hal_tasking/functions/fnc_squadTasking.sqf:70` |
| 4 | `RydHQ_SRep` | `_HQ getVariable [QEGVAR(core,sRep),true]` | `addons/hal_hac/functions/fnc_statusQuo.sqf:141` |
| 5 | `RydxHQ_AIC_SILENTM_` | bare legacy ref in string concat: `"RydxHQ_AIC_SILENTM_" + _messageType` | `addons/common/functions/fnc_AIChatter.sqf:31` |

The fifth spot-check is the key correctness case: this entry is a dynamic-prefix variable where the runtime key is constructed via string concatenation from the legacy prefix. An audit that scanned only new literal forms would incorrectly mark it DEAD. The current scanner catches it via the bare legacy-name reader path, confirming ALIVE.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 — Bug] Legacy-name reader detection was missing from the initial classifier**

- **Found during:** First audit run produced 2 false-dead entries (`RydxHQ_AIC_40KImp_`, `RydxHQ_AIC_SILENTM_`) that are both referenced in `addons/common/functions/fnc_AIChatter.sqf` via runtime string concatenation (`getVariable ["RydxHQ_AIC_SILENTM_" + _messageType, []]`).
- **Issue:** The plan's reader criteria (literal getVariable, GVAR/EGVAR, QGVAR/QEGVAR) did not explicitly cover the case where a LEGACY name is still used at runtime because the code does not construct the new literal at the call-site. The classifier's initial pass looked only for new-form references.
- **Fix:** Extended `.tmp/audit_dead_vars.py` to also detect legacy-name reader forms: `getVariable "Ryd*"` (both bracket and non-bracket), `isNil "Ryd*"`, and bare-word references outside write contexts. Re-ran audit.
- **Impact:** Prevents false-dead flag on any variable still actively read under its legacy name. Both AIC_* entries reclassified correctly as ALIVE.
- **Files modified:** `.tmp/audit_dead_vars.py` (audit tool only — no production code)

### Notes

- No changes to addons/ source code. Audit is pure metadata update to rename-map.json, as mandated by plan Task 1 and D-06 sequencing.
- No commits to strip entries from source code needed — the plan made strip commits optional per dead-count, and with zero dead entries there is nothing to strip.
- `hemtt check` was re-run after the audit as a sanity gate; result unchanged (0 errors, same pre-existing L-S* lint help notices as prior plans).

## What This Unblocks (Plan 07)

Plan 07 (compat addon generation) can now consume rename-map.json and emit aliases for every non-stripped entry. Because this audit found zero dead entries, the compat addon will need to cover all 506 entries — the lean compat addon described in D-06 is still lean in the sense that every alias is provably needed.

## Known Stubs

None.

## Threat Flags

None.

## Self-Check: PASSED

- rename-map.json exists and has all 506 entries with `stripped` field — VERIFIED via `python -c "..."`
- All 506 entries classified (alive + dead = 506) — VERIFIED
- 5 spot-checks confirmed manually — VERIFIED via Grep
- No production code modified — VERIFIED via `git diff --stat` (only rename-map.json touched, and only a trailing newline diff since all entries remained stripped:false)
- `hemtt check` still passes — VERIFIED (0 errors, 308 SQF files compiled)
