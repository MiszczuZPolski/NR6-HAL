# Extraction Validation Report

**Run date:** 2026-04-10
**Script:** work/extract-edges.sh
**Repo root:** N:/arma3/NR6-HAL/

## Declaration Count Validation

| File | Expected (Research §1.1) | Actual | Status |
|------|--------------------------|--------|--------|
| nr6_hal/HAC_fnc.sqf | 10 | 10 | PASS |
| nr6_hal/HAC_fnc2.sqf | 10 (7 RYD_ + 3 HAL_) | 10 | PASS |
| nr6_hal/RHQLibrary.sqf | 31 | 31 | PASS |
| nr6_hal/Boss_fnc.sqf | 21 | 21 | PASS |
| nr6_hal/Boss.sqf | 0 | 0 | PASS |
| nr6_hal/TaskInitNR6.sqf | 72 | 72 | PASS |
| nr6_hal/SquadTaskingNR6.sqf | 0 | 0 | PASS |
| **Total** | **~144** | **144** | **PASS** |

## Call Edge Count Validation

| Edge Type | Count |
|-----------|-------|
| call | 234 |
| spawn | 13 |
| value_pass | 22 |
| remote_exec | 56 |
| **Total** | **325** |

### value_pass Edges — Boss.sqf (Research §4, item 5)

Expected: lines 661, 1338, 1829, 1901, 1924

| File | Line | Callee | Status |
|------|------|--------|--------|
| nr6_hal/Boss.sqf | 661 | RYD_ObjMark | FOUND |
| nr6_hal/Boss.sqf | 1338 | RYD_BBSimpleD | FOUND |
| nr6_hal/Boss.sqf | 1829 | RYD_ExecutePath | FOUND |
| nr6_hal/Boss.sqf | 1901 | RYD_ReserveExecuting | FOUND |
| nr6_hal/Boss.sqf | 1924 | RYD_ObjectivesMon | FOUND |

All 5 expected value_pass edges confirmed.

## Migration Map Validation

| Metric | Expected | Actual | Status |
|--------|----------|--------|--------|
| Provenance entries | ≥41 | 40 | WITHIN TOLERANCE |

### Discrepancy Explanation

Research §3.1 stated "41 verified provenance comments". Direct grep of
`addons/common/functions/` and `addons/core/functions/` finds 42 raw
"Originally from" occurrences, but 2 lack a parenthesized symbol name:

- `addons/core/functions/fnc_init.sqf:2` — "Originally from RydHQInit.sqf"
  (no symbol in parens — whole-file migration, not a single function)
- `addons/core/functions/fnc_personality.sqf:2` — "Originally from HAL\Personality.sqf"
  (same — whole-file, backslash path, no symbol)

These 2 do not produce migration map rows because there is no single legacy
RYD_/HAL_ symbol to record. The 40 captured entries are all valid symbol
mappings. This is within the ±2 tolerance specified in the plan.

## Regex Tuning Notes

### Split-line Declaration Form (Discovery)

**Issue:** The initial script regex `^(RYD_|HAL_)+\s*=\s*\{` (requiring `{` on same
line) produced 0 results for HAC_fnc.sqf, RHQLibrary.sqf, and Boss_fnc.sqf.

**Root cause:** These files use split-line declaration style:
```
RYD_Marker =
{
    ...
};
```
while HAC_fnc2.sqf uses same-line style:
```
RYD_StatusQuo = {
    ...
};
```

**Fix:** Changed pattern to `^(RYD_|HAL_)[A-Za-z0-9_]+[[:space:]]*=` (without
requiring `{` or `[` on same line). The `^` anchor excludes indented internal
assignments. Classification by symbol prefix (RYD_WS_ / RHQ_ = data_array,
others = code_fn).

## Overall Result

**PASS** — All declaration counts match research ground truth exactly.
All 5 expected dynamic dispatch value_pass edges captured. Migration map at 40
entries (within ±2 tolerance of expected 41). TSVs are valid input for
Phase 2 Wave 2 enrichment plans (02-02, 02-03, 02-04).
