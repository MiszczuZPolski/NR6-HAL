---
phase: 04-variable-namespacing
plan: 02
subsystem: variable-namespacing
tags: [rename, prefix-batch, RHQ_, GVAR, EGVAR, wave-2, hal_data]
requires:
  - 04-00 (phase4-rename.py tool)
  - 04-01 (wave-1 RYD_ batch + tool hardening)
  - 04-CONTEXT.md D-01..D-06
provides:
  - .planning/phases/04-variable-namespacing/rename-map-rhq.json
  - .planning/phases/04-variable-namespacing/manual-sites-rhq.md
  - .planning/phases/04-variable-namespacing/stale-comments-rhq.md
  - .planning/phases/04-variable-namespacing/owner-overrides-rhq.json
  - unchanged companion-prefix baselines for 04-03..04-05
affects:
  - addons/common/ (2 files)
  - addons/core/ (1 file)
  - addons/hal_data/ (1 file, owner)
  - addons/hal_tasking/ (6 files)
tech-stack:
  added: []
  patterns: [GVAR, EGVAR, QGVAR, QEGVAR]
key-files:
  created:
    - .planning/phases/04-variable-namespacing/rename-map-rhq.json
    - .planning/phases/04-variable-namespacing/manual-sites-rhq.md
    - .planning/phases/04-variable-namespacing/stale-comments-rhq.md
    - .planning/phases/04-variable-namespacing/owner-overrides-rhq.json
  modified:
    - addons/common/functions/fnc_artyMission.sqf
    - addons/common/functions/fnc_rhqCheck.sqf
    - addons/core/functions/fnc_HQSitRep.sqf
    - addons/hal_data/functions/fnc_presentRHQ.sqf
    - addons/hal_tasking/functions/fnc_action9ct.sqf
    - addons/hal_tasking/functions/fnc_action10ct.sqf
    - addons/hal_tasking/functions/fnc_action11ct.sqf
    - addons/hal_tasking/functions/fnc_action12ct.sqf
    - addons/hal_tasking/functions/fnc_action13ct.sqf
    - addons/hal_tasking/functions/fnc_actionArtct.sqf
decisions:
  - "Owner-override file introduced for the 28 names that have no top-level assignment in addons/ — the tool's default fallback (first-referring addon = common) contradicted the plan's key_links which pin hal_data as canonical owner for all RHQ_* weapon-class arrays."
  - "Tool behaved cleanly this batch — no new bugs found, self-test still 14/14. The 04-01 hardening pass carried."
  - "Comment-only RHQ_ mentions in JSDoc header of fnc_presentRHQ.sqf (2 occurrences) preserved per D-05/D-06 posture."
metrics:
  duration: ~600s
  completed: 2026-04-11
  unique_legacy_names: 34
  files_modified_in_addons: 10
  rename_map_entries: 34
  dispatch_sites_whitelisted: 0
  tool_bugs_fixed: 0
  commits: 1
requirements: [VAR-01, VAR-02, VAR-03, VAR-04]
---

# Phase 04 Plan 02: Wave-2 RHQ_ prefix rename Summary

One-liner: Atomically rewrote all 34 unique `RHQ_*` legacy identifiers (player-faction weapon-class arrays) under `addons/` to `GVAR(...)` inside `hal_data` and `EGVAR(hal_data,...)` in cross-addon readers across 10 files, with a curated owner-override file pinning 28 indirectly-referenced names to their canonical `hal_data` owner.

## What shipped

- **10 addon source files rewritten** — every non-comment `RHQ_*` code reference is now a CBA macro. Zero residual `RHQ_[A-Za-z]` code lines remain.
- **`rename-map-rhq.json`** — 34 entries, schema-valid (`phase-4-rename-map-v1`), `prefix_batch: RHQ_`, every entry `addon_owner: hal_data` and `stripped: false`. Ready for Phase 5 compat alias generation.
- **`owner-overrides-rhq.json`** — 28-entry override file pinning the indirectly-referenced RHQ_ names to `hal_data`. Committed alongside the rename to keep the batch reproducible.
- **`manual-sites-rhq.md`** — 0 dispatch sites, 0 string-literal substring flags.
- **`stale-comments-rhq.md`** — 0 flagged entries.
- **Single atomic commit `259f093`** — 14 files changed, 1291 insertions, 112 deletions. Addons/ rewrites, rename-map, reports, and the override file landed together per D-03.

## Rename breakdown (by owner)

| Owner | Count | Notes |
|---|---|---|
| hal_data | 34 | Weapon-class arrays. 6 resolved natively (RHQ_Inf, RHQ_Crew, RHQ_HArmor + the 3 RHQ_ClassRange* via fallback to hal_data); 28 pinned via `owner-overrides-rhq.json`. |

All `RHQ_*` writers and readers now route through `hal_data` as the canonical owner per plan key_links.

## Tool behaviour this batch

- **No new bugs surfaced.** Phase4-rename.py ran cleanly on first attempt post-04-01 hardening. Self-test unchanged at 14/14.
- **Override file was required.** 28 of 34 RHQ_ names have no top-level `NAME = value` assignment anywhere in `addons/` — they are only READ in `addons/` and assigned in legacy `nr6_hal/` (mirrors the `RYD_WS_NCrewInf_class` pattern from 04-01 but at scale). The tool's default owner-inference fallback attributes such names to the first referring addon (alphabetically `common`), which contradicts the plan's explicit `hal_data`-owner design. Rather than expand the fallback to "look for mutation verbs like `pushBackUnique` / `pushBack`" (speculative, fragile), the deterministic path was a hand-curated override file — exactly the escape-hatch the tool exposes via `--owner-override`.
- **Double-hal_ expansion noted, accepted.** `GVAR(inf)` → `hal_hal_data_inf` inside hal_data. External `EGVAR(hal_data, inf)` resolves to the same string. Cosmetic ugliness only, per research Q1.

## Companion-prefix baseline verification (unchanged from 04-01)

Verified using the same measurement method 04-01 established (`grep -rE '\b<prefix>' addons/ --include='*.sqf' | wc -l`):

| Prefix | Baseline (from 04-01 commit) | After 04-02 | Delta |
|---|---|---|---|
| `RYD_` | 0 (code) / 100 (raw) | 0 code / 100 raw | 0 |
| `RHQ_` | 114 | **0 code / 2 comment-only** | -114 (target for this batch) |
| `RydBB_` | 33 | 33 | 0 ✓ |
| `RydHQ_` | 1124 | 1124 | 0 ✓ |
| `RydxHQ_` | 157 | 157 | 0 ✓ |

The 2 comment-only RHQ_ hits remaining are both in the JSDoc header of `addons/hal_data/functions/fnc_presentRHQ.sqf` (descriptive prose referring to "RHQ_* arrays"). Acceptable per D-05/D-06 — no behavior or build impact.

These counts become the new baseline for 04-03..04-05 to regression-check against.

## Build gate

- `hemtt build`: exit 0
- L-S/L-C warnings: 0
- BBW1: present (accepted environment notice per CLAUDE.md)
- Post-commit residual scan: `grep -rnE '\bRHQ_[A-Za-z]' addons/` → 2 lines, both in JSDoc comments

## Deviations from Plan

### [Rule 3 - Blocking issue] Owner-inference fell through to `common` for 28 of 34 names

- **Found during:** Task 1 dry-run review
- **Issue:** Tool's default fallback inferred `addon_owner: common` for every RHQ_ name that lacked a top-level `NAME =` assignment in addons/. These names ARE conceptually hal_data-owned (they're weapon-class arrays, sibling to the `RYD_WS_*_class` arrays already owned by hal_data post-04-01, and the plan's key_links pins them to hal_data explicitly). Allowing the tool's default would have emitted `EGVAR(common, inf)` / `GVAR(inf)` mappings that contradicted the plan's Task 1 `<automated>` gate (`assert all(e['addon_owner']=='hal_data' for e in m['entries'])`). Plan also explicitly documents this escape hatch: "Any non-hal_data writer is a collision and must go into owner-overrides-rhq.yml".
- **Fix:** Created `.planning/phases/04-variable-namespacing/owner-overrides-rhq.json` (plan text said `.yml` but tool also accepts JSON per `load_owner_overrides`) pinning all 28 names to `hal_data`. Ran the rename with `--owner-override` pointing at that file. Task 1 automated gate now passes.
- **Files modified:** `.planning/phases/04-variable-namespacing/owner-overrides-rhq.json` (new file)
- **Commit:** 259f093
- **Design note:** The root cause is that these names are only READ in `addons/`; their writers live in `nr6_hal/`. Exactly the `RYD_WS_NCrewInf_class` situation from 04-01 (single name), but at 28× scale because RHQ_ is an entire array family mirroring RYD_WS_*. 04-01 accepted the single fallback inference; 04-02 couldn't because the plan's key_links made the correct owner explicit and the scale made ambiguity a reviewability concern.

### [design] Override file extension `.json` instead of plan-spec `.yml`

- **Plan text:** `owner-overrides-rhq.yml`
- **Committed as:** `owner-overrides-rhq.json`
- **Why:** The tool's `load_owner_overrides` function tries JSON first and falls back to a minimal YAML subset. JSON is unambiguous, avoids any YAML-parser edge cases, and keeps the file machine-readable by standard tooling. Cosmetic mismatch only.

## Known stubs / deferred items

- **JSDoc mentions of `RHQ_*` in `fnc_presentRHQ.sqf` header** (2 occurrences, descriptive prose — "Categorizes all mission vehicles and units into RHQ_* arrays" / "Writes results to RHQ_* globals used throughout the AI system"). Comment-only, preserved per D-05/D-06. A future cleanup pass may modernize the docstring if desired.
- **Runtime assignment of RHQ_* still lives in `nr6_hal/`** — 28 names are READ by `addons/` but never assigned there. Phase 5 compat addon will need to either alias them or ensure the legacy writes still reach the new `hal_hal_data_*` mission-namespace variable names. Flagged for Phase 5 planning, not an execution bug here (pre-existing condition mirroring 04-01's RYD_WS_NCrewInf_class).

## Verification

- [x] Pre-commit dry-run reviewed and approved (34 unique names, 10 files, ~560-line diff)
- [x] Zero residual `RHQ_[A-Za-z]` in non-comment code after apply (2 JSDoc-comment mentions preserved)
- [x] Zero residual `RYD_[A-Za-z]` in non-comment code (04-01 territory unchanged)
- [x] RydBB_/RydHQ_/RydxHQ_ counts match 04-01 baseline exactly (33/1124/157)
- [x] `hemtt build` clean (exit 0, 0 L-S/L-C warnings, BBW1 accepted)
- [x] `rename-map-rhq.json` committed, schema-valid, all 34 entries `addon_owner: hal_data`, all `stripped: false`
- [x] `manual-sites-rhq.md` and `stale-comments-rhq.md` committed (both empty-ish — 0 flags)
- [x] `owner-overrides-rhq.json` committed (28 entries, all → hal_data)
- [x] Atomic single commit per D-03 (259f093)
- [x] Self-test 14/14 still passing (unchanged — no tool modifications this batch)

## Confirmed baselines for 04-03

| Prefix | Count (04-01 method: `grep -rE '\b<P>' addons/ --include='*.sqf' \| wc -l`) |
|---|---|
| `RYD_` | 0 (code) / 100 (raw, comment-inclusive) |
| `RHQ_` | 0 (code) / 2 (raw, comment-inclusive) |
| `RydBB_` | **33** (04-03 target — must reach 0) |
| `RydHQ_` | **1124** (04-04 target) |
| `RydxHQ_` | **157** (04-05 target) |

## Threat surface scan

No new network endpoints, auth surface, schema changes, or file access patterns introduced. Pure identifier rewrite.

## Self-Check: PASSED

- `.planning/phases/04-variable-namespacing/rename-map-rhq.json` — FOUND
- `.planning/phases/04-variable-namespacing/manual-sites-rhq.md` — FOUND
- `.planning/phases/04-variable-namespacing/stale-comments-rhq.md` — FOUND
- `.planning/phases/04-variable-namespacing/owner-overrides-rhq.json` — FOUND
- Commit `259f093` — FOUND (`git log --oneline -1` confirms HEAD)
- `hemtt build` — exit 0, 0 L-S/L-C warnings
- Residual `RHQ_[A-Za-z]` in code — 0 (verified via grep post-commit, 2 comment-only preserved)
- Companion prefixes — unchanged (33/1124/157)
