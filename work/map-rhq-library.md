## RHQLibrary.sqf

**File:** `nr6_hal/RHQLibrary.sqf` (2,491 lines)
**Declarations:** 31 `RYD_WS_*` data arrays (lines 1–752) + extensive `RHQ_*_A2/_OA/_ACR/_BAF/_PMC` legacy DLC sub-arrays (lines 753–2486) + 1 imperative call (lines 2487–2491)
**Code functions declared:** **ZERO** — this file contains only static data arrays (verified by `grep -n "params\|_this select" returning zero results`)
**Phase 3 target:** Entire file → `addons/hal_data/functions/fnc_initWeaponClasses.sqf` as a single migration task per FUNC-03.

### Data Array Inventory

| name | line | category | target_addon | classification |
|------|------|----------|--------------|----------------|
| RYD_WS_specFor_class | 1 | Arma 3 vanilla SF classes | hal_data | active |
| RYD_WS_recon_class | 5 | Recon/UAV classes | hal_data | active |
| RYD_WS_FO_class | 41 | Forward observer classes | hal_data | active |
| RYD_WS_snipers_class | 50 | Sniper classes | hal_data | active |
| RYD_WS_ATinf_class | 64 | AT infantry classes | hal_data | active |
| RYD_WS_AAinf_class | 80 | AA infantry classes | hal_data | active |
| RYD_WS_Inf_class | 90 | General infantry classes | hal_data | active |
| RYD_WS_Art_class | 262 | Artillery classes | hal_data | active |
| RYD_WS_HArmor_class | 279 | Heavy armor classes | hal_data | active |
| RYD_WS_MArmor_class | 287 | Medium armor classes | hal_data | active |
| RYD_WS_LArmor_class | 291 | Light armor classes | hal_data | active |
| RYD_WS_LArmorAT_class | 303 | Light armor AT classes | hal_data | active |
| RYD_WS_Cars_class | 311 | Cars/trucks classes | hal_data | active |
| RYD_WS_Air_class | 366 | Aircraft classes | hal_data | active |
| RYD_WS_BAir_class | 409 | Bomber aircraft classes | hal_data | active |
| RYD_WS_RAir_class | 416 | Rotary aircraft classes | hal_data | active |
| RYD_WS_NCAir_class | 429 | Non-combat aircraft classes | hal_data | active |
| RYD_WS_Naval_class | 446 | Naval classes | hal_data | active |
| RYD_WS_Static_class | 462 | Static weapon classes | hal_data | active |
| RYD_WS_StaticAA_class | 497 | Static AA classes | hal_data | active |
| RYD_WS_StaticAT_class | 504 | Static AT classes | hal_data | active |
| RYD_WS_Support_class | 511 | Support vehicle classes | hal_data | active |
| RYD_WS_Cargo_class | 538 | Cargo vehicle classes | hal_data | active |
| RYD_WS_NCCargo_class | 606 | Non-combat cargo classes | hal_data | active |
| RYD_WS_Crew_class | 648 | Crew classes | hal_data | active |
| RYD_WS_Other_class | 665 | Other/misc classes | hal_data | active |
| RYD_WS_rep | 672 | Repair vehicle classes | hal_data | active |
| RYD_WS_med | 693 | Medical vehicle classes | hal_data | active |
| RYD_WS_fuel | 712 | Fuel vehicle classes | hal_data | active |
| RYD_WS_ammo | 731 | Ammo vehicle classes | hal_data | active |
| RYD_WS_AllClasses | 752 | Composite: all arrays concatenated | hal_data | active |

### Legacy DLC Sub-arrays (lines 753–2486)

Bulk range containing `RHQ_*_A2`, `RHQ_*_OA`, `RHQ_*_ACR`, `RHQ_*_BAF`, `RHQ_*_PMC` sub-arrays for legacy Arma 2 / Operation Arrowhead / Army of the Czech Republic / British Armed Forces / Private Military Company DLC unit classes. These are enumerated as a single block in MAP.md — individual entries are not useful for dependency analysis since they share the same classification and target_addon.

**Target_addon:** hal_data
**Classification:** active (referenced by RYD_WS_AllClasses composite on line 752)
**Notes:** Phase 3 migration moves these arrays into `fnc_initWeaponClasses.sqf` alongside the primary RYD_WS_* arrays, preserving the DLC conditional logic.

### Imperative Trailing Call (lines 2487–2491)

```sqf
if (RydxHQ_RHQAutoFill) then
    {
    [] call RYD_PresentRHQ;
//  [] spawn RYD_PresentRHQLoop;
    };
```

- **Edge:** `RHQLibrary.sqf:2489` calls `RYD_PresentRHQ` (declared in HAC_fnc2.sqf:2207)
- **Secondary edge (commented out):** `RHQLibrary.sqf:2490` formerly spawned `RYD_PresentRHQLoop` (HAC_fnc2.sqf:3233) — line is commented out; RYD_PresentRHQLoop has no active callers
- **Classification:** active (entry point for RHQ population on mission start)
- **Phase 3 handling:** This imperative call migrates into `hal_data`'s XEH_postInit (or equivalent wire-up) to trigger RHQ population on mission start via `FUNC(initWeaponClasses)`.

### Notes

- All 31 primary arrays use the `RYD_WS_*` prefix (weapon set shortform for class categorization).
- The composite `RYD_WS_AllClasses` (line 752) concatenates: `RYD_WS_Inf_class + RYD_WS_Art_class + RYD_WS_HArmor_class + RYD_WS_MArmor_class + RYD_WS_LArmor_class + RYD_WS_Cars_class + RYD_WS_Air_class + RYD_WS_Naval_class + RYD_WS_Static_class + RYD_WS_Support_class + RYD_WS_Other_class`. This establishes the internal dependency order: all individual arrays must be defined before the composite.
- RHQLibrary.sqf has zero code functions, so there is no PREP ordering concern within the file. The single Phase 3 task moves all arrays in one atomic migration.
- The sub-arrays `RYD_WS_BAir_class`, `RYD_WS_RAir_class`, `RYD_WS_NCAir_class`, `RYD_WS_LArmorAT_class` are not included in `RYD_WS_AllClasses` — they appear to be standalone lookup tables for specific subsystem queries (not part of the composite). Phase 3 should preserve their individual accessibility.
- Dual classification `active` applies to every row because `RYD_WS_AllClasses` references them transitively, and the entire file is loaded at mission start as the asset classification backbone.
- Phase 3 single-task migration per FUNC-03 covers: all 31 `RYD_WS_*` arrays + all `RHQ_*` legacy DLC arrays + imperative trailing call wire-up.
