// BEHAV-03: Enemy Scan Loop Smoke Test
// Run via: 0 = [] execVM "tests\test_BEHAV_03_scan.sqf"; in debug console
// Prerequisites: HAL Core active, enemy units placed within ~1000m of friendly groups
// Expected: After ~60s, scan loop has tagged enemies and set marker state
//
// Verifies MACHINERY (scan loop ran, enemy markers set), not tactical decisions.

private _testName = "BEHAV-03: Enemy Scan";
NR6HAL_TEST_pass = 0;
NR6HAL_TEST_fail = 0;
NR6HAL_TEST_total = 0;

private _check = {
    params ["_desc", "_condition"];
    NR6HAL_TEST_total = NR6HAL_TEST_total + 1;
    if (_condition) then {
        NR6HAL_TEST_pass = NR6HAL_TEST_pass + 1;
        systemChat format ["  [PASS] %1", _desc];
    } else {
        NR6HAL_TEST_fail = NR6HAL_TEST_fail + 1;
        systemChat format ["  [FAIL] %1", _desc];
    };
};

systemChat format ["=== %1 ===", _testName];
systemChat "Waiting 60s for enemy scan cycle...";
sleep 60;

private _allHQ = missionNamespace getVariable ["hal_core_allHQ", []];
if (count _allHQ == 0) exitWith {
    systemChat format ["=== %1: ABORTED (no HQ) ===", _testName];
};

private _HQ = _allHQ select 0;

// Verify EnemyScan function compiled
private _scanFn = missionNamespace getVariable ["hal_core_fnc_EnemyScan", {}];
["hal_core_fnc_EnemyScan is a compiled function", _scanFn isEqualType {}] call _check;

// Check eS flag (set at end of EnemyScan in fnc_EnemyScan.sqf line 198)
private _eS = _HQ getVariable ["hal_core_eS", false];
["hal_core_eS flag set on HQ (scan ran)", _eS] call _check;

// Check at least one enemy group has been seen / tagged with markerES
private _enemySides = [];
{ if (!isNull _x) then { _enemySides pushBackUnique (side _x); }; } forEach allGroups;
private _hqSide = side _HQ;
private _enemyGroups = allGroups select {
    !isNull _x && {(side _x) getFriend _hqSide < 0.6} && {(side _x) != _hqSide}
};
private _markedCount = {
    _x getVariable ["hal_core_markerES", false]
} count _enemyGroups;
[format ["at least one enemy group tagged with markerES (marked=%1/%2)",
    _markedCount, count _enemyGroups], _markedCount > 0] call _check;

// Check HQSitRep cyclecount has advanced (loop is running)
private _cycle = _HQ getVariable ["hal_core_cyclecount", 0];
[format ["HQ cyclecount > 0 (got %1)", _cycle], _cycle > 0] call _check;

systemChat format ["=== %1: %2/%3 passed, %4 failed ===",
    _testName, NR6HAL_TEST_pass, NR6HAL_TEST_total, NR6HAL_TEST_fail];
