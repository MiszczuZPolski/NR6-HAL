# External Integrations

**Analysis Date:** 2026-04-09

## APIs & External Services

**Arma 3 Game Engine:**
- Arma 3 Engine - Primary runtime environment
  - Provides: Game world simulation, unit scripting, event handlers, mission system
  - Integration: Direct API calls via SQF engine commands (e.g., `spawn`, `execVM`, `remoteExec`, `callExtension`)

**Steam Workshop:**
- Steam Workshop - Content distribution platform
  - Purpose: Mod publishing and dependency management
  - CBA Dependency: Workshop ID `450814997` (Community Base Addons)
  - Project Configuration: `.hemtt/launch.toml`

## Data Storage

**Game World Data:**
- Arma 3 in-game entity storage (units, groups, waypoints)
  - Storage: Mission variables stored on unit objects via `setVariable`/`getVariable`
  - No external database - all state persisted in game session
  - Example usage in codebase: `_vehicle getVariable ["RydHQ_ShotsToFire", 1]` in `addons/common/functions/fnc_cff_fire.sqf`

**Persistent Storage:**
- File system: Mission .pbo archives containing mission briefing, scripts, media
  - No direct database connections
  - Mission data compiled into addon PBOs via HEMTT build process

**In-Memory State Management:**
- HAL maintains mission state in SQF arrays and objects
  - Task queuing: `TaskInitNR6.sqf` (65KB core task engine)
  - Unit behavior: `Boss.sqf` and `Boss_fnc.sqf` (AI decision logic)
  - Force structure: `HAC_fnc.sqf` and `HAC_fnc2.sqf` (unit grouping, 260KB+ combined)

## Authentication & Identity

**Authentication:**
- None required - Game based
- Arma 3 integrates player identity through game session
- No external login system or API authentication

**Player Identity:**
- Managed by Arma 3 engine directly
- HAL operates on mission-side scripts (not account-based)

## Monitoring & Observability

**Error Tracking:**
- Custom debug monitoring via `fnc_DbgMon.sqf` in `addons/common/functions/`
- Optional debug output when `DEBUG_MODE_FULL` is enabled in script components
- No external error tracking service

**Logs:**
- In-game console logging (Arma 3 debug console)
- Script debugging via `.rpt` files (Arma 3 RPT logs location: user's Arma 3 config directory)
- Optional debug macro definitions in component-level headers:
  - `DEBUG_ENABLED_*` flags in `addons/*/script_component.hpp`
  - `DEBUG_SETTINGS_*` for component-specific trace levels

**Debug Framework:**
- Uses Arma 3 native debug capabilities
- No external monitoring or APM integration

## CI/CD & Deployment

**Hosting/Distribution:**
- Steam Workshop (primary distribution)
  - Configured in `.hemtt/launch.toml`
  - Automatic dependency resolution via Steam workshop IDs

**Local Distribution:**
- Local mod directory installation (`addons/` → `mods/` folder in Arma 3)
- Manual PBO compilation with Arma 3 Tools or PBOMan

**Build Pipeline:**
- HEMTT (local build tool)
  - Config: `.hemtt/project.toml`
  - Handles: Compilation, PBO packaging, dependency validation
  - No cloud CI integration detected (GitHub Actions, Jenkins, etc.)

**Version Control:**
- Git repository (configured with user: "Jakub Charyton")
- No automated release pipeline detected

## Remote Code Execution

**Inter-process Communication:**
- `remoteExec` / `remoteExecCall` - Networked script execution
  - Used in: `addons/common/functions/fnc_AIChatter.sqf`, `fnc_HQChatter.sqf`, `fnc_reqLogisticsActions.sqf`, `fnc_reqTransportActions.sqf`
  - Purpose: Multiplayer synchronization of AI radio chatter and unit commands
  - Example: `[_unit, _sentence] remoteExecCall ["sideRadio"];` executes sideRadio on remote clients

- `callExtension` - Not actively used in codebase
  - Capability exists but no active external DLL/native extensions detected

**Script Execution:**
- `execVM` - Load and execute external SQF files
  - Used in: `addons/core/functions/fnc_init.sqf`
  - Example: `nul = [] execVM (RYD_Path + "SquadTaskingNR6.sqf");`
  - Purpose: Dynamic loading of task and reinforcement modules at mission initialization

- `preprocessFileLineNumbers` - Include and preprocess header files
  - Used throughout for macro expansion in SQF function compilation
  - Example in macros: `PREP(fncName) = compile preprocessFileLineNumbers QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)`

## Webhooks & Callbacks

**Incoming:**
- Arma 3 event handlers (`CfgEventHandlers.hpp`)
  - Mission initialization events
  - Player connection events (multiplayer)
  - Location in: `addons/*/CfgEventHandlers.hpp`
  - No external webhook listeners

**Outgoing:**
- None detected - System operates entirely within Arma 3 runtime

**Event-Driven Architecture:**
- Arma 3 Mission Event Handler System
  - Hooks defined in: `addons/core/CfgEventHandlers.hpp`, `addons/common/CfgEventHandlers.hpp`
  - Execution model: Event-based task spawning and AI behavior updates

## External Libraries & Includes

**CBA (Community Base Addons):**
- Required: Version 3.16.0
- Functions called:
  - `CBA_fnc_randPos` - Random position generation within radius
  - `CBA_fnc_findMax` - Array maximum value finding
  - `CBA_fnc_waitUntilAndExecute` - Conditional task execution
  - `CBA_fnc_compileFunction` - Function precompilation and caching
- Location: Injected via `#include "\z\hal\addons\main\script_mod.hpp"` and `script_macros.hpp`
- Installation: Steam Workshop dependency (auto-loaded by launcher)

**Arma 3 Vanilla Assets:**
- Files included from base game:
  - `A3\modules_f\marta\data\scripts\fnc_getType.sqf` - Asset type detection (in `addons/core/functions/fnc_init.sqf`)
  - `A3\modules_f\marta\data\scripts\fnc_getSize.sqf` - Asset size detection
  - Purpose: MARTA (Modular Artillery Targeting Assistant) integration for auto-detection of asset capabilities

**ACE3 (Advanced Combat Environment):**
- Optional reference macros available in `include/z/ace/addons/medical_engine/`
- Status: Not required, included for potential future medical system integration
- Not actively integrated in current HAL implementation

## Mission Module System

**CfgVehicles Module Classes:**
- Defined in: `addons/missionmodules/CfgVehicles.hpp`, `addons/common/CfgVehicles.hpp`
- Arma 3 Integration: Modules appear in editor module list
- Function calls: Scripts execute via CfgEventHandlers when modules are placed in mission editor
- Examples:
  - HAL Commander Leader Module - `addons/missionmodules/`
  - NR6 Sites Garrison Script - `addons/common/` (alternative to stock HAL)

## Environment & Configuration

**Required Environment Variables:**
- None - Configuration is entirely file-based

**Runtime Paths:**
- Dynamic path construction: `RYD_Path` variable set during mission initialization
  - References: `nr6_hal/` directory files
  - Used in: `addons/core/functions/fnc_init.sqf`

**Preprocessor Includes:**
- Header system: `\z\hal\addons\main\script_*.hpp` files
  - Version: `script_version.hpp` (defines MAJOR=1, MINOR=0, PATCH=0)
  - Macros: `script_macros.hpp` (ACE3-style macro definitions)
  - Configuration: `script_mod.hpp` (paths, versions, includes)

## Network Configuration

**Multiplayer Support:**
- Client/Server Architecture: Arma 3 native multiplayer model
- Synchronization: Via `remoteExec`/`remoteExecCall` for:
  - Radio chatter broadcast to all clients
  - Unit command execution across network
  - Logistics and reinforcement updates
- No dedicated server authentication or API

**Port Configuration:**
- Handled by Arma 3 engine (default: UDP 2302-2305)
- Not configurable at HAL level

---

*Integration audit: 2026-04-09*
