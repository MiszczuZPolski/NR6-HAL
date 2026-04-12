---
phase: 05-settings-localization-compat-cleanup
plan: 06
subsystem: cba-settings-localization
tags: [cba, settings, stringtable, localization, missionmodules, core]
requires:
  - 05-04 (Wave 4 extraction complete; nr6_hal deleted)
  - 05-05 (dead-var audit complete)
provides:
  - CBA settings registration for ~100 HAL options
  - Per-addon stringtable.xml files (core + missionmodules)
  - CSTRING-wired module displayName/description in CfgVehicles.hpp
  - CBA-setting-as-default fallback in all 6 fnc_leader*Settings.sqf
    plus fnc_generalSettings.sqf and fnc_bbSettings.sqf
affects:
  - addons/core/XEH_preInit.sqf
  - addons/missionmodules/CfgVehicles.hpp
  - addons/missionmodules/functions/fnc_leader*Settings.sqf
tech-stack:
  added:
    - CBA_fnc_addSetting framework usage
    - HEMTT stringtable.xml localization files
  patterns:
    - Per-addon stringtable placement (LLSTRING/CSTRING resolve against own addon)
    - CBA setting as fallback, editor module attribute overrides per-HQ
key-files:
  created:
    - addons/core/initSettings.inc.sqf
    - addons/core/stringtable.xml
    - addons/missionmodules/stringtable.xml
  modified:
    - addons/core/XEH_preInit.sqf
    - addons/missionmodules/CfgVehicles.hpp
    - addons/missionmodules/functions/fnc_generalSettings.sqf
    - addons/missionmodules/functions/fnc_leaderSettings.sqf
    - addons/missionmodules/functions/fnc_leaderBehaviourSettings.sqf
    - addons/missionmodules/functions/fnc_leaderPersonalitySettings.sqf
    - addons/missionmodules/functions/fnc_leaderSupportSettings.sqf
    - addons/missionmodules/functions/fnc_leaderObjectivesSettings.sqf
    - addons/missionmodules/functions/fnc_bbSettings.sqf
decisions:
  - "Per-addon stringtable placement honours HEMTT LSTRING resolution (LLSTRING in core resolves to STR_hal_core_*, CSTRING in missionmodules resolves to STR_hal_missionmodules_*) — addons/main/stringtable.xml explicitly NOT created"
  - "fnc_leader*Settings.sqf attribute lookup keys corrected from QGVAR(x) to QEGVAR(core,x) so the functions actually read the attribute classes defined in CfgVehicles.hpp (pre-existing Phase 4 namespace mismatch fixed under Rule 1 — required for SET-02 settings plumbing to function)"
  - "HC settings registered under QEGVAR(missionmodules,*) prefix because they belong to missionmodules GVAR namespace (used by fnc_bbSettings.sqf)"
  - "EGVAR(common,*), EGVAR(hal_hac,*) settings kept under their native addon prefix but display-name LLSTRING keys live in core/stringtable.xml (file that contains the LLSTRING calls determines lookup addon)"
metrics:
  duration: "~45m"
  tasks: 2
  files_created: 3
  files_modified: 9
  commits: 2
completed: "2026-04-11"
---

# Phase 05 Plan 06: CBA Settings + Per-Addon Stringtables Summary

Registered ~101 HAL configurable options as CBA settings with English display names and tooltips, delivered via per-addon stringtable.xml files (207 entries in core, 90 in missionmodules). Wired CBA setting values as default fallbacks in all module-activation functions so existing editor modules continue to override per-HQ while server admins gain out-of-box configuration via the CBA settings menu.

## What Was Built

**Task 1 — CBA settings + stringtables (commit `e485532`):**

- `addons/core/initSettings.inc.sqf` (new, 571 lines, **101** `CBA_fnc_addSetting` calls). Covers seven categories:
  - HAL General (25 settings) — reconCargo, synchroAttack, hQChat, aIChat*, actions*, magic*, garrisonV2, nEAware, pathFinding, etc.
  - HAL Commander (15) — fast, commDelay, chatDebug, exInfo, resetTime, infoMarkers, artyMarks, secTasks, camV, debug, etc.
  - HAL Behaviour (23) — smoke, flare, flee, surr, rush, withdraw, dynForm, muu, defRange, garrRange, attInfDistance, attArmDistance, etc.
  - HAL Personality (2) — mAtt, personality (LIST: GENIUS/IDIOT/CHAOTIC/COMPETENT/EAGER/DILATORY/SCHEMER/BRUTE/OTHER)
  - HAL Support (11) — cargoFind, noAirCargo, noLandCargo, sMed, sFuel, sAmmo, sRep, supportWP, artyShells, airEvac, supportRTB
  - HAL Objectives (21) — order, berserk, simpleMode, captLimit, garrR, objHoldTime, objRadius*, reconReserve, attackReserve, maxSimpleObjs, objectiveRespawn, etc.
  - HAL High Commander (3) — customObjOnly, bbLRelocating, mainInterval
- `addons/core/stringtable.xml` (new, **207** `Key ID` entries). Contains 7 category labels + ~200 setting name/tooltip pairs. All LLSTRING calls in initSettings.inc.sqf resolve here.
- `addons/missionmodules/stringtable.xml` (new, **90** `Key ID` entries). Contains 45 module displayName + description pairs for core, commander, squad-property, and BB modules.
- `addons/core/XEH_preInit.sqf`: added `#include "initSettings.inc.sqf"` so CBA settings register during preInit, before any editor module activation.

**Task 2 — CBA fallbacks + CSTRING wiring (commit `32b0a47`):**

- `addons/missionmodules/functions/fnc_generalSettings.sqf` — 25 settings now read `_logic getVariable [QEGVAR(core,X), EGVAR(core,X)]`; CBA setting is the default fallback when editor module attribute is unset.
- `addons/missionmodules/functions/fnc_leaderSettings.sqf` — 15 commander settings wired. Pre-existing Phase 4 namespace mismatch fixed: function previously queried `QGVAR(fast)` (= `hal_missionmodules_fast`) but CfgVehicles.hpp attribute class is `EGVAR(core,fast)` (= `hal_core_fast`). Function now correctly reads `QEGVAR(core,fast)` and writes the per-slot variable under the core prefix that consuming code (`addons/core/functions/fnc_HQSitRep*.sqf`) expects. See Deviations Rule 1.
- `addons/missionmodules/functions/fnc_leaderBehaviourSettings.sqf` — 23 behaviour settings wired (same namespace correction).
- `addons/missionmodules/functions/fnc_leaderPersonalitySettings.sqf` — 2 personality settings wired.
- `addons/missionmodules/functions/fnc_leaderSupportSettings.sqf` — 11 support settings wired.
- `addons/missionmodules/functions/fnc_leaderObjectivesSettings.sqf` — 21 objective settings wired (includes the preserved "DEFEND" string legacy quirk).
- `addons/missionmodules/functions/fnc_bbSettings.sqf` — 3 HC settings use `_logic getVariable [QGVAR(X), GVAR(X)]`. HC settings are registered as `QEGVAR(missionmodules,*)` CBA settings which resolve to the same missionmodules GVAR namespace.
- `addons/missionmodules/CfgVehicles.hpp` — 45 module classes updated: `displayName = "..."` replaced with `displayName = CSTRING(<moduleName>);`, and ModuleDescription `description = "..."` replaced with `description = CSTRING(<moduleName>_desc);`. Total **90** CSTRING() references added (45 × 2). Resolves against `addons/missionmodules/stringtable.xml`.

## Plan Verification Checks

| Check | Target | Actual | Status |
|---|---|---|---|
| `CBA_fnc_addSetting` in initSettings.inc.sqf | >= 90 | **101** | PASS |
| `Key ID` in addons/core/stringtable.xml | >= 190 | **207** | PASS |
| `Key ID` in addons/missionmodules/stringtable.xml | >= 40 | **90** | PASS |
| `initSettings` include in XEH_preInit.sqf | present | present | PASS |
| `test ! -f addons/main/stringtable.xml` | absent | absent | PASS |
| `EGVAR(core,` in fnc_leaderBehaviourSettings.sqf | > 0 | **22** | PASS |
| `CSTRING(` in CfgVehicles.hpp | > 0 | **90** | PASS |
| `hemtt build` exit status | 0 | 0 | PASS |
| New LSTRING/CSTRING warnings | 0 | 0 | PASS |

## Build Status

HEMTT build: **exit 0, 9 PBOs built.**

Warning count: **30** (matches Phase 05 post-05-05 baseline exactly). Composition:
- 1 × BBW1 (Arma 3 Tools not installed — accepted environment notice per CLAUDE.md)
- 29 × pre-existing L-S03/L-S12/L-S18/L-S24 lint warnings (not caused by this plan; out of scope per plan boundary)

No new warnings introduced. Specifically:
- Zero unresolved LSTRING / LLSTRING / CSTRING references
- Zero L-L01 stringtable-sort warnings (ran `hemtt ln sort` once during Task 1 to alphabetise the generated stringtables — standard ACE3 convention)
- Zero L-L02U unused-key warnings (every stringtable key is referenced by either initSettings.inc.sqf or CfgVehicles.hpp)

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 — Bug] Phase 4 namespace mismatch in fnc_leader*Settings.sqf**

- **Found during:** Task 2 (writing CBA fallback defaults)
- **Issue:** The five `fnc_leader*Settings.sqf` functions were querying `_logic getVariable [QGVAR(fast), ...]` (= `hal_missionmodules_fast`) while `CfgVehicles.hpp` declares the attribute under `class EGVAR(core,fast)` (= `hal_core_fast`). The two namespaces never matched: the logic would never contain a `hal_missionmodules_*` key, so every setting silently fell through to its hardcoded default. Consumers in `addons/core/` (e.g. `fnc_HQSitRep*.sqf`) read the per-slot variable under the `hal_core_*` prefix, so the write side was also wrong. This meant no editor-module attribute actually took effect after the Phase 4 rename — a pre-existing bug surfaced by this plan.
- **Fix:** Every setting lookup in `fnc_leaderSettings/BehaviourSettings/PersonalitySettings/SupportSettings/ObjectivesSettings.sqf` (and `fnc_generalSettings.sqf`) changed from `QGVAR(X)` to `QEGVAR(core,X)` (or the appropriate `EGVAR(common,*)` / `EGVAR(hal_hac,*)` per CfgVehicles.hpp). The per-slot output variable is now also written under the correct prefix that consuming code reads from.
- **Files modified:** `fnc_generalSettings.sqf`, `fnc_leaderSettings.sqf`, `fnc_leaderBehaviourSettings.sqf`, `fnc_leaderPersonalitySettings.sqf`, `fnc_leaderSupportSettings.sqf`, `fnc_leaderObjectivesSettings.sqf`
- **Commit:** `32b0a47`
- **Why in scope:** The plan required these files to wire CBA settings as defaults. That wiring would have been functionally useless on top of the broken key lookup. Rule 1 (auto-fix directly broken behaviour that blocks the task) applies.

**2. [Rule 2 — Missing critical functionality] hemtt-required stringtable sort**

- **Found during:** Task 1 first build
- **Issue:** HEMTT emitted `warning[L-L01]: Stringtable at ... is not sorted` for both newly created stringtable.xml files. Without alphabetical sort, HEMTT warns — introducing new warnings would violate the plan's zero-new-warnings constraint.
- **Fix:** Ran `hemtt ln sort` once after the files were created, producing alphabetised Key ID ordering. Subsequent builds have no L-L01 warnings.
- **Files affected:** `addons/core/stringtable.xml`, `addons/missionmodules/stringtable.xml`
- **Commit:** bundled into `e485532`

### Plan File Names vs Reality

The plan frontmatter referenced `fnc_leaderPersSettings.sqf`, `fnc_leaderSupSettings.sqf`, and `fnc_leaderObjSettings.sqf`. The actual files on disk are named `fnc_leaderPersonalitySettings.sqf`, `fnc_leaderSupportSettings.sqf`, and `fnc_leaderObjectivesSettings.sqf` (Phase 3 extraction naming). Plan-frontmatter names are stale; no rename needed — functions are correctly referenced from `QFUNC(leaderPersonalitySettings)` etc. in CfgVehicles.hpp.

### Scope Items Deferred

- **Argument attribute `displayName` values** (e.g. `displayName="Enable Cargo Recon";` inside `class Arguments`) were **not** wired to stringtable keys. The plan scoped the CSTRING replacement to module-class `displayName`/`description` and ModuleDescription `description` — the argument-attribute strings are a separate localisation surface not required by SET-03/SET-04 verification. Logged for potential future plan.
- **Value-class labels** for LIST-type attributes (`class 40K_IMPERIUM { name="Imperium Of Man..."; }`) likewise not localised.
- **Non-EGVAR/GVAR attribute classes** (`class RydART_Safe`, `class RydHQx_PlayerCargoCheckLoopTime`, `class LeaderType`, etc.) were not registered as CBA settings — these are module-placement parameters, not global tunables. Per the analysis in Task 1 prep work: ~8 such attributes exist across the Arguments blocks; all are intentionally kept module-only.

## Key Decisions Made

1. **Per-addon stringtable placement honoured (D-plan-checker-fix).** Confirmed via HEMTT build: LLSTRING in `addons/core/initSettings.inc.sqf` resolved against `addons/core/stringtable.xml`; CSTRING in `addons/missionmodules/CfgVehicles.hpp` resolved against `addons/missionmodules/stringtable.xml`. Zero cross-addon warnings. `addons/main/stringtable.xml` was explicitly not created.

2. **Phase 4 namespace mismatch fixed as part of Task 2.** Without this fix, the entire plan would have been cosmetic — the existing setting functions never actually read their CfgVehicles attributes. See Deviation 1.

3. **HC settings registered under `missionmodules` prefix.** `customObjOnly`, `lRelocating`, and `mainInterval` live in the BBSettings_Module using local `GVAR(...)`. Registered CBA settings as `QEGVAR(missionmodules,customObjOnly)` etc. so the same variable symbol is shared by the CBA storage and the fnc_bbSettings.sqf local reads. Note: one HC CBA setting uses name `bbLRelocating` (distinguishing from the per-commander `QEGVAR(core,lRelocating)` legacy-objectives setting) — mapped explicitly in fnc_bbSettings.sqf.

## Threat Register Closure

| Threat ID | Status | Evidence |
|---|---|---|
| T-05-12 (CBA setting nil at module read) | **closed** | `#include "initSettings.inc.sqf"` runs during core addon preInit, before any module activation (postInit/trigger). Module activation reads via `_logic getVariable [Qkey, <CBA-setting-value>]` — never nil even with no editor module. |
| T-05-13 (Mismatched stringtable key) | **closed** | HEMTT build produced 0 unresolved LSTRING/CSTRING warnings across both stringtables and both consuming files. |
| T-05-14 (Missing LLSTRING for a setting) | **closed** | 101 CBA_fnc_addSetting calls × 2 LLSTRING per call (name + desc) = 202 LLSTRING references, matched by 200 setting keys + 7 category keys = 207 core/stringtable.xml entries. HEMTT L-L02U warning count: 0. |
| T-05-15 (Cross-addon LSTRING resolution failure) | **closed** | All LLSTRING in core/ target STR_hal_core_*; all CSTRING in missionmodules/ target STR_hal_missionmodules_*. No ELSTRING or ECSTRING used. Zero cross-addon warnings. |

## Requirements Satisfied

- **SET-01** — CBA settings registration: 101 settings wired via `CBA_fnc_addSetting`
- **SET-02** — CBA-setting-as-default for module activation: 6 `fnc_leader*Settings.sqf` functions + `fnc_generalSettings.sqf` + `fnc_bbSettings.sqf` now use CBA fallback pattern
- **SET-03** — Per-addon stringtable for core settings: 207 entries in `addons/core/stringtable.xml`
- **SET-04** — Per-addon stringtable for module UI: 90 entries in `addons/missionmodules/stringtable.xml`; CfgVehicles.hpp uses CSTRING() macros

## Known Stubs

None. All 101 settings have real defaults (preserved verbatim from CfgVehicles.hpp attribute `defaultValue`), all 297 stringtable keys have real English text.

## Self-Check: PASSED

- `addons/core/initSettings.inc.sqf` — **FOUND**
- `addons/core/stringtable.xml` — **FOUND**
- `addons/missionmodules/stringtable.xml` — **FOUND**
- `addons/core/XEH_preInit.sqf` — **FOUND** (contains `#include "initSettings.inc.sqf"`)
- `addons/missionmodules/CfgVehicles.hpp` — **FOUND** (90 CSTRING references)
- Commit `e485532` (Task 1) — **FOUND**
- Commit `32b0a47` (Task 2) — **FOUND**
- `addons/main/stringtable.xml` — **ABSENT** (as required — negative check)
- HEMTT build exit status — **0**
- New LSTRING/CSTRING warnings — **0**
