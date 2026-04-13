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

    // Editor module overrides CBA setting; CBA setting is the fallback default.
    missionNamespace setVariable [QEGVAR(core,mAtt)        + _letter, _logic getVariable [QEGVAR(core,mAtt),        EGVAR(core,mAtt)]];
    missionNamespace setVariable [QEGVAR(core,personality) + _letter, _logic getVariable [QEGVAR(core,personality), EGVAR(core,personality)]];

} forEach _commanders;
