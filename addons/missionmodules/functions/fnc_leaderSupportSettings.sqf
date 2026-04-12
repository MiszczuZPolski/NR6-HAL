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

    missionNamespace setVariable [QGVAR(cargoFind) + _letter,   _logic getVariable [QGVAR(cargoFind), false]];
    missionNamespace setVariable [QGVAR(noAirCargo) + _letter,  _logic getVariable [QGVAR(noAirCargo), false]];
    missionNamespace setVariable [QGVAR(noLandCargo) + _letter, _logic getVariable [QGVAR(noLandCargo), false]];
    missionNamespace setVariable [QGVAR(sMed) + _letter,        _logic getVariable [QGVAR(sMed), false]];
    missionNamespace setVariable [QGVAR(sFuel) + _letter,       _logic getVariable [QGVAR(sFuel), false]];
    missionNamespace setVariable [QGVAR(sAmmo) + _letter,       _logic getVariable [QGVAR(sAmmo), false]];
    missionNamespace setVariable [QGVAR(sRep) + _letter,        _logic getVariable [QGVAR(sRep), false]];
    missionNamespace setVariable [QGVAR(supportWP) + _letter,   _logic getVariable [QGVAR(supportWP), false]];
    missionNamespace setVariable [QGVAR(artyShells) + _letter,  _logic getVariable [QGVAR(artyShells), 0]];
    missionNamespace setVariable [QGVAR(airEvac) + _letter,     _logic getVariable [QGVAR(airEvac), false]];
    missionNamespace setVariable [QGVAR(supportRTB) + _letter,  _logic getVariable [QGVAR(supportRTB), false]];

} forEach _commanders;
