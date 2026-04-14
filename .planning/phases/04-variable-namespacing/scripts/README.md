# phase4-rename.py — Phase 4 mechanical rename tool

A single-file Python tool that rewrites legacy HAL globals (`RYD_*`, `RHQ_*`,
`RydBB_*`, `RydHQ_*`, `RydxHQ_*`) to CBA `GVAR()` / `EGVAR()` macros under
`addons/`. Drives execution plans `04-01` through `04-05`.

Design reference: `04-RESEARCH.md` Q6 (tool selection), Q1 (macro expansion),
Q4 (rename map schema), Q10 (JSON schema), `04-CONTEXT.md` D-01..D-06, and the
constraint matrix in `04-00-PLAN.md`.

## CLI

```
phase4-rename.py
  --root <path>                Rename scope (must be under addons/; rejects .planning/ or docs/)
  --prefix <RYD_|RHQ_|RydBB_|RydHQ_|RydxHQ_>
                               Batch selector (required except with --self-test)
  --legacy-dir nr6_hal/        nr6_hal/ tree for dead-var cross-check (Phase 4 records only)
  --map-out <path>             Rename-map JSON output path
  --dry-run                    Default — no writes, print unified diff to stdout
  --apply                      Actually write files + emit map
  --owner-override <path>      JSON or simple `key: value` YAML file forcing owner per legacy name
  --allow-dispatch-file <path> Whitelist a hand-rewritten dispatch-site file (repeatable)
  --report-dir <path>          Where to write manual-sites / stale-comments reports
  --self-test                  Run in-memory fixtures, print PASS/FAIL per case, exit
```

## Example invocations

Dry-run the RYD_ batch (default — nothing written to disk):

```bash
python phase4-rename.py \
  --prefix RYD_ \
  --root addons/ \
  --map-out .planning/phases/04-variable-namespacing/rename-map-ryd.json
```

Apply the RydHQ_ batch with whitelisted dispatch files:

```bash
python phase4-rename.py \
  --prefix RydHQ_ \
  --root addons/ \
  --apply \
  --map-out .planning/phases/04-variable-namespacing/rename-map-rydhq.json \
  --allow-dispatch-file addons/missionmodules/functions/fnc_leaderBehaviourSettings.sqf \
  --allow-dispatch-file addons/missionmodules/functions/fnc_leaderSettings.sqf
```

Run the in-memory self-test (no filesystem access):

```bash
python phase4-rename.py --self-test
```

> **Python executable note:** This project runs on Windows under git-bash.
> `python3` is not on the PATH in that environment; use `python` (or `py`).
> The tool's shebang is `#!/usr/bin/env python3` so POSIX environments work
> unchanged.

## Constraint matrix (from 04-RESEARCH.md Q6)

| Constraint | Implemented by |
|---|---|
| Word-boundary | `(?<![A-Za-z0-9_])…(?![A-Za-z0-9_])` in `make_identifier_regex` |
| Longest-match alternation | `PREFIX_CORE["RydHQ_"] = r"(?:RydHQ[B-H]_\|RydHQ_)"` — siblings first |
| Comment awareness | `tokenize_sqf` labels `//…` and `/*…*/` spans; rewrite skips them |
| String-literal awareness | Exact match in a string → `QGVAR` / `QEGVAR`; substring match → flagged, not mutated |
| Dispatch-site protection | `detect_dispatch_files` flags files containing `call compile (…_prefix…)`; `--apply` refuses unless whitelisted |
| Dry-run default | `--dry-run` is the default; `--apply` required for writes |
| Map emission | `--map-out` writes the Q10 JSON schema |
| Owner inference | First file (canonical sort) with a top-level `NAME =` assignment wins; collisions block `--apply` until `--owner-override` supplied |
| `.planning/` protection | `--root` refuses paths containing `.planning` or `docs`; `--self-test` bypasses filesystem access entirely |
| Dead-var cross-check (`nr6_hal/`) | Flag kept (`--legacy-dir`) but per D-06 every entry emits `stripped: false` |

## Rename-map JSON schema (Q10)

```json
{
  "$schema": "phase-4-rename-map-v1",
  "generated_at": "2026-04-11T19:53:45Z",
  "prefix_batch": "RYD_",
  "entries": [
    {
      "legacy_name": "RydHQ_Activity",
      "new_macro_owner_form": "GVAR(activity)",
      "new_macro_extern_form": "EGVAR(core,activity)",
      "new_literal_expansion": "hal_core_activity",
      "addon_owner": "core",
      "scopes": ["global_assignment", "setVariable_key", "getVariable_key", "isNil_guard"],
      "multi_hq": false,
      "multi_hq_siblings": [],
      "stripped": false,
      "notes": "",
      "file_locations": [
        {"path": "addons/core/functions/fnc_init.sqf", "line": 8, "scope": "global_assignment"}
      ]
    }
  ]
}
```

Every Phase 4 entry is emitted with `"stripped": false` per the D-06
deviation. The field is retained for Phase 5's compat addon generation.

## Self-test cases

The `--self-test` flag runs these in-memory fixtures and exits non-zero on any
failure:

1. `global_assignment` — `RYD_Top = 5` → `GVAR(top) = 5`
2. `publicVariable_string` — `publicVariable "RYD_Top"` → `publicVariable QGVAR(top)`
3. `isNil_guard` — `isNil "RYD_Top"` → `isNil QGVAR(top)`
4. `setVariable_key` — `_o setVariable ["RYD_K", 1]` → `_o setVariable [QGVAR(k), 1]`
5. `getVariable_key` — `_o getVariable ["RYD_K", 0]` → `_o getVariable [QGVAR(k), 0]`
6. `global_read` — `hint str RYD_Top` → `hint str GVAR(top)`
7. `line_comment_preserved` — `// RYD_DoNotRewrite` unchanged
8. `block_comment_preserved` — `/* RYD_DoNotRewrite */` unchanged
9. `word_boundary_negative` — `XRYD_NotATarget = 1` unchanged
10. `fuzzy_string_flagged` — `"RYD_Top was set"` unchanged + flagged
11. `extern_form_from_other_addon` — `core`-owned global read from `common` → `EGVAR(core,top)`
12. `multi_hq_sibling_detect` — 8 `RydHQ[B-H]?_Debug` siblings all flagged `multi_hq:true` with 8-element sibling list
13. `multi_hq_letter_suffix` — `RydHQB_Debug = true` → `GVAR(debugB) = true`
14. `rydhq_vs_rydhqh_distinction` — `RydHQH_Debug` captured as single token, never split

See `phase4-rename.py::run_self_test` for exact fixture bodies.
