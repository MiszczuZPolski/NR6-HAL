## Boss_fnc.sqf

**File:** `nr6_hal/Boss_fnc.sqf` (2,202 lines)
**Declarations:** 21 `RYD_*` strategic functions (all active, all target hal_boss per D-06 section 6)
**Phase 3 target:** `addons/hal_boss/functions/fnc_*.sqf` (one file per function)

### Function Table

| name | line | classification | target_addon | params | calls | called_by | notes |
|------|------|----------------|--------------|--------|-------|-----------|-------|
| RYD_Marker | 1 | active | hal_boss | `_name, _pos, _cl, _shape, _size, _dir, _alpha, _type/_brush, _text` (9 params via `_this select N`) | (none — Arma 3 marker API only) | Boss.sqf:75, 106, 493, 510, 655; Boss_fnc.sqf:748, 1253, 1275, 1568, 1741, 2083, 2098, 2180 | Writes to `RydxHQ_Markers` array via `set`. Returns marker name. No external RYD_ calls. |
| RYD_DistOrdB | 40 | active | hal_boss | `_array, _point, _limit` (3 params via `_this select N`) | (none) | Boss_fnc.sqf:1240 | Distance-sorted array variant B. Pure math/array utility; no external calls. Analogous to `RYD_DistOrd` (HAC_fnc) but variant B for Boss context. |
| RYD_WhereIs | 67 | active | hal_boss | `_point, _rPoint, _axis` (3 params) | RYD_AngTowards (line 75) | Boss.sqf:671, 677, 689, 746 | Returns directional string (left/right/front/rear) relative to axis. Calls migrated `RYD_AngTowards` (addons/common/functions/fnc_angleTowards.sqf). |
| RYD_TerraCognita | 106 | active | hal_boss | `_position, _samples [, _rds=100]` (2-3 params via `_this select N`) | (Arma 3 selectBestPlaces API only) | Boss.sqf:137, 233; HAC_fnc.sqf:797, 1459, 4418 | **DUAL PRESENCE** — see TerraCognita Dual Presence section below. Classification is `active` with AMBIGUOUS flag pending resolution. |
| RYD_Sectorize | 175 | active | hal_boss | `_ctr, _lng, _ang, _nbr` (4+ params via `_this select N`) | (Arma 3 createLocation / location API) | Boss.sqf:99 | Divides map into grid sectors as location objects. No external RYD_ calls; pure geometry + Arma 3 location API. |
| RYD_LocLineTransform | 259 | active | hal_boss | `_loc, _p1, _p2, _space` (4 params) | RYD_AngTowards (line 270) | Boss_fnc.sqf:642, 918; Boss.sqf:1543 | Sets size/dir/pos of a location object to span a line between two points. Returns `true`. |
| RYD_LocMultiTransform | 282 | active | hal_boss | `_loc, _ps, _space` (3 params) | RYD_AngTowards (line 357) | Boss.sqf:1825, 1897 | Sets a location to encompass multiple points. More complex than LocLineTransform; handles point clustering. |
| RYD_ForceCount | 418 | active | hal_boss | `_friends, _inf, _car, _arm, _air, _nc, _current, _initial, _value, _morale, _enemies, _einf, _ecar, _earm, _eair, _enc, _evalue` (17 params via `_this select N`) | (none) | Boss.sqf:554 (implied via Boss_fnc.sqf:554 cross-check) | Computes friendly/enemy force strength metrics and morale. Large param surface — all numeric force stats. Pure computation, no external calls. |
| RYD_ForceAnalyze | 513 | active | hal_boss | `_HQarr` (1 param — array of HQ groups) | (none — Arma 3 unit/group API) | Boss.sqf:471 | Iterates HQ array to categorize units into friendly/enemy force composition arrays. Returns `[_frArr, _enArr, _frG, _enG, _HQs]`. |
| RYD_TopoAnalize | 576 | active | hal_boss | `_sectors` (1 param — array of location objects) | (none — getVariable on location objects) | Boss.sqf:720, 726, 732; Boss_fnc.sqf:684, 688 | Aggregates topology variables (`Topo_Urban`, `Topo_Forest`, `Topo_Hills`, `Topo_Flat`, `Topo_Sea`, `Topo_Roads`) from a sector list. Reads sector `getVariable` data set by RYD_Sectorize. |
| RYD_Itinerary | 629 | active | hal_boss | `_sectors, _targets, _pos1, _pos2, _side` (5 params) | RYD_LocLineTransform (line 642), RYD_TopoAnalize (implied via sector analysis) | Boss.sqf:1799 | Plans path through sectors between two positions. Creates a temporary location to test containment. Calls RYD_LocLineTransform to set the path bounding location. |
| RYD_ExecuteObj | 696 | active | hal_boss | `_sortedA, _HQ, _side, _BBAOObj, _AAO, _allied, _front, _frPos, _frDir, _frDim, _reserve, _HandledArray, _varName, _o1, _o2, _o3, _o4` (17 params) | RYD_Spawn (via value-pass at lines 1290–1293 self-reference), RYD_LocLineTransform (line 918), RYD_AIChatter (line 1437), RYD_AddTask (line 1439), RYD_WPadd (line 1443), RYD_Wait (line 1445), RYD_Spawn (line 1457), RYD_Mark (line 1568) | Boss_fnc.sqf:1290, 1291, 1292, 1293 (value-passed to RYD_Spawn — self-recursive dispatch) | **DYNAMIC DISPATCH TARGET**: passed as value in lines 1290–1293 inside RYD_ExecutePath. The pattern is `[[args, RYD_ExecuteObj] call RYD_Spawn` — function reference, not direct call. Sets `BBObj1Done`–`BBObj4Done` variables. Very long function (~500 lines, 696–1199). |
| RYD_ExecutePath | 1201 | active | hal_boss | `_HQ, _areas, _o1, _o2, _o3, _o4, _allied` (7 params) | RYD_DistOrdB (line 1240), RYD_Mark (line 1253, 1275), RYD_AngTowards (line 1268), RYD_Spawn (lines 1290–1293 to dispatch RYD_ExecuteObj as value) | Boss.sqf:1827 (value-pass as spawn target), Boss.sqf:1829 (RYD_Spawn call) | Prepares objective assignments then dispatches RYD_ExecuteObj (up to 4 concurrent spawns) based on `_BBAOObj` count. The 4 value-pass sites at lines 1290–1293 are the central dynamic dispatch mechanism for the Big Boss objective execution system. |
| RYD_ReserveExecuting | 1320 | active | hal_boss | `_HQ, _ahead, _o1, _o2, _o3, _o4, _allied, _front, _taken, _hostileG` (10 params) | RYD_AngTowards (line 1367), RYD_PosTowards2D (line 1373), RYD_AIChatter (line 1437), RYD_WPadd (line 1559), RYD_Mark (line 1568) | Boss.sqf:1899 (value-pass to RYD_Spawn), Boss.sqf:1901 (RYD_Spawn call) | Manages reserve force assignment and repositioning. Long background loop function (~260 lines). Value-passed to RYD_Spawn from Boss.sqf line 1901. |
| RYD_ObjectivesMon | 1578 | active | hal_boss | `_area, _BBSide, _HQ, _HQs` (4 params) | (Arma 3 unit/nearObjects API) | Boss.sqf:1923 (value-pass to RYD_Spawn), Boss.sqf:1924 (RYD_Spawn call) | Monitors objective area capture status in a `while {RydBB_Active}` loop (sleeps 15s). Sets `BBProg` variable. Value-passed to RYD_Spawn from Boss.sqf line 1924. |
| RYD_ObjMark | 1723 | active | hal_boss | `_strArea, _BBSide` (2 params via `_this select N`) | RYD_Marker (line 1741) | Boss.sqf:661 (value-pass to RYD_Spawn), Boss.sqf:440 (RYD_Spawn call for cycle 1 init) | Renders objective area markers. Returns `_markers` array. Value-passed to RYD_Spawn from Boss.sqf line 661. |
| RYD_ClusterA | 1769 | active | hal_boss | `_points, _range` (2 params) | (none) | Boss_fnc.sqf:1917 (called from RYD_Cluster) | Cluster-by-center variant A. Pure array math. Called internally by RYD_Cluster. |
| RYD_ClusterB | 1811 | active | hal_boss | `_points` (1 param) | (none) | Boss_fnc.sqf:1893 (called from RYD_Cluster) | Cluster-by-density variant B. Pure array math. Called internally by RYD_Cluster. |
| RYD_Cluster | 1887 | active | hal_boss | `_points` (1 param) | RYD_ClusterB (line 1893), RYD_ClusterA (line 1917) | Boss_fnc.sqf:2126 (called from RYD_BBSimpleD) | Top-level cluster algorithm: calls ClusterB for initial grouping, then ClusterA for center refinement. |
| RYD_isOnMap | 1952 | active | hal_boss | `_pos` (1 param) | (none — reads `RydBB_MC` namespace variable) | Boss_fnc.sqf:2051, 2157 (called from RYD_BBSimpleD) | Map bounds check using `RydBB_MapXMax/Min/YMax/Min` globals. Returns boolean. |
| RYD_BBSimpleD | 2000 | active | hal_boss | `_HQs, _BBSide` (2 params) | RYD_Cluster (line 2126), RYD_isOnMap (lines 2051, 2157), RYD_AngTowards (line 2077), RYD_Mark (lines 2083, 2098, 2180) | Boss.sqf:1337 (value-pass to RYD_Spawn), Boss.sqf:1338 (RYD_Spawn call) | Big Boss simple-mode display loop. Runs while `RydBB_Active`. Renders battle-line overlays. Value-passed to RYD_Spawn from Boss.sqf line 1338. |

### Dynamic Dispatch

Value-pass patterns where a function reference is passed as an argument to `RYD_Spawn` (the `[[args, FuncRef] call RYD_Spawn` pattern). These are NOT direct calls — the function executes inside `RYD_Spawn`'s spawned thread. Static regex on `call`/`spawn` keywords will NOT detect these edges.

| Site | File | Lines | Function passed | Context |
|------|------|-------|-----------------|---------|
| 1 | `Boss_fnc.sqf` | 1290–1293 | `RYD_ExecuteObj` | Inside `RYD_ExecutePath`: 4 conditional spawns based on `_BBAOObj` count (1/2/3/4). Each spawns one objective executor. The pattern is: `[[_sortedA,_HQ,_side,_AssObj,_AAO,_allied,_front,_frPos,_frDir,_frDim,_reserve,_HandledArray,_varName,_o1,_o2,_o3,_o4],RYD_ExecuteObj] call RYD_Spawn` |
| 2 | `Boss.sqf` | 440 / 661 | `RYD_ObjMark` | Cycle 1 init: spawns per-side objective marker loop. Line 661 also passes `RYD_ObjMark` as value; line 440 is the RYD_Spawn call site. |
| 3 | `Boss.sqf` | 1337 / 1338 | `RYD_BBSimpleD` | Simple mode branch: if `_bbSimple` flag set, spawn the simple display loop instead of full path execution. |
| 4 | `Boss.sqf` | 1827 / 1829 | `RYD_ExecutePath` | Main path execution spawn for primary HQ. Line 1829 is the RYD_Spawn call site. |
| 5 | `Boss.sqf` | 1899 / 1901 | `RYD_ReserveExecuting` | Reserve force execution spawn. Line 1901 is the RYD_Spawn call site. |
| 6 | `Boss.sqf` | 1923 / 1924 | `RYD_ObjectivesMon` | Objective capture monitor spawn. Line 1924 is the RYD_Spawn call site. |

**Phase 3 implication:** When extracting these functions into `hal_boss`, their Phase 3 PREP entries must be declared BEFORE the calling functions in XEH_PREP.hpp. The leaf-first order for dynamic dispatch targets is: `RYD_ExecuteObj` before `RYD_ExecutePath`; `RYD_ObjMark` before `Boss.sqf` entry; `RYD_BBSimpleD`, `RYD_ReserveExecuting`, `RYD_ObjectivesMon` before Boss main loop.

### TerraCognita Dual Presence

`RYD_TerraCognita` is declared in **both** `Boss_fnc.sqf:106` and `addons/common/functions/fnc_terraCognita.sqf`. The migration map (`raw-migration-map.tsv`) records it as migrated. This section resolves whether the bodies are functionally identical.

#### Boss_fnc.sqf version (lines 106–173, ~68 lines)

- **Params style:** Old-style `private [...]` block + `_this select N` extraction
- **Third param:** Named `_rds` (radius), default 100 applied via `if ((count _this) > 2) then`
- **Gradient calc:** Uses `_hprev`/`_hcurr` but only computes diff against the **initial** position (`_hprev` is set once to initial height and never updated in the loop — each iteration compares `_hcurr` vs original `_hprev`)
- **SelectBestPlaces:** No safety check on empty result — directly does `_val0 = _value select 0; _val0 = _val0 select 1` which would error on empty array
- **Line count:** 68 lines

#### addons/common/functions/fnc_terraCognita.sqf version (80 lines)

- **Params style:** Modern `params ["_position", "_samples", ["_radius", 100]]`
- **Third param:** Named `_radius` (same semantic, cleaner name)
- **Gradient calc:** `_prevHeight` is correctly **updated each iteration** (`_prevHeight = _currentHeight` at end of loop body) — this produces a true cumulative slope gradient rather than radial delta from origin
- **SelectBestPlaces:** Has safety check `if (count _bestValue > 0) then` before extracting values — prevents nil errors on sparse terrain
- **Return:** Identical type: `[_urban, _forest, _hills, _flat, _sea, _groundGradient]`

#### Body Diff Verdict: DIFFERS — bodies are NOT functionally identical

Two behavioral differences identified:

1. **Gradient calculation bug in legacy version:** The Boss_fnc.sqf version computes `abs(_hcurr - _hprev)` where `_hprev` is the height at the origin point (never updated). The migrated version correctly updates `_prevHeight = _currentHeight` after each sample, producing a proper cumulative slope measurement. The migrated version returns a more accurate gradient value.

2. **Missing safety check in legacy version:** The legacy version crashes (nil-select error) if `selectBestPlaces` returns an empty array for sparse terrain. The migrated version guards with `if (count _bestValue > 0)`.

#### Recommendation

**Phase 3 must use the migrated `fnc_terraCognita.sqf` version and delete the legacy Boss_fnc.sqf redeclaration.** The migrated version is a bug-fix-and-cleanup of the original. Classification for the Boss_fnc.sqf entry remains `active` (it is the currently-executed version since Boss_fnc.sqf loads after the addon system sets up), but Phase 3 should wire Boss.sqf and HAC_fnc.sqf callers to `FUNC(terraCognita)` from `addons/common/` and remove the Boss_fnc.sqf body.

**Callers of RYD_TerraCognita:**
- Boss.sqf:137, 233 (sector terrain analysis in sector creation section)
- HAC_fnc.sqf:797, 1459, 4418 (recon and tactical analysis)
