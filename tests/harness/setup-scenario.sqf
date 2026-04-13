// HAL Test Harness — Scenario Setup
// Spawns a canned test scenario around the player so the BEHAV smoke tests
// have everything they need: a friendly HAL HQ with subordinate groups,
// enemies within sensor range, and an artillery piece.
//
// Usage (debug console, any HAL-enabled mission):
//     0 = [] execVM "tests\harness\setup-scenario.sqf";
//
// Or paste the whole file body into the console if tests\ isn't in the
// mission folder.
//
// Prerequisites:
//     - NR6-HAL mod loaded (CBA_A3 too)
//     - A HAL Core module (hal_missionmodules_Core_Module) placed in the
//       mission. Most easily done by saving an editor mission with one HAL
//       Core module placed and synced to the player's side.
//     - The player spawned and alive.
//
// What it spawns (all within 600m of the player):
//     - 3 friendly infantry squads (5 men each) on player side
//     - 1 friendly mortar team (2 men + 1x mortar) on player side
//     - 2 enemy infantry squads (5 men each) on the opposing side
// All friendly groups are pushed onto HAL's friends-list for the first HQ.
//
// Runs fire-and-forget. Prints progress to systemChat.

if (!isServer) exitWith {
    systemChat "[HARNESS] setup-scenario must run on the server. Aborting.";
};

systemChat "=== HAL Test Harness: scenario setup ===";

// ---------- 1. Wait for HAL to initialize ----------

systemChat "[HARNESS] Waiting up to 60s for HAL HQ to exist...";
private _deadline = time + 60;
waitUntil {
    sleep 1;
    private _allHQ = missionNamespace getVariable ["hal_core_allHQ", []];
    (count _allHQ > 0) || (time > _deadline)
};

private _allHQ = missionNamespace getVariable ["hal_core_allHQ", []];
if (count _allHQ == 0) exitWith {
    systemChat "[HARNESS] FAIL — no HAL HQ found after 60s. Is the HAL Core module placed?";
};

private _HQ = _allHQ select 0;
private _HQLeader = leader _HQ;
private _friendSide = side _HQLeader;
private _enemySide = [east, west] select (_friendSide isEqualTo east);
systemChat format ["[HARNESS] HQ found: %1 (side %2). Friendly=%2, Enemy=%3",
    groupId _HQ, _friendSide, _enemySide];

// ---------- 2. Pick anchor position ----------

private _anchor = if (!isNull player && {alive player}) then {
    getPosATL player
} else {
    getPosATL _HQLeader
};
systemChat format ["[HARNESS] Anchor position: %1", _anchor];

// ---------- 3. Resolve classnames ----------
// Vanilla A3 names that exist in every CDLC-free install.

private _bluRifleman = "B_Soldier_F";
private _bluSquadLead = "B_Soldier_SL_F";
private _bluMortarMan = "B_Soldier_F";
private _bluMortar = "B_Mortar_01_F";

private _opfRifleman = "O_Soldier_F";
private _opfSquadLead = "O_Soldier_SL_F";

// Mirror the classnames if the HQ is OPFOR (player is red)
if (_friendSide isEqualTo east) then {
    _bluRifleman = "O_Soldier_F";
    _bluSquadLead = "O_Soldier_SL_F";
    _bluMortarMan = "O_Soldier_F";
    _bluMortar = "O_Mortar_01_F";
    _opfRifleman = "B_Soldier_F";
    _opfSquadLead = "B_Soldier_SL_F";
};

// ---------- 4. Spawn helper ----------

private _spawnSquad = {
    params ["_side", "_pos", "_sqLeadCls", "_rifleCls", "_count", "_label"];
    private _grp = createGroup [_side, true];
    private _lead = _grp createUnit [_sqLeadCls, _pos, [], 0, "FORM"];
    _lead setDir random 360;
    for "_i" from 1 to (_count - 1) do {
        _grp createUnit [_rifleCls, _pos vectorAdd [(random 20) - 10, (random 20) - 10, 0], [], 0, "FORM"];
    };
    _grp setFormation "WEDGE";
    _grp setBehaviour "AWARE";
    _grp setCombatMode "YELLOW";
    _grp setGroupId [_label];
    _grp
};

// ---------- 5. Spawn friendly infantry squads ----------

private _friendlyGroups = [];

{
    _x params ["_offset", "_label"];
    private _pos = _anchor vectorAdd _offset;
    private _grp = [_friendSide, _pos, _bluSquadLead, _bluRifleman, 5, _label] call _spawnSquad;
    _friendlyGroups pushBack _grp;
    systemChat format ["[HARNESS] spawned %1 at %2 (%3 units)", _label, _pos, count (units _grp)];
    sleep 0.2;
} forEach [
    [[120, 80, 0], "HARNESS_A"],
    [[-100, 150, 0], "HARNESS_B"],
    [[180, -120, 0], "HARNESS_C"]
];

// ---------- 6. Spawn friendly mortar team ----------

private _mortarPos = _anchor vectorAdd [-200, 40, 0];
private _mortarGrp = createGroup [_friendSide, true];
_mortarGrp setGroupId ["HARNESS_ARTY"];

private _mortar = createVehicle [_bluMortar, _mortarPos, [], 0, "NONE"];
private _gunner = _mortarGrp createUnit [_bluMortarMan, _mortarPos, [], 0, "FORM"];
_gunner moveInGunner _mortar;
private _assist = _mortarGrp createUnit [_bluMortarMan, _mortarPos vectorAdd [3, 0, 0], [], 0, "FORM"];
_mortarGrp selectLeader _gunner;
_mortarGrp setBehaviour "AWARE";
_mortarGrp setCombatMode "YELLOW";
_friendlyGroups pushBack _mortarGrp;
systemChat format ["[HARNESS] spawned mortar team HARNESS_ARTY at %1 (mortar=%2)", _mortarPos, typeOf _mortar];

// ---------- 7. Spawn enemy squads ----------

private _enemyGroups = [];

{
    _x params ["_offset", "_label"];
    private _pos = _anchor vectorAdd _offset;
    private _grp = [_enemySide, _pos, _opfSquadLead, _opfRifleman, 5, _label] call _spawnSquad;
    _enemyGroups pushBack _grp;
    systemChat format ["[HARNESS] spawned %1 (enemy) at %2", _label, _pos];
    sleep 0.2;
} forEach [
    [[500, 350, 0], "HARNESS_E1"],
    [[-450, 500, 0], "HARNESS_E2"]
];

// ---------- 8. Register friendly groups with HAL HQ ----------
//
// HAL tracks subordinate groups via the HQ's friends list (and multi-HQ
// variants). Push each spawned friendly group onto hal_core_friends so the
// HAL scanning loops treat them as owned groups.
//
// Also try to find any HAL Include module on the map and synchronize our
// groups to it so HAL's own pickup-loop catches them — belt and suspenders.

private _friends = _HQ getVariable ["hal_core_friends", []];
{
    if !(_x in _friends) then { _friends pushBack _x };
} forEach _friendlyGroups;
_HQ setVariable ["hal_core_friends", _friends, true];
systemChat format ["[HARNESS] HQ friends list now has %1 groups", count _friends];

private _includeLogic = objNull;
{
    if (typeOf _x == "hal_missionmodules_Leader_Include_Module") exitWith {
        _includeLogic = _x;
    };
} forEach (allMissionObjects "hal_missionmodules_Leader_Include_Module");

if (!isNull _includeLogic) then {
    {
        private _lead = leader _x;
        if (!isNull _lead && {alive _lead}) then {
            [_includeLogic, [_lead]] remoteExec ["synchronizeObjectsAdd", 2];
        };
    } forEach _friendlyGroups;
    systemChat format ["[HARNESS] synchronized %1 friendly groups to HAL Include module",
        count _friendlyGroups];
} else {
    systemChat "[HARNESS] No HAL Include module found on map — skipped sync (friends list push still applied)";
};

// ---------- 9. Final summary ----------

sleep 2;
systemChat format ["=== HAL Test Harness: scenario ready ==="];
systemChat format ["  Friendly groups: %1 (3 infantry + 1 mortar)", count _friendlyGroups];
systemChat format ["  Enemy groups: %1", count _enemyGroups];
systemChat format ["  HQ friends list: %1 entries", count _friends];
systemChat "[HARNESS] Now run: 0 = [] execVM 'tests\harness\run-all.sqf';";

// Export handles for run-all.sqf
missionNamespace setVariable ["HARNESS_friendlyGroups", _friendlyGroups];
missionNamespace setVariable ["HARNESS_enemyGroups", _enemyGroups];
missionNamespace setVariable ["HARNESS_HQ", _HQ];
missionNamespace setVariable ["HARNESS_setupComplete", true];
