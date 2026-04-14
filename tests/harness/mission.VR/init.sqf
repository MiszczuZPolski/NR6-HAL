// HAL test mission — init.sqf
// Fires once on mission start. Auto-runs the harness 30s after HAL has
// initialized so the user doesn't have to touch the debug console.

if (!isServer) exitWith {};

[] spawn {
    systemChat "=== HAL Test Mission: auto-harness will start in 30s ===";
    sleep 30;
    systemChat "[HARNESS] Starting automated scenario setup + BEHAV tests.";
    [] execVM "harness\inject-and-run.sqf";
};
