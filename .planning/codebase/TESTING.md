# Testing Patterns

**Analysis Date:** 2026-04-09

## Current State

**Testing Framework:** Not detected

This codebase does not currently use a dedicated testing framework. There are no automated test files (`.test.sqf`, `.spec.sqf`) or test runner configured. Testing appears to be manual/in-game.

## Test Infrastructure Gaps

**No test runner configured:**
- No Jest, Mocha, Vitest, or SQF-specific test framework
- No test configuration files (jest.config.js, vitest.config.ts, etc.)
- No npm test scripts or test commands

**No test files:**
- 0 test files across the 228 SQF scripts
- 0 test fixtures or test data
- 0 mock/stub infrastructure

**Manual verification only:**
- Testing relies on runtime behavior in Arma 3 mission editor or multiplayer
- No automated validation of function behavior
- Functions cannot be easily isolated or unit tested in current structure

## Development Workflow (Implicit)

Based on codebase examination:

**Function structure enables testing:**
- Pure functions with input parameters: `params ["_param1", "_param2"]`
- Deterministic logic with minimal external dependencies
- Return values explicit (value at end of script)
- Functions are small and focused (most under 50 lines)

**Examples of testable functions:**
```sqf
// fnc_angleTowards.sqf - Pure math function
params ["_source", "_target", "_random"];
private _dX0 = (_target select 0) - (_source select 0);
private _dY0 = (_target select 1) - (_source select 1);
(_dX0 atan2 _dY0) + (random (_random * 2)) - _random;
// INPUT: positions, random value → OUTPUT: angle
// Could be tested by calling with known inputs, verifying output range

// fnc_clusterC.sqf - Array clustering logic
params ["_points", "_range"];
private _clusters = [];
private _checked = [];
{
    if !(_x in _checked) then {
        // clustering logic
    };
} forEach _points;
_clusters;
// INPUT: array of points, distance range → OUTPUT: clustered array
// Could be tested by verifying cluster membership matches distance criteria
```

## Current Testing Approach

**Debug monitoring:**
- `fnc_DbgMon.sqf` - Debug monitoring function that logs HQ status
- Conditional debug output: `missionNamespace getVariable ["RydHQ_ChatDebug", false]`
- Debug markers created when enabled: `if (missionNamespace getVariable ["RydHQ_ChatDebug", false]) then {...}`

**Example debug implementation:**
```sqf
// fnc_AIChatter.sqf - Creates visual markers for debugging
if (missionNamespace getVariable ["RydHQ_ChatDebug", false]) then {
    private _marker = [...] call FUNC(mark);
    [_marker] spawn {
        // Fade out marker over time
        sleep 27.5;
        for "_i" from 1 to 20 do {
            _alpha = _alpha - 0.05;
            _marker setMarkerAlpha _alpha;
            sleep 0.1;
        };
        deleteMarker _marker;
    };
};
```

**In-game verification:**
- Testing performed through Arma 3 mission execution
- Script output visible through:
  - Debug markers on map
  - Rpt file logging
  - Visual/behavioral changes in simulation
  - Chat messages and radio communications

## Recommendations for Testing Infrastructure

**To add automated testing:**

1. **Unit Test Framework Option: SQF_VM or custom test runner**
   - Create test suite in separate directory: `tests/unit/`
   - Each test file: `tests/unit/fnc_{functionName}.test.sqf`
   - Test harness would need to:
     - Load function from compilation cache
     - Call with known inputs
     - Assert output equals expected values

2. **Test Structure Pattern (if implemented):**
   ```sqf
   // tests/unit/fnc_angleTowards.test.sqf
   #include "...\addons\common\script_component.hpp"
   
   // Load function (would need custom loader)
   call FUNC(angleTowards);
   
   // Test fixture: known inputs and expected outputs
   private _testCases = [
       // [source, target, random] -> expectedOutput
       [[0, 0, 0], [0, 1, 0], 0],  // Should return 0° (north)
       [[0, 0, 0], [1, 0, 0], 0],  // Should return 90° (east)
       [[0, 0, 0], [0, -1, 0], 0]  // Should return 180° (south)
   ];
   
   private _passed = 0;
   private _failed = 0;
   
   {
       private _source = _x select 0;
       private _target = _x select 1;
       private _random = _x select 2;
       
       private _result = [_source, _target, _random] call FUNC(angleTowards);
       private _expected = _x select 3;
       
       if (abs (_result - _expected) < 0.01) then {
           _passed = _passed + 1;
       } else {
           _failed = _failed + 1;
           diag_log format ["FAIL: expected %1, got %2", _expected, _result];
       };
   } forEach _testCases;
   
   diag_log format ["Tests: %1 passed, %2 failed", _passed, _failed];
   ```

3. **Integration Test Pattern:**
   - Test function chains: `fnc_artyMission` → `fnc_cff` → `fnc_cff_ffe`
   - Verify mission namespace variables are properly set/retrieved
   - Test spawned async tasks complete correctly

4. **Test Coverage Priorities (High Impact):**
   - `fnc_ammoFullCount.sqf` (complex config traversal) - Lines: 138
   - `fnc_AIChatter.sqf` (state management, side effects) - Lines: 145
   - `fnc_cff_ffe.sqf` (largest function, artillery logic) - Lines: 672
   - `fnc_closeEnemyB.sqf` (used widely, distance calculations) - Lines: 38
   - `fnc_clusterC.sqf` (clustering algorithm) - Lines: 35

## Testing Considerations for SQF

**Challenges specific to SQF:**
- Cannot easily mock Arma 3 engine functions (vehicle, units, group, etc.)
- Math functions work deterministically, but random() functions need seeding
- Mission namespace state persists across tests (need setup/teardown)
- Object references (groups, units) only exist in running mission context

**What CAN be tested in isolation:**
- Pure math calculations (`fnc_angleTowards`)
- Array operations (`fnc_clusterC`, `fnc_findBiggest`)
- Conditional logic without engine dependencies
- Variable accessor patterns (getter/setter functions)

**What requires integration/in-game testing:**
- Group/unit manipulation (`fnc_addTask`, `fnc_garrisonS`)
- Vehicle/weapon interactions (`fnc_ammoCount`)
- Mission event handlers (`XEH_preInit`, `XEH_postInit`)
- Multiplayer remote execution (`fnc_MP_*` functions)

## Code Patterns That Aid Testing

**Dependency injection pattern (used in some functions):**
```sqf
// fnc_closeEnemy - Takes dependencies as parameters, not globals
params ["_position", "_enemyGroups", "_maxDistance"];
// All inputs passed in, no hidden globals (except Arma functions)
// Easy to call with test data
```

**Variable storage on objects (traceable):**
```sqf
// fnc_addTask - Stores task ID on group variable
(group _unit) setVariable ["HACAddedTasks", _tasks];
// Can verify by checking group variable after call
// Tests can inspect: (testGroup) getVariable ["HACAddedTasks"]
```

**Clear input/output contracts:**
```sqf
// Functions with clear @param/@return documentation
// Can write property-based tests
// Example: fnc_clusterC should cluster all points within range of seed
```

## Testing Best Practices to Follow (If Implemented)

1. **Test isolation:**
   - Reset mission namespace variables between tests
   - Use unique test identifiers for group/unit creation
   - Clean up spawned objects after each test

2. **Assertion patterns:**
   ```sqf
   // Equality
   if (_result != _expected) exitWith {diag_log "FAIL: values not equal"};
   
   // Array comparison
   if (_result isNotEqualTo _expected) exitWith {diag_log "FAIL: arrays differ"};
   
   // Range testing (for distance, angles)
   if (abs (_result - _expected) > _tolerance) exitWith {diag_log "FAIL: out of range"};
   ```

3. **Test organization:**
   - One test file per function: `tests/unit/fnc_{name}.test.sqf`
   - Test data in fixtures: `tests/fixtures/pointsArray.sqf`
   - Helper functions: `tests/helpers/assert.sqf`

4. **Documentation in tests:**
   ```sqf
   /**
    * @test fnc_angleTowards
    * @description Verify angle calculation to target with random variance
    * @given source position at [0,0], target at [0,100]
    * @when random variance is 0
    * @then return angle should be 0 (north)
    */
   ```

## File Organization for Testing

**Proposed structure (if testing added):**
```
tests/
├── unit/
│   ├── fnc_angleTowards.test.sqf
│   ├── fnc_clusterC.test.sqf
│   ├── fnc_closeEnemy.test.sqf
│   └── ...
├── integration/
│   ├── artillery_mission_chain.test.sqf
│   └── hq_chatter_system.test.sqf
├── fixtures/
│   ├── groups.sqf
│   ├── positions.sqf
│   └── enemy_arrays.sqf
├── helpers/
│   ├── assert.sqf
│   └── test_runner.sqf
└── README.md
```

---

*Testing analysis: 2026-04-09*
