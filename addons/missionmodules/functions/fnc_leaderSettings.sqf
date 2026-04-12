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

    missionNamespace setVariable [QGVAR(fast) + _letter,          _logic getVariable [QGVAR(fast), false]];
    missionNamespace setVariable [QGVAR(commDelay) + _letter,     _logic getVariable [QGVAR(commDelay), 0]];
    missionNamespace setVariable [QGVAR(hQChat) + _letter,        _logic getVariable [QGVAR(hQChat), false]];
    missionNamespace setVariable [QGVAR(chatDebug) + _letter,     _logic getVariable [QGVAR(chatDebug), false]];
    missionNamespace setVariable [QGVAR(exInfo) + _letter,        _logic getVariable [QGVAR(exInfo), false]];
    missionNamespace setVariable [QGVAR(resetTime) + _letter,     _logic getVariable [QGVAR(resetTime), 0]];
    missionNamespace setVariable [QGVAR(resetOnDemand) + _letter, _logic getVariable [QGVAR(resetOnDemand), false]];
    missionNamespace setVariable [QGVAR(subAll) + _letter,        _logic getVariable [QGVAR(subAll), false]];
    missionNamespace setVariable [QGVAR(subSynchro) + _letter,    _logic getVariable [QGVAR(subSynchro), false]];
    missionNamespace setVariable [QGVAR(knowTL) + _letter,        _logic getVariable [QGVAR(knowTL), false]];
    missionNamespace setVariable [QGVAR(getHQInside) + _letter,   _logic getVariable [QGVAR(getHQInside), false]];
    missionNamespace setVariable [QGVAR(camV) + _letter,          _logic getVariable [QGVAR(camV), false]];
    missionNamespace setVariable [QGVAR(infoMarkers) + _letter,   _logic getVariable [QGVAR(infoMarkers), false]];
    missionNamespace setVariable [QGVAR(artyMarks) + _letter,     _logic getVariable [QGVAR(artyMarks), false]];
    missionNamespace setVariable [QGVAR(secTasks) + _letter,      _logic getVariable [QGVAR(secTasks), false]];
    missionNamespace setVariable [QGVAR(debug) + _letter,         _logic getVariable [QGVAR(debug), false]];

} forEach _commanders;
