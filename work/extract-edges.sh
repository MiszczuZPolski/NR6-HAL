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
# Windows git-bash compatible (no gawk/awk assumed, uses grep + sed + bash builtins).

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
#      a. RYD_<name> = {   — code function declarations
#      b. HAL_<name> = {   — HAL_ code function declarations (HAC_fnc2.sqf)
#      c. RYD_WS_<name> = [  or  RYD_<name> = [   — data array declarations (RHQLibrary.sqf)
#      d. Action<N><suffix> = {  and  ACEAction<N><suffix> = {  — TaskInitNR6.sqf scheme
#
#    grep -n returns file:line:match; we parse with sed to produce TSV columns.
#    Lines starting with // (comments) are excluded by the anchor (no space before RYD_/HAL_).
# ---------------------------------------------------------------------------

echo -e "file\tline\tsymbol\tpattern" > "${DECL_TSV}"

for src in "${LEGACY_FILES[@]}"; do
    # Pattern a+b: RYD_ or HAL_ function declarations (assignment to {)
    grep -nE '^(RYD_|HAL_)[A-Za-z0-9_]+[[:space:]]*=[[:space:]]*\{' "${src}" \
    | while IFS=: read -r lineno rest; do
        symbol=$(echo "${rest}" | sed -E 's/^([A-Za-z0-9_]+).*/\1/')
        if echo "${symbol}" | grep -qE '^RYD_WS_|^RHQ_'; then
            pat="data_array"
        else
            pat="code_fn"
        fi
        printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "${pat}"
    done >> "${DECL_TSV}"

    # Pattern c: RYD_WS_ or RHQ_ data arrays (assignment to [)
    grep -nE '^(RYD_|RHQ_)[A-Za-z0-9_]+[[:space:]]*=[[:space:]]*\[' "${src}" \
    | while IFS=: read -r lineno rest; do
        symbol=$(echo "${rest}" | sed -E 's/^([A-Za-z0-9_]+).*/\1/')
        printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "data_array"
    done >> "${DECL_TSV}"

    # Pattern d: Action* and ACEAction* declarations (TaskInitNR6.sqf scheme)
    grep -nE '^(ACE)?Action[0-9A-Za-z]+[[:space:]]*=[[:space:]]*\{' "${src}" \
    | while IFS=: read -r lineno rest; do
        symbol=$(echo "${rest}" | sed -E 's/^([A-Za-z0-9_]+).*/\1/')
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
#      value_pass  — function reference passed as value: `, RYD_Fn]` pattern
#      remote_exec — `remoteExecCall ["ActionXxx"` string dispatch (TaskInitNR6 scheme)
#
#    Commented lines (leading //) are excluded by requiring the symbol appears
#    after the call/spawn keyword — commented lines still get picked up but
#    are flagged by the presence of "//" before the keyword on that line.
#    We keep them — the LLM semantic review pass filters commented context.
# ---------------------------------------------------------------------------

echo -e "caller_file\tcaller_line\tcallee_symbol\tedge_type" > "${EDGES_TSV}"

for src in "${LEGACY_FILES[@]}"; do
    # Edge type: call — `call RYD_*` or `call HAL_*`
    # grep returns entire matching line; extract symbol with sed
    grep -nE '\bcall[[:space:]]+(RYD_|HAL_)[A-Za-z0-9_]+' "${src}" \
    | while IFS=: read -r lineno rest; do
        # Extract all matching callee symbols from the line (may be multiple)
        echo "${rest}" | grep -oE '\bcall[[:space:]]+(RYD_|HAL_)[A-Za-z0-9_]+' \
        | while read -r match; do
            symbol=$(echo "${match}" | sed -E 's/.*call[[:space:]]+//')
            printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "call"
        done
    done >> "${EDGES_TSV}"

    # Edge type: spawn — `spawn RYD_*` or `spawn HAL_*`
    grep -nE '\bspawn[[:space:]]+(RYD_|HAL_)[A-Za-z0-9_]+' "${src}" \
    | while IFS=: read -r lineno rest; do
        echo "${rest}" | grep -oE '\bspawn[[:space:]]+(RYD_|HAL_)[A-Za-z0-9_]+' \
        | while read -r match; do
            symbol=$(echo "${match}" | sed -E 's/.*spawn[[:space:]]+//')
            printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "spawn"
        done
    done >> "${EDGES_TSV}"

    # Edge type: value_pass — `, RYD_Fn]` or `, HAL_Fn]`
    # Pattern: comma then optional space then RYD_/HAL_ symbol then ] (closing array)
    # This captures [args, RYD_ExecutePath] call RYD_Spawn style dynamic dispatch
    grep -nE ',[[:space:]]*(RYD_|HAL_)[A-Za-z0-9_]+[[:space:]]*\]' "${src}" \
    | while IFS=: read -r lineno rest; do
        echo "${rest}" | grep -oE '(RYD_|HAL_)[A-Za-z0-9_]+[[:space:]]*\]' \
        | while read -r match; do
            symbol=$(echo "${match}" | sed -E 's/[[:space:]]*\]$//')
            printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "value_pass"
        done
    done >> "${EDGES_TSV}"

    # Edge type: remote_exec — remoteExecCall ["ActionXxx", ...]
    # Captures string-dispatch to TaskInitNR6 Action* functions
    grep -nE 'remoteExecCall[[:space:]]*\[[[:space:]]*"(Action|ACEAction)[A-Za-z0-9]+"' "${src}" \
    | while IFS=: read -r lineno rest; do
        echo "${rest}" | grep -oE '"(Action|ACEAction)[A-Za-z0-9]+"' \
        | while read -r match; do
            symbol=$(echo "${match}" | tr -d '"')
            printf '%s\t%s\t%s\t%s\n' "${src}" "${lineno}" "${symbol}" "remote_exec"
        done
    done >> "${EDGES_TSV}"
done

EDGES_COUNT=$(( $(wc -l < "${EDGES_TSV}") - 1 ))

# ---------------------------------------------------------------------------
# 3. raw-migration-map.tsv
#    Header: legacy_symbol<TAB>migrated_path<TAB>provenance_file
#
#    Scans addons/common/functions/ and addons/core/functions/ for comments
#    matching the format: // Originally from <SourceFile>.sqf (RYD_SymbolName)
#    or:                  // Originally from <SourceFile>.sqf (HAL_SymbolName)
#
#    Research section 3.1 documents exactly 41 such comments.
# ---------------------------------------------------------------------------

echo -e "legacy_symbol\tmigrated_path\tprovenance_file" > "${MMAP_TSV}"

grep -rnE '//[[:space:]]*Originally from[[:space:]]+[A-Za-z0-9_]+\.sqf[[:space:]]*\(([A-Za-z0-9_]+)\)' \
    addons/common/functions/ addons/core/functions/ \
| while IFS=: read -r filepath lineno rest; do
    # Extract the parenthesized legacy symbol name
    legacy_symbol=$(echo "${rest}" | grep -oE '\([A-Za-z0-9_]+\)' | tr -d '()')
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
