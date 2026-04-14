## TaskInitNR6.sqf

**File:** `nr6_hal/TaskInitNR6.sqf` (1,607 lines)
**Declarations:** 72 global callback functions using the `Action*ct` / `Action*fnc` / `ACEAction*fnc` / `*R` (remove) naming scheme — NOT RYD_ or HAL_ prefix.
**Target_addon:** `hal_tasking` for every declaration per D-06.
**Load status:** CURRENTLY NOT LOADED — commented out at `addons/core/functions/fnc_init.sqf:102` (`// call compile preprocessFile (RYD_Path + "TaskInitNR6.sqf")`). This is a **Phase 3 blocker**: SquadTaskingNR6.sqf dispatches these functions via `remoteExecCall` string names (see map-squadtasking.md), so they must be loaded before SquadTaskingNR6 runs, or dispatch produces nil-function errors.

---

### Declaration Groups (grouped by task slot)

| slot | line_range | declarations | purpose | target_addon |
|------|------------|--------------|---------|--------------|
| Slot 1 (Move) | 3–49 | `Action1ct`, `Action1fnc`, `ACEAction1fnc`, `Action1fncR`, `ACEAction1fncR` | Move order task — reset waypoints, cancel tasks, set group variables | hal_tasking |
| Slot 2 (Attack) | 50–89 | `Action2ct`, `Action2fnc`, `ACEAction2fnc`, `Action2fncR`, `ACEAction2fncR` | Attack order task | hal_tasking |
| Slot 3 (Defend) | 90–130 | `Action3ct`, `Action3fnc`, `ACEAction3fnc`, `Action3fncR`, `ACEAction3fncR` | Defend order task | hal_tasking |
| Slot 4 | 197–308 | `Action4ct`, `Action4fnc`, `ACEAction4fnc`, `Action4fncR`, `ACEAction4fncR` | Task slot 4 | hal_tasking |
| Slot 5 | 309–422 | `Action5ct`, `Action5fnc`, `ACEAction5fnc`, `Action5fncR`, `ACEAction5fncR` | Task slot 5 | hal_tasking |
| Slot 6 | 423–536 | `Action6ct`, `Action6fnc`, `ACEAction6fnc`, `Action6fncR`, `ACEAction6fncR` | Task slot 6 | hal_tasking |
| Slot 7 | 537–687 | `Action7ct`, `Action7fnc`, `ACEAction7fnc`, `Action7fncR`, `ACEAction7fncR` | Task slot 7 | hal_tasking |
| Slot 8 | 688–785 | `Action8ct`, `Action8fnc`, `ACEAction8fnc`, `Action8fncR`, `ACEAction8fncR` | Task slot 8 | hal_tasking |
| Slot 9 | 786–876 | `Action9ct`, `Action9fnc`, `ACEAction9fnc`, `Action9fncR`, `ACEAction9fncR` | Task slot 9 | hal_tasking |
| Slot 10 | 877–967 | `Action10ct`, `Action10fnc`, `ACEAction10fnc`, `Action10fncR`, `ACEAction10fncR` | Task slot 10 | hal_tasking |
| Slot 11 | 968–1058 | `Action11ct`, `Action11fnc`, `ACEAction11fnc`, `Action11fncR`, `ACEAction11fncR` | Task slot 11 | hal_tasking |
| Slot 12 | 1059–1150 | `Action12ct`, `Action12fnc`, `ACEAction12fnc`, `Action12fncR`, `ACEAction12fncR` | Task slot 12 | hal_tasking |
| Slot 13 | 1151–1244 | `Action13ct`, `Action13fnc`, `ACEAction13fnc`, `Action13fncR`, `ACEAction13fncR` | Task slot 13 | hal_tasking |
| Master menu | 1245–1299 | `ActionMfnc`, `ACEActionMfnc`, `ActionMfncR`, `ACEActionMfncR` | Master task menu add/remove — **string-dispatched from SquadTaskingNR6.sqf:33,39,50,55** | hal_tasking |
| Ground transport | 1300–1392 | `ActionGTct` | Ground transport task condition | hal_tasking |
| Artillery | 1393–1582 | `ActionArtct` | Artillery support task condition | hal_tasking |
| Artillery 2 | 1583–end | `ActionArt2ct` | Artillery secondary task condition | hal_tasking |

---

### Full Declaration List

All 72 declarations from `raw-declarations.tsv` filtered to `nr6_hal/TaskInitNR6.sqf`. Grouped visually by task slot.

#### Slot 1 — Move order (lines 3–195)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action1ct` | 3 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check for slot 1 action menu entry |
| `Action1fnc` | 23 | active | hal_tasking | implicit `_this` (unit) | SquadTaskingNR6.sqf (remote_exec) | Move order handler; calls `RYD_AIChatter` |
| `ACEAction1fnc` | 33 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant of Action1fnc |
| `Action1fncR` | 131 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 1 action menu entry |
| `ACEAction1fncR` | 142 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 2 — Attack order (lines 50–89 + remove: 152–172)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action2ct` | 50 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check for slot 2 |
| `Action2fnc` | 58 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Attack order handler |
| `ACEAction2fnc` | 75 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action2fncR` | 152 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 2 action |
| `ACEAction2fncR` | 163 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 3 — Defend order (lines 90–130 + remove: 173–196)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action3ct` | 90 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check for slot 3 |
| `Action3fnc` | 98 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Defend order handler |
| `ACEAction3fnc` | 115 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action3fncR` | 173 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 3 action |
| `ACEAction3fncR` | 184 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 4 (lines 197–308)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action4ct` | 197 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check |
| `Action4fnc` | 250 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Task slot 4 handler; spawns `HAL_SCargo` via `RYD_Spawn` (line 568) |
| `ACEAction4fnc` | 267 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action4fncR` | 288 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 4 action |
| `ACEAction4fncR` | 299 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 5 (lines 309–422)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action5ct` | 309 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check |
| `Action5fnc` | 368 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Task slot 5 handler; spawns `HAL_SCargo` via `RYD_Spawn` (line 603) |
| `ACEAction5fnc` | 385 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action5fncR` | 402 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 5 action |
| `ACEAction5fncR` | 413 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 6 (lines 423–536)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action6ct` | 423 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check |
| `Action6fnc` | 481 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Task slot 6 handler; spawns `HAL_GoLaunch`/`RYD_Spawn` (line 474) |
| `ACEAction6fnc` | 498 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action6fncR` | 515 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 6 action |
| `ACEAction6fncR` | 526 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 7 (lines 537–687)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action7ct` | 537 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check |
| `Action7fnc` | 630 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Task slot 7 handler; spawns `HAL_GoAmmoSupp` via `RYD_Spawn` (line 721) |
| `ACEAction7fnc` | 647 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action7fncR` | 664 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 7 action |
| `ACEAction7fncR` | 675 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 8 (lines 688–785)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action8ct` | 688 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check |
| `Action8fnc` | 727 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Task slot 8 handler; spawns `HAL_GoAmmoSupp` via `RYD_Spawn` (line 816) |
| `ACEAction8fnc` | 744 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action8fncR` | 765 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 8 action |
| `ACEAction8fncR` | 776 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 9 (lines 786–876)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action9ct` | 786 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check |
| `Action9fnc` | 822 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Task slot 9 handler; spawns `HAL_GoFuelSupp` via `RYD_Spawn` (line 907) |
| `ACEAction9fnc` | 839 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action9fncR` | 856 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 9 action |
| `ACEAction9fncR` | 867 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 10 (lines 877–967)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action10ct` | 877 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check |
| `Action10fnc` | 913 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Task slot 10 handler; spawns `HAL_GoMedSupp` via `RYD_Spawn` (line 998) |
| `ACEAction10fnc` | 930 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action10fncR` | 947 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 10 action |
| `ACEAction10fncR` | 958 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 11 (lines 968–1058)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action11ct` | 968 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check |
| `Action11fnc` | 1004 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Task slot 11 handler; spawns `HAL_GoMedSupp` via `RYD_Spawn` (line 1089) |
| `ACEAction11fnc` | 1021 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action11fncR` | 1038 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 11 action |
| `ACEAction11fncR` | 1049 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 12 (lines 1059–1150)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action12ct` | 1059 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check |
| `Action12fnc` | 1095 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Task slot 12 handler; spawns `HAL_GoRepSupp` via `RYD_Spawn` (line 1181) |
| `ACEAction12fnc` | 1112 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action12fncR` | 1129 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 12 action |
| `ACEAction12fncR` | 1140 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Slot 13 (lines 1151–1244)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `Action13ct` | 1151 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Condition check |
| `Action13fnc` | 1187 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Task slot 13 handler; spawns `HAL_SCargo` via `RYD_Spawn` (lines 1331, 1366) |
| `ACEAction13fnc` | 1204 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant |
| `Action13fncR` | 1221 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Remove slot 13 action |
| `ACEAction13fncR` | 1232 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | ACE variant remove |

#### Master Menu (lines 1245–1299) — PRIMARY string-dispatch targets

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `ActionMfnc` | 1245 | active | hal_tasking | implicit `_this` (unit) | SquadTaskingNR6.sqf:33 (remoteExecCall string) | Adds full task action menu to unit; primary dispatch target |
| `ACEActionMfnc` | 1262 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf:39 (remoteExecCall string) | ACE variant add |
| `ActionMfncR` | 1279 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf:50 (remoteExecCall string) | Removes full task action menu from unit |
| `ACEActionMfncR` | 1290 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf:55 (remoteExecCall string) | ACE variant remove |

#### Specialty Conditions (lines 1300–end)

| symbol | line | status | target_addon | params | called_by | notes |
|--------|------|--------|-------------|--------|-----------|-------|
| `ActionGTct` | 1300 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Ground transport action condition; 92-line body (1300–1392) |
| `ActionArtct` | 1393 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Artillery support condition; 189-line body; calls `RYD_ArtyMission` (line 1593), spawns `RYD_CFF_FFE` (line 1597) |
| `ActionArt2ct` | 1583 | active | hal_tasking | implicit `_this` | SquadTaskingNR6.sqf (remote_exec) | Artillery secondary condition; remainder of file |

**Total: 72 declarations** (65 slot fn/ct/remove + 4 master menu + 3 specialty conditions)

---

### Dynamic Dispatch Note

**String dispatch pattern (raw-call-edges.tsv edge_type=remote_exec):** `SquadTaskingNR6.sqf` lines 33, 39, 50, 55 call `remoteExecCall ["ActionMfnc", _x]` / `"ACEActionMfnc"` / `"ActionMfncR"` / `"ACEActionMfncR"`. These are **string literals**, not symbol references — the regex extraction pass captures them but they cannot be resolved via normal static analysis. The `called_by` field for all `ActionMfnc` / `ACEActionMfnc` / `ActionMfncR` / `ACEActionMfncR` rows MUST list `SquadTaskingNR6.sqf:33,39,50,55 (remoteExecCall string)`.

Additionally, SquadTaskingNR6.sqf dispatches ALL 52 slot-level `Action*fnc` and `Action*fncR` functions via `remoteExecCall` (lines 73–497) — the full remote_exec edge list is in `raw-call-edges.tsv` rows 271–327.

---

### Phase 3 Blocker — Load Order

The Phase 3 executor MUST:

1. Register all 72 `Action*` / `ACEAction*` callbacks via `PREP(...)` in `addons/hal_tasking/XEH_PREP.hpp` BEFORE `SquadTaskingNR6.sqf` (or its migrated successor) runs.
2. Update the string dispatches in SquadTaskingNR6 to use `QFUNC()` / GVAR-qualified string references — e.g., `remoteExecCall ["ActionMfnc", _x]` becomes `remoteExecCall [QFUNC(actionMfnc), _x]` where `QFUNC(actionMfnc)` expands to `"hal_tasking_fnc_actionMfnc"`.
3. Uncomment and update the load site in `addons/core/functions/fnc_init.sqf:102` (or replace with XEH_PREP mechanism — recommended: remove the line entirely and let CBA preInit handle PREP compilation).

**Failure to do steps 1–3 atomically in Phase 3 reproduces the current bug:** dispatched functions resolve to nil and the action menu silently breaks. This is the current state — `TaskInitNR6.sqf` is commented out at `fnc_init.sqf:102` but `SquadTaskingNR6.sqf` is still executed at `fnc_init.sqf:210`. The action menu system is currently broken in the addon version.

**Internal call edges from TaskInitNR6.sqf (must survive migration):**

| caller_line | callee | edge_type | notes |
|-------------|--------|-----------|-------|
| 10 | `RYD_AIChatter` | call | migrated to addons/common — use `EFUNC(common,AIChatter)` |
| 243 | `RYD_GoLaunch` + `RYD_Spawn` | call | `RYD_GoLaunch` in HAC_fnc.sqf; `RYD_Spawn` migrated |
| 361 | `RYD_GoLaunch` + `RYD_Spawn` | call | same |
| 474 | `RYD_GoLaunch` + `RYD_Spawn` | call | same |
| 568 | `HAL_SCargo` | value_pass via `RYD_Spawn` | external HAL/*.sqf — out of scope |
| 603 | `HAL_SCargo` | value_pass via `RYD_Spawn` | external HAL/*.sqf |
| 721 | `HAL_GoAmmoSupp` | value_pass via `RYD_Spawn` | external HAL/*.sqf |
| 816 | `HAL_GoAmmoSupp` | value_pass via `RYD_Spawn` | external HAL/*.sqf |
| 907 | `HAL_GoFuelSupp` | value_pass via `RYD_Spawn` | external HAL/*.sqf |
| 998 | `HAL_GoMedSupp` | value_pass via `RYD_Spawn` | external HAL/*.sqf |
| 1089 | `HAL_GoMedSupp` | value_pass via `RYD_Spawn` | external HAL/*.sqf |
| 1181 | `HAL_GoRepSupp` | value_pass via `RYD_Spawn` | external HAL/*.sqf |
| 1331 | `HAL_SCargo` | value_pass via `RYD_Spawn` | external HAL/*.sqf |
| 1366 | `HAL_SCargo` | value_pass via `RYD_Spawn` | external HAL/*.sqf |
| 1593 | `RYD_ArtyMission` | call | migrated to addons/common |
| 1597 | `RYD_CFF_FFE` | spawn | migrated to addons/common |
