## HAC_fnc2.sqf

**File:** `nr6_hal/HAC_fnc2.sqf` (3,389 lines)
**Declarations:** 10 total (7 `RYD_*` + 3 `HAL_*`). 7 are genuinely active (uncommented) code; 2 are inside `/* */` comment blocks (migrated); 1 (`RYD_FindClosest`) is active at source but also exists in `addons/common/` (dual presence).

### Function Table

| name | line | classification | target_addon | params | calls | called_by | notes |
|------|------|----------------|--------------|--------|-------|-----------|-------|
| RYD_StatusQuo | 1 | active | hal_boss | No `params` statement — reads HQ state from globals: `_HQ` (group, implicit context var set by caller), `_cycleC` (int), `_lastReset` (number), `_excl` (array), `_civF` (array) passed via caller context | `HAL_HQReset` (lines 20,36; external: `nr6_hal/HAL/HQReset.sqf`); `RYD_Spawn` (line 39,1282,1424,1747); `RYD_RandomOrd` (216); `RYD_LiveFeed` (233); `RYD_AIChatter` (284,887,912,1181,1193); `RYD_Mark` (904); `RYD_ArtyPrep` (1032); `RYD_CFF` (1088); `HAL_HQOrders` (1186; external: `nr6_hal/HAL/HQOrders.sqf`); `HAL_HQOrdersDef` (1198; external); `RYD_isNight` (1207,1652); `RYD_WPadd` (1342,1414); `RYD_GoInside` (1345,1417); `HAL_Rev` (1464; external); `HAL_SuppMed` (1474; external); `HAL_SuppFuel` (1483; external); `HAL_SuppRep` (1492; external); `HAL_SuppAmmo` (1504; external); `HAL_SFIdleOrd` (1518; external); `HAL_Reloc` (1525; external); `HAL_LPos` (1533; external); `HAL_EnemyScan` (1546; external); `RYD_LF_EFF` (1654); `RYD_isInside` (1690); `HAL_GoSFAttack` (1281,1282; external, spawn + value_pass); `HAL_Garrison` (1552; external, spawn); `HAL_EBFT` (308; spawn — same file line 3029) | Entry point spawned from `addons/core/functions/fnc_init.sqf` (indirectly via the per-HQ loop at lines 185–190 which spawns HQSitRep, FBFTLOOP, and SecTasks — StatusQuo is the HQSitRep body called from the `_HQSitRep` variable per side) | **1,779-line mega-function (lines 1–1779).** Phase 3 FUNC-08 decomposes into sub-functions under 250 lines each. This is the HQ commander decision loop — the "brain" that assesses threats, manages friends/enemies lists, dispatches attack orders, coordinates logistics. Calls ~15 external `HAL_*` functions compiled from `nr6_hal/HAL/*.sqf` via `VarInit.sqf` — these appear as `[external: nr6_hal/HAL/...]` in the calls column and will NOT appear in `raw-call-edges.tsv`. The `[_HQ] spawn HAL_EBFT` at line 308 is the entry point for the enemy tracking loop. See Dynamic Dispatch section below. |
| RYD_LF_Loop | 1780 | dead? | hal_hac | `_leader` (unit, `_this select 0`); `_HQ` (group, `(_this select 3) select 0`) — note: selects index 3 suggesting 4-element array | `RYD_LF` (lines 1854,1859,1926 — migrated to `addons/common/functions/fnc_LF.sqf`) | (none found in 7-file scope) | AMBIGUOUS — No callers found in the 7-file scope. The Live Feed loop utility. Background caller would have been something like `[_leader,_cam,_src,_HQ] spawn RYD_LF_Loop` but no such call appears in any of the 7 scoped files. LF utilities (`RYD_LF`, `RYD_LF_EFF`) are already migrated. This function may have been orphaned when LF was refactored. Phase 3 must search `nr6_hal/HAL/` and addon scripts before classifying as dead and deleting. |
| RYD_FindClosest | 1932 | migrated | hal_hac | `_ref` (object/pos, `_this select 0`); `_objects` (array, `_this select 1`) | None (iterates `_objects` with distance check) | HAC_fnc.sqf:286 (in commented block — inactive); no active callers in 7-file scope | Dual presence — active source code at line 1932 (not in comment block) AND exists in `addons/common/functions/fnc_findClosest.sqf`. Research confirms provenance comment `// Originally from HAC_fnc.sqf (RYD_FindClosest)` in the addons version. The legacy global name is still defined at runtime since this file is loaded; Phase 3 must delete this duplicate and update any callers to use `FUNC(findClosest)`. |
| RYD_ClusterC | 1999 | migrated | hal_hac | `_points` (array, `_this select 0`); `_range` (number, `_this select 1`) | None (iterates `_points`, proximity clustering) | (none found in 7-file scope; callers presumably in HAL/ scope) | Body commented out inside `/* RYD_ClusterC -> migrated to fnc_clusterC.sqf ... */` (lines 1998–2032). Already in `addons/common/functions/fnc_clusterC.sqf`. Phase 3 deletes this commented block. |
| RYD_PresentRHQ | 2207 | active | hal_data | No params — reads all vehicles/units from `allVehicles`, uses mission-namespace `RYD_WS_*_class` arrays from RHQLibrary.sqf, writes to `RHQ_*` globals | `RYD_WS_*_class` arrays (globals from RHQLibrary.sqf, read directly); `CBA_fnc_clearWaypoints` (Arma 3 API — not tracked) | `nr6_hal/RHQLibrary.sqf:2489` (`[] call RYD_PresentRHQ` at file end); `addons/core/functions/fnc_init.sqf` (indirectly via entry-point setup); `HAC_fnc2.sqf:3238` (`[] spawn RYD_PresentRHQ` from `RYD_PresentRHQLoop`) | Data initialization function — scans all mission vehicles and categorizes them into `RHQ_*` arrays (RHQ_Inf, RHQ_HArmor, etc.) by matching against `RYD_WS_*_class` tables. Belongs with `hal_data` per D-06 (data initialization, populates static asset registry). Will be migrated to `addons/hal_data/` in Phase 3. Reads from RHQLibrary.sqf data arrays — must be extracted AFTER those arrays are extracted. |
| HAL_FBFTLOOP | 2871 | active | hal_boss | `_HQ` (group, `(_this select 0)`) | `HAL_fnc_getType` (line 2915; Arma 3 engine fn — external, not RYD_/HAL_ in scope); `HAL_fnc_getSize` (line 2916; Arma 3 engine fn — external) | `addons/core/functions/fnc_init.sqf:189` (`[[_gp], HAL_FBFTLOOP] call RYD_Spawn`) | Friendly/Enemy Battle-Field Tracking loop — maintains HQ marker groups for visual unit tracking. Entry point via `fnc_init.sqf` line 189 which spawns it per-HQ-side. Runs as `while {not (isNull _HQ)}` loop. `HAL_fnc_getType` / `HAL_fnc_getSize` at lines 2915–2916 are Arma 3 engine functions registered in `VarInit.sqf` — out of scope, not RYD_/HAL_ functions defined in the 7 files. Phase 3 extracts to `addons/hal_boss/functions/fnc_FBFTLOOP.sqf`. |
| HAL_EBFT | 3029 | active | hal_boss | `_HQ` (group, `(_this select 0)`) | `HAL_fnc_getType` (line 3053; Arma 3 engine fn — external); `HAL_fnc_getSize` (line 3054; Arma 3 engine fn — external) | `HAC_fnc2.sqf:308` (`[_HQ] spawn HAL_EBFT` from inside `RYD_StatusQuo` body) | Enemy Battle-Field Tracking — maintains enemy marker display. Spawned from `RYD_StatusQuo` at line 308 (first thing the HQ brain does after reset). Runs as loop until `_HQ` is null. Uses same engine-function pattern as FBFTLOOP. Phase 3 extracts to `addons/hal_boss/functions/fnc_EBFT.sqf`. |
| HAL_SecTasks | 3121 | active | hal_boss | `_HQ` (group, `_this select 0`) | None (reads `_HQ getVariable ["RydHQ_Friends",[]]`, `RYD_AddTask`, `RYD_DeleteWaypoint` via indirect references) | `addons/core/functions/fnc_init.sqf:190` (`[[_gp], HAL_SecTasks] call RYD_Spawn`) | Player secondary task management loop. Entry point via `fnc_init.sqf` line 190 spawned per-HQ-side. Reads the HQ's friends list and manages player-accessible task menu options. Runs as `while {not (isNull _HQ)}` loop. Sleep 15 between cycles. Phase 3 extracts to `addons/hal_boss/functions/fnc_SecTasks.sqf`. |
| RYD_PresentRHQLoop | 3233 | dead? | hal_data | No params (reads global `RydxHQ_RHQAutoFill` and `RydxHQ_AllHQ`) | `RYD_PresentRHQ` (line 3238; spawn) | `nr6_hal/RHQLibrary.sqf:2490` (`[] spawn RYD_PresentRHQLoop` — but this line is inside the conditional block `if (RydxHQ_RHQAutoFill)`) | AMBIGUOUS — The only caller found is `RHQLibrary.sqf:2490` which calls `[] spawn RYD_PresentRHQLoop`. However, research flagged that this call in RHQLibrary.sqf may be commented out. Direct source reading of raw-call-edges.tsv shows `nr6_hal/RHQLibrary.sqf:2490` as a spawn edge to `RYD_PresentRHQLoop` — this IS active. Reclassification: caller IS present in 7-file scope (`RHQLibrary.sqf:2490`). However, the loop itself just wraps `RYD_PresentRHQ` — it is a thin scheduler. Both `hal_data` target since it manages the data initialization loop. |
| RYD_deployUAV | 3244 | migrated | hal_hac | `_gp` (group, `_this select 0`); `_pos` (pos, `_this select 1`); `_HQ` (group, `_this select 2`) | None (manages UAV deployment waypoints) | (none found in 7-file scope) | Body commented out inside `/* RYD_deployUAV -> migrated to fnc_deployUAV.sqf ... */` (lines 3243–3389). Already in `addons/common/functions/fnc_deployUAV.sqf`. Phase 3 deletes this commented block. |

### Dynamic Dispatch

The following call sites in `RYD_StatusQuo` reference functions compiled from `nr6_hal/HAL/*.sqf` via `VarInit.sqf`. They are NOT capturable by static regex on the 7 in-scope files and do NOT appear in `raw-call-edges.tsv`. These edges are documented here as the "LLM review catches what regex misses" value of D-09.

| Line | Call Pattern | External Symbol | Source File (est.) |
|------|-------------|-----------------|-------------------|
| 20 | `[_HQ] call HAL_HQReset` | `HAL_HQReset` | `nr6_hal/HAL/HQReset.sqf` |
| 36 | `[_HQ] call HAL_HQReset` | `HAL_HQReset` | `nr6_hal/HAL/HQReset.sqf` |
| 308 | `[_HQ] spawn HAL_EBFT` | `HAL_EBFT` | `HAC_fnc2.sqf:3029` (same file — in-scope) |
| 1186 | `[...] call HAL_HQOrders` | `HAL_HQOrders` | `nr6_hal/HAL/HQOrders.sqf` |
| 1198 | `[...] call HAL_HQOrdersDef` | `HAL_HQOrdersDef` | `nr6_hal/HAL/HQOrders.sqf` |
| 1281 | `[...] spawn HAL_GoSFAttack` | `HAL_GoSFAttack` | `[external: nr6_hal/HAL/GoSFAttack.sqf]` |
| 1282 | `[..., HAL_GoSFAttack] call RYD_Spawn` | `HAL_GoSFAttack` | `[external: nr6_hal/HAL/GoSFAttack.sqf]` (value_pass) |
| 1464 | `[...] call HAL_Rev` | `HAL_Rev` | `[external: nr6_hal/HAL/Rev.sqf]` |
| 1474 | `[...] call HAL_SuppMed` | `HAL_SuppMed` | `[external: nr6_hal/HAL/SuppMed.sqf]` |
| 1483 | `[...] call HAL_SuppFuel` | `HAL_SuppFuel` | `[external: nr6_hal/HAL/SuppFuel.sqf]` |
| 1492 | `[...] call HAL_SuppRep` | `HAL_SuppRep` | `[external: nr6_hal/HAL/SuppRep.sqf]` |
| 1504 | `[...] call HAL_SuppAmmo` | `HAL_SuppAmmo` | `[external: nr6_hal/HAL/SuppAmmo.sqf]` |
| 1518 | `[...] call HAL_SFIdleOrd` | `HAL_SFIdleOrd` | `[external: nr6_hal/HAL/SFIdleOrd.sqf]` |
| 1525 | `[...] call HAL_Reloc` | `HAL_Reloc` | `[external: nr6_hal/HAL/Reloc.sqf]` |
| 1533 | `[...] call HAL_LPos` | `HAL_LPos` | `[external: nr6_hal/HAL/LPos.sqf]` |
| 1546 | `[...] call HAL_EnemyScan` | `HAL_EnemyScan` | `addons/core/functions/fnc_EnemyScan.sqf` (migrated) |
| 1552 | `[...] spawn HAL_Garrison` | `HAL_Garrison` | `[external: nr6_hal/HAL/Garrison.sqf]` |

**Engine function references** (NOT in-scope edges — Arma 3 built-ins registered via VarInit.sqf):

- `HAC_fnc2.sqf:2915` — `_x call HAL_fnc_getType` (inside `HAL_FBFTLOOP` body)
- `HAC_fnc2.sqf:2916` — `call HAL_fnc_getSize` (inside `HAL_FBFTLOOP` body)
- `HAC_fnc2.sqf:3053` — `_x call HAL_fnc_getType` (inside `HAL_EBFT` body)
- `HAC_fnc2.sqf:3054` — `call HAL_fnc_getSize` (inside `HAL_EBFT` body)

These are Arma 3 engine functions (unit type classification, size queries) compiled at mission start. They are not defined in any of the 7 scoped files.

### Notes

#### RYD_StatusQuo Decomposition Requirement (FUNC-08)

`RYD_StatusQuo` is a 1,779-line mega-function (lines 1–1779). Per Phase 3 requirement FUNC-08, this must be decomposed into sub-functions each under 250 lines before or during extraction. Suggested decomposition boundaries based on source structure:

- Enemy/Friend list update block (~lines 75–310) → `fnc_statusQuo_scanGroups.sqf`
- Radio channel management block (~lines 189–215) → inline or `fnc_statusQuo_radioUpdate.sqf`
- Logistics/support dispatch block (~lines 1460–1560) → `fnc_statusQuo_logistics.sqf`
- Attack order dispatch block (~lines 1180–1280) → `fnc_statusQuo_attackDispatch.sqf`
- Main decision loop orchestrator (~remaining lines) → `fnc_statusQuo.sqf`

Phase 3 executor must read the full body before finalizing decomposition boundaries.

#### Ambiguous Cases Escalated for User Review

1. **RYD_LF_Loop** — No callers found in 7-file scope. The Live Feed loop was likely orphaned when `RYD_LF` / `RYD_LF_EFF` were migrated. AMBIGUOUS: out-of-scope HAL/ or mission scripts may still call it. Phase 3 must confirm before deletion.

2. **RYD_PresentRHQLoop** — Has one caller (`RHQLibrary.sqf:2490`) confirmed in `raw-call-edges.tsv`. This makes it technically `active`, but the body is trivial (thin scheduler wrapping `RYD_PresentRHQ`). The reclassification note is in the table. Not flagged AMBIGUOUS — caller is confirmed.

#### HAC_fnc2.sqf Not Loaded in Current Addon System

`addons/core/functions/fnc_init.sqf` lines 98–102 are commented out (the block that loaded `HAC_fnc.sqf` and `HAC_fnc2.sqf` via `compile preprocessFile`). The functions in this file are NOT currently loaded in the new addon system. The migrated equivalents in `addons/common/` and `addons/core/` replace them. The three HAL_* functions (FBFTLOOP, EBFT, SecTasks) are referenced by name from `fnc_init.sqf` lines 189–190 — this means those names must be available at runtime. Investigation needed in Phase 3: how do these names get defined if HAC_fnc2.sqf is not loaded? Likely through the legacy `VarInit.sqf` bootstrap path which is still active.
