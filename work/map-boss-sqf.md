## Boss.sqf

**File:** `nr6_hal/Boss.sqf` (2,021 lines)
**Declarations:** ZERO — this is an imperative main-loop script stored as the compiled `Boss` variable (via legacy `VarInit.sqf:1085`: `Boss = compile preprocessFile (RYD_Path + "Boss.sqf")`). Spawned per-HQ side from `addons/core/functions/fnc_init.sqf:172` via `[[_x, _BBHQGrps], Boss] call RYD_Spawn`.
**D-08 treatment:** Mapped by logical sections (line ranges + purpose + external calls + state variables) — NOT by function table.
**Phase 4 target:** Boss module refactor — this section map is the blueprint.

---

### Logical Section Breakdown

| section | lines | purpose | external_calls | state_variables |
|---------|-------|---------|----------------|-----------------|
| Preamble / params | 1–26 | Variable declarations (`private [...]`); receive `_BBHQs`, `_BBSide`, `_BBHQGrps` from spawn args | None | Locals: `_BBHQs`, `_BBSide`, `_BBHQGrps` |
| Side A / B init + map bounds | 27–96 | Wait for side B if side A not yet ready; compute map centroid, map extents, sector grid spacing | None | `RydBB_MapC`, `RydBB_MapXMax`, `RydBB_MapXMin`, `RydBB_MapYMax`, `RydBB_MapYMin`, `RydBB_MapLng` |
| Sector creation | 97–177 | Call `RYD_Sectorize` to grid the map; loop every sector calling `RYD_TerraCognita` for topology data; write `RydBB_Sectors`; set `RydBB_mapReady` | `RYD_Sectorize` (line 99, Boss_fnc.sqf:175); `RYD_TerraCognita` (line 137, addons/common — migrated) | `RydBB_Sectors`, `RydBB_mapReady` |
| Strategic objective discovery | 178–336 | Enumerate `allLocations`, filter by `BBStr` / `SAL` objects; build strategic area arrays for each side | `RYD_TerraCognita` (line 233) | `missionNamespace["A_SAreas"]`, `missionNamespace["B_SAreas"]`, `_strArea` |
| Cycle init / stance variables | 337–369 | Initialize `_bbCycle` counter; set flank/front name strings per side (`_leftFlankName`, `_frontName`, etc.) | None | `_bbCycle`, `_allAreTaken`, flank variable name strings |
| Main decision loop (outer) | 370–2021 | Outer `while {RydBB_Active} do` — all tactical decisions per cycle; exits on alive-check failure | Many (see sub-sections) | `RydBB_Active`, `_BBalive`, `_bbCycle` |
| Cycle 1 spawn | 397–454 | On first cycle only: build per-side ObjMark code block; spawn `RYD_ObjMark` for each side via `RYD_Spawn` | `RYD_Spawn` (line 440, addons/common); `RYD_ObjMark` passed as value (line 661) | `RydBBa_Init`, `RydBBb_Init` |
| Force assessment | 455–543 | Compute army positions via `RYD_ForceAnalyze`; derive `_ForcesRep`, `_ownGroups`, `_armyPos` | `RYD_ForceAnalyze` (line 471, Boss_fnc.sqf:513) | `_ForcesRep`, `_ownGroups`, `_armyPos` |
| Attack axis calculation | 544–714 | Find main enemy cluster; compute attack angle via `RYD_AngTowards`; classify sectors left/right/front via `RYD_WhereIs` and `RYD_TopoAnalize` | `RYD_AngTowards` (line 657, addons/common — migrated); `RYD_WhereIs` (lines 671, 677, 689, 746, Boss_fnc.sqf:67); `RYD_TopoAnalize` (lines 720, 726, 732, Boss_fnc.sqf:576); `RYD_Spawn` (line 661); `RYD_Marker` (line 655, Boss_fnc.sqf:1) | `_attackAxis`, sector classification arrays |
| Flank/front assignment | 715–1000 | Assign HQ groups to flanks (left/right/front/reserve) based on topological sector analysis | `RYD_Spawn` | Flank assignments: `_goingLeft`, `_goingRight`, `_goingAhead`, `_goingReserve` |
| Group force counting | 1001–1336 | Count forces in each directional assignment; decide stance (aggressive/defensive/holding); detect if all objectives taken | `RYD_ForceCount` (line 554, Boss_fnc.sqf:418) | `_flankCount`, `_centerCount`, `_allCount`, `_resCount`, stance determination variables, `_allAreTaken` |
| Simple mode / dispatch | 1337–1338 | If `RydBBa_SimpleDebug` / `RydBBb_SimpleDebug` active: spawn `RYD_BBSimpleD` and skip full path planning | `RYD_Spawn` (line 1338); `RYD_BBSimpleD` as value (line 1338, Boss_fnc.sqf:2000) | — |
| Path planning and execution | 1339–1924 | Main path loop: for each assigned HQ group compute `RYD_Itinerary`, transform locations via `RYD_LocMultiTransform`, spawn `RYD_ExecutePath` / `RYD_ReserveExecuting` / `RYD_ObjectivesMon` | `RYD_Itinerary` (line 1799, Boss_fnc.sqf:629); `RYD_LocMultiTransform` (lines 1825, 1897, Boss_fnc.sqf:282); `RYD_Spawn` (lines 1829, 1901, 1924); `RYD_ExecutePath` as value (line 1829, Boss_fnc.sqf:1201); `RYD_ReserveExecuting` as value (line 1901, Boss_fnc.sqf:1320); `RYD_ObjectivesMon` as value (line 1924, Boss_fnc.sqf:1578); `RYD_Marker` (lines 1539, 1893); `RYD_LocLineTransform` (line 1543, Boss_fnc.sqf:259); `RYD_AngTowards` (line 1527); `RYD_PosTowards2D` (line 1532, addons/common — migrated) | Path assignments, `_pathDone` |
| Alive check and interval | 1925–2021 | Mark `RydBBa_Init` / `RydBBb_Init` on first cycle; debug chat; `waitUntil` interval (`RydBB_MainInterval`); alive check loop | None | `_BBalive`, `_aliveHQ`, `RydBBa_Init`, `RydBBb_Init`, `RydBB_MainInterval`, `_bbCycle` increment |

---

### State Variable Inventory

All `RydBB_*` globals used in Boss.sqf — critical for Phase 4 namespacing into `hal_boss` (or dedicated `hal_bb`) namespace:

| variable | read | written | purpose |
|----------|------|---------|---------|
| `RydBB_Active` | yes | no | Loop condition — when false, Boss exits |
| `RydBB_Debug` | yes | no | Enable debug chat/diag_log output |
| `RydBB_MC` | yes | no | Map centroid position |
| `RydBB_MapC` | yes | yes | Map centroid (computed in Side init section) |
| `RydBB_MapXMax` | yes | yes | Map X upper bound |
| `RydBB_MapXMin` | yes | yes | Map X lower bound |
| `RydBB_MapYMax` | yes | yes | Map Y upper bound |
| `RydBB_MapYMin` | yes | yes | Map Y lower bound |
| `RydBB_MapLng` | yes | yes | Map longest dimension |
| `RydBB_Sectors` | yes | yes | Array of sectors from `RYD_Sectorize` |
| `RydBB_mapReady` | yes | yes | Flag: sector/terrain data initialized |
| `RydBBa_HQs` | yes | no | Side A HQ leaders array |
| `RydBBb_HQs` | yes | no | Side B HQ leaders array |
| `RydBBa_SAL` | yes | no | Side A SAL (chat object) |
| `RydBBb_SAL` | yes | no | Side B SAL (chat object) |
| `RydBBa_Str` | yes | no | Side A strategic areas |
| `RydBBb_Str` | yes | no | Side B strategic areas |
| `RydBBa_Init` | yes | yes | Side A first-cycle complete flag |
| `RydBBb_Init` | yes | yes | Side B first-cycle complete flag |
| `RydBBaHQ` | yes | no | Side A HQ group reference |
| `RydBBbHQ` | yes | no | Side B HQ group reference |
| `RydBB_CustomObjOnly` | yes | no | Restrict to custom objectives only |
| `RydBB_BBOnMap` | yes | no | Flag: BB units are on map |
| `RydBB_CivF` | yes | no | Civilian faction setting |
| `RydBB_MainInterval` | yes | no | Decision cycle interval (seconds) |

---

### Dynamic Dispatch (value-pass to RYD_Spawn)

Boss.sqf passes function references as values to `RYD_Spawn` rather than using direct `call` or `spawn`. These are **invisible to symbol-regex call-site extraction** — they must be tracked as value-pass edges:

| line | function passed | target declaration | section |
|------|-----------------|-------------------|---------|
| 440 | `_code` (holds `RYD_ObjMark` block) | `RYD_ObjMark` (Boss_fnc.sqf:1723) | Cycle 1 spawn |
| 661 | `RYD_ObjMark` | `RYD_ObjMark` (Boss_fnc.sqf:1723) | Attack axis calculation |
| 1338 | `RYD_BBSimpleD` | `RYD_BBSimpleD` (Boss_fnc.sqf:2000) | Simple mode / dispatch |
| 1829 | `RYD_ExecutePath` | `RYD_ExecutePath` (Boss_fnc.sqf:1201) | Path planning and execution |
| 1901 | `RYD_ReserveExecuting` | `RYD_ReserveExecuting` (Boss_fnc.sqf:1320) | Path planning and execution |
| 1924 | `RYD_ObjectivesMon` | `RYD_ObjectivesMon` (Boss_fnc.sqf:1578) | Path planning and execution |

**Note:** Line 440 uses a local `_code` variable built earlier in the cycle-1 block (lines 397–440) that assembles the `RYD_ObjMark` call. Line 661 passes `RYD_ObjMark` directly as a symbol. Both create the same inbound edge to `RYD_ObjMark`.

---

### External Call Summary (raw-call-edges.tsv, caller_file=Boss.sqf)

| line | symbol | edge_type | target_file |
|------|--------|-----------|-------------|
| 75 | `RYD_Marker` | call | Boss_fnc.sqf:1 |
| 99 | `RYD_Sectorize` | call | Boss_fnc.sqf:175 |
| 106 | `RYD_Marker` | call | Boss_fnc.sqf:1 |
| 137 | `RYD_TerraCognita` | call | addons/common (migrated) |
| 233 | `RYD_TerraCognita` | call | addons/common (migrated) |
| 440 | `RYD_Spawn` | call | addons/common (migrated) |
| 471 | `RYD_ForceAnalyze` | call | Boss_fnc.sqf:513 |
| 493 | `RYD_Marker` | call | Boss_fnc.sqf:1 |
| 510 | `RYD_Marker` | call | Boss_fnc.sqf:1 |
| 655 | `RYD_Marker` | call | Boss_fnc.sqf:1 |
| 657 | `RYD_AngTowards` | call | addons/common (migrated) |
| 661 | `RYD_Spawn` | call | addons/common (migrated) |
| 671 | `RYD_WhereIs` | call | Boss_fnc.sqf:67 |
| 677 | `RYD_WhereIs` | call | Boss_fnc.sqf:67 |
| 689 | `RYD_WhereIs` | call | Boss_fnc.sqf:67 |
| 720 | `RYD_TopoAnalize` | call | Boss_fnc.sqf:576 |
| 726 | `RYD_TopoAnalize` | call | Boss_fnc.sqf:576 |
| 732 | `RYD_TopoAnalize` | call | Boss_fnc.sqf:576 |
| 746 | `RYD_WhereIs` | call | Boss_fnc.sqf:67 |
| 1338 | `RYD_Spawn` | call | addons/common (migrated) |
| 1527 | `RYD_AngTowards` | call | addons/common (migrated) |
| 1532 | `RYD_PosTowards2D` | call | addons/common (migrated) |
| 1539 | `RYD_Marker` | call | Boss_fnc.sqf:1 |
| 1543 | `RYD_LocLineTransform` | call | Boss_fnc.sqf:259 |
| 1799 | `RYD_Itinerary` | call | Boss_fnc.sqf:629 |
| 1825 | `RYD_LocMultiTransform` | call | Boss_fnc.sqf:282 |
| 1829 | `RYD_Spawn` | call | addons/common (migrated) |
| 1893 | `RYD_Marker` | call | Boss_fnc.sqf:1 |
| 1897 | `RYD_LocMultiTransform` | call | Boss_fnc.sqf:282 |
| 1901 | `RYD_Spawn` | call | addons/common (migrated) |
| 1924 | `RYD_Spawn` | call | addons/common (migrated) |
| 661 | `RYD_ObjMark` | value_pass | Boss_fnc.sqf:1723 |
| 1337 | `RYD_BBSimpleD` | spawn | Boss_fnc.sqf:2000 |
| 1338 | `RYD_BBSimpleD` | value_pass | Boss_fnc.sqf:2000 |
| 1827 | `RYD_ExecutePath` | spawn | Boss_fnc.sqf:1201 |
| 1829 | `RYD_ExecutePath` | value_pass | Boss_fnc.sqf:1201 |
| 1899 | `RYD_ReserveExecuting` | spawn | Boss_fnc.sqf:1320 |
| 1901 | `RYD_ReserveExecuting` | value_pass | Boss_fnc.sqf:1320 |
| 1923 | `RYD_ObjectivesMon` | spawn | Boss_fnc.sqf:1578 |
| 1924 | `RYD_ObjectivesMon` | value_pass | Boss_fnc.sqf:1578 |

**Unique Boss_fnc.sqf functions called from Boss.sqf:** `RYD_Marker`, `RYD_Sectorize`, `RYD_ForceAnalyze`, `RYD_WhereIs`, `RYD_TopoAnalize`, `RYD_ForceCount`, `RYD_LocLineTransform`, `RYD_LocMultiTransform`, `RYD_Itinerary`, `RYD_ObjMark`, `RYD_BBSimpleD`, `RYD_ExecutePath`, `RYD_ReserveExecuting`, `RYD_ObjectivesMon` (14 of the 21 Boss_fnc.sqf functions — the remaining 7 are called indirectly via the spawned functions).

---

### Phase 4 Refactor Blueprint Note

This section map is the **canonical input to Phase 4's Boss module refactor**. Phase 4 planning MUST consume `map-boss-sqf.md` as its primary source for:

1. **Namespace migration:** All `RydBB_*` globals in the State Variable Inventory above must be re-namespaced to `GVAR(*)` or `hal_boss_GVAR(*)` macros in the refactored `hal_boss` addon.
2. **Section extraction order:** The 14 logical sections map directly to sub-functions in the refactored Boss module. Natural extraction boundaries are the section headers above — each section becomes a `fnc_boss{SectionName}.sqf` candidate.
3. **Value-pass pattern migration:** The 6 dynamic dispatch sites (lines 440, 661, 1338, 1829, 1901, 1924) must be rewritten using `FUNC()` macro references rather than bare symbol names — the symbol names will change when `Boss_fnc.sqf` declarations are renamed via `PREP(...)`.
4. **Entry point:** The `Boss` compiled variable (loaded via `VarInit.sqf:1085`, spawned from `fnc_init.sqf:172`) must become a proper `PREP(boss)` CBA function in `hal_boss` — removing the compile-variable bootstrap entirely.
5. **Dependency order:** Boss.sqf calls 14 Boss_fnc.sqf functions. Per the Phase 1 DAG (`hal_data → hal_hac → hal_boss → hal_tasking`), all Boss_fnc.sqf functions must be PREP'd before Boss.sqf's successor function runs.
