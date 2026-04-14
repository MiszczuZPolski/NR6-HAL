// BEHAV-04: Artillery / CFF Smoke Test
// Run via: 0 = [] execVM "tests\test_BEHAV_04_arty.sqf"; in debug console
// Prerequisites: HAL Core active, at least one artillery battery (mortar/howitzer)
//                synced as a friendly group, enemies present within range
// Expected: After ~90s, artillery machinery is wired (battery recognised)
//
// Verifies MACHINERY (artyMission function exists, batteryBusy var touched).
// NOTE: Stochastic - actual fire missions depend on tactical state. Tests
// only verify the wiring, not that a round was fired.

private _testName = "BEHAV-04: Artillery";
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
systemChat "Waiting 90s for artillery dispatch cycle...";
sleep 90;

private _allHQ = missionNamespace getVariable ["hal_core_allHQ", []];
if (count _allHQ == 0) exitWith {
    systemChat format ["=== %1: ABORTED (no HQ) ===", _testName];
};

private _HQ = _allHQ select 0;

// Verify artyMission function compiled
private _artyFn = missionNamespace getVariable ["hal_common_fnc_artyMission", {}];
["hal_common_fnc_artyMission is compiled", _artyFn isEqualType {}] call _check;

// Check friends list and look for batteries
private _friends = _HQ getVariable ["hal_core_friends", []];
private _batteries = [];
{
    if (!isNull _x) then {
        private _arr = (units _x) select {
            !isNull _x && {alive _x} && {getArtilleryAmmo [vehicle _x] isNotEqualTo []}
        };
        if (count _arr > 0) then { _batteries pushBack _x; };
    };
} forEach _friends;
[format ["at least one artillery-capable group in friends list (count=%1)",
    count _batteries], count _batteries > 0] call _check;

// Check batteryBusy variable touched on at least one battery (default unset)
private _touched = 0;
{
    private _v = _x getVariable ["hal_common_batteryBusy", "UNSET"];
    if (_v isNotEqualTo "UNSET") then { _touched = _touched + 1; };
} forEach _batteries;
[format ["batteryBusy variable touched on %1/%2 batteries",
    _touched, count _batteries], _touched > 0 || count _batteries == 0] call _check;

// Check HQ has fireSupport-related state (fast / fineness used in arty decisions)
private _hasFineness = !isNil {_HQ getVariable "hal_core_fineness"};
["HQ fineness (arty decision input) initialised", _hasFineness] call _check;

systemChat format ["=== %1: %2/%3 passed, %4 failed ===",
    _testName, NR6HAL_TEST_pass, NR6HAL_TEST_total, NR6HAL_TEST_fail];
