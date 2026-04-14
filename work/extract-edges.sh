#!/usr/bin/env bash
# extract-edges.sh — Phase 2 Dependency Mapping: Scripted Extraction Pass
#
# Produces three TSV artifacts under work/ from the 7 in-scope legacy files:
#   work/raw-declarations.tsv   — every symbol declaration with file + line
#   work/raw-call-edges.tsv     — every caller→callee edge found by regex
#   work/raw-migration-map.tsv  — legacy→migrated provenance from // Originally from comments
#
# Run from repo root: N:/arma3/NR6-HAL/
#   bash work/extract-edges.sh
#
# Idempotent: wipes and recreates all three TSVs on each run.
# Windows git-bash compatible (POSIX grep + sed + bash builtins).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "${REPO_ROOT}"

WORK_DIR="${REPO_ROOT}/work"
DECL_TSV="${WORK_DIR}/raw-declarations.tsv"
EDGES_TSV="${WORK_DIR}/raw-call-edges.tsv"
MMAP_TSV="${WORK_DIR}/raw-migration-map.tsv"

# ---------------------------------------------------------------------------
# 7 in-scope legacy files (D-07)
# ---------------------------------------------------------------------------
LEGACY_FILES=(
    "nr6_hal/HAC_fnc.sqf"
    "nr6_hal/HAC_fnc2.sqf"
    "nr6_hal/RHQLibrary.sqf"
    "nr6_hal/Boss_fnc.sqf"
    "nr6_hal/Boss.sqf"
    "nr6_hal/TaskInitNR6.sqf"
    "nr6_hal/SquadTaskingNR6.sqf"
)

# ---------------------------------------------------------------------------
# Helper: grep that never fails with exit code 1 (no matches = ok)
# Usage: safe_grep [grep-args...] || true
# We use a wrapper so set -e doesn't abort on zero-result greps.
# ---------------------------------------------------------------------------
safe_grep() {
    grep "$@" || true
}

# ---------------------------------------------------------------------------
# Verify all files exist before touching outputs
# ---------------------------------------------------------------------------
for f in "${LEGACY_FILES[@]}"; do
    if [[ ! -f "${REPO_ROOT}/${f}" ]]; then
        echo "ERROR: expected legacy file not found: ${f}" >&2
        exit 1
    fi
done

echo "All 7 legacy files found. Starting extraction..."

# ---------------------------------------------------------------------------
# 1. raw-declarations.tsv
#    Header: file<TAB>line<TAB>symbol<TAB>pattern
#
#    Captures (anchored at column 0, non-commented lines):
#      a. RYD_<name> = {   — code function declarations (same-line or split-line)
#      b. HAL_<name> = {   — HAL_ code function declarations (HAC_fnc2.sqf)
#      c. RYD_WS_<name> = [  or  RYD_<name> = [  — data array declarations (RHQLibrary.sqf)
#         RHQLibrary.sqf uses split-line form: "RYD_WS_name =\n["
#      d. Action<N><suffix> = {  and  ACEAction<N><suffix> = {  — TaskInitNR6.sqf
#
#    Most files use SPLIT-LINE declarations (symbol =\n{) rather than same-line.
#    HAC_fnc2.sqf uses SAME-LINE (symbol = {).
#    The pattern ^SYMBOL[space]*= captures both since we anchor at column 0 and
#    internal assignments always have leading whitespace (tab indent).
#
#    Classification by symbol prefix:
#      RYD_WS_* or RHQ_* → data_array
#      All other RYD_/HAL_ → code_fn
#      Action*/ACEAction* → action_fn
# ---------------------------------------------------------------------------

printf 'file\tline\tsymbol\tpattern\n' > "${DECL_TSV}"

for src in "${LEGACY_FILES[@]}"; do
    # Pattern a+b: RYD_ or HAL_ declarations (handles both same-line and split-line = / = {)
    # Anchored at col 0 so indented internal assignments are excluded.
    safe_grep -nE '^(RYD_|HAL_)[A-Za-z0-9_]+[[:space:]]*=' "${src}" \
    | while IFS=: read -r lineno rest; do
        symbol=$(printf '%s' "${rest}" | sed -E 's/^([A-Za-z0-9_]+).*/\1/')
        # Classify by prefix: RYD_WS_ and RHQ_ are data arrays
        if printf '%s' "${symbol}" | grep -qE '^RYD_WS_|^RHQ_'; then
            pat="data_array"
        else
            pat="code_fn"
        fi
        printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "${pat}"
    done >> "${DECL_TSV}"

    # Pattern d: Action* and ACEAction* declarations (TaskInitNR6.sqf scheme)
    # These use split-line form too: "Action1ct =\n{"
    safe_grep -nE '^(ACE)?Action[0-9A-Za-z]+[[:space:]]*=' "${src}" \
    | while IFS=: read -r lineno rest; do
        symbol=$(printf '%s' "${rest}" | sed -E 's/^([A-Za-z0-9_]+).*/\1/')
        printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "action_fn"
    done >> "${DECL_TSV}"
done

DECL_COUNT=$(( $(wc -l < "${DECL_TSV}") - 1 ))

# ---------------------------------------------------------------------------
# 2. raw-call-edges.tsv
#    Header: caller_file<TAB>caller_line<TAB>callee_symbol<TAB>edge_type
#
#    Edge types:
#      call        — direct `call RYD_/HAL_` invocation
#      spawn       — direct `spawn RYD_/HAL_` invocation
#      value_pass  — function reference passed as array element: `, RYD_Fn]`
#      remote_exec — remoteExecCall ["ActionXxx"] string dispatch
#
#    Note: commented lines (// ...) may still be captured; the LLM semantic
#    review pass (Plans 02-02/03/04) will classify and filter.
# ---------------------------------------------------------------------------

printf 'caller_file\tcaller_line\tcallee_symbol\tedge_type\n' > "${EDGES_TSV}"

for src in "${LEGACY_FILES[@]}"; do
    # Edge type: call — `call RYD_*` or `call HAL_*`
    safe_grep -nE '\bcall[[:space:]]+(RYD_|HAL_)[A-Za-z0-9_]+' "${src}" \
    | while IFS=: read -r lineno rest; do
        printf '%s' "${rest}" | grep -oE '\bcall[[:space:]]+(RYD_|HAL_)[A-Za-z0-9_]+' \
        | while read -r match; do
            symbol=$(printf '%s' "${match}" | sed -E 's/.*call[[:space:]]+//')
            printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "call"
        done
    done >> "${EDGES_TSV}"

    # Edge type: spawn — `spawn RYD_*` or `spawn HAL_*`
    safe_grep -nE '\bspawn[[:space:]]+(RYD_|HAL_)[A-Za-z0-9_]+' "${src}" \
    | while IFS=: read -r lineno rest; do
        printf '%s' "${rest}" | grep -oE '\bspawn[[:space:]]+(RYD_|HAL_)[A-Za-z0-9_]+' \
        | while read -r match; do
            symbol=$(printf '%s' "${match}" | sed -E 's/.*spawn[[:space:]]+//')
            printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "spawn"
        done
    done >> "${EDGES_TSV}"

    # Edge type: value_pass — `, RYD_Fn]` pattern
    # Captures [args, RYD_ExecutePath] call RYD_Spawn — dynamic dispatch sites
    # Research section 4 item 5: Boss.sqf lines 661, 1338, 1829, 1901, 1924
    # Research section 4 item 6: Boss_fnc.sqf lines 1290-1293
    safe_grep -nE ',[[:space:]]*(RYD_|HAL_)[A-Za-z0-9_]+[[:space:]]*\]' "${src}" \
    | while IFS=: read -r lineno rest; do
        printf '%s' "${rest}" | grep -oE '(RYD_|HAL_)[A-Za-z0-9_]+[[:space:]]*\]' \
        | while read -r match; do
            symbol=$(printf '%s' "${match}" | sed -E 's/[[:space:]]*\]$//')
            printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "value_pass"
        done
    done >> "${EDGES_TSV}"

    # Edge type: remote_exec — remoteExecCall ["ActionXxx", ...]
    # String-dispatch to TaskInitNR6 Action* functions from SquadTaskingNR6.sqf
    safe_grep -nE 'remoteExecCall[[:space:]]*\[[[:space:]]*"(Action|ACEAction)[A-Za-z0-9]+"' "${src}" \
    | while IFS=: read -r lineno rest; do
        printf '%s' "${rest}" | grep -oE '"(Action|ACEAction)[A-Za-z0-9]+"' \
        | while read -r match; do
            symbol=$(printf '%s' "${match}" | tr -d '"')
            printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "remote_exec"
        done
    done >> "${EDGES_TSV}"
done

EDGES_COUNT=$(( $(wc -l < "${EDGES_TSV}") - 1 ))

# ---------------------------------------------------------------------------
# 3. raw-migration-map.tsv
#    Header: legacy_symbol<TAB>migrated_path<TAB>provenance_file
#
#    Scans addons/common/functions/ and addons/core/functions/ for provenance
#    comments matching: // Originally from <File>.sqf (LegacySymbol)
#    Research section 3.1 verified exactly 41 such comments exist.
# ---------------------------------------------------------------------------

printf 'legacy_symbol\tmigrated_path\tprovenance_file\n' > "${MMAP_TSV}"

safe_grep -rnE '//[[:space:]]*Originally from[[:space:]]+[A-Za-z0-9_.]+\.sqf[[:space:]]*\(([A-Za-z0-9_]+)\)' \
    addons/common/functions/ addons/core/functions/ \
| while IFS=: read -r filepath lineno rest; do
    legacy_symbol=$(printf '%s' "${rest}" | grep -oE '\([A-Za-z0-9_]+\)' | tr -d '()')
    if [[ -n "${legacy_symbol}" ]]; then
        printf '%s\t%s\t%s\n' "${legacy_symbol}" "${filepath}" "${filepath}"
    fi
done >> "${MMAP_TSV}"

MMAP_COUNT=$(( $(wc -l < "${MMAP_TSV}") - 1 ))

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo ""
echo "EXTRACT COMPLETE: ${DECL_COUNT} declarations, ${EDGES_COUNT} call edges, ${MMAP_COUNT} migration entries"
echo ""
echo "Output files:"
echo "  ${DECL_TSV}"
echo "  ${EDGES_TSV}"
echo "  ${MMAP_TSV}"
