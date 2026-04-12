---
phase: 05-settings-localization-compat-cleanup
plan: 07
subsystem: compat
tags: [compat, aliases, backward-compat, cfgvehicles, postinit]
requires: [05-05, 05-06]
provides:
  - "Legacy module classname compat via CfgVehicles inheritance"
  - "Legacy HAL_*/Boss/Desperado/HQSitRep function handle aliases"
  - "Legacy global variable aliases (506 entries) for all Phase-4 renames"
affects: [addons/compat_nr6hal]
tech-stack:
  added: []
  patterns:
    - "CfgVehicles class inheritance as read-only classname alias"
    - "postInit one-directional global-variable mirror via EGVAR() expansion"
    - "Generated SQF from rename-map.json via .tmp/gen_compat_aliases.py"
key-files:
  created: []
  modified:
    - addons/compat_nr6hal/config.cpp
    - addons/compat_nr6hal/XEH_postInit.sqf
decisions:
  - "Part B aliases are local-only (no publicVariable) — owning addons already broadcast authoritative values; doubling would waste bandwidth and risk write-race"
  - "Read-only mirror accepted per D-05: writes to legacy names do not propagate back"
metrics:
  duration: ~25m
  completed: 2026-04-11
requirements: [COMPAT-01, COMPAT-02, COMPAT-03]
---

# Phase 05 Plan 07: Legacy Compat Addon Population Summary

One-liner: Wired compat_nr6hal with 9 CfgVehicles classname shims, 51 legacy function-handle aliases, and 506 generated global-variable aliases so pre-Phase-4 missions keep loading unchanged.

## What Shipped

### COMPAT-01 — CfgVehicles classname inheritance (9 entries)
Added a `class CfgVehicles { ... }` block to `addons/compat_nr6hal/config.cpp`
that forward-declares the Phase-4 parents and inherits the legacy names:

| Legacy classname | New parent (hal_missionmodules) |
|---|---|
| NR6_HAL_Core_Module | hal_missionmodules_Core_Module |
| NR6_HAL_Leader_Module | hal_missionmodules_Leader_Module |
| NR6_HAL_Leader_Settings_Module | hal_missionmodules_Leader_Settings_Module |
| NR6_HAL_GenSettings_Module | hal_missionmodules_GenSettings_Module |
| NR6_HAL_Leader_BehSettings_Module | hal_missionmodules_Leader_BehSettings_Module |
| NR6_HAL_Objective_Module | hal_missionmodules_Leader_Objective_Module |
| NR6_HAL_BBObjective_Module | hal_missionmodules_BBLeader_Objective_Module |
| NR6_HAL_BBLeader_Module | hal_missionmodules_BBLeader_Module |
| NR6_HAL_Front_Module | hal_missionmodules_Leader_Front_Module |

All 9 parents confirmed to exist in `addons/missionmodules/CfgVehicles.hpp`
(class names expand from `GVAR(Core_Module)` etc. where
`PREFIX=hal, COMPONENT=missionmodules`).

`requiredAddons[]` was extended with `hal_common` and `hal_core` so the
compat shim loads after all addons whose globals/functions it aliases.

### COMPAT-02 — Function handle aliases (51 entries)
`addons/compat_nr6hal/XEH_postInit.sqf` Part A mirrors every legacy handle
to its new EFUNC() target:

- **41 HAL_* tactical handles**: `HAL_EnemyScan`, `HAL_Flanking`, `HAL_Garrison`,
  all `HAL_GoAtt*`/`HAL_GoDef*`/`HAL_GoCapture*`/`HAL_GoFlank`/`HAL_GoIdle`/
  `HAL_GoRecon`/`HAL_GoRest`/`HAL_GoSFAttack`, the four `HAL_Go*Supp` +
  `HAL_Supp*` supply handles, `HAL_HQOrders*`/`HAL_HQReset`/`HAL_LHQ`/
  `HAL_LPos`/`HAL_Personality`/`HAL_Reloc`/`HAL_Rev`/`HAL_SCargo`/
  `HAL_SFIdleOrd`/`HAL_Spotscan`
- **2 special handles**: `Boss` (→ `EFUNC(hal_boss,boss)`),
  `Desperado` (→ `EFUNC(hal_hac,desperation)`)
- **8 HQSitRep dispatch handles**: `[A-H]_HQSitRep` → `EFUNC(core,HQSitRep*)`

All EFUNC targets confirmed against `XEH_PREP.hpp` in `core`, `hal_hac`,
and `hal_boss`. Spot-checked: `enemyScan`, `personality`, `flanking`,
`hqOrders`, `boss`, `desperation`, `HQSitRepD` — all present as PREP'd
functions on disk.

### COMPAT-03 — Global variable aliases (506 entries)
`addons/compat_nr6hal/XEH_postInit.sqf` Part B, generated from
`.planning/phases/04-variable-namespacing/rename-map.json` via
`.tmp/gen_compat_aliases.py` (committed to `.tmp/` as scratch tooling,
not shipped in any PBO). For every non-stripped entry in the rename map:

```sqf
<legacy_name> = <new_macro_extern_form>;
```

Distribution by owning addon (from rename-map.json):

| Owner | Aliases |
|---|---|
| core | 233 |
| hal_hac | 122 |
| hal_data | 67 |
| common | 53 |
| hal_boss | 18 |
| missionmodules | 9 |
| hal_tasking | 4 |
| **Total** | **506** |

Stripped (dead) entries: 0 — audit in Plan 05-05 confirmed all 506 rename
entries are still live and need aliasing.

**Accepted caveat (D-05):** these are read-only mirrors. Writing to the
legacy name (`RydHQ_Activity = 5`) does NOT propagate back to the new
`hal_core_activity` home. Legacy missions that *read* from these globals
work; legacy missions that *write* to them and expect HAL to pick up the
value do not. Per Phase 4 decision, this is acceptable because write
sites in mission authoring are rare and typically happen through the
module arguments pathway, which already feeds the new GVARs directly.

No `publicVariable` calls in Part B: the authoritative variables are
already broadcast by their owning addon during its own `varInit`/postInit,
so doubling would waste network bandwidth and create a write-race on
join-in-progress.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Added hal_core + hal_common to requiredAddons**
- **Found during:** Task 1
- **Issue:** The plan specified EGVAR(core,*) and EGVAR(common,*) targets for Part B aliases, but `addons/compat_nr6hal/config.cpp` only listed `hal_data`, `hal_hac`, `hal_boss`, `hal_tasking`, `hal_missionmodules` in `requiredAddons[]`. Without `hal_core` and `hal_common` declared, the compat PBO could load before those addons, leaving `EGVAR(core,activity)` etc. resolved against an undefined namespace at postInit time.
- **Fix:** Added `"hal_common"` and `"hal_core"` to the `requiredAddons[]` array.
- **Files modified:** `addons/compat_nr6hal/config.cpp`
- **Commit:** c59dd40

## Build Status

- `hemtt build` exits 0
- 9 PBOs built (includes `compat_nr6hal.pbo`)
- 308 SQF files compiled
- Zero errors. Pre-existing L-S18 warnings in `fnc_goDef.sqf:213` and
  `fnc_hqOrdersDef.sqf:264` are out of scope (unrelated to this plan;
  logged for future cleanup).

## Verification Checks

- [x] `grep -c "NR6_HAL_" addons/compat_nr6hal/config.cpp` = 19 (9 class
  declarations + 9 comment-inventory lines + 1 banner reference ≥ 9 ✓)
- [x] `grep -cE "^HAL_\w+ = EFUNC" XEH_postInit.sqf` = 41 ✓
- [x] `grep -cE "^[A-H]_HQSitRep = EFUNC" XEH_postInit.sqf` = 8 ✓
- [x] `grep -c "EFUNC" XEH_postInit.sqf` = 52 (51 aliases + 1 comment) ✓
- [x] `grep -c "EGVAR" XEH_postInit.sqf` = 507 (506 aliases + 1 comment) ✓
- [x] Spot-check 6 EFUNC targets → all present in PREP registers
- [x] `hemtt build` clean, compat_nr6hal.pbo produced

## Commits

- `c59dd40` feat(05-07): add CfgVehicles inheritance for 9 legacy NR6_HAL module classnames
- `7e88343` feat(05-07): populate compat postInit with 51 fn + 506 global aliases

## Known Stubs

None — all aliasing layers are fully wired.

## Self-Check: PASSED
- addons/compat_nr6hal/config.cpp: FOUND
- addons/compat_nr6hal/XEH_postInit.sqf: FOUND
- commit c59dd40: FOUND
- commit 7e88343: FOUND
