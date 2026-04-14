#include "..\script_component.hpp"

params ["_logic"];

private _commanders = [];

private _objName = _logic getVariable "_ObjName";
if (_objName isNotEqualTo "") then {_logic setVariable ["ObjName",_objName]};

{
    if ((typeOf _x) == QGVAR(Leader_Module)) then {_commanders pushBack _x};
} forEach (synchronizedObjects _logic);

{
    private _leaderName = (_x getVariable "LeaderType");

    private _letter = switch (_leaderName) do {
        case "LeaderHQ":  {""};
        case "LeaderHQB": {"B"};
        case "LeaderHQC": {"C"};
        case "LeaderHQD": {"D"};
        case "LeaderHQE": {"E"};
        case "LeaderHQF": {"F"};
        case "LeaderHQG": {"G"};
        case "LeaderHQH": {"H"};
        default {""};
    };

    // _prefixT dispatch is OUT OF PHASE 4 SCOPE — SetTaken* keys are on _logic, not Ryd*-prefixed globals.
    private _prefixT = switch (_leaderName) do {
        case "LeaderHQ":  {"SetTakenA"};
        case "LeaderHQB": {"SetTakenB"};
        case "LeaderHQC": {"SetTakenC"};
        case "LeaderHQD": {"SetTakenD"};
        case "LeaderHQE": {"SetTakenE"};
        case "LeaderHQF": {"SetTakenF"};
        case "LeaderHQG": {"SetTakenG"};
        case "LeaderHQH": {"SetTakenH"};
        default {"SetTakenA"};
    };

    waitUntil {sleep 0.5; (!(isNil _leaderName))};

    private _leaderObj = call compile _leaderName;

    private _varName = QGVAR(simpleObjs) + _letter;

    if (isNil {missionNamespace getVariable _varName}) then {
        missionNamespace setVariable [_varName, []];
    };

    private _existing = missionNamespace getVariable [_varName, []];
    _existing pushBack _logic;
    missionNamespace setVariable [_varName, _existing];

    if ((_logic getVariable QGVAR(takenLeader)) isEqualTo (_x getVariable "LeaderType")) then  {
        (group _leaderObj) setVariable [QEGVAR(common,taken),((group _leaderObj) getVariable [QEGVAR(common,taken),[]]) + [_logic]];
        _logic setVariable [_prefixT,true];
    };

} forEach _commanders;
