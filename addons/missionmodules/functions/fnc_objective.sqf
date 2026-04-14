#include "..\script_component.hpp"

params ["_logic"];

private _commanders = [];

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

    private _leaderObj = call compile _leaderName;

    // ObjType is a runtime string like "SimpleObjs", "NavalObjs", etc.
    // Construct the same variable name that GVAR(<objType>) would expand to,
    // but at runtime since the type is user-selected.
    private _objType = _logic getVariable "ObjType";
    private _gvarBase = format ["hal_missionmodules_%1", toLower _objType];
    private _fullVar = _gvarBase + _letter;
    missionNamespace setVariable [_fullVar, _logic];

} forEach _commanders;
