// HAL Test Harness — Run All BEHAV Smoke Tests
//
// Executes BEHAV-01 through BEHAV-05 sequentially, aggregates PASS/FAIL
// counts across every assertion, and prints a single final report.
//
// Usage (debug console):
//     0 = [] execVM "tests\harness\run-all.sqf";
//
// Prerequisites:
//     - setup-scenario.sqf has run (or an equivalent mission is loaded with
//       HAL Core + Include + AI groups + enemies + artillery)
//     - tests\ directory is accessible from the mission folder
//
// Total runtime: ~4-5 minutes (dominated by BEHAV-04's 90s artillery wait).

if (!isServer) exitWith {
    systemChat "[HARNESS] run-all must execute on the server. Aborting.";
};

if !(missionNamespace getVariable ["HARNESS_setupComplete", false]) then {
    systemChat "[HARNESS] WARNING: setup-scenario.sqf hasn't run. Tests will still execute";
    systemChat "[HARNESS]          but may fail if the mission lacks HAL groups/enemies/arty.";
};

systemChat "=== HAL Test Harness: run-all ===";
systemChat "Executing 5 BEHAV tests sequentially. Estimated total: ~4 min.";
systemChat "Watch systemChat for per-test [PASS]/[FAIL] lines.";

HARNESS_agg_pass = 0;
HARNESS_agg_fail = 0;
HARNESS_agg_total = 0;
HARNESS_agg_log = [];

private _runOne = {
    params ["_script", "_label"];
    systemChat format ["", ""];
    systemChat format ["---------- %1 ----------", _label];

    // Reset per-test counters
    NR6HAL_TEST_pass = 0;
    NR6HAL_TEST_fail = 0;
    NR6HAL_TEST_total = 0;

    private _handle = [] execVM _script;
    waitUntil { scriptDone _handle };

    HARNESS_agg_pass = HARNESS_agg_pass + NR6HAL_TEST_pass;
    HARNESS_agg_fail = HARNESS_agg_fail + NR6HAL_TEST_fail;
    HARNESS_agg_total = HARNESS_agg_total + NR6HAL_TEST_total;
    HARNESS_agg_log pushBack [_label, NR6HAL_TEST_pass, NR6HAL_TEST_fail, NR6HAL_TEST_total];

    systemChat format ["  -> %1: %2/%3 passed, %4 failed",
        _label, NR6HAL_TEST_pass, NR6HAL_TEST_total, NR6HAL_TEST_fail];
};

["tests\test_BEHAV_01_init.sqf", "BEHAV-01 HQ Init"] call _runOne;
["tests\test_BEHAV_02_groups.sqf", "BEHAV-02 Groups"] call _runOne;
["tests\test_BEHAV_03_scan.sqf", "BEHAV-03 Enemy Scan"] call _runOne;
["tests\test_BEHAV_04_arty.sqf", "BEHAV-04 Artillery"] call _runOne;
["tests\test_BEHAV_05_chatter.sqf", "BEHAV-05 Chatter"] call _runOne;

// ---------- Final report ----------

systemChat "";
systemChat "================================================";
systemChat "=== HAL Test Harness: FINAL REPORT ===";
systemChat "================================================";
{
    _x params ["_label", "_p", "_f", "_t"];
    private _verdict = if (_f == 0 && _t > 0) then { "PASS" } else { "FAIL" };
    systemChat format ["  [%1] %2: %3/%4 passed (%5 failed)",
        _verdict, _label, _p, _t, _f];
} forEach HARNESS_agg_log;

systemChat "------------------------------------------------";
systemChat format ["  TOTAL: %1/%2 assertions passed, %3 failed",
    HARNESS_agg_pass, HARNESS_agg_total, HARNESS_agg_fail];

private _finalVerdict = if (HARNESS_agg_fail == 0 && HARNESS_agg_total > 0) then {
    "ALL PASS"
} else {
    format ["FAILURES DETECTED (%1)", HARNESS_agg_fail]
};
systemChat format ["  VERDICT: %1", _finalVerdict];
systemChat "================================================";

// Also hint chat in case systemChat scrolled away
hint format ["HAL Harness:\n%1 / %2 passed\n%3 failed\n\nVerdict: %4",
    HARNESS_agg_pass, HARNESS_agg_total, HARNESS_agg_fail, _finalVerdict];
