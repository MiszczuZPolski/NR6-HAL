<!-- GSD:project-start source:PROJECT.md -->
## Project

**NR6-HAL Refactor**

NR6-HAL is an Arma 3 AI command and control mod that provides an autonomous AI commander (HAL) capable of managing infantry, vehicles, artillery, and reinforcements. V1 refactors the core `nr6_hal` module to match ACE3 community standards — full CBA integration, HEMTT-clean builds, and modern Arma 3 mod structure — without breaking existing functionality.

**Core Value:** Existing HAL AI behavior must continue working identically after refactoring. Structure changes, not behavior changes.

### Constraints

- **Backward compatibility**: Old classnames must remain accessible via compatibility addon — existing missions must not break
- **No behavior changes**: AI logic must produce identical results after refactoring
- **ACE3 standard**: Follow ACE3 coding guidelines for file structure, naming, macros, config.cpp patterns
- **HEMTT build**: Project must build cleanly with HEMTT — zero errors, zero warnings
- **CBA dependency**: Must maintain CBA 3.16.0+ as core dependency
<!-- GSD:project-end -->

<!-- GSD:stack-start source:codebase/STACK.md -->
## Technology Stack

## Languages
- SQF (SQF Script Format) - Arma 3 scripting language used for all game logic and AI behavior
- SQC - Binarized SQF format for optimized performance (mentioned in README as future implementation)
- C++ - Configuration and class definitions in `.cpp` files (Arma 3 config syntax)
## Runtime
- Arma 3 Engine (required version 2.14+) - Military combat simulation platform
- Bohemia Interactive Arma 3 - DirectX/custom rendering engine
## Frameworks
- Community Base Addons (CBA) - Version 3.16.0 (required dependency)
- Arma 3 Modules Framework (`A3_Modules_F`) - Required for mission module integration
- HEMTT (Build Tool) - Arma 3 PBO compilation and project management
## Key Dependencies
- CBA (Community Base Addons) Version 3.16.0 - Core library functions, macro compilation, event handler system
- ACE3 - Medical engine macros available in `include/z/ace/` but not actively required
## Configuration
- HEMTT project configuration-based
- No external environment variables (.env) required
- Configuration defined in: `.hemtt/project.toml`
- HEMTT processes config files:
- Script macros defined in: `addons/main/script_macros.hpp`
- Version macros in: `addons/main/script_version.hpp` (MAJOR=1, MINOR=0, PATCH=0, BUILD=0)
- Component-level settings in: `addons/*/script_component.hpp` files
- Debug flags support optional compilation: `DEBUG_MODE_FULL`, `DISABLE_COMPILE_CACHE`, `ENABLE_PERFORMANCE_COUNTERS`
## Platform Requirements
- Arma 3 (base game installation required)
- HEMTT build tool
- Text editor with SQF/C++ syntax support
- Optional: PBO Manager (pboman3) for manual PBO creation/decompilation
- Arma 3 Tools (binarization of SQF to SQFC format)
- Git for version control
- Target: Arma 3 Steam Workshop or local mod directory
- Installation: PBO addons in `addons/` directory as compiled `.pbo` files
- Runtime dependency: CBA_A3 mod (Steam workshop ID 450814997) must be loaded before HAL
## Module Structure
- `addons/main/` - Core module with version, macros, and shared utilities
- `addons/core/` - Core initialization and CBA integration
- `addons/common/` - Common functions library (50+ mission/AI functions)
- `addons/missionmodules/` - Arma 3 mission module definitions and UI
- `nr6_hal/` - Main HAL AI and task management engine (Boss, HAC_fnc, TaskInit, Squad Tasking)
- `nr6_reinforcements/` - Air and logistic reinforcement system
- `nr6_airreinforcements/` - Air reinforcement dispatcher (variants A/B/C)
- `nr6_alice2/` - Enhanced asset intelligence system
- `nr6_sites/` - Defensive site management and garrison tactics
- `nr6_sitemarkers/` - Site marker visualization
- `nr6_tools/` - Development and compilation utilities
## Asset Formats
- PAA (Arma 3 texture format) - Icon and logo files
- Sound files - Audio for radio chatter and notifications (in `nr6_hal/Sound/`)
- SQF files (.sqf) - Human-readable scripts
- HPP files (.hpp) - Header includes and macro definitions
- CPP files (.cpp) - Configuration class definitions
- SQFC files (.sqfc) - Binarized compiled SQF (post-build)
- PBO files (.pbo) - Packed addon containers (compiled output)
## Compilation & Optimization
- Scripts compiled from SQF source files at runtime via `compile preprocessFileLineNumbers`
- Function caching enabled via `CBA_fnc_compileFunction` unless `DISABLE_COMPILE_CACHE` is set
- Optional binarization to SQFC (compiled binary format) for improved load time and performance
- Requires: Arma 3 Script Compiler (part of Arma 3 Tools)
- Build process controlled by HEMTT: compiles SQF → SQFC automatically when configured
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

## Language & Context
## File Organization & Naming
- SQF scripts: snake_case with `fnc_` prefix for functions
- Example: `fnc_addTask.sqf`, `fnc_AIChatter.sqf`, `fnc_angleTowards.sqf`
- Location: `addons/{component}/functions/fnc_{functionName}.sqf`
- Header files: `script_component.hpp`, `script_mod.hpp`, `script_macros.hpp`
- Config files: `config.cpp`, `CfgEventHandlers.hpp`
- Initialization: `XEH_preInit.sqf`, `XEH_postInit.sqf`
- addon-based structure: `addons/{component_name}/`
- Each addon contains: `functions/`, `config.cpp`, `script_component.hpp`, `CfgEventHandlers.hpp`, `XEH_*.sqf`
- Key addons: `addons/main` (core macros), `addons/common` (shared functions), `addons/core`, `addons/missionmodules`
## Naming Patterns
- Private variables: prefix with underscore `_variableName`
- Mission namespace variables: `RydxHQ_`, `RydHQ_`, `HAL_`, `HAC_` prefixes
- Examples: `_unit`, `_group`, `_position`, `_enemyGroups`, `_maxDistance`, `_closestEnemyGroup`, `_checkedVehicles`
- Camel case for compound names: `_unitGroup`, `_lastCommunication`, `_minimumDistance`
- Prefixed: `RydHQ_Front`, `RydxHQ_AllHQ`, `HAC_LastComm`, `RydHQ_BatteryBusy`
- Global function naming: `ADDON_fnc_functionName` (compiled via macros)
- Internal references use `FUNC()` macro: `call FUNC(functionName)`
- Function names describe action: `addTask`, `closeEnemy`, `findBiggest`, `clusterC`, `createDecoy`
- Group types: `grpNull`, `groupId()`
- Object checks: `isNull`, `isNil`
- Variables stored on objects: `getVariable`, `setVariable`
- Mission namespace: `missionNamespace getVariable [...]`, `missionNamespace setVariable [...]`
## Code Style
- Indentation: 4 spaces (from `.editorconfig`)
- Line endings: LF
- Character encoding: UTF-8
- Trim trailing whitespace
- Insert final newline
#include "..\script_component.hpp"
- `params` statement at top of script
- Use `private` for all local variables
- Optional parameters use array syntax: `["_paramName", defaultValue]`
- Implicit return (value at end of script)
- Single-line comments: `//`
- Block comments: `/** ... */` for JSDoc-style documentation
## Control Flow
- Use `if...then` blocks: `if (condition) then { code }`
- Exit early with `exitWith`: `if (badCondition) exitWith { return value }`
- Switch statements: `switch (expression) do { case value: {...}; default: {...}; }`
- Negation: `if !(condition)` or `if not (condition)` (both used)
- Equality: `isEqualTo` for comparisons, `isNotEqualTo` for inequality
## Loops & Iteration
- Standard iteration: `{ code with _x, _forEachIndex } forEach _array`
- Access to automatic index: `_forEachIndex` (0-based)
- Current element: `_x`
- Early exit: `exitWith` within loop
## Functions & Parameters
- All parameters extracted via `params` statement
- Optional parameters with default values
- Type hints in JSDoc comments
- Implicit return: place return value at end of script
- Can be any type: boolean, number, array, object, string
- No explicit `return` statement needed
## Documentation
- Three-line comment blocks with `@description`, `@param`, `@return`
- Type annotations in curly braces: `{Type}`
- Optional params noted: `[Optional]`
- Most addon functions have documentation (172+ comment lines in common addon alone)
- Comments explain non-obvious logic
- Original function credits included: `// Originally from HAC_fnc.sqf (RYD_FunctionName)`
## Macro System (CBA-based)
- `FUNC(name)` - Generate function namespace: expands to `ADDON_fnc_name`
- `QFUNC(name)` - Quoted function name
- `DFUNC(name)` - Direct function reference
- `GETVAR(obj, var, default)` - Get variable with default
- `SETVAR(obj, var, value)` - Set variable
- `GETMVAR(var, default)` - Mission namespace get
- `SETMVAR(var, value)` - Mission namespace set
- `GVAR(name)` - Global variable reference
#include "..\script_component.hpp"
## Error Handling
- Check array/count before access: `if (count _array > 0) then { _array select 0 }`
- Null checks: `if !(isNull _object)`, `if (isNil "_variable")`
- Safe element selection with index validation
- Use `max` operator for safe minimum: `(_currentAmmo / (_maxAmmo max 1))`
## Performance & Async
- Used for throttling/timing: `sleep 1;`, `sleep 27.5;`, `sleep 0.1;`
- Used with conditions: `if (condition) then {sleep 2};`
- Used in loops with delays: `for "_i" from 1 to count do { ... sleep 0.1; };`
## Array Operations
- `pushBack` - Add to end
- `pushBackUnique` - Add if not exists
- `select` - Index access
- `count` - Get length
- `in` - Membership test
- `forEach` - Iteration
## Configuration & Includes
#include "..\script_component.hpp"  // Relative include to component
#include "\z\hal\addons\main\..."   // Absolute path from mod root
#define COMPONENT common             // Define component name
#define COMPONENT_BEAUTIFIED "..."   // Display name
#ifdef DEBUG_ENABLED_HAL             // Conditional compilation
#endif
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

## Pattern Overview
- Modular addon-based architecture following Arma 3 conventions
- Mission logic driven by Named Groups and setVariable-based state management
- Pre-initialization compilation via CBA macros for function caching
- Extended Event Handler pattern for mission/server startup hooks
- Namespace-based configuration distribution (missionNamespace publicVariable)
## Layers
- Purpose: Define module behavior, configure dependencies, load initial settings
- Location: `addons/main/`, `addons/core/`, `addons/missionmodules/`, `addons/common/`
- Contains: `config.cpp`, `script_*.hpp` files, XEH event handlers
- Depends on: CBA framework, Arma 3 base classes
- Used by: Mission system, module editor placement
- Purpose: Initialize and manage AI HQ group with personality, state variables, and core scanning loops
- Location: `addons/core/functions/`
- Contains: `fnc_init.sqf` (HQ initialization), `fnc_EnemyScan.sqf` (threat scanning), `fnc_HQSitRep.sqf` (situation reporting), `fnc_personality.sqf` (commander personality)
- Depends on: Common utility functions, namespace variables
- Used by: Mission modules, group AI systems
- Purpose: Provide reusable functions for pathfinding, group management, math, and tactical operations
- Location: `addons/common/functions/`
- Contains: 69 utility functions including spawn handlers, wait loops, formation logic, artillery functions, marker systems
- Depends on: Arma 3 scripting API
- Used by: Core layer, mission modules, group behavior systems
- Purpose: Expose configurable mission objectives and group settings via in-editor modules with UI parameters
- Location: `addons/missionmodules/functions/`, `addons/missionmodules/CfgVehicles.hpp`
- Contains: 45+ module functions for objectives, leader settings, support actions, exclusions
- Depends on: Core logic and common utilities
- Used by: Mission designers via editor
- Purpose: Present in-mission configuration dialogs and radio communication system
- Location: `addons/main/ui/`
- Contains: UI dialog definitions, communication system resources
- Depends on: Arma 3 UI framework
- Used by: Players and mission system
## Data Flow
## Key Abstractions
- Purpose: Central agent representing AI commander with personality traits and decision-making capability
- Examples: `addons/core/functions/fnc_init.sqf`, `fnc_personality.sqf`, `fnc_HQSitRep.sqf`
- Pattern: A single group object that never engages, only commands. Stores all strategic state via setVariable. Personality traits (Recklessness, Consistency, Activity, Reflex, Circumspection, Fineness) influence tactical decisions.
- Purpose: Infantry/vehicle squad under HQ command with assigned waypoints and objectives
- Examples: Groups added via mission modules, managed by `fnc_init.sqf` and related functions
- Pattern: Each group has setVariable entries for wait conditions, objective targets, cargo status, and transient flags. Spawned loops monitor and execute group-level wait logic via `fnc_wait.sqf`.
- Purpose: Provide mission designers direct control over HQ behavior via editor-placed objects
- Examples: `fnc_generalSettings.sqf`, `fnc_leaderBehaviourSettings.sqf`, `fnc_objective.sqf`
- Pattern: Each module's function reads its parameters, updates HQ setVariable entries, then either spawns background loops or returns immediately. CBA PREP macro ensures functions compile once per mission.
- Purpose: Synchronize group progression with multiple conditions (enemy presence, waypoint completion, cargo loading, etc.)
- Examples: `fnc_wait.sqf` (main framework), variants in group behavior scripts
- Pattern: `waitUntil` loop checks multiple conditions per interval. Returns array of results. Supports complex checks like "units inside/outside vehicles", "ammo checks", "speed monitoring", "waypoint completion".
## Entry Points
- Location: `addons/missionmodules/functions/fnc_include.sqf` (sync target) and `addons/core/functions/fnc_init.sqf`
- Triggers: Placement of HAL Core module in mission editor → activation (manual or via trigger sync)
- Responsibilities: Initialize HQ group, set default variables, spawn main event loops, broadcast configuration to all clients
- Location: `addons/missionmodules/functions/fnc_generalSettings.sqf`
- Triggers: Placement of HAL General Settings module in editor
- Responsibilities: Configure gameplay options like cargo recon, synchronous attacks, chat density, garrison mode, magic repair/heal/rearm/refuel, pathfinding type
- Location: `addons/core/CfgEventHandlers.hpp` → preInit/postInit
- Triggers: Mission start
- Responsibilities: Compile function cache, set global addon state flag
## Error Handling
- Null check before accessing group/unit: `if (isNull _HQ) exitWith {};`
- Safety variables checked before operations: `if (isNil "RydHQ_Excluded") then {RydHQ_Excluded = []}`
- Break flags in wait loops: `if (_group getVariable ["Break", false]) then {_alive = false}`
- MIA detection in wait loops: `if (_group getVariable ["RydHQ_MIA", false]) then {_alive = false; _group setVariable ["RydHQ_MIA", nil]}`
- Handle cleanup for spawned scripts: `RydxHQ_Handles` array managed in `fnc_spawn.sqf` to track and remove completed script handles
## Cross-Cutting Concerns
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, or `.github/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->

## Build Environment Notes

### BBW1 — Arma 3 Tools Not Installed (Accepted Environment Notice)

HEMTT emits `BBW1` when the Arma 3 Tools suite (binarization toolchain) is absent from the build environment. This is an **environment capability notice, not a code defect**.

**Policy:** BBW1 is accepted as a known environment condition on machines without Arma 3 Tools installed. It does not indicate a build failure, missing source file, or incorrect configuration. The zero-warnings build gate defined in BUILD-02 explicitly excludes BBW1 from its warning count — only `L-S*` and `L-C*` lint codes constitute real warnings.

**If binarization is needed:** Install Arma 3 Tools via Steam (free, part of Arma 3 Tools app). HEMTT will then silently skip the BBW1 notice and produce `.sqfc` binarized output.

**Resolution tracking:** BBW1 closed as accepted environment notice in Phase 1 plan 01-05 (2026-04-10).
