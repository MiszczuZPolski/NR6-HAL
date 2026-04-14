---
phase: 04-variable-namespacing
plan: 00
subsystem: tooling
tags: [python, rename-tool, prefix-batch, prerequisite]
requires:
  - 04-RESEARCH.md Q1 (GVAR expansion)
  - 04-RESEARCH.md Q6 (tool spec)
  - 04-RESEARCH.md Q10 (JSON schema)
  - 04-CONTEXT.md D-01..D-06
provides:
  - .planning/phases/04-variable-namespacing/scripts/phase4-rename.py
  - .planning/phases/04-variable-namespacing/scripts/README.md
affects:
  - plans 04-01, 04-02, 04-03, 04-04, 04-05 (all invoke this tool)
tech-stack:
  added: [python3]
  patterns: [SQF-aware tokenizer, word-boundary regex with longest-match alternation, dispatch-site detection]
key-files:
  created:
    - .planning/phases/04-variable-namespacing/scripts/phase4-rename.py
    - .planning/phases/04-variable-namespacing/scripts/README.md
  modified: []
decisions:
  - "Single-file ~800 LOC tool (slightly over the ~400 pseudocode target) to keep all helpers co-located"
  - "`python3` shebang kept for POSIX; Windows runs via `python` (documented in README)"
  - "Self-test uses pure in-memory fixtures; never touches the filesystem"
metrics:
  duration: 256s
  completed: 2026-04-11
requirements: [VAR-01, VAR-04]
---

# Phase 04 Plan 00: Phase 4 rename tool Summary

One-liner: Built `phase4-rename.py`, an SQF-aware, word-boundary, dispatch-safe Python rewriter that plans 04-01..04-05 invoke per-prefix to convert legacy HAL globals into CBA `GVAR`/`EGVAR` macros, emitting a Q10-schema rename-map JSON in the same pass.

## What shipped

- **`scripts/phase4-rename.py`** — ~800 line single-file Python 3 tool implementing:
  - `tokenize_sqf(text)` — state-machine tokenizer splitting text into `code` / `line_comment` / `block_comment` / `string` spans. Handles SQF's doubled-quote escape (`""` / `''`) and cross-line block comments.
  - `make_identifier_regex(prefix)` — word-boundary matcher with `(?<![A-Za-z0-9_])…(?![A-Za-z0-9_])`. The `RydHQ_` core pattern is `(?:RydHQ[B-H]_|RydHQ_)`, listing multi-HQ siblings first so Python's leftmost-first alternation picks the longer match.
  - `strip_prefix(legacy_name, prefix)` — prefix removal + first-char lowercasing. `RydHQB_Debug` folds to `debugB` (multi-HQ letter becomes a name suffix, per D-02).
  - `canonical_macros(...)` — emits the `GVAR(...)`, `EGVAR(owner,...)`, `QGVAR`/`QEGVAR` and literal `hal_COMPONENT_name` expansion forms. Doubled `hal_` for hal_* addons is preserved (Q1 ⚠️).
  - `scan_map(root, prefix, overrides)` — first-pass scanner walking `.sqf` / `.hpp` / `.cpp` / `.inc` files. Classifies each hit by coarse scope (`global_assignment`, `setVariable_key`, `getVariable_key`, `publicVariable_string`, `isNil_guard`, `global_read`). Infers `addon_owner` from the first top-level `NAME =` assignment in canonical sort order. Flags ownership collisions.
  - Multi-HQ sibling detection — runs as a second pass on the RydHQ_ batch only, grouping entries by base name and marking any group with ≥2 members as `multi_hq:true` with a full sibling list.
  - `detect_dispatch_files(root, prefix)` — returns every file containing `call compile (…_prefix + …)` or `call compile (…RydHQ_…)`. These are excluded from auto-rewrite and `--apply` refuses unless each is passed via `--allow-dispatch-file`.
  - `rewrite_text(...)` — per-span rewriter that (a) skips comments, (b) exact-matches string literals to `QGVAR`/`QEGVAR`, (c) flags (but never mutates) substring legacy-name occurrences inside larger strings, (d) replaces code identifiers choosing `GVAR` vs `EGVAR` based on owner vs current addon.
  - `materialize_map_json(...)` — emits the Q10 schema with all entries at `stripped: false` (D-06 deviation).
  - `run_self_test()` — 14 in-memory fixtures, no filesystem access.
  - `main()` — CLI wiring. Refuses `--root` containing `.planning` or `docs`. Requires `--apply` for writes. Writes `manual-sites-<prefix>.md` and `stale-comments-<prefix>.md` reports next to the map.

- **`scripts/README.md`** — CLI reference, example invocations (dry-run RYD_, apply RydHQ_ with whitelisted dispatch files, self-test), constraint matrix cross-reference, JSON schema, self-test case list, Python-executable note for the Windows/git-bash environment.

## Tool CLI invocation examples

Dry-run the RYD_ batch (default, nothing written):
```bash
python .planning/phases/04-variable-namespacing/scripts/phase4-rename.py \
  --prefix RYD_ --root addons/ \
  --map-out .planning/phases/04-variable-namespacing/rename-map-ryd.json
```

Apply the RydHQ_ batch with two whitelisted dispatch files:
```bash
python .planning/phases/04-variable-namespacing/scripts/phase4-rename.py \
  --prefix RydHQ_ --root addons/ --apply \
  --map-out .planning/phases/04-variable-namespacing/rename-map-rydhq.json \
  --allow-dispatch-file addons/missionmodules/functions/fnc_leaderBehaviourSettings.sqf \
  --allow-dispatch-file addons/missionmodules/functions/fnc_leaderSettings.sqf
```

Run the in-memory self-test:
```bash
python .planning/phases/04-variable-namespacing/scripts/phase4-rename.py --self-test
```

## Self-test results

```
[PASS] global_assignment                'RYD_Top = 5'                        -> 'GVAR(top) = 5'
[PASS] publicVariable_string            'publicVariable "RYD_Top"'           -> 'publicVariable QGVAR(top)'
[PASS] isNil_guard                      'isNil "RYD_Top"'                    -> 'isNil QGVAR(top)'
[PASS] setVariable_key                  '_o setVariable ["RYD_K", 1]'        -> '_o setVariable [QGVAR(k), 1]'
[PASS] getVariable_key                  '_o getVariable ["RYD_K", 0]'        -> '_o getVariable [QGVAR(k), 0]'
[PASS] global_read                      'hint str RYD_Top'                   -> 'hint str GVAR(top)'
[PASS] line_comment_preserved           '// RYD_DoNotRewrite\n'              -> (unchanged)
[PASS] block_comment_preserved          '/* RYD_DoNotRewrite */'             -> (unchanged)
[PASS] word_boundary_negative           'XRYD_NotATarget = 1'                -> (unchanged)
[PASS] fuzzy_string_flagged             '_x = "RYD_Top was set";'            -> (unchanged + flagged)
[PASS] extern_form_from_other_addon     'hint str RYD_Top' [from common]     -> 'hint str EGVAR(core,top)'
[PASS] multi_hq_sibling_detect          8 RydHQ[B-H]?_Debug siblings         -> multi_hq:true, siblings:[8]
[PASS] multi_hq_letter_suffix           'RydHQB_Debug = true'                -> 'GVAR(debugB) = true'
[PASS] rydhq_vs_rydhqh_distinction      'x = RydHQH_Debug'                   -> 'x = GVAR(debugH)'
14/14 cases passed
```

Exit 0. `--help` also verified (prints all documented flags including `--self-test`).

## Deviations from Plan

### [Rule 3 — blocker] python3 binary missing in git-bash
- **Found during:** Task 2 (self-test invocation)
- **Issue:** Plan verify commands use `python3`; this Windows git-bash environment only exposes `python` (3.10) and `py` (3.14).
- **Fix:** Kept `#!/usr/bin/env python3` shebang (works on POSIX), used `python` in all verify commands during this execution, and documented the discrepancy in `scripts/README.md` under "Python executable note". Plans 04-01..04-05 will need the same `python` invocation on this machine.
- **Files modified:** `scripts/README.md`
- **Commit:** 92cca26

### [design] Tool ~800 LOC, not ~400
- **Found during:** Task 1 implementation
- **Issue:** The pseudocode outline estimated ~400 lines, but a fully self-contained single-file tool with tokenizer + scanner + rewriter + self-test + map emission + report writers + CLI came in near 800 lines. The spec explicitly asked for "one file" and "keep to ~400 lines" as a soft target.
- **Decision:** Kept everything in one file per the "one file" constraint and accepted the higher line count — splitting into modules would have required an importable package which breaks the "drop-in script" invocation pattern plans 04-01..04-05 expect. No behavioral cost.
- **Commit:** 92cca26

### [design] Owner inference fallback for names with no top-level assignment
- **Found during:** Task 1 implementation
- **Issue:** The Q6 spec describes owner inference as "the addon containing the first top-level assignment." But some legacy names exist only as `setVariable` keys with no bare `NAME = …` assignment anywhere. Without a fallback, their `addon_owner` would be `None`, propagating a `null` into emitted JSON and breaking `canonical_macros`.
- **Fix:** When no top-level assignment is found, the tool falls back to the first referencing file's addon and records `notes: "inferred owner (no top-level assignment found)"`. The planner can override with `--owner-override` if the inference is wrong.
- **Commit:** 92cca26

## Known Limitations

1. **`classify_scope` is line-scoped heuristic, not AST.** It looks at the same line as each match for the enclosing SQF construct. A `setVariable` call split across multiple lines may be misclassified as `global_read`. Impact: the emitted `scopes` array is advisory — the actual rewrite is driven by the tokenizer, not by scope labels, so classification mistakes do not affect correctness of the rewrite itself.
2. **Fuzzy-string flags are noisy but informational.** Any mention of a legacy name inside a larger string (e.g. `"Setting RYD_Top to 5"` in a log message) is flagged. Plans 04-01..04-05 must review `manual-sites-*.md` per batch and either update the string by hand or accept that it stays as stale-text.
3. **`--legacy-dir nr6_hal/` is recorded but not acted on** (per D-06). The flag exists for future use but Phase 4 always emits `stripped: false`.
4. **Dispatch-site detection regex is coarse.** `detect_dispatch_files` trips on any `call compile (...)` line that contains `_prefix + ` or a direct legacy-prefix reference. False positives (files that merely mention the pattern in a comment) are possible — the remedy is to `--allow-dispatch-file` whitelist them after manual review.
5. **No built-in diff highlighting.** Output is plain unified diff to stdout. Pipe through `delta`, `diff-so-fancy`, or your pager of choice for colorized review.

## Threat surface scan

No new network endpoints, auth surface, schema changes, or file access patterns introduced. The tool is a local-only developer script.

## Self-Check: PASSED

- `.planning/phases/04-variable-namespacing/scripts/phase4-rename.py` — FOUND
- `.planning/phases/04-variable-namespacing/scripts/README.md` — FOUND
- Commit `92cca26` — FOUND (`git log --oneline -1` shows it on HEAD)
- `--help` exit code — 0
- `--self-test` exit code — 0 (14/14 pass)
- `--root .planning` refusal — confirmed (exit 2, REFUSE message)
- Working tree clean post-commit — confirmed (only untracked `.claude/` and `.tmp/`)
