# Coding Conventions

**Analysis Date:** 2026-04-09

## Language & Context

This is an Arma 3 mod written in SQF (SQF Script), a scripting language specific to Bohemia Interactive's game engine. The project uses HEMTT (Headless Execute Mission Total Taskforce) as a build tool and follows the CBA (Community Base Addons) framework structure.

## File Organization & Naming

**Files:**
- SQF scripts: snake_case with `fnc_` prefix for functions
- Example: `fnc_addTask.sqf`, `fnc_AIChatter.sqf`, `fnc_angleTowards.sqf`
- Location: `addons/{component}/functions/fnc_{functionName}.sqf`
- Header files: `script_component.hpp`, `script_mod.hpp`, `script_macros.hpp`
- Config files: `config.cpp`, `CfgEventHandlers.hpp`
- Initialization: `XEH_preInit.sqf`, `XEH_postInit.sqf`

**Directories:**
- addon-based structure: `addons/{component_name}/`
- Each addon contains: `functions/`, `config.cpp`, `script_component.hpp`, `CfgEventHandlers.hpp`, `XEH_*.sqf`
- Key addons: `addons/main` (core macros), `addons/common` (shared functions), `addons/core`, `addons/missionmodules`

## Naming Patterns

**Variables:**
- Private variables: prefix with underscore `_variableName`
- Mission namespace variables: `RydxHQ_`, `RydHQ_`, `HAL_`, `HAC_` prefixes
- Examples: `_unit`, `_group`, `_position`, `_enemyGroups`, `_maxDistance`, `_closestEnemyGroup`, `_checkedVehicles`
- Camel case for compound names: `_unitGroup`, `_lastCommunication`, `_minimumDistance`
- Prefixed: `RydHQ_Front`, `RydxHQ_AllHQ`, `HAC_LastComm`, `RydHQ_BatteryBusy`

**Functions:**
- Global function naming: `ADDON_fnc_functionName` (compiled via macros)
- Internal references use `FUNC()` macro: `call FUNC(functionName)`
- Function names describe action: `addTask`, `closeEnemy`, `findBiggest`, `clusterC`, `createDecoy`

**Types & Constants:**
- Group types: `grpNull`, `groupId()`
- Object checks: `isNull`, `isNil`
- Variables stored on objects: `getVariable`, `setVariable`
- Mission namespace: `missionNamespace getVariable [...]`, `missionNamespace setVariable [...]`

## Code Style

**Formatting:**
- Indentation: 4 spaces (from `.editorconfig`)
- Line endings: LF
- Character encoding: UTF-8
- Trim trailing whitespace
- Insert final newline

**Structure:**
```sqf
#include "..\script_component.hpp"

params ["_param1", "_param2", ["_optionalParam", defaultValue]];

private _variableName = value;
private _anotherVar = calculation;

// Logic here
if (condition) then {
    // action
};

// Return value at end (implicit return)
_result
```

**Key formatting conventions:**
- `params` statement at top of script
- Use `private` for all local variables
- Optional parameters use array syntax: `["_paramName", defaultValue]`
- Implicit return (value at end of script)
- Single-line comments: `//`
- Block comments: `/** ... */` for JSDoc-style documentation

## Control Flow

**Conditional Logic:**
- Use `if...then` blocks: `if (condition) then { code }`
- Exit early with `exitWith`: `if (badCondition) exitWith { return value }`
- Switch statements: `switch (expression) do { case value: {...}; default: {...}; }`
- Negation: `if !(condition)` or `if not (condition)` (both used)
- Equality: `isEqualTo` for comparisons, `isNotEqualTo` for inequality

**Examples from codebase:**
```sqf
// Early exit pattern
if (count _enemyGroups == 0) exitWith {false};

// Conditional setting
if ((time - _lastTimestamp) < 5) then {sleep 2};

// Negation check
if !(_unit in _checkedVehicles) then { ... };

// Switch with type checking
switch (true) do {
    case (_messageType in ["ArtyReq", "SmokeReq"]): { ... };
    case (_messageType in ["ArtDen", "SuppDen"]): { ... };
    default: { ... };
};
```

## Loops & Iteration

**forEach loops:**
- Standard iteration: `{ code with _x, _forEachIndex } forEach _array`
- Access to automatic index: `_forEachIndex` (0-based)
- Current element: `_x`
- Early exit: `exitWith` within loop

**Examples:**
```sqf
// Iterate and modify
{
    if (vehicle _x isNotEqualTo _x) then {
        _groupVehicles pushBackUnique (vehicle _x);
    };
} forEach (units _group);

// Conditional iteration with exit
{
    if (_enemyDistance < _maxDistance) exitWith {
        _enemyIsClose = true;
    };
} forEach _enemyGroups;

// Indexed iteration
{
    private _currentUnitCount = count (units _x);
    if (_currentUnitCount > _maxUnitCount) then {
        _biggest = _x;
        _biggestIndex = _forEachIndex;
    };
} forEach _array;
```

## Functions & Parameters

**Definition:**
- All parameters extracted via `params` statement
- Optional parameters with default values
- Type hints in JSDoc comments

**Parameter extraction pattern:**
```sqf
params ["_unit", "_descr", "_dstn", "_type"];

// With optional parameters
params ["_group", ["_excludedVehicles", []]];

// Complex optional params
params ["_position", "_enemyGroups", "_maxDistance"];
```

**Return values:**
- Implicit return: place return value at end of script
- Can be any type: boolean, number, array, object, string
- No explicit `return` statement needed

**Examples:**
```sqf
// Simple return
_task

// Boolean return
_enemyIsClose

// Array return
[_enemyIsClose, _minimumDistance, _closestEnemyGroup]

// Calculation return
(_currentAmmo / (_maxAmmo max 1))
```

## Documentation

**JSDoc/TSDoc Style:**
- Three-line comment blocks with `@description`, `@param`, `@return`
- Type annotations in curly braces: `{Type}`
- Optional params noted: `[Optional]`

**Example:**
```sqf
/**
 * @description Checks if any enemy group is within the specified distance
 * @param {Object|Array} Position or object to check from
 * @param {Array} Array of enemy groups to check
 * @param {Number} Maximum distance to consider enemies as "close"
 * @return {Boolean} True if any enemy is within range, false otherwise
 */
```

**Coverage:**
- Most addon functions have documentation (172+ comment lines in common addon alone)
- Comments explain non-obvious logic
- Original function credits included: `// Originally from HAC_fnc.sqf (RYD_FunctionName)`

## Macro System (CBA-based)

**Key macros from `script_macros.hpp`:**
- `FUNC(name)` - Generate function namespace: expands to `ADDON_fnc_name`
- `QFUNC(name)` - Quoted function name
- `DFUNC(name)` - Direct function reference
- `GETVAR(obj, var, default)` - Get variable with default
- `SETVAR(obj, var, value)` - Set variable
- `GETMVAR(var, default)` - Mission namespace get
- `SETMVAR(var, value)` - Mission namespace set
- `GVAR(name)` - Global variable reference

**Usage examples:**
```sqf
#include "..\script_component.hpp"

// Function compilation via macro
PREP(functionName);

// Function calls
call FUNC(mark);
[_unit, _sentences, _messageType] call FUNC(AIChatter);

// Variable access
private _tasks = (group _unit) getVariable ["HACAddedTasks", []];
(group _unit) setVariable ["HACAddedTasks", _tasks];

// Mission namespace
private _lastComm = _unitGroup getVariable ["HAC_LastComm", -5];
missionNamespace getVariable ["RydxHQ_AIChat_Type", "NONE"]
```

## Error Handling

**Defensive Programming:**
- Check array/count before access: `if (count _array > 0) then { _array select 0 }`
- Null checks: `if !(isNull _object)`, `if (isNil "_variable")`
- Safe element selection with index validation
- Use `max` operator for safe minimum: `(_currentAmmo / (_maxAmmo max 1))`

**Patterns:**
```sqf
// Safe count check
if (count _enemyGroups == 0) exitWith {false};

// Safe variable access
private _lastTime = missionNamespace getVariable ["VAR_NAME", [0, ""]];
private _value = _lastTime select 0;

// Null-safe operations
if !(isNull _parachute) then { deleteVehicle _parachute };

// Type checking via config
if (isClass _turretConfigPath) then {
    _turretMags = getArray (_turretConfigPath >> "magazines");
};
```

## Performance & Async

**Async/Spawn patterns:**
```sqf
// Spawn background task
[_marker] spawn {
    params ["_marker"];
    private _alpha = 1;
    sleep 27.5;
    for "_i" from 1 to 20 do {
        _alpha = _alpha - 0.05;
        _marker setMarkerAlpha _alpha;
        sleep 0.1;
    };
    deleteMarker _marker;
};

// Call with custom spawn function
[[params...], FUNCTION_NAME] call RYD_Spawn;

// Remote execution
[_unit, _sentence] remoteExecCall ["sideRadio"];
```

**Sleep usage:**
- Used for throttling/timing: `sleep 1;`, `sleep 27.5;`, `sleep 0.1;`
- Used with conditions: `if (condition) then {sleep 2};`
- Used in loops with delays: `for "_i" from 1 to count do { ... sleep 0.1; };`

## Array Operations

**Common patterns:**
- `pushBack` - Add to end
- `pushBackUnique` - Add if not exists
- `select` - Index access
- `count` - Get length
- `in` - Membership test
- `forEach` - Iteration

**Examples:**
```sqf
// Add with duplicate prevention
_groupVehicles pushBackUnique (vehicle _x);
_checkedVehicles pushBackUnique _unit;

// Count and index
if ((count _array) > 0) then { _array select 0 };
_largest = _array select _biggestIndex;

// Array membership
if !(_x in _checked) then { ... };
if (_messageType in ["ArtyReq", "SmokeReq"]) then { ... };

// Build result array
[_enemyIsClose, _minimumDistance, _closestEnemyGroup]
```

## Configuration & Includes

**Include hierarchy:**
1. `script_component.hpp` - Per-addon component definition
2. `script_mod.hpp` - Version and core constants
3. `script_macros.hpp` - Macro definitions
4. CBA includes: `\x\cba\addons\main\script_macros_common.hpp`

**Preprocessor directives:**
```sqf
#include "..\script_component.hpp"  // Relative include to component
#include "\z\hal\addons\main\..."   // Absolute path from mod root
#define COMPONENT common             // Define component name
#define COMPONENT_BEAUTIFIED "..."   // Display name
#ifdef DEBUG_ENABLED_HAL             // Conditional compilation
#endif
```

---

*Convention analysis: 2026-04-09*
