# NR6-HAL Refactor

## What This Is

NR6-HAL is an Arma 3 AI command and control mod that provides an autonomous AI commander (HAL) capable of managing infantry, vehicles, artillery, and reinforcements. V1 refactors the core `nr6_hal` module to match ACE3 community standards — full CBA integration, HEMTT-clean builds, and modern Arma 3 mod structure — without breaking existing functionality.

## Core Value

Existing HAL AI behavior must continue working identically after refactoring. Structure changes, not behavior changes.

## Requirements

### Validated

- ✓ AI HQ commander with personality traits (Recklessness, Consistency, Activity, Reflex, Circumspection, Fineness) — existing
- ✓ Group management: spawn, assign waypoints, manage objectives — existing
- ✓ Enemy scanning and threat detection loops — existing
- ✓ Artillery/fire support coordination — existing
- ✓ Mission module system (editor-placed modules for configuration) — existing
- ✓ AI chatter/radio communication system — existing
- ✓ Reinforcement system (air and logistics) — existing (nr6_reinforcements, deferred for restructure)
- ✓ Civilian ambient life system (ALICE2) — existing (nr6_alice2, deferred for restructure)
- ✓ Defensive site management — existing (nr6_sites, deferred for restructure)
- ✓ CBA dependency and XEH event handlers — existing (addons/ layer)
- ✓ HEMTT build system configured — existing

### Active

- [ ] Migrate nr6_hal into addons/ with ACE3-compliant structure
- [ ] Split monolithic files (HAC_fnc.sqf, Boss.sqf, Boss_fnc.sqf, RHQLibrary.sqf, HAC_fnc2.sqf) into individual CBA-compiled functions
- [ ] ACE3 settings framework integration (CBA settings for all configurable options)
- [ ] Stringtable.xml localization for all user-facing strings
- [ ] Clean HEMTT build with zero errors and zero warnings
- [ ] Fix bugs discovered during refactoring and HEMTT build
- [ ] Standardize variable declaration (params syntax throughout)
- [ ] Compatibility addon mapping old classnames to new ones
- [ ] Proper CBA macros (PREP, GVAR, QGVAR, FUNC, EFUNC) throughout migrated code
- [ ] Remove commented-out/dead code from migrated files

### Out of Scope

- Migrate nr6_alice2 into addons/ — deferred to V2 (focus on core HAL first)
- Migrate nr6_reinforcements into addons/ — deferred to V2
- Migrate nr6_sites/nr6_sitemarkers into addons/ — deferred to V2
- Migrate nr6_tools into addons/ — deferred to V2
- New AI features or behavior changes — V1 is structure-only refactor
- Automated testing framework — desirable but out of V1 scope
- Performance optimization beyond what refactoring naturally improves — deferred
- UI/dialog redesign — keep existing UI working

## Context

- **Existing architecture:** Two-layer codebase. `addons/` already follows CBA/ACE3 conventions partially. `nr6_*/` folders are legacy standalone modules with monolithic files and global variables.
- **ACE3 reference:** https://github.com/acemod/ACE3 is the gold standard for structure, naming, macro usage, settings framework, and localization.
- **HEMTT:** Already configured (`.hemtt/project.toml`, `.hemtt/launch.toml`) but builds with errors/warnings that need fixing.
- **Key monolithic files to split:**
  - `nr6_hal/HAC_fnc.sqf` (5645 lines)
  - `nr6_hal/HAC_fnc2.sqf` (3389 lines)
  - `nr6_hal/RHQLibrary.sqf` (2491 lines)
  - `nr6_hal/Boss_fnc.sqf` (2202 lines)
  - `nr6_hal/Boss.sqf` (2021 lines)
- **Global variables:** Hundreds of `RYD*`, `RHQ*`, `RydBB*` globals need proper namespacing with CBA GVAR macros.
- **CBA version:** 3.16.0 required dependency.
- **Arma 3 version:** 2.14+ required.

## Constraints

- **Backward compatibility**: Old classnames must remain accessible via compatibility addon — existing missions must not break
- **No behavior changes**: AI logic must produce identical results after refactoring
- **ACE3 standard**: Follow ACE3 coding guidelines for file structure, naming, macros, config.cpp patterns
- **HEMTT build**: Project must build cleanly with HEMTT — zero errors, zero warnings
- **CBA dependency**: Must maintain CBA 3.16.0+ as core dependency

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Migrate nr6_hal only in V1 | Largest, most critical module — proves the pattern before tackling others | -- Pending |
| Full ACE3 parity (not just structure) | User wants settings framework, localization, the full standard | -- Pending |
| Split monolithic files into CBA functions | Files are 2000-5600 lines — unmaintainable, ACE3 uses individual fnc_*.sqf files | -- Pending |
| Compatibility addon for old classnames | Missions shouldn't break — compat layer maps old to new | -- Pending |
| Fix bugs found via HEMTT + refactor only | No proactive bug hunting — fix what surfaces naturally | -- Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? -> Move to Out of Scope with reason
2. Requirements validated? -> Move to Validated with phase reference
3. New requirements emerged? -> Add to Active
4. Decisions to log? -> Add to Key Decisions
5. "What This Is" still accurate? -> Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-09 after initialization*
