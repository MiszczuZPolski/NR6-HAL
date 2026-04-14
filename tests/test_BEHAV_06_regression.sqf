// BEHAV-06: Regression Test for 2026-04-14 Debug Session Bugs
// Run via: 0 = [] execVM "tests\test_BEHAV_06_regression.sqf"; in debug console
// Prerequisites: HAL Core module + at least one Leader_Include group synced.
//                Ideally also the setup-scenario harness so there's a battery.
//
// Verifies that every critical variable seeded across Rounds 1-18 (see
// .planning/debug/runtime-init-errors.md) is still populated at runtime.
// If any of these assertions fail, a Phase 4/5 migration bug has re-surfaced.
//
// WHAT THIS CATCHES:
//   - Missing preInit seeds (Rounds 1, 2, 4, 5, 6, 7, 8, 11, 16, 17)
//   - Cross-addon namespace splits (Rounds 12, 13, 15, 16, 18)
//   - Missing function PREPs that would cause bare-call crashes (Rounds 7, 10, 14)
//   - Data taxonomy population (Round 6 Bug 12)
//   - HQSitRep loop actually reaches classifyFriends (Round 12 Bug 22)
//
// WHAT THIS DOESN'T CATCH:
//   - Runtime type errors (null group, HashMap key type, etc.) — those crash
//     immediately in RPT; watch diag_log for "Error in expression" lines.
//   - Tactical correctness — HAL is stochastic; we only check machinery.

private _testName = "BEHAV-06: Post-Debug Regression Wall";
NR6HAL_TEST_pass = 0;
NR6HAL_TEST_fail = 0;
NR6HAL_TEST_total = 0;
NR6HAL_TEST_failures = [];

private _check = {
    params ["_desc", "_condition"];
    NR6HAL_TEST_total = NR6HAL_TEST_total + 1;
    if (_condition) then {
        NR6HAL_TEST_pass = NR6HAL_TEST_pass + 1;
        systemChat format ["  [PASS] %1", _desc];
    } else {
        NR6HAL_TEST_fail = NR6HAL_TEST_fail + 1;
        NR6HAL_TEST_failures pushBack _desc;
        systemChat format ["  [FAIL] %1", _desc];
    };
};

private _checkSeeded = {
    params ["_varName"];
    private _val = missionNamespace getVariable [_varName, "NIL_SENTINEL"];
    [format ["%1 is seeded (not nil)", _varName], _val isNotEqualTo "NIL_SENTINEL"] call _check;
};

private _checkFuncCompiled = {
    params ["_funcName"];
    private _val = missionNamespace getVariable [_funcName, "NIL_SENTINEL"];
    [format ["%1 is compiled (FUNC/EFUNC)", _funcName], _val isEqualType {}] call _check;
};

systemChat format ["=== %1 ===", _testName];
systemChat "Waiting 60s for HAL init and first HQSitRep cycle...";
sleep 60;

// ==========================================================================
// Round 1 — Missing preInit seeds for core arrays
// ==========================================================================
systemChat "-- Round 1: common/handles + HQSitRep final-func --";
["hal_common_handles"] call _checkSeeded;

// ==========================================================================
// Round 2 — missionmodules seeds + common debug flags
// ==========================================================================
systemChat "-- Round 2: missionmodules + common debug --";
["hal_missionmodules_active"] call _checkSeeded;
["hal_common_debug"] call _checkSeeded;
["hal_common_debugB"] call _checkSeeded;
["hal_common_debugC"] call _checkSeeded;
["hal_common_debugD"] call _checkSeeded;
["hal_common_debugE"] call _checkSeeded;
["hal_common_debugF"] call _checkSeeded;
["hal_common_debugG"] call _checkSeeded;
["hal_common_debugH"] call _checkSeeded;

// ==========================================================================
// Round 4 — Core leader discovery must populate allHQ
// ==========================================================================
systemChat "-- Round 4: leader discovery --";
private _allHQ = missionNamespace getVariable ["hal_core_allHQ", []];
["hal_core_allHQ is populated (leaders discovered)", (count _allHQ) > 0] call _check;

// ==========================================================================
// Round 5 — callSigns seed
// ==========================================================================
systemChat "-- Round 5: callSignsN --";
["hal_core_callSignsN"] call _checkSeeded;
private _csn = missionNamespace getVariable ["hal_core_callSignsN", []];
["hal_core_callSignsN has entries", (count _csn) > 0] call _check;

// ==========================================================================
// Round 6 — data taxonomy populated by initWeaponClasses
// ==========================================================================
systemChat "-- Round 6: hal_data_* class arrays --";
private _dataArrays = [
    "hal_data_wS_AllClasses",
    "hal_data_wS_Inf_class",
    "hal_data_wS_Art_class",
    "hal_data_wS_Crew_class",
    "hal_data_wS_Cargo_class",
    "hal_data_inf",
    "hal_data_specFor"
];
{
    [_x] call _checkSeeded;
    private _val = missionNamespace getVariable [_x, []];
    [format ["%1 has entries", _x], (count _val) > 0] call _check;
} forEach _dataArrays;

// ==========================================================================
// Round 7 — hac/boss/common AI chatter arrays
// ==========================================================================
systemChat "-- Round 7: aIC_* chatter arrays --";
private _chatterArrays = [
    "hal_boss_aIC_OrdConf",
    "hal_hac_aIC_OrdConf",
    "hal_hac_aIC_OrdDen",
    "hal_hac_aIC_SuppReq",
    "hal_hac_aIC_MedReq",
    "hal_hac_aIC_EnemySpot",
    "hal_common_aIC_ArtyReq",
    "hal_common_aIC_ArtAss"
];
{ [_x] call _checkSeeded } forEach _chatterArrays;

// ==========================================================================
// Round 12 — missionmodules→core included bridge
// ==========================================================================
systemChat "-- Round 12: included bridge --";
private _mmIncluded = missionNamespace getVariable ["hal_missionmodules_included", []];
["hal_missionmodules_included populated by Leader_Include module", (count _mmIncluded) > 0] call _check;

if ((count _allHQ) > 0) then {
    private _hq = _allHQ select 0;
    private _hqIncluded = _hq getVariable ["hal_core_included", []];
    ["HQ.hal_core_included bridged from missionmodules", (count _hqIncluded) > 0] call _check;

    private _hqFriends = _hq getVariable ["hal_core_friends", []];
    ["HQ.hal_core_friends populated by scanFriends loop", (count _hqFriends) > 0] call _check;
};

// ==========================================================================
// Round 14 — hac functions must be compiled (not bare globals)
// ==========================================================================
systemChat "-- Round 14: hac function PREPs --";
private _hacFuncs = [
    "hal_hac_fnc_statusQuo",
    "hal_hac_fnc_statusQuo_classifyFriends",
    "hal_hac_fnc_dispatcher",
    "hal_hac_fnc_goAttInf",
    "hal_hac_fnc_goDef",
    "hal_common_fnc_ammoCount",
    "hal_common_fnc_ammoFullCount",
    "hal_common_fnc_spawn",
    "hal_common_fnc_wait",
    "hal_common_fnc_WPadd",
    "hal_common_fnc_mark",
    "hal_common_fnc_flares",
    "hal_common_fnc_artyMission",
    "hal_common_fnc_cff",
    "hal_common_fnc_cff_fire"
];
{ [_x] call _checkFuncCompiled } forEach _hacFuncs;

// ==========================================================================
// Round 15 — gPauseActive cross-addon reference
// ==========================================================================
systemChat "-- Round 15: gPauseActive --";
["hal_common_gPauseActive"] call _checkSeeded;

// ==========================================================================
// Round 16 — mARatio + artillery classname lists
// ==========================================================================
systemChat "-- Round 16: mARatio + arty classname lists --";
["hal_hac_mARatio"] call _checkSeeded;
private _mar = missionNamespace getVariable ["hal_hac_mARatio", []];
["hal_hac_mARatio has 5 entries", (count _mar) == 5] call _check;

private _artyLists = [
    "hal_core_mortar_A3",
    "hal_core_sPMortar_A3",
    "hal_core_rocket_A3",
    "hal_common_allArty"
];
{
    [_x] call _checkSeeded;
    private _val = missionNamespace getVariable [_x, []];
    [format ["%1 has entries", _x], (count _val) > 0] call _check;
} forEach _artyLists;

// ==========================================================================
// Round 18 — 14 missionmodules→core bridge variables
// ==========================================================================
systemChat "-- Round 18: missionmodules bridge variables --";
if ((count _allHQ) > 0) then {
    private _hq = _allHQ select 0;
    private _bridged = [
        "hal_core_simpleObjs", "hal_core_navalObjs",
        "hal_core_noRecon", "hal_core_noAttack", "hal_core_noCargo", "hal_core_noFlank",
        "hal_core_rDChance", "hal_core_sDChance",
        "hal_core_supportDecoy", "hal_core_restDecoy",
        "hal_core_rCAP", "hal_core_rCAS", "hal_core_rOnly", "hal_core_sFBodyGuard",
        "hal_core_aOnly", "hal_core_alwaysKnownU", "hal_core_excluded",
        "hal_core_ammoBoxes", "hal_core_ammoDrop",
        "hal_core_exMedic", "hal_core_exRefuel", "hal_core_exReammo", "hal_core_exRepair",
        "hal_core_firstToFight", "hal_core_garrison",
        "hal_core_iDChance", "hal_core_idleDecoy",
        "hal_core_cargoOnly", "hal_core_noDef",
        "hal_core_front"
    ];
    {
        private _val = _hq getVariable [_x, "NIL_SENTINEL"];
        [format ["HQ.%1 bridged (not nil)", _x], _val isNotEqualTo "NIL_SENTINEL"] call _check;
    } forEach _bridged;
};

// ==========================================================================
// Round 19 — Phase 6 delete compat: HQSitRep dispatch seeds and HAL_* handles
// Context: Plan 06-02 replaced compat_nr6hal's alias mirror with (a) seeds
// for A..H_HQSitRep in addons/core/XEH_postInit.sqf, and (b) direct EFUNC()
// rewrites of 57 HAL_* call sites across hac/common/tasking. These assertions
// make sure neither half regresses.
// ==========================================================================
systemChat "-- Round 19: HQSitRep dispatch seeds --";

// 19a. A..H_HQSitRep dispatch — MUST exist because fnc_init.sqf:226 looks them
// up by string concatenation, which EFUNC() cannot replace.
["A_HQSitRep"] call _checkSeeded;
["B_HQSitRep"] call _checkSeeded;
["C_HQSitRep"] call _checkSeeded;
["D_HQSitRep"] call _checkSeeded;
["E_HQSitRep"] call _checkSeeded;
["F_HQSitRep"] call _checkSeeded;
["G_HQSitRep"] call _checkSeeded;
["H_HQSitRep"] call _checkSeeded;

[
    "A_HQSitRep points at hal_core_fnc_HQSitRep",
    (missionNamespace getVariable ["A_HQSitRep", {}]) isEqualTo (missionNamespace getVariable ["hal_core_fnc_HQSitRep", {"NIL"}])
] call _check;

[
    "B_HQSitRep points at hal_core_fnc_HQSitRepB",
    (missionNamespace getVariable ["B_HQSitRep", {}]) isEqualTo (missionNamespace getVariable ["hal_core_fnc_HQSitRepB", {"NIL"}])
] call _check;

[
    "C_HQSitRep points at hal_core_fnc_HQSitRepC",
    (missionNamespace getVariable ["C_HQSitRep", {}]) isEqualTo (missionNamespace getVariable ["hal_core_fnc_HQSitRepC", {"NIL"}])
] call _check;

[
    "D_HQSitRep points at hal_core_fnc_HQSitRepD",
    (missionNamespace getVariable ["D_HQSitRep", {}]) isEqualTo (missionNamespace getVariable ["hal_core_fnc_HQSitRepD", {"NIL"}])
] call _check;

[
    "E_HQSitRep points at hal_core_fnc_HQSitRepE",
    (missionNamespace getVariable ["E_HQSitRep", {}]) isEqualTo (missionNamespace getVariable ["hal_core_fnc_HQSitRepE", {"NIL"}])
] call _check;

[
    "F_HQSitRep points at hal_core_fnc_HQSitRepF",
    (missionNamespace getVariable ["F_HQSitRep", {}]) isEqualTo (missionNamespace getVariable ["hal_core_fnc_HQSitRepF", {"NIL"}])
] call _check;

[
    "G_HQSitRep points at hal_core_fnc_HQSitRepG",
    (missionNamespace getVariable ["G_HQSitRep", {}]) isEqualTo (missionNamespace getVariable ["hal_core_fnc_HQSitRepG", {"NIL"}])
] call _check;

[
    "H_HQSitRep points at hal_core_fnc_HQSitRepH",
    (missionNamespace getVariable ["H_HQSitRep", {}]) isEqualTo (missionNamespace getVariable ["hal_core_fnc_HQSitRepH", {"NIL"}])
] call _check;

// 19b. HAL_* tactical handles — after 06-02 migrates the 5 consumer files to
// EFUNC() form, the bare globals should no longer be needed. We assert that
// the PRODUCTION functions themselves are compiled (not the bare HAL_* names,
// which Plan 06-02 explicitly does not reseed).
systemChat "-- Round 19b: hac tactical function PREPs --";
["hal_hac_fnc_goRecon"] call _checkFuncCompiled;
["hal_hac_fnc_goRest"] call _checkFuncCompiled;
["hal_hac_fnc_goCapture"] call _checkFuncCompiled;
["hal_hac_fnc_goIdle"] call _checkFuncCompiled;
["hal_hac_fnc_goDef"] call _checkFuncCompiled;
["hal_hac_fnc_goDefRes"] call _checkFuncCompiled;
["hal_hac_fnc_goDefAir"] call _checkFuncCompiled;
["hal_hac_fnc_goDefNav"] call _checkFuncCompiled;
["hal_hac_fnc_goDefRecon"] call _checkFuncCompiled;
["hal_hac_fnc_goCaptureNaval"] call _checkFuncCompiled;
["hal_hac_fnc_goFlank"] call _checkFuncCompiled;
["hal_hac_fnc_goAttInf"] call _checkFuncCompiled;
["hal_hac_fnc_goAttArmor"] call _checkFuncCompiled;
["hal_hac_fnc_goAttAir"] call _checkFuncCompiled;
["hal_hac_fnc_goAttAirCAP"] call _checkFuncCompiled;
["hal_hac_fnc_goAttSniper"] call _checkFuncCompiled;
["hal_hac_fnc_goAttNaval"] call _checkFuncCompiled;
["hal_hac_fnc_sCargo"] call _checkFuncCompiled;
["hal_hac_fnc_lhq"] call _checkFuncCompiled;

// ==========================================================================
// Summary
// ==========================================================================
sleep 1;
systemChat "";
systemChat format ["=== %1 RESULTS ===", _testName];
systemChat format ["Total: %1 | Pass: %2 | Fail: %3",
    NR6HAL_TEST_total, NR6HAL_TEST_pass, NR6HAL_TEST_fail];

if (NR6HAL_TEST_fail == 0) then {
    systemChat "ALL REGRESSION CHECKS PASSED — Phase 6 regression wall is stable.";
} else {
    systemChat format ["%1 REGRESSIONS DETECTED:", NR6HAL_TEST_fail];
    {
        systemChat format ["  - %1", _x];
    } forEach NR6HAL_TEST_failures;
    systemChat "See .planning/debug/runtime-init-errors.md for fix history.";
};
