#include "..\script_component.hpp"

params ["_logic"];

private _commanders = [];

{
    if ((typeOf _x) == "NR6_HAL_Leader_Module") then {_commanders pushBack _x};
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

    missionNamespace setVariable [QGVAR(mAtt) + _letter,        _logic getVariable [QGVAR(mAtt), 0]];
    missionNamespace setVariable [QGVAR(personality) + _letter, _logic getVariable [QGVAR(personality), []]];

} forEach _commanders;
