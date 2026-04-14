#!/usr/bin/env bash
# HAL static lint — catches the defect families from the 2026-04-14 debug
# session (18 rounds, ~170 distinct bugs). Run from the repo root:
#
#     bash tests/lint-hal.sh
#
# Exits 0 if clean, 1 if any HIGH-severity defect found, 2 on tool error.
#
# Families checked (see .planning/debug/runtime-init-errors.md for the history):
#   1. Literal double-backslash in includes   (Round 3, tasking addon)
#   2. Bare function refs (call hal_X_name)   (Rounds 7, 10, 14, 15)
#   3. Cross-addon namespace split            (Rounds 12, 13, 15, 16)
#   4. Stale legacy reads (RydHQ_*/RydBB*)    (Rounds 2, 6, 7, 10, 11)
#   5. Undefended GVAR reads in loops         (Rounds 1, 2, 6, 11, 17)

set -o pipefail

ADDONS_DIR="addons"
EXIT_CODE=0
RED=$'\e[31m'
YELLOW=$'\e[33m'
GREEN=$'\e[32m'
BOLD=$'\e[1m'
RESET=$'\e[0m'

if [[ ! -d "$ADDONS_DIR" ]]; then
  echo "Error: run from repo root (no $ADDONS_DIR/ found)" >&2
  exit 2
fi

section() {
  echo
  echo "${BOLD}=== $1 ===${RESET}"
}

fail() {
  EXIT_CODE=1
  echo "${RED}FAIL${RESET} $1"
}

pass() {
  echo "${GREEN}PASS${RESET} $1"
}

warn() {
  echo "${YELLOW}WARN${RESET} $1"
}

# ---------------------------------------------------------------------------
# Family 1: literal double-backslash in #include paths
# Pattern: #include "..\\script_component.hpp"
# SQF preprocessor doesn't C-escape — leaves the double-backslash literal.
# ---------------------------------------------------------------------------
section "F1: literal \\\\ in #include paths"
F1_HITS=$(grep -rn '#include "[^"]*\\\\\\\\[^"]*"' "$ADDONS_DIR" --include='*.sqf' --include='*.hpp' --include='*.cpp' 2>/dev/null || true)
if [[ -n "$F1_HITS" ]]; then
  fail "Broken #include paths:"
  echo "$F1_HITS" | head -20
else
  pass "No literal \\\\ in #include paths"
fi

# ---------------------------------------------------------------------------
# Family 2: bare function refs (call hal_<addon>_<name>)
# Pattern: `call hal_hac_ammoCount` (bare global, not EFUNC macro)
# These only work if the function is in XEH_PREP.hpp of that addon.
# ---------------------------------------------------------------------------
section "F2: bare function refs not in XEH_PREP.hpp"
F2_HITS=$(grep -rnE '(call|spawn|execVM)[[:space:]]+hal_[a-z_]+_[a-zA-Z][a-zA-Z0-9_]*' "$ADDONS_DIR" --include='*.sqf' 2>/dev/null | grep -v '^\s*//' | grep -v 'hal_common_fnc_\|hal_core_fnc_\|hal_hac_fnc_\|hal_boss_fnc_\|hal_data_fnc_\|hal_tasking_fnc_\|hal_missionmodules_fnc_' || true)
if [[ -n "$F2_HITS" ]]; then
  warn "Potential bare function refs (verify each is in XEH_PREP.hpp):"
  echo "$F2_HITS" | head -30
  HIT_COUNT=$(echo "$F2_HITS" | wc -l)
  if (( HIT_COUNT > 5 )); then
    fail "Too many bare refs ($HIT_COUNT). Round 14 fixed 22 in one pass — fix these before shipping."
  fi
else
  pass "No bare function refs (all calls use _fnc_ compiled form)"
fi

# ---------------------------------------------------------------------------
# Family 3: cross-addon namespace split
# For each GVAR(x) read in addon A, check if x is written in addon B as
# EGVAR(B,x). That's the Phase 4 migration bug family.
#
# Simplified check: list all unique GVAR identifiers per addon, then look
# for each as an EGVAR write in another addon's XEH_preInit.sqf.
# ---------------------------------------------------------------------------
section "F3: cross-addon namespace split (reader in A, writer in B)"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# Find all GVAR(x) reads per addon
for addon_dir in "$ADDONS_DIR"/*/; do
  addon=$(basename "$addon_dir")
  # Skip compat, main — they're legacy/meta
  [[ "$addon" == "compat_nr6hal" || "$addon" == "main" ]] && continue

  # Match GVAR(x) NOT preceded by Q or E (exclude QGVAR/EGVAR/QEGVAR which are
  # either setVariable keys or cross-addon reads handled elsewhere).
  grep -rohE '(^|[^A-Za-z0-9_])GVAR\([a-zA-Z_][a-zA-Z0-9_]*\)' "$addon_dir" --include='*.sqf' 2>/dev/null \
    | grep -oE 'GVAR\([a-zA-Z_][a-zA-Z0-9_]*\)' \
    | sed -E 's/GVAR\(([^)]*)\)/\1/' \
    | sort -u > "$TMP_DIR/$addon.reads" || true
done

# Find all EGVAR(x,y) / QEGVAR(x,y) writes across all addons
grep -rohE '(E|QE)GVAR\(([a-zA-Z_]+),([a-zA-Z_][a-zA-Z0-9_]*)\)[[:space:]]*=' "$ADDONS_DIR" --include='*.sqf' --include='*.hpp' 2>/dev/null \
  | sed -E 's/.*GVAR\(([^,]+),([^)]*)\).*/\1 \2/' \
  | sort -u > "$TMP_DIR/all_egvar_writes" || true

F3_HITS=0
for reads_file in "$TMP_DIR"/*.reads; do
  addon=$(basename "$reads_file" .reads)
  while read -r varname; do
    [[ -z "$varname" ]] && continue
    # Skip common vars that have many legitimate cross-addon uses
    case "$varname" in
      debug|active|included|friends|excluded) continue ;;
    esac
    # Check if this var is written by another addon's EGVAR
    other_writer=$(awk -v v="$varname" -v self="$addon" '$2 == v && $1 != self {print $1; exit}' "$TMP_DIR/all_egvar_writes")
    if [[ -n "$other_writer" ]]; then
      # Also check: is it written in the SAME addon too? If yes, not a split.
      self_writer=$(grep -l "GVAR($varname)[[:space:]]*=" "$ADDONS_DIR/$addon/" -r --include='*.sqf' 2>/dev/null || true)
      if [[ -z "$self_writer" ]]; then
        if [[ $F3_HITS -eq 0 ]]; then
          warn "Cross-addon GVAR reads (reader addon has no writer, another addon does):"
        fi
        echo "  $addon reads GVAR($varname) — written by $other_writer"
        F3_HITS=$((F3_HITS + 1))
      fi
    fi
  done < "$reads_file"
done

if [[ $F3_HITS -eq 0 ]]; then
  pass "No obvious cross-addon GVAR splits"
elif (( F3_HITS > 5 )); then
  fail "$F3_HITS cross-addon splits — use EGVAR(writerAddon,x) in the reader"
fi

# ---------------------------------------------------------------------------
# Family 4: stale legacy reads (RydHQ_*/RydBB*/Rydx*)
# Any uncommented reference outside compat_nr6hal is suspicious.
# ---------------------------------------------------------------------------
section "F4: stale legacy reads (RydHQ_/RydBB/Rydx) outside compat_nr6hal"
F4_HITS=$(grep -rnE 'Ryd(HQ_|BB[a-z]?_|x[A-Z])' "$ADDONS_DIR" --include='*.sqf' 2>/dev/null \
  | grep -v 'compat_nr6hal' \
  | grep -v '^\s*//' \
  | grep -vE '^\s*\*' \
  || true)

F4_COUNT=$(echo -n "$F4_HITS" | grep -c '' 2>/dev/null || echo 0)
if [[ $F4_COUNT -eq 0 ]]; then
  pass "No stale legacy reads in live code"
elif (( F4_COUNT < 20 )); then
  warn "$F4_COUNT legacy refs outside compat (mostly setVariable string keys — expected). First 10:"
  echo "$F4_HITS" | head -10
else
  warn "$F4_COUNT legacy refs outside compat. Many are setVariable string keys (internal storage, OK)."
  warn "Review after Phase 6 to identify any that should be renamed."
fi

# ---------------------------------------------------------------------------
# Family 5: undefended GVAR reads in loops / arithmetic
# Pattern: `GVAR(x) pushBack`, `+GVAR(x)`, `forEach GVAR(x)`, `count GVAR(x)`
# Without an isNil guard or default. These crash if the var wasn't seeded.
# ---------------------------------------------------------------------------
section "F5: undefended GVAR operations (no isNil/default guard)"
F5_HITS=$(grep -rnE '(pushBack|forEach|count|\+|select)[[:space:]]+[^QE]?GVAR\(' "$ADDONS_DIR" --include='*.sqf' 2>/dev/null \
  | grep -v '^\s*//' \
  || true)
F5_COUNT=$(echo -n "$F5_HITS" | grep -c '' 2>/dev/null || echo 0)
if [[ $F5_COUNT -eq 0 ]]; then
  pass "All GVAR operations are guarded"
else
  warn "$F5_COUNT undefended GVAR operations. Spot-check each for isNil/preInit seed:"
  echo "$F5_HITS" | head -15
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
section "SUMMARY"
if [[ $EXIT_CODE -eq 0 ]]; then
  echo "${GREEN}HAL lint CLEAN${RESET} — no HIGH severity defects found."
  echo "Run this before committing any refactor that touches addons/."
else
  echo "${RED}HAL lint FAILED${RESET} — HIGH severity defects detected. See above."
  echo "Reference: .planning/debug/runtime-init-errors.md for fix patterns."
fi

exit $EXIT_CODE
