// BEHAV-01: HQ Initialization Smoke Test
// Run via: 0 = [] execVM "tests\test_BEHAV_01_init.sqf"; in debug console
// Prerequisites: Place HAL Core module synced to a group leader in editor
// Expected: After ~20s, HQ has personality traits and state variables set
//
// Verifies MACHINERY (variables set, init ran), not tactical decisions.

private _testName = "BEHAV-01: HQ Init";
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
systemChat "Waiting 20s for HQ init...";
sleep 20;

// Check core HQ list populated
private _allHQ = missionNamespace getVariable ["hal_core_allHQ", []];
["hal_core_allHQ array is non-empty", count _allHQ > 0] call _check;

if (count _allHQ == 0) exitWith {
    systemChat format ["=== %1: ABORTED (no HQ) - %2/%3 passed ===",
        _testName, NR6HAL_TEST_pass, NR6HAL_TEST_total];
};

private _HQ = _allHQ select 0;
["HQ group is not null", !(isNull _HQ)] call _check;

// Check codeSign letter set
private _code = _HQ getVariable ["hal_core_codeSign", ""];
[format ["codeSign is set (got '%1')", _code], _code isNotEqualTo ""] call _check;

// Check personality traits in [0,1]
{
    _x params ["_var", "_label"];
    private _val = _HQ getVariable [_var, -1];
    [format ["%1 in [0,1] (got %2)", _label, _val], (_val >= 0) && (_val <= 1)] call _check;
} forEach [
    ["hal_core_recklessness",   "recklessness"],
    ["hal_core_consistency",    "consistency"],
    ["hal_core_activity",       "activity"],
    ["hal_core_reflex",         "reflex"],
    ["hal_core_circumspection", "circumspection"],
    ["hal_core_fineness",       "fineness"]
];

// Check personality string assigned
private _pers = _HQ getVariable ["hal_core_personality", ""];
[format ["personality string set (got '%1')", _pers], _pers isNotEqualTo ""] call _check;

// Check allLeaders array populated
private _allLeaders = missionNamespace getVariable ["hal_core_allLeaders", []];
["hal_core_allLeaders array is non-empty", count _allLeaders > 0] call _check;

// Check core init flag (cyclecount initialised by HQSitRep)
private _hasCycle = !isNil {_HQ getVariable "hal_core_cyclecount"};
["HQ cyclecount variable initialised", _hasCycle] call _check;

systemChat format ["=== %1: %2/%3 passed, %4 failed ===",
    _testName, NR6HAL_TEST_pass, NR6HAL_TEST_total, NR6HAL_TEST_fail];
