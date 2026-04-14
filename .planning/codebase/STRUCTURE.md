# Codebase Structure

**Analysis Date:** 2026-04-09

## Directory Layout

```
NR6-HAL/
├── .hemtt/                 # Build tool configuration (HEMTT compiler)
├── .planning/              # Generated analysis documents
├── addons/                 # Primary codebase - organized by functional addon
│   ├── main/               # Core configuration, macros, UI framework
│   ├── core/               # HAL AI commander core logic
│   ├── common/             # Shared utility functions (65+ functions)
│   └── missionmodules/     # Mission editor modules and settings (45+ functions)
├── include/                # CBA and framework headers (linked, not source)
│   ├── a3/                 # Arma 3 base includes
│   ├── x/cba/              # CBA framework headers
│   └── z/ace/              # ACE3 framework headers
├── cache/                  # Build artifacts (PBO compilation output)
├── nr6_hal/                # Legacy asset folder (sounds, LF data)
├── nr6_*/                  # Separate mission modules/support addons
├── mod.cpp                 # Mod metadata file
├── README.md               # Project documentation
└── LICENSE                 # License information
```

## Directory Purposes

**addons/main/:**
- Purpose: Central configuration hub and macro definitions
- Contains: Versioning, CBA/ACE macro definitions, UI framework, debug settings
- Key files: `script_mod.hpp` (prefix/version), `script_macros.hpp` (CBA macro overrides), `script_debug.hpp` (debug configuration)

**addons/core/:**
- Purpose: HAL AI commander initialization and core scanning logic
- Contains: HAL group instantiation, personality system, enemy threat detection, HQ state management
- Key files: `fnc_init.sqf` (initialize HQ), `fnc_EnemyScan.sqf` (threat scanning), `fnc_HQSitRep.sqf` (situation reporting), `fnc_personality.sqf` (commander traits)

**addons/common/:**
- Purpose: Reusable tactical and utility functions for all subsystems
- Contains: 69 functions including pathfinding, group management, wait conditions, artillery prep, formation logic, marker systems, MP synchronization
- Key files: `fnc_spawn.sqf` (script spawning), `fnc_wait.sqf` (wait loop), `fnc_artyMission.sqf` (artillery), `fnc_garrisonP.sqf`/`fnc_garrisonS.sqf` (garrison)

**addons/missionmodules/:**
- Purpose: Mission editor module interface for configuring HAL behavior and objectives
- Contains: 45+ module initialization functions defining mission objectives, group settings, leader behaviors, support actions, exclusion rules
- Key files: `fnc_init.sqf` (module auto-init template), `fnc_generalSettings.sqf`, `fnc_leaderBehaviourSettings.sqf`, `fnc_objective.sqf`, `fnc_garrison.sqf`, `fnc_front.sqf`
- Large file: `CfgVehicles.hpp` (2850 lines - all module class definitions for editor)

**addons/main/ui/:**
- Purpose: In-mission UI dialogs and communication system
- Contains: Dialog definitions, radio communication resources
- Used by: Mission runtime and players

## Key File Locations

**Entry Points:**

- `addons/core/XEH_preInit.sqf`: CBA preInit hook - sets ADDON flag, triggers function compilation via `XEH_PREP.hpp`
- `addons/core/XEH_postInit.sqf`: CBA postInit hook - signals addon ready
- `addons/missionmodules/functions/fnc_init.sqf`: Generic module initializer (used as sync target for Core module)
- `addons/core/functions/fnc_init.sqf`: Main HAL initialization - called by Core module, initializes HQ group with all variables and spawns main event loops

**Configuration:**

- `addons/main/script_mod.hpp`: Mod prefix, version numbers, required version (2.14)
- `addons/main/script_macros.hpp`: CBA macro library customizations, version macros, debug settings
- `addons/core/config.cpp`: Addon metadata - requires CBA_main and hal_main
- `addons/missionmodules/config.cpp`: Module metadata - requires core addon, A3_Modules_F

**Core Logic:**

- `addons/core/functions/fnc_init.sqf`: Initialize HQ group, set default variables, populate group arrays, spawn main loops
- `addons/core/functions/fnc_EnemyScan.sqf`: Periodic threat scanning of all friendly groups, updates danger markers, adjusts AI behavior
- `addons/core/functions/fnc_HQSitRep.sqf`: Situation reporting - gathers intelligence from all units
- `addons/core/functions/fnc_personality.sqf`: Map personality type string to numeric trait values (Recklessness 0-1, Consistency 0-1, etc.)

**Testing:**

- No formal test suite. Function testing requires mission editor placement and mission execution.

## Naming Conventions

**Files:**

- Function files: `fnc_[camelCase].sqf` (e.g., `fnc_enemyScan.sqf`, `fnc_addTask.sqf`)
- Configuration/macros: `script_[purpose].hpp` (e.g., `script_component.hpp`, `script_mod.hpp`, `script_macros.hpp`)
- Event handlers: `XEH_[stage].sqf` (e.g., `XEH_preInit.sqf`, `XEH_postInit.sqf`)
- Prep file: `XEH_PREP.hpp` (lists all functions to be compiled)
- Config files: `config.cpp` (CfgPatches, CfgEventHandlers), `CfgVehicles.hpp`, `CfgFactionClasses.hpp`

**Directories:**

- Addon folders lowercase with underscore: `addons/core/`, `addons/common/`, `addons/main/`, `addons/missionmodules/`
- Subdirectories lowercase: `functions/`, `ui/`, `icons/`
- Include paths follow framework convention: `include/a3/`, `include/x/cba/`, `include/z/ace/`

**Code:**

- Function names: `fnc_[camelCase]` (e.g., `RYD_Spawn`, `FUNC(init)` via macros)
- Global variables: `Ryd*` or `RydHQ_*` prefix (legacy, no namespace isolation)
- Mission namespace variables: `Rydx*` or `Ryd*` (broadcast via publicVariable)
- Object variables: `setVariable ["RydHQ_[PropertyName]", value]`
- Macros: `ADDON`, `COMPONENT`, `PREFIX`, `GVAR()`, `FUNC()`, `EGVAR()`, `QUOTE()` via CBA

## Where to Add New Code

**New Tactical Function:**
- Location: `addons/common/functions/fnc_[newFunction].sqf`
- Prep: Add `PREP(newFunction);` to `addons/common/XEH_PREP.hpp`
- Include header: `#include "..\script_component.hpp"`
- Call pattern: `[params] call FUNC(newFunction)`

**New Mission Module:**
- Location: `addons/missionmodules/functions/fnc_[moduleName].sqf`
- Prep: Add `PREP(moduleName);` to `addons/missionmodules/XEH_PREP.hpp`
- Define class in `CfgVehicles.hpp` with `function = QFUNC(moduleName);` entry
- Module function signature: `params ["_logic", "_units", "_activated"];`

**New Core HQ System:**
- Location: `addons/core/functions/fnc_[system].sqf`
- Prep: Add `PREP(system);` to `addons/core/XEH_PREP.hpp` (file at `addons/core/functions/`)
- Called from: `fnc_init.sqf` or spawned via `fnc_spawn.sqf`

**New Configuration Macro:**
- Location: `addons/main/script_macros.hpp` (if global), or `addons/[addon]/script_component.hpp` (if addon-specific)
- Pattern: Follow CBA convention using `#define` with `QUOTE()`, `TRIPLES()`, `DOUBLES()` macro wrappers

**Shared Utilities:**
- Location: `addons/common/functions/`
- Scope: Accessible from any addon via `FUNC()` macro within that addon, or `EFUNC(common, functionName)` from other addons

## Special Directories

**include/:**
- Purpose: Framework/dependency headers (CBA, Arma 3 base, ACE3)
- Generated: Yes - linked or extracted from external mods
- Committed: Partially - only headers needed for compilation

**cache/:**
- Purpose: Build output directory for HEMTT compiler
- Generated: Yes - PBO files created during build
- Committed: No - ignored in `.gitignore`

**icons/:**
- Purpose: Module UI icons for mission editor
- Generated: No - manually created images (`.paa` format)
- Committed: Yes

**addons/main/ui/:**
- Purpose: Dialog UI definitions and resources
- Generated: No - hand-authored
- Committed: Yes

## File Include Patterns

All files include standard header:
```
#include "..\script_component.hpp"
```

This header chain:
1. `script_component.hpp` → defines `COMPONENT` and `COMPONENT_BEAUTIFIED`
2. → includes `\z\hal\addons\main\script_mod.hpp` (prefix, version, required version)
3. → includes `\z\hal\addons\main\script_macros.hpp` (CBA macros, namespace helpers, ACE macros)
4. → includes `\z\hal\addons\main\script_debug.hpp` (debug flags, logging)

This pattern ensures all functions have access to:
- `FUNC(name)` - call function in current addon
- `EFUNC(addon, name)` - call function in other addon
- `GVAR(name)` - get/set global variables in current addon namespace
- `GETMVAR(name, default)` - get mission namespace variable
- `LOG_8()` - conditional debug logging
- `QUOTE()`, `TRIPLES()`, `DOUBLES()` - macro helpers

---

*Structure analysis: 2026-04-09*
