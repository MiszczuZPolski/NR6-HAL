#include "..\script_component.hpp"

params ["_logic", "_units", "_activated"];

private _commanders = [];

{
    if ((typeOf _x) == QGVAR(Leader_Module)) then {_commanders pushBack _x};
} forEach (synchronizedObjects _logic);

{
    private _leader = (_x getVariable "LeaderType");

    private _letter = switch (_leader) do {
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

    missionNamespace setVariable [QGVAR(front) + _letter, _logic getVariable [QGVAR(front), false]];

    // HET_F<letter> dispatch is OUT OF PHASE 4 SCOPE — HET_F* globals are not Ryd*-prefixed.
    // Preserved verbatim below (uses "A".."H" suffix, NOT ""/"B".."H").
    private _hetLetter = switch (_leader) do {
        case "LeaderHQ":  {"A"};
        case "LeaderHQB": {"B"};
        case "LeaderHQC": {"C"};
        case "LeaderHQD": {"D"};
        case "LeaderHQE": {"E"};
        case "LeaderHQF": {"F"};
        case "LeaderHQG": {"G"};
        case "LeaderHQH": {"H"};
        default {"A"};
    };

    private _area = _logic getVariable ["objectArea", [0, 0, 0, true, 0]];

    private _trigger = createTrigger ["EmptyDetector", getPos _logic];
    _trigger setTriggerArea [_area select 0, _area select 1, _area select 2, _area select 3];

    _trigger call compile ("HET_F" + _hetLetter + " = _this");


} forEach _commanders;
