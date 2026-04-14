// HAL Test Harness — One-shot: setup + wait + run-all
//
// Runs the scenario setup, gives HAL 60s to pick up the new groups, then
// executes all 5 BEHAV smoke tests and prints a single aggregate report.
//
// Usage (debug console):
//     0 = [] execVM "tests\harness\inject-and-run.sqf";
//
// Total runtime: ~5-6 minutes (setup + settle + 5 tests).

if (!isServer) exitWith {
    systemChat "[HARNESS] inject-and-run must run on the server. Aborting.";
};

systemChat "=== HAL Test Harness: inject-and-run ===";

private _setupHandle = [] execVM "tests\harness\setup-scenario.sqf";
waitUntil { scriptDone _setupHandle };

if !(missionNamespace getVariable ["HARNESS_setupComplete", false]) exitWith {
    systemChat "[HARNESS] Setup did not complete. Aborting tests.";
};

systemChat "[HARNESS] Setup done. Waiting 60s for HAL to assimilate new groups...";
sleep 60;

private _runHandle = [] execVM "tests\harness\run-all.sqf";
waitUntil { scriptDone _runHandle };

systemChat "[HARNESS] inject-and-run complete.";
