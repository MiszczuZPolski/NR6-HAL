# Requirements: NR6-HAL ACE3 Refactor

**Defined:** 2026-04-09
**Core Value:** Existing HAL AI behavior must continue working identically after refactoring

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Build Infrastructure

- [ ] **BUILD-01**: HEMTT builds project with zero errors
- [ ] **BUILD-02**: HEMTT builds project with zero warnings
- [ ] **BUILD-03**: Subsystem addon skeletons exist under `addons/hal_data/`, `addons/hal_hac/`, `addons/hal_boss/`, `addons/hal_tasking/` each with correct `$PBOPREFIX$`, `script_component.hpp`, `config.cpp`, `CfgEventHandlers.hpp`, XEH files (per D-01 4-way split)
- [ ] **BUILD-04**: `addons/compat_nr6hal/` compatibility addon skeleton exists
- [ ] **BUILD-05**: `mod.cpp` contains correct project metadata (not ACE3 placeholder text)

### Function Migration

- [ ] **FUNC-01**: Full inter-function call graph documented for all 7 legacy files (HAC_fnc.sqf, HAC_fnc2.sqf, RHQLibrary.sqf, Boss_fnc.sqf, Boss.sqf, TaskInitNR6.sqf, SquadTaskingNR6.sqf)
- [ ] **FUNC-02**: All active functions classified (active/dead/already-migrated) with target destination
- [ ] **FUNC-03**: `RHQLibrary.sqf` weapon class arrays migrated to `fnc_initWeaponClasses.sqf` in addons/
- [ ] **FUNC-04**: All active `HAC_fnc.sqf` functions (~10 remaining) extracted to individual `fnc_*.sqf` files
- [ ] **FUNC-05**: All active `HAC_fnc2.sqf` functions extracted to individual `fnc_*.sqf` files
- [ ] **FUNC-06**: All active `Boss_fnc.sqf` functions (~20) extracted to individual `fnc_*.sqf` files in `addons/core/functions/`
- [ ] **FUNC-07**: `Boss.sqf` migrated to `fnc_boss.sqf` with all internal call sites updated — Boss.sqf external call edges (RYD_*/HAL_*) updated to EFUNC() in Phase 3; full imperative main-loop migration is Phase 4 per D-06
- [ ] **FUNC-08**: `RYD_StatusQuo` (1779 lines) decomposed into sub-functions under 250 lines each
- [ ] **FUNC-09**: Every migrated function registered in `XEH_PREP.hpp` with correct PREP ordering (leaf functions first)
- [ ] **FUNC-10**: Every migrated function file includes `#include "script_component.hpp"` header

### Code Standards

- [ ] **STD-01**: All migrated functions use `params` syntax (not `_this select N` or `private ["_var"]`)
- [ ] **STD-02**: All migrated functions use `private` keyword for local variable declarations
- [ ] **STD-03**: All commented-out/dead code removed from migrated files
- [ ] **STD-04**: All function call sites use `FUNC()`/`EFUNC()` macros instead of hardcoded function names

### Variable Namespacing

- [x] **VAR-01**: All `RYD*`/`RHQ*`/`RydBB*` global variables replaced with `GVAR()`/`QGVAR()` macros
- [x] **VAR-02**: All `publicVariable` calls updated to use `QGVAR()` string references
- [x] **VAR-03**: All `isNil "RydHQ_..."` guards converted to use `QGVAR()` references
- [x] **VAR-04**: Each variable renamed atomically (assignment + publicVariable + all readers in same commit)

### Settings & Localization

- [ ] **SET-01**: CBA settings framework integrated via `CBA_fnc_addSetting` in `initSettings.inc.sqf`
- [ ] **SET-02**: All configurable options (currently in mission module Arguments) exposed as CBA settings
- [ ] **SET-03**: `stringtable.xml` created with English localization for all user-facing strings
- [ ] **SET-04**: All settings display names and descriptions use `LSTRING()` macro referencing stringtable.xml

### Compatibility

- [ ] **COMPAT-01**: Compatibility addon maps all old module classnames to new classnames via CfgVehicles inheritance
- [ ] **COMPAT-02**: `compat_vars.sqf` assigns all legacy function variable names to new `hal_*_fnc_*` references
- [ ] **COMPAT-03**: Existing missions using old classnames load and function correctly with compat addon enabled
- [ ] **COMPAT-04**: Legacy `nr6_hal/` directory removed after all functions migrated and verified

### Behavior Preservation

- [ ] **BEHAV-01**: AI HQ commander initializes with identical personality traits and state variables
- [ ] **BEHAV-02**: Group management (spawn, waypoints, objectives) produces identical behavior
- [ ] **BEHAV-03**: Enemy scanning and threat detection loops function identically
- [ ] **BEHAV-04**: Artillery/fire support coordination produces identical results
- [ ] **BEHAV-05**: AI chatter/radio communication system works identically

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Module Migration

- **MOD-01**: Migrate `nr6_alice2` (civilian ambient life) into addons/ structure
- **MOD-02**: Migrate `nr6_reinforcements` into addons/ structure
- **MOD-03**: Migrate `nr6_sites`/`nr6_sitemarkers` into addons/ structure
- **MOD-04**: Migrate `nr6_tools` into addons/ structure

### Testing

- **TEST-01**: Automated test framework for utility functions
- **TEST-02**: Regression test suite for core AI behaviors

### Performance

- **PERF-01**: Optimize entity queries (replace 100000m nearEntities with location-based approach)
- **PERF-02**: Cache repeated group string conversions
- **PERF-03**: Replace array concatenation in loops with pushBack

## Out of Scope

| Feature | Reason |
|---------|--------|
| AI behavior changes | V1 is structure-only refactor — behavior must be identical |
| New gameplay features | Scope creep risk; structure must be stable first |
| UI/dialog redesign | Keep existing UI working; cosmetic changes are V2+ |
| Multi-language localization | English baseline only for V1; other languages in V2+ |
| Performance optimization | Only fix what naturally improves during refactoring |
| nr6_alice2/reinforcements/sites migration | Focus on core HAL first; proves the pattern |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| BUILD-01 | Phase 1 | Pending |
| BUILD-02 | Phase 1 | Pending |
| BUILD-03 | Phase 1 | Pending |
| BUILD-04 | Phase 1 | Pending |
| BUILD-05 | Phase 1 | Pending |
| FUNC-01 | Phase 2 | Pending |
| FUNC-02 | Phase 2 | Pending |
| FUNC-03 | Phase 3 | Pending |
| FUNC-04 | Phase 3 | Pending |
| FUNC-05 | Phase 3 | Pending |
| FUNC-06 | Phase 3 | Pending |
| FUNC-07 | Phase 3 | Pending |
| FUNC-08 | Phase 3 | Pending |
| FUNC-09 | Phase 3 | Pending |
| FUNC-10 | Phase 3 | Pending |
| STD-01 | Phase 3 | Pending |
| STD-02 | Phase 3 | Pending |
| STD-03 | Phase 3 | Pending |
| STD-04 | Phase 3 | Pending |
| VAR-01 | Phase 4 | Complete |
| VAR-02 | Phase 4 | Complete |
| VAR-03 | Phase 4 | Complete |
| VAR-04 | Phase 4 | Complete |
| SET-01 | Phase 5 | Pending |
| SET-02 | Phase 5 | Pending |
| SET-03 | Phase 5 | Pending |
| SET-04 | Phase 5 | Pending |
| COMPAT-01 | Phase 5 | Pending |
| COMPAT-02 | Phase 5 | Pending |
| COMPAT-03 | Phase 5 | Pending |
| COMPAT-04 | Phase 5 | Pending |
| BEHAV-01 | Phase 5 | Pending |
| BEHAV-02 | Phase 5 | Pending |
| BEHAV-03 | Phase 5 | Pending |
| BEHAV-04 | Phase 5 | Pending |
| BEHAV-05 | Phase 5 | Pending |

**Coverage:**
- v1 requirements: 37 total
- Mapped to phases: 37
- Unmapped: 0 ✓

---
*Requirements defined: 2026-04-09*
*Last updated: 2026-04-10 — BUILD-03 updated to reflect 4-way addon split per D-01*
