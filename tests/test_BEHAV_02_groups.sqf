// BEHAV-02: Group Management Smoke Test
// Run via: 0 = [] execVM "tests\test_BEHAV_02_groups.sqf"; in debug console
// Prerequisites: HAL Core + at least one Include module with synced AI groups
// Expected: After ~30s, HQ has friends list and groups have waypoints
//
// Verifies MACHINERY (groups linked to HQ, waypoints issued), not tactical decisions.

private _testName = "BEHAV-02: Groups";
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
systemChat "Waiting 30s for group assignment...";
sleep 30;

private _allHQ = missionNamespace getVariable ["hal_core_allHQ", []];
if (count _allHQ == 0) exitWith {
    systemChat format ["=== %1: ABORTED (no HQ) ===", _testName];
};

private _HQ = _allHQ select 0;

// Check friends list populated on HQ group
private _friends = _HQ getVariable ["hal_core_friends", []];
[format ["friends list non-empty (count=%1)", count _friends], count _friends > 0] call _check;

// Check at least one subordinate has waypoints assigned
private _hasWP = false;
private _wpCount = 0;
{
    if (!isNull _x) then {
        private _w = count (waypoints _x);
        if (_w > 0) then {
            _hasWP = true;
            _wpCount = _wpCount + _w;
        };
    };
} forEach _friends;
[format ["at least one friend group has waypoints (total=%1)", _wpCount], _hasWP] call _check;

// Check lastFriends snapshot variable exists (set by HQSitRep loop)
private _hasLast = !isNil {_HQ getVariable "hal_core_lastFriends"};
["HQ lastFriends snapshot variable initialised", _hasLast] call _check;

// Check at least one friend group has a side matching HQ side
private _hqSide = side _HQ;
private _sideMatch = false;
{
    if (!isNull _x && {(side _x) == _hqSide}) exitWith { _sideMatch = true; };
} forEach _friends;
["at least one friend group shares HQ side", _sideMatch] call _check;

systemChat format ["=== %1: %2/%3 passed, %4 failed ===",
    _testName, NR6HAL_TEST_pass, NR6HAL_TEST_total, NR6HAL_TEST_fail];
