# Architecture

**Analysis Date:** 2026-04-09

## Pattern Overview

**Overall:** Arma 3 mod system using CBA Extended Event Handlers (XEH) with modular addon structure for AI command and control system.

**Key Characteristics:**
- Modular addon-based architecture following Arma 3 conventions
- Mission logic driven by Named Groups and setVariable-based state management
- Pre-initialization compilation via CBA macros for function caching
- Extended Event Handler pattern for mission/server startup hooks
- Namespace-based configuration distribution (missionNamespace publicVariable)

## Layers

**Configuration & Initialization Layer:**
- Purpose: Define module behavior, configure dependencies, load initial settings
- Location: `addons/main/`, `addons/core/`, `addons/missionmodules/`, `addons/common/`
- Contains: `config.cpp`, `script_*.hpp` files, XEH event handlers
- Depends on: CBA framework, Arma 3 base classes
- Used by: Mission system, module editor placement

**Core HAL Logic Layer:**
- Purpose: Initialize and manage AI HQ group with personality, state variables, and core scanning loops
- Location: `addons/core/functions/`
- Contains: `fnc_init.sqf` (HQ initialization), `fnc_EnemyScan.sqf` (threat scanning), `fnc_HQSitRep.sqf` (situation reporting), `fnc_personality.sqf` (commander personality)
- Depends on: Common utility functions, namespace variables
- Used by: Mission modules, group AI systems

**Common Utilities Layer:**
- Purpose: Provide reusable functions for pathfinding, group management, math, and tactical operations
- Location: `addons/common/functions/`
- Contains: 69 utility functions including spawn handlers, wait loops, formation logic, artillery functions, marker systems
- Depends on: Arma 3 scripting API
- Used by: Core layer, mission modules, group behavior systems

**Mission Module Interface Layer:**
- Purpose: Expose configurable mission objectives and group settings via in-editor modules with UI parameters
- Location: `addons/missionmodules/functions/`, `addons/missionmodules/CfgVehicles.hpp`
- Contains: 45+ module functions for objectives, leader settings, support actions, exclusions
- Depends on: Core logic and common utilities
- Used by: Mission designers via editor

**UI/Configuration Layer:**
- Purpose: Present in-mission configuration dialogs and radio communication system
- Location: `addons/main/ui/`
- Contains: UI dialog definitions, communication system resources
- Depends on: Arma 3 UI framework
- Used by: Players and mission system

## Data Flow

**Mission Initialization Flow:**

1. CBA preInit stage → `addons/core/XEH_preInit.sqf` sets `ADDON = false`, compiles function cache via `XEH_PREP.hpp`
2. Mission start → Editor-placed modules trigger their defined functions (`function = QEFUNC(core,init)` etc.)
3. HAL Core module (`fnc_generalSettings.sqf` → `fnc_init.sqf`) initializes HQ group with personality settings
4. Configuration variables broadcast to all clients via `publicVariable` statements in `fnc_init.sqf`
5. CBA postInit stage → `addons/core/XEH_postInit.sqf` sets `ADDON = true`

**Group Behavior Loop Flow:**

1. HQ stores group references in arrays: `RydHQ_Friends`, `RydHQ_KnEnemiesG`, `RydHQ_AirG`, etc.
2. Groups spawned via `fnc_spawn.sqf` which maintains `RydxHQ_Handles` array of running scripts
3. Main loops (e.g., `fnc_EnemyScan.sqf`) execute periodically, scanning group state variables:
   - `RydHQ_Init` - whether initialization complete
   - `RydHQ_KnownEnemies` - detected enemy positions
   - `RydHQ_Front` - front line location
   - Group-specific: `Busy`, `Break`, `MIA`, `WaitingTarget`, `WaitingObjective`
4. Group wait logic (`fnc_wait.sqf`) checks multiple conditions simultaneously before proceeding
5. Actions update waypoints, unit assignments, and vehicle behaviors based on wait results

**State Management Flow:**

1. Configuration state: Stored in missionNamespace as `Rydx*` and `Ryd*` variables (broadcast via `publicVariable`)
2. HQ state: Stored in HQ object via `setVariable/getVariable` with prefixes like `RydHQ_*`
3. Group state: Stored in group object with prefixes like `RydHQ_*` for HQ-related, or `Busy`, `Break` for transient
4. Unit state: Stored on individual unit objects as needed

## Key Abstractions

**HAL Commander (HQ Group Object):**
- Purpose: Central agent representing AI commander with personality traits and decision-making capability
- Examples: `addons/core/functions/fnc_init.sqf`, `fnc_personality.sqf`, `fnc_HQSitRep.sqf`
- Pattern: A single group object that never engages, only commands. Stores all strategic state via setVariable. Personality traits (Recklessness, Consistency, Activity, Reflex, Circumspection, Fineness) influence tactical decisions.

**Managed Group (Child Group of HQ):**
- Purpose: Infantry/vehicle squad under HQ command with assigned waypoints and objectives
- Examples: Groups added via mission modules, managed by `fnc_init.sqf` and related functions
- Pattern: Each group has setVariable entries for wait conditions, objective targets, cargo status, and transient flags. Spawned loops monitor and execute group-level wait logic via `fnc_wait.sqf`.

**Module System (Cached Function Interface):**
- Purpose: Provide mission designers direct control over HQ behavior via editor-placed objects
- Examples: `fnc_generalSettings.sqf`, `fnc_leaderBehaviourSettings.sqf`, `fnc_objective.sqf`
- Pattern: Each module's function reads its parameters, updates HQ setVariable entries, then either spawns background loops or returns immediately. CBA PREP macro ensures functions compile once per mission.

**Wait/Condition Loop Pattern:**
- Purpose: Synchronize group progression with multiple conditions (enemy presence, waypoint completion, cargo loading, etc.)
- Examples: `fnc_wait.sqf` (main framework), variants in group behavior scripts
- Pattern: `waitUntil` loop checks multiple conditions per interval. Returns array of results. Supports complex checks like "units inside/outside vehicles", "ammo checks", "speed monitoring", "waypoint completion".

## Entry Points

**Mission Module Core:**
- Location: `addons/missionmodules/functions/fnc_include.sqf` (sync target) and `addons/core/functions/fnc_init.sqf`
- Triggers: Placement of HAL Core module in mission editor → activation (manual or via trigger sync)
- Responsibilities: Initialize HQ group, set default variables, spawn main event loops, broadcast configuration to all clients

**Mission Module - General Settings:**
- Location: `addons/missionmodules/functions/fnc_generalSettings.sqf`
- Triggers: Placement of HAL General Settings module in editor
- Responsibilities: Configure gameplay options like cargo recon, synchronous attacks, chat density, garrison mode, magic repair/heal/rearm/refuel, pathfinding type

**Group Event Handlers:**
- Location: `addons/core/CfgEventHandlers.hpp` → preInit/postInit
- Triggers: Mission start
- Responsibilities: Compile function cache, set global addon state flag

## Error Handling

**Strategy:** Minimal error handling. Functions assume valid input (group/unit objects, numeric arrays, etc.). Failures cascade into group state variables (MIA flag, Busy flag) which cause groups to exit main loops.

**Patterns:**
- Null check before accessing group/unit: `if (isNull _HQ) exitWith {};`
- Safety variables checked before operations: `if (isNil "RydHQ_Excluded") then {RydHQ_Excluded = []}`
- Break flags in wait loops: `if (_group getVariable ["Break", false]) then {_alive = false}`
- MIA detection in wait loops: `if (_group getVariable ["RydHQ_MIA", false]) then {_alive = false; _group setVariable ["RydHQ_MIA", nil]}`
- Handle cleanup for spawned scripts: `RydxHQ_Handles` array managed in `fnc_spawn.sqf` to track and remove completed script handles

## Cross-Cutting Concerns

**Logging:** Uses CBA LOG macros (LOG_8, etc.) that expand to debugLog in debug mode. Examples in `fnc_personality.sqf`, `fnc_EnemyScan.sqf`.

**Validation:** Mission namespace variables validate with `isNil` checks before use. Defaults provided (e.g., `missionNamespace getVariable ["RydxHQ_AIChatDensity", 100]`).

**Communication:** AI chatter via `fnc_AIChatter.sqf` and `fnc_HQChatter.sqf` for radio messages. Density controlled by `RydxHQ_AIChatDensity` mission variable (percentage).

**Networking:** publicVariable statements in `fnc_init.sqf` ensure mission variables replicate to all clients. Group/unit setVariable calls use local scope by default.

**Performance:** Handles array managed in `fnc_spawn.sqf` culls dead/completed scripts. Wait loops use configurable intervals. Common functions (65+) pre-compiled via CBA PREP macro to avoid recompilation.

---

*Architecture analysis: 2026-04-09*
