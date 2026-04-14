## SquadTaskingNR6.sqf

**File:** `nr6_hal/SquadTaskingNR6.sqf` (508 lines)
**Declarations:** ZERO — imperative `while {true} do` dispatch loop.
**Load status:** ACTIVE — loaded via `nul = [] execVM (RYD_Path + "SquadTaskingNR6.sqf")` at `addons/core/functions/fnc_init.sqf:210`.
**Target_addon:** `hal_tasking` (the entire file becomes a single migrated entry — a spawned/scheduled function in hal_tasking).
**Classification:** active (entry point from fnc_init.sqf line 210 inside `if (RydxHQ_Actions)` guard).

---

### Purpose

Imperative action-menu dispatch loop. Runs as a persistent `while {true} do` VM script. On each iteration:

1. Reads HQ state: builds `_HalFriends` by aggregating `RydHQ_Friends` from all 8 possible HQ group variables (`LeaderHQ` through `LeaderHQH`).
2. Iterates `allPlayers` via `forEach`.
3. For leaders of friendly groups who haven't received the action menu yet: dispatches `ActionMfnc` / `ACEActionMfnc` via `remoteExecCall` (master menu add).
4. For players who no longer qualify (demoted, left group, etc.): dispatches `ActionMfncR` / `ACEActionMfncR` via `remoteExecCall` (master menu remove).
5. In a deprecated block (`// BELOW IS DEPRECATED`): individually dispatches all 13 slot `Action*fnc` / `Action*fncR` functions via `remoteExecCall`.
6. Sleeps 15 seconds between iterations.

The string names in `remoteExecCall` resolve to TaskInitNR6.sqf declarations at runtime — see map-taskinit.md for target functions.

---

### External Edges — Master Menu Dispatch (lines 26–60)

These 4 are the **primary dispatch sites** referenced in the plan and research. They fire on every player on every iteration and are the live action-menu mechanism:

| edge | edge_type | source_line | target_function | target_file | dispatch_note |
|------|-----------|-------------|-----------------|-------------|---------------|
| SquadTaskingNR6.sqf:33 | remoteExecCall | 33 | `"ActionMfnc"` | TaskInitNR6.sqf:1245 | String literal — not resolvable by symbol regex |
| SquadTaskingNR6.sqf:39 | remoteExecCall | 39 | `"ACEActionMfnc"` | TaskInitNR6.sqf:1262 | ACE variant, guarded by `isClass ace_main` check |
| SquadTaskingNR6.sqf:50 | remoteExecCall | 50 | `"ActionMfncR"` | TaskInitNR6.sqf:1279 | Remove variant — fires when player loses leader status |
| SquadTaskingNR6.sqf:55 | remoteExecCall | 55 | `"ACEActionMfncR"` | TaskInitNR6.sqf:1290 | ACE remove variant |

---

### External Edges — Deprecated Slot Dispatch (lines 66–503)

The block starting at line 62 (`// BELOW IS DEPRECATED`) individually dispatches all 13 task slot functions via `remoteExecCall`. These are captured in `raw-call-edges.tsv` rows 275–327:

| source_line | target_function | target_file |
|-------------|-----------------|-------------|
| 73 | `"Action1fnc"` | TaskInitNR6.sqf:23 |
| 78 | `"ACEAction1fnc"` | TaskInitNR6.sqf:33 |
| 88 | `"Action2fnc"` | TaskInitNR6.sqf:58 |
| 94 | `"ACEAction2fnc"` | TaskInitNR6.sqf:75 |
| 105 | `"Action3fnc"` | TaskInitNR6.sqf:98 |
| 111 | `"ACEAction3fnc"` | TaskInitNR6.sqf:115 |
| 122 | `"Action1fncR"` | TaskInitNR6.sqf:131 |
| 127 | `"ACEAction1fncR"` | TaskInitNR6.sqf:142 |
| 138 | `"Action2fncR"` | TaskInitNR6.sqf:152 |
| 143 | `"ACEAction2fncR"` | TaskInitNR6.sqf:163 |
| 154 | `"Action3fncR"` | TaskInitNR6.sqf:173 |
| 159 | `"ACEAction3fncR"` | TaskInitNR6.sqf:184 |
| 176 | `"Action4fnc"` | TaskInitNR6.sqf:250 |
| 182 | `"ACEAction4fnc"` | TaskInitNR6.sqf:267 |
| 193 | `"Action4fncR"` | TaskInitNR6.sqf:288 |
| 198 | `"ACEAction4fncR"` | TaskInitNR6.sqf:299 |
| 209 | `"Action5fnc"` | TaskInitNR6.sqf:368 |
| 215 | `"ACEAction5fnc"` | TaskInitNR6.sqf:385 |
| 226 | `"Action5fncR"` | TaskInitNR6.sqf:402 |
| 231 | `"ACEAction5fncR"` | TaskInitNR6.sqf:413 |
| 242 | `"Action6fnc"` | TaskInitNR6.sqf:481 |
| 248 | `"ACEAction6fnc"` | TaskInitNR6.sqf:498 |
| 259 | `"Action6fncR"` | TaskInitNR6.sqf:515 |
| 264 | `"ACEAction6fncR"` | TaskInitNR6.sqf:526 |
| 275 | `"Action7fnc"` | TaskInitNR6.sqf:630 |
| 281 | `"ACEAction7fnc"` | TaskInitNR6.sqf:647 |
| 292 | `"Action7fncR"` | TaskInitNR6.sqf:664 |
| 297 | `"ACEAction7fncR"` | TaskInitNR6.sqf:675 |
| 310 | `"Action8fnc"` | TaskInitNR6.sqf:727 |
| 316 | `"ACEAction8fnc"` | TaskInitNR6.sqf:744 |
| 327 | `"Action8fncR"` | TaskInitNR6.sqf:765 |
| 332 | `"ACEAction8fncR"` | TaskInitNR6.sqf:776 |
| 343 | `"Action9fnc"` | TaskInitNR6.sqf:822 |
| 349 | `"ACEAction9fnc"` | TaskInitNR6.sqf:839 |
| 360 | `"Action9fncR"` | TaskInitNR6.sqf:856 |
| 365 | `"ACEAction9fncR"` | TaskInitNR6.sqf:867 |
| 376 | `"Action10fnc"` | TaskInitNR6.sqf:913 |
| 382 | `"ACEAction10fnc"` | TaskInitNR6.sqf:930 |
| 393 | `"Action10fncR"` | TaskInitNR6.sqf:947 |
| 398 | `"ACEAction10fncR"` | TaskInitNR6.sqf:958 |
| 409 | `"Action11fnc"` | TaskInitNR6.sqf:1004 |
| 415 | `"ACEAction11fnc"` | TaskInitNR6.sqf:1021 |
| 426 | `"Action11fncR"` | TaskInitNR6.sqf:1038 |
| 431 | `"ACEAction11fncR"` | TaskInitNR6.sqf:1049 |
| 442 | `"Action12fnc"` | TaskInitNR6.sqf:1095 |
| 448 | `"ACEAction12fnc"` | TaskInitNR6.sqf:1112 |
| 459 | `"Action12fncR"` | TaskInitNR6.sqf:1129 |
| 464 | `"ACEAction12fncR"` | TaskInitNR6.sqf:1140 |
| 475 | `"Action13fnc"` | TaskInitNR6.sqf:1187 |
| 481 | `"ACEAction13fnc"` | TaskInitNR6.sqf:1204 |
| 492 | `"Action13fncR"` | TaskInitNR6.sqf:1221 |
| 497 | `"ACEAction13fncR"` | TaskInitNR6.sqf:1232 |

**Total remoteExecCall dispatch sites: 56** (4 master menu + 52 slot-level). All 56 are string-dispatch edges invisible to symbol-based static analysis.

---

### State Reads

Variables read from the game state inside the dispatch loop:

| variable | access_pattern | purpose |
|----------|---------------|---------|
| `RydHQ_Friends` | `group LeaderHQ getVariable ["RydHQ_Friends",[]]` | List of friendly groups under each HQ; aggregated across all 8 HQ slots |
| `RydxHQ_ActionsMenu` | direct boolean check | Gate: only dispatch action menus if this is true |
| `RydxHQ_ActionsAceOnly` | direct boolean check | Gate: skip non-ACE action dispatch if true |
| `RydxHQ_TaskActions` | direct boolean check | Gate: enable deprecated per-slot task actions |
| `HAL_TaskMenuAdded` | `_x getVariable ["HAL_TaskMenuAdded", false]` | Per-player flag: has master menu been added |
| `HAL_PlayerUnit` | `_x getVariable ["HAL_PlayerUnit", objNull]` | Per-player: unit reference for change detection |
| `HAL_Task1Added`..`HAL_Task13Added` | `_x getVariable ["HAL_Task1Added", false]` | Per-player per-slot: has slot N action been added |
| `EnableHALActions` | `group _x getVariable ["EnableHALActions",false]` | Group-level override: enable HAL actions regardless of HQ membership |
| `LeaderHQ`..`LeaderHQH` | direct nil-checked globals | 8 possible HQ leader object references |

---

### Phase 3 Migration Notes

1. **Target file:** `addons/hal_tasking/functions/fnc_squadTasking.sqf` — the entire imperative loop migrates as a single spawned function.
2. **Entry point update:** `fnc_init.sqf:210` `execVM` call must become `[] spawn EFUNC(hal_tasking,squadTasking)` (or equivalent CBA scheduled call).
3. **String dispatch migration:** All 56 `remoteExecCall "ActionXfnc"` calls must be updated to use migrated function names. Two options:
   - Keep `remoteExecCall` but update strings to `"hal_tasking_fnc_actionXfnc"` format
   - Switch to CBA event mechanism (`CBA_fnc_globalEvent` or `addAction` at player's locality)
4. **Load-order dependency:** All 72 TaskInitNR6 migrated functions MUST be PREP'd and compiled before `fnc_squadTasking` spawns — see map-taskinit.md Phase 3 Blocker section.
5. **Loop pattern decision:** The `while {true} do ... sleep 15` pattern needs Phase 3 decision: keep as spawned background loop (simpler migration) vs. convert to CBA per-frame handler or `CBA_fnc_addPerFrameHandler` (cleaner but larger change). Either is valid — document the choice in Phase 3 plan.
6. **RydxHQ_Actions guard:** The `if (RydxHQ_Actions)` guard at `fnc_init.sqf:209` that wraps the `execVM` call must be preserved in the migration so the feature can still be disabled at runtime.

---

### Notes

- The `// BELOW IS DEPRECATED` comment at line 62 indicates the per-slot dispatch block was intended for removal when the master-menu approach (`ActionMfnc`) was introduced. Phase 3 should evaluate whether to carry the deprecated block forward or remove it — if the master menu (`ActionMfnc`) correctly registers all slot actions, the deprecated block is redundant.
- The `while {true} do` pattern with `sleep 15` at line 507 means action menus are refreshed every 15 seconds — this creates a 15-second lag window where a newly promoted leader may not receive their action menu. Phase 3 should document this as a known latency.
- The file ends at line 508 (`};`) — the outer while-loop closing brace. There is no cleanup or exit condition other than script termination (mission end).
