## HAC_fnc.sqf

**File:** `nr6_hal/HAC_fnc.sqf` (5,645 lines)
**Active declarations:** 1 genuinely active (`RYD_Dispatcher`, line 1276); 9 others are inside `/* */` comment blocks — all commented-out originals (migrated or superseded). The research-phase grep (`^RYD_`) matched these even inside multi-line comment blocks; this document corrects that classification.

### Function Table

| name | line | classification | target_addon | params | calls | called_by | notes |
|------|------|----------------|--------------|--------|-------|-----------|-------|
| RYD_WPadd | 596 | migrated | hal_hac | implicit: `_this select 0` (group), `_this select 1`+ (pos, tp, beh, CM, spd, sts, crr, rds, TO, formation) — 11 fields | `RYD_FlatLandNoRoad`, `RYD_TerraCognita`, `RYD_AngTowards`, `RYD_PosTowards2D` (all via commented body) | HAC_fnc2.sqf:1342,1414; Boss_fnc.sqf:1192,1443,1559 (still active callers in other files) | Body commented out inside `/* RYD_WPadd -> replaced by CBA_fnc_addWaypoint ... */` (lines 595–905). Migrated to stub `addons/common/functions/fnc_WPadd.sqf` (Phase 1 placeholder — real migration in Phase 3). Dual presence: legacy block is dead, but active callers remain in other files calling the legacy global name. Phase 3 must implement fnc_WPadd.sqf fully before deleting this block. |
| RYD_GoLaunch | 977 | migrated | hal_hac | `_kind` (string: INF/ARM/SNP/AIR/AIRCAP/NAVAL) — implicit `_this select 0` | Returns HAL_GoAtt* code reference (switch-dispatch to external HAL_ values) | HAC_fnc.sqf:1715,1717 (commented callers); TaskInitNR6.sqf:243,361,474 (active callers) | Body commented out inside `/* RYD_GoLaunch -> migrated to fnc_goLaunch.sqf ... */` (lines 976–997). Migrated to `addons/common/functions/fnc_goLaunch.sqf`. Active callers remain in TaskInitNR6.sqf calling legacy global name — dual presence risk until Phase 3 renames all call sites. |
| RYD_FindClosestWithIndex | 1000 | dead? | hal_hac | `_ref` (object/pos), `_objects` (array) — implicit `_this select 0,1` | `RYD_FindClosest` (internal, via commented body) | HAC_fnc.sqf:1089 (in commented `RYD_DistOrd` body — also dead) | AMBIGUOUS — body commented out inside `/* RYD_FindClosestWithIndex -> dead code once DistOrd/DistOrdC replaced by CBA_fnc_sortNestedArray ... */` (lines 999–1040, plus duplicate block 1042–1075). Comment header explicitly marks this as dead code. No active callers found in 7-file scope. Phase 3 must confirm before deletion. |
| RYD_DistOrd | 1077 | dead? | hal_hac | `_array` (array), `_point` (pos/object), `_limit` (number) — implicit `_this select 0,1,2` | `RYD_FindClosestWithIndex` (commented body) | HAC_fnc.sqf:1270,1498 (both in commented `RYD_Recon`/`RYD_Dispatcher` bodies); HAL/SCargo.sqf:102 (out of scope) | Body commented out inside `/* RYD_DistOrd -> replaced by CBA_fnc_sortNestedArray ... */` (lines 1076–1105). Both in-scope callers are also inside comment blocks. Only active caller is `nr6_hal/HAL/SCargo.sqf` which is out of Phase 2 scope. Phase 3 must check HAL/SCargo.sqf before deleting. |
| RYD_DistOrdC | 1108 | dead? | hal_hac | `_array` (array), `_point` (pos/object), `_limit` (number) — implicit `_this select 0,1,2` | None | (none found in 7-file scope) | AMBIGUOUS — body commented out inside `/* RYD_DistOrdC -> replaced by CBA_fnc_sortNestedArray ... */` (lines 1107–1134). Comment header marks as superseded. No active callers found in entire 7-file scope. Not in raw-migration-map.tsv (no migrated equivalent in addons/). Phase 3 must confirm no callers in out-of-scope HAL/ files before deletion. |
| RYD_DistOrdD | 1137 | migrated | hal_hac | `_array` (array), `_point` (pos/object), `_limit` (number) — implicit `_this select 0,1,2`; uses internal `_pos`, `_sort`, `_mid` | None via commented body | (none found in 7-file scope) | Body commented out inside `/* RYD_DistOrdD -> migrated to fnc_distOrdD.sqf ... */` (lines 1136–1179). Migrated to `addons/common/functions/fnc_distOrdD.sqf`. No active callers in 7-file scope — legacy callers would have been using global name which is now dead. Phase 3 deletes this commented block. |
| RYD_Recon | 1182 | migrated | hal_hac | `_gps` (bool), `_IR` (bool), `_rcArr` (array), `_lmt` (number), `_trg` (object/group) — implicit `_this select 0..4` | `RYD_DistOrd` (via commented body) | (none found in 7-file scope; active callers presumably in HAL/ scope) | Body commented out inside `/* RYD_Recon -> migrated to fnc_recon.sqf ... */` (lines 1181–1274). Migrated to `addons/common/functions/fnc_recon.sqf`. Phase 3 deletes this commented block. |
| RYD_Dispatcher | 1276 | active | hal_hac | `_threat` (array), `_kind` (string), `_HQ` (group), `_ATriskResign1`, `_ATriskResign2`, `_AAriskResign`, `_AAthreat`, `_ATthreat`, `_armorATthreat`, `_Fpool` (array of 20 elements) — `_this select 0..9` | `[external: nr6_hal/HAL/HQOrders.sqf]` (HAL_GoCapture, HAL_GoAttAir, HAL_GoAttInf, HAL_GoAttSniper, HAL_GoAttArmor, HAL_GoAttNaval via `_code` value dispatch), `RYD_VarReductor` (called in body lines ~1700+) | `[external: nr6_hal/HAL/HQOrders.sqf:642–682]` (only active caller — out of 7-file scope) | ONLY genuinely active (uncommented) function in HAC_fnc.sqf. 466-line body (lines 1276–1741). Dispatches force to attack objectives by composing attack orders. Uses GoLaunch-style value dispatch internally — calls `_code = HAL_GoAtt*` then `[_HQ,_threat,_kind] call _code`. External HAL_* calls are NOT capturable by static regex — they are runtime-compiled references from VarInit.sqf. Phase 3 must extract this as `hal_hac_fnc_dispatcher.sqf`. |
| RYD_VarReductor | 1744 | migrated | hal_hac | `_trg` (group/object), `_kind` (string) — implicit `_this select 0,1` | None (standalone, reads/writes `HAC_Attacked` group variable) | RYD_Dispatcher body (line ~1700+, active); other callers in HAL/ scope (out of scope) | Body commented out inside `/* RYD_VarReductor -> migrated to fnc_varReductor.sqf ... */` (lines 1743–1777). Migrated to `addons/common/functions/fnc_varReductor.sqf`. However, the active `RYD_Dispatcher` body calls it — meaning the global name `RYD_VarReductor` must still resolve at runtime. Phase 3 must update `RYD_Dispatcher` to call `FUNC(varReductor)` before deleting the legacy global. |
| RYD_RHQCheck | 5441 | migrated | hal_hac | No params (reads mission-namespace globals `RHQ_*`, `RHQs_*`, `RYD_WS_*_class` directly) | `RYD_WS_*_class` arrays from RHQLibrary.sqf (read as globals) | (none found in 7-file scope; active callers presumably in HAL/ scripts or entry-point chain) | Body commented out inside `/* RYD_RHQCheck -> migrated to fnc_rhqCheck.sqf ... */` (lines 5440–5560). Migrated to `addons/common/functions/fnc_rhqCheck.sqf`. Large function spanning 120 lines — populates force-composition summary. Phase 3 deletes this commented block. |

### Notes

#### Lines 1–595: Commented-Out Block (D-04)

Lines 1–595 contain `//`-commented originals of functions migrated to `addons/common/functions/` in an earlier work session. These are NOT enumerated as separate table rows per D-04 (Phase 2 documents only, does not touch source). The commented symbols in this block are listed below.

The `/* */` comment pattern extends beyond line 595 — all 9 non-Dispatcher declarations (lines 596–5560) are also inside `/* */` blocks with migration notes in the comment headers. This corrects the research-phase characterization of "10 active declarations at line 596+".

#### Commented-Out Migrated Symbols (lines 1–595 and embedded `/* */` blocks)

The 34 symbols that appear in commented form (either `//` lines 1–595 or `/* */` wraps per above table):

- `RYD_AIChatter` → `addons/common/functions/fnc_AIChatter.sqf` (migrated)
- `RYD_AmmoCount` → `addons/common/functions/fnc_ammoCount.sqf` (migrated)
- `RYD_AmmoFullCount` → `addons/common/functions/fnc_ammoFullCount.sqf` (migrated)
- `RYD_AngTowards` → `addons/common/functions/fnc_angleTowards.sqf` (migrated)
- `RYD_CloseEnemy` → `addons/common/functions/fnc_closeEnemy.sqf` (migrated)
- `RYD_CloseEnemyB` → `addons/common/functions/fnc_closeEnemyB.sqf` (migrated)
- `RYD_CreateDecoy` → `addons/common/functions/fnc_createDecoy.sqf` (migrated)
- `RYD_FireCount` → `addons/common/functions/fnc_fireCount.sqf` (migrated)
- `RYD_Flares` → `addons/common/functions/fnc_flares.sqf` (migrated)
- `RYD_GarrP` → `addons/common/functions/fnc_garrisonP.sqf` (migrated)
- `RYD_GarrS` → `addons/common/functions/fnc_garrisonS.sqf` (migrated)
- `RYD_GroupMarkerLoop` → `addons/common/functions/fnc_groupMarkerLoop.sqf` (migrated)
- `RYD_HQChatter` → `addons/common/functions/fnc_HQChatter.sqf` (migrated)
- `RYD_isNight` → `addons/common/functions/fnc_isNight.sqf` (migrated)
- `RYD_LOSCheck` → `addons/common/functions/fnc_LOSCheck.sqf` (migrated)
- `RYD_Mark` → `addons/common/functions/fnc_mark.sqf` (migrated)
- `RYD_OrderPause` → `addons/common/functions/fnc_orderPause.sqf` (migrated)
- `RYD_PointToSecDst` → `addons/common/functions/fnc_pointToSecondaryDistance.sqf` (migrated)
- `RYD_PosTowards2D` → `addons/common/functions/fnc_positionTowards2D.sqf` (migrated)
- `RYD_RandomAround` → `addons/common/functions/fnc_positionAround.sqf` (migrated; renamed)
- `RYD_RandomAroundB` → `addons/common/functions/fnc_randomAroundB.sqf` (migrated)
- `RYD_RandomAroundMM` → `addons/common/functions/fnc_randomAroundMM.sqf` (migrated)
- `RYD_ReverseArr` → `addons/common/functions/fnc_reverseArr.sqf` (migrated)
- `RYD_Smoke` → `addons/common/functions/fnc_smoke.sqf` (migrated)
- `RYD_TerraCognita` → `addons/common/functions/fnc_terraCognita.sqf` (migrated)
- `RYD_Wait` → `addons/common/functions/fnc_wait.sqf` (migrated)
- `RYD_WPSync` → `addons/common/functions/fnc_WPSync.sqf` (migrated)
- `RYD_FindBiggest` → `addons/common/functions/fnc_findBiggest.sqf` (migrated; in XEH_PREP.hpp)
- `RYD_FlatLandNoRoad` → `addons/common/functions/fnc_flatLandNoRoad.sqf` (migrated; in XEH_PREP.hpp)
- `RYD_GoInside` → `addons/common/functions/fnc_goInside.sqf` (migrated; in XEH_PREP.hpp)
- `RYD_NearestRoad` → `addons/common/functions/fnc_nearestRoad.sqf` (migrated; in XEH_PREP.hpp)
- `RYD_RoofOver` → `addons/common/functions/fnc_roofOver.sqf` (migrated; in XEH_PREP.hpp)
- `RYD_ValueOrd` → `addons/common/functions/fnc_valueOrd.sqf` (migrated; in XEH_PREP.hpp)
- `RYD_WPadd` → `addons/common/functions/fnc_WPadd.sqf` (Phase 1 stub; real migration in Phase 3)

#### Ambiguous Cases Escalated for User Review

1. **RYD_DistOrdC** — No active callers found in 7-file scope and no migrated equivalent in addons/. Comment header says "replaced by CBA_fnc_sortNestedArray". AMBIGUOUS: may be called from out-of-scope HAL/ files. Phase 3 must search HAL/ before deleting.

2. **RYD_FindClosestWithIndex** — Comment header explicitly says "dead code once DistOrd/DistOrdC replaced". No callers outside commented blocks. Most likely safe to delete in Phase 3, but the HAL/ scope check should confirm.

#### Research-Phase Correction

The Phase 2 research characterized HAC_fnc.sqf as having "10 active declarations at line 596+". Direct source reading reveals all 10 symbols are wrapped in `/* */` comment blocks — the grep pattern `^RYD_` matched them even inside multi-line comments because grep is line-oriented, not block-aware. The corrected picture: 1 active function (`RYD_Dispatcher`), 6 migrated (commented), 3 dead (commented). This does not affect Phase 3 planning — the symbols still need processing — but the classification changes from active to migrated/dead for 9 of 10.
