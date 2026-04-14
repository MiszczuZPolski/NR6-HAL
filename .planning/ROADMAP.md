# Roadmap: NR6-HAL ACE3 Refactor

**Project:** NR6-HAL — Migrate nr6_hal to ACE3/CBA-compliant addon structure
**Core Value:** Existing HAL AI behavior must continue working identically after refactoring
**Milestone:** V1 Refactor
**Created:** 2026-04-09
**Granularity:** Coarse (5 phases)

---

## Phases

- [x] **Phase 1: Addon Skeleton & Build Foundation** - Create 4 subsystem addon skeletons (hal_data/hal_hac/hal_boss/hal_tasking) + compat_nr6hal, fix mod.cpp, establish HEMTT clean build
- [x] **Phase 2: Dependency Mapping** - Map inter-function call graph, classify active/dead functions, establish PREP order
- [x] **Phase 3: Function Extraction** - Extract all active functions from all 7 in-scope legacy files into individual fnc_*.sqf files
- [x] **Phase 4: Variable Namespacing** - Rename all RYD*/RHQ*/RydBB* globals to GVAR() macros atomically
- [x] **Phase 5: Settings, Localization, Compat & Cleanup** - CBA settings, stringtable, compatibility addon, legacy removal, behavior verification

---

## Phase Details

### Phase 1: Addon Skeleton & Build Foundation
**Goal**: A clean HEMTT build exists with correct addon skeleton structure so all subsequent migration work has a valid compilation target
**Depends on**: Nothing
**Requirements**: BUILD-01, BUILD-02, BUILD-03, BUILD-04, BUILD-05
**Success Criteria** (what must be TRUE):
  1. `hemtt build` completes with zero errors and zero warnings
  2. 4 subsystem addons (hal_data, hal_hac, hal_boss, hal_tasking) exist under `addons/` with valid `$PBOPREFIX$`, `script_component.hpp`, `config.cpp`, `CfgEventHandlers.hpp`, and XEH files per D-01..D-03
  3. `addons/compat_nr6hal/` skeleton exists with classname inventory comments and is included in the build (D-04, D-13, D-14)
  4. `mod.cpp` contains correct NR6-HAL project metadata (no ACE3 placeholder text) per D-05..D-09
**Plans**: 5 plans
  - [x] 01-01-PLAN.md — Rebrand mod.cpp + lenient HEMTT lint config (BUILD-02, BUILD-05)
  - [x] 01-02-PLAN.md — Create 4 subsystem addon skeletons hal_data/hal_hac/hal_boss/hal_tasking (BUILD-01, BUILD-03)
  - [x] 01-03-PLAN.md — Create compat_nr6hal skeleton + classname audit + final build verification (BUILD-01, BUILD-02, BUILD-04)
  - [x] 01-04-PLAN.md — Gap closure Track A: extend HEMTT lint suppressions L-S13/L-S19/L-S30/L-C14 + gitignore .hemttprivatekey (BUILD-02)
  - [x] 01-05-PLAN.md — Gap closure Track B: stub 3 undefined common fns + core mark proxy + populate 45 missionmodules units[] + BBW1 environment note (BUILD-02)

### Phase 2: Dependency Mapping
**Goal**: The full call graph across all 7 in-scope legacy files is documented so every function can be extracted in safe dependency order without silent nil-reference failures
**Depends on**: Phase 1
**Requirements**: FUNC-01, FUNC-02
**Success Criteria** (what must be TRUE):
  1. A documented call graph exists covering all functions in the 7 in-scope legacy files (HAC_fnc.sqf, HAC_fnc2.sqf, RHQLibrary.sqf, Boss_fnc.sqf, Boss.sqf, TaskInitNR6.sqf, SquadTaskingNR6.sqf)
  2. Every function is classified as active, dead, or already-migrated with its target destination file named
  3. PREP ordering (leaf-first) is determined and documented so extraction can proceed without silent compile-order failures
**Plans**: 5 plans
  - [x] 02-01-PLAN.md — Scripted extraction: bash script + raw declaration/edge/migration TSVs (FUNC-01)
  - [x] 02-02-PLAN.md — Enrich HAC_fnc.sqf + HAC_fnc2.sqf with classification/target_addon/notes (FUNC-01, FUNC-02)
  - [x] 02-03-PLAN.md — Enrich RHQLibrary.sqf (hal_data) + Boss_fnc.sqf (hal_boss) (FUNC-01, FUNC-02)
  - [x] 02-04-PLAN.md — Boss.sqf section map + TaskInitNR6.sqf + SquadTaskingNR6.sqf (FUNC-01, FUNC-02)
  - [x] 02-05-PLAN.md — Synthesis: Mermaid graph + PREP ordering + canonical docs/dependency-map.md (FUNC-01, FUNC-02)

### Phase 3: Function Extraction
**Goal**: All active functions from all 7 in-scope legacy files (HAC_fnc.sqf, HAC_fnc2.sqf, RHQLibrary.sqf, Boss_fnc.sqf, Boss.sqf external edges, TaskInitNR6.sqf, SquadTaskingNR6.sqf) are extracted into individual CBA-registered fnc_*.sqf files using ACE3 code standards
**Depends on**: Phase 2
**Requirements**: FUNC-03, FUNC-04, FUNC-05, FUNC-06, FUNC-07, FUNC-08, FUNC-09, FUNC-10, STD-01, STD-02, STD-03, STD-04
**Success Criteria** (what must be TRUE):
  1. Every active function from the 7 in-scope legacy files (RHQLibrary.sqf, HAC_fnc.sqf, HAC_fnc2.sqf, Boss_fnc.sqf, Boss.sqf external edges, TaskInitNR6.sqf, SquadTaskingNR6.sqf) exists as an individual `fnc_*.sqf` file in addons/
  2. Every migrated function is registered in XEH_PREP.hpp and the HEMTT build remains clean throughout
  3. RYD_StatusQuo is decomposed into sub-functions each under 250 lines
  4. Every migrated function uses `params` syntax, `private` declarations, `FUNC()`/`EFUNC()` call macros, and includes `script_component.hpp`
  5. No commented-out or dead code remains in any migrated file
**Plans**: 5 plans
  - [x] 03-01-PLAN.md — Extract RHQLibrary.sqf (31 data arrays) -> hal_data + D-06a REQUIREMENTS/ROADMAP scope update (FUNC-03, FUNC-09, FUNC-10, STD-01..04)
  - [x] 03-02-PLAN.md — Extract HAC_fnc.sqf (RYD_Dispatcher only, delete 5645 lines of deadwood) -> hal_hac (FUNC-04, FUNC-09, FUNC-10, STD-01..04)
  - [x] 03-03-PLAN.md — Extract HAC_fnc2.sqf (RYD_StatusQuo decomposition + HAL_* + PresentRHQ) -> hal_hac/hal_boss/hal_data; NON-AUTONOMOUS D-03a checkpoint (FUNC-05, FUNC-08, FUNC-09, FUNC-10, STD-01..04)
  - [x] 03-04-PLAN.md — Extract Boss_fnc.sqf (20 fns) -> hal_boss + retire RYD_TerraCognita + update Boss.sqf external edges (FUNC-06, FUNC-09, FUNC-10, STD-01..04)
  - [x] 03-05-PLAN.md — Extract TaskInitNR6.sqf (72 Action* callbacks) -> hal_tasking + SquadTaskingNR6 string updates + D-04 load restore (FUNC-07, FUNC-09, FUNC-10, STD-01..04)

### Phase 4: Variable Namespacing
**Goal**: All legacy global variable names (RYD*, RHQ*, RydBB*) are replaced with CBA GVAR() macros throughout the migrated codebase, each rename completed atomically to prevent partial-rename state corruption
**Depends on**: Phase 3
**Requirements**: VAR-01, VAR-02, VAR-03, VAR-04
**Success Criteria** (what must be TRUE):
  1. No raw `RYD*`, `RHQ*`, or `RydBB*` variable names remain in any file under addons/
  2. Every `publicVariable` call uses a `QGVAR()` string reference (no string literals with old names)
  3. Every `isNil "RydHQ_..."` guard is converted to use `QGVAR()` references
  4. Each variable was renamed in a single atomic commit (assignment + publicVariable + all readers together)
**Plans**: 6 plans (1 tool scaffold + 5 per-prefix atomic batches per D-03)
  - [x] 04-00-PLAN.md — Build Python rename tool (phase4-rename.py) + scaffold rename-map JSON schema (pre-plan tool task)
  - [x] 04-01-PLAN.md — Rename RYD_* -> GVAR/EGVAR (shakedown batch, smallest) (VAR-01..04)
  - [x] 04-02-PLAN.md — Rename RHQ_* -> GVAR(hal_data,*) family (weapon class arrays) (VAR-01..04)
  - [x] 04-03-PLAN.md — Rename RydBB_* -> GVAR(missionmodules,*) + bbZone dispatch rewrite (VAR-01..04)
  - [x] 04-04-PLAN.md — Rename RydHQ_* + multi-HQ siblings + reconstruct 11 runtime-format dispatch sites (largest, non-autonomous) (VAR-01..04)
  - [x] 04-05-PLAN.md — Rename RydxHQ_* + resolve ReconCargo owner collision + AIChatter writer survey + consolidate rename-map.json (VAR-01..04)

### Phase 5: Settings, Localization, Compat & Cleanup
**Goal**: CBA settings, English stringtable, compatibility addon, and legacy removal are complete — the project builds cleanly, old missions still work, and AI behavior is verified identical
**Depends on**: Phase 4
**Requirements**: SET-01, SET-02, SET-03, SET-04, COMPAT-01, COMPAT-02, COMPAT-03, COMPAT-04, BEHAV-01, BEHAV-02, BEHAV-03, BEHAV-04, BEHAV-05
**Success Criteria** (what must be TRUE):
  1. All configurable HAL options (personality traits, activity levels, etc.) are exposed as CBA settings adjustable in the CBA settings menu — no mission-module-only configuration remains
  2. `stringtable.xml` exists with English entries for all user-facing strings; all settings display names and descriptions use LSTRING() macros
  3. An existing mission that used old nr6_hal module classnames loads correctly with the compat addon enabled — no "module not found" errors
  4. `nr6_hal/` legacy directory has been deleted and the HEMTT build still produces zero errors and zero warnings
  5. HAL AI commander initializes, assigns groups, scans for threats, coordinates fire support, and runs chatter identically to pre-refactor behavior in a test session
**Plans**: 9 plans
  - [x] 05-01-PLAN.md — Extract VarInit.sqf unique content + TimeM/TaskMenu/LF utilities + Sound/CfgRadio migration (COMPAT-04)
  - [x] 05-02-PLAN.md — Extract Boss.sqf + Front.sqf + Desperation.sqf + HQSitRep[B-H] + 11 HQ command scripts (COMPAT-04, BEHAV-01, BEHAV-02)
  - [x] 05-03-PLAN.md — Extract 20 tactical behavior scripts (Go* attack/defense/recon + SCargo + Garrison) (COMPAT-04)
  - [x] 05-04-PLAN.md — Extract 8 supply scripts + SquadTaskingNR6.sqf + delete nr6_hal/ directory (COMPAT-04)
  - [x] 05-05-PLAN.md — Dead-variable audit: grep 506 rename-map entries, mark dead as stripped (COMPAT-02, COMPAT-03)
  - [x] 05-06-PLAN.md — CBA settings (initSettings.inc.sqf) + stringtable.xml + wire module defaults (SET-01, SET-02, SET-03, SET-04)
  - [x] 05-07-PLAN.md — Populate compat addon: classname inheritance + function aliases + global variable aliases (COMPAT-01, COMPAT-02, COMPAT-03)
  - [x] 05-08-PLAN.md — Create 5 SQF behavior verification smoke tests (BEHAV-01, BEHAV-02, BEHAV-03, BEHAV-04, BEHAV-05)
  - [x] 05-09-PLAN.md — Final build verification + ROADMAP/STATE/REQUIREMENTS completion (all Phase 5 reqs)

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Addon Skeleton & Build Foundation | 5/5 | Complete | 2026-04-10 |
| 2. Dependency Mapping | 5/5 | Complete | 2026-04-10 |
| 3. Function Extraction | 5/5 | Complete | 2026-04-10 |
| 4. Variable Namespacing | 6/6 | Complete | 2026-04-10 |
| 5. Settings, Localization, Compat & Cleanup | 9/9 | Complete | 2026-04-11 |

**v1.0 milestone: COMPLETE — all 5 phases, all 30 plans, all 37 requirements.**

---

## Coverage

| Requirement | Phase |
|-------------|-------|
| BUILD-01 | Phase 1 |
| BUILD-02 | Phase 1 |
| BUILD-03 | Phase 1 |
| BUILD-04 | Phase 1 |
| BUILD-05 | Phase 1 |
| FUNC-01 | Phase 2 |
| FUNC-02 | Phase 2 |
| FUNC-03 | Phase 3 |
| FUNC-04 | Phase 3 |
| FUNC-05 | Phase 3 |
| FUNC-06 | Phase 3 |
| FUNC-07 | Phase 3 |
| FUNC-08 | Phase 3 |
| FUNC-09 | Phase 3 |
| FUNC-10 | Phase 3 |
| STD-01 | Phase 3 |
| STD-02 | Phase 3 |
| STD-03 | Phase 3 |
| STD-04 | Phase 3 |
| VAR-01 | Phase 4 |
| VAR-02 | Phase 4 |
| VAR-03 | Phase 4 |
| VAR-04 | Phase 4 |
| SET-01 | Phase 5 |
| SET-02 | Phase 5 |
| SET-03 | Phase 5 |
| SET-04 | Phase 5 |
| COMPAT-01 | Phase 5 |
| COMPAT-02 | Phase 5 |
| COMPAT-03 | Phase 5 |
| COMPAT-04 | Phase 5 |
| BEHAV-01 | Phase 5 |
| BEHAV-02 | Phase 5 |
| BEHAV-03 | Phase 5 |
| BEHAV-04 | Phase 5 |
| BEHAV-05 | Phase 5 |

**v1 requirements mapped: 37/37**

---
*Created: 2026-04-09*
*Last updated: 2026-04-11 — v1.0 milestone complete after Plan 05-09 closure*
